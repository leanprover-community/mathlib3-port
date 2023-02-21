/-
Copyright (c) 2019 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Floris van Doorn

! This file was ported from Lean 3 source module data.set.pointwise.finite
! leanprover-community/mathlib commit bd9851ca476957ea4549eb19b40e7b5ade9428cc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Finite
import Mathbin.Data.Set.Pointwise.Smul

/-! # Finiteness lemmas for pointwise operations on sets 

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.-/


open Pointwise

variable {F α β γ : Type _}

namespace Set

section InvolutiveInv

variable [InvolutiveInv α] {s : Set α}

/- warning: set.finite.inv -> Set.Finite.inv is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : InvolutiveInv.{u1} α] {s : Set.{u1} α}, (Set.Finite.{u1} α s) -> (Set.Finite.{u1} α (Inv.inv.{u1} (Set.{u1} α) (Set.inv.{u1} α (InvolutiveInv.toHasInv.{u1} α _inst_1)) s))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : InvolutiveInv.{u1} α] {s : Set.{u1} α}, (Set.Finite.{u1} α s) -> (Set.Finite.{u1} α (Inv.inv.{u1} (Set.{u1} α) (Set.inv.{u1} α (InvolutiveInv.toInv.{u1} α _inst_1)) s))
Case conversion may be inaccurate. Consider using '#align set.finite.inv Set.Finite.invₓ'. -/
@[to_additive]
theorem Finite.inv (hs : s.Finite) : s⁻¹.Finite :=
  hs.Preimage <| inv_injective.InjOn _
#align set.finite.inv Set.Finite.inv
#align set.finite.neg Set.Finite.neg

end InvolutiveInv

section Mul

variable [Mul α] {s t : Set α}

#print Set.Finite.mul /-
@[to_additive]
theorem Finite.mul : s.Finite → t.Finite → (s * t).Finite :=
  Finite.image2 _
#align set.finite.mul Set.Finite.mul
#align set.finite.add Set.Finite.add
-/

#print Set.fintypeMul /-
/-- Multiplication preserves finiteness. -/
@[to_additive "Addition preserves finiteness."]
def fintypeMul [DecidableEq α] (s t : Set α) [Fintype s] [Fintype t] : Fintype (s * t : Set α) :=
  Set.fintypeImage2 _ _ _
#align set.fintype_mul Set.fintypeMul
#align set.fintype_add Set.fintypeAdd
-/

end Mul

section Monoid

variable [Monoid α] {s t : Set α}

/- warning: set.decidable_mem_mul -> Set.decidableMemMul is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Monoid.{u1} α] {s : Set.{u1} α} {t : Set.{u1} α} [_inst_2 : Fintype.{u1} α] [_inst_3 : DecidableEq.{succ u1} α] [_inst_4 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x s)] [_inst_5 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x t)], DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x (HMul.hMul.{u1, u1, u1} (Set.{u1} α) (Set.{u1} α) (Set.{u1} α) (instHMul.{u1} (Set.{u1} α) (Set.mul.{u1} α (MulOneClass.toHasMul.{u1} α (Monoid.toMulOneClass.{u1} α _inst_1)))) s t))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Monoid.{u1} α] {s : Set.{u1} α} {t : Set.{u1} α} [_inst_2 : Fintype.{u1} α] [_inst_3 : DecidableEq.{succ u1} α] [_inst_4 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x s)] [_inst_5 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x t)], DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x (HMul.hMul.{u1, u1, u1} (Set.{u1} α) (Set.{u1} α) (Set.{u1} α) (instHMul.{u1} (Set.{u1} α) (Set.mul.{u1} α (MulOneClass.toMul.{u1} α (Monoid.toMulOneClass.{u1} α _inst_1)))) s t))
Case conversion may be inaccurate. Consider using '#align set.decidable_mem_mul Set.decidableMemMulₓ'. -/
@[to_additive]
instance decidableMemMul [Fintype α] [DecidableEq α] [DecidablePred (· ∈ s)]
    [DecidablePred (· ∈ t)] : DecidablePred (· ∈ s * t) := fun _ => decidable_of_iff _ mem_mul.symm
#align set.decidable_mem_mul Set.decidableMemMul
#align set.decidable_mem_add Set.decidableMemAdd

/- warning: set.decidable_mem_pow -> Set.decidableMemPow is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Monoid.{u1} α] {s : Set.{u1} α} [_inst_2 : Fintype.{u1} α] [_inst_3 : DecidableEq.{succ u1} α] [_inst_4 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x s)] (n : Nat), DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x (HPow.hPow.{u1, 0, u1} (Set.{u1} α) Nat (Set.{u1} α) (instHPow.{u1, 0} (Set.{u1} α) Nat (Set.NPow.{u1} α (MulOneClass.toHasOne.{u1} α (Monoid.toMulOneClass.{u1} α _inst_1)) (MulOneClass.toHasMul.{u1} α (Monoid.toMulOneClass.{u1} α _inst_1)))) s n))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Monoid.{u1} α] {s : Set.{u1} α} [_inst_2 : Fintype.{u1} α] [_inst_3 : DecidableEq.{succ u1} α] [_inst_4 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x s)] (n : Nat), DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x (HPow.hPow.{u1, 0, u1} (Set.{u1} α) Nat (Set.{u1} α) (instHPow.{u1, 0} (Set.{u1} α) Nat (Set.NPow.{u1} α (Monoid.toOne.{u1} α _inst_1) (MulOneClass.toMul.{u1} α (Monoid.toMulOneClass.{u1} α _inst_1)))) s n))
Case conversion may be inaccurate. Consider using '#align set.decidable_mem_pow Set.decidableMemPowₓ'. -/
@[to_additive]
instance decidableMemPow [Fintype α] [DecidableEq α] [DecidablePred (· ∈ s)] (n : ℕ) :
    DecidablePred (· ∈ s ^ n) := by
  induction' n with n ih
  · simp_rw [pow_zero, mem_one]
    infer_instance
  · letI := ih
    rw [pow_succ]
    infer_instance
#align set.decidable_mem_pow Set.decidableMemPow
#align set.decidable_mem_nsmul Set.decidableMemNSMul

end Monoid

section SMul

variable [SMul α β] {s : Set α} {t : Set β}

/- warning: set.finite.smul -> Set.Finite.smul is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : SMul.{u1, u2} α β] {s : Set.{u1} α} {t : Set.{u2} β}, (Set.Finite.{u1} α s) -> (Set.Finite.{u2} β t) -> (Set.Finite.{u2} β (SMul.smul.{u1, u2} (Set.{u1} α) (Set.{u2} β) (Set.smul.{u1, u2} α β _inst_1) s t))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : SMul.{u2, u1} α β] {s : Set.{u2} α} {t : Set.{u1} β}, (Set.Finite.{u2} α s) -> (Set.Finite.{u1} β t) -> (Set.Finite.{u1} β (HSMul.hSMul.{u2, u1, u1} (Set.{u2} α) (Set.{u1} β) (Set.{u1} β) (instHSMul.{u2, u1} (Set.{u2} α) (Set.{u1} β) (Set.smul.{u2, u1} α β _inst_1)) s t))
Case conversion may be inaccurate. Consider using '#align set.finite.smul Set.Finite.smulₓ'. -/
@[to_additive]
theorem Finite.smul : s.Finite → t.Finite → (s • t).Finite :=
  Finite.image2 _
#align set.finite.smul Set.Finite.smul
#align set.finite.vadd Set.Finite.vadd

end SMul

section HasSmulSet

variable [SMul α β] {s : Set β} {a : α}

#print Set.Finite.smul_set /-
@[to_additive]
theorem Finite.smul_set : s.Finite → (a • s).Finite :=
  Finite.image _
#align set.finite.smul_set Set.Finite.smul_set
#align set.finite.vadd_set Set.Finite.vadd_set
-/

end HasSmulSet

section Vsub

variable [VSub α β] {s t : Set β}

include α

#print Set.Finite.vsub /-
theorem Finite.vsub (hs : s.Finite) (ht : t.Finite) : Set.Finite (s -ᵥ t) :=
  hs.image2 _ ht
#align set.finite.vsub Set.Finite.vsub
-/

end Vsub

end Set

open Set

namespace Group

variable {G : Type _} [Group G] [Fintype G] (S : Set G)

/- warning: group.card_pow_eq_card_pow_card_univ -> Group.card_pow_eq_card_pow_card_univ is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u1}} [_inst_1 : Group.{u1} G] [_inst_2 : Fintype.{u1} G] (S : Set.{u1} G) [_inst_3 : forall (k : Nat), DecidablePred.{succ u1} G (fun (_x : G) => Membership.Mem.{u1, u1} G (Set.{u1} G) (Set.hasMem.{u1} G) _x (HPow.hPow.{u1, 0, u1} (Set.{u1} G) Nat (Set.{u1} G) (instHPow.{u1, 0} (Set.{u1} G) Nat (Set.NPow.{u1} G (MulOneClass.toHasOne.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))) (MulOneClass.toHasMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))))) S k))] (k : Nat), (LE.le.{0} Nat Nat.hasLe (Fintype.card.{u1} G _inst_2) k) -> (Eq.{1} Nat (Fintype.card.{u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} G) Type.{u1} (Set.hasCoeToSort.{u1} G) (HPow.hPow.{u1, 0, u1} (Set.{u1} G) Nat (Set.{u1} G) (instHPow.{u1, 0} (Set.{u1} G) Nat (Set.NPow.{u1} G (MulOneClass.toHasOne.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))) (MulOneClass.toHasMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))))) S k)) (Subtype.fintype.{u1} G (fun (x : G) => Membership.Mem.{u1, u1} G (Set.{u1} G) (Set.hasMem.{u1} G) x (HPow.hPow.{u1, 0, u1} (Set.{u1} G) Nat (Set.{u1} G) (instHPow.{u1, 0} (Set.{u1} G) Nat (Set.NPow.{u1} G (MulOneClass.toHasOne.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))) (MulOneClass.toHasMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))))) S k)) (fun (a : G) => _inst_3 k a) _inst_2)) (Fintype.card.{u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} G) Type.{u1} (Set.hasCoeToSort.{u1} G) (HPow.hPow.{u1, 0, u1} (Set.{u1} G) Nat (Set.{u1} G) (instHPow.{u1, 0} (Set.{u1} G) Nat (Set.NPow.{u1} G (MulOneClass.toHasOne.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))) (MulOneClass.toHasMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))))) S (Fintype.card.{u1} G _inst_2))) (Subtype.fintype.{u1} G (fun (x : G) => Membership.Mem.{u1, u1} G (Set.{u1} G) (Set.hasMem.{u1} G) x (HPow.hPow.{u1, 0, u1} (Set.{u1} G) Nat (Set.{u1} G) (instHPow.{u1, 0} (Set.{u1} G) Nat (Set.NPow.{u1} G (MulOneClass.toHasOne.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))) (MulOneClass.toHasMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))))) S (Fintype.card.{u1} G _inst_2))) (fun (a : G) => _inst_3 (Fintype.card.{u1} G _inst_2) a) _inst_2)))
but is expected to have type
  forall {G : Type.{u1}} [_inst_1 : Group.{u1} G] [_inst_2 : Fintype.{u1} G] (S : Set.{u1} G) [_inst_3 : forall (k : Nat), DecidablePred.{succ u1} G (fun (_x : G) => Membership.mem.{u1, u1} G (Set.{u1} G) (Set.instMembershipSet.{u1} G) _x (HPow.hPow.{u1, 0, u1} (Set.{u1} G) Nat (Set.{u1} G) (instHPow.{u1, 0} (Set.{u1} G) Nat (Set.NPow.{u1} G (InvOneClass.toOne.{u1} G (DivInvOneMonoid.toInvOneClass.{u1} G (DivisionMonoid.toDivInvOneMonoid.{u1} G (Group.toDivisionMonoid.{u1} G _inst_1)))) (MulOneClass.toMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))))) S k))] (k : Nat), (LE.le.{0} Nat instLENat (Fintype.card.{u1} G _inst_2) k) -> (Eq.{1} Nat (Fintype.card.{u1} (Set.Elem.{u1} G (HPow.hPow.{u1, 0, u1} (Set.{u1} G) Nat (Set.{u1} G) (instHPow.{u1, 0} (Set.{u1} G) Nat (Set.NPow.{u1} G (InvOneClass.toOne.{u1} G (DivInvOneMonoid.toInvOneClass.{u1} G (DivisionMonoid.toDivInvOneMonoid.{u1} G (Group.toDivisionMonoid.{u1} G _inst_1)))) (MulOneClass.toMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))))) S k)) (Subtype.fintype.{u1} G (fun (x : G) => Membership.mem.{u1, u1} G (Set.{u1} G) (Set.instMembershipSet.{u1} G) x (HPow.hPow.{u1, 0, u1} (Set.{u1} G) Nat (Set.{u1} G) (instHPow.{u1, 0} (Set.{u1} G) Nat (Set.NPow.{u1} G (InvOneClass.toOne.{u1} G (DivInvOneMonoid.toInvOneClass.{u1} G (DivisionMonoid.toDivInvOneMonoid.{u1} G (Group.toDivisionMonoid.{u1} G _inst_1)))) (MulOneClass.toMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))))) S k)) (fun (a : G) => _inst_3 k a) _inst_2)) (Fintype.card.{u1} (Set.Elem.{u1} G (HPow.hPow.{u1, 0, u1} (Set.{u1} G) Nat (Set.{u1} G) (instHPow.{u1, 0} (Set.{u1} G) Nat (Set.NPow.{u1} G (InvOneClass.toOne.{u1} G (DivInvOneMonoid.toInvOneClass.{u1} G (DivisionMonoid.toDivInvOneMonoid.{u1} G (Group.toDivisionMonoid.{u1} G _inst_1)))) (MulOneClass.toMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))))) S (Fintype.card.{u1} G _inst_2))) (Subtype.fintype.{u1} G (fun (x : G) => Membership.mem.{u1, u1} G (Set.{u1} G) (Set.instMembershipSet.{u1} G) x (HPow.hPow.{u1, 0, u1} (Set.{u1} G) Nat (Set.{u1} G) (instHPow.{u1, 0} (Set.{u1} G) Nat (Set.NPow.{u1} G (InvOneClass.toOne.{u1} G (DivInvOneMonoid.toInvOneClass.{u1} G (DivisionMonoid.toDivInvOneMonoid.{u1} G (Group.toDivisionMonoid.{u1} G _inst_1)))) (MulOneClass.toMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))))) S (Fintype.card.{u1} G _inst_2))) (fun (a : G) => _inst_3 (Fintype.card.{u1} G _inst_2) a) _inst_2)))
Case conversion may be inaccurate. Consider using '#align group.card_pow_eq_card_pow_card_univ Group.card_pow_eq_card_pow_card_univₓ'. -/
@[to_additive]
theorem card_pow_eq_card_pow_card_univ [∀ k : ℕ, DecidablePred (· ∈ S ^ k)] :
    ∀ k, Fintype.card G ≤ k → Fintype.card ↥(S ^ k) = Fintype.card ↥(S ^ Fintype.card G) :=
  by
  have hG : 0 < Fintype.card G := fintype.card_pos_iff.mpr ⟨1⟩
  by_cases hS : S = ∅
  · refine' fun k hk => Fintype.card_congr _
    rw [hS, empty_pow (ne_of_gt (lt_of_lt_of_le hG hk)), empty_pow (ne_of_gt hG)]
  obtain ⟨a, ha⟩ := Set.nonempty_iff_ne_empty.2 hS
  classical!
  have key : ∀ (a) (s t : Set G), (∀ b : G, b ∈ s → a * b ∈ t) → Fintype.card s ≤ Fintype.card t :=
    by
    refine' fun a s t h => Fintype.card_le_of_injective (fun ⟨b, hb⟩ => ⟨a * b, h b hb⟩) _
    rintro ⟨b, hb⟩ ⟨c, hc⟩ hbc
    exact Subtype.ext (mul_left_cancel (subtype.ext_iff.mp hbc))
  have mono : Monotone (fun n => Fintype.card ↥(S ^ n) : ℕ → ℕ) :=
    monotone_nat_of_le_succ fun n => key a _ _ fun b hb => Set.mul_mem_mul ha hb
  convert
    card_pow_eq_card_pow_card_univ_aux mono (fun n => set_fintype_card_le_univ (S ^ n)) fun n h =>
      le_antisymm (mono (n + 1).le_succ) (key a⁻¹ _ _ _)
  · simp only [[anonymous], Fintype.card_ofFinset]
  replace h : {a} * S ^ n = S ^ (n + 1)
  · refine' Set.eq_of_subset_of_card_le _ (le_trans (ge_of_eq h) _)
    · exact mul_subset_mul (set.singleton_subset_iff.mpr ha) Set.Subset.rfl
    · convert key a (S ^ n) ({a} * S ^ n) fun b hb => Set.mul_mem_mul (Set.mem_singleton a) hb
  rw [pow_succ', ← h, mul_assoc, ← pow_succ', h]
  rintro _ ⟨b, c, hb, hc, rfl⟩
  rwa [set.mem_singleton_iff.mp hb, inv_mul_cancel_left]
#align group.card_pow_eq_card_pow_card_univ Group.card_pow_eq_card_pow_card_univ
#align add_group.card_nsmul_eq_card_nsmul_card_univ AddGroup.card_nsmul_eq_card_nsmul_card_univ

end Group

