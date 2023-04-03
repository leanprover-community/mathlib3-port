/-
Copyright (c) 2022 Junyan Xu. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Junyan Xu

! This file was ported from Lean 3 source module logic.hydra
! leanprover-community/mathlib commit e9b8651eb1ad354f4de6be35a38ef31efcd2cfaa
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finsupp.Lex
import Mathbin.Data.Finsupp.Multiset
import Mathbin.Order.GameAdd

/-!
# Termination of a hydra game

This file deals with the following version of the hydra game: each head of the hydra is
labelled by an element in a type `α`, and when you cut off one head with label `a`, it
grows back an arbitrary but finite number of heads, all labelled by elements smaller than
`a` with respect to a well-founded relation `r` on `α`. We show that no matter how (in
what order) you choose cut off the heads, the game always terminates, i.e. all heads will
eventually be cut off (but of course it can last arbitrarily long, i.e. takes an
arbitrary finite number of steps).

This result is stated as the well-foundedness of the `cut_expand` relation defined in
this file: we model the heads of the hydra as a multiset of elements of `α`, and the
valid "moves" of the game are modelled by the relation `cut_expand r` on `multiset α`:
`cut_expand r s' s` is true iff `s'` is obtained by removing one head `a ∈ s` and
adding back an arbitrary multiset `t` of heads such that all `a' ∈ t` satisfy `r a' a`.

We follow the proof by Peter LeFanu Lumsdaine at https://mathoverflow.net/a/229084/3332.

TODO: formalize the relations corresponding to more powerful (e.g. Kirby–Paris and Buchholz)
hydras, and prove their well-foundedness.
-/


namespace Relation

open Multiset Prod

variable {α : Type _}

#print Relation.CutExpand /-
/-- The relation that specifies valid moves in our hydra game. `cut_expand r s' s`
  means that `s'` is obtained by removing one head `a ∈ s` and adding back an arbitrary
  multiset `t` of heads such that all `a' ∈ t` satisfy `r a' a`.

  This is most directly translated into `s' = s.erase a + t`, but `multiset.erase` requires
  `decidable_eq α`, so we use the equivalent condition `s' + {a} = s + t` instead, which
  is also easier to verify for explicit multisets `s'`, `s` and `t`.

  We also don't include the condition `a ∈ s` because `s' + {a} = s + t` already
  guarantees `a ∈ s + t`, and if `r` is irreflexive then `a ∉ t`, which is the
  case when `r` is well-founded, the case we are primarily interested in.

  The lemma `relation.cut_expand_iff` below converts between this convenient definition
  and the direct translation when `r` is irreflexive. -/
def CutExpand (r : α → α → Prop) (s' s : Multiset α) : Prop :=
  ∃ (t : Multiset α)(a : α), (∀ a' ∈ t, r a' a) ∧ s' + {a} = s + t
#align relation.cut_expand Relation.CutExpand
-/

variable {r : α → α → Prop}

/- warning: relation.cut_expand_le_inv_image_lex -> Relation.cutExpand_le_invImage_lex is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {r : α -> α -> Prop} [hi : IsIrrefl.{u1} α r], LE.le.{u1} ((Multiset.{u1} α) -> (Multiset.{u1} α) -> Prop) (Pi.hasLe.{u1, u1} (Multiset.{u1} α) (fun (s' : Multiset.{u1} α) => (Multiset.{u1} α) -> Prop) (fun (i : Multiset.{u1} α) => Pi.hasLe.{u1, 0} (Multiset.{u1} α) (fun (s : Multiset.{u1} α) => Prop) (fun (i : Multiset.{u1} α) => Prop.le))) (Relation.CutExpand.{u1} α r) (InvImage.{succ u1, succ u1} (Multiset.{u1} α) (Finsupp.{u1, 0} α Nat Nat.hasZero) (Finsupp.Lex.{u1, 0} α Nat Nat.hasZero (Inf.inf.{u1} (α -> α -> Prop) (Pi.hasInf.{u1, u1} α (fun (ᾰ : α) => α -> Prop) (fun (i : α) => Pi.hasInf.{u1, 0} α (fun (ᾰ : α) => Prop) (fun (i : α) => SemilatticeInf.toHasInf.{0} Prop (Lattice.toSemilatticeInf.{0} Prop (ConditionallyCompleteLattice.toLattice.{0} Prop (CompleteLattice.toConditionallyCompleteLattice.{0} Prop Prop.completeLattice)))))) (HasCompl.compl.{u1} (α -> α -> Prop) (Pi.hasCompl.{u1, u1} α (fun (ᾰ : α) => α -> Prop) (fun (i : α) => Pi.hasCompl.{u1, 0} α (fun (ᾰ : α) => Prop) (fun (i : α) => Prop.hasCompl))) r) (Ne.{succ u1} α)) (LT.lt.{0} Nat Nat.hasLt)) (coeFn.{succ u1, succ u1} (AddEquiv.{u1, u1} (Multiset.{u1} α) (Finsupp.{u1, 0} α Nat Nat.hasZero) (Multiset.hasAdd.{u1} α) (Finsupp.add.{u1, 0} α Nat (AddMonoid.toAddZeroClass.{0} Nat Nat.addMonoid))) (fun (_x : AddEquiv.{u1, u1} (Multiset.{u1} α) (Finsupp.{u1, 0} α Nat Nat.hasZero) (Multiset.hasAdd.{u1} α) (Finsupp.add.{u1, 0} α Nat (AddMonoid.toAddZeroClass.{0} Nat Nat.addMonoid))) => (Multiset.{u1} α) -> (Finsupp.{u1, 0} α Nat Nat.hasZero)) (AddEquiv.hasCoeToFun.{u1, u1} (Multiset.{u1} α) (Finsupp.{u1, 0} α Nat Nat.hasZero) (Multiset.hasAdd.{u1} α) (Finsupp.add.{u1, 0} α Nat (AddMonoid.toAddZeroClass.{0} Nat Nat.addMonoid))) (Multiset.toFinsupp.{u1} α)))
but is expected to have type
  forall {α : Type.{u1}} {r : α -> α -> Prop} [hi : IsIrrefl.{u1} α r], LE.le.{u1} ((Multiset.{u1} α) -> (Multiset.{u1} α) -> Prop) (Pi.hasLe.{u1, u1} (Multiset.{u1} α) (fun (s' : Multiset.{u1} α) => (Multiset.{u1} α) -> Prop) (fun (i : Multiset.{u1} α) => Pi.hasLe.{u1, 0} (Multiset.{u1} α) (fun (s : Multiset.{u1} α) => Prop) (fun (i : Multiset.{u1} α) => Prop.le))) (Relation.CutExpand.{u1} α r) (InvImage.{succ u1, succ u1} (Multiset.{u1} α) (Finsupp.{u1, 0} α Nat (LinearOrderedCommMonoidWithZero.toZero.{0} Nat Nat.linearOrderedCommMonoidWithZero)) (Finsupp.Lex.{u1, 0} α Nat (LinearOrderedCommMonoidWithZero.toZero.{0} Nat Nat.linearOrderedCommMonoidWithZero) (Inf.inf.{u1} (α -> α -> Prop) (Pi.instInfForAll.{u1, u1} α (fun (ᾰ : α) => α -> Prop) (fun (i : α) => Pi.instInfForAll.{u1, 0} α (fun (ᾰ : α) => Prop) (fun (i : α) => Lattice.toInf.{0} Prop (ConditionallyCompleteLattice.toLattice.{0} Prop (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{0} Prop (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{0} Prop (CompleteLinearOrder.toConditionallyCompleteLinearOrderBot.{0} Prop Prop.completeLinearOrder))))))) (HasCompl.compl.{u1} (α -> α -> Prop) (Pi.hasCompl.{u1, u1} α (fun (ᾰ : α) => α -> Prop) (fun (i : α) => Pi.hasCompl.{u1, 0} α (fun (ᾰ : α) => Prop) (fun (i : α) => Prop.hasCompl))) r) (fun (x._@.Mathlib.Logic.Hydra._hyg.153 : α) (x._@.Mathlib.Logic.Hydra._hyg.155 : α) => Ne.{succ u1} α x._@.Mathlib.Logic.Hydra._hyg.153 x._@.Mathlib.Logic.Hydra._hyg.155)) (fun (x._@.Mathlib.Logic.Hydra._hyg.168 : Nat) (x._@.Mathlib.Logic.Hydra._hyg.170 : Nat) => LT.lt.{0} Nat instLTNat x._@.Mathlib.Logic.Hydra._hyg.168 x._@.Mathlib.Logic.Hydra._hyg.170)) (FunLike.coe.{succ u1, succ u1, succ u1} (AddEquiv.{u1, u1} (Multiset.{u1} α) (Finsupp.{u1, 0} α Nat (LinearOrderedCommMonoidWithZero.toZero.{0} Nat Nat.linearOrderedCommMonoidWithZero)) (Multiset.instAddMultiset.{u1} α) (Finsupp.add.{u1, 0} α Nat (AddMonoid.toAddZeroClass.{0} Nat Nat.addMonoid))) (Multiset.{u1} α) (fun (_x : Multiset.{u1} α) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.403 : Multiset.{u1} α) => Finsupp.{u1, 0} α Nat (LinearOrderedCommMonoidWithZero.toZero.{0} Nat Nat.linearOrderedCommMonoidWithZero)) _x) (AddHomClass.toFunLike.{u1, u1, u1} (AddEquiv.{u1, u1} (Multiset.{u1} α) (Finsupp.{u1, 0} α Nat (LinearOrderedCommMonoidWithZero.toZero.{0} Nat Nat.linearOrderedCommMonoidWithZero)) (Multiset.instAddMultiset.{u1} α) (Finsupp.add.{u1, 0} α Nat (AddMonoid.toAddZeroClass.{0} Nat Nat.addMonoid))) (Multiset.{u1} α) (Finsupp.{u1, 0} α Nat (LinearOrderedCommMonoidWithZero.toZero.{0} Nat Nat.linearOrderedCommMonoidWithZero)) (AddZeroClass.toAdd.{u1} (Multiset.{u1} α) (AddMonoid.toAddZeroClass.{u1} (Multiset.{u1} α) (AddRightCancelMonoid.toAddMonoid.{u1} (Multiset.{u1} α) (AddCancelMonoid.toAddRightCancelMonoid.{u1} (Multiset.{u1} α) (AddCancelCommMonoid.toAddCancelMonoid.{u1} (Multiset.{u1} α) (OrderedCancelAddCommMonoid.toCancelAddCommMonoid.{u1} (Multiset.{u1} α) (Multiset.instOrderedCancelAddCommMonoidMultiset.{u1} α))))))) (AddZeroClass.toAdd.{u1} (Finsupp.{u1, 0} α Nat (LinearOrderedCommMonoidWithZero.toZero.{0} Nat Nat.linearOrderedCommMonoidWithZero)) (Finsupp.addZeroClass.{u1, 0} α Nat (AddMonoid.toAddZeroClass.{0} Nat Nat.addMonoid))) (AddMonoidHomClass.toAddHomClass.{u1, u1, u1} (AddEquiv.{u1, u1} (Multiset.{u1} α) (Finsupp.{u1, 0} α Nat (LinearOrderedCommMonoidWithZero.toZero.{0} Nat Nat.linearOrderedCommMonoidWithZero)) (Multiset.instAddMultiset.{u1} α) (Finsupp.add.{u1, 0} α Nat (AddMonoid.toAddZeroClass.{0} Nat Nat.addMonoid))) (Multiset.{u1} α) (Finsupp.{u1, 0} α Nat (LinearOrderedCommMonoidWithZero.toZero.{0} Nat Nat.linearOrderedCommMonoidWithZero)) (AddMonoid.toAddZeroClass.{u1} (Multiset.{u1} α) (AddRightCancelMonoid.toAddMonoid.{u1} (Multiset.{u1} α) (AddCancelMonoid.toAddRightCancelMonoid.{u1} (Multiset.{u1} α) (AddCancelCommMonoid.toAddCancelMonoid.{u1} (Multiset.{u1} α) (OrderedCancelAddCommMonoid.toCancelAddCommMonoid.{u1} (Multiset.{u1} α) (Multiset.instOrderedCancelAddCommMonoidMultiset.{u1} α)))))) (Finsupp.addZeroClass.{u1, 0} α Nat (AddMonoid.toAddZeroClass.{0} Nat Nat.addMonoid)) (AddEquivClass.instAddMonoidHomClass.{u1, u1, u1} (AddEquiv.{u1, u1} (Multiset.{u1} α) (Finsupp.{u1, 0} α Nat (LinearOrderedCommMonoidWithZero.toZero.{0} Nat Nat.linearOrderedCommMonoidWithZero)) (Multiset.instAddMultiset.{u1} α) (Finsupp.add.{u1, 0} α Nat (AddMonoid.toAddZeroClass.{0} Nat Nat.addMonoid))) (Multiset.{u1} α) (Finsupp.{u1, 0} α Nat (LinearOrderedCommMonoidWithZero.toZero.{0} Nat Nat.linearOrderedCommMonoidWithZero)) (AddMonoid.toAddZeroClass.{u1} (Multiset.{u1} α) (AddRightCancelMonoid.toAddMonoid.{u1} (Multiset.{u1} α) (AddCancelMonoid.toAddRightCancelMonoid.{u1} (Multiset.{u1} α) (AddCancelCommMonoid.toAddCancelMonoid.{u1} (Multiset.{u1} α) (OrderedCancelAddCommMonoid.toCancelAddCommMonoid.{u1} (Multiset.{u1} α) (Multiset.instOrderedCancelAddCommMonoidMultiset.{u1} α)))))) (Finsupp.addZeroClass.{u1, 0} α Nat (AddMonoid.toAddZeroClass.{0} Nat Nat.addMonoid)) (AddEquiv.instAddEquivClassAddEquiv.{u1, u1} (Multiset.{u1} α) (Finsupp.{u1, 0} α Nat (LinearOrderedCommMonoidWithZero.toZero.{0} Nat Nat.linearOrderedCommMonoidWithZero)) (Multiset.instAddMultiset.{u1} α) (Finsupp.add.{u1, 0} α Nat (AddMonoid.toAddZeroClass.{0} Nat Nat.addMonoid)))))) (Multiset.toFinsupp.{u1} α)))
Case conversion may be inaccurate. Consider using '#align relation.cut_expand_le_inv_image_lex Relation.cutExpand_le_invImage_lexₓ'. -/
theorem cutExpand_le_invImage_lex [hi : IsIrrefl α r] :
    CutExpand r ≤ InvImage (Finsupp.Lex (rᶜ ⊓ (· ≠ ·)) (· < ·)) toFinsupp :=
  fun s t ⟨u, a, hr, he⟩ => by
  classical
    refine' ⟨a, fun b h => _, _⟩ <;> simp_rw [to_finsupp_apply]
    · apply_fun count b  at he
      simp_rw [count_add] at he
      convert he <;> convert(add_zero _).symm <;> rw [count_eq_zero] <;> intro hb
      exacts[h.2 (mem_singleton.1 hb), h.1 (hr b hb)]
    · apply_fun count a  at he
      simp_rw [count_add, count_singleton_self] at he
      apply Nat.lt_of_succ_le
      convert he.le
      convert(add_zero _).symm
      exact count_eq_zero.2 fun ha => hi.irrefl a <| hr a ha
#align relation.cut_expand_le_inv_image_lex Relation.cutExpand_le_invImage_lex

#print Relation.cutExpand_singleton /-
theorem cutExpand_singleton {s x} (h : ∀ x' ∈ s, r x' x) : CutExpand r s {x} :=
  ⟨s, x, h, add_comm s _⟩
#align relation.cut_expand_singleton Relation.cutExpand_singleton
-/

#print Relation.cutExpand_singleton_singleton /-
theorem cutExpand_singleton_singleton {x' x} (h : r x' x) : CutExpand r {x'} {x} :=
  cutExpand_singleton fun a h => by rwa [mem_singleton.1 h]
#align relation.cut_expand_singleton_singleton Relation.cutExpand_singleton_singleton
-/

#print Relation.cutExpand_add_left /-
theorem cutExpand_add_left {t u} (s) : CutExpand r (s + t) (s + u) ↔ CutExpand r t u :=
  exists₂_congr fun _ _ => and_congr Iff.rfl <| by rw [add_assoc, add_assoc, add_left_cancel_iff]
#align relation.cut_expand_add_left Relation.cutExpand_add_left
-/

#print Relation.cutExpand_iff /-
theorem cutExpand_iff [DecidableEq α] [IsIrrefl α r] {s' s : Multiset α} :
    CutExpand r s' s ↔
      ∃ (t : Multiset α)(a : _), (∀ a' ∈ t, r a' a) ∧ a ∈ s ∧ s' = s.eraseₓ a + t :=
  by
  simp_rw [cut_expand, add_singleton_eq_iff]
  refine' exists₂_congr fun t a => ⟨_, _⟩
  · rintro ⟨ht, ha, rfl⟩
    obtain h | h := mem_add.1 ha
    exacts[⟨ht, h, t.erase_add_left_pos h⟩, (@irrefl α r _ a (ht a h)).elim]
  · rintro ⟨ht, h, rfl⟩
    exact ⟨ht, mem_add.2 (Or.inl h), (t.erase_add_left_pos h).symm⟩
#align relation.cut_expand_iff Relation.cutExpand_iff
-/

#print Relation.not_cutExpand_zero /-
theorem not_cutExpand_zero [IsIrrefl α r] (s) : ¬CutExpand r s 0 := by
  classical
    rw [cut_expand_iff]
    rintro ⟨_, _, _, ⟨⟩, _⟩
#align relation.not_cut_expand_zero Relation.not_cutExpand_zero
-/

#print Relation.cutExpand_fibration /-
/-- For any relation `r` on `α`, multiset addition `multiset α × multiset α → multiset α` is a
  fibration between the game sum of `cut_expand r` with itself and `cut_expand r` itself. -/
theorem cutExpand_fibration (r : α → α → Prop) :
    Fibration (GameAdd (CutExpand r) (CutExpand r)) (CutExpand r) fun s => s.1 + s.2 :=
  by
  rintro ⟨s₁, s₂⟩ s ⟨t, a, hr, he⟩; dsimp at he⊢
  classical
    obtain ⟨ha, rfl⟩ := add_singleton_eq_iff.1 he
    rw [add_assoc, mem_add] at ha
    obtain h | h := ha
    · refine' ⟨(s₁.erase a + t, s₂), game_add.fst ⟨t, a, hr, _⟩, _⟩
      · rw [add_comm, ← add_assoc, singleton_add, cons_erase h]
      · rw [add_assoc s₁, erase_add_left_pos _ h, add_right_comm, add_assoc]
    · refine' ⟨(s₁, (s₂ + t).eraseₓ a), game_add.snd ⟨t, a, hr, _⟩, _⟩
      · rw [add_comm, singleton_add, cons_erase h]
      · rw [add_assoc, erase_add_right_pos _ h]
#align relation.cut_expand_fibration Relation.cutExpand_fibration
-/

#print Relation.acc_of_singleton /-
/-- A multiset is accessible under `cut_expand` if all its singleton subsets are,
  assuming `r` is irreflexive. -/
theorem acc_of_singleton [IsIrrefl α r] {s : Multiset α} :
    (∀ a ∈ s, Acc (CutExpand r) {a}) → Acc (CutExpand r) s :=
  by
  refine' Multiset.induction _ _ s
  · exact fun _ => Acc.intro 0 fun s h => (not_cut_expand_zero s h).elim
  · intro a s ih hacc
    rw [← s.singleton_add a]
    exact
      ((hacc a <| s.mem_cons_self a).prod_gameAdd <|
            ih fun a ha => hacc a <| mem_cons_of_mem ha).of_fibration
        _ (cut_expand_fibration r)
#align relation.acc_of_singleton Relation.acc_of_singleton
-/

#print Acc.cutExpand /-
/-- A singleton `{a}` is accessible under `cut_expand r` if `a` is accessible under `r`,
  assuming `r` is irreflexive. -/
theorem Acc.cutExpand [IsIrrefl α r] {a : α} (hacc : Acc r a) : Acc (CutExpand r) {a} :=
  by
  induction' hacc with a h ih
  refine' Acc.intro _ fun s => _
  classical
    rw [cut_expand_iff]
    rintro ⟨t, a, hr, rfl | ⟨⟨⟩⟩, rfl⟩
    refine' acc_of_singleton fun a' => _
    rw [erase_singleton, zero_add]
    exact ih a' ∘ hr a'
#align acc.cut_expand Acc.cutExpand
-/

#print WellFounded.cutExpand /-
/-- `cut_expand r` is well-founded when `r` is. -/
theorem WellFounded.cutExpand (hr : WellFounded r) : WellFounded (CutExpand r) :=
  ⟨letI h := hr.is_irrefl
    fun s => acc_of_singleton fun a _ => (hr.apply a).CutExpand⟩
#align well_founded.cut_expand WellFounded.cutExpand
-/

end Relation

