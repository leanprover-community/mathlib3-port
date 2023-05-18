/-
Copyright (c) 2018 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Isometries of emetric and metric spaces
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module topology.metric_space.isometry
! leanprover-community/mathlib commit b1859b6d4636fdbb78c5d5cefd24530653cfd3eb
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.MetricSpace.Antilipschitz

/-!
# Isometries

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define isometries, i.e., maps between emetric spaces that preserve
the edistance (on metric spaces, these are exactly the maps that preserve distances),
and prove their basic properties. We also introduce isometric bijections.

Since a lot of elementary properties don't require `eq_of_dist_eq_zero` we start setting up the
theory for `pseudo_metric_space` and we specialize to `metric_space` when needed.
-/


noncomputable section

universe u v w

variable {ι : Type _} {α : Type u} {β : Type v} {γ : Type w}

open Function Set

open Topology ENNReal

#print Isometry /-
/-- An isometry (also known as isometric embedding) is a map preserving the edistance
between pseudoemetric spaces, or equivalently the distance between pseudometric space.  -/
def Isometry [PseudoEMetricSpace α] [PseudoEMetricSpace β] (f : α → β) : Prop :=
  ∀ x1 x2 : α, edist (f x1) (f x2) = edist x1 x2
#align isometry Isometry
-/

#print isometry_iff_nndist_eq /-
/-- On pseudometric spaces, a map is an isometry if and only if it preserves nonnegative
distances. -/
theorem isometry_iff_nndist_eq [PseudoMetricSpace α] [PseudoMetricSpace β] {f : α → β} :
    Isometry f ↔ ∀ x y, nndist (f x) (f y) = nndist x y := by
  simp only [Isometry, edist_nndist, ENNReal.coe_eq_coe]
#align isometry_iff_nndist_eq isometry_iff_nndist_eq
-/

#print isometry_iff_dist_eq /-
/-- On pseudometric spaces, a map is an isometry if and only if it preserves distances. -/
theorem isometry_iff_dist_eq [PseudoMetricSpace α] [PseudoMetricSpace β] {f : α → β} :
    Isometry f ↔ ∀ x y, dist (f x) (f y) = dist x y := by
  simp only [isometry_iff_nndist_eq, ← coe_nndist, NNReal.coe_eq]
#align isometry_iff_dist_eq isometry_iff_dist_eq
-/

/-- An isometry preserves distances. -/
alias isometry_iff_dist_eq ↔ Isometry.dist_eq _
#align isometry.dist_eq Isometry.dist_eq

/-- A map that preserves distances is an isometry -/
alias isometry_iff_dist_eq ↔ _ Isometry.of_dist_eq
#align isometry.of_dist_eq Isometry.of_dist_eq

/-- An isometry preserves non-negative distances. -/
alias isometry_iff_nndist_eq ↔ Isometry.nndist_eq _
#align isometry.nndist_eq Isometry.nndist_eq

/-- A map that preserves non-negative distances is an isometry. -/
alias isometry_iff_nndist_eq ↔ _ Isometry.of_nndist_eq
#align isometry.of_nndist_eq Isometry.of_nndist_eq

namespace Isometry

section PseudoEmetricIsometry

variable [PseudoEMetricSpace α] [PseudoEMetricSpace β] [PseudoEMetricSpace γ]

variable {f : α → β} {x y z : α} {s : Set α}

#print Isometry.edist_eq /-
/-- An isometry preserves edistances. -/
theorem edist_eq (hf : Isometry f) (x y : α) : edist (f x) (f y) = edist x y :=
  hf x y
#align isometry.edist_eq Isometry.edist_eq
-/

#print Isometry.lipschitz /-
theorem lipschitz (h : Isometry f) : LipschitzWith 1 f :=
  LipschitzWith.of_edist_le fun x y => (h x y).le
#align isometry.lipschitz Isometry.lipschitz
-/

#print Isometry.antilipschitz /-
theorem antilipschitz (h : Isometry f) : AntilipschitzWith 1 f := fun x y => by
  simp only [h x y, ENNReal.coe_one, one_mul, le_refl]
#align isometry.antilipschitz Isometry.antilipschitz
-/

#print isometry_subsingleton /-
/-- Any map on a subsingleton is an isometry -/
@[nontriviality]
theorem isometry_subsingleton [Subsingleton α] : Isometry f := fun x y => by
  rw [Subsingleton.elim x y] <;> simp
#align isometry_subsingleton isometry_subsingleton
-/

#print isometry_id /-
/-- The identity is an isometry -/
theorem isometry_id : Isometry (id : α → α) := fun x y => rfl
#align isometry_id isometry_id
-/

/- warning: isometry.prod_map -> Isometry.prod_map is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] [_inst_3 : PseudoEMetricSpace.{u3} γ] {δ : Type.{u4}} [_inst_4 : PseudoEMetricSpace.{u4} δ] {f : α -> β} {g : γ -> δ}, (Isometry.{u1, u2} α β _inst_1 _inst_2 f) -> (Isometry.{u3, u4} γ δ _inst_3 _inst_4 g) -> (Isometry.{max u1 u3, max u2 u4} (Prod.{u1, u3} α γ) (Prod.{u2, u4} β δ) (Prod.pseudoEMetricSpaceMax.{u1, u3} α γ _inst_1 _inst_3) (Prod.pseudoEMetricSpaceMax.{u2, u4} β δ _inst_2 _inst_4) (Prod.map.{u1, u2, u3, u4} α β γ δ f g))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u3}} {γ : Type.{u4}} [_inst_1 : PseudoEMetricSpace.{u2} α] [_inst_2 : PseudoEMetricSpace.{u3} β] [_inst_3 : PseudoEMetricSpace.{u4} γ] {δ : Type.{u1}} [_inst_4 : PseudoEMetricSpace.{u1} δ] {f : α -> β} {g : γ -> δ}, (Isometry.{u2, u3} α β _inst_1 _inst_2 f) -> (Isometry.{u4, u1} γ δ _inst_3 _inst_4 g) -> (Isometry.{max u4 u2, max u1 u3} (Prod.{u2, u4} α γ) (Prod.{u3, u1} β δ) (Prod.pseudoEMetricSpaceMax.{u2, u4} α γ _inst_1 _inst_3) (Prod.pseudoEMetricSpaceMax.{u3, u1} β δ _inst_2 _inst_4) (Prod.map.{u2, u3, u4, u1} α β γ δ f g))
Case conversion may be inaccurate. Consider using '#align isometry.prod_map Isometry.prod_mapₓ'. -/
theorem prod_map {δ} [PseudoEMetricSpace δ] {f : α → β} {g : γ → δ} (hf : Isometry f)
    (hg : Isometry g) : Isometry (Prod.map f g) := fun x y => by
  simp only [Prod.edist_eq, hf.edist_eq, hg.edist_eq, Prod_map]
#align isometry.prod_map Isometry.prod_map

/- warning: isometry_dcomp -> isometry_dcomp is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_4 : Fintype.{u1} ι] {α : ι -> Type.{u2}} {β : ι -> Type.{u3}} [_inst_5 : forall (i : ι), PseudoEMetricSpace.{u2} (α i)] [_inst_6 : forall (i : ι), PseudoEMetricSpace.{u3} (β i)] (f : forall (i : ι), (α i) -> (β i)), (forall (i : ι), Isometry.{u2, u3} (α i) (β i) (_inst_5 i) (_inst_6 i) (f i)) -> (Isometry.{max u1 u2, max u1 u3} (forall (x : ι), α x) (forall (x : ι), β x) (pseudoEMetricSpacePi.{u1, u2} ι (fun (x : ι) => α x) _inst_4 (fun (b : ι) => _inst_5 b)) (pseudoEMetricSpacePi.{u1, u3} ι (fun (x : ι) => β x) _inst_4 (fun (b : ι) => _inst_6 b)) (Function.dcomp.{succ u1, succ u2, succ u3} ι (fun (i : ι) => α i) (fun (i : ι) (ᾰ : α i) => β i) f))
but is expected to have type
  forall {ι : Type.{u3}} [_inst_4 : Fintype.{u3} ι] {α : ι -> Type.{u2}} {β : ι -> Type.{u1}} [_inst_5 : forall (i : ι), PseudoEMetricSpace.{u2} (α i)] [_inst_6 : forall (i : ι), PseudoEMetricSpace.{u1} (β i)] (f : forall (i : ι), (α i) -> (β i)), (forall (i : ι), Isometry.{u2, u1} (α i) (β i) (_inst_5 i) (_inst_6 i) (f i)) -> (Isometry.{max u3 u2, max u3 u1} (forall (x : ι), α x) (forall (x : ι), β x) (pseudoEMetricSpacePi.{u3, u2} ι (fun (x : ι) => α x) _inst_4 (fun (b : ι) => _inst_5 b)) (pseudoEMetricSpacePi.{u3, u1} ι (fun (x : ι) => β x) _inst_4 (fun (b : ι) => _inst_6 b)) (fun (g : forall (i : ι), α i) (i : ι) => f i (g i)))
Case conversion may be inaccurate. Consider using '#align isometry_dcomp isometry_dcompₓ'. -/
theorem isometry_dcomp {ι} [Fintype ι] {α β : ι → Type _} [∀ i, PseudoEMetricSpace (α i)]
    [∀ i, PseudoEMetricSpace (β i)] (f : ∀ i, α i → β i) (hf : ∀ i, Isometry (f i)) :
    Isometry (dcomp f) := fun x y => by simp only [edist_pi_def, (hf _).edist_eq]
#align isometry_dcomp isometry_dcomp

#print Isometry.comp /-
/-- The composition of isometries is an isometry. -/
theorem comp {g : β → γ} {f : α → β} (hg : Isometry g) (hf : Isometry f) : Isometry (g ∘ f) :=
  fun x y => (hg _ _).trans (hf _ _)
#align isometry.comp Isometry.comp
-/

#print Isometry.uniformContinuous /-
/-- An isometry from a metric space is a uniform continuous map -/
protected theorem uniformContinuous (hf : Isometry f) : UniformContinuous f :=
  hf.lipschitz.UniformContinuous
#align isometry.uniform_continuous Isometry.uniformContinuous
-/

#print Isometry.uniformInducing /-
/-- An isometry from a metric space is a uniform inducing map -/
protected theorem uniformInducing (hf : Isometry f) : UniformInducing f :=
  hf.antilipschitz.UniformInducing hf.UniformContinuous
#align isometry.uniform_inducing Isometry.uniformInducing
-/

/- warning: isometry.tendsto_nhds_iff -> Isometry.tendsto_nhds_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] {ι : Type.{u3}} {f : α -> β} {g : ι -> α} {a : Filter.{u3} ι} {b : α}, (Isometry.{u1, u2} α β _inst_1 _inst_2 f) -> (Iff (Filter.Tendsto.{u3, u1} ι α g a (nhds.{u1} α (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) b)) (Filter.Tendsto.{u3, u2} ι β (Function.comp.{succ u3, succ u1, succ u2} ι α β f g) a (nhds.{u2} β (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (f b))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u3}} [_inst_1 : PseudoEMetricSpace.{u2} α] [_inst_2 : PseudoEMetricSpace.{u3} β] {ι : Type.{u1}} {f : α -> β} {g : ι -> α} {a : Filter.{u1} ι} {b : α}, (Isometry.{u2, u3} α β _inst_1 _inst_2 f) -> (Iff (Filter.Tendsto.{u1, u2} ι α g a (nhds.{u2} α (UniformSpace.toTopologicalSpace.{u2} α (PseudoEMetricSpace.toUniformSpace.{u2} α _inst_1)) b)) (Filter.Tendsto.{u1, u3} ι β (Function.comp.{succ u1, succ u2, succ u3} ι α β f g) a (nhds.{u3} β (UniformSpace.toTopologicalSpace.{u3} β (PseudoEMetricSpace.toUniformSpace.{u3} β _inst_2)) (f b))))
Case conversion may be inaccurate. Consider using '#align isometry.tendsto_nhds_iff Isometry.tendsto_nhds_iffₓ'. -/
theorem tendsto_nhds_iff {ι : Type _} {f : α → β} {g : ι → α} {a : Filter ι} {b : α}
    (hf : Isometry f) : Filter.Tendsto g a (𝓝 b) ↔ Filter.Tendsto (f ∘ g) a (𝓝 (f b)) :=
  hf.UniformInducing.Inducing.tendsto_nhds_iff
#align isometry.tendsto_nhds_iff Isometry.tendsto_nhds_iff

#print Isometry.continuous /-
/-- An isometry is continuous. -/
protected theorem continuous (hf : Isometry f) : Continuous f :=
  hf.lipschitz.Continuous
#align isometry.continuous Isometry.continuous
-/

#print Isometry.right_inv /-
/-- The right inverse of an isometry is an isometry. -/
theorem right_inv {f : α → β} {g : β → α} (h : Isometry f) (hg : RightInverse g f) : Isometry g :=
  fun x y => by rw [← h, hg _, hg _]
#align isometry.right_inv Isometry.right_inv
-/

#print Isometry.preimage_emetric_closedBall /-
theorem preimage_emetric_closedBall (h : Isometry f) (x : α) (r : ℝ≥0∞) :
    f ⁻¹' EMetric.closedBall (f x) r = EMetric.closedBall x r :=
  by
  ext y
  simp [h.edist_eq]
#align isometry.preimage_emetric_closed_ball Isometry.preimage_emetric_closedBall
-/

#print Isometry.preimage_emetric_ball /-
theorem preimage_emetric_ball (h : Isometry f) (x : α) (r : ℝ≥0∞) :
    f ⁻¹' EMetric.ball (f x) r = EMetric.ball x r :=
  by
  ext y
  simp [h.edist_eq]
#align isometry.preimage_emetric_ball Isometry.preimage_emetric_ball
-/

#print Isometry.ediam_image /-
/-- Isometries preserve the diameter in pseudoemetric spaces. -/
theorem ediam_image (hf : Isometry f) (s : Set α) : EMetric.diam (f '' s) = EMetric.diam s :=
  eq_of_forall_ge_iff fun d => by simp only [EMetric.diam_le_iff, ball_image_iff, hf.edist_eq]
#align isometry.ediam_image Isometry.ediam_image
-/

#print Isometry.ediam_range /-
theorem ediam_range (hf : Isometry f) : EMetric.diam (range f) = EMetric.diam (univ : Set α) :=
  by
  rw [← image_univ]
  exact hf.ediam_image univ
#align isometry.ediam_range Isometry.ediam_range
-/

#print Isometry.mapsTo_emetric_ball /-
theorem mapsTo_emetric_ball (hf : Isometry f) (x : α) (r : ℝ≥0∞) :
    MapsTo f (EMetric.ball x r) (EMetric.ball (f x) r) :=
  (hf.preimage_emetric_ball x r).ge
#align isometry.maps_to_emetric_ball Isometry.mapsTo_emetric_ball
-/

#print Isometry.mapsTo_emetric_closedBall /-
theorem mapsTo_emetric_closedBall (hf : Isometry f) (x : α) (r : ℝ≥0∞) :
    MapsTo f (EMetric.closedBall x r) (EMetric.closedBall (f x) r) :=
  (hf.preimage_emetric_closedBall x r).ge
#align isometry.maps_to_emetric_closed_ball Isometry.mapsTo_emetric_closedBall
-/

#print isometry_subtype_coe /-
/-- The injection from a subtype is an isometry -/
theorem isometry_subtype_coe {s : Set α} : Isometry (coe : s → α) := fun x y => rfl
#align isometry_subtype_coe isometry_subtype_coe
-/

/- warning: isometry.comp_continuous_on_iff -> Isometry.comp_continuousOn_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] {f : α -> β} {γ : Type.{u3}} [_inst_4 : TopologicalSpace.{u3} γ], (Isometry.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {g : γ -> α} {s : Set.{u3} γ}, Iff (ContinuousOn.{u3, u2} γ β _inst_4 (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (Function.comp.{succ u3, succ u1, succ u2} γ α β f g) s) (ContinuousOn.{u3, u1} γ α _inst_4 (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) g s))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u3}} [_inst_1 : PseudoEMetricSpace.{u2} α] [_inst_2 : PseudoEMetricSpace.{u3} β] {f : α -> β} {γ : Type.{u1}} [_inst_4 : TopologicalSpace.{u1} γ], (Isometry.{u2, u3} α β _inst_1 _inst_2 f) -> (forall {g : γ -> α} {s : Set.{u1} γ}, Iff (ContinuousOn.{u1, u3} γ β _inst_4 (UniformSpace.toTopologicalSpace.{u3} β (PseudoEMetricSpace.toUniformSpace.{u3} β _inst_2)) (Function.comp.{succ u1, succ u2, succ u3} γ α β f g) s) (ContinuousOn.{u1, u2} γ α _inst_4 (UniformSpace.toTopologicalSpace.{u2} α (PseudoEMetricSpace.toUniformSpace.{u2} α _inst_1)) g s))
Case conversion may be inaccurate. Consider using '#align isometry.comp_continuous_on_iff Isometry.comp_continuousOn_iffₓ'. -/
theorem comp_continuousOn_iff {γ} [TopologicalSpace γ] (hf : Isometry f) {g : γ → α} {s : Set γ} :
    ContinuousOn (f ∘ g) s ↔ ContinuousOn g s :=
  hf.UniformInducing.Inducing.continuousOn_iff.symm
#align isometry.comp_continuous_on_iff Isometry.comp_continuousOn_iff

/- warning: isometry.comp_continuous_iff -> Isometry.comp_continuous_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] {f : α -> β} {γ : Type.{u3}} [_inst_4 : TopologicalSpace.{u3} γ], (Isometry.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {g : γ -> α}, Iff (Continuous.{u3, u2} γ β _inst_4 (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (Function.comp.{succ u3, succ u1, succ u2} γ α β f g)) (Continuous.{u3, u1} γ α _inst_4 (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) g))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u3}} [_inst_1 : PseudoEMetricSpace.{u2} α] [_inst_2 : PseudoEMetricSpace.{u3} β] {f : α -> β} {γ : Type.{u1}} [_inst_4 : TopologicalSpace.{u1} γ], (Isometry.{u2, u3} α β _inst_1 _inst_2 f) -> (forall {g : γ -> α}, Iff (Continuous.{u1, u3} γ β _inst_4 (UniformSpace.toTopologicalSpace.{u3} β (PseudoEMetricSpace.toUniformSpace.{u3} β _inst_2)) (Function.comp.{succ u1, succ u2, succ u3} γ α β f g)) (Continuous.{u1, u2} γ α _inst_4 (UniformSpace.toTopologicalSpace.{u2} α (PseudoEMetricSpace.toUniformSpace.{u2} α _inst_1)) g))
Case conversion may be inaccurate. Consider using '#align isometry.comp_continuous_iff Isometry.comp_continuous_iffₓ'. -/
theorem comp_continuous_iff {γ} [TopologicalSpace γ] (hf : Isometry f) {g : γ → α} :
    Continuous (f ∘ g) ↔ Continuous g :=
  hf.UniformInducing.Inducing.continuous_iff.symm
#align isometry.comp_continuous_iff Isometry.comp_continuous_iff

end PseudoEmetricIsometry

--section
section EmetricIsometry

variable [EMetricSpace α] [PseudoEMetricSpace β] {f : α → β}

#print Isometry.injective /-
/-- An isometry from an emetric space is injective -/
protected theorem injective (h : Isometry f) : Injective f :=
  h.antilipschitz.Injective
#align isometry.injective Isometry.injective
-/

#print Isometry.uniformEmbedding /-
/-- An isometry from an emetric space is a uniform embedding -/
protected theorem uniformEmbedding (hf : Isometry f) : UniformEmbedding f :=
  hf.antilipschitz.UniformEmbedding hf.lipschitz.UniformContinuous
#align isometry.uniform_embedding Isometry.uniformEmbedding
-/

#print Isometry.embedding /-
/-- An isometry from an emetric space is an embedding -/
protected theorem embedding (hf : Isometry f) : Embedding f :=
  hf.UniformEmbedding.Embedding
#align isometry.embedding Isometry.embedding
-/

#print Isometry.closedEmbedding /-
/-- An isometry from a complete emetric space is a closed embedding -/
theorem closedEmbedding [CompleteSpace α] [EMetricSpace γ] {f : α → γ} (hf : Isometry f) :
    ClosedEmbedding f :=
  hf.antilipschitz.ClosedEmbedding hf.lipschitz.UniformContinuous
#align isometry.closed_embedding Isometry.closedEmbedding
-/

end EmetricIsometry

--section
section PseudoMetricIsometry

variable [PseudoMetricSpace α] [PseudoMetricSpace β] {f : α → β}

#print Isometry.diam_image /-
/-- An isometry preserves the diameter in pseudometric spaces. -/
theorem diam_image (hf : Isometry f) (s : Set α) : Metric.diam (f '' s) = Metric.diam s := by
  rw [Metric.diam, Metric.diam, hf.ediam_image]
#align isometry.diam_image Isometry.diam_image
-/

#print Isometry.diam_range /-
theorem diam_range (hf : Isometry f) : Metric.diam (range f) = Metric.diam (univ : Set α) :=
  by
  rw [← image_univ]
  exact hf.diam_image univ
#align isometry.diam_range Isometry.diam_range
-/

#print Isometry.preimage_setOf_dist /-
theorem preimage_setOf_dist (hf : Isometry f) (x : α) (p : ℝ → Prop) :
    f ⁻¹' { y | p (dist y (f x)) } = { y | p (dist y x) } :=
  by
  ext y
  simp [hf.dist_eq]
#align isometry.preimage_set_of_dist Isometry.preimage_setOf_dist
-/

#print Isometry.preimage_closedBall /-
theorem preimage_closedBall (hf : Isometry f) (x : α) (r : ℝ) :
    f ⁻¹' Metric.closedBall (f x) r = Metric.closedBall x r :=
  hf.preimage_setOf_dist x (· ≤ r)
#align isometry.preimage_closed_ball Isometry.preimage_closedBall
-/

#print Isometry.preimage_ball /-
theorem preimage_ball (hf : Isometry f) (x : α) (r : ℝ) :
    f ⁻¹' Metric.ball (f x) r = Metric.ball x r :=
  hf.preimage_setOf_dist x (· < r)
#align isometry.preimage_ball Isometry.preimage_ball
-/

#print Isometry.preimage_sphere /-
theorem preimage_sphere (hf : Isometry f) (x : α) (r : ℝ) :
    f ⁻¹' Metric.sphere (f x) r = Metric.sphere x r :=
  hf.preimage_setOf_dist x (· = r)
#align isometry.preimage_sphere Isometry.preimage_sphere
-/

#print Isometry.mapsTo_ball /-
theorem mapsTo_ball (hf : Isometry f) (x : α) (r : ℝ) :
    MapsTo f (Metric.ball x r) (Metric.ball (f x) r) :=
  (hf.preimage_ball x r).ge
#align isometry.maps_to_ball Isometry.mapsTo_ball
-/

#print Isometry.mapsTo_sphere /-
theorem mapsTo_sphere (hf : Isometry f) (x : α) (r : ℝ) :
    MapsTo f (Metric.sphere x r) (Metric.sphere (f x) r) :=
  (hf.preimage_sphere x r).ge
#align isometry.maps_to_sphere Isometry.mapsTo_sphere
-/

#print Isometry.mapsTo_closedBall /-
theorem mapsTo_closedBall (hf : Isometry f) (x : α) (r : ℝ) :
    MapsTo f (Metric.closedBall x r) (Metric.closedBall (f x) r) :=
  (hf.preimage_closedBall x r).ge
#align isometry.maps_to_closed_ball Isometry.mapsTo_closedBall
-/

end PseudoMetricIsometry

-- section
end Isometry

/- warning: uniform_embedding.to_isometry -> UniformEmbedding.to_isometry is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : UniformSpace.{u1} α] [_inst_2 : MetricSpace.{u2} β] {f : α -> β} (h : UniformEmbedding.{u1, u2} α β _inst_1 (PseudoMetricSpace.toUniformSpace.{u2} β (MetricSpace.toPseudoMetricSpace.{u2} β _inst_2)) f), Isometry.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α (UniformEmbedding.comapMetricSpace.{u1, u2} α β _inst_1 _inst_2 f h))) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β (MetricSpace.toPseudoMetricSpace.{u2} β _inst_2)) f
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : UniformSpace.{u2} α] [_inst_2 : MetricSpace.{u1} β] {f : α -> β} (h : UniformEmbedding.{u2, u1} α β _inst_1 (PseudoMetricSpace.toUniformSpace.{u1} β (MetricSpace.toPseudoMetricSpace.{u1} β _inst_2)) f), Isometry.{u2, u1} α β (EMetricSpace.toPseudoEMetricSpace.{u2} α (MetricSpace.toEMetricSpace.{u2} α (UniformEmbedding.comapMetricSpace.{u2, u1} α β _inst_1 _inst_2 f h))) (EMetricSpace.toPseudoEMetricSpace.{u1} β (MetricSpace.toEMetricSpace.{u1} β _inst_2)) f
Case conversion may be inaccurate. Consider using '#align uniform_embedding.to_isometry UniformEmbedding.to_isometryₓ'. -/
-- namespace
/-- A uniform embedding from a uniform space to a metric space is an isometry with respect to the
induced metric space structure on the source space. -/
theorem UniformEmbedding.to_isometry {α β} [UniformSpace α] [MetricSpace β] {f : α → β}
    (h : UniformEmbedding f) :
    @Isometry α β
      (@PseudoMetricSpace.toPseudoEMetricSpace α
        (@MetricSpace.toPseudoMetricSpace α (h.comapMetricSpace f)))
      (by infer_instance) f :=
  by
  apply Isometry.of_dist_eq
  intro x y
  rfl
#align uniform_embedding.to_isometry UniformEmbedding.to_isometry

/- warning: embedding.to_isometry -> Embedding.to_isometry is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : MetricSpace.{u2} β] {f : α -> β} (h : Embedding.{u1, u2} α β _inst_1 (UniformSpace.toTopologicalSpace.{u2} β (PseudoMetricSpace.toUniformSpace.{u2} β (MetricSpace.toPseudoMetricSpace.{u2} β _inst_2))) f), Isometry.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α (Embedding.comapMetricSpace.{u1, u2} α β _inst_1 _inst_2 f h))) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β (MetricSpace.toPseudoMetricSpace.{u2} β _inst_2)) f
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : MetricSpace.{u1} β] {f : α -> β} (h : Embedding.{u2, u1} α β _inst_1 (UniformSpace.toTopologicalSpace.{u1} β (PseudoMetricSpace.toUniformSpace.{u1} β (MetricSpace.toPseudoMetricSpace.{u1} β _inst_2))) f), Isometry.{u2, u1} α β (EMetricSpace.toPseudoEMetricSpace.{u2} α (MetricSpace.toEMetricSpace.{u2} α (Embedding.comapMetricSpace.{u2, u1} α β _inst_1 _inst_2 f h))) (EMetricSpace.toPseudoEMetricSpace.{u1} β (MetricSpace.toEMetricSpace.{u1} β _inst_2)) f
Case conversion may be inaccurate. Consider using '#align embedding.to_isometry Embedding.to_isometryₓ'. -/
/-- An embedding from a topological space to a metric space is an isometry with respect to the
induced metric space structure on the source space. -/
theorem Embedding.to_isometry {α β} [TopologicalSpace α] [MetricSpace β] {f : α → β}
    (h : Embedding f) :
    @Isometry α β
      (@PseudoMetricSpace.toPseudoEMetricSpace α
        (@MetricSpace.toPseudoMetricSpace α (h.comapMetricSpace f)))
      (by infer_instance) f :=
  by
  apply Isometry.of_dist_eq
  intro x y
  rfl
#align embedding.to_isometry Embedding.to_isometry

#print IsometryEquiv /-
-- such a bijection need not exist
/-- `α` and `β` are isometric if there is an isometric bijection between them. -/
@[nolint has_nonempty_instance]
structure IsometryEquiv (α β : Type _) [PseudoEMetricSpace α] [PseudoEMetricSpace β] extends
  α ≃ β where
  isometry_toFun : Isometry to_fun
#align isometry_equiv IsometryEquiv
-/

-- mathport name: «expr ≃ᵢ »
infixl:25 " ≃ᵢ " => IsometryEquiv

namespace IsometryEquiv

section PseudoEMetricSpace

variable [PseudoEMetricSpace α] [PseudoEMetricSpace β] [PseudoEMetricSpace γ]

instance : CoeFun (α ≃ᵢ β) fun _ => α → β :=
  ⟨fun e => e.toEquiv⟩

/- warning: isometry_equiv.coe_eq_to_equiv -> IsometryEquiv.coe_eq_toEquiv is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (a : α), Eq.{succ u2} β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h a) (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) (IsometryEquiv.toEquiv.{u1, u2} α β _inst_1 _inst_2 h) a)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (a : α), Eq.{succ u2} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) a) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h a) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (Equiv.{succ u1, succ u2} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.808 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u2} α β) (IsometryEquiv.toEquiv.{u1, u2} α β _inst_1 _inst_2 h) a)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.coe_eq_to_equiv IsometryEquiv.coe_eq_toEquivₓ'. -/
theorem coe_eq_toEquiv (h : α ≃ᵢ β) (a : α) : h a = h.toEquiv a :=
  rfl
#align isometry_equiv.coe_eq_to_equiv IsometryEquiv.coe_eq_toEquiv

#print IsometryEquiv.coe_toEquiv /-
@[simp]
theorem coe_toEquiv (h : α ≃ᵢ β) : ⇑h.toEquiv = h :=
  rfl
#align isometry_equiv.coe_to_equiv IsometryEquiv.coe_toEquiv
-/

/- warning: isometry_equiv.isometry -> IsometryEquiv.isometry is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Isometry.{u1, u2} α β _inst_1 _inst_2 (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Isometry.{u1, u2} α β _inst_1 _inst_2 (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.isometry IsometryEquiv.isometryₓ'. -/
protected theorem isometry (h : α ≃ᵢ β) : Isometry h :=
  h.isometry_toFun
#align isometry_equiv.isometry IsometryEquiv.isometry

/- warning: isometry_equiv.bijective -> IsometryEquiv.bijective is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Function.Bijective.{succ u1, succ u2} α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Function.Bijective.{succ u1, succ u2} α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.bijective IsometryEquiv.bijectiveₓ'. -/
protected theorem bijective (h : α ≃ᵢ β) : Bijective h :=
  h.toEquiv.Bijective
#align isometry_equiv.bijective IsometryEquiv.bijective

/- warning: isometry_equiv.injective -> IsometryEquiv.injective is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Function.Injective.{succ u1, succ u2} α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Function.Injective.{succ u1, succ u2} α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.injective IsometryEquiv.injectiveₓ'. -/
protected theorem injective (h : α ≃ᵢ β) : Injective h :=
  h.toEquiv.Injective
#align isometry_equiv.injective IsometryEquiv.injective

/- warning: isometry_equiv.surjective -> IsometryEquiv.surjective is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Function.Surjective.{succ u1, succ u2} α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Function.Surjective.{succ u1, succ u2} α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.surjective IsometryEquiv.surjectiveₓ'. -/
protected theorem surjective (h : α ≃ᵢ β) : Surjective h :=
  h.toEquiv.Surjective
#align isometry_equiv.surjective IsometryEquiv.surjective

/- warning: isometry_equiv.edist_eq -> IsometryEquiv.edist_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (x : α) (y : α), Eq.{1} ENNReal (EDist.edist.{u2} β (PseudoEMetricSpace.toHasEdist.{u2} β _inst_2) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h x) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h y)) (EDist.edist.{u1} α (PseudoEMetricSpace.toHasEdist.{u1} α _inst_1) x y)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (x : α) (y : α), Eq.{1} ENNReal (EDist.edist.{u2} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) x) (PseudoEMetricSpace.toEDist.{u2} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) x) _inst_2) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h x) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h y)) (EDist.edist.{u1} α (PseudoEMetricSpace.toEDist.{u1} α _inst_1) x y)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.edist_eq IsometryEquiv.edist_eqₓ'. -/
protected theorem edist_eq (h : α ≃ᵢ β) (x y : α) : edist (h x) (h y) = edist x y :=
  h.Isometry.edist_eq x y
#align isometry_equiv.edist_eq IsometryEquiv.edist_eq

/- warning: isometry_equiv.dist_eq -> IsometryEquiv.dist_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_4 : PseudoMetricSpace.{u1} α] [_inst_5 : PseudoMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_5)) (x : α) (y : α), Eq.{1} Real (Dist.dist.{u2} β (PseudoMetricSpace.toHasDist.{u2} β _inst_5) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_5)) (fun (_x : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_5)) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_5)) h x) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_5)) (fun (_x : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_5)) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_5)) h y)) (Dist.dist.{u1} α (PseudoMetricSpace.toHasDist.{u1} α _inst_4) x y)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_4 : PseudoMetricSpace.{u2} α] [_inst_5 : PseudoMetricSpace.{u1} β] (h : IsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)) (x : α) (y : α), Eq.{1} Real (Dist.dist.{u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) x) (PseudoMetricSpace.toDist.{u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) x) _inst_5) (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (IsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u2) (succ u1), succ u2, succ u1} (IsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)) α β (EquivLike.toEmbeddingLike.{max (succ u2) (succ u1), succ u2, succ u1} (IsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)))) h x) (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (IsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u2) (succ u1), succ u2, succ u1} (IsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)) α β (EquivLike.toEmbeddingLike.{max (succ u2) (succ u1), succ u2, succ u1} (IsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)))) h y)) (Dist.dist.{u2} α (PseudoMetricSpace.toDist.{u2} α _inst_4) x y)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.dist_eq IsometryEquiv.dist_eqₓ'. -/
protected theorem dist_eq {α β : Type _} [PseudoMetricSpace α] [PseudoMetricSpace β] (h : α ≃ᵢ β)
    (x y : α) : dist (h x) (h y) = dist x y :=
  h.Isometry.dist_eq x y
#align isometry_equiv.dist_eq IsometryEquiv.dist_eq

/- warning: isometry_equiv.nndist_eq -> IsometryEquiv.nndist_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_4 : PseudoMetricSpace.{u1} α] [_inst_5 : PseudoMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_5)) (x : α) (y : α), Eq.{1} NNReal (NNDist.nndist.{u2} β (PseudoMetricSpace.toNNDist.{u2} β _inst_5) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_5)) (fun (_x : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_5)) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_5)) h x) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_5)) (fun (_x : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_5)) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_5)) h y)) (NNDist.nndist.{u1} α (PseudoMetricSpace.toNNDist.{u1} α _inst_4) x y)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_4 : PseudoMetricSpace.{u2} α] [_inst_5 : PseudoMetricSpace.{u1} β] (h : IsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)) (x : α) (y : α), Eq.{1} NNReal (NNDist.nndist.{u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) x) (PseudoMetricSpace.toNNDist.{u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) x) _inst_5) (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (IsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u2) (succ u1), succ u2, succ u1} (IsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)) α β (EquivLike.toEmbeddingLike.{max (succ u2) (succ u1), succ u2, succ u1} (IsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)))) h x) (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (IsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u2) (succ u1), succ u2, succ u1} (IsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)) α β (EquivLike.toEmbeddingLike.{max (succ u2) (succ u1), succ u2, succ u1} (IsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u2} α _inst_4) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} β _inst_5)))) h y)) (NNDist.nndist.{u2} α (PseudoMetricSpace.toNNDist.{u2} α _inst_4) x y)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.nndist_eq IsometryEquiv.nndist_eqₓ'. -/
protected theorem nndist_eq {α β : Type _} [PseudoMetricSpace α] [PseudoMetricSpace β] (h : α ≃ᵢ β)
    (x y : α) : nndist (h x) (h y) = nndist x y :=
  h.Isometry.nndist_eq x y
#align isometry_equiv.nndist_eq IsometryEquiv.nndist_eq

/- warning: isometry_equiv.continuous -> IsometryEquiv.continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Continuous.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Continuous.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.continuous IsometryEquiv.continuousₓ'. -/
protected theorem continuous (h : α ≃ᵢ β) : Continuous h :=
  h.Isometry.Continuous
#align isometry_equiv.continuous IsometryEquiv.continuous

#print IsometryEquiv.ediam_image /-
@[simp]
theorem ediam_image (h : α ≃ᵢ β) (s : Set α) : EMetric.diam (h '' s) = EMetric.diam s :=
  h.Isometry.ediam_image s
#align isometry_equiv.ediam_image IsometryEquiv.ediam_image
-/

#print IsometryEquiv.toEquiv_injective /-
theorem toEquiv_injective : ∀ ⦃h₁ h₂ : α ≃ᵢ β⦄, h₁.toEquiv = h₂.toEquiv → h₁ = h₂
  | ⟨e₁, h₁⟩, ⟨e₂, h₂⟩, H => by
    dsimp at H
    subst e₁
#align isometry_equiv.to_equiv_inj IsometryEquiv.toEquiv_injective
-/

/- warning: isometry_equiv.ext -> IsometryEquiv.ext is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] {{h₁ : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2}} {{h₂ : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2}}, (forall (x : α), Eq.{succ u2} β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h₁ x) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h₂ x)) -> (Eq.{max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) h₁ h₂)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] {{h₁ : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2}} {{h₂ : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2}}, (forall (x : α), Eq.{succ u2} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) x) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h₁ x) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h₂ x)) -> (Eq.{max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) h₁ h₂)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.ext IsometryEquiv.extₓ'. -/
@[ext]
theorem ext ⦃h₁ h₂ : α ≃ᵢ β⦄ (H : ∀ x, h₁ x = h₂ x) : h₁ = h₂ :=
  toEquiv_injective <| Equiv.ext H
#align isometry_equiv.ext IsometryEquiv.ext

#print IsometryEquiv.mk' /-
/-- Alternative constructor for isometric bijections,
taking as input an isometry, and a right inverse. -/
def mk' {α : Type u} [EMetricSpace α] (f : α → β) (g : β → α) (hfg : ∀ x, f (g x) = x)
    (hf : Isometry f) : α ≃ᵢ β where
  toFun := f
  invFun := g
  left_inv x := hf.Injective <| hfg _
  right_inv := hfg
  isometry_toFun := hf
#align isometry_equiv.mk' IsometryEquiv.mk'
-/

#print IsometryEquiv.refl /-
/-- The identity isometry of a space. -/
protected def refl (α : Type _) [PseudoEMetricSpace α] : α ≃ᵢ α :=
  { Equiv.refl α with isometry_toFun := isometry_id }
#align isometry_equiv.refl IsometryEquiv.refl
-/

#print IsometryEquiv.trans /-
/-- The composition of two isometric isomorphisms, as an isometric isomorphism. -/
protected def trans (h₁ : α ≃ᵢ β) (h₂ : β ≃ᵢ γ) : α ≃ᵢ γ :=
  { Equiv.trans h₁.toEquiv h₂.toEquiv with
    isometry_toFun := h₂.isometry_toFun.comp h₁.isometry_toFun }
#align isometry_equiv.trans IsometryEquiv.trans
-/

/- warning: isometry_equiv.trans_apply -> IsometryEquiv.trans_apply is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] [_inst_3 : PseudoEMetricSpace.{u3} γ] (h₁ : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (h₂ : IsometryEquiv.{u2, u3} β γ _inst_2 _inst_3) (x : α), Eq.{succ u3} γ (coeFn.{max (succ u1) (succ u3), max (succ u1) (succ u3)} (IsometryEquiv.{u1, u3} α γ _inst_1 _inst_3) (fun (_x : IsometryEquiv.{u1, u3} α γ _inst_1 _inst_3) => α -> γ) (IsometryEquiv.hasCoeToFun.{u1, u3} α γ _inst_1 _inst_3) (IsometryEquiv.trans.{u1, u2, u3} α β γ _inst_1 _inst_2 _inst_3 h₁ h₂) x) (coeFn.{max (succ u2) (succ u3), max (succ u2) (succ u3)} (IsometryEquiv.{u2, u3} β γ _inst_2 _inst_3) (fun (_x : IsometryEquiv.{u2, u3} β γ _inst_2 _inst_3) => β -> γ) (IsometryEquiv.hasCoeToFun.{u2, u3} β γ _inst_2 _inst_3) h₂ (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h₁ x))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] [_inst_3 : PseudoEMetricSpace.{u3} γ] (h₁ : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (h₂ : IsometryEquiv.{u2, u3} β γ _inst_2 _inst_3) (x : α), Eq.{succ u3} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => γ) x) (FunLike.coe.{max (succ u1) (succ u3), succ u1, succ u3} (IsometryEquiv.{u1, u3} α γ _inst_1 _inst_3) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => γ) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u3), succ u1, succ u3} (IsometryEquiv.{u1, u3} α γ _inst_1 _inst_3) α γ (EquivLike.toEmbeddingLike.{max (succ u1) (succ u3), succ u1, succ u3} (IsometryEquiv.{u1, u3} α γ _inst_1 _inst_3) α γ (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u3} α γ _inst_1 _inst_3))) (IsometryEquiv.trans.{u1, u2, u3} α β γ _inst_1 _inst_2 _inst_3 h₁ h₂) x) (FunLike.coe.{max (succ u2) (succ u3), succ u2, succ u3} (IsometryEquiv.{u2, u3} β γ _inst_2 _inst_3) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => γ) _x) (EmbeddingLike.toFunLike.{max (succ u2) (succ u3), succ u2, succ u3} (IsometryEquiv.{u2, u3} β γ _inst_2 _inst_3) β γ (EquivLike.toEmbeddingLike.{max (succ u2) (succ u3), succ u2, succ u3} (IsometryEquiv.{u2, u3} β γ _inst_2 _inst_3) β γ (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u3} β γ _inst_2 _inst_3))) h₂ (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h₁ x))
Case conversion may be inaccurate. Consider using '#align isometry_equiv.trans_apply IsometryEquiv.trans_applyₓ'. -/
@[simp]
theorem trans_apply (h₁ : α ≃ᵢ β) (h₂ : β ≃ᵢ γ) (x : α) : h₁.trans h₂ x = h₂ (h₁ x) :=
  rfl
#align isometry_equiv.trans_apply IsometryEquiv.trans_apply

#print IsometryEquiv.symm /-
/-- The inverse of an isometric isomorphism, as an isometric isomorphism. -/
protected def symm (h : α ≃ᵢ β) : β ≃ᵢ α
    where
  isometry_toFun := h.Isometry.right_inv h.right_inv
  toEquiv := h.toEquiv.symm
#align isometry_equiv.symm IsometryEquiv.symm
-/

#print IsometryEquiv.Simps.apply /-
/-- See Note [custom simps projection]. We need to specify this projection explicitly in this case,
  because it is a composition of multiple projections. -/
def Simps.apply (h : α ≃ᵢ β) : α → β :=
  h
#align isometry_equiv.simps.apply IsometryEquiv.Simps.apply
-/

#print IsometryEquiv.Simps.symm_apply /-
/-- See Note [custom simps projection] -/
def Simps.symm_apply (h : α ≃ᵢ β) : β → α :=
  h.symm
#align isometry_equiv.simps.symm_apply IsometryEquiv.Simps.symm_apply
-/

initialize_simps_projections IsometryEquiv (to_equiv_to_fun → apply, to_equiv_inv_fun → symm_apply)

#print IsometryEquiv.symm_symm /-
@[simp]
theorem symm_symm (h : α ≃ᵢ β) : h.symm.symm = h :=
  toEquiv_injective h.toEquiv.symm_symm
#align isometry_equiv.symm_symm IsometryEquiv.symm_symm
-/

/- warning: isometry_equiv.apply_symm_apply -> IsometryEquiv.apply_symm_apply is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (y : β), Eq.{succ u2} β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) (fun (_x : IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) => β -> α) (IsometryEquiv.hasCoeToFun.{u2, u1} β α _inst_2 _inst_1) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h) y)) y
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (y : β), Eq.{succ u2} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β (fun (a : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) a) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α _inst_2 _inst_1))) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h) y)) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α _inst_2 _inst_1))) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h) y)) y
Case conversion may be inaccurate. Consider using '#align isometry_equiv.apply_symm_apply IsometryEquiv.apply_symm_applyₓ'. -/
@[simp]
theorem apply_symm_apply (h : α ≃ᵢ β) (y : β) : h (h.symm y) = y :=
  h.toEquiv.apply_symm_apply y
#align isometry_equiv.apply_symm_apply IsometryEquiv.apply_symm_apply

/- warning: isometry_equiv.symm_apply_apply -> IsometryEquiv.symm_apply_apply is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (x : α), Eq.{succ u1} α (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) (fun (_x : IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) => β -> α) (IsometryEquiv.hasCoeToFun.{u2, u1} β α _inst_2 _inst_1) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h x)) x
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (x : α), Eq.{succ u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (a : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) a) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h x)) (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α _inst_2 _inst_1))) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h x)) x
Case conversion may be inaccurate. Consider using '#align isometry_equiv.symm_apply_apply IsometryEquiv.symm_apply_applyₓ'. -/
@[simp]
theorem symm_apply_apply (h : α ≃ᵢ β) (x : α) : h.symm (h x) = x :=
  h.toEquiv.symm_apply_apply x
#align isometry_equiv.symm_apply_apply IsometryEquiv.symm_apply_apply

/- warning: isometry_equiv.symm_apply_eq -> IsometryEquiv.symm_apply_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) {x : α} {y : β}, Iff (Eq.{succ u1} α (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) (fun (_x : IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) => β -> α) (IsometryEquiv.hasCoeToFun.{u2, u1} β α _inst_2 _inst_1) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h) y) x) (Eq.{succ u2} β y (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h x))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) {x : α} {y : β}, Iff (Eq.{succ u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) y) (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α _inst_2 _inst_1))) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h) y) x) (Eq.{succ u2} β y (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h x))
Case conversion may be inaccurate. Consider using '#align isometry_equiv.symm_apply_eq IsometryEquiv.symm_apply_eqₓ'. -/
theorem symm_apply_eq (h : α ≃ᵢ β) {x : α} {y : β} : h.symm y = x ↔ y = h x :=
  h.toEquiv.symm_apply_eq
#align isometry_equiv.symm_apply_eq IsometryEquiv.symm_apply_eq

/- warning: isometry_equiv.eq_symm_apply -> IsometryEquiv.eq_symm_apply is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) {x : α} {y : β}, Iff (Eq.{succ u1} α x (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) (fun (_x : IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) => β -> α) (IsometryEquiv.hasCoeToFun.{u2, u1} β α _inst_2 _inst_1) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h) y)) (Eq.{succ u2} β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h x) y)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) {x : α} {y : β}, Iff (Eq.{succ u1} α x (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α _inst_2 _inst_1))) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h) y)) (Eq.{succ u2} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) x) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h x) y)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.eq_symm_apply IsometryEquiv.eq_symm_applyₓ'. -/
theorem eq_symm_apply (h : α ≃ᵢ β) {x : α} {y : β} : x = h.symm y ↔ h x = y :=
  h.toEquiv.eq_symm_apply
#align isometry_equiv.eq_symm_apply IsometryEquiv.eq_symm_apply

/- warning: isometry_equiv.symm_comp_self -> IsometryEquiv.symm_comp_self is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Eq.{succ u1} (α -> α) (Function.comp.{succ u1, succ u2, succ u1} α β α (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) (fun (_x : IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) => β -> α) (IsometryEquiv.hasCoeToFun.{u2, u1} β α _inst_2 _inst_1) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h)) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h)) (id.{succ u1} α)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Eq.{succ u1} (α -> α) (Function.comp.{succ u1, succ u2, succ u1} α β α (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α _inst_2 _inst_1))) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h)) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h)) (id.{succ u1} α)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.symm_comp_self IsometryEquiv.symm_comp_selfₓ'. -/
theorem symm_comp_self (h : α ≃ᵢ β) : ⇑h.symm ∘ ⇑h = id :=
  funext fun a => h.toEquiv.left_inv a
#align isometry_equiv.symm_comp_self IsometryEquiv.symm_comp_self

/- warning: isometry_equiv.self_comp_symm -> IsometryEquiv.self_comp_symm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Eq.{succ u2} (β -> β) (Function.comp.{succ u2, succ u1, succ u2} β α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h) (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) (fun (_x : IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) => β -> α) (IsometryEquiv.hasCoeToFun.{u2, u1} β α _inst_2 _inst_1) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h))) (id.{succ u2} β)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Eq.{succ u2} (β -> β) (Function.comp.{succ u2, succ u1, succ u2} β α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h) (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α _inst_2 _inst_1))) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h))) (id.{succ u2} β)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.self_comp_symm IsometryEquiv.self_comp_symmₓ'. -/
theorem self_comp_symm (h : α ≃ᵢ β) : ⇑h ∘ ⇑h.symm = id :=
  funext fun a => h.toEquiv.right_inv a
#align isometry_equiv.self_comp_symm IsometryEquiv.self_comp_symm

/- warning: isometry_equiv.range_eq_univ -> IsometryEquiv.range_eq_univ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Eq.{succ u2} (Set.{u2} β) (Set.range.{u2, succ u1} β α (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h)) (Set.univ.{u2} β)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Eq.{succ u2} (Set.{u2} β) (Set.range.{u2, succ u1} β α (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h)) (Set.univ.{u2} β)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.range_eq_univ IsometryEquiv.range_eq_univₓ'. -/
@[simp]
theorem range_eq_univ (h : α ≃ᵢ β) : range h = univ :=
  h.toEquiv.range_eq_univ
#align isometry_equiv.range_eq_univ IsometryEquiv.range_eq_univ

/- warning: isometry_equiv.image_symm -> IsometryEquiv.image_symm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Eq.{max (succ u2) (succ u1)} ((Set.{u2} β) -> (Set.{u1} α)) (Set.image.{u2, u1} β α (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) (fun (_x : IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) => β -> α) (IsometryEquiv.hasCoeToFun.{u2, u1} β α _inst_2 _inst_1) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h))) (Set.preimage.{u1, u2} α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Eq.{max (succ u1) (succ u2)} ((Set.{u2} β) -> (Set.{u1} α)) (Set.image.{u2, u1} β α (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α _inst_2 _inst_1))) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h))) (Set.preimage.{u1, u2} α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h))
Case conversion may be inaccurate. Consider using '#align isometry_equiv.image_symm IsometryEquiv.image_symmₓ'. -/
theorem image_symm (h : α ≃ᵢ β) : image h.symm = preimage h :=
  image_eq_preimage_of_inverse h.symm.toEquiv.left_inv h.symm.toEquiv.right_inv
#align isometry_equiv.image_symm IsometryEquiv.image_symm

/- warning: isometry_equiv.preimage_symm -> IsometryEquiv.preimage_symm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Eq.{max (succ u1) (succ u2)} ((Set.{u1} α) -> (Set.{u2} β)) (Set.preimage.{u2, u1} β α (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) (fun (_x : IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) => β -> α) (IsometryEquiv.hasCoeToFun.{u2, u1} β α _inst_2 _inst_1) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h))) (Set.image.{u1, u2} α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Eq.{max (succ u1) (succ u2)} ((Set.{u1} α) -> (Set.{u2} β)) (Set.preimage.{u2, u1} β α (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α _inst_2 _inst_1))) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h))) (Set.image.{u1, u2} α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h))
Case conversion may be inaccurate. Consider using '#align isometry_equiv.preimage_symm IsometryEquiv.preimage_symmₓ'. -/
theorem preimage_symm (h : α ≃ᵢ β) : preimage h.symm = image h :=
  (image_eq_preimage_of_inverse h.toEquiv.left_inv h.toEquiv.right_inv).symm
#align isometry_equiv.preimage_symm IsometryEquiv.preimage_symm

/- warning: isometry_equiv.symm_trans_apply -> IsometryEquiv.symm_trans_apply is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] [_inst_3 : PseudoEMetricSpace.{u3} γ] (h₁ : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (h₂ : IsometryEquiv.{u2, u3} β γ _inst_2 _inst_3) (x : γ), Eq.{succ u1} α (coeFn.{max (succ u3) (succ u1), max (succ u3) (succ u1)} (IsometryEquiv.{u3, u1} γ α _inst_3 _inst_1) (fun (_x : IsometryEquiv.{u3, u1} γ α _inst_3 _inst_1) => γ -> α) (IsometryEquiv.hasCoeToFun.{u3, u1} γ α _inst_3 _inst_1) (IsometryEquiv.symm.{u1, u3} α γ _inst_1 _inst_3 (IsometryEquiv.trans.{u1, u2, u3} α β γ _inst_1 _inst_2 _inst_3 h₁ h₂)) x) (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) (fun (_x : IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) => β -> α) (IsometryEquiv.hasCoeToFun.{u2, u1} β α _inst_2 _inst_1) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h₁) (coeFn.{max (succ u3) (succ u2), max (succ u3) (succ u2)} (IsometryEquiv.{u3, u2} γ β _inst_3 _inst_2) (fun (_x : IsometryEquiv.{u3, u2} γ β _inst_3 _inst_2) => γ -> β) (IsometryEquiv.hasCoeToFun.{u3, u2} γ β _inst_3 _inst_2) (IsometryEquiv.symm.{u2, u3} β γ _inst_2 _inst_3 h₂) x))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] [_inst_3 : PseudoEMetricSpace.{u3} γ] (h₁ : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (h₂ : IsometryEquiv.{u2, u3} β γ _inst_2 _inst_3) (x : γ), Eq.{succ u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : γ) => α) x) (FunLike.coe.{max (succ u1) (succ u3), succ u3, succ u1} (IsometryEquiv.{u3, u1} γ α _inst_3 _inst_1) γ (fun (_x : γ) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : γ) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u3), succ u3, succ u1} (IsometryEquiv.{u3, u1} γ α _inst_3 _inst_1) γ α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u3), succ u3, succ u1} (IsometryEquiv.{u3, u1} γ α _inst_3 _inst_1) γ α (IsometryEquiv.instEquivLikeIsometryEquiv.{u3, u1} γ α _inst_3 _inst_1))) (IsometryEquiv.symm.{u1, u3} α γ _inst_1 _inst_3 (IsometryEquiv.trans.{u1, u2, u3} α β γ _inst_1 _inst_2 _inst_3 h₁ h₂)) x) (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α _inst_2 _inst_1))) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h₁) (FunLike.coe.{max (succ u2) (succ u3), succ u3, succ u2} (IsometryEquiv.{u3, u2} γ β _inst_3 _inst_2) γ (fun (_x : γ) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : γ) => β) _x) (EmbeddingLike.toFunLike.{max (succ u2) (succ u3), succ u3, succ u2} (IsometryEquiv.{u3, u2} γ β _inst_3 _inst_2) γ β (EquivLike.toEmbeddingLike.{max (succ u2) (succ u3), succ u3, succ u2} (IsometryEquiv.{u3, u2} γ β _inst_3 _inst_2) γ β (IsometryEquiv.instEquivLikeIsometryEquiv.{u3, u2} γ β _inst_3 _inst_2))) (IsometryEquiv.symm.{u2, u3} β γ _inst_2 _inst_3 h₂) x))
Case conversion may be inaccurate. Consider using '#align isometry_equiv.symm_trans_apply IsometryEquiv.symm_trans_applyₓ'. -/
@[simp]
theorem symm_trans_apply (h₁ : α ≃ᵢ β) (h₂ : β ≃ᵢ γ) (x : γ) :
    (h₁.trans h₂).symm x = h₁.symm (h₂.symm x) :=
  rfl
#align isometry_equiv.symm_trans_apply IsometryEquiv.symm_trans_apply

#print IsometryEquiv.ediam_univ /-
theorem ediam_univ (h : α ≃ᵢ β) : EMetric.diam (univ : Set α) = EMetric.diam (univ : Set β) := by
  rw [← h.range_eq_univ, h.isometry.ediam_range]
#align isometry_equiv.ediam_univ IsometryEquiv.ediam_univ
-/

#print IsometryEquiv.ediam_preimage /-
@[simp]
theorem ediam_preimage (h : α ≃ᵢ β) (s : Set β) : EMetric.diam (h ⁻¹' s) = EMetric.diam s := by
  rw [← image_symm, ediam_image]
#align isometry_equiv.ediam_preimage IsometryEquiv.ediam_preimage
-/

/- warning: isometry_equiv.preimage_emetric_ball -> IsometryEquiv.preimage_emetric_ball is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (x : β) (r : ENNReal), Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h) (EMetric.ball.{u2} β _inst_2 x r)) (EMetric.ball.{u1} α _inst_1 (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) (fun (_x : IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) => β -> α) (IsometryEquiv.hasCoeToFun.{u2, u1} β α _inst_2 _inst_1) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h) x) r)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (x : β) (r : ENNReal), Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h) (EMetric.ball.{u2} β _inst_2 x r)) (EMetric.ball.{u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) x) _inst_1 (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α _inst_2 _inst_1))) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h) x) r)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.preimage_emetric_ball IsometryEquiv.preimage_emetric_ballₓ'. -/
@[simp]
theorem preimage_emetric_ball (h : α ≃ᵢ β) (x : β) (r : ℝ≥0∞) :
    h ⁻¹' EMetric.ball x r = EMetric.ball (h.symm x) r := by
  rw [← h.isometry.preimage_emetric_ball (h.symm x) r, h.apply_symm_apply]
#align isometry_equiv.preimage_emetric_ball IsometryEquiv.preimage_emetric_ball

/- warning: isometry_equiv.preimage_emetric_closed_ball -> IsometryEquiv.preimage_emetric_closedBall is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (x : β) (r : ENNReal), Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h) (EMetric.closedBall.{u2} β _inst_2 x r)) (EMetric.closedBall.{u1} α _inst_1 (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) (fun (_x : IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) => β -> α) (IsometryEquiv.hasCoeToFun.{u2, u1} β α _inst_2 _inst_1) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h) x) r)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (x : β) (r : ENNReal), Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h) (EMetric.closedBall.{u2} β _inst_2 x r)) (EMetric.closedBall.{u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) x) _inst_1 (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α _inst_2 _inst_1))) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h) x) r)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.preimage_emetric_closed_ball IsometryEquiv.preimage_emetric_closedBallₓ'. -/
@[simp]
theorem preimage_emetric_closedBall (h : α ≃ᵢ β) (x : β) (r : ℝ≥0∞) :
    h ⁻¹' EMetric.closedBall x r = EMetric.closedBall (h.symm x) r := by
  rw [← h.isometry.preimage_emetric_closed_ball (h.symm x) r, h.apply_symm_apply]
#align isometry_equiv.preimage_emetric_closed_ball IsometryEquiv.preimage_emetric_closedBall

/- warning: isometry_equiv.image_emetric_ball -> IsometryEquiv.image_emetric_ball is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (x : α) (r : ENNReal), Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h) (EMetric.ball.{u1} α _inst_1 x r)) (EMetric.ball.{u2} β _inst_2 (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h x) r)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (x : α) (r : ENNReal), Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h) (EMetric.ball.{u1} α _inst_1 x r)) (EMetric.ball.{u2} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) x) _inst_2 (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h x) r)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.image_emetric_ball IsometryEquiv.image_emetric_ballₓ'. -/
@[simp]
theorem image_emetric_ball (h : α ≃ᵢ β) (x : α) (r : ℝ≥0∞) :
    h '' EMetric.ball x r = EMetric.ball (h x) r := by
  rw [← h.preimage_symm, h.symm.preimage_emetric_ball, symm_symm]
#align isometry_equiv.image_emetric_ball IsometryEquiv.image_emetric_ball

/- warning: isometry_equiv.image_emetric_closed_ball -> IsometryEquiv.image_emetric_closedBall is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (x : α) (r : ENNReal), Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h) (EMetric.closedBall.{u1} α _inst_1 x r)) (EMetric.closedBall.{u2} β _inst_2 (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h x) r)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (x : α) (r : ENNReal), Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h) (EMetric.closedBall.{u1} α _inst_1 x r)) (EMetric.closedBall.{u2} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) x) _inst_2 (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h x) r)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.image_emetric_closed_ball IsometryEquiv.image_emetric_closedBallₓ'. -/
@[simp]
theorem image_emetric_closedBall (h : α ≃ᵢ β) (x : α) (r : ℝ≥0∞) :
    h '' EMetric.closedBall x r = EMetric.closedBall (h x) r := by
  rw [← h.preimage_symm, h.symm.preimage_emetric_closed_ball, symm_symm]
#align isometry_equiv.image_emetric_closed_ball IsometryEquiv.image_emetric_closedBall

#print IsometryEquiv.toHomeomorph /-
/-- The (bundled) homeomorphism associated to an isometric isomorphism. -/
@[simps toEquiv]
protected def toHomeomorph (h : α ≃ᵢ β) : α ≃ₜ β
    where
  continuous_toFun := h.Continuous
  continuous_invFun := h.symm.Continuous
  toEquiv := h.toEquiv
#align isometry_equiv.to_homeomorph IsometryEquiv.toHomeomorph
-/

/- warning: isometry_equiv.coe_to_homeomorph -> IsometryEquiv.coe_toHomeomorph is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Eq.{max (succ u1) (succ u2)} (α -> β) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (Homeomorph.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2))) (fun (_x : Homeomorph.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2))) => α -> β) (Homeomorph.hasCoeToFun.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2))) (IsometryEquiv.toHomeomorph.{u1, u2} α β _inst_1 _inst_2 h)) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Eq.{max (succ u1) (succ u2)} (α -> β) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (Homeomorph.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2))) α (fun (_x : α) => β) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (Homeomorph.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2))) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (Homeomorph.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2))) α β (Homeomorph.instEquivLikeHomeomorph.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2))))) (IsometryEquiv.toHomeomorph.{u1, u2} α β _inst_1 _inst_2 h)) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β _inst_1 _inst_2))) h)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.coe_to_homeomorph IsometryEquiv.coe_toHomeomorphₓ'. -/
@[simp]
theorem coe_toHomeomorph (h : α ≃ᵢ β) : ⇑h.toHomeomorph = h :=
  rfl
#align isometry_equiv.coe_to_homeomorph IsometryEquiv.coe_toHomeomorph

/- warning: isometry_equiv.coe_to_homeomorph_symm -> IsometryEquiv.coe_toHomeomorph_symm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Eq.{max (succ u2) (succ u1)} (β -> α) (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (Homeomorph.{u2, u1} β α (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1))) (fun (_x : Homeomorph.{u2, u1} β α (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1))) => β -> α) (Homeomorph.hasCoeToFun.{u2, u1} β α (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1))) (Homeomorph.symm.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (IsometryEquiv.toHomeomorph.{u1, u2} α β _inst_1 _inst_2 h))) (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) (fun (_x : IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) => β -> α) (IsometryEquiv.hasCoeToFun.{u2, u1} β α _inst_2 _inst_1) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2), Eq.{max (succ u1) (succ u2)} (β -> α) (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Homeomorph.{u2, u1} β α (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1))) β (fun (_x : β) => α) (EmbeddingLike.toFunLike.{max (succ u2) (succ u1), succ u2, succ u1} (Homeomorph.{u2, u1} β α (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1))) β α (EquivLike.toEmbeddingLike.{max (succ u2) (succ u1), succ u2, succ u1} (Homeomorph.{u2, u1} β α (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1))) β α (Homeomorph.instEquivLikeHomeomorph.{u2, u1} β α (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1))))) (Homeomorph.symm.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (IsometryEquiv.toHomeomorph.{u1, u2} α β _inst_1 _inst_2 h))) (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α _inst_2 _inst_1) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α _inst_2 _inst_1))) (IsometryEquiv.symm.{u1, u2} α β _inst_1 _inst_2 h))
Case conversion may be inaccurate. Consider using '#align isometry_equiv.coe_to_homeomorph_symm IsometryEquiv.coe_toHomeomorph_symmₓ'. -/
@[simp]
theorem coe_toHomeomorph_symm (h : α ≃ᵢ β) : ⇑h.toHomeomorph.symm = h.symm :=
  rfl
#align isometry_equiv.coe_to_homeomorph_symm IsometryEquiv.coe_toHomeomorph_symm

/- warning: isometry_equiv.comp_continuous_on_iff -> IsometryEquiv.comp_continuousOn_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] {γ : Type.{u3}} [_inst_4 : TopologicalSpace.{u3} γ] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) {f : γ -> α} {s : Set.{u3} γ}, Iff (ContinuousOn.{u3, u2} γ β _inst_4 (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (Function.comp.{succ u3, succ u1, succ u2} γ α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h) f) s) (ContinuousOn.{u3, u1} γ α _inst_4 (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) f s)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u3}} [_inst_1 : PseudoEMetricSpace.{u2} α] [_inst_2 : PseudoEMetricSpace.{u3} β] {γ : Type.{u1}} [_inst_4 : TopologicalSpace.{u1} γ] (h : IsometryEquiv.{u2, u3} α β _inst_1 _inst_2) {f : γ -> α} {s : Set.{u1} γ}, Iff (ContinuousOn.{u1, u3} γ β _inst_4 (UniformSpace.toTopologicalSpace.{u3} β (PseudoEMetricSpace.toUniformSpace.{u3} β _inst_2)) (Function.comp.{succ u1, succ u2, succ u3} γ α β (FunLike.coe.{max (succ u2) (succ u3), succ u2, succ u3} (IsometryEquiv.{u2, u3} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u2) (succ u3), succ u2, succ u3} (IsometryEquiv.{u2, u3} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u2) (succ u3), succ u2, succ u3} (IsometryEquiv.{u2, u3} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u3} α β _inst_1 _inst_2))) h) f) s) (ContinuousOn.{u1, u2} γ α _inst_4 (UniformSpace.toTopologicalSpace.{u2} α (PseudoEMetricSpace.toUniformSpace.{u2} α _inst_1)) f s)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.comp_continuous_on_iff IsometryEquiv.comp_continuousOn_iffₓ'. -/
@[simp]
theorem comp_continuousOn_iff {γ} [TopologicalSpace γ] (h : α ≃ᵢ β) {f : γ → α} {s : Set γ} :
    ContinuousOn (h ∘ f) s ↔ ContinuousOn f s :=
  h.toHomeomorph.comp_continuousOn_iff _ _
#align isometry_equiv.comp_continuous_on_iff IsometryEquiv.comp_continuousOn_iff

/- warning: isometry_equiv.comp_continuous_iff -> IsometryEquiv.comp_continuous_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] {γ : Type.{u3}} [_inst_4 : TopologicalSpace.{u3} γ] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) {f : γ -> α}, Iff (Continuous.{u3, u2} γ β _inst_4 (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) (Function.comp.{succ u3, succ u1, succ u2} γ α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h) f)) (Continuous.{u3, u1} γ α _inst_4 (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u3}} [_inst_1 : PseudoEMetricSpace.{u2} α] [_inst_2 : PseudoEMetricSpace.{u3} β] {γ : Type.{u1}} [_inst_4 : TopologicalSpace.{u1} γ] (h : IsometryEquiv.{u2, u3} α β _inst_1 _inst_2) {f : γ -> α}, Iff (Continuous.{u1, u3} γ β _inst_4 (UniformSpace.toTopologicalSpace.{u3} β (PseudoEMetricSpace.toUniformSpace.{u3} β _inst_2)) (Function.comp.{succ u1, succ u2, succ u3} γ α β (FunLike.coe.{max (succ u2) (succ u3), succ u2, succ u3} (IsometryEquiv.{u2, u3} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u2) (succ u3), succ u2, succ u3} (IsometryEquiv.{u2, u3} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u2) (succ u3), succ u2, succ u3} (IsometryEquiv.{u2, u3} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u3} α β _inst_1 _inst_2))) h) f)) (Continuous.{u1, u2} γ α _inst_4 (UniformSpace.toTopologicalSpace.{u2} α (PseudoEMetricSpace.toUniformSpace.{u2} α _inst_1)) f)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.comp_continuous_iff IsometryEquiv.comp_continuous_iffₓ'. -/
@[simp]
theorem comp_continuous_iff {γ} [TopologicalSpace γ] (h : α ≃ᵢ β) {f : γ → α} :
    Continuous (h ∘ f) ↔ Continuous f :=
  h.toHomeomorph.comp_continuous_iff
#align isometry_equiv.comp_continuous_iff IsometryEquiv.comp_continuous_iff

/- warning: isometry_equiv.comp_continuous_iff' -> IsometryEquiv.comp_continuous_iff' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoEMetricSpace.{u1} α] [_inst_2 : PseudoEMetricSpace.{u2} β] {γ : Type.{u3}} [_inst_4 : TopologicalSpace.{u3} γ] (h : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) {f : β -> γ}, Iff (Continuous.{u1, u3} α γ (UniformSpace.toTopologicalSpace.{u1} α (PseudoEMetricSpace.toUniformSpace.{u1} α _inst_1)) _inst_4 (Function.comp.{succ u1, succ u2, succ u3} α β γ f (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) (fun (_x : IsometryEquiv.{u1, u2} α β _inst_1 _inst_2) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β _inst_1 _inst_2) h))) (Continuous.{u2, u3} β γ (UniformSpace.toTopologicalSpace.{u2} β (PseudoEMetricSpace.toUniformSpace.{u2} β _inst_2)) _inst_4 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u3}} [_inst_1 : PseudoEMetricSpace.{u2} α] [_inst_2 : PseudoEMetricSpace.{u3} β] {γ : Type.{u1}} [_inst_4 : TopologicalSpace.{u1} γ] (h : IsometryEquiv.{u2, u3} α β _inst_1 _inst_2) {f : β -> γ}, Iff (Continuous.{u2, u1} α γ (UniformSpace.toTopologicalSpace.{u2} α (PseudoEMetricSpace.toUniformSpace.{u2} α _inst_1)) _inst_4 (Function.comp.{succ u2, succ u3, succ u1} α β γ f (FunLike.coe.{max (succ u2) (succ u3), succ u2, succ u3} (IsometryEquiv.{u2, u3} α β _inst_1 _inst_2) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u2) (succ u3), succ u2, succ u3} (IsometryEquiv.{u2, u3} α β _inst_1 _inst_2) α β (EquivLike.toEmbeddingLike.{max (succ u2) (succ u3), succ u2, succ u3} (IsometryEquiv.{u2, u3} α β _inst_1 _inst_2) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u3} α β _inst_1 _inst_2))) h))) (Continuous.{u3, u1} β γ (UniformSpace.toTopologicalSpace.{u3} β (PseudoEMetricSpace.toUniformSpace.{u3} β _inst_2)) _inst_4 f)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.comp_continuous_iff' IsometryEquiv.comp_continuous_iff'ₓ'. -/
@[simp]
theorem comp_continuous_iff' {γ} [TopologicalSpace γ] (h : α ≃ᵢ β) {f : β → γ} :
    Continuous (f ∘ h) ↔ Continuous f :=
  h.toHomeomorph.comp_continuous_iff'
#align isometry_equiv.comp_continuous_iff' IsometryEquiv.comp_continuous_iff'

/-- The group of isometries. -/
instance : Group (α ≃ᵢ α) where
  one := IsometryEquiv.refl _
  mul e₁ e₂ := e₂.trans e₁
  inv := IsometryEquiv.symm
  mul_assoc e₁ e₂ e₃ := rfl
  one_mul e := ext fun _ => rfl
  mul_one e := ext fun _ => rfl
  mul_left_inv e := ext e.symm_apply_apply

/- warning: isometry_equiv.coe_one -> IsometryEquiv.coe_one is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PseudoEMetricSpace.{u1} α], Eq.{succ u1} (α -> α) (coeFn.{succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (fun (_x : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) => α -> α) (IsometryEquiv.hasCoeToFun.{u1, u1} α α _inst_1 _inst_1) (OfNat.ofNat.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) 1 (OfNat.mk.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) 1 (One.one.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (MulOneClass.toHasOne.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Monoid.toMulOneClass.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (DivInvMonoid.toMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Group.toDivInvMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.group.{u1} α _inst_1))))))))) (id.{succ u1} α)
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PseudoEMetricSpace.{u1} α], Eq.{succ u1} (forall (ᾰ : α), (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) ᾰ) (FunLike.coe.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (EquivLike.toEmbeddingLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u1} α α _inst_1 _inst_1))) (OfNat.ofNat.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) 1 (One.toOfNat1.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (InvOneClass.toOne.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (DivInvOneMonoid.toInvOneClass.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (DivisionMonoid.toDivInvOneMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Group.toDivisionMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.instGroupIsometryEquiv.{u1} α _inst_1)))))))) (id.{succ u1} α)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.coe_one IsometryEquiv.coe_oneₓ'. -/
@[simp]
theorem coe_one : ⇑(1 : α ≃ᵢ α) = id :=
  rfl
#align isometry_equiv.coe_one IsometryEquiv.coe_one

/- warning: isometry_equiv.coe_mul -> IsometryEquiv.coe_mul is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PseudoEMetricSpace.{u1} α] (e₁ : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (e₂ : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1), Eq.{succ u1} (α -> α) (coeFn.{succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (fun (_x : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) => α -> α) (IsometryEquiv.hasCoeToFun.{u1, u1} α α _inst_1 _inst_1) (HMul.hMul.{u1, u1, u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (instHMul.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (MulOneClass.toHasMul.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Monoid.toMulOneClass.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (DivInvMonoid.toMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Group.toDivInvMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.group.{u1} α _inst_1)))))) e₁ e₂)) (Function.comp.{succ u1, succ u1, succ u1} α α α (coeFn.{succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (fun (_x : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) => α -> α) (IsometryEquiv.hasCoeToFun.{u1, u1} α α _inst_1 _inst_1) e₁) (coeFn.{succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (fun (_x : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) => α -> α) (IsometryEquiv.hasCoeToFun.{u1, u1} α α _inst_1 _inst_1) e₂))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PseudoEMetricSpace.{u1} α] (e₁ : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (e₂ : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1), Eq.{succ u1} (forall (ᾰ : α), (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) ᾰ) (FunLike.coe.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (EquivLike.toEmbeddingLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u1} α α _inst_1 _inst_1))) (HMul.hMul.{u1, u1, u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (instHMul.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (MulOneClass.toMul.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Monoid.toMulOneClass.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (DivInvMonoid.toMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Group.toDivInvMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.instGroupIsometryEquiv.{u1} α _inst_1)))))) e₁ e₂)) (Function.comp.{succ u1, succ u1, succ u1} α α α (FunLike.coe.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (EquivLike.toEmbeddingLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u1} α α _inst_1 _inst_1))) e₁) (FunLike.coe.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (EquivLike.toEmbeddingLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u1} α α _inst_1 _inst_1))) e₂))
Case conversion may be inaccurate. Consider using '#align isometry_equiv.coe_mul IsometryEquiv.coe_mulₓ'. -/
@[simp]
theorem coe_mul (e₁ e₂ : α ≃ᵢ α) : ⇑(e₁ * e₂) = e₁ ∘ e₂ :=
  rfl
#align isometry_equiv.coe_mul IsometryEquiv.coe_mul

/- warning: isometry_equiv.mul_apply -> IsometryEquiv.mul_apply is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PseudoEMetricSpace.{u1} α] (e₁ : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (e₂ : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (x : α), Eq.{succ u1} α (coeFn.{succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (fun (_x : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) => α -> α) (IsometryEquiv.hasCoeToFun.{u1, u1} α α _inst_1 _inst_1) (HMul.hMul.{u1, u1, u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (instHMul.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (MulOneClass.toHasMul.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Monoid.toMulOneClass.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (DivInvMonoid.toMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Group.toDivInvMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.group.{u1} α _inst_1)))))) e₁ e₂) x) (coeFn.{succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (fun (_x : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) => α -> α) (IsometryEquiv.hasCoeToFun.{u1, u1} α α _inst_1 _inst_1) e₁ (coeFn.{succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (fun (_x : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) => α -> α) (IsometryEquiv.hasCoeToFun.{u1, u1} α α _inst_1 _inst_1) e₂ x))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PseudoEMetricSpace.{u1} α] (e₁ : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (e₂ : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (x : α), Eq.{succ u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) x) (FunLike.coe.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (EquivLike.toEmbeddingLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u1} α α _inst_1 _inst_1))) (HMul.hMul.{u1, u1, u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (instHMul.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (MulOneClass.toMul.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Monoid.toMulOneClass.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (DivInvMonoid.toMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Group.toDivInvMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.instGroupIsometryEquiv.{u1} α _inst_1)))))) e₁ e₂) x) (FunLike.coe.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (EquivLike.toEmbeddingLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u1} α α _inst_1 _inst_1))) e₁ (FunLike.coe.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (EquivLike.toEmbeddingLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u1} α α _inst_1 _inst_1))) e₂ x))
Case conversion may be inaccurate. Consider using '#align isometry_equiv.mul_apply IsometryEquiv.mul_applyₓ'. -/
theorem mul_apply (e₁ e₂ : α ≃ᵢ α) (x : α) : (e₁ * e₂) x = e₁ (e₂ x) :=
  rfl
#align isometry_equiv.mul_apply IsometryEquiv.mul_apply

/- warning: isometry_equiv.inv_apply_self -> IsometryEquiv.inv_apply_self is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PseudoEMetricSpace.{u1} α] (e : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (x : α), Eq.{succ u1} α (coeFn.{succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (fun (_x : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) => α -> α) (IsometryEquiv.hasCoeToFun.{u1, u1} α α _inst_1 _inst_1) (Inv.inv.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (DivInvMonoid.toHasInv.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Group.toDivInvMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.group.{u1} α _inst_1))) e) (coeFn.{succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (fun (_x : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) => α -> α) (IsometryEquiv.hasCoeToFun.{u1, u1} α α _inst_1 _inst_1) e x)) x
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PseudoEMetricSpace.{u1} α] (e : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (x : α), Eq.{succ u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) (FunLike.coe.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α (fun (a : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) a) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (EquivLike.toEmbeddingLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u1} α α _inst_1 _inst_1))) e x)) (FunLike.coe.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (EquivLike.toEmbeddingLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u1} α α _inst_1 _inst_1))) (Inv.inv.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (InvOneClass.toInv.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (DivInvOneMonoid.toInvOneClass.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (DivisionMonoid.toDivInvOneMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Group.toDivisionMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.instGroupIsometryEquiv.{u1} α _inst_1))))) e) (FunLike.coe.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (EquivLike.toEmbeddingLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u1} α α _inst_1 _inst_1))) e x)) x
Case conversion may be inaccurate. Consider using '#align isometry_equiv.inv_apply_self IsometryEquiv.inv_apply_selfₓ'. -/
@[simp]
theorem inv_apply_self (e : α ≃ᵢ α) (x : α) : e⁻¹ (e x) = x :=
  e.symm_apply_apply x
#align isometry_equiv.inv_apply_self IsometryEquiv.inv_apply_self

/- warning: isometry_equiv.apply_inv_self -> IsometryEquiv.apply_inv_self is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PseudoEMetricSpace.{u1} α] (e : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (x : α), Eq.{succ u1} α (coeFn.{succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (fun (_x : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) => α -> α) (IsometryEquiv.hasCoeToFun.{u1, u1} α α _inst_1 _inst_1) e (coeFn.{succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (fun (_x : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) => α -> α) (IsometryEquiv.hasCoeToFun.{u1, u1} α α _inst_1 _inst_1) (Inv.inv.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (DivInvMonoid.toHasInv.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Group.toDivInvMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.group.{u1} α _inst_1))) e) x)) x
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PseudoEMetricSpace.{u1} α] (e : IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (x : α), Eq.{succ u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) (FunLike.coe.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α (fun (a : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) a) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (EquivLike.toEmbeddingLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u1} α α _inst_1 _inst_1))) (Inv.inv.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (InvOneClass.toInv.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (DivInvOneMonoid.toInvOneClass.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (DivisionMonoid.toDivInvOneMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Group.toDivisionMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.instGroupIsometryEquiv.{u1} α _inst_1))))) e) x)) (FunLike.coe.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (EquivLike.toEmbeddingLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u1} α α _inst_1 _inst_1))) e (FunLike.coe.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => α) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (EquivLike.toEmbeddingLike.{succ u1, succ u1, succ u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) α α (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u1} α α _inst_1 _inst_1))) (Inv.inv.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (InvOneClass.toInv.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (DivInvOneMonoid.toInvOneClass.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (DivisionMonoid.toDivInvOneMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (Group.toDivisionMonoid.{u1} (IsometryEquiv.{u1, u1} α α _inst_1 _inst_1) (IsometryEquiv.instGroupIsometryEquiv.{u1} α _inst_1))))) e) x)) x
Case conversion may be inaccurate. Consider using '#align isometry_equiv.apply_inv_self IsometryEquiv.apply_inv_selfₓ'. -/
@[simp]
theorem apply_inv_self (e : α ≃ᵢ α) (x : α) : e (e⁻¹ x) = x :=
  e.apply_symm_apply x
#align isometry_equiv.apply_inv_self IsometryEquiv.apply_inv_self

#print IsometryEquiv.completeSpace /-
protected theorem completeSpace [CompleteSpace β] (e : α ≃ᵢ β) : CompleteSpace α :=
  completeSpace_of_isComplete_univ <|
    isComplete_of_complete_image e.Isometry.UniformInducing <| by
      rwa [Set.image_univ, IsometryEquiv.range_eq_univ, ← completeSpace_iff_isComplete_univ]
#align isometry_equiv.complete_space IsometryEquiv.completeSpace
-/

#print IsometryEquiv.completeSpace_iff /-
theorem completeSpace_iff (e : α ≃ᵢ β) : CompleteSpace α ↔ CompleteSpace β :=
  by
  constructor <;> intro H
  exacts[e.symm.complete_space, e.complete_space]
#align isometry_equiv.complete_space_iff IsometryEquiv.completeSpace_iff
-/

variable (ι α)

/-- `equiv.fun_unique` as an `isometry_equiv`. -/
@[simps]
def funUnique [Unique ι] [Fintype ι] : (ι → α) ≃ᵢ α
    where
  toEquiv := Equiv.funUnique ι α
  isometry_toFun x hx := by simp [edist_pi_def, Finset.univ_unique, Finset.sup_singleton]
#align isometry_equiv.fun_unique IsometryEquiv.funUnique

/-- `pi_fin_two_equiv` as an `isometry_equiv`. -/
@[simps]
def piFinTwo (α : Fin 2 → Type _) [∀ i, PseudoEMetricSpace (α i)] : (∀ i, α i) ≃ᵢ α 0 × α 1
    where
  toEquiv := piFinTwoEquiv α
  isometry_toFun x hx := by simp [edist_pi_def, Fin.univ_succ, Prod.edist_eq]
#align isometry_equiv.pi_fin_two IsometryEquiv.piFinTwo

end PseudoEMetricSpace

section PseudoMetricSpace

variable [PseudoMetricSpace α] [PseudoMetricSpace β] (h : α ≃ᵢ β)

#print IsometryEquiv.diam_image /-
@[simp]
theorem diam_image (s : Set α) : Metric.diam (h '' s) = Metric.diam s :=
  h.Isometry.diam_image s
#align isometry_equiv.diam_image IsometryEquiv.diam_image
-/

#print IsometryEquiv.diam_preimage /-
@[simp]
theorem diam_preimage (s : Set β) : Metric.diam (h ⁻¹' s) = Metric.diam s := by
  rw [← image_symm, diam_image]
#align isometry_equiv.diam_preimage IsometryEquiv.diam_preimage
-/

#print IsometryEquiv.diam_univ /-
theorem diam_univ : Metric.diam (univ : Set α) = Metric.diam (univ : Set β) :=
  congr_arg ENNReal.toReal h.ediam_univ
#align isometry_equiv.diam_univ IsometryEquiv.diam_univ
-/

/- warning: isometry_equiv.preimage_ball -> IsometryEquiv.preimage_ball is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoMetricSpace.{u1} α] [_inst_2 : PseudoMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (x : β) (r : Real), Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (fun (_x : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) h) (Metric.ball.{u2} β _inst_2 x r)) (Metric.ball.{u1} α _inst_1 (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (IsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) (fun (_x : IsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) => β -> α) (IsometryEquiv.hasCoeToFun.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) (IsometryEquiv.symm.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) h) x) r)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoMetricSpace.{u1} α] [_inst_2 : PseudoMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (x : β) (r : Real), Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)))) h) (Metric.ball.{u2} β _inst_2 x r)) (Metric.ball.{u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) x) _inst_1 (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)))) (IsometryEquiv.symm.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) h) x) r)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.preimage_ball IsometryEquiv.preimage_ballₓ'. -/
@[simp]
theorem preimage_ball (h : α ≃ᵢ β) (x : β) (r : ℝ) :
    h ⁻¹' Metric.ball x r = Metric.ball (h.symm x) r := by
  rw [← h.isometry.preimage_ball (h.symm x) r, h.apply_symm_apply]
#align isometry_equiv.preimage_ball IsometryEquiv.preimage_ball

/- warning: isometry_equiv.preimage_sphere -> IsometryEquiv.preimage_sphere is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoMetricSpace.{u1} α] [_inst_2 : PseudoMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (x : β) (r : Real), Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (fun (_x : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) h) (Metric.sphere.{u2} β _inst_2 x r)) (Metric.sphere.{u1} α _inst_1 (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (IsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) (fun (_x : IsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) => β -> α) (IsometryEquiv.hasCoeToFun.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) (IsometryEquiv.symm.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) h) x) r)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoMetricSpace.{u1} α] [_inst_2 : PseudoMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (x : β) (r : Real), Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)))) h) (Metric.sphere.{u2} β _inst_2 x r)) (Metric.sphere.{u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) x) _inst_1 (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)))) (IsometryEquiv.symm.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) h) x) r)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.preimage_sphere IsometryEquiv.preimage_sphereₓ'. -/
@[simp]
theorem preimage_sphere (h : α ≃ᵢ β) (x : β) (r : ℝ) :
    h ⁻¹' Metric.sphere x r = Metric.sphere (h.symm x) r := by
  rw [← h.isometry.preimage_sphere (h.symm x) r, h.apply_symm_apply]
#align isometry_equiv.preimage_sphere IsometryEquiv.preimage_sphere

/- warning: isometry_equiv.preimage_closed_ball -> IsometryEquiv.preimage_closedBall is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoMetricSpace.{u1} α] [_inst_2 : PseudoMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (x : β) (r : Real), Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (fun (_x : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) h) (Metric.closedBall.{u2} β _inst_2 x r)) (Metric.closedBall.{u1} α _inst_1 (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (IsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) (fun (_x : IsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) => β -> α) (IsometryEquiv.hasCoeToFun.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) (IsometryEquiv.symm.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) h) x) r)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoMetricSpace.{u1} α] [_inst_2 : PseudoMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (x : β) (r : Real), Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)))) h) (Metric.closedBall.{u2} β _inst_2 x r)) (Metric.closedBall.{u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) x) _inst_1 (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) β α (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (IsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)) β α (IsometryEquiv.instEquivLikeIsometryEquiv.{u2, u1} β α (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1)))) (IsometryEquiv.symm.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2) h) x) r)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.preimage_closed_ball IsometryEquiv.preimage_closedBallₓ'. -/
@[simp]
theorem preimage_closedBall (h : α ≃ᵢ β) (x : β) (r : ℝ) :
    h ⁻¹' Metric.closedBall x r = Metric.closedBall (h.symm x) r := by
  rw [← h.isometry.preimage_closed_ball (h.symm x) r, h.apply_symm_apply]
#align isometry_equiv.preimage_closed_ball IsometryEquiv.preimage_closedBall

/- warning: isometry_equiv.image_ball -> IsometryEquiv.image_ball is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoMetricSpace.{u1} α] [_inst_2 : PseudoMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (x : α) (r : Real), Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (fun (_x : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) h) (Metric.ball.{u1} α _inst_1 x r)) (Metric.ball.{u2} β _inst_2 (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (fun (_x : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) h x) r)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoMetricSpace.{u1} α] [_inst_2 : PseudoMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (x : α) (r : Real), Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)))) h) (Metric.ball.{u1} α _inst_1 x r)) (Metric.ball.{u2} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) x) _inst_2 (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)))) h x) r)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.image_ball IsometryEquiv.image_ballₓ'. -/
@[simp]
theorem image_ball (h : α ≃ᵢ β) (x : α) (r : ℝ) : h '' Metric.ball x r = Metric.ball (h x) r := by
  rw [← h.preimage_symm, h.symm.preimage_ball, symm_symm]
#align isometry_equiv.image_ball IsometryEquiv.image_ball

/- warning: isometry_equiv.image_sphere -> IsometryEquiv.image_sphere is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoMetricSpace.{u1} α] [_inst_2 : PseudoMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (x : α) (r : Real), Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (fun (_x : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) h) (Metric.sphere.{u1} α _inst_1 x r)) (Metric.sphere.{u2} β _inst_2 (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (fun (_x : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) h x) r)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoMetricSpace.{u1} α] [_inst_2 : PseudoMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (x : α) (r : Real), Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)))) h) (Metric.sphere.{u1} α _inst_1 x r)) (Metric.sphere.{u2} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) x) _inst_2 (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)))) h x) r)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.image_sphere IsometryEquiv.image_sphereₓ'. -/
@[simp]
theorem image_sphere (h : α ≃ᵢ β) (x : α) (r : ℝ) :
    h '' Metric.sphere x r = Metric.sphere (h x) r := by
  rw [← h.preimage_symm, h.symm.preimage_sphere, symm_symm]
#align isometry_equiv.image_sphere IsometryEquiv.image_sphere

/- warning: isometry_equiv.image_closed_ball -> IsometryEquiv.image_closedBall is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoMetricSpace.{u1} α] [_inst_2 : PseudoMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (x : α) (r : Real), Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (fun (_x : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) h) (Metric.closedBall.{u1} α _inst_1 x r)) (Metric.closedBall.{u2} β _inst_2 (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (fun (_x : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) => α -> β) (IsometryEquiv.hasCoeToFun.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) h x) r)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PseudoMetricSpace.{u1} α] [_inst_2 : PseudoMetricSpace.{u2} β] (h : IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) (x : α) (r : Real), Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)))) h) (Metric.closedBall.{u1} α _inst_1 x r)) (Metric.closedBall.{u2} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) x) _inst_2 (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (IsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)) α β (IsometryEquiv.instEquivLikeIsometryEquiv.{u1, u2} α β (PseudoMetricSpace.toPseudoEMetricSpace.{u1} α _inst_1) (PseudoMetricSpace.toPseudoEMetricSpace.{u2} β _inst_2)))) h x) r)
Case conversion may be inaccurate. Consider using '#align isometry_equiv.image_closed_ball IsometryEquiv.image_closedBallₓ'. -/
@[simp]
theorem image_closedBall (h : α ≃ᵢ β) (x : α) (r : ℝ) :
    h '' Metric.closedBall x r = Metric.closedBall (h x) r := by
  rw [← h.preimage_symm, h.symm.preimage_closed_ball, symm_symm]
#align isometry_equiv.image_closed_ball IsometryEquiv.image_closedBall

end PseudoMetricSpace

end IsometryEquiv

#print Isometry.isometryEquivOnRange /-
/-- An isometry induces an isometric isomorphism between the source space and the
range of the isometry. -/
@[simps (config := { simpRhs := true }) toEquiv apply]
def Isometry.isometryEquivOnRange [EMetricSpace α] [PseudoEMetricSpace β] {f : α → β}
    (h : Isometry f) : α ≃ᵢ range f
    where
  isometry_toFun x y := by simpa [Subtype.edist_eq] using h x y
  toEquiv := Equiv.ofInjective f h.Injective
#align isometry.isometry_equiv_on_range Isometry.isometryEquivOnRange
-/

