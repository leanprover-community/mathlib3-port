/-
Copyright (c) 2017 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Massot, Scott Morrison, Mario Carneiro, Andrew Yang

! This file was ported from Lean 3 source module topology.category.Top.limits.pullbacks
! leanprover-community/mathlib commit 6cf5900728239efa287df7761ec2a1ac9cf39b29
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Category.Top.Limits.Products
import Mathbin.CategoryTheory.ConcreteCategory.Elementwise

/-!
# Pullbacks in the category of topological spaces.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

-/


open TopologicalSpace

open CategoryTheory

open CategoryTheory.Limits

universe u v w

noncomputable section

namespace TopCat

variable {J : Type v} [SmallCategory J]

section Pullback

variable {X Y Z : TopCat.{u}}

/- warning: Top.pullback_fst -> TopCat.pullbackFst is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.pullback_fst TopCat.pullbackFstₓ'. -/
/-- The first projection from the pullback. -/
abbrev pullbackFst (f : X ⟶ Z) (g : Y ⟶ Z) : TopCat.of { p : X × Y // f p.1 = g p.2 } ⟶ X :=
  ⟨Prod.fst ∘ Subtype.val⟩
#align Top.pullback_fst TopCat.pullbackFst

/- warning: Top.pullback_snd -> TopCat.pullbackSnd is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.pullback_snd TopCat.pullbackSndₓ'. -/
/-- The second projection from the pullback. -/
abbrev pullbackSnd (f : X ⟶ Z) (g : Y ⟶ Z) : TopCat.of { p : X × Y // f p.1 = g p.2 } ⟶ Y :=
  ⟨Prod.snd ∘ Subtype.val⟩
#align Top.pullback_snd TopCat.pullbackSnd

#print TopCat.pullbackCone /-
/-- The explicit pullback cone of `X, Y` given by `{ p : X × Y // f p.1 = g p.2 }`. -/
def pullbackCone (f : X ⟶ Z) (g : Y ⟶ Z) : PullbackCone f g :=
  PullbackCone.mk (pullbackFst f g) (pullbackSnd f g) (by ext ⟨x, h⟩; simp [h])
#align Top.pullback_cone TopCat.pullbackCone
-/

#print TopCat.pullbackConeIsLimit /-
/-- The constructed cone is a limit. -/
def pullbackConeIsLimit (f : X ⟶ Z) (g : Y ⟶ Z) : IsLimit (pullbackCone f g) :=
  PullbackCone.isLimitAux' _
    (by
      intro s
      constructor; swap
      exact
        {
          toFun := fun x =>
            ⟨⟨s.fst x, s.snd x⟩, by simpa using concrete_category.congr_hom s.condition x⟩ }
      refine' ⟨_, _, _⟩
      · ext; delta pullback_cone; simp
      · ext; delta pullback_cone; simp
      · intro m h₁ h₂
        ext x
        · simpa using concrete_category.congr_hom h₁ x
        · simpa using concrete_category.congr_hom h₂ x)
#align Top.pullback_cone_is_limit TopCat.pullbackConeIsLimit
-/

/- warning: Top.pullback_iso_prod_subtype -> TopCat.pullbackIsoProdSubtype is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.pullback_iso_prod_subtype TopCat.pullbackIsoProdSubtypeₓ'. -/
/-- The pullback of two maps can be identified as a subspace of `X × Y`. -/
def pullbackIsoProdSubtype (f : X ⟶ Z) (g : Y ⟶ Z) :
    pullback f g ≅ TopCat.of { p : X × Y // f p.1 = g p.2 } :=
  (limit.isLimit _).conePointUniqueUpToIso (pullbackConeIsLimit f g)
#align Top.pullback_iso_prod_subtype TopCat.pullbackIsoProdSubtype

/- warning: Top.pullback_iso_prod_subtype_inv_fst -> TopCat.pullbackIsoProdSubtype_inv_fst is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.pullback_iso_prod_subtype_inv_fst TopCat.pullbackIsoProdSubtype_inv_fstₓ'. -/
@[simp, reassoc]
theorem pullbackIsoProdSubtype_inv_fst (f : X ⟶ Z) (g : Y ⟶ Z) :
    (pullbackIsoProdSubtype f g).inv ≫ pullback.fst = pullbackFst f g := by
  simpa [pullback_iso_prod_subtype]
#align Top.pullback_iso_prod_subtype_inv_fst TopCat.pullbackIsoProdSubtype_inv_fst

/- warning: Top.pullback_iso_prod_subtype_inv_fst_apply -> TopCat.pullbackIsoProdSubtype_inv_fst_apply is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.pullback_iso_prod_subtype_inv_fst_apply TopCat.pullbackIsoProdSubtype_inv_fst_applyₓ'. -/
@[simp]
theorem pullbackIsoProdSubtype_inv_fst_apply (f : X ⟶ Z) (g : Y ⟶ Z)
    (x : { p : X × Y // f p.1 = g p.2 }) :
    (pullback.fst : pullback f g ⟶ _) ((pullbackIsoProdSubtype f g).inv x) = (x : X × Y).fst :=
  ConcreteCategory.congr_hom (pullbackIsoProdSubtype_inv_fst f g) x
#align Top.pullback_iso_prod_subtype_inv_fst_apply TopCat.pullbackIsoProdSubtype_inv_fst_apply

/- warning: Top.pullback_iso_prod_subtype_inv_snd -> TopCat.pullbackIsoProdSubtype_inv_snd is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.pullback_iso_prod_subtype_inv_snd TopCat.pullbackIsoProdSubtype_inv_sndₓ'. -/
@[simp, reassoc]
theorem pullbackIsoProdSubtype_inv_snd (f : X ⟶ Z) (g : Y ⟶ Z) :
    (pullbackIsoProdSubtype f g).inv ≫ pullback.snd = pullbackSnd f g := by
  simpa [pullback_iso_prod_subtype]
#align Top.pullback_iso_prod_subtype_inv_snd TopCat.pullbackIsoProdSubtype_inv_snd

/- warning: Top.pullback_iso_prod_subtype_inv_snd_apply -> TopCat.pullbackIsoProdSubtype_inv_snd_apply is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.pullback_iso_prod_subtype_inv_snd_apply TopCat.pullbackIsoProdSubtype_inv_snd_applyₓ'. -/
@[simp]
theorem pullbackIsoProdSubtype_inv_snd_apply (f : X ⟶ Z) (g : Y ⟶ Z)
    (x : { p : X × Y // f p.1 = g p.2 }) :
    (pullback.snd : pullback f g ⟶ _) ((pullbackIsoProdSubtype f g).inv x) = (x : X × Y).snd :=
  ConcreteCategory.congr_hom (pullbackIsoProdSubtype_inv_snd f g) x
#align Top.pullback_iso_prod_subtype_inv_snd_apply TopCat.pullbackIsoProdSubtype_inv_snd_apply

#print TopCat.pullbackIsoProdSubtype_hom_fst /-
theorem pullbackIsoProdSubtype_hom_fst (f : X ⟶ Z) (g : Y ⟶ Z) :
    (pullbackIsoProdSubtype f g).Hom ≫ pullbackFst f g = pullback.fst := by
  rw [← iso.eq_inv_comp, pullback_iso_prod_subtype_inv_fst]
#align Top.pullback_iso_prod_subtype_hom_fst TopCat.pullbackIsoProdSubtype_hom_fst
-/

#print TopCat.pullbackIsoProdSubtype_hom_snd /-
theorem pullbackIsoProdSubtype_hom_snd (f : X ⟶ Z) (g : Y ⟶ Z) :
    (pullbackIsoProdSubtype f g).Hom ≫ pullbackSnd f g = pullback.snd := by
  rw [← iso.eq_inv_comp, pullback_iso_prod_subtype_inv_snd]
#align Top.pullback_iso_prod_subtype_hom_snd TopCat.pullbackIsoProdSubtype_hom_snd
-/

/- warning: Top.pullback_iso_prod_subtype_hom_apply -> TopCat.pullbackIsoProdSubtype_hom_apply is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.pullback_iso_prod_subtype_hom_apply TopCat.pullbackIsoProdSubtype_hom_applyₓ'. -/
@[simp]
theorem pullbackIsoProdSubtype_hom_apply {f : X ⟶ Z} {g : Y ⟶ Z} (x : pullback f g) :
    (pullbackIsoProdSubtype f g).Hom x =
      ⟨⟨(pullback.fst : pullback f g ⟶ _) x, (pullback.snd : pullback f g ⟶ _) x⟩, by
        simpa using concrete_category.congr_hom pullback.condition x⟩ :=
  by
  ext
  exacts[concrete_category.congr_hom (pullback_iso_prod_subtype_hom_fst f g) x,
    concrete_category.congr_hom (pullback_iso_prod_subtype_hom_snd f g) x]
#align Top.pullback_iso_prod_subtype_hom_apply TopCat.pullbackIsoProdSubtype_hom_apply

/- warning: Top.pullback_topology -> TopCat.pullback_topology is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.pullback_topology TopCat.pullback_topologyₓ'. -/
theorem pullback_topology {X Y Z : TopCat.{u}} (f : X ⟶ Z) (g : Y ⟶ Z) :
    (pullback f g).TopologicalSpace =
      induced (pullback.fst : pullback f g ⟶ _) X.TopologicalSpace ⊓
        induced (pullback.snd : pullback f g ⟶ _) Y.TopologicalSpace :=
  by
  let homeo := homeo_of_iso (pullback_iso_prod_subtype f g)
  refine' homeo.inducing.induced.trans _
  change induced homeo (induced _ (_ ⊓ _)) = _
  simpa [induced_compose]
#align Top.pullback_topology TopCat.pullback_topology

/- warning: Top.range_pullback_to_prod -> TopCat.range_pullback_to_prod is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.range_pullback_to_prod TopCat.range_pullback_to_prodₓ'. -/
theorem range_pullback_to_prod {X Y Z : TopCat} (f : X ⟶ Z) (g : Y ⟶ Z) :
    Set.range (prod.lift pullback.fst pullback.snd : pullback f g ⟶ X ⨯ Y) =
      { x | (Limits.prod.fst ≫ f) x = (Limits.prod.snd ≫ g) x } :=
  by
  ext x
  constructor
  · rintro ⟨y, rfl⟩
    simp only [← comp_apply, Set.mem_setOf_eq]
    congr 1
    simp [pullback.condition]
  · intro h
    use (pullback_iso_prod_subtype f g).inv ⟨⟨_, _⟩, h⟩
    apply concrete.limit_ext
    rintro ⟨⟨⟩⟩ <;> simp
#align Top.range_pullback_to_prod TopCat.range_pullback_to_prod

/- warning: Top.inducing_pullback_to_prod -> TopCat.inducing_pullback_to_prod is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.inducing_pullback_to_prod TopCat.inducing_pullback_to_prodₓ'. -/
theorem inducing_pullback_to_prod {X Y Z : TopCat} (f : X ⟶ Z) (g : Y ⟶ Z) :
    Inducing ⇑(prod.lift pullback.fst pullback.snd : pullback f g ⟶ X ⨯ Y) :=
  ⟨by simp [prod_topology, pullbackTopology, induced_compose, ← coe_comp]⟩
#align Top.inducing_pullback_to_prod TopCat.inducing_pullback_to_prod

/- warning: Top.embedding_pullback_to_prod -> TopCat.embedding_pullback_to_prod is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.embedding_pullback_to_prod TopCat.embedding_pullback_to_prodₓ'. -/
theorem embedding_pullback_to_prod {X Y Z : TopCat} (f : X ⟶ Z) (g : Y ⟶ Z) :
    Embedding ⇑(prod.lift pullback.fst pullback.snd : pullback f g ⟶ X ⨯ Y) :=
  ⟨inducing_pullback_to_prod f g, (TopCat.mono_iff_injective _).mp inferInstance⟩
#align Top.embedding_pullback_to_prod TopCat.embedding_pullback_to_prod

/- warning: Top.range_pullback_map -> TopCat.range_pullback_map is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.range_pullback_map TopCat.range_pullback_mapₓ'. -/
/-- If the map `S ⟶ T` is mono, then there is a description of the image of `W ×ₛ X ⟶ Y ×ₜ Z`. -/
theorem range_pullback_map {W X Y Z S T : TopCat} (f₁ : W ⟶ S) (f₂ : X ⟶ S) (g₁ : Y ⟶ T)
    (g₂ : Z ⟶ T) (i₁ : W ⟶ Y) (i₂ : X ⟶ Z) (i₃ : S ⟶ T) [H₃ : Mono i₃] (eq₁ : f₁ ≫ i₃ = i₁ ≫ g₁)
    (eq₂ : f₂ ≫ i₃ = i₂ ≫ g₂) :
    Set.range (pullback.map f₁ f₂ g₁ g₂ i₁ i₂ i₃ eq₁ eq₂) =
      (pullback.fst : pullback g₁ g₂ ⟶ _) ⁻¹' Set.range i₁ ∩
        (pullback.snd : pullback g₁ g₂ ⟶ _) ⁻¹' Set.range i₂ :=
  by
  ext
  constructor
  · rintro ⟨y, rfl⟩; simp
  rintro ⟨⟨x₁, hx₁⟩, ⟨x₂, hx₂⟩⟩
  have : f₁ x₁ = f₂ x₂ := by
    apply (TopCat.mono_iff_injective _).mp H₃
    simp only [← comp_apply, eq₁, eq₂]
    simp only [comp_apply, hx₁, hx₂]
    simp only [← comp_apply, pullback.condition]
  use (pullback_iso_prod_subtype f₁ f₂).inv ⟨⟨x₁, x₂⟩, this⟩
  apply concrete.limit_ext
  rintro (_ | _ | _)
  · simp only [TopCat.comp_app, limit.lift_π_apply, category.assoc, pullback_cone.mk_π_app_one, hx₁,
      pullback_iso_prod_subtype_inv_fst_apply, Subtype.coe_mk]
    simp only [← comp_apply]
    congr
    apply limit.w _ walking_cospan.hom.inl
  · simp [hx₁]
  · simp [hx₂]
#align Top.range_pullback_map TopCat.range_pullback_map

/- warning: Top.pullback_fst_range -> TopCat.pullback_fst_range is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.pullback_fst_range TopCat.pullback_fst_rangeₓ'. -/
theorem pullback_fst_range {X Y S : TopCat} (f : X ⟶ S) (g : Y ⟶ S) :
    Set.range (pullback.fst : pullback f g ⟶ _) = { x : X | ∃ y : Y, f x = g y } :=
  by
  ext x
  constructor
  · rintro ⟨y, rfl⟩
    use (pullback.snd : pullback f g ⟶ _) y
    exact concrete_category.congr_hom pullback.condition y
  · rintro ⟨y, eq⟩
    use (TopCat.pullbackIsoProdSubtype f g).inv ⟨⟨x, y⟩, Eq⟩
    simp
#align Top.pullback_fst_range TopCat.pullback_fst_range

/- warning: Top.pullback_snd_range -> TopCat.pullback_snd_range is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.pullback_snd_range TopCat.pullback_snd_rangeₓ'. -/
theorem pullback_snd_range {X Y S : TopCat} (f : X ⟶ S) (g : Y ⟶ S) :
    Set.range (pullback.snd : pullback f g ⟶ _) = { y : Y | ∃ x : X, f x = g y } :=
  by
  ext y
  constructor
  · rintro ⟨x, rfl⟩
    use (pullback.fst : pullback f g ⟶ _) x
    exact concrete_category.congr_hom pullback.condition x
  · rintro ⟨x, eq⟩
    use (TopCat.pullbackIsoProdSubtype f g).inv ⟨⟨x, y⟩, Eq⟩
    simp
#align Top.pullback_snd_range TopCat.pullback_snd_range

/- warning: Top.pullback_map_embedding_of_embeddings -> TopCat.pullback_map_embedding_of_embeddings is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.pullback_map_embedding_of_embeddings TopCat.pullback_map_embedding_of_embeddingsₓ'. -/
/-- If there is a diagram where the morphisms `W ⟶ Y` and `X ⟶ Z` are embeddings,
then the induced morphism `W ×ₛ X ⟶ Y ×ₜ Z` is also an embedding.

  W  ⟶  Y
    ↘      ↘
      S  ⟶  T
    ↗      ↗
  X  ⟶  Z
-/
theorem pullback_map_embedding_of_embeddings {W X Y Z S T : TopCat} (f₁ : W ⟶ S) (f₂ : X ⟶ S)
    (g₁ : Y ⟶ T) (g₂ : Z ⟶ T) {i₁ : W ⟶ Y} {i₂ : X ⟶ Z} (H₁ : Embedding i₁) (H₂ : Embedding i₂)
    (i₃ : S ⟶ T) (eq₁ : f₁ ≫ i₃ = i₁ ≫ g₁) (eq₂ : f₂ ≫ i₃ = i₂ ≫ g₂) :
    Embedding (pullback.map f₁ f₂ g₁ g₂ i₁ i₂ i₃ eq₁ eq₂) :=
  by
  refine'
    embedding_of_embedding_compose (ContinuousMap.continuous_toFun _)
      (show Continuous (prod.lift pullback.fst pullback.snd : pullback g₁ g₂ ⟶ Y ⨯ Z) from
        ContinuousMap.continuous_toFun _)
      _
  suffices
    Embedding (prod.lift pullback.fst pullback.snd ≫ limits.prod.map i₁ i₂ : pullback f₁ f₂ ⟶ _) by
    simpa [← coe_comp] using this
  rw [coe_comp]
  refine' Embedding.comp (embedding_prod_map H₁ H₂) (embedding_pullback_to_prod _ _)
#align Top.pullback_map_embedding_of_embeddings TopCat.pullback_map_embedding_of_embeddings

/- warning: Top.pullback_map_open_embedding_of_open_embeddings -> TopCat.pullback_map_openEmbedding_of_open_embeddings is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.pullback_map_open_embedding_of_open_embeddings TopCat.pullback_map_openEmbedding_of_open_embeddingsₓ'. -/
/-- If there is a diagram where the morphisms `W ⟶ Y` and `X ⟶ Z` are open embeddings, and `S ⟶ T`
is mono, then the induced morphism `W ×ₛ X ⟶ Y ×ₜ Z` is also an open embedding.
  W  ⟶  Y
    ↘      ↘
      S  ⟶  T
    ↗       ↗
  X  ⟶  Z
-/
theorem pullback_map_openEmbedding_of_open_embeddings {W X Y Z S T : TopCat} (f₁ : W ⟶ S)
    (f₂ : X ⟶ S) (g₁ : Y ⟶ T) (g₂ : Z ⟶ T) {i₁ : W ⟶ Y} {i₂ : X ⟶ Z} (H₁ : OpenEmbedding i₁)
    (H₂ : OpenEmbedding i₂) (i₃ : S ⟶ T) [H₃ : Mono i₃] (eq₁ : f₁ ≫ i₃ = i₁ ≫ g₁)
    (eq₂ : f₂ ≫ i₃ = i₂ ≫ g₂) : OpenEmbedding (pullback.map f₁ f₂ g₁ g₂ i₁ i₂ i₃ eq₁ eq₂) :=
  by
  constructor
  ·
    apply
      pullback_map_embedding_of_embeddings f₁ f₂ g₁ g₂ H₁.to_embedding H₂.to_embedding i₃ eq₁ eq₂
  · rw [range_pullback_map]
    apply IsOpen.inter <;> apply Continuous.isOpen_preimage
    continuity
    exacts[H₁.open_range, H₂.open_range]
#align Top.pullback_map_open_embedding_of_open_embeddings TopCat.pullback_map_openEmbedding_of_open_embeddings

/- warning: Top.snd_embedding_of_left_embedding -> TopCat.snd_embedding_of_left_embedding is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.snd_embedding_of_left_embedding TopCat.snd_embedding_of_left_embeddingₓ'. -/
theorem snd_embedding_of_left_embedding {X Y S : TopCat} {f : X ⟶ S} (H : Embedding f) (g : Y ⟶ S) :
    Embedding ⇑(pullback.snd : pullback f g ⟶ Y) :=
  by
  convert(homeo_of_iso (as_iso (pullback.snd : pullback (𝟙 S) g ⟶ _))).Embedding.comp
      (pullback_map_embedding_of_embeddings f g (𝟙 _) g H (homeo_of_iso (iso.refl _)).Embedding
        (𝟙 _) rfl (by simp))
  erw [← coe_comp]
  simp
#align Top.snd_embedding_of_left_embedding TopCat.snd_embedding_of_left_embedding

/- warning: Top.fst_embedding_of_right_embedding -> TopCat.fst_embedding_of_right_embedding is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.fst_embedding_of_right_embedding TopCat.fst_embedding_of_right_embeddingₓ'. -/
theorem fst_embedding_of_right_embedding {X Y S : TopCat} (f : X ⟶ S) {g : Y ⟶ S}
    (H : Embedding g) : Embedding ⇑(pullback.fst : pullback f g ⟶ X) :=
  by
  convert(homeo_of_iso (as_iso (pullback.fst : pullback f (𝟙 S) ⟶ _))).Embedding.comp
      (pullback_map_embedding_of_embeddings f g f (𝟙 _) (homeo_of_iso (iso.refl _)).Embedding H
        (𝟙 _) rfl (by simp))
  erw [← coe_comp]
  simp
#align Top.fst_embedding_of_right_embedding TopCat.fst_embedding_of_right_embedding

/- warning: Top.embedding_of_pullback_embeddings -> TopCat.embedding_of_pullback_embeddings is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.embedding_of_pullback_embeddings TopCat.embedding_of_pullback_embeddingsₓ'. -/
theorem embedding_of_pullback_embeddings {X Y S : TopCat} {f : X ⟶ S} {g : Y ⟶ S} (H₁ : Embedding f)
    (H₂ : Embedding g) : Embedding (limit.π (cospan f g) WalkingCospan.one) :=
  by
  convert H₂.comp (snd_embedding_of_left_embedding H₁ g)
  erw [← coe_comp]
  congr
  exact (limit.w _ walking_cospan.hom.inr).symm
#align Top.embedding_of_pullback_embeddings TopCat.embedding_of_pullback_embeddings

/- warning: Top.snd_open_embedding_of_left_open_embedding -> TopCat.snd_openEmbedding_of_left_openEmbedding is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.snd_open_embedding_of_left_open_embedding TopCat.snd_openEmbedding_of_left_openEmbeddingₓ'. -/
theorem snd_openEmbedding_of_left_openEmbedding {X Y S : TopCat} {f : X ⟶ S} (H : OpenEmbedding f)
    (g : Y ⟶ S) : OpenEmbedding ⇑(pullback.snd : pullback f g ⟶ Y) :=
  by
  convert(homeo_of_iso (as_iso (pullback.snd : pullback (𝟙 S) g ⟶ _))).OpenEmbedding.comp
      (pullback_map_open_embedding_of_open_embeddings f g (𝟙 _) g H
        (homeo_of_iso (iso.refl _)).OpenEmbedding (𝟙 _) rfl (by simp))
  erw [← coe_comp]
  simp
#align Top.snd_open_embedding_of_left_open_embedding TopCat.snd_openEmbedding_of_left_openEmbedding

/- warning: Top.fst_open_embedding_of_right_open_embedding -> TopCat.fst_openEmbedding_of_right_openEmbedding is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.fst_open_embedding_of_right_open_embedding TopCat.fst_openEmbedding_of_right_openEmbeddingₓ'. -/
theorem fst_openEmbedding_of_right_openEmbedding {X Y S : TopCat} (f : X ⟶ S) {g : Y ⟶ S}
    (H : OpenEmbedding g) : OpenEmbedding ⇑(pullback.fst : pullback f g ⟶ X) :=
  by
  convert(homeo_of_iso (as_iso (pullback.fst : pullback f (𝟙 S) ⟶ _))).OpenEmbedding.comp
      (pullback_map_open_embedding_of_open_embeddings f g f (𝟙 _)
        (homeo_of_iso (iso.refl _)).OpenEmbedding H (𝟙 _) rfl (by simp))
  erw [← coe_comp]
  simp
#align Top.fst_open_embedding_of_right_open_embedding TopCat.fst_openEmbedding_of_right_openEmbedding

/- warning: Top.open_embedding_of_pullback_open_embeddings -> TopCat.openEmbedding_of_pullback_open_embeddings is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.open_embedding_of_pullback_open_embeddings TopCat.openEmbedding_of_pullback_open_embeddingsₓ'. -/
/-- If `X ⟶ S`, `Y ⟶ S` are open embeddings, then so is `X ×ₛ Y ⟶ S`. -/
theorem openEmbedding_of_pullback_open_embeddings {X Y S : TopCat} {f : X ⟶ S} {g : Y ⟶ S}
    (H₁ : OpenEmbedding f) (H₂ : OpenEmbedding g) :
    OpenEmbedding (limit.π (cospan f g) WalkingCospan.one) :=
  by
  convert H₂.comp (snd_open_embedding_of_left_open_embedding H₁ g)
  erw [← coe_comp]
  congr
  exact (limit.w _ walking_cospan.hom.inr).symm
#align Top.open_embedding_of_pullback_open_embeddings TopCat.openEmbedding_of_pullback_open_embeddings

/- warning: Top.fst_iso_of_right_embedding_range_subset -> TopCat.fst_iso_of_right_embedding_range_subset is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.fst_iso_of_right_embedding_range_subset TopCat.fst_iso_of_right_embedding_range_subsetₓ'. -/
theorem fst_iso_of_right_embedding_range_subset {X Y S : TopCat} (f : X ⟶ S) {g : Y ⟶ S}
    (hg : Embedding g) (H : Set.range f ⊆ Set.range g) : IsIso (pullback.fst : pullback f g ⟶ X) :=
  by
  let this : (pullback f g : TopCat) ≃ₜ X :=
    (Homeomorph.ofEmbedding _ (fst_embedding_of_right_embedding f hg)).trans
      { toFun := coe
        invFun := fun x =>
          ⟨x, by rw [pullback_fst_range]; exact ⟨_, (H (Set.mem_range_self x)).choose_spec.symm⟩⟩
        left_inv := fun ⟨_, _⟩ => rfl
        right_inv := fun x => rfl }
  convert is_iso.of_iso (iso_of_homeo this)
  ext
  rfl
#align Top.fst_iso_of_right_embedding_range_subset TopCat.fst_iso_of_right_embedding_range_subset

/- warning: Top.snd_iso_of_left_embedding_range_subset -> TopCat.snd_iso_of_left_embedding_range_subset is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.snd_iso_of_left_embedding_range_subset TopCat.snd_iso_of_left_embedding_range_subsetₓ'. -/
theorem snd_iso_of_left_embedding_range_subset {X Y S : TopCat} {f : X ⟶ S} (hf : Embedding f)
    (g : Y ⟶ S) (H : Set.range g ⊆ Set.range f) : IsIso (pullback.snd : pullback f g ⟶ Y) :=
  by
  let this : (pullback f g : TopCat) ≃ₜ Y :=
    (Homeomorph.ofEmbedding _ (snd_embedding_of_left_embedding hf g)).trans
      { toFun := coe
        invFun := fun x =>
          ⟨x, by rw [pullback_snd_range]; exact ⟨_, (H (Set.mem_range_self x)).choose_spec⟩⟩
        left_inv := fun ⟨_, _⟩ => rfl
        right_inv := fun x => rfl }
  convert is_iso.of_iso (iso_of_homeo this)
  ext
  rfl
#align Top.snd_iso_of_left_embedding_range_subset TopCat.snd_iso_of_left_embedding_range_subset

/- warning: Top.pullback_snd_image_fst_preimage -> TopCat.pullback_snd_image_fst_preimage is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.pullback_snd_image_fst_preimage TopCat.pullback_snd_image_fst_preimageₓ'. -/
theorem pullback_snd_image_fst_preimage (f : X ⟶ Z) (g : Y ⟶ Z) (U : Set X) :
    (pullback.snd : pullback f g ⟶ _) '' ((pullback.fst : pullback f g ⟶ _) ⁻¹' U) =
      g ⁻¹' (f '' U) :=
  by
  ext x
  constructor
  · rintro ⟨y, hy, rfl⟩
    exact
      ⟨(pullback.fst : pullback f g ⟶ _) y, hy, concrete_category.congr_hom pullback.condition y⟩
  · rintro ⟨y, hy, eq⟩
    exact ⟨(TopCat.pullbackIsoProdSubtype f g).inv ⟨⟨_, _⟩, Eq⟩, by simpa, by simp⟩
#align Top.pullback_snd_image_fst_preimage TopCat.pullback_snd_image_fst_preimage

/- warning: Top.pullback_fst_image_snd_preimage -> TopCat.pullback_fst_image_snd_preimage is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.pullback_fst_image_snd_preimage TopCat.pullback_fst_image_snd_preimageₓ'. -/
theorem pullback_fst_image_snd_preimage (f : X ⟶ Z) (g : Y ⟶ Z) (U : Set Y) :
    (pullback.fst : pullback f g ⟶ _) '' ((pullback.snd : pullback f g ⟶ _) ⁻¹' U) =
      f ⁻¹' (g '' U) :=
  by
  ext x
  constructor
  · rintro ⟨y, hy, rfl⟩
    exact
      ⟨(pullback.snd : pullback f g ⟶ _) y, hy,
        (concrete_category.congr_hom pullback.condition y).symm⟩
  · rintro ⟨y, hy, eq⟩
    exact ⟨(TopCat.pullbackIsoProdSubtype f g).inv ⟨⟨_, _⟩, Eq.symm⟩, by simpa, by simp⟩
#align Top.pullback_fst_image_snd_preimage TopCat.pullback_fst_image_snd_preimage

end Pullback

/- warning: Top.coinduced_of_is_colimit -> TopCat.coinduced_of_isColimit is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.coinduced_of_is_colimit TopCat.coinduced_of_isColimitₓ'. -/
theorem coinduced_of_isColimit {F : J ⥤ TopCat.{max v u}} (c : Cocone F) (hc : IsColimit c) :
    c.pt.TopologicalSpace = ⨆ j, (F.obj j).TopologicalSpace.coinduced (c.ι.app j) :=
  by
  let homeo := homeo_of_iso (hc.cocone_point_unique_up_to_iso (colimit_cocone_is_colimit F))
  ext
  refine' homeo.symm.is_open_preimage.symm.trans (Iff.trans _ is_open_supr_iff.symm)
  exact isOpen_iSup_iff
#align Top.coinduced_of_is_colimit TopCat.coinduced_of_isColimit

/- warning: Top.colimit_topology -> TopCat.colimit_topology is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.colimit_topology TopCat.colimit_topologyₓ'. -/
theorem colimit_topology (F : J ⥤ TopCat.{max v u}) :
    (colimit F).TopologicalSpace = ⨆ j, (F.obj j).TopologicalSpace.coinduced (colimit.ι F j) :=
  coinduced_of_isColimit _ (colimit.isColimit F)
#align Top.colimit_topology TopCat.colimit_topology

/- warning: Top.colimit_is_open_iff -> TopCat.colimit_isOpen_iff is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.colimit_is_open_iff TopCat.colimit_isOpen_iffₓ'. -/
theorem colimit_isOpen_iff (F : J ⥤ TopCat.{max v u}) (U : Set ((colimit F : _) : Type max v u)) :
    IsOpen U ↔ ∀ j, IsOpen (colimit.ι F j ⁻¹' U) :=
  by
  conv_lhs => rw [colimit_topology F]
  exact isOpen_iSup_iff
#align Top.colimit_is_open_iff TopCat.colimit_isOpen_iff

/- warning: Top.coequalizer_is_open_iff -> TopCat.coequalizer_isOpen_iff is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.coequalizer_is_open_iff TopCat.coequalizer_isOpen_iffₓ'. -/
theorem coequalizer_isOpen_iff (F : WalkingParallelPair ⥤ TopCat.{u})
    (U : Set ((colimit F : _) : Type u)) :
    IsOpen U ↔ IsOpen (colimit.ι F WalkingParallelPair.one ⁻¹' U) :=
  by
  rw [colimit_isOpen_iff.{u}]
  constructor
  · intro H; exact H _
  · intro H j
    cases j
    · rw [← colimit.w F walking_parallel_pair_hom.left]
      exact (F.map walking_parallel_pair_hom.left).continuous_toFun.isOpen_preimage _ H
    · exact H
#align Top.coequalizer_is_open_iff TopCat.coequalizer_isOpen_iff

end TopCat

