/-
Copyright (c) 2021 Rémy Degenne. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rémy Degenne

! This file was ported from Lean 3 source module measure_theory.function.ess_sup
! leanprover-community/mathlib commit bd9851ca476957ea4549eb19b40e7b5ade9428cc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Constructions.BorelSpace
import Mathbin.Order.Filter.Ennreal

/-!
# Essential supremum and infimum
We define the essential supremum and infimum of a function `f : α → β` with respect to a measure
`μ` on `α`. The essential supremum is the infimum of the constants `c : β` such that `f x ≤ c`
almost everywhere.

TODO: The essential supremum of functions `α → ℝ≥0∞` is used in particular to define the norm in
the `L∞` space (see measure_theory/lp_space.lean).

There is a different quantity which is sometimes also called essential supremum: the least
upper-bound among measurable functions of a family of measurable functions (in an almost-everywhere
sense). We do not define that quantity here, which is simply the supremum of a map with values in
`α →ₘ[μ] β` (see measure_theory/ae_eq_fun.lean).

## Main definitions

* `ess_sup f μ := μ.ae.limsup f`
* `ess_inf f μ := μ.ae.liminf f`
-/


open MeasureTheory Filter TopologicalSpace

open Ennreal MeasureTheory

variable {α β : Type _} {m : MeasurableSpace α} {μ ν : Measure α}

section ConditionallyCompleteLattice

variable [ConditionallyCompleteLattice β]

/-- Essential supremum of `f` with respect to measure `μ`: the smallest `c : β` such that
`f x ≤ c` a.e. -/
def essSup {m : MeasurableSpace α} (f : α → β) (μ : Measure α) :=
  μ.ae.limsup f
#align ess_sup essSup

/-- Essential infimum of `f` with respect to measure `μ`: the greatest `c : β` such that
`c ≤ f x` a.e. -/
def essInf {m : MeasurableSpace α} (f : α → β) (μ : Measure α) :=
  μ.ae.liminf f
#align ess_inf essInf

theorem essSup_congr_ae {f g : α → β} (hfg : f =ᵐ[μ] g) : essSup f μ = essSup g μ :=
  limsup_congr hfg
#align ess_sup_congr_ae essSup_congr_ae

theorem essInf_congr_ae {f g : α → β} (hfg : f =ᵐ[μ] g) : essInf f μ = essInf g μ :=
  @essSup_congr_ae α βᵒᵈ _ _ _ _ _ hfg
#align ess_inf_congr_ae essInf_congr_ae

end ConditionallyCompleteLattice

section ConditionallyCompleteLinearOrder

variable [ConditionallyCompleteLinearOrder β]

theorem essSup_eq_infₛ {m : MeasurableSpace α} (μ : Measure α) (f : α → β) :
    essSup f μ = infₛ { a | μ { x | a < f x } = 0 } :=
  by
  dsimp [essSup, limsup, Limsup]
  congr
  ext a
  simp [eventually_map, ae_iff]
#align ess_sup_eq_Inf essSup_eq_infₛ

end ConditionallyCompleteLinearOrder

section CompleteLattice

variable [CompleteLattice β]

@[simp]
theorem essSup_measure_zero {m : MeasurableSpace α} {f : α → β} : essSup f (0 : Measure α) = ⊥ :=
  le_bot_iff.mp (infₛ_le (by simp [Set.mem_setOf_eq, eventually_le, ae_iff]))
#align ess_sup_measure_zero essSup_measure_zero

@[simp]
theorem essInf_measure_zero {m : MeasurableSpace α} {f : α → β} : essInf f (0 : Measure α) = ⊤ :=
  @essSup_measure_zero α βᵒᵈ _ _ _
#align ess_inf_measure_zero essInf_measure_zero

theorem essSup_mono_ae {f g : α → β} (hfg : f ≤ᵐ[μ] g) : essSup f μ ≤ essSup g μ :=
  limsup_le_limsup hfg
#align ess_sup_mono_ae essSup_mono_ae

theorem essInf_mono_ae {f g : α → β} (hfg : f ≤ᵐ[μ] g) : essInf f μ ≤ essInf g μ :=
  liminf_le_liminf hfg
#align ess_inf_mono_ae essInf_mono_ae

theorem essSup_const (c : β) (hμ : μ ≠ 0) : essSup (fun x : α => c) μ = c :=
  haveI hμ_ne_bot : μ.ae.ne_bot := by rwa [ne_bot_iff, Ne.def, ae_eq_bot]
  limsup_const c
#align ess_sup_const essSup_const

theorem essSup_le_of_ae_le {f : α → β} (c : β) (hf : f ≤ᵐ[μ] fun _ => c) : essSup f μ ≤ c :=
  by
  refine' (essSup_mono_ae hf).trans _
  by_cases hμ : μ = 0
  · simp [hμ]
  · rwa [essSup_const]
#align ess_sup_le_of_ae_le essSup_le_of_ae_le

theorem essInf_const (c : β) (hμ : μ ≠ 0) : essInf (fun x : α => c) μ = c :=
  @essSup_const α βᵒᵈ _ _ _ _ hμ
#align ess_inf_const essInf_const

theorem le_essInf_of_ae_le {f : α → β} (c : β) (hf : (fun _ => c) ≤ᵐ[μ] f) : c ≤ essInf f μ :=
  @essSup_le_of_ae_le α βᵒᵈ _ _ _ _ c hf
#align le_ess_inf_of_ae_le le_essInf_of_ae_le

theorem essSup_const_bot : essSup (fun x : α => (⊥ : β)) μ = (⊥ : β) :=
  limsup_const_bot
#align ess_sup_const_bot essSup_const_bot

theorem essInf_const_top : essInf (fun x : α => (⊤ : β)) μ = (⊤ : β) :=
  liminf_const_top
#align ess_inf_const_top essInf_const_top

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic filter.is_bounded_default -/
theorem OrderIso.essSup_apply {m : MeasurableSpace α} {γ} [CompleteLattice γ] (f : α → β)
    (μ : Measure α) (g : β ≃o γ) : g (essSup f μ) = essSup (fun x => g (f x)) μ :=
  by
  refine' OrderIso.limsup_apply g _ _ _ _
  all_goals
    run_tac
      is_bounded_default
#align order_iso.ess_sup_apply OrderIso.essSup_apply

theorem OrderIso.essInf_apply {m : MeasurableSpace α} {γ} [CompleteLattice γ] (f : α → β)
    (μ : Measure α) (g : β ≃o γ) : g (essInf f μ) = essInf (fun x => g (f x)) μ :=
  @OrderIso.essSup_apply α βᵒᵈ _ _ γᵒᵈ _ _ _ g.dual
#align order_iso.ess_inf_apply OrderIso.essInf_apply

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic filter.is_bounded_default -/
theorem essSup_mono_measure {f : α → β} (hμν : ν ≪ μ) : essSup f ν ≤ essSup f μ :=
  by
  refine' limsup_le_limsup_of_le (measure.ae_le_iff_absolutely_continuous.mpr hμν) _ _
  all_goals
    run_tac
      is_bounded_default
#align ess_sup_mono_measure essSup_mono_measure

theorem essSup_mono_measure' {α : Type _} {β : Type _} {m : MeasurableSpace α}
    {μ ν : MeasureTheory.Measure α} [CompleteLattice β] {f : α → β} (hμν : ν ≤ μ) :
    essSup f ν ≤ essSup f μ :=
  essSup_mono_measure (Measure.absolutelyContinuousOfLe hμν)
#align ess_sup_mono_measure' essSup_mono_measure'

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic filter.is_bounded_default -/
theorem essInf_antitone_measure {f : α → β} (hμν : μ ≪ ν) : essInf f ν ≤ essInf f μ :=
  by
  refine' liminf_le_liminf_of_le (measure.ae_le_iff_absolutely_continuous.mpr hμν) _ _
  all_goals
    run_tac
      is_bounded_default
#align ess_inf_antitone_measure essInf_antitone_measure

theorem essSup_smul_measure {f : α → β} {c : ℝ≥0∞} (hc : c ≠ 0) : essSup f (c • μ) = essSup f μ :=
  by
  simp_rw [essSup]
  suffices h_smul : (c • μ).ae = μ.ae; · rw [h_smul]
  ext1
  simp_rw [mem_ae_iff]
  simp [hc]
#align ess_sup_smul_measure essSup_smul_measure

section TopologicalSpace

variable {γ : Type _} {mγ : MeasurableSpace γ} {f : α → γ} {g : γ → β}

include mγ

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic filter.is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic filter.is_bounded_default -/
theorem essSup_comp_le_essSup_map_measure (hf : AeMeasurable f μ) :
    essSup (g ∘ f) μ ≤ essSup g (Measure.map f μ) :=
  by
  refine'
    Limsup_le_Limsup_of_le (fun t => _)
      (by
        run_tac
          is_bounded_default)
      (by
        run_tac
          is_bounded_default)
  simp_rw [Filter.mem_map]
  have : g ∘ f ⁻¹' t = f ⁻¹' (g ⁻¹' t) := by
    ext1 x
    simp_rw [Set.mem_preimage]
  rw [this]
  exact fun h => mem_ae_of_mem_ae_map hf h
#align ess_sup_comp_le_ess_sup_map_measure essSup_comp_le_essSup_map_measure

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic filter.is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic filter.is_bounded_default -/
theorem MeasurableEmbedding.essSup_map_measure (hf : MeasurableEmbedding f) :
    essSup g (Measure.map f μ) = essSup (g ∘ f) μ :=
  by
  refine' le_antisymm _ (essSup_comp_le_essSup_map_measure hf.measurable.ae_measurable)
  refine'
    Limsup_le_Limsup
      (by
        run_tac
          is_bounded_default)
      (by
        run_tac
          is_bounded_default)
      fun c h_le => _
  rw [eventually_map] at h_le⊢
  exact hf.ae_map_iff.mpr h_le
#align measurable_embedding.ess_sup_map_measure MeasurableEmbedding.essSup_map_measure

variable [MeasurableSpace β] [TopologicalSpace β] [SecondCountableTopology β]
  [OrderClosedTopology β] [OpensMeasurableSpace β]

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic filter.is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic filter.is_bounded_default -/
theorem essSup_map_measure_of_measurable (hg : Measurable g) (hf : AeMeasurable f μ) :
    essSup g (Measure.map f μ) = essSup (g ∘ f) μ :=
  by
  refine' le_antisymm _ (essSup_comp_le_essSup_map_measure hf)
  refine'
    Limsup_le_Limsup
      (by
        run_tac
          is_bounded_default)
      (by
        run_tac
          is_bounded_default)
      fun c h_le => _
  rw [eventually_map] at h_le⊢
  rw [ae_map_iff hf (measurableSet_le hg measurable_const)]
  exact h_le
#align ess_sup_map_measure_of_measurable essSup_map_measure_of_measurable

theorem essSup_map_measure (hg : AeMeasurable g (Measure.map f μ)) (hf : AeMeasurable f μ) :
    essSup g (Measure.map f μ) = essSup (g ∘ f) μ :=
  by
  rw [essSup_congr_ae hg.ae_eq_mk, essSup_map_measure_of_measurable hg.measurable_mk hf]
  refine' essSup_congr_ae _
  have h_eq := ae_of_ae_map hf hg.ae_eq_mk
  rw [← eventually_eq] at h_eq
  exact h_eq.symm
#align ess_sup_map_measure essSup_map_measure

omit mγ

end TopologicalSpace

end CompleteLattice

section CompleteLinearOrder

variable [CompleteLinearOrder β]

theorem ae_lt_of_essSup_lt {f : α → β} {x : β} (hf : essSup f μ < x) : ∀ᵐ y ∂μ, f y < x :=
  Filter.eventually_lt_of_limsup_lt hf
#align ae_lt_of_ess_sup_lt ae_lt_of_essSup_lt

theorem ae_lt_of_lt_essInf {f : α → β} {x : β} (hf : x < essInf f μ) : ∀ᵐ y ∂μ, x < f y :=
  @ae_lt_of_essSup_lt α βᵒᵈ _ _ _ _ _ hf
#align ae_lt_of_lt_ess_inf ae_lt_of_lt_essInf

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic filter.is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic filter.is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic filter.is_bounded_default -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic filter.is_bounded_default -/
theorem essSup_indicator_eq_essSup_restrict [Zero β] {s : Set α} {f : α → β}
    (hf : 0 ≤ᵐ[μ.restrict s] f) (hs : MeasurableSet s) (hs_not_null : μ s ≠ 0) :
    essSup (s.indicator f) μ = essSup f (μ.restrict s) :=
  by
  refine'
    le_antisymm _
      (Limsup_le_Limsup_of_le (map_restrict_ae_le_map_indicator_ae hs)
        (by
          run_tac
            is_bounded_default)
        (by
          run_tac
            is_bounded_default))
  refine'
    Limsup_le_Limsup
      (by
        run_tac
          is_bounded_default)
      (by
        run_tac
          is_bounded_default)
      fun c h_restrict_le => _
  rw [eventually_map] at h_restrict_le⊢
  rw [ae_restrict_iff' hs] at h_restrict_le
  have hc : 0 ≤ c := by
    rsuffices ⟨x, hx⟩ : ∃ x, 0 ≤ f x ∧ f x ≤ c
    exact hx.1.trans hx.2
    refine' frequently.exists _
    · exact μ.ae
    rw [eventually_le, ae_restrict_iff' hs] at hf
    have hs' : ∃ᵐ x ∂μ, x ∈ s := by
      contrapose! hs_not_null
      rw [not_frequently, ae_iff] at hs_not_null
      suffices { a : α | ¬a ∉ s } = s by rwa [← this]
      simp
    refine' hs'.mp (hf.mp (h_restrict_le.mono fun x hxs_imp_c hxf_nonneg hxs => _))
    rw [Pi.zero_apply] at hxf_nonneg
    exact ⟨hxf_nonneg hxs, hxs_imp_c hxs⟩
  refine' h_restrict_le.mono fun x hxc => _
  by_cases hxs : x ∈ s
  · simpa [hxs] using hxc hxs
  · simpa [hxs] using hc
#align ess_sup_indicator_eq_ess_sup_restrict essSup_indicator_eq_essSup_restrict

end CompleteLinearOrder

namespace Ennreal

variable {f : α → ℝ≥0∞}

theorem ae_le_essSup (f : α → ℝ≥0∞) : ∀ᵐ y ∂μ, f y ≤ essSup f μ :=
  eventually_le_limsup f
#align ennreal.ae_le_ess_sup Ennreal.ae_le_essSup

@[simp]
theorem essSup_eq_zero_iff : essSup f μ = 0 ↔ f =ᵐ[μ] 0 :=
  limsup_eq_zero_iff
#align ennreal.ess_sup_eq_zero_iff Ennreal.essSup_eq_zero_iff

theorem essSup_const_mul {a : ℝ≥0∞} : essSup (fun x : α => a * f x) μ = a * essSup f μ :=
  limsup_const_mul
#align ennreal.ess_sup_const_mul Ennreal.essSup_const_mul

theorem essSup_mul_le (f g : α → ℝ≥0∞) : essSup (f * g) μ ≤ essSup f μ * essSup g μ :=
  limsup_mul_le f g
#align ennreal.ess_sup_mul_le Ennreal.essSup_mul_le

theorem essSup_add_le (f g : α → ℝ≥0∞) : essSup (f + g) μ ≤ essSup f μ + essSup g μ :=
  limsup_add_le f g
#align ennreal.ess_sup_add_le Ennreal.essSup_add_le

theorem essSup_liminf_le {ι} [Countable ι] [LinearOrder ι] (f : ι → α → ℝ≥0∞) :
    essSup (fun x => atTop.liminf fun n => f n x) μ ≤
      atTop.liminf fun n => essSup (fun x => f n x) μ :=
  by
  simp_rw [essSup]
  exact Ennreal.limsup_liminf_le_liminf_limsup fun a b => f b a
#align ennreal.ess_sup_liminf_le Ennreal.essSup_liminf_le

end Ennreal

