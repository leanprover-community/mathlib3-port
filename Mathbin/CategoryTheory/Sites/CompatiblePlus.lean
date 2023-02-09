/-
Copyright (c) 2021 Adam Topaz. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Adam Topaz

! This file was ported from Lean 3 source module category_theory.sites.compatible_plus
! leanprover-community/mathlib commit 0ebfdb71919ac6ca5d7fbc61a082fa2519556818
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Sites.Whiskering
import Mathbin.CategoryTheory.Sites.Plus

/-!

In this file, we prove that the plus functor is compatible with functors which
preserve the correct limits and colimits.

See `category_theory/sites/compatible_sheafification` for the compatibility
of sheafification, which follows easily from the content in this file.

-/


namespace CategoryTheory.GrothendieckTopology

open CategoryTheory

open CategoryTheory.Limits

open Opposite

universe w₁ w₂ v u

variable {C : Type u} [Category.{v} C] (J : GrothendieckTopology C)

variable {D : Type w₁} [Category.{max v u} D]

variable {E : Type w₂} [Category.{max v u} E]

variable (F : D ⥤ E)

noncomputable section

variable [∀ (α β : Type max v u) (fst snd : β → α), HasLimitsOfShape (WalkingMulticospan fst snd) D]

variable [∀ (α β : Type max v u) (fst snd : β → α), HasLimitsOfShape (WalkingMulticospan fst snd) E]

variable [∀ (X : C) (W : J.Cover X) (P : Cᵒᵖ ⥤ D), PreservesLimit (W.index P).multicospan F]

variable (P : Cᵒᵖ ⥤ D)

/-- The diagram used to define `P⁺`, composed with `F`, is isomorphic
to the diagram used to define `P ⋙ F`. -/
def diagramCompIso (X : C) : J.diagram P X ⋙ F ≅ J.diagram (P ⋙ F) X :=
  NatIso.ofComponents
    (fun W => by
      refine' _ ≪≫ HasLimit.isoOfNatIso (W.unop.multicospan_comp _ _).symm
      refine' (isLimitOfPreserves F (limit.isLimit _)).conePointUniqueUpToIso (limit.isLimit _))
    (by
      intro A B f
      ext
      dsimp
      simp only [Functor.mapCone_π_app, multiequalizer.multifork_π_app_left, Iso.symm_hom,
        multiequalizer.lift_ι, eqToHom_refl, Category.comp_id,
        limit.conePointUniqueUpToIso_hom_comp,
        GrothendieckTopology.Cover.multicospanComp_hom_inv_left, HasLimit.isoOfNatIso_hom_π,
        Category.assoc]
      simp only [← F.map_comp, multiequalizer.lift_ι])
#align category_theory.grothendieck_topology.diagram_comp_iso CategoryTheory.GrothendieckTopology.diagramCompIso

@[simp, reassoc.1]
theorem diagramCompIso_hom_ι (X : C) (W : (J.Cover X)ᵒᵖ) (i : W.unop.Arrow) :
    (J.diagramCompIso F P X).hom.app W ≫ multiequalizer.ι _ i = F.map (multiequalizer.ι _ _) :=
  by
  delta diagram_comp_iso
  dsimp
  simp
#align category_theory.grothendieck_topology.diagram_comp_iso_hom_ι CategoryTheory.GrothendieckTopology.diagramCompIso_hom_ι

variable [∀ X : C, HasColimitsOfShape (J.Cover X)ᵒᵖ D]

variable [∀ X : C, HasColimitsOfShape (J.Cover X)ᵒᵖ E]

variable [∀ X : C, PreservesColimitsOfShape (J.Cover X)ᵒᵖ F]

/-- The isomorphism between `P⁺ ⋙ F` and `(P ⋙ F)⁺`. -/
def plusCompIso : J.plusObj P ⋙ F ≅ J.plusObj (P ⋙ F) :=
  NatIso.ofComponents
    (fun X => by
      refine' _ ≪≫ HasColimit.isoOfNatIso (J.diagram_comp_iso F P X.unop)
      refine'
        (isColimitOfPreserves F (colimit.isColimit (J.diagram P (unop X)))).coconePointUniqueUpToIso
          (colimit.isColimit _))
    (by
      intro X Y f
      apply (isColimitOfPreserves F (colimit.isColimit (J.diagram P X.unop))).hom_ext
      intro W
      dsimp [plusObj, plusMap]
      simp only [Functor.map_comp, Category.assoc]
      slice_rhs 1 2 => erw [(isColimitOfPreserves F (colimit.isColimit (J.diagram P X.unop))).fac]
      slice_lhs 1 3 =>
        simp only [← F.map_comp]
        dsimp [colimMap, IsColimit.map, colimit.pre]
        simp only [colimit.ι_desc_assoc, colimit.ι_desc]
        dsimp [Cocones.precompose]
        rw [Category.assoc, colimit.ι_desc]
        dsimp [Cocone.whisker]
        rw [F.map_comp]
      simp only [Category.assoc]
      slice_lhs 2 3 => erw [(isColimitOfPreserves F (colimit.isColimit (J.diagram P Y.unop))).fac]
      dsimp
      simp only [HasColimit.isoOfNatIso_ι_hom_assoc, GrothendieckTopology.diagramPullback_app,
        colimit.ι_pre, HasColimit.isoOfNatIso_ι_hom, ι_colimMap_assoc]
      simp only [← Category.assoc]
      congr 1
      ext
      dsimp
      simp only [Category.assoc]
      erw [multiequalizer.lift_ι, diagramCompIso_hom_ι, diagramCompIso_hom_ι, ← F.map_comp,
        multiequalizer.lift_ι])
#align category_theory.grothendieck_topology.plus_comp_iso CategoryTheory.GrothendieckTopology.plusCompIso

@[simp, reassoc.1]
theorem ι_plusCompIso_hom (X) (W) :
    F.map (colimit.ι _ W) ≫ (J.plusCompIso F P).hom.app X =
      (J.diagramCompIso F P X.unop).hom.app W ≫ colimit.ι _ W :=
  by
  delta diagram_comp_iso plus_comp_iso
  simp only [IsColimit.descCoconeMorphism_hom, IsColimit.uniqueUpToIso_hom, Cocones.forget_map,
    Iso.trans_hom, NatIso.ofComponents_hom_app, Functor.mapIso_hom, ← Category.assoc]
  erw [(isColimitOfPreserves F (colimit.isColimit (J.diagram P (unop X)))).fac]
  simp only [Category.assoc, HasLimit.isoOfNatIso_hom_π, Iso.symm_hom,
    Cover.multicospanComp_hom_inv_left, eqToHom_refl, Category.comp_id,
    limit.conePointUniqueUpToIso_hom_comp, Functor.mapCone_π_app,
    multiequalizer.multifork_π_app_left, multiequalizer.lift_ι, Functor.map_comp, eq_self_iff_true,
    Category.assoc, Iso.trans_hom, Iso.cancel_iso_hom_left, NatIso.ofComponents_hom_app,
    colimit.cocone_ι, Category.assoc, HasColimit.isoOfNatIso_ι_hom]
#align category_theory.grothendieck_topology.ι_plus_comp_iso_hom CategoryTheory.GrothendieckTopology.ι_plusCompIso_hom

@[simp, reassoc.1]
theorem plusCompIso_whiskerLeft {F G : D ⥤ E} (η : F ⟶ G) (P : Cᵒᵖ ⥤ D)
    [∀ X : C, PreservesColimitsOfShape (J.Cover X)ᵒᵖ F]
    [∀ (X : C) (W : J.Cover X) (P : Cᵒᵖ ⥤ D), PreservesLimit (W.index P).multicospan F]
    [∀ X : C, PreservesColimitsOfShape (J.Cover X)ᵒᵖ G]
    [∀ (X : C) (W : J.Cover X) (P : Cᵒᵖ ⥤ D), PreservesLimit (W.index P).multicospan G] :
    whiskerLeft _ η ≫ (J.plusCompIso G P).hom =
      (J.plusCompIso F P).hom ≫ J.plusMap (whiskerLeft _ η) :=
  by
  ext X
  apply (isColimitOfPreserves F (colimit.isColimit (J.diagram P X.unop))).hom_ext
  intro W
  dsimp [plusObj, plusMap]
  simp only [ι_plusCompIso_hom, ι_colimMap, whiskerLeft_app, ι_plusCompIso_hom_assoc,
    NatTrans.naturality_assoc, GrothendieckTopology.diagramNatTrans_app]
  simp only [← Category.assoc]
  congr 1
  ext
  dsimp
  simpa
#align category_theory.grothendieck_topology.plus_comp_iso_whisker_left CategoryTheory.GrothendieckTopology.plusCompIso_whiskerLeft

/-- The isomorphism between `P⁺ ⋙ F` and `(P ⋙ F)⁺`, functorially in `F`. -/
@[simps hom_app inv_app]
def plusFunctorWhiskerLeftIso (P : Cᵒᵖ ⥤ D)
    [∀ (F : D ⥤ E) (X : C), PreservesColimitsOfShape (J.Cover X)ᵒᵖ F]
    [∀ (F : D ⥤ E) (X : C) (W : J.Cover X) (P : Cᵒᵖ ⥤ D),
        PreservesLimit (W.index P).multicospan F] :
    (whiskeringLeft _ _ E).obj (J.plusObj P) ≅ (whiskeringLeft _ _ _).obj P ⋙ J.plusFunctor E :=
  NatIso.ofComponents (fun X => plusCompIso _ _ _) fun F G η => plusCompIso_whiskerLeft _ _ _
#align category_theory.grothendieck_topology.plus_functor_whisker_left_iso CategoryTheory.GrothendieckTopology.plusFunctorWhiskerLeftIso

@[simp, reassoc.1]
theorem plusCompIso_whiskerRight {P Q : Cᵒᵖ ⥤ D} (η : P ⟶ Q) :
    whiskerRight (J.plusMap η) F ≫ (J.plusCompIso F Q).hom =
      (J.plusCompIso F P).hom ≫ J.plusMap (whiskerRight η F) :=
  by
  ext X
  apply (isColimitOfPreserves F (colimit.isColimit (J.diagram P X.unop))).hom_ext
  intro W
  dsimp [plusObj, plusMap]
  simp only [ι_colimMap, whiskerRight_app, ι_plusCompIso_hom_assoc,
    GrothendieckTopology.diagramNatTrans_app]
  simp only [← Category.assoc, ← F.map_comp]
  dsimp [colimMap, IsColimit.map]
  simp only [colimit.ι_desc]
  dsimp [Cocones.precompose]
  simp only [Functor.map_comp, Category.assoc, ι_plusCompIso_hom]
  simp only [← Category.assoc]
  congr 1
  ext
  dsimp
  simp only [diagramCompIso_hom_ι_assoc, multiequalizer.lift_ι, diagramCompIso_hom_ι,
    Category.assoc]
  simp only [← F.map_comp, multiequalizer.lift_ι]
#align category_theory.grothendieck_topology.plus_comp_iso_whisker_right CategoryTheory.GrothendieckTopology.plusCompIso_whiskerRight

/-- The isomorphism between `P⁺ ⋙ F` and `(P ⋙ F)⁺`, functorially in `P`. -/
@[simps hom_app inv_app]
def plusFunctorWhiskerRightIso :
    J.plusFunctor D ⋙ (whiskeringRight _ _ _).obj F ≅
      (whiskeringRight _ _ _).obj F ⋙ J.plusFunctor E :=
  NatIso.ofComponents (fun P => J.plusCompIso _ _) fun P Q η => plusCompIso_whiskerRight _ _ _
#align category_theory.grothendieck_topology.plus_functor_whisker_right_iso CategoryTheory.GrothendieckTopology.plusFunctorWhiskerRightIso

@[simp, reassoc.1]
theorem whiskerRight_toPlus_comp_plusCompIso_hom :
    whiskerRight (J.toPlus _) _ ≫ (J.plusCompIso F P).hom = J.toPlus _ :=
  by
  ext
  dsimp [toPlus]
  simp only [ι_plusCompIso_hom, Functor.map_comp, Category.assoc]
  simp only [← Category.assoc]
  congr 1
  ext
  delta cover.to_multiequalizer
  simp only [diagramCompIso_hom_ι, Category.assoc, ← F.map_comp]
  erw [multiequalizer.lift_ι, multiequalizer.lift_ι]
  rfl
#align category_theory.grothendieck_topology.whisker_right_to_plus_comp_plus_comp_iso_hom CategoryTheory.GrothendieckTopology.whiskerRight_toPlus_comp_plusCompIso_hom

@[simp]
theorem toPlus_comp_plusCompIso_inv :
    J.toPlus _ ≫ (J.plusCompIso F P).inv = whiskerRight (J.toPlus _) _ := by simp [Iso.comp_inv_eq]
#align category_theory.grothendieck_topology.to_plus_comp_plus_comp_iso_inv CategoryTheory.GrothendieckTopology.toPlus_comp_plusCompIso_inv

theorem plusCompIso_inv_eq_plusLift (hP : Presheaf.IsSheaf J (J.plusObj P ⋙ F)) :
    (J.plusCompIso F P).inv = J.plusLift (whiskerRight (J.toPlus _) _) hP :=
  by
  apply J.plus_lift_unique
  simp [Iso.comp_inv_eq]
#align category_theory.grothendieck_topology.plus_comp_iso_inv_eq_plus_lift CategoryTheory.GrothendieckTopology.plusCompIso_inv_eq_plusLift

end CategoryTheory.GrothendieckTopology

