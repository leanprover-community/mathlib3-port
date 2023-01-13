/-
Copyright (c) 2022 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module dynamics.ergodic.ergodic
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Dynamics.Ergodic.MeasurePreserving

/-!
# Ergodic maps and measures

Let `f : α → α` be measure preserving with respect to a measure `μ`. We say `f` is ergodic with
respect to `μ` (or `μ` is ergodic with respect to `f`) if the only measurable sets `s` such that
`f⁻¹' s = s` are either almost empty or full.

In this file we define ergodic maps / measures together with quasi-ergodic maps / measures and
provide some basic API. Quasi-ergodicity is a weaker condition than ergodicity for which the measure
preserving condition is relaxed to quasi measure preserving.

# Main definitions:

 * `pre_ergodic`: the ergodicity condition without the measure preserving condition. This exists
   to share code between the `ergodic` and `quasi_ergodic` definitions.
 * `ergodic`: the definition of ergodic maps / measures.
 * `quasi_ergodic`: the definition of quasi ergodic maps / measures.
 * `ergodic.quasi_ergodic`: an ergodic map / measure is quasi ergodic.
 * `quasi_ergodic.ae_empty_or_univ'`: when the map is quasi measure preserving, one may relax the
   strict invariance condition to almost invariance in the ergodicity condition.

-/


open Set Function Filter MeasureTheory MeasureTheory.Measure

open Ennreal

variable {α : Type _} {m : MeasurableSpace α} (f : α → α) {s : Set α}

include m

/-- A map `f : α → α` is said to be pre-ergodic with respect to a measure `μ` if any measurable
strictly invariant set is either almost empty or full. -/
structure PreErgodic (μ : Measure α := by exact MeasureTheory.MeasureSpace.volume) : Prop where
  ae_empty_or_univ : ∀ ⦃s⦄, MeasurableSet s → f ⁻¹' s = s → s =ᵐ[μ] (∅ : Set α) ∨ s =ᵐ[μ] univ
#align pre_ergodic PreErgodic

/-- A map `f : α → α` is said to be ergodic with respect to a measure `μ` if it is measure
preserving and pre-ergodic. -/
@[nolint has_nonempty_instance]
structure Ergodic (μ : Measure α := by exact MeasureTheory.MeasureSpace.volume) extends
  MeasurePreserving f μ μ, PreErgodic f μ : Prop
#align ergodic Ergodic

/-- A map `f : α → α` is said to be quasi ergodic with respect to a measure `μ` if it is quasi
measure preserving and pre-ergodic. -/
@[nolint has_nonempty_instance]
structure QuasiErgodic (μ : Measure α := by exact MeasureTheory.MeasureSpace.volume) extends
  QuasiMeasurePreserving f μ μ, PreErgodic f μ : Prop
#align quasi_ergodic QuasiErgodic

variable {f} {μ : Measure α}

namespace PreErgodic

theorem measure_self_or_compl_eq_zero (hf : PreErgodic f μ) (hs : MeasurableSet s)
    (hs' : f ⁻¹' s = s) : μ s = 0 ∨ μ (sᶜ) = 0 := by simpa using hf.ae_empty_or_univ hs hs'
#align pre_ergodic.measure_self_or_compl_eq_zero PreErgodic.measure_self_or_compl_eq_zero

/-- On a probability space, the (pre)ergodicity condition is a zero one law. -/
theorem prob_eq_zero_or_one [IsProbabilityMeasure μ] (hf : PreErgodic f μ) (hs : MeasurableSet s)
    (hs' : f ⁻¹' s = s) : μ s = 0 ∨ μ s = 1 := by
  simpa [hs] using hf.measure_self_or_compl_eq_zero hs hs'
#align pre_ergodic.prob_eq_zero_or_one PreErgodic.prob_eq_zero_or_one

theorem ofIterate (n : ℕ) (hf : PreErgodic (f^[n]) μ) : PreErgodic f μ :=
  ⟨fun s hs hs' => hf.ae_empty_or_univ hs <| IsFixedPt.preimage_iterate hs' n⟩
#align pre_ergodic.of_iterate PreErgodic.ofIterate

end PreErgodic

namespace MeasureTheory.MeasurePreserving

variable {β : Type _} {m' : MeasurableSpace β} {μ' : Measure β} {s' : Set β} {g : α → β}

theorem preErgodicOfPreErgodicConjugate (hg : MeasurePreserving g μ μ') (hf : PreErgodic f μ)
    {f' : β → β} (h_comm : g ∘ f = f' ∘ g) : PreErgodic f' μ' :=
  ⟨by
    intro s hs₀ hs₁
    replace hs₁ : f ⁻¹' (g ⁻¹' s) = g ⁻¹' s; · rw [← preimage_comp, h_comm, preimage_comp, hs₁]
    cases' hf.ae_empty_or_univ (hg.measurable hs₀) hs₁ with hs₂ hs₂ <;> [left, right]
    · simpa only [ae_eq_empty, hg.measure_preimage hs₀] using hs₂
    · simpa only [ae_eq_univ, ← preimage_compl, hg.measure_preimage hs₀.compl] using hs₂⟩
#align
  measure_theory.measure_preserving.pre_ergodic_of_pre_ergodic_conjugate MeasureTheory.MeasurePreserving.preErgodicOfPreErgodicConjugate

theorem pre_ergodic_conjugate_iff {e : α ≃ᵐ β} (h : MeasurePreserving e μ μ') :
    PreErgodic (e ∘ f ∘ e.symm) μ' ↔ PreErgodic f μ :=
  by
  refine'
    ⟨fun hf => pre_ergodic_of_pre_ergodic_conjugate (h.symm e) hf _, fun hf =>
      pre_ergodic_of_pre_ergodic_conjugate h hf _⟩
  · change (e.symm ∘ e) ∘ f ∘ e.symm = f ∘ e.symm
    rw [MeasurableEquiv.symm_comp_self, comp.left_id]
  · change e ∘ f = e ∘ f ∘ e.symm ∘ e
    rw [MeasurableEquiv.symm_comp_self, comp.right_id]
#align
  measure_theory.measure_preserving.pre_ergodic_conjugate_iff MeasureTheory.MeasurePreserving.pre_ergodic_conjugate_iff

theorem ergodic_conjugate_iff {e : α ≃ᵐ β} (h : MeasurePreserving e μ μ') :
    Ergodic (e ∘ f ∘ e.symm) μ' ↔ Ergodic f μ :=
  by
  have : measure_preserving (e ∘ f ∘ e.symm) μ' μ' ↔ measure_preserving f μ μ := by
    rw [h.comp_left_iff, (measure_preserving.symm e h).comp_right_iff]
  replace h : PreErgodic (e ∘ f ∘ e.symm) μ' ↔ PreErgodic f μ := h.pre_ergodic_conjugate_iff
  exact
    ⟨fun hf => { this.mp hf.toMeasurePreserving, h.mp hf.toPreErgodic with }, fun hf =>
      { this.mpr hf.toMeasurePreserving, h.mpr hf.toPreErgodic with }⟩
#align
  measure_theory.measure_preserving.ergodic_conjugate_iff MeasureTheory.MeasurePreserving.ergodic_conjugate_iff

end MeasureTheory.MeasurePreserving

namespace QuasiErgodic

/-- For a quasi ergodic map, sets that are almost invariant (rather than strictly invariant) are
still either almost empty or full. -/
theorem ae_empty_or_univ' (hf : QuasiErgodic f μ) (hs : MeasurableSet s) (hs' : f ⁻¹' s =ᵐ[μ] s) :
    s =ᵐ[μ] (∅ : Set α) ∨ s =ᵐ[μ] univ :=
  by
  obtain ⟨t, h₀, h₁, h₂⟩ := hf.to_quasi_measure_preserving.exists_preimage_eq_of_preimage_ae hs hs'
  rcases hf.ae_empty_or_univ h₀ h₂ with (h₃ | h₃) <;> [left, right] <;> exact ae_eq_trans h₁.symm h₃
#align quasi_ergodic.ae_empty_or_univ' QuasiErgodic.ae_empty_or_univ'

end QuasiErgodic

namespace Ergodic

/-- An ergodic map is quasi ergodic. -/
theorem quasiErgodic (hf : Ergodic f μ) : QuasiErgodic f μ :=
  { hf.toPreErgodic, hf.toMeasurePreserving.QuasiMeasurePreserving with }
#align ergodic.quasi_ergodic Ergodic.quasiErgodic

/-- See also `ergodic.ae_empty_or_univ_of_preimage_ae_le`. -/
theorem ae_empty_or_univ_of_preimage_ae_le' (hf : Ergodic f μ) (hs : MeasurableSet s)
    (hs' : f ⁻¹' s ≤ᵐ[μ] s) (h_fin : μ s ≠ ∞) : s =ᵐ[μ] (∅ : Set α) ∨ s =ᵐ[μ] univ :=
  by
  refine' hf.quasi_ergodic.ae_empty_or_univ' hs _
  refine' ae_eq_of_ae_subset_of_measure_ge hs' (hf.measure_preimage hs).symm.le _ h_fin
  exact measurable_set_preimage hf.measurable hs
#align ergodic.ae_empty_or_univ_of_preimage_ae_le' Ergodic.ae_empty_or_univ_of_preimage_ae_le'

/-- See also `ergodic.ae_empty_or_univ_of_ae_le_preimage`. -/
theorem ae_empty_or_univ_of_ae_le_preimage' (hf : Ergodic f μ) (hs : MeasurableSet s)
    (hs' : s ≤ᵐ[μ] f ⁻¹' s) (h_fin : μ s ≠ ∞) : s =ᵐ[μ] (∅ : Set α) ∨ s =ᵐ[μ] univ :=
  by
  replace h_fin : μ (f ⁻¹' s) ≠ ∞; · rwa [hf.measure_preimage hs]
  refine' hf.quasi_ergodic.ae_empty_or_univ' hs _
  exact (ae_eq_of_ae_subset_of_measure_ge hs' (hf.measure_preimage hs).le hs h_fin).symm
#align ergodic.ae_empty_or_univ_of_ae_le_preimage' Ergodic.ae_empty_or_univ_of_ae_le_preimage'

/-- See also `ergodic.ae_empty_or_univ_of_image_ae_le`. -/
theorem ae_empty_or_univ_of_image_ae_le' (hf : Ergodic f μ) (hs : MeasurableSet s)
    (hs' : f '' s ≤ᵐ[μ] s) (h_fin : μ s ≠ ∞) : s =ᵐ[μ] (∅ : Set α) ∨ s =ᵐ[μ] univ :=
  by
  replace hs' : s ≤ᵐ[μ] f ⁻¹' s :=
    (HasSubset.Subset.eventually_le (subset_preimage_image f s)).trans
      (hf.quasi_measure_preserving.preimage_mono_ae hs')
  exact ae_empty_or_univ_of_ae_le_preimage' hf hs hs' h_fin
#align ergodic.ae_empty_or_univ_of_image_ae_le' Ergodic.ae_empty_or_univ_of_image_ae_le'

section IsFiniteMeasure

variable [IsFiniteMeasure μ]

theorem ae_empty_or_univ_of_preimage_ae_le (hf : Ergodic f μ) (hs : MeasurableSet s)
    (hs' : f ⁻¹' s ≤ᵐ[μ] s) : s =ᵐ[μ] (∅ : Set α) ∨ s =ᵐ[μ] univ :=
  ae_empty_or_univ_of_preimage_ae_le' hf hs hs' <| measure_ne_top μ s
#align ergodic.ae_empty_or_univ_of_preimage_ae_le Ergodic.ae_empty_or_univ_of_preimage_ae_le

theorem ae_empty_or_univ_of_ae_le_preimage (hf : Ergodic f μ) (hs : MeasurableSet s)
    (hs' : s ≤ᵐ[μ] f ⁻¹' s) : s =ᵐ[μ] (∅ : Set α) ∨ s =ᵐ[μ] univ :=
  ae_empty_or_univ_of_ae_le_preimage' hf hs hs' <| measure_ne_top μ s
#align ergodic.ae_empty_or_univ_of_ae_le_preimage Ergodic.ae_empty_or_univ_of_ae_le_preimage

theorem ae_empty_or_univ_of_image_ae_le (hf : Ergodic f μ) (hs : MeasurableSet s)
    (hs' : f '' s ≤ᵐ[μ] s) : s =ᵐ[μ] (∅ : Set α) ∨ s =ᵐ[μ] univ :=
  ae_empty_or_univ_of_image_ae_le' hf hs hs' <| measure_ne_top μ s
#align ergodic.ae_empty_or_univ_of_image_ae_le Ergodic.ae_empty_or_univ_of_image_ae_le

end IsFiniteMeasure

end Ergodic

