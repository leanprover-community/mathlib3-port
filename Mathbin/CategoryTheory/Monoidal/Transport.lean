/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module category_theory.monoidal.transport
! leanprover-community/mathlib commit 0ebfdb71919ac6ca5d7fbc61a082fa2519556818
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Monoidal.NaturalTransformation

/-!
# Transport a monoidal structure along an equivalence.

When `C` and `D` are equivalent as categories,
we can transport a monoidal structure on `C` along the equivalence,
obtaining a monoidal structure on `D`.

We then upgrade the original functor and its inverse to monoidal functors
with respect to the new monoidal structure on `D`.
-/


universe v₁ v₂ u₁ u₂

noncomputable section

open CategoryTheory

open CategoryTheory.Category

open CategoryTheory.MonoidalCategory

namespace CategoryTheory.Monoidal

variable {C : Type u₁} [Category.{v₁} C] [MonoidalCategory.{v₁} C]

variable {D : Type u₂} [Category.{v₂} D]

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
-- We just want these simp lemmas locally
/-- Transport a monoidal structure along an equivalence of (plain) categories.
-/
@[simps (config := { attrs := [`_refl_lemma] })]
def transport (e : C ≌ D) : MonoidalCategory.{v₂} D
    where
  tensorObj X Y := e.functor.obj (e.inverse.obj X ⊗ e.inverse.obj Y)
  tensorHom W X Y Z f g := e.functor.map (e.inverse.map f ⊗ e.inverse.map g)
  tensorUnit := e.functor.obj (𝟙_ C)
  associator X Y Z :=
    e.functor.mapIso
      (((e.unitIso.app _).symm ⊗ Iso.refl _) ≪≫
        α_ (e.inverse.obj X) (e.inverse.obj Y) (e.inverse.obj Z) ≪≫ (Iso.refl _ ⊗ e.unitIso.app _))
  leftUnitor X :=
    e.functor.mapIso (((e.unitIso.app _).symm ⊗ Iso.refl _) ≪≫ λ_ (e.inverse.obj X)) ≪≫
      e.counitIso.app _
  rightUnitor X :=
    e.functor.mapIso ((Iso.refl _ ⊗ (e.unitIso.app _).symm) ≪≫ ρ_ (e.inverse.obj X)) ≪≫
      e.counitIso.app _
  triangle' X Y := by
    dsimp
    simp only [Iso.hom_inv_id_app_assoc, comp_tensor_id, Equivalence.unit_inverse_comp, assoc,
      Equivalence.inv_fun_map, comp_id, Functor.map_comp, id_tensor_comp, e.inverse.map_id]
    simp only [← e.functor.map_comp]
    congr 2
    slice_lhs 2 3 =>
      rw [← id_tensor_comp]
      simp
      dsimp
      rw [tensor_id]
    rw [Category.id_comp, ← associator_naturality_assoc, triangle]
  pentagon' W X Y Z := by
    dsimp
    simp only [Iso.hom_inv_id_app_assoc, comp_tensor_id, assoc, Equivalence.inv_fun_map,
      Functor.map_comp, id_tensor_comp, e.inverse.map_id]
    simp only [← e.functor.map_comp]
    congr 2
    slice_lhs 4 5 =>
      rw [← comp_tensor_id, Iso.hom_inv_id_app]
      dsimp
      rw [tensor_id]
    simp only [Category.id_comp, Category.assoc]
    slice_lhs 5 6 =>
      rw [← id_tensor_comp, Iso.hom_inv_id_app]
      dsimp
      rw [tensor_id]
    simp only [Category.id_comp, Category.assoc]
    slice_rhs 2 3 => rw [id_tensor_comp_tensor_id, ← tensor_id_comp_id_tensor]
    slice_rhs 1 2 => rw [← tensor_id, ← associator_naturality]
    slice_rhs 3 4 => rw [← tensor_id, associator_naturality]
    slice_rhs 2 3 => rw [← pentagon]
    simp only [Category.assoc]
    congr 2
    slice_lhs 1 2 => rw [associator_naturality]
    simp only [Category.assoc]
    congr 1
    slice_lhs 1 2 =>
      rw [← id_tensor_comp, ← comp_tensor_id, Iso.hom_inv_id_app]
      dsimp
      rw [tensor_id, tensor_id]
    simp only [Category.id_comp, Category.assoc]
  leftUnitor_naturality' X Y f := by
    dsimp
    simp only [Functor.map_comp, Functor.map_id, Category.assoc]
    erw [← e.counit_iso.hom.naturality]
    simp only [Functor.comp_map, ← e.functor.map_comp_assoc]
    congr 2
    rw [e.inverse.map_id, id_tensor_comp_tensor_id_assoc, ← tensor_id_comp_id_tensor_assoc,
      leftUnitor_naturality]
  rightUnitor_naturality' X Y f := by
    dsimp
    simp only [Functor.map_comp, Functor.map_id, Category.assoc]
    erw [← e.counit_iso.hom.naturality]
    simp only [Functor.comp_map, ← e.functor.map_comp_assoc]
    congr 2
    rw [e.inverse.map_id, tensor_id_comp_id_tensor_assoc, ← id_tensor_comp_tensor_id_assoc,
      rightUnitor_naturality]
  associator_naturality' X₁ X₂ X₃ Y₁ Y₂ Y₃ f₁ f₂ f₃ :=
    by
    dsimp
    simp only [Equivalence.inv_fun_map, Functor.map_comp, Category.assoc]
    simp only [← e.functor.map_comp]
    congr 1
    conv_lhs => rw [← tensor_id_comp_id_tensor]
    slice_lhs 2 3 => rw [id_tensor_comp_tensor_id, ← tensor_id_comp_id_tensor, ← tensor_id]
    simp only [Category.assoc]
    slice_lhs 3 4 => rw [associator_naturality]
    conv_lhs => simp only [comp_tensor_id]
    slice_lhs 3 4 =>
      rw [← comp_tensor_id, Iso.hom_inv_id_app]
      dsimp
      rw [tensor_id]
    simp only [Category.id_comp, Category.assoc]
    slice_lhs 2 3 => rw [associator_naturality]
    simp only [Category.assoc]
    congr 2
    slice_lhs 1 1 => rw [← tensor_id_comp_id_tensor]
    slice_lhs 2 3 => rw [← id_tensor_comp, tensor_id_comp_id_tensor]
    slice_lhs 1 2 => rw [tensor_id_comp_id_tensor]
    conv_rhs =>
      congr
      skip
      rw [← id_tensor_comp_tensor_id, id_tensor_comp]
    simp only [Category.assoc]
    slice_rhs 1 2 =>
      rw [← id_tensor_comp, Iso.hom_inv_id_app]
      dsimp
      rw [tensor_id]
    simp only [Category.id_comp, Category.assoc]
    conv_rhs => rw [id_tensor_comp]
    slice_rhs 2 3 => rw [id_tensor_comp_tensor_id, ← tensor_id_comp_id_tensor]
    slice_rhs 1 2 => rw [id_tensor_comp_tensor_id]
#align category_theory.monoidal.transport CategoryTheory.Monoidal.transport

/-- A type synonym for `D`, which will carry the transported monoidal structure. -/
@[nolint unused_arguments]
def Transported (e : C ≌ D) :=
  D deriving Category
#align category_theory.monoidal.transported CategoryTheory.Monoidal.Transported

instance (e : C ≌ D) : MonoidalCategory (Transported e) :=
  transport e

instance (e : C ≌ D) : Inhabited (Transported e) :=
  ⟨𝟙_ _⟩

section

attribute [local simp] transport_tensor_unit

section

attribute [local simp]
  transport_tensor_hom transport_associator transport_left_unitor transport_right_unitor

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/--
We can upgrade `e.functor` to a lax monoidal functor from `C` to `D` with the transported structure.
-/
@[simps]
def laxToTransported (e : C ≌ D) : LaxMonoidalFunctor C (Transported e)
    where
  toFunctor := e.functor
  ε := 𝟙 (e.functor.obj (𝟙_ C))
  μ X Y := e.functor.map (e.unitInv.app X ⊗ e.unitInv.app Y)
  μ_natural' X Y X' Y' f g := by
    dsimp
    simp only [Equivalence.inv_fun_map, Functor.map_comp, tensor_comp, Category.assoc]
    simp only [← e.functor.map_comp]
    congr 1
    rw [← tensor_comp, Iso.hom_inv_id_app, Iso.hom_inv_id_app, ← tensor_comp]
    dsimp
    rw [comp_id, comp_id]
  associativity' X Y Z := by
    dsimp
    simp only [comp_tensor_id, assoc, Equivalence.inv_fun_map, Functor.map_comp, id_tensor_comp,
      e.inverse.map_id]
    simp only [← e.functor.map_comp]
    congr 2
    slice_lhs 3 3 => rw [← tensor_id_comp_id_tensor]
    slice_lhs 2 3 =>
      rw [← comp_tensor_id, Iso.hom_inv_id_app]
      dsimp
      rw [tensor_id]
    simp only [id_comp]
    slice_rhs 2 3 =>
      rw [← id_tensor_comp, Iso.hom_inv_id_app]
      dsimp
      rw [tensor_id]
    simp only [id_comp]
    conv_rhs => rw [← id_tensor_comp_tensor_id _ (e.unit_inv.app X)]
    dsimp only [Functor.comp_obj]
    slice_rhs 3 4 =>
      rw [← id_tensor_comp, Iso.hom_inv_id_app]
      dsimp
      rw [tensor_id]
    simp only [associator_conjugation, ← tensor_id, ← tensor_comp, Iso.inv_hom_id,
      Iso.inv_hom_id_assoc, Category.assoc, Category.id_comp, Category.comp_id]
  left_unitality' X := by
    dsimp
    simp only [tensor_id, assoc, id_comp, Functor.map_comp, e.inverse.map_id]
    rw [Equivalence.counit_app_functor]
    simp only [← e.functor.map_comp]
    congr 1
    simp only [← leftUnitor_naturality, id_comp, ← tensor_comp_assoc, comp_id]
  right_unitality' X := by
    dsimp
    simp only [tensor_id, assoc, id_comp, Functor.map_comp, e.inverse.map_id]
    rw [Equivalence.counit_app_functor]
    simp only [← e.functor.map_comp]
    congr 1
    simp only [← rightUnitor_naturality, id_comp, ← tensor_comp_assoc, comp_id]
#align category_theory.monoidal.lax_to_transported CategoryTheory.Monoidal.laxToTransported

end

/-- We can upgrade `e.functor` to a monoidal functor from `C` to `D` with the transported structure.
-/
@[simps]
def toTransported (e : C ≌ D) : MonoidalFunctor C (Transported e)
    where
  toLaxMonoidalFunctor := laxToTransported e
  ε_isIso := by
    dsimp
    infer_instance
  μ_isIso X Y := by
    dsimp
    infer_instance
#align category_theory.monoidal.to_transported CategoryTheory.Monoidal.toTransported

end

instance (e : C ≌ D) : IsEquivalence (toTransported e).toFunctor :=
  by
  dsimp
  infer_instance

/-- We can upgrade `e.inverse` to a monoidal functor from `D` with the transported structure to `C`.
-/
@[simps]
def fromTransported (e : C ≌ D) : MonoidalFunctor (Transported e) C :=
  monoidalInverse (toTransported e)
#align category_theory.monoidal.from_transported CategoryTheory.Monoidal.fromTransported

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- The unit isomorphism upgrades to a monoidal isomorphism. -/
@[simps]
def transportedMonoidalUnitIso (e : C ≌ D) :
    LaxMonoidalFunctor.id C ≅ laxToTransported e ⊗⋙ (fromTransported e).toLaxMonoidalFunctor :=
  asIso (monoidalUnit (toTransported e))
#align category_theory.monoidal.transported_monoidal_unit_iso CategoryTheory.Monoidal.transportedMonoidalUnitIso

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- The counit isomorphism upgrades to a monoidal isomorphism. -/
@[simps]
def transportedMonoidalCounitIso (e : C ≌ D) :
    (fromTransported e).toLaxMonoidalFunctor ⊗⋙ laxToTransported e ≅
      LaxMonoidalFunctor.id (Transported e) :=
  asIso (monoidalCounit (toTransported e))
#align category_theory.monoidal.transported_monoidal_counit_iso CategoryTheory.Monoidal.transportedMonoidalCounitIso

end CategoryTheory.Monoidal

