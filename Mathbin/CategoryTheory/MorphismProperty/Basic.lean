/-
Copyright (c) 2022 Andrew Yang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Andrew Yang
-/
import CategoryTheory.Limits.Shapes.Diagonal
import CategoryTheory.Comma.Arrow
import CategoryTheory.Limits.Shapes.Pullback.CommSq
import CategoryTheory.ConcreteCategory.Basic

#align_import category_theory.morphism_property from "leanprover-community/mathlib"@"cb3ceec8485239a61ed51d944cb9a95b68c6bafc"

/-!
# Properties of morphisms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We provide the basic framework for talking about properties of morphisms.
The following meta-properties are defined

* `respects_iso`: `P` respects isomorphisms if `P f → P (e ≫ f)` and `P f → P (f ≫ e)`, where
  `e` is an isomorphism.
* `stable_under_composition`: `P` is stable under composition if `P f → P g → P (f ≫ g)`.
* `stable_under_base_change`: `P` is stable under base change if in all pullback
  squares, the left map satisfies `P` if the right map satisfies it.
* `stable_under_cobase_change`: `P` is stable under cobase change if in all pushout
  squares, the right map satisfies `P` if the left map satisfies it.

-/


universe v u

open CategoryTheory CategoryTheory.Limits Opposite

noncomputable section

namespace CategoryTheory

variable (C : Type u) [Category.{v} C] {D : Type _} [Category D]

#print CategoryTheory.MorphismProperty /-
/-- A `morphism_property C` is a class of morphisms between objects in `C`. -/
def MorphismProperty :=
  ∀ ⦃X Y : C⦄ (f : X ⟶ Y), Prop
deriving CompleteLattice
#align category_theory.morphism_property CategoryTheory.MorphismProperty
-/

instance : Inhabited (MorphismProperty C) :=
  ⟨⊤⟩

variable {C}

namespace MorphismProperty

instance : HasSubset (MorphismProperty C) :=
  ⟨fun P₁ P₂ => ∀ ⦃X Y : C⦄ (f : X ⟶ Y) (hf : P₁ f), P₂ f⟩

instance : Inter (MorphismProperty C) :=
  ⟨fun P₁ P₂ X Y f => P₁ f ∧ P₂ f⟩

#print CategoryTheory.MorphismProperty.op /-
/-- The morphism property in `Cᵒᵖ` associated to a morphism property in `C` -/
@[simp]
def op (P : MorphismProperty C) : MorphismProperty Cᵒᵖ := fun X Y f => P f.unop
#align category_theory.morphism_property.op CategoryTheory.MorphismProperty.op
-/

#print CategoryTheory.MorphismProperty.unop /-
/-- The morphism property in `C` associated to a morphism property in `Cᵒᵖ` -/
@[simp]
def unop (P : MorphismProperty Cᵒᵖ) : MorphismProperty C := fun X Y f => P f.op
#align category_theory.morphism_property.unop CategoryTheory.MorphismProperty.unop
-/

#print CategoryTheory.MorphismProperty.unop_op /-
theorem unop_op (P : MorphismProperty C) : P.op.unop = P :=
  rfl
#align category_theory.morphism_property.unop_op CategoryTheory.MorphismProperty.unop_op
-/

#print CategoryTheory.MorphismProperty.op_unop /-
theorem op_unop (P : MorphismProperty Cᵒᵖ) : P.unop.op = P :=
  rfl
#align category_theory.morphism_property.op_unop CategoryTheory.MorphismProperty.op_unop
-/

#print CategoryTheory.MorphismProperty.inverseImage /-
/-- The inverse image of a `morphism_property D` by a functor `C ⥤ D` -/
def inverseImage (P : MorphismProperty D) (F : C ⥤ D) : MorphismProperty C := fun X Y f =>
  P (F.map f)
#align category_theory.morphism_property.inverse_image CategoryTheory.MorphismProperty.inverseImage
-/

#print CategoryTheory.MorphismProperty.RespectsIso /-
/-- A morphism property `respects_iso` if it still holds when composed with an isomorphism -/
def RespectsIso (P : MorphismProperty C) : Prop :=
  (∀ {X Y Z} (e : X ≅ Y) (f : Y ⟶ Z), P f → P (e.Hom ≫ f)) ∧
    ∀ {X Y Z} (e : Y ≅ Z) (f : X ⟶ Y), P f → P (f ≫ e.Hom)
#align category_theory.morphism_property.respects_iso CategoryTheory.MorphismProperty.RespectsIso
-/

#print CategoryTheory.MorphismProperty.RespectsIso.op /-
theorem RespectsIso.op {P : MorphismProperty C} (h : RespectsIso P) : RespectsIso P.op :=
  ⟨fun X Y Z e f hf => h.2 e.unop f.unop hf, fun X Y Z e f hf => h.1 e.unop f.unop hf⟩
#align category_theory.morphism_property.respects_iso.op CategoryTheory.MorphismProperty.RespectsIso.op
-/

#print CategoryTheory.MorphismProperty.RespectsIso.unop /-
theorem RespectsIso.unop {P : MorphismProperty Cᵒᵖ} (h : RespectsIso P) : RespectsIso P.unop :=
  ⟨fun X Y Z e f hf => h.2 e.op f.op hf, fun X Y Z e f hf => h.1 e.op f.op hf⟩
#align category_theory.morphism_property.respects_iso.unop CategoryTheory.MorphismProperty.RespectsIso.unop
-/

#print CategoryTheory.MorphismProperty.IsStableUnderComposition /-
/-- A morphism property is `stable_under_composition` if the composition of two such morphisms
still falls in the class. -/
def IsStableUnderComposition (P : MorphismProperty C) : Prop :=
  ∀ ⦃X Y Z⦄ (f : X ⟶ Y) (g : Y ⟶ Z), P f → P g → P (f ≫ g)
#align category_theory.morphism_property.stable_under_composition CategoryTheory.MorphismProperty.IsStableUnderComposition
-/

#print CategoryTheory.MorphismProperty.IsStableUnderComposition.op /-
theorem IsStableUnderComposition.op {P : MorphismProperty C} (h : IsStableUnderComposition P) :
    IsStableUnderComposition P.op := fun X Y Z f g hf hg => h g.unop f.unop hg hf
#align category_theory.morphism_property.stable_under_composition.op CategoryTheory.MorphismProperty.IsStableUnderComposition.op
-/

#print CategoryTheory.MorphismProperty.IsStableUnderComposition.unop /-
theorem IsStableUnderComposition.unop {P : MorphismProperty Cᵒᵖ} (h : IsStableUnderComposition P) :
    IsStableUnderComposition P.unop := fun X Y Z f g hf hg => h g.op f.op hg hf
#align category_theory.morphism_property.stable_under_composition.unop CategoryTheory.MorphismProperty.IsStableUnderComposition.unop
-/

#print CategoryTheory.MorphismProperty.StableUnderInverse /-
/-- A morphism property is `stable_under_inverse` if the inverse of a morphism satisfying
the property still falls in the class. -/
def StableUnderInverse (P : MorphismProperty C) : Prop :=
  ∀ ⦃X Y⦄ (e : X ≅ Y), P e.Hom → P e.inv
#align category_theory.morphism_property.stable_under_inverse CategoryTheory.MorphismProperty.StableUnderInverse
-/

#print CategoryTheory.MorphismProperty.StableUnderInverse.op /-
theorem StableUnderInverse.op {P : MorphismProperty C} (h : StableUnderInverse P) :
    StableUnderInverse P.op := fun X Y e he => h e.unop he
#align category_theory.morphism_property.stable_under_inverse.op CategoryTheory.MorphismProperty.StableUnderInverse.op
-/

#print CategoryTheory.MorphismProperty.StableUnderInverse.unop /-
theorem StableUnderInverse.unop {P : MorphismProperty Cᵒᵖ} (h : StableUnderInverse P) :
    StableUnderInverse P.unop := fun X Y e he => h e.op he
#align category_theory.morphism_property.stable_under_inverse.unop CategoryTheory.MorphismProperty.StableUnderInverse.unop
-/

#print CategoryTheory.MorphismProperty.StableUnderBaseChange /-
/-- A morphism property is `stable_under_base_change` if the base change of such a morphism
still falls in the class. -/
def StableUnderBaseChange (P : MorphismProperty C) : Prop :=
  ∀ ⦃X Y Y' S : C⦄ ⦃f : X ⟶ S⦄ ⦃g : Y ⟶ S⦄ ⦃f' : Y' ⟶ Y⦄ ⦃g' : Y' ⟶ X⦄ (sq : IsPullback f' g' g f)
    (hg : P g), P g'
#align category_theory.morphism_property.stable_under_base_change CategoryTheory.MorphismProperty.StableUnderBaseChange
-/

#print CategoryTheory.MorphismProperty.StableUnderCobaseChange /-
/-- A morphism property is `stable_under_cobase_change` if the cobase change of such a morphism
still falls in the class. -/
def StableUnderCobaseChange (P : MorphismProperty C) : Prop :=
  ∀ ⦃A A' B B' : C⦄ ⦃f : A ⟶ A'⦄ ⦃g : A ⟶ B⦄ ⦃f' : B ⟶ B'⦄ ⦃g' : A' ⟶ B'⦄ (sq : IsPushout g f f' g')
    (hf : P f), P f'
#align category_theory.morphism_property.stable_under_cobase_change CategoryTheory.MorphismProperty.StableUnderCobaseChange
-/

#print CategoryTheory.MorphismProperty.respectsIso_of_isStableUnderComposition /-
theorem CategoryTheory.MorphismProperty.respectsIso_of_isStableUnderComposition
    {P : MorphismProperty C} (hP : IsStableUnderComposition P)
    (hP' : ∀ {X Y} (e : X ≅ Y), P e.Hom) : RespectsIso P :=
  ⟨fun X Y Z e f hf => hP _ _ (hP' e) hf, fun X Y Z e f hf => hP _ _ hf (hP' e)⟩
#align category_theory.morphism_property.stable_under_composition.respects_iso CategoryTheory.MorphismProperty.respectsIso_of_isStableUnderComposition
-/

#print CategoryTheory.MorphismProperty.cancel_left_of_respectsIso /-
theorem CategoryTheory.MorphismProperty.cancel_left_of_respectsIso {P : MorphismProperty C}
    (hP : RespectsIso P) {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z) [IsIso f] : P (f ≫ g) ↔ P g :=
  ⟨fun h => by simpa using hP.1 (as_iso f).symm (f ≫ g) h, hP.1 (asIso f) g⟩
#align category_theory.morphism_property.respects_iso.cancel_left_is_iso CategoryTheory.MorphismProperty.cancel_left_of_respectsIso
-/

#print CategoryTheory.MorphismProperty.cancel_right_of_respectsIso /-
theorem CategoryTheory.MorphismProperty.cancel_right_of_respectsIso {P : MorphismProperty C}
    (hP : RespectsIso P) {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z) [IsIso g] : P (f ≫ g) ↔ P f :=
  ⟨fun h => by simpa using hP.2 (as_iso g).symm (f ≫ g) h, hP.2 (asIso g) f⟩
#align category_theory.morphism_property.respects_iso.cancel_right_is_iso CategoryTheory.MorphismProperty.cancel_right_of_respectsIso
-/

#print CategoryTheory.MorphismProperty.arrow_iso_iff /-
theorem CategoryTheory.MorphismProperty.arrow_iso_iff {P : MorphismProperty C} (hP : RespectsIso P)
    {f g : Arrow C} (e : f ≅ g) : P f.Hom ↔ P g.Hom := by
  rw [← arrow.inv_left_hom_right e.hom, hP.cancel_left_is_iso, hP.cancel_right_is_iso]; rfl
#align category_theory.morphism_property.respects_iso.arrow_iso_iff CategoryTheory.MorphismProperty.arrow_iso_iff
-/

#print CategoryTheory.MorphismProperty.arrow_mk_iso_iff /-
theorem CategoryTheory.MorphismProperty.arrow_mk_iso_iff {P : MorphismProperty C}
    (hP : RespectsIso P) {W X Y Z : C} {f : W ⟶ X} {g : Y ⟶ Z} (e : Arrow.mk f ≅ Arrow.mk g) :
    P f ↔ P g :=
  hP.arrow_iso_iff e
#align category_theory.morphism_property.respects_iso.arrow_mk_iso_iff CategoryTheory.MorphismProperty.arrow_mk_iso_iff
-/

#print CategoryTheory.MorphismProperty.RespectsIso.of_respects_arrow_iso /-
theorem RespectsIso.of_respects_arrow_iso (P : MorphismProperty C)
    (hP : ∀ (f g : Arrow C) (e : f ≅ g) (hf : P f.Hom), P g.Hom) : RespectsIso P :=
  by
  constructor
  · intro X Y Z e f hf
    refine' hP (arrow.mk f) (arrow.mk (e.hom ≫ f)) (arrow.iso_mk e.symm (iso.refl _) _) hf
    dsimp
    simp only [iso.inv_hom_id_assoc, category.comp_id]
  · intro X Y Z e f hf
    refine' hP (arrow.mk f) (arrow.mk (f ≫ e.hom)) (arrow.iso_mk (iso.refl _) e _) hf
    dsimp
    simp only [category.id_comp]
#align category_theory.morphism_property.respects_iso.of_respects_arrow_iso CategoryTheory.MorphismProperty.RespectsIso.of_respects_arrow_iso
-/

#print CategoryTheory.MorphismProperty.StableUnderBaseChange.mk /-
theorem StableUnderBaseChange.mk {P : MorphismProperty C} [HasPullbacks C] (hP₁ : RespectsIso P)
    (hP₂ : ∀ (X Y S : C) (f : X ⟶ S) (g : Y ⟶ S) (hg : P g), P (pullback.fst : pullback f g ⟶ X)) :
    StableUnderBaseChange P := fun X Y Y' S f g f' g' sq hg =>
  by
  let e := sq.flip.iso_pullback
  rw [← hP₁.cancel_left_is_iso e.inv, sq.flip.iso_pullback_inv_fst]
  exact hP₂ _ _ _ f g hg
#align category_theory.morphism_property.stable_under_base_change.mk CategoryTheory.MorphismProperty.StableUnderBaseChange.mk
-/

#print CategoryTheory.MorphismProperty.StableUnderBaseChange.respectsIso /-
theorem StableUnderBaseChange.respectsIso {P : MorphismProperty C} (hP : StableUnderBaseChange P) :
    RespectsIso P := by
  apply respects_iso.of_respects_arrow_iso
  intro f g e
  exact hP (is_pullback.of_horiz_is_iso (comm_sq.mk e.inv.w))
#align category_theory.morphism_property.stable_under_base_change.respects_iso CategoryTheory.MorphismProperty.StableUnderBaseChange.respectsIso
-/

#print CategoryTheory.MorphismProperty.StableUnderBaseChange.fst /-
theorem StableUnderBaseChange.fst {P : MorphismProperty C} (hP : StableUnderBaseChange P)
    {X Y S : C} (f : X ⟶ S) (g : Y ⟶ S) [HasPullback f g] (H : P g) :
    P (pullback.fst : pullback f g ⟶ X) :=
  hP (IsPullback.of_hasPullback f g).flip H
#align category_theory.morphism_property.stable_under_base_change.fst CategoryTheory.MorphismProperty.StableUnderBaseChange.fst
-/

#print CategoryTheory.MorphismProperty.StableUnderBaseChange.snd /-
theorem StableUnderBaseChange.snd {P : MorphismProperty C} (hP : StableUnderBaseChange P)
    {X Y S : C} (f : X ⟶ S) (g : Y ⟶ S) [HasPullback f g] (H : P f) :
    P (pullback.snd : pullback f g ⟶ Y) :=
  hP (IsPullback.of_hasPullback f g) H
#align category_theory.morphism_property.stable_under_base_change.snd CategoryTheory.MorphismProperty.StableUnderBaseChange.snd
-/

#print CategoryTheory.MorphismProperty.StableUnderBaseChange.baseChange_obj /-
theorem StableUnderBaseChange.baseChange_obj [HasPullbacks C] {P : MorphismProperty C}
    (hP : StableUnderBaseChange P) {S S' : C} (f : S' ⟶ S) (X : Over S) (H : P X.Hom) :
    P ((pullback f).obj X).Hom :=
  hP.snd X.Hom f H
#align category_theory.morphism_property.stable_under_base_change.base_change_obj CategoryTheory.MorphismProperty.StableUnderBaseChange.baseChange_obj
-/

#print CategoryTheory.MorphismProperty.StableUnderBaseChange.baseChange_map /-
theorem StableUnderBaseChange.baseChange_map [HasPullbacks C] {P : MorphismProperty C}
    (hP : StableUnderBaseChange P) {S S' : C} (f : S' ⟶ S) {X Y : Over S} (g : X ⟶ Y)
    (H : P g.left) : P ((pullback f).map g).left :=
  by
  let e :=
    pullback_right_pullback_fst_iso Y.hom f g.left ≪≫
      pullback.congr_hom (g.w.trans (category.comp_id _)) rfl
  have : e.inv ≫ pullback.snd = ((base_change f).map g).left := by
    apply pullback.hom_ext <;> dsimp <;> simp
  rw [← this, hP.respects_iso.cancel_left_is_iso]
  exact hP.snd _ _ H
#align category_theory.morphism_property.stable_under_base_change.base_change_map CategoryTheory.MorphismProperty.StableUnderBaseChange.baseChange_map
-/

#print CategoryTheory.MorphismProperty.StableUnderBaseChange.pullback_map /-
theorem StableUnderBaseChange.pullback_map [HasPullbacks C] {P : MorphismProperty C}
    (hP : StableUnderBaseChange P) (hP' : IsStableUnderComposition P) {S X X' Y Y' : C} {f : X ⟶ S}
    {g : Y ⟶ S} {f' : X' ⟶ S} {g' : Y' ⟶ S} {i₁ : X ⟶ X'} {i₂ : Y ⟶ Y'} (h₁ : P i₁) (h₂ : P i₂)
    (e₁ : f = i₁ ≫ f') (e₂ : g = i₂ ≫ g') :
    P
      (pullback.map f g f' g' i₁ i₂ (𝟙 _) ((Category.comp_id _).trans e₁)
        ((Category.comp_id _).trans e₂)) :=
  by
  have :
    pullback.map f g f' g' i₁ i₂ (𝟙 _) ((category.comp_id _).trans e₁)
        ((category.comp_id _).trans e₂) =
      ((pullback_symmetry _ _).Hom ≫
          ((base_change _).map (over.hom_mk _ e₂.symm : over.mk g ⟶ over.mk g')).left) ≫
        (pullback_symmetry _ _).Hom ≫
          ((base_change g').map (over.hom_mk _ e₁.symm : over.mk f ⟶ over.mk f')).left :=
    by apply pullback.hom_ext <;> dsimp <;> simp
  rw [this]
  apply hP' <;> rw [hP.respects_iso.cancel_left_is_iso]
  exacts [hP.base_change_map _ (over.hom_mk _ e₂.symm : over.mk g ⟶ over.mk g') h₂,
    hP.base_change_map _ (over.hom_mk _ e₁.symm : over.mk f ⟶ over.mk f') h₁]
#align category_theory.morphism_property.stable_under_base_change.pullback_map CategoryTheory.MorphismProperty.StableUnderBaseChange.pullback_map
-/

#print CategoryTheory.MorphismProperty.StableUnderCobaseChange.mk /-
theorem StableUnderCobaseChange.mk {P : MorphismProperty C} [HasPushouts C] (hP₁ : RespectsIso P)
    (hP₂ : ∀ (A B A' : C) (f : A ⟶ A') (g : A ⟶ B) (hf : P f), P (pushout.inr : B ⟶ pushout f g)) :
    StableUnderCobaseChange P := fun A A' B B' f g f' g' sq hf =>
  by
  let e := sq.flip.iso_pushout
  rw [← hP₁.cancel_right_is_iso _ e.hom, sq.flip.inr_iso_pushout_hom]
  exact hP₂ _ _ _ f g hf
#align category_theory.morphism_property.stable_under_cobase_change.mk CategoryTheory.MorphismProperty.StableUnderCobaseChange.mk
-/

#print CategoryTheory.MorphismProperty.StableUnderCobaseChange.respectsIso /-
theorem StableUnderCobaseChange.respectsIso {P : MorphismProperty C}
    (hP : StableUnderCobaseChange P) : RespectsIso P :=
  RespectsIso.of_respects_arrow_iso _ fun f g e => hP (IsPushout.of_horiz_isIso (CommSq.mk e.Hom.w))
#align category_theory.morphism_property.stable_under_cobase_change.respects_iso CategoryTheory.MorphismProperty.StableUnderCobaseChange.respectsIso
-/

#print CategoryTheory.MorphismProperty.StableUnderCobaseChange.inl /-
theorem StableUnderCobaseChange.inl {P : MorphismProperty C} (hP : StableUnderCobaseChange P)
    {A B A' : C} (f : A ⟶ A') (g : A ⟶ B) [HasPushout f g] (H : P g) :
    P (pushout.inl : A' ⟶ pushout f g) :=
  hP (IsPushout.of_hasPushout f g) H
#align category_theory.morphism_property.stable_under_cobase_change.inl CategoryTheory.MorphismProperty.StableUnderCobaseChange.inl
-/

#print CategoryTheory.MorphismProperty.StableUnderCobaseChange.inr /-
theorem StableUnderCobaseChange.inr {P : MorphismProperty C} (hP : StableUnderCobaseChange P)
    {A B A' : C} (f : A ⟶ A') (g : A ⟶ B) [HasPushout f g] (H : P f) :
    P (pushout.inr : B ⟶ pushout f g) :=
  hP (IsPushout.of_hasPushout f g).flip H
#align category_theory.morphism_property.stable_under_cobase_change.inr CategoryTheory.MorphismProperty.StableUnderCobaseChange.inr
-/

#print CategoryTheory.MorphismProperty.StableUnderCobaseChange.op /-
theorem StableUnderCobaseChange.op {P : MorphismProperty C} (hP : StableUnderCobaseChange P) :
    StableUnderBaseChange P.op := fun X Y Y' S f g f' g' sq hg => hP sq.unop hg
#align category_theory.morphism_property.stable_under_cobase_change.op CategoryTheory.MorphismProperty.StableUnderCobaseChange.op
-/

#print CategoryTheory.MorphismProperty.StableUnderCobaseChange.unop /-
theorem StableUnderCobaseChange.unop {P : MorphismProperty Cᵒᵖ} (hP : StableUnderCobaseChange P) :
    StableUnderBaseChange P.unop := fun X Y Y' S f g f' g' sq hg => hP sq.op hg
#align category_theory.morphism_property.stable_under_cobase_change.unop CategoryTheory.MorphismProperty.StableUnderCobaseChange.unop
-/

#print CategoryTheory.MorphismProperty.StableUnderBaseChange.op /-
theorem StableUnderBaseChange.op {P : MorphismProperty C} (hP : StableUnderBaseChange P) :
    StableUnderCobaseChange P.op := fun A A' B B' f g f' g' sq hf => hP sq.unop hf
#align category_theory.morphism_property.stable_under_base_change.op CategoryTheory.MorphismProperty.StableUnderBaseChange.op
-/

#print CategoryTheory.MorphismProperty.StableUnderBaseChange.unop /-
theorem StableUnderBaseChange.unop {P : MorphismProperty Cᵒᵖ} (hP : StableUnderBaseChange P) :
    StableUnderCobaseChange P.unop := fun A A' B B' f g f' g' sq hf => hP sq.op hf
#align category_theory.morphism_property.stable_under_base_change.unop CategoryTheory.MorphismProperty.StableUnderBaseChange.unop
-/

#print CategoryTheory.MorphismProperty.IsInvertedBy /-
/-- If `P : morphism_property C` and `F : C ⥤ D`, then
`P.is_inverted_by F` means that all morphisms in `P` are mapped by `F`
to isomorphisms in `D`. -/
def IsInvertedBy (P : MorphismProperty C) (F : C ⥤ D) : Prop :=
  ∀ ⦃X Y : C⦄ (f : X ⟶ Y) (hf : P f), IsIso (F.map f)
#align category_theory.morphism_property.is_inverted_by CategoryTheory.MorphismProperty.IsInvertedBy
-/

namespace IsInvertedBy

#print CategoryTheory.MorphismProperty.IsInvertedBy.of_comp /-
theorem of_comp {C₁ C₂ C₃ : Type _} [Category C₁] [Category C₂] [Category C₃]
    (W : MorphismProperty C₁) (F : C₁ ⥤ C₂) (hF : W.IsInvertedBy F) (G : C₂ ⥤ C₃) :
    W.IsInvertedBy (F ⋙ G) := fun X Y f hf => by haveI := hF f hf; dsimp; infer_instance
#align category_theory.morphism_property.is_inverted_by.of_comp CategoryTheory.MorphismProperty.IsInvertedBy.of_comp
-/

#print CategoryTheory.MorphismProperty.IsInvertedBy.op /-
theorem op {W : MorphismProperty C} {L : C ⥤ D} (h : W.IsInvertedBy L) : W.op.IsInvertedBy L.op :=
  fun X Y f hf => by haveI := h f.unop hf; dsimp; infer_instance
#align category_theory.morphism_property.is_inverted_by.op CategoryTheory.MorphismProperty.IsInvertedBy.op
-/

#print CategoryTheory.MorphismProperty.IsInvertedBy.rightOp /-
theorem rightOp {W : MorphismProperty C} {L : Cᵒᵖ ⥤ D} (h : W.op.IsInvertedBy L) :
    W.IsInvertedBy L.rightOp := fun X Y f hf => by haveI := h f.op hf; dsimp; infer_instance
#align category_theory.morphism_property.is_inverted_by.right_op CategoryTheory.MorphismProperty.IsInvertedBy.rightOp
-/

#print CategoryTheory.MorphismProperty.IsInvertedBy.leftOp /-
theorem leftOp {W : MorphismProperty C} {L : C ⥤ Dᵒᵖ} (h : W.IsInvertedBy L) :
    W.op.IsInvertedBy L.leftOp := fun X Y f hf => by haveI := h f.unop hf; dsimp; infer_instance
#align category_theory.morphism_property.is_inverted_by.left_op CategoryTheory.MorphismProperty.IsInvertedBy.leftOp
-/

#print CategoryTheory.MorphismProperty.IsInvertedBy.unop /-
theorem unop {W : MorphismProperty C} {L : Cᵒᵖ ⥤ Dᵒᵖ} (h : W.op.IsInvertedBy L) :
    W.IsInvertedBy L.unop := fun X Y f hf => by haveI := h f.op hf; dsimp; infer_instance
#align category_theory.morphism_property.is_inverted_by.unop CategoryTheory.MorphismProperty.IsInvertedBy.unop
-/

end IsInvertedBy

#print CategoryTheory.MorphismProperty.naturalityProperty /-
/-- Given `app : Π X, F₁.obj X ⟶ F₂.obj X` where `F₁` and `F₂` are two functors,
this is the `morphism_property C` satisfied by the morphisms in `C` with respect
to whom `app` is natural. -/
@[simp]
def naturalityProperty {F₁ F₂ : C ⥤ D} (app : ∀ X, F₁.obj X ⟶ F₂.obj X) : MorphismProperty C :=
  fun X Y f => F₁.map f ≫ app Y = app X ≫ F₂.map f
#align category_theory.morphism_property.naturality_property CategoryTheory.MorphismProperty.naturalityProperty
-/

namespace NaturalityProperty

#print CategoryTheory.MorphismProperty.naturalityProperty.isStableUnderComposition /-
theorem isStableUnderComposition {F₁ F₂ : C ⥤ D} (app : ∀ X, F₁.obj X ⟶ F₂.obj X) :
    (naturalityProperty app).IsStableUnderComposition := fun X Y Z f g hf hg =>
  by
  simp only [naturality_property] at hf hg ⊢
  simp only [functor.map_comp, category.assoc, hg]
  slice_lhs 1 2 => rw [hf]
  rw [category.assoc]
#align category_theory.morphism_property.naturality_property.is_stable_under_composition CategoryTheory.MorphismProperty.naturalityProperty.isStableUnderComposition
-/

#print CategoryTheory.MorphismProperty.naturalityProperty.stableUnderInverse /-
theorem stableUnderInverse {F₁ F₂ : C ⥤ D} (app : ∀ X, F₁.obj X ⟶ F₂.obj X) :
    (naturalityProperty app).StableUnderInverse := fun X Y e he =>
  by
  simp only [naturality_property] at he ⊢
  rw [← cancel_epi (F₁.map e.hom)]
  slice_rhs 1 2 => rw [he]
  simp only [category.assoc, ← F₁.map_comp_assoc, ← F₂.map_comp, e.hom_inv_id, Functor.map_id,
    category.id_comp, category.comp_id]
#align category_theory.morphism_property.naturality_property.is_stable_under_inverse CategoryTheory.MorphismProperty.naturalityProperty.stableUnderInverse
-/

end NaturalityProperty

#print CategoryTheory.MorphismProperty.RespectsIso.inverseImage /-
theorem RespectsIso.inverseImage {P : MorphismProperty D} (h : RespectsIso P) (F : C ⥤ D) :
    RespectsIso (P.inverseImage F) := by
  constructor
  all_goals
    intro X Y Z e f hf
    dsimp [inverse_image]
    rw [F.map_comp]
  exacts [h.1 (F.map_iso e) (F.map f) hf, h.2 (F.map_iso e) (F.map f) hf]
#align category_theory.morphism_property.respects_iso.inverse_image CategoryTheory.MorphismProperty.RespectsIso.inverseImage
-/

#print CategoryTheory.MorphismProperty.IsStableUnderComposition.inverseImage /-
theorem IsStableUnderComposition.inverseImage {P : MorphismProperty D}
    (h : IsStableUnderComposition P) (F : C ⥤ D) : IsStableUnderComposition (P.inverseImage F) :=
  fun X Y Z f g hf hg => by simpa only [← F.map_comp] using h (F.map f) (F.map g) hf hg
#align category_theory.morphism_property.stable_under_composition.inverse_image CategoryTheory.MorphismProperty.IsStableUnderComposition.inverseImage
-/

variable (C)

#print CategoryTheory.MorphismProperty.isomorphisms /-
/-- The `morphism_property C` satisfied by isomorphisms in `C`. -/
def isomorphisms : MorphismProperty C := fun X Y f => IsIso f
#align category_theory.morphism_property.isomorphisms CategoryTheory.MorphismProperty.isomorphisms
-/

#print CategoryTheory.MorphismProperty.monomorphisms /-
/-- The `morphism_property C` satisfied by monomorphisms in `C`. -/
def monomorphisms : MorphismProperty C := fun X Y f => Mono f
#align category_theory.morphism_property.monomorphisms CategoryTheory.MorphismProperty.monomorphisms
-/

#print CategoryTheory.MorphismProperty.epimorphisms /-
/-- The `morphism_property C` satisfied by epimorphisms in `C`. -/
def epimorphisms : MorphismProperty C := fun X Y f => Epi f
#align category_theory.morphism_property.epimorphisms CategoryTheory.MorphismProperty.epimorphisms
-/

section

variable {C} {X Y : C} (f : X ⟶ Y)

#print CategoryTheory.MorphismProperty.isomorphisms.iff /-
@[simp]
theorem isomorphisms.iff : (isomorphisms C) f ↔ IsIso f := by rfl
#align category_theory.morphism_property.isomorphisms.iff CategoryTheory.MorphismProperty.isomorphisms.iff
-/

#print CategoryTheory.MorphismProperty.monomorphisms.iff /-
@[simp]
theorem monomorphisms.iff : (monomorphisms C) f ↔ Mono f := by rfl
#align category_theory.morphism_property.monomorphisms.iff CategoryTheory.MorphismProperty.monomorphisms.iff
-/

#print CategoryTheory.MorphismProperty.epimorphisms.iff /-
@[simp]
theorem epimorphisms.iff : (epimorphisms C) f ↔ Epi f := by rfl
#align category_theory.morphism_property.epimorphisms.iff CategoryTheory.MorphismProperty.epimorphisms.iff
-/

#print CategoryTheory.MorphismProperty.isomorphisms.infer_property /-
theorem isomorphisms.infer_property [hf : IsIso f] : (isomorphisms C) f :=
  hf
#align category_theory.morphism_property.isomorphisms.infer_property CategoryTheory.MorphismProperty.isomorphisms.infer_property
-/

#print CategoryTheory.MorphismProperty.monomorphisms.infer_property /-
theorem monomorphisms.infer_property [hf : Mono f] : (monomorphisms C) f :=
  hf
#align category_theory.morphism_property.monomorphisms.infer_property CategoryTheory.MorphismProperty.monomorphisms.infer_property
-/

#print CategoryTheory.MorphismProperty.epimorphisms.infer_property /-
theorem epimorphisms.infer_property [hf : Epi f] : (epimorphisms C) f :=
  hf
#align category_theory.morphism_property.epimorphisms.infer_property CategoryTheory.MorphismProperty.epimorphisms.infer_property
-/

end

#print CategoryTheory.MorphismProperty.RespectsIso.monomorphisms /-
theorem RespectsIso.monomorphisms : RespectsIso (monomorphisms C) := by
  constructor <;> · intro X Y Z e f; simp only [monomorphisms.iff]; intro; apply mono_comp
#align category_theory.morphism_property.respects_iso.monomorphisms CategoryTheory.MorphismProperty.RespectsIso.monomorphisms
-/

#print CategoryTheory.MorphismProperty.RespectsIso.epimorphisms /-
theorem RespectsIso.epimorphisms : RespectsIso (epimorphisms C) := by
  constructor <;> · intro X Y Z e f; simp only [epimorphisms.iff]; intro; apply epi_comp
#align category_theory.morphism_property.respects_iso.epimorphisms CategoryTheory.MorphismProperty.RespectsIso.epimorphisms
-/

#print CategoryTheory.MorphismProperty.RespectsIso.isomorphisms /-
theorem RespectsIso.isomorphisms : RespectsIso (isomorphisms C) := by
  constructor <;> · intro X Y Z e f; simp only [isomorphisms.iff]; intro; infer_instance
#align category_theory.morphism_property.respects_iso.isomorphisms CategoryTheory.MorphismProperty.RespectsIso.isomorphisms
-/

theorem IsStableUnderComposition.isomorphisms : IsStableUnderComposition (isomorphisms C) :=
  fun X Y Z f g hf hg => by
  rw [isomorphisms.iff] at hf hg ⊢
  haveI := hf
  haveI := hg
  infer_instance
#align category_theory.morphism_property.stable_under_composition.isomorphisms CategoryTheory.MorphismProperty.IsStableUnderComposition.isomorphisms

theorem IsStableUnderComposition.monomorphisms : IsStableUnderComposition (monomorphisms C) :=
  fun X Y Z f g hf hg => by
  rw [monomorphisms.iff] at hf hg ⊢
  haveI := hf
  haveI := hg
  apply mono_comp
#align category_theory.morphism_property.stable_under_composition.monomorphisms CategoryTheory.MorphismProperty.IsStableUnderComposition.monomorphisms

theorem IsStableUnderComposition.epimorphisms : IsStableUnderComposition (epimorphisms C) :=
  fun X Y Z f g hf hg => by
  rw [epimorphisms.iff] at hf hg ⊢
  haveI := hf
  haveI := hg
  apply epi_comp
#align category_theory.morphism_property.stable_under_composition.epimorphisms CategoryTheory.MorphismProperty.IsStableUnderComposition.epimorphisms

variable {C}

#print CategoryTheory.MorphismProperty.FunctorsInverting /-
/-- The full subcategory of `C ⥤ D` consisting of functors inverting morphisms in `W` -/
@[nolint has_nonempty_instance]
def FunctorsInverting (W : MorphismProperty C) (D : Type _) [Category D] :=
  FullSubcategory fun F : C ⥤ D => W.IsInvertedBy F
deriving Category
#align category_theory.morphism_property.functors_inverting CategoryTheory.MorphismProperty.FunctorsInverting
-/

#print CategoryTheory.MorphismProperty.FunctorsInverting.mk /-
/-- A constructor for `W.functors_inverting D` -/
def FunctorsInverting.mk {W : MorphismProperty C} {D : Type _} [Category D] (F : C ⥤ D)
    (hF : W.IsInvertedBy F) : W.FunctorsInverting D :=
  ⟨F, hF⟩
#align category_theory.morphism_property.functors_inverting.mk CategoryTheory.MorphismProperty.FunctorsInverting.mk
-/

#print CategoryTheory.MorphismProperty.IsInvertedBy.iff_of_iso /-
theorem IsInvertedBy.iff_of_iso (W : MorphismProperty C) {F₁ F₂ : C ⥤ D} (e : F₁ ≅ F₂) :
    W.IsInvertedBy F₁ ↔ W.IsInvertedBy F₂ :=
  by
  suffices ∀ (X Y : C) (f : X ⟶ Y), is_iso (F₁.map f) ↔ is_iso (F₂.map f)
    by
    constructor
    exact fun h X Y f hf => by rw [← this]; exact h f hf
    exact fun h X Y f hf => by rw [this]; exact h f hf
  intro X Y f
  exact (respects_iso.isomorphisms D).arrow_mk_iso_iff (arrow.iso_mk (e.app X) (e.app Y) (by simp))
#align category_theory.morphism_property.is_inverted_by.iff_of_iso CategoryTheory.MorphismProperty.IsInvertedBy.iff_of_iso
-/

section Diagonal

variable [HasPullbacks C] {P : MorphismProperty C}

#print CategoryTheory.MorphismProperty.diagonal /-
/-- For `P : morphism_property C`, `P.diagonal` is a morphism property that holds for `f : X ⟶ Y`
whenever `P` holds for `X ⟶ Y xₓ Y`. -/
def diagonal (P : MorphismProperty C) : MorphismProperty C := fun X Y f => P (pullback.diagonal f)
#align category_theory.morphism_property.diagonal CategoryTheory.MorphismProperty.diagonal
-/

#print CategoryTheory.MorphismProperty.diagonal_iff /-
theorem diagonal_iff {X Y : C} {f : X ⟶ Y} : P.diagonal f ↔ P (pullback.diagonal f) :=
  Iff.rfl
#align category_theory.morphism_property.diagonal_iff CategoryTheory.MorphismProperty.diagonal_iff
-/

#print CategoryTheory.MorphismProperty.RespectsIso.diagonal /-
theorem RespectsIso.diagonal (hP : P.RespectsIso) : P.diagonal.RespectsIso :=
  by
  constructor
  · introv H
    rwa [diagonal_iff, pullback.diagonal_comp, hP.cancel_left_is_iso, hP.cancel_left_is_iso, ←
      hP.cancel_right_is_iso _ _, ← pullback.condition, hP.cancel_left_is_iso]
    infer_instance
  · introv H
    delta diagonal
    rwa [pullback.diagonal_comp, hP.cancel_right_is_iso]
#align category_theory.morphism_property.respects_iso.diagonal CategoryTheory.MorphismProperty.RespectsIso.diagonal
-/

#print CategoryTheory.MorphismProperty.diagonal_isStableUnderComposition /-
theorem CategoryTheory.MorphismProperty.diagonal_isStableUnderComposition
    (hP : IsStableUnderComposition P) (hP' : RespectsIso P) (hP'' : StableUnderBaseChange P) :
    P.diagonal.IsStableUnderComposition :=
  by
  introv X h₁ h₂
  rw [diagonal_iff, pullback.diagonal_comp]
  apply hP; · assumption
  rw [hP'.cancel_left_is_iso]
  apply hP''.snd
  assumption
#align category_theory.morphism_property.stable_under_composition.diagonal CategoryTheory.MorphismProperty.diagonal_isStableUnderComposition
-/

#print CategoryTheory.MorphismProperty.StableUnderBaseChange.diagonal /-
theorem StableUnderBaseChange.diagonal (hP : StableUnderBaseChange P) (hP' : RespectsIso P) :
    P.diagonal.StableUnderBaseChange :=
  StableUnderBaseChange.mk hP'.diagonal
    (by
      introv h
      rw [diagonal_iff, diagonal_pullback_fst, hP'.cancel_left_is_iso, hP'.cancel_right_is_iso]
      convert hP.base_change_map f _ _ <;> simp <;> assumption)
#align category_theory.morphism_property.stable_under_base_change.diagonal CategoryTheory.MorphismProperty.StableUnderBaseChange.diagonal
-/

end Diagonal

section Universally

#print CategoryTheory.MorphismProperty.universally /-
/-- `P.universally` holds for a morphism `f : X ⟶ Y` iff `P` holds for all `X ×[Y] Y' ⟶ Y'`. -/
def universally (P : MorphismProperty C) : MorphismProperty C := fun X Y f =>
  ∀ ⦃X' Y' : C⦄ (i₁ : X' ⟶ X) (i₂ : Y' ⟶ Y) (f' : X' ⟶ Y') (h : IsPullback f' i₁ i₂ f), P f'
#align category_theory.morphism_property.universally CategoryTheory.MorphismProperty.universally
-/

#print CategoryTheory.MorphismProperty.universally_respectsIso /-
theorem universally_respectsIso (P : MorphismProperty C) : P.universally.RespectsIso :=
  by
  constructor
  · intro X Y Z e f hf X' Z' i₁ i₂ f' H
    have : is_pullback (𝟙 _) (i₁ ≫ e.hom) i₁ e.inv :=
      is_pullback.of_horiz_is_iso
        ⟨by rw [category.id_comp, category.assoc, e.hom_inv_id, category.comp_id]⟩
    replace this := this.paste_horiz H
    rw [iso.inv_hom_id_assoc, category.id_comp] at this
    exact hf _ _ _ this
  · intro X Y Z e f hf X' Z' i₁ i₂ f' H
    have : is_pullback (𝟙 _) i₂ (i₂ ≫ e.inv) e.inv :=
      is_pullback.of_horiz_is_iso ⟨category.id_comp _⟩
    replace this := H.paste_horiz this
    rw [category.assoc, iso.hom_inv_id, category.comp_id, category.comp_id] at this
    exact hf _ _ _ this
#align category_theory.morphism_property.universally_respects_iso CategoryTheory.MorphismProperty.universally_respectsIso
-/

#print CategoryTheory.MorphismProperty.universally_stableUnderBaseChange /-
theorem universally_stableUnderBaseChange (P : MorphismProperty C) :
    P.universally.StableUnderBaseChange := fun X Y Y' S f g f' g' H h₁ Y'' X'' i₁ i₂ f'' H' =>
  h₁ _ _ _ (H'.paste_vert H.flip)
#align category_theory.morphism_property.universally_stable_under_base_change CategoryTheory.MorphismProperty.universally_stableUnderBaseChange
-/

#print CategoryTheory.MorphismProperty.IsStableUnderComposition.universally /-
theorem IsStableUnderComposition.universally [HasPullbacks C] {P : MorphismProperty C}
    (hP : P.IsStableUnderComposition) : P.universally.IsStableUnderComposition :=
  by
  intro X Y Z f g hf hg X' Z' i₁ i₂ f' H
  have := pullback.lift_fst _ _ (H.w.trans (category.assoc _ _ _).symm)
  rw [← this] at H ⊢
  apply hP _ _ _ (hg _ _ _ <| is_pullback.of_has_pullback _ _)
  exact hf _ _ _ (H.of_right (pullback.lift_snd _ _ _) (is_pullback.of_has_pullback i₂ g))
#align category_theory.morphism_property.stable_under_composition.universally CategoryTheory.MorphismProperty.IsStableUnderComposition.universally
-/

#print CategoryTheory.MorphismProperty.universally_le /-
theorem universally_le (P : MorphismProperty C) : P.universally ≤ P :=
  by
  intro X Y f hf
  exact hf (𝟙 _) (𝟙 _) _ (is_pullback.of_vert_is_iso ⟨by rw [category.comp_id, category.id_comp]⟩)
#align category_theory.morphism_property.universally_le CategoryTheory.MorphismProperty.universally_le
-/

#print CategoryTheory.MorphismProperty.StableUnderBaseChange.universally_eq /-
theorem StableUnderBaseChange.universally_eq {P : MorphismProperty C}
    (hP : P.StableUnderBaseChange) : P.universally = P :=
  P.universally_le.antisymm fun X Y f hf X' Y' i₁ i₂ f' H => hP H.flip hf
#align category_theory.morphism_property.stable_under_base_change.universally_eq CategoryTheory.MorphismProperty.StableUnderBaseChange.universally_eq
-/

#print CategoryTheory.MorphismProperty.universally_mono /-
theorem universally_mono : Monotone (universally : MorphismProperty C → MorphismProperty C) :=
  fun P₁ P₂ h X Y f h₁ X' Y' i₁ i₂ f' H => h _ _ _ (h₁ _ _ _ H)
#align category_theory.morphism_property.universally_mono CategoryTheory.MorphismProperty.universally_mono
-/

end Universally

section Bijective

variable [ConcreteCategory C]

open Function

attribute [local instance] concrete_category.has_coe_to_fun concrete_category.has_coe_to_sort

variable (C)

#print CategoryTheory.MorphismProperty.injective /-
/-- Injectiveness (in a concrete category) as a `morphism_property` -/
protected def injective : MorphismProperty C := fun X Y f => Injective f
#align category_theory.morphism_property.injective CategoryTheory.MorphismProperty.injective
-/

#print CategoryTheory.MorphismProperty.surjective /-
/-- Surjectiveness (in a concrete category) as a `morphism_property` -/
protected def surjective : MorphismProperty C := fun X Y f => Surjective f
#align category_theory.morphism_property.surjective CategoryTheory.MorphismProperty.surjective
-/

#print CategoryTheory.MorphismProperty.bijective /-
/-- Bijectiveness (in a concrete category) as a `morphism_property` -/
protected def bijective : MorphismProperty C := fun X Y f => Bijective f
#align category_theory.morphism_property.bijective CategoryTheory.MorphismProperty.bijective
-/

#print CategoryTheory.MorphismProperty.bijective_eq_sup /-
theorem bijective_eq_sup :
    MorphismProperty.bijective C = MorphismProperty.injective C ⊓ MorphismProperty.surjective C :=
  rfl
#align category_theory.morphism_property.bijective_eq_sup CategoryTheory.MorphismProperty.bijective_eq_sup
-/

theorem injective_isStableUnderComposition :
    (MorphismProperty.injective C).IsStableUnderComposition := fun X Y Z f g hf hg => by
  delta morphism_property.injective; rw [coe_comp]; exact hg.comp hf
#align category_theory.morphism_property.injective_stable_under_composition CategoryTheory.MorphismProperty.injective_isStableUnderComposition

theorem surjective_isStableUnderComposition :
    (MorphismProperty.surjective C).IsStableUnderComposition := fun X Y Z f g hf hg => by
  delta morphism_property.surjective; rw [coe_comp]; exact hg.comp hf
#align category_theory.morphism_property.surjective_stable_under_composition CategoryTheory.MorphismProperty.surjective_isStableUnderComposition

theorem bijective_isStableUnderComposition :
    (MorphismProperty.bijective C).IsStableUnderComposition := fun X Y Z f g hf hg => by
  delta morphism_property.bijective; rw [coe_comp]; exact hg.comp hf
#align category_theory.morphism_property.bijective_stable_under_composition CategoryTheory.MorphismProperty.bijective_isStableUnderComposition

#print CategoryTheory.MorphismProperty.injective_respectsIso /-
theorem injective_respectsIso : (MorphismProperty.injective C).RespectsIso :=
  (injective_isStableUnderComposition C).RespectsIso fun X Y e =>
    ((forget C).mapIso e).toEquiv.Injective
#align category_theory.morphism_property.injective_respects_iso CategoryTheory.MorphismProperty.injective_respectsIso
-/

#print CategoryTheory.MorphismProperty.surjective_respectsIso /-
theorem surjective_respectsIso : (MorphismProperty.surjective C).RespectsIso :=
  (surjective_isStableUnderComposition C).RespectsIso fun X Y e =>
    ((forget C).mapIso e).toEquiv.Surjective
#align category_theory.morphism_property.surjective_respects_iso CategoryTheory.MorphismProperty.surjective_respectsIso
-/

#print CategoryTheory.MorphismProperty.bijective_respectsIso /-
theorem bijective_respectsIso : (MorphismProperty.bijective C).RespectsIso :=
  (bijective_isStableUnderComposition C).RespectsIso fun X Y e =>
    ((forget C).mapIso e).toEquiv.Bijective
#align category_theory.morphism_property.bijective_respects_iso CategoryTheory.MorphismProperty.bijective_respectsIso
-/

end Bijective

end MorphismProperty

end CategoryTheory

