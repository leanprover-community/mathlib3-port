/-
Copyright (c) 2022 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel

! This file was ported from Lean 3 source module category_theory.limits.essentially_small
! leanprover-community/mathlib commit bd9851ca476957ea4549eb19b40e7b5ade9428cc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.Shapes.Products
import Mathbin.CategoryTheory.EssentiallySmall

/-!
# Limits over essentially small indexing categories

If `C` has limits of size `w` and `J` is `w`-essentially small, then `C` has limits of shape `J`.

-/


universe w₁ w₂ v₁ v₂ u₁ u₂

noncomputable section

open CategoryTheory

namespace CategoryTheory.Limits

variable (J : Type u₂) [Category.{v₂} J] (C : Type u₁) [Category.{v₁} C]

theorem hasLimitsOfShapeOfEssentiallySmall [EssentiallySmall.{w₁} J] [HasLimitsOfSize.{w₁, w₁} C] :
    HasLimitsOfShape J C :=
  hasLimitsOfShapeOfEquivalence <| Equivalence.symm <| equivSmallModel.{w₁} J
#align category_theory.limits.has_limits_of_shape_of_essentially_small CategoryTheory.Limits.hasLimitsOfShapeOfEssentiallySmall

theorem hasColimitsOfShapeOfEssentiallySmall [EssentiallySmall.{w₁} J]
    [HasColimitsOfSize.{w₁, w₁} C] : HasColimitsOfShape J C :=
  hasColimitsOfShapeOfEquivalence <| Equivalence.symm <| equivSmallModel.{w₁} J
#align category_theory.limits.has_colimits_of_shape_of_essentially_small CategoryTheory.Limits.hasColimitsOfShapeOfEssentiallySmall

theorem hasProductsOfShape_of_small (β : Type w₂) [Small.{w₁} β] [HasProducts.{w₁} C] :
    HasProductsOfShape β C :=
  hasLimitsOfShapeOfEquivalence <| Discrete.equivalence <| Equiv.symm <| equivShrink β
#align category_theory.limits.has_products_of_shape_of_small CategoryTheory.Limits.hasProductsOfShape_of_small

theorem hasCoproductsOfShape_of_small (β : Type w₂) [Small.{w₁} β] [HasCoproducts.{w₁} C] :
    HasCoproductsOfShape β C :=
  hasColimitsOfShapeOfEquivalence <| Discrete.equivalence <| Equiv.symm <| equivShrink β
#align category_theory.limits.has_coproducts_of_shape_of_small CategoryTheory.Limits.hasCoproductsOfShape_of_small

end CategoryTheory.Limits

