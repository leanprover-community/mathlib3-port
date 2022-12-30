/-
Copyright (c) 2022 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module algebra.module.algebra
! leanprover-community/mathlib commit 986c4d5761f938b2e1c43c01f001b6d9d88c2055
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Module.Basic
import Mathbin.Algebra.Algebra.Basic

/-!
# Additional facts about modules over algebras.
-/


namespace LinearMap

section RestrictScalars

variable (k : Type _) [CommSemiring k] (A : Type _) [Semiring A] [Algebra k A]

variable (M : Type _) [AddCommMonoid M] [Module k M] [Module A M] [IsScalarTower k A M]

variable (N : Type _) [AddCommMonoid N] [Module k N] [Module A N] [IsScalarTower k A N]

/-- Restriction of scalars for linear maps between modules over a `k`-algebra is itself `k`-linear.
-/
@[simps]
def restrictScalarsLinearMap : (M →ₗ[A] N) →ₗ[k] M →ₗ[k] N
    where
  toFun := LinearMap.restrictScalars k
  map_add' := by tidy
  map_smul' := by tidy
#align linear_map.restrict_scalars_linear_map LinearMap.restrictScalarsLinearMap

end RestrictScalars

end LinearMap

