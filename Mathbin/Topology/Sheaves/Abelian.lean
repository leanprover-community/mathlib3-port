/-
Copyright (c) 2022 Jujian Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Adam Topaz, Jujian Zhang

! This file was ported from Lean 3 source module topology.sheaves.abelian
! leanprover-community/mathlib commit 422e70f7ce183d2900c586a8cda8381e788a0c62
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Abelian.FunctorCategory
import Mathbin.CategoryTheory.Preadditive.AdditiveFunctor
import Mathbin.CategoryTheory.Preadditive.FunctorCategory
import Mathbin.CategoryTheory.Abelian.Transfer
import Mathbin.CategoryTheory.Sites.LeftExact

/-!
# Category of sheaves is abelian
Let `C, D` be categories and `J` be a grothendieck topology on `C`, when `D` is abelian and
sheafification is possible in `C`, `Sheaf J D` is abelian as well (`Sheaf_is_abelian`).

Hence, `presheaf_to_Sheaf` is an additive functor (`presheaf_to_Sheaf_additive`).

-/


noncomputable section

namespace CategoryTheory

open CategoryTheory.Limits

section Abelian

universe w v u

variable {C : Type max v u} [Category.{v} C]

variable {D : Type w} [Category.{max v u} D] [Abelian D]

variable {J : GrothendieckTopology C}

-- This needs to be specified manually because of universe level.
instance : Abelian (Cᵒᵖ ⥤ D) :=
  @Abelian.functorCategoryAbelian.{v} Cᵒᵖ _ D _ _

-- This also needs to be specified manually, but I don't know why.
instance : HasFiniteProducts (SheafCat J D)
    where out j := { HasLimit := fun F => by infer_instance }

-- sheafification assumptions
variable [∀ (P : Cᵒᵖ ⥤ D) (X : C) (S : J.cover X), HasMultiequalizer (S.index P)]

variable [∀ X : C, HasColimitsOfShape (J.cover X)ᵒᵖ D]

variable [ConcreteCategory.{max v u} D] [PreservesLimits (forget D)]

variable [∀ X : C, PreservesColimitsOfShape (J.cover X)ᵒᵖ (forget D)]

variable [ReflectsIsomorphisms (forget D)]

instance sheafIsAbelian [HasFiniteLimits D] : Abelian (SheafCat J D) :=
  let adj := sheafificationAdjunction J D
  abelianOfAdjunction _ _ (asIso adj.counit) adj
#align category_theory.Sheaf_is_abelian CategoryTheory.sheafIsAbelian

attribute [local instance] preserves_binary_biproducts_of_preserves_binary_products

instance presheaf_to_Sheaf_additive : (presheafToSheaf J D).Additive :=
  (presheafToSheaf J D).additive_of_preserves_binary_biproducts
#align category_theory.presheaf_to_Sheaf_additive CategoryTheory.presheaf_to_Sheaf_additive

end Abelian

end CategoryTheory

