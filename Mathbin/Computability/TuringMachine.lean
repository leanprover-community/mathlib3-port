/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module computability.turing_machine
! leanprover-community/mathlib commit e97cf15cd1aec9bd5c193b2ffac5a6dc9118912b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fintype.Option
import Mathbin.Data.Fintype.Prod
import Mathbin.Data.Fintype.Pi
import Mathbin.Data.Vector.Basic
import Mathbin.Data.Pfun
import Mathbin.Logic.Function.Iterate
import Mathbin.Order.Basic
import Mathbin.Tactic.ApplyFun

/-!
# Turing machines

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines a sequence of simple machine languages, starting with Turing machines and working
up to more complex languages based on Wang B-machines.

## Naming conventions

Each model of computation in this file shares a naming convention for the elements of a model of
computation. These are the parameters for the language:

* `Γ` is the alphabet on the tape.
* `Λ` is the set of labels, or internal machine states.
* `σ` is the type of internal memory, not on the tape. This does not exist in the TM0 model, and
  later models achieve this by mixing it into `Λ`.
* `K` is used in the TM2 model, which has multiple stacks, and denotes the number of such stacks.

All of these variables denote "essentially finite" types, but for technical reasons it is
convenient to allow them to be infinite anyway. When using an infinite type, we will be interested
to prove that only finitely many values of the type are ever interacted with.

Given these parameters, there are a few common structures for the model that arise:

* `stmt` is the set of all actions that can be performed in one step. For the TM0 model this set is
  finite, and for later models it is an infinite inductive type representing "possible program
  texts".
* `cfg` is the set of instantaneous configurations, that is, the state of the machine together with
  its environment.
* `machine` is the set of all machines in the model. Usually this is approximately a function
  `Λ → stmt`, although different models have different ways of halting and other actions.
* `step : cfg → option cfg` is the function that describes how the state evolves over one step.
  If `step c = none`, then `c` is a terminal state, and the result of the computation is read off
  from `c`. Because of the type of `step`, these models are all deterministic by construction.
* `init : input → cfg` sets up the initial state. The type `input` depends on the model;
  in most cases it is `list Γ`.
* `eval : machine → input → part output`, given a machine `M` and input `i`, starts from
  `init i`, runs `step` until it reaches an output, and then applies a function `cfg → output` to
  the final state to obtain the result. The type `output` depends on the model.
* `supports : machine → finset Λ → Prop` asserts that a machine `M` starts in `S : finset Λ`, and
  can only ever jump to other states inside `S`. This implies that the behavior of `M` on any input
  cannot depend on its values outside `S`. We use this to allow `Λ` to be an infinite set when
  convenient, and prove that only finitely many of these states are actually accessible. This
  formalizes "essentially finite" mentioned above.
-/


open Relation

open Nat (iterate)

open
  Function (update iterate_succ iterate_succ_apply iterate_succ' iterate_succ_apply' iterate_zero_apply)

namespace Turing

#print Turing.BlankExtends /-
/-- The `blank_extends` partial order holds of `l₁` and `l₂` if `l₂` is obtained by adding
blanks (`default : Γ`) to the end of `l₁`. -/
def BlankExtends {Γ} [Inhabited Γ] (l₁ l₂ : List Γ) : Prop :=
  ∃ n, l₂ = l₁ ++ List.replicate n default
#align turing.blank_extends Turing.BlankExtends
-/

#print Turing.BlankExtends.refl /-
@[refl]
theorem BlankExtends.refl {Γ} [Inhabited Γ] (l : List Γ) : BlankExtends l l :=
  ⟨0, by simp⟩
#align turing.blank_extends.refl Turing.BlankExtends.refl
-/

#print Turing.BlankExtends.trans /-
@[trans]
theorem BlankExtends.trans {Γ} [Inhabited Γ] {l₁ l₂ l₃ : List Γ} :
    BlankExtends l₁ l₂ → BlankExtends l₂ l₃ → BlankExtends l₁ l₃ :=
  by
  rintro ⟨i, rfl⟩ ⟨j, rfl⟩
  exact ⟨i + j, by simp [List.replicate_add]⟩
#align turing.blank_extends.trans Turing.BlankExtends.trans
-/

#print Turing.BlankExtends.below_of_le /-
theorem BlankExtends.below_of_le {Γ} [Inhabited Γ] {l l₁ l₂ : List Γ} :
    BlankExtends l l₁ → BlankExtends l l₂ → l₁.length ≤ l₂.length → BlankExtends l₁ l₂ :=
  by
  rintro ⟨i, rfl⟩ ⟨j, rfl⟩ h; use j - i
  simp only [List.length_append, add_le_add_iff_left, List.length_replicate] at h
  simp only [← List.replicate_add, add_tsub_cancel_of_le h, List.append_assoc]
#align turing.blank_extends.below_of_le Turing.BlankExtends.below_of_le
-/

#print Turing.BlankExtends.above /-
/-- Any two extensions by blank `l₁,l₂` of `l` have a common join (which can be taken to be the
longer of `l₁` and `l₂`). -/
def BlankExtends.above {Γ} [Inhabited Γ] {l l₁ l₂ : List Γ} (h₁ : BlankExtends l l₁)
    (h₂ : BlankExtends l l₂) : { l' // BlankExtends l₁ l' ∧ BlankExtends l₂ l' } :=
  if h : l₁.length ≤ l₂.length then ⟨l₂, h₁.below_of_le h₂ h, BlankExtends.refl _⟩
  else ⟨l₁, BlankExtends.refl _, h₂.below_of_le h₁ (le_of_not_ge h)⟩
#align turing.blank_extends.above Turing.BlankExtends.above
-/

#print Turing.BlankExtends.above_of_le /-
theorem BlankExtends.above_of_le {Γ} [Inhabited Γ] {l l₁ l₂ : List Γ} :
    BlankExtends l₁ l → BlankExtends l₂ l → l₁.length ≤ l₂.length → BlankExtends l₁ l₂ :=
  by
  rintro ⟨i, rfl⟩ ⟨j, e⟩ h; use i - j
  refine' List.append_right_cancel (e.symm.trans _)
  rw [List.append_assoc, ← List.replicate_add, tsub_add_cancel_of_le]
  apply_fun List.length  at e
  simp only [List.length_append, List.length_replicate] at e
  rwa [← add_le_add_iff_left, e, add_le_add_iff_right]
#align turing.blank_extends.above_of_le Turing.BlankExtends.above_of_le
-/

#print Turing.BlankRel /-
/-- `blank_rel` is the symmetric closure of `blank_extends`, turning it into an equivalence
relation. Two lists are related by `blank_rel` if one extends the other by blanks. -/
def BlankRel {Γ} [Inhabited Γ] (l₁ l₂ : List Γ) : Prop :=
  BlankExtends l₁ l₂ ∨ BlankExtends l₂ l₁
#align turing.blank_rel Turing.BlankRel
-/

#print Turing.BlankRel.refl /-
@[refl]
theorem BlankRel.refl {Γ} [Inhabited Γ] (l : List Γ) : BlankRel l l :=
  Or.inl (BlankExtends.refl _)
#align turing.blank_rel.refl Turing.BlankRel.refl
-/

#print Turing.BlankRel.symm /-
@[symm]
theorem BlankRel.symm {Γ} [Inhabited Γ] {l₁ l₂ : List Γ} : BlankRel l₁ l₂ → BlankRel l₂ l₁ :=
  Or.symm
#align turing.blank_rel.symm Turing.BlankRel.symm
-/

#print Turing.BlankRel.trans /-
@[trans]
theorem BlankRel.trans {Γ} [Inhabited Γ] {l₁ l₂ l₃ : List Γ} :
    BlankRel l₁ l₂ → BlankRel l₂ l₃ → BlankRel l₁ l₃ :=
  by
  rintro (h₁ | h₁) (h₂ | h₂)
  · exact Or.inl (h₁.trans h₂)
  · cases' le_total l₁.length l₃.length with h h
    · exact Or.inl (h₁.above_of_le h₂ h)
    · exact Or.inr (h₂.above_of_le h₁ h)
  · cases' le_total l₁.length l₃.length with h h
    · exact Or.inl (h₁.below_of_le h₂ h)
    · exact Or.inr (h₂.below_of_le h₁ h)
  · exact Or.inr (h₂.trans h₁)
#align turing.blank_rel.trans Turing.BlankRel.trans
-/

#print Turing.BlankRel.above /-
/-- Given two `blank_rel` lists, there exists (constructively) a common join. -/
def BlankRel.above {Γ} [Inhabited Γ] {l₁ l₂ : List Γ} (h : BlankRel l₁ l₂) :
    { l // BlankExtends l₁ l ∧ BlankExtends l₂ l } :=
  by
  refine'
    if hl : l₁.length ≤ l₂.length then ⟨l₂, Or.elim h id fun h' => _, blank_extends.refl _⟩
    else ⟨l₁, blank_extends.refl _, Or.elim h (fun h' => _) id⟩
  exact (blank_extends.refl _).above_of_le h' hl
  exact (blank_extends.refl _).above_of_le h' (le_of_not_ge hl)
#align turing.blank_rel.above Turing.BlankRel.above
-/

#print Turing.BlankRel.below /-
/-- Given two `blank_rel` lists, there exists (constructively) a common meet. -/
def BlankRel.below {Γ} [Inhabited Γ] {l₁ l₂ : List Γ} (h : BlankRel l₁ l₂) :
    { l // BlankExtends l l₁ ∧ BlankExtends l l₂ } :=
  by
  refine'
    if hl : l₁.length ≤ l₂.length then ⟨l₁, blank_extends.refl _, Or.elim h id fun h' => _⟩
    else ⟨l₂, Or.elim h (fun h' => _) id, blank_extends.refl _⟩
  exact (blank_extends.refl _).above_of_le h' hl
  exact (blank_extends.refl _).above_of_le h' (le_of_not_ge hl)
#align turing.blank_rel.below Turing.BlankRel.below
-/

#print Turing.BlankRel.equivalence /-
theorem BlankRel.equivalence (Γ) [Inhabited Γ] : Equivalence (@BlankRel Γ _) :=
  ⟨BlankRel.refl, @BlankRel.symm _ _, @BlankRel.trans _ _⟩
#align turing.blank_rel.equivalence Turing.BlankRel.equivalence
-/

#print Turing.BlankRel.setoid /-
/-- Construct a setoid instance for `blank_rel`. -/
def BlankRel.setoid (Γ) [Inhabited Γ] : Setoid (List Γ) :=
  ⟨_, BlankRel.equivalence _⟩
#align turing.blank_rel.setoid Turing.BlankRel.setoid
-/

#print Turing.ListBlank /-
/-- A `list_blank Γ` is a quotient of `list Γ` by extension by blanks at the end. This is used to
represent half-tapes of a Turing machine, so that we can pretend that the list continues
infinitely with blanks. -/
def ListBlank (Γ) [Inhabited Γ] :=
  Quotient (BlankRel.setoid Γ)
#align turing.list_blank Turing.ListBlank
-/

#print Turing.ListBlank.inhabited /-
instance ListBlank.inhabited {Γ} [Inhabited Γ] : Inhabited (ListBlank Γ) :=
  ⟨Quotient.mk'' []⟩
#align turing.list_blank.inhabited Turing.ListBlank.inhabited
-/

#print Turing.ListBlank.hasEmptyc /-
instance ListBlank.hasEmptyc {Γ} [Inhabited Γ] : EmptyCollection (ListBlank Γ) :=
  ⟨Quotient.mk'' []⟩
#align turing.list_blank.has_emptyc Turing.ListBlank.hasEmptyc
-/

#print Turing.ListBlank.liftOn /-
/-- A modified version of `quotient.lift_on'` specialized for `list_blank`, with the stronger
precondition `blank_extends` instead of `blank_rel`. -/
@[elab_as_elim, reducible]
protected def ListBlank.liftOn {Γ} [Inhabited Γ] {α} (l : ListBlank Γ) (f : List Γ → α)
    (H : ∀ a b, BlankExtends a b → f a = f b) : α :=
  l.liftOn' f <| by rintro a b (h | h) <;> [exact H _ _ h, exact (H _ _ h).symm]
#align turing.list_blank.lift_on Turing.ListBlank.liftOn
-/

#print Turing.ListBlank.mk /-
/-- The quotient map turning a `list` into a `list_blank`. -/
def ListBlank.mk {Γ} [Inhabited Γ] : List Γ → ListBlank Γ :=
  Quotient.mk''
#align turing.list_blank.mk Turing.ListBlank.mk
-/

#print Turing.ListBlank.induction_on /-
@[elab_as_elim]
protected theorem ListBlank.induction_on {Γ} [Inhabited Γ] {p : ListBlank Γ → Prop}
    (q : ListBlank Γ) (h : ∀ a, p (ListBlank.mk a)) : p q :=
  Quotient.inductionOn' q h
#align turing.list_blank.induction_on Turing.ListBlank.induction_on
-/

#print Turing.ListBlank.head /-
/-- The head of a `list_blank` is well defined. -/
def ListBlank.head {Γ} [Inhabited Γ] (l : ListBlank Γ) : Γ :=
  l.liftOn List.headI
    (by
      rintro _ _ ⟨i, rfl⟩
      cases a; · cases i <;> rfl; rfl)
#align turing.list_blank.head Turing.ListBlank.head
-/

#print Turing.ListBlank.head_mk /-
@[simp]
theorem ListBlank.head_mk {Γ} [Inhabited Γ] (l : List Γ) :
    ListBlank.head (ListBlank.mk l) = l.headI :=
  rfl
#align turing.list_blank.head_mk Turing.ListBlank.head_mk
-/

#print Turing.ListBlank.tail /-
/-- The tail of a `list_blank` is well defined (up to the tail of blanks). -/
def ListBlank.tail {Γ} [Inhabited Γ] (l : ListBlank Γ) : ListBlank Γ :=
  l.liftOn (fun l => ListBlank.mk l.tail)
    (by
      rintro _ _ ⟨i, rfl⟩
      refine' Quotient.sound' (Or.inl _)
      cases a <;> [· cases i <;> [exact ⟨0, rfl⟩, exact ⟨i, rfl⟩], exact ⟨i, rfl⟩])
#align turing.list_blank.tail Turing.ListBlank.tail
-/

#print Turing.ListBlank.tail_mk /-
@[simp]
theorem ListBlank.tail_mk {Γ} [Inhabited Γ] (l : List Γ) :
    ListBlank.tail (ListBlank.mk l) = ListBlank.mk l.tail :=
  rfl
#align turing.list_blank.tail_mk Turing.ListBlank.tail_mk
-/

#print Turing.ListBlank.cons /-
/-- We can cons an element onto a `list_blank`. -/
def ListBlank.cons {Γ} [Inhabited Γ] (a : Γ) (l : ListBlank Γ) : ListBlank Γ :=
  l.liftOn (fun l => ListBlank.mk (List.cons a l))
    (by
      rintro _ _ ⟨i, rfl⟩
      exact Quotient.sound' (Or.inl ⟨i, rfl⟩))
#align turing.list_blank.cons Turing.ListBlank.cons
-/

#print Turing.ListBlank.cons_mk /-
@[simp]
theorem ListBlank.cons_mk {Γ} [Inhabited Γ] (a : Γ) (l : List Γ) :
    ListBlank.cons a (ListBlank.mk l) = ListBlank.mk (a :: l) :=
  rfl
#align turing.list_blank.cons_mk Turing.ListBlank.cons_mk
-/

#print Turing.ListBlank.head_cons /-
@[simp]
theorem ListBlank.head_cons {Γ} [Inhabited Γ] (a : Γ) : ∀ l : ListBlank Γ, (l.cons a).headI = a :=
  Quotient.ind' fun l => rfl
#align turing.list_blank.head_cons Turing.ListBlank.head_cons
-/

#print Turing.ListBlank.tail_cons /-
@[simp]
theorem ListBlank.tail_cons {Γ} [Inhabited Γ] (a : Γ) : ∀ l : ListBlank Γ, (l.cons a).tail = l :=
  Quotient.ind' fun l => rfl
#align turing.list_blank.tail_cons Turing.ListBlank.tail_cons
-/

#print Turing.ListBlank.cons_head_tail /-
/-- The `cons` and `head`/`tail` functions are mutually inverse, unlike in the case of `list` where
this only holds for nonempty lists. -/
@[simp]
theorem ListBlank.cons_head_tail {Γ} [Inhabited Γ] : ∀ l : ListBlank Γ, l.tail.cons l.headI = l :=
  Quotient.ind'
    (by
      refine' fun l => Quotient.sound' (Or.inr _)
      cases l; · exact ⟨1, rfl⟩; · rfl)
#align turing.list_blank.cons_head_tail Turing.ListBlank.cons_head_tail
-/

#print Turing.ListBlank.exists_cons /-
/-- The `cons` and `head`/`tail` functions are mutually inverse, unlike in the case of `list` where
this only holds for nonempty lists. -/
theorem ListBlank.exists_cons {Γ} [Inhabited Γ] (l : ListBlank Γ) :
    ∃ a l', l = ListBlank.cons a l' :=
  ⟨_, _, (ListBlank.cons_head_tail _).symm⟩
#align turing.list_blank.exists_cons Turing.ListBlank.exists_cons
-/

#print Turing.ListBlank.nth /-
/-- The n-th element of a `list_blank` is well defined for all `n : ℕ`, unlike in a `list`. -/
def ListBlank.nth {Γ} [Inhabited Γ] (l : ListBlank Γ) (n : ℕ) : Γ :=
  l.liftOn (fun l => List.getI l n)
    (by
      rintro l _ ⟨i, rfl⟩
      simp only
      cases' lt_or_le _ _ with h h; · rw [List.getI_append _ _ _ h]
      rw [List.getI_eq_default _ h]
      cases' le_or_lt _ _ with h₂ h₂; · rw [List.getI_eq_default _ h₂]
      rw [List.getI_eq_nthLe _ h₂, List.nthLe_append_right h, List.nthLe_replicate])
#align turing.list_blank.nth Turing.ListBlank.nth
-/

#print Turing.ListBlank.nth_mk /-
@[simp]
theorem ListBlank.nth_mk {Γ} [Inhabited Γ] (l : List Γ) (n : ℕ) :
    (ListBlank.mk l).get? n = l.getI n :=
  rfl
#align turing.list_blank.nth_mk Turing.ListBlank.nth_mk
-/

#print Turing.ListBlank.nth_zero /-
@[simp]
theorem ListBlank.nth_zero {Γ} [Inhabited Γ] (l : ListBlank Γ) : l.get? 0 = l.headI :=
  by
  conv =>
    lhs
    rw [← list_blank.cons_head_tail l]
  exact Quotient.inductionOn' l.tail fun l => rfl
#align turing.list_blank.nth_zero Turing.ListBlank.nth_zero
-/

#print Turing.ListBlank.nth_succ /-
@[simp]
theorem ListBlank.nth_succ {Γ} [Inhabited Γ] (l : ListBlank Γ) (n : ℕ) :
    l.get? (n + 1) = l.tail.get? n :=
  by
  conv =>
    lhs
    rw [← list_blank.cons_head_tail l]
  exact Quotient.inductionOn' l.tail fun l => rfl
#align turing.list_blank.nth_succ Turing.ListBlank.nth_succ
-/

#print Turing.ListBlank.ext /-
@[ext]
theorem ListBlank.ext {Γ} [Inhabited Γ] {L₁ L₂ : ListBlank Γ} :
    (∀ i, L₁.get? i = L₂.get? i) → L₁ = L₂ :=
  ListBlank.induction_on L₁ fun l₁ =>
    ListBlank.induction_on L₂ fun l₂ H =>
      by
      wlog h : l₁.length ≤ l₂.length
      · cases le_total l₁.length l₂.length <;> [skip, symm] <;> apply_assumption <;> try assumption
        intro
        rw [H]
      refine' Quotient.sound' (Or.inl ⟨l₂.length - l₁.length, _⟩)
      refine' List.ext_nthLe _ fun i h h₂ => Eq.symm _
      · simp only [add_tsub_cancel_of_le h, List.length_append, List.length_replicate]
      simp only [list_blank.nth_mk] at H
      cases' lt_or_le i l₁.length with h' h'
      ·
        simp only [List.nthLe_append _ h', List.nthLe_get? h, List.nthLe_get? h', ←
          List.getI_eq_nthLe _ h, ← List.getI_eq_nthLe _ h', H]
      ·
        simp only [List.nthLe_append_right h', List.nthLe_replicate, List.nthLe_get? h,
          List.get?_len_le h', ← List.getI_eq_default _ h', H, List.getI_eq_nthLe _ h]
#align turing.list_blank.ext Turing.ListBlank.ext
-/

#print Turing.ListBlank.modifyNth /-
/-- Apply a function to a value stored at the nth position of the list. -/
@[simp]
def ListBlank.modifyNth {Γ} [Inhabited Γ] (f : Γ → Γ) : ℕ → ListBlank Γ → ListBlank Γ
  | 0, L => L.tail.cons (f L.headI)
  | n + 1, L => (L.tail.modifyNth n).cons L.headI
#align turing.list_blank.modify_nth Turing.ListBlank.modifyNth
-/

/- warning: turing.list_blank.nth_modify_nth -> Turing.ListBlank.nth_modifyNth is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] (f : Γ -> Γ) (n : Nat) (i : Nat) (L : Turing.ListBlank.{u1} Γ _inst_1), Eq.{succ u1} Γ (Turing.ListBlank.nth.{u1} Γ _inst_1 (Turing.ListBlank.modifyNth.{u1} Γ _inst_1 f n L) i) (ite.{succ u1} Γ (Eq.{1} Nat i n) (Nat.decidableEq i n) (f (Turing.ListBlank.nth.{u1} Γ _inst_1 L i)) (Turing.ListBlank.nth.{u1} Γ _inst_1 L i))
but is expected to have type
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] (f : Γ -> Γ) (n : Nat) (i : Nat) (L : Turing.ListBlank.{u1} Γ _inst_1), Eq.{succ u1} Γ (Turing.ListBlank.nth.{u1} Γ _inst_1 (Turing.ListBlank.modifyNth.{u1} Γ _inst_1 f n L) i) (ite.{succ u1} Γ (Eq.{1} Nat i n) (instDecidableEqNat i n) (f (Turing.ListBlank.nth.{u1} Γ _inst_1 L i)) (Turing.ListBlank.nth.{u1} Γ _inst_1 L i))
Case conversion may be inaccurate. Consider using '#align turing.list_blank.nth_modify_nth Turing.ListBlank.nth_modifyNthₓ'. -/
theorem ListBlank.nth_modifyNth {Γ} [Inhabited Γ] (f : Γ → Γ) (n i) (L : ListBlank Γ) :
    (L.modifyNth f n).get? i = if i = n then f (L.get? i) else L.get? i :=
  by
  induction' n with n IH generalizing i L
  ·
    cases i <;>
      simp only [list_blank.nth_zero, if_true, list_blank.head_cons, list_blank.modify_nth,
        eq_self_iff_true, list_blank.nth_succ, if_false, list_blank.tail_cons]
  · cases i
    · rw [if_neg (Nat.succ_ne_zero _).symm]
      simp only [list_blank.nth_zero, list_blank.head_cons, list_blank.modify_nth]
    · simp only [IH, list_blank.modify_nth, list_blank.nth_succ, list_blank.tail_cons]
#align turing.list_blank.nth_modify_nth Turing.ListBlank.nth_modifyNth

#print Turing.PointedMap /-
/-- A pointed map of `inhabited` types is a map that sends one default value to the other. -/
structure PointedMap.{u, v} (Γ : Type u) (Γ' : Type v) [Inhabited Γ] [Inhabited Γ'] :
  Type max u v where
  f : Γ → Γ'
  map_pt' : f default = default
#align turing.pointed_map Turing.PointedMap
-/

instance {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] : Inhabited (PointedMap Γ Γ') :=
  ⟨⟨default, rfl⟩⟩

instance {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] : CoeFun (PointedMap Γ Γ') fun _ => Γ → Γ' :=
  ⟨PointedMap.f⟩

/- warning: turing.pointed_map.mk_val -> Turing.PointedMap.mk_val is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (f : Γ -> Γ') (pt : Eq.{succ u2} Γ' (f (Inhabited.default.{succ u1} Γ _inst_1)) (Inhabited.default.{succ u2} Γ' _inst_2)), Eq.{max (succ u1) (succ u2)} ((fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.mk.{u1, u2} Γ Γ' _inst_1 _inst_2 f pt)) (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) (Turing.PointedMap.mk.{u1, u2} Γ Γ' _inst_1 _inst_2 f pt)) f
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (f : Γ -> Γ') (pt : Eq.{succ u1} Γ' (f (Inhabited.default.{succ u2} Γ _inst_1)) (Inhabited.default.{succ u1} Γ' _inst_2)), Eq.{max (succ u1) (succ u2)} (Γ -> Γ') (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 (Turing.PointedMap.mk.{u2, u1} Γ Γ' _inst_1 _inst_2 f pt)) f
Case conversion may be inaccurate. Consider using '#align turing.pointed_map.mk_val Turing.PointedMap.mk_valₓ'. -/
@[simp]
theorem PointedMap.mk_val {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : Γ → Γ') (pt) :
    (PointedMap.mk f pt : Γ → Γ') = f :=
  rfl
#align turing.pointed_map.mk_val Turing.PointedMap.mk_val

/- warning: turing.pointed_map.map_pt -> Turing.PointedMap.map_pt is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (f : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2), Eq.{succ u2} Γ' (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) f (Inhabited.default.{succ u1} Γ _inst_1)) (Inhabited.default.{succ u2} Γ' _inst_2)
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (f : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2), Eq.{succ u1} Γ' (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 f (Inhabited.default.{succ u2} Γ _inst_1)) (Inhabited.default.{succ u1} Γ' _inst_2)
Case conversion may be inaccurate. Consider using '#align turing.pointed_map.map_pt Turing.PointedMap.map_ptₓ'. -/
@[simp]
theorem PointedMap.map_pt {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : PointedMap Γ Γ') :
    f default = default :=
  PointedMap.map_pt' _
#align turing.pointed_map.map_pt Turing.PointedMap.map_pt

/- warning: turing.pointed_map.head_map -> Turing.PointedMap.headI_map is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (f : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (l : List.{u1} Γ), Eq.{succ u2} Γ' (List.headI.{u2} Γ' _inst_2 (List.map.{u1, u2} Γ Γ' (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) f) l)) (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) f (List.headI.{u1} Γ _inst_1 l))
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (f : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2) (l : List.{u2} Γ), Eq.{succ u1} Γ' (List.headI.{u1} Γ' _inst_2 (List.map.{u2, u1} Γ Γ' (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 f) l)) (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 f (List.headI.{u2} Γ _inst_1 l))
Case conversion may be inaccurate. Consider using '#align turing.pointed_map.head_map Turing.PointedMap.headI_mapₓ'. -/
@[simp]
theorem PointedMap.headI_map {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : PointedMap Γ Γ')
    (l : List Γ) : (l.map f).headI = f l.headI := by
  cases l <;> [exact (pointed_map.map_pt f).symm, rfl]
#align turing.pointed_map.head_map Turing.PointedMap.headI_map

#print Turing.ListBlank.map /-
/-- The `map` function on lists is well defined on `list_blank`s provided that the map is
pointed. -/
def ListBlank.map {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : PointedMap Γ Γ') (l : ListBlank Γ) :
    ListBlank Γ' :=
  l.liftOn (fun l => ListBlank.mk (List.map f l))
    (by
      rintro l _ ⟨i, rfl⟩; refine' Quotient.sound' (Or.inl ⟨i, _⟩)
      simp only [pointed_map.map_pt, List.map_append, List.map_replicate])
#align turing.list_blank.map Turing.ListBlank.map
-/

/- warning: turing.list_blank.map_mk -> Turing.ListBlank.map_mk is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (f : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (l : List.{u1} Γ), Eq.{succ u2} (Turing.ListBlank.{u2} Γ' _inst_2) (Turing.ListBlank.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f (Turing.ListBlank.mk.{u1} Γ _inst_1 l)) (Turing.ListBlank.mk.{u2} Γ' _inst_2 (List.map.{u1, u2} Γ Γ' (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) f) l))
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (f : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2) (l : List.{u2} Γ), Eq.{succ u1} (Turing.ListBlank.{u1} Γ' _inst_2) (Turing.ListBlank.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f (Turing.ListBlank.mk.{u2} Γ _inst_1 l)) (Turing.ListBlank.mk.{u1} Γ' _inst_2 (List.map.{u2, u1} Γ Γ' (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 f) l))
Case conversion may be inaccurate. Consider using '#align turing.list_blank.map_mk Turing.ListBlank.map_mkₓ'. -/
@[simp]
theorem ListBlank.map_mk {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : PointedMap Γ Γ') (l : List Γ) :
    (ListBlank.mk l).map f = ListBlank.mk (l.map f) :=
  rfl
#align turing.list_blank.map_mk Turing.ListBlank.map_mk

/- warning: turing.list_blank.head_map -> Turing.ListBlank.head_map is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (f : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (l : Turing.ListBlank.{u1} Γ _inst_1), Eq.{succ u2} Γ' (Turing.ListBlank.head.{u2} Γ' _inst_2 (Turing.ListBlank.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f l)) (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) f (Turing.ListBlank.head.{u1} Γ _inst_1 l))
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (f : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2) (l : Turing.ListBlank.{u2} Γ _inst_1), Eq.{succ u1} Γ' (Turing.ListBlank.head.{u1} Γ' _inst_2 (Turing.ListBlank.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f l)) (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 f (Turing.ListBlank.head.{u2} Γ _inst_1 l))
Case conversion may be inaccurate. Consider using '#align turing.list_blank.head_map Turing.ListBlank.head_mapₓ'. -/
@[simp]
theorem ListBlank.head_map {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : PointedMap Γ Γ')
    (l : ListBlank Γ) : (l.map f).headI = f l.headI :=
  by
  conv =>
    lhs
    rw [← list_blank.cons_head_tail l]
  exact Quotient.inductionOn' l fun a => rfl
#align turing.list_blank.head_map Turing.ListBlank.head_map

/- warning: turing.list_blank.tail_map -> Turing.ListBlank.tail_map is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (f : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (l : Turing.ListBlank.{u1} Γ _inst_1), Eq.{succ u2} (Turing.ListBlank.{u2} Γ' _inst_2) (Turing.ListBlank.tail.{u2} Γ' _inst_2 (Turing.ListBlank.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f l)) (Turing.ListBlank.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f (Turing.ListBlank.tail.{u1} Γ _inst_1 l))
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (f : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2) (l : Turing.ListBlank.{u2} Γ _inst_1), Eq.{succ u1} (Turing.ListBlank.{u1} Γ' _inst_2) (Turing.ListBlank.tail.{u1} Γ' _inst_2 (Turing.ListBlank.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f l)) (Turing.ListBlank.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f (Turing.ListBlank.tail.{u2} Γ _inst_1 l))
Case conversion may be inaccurate. Consider using '#align turing.list_blank.tail_map Turing.ListBlank.tail_mapₓ'. -/
@[simp]
theorem ListBlank.tail_map {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : PointedMap Γ Γ')
    (l : ListBlank Γ) : (l.map f).tail = l.tail.map f :=
  by
  conv =>
    lhs
    rw [← list_blank.cons_head_tail l]
  exact Quotient.inductionOn' l fun a => rfl
#align turing.list_blank.tail_map Turing.ListBlank.tail_map

/- warning: turing.list_blank.map_cons -> Turing.ListBlank.map_cons is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (f : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (l : Turing.ListBlank.{u1} Γ _inst_1) (a : Γ), Eq.{succ u2} (Turing.ListBlank.{u2} Γ' _inst_2) (Turing.ListBlank.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f (Turing.ListBlank.cons.{u1} Γ _inst_1 a l)) (Turing.ListBlank.cons.{u2} Γ' _inst_2 (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) f a) (Turing.ListBlank.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f l))
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (f : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2) (l : Turing.ListBlank.{u2} Γ _inst_1) (a : Γ), Eq.{succ u1} (Turing.ListBlank.{u1} Γ' _inst_2) (Turing.ListBlank.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f (Turing.ListBlank.cons.{u2} Γ _inst_1 a l)) (Turing.ListBlank.cons.{u1} Γ' _inst_2 (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 f a) (Turing.ListBlank.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f l))
Case conversion may be inaccurate. Consider using '#align turing.list_blank.map_cons Turing.ListBlank.map_consₓ'. -/
@[simp]
theorem ListBlank.map_cons {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : PointedMap Γ Γ')
    (l : ListBlank Γ) (a : Γ) : (l.cons a).map f = (l.map f).cons (f a) :=
  by
  refine' (list_blank.cons_head_tail _).symm.trans _
  simp only [list_blank.head_map, list_blank.head_cons, list_blank.tail_map, list_blank.tail_cons]
#align turing.list_blank.map_cons Turing.ListBlank.map_cons

/- warning: turing.list_blank.nth_map -> Turing.ListBlank.nth_map is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (f : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (l : Turing.ListBlank.{u1} Γ _inst_1) (n : Nat), Eq.{succ u2} Γ' (Turing.ListBlank.nth.{u2} Γ' _inst_2 (Turing.ListBlank.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f l) n) (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) f (Turing.ListBlank.nth.{u1} Γ _inst_1 l n))
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (f : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2) (l : Turing.ListBlank.{u2} Γ _inst_1) (n : Nat), Eq.{succ u1} Γ' (Turing.ListBlank.nth.{u1} Γ' _inst_2 (Turing.ListBlank.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f l) n) (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 f (Turing.ListBlank.nth.{u2} Γ _inst_1 l n))
Case conversion may be inaccurate. Consider using '#align turing.list_blank.nth_map Turing.ListBlank.nth_mapₓ'. -/
@[simp]
theorem ListBlank.nth_map {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : PointedMap Γ Γ')
    (l : ListBlank Γ) (n : ℕ) : (l.map f).get? n = f (l.get? n) :=
  l.inductionOn
    (by
      intro l;
      simp only [List.get?_map, list_blank.map_mk, list_blank.nth_mk, List.getI_eq_iget_get?]
      cases l.nth n; · exact f.2.symm; · rfl)
#align turing.list_blank.nth_map Turing.ListBlank.nth_map

#print Turing.proj /-
/-- The `i`-th projection as a pointed map. -/
def proj {ι : Type _} {Γ : ι → Type _} [∀ i, Inhabited (Γ i)] (i : ι) :
    PointedMap (∀ i, Γ i) (Γ i) :=
  ⟨fun a => a i, rfl⟩
#align turing.proj Turing.proj
-/

/- warning: turing.proj_map_nth -> Turing.proj_map_nth is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {Γ : ι -> Type.{u2}} [_inst_1 : forall (i : ι), Inhabited.{succ u2} (Γ i)] (i : ι) (L : Turing.ListBlank.{max u1 u2} (forall (i : ι), Γ i) (Pi.inhabited.{succ u1, succ u2} ι (fun (i : ι) => Γ i) (fun (x : ι) => (fun (i : ι) => _inst_1 i) x))) (n : Nat), Eq.{succ u2} (Γ i) (Turing.ListBlank.nth.{u2} (Γ i) ((fun (i : ι) => _inst_1 i) i) (Turing.ListBlank.map.{max u1 u2, u2} (forall (i : ι), Γ i) (Γ i) (Pi.inhabited.{succ u1, succ u2} ι (fun (i : ι) => Γ i) (fun (x : ι) => (fun (i : ι) => _inst_1 i) x)) ((fun (i : ι) => _inst_1 i) i) (Turing.proj.{u1, u2} ι Γ (fun (i : ι) => _inst_1 i) i) L) n) (Turing.ListBlank.nth.{max u1 u2} (forall (i : ι), Γ i) (Pi.inhabited.{succ u1, succ u2} ι (fun (i : ι) => Γ i) (fun (x : ι) => (fun (i : ι) => _inst_1 i) x)) L n i)
but is expected to have type
  forall {ι : Type.{u2}} {Γ : ι -> Type.{u1}} [_inst_1 : forall (i : ι), Inhabited.{succ u1} (Γ i)] (i : ι) (L : Turing.ListBlank.{max u2 u1} (forall (i : ι), Γ i) (instInhabitedForAll_1.{succ u2, succ u1} ι (fun (i : ι) => Γ i) (fun (x : ι) => _inst_1 x))) (n : Nat), Eq.{succ u1} (Γ i) (Turing.ListBlank.nth.{u1} (Γ i) (_inst_1 i) (Turing.ListBlank.map.{max u2 u1, u1} (forall (i : ι), Γ i) (Γ i) (instInhabitedForAll_1.{succ u2, succ u1} ι (fun (i : ι) => Γ i) (fun (x : ι) => _inst_1 x)) (_inst_1 i) (Turing.proj.{u2, u1} ι Γ (fun (i : ι) => _inst_1 i) i) L) n) (Turing.ListBlank.nth.{max u2 u1} (forall (i : ι), Γ i) (instInhabitedForAll_1.{succ u2, succ u1} ι (fun (i : ι) => Γ i) (fun (x : ι) => _inst_1 x)) L n i)
Case conversion may be inaccurate. Consider using '#align turing.proj_map_nth Turing.proj_map_nthₓ'. -/
theorem proj_map_nth {ι : Type _} {Γ : ι → Type _} [∀ i, Inhabited (Γ i)] (i : ι) (L n) :
    (ListBlank.map (@proj ι Γ _ i) L).get? n = L.get? n i := by rw [list_blank.nth_map] <;> rfl
#align turing.proj_map_nth Turing.proj_map_nth

/- warning: turing.list_blank.map_modify_nth -> Turing.ListBlank.map_modifyNth is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (F : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (f : Γ -> Γ) (f' : Γ' -> Γ'), (forall (x : Γ), Eq.{succ u2} Γ' (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) F (f x)) (f' (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) F x))) -> (forall (n : Nat) (L : Turing.ListBlank.{u1} Γ _inst_1), Eq.{succ u2} (Turing.ListBlank.{u2} Γ' _inst_2) (Turing.ListBlank.map.{u1, u2} Γ Γ' _inst_1 _inst_2 F (Turing.ListBlank.modifyNth.{u1} Γ _inst_1 f n L)) (Turing.ListBlank.modifyNth.{u2} Γ' _inst_2 f' n (Turing.ListBlank.map.{u1, u2} Γ Γ' _inst_1 _inst_2 F L)))
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (F : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2) (f : Γ -> Γ) (f' : Γ' -> Γ'), (forall (x : Γ), Eq.{succ u1} Γ' (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 F (f x)) (f' (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 F x))) -> (forall (n : Nat) (L : Turing.ListBlank.{u2} Γ _inst_1), Eq.{succ u1} (Turing.ListBlank.{u1} Γ' _inst_2) (Turing.ListBlank.map.{u2, u1} Γ Γ' _inst_1 _inst_2 F (Turing.ListBlank.modifyNth.{u2} Γ _inst_1 f n L)) (Turing.ListBlank.modifyNth.{u1} Γ' _inst_2 f' n (Turing.ListBlank.map.{u2, u1} Γ Γ' _inst_1 _inst_2 F L)))
Case conversion may be inaccurate. Consider using '#align turing.list_blank.map_modify_nth Turing.ListBlank.map_modifyNthₓ'. -/
theorem ListBlank.map_modifyNth {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (F : PointedMap Γ Γ')
    (f : Γ → Γ) (f' : Γ' → Γ') (H : ∀ x, F (f x) = f' (F x)) (n) (L : ListBlank Γ) :
    (L.modifyNth f n).map F = (L.map F).modifyNth f' n := by
  induction' n with n IH generalizing L <;>
    simp only [*, list_blank.head_map, list_blank.modify_nth, list_blank.map_cons,
      list_blank.tail_map]
#align turing.list_blank.map_modify_nth Turing.ListBlank.map_modifyNth

#print Turing.ListBlank.append /-
/-- Append a list on the left side of a list_blank. -/
@[simp]
def ListBlank.append {Γ} [Inhabited Γ] : List Γ → ListBlank Γ → ListBlank Γ
  | [], L => L
  | a :: l, L => ListBlank.cons a (list_blank.append l L)
#align turing.list_blank.append Turing.ListBlank.append
-/

#print Turing.ListBlank.append_mk /-
@[simp]
theorem ListBlank.append_mk {Γ} [Inhabited Γ] (l₁ l₂ : List Γ) :
    ListBlank.append l₁ (ListBlank.mk l₂) = ListBlank.mk (l₁ ++ l₂) := by
  induction l₁ <;>
    simp only [*, list_blank.append, List.nil_append, List.cons_append, list_blank.cons_mk]
#align turing.list_blank.append_mk Turing.ListBlank.append_mk
-/

#print Turing.ListBlank.append_assoc /-
theorem ListBlank.append_assoc {Γ} [Inhabited Γ] (l₁ l₂ : List Γ) (l₃ : ListBlank Γ) :
    ListBlank.append (l₁ ++ l₂) l₃ = ListBlank.append l₁ (ListBlank.append l₂ l₃) :=
  l₃.inductionOn <| by intro <;> simp only [list_blank.append_mk, List.append_assoc]
#align turing.list_blank.append_assoc Turing.ListBlank.append_assoc
-/

#print Turing.ListBlank.bind /-
/-- The `bind` function on lists is well defined on `list_blank`s provided that the default element
is sent to a sequence of default elements. -/
def ListBlank.bind {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (l : ListBlank Γ) (f : Γ → List Γ')
    (hf : ∃ n, f default = List.replicate n default) : ListBlank Γ' :=
  l.liftOn (fun l => ListBlank.mk (List.bind l f))
    (by
      rintro l _ ⟨i, rfl⟩; cases' hf with n e; refine' Quotient.sound' (Or.inl ⟨i * n, _⟩)
      rw [List.bind_append, mul_comm]; congr
      induction' i with i IH; rfl
      simp only [IH, e, List.replicate_add, Nat.mul_succ, add_comm, List.replicate_succ,
        List.cons_bind])
#align turing.list_blank.bind Turing.ListBlank.bind
-/

/- warning: turing.list_blank.bind_mk -> Turing.ListBlank.bind_mk is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (l : List.{u1} Γ) (f : Γ -> (List.{u2} Γ')) (hf : Exists.{1} Nat (fun (n : Nat) => Eq.{succ u2} (List.{u2} Γ') (f (Inhabited.default.{succ u1} Γ _inst_1)) (List.replicate.{u2} Γ' n (Inhabited.default.{succ u2} Γ' _inst_2)))), Eq.{succ u2} (Turing.ListBlank.{u2} Γ' _inst_2) (Turing.ListBlank.bind.{u1, u2} Γ Γ' _inst_1 _inst_2 (Turing.ListBlank.mk.{u1} Γ _inst_1 l) f hf) (Turing.ListBlank.mk.{u2} Γ' _inst_2 (List.bind.{u1, u2} Γ Γ' l f))
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (l : List.{u2} Γ) (f : Γ -> (List.{u1} Γ')) (hf : Exists.{1} Nat (fun (n : Nat) => Eq.{succ u1} (List.{u1} Γ') (f (Inhabited.default.{succ u2} Γ _inst_1)) (List.replicate.{u1} Γ' n (Inhabited.default.{succ u1} Γ' _inst_2)))), Eq.{succ u1} (Turing.ListBlank.{u1} Γ' _inst_2) (Turing.ListBlank.bind.{u2, u1} Γ Γ' _inst_1 _inst_2 (Turing.ListBlank.mk.{u2} Γ _inst_1 l) f hf) (Turing.ListBlank.mk.{u1} Γ' _inst_2 (List.bind.{u2, u1} Γ Γ' l f))
Case conversion may be inaccurate. Consider using '#align turing.list_blank.bind_mk Turing.ListBlank.bind_mkₓ'. -/
@[simp]
theorem ListBlank.bind_mk {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (l : List Γ) (f : Γ → List Γ') (hf) :
    (ListBlank.mk l).bind f hf = ListBlank.mk (l.bind f) :=
  rfl
#align turing.list_blank.bind_mk Turing.ListBlank.bind_mk

/- warning: turing.list_blank.cons_bind -> Turing.ListBlank.cons_bind is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (a : Γ) (l : Turing.ListBlank.{u1} Γ _inst_1) (f : Γ -> (List.{u2} Γ')) (hf : Exists.{1} Nat (fun (n : Nat) => Eq.{succ u2} (List.{u2} Γ') (f (Inhabited.default.{succ u1} Γ _inst_1)) (List.replicate.{u2} Γ' n (Inhabited.default.{succ u2} Γ' _inst_2)))), Eq.{succ u2} (Turing.ListBlank.{u2} Γ' _inst_2) (Turing.ListBlank.bind.{u1, u2} Γ Γ' _inst_1 _inst_2 (Turing.ListBlank.cons.{u1} Γ _inst_1 a l) f hf) (Turing.ListBlank.append.{u2} Γ' _inst_2 (f a) (Turing.ListBlank.bind.{u1, u2} Γ Γ' _inst_1 _inst_2 l f hf))
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (a : Γ) (l : Turing.ListBlank.{u2} Γ _inst_1) (f : Γ -> (List.{u1} Γ')) (hf : Exists.{1} Nat (fun (n : Nat) => Eq.{succ u1} (List.{u1} Γ') (f (Inhabited.default.{succ u2} Γ _inst_1)) (List.replicate.{u1} Γ' n (Inhabited.default.{succ u1} Γ' _inst_2)))), Eq.{succ u1} (Turing.ListBlank.{u1} Γ' _inst_2) (Turing.ListBlank.bind.{u2, u1} Γ Γ' _inst_1 _inst_2 (Turing.ListBlank.cons.{u2} Γ _inst_1 a l) f hf) (Turing.ListBlank.append.{u1} Γ' _inst_2 (f a) (Turing.ListBlank.bind.{u2, u1} Γ Γ' _inst_1 _inst_2 l f hf))
Case conversion may be inaccurate. Consider using '#align turing.list_blank.cons_bind Turing.ListBlank.cons_bindₓ'. -/
@[simp]
theorem ListBlank.cons_bind {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (a : Γ) (l : ListBlank Γ)
    (f : Γ → List Γ') (hf) : (l.cons a).bind f hf = (l.bind f hf).append (f a) :=
  l.inductionOn <| by
    intro <;>
      simp only [list_blank.append_mk, list_blank.bind_mk, list_blank.cons_mk, List.cons_bind]
#align turing.list_blank.cons_bind Turing.ListBlank.cons_bind

#print Turing.Tape /-
/-- The tape of a Turing machine is composed of a head element (which we imagine to be the
current position of the head), together with two `list_blank`s denoting the portions of the tape
going off to the left and right. When the Turing machine moves right, an element is pulled from the
right side and becomes the new head, while the head element is consed onto the left side. -/
structure Tape (Γ : Type _) [Inhabited Γ] where
  headI : Γ
  left : ListBlank Γ
  right : ListBlank Γ
#align turing.tape Turing.Tape
-/

#print Turing.Tape.inhabited /-
instance Tape.inhabited {Γ} [Inhabited Γ] : Inhabited (Tape Γ) :=
  ⟨by constructor <;> apply default⟩
#align turing.tape.inhabited Turing.Tape.inhabited
-/

#print Turing.Dir /-
/-- A direction for the turing machine `move` command, either
  left or right. -/
inductive Dir
  | left
  | right
  deriving DecidableEq, Inhabited
#align turing.dir Turing.Dir
-/

#print Turing.Tape.left₀ /-
/-- The "inclusive" left side of the tape, including both `left` and `head`. -/
def Tape.left₀ {Γ} [Inhabited Γ] (T : Tape Γ) : ListBlank Γ :=
  T.left.cons T.headI
#align turing.tape.left₀ Turing.Tape.left₀
-/

#print Turing.Tape.right₀ /-
/-- The "inclusive" right side of the tape, including both `right` and `head`. -/
def Tape.right₀ {Γ} [Inhabited Γ] (T : Tape Γ) : ListBlank Γ :=
  T.right.cons T.headI
#align turing.tape.right₀ Turing.Tape.right₀
-/

#print Turing.Tape.move /-
/-- Move the tape in response to a motion of the Turing machine. Note that `T.move dir.left` makes
`T.left` smaller; the Turing machine is moving left and the tape is moving right. -/
def Tape.move {Γ} [Inhabited Γ] : Dir → Tape Γ → Tape Γ
  | dir.left, ⟨a, L, R⟩ => ⟨L.headI, L.tail, R.cons a⟩
  | dir.right, ⟨a, L, R⟩ => ⟨R.headI, L.cons a, R.tail⟩
#align turing.tape.move Turing.Tape.move
-/

#print Turing.Tape.move_left_right /-
@[simp]
theorem Tape.move_left_right {Γ} [Inhabited Γ] (T : Tape Γ) :
    (T.move Dir.left).move Dir.right = T := by cases T <;> simp [tape.move]
#align turing.tape.move_left_right Turing.Tape.move_left_right
-/

#print Turing.Tape.move_right_left /-
@[simp]
theorem Tape.move_right_left {Γ} [Inhabited Γ] (T : Tape Γ) :
    (T.move Dir.right).move Dir.left = T := by cases T <;> simp [tape.move]
#align turing.tape.move_right_left Turing.Tape.move_right_left
-/

#print Turing.Tape.mk' /-
/-- Construct a tape from a left side and an inclusive right side. -/
def Tape.mk' {Γ} [Inhabited Γ] (L R : ListBlank Γ) : Tape Γ :=
  ⟨R.headI, L, R.tail⟩
#align turing.tape.mk' Turing.Tape.mk'
-/

#print Turing.Tape.mk'_left /-
@[simp]
theorem Tape.mk'_left {Γ} [Inhabited Γ] (L R : ListBlank Γ) : (Tape.mk' L R).left = L :=
  rfl
#align turing.tape.mk'_left Turing.Tape.mk'_left
-/

#print Turing.Tape.mk'_head /-
@[simp]
theorem Tape.mk'_head {Γ} [Inhabited Γ] (L R : ListBlank Γ) : (Tape.mk' L R).headI = R.headI :=
  rfl
#align turing.tape.mk'_head Turing.Tape.mk'_head
-/

#print Turing.Tape.mk'_right /-
@[simp]
theorem Tape.mk'_right {Γ} [Inhabited Γ] (L R : ListBlank Γ) : (Tape.mk' L R).right = R.tail :=
  rfl
#align turing.tape.mk'_right Turing.Tape.mk'_right
-/

#print Turing.Tape.mk'_right₀ /-
@[simp]
theorem Tape.mk'_right₀ {Γ} [Inhabited Γ] (L R : ListBlank Γ) : (Tape.mk' L R).right₀ = R :=
  ListBlank.cons_head_tail _
#align turing.tape.mk'_right₀ Turing.Tape.mk'_right₀
-/

#print Turing.Tape.mk'_left_right₀ /-
@[simp]
theorem Tape.mk'_left_right₀ {Γ} [Inhabited Γ] (T : Tape Γ) : Tape.mk' T.left T.right₀ = T := by
  cases T <;>
    simp only [tape.right₀, tape.mk', list_blank.head_cons, list_blank.tail_cons, eq_self_iff_true,
      and_self_iff]
#align turing.tape.mk'_left_right₀ Turing.Tape.mk'_left_right₀
-/

#print Turing.Tape.exists_mk' /-
theorem Tape.exists_mk' {Γ} [Inhabited Γ] (T : Tape Γ) : ∃ L R, T = Tape.mk' L R :=
  ⟨_, _, (Tape.mk'_left_right₀ _).symm⟩
#align turing.tape.exists_mk' Turing.Tape.exists_mk'
-/

#print Turing.Tape.move_left_mk' /-
@[simp]
theorem Tape.move_left_mk' {Γ} [Inhabited Γ] (L R : ListBlank Γ) :
    (Tape.mk' L R).move Dir.left = Tape.mk' L.tail (R.cons L.headI) := by
  simp only [tape.move, tape.mk', list_blank.head_cons, eq_self_iff_true, list_blank.cons_head_tail,
    and_self_iff, list_blank.tail_cons]
#align turing.tape.move_left_mk' Turing.Tape.move_left_mk'
-/

#print Turing.Tape.move_right_mk' /-
@[simp]
theorem Tape.move_right_mk' {Γ} [Inhabited Γ] (L R : ListBlank Γ) :
    (Tape.mk' L R).move Dir.right = Tape.mk' (L.cons R.headI) R.tail := by
  simp only [tape.move, tape.mk', list_blank.head_cons, eq_self_iff_true, list_blank.cons_head_tail,
    and_self_iff, list_blank.tail_cons]
#align turing.tape.move_right_mk' Turing.Tape.move_right_mk'
-/

#print Turing.Tape.mk₂ /-
/-- Construct a tape from a left side and an inclusive right side. -/
def Tape.mk₂ {Γ} [Inhabited Γ] (L R : List Γ) : Tape Γ :=
  Tape.mk' (ListBlank.mk L) (ListBlank.mk R)
#align turing.tape.mk₂ Turing.Tape.mk₂
-/

#print Turing.Tape.mk₁ /-
/-- Construct a tape from a list, with the head of the list at the TM head and the rest going
to the right. -/
def Tape.mk₁ {Γ} [Inhabited Γ] (l : List Γ) : Tape Γ :=
  Tape.mk₂ [] l
#align turing.tape.mk₁ Turing.Tape.mk₁
-/

#print Turing.Tape.nth /-
/-- The `nth` function of a tape is integer-valued, with index `0` being the head, negative indexes
on the left and positive indexes on the right. (Picture a number line.) -/
def Tape.nth {Γ} [Inhabited Γ] (T : Tape Γ) : ℤ → Γ
  | 0 => T.headI
  | (n + 1 : ℕ) => T.right.get? n
  | -[n+1] => T.left.get? n
#align turing.tape.nth Turing.Tape.nth
-/

#print Turing.Tape.nth_zero /-
@[simp]
theorem Tape.nth_zero {Γ} [Inhabited Γ] (T : Tape Γ) : T.get? 0 = T.1 :=
  rfl
#align turing.tape.nth_zero Turing.Tape.nth_zero
-/

#print Turing.Tape.right₀_nth /-
theorem Tape.right₀_nth {Γ} [Inhabited Γ] (T : Tape Γ) (n : ℕ) : T.right₀.get? n = T.get? n := by
  cases n <;>
    simp only [tape.nth, tape.right₀, Int.ofNat_zero, list_blank.nth_zero, list_blank.nth_succ,
      list_blank.head_cons, list_blank.tail_cons]
#align turing.tape.right₀_nth Turing.Tape.right₀_nth
-/

#print Turing.Tape.mk'_nth_nat /-
@[simp]
theorem Tape.mk'_nth_nat {Γ} [Inhabited Γ] (L R : ListBlank Γ) (n : ℕ) :
    (Tape.mk' L R).get? n = R.get? n := by rw [← tape.right₀_nth, tape.mk'_right₀]
#align turing.tape.mk'_nth_nat Turing.Tape.mk'_nth_nat
-/

#print Turing.Tape.move_left_nth /-
@[simp]
theorem Tape.move_left_nth {Γ} [Inhabited Γ] :
    ∀ (T : Tape Γ) (i : ℤ), (T.move Dir.left).get? i = T.get? (i - 1)
  | ⟨a, L, R⟩, -[n+1] => (ListBlank.nth_succ _ _).symm
  | ⟨a, L, R⟩, 0 => (ListBlank.nth_zero _).symm
  | ⟨a, L, R⟩, 1 => (ListBlank.nth_zero _).trans (ListBlank.head_cons _ _)
  | ⟨a, L, R⟩, (n + 1 : ℕ) + 1 => by
    rw [add_sub_cancel]
    change (R.cons a).get? (n + 1) = R.nth n
    rw [list_blank.nth_succ, list_blank.tail_cons]
#align turing.tape.move_left_nth Turing.Tape.move_left_nth
-/

#print Turing.Tape.move_right_nth /-
@[simp]
theorem Tape.move_right_nth {Γ} [Inhabited Γ] (T : Tape Γ) (i : ℤ) :
    (T.move Dir.right).get? i = T.get? (i + 1) := by
  conv =>
      rhs
      rw [← T.move_right_left] <;>
    rw [tape.move_left_nth, add_sub_cancel]
#align turing.tape.move_right_nth Turing.Tape.move_right_nth
-/

#print Turing.Tape.move_right_n_head /-
@[simp]
theorem Tape.move_right_n_head {Γ} [Inhabited Γ] (T : Tape Γ) (i : ℕ) :
    ((Tape.move Dir.right^[i]) T).headI = T.get? i := by
  induction i generalizing T <;> [rfl,
    simp only [*, tape.move_right_nth, Int.ofNat_succ, iterate_succ]]
#align turing.tape.move_right_n_head Turing.Tape.move_right_n_head
-/

#print Turing.Tape.write /-
/-- Replace the current value of the head on the tape. -/
def Tape.write {Γ} [Inhabited Γ] (b : Γ) (T : Tape Γ) : Tape Γ :=
  { T with headI := b }
#align turing.tape.write Turing.Tape.write
-/

#print Turing.Tape.write_self /-
@[simp]
theorem Tape.write_self {Γ} [Inhabited Γ] : ∀ T : Tape Γ, T.write T.1 = T := by rintro ⟨⟩ <;> rfl
#align turing.tape.write_self Turing.Tape.write_self
-/

/- warning: turing.tape.write_nth -> Turing.Tape.write_nth is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] (b : Γ) (T : Turing.Tape.{u1} Γ _inst_1) {i : Int}, Eq.{succ u1} Γ (Turing.Tape.nth.{u1} Γ _inst_1 (Turing.Tape.write.{u1} Γ _inst_1 b T) i) (ite.{succ u1} Γ (Eq.{1} Int i (OfNat.ofNat.{0} Int 0 (OfNat.mk.{0} Int 0 (Zero.zero.{0} Int Int.hasZero)))) (Int.decidableEq i (OfNat.ofNat.{0} Int 0 (OfNat.mk.{0} Int 0 (Zero.zero.{0} Int Int.hasZero)))) b (Turing.Tape.nth.{u1} Γ _inst_1 T i))
but is expected to have type
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] (b : Γ) (T : Turing.Tape.{u1} Γ _inst_1) {i : Int}, Eq.{succ u1} Γ (Turing.Tape.nth.{u1} Γ _inst_1 (Turing.Tape.write.{u1} Γ _inst_1 b T) i) (ite.{succ u1} Γ (Eq.{1} Int i (OfNat.ofNat.{0} Int 0 (instOfNatInt 0))) (Int.instDecidableEqInt i (OfNat.ofNat.{0} Int 0 (instOfNatInt 0))) b (Turing.Tape.nth.{u1} Γ _inst_1 T i))
Case conversion may be inaccurate. Consider using '#align turing.tape.write_nth Turing.Tape.write_nthₓ'. -/
@[simp]
theorem Tape.write_nth {Γ} [Inhabited Γ] (b : Γ) :
    ∀ (T : Tape Γ) {i : ℤ}, (T.write b).get? i = if i = 0 then b else T.get? i
  | ⟨a, L, R⟩, 0 => rfl
  | ⟨a, L, R⟩, (n + 1 : ℕ) => rfl
  | ⟨a, L, R⟩, -[n+1] => rfl
#align turing.tape.write_nth Turing.Tape.write_nth

#print Turing.Tape.write_mk' /-
@[simp]
theorem Tape.write_mk' {Γ} [Inhabited Γ] (a b : Γ) (L R : ListBlank Γ) :
    (Tape.mk' L (R.cons a)).write b = Tape.mk' L (R.cons b) := by
  simp only [tape.write, tape.mk', list_blank.head_cons, list_blank.tail_cons, eq_self_iff_true,
    and_self_iff]
#align turing.tape.write_mk' Turing.Tape.write_mk'
-/

#print Turing.Tape.map /-
/-- Apply a pointed map to a tape to change the alphabet. -/
def Tape.map {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : PointedMap Γ Γ') (T : Tape Γ) : Tape Γ' :=
  ⟨f T.1, T.2.map f, T.3.map f⟩
#align turing.tape.map Turing.Tape.map
-/

/- warning: turing.tape.map_fst -> Turing.Tape.map_fst is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (f : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (T : Turing.Tape.{u1} Γ _inst_1), Eq.{succ u2} Γ' (Turing.Tape.head.{u2} Γ' _inst_2 (Turing.Tape.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f T)) (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) f (Turing.Tape.head.{u1} Γ _inst_1 T))
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (f : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2) (T : Turing.Tape.{u2} Γ _inst_1), Eq.{succ u1} Γ' (Turing.Tape.head.{u1} Γ' _inst_2 (Turing.Tape.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f T)) (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 f (Turing.Tape.head.{u2} Γ _inst_1 T))
Case conversion may be inaccurate. Consider using '#align turing.tape.map_fst Turing.Tape.map_fstₓ'. -/
@[simp]
theorem Tape.map_fst {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : PointedMap Γ Γ') :
    ∀ T : Tape Γ, (T.map f).1 = f T.1 := by rintro ⟨⟩ <;> rfl
#align turing.tape.map_fst Turing.Tape.map_fst

/- warning: turing.tape.map_write -> Turing.Tape.map_write is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (f : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (b : Γ) (T : Turing.Tape.{u1} Γ _inst_1), Eq.{succ u2} (Turing.Tape.{u2} Γ' _inst_2) (Turing.Tape.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f (Turing.Tape.write.{u1} Γ _inst_1 b T)) (Turing.Tape.write.{u2} Γ' _inst_2 (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) f b) (Turing.Tape.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f T))
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (f : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2) (b : Γ) (T : Turing.Tape.{u2} Γ _inst_1), Eq.{succ u1} (Turing.Tape.{u1} Γ' _inst_2) (Turing.Tape.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f (Turing.Tape.write.{u2} Γ _inst_1 b T)) (Turing.Tape.write.{u1} Γ' _inst_2 (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 f b) (Turing.Tape.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f T))
Case conversion may be inaccurate. Consider using '#align turing.tape.map_write Turing.Tape.map_writeₓ'. -/
@[simp]
theorem Tape.map_write {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : PointedMap Γ Γ') (b : Γ) :
    ∀ T : Tape Γ, (T.write b).map f = (T.map f).write (f b) := by rintro ⟨⟩ <;> rfl
#align turing.tape.map_write Turing.Tape.map_write

#print Turing.Tape.write_move_right_n /-
@[simp]
theorem Tape.write_move_right_n {Γ} [Inhabited Γ] (f : Γ → Γ) (L R : ListBlank Γ) (n : ℕ) :
    ((Tape.move Dir.right^[n]) (Tape.mk' L R)).write (f (R.get? n)) =
      (Tape.move Dir.right^[n]) (Tape.mk' L (R.modifyNth f n)) :=
  by
  induction' n with n IH generalizing L R
  · simp only [list_blank.nth_zero, list_blank.modify_nth, iterate_zero_apply]
    rw [← tape.write_mk', list_blank.cons_head_tail]
  simp only [list_blank.head_cons, list_blank.nth_succ, list_blank.modify_nth, tape.move_right_mk',
    list_blank.tail_cons, iterate_succ_apply, IH]
#align turing.tape.write_move_right_n Turing.Tape.write_move_right_n
-/

/- warning: turing.tape.map_move -> Turing.Tape.map_move is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (f : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (T : Turing.Tape.{u1} Γ _inst_1) (d : Turing.Dir), Eq.{succ u2} (Turing.Tape.{u2} Γ' _inst_2) (Turing.Tape.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f (Turing.Tape.move.{u1} Γ _inst_1 d T)) (Turing.Tape.move.{u2} Γ' _inst_2 d (Turing.Tape.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f T))
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (f : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2) (T : Turing.Tape.{u2} Γ _inst_1) (d : Turing.Dir), Eq.{succ u1} (Turing.Tape.{u1} Γ' _inst_2) (Turing.Tape.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f (Turing.Tape.move.{u2} Γ _inst_1 d T)) (Turing.Tape.move.{u1} Γ' _inst_2 d (Turing.Tape.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f T))
Case conversion may be inaccurate. Consider using '#align turing.tape.map_move Turing.Tape.map_moveₓ'. -/
theorem Tape.map_move {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : PointedMap Γ Γ') (T : Tape Γ) (d) :
    (T.move d).map f = (T.map f).move d := by
  cases T <;> cases d <;>
    simp only [tape.move, tape.map, list_blank.head_map, eq_self_iff_true, list_blank.map_cons,
      and_self_iff, list_blank.tail_map]
#align turing.tape.map_move Turing.Tape.map_move

/- warning: turing.tape.map_mk' -> Turing.Tape.map_mk' is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (f : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (L : Turing.ListBlank.{u1} Γ _inst_1) (R : Turing.ListBlank.{u1} Γ _inst_1), Eq.{succ u2} (Turing.Tape.{u2} Γ' _inst_2) (Turing.Tape.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f (Turing.Tape.mk'.{u1} Γ _inst_1 L R)) (Turing.Tape.mk'.{u2} Γ' _inst_2 (Turing.ListBlank.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f L) (Turing.ListBlank.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f R))
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (f : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2) (L : Turing.ListBlank.{u2} Γ _inst_1) (R : Turing.ListBlank.{u2} Γ _inst_1), Eq.{succ u1} (Turing.Tape.{u1} Γ' _inst_2) (Turing.Tape.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f (Turing.Tape.mk'.{u2} Γ _inst_1 L R)) (Turing.Tape.mk'.{u1} Γ' _inst_2 (Turing.ListBlank.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f L) (Turing.ListBlank.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f R))
Case conversion may be inaccurate. Consider using '#align turing.tape.map_mk' Turing.Tape.map_mk'ₓ'. -/
theorem Tape.map_mk' {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : PointedMap Γ Γ') (L R : ListBlank Γ) :
    (Tape.mk' L R).map f = Tape.mk' (L.map f) (R.map f) := by
  simp only [tape.mk', tape.map, list_blank.head_map, eq_self_iff_true, and_self_iff,
    list_blank.tail_map]
#align turing.tape.map_mk' Turing.Tape.map_mk'

/- warning: turing.tape.map_mk₂ -> Turing.Tape.map_mk₂ is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (f : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (L : List.{u1} Γ) (R : List.{u1} Γ), Eq.{succ u2} (Turing.Tape.{u2} Γ' _inst_2) (Turing.Tape.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f (Turing.Tape.mk₂.{u1} Γ _inst_1 L R)) (Turing.Tape.mk₂.{u2} Γ' _inst_2 (List.map.{u1, u2} Γ Γ' (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) f) L) (List.map.{u1, u2} Γ Γ' (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) f) R))
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (f : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2) (L : List.{u2} Γ) (R : List.{u2} Γ), Eq.{succ u1} (Turing.Tape.{u1} Γ' _inst_2) (Turing.Tape.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f (Turing.Tape.mk₂.{u2} Γ _inst_1 L R)) (Turing.Tape.mk₂.{u1} Γ' _inst_2 (List.map.{u2, u1} Γ Γ' (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 f) L) (List.map.{u2, u1} Γ Γ' (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 f) R))
Case conversion may be inaccurate. Consider using '#align turing.tape.map_mk₂ Turing.Tape.map_mk₂ₓ'. -/
theorem Tape.map_mk₂ {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : PointedMap Γ Γ') (L R : List Γ) :
    (Tape.mk₂ L R).map f = Tape.mk₂ (L.map f) (R.map f) := by
  simp only [tape.mk₂, tape.map_mk', list_blank.map_mk]
#align turing.tape.map_mk₂ Turing.Tape.map_mk₂

/- warning: turing.tape.map_mk₁ -> Turing.Tape.map_mk₁ is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} {Γ' : Type.{u2}} [_inst_1 : Inhabited.{succ u1} Γ] [_inst_2 : Inhabited.{succ u2} Γ'] (f : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (l : List.{u1} Γ), Eq.{succ u2} (Turing.Tape.{u2} Γ' _inst_2) (Turing.Tape.map.{u1, u2} Γ Γ' _inst_1 _inst_2 f (Turing.Tape.mk₁.{u1} Γ _inst_1 l)) (Turing.Tape.mk₁.{u2} Γ' _inst_2 (List.map.{u1, u2} Γ Γ' (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) f) l))
but is expected to have type
  forall {Γ : Type.{u2}} {Γ' : Type.{u1}} [_inst_1 : Inhabited.{succ u2} Γ] [_inst_2 : Inhabited.{succ u1} Γ'] (f : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2) (l : List.{u2} Γ), Eq.{succ u1} (Turing.Tape.{u1} Γ' _inst_2) (Turing.Tape.map.{u2, u1} Γ Γ' _inst_1 _inst_2 f (Turing.Tape.mk₁.{u2} Γ _inst_1 l)) (Turing.Tape.mk₁.{u1} Γ' _inst_2 (List.map.{u2, u1} Γ Γ' (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 f) l))
Case conversion may be inaccurate. Consider using '#align turing.tape.map_mk₁ Turing.Tape.map_mk₁ₓ'. -/
theorem Tape.map_mk₁ {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : PointedMap Γ Γ') (l : List Γ) :
    (Tape.mk₁ l).map f = Tape.mk₁ (l.map f) :=
  Tape.map_mk₂ _ _ _
#align turing.tape.map_mk₁ Turing.Tape.map_mk₁

#print Turing.eval /-
/-- Run a state transition function `σ → option σ` "to completion". The return value is the last
state returned before a `none` result. If the state transition function always returns `some`,
then the computation diverges, returning `part.none`. -/
def eval {σ} (f : σ → Option σ) : σ → Part σ :=
  PFun.fix fun s => Part.some <| (f s).elim (Sum.inl s) Sum.inr
#align turing.eval Turing.eval
-/

#print Turing.Reaches /-
/-- The reflexive transitive closure of a state transition function. `reaches f a b` means
there is a finite sequence of steps `f a = some a₁`, `f a₁ = some a₂`, ... such that `aₙ = b`.
This relation permits zero steps of the state transition function. -/
def Reaches {σ} (f : σ → Option σ) : σ → σ → Prop :=
  ReflTransGen fun a b => b ∈ f a
#align turing.reaches Turing.Reaches
-/

#print Turing.Reaches₁ /-
/-- The transitive closure of a state transition function. `reaches₁ f a b` means there is a
nonempty finite sequence of steps `f a = some a₁`, `f a₁ = some a₂`, ... such that `aₙ = b`.
This relation does not permit zero steps of the state transition function. -/
def Reaches₁ {σ} (f : σ → Option σ) : σ → σ → Prop :=
  TransGen fun a b => b ∈ f a
#align turing.reaches₁ Turing.Reaches₁
-/

#print Turing.reaches₁_eq /-
theorem reaches₁_eq {σ} {f : σ → Option σ} {a b c} (h : f a = f b) :
    Reaches₁ f a c ↔ Reaches₁ f b c :=
  TransGen.head'_iff.trans (TransGen.head'_iff.trans <| by rw [h]).symm
#align turing.reaches₁_eq Turing.reaches₁_eq
-/

#print Turing.reaches_total /-
theorem reaches_total {σ} {f : σ → Option σ} {a b c} (hab : Reaches f a b) (hac : Reaches f a c) :
    Reaches f b c ∨ Reaches f c b :=
  ReflTransGen.total_of_right_unique (fun _ _ _ => Option.mem_unique) hab hac
#align turing.reaches_total Turing.reaches_total
-/

#print Turing.reaches₁_fwd /-
theorem reaches₁_fwd {σ} {f : σ → Option σ} {a b c} (h₁ : Reaches₁ f a c) (h₂ : b ∈ f a) :
    Reaches f b c := by
  rcases trans_gen.head'_iff.1 h₁ with ⟨b', hab, hbc⟩
  cases Option.mem_unique hab h₂; exact hbc
#align turing.reaches₁_fwd Turing.reaches₁_fwd
-/

#print Turing.Reaches₀ /-
/-- A variation on `reaches`. `reaches₀ f a b` holds if whenever `reaches₁ f b c` then
`reaches₁ f a c`. This is a weaker property than `reaches` and is useful for replacing states with
equivalent states without taking a step. -/
def Reaches₀ {σ} (f : σ → Option σ) (a b : σ) : Prop :=
  ∀ c, Reaches₁ f b c → Reaches₁ f a c
#align turing.reaches₀ Turing.Reaches₀
-/

#print Turing.Reaches₀.trans /-
theorem Reaches₀.trans {σ} {f : σ → Option σ} {a b c : σ} (h₁ : Reaches₀ f a b)
    (h₂ : Reaches₀ f b c) : Reaches₀ f a c
  | d, h₃ => h₁ _ (h₂ _ h₃)
#align turing.reaches₀.trans Turing.Reaches₀.trans
-/

#print Turing.Reaches₀.refl /-
@[refl]
theorem Reaches₀.refl {σ} {f : σ → Option σ} (a : σ) : Reaches₀ f a a
  | b, h => h
#align turing.reaches₀.refl Turing.Reaches₀.refl
-/

#print Turing.Reaches₀.single /-
theorem Reaches₀.single {σ} {f : σ → Option σ} {a b : σ} (h : b ∈ f a) : Reaches₀ f a b
  | c, h₂ => h₂.headI h
#align turing.reaches₀.single Turing.Reaches₀.single
-/

#print Turing.Reaches₀.head /-
theorem Reaches₀.head {σ} {f : σ → Option σ} {a b c : σ} (h : b ∈ f a) (h₂ : Reaches₀ f b c) :
    Reaches₀ f a c :=
  (Reaches₀.single h).trans h₂
#align turing.reaches₀.head Turing.Reaches₀.head
-/

#print Turing.Reaches₀.tail /-
theorem Reaches₀.tail {σ} {f : σ → Option σ} {a b c : σ} (h₁ : Reaches₀ f a b) (h : c ∈ f b) :
    Reaches₀ f a c :=
  h₁.trans (Reaches₀.single h)
#align turing.reaches₀.tail Turing.Reaches₀.tail
-/

#print Turing.reaches₀_eq /-
theorem reaches₀_eq {σ} {f : σ → Option σ} {a b} (e : f a = f b) : Reaches₀ f a b
  | d, h => (reaches₁_eq e).2 h
#align turing.reaches₀_eq Turing.reaches₀_eq
-/

#print Turing.Reaches₁.to₀ /-
theorem Reaches₁.to₀ {σ} {f : σ → Option σ} {a b : σ} (h : Reaches₁ f a b) : Reaches₀ f a b
  | c, h₂ => h.trans h₂
#align turing.reaches₁.to₀ Turing.Reaches₁.to₀
-/

#print Turing.Reaches.to₀ /-
theorem Reaches.to₀ {σ} {f : σ → Option σ} {a b : σ} (h : Reaches f a b) : Reaches₀ f a b
  | c, h₂ => h₂.trans_right h
#align turing.reaches.to₀ Turing.Reaches.to₀
-/

#print Turing.Reaches₀.tail' /-
theorem Reaches₀.tail' {σ} {f : σ → Option σ} {a b c : σ} (h : Reaches₀ f a b) (h₂ : c ∈ f b) :
    Reaches₁ f a c :=
  h _ (TransGen.single h₂)
#align turing.reaches₀.tail' Turing.Reaches₀.tail'
-/

#print Turing.evalInduction /-
/-- (co-)Induction principle for `eval`. If a property `C` holds of any point `a` evaluating to `b`
which is either terminal (meaning `a = b`) or where the next point also satisfies `C`, then it
holds of any point where `eval f a` evaluates to `b`. This formalizes the notion that if
`eval f a` evaluates to `b` then it reaches terminal state `b` in finitely many steps. -/
@[elab_as_elim]
def evalInduction {σ} {f : σ → Option σ} {b : σ} {C : σ → Sort _} {a : σ} (h : b ∈ eval f a)
    (H : ∀ a, b ∈ eval f a → (∀ a', f a = some a' → C a') → C a) : C a :=
  PFun.fixInduction h fun a' ha' h' =>
    H _ ha' fun b' e => h' _ <| Part.mem_some_iff.2 <| by rw [e] <;> rfl
#align turing.eval_induction Turing.evalInduction
-/

#print Turing.mem_eval /-
theorem mem_eval {σ} {f : σ → Option σ} {a b} : b ∈ eval f a ↔ Reaches f a b ∧ f b = none :=
  ⟨fun h => by
    refine' eval_induction h fun a h IH => _
    cases' e : f a with a'
    · rw [Part.mem_unique h
          (PFun.mem_fix_iff.2 <| Or.inl <| Part.mem_some_iff.2 <| by rw [e] <;> rfl)]
      exact ⟨refl_trans_gen.refl, e⟩
    · rcases PFun.mem_fix_iff.1 h with (h | ⟨_, h, _⟩) <;> rw [e] at h <;>
        cases Part.mem_some_iff.1 h
      cases' IH a' (by rwa [e]) with h₁ h₂
      exact ⟨refl_trans_gen.head e h₁, h₂⟩, fun ⟨h₁, h₂⟩ =>
    by
    refine' refl_trans_gen.head_induction_on h₁ _ fun a a' h _ IH => _
    · refine' PFun.mem_fix_iff.2 (Or.inl _)
      rw [h₂]
      apply Part.mem_some
    · refine' PFun.mem_fix_iff.2 (Or.inr ⟨_, _, IH⟩)
      rw [show f a = _ from h]
      apply Part.mem_some⟩
#align turing.mem_eval Turing.mem_eval
-/

#print Turing.eval_maximal₁ /-
theorem eval_maximal₁ {σ} {f : σ → Option σ} {a b} (h : b ∈ eval f a) (c) : ¬Reaches₁ f b c
  | bc => by
    let ⟨ab, b0⟩ := mem_eval.1 h
    let ⟨b', h', _⟩ := TransGen.head'_iff.1 bc
    cases b0.symm.trans h'
#align turing.eval_maximal₁ Turing.eval_maximal₁
-/

#print Turing.eval_maximal /-
theorem eval_maximal {σ} {f : σ → Option σ} {a b} (h : b ∈ eval f a) {c} : Reaches f b c ↔ c = b :=
  let ⟨ab, b0⟩ := mem_eval.1 h
  reflTransGen_iff_eq fun b' h' => by cases b0.symm.trans h'
#align turing.eval_maximal Turing.eval_maximal
-/

#print Turing.reaches_eval /-
theorem reaches_eval {σ} {f : σ → Option σ} {a b} (ab : Reaches f a b) : eval f a = eval f b :=
  Part.ext fun c =>
    ⟨fun h =>
      let ⟨ac, c0⟩ := mem_eval.1 h
      mem_eval.2
        ⟨(or_iff_left_of_imp fun cb => (eval_maximal h).1 cb ▸ refl_trans_gen.refl).1
            (reaches_total ab ac),
          c0⟩,
      fun h =>
      let ⟨bc, c0⟩ := mem_eval.1 h
      mem_eval.2 ⟨ab.trans bc, c0⟩⟩
#align turing.reaches_eval Turing.reaches_eval
-/

#print Turing.Respects /-
/-- Given a relation `tr : σ₁ → σ₂ → Prop` between state spaces, and state transition functions
`f₁ : σ₁ → option σ₁` and `f₂ : σ₂ → option σ₂`, `respects f₁ f₂ tr` means that if `tr a₁ a₂` holds
initially and `f₁` takes a step to `a₂` then `f₂` will take one or more steps before reaching a
state `b₂` satisfying `tr a₂ b₂`, and if `f₁ a₁` terminates then `f₂ a₂` also terminates.
Such a relation `tr` is also known as a refinement. -/
def Respects {σ₁ σ₂} (f₁ : σ₁ → Option σ₁) (f₂ : σ₂ → Option σ₂) (tr : σ₁ → σ₂ → Prop) :=
  ∀ ⦃a₁ a₂⦄,
    tr a₁ a₂ →
      (match f₁ a₁ with
        | some b₁ => ∃ b₂, tr b₁ b₂ ∧ Reaches₁ f₂ a₂ b₂
        | none => f₂ a₂ = none :
        Prop)
#align turing.respects Turing.Respects
-/

/- warning: turing.tr_reaches₁ -> Turing.tr_reaches₁ is a dubious translation:
lean 3 declaration is
  forall {σ₁ : Type.{u1}} {σ₂ : Type.{u2}} {f₁ : σ₁ -> (Option.{u1} σ₁)} {f₂ : σ₂ -> (Option.{u2} σ₂)} {tr : σ₁ -> σ₂ -> Prop}, (Turing.Respects.{u1, u2} σ₁ σ₂ f₁ f₂ tr) -> (forall {a₁ : σ₁} {a₂ : σ₂}, (tr a₁ a₂) -> (forall {b₁ : σ₁}, (Turing.Reaches₁.{u1} σ₁ f₁ a₁ b₁) -> (Exists.{succ u2} σ₂ (fun (b₂ : σ₂) => And (tr b₁ b₂) (Turing.Reaches₁.{u2} σ₂ f₂ a₂ b₂)))))
but is expected to have type
  forall {σ₁ : Type.{u2}} {σ₂ : Type.{u1}} {f₁ : σ₁ -> (Option.{u2} σ₁)} {f₂ : σ₂ -> (Option.{u1} σ₂)} {tr : σ₁ -> σ₂ -> Prop}, (Turing.Respects.{u2, u1} σ₁ σ₂ f₁ f₂ tr) -> (forall {a₁ : σ₁} {a₂ : σ₂}, (tr a₁ a₂) -> (forall {b₁ : σ₁}, (Turing.Reaches₁.{u2} σ₁ f₁ a₁ b₁) -> (Exists.{succ u1} σ₂ (fun (b₂ : σ₂) => And (tr b₁ b₂) (Turing.Reaches₁.{u1} σ₂ f₂ a₂ b₂)))))
Case conversion may be inaccurate. Consider using '#align turing.tr_reaches₁ Turing.tr_reaches₁ₓ'. -/
theorem tr_reaches₁ {σ₁ σ₂ f₁ f₂} {tr : σ₁ → σ₂ → Prop} (H : Respects f₁ f₂ tr) {a₁ a₂}
    (aa : tr a₁ a₂) {b₁} (ab : Reaches₁ f₁ a₁ b₁) : ∃ b₂, tr b₁ b₂ ∧ Reaches₁ f₂ a₂ b₂ :=
  by
  induction' ab with c₁ ac c₁ d₁ ac cd IH
  · have := H aa
    rwa [show f₁ a₁ = _ from ac] at this
  · rcases IH with ⟨c₂, cc, ac₂⟩
    have := H cc
    rw [show f₁ c₁ = _ from cd] at this
    rcases this with ⟨d₂, dd, cd₂⟩
    exact ⟨_, dd, ac₂.trans cd₂⟩
#align turing.tr_reaches₁ Turing.tr_reaches₁

/- warning: turing.tr_reaches -> Turing.tr_reaches is a dubious translation:
lean 3 declaration is
  forall {σ₁ : Type.{u1}} {σ₂ : Type.{u2}} {f₁ : σ₁ -> (Option.{u1} σ₁)} {f₂ : σ₂ -> (Option.{u2} σ₂)} {tr : σ₁ -> σ₂ -> Prop}, (Turing.Respects.{u1, u2} σ₁ σ₂ f₁ f₂ tr) -> (forall {a₁ : σ₁} {a₂ : σ₂}, (tr a₁ a₂) -> (forall {b₁ : σ₁}, (Turing.Reaches.{u1} σ₁ f₁ a₁ b₁) -> (Exists.{succ u2} σ₂ (fun (b₂ : σ₂) => And (tr b₁ b₂) (Turing.Reaches.{u2} σ₂ f₂ a₂ b₂)))))
but is expected to have type
  forall {σ₁ : Type.{u2}} {σ₂ : Type.{u1}} {f₁ : σ₁ -> (Option.{u2} σ₁)} {f₂ : σ₂ -> (Option.{u1} σ₂)} {tr : σ₁ -> σ₂ -> Prop}, (Turing.Respects.{u2, u1} σ₁ σ₂ f₁ f₂ tr) -> (forall {a₁ : σ₁} {a₂ : σ₂}, (tr a₁ a₂) -> (forall {b₁ : σ₁}, (Turing.Reaches.{u2} σ₁ f₁ a₁ b₁) -> (Exists.{succ u1} σ₂ (fun (b₂ : σ₂) => And (tr b₁ b₂) (Turing.Reaches.{u1} σ₂ f₂ a₂ b₂)))))
Case conversion may be inaccurate. Consider using '#align turing.tr_reaches Turing.tr_reachesₓ'. -/
theorem tr_reaches {σ₁ σ₂ f₁ f₂} {tr : σ₁ → σ₂ → Prop} (H : Respects f₁ f₂ tr) {a₁ a₂}
    (aa : tr a₁ a₂) {b₁} (ab : Reaches f₁ a₁ b₁) : ∃ b₂, tr b₁ b₂ ∧ Reaches f₂ a₂ b₂ :=
  by
  rcases refl_trans_gen_iff_eq_or_trans_gen.1 ab with (rfl | ab)
  · exact ⟨_, aa, refl_trans_gen.refl⟩
  ·
    exact
      let ⟨b₂, bb, h⟩ := tr_reaches₁ H aa ab
      ⟨b₂, bb, h.to_reflTransGen⟩
#align turing.tr_reaches Turing.tr_reaches

/- warning: turing.tr_reaches_rev -> Turing.tr_reaches_rev is a dubious translation:
lean 3 declaration is
  forall {σ₁ : Type.{u1}} {σ₂ : Type.{u2}} {f₁ : σ₁ -> (Option.{u1} σ₁)} {f₂ : σ₂ -> (Option.{u2} σ₂)} {tr : σ₁ -> σ₂ -> Prop}, (Turing.Respects.{u1, u2} σ₁ σ₂ f₁ f₂ tr) -> (forall {a₁ : σ₁} {a₂ : σ₂}, (tr a₁ a₂) -> (forall {b₂ : σ₂}, (Turing.Reaches.{u2} σ₂ f₂ a₂ b₂) -> (Exists.{succ u1} σ₁ (fun (c₁ : σ₁) => Exists.{succ u2} σ₂ (fun (c₂ : σ₂) => And (Turing.Reaches.{u2} σ₂ f₂ b₂ c₂) (And (tr c₁ c₂) (Turing.Reaches.{u1} σ₁ f₁ a₁ c₁)))))))
but is expected to have type
  forall {σ₁ : Type.{u2}} {σ₂ : Type.{u1}} {f₁ : σ₁ -> (Option.{u2} σ₁)} {f₂ : σ₂ -> (Option.{u1} σ₂)} {tr : σ₁ -> σ₂ -> Prop}, (Turing.Respects.{u2, u1} σ₁ σ₂ f₁ f₂ tr) -> (forall {a₁ : σ₁} {a₂ : σ₂}, (tr a₁ a₂) -> (forall {b₂ : σ₂}, (Turing.Reaches.{u1} σ₂ f₂ a₂ b₂) -> (Exists.{succ u2} σ₁ (fun (c₁ : σ₁) => Exists.{succ u1} σ₂ (fun (c₂ : σ₂) => And (Turing.Reaches.{u1} σ₂ f₂ b₂ c₂) (And (tr c₁ c₂) (Turing.Reaches.{u2} σ₁ f₁ a₁ c₁)))))))
Case conversion may be inaccurate. Consider using '#align turing.tr_reaches_rev Turing.tr_reaches_revₓ'. -/
theorem tr_reaches_rev {σ₁ σ₂ f₁ f₂} {tr : σ₁ → σ₂ → Prop} (H : Respects f₁ f₂ tr) {a₁ a₂}
    (aa : tr a₁ a₂) {b₂} (ab : Reaches f₂ a₂ b₂) :
    ∃ c₁ c₂, Reaches f₂ b₂ c₂ ∧ tr c₁ c₂ ∧ Reaches f₁ a₁ c₁ :=
  by
  induction' ab with c₂ d₂ ac cd IH
  · exact ⟨_, _, refl_trans_gen.refl, aa, refl_trans_gen.refl⟩
  · rcases IH with ⟨e₁, e₂, ce, ee, ae⟩
    rcases refl_trans_gen.cases_head ce with (rfl | ⟨d', cd', de⟩)
    · have := H ee
      revert this
      cases' eg : f₁ e₁ with g₁ <;> simp only [respects, and_imp, exists_imp]
      · intro c0
        cases cd.symm.trans c0
      · intro g₂ gg cg
        rcases trans_gen.head'_iff.1 cg with ⟨d', cd', dg⟩
        cases Option.mem_unique cd cd'
        exact ⟨_, _, dg, gg, ae.tail eg⟩
    · cases Option.mem_unique cd cd'
      exact ⟨_, _, de, ee, ae⟩
#align turing.tr_reaches_rev Turing.tr_reaches_rev

/- warning: turing.tr_eval -> Turing.tr_eval is a dubious translation:
lean 3 declaration is
  forall {σ₁ : Type.{u1}} {σ₂ : Type.{u2}} {f₁ : σ₁ -> (Option.{u1} σ₁)} {f₂ : σ₂ -> (Option.{u2} σ₂)} {tr : σ₁ -> σ₂ -> Prop}, (Turing.Respects.{u1, u2} σ₁ σ₂ f₁ f₂ tr) -> (forall {a₁ : σ₁} {b₁ : σ₁} {a₂ : σ₂}, (tr a₁ a₂) -> (Membership.Mem.{u1, u1} σ₁ (Part.{u1} σ₁) (Part.hasMem.{u1} σ₁) b₁ (Turing.eval.{u1} σ₁ f₁ a₁)) -> (Exists.{succ u2} σ₂ (fun (b₂ : σ₂) => And (tr b₁ b₂) (Membership.Mem.{u2, u2} σ₂ (Part.{u2} σ₂) (Part.hasMem.{u2} σ₂) b₂ (Turing.eval.{u2} σ₂ f₂ a₂)))))
but is expected to have type
  forall {σ₁ : Type.{u2}} {σ₂ : Type.{u1}} {f₁ : σ₁ -> (Option.{u2} σ₁)} {f₂ : σ₂ -> (Option.{u1} σ₂)} {tr : σ₁ -> σ₂ -> Prop}, (Turing.Respects.{u2, u1} σ₁ σ₂ f₁ f₂ tr) -> (forall {a₁ : σ₁} {b₁ : σ₁} {a₂ : σ₂}, (tr a₁ a₂) -> (Membership.mem.{u2, u2} σ₁ (Part.{u2} σ₁) (Part.instMembershipPart.{u2} σ₁) b₁ (Turing.eval.{u2} σ₁ f₁ a₁)) -> (Exists.{succ u1} σ₂ (fun (b₂ : σ₂) => And (tr b₁ b₂) (Membership.mem.{u1, u1} σ₂ (Part.{u1} σ₂) (Part.instMembershipPart.{u1} σ₂) b₂ (Turing.eval.{u1} σ₂ f₂ a₂)))))
Case conversion may be inaccurate. Consider using '#align turing.tr_eval Turing.tr_evalₓ'. -/
theorem tr_eval {σ₁ σ₂ f₁ f₂} {tr : σ₁ → σ₂ → Prop} (H : Respects f₁ f₂ tr) {a₁ b₁ a₂}
    (aa : tr a₁ a₂) (ab : b₁ ∈ eval f₁ a₁) : ∃ b₂, tr b₁ b₂ ∧ b₂ ∈ eval f₂ a₂ :=
  by
  cases' mem_eval.1 ab with ab b0
  rcases tr_reaches H aa ab with ⟨b₂, bb, ab⟩
  refine' ⟨_, bb, mem_eval.2 ⟨ab, _⟩⟩
  have := H bb; rwa [b0] at this
#align turing.tr_eval Turing.tr_eval

/- warning: turing.tr_eval_rev -> Turing.tr_eval_rev is a dubious translation:
lean 3 declaration is
  forall {σ₁ : Type.{u1}} {σ₂ : Type.{u2}} {f₁ : σ₁ -> (Option.{u1} σ₁)} {f₂ : σ₂ -> (Option.{u2} σ₂)} {tr : σ₁ -> σ₂ -> Prop}, (Turing.Respects.{u1, u2} σ₁ σ₂ f₁ f₂ tr) -> (forall {a₁ : σ₁} {b₂ : σ₂} {a₂ : σ₂}, (tr a₁ a₂) -> (Membership.Mem.{u2, u2} σ₂ (Part.{u2} σ₂) (Part.hasMem.{u2} σ₂) b₂ (Turing.eval.{u2} σ₂ f₂ a₂)) -> (Exists.{succ u1} σ₁ (fun (b₁ : σ₁) => And (tr b₁ b₂) (Membership.Mem.{u1, u1} σ₁ (Part.{u1} σ₁) (Part.hasMem.{u1} σ₁) b₁ (Turing.eval.{u1} σ₁ f₁ a₁)))))
but is expected to have type
  forall {σ₁ : Type.{u2}} {σ₂ : Type.{u1}} {f₁ : σ₁ -> (Option.{u2} σ₁)} {f₂ : σ₂ -> (Option.{u1} σ₂)} {tr : σ₁ -> σ₂ -> Prop}, (Turing.Respects.{u2, u1} σ₁ σ₂ f₁ f₂ tr) -> (forall {a₁ : σ₁} {b₂ : σ₂} {a₂ : σ₂}, (tr a₁ a₂) -> (Membership.mem.{u1, u1} σ₂ (Part.{u1} σ₂) (Part.instMembershipPart.{u1} σ₂) b₂ (Turing.eval.{u1} σ₂ f₂ a₂)) -> (Exists.{succ u2} σ₁ (fun (b₁ : σ₁) => And (tr b₁ b₂) (Membership.mem.{u2, u2} σ₁ (Part.{u2} σ₁) (Part.instMembershipPart.{u2} σ₁) b₁ (Turing.eval.{u2} σ₁ f₁ a₁)))))
Case conversion may be inaccurate. Consider using '#align turing.tr_eval_rev Turing.tr_eval_revₓ'. -/
theorem tr_eval_rev {σ₁ σ₂ f₁ f₂} {tr : σ₁ → σ₂ → Prop} (H : Respects f₁ f₂ tr) {a₁ b₂ a₂}
    (aa : tr a₁ a₂) (ab : b₂ ∈ eval f₂ a₂) : ∃ b₁, tr b₁ b₂ ∧ b₁ ∈ eval f₁ a₁ :=
  by
  cases' mem_eval.1 ab with ab b0
  rcases tr_reaches_rev H aa ab with ⟨c₁, c₂, bc, cc, ac⟩
  cases (refl_trans_gen_iff_eq (Option.eq_none_iff_forall_not_mem.1 b0)).1 bc
  refine' ⟨_, cc, mem_eval.2 ⟨ac, _⟩⟩
  have := H cc; cases' f₁ c₁ with d₁; · rfl
  rcases this with ⟨d₂, dd, bd⟩
  rcases trans_gen.head'_iff.1 bd with ⟨e, h, _⟩
  cases b0.symm.trans h
#align turing.tr_eval_rev Turing.tr_eval_rev

/- warning: turing.tr_eval_dom -> Turing.tr_eval_dom is a dubious translation:
lean 3 declaration is
  forall {σ₁ : Type.{u1}} {σ₂ : Type.{u2}} {f₁ : σ₁ -> (Option.{u1} σ₁)} {f₂ : σ₂ -> (Option.{u2} σ₂)} {tr : σ₁ -> σ₂ -> Prop}, (Turing.Respects.{u1, u2} σ₁ σ₂ f₁ f₂ tr) -> (forall {a₁ : σ₁} {a₂ : σ₂}, (tr a₁ a₂) -> (Iff (Part.Dom.{u2} σ₂ (Turing.eval.{u2} σ₂ f₂ a₂)) (Part.Dom.{u1} σ₁ (Turing.eval.{u1} σ₁ f₁ a₁))))
but is expected to have type
  forall {σ₁ : Type.{u2}} {σ₂ : Type.{u1}} {f₁ : σ₁ -> (Option.{u2} σ₁)} {f₂ : σ₂ -> (Option.{u1} σ₂)} {tr : σ₁ -> σ₂ -> Prop}, (Turing.Respects.{u2, u1} σ₁ σ₂ f₁ f₂ tr) -> (forall {a₁ : σ₁} {a₂ : σ₂}, (tr a₁ a₂) -> (Iff (Part.Dom.{u1} σ₂ (Turing.eval.{u1} σ₂ f₂ a₂)) (Part.Dom.{u2} σ₁ (Turing.eval.{u2} σ₁ f₁ a₁))))
Case conversion may be inaccurate. Consider using '#align turing.tr_eval_dom Turing.tr_eval_domₓ'. -/
theorem tr_eval_dom {σ₁ σ₂ f₁ f₂} {tr : σ₁ → σ₂ → Prop} (H : Respects f₁ f₂ tr) {a₁ a₂}
    (aa : tr a₁ a₂) : (eval f₂ a₂).Dom ↔ (eval f₁ a₁).Dom :=
  ⟨fun h =>
    let ⟨b₂, tr, h, _⟩ := tr_eval_rev H aa ⟨h, rfl⟩
    h,
    fun h =>
    let ⟨b₂, tr, h, _⟩ := tr_eval H aa ⟨h, rfl⟩
    h⟩
#align turing.tr_eval_dom Turing.tr_eval_dom

#print Turing.FRespects /-
/-- A simpler version of `respects` when the state transition relation `tr` is a function. -/
def FRespects {σ₁ σ₂} (f₂ : σ₂ → Option σ₂) (tr : σ₁ → σ₂) (a₂ : σ₂) : Option σ₁ → Prop
  | some b₁ => Reaches₁ f₂ a₂ (tr b₁)
  | none => f₂ a₂ = none
#align turing.frespects Turing.FRespects
-/

/- warning: turing.frespects_eq -> Turing.frespects_eq is a dubious translation:
lean 3 declaration is
  forall {σ₁ : Type.{u1}} {σ₂ : Type.{u2}} {f₂ : σ₂ -> (Option.{u2} σ₂)} {tr : σ₁ -> σ₂} {a₂ : σ₂} {b₂ : σ₂}, (Eq.{succ u2} (Option.{u2} σ₂) (f₂ a₂) (f₂ b₂)) -> (forall {b₁ : Option.{u1} σ₁}, Iff (Turing.FRespects.{u1, u2} σ₁ σ₂ f₂ tr a₂ b₁) (Turing.FRespects.{u1, u2} σ₁ σ₂ f₂ tr b₂ b₁))
but is expected to have type
  forall {σ₁ : Type.{u2}} {σ₂ : Type.{u1}} {f₂ : σ₂ -> (Option.{u1} σ₂)} {tr : σ₁ -> σ₂} {a₂ : σ₂} {b₂ : σ₂}, (Eq.{succ u1} (Option.{u1} σ₂) (f₂ a₂) (f₂ b₂)) -> (forall {b₁ : Option.{u2} σ₁}, Iff (Turing.FRespects.{u2, u1} σ₁ σ₂ f₂ tr a₂ b₁) (Turing.FRespects.{u2, u1} σ₁ σ₂ f₂ tr b₂ b₁))
Case conversion may be inaccurate. Consider using '#align turing.frespects_eq Turing.frespects_eqₓ'. -/
theorem frespects_eq {σ₁ σ₂} {f₂ : σ₂ → Option σ₂} {tr : σ₁ → σ₂} {a₂ b₂} (h : f₂ a₂ = f₂ b₂) :
    ∀ {b₁}, FRespects f₂ tr a₂ b₁ ↔ FRespects f₂ tr b₂ b₁
  | some b₁ => reaches₁_eq h
  | none => by unfold frespects <;> rw [h]
#align turing.frespects_eq Turing.frespects_eq

/- warning: turing.fun_respects -> Turing.fun_respects is a dubious translation:
lean 3 declaration is
  forall {σ₁ : Type.{u1}} {σ₂ : Type.{u2}} {f₁ : σ₁ -> (Option.{u1} σ₁)} {f₂ : σ₂ -> (Option.{u2} σ₂)} {tr : σ₁ -> σ₂}, Iff (Turing.Respects.{u1, u2} σ₁ σ₂ f₁ f₂ (fun (a : σ₁) (b : σ₂) => Eq.{succ u2} σ₂ (tr a) b)) (forall {{a₁ : σ₁}}, Turing.FRespects.{u1, u2} σ₁ σ₂ f₂ tr (tr a₁) (f₁ a₁))
but is expected to have type
  forall {σ₁ : Type.{u2}} {σ₂ : Type.{u1}} {f₁ : σ₁ -> (Option.{u2} σ₁)} {f₂ : σ₂ -> (Option.{u1} σ₂)} {tr : σ₁ -> σ₂}, Iff (Turing.Respects.{u2, u1} σ₁ σ₂ f₁ f₂ (fun (a : σ₁) (b : σ₂) => Eq.{succ u1} σ₂ (tr a) b)) (forall {{a₁ : σ₁}}, Turing.FRespects.{u2, u1} σ₁ σ₂ f₂ tr (tr a₁) (f₁ a₁))
Case conversion may be inaccurate. Consider using '#align turing.fun_respects Turing.fun_respectsₓ'. -/
theorem fun_respects {σ₁ σ₂ f₁ f₂} {tr : σ₁ → σ₂} :
    (Respects f₁ f₂ fun a b => tr a = b) ↔ ∀ ⦃a₁⦄, FRespects f₂ tr (tr a₁) (f₁ a₁) :=
  forall_congr' fun a₁ => by
    cases f₁ a₁ <;> simp only [frespects, respects, exists_eq_left', forall_eq']
#align turing.fun_respects Turing.fun_respects

/- warning: turing.tr_eval' -> Turing.tr_eval' is a dubious translation:
lean 3 declaration is
  forall {σ₁ : Type.{u1}} {σ₂ : Type.{u1}} (f₁ : σ₁ -> (Option.{u1} σ₁)) (f₂ : σ₂ -> (Option.{u1} σ₂)) (tr : σ₁ -> σ₂), (Turing.Respects.{u1, u1} σ₁ σ₂ f₁ f₂ (fun (a : σ₁) (b : σ₂) => Eq.{succ u1} σ₂ (tr a) b)) -> (forall (a₁ : σ₁), Eq.{succ u1} (Part.{u1} σ₂) (Turing.eval.{u1} σ₂ f₂ (tr a₁)) (Functor.map.{u1, u1} Part.{u1} (Applicative.toFunctor.{u1, u1} Part.{u1} (Monad.toApplicative.{u1, u1} Part.{u1} Part.monad.{u1})) σ₁ σ₂ tr (Turing.eval.{u1} σ₁ f₁ a₁)))
but is expected to have type
  forall {σ₁ : Type.{u1}} {σ₂ : Type.{u1}} (f₁ : σ₁ -> (Option.{u1} σ₁)) (f₂ : σ₂ -> (Option.{u1} σ₂)) (tr : σ₁ -> σ₂), (Turing.Respects.{u1, u1} σ₁ σ₂ f₁ f₂ (fun (a : σ₁) (b : σ₂) => Eq.{succ u1} σ₂ (tr a) b)) -> (forall (a₁ : σ₁), Eq.{succ u1} (Part.{u1} σ₂) (Turing.eval.{u1} σ₂ f₂ (tr a₁)) (Functor.map.{u1, u1} Part.{u1} (Applicative.toFunctor.{u1, u1} Part.{u1} (Monad.toApplicative.{u1, u1} Part.{u1} Part.instMonadPart.{u1})) σ₁ σ₂ tr (Turing.eval.{u1} σ₁ f₁ a₁)))
Case conversion may be inaccurate. Consider using '#align turing.tr_eval' Turing.tr_eval'ₓ'. -/
theorem tr_eval' {σ₁ σ₂} (f₁ : σ₁ → Option σ₁) (f₂ : σ₂ → Option σ₂) (tr : σ₁ → σ₂)
    (H : Respects f₁ f₂ fun a b => tr a = b) (a₁) : eval f₂ (tr a₁) = tr <$> eval f₁ a₁ :=
  Part.ext fun b₂ =>
    ⟨fun h =>
      let ⟨b₁, bb, hb⟩ := tr_eval_rev H rfl h
      (Part.mem_map_iff _).2 ⟨b₁, hb, bb⟩,
      fun h => by
      rcases(Part.mem_map_iff _).1 h with ⟨b₁, ab, bb⟩
      rcases tr_eval H rfl ab with ⟨_, rfl, h⟩
      rwa [bb] at h⟩
#align turing.tr_eval' Turing.tr_eval'

/-!
## The TM0 model

A TM0 turing machine is essentially a Post-Turing machine, adapted for type theory.

A Post-Turing machine with symbol type `Γ` and label type `Λ` is a function
`Λ → Γ → option (Λ × stmt)`, where a `stmt` can be either `move left`, `move right` or `write a`
for `a : Γ`. The machine works over a "tape", a doubly-infinite sequence of elements of `Γ`, and
an instantaneous configuration, `cfg`, is a label `q : Λ` indicating the current internal state of
the machine, and a `tape Γ` (which is essentially `ℤ →₀ Γ`). The evolution is described by the
`step` function:

* If `M q T.head = none`, then the machine halts.
* If `M q T.head = some (q', s)`, then the machine performs action `s : stmt` and then transitions
  to state `q'`.

The initial state takes a `list Γ` and produces a `tape Γ` where the head of the list is the head
of the tape and the rest of the list extends to the right, with the left side all blank. The final
state takes the entire right side of the tape right or equal to the current position of the
machine. (This is actually a `list_blank Γ`, not a `list Γ`, because we don't know, at this level
of generality, where the output ends. If equality to `default : Γ` is decidable we can trim the list
to remove the infinite tail of blanks.)
-/


namespace TM0

section

parameter (Γ : Type _)[Inhabited Γ]

-- type of tape symbols
parameter (Λ : Type _)[Inhabited Λ]

/- warning: turing.TM0.stmt -> Turing.TM0.Stmt is a dubious translation:
lean 3 declaration is
  forall (Γ : Type.{u1}) [_inst_1 : Inhabited.{succ u1} Γ], Type.{u1}
but is expected to have type
  Type.{u1} -> Type.{u1}
Case conversion may be inaccurate. Consider using '#align turing.TM0.stmt Turing.TM0.Stmtₓ'. -/
-- type of "labels" or TM states
/-- A Turing machine "statement" is just a command to either move
  left or right, or write a symbol on the tape. -/
inductive Stmt
  | move : Dir → stmt
  | write : Γ → stmt
#align turing.TM0.stmt Turing.TM0.Stmt

#print Turing.TM0.Stmt.inhabited /-
instance Stmt.inhabited : Inhabited stmt :=
  ⟨stmt.write default⟩
#align turing.TM0.stmt.inhabited Turing.TM0.Stmt.inhabited
-/

/- warning: turing.TM0.machine -> Turing.TM0.Machine is a dubious translation:
lean 3 declaration is
  forall (Γ : Type.{u1}) [_inst_1 : Inhabited.{succ u1} Γ] (Λ : Type.{u2}) [_inst_2 : Inhabited.{succ u2} Λ], Sort.{max (succ u2) (succ u1) (succ (max u2 u1))}
but is expected to have type
  Type.{u1} -> (forall (_inst_1 : Type.{u2}) [Λ : Inhabited.{succ u2} _inst_1], Sort.{max (max (succ u1) (succ u2)) (succ (max u1 u2))})
Case conversion may be inaccurate. Consider using '#align turing.TM0.machine Turing.TM0.Machineₓ'. -/
-- [inhabited Λ]: this is a deliberate addition, see comment
/-- A Post-Turing machine with symbol type `Γ` and label type `Λ`
  is a function which, given the current state `q : Λ` and
  the tape head `a : Γ`, either halts (returns `none`) or returns
  a new state `q' : Λ` and a `stmt` describing what to do,
  either a move left or right, or a write command.

  Both `Λ` and `Γ` are required to be inhabited; the default value
  for `Γ` is the "blank" tape value, and the default value of `Λ` is
  the initial state. -/
@[nolint unused_arguments]
def Machine :=
  Λ → Γ → Option (Λ × stmt)
#align turing.TM0.machine Turing.TM0.Machine

/- warning: turing.TM0.machine.inhabited -> Turing.TM0.Machine.inhabited is a dubious translation:
lean 3 declaration is
  forall (Γ : Type.{u1}) [_inst_1 : Inhabited.{succ u1} Γ] (Λ : Type.{u2}) [_inst_2 : Inhabited.{succ u2} Λ], Inhabited.{max (succ u2) (succ u1) (succ (max u2 u1))} (Turing.TM0.Machine.{u1, u2} Γ _inst_1 Λ _inst_2)
but is expected to have type
  forall (Γ : Type.{u1}) (_inst_1 : Type.{u2}) [Λ : Inhabited.{succ u2} _inst_1], Inhabited.{max (succ u2) (succ u1)} (Turing.TM0.Machine.{u1, u2} Γ _inst_1 Λ)
Case conversion may be inaccurate. Consider using '#align turing.TM0.machine.inhabited Turing.TM0.Machine.inhabitedₓ'. -/
instance Machine.inhabited : Inhabited machine := by unfold machine <;> infer_instance
#align turing.TM0.machine.inhabited Turing.TM0.Machine.inhabited

/- warning: turing.TM0.cfg -> Turing.TM0.Cfg is a dubious translation:
lean 3 declaration is
  forall (Γ : Type.{u1}) [_inst_1 : Inhabited.{succ u1} Γ] (Λ : Type.{u2}) [_inst_2 : Inhabited.{succ u2} Λ], Sort.{max (succ u1) (succ u2)}
but is expected to have type
  forall (Γ : Type.{u1}) [_inst_1 : Inhabited.{succ u1} Γ], Type.{u2} -> Sort.{max (succ u1) (succ u2)}
Case conversion may be inaccurate. Consider using '#align turing.TM0.cfg Turing.TM0.Cfgₓ'. -/
/-- The configuration state of a Turing machine during operation
  consists of a label (machine state), and a tape, represented in
  the form `(a, L, R)` meaning the tape looks like `L.rev ++ [a] ++ R`
  with the machine currently reading the `a`. The lists are
  automatically extended with blanks as the machine moves around. -/
structure Cfg where
  q : Λ
  Tape : Tape Γ
#align turing.TM0.cfg Turing.TM0.Cfg

#print Turing.TM0.Cfg.inhabited /-
instance Cfg.inhabited : Inhabited cfg :=
  ⟨⟨default, default⟩⟩
#align turing.TM0.cfg.inhabited Turing.TM0.Cfg.inhabited
-/

parameter {Γ Λ}

#print Turing.TM0.step /-
/-- Execution semantics of the Turing machine. -/
def step (M : machine) : cfg → Option cfg
  | ⟨q, T⟩ =>
    (M q T.1).map fun ⟨q', a⟩ =>
      ⟨q',
        match a with
        | stmt.move d => T.move d
        | stmt.write a => T.write a⟩
#align turing.TM0.step Turing.TM0.step
-/

#print Turing.TM0.Reaches /-
/-- The statement `reaches M s₁ s₂` means that `s₂` is obtained
  starting from `s₁` after a finite number of steps from `s₂`. -/
def Reaches (M : machine) : cfg → cfg → Prop :=
  ReflTransGen fun a b => b ∈ step M a
#align turing.TM0.reaches Turing.TM0.Reaches
-/

#print Turing.TM0.init /-
/-- The initial configuration. -/
def init (l : List Γ) : cfg :=
  ⟨default, Tape.mk₁ l⟩
#align turing.TM0.init Turing.TM0.init
-/

#print Turing.TM0.eval /-
/-- Evaluate a Turing machine on initial input to a final state,
  if it terminates. -/
def eval (M : machine) (l : List Γ) : Part (ListBlank Γ) :=
  (eval (step M) (init l)).map fun c => c.Tape.right₀
#align turing.TM0.eval Turing.TM0.eval
-/

/- warning: turing.TM0.supports -> Turing.TM0.Supports is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ], (Turing.TM0.Machine.{u1, u2} Γ _inst_1 Λ _inst_2) -> (Set.{u2} Λ) -> Prop
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} [Λ : Inhabited.{succ u2} _inst_1], (Turing.TM0.Machine.{u1, u2} Γ _inst_1 Λ) -> (Set.{u2} _inst_1) -> Prop
Case conversion may be inaccurate. Consider using '#align turing.TM0.supports Turing.TM0.Supportsₓ'. -/
/-- The raw definition of a Turing machine does not require that
  `Γ` and `Λ` are finite, and in practice we will be interested
  in the infinite `Λ` case. We recover instead a notion of
  "effectively finite" Turing machines, which only make use of a
  finite subset of their states. We say that a set `S ⊆ Λ`
  supports a Turing machine `M` if `S` is closed under the
  transition function and contains the initial state. -/
def Supports (M : machine) (S : Set Λ) :=
  default ∈ S ∧ ∀ {q a q' s}, (q', s) ∈ M q a → q ∈ S → q' ∈ S
#align turing.TM0.supports Turing.TM0.Supports

/- warning: turing.TM0.step_supports -> Turing.TM0.step_supports is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] (M : Turing.TM0.Machine.{u1, u2} Γ _inst_1 Λ _inst_2) {S : Set.{u2} Λ}, (Turing.TM0.Supports.{u1, u2} Γ _inst_1 Λ _inst_2 M S) -> (forall {c : Turing.TM0.Cfg.{u1, u2} Γ _inst_1 Λ _inst_2} {c' : Turing.TM0.Cfg.{u1, u2} Γ _inst_1 Λ _inst_2}, (Membership.Mem.{max u1 u2, max u1 u2} (Turing.TM0.Cfg.{u1, u2} Γ _inst_1 Λ _inst_2) (Option.{max u1 u2} (Turing.TM0.Cfg.{u1, u2} Γ _inst_1 Λ _inst_2)) (Option.hasMem.{max u1 u2} (Turing.TM0.Cfg.{u1, u2} Γ _inst_1 Λ _inst_2)) c' (Turing.TM0.step.{u1, u2} Γ _inst_1 Λ _inst_2 M c)) -> (Membership.Mem.{u2, u2} Λ (Set.{u2} Λ) (Set.hasMem.{u2} Λ) (Turing.TM0.Cfg.q.{u1, u2} Γ _inst_1 Λ _inst_2 c) S) -> (Membership.Mem.{u2, u2} Λ (Set.{u2} Λ) (Set.hasMem.{u2} Λ) (Turing.TM0.Cfg.q.{u1, u2} Γ _inst_1 Λ _inst_2 c') S))
but is expected to have type
  forall {Γ : Type.{u2}} [_inst_1 : Inhabited.{succ u2} Γ] {Λ : Type.{u1}} [_inst_2 : Inhabited.{succ u1} Λ] (M : Turing.TM0.Machine.{u2, u1} Γ Λ _inst_2) {S : Set.{u1} Λ}, (Turing.TM0.Supports.{u2, u1} Γ Λ _inst_2 M S) -> (forall {c : Turing.TM0.Cfg.{u2, u1} Γ _inst_1 Λ} {c' : Turing.TM0.Cfg.{u2, u1} Γ _inst_1 Λ}, (Membership.mem.{max u2 u1, max u1 u2} (Turing.TM0.Cfg.{u2, u1} Γ _inst_1 Λ) (Option.{max u1 u2} (Turing.TM0.Cfg.{u2, u1} Γ _inst_1 Λ)) (Option.instMembershipOption.{max u2 u1} (Turing.TM0.Cfg.{u2, u1} Γ _inst_1 Λ)) c' (Turing.TM0.step.{u2, u1} Γ _inst_1 Λ _inst_2 M c)) -> (Membership.mem.{u1, u1} Λ (Set.{u1} Λ) (Set.instMembershipSet.{u1} Λ) (Turing.TM0.Cfg.q.{u2, u1} Γ _inst_1 Λ c) S) -> (Membership.mem.{u1, u1} Λ (Set.{u1} Λ) (Set.instMembershipSet.{u1} Λ) (Turing.TM0.Cfg.q.{u2, u1} Γ _inst_1 Λ c') S))
Case conversion may be inaccurate. Consider using '#align turing.TM0.step_supports Turing.TM0.step_supportsₓ'. -/
theorem step_supports (M : machine) {S} (ss : supports M S) :
    ∀ {c c' : cfg}, c' ∈ step M c → c.q ∈ S → c'.q ∈ S
  | ⟨q, T⟩, c', h₁, h₂ =>
    by
    rcases Option.map_eq_some'.1 h₁ with ⟨⟨q', a⟩, h, rfl⟩
    exact ss.2 h h₂
#align turing.TM0.step_supports Turing.TM0.step_supports

/- warning: turing.TM0.univ_supports -> Turing.TM0.univ_supports is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] (M : Turing.TM0.Machine.{u1, u2} Γ _inst_1 Λ _inst_2), Turing.TM0.Supports.{u1, u2} Γ _inst_1 Λ _inst_2 M (Set.univ.{u2} Λ)
but is expected to have type
  forall {Γ : Type.{u2}} {_inst_1 : Type.{u1}} [Λ : Inhabited.{succ u1} _inst_1] (_inst_2 : Turing.TM0.Machine.{u2, u1} Γ _inst_1 Λ), Turing.TM0.Supports.{u2, u1} Γ _inst_1 Λ _inst_2 (Set.univ.{u1} _inst_1)
Case conversion may be inaccurate. Consider using '#align turing.TM0.univ_supports Turing.TM0.univ_supportsₓ'. -/
theorem univ_supports (M : machine) : supports M Set.univ :=
  ⟨trivial, fun q a q' s h₁ h₂ => trivial⟩
#align turing.TM0.univ_supports Turing.TM0.univ_supports

end

section

variable {Γ : Type _} [Inhabited Γ]

variable {Γ' : Type _} [Inhabited Γ']

variable {Λ : Type _} [Inhabited Λ]

variable {Λ' : Type _} [Inhabited Λ']

#print Turing.TM0.Stmt.map /-
/-- Map a TM statement across a function. This does nothing to move statements and maps the write
values. -/
def Stmt.map (f : PointedMap Γ Γ') : Stmt Γ → Stmt Γ'
  | stmt.move d => Stmt.move d
  | stmt.write a => Stmt.write (f a)
#align turing.TM0.stmt.map Turing.TM0.Stmt.map
-/

/- warning: turing.TM0.cfg.map -> Turing.TM0.Cfg.map is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Γ' : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Γ'] {Λ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} Λ] {Λ' : Type.{u4}} [_inst_4 : Inhabited.{succ u4} Λ'], (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) -> (Λ -> Λ') -> (Turing.TM0.Cfg.{u1, u3} Γ _inst_1 Λ _inst_3) -> (Turing.TM0.Cfg.{u2, u4} Γ' _inst_2 Λ' _inst_4)
but is expected to have type
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Γ' : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Γ'] {Λ : Type.{u3}} {_inst_3 : Type.{u4}}, (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) -> (Λ -> _inst_3) -> (Turing.TM0.Cfg.{u1, u3} Γ _inst_1 Λ) -> (Turing.TM0.Cfg.{u2, u4} Γ' _inst_2 _inst_3)
Case conversion may be inaccurate. Consider using '#align turing.TM0.cfg.map Turing.TM0.Cfg.mapₓ'. -/
/-- Map a configuration across a function, given `f : Γ → Γ'` a map of the alphabets and
`g : Λ → Λ'` a map of the machine states. -/
def Cfg.map (f : PointedMap Γ Γ') (g : Λ → Λ') : Cfg Γ Λ → Cfg Γ' Λ'
  | ⟨q, T⟩ => ⟨g q, T.map f⟩
#align turing.TM0.cfg.map Turing.TM0.Cfg.map

variable (M : Machine Γ Λ) (f₁ : PointedMap Γ Γ') (f₂ : PointedMap Γ' Γ) (g₁ : Λ → Λ') (g₂ : Λ' → Λ)

#print Turing.TM0.Machine.map /-
/-- Because the state transition function uses the alphabet and machine states in both the input
and output, to map a machine from one alphabet and machine state space to another we need functions
in both directions, essentially an `equiv` without the laws. -/
def Machine.map : Machine Γ' Λ'
  | q, l => (M (g₂ q) (f₂ l)).map (Prod.map g₁ (Stmt.map f₁))
#align turing.TM0.machine.map Turing.TM0.Machine.map
-/

/- warning: turing.TM0.machine.map_step -> Turing.TM0.Machine.map_step is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Γ' : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Γ'] {Λ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} Λ] {Λ' : Type.{u4}} [_inst_4 : Inhabited.{succ u4} Λ'] (M : Turing.TM0.Machine.{u1, u3} Γ _inst_1 Λ _inst_3) (f₁ : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (f₂ : Turing.PointedMap.{u2, u1} Γ' Γ _inst_2 _inst_1) (g₁ : Λ -> Λ') (g₂ : Λ' -> Λ) {S : Set.{u3} Λ}, (Function.RightInverse.{succ u2, succ u1} Γ' Γ (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) f₁) (coeFn.{succ (max u2 u1), max (succ u2) (succ u1)} (Turing.PointedMap.{u2, u1} Γ' Γ _inst_2 _inst_1) (fun (_x : Turing.PointedMap.{u2, u1} Γ' Γ _inst_2 _inst_1) => Γ' -> Γ) (Turing.PointedMap.hasCoeToFun.{u2, u1} Γ' Γ _inst_2 _inst_1) f₂)) -> (forall (q : Λ), (Membership.Mem.{u3, u3} Λ (Set.{u3} Λ) (Set.hasMem.{u3} Λ) q S) -> (Eq.{succ u3} Λ (g₂ (g₁ q)) q)) -> (forall (c : Turing.TM0.Cfg.{u1, u3} Γ _inst_1 Λ _inst_3), (Membership.Mem.{u3, u3} Λ (Set.{u3} Λ) (Set.hasMem.{u3} Λ) (Turing.TM0.Cfg.q.{u1, u3} Γ _inst_1 Λ _inst_3 c) S) -> (Eq.{succ (max u2 u4)} (Option.{max u2 u4} (Turing.TM0.Cfg.{u2, u4} Γ' _inst_2 Λ' _inst_4)) (Option.map.{max u1 u3, max u2 u4} (Turing.TM0.Cfg.{u1, u3} Γ _inst_1 Λ _inst_3) (Turing.TM0.Cfg.{u2, u4} Γ' _inst_2 Λ' _inst_4) (Turing.TM0.Cfg.map.{u1, u2, u3, u4} Γ _inst_1 Γ' _inst_2 Λ _inst_3 Λ' _inst_4 f₁ g₁) (Turing.TM0.step.{u1, u3} Γ _inst_1 Λ _inst_3 M c)) (Turing.TM0.step.{u2, u4} Γ' _inst_2 Λ' _inst_4 (Turing.TM0.Machine.map.{u1, u2, u3, u4} Γ _inst_1 Γ' _inst_2 Λ _inst_3 Λ' _inst_4 M f₁ f₂ g₁ g₂) (Turing.TM0.Cfg.map.{u1, u2, u3, u4} Γ _inst_1 Γ' _inst_2 Λ _inst_3 Λ' _inst_4 f₁ g₁ c))))
but is expected to have type
  forall {Γ : Type.{u2}} [_inst_1 : Inhabited.{succ u2} Γ] {Γ' : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Γ'] {Λ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} Λ] {Λ' : Type.{u1}} [_inst_4 : Inhabited.{succ u1} Λ'] (M : Turing.TM0.Machine.{u2, u4} Γ Λ _inst_3) (f₁ : Turing.PointedMap.{u2, u3} Γ Γ' _inst_1 _inst_2) (f₂ : Turing.PointedMap.{u3, u2} Γ' Γ _inst_2 _inst_1) (g₁ : Λ -> Λ') (g₂ : Λ' -> Λ) {S : Set.{u4} Λ}, (Function.RightInverse.{succ u3, succ u2} Γ' Γ (Turing.PointedMap.f.{u2, u3} Γ Γ' _inst_1 _inst_2 f₁) (Turing.PointedMap.f.{u3, u2} Γ' Γ _inst_2 _inst_1 f₂)) -> (forall (q : Λ), (Membership.mem.{u4, u4} Λ (Set.{u4} Λ) (Set.instMembershipSet.{u4} Λ) q S) -> (Eq.{succ u4} Λ (g₂ (g₁ q)) q)) -> (forall (c : Turing.TM0.Cfg.{u2, u4} Γ _inst_1 Λ), (Membership.mem.{u4, u4} Λ (Set.{u4} Λ) (Set.instMembershipSet.{u4} Λ) (Turing.TM0.Cfg.q.{u2, u4} Γ _inst_1 Λ c) S) -> (Eq.{max (succ u3) (succ u1)} (Option.{max u1 u3} (Turing.TM0.Cfg.{u3, u1} Γ' _inst_2 Λ')) (Option.map.{max u4 u2, max u1 u3} (Turing.TM0.Cfg.{u2, u4} Γ _inst_1 Λ) (Turing.TM0.Cfg.{u3, u1} Γ' _inst_2 Λ') (Turing.TM0.Cfg.map.{u2, u3, u4, u1} Γ _inst_1 Γ' _inst_2 Λ Λ' f₁ g₁) (Turing.TM0.step.{u2, u4} Γ _inst_1 Λ _inst_3 M c)) (Turing.TM0.step.{u3, u1} Γ' _inst_2 Λ' _inst_4 (Turing.TM0.Machine.map.{u2, u3, u4, u1} Γ _inst_1 Γ' _inst_2 Λ _inst_3 Λ' _inst_4 M f₁ f₂ g₁ g₂) (Turing.TM0.Cfg.map.{u2, u3, u4, u1} Γ _inst_1 Γ' _inst_2 Λ Λ' f₁ g₁ c))))
Case conversion may be inaccurate. Consider using '#align turing.TM0.machine.map_step Turing.TM0.Machine.map_stepₓ'. -/
theorem Machine.map_step {S : Set Λ} (f₂₁ : Function.RightInverse f₁ f₂)
    (g₂₁ : ∀ q ∈ S, g₂ (g₁ q) = q) :
    ∀ c : Cfg Γ Λ,
      c.q ∈ S → (step M c).map (Cfg.map f₁ g₁) = step (M.map f₁ f₂ g₁ g₂) (Cfg.map f₁ g₁ c)
  | ⟨q, T⟩, h => by
    unfold step machine.map cfg.map
    simp only [Turing.Tape.map_fst, g₂₁ q h, f₂₁ _]
    rcases M q T.1 with (_ | ⟨q', d | a⟩); · rfl
    · simp only [step, cfg.map, Option.map_some', tape.map_move f₁]
      rfl
    · simp only [step, cfg.map, Option.map_some', tape.map_write]
      rfl
#align turing.TM0.machine.map_step Turing.TM0.Machine.map_step

/- warning: turing.TM0.map_init -> Turing.TM0.map_init is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Γ' : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Γ'] {Λ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} Λ] {Λ' : Type.{u4}} [_inst_4 : Inhabited.{succ u4} Λ'] (f₁ : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (g₁ : Turing.PointedMap.{u3, u4} Λ Λ' _inst_3 _inst_4) (l : List.{u1} Γ), Eq.{max (succ u2) (succ u4)} (Turing.TM0.Cfg.{u2, u4} Γ' _inst_2 Λ' _inst_4) (Turing.TM0.Cfg.map.{u1, u2, u3, u4} Γ _inst_1 Γ' _inst_2 Λ _inst_3 Λ' _inst_4 f₁ (coeFn.{succ (max u3 u4), max (succ u3) (succ u4)} (Turing.PointedMap.{u3, u4} Λ Λ' _inst_3 _inst_4) (fun (_x : Turing.PointedMap.{u3, u4} Λ Λ' _inst_3 _inst_4) => Λ -> Λ') (Turing.PointedMap.hasCoeToFun.{u3, u4} Λ Λ' _inst_3 _inst_4) g₁) (Turing.TM0.init.{u1, u3} Γ _inst_1 Λ _inst_3 l)) (Turing.TM0.init.{u2, u4} Γ' _inst_2 Λ' _inst_4 (List.map.{u1, u2} Γ Γ' (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) f₁) l))
but is expected to have type
  forall {Γ : Type.{u2}} [_inst_1 : Inhabited.{succ u2} Γ] {Γ' : Type.{u1}} [_inst_2 : Inhabited.{succ u1} Γ'] {Λ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} Λ] {Λ' : Type.{u3}} [_inst_4 : Inhabited.{succ u3} Λ'] (f₁ : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2) (g₁ : Turing.PointedMap.{u4, u3} Λ Λ' _inst_3 _inst_4) (l : List.{u2} Γ), Eq.{max (succ u1) (succ u3)} (Turing.TM0.Cfg.{u1, u3} Γ' _inst_2 Λ') (Turing.TM0.Cfg.map.{u2, u1, u4, u3} Γ _inst_1 Γ' _inst_2 Λ Λ' f₁ (Turing.PointedMap.f.{u4, u3} Λ Λ' _inst_3 _inst_4 g₁) (Turing.TM0.init.{u2, u4} Γ _inst_1 Λ _inst_3 l)) (Turing.TM0.init.{u1, u3} Γ' _inst_2 Λ' _inst_4 (List.map.{u2, u1} Γ Γ' (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 f₁) l))
Case conversion may be inaccurate. Consider using '#align turing.TM0.map_init Turing.TM0.map_initₓ'. -/
theorem map_init (g₁ : PointedMap Λ Λ') (l : List Γ) : (init l).map f₁ g₁ = init (l.map f₁) :=
  congr (congr_arg Cfg.mk g₁.map_pt) (Tape.map_mk₁ _ _)
#align turing.TM0.map_init Turing.TM0.map_init

/- warning: turing.TM0.machine.map_respects -> Turing.TM0.Machine.map_respects is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Γ' : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Γ'] {Λ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} Λ] {Λ' : Type.{u4}} [_inst_4 : Inhabited.{succ u4} Λ'] (M : Turing.TM0.Machine.{u1, u3} Γ _inst_1 Λ _inst_3) (f₁ : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (f₂ : Turing.PointedMap.{u2, u1} Γ' Γ _inst_2 _inst_1) (g₁ : Turing.PointedMap.{u3, u4} Λ Λ' _inst_3 _inst_4) (g₂ : Λ' -> Λ) {S : Set.{u3} Λ}, (Turing.TM0.Supports.{u1, u3} Γ _inst_1 Λ _inst_3 M S) -> (Function.RightInverse.{succ u2, succ u1} Γ' Γ (coeFn.{succ (max u1 u2), max (succ u1) (succ u2)} (Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) (fun (_x : Turing.PointedMap.{u1, u2} Γ Γ' _inst_1 _inst_2) => Γ -> Γ') (Turing.PointedMap.hasCoeToFun.{u1, u2} Γ Γ' _inst_1 _inst_2) f₁) (coeFn.{succ (max u2 u1), max (succ u2) (succ u1)} (Turing.PointedMap.{u2, u1} Γ' Γ _inst_2 _inst_1) (fun (_x : Turing.PointedMap.{u2, u1} Γ' Γ _inst_2 _inst_1) => Γ' -> Γ) (Turing.PointedMap.hasCoeToFun.{u2, u1} Γ' Γ _inst_2 _inst_1) f₂)) -> (forall (q : Λ), (Membership.Mem.{u3, u3} Λ (Set.{u3} Λ) (Set.hasMem.{u3} Λ) q S) -> (Eq.{succ u3} Λ (g₂ (coeFn.{succ (max u3 u4), max (succ u3) (succ u4)} (Turing.PointedMap.{u3, u4} Λ Λ' _inst_3 _inst_4) (fun (_x : Turing.PointedMap.{u3, u4} Λ Λ' _inst_3 _inst_4) => Λ -> Λ') (Turing.PointedMap.hasCoeToFun.{u3, u4} Λ Λ' _inst_3 _inst_4) g₁ q)) q)) -> (Turing.Respects.{max u1 u3, max u2 u4} (Turing.TM0.Cfg.{u1, u3} Γ _inst_1 Λ _inst_3) (Turing.TM0.Cfg.{u2, u4} Γ' _inst_2 Λ' _inst_4) (Turing.TM0.step.{u1, u3} Γ _inst_1 Λ _inst_3 M) (Turing.TM0.step.{u2, u4} Γ' _inst_2 Λ' _inst_4 (Turing.TM0.Machine.map.{u1, u2, u3, u4} Γ _inst_1 Γ' _inst_2 Λ _inst_3 Λ' _inst_4 M f₁ f₂ (coeFn.{succ (max u3 u4), max (succ u3) (succ u4)} (Turing.PointedMap.{u3, u4} Λ Λ' _inst_3 _inst_4) (fun (_x : Turing.PointedMap.{u3, u4} Λ Λ' _inst_3 _inst_4) => Λ -> Λ') (Turing.PointedMap.hasCoeToFun.{u3, u4} Λ Λ' _inst_3 _inst_4) g₁) g₂)) (fun (a : Turing.TM0.Cfg.{u1, u3} Γ _inst_1 Λ _inst_3) (b : Turing.TM0.Cfg.{u2, u4} Γ' _inst_2 Λ' _inst_4) => And (Membership.Mem.{u3, u3} Λ (Set.{u3} Λ) (Set.hasMem.{u3} Λ) (Turing.TM0.Cfg.q.{u1, u3} Γ _inst_1 Λ _inst_3 a) S) (Eq.{max (succ u2) (succ u4)} (Turing.TM0.Cfg.{u2, u4} Γ' _inst_2 Λ' _inst_4) (Turing.TM0.Cfg.map.{u1, u2, u3, u4} Γ _inst_1 Γ' _inst_2 Λ _inst_3 Λ' _inst_4 f₁ (coeFn.{succ (max u3 u4), max (succ u3) (succ u4)} (Turing.PointedMap.{u3, u4} Λ Λ' _inst_3 _inst_4) (fun (_x : Turing.PointedMap.{u3, u4} Λ Λ' _inst_3 _inst_4) => Λ -> Λ') (Turing.PointedMap.hasCoeToFun.{u3, u4} Λ Λ' _inst_3 _inst_4) g₁) a) b)))
but is expected to have type
  forall {Γ : Type.{u2}} [_inst_1 : Inhabited.{succ u2} Γ] {Γ' : Type.{u1}} [_inst_2 : Inhabited.{succ u1} Γ'] {Λ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} Λ] {Λ' : Type.{u3}} [_inst_4 : Inhabited.{succ u3} Λ'] (M : Turing.TM0.Machine.{u2, u4} Γ Λ _inst_3) (f₁ : Turing.PointedMap.{u2, u1} Γ Γ' _inst_1 _inst_2) (f₂ : Turing.PointedMap.{u1, u2} Γ' Γ _inst_2 _inst_1) (g₁ : Turing.PointedMap.{u4, u3} Λ Λ' _inst_3 _inst_4) (g₂ : Λ' -> Λ) {S : Set.{u4} Λ}, (Turing.TM0.Supports.{u2, u4} Γ Λ _inst_3 M S) -> (Function.RightInverse.{succ u1, succ u2} Γ' Γ (Turing.PointedMap.f.{u2, u1} Γ Γ' _inst_1 _inst_2 f₁) (Turing.PointedMap.f.{u1, u2} Γ' Γ _inst_2 _inst_1 f₂)) -> (forall (q : Λ), (Membership.mem.{u4, u4} Λ (Set.{u4} Λ) (Set.instMembershipSet.{u4} Λ) q S) -> (Eq.{succ u4} Λ (g₂ (Turing.PointedMap.f.{u4, u3} Λ Λ' _inst_3 _inst_4 g₁ q)) q)) -> (Turing.Respects.{max u4 u2, max u3 u1} (Turing.TM0.Cfg.{u2, u4} Γ _inst_1 Λ) (Turing.TM0.Cfg.{u1, u3} Γ' _inst_2 Λ') (Turing.TM0.step.{u2, u4} Γ _inst_1 Λ _inst_3 M) (Turing.TM0.step.{u1, u3} Γ' _inst_2 Λ' _inst_4 (Turing.TM0.Machine.map.{u2, u1, u4, u3} Γ _inst_1 Γ' _inst_2 Λ _inst_3 Λ' _inst_4 M f₁ f₂ (Turing.PointedMap.f.{u4, u3} Λ Λ' _inst_3 _inst_4 g₁) g₂)) (fun (a : Turing.TM0.Cfg.{u2, u4} Γ _inst_1 Λ) (b : Turing.TM0.Cfg.{u1, u3} Γ' _inst_2 Λ') => And (Membership.mem.{u4, u4} Λ (Set.{u4} Λ) (Set.instMembershipSet.{u4} Λ) (Turing.TM0.Cfg.q.{u2, u4} Γ _inst_1 Λ a) S) (Eq.{max (succ u1) (succ u3)} (Turing.TM0.Cfg.{u1, u3} Γ' _inst_2 Λ') (Turing.TM0.Cfg.map.{u2, u1, u4, u3} Γ _inst_1 Γ' _inst_2 Λ Λ' f₁ (Turing.PointedMap.f.{u4, u3} Λ Λ' _inst_3 _inst_4 g₁) a) b)))
Case conversion may be inaccurate. Consider using '#align turing.TM0.machine.map_respects Turing.TM0.Machine.map_respectsₓ'. -/
theorem Machine.map_respects (g₁ : PointedMap Λ Λ') (g₂ : Λ' → Λ) {S} (ss : Supports M S)
    (f₂₁ : Function.RightInverse f₁ f₂) (g₂₁ : ∀ q ∈ S, g₂ (g₁ q) = q) :
    Respects (step M) (step (M.map f₁ f₂ g₁ g₂)) fun a b => a.q ∈ S ∧ Cfg.map f₁ g₁ a = b
  | c, _, ⟨cs, rfl⟩ => by
    cases' e : step M c with c' <;> unfold respects
    · rw [← M.map_step f₁ f₂ g₁ g₂ f₂₁ g₂₁ _ cs, e]
      rfl
    · refine' ⟨_, ⟨step_supports M ss e cs, rfl⟩, trans_gen.single _⟩
      rw [← M.map_step f₁ f₂ g₁ g₂ f₂₁ g₂₁ _ cs, e]
      exact rfl
#align turing.TM0.machine.map_respects Turing.TM0.Machine.map_respects

end

end TM0

/-!
## The TM1 model

The TM1 model is a simplification and extension of TM0 (Post-Turing model) in the direction of
Wang B-machines. The machine's internal state is extended with a (finite) store `σ` of variables
that may be accessed and updated at any time.

A machine is given by a `Λ` indexed set of procedures or functions. Each function has a body which
is a `stmt`. Most of the regular commands are allowed to use the current value `a` of the local
variables and the value `T.head` on the tape to calculate what to write or how to change local
state, but the statements themselves have a fixed structure. The `stmt`s can be as follows:

* `move d q`: move left or right, and then do `q`
* `write (f : Γ → σ → Γ) q`: write `f a T.head` to the tape, then do `q`
* `load (f : Γ → σ → σ) q`: change the internal state to `f a T.head`
* `branch (f : Γ → σ → bool) qtrue qfalse`: If `f a T.head` is true, do `qtrue`, else `qfalse`
* `goto (f : Γ → σ → Λ)`: Go to label `f a T.head`
* `halt`: Transition to the halting state, which halts on the following step

Note that here most statements do not have labels; `goto` commands can only go to a new function.
Only the `goto` and `halt` statements actually take a step; the rest is done by recursion on
statements and so take 0 steps. (There is a uniform bound on many statements can be executed before
the next `goto`, so this is an `O(1)` speedup with the constant depending on the machine.)

The `halt` command has a one step stutter before actually halting so that any changes made before
the halt have a chance to be "committed", since the `eval` relation uses the final configuration
before the halt as the output, and `move` and `write` etc. take 0 steps in this model.
-/


namespace TM1

section

parameter (Γ : Type _)[Inhabited Γ]

-- Type of tape symbols
parameter (Λ : Type _)

-- Type of function labels
parameter (σ : Type _)

/- warning: turing.TM1.stmt -> Turing.TM1.Stmt is a dubious translation:
lean 3 declaration is
  forall (Γ : Type.{u1}) [_inst_1 : Inhabited.{succ u1} Γ], Type.{u2} -> Type.{u3} -> Sort.{max (succ u1) (succ u2) (succ u3)}
but is expected to have type
  Type.{u1} -> Type.{u2} -> Type.{u3} -> Sort.{max (max (succ u1) (succ u2)) (succ u3)}
Case conversion may be inaccurate. Consider using '#align turing.TM1.stmt Turing.TM1.Stmtₓ'. -/
-- Type of variable settings
/-- The TM1 model is a simplification and extension of TM0
  (Post-Turing model) in the direction of Wang B-machines. The machine's
  internal state is extended with a (finite) store `σ` of variables
  that may be accessed and updated at any time.
  A machine is given by a `Λ` indexed set of procedures or functions.
  Each function has a body which is a `stmt`, which can either be a
  `move` or `write` command, a `branch` (if statement based on the
  current tape value), a `load` (set the variable value),
  a `goto` (call another function), or `halt`. Note that here
  most statements do not have labels; `goto` commands can only
  go to a new function. All commands have access to the variable value
  and current tape value. -/
inductive Stmt
  | move : Dir → stmt → stmt
  | write : (Γ → σ → Γ) → stmt → stmt
  | load : (Γ → σ → σ) → stmt → stmt
  | branch : (Γ → σ → Bool) → stmt → stmt → stmt
  | goto : (Γ → σ → Λ) → stmt
  | halt : stmt
#align turing.TM1.stmt Turing.TM1.Stmt

open Stmt

/- warning: turing.TM1.stmt.inhabited -> Turing.TM1.Stmt.inhabited is a dubious translation:
lean 3 declaration is
  forall (Γ : Type.{u1}) [_inst_1 : Inhabited.{succ u1} Γ] (Λ : Type.{u2}) (σ : Type.{u3}), Inhabited.{max (succ u1) (succ u2) (succ u3)} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)
but is expected to have type
  forall (Γ : Type.{u1}) (_inst_1 : Type.{u2}) (Λ : Type.{u3}), Inhabited.{max (max (succ u3) (succ u2)) (succ u1)} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ)
Case conversion may be inaccurate. Consider using '#align turing.TM1.stmt.inhabited Turing.TM1.Stmt.inhabitedₓ'. -/
instance Stmt.inhabited : Inhabited stmt :=
  ⟨halt⟩
#align turing.TM1.stmt.inhabited Turing.TM1.Stmt.inhabited

#print Turing.TM1.Cfg /-
/-- The configuration of a TM1 machine is given by the currently
  evaluating statement, the variable store value, and the tape. -/
structure Cfg where
  l : Option Λ
  var : σ
  Tape : Tape Γ
#align turing.TM1.cfg Turing.TM1.Cfg
-/

#print Turing.TM1.Cfg.inhabited /-
instance Cfg.inhabited [Inhabited σ] : Inhabited cfg :=
  ⟨⟨default, default, default⟩⟩
#align turing.TM1.cfg.inhabited Turing.TM1.Cfg.inhabited
-/

parameter {Γ Λ σ}

#print Turing.TM1.stepAux /-
/-- The semantics of TM1 evaluation. -/
def stepAux : stmt → σ → Tape Γ → cfg
  | move d q, v, T => step_aux q v (T.move d)
  | write a q, v, T => step_aux q v (T.write (a T.1 v))
  | load s q, v, T => step_aux q (s T.1 v) T
  | branch p q₁ q₂, v, T => cond (p T.1 v) (step_aux q₁ v T) (step_aux q₂ v T)
  | goto l, v, T => ⟨some (l T.1 v), v, T⟩
  | halt, v, T => ⟨none, v, T⟩
#align turing.TM1.step_aux Turing.TM1.stepAux
-/

#print Turing.TM1.step /-
/-- The state transition function. -/
def step (M : Λ → stmt) : cfg → Option cfg
  | ⟨none, v, T⟩ => none
  | ⟨some l, v, T⟩ => some (step_aux (M l) v T)
#align turing.TM1.step Turing.TM1.step
-/

/- warning: turing.TM1.supports_stmt -> Turing.TM1.SupportsStmt is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} {σ : Type.{u3}}, (Finset.{u2} Λ) -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ) -> Prop
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}}, (Finset.{u2} _inst_1) -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ) -> Prop
Case conversion may be inaccurate. Consider using '#align turing.TM1.supports_stmt Turing.TM1.SupportsStmtₓ'. -/
/-- A set `S` of labels supports the statement `q` if all the `goto`
  statements in `q` refer only to other functions in `S`. -/
def SupportsStmt (S : Finset Λ) : stmt → Prop
  | move d q => supports_stmt q
  | write a q => supports_stmt q
  | load s q => supports_stmt q
  | branch p q₁ q₂ => supports_stmt q₁ ∧ supports_stmt q₂
  | goto l => ∀ a v, l a v ∈ S
  | halt => True
#align turing.TM1.supports_stmt Turing.TM1.SupportsStmt

open Classical

/- warning: turing.TM1.stmts₁ -> Turing.TM1.stmts₁ is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} {σ : Type.{u3}}, (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ) -> (Finset.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ))
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}}, (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ) -> (Finset.{max (max u3 u2) u1} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ))
Case conversion may be inaccurate. Consider using '#align turing.TM1.stmts₁ Turing.TM1.stmts₁ₓ'. -/
/-- The subterm closure of a statement. -/
noncomputable def stmts₁ : stmt → Finset stmt
  | Q@(move d q) => insert Q (stmts₁ q)
  | Q@(write a q) => insert Q (stmts₁ q)
  | Q@(load s q) => insert Q (stmts₁ q)
  | Q@(branch p q₁ q₂) => insert Q (stmts₁ q₁ ∪ stmts₁ q₂)
  | Q => {Q}
#align turing.TM1.stmts₁ Turing.TM1.stmts₁

/- warning: turing.TM1.stmts₁_self -> Turing.TM1.stmts₁_self is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} {σ : Type.{u3}} {q : Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ}, Membership.Mem.{max u1 u2 u3, max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ) (Finset.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) (Finset.hasMem.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) q (Turing.TM1.stmts₁.{u1, u2, u3} Γ _inst_1 Λ σ q)
but is expected to have type
  forall {Γ : Type.{u3}} {_inst_1 : Type.{u2}} {Λ : Type.{u1}} {σ : Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ}, Membership.mem.{max (max u3 u2) u1, max (max u1 u2) u3} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ) (Finset.{max (max u1 u2) u3} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ)) (Finset.instMembershipFinset.{max (max u3 u2) u1} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ)) σ (Turing.TM1.stmts₁.{u3, u2, u1} Γ _inst_1 Λ σ)
Case conversion may be inaccurate. Consider using '#align turing.TM1.stmts₁_self Turing.TM1.stmts₁_selfₓ'. -/
theorem stmts₁_self {q} : q ∈ stmts₁ q := by
  cases q <;> apply_rules [Finset.mem_insert_self, Finset.mem_singleton_self]
#align turing.TM1.stmts₁_self Turing.TM1.stmts₁_self

/- warning: turing.TM1.stmts₁_trans -> Turing.TM1.stmts₁_trans is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} {σ : Type.{u3}} {q₁ : Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ} {q₂ : Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ}, (Membership.Mem.{max u1 u2 u3, max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ) (Finset.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) (Finset.hasMem.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) q₁ (Turing.TM1.stmts₁.{u1, u2, u3} Γ _inst_1 Λ σ q₂)) -> (HasSubset.Subset.{max u1 u2 u3} (Finset.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) (Finset.hasSubset.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) (Turing.TM1.stmts₁.{u1, u2, u3} Γ _inst_1 Λ σ q₁) (Turing.TM1.stmts₁.{u1, u2, u3} Γ _inst_1 Λ σ q₂))
but is expected to have type
  forall {Γ : Type.{u3}} {_inst_1 : Type.{u2}} {Λ : Type.{u1}} {σ : Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ} {q₁ : Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ}, (Membership.mem.{max (max u3 u2) u1, max (max u1 u2) u3} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ) (Finset.{max (max u1 u2) u3} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ)) (Finset.instMembershipFinset.{max (max u3 u2) u1} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ)) σ (Turing.TM1.stmts₁.{u3, u2, u1} Γ _inst_1 Λ q₁)) -> (HasSubset.Subset.{max (max u1 u2) u3} (Finset.{max (max u1 u2) u3} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ)) (Finset.instHasSubsetFinset.{max (max u3 u2) u1} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ)) (Turing.TM1.stmts₁.{u3, u2, u1} Γ _inst_1 Λ σ) (Turing.TM1.stmts₁.{u3, u2, u1} Γ _inst_1 Λ q₁))
Case conversion may be inaccurate. Consider using '#align turing.TM1.stmts₁_trans Turing.TM1.stmts₁_transₓ'. -/
theorem stmts₁_trans {q₁ q₂} : q₁ ∈ stmts₁ q₂ → stmts₁ q₁ ⊆ stmts₁ q₂ :=
  by
  intro h₁₂ q₀ h₀₁
  induction' q₂ with _ q IH _ q IH _ q IH <;> simp only [stmts₁] at h₁₂⊢ <;>
    simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at h₁₂
  iterate 3 
    rcases h₁₂ with (rfl | h₁₂)
    · unfold stmts₁ at h₀₁
      exact h₀₁
    · exact Finset.mem_insert_of_mem (IH h₁₂)
  case branch p q₁ q₂ IH₁ IH₂ =>
    rcases h₁₂ with (rfl | h₁₂ | h₁₂)
    · unfold stmts₁ at h₀₁
      exact h₀₁
    · exact Finset.mem_insert_of_mem (Finset.mem_union_left _ <| IH₁ h₁₂)
    · exact Finset.mem_insert_of_mem (Finset.mem_union_right _ <| IH₂ h₁₂)
  case goto l => subst h₁₂; exact h₀₁
  case halt => subst h₁₂; exact h₀₁
#align turing.TM1.stmts₁_trans Turing.TM1.stmts₁_trans

/- warning: turing.TM1.stmts₁_supports_stmt_mono -> Turing.TM1.stmts₁_supportsStmt_mono is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} {σ : Type.{u3}} {S : Finset.{u2} Λ} {q₁ : Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ} {q₂ : Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ}, (Membership.Mem.{max u1 u2 u3, max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ) (Finset.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) (Finset.hasMem.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) q₁ (Turing.TM1.stmts₁.{u1, u2, u3} Γ _inst_1 Λ σ q₂)) -> (Turing.TM1.SupportsStmt.{u1, u2, u3} Γ _inst_1 Λ σ S q₂) -> (Turing.TM1.SupportsStmt.{u1, u2, u3} Γ _inst_1 Λ σ S q₁)
but is expected to have type
  forall {Γ : Type.{u2}} {_inst_1 : Type.{u3}} {Λ : Type.{u1}} {σ : Finset.{u3} _inst_1} {S : Turing.TM1.Stmt.{u2, u3, u1} Γ _inst_1 Λ} {q₁ : Turing.TM1.Stmt.{u2, u3, u1} Γ _inst_1 Λ}, (Membership.mem.{max (max u2 u3) u1, max (max u1 u3) u2} (Turing.TM1.Stmt.{u2, u3, u1} Γ _inst_1 Λ) (Finset.{max (max u1 u3) u2} (Turing.TM1.Stmt.{u2, u3, u1} Γ _inst_1 Λ)) (Finset.instMembershipFinset.{max (max u2 u3) u1} (Turing.TM1.Stmt.{u2, u3, u1} Γ _inst_1 Λ)) S (Turing.TM1.stmts₁.{u2, u3, u1} Γ _inst_1 Λ q₁)) -> (Turing.TM1.SupportsStmt.{u2, u3, u1} Γ _inst_1 Λ σ q₁) -> (Turing.TM1.SupportsStmt.{u2, u3, u1} Γ _inst_1 Λ σ S)
Case conversion may be inaccurate. Consider using '#align turing.TM1.stmts₁_supports_stmt_mono Turing.TM1.stmts₁_supportsStmt_monoₓ'. -/
theorem stmts₁_supportsStmt_mono {S q₁ q₂} (h : q₁ ∈ stmts₁ q₂) (hs : supports_stmt S q₂) :
    supports_stmt S q₁ :=
  by
  induction' q₂ with _ q IH _ q IH _ q IH <;>
    simp only [stmts₁, supports_stmt, Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at
      h hs
  iterate 3 rcases h with (rfl | h) <;> [exact hs, exact IH h hs]
  case branch p q₁ q₂ IH₁ IH₂ => rcases h with (rfl | h | h); exacts[hs, IH₁ h hs.1, IH₂ h hs.2]
  case goto l => subst h; exact hs
  case halt => subst h; trivial
#align turing.TM1.stmts₁_supports_stmt_mono Turing.TM1.stmts₁_supportsStmt_mono

/- warning: turing.TM1.stmts -> Turing.TM1.stmts is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} {σ : Type.{u3}}, (Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) -> (Finset.{u2} Λ) -> (Finset.{max u1 u2 u3} (Option.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)))
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}}, (_inst_1 -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ)) -> (Finset.{u2} _inst_1) -> (Finset.{max (max u3 u2) u1} (Option.{max (max u3 u2) u1} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ)))
Case conversion may be inaccurate. Consider using '#align turing.TM1.stmts Turing.TM1.stmtsₓ'. -/
/-- The set of all statements in a turing machine, plus one extra value `none` representing the
halt state. This is used in the TM1 to TM0 reduction. -/
noncomputable def stmts (M : Λ → stmt) (S : Finset Λ) : Finset (Option stmt) :=
  (S.biUnion fun q => stmts₁ (M q)).insertNone
#align turing.TM1.stmts Turing.TM1.stmts

/- warning: turing.TM1.stmts_trans -> Turing.TM1.stmts_trans is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} {σ : Type.{u3}} {M : Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)} {S : Finset.{u2} Λ} {q₁ : Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ} {q₂ : Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ}, (Membership.Mem.{max u1 u2 u3, max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ) (Finset.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) (Finset.hasMem.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) q₁ (Turing.TM1.stmts₁.{u1, u2, u3} Γ _inst_1 Λ σ q₂)) -> (Membership.Mem.{max u1 u2 u3, max u1 u2 u3} (Option.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) (Finset.{max u1 u2 u3} (Option.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ))) (Finset.hasMem.{max u1 u2 u3} (Option.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ))) (Option.some.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ) q₂) (Turing.TM1.stmts.{u1, u2, u3} Γ _inst_1 Λ σ M S)) -> (Membership.Mem.{max u1 u2 u3, max u1 u2 u3} (Option.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) (Finset.{max u1 u2 u3} (Option.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ))) (Finset.hasMem.{max u1 u2 u3} (Option.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ))) (Option.some.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ) q₁) (Turing.TM1.stmts.{u1, u2, u3} Γ _inst_1 Λ σ M S))
but is expected to have type
  forall {Γ : Type.{u3}} {_inst_1 : Type.{u2}} {Λ : Type.{u1}} {σ : _inst_1 -> (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ)} {M : Finset.{u2} _inst_1} {S : Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ} {q₁ : Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ}, (Membership.mem.{max (max u3 u2) u1, max (max u1 u2) u3} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ) (Finset.{max (max u1 u2) u3} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ)) (Finset.instMembershipFinset.{max (max u3 u2) u1} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ)) S (Turing.TM1.stmts₁.{u3, u2, u1} Γ _inst_1 Λ q₁)) -> (Membership.mem.{max (max u3 u2) u1, max (max u1 u2) u3} (Option.{max (max u3 u2) u1} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ)) (Finset.{max (max u1 u2) u3} (Option.{max (max u1 u2) u3} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ))) (Finset.instMembershipFinset.{max (max u3 u2) u1} (Option.{max (max u1 u2) u3} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ))) (Option.some.{max (max u3 u2) u1} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ) q₁) (Turing.TM1.stmts.{u3, u2, u1} Γ _inst_1 Λ σ M)) -> (Membership.mem.{max (max u3 u2) u1, max (max u1 u2) u3} (Option.{max (max u3 u2) u1} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ)) (Finset.{max (max u1 u2) u3} (Option.{max (max u1 u2) u3} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ))) (Finset.instMembershipFinset.{max (max u3 u2) u1} (Option.{max (max u1 u2) u3} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ))) (Option.some.{max (max u3 u2) u1} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ) S) (Turing.TM1.stmts.{u3, u2, u1} Γ _inst_1 Λ σ M))
Case conversion may be inaccurate. Consider using '#align turing.TM1.stmts_trans Turing.TM1.stmts_transₓ'. -/
theorem stmts_trans {M : Λ → stmt} {S q₁ q₂} (h₁ : q₁ ∈ stmts₁ q₂) :
    some q₂ ∈ stmts M S → some q₁ ∈ stmts M S := by
  simp only [stmts, Finset.mem_insertNone, Finset.mem_biUnion, Option.mem_def, forall_eq',
      exists_imp] <;>
    exact fun l ls h₂ => ⟨_, ls, stmts₁_trans h₂ h₁⟩
#align turing.TM1.stmts_trans Turing.TM1.stmts_trans

variable [Inhabited Λ]

/- warning: turing.TM1.supports -> Turing.TM1.Supports is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} {σ : Type.{u3}} [_inst_2 : Inhabited.{succ u2} Λ], (Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) -> (Finset.{u2} Λ) -> Prop
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}} [σ : Inhabited.{succ u2} _inst_1], (_inst_1 -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ)) -> (Finset.{u2} _inst_1) -> Prop
Case conversion may be inaccurate. Consider using '#align turing.TM1.supports Turing.TM1.Supportsₓ'. -/
/-- A set `S` of labels supports machine `M` if all the `goto`
  statements in the functions in `S` refer only to other functions
  in `S`. -/
def Supports (M : Λ → stmt) (S : Finset Λ) :=
  default ∈ S ∧ ∀ q ∈ S, supports_stmt S (M q)
#align turing.TM1.supports Turing.TM1.Supports

/- warning: turing.TM1.stmts_supports_stmt -> Turing.TM1.stmts_supportsStmt is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} {σ : Type.{u3}} [_inst_2 : Inhabited.{succ u2} Λ] {M : Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)} {S : Finset.{u2} Λ} {q : Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ}, (Turing.TM1.Supports.{u1, u2, u3} Γ _inst_1 Λ σ _inst_2 M S) -> (Membership.Mem.{max u1 u2 u3, max u1 u2 u3} (Option.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) (Finset.{max u1 u2 u3} (Option.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ))) (Finset.hasMem.{max u1 u2 u3} (Option.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ))) (Option.some.{max u1 u2 u3} (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ) q) (Turing.TM1.stmts.{u1, u2, u3} Γ _inst_1 Λ σ M S)) -> (Turing.TM1.SupportsStmt.{u1, u2, u3} Γ _inst_1 Λ σ S q)
but is expected to have type
  forall {Γ : Type.{u3}} {_inst_1 : Type.{u2}} {Λ : Type.{u1}} [σ : Inhabited.{succ u2} _inst_1] {_inst_2 : _inst_1 -> (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ)} {M : Finset.{u2} _inst_1} {S : Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ}, (Turing.TM1.Supports.{u3, u2, u1} Γ _inst_1 Λ σ _inst_2 M) -> (Membership.mem.{max (max u3 u2) u1, max (max u1 u2) u3} (Option.{max (max u3 u2) u1} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ)) (Finset.{max (max u1 u2) u3} (Option.{max (max u1 u2) u3} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ))) (Finset.instMembershipFinset.{max (max u3 u2) u1} (Option.{max (max u1 u2) u3} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ))) (Option.some.{max (max u3 u2) u1} (Turing.TM1.Stmt.{u3, u2, u1} Γ _inst_1 Λ) S) (Turing.TM1.stmts.{u3, u2, u1} Γ _inst_1 Λ _inst_2 M)) -> (Turing.TM1.SupportsStmt.{u3, u2, u1} Γ _inst_1 Λ M S)
Case conversion may be inaccurate. Consider using '#align turing.TM1.stmts_supports_stmt Turing.TM1.stmts_supportsStmtₓ'. -/
theorem stmts_supportsStmt {M : Λ → stmt} {S q} (ss : supports M S) :
    some q ∈ stmts M S → supports_stmt S q := by
  simp only [stmts, Finset.mem_insertNone, Finset.mem_biUnion, Option.mem_def, forall_eq',
      exists_imp] <;>
    exact fun l ls h => stmts₁_supports_stmt_mono h (ss.2 _ ls)
#align turing.TM1.stmts_supports_stmt Turing.TM1.stmts_supportsStmt

/- warning: turing.TM1.step_supports -> Turing.TM1.step_supports is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} {σ : Type.{u3}} [_inst_2 : Inhabited.{succ u2} Λ] (M : Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) {S : Finset.{u2} Λ}, (Turing.TM1.Supports.{u1, u2, u3} Γ _inst_1 Λ σ _inst_2 M S) -> (forall {c : Turing.TM1.Cfg.{u1, u2, u3} Γ _inst_1 Λ σ} {c' : Turing.TM1.Cfg.{u1, u2, u3} Γ _inst_1 Λ σ}, (Membership.Mem.{max u1 u2 u3, max u1 u2 u3} (Turing.TM1.Cfg.{u1, u2, u3} Γ _inst_1 Λ σ) (Option.{max u1 u2 u3} (Turing.TM1.Cfg.{u1, u2, u3} Γ _inst_1 Λ σ)) (Option.hasMem.{max u1 u2 u3} (Turing.TM1.Cfg.{u1, u2, u3} Γ _inst_1 Λ σ)) c' (Turing.TM1.step.{u1, u2, u3} Γ _inst_1 Λ σ M c)) -> (Membership.Mem.{u2, u2} (Option.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (Finset.hasMem.{u2} (Option.{u2} Λ)) (Turing.TM1.Cfg.l.{u1, u2, u3} Γ _inst_1 Λ σ c) (coeFn.{succ u2, succ u2} (OrderEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ))))) (fun (_x : RelEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (LE.le.{u2} (Finset.{u2} Λ) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ)))) (LE.le.{u2} (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ)))))) => (Finset.{u2} Λ) -> (Finset.{u2} (Option.{u2} Λ))) (RelEmbedding.hasCoeToFun.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (LE.le.{u2} (Finset.{u2} Λ) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ)))) (LE.le.{u2} (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ)))))) (Finset.insertNone.{u2} Λ) S)) -> (Membership.Mem.{u2, u2} (Option.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (Finset.hasMem.{u2} (Option.{u2} Λ)) (Turing.TM1.Cfg.l.{u1, u2, u3} Γ _inst_1 Λ σ c') (coeFn.{succ u2, succ u2} (OrderEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ))))) (fun (_x : RelEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (LE.le.{u2} (Finset.{u2} Λ) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ)))) (LE.le.{u2} (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ)))))) => (Finset.{u2} Λ) -> (Finset.{u2} (Option.{u2} Λ))) (RelEmbedding.hasCoeToFun.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (LE.le.{u2} (Finset.{u2} Λ) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ)))) (LE.le.{u2} (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ)))))) (Finset.insertNone.{u2} Λ) S)))
but is expected to have type
  forall {Γ : Type.{u3}} [_inst_1 : Inhabited.{succ u3} Γ] {Λ : Type.{u2}} {σ : Type.{u1}} [_inst_2 : Inhabited.{succ u2} Λ] (M : Λ -> (Turing.TM1.Stmt.{u3, u2, u1} Γ Λ σ)) {S : Finset.{u2} Λ}, (Turing.TM1.Supports.{u3, u2, u1} Γ Λ σ _inst_2 M S) -> (forall {c : Turing.TM1.Cfg.{u3, u2, u1} Γ _inst_1 Λ σ} {c' : Turing.TM1.Cfg.{u3, u2, u1} Γ _inst_1 Λ σ}, (Membership.mem.{max (max u3 u2) u1, max (max u1 u2) u3} (Turing.TM1.Cfg.{u3, u2, u1} Γ _inst_1 Λ σ) (Option.{max (max u1 u2) u3} (Turing.TM1.Cfg.{u3, u2, u1} Γ _inst_1 Λ σ)) (Option.instMembershipOption.{max (max u3 u2) u1} (Turing.TM1.Cfg.{u3, u2, u1} Γ _inst_1 Λ σ)) c' (Turing.TM1.step.{u3, u2, u1} Γ _inst_1 Λ σ M c)) -> (Membership.mem.{u2, u2} (Option.{u2} Λ) ((fun (x._@.Mathlib.Order.RelIso.Basic._hyg.867 : Finset.{u2} Λ) => Finset.{u2} (Option.{u2} Λ)) S) (Finset.instMembershipFinset.{u2} (Option.{u2} Λ)) (Turing.TM1.Cfg.l.{u3, u2, u1} Γ _inst_1 Λ σ c) (FunLike.coe.{succ u2, succ u2, succ u2} (OrderEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ))))) (Finset.{u2} Λ) (fun (_x : Finset.{u2} Λ) => (fun (x._@.Mathlib.Order.RelIso.Basic._hyg.867 : Finset.{u2} Λ) => Finset.{u2} (Option.{u2} Λ)) _x) (RelHomClass.toFunLike.{u2, u2, u2} (OrderEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ))))) (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : Finset.{u2} Λ) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : Finset.{u2} Λ) => LE.le.{u2} (Finset.{u2} Λ) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Finset.{u2} (Option.{u2} Λ)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Finset.{u2} (Option.{u2} Λ)) => LE.le.{u2} (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ)))) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (RelEmbedding.instRelHomClassRelEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : Finset.{u2} Λ) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : Finset.{u2} Λ) => LE.le.{u2} (Finset.{u2} Λ) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Finset.{u2} (Option.{u2} Λ)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Finset.{u2} (Option.{u2} Λ)) => LE.le.{u2} (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ)))) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697))) (Finset.insertNone.{u2} Λ) S)) -> (Membership.mem.{u2, u2} (Option.{u2} Λ) ((fun (x._@.Mathlib.Order.RelIso.Basic._hyg.867 : Finset.{u2} Λ) => Finset.{u2} (Option.{u2} Λ)) S) (Finset.instMembershipFinset.{u2} (Option.{u2} Λ)) (Turing.TM1.Cfg.l.{u3, u2, u1} Γ _inst_1 Λ σ c') (FunLike.coe.{succ u2, succ u2, succ u2} (OrderEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ))))) (Finset.{u2} Λ) (fun (_x : Finset.{u2} Λ) => (fun (x._@.Mathlib.Order.RelIso.Basic._hyg.867 : Finset.{u2} Λ) => Finset.{u2} (Option.{u2} Λ)) _x) (RelHomClass.toFunLike.{u2, u2, u2} (OrderEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ))))) (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : Finset.{u2} Λ) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : Finset.{u2} Λ) => LE.le.{u2} (Finset.{u2} Λ) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Finset.{u2} (Option.{u2} Λ)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Finset.{u2} (Option.{u2} Λ)) => LE.le.{u2} (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ)))) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (RelEmbedding.instRelHomClassRelEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : Finset.{u2} Λ) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : Finset.{u2} Λ) => LE.le.{u2} (Finset.{u2} Λ) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Finset.{u2} (Option.{u2} Λ)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Finset.{u2} (Option.{u2} Λ)) => LE.le.{u2} (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ)))) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697))) (Finset.insertNone.{u2} Λ) S)))
Case conversion may be inaccurate. Consider using '#align turing.TM1.step_supports Turing.TM1.step_supportsₓ'. -/
theorem step_supports (M : Λ → stmt) {S} (ss : supports M S) :
    ∀ {c c' : cfg}, c' ∈ step M c → c.l ∈ S.insertNone → c'.l ∈ S.insertNone
  | ⟨some l₁, v, T⟩, c', h₁, h₂ =>
    by
    replace h₂ := ss.2 _ (Finset.some_mem_insertNone.1 h₂)
    simp only [step, Option.mem_def] at h₁; subst c'
    revert h₂; induction' M l₁ with _ q IH _ q IH _ q IH generalizing v T <;> intro hs
    iterate 3 exact IH _ _ hs
    case branch p q₁' q₂' IH₁ IH₂ =>
      unfold step_aux; cases p T.1 v
      · exact IH₂ _ _ hs.2
      · exact IH₁ _ _ hs.1
    case goto => exact Finset.some_mem_insertNone.2 (hs _ _)
    case halt => apply Multiset.mem_cons_self
#align turing.TM1.step_supports Turing.TM1.step_supports

variable [Inhabited σ]

#print Turing.TM1.init /-
/-- The initial state, given a finite input that is placed on the tape starting at the TM head and
going to the right. -/
def init (l : List Γ) : cfg :=
  ⟨some default, default, Tape.mk₁ l⟩
#align turing.TM1.init Turing.TM1.init
-/

#print Turing.TM1.eval /-
/-- Evaluate a TM to completion, resulting in an output list on the tape (with an indeterminate
number of blanks on the end). -/
def eval (M : Λ → stmt) (l : List Γ) : Part (ListBlank Γ) :=
  (eval (step M) (init l)).map fun c => c.Tape.right₀
#align turing.TM1.eval Turing.TM1.eval
-/

end

end TM1

/-!
## TM1 emulator in TM0

To prove that TM1 computable functions are TM0 computable, we need to reduce each TM1 program to a
TM0 program. So suppose a TM1 program is given. We take the following:

* The alphabet `Γ` is the same for both TM1 and TM0
* The set of states `Λ'` is defined to be `option stmt₁ × σ`, that is, a TM1 statement or `none`
  representing halt, and the possible settings of the internal variables.
  Note that this is an infinite set, because `stmt₁` is infinite. This is okay because we assume
  that from the initial TM1 state, only finitely many other labels are reachable, and there are
  only finitely many statements that appear in all of these functions.

Even though `stmt₁` contains a statement called `halt`, we must separate it from `none`
(`some halt` steps to `none` and `none` actually halts) because there is a one step stutter in the
TM1 semantics.
-/


namespace TM1to0

section

parameter {Γ : Type _}[Inhabited Γ]

parameter {Λ : Type _}[Inhabited Λ]

parameter {σ : Type _}[Inhabited σ]

-- mathport name: exprstmt₁
local notation "stmt₁" => TM1.Stmt Γ Λ σ

-- mathport name: exprcfg₁
local notation "cfg₁" => TM1.Cfg Γ Λ σ

-- mathport name: exprstmt₀
local notation "stmt₀" => TM0.Stmt Γ

parameter (M : Λ → stmt₁)

include M

/- warning: turing.TM1to0.Λ' -> Turing.TM1to0.Λ' is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ], (Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) -> Sort.{max (succ (max u1 u2 u3)) (succ u3)}
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}}, (_inst_1 -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ)) -> Sort.{max (succ (max (max u3 u2) u1)) (succ u3)}
Case conversion may be inaccurate. Consider using '#align turing.TM1to0.Λ' Turing.TM1to0.Λ'ₓ'. -/
-- [inhabited Λ] [inhabited σ] (M : Λ → stmt₁): We need the M assumption
-- because of the inhabited instance, but we could avoid the inhabited instances on Λ and σ here.
-- But they are parameters so we cannot easily skip them for just this definition.
/-- The base machine state space is a pair of an `option stmt₁` representing the current program
to be executed, or `none` for the halt state, and a `σ` which is the local state (stored in the TM,
not the tape). Because there are an infinite number of programs, this state space is infinite, but
for a finitely supported TM1 machine and a finite type `σ`, only finitely many of these states are
reachable. -/
@[nolint unused_arguments]
def Λ' :=
  Option stmt₁ × σ
#align turing.TM1to0.Λ' Turing.TM1to0.Λ'

instance : Inhabited Λ' :=
  ⟨(some (M default), default)⟩

open TM0.Stmt

/- warning: turing.TM1to0.tr_aux -> Turing.TM1to0.trAux is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] (M : Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)), Γ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ) -> σ -> (Prod.{max (max u1 u2 u3) u3, u1} (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M) (Turing.TM0.Stmt.{u1} Γ _inst_1))
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}} (_inst_2 : _inst_1 -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ)), Γ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ) -> Λ -> (Prod.{max (max u3 u2) u1, u1} (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2) (Turing.TM0.Stmt.{u1} Γ))
Case conversion may be inaccurate. Consider using '#align turing.TM1to0.tr_aux Turing.TM1to0.trAuxₓ'. -/
/-- The core TM1 → TM0 translation function. Here `s` is the current value on the tape, and the
`stmt₁` is the TM1 statement to translate, with local state `v : σ`. We evaluate all regular
instructions recursively until we reach either a `move` or `write` command, or a `goto`; in the
latter case we emit a dummy `write s` step and transition to the new target location. -/
def trAux (s : Γ) : stmt₁ → σ → Λ' × stmt₀
  | TM1.stmt.move d q, v => ((some q, v), move d)
  | TM1.stmt.write a q, v => ((some q, v), write (a s v))
  | TM1.stmt.load a q, v => tr_aux q (a s v)
  | TM1.stmt.branch p q₁ q₂, v => cond (p s v) (tr_aux q₁ v) (tr_aux q₂ v)
  | TM1.stmt.goto l, v => ((some (M (l s v)), v), write s)
  | TM1.stmt.halt, v => ((none, v), write s)
#align turing.TM1to0.tr_aux Turing.TM1to0.trAux

-- mathport name: exprcfg₀
local notation "cfg₀" => TM0.Cfg Γ Λ'

/- warning: turing.TM1to0.tr -> Turing.TM1to0.tr is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] (M : Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)), Turing.TM0.Machine.{u1, max (max u1 u2 u3) u3} Γ _inst_1 (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M) (Turing.TM1to0.Λ'.inhabited.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M)
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} [Λ : Inhabited.{succ u2} _inst_1] {_inst_2 : Type.{u3}} [σ : Inhabited.{succ u3} _inst_2] (_inst_3 : _inst_1 -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 _inst_2)), Turing.TM0.Machine.{u1, max (max u3 u2) u1} Γ (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 _inst_2 _inst_3) (Turing.TM1to0.instInhabitedΛ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3)
Case conversion may be inaccurate. Consider using '#align turing.TM1to0.tr Turing.TM1to0.trₓ'. -/
/-- The translated TM0 machine (given the TM1 machine input). -/
def tr : TM0.Machine Γ Λ'
  | (none, v), s => none
  | (some q, v), s => some (tr_aux s q v)
#align turing.TM1to0.tr Turing.TM1to0.tr

/- warning: turing.TM1to0.tr_cfg -> Turing.TM1to0.trCfg is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] (M : Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)), (Turing.TM1.Cfg.{u1, u2, u3} Γ _inst_1 Λ σ) -> (Turing.TM0.Cfg.{u1, max (max u1 u2 u3) u3} Γ _inst_1 (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M) (Turing.TM1to0.Λ'.inhabited.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M))
but is expected to have type
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} {_inst_2 : Type.{u3}} (σ : Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ Λ _inst_2)), (Turing.TM1.Cfg.{u1, u2, u3} Γ _inst_1 Λ _inst_2) -> (Turing.TM0.Cfg.{u1, max (max u3 u2) u1} Γ _inst_1 (Turing.TM1to0.Λ'.{u1, u2, u3} Γ Λ _inst_2 σ))
Case conversion may be inaccurate. Consider using '#align turing.TM1to0.tr_cfg Turing.TM1to0.trCfgₓ'. -/
/-- Translate configurations from TM1 to TM0. -/
def trCfg : cfg₁ → cfg₀
  | ⟨l, v, T⟩ => ⟨(l.map M, v), T⟩
#align turing.TM1to0.tr_cfg Turing.TM1to0.trCfg

#print Turing.TM1to0.tr_respects /-
theorem tr_respects : Respects (TM1.step M) (TM0.step tr) fun c₁ c₂ => tr_cfg c₁ = c₂ :=
  fun_respects.2 fun ⟨l₁, v, T⟩ => by
    cases' l₁ with l₁; · exact rfl
    unfold tr_cfg TM1.step frespects Option.map Function.comp Option.bind
    induction' M l₁ with _ q IH _ q IH _ q IH generalizing v T
    case move d q IH => exact trans_gen.head rfl (IH _ _)
    case write a q IH => exact trans_gen.head rfl (IH _ _)
    case load a q IH => exact (reaches₁_eq (by rfl)).2 (IH _ _)
    case branch p q₁ q₂ IH₁ IH₂ =>
      unfold TM1.step_aux; cases e : p T.1 v
      · exact (reaches₁_eq (by simp only [TM0.step, tr, tr_aux, e] <;> rfl)).2 (IH₂ _ _)
      · exact (reaches₁_eq (by simp only [TM0.step, tr, tr_aux, e] <;> rfl)).2 (IH₁ _ _)
    iterate 2
      exact trans_gen.single (congr_arg some (congr (congr_arg TM0.cfg.mk rfl) (tape.write_self T)))
#align turing.TM1to0.tr_respects Turing.TM1to0.tr_respects
-/

/- warning: turing.TM1to0.tr_eval -> Turing.TM1to0.tr_eval is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] (M : Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) (l : List.{u1} Γ), Eq.{succ u1} (Part.{u1} (Turing.ListBlank.{u1} Γ _inst_1)) (Turing.TM0.eval.{u1, max (max u1 u2 u3) u3} Γ _inst_1 (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M) (Turing.TM1to0.Λ'.inhabited.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M) (Turing.TM1to0.tr.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M) l) (Turing.TM1.eval.{u1, u2, u3} Γ _inst_1 Λ σ _inst_2 _inst_3 M l)
but is expected to have type
  forall {Γ : Type.{u3}} [_inst_1 : Inhabited.{succ u3} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u1}} [_inst_3 : Inhabited.{succ u1} σ] (M : Λ -> (Turing.TM1.Stmt.{u3, u2, u1} Γ Λ σ)) (l : List.{u3} Γ), Eq.{succ u3} (Part.{u3} (Turing.ListBlank.{u3} Γ _inst_1)) (Turing.TM0.eval.{u3, max (max u3 u2) u1} Γ _inst_1 (Turing.TM1to0.Λ'.{u3, u2, u1} Γ Λ σ M) (Turing.TM1to0.instInhabitedΛ'.{u3, u2, u1} Γ Λ _inst_2 σ _inst_3 M) (Turing.TM1to0.tr.{u3, u2, u1} Γ Λ _inst_2 σ _inst_3 M) l) (Turing.TM1.eval.{u3, u2, u1} Γ _inst_1 Λ σ _inst_2 _inst_3 M l)
Case conversion may be inaccurate. Consider using '#align turing.TM1to0.tr_eval Turing.TM1to0.tr_evalₓ'. -/
theorem tr_eval (l : List Γ) : TM0.eval tr l = TM1.eval M l :=
  (congr_arg _ (tr_eval' _ _ _ tr_respects ⟨some _, _, _⟩)).trans
    (by
      rw [Part.map_eq_map, Part.map_map, TM1.eval]
      congr with ⟨⟩; rfl)
#align turing.TM1to0.tr_eval Turing.TM1to0.tr_eval

variable [Fintype σ]

/- warning: turing.TM1to0.tr_stmts -> Turing.TM1to0.trStmts is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] (M : Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) [_inst_4 : Fintype.{u3} σ], (Finset.{u2} Λ) -> (Finset.{max (max u1 u2 u3) u3} (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M))
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}} (_inst_2 : _inst_1 -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ)) [σ : Fintype.{u3} Λ], (Finset.{u2} _inst_1) -> (Finset.{max (max u3 u2) u1} (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2))
Case conversion may be inaccurate. Consider using '#align turing.TM1to0.tr_stmts Turing.TM1to0.trStmtsₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- Given a finite set of accessible `Λ` machine states, there is a finite set of accessible
machine states in the target (even though the type `Λ'` is infinite). -/
noncomputable def trStmts (S : Finset Λ) : Finset Λ' :=
  TM1.stmts M S ×ˢ Finset.univ
#align turing.TM1to0.tr_stmts Turing.TM1to0.trStmts

open Classical

attribute [local simp] TM1.stmts₁_self

/- warning: turing.TM1to0.tr_supports -> Turing.TM1to0.tr_supports is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] (M : Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) [_inst_4 : Fintype.{u3} σ] {S : Finset.{u2} Λ}, (Turing.TM1.Supports.{u1, u2, u3} Γ _inst_1 Λ σ _inst_2 M S) -> (Turing.TM0.Supports.{u1, max (max u1 u2 u3) u3} Γ _inst_1 (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M) (Turing.TM1to0.Λ'.inhabited.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M) (Turing.TM1to0.tr.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M) ((fun (a : Type.{max (max u1 u2 u3) u3}) (b : Type.{max (max u1 u2 u3) u3}) [self : HasLiftT.{succ (max (max u1 u2 u3) u3), succ (max (max u1 u2 u3) u3)} a b] => self.0) (Finset.{max (max u1 u2 u3) u3} (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M)) (Set.{max (max u1 u2 u3) u3} (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M)) (HasLiftT.mk.{succ (max (max u1 u2 u3) u3), succ (max (max u1 u2 u3) u3)} (Finset.{max (max u1 u2 u3) u3} (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M)) (Set.{max (max u1 u2 u3) u3} (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M)) (CoeTCₓ.coe.{succ (max (max u1 u2 u3) u3), succ (max (max u1 u2 u3) u3)} (Finset.{max (max u1 u2 u3) u3} (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M)) (Set.{max (max u1 u2 u3) u3} (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M)) (Finset.Set.hasCoeT.{max (max u1 u2 u3) u3} (Turing.TM1to0.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M)))) (Turing.TM1to0.trStmts.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M _inst_4 S)))
but is expected to have type
  forall {Γ : Type.{u2}} {_inst_1 : Type.{u3}} [Λ : Inhabited.{succ u3} _inst_1] {_inst_2 : Type.{u1}} [σ : Inhabited.{succ u1} _inst_2] (_inst_3 : _inst_1 -> (Turing.TM1.Stmt.{u2, u3, u1} Γ _inst_1 _inst_2)) [M : Fintype.{u1} _inst_2] {_inst_4 : Finset.{u3} _inst_1}, (Turing.TM1.Supports.{u2, u3, u1} Γ _inst_1 _inst_2 Λ _inst_3 _inst_4) -> (Turing.TM0.Supports.{u2, max (max u2 u3) u1} Γ (Turing.TM1to0.Λ'.{u2, u3, u1} Γ _inst_1 _inst_2 _inst_3) (Turing.TM1to0.instInhabitedΛ'.{u2, u3, u1} Γ _inst_1 Λ _inst_2 σ _inst_3) (Turing.TM1to0.tr.{u2, u3, u1} Γ _inst_1 Λ _inst_2 σ _inst_3) (Finset.toSet.{max (max u2 u3) u1} (Turing.TM1to0.Λ'.{u2, u3, u1} Γ _inst_1 _inst_2 _inst_3) (Turing.TM1to0.trStmts.{u2, u3, u1} Γ _inst_1 _inst_2 _inst_3 M _inst_4)))
Case conversion may be inaccurate. Consider using '#align turing.TM1to0.tr_supports Turing.TM1to0.tr_supportsₓ'. -/
theorem tr_supports {S : Finset Λ} (ss : TM1.Supports M S) : TM0.Supports tr ↑(tr_stmts S) :=
  ⟨Finset.mem_product.2
      ⟨Finset.some_mem_insertNone.2 (Finset.mem_biUnion.2 ⟨_, ss.1, TM1.stmts₁_self⟩),
        Finset.mem_univ _⟩,
    fun q a q' s h₁ h₂ => by
    rcases q with ⟨_ | q, v⟩; · cases h₁
    cases' q' with q' v';
    simp only [tr_stmts, Finset.mem_coe, Finset.mem_product, Finset.mem_univ, and_true_iff] at h₂⊢
    cases q'; · exact Multiset.mem_cons_self _ _
    simp only [tr, Option.mem_def] at h₁
    have := TM1.stmts_supports_stmt ss h₂
    revert this; induction q generalizing v <;> intro hs
    case move d q =>
      cases h₁; refine' TM1.stmts_trans _ h₂
      unfold TM1.stmts₁
      exact Finset.mem_insert_of_mem TM1.stmts₁_self
    case write b q =>
      cases h₁; refine' TM1.stmts_trans _ h₂
      unfold TM1.stmts₁
      exact Finset.mem_insert_of_mem TM1.stmts₁_self
    case load b q IH =>
      refine' IH (TM1.stmts_trans _ h₂) _ h₁ hs
      unfold TM1.stmts₁
      exact Finset.mem_insert_of_mem TM1.stmts₁_self
    case
      branch p q₁ q₂ IH₁ IH₂ =>
      change cond (p a v) _ _ = ((some q', v'), s) at h₁
      cases p a v
      · refine' IH₂ (TM1.stmts_trans _ h₂) _ h₁ hs.2
        unfold TM1.stmts₁
        exact Finset.mem_insert_of_mem (Finset.mem_union_right _ TM1.stmts₁_self)
      · refine' IH₁ (TM1.stmts_trans _ h₂) _ h₁ hs.1
        unfold TM1.stmts₁
        exact Finset.mem_insert_of_mem (Finset.mem_union_left _ TM1.stmts₁_self)
    case goto l => cases h₁;
      exact Finset.some_mem_insertNone.2 (Finset.mem_biUnion.2 ⟨_, hs _ _, TM1.stmts₁_self⟩)
    case halt => cases h₁⟩
#align turing.TM1to0.tr_supports Turing.TM1to0.tr_supports

end

end TM1to0

/-!
## TM1(Γ) emulator in TM1(bool)

The most parsimonious Turing machine model that is still Turing complete is `TM0` with `Γ = bool`.
Because our construction in the previous section reducing `TM1` to `TM0` doesn't change the
alphabet, we can do the alphabet reduction on `TM1` instead of `TM0` directly.

The basic idea is to use a bijection between `Γ` and a subset of `vector bool n`, where `n` is a
fixed constant. Each tape element is represented as a block of `n` bools. Whenever the machine
wants to read a symbol from the tape, it traverses over the block, performing `n` `branch`
instructions to each any of the `2^n` results.

For the `write` instruction, we have to use a `goto` because we need to follow a different code
path depending on the local state, which is not available in the TM1 model, so instead we jump to
a label computed using the read value and the local state, which performs the writing and returns
to normal execution.

Emulation overhead is `O(1)`. If not for the above `write` behavior it would be 1-1 because we are
exploiting the 0-step behavior of regular commands to avoid taking steps, but there are
nevertheless a bounded number of `write` calls between `goto` statements because TM1 statements are
finitely long.
-/


namespace TM1to1

open TM1

section

parameter {Γ : Type _}[Inhabited Γ]

#print Turing.TM1to1.exists_enc_dec /-
theorem exists_enc_dec [Fintype Γ] :
    ∃ (n : _)(enc : Γ → Vector Bool n)(dec : Vector Bool n → Γ),
      enc default = Vector.replicate n false ∧ ∀ a, dec (enc a) = a :=
  by
  letI := Classical.decEq Γ
  let n := Fintype.card Γ
  obtain ⟨F⟩ := Fintype.truncEquivFin Γ
  let G : Fin n ↪ Fin n → Bool :=
    ⟨fun a b => a = b, fun a b h =>
      Bool.of_decide_true <| (congr_fun h b).trans <| Bool.decide_true rfl⟩
  let H := (F.to_embedding.trans G).trans (Equiv.vectorEquivFin _ _).symm.toEmbedding
  classical
    let enc := H.set_value default (Vector.replicate n ff)
    exact ⟨_, enc, Function.invFun enc, H.set_value_eq _ _, Function.leftInverse_invFun enc.2⟩
#align turing.TM1to1.exists_enc_dec Turing.TM1to1.exists_enc_dec
-/

parameter {Λ : Type _}[Inhabited Λ]

parameter {σ : Type _}[Inhabited σ]

-- mathport name: exprstmt₁
local notation "stmt₁" => Stmt Γ Λ σ

-- mathport name: exprcfg₁
local notation "cfg₁" => Cfg Γ Λ σ

/- warning: turing.TM1to1.Λ' -> Turing.TM1to1.Λ' is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ], Type.{max u1 u2 u3}
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}}, Sort.{max (max (succ u1) (succ u2)) (succ u3)}
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.Λ' Turing.TM1to1.Λ'ₓ'. -/
/-- The configuration state of the TM. -/
inductive Λ' : Type max u_1 u_2 u_3
  | normal : Λ → Λ'
  | write : Γ → stmt₁ → Λ'
#align turing.TM1to1.Λ' Turing.TM1to1.Λ'

instance : Inhabited Λ' :=
  ⟨Λ'.normal default⟩

-- mathport name: exprstmt'
local notation "stmt'" => Stmt Bool Λ' σ

-- mathport name: exprcfg'
local notation "cfg'" => Cfg Bool Λ' σ

/- warning: turing.TM1to1.read_aux -> Turing.TM1to1.readAux is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] (n : Nat), ((Vector.{0} Bool n) -> (Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ)) -> (Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ)
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}} (_inst_2 : Nat), ((Vector.{0} Bool _inst_2) -> (Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ)) -> (Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ)
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.read_aux Turing.TM1to1.readAuxₓ'. -/
/-- Read a vector of length `n` from the tape. -/
def readAux : ∀ n, (Vector Bool n → stmt') → stmt'
  | 0, f => f Vector.nil
  | i + 1, f =>
    Stmt.branch (fun a s => a) (Stmt.move Dir.right <| read_aux i fun v => f (true ::ᵥ v))
      (Stmt.move Dir.right <| read_aux i fun v => f (false ::ᵥ v))
#align turing.TM1to1.read_aux Turing.TM1to1.readAux

parameter {n : ℕ}(enc : Γ → Vector Bool n)(dec : Vector Bool n → Γ)

/- warning: turing.TM1to1.move -> Turing.TM1to1.move is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {n : Nat}, Turing.Dir -> (Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ) -> (Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ)
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}} {_inst_2 : Nat}, Turing.Dir -> (Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ) -> (Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ)
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.move Turing.TM1to1.moveₓ'. -/
/-- A move left or right corresponds to `n` moves across the super-cell. -/
def move (d : Dir) (q : stmt') : stmt' :=
  (Stmt.move d^[n]) q
#align turing.TM1to1.move Turing.TM1to1.move

/- warning: turing.TM1to1.read -> Turing.TM1to1.read is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {n : Nat}, ((Vector.{0} Bool n) -> Γ) -> (Γ -> (Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ)) -> (Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ)
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}} {_inst_2 : Nat}, ((Vector.{0} Bool _inst_2) -> Γ) -> (Γ -> (Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ)) -> (Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ)
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.read Turing.TM1to1.readₓ'. -/
/-- To read a symbol from the tape, we use `read_aux` to traverse the symbol,
then return to the original position with `n` moves to the left. -/
def read (f : Γ → stmt') : stmt' :=
  read_aux n fun v => move Dir.left <| f (dec v)
#align turing.TM1to1.read Turing.TM1to1.read

/- warning: turing.TM1to1.write -> Turing.TM1to1.write is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ], (List.{0} Bool) -> (Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ) -> (Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ)
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}}, (List.{0} Bool) -> (Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ) -> (Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ)
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.write Turing.TM1to1.writeₓ'. -/
/-- Write a list of bools on the tape. -/
def write : List Bool → stmt' → stmt'
  | [], q => q
  | a :: l, q => (Stmt.write fun _ _ => a) <| Stmt.move Dir.right <| write l q
#align turing.TM1to1.write Turing.TM1to1.write

/- warning: turing.TM1to1.tr_normal -> Turing.TM1to1.trNormal is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {n : Nat}, ((Vector.{0} Bool n) -> Γ) -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ) -> (Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ)
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}} {_inst_2 : Nat}, ((Vector.{0} Bool _inst_2) -> Γ) -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ) -> (Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ)
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.tr_normal Turing.TM1to1.trNormalₓ'. -/
/-- Translate a normal instruction. For the `write` command, we use a `goto` indirection so that
we can access the current value of the tape. -/
def trNormal : stmt₁ → stmt'
  | stmt.move d q => move d <| tr_normal q
  | stmt.write f q => read fun a => Stmt.goto fun _ s => Λ'.write (f a s) q
  | stmt.load f q => read fun a => (Stmt.load fun _ s => f a s) <| tr_normal q
  | stmt.branch p q₁ q₂ =>
    read fun a => Stmt.branch (fun _ s => p a s) (tr_normal q₁) (tr_normal q₂)
  | stmt.goto l => read fun a => Stmt.goto fun _ s => Λ'.normal (l a s)
  | stmt.halt => Stmt.halt
#align turing.TM1to1.tr_normal Turing.TM1to1.trNormal

/- warning: turing.TM1to1.step_aux_move -> Turing.TM1to1.stepAux_move is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {n : Nat} (d : Turing.Dir) (q : Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ) (v : σ) (T : Turing.Tape.{0} Bool Bool.inhabited), Eq.{max 1 (succ (max u1 u2 u3)) (succ u3)} (Turing.TM1.Cfg.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ) (Turing.TM1.stepAux.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ (Turing.TM1to1.move.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 n d q) v T) (Turing.TM1.stepAux.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ q v (Nat.iterate.{1} (Turing.Tape.{0} Bool Bool.inhabited) (Turing.Tape.move.{0} Bool Bool.inhabited d) n T))
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}} {_inst_2 : Nat} (σ : Turing.Dir) (_inst_3 : Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ) (n : Λ) (d : Turing.Tape.{0} Bool instInhabitedBool), Eq.{max (max (succ u1) (succ u2)) (succ u3)} (Turing.TM1.Cfg.{0, max (max u1 u2) u3, u3} Bool instInhabitedBool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ) (Turing.TM1.stepAux.{0, max (max u1 u2) u3, u3} Bool instInhabitedBool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ (Turing.TM1to1.move.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) n d) (Turing.TM1.stepAux.{0, max (max u1 u2) u3, u3} Bool instInhabitedBool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ _inst_3 n (Nat.iterate.{1} (Turing.Tape.{0} Bool instInhabitedBool) (Turing.Tape.move.{0} Bool instInhabitedBool σ) _inst_2 d))
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.step_aux_move Turing.TM1to1.stepAux_moveₓ'. -/
theorem stepAux_move (d q v T) : stepAux (move d q) v T = stepAux q v ((Tape.move d^[n]) T) :=
  by
  suffices : ∀ i, step_aux ((stmt.move d^[i]) q) v T = step_aux q v ((tape.move d^[i]) T)
  exact this n
  intro ; induction' i with i IH generalizing T; · rfl
  rw [iterate_succ', step_aux, IH, iterate_succ]
#align turing.TM1to1.step_aux_move Turing.TM1to1.stepAux_move

/- warning: turing.TM1to1.supports_stmt_move -> Turing.TM1to1.supportsStmt_move is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {n : Nat} {S : Finset.{max u1 u2 u3} (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3)} {d : Turing.Dir} {q : Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ}, Eq.{1} Prop (Turing.TM1.SupportsStmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ S (Turing.TM1to1.move.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 n d q)) (Turing.TM1.SupportsStmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ S q)
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}} {_inst_2 : Nat} {σ : Finset.{max (max u3 u2) u1} (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ)} {_inst_3 : Turing.Dir} {n : Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ}, Eq.{1} Prop (Turing.TM1.SupportsStmt.{0, max (max u1 u2) u3, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ σ (Turing.TM1to1.move.{u1, u2, u3} Γ _inst_1 Λ _inst_2 _inst_3 n)) (Turing.TM1.SupportsStmt.{0, max (max u1 u2) u3, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ σ n)
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.supports_stmt_move Turing.TM1to1.supportsStmt_moveₓ'. -/
theorem supportsStmt_move {S d q} : SupportsStmt S (move d q) = SupportsStmt S q :=
  by
  suffices ∀ {i}, SupportsStmt S ((Stmt.move d^[i]) q) = _ from this
  intro <;> induction i generalizing q <;> simp only [*, iterate] <;> rfl
#align turing.TM1to1.supports_stmt_move Turing.TM1to1.supportsStmt_move

/- warning: turing.TM1to1.supports_stmt_write -> Turing.TM1to1.supportsStmt_write is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {S : Finset.{max u1 u2 u3} (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3)} {l : List.{0} Bool} {q : Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ}, Eq.{1} Prop (Turing.TM1.SupportsStmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ S (Turing.TM1to1.write.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 l q)) (Turing.TM1.SupportsStmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ S q)
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}} {_inst_2 : Finset.{max (max u3 u2) u1} (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ)} {σ : List.{0} Bool} {_inst_3 : Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ}, Eq.{1} Prop (Turing.TM1.SupportsStmt.{0, max (max u1 u2) u3, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ _inst_2 (Turing.TM1to1.write.{u1, u2, u3} Γ _inst_1 Λ σ _inst_3)) (Turing.TM1.SupportsStmt.{0, max (max u1 u2) u3, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ _inst_2 _inst_3)
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.supports_stmt_write Turing.TM1to1.supportsStmt_writeₓ'. -/
theorem supportsStmt_write {S l q} : SupportsStmt S (write l q) = SupportsStmt S q := by
  induction' l with a l IH <;> simp only [write, supports_stmt, *]
#align turing.TM1to1.supports_stmt_write Turing.TM1to1.supportsStmt_write

/- warning: turing.TM1to1.supports_stmt_read -> Turing.TM1to1.supportsStmt_read is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {n : Nat} (dec : (Vector.{0} Bool n) -> Γ) {S : Finset.{max u1 u2 u3} (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3)} {f : Γ -> (Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ)}, (forall (a : Γ), Turing.TM1.SupportsStmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ S (f a)) -> (Turing.TM1.SupportsStmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ S (Turing.TM1to1.read.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 n dec f))
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}} {_inst_2 : Nat} (σ : (Vector.{0} Bool _inst_2) -> Γ) {_inst_3 : Finset.{max (max u3 u2) u1} (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ)} {n : Γ -> (Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ)}, (forall (ᾰ : Γ), Turing.TM1.SupportsStmt.{0, max (max u1 u2) u3, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ _inst_3 (n ᾰ)) -> (Turing.TM1.SupportsStmt.{0, max (max u1 u2) u3, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ _inst_3 (Turing.TM1to1.read.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ n))
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.supports_stmt_read Turing.TM1to1.supportsStmt_readₓ'. -/
theorem supportsStmt_read {S} :
    ∀ {f : Γ → stmt'}, (∀ a, SupportsStmt S (f a)) → SupportsStmt S (read f) :=
  suffices
    ∀ (i) (f : Vector Bool i → stmt'), (∀ v, SupportsStmt S (f v)) → SupportsStmt S (read_aux i f)
    from fun f hf => this n _ (by intro <;> simp only [supports_stmt_move, hf])
  fun i f hf => by
  induction' i with i IH; · exact hf _
  constructor <;> apply IH <;> intro <;> apply hf
#align turing.TM1to1.supports_stmt_read Turing.TM1to1.supportsStmt_read

parameter (enc0 : enc default = Vector.replicate n false)

section

parameter {enc}

include enc0

#print Turing.TM1to1.trTape' /-
/-- The low level tape corresponding to the given tape over alphabet `Γ`. -/
def trTape' (L R : ListBlank Γ) : Tape Bool := by
  refine'
      tape.mk' (L.bind (fun x => (enc x).toList.reverse) ⟨n, _⟩)
        (R.bind (fun x => (enc x).toList) ⟨n, _⟩) <;>
    simp only [enc0, Vector.replicate, List.reverse_replicate, Bool.default_bool, Vector.toList_mk]
#align turing.TM1to1.tr_tape' Turing.TM1to1.trTape'
-/

#print Turing.TM1to1.trTape /-
/-- The low level tape corresponding to the given tape over alphabet `Γ`. -/
def trTape (T : Tape Γ) : Tape Bool :=
  tr_tape' T.left T.right₀
#align turing.TM1to1.tr_tape Turing.TM1to1.trTape
-/

#print Turing.TM1to1.trTape_mk' /-
theorem trTape_mk' (L R : ListBlank Γ) : tr_tape (Tape.mk' L R) = tr_tape' L R := by
  simp only [tr_tape, tape.mk'_left, tape.mk'_right₀]
#align turing.TM1to1.tr_tape_mk' Turing.TM1to1.trTape_mk'
-/

end

parameter (M : Λ → stmt₁)

/- warning: turing.TM1to1.tr -> Turing.TM1to1.tr is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {n : Nat}, (Γ -> (Vector.{0} Bool n)) -> ((Vector.{0} Bool n) -> Γ) -> (Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) -> (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) -> (Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ)
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}} {_inst_2 : Nat}, (Γ -> (Vector.{0} Bool _inst_2)) -> ((Vector.{0} Bool _inst_2) -> Γ) -> (_inst_1 -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ)) -> (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) -> (Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ) Λ)
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.tr Turing.TM1to1.trₓ'. -/
/-- The top level program. -/
def tr : Λ' → stmt'
  | Λ'.normal l => tr_normal (M l)
  | Λ'.write a q => write (enc a).toList <| move Dir.left <| tr_normal q
#align turing.TM1to1.tr Turing.TM1to1.tr

/- warning: turing.TM1to1.tr_cfg -> Turing.TM1to1.trCfg is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {n : Nat} {enc : Γ -> (Vector.{0} Bool n)}, (Eq.{1} (Vector.{0} Bool n) (enc (Inhabited.default.{succ u1} Γ _inst_1)) (Vector.replicate.{0} Bool n Bool.false)) -> (Turing.TM1.Cfg.{u1, u2, u3} Γ _inst_1 Λ σ) -> (Turing.TM1.Cfg.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ)
but is expected to have type
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} {_inst_2 : Type.{u3}} {σ : Nat} (_inst_3 : Γ -> (Vector.{0} Bool σ)), (Eq.{1} (Vector.{0} Bool σ) (_inst_3 (Inhabited.default.{succ u1} Γ _inst_1)) (Vector.replicate.{0} Bool σ Bool.false)) -> (Turing.TM1.Cfg.{u1, u2, u3} Γ _inst_1 Λ _inst_2) -> (Turing.TM1.Cfg.{0, max (max u3 u2) u1, u3} Bool instInhabitedBool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ Λ _inst_2) _inst_2)
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.tr_cfg Turing.TM1to1.trCfgₓ'. -/
/-- The machine configuration translation. -/
def trCfg : cfg₁ → cfg'
  | ⟨l, v, T⟩ => ⟨l.map Λ'.normal, v, tr_tape T⟩
#align turing.TM1to1.tr_cfg Turing.TM1to1.trCfg

parameter {enc}

include enc0

#print Turing.TM1to1.trTape'_move_left /-
theorem trTape'_move_left (L R) :
    (Tape.move Dir.left^[n]) (tr_tape' L R) = tr_tape' L.tail (R.cons L.headI) :=
  by
  obtain ⟨a, L, rfl⟩ := L.exists_cons
  simp only [tr_tape', list_blank.cons_bind, list_blank.head_cons, list_blank.tail_cons]
  suffices
    ∀ {L' R' l₁ l₂} (e : Vector.toList (enc a) = List.reverseAux l₁ l₂),
      (tape.move dir.left^[l₁.length])
          (tape.mk' (list_blank.append l₁ L') (list_blank.append l₂ R')) =
        tape.mk' L' (list_blank.append (Vector.toList (enc a)) R')
    by
    simpa only [List.length_reverse, Vector.toList_length] using this (List.reverse_reverse _).symm
  intros
  induction' l₁ with b l₁ IH generalizing l₂
  · cases e
    rfl
  simp only [List.length, List.cons_append, iterate_succ_apply]
  convert IH e
  simp only [list_blank.tail_cons, list_blank.append, tape.move_left_mk', list_blank.head_cons]
#align turing.TM1to1.tr_tape'_move_left Turing.TM1to1.trTape'_move_left
-/

#print Turing.TM1to1.trTape'_move_right /-
theorem trTape'_move_right (L R) :
    (Tape.move Dir.right^[n]) (tr_tape' L R) = tr_tape' (L.cons R.headI) R.tail :=
  by
  suffices ∀ i L, (tape.move dir.right^[i]) ((tape.move dir.left^[i]) L) = L
    by
    refine' (Eq.symm _).trans (this n _)
    simp only [tr_tape'_move_left, list_blank.cons_head_tail, list_blank.head_cons,
      list_blank.tail_cons]
  intros
  induction' i with i IH
  · rfl
  rw [iterate_succ_apply, iterate_succ_apply', tape.move_left_right, IH]
#align turing.TM1to1.tr_tape'_move_right Turing.TM1to1.trTape'_move_right
-/

/- warning: turing.TM1to1.step_aux_write -> Turing.TM1to1.stepAux_write is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {n : Nat} {enc : Γ -> (Vector.{0} Bool n)} (enc0 : Eq.{1} (Vector.{0} Bool n) (enc (Inhabited.default.{succ u1} Γ _inst_1)) (Vector.replicate.{0} Bool n Bool.false)) (q : Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ) (v : σ) (a : Γ) (b : Γ) (L : Turing.ListBlank.{u1} Γ _inst_1) (R : Turing.ListBlank.{u1} Γ _inst_1), Eq.{max 1 (succ (max u1 u2 u3)) (succ u3)} (Turing.TM1.Cfg.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ) (Turing.TM1.stepAux.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ (Turing.TM1to1.write.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 (Vector.toList.{0} Bool n (enc a)) q) v (Turing.TM1to1.trTape'.{u1} Γ _inst_1 n enc enc0 L (Turing.ListBlank.cons.{u1} Γ _inst_1 b R))) (Turing.TM1.stepAux.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ q v (Turing.TM1to1.trTape'.{u1} Γ _inst_1 n enc enc0 (Turing.ListBlank.cons.{u1} Γ _inst_1 a L) R))
but is expected to have type
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} {_inst_2 : Type.{u3}} {σ : Nat} {_inst_3 : Γ -> (Vector.{0} Bool σ)} (n : Eq.{1} (Vector.{0} Bool σ) (_inst_3 (Inhabited.default.{succ u1} Γ _inst_1)) (Vector.replicate.{0} Bool σ Bool.false)) (enc : Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ Λ _inst_2) _inst_2) (enc0 : _inst_2) (q : Γ) (v : Γ) (a : Turing.ListBlank.{u1} Γ _inst_1) (b : Turing.ListBlank.{u1} Γ _inst_1), Eq.{max (max (succ u1) (succ u2)) (succ u3)} (Turing.TM1.Cfg.{0, max (max u3 u2) u1, u3} Bool instInhabitedBool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ Λ _inst_2) _inst_2) (Turing.TM1.stepAux.{0, max (max u3 u2) u1, u3} Bool instInhabitedBool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ Λ _inst_2) _inst_2 (Turing.TM1to1.write.{u1, u2, u3} Γ Λ _inst_2 (Vector.toList.{0} Bool σ (_inst_3 q)) enc) enc0 (Turing.TM1to1.trTape'.{u1} Γ _inst_1 σ _inst_3 n a (Turing.ListBlank.cons.{u1} Γ _inst_1 v b))) (Turing.TM1.stepAux.{0, max (max u1 u2) u3, u3} Bool instInhabitedBool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ Λ _inst_2) _inst_2 enc enc0 (Turing.TM1to1.trTape'.{u1} Γ _inst_1 σ _inst_3 n (Turing.ListBlank.cons.{u1} Γ _inst_1 q a) b))
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.step_aux_write Turing.TM1to1.stepAux_writeₓ'. -/
theorem stepAux_write (q v a b L R) :
    stepAux (write (enc a).toList q) v (tr_tape' L (ListBlank.cons b R)) =
      stepAux q v (tr_tape' (ListBlank.cons a L) R) :=
  by
  simp only [tr_tape', List.cons_bind, List.append_assoc]
  suffices
    ∀ {L' R'} (l₁ l₂ l₂' : List Bool) (e : l₂'.length = l₂.length),
      step_aux (write l₂ q) v (tape.mk' (list_blank.append l₁ L') (list_blank.append l₂' R')) =
        step_aux q v (tape.mk' (L'.append (List.reverseAux l₂ l₁)) R')
    by convert this [] _ _ ((enc b).2.trans (enc a).2.symm) <;> rw [list_blank.cons_bind] <;> rfl
  clear a b L R
  intros
  induction' l₂ with a l₂ IH generalizing l₁ l₂'
  · cases List.length_eq_zero.1 e
    rfl
  cases' l₂' with b l₂' <;> injection e with e
  dsimp only [write, step_aux]
  convert IH _ _ e using 1
  simp only [list_blank.head_cons, list_blank.tail_cons, list_blank.append, tape.move_right_mk',
    tape.write_mk']
#align turing.TM1to1.step_aux_write Turing.TM1to1.stepAux_write

parameter (encdec : ∀ a, dec (enc a) = a)

include encdec

/- warning: turing.TM1to1.step_aux_read -> Turing.TM1to1.stepAux_read is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {n : Nat} {enc : Γ -> (Vector.{0} Bool n)} (dec : (Vector.{0} Bool n) -> Γ) (enc0 : Eq.{1} (Vector.{0} Bool n) (enc (Inhabited.default.{succ u1} Γ _inst_1)) (Vector.replicate.{0} Bool n Bool.false)), (forall (a : Γ), Eq.{succ u1} Γ (dec (enc a)) a) -> (forall (f : Γ -> (Turing.TM1.Stmt.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ)) (v : σ) (L : Turing.ListBlank.{u1} Γ _inst_1) (R : Turing.ListBlank.{u1} Γ _inst_1), Eq.{max 1 (succ (max u1 u2 u3)) (succ u3)} (Turing.TM1.Cfg.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ) (Turing.TM1.stepAux.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ (Turing.TM1to1.read.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 n dec f) v (Turing.TM1to1.trTape'.{u1} Γ _inst_1 n enc enc0 L R)) (Turing.TM1.stepAux.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ (f (Turing.ListBlank.head.{u1} Γ _inst_1 R)) v (Turing.TM1to1.trTape'.{u1} Γ _inst_1 n enc enc0 L R)))
but is expected to have type
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} {_inst_2 : Type.{u3}} {σ : Nat} {_inst_3 : Γ -> (Vector.{0} Bool σ)} (n : (Vector.{0} Bool σ) -> Γ) (enc : Eq.{1} (Vector.{0} Bool σ) (_inst_3 (Inhabited.default.{succ u1} Γ _inst_1)) (Vector.replicate.{0} Bool σ Bool.false)), (forall (ᾰ : Γ), Eq.{succ u1} Γ (n (_inst_3 ᾰ)) ᾰ) -> (forall (enc0 : Γ -> (Turing.TM1.Stmt.{0, max (max u3 u2) u1, u3} Bool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ Λ _inst_2) _inst_2)) (encdec : _inst_2) (f : Turing.ListBlank.{u1} Γ _inst_1) (v : Turing.ListBlank.{u1} Γ _inst_1), Eq.{max (max (succ u1) (succ u2)) (succ u3)} (Turing.TM1.Cfg.{0, max (max u3 u2) u1, u3} Bool instInhabitedBool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ Λ _inst_2) _inst_2) (Turing.TM1.stepAux.{0, max (max u3 u2) u1, u3} Bool instInhabitedBool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ Λ _inst_2) _inst_2 (Turing.TM1to1.read.{u1, u2, u3} Γ Λ _inst_2 σ n enc0) encdec (Turing.TM1to1.trTape'.{u1} Γ _inst_1 σ _inst_3 enc f v)) (Turing.TM1.stepAux.{0, max (max u1 u2) u3, u3} Bool instInhabitedBool (Turing.TM1to1.Λ'.{u1, u2, u3} Γ Λ _inst_2) _inst_2 (enc0 (Turing.ListBlank.head.{u1} Γ _inst_1 v)) encdec (Turing.TM1to1.trTape'.{u1} Γ _inst_1 σ _inst_3 enc f v)))
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.step_aux_read Turing.TM1to1.stepAux_readₓ'. -/
theorem stepAux_read (f v L R) :
    stepAux (read f) v (tr_tape' L R) = stepAux (f R.headI) v (tr_tape' L R) :=
  by
  suffices
    ∀ f,
      step_aux (read_aux n f) v (tr_tape' enc0 L R) =
        step_aux (f (enc R.head)) v (tr_tape' enc0 (L.cons R.head) R.tail)
    by
    rw [read, this, step_aux_move, encdec, tr_tape'_move_left enc0]
    simp only [list_blank.head_cons, list_blank.cons_head_tail, list_blank.tail_cons]
  obtain ⟨a, R, rfl⟩ := R.exists_cons
  simp only [list_blank.head_cons, list_blank.tail_cons, tr_tape', list_blank.cons_bind,
    list_blank.append_assoc]
  suffices
    ∀ i f L' R' l₁ l₂ h,
      step_aux (read_aux i f) v (tape.mk' (list_blank.append l₁ L') (list_blank.append l₂ R')) =
        step_aux (f ⟨l₂, h⟩) v (tape.mk' (list_blank.append (l₂.reverseAux l₁) L') R')
    by
    intro f
    convert this n f _ _ _ _ (enc a).2 <;> simp
  clear f L a R
  intros
  subst i
  induction' l₂ with a l₂ IH generalizing l₁
  · rfl
  trans
    step_aux (read_aux l₂.length fun v => f (a ::ᵥ v)) v
      (tape.mk' ((L'.append l₁).cons a) (R'.append l₂))
  · dsimp [read_aux, step_aux]
    simp
    cases a <;> rfl
  rw [← list_blank.append, IH]
  rfl
#align turing.TM1to1.step_aux_read Turing.TM1to1.stepAux_read

/- warning: turing.TM1to1.tr_respects -> Turing.TM1to1.tr_respects is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {n : Nat} {enc : Γ -> (Vector.{0} Bool n)} (dec : (Vector.{0} Bool n) -> Γ) (enc0 : Eq.{1} (Vector.{0} Bool n) (enc (Inhabited.default.{succ u1} Γ _inst_1)) (Vector.replicate.{0} Bool n Bool.false)) (M : Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)), (forall (a : Γ), Eq.{succ u1} Γ (dec (enc a)) a) -> (Turing.Respects.{max u1 u2 u3, max (max u1 u2 u3) u3} (Turing.TM1.Cfg.{u1, u2, u3} Γ _inst_1 Λ σ) (Turing.TM1.Cfg.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ) (Turing.TM1.step.{u1, u2, u3} Γ _inst_1 Λ σ M) (Turing.TM1.step.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ (Turing.TM1to1.tr.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 n enc dec M)) (fun (c₁ : Turing.TM1.Cfg.{u1, u2, u3} Γ _inst_1 Λ σ) (c₂ : Turing.TM1.Cfg.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ) => Eq.{max 1 (succ (max u1 u2 u3)) (succ u3)} (Turing.TM1.Cfg.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ) (Turing.TM1to1.trCfg.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 n enc enc0 c₁) c₂))
but is expected to have type
  forall {Γ : Type.{u3}} [_inst_1 : Inhabited.{succ u3} Γ] {Λ : Type.{u1}} {_inst_2 : Type.{u2}} {σ : Nat} {_inst_3 : Γ -> (Vector.{0} Bool σ)} (n : (Vector.{0} Bool σ) -> Γ), (Eq.{1} (Vector.{0} Bool σ) (_inst_3 (Inhabited.default.{succ u3} Γ _inst_1)) (Vector.replicate.{0} Bool σ Bool.false)) -> (forall (dec : Λ -> (Turing.TM1.Stmt.{u3, u1, u2} Γ Λ _inst_2)), (forall (a : Γ), Eq.{succ u3} Γ (n (_inst_3 a)) a) -> (forall {M : Eq.{1} (Vector.{0} Bool σ) (_inst_3 (Inhabited.default.{succ u3} Γ _inst_1)) (Vector.replicate.{0} Bool σ Bool.false)}, Turing.Respects.{max (max u2 u1) u3, max u2 (max u2 u1) u3} (Turing.TM1.Cfg.{u3, u1, u2} Γ _inst_1 Λ _inst_2) (Turing.TM1.Cfg.{0, max (max u2 u1) u3, u2} Bool instInhabitedBool (Turing.TM1to1.Λ'.{u3, u1, u2} Γ Λ _inst_2) _inst_2) (Turing.TM1.step.{u3, u1, u2} Γ _inst_1 Λ _inst_2 dec) (Turing.TM1.step.{0, max (max u2 u1) u3, u2} Bool instInhabitedBool (Turing.TM1to1.Λ'.{u3, u1, u2} Γ Λ _inst_2) _inst_2 (Turing.TM1to1.tr.{u3, u1, u2} Γ Λ _inst_2 σ _inst_3 n dec)) (fun (c₁ : Turing.TM1.Cfg.{u3, u1, u2} Γ _inst_1 Λ _inst_2) (c₂ : Turing.TM1.Cfg.{0, max (max u2 u1) u3, u2} Bool instInhabitedBool (Turing.TM1to1.Λ'.{u3, u1, u2} Γ Λ _inst_2) _inst_2) => Eq.{max (max (succ u3) (succ u1)) (succ u2)} (Turing.TM1.Cfg.{0, max (max u2 u1) u3, u2} Bool instInhabitedBool (Turing.TM1to1.Λ'.{u3, u1, u2} Γ Λ _inst_2) _inst_2) (Turing.TM1to1.trCfg.{u3, u1, u2} Γ _inst_1 Λ _inst_2 σ _inst_3 M c₁) c₂)))
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.tr_respects Turing.TM1to1.tr_respectsₓ'. -/
theorem tr_respects : Respects (step M) (step tr) fun c₁ c₂ => tr_cfg c₁ = c₂ :=
  fun_respects.2 fun ⟨l₁, v, T⟩ =>
    by
    obtain ⟨L, R, rfl⟩ := T.exists_mk'
    cases' l₁ with l₁
    · exact rfl
    suffices
      ∀ q R,
        reaches (step (tr enc dec M)) (step_aux (tr_normal dec q) v (tr_tape' enc0 L R))
          (tr_cfg enc0 (step_aux q v (tape.mk' L R)))
      by
      refine' trans_gen.head' rfl _
      rw [tr_tape_mk']
      exact this _ R
    clear R l₁
    intros
    induction' q with _ q IH _ q IH _ q IH generalizing v L R
    case move d q IH =>
      cases d <;>
          simp only [tr_normal, iterate, step_aux_move, step_aux, list_blank.head_cons,
            tape.move_left_mk', list_blank.cons_head_tail, list_blank.tail_cons,
            tr_tape'_move_left enc0, tr_tape'_move_right enc0] <;>
        apply IH
    case
      write f q IH =>
      simp only [tr_normal, step_aux_read dec enc0 encdec, step_aux]
      refine' refl_trans_gen.head rfl _
      obtain ⟨a, R, rfl⟩ := R.exists_cons
      rw [tr, tape.mk'_head, step_aux_write, list_blank.head_cons, step_aux_move,
        tr_tape'_move_left enc0, list_blank.head_cons, list_blank.tail_cons, tape.write_mk']
      apply IH
    case load a q IH =>
      simp only [tr_normal, step_aux_read dec enc0 encdec]
      apply IH
    case
      branch p q₁ q₂ IH₁ IH₂ =>
      simp only [tr_normal, step_aux_read dec enc0 encdec, step_aux]
      cases p R.head v <;> [apply IH₂, apply IH₁]
    case
      goto l =>
      simp only [tr_normal, step_aux_read dec enc0 encdec, step_aux, tr_cfg, tr_tape_mk']
      apply refl_trans_gen.refl
    case
      halt =>
      simp only [tr_normal, step_aux, tr_cfg, step_aux_move, tr_tape'_move_left enc0,
        tr_tape'_move_right enc0, tr_tape_mk']
      apply refl_trans_gen.refl
#align turing.TM1to1.tr_respects Turing.TM1to1.tr_respects

omit enc0 encdec

open Classical

parameter [Fintype Γ]

/- warning: turing.TM1to1.writes -> Turing.TM1to1.writes is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] [_inst_4 : Fintype.{u1} Γ], (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ) -> (Finset.{max u1 u2 u3} (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3))
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Fintype.{u1} Γ], (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ) -> (Finset.{max (max u3 u2) u1} (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ))
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.writes Turing.TM1to1.writesₓ'. -/
/-- The set of accessible `Λ'.write` machine states. -/
noncomputable def writes : stmt₁ → Finset Λ'
  | stmt.move d q => writes q
  | stmt.write f q => (Finset.univ.image fun a => Λ'.write a q) ∪ writes q
  | stmt.load f q => writes q
  | stmt.branch p q₁ q₂ => writes q₁ ∪ writes q₂
  | stmt.goto l => ∅
  | stmt.halt => ∅
#align turing.TM1to1.writes Turing.TM1to1.writes

/- warning: turing.TM1to1.tr_supp -> Turing.TM1to1.trSupp is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ], (Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) -> (forall [_inst_4 : Fintype.{u1} Γ], (Finset.{u2} Λ) -> (Finset.{max u1 u2 u3} (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3)))
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} {Λ : Type.{u3}}, (_inst_1 -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ)) -> (forall [σ : Fintype.{u1} Γ], (Finset.{u2} _inst_1) -> (Finset.{max (max u3 u2) u1} (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ)))
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.tr_supp Turing.TM1to1.trSuppₓ'. -/
/-- The set of accessible machine states, assuming that the input machine is supported on `S`,
are the normal states embedded from `S`, plus all write states accessible from these states. -/
noncomputable def trSupp (S : Finset Λ) : Finset Λ' :=
  S.biUnion fun l => insert (Λ'.normal l) (writes (M l))
#align turing.TM1to1.tr_supp Turing.TM1to1.trSupp

/- warning: turing.TM1to1.tr_supports -> Turing.TM1to1.tr_supports is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {n : Nat} {enc : Γ -> (Vector.{0} Bool n)} (dec : (Vector.{0} Bool n) -> Γ) (M : Λ -> (Turing.TM1.Stmt.{u1, u2, u3} Γ _inst_1 Λ σ)) [_inst_4 : Fintype.{u1} Γ] {S : Finset.{u2} Λ}, (Turing.TM1.Supports.{u1, u2, u3} Γ _inst_1 Λ σ _inst_2 M S) -> (Turing.TM1.Supports.{0, max u1 u2 u3, u3} Bool Bool.inhabited (Turing.TM1to1.Λ'.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) σ (Turing.TM1to1.Λ'.inhabited.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3) (Turing.TM1to1.tr.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 n enc dec M) (Turing.TM1to1.trSupp.{u1, u2, u3} Γ _inst_1 Λ _inst_2 σ _inst_3 M _inst_4 S))
but is expected to have type
  forall {Γ : Type.{u2}} {_inst_1 : Type.{u3}} [Λ : Inhabited.{succ u3} _inst_1] {_inst_2 : Type.{u1}} {σ : Nat} {_inst_3 : Γ -> (Vector.{0} Bool σ)} (n : (Vector.{0} Bool σ) -> Γ) (enc : _inst_1 -> (Turing.TM1.Stmt.{u2, u3, u1} Γ _inst_1 _inst_2)) [dec : Fintype.{u2} Γ] {M : Finset.{u3} _inst_1}, (Turing.TM1.Supports.{u2, u3, u1} Γ _inst_1 _inst_2 Λ enc M) -> (Turing.TM1.Supports.{0, max (max u1 u3) u2, u1} Bool (Turing.TM1to1.Λ'.{u2, u3, u1} Γ _inst_1 _inst_2) _inst_2 (Turing.TM1to1.instInhabitedΛ'.{u2, u3, u1} Γ _inst_1 Λ _inst_2) (Turing.TM1to1.tr.{u2, u3, u1} Γ _inst_1 _inst_2 σ _inst_3 n enc) (Turing.TM1to1.trSupp.{u2, u3, u1} Γ _inst_1 _inst_2 enc dec M))
Case conversion may be inaccurate. Consider using '#align turing.TM1to1.tr_supports Turing.TM1to1.tr_supportsₓ'. -/
theorem tr_supports {S} (ss : Supports M S) : Supports tr (tr_supp S) :=
  ⟨Finset.mem_biUnion.2 ⟨_, ss.1, Finset.mem_insert_self _ _⟩, fun q h =>
    by
    suffices
      ∀ q,
        supports_stmt S q →
          (∀ q' ∈ writes q, q' ∈ tr_supp M S) →
            supports_stmt (tr_supp M S) (tr_normal dec q) ∧
              ∀ q' ∈ writes q, supports_stmt (tr_supp M S) (tr enc dec M q')
      by
      rcases Finset.mem_biUnion.1 h with ⟨l, hl, h⟩
      have :=
        this _ (ss.2 _ hl) fun q' hq => Finset.mem_biUnion.2 ⟨_, hl, Finset.mem_insert_of_mem hq⟩
      rcases Finset.mem_insert.1 h with (rfl | h)
      exacts[this.1, this.2 _ h]
    intro q hs hw
    induction q
    case move d q IH =>
      unfold writes at hw⊢
      replace IH := IH hs hw; refine' ⟨_, IH.2⟩
      cases d <;> simp only [tr_normal, iterate, supports_stmt_move, IH]
    case write f q IH =>
      unfold writes at hw⊢
      simp only [Finset.mem_image, Finset.mem_union, Finset.mem_univ, exists_prop, true_and_iff] at
        hw⊢
      replace IH := IH hs fun q hq => hw q (Or.inr hq)
      refine' ⟨supports_stmt_read _ fun a _ s => hw _ (Or.inl ⟨_, rfl⟩), fun q' hq => _⟩
      rcases hq with (⟨a, q₂, rfl⟩ | hq)
      · simp only [tr, supports_stmt_write, supports_stmt_move, IH.1]
      · exact IH.2 _ hq
    case load a q IH =>
      unfold writes at hw⊢
      replace IH := IH hs hw
      refine' ⟨supports_stmt_read _ fun a => IH.1, IH.2⟩
    case branch p q₁ q₂ IH₁ IH₂ =>
      unfold writes at hw⊢
      simp only [Finset.mem_union] at hw⊢
      replace IH₁ := IH₁ hs.1 fun q hq => hw q (Or.inl hq)
      replace IH₂ := IH₂ hs.2 fun q hq => hw q (Or.inr hq)
      exact ⟨supports_stmt_read _ fun a => ⟨IH₁.1, IH₂.1⟩, fun q => Or.ndrec (IH₁.2 _) (IH₂.2 _)⟩
    case goto l =>
      refine' ⟨_, fun _ => False.elim⟩
      refine' supports_stmt_read _ fun a _ s => _
      exact Finset.mem_biUnion.2 ⟨_, hs _ _, Finset.mem_insert_self _ _⟩
    case halt =>
      refine' ⟨_, fun _ => False.elim⟩
      simp only [supports_stmt, supports_stmt_move, tr_normal]⟩
#align turing.TM1to1.tr_supports Turing.TM1to1.tr_supports

end

end TM1to1

/-!
## TM0 emulator in TM1

To establish that TM0 and TM1 are equivalent computational models, we must also have a TM0 emulator
in TM1. The main complication here is that TM0 allows an action to depend on the value at the head
and local state, while TM1 doesn't (in order to have more programming language-like semantics).
So we use a computed `goto` to go to a state that performes the desired action and then returns to
normal execution.

One issue with this is that the `halt` instruction is supposed to halt immediately, not take a step
to a halting state. To resolve this we do a check for `halt` first, then `goto` (with an
unreachable branch).
-/


namespace TM0to1

section

parameter {Γ : Type _}[Inhabited Γ]

parameter {Λ : Type _}[Inhabited Λ]

/- warning: turing.TM0to1.Λ' -> Turing.TM0to1.Λ' is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ], Sort.{max (succ u1) (succ u2)}
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}}, Sort.{max (succ u1) (succ u2)}
Case conversion may be inaccurate. Consider using '#align turing.TM0to1.Λ' Turing.TM0to1.Λ'ₓ'. -/
/-- The machine states for a TM1 emulating a TM0 machine. States of the TM0 machine are embedded
as `normal q` states, but the actual operation is split into two parts, a jump to `act s q`
followed by the action and a jump to the next `normal` state.  -/
inductive Λ'
  | normal : Λ → Λ'
  | act : TM0.Stmt Γ → Λ → Λ'
#align turing.TM0to1.Λ' Turing.TM0to1.Λ'

instance : Inhabited Λ' :=
  ⟨Λ'.normal default⟩

-- mathport name: exprcfg₀
local notation "cfg₀" => TM0.Cfg Γ Λ

-- mathport name: exprstmt₁
local notation "stmt₁" => TM1.Stmt Γ Λ' Unit

-- mathport name: exprcfg₁
local notation "cfg₁" => TM1.Cfg Γ Λ' Unit

parameter (M : TM0.Machine Γ Λ)

open TM1.Stmt

/- warning: turing.TM0to1.tr -> Turing.TM0to1.tr is a dubious translation:
lean 3 declaration is
  forall {Γ : Type.{u1}} [_inst_1 : Inhabited.{succ u1} Γ] {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ], (Turing.TM0.Machine.{u1, u2} Γ _inst_1 Λ _inst_2) -> (Turing.TM0to1.Λ'.{u1, u2} Γ _inst_1 Λ _inst_2) -> (Turing.TM1.Stmt.{u1, max u1 u2, 0} Γ _inst_1 (Turing.TM0to1.Λ'.{u1, u2} Γ _inst_1 Λ _inst_2) Unit)
but is expected to have type
  forall {Γ : Type.{u1}} {_inst_1 : Type.{u2}} [Λ : Inhabited.{succ u2} _inst_1], (Turing.TM0.Machine.{u1, u2} Γ _inst_1 Λ) -> (Turing.TM0to1.Λ'.{u1, u2} Γ _inst_1) -> (Turing.TM1.Stmt.{u1, max u2 u1, 0} Γ (Turing.TM0to1.Λ'.{u1, u2} Γ _inst_1) Unit)
Case conversion may be inaccurate. Consider using '#align turing.TM0to1.tr Turing.TM0to1.trₓ'. -/
/-- The program.  -/
def tr : Λ' → stmt₁
  | Λ'.normal q =>
    branch (fun a _ => (M q a).isNone) halt <|
      goto fun a _ =>
        match M q a with
        | none => default
        |-- unreachable
            some
            (q', s) =>
          Λ'.act s q'
  | Λ'.act (TM0.stmt.move d) q => move d <| goto fun _ _ => Λ'.normal q
  | Λ'.act (TM0.stmt.write a) q => (write fun _ _ => a) <| goto fun _ _ => Λ'.normal q
#align turing.TM0to1.tr Turing.TM0to1.tr

#print Turing.TM0to1.trCfg /-
/-- The configuration translation. -/
def trCfg : cfg₀ → cfg₁
  | ⟨q, T⟩ => ⟨cond (M q T.1).isSome (some (Λ'.normal q)) none, (), T⟩
#align turing.TM0to1.tr_cfg Turing.TM0to1.trCfg
-/

#print Turing.TM0to1.tr_respects /-
theorem tr_respects : Respects (TM0.step M) (TM1.step tr) fun a b => tr_cfg a = b :=
  fun_respects.2 fun ⟨q, T⟩ => by
    cases e : M q T.1
    · simp only [TM0.step, tr_cfg, e] <;> exact Eq.refl none
    cases' val with q' s
    simp only [frespects, TM0.step, tr_cfg, e, Option.isSome, cond, Option.map_some']
    have :
      TM1.step (tr M) ⟨some (Λ'.act s q'), (), T⟩ =
        some ⟨some (Λ'.normal q'), (), TM0.step._match_1 T s⟩ :=
      by cases' s with d a <;> rfl
    refine' trans_gen.head _ (trans_gen.head' this _)
    · unfold TM1.step TM1.step_aux tr Membership.Mem
      rw [e]
      rfl
    cases e' : M q' _
    · apply refl_trans_gen.single
      unfold TM1.step TM1.step_aux tr Membership.Mem
      rw [e']
      rfl
    · rfl
#align turing.TM0to1.tr_respects Turing.TM0to1.tr_respects
-/

end

end TM0to1

/-!
## The TM2 model

The TM2 model removes the tape entirely from the TM1 model, replacing it with an arbitrary (finite)
collection of stacks, each with elements of different types (the alphabet of stack `k : K` is
`Γ k`). The statements are:

* `push k (f : σ → Γ k) q` puts `f a` on the `k`-th stack, then does `q`.
* `pop k (f : σ → option (Γ k) → σ) q` changes the state to `f a (S k).head`, where `S k` is the
  value of the `k`-th stack, and removes this element from the stack, then does `q`.
* `peek k (f : σ → option (Γ k) → σ) q` changes the state to `f a (S k).head`, where `S k` is the
  value of the `k`-th stack, then does `q`.
* `load (f : σ → σ) q` reads nothing but applies `f` to the internal state, then does `q`.
* `branch (f : σ → bool) qtrue qfalse` does `qtrue` or `qfalse` according to `f a`.
* `goto (f : σ → Λ)` jumps to label `f a`.
* `halt` halts on the next step.

The configuration is a tuple `(l, var, stk)` where `l : option Λ` is the current label to run or
`none` for the halting state, `var : σ` is the (finite) internal state, and `stk : ∀ k, list (Γ k)`
is the collection of stacks. (Note that unlike the `TM0` and `TM1` models, these are not
`list_blank`s, they have definite ends that can be detected by the `pop` command.)

Given a designated stack `k` and a value `L : list (Γ k)`, the initial configuration has all the
stacks empty except the designated "input" stack; in `eval` this designated stack also functions
as the output stack.
-/


namespace TM2

section

parameter {K : Type _}[DecidableEq K]

-- Index type of stacks
parameter (Γ : K → Type _)

-- Type of stack elements
parameter (Λ : Type _)

-- Type of function labels
parameter (σ : Type _)

/- warning: turing.TM2.stmt -> Turing.TM2.Stmt is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K], (K -> Type.{u2}) -> Type.{u3} -> Type.{u4} -> Sort.{max (succ u1) (succ u2) (succ u3) (succ u4)}
but is expected to have type
  forall {K : Type.{u1}}, (K -> Type.{u2}) -> Type.{u3} -> Type.{u4} -> Sort.{max (max (max (succ u1) (succ u2)) (succ u3)) (succ u4)}
Case conversion may be inaccurate. Consider using '#align turing.TM2.stmt Turing.TM2.Stmtₓ'. -/
-- Type of variable settings
/-- The TM2 model removes the tape entirely from the TM1 model,
  replacing it with an arbitrary (finite) collection of stacks.
  The operation `push` puts an element on one of the stacks,
  and `pop` removes an element from a stack (and modifying the
  internal state based on the result). `peek` modifies the
  internal state but does not remove an element. -/
inductive Stmt
  | push : ∀ k, (σ → Γ k) → stmt → stmt
  | peek : ∀ k, (σ → Option (Γ k) → σ) → stmt → stmt
  | pop : ∀ k, (σ → Option (Γ k) → σ) → stmt → stmt
  | load : (σ → σ) → stmt → stmt
  | branch : (σ → Bool) → stmt → stmt → stmt
  | goto : (σ → Λ) → stmt
  | halt : stmt
#align turing.TM2.stmt Turing.TM2.Stmt

open Stmt

/- warning: turing.TM2.stmt.inhabited -> Turing.TM2.Stmt.inhabited is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] (Γ : K -> Type.{u2}) (Λ : Type.{u3}) (σ : Type.{u4}), Inhabited.{max (succ u1) (succ u2) (succ u3) (succ u4)} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)
but is expected to have type
  forall {K : Type.{u1}} (_inst_1 : K -> Type.{u2}) (Γ : Type.{u3}) (Λ : Type.{u4}), Inhabited.{max (max (max (succ u4) (succ u3)) (succ u2)) (succ u1)} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ)
Case conversion may be inaccurate. Consider using '#align turing.TM2.stmt.inhabited Turing.TM2.Stmt.inhabitedₓ'. -/
instance Stmt.inhabited : Inhabited stmt :=
  ⟨halt⟩
#align turing.TM2.stmt.inhabited Turing.TM2.Stmt.inhabited

/- warning: turing.TM2.cfg -> Turing.TM2.Cfg is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K], (K -> Type.{u2}) -> Type.{u3} -> Type.{u4} -> Sort.{max (succ u1) (succ u2) (succ u3) (succ u4)}
but is expected to have type
  forall {K : Type.{u1}}, (K -> Type.{u2}) -> Type.{u3} -> Type.{u4} -> Sort.{max (max (max (succ u1) (succ u2)) (succ u3)) (succ u4)}
Case conversion may be inaccurate. Consider using '#align turing.TM2.cfg Turing.TM2.Cfgₓ'. -/
/-- A configuration in the TM2 model is a label (or `none` for the halt state), the state of
local variables, and the stacks. (Note that the stacks are not `list_blank`s, they have a definite
size.) -/
structure Cfg where
  l : Option Λ
  var : σ
  stk : ∀ k, List (Γ k)
#align turing.TM2.cfg Turing.TM2.Cfg

/- warning: turing.TM2.cfg.inhabited -> Turing.TM2.Cfg.inhabited is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] (Γ : K -> Type.{u2}) (Λ : Type.{u3}) (σ : Type.{u4}) [_inst_2 : Inhabited.{succ u4} σ], Inhabited.{max (succ u1) (succ u2) (succ u3) (succ u4)} (Turing.TM2.Cfg.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)
but is expected to have type
  forall {K : Type.{u1}} (_inst_1 : K -> Type.{u2}) (Γ : Type.{u3}) (Λ : Type.{u4}) [σ : Inhabited.{succ u4} Λ], Inhabited.{max (max (max (succ u4) (succ u3)) (succ u2)) (succ u1)} (Turing.TM2.Cfg.{u1, u2, u3, u4} K _inst_1 Γ Λ)
Case conversion may be inaccurate. Consider using '#align turing.TM2.cfg.inhabited Turing.TM2.Cfg.inhabitedₓ'. -/
instance Cfg.inhabited [Inhabited σ] : Inhabited cfg :=
  ⟨⟨default, default, default⟩⟩
#align turing.TM2.cfg.inhabited Turing.TM2.Cfg.inhabited

parameter {Γ Λ σ K}

#print Turing.TM2.stepAux /-
/-- The step function for the TM2 model. -/
@[simp]
def stepAux : stmt → σ → (∀ k, List (Γ k)) → cfg
  | push k f q, v, S => step_aux q v (update S k (f v :: S k))
  | peek k f q, v, S => step_aux q (f v (S k).head?) S
  | pop k f q, v, S => step_aux q (f v (S k).head?) (update S k (S k).tail)
  | load a q, v, S => step_aux q (a v) S
  | branch f q₁ q₂, v, S => cond (f v) (step_aux q₁ v S) (step_aux q₂ v S)
  | goto f, v, S => ⟨some (f v), v, S⟩
  | halt, v, S => ⟨none, v, S⟩
#align turing.TM2.step_aux Turing.TM2.stepAux
-/

#print Turing.TM2.step /-
/-- The step function for the TM2 model. -/
@[simp]
def step (M : Λ → stmt) : cfg → Option cfg
  | ⟨none, v, S⟩ => none
  | ⟨some l, v, S⟩ => some (step_aux (M l) v S)
#align turing.TM2.step Turing.TM2.step
-/

#print Turing.TM2.Reaches /-
/-- The (reflexive) reachability relation for the TM2 model. -/
def Reaches (M : Λ → stmt) : cfg → cfg → Prop :=
  ReflTransGen fun a b => b ∈ step M a
#align turing.TM2.reaches Turing.TM2.Reaches
-/

/- warning: turing.TM2.supports_stmt -> Turing.TM2.SupportsStmt is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} {σ : Type.{u4}}, (Finset.{u3} Λ) -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ) -> Prop
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u3}} {Λ : Type.{u4}}, (Finset.{u3} Γ) -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ) -> Prop
Case conversion may be inaccurate. Consider using '#align turing.TM2.supports_stmt Turing.TM2.SupportsStmtₓ'. -/
/-- Given a set `S` of states, `support_stmt S q` means that `q` only jumps to states in `S`. -/
def SupportsStmt (S : Finset Λ) : stmt → Prop
  | push k f q => supports_stmt q
  | peek k f q => supports_stmt q
  | pop k f q => supports_stmt q
  | load a q => supports_stmt q
  | branch f q₁ q₂ => supports_stmt q₁ ∧ supports_stmt q₂
  | goto l => ∀ v, l v ∈ S
  | halt => True
#align turing.TM2.supports_stmt Turing.TM2.SupportsStmt

open Classical

/- warning: turing.TM2.stmts₁ -> Turing.TM2.stmts₁ is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} {σ : Type.{u4}}, (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ) -> (Finset.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ))
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u3}} {Λ : Type.{u4}}, (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ) -> (Finset.{max (max (max u4 u3) u2) u1} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ))
Case conversion may be inaccurate. Consider using '#align turing.TM2.stmts₁ Turing.TM2.stmts₁ₓ'. -/
/-- The set of subtree statements in a statement. -/
noncomputable def stmts₁ : stmt → Finset stmt
  | Q@(push k f q) => insert Q (stmts₁ q)
  | Q@(peek k f q) => insert Q (stmts₁ q)
  | Q@(pop k f q) => insert Q (stmts₁ q)
  | Q@(load a q) => insert Q (stmts₁ q)
  | Q@(branch f q₁ q₂) => insert Q (stmts₁ q₁ ∪ stmts₁ q₂)
  | Q@(goto l) => {Q}
  | Q@halt => {Q}
#align turing.TM2.stmts₁ Turing.TM2.stmts₁

/- warning: turing.TM2.stmts₁_self -> Turing.TM2.stmts₁_self is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} {σ : Type.{u4}} {q : Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ}, Membership.Mem.{max u1 u2 u3 u4, max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ) (Finset.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) (Finset.hasMem.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) q (Turing.TM2.stmts₁.{u1, u2, u3, u4} K _inst_1 Γ Λ σ q)
but is expected to have type
  forall {K : Type.{u4}} {_inst_1 : K -> Type.{u3}} {Γ : Type.{u2}} {Λ : Type.{u1}} {σ : Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ}, Membership.mem.{max (max (max u4 u3) u2) u1, max (max (max u1 u2) u3) u4} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ) (Finset.{max (max (max u1 u2) u3) u4} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ)) (Finset.instMembershipFinset.{max (max (max u4 u3) u2) u1} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ)) σ (Turing.TM2.stmts₁.{u4, u3, u2, u1} K _inst_1 Γ Λ σ)
Case conversion may be inaccurate. Consider using '#align turing.TM2.stmts₁_self Turing.TM2.stmts₁_selfₓ'. -/
theorem stmts₁_self {q} : q ∈ stmts₁ q := by
  cases q <;> apply_rules [Finset.mem_insert_self, Finset.mem_singleton_self]
#align turing.TM2.stmts₁_self Turing.TM2.stmts₁_self

/- warning: turing.TM2.stmts₁_trans -> Turing.TM2.stmts₁_trans is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} {σ : Type.{u4}} {q₁ : Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ} {q₂ : Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ}, (Membership.Mem.{max u1 u2 u3 u4, max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ) (Finset.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) (Finset.hasMem.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) q₁ (Turing.TM2.stmts₁.{u1, u2, u3, u4} K _inst_1 Γ Λ σ q₂)) -> (HasSubset.Subset.{max u1 u2 u3 u4} (Finset.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) (Finset.hasSubset.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) (Turing.TM2.stmts₁.{u1, u2, u3, u4} K _inst_1 Γ Λ σ q₁) (Turing.TM2.stmts₁.{u1, u2, u3, u4} K _inst_1 Γ Λ σ q₂))
but is expected to have type
  forall {K : Type.{u4}} {_inst_1 : K -> Type.{u3}} {Γ : Type.{u2}} {Λ : Type.{u1}} {σ : Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ} {q₁ : Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ}, (Membership.mem.{max (max (max u4 u3) u2) u1, max (max (max u1 u2) u3) u4} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ) (Finset.{max (max (max u1 u2) u3) u4} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ)) (Finset.instMembershipFinset.{max (max (max u4 u3) u2) u1} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ)) σ (Turing.TM2.stmts₁.{u4, u3, u2, u1} K _inst_1 Γ Λ q₁)) -> (HasSubset.Subset.{max (max (max u1 u2) u3) u4} (Finset.{max (max (max u1 u2) u3) u4} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ)) (Finset.instHasSubsetFinset.{max (max (max u4 u3) u2) u1} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ)) (Turing.TM2.stmts₁.{u4, u3, u2, u1} K _inst_1 Γ Λ σ) (Turing.TM2.stmts₁.{u4, u3, u2, u1} K _inst_1 Γ Λ q₁))
Case conversion may be inaccurate. Consider using '#align turing.TM2.stmts₁_trans Turing.TM2.stmts₁_transₓ'. -/
theorem stmts₁_trans {q₁ q₂} : q₁ ∈ stmts₁ q₂ → stmts₁ q₁ ⊆ stmts₁ q₂ :=
  by
  intro h₁₂ q₀ h₀₁
  induction' q₂ with _ _ q IH _ _ q IH _ _ q IH _ q IH <;> simp only [stmts₁] at h₁₂⊢ <;>
    simp only [Finset.mem_insert, Finset.mem_singleton, Finset.mem_union] at h₁₂
  iterate 4 
    rcases h₁₂ with (rfl | h₁₂)
    · unfold stmts₁ at h₀₁
      exact h₀₁
    · exact Finset.mem_insert_of_mem (IH h₁₂)
  case branch f q₁ q₂ IH₁ IH₂ =>
    rcases h₁₂ with (rfl | h₁₂ | h₁₂)
    · unfold stmts₁ at h₀₁
      exact h₀₁
    · exact Finset.mem_insert_of_mem (Finset.mem_union_left _ (IH₁ h₁₂))
    · exact Finset.mem_insert_of_mem (Finset.mem_union_right _ (IH₂ h₁₂))
  case goto l => subst h₁₂; exact h₀₁
  case halt => subst h₁₂; exact h₀₁
#align turing.TM2.stmts₁_trans Turing.TM2.stmts₁_trans

/- warning: turing.TM2.stmts₁_supports_stmt_mono -> Turing.TM2.stmts₁_supportsStmt_mono is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} {σ : Type.{u4}} {S : Finset.{u3} Λ} {q₁ : Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ} {q₂ : Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ}, (Membership.Mem.{max u1 u2 u3 u4, max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ) (Finset.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) (Finset.hasMem.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) q₁ (Turing.TM2.stmts₁.{u1, u2, u3, u4} K _inst_1 Γ Λ σ q₂)) -> (Turing.TM2.SupportsStmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ S q₂) -> (Turing.TM2.SupportsStmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ S q₁)
but is expected to have type
  forall {K : Type.{u3}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u4}} {Λ : Type.{u1}} {σ : Finset.{u4} Γ} {S : Turing.TM2.Stmt.{u3, u2, u4, u1} K _inst_1 Γ Λ} {q₁ : Turing.TM2.Stmt.{u3, u2, u4, u1} K _inst_1 Γ Λ}, (Membership.mem.{max (max (max u3 u2) u4) u1, max (max (max u1 u4) u2) u3} (Turing.TM2.Stmt.{u3, u2, u4, u1} K _inst_1 Γ Λ) (Finset.{max (max (max u1 u4) u2) u3} (Turing.TM2.Stmt.{u3, u2, u4, u1} K _inst_1 Γ Λ)) (Finset.instMembershipFinset.{max (max (max u3 u2) u4) u1} (Turing.TM2.Stmt.{u3, u2, u4, u1} K _inst_1 Γ Λ)) S (Turing.TM2.stmts₁.{u3, u2, u4, u1} K _inst_1 Γ Λ q₁)) -> (Turing.TM2.SupportsStmt.{u3, u2, u4, u1} K _inst_1 Γ Λ σ q₁) -> (Turing.TM2.SupportsStmt.{u3, u2, u4, u1} K _inst_1 Γ Λ σ S)
Case conversion may be inaccurate. Consider using '#align turing.TM2.stmts₁_supports_stmt_mono Turing.TM2.stmts₁_supportsStmt_monoₓ'. -/
theorem stmts₁_supportsStmt_mono {S q₁ q₂} (h : q₁ ∈ stmts₁ q₂) (hs : supports_stmt S q₂) :
    supports_stmt S q₁ :=
  by
  induction' q₂ with _ _ q IH _ _ q IH _ _ q IH _ q IH <;>
    simp only [stmts₁, supports_stmt, Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at
      h hs
  iterate 4 rcases h with (rfl | h) <;> [exact hs, exact IH h hs]
  case branch f q₁ q₂ IH₁ IH₂ => rcases h with (rfl | h | h); exacts[hs, IH₁ h hs.1, IH₂ h hs.2]
  case goto l => subst h; exact hs
  case halt => subst h; trivial
#align turing.TM2.stmts₁_supports_stmt_mono Turing.TM2.stmts₁_supportsStmt_mono

/- warning: turing.TM2.stmts -> Turing.TM2.stmts is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} {σ : Type.{u4}}, (Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) -> (Finset.{u3} Λ) -> (Finset.{max u1 u2 u3 u4} (Option.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)))
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u3}} {Λ : Type.{u4}}, (Γ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ)) -> (Finset.{u3} Γ) -> (Finset.{max (max (max u4 u3) u2) u1} (Option.{max (max (max u4 u3) u2) u1} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ)))
Case conversion may be inaccurate. Consider using '#align turing.TM2.stmts Turing.TM2.stmtsₓ'. -/
/-- The set of statements accessible from initial set `S` of labels. -/
noncomputable def stmts (M : Λ → stmt) (S : Finset Λ) : Finset (Option stmt) :=
  (S.biUnion fun q => stmts₁ (M q)).insertNone
#align turing.TM2.stmts Turing.TM2.stmts

/- warning: turing.TM2.stmts_trans -> Turing.TM2.stmts_trans is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} {σ : Type.{u4}} {M : Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)} {S : Finset.{u3} Λ} {q₁ : Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ} {q₂ : Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ}, (Membership.Mem.{max u1 u2 u3 u4, max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ) (Finset.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) (Finset.hasMem.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) q₁ (Turing.TM2.stmts₁.{u1, u2, u3, u4} K _inst_1 Γ Λ σ q₂)) -> (Membership.Mem.{max u1 u2 u3 u4, max u1 u2 u3 u4} (Option.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) (Finset.{max u1 u2 u3 u4} (Option.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ))) (Finset.hasMem.{max u1 u2 u3 u4} (Option.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ))) (Option.some.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ) q₂) (Turing.TM2.stmts.{u1, u2, u3, u4} K _inst_1 Γ Λ σ M S)) -> (Membership.Mem.{max u1 u2 u3 u4, max u1 u2 u3 u4} (Option.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) (Finset.{max u1 u2 u3 u4} (Option.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ))) (Finset.hasMem.{max u1 u2 u3 u4} (Option.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ))) (Option.some.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ) q₁) (Turing.TM2.stmts.{u1, u2, u3, u4} K _inst_1 Γ Λ σ M S))
but is expected to have type
  forall {K : Type.{u4}} {_inst_1 : K -> Type.{u3}} {Γ : Type.{u2}} {Λ : Type.{u1}} {σ : Γ -> (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ)} {M : Finset.{u2} Γ} {S : Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ} {q₁ : Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ}, (Membership.mem.{max (max (max u4 u3) u2) u1, max (max (max u1 u2) u3) u4} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ) (Finset.{max (max (max u1 u2) u3) u4} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ)) (Finset.instMembershipFinset.{max (max (max u4 u3) u2) u1} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ)) S (Turing.TM2.stmts₁.{u4, u3, u2, u1} K _inst_1 Γ Λ q₁)) -> (Membership.mem.{max (max (max u4 u3) u2) u1, max (max (max u1 u2) u3) u4} (Option.{max (max (max u4 u3) u2) u1} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ)) (Finset.{max (max (max u1 u2) u3) u4} (Option.{max (max (max u1 u2) u3) u4} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ))) (Finset.instMembershipFinset.{max (max (max u4 u3) u2) u1} (Option.{max (max (max u1 u2) u3) u4} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ))) (Option.some.{max (max (max u4 u3) u2) u1} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ) q₁) (Turing.TM2.stmts.{u4, u3, u2, u1} K _inst_1 Γ Λ σ M)) -> (Membership.mem.{max (max (max u4 u3) u2) u1, max (max (max u1 u2) u3) u4} (Option.{max (max (max u4 u3) u2) u1} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ)) (Finset.{max (max (max u1 u2) u3) u4} (Option.{max (max (max u1 u2) u3) u4} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ))) (Finset.instMembershipFinset.{max (max (max u4 u3) u2) u1} (Option.{max (max (max u1 u2) u3) u4} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ))) (Option.some.{max (max (max u4 u3) u2) u1} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ) S) (Turing.TM2.stmts.{u4, u3, u2, u1} K _inst_1 Γ Λ σ M))
Case conversion may be inaccurate. Consider using '#align turing.TM2.stmts_trans Turing.TM2.stmts_transₓ'. -/
theorem stmts_trans {M : Λ → stmt} {S q₁ q₂} (h₁ : q₁ ∈ stmts₁ q₂) :
    some q₂ ∈ stmts M S → some q₁ ∈ stmts M S := by
  simp only [stmts, Finset.mem_insertNone, Finset.mem_biUnion, Option.mem_def, forall_eq',
      exists_imp] <;>
    exact fun l ls h₂ => ⟨_, ls, stmts₁_trans h₂ h₁⟩
#align turing.TM2.stmts_trans Turing.TM2.stmts_trans

variable [Inhabited Λ]

/- warning: turing.TM2.supports -> Turing.TM2.Supports is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} {σ : Type.{u4}} [_inst_2 : Inhabited.{succ u3} Λ], (Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) -> (Finset.{u3} Λ) -> Prop
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u3}} {Λ : Type.{u4}} [σ : Inhabited.{succ u3} Γ], (Γ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ)) -> (Finset.{u3} Γ) -> Prop
Case conversion may be inaccurate. Consider using '#align turing.TM2.supports Turing.TM2.Supportsₓ'. -/
/-- Given a TM2 machine `M` and a set `S` of states, `supports M S` means that all states in
`S` jump only to other states in `S`. -/
def Supports (M : Λ → stmt) (S : Finset Λ) :=
  default ∈ S ∧ ∀ q ∈ S, supports_stmt S (M q)
#align turing.TM2.supports Turing.TM2.Supports

/- warning: turing.TM2.stmts_supports_stmt -> Turing.TM2.stmts_supportsStmt is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} {σ : Type.{u4}} [_inst_2 : Inhabited.{succ u3} Λ] {M : Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)} {S : Finset.{u3} Λ} {q : Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ}, (Turing.TM2.Supports.{u1, u2, u3, u4} K _inst_1 Γ Λ σ _inst_2 M S) -> (Membership.Mem.{max u1 u2 u3 u4, max u1 u2 u3 u4} (Option.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) (Finset.{max u1 u2 u3 u4} (Option.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ))) (Finset.hasMem.{max u1 u2 u3 u4} (Option.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ))) (Option.some.{max u1 u2 u3 u4} (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ) q) (Turing.TM2.stmts.{u1, u2, u3, u4} K _inst_1 Γ Λ σ M S)) -> (Turing.TM2.SupportsStmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ S q)
but is expected to have type
  forall {K : Type.{u4}} {_inst_1 : K -> Type.{u3}} {Γ : Type.{u2}} {Λ : Type.{u1}} [σ : Inhabited.{succ u2} Γ] {_inst_2 : Γ -> (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ)} {M : Finset.{u2} Γ} {S : Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ}, (Turing.TM2.Supports.{u4, u3, u2, u1} K _inst_1 Γ Λ σ _inst_2 M) -> (Membership.mem.{max (max (max u4 u3) u2) u1, max (max (max u1 u2) u3) u4} (Option.{max (max (max u4 u3) u2) u1} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ)) (Finset.{max (max (max u1 u2) u3) u4} (Option.{max (max (max u1 u2) u3) u4} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ))) (Finset.instMembershipFinset.{max (max (max u4 u3) u2) u1} (Option.{max (max (max u1 u2) u3) u4} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ))) (Option.some.{max (max (max u4 u3) u2) u1} (Turing.TM2.Stmt.{u4, u3, u2, u1} K _inst_1 Γ Λ) S) (Turing.TM2.stmts.{u4, u3, u2, u1} K _inst_1 Γ Λ _inst_2 M)) -> (Turing.TM2.SupportsStmt.{u4, u3, u2, u1} K _inst_1 Γ Λ M S)
Case conversion may be inaccurate. Consider using '#align turing.TM2.stmts_supports_stmt Turing.TM2.stmts_supportsStmtₓ'. -/
theorem stmts_supportsStmt {M : Λ → stmt} {S q} (ss : supports M S) :
    some q ∈ stmts M S → supports_stmt S q := by
  simp only [stmts, Finset.mem_insertNone, Finset.mem_biUnion, Option.mem_def, forall_eq',
      exists_imp] <;>
    exact fun l ls h => stmts₁_supports_stmt_mono h (ss.2 _ ls)
#align turing.TM2.stmts_supports_stmt Turing.TM2.stmts_supportsStmt

/- warning: turing.TM2.step_supports -> Turing.TM2.step_supports is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} {σ : Type.{u4}} [_inst_2 : Inhabited.{succ u3} Λ] (M : Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) {S : Finset.{u3} Λ}, (Turing.TM2.Supports.{u1, u2, u3, u4} K _inst_1 Γ Λ σ _inst_2 M S) -> (forall {c : Turing.TM2.Cfg.{u1, u2, u3, u4} K _inst_1 Γ Λ σ} {c' : Turing.TM2.Cfg.{u1, u2, u3, u4} K _inst_1 Γ Λ σ}, (Membership.Mem.{max u1 u2 u3 u4, max u1 u2 u3 u4} (Turing.TM2.Cfg.{u1, u2, u3, u4} K _inst_1 Γ Λ σ) (Option.{max u1 u2 u3 u4} (Turing.TM2.Cfg.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) (Option.hasMem.{max u1 u2 u3 u4} (Turing.TM2.Cfg.{u1, u2, u3, u4} K _inst_1 Γ Λ σ)) c' (Turing.TM2.step.{u1, u2, u3, u4} K _inst_1 Γ Λ σ M c)) -> (Membership.Mem.{u3, u3} (Option.{u3} Λ) (Finset.{u3} (Option.{u3} Λ)) (Finset.hasMem.{u3} (Option.{u3} Λ)) (Turing.TM2.Cfg.l.{u1, u2, u3, u4} K _inst_1 Γ Λ σ c) (coeFn.{succ u3, succ u3} (OrderEmbedding.{u3, u3} (Finset.{u3} Λ) (Finset.{u3} (Option.{u3} Λ)) (Preorder.toLE.{u3} (Finset.{u3} Λ) (PartialOrder.toPreorder.{u3} (Finset.{u3} Λ) (Finset.partialOrder.{u3} Λ))) (Preorder.toLE.{u3} (Finset.{u3} (Option.{u3} Λ)) (PartialOrder.toPreorder.{u3} (Finset.{u3} (Option.{u3} Λ)) (Finset.partialOrder.{u3} (Option.{u3} Λ))))) (fun (_x : RelEmbedding.{u3, u3} (Finset.{u3} Λ) (Finset.{u3} (Option.{u3} Λ)) (LE.le.{u3} (Finset.{u3} Λ) (Preorder.toLE.{u3} (Finset.{u3} Λ) (PartialOrder.toPreorder.{u3} (Finset.{u3} Λ) (Finset.partialOrder.{u3} Λ)))) (LE.le.{u3} (Finset.{u3} (Option.{u3} Λ)) (Preorder.toLE.{u3} (Finset.{u3} (Option.{u3} Λ)) (PartialOrder.toPreorder.{u3} (Finset.{u3} (Option.{u3} Λ)) (Finset.partialOrder.{u3} (Option.{u3} Λ)))))) => (Finset.{u3} Λ) -> (Finset.{u3} (Option.{u3} Λ))) (RelEmbedding.hasCoeToFun.{u3, u3} (Finset.{u3} Λ) (Finset.{u3} (Option.{u3} Λ)) (LE.le.{u3} (Finset.{u3} Λ) (Preorder.toLE.{u3} (Finset.{u3} Λ) (PartialOrder.toPreorder.{u3} (Finset.{u3} Λ) (Finset.partialOrder.{u3} Λ)))) (LE.le.{u3} (Finset.{u3} (Option.{u3} Λ)) (Preorder.toLE.{u3} (Finset.{u3} (Option.{u3} Λ)) (PartialOrder.toPreorder.{u3} (Finset.{u3} (Option.{u3} Λ)) (Finset.partialOrder.{u3} (Option.{u3} Λ)))))) (Finset.insertNone.{u3} Λ) S)) -> (Membership.Mem.{u3, u3} (Option.{u3} Λ) (Finset.{u3} (Option.{u3} Λ)) (Finset.hasMem.{u3} (Option.{u3} Λ)) (Turing.TM2.Cfg.l.{u1, u2, u3, u4} K _inst_1 Γ Λ σ c') (coeFn.{succ u3, succ u3} (OrderEmbedding.{u3, u3} (Finset.{u3} Λ) (Finset.{u3} (Option.{u3} Λ)) (Preorder.toLE.{u3} (Finset.{u3} Λ) (PartialOrder.toPreorder.{u3} (Finset.{u3} Λ) (Finset.partialOrder.{u3} Λ))) (Preorder.toLE.{u3} (Finset.{u3} (Option.{u3} Λ)) (PartialOrder.toPreorder.{u3} (Finset.{u3} (Option.{u3} Λ)) (Finset.partialOrder.{u3} (Option.{u3} Λ))))) (fun (_x : RelEmbedding.{u3, u3} (Finset.{u3} Λ) (Finset.{u3} (Option.{u3} Λ)) (LE.le.{u3} (Finset.{u3} Λ) (Preorder.toLE.{u3} (Finset.{u3} Λ) (PartialOrder.toPreorder.{u3} (Finset.{u3} Λ) (Finset.partialOrder.{u3} Λ)))) (LE.le.{u3} (Finset.{u3} (Option.{u3} Λ)) (Preorder.toLE.{u3} (Finset.{u3} (Option.{u3} Λ)) (PartialOrder.toPreorder.{u3} (Finset.{u3} (Option.{u3} Λ)) (Finset.partialOrder.{u3} (Option.{u3} Λ)))))) => (Finset.{u3} Λ) -> (Finset.{u3} (Option.{u3} Λ))) (RelEmbedding.hasCoeToFun.{u3, u3} (Finset.{u3} Λ) (Finset.{u3} (Option.{u3} Λ)) (LE.le.{u3} (Finset.{u3} Λ) (Preorder.toLE.{u3} (Finset.{u3} Λ) (PartialOrder.toPreorder.{u3} (Finset.{u3} Λ) (Finset.partialOrder.{u3} Λ)))) (LE.le.{u3} (Finset.{u3} (Option.{u3} Λ)) (Preorder.toLE.{u3} (Finset.{u3} (Option.{u3} Λ)) (PartialOrder.toPreorder.{u3} (Finset.{u3} (Option.{u3} Λ)) (Finset.partialOrder.{u3} (Option.{u3} Λ)))))) (Finset.insertNone.{u3} Λ) S)))
but is expected to have type
  forall {K : Type.{u4}} [_inst_1 : DecidableEq.{succ u4} K] {Γ : K -> Type.{u3}} {Λ : Type.{u2}} {σ : Type.{u1}} [_inst_2 : Inhabited.{succ u2} Λ] (M : Λ -> (Turing.TM2.Stmt.{u4, u3, u2, u1} K Γ Λ σ)) {S : Finset.{u2} Λ}, (Turing.TM2.Supports.{u4, u3, u2, u1} K Γ Λ σ _inst_2 M S) -> (forall {c : Turing.TM2.Cfg.{u4, u3, u2, u1} K Γ Λ σ} {c' : Turing.TM2.Cfg.{u4, u3, u2, u1} K Γ Λ σ}, (Membership.mem.{max (max (max u4 u3) u2) u1, max (max (max u1 u2) u3) u4} (Turing.TM2.Cfg.{u4, u3, u2, u1} K Γ Λ σ) (Option.{max (max (max u1 u2) u3) u4} (Turing.TM2.Cfg.{u4, u3, u2, u1} K Γ Λ σ)) (Option.instMembershipOption.{max (max (max u4 u3) u2) u1} (Turing.TM2.Cfg.{u4, u3, u2, u1} K Γ Λ σ)) c' (Turing.TM2.step.{u4, u3, u2, u1} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ M c)) -> (Membership.mem.{u2, u2} (Option.{u2} Λ) ((fun (x._@.Mathlib.Order.RelIso.Basic._hyg.867 : Finset.{u2} Λ) => Finset.{u2} (Option.{u2} Λ)) S) (Finset.instMembershipFinset.{u2} (Option.{u2} Λ)) (Turing.TM2.Cfg.l.{u4, u3, u2, u1} K Γ Λ σ c) (FunLike.coe.{succ u2, succ u2, succ u2} (OrderEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ))))) (Finset.{u2} Λ) (fun (_x : Finset.{u2} Λ) => (fun (x._@.Mathlib.Order.RelIso.Basic._hyg.867 : Finset.{u2} Λ) => Finset.{u2} (Option.{u2} Λ)) _x) (RelHomClass.toFunLike.{u2, u2, u2} (OrderEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ))))) (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : Finset.{u2} Λ) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : Finset.{u2} Λ) => LE.le.{u2} (Finset.{u2} Λ) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Finset.{u2} (Option.{u2} Λ)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Finset.{u2} (Option.{u2} Λ)) => LE.le.{u2} (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ)))) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (RelEmbedding.instRelHomClassRelEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : Finset.{u2} Λ) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : Finset.{u2} Λ) => LE.le.{u2} (Finset.{u2} Λ) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Finset.{u2} (Option.{u2} Λ)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Finset.{u2} (Option.{u2} Λ)) => LE.le.{u2} (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ)))) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697))) (Finset.insertNone.{u2} Λ) S)) -> (Membership.mem.{u2, u2} (Option.{u2} Λ) ((fun (x._@.Mathlib.Order.RelIso.Basic._hyg.867 : Finset.{u2} Λ) => Finset.{u2} (Option.{u2} Λ)) S) (Finset.instMembershipFinset.{u2} (Option.{u2} Λ)) (Turing.TM2.Cfg.l.{u4, u3, u2, u1} K Γ Λ σ c') (FunLike.coe.{succ u2, succ u2, succ u2} (OrderEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ))))) (Finset.{u2} Λ) (fun (_x : Finset.{u2} Λ) => (fun (x._@.Mathlib.Order.RelIso.Basic._hyg.867 : Finset.{u2} Λ) => Finset.{u2} (Option.{u2} Λ)) _x) (RelHomClass.toFunLike.{u2, u2, u2} (OrderEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ))))) (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : Finset.{u2} Λ) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : Finset.{u2} Λ) => LE.le.{u2} (Finset.{u2} Λ) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Finset.{u2} (Option.{u2} Λ)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Finset.{u2} (Option.{u2} Λ)) => LE.le.{u2} (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ)))) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (RelEmbedding.instRelHomClassRelEmbedding.{u2, u2} (Finset.{u2} Λ) (Finset.{u2} (Option.{u2} Λ)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : Finset.{u2} Λ) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : Finset.{u2} Λ) => LE.le.{u2} (Finset.{u2} Λ) (Preorder.toLE.{u2} (Finset.{u2} Λ) (PartialOrder.toPreorder.{u2} (Finset.{u2} Λ) (Finset.partialOrder.{u2} Λ))) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Finset.{u2} (Option.{u2} Λ)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Finset.{u2} (Option.{u2} Λ)) => LE.le.{u2} (Finset.{u2} (Option.{u2} Λ)) (Preorder.toLE.{u2} (Finset.{u2} (Option.{u2} Λ)) (PartialOrder.toPreorder.{u2} (Finset.{u2} (Option.{u2} Λ)) (Finset.partialOrder.{u2} (Option.{u2} Λ)))) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697))) (Finset.insertNone.{u2} Λ) S)))
Case conversion may be inaccurate. Consider using '#align turing.TM2.step_supports Turing.TM2.step_supportsₓ'. -/
theorem step_supports (M : Λ → stmt) {S} (ss : supports M S) :
    ∀ {c c' : cfg}, c' ∈ step M c → c.l ∈ S.insertNone → c'.l ∈ S.insertNone
  | ⟨some l₁, v, T⟩, c', h₁, h₂ =>
    by
    replace h₂ := ss.2 _ (Finset.some_mem_insertNone.1 h₂)
    simp only [step, Option.mem_def] at h₁; subst c'
    revert h₂; induction' M l₁ with _ _ q IH _ _ q IH _ _ q IH _ q IH generalizing v T <;> intro hs
    iterate 4 exact IH _ _ hs
    case branch p q₁' q₂' IH₁ IH₂ =>
      unfold step_aux; cases p v
      · exact IH₂ _ _ hs.2
      · exact IH₁ _ _ hs.1
    case goto => exact Finset.some_mem_insertNone.2 (hs _)
    case halt => apply Multiset.mem_cons_self
#align turing.TM2.step_supports Turing.TM2.step_supports

variable [Inhabited σ]

#print Turing.TM2.init /-
/-- The initial state of the TM2 model. The input is provided on a designated stack. -/
def init (k) (L : List (Γ k)) : cfg :=
  ⟨some default, default, update (fun _ => []) k L⟩
#align turing.TM2.init Turing.TM2.init
-/

#print Turing.TM2.eval /-
/-- Evaluates a TM2 program to completion, with the output on the same stack as the input. -/
def eval (M : Λ → stmt) (k) (L : List (Γ k)) : Part (List (Γ k)) :=
  (eval (step M) (init k L)).map fun c => c.stk k
#align turing.TM2.eval Turing.TM2.eval
-/

end

end TM2

/-!
## TM2 emulator in TM1

To prove that TM2 computable functions are TM1 computable, we need to reduce each TM2 program to a
TM1 program. So suppose a TM2 program is given. This program has to maintain a whole collection of
stacks, but we have only one tape, so we must "multiplex" them all together. Pictorially, if stack
1 contains `[a, b]` and stack 2 contains `[c, d, e, f]` then the tape looks like this:

```
 bottom:  ... | _ | T | _ | _ | _ | _ | ...
 stack 1: ... | _ | b | a | _ | _ | _ | ...
 stack 2: ... | _ | f | e | d | c | _ | ...
```

where a tape element is a vertical slice through the diagram. Here the alphabet is
`Γ' := bool × ∀ k, option (Γ k)`, where:

* `bottom : bool` is marked only in one place, the initial position of the TM, and represents the
  tail of all stacks. It is never modified.
* `stk k : option (Γ k)` is the value of the `k`-th stack, if in range, otherwise `none` (which is
  the blank value). Note that the head of the stack is at the far end; this is so that push and pop
  don't have to do any shifting.

In "resting" position, the TM is sitting at the position marked `bottom`. For non-stack actions,
it operates in place, but for the stack actions `push`, `peek`, and `pop`, it must shuttle to the
end of the appropriate stack, make its changes, and then return to the bottom. So the states are:

* `normal (l : Λ)`: waiting at `bottom` to execute function `l`
* `go k (s : st_act k) (q : stmt₂)`: travelling to the right to get to the end of stack `k` in
  order to perform stack action `s`, and later continue with executing `q`
* `ret (q : stmt₂)`: travelling to the left after having performed a stack action, and executing
  `q` once we arrive

Because of the shuttling, emulation overhead is `O(n)`, where `n` is the current maximum of the
length of all stacks. Therefore a program that takes `k` steps to run in TM2 takes `O((m+k)k)`
steps to run when emulated in TM1, where `m` is the length of the input.
-/


namespace TM2to1

/- warning: turing.TM2to1.stk_nth_val -> Turing.TM2to1.stk_nth_val is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} {Γ : K -> Type.{u2}} {L : Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))} {k : K} {S : List.{u2} (Γ k)} (n : Nat), (Eq.{succ u2} (Turing.ListBlank.{u2} (Option.{u2} (Γ k)) (Option.inhabited.{u2} (Γ k))) (Turing.ListBlank.map.{max u1 u2, u2} (forall (i : K), Option.{u2} (Γ i)) (Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (i : K) => Option.{u2} (Γ i)) (fun (x : K) => Option.inhabited.{u2} (Γ x))) (Option.inhabited.{u2} (Γ k)) (Turing.proj.{u1, u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)) k) L) (Turing.ListBlank.mk.{u2} (Option.{u2} (Γ k)) (Option.inhabited.{u2} (Γ k)) (List.reverse.{u2} (Option.{u2} (Γ k)) (List.map.{u2, u2} (Γ k) (Option.{u2} (Γ k)) (Option.some.{u2} (Γ k)) S)))) -> (Eq.{succ u2} (Option.{u2} (Γ k)) (Turing.ListBlank.nth.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x))) L n k) (List.get?.{u2} (Γ k) (List.reverse.{u2} (Γ k) S) n))
but is expected to have type
  forall {K : Type.{u2}} {Γ : K -> Type.{u1}} {L : Turing.ListBlank.{max u2 u1} (forall (k : K), Option.{u1} (Γ k)) (instInhabitedForAll_1.{succ u2, succ u1} K (fun (k : K) => Option.{u1} (Γ k)) (fun (x : K) => instInhabitedOption.{u1} (Γ x)))} {k : K} {S : List.{u1} (Γ k)} (n : Nat), (Eq.{succ u1} (Turing.ListBlank.{u1} (Option.{u1} (Γ k)) (instInhabitedOption.{u1} (Γ k))) (Turing.ListBlank.map.{max u1 u2, u1} (forall (i : K), Option.{u1} (Γ i)) (Option.{u1} (Γ k)) (instInhabitedForAll_1.{succ u2, succ u1} K (fun (i : K) => Option.{u1} (Γ i)) (fun (x : K) => instInhabitedOption.{u1} (Γ x))) (instInhabitedOption.{u1} (Γ k)) (Turing.proj.{u2, u1} K (fun (k : K) => Option.{u1} (Γ k)) (fun (x : K) => instInhabitedOption.{u1} (Γ x)) k) L) (Turing.ListBlank.mk.{u1} (Option.{u1} (Γ k)) (instInhabitedOption.{u1} (Γ k)) (List.reverse.{u1} (Option.{u1} (Γ k)) (List.map.{u1, u1} (Γ k) (Option.{u1} (Γ k)) (Option.some.{u1} (Γ k)) S)))) -> (Eq.{succ u1} (Option.{u1} (Γ k)) (Turing.ListBlank.nth.{max u2 u1} (forall (k : K), Option.{u1} (Γ k)) (instInhabitedForAll_1.{succ u2, succ u1} K (fun (k : K) => Option.{u1} (Γ k)) (fun (x : K) => instInhabitedOption.{u1} (Γ x))) L n k) (List.get?.{u1} (Γ k) (List.reverse.{u1} (Γ k) S) n))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.stk_nth_val Turing.TM2to1.stk_nth_valₓ'. -/
-- A displaced lemma proved in unnecessary generality
theorem stk_nth_val {K : Type _} {Γ : K → Type _} {L : ListBlank (∀ k, Option (Γ k))} {k S} (n)
    (hL : ListBlank.map (proj k) L = ListBlank.mk (List.map some S).reverse) :
    L.get? n k = S.reverse.get? n :=
  by
  rw [← proj_map_nth, hL, ← List.map_reverse, list_blank.nth_mk, List.getI_eq_iget_get?,
    List.get?_map]
  cases S.reverse.nth n <;> rfl
#align turing.TM2to1.stk_nth_val Turing.TM2to1.stk_nth_val

section

parameter {K : Type _}[DecidableEq K]

parameter {Γ : K → Type _}

parameter {Λ : Type _}[Inhabited Λ]

parameter {σ : Type _}[Inhabited σ]

-- mathport name: exprstmt₂
local notation "stmt₂" => TM2.Stmt Γ Λ σ

-- mathport name: exprcfg₂
local notation "cfg₂" => TM2.Cfg Γ Λ σ

/- warning: turing.TM2to1.Γ' -> Turing.TM2to1.Γ' is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}}, Type.{max u1 u2}
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}}, Type.{max u1 u2}
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.Γ' Turing.TM2to1.Γ'ₓ'. -/
-- [decidable_eq K]: Because K is a parameter, we cannot easily skip
-- the decidable_eq assumption, and this is a local definition anyway so it's not important.
/-- The alphabet of the TM2 simulator on TM1 is a marker for the stack bottom,
plus a vector of stack elements for each stack, or none if the stack does not extend this far. -/
@[nolint unused_arguments]
def Γ' :=
  Bool × ∀ k, Option (Γ k)
#align turing.TM2to1.Γ' Turing.TM2to1.Γ'

/- warning: turing.TM2to1.Γ'.inhabited -> Turing.TM2to1.Γ'.inhabited is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}}, Inhabited.{succ (max u1 u2)} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ)
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}}, Inhabited.{max (succ u2) (succ u1)} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1)
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.Γ'.inhabited Turing.TM2to1.Γ'.inhabitedₓ'. -/
instance Γ'.inhabited : Inhabited Γ' :=
  ⟨⟨false, fun _ => none⟩⟩
#align turing.TM2to1.Γ'.inhabited Turing.TM2to1.Γ'.inhabited

#print Turing.TM2to1.Γ'.fintype /-
instance Γ'.fintype [Fintype K] [∀ k, Fintype (Γ k)] : Fintype Γ' :=
  Prod.fintype _ _
#align turing.TM2to1.Γ'.fintype Turing.TM2to1.Γ'.fintype
-/

/- warning: turing.TM2to1.add_bottom -> Turing.TM2to1.addBottom is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}}, (Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))) -> (Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ))
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}}, (Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (_inst_1 k)) (instInhabitedForAll_1.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (_inst_1 k)) (fun (a : K) => instInhabitedOption.{u2} (_inst_1 a)))) -> (Turing.ListBlank.{max u2 u1} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.add_bottom Turing.TM2to1.addBottomₓ'. -/
/-- The bottom marker is fixed throughout the calculation, so we use the `add_bottom` function
to express the program state in terms of a tape with only the stacks themselves. -/
def addBottom (L : ListBlank (∀ k, Option (Γ k))) : ListBlank Γ' :=
  ListBlank.cons (true, L.headI) (L.tail.map ⟨Prod.mk false, rfl⟩)
#align turing.TM2to1.add_bottom Turing.TM2to1.addBottom

/- warning: turing.TM2to1.add_bottom_map -> Turing.TM2to1.addBottom_map is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} (L : Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))), Eq.{succ (max u1 u2)} (Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))) (Turing.ListBlank.map.{max u1 u2, max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (forall (k : K), Option.{u2} (Γ k)) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x))) (Turing.PointedMap.mk.{max u1 u2, max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (forall (k : K), Option.{u2} (Γ k)) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x))) (Prod.snd.{0, max u1 u2} Bool (forall (k : K), Option.{u2} (Γ k))) (rfl.{succ (max u1 u2)} (forall (k : K), Option.{u2} (Γ k)) (Prod.snd.{0, max u1 u2} Bool (forall (k : K), Option.{u2} (Γ k)) (Inhabited.default.{succ (max u1 u2)} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ))))) (Turing.TM2to1.addBottom.{u1, u2} K _inst_1 Γ L)) L
but is expected to have type
  forall {K : Type.{u2}} {_inst_1 : K -> Type.{u1}} (Γ : Turing.ListBlank.{max u2 u1} (forall (k : K), Option.{u1} (_inst_1 k)) (instInhabitedForAll_1.{succ u2, succ u1} K (fun (k : K) => Option.{u1} (_inst_1 k)) (fun (a : K) => instInhabitedOption.{u1} (_inst_1 a)))), Eq.{max (succ u2) (succ u1)} (Turing.ListBlank.{max u2 u1} (forall (k : K), Option.{u1} ((fun (k : K) => _inst_1 k) k)) (instInhabitedForAll_1.{succ u2, succ u1} K (fun (k : K) => Option.{u1} ((fun (k : K) => _inst_1 k) k)) (fun (a : K) => instInhabitedOption.{u1} ((fun (k : K) => _inst_1 k) a)))) (Turing.ListBlank.map.{max u2 u1, max u2 u1} (Prod.{0, max u2 u1} Bool (forall (k : K), Option.{u1} ((fun (k : K) => _inst_1 k) k))) (forall (k : K), Option.{u1} ((fun (k : K) => _inst_1 k) k)) (Turing.TM2to1.Γ'.inhabited.{u2, u1} K (fun (k : K) => _inst_1 k)) (instInhabitedForAll_1.{succ u2, succ u1} K (fun (k : K) => Option.{u1} ((fun (k : K) => _inst_1 k) k)) (fun (a : K) => instInhabitedOption.{u1} ((fun (k : K) => _inst_1 k) a))) (Turing.PointedMap.mk.{max u2 u1, max u2 u1} (Prod.{0, max u2 u1} Bool (forall (k : K), Option.{u1} ((fun (k : K) => _inst_1 k) k))) (forall (k : K), Option.{u1} ((fun (k : K) => _inst_1 k) k)) (Turing.TM2to1.Γ'.inhabited.{u2, u1} K (fun (k : K) => _inst_1 k)) (instInhabitedForAll_1.{succ u2, succ u1} K (fun (k : K) => Option.{u1} ((fun (k : K) => _inst_1 k) k)) (fun (a : K) => instInhabitedOption.{u1} ((fun (k : K) => _inst_1 k) a))) (Prod.snd.{0, max u2 u1} Bool (forall (k : K), Option.{u1} ((fun (k : K) => _inst_1 k) k))) (Eq.refl.{succ (max u2 u1)} (forall (k : K), Option.{u1} ((fun (k : K) => _inst_1 k) k)) (Prod.snd.{0, max u2 u1} Bool (forall (k : K), Option.{u1} ((fun (k : K) => _inst_1 k) k)) (Inhabited.default.{succ (max u2 u1)} (Prod.{0, max u2 u1} Bool (forall (k : K), Option.{u1} ((fun (k : K) => _inst_1 k) k))) (Turing.TM2to1.Γ'.inhabited.{u2, u1} K (fun (k : K) => _inst_1 k)))))) (Turing.TM2to1.addBottom.{u2, u1} K (fun (k : K) => _inst_1 k) Γ)) Γ
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.add_bottom_map Turing.TM2to1.addBottom_mapₓ'. -/
theorem addBottom_map (L) : (add_bottom L).map ⟨Prod.snd, rfl⟩ = L :=
  by
  simp only [add_bottom, list_blank.map_cons] <;> convert list_blank.cons_head_tail _
  generalize list_blank.tail L = L'
  refine' L'.induction_on fun l => _; simp
#align turing.TM2to1.add_bottom_map Turing.TM2to1.addBottom_map

/- warning: turing.TM2to1.add_bottom_modify_nth -> Turing.TM2to1.addBottom_modifyNth is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} (f : (forall (k : K), Option.{u2} (Γ k)) -> (forall (k : K), Option.{u2} (Γ k))) (L : Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))) (n : Nat), Eq.{succ (max u1 u2)} (Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Turing.ListBlank.modifyNth.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (fun (a : Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) => Prod.mk.{0, max u1 u2} Bool (forall (k : K), Option.{u2} (Γ k)) (Prod.fst.{0, max u1 u2} Bool (forall (k : K), Option.{u2} (Γ k)) a) (f (Prod.snd.{0, max u1 u2} Bool (forall (k : K), Option.{u2} (Γ k)) a))) n (Turing.TM2to1.addBottom.{u1, u2} K _inst_1 Γ L)) (Turing.TM2to1.addBottom.{u1, u2} K _inst_1 Γ (Turing.ListBlank.modifyNth.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x))) f n L))
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} (Γ : (forall (k : K), Option.{u2} (_inst_1 k)) -> (forall (k : K), Option.{u2} (_inst_1 k))) (f : Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (_inst_1 k)) (instInhabitedForAll_1.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (_inst_1 k)) (fun (a : K) => instInhabitedOption.{u2} (_inst_1 a)))) (L : Nat), Eq.{max (succ u1) (succ u2)} (Turing.ListBlank.{max u1 u2} (Prod.{0, max u1 u2} Bool (forall (k : K), Option.{u2} (_inst_1 k))) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K (fun (k : K) => _inst_1 k))) (Turing.ListBlank.modifyNth.{max u1 u2} (Prod.{0, max u1 u2} Bool (forall (k : K), Option.{u2} (_inst_1 k))) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K (fun (k : K) => _inst_1 k)) (fun (a : Prod.{0, max u1 u2} Bool (forall (k : K), Option.{u2} (_inst_1 k))) => Prod.mk.{0, max u1 u2} Bool (forall (k : K), Option.{u2} (_inst_1 k)) (Prod.fst.{0, max u1 u2} Bool (forall (k : K), Option.{u2} (_inst_1 k)) a) (Γ (Prod.snd.{0, max u1 u2} Bool (forall (k : K), Option.{u2} (_inst_1 k)) a))) L (Turing.TM2to1.addBottom.{u1, u2} K (fun (k : K) => _inst_1 k) f)) (Turing.TM2to1.addBottom.{u1, u2} K (fun (k : K) => _inst_1 k) (Turing.ListBlank.modifyNth.{max u2 u1} (forall (k : K), Option.{u2} (_inst_1 k)) (instInhabitedForAll_1.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (_inst_1 k)) (fun (a : K) => instInhabitedOption.{u2} (_inst_1 a))) Γ L f))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.add_bottom_modify_nth Turing.TM2to1.addBottom_modifyNthₓ'. -/
theorem addBottom_modifyNth (f : (∀ k, Option (Γ k)) → ∀ k, Option (Γ k)) (L n) :
    (add_bottom L).modifyNth (fun a => (a.1, f a.2)) n = add_bottom (L.modifyNth f n) :=
  by
  cases n <;>
    simp only [add_bottom, list_blank.head_cons, list_blank.modify_nth, list_blank.tail_cons]
  congr ; symm; apply list_blank.map_modify_nth; intro ; rfl
#align turing.TM2to1.add_bottom_modify_nth Turing.TM2to1.addBottom_modifyNth

/- warning: turing.TM2to1.add_bottom_nth_snd -> Turing.TM2to1.addBottom_nth_snd is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} (L : Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))) (n : Nat), Eq.{max (succ u1) (succ u2)} (forall (k : K), Option.{u2} (Γ k)) (Prod.snd.{0, max u1 u2} Bool (forall (k : K), Option.{u2} (Γ k)) (Turing.ListBlank.nth.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.addBottom.{u1, u2} K _inst_1 Γ L) n)) (Turing.ListBlank.nth.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x))) L n)
but is expected to have type
  forall {K : Type.{u2}} {_inst_1 : K -> Type.{u1}} (Γ : Turing.ListBlank.{max u2 u1} (forall (k : K), Option.{u1} (_inst_1 k)) (instInhabitedForAll_1.{succ u2, succ u1} K (fun (k : K) => Option.{u1} (_inst_1 k)) (fun (a : K) => instInhabitedOption.{u1} (_inst_1 a)))) (L : Nat), Eq.{max (succ u2) (succ u1)} (forall (k : K), Option.{u1} ((fun (k : K) => _inst_1 k) k)) (Prod.snd.{0, max u2 u1} Bool (forall (k : K), Option.{u1} ((fun (k : K) => _inst_1 k) k)) (Turing.ListBlank.nth.{max u2 u1} (Turing.TM2to1.Γ'.{u2, u1} K (fun (k : K) => _inst_1 k)) (Turing.TM2to1.Γ'.inhabited.{u2, u1} K (fun (k : K) => _inst_1 k)) (Turing.TM2to1.addBottom.{u2, u1} K (fun (k : K) => _inst_1 k) Γ) L)) (Turing.ListBlank.nth.{max u2 u1} (forall (k : K), Option.{u1} (_inst_1 k)) (instInhabitedForAll_1.{succ u2, succ u1} K (fun (k : K) => Option.{u1} (_inst_1 k)) (fun (a : K) => instInhabitedOption.{u1} (_inst_1 a))) Γ L)
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.add_bottom_nth_snd Turing.TM2to1.addBottom_nth_sndₓ'. -/
theorem addBottom_nth_snd (L n) : ((add_bottom L).get? n).2 = L.get? n := by
  conv =>
      rhs
      rw [← add_bottom_map L, list_blank.nth_map] <;>
    rfl
#align turing.TM2to1.add_bottom_nth_snd Turing.TM2to1.addBottom_nth_snd

/- warning: turing.TM2to1.add_bottom_nth_succ_fst -> Turing.TM2to1.addBottom_nth_succ_fst is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} (L : Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))) (n : Nat), Eq.{1} Bool (Prod.fst.{0, max u1 u2} Bool (forall (k : K), Option.{u2} (Γ k)) (Turing.ListBlank.nth.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.addBottom.{u1, u2} K _inst_1 Γ L) (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) Bool.false
but is expected to have type
  forall {K : Type.{u2}} {_inst_1 : K -> Type.{u1}} (Γ : Turing.ListBlank.{max u2 u1} (forall (k : K), Option.{u1} (_inst_1 k)) (instInhabitedForAll_1.{succ u2, succ u1} K (fun (k : K) => Option.{u1} (_inst_1 k)) (fun (a : K) => instInhabitedOption.{u1} (_inst_1 a)))) (L : Nat), Eq.{1} Bool (Prod.fst.{0, max u2 u1} Bool (forall (k : K), Option.{u1} ((fun (k : K) => _inst_1 k) k)) (Turing.ListBlank.nth.{max u2 u1} (Turing.TM2to1.Γ'.{u2, u1} K (fun (k : K) => _inst_1 k)) (Turing.TM2to1.Γ'.inhabited.{u2, u1} K (fun (k : K) => _inst_1 k)) (Turing.TM2to1.addBottom.{u2, u1} K (fun (k : K) => _inst_1 k) Γ) (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) L (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) Bool.false
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.add_bottom_nth_succ_fst Turing.TM2to1.addBottom_nth_succ_fstₓ'. -/
theorem addBottom_nth_succ_fst (L n) : ((add_bottom L).get? (n + 1)).1 = false := by
  rw [list_blank.nth_succ, add_bottom, list_blank.tail_cons, list_blank.nth_map] <;> rfl
#align turing.TM2to1.add_bottom_nth_succ_fst Turing.TM2to1.addBottom_nth_succ_fst

/- warning: turing.TM2to1.add_bottom_head_fst -> Turing.TM2to1.addBottom_head_fst is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} (L : Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))), Eq.{1} Bool (Prod.fst.{0, max u1 u2} Bool (forall (k : K), Option.{u2} (Γ k)) (Turing.ListBlank.head.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.addBottom.{u1, u2} K _inst_1 Γ L))) Bool.true
but is expected to have type
  forall {K : Type.{u2}} {_inst_1 : K -> Type.{u1}} (Γ : Turing.ListBlank.{max u2 u1} (forall (k : K), Option.{u1} (_inst_1 k)) (instInhabitedForAll_1.{succ u2, succ u1} K (fun (k : K) => Option.{u1} (_inst_1 k)) (fun (a : K) => instInhabitedOption.{u1} (_inst_1 a)))), Eq.{1} Bool (Prod.fst.{0, max u2 u1} Bool (forall (k : K), Option.{u1} ((fun (k : K) => _inst_1 k) k)) (Turing.ListBlank.head.{max u2 u1} (Turing.TM2to1.Γ'.{u2, u1} K (fun (k : K) => _inst_1 k)) (Turing.TM2to1.Γ'.inhabited.{u2, u1} K (fun (k : K) => _inst_1 k)) (Turing.TM2to1.addBottom.{u2, u1} K (fun (k : K) => _inst_1 k) Γ))) Bool.true
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.add_bottom_head_fst Turing.TM2to1.addBottom_head_fstₓ'. -/
theorem addBottom_head_fst (L) : (add_bottom L).headI.1 = true := by
  rw [add_bottom, list_blank.head_cons] <;> rfl
#align turing.TM2to1.add_bottom_head_fst Turing.TM2to1.addBottom_head_fst

/- warning: turing.TM2to1.st_act -> Turing.TM2to1.StAct is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ], K -> Sort.{max (succ u2) (succ u3)}
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u3}}, K -> Sort.{max (succ u2) (succ u3)}
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.st_act Turing.TM2to1.StActₓ'. -/
/-- A stack action is a command that interacts with the top of a stack. Our default position
is at the bottom of all the stacks, so we have to hold on to this action while going to the end
to modify the stack. -/
inductive StAct (k : K)
  | push : (σ → Γ k) → st_act
  | peek : (σ → Option (Γ k) → σ) → st_act
  | pop : (σ → Option (Γ k) → σ) → st_act
#align turing.TM2to1.st_act Turing.TM2to1.StAct

/- warning: turing.TM2to1.st_act.inhabited -> Turing.TM2to1.StAct.inhabited is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {k : K}, Inhabited.{max (succ u2) (succ u3)} (Turing.TM2to1.StAct.{u1, u2, u3} K _inst_1 Γ σ _inst_3 k)
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u3}} {σ : K}, Inhabited.{max (succ u2) (succ u3)} (Turing.TM2to1.StAct.{u1, u2, u3} K _inst_1 Γ σ)
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.st_act.inhabited Turing.TM2to1.StAct.inhabitedₓ'. -/
instance StAct.inhabited {k} : Inhabited (st_act k) :=
  ⟨st_act.peek fun s _ => s⟩
#align turing.TM2to1.st_act.inhabited Turing.TM2to1.StAct.inhabited

section

open StAct

/- warning: turing.TM2to1.st_run -> Turing.TM2to1.stRun is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] {k : K}, (Turing.TM2to1.StAct.{u1, u2, u4} K _inst_1 Γ σ _inst_3 k) -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ) -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ)
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u3}} {Λ : Type.{u4}} {_inst_2 : K}, (Turing.TM2to1.StAct.{u1, u2, u4} K _inst_1 Λ _inst_2) -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ) -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ)
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.st_run Turing.TM2to1.stRunₓ'. -/
-- [inhabited Λ]: as this is a local definition it is more trouble than
-- it is worth to omit the typeclass assumption without breaking the parameters
/-- The TM2 statement corresponding to a stack action. -/
@[nolint unused_arguments]
def stRun {k : K} : st_act k → stmt₂ → stmt₂
  | push f => TM2.Stmt.push k f
  | peek f => TM2.Stmt.peek k f
  | pop f => TM2.Stmt.pop k f
#align turing.TM2to1.st_run Turing.TM2to1.stRun

/- warning: turing.TM2to1.st_var -> Turing.TM2to1.stVar is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {k : K}, σ -> (List.{u2} (Γ k)) -> (Turing.TM2to1.StAct.{u1, u2, u3} K _inst_1 Γ σ _inst_3 k) -> σ
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u3}} {σ : K}, Γ -> (List.{u2} (_inst_1 σ)) -> (Turing.TM2to1.StAct.{u1, u2, u3} K _inst_1 Γ σ) -> Γ
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.st_var Turing.TM2to1.stVarₓ'. -/
/-- The effect of a stack action on the local variables, given the value of the stack. -/
def stVar {k : K} (v : σ) (l : List (Γ k)) : st_act k → σ
  | push f => v
  | peek f => f v l.head?
  | pop f => f v l.head?
#align turing.TM2to1.st_var Turing.TM2to1.stVar

/- warning: turing.TM2to1.st_write -> Turing.TM2to1.stWrite is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {σ : Type.{u3}} [_inst_3 : Inhabited.{succ u3} σ] {k : K}, σ -> (List.{u2} (Γ k)) -> (Turing.TM2to1.StAct.{u1, u2, u3} K _inst_1 Γ σ _inst_3 k) -> (List.{u2} (Γ k))
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u3}} {σ : K}, Γ -> (List.{u2} (_inst_1 σ)) -> (Turing.TM2to1.StAct.{u1, u2, u3} K _inst_1 Γ σ) -> (List.{u2} (_inst_1 σ))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.st_write Turing.TM2to1.stWriteₓ'. -/
/-- The effect of a stack action on the stack. -/
def stWrite {k : K} (v : σ) (l : List (Γ k)) : st_act k → List (Γ k)
  | push f => f v :: l
  | peek f => l
  | pop f => l.tail
#align turing.TM2to1.st_write Turing.TM2to1.stWrite

/- warning: turing.TM2to1.stmt_st_rec -> Turing.TM2to1.stmtStRec is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] {C : (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ) -> Sort.{u5}}, (forall (k : K) (s : Turing.TM2to1.StAct.{u1, u2, u4} K _inst_1 Γ σ _inst_3 k) (q : Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ), (C q) -> (C (Turing.TM2to1.stRun.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 k s q))) -> (forall (a : σ -> σ) (q : Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ), (C q) -> (C (Turing.TM2.Stmt.load.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ a q))) -> (forall (p : σ -> Bool) (q₁ : Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ) (q₂ : Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ), (C q₁) -> (C q₂) -> (C (Turing.TM2.Stmt.branch.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ p q₁ q₂))) -> (forall (l : σ -> Λ), C (Turing.TM2.Stmt.goto.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ l)) -> (C (Turing.TM2.Stmt.halt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ)) -> (forall (n : Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ), C n)
but is expected to have type
  forall {K : Type.{u2}} {_inst_1 : K -> Type.{u3}} {Γ : Type.{u4}} {Λ : Type.{u5}} {_inst_2 : (Turing.TM2.Stmt.{u2, u3, u4, u5} K _inst_1 Γ Λ) -> Sort.{u1}}, (forall (k : K) (s : Turing.TM2to1.StAct.{u2, u3, u5} K _inst_1 Λ k) (q : Turing.TM2.Stmt.{u2, u3, u4, u5} K _inst_1 Γ Λ), (_inst_2 q) -> (_inst_2 (Turing.TM2to1.stRun.{u2, u3, u4, u5} K _inst_1 Γ Λ k s q))) -> (forall (a : Λ -> Λ) (q : Turing.TM2.Stmt.{u2, u3, u4, u5} K _inst_1 Γ Λ), (_inst_2 q) -> (_inst_2 (Turing.TM2.Stmt.load.{u2, u3, u4, u5} K _inst_1 Γ Λ a q))) -> (forall (ᾰ : Λ -> Bool) (q₁ : Turing.TM2.Stmt.{u2, u3, u4, u5} K _inst_1 Γ Λ) (q₂ : Turing.TM2.Stmt.{u2, u3, u4, u5} K _inst_1 Γ Λ), (_inst_2 q₁) -> (_inst_2 q₂) -> (_inst_2 (Turing.TM2.Stmt.branch.{u2, u3, u4, u5} K _inst_1 Γ Λ ᾰ q₁ q₂))) -> (forall (k : Λ -> Γ), _inst_2 (Turing.TM2.Stmt.goto.{u2, u3, u4, u5} K _inst_1 Γ Λ k)) -> (_inst_2 (Turing.TM2.Stmt.halt.{u2, u3, u4, u5} K _inst_1 Γ Λ)) -> (forall (H₃ : Turing.TM2.Stmt.{u2, u3, u4, u5} K _inst_1 Γ Λ), _inst_2 H₃)
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.stmt_st_rec Turing.TM2to1.stmtStRecₓ'. -/
/-- We have partitioned the TM2 statements into "stack actions", which require going to the end
of the stack, and all other actions, which do not. This is a modified recursor which lumps the
stack actions into one. -/
@[elab_as_elim]
def stmtStRec.{l} {C : stmt₂ → Sort l} (H₁ : ∀ (k) (s : st_act k) (q) (IH : C q), C (st_run s q))
    (H₂ : ∀ (a q) (IH : C q), C (TM2.Stmt.load a q))
    (H₃ : ∀ (p q₁ q₂) (IH₁ : C q₁) (IH₂ : C q₂), C (TM2.Stmt.branch p q₁ q₂))
    (H₄ : ∀ l, C (TM2.Stmt.goto l)) (H₅ : C TM2.Stmt.halt) : ∀ n, C n
  | TM2.stmt.push k f q => H₁ _ (push f) _ (stmt_st_rec q)
  | TM2.stmt.peek k f q => H₁ _ (peek f) _ (stmt_st_rec q)
  | TM2.stmt.pop k f q => H₁ _ (pop f) _ (stmt_st_rec q)
  | TM2.stmt.load a q => H₂ _ _ (stmt_st_rec q)
  | TM2.stmt.branch a q₁ q₂ => H₃ _ _ _ (stmt_st_rec q₁) (stmt_st_rec q₂)
  | TM2.stmt.goto l => H₄ _
  | TM2.stmt.halt => H₅
#align turing.TM2to1.stmt_st_rec Turing.TM2to1.stmtStRec

/- warning: turing.TM2to1.supports_run -> Turing.TM2to1.supports_run is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] (S : Finset.{u3} Λ) {k : K} (s : Turing.TM2to1.StAct.{u1, u2, u4} K _inst_1 Γ σ _inst_3 k) (q : Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ), Iff (Turing.TM2.SupportsStmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ S (Turing.TM2to1.stRun.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 k s q)) (Turing.TM2.SupportsStmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ S q)
but is expected to have type
  forall {K : Type.{u3}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u4}} {Λ : Type.{u1}} (_inst_2 : Finset.{u4} Γ) {σ : K} (_inst_3 : Turing.TM2to1.StAct.{u3, u2, u1} K _inst_1 Λ σ) (S : Turing.TM2.Stmt.{u3, u2, u4, u1} K _inst_1 Γ Λ), Iff (Turing.TM2.SupportsStmt.{u3, u2, u4, u1} K _inst_1 Γ Λ _inst_2 (Turing.TM2to1.stRun.{u3, u2, u4, u1} K _inst_1 Γ Λ σ _inst_3 S)) (Turing.TM2.SupportsStmt.{u3, u2, u4, u1} K _inst_1 Γ Λ _inst_2 S)
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.supports_run Turing.TM2to1.supports_runₓ'. -/
theorem supports_run (S : Finset Λ) {k} (s : st_act k) (q) :
    TM2.SupportsStmt S (st_run s q) ↔ TM2.SupportsStmt S q := by rcases s with (_ | _ | _) <;> rfl
#align turing.TM2to1.supports_run Turing.TM2to1.supports_run

end

/- warning: turing.TM2to1.Λ' -> Turing.TM2to1.Λ' is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ], Type.{max u1 u2 u3 u4}
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u3}} {Λ : Type.{u4}}, Sort.{max (max (max (succ u1) (succ u2)) (succ u3)) (succ u4)}
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.Λ' Turing.TM2to1.Λ'ₓ'. -/
/-- The machine states of the TM2 emulator. We can either be in a normal state when waiting for the
next TM2 action, or we can be in the "go" and "return" states to go to the top of the stack and
return to the bottom, respectively. -/
inductive Λ' : Type max u_1 u_2 u_3 u_4
  | normal : Λ → Λ'
  | go (k) : st_act k → stmt₂ → Λ'
  | ret : stmt₂ → Λ'
#align turing.TM2to1.Λ' Turing.TM2to1.Λ'

open Λ'

/- warning: turing.TM2to1.Λ'.inhabited -> Turing.TM2to1.Λ'.inhabited is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ], Inhabited.{succ (max u1 u2 u3 u4)} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3)
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u3}} [Λ : Inhabited.{succ u3} Γ] {_inst_2 : Type.{u4}}, Inhabited.{max (max (max (succ u4) (succ u3)) (succ u2)) (succ u1)} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ _inst_2)
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.Λ'.inhabited Turing.TM2to1.Λ'.inhabitedₓ'. -/
instance Λ'.inhabited : Inhabited Λ' :=
  ⟨normal default⟩
#align turing.TM2to1.Λ'.inhabited Turing.TM2to1.Λ'.inhabited

-- mathport name: exprstmt₁
local notation "stmt₁" => TM1.Stmt Γ' Λ' σ

-- mathport name: exprcfg₁
local notation "cfg₁" => TM1.Cfg Γ' Λ' σ

open TM1.Stmt

/- warning: turing.TM2to1.tr_st_act -> Turing.TM2to1.trStAct is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] {k : K}, (Turing.TM1.Stmt.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ) -> (Turing.TM2to1.StAct.{u1, u2, u4} K _inst_1 Γ σ _inst_3 k) -> (Turing.TM1.Stmt.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} {_inst_2 : Type.{u4}} {σ : K}, (Turing.TM1.Stmt.{max u2 u1, max (max (max u4 u3) u2) u1, u4} (Turing.TM2to1.Γ'.{u1, u2} K Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K Γ Λ _inst_2) _inst_2) -> (Turing.TM2to1.StAct.{u1, u2, u4} K Γ _inst_2 σ) -> (Turing.TM1.Stmt.{max u2 u1, max (max (max u4 u3) u2) u1, u4} (Turing.TM2to1.Γ'.{u1, u2} K Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K Γ Λ _inst_2) _inst_2)
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_st_act Turing.TM2to1.trStActₓ'. -/
/-- The program corresponding to state transitions at the end of a stack. Here we start out just
after the top of the stack, and should end just after the new top of the stack. -/
def trStAct {k} (q : stmt₁) : st_act k → stmt₁
  | st_act.push f => (write fun a s => (a.1, update a.2 k <| some <| f s)) <| move Dir.right q
  | st_act.peek f => move Dir.left <| (load fun a s => f s (a.2 k)) <| move Dir.right q
  | st_act.pop f =>
    branch (fun a _ => a.1) (load (fun a s => f s none) q)
      (move Dir.left <|
        (load fun a s => f s (a.2 k)) <| write (fun a s => (a.1, update a.2 k none)) q)
#align turing.TM2to1.tr_st_act Turing.TM2to1.trStAct

#print Turing.TM2to1.trInit /-
/-- The initial state for the TM2 emulator, given an initial TM2 state. All stacks start out empty
except for the input stack, and the stack bottom mark is set at the head. -/
def trInit (k) (L : List (Γ k)) : List Γ' :=
  let L' : List Γ' := L.reverse.map fun a => (false, update (fun _ => none) k a)
  (true, L'.headI.2) :: L'.tail
#align turing.TM2to1.tr_init Turing.TM2to1.trInit
-/

/- warning: turing.TM2to1.step_run -> Turing.TM2to1.step_run is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] {k : K} (q : Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ) (v : σ) (S : forall (k : K), List.{u2} (Γ k)) (s : Turing.TM2to1.StAct.{u1, u2, u4} K _inst_1 Γ σ _inst_3 k), Eq.{max (succ u1) (succ u2) (succ u3) (succ u4)} (Turing.TM2.Cfg.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ) (Turing.TM2.stepAux.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ (Turing.TM2to1.stRun.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 k s q) v S) (Turing.TM2.stepAux.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ q (Turing.TM2to1.stVar.{u1, u2, u4} K _inst_1 Γ σ _inst_3 k v (S k) s) (Function.update.{succ u1, succ u2} K (fun (k : K) => List.{u2} (Γ k)) (fun (a : K) (b : K) => _inst_1 a b) S k (Turing.TM2to1.stWrite.{u1, u2, u4} K _inst_1 Γ σ _inst_3 k v (S k) s)))
but is expected to have type
  forall {K : Type.{u4}} [_inst_1 : DecidableEq.{succ u4} K] {Γ : K -> Type.{u3}} {Λ : Type.{u2}} {_inst_2 : Type.{u1}} {σ : K} (_inst_3 : Turing.TM2.Stmt.{u4, u3, u2, u1} K Γ Λ _inst_2) (k : _inst_2) (q : forall (k : K), List.{u3} (Γ k)) (v : Turing.TM2to1.StAct.{u4, u3, u1} K Γ _inst_2 σ), Eq.{max (max (max (succ u4) (succ u3)) (succ u2)) (succ u1)} (Turing.TM2.Cfg.{u4, u3, u2, u1} K Γ Λ _inst_2) (Turing.TM2.stepAux.{u4, u3, u2, u1} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ _inst_2 (Turing.TM2to1.stRun.{u4, u3, u2, u1} K Γ Λ _inst_2 σ v _inst_3) k q) (Turing.TM2.stepAux.{u4, u3, u2, u1} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ _inst_2 _inst_3 (Turing.TM2to1.stVar.{u4, u3, u1} K Γ _inst_2 σ k (q σ) v) (Function.update.{succ u4, succ u3} K (fun (k : K) => List.{u3} (Γ k)) (fun (a : K) (b : K) => _inst_1 a b) q σ (Turing.TM2to1.stWrite.{u4, u3, u1} K Γ _inst_2 σ k (q σ) v)))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.step_run Turing.TM2to1.step_runₓ'. -/
theorem step_run {k : K} (q v S) :
    ∀ s : st_act k,
      TM2.stepAux (st_run s q) v S =
        TM2.stepAux q (st_var v (S k) s) (update S k (st_write v (S k) s))
  | st_act.push f => rfl
  | st_act.peek f => by unfold st_write <;> rw [Function.update_eq_self] <;> rfl
  | st_act.pop f => rfl
#align turing.TM2to1.step_run Turing.TM2to1.step_run

/- warning: turing.TM2to1.tr_normal -> Turing.TM2to1.trNormal is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ], (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ) -> (Turing.TM1.Stmt.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ)
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u3}} {Λ : Type.{u4}}, (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ) -> (Turing.TM1.Stmt.{max u2 u1, max (max (max u4 u3) u2) u1, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ) Λ)
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_normal Turing.TM2to1.trNormalₓ'. -/
/-- The translation of TM2 statements to TM1 statements. regular actions have direct equivalents,
but stack actions are deferred by going to the corresponding `go` state, so that we can find the
appropriate stack top. -/
def trNormal : stmt₂ → stmt₁
  | TM2.stmt.push k f q => goto fun _ _ => go k (st_act.push f) q
  | TM2.stmt.peek k f q => goto fun _ _ => go k (st_act.peek f) q
  | TM2.stmt.pop k f q => goto fun _ _ => go k (st_act.pop f) q
  | TM2.stmt.load a q => load (fun _ => a) (tr_normal q)
  | TM2.stmt.branch f q₁ q₂ => branch (fun a => f) (tr_normal q₁) (tr_normal q₂)
  | TM2.stmt.goto l => goto fun a s => normal (l s)
  | TM2.stmt.halt => halt
#align turing.TM2to1.tr_normal Turing.TM2to1.trNormal

/- warning: turing.TM2to1.tr_normal_run -> Turing.TM2to1.trNormal_run is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] {k : K} (s : Turing.TM2to1.StAct.{u1, u2, u4} K _inst_1 Γ σ _inst_3 k) (q : Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ), Eq.{max (succ (max u1 u2)) (succ (max u1 u2 u3 u4)) (succ u4)} (Turing.TM1.Stmt.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ) (Turing.TM2to1.trNormal.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 (Turing.TM2to1.stRun.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 k s q)) (Turing.TM1.Stmt.goto.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (fun (_x : Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (_x : σ) => Turing.TM2to1.Λ'.go.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 k s q))
but is expected to have type
  forall {K : Type.{u4}} {_inst_1 : K -> Type.{u3}} {Γ : Type.{u1}} {Λ : Type.{u2}} {_inst_2 : K} (σ : Turing.TM2to1.StAct.{u4, u3, u2} K _inst_1 Λ _inst_2) (_inst_3 : Turing.TM2.Stmt.{u4, u3, u1, u2} K _inst_1 Γ Λ), Eq.{max (max (max (succ u4) (succ u3)) (succ u1)) (succ u2)} (Turing.TM1.Stmt.{max u3 u4, max (max (max u2 u1) u3) u4, u2} (Turing.TM2to1.Γ'.{u4, u3} K _inst_1) (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ) Λ) (Turing.TM2to1.trNormal.{u4, u3, u1, u2} K _inst_1 Γ Λ (Turing.TM2to1.stRun.{u4, u3, u1, u2} K _inst_1 Γ Λ _inst_2 σ _inst_3)) (Turing.TM1.Stmt.goto.{max u4 u3, max (max (max u2 u1) u3) u4, u2} (Turing.TM2to1.Γ'.{u4, u3} K _inst_1) (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ) Λ (fun (x._@.Mathlib.Computability.TuringMachine._hyg.57723 : Turing.TM2to1.Γ'.{u4, u3} K _inst_1) (x._@.Mathlib.Computability.TuringMachine._hyg.57725 : Λ) => Turing.TM2to1.Λ'.go.{u4, u3, u1, u2} K _inst_1 Γ Λ _inst_2 σ _inst_3))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_normal_run Turing.TM2to1.trNormal_runₓ'. -/
theorem trNormal_run {k} (s q) : tr_normal (st_run s q) = goto fun _ _ => go k s q := by
  rcases s with (_ | _ | _) <;> rfl
#align turing.TM2to1.tr_normal_run Turing.TM2to1.trNormal_run

open Classical

/- warning: turing.TM2to1.tr_stmts₁ -> Turing.TM2to1.trStmts₁ is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ], (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ) -> (Finset.{max u1 u2 u3 u4} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3))
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u3}} {Λ : Type.{u4}}, (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ) -> (Finset.{max (max (max u4 u3) u2) u1} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_stmts₁ Turing.TM2to1.trStmts₁ₓ'. -/
/-- The set of machine states accessible from an initial TM2 statement. -/
noncomputable def trStmts₁ : stmt₂ → Finset Λ'
  | TM2.stmt.push k f q => {go k (st_act.push f) q, ret q} ∪ tr_stmts₁ q
  | TM2.stmt.peek k f q => {go k (st_act.peek f) q, ret q} ∪ tr_stmts₁ q
  | TM2.stmt.pop k f q => {go k (st_act.pop f) q, ret q} ∪ tr_stmts₁ q
  | TM2.stmt.load a q => tr_stmts₁ q
  | TM2.stmt.branch f q₁ q₂ => tr_stmts₁ q₁ ∪ tr_stmts₁ q₂
  | _ => ∅
#align turing.TM2to1.tr_stmts₁ Turing.TM2to1.trStmts₁

/- warning: turing.TM2to1.tr_stmts₁_run -> Turing.TM2to1.trStmts₁_run is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] {k : K} {s : Turing.TM2to1.StAct.{u1, u2, u4} K _inst_1 Γ σ _inst_3 k} {q : Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ}, Eq.{succ (max u1 u2 u3 u4)} (Finset.{max u1 u2 u3 u4} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3)) (Turing.TM2to1.trStmts₁.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 (Turing.TM2to1.stRun.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 k s q)) (Union.union.{max u1 u2 u3 u4} (Finset.{max u1 u2 u3 u4} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3)) (Finset.hasUnion.{max u1 u2 u3 u4} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) (fun (a : Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) (b : Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) => Classical.propDecidable (Eq.{succ (max u1 u2 u3 u4)} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) a b))) (Insert.insert.{max u1 u2 u3 u4, max u1 u2 u3 u4} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) (Finset.{max u1 u2 u3 u4} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3)) (Finset.hasInsert.{max u1 u2 u3 u4} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) (fun (a : Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) (b : Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) => Classical.propDecidable (Eq.{succ (max u1 u2 u3 u4)} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) a b))) (Turing.TM2to1.Λ'.go.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 k s q) (Singleton.singleton.{max u1 u2 u3 u4, max u1 u2 u3 u4} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) (Finset.{max u1 u2 u3 u4} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3)) (Finset.hasSingleton.{max u1 u2 u3 u4} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3)) (Turing.TM2to1.Λ'.ret.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 q))) (Turing.TM2to1.trStmts₁.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 q))
but is expected to have type
  forall {K : Type.{u4}} {_inst_1 : K -> Type.{u3}} {Γ : Type.{u1}} {Λ : Type.{u2}} {_inst_2 : K} {σ : Turing.TM2to1.StAct.{u4, u3, u2} K _inst_1 Λ _inst_2} {_inst_3 : Turing.TM2.Stmt.{u4, u3, u1, u2} K _inst_1 Γ Λ}, Eq.{max (max (max (succ u4) (succ u3)) (succ u1)) (succ u2)} (Finset.{max (max (max u2 u1) u3) u4} (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ)) (Turing.TM2to1.trStmts₁.{u4, u3, u1, u2} K _inst_1 Γ Λ (Turing.TM2to1.stRun.{u4, u3, u1, u2} K _inst_1 Γ Λ _inst_2 σ _inst_3)) (Union.union.{max (max (max u2 u1) u3) u4} (Finset.{max (max (max u2 u1) u3) u4} (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ)) (Finset.instUnionFinset.{max (max (max u4 u3) u1) u2} (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ) (fun (a : Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ) (b : Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ) => Classical.propDecidable (Eq.{succ (max (max (max u4 u3) u1) u2)} (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ) a b))) (Insert.insert.{max (max (max u2 u1) u3) u4, max (max (max u2 u1) u3) u4} (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ) (Finset.{max (max (max u2 u1) u3) u4} (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ)) (Finset.instInsertFinset.{max (max (max u4 u3) u1) u2} (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ) (fun (a : Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ) (b : Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ) => Classical.propDecidable (Eq.{succ (max (max (max u4 u3) u1) u2)} (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ) a b))) (Turing.TM2to1.Λ'.go.{u4, u3, u1, u2} K _inst_1 Γ Λ _inst_2 σ _inst_3) (Singleton.singleton.{max (max (max u2 u1) u3) u4, max (max (max u2 u1) u3) u4} (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ) (Finset.{max (max (max u2 u1) u3) u4} (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ)) (Finset.instSingletonFinset.{max (max (max u4 u3) u1) u2} (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K _inst_1 Γ Λ)) (Turing.TM2to1.Λ'.ret.{u4, u3, u1, u2} K _inst_1 Γ Λ _inst_3))) (Turing.TM2to1.trStmts₁.{u4, u3, u1, u2} K _inst_1 Γ Λ _inst_3))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_stmts₁_run Turing.TM2to1.trStmts₁_runₓ'. -/
theorem trStmts₁_run {k s q} : tr_stmts₁ (st_run s q) = {go k s q, ret q} ∪ tr_stmts₁ q := by
  rcases s with (_ | _ | _) <;> unfold tr_stmts₁ st_run
#align turing.TM2to1.tr_stmts₁_run Turing.TM2to1.trStmts₁_run

/- warning: turing.TM2to1.tr_respects_aux₂ -> Turing.TM2to1.tr_respects_aux₂ is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] {k : K} {q : Turing.TM1.Stmt.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ} {v : σ} {S : forall (k : K), List.{u2} (Γ k)} {L : Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))}, (forall (k : K), Eq.{succ u2} (Turing.ListBlank.{u2} (Option.{u2} (Γ k)) (Option.inhabited.{u2} (Γ k))) (Turing.ListBlank.map.{max u1 u2, u2} (forall (k : K), Option.{u2} (Γ k)) (Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x))) (Option.inhabited.{u2} (Γ k)) (Turing.proj.{u1, u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)) k) L) (Turing.ListBlank.mk.{u2} (Option.{u2} (Γ k)) (Option.inhabited.{u2} (Γ k)) (List.reverse.{u2} (Option.{u2} (Γ k)) (List.map.{u2, u2} (Γ k) (Option.{u2} (Γ k)) (Option.some.{u2} (Γ k)) (S k))))) -> (forall (o : Turing.TM2to1.StAct.{u1, u2, u4} K _inst_1 Γ σ _inst_3 k), let v' : σ := Turing.TM2to1.stVar.{u1, u2, u4} K _inst_1 Γ σ _inst_3 k v (S k) o; let Sk' : List.{u2} (Γ k) := Turing.TM2to1.stWrite.{u1, u2, u4} K _inst_1 Γ σ _inst_3 k v (S k) o; let S' : forall (a : K), List.{u2} (Γ a) := Function.update.{succ u1, succ u2} K (fun (k : K) => List.{u2} (Γ k)) (fun (a : K) (b : K) => _inst_1 a b) S k Sk'; Exists.{succ (max u1 u2)} (Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))) (fun (L' : Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))) => And (forall (k : K), Eq.{succ u2} (Turing.ListBlank.{u2} (Option.{u2} (Γ k)) (Option.inhabited.{u2} (Γ k))) (Turing.ListBlank.map.{max u1 u2, u2} (forall (k : K), Option.{u2} (Γ k)) (Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x))) (Option.inhabited.{u2} (Γ k)) (Turing.proj.{u1, u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)) k) L') (Turing.ListBlank.mk.{u2} (Option.{u2} (Γ k)) (Option.inhabited.{u2} (Γ k)) (List.reverse.{u2} (Option.{u2} (Γ k)) (List.map.{u2, u2} (Γ k) (Option.{u2} (Γ k)) (Option.some.{u2} (Γ k)) (S' k))))) (Eq.{max (succ (max u1 u2)) (succ (max u1 u2 u3 u4)) (succ u4)} (Turing.TM1.Cfg.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ) (Turing.TM1.stepAux.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Turing.TM2to1.trStAct.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 k q o) v (Nat.iterate.{succ (max u1 u2)} (Turing.Tape.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Turing.Tape.move.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) Turing.Dir.right) (List.length.{u2} (Γ k) (S k)) (Turing.Tape.mk'.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (EmptyCollection.emptyCollection.{max u1 u2} (Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Turing.ListBlank.hasEmptyc.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ))) (Turing.TM2to1.addBottom.{u1, u2} K _inst_1 Γ L)))) (Turing.TM1.stepAux.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ q v' (Nat.iterate.{succ (max u1 u2)} (Turing.Tape.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Turing.Tape.move.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) Turing.Dir.right) (List.length.{u2} (Γ k) (S' k)) (Turing.Tape.mk'.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (EmptyCollection.emptyCollection.{max u1 u2} (Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Turing.ListBlank.hasEmptyc.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ))) (Turing.TM2to1.addBottom.{u1, u2} K _inst_1 Γ L')))))))
but is expected to have type
  forall {K : Type.{u3}} [_inst_1 : DecidableEq.{succ u3} K] {Γ : K -> Type.{u4}} {Λ : Type.{u1}} {_inst_2 : Type.{u2}} {σ : K} {_inst_3 : Turing.TM1.Stmt.{max u4 u3, max (max (max u2 u1) u4) u3, u2} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Λ'.{u3, u4, u1, u2} K Γ Λ _inst_2) _inst_2} {k : _inst_2} {q : forall (k : K), List.{u4} (Γ k)} {v : Turing.ListBlank.{max u3 u4} (forall (k : K), Option.{u4} (Γ k)) (instInhabitedForAll_1.{succ u3, succ u4} K (fun (k : K) => Option.{u4} (Γ k)) (fun (a : K) => instInhabitedOption.{u4} (Γ a)))}, (forall (k : K), Eq.{succ u4} (Turing.ListBlank.{u4} (Option.{u4} (Γ k)) (instInhabitedOption.{u4} (Γ k))) (Turing.ListBlank.map.{max u4 u3, u4} (forall (i : K), Option.{u4} (Γ i)) (Option.{u4} (Γ k)) (instInhabitedForAll_1.{succ u3, succ u4} K (fun (i : K) => Option.{u4} (Γ i)) (fun (a : K) => instInhabitedOption.{u4} (Γ a))) (instInhabitedOption.{u4} (Γ k)) (Turing.proj.{u3, u4} K (fun (k : K) => Option.{u4} (Γ k)) (fun (a : K) => instInhabitedOption.{u4} (Γ a)) k) v) (Turing.ListBlank.mk.{u4} (Option.{u4} (Γ k)) (instInhabitedOption.{u4} (Γ k)) (List.reverse.{u4} (Option.{u4} (Γ k)) (List.map.{u4, u4} (Γ k) (Option.{u4} (Γ k)) (Option.some.{u4} (Γ k)) (q k))))) -> (forall (L : Turing.TM2to1.StAct.{u3, u4, u2} K Γ _inst_2 σ), let v' : _inst_2 := Turing.TM2to1.stVar.{u3, u4, u2} K Γ _inst_2 σ k (q σ) L; let Sk' : List.{u4} (Γ σ) := Turing.TM2to1.stWrite.{u3, u4, u2} K Γ _inst_2 σ k (q σ) L; let S' : forall (a : K), List.{u4} (Γ a) := Function.update.{succ u3, succ u4} K (fun (a : K) => List.{u4} (Γ a)) (fun (a : K) (b : K) => _inst_1 a b) q σ Sk'; Exists.{max (succ u3) (succ u4)} (Turing.ListBlank.{max u3 u4} (forall (k : K), Option.{u4} (Γ k)) (instInhabitedForAll_1.{succ u3, succ u4} K (fun (k : K) => Option.{u4} (Γ k)) (fun (a : K) => instInhabitedOption.{u4} (Γ a)))) (fun (L' : Turing.ListBlank.{max u3 u4} (forall (k : K), Option.{u4} (Γ k)) (instInhabitedForAll_1.{succ u3, succ u4} K (fun (k : K) => Option.{u4} (Γ k)) (fun (a : K) => instInhabitedOption.{u4} (Γ a)))) => And (forall (k : K), Eq.{succ u4} (Turing.ListBlank.{u4} (Option.{u4} (Γ k)) (instInhabitedOption.{u4} (Γ k))) (Turing.ListBlank.map.{max u4 u3, u4} (forall (i : K), Option.{u4} (Γ i)) (Option.{u4} (Γ k)) (instInhabitedForAll_1.{succ u3, succ u4} K (fun (i : K) => Option.{u4} (Γ i)) (fun (a : K) => instInhabitedOption.{u4} (Γ a))) (instInhabitedOption.{u4} (Γ k)) (Turing.proj.{u3, u4} K (fun (k : K) => Option.{u4} (Γ k)) (fun (a : K) => instInhabitedOption.{u4} (Γ a)) k) L') (Turing.ListBlank.mk.{u4} (Option.{u4} (Γ k)) (instInhabitedOption.{u4} (Γ k)) (List.reverse.{u4} (Option.{u4} (Γ k)) (List.map.{u4, u4} (Γ k) (Option.{u4} (Γ k)) (Option.some.{u4} (Γ k)) (S' k))))) (Eq.{max (max (max (succ u3) (succ u4)) (succ u1)) (succ u2)} (Turing.TM1.Cfg.{max u4 u3, max (max (max u2 u1) u4) u3, u2} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ) (Turing.TM2to1.Λ'.{u3, u4, u1, u2} K Γ Λ _inst_2) _inst_2) (Turing.TM1.stepAux.{max u4 u3, max (max (max u2 u1) u4) u3, u2} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ) (Turing.TM2to1.Λ'.{u3, u4, u1, u2} K Γ Λ _inst_2) _inst_2 (Turing.TM2to1.trStAct.{u3, u4, u1, u2} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ _inst_2 σ _inst_3 L) k (Nat.iterate.{succ (max u3 u4)} (Turing.Tape.{max u3 u4} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ)) (Turing.Tape.move.{max u3 u4} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ) Turing.Dir.right) (List.length.{u4} (Γ σ) (q σ)) (Turing.Tape.mk'.{max u3 u4} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ) (EmptyCollection.emptyCollection.{max u3 u4} (Turing.ListBlank.{max u3 u4} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ)) (Turing.ListBlank.hasEmptyc.{max u3 u4} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ))) (Turing.TM2to1.addBottom.{u3, u4} K Γ v)))) (Turing.TM1.stepAux.{max u3 u4, max (max (max u3 u4) u1) u2, u2} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ) (Turing.TM2to1.Λ'.{u3, u4, u1, u2} K Γ Λ _inst_2) _inst_2 _inst_3 v' (Nat.iterate.{succ (max u3 u4)} (Turing.Tape.{max u3 u4} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ)) (Turing.Tape.move.{max u3 u4} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ) Turing.Dir.right) (List.length.{u4} (Γ σ) (S' σ)) (Turing.Tape.mk'.{max u3 u4} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ) (EmptyCollection.emptyCollection.{max u3 u4} (Turing.ListBlank.{max u3 u4} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ)) (Turing.ListBlank.hasEmptyc.{max u3 u4} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ))) (Turing.TM2to1.addBottom.{u3, u4} K Γ L')))))))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_respects_aux₂ Turing.TM2to1.tr_respects_aux₂ₓ'. -/
theorem tr_respects_aux₂ {k q v} {S : ∀ k, List (Γ k)} {L : ListBlank (∀ k, Option (Γ k))}
    (hL : ∀ k, L.map (proj k) = ListBlank.mk ((S k).map some).reverse) (o) :
    let v' := st_var v (S k) o
    let Sk' := st_write v (S k) o
    let S' := update S k Sk'
    ∃ L' : ListBlank (∀ k, Option (Γ k)),
      (∀ k, L'.map (proj k) = ListBlank.mk ((S' k).map some).reverse) ∧
        TM1.stepAux (tr_st_act q o) v
            ((Tape.move Dir.right^[(S k).length]) (Tape.mk' ∅ (add_bottom L))) =
          TM1.stepAux q v' ((Tape.move Dir.right^[(S' k).length]) (Tape.mk' ∅ (add_bottom L'))) :=
  by
  dsimp only; simp; cases o <;> simp only [st_write, st_var, tr_st_act, TM1.step_aux]
  case
    push f =>
    have := tape.write_move_right_n fun a : Γ' => (a.1, update a.2 k (some (f v)))
    dsimp only at this
    refine'
      ⟨_, fun k' => _, by
        rw [tape.move_right_n_head, List.length, tape.mk'_nth_nat, this,
          add_bottom_modify_nth fun a => update a k (some (f v)), Nat.add_one, iterate_succ']⟩
    refine' list_blank.ext fun i => _
    rw [list_blank.nth_map, list_blank.nth_modify_nth, proj, pointed_map.mk_val]
    by_cases h' : k' = k
    · subst k'
      split_ifs <;> simp only [List.reverse_cons, Function.update_same, list_blank.nth_mk, List.map]
      ·
        rw [List.getI_eq_nthLe, List.nthLe_append_right] <;>
          simp only [h, List.nthLe_singleton, List.length_map, List.length_reverse, Nat.succ_pos',
            List.length_append, lt_add_iff_pos_right, List.length]
      rw [← proj_map_nth, hL, list_blank.nth_mk]
      cases' lt_or_gt_of_ne h with h h
      · rw [List.getI_append]
        simpa only [List.length_map, List.length_reverse] using h
      · rw [gt_iff_lt] at h
        rw [List.getI_eq_default, List.getI_eq_default] <;>
          simp only [Nat.add_one_le_iff, h, List.length, le_of_lt, List.length_reverse,
            List.length_append, List.length_map]
    · split_ifs <;> rw [Function.update_noteq h', ← proj_map_nth, hL]
      rw [Function.update_noteq h']
  case peek f =>
    rw [Function.update_eq_self]
    use L, hL; rw [tape.move_left_right]; congr
    cases e : S k; · rfl
    rw [List.length_cons, iterate_succ', tape.move_right_left, tape.move_right_n_head,
      tape.mk'_nth_nat, add_bottom_nth_snd, stk_nth_val _ (hL k), e, List.reverse_cons, ←
      List.length_reverse, List.get?_concat_length]
    rfl
  case pop f =>
    cases e : S k
    · simp only [tape.mk'_head, list_blank.head_cons, tape.move_left_mk', List.length,
        tape.write_mk', List.head?, iterate_zero_apply, List.tail_nil]
      rw [← e, Function.update_eq_self]
      exact ⟨L, hL, by rw [add_bottom_head_fst, cond]⟩
    · refine'
        ⟨_, fun k' => _, by
          rw [List.length_cons, tape.move_right_n_head, tape.mk'_nth_nat, add_bottom_nth_succ_fst,
            cond, iterate_succ', tape.move_right_left, tape.move_right_n_head, tape.mk'_nth_nat,
            tape.write_move_right_n fun a : Γ' => (a.1, update a.2 k none),
            add_bottom_modify_nth fun a => update a k none, add_bottom_nth_snd,
            stk_nth_val _ (hL k), e,
            show (List.cons hd tl).reverse.get? tl.length = some hd by
              rw [List.reverse_cons, ← List.length_reverse, List.get?_concat_length] <;> rfl,
            List.head?, List.tail]⟩
      refine' list_blank.ext fun i => _
      rw [list_blank.nth_map, list_blank.nth_modify_nth, proj, pointed_map.mk_val]
      by_cases h' : k' = k
      · subst k'
        split_ifs <;> simp only [Function.update_same, list_blank.nth_mk, List.tail]
        · rw [List.getI_eq_default]
          · rfl
          rw [h, List.length_reverse, List.length_map]
        rw [← proj_map_nth, hL, list_blank.nth_mk, e, List.map, List.reverse_cons]
        cases' lt_or_gt_of_ne h with h h
        · rw [List.getI_append]
          simpa only [List.length_map, List.length_reverse] using h
        · rw [gt_iff_lt] at h
          rw [List.getI_eq_default, List.getI_eq_default] <;>
            simp only [Nat.add_one_le_iff, h, List.length, le_of_lt, List.length_reverse,
              List.length_append, List.length_map]
      · split_ifs <;> rw [Function.update_noteq h', ← proj_map_nth, hL]
        rw [Function.update_noteq h']
#align turing.TM2to1.tr_respects_aux₂ Turing.TM2to1.tr_respects_aux₂

parameter (M : Λ → stmt₂)

include M

/- warning: turing.TM2to1.tr -> Turing.TM2to1.tr is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ], (Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ)) -> (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) -> (Turing.TM1.Stmt.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} {_inst_2 : Type.{u4}}, (Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K Γ Λ _inst_2)) -> (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K Γ Λ _inst_2) -> (Turing.TM1.Stmt.{max u2 u1, max (max (max u4 u3) u2) u1, u4} (Turing.TM2to1.Γ'.{u1, u2} K Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K Γ Λ _inst_2) _inst_2)
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr Turing.TM2to1.trₓ'. -/
/-- The TM2 emulator machine states written as a TM1 program.
This handles the `go` and `ret` states, which shuttle to and from a stack top. -/
def tr : Λ' → stmt₁
  | normal q => tr_normal (M q)
  | go k s q =>
    branch (fun a s => (a.2 k).isNone) (tr_st_act (goto fun _ _ => ret q) s)
      (move Dir.right <| goto fun _ _ => go k s q)
  | ret q => branch (fun a s => a.1) (tr_normal q) (move Dir.left <| goto fun _ _ => ret q)
#align turing.TM2to1.tr Turing.TM2to1.tr

attribute [local pp_using_anonymous_constructor] Turing.TM1.Cfg

/- warning: turing.TM2to1.tr_cfg -> Turing.TM2to1.TrCfg is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ], (Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ)) -> (Turing.TM2.Cfg.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ) -> (Turing.TM1.Cfg.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ) -> Prop
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u3}} {Λ : Type.{u4}}, (Turing.TM2.Cfg.{u1, u2, u3, u4} K _inst_1 Γ Λ) -> (Turing.TM1.Cfg.{max u2 u1, max (max (max u4 u3) u2) u1, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ) Λ) -> Prop
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_cfg Turing.TM2to1.TrCfgₓ'. -/
/-- The relation between TM2 configurations and TM1 configurations of the TM2 emulator. -/
inductive TrCfg : cfg₂ → cfg₁ → Prop
  |
  mk {q v} {S : ∀ k, List (Γ k)} (L : ListBlank (∀ k, Option (Γ k))) :
    (∀ k, L.map (proj k) = ListBlank.mk ((S k).map some).reverse) →
      tr_cfg ⟨q, v, S⟩ ⟨q.map normal, v, Tape.mk' ∅ (add_bottom L)⟩
#align turing.TM2to1.tr_cfg Turing.TM2to1.TrCfg

/- warning: turing.TM2to1.tr_respects_aux₁ -> Turing.TM2to1.tr_respects_aux₁ is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] (M : Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ)) {k : K} (o : Turing.TM2to1.StAct.{u1, u2, u4} K _inst_1 Γ σ _inst_3 k) (q : Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ) (v : σ) {S : List.{u2} (Γ k)} {L : Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))}, (Eq.{succ u2} (Turing.ListBlank.{u2} (Option.{u2} (Γ k)) (Option.inhabited.{u2} (Γ k))) (Turing.ListBlank.map.{max u1 u2, u2} (forall (k : K), Option.{u2} (Γ k)) (Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x))) (Option.inhabited.{u2} (Γ k)) (Turing.proj.{u1, u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)) k) L) (Turing.ListBlank.mk.{u2} (Option.{u2} (Γ k)) (Option.inhabited.{u2} (Γ k)) (List.reverse.{u2} (Option.{u2} (Γ k)) (List.map.{u2, u2} (Γ k) (Option.{u2} (Γ k)) (Option.some.{u2} (Γ k)) S)))) -> (forall (n : Nat), (LE.le.{0} Nat Nat.hasLe n (List.length.{u2} (Γ k) S)) -> (Turing.Reaches₀.{max (max u1 u2) (max u1 u2 u3 u4) u4} (Turing.TM1.Cfg.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ) (Turing.TM1.step.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Turing.TM2to1.tr.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 M)) (Turing.TM1.Cfg.mk.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Option.some.{max u1 u2 u3 u4} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) (Turing.TM2to1.Λ'.go.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 k o q)) v (Turing.Tape.mk'.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (EmptyCollection.emptyCollection.{max u1 u2} (Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Turing.ListBlank.hasEmptyc.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ))) (Turing.TM2to1.addBottom.{u1, u2} K _inst_1 Γ L))) (Turing.TM1.Cfg.mk.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Option.some.{max u1 u2 u3 u4} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) (Turing.TM2to1.Λ'.go.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 k o q)) v (Nat.iterate.{succ (max u1 u2)} (Turing.Tape.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Turing.Tape.move.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) Turing.Dir.right) n (Turing.Tape.mk'.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (EmptyCollection.emptyCollection.{max u1 u2} (Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Turing.ListBlank.hasEmptyc.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ))) (Turing.TM2to1.addBottom.{u1, u2} K _inst_1 Γ L))))))
but is expected to have type
  forall {K : Type.{u4}} [_inst_1 : DecidableEq.{succ u4} K] {Γ : K -> Type.{u3}} {Λ : Type.{u1}} {_inst_2 : Type.{u2}} (σ : Λ -> (Turing.TM2.Stmt.{u4, u3, u1, u2} K Γ Λ _inst_2)) {_inst_3 : K} (M : Turing.TM2to1.StAct.{u4, u3, u2} K Γ _inst_2 _inst_3) (k : Turing.TM2.Stmt.{u4, u3, u1, u2} K Γ Λ _inst_2) (o : _inst_2) {q : List.{u3} (Γ _inst_3)} {v : Turing.ListBlank.{max u4 u3} (forall (k : K), Option.{u3} (Γ k)) (instInhabitedForAll_1.{succ u4, succ u3} K (fun (k : K) => Option.{u3} (Γ k)) (fun (a : K) => instInhabitedOption.{u3} (Γ a)))}, (Eq.{succ u3} (Turing.ListBlank.{u3} (Option.{u3} (Γ _inst_3)) (instInhabitedOption.{u3} (Γ _inst_3))) (Turing.ListBlank.map.{max u4 u3, u3} (forall (i : K), Option.{u3} (Γ i)) (Option.{u3} (Γ _inst_3)) (instInhabitedForAll_1.{succ u4, succ u3} K (fun (i : K) => Option.{u3} (Γ i)) (fun (a : K) => instInhabitedOption.{u3} (Γ a))) (instInhabitedOption.{u3} (Γ _inst_3)) (Turing.proj.{u4, u3} K (fun (k : K) => Option.{u3} (Γ k)) (fun (a : K) => instInhabitedOption.{u3} (Γ a)) _inst_3) v) (Turing.ListBlank.mk.{u3} (Option.{u3} (Γ _inst_3)) (instInhabitedOption.{u3} (Γ _inst_3)) (List.reverse.{u3} (Option.{u3} (Γ _inst_3)) (List.map.{u3, u3} (Γ _inst_3) (Option.{u3} (Γ _inst_3)) (Option.some.{u3} (Γ _inst_3)) q)))) -> (forall (L : Nat), (LE.le.{0} Nat instLENat L (List.length.{u3} (Γ _inst_3) q)) -> (Turing.Reaches₀.{max (max u2 (max (max u2 u1) u3) u4) u3 u4} (Turing.TM1.Cfg.{max u3 u4, max (max (max u2 u1) u3) u4, u2} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K Γ Λ _inst_2) _inst_2) (Turing.TM1.step.{max u3 u4, max (max (max u2 u1) u3) u4, u2} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K Γ Λ _inst_2) _inst_2 (Turing.TM2to1.tr.{u4, u3, u1, u2} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ _inst_2 σ)) (Turing.TM1.Cfg.mk.{max u4 u3, max (max (max u4 u3) u1) u2, u2} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K Γ Λ _inst_2) _inst_2 (Option.some.{max (max (max u4 u3) u1) u2} (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K Γ Λ _inst_2) (Turing.TM2to1.Λ'.go.{u4, u3, u1, u2} K Γ Λ _inst_2 _inst_3 M k)) o (Turing.Tape.mk'.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (EmptyCollection.emptyCollection.{max u4 u3} (Turing.ListBlank.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ)) (Turing.ListBlank.hasEmptyc.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ))) (Turing.TM2to1.addBottom.{u4, u3} K Γ v))) (Turing.TM1.Cfg.mk.{max u4 u3, max (max (max u4 u3) u1) u2, u2} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K Γ Λ _inst_2) _inst_2 (Option.some.{max (max (max u4 u3) u1) u2} (Turing.TM2to1.Λ'.{u4, u3, u1, u2} K Γ Λ _inst_2) (Turing.TM2to1.Λ'.go.{u4, u3, u1, u2} K Γ Λ _inst_2 _inst_3 M k)) o (Nat.iterate.{succ (max u4 u3)} (Turing.Tape.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ)) (Turing.Tape.move.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) Turing.Dir.right) L (Turing.Tape.mk'.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (EmptyCollection.emptyCollection.{max u4 u3} (Turing.ListBlank.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ)) (Turing.ListBlank.hasEmptyc.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ))) (Turing.TM2to1.addBottom.{u4, u3} K Γ v))))))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_respects_aux₁ Turing.TM2to1.tr_respects_aux₁ₓ'. -/
/- ./././Mathport/Syntax/Translate/Basic.lean:635:2: warning: expanding binder collection (n «expr ≤ » S.length) -/
theorem tr_respects_aux₁ {k} (o q v) {S : List (Γ k)} {L : ListBlank (∀ k, Option (Γ k))}
    (hL : L.map (proj k) = ListBlank.mk (S.map some).reverse) (n) (_ : n ≤ S.length) :
    Reaches₀ (TM1.step tr) ⟨some (go k o q), v, Tape.mk' ∅ (add_bottom L)⟩
      ⟨some (go k o q), v, (Tape.move Dir.right^[n]) (Tape.mk' ∅ (add_bottom L))⟩ :=
  by
  induction' n with n IH; · rfl
  apply (IH (le_of_lt H)).tail
  rw [iterate_succ_apply'];
  simp only [TM1.step, TM1.step_aux, tr, tape.mk'_nth_nat, tape.move_right_n_head,
    add_bottom_nth_snd, Option.mem_def]
  rw [stk_nth_val _ hL, List.nthLe_get?]; rfl; rwa [List.length_reverse]
#align turing.TM2to1.tr_respects_aux₁ Turing.TM2to1.tr_respects_aux₁

/- warning: turing.TM2to1.tr_respects_aux₃ -> Turing.TM2to1.tr_respects_aux₃ is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] (M : Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ)) {q : Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ} {v : σ} {L : Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))} (n : Nat), Turing.Reaches₀.{max (max u1 u2) (max u1 u2 u3 u4) u4} (Turing.TM1.Cfg.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ) (Turing.TM1.step.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Turing.TM2to1.tr.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 M)) (Turing.TM1.Cfg.mk.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Option.some.{max u1 u2 u3 u4} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) (Turing.TM2to1.Λ'.ret.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 q)) v (Nat.iterate.{succ (max u1 u2)} (Turing.Tape.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Turing.Tape.move.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) Turing.Dir.right) n (Turing.Tape.mk'.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (EmptyCollection.emptyCollection.{max u1 u2} (Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Turing.ListBlank.hasEmptyc.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ))) (Turing.TM2to1.addBottom.{u1, u2} K _inst_1 Γ L)))) (Turing.TM1.Cfg.mk.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Option.some.{max u1 u2 u3 u4} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) (Turing.TM2to1.Λ'.ret.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 q)) v (Turing.Tape.mk'.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (EmptyCollection.emptyCollection.{max u1 u2} (Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Turing.ListBlank.hasEmptyc.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ))) (Turing.TM2to1.addBottom.{u1, u2} K _inst_1 Γ L)))
but is expected to have type
  forall {K : Type.{u4}} [_inst_1 : DecidableEq.{succ u4} K] {Γ : K -> Type.{u3}} {Λ : Type.{u2}} {_inst_2 : Type.{u1}} (σ : Λ -> (Turing.TM2.Stmt.{u4, u3, u2, u1} K Γ Λ _inst_2)) {_inst_3 : Turing.TM2.Stmt.{u4, u3, u2, u1} K Γ Λ _inst_2} {M : _inst_2} {q : Turing.ListBlank.{max u4 u3} (forall (k : K), Option.{u3} (Γ k)) (instInhabitedForAll_1.{succ u4, succ u3} K (fun (k : K) => Option.{u3} (Γ k)) (fun (a : K) => instInhabitedOption.{u3} (Γ a)))} (v : Nat), Turing.Reaches₀.{max (max u1 (max (max u1 u2) u3) u4) u3 u4} (Turing.TM1.Cfg.{max u3 u4, max (max (max u1 u2) u3) u4, u1} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K Γ Λ _inst_2) _inst_2) (Turing.TM1.step.{max u3 u4, max (max (max u1 u2) u3) u4, u1} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K Γ Λ _inst_2) _inst_2 (Turing.TM2to1.tr.{u4, u3, u2, u1} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ _inst_2 σ)) (Turing.TM1.Cfg.mk.{max u4 u3, max (max (max u4 u3) u2) u1, u1} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K Γ Λ _inst_2) _inst_2 (Option.some.{max (max (max u4 u3) u2) u1} (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K Γ Λ _inst_2) (Turing.TM2to1.Λ'.ret.{u4, u3, u2, u1} K Γ Λ _inst_2 _inst_3)) M (Nat.iterate.{succ (max u4 u3)} (Turing.Tape.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ)) (Turing.Tape.move.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) Turing.Dir.right) v (Turing.Tape.mk'.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (EmptyCollection.emptyCollection.{max u4 u3} (Turing.ListBlank.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ)) (Turing.ListBlank.hasEmptyc.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ))) (Turing.TM2to1.addBottom.{u4, u3} K Γ q)))) (Turing.TM1.Cfg.mk.{max u4 u3, max (max (max u4 u3) u2) u1, u1} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K Γ Λ _inst_2) _inst_2 (Option.some.{max (max (max u4 u3) u2) u1} (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K Γ Λ _inst_2) (Turing.TM2to1.Λ'.ret.{u4, u3, u2, u1} K Γ Λ _inst_2 _inst_3)) M (Turing.Tape.mk'.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (EmptyCollection.emptyCollection.{max u4 u3} (Turing.ListBlank.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ)) (Turing.ListBlank.hasEmptyc.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ))) (Turing.TM2to1.addBottom.{u4, u3} K Γ q)))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_respects_aux₃ Turing.TM2to1.tr_respects_aux₃ₓ'. -/
theorem tr_respects_aux₃ {q v} {L : ListBlank (∀ k, Option (Γ k))} (n) :
    Reaches₀ (TM1.step tr) ⟨some (ret q), v, (Tape.move Dir.right^[n]) (Tape.mk' ∅ (add_bottom L))⟩
      ⟨some (ret q), v, Tape.mk' ∅ (add_bottom L)⟩ :=
  by
  induction' n with n IH; · rfl
  refine' reaches₀.head _ IH
  rw [Option.mem_def, TM1.step, tr, TM1.step_aux, tape.move_right_n_head, tape.mk'_nth_nat,
    add_bottom_nth_succ_fst, TM1.step_aux, iterate_succ', tape.move_right_left]
  rfl
#align turing.TM2to1.tr_respects_aux₃ Turing.TM2to1.tr_respects_aux₃

/- warning: turing.TM2to1.tr_respects_aux -> Turing.TM2to1.tr_respects_aux is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] (M : Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ)) {q : Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ} {v : σ} {T : Turing.ListBlank.{max u1 u2} (forall (i : K), Option.{u2} (Γ i)) (Pi.inhabited.{succ u1, succ u2} K (fun (i : K) => Option.{u2} (Γ i)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))} {k : K} {S : forall (k : K), List.{u2} (Γ k)}, (forall (k : K), Eq.{succ u2} (Turing.ListBlank.{u2} (Option.{u2} (Γ k)) (Option.inhabited.{u2} (Γ k))) (Turing.ListBlank.map.{max u1 u2, u2} (forall (i : K), Option.{u2} (Γ i)) (Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (i : K) => Option.{u2} (Γ i)) (fun (x : K) => Option.inhabited.{u2} (Γ x))) (Option.inhabited.{u2} (Γ k)) (Turing.proj.{u1, u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (k : K) => Option.inhabited.{u2} (Γ k)) k) T) (Turing.ListBlank.mk.{u2} (Option.{u2} (Γ k)) (Option.inhabited.{u2} (Γ k)) (List.reverse.{u2} (Option.{u2} (Γ k)) (List.map.{u2, u2} (Γ k) (Option.{u2} (Γ k)) (Option.some.{u2} (Γ k)) (S k))))) -> (forall (o : Turing.TM2to1.StAct.{u1, u2, u4} K _inst_1 Γ σ _inst_3 k), (forall {v : σ} {S : forall (k : K), List.{u2} (Γ k)} {T : Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (i : K) => Option.inhabited.{u2} (Γ i)))}, (forall (k : K), Eq.{succ u2} (Turing.ListBlank.{u2} (Option.{u2} (Γ k)) (Option.inhabited.{u2} (Γ k))) (Turing.ListBlank.map.{max u1 u2, u2} (forall (i : K), Option.{u2} (Γ i)) (Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (i : K) => Option.{u2} (Γ i)) (fun (x : K) => Option.inhabited.{u2} (Γ x))) (Option.inhabited.{u2} (Γ k)) (Turing.proj.{u1, u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (i : K) => Option.inhabited.{u2} (Γ i)) k) T) (Turing.ListBlank.mk.{u2} (Option.{u2} (Γ k)) (Option.inhabited.{u2} (Γ k)) (List.reverse.{u2} (Option.{u2} (Γ k)) (List.map.{u2, u2} (Γ k) (Option.{u2} (Γ k)) (Option.some.{u2} (Γ k)) (S k))))) -> (Exists.{max (succ (max u1 u2)) (succ (max u1 u2 u3 u4)) (succ u4)} (Turing.TM1.Cfg.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ) (fun (b : Turing.TM1.Cfg.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ) => And (Turing.TM2to1.TrCfg.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 M (Turing.TM2.stepAux.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ q v S) b) (Turing.Reaches.{max (max u1 u2) (max u1 u2 u3 u4) u4} (Turing.TM1.Cfg.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ) (Turing.TM1.step.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Turing.TM2to1.tr.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 M)) (Turing.TM1.stepAux.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Turing.TM2to1.trNormal.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 q) v (Turing.Tape.mk'.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (EmptyCollection.emptyCollection.{max u1 u2} (Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Turing.ListBlank.hasEmptyc.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ))) (Turing.TM2to1.addBottom.{u1, u2} K _inst_1 Γ T))) b)))) -> (Exists.{max (succ (max u1 u2)) (succ (max u1 u2 u3 u4)) (succ u4)} (Turing.TM1.Cfg.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ) (fun (b : Turing.TM1.Cfg.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ) => And (Turing.TM2to1.TrCfg.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 M (Turing.TM2.stepAux.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ (Turing.TM2to1.stRun.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 k o q) v S) b) (Turing.Reaches.{max (max u1 u2) (max u1 u2 u3 u4) u4} (Turing.TM1.Cfg.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ) (Turing.TM1.step.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Turing.TM2to1.tr.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 M)) (Turing.TM1.stepAux.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Turing.TM2to1.trNormal.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 (Turing.TM2to1.stRun.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 k o q)) v (Turing.Tape.mk'.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (EmptyCollection.emptyCollection.{max u1 u2} (Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Turing.ListBlank.hasEmptyc.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ))) (Turing.TM2to1.addBottom.{u1, u2} K _inst_1 Γ T))) b))))
but is expected to have type
  forall {K : Type.{u4}} [_inst_1 : DecidableEq.{succ u4} K] {Γ : K -> Type.{u3}} {Λ : Type.{u2}} {_inst_2 : Type.{u1}} (σ : Λ -> (Turing.TM2.Stmt.{u4, u3, u2, u1} K Γ Λ _inst_2)) {_inst_3 : Turing.TM2.Stmt.{u4, u3, u2, u1} K (fun (k : K) => Γ k) Λ _inst_2} {M : _inst_2} {q : Turing.ListBlank.{max u3 u4} (forall (i : K), Option.{u3} (Γ i)) (instInhabitedForAll_1.{succ u4, succ u3} K (fun (i : K) => Option.{u3} (Γ i)) (fun (a : K) => instInhabitedOption.{u3} (Γ a)))} {v : K} {T : forall (k : K), List.{u3} (Γ k)}, (forall (k : K), Eq.{succ u3} (Turing.ListBlank.{u3} (Option.{u3} (Γ k)) (instInhabitedOption.{u3} (Γ k))) (Turing.ListBlank.map.{max u3 u4, u3} (forall (i : K), Option.{u3} (Γ i)) (Option.{u3} (Γ k)) (instInhabitedForAll_1.{succ u4, succ u3} K (fun (i : K) => Option.{u3} (Γ i)) (fun (a : K) => instInhabitedOption.{u3} (Γ a))) (instInhabitedOption.{u3} (Γ k)) (Turing.proj.{u4, u3} K (fun (k : K) => Option.{u3} (Γ k)) (fun (i : K) => instInhabitedOption.{u3} (Γ i)) k) q) (Turing.ListBlank.mk.{u3} (Option.{u3} (Γ k)) (instInhabitedOption.{u3} (Γ k)) (List.reverse.{u3} (Option.{u3} (Γ k)) (List.map.{u3, u3} (Γ k) (Option.{u3} (Γ k)) (Option.some.{u3} (Γ k)) (T k))))) -> (forall (S : Turing.TM2to1.StAct.{u4, u3, u1} K Γ _inst_2 v), (forall {k : _inst_2} {S : forall (k : K), List.{u3} (Γ k)} {T : Turing.ListBlank.{max u4 u3} (forall (k : K), Option.{u3} (Γ k)) (instInhabitedForAll_1.{succ u4, succ u3} K (fun (k : K) => Option.{u3} (Γ k)) (fun (a : K) => instInhabitedOption.{u3} (Γ a)))}, (forall (k : K), Eq.{succ u3} (Turing.ListBlank.{u3} (Option.{u3} (Γ k)) (instInhabitedOption.{u3} (Γ k))) (Turing.ListBlank.map.{max u3 u4, u3} (forall (i : K), Option.{u3} (Γ i)) (Option.{u3} (Γ k)) (instInhabitedForAll_1.{succ u4, succ u3} K (fun (i : K) => Option.{u3} (Γ i)) (fun (a : K) => instInhabitedOption.{u3} (Γ a))) (instInhabitedOption.{u3} (Γ k)) (Turing.proj.{u4, u3} K (fun (i : K) => Option.{u3} (Γ i)) (fun (a : K) => instInhabitedOption.{u3} (Γ a)) k) T) (Turing.ListBlank.mk.{u3} (Option.{u3} (Γ k)) (instInhabitedOption.{u3} (Γ k)) (List.reverse.{u3} (Option.{u3} (Γ k)) (List.map.{u3, u3} (Γ k) (Option.{u3} (Γ k)) (Option.some.{u3} (Γ k)) (S k))))) -> (Exists.{max (max (max (succ u4) (succ u3)) (succ u1)) (succ u2)} (Turing.TM1.Cfg.{max u3 u4, max (max (max u1 u2) u3) u4, u1} (Turing.TM2to1.Γ'.{u4, u3} K (fun (k : K) => Γ k)) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K (fun (k : K) => Γ k)) (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K (fun (k : K) => Γ k) Λ _inst_2) _inst_2) (fun (b : Turing.TM1.Cfg.{max u3 u4, max (max (max u1 u2) u3) u4, u1} (Turing.TM2to1.Γ'.{u4, u3} K (fun (k : K) => Γ k)) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K (fun (k : K) => Γ k)) (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K (fun (k : K) => Γ k) Λ _inst_2) _inst_2) => And (Turing.TM2to1.TrCfg.{u4, u3, u2, u1} K (fun (k : K) => Γ k) Λ _inst_2 (Turing.TM2.stepAux.{u4, u3, u2, u1} K (fun (a : K) (b : K) => _inst_1 a b) (fun (k : K) => Γ k) Λ _inst_2 _inst_3 k S) b) (Turing.Reaches.{max (max u1 (max (max u1 u2) u3) u4) u3 u4} (Turing.TM1.Cfg.{max u3 u4, max (max (max u1 u2) u3) u4, u1} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K Γ Λ _inst_2) _inst_2) (Turing.TM1.step.{max u3 u4, max (max (max u1 u2) u3) u4, u1} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K Γ Λ _inst_2) _inst_2 (Turing.TM2to1.tr.{u4, u3, u2, u1} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ _inst_2 σ)) (Turing.TM1.stepAux.{max u4 u3, max (max (max u4 u3) u2) u1, u1} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K Γ Λ _inst_2) _inst_2 (Turing.TM2to1.trNormal.{u4, u3, u2, u1} K Γ Λ _inst_2 _inst_3) k (Turing.Tape.mk'.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (EmptyCollection.emptyCollection.{max u4 u3} (Turing.ListBlank.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ)) (Turing.ListBlank.hasEmptyc.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ))) (Turing.TM2to1.addBottom.{u4, u3} K Γ T))) b)))) -> (Exists.{max (max (max (succ u4) (succ u3)) (succ u2)) (succ u1)} (Turing.TM1.Cfg.{max u3 u4, max (max (max u1 u2) u3) u4, u1} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K Γ Λ _inst_2) _inst_2) (fun (b : Turing.TM1.Cfg.{max u3 u4, max (max (max u1 u2) u3) u4, u1} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K Γ Λ _inst_2) _inst_2) => And (Turing.TM2to1.TrCfg.{u4, u3, u2, u1} K Γ Λ _inst_2 (Turing.TM2.stepAux.{u4, u3, u2, u1} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ _inst_2 (Turing.TM2to1.stRun.{u4, u3, u2, u1} K Γ Λ _inst_2 v S _inst_3) M T) b) (Turing.Reaches.{max (max u1 (max (max u1 u2) u3) u4) u3 u4} (Turing.TM1.Cfg.{max u3 u4, max (max (max u1 u2) u3) u4, u1} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K Γ Λ _inst_2) _inst_2) (Turing.TM1.step.{max u3 u4, max (max (max u1 u2) u3) u4, u1} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K Γ Λ _inst_2) _inst_2 (Turing.TM2to1.tr.{u4, u3, u2, u1} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ _inst_2 σ)) (Turing.TM1.stepAux.{max u4 u3, max (max (max u4 u3) u2) u1, u1} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (Turing.TM2to1.Λ'.{u4, u3, u2, u1} K Γ Λ _inst_2) _inst_2 (Turing.TM2to1.trNormal.{u4, u3, u2, u1} K Γ Λ _inst_2 (Turing.TM2to1.stRun.{u4, u3, u2, u1} K Γ Λ _inst_2 v S _inst_3)) M (Turing.Tape.mk'.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ) (EmptyCollection.emptyCollection.{max u4 u3} (Turing.ListBlank.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ)) (Turing.ListBlank.hasEmptyc.{max u4 u3} (Turing.TM2to1.Γ'.{u4, u3} K Γ) (Turing.TM2to1.Γ'.inhabited.{u4, u3} K Γ))) (Turing.TM2to1.addBottom.{u4, u3} K Γ q))) b))))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_respects_aux Turing.TM2to1.tr_respects_auxₓ'. -/
theorem tr_respects_aux {q v T k} {S : ∀ k, List (Γ k)}
    (hT : ∀ k, ListBlank.map (proj k) T = ListBlank.mk ((S k).map some).reverse) (o : st_act k)
    (IH :
      ∀ {v : σ} {S : ∀ k : K, List (Γ k)} {T : ListBlank (∀ k, Option (Γ k))},
        (∀ k, ListBlank.map (proj k) T = ListBlank.mk ((S k).map some).reverse) →
          ∃ b,
            tr_cfg (TM2.stepAux q v S) b ∧
              Reaches (TM1.step tr) (TM1.stepAux (tr_normal q) v (Tape.mk' ∅ (add_bottom T))) b) :
    ∃ b,
      tr_cfg (TM2.stepAux (st_run o q) v S) b ∧
        Reaches (TM1.step tr) (TM1.stepAux (tr_normal (st_run o q)) v (Tape.mk' ∅ (add_bottom T)))
          b :=
  by
  simp only [tr_normal_run, step_run]
  have hgo := tr_respects_aux₁ M o q v (hT k) _ le_rfl
  obtain ⟨T', hT', hrun⟩ := tr_respects_aux₂ hT o
  have hret := tr_respects_aux₃ M _
  have := hgo.tail' rfl
  rw [tr, TM1.step_aux, tape.move_right_n_head, tape.mk'_nth_nat, add_bottom_nth_snd,
    stk_nth_val _ (hT k), List.get?_len_le (le_of_eq (List.length_reverse _)), Option.isNone, cond,
    hrun, TM1.step_aux] at this
  obtain ⟨c, gc, rc⟩ := IH hT'
  refine' ⟨c, gc, (this.to₀.trans hret c (trans_gen.head' rfl _)).to_reflTransGen⟩
  rw [tr, TM1.step_aux, tape.mk'_head, add_bottom_head_fst]
  exact rc
#align turing.TM2to1.tr_respects_aux Turing.TM2to1.tr_respects_aux

attribute [local simp] respects TM2.step TM2.step_aux tr_normal

/- warning: turing.TM2to1.tr_respects -> Turing.TM2to1.tr_respects is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] (M : Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ)), Turing.Respects.{max u1 u2 u3 u4, max (max u1 u2) (max u1 u2 u3 u4) u4} (Turing.TM2.Cfg.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ) (Turing.TM1.Cfg.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ) (Turing.TM2.step.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ M) (Turing.TM1.step.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Turing.TM2to1.tr.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 M)) (Turing.TM2to1.TrCfg.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 M)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} {_inst_2 : Type.{u4}} (σ : Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K Γ Λ _inst_2)), Turing.Respects.{max (max (max u4 u3) u2) u1, max (max u4 (max (max u4 u3) u2) u1) u2 u1} (Turing.TM2.Cfg.{u1, u2, u3, u4} K Γ Λ _inst_2) (Turing.TM1.Cfg.{max u2 u1, max (max (max u4 u3) u2) u1, u4} (Turing.TM2to1.Γ'.{u1, u2} K Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K Γ Λ _inst_2) _inst_2) (Turing.TM2.step.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ _inst_2 σ) (Turing.TM1.step.{max u2 u1, max (max (max u4 u3) u2) u1, u4} (Turing.TM2to1.Γ'.{u1, u2} K Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K Γ Λ _inst_2) _inst_2 (Turing.TM2to1.tr.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ _inst_2 σ)) (Turing.TM2to1.TrCfg.{u1, u2, u3, u4} K Γ Λ _inst_2)
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_respects Turing.TM2to1.tr_respectsₓ'. -/
theorem tr_respects : Respects (TM2.step M) (TM1.step tr) tr_cfg := fun c₁ c₂ h =>
  by
  cases' h with l v S L hT; clear h
  cases l; · constructor
  simp only [TM2.step, respects, Option.map_some']
  rsuffices ⟨b, c, r⟩ : ∃ b, _ ∧ reaches (TM1.step (tr M)) _ _
  · exact ⟨b, c, trans_gen.head' rfl r⟩
  rw [tr]
  revert v S L hT; refine' stmt_st_rec _ _ _ _ _ (M l) <;> intros
  · exact tr_respects_aux M hT s @IH
  · exact IH _ hT
  · unfold TM2.step_aux tr_normal TM1.step_aux
    cases p v <;> [exact IH₂ _ hT, exact IH₁ _ hT]
  · exact ⟨_, ⟨_, hT⟩, refl_trans_gen.refl⟩
  · exact ⟨_, ⟨_, hT⟩, refl_trans_gen.refl⟩
#align turing.TM2to1.tr_respects Turing.TM2to1.tr_respects

/- warning: turing.TM2to1.tr_cfg_init -> Turing.TM2to1.trCfg_init is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] (M : Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ)) (k : K) (L : List.{u2} (Γ k)), Turing.TM2to1.TrCfg.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 M (Turing.TM2.init.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ _inst_2 _inst_3 k L) (Turing.TM1.init.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Turing.TM2to1.Λ'.inhabited.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) _inst_3 (Turing.TM2to1.trInit.{u1, u2} K _inst_1 Γ k L))
but is expected to have type
  forall {K : Type.{u3}} [_inst_1 : DecidableEq.{succ u3} K] {Γ : K -> Type.{u4}} {Λ : Type.{u2}} [_inst_2 : Inhabited.{succ u2} Λ] {σ : Type.{u1}} [_inst_3 : Inhabited.{succ u1} σ] (M : K) (k : List.{u4} (Γ M)), Turing.TM2to1.TrCfg.{u3, u4, u2, u1} K Γ Λ σ (Turing.TM2.init.{u3, u4, u2, u1} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ _inst_2 _inst_3 M k) (Turing.TM1.init.{max u3 u4, max (max (max u3 u4) u2) u1, u1} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ) (Turing.TM2to1.Λ'.{u3, u4, u2, u1} K Γ Λ σ) σ (Turing.TM2to1.Λ'.inhabited.{u3, u4, u2, u1} K Γ Λ _inst_2 σ) _inst_3 (Turing.TM2to1.trInit.{u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ M k))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_cfg_init Turing.TM2to1.trCfg_initₓ'. -/
theorem trCfg_init (k) (L : List (Γ k)) : tr_cfg (TM2.init k L) (TM1.init (tr_init k L)) :=
  by
  rw [(_ : TM1.init _ = _)]
  · refine' ⟨list_blank.mk (L.reverse.map fun a => update default k (some a)), fun k' => _⟩
    refine' list_blank.ext fun i => _
    rw [list_blank.map_mk, list_blank.nth_mk, List.getI_eq_iget_get?, List.map_map, (· ∘ ·),
      List.get?_map, proj, pointed_map.mk_val]
    by_cases k' = k
    · subst k'
      simp only [Function.update_same]
      rw [list_blank.nth_mk, List.getI_eq_iget_get?, ← List.map_reverse, List.get?_map]
    · simp only [Function.update_noteq h]
      rw [list_blank.nth_mk, List.getI_eq_iget_get?, List.map, List.reverse_nil, List.get?]
      cases L.reverse.nth i <;> rfl
  · rw [tr_init, TM1.init]
    dsimp only
    congr <;> cases L.reverse <;> try rfl
    simp only [List.map_map, List.tail_cons, List.map]
    rfl
#align turing.TM2to1.tr_cfg_init Turing.TM2to1.trCfg_init

/- warning: turing.TM2to1.tr_eval_dom -> Turing.TM2to1.tr_eval_dom is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] (M : Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ)) (k : K) (L : List.{u2} (Γ k)), Iff (Part.Dom.{max u1 u2} (Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Turing.TM1.eval.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Turing.TM2to1.Λ'.inhabited.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) _inst_3 (Turing.TM2to1.tr.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 M) (Turing.TM2to1.trInit.{u1, u2} K _inst_1 Γ k L))) (Part.Dom.{u2} (List.{u2} (Γ k)) (Turing.TM2.eval.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ _inst_2 _inst_3 M k L))
but is expected to have type
  forall {K : Type.{u3}} [_inst_1 : DecidableEq.{succ u3} K] {Γ : K -> Type.{u4}} {Λ : Type.{u1}} [_inst_2 : Inhabited.{succ u1} Λ] {σ : Type.{u2}} [_inst_3 : Inhabited.{succ u2} σ] (M : Λ -> (Turing.TM2.Stmt.{u3, u4, u1, u2} K Γ Λ σ)) (k : K) (L : List.{u4} (Γ k)), Iff (Part.Dom.{max u3 u4} (Turing.ListBlank.{max u4 u3} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ)) (Turing.TM1.eval.{max u4 u3, max (max (max u2 u1) u4) u3, u2} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ) (Turing.TM2to1.Λ'.{u3, u4, u1, u2} K Γ Λ σ) σ (Turing.TM2to1.Λ'.inhabited.{u3, u4, u1, u2} K Γ Λ _inst_2 σ) _inst_3 (Turing.TM2to1.tr.{u3, u4, u1, u2} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ M) (Turing.TM2to1.trInit.{u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ k L))) (Part.Dom.{u4} (List.{u4} (Γ k)) (Turing.TM2.eval.{u3, u4, u1, u2} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ _inst_2 _inst_3 M k L))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_eval_dom Turing.TM2to1.tr_eval_domₓ'. -/
theorem tr_eval_dom (k) (L : List (Γ k)) : (TM1.eval tr (tr_init k L)).Dom ↔ (TM2.eval M k L).Dom :=
  tr_eval_dom tr_respects (tr_cfg_init _ _)
#align turing.TM2to1.tr_eval_dom Turing.TM2to1.tr_eval_dom

/- warning: turing.TM2to1.tr_eval -> Turing.TM2to1.tr_eval is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] (M : Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ)) (k : K) (L : List.{u2} (Γ k)) {L₁ : Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)} {L₂ : List.{u2} (Γ k)}, (Membership.Mem.{max u1 u2, max u1 u2} (Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Part.{max u1 u2} (Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ))) (Part.hasMem.{max u1 u2} (Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ))) L₁ (Turing.TM1.eval.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Turing.TM2to1.Λ'.inhabited.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) _inst_3 (Turing.TM2to1.tr.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 M) (Turing.TM2to1.trInit.{u1, u2} K _inst_1 Γ k L))) -> (Membership.Mem.{u2, u2} (List.{u2} (Γ k)) (Part.{u2} (List.{u2} (Γ k))) (Part.hasMem.{u2} (List.{u2} (Γ k))) L₂ (Turing.TM2.eval.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ _inst_2 _inst_3 M k L)) -> (Exists.{max (succ u1) (succ u2)} (forall (k : K), List.{u2} (Γ k)) (fun (S : forall (k : K), List.{u2} (Γ k)) => Exists.{succ (max u1 u2)} (Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))) (fun (L' : Turing.ListBlank.{max u1 u2} (forall (k : K), Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)))) => And (Eq.{succ (max u1 u2)} (Turing.ListBlank.{max u1 u2} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ)) (Turing.TM2to1.addBottom.{u1, u2} K _inst_1 Γ L') L₁) (And (forall (k : K), Eq.{succ u2} (Turing.ListBlank.{u2} (Option.{u2} (Γ k)) (Option.inhabited.{u2} (Γ k))) (Turing.ListBlank.map.{max u1 u2, u2} (forall (k : K), Option.{u2} (Γ k)) (Option.{u2} (Γ k)) (Pi.inhabited.{succ u1, succ u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x))) (Option.inhabited.{u2} (Γ k)) (Turing.proj.{u1, u2} K (fun (k : K) => Option.{u2} (Γ k)) (fun (x : K) => Option.inhabited.{u2} (Γ x)) k) L') (Turing.ListBlank.mk.{u2} (Option.{u2} (Γ k)) (Option.inhabited.{u2} (Γ k)) (List.reverse.{u2} (Option.{u2} (Γ k)) (List.map.{u2, u2} (Γ k) (Option.{u2} (Γ k)) (Option.some.{u2} (Γ k)) (S k))))) (Eq.{succ u2} (List.{u2} (Γ k)) (S k) L₂)))))
but is expected to have type
  forall {K : Type.{u3}} [_inst_1 : DecidableEq.{succ u3} K] {Γ : K -> Type.{u4}} {Λ : Type.{u1}} [_inst_2 : Inhabited.{succ u1} Λ] {σ : Type.{u2}} [_inst_3 : Inhabited.{succ u2} σ] (M : Λ -> (Turing.TM2.Stmt.{u3, u4, u1, u2} K Γ Λ σ)) (k : K) (L : List.{u4} (Γ k)) {L₁ : Turing.ListBlank.{max u4 u3} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ)} {L₂ : List.{u4} (Γ k)}, (Membership.mem.{max u3 u4, max u4 u3} (Turing.ListBlank.{max u4 u3} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ)) (Part.{max u4 u3} (Turing.ListBlank.{max u4 u3} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ))) (Part.instMembershipPart.{max u3 u4} (Turing.ListBlank.{max u4 u3} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ))) L₁ (Turing.TM1.eval.{max u4 u3, max (max (max u2 u1) u4) u3, u2} (Turing.TM2to1.Γ'.{u3, u4} K Γ) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K Γ) (Turing.TM2to1.Λ'.{u3, u4, u1, u2} K Γ Λ σ) σ (Turing.TM2to1.Λ'.inhabited.{u3, u4, u1, u2} K Γ Λ _inst_2 σ) _inst_3 (Turing.TM2to1.tr.{u3, u4, u1, u2} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ M) (Turing.TM2to1.trInit.{u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ k L))) -> (Membership.mem.{u4, u4} (List.{u4} (Γ k)) (Part.{u4} (List.{u4} (Γ k))) (Part.instMembershipPart.{u4} (List.{u4} (Γ k))) L₂ (Turing.TM2.eval.{u3, u4, u1, u2} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ _inst_2 _inst_3 M k L)) -> (Exists.{max (succ u3) (succ u4)} (forall (k : K), List.{u4} (Γ k)) (fun (S : forall (k : K), List.{u4} (Γ k)) => Exists.{max (succ u3) (succ u4)} (Turing.ListBlank.{max u3 u4} (forall (k : K), Option.{u4} (Γ k)) (instInhabitedForAll_1.{succ u3, succ u4} K (fun (k : K) => Option.{u4} (Γ k)) (fun (x : K) => instInhabitedOption.{u4} (Γ x)))) (fun (L' : Turing.ListBlank.{max u3 u4} (forall (k : K), Option.{u4} (Γ k)) (instInhabitedForAll_1.{succ u3, succ u4} K (fun (k : K) => Option.{u4} (Γ k)) (fun (x : K) => instInhabitedOption.{u4} (Γ x)))) => And (Eq.{max (succ u3) (succ u4)} (Turing.ListBlank.{max u4 u3} (Turing.TM2to1.Γ'.{u3, u4} K (fun (k : K) => Γ k)) (Turing.TM2to1.Γ'.inhabited.{u3, u4} K (fun (k : K) => Γ k))) (Turing.TM2to1.addBottom.{u3, u4} K (fun (k : K) => Γ k) L') L₁) (And (forall (k : K), Eq.{succ u4} (Turing.ListBlank.{u4} (Option.{u4} (Γ k)) (instInhabitedOption.{u4} (Γ k))) (Turing.ListBlank.map.{max u4 u3, u4} (forall (k : K), Option.{u4} (Γ k)) (Option.{u4} (Γ k)) (instInhabitedForAll_1.{succ u3, succ u4} K (fun (k : K) => Option.{u4} (Γ k)) (fun (x : K) => instInhabitedOption.{u4} (Γ x))) (instInhabitedOption.{u4} (Γ k)) (Turing.proj.{u3, u4} K (fun (k : K) => Option.{u4} (Γ k)) (fun (x : K) => instInhabitedOption.{u4} (Γ x)) k) L') (Turing.ListBlank.mk.{u4} (Option.{u4} (Γ k)) (instInhabitedOption.{u4} (Γ k)) (List.reverse.{u4} (Option.{u4} (Γ k)) (List.map.{u4, u4} (Γ k) (Option.{u4} (Γ k)) (Option.some.{u4} (Γ k)) (S k))))) (Eq.{succ u4} (List.{u4} (Γ k)) (S k) L₂)))))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_eval Turing.TM2to1.tr_evalₓ'. -/
theorem tr_eval (k) (L : List (Γ k)) {L₁ L₂} (H₁ : L₁ ∈ TM1.eval tr (tr_init k L))
    (H₂ : L₂ ∈ TM2.eval M k L) :
    ∃ (S : ∀ k, List (Γ k))(L' : ListBlank (∀ k, Option (Γ k))),
      add_bottom L' = L₁ ∧
        (∀ k, L'.map (proj k) = ListBlank.mk ((S k).map some).reverse) ∧ S k = L₂ :=
  by
  obtain ⟨c₁, h₁, rfl⟩ := (Part.mem_map_iff _).1 H₁
  obtain ⟨c₂, h₂, rfl⟩ := (Part.mem_map_iff _).1 H₂
  obtain ⟨_, ⟨L', hT⟩, h₃⟩ := tr_eval (tr_respects M) (tr_cfg_init M k L) h₂
  cases Part.mem_unique h₁ h₃
  exact ⟨_, L', by simp only [tape.mk'_right₀], hT, rfl⟩
#align turing.TM2to1.tr_eval Turing.TM2to1.tr_eval

/- warning: turing.TM2to1.tr_supp -> Turing.TM2to1.trSupp is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ], (Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ)) -> (Finset.{u3} Λ) -> (Finset.{max u1 u2 u3 u4} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3))
but is expected to have type
  forall {K : Type.{u1}} {_inst_1 : K -> Type.{u2}} {Γ : Type.{u3}} {Λ : Type.{u4}}, (Γ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K _inst_1 Γ Λ)) -> (Finset.{u3} Γ) -> (Finset.{max (max (max u4 u3) u2) u1} (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_supp Turing.TM2to1.trSuppₓ'. -/
/-- The support of a set of TM2 states in the TM2 emulator. -/
noncomputable def trSupp (S : Finset Λ) : Finset Λ' :=
  S.biUnion fun l => insert (normal l) (tr_stmts₁ (M l))
#align turing.TM2to1.tr_supp Turing.TM2to1.trSupp

/- warning: turing.TM2to1.tr_supports -> Turing.TM2to1.tr_supports is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : DecidableEq.{succ u1} K] {Γ : K -> Type.{u2}} {Λ : Type.{u3}} [_inst_2 : Inhabited.{succ u3} Λ] {σ : Type.{u4}} [_inst_3 : Inhabited.{succ u4} σ] (M : Λ -> (Turing.TM2.Stmt.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ)) {S : Finset.{u3} Λ}, (Turing.TM2.Supports.{u1, u2, u3, u4} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ _inst_2 M S) -> (Turing.TM1.Supports.{max u1 u2, max u1 u2 u3 u4, u4} (Turing.TM2to1.Γ'.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Γ'.inhabited.{u1, u2} K _inst_1 Γ) (Turing.TM2to1.Λ'.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) σ (Turing.TM2to1.Λ'.inhabited.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3) (Turing.TM2to1.tr.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 M) (Turing.TM2to1.trSupp.{u1, u2, u3, u4} K _inst_1 Γ Λ _inst_2 σ _inst_3 M S))
but is expected to have type
  forall {K : Type.{u3}} [_inst_1 : DecidableEq.{succ u3} K] {Γ : K -> Type.{u2}} {Λ : Type.{u4}} [_inst_2 : Inhabited.{succ u4} Λ] {σ : Type.{u1}} (_inst_3 : Λ -> (Turing.TM2.Stmt.{u3, u2, u4, u1} K Γ Λ σ)) {M : Finset.{u4} Λ}, (Turing.TM2.Supports.{u3, u2, u4, u1} K Γ Λ σ _inst_2 _inst_3 M) -> (Turing.TM1.Supports.{max u2 u3, max (max (max u1 u4) u2) u3, u1} (Turing.TM2to1.Γ'.{u3, u2} K Γ) (Turing.TM2to1.Λ'.{u3, u2, u4, u1} K Γ Λ σ) σ (Turing.TM2to1.Λ'.inhabited.{u3, u2, u4, u1} K Γ Λ _inst_2 σ) (Turing.TM2to1.tr.{u3, u2, u4, u1} K (fun (a : K) (b : K) => _inst_1 a b) Γ Λ σ _inst_3) (Turing.TM2to1.trSupp.{u3, u2, u4, u1} K Γ Λ σ _inst_3 M))
Case conversion may be inaccurate. Consider using '#align turing.TM2to1.tr_supports Turing.TM2to1.tr_supportsₓ'. -/
theorem tr_supports {S} (ss : TM2.Supports M S) : TM1.Supports tr (tr_supp S) :=
  ⟨Finset.mem_biUnion.2 ⟨_, ss.1, Finset.mem_insert.2 <| Or.inl rfl⟩, fun l' h =>
    by
    suffices
      ∀ (q) (ss' : TM2.supports_stmt S q) (sub : ∀ x ∈ tr_stmts₁ q, x ∈ tr_supp M S),
        TM1.supports_stmt (tr_supp M S) (tr_normal q) ∧
          ∀ l' ∈ tr_stmts₁ q, TM1.supports_stmt (tr_supp M S) (tr M l')
      by
      rcases Finset.mem_biUnion.1 h with ⟨l, lS, h⟩
      have :=
        this _ (ss.2 l lS) fun x hx => Finset.mem_biUnion.2 ⟨_, lS, Finset.mem_insert_of_mem hx⟩
      rcases Finset.mem_insert.1 h with (rfl | h) <;> [exact this.1, exact this.2 _ h]
    clear h l'
    refine' stmt_st_rec _ _ _ _ _ <;> intros
    · -- stack op
      rw [TM2to1.supports_run] at ss'
      simp only [TM2to1.tr_stmts₁_run, Finset.mem_union, Finset.mem_insert, Finset.mem_singleton] at
        sub
      have hgo := sub _ (Or.inl <| Or.inl rfl)
      have hret := sub _ (Or.inl <| Or.inr rfl)
      cases' IH ss' fun x hx => sub x <| Or.inr hx with IH₁ IH₂
      refine'
        ⟨by simp only [tr_normal_run, TM1.supports_stmt] <;> intros <;> exact hgo, fun l h => _⟩
      rw [tr_stmts₁_run] at h
      simp only [TM2to1.tr_stmts₁_run, Finset.mem_union, Finset.mem_insert, Finset.mem_singleton] at
        h
      rcases h with (⟨rfl | rfl⟩ | h)
      · unfold TM1.supports_stmt TM2to1.tr
        rcases s with (_ | _ | _)
        · exact ⟨fun _ _ => hret, fun _ _ => hgo⟩
        · exact ⟨fun _ _ => hret, fun _ _ => hgo⟩
        · exact ⟨⟨fun _ _ => hret, fun _ _ => hret⟩, fun _ _ => hgo⟩
      · unfold TM1.supports_stmt TM2to1.tr
        exact ⟨IH₁, fun _ _ => hret⟩
      · exact IH₂ _ h
    · -- load
      unfold TM2to1.tr_stmts₁ at ss' sub⊢
      exact IH ss' sub
    · -- branch
      unfold TM2to1.tr_stmts₁ at sub
      cases' IH₁ ss'.1 fun x hx => sub x <| Finset.mem_union_left _ hx with IH₁₁ IH₁₂
      cases' IH₂ ss'.2 fun x hx => sub x <| Finset.mem_union_right _ hx with IH₂₁ IH₂₂
      refine' ⟨⟨IH₁₁, IH₂₁⟩, fun l h => _⟩
      rw [tr_stmts₁] at h
      rcases Finset.mem_union.1 h with (h | h) <;> [exact IH₁₂ _ h, exact IH₂₂ _ h]
    · -- goto
      rw [tr_stmts₁]
      unfold TM2to1.tr_normal TM1.supports_stmt
      unfold TM2.supports_stmt at ss'
      exact
        ⟨fun _ v => Finset.mem_biUnion.2 ⟨_, ss' v, Finset.mem_insert_self _ _⟩, fun _ =>
          False.elim⟩
    · exact ⟨trivial, fun _ => False.elim⟩⟩
#align turing.TM2to1.tr_supports Turing.TM2to1.tr_supports

-- halt
end

end TM2to1

end Turing

