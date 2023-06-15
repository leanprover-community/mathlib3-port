/-
Copyright (c) 2023 Paul Reichert. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Paul Reichert, Yaël Dillies

! This file was ported from Lean 3 source module analysis.convex.intrinsic
! leanprover-community/mathlib commit d07a9c875ed7139abfde6a333b2be205c5bd404e
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.AddTorsorBases

/-!
# Intrinsic frontier and interior

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the intrinsic frontier, interior and closure of a set in a normed additive torsor.
These are also known as relative frontier, interior, closure.

The intrinsic frontier/interior/closure of a set `s` is the frontier/interior/closure of `s`
considered as a set in its affine span.

The intrinsic interior is in general greater than the topological interior, the intrinsic frontier
in general less than the topological frontier, and the intrinsic closure in cases of interest the
same as the topological closure.

## Definitions

* `intrinsic_interior`: Intrinsic interior
* `intrinsic_frontier`: Intrinsic frontier
* `intrinsic_closure`: Intrinsic closure

## Results

The main results are:
* `affine_isometry.image_intrinsic_interior`/`affine_isometry.image_intrinsic_frontier`/
  `affine_isometry.image_intrinsic_closure`: Intrinsic interiors/frontiers/closures commute with
  taking the image under an affine isometry.
* `set.nonempty.intrinsic_interior`: The intrinsic interior of a nonempty convex set is nonempty.

## References

* Chapter 8 of [Barry Simon, *Convexity*][simon2011]
* Chapter 1 of [Rolf Schneider, *Convex Bodies: The Brunn-Minkowski theory*][schneider2013].

## TODO

* `is_closed s → is_extreme 𝕜 s (intrinsic_frontier 𝕜 s)`
* `x ∈ s → y ∈ intrinsic_interior 𝕜 s → open_segment 𝕜 x y ⊆ intrinsic_interior 𝕜 s`
-/


open AffineSubspace Set

open scoped Pointwise

variable {𝕜 V W Q P : Type _}

section AddTorsor

variable (𝕜) [Ring 𝕜] [AddCommGroup V] [Module 𝕜 V] [TopologicalSpace P] [AddTorsor V P]
  {s t : Set P} {x : P}

#print intrinsicInterior /-
/-- The intrinsic interior of a set is its interior considered as a set in its affine span. -/
def intrinsicInterior (s : Set P) : Set P :=
  coe '' interior (coe ⁻¹' s : Set <| affineSpan 𝕜 s)
#align intrinsic_interior intrinsicInterior
-/

#print intrinsicFrontier /-
/-- The intrinsic frontier of a set is its frontier considered as a set in its affine span. -/
def intrinsicFrontier (s : Set P) : Set P :=
  coe '' frontier (coe ⁻¹' s : Set <| affineSpan 𝕜 s)
#align intrinsic_frontier intrinsicFrontier
-/

#print intrinsicClosure /-
/-- The intrinsic closure of a set is its closure considered as a set in its affine span. -/
def intrinsicClosure (s : Set P) : Set P :=
  coe '' closure (coe ⁻¹' s : Set <| affineSpan 𝕜 s)
#align intrinsic_closure intrinsicClosure
-/

variable {𝕜}

#print mem_intrinsicInterior /-
@[simp]
theorem mem_intrinsicInterior :
    x ∈ intrinsicInterior 𝕜 s ↔ ∃ y, y ∈ interior (coe ⁻¹' s : Set <| affineSpan 𝕜 s) ∧ ↑y = x :=
  mem_image _ _ _
#align mem_intrinsic_interior mem_intrinsicInterior
-/

#print mem_intrinsicFrontier /-
@[simp]
theorem mem_intrinsicFrontier :
    x ∈ intrinsicFrontier 𝕜 s ↔ ∃ y, y ∈ frontier (coe ⁻¹' s : Set <| affineSpan 𝕜 s) ∧ ↑y = x :=
  mem_image _ _ _
#align mem_intrinsic_frontier mem_intrinsicFrontier
-/

#print mem_intrinsicClosure /-
@[simp]
theorem mem_intrinsicClosure :
    x ∈ intrinsicClosure 𝕜 s ↔ ∃ y, y ∈ closure (coe ⁻¹' s : Set <| affineSpan 𝕜 s) ∧ ↑y = x :=
  mem_image _ _ _
#align mem_intrinsic_closure mem_intrinsicClosure
-/

#print intrinsicInterior_subset /-
theorem intrinsicInterior_subset : intrinsicInterior 𝕜 s ⊆ s :=
  image_subset_iff.2 interior_subset
#align intrinsic_interior_subset intrinsicInterior_subset
-/

#print intrinsicFrontier_subset /-
theorem intrinsicFrontier_subset (hs : IsClosed s) : intrinsicFrontier 𝕜 s ⊆ s :=
  image_subset_iff.2 (hs.Preimage continuous_induced_dom).frontier_subset
#align intrinsic_frontier_subset intrinsicFrontier_subset
-/

#print intrinsicFrontier_subset_intrinsicClosure /-
theorem intrinsicFrontier_subset_intrinsicClosure : intrinsicFrontier 𝕜 s ⊆ intrinsicClosure 𝕜 s :=
  image_subset _ frontier_subset_closure
#align intrinsic_frontier_subset_intrinsic_closure intrinsicFrontier_subset_intrinsicClosure
-/

#print subset_intrinsicClosure /-
theorem subset_intrinsicClosure : s ⊆ intrinsicClosure 𝕜 s := fun x hx =>
  ⟨⟨x, subset_affineSpan _ _ hx⟩, subset_closure hx, rfl⟩
#align subset_intrinsic_closure subset_intrinsicClosure
-/

#print intrinsicInterior_empty /-
@[simp]
theorem intrinsicInterior_empty : intrinsicInterior 𝕜 (∅ : Set P) = ∅ := by simp [intrinsicInterior]
#align intrinsic_interior_empty intrinsicInterior_empty
-/

#print intrinsicFrontier_empty /-
@[simp]
theorem intrinsicFrontier_empty : intrinsicFrontier 𝕜 (∅ : Set P) = ∅ := by simp [intrinsicFrontier]
#align intrinsic_frontier_empty intrinsicFrontier_empty
-/

#print intrinsicClosure_empty /-
@[simp]
theorem intrinsicClosure_empty : intrinsicClosure 𝕜 (∅ : Set P) = ∅ := by simp [intrinsicClosure]
#align intrinsic_closure_empty intrinsicClosure_empty
-/

#print intrinsicClosure_nonempty /-
@[simp]
theorem intrinsicClosure_nonempty : (intrinsicClosure 𝕜 s).Nonempty ↔ s.Nonempty :=
  ⟨by simp_rw [nonempty_iff_ne_empty]; rintro h rfl; exact h intrinsicClosure_empty,
    Nonempty.mono subset_intrinsicClosure⟩
#align intrinsic_closure_nonempty intrinsicClosure_nonempty
-/

alias intrinsicClosure_nonempty ↔ Set.Nonempty.ofIntrinsicClosure Set.Nonempty.intrinsicClosure
#align set.nonempty.of_intrinsic_closure Set.Nonempty.ofIntrinsicClosure
#align set.nonempty.intrinsic_closure Set.Nonempty.intrinsicClosure

attribute [protected] Set.Nonempty.intrinsicClosure

#print intrinsicInterior_singleton /-
@[simp]
theorem intrinsicInterior_singleton (x : P) : intrinsicInterior 𝕜 ({x} : Set P) = {x} := by
  simpa only [intrinsicInterior, preimage_coe_affine_span_singleton, interior_univ, image_univ,
    Subtype.range_coe] using coe_affine_span_singleton _ _ _
#align intrinsic_interior_singleton intrinsicInterior_singleton
-/

#print intrinsicFrontier_singleton /-
@[simp]
theorem intrinsicFrontier_singleton (x : P) : intrinsicFrontier 𝕜 ({x} : Set P) = ∅ := by
  rw [intrinsicFrontier, preimage_coe_affine_span_singleton, frontier_univ, image_empty]
#align intrinsic_frontier_singleton intrinsicFrontier_singleton
-/

#print intrinsicClosure_singleton /-
@[simp]
theorem intrinsicClosure_singleton (x : P) : intrinsicClosure 𝕜 ({x} : Set P) = {x} := by
  simpa only [intrinsicClosure, preimage_coe_affine_span_singleton, closure_univ, image_univ,
    Subtype.range_coe] using coe_affine_span_singleton _ _ _
#align intrinsic_closure_singleton intrinsicClosure_singleton
-/

/-!
Note that neither `intrinsic_interior` nor `intrinsic_frontier` is monotone.
-/


#print intrinsicClosure_mono /-
theorem intrinsicClosure_mono (h : s ⊆ t) : intrinsicClosure 𝕜 s ⊆ intrinsicClosure 𝕜 t :=
  by
  refine'
    image_subset_iff.2 fun x hx =>
      ⟨Set.inclusion (affineSpan_mono _ h) x,
        (continuous_inclusion _).closure_preimage_subset _ <| closure_mono _ hx, rfl⟩
  exact fun y hy => h hy
#align intrinsic_closure_mono intrinsicClosure_mono
-/

#print interior_subset_intrinsicInterior /-
theorem interior_subset_intrinsicInterior : interior s ⊆ intrinsicInterior 𝕜 s := fun x hx =>
  ⟨⟨x, subset_affineSpan _ _ <| interior_subset hx⟩,
    preimage_interior_subset_interior_preimage continuous_subtype_val hx, rfl⟩
#align interior_subset_intrinsic_interior interior_subset_intrinsicInterior
-/

#print intrinsicClosure_subset_closure /-
theorem intrinsicClosure_subset_closure : intrinsicClosure 𝕜 s ⊆ closure s :=
  image_subset_iff.2 <| continuous_subtype_val.closure_preimage_subset _
#align intrinsic_closure_subset_closure intrinsicClosure_subset_closure
-/

#print intrinsicFrontier_subset_frontier /-
theorem intrinsicFrontier_subset_frontier : intrinsicFrontier 𝕜 s ⊆ frontier s :=
  image_subset_iff.2 <| continuous_subtype_val.frontier_preimage_subset _
#align intrinsic_frontier_subset_frontier intrinsicFrontier_subset_frontier
-/

#print intrinsicClosure_subset_affineSpan /-
theorem intrinsicClosure_subset_affineSpan : intrinsicClosure 𝕜 s ⊆ affineSpan 𝕜 s :=
  (image_subset_range _ _).trans Subtype.range_coe.Subset
#align intrinsic_closure_subset_affine_span intrinsicClosure_subset_affineSpan
-/

#print intrinsicClosure_diff_intrinsicFrontier /-
@[simp]
theorem intrinsicClosure_diff_intrinsicFrontier (s : Set P) :
    intrinsicClosure 𝕜 s \ intrinsicFrontier 𝕜 s = intrinsicInterior 𝕜 s :=
  (image_diff Subtype.coe_injective _ _).symm.trans <| by
    rw [closure_diff_frontier, intrinsicInterior]
#align intrinsic_closure_diff_intrinsic_frontier intrinsicClosure_diff_intrinsicFrontier
-/

#print intrinsicClosure_diff_intrinsicInterior /-
@[simp]
theorem intrinsicClosure_diff_intrinsicInterior (s : Set P) :
    intrinsicClosure 𝕜 s \ intrinsicInterior 𝕜 s = intrinsicFrontier 𝕜 s :=
  (image_diff Subtype.coe_injective _ _).symm
#align intrinsic_closure_diff_intrinsic_interior intrinsicClosure_diff_intrinsicInterior
-/

#print intrinsicInterior_union_intrinsicFrontier /-
@[simp]
theorem intrinsicInterior_union_intrinsicFrontier (s : Set P) :
    intrinsicInterior 𝕜 s ∪ intrinsicFrontier 𝕜 s = intrinsicClosure 𝕜 s := by
  simp [intrinsicClosure, intrinsicInterior, intrinsicFrontier, closure_eq_interior_union_frontier,
    image_union]
#align intrinsic_interior_union_intrinsic_frontier intrinsicInterior_union_intrinsicFrontier
-/

#print intrinsicFrontier_union_intrinsicInterior /-
@[simp]
theorem intrinsicFrontier_union_intrinsicInterior (s : Set P) :
    intrinsicFrontier 𝕜 s ∪ intrinsicInterior 𝕜 s = intrinsicClosure 𝕜 s := by
  rw [union_comm, intrinsicInterior_union_intrinsicFrontier]
#align intrinsic_frontier_union_intrinsic_interior intrinsicFrontier_union_intrinsicInterior
-/

#print isClosed_intrinsicClosure /-
theorem isClosed_intrinsicClosure (hs : IsClosed (affineSpan 𝕜 s : Set P)) :
    IsClosed (intrinsicClosure 𝕜 s) :=
  (closedEmbedding_subtype_val hs).IsClosedMap _ isClosed_closure
#align is_closed_intrinsic_closure isClosed_intrinsicClosure
-/

#print isClosed_intrinsicFrontier /-
theorem isClosed_intrinsicFrontier (hs : IsClosed (affineSpan 𝕜 s : Set P)) :
    IsClosed (intrinsicFrontier 𝕜 s) :=
  (closedEmbedding_subtype_val hs).IsClosedMap _ isClosed_frontier
#align is_closed_intrinsic_frontier isClosed_intrinsicFrontier
-/

#print affineSpan_intrinsicClosure /-
@[simp]
theorem affineSpan_intrinsicClosure (s : Set P) :
    affineSpan 𝕜 (intrinsicClosure 𝕜 s) = affineSpan 𝕜 s :=
  (affineSpan_le.2 intrinsicClosure_subset_affineSpan).antisymm <|
    affineSpan_mono _ subset_intrinsicClosure
#align affine_span_intrinsic_closure affineSpan_intrinsicClosure
-/

#print IsClosed.intrinsicClosure /-
protected theorem IsClosed.intrinsicClosure (hs : IsClosed (coe ⁻¹' s : Set <| affineSpan 𝕜 s)) :
    intrinsicClosure 𝕜 s = s :=
  by
  rw [intrinsicClosure, hs.closure_eq, image_preimage_eq_of_subset]
  exact (subset_affineSpan _ _).trans subtype.range_coe.superset
#align is_closed.intrinsic_closure IsClosed.intrinsicClosure
-/

#print intrinsicClosure_idem /-
@[simp]
theorem intrinsicClosure_idem (s : Set P) :
    intrinsicClosure 𝕜 (intrinsicClosure 𝕜 s) = intrinsicClosure 𝕜 s :=
  by
  refine' IsClosed.intrinsicClosure _
  set t := affineSpan 𝕜 (intrinsicClosure 𝕜 s) with ht
  clear_value t
  obtain rfl := ht.trans (affineSpan_intrinsicClosure _)
  rw [intrinsicClosure, preimage_image_eq _ Subtype.coe_injective]
  exact isClosed_closure
#align intrinsic_closure_idem intrinsicClosure_idem
-/

end AddTorsor

namespace AffineIsometry

variable [NormedField 𝕜] [SeminormedAddCommGroup V] [SeminormedAddCommGroup W] [NormedSpace 𝕜 V]
  [NormedSpace 𝕜 W] [MetricSpace P] [PseudoMetricSpace Q] [NormedAddTorsor V P]
  [NormedAddTorsor W Q]

attribute [local instance, local nolint fails_quickly] AffineSubspace.toNormedAddTorsor
  AffineSubspace.nonempty_map

#print AffineIsometry.image_intrinsicInterior /-
@[simp]
theorem image_intrinsicInterior (φ : P →ᵃⁱ[𝕜] Q) (s : Set P) :
    intrinsicInterior 𝕜 (φ '' s) = φ '' intrinsicInterior 𝕜 s :=
  by
  obtain rfl | hs := s.eq_empty_or_nonempty
  · simp only [intrinsicInterior_empty, image_empty]
  haveI : Nonempty s := hs.to_subtype
  let f := ((affineSpan 𝕜 s).isometryEquivMap φ).toHomeomorph
  have : φ.to_affine_map ∘ coe ∘ f.symm = coe := funext isometry_equiv_map.apply_symm_apply
  rw [intrinsicInterior, intrinsicInterior, ← φ.coe_to_affine_map, ← map_span φ.to_affine_map s, ←
    this, ← Function.comp.assoc, image_comp, image_comp, f.symm.image_interior, f.image_symm, ←
    preimage_comp, Function.comp.assoc, f.symm_comp_self, AffineIsometry.coe_toAffineMap,
    Function.comp.right_id, preimage_comp, φ.injective.preimage_image]
#align affine_isometry.image_intrinsic_interior AffineIsometry.image_intrinsicInterior
-/

#print AffineIsometry.image_intrinsicFrontier /-
@[simp]
theorem image_intrinsicFrontier (φ : P →ᵃⁱ[𝕜] Q) (s : Set P) :
    intrinsicFrontier 𝕜 (φ '' s) = φ '' intrinsicFrontier 𝕜 s :=
  by
  obtain rfl | hs := s.eq_empty_or_nonempty
  · simp
  haveI : Nonempty s := hs.to_subtype
  let f := ((affineSpan 𝕜 s).isometryEquivMap φ).toHomeomorph
  have : φ.to_affine_map ∘ coe ∘ f.symm = coe := funext isometry_equiv_map.apply_symm_apply
  rw [intrinsicFrontier, intrinsicFrontier, ← φ.coe_to_affine_map, ← map_span φ.to_affine_map s, ←
    this, ← Function.comp.assoc, image_comp, image_comp, f.symm.image_frontier, f.image_symm, ←
    preimage_comp, Function.comp.assoc, f.symm_comp_self, AffineIsometry.coe_toAffineMap,
    Function.comp.right_id, preimage_comp, φ.injective.preimage_image]
#align affine_isometry.image_intrinsic_frontier AffineIsometry.image_intrinsicFrontier
-/

#print AffineIsometry.image_intrinsicClosure /-
@[simp]
theorem image_intrinsicClosure (φ : P →ᵃⁱ[𝕜] Q) (s : Set P) :
    intrinsicClosure 𝕜 (φ '' s) = φ '' intrinsicClosure 𝕜 s :=
  by
  obtain rfl | hs := s.eq_empty_or_nonempty
  · simp
  haveI : Nonempty s := hs.to_subtype
  let f := ((affineSpan 𝕜 s).isometryEquivMap φ).toHomeomorph
  have : φ.to_affine_map ∘ coe ∘ f.symm = coe := funext isometry_equiv_map.apply_symm_apply
  rw [intrinsicClosure, intrinsicClosure, ← φ.coe_to_affine_map, ← map_span φ.to_affine_map s, ←
    this, ← Function.comp.assoc, image_comp, image_comp, f.symm.image_closure, f.image_symm, ←
    preimage_comp, Function.comp.assoc, f.symm_comp_self, AffineIsometry.coe_toAffineMap,
    Function.comp.right_id, preimage_comp, φ.injective.preimage_image]
#align affine_isometry.image_intrinsic_closure AffineIsometry.image_intrinsicClosure
-/

end AffineIsometry

section NormedAddTorsor

variable (𝕜) [NontriviallyNormedField 𝕜] [CompleteSpace 𝕜] [NormedAddCommGroup V] [NormedSpace 𝕜 V]
  [FiniteDimensional 𝕜 V] [MetricSpace P] [NormedAddTorsor V P] (s : Set P)

#print intrinsicClosure_eq_closure /-
@[simp]
theorem intrinsicClosure_eq_closure : intrinsicClosure 𝕜 s = closure s :=
  by
  ext x
  simp only [mem_closure_iff, mem_intrinsicClosure]
  refine' ⟨_, fun h => ⟨⟨x, _⟩, _, Subtype.coe_mk _ _⟩⟩
  · rintro ⟨x, h, rfl⟩ t ht hx
    obtain ⟨z, hz₁, hz₂⟩ := h _ (continuous_induced_dom.is_open_preimage t ht) hx
    exact ⟨z, hz₁, hz₂⟩
  · by_contra hc
    obtain ⟨z, hz₁, hz₂⟩ := h _ (affineSpan 𝕜 s).closed_of_finiteDimensional.isOpen_compl hc
    exact hz₁ (subset_affineSpan 𝕜 s hz₂)
  · rintro _ ⟨t, ht, rfl⟩ hx
    obtain ⟨y, hyt, hys⟩ := h _ ht hx
    exact ⟨⟨_, subset_affineSpan 𝕜 s hys⟩, hyt, hys⟩
#align intrinsic_closure_eq_closure intrinsicClosure_eq_closure
-/

variable {𝕜}

#print closure_diff_intrinsicInterior /-
@[simp]
theorem closure_diff_intrinsicInterior (s : Set P) :
    closure s \ intrinsicInterior 𝕜 s = intrinsicFrontier 𝕜 s :=
  intrinsicClosure_eq_closure 𝕜 s ▸ intrinsicClosure_diff_intrinsicInterior s
#align closure_diff_intrinsic_interior closure_diff_intrinsicInterior
-/

#print closure_diff_intrinsicFrontier /-
@[simp]
theorem closure_diff_intrinsicFrontier (s : Set P) :
    closure s \ intrinsicFrontier 𝕜 s = intrinsicInterior 𝕜 s :=
  intrinsicClosure_eq_closure 𝕜 s ▸ intrinsicClosure_diff_intrinsicFrontier s
#align closure_diff_intrinsic_frontier closure_diff_intrinsicFrontier
-/

end NormedAddTorsor

private theorem aux {α β : Type _} [TopologicalSpace α] [TopologicalSpace β] (φ : α ≃ₜ β)
    (s : Set β) : (interior s).Nonempty ↔ (interior (φ ⁻¹' s)).Nonempty := by
  rw [← φ.image_symm, ← φ.symm.image_interior, nonempty_image_iff]

variable [NormedAddCommGroup V] [NormedSpace ℝ V] [FiniteDimensional ℝ V] {s : Set V}

#print Set.Nonempty.intrinsicInterior /-
/-- The intrinsic interior of a nonempty convex set is nonempty. -/
protected theorem Set.Nonempty.intrinsicInterior (hscv : Convex ℝ s) (hsne : s.Nonempty) :
    (intrinsicInterior ℝ s).Nonempty :=
  by
  haveI := hsne.coe_sort
  obtain ⟨p, hp⟩ := hsne
  let p' : affineSpan ℝ s := ⟨p, subset_affineSpan _ _ hp⟩
  rw [intrinsicInterior, nonempty_image_iff,
    aux (AffineIsometryEquiv.constVSub ℝ p').symm.toHomeomorph,
    Convex.interior_nonempty_iff_affineSpan_eq_top, AffineIsometryEquiv.coe_toHomeomorph, ←
    AffineIsometryEquiv.coe_toAffineEquiv, ← comap_span, affineSpan_coe_preimage_eq_top, comap_top]
  exact
    hscv.affine_preimage
      ((affineSpan ℝ s).Subtype.comp
        (AffineIsometryEquiv.constVSub ℝ p').symm.toAffineEquiv.toAffineMap)
#align set.nonempty.intrinsic_interior Set.Nonempty.intrinsicInterior
-/

#print intrinsicInterior_nonempty /-
theorem intrinsicInterior_nonempty (hs : Convex ℝ s) :
    (intrinsicInterior ℝ s).Nonempty ↔ s.Nonempty :=
  ⟨by simp_rw [nonempty_iff_ne_empty]; rintro h rfl; exact h intrinsicInterior_empty,
    Set.Nonempty.intrinsicInterior hs⟩
#align intrinsic_interior_nonempty intrinsicInterior_nonempty
-/

