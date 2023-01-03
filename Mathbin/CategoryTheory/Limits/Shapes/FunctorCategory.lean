/-
Copyright (c) 2022 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module category_theory.limits.shapes.functor_category
! leanprover-community/mathlib commit 9830a300340708eaa85d477c3fb96dd25f9468a5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.Shapes.FiniteLimits
import Mathbin.CategoryTheory.Limits.FunctorCategory

/-!
# If `D` has finite (co)limits, so do the functor categories `C ⥤ D`.

These are boiler-plate instances, in their own file as neither import otherwise needs the other.
-/


open CategoryTheory

namespace CategoryTheory.Limits

universe v₁ v₂ u₁ u₂ w

variable {C : Type u₁} [Category.{v₁} C]

variable {D : Type u₂} [Category.{v₂} D]

instance functorCategoryHasFiniteLimits [HasFiniteLimits D] : HasFiniteLimits (C ⥤ D)
    where out J _ _ := inferInstance
#align
  category_theory.limits.functor_category_has_finite_limits CategoryTheory.Limits.functorCategoryHasFiniteLimits

instance functorCategoryHasFiniteColimits [HasFiniteColimits D] : HasFiniteColimits (C ⥤ D)
    where out J _ _ := inferInstance
#align
  category_theory.limits.functor_category_has_finite_colimits CategoryTheory.Limits.functorCategoryHasFiniteColimits

end CategoryTheory.Limits

