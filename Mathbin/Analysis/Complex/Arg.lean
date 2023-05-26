/-
Copyright (c) 2022 Eric Rodriguez. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Rodriguez

! This file was ported from Lean 3 source module analysis.complex.arg
! leanprover-community/mathlib commit 17ef379e997badd73e5eabb4d38f11919ab3c4b3
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.InnerProductSpace.Basic
import Mathbin.Analysis.SpecialFunctions.Complex.Arg

/-!
# Rays in the complex numbers

This file links the definition `same_ray ℝ x y` with the equality of arguments of complex numbers,
the usual way this is considered.

## Main statements

* `complex.same_ray_iff` : Two complex numbers are on the same ray iff one of them is zero, or they
  have the same argument.
* `complex.abs_add_eq/complex.abs_sub_eq`: If two non zero complex numbers have different argument,
  then the triangle inequality becomes strict.

-/


variable {x y : ℂ}

namespace Complex

/- warning: complex.same_ray_iff -> Complex.sameRay_iff is a dubious translation:
lean 3 declaration is
  forall {x : Complex} {y : Complex}, Iff (SameRay.{0, 0} Real Real.strictOrderedCommSemiring Complex (AddCommGroup.toAddCommMonoid.{0} Complex Complex.addCommGroup) (Complex.module.{0} Real (StrictOrderedSemiring.toSemiring.{0} Real (StrictOrderedCommSemiring.toStrictOrderedSemiring.{0} Real Real.strictOrderedCommSemiring)) Real.module) x y) (Or (Eq.{1} Complex x (OfNat.ofNat.{0} Complex 0 (OfNat.mk.{0} Complex 0 (Zero.zero.{0} Complex Complex.hasZero)))) (Or (Eq.{1} Complex y (OfNat.ofNat.{0} Complex 0 (OfNat.mk.{0} Complex 0 (Zero.zero.{0} Complex Complex.hasZero)))) (Eq.{1} Real (Complex.arg x) (Complex.arg y))))
but is expected to have type
  forall {x : Complex} {y : Complex}, Iff (SameRay.{0, 0} Real Real.strictOrderedCommSemiring Complex (NonUnitalNonAssocSemiring.toAddCommMonoid.{0} Complex (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{0} Complex (NonAssocRing.toNonUnitalNonAssocRing.{0} Complex (Ring.toNonAssocRing.{0} Complex Complex.instRingComplex)))) (Complex.instModuleComplexToAddCommMonoidToNonUnitalNonAssocSemiringToNonUnitalNonAssocRingToNonAssocRingInstRingComplex.{0} Real (StrictOrderedSemiring.toSemiring.{0} Real (StrictOrderedCommSemiring.toStrictOrderedSemiring.{0} Real Real.strictOrderedCommSemiring)) (NormedSpace.toModule.{0, 0} Real Real Real.normedField (NonUnitalSeminormedRing.toSeminormedAddCommGroup.{0} Real (NonUnitalNormedRing.toNonUnitalSeminormedRing.{0} Real (NormedRing.toNonUnitalNormedRing.{0} Real (NormedCommRing.toNormedRing.{0} Real Real.normedCommRing)))) (InnerProductSpace.toNormedSpace.{0, 0} Real Real Real.isROrC Real.normedAddCommGroup (IsROrC.innerProductSpace.{0} Real Real.isROrC)))) x y) (Or (Eq.{1} Complex x (OfNat.ofNat.{0} Complex 0 (Zero.toOfNat0.{0} Complex Complex.instZeroComplex))) (Or (Eq.{1} Complex y (OfNat.ofNat.{0} Complex 0 (Zero.toOfNat0.{0} Complex Complex.instZeroComplex))) (Eq.{1} Real (Complex.arg x) (Complex.arg y))))
Case conversion may be inaccurate. Consider using '#align complex.same_ray_iff Complex.sameRay_iffₓ'. -/
theorem sameRay_iff : SameRay ℝ x y ↔ x = 0 ∨ y = 0 ∨ x.arg = y.arg :=
  by
  rcases eq_or_ne x 0 with (rfl | hx)
  · simp
  rcases eq_or_ne y 0 with (rfl | hy)
  · simp
  simp only [hx, hy, false_or_iff, sameRay_iff_norm_smul_eq, arg_eq_arg_iff hx hy]
  field_simp [hx, hy]
  rw [mul_comm, eq_comm]
#align complex.same_ray_iff Complex.sameRay_iff

/- warning: complex.same_ray_iff_arg_div_eq_zero -> Complex.sameRay_iff_arg_div_eq_zero is a dubious translation:
lean 3 declaration is
  forall {x : Complex} {y : Complex}, Iff (SameRay.{0, 0} Real Real.strictOrderedCommSemiring Complex (AddCommGroup.toAddCommMonoid.{0} Complex Complex.addCommGroup) (Complex.module.{0} Real (StrictOrderedSemiring.toSemiring.{0} Real (StrictOrderedCommSemiring.toStrictOrderedSemiring.{0} Real Real.strictOrderedCommSemiring)) Real.module) x y) (Eq.{1} Real (Complex.arg (HDiv.hDiv.{0, 0, 0} Complex Complex Complex (instHDiv.{0} Complex (DivInvMonoid.toHasDiv.{0} Complex (DivisionRing.toDivInvMonoid.{0} Complex (NormedDivisionRing.toDivisionRing.{0} Complex (NormedField.toNormedDivisionRing.{0} Complex Complex.normedField))))) x y)) (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))))
but is expected to have type
  forall {x : Complex} {y : Complex}, Iff (SameRay.{0, 0} Real Real.strictOrderedCommSemiring Complex (NonUnitalNonAssocSemiring.toAddCommMonoid.{0} Complex (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{0} Complex (NonAssocRing.toNonUnitalNonAssocRing.{0} Complex (Ring.toNonAssocRing.{0} Complex Complex.instRingComplex)))) (Complex.instModuleComplexToAddCommMonoidToNonUnitalNonAssocSemiringToNonUnitalNonAssocRingToNonAssocRingInstRingComplex.{0} Real (StrictOrderedSemiring.toSemiring.{0} Real (StrictOrderedCommSemiring.toStrictOrderedSemiring.{0} Real Real.strictOrderedCommSemiring)) (NormedSpace.toModule.{0, 0} Real Real Real.normedField (NonUnitalSeminormedRing.toSeminormedAddCommGroup.{0} Real (NonUnitalNormedRing.toNonUnitalSeminormedRing.{0} Real (NormedRing.toNonUnitalNormedRing.{0} Real (NormedCommRing.toNormedRing.{0} Real Real.normedCommRing)))) (InnerProductSpace.toNormedSpace.{0, 0} Real Real Real.isROrC Real.normedAddCommGroup (IsROrC.innerProductSpace.{0} Real Real.isROrC)))) x y) (Eq.{1} Real (Complex.arg (HDiv.hDiv.{0, 0, 0} Complex Complex Complex (instHDiv.{0} Complex (Field.toDiv.{0} Complex Complex.instFieldComplex)) x y)) (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)))
Case conversion may be inaccurate. Consider using '#align complex.same_ray_iff_arg_div_eq_zero Complex.sameRay_iff_arg_div_eq_zeroₓ'. -/
theorem sameRay_iff_arg_div_eq_zero : SameRay ℝ x y ↔ arg (x / y) = 0 :=
  by
  rw [← Real.Angle.toReal_zero, ← arg_coe_angle_eq_iff_eq_to_real, same_ray_iff]
  by_cases hx : x = 0; · simp [hx]
  by_cases hy : y = 0; · simp [hy]
  simp [hx, hy, arg_div_coe_angle, sub_eq_zero]
#align complex.same_ray_iff_arg_div_eq_zero Complex.sameRay_iff_arg_div_eq_zero

/- warning: complex.abs_add_eq_iff -> Complex.abs_add_eq_iff is a dubious translation:
lean 3 declaration is
  forall {x : Complex} {y : Complex}, Iff (Eq.{1} Real (coeFn.{1, 1} (AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) (fun (f : AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) => Complex -> Real) (AbsoluteValue.hasCoeToFun.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) Complex.abs (HAdd.hAdd.{0, 0, 0} Complex Complex Complex (instHAdd.{0} Complex Complex.hasAdd) x y)) (HAdd.hAdd.{0, 0, 0} Real Real Real (instHAdd.{0} Real Real.hasAdd) (coeFn.{1, 1} (AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) (fun (f : AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) => Complex -> Real) (AbsoluteValue.hasCoeToFun.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) Complex.abs x) (coeFn.{1, 1} (AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) (fun (f : AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) => Complex -> Real) (AbsoluteValue.hasCoeToFun.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) Complex.abs y))) (Or (Eq.{1} Complex x (OfNat.ofNat.{0} Complex 0 (OfNat.mk.{0} Complex 0 (Zero.zero.{0} Complex Complex.hasZero)))) (Or (Eq.{1} Complex y (OfNat.ofNat.{0} Complex 0 (OfNat.mk.{0} Complex 0 (Zero.zero.{0} Complex Complex.hasZero)))) (Eq.{1} Real (Complex.arg x) (Complex.arg y))))
but is expected to have type
  forall {x : Complex} {y : Complex}, Iff (Eq.{1} ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) (HAdd.hAdd.{0, 0, 0} Complex Complex Complex (instHAdd.{0} Complex Complex.instAddComplex) x y)) (FunLike.coe.{1, 1, 1} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex (fun (f : Complex) => (fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) f) (SubadditiveHomClass.toFunLike.{0, 0, 0} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex Real (Distrib.toAdd.{0} Complex (NonUnitalNonAssocSemiring.toDistrib.{0} Complex (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Complex (Semiring.toNonAssocSemiring.{0} Complex Complex.instSemiringComplex)))) (Distrib.toAdd.{0} Real (NonUnitalNonAssocSemiring.toDistrib.{0} Real (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Real (Semiring.toNonAssocSemiring.{0} Real (OrderedSemiring.toSemiring.{0} Real Real.orderedSemiring))))) (Preorder.toLE.{0} Real (PartialOrder.toPreorder.{0} Real (OrderedSemiring.toPartialOrder.{0} Real Real.orderedSemiring))) (AbsoluteValue.subadditiveHomClass.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring)) Complex.abs (HAdd.hAdd.{0, 0, 0} Complex Complex Complex (instHAdd.{0} Complex Complex.instAddComplex) x y)) (HAdd.hAdd.{0, 0, 0} ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) x) ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) y) ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) x) (instHAdd.{0} ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) x) Real.instAddReal) (FunLike.coe.{1, 1, 1} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex (fun (f : Complex) => (fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) f) (SubadditiveHomClass.toFunLike.{0, 0, 0} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex Real (Distrib.toAdd.{0} Complex (NonUnitalNonAssocSemiring.toDistrib.{0} Complex (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Complex (Semiring.toNonAssocSemiring.{0} Complex Complex.instSemiringComplex)))) (Distrib.toAdd.{0} Real (NonUnitalNonAssocSemiring.toDistrib.{0} Real (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Real (Semiring.toNonAssocSemiring.{0} Real (OrderedSemiring.toSemiring.{0} Real Real.orderedSemiring))))) (Preorder.toLE.{0} Real (PartialOrder.toPreorder.{0} Real (OrderedSemiring.toPartialOrder.{0} Real Real.orderedSemiring))) (AbsoluteValue.subadditiveHomClass.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring)) Complex.abs x) (FunLike.coe.{1, 1, 1} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex (fun (f : Complex) => (fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) f) (SubadditiveHomClass.toFunLike.{0, 0, 0} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex Real (Distrib.toAdd.{0} Complex (NonUnitalNonAssocSemiring.toDistrib.{0} Complex (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Complex (Semiring.toNonAssocSemiring.{0} Complex Complex.instSemiringComplex)))) (Distrib.toAdd.{0} Real (NonUnitalNonAssocSemiring.toDistrib.{0} Real (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Real (Semiring.toNonAssocSemiring.{0} Real (OrderedSemiring.toSemiring.{0} Real Real.orderedSemiring))))) (Preorder.toLE.{0} Real (PartialOrder.toPreorder.{0} Real (OrderedSemiring.toPartialOrder.{0} Real Real.orderedSemiring))) (AbsoluteValue.subadditiveHomClass.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring)) Complex.abs y))) (Or (Eq.{1} Complex x (OfNat.ofNat.{0} Complex 0 (Zero.toOfNat0.{0} Complex Complex.instZeroComplex))) (Or (Eq.{1} Complex y (OfNat.ofNat.{0} Complex 0 (Zero.toOfNat0.{0} Complex Complex.instZeroComplex))) (Eq.{1} Real (Complex.arg x) (Complex.arg y))))
Case conversion may be inaccurate. Consider using '#align complex.abs_add_eq_iff Complex.abs_add_eq_iffₓ'. -/
theorem abs_add_eq_iff : (x + y).abs = x.abs + y.abs ↔ x = 0 ∨ y = 0 ∨ x.arg = y.arg :=
  sameRay_iff_norm_add.symm.trans sameRay_iff
#align complex.abs_add_eq_iff Complex.abs_add_eq_iff

/- warning: complex.abs_sub_eq_iff -> Complex.abs_sub_eq_iff is a dubious translation:
lean 3 declaration is
  forall {x : Complex} {y : Complex}, Iff (Eq.{1} Real (coeFn.{1, 1} (AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) (fun (f : AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) => Complex -> Real) (AbsoluteValue.hasCoeToFun.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) Complex.abs (HSub.hSub.{0, 0, 0} Complex Complex Complex (instHSub.{0} Complex Complex.hasSub) x y)) (Abs.abs.{0} Real (Neg.toHasAbs.{0} Real Real.hasNeg Real.hasSup) (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (coeFn.{1, 1} (AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) (fun (f : AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) => Complex -> Real) (AbsoluteValue.hasCoeToFun.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) Complex.abs x) (coeFn.{1, 1} (AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) (fun (f : AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) => Complex -> Real) (AbsoluteValue.hasCoeToFun.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) Complex.abs y)))) (Or (Eq.{1} Complex x (OfNat.ofNat.{0} Complex 0 (OfNat.mk.{0} Complex 0 (Zero.zero.{0} Complex Complex.hasZero)))) (Or (Eq.{1} Complex y (OfNat.ofNat.{0} Complex 0 (OfNat.mk.{0} Complex 0 (Zero.zero.{0} Complex Complex.hasZero)))) (Eq.{1} Real (Complex.arg x) (Complex.arg y))))
but is expected to have type
  forall {x : Complex} {y : Complex}, Iff (Eq.{1} ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) (HSub.hSub.{0, 0, 0} Complex Complex Complex (instHSub.{0} Complex Complex.instSubComplex) x y)) (FunLike.coe.{1, 1, 1} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex (fun (f : Complex) => (fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) f) (SubadditiveHomClass.toFunLike.{0, 0, 0} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex Real (Distrib.toAdd.{0} Complex (NonUnitalNonAssocSemiring.toDistrib.{0} Complex (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Complex (Semiring.toNonAssocSemiring.{0} Complex Complex.instSemiringComplex)))) (Distrib.toAdd.{0} Real (NonUnitalNonAssocSemiring.toDistrib.{0} Real (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Real (Semiring.toNonAssocSemiring.{0} Real (OrderedSemiring.toSemiring.{0} Real Real.orderedSemiring))))) (Preorder.toLE.{0} Real (PartialOrder.toPreorder.{0} Real (OrderedSemiring.toPartialOrder.{0} Real Real.orderedSemiring))) (AbsoluteValue.subadditiveHomClass.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring)) Complex.abs (HSub.hSub.{0, 0, 0} Complex Complex Complex (instHSub.{0} Complex Complex.instSubComplex) x y)) (Abs.abs.{0} ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) x) (Neg.toHasAbs.{0} ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) x) Real.instNegReal Real.instSupReal) (HSub.hSub.{0, 0, 0} ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) x) ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) y) ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) x) (instHSub.{0} ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) x) Real.instSubReal) (FunLike.coe.{1, 1, 1} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex (fun (f : Complex) => (fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) f) (SubadditiveHomClass.toFunLike.{0, 0, 0} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex Real (Distrib.toAdd.{0} Complex (NonUnitalNonAssocSemiring.toDistrib.{0} Complex (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Complex (Semiring.toNonAssocSemiring.{0} Complex Complex.instSemiringComplex)))) (Distrib.toAdd.{0} Real (NonUnitalNonAssocSemiring.toDistrib.{0} Real (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Real (Semiring.toNonAssocSemiring.{0} Real (OrderedSemiring.toSemiring.{0} Real Real.orderedSemiring))))) (Preorder.toLE.{0} Real (PartialOrder.toPreorder.{0} Real (OrderedSemiring.toPartialOrder.{0} Real Real.orderedSemiring))) (AbsoluteValue.subadditiveHomClass.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring)) Complex.abs x) (FunLike.coe.{1, 1, 1} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex (fun (f : Complex) => (fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) f) (SubadditiveHomClass.toFunLike.{0, 0, 0} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex Real (Distrib.toAdd.{0} Complex (NonUnitalNonAssocSemiring.toDistrib.{0} Complex (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Complex (Semiring.toNonAssocSemiring.{0} Complex Complex.instSemiringComplex)))) (Distrib.toAdd.{0} Real (NonUnitalNonAssocSemiring.toDistrib.{0} Real (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Real (Semiring.toNonAssocSemiring.{0} Real (OrderedSemiring.toSemiring.{0} Real Real.orderedSemiring))))) (Preorder.toLE.{0} Real (PartialOrder.toPreorder.{0} Real (OrderedSemiring.toPartialOrder.{0} Real Real.orderedSemiring))) (AbsoluteValue.subadditiveHomClass.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring)) Complex.abs y)))) (Or (Eq.{1} Complex x (OfNat.ofNat.{0} Complex 0 (Zero.toOfNat0.{0} Complex Complex.instZeroComplex))) (Or (Eq.{1} Complex y (OfNat.ofNat.{0} Complex 0 (Zero.toOfNat0.{0} Complex Complex.instZeroComplex))) (Eq.{1} Real (Complex.arg x) (Complex.arg y))))
Case conversion may be inaccurate. Consider using '#align complex.abs_sub_eq_iff Complex.abs_sub_eq_iffₓ'. -/
theorem abs_sub_eq_iff : (x - y).abs = |x.abs - y.abs| ↔ x = 0 ∨ y = 0 ∨ x.arg = y.arg :=
  sameRay_iff_norm_sub.symm.trans sameRay_iff
#align complex.abs_sub_eq_iff Complex.abs_sub_eq_iff

/- warning: complex.same_ray_of_arg_eq -> Complex.sameRay_of_arg_eq is a dubious translation:
lean 3 declaration is
  forall {x : Complex} {y : Complex}, (Eq.{1} Real (Complex.arg x) (Complex.arg y)) -> (SameRay.{0, 0} Real Real.strictOrderedCommSemiring Complex (AddCommGroup.toAddCommMonoid.{0} Complex Complex.addCommGroup) (Complex.module.{0} Real (StrictOrderedSemiring.toSemiring.{0} Real (StrictOrderedCommSemiring.toStrictOrderedSemiring.{0} Real Real.strictOrderedCommSemiring)) Real.module) x y)
but is expected to have type
  forall {x : Complex} {y : Complex}, (Eq.{1} Real (Complex.arg x) (Complex.arg y)) -> (SameRay.{0, 0} Real Real.strictOrderedCommSemiring Complex (NonUnitalNonAssocSemiring.toAddCommMonoid.{0} Complex (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{0} Complex (NonAssocRing.toNonUnitalNonAssocRing.{0} Complex (Ring.toNonAssocRing.{0} Complex Complex.instRingComplex)))) (Complex.instModuleComplexToAddCommMonoidToNonUnitalNonAssocSemiringToNonUnitalNonAssocRingToNonAssocRingInstRingComplex.{0} Real (StrictOrderedSemiring.toSemiring.{0} Real (StrictOrderedCommSemiring.toStrictOrderedSemiring.{0} Real Real.strictOrderedCommSemiring)) (NormedSpace.toModule.{0, 0} Real Real Real.normedField (NonUnitalSeminormedRing.toSeminormedAddCommGroup.{0} Real (NonUnitalNormedRing.toNonUnitalSeminormedRing.{0} Real (NormedRing.toNonUnitalNormedRing.{0} Real (NormedCommRing.toNormedRing.{0} Real Real.normedCommRing)))) (InnerProductSpace.toNormedSpace.{0, 0} Real Real Real.isROrC Real.normedAddCommGroup (IsROrC.innerProductSpace.{0} Real Real.isROrC)))) x y)
Case conversion may be inaccurate. Consider using '#align complex.same_ray_of_arg_eq Complex.sameRay_of_arg_eqₓ'. -/
theorem sameRay_of_arg_eq (h : x.arg = y.arg) : SameRay ℝ x y :=
  sameRay_iff.mpr <| Or.inr <| Or.inr h
#align complex.same_ray_of_arg_eq Complex.sameRay_of_arg_eq

/- warning: complex.abs_add_eq -> Complex.abs_add_eq is a dubious translation:
lean 3 declaration is
  forall {x : Complex} {y : Complex}, (Eq.{1} Real (Complex.arg x) (Complex.arg y)) -> (Eq.{1} Real (coeFn.{1, 1} (AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) (fun (f : AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) => Complex -> Real) (AbsoluteValue.hasCoeToFun.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) Complex.abs (HAdd.hAdd.{0, 0, 0} Complex Complex Complex (instHAdd.{0} Complex Complex.hasAdd) x y)) (HAdd.hAdd.{0, 0, 0} Real Real Real (instHAdd.{0} Real Real.hasAdd) (coeFn.{1, 1} (AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) (fun (f : AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) => Complex -> Real) (AbsoluteValue.hasCoeToFun.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) Complex.abs x) (coeFn.{1, 1} (AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) (fun (f : AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) => Complex -> Real) (AbsoluteValue.hasCoeToFun.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) Complex.abs y)))
but is expected to have type
  forall {x : Complex} {y : Complex}, (Eq.{1} Real (Complex.arg x) (Complex.arg y)) -> (Eq.{1} ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) (HAdd.hAdd.{0, 0, 0} Complex Complex Complex (instHAdd.{0} Complex Complex.instAddComplex) x y)) (FunLike.coe.{1, 1, 1} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex (fun (f : Complex) => (fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) f) (SubadditiveHomClass.toFunLike.{0, 0, 0} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex Real (Distrib.toAdd.{0} Complex (NonUnitalNonAssocSemiring.toDistrib.{0} Complex (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Complex (Semiring.toNonAssocSemiring.{0} Complex Complex.instSemiringComplex)))) (Distrib.toAdd.{0} Real (NonUnitalNonAssocSemiring.toDistrib.{0} Real (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Real (Semiring.toNonAssocSemiring.{0} Real (OrderedSemiring.toSemiring.{0} Real Real.orderedSemiring))))) (Preorder.toLE.{0} Real (PartialOrder.toPreorder.{0} Real (OrderedSemiring.toPartialOrder.{0} Real Real.orderedSemiring))) (AbsoluteValue.subadditiveHomClass.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring)) Complex.abs (HAdd.hAdd.{0, 0, 0} Complex Complex Complex (instHAdd.{0} Complex Complex.instAddComplex) x y)) (HAdd.hAdd.{0, 0, 0} ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) x) ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) y) ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) x) (instHAdd.{0} ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) x) Real.instAddReal) (FunLike.coe.{1, 1, 1} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex (fun (f : Complex) => (fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) f) (SubadditiveHomClass.toFunLike.{0, 0, 0} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex Real (Distrib.toAdd.{0} Complex (NonUnitalNonAssocSemiring.toDistrib.{0} Complex (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Complex (Semiring.toNonAssocSemiring.{0} Complex Complex.instSemiringComplex)))) (Distrib.toAdd.{0} Real (NonUnitalNonAssocSemiring.toDistrib.{0} Real (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Real (Semiring.toNonAssocSemiring.{0} Real (OrderedSemiring.toSemiring.{0} Real Real.orderedSemiring))))) (Preorder.toLE.{0} Real (PartialOrder.toPreorder.{0} Real (OrderedSemiring.toPartialOrder.{0} Real Real.orderedSemiring))) (AbsoluteValue.subadditiveHomClass.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring)) Complex.abs x) (FunLike.coe.{1, 1, 1} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex (fun (f : Complex) => (fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) f) (SubadditiveHomClass.toFunLike.{0, 0, 0} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex Real (Distrib.toAdd.{0} Complex (NonUnitalNonAssocSemiring.toDistrib.{0} Complex (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Complex (Semiring.toNonAssocSemiring.{0} Complex Complex.instSemiringComplex)))) (Distrib.toAdd.{0} Real (NonUnitalNonAssocSemiring.toDistrib.{0} Real (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Real (Semiring.toNonAssocSemiring.{0} Real (OrderedSemiring.toSemiring.{0} Real Real.orderedSemiring))))) (Preorder.toLE.{0} Real (PartialOrder.toPreorder.{0} Real (OrderedSemiring.toPartialOrder.{0} Real Real.orderedSemiring))) (AbsoluteValue.subadditiveHomClass.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring)) Complex.abs y)))
Case conversion may be inaccurate. Consider using '#align complex.abs_add_eq Complex.abs_add_eqₓ'. -/
theorem abs_add_eq (h : x.arg = y.arg) : (x + y).abs = x.abs + y.abs :=
  (sameRay_of_arg_eq h).norm_add
#align complex.abs_add_eq Complex.abs_add_eq

/- warning: complex.abs_sub_eq -> Complex.abs_sub_eq is a dubious translation:
lean 3 declaration is
  forall {x : Complex} {y : Complex}, (Eq.{1} Real (Complex.arg x) (Complex.arg y)) -> (Eq.{1} Real (coeFn.{1, 1} (AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) (fun (f : AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) => Complex -> Real) (AbsoluteValue.hasCoeToFun.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) Complex.abs (HSub.hSub.{0, 0, 0} Complex Complex Complex (instHSub.{0} Complex Complex.hasSub) x y)) (Norm.norm.{0} Real Real.hasNorm (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (coeFn.{1, 1} (AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) (fun (f : AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) => Complex -> Real) (AbsoluteValue.hasCoeToFun.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) Complex.abs x) (coeFn.{1, 1} (AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) (fun (f : AbsoluteValue.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) => Complex -> Real) (AbsoluteValue.hasCoeToFun.{0, 0} Complex Real (Ring.toSemiring.{0} Complex Complex.ring) Real.orderedSemiring) Complex.abs y))))
but is expected to have type
  forall {x : Complex} {y : Complex}, (Eq.{1} Real (Complex.arg x) (Complex.arg y)) -> (Eq.{1} ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) (HSub.hSub.{0, 0, 0} Complex Complex Complex (instHSub.{0} Complex Complex.instSubComplex) x y)) (FunLike.coe.{1, 1, 1} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex (fun (f : Complex) => (fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) f) (SubadditiveHomClass.toFunLike.{0, 0, 0} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex Real (Distrib.toAdd.{0} Complex (NonUnitalNonAssocSemiring.toDistrib.{0} Complex (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Complex (Semiring.toNonAssocSemiring.{0} Complex Complex.instSemiringComplex)))) (Distrib.toAdd.{0} Real (NonUnitalNonAssocSemiring.toDistrib.{0} Real (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Real (Semiring.toNonAssocSemiring.{0} Real (OrderedSemiring.toSemiring.{0} Real Real.orderedSemiring))))) (Preorder.toLE.{0} Real (PartialOrder.toPreorder.{0} Real (OrderedSemiring.toPartialOrder.{0} Real Real.orderedSemiring))) (AbsoluteValue.subadditiveHomClass.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring)) Complex.abs (HSub.hSub.{0, 0, 0} Complex Complex Complex (instHSub.{0} Complex Complex.instSubComplex) x y)) (Norm.norm.{0} ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) x) Real.norm (HSub.hSub.{0, 0, 0} ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) x) ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) y) ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) x) (instHSub.{0} ((fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) x) Real.instSubReal) (FunLike.coe.{1, 1, 1} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex (fun (f : Complex) => (fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) f) (SubadditiveHomClass.toFunLike.{0, 0, 0} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex Real (Distrib.toAdd.{0} Complex (NonUnitalNonAssocSemiring.toDistrib.{0} Complex (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Complex (Semiring.toNonAssocSemiring.{0} Complex Complex.instSemiringComplex)))) (Distrib.toAdd.{0} Real (NonUnitalNonAssocSemiring.toDistrib.{0} Real (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Real (Semiring.toNonAssocSemiring.{0} Real (OrderedSemiring.toSemiring.{0} Real Real.orderedSemiring))))) (Preorder.toLE.{0} Real (PartialOrder.toPreorder.{0} Real (OrderedSemiring.toPartialOrder.{0} Real Real.orderedSemiring))) (AbsoluteValue.subadditiveHomClass.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring)) Complex.abs x) (FunLike.coe.{1, 1, 1} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex (fun (f : Complex) => (fun (x._@.Mathlib.Algebra.Order.Hom.Basic._hyg.99 : Complex) => Real) f) (SubadditiveHomClass.toFunLike.{0, 0, 0} (AbsoluteValue.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring) Complex Real (Distrib.toAdd.{0} Complex (NonUnitalNonAssocSemiring.toDistrib.{0} Complex (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Complex (Semiring.toNonAssocSemiring.{0} Complex Complex.instSemiringComplex)))) (Distrib.toAdd.{0} Real (NonUnitalNonAssocSemiring.toDistrib.{0} Real (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} Real (Semiring.toNonAssocSemiring.{0} Real (OrderedSemiring.toSemiring.{0} Real Real.orderedSemiring))))) (Preorder.toLE.{0} Real (PartialOrder.toPreorder.{0} Real (OrderedSemiring.toPartialOrder.{0} Real Real.orderedSemiring))) (AbsoluteValue.subadditiveHomClass.{0, 0} Complex Real Complex.instSemiringComplex Real.orderedSemiring)) Complex.abs y))))
Case conversion may be inaccurate. Consider using '#align complex.abs_sub_eq Complex.abs_sub_eqₓ'. -/
theorem abs_sub_eq (h : x.arg = y.arg) : (x - y).abs = ‖x.abs - y.abs‖ :=
  (sameRay_of_arg_eq h).norm_sub
#align complex.abs_sub_eq Complex.abs_sub_eq

end Complex

