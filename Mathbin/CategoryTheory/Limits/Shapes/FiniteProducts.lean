/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import Mathbin.CategoryTheory.Limits.Shapes.BinaryProducts
import Mathbin.CategoryTheory.Limits.Shapes.FiniteLimits
import Mathbin.CategoryTheory.Limits.Shapes.Products
import Mathbin.CategoryTheory.Limits.Shapes.Terminal

/-!
# Categories with finite (co)products

Typeclasses representing categories with (co)products over finite indexing types.
-/


universe w v u

open CategoryTheory

open Classical

namespace CategoryTheory.Limits

variable (C : Type u) [Category.{v} C]

-- We can't simply make this an abbreviation, as we do with other `has_Xs` limits typeclasses,
-- because of https://github.com/leanprover-community/lean/issues/429
/-- A category has finite products if there is a chosen limit for every diagram
with shape `discrete J`, where we have `[fintype J]`.
-/
class HasFiniteProducts : Prop where
  out (J : Type) [Fintypeₓ J] : HasLimitsOfShape (Discrete J) C

instance has_limits_of_shape_discrete (J : Type) [Finite J] [HasFiniteProducts C] : HasLimitsOfShape (Discrete J) C :=
  by
  cases nonempty_fintype J
  haveI := @has_finite_products.out C _ _ J
  infer_instance

/-- If `C` has finite limits then it has finite products. -/
instance (priority := 10) has_finite_products_of_has_finite_limits [HasFiniteLimits C] : HasFiniteProducts C :=
  ⟨fun J 𝒥 => by
    skip
    infer_instance⟩

instance has_fintype_products [HasFiniteProducts C] (ι : Type w) [Finite ι] : HasLimitsOfShape (Discrete ι) C := by
  cases nonempty_fintype ι <;>
    exact has_limits_of_shape_of_equivalence (discrete.equivalence (Equivₓ.ulift.{0}.trans (Fintypeₓ.equivFin ι).symm))

/-- We can now write this for powers. -/
noncomputable example [HasFiniteProducts C] (X : C) : C :=
  ∏ fun i : Finₓ 5 => X

/-- If a category has all products then in particular it has finite products.
-/
theorem has_finite_products_of_has_products [HasProducts.{w} C] : HasFiniteProducts C :=
  ⟨fun J _ => has_limits_of_shape_of_equivalence (Discrete.equivalence Equivₓ.ulift.{w})⟩

/-- A category has finite coproducts if there is a chosen colimit for every diagram
with shape `discrete J`, where we have `[fintype J]`.
-/
class HasFiniteCoproducts : Prop where
  out (J : Type) [Fintypeₓ J] : HasColimitsOfShape (Discrete J) C

attribute [class] has_finite_coproducts

instance has_colimits_of_shape_discrete (J : Type) [Finite J] [HasFiniteCoproducts C] :
    HasColimitsOfShape (Discrete J) C := by
  cases nonempty_fintype J
  haveI := @has_finite_coproducts.out C _ _ J
  infer_instance

/-- If `C` has finite colimits then it has finite coproducts. -/
instance (priority := 10) has_finite_coproducts_of_has_finite_colimits [HasFiniteColimits C] : HasFiniteCoproducts C :=
  ⟨fun J 𝒥 => by
    skip
    infer_instance⟩

instance has_fintype_coproducts [HasFiniteCoproducts C] (ι : Type w) [Fintypeₓ ι] : HasColimitsOfShape (Discrete ι) C :=
  by
  cases nonempty_fintype ι <;>
    exact
      has_colimits_of_shape_of_equivalence (discrete.equivalence (Equivₓ.ulift.{0}.trans (Fintypeₓ.equivFin ι).symm))

/-- If a category has all coproducts then in particular it has finite coproducts.
-/
theorem has_finite_coproducts_of_has_coproducts [HasCoproducts.{w} C] : HasFiniteCoproducts C :=
  ⟨fun J _ => has_colimits_of_shape_of_equivalence (Discrete.equivalence Equivₓ.ulift.{w})⟩

end CategoryTheory.Limits

