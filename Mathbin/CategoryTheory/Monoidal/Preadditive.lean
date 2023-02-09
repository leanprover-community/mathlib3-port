/-
Copyright (c) 2021 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module category_theory.monoidal.preadditive
! leanprover-community/mathlib commit 0ebfdb71919ac6ca5d7fbc61a082fa2519556818
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Preadditive.AdditiveFunctor
import Mathbin.CategoryTheory.Monoidal.Functor

/-!
# Preadditive monoidal categories

A monoidal category is `monoidal_preadditive` if it is preadditive and tensor product of morphisms
is linear in both factors.
-/


noncomputable section

open Classical

namespace CategoryTheory

open CategoryTheory.Limits

open CategoryTheory.MonoidalCategory

variable (C : Type _) [Category C] [Preadditive C] [MonoidalCategory C]

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- A category is `monoidal_preadditive` if tensoring is additive in both factors.

Note we don't `extend preadditive C` here, as `abelian C` already extends it,
and we'll need to have both typeclasses sometimes.
-/
class MonoidalPreadditive : Prop where
  tensor_zero' : ∀ {W X Y Z : C} (f : W ⟶ X), f ⊗ (0 : Y ⟶ Z) = 0 := by obviously
  zero_tensor' : ∀ {W X Y Z : C} (f : Y ⟶ Z), (0 : W ⟶ X) ⊗ f = 0 := by obviously
  tensor_add' : ∀ {W X Y Z : C} (f : W ⟶ X) (g h : Y ⟶ Z), f ⊗ (g + h) = f ⊗ g + f ⊗ h := by
    obviously
  add_tensor' : ∀ {W X Y Z : C} (f g : W ⟶ X) (h : Y ⟶ Z), (f + g) ⊗ h = f ⊗ h + g ⊗ h := by
    obviously
#align category_theory.monoidal_preadditive CategoryTheory.MonoidalPreadditive

restate_axiom monoidal_preadditive.tensor_zero'

restate_axiom monoidal_preadditive.zero_tensor'

restate_axiom monoidal_preadditive.tensor_add'

restate_axiom monoidal_preadditive.add_tensor'

attribute [simp] monoidal_preadditive.tensor_zero monoidal_preadditive.zero_tensor

variable {C} [MonoidalPreadditive C]

attribute [local simp] monoidal_preadditive.tensor_add monoidal_preadditive.add_tensor

instance tensorLeft_additive (X : C) : (tensorLeft X).Additive where
#align category_theory.tensor_left_additive CategoryTheory.tensorLeft_additive

instance tensorRight_additive (X : C) : (tensorRight X).Additive where
#align category_theory.tensor_right_additive CategoryTheory.tensorRight_additive

instance tensoringLeft_additive (X : C) : ((tensoringLeft C).obj X).Additive where
#align category_theory.tensoring_left_additive CategoryTheory.tensoringLeft_additive

instance tensoringRight_additive (X : C) : ((tensoringRight C).obj X).Additive where
#align category_theory.tensoring_right_additive CategoryTheory.tensoringRight_additive

/-- A faithful additive monoidal functor to a monoidal preadditive category
ensures that the domain is monoidal preadditive. -/
theorem monoidalPreadditive_of_faithful {D} [Category D] [Preadditive D] [MonoidalCategory D]
    (F : MonoidalFunctor D C) [Faithful F.toFunctor] [F.toFunctor.Additive] :
    MonoidalPreadditive D :=
  { tensor_zero' := by
      intros
      apply F.to_functor.map_injective
      simp [F.map_tensor]
    zero_tensor' := by
      intros
      apply F.to_functor.map_injective
      simp [F.map_tensor]
    tensor_add' := by
      intros
      apply F.to_functor.map_injective
      simp only [F.map_tensor, F.to_functor.map_add, Preadditive.comp_add, Preadditive.add_comp,
        MonoidalPreadditive.tensor_add]
    add_tensor' := by
      intros
      apply F.to_functor.map_injective
      simp only [F.map_tensor, F.to_functor.map_add, Preadditive.comp_add, Preadditive.add_comp,
        MonoidalPreadditive.add_tensor] }
#align category_theory.monoidal_preadditive_of_faithful CategoryTheory.monoidalPreadditive_of_faithful

open BigOperators

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem tensor_sum {P Q R S : C} {J : Type _} (s : Finset J) (f : P ⟶ Q) (g : J → (R ⟶ S)) :
    (f ⊗ ∑ j in s, g j) = ∑ j in s, f ⊗ g j :=
  by
  rw [← tensor_id_comp_id_tensor]
  let tQ := (((tensoringLeft C).obj Q).mapAddHom : (R ⟶ S) →+ _)
  change _ ≫ tQ _ = _
  rw [tQ.map_sum, Preadditive.comp_sum]
  dsimp [tQ]
  simp only [tensor_id_comp_id_tensor]
#align category_theory.tensor_sum CategoryTheory.tensor_sum

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem sum_tensor {P Q R S : C} {J : Type _} (s : Finset J) (f : P ⟶ Q) (g : J → (R ⟶ S)) :
    (∑ j in s, g j) ⊗ f = ∑ j in s, g j ⊗ f :=
  by
  rw [← tensor_id_comp_id_tensor]
  let tQ := (((tensoringRight C).obj P).mapAddHom : (R ⟶ S) →+ _)
  change tQ _ ≫ _ = _
  rw [tQ.map_sum, Preadditive.sum_comp]
  dsimp [tQ]
  simp only [tensor_id_comp_id_tensor]
#align category_theory.sum_tensor CategoryTheory.sum_tensor

variable {C}

-- In a closed monoidal category, this would hold because
-- `tensor_left X` is a left adjoint and hence preserves all colimits.
-- In any case it is true in any preadditive category.
instance (X : C) : PreservesFiniteBiproducts (tensorLeft X)
    where preserves J _ :=
    {
      preserves := fun f =>
        {
          preserves := fun b i =>
            isBilimitOfTotal _
              (by
                dsimp
                simp only [← tensor_comp, Category.comp_id, ← tensor_sum, ← tensor_id,
                  IsBilimit.total i]) } }

instance (X : C) : PreservesFiniteBiproducts (tensorRight X)
    where preserves J _ :=
    {
      preserves := fun f =>
        {
          preserves := fun b i =>
            isBilimitOfTotal _
              (by
                dsimp
                simp only [← tensor_comp, Category.comp_id, ← sum_tensor, ← tensor_id,
                  IsBilimit.total i]) } }

variable [HasFiniteBiproducts C]

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- The isomorphism showing how tensor product on the left distributes over direct sums. -/
def leftDistributor {J : Type} [Fintype J] (X : C) (f : J → C) : X ⊗ ⨁ f ≅ ⨁ fun j => X ⊗ f j :=
  (tensorLeft X).mapBiproduct f
#align category_theory.left_distributor CategoryTheory.leftDistributor

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simp]
theorem leftDistributor_hom {J : Type} [Fintype J] (X : C) (f : J → C) :
    (leftDistributor X f).hom = ∑ j : J, (𝟙 X ⊗ biproduct.π f j) ≫ biproduct.ι _ j :=
  by
  ext; dsimp [tensorLeft, leftDistributor]
  simp [Preadditive.sum_comp, biproduct.ι_π, comp_dite]
#align category_theory.left_distributor_hom CategoryTheory.leftDistributor_hom

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simp]
theorem leftDistributor_inv {J : Type} [Fintype J] (X : C) (f : J → C) :
    (leftDistributor X f).inv = ∑ j : J, biproduct.π _ j ≫ (𝟙 X ⊗ biproduct.ι f j) :=
  by
  ext; dsimp [tensorLeft, leftDistributor]
  simp [Preadditive.comp_sum, biproduct.ι_π_assoc, dite_comp]
#align category_theory.left_distributor_inv CategoryTheory.leftDistributor_inv

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem leftDistributor_assoc {J : Type} [Fintype J] (X Y : C) (f : J → C) :
    (asIso (𝟙 X) ⊗ leftDistributor Y f) ≪≫ leftDistributor X _ =
      (α_ X Y (⨁ f)).symm ≪≫ leftDistributor (X ⊗ Y) f ≪≫ biproduct.mapIso fun j => α_ X Y _ :=
  by
  ext
  simp only [Category.comp_id, Category.assoc, eqToHom_refl, Iso.trans_hom, Iso.symm_hom, asIso_hom,
    comp_zero, comp_dite, Preadditive.sum_comp, Preadditive.comp_sum, tensor_sum, id_tensor_comp,
    tensorIso_hom, leftDistributor_hom, biproduct.mapIso_hom, biproduct.ι_map, biproduct.ι_π,
    Finset.sum_dite_irrel, Finset.sum_dite_eq', Finset.sum_const_zero]
  simp only [← id_tensor_comp, biproduct.ι_π]
  simp only [id_tensor_comp, tensor_dite, comp_dite]
  simp only [Category.comp_id, comp_zero, MonoidalPreadditive.tensor_zero, eqToHom_refl, tensor_id,
    if_true, dif_ctx_congr, finset.sum_congr, Finset.mem_univ, Finset.sum_dite_eq']
  simp only [← tensor_id, associator_naturality, Iso.inv_hom_id_assoc]
#align category_theory.left_distributor_assoc CategoryTheory.leftDistributor_assoc

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- The isomorphism showing how tensor product on the right distributes over direct sums. -/
def rightDistributor {J : Type} [Fintype J] (X : C) (f : J → C) : (⨁ f) ⊗ X ≅ ⨁ fun j => f j ⊗ X :=
  (tensorRight X).mapBiproduct f
#align category_theory.right_distributor CategoryTheory.rightDistributor

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simp]
theorem rightDistributor_hom {J : Type} [Fintype J] (X : C) (f : J → C) :
    (rightDistributor X f).hom = ∑ j : J, (biproduct.π f j ⊗ 𝟙 X) ≫ biproduct.ι _ j :=
  by
  ext; dsimp [tensorRight, rightDistributor]
  simp [Preadditive.sum_comp, biproduct.ι_π, comp_dite]
#align category_theory.right_distributor_hom CategoryTheory.rightDistributor_hom

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simp]
theorem rightDistributor_inv {J : Type} [Fintype J] (X : C) (f : J → C) :
    (rightDistributor X f).inv = ∑ j : J, biproduct.π _ j ≫ (biproduct.ι f j ⊗ 𝟙 X) :=
  by
  ext; dsimp [tensorRight, rightDistributor]
  simp [Preadditive.comp_sum, biproduct.ι_π_assoc, dite_comp]
#align category_theory.right_distributor_inv CategoryTheory.rightDistributor_inv

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem rightDistributor_assoc {J : Type} [Fintype J] (X Y : C) (f : J → C) :
    (rightDistributor X f ⊗ asIso (𝟙 Y)) ≪≫ rightDistributor Y _ =
      α_ (⨁ f) X Y ≪≫ rightDistributor (X ⊗ Y) f ≪≫ biproduct.mapIso fun j => (α_ _ X Y).symm :=
  by
  ext
  simp only [Category.comp_id, Category.assoc, eqToHom_refl, Iso.symm_hom, Iso.trans_hom, asIso_hom,
    comp_zero, comp_dite, Preadditive.sum_comp, Preadditive.comp_sum, sum_tensor, comp_tensor_id,
    tensorIso_hom, rightDistributor_hom, biproduct.mapIso_hom, biproduct.ι_map, biproduct.ι_π,
    Finset.sum_dite_irrel, Finset.sum_dite_eq', Finset.sum_const_zero, Finset.mem_univ, if_true]
  simp only [← comp_tensor_id, biproduct.ι_π, dite_tensor, comp_dite]
  simp only [Category.comp_id, comp_tensor_id, eqToHom_refl, tensor_id, comp_zero,
    MonoidalPreadditive.zero_tensor, if_true, dif_ctx_congr, Finset.mem_univ, finset.sum_congr,
    Finset.sum_dite_eq']
  simp only [← tensor_id, associator_inv_naturality, Iso.hom_inv_id_assoc]
#align category_theory.right_distributor_assoc CategoryTheory.rightDistributor_assoc

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem leftDistributor_rightDistributor_assoc {J : Type _} [Fintype J] (X Y : C) (f : J → C) :
    (leftDistributor X f ⊗ asIso (𝟙 Y)) ≪≫ rightDistributor Y _ =
      α_ X (⨁ f) Y ≪≫
        (asIso (𝟙 X) ⊗ rightDistributor Y _) ≪≫
          leftDistributor X _ ≪≫ biproduct.mapIso fun j => (α_ _ _ _).symm :=
  by
  ext
  simp only [Category.comp_id, Category.assoc, eqToHom_refl, Iso.symm_hom, Iso.trans_hom, asIso_hom,
    comp_zero, comp_dite, Preadditive.sum_comp, Preadditive.comp_sum, sum_tensor, tensor_sum,
    comp_tensor_id, tensorIso_hom, leftDistributor_hom, rightDistributor_hom, biproduct.mapIso_hom,
    biproduct.ι_map, biproduct.ι_π, Finset.sum_dite_irrel, Finset.sum_dite_eq',
    Finset.sum_const_zero, Finset.mem_univ, if_true]
  simp only [← comp_tensor_id, ← id_tensor_comp_assoc, Category.assoc, biproduct.ι_π, comp_dite,
    dite_comp, tensor_dite, dite_tensor]
  simp only [Category.comp_id, Category.id_comp, Category.assoc, id_tensor_comp, comp_zero,
    zero_comp, MonoidalPreadditive.tensor_zero, MonoidalPreadditive.zero_tensor, comp_tensor_id,
    eqToHom_refl, tensor_id, if_true, dif_ctx_congr, finset.sum_congr, Finset.mem_univ,
    Finset.sum_dite_eq']
  simp only [associator_inv_naturality, Iso.hom_inv_id_assoc]
#align category_theory.left_distributor_right_distributor_assoc CategoryTheory.leftDistributor_rightDistributor_assoc

end CategoryTheory

