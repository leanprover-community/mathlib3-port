/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module order.monotone.odd
! leanprover-community/mathlib commit 09597669f02422ed388036273d8848119699c22f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Monotone.Union
import Mathbin.Algebra.Order.Group.Instances

/-!
# Monotonicity of odd functions

An odd function on a linear ordered additive commutative group `G` is monotone on the whole group
provided that is is monotone on `set.Ici 0`, see `monotone_of_odd_of_monotone_on_nonneg`. We also
prove versions of this lemma for `antitone`, `strict_mono`, and `strict_anti`.
-/


open Set

variable {G H : Type _} [LinearOrderedAddCommGroup G] [OrderedAddCommGroup H]

/- warning: strict_mono_of_odd_strict_mono_on_nonneg -> strictMono_of_odd_strictMono_on_nonneg is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u1}} {H : Type.{u2}} [_inst_1 : LinearOrderedAddCommGroup.{u1} G] [_inst_2 : OrderedAddCommGroup.{u2} H] {f : G -> H}, (forall (x : G), Eq.{succ u2} H (f (Neg.neg.{u1} G (SubNegMonoid.toHasNeg.{u1} G (AddGroup.toSubNegMonoid.{u1} G (AddCommGroup.toAddGroup.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))))) x)) (Neg.neg.{u2} H (SubNegMonoid.toHasNeg.{u2} H (AddGroup.toSubNegMonoid.{u2} H (AddCommGroup.toAddGroup.{u2} H (OrderedAddCommGroup.toAddCommGroup.{u2} H _inst_2)))) (f x))) -> (StrictMonoOn.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f (Set.Ici.{u1} G (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (OfNat.ofNat.{u1} G 0 (OfNat.mk.{u1} G 0 (Zero.zero.{u1} G (AddZeroClass.toHasZero.{u1} G (AddMonoid.toAddZeroClass.{u1} G (SubNegMonoid.toAddMonoid.{u1} G (AddGroup.toSubNegMonoid.{u1} G (AddCommGroup.toAddGroup.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1)))))))))))) -> (StrictMono.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f)
but is expected to have type
  forall {G : Type.{u1}} {H : Type.{u2}} [_inst_1 : LinearOrderedAddCommGroup.{u1} G] [_inst_2 : OrderedAddCommGroup.{u2} H] {f : G -> H}, (forall (x : G), Eq.{succ u2} H (f (Neg.neg.{u1} G (NegZeroClass.toNeg.{u1} G (SubNegZeroMonoid.toNegZeroClass.{u1} G (SubtractionMonoid.toSubNegZeroMonoid.{u1} G (SubtractionCommMonoid.toSubtractionMonoid.{u1} G (AddCommGroup.toDivisionAddCommMonoid.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))))))) x)) (Neg.neg.{u2} H (NegZeroClass.toNeg.{u2} H (SubNegZeroMonoid.toNegZeroClass.{u2} H (SubtractionMonoid.toSubNegZeroMonoid.{u2} H (SubtractionCommMonoid.toSubtractionMonoid.{u2} H (AddCommGroup.toDivisionAddCommMonoid.{u2} H (OrderedAddCommGroup.toAddCommGroup.{u2} H _inst_2)))))) (f x))) -> (StrictMonoOn.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f (Set.Ici.{u1} G (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (OfNat.ofNat.{u1} G 0 (Zero.toOfNat0.{u1} G (NegZeroClass.toZero.{u1} G (SubNegZeroMonoid.toNegZeroClass.{u1} G (SubtractionMonoid.toSubNegZeroMonoid.{u1} G (SubtractionCommMonoid.toSubtractionMonoid.{u1} G (AddCommGroup.toDivisionAddCommMonoid.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))))))))))) -> (StrictMono.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f)
Case conversion may be inaccurate. Consider using '#align strict_mono_of_odd_strict_mono_on_nonneg strictMono_of_odd_strictMono_on_nonnegₓ'. -/
/-- An odd function on a linear ordered additive commutative group is strictly monotone on the whole
group provided that it is strictly monotone on `set.Ici 0`. -/
theorem strictMono_of_odd_strictMono_on_nonneg {f : G → H} (h₁ : ∀ x, f (-x) = -f x)
    (h₂ : StrictMonoOn f (Ici 0)) : StrictMono f :=
  by
  refine' StrictMonoOn.Iic_union_Ici (fun x hx y hy hxy => neg_lt_neg_iff.1 _) h₂
  rw [← h₁, ← h₁]
  exact h₂ (neg_nonneg.2 hy) (neg_nonneg.2 hx) (neg_lt_neg hxy)
#align strict_mono_of_odd_strict_mono_on_nonneg strictMono_of_odd_strictMono_on_nonneg

/- warning: strict_anti_of_odd_strict_anti_on_nonneg -> strictAnti_of_odd_strictAnti_on_nonneg is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u1}} {H : Type.{u2}} [_inst_1 : LinearOrderedAddCommGroup.{u1} G] [_inst_2 : OrderedAddCommGroup.{u2} H] {f : G -> H}, (forall (x : G), Eq.{succ u2} H (f (Neg.neg.{u1} G (SubNegMonoid.toHasNeg.{u1} G (AddGroup.toSubNegMonoid.{u1} G (AddCommGroup.toAddGroup.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))))) x)) (Neg.neg.{u2} H (SubNegMonoid.toHasNeg.{u2} H (AddGroup.toSubNegMonoid.{u2} H (AddCommGroup.toAddGroup.{u2} H (OrderedAddCommGroup.toAddCommGroup.{u2} H _inst_2)))) (f x))) -> (StrictAntiOn.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f (Set.Ici.{u1} G (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (OfNat.ofNat.{u1} G 0 (OfNat.mk.{u1} G 0 (Zero.zero.{u1} G (AddZeroClass.toHasZero.{u1} G (AddMonoid.toAddZeroClass.{u1} G (SubNegMonoid.toAddMonoid.{u1} G (AddGroup.toSubNegMonoid.{u1} G (AddCommGroup.toAddGroup.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1)))))))))))) -> (StrictAnti.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f)
but is expected to have type
  forall {G : Type.{u1}} {H : Type.{u2}} [_inst_1 : LinearOrderedAddCommGroup.{u1} G] [_inst_2 : OrderedAddCommGroup.{u2} H] {f : G -> H}, (forall (x : G), Eq.{succ u2} H (f (Neg.neg.{u1} G (NegZeroClass.toNeg.{u1} G (SubNegZeroMonoid.toNegZeroClass.{u1} G (SubtractionMonoid.toSubNegZeroMonoid.{u1} G (SubtractionCommMonoid.toSubtractionMonoid.{u1} G (AddCommGroup.toDivisionAddCommMonoid.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))))))) x)) (Neg.neg.{u2} H (NegZeroClass.toNeg.{u2} H (SubNegZeroMonoid.toNegZeroClass.{u2} H (SubtractionMonoid.toSubNegZeroMonoid.{u2} H (SubtractionCommMonoid.toSubtractionMonoid.{u2} H (AddCommGroup.toDivisionAddCommMonoid.{u2} H (OrderedAddCommGroup.toAddCommGroup.{u2} H _inst_2)))))) (f x))) -> (StrictAntiOn.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f (Set.Ici.{u1} G (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (OfNat.ofNat.{u1} G 0 (Zero.toOfNat0.{u1} G (NegZeroClass.toZero.{u1} G (SubNegZeroMonoid.toNegZeroClass.{u1} G (SubtractionMonoid.toSubNegZeroMonoid.{u1} G (SubtractionCommMonoid.toSubtractionMonoid.{u1} G (AddCommGroup.toDivisionAddCommMonoid.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))))))))))) -> (StrictAnti.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f)
Case conversion may be inaccurate. Consider using '#align strict_anti_of_odd_strict_anti_on_nonneg strictAnti_of_odd_strictAnti_on_nonnegₓ'. -/
/-- An odd function on a linear ordered additive commutative group is strictly antitone on the whole
group provided that it is strictly antitone on `set.Ici 0`. -/
theorem strictAnti_of_odd_strictAnti_on_nonneg {f : G → H} (h₁ : ∀ x, f (-x) = -f x)
    (h₂ : StrictAntiOn f (Ici 0)) : StrictAnti f :=
  @strictMono_of_odd_strictMono_on_nonneg G Hᵒᵈ _ _ _ h₁ h₂
#align strict_anti_of_odd_strict_anti_on_nonneg strictAnti_of_odd_strictAnti_on_nonneg

/- warning: monotone_of_odd_of_monotone_on_nonneg -> monotone_of_odd_of_monotone_on_nonneg is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u1}} {H : Type.{u2}} [_inst_1 : LinearOrderedAddCommGroup.{u1} G] [_inst_2 : OrderedAddCommGroup.{u2} H] {f : G -> H}, (forall (x : G), Eq.{succ u2} H (f (Neg.neg.{u1} G (SubNegMonoid.toHasNeg.{u1} G (AddGroup.toSubNegMonoid.{u1} G (AddCommGroup.toAddGroup.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))))) x)) (Neg.neg.{u2} H (SubNegMonoid.toHasNeg.{u2} H (AddGroup.toSubNegMonoid.{u2} H (AddCommGroup.toAddGroup.{u2} H (OrderedAddCommGroup.toAddCommGroup.{u2} H _inst_2)))) (f x))) -> (MonotoneOn.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f (Set.Ici.{u1} G (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (OfNat.ofNat.{u1} G 0 (OfNat.mk.{u1} G 0 (Zero.zero.{u1} G (AddZeroClass.toHasZero.{u1} G (AddMonoid.toAddZeroClass.{u1} G (SubNegMonoid.toAddMonoid.{u1} G (AddGroup.toSubNegMonoid.{u1} G (AddCommGroup.toAddGroup.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1)))))))))))) -> (Monotone.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f)
but is expected to have type
  forall {G : Type.{u1}} {H : Type.{u2}} [_inst_1 : LinearOrderedAddCommGroup.{u1} G] [_inst_2 : OrderedAddCommGroup.{u2} H] {f : G -> H}, (forall (x : G), Eq.{succ u2} H (f (Neg.neg.{u1} G (NegZeroClass.toNeg.{u1} G (SubNegZeroMonoid.toNegZeroClass.{u1} G (SubtractionMonoid.toSubNegZeroMonoid.{u1} G (SubtractionCommMonoid.toSubtractionMonoid.{u1} G (AddCommGroup.toDivisionAddCommMonoid.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))))))) x)) (Neg.neg.{u2} H (NegZeroClass.toNeg.{u2} H (SubNegZeroMonoid.toNegZeroClass.{u2} H (SubtractionMonoid.toSubNegZeroMonoid.{u2} H (SubtractionCommMonoid.toSubtractionMonoid.{u2} H (AddCommGroup.toDivisionAddCommMonoid.{u2} H (OrderedAddCommGroup.toAddCommGroup.{u2} H _inst_2)))))) (f x))) -> (MonotoneOn.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f (Set.Ici.{u1} G (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (OfNat.ofNat.{u1} G 0 (Zero.toOfNat0.{u1} G (NegZeroClass.toZero.{u1} G (SubNegZeroMonoid.toNegZeroClass.{u1} G (SubtractionMonoid.toSubNegZeroMonoid.{u1} G (SubtractionCommMonoid.toSubtractionMonoid.{u1} G (AddCommGroup.toDivisionAddCommMonoid.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))))))))))) -> (Monotone.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f)
Case conversion may be inaccurate. Consider using '#align monotone_of_odd_of_monotone_on_nonneg monotone_of_odd_of_monotone_on_nonnegₓ'. -/
/-- An odd function on a linear ordered additive commutative group is monotone on the whole group
provided that it is monotone on `set.Ici 0`. -/
theorem monotone_of_odd_of_monotone_on_nonneg {f : G → H} (h₁ : ∀ x, f (-x) = -f x)
    (h₂ : MonotoneOn f (Ici 0)) : Monotone f :=
  by
  refine' MonotoneOn.Iic_union_Ici (fun x hx y hy hxy => neg_le_neg_iff.1 _) h₂
  rw [← h₁, ← h₁]
  exact h₂ (neg_nonneg.2 hy) (neg_nonneg.2 hx) (neg_le_neg hxy)
#align monotone_of_odd_of_monotone_on_nonneg monotone_of_odd_of_monotone_on_nonneg

/- warning: antitone_of_odd_of_monotone_on_nonneg -> antitone_of_odd_of_monotone_on_nonneg is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u1}} {H : Type.{u2}} [_inst_1 : LinearOrderedAddCommGroup.{u1} G] [_inst_2 : OrderedAddCommGroup.{u2} H] {f : G -> H}, (forall (x : G), Eq.{succ u2} H (f (Neg.neg.{u1} G (SubNegMonoid.toHasNeg.{u1} G (AddGroup.toSubNegMonoid.{u1} G (AddCommGroup.toAddGroup.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))))) x)) (Neg.neg.{u2} H (SubNegMonoid.toHasNeg.{u2} H (AddGroup.toSubNegMonoid.{u2} H (AddCommGroup.toAddGroup.{u2} H (OrderedAddCommGroup.toAddCommGroup.{u2} H _inst_2)))) (f x))) -> (AntitoneOn.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f (Set.Ici.{u1} G (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (OfNat.ofNat.{u1} G 0 (OfNat.mk.{u1} G 0 (Zero.zero.{u1} G (AddZeroClass.toHasZero.{u1} G (AddMonoid.toAddZeroClass.{u1} G (SubNegMonoid.toAddMonoid.{u1} G (AddGroup.toSubNegMonoid.{u1} G (AddCommGroup.toAddGroup.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1)))))))))))) -> (Antitone.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f)
but is expected to have type
  forall {G : Type.{u1}} {H : Type.{u2}} [_inst_1 : LinearOrderedAddCommGroup.{u1} G] [_inst_2 : OrderedAddCommGroup.{u2} H] {f : G -> H}, (forall (x : G), Eq.{succ u2} H (f (Neg.neg.{u1} G (NegZeroClass.toNeg.{u1} G (SubNegZeroMonoid.toNegZeroClass.{u1} G (SubtractionMonoid.toSubNegZeroMonoid.{u1} G (SubtractionCommMonoid.toSubtractionMonoid.{u1} G (AddCommGroup.toDivisionAddCommMonoid.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))))))) x)) (Neg.neg.{u2} H (NegZeroClass.toNeg.{u2} H (SubNegZeroMonoid.toNegZeroClass.{u2} H (SubtractionMonoid.toSubNegZeroMonoid.{u2} H (SubtractionCommMonoid.toSubtractionMonoid.{u2} H (AddCommGroup.toDivisionAddCommMonoid.{u2} H (OrderedAddCommGroup.toAddCommGroup.{u2} H _inst_2)))))) (f x))) -> (AntitoneOn.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f (Set.Ici.{u1} G (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (OfNat.ofNat.{u1} G 0 (Zero.toOfNat0.{u1} G (NegZeroClass.toZero.{u1} G (SubNegZeroMonoid.toNegZeroClass.{u1} G (SubtractionMonoid.toSubNegZeroMonoid.{u1} G (SubtractionCommMonoid.toSubtractionMonoid.{u1} G (AddCommGroup.toDivisionAddCommMonoid.{u1} G (OrderedAddCommGroup.toAddCommGroup.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))))))))))) -> (Antitone.{u1, u2} G H (PartialOrder.toPreorder.{u1} G (OrderedAddCommGroup.toPartialOrder.{u1} G (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} G _inst_1))) (PartialOrder.toPreorder.{u2} H (OrderedAddCommGroup.toPartialOrder.{u2} H _inst_2)) f)
Case conversion may be inaccurate. Consider using '#align antitone_of_odd_of_monotone_on_nonneg antitone_of_odd_of_monotone_on_nonnegₓ'. -/
/-- An odd function on a linear ordered additive commutative group is antitone on the whole group
provided that it is monotone on `set.Ici 0`. -/
theorem antitone_of_odd_of_monotone_on_nonneg {f : G → H} (h₁ : ∀ x, f (-x) = -f x)
    (h₂ : AntitoneOn f (Ici 0)) : Antitone f :=
  @monotone_of_odd_of_monotone_on_nonneg G Hᵒᵈ _ _ _ h₁ h₂
#align antitone_of_odd_of_monotone_on_nonneg antitone_of_odd_of_monotone_on_nonneg

