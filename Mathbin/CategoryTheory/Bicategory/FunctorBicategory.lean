/-
Copyright (c) 2022 Yuma Mizuno. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yuma Mizuno
-/
import Mathbin.CategoryTheory.Bicategory.NaturalTransformation

#align_import category_theory.bicategory.functor_bicategory from "leanprover-community/mathlib"@"44e2ae8cffc713925494e4975ee31ec1d06929b3"

/-!
# The bicategory of oplax functors between two bicategories

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Given bicategories `B` and `C`, we give a bicategory structure on `oplax_functor B C` whose
* objects are oplax functors,
* 1-morphisms are oplax natural transformations, and
* 2-morphisms are modifications.
-/


namespace CategoryTheory

open Category Bicategory

open scoped Bicategory

universe w₁ w₂ v₁ v₂ u₁ u₂

variable {B : Type u₁} [Bicategory.{w₁, v₁} B] {C : Type u₂} [Bicategory.{w₂, v₂} C]

variable {F G H I : OplaxFunctor B C}

namespace OplaxNatTrans

#print CategoryTheory.OplaxNatTrans.whiskerLeft /-
/-- Left whiskering of an oplax natural transformation and a modification. -/
@[simps]
def whiskerLeft (η : F ⟶ G) {θ ι : G ⟶ H} (Γ : θ ⟶ ι) : η ≫ θ ⟶ η ≫ ι
    where
  app a := η.app a ◁ Γ.app a
  naturality a b f := by dsimp; rw [associator_inv_naturality_right_assoc, whisker_exchange_assoc];
    simp
#align category_theory.oplax_nat_trans.whisker_left CategoryTheory.OplaxNatTrans.whiskerLeft
-/

#print CategoryTheory.OplaxNatTrans.whiskerRight /-
/-- Right whiskering of an oplax natural transformation and a modification. -/
@[simps]
def whiskerRight {η θ : F ⟶ G} (Γ : η ⟶ θ) (ι : G ⟶ H) : η ≫ ι ⟶ θ ≫ ι
    where
  app a := Γ.app a ▷ ι.app a
  naturality a b f := by dsimp;
    simp_rw [assoc, ← associator_inv_naturality_left, whisker_exchange_assoc]; simp
#align category_theory.oplax_nat_trans.whisker_right CategoryTheory.OplaxNatTrans.whiskerRight
-/

#print CategoryTheory.OplaxNatTrans.associator /-
/-- Associator for the vertical composition of oplax natural transformations. -/
@[simps]
def associator (η : F ⟶ G) (θ : G ⟶ H) (ι : H ⟶ I) : (η ≫ θ) ≫ ι ≅ η ≫ θ ≫ ι :=
  ModificationIso.ofComponents (fun a => α_ (η.app a) (θ.app a) (ι.app a)) (by tidy)
#align category_theory.oplax_nat_trans.associator CategoryTheory.OplaxNatTrans.associator
-/

#print CategoryTheory.OplaxNatTrans.leftUnitor /-
/-- Left unitor for the vertical composition of oplax natural transformations. -/
@[simps]
def leftUnitor (η : F ⟶ G) : 𝟙 F ≫ η ≅ η :=
  ModificationIso.ofComponents (fun a => λ_ (η.app a)) (by tidy)
#align category_theory.oplax_nat_trans.left_unitor CategoryTheory.OplaxNatTrans.leftUnitor
-/

#print CategoryTheory.OplaxNatTrans.rightUnitor /-
/-- Right unitor for the vertical composition of oplax natural transformations. -/
@[simps]
def rightUnitor (η : F ⟶ G) : η ≫ 𝟙 G ≅ η :=
  ModificationIso.ofComponents (fun a => ρ_ (η.app a)) (by tidy)
#align category_theory.oplax_nat_trans.right_unitor CategoryTheory.OplaxNatTrans.rightUnitor
-/

end OplaxNatTrans

variable (B C)

#print CategoryTheory.OplaxFunctor.bicategory /-
/-- A bicategory structure on the oplax functors between bicategories. -/
@[simps]
instance OplaxFunctor.bicategory : Bicategory (OplaxFunctor B C)
    where
  whiskerLeft F G H η _ _ Γ := OplaxNatTrans.whiskerLeft η Γ
  whiskerRight F G H _ _ Γ η := OplaxNatTrans.whiskerRight Γ η
  associator F G H I := OplaxNatTrans.associator
  leftUnitor F G := OplaxNatTrans.leftUnitor
  rightUnitor F G := OplaxNatTrans.rightUnitor
  whisker_exchange := by intros; ext; apply whisker_exchange
#align category_theory.oplax_functor.bicategory CategoryTheory.OplaxFunctor.bicategory
-/

end CategoryTheory

