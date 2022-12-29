/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module algebra.order.positive.field
! leanprover-community/mathlib commit 422e70f7ce183d2900c586a8cda8381e788a0c62
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Field.Basic
import Mathbin.Algebra.Order.Positive.Ring

/-!
# Algebraic structures on the set of positive numbers

In this file we prove that the set of positive elements of a linear ordered field is a linear
ordered commutative group.
-/


variable {K : Type _} [LinearOrderedField K]

namespace Positive

instance : Inv { x : K // 0 < x } :=
  ⟨fun x => ⟨x⁻¹, inv_pos.2 x.2⟩⟩

/- warning: positive.coe_inv -> Positive.coe_inv is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : LinearOrderedField.{u1} K] (x : Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)), Eq.{succ u1} K ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (coeBase.{succ u1, succ u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (coeSubtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x))))) (Inv.inv.{u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) (Positive.Subtype.hasInv.{u1} K _inst_1) x)) (Inv.inv.{u1} K (DivInvMonoid.toHasInv.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K (LinearOrderedField.toField.{u1} K _inst_1)))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (coeBase.{succ u1, succ u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (coeSubtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x))))) x))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : LinearOrderedField.{u1} K] (x : Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (StrictOrderedRing.toPartialOrder.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))) (OfNat.ofNat.{u1} K 0 (Zero.toOfNat0.{u1} K (CommMonoidWithZero.toZero.{u1} K (CommGroupWithZero.toCommMonoidWithZero.{u1} K (Semifield.toCommGroupWithZero.{u1} K (LinearOrderedSemifield.toSemifield.{u1} K (LinearOrderedField.toLinearOrderedSemifield.{u1} K _inst_1))))))) x)), Eq.{succ u1} K (Subtype.val.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (StrictOrderedRing.toPartialOrder.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))) (OfNat.ofNat.{u1} K 0 (Zero.toOfNat0.{u1} K (CommMonoidWithZero.toZero.{u1} K (CommGroupWithZero.toCommMonoidWithZero.{u1} K (Semifield.toCommGroupWithZero.{u1} K (LinearOrderedSemifield.toSemifield.{u1} K (LinearOrderedField.toLinearOrderedSemifield.{u1} K _inst_1))))))) x) (Inv.inv.{u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (StrictOrderedRing.toPartialOrder.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))) (OfNat.ofNat.{u1} K 0 (Zero.toOfNat0.{u1} K (CommMonoidWithZero.toZero.{u1} K (CommGroupWithZero.toCommMonoidWithZero.{u1} K (Semifield.toCommGroupWithZero.{u1} K (LinearOrderedSemifield.toSemifield.{u1} K (LinearOrderedField.toLinearOrderedSemifield.{u1} K _inst_1))))))) x)) (Positive.Subtype.inv.{u1} K _inst_1) x)) (Inv.inv.{u1} K (LinearOrderedField.toInv.{u1} K _inst_1) (Subtype.val.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (StrictOrderedRing.toPartialOrder.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))) (OfNat.ofNat.{u1} K 0 (Zero.toOfNat0.{u1} K (CommMonoidWithZero.toZero.{u1} K (CommGroupWithZero.toCommMonoidWithZero.{u1} K (Semifield.toCommGroupWithZero.{u1} K (LinearOrderedSemifield.toSemifield.{u1} K (LinearOrderedField.toLinearOrderedSemifield.{u1} K _inst_1))))))) x) x))
Case conversion may be inaccurate. Consider using '#align positive.coe_inv Positive.coe_invₓ'. -/
@[simp]
theorem coe_inv (x : { x : K // 0 < x }) : ↑x⁻¹ = (x⁻¹ : K) :=
  rfl
#align positive.coe_inv Positive.coe_inv

instance : Pow { x : K // 0 < x } ℤ :=
  ⟨fun x n => ⟨x ^ n, zpow_pos_of_pos x.2 _⟩⟩

/- warning: positive.coe_zpow -> Positive.coe_zpow is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : LinearOrderedField.{u1} K] (x : Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) (n : Int), Eq.{succ u1} K ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (coeBase.{succ u1, succ u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (coeSubtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x))))) (HPow.hPow.{u1, 0, u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) Int (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) (instHPow.{u1, 0} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) Int (Positive.Int.hasPow.{u1} K _inst_1)) x n)) (HPow.hPow.{u1, 0, u1} K Int K (instHPow.{u1, 0} K Int (DivInvMonoid.Pow.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K (LinearOrderedField.toField.{u1} K _inst_1))))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (coeBase.{succ u1, succ u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x)) K (coeSubtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (OrderedAddCommGroup.toPartialOrder.{u1} K (StrictOrderedRing.toOrderedAddCommGroup.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1))))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (StrictOrderedRing.toRing.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))))))))) x))))) x) n)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : LinearOrderedField.{u1} K] (x : Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (StrictOrderedRing.toPartialOrder.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))) (OfNat.ofNat.{u1} K 0 (Zero.toOfNat0.{u1} K (CommMonoidWithZero.toZero.{u1} K (CommGroupWithZero.toCommMonoidWithZero.{u1} K (Semifield.toCommGroupWithZero.{u1} K (LinearOrderedSemifield.toSemifield.{u1} K (LinearOrderedField.toLinearOrderedSemifield.{u1} K _inst_1))))))) x)) (n : Int), Eq.{succ u1} K (Subtype.val.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (StrictOrderedRing.toPartialOrder.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))) (OfNat.ofNat.{u1} K 0 (Zero.toOfNat0.{u1} K (CommMonoidWithZero.toZero.{u1} K (CommGroupWithZero.toCommMonoidWithZero.{u1} K (Semifield.toCommGroupWithZero.{u1} K (LinearOrderedSemifield.toSemifield.{u1} K (LinearOrderedField.toLinearOrderedSemifield.{u1} K _inst_1))))))) x) (HPow.hPow.{u1, 0, u1} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (StrictOrderedRing.toPartialOrder.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))) (OfNat.ofNat.{u1} K 0 (Zero.toOfNat0.{u1} K (CommMonoidWithZero.toZero.{u1} K (CommGroupWithZero.toCommMonoidWithZero.{u1} K (Semifield.toCommGroupWithZero.{u1} K (LinearOrderedSemifield.toSemifield.{u1} K (LinearOrderedField.toLinearOrderedSemifield.{u1} K _inst_1))))))) x)) Int (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (StrictOrderedRing.toPartialOrder.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))) (OfNat.ofNat.{u1} K 0 (Zero.toOfNat0.{u1} K (CommMonoidWithZero.toZero.{u1} K (CommGroupWithZero.toCommMonoidWithZero.{u1} K (Semifield.toCommGroupWithZero.{u1} K (LinearOrderedSemifield.toSemifield.{u1} K (LinearOrderedField.toLinearOrderedSemifield.{u1} K _inst_1))))))) x)) (instHPow.{u1, 0} (Subtype.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (StrictOrderedRing.toPartialOrder.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))) (OfNat.ofNat.{u1} K 0 (Zero.toOfNat0.{u1} K (CommMonoidWithZero.toZero.{u1} K (CommGroupWithZero.toCommMonoidWithZero.{u1} K (Semifield.toCommGroupWithZero.{u1} K (LinearOrderedSemifield.toSemifield.{u1} K (LinearOrderedField.toLinearOrderedSemifield.{u1} K _inst_1))))))) x)) Int (Positive.instPowSubtypeLtToLTToPreorderToPartialOrderToStrictOrderedRingToLinearOrderedRingToLinearOrderedCommRingOfNatToOfNat0ToZeroToCommMonoidWithZeroToCommGroupWithZeroToSemifieldToLinearOrderedSemifieldInt.{u1} K _inst_1)) x n)) (HPow.hPow.{u1, 0, u1} K Int K (instHPow.{u1, 0} K Int (DivInvMonoid.Pow.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K (LinearOrderedField.toField.{u1} K _inst_1))))) (Subtype.val.{succ u1} K (fun (x : K) => LT.lt.{u1} K (Preorder.toLT.{u1} K (PartialOrder.toPreorder.{u1} K (StrictOrderedRing.toPartialOrder.{u1} K (LinearOrderedRing.toStrictOrderedRing.{u1} K (LinearOrderedCommRing.toLinearOrderedRing.{u1} K (LinearOrderedField.toLinearOrderedCommRing.{u1} K _inst_1)))))) (OfNat.ofNat.{u1} K 0 (Zero.toOfNat0.{u1} K (CommMonoidWithZero.toZero.{u1} K (CommGroupWithZero.toCommMonoidWithZero.{u1} K (Semifield.toCommGroupWithZero.{u1} K (LinearOrderedSemifield.toSemifield.{u1} K (LinearOrderedField.toLinearOrderedSemifield.{u1} K _inst_1))))))) x) x) n)
Case conversion may be inaccurate. Consider using '#align positive.coe_zpow Positive.coe_zpowₓ'. -/
@[simp]
theorem coe_zpow (x : { x : K // 0 < x }) (n : ℤ) : ↑(x ^ n) = (x ^ n : K) :=
  rfl
#align positive.coe_zpow Positive.coe_zpow

instance : LinearOrderedCommGroup { x : K // 0 < x } :=
  { Positive.Subtype.hasInv, Positive.Subtype.linearOrderedCancelCommMonoid with
    mul_left_inv := fun a => Subtype.ext <| inv_mul_cancel a.2.ne' }

end Positive

