/-
Copyright (c) 2019 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Patrick Massot, Casper Putz, Anne Baanen

! This file was ported from Lean 3 source module linear_algebra.matrix.dot_product
! leanprover-community/mathlib commit 19cb3751e5e9b3d97adb51023949c50c13b5fdfd
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Matrix.Basic
import Mathbin.LinearAlgebra.StdBasis

/-!
# Dot product of two vectors

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains some results on the map `matrix.dot_product`, which maps two
vectors `v w : n → R` to the sum of the entrywise products `v i * w i`.

## Main results

* `matrix.dot_product_std_basis_one`: the dot product of `v` with the `i`th
  standard basis vector is `v i`
* `matrix.dot_product_eq_zero_iff`: if `v`'s' dot product with all `w` is zero,
  then `v` is zero

## Tags

matrix, reindex

-/


universe v w

namespace Matrix

variable {R : Type v} [Semiring R] {n : Type w} [Fintype n]

/- warning: matrix.dot_product_std_basis_eq_mul -> Matrix.dotProduct_stdBasis_eq_mul is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : Semiring.{u1} R] {n : Type.{u2}} [_inst_2 : Fintype.{u2} n] [_inst_3 : DecidableEq.{succ u2} n] (v : n -> R) (c : R) (i : n), Eq.{succ u1} R (Matrix.dotProduct.{u1, u2} n R _inst_2 (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) v (coeFn.{max (succ u1) (succ (max u2 u1)), max (succ u1) (succ (max u2 u1))} (LinearMap.{u1, u1, u1, max u2 u1} R R _inst_1 _inst_1 (RingHom.id.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)) ((fun (_x : n) => R) i) (forall (i : n), (fun (_x : n) => R) i) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (Pi.addCommMonoid.{u2, u1} n (fun (i : n) => (fun (_x : n) => R) i) (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1)))) (Semiring.toModule.{u1} R _inst_1) (Pi.module.{u2, u1, u1} n (fun (i : n) => (fun (_x : n) => R) i) R _inst_1 (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (fun (i : n) => Semiring.toModule.{u1} R _inst_1))) (fun (_x : LinearMap.{u1, u1, u1, max u2 u1} R R _inst_1 _inst_1 (RingHom.id.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)) ((fun (_x : n) => R) i) (forall (i : n), (fun (_x : n) => R) i) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (Pi.addCommMonoid.{u2, u1} n (fun (i : n) => (fun (_x : n) => R) i) (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1)))) (Semiring.toModule.{u1} R _inst_1) (Pi.module.{u2, u1, u1} n (fun (i : n) => (fun (_x : n) => R) i) R _inst_1 (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (fun (i : n) => Semiring.toModule.{u1} R _inst_1))) => R -> (forall (i : n), (fun (_x : n) => R) i)) (LinearMap.hasCoeToFun.{u1, u1, u1, max u2 u1} R R ((fun (_x : n) => R) i) (forall (i : n), (fun (_x : n) => R) i) _inst_1 _inst_1 (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (Pi.addCommMonoid.{u2, u1} n (fun (i : n) => (fun (_x : n) => R) i) (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1)))) (Semiring.toModule.{u1} R _inst_1) (Pi.module.{u2, u1, u1} n (fun (i : n) => (fun (_x : n) => R) i) R _inst_1 (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (fun (i : n) => Semiring.toModule.{u1} R _inst_1)) (RingHom.id.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) (LinearMap.stdBasis.{u1, u2, u1} R n _inst_1 (fun (_x : n) => R) (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (fun (i : n) => Semiring.toModule.{u1} R _inst_1) (fun (a : n) (b : n) => _inst_3 a b) i) c)) (HMul.hMul.{u1, u1, u1} R R R (instHMul.{u1} R (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))))) (v i) c)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : Semiring.{u1} R] {n : Type.{u2}} [_inst_2 : Fintype.{u2} n] [_inst_3 : DecidableEq.{succ u2} n] (v : n -> R) (c : R) (i : n), Eq.{succ u1} R (Matrix.dotProduct.{u1, u2} n R _inst_2 (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) v (FunLike.coe.{max (succ u1) (succ u2), succ u1, max (succ u1) (succ u2)} (LinearMap.{u1, u1, u1, max u2 u1} R R _inst_1 _inst_1 (RingHom.id.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)) R (n -> R) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.48 : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.48 : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.48 : n) => R) i) _inst_1))) (Pi.addCommMonoid.{u2, u1} n (fun (i : n) => R) (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.48 : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.48 : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.48 : n) => R) i) _inst_1)))) (Semiring.toModule.{u1} R _inst_1) (Pi.module.{u2, u1, u1} n (fun (i : n) => R) R _inst_1 (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.48 : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.48 : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.48 : n) => R) i) _inst_1))) (fun (i : n) => Semiring.toModule.{u1} R _inst_1))) R (fun (_x : R) => (fun (x._@.Mathlib.Algebra.Module.LinearMap._hyg.6190 : R) => n -> R) _x) (LinearMap.instFunLikeLinearMap.{u1, u1, u1, max u1 u2} R R R (n -> R) _inst_1 _inst_1 (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (Pi.addCommMonoid.{u2, u1} n (fun (i : n) => R) (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1)))) (Semiring.toModule.{u1} R _inst_1) (Pi.module.{u2, u1, u1} n (fun (i : n) => R) R _inst_1 (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (fun (i : n) => Semiring.toModule.{u1} R _inst_1)) (RingHom.id.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) (LinearMap.stdBasis.{u1, u2, u1} R n _inst_1 (fun (_x : n) => R) (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (fun (i : n) => Semiring.toModule.{u1} R _inst_1) (fun (a : n) (b : n) => _inst_3 a b) i) c)) (HMul.hMul.{u1, u1, u1} R R R (instHMul.{u1} R (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)))) (v i) c)
Case conversion may be inaccurate. Consider using '#align matrix.dot_product_std_basis_eq_mul Matrix.dotProduct_stdBasis_eq_mulₓ'. -/
@[simp]
theorem dotProduct_stdBasis_eq_mul [DecidableEq n] (v : n → R) (c : R) (i : n) :
    dotProduct v (LinearMap.stdBasis R (fun _ => R) i c) = v i * c :=
  by
  rw [dot_product, Finset.sum_eq_single i, LinearMap.stdBasis_same]
  exact fun _ _ hb => by rw [LinearMap.stdBasis_ne _ _ _ _ hb, MulZeroClass.mul_zero]
  exact fun hi => False.elim (hi <| Finset.mem_univ _)
#align matrix.dot_product_std_basis_eq_mul Matrix.dotProduct_stdBasis_eq_mul

/- warning: matrix.dot_product_std_basis_one -> Matrix.dotProduct_stdBasis_one is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : Semiring.{u1} R] {n : Type.{u2}} [_inst_2 : Fintype.{u2} n] [_inst_3 : DecidableEq.{succ u2} n] (v : n -> R) (i : n), Eq.{succ u1} R (Matrix.dotProduct.{u1, u2} n R _inst_2 (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) v (coeFn.{max (succ u1) (succ (max u2 u1)), max (succ u1) (succ (max u2 u1))} (LinearMap.{u1, u1, u1, max u2 u1} R R _inst_1 _inst_1 (RingHom.id.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)) ((fun (_x : n) => R) i) (forall (i : n), (fun (_x : n) => R) i) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (Pi.addCommMonoid.{u2, u1} n (fun (i : n) => (fun (_x : n) => R) i) (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1)))) (Semiring.toModule.{u1} R _inst_1) (Pi.module.{u2, u1, u1} n (fun (i : n) => (fun (_x : n) => R) i) R _inst_1 (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (fun (i : n) => Semiring.toModule.{u1} R _inst_1))) (fun (_x : LinearMap.{u1, u1, u1, max u2 u1} R R _inst_1 _inst_1 (RingHom.id.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)) ((fun (_x : n) => R) i) (forall (i : n), (fun (_x : n) => R) i) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (Pi.addCommMonoid.{u2, u1} n (fun (i : n) => (fun (_x : n) => R) i) (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1)))) (Semiring.toModule.{u1} R _inst_1) (Pi.module.{u2, u1, u1} n (fun (i : n) => (fun (_x : n) => R) i) R _inst_1 (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (fun (i : n) => Semiring.toModule.{u1} R _inst_1))) => R -> (forall (i : n), (fun (_x : n) => R) i)) (LinearMap.hasCoeToFun.{u1, u1, u1, max u2 u1} R R ((fun (_x : n) => R) i) (forall (i : n), (fun (_x : n) => R) i) _inst_1 _inst_1 (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (Pi.addCommMonoid.{u2, u1} n (fun (i : n) => (fun (_x : n) => R) i) (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1)))) (Semiring.toModule.{u1} R _inst_1) (Pi.module.{u2, u1, u1} n (fun (i : n) => (fun (_x : n) => R) i) R _inst_1 (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (fun (i : n) => Semiring.toModule.{u1} R _inst_1)) (RingHom.id.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) (LinearMap.stdBasis.{u1, u2, u1} R n _inst_1 (fun (_x : n) => R) (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (fun (i : n) => Semiring.toModule.{u1} R _inst_1) (fun (a : n) (b : n) => _inst_3 a b) i) (OfNat.ofNat.{u1} ((fun (_x : n) => R) i) 1 (OfNat.mk.{u1} ((fun (_x : n) => R) i) 1 (One.one.{u1} ((fun (_x : n) => R) i) (AddMonoidWithOne.toOne.{u1} ((fun (_x : n) => R) i) (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toAddCommMonoidWithOne.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))))))))) (v i)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : Semiring.{u1} R] {n : Type.{u2}} [_inst_2 : Fintype.{u2} n] [_inst_3 : DecidableEq.{succ u2} n] (v : n -> R) (i : n), Eq.{succ u1} R (Matrix.dotProduct.{u1, u2} n R _inst_2 (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) v (FunLike.coe.{max (succ u1) (succ u2), succ u1, max (succ u1) (succ u2)} (LinearMap.{u1, u1, u1, max u2 u1} R R _inst_1 _inst_1 (RingHom.id.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)) R (n -> R) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.175 : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.175 : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.175 : n) => R) i) _inst_1))) (Pi.addCommMonoid.{u2, u1} n (fun (i : n) => R) (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.175 : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.175 : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.175 : n) => R) i) _inst_1)))) (Semiring.toModule.{u1} R _inst_1) (Pi.module.{u2, u1, u1} n (fun (i : n) => R) R _inst_1 (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.175 : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.175 : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (x._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.175 : n) => R) i) _inst_1))) (fun (i : n) => Semiring.toModule.{u1} R _inst_1))) R (fun (_x : R) => (fun (x._@.Mathlib.Algebra.Module.LinearMap._hyg.6190 : R) => n -> R) _x) (LinearMap.instFunLikeLinearMap.{u1, u1, u1, max u1 u2} R R R (n -> R) _inst_1 _inst_1 (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (Pi.addCommMonoid.{u2, u1} n (fun (i : n) => R) (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1)))) (Semiring.toModule.{u1} R _inst_1) (Pi.module.{u2, u1, u1} n (fun (i : n) => R) R _inst_1 (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (fun (i : n) => Semiring.toModule.{u1} R _inst_1)) (RingHom.id.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) (LinearMap.stdBasis.{u1, u2, u1} R n _inst_1 (fun (_x : n) => R) (fun (i : n) => NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} ((fun (_x : n) => R) i) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} ((fun (_x : n) => R) i) (Semiring.toNonAssocSemiring.{u1} ((fun (_x : n) => R) i) _inst_1))) (fun (i : n) => Semiring.toModule.{u1} R _inst_1) (fun (a : n) (b : n) => _inst_3 a b) i) (OfNat.ofNat.{u1} R 1 (One.toOfNat1.{u1} R (Semiring.toOne.{u1} R _inst_1))))) (v i)
Case conversion may be inaccurate. Consider using '#align matrix.dot_product_std_basis_one Matrix.dotProduct_stdBasis_oneₓ'. -/
@[simp]
theorem dotProduct_stdBasis_one [DecidableEq n] (v : n → R) (i : n) :
    dotProduct v (LinearMap.stdBasis R (fun _ => R) i 1) = v i := by
  rw [dot_product_std_basis_eq_mul, mul_one]
#align matrix.dot_product_std_basis_one Matrix.dotProduct_stdBasis_one

/- warning: matrix.dot_product_eq -> Matrix.dotProduct_eq is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : Semiring.{u1} R] {n : Type.{u2}} [_inst_2 : Fintype.{u2} n] (v : n -> R) (w : n -> R), (forall (u : n -> R), Eq.{succ u1} R (Matrix.dotProduct.{u1, u2} n R _inst_2 (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) v u) (Matrix.dotProduct.{u1, u2} n R _inst_2 (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) w u)) -> (Eq.{max (succ u2) (succ u1)} (n -> R) v w)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : Semiring.{u1} R] {n : Type.{u2}} [_inst_2 : Fintype.{u2} n] (v : n -> R) (w : n -> R), (forall (u : n -> R), Eq.{succ u1} R (Matrix.dotProduct.{u1, u2} n R _inst_2 (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) v u) (Matrix.dotProduct.{u1, u2} n R _inst_2 (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) w u)) -> (Eq.{max (succ u1) (succ u2)} (n -> R) v w)
Case conversion may be inaccurate. Consider using '#align matrix.dot_product_eq Matrix.dotProduct_eqₓ'. -/
theorem dotProduct_eq (v w : n → R) (h : ∀ u, dotProduct v u = dotProduct w u) : v = w :=
  by
  funext x
  classical rw [← dot_product_std_basis_one v x, ← dot_product_std_basis_one w x, h]
#align matrix.dot_product_eq Matrix.dotProduct_eq

/- warning: matrix.dot_product_eq_iff -> Matrix.dotProduct_eq_iff is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : Semiring.{u1} R] {n : Type.{u2}} [_inst_2 : Fintype.{u2} n] {v : n -> R} {w : n -> R}, Iff (forall (u : n -> R), Eq.{succ u1} R (Matrix.dotProduct.{u1, u2} n R _inst_2 (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) v u) (Matrix.dotProduct.{u1, u2} n R _inst_2 (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) w u)) (Eq.{max (succ u2) (succ u1)} (n -> R) v w)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : Semiring.{u1} R] {n : Type.{u2}} [_inst_2 : Fintype.{u2} n] {v : n -> R} {w : n -> R}, Iff (forall (u : n -> R), Eq.{succ u1} R (Matrix.dotProduct.{u1, u2} n R _inst_2 (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) v u) (Matrix.dotProduct.{u1, u2} n R _inst_2 (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) w u)) (Eq.{max (succ u1) (succ u2)} (n -> R) v w)
Case conversion may be inaccurate. Consider using '#align matrix.dot_product_eq_iff Matrix.dotProduct_eq_iffₓ'. -/
theorem dotProduct_eq_iff {v w : n → R} : (∀ u, dotProduct v u = dotProduct w u) ↔ v = w :=
  ⟨fun h => dotProduct_eq v w h, fun h _ => h ▸ rfl⟩
#align matrix.dot_product_eq_iff Matrix.dotProduct_eq_iff

/- warning: matrix.dot_product_eq_zero -> Matrix.dotProduct_eq_zero is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : Semiring.{u1} R] {n : Type.{u2}} [_inst_2 : Fintype.{u2} n] (v : n -> R), (forall (w : n -> R), Eq.{succ u1} R (Matrix.dotProduct.{u1, u2} n R _inst_2 (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) v w) (OfNat.ofNat.{u1} R 0 (OfNat.mk.{u1} R 0 (Zero.zero.{u1} R (MulZeroClass.toHasZero.{u1} R (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)))))))) -> (Eq.{max (succ u2) (succ u1)} (n -> R) v (OfNat.ofNat.{max u2 u1} (n -> R) 0 (OfNat.mk.{max u2 u1} (n -> R) 0 (Zero.zero.{max u2 u1} (n -> R) (Pi.instZero.{u2, u1} n (fun (ᾰ : n) => R) (fun (i : n) => MulZeroClass.toHasZero.{u1} R (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)))))))))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : Semiring.{u1} R] {n : Type.{u2}} [_inst_2 : Fintype.{u2} n] (v : n -> R), (forall (w : n -> R), Eq.{succ u1} R (Matrix.dotProduct.{u1, u2} n R _inst_2 (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) v w) (OfNat.ofNat.{u1} R 0 (Zero.toOfNat0.{u1} R (MonoidWithZero.toZero.{u1} R (Semiring.toMonoidWithZero.{u1} R _inst_1))))) -> (Eq.{max (succ u1) (succ u2)} (n -> R) v (OfNat.ofNat.{max u1 u2} (n -> R) 0 (Zero.toOfNat0.{max u1 u2} (n -> R) (Pi.instZero.{u2, u1} n (fun (a._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.355 : n) => R) (fun (i : n) => MonoidWithZero.toZero.{u1} R (Semiring.toMonoidWithZero.{u1} R _inst_1))))))
Case conversion may be inaccurate. Consider using '#align matrix.dot_product_eq_zero Matrix.dotProduct_eq_zeroₓ'. -/
theorem dotProduct_eq_zero (v : n → R) (h : ∀ w, dotProduct v w = 0) : v = 0 :=
  dotProduct_eq _ _ fun u => (h u).symm ▸ (zero_dotProduct u).symm
#align matrix.dot_product_eq_zero Matrix.dotProduct_eq_zero

/- warning: matrix.dot_product_eq_zero_iff -> Matrix.dotProduct_eq_zero_iff is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : Semiring.{u1} R] {n : Type.{u2}} [_inst_2 : Fintype.{u2} n] {v : n -> R}, Iff (forall (w : n -> R), Eq.{succ u1} R (Matrix.dotProduct.{u1, u2} n R _inst_2 (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) v w) (OfNat.ofNat.{u1} R 0 (OfNat.mk.{u1} R 0 (Zero.zero.{u1} R (MulZeroClass.toHasZero.{u1} R (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)))))))) (Eq.{max (succ u2) (succ u1)} (n -> R) v (OfNat.ofNat.{max u2 u1} (n -> R) 0 (OfNat.mk.{max u2 u1} (n -> R) 0 (Zero.zero.{max u2 u1} (n -> R) (Pi.instZero.{u2, u1} n (fun (ᾰ : n) => R) (fun (i : n) => MulZeroClass.toHasZero.{u1} R (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1)))))))))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : Semiring.{u1} R] {n : Type.{u2}} [_inst_2 : Fintype.{u2} n] {v : n -> R}, Iff (forall (w : n -> R), Eq.{succ u1} R (Matrix.dotProduct.{u1, u2} n R _inst_2 (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_1))) v w) (OfNat.ofNat.{u1} R 0 (Zero.toOfNat0.{u1} R (MonoidWithZero.toZero.{u1} R (Semiring.toMonoidWithZero.{u1} R _inst_1))))) (Eq.{max (succ u1) (succ u2)} (n -> R) v (OfNat.ofNat.{max u1 u2} (n -> R) 0 (Zero.toOfNat0.{max u1 u2} (n -> R) (Pi.instZero.{u2, u1} n (fun (a._@.Mathlib.LinearAlgebra.Matrix.DotProduct._hyg.403 : n) => R) (fun (i : n) => MonoidWithZero.toZero.{u1} R (Semiring.toMonoidWithZero.{u1} R _inst_1))))))
Case conversion may be inaccurate. Consider using '#align matrix.dot_product_eq_zero_iff Matrix.dotProduct_eq_zero_iffₓ'. -/
theorem dotProduct_eq_zero_iff {v : n → R} : (∀ w, dotProduct v w = 0) ↔ v = 0 :=
  ⟨fun h => dotProduct_eq_zero v h, fun h w => h.symm ▸ zero_dotProduct w⟩
#align matrix.dot_product_eq_zero_iff Matrix.dotProduct_eq_zero_iff

end Matrix

