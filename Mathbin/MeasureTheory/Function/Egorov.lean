/-
Copyright (c) 2022 Kexing Ying. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kexing Ying
-/
import MeasureTheory.Function.StronglyMeasurable.Basic

#align_import measure_theory.function.egorov from "leanprover-community/mathlib"@"0b7c740e25651db0ba63648fbae9f9d6f941e31b"

/-!
# Egorov theorem

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains the Egorov theorem which states that an almost everywhere convergent
sequence on a finite measure space converges uniformly except on an arbitrarily small set.
This theorem is useful for the Vitali convergence theorem as well as theorems regarding
convergence in measure.

## Main results

* `measure_theory.egorov`: Egorov's theorem which shows that a sequence of almost everywhere
  convergent functions converges uniformly except on an arbitrarily small set.

-/


noncomputable section

open scoped Classical MeasureTheory NNReal ENNReal Topology

namespace MeasureTheory

open Set Filter TopologicalSpace

variable {α β ι : Type _} {m : MeasurableSpace α} [MetricSpace β] {μ : Measure α}

namespace Egorov

#print MeasureTheory.Egorov.notConvergentSeq /-
/-- Given a sequence of functions `f` and a function `g`, `not_convergent_seq f g n j` is the
set of elements such that `f k x` and `g x` are separated by at least `1 / (n + 1)` for some
`k ≥ j`.

This definition is useful for Egorov's theorem. -/
def notConvergentSeq [Preorder ι] (f : ι → α → β) (g : α → β) (n : ℕ) (j : ι) : Set α :=
  ⋃ (k) (hk : j ≤ k), {x | 1 / (n + 1 : ℝ) < dist (f k x) (g x)}
#align measure_theory.egorov.not_convergent_seq MeasureTheory.Egorov.notConvergentSeq
-/

variable {n : ℕ} {i j : ι} {s : Set α} {ε : ℝ} {f : ι → α → β} {g : α → β}

#print MeasureTheory.Egorov.mem_notConvergentSeq_iff /-
theorem mem_notConvergentSeq_iff [Preorder ι] {x : α} :
    x ∈ notConvergentSeq f g n j ↔ ∃ (k : _) (hk : j ≤ k), 1 / (n + 1 : ℝ) < dist (f k x) (g x) :=
  by simp_rw [not_convergent_seq, mem_Union]; rfl
#align measure_theory.egorov.mem_not_convergent_seq_iff MeasureTheory.Egorov.mem_notConvergentSeq_iff
-/

#print MeasureTheory.Egorov.notConvergentSeq_antitone /-
theorem notConvergentSeq_antitone [Preorder ι] : Antitone (notConvergentSeq f g n) := fun j k hjk =>
  iUnion₂_mono' fun l hl => ⟨l, le_trans hjk hl, Subset.rfl⟩
#align measure_theory.egorov.not_convergent_seq_antitone MeasureTheory.Egorov.notConvergentSeq_antitone
-/

#print MeasureTheory.Egorov.measure_inter_notConvergentSeq_eq_zero /-
theorem measure_inter_notConvergentSeq_eq_zero [SemilatticeSup ι] [Nonempty ι]
    (hfg : ∀ᵐ x ∂μ, x ∈ s → Tendsto (fun n => f n x) atTop (𝓝 (g x))) (n : ℕ) :
    μ (s ∩ ⋂ j, notConvergentSeq f g n j) = 0 :=
  by
  simp_rw [Metric.tendsto_atTop, ae_iff] at hfg
  rw [← nonpos_iff_eq_zero, ← hfg]
  refine' measure_mono fun x => _
  simp only [mem_inter_iff, mem_Inter, ge_iff_le, mem_not_convergent_seq_iff]
  push_neg
  rintro ⟨hmem, hx⟩
  refine' ⟨hmem, 1 / (n + 1 : ℝ), Nat.one_div_pos_of_nat, fun N => _⟩
  obtain ⟨n, hn₁, hn₂⟩ := hx N
  exact ⟨n, hn₁, hn₂.le⟩
#align measure_theory.egorov.measure_inter_not_convergent_seq_eq_zero MeasureTheory.Egorov.measure_inter_notConvergentSeq_eq_zero
-/

#print MeasureTheory.Egorov.notConvergentSeq_measurableSet /-
theorem notConvergentSeq_measurableSet [Preorder ι] [Countable ι]
    (hf : ∀ n, strongly_measurable[m] (f n)) (hg : StronglyMeasurable g) :
    MeasurableSet (notConvergentSeq f g n j) :=
  MeasurableSet.iUnion fun k =>
    MeasurableSet.iUnion fun hk =>
      StronglyMeasurable.measurableSet_lt stronglyMeasurable_const <| (hf k).dist hg
#align measure_theory.egorov.not_convergent_seq_measurable_set MeasureTheory.Egorov.notConvergentSeq_measurableSet
-/

#print MeasureTheory.Egorov.measure_notConvergentSeq_tendsto_zero /-
theorem measure_notConvergentSeq_tendsto_zero [SemilatticeSup ι] [Countable ι]
    (hf : ∀ n, StronglyMeasurable (f n)) (hg : StronglyMeasurable g) (hsm : MeasurableSet s)
    (hs : μ s ≠ ∞) (hfg : ∀ᵐ x ∂μ, x ∈ s → Tendsto (fun n => f n x) atTop (𝓝 (g x))) (n : ℕ) :
    Tendsto (fun j => μ (s ∩ notConvergentSeq f g n j)) atTop (𝓝 0) :=
  by
  cases isEmpty_or_nonempty ι
  · have : (fun j => μ (s ∩ not_convergent_seq f g n j)) = fun j => 0 := by
      simp only [eq_iff_true_of_subsingleton]
    rw [this]
    exact tendsto_const_nhds
  rw [← measure_inter_not_convergent_seq_eq_zero hfg n, inter_Inter]
  refine'
    tendsto_measure_Inter (fun n => hsm.inter <| not_convergent_seq_measurable_set hf hg)
      (fun k l hkl => inter_subset_inter_right _ <| not_convergent_seq_antitone hkl)
      ⟨h.some, (lt_of_le_of_lt (measure_mono <| inter_subset_left _ _) (lt_top_iff_ne_top.2 hs)).Ne⟩
#align measure_theory.egorov.measure_not_convergent_seq_tendsto_zero MeasureTheory.Egorov.measure_notConvergentSeq_tendsto_zero
-/

variable [SemilatticeSup ι] [Nonempty ι] [Countable ι]

#print MeasureTheory.Egorov.exists_notConvergentSeq_lt /-
theorem exists_notConvergentSeq_lt (hε : 0 < ε) (hf : ∀ n, StronglyMeasurable (f n))
    (hg : StronglyMeasurable g) (hsm : MeasurableSet s) (hs : μ s ≠ ∞)
    (hfg : ∀ᵐ x ∂μ, x ∈ s → Tendsto (fun n => f n x) atTop (𝓝 (g x))) (n : ℕ) :
    ∃ j : ι, μ (s ∩ notConvergentSeq f g n j) ≤ ENNReal.ofReal (ε * 2⁻¹ ^ n) :=
  by
  obtain ⟨N, hN⟩ :=
    (ENNReal.tendsto_atTop ENNReal.zero_ne_top).1
      (measure_not_convergent_seq_tendsto_zero hf hg hsm hs hfg n) (ENNReal.ofReal (ε * 2⁻¹ ^ n)) _
  · rw [zero_add] at hN
    exact ⟨N, (hN N le_rfl).2⟩
  · rw [gt_iff_lt, ENNReal.ofReal_pos]
    exact mul_pos hε (pow_pos (by norm_num) n)
#align measure_theory.egorov.exists_not_convergent_seq_lt MeasureTheory.Egorov.exists_notConvergentSeq_lt
-/

#print MeasureTheory.Egorov.notConvergentSeqLTIndex /-
/-- Given some `ε > 0`, `not_convergent_seq_lt_index` provides the index such that
`not_convergent_seq` (intersected with a set of finite measure) has measure less than
`ε * 2⁻¹ ^ n`.

This definition is useful for Egorov's theorem. -/
def notConvergentSeqLTIndex (hε : 0 < ε) (hf : ∀ n, StronglyMeasurable (f n))
    (hg : StronglyMeasurable g) (hsm : MeasurableSet s) (hs : μ s ≠ ∞)
    (hfg : ∀ᵐ x ∂μ, x ∈ s → Tendsto (fun n => f n x) atTop (𝓝 (g x))) (n : ℕ) : ι :=
  Classical.choose <| exists_notConvergentSeq_lt hε hf hg hsm hs hfg n
#align measure_theory.egorov.not_convergent_seq_lt_index MeasureTheory.Egorov.notConvergentSeqLTIndex
-/

#print MeasureTheory.Egorov.notConvergentSeqLTIndex_spec /-
theorem notConvergentSeqLTIndex_spec (hε : 0 < ε) (hf : ∀ n, StronglyMeasurable (f n))
    (hg : StronglyMeasurable g) (hsm : MeasurableSet s) (hs : μ s ≠ ∞)
    (hfg : ∀ᵐ x ∂μ, x ∈ s → Tendsto (fun n => f n x) atTop (𝓝 (g x))) (n : ℕ) :
    μ (s ∩ notConvergentSeq f g n (notConvergentSeqLTIndex hε hf hg hsm hs hfg n)) ≤
      ENNReal.ofReal (ε * 2⁻¹ ^ n) :=
  Classical.choose_spec <| exists_notConvergentSeq_lt hε hf hg hsm hs hfg n
#align measure_theory.egorov.not_convergent_seq_lt_index_spec MeasureTheory.Egorov.notConvergentSeqLTIndex_spec
-/

#print MeasureTheory.Egorov.iUnionNotConvergentSeq /-
/-- Given some `ε > 0`, `Union_not_convergent_seq` is the union of `not_convergent_seq` with
specific indicies such that `Union_not_convergent_seq` has measure less equal than `ε`.

This definition is useful for Egorov's theorem. -/
def iUnionNotConvergentSeq (hε : 0 < ε) (hf : ∀ n, StronglyMeasurable (f n))
    (hg : StronglyMeasurable g) (hsm : MeasurableSet s) (hs : μ s ≠ ∞)
    (hfg : ∀ᵐ x ∂μ, x ∈ s → Tendsto (fun n => f n x) atTop (𝓝 (g x))) : Set α :=
  ⋃ n, s ∩ notConvergentSeq f g n (notConvergentSeqLTIndex (half_pos hε) hf hg hsm hs hfg n)
#align measure_theory.egorov.Union_not_convergent_seq MeasureTheory.Egorov.iUnionNotConvergentSeq
-/

#print MeasureTheory.Egorov.iUnionNotConvergentSeq_measurableSet /-
theorem iUnionNotConvergentSeq_measurableSet (hε : 0 < ε) (hf : ∀ n, StronglyMeasurable (f n))
    (hg : StronglyMeasurable g) (hsm : MeasurableSet s) (hs : μ s ≠ ∞)
    (hfg : ∀ᵐ x ∂μ, x ∈ s → Tendsto (fun n => f n x) atTop (𝓝 (g x))) :
    MeasurableSet <| iUnionNotConvergentSeq hε hf hg hsm hs hfg :=
  MeasurableSet.iUnion fun n => hsm.inter <| notConvergentSeq_measurableSet hf hg
#align measure_theory.egorov.Union_not_convergent_seq_measurable_set MeasureTheory.Egorov.iUnionNotConvergentSeq_measurableSet
-/

#print MeasureTheory.Egorov.measure_iUnionNotConvergentSeq /-
theorem measure_iUnionNotConvergentSeq (hε : 0 < ε) (hf : ∀ n, StronglyMeasurable (f n))
    (hg : StronglyMeasurable g) (hsm : MeasurableSet s) (hs : μ s ≠ ∞)
    (hfg : ∀ᵐ x ∂μ, x ∈ s → Tendsto (fun n => f n x) atTop (𝓝 (g x))) :
    μ (iUnionNotConvergentSeq hε hf hg hsm hs hfg) ≤ ENNReal.ofReal ε :=
  by
  refine'
    le_trans (measure_Union_le _)
      (le_trans
        (ENNReal.tsum_le_tsum <| not_convergent_seq_lt_index_spec (half_pos hε) hf hg hsm hs hfg) _)
  simp_rw [ENNReal.ofReal_mul (half_pos hε).le]
  rw [ENNReal.tsum_mul_left, ← ENNReal.ofReal_tsum_of_nonneg, inv_eq_one_div, tsum_geometric_two, ←
    ENNReal.ofReal_mul (half_pos hε).le, div_mul_cancel₀ ε two_ne_zero]
  · exact le_rfl
  · exact fun n => pow_nonneg (by norm_num) _
  · rw [inv_eq_one_div]
    exact summable_geometric_two
#align measure_theory.egorov.measure_Union_not_convergent_seq MeasureTheory.Egorov.measure_iUnionNotConvergentSeq
-/

#print MeasureTheory.Egorov.iUnionNotConvergentSeq_subset /-
theorem iUnionNotConvergentSeq_subset (hε : 0 < ε) (hf : ∀ n, StronglyMeasurable (f n))
    (hg : StronglyMeasurable g) (hsm : MeasurableSet s) (hs : μ s ≠ ∞)
    (hfg : ∀ᵐ x ∂μ, x ∈ s → Tendsto (fun n => f n x) atTop (𝓝 (g x))) :
    iUnionNotConvergentSeq hε hf hg hsm hs hfg ⊆ s :=
  by
  rw [Union_not_convergent_seq, ← inter_Union]
  exact inter_subset_left _ _
#align measure_theory.egorov.Union_not_convergent_seq_subset MeasureTheory.Egorov.iUnionNotConvergentSeq_subset
-/

#print MeasureTheory.Egorov.tendstoUniformlyOn_diff_iUnionNotConvergentSeq /-
theorem tendstoUniformlyOn_diff_iUnionNotConvergentSeq (hε : 0 < ε)
    (hf : ∀ n, StronglyMeasurable (f n)) (hg : StronglyMeasurable g) (hsm : MeasurableSet s)
    (hs : μ s ≠ ∞) (hfg : ∀ᵐ x ∂μ, x ∈ s → Tendsto (fun n => f n x) atTop (𝓝 (g x))) :
    TendstoUniformlyOn f g atTop (s \ Egorov.iUnionNotConvergentSeq hε hf hg hsm hs hfg) :=
  by
  rw [Metric.tendstoUniformlyOn_iff]
  intro δ hδ
  obtain ⟨N, hN⟩ := exists_nat_one_div_lt hδ
  rw [eventually_at_top]
  refine' ⟨egorov.not_convergent_seq_lt_index (half_pos hε) hf hg hsm hs hfg N, fun n hn x hx => _⟩
  simp only [mem_diff, egorov.Union_not_convergent_seq, not_exists, mem_Union, mem_inter_iff,
    not_and, exists_and_left] at hx
  obtain ⟨hxs, hx⟩ := hx
  specialize hx hxs N
  rw [egorov.mem_not_convergent_seq_iff] at hx
  push_neg at hx
  rw [dist_comm]
  exact lt_of_le_of_lt (hx n hn) hN
#align measure_theory.egorov.tendsto_uniformly_on_diff_Union_not_convergent_seq MeasureTheory.Egorov.tendstoUniformlyOn_diff_iUnionNotConvergentSeq
-/

end Egorov

variable [SemilatticeSup ι] [Nonempty ι] [Countable ι] {γ : Type _} [TopologicalSpace γ]
  {f : ι → α → β} {g : α → β} {s : Set α}

/- ././././Mathport/Syntax/Translate/Basic.lean:642:2: warning: expanding binder collection (t «expr ⊆ » s) -/
#print MeasureTheory.tendstoUniformlyOn_of_ae_tendsto /-
/-- **Egorov's theorem**: If `f : ι → α → β` is a sequence of strongly measurable functions that
converges to `g : α → β` almost everywhere on a measurable set `s` of finite measure,
then for all `ε > 0`, there exists a subset `t ⊆ s` such that `μ t ≤ ε` and `f` converges to `g`
uniformly on `s \ t`. We require the index type `ι` to be countable, and usually `ι = ℕ`.

In other words, a sequence of almost everywhere convergent functions converges uniformly except on
an arbitrarily small set. -/
theorem tendstoUniformlyOn_of_ae_tendsto (hf : ∀ n, StronglyMeasurable (f n))
    (hg : StronglyMeasurable g) (hsm : MeasurableSet s) (hs : μ s ≠ ∞)
    (hfg : ∀ᵐ x ∂μ, x ∈ s → Tendsto (fun n => f n x) atTop (𝓝 (g x))) {ε : ℝ} (hε : 0 < ε) :
    ∃ (t : _) (_ : t ⊆ s),
      MeasurableSet t ∧ μ t ≤ ENNReal.ofReal ε ∧ TendstoUniformlyOn f g atTop (s \ t) :=
  ⟨Egorov.iUnionNotConvergentSeq hε hf hg hsm hs hfg,
    Egorov.iUnionNotConvergentSeq_subset hε hf hg hsm hs hfg,
    Egorov.iUnionNotConvergentSeq_measurableSet hε hf hg hsm hs hfg,
    Egorov.measure_iUnionNotConvergentSeq hε hf hg hsm hs hfg,
    Egorov.tendstoUniformlyOn_diff_iUnionNotConvergentSeq hε hf hg hsm hs hfg⟩
#align measure_theory.tendsto_uniformly_on_of_ae_tendsto MeasureTheory.tendstoUniformlyOn_of_ae_tendsto
-/

#print MeasureTheory.tendstoUniformlyOn_of_ae_tendsto' /-
/-- Egorov's theorem for finite measure spaces. -/
theorem tendstoUniformlyOn_of_ae_tendsto' [IsFiniteMeasure μ] (hf : ∀ n, StronglyMeasurable (f n))
    (hg : StronglyMeasurable g) (hfg : ∀ᵐ x ∂μ, Tendsto (fun n => f n x) atTop (𝓝 (g x))) {ε : ℝ}
    (hε : 0 < ε) :
    ∃ t, MeasurableSet t ∧ μ t ≤ ENNReal.ofReal ε ∧ TendstoUniformlyOn f g atTop (tᶜ) :=
  by
  obtain ⟨t, _, ht, htendsto⟩ :=
    tendsto_uniformly_on_of_ae_tendsto hf hg MeasurableSet.univ (measure_ne_top μ univ) _ hε
  · refine' ⟨_, ht, _⟩
    rwa [compl_eq_univ_diff]
  · filter_upwards [hfg] with _ htendsto _ using htendsto
#align measure_theory.tendsto_uniformly_on_of_ae_tendsto' MeasureTheory.tendstoUniformlyOn_of_ae_tendsto'
-/

end MeasureTheory

