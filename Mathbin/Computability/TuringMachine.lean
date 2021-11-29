import Mathbin.Data.Fintype.Basic 
import Mathbin.Data.Pfun 
import Mathbin.Logic.Function.Iterate 
import Mathbin.Order.Basic 
import Mathbin.Tactic.ApplyFun

/-!
# Turing machines

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

open nat(iterate)

open function(update iterate_succ iterate_succ_apply iterate_succ' iterate_succ_apply' iterate_zero_apply)

namespace Turing

/-- The `blank_extends` partial order holds of `l₁` and `l₂` if `l₂` is obtained by adding
blanks (`default Γ`) to the end of `l₁`. -/
def blank_extends {Γ} [Inhabited Γ] (l₁ l₂ : List Γ) : Prop :=
  ∃ n, l₂ = l₁ ++ List.repeat (default Γ) n

@[refl]
theorem blank_extends.refl {Γ} [Inhabited Γ] (l : List Γ) : blank_extends l l :=
  ⟨0,
    by 
      simp ⟩

@[trans]
theorem blank_extends.trans {Γ} [Inhabited Γ] {l₁ l₂ l₃ : List Γ} :
  blank_extends l₁ l₂ → blank_extends l₂ l₃ → blank_extends l₁ l₃ :=
  by 
    rintro ⟨i, rfl⟩ ⟨j, rfl⟩ <;>
      exact
        ⟨i+j,
          by 
            simp [List.repeat_add]⟩

theorem blank_extends.below_of_le {Γ} [Inhabited Γ] {l l₁ l₂ : List Γ} :
  blank_extends l l₁ → blank_extends l l₂ → l₁.length ≤ l₂.length → blank_extends l₁ l₂ :=
  by 
    rintro ⟨i, rfl⟩ ⟨j, rfl⟩ h 
    use j - i 
    simp only [List.length_append, add_le_add_iff_left, List.length_repeat] at h 
    simp only [←List.repeat_add, add_tsub_cancel_of_le h, List.append_assoc]

/-- Any two extensions by blank `l₁,l₂` of `l` have a common join (which can be taken to be the
longer of `l₁` and `l₂`). -/
def blank_extends.above {Γ} [Inhabited Γ] {l l₁ l₂ : List Γ} (h₁ : blank_extends l l₁) (h₂ : blank_extends l l₂) :
  { l' // blank_extends l₁ l' ∧ blank_extends l₂ l' } :=
  if h : l₁.length ≤ l₂.length then ⟨l₂, h₁.below_of_le h₂ h, blank_extends.refl _⟩ else
    ⟨l₁, blank_extends.refl _, h₂.below_of_le h₁ (le_of_not_geₓ h)⟩

theorem blank_extends.above_of_le {Γ} [Inhabited Γ] {l l₁ l₂ : List Γ} :
  blank_extends l₁ l → blank_extends l₂ l → l₁.length ≤ l₂.length → blank_extends l₁ l₂ :=
  by 
    rintro ⟨i, rfl⟩ ⟨j, e⟩ h 
    use i - j 
    refine' List.append_right_cancel (e.symm.trans _)
    rw [List.append_assoc, ←List.repeat_add, tsub_add_cancel_of_le]
    applyFun List.length  at e 
    simp only [List.length_append, List.length_repeat] at e 
    rwa [←add_le_add_iff_left, e, add_le_add_iff_right]

/-- `blank_rel` is the symmetric closure of `blank_extends`, turning it into an equivalence
relation. Two lists are related by `blank_rel` if one extends the other by blanks. -/
def blank_rel {Γ} [Inhabited Γ] (l₁ l₂ : List Γ) : Prop :=
  blank_extends l₁ l₂ ∨ blank_extends l₂ l₁

@[refl]
theorem blank_rel.refl {Γ} [Inhabited Γ] (l : List Γ) : blank_rel l l :=
  Or.inl (blank_extends.refl _)

@[symm]
theorem blank_rel.symm {Γ} [Inhabited Γ] {l₁ l₂ : List Γ} : blank_rel l₁ l₂ → blank_rel l₂ l₁ :=
  Or.symm

@[trans]
theorem blank_rel.trans {Γ} [Inhabited Γ] {l₁ l₂ l₃ : List Γ} : blank_rel l₁ l₂ → blank_rel l₂ l₃ → blank_rel l₁ l₃ :=
  by 
    rintro (h₁ | h₁) (h₂ | h₂)
    ·
      exact Or.inl (h₁.trans h₂)
    ·
      cases' le_totalₓ l₁.length l₃.length with h h
      ·
        exact Or.inl (h₁.above_of_le h₂ h)
      ·
        exact Or.inr (h₂.above_of_le h₁ h)
    ·
      cases' le_totalₓ l₁.length l₃.length with h h
      ·
        exact Or.inl (h₁.below_of_le h₂ h)
      ·
        exact Or.inr (h₂.below_of_le h₁ h)
    ·
      exact Or.inr (h₂.trans h₁)

/-- Given two `blank_rel` lists, there exists (constructively) a common join. -/
def blank_rel.above {Γ} [Inhabited Γ] {l₁ l₂ : List Γ} (h : blank_rel l₁ l₂) :
  { l // blank_extends l₁ l ∧ blank_extends l₂ l } :=
  by 
    refine'
      if hl : l₁.length ≤ l₂.length then ⟨l₂, Or.elim h id fun h' => _, blank_extends.refl _⟩ else
        ⟨l₁, blank_extends.refl _, Or.elim h (fun h' => _) id⟩
    exact (blank_extends.refl _).above_of_le h' hl 
    exact (blank_extends.refl _).above_of_le h' (le_of_not_geₓ hl)

/-- Given two `blank_rel` lists, there exists (constructively) a common meet. -/
def blank_rel.below {Γ} [Inhabited Γ] {l₁ l₂ : List Γ} (h : blank_rel l₁ l₂) :
  { l // blank_extends l l₁ ∧ blank_extends l l₂ } :=
  by 
    refine'
      if hl : l₁.length ≤ l₂.length then ⟨l₁, blank_extends.refl _, Or.elim h id fun h' => _⟩ else
        ⟨l₂, Or.elim h (fun h' => _) id, blank_extends.refl _⟩
    exact (blank_extends.refl _).above_of_le h' hl 
    exact (blank_extends.refl _).above_of_le h' (le_of_not_geₓ hl)

theorem blank_rel.equivalence Γ [Inhabited Γ] : Equivalenceₓ (@blank_rel Γ _) :=
  ⟨blank_rel.refl, @blank_rel.symm _ _, @blank_rel.trans _ _⟩

/-- Construct a setoid instance for `blank_rel`. -/
def blank_rel.setoid Γ [Inhabited Γ] : Setoidₓ (List Γ) :=
  ⟨_, blank_rel.equivalence _⟩

/-- A `list_blank Γ` is a quotient of `list Γ` by extension by blanks at the end. This is used to
represent half-tapes of a Turing machine, so that we can pretend that the list continues
infinitely with blanks. -/
def list_blank Γ [Inhabited Γ] :=
  Quotientₓ (blank_rel.setoid Γ)

instance list_blank.inhabited {Γ} [Inhabited Γ] : Inhabited (list_blank Γ) :=
  ⟨Quotientₓ.mk' []⟩

instance list_blank.has_emptyc {Γ} [Inhabited Γ] : HasEmptyc (list_blank Γ) :=
  ⟨Quotientₓ.mk' []⟩

/-- A modified version of `quotient.lift_on'` specialized for `list_blank`, with the stronger
precondition `blank_extends` instead of `blank_rel`. -/
@[elab_as_eliminator, reducible]
protected def list_blank.lift_on {Γ} [Inhabited Γ] {α} (l : list_blank Γ) (f : List Γ → α)
  (H : ∀ a b, blank_extends a b → f a = f b) : α :=
  l.lift_on' f$
    by 
      rintro a b (h | h) <;> [exact H _ _ h, exact (H _ _ h).symm]

/-- The quotient map turning a `list` into a `list_blank`. -/
def list_blank.mk {Γ} [Inhabited Γ] : List Γ → list_blank Γ :=
  Quotientₓ.mk'

@[elab_as_eliminator]
protected theorem list_blank.induction_on {Γ} [Inhabited Γ] {p : list_blank Γ → Prop} (q : list_blank Γ)
  (h : ∀ a, p (list_blank.mk a)) : p q :=
  Quotientₓ.induction_on' q h

/-- The head of a `list_blank` is well defined. -/
def list_blank.head {Γ} [Inhabited Γ] (l : list_blank Γ) : Γ :=
  l.lift_on List.headₓ
    (by 
      rintro _ _ ⟨i, rfl⟩
      cases a
      ·
        cases i <;> rfl 
      rfl)

@[simp]
theorem list_blank.head_mk {Γ} [Inhabited Γ] (l : List Γ) : list_blank.head (list_blank.mk l) = l.head :=
  rfl

/-- The tail of a `list_blank` is well defined (up to the tail of blanks). -/
def list_blank.tail {Γ} [Inhabited Γ] (l : list_blank Γ) : list_blank Γ :=
  l.lift_on (fun l => list_blank.mk l.tail)
    (by 
      rintro _ _ ⟨i, rfl⟩
      refine' Quotientₓ.sound' (Or.inl _)
      cases a <;>
        [·
          cases i <;> [exact ⟨0, rfl⟩, exact ⟨i, rfl⟩],
        exact ⟨i, rfl⟩])

@[simp]
theorem list_blank.tail_mk {Γ} [Inhabited Γ] (l : List Γ) : list_blank.tail (list_blank.mk l) = list_blank.mk l.tail :=
  rfl

/-- We can cons an element onto a `list_blank`. -/
def list_blank.cons {Γ} [Inhabited Γ] (a : Γ) (l : list_blank Γ) : list_blank Γ :=
  l.lift_on (fun l => list_blank.mk (List.cons a l))
    (by 
      rintro _ _ ⟨i, rfl⟩
      exact Quotientₓ.sound' (Or.inl ⟨i, rfl⟩))

@[simp]
theorem list_blank.cons_mk {Γ} [Inhabited Γ] (a : Γ) (l : List Γ) :
  list_blank.cons a (list_blank.mk l) = list_blank.mk (a :: l) :=
  rfl

@[simp]
theorem list_blank.head_cons {Γ} [Inhabited Γ] (a : Γ) : ∀ (l : list_blank Γ), (l.cons a).head = a :=
  Quotientₓ.ind'$
    by 
      exact fun l => rfl

@[simp]
theorem list_blank.tail_cons {Γ} [Inhabited Γ] (a : Γ) : ∀ (l : list_blank Γ), (l.cons a).tail = l :=
  Quotientₓ.ind'$
    by 
      exact fun l => rfl

/-- The `cons` and `head`/`tail` functions are mutually inverse, unlike in the case of `list` where
this only holds for nonempty lists. -/
@[simp]
theorem list_blank.cons_head_tail {Γ} [Inhabited Γ] : ∀ (l : list_blank Γ), l.tail.cons l.head = l :=
  Quotientₓ.ind'
    (by 
      refine' fun l => Quotientₓ.sound' (Or.inr _)
      cases l
      ·
        exact ⟨1, rfl⟩
      ·
        rfl)

/-- The `cons` and `head`/`tail` functions are mutually inverse, unlike in the case of `list` where
this only holds for nonempty lists. -/
theorem list_blank.exists_cons {Γ} [Inhabited Γ] (l : list_blank Γ) : ∃ a l', l = list_blank.cons a l' :=
  ⟨_, _, (list_blank.cons_head_tail _).symm⟩

/-- The n-th element of a `list_blank` is well defined for all `n : ℕ`, unlike in a `list`. -/
def list_blank.nth {Γ} [Inhabited Γ] (l : list_blank Γ) (n : ℕ) : Γ :=
  l.lift_on (fun l => List.inth l n)
    (by 
      rintro l _ ⟨i, rfl⟩
      simp only [List.inth]
      cases' lt_or_leₓ _ _ with h h
      ·
        rw [List.nth_append h]
      rw [List.nth_len_le h]
      cases' le_or_ltₓ _ _ with h₂ h₂
      ·
        rw [List.nth_len_le h₂]
      rw [List.nth_le_nth h₂, List.nth_le_append_right h, List.nth_le_repeat])

@[simp]
theorem list_blank.nth_mk {Γ} [Inhabited Γ] (l : List Γ) (n : ℕ) : (list_blank.mk l).nth n = l.inth n :=
  rfl

@[simp]
theorem list_blank.nth_zero {Γ} [Inhabited Γ] (l : list_blank Γ) : l.nth 0 = l.head :=
  by 
    conv  => toLHS rw [←list_blank.cons_head_tail l]
    exact Quotientₓ.induction_on' l.tail fun l => rfl

@[simp]
theorem list_blank.nth_succ {Γ} [Inhabited Γ] (l : list_blank Γ) (n : ℕ) : l.nth (n+1) = l.tail.nth n :=
  by 
    conv  => toLHS rw [←list_blank.cons_head_tail l]
    exact Quotientₓ.induction_on' l.tail fun l => rfl

@[ext]
theorem list_blank.ext {Γ} [Inhabited Γ] {L₁ L₂ : list_blank Γ} : (∀ i, L₁.nth i = L₂.nth i) → L₁ = L₂ :=
  list_blank.induction_on L₁$
    fun l₁ =>
      list_blank.induction_on L₂$
        fun l₂ H =>
          by 
            wlog h : l₁.length ≤ l₂.length using l₁ l₂ 
            swap
            ·
              exact (this$ fun i => (H i).symm).symm 
            refine' Quotientₓ.sound' (Or.inl ⟨l₂.length - l₁.length, _⟩)
            refine' List.ext_le _ fun i h h₂ => Eq.symm _
            ·
              simp only [add_tsub_cancel_of_le h, List.length_append, List.length_repeat]
            simp  at H 
            cases' lt_or_leₓ i l₁.length with h' h'
            ·
              simpa only [List.nth_le_append _ h', List.nth_le_nth h, List.nth_le_nth h', Option.iget] using H i
            ·
              simpa only [List.nth_le_append_right h', List.nth_le_repeat, List.nth_le_nth h, List.nth_len_le h',
                Option.iget] using H i

/-- Apply a function to a value stored at the nth position of the list. -/
@[simp]
def list_blank.modify_nth {Γ} [Inhabited Γ] (f : Γ → Γ) : ℕ → list_blank Γ → list_blank Γ
| 0, L => L.tail.cons (f L.head)
| n+1, L => (L.tail.modify_nth n).cons L.head

theorem list_blank.nth_modify_nth {Γ} [Inhabited Γ] (f : Γ → Γ) n i (L : list_blank Γ) :
  (L.modify_nth f n).nth i = if i = n then f (L.nth i) else L.nth i :=
  by 
    induction' n with n IH generalizing i L
    ·
      cases i <;>
        simp only [list_blank.nth_zero, if_true, list_blank.head_cons, list_blank.modify_nth, eq_self_iff_true,
          list_blank.nth_succ, if_false, list_blank.tail_cons]
    ·
      cases i
      ·
        rw [if_neg (Nat.succ_ne_zero _).symm]
        simp only [list_blank.nth_zero, list_blank.head_cons, list_blank.modify_nth]
      ·
        simp only [IH, list_blank.modify_nth, list_blank.nth_succ, list_blank.tail_cons]
        congr

/-- A pointed map of `inhabited` types is a map that sends one default value to the other. -/
structure pointed_map.{u, v}(Γ : Type u)(Γ' : Type v)[Inhabited Γ][Inhabited Γ'] : Type max u v where 
  f : Γ → Γ' 
  map_pt' : f (default _) = default _

instance  {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] : Inhabited (pointed_map Γ Γ') :=
  ⟨⟨fun _ => default _, rfl⟩⟩

instance  {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] : CoeFun (pointed_map Γ Γ') fun _ => Γ → Γ' :=
  ⟨pointed_map.f⟩

@[simp]
theorem pointed_map.mk_val {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : Γ → Γ') pt : (pointed_map.mk f pt : Γ → Γ') = f :=
  rfl

@[simp]
theorem pointed_map.map_pt {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : pointed_map Γ Γ') : f (default _) = default _ :=
  pointed_map.map_pt' _

@[simp]
theorem pointed_map.head_map {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : pointed_map Γ Γ') (l : List Γ) :
  (l.map f).head = f l.head :=
  by 
    cases l <;> [exact (pointed_map.map_pt f).symm, rfl]

/-- The `map` function on lists is well defined on `list_blank`s provided that the map is
pointed. -/
def list_blank.map {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : pointed_map Γ Γ') (l : list_blank Γ) : list_blank Γ' :=
  l.lift_on (fun l => list_blank.mk (List.map f l))
    (by 
      rintro l _ ⟨i, rfl⟩
      refine' Quotientₓ.sound' (Or.inl ⟨i, _⟩)
      simp only [pointed_map.map_pt, List.map_append, List.map_repeat])

@[simp]
theorem list_blank.map_mk {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : pointed_map Γ Γ') (l : List Γ) :
  (list_blank.mk l).map f = list_blank.mk (l.map f) :=
  rfl

@[simp]
theorem list_blank.head_map {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : pointed_map Γ Γ') (l : list_blank Γ) :
  (l.map f).head = f l.head :=
  by 
    conv  => toLHS rw [←list_blank.cons_head_tail l]
    exact Quotientₓ.induction_on' l fun a => rfl

@[simp]
theorem list_blank.tail_map {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : pointed_map Γ Γ') (l : list_blank Γ) :
  (l.map f).tail = l.tail.map f :=
  by 
    conv  => toLHS rw [←list_blank.cons_head_tail l]
    exact Quotientₓ.induction_on' l fun a => rfl

@[simp]
theorem list_blank.map_cons {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : pointed_map Γ Γ') (l : list_blank Γ) (a : Γ) :
  (l.cons a).map f = (l.map f).cons (f a) :=
  by 
    refine' (list_blank.cons_head_tail _).symm.trans _ 
    simp only [list_blank.head_map, list_blank.head_cons, list_blank.tail_map, list_blank.tail_cons]

@[simp]
theorem list_blank.nth_map {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : pointed_map Γ Γ') (l : list_blank Γ) (n : ℕ) :
  (l.map f).nth n = f (l.nth n) :=
  l.induction_on
    (by 
      intro l 
      simp only [List.nth_map, list_blank.map_mk, list_blank.nth_mk, List.inth]
      cases l.nth n
      ·
        exact f.2.symm
      ·
        rfl)

/-- The `i`-th projection as a pointed map. -/
def proj {ι : Type _} {Γ : ι → Type _} [∀ i, Inhabited (Γ i)] (i : ι) : pointed_map (∀ i, Γ i) (Γ i) :=
  ⟨fun a => a i, rfl⟩

theorem proj_map_nth {ι : Type _} {Γ : ι → Type _} [∀ i, Inhabited (Γ i)] (i : ι) L n :
  (list_blank.map (@proj ι Γ _ i) L).nth n = L.nth n i :=
  by 
    rw [list_blank.nth_map] <;> rfl

theorem list_blank.map_modify_nth {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (F : pointed_map Γ Γ') (f : Γ → Γ) (f' : Γ' → Γ')
  (H : ∀ x, F (f x) = f' (F x)) n (L : list_blank Γ) : (L.modify_nth f n).map F = (L.map F).modifyNth f' n :=
  by 
    induction' n with n IH generalizing L <;>
      simp only [list_blank.head_map, list_blank.modify_nth, list_blank.map_cons, list_blank.tail_map]

/-- Append a list on the left side of a list_blank. -/
@[simp]
def list_blank.append {Γ} [Inhabited Γ] : List Γ → list_blank Γ → list_blank Γ
| [], L => L
| a :: l, L => list_blank.cons a (list_blank.append l L)

@[simp]
theorem list_blank.append_mk {Γ} [Inhabited Γ] (l₁ l₂ : List Γ) :
  list_blank.append l₁ (list_blank.mk l₂) = list_blank.mk (l₁ ++ l₂) :=
  by 
    induction l₁ <;> simp only [list_blank.append, List.nil_append, List.cons_append, list_blank.cons_mk]

theorem list_blank.append_assoc {Γ} [Inhabited Γ] (l₁ l₂ : List Γ) (l₃ : list_blank Γ) :
  list_blank.append (l₁ ++ l₂) l₃ = list_blank.append l₁ (list_blank.append l₂ l₃) :=
  l₃.induction_on$
    by 
      intro  <;> simp only [list_blank.append_mk, List.append_assoc]

/-- The `bind` function on lists is well defined on `list_blank`s provided that the default element
is sent to a sequence of default elements. -/
def list_blank.bind {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (l : list_blank Γ) (f : Γ → List Γ')
  (hf : ∃ n, f (default _) = List.repeat (default _) n) : list_blank Γ' :=
  l.lift_on (fun l => list_blank.mk (List.bind l f))
    (by 
      rintro l _ ⟨i, rfl⟩
      cases' hf with n e 
      refine' Quotientₓ.sound' (Or.inl ⟨i*n, _⟩)
      rw [List.bind_append, mul_commₓ]
      congr 
      induction' i with i IH 
      rfl 
      simp only [IH, e, List.repeat_add, Nat.mul_succ, add_commₓ, List.repeat_succ, List.cons_bind])

@[simp]
theorem list_blank.bind_mk {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (l : List Γ) (f : Γ → List Γ') hf :
  (list_blank.mk l).bind f hf = list_blank.mk (l.bind f) :=
  rfl

@[simp]
theorem list_blank.cons_bind {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (a : Γ) (l : list_blank Γ) (f : Γ → List Γ') hf :
  (l.cons a).bind f hf = (l.bind f hf).append (f a) :=
  l.induction_on$
    by 
      intro  <;> simp only [list_blank.append_mk, list_blank.bind_mk, list_blank.cons_mk, List.cons_bind]

/-- The tape of a Turing machine is composed of a head element (which we imagine to be the
current position of the head), together with two `list_blank`s denoting the portions of the tape
going off to the left and right. When the Turing machine moves right, an element is pulled from the
right side and becomes the new head, while the head element is consed onto the left side. -/
structure tape(Γ : Type _)[Inhabited Γ] where 
  head : Γ 
  left : list_blank Γ 
  right : list_blank Γ

instance tape.inhabited {Γ} [Inhabited Γ] : Inhabited (tape Γ) :=
  ⟨by 
      constructor <;> apply default⟩

-- error in Computability.TuringMachine: ././Mathport/Syntax/Translate/Basic.lean:704:9: unsupported derive handler decidable_eq
/-- A direction for the turing machine `move` command, either
  left or right. -/ @[derive #[expr decidable_eq], derive #[expr inhabited]] inductive dir
| left
| right

/-- The "inclusive" left side of the tape, including both `left` and `head`. -/
def tape.left₀ {Γ} [Inhabited Γ] (T : tape Γ) : list_blank Γ :=
  T.left.cons T.head

/-- The "inclusive" right side of the tape, including both `right` and `head`. -/
def tape.right₀ {Γ} [Inhabited Γ] (T : tape Γ) : list_blank Γ :=
  T.right.cons T.head

/-- Move the tape in response to a motion of the Turing machine. Note that `T.move dir.left` makes
`T.left` smaller; the Turing machine is moving left and the tape is moving right. -/
def tape.move {Γ} [Inhabited Γ] : dir → tape Γ → tape Γ
| dir.left, ⟨a, L, R⟩ => ⟨L.head, L.tail, R.cons a⟩
| dir.right, ⟨a, L, R⟩ => ⟨R.head, L.cons a, R.tail⟩

@[simp]
theorem tape.move_left_right {Γ} [Inhabited Γ] (T : tape Γ) : (T.move dir.left).move dir.right = T :=
  by 
    cases T <;> simp [tape.move]

@[simp]
theorem tape.move_right_left {Γ} [Inhabited Γ] (T : tape Γ) : (T.move dir.right).move dir.left = T :=
  by 
    cases T <;> simp [tape.move]

/-- Construct a tape from a left side and an inclusive right side. -/
def tape.mk' {Γ} [Inhabited Γ] (L R : list_blank Γ) : tape Γ :=
  ⟨R.head, L, R.tail⟩

@[simp]
theorem tape.mk'_left {Γ} [Inhabited Γ] (L R : list_blank Γ) : (tape.mk' L R).left = L :=
  rfl

@[simp]
theorem tape.mk'_head {Γ} [Inhabited Γ] (L R : list_blank Γ) : (tape.mk' L R).head = R.head :=
  rfl

@[simp]
theorem tape.mk'_right {Γ} [Inhabited Γ] (L R : list_blank Γ) : (tape.mk' L R).right = R.tail :=
  rfl

@[simp]
theorem tape.mk'_right₀ {Γ} [Inhabited Γ] (L R : list_blank Γ) : (tape.mk' L R).right₀ = R :=
  list_blank.cons_head_tail _

@[simp]
theorem tape.mk'_left_right₀ {Γ} [Inhabited Γ] (T : tape Γ) : tape.mk' T.left T.right₀ = T :=
  by 
    cases T <;>
      simp only [tape.right₀, tape.mk', list_blank.head_cons, list_blank.tail_cons, eq_self_iff_true, and_selfₓ]

theorem tape.exists_mk' {Γ} [Inhabited Γ] (T : tape Γ) : ∃ L R, T = tape.mk' L R :=
  ⟨_, _, (tape.mk'_left_right₀ _).symm⟩

@[simp]
theorem tape.move_left_mk' {Γ} [Inhabited Γ] (L R : list_blank Γ) :
  (tape.mk' L R).move dir.left = tape.mk' L.tail (R.cons L.head) :=
  by 
    simp only [tape.move, tape.mk', list_blank.head_cons, eq_self_iff_true, list_blank.cons_head_tail, and_selfₓ,
      list_blank.tail_cons]

@[simp]
theorem tape.move_right_mk' {Γ} [Inhabited Γ] (L R : list_blank Γ) :
  (tape.mk' L R).move dir.right = tape.mk' (L.cons R.head) R.tail :=
  by 
    simp only [tape.move, tape.mk', list_blank.head_cons, eq_self_iff_true, list_blank.cons_head_tail, and_selfₓ,
      list_blank.tail_cons]

/-- Construct a tape from a left side and an inclusive right side. -/
def tape.mk₂ {Γ} [Inhabited Γ] (L R : List Γ) : tape Γ :=
  tape.mk' (list_blank.mk L) (list_blank.mk R)

/-- Construct a tape from a list, with the head of the list at the TM head and the rest going
to the right. -/
def tape.mk₁ {Γ} [Inhabited Γ] (l : List Γ) : tape Γ :=
  tape.mk₂ [] l

/-- The `nth` function of a tape is integer-valued, with index `0` being the head, negative indexes
on the left and positive indexes on the right. (Picture a number line.) -/
def tape.nth {Γ} [Inhabited Γ] (T : tape Γ) : ℤ → Γ
| 0 => T.head
| (n+1 : ℕ) => T.right.nth n
| -[1+ n] => T.left.nth n

@[simp]
theorem tape.nth_zero {Γ} [Inhabited Γ] (T : tape Γ) : T.nth 0 = T.1 :=
  rfl

theorem tape.right₀_nth {Γ} [Inhabited Γ] (T : tape Γ) (n : ℕ) : T.right₀.nth n = T.nth n :=
  by 
    cases n <;>
      simp only [tape.nth, tape.right₀, Int.coe_nat_zero, list_blank.nth_zero, list_blank.nth_succ,
        list_blank.head_cons, list_blank.tail_cons]

@[simp]
theorem tape.mk'_nth_nat {Γ} [Inhabited Γ] (L R : list_blank Γ) (n : ℕ) : (tape.mk' L R).nth n = R.nth n :=
  by 
    rw [←tape.right₀_nth, tape.mk'_right₀]

@[simp]
theorem tape.move_left_nth {Γ} [Inhabited Γ] : ∀ (T : tape Γ) (i : ℤ), (T.move dir.left).nth i = T.nth (i - 1)
| ⟨a, L, R⟩, -[1+ n] => (list_blank.nth_succ _ _).symm
| ⟨a, L, R⟩, 0 => (list_blank.nth_zero _).symm
| ⟨a, L, R⟩, 1 => (list_blank.nth_zero _).trans (list_blank.head_cons _ _)
| ⟨a, L, R⟩, (n+1 : ℕ)+1 =>
  by 
    rw [add_sub_cancel]
    change (R.cons a).nth (n+1) = R.nth n 
    rw [list_blank.nth_succ, list_blank.tail_cons]

@[simp]
theorem tape.move_right_nth {Γ} [Inhabited Γ] (T : tape Γ) (i : ℤ) : (T.move dir.right).nth i = T.nth (i+1) :=
  by 
    conv  => toRHS rw [←T.move_right_left] <;> rw [tape.move_left_nth, add_sub_cancel]

@[simp]
theorem tape.move_right_n_head {Γ} [Inhabited Γ] (T : tape Γ) (i : ℕ) : ((tape.move dir.right^[i]) T).head = T.nth i :=
  by 
    induction i generalizing T <;> [rfl, simp only [tape.move_right_nth, Int.coe_nat_succ, iterate_succ]]

/-- Replace the current value of the head on the tape. -/
def tape.write {Γ} [Inhabited Γ] (b : Γ) (T : tape Γ) : tape Γ :=
  { T with head := b }

@[simp]
theorem tape.write_self {Γ} [Inhabited Γ] : ∀ (T : tape Γ), T.write T.1 = T :=
  by 
    rintro ⟨⟩ <;> rfl

@[simp]
theorem tape.write_nth {Γ} [Inhabited Γ] (b : Γ) :
  ∀ (T : tape Γ) {i : ℤ}, (T.write b).nth i = if i = 0 then b else T.nth i
| ⟨a, L, R⟩, 0 => rfl
| ⟨a, L, R⟩, (n+1 : ℕ) => rfl
| ⟨a, L, R⟩, -[1+ n] => rfl

@[simp]
theorem tape.write_mk' {Γ} [Inhabited Γ] (a b : Γ) (L R : list_blank Γ) :
  (tape.mk' L (R.cons a)).write b = tape.mk' L (R.cons b) :=
  by 
    simp only [tape.write, tape.mk', list_blank.head_cons, list_blank.tail_cons, eq_self_iff_true, and_selfₓ]

/-- Apply a pointed map to a tape to change the alphabet. -/
def tape.map {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : pointed_map Γ Γ') (T : tape Γ) : tape Γ' :=
  ⟨f T.1, T.2.map f, T.3.map f⟩

@[simp]
theorem tape.map_fst {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : pointed_map Γ Γ') : ∀ (T : tape Γ), (T.map f).1 = f T.1 :=
  by 
    rintro ⟨⟩ <;> rfl

@[simp]
theorem tape.map_write {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : pointed_map Γ Γ') (b : Γ) :
  ∀ (T : tape Γ), (T.write b).map f = (T.map f).write (f b) :=
  by 
    rintro ⟨⟩ <;> rfl

@[simp]
theorem tape.write_move_right_n {Γ} [Inhabited Γ] (f : Γ → Γ) (L R : list_blank Γ) (n : ℕ) :
  ((tape.move dir.right^[n]) (tape.mk' L R)).write (f (R.nth n)) =
    (tape.move dir.right^[n]) (tape.mk' L (R.modify_nth f n)) :=
  by 
    induction' n with n IH generalizing L R
    ·
      simp only [list_blank.nth_zero, list_blank.modify_nth, iterate_zero_apply]
      rw [←tape.write_mk', list_blank.cons_head_tail]
    simp only [list_blank.head_cons, list_blank.nth_succ, list_blank.modify_nth, tape.move_right_mk',
      list_blank.tail_cons, iterate_succ_apply, IH]

theorem tape.map_move {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : pointed_map Γ Γ') (T : tape Γ) d :
  (T.move d).map f = (T.map f).move d :=
  by 
    cases T <;>
      cases d <;>
        simp only [tape.move, tape.map, list_blank.head_map, eq_self_iff_true, list_blank.map_cons, and_selfₓ,
          list_blank.tail_map]

theorem tape.map_mk' {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : pointed_map Γ Γ') (L R : list_blank Γ) :
  (tape.mk' L R).map f = tape.mk' (L.map f) (R.map f) :=
  by 
    simp only [tape.mk', tape.map, list_blank.head_map, eq_self_iff_true, and_selfₓ, list_blank.tail_map]

theorem tape.map_mk₂ {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : pointed_map Γ Γ') (L R : List Γ) :
  (tape.mk₂ L R).map f = tape.mk₂ (L.map f) (R.map f) :=
  by 
    simp only [tape.mk₂, tape.map_mk', list_blank.map_mk]

theorem tape.map_mk₁ {Γ Γ'} [Inhabited Γ] [Inhabited Γ'] (f : pointed_map Γ Γ') (l : List Γ) :
  (tape.mk₁ l).map f = tape.mk₁ (l.map f) :=
  tape.map_mk₂ _ _ _

/-- Run a state transition function `σ → option σ` "to completion". The return value is the last
state returned before a `none` result. If the state transition function always returns `some`,
then the computation diverges, returning `part.none`. -/
def eval {σ} (f : σ → Option σ) : σ → Part σ :=
  Pfun.fix fun s => Part.some$ (f s).elim (Sum.inl s) Sum.inr

/-- The reflexive transitive closure of a state transition function. `reaches f a b` means
there is a finite sequence of steps `f a = some a₁`, `f a₁ = some a₂`, ... such that `aₙ = b`.
This relation permits zero steps of the state transition function. -/
def reaches {σ} (f : σ → Option σ) : σ → σ → Prop :=
  refl_trans_gen fun a b => b ∈ f a

/-- The transitive closure of a state transition function. `reaches₁ f a b` means there is a
nonempty finite sequence of steps `f a = some a₁`, `f a₁ = some a₂`, ... such that `aₙ = b`.
This relation does not permit zero steps of the state transition function. -/
def reaches₁ {σ} (f : σ → Option σ) : σ → σ → Prop :=
  trans_gen fun a b => b ∈ f a

theorem reaches₁_eq {σ} {f : σ → Option σ} {a b c} (h : f a = f b) : reaches₁ f a c ↔ reaches₁ f b c :=
  trans_gen.head'_iff.trans
    (trans_gen.head'_iff.trans$
        by 
          rw [h]).symm

theorem reaches_total {σ} {f : σ → Option σ} {a b c} (hab : reaches f a b) (hac : reaches f a c) :
  reaches f b c ∨ reaches f c b :=
  refl_trans_gen.total_of_right_unique (fun _ _ _ => Option.mem_unique) hab hac

theorem reaches₁_fwd {σ} {f : σ → Option σ} {a b c} (h₁ : reaches₁ f a c) (h₂ : b ∈ f a) : reaches f b c :=
  by 
    rcases trans_gen.head'_iff.1 h₁ with ⟨b', hab, hbc⟩
    cases Option.mem_unique hab h₂ 
    exact hbc

/-- A variation on `reaches`. `reaches₀ f a b` holds if whenever `reaches₁ f b c` then
`reaches₁ f a c`. This is a weaker property than `reaches` and is useful for replacing states with
equivalent states without taking a step. -/
def reaches₀ {σ} (f : σ → Option σ) (a b : σ) : Prop :=
  ∀ c, reaches₁ f b c → reaches₁ f a c

theorem reaches₀.trans {σ} {f : σ → Option σ} {a b c : σ} (h₁ : reaches₀ f a b) (h₂ : reaches₀ f b c) : reaches₀ f a c
| d, h₃ => h₁ _ (h₂ _ h₃)

@[refl]
theorem reaches₀.refl {σ} {f : σ → Option σ} (a : σ) : reaches₀ f a a
| b, h => h

theorem reaches₀.single {σ} {f : σ → Option σ} {a b : σ} (h : b ∈ f a) : reaches₀ f a b
| c, h₂ => h₂.head h

theorem reaches₀.head {σ} {f : σ → Option σ} {a b c : σ} (h : b ∈ f a) (h₂ : reaches₀ f b c) : reaches₀ f a c :=
  (reaches₀.single h).trans h₂

theorem reaches₀.tail {σ} {f : σ → Option σ} {a b c : σ} (h₁ : reaches₀ f a b) (h : c ∈ f b) : reaches₀ f a c :=
  h₁.trans (reaches₀.single h)

theorem reaches₀_eq {σ} {f : σ → Option σ} {a b} (e : f a = f b) : reaches₀ f a b
| d, h => (reaches₁_eq e).2 h

theorem reaches₁.to₀ {σ} {f : σ → Option σ} {a b : σ} (h : reaches₁ f a b) : reaches₀ f a b
| c, h₂ => h.trans h₂

theorem reaches.to₀ {σ} {f : σ → Option σ} {a b : σ} (h : reaches f a b) : reaches₀ f a b
| c, h₂ => h₂.trans_right h

theorem reaches₀.tail' {σ} {f : σ → Option σ} {a b c : σ} (h : reaches₀ f a b) (h₂ : c ∈ f b) : reaches₁ f a c :=
  h _ (trans_gen.single h₂)

/-- (co-)Induction principle for `eval`. If a property `C` holds of any point `a` evaluating to `b`
which is either terminal (meaning `a = b`) or where the next point also satisfies `C`, then it
holds of any point where `eval f a` evaluates to `b`. This formalizes the notion that if
`eval f a` evaluates to `b` then it reaches terminal state `b` in finitely many steps. -/
@[elab_as_eliminator]
def eval_induction {σ} {f : σ → Option σ} {b : σ} {C : σ → Sort _} {a : σ} (h : b ∈ eval f a)
  (H : ∀ a, b ∈ eval f a → (∀ a', b ∈ eval f a' → f a = some a' → C a') → C a) : C a :=
  Pfun.fixInduction h
    fun a' ha' h' =>
      H _ ha'$
        fun b' hb' e =>
          h' _ hb'$
            Part.mem_some_iff.2$
              by 
                rw [e] <;> rfl

theorem mem_eval {σ} {f : σ → Option σ} {a b} : b ∈ eval f a ↔ reaches f a b ∧ f b = none :=
  ⟨fun h =>
      by 
        refine' eval_induction h fun a h IH => _ 
        cases' e : f a with a'
        ·
          rw
            [Part.mem_unique h
              (Pfun.mem_fix_iff.2$
                Or.inl$
                  Part.mem_some_iff.2$
                    by 
                      rw [e] <;> rfl)]
          exact ⟨refl_trans_gen.refl, e⟩
        ·
          rcases Pfun.mem_fix_iff.1 h with (h | ⟨_, h, h'⟩) <;> rw [e] at h <;> cases Part.mem_some_iff.1 h 
          cases'
            IH a' h'
              (by 
                rwa [e]) with
            h₁ h₂ 
          exact ⟨refl_trans_gen.head e h₁, h₂⟩,
    fun ⟨h₁, h₂⟩ =>
      by 
        refine' refl_trans_gen.head_induction_on h₁ _ fun a a' h _ IH => _
        ·
          refine' Pfun.mem_fix_iff.2 (Or.inl _)
          rw [h₂]
          apply Part.mem_some
        ·
          refine' Pfun.mem_fix_iff.2 (Or.inr ⟨_, _, IH⟩)
          rw [show f a = _ from h]
          apply Part.mem_some⟩

theorem eval_maximal₁ {σ} {f : σ → Option σ} {a b} (h : b ∈ eval f a) c : ¬reaches₁ f b c
| bc =>
  let ⟨ab, b0⟩ := mem_eval.1 h 
  let ⟨b', h', _⟩ := trans_gen.head'_iff.1 bc 
  by 
    cases b0.symm.trans h'

theorem eval_maximal {σ} {f : σ → Option σ} {a b} (h : b ∈ eval f a) {c} : reaches f b c ↔ c = b :=
  let ⟨ab, b0⟩ := mem_eval.1 h 
  refl_trans_gen_iff_eq$
    fun b' h' =>
      by 
        cases b0.symm.trans h'

theorem reaches_eval {σ} {f : σ → Option σ} {a b} (ab : reaches f a b) : eval f a = eval f b :=
  Part.ext$
    fun c =>
      ⟨fun h =>
          let ⟨ac, c0⟩ := mem_eval.1 h 
          mem_eval.2
            ⟨(or_iff_left_of_imp$
                    by 
                      exact fun cb => (eval_maximal h).1 cb ▸ refl_trans_gen.refl).1
                (reaches_total ab ac),
              c0⟩,
        fun h =>
          let ⟨bc, c0⟩ := mem_eval.1 h 
          mem_eval.2 ⟨ab.trans bc, c0⟩⟩

/-- Given a relation `tr : σ₁ → σ₂ → Prop` between state spaces, and state transition functions
`f₁ : σ₁ → option σ₁` and `f₂ : σ₂ → option σ₂`, `respects f₁ f₂ tr` means that if `tr a₁ a₂` holds
initially and `f₁` takes a step to `a₂` then `f₂` will take one or more steps before reaching a
state `b₂` satisfying `tr a₂ b₂`, and if `f₁ a₁` terminates then `f₂ a₂` also terminates.
Such a relation `tr` is also known as a refinement. -/
def respects {σ₁ σ₂} (f₁ : σ₁ → Option σ₁) (f₂ : σ₂ → Option σ₂) (tr : σ₁ → σ₂ → Prop) :=
  ∀ ⦃a₁ a₂⦄,
    tr a₁ a₂ →
      (match f₁ a₁ with 
      | some b₁ => ∃ b₂, tr b₁ b₂ ∧ reaches₁ f₂ a₂ b₂
      | none => f₂ a₂ = none :
      Prop)

-- error in Computability.TuringMachine: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tr_reaches₁
{σ₁ σ₂ f₁ f₂}
{tr : σ₁ → σ₂ → exprProp()}
(H : respects f₁ f₂ tr)
{a₁ a₂}
(aa : tr a₁ a₂)
{b₁}
(ab : reaches₁ f₁ a₁ b₁) : «expr∃ , »((b₂), «expr ∧ »(tr b₁ b₂, reaches₁ f₂ a₂ b₂)) :=
begin
  induction [expr ab] [] ["with", ident c₁, ident ac, ident c₁, ident d₁, ident ac, ident cd, ident IH] [],
  { have [] [] [":=", expr H aa],
    rwa [expr show «expr = »(f₁ a₁, _), from ac] ["at", ident this] },
  { rcases [expr IH, "with", "⟨", ident c₂, ",", ident cc, ",", ident ac₂, "⟩"],
    have [] [] [":=", expr H cc],
    rw [expr show «expr = »(f₁ c₁, _), from cd] ["at", ident this],
    rcases [expr this, "with", "⟨", ident d₂, ",", ident dd, ",", ident cd₂, "⟩"],
    exact [expr ⟨_, dd, ac₂.trans cd₂⟩] }
end

theorem tr_reaches {σ₁ σ₂ f₁ f₂} {tr : σ₁ → σ₂ → Prop} (H : respects f₁ f₂ tr) {a₁ a₂} (aa : tr a₁ a₂) {b₁}
  (ab : reaches f₁ a₁ b₁) : ∃ b₂, tr b₁ b₂ ∧ reaches f₂ a₂ b₂ :=
  by 
    rcases refl_trans_gen_iff_eq_or_trans_gen.1 ab with (rfl | ab)
    ·
      exact ⟨_, aa, refl_trans_gen.refl⟩
    ·
      exact
        let ⟨b₂, bb, h⟩ := tr_reaches₁ H aa ab
        ⟨b₂, bb, h.to_refl⟩

-- error in Computability.TuringMachine: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tr_reaches_rev
{σ₁ σ₂ f₁ f₂}
{tr : σ₁ → σ₂ → exprProp()}
(H : respects f₁ f₂ tr)
{a₁ a₂}
(aa : tr a₁ a₂)
{b₂}
(ab : reaches f₂ a₂ b₂) : «expr∃ , »((c₁ c₂), «expr ∧ »(reaches f₂ b₂ c₂, «expr ∧ »(tr c₁ c₂, reaches f₁ a₁ c₁))) :=
begin
  induction [expr ab] [] ["with", ident c₂, ident d₂, ident ac, ident cd, ident IH] [],
  { exact [expr ⟨_, _, refl_trans_gen.refl, aa, refl_trans_gen.refl⟩] },
  { rcases [expr IH, "with", "⟨", ident e₁, ",", ident e₂, ",", ident ce, ",", ident ee, ",", ident ae, "⟩"],
    rcases [expr refl_trans_gen.cases_head ce, "with", ident rfl, "|", "⟨", ident d', ",", ident cd', ",", ident de, "⟩"],
    { have [] [] [":=", expr H ee],
      revert [ident this],
      cases [expr eg, ":", expr f₁ e₁] ["with", ident g₁]; simp [] [] ["only"] ["[", expr respects, ",", expr and_imp, ",", expr exists_imp_distrib, "]"] [] [],
      { intro [ident c0],
        cases [expr cd.symm.trans c0] [] },
      { intros [ident g₂, ident gg, ident cg],
        rcases [expr trans_gen.head'_iff.1 cg, "with", "⟨", ident d', ",", ident cd', ",", ident dg, "⟩"],
        cases [expr option.mem_unique cd cd'] [],
        exact [expr ⟨_, _, dg, gg, ae.tail eg⟩] } },
    { cases [expr option.mem_unique cd cd'] [],
      exact [expr ⟨_, _, de, ee, ae⟩] } }
end

-- error in Computability.TuringMachine: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tr_eval
{σ₁ σ₂ f₁ f₂}
{tr : σ₁ → σ₂ → exprProp()}
(H : respects f₁ f₂ tr)
{a₁ b₁ a₂}
(aa : tr a₁ a₂)
(ab : «expr ∈ »(b₁, eval f₁ a₁)) : «expr∃ , »((b₂), «expr ∧ »(tr b₁ b₂, «expr ∈ »(b₂, eval f₂ a₂))) :=
begin
  cases [expr mem_eval.1 ab] ["with", ident ab, ident b0],
  rcases [expr tr_reaches H aa ab, "with", "⟨", ident b₂, ",", ident bb, ",", ident ab, "⟩"],
  refine [expr ⟨_, bb, mem_eval.2 ⟨ab, _⟩⟩],
  have [] [] [":=", expr H bb],
  rwa [expr b0] ["at", ident this]
end

-- error in Computability.TuringMachine: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tr_eval_rev
{σ₁ σ₂ f₁ f₂}
{tr : σ₁ → σ₂ → exprProp()}
(H : respects f₁ f₂ tr)
{a₁ b₂ a₂}
(aa : tr a₁ a₂)
(ab : «expr ∈ »(b₂, eval f₂ a₂)) : «expr∃ , »((b₁), «expr ∧ »(tr b₁ b₂, «expr ∈ »(b₁, eval f₁ a₁))) :=
begin
  cases [expr mem_eval.1 ab] ["with", ident ab, ident b0],
  rcases [expr tr_reaches_rev H aa ab, "with", "⟨", ident c₁, ",", ident c₂, ",", ident bc, ",", ident cc, ",", ident ac, "⟩"],
  cases [expr (refl_trans_gen_iff_eq (by exact [expr option.eq_none_iff_forall_not_mem.1 b0])).1 bc] [],
  refine [expr ⟨_, cc, mem_eval.2 ⟨ac, _⟩⟩],
  have [] [] [":=", expr H cc],
  cases [expr f₁ c₁] ["with", ident d₁],
  { refl },
  rcases [expr this, "with", "⟨", ident d₂, ",", ident dd, ",", ident bd, "⟩"],
  rcases [expr trans_gen.head'_iff.1 bd, "with", "⟨", ident e, ",", ident h, ",", "_", "⟩"],
  cases [expr b0.symm.trans h] []
end

theorem tr_eval_dom {σ₁ σ₂ f₁ f₂} {tr : σ₁ → σ₂ → Prop} (H : respects f₁ f₂ tr) {a₁ a₂} (aa : tr a₁ a₂) :
  (eval f₂ a₂).Dom ↔ (eval f₁ a₁).Dom :=
  ⟨fun h =>
      let ⟨b₂, tr, h, _⟩ := tr_eval_rev H aa ⟨h, rfl⟩
      h,
    fun h =>
      let ⟨b₂, tr, h, _⟩ := tr_eval H aa ⟨h, rfl⟩
      h⟩

/-- A simpler version of `respects` when the state transition relation `tr` is a function. -/
def frespects {σ₁ σ₂} (f₂ : σ₂ → Option σ₂) (tr : σ₁ → σ₂) (a₂ : σ₂) : Option σ₁ → Prop
| some b₁ => reaches₁ f₂ a₂ (tr b₁)
| none => f₂ a₂ = none

theorem frespects_eq {σ₁ σ₂} {f₂ : σ₂ → Option σ₂} {tr : σ₁ → σ₂} {a₂ b₂} (h : f₂ a₂ = f₂ b₂) :
  ∀ {b₁}, frespects f₂ tr a₂ b₁ ↔ frespects f₂ tr b₂ b₁
| some b₁ => reaches₁_eq h
| none =>
  by 
    unfold frespects <;> rw [h]

theorem fun_respects {σ₁ σ₂ f₁ f₂} {tr : σ₁ → σ₂} :
  (respects f₁ f₂ fun a b => tr a = b) ↔ ∀ ⦃a₁⦄, frespects f₂ tr (tr a₁) (f₁ a₁) :=
  forall_congrₓ$
    fun a₁ =>
      by 
        cases f₁ a₁ <;> simp only [frespects, respects, exists_eq_left', forall_eq']

theorem tr_eval' {σ₁ σ₂} (f₁ : σ₁ → Option σ₁) (f₂ : σ₂ → Option σ₂) (tr : σ₁ → σ₂)
  (H : respects f₁ f₂ fun a b => tr a = b) a₁ : eval f₂ (tr a₁) = tr <$> eval f₁ a₁ :=
  Part.ext$
    fun b₂ =>
      ⟨fun h =>
          let ⟨b₁, bb, hb⟩ := tr_eval_rev H rfl h
          (Part.mem_map_iff _).2 ⟨b₁, hb, bb⟩,
        fun h =>
          by 
            rcases(Part.mem_map_iff _).1 h with ⟨b₁, ab, bb⟩
            rcases tr_eval H rfl ab with ⟨_, rfl, h⟩
            rwa [bb] at h⟩

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
of generality, where the output ends. If equality to `default Γ` is decidable we can trim the list
to remove the infinite tail of blanks.)
-/


namespace TM0

section 

parameter (Γ : Type _)[Inhabited Γ]

parameter (Λ : Type _)[Inhabited Λ]

/-- A Turing machine "statement" is just a command to either move
  left or right, or write a symbol on the tape. -/
inductive stmt
  | move : dir → stmt
  | write : Γ → stmt

instance stmt.inhabited : Inhabited stmt :=
  ⟨stmt.write (default _)⟩

/-- A Post-Turing machine with symbol type `Γ` and label type `Λ`
  is a function which, given the current state `q : Λ` and
  the tape head `a : Γ`, either halts (returns `none`) or returns
  a new state `q' : Λ` and a `stmt` describing what to do,
  either a move left or right, or a write command.

  Both `Λ` and `Γ` are required to be inhabited; the default value
  for `Γ` is the "blank" tape value, and the default value of `Λ` is
  the initial state. -/
@[nolint unused_arguments]
def machine :=
  Λ → Γ → Option (Λ × stmt)

instance machine.inhabited : Inhabited machine :=
  by 
    unfold machine <;> infer_instance

/-- The configuration state of a Turing machine during operation
  consists of a label (machine state), and a tape, represented in
  the form `(a, L, R)` meaning the tape looks like `L.rev ++ [a] ++ R`
  with the machine currently reading the `a`. The lists are
  automatically extended with blanks as the machine moves around. -/
structure cfg where 
  q : Λ 
  Tape : tape Γ

instance cfg.inhabited : Inhabited cfg :=
  ⟨⟨default _, default _⟩⟩

parameter {Γ Λ}

/-- Execution semantics of the Turing machine. -/
def step (M : machine) : cfg → Option cfg
| ⟨q, T⟩ =>
  (M q T.1).map
    fun ⟨q', a⟩ =>
      ⟨q',
        match a with 
        | stmt.move d => T.move d
        | stmt.write a => T.write a⟩

/-- The statement `reaches M s₁ s₂` means that `s₂` is obtained
  starting from `s₁` after a finite number of steps from `s₂`. -/
def reaches (M : machine) : cfg → cfg → Prop :=
  refl_trans_gen fun a b => b ∈ step M a

/-- The initial configuration. -/
def init (l : List Γ) : cfg :=
  ⟨default Λ, tape.mk₁ l⟩

/-- Evaluate a Turing machine on initial input to a final state,
  if it terminates. -/
def eval (M : machine) (l : List Γ) : Part (list_blank Γ) :=
  (eval (step M) (init l)).map fun c => c.tape.right₀

/-- The raw definition of a Turing machine does not require that
  `Γ` and `Λ` are finite, and in practice we will be interested
  in the infinite `Λ` case. We recover instead a notion of
  "effectively finite" Turing machines, which only make use of a
  finite subset of their states. We say that a set `S ⊆ Λ`
  supports a Turing machine `M` if `S` is closed under the
  transition function and contains the initial state. -/
def supports (M : machine) (S : Set Λ) :=
  default Λ ∈ S ∧ ∀ {q a q' s}, (q', s) ∈ M q a → q ∈ S → q' ∈ S

theorem step_supports (M : machine) {S} (ss : supports M S) : ∀ {c c' : cfg}, c' ∈ step M c → c.q ∈ S → c'.q ∈ S
| ⟨q, T⟩, c', h₁, h₂ =>
  by 
    rcases Option.map_eq_some'.1 h₁ with ⟨⟨q', a⟩, h, rfl⟩
    exact ss.2 h h₂

theorem univ_supports (M : machine) : supports M Set.Univ :=
  ⟨trivialₓ, fun q a q' s h₁ h₂ => trivialₓ⟩

end 

section 

variable{Γ : Type _}[Inhabited Γ]

variable{Γ' : Type _}[Inhabited Γ']

variable{Λ : Type _}[Inhabited Λ]

variable{Λ' : Type _}[Inhabited Λ']

/-- Map a TM statement across a function. This does nothing to move statements and maps the write
values. -/
def stmt.map (f : pointed_map Γ Γ') : stmt Γ → stmt Γ'
| stmt.move d => stmt.move d
| stmt.write a => stmt.write (f a)

/-- Map a configuration across a function, given `f : Γ → Γ'` a map of the alphabets and
`g : Λ → Λ'` a map of the machine states. -/
def cfg.map (f : pointed_map Γ Γ') (g : Λ → Λ') : cfg Γ Λ → cfg Γ' Λ'
| ⟨q, T⟩ => ⟨g q, T.map f⟩

variable(M : machine Γ Λ)(f₁ : pointed_map Γ Γ')(f₂ : pointed_map Γ' Γ)(g₁ : Λ → Λ')(g₂ : Λ' → Λ)

/-- Because the state transition function uses the alphabet and machine states in both the input
and output, to map a machine from one alphabet and machine state space to another we need functions
in both directions, essentially an `equiv` without the laws. -/
def machine.map : machine Γ' Λ'
| q, l => (M (g₂ q) (f₂ l)).map (Prod.mapₓ g₁ (stmt.map f₁))

theorem machine.map_step {S : Set Λ} (f₂₁ : Function.RightInverse f₁ f₂) (g₂₁ : ∀ q (_ : q ∈ S), g₂ (g₁ q) = q) :
  ∀ (c : cfg Γ Λ), c.q ∈ S → (step M c).map (cfg.map f₁ g₁) = step (M.map f₁ f₂ g₁ g₂) (cfg.map f₁ g₁ c)
| ⟨q, T⟩, h =>
  by 
    unfold step machine.map cfg.map 
    simp only [Turing.Tape.map_fst, g₂₁ q h, f₂₁ _]
    rcases M q T.1 with (_ | ⟨q', d | a⟩)
    ·
      rfl
    ·
      simp only [step, cfg.map, Option.map_some', tape.map_move f₁]
      rfl
    ·
      simp only [step, cfg.map, Option.map_some', tape.map_write]
      rfl

theorem map_init (g₁ : pointed_map Λ Λ') (l : List Γ) : (init l).map f₁ g₁ = init (l.map f₁) :=
  congr (congr_argₓ cfg.mk g₁.map_pt) (tape.map_mk₁ _ _)

theorem machine.map_respects (g₁ : pointed_map Λ Λ') (g₂ : Λ' → Λ) {S} (ss : supports M S)
  (f₂₁ : Function.RightInverse f₁ f₂) (g₂₁ : ∀ q (_ : q ∈ S), g₂ (g₁ q) = q) :
  respects (step M) (step (M.map f₁ f₂ g₁ g₂)) fun a b => a.q ∈ S ∧ cfg.map f₁ g₁ a = b
| c, _, ⟨cs, rfl⟩ =>
  by 
    cases' e : step M c with c' <;> unfold respects
    ·
      rw [←M.map_step f₁ f₂ g₁ g₂ f₂₁ g₂₁ _ cs, e]
      rfl
    ·
      refine' ⟨_, ⟨step_supports M ss e cs, rfl⟩, trans_gen.single _⟩
      rw [←M.map_step f₁ f₂ g₁ g₂ f₂₁ g₂₁ _ cs, e]
      exact rfl

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

parameter (Λ : Type _)

parameter (σ : Type _)

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
inductive stmt
  | move : dir → stmt → stmt
  | write : (Γ → σ → Γ) → stmt → stmt
  | load : (Γ → σ → σ) → stmt → stmt
  | branch : (Γ → σ → Bool) → stmt → stmt → stmt
  | goto : (Γ → σ → Λ) → stmt
  | halt : stmt

open Stmt

instance stmt.inhabited : Inhabited stmt :=
  ⟨halt⟩

/-- The configuration of a TM1 machine is given by the currently
  evaluating statement, the variable store value, and the tape. -/
structure cfg where 
  l : Option Λ 
  var : σ 
  Tape : tape Γ

instance cfg.inhabited [Inhabited σ] : Inhabited cfg :=
  ⟨⟨default _, default _, default _⟩⟩

parameter {Γ Λ σ}

/-- The semantics of TM1 evaluation. -/
def step_aux : stmt → σ → tape Γ → cfg
| move d q, v, T => step_aux q v (T.move d)
| write a q, v, T => step_aux q v (T.write (a T.1 v))
| load s q, v, T => step_aux q (s T.1 v) T
| branch p q₁ q₂, v, T => cond (p T.1 v) (step_aux q₁ v T) (step_aux q₂ v T)
| goto l, v, T => ⟨some (l T.1 v), v, T⟩
| halt, v, T => ⟨none, v, T⟩

/-- The state transition function. -/
def step (M : Λ → stmt) : cfg → Option cfg
| ⟨none, v, T⟩ => none
| ⟨some l, v, T⟩ => some (step_aux (M l) v T)

/-- A set `S` of labels supports the statement `q` if all the `goto`
  statements in `q` refer only to other functions in `S`. -/
def supports_stmt (S : Finset Λ) : stmt → Prop
| move d q => supports_stmt q
| write a q => supports_stmt q
| load s q => supports_stmt q
| branch p q₁ q₂ => supports_stmt q₁ ∧ supports_stmt q₂
| goto l => ∀ a v, l a v ∈ S
| halt => True

open_locale Classical

/-- The subterm closure of a statement. -/
noncomputable def stmts₁ : stmt → Finset stmt
| Q@(move d q) => insert Q (stmts₁ q)
| Q@(write a q) => insert Q (stmts₁ q)
| Q@(load s q) => insert Q (stmts₁ q)
| Q@(branch p q₁ q₂) => insert Q (stmts₁ q₁ ∪ stmts₁ q₂)
| Q => {Q}

theorem stmts₁_self {q} : q ∈ stmts₁ q :=
  by 
    cases q <;> applyRules [Finset.mem_insert_self, Finset.mem_singleton_self]

theorem stmts₁_trans {q₁ q₂} : q₁ ∈ stmts₁ q₂ → stmts₁ q₁ ⊆ stmts₁ q₂ :=
  by 
    intro h₁₂ q₀ h₀₁ 
    induction' q₂ with _ q IH _ q IH _ q IH <;>
      simp only [stmts₁] at h₁₂⊢ <;> simp only [Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at h₁₂ 
    iterate 3
      rcases h₁₂ with (rfl | h₁₂)
      ·
        unfold stmts₁  at h₀₁ 
        exact h₀₁
      ·
        exact Finset.mem_insert_of_mem (IH h₁₂)
    case TM1.stmt.branch p q₁ q₂ IH₁ IH₂ => 
      rcases h₁₂ with (rfl | h₁₂ | h₁₂)
      ·
        unfold stmts₁  at h₀₁ 
        exact h₀₁
      ·
        exact Finset.mem_insert_of_mem (Finset.mem_union_left _$ IH₁ h₁₂)
      ·
        exact Finset.mem_insert_of_mem (Finset.mem_union_right _$ IH₂ h₁₂)
    case TM1.stmt.goto l => 
      subst h₁₂ 
      exact h₀₁ 
    case TM1.stmt.halt => 
      subst h₁₂ 
      exact h₀₁

theorem stmts₁_supports_stmt_mono {S q₁ q₂} (h : q₁ ∈ stmts₁ q₂) (hs : supports_stmt S q₂) : supports_stmt S q₁ :=
  by 
    induction' q₂ with _ q IH _ q IH _ q IH <;>
      simp only [stmts₁, supports_stmt, Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at h hs 
    iterate 3
      rcases h with (rfl | h) <;> [exact hs, exact IH h hs]
    case TM1.stmt.branch p q₁ q₂ IH₁ IH₂ => 
      rcases h with (rfl | h | h)
      exacts[hs, IH₁ h hs.1, IH₂ h hs.2]
    case TM1.stmt.goto l => 
      subst h 
      exact hs 
    case TM1.stmt.halt => 
      subst h 
      trivial

/-- The set of all statements in a turing machine, plus one extra value `none` representing the
halt state. This is used in the TM1 to TM0 reduction. -/
noncomputable def stmts (M : Λ → stmt) (S : Finset Λ) : Finset (Option stmt) :=
  (S.bUnion fun q => stmts₁ (M q)).insertNone

theorem stmts_trans {M : Λ → stmt} {S q₁ q₂} (h₁ : q₁ ∈ stmts₁ q₂) : some q₂ ∈ stmts M S → some q₁ ∈ stmts M S :=
  by 
    simp only [stmts, Finset.mem_insert_none, Finset.mem_bUnion, Option.mem_def, forall_eq', exists_imp_distrib] <;>
      exact fun l ls h₂ => ⟨_, ls, stmts₁_trans h₂ h₁⟩

variable[Inhabited Λ]

/-- A set `S` of labels supports machine `M` if all the `goto`
  statements in the functions in `S` refer only to other functions
  in `S`. -/
def supports (M : Λ → stmt) (S : Finset Λ) :=
  default Λ ∈ S ∧ ∀ q (_ : q ∈ S), supports_stmt S (M q)

theorem stmts_supports_stmt {M : Λ → stmt} {S q} (ss : supports M S) : some q ∈ stmts M S → supports_stmt S q :=
  by 
    simp only [stmts, Finset.mem_insert_none, Finset.mem_bUnion, Option.mem_def, forall_eq', exists_imp_distrib] <;>
      exact fun l ls h => stmts₁_supports_stmt_mono h (ss.2 _ ls)

theorem step_supports (M : Λ → stmt) {S} (ss : supports M S) :
  ∀ {c c' : cfg}, c' ∈ step M c → c.l ∈ S.insert_none → c'.l ∈ S.insert_none
| ⟨some l₁, v, T⟩, c', h₁, h₂ =>
  by 
    replace h₂ := ss.2 _ (Finset.some_mem_insert_none.1 h₂)
    simp only [step, Option.mem_def] at h₁ 
    subst c' 
    revert h₂ 
    induction' M l₁ with _ q IH _ q IH _ q IH generalizing v T <;> intro hs 
    iterate 3 
      exact IH _ _ hs 
    case TM1.stmt.branch p q₁' q₂' IH₁ IH₂ => 
      unfold step_aux 
      cases p T.1 v
      ·
        exact IH₂ _ _ hs.2
      ·
        exact IH₁ _ _ hs.1
    case TM1.stmt.goto => 
      exact Finset.some_mem_insert_none.2 (hs _ _)
    case TM1.stmt.halt => 
      apply Multiset.mem_cons_self

variable[Inhabited σ]

/-- The initial state, given a finite input that is placed on the tape starting at the TM head and
going to the right. -/
def init (l : List Γ) : cfg :=
  ⟨some (default _), default _, tape.mk₁ l⟩

/-- Evaluate a TM to completion, resulting in an output list on the tape (with an indeterminate
number of blanks on the end). -/
def eval (M : Λ → stmt) (l : List Γ) : Part (list_blank Γ) :=
  (eval (step M) (init l)).map fun c => c.tape.right₀

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

local notation "stmt₁" => TM1.stmt Γ Λ σ

local notation "cfg₁" => TM1.cfg Γ Λ σ

local notation "stmt₀" => TM0.stmt Γ

parameter (M : Λ → stmt₁)

include M

/-- The base machine state space is a pair of an `option stmt₁` representing the current program
to be executed, or `none` for the halt state, and a `σ` which is the local state (stored in the TM,
not the tape). Because there are an infinite number of programs, this state space is infinite, but
for a finitely supported TM1 machine and a finite type `σ`, only finitely many of these states are
reachable. -/
@[nolint unused_arguments]
def Λ' :=
  Option stmt₁ × σ

instance  : Inhabited Λ' :=
  ⟨(some (M (default _)), default _)⟩

open TM0.Stmt

/-- The core TM1 → TM0 translation function. Here `s` is the current value on the tape, and the
`stmt₁` is the TM1 statement to translate, with local state `v : σ`. We evaluate all regular
instructions recursively until we reach either a `move` or `write` command, or a `goto`; in the
latter case we emit a dummy `write s` step and transition to the new target location. -/
def tr_aux (s : Γ) : stmt₁ → σ → Λ' × stmt₀
| TM1.stmt.move d q, v => ((some q, v), move d)
| TM1.stmt.write a q, v => ((some q, v), write (a s v))
| TM1.stmt.load a q, v => tr_aux q (a s v)
| TM1.stmt.branch p q₁ q₂, v => cond (p s v) (tr_aux q₁ v) (tr_aux q₂ v)
| TM1.stmt.goto l, v => ((some (M (l s v)), v), write s)
| TM1.stmt.halt, v => ((none, v), write s)

local notation "cfg₀" => TM0.cfg Γ Λ'

/-- The translated TM0 machine (given the TM1 machine input). -/
def tr : TM0.machine Γ Λ'
| (none, v), s => none
| (some q, v), s => some (tr_aux s q v)

/-- Translate configurations from TM1 to TM0. -/
def tr_cfg : cfg₁ → cfg₀
| ⟨l, v, T⟩ => ⟨(l.map M, v), T⟩

theorem tr_respects : respects (TM1.step M) (TM0.step tr) fun c₁ c₂ => tr_cfg c₁ = c₂ :=
  fun_respects.2$
    fun ⟨l₁, v, T⟩ =>
      by 
        cases' l₁ with l₁
        ·
          exact rfl 
        unfold tr_cfg TM1.step frespects Option.map Function.comp Option.bind 
        induction' M l₁ with _ q IH _ q IH _ q IH generalizing v T 
        case TM1.stmt.move d q IH => 
          exact trans_gen.head rfl (IH _ _)
        case TM1.stmt.write a q IH => 
          exact trans_gen.head rfl (IH _ _)
        case TM1.stmt.load a q IH => 
          exact
            (reaches₁_eq
                  (by 
                    rfl)).2
              (IH _ _)
        case TM1.stmt.branch p q₁ q₂ IH₁ IH₂ => 
          unfold TM1.step_aux 
          cases e : p T.1 v
          ·
            exact
              (reaches₁_eq
                    (by 
                      simp only [TM0.step, tr, tr_aux, e] <;> rfl)).2
                (IH₂ _ _)
          ·
            exact
              (reaches₁_eq
                    (by 
                      simp only [TM0.step, tr, tr_aux, e] <;> rfl)).2
                (IH₁ _ _)
        iterate 2 
          exact trans_gen.single (congr_argₓ some (congr (congr_argₓ TM0.cfg.mk rfl) (tape.write_self T)))

theorem tr_eval (l : List Γ) : TM0.eval tr l = TM1.eval M l :=
  (congr_argₓ _ (tr_eval' _ _ _ tr_respects ⟨some _, _, _⟩)).trans
    (by 
      rw [Part.map_eq_map, Part.map_map, TM1.eval]
      congr with ⟨⟩
      rfl)

variable[Fintype σ]

/-- Given a finite set of accessible `Λ` machine states, there is a finite set of accessible
machine states in the target (even though the type `Λ'` is infinite). -/
noncomputable def tr_stmts (S : Finset Λ) : Finset Λ' :=
  (TM1.stmts M S).product Finset.univ

open_locale Classical

attribute [local simp] TM1.stmts₁_self

-- error in Computability.TuringMachine: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tr_supports {S : finset Λ} (ss : TM1.supports M S) : TM0.supports tr «expr↑ »(tr_stmts S) :=
⟨finset.mem_product.2 ⟨finset.some_mem_insert_none.2 (finset.mem_bUnion.2 ⟨_, ss.1, TM1.stmts₁_self⟩), finset.mem_univ _⟩, λ
 q a q' s h₁ h₂, begin
   rcases [expr q, "with", "⟨", "_", "|", ident q, ",", ident v, "⟩"],
   { cases [expr h₁] [] },
   cases [expr q'] ["with", ident q', ident v'],
   simp [] [] ["only"] ["[", expr tr_stmts, ",", expr finset.mem_coe, ",", expr finset.mem_product, ",", expr finset.mem_univ, ",", expr and_true, "]"] [] ["at", ident h₂, "⊢"],
   cases [expr q'] [],
   { exact [expr multiset.mem_cons_self _ _] },
   simp [] [] ["only"] ["[", expr tr, ",", expr option.mem_def, "]"] [] ["at", ident h₁],
   have [] [] [":=", expr TM1.stmts_supports_stmt ss h₂],
   revert [ident this],
   induction [expr q] [] [] ["generalizing", ident v]; intro [ident hs],
   case [ident TM1.stmt.move, ":", ident d, ident q] { cases [expr h₁] [],
     refine [expr TM1.stmts_trans _ h₂],
     unfold [ident TM1.stmts₁] [],
     exact [expr finset.mem_insert_of_mem TM1.stmts₁_self] },
   case [ident TM1.stmt.write, ":", ident b, ident q] { cases [expr h₁] [],
     refine [expr TM1.stmts_trans _ h₂],
     unfold [ident TM1.stmts₁] [],
     exact [expr finset.mem_insert_of_mem TM1.stmts₁_self] },
   case [ident TM1.stmt.load, ":", ident b, ident q, ident IH] { refine [expr IH (TM1.stmts_trans _ h₂) _ h₁ hs],
     unfold [ident TM1.stmts₁] [],
     exact [expr finset.mem_insert_of_mem TM1.stmts₁_self] },
   case [ident TM1.stmt.branch, ":", ident p, ident q₁, ident q₂, ident IH₁, ident IH₂] { change [expr «expr = »(cond (p a v) _ _, ((some q', v'), s))] [] ["at", ident h₁],
     cases [expr p a v] [],
     { refine [expr IH₂ (TM1.stmts_trans _ h₂) _ h₁ hs.2],
       unfold [ident TM1.stmts₁] [],
       exact [expr finset.mem_insert_of_mem (finset.mem_union_right _ TM1.stmts₁_self)] },
     { refine [expr IH₁ (TM1.stmts_trans _ h₂) _ h₁ hs.1],
       unfold [ident TM1.stmts₁] [],
       exact [expr finset.mem_insert_of_mem (finset.mem_union_left _ TM1.stmts₁_self)] } },
   case [ident TM1.stmt.goto, ":", ident l] { cases [expr h₁] [],
     exact [expr finset.some_mem_insert_none.2 (finset.mem_bUnion.2 ⟨_, hs _ _, TM1.stmts₁_self⟩)] },
   case [ident TM1.stmt.halt] { cases [expr h₁] [] }
 end⟩

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

-- error in Computability.TuringMachine: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem exists_enc_dec
[fintype Γ] : «expr∃ , »((n)
 (enc : Γ → vector bool n)
 (dec : vector bool n → Γ), «expr ∧ »(«expr = »(enc (default _), vector.repeat ff n), ∀
  a, «expr = »(dec (enc a), a))) :=
begin
  letI [] [] [":=", expr classical.dec_eq Γ],
  let [ident n] [] [":=", expr fintype.card Γ],
  obtain ["⟨", ident F, "⟩", ":=", expr fintype.trunc_equiv_fin Γ],
  let [ident G] [":", expr «expr ↪ »(fin n, fin n → bool)] [":=", expr ⟨λ
    a b, «expr = »(a, b), λ a b h, «expr $ »(of_to_bool_true, «expr $ »((congr_fun h b).trans, to_bool_tt rfl))⟩],
  let [ident H] [] [":=", expr (F.to_embedding.trans G).trans (equiv.vector_equiv_fin _ _).symm.to_embedding],
  classical,
  let [ident enc] [] [":=", expr H.set_value (default _) (vector.repeat ff n)],
  exact [expr ⟨_, enc, function.inv_fun enc, H.set_value_eq _ _, function.left_inverse_inv_fun enc.2⟩]
end

parameter {Λ : Type _}[Inhabited Λ]

parameter {σ : Type _}[Inhabited σ]

local notation "stmt₁" => stmt Γ Λ σ

local notation "cfg₁" => cfg Γ Λ σ

/-- The configuration state of the TM. -/
inductive Λ' : Type max u_1 u_2 u_3
  | normal : Λ → Λ'
  | write : Γ → stmt₁ → Λ'

instance  : Inhabited Λ' :=
  ⟨Λ'.normal (default _)⟩

local notation "stmt'" => stmt Bool Λ' σ

local notation "cfg'" => cfg Bool Λ' σ

/-- Read a vector of length `n` from the tape. -/
def read_aux : ∀ n, (Vector Bool n → stmt') → stmt'
| 0, f => f Vector.nil
| i+1, f =>
  stmt.branch (fun a s => a) (stmt.move dir.right$ read_aux i fun v => f (tt::ᵥv))
    (stmt.move dir.right$ read_aux i fun v => f (ff::ᵥv))

parameter {n : ℕ}(enc : Γ → Vector Bool n)(dec : Vector Bool n → Γ)

/-- A move left or right corresponds to `n` moves across the super-cell. -/
def move (d : dir) (q : stmt') : stmt' :=
  (stmt.move d^[n]) q

/-- To read a symbol from the tape, we use `read_aux` to traverse the symbol,
then return to the original position with `n` moves to the left. -/
def read (f : Γ → stmt') : stmt' :=
  read_aux n fun v => move dir.left$ f (dec v)

/-- Write a list of bools on the tape. -/
def write : List Bool → stmt' → stmt'
| [], q => q
| a :: l, q => (stmt.write fun _ _ => a)$ stmt.move dir.right$ write l q

/-- Translate a normal instruction. For the `write` command, we use a `goto` indirection so that
we can access the current value of the tape. -/
def tr_normal : stmt₁ → stmt'
| stmt.move d q => move d$ tr_normal q
| stmt.write f q => read$ fun a => stmt.goto$ fun _ s => Λ'.write (f a s) q
| stmt.load f q => read$ fun a => (stmt.load fun _ s => f a s)$ tr_normal q
| stmt.branch p q₁ q₂ => read$ fun a => stmt.branch (fun _ s => p a s) (tr_normal q₁) (tr_normal q₂)
| stmt.goto l => read$ fun a => stmt.goto$ fun _ s => Λ'.normal (l a s)
| stmt.halt => stmt.halt

theorem step_aux_move d q v T : step_aux (move d q) v T = step_aux q v ((tape.move d^[n]) T) :=
  by 
    suffices  : ∀ i, step_aux ((stmt.move d^[i]) q) v T = step_aux q v ((tape.move d^[i]) T)
    exact this n 
    intro 
    induction' i with i IH generalizing T
    ·
      rfl 
    rw [iterate_succ', step_aux, IH, iterate_succ]

theorem supports_stmt_move {S d q} : supports_stmt S (move d q) = supports_stmt S q :=
  suffices ∀ {i}, supports_stmt S ((stmt.move d^[i]) q) = _ from this 
  by 
    intro  <;> induction i generalizing q <;> simp only [iterate] <;> rfl

theorem supports_stmt_write {S l q} : supports_stmt S (write l q) = supports_stmt S q :=
  by 
    induction' l with a l IH <;> simp only [write, supports_stmt]

theorem supports_stmt_read {S} : ∀ {f : Γ → stmt'}, (∀ a, supports_stmt S (f a)) → supports_stmt S (read f) :=
  suffices ∀ i (f : Vector Bool i → stmt'), (∀ v, supports_stmt S (f v)) → supports_stmt S (read_aux i f) from
    fun f hf =>
      this n _
        (by 
          intro  <;> simp only [supports_stmt_move, hf])
  fun i f hf =>
    by 
      induction' i with i IH
      ·
        exact hf _ 
      split  <;> apply IH <;> intro  <;> apply hf

parameter (enc0 : enc (default _) = Vector.repeat ff n)

section 

parameter {enc}

include enc0

/-- The low level tape corresponding to the given tape over alphabet `Γ`. -/
def tr_tape' (L R : list_blank Γ) : tape Bool :=
  by 
    refine' tape.mk' (L.bind (fun x => (enc x).toList.reverse) ⟨n, _⟩) (R.bind (fun x => (enc x).toList) ⟨n, _⟩) <;>
      simp only [enc0, Vector.repeat, List.reverse_repeat, Bool.default_bool, Vector.to_list_mk]

/-- The low level tape corresponding to the given tape over alphabet `Γ`. -/
def tr_tape (T : tape Γ) : tape Bool :=
  tr_tape' T.left T.right₀

theorem tr_tape_mk' (L R : list_blank Γ) : tr_tape (tape.mk' L R) = tr_tape' L R :=
  by 
    simp only [tr_tape, tape.mk'_left, tape.mk'_right₀]

end 

parameter (M : Λ → stmt₁)

/-- The top level program. -/
def tr : Λ' → stmt'
| Λ'.normal l => tr_normal (M l)
| Λ'.write a q => write (enc a).toList$ move dir.left$ tr_normal q

/-- The machine configuration translation. -/
def tr_cfg : cfg₁ → cfg'
| ⟨l, v, T⟩ => ⟨l.map Λ'.normal, v, tr_tape T⟩

parameter {enc}

include enc0

theorem tr_tape'_move_left L R : (tape.move dir.left^[n]) (tr_tape' L R) = tr_tape' L.tail (R.cons L.head) :=
  by 
    obtain ⟨a, L, rfl⟩ := L.exists_cons 
    simp only [tr_tape', list_blank.cons_bind, list_blank.head_cons, list_blank.tail_cons]
    suffices  :
      ∀ {L' R' l₁ l₂} (e : Vector.toList (enc a) = List.reverseCore l₁ l₂),
        (tape.move dir.left^[l₁.length]) (tape.mk' (list_blank.append l₁ L') (list_blank.append l₂ R')) =
          tape.mk' L' (list_blank.append (Vector.toList (enc a)) R')
    ·
      simpa only [List.length_reverse, Vector.to_list_length] using this (List.reverse_reverse _).symm 
    intros 
    induction' l₁ with b l₁ IH generalizing l₂
    ·
      cases e 
      rfl 
    simp only [List.length, List.cons_append, iterate_succ_apply]
    convert IH e 
    simp only [list_blank.tail_cons, list_blank.append, tape.move_left_mk', list_blank.head_cons]

theorem tr_tape'_move_right L R : (tape.move dir.right^[n]) (tr_tape' L R) = tr_tape' (L.cons R.head) R.tail :=
  by 
    suffices  : ∀ i L, (tape.move dir.right^[i]) ((tape.move dir.left^[i]) L) = L
    ·
      refine' (Eq.symm _).trans (this n _)
      simp only [tr_tape'_move_left, list_blank.cons_head_tail, list_blank.head_cons, list_blank.tail_cons]
    intros 
    induction' i with i IH
    ·
      rfl 
    rw [iterate_succ_apply, iterate_succ_apply', tape.move_left_right, IH]

theorem step_aux_write q v a b L R :
  step_aux (write (enc a).toList q) v (tr_tape' L (list_blank.cons b R)) =
    step_aux q v (tr_tape' (list_blank.cons a L) R) :=
  by 
    simp only [tr_tape', List.cons_bind, List.append_assoc]
    suffices  :
      ∀ {L' R'} (l₁ l₂ l₂' : List Bool) (e : l₂'.length = l₂.length),
        step_aux (write l₂ q) v (tape.mk' (list_blank.append l₁ L') (list_blank.append l₂' R')) =
          step_aux q v (tape.mk' (L'.append (List.reverseCore l₂ l₁)) R')
    ·
      convert this [] _ _ ((enc b).2.trans (enc a).2.symm) <;> rw [list_blank.cons_bind] <;> rfl 
    clear a b L R 
    intros 
    induction' l₂ with a l₂ IH generalizing l₁ l₂'
    ·
      cases List.length_eq_zero.1 e 
      rfl 
    cases' l₂' with b l₂' <;> injection e with e 
    dunfold write step_aux 
    convert IH _ _ e using 1
    simp only [list_blank.head_cons, list_blank.tail_cons, list_blank.append, tape.move_right_mk', tape.write_mk']

parameter (encdec : ∀ a, dec (enc a) = a)

include encdec

theorem step_aux_read f v L R : step_aux (read f) v (tr_tape' L R) = step_aux (f R.head) v (tr_tape' L R) :=
  by 
    suffices  :
      ∀ f,
        step_aux (read_aux n f) v (tr_tape' enc0 L R) =
          step_aux (f (enc R.head)) v (tr_tape' enc0 (L.cons R.head) R.tail)
    ·
      rw [read, this, step_aux_move, encdec, tr_tape'_move_left enc0]
      simp only [list_blank.head_cons, list_blank.cons_head_tail, list_blank.tail_cons]
    obtain ⟨a, R, rfl⟩ := R.exists_cons 
    simp only [list_blank.head_cons, list_blank.tail_cons, tr_tape', list_blank.cons_bind, list_blank.append_assoc]
    suffices  :
      ∀ i f L' R' l₁ l₂ h,
        step_aux (read_aux i f) v (tape.mk' (list_blank.append l₁ L') (list_blank.append l₂ R')) =
          step_aux (f ⟨l₂, h⟩) v (tape.mk' (list_blank.append (l₂.reverse_core l₁) L') R')
    ·
      intro f 
      convert this n f _ _ _ _ (enc a).2 <;> simp 
    clear f L a R 
    intros 
    subst i 
    induction' l₂ with a l₂ IH generalizing l₁
    ·
      rfl 
    trans step_aux (read_aux l₂.length fun v => f (a::ᵥv)) v (tape.mk' ((L'.append l₁).cons a) (R'.append l₂))
    ·
      dsimp [read_aux, step_aux]
      simp 
      cases a <;> rfl 
    rw [←list_blank.append, IH]
    rfl

theorem tr_respects : respects (step M) (step tr) fun c₁ c₂ => tr_cfg c₁ = c₂ :=
  fun_respects.2$
    fun ⟨l₁, v, T⟩ =>
      by 
        obtain ⟨L, R, rfl⟩ := T.exists_mk' 
        cases' l₁ with l₁
        ·
          exact rfl 
        suffices  :
          ∀ q R,
            reaches (step (tr enc dec M)) (step_aux (tr_normal dec q) v (tr_tape' enc0 L R))
              (tr_cfg enc0 (step_aux q v (tape.mk' L R)))
        ·
          refine' trans_gen.head' rfl _ 
          rw [tr_tape_mk']
          exact this _ R 
        clear R l₁ 
        intros 
        induction' q with _ q IH _ q IH _ q IH generalizing v L R 
        case TM1.stmt.move d q IH => 
          cases d <;>
            simp only [tr_normal, iterate, step_aux_move, step_aux, list_blank.head_cons, tape.move_left_mk',
                list_blank.cons_head_tail, list_blank.tail_cons, tr_tape'_move_left enc0, tr_tape'_move_right enc0] <;>
              apply IH 
        case TM1.stmt.write f q IH => 
          simp only [tr_normal, step_aux_read dec enc0 encdec, step_aux]
          refine' refl_trans_gen.head rfl _ 
          obtain ⟨a, R, rfl⟩ := R.exists_cons 
          rw [tr, tape.mk'_head, step_aux_write, list_blank.head_cons, step_aux_move, tr_tape'_move_left enc0,
            list_blank.head_cons, list_blank.tail_cons, tape.write_mk']
          apply IH 
        case TM1.stmt.load a q IH => 
          simp only [tr_normal, step_aux_read dec enc0 encdec]
          apply IH 
        case TM1.stmt.branch p q₁ q₂ IH₁ IH₂ => 
          simp only [tr_normal, step_aux_read dec enc0 encdec, step_aux]
          cases p R.head v <;> [apply IH₂, apply IH₁]
        case TM1.stmt.goto l => 
          simp only [tr_normal, step_aux_read dec enc0 encdec, step_aux, tr_cfg, tr_tape_mk']
          apply refl_trans_gen.refl 
        case TM1.stmt.halt => 
          simp only [tr_normal, step_aux, tr_cfg, step_aux_move, tr_tape'_move_left enc0, tr_tape'_move_right enc0,
            tr_tape_mk']
          apply refl_trans_gen.refl

omit enc0 encdec

open_locale Classical

parameter [Fintype Γ]

/-- The set of accessible `Λ'.write` machine states. -/
noncomputable def writes : stmt₁ → Finset Λ'
| stmt.move d q => writes q
| stmt.write f q => (Finset.univ.Image fun a => Λ'.write a q) ∪ writes q
| stmt.load f q => writes q
| stmt.branch p q₁ q₂ => writes q₁ ∪ writes q₂
| stmt.goto l => ∅
| stmt.halt => ∅

/-- The set of accessible machine states, assuming that the input machine is supported on `S`,
are the normal states embedded from `S`, plus all write states accessible from these states. -/
noncomputable def tr_supp (S : Finset Λ) : Finset Λ' :=
  S.bUnion fun l => insert (Λ'.normal l) (writes (M l))

-- error in Computability.TuringMachine: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tr_supports {S} (ss : supports M S) : supports tr (tr_supp S) :=
⟨finset.mem_bUnion.2 ⟨_, ss.1, finset.mem_insert_self _ _⟩, λ q h, begin
   suffices [] [":", expr ∀
    q, supports_stmt S q → ∀
    q' «expr ∈ » writes q, «expr ∈ »(q', tr_supp M S) → «expr ∧ »(supports_stmt (tr_supp M S) (tr_normal dec q), ∀
     q' «expr ∈ » writes q, supports_stmt (tr_supp M S) (tr enc dec M q'))],
   { rcases [expr finset.mem_bUnion.1 h, "with", "⟨", ident l, ",", ident hl, ",", ident h, "⟩"],
     have [] [] [":=", expr this _ (ss.2 _ hl) (λ q' hq, finset.mem_bUnion.2 ⟨_, hl, finset.mem_insert_of_mem hq⟩)],
     rcases [expr finset.mem_insert.1 h, "with", ident rfl, "|", ident h],
     exacts ["[", expr this.1, ",", expr this.2 _ h, "]"] },
   intros [ident q, ident hs, ident hw],
   induction [expr q] [] [] [],
   case [ident TM1.stmt.move, ":", ident d, ident q, ident IH] { unfold [ident writes] ["at", ident hw, "⊢"],
     replace [ident IH] [] [":=", expr IH hs hw],
     refine [expr ⟨_, IH.2⟩],
     cases [expr d] []; simp [] [] ["only"] ["[", expr tr_normal, ",", expr iterate, ",", expr supports_stmt_move, ",", expr IH, "]"] [] [] },
   case [ident TM1.stmt.write, ":", ident f, ident q, ident IH] { unfold [ident writes] ["at", ident hw, "⊢"],
     simp [] [] ["only"] ["[", expr finset.mem_image, ",", expr finset.mem_union, ",", expr finset.mem_univ, ",", expr exists_prop, ",", expr true_and, "]"] [] ["at", ident hw, "⊢"],
     replace [ident IH] [] [":=", expr IH hs (λ q hq, hw q (or.inr hq))],
     refine [expr ⟨«expr $ »(supports_stmt_read _, λ a _ s, hw _ (or.inl ⟨_, rfl⟩)), λ q' hq, _⟩],
     rcases [expr hq, "with", "⟨", ident a, ",", ident q₂, ",", ident rfl, "⟩", "|", ident hq],
     { simp [] [] ["only"] ["[", expr tr, ",", expr supports_stmt_write, ",", expr supports_stmt_move, ",", expr IH.1, "]"] [] [] },
     { exact [expr IH.2 _ hq] } },
   case [ident TM1.stmt.load, ":", ident a, ident q, ident IH] { unfold [ident writes] ["at", ident hw, "⊢"],
     replace [ident IH] [] [":=", expr IH hs hw],
     refine [expr ⟨supports_stmt_read _ (λ a, IH.1), IH.2⟩] },
   case [ident TM1.stmt.branch, ":", ident p, ident q₁, ident q₂, ident IH₁, ident IH₂] { unfold [ident writes] ["at", ident hw, "⊢"],
     simp [] [] ["only"] ["[", expr finset.mem_union, "]"] [] ["at", ident hw, "⊢"],
     replace [ident IH₁] [] [":=", expr IH₁ hs.1 (λ q hq, hw q (or.inl hq))],
     replace [ident IH₂] [] [":=", expr IH₂ hs.2 (λ q hq, hw q (or.inr hq))],
     exact [expr ⟨supports_stmt_read _ (λ a, ⟨IH₁.1, IH₂.1⟩), λ q, or.rec (IH₁.2 _) (IH₂.2 _)⟩] },
   case [ident TM1.stmt.goto, ":", ident l] { refine [expr ⟨_, λ _, false.elim⟩],
     refine [expr supports_stmt_read _ (λ a _ s, _)],
     exact [expr finset.mem_bUnion.2 ⟨_, hs _ _, finset.mem_insert_self _ _⟩] },
   case [ident TM1.stmt.halt] { refine [expr ⟨_, λ _, false.elim⟩],
     simp [] [] ["only"] ["[", expr supports_stmt, ",", expr supports_stmt_move, ",", expr tr_normal, "]"] [] [] }
 end⟩

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

/-- The machine states for a TM1 emulating a TM0 machine. States of the TM0 machine are embedded
as `normal q` states, but the actual operation is split into two parts, a jump to `act s q`
followed by the action and a jump to the next `normal` state.  -/
inductive Λ'
  | normal : Λ → Λ'
  | act : TM0.stmt Γ → Λ → Λ'

instance  : Inhabited Λ' :=
  ⟨Λ'.normal (default _)⟩

local notation "cfg₀" => TM0.cfg Γ Λ

local notation "stmt₁" => TM1.stmt Γ Λ' Unit

local notation "cfg₁" => TM1.cfg Γ Λ' Unit

parameter (M : TM0.machine Γ Λ)

open TM1.Stmt

/-- The program.  -/
def tr : Λ' → stmt₁
| Λ'.normal q =>
  branch (fun a _ => (M q a).isNone) halt$
    goto
      fun a _ =>
        match M q a with 
        | none => default _
        | some (q', s) => Λ'.act s q'
| Λ'.act (TM0.stmt.move d) q => move d$ goto fun _ _ => Λ'.normal q
| Λ'.act (TM0.stmt.write a) q => (write fun _ _ => a)$ goto fun _ _ => Λ'.normal q

/-- The configuration translation. -/
def tr_cfg : cfg₀ → cfg₁
| ⟨q, T⟩ => ⟨cond (M q T.1).isSome (some (Λ'.normal q)) none, (), T⟩

-- error in Computability.TuringMachine: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tr_respects : respects (TM0.step M) (TM1.step tr) (λ a b, «expr = »(tr_cfg a, b)) :=
«expr $ »(fun_respects.2, λ ⟨q, T⟩, begin
   cases [expr e, ":", expr M q T.1] [],
   { simp [] [] ["only"] ["[", expr TM0.step, ",", expr tr_cfg, ",", expr e, "]"] [] []; exact [expr eq.refl none] },
   cases [expr val] ["with", ident q', ident s],
   simp [] [] ["only"] ["[", expr frespects, ",", expr TM0.step, ",", expr tr_cfg, ",", expr e, ",", expr option.is_some, ",", expr cond, ",", expr option.map_some', "]"] [] [],
   have [] [":", expr «expr = »(TM1.step (tr M) ⟨some (Λ'.act s q'), (), T⟩, some ⟨some (Λ'.normal q'), (), TM0.step._match_1 T s⟩)] [],
   { cases [expr s] ["with", ident d, ident a]; refl },
   refine [expr trans_gen.head _ (trans_gen.head' this _)],
   { unfold [ident TM1.step, ident TM1.step_aux, ident tr, ident has_mem.mem] [],
     rw [expr e] [],
     refl },
   cases [expr e', ":", expr M q' _] [],
   { apply [expr refl_trans_gen.single],
     unfold [ident TM1.step, ident TM1.step_aux, ident tr, ident has_mem.mem] [],
     rw [expr e'] [],
     refl },
   { refl }
 end)

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

parameter (Γ : K → Type _)

parameter (Λ : Type _)

parameter (σ : Type _)

/-- The TM2 model removes the tape entirely from the TM1 model,
  replacing it with an arbitrary (finite) collection of stacks.
  The operation `push` puts an element on one of the stacks,
  and `pop` removes an element from a stack (and modifying the
  internal state based on the result). `peek` modifies the
  internal state but does not remove an element. -/
inductive stmt
  | push : ∀ k, (σ → Γ k) → stmt → stmt
  | peek : ∀ k, (σ → Option (Γ k) → σ) → stmt → stmt
  | pop : ∀ k, (σ → Option (Γ k) → σ) → stmt → stmt
  | load : (σ → σ) → stmt → stmt
  | branch : (σ → Bool) → stmt → stmt → stmt
  | goto : (σ → Λ) → stmt
  | halt : stmt

open Stmt

instance stmt.inhabited : Inhabited stmt :=
  ⟨halt⟩

/-- A configuration in the TM2 model is a label (or `none` for the halt state), the state of
local variables, and the stacks. (Note that the stacks are not `list_blank`s, they have a definite
size.) -/
structure cfg where 
  l : Option Λ 
  var : σ 
  stk : ∀ k, List (Γ k)

instance cfg.inhabited [Inhabited σ] : Inhabited cfg :=
  ⟨⟨default _, default _, default _⟩⟩

parameter {Γ Λ σ K}

/-- The step function for the TM2 model. -/
@[simp]
def step_aux : stmt → σ → (∀ k, List (Γ k)) → cfg
| push k f q, v, S => step_aux q v (update S k (f v :: S k))
| peek k f q, v, S => step_aux q (f v (S k).head') S
| pop k f q, v, S => step_aux q (f v (S k).head') (update S k (S k).tail)
| load a q, v, S => step_aux q (a v) S
| branch f q₁ q₂, v, S => cond (f v) (step_aux q₁ v S) (step_aux q₂ v S)
| goto f, v, S => ⟨some (f v), v, S⟩
| halt, v, S => ⟨none, v, S⟩

/-- The step function for the TM2 model. -/
@[simp]
def step (M : Λ → stmt) : cfg → Option cfg
| ⟨none, v, S⟩ => none
| ⟨some l, v, S⟩ => some (step_aux (M l) v S)

/-- The (reflexive) reachability relation for the TM2 model. -/
def reaches (M : Λ → stmt) : cfg → cfg → Prop :=
  refl_trans_gen fun a b => b ∈ step M a

/-- Given a set `S` of states, `support_stmt S q` means that `q` only jumps to states in `S`. -/
def supports_stmt (S : Finset Λ) : stmt → Prop
| push k f q => supports_stmt q
| peek k f q => supports_stmt q
| pop k f q => supports_stmt q
| load a q => supports_stmt q
| branch f q₁ q₂ => supports_stmt q₁ ∧ supports_stmt q₂
| goto l => ∀ v, l v ∈ S
| halt => True

open_locale Classical

/-- The set of subtree statements in a statement. -/
noncomputable def stmts₁ : stmt → Finset stmt
| Q@(push k f q) => insert Q (stmts₁ q)
| Q@(peek k f q) => insert Q (stmts₁ q)
| Q@(pop k f q) => insert Q (stmts₁ q)
| Q@(load a q) => insert Q (stmts₁ q)
| Q@(branch f q₁ q₂) => insert Q (stmts₁ q₁ ∪ stmts₁ q₂)
| Q@(goto l) => {Q}
| Q@halt => {Q}

theorem stmts₁_self {q} : q ∈ stmts₁ q :=
  by 
    cases q <;> applyRules [Finset.mem_insert_self, Finset.mem_singleton_self]

theorem stmts₁_trans {q₁ q₂} : q₁ ∈ stmts₁ q₂ → stmts₁ q₁ ⊆ stmts₁ q₂ :=
  by 
    intro h₁₂ q₀ h₀₁ 
    induction' q₂ with _ _ q IH _ _ q IH _ _ q IH _ q IH <;>
      simp only [stmts₁] at h₁₂⊢ <;> simp only [Finset.mem_insert, Finset.mem_singleton, Finset.mem_union] at h₁₂ 
    iterate 4
      rcases h₁₂ with (rfl | h₁₂)
      ·
        unfold stmts₁  at h₀₁ 
        exact h₀₁
      ·
        exact Finset.mem_insert_of_mem (IH h₁₂)
    case TM2.stmt.branch f q₁ q₂ IH₁ IH₂ => 
      rcases h₁₂ with (rfl | h₁₂ | h₁₂)
      ·
        unfold stmts₁  at h₀₁ 
        exact h₀₁
      ·
        exact Finset.mem_insert_of_mem (Finset.mem_union_left _ (IH₁ h₁₂))
      ·
        exact Finset.mem_insert_of_mem (Finset.mem_union_right _ (IH₂ h₁₂))
    case TM2.stmt.goto l => 
      subst h₁₂ 
      exact h₀₁ 
    case TM2.stmt.halt => 
      subst h₁₂ 
      exact h₀₁

theorem stmts₁_supports_stmt_mono {S q₁ q₂} (h : q₁ ∈ stmts₁ q₂) (hs : supports_stmt S q₂) : supports_stmt S q₁ :=
  by 
    induction' q₂ with _ _ q IH _ _ q IH _ _ q IH _ q IH <;>
      simp only [stmts₁, supports_stmt, Finset.mem_insert, Finset.mem_union, Finset.mem_singleton] at h hs 
    iterate 4
      rcases h with (rfl | h) <;> [exact hs, exact IH h hs]
    case TM2.stmt.branch f q₁ q₂ IH₁ IH₂ => 
      rcases h with (rfl | h | h)
      exacts[hs, IH₁ h hs.1, IH₂ h hs.2]
    case TM2.stmt.goto l => 
      subst h 
      exact hs 
    case TM2.stmt.halt => 
      subst h 
      trivial

/-- The set of statements accessible from initial set `S` of labels. -/
noncomputable def stmts (M : Λ → stmt) (S : Finset Λ) : Finset (Option stmt) :=
  (S.bUnion fun q => stmts₁ (M q)).insertNone

theorem stmts_trans {M : Λ → stmt} {S q₁ q₂} (h₁ : q₁ ∈ stmts₁ q₂) : some q₂ ∈ stmts M S → some q₁ ∈ stmts M S :=
  by 
    simp only [stmts, Finset.mem_insert_none, Finset.mem_bUnion, Option.mem_def, forall_eq', exists_imp_distrib] <;>
      exact fun l ls h₂ => ⟨_, ls, stmts₁_trans h₂ h₁⟩

variable[Inhabited Λ]

/-- Given a TM2 machine `M` and a set `S` of states, `supports M S` means that all states in
`S` jump only to other states in `S`. -/
def supports (M : Λ → stmt) (S : Finset Λ) :=
  default Λ ∈ S ∧ ∀ q (_ : q ∈ S), supports_stmt S (M q)

theorem stmts_supports_stmt {M : Λ → stmt} {S q} (ss : supports M S) : some q ∈ stmts M S → supports_stmt S q :=
  by 
    simp only [stmts, Finset.mem_insert_none, Finset.mem_bUnion, Option.mem_def, forall_eq', exists_imp_distrib] <;>
      exact fun l ls h => stmts₁_supports_stmt_mono h (ss.2 _ ls)

theorem step_supports (M : Λ → stmt) {S} (ss : supports M S) :
  ∀ {c c' : cfg}, c' ∈ step M c → c.l ∈ S.insert_none → c'.l ∈ S.insert_none
| ⟨some l₁, v, T⟩, c', h₁, h₂ =>
  by 
    replace h₂ := ss.2 _ (Finset.some_mem_insert_none.1 h₂)
    simp only [step, Option.mem_def] at h₁ 
    subst c' 
    revert h₂ 
    induction' M l₁ with _ _ q IH _ _ q IH _ _ q IH _ q IH generalizing v T <;> intro hs 
    iterate 4 
      exact IH _ _ hs 
    case TM2.stmt.branch p q₁' q₂' IH₁ IH₂ => 
      unfold step_aux 
      cases p v
      ·
        exact IH₂ _ _ hs.2
      ·
        exact IH₁ _ _ hs.1
    case TM2.stmt.goto => 
      exact Finset.some_mem_insert_none.2 (hs _)
    case TM2.stmt.halt => 
      apply Multiset.mem_cons_self

variable[Inhabited σ]

/-- The initial state of the TM2 model. The input is provided on a designated stack. -/
def init k (L : List (Γ k)) : cfg :=
  ⟨some (default _), default _, update (fun _ => []) k L⟩

/-- Evaluates a TM2 program to completion, with the output on the same stack as the input. -/
def eval (M : Λ → stmt) k (L : List (Γ k)) : Part (List (Γ k)) :=
  (eval (step M) (init k L)).map$ fun c => c.stk k

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

theorem stk_nth_val {K : Type _} {Γ : K → Type _} {L : list_blank (∀ k, Option (Γ k))} {k S} n
  (hL : list_blank.map (proj k) L = list_blank.mk (List.map some S).reverse) : L.nth n k = S.reverse.nth n :=
  by 
    rw [←proj_map_nth, hL, ←List.map_reverse, list_blank.nth_mk, List.inth, List.nth_map]
    cases S.reverse.nth n <;> rfl

section 

parameter {K : Type _}[DecidableEq K]

parameter {Γ : K → Type _}

parameter {Λ : Type _}[Inhabited Λ]

parameter {σ : Type _}[Inhabited σ]

local notation "stmt₂" => TM2.stmt Γ Λ σ

local notation "cfg₂" => TM2.cfg Γ Λ σ

/-- The alphabet of the TM2 simulator on TM1 is a marker for the stack bottom,
plus a vector of stack elements for each stack, or none if the stack does not extend this far. -/
@[nolint unused_arguments]
def Γ' :=
  Bool × ∀ k, Option (Γ k)

instance Γ'.inhabited : Inhabited Γ' :=
  ⟨⟨ff, fun _ => none⟩⟩

instance Γ'.fintype [Fintype K] [∀ k, Fintype (Γ k)] : Fintype Γ' :=
  Prod.fintype _ _

/-- The bottom marker is fixed throughout the calculation, so we use the `add_bottom` function
to express the program state in terms of a tape with only the stacks themselves. -/
def add_bottom (L : list_blank (∀ k, Option (Γ k))) : list_blank Γ' :=
  list_blank.cons (tt, L.head) (L.tail.map ⟨Prod.mk ff, rfl⟩)

theorem add_bottom_map L : (add_bottom L).map ⟨Prod.snd, rfl⟩ = L :=
  by 
    simp only [add_bottom, list_blank.map_cons] <;> convert list_blank.cons_head_tail _ 
    generalize list_blank.tail L = L' 
    refine' L'.induction_on fun l => _ 
    simp 

theorem add_bottom_modify_nth (f : (∀ k, Option (Γ k)) → ∀ k, Option (Γ k)) L n :
  (add_bottom L).modifyNth (fun a => (a.1, f a.2)) n = add_bottom (L.modify_nth f n) :=
  by 
    cases n <;> simp only [add_bottom, list_blank.head_cons, list_blank.modify_nth, list_blank.tail_cons]
    congr 
    symm 
    apply list_blank.map_modify_nth 
    intro 
    rfl

theorem add_bottom_nth_snd L n : ((add_bottom L).nth n).2 = L.nth n :=
  by 
    conv  => toRHS rw [←add_bottom_map L, list_blank.nth_map] <;> rfl

theorem add_bottom_nth_succ_fst L n : ((add_bottom L).nth (n+1)).1 = ff :=
  by 
    rw [list_blank.nth_succ, add_bottom, list_blank.tail_cons, list_blank.nth_map] <;> rfl

theorem add_bottom_head_fst L : (add_bottom L).head.1 = tt :=
  by 
    rw [add_bottom, list_blank.head_cons] <;> rfl

/-- A stack action is a command that interacts with the top of a stack. Our default position
is at the bottom of all the stacks, so we have to hold on to this action while going to the end
to modify the stack. -/
inductive st_act (k : K)
  | push : (σ → Γ k) → st_act
  | peek : (σ → Option (Γ k) → σ) → st_act
  | pop : (σ → Option (Γ k) → σ) → st_act

instance st_act.inhabited {k} : Inhabited (st_act k) :=
  ⟨st_act.peek fun s _ => s⟩

section 

open StAct

/-- The TM2 statement corresponding to a stack action. -/
@[nolint unused_arguments]
def st_run {k : K} : st_act k → stmt₂ → stmt₂
| push f => TM2.stmt.push k f
| peek f => TM2.stmt.peek k f
| pop f => TM2.stmt.pop k f

/-- The effect of a stack action on the local variables, given the value of the stack. -/
def st_var {k : K} (v : σ) (l : List (Γ k)) : st_act k → σ
| push f => v
| peek f => f v l.head'
| pop f => f v l.head'

/-- The effect of a stack action on the stack. -/
def st_write {k : K} (v : σ) (l : List (Γ k)) : st_act k → List (Γ k)
| push f => f v :: l
| peek f => l
| pop f => l.tail

/-- We have partitioned the TM2 statements into "stack actions", which require going to the end
of the stack, and all other actions, which do not. This is a modified recursor which lumps the
stack actions into one. -/
@[elab_as_eliminator]
def stmt_st_rec.{l} {C : stmt₂ → Sort l} (H₁ : ∀ k (s : st_act k) q (IH : C q), C (st_run s q))
  (H₂ : ∀ a q (IH : C q), C (TM2.stmt.load a q)) (H₃ : ∀ p q₁ q₂ (IH₁ : C q₁) (IH₂ : C q₂), C (TM2.stmt.branch p q₁ q₂))
  (H₄ : ∀ l, C (TM2.stmt.goto l)) (H₅ : C TM2.stmt.halt) : ∀ n, C n
| TM2.stmt.push k f q => H₁ _ (push f) _ (stmt_st_rec q)
| TM2.stmt.peek k f q => H₁ _ (peek f) _ (stmt_st_rec q)
| TM2.stmt.pop k f q => H₁ _ (pop f) _ (stmt_st_rec q)
| TM2.stmt.load a q => H₂ _ _ (stmt_st_rec q)
| TM2.stmt.branch a q₁ q₂ => H₃ _ _ _ (stmt_st_rec q₁) (stmt_st_rec q₂)
| TM2.stmt.goto l => H₄ _
| TM2.stmt.halt => H₅

theorem supports_run (S : Finset Λ) {k} (s : st_act k) q : TM2.supports_stmt S (st_run s q) ↔ TM2.supports_stmt S q :=
  by 
    rcases s with (_ | _ | _) <;> rfl

end 

/-- The machine states of the TM2 emulator. We can either be in a normal state when waiting for the
next TM2 action, or we can be in the "go" and "return" states to go to the top of the stack and
return to the bottom, respectively. -/
inductive Λ' : Type max u_1 u_2 u_3 u_4
  | normal : Λ → Λ'
  | go k : st_act k → stmt₂ → Λ'
  | ret : stmt₂ → Λ'

open Λ'

instance Λ'.inhabited : Inhabited Λ' :=
  ⟨normal (default _)⟩

local notation "stmt₁" => TM1.stmt Γ' Λ' σ

local notation "cfg₁" => TM1.cfg Γ' Λ' σ

open TM1.Stmt

/-- The program corresponding to state transitions at the end of a stack. Here we start out just
after the top of the stack, and should end just after the new top of the stack. -/
def tr_st_act {k} (q : stmt₁) : st_act k → stmt₁
| st_act.push f => (write fun a s => (a.1, update a.2 k$ some$ f s))$ move dir.right q
| st_act.peek f => move dir.left$ (load fun a s => f s (a.2 k))$ move dir.right q
| st_act.pop f =>
  branch (fun a _ => a.1) (load (fun a s => f s none) q)
    (move dir.left$ (load fun a s => f s (a.2 k))$ write (fun a s => (a.1, update a.2 k none)) q)

/-- The initial state for the TM2 emulator, given an initial TM2 state. All stacks start out empty
except for the input stack, and the stack bottom mark is set at the head. -/
def tr_init k (L : List (Γ k)) : List Γ' :=
  let L' : List Γ' := L.reverse.map fun a => (ff, update (fun _ => none) k a)
  (tt, L'.head.2) :: L'.tail

theorem step_run {k : K} q v S :
  ∀ (s : st_act k), TM2.step_aux (st_run s q) v S = TM2.step_aux q (st_var v (S k) s) (update S k (st_write v (S k) s))
| st_act.push f => rfl
| st_act.peek f =>
  by 
    unfold st_write <;> rw [Function.update_eq_self] <;> rfl
| st_act.pop f => rfl

/-- The translation of TM2 statements to TM1 statements. regular actions have direct equivalents,
but stack actions are deferred by going to the corresponding `go` state, so that we can find the
appropriate stack top. -/
def tr_normal : stmt₂ → stmt₁
| TM2.stmt.push k f q => goto fun _ _ => go k (st_act.push f) q
| TM2.stmt.peek k f q => goto fun _ _ => go k (st_act.peek f) q
| TM2.stmt.pop k f q => goto fun _ _ => go k (st_act.pop f) q
| TM2.stmt.load a q => load (fun _ => a) (tr_normal q)
| TM2.stmt.branch f q₁ q₂ => branch (fun a => f) (tr_normal q₁) (tr_normal q₂)
| TM2.stmt.goto l => goto fun a s => normal (l s)
| TM2.stmt.halt => halt

theorem tr_normal_run {k} s q : tr_normal (st_run s q) = goto fun _ _ => go k s q :=
  by 
    rcases s with (_ | _ | _) <;> rfl

open_locale Classical

/-- The set of machine states accessible from an initial TM2 statement. -/
noncomputable def tr_stmts₁ : stmt₂ → Finset Λ'
| TM2.stmt.push k f q => {go k (st_act.push f) q, ret q} ∪ tr_stmts₁ q
| TM2.stmt.peek k f q => {go k (st_act.peek f) q, ret q} ∪ tr_stmts₁ q
| TM2.stmt.pop k f q => {go k (st_act.pop f) q, ret q} ∪ tr_stmts₁ q
| TM2.stmt.load a q => tr_stmts₁ q
| TM2.stmt.branch f q₁ q₂ => tr_stmts₁ q₁ ∪ tr_stmts₁ q₂
| _ => ∅

theorem tr_stmts₁_run {k s q} : tr_stmts₁ (st_run s q) = {go k s q, ret q} ∪ tr_stmts₁ q :=
  by 
    rcases s with (_ | _ | _) <;> unfold tr_stmts₁ st_run

-- error in Computability.TuringMachine: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem tr_respects_aux₂
{k q v}
{S : ∀ k, list (Γ k)}
{L : list_blank (∀ k, option (Γ k))}
(hL : ∀ k, «expr = »(L.map (proj k), list_blank.mk ((S k).map some).reverse))
(o) : let v' := st_var v (S k) o, Sk' := st_write v (S k) o, S' := update S k Sk' in
«expr∃ , »((L' : list_blank (∀
   k, option (Γ k))), «expr ∧ »(∀
  k, «expr = »(L'.map (proj k), list_blank.mk ((S' k).map some).reverse), «expr = »(TM1.step_aux (tr_st_act q o) v («expr ^[ ]»(tape.move dir.right, (S k).length) (tape.mk' «expr∅»() (add_bottom L))), TM1.step_aux q v' («expr ^[ ]»(tape.move dir.right, (S' k).length) (tape.mk' «expr∅»() (add_bottom L')))))) :=
begin
  dsimp ["only"] [] [] [],
  simp [] [] [] [] [] [],
  cases [expr o] []; simp [] [] ["only"] ["[", expr st_write, ",", expr st_var, ",", expr tr_st_act, ",", expr TM1.step_aux, "]"] [] [],
  case [ident TM2to1.st_act.push, ":", ident f] { have [] [] [":=", expr tape.write_move_right_n (λ
      a : Γ', (a.1, update a.2 k (some (f v))))],
    dsimp ["only"] [] [] ["at", ident this],
    refine [expr ⟨_, λ
      k', _, by rw ["[", expr tape.move_right_n_head, ",", expr list.length, ",", expr tape.mk'_nth_nat, ",", expr this, ",", expr add_bottom_modify_nth (λ
        a, update a k (some (f v))), ",", expr nat.add_one, ",", expr iterate_succ', "]"] []⟩],
    refine [expr list_blank.ext (λ i, _)],
    rw ["[", expr list_blank.nth_map, ",", expr list_blank.nth_modify_nth, ",", expr proj, ",", expr pointed_map.mk_val, "]"] [],
    by_cases [expr h', ":", expr «expr = »(k', k)],
    { subst [expr k'],
      split_ifs [] []; simp [] [] ["only"] ["[", expr list.reverse_cons, ",", expr function.update_same, ",", expr list_blank.nth_mk, ",", expr list.inth, ",", expr list.map, "]"] [] [],
      { rw ["[", expr list.nth_le_nth, ",", expr list.nth_le_append_right, "]"] []; simp [] [] ["only"] ["[", expr h, ",", expr list.nth_le_singleton, ",", expr list.length_map, ",", expr list.length_reverse, ",", expr nat.succ_pos', ",", expr list.length_append, ",", expr lt_add_iff_pos_right, ",", expr list.length, "]"] [] [] },
      rw ["[", "<-", expr proj_map_nth, ",", expr hL, ",", expr list_blank.nth_mk, ",", expr list.inth, "]"] [],
      cases [expr lt_or_gt_of_ne h] ["with", ident h, ident h],
      { rw [expr list.nth_append] [],
        simpa [] [] ["only"] ["[", expr list.length_map, ",", expr list.length_reverse, "]"] [] ["using", expr h] },
      { rw [expr gt_iff_lt] ["at", ident h],
        rw ["[", expr list.nth_len_le, ",", expr list.nth_len_le, "]"] []; simp [] [] ["only"] ["[", expr nat.add_one_le_iff, ",", expr h, ",", expr list.length, ",", expr le_of_lt, ",", expr list.length_reverse, ",", expr list.length_append, ",", expr list.length_map, "]"] [] [] } },
    { split_ifs [] []; rw ["[", expr function.update_noteq h', ",", "<-", expr proj_map_nth, ",", expr hL, "]"] [],
      rw [expr function.update_noteq h'] [] } },
  case [ident TM2to1.st_act.peek, ":", ident f] { rw [expr function.update_eq_self] [],
    use ["[", expr L, ",", expr hL, "]"],
    rw ["[", expr tape.move_left_right, "]"] [],
    congr,
    cases [expr e, ":", expr S k] [],
    { refl },
    rw ["[", expr list.length_cons, ",", expr iterate_succ', ",", expr tape.move_right_left, ",", expr tape.move_right_n_head, ",", expr tape.mk'_nth_nat, ",", expr add_bottom_nth_snd, ",", expr stk_nth_val _ (hL k), ",", expr e, ",", expr list.reverse_cons, ",", "<-", expr list.length_reverse, ",", expr list.nth_concat_length, "]"] [],
    refl },
  case [ident TM2to1.st_act.pop, ":", ident f] { cases [expr e, ":", expr S k] [],
    { simp [] [] ["only"] ["[", expr tape.mk'_head, ",", expr list_blank.head_cons, ",", expr tape.move_left_mk', ",", expr list.length, ",", expr tape.write_mk', ",", expr list.head', ",", expr iterate_zero_apply, ",", expr list.tail_nil, "]"] [] [],
      rw ["[", "<-", expr e, ",", expr function.update_eq_self, "]"] [],
      exact [expr ⟨L, hL, by rw ["[", expr add_bottom_head_fst, ",", expr cond, "]"] []⟩] },
    { refine [expr ⟨_, λ
        k', _, by rw ["[", expr list.length_cons, ",", expr tape.move_right_n_head, ",", expr tape.mk'_nth_nat, ",", expr add_bottom_nth_succ_fst, ",", expr cond, ",", expr iterate_succ', ",", expr tape.move_right_left, ",", expr tape.move_right_n_head, ",", expr tape.mk'_nth_nat, ",", expr tape.write_move_right_n (λ
          a : Γ', (a.1, update a.2 k none)), ",", expr add_bottom_modify_nth (λ
          a, update a k none), ",", expr add_bottom_nth_snd, ",", expr stk_nth_val _ (hL k), ",", expr e, ",", expr show «expr = »((list.cons hd tl).reverse.nth tl.length, some hd), by rw ["[", expr list.reverse_cons, ",", "<-", expr list.length_reverse, ",", expr list.nth_concat_length, "]"] []; refl, ",", expr list.head', ",", expr list.tail, "]"] []⟩],
      refine [expr list_blank.ext (λ i, _)],
      rw ["[", expr list_blank.nth_map, ",", expr list_blank.nth_modify_nth, ",", expr proj, ",", expr pointed_map.mk_val, "]"] [],
      by_cases [expr h', ":", expr «expr = »(k', k)],
      { subst [expr k'],
        split_ifs [] []; simp [] [] ["only"] ["[", expr function.update_same, ",", expr list_blank.nth_mk, ",", expr list.tail, ",", expr list.inth, "]"] [] [],
        { rw ["[", expr list.nth_len_le, "]"] [],
          { refl },
          rw ["[", expr h, ",", expr list.length_reverse, ",", expr list.length_map, "]"] [] },
        rw ["[", "<-", expr proj_map_nth, ",", expr hL, ",", expr list_blank.nth_mk, ",", expr list.inth, ",", expr e, ",", expr list.map, ",", expr list.reverse_cons, "]"] [],
        cases [expr lt_or_gt_of_ne h] ["with", ident h, ident h],
        { rw [expr list.nth_append] [],
          simpa [] [] ["only"] ["[", expr list.length_map, ",", expr list.length_reverse, "]"] [] ["using", expr h] },
        { rw [expr gt_iff_lt] ["at", ident h],
          rw ["[", expr list.nth_len_le, ",", expr list.nth_len_le, "]"] []; simp [] [] ["only"] ["[", expr nat.add_one_le_iff, ",", expr h, ",", expr list.length, ",", expr le_of_lt, ",", expr list.length_reverse, ",", expr list.length_append, ",", expr list.length_map, "]"] [] [] } },
      { split_ifs [] []; rw ["[", expr function.update_noteq h', ",", "<-", expr proj_map_nth, ",", expr hL, "]"] [],
        rw [expr function.update_noteq h'] [] } } }
end

parameter (M : Λ → stmt₂)

include M

/-- The TM2 emulator machine states written as a TM1 program.
This handles the `go` and `ret` states, which shuttle to and from a stack top. -/
def tr : Λ' → stmt₁
| normal q => tr_normal (M q)
| go k s q =>
  branch (fun a s => (a.2 k).isNone) (tr_st_act (goto fun _ _ => ret q) s) (move dir.right$ goto fun _ _ => go k s q)
| ret q => branch (fun a s => a.1) (tr_normal q) (move dir.left$ goto fun _ _ => ret q)

attribute [local pp_using_anonymous_constructor] Turing.TM1.Cfg

/-- The relation between TM2 configurations and TM1 configurations of the TM2 emulator. -/
inductive tr_cfg : cfg₂ → cfg₁ → Prop
  | mk {q v} {S : ∀ k, List (Γ k)} (L : list_blank (∀ k, Option (Γ k))) :
  (∀ k, L.map (proj k) = list_blank.mk ((S k).map some).reverse) →
    tr_cfg ⟨q, v, S⟩ ⟨q.map normal, v, tape.mk' ∅ (add_bottom L)⟩

theorem tr_respects_aux₁ {k} o q v {S : List (Γ k)} {L : list_blank (∀ k, Option (Γ k))}
  (hL : L.map (proj k) = list_blank.mk (S.map some).reverse) n (_ : n ≤ S.length) :
  reaches₀ (TM1.step tr) ⟨some (go k o q), v, tape.mk' ∅ (add_bottom L)⟩
    ⟨some (go k o q), v, (tape.move dir.right^[n]) (tape.mk' ∅ (add_bottom L))⟩ :=
  by 
    induction' n with n IH
    ·
      rfl 
    apply (IH (le_of_ltₓ H)).tail 
    rw [iterate_succ_apply']
    simp only [TM1.step, TM1.step_aux, tr, tape.mk'_nth_nat, tape.move_right_n_head, add_bottom_nth_snd, Option.mem_def]
    rw [stk_nth_val _ hL, List.nth_le_nth]
    rfl 
    rwa [List.length_reverse]

theorem tr_respects_aux₃ {q v} {L : list_blank (∀ k, Option (Γ k))} n :
  reaches₀ (TM1.step tr) ⟨some (ret q), v, (tape.move dir.right^[n]) (tape.mk' ∅ (add_bottom L))⟩
    ⟨some (ret q), v, tape.mk' ∅ (add_bottom L)⟩ :=
  by 
    induction' n with n IH
    ·
      rfl 
    refine' reaches₀.head _ IH 
    rw [Option.mem_def, TM1.step, tr, TM1.step_aux, tape.move_right_n_head, tape.mk'_nth_nat, add_bottom_nth_succ_fst,
      TM1.step_aux, iterate_succ', tape.move_right_left]
    rfl

-- error in Computability.TuringMachine: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tr_respects_aux
{q v T k}
{S : ∀ k, list (Γ k)}
(hT : ∀ k, «expr = »(list_blank.map (proj k) T, list_blank.mk ((S k).map some).reverse))
(o : st_act k)
(IH : ∀
 {v : σ}
 {S : ∀ k : K, list (Γ k)}
 {T : list_blank (∀
   k, option (Γ k))}, ∀
 k, «expr = »(list_blank.map (proj k) T, list_blank.mk ((S k).map some).reverse) → «expr∃ , »((b), «expr ∧ »(tr_cfg (TM2.step_aux q v S) b, reaches (TM1.step tr) (TM1.step_aux (tr_normal q) v (tape.mk' «expr∅»() (add_bottom T))) b))) : «expr∃ , »((b), «expr ∧ »(tr_cfg (TM2.step_aux (st_run o q) v S) b, reaches (TM1.step tr) (TM1.step_aux (tr_normal (st_run o q)) v (tape.mk' «expr∅»() (add_bottom T))) b)) :=
begin
  simp [] [] ["only"] ["[", expr tr_normal_run, ",", expr step_run, "]"] [] [],
  have [ident hgo] [] [":=", expr tr_respects_aux₁ M o q v (hT k) _ (le_refl _)],
  obtain ["⟨", ident T', ",", ident hT', ",", ident hrun, "⟩", ":=", expr tr_respects_aux₂ hT o],
  have [ident hret] [] [":=", expr tr_respects_aux₃ M _],
  have [] [] [":=", expr hgo.tail' rfl],
  rw ["[", expr tr, ",", expr TM1.step_aux, ",", expr tape.move_right_n_head, ",", expr tape.mk'_nth_nat, ",", expr add_bottom_nth_snd, ",", expr stk_nth_val _ (hT k), ",", expr list.nth_len_le (le_of_eq (list.length_reverse _)), ",", expr option.is_none, ",", expr cond, ",", expr hrun, ",", expr TM1.step_aux, "]"] ["at", ident this],
  obtain ["⟨", ident c, ",", ident gc, ",", ident rc, "⟩", ":=", expr IH hT'],
  refine [expr ⟨c, gc, (this.to₀.trans hret c (trans_gen.head' rfl _)).to_refl⟩],
  rw ["[", expr tr, ",", expr TM1.step_aux, ",", expr tape.mk'_head, ",", expr add_bottom_head_fst, "]"] [],
  exact [expr rc]
end

attribute [local simp] respects TM2.step TM2.step_aux tr_normal

theorem tr_respects : respects (TM2.step M) (TM1.step tr) tr_cfg :=
  fun c₁ c₂ h =>
    by 
      cases' h with l v S L hT 
      clear h 
      cases l
      ·
        constructor 
      simp only [TM2.step, respects, Option.map_some']
      suffices  : ∃ b, _ ∧ reaches (TM1.step (tr M)) _ _ 
      exact
        let ⟨b, c, r⟩ := this
        ⟨b, c, trans_gen.head' rfl r⟩
      rw [tr]
      revert v S L hT 
      refine' stmt_st_rec _ _ _ _ _ (M l) <;> intros 
      ·
        exact tr_respects_aux M hT s @IH
      ·
        exact IH _ hT
      ·
        unfold TM2.step_aux tr_normal TM1.step_aux 
        cases p v <;> [exact IH₂ _ hT, exact IH₁ _ hT]
      ·
        exact ⟨_, ⟨_, hT⟩, refl_trans_gen.refl⟩
      ·
        exact ⟨_, ⟨_, hT⟩, refl_trans_gen.refl⟩

theorem tr_cfg_init k (L : List (Γ k)) : tr_cfg (TM2.init k L) (TM1.init (tr_init k L)) :=
  by 
    rw [(_ : TM1.init _ = _)]
    ·
      refine' ⟨list_blank.mk (L.reverse.map$ fun a => update (default _) k (some a)), fun k' => _⟩
      refine' list_blank.ext fun i => _ 
      rw [list_blank.map_mk, list_blank.nth_mk, List.inth, List.map_mapₓ, · ∘ ·, List.nth_map, proj, pointed_map.mk_val]
      byCases' k' = k
      ·
        subst k' 
        simp only [Function.update_same]
        rw [list_blank.nth_mk, List.inth, ←List.map_reverse, List.nth_map]
      ·
        simp only [Function.update_noteq h]
        rw [list_blank.nth_mk, List.inth, List.map, List.reverse_nil, List.nth]
        cases L.reverse.nth i <;> rfl
    ·
      rw [tr_init, TM1.init]
      dsimp only 
      congr <;>
        cases L.reverse <;>
          try 
            rfl 
      simp only [List.map_mapₓ, List.tail_cons, List.map]
      rfl

theorem tr_eval_dom k (L : List (Γ k)) : (TM1.eval tr (tr_init k L)).Dom ↔ (TM2.eval M k L).Dom :=
  tr_eval_dom tr_respects (tr_cfg_init _ _)

theorem tr_eval k (L : List (Γ k)) {L₁ L₂} (H₁ : L₁ ∈ TM1.eval tr (tr_init k L)) (H₂ : L₂ ∈ TM2.eval M k L) :
  ∃ (S : ∀ k, List (Γ k))(L' : list_blank (∀ k, Option (Γ k))),
    add_bottom L' = L₁ ∧ (∀ k, L'.map (proj k) = list_blank.mk ((S k).map some).reverse) ∧ S k = L₂ :=
  by 
    obtain ⟨c₁, h₁, rfl⟩ := (Part.mem_map_iff _).1 H₁ 
    obtain ⟨c₂, h₂, rfl⟩ := (Part.mem_map_iff _).1 H₂ 
    obtain ⟨_, ⟨q, v, S, L', hT⟩, h₃⟩ := tr_eval (tr_respects M) (tr_cfg_init M k L) h₂ 
    cases Part.mem_unique h₁ h₃ 
    exact
      ⟨S, L',
        by 
          simp only [tape.mk'_right₀],
        hT, rfl⟩

/-- The support of a set of TM2 states in the TM2 emulator. -/
noncomputable def tr_supp (S : Finset Λ) : Finset Λ' :=
  S.bUnion fun l => insert (normal l) (tr_stmts₁ (M l))

-- error in Computability.TuringMachine: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tr_supports {S} (ss : TM2.supports M S) : TM1.supports tr (tr_supp S) :=
⟨finset.mem_bUnion.2 ⟨_, ss.1, «expr $ »(finset.mem_insert.2, or.inl rfl)⟩, λ l' h, begin
   suffices [] [":", expr ∀
    (q)
    (ss' : TM2.supports_stmt S q)
    (sub : ∀
     x «expr ∈ » tr_stmts₁ q, «expr ∈ »(x, tr_supp M S)), «expr ∧ »(TM1.supports_stmt (tr_supp M S) (tr_normal q), ∀
     l' «expr ∈ » tr_stmts₁ q, TM1.supports_stmt (tr_supp M S) (tr M l'))],
   { rcases [expr finset.mem_bUnion.1 h, "with", "⟨", ident l, ",", ident lS, ",", ident h, "⟩"],
     have [] [] [":=", expr this _ (ss.2 l lS) (λ x hx, finset.mem_bUnion.2 ⟨_, lS, finset.mem_insert_of_mem hx⟩)],
     rcases [expr finset.mem_insert.1 h, "with", ident rfl, "|", ident h]; [exact [expr this.1], exact [expr this.2 _ h]] },
   clear [ident h, ident l'],
   refine [expr stmt_st_rec _ _ _ _ _]; intros [],
   { rw [expr TM2to1.supports_run] ["at", ident ss'],
     simp [] [] ["only"] ["[", expr TM2to1.tr_stmts₁_run, ",", expr finset.mem_union, ",", expr finset.mem_insert, ",", expr finset.mem_singleton, "]"] [] ["at", ident sub],
     have [ident hgo] [] [":=", expr sub _ «expr $ »(or.inl, or.inl rfl)],
     have [ident hret] [] [":=", expr sub _ «expr $ »(or.inl, or.inr rfl)],
     cases [expr IH ss' (λ x hx, «expr $ »(sub x, or.inr hx))] ["with", ident IH₁, ident IH₂],
     refine [expr ⟨by simp [] [] ["only"] ["[", expr tr_normal_run, ",", expr TM1.supports_stmt, "]"] [] []; intros []; exact [expr hgo], λ
       l h, _⟩],
     rw ["[", expr tr_stmts₁_run, "]"] ["at", ident h],
     simp [] [] ["only"] ["[", expr TM2to1.tr_stmts₁_run, ",", expr finset.mem_union, ",", expr finset.mem_insert, ",", expr finset.mem_singleton, "]"] [] ["at", ident h],
     rcases [expr h, "with", "⟨", ident rfl, "|", ident rfl, "⟩", "|", ident h],
     { unfold [ident TM1.supports_stmt, ident TM2to1.tr] [],
       rcases [expr s, "with", "_", "|", "_", "|", "_"],
       { exact [expr ⟨λ _ _, hret, λ _ _, hgo⟩] },
       { exact [expr ⟨λ _ _, hret, λ _ _, hgo⟩] },
       { exact [expr ⟨⟨λ _ _, hret, λ _ _, hret⟩, λ _ _, hgo⟩] } },
     { unfold [ident TM1.supports_stmt, ident TM2to1.tr] [],
       exact [expr ⟨IH₁, λ _ _, hret⟩] },
     { exact [expr IH₂ _ h] } },
   { unfold [ident TM2to1.tr_stmts₁] ["at", ident ss', ident sub, "⊢"],
     exact [expr IH ss' sub] },
   { unfold [ident TM2to1.tr_stmts₁] ["at", ident sub],
     cases [expr IH₁ ss'.1 (λ x hx, «expr $ »(sub x, finset.mem_union_left _ hx))] ["with", ident IH₁₁, ident IH₁₂],
     cases [expr IH₂ ss'.2 (λ x hx, «expr $ »(sub x, finset.mem_union_right _ hx))] ["with", ident IH₂₁, ident IH₂₂],
     refine [expr ⟨⟨IH₁₁, IH₂₁⟩, λ l h, _⟩],
     rw ["[", expr tr_stmts₁, "]"] ["at", ident h],
     rcases [expr finset.mem_union.1 h, "with", ident h, "|", ident h]; [exact [expr IH₁₂ _ h], exact [expr IH₂₂ _ h]] },
   { rw [expr tr_stmts₁] [],
     unfold [ident TM2to1.tr_normal, ident TM1.supports_stmt] [],
     unfold [ident TM2.supports_stmt] ["at", ident ss'],
     exact [expr ⟨λ _ v, finset.mem_bUnion.2 ⟨_, ss' v, finset.mem_insert_self _ _⟩, λ _, false.elim⟩] },
   { exact [expr ⟨trivial, λ _, false.elim⟩] }
 end⟩

end 

end TM2to1

end Turing

