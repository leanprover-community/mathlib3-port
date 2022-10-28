/-
Copyright (c) 2021 Anatole Dedecker. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anatole Dedecker, Bhavik Mehta
-/
import Mathbin.MeasureTheory.Integral.IntervalIntegral
import Mathbin.Order.Filter.AtTopBot

/-!
# Links between an integral and its "improper" version

In its current state, mathlib only knows how to talk about definite ("proper") integrals,
in the sense that it treats integrals over `[x, +∞)` the same as it treats integrals over
`[y, z]`. For example, the integral over `[1, +∞)` is **not** defined to be the limit of
the integral over `[1, x]` as `x` tends to `+∞`, which is known as an **improper integral**.

Indeed, the "proper" definition is stronger than the "improper" one. The usual counterexample
is `x ↦ sin(x)/x`, which has an improper integral over `[1, +∞)` but no definite integral.

Although definite integrals have better properties, they are hardly usable when it comes to
computing integrals on unbounded sets, which is much easier using limits. Thus, in this file,
we prove various ways of studying the proper integral by studying the improper one.

## Definitions

The main definition of this file is `measure_theory.ae_cover`. It is a rather technical
definition whose sole purpose is generalizing and factoring proofs. Given an index type `ι`, a
countably generated filter `l` over `ι`, and an `ι`-indexed family `φ` of subsets of a measurable
space `α` equipped with a measure `μ`, one should think of a hypothesis `hφ : ae_cover μ l φ` as
a sufficient condition for being able to interpret `∫ x, f x ∂μ` (if it exists) as the limit
of `∫ x in φ i, f x ∂μ` as `i` tends to `l`.

When using this definition with a measure restricted to a set `s`, which happens fairly often,
one should not try too hard to use a `ae_cover` of subsets of `s`, as it often makes proofs
more complicated than necessary. See for example the proof of
`measure_theory.integrable_on_Iic_of_interval_integral_norm_tendsto` where we use `(λ x, Ioi x)`
as an `ae_cover` w.r.t. `μ.restrict (Iic b)`, instead of using `(λ x, Ioc x b)`.

## Main statements

- `measure_theory.ae_cover.lintegral_tendsto_of_countably_generated` : if `φ` is a `ae_cover μ l`,
  where `l` is a countably generated filter, and if `f` is a measurable `ennreal`-valued function,
  then `∫⁻ x in φ n, f x ∂μ` tends to `∫⁻ x, f x ∂μ` as `n` tends to `l`
- `measure_theory.ae_cover.integrable_of_integral_norm_tendsto` : if `φ` is a `ae_cover μ l`,
  where `l` is a countably generated filter, if `f` is measurable and integrable on each `φ n`,
  and if `∫ x in φ n, ∥f x∥ ∂μ` tends to some `I : ℝ` as n tends to `l`, then `f` is integrable
- `measure_theory.ae_cover.integral_tendsto_of_countably_generated` : if `φ` is a `ae_cover μ l`,
  where `l` is a countably generated filter, and if `f` is measurable and integrable (globally),
  then `∫ x in φ n, f x ∂μ` tends to `∫ x, f x ∂μ` as `n` tends to `+∞`.

We then specialize these lemmas to various use cases involving intervals, which are frequent
in analysis.
-/


open MeasureTheory Filter Set TopologicalSpace

open Ennreal Nnreal TopologicalSpace

namespace MeasureTheory

section AeCover

variable {α ι : Type _} [MeasurableSpace α] (μ : Measure α) (l : Filter ι)

/-- A sequence `φ` of subsets of `α` is a `ae_cover` w.r.t. a measure `μ` and a filter `l`
    if almost every point (w.r.t. `μ`) of `α` eventually belongs to `φ n` (w.r.t. `l`), and if
    each `φ n` is measurable.
    This definition is a technical way to avoid duplicating a lot of proofs.
    It should be thought of as a sufficient condition for being able to interpret
    `∫ x, f x ∂μ` (if it exists) as the limit of `∫ x in φ n, f x ∂μ` as `n` tends to `l`.

    See for example `measure_theory.ae_cover.lintegral_tendsto_of_countably_generated`,
    `measure_theory.ae_cover.integrable_of_integral_norm_tendsto` and
    `measure_theory.ae_cover.integral_tendsto_of_countably_generated`. -/
structure AeCover (φ : ι → Set α) : Prop where
  ae_eventually_mem : ∀ᵐ x ∂μ, ∀ᶠ i in l, x ∈ φ i
  Measurable : ∀ i, MeasurableSet <| φ i

variable {μ} {l}

section Preorderα

variable [Preorder α] [TopologicalSpace α] [OrderClosedTopology α] [OpensMeasurableSpace α] {a b : ι → α}
  (ha : Tendsto a l atBot) (hb : Tendsto b l atTop)

theorem aeCoverIcc : AeCover μ l fun i => IccCat (a i) (b i) :=
  { ae_eventually_mem :=
      ae_of_all μ fun x =>
        (ha.Eventually <| eventually_le_at_bot x).mp <|
          (hb.Eventually <| eventually_ge_at_top x).mono fun i hbi hai => ⟨hai, hbi⟩,
    Measurable := fun i => measurableSetIcc }

theorem aeCoverIci : AeCover μ l fun i => Ici <| a i :=
  { ae_eventually_mem := ae_of_all μ fun x => (ha.Eventually <| eventually_le_at_bot x).mono fun i hai => hai,
    Measurable := fun i => measurableSetIci }

theorem aeCoverIic : AeCover μ l fun i => Iic <| b i :=
  { ae_eventually_mem := ae_of_all μ fun x => (hb.Eventually <| eventually_ge_at_top x).mono fun i hbi => hbi,
    Measurable := fun i => measurableSetIic }

end Preorderα

section LinearOrderα

variable [LinearOrder α] [TopologicalSpace α] [OrderClosedTopology α] [OpensMeasurableSpace α] {a b : ι → α}
  (ha : Tendsto a l atBot) (hb : Tendsto b l atTop)

theorem aeCoverIoo [NoMinOrder α] [NoMaxOrder α] : AeCover μ l fun i => IooCat (a i) (b i) :=
  { ae_eventually_mem :=
      ae_of_all μ fun x =>
        (ha.Eventually <| eventually_lt_at_bot x).mp <|
          (hb.Eventually <| eventually_gt_at_top x).mono fun i hbi hai => ⟨hai, hbi⟩,
    Measurable := fun i => measurableSetIoo }

theorem aeCoverIoc [NoMinOrder α] : AeCover μ l fun i => IocCat (a i) (b i) :=
  { ae_eventually_mem :=
      ae_of_all μ fun x =>
        (ha.Eventually <| eventually_lt_at_bot x).mp <|
          (hb.Eventually <| eventually_ge_at_top x).mono fun i hbi hai => ⟨hai, hbi⟩,
    Measurable := fun i => measurableSetIoc }

theorem aeCoverIco [NoMaxOrder α] : AeCover μ l fun i => IcoCat (a i) (b i) :=
  { ae_eventually_mem :=
      ae_of_all μ fun x =>
        (ha.Eventually <| eventually_le_at_bot x).mp <|
          (hb.Eventually <| eventually_gt_at_top x).mono fun i hbi hai => ⟨hai, hbi⟩,
    Measurable := fun i => measurableSetIco }

theorem aeCoverIoi [NoMinOrder α] : AeCover μ l fun i => Ioi <| a i :=
  { ae_eventually_mem := ae_of_all μ fun x => (ha.Eventually <| eventually_lt_at_bot x).mono fun i hai => hai,
    Measurable := fun i => measurableSetIoi }

theorem aeCoverIio [NoMaxOrder α] : AeCover μ l fun i => Iio <| b i :=
  { ae_eventually_mem := ae_of_all μ fun x => (hb.Eventually <| eventually_gt_at_top x).mono fun i hbi => hbi,
    Measurable := fun i => measurableSetIio }

end LinearOrderα

section FiniteIntervals

variable [LinearOrder α] [TopologicalSpace α] [OrderClosedTopology α] [OpensMeasurableSpace α] {a b : ι → α} {A B : α}
  (ha : Tendsto a l (𝓝 A)) (hb : Tendsto b l (𝓝 B))

theorem aeCoverIooOfIcc : AeCover (μ.restrict <| IooCat A B) l fun i => IccCat (a i) (b i) :=
  { ae_eventually_mem :=
      (ae_restrict_iff' measurableSetIoo).mpr
        (ae_of_all μ fun x hx =>
          (ha.Eventually <| eventually_le_nhds hx.left).mp <|
            (hb.Eventually <| eventually_ge_nhds hx.right).mono fun i hbi hai => ⟨hai, hbi⟩),
    Measurable := fun i => measurableSetIcc }

theorem aeCoverIooOfIco : AeCover (μ.restrict <| IooCat A B) l fun i => IcoCat (a i) (b i) :=
  { ae_eventually_mem :=
      (ae_restrict_iff' measurableSetIoo).mpr
        (ae_of_all μ fun x hx =>
          (ha.Eventually <| eventually_le_nhds hx.left).mp <|
            (hb.Eventually <| eventually_gt_nhds hx.right).mono fun i hbi hai => ⟨hai, hbi⟩),
    Measurable := fun i => measurableSetIco }

theorem aeCoverIooOfIoc : AeCover (μ.restrict <| IooCat A B) l fun i => IocCat (a i) (b i) :=
  { ae_eventually_mem :=
      (ae_restrict_iff' measurableSetIoo).mpr
        (ae_of_all μ fun x hx =>
          (ha.Eventually <| eventually_lt_nhds hx.left).mp <|
            (hb.Eventually <| eventually_ge_nhds hx.right).mono fun i hbi hai => ⟨hai, hbi⟩),
    Measurable := fun i => measurableSetIoc }

theorem aeCoverIooOfIoo : AeCover (μ.restrict <| IooCat A B) l fun i => IooCat (a i) (b i) :=
  { ae_eventually_mem :=
      (ae_restrict_iff' measurableSetIoo).mpr
        (ae_of_all μ fun x hx =>
          (ha.Eventually <| eventually_lt_nhds hx.left).mp <|
            (hb.Eventually <| eventually_gt_nhds hx.right).mono fun i hbi hai => ⟨hai, hbi⟩),
    Measurable := fun i => measurableSetIoo }

variable [HasNoAtoms μ]

theorem aeCoverIocOfIcc (ha : Tendsto a l (𝓝 A)) (hb : Tendsto b l (𝓝 B)) :
    AeCover (μ.restrict <| IocCat A B) l fun i => IccCat (a i) (b i) := by
  simp [measure.restrict_congr_set Ioo_ae_eq_Ioc.symm, ae_cover_Ioo_of_Icc ha hb]

theorem aeCoverIocOfIco (ha : Tendsto a l (𝓝 A)) (hb : Tendsto b l (𝓝 B)) :
    AeCover (μ.restrict <| IocCat A B) l fun i => IcoCat (a i) (b i) := by
  simp [measure.restrict_congr_set Ioo_ae_eq_Ioc.symm, ae_cover_Ioo_of_Ico ha hb]

theorem aeCoverIocOfIoc (ha : Tendsto a l (𝓝 A)) (hb : Tendsto b l (𝓝 B)) :
    AeCover (μ.restrict <| IocCat A B) l fun i => IocCat (a i) (b i) := by
  simp [measure.restrict_congr_set Ioo_ae_eq_Ioc.symm, ae_cover_Ioo_of_Ioc ha hb]

theorem aeCoverIocOfIoo (ha : Tendsto a l (𝓝 A)) (hb : Tendsto b l (𝓝 B)) :
    AeCover (μ.restrict <| IocCat A B) l fun i => IooCat (a i) (b i) := by
  simp [measure.restrict_congr_set Ioo_ae_eq_Ioc.symm, ae_cover_Ioo_of_Ioo ha hb]

theorem aeCoverIcoOfIcc (ha : Tendsto a l (𝓝 A)) (hb : Tendsto b l (𝓝 B)) :
    AeCover (μ.restrict <| IcoCat A B) l fun i => IccCat (a i) (b i) := by
  simp [measure.restrict_congr_set Ioo_ae_eq_Ico.symm, ae_cover_Ioo_of_Icc ha hb]

theorem aeCoverIcoOfIco (ha : Tendsto a l (𝓝 A)) (hb : Tendsto b l (𝓝 B)) :
    AeCover (μ.restrict <| IcoCat A B) l fun i => IcoCat (a i) (b i) := by
  simp [measure.restrict_congr_set Ioo_ae_eq_Ico.symm, ae_cover_Ioo_of_Ico ha hb]

theorem aeCoverIcoOfIoc (ha : Tendsto a l (𝓝 A)) (hb : Tendsto b l (𝓝 B)) :
    AeCover (μ.restrict <| IcoCat A B) l fun i => IocCat (a i) (b i) := by
  simp [measure.restrict_congr_set Ioo_ae_eq_Ico.symm, ae_cover_Ioo_of_Ioc ha hb]

theorem aeCoverIcoOfIoo (ha : Tendsto a l (𝓝 A)) (hb : Tendsto b l (𝓝 B)) :
    AeCover (μ.restrict <| IcoCat A B) l fun i => IooCat (a i) (b i) := by
  simp [measure.restrict_congr_set Ioo_ae_eq_Ico.symm, ae_cover_Ioo_of_Ioo ha hb]

theorem aeCoverIccOfIcc (ha : Tendsto a l (𝓝 A)) (hb : Tendsto b l (𝓝 B)) :
    AeCover (μ.restrict <| IccCat A B) l fun i => IccCat (a i) (b i) := by
  simp [measure.restrict_congr_set Ioo_ae_eq_Icc.symm, ae_cover_Ioo_of_Icc ha hb]

theorem aeCoverIccOfIco (ha : Tendsto a l (𝓝 A)) (hb : Tendsto b l (𝓝 B)) :
    AeCover (μ.restrict <| IccCat A B) l fun i => IcoCat (a i) (b i) := by
  simp [measure.restrict_congr_set Ioo_ae_eq_Icc.symm, ae_cover_Ioo_of_Ico ha hb]

theorem aeCoverIccOfIoc (ha : Tendsto a l (𝓝 A)) (hb : Tendsto b l (𝓝 B)) :
    AeCover (μ.restrict <| IccCat A B) l fun i => IocCat (a i) (b i) := by
  simp [measure.restrict_congr_set Ioo_ae_eq_Icc.symm, ae_cover_Ioo_of_Ioc ha hb]

theorem aeCoverIccOfIoo (ha : Tendsto a l (𝓝 A)) (hb : Tendsto b l (𝓝 B)) :
    AeCover (μ.restrict <| IccCat A B) l fun i => IooCat (a i) (b i) := by
  simp [measure.restrict_congr_set Ioo_ae_eq_Icc.symm, ae_cover_Ioo_of_Ioo ha hb]

end FiniteIntervals

theorem AeCover.restrict {φ : ι → Set α} (hφ : AeCover μ l φ) {s : Set α} : AeCover (μ.restrict s) l φ :=
  { ae_eventually_mem := ae_restrict_of_ae hφ.ae_eventually_mem, Measurable := hφ.Measurable }

theorem aeCoverRestrictOfAeImp {s : Set α} {φ : ι → Set α} (hs : MeasurableSet s)
    (ae_eventually_mem : ∀ᵐ x ∂μ, x ∈ s → ∀ᶠ n in l, x ∈ φ n) (measurable : ∀ n, MeasurableSet <| φ n) :
    AeCover (μ.restrict s) l φ :=
  { ae_eventually_mem := by rwa [ae_restrict_iff' hs], Measurable }

theorem AeCover.interRestrict {φ : ι → Set α} (hφ : AeCover μ l φ) {s : Set α} (hs : MeasurableSet s) :
    AeCover (μ.restrict s) l fun i => φ i ∩ s :=
  aeCoverRestrictOfAeImp hs (hφ.ae_eventually_mem.mono fun x hx hxs => hx.mono fun i hi => ⟨hi, hxs⟩) fun i =>
    (hφ.Measurable i).inter hs

theorem AeCover.ae_tendsto_indicator {β : Type _} [Zero β] [TopologicalSpace β] (f : α → β) {φ : ι → Set α}
    (hφ : AeCover μ l φ) : ∀ᵐ x ∂μ, Tendsto (fun i => (φ i).indicator f x) l (𝓝 <| f x) :=
  hφ.ae_eventually_mem.mono fun x hx => tendsto_const_nhds.congr' <| hx.mono fun n hn => (indicator_of_mem hn _).symm

theorem AeCover.aeMeasurable {β : Type _} [MeasurableSpace β] [l.IsCountablyGenerated] [l.ne_bot] {f : α → β}
    {φ : ι → Set α} (hφ : AeCover μ l φ) (hfm : ∀ i, AeMeasurable f (μ.restrict <| φ i)) : AeMeasurable f μ := by
  obtain ⟨u, hu⟩ := l.exists_seq_tendsto
  have := ae_measurable_Union_iff.mpr fun n : ℕ => hfm (u n)
  rwa [measure.restrict_eq_self_of_ae_mem] at this
  filter_upwards [hφ.ae_eventually_mem] with x hx using let ⟨i, hi⟩ := (hu.eventually hx).exists
    mem_Union.mpr ⟨i, hi⟩

theorem AeCover.aeStronglyMeasurable {β : Type _} [TopologicalSpace β] [PseudoMetrizableSpace β]
    [l.IsCountablyGenerated] [l.ne_bot] {f : α → β} {φ : ι → Set α} (hφ : AeCover μ l φ)
    (hfm : ∀ i, AeStronglyMeasurable f (μ.restrict <| φ i)) : AeStronglyMeasurable f μ := by
  obtain ⟨u, hu⟩ := l.exists_seq_tendsto
  have := ae_strongly_measurable_Union_iff.mpr fun n : ℕ => hfm (u n)
  rwa [measure.restrict_eq_self_of_ae_mem] at this
  filter_upwards [hφ.ae_eventually_mem] with x hx using let ⟨i, hi⟩ := (hu.eventually hx).exists
    mem_Union.mpr ⟨i, hi⟩

end AeCover

theorem AeCover.compTendsto {α ι ι' : Type _} [MeasurableSpace α] {μ : Measure α} {l : Filter ι} {l' : Filter ι'}
    {φ : ι → Set α} (hφ : AeCover μ l φ) {u : ι' → ι} (hu : Tendsto u l' l) : AeCover μ l' (φ ∘ u) :=
  { ae_eventually_mem := hφ.ae_eventually_mem.mono fun x hx => hu.Eventually hx,
    Measurable := fun i => hφ.Measurable (u i) }

section AeCoverUnionInterCountable

variable {α ι : Type _} [Countable ι] [MeasurableSpace α] {μ : Measure α}

theorem AeCover.bUnionIicAeCover [Preorder ι] {φ : ι → Set α} (hφ : AeCover μ atTop φ) :
    AeCover μ atTop fun n : ι => ⋃ (k) (h : k ∈ IicCat n), φ k :=
  { ae_eventually_mem := hφ.ae_eventually_mem.mono fun x h => h.mono fun i hi => mem_bUnion right_mem_Iic hi,
    Measurable := fun i => MeasurableSet.bUnion (to_countable _) fun n _ => hφ.Measurable n }

theorem AeCover.bInterIciAeCover [SemilatticeSup ι] [Nonempty ι] {φ : ι → Set α} (hφ : AeCover μ atTop φ) :
    AeCover μ atTop fun n : ι => ⋂ (k) (h : k ∈ IciCat n), φ k :=
  { ae_eventually_mem :=
      hφ.ae_eventually_mem.mono
        (by
          intro x h
          rw [eventually_at_top] at *
          rcases h with ⟨i, hi⟩
          use i
          intro j hj
          exact mem_bInter fun k hk => hi k (le_trans hj hk)),
    Measurable := fun i => MeasurableSet.bInter (to_countable _) fun n _ => hφ.Measurable n }

end AeCoverUnionInterCountable

section Lintegral

variable {α ι : Type _} [MeasurableSpace α] {μ : Measure α} {l : Filter ι}

private theorem lintegral_tendsto_of_monotone_of_nat {φ : ℕ → Set α} (hφ : AeCover μ atTop φ) (hmono : Monotone φ)
    {f : α → ℝ≥0∞} (hfm : AeMeasurable f μ) : Tendsto (fun i => ∫⁻ x in φ i, f x ∂μ) atTop (𝓝 <| ∫⁻ x, f x ∂μ) :=
  let F n := (φ n).indicator f
  have key₁ : ∀ n, AeMeasurable (F n) μ := fun n => hfm.indicator (hφ.Measurable n)
  have key₂ : ∀ᵐ x : α ∂μ, Monotone fun n => F n x :=
    ae_of_all _ fun x i j hij => indicator_le_indicator_of_subset (hmono hij) (fun x => zero_le <| f x) x
  have key₃ : ∀ᵐ x : α ∂μ, Tendsto (fun n => F n x) atTop (𝓝 (f x)) := hφ.ae_tendsto_indicator f
  (lintegral_tendsto_of_tendsto_of_monotone key₁ key₂ key₃).congr fun n => lintegral_indicator f (hφ.Measurable n)

theorem AeCover.lintegral_tendsto_of_nat {φ : ℕ → Set α} (hφ : AeCover μ atTop φ) {f : α → ℝ≥0∞}
    (hfm : AeMeasurable f μ) : Tendsto (fun i => ∫⁻ x in φ i, f x ∂μ) atTop (𝓝 <| ∫⁻ x, f x ∂μ) := by
  have lim₁ :=
    lintegral_tendsto_of_monotone_of_nat hφ.bInter_Ici_ae_cover
      (fun i j hij => bInter_subset_bInter_left (Ici_subset_Ici.mpr hij)) hfm
  have lim₂ :=
    lintegral_tendsto_of_monotone_of_nat hφ.bUnion_Iic_ae_cover
      (fun i j hij => bUnion_subset_bUnion_left (Iic_subset_Iic.mpr hij)) hfm
  have le₁ := fun n => lintegral_mono_set (bInter_subset_of_mem left_mem_Ici)
  have le₂ := fun n => lintegral_mono_set (subset_bUnion_of_mem right_mem_Iic)
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le lim₁ lim₂ le₁ le₂

theorem AeCover.lintegral_tendsto_of_countably_generated [l.IsCountablyGenerated] {φ : ι → Set α} (hφ : AeCover μ l φ)
    {f : α → ℝ≥0∞} (hfm : AeMeasurable f μ) : Tendsto (fun i => ∫⁻ x in φ i, f x ∂μ) l (𝓝 <| ∫⁻ x, f x ∂μ) :=
  tendsto_of_seq_tendsto fun u hu => (hφ.comp_tendsto hu).lintegral_tendsto_of_nat hfm

theorem AeCover.lintegral_eq_of_tendsto [l.ne_bot] [l.IsCountablyGenerated] {φ : ι → Set α} (hφ : AeCover μ l φ)
    {f : α → ℝ≥0∞} (I : ℝ≥0∞) (hfm : AeMeasurable f μ) (htendsto : Tendsto (fun i => ∫⁻ x in φ i, f x ∂μ) l (𝓝 I)) :
    (∫⁻ x, f x ∂μ) = I :=
  tendsto_nhds_unique (hφ.lintegral_tendsto_of_countably_generated hfm) htendsto

theorem AeCover.supr_lintegral_eq_of_countably_generated [Nonempty ι] [l.ne_bot] [l.IsCountablyGenerated]
    {φ : ι → Set α} (hφ : AeCover μ l φ) {f : α → ℝ≥0∞} (hfm : AeMeasurable f μ) :
    (⨆ i : ι, ∫⁻ x in φ i, f x ∂μ) = ∫⁻ x, f x ∂μ := by
  have := hφ.lintegral_tendsto_of_countably_generated hfm
  refine'
    csupr_eq_of_forall_le_of_forall_lt_exists_gt (fun i => lintegral_mono' measure.restrict_le_self le_rfl) fun w hw =>
      _
  rcases exists_between hw with ⟨m, hm₁, hm₂⟩
  rcases(eventually_ge_of_tendsto_gt hm₂ this).exists with ⟨i, hi⟩
  exact ⟨i, lt_of_lt_of_le hm₁ hi⟩

end Lintegral

section Integrable

variable {α ι E : Type _} [MeasurableSpace α] {μ : Measure α} {l : Filter ι} [NormedAddCommGroup E]

theorem AeCover.integrableOfLintegralNnnormBounded [l.ne_bot] [l.IsCountablyGenerated] {φ : ι → Set α}
    (hφ : AeCover μ l φ) {f : α → E} (I : ℝ) (hfm : AeStronglyMeasurable f μ)
    (hbounded : ∀ᶠ i in l, (∫⁻ x in φ i, ∥f x∥₊ ∂μ) ≤ Ennreal.ofReal I) : Integrable f μ := by
  refine' ⟨hfm, (le_of_tendsto _ hbounded).trans_lt Ennreal.of_real_lt_top⟩
  exact hφ.lintegral_tendsto_of_countably_generated hfm.ennnorm

theorem AeCover.integrableOfLintegralNnnormTendsto [l.ne_bot] [l.IsCountablyGenerated] {φ : ι → Set α}
    (hφ : AeCover μ l φ) {f : α → E} (I : ℝ) (hfm : AeStronglyMeasurable f μ)
    (htendsto : Tendsto (fun i => ∫⁻ x in φ i, ∥f x∥₊ ∂μ) l (𝓝 <| Ennreal.ofReal I)) : Integrable f μ := by
  refine' hφ.integrable_of_lintegral_nnnorm_bounded (max 1 (I + 1)) hfm _
  refine' htendsto.eventually (ge_mem_nhds _)
  refine' (Ennreal.of_real_lt_of_real_iff (lt_max_of_lt_left zero_lt_one)).2 _
  exact lt_max_of_lt_right (lt_add_one I)

theorem AeCover.integrableOfLintegralNnnormBounded' [l.ne_bot] [l.IsCountablyGenerated] {φ : ι → Set α}
    (hφ : AeCover μ l φ) {f : α → E} (I : ℝ≥0) (hfm : AeStronglyMeasurable f μ)
    (hbounded : ∀ᶠ i in l, (∫⁻ x in φ i, ∥f x∥₊ ∂μ) ≤ I) : Integrable f μ :=
  hφ.integrableOfLintegralNnnormBounded I hfm (by simpa only [Ennreal.of_real_coe_nnreal] using hbounded)

theorem AeCover.integrableOfLintegralNnnormTendsto' [l.ne_bot] [l.IsCountablyGenerated] {φ : ι → Set α}
    (hφ : AeCover μ l φ) {f : α → E} (I : ℝ≥0) (hfm : AeStronglyMeasurable f μ)
    (htendsto : Tendsto (fun i => ∫⁻ x in φ i, ∥f x∥₊ ∂μ) l (𝓝 I)) : Integrable f μ :=
  hφ.integrableOfLintegralNnnormTendsto I hfm (by simpa only [Ennreal.of_real_coe_nnreal] using htendsto)

theorem AeCover.integrableOfIntegralNormBounded [l.ne_bot] [l.IsCountablyGenerated] {φ : ι → Set α} (hφ : AeCover μ l φ)
    {f : α → E} (I : ℝ) (hfi : ∀ i, IntegrableOn f (φ i) μ) (hbounded : ∀ᶠ i in l, (∫ x in φ i, ∥f x∥ ∂μ) ≤ I) :
    Integrable f μ := by
  have hfm : ae_strongly_measurable f μ := hφ.ae_strongly_measurable fun i => (hfi i).AeStronglyMeasurable
  refine' hφ.integrable_of_lintegral_nnnorm_bounded I hfm _
  conv at hbounded in integral _ _ =>
    rw [integral_eq_lintegral_of_nonneg_ae (ae_of_all _ fun x => @norm_nonneg E _ (f x)) hfm.norm.restrict]
  conv at hbounded in Ennreal.ofReal _ =>
    dsimp
    rw [← coe_nnnorm]
    rw [Ennreal.of_real_coe_nnreal]
  refine' hbounded.mono fun i hi => _
  rw [← Ennreal.of_real_to_real (ne_top_of_lt (hfi i).2)]
  apply Ennreal.of_real_le_of_real hi

theorem AeCover.integrableOfIntegralNormTendsto [l.ne_bot] [l.IsCountablyGenerated] {φ : ι → Set α} (hφ : AeCover μ l φ)
    {f : α → E} (I : ℝ) (hfi : ∀ i, IntegrableOn f (φ i) μ)
    (htendsto : Tendsto (fun i => ∫ x in φ i, ∥f x∥ ∂μ) l (𝓝 I)) : Integrable f μ :=
  let ⟨I', hI'⟩ := htendsto.is_bounded_under_le
  hφ.integrableOfIntegralNormBounded I' hfi hI'

theorem AeCover.integrableOfIntegralBoundedOfNonnegAe [l.ne_bot] [l.IsCountablyGenerated] {φ : ι → Set α}
    (hφ : AeCover μ l φ) {f : α → ℝ} (I : ℝ) (hfi : ∀ i, IntegrableOn f (φ i) μ) (hnng : ∀ᵐ x ∂μ, 0 ≤ f x)
    (hbounded : ∀ᶠ i in l, (∫ x in φ i, f x ∂μ) ≤ I) : Integrable f μ :=
  hφ.integrableOfIntegralNormBounded I hfi <|
    hbounded.mono fun i hi =>
      (integral_congr_ae <| ae_restrict_of_ae <| hnng.mono fun x => Real.norm_of_nonneg).le.trans hi

theorem AeCover.integrableOfIntegralTendstoOfNonnegAe [l.ne_bot] [l.IsCountablyGenerated] {φ : ι → Set α}
    (hφ : AeCover μ l φ) {f : α → ℝ} (I : ℝ) (hfi : ∀ i, IntegrableOn f (φ i) μ) (hnng : ∀ᵐ x ∂μ, 0 ≤ f x)
    (htendsto : Tendsto (fun i => ∫ x in φ i, f x ∂μ) l (𝓝 I)) : Integrable f μ :=
  let ⟨I', hI'⟩ := htendsto.is_bounded_under_le
  hφ.integrableOfIntegralBoundedOfNonnegAe I' hfi hnng hI'

end Integrable

section Integral

variable {α ι E : Type _} [MeasurableSpace α] {μ : Measure α} {l : Filter ι} [NormedAddCommGroup E] [NormedSpace ℝ E]
  [CompleteSpace E]

theorem AeCover.integral_tendsto_of_countably_generated [l.IsCountablyGenerated] {φ : ι → Set α} (hφ : AeCover μ l φ)
    {f : α → E} (hfi : Integrable f μ) : Tendsto (fun i => ∫ x in φ i, f x ∂μ) l (𝓝 <| ∫ x, f x ∂μ) :=
  suffices h : Tendsto (fun i => ∫ x : α, (φ i).indicator f x ∂μ) l (𝓝 (∫ x : α, f x ∂μ)) from by
    convert h
    ext n
    rw [integral_indicator (hφ.measurable n)]
  tendsto_integral_filter_of_dominated_convergence (fun x => ∥f x∥)
    (eventually_of_forall fun i => hfi.AeStronglyMeasurable.indicator <| hφ.Measurable i)
    (eventually_of_forall fun i => (ae_of_all _) fun x => norm_indicator_le_norm_self _ _) hfi.norm
    (hφ.ae_tendsto_indicator f)

/-- Slight reformulation of
    `measure_theory.ae_cover.integral_tendsto_of_countably_generated`. -/
theorem AeCover.integral_eq_of_tendsto [l.ne_bot] [l.IsCountablyGenerated] {φ : ι → Set α} (hφ : AeCover μ l φ)
    {f : α → E} (I : E) (hfi : Integrable f μ) (h : Tendsto (fun n => ∫ x in φ n, f x ∂μ) l (𝓝 I)) :
    (∫ x, f x ∂μ) = I :=
  tendsto_nhds_unique (hφ.integral_tendsto_of_countably_generated hfi) h

theorem AeCover.integral_eq_of_tendsto_of_nonneg_ae [l.ne_bot] [l.IsCountablyGenerated] {φ : ι → Set α}
    (hφ : AeCover μ l φ) {f : α → ℝ} (I : ℝ) (hnng : 0 ≤ᵐ[μ] f) (hfi : ∀ n, IntegrableOn f (φ n) μ)
    (htendsto : Tendsto (fun n => ∫ x in φ n, f x ∂μ) l (𝓝 I)) : (∫ x, f x ∂μ) = I :=
  have hfi' : Integrable f μ := hφ.integrableOfIntegralTendstoOfNonnegAe I hfi hnng htendsto
  hφ.integral_eq_of_tendsto I hfi' htendsto

end Integral

section IntegrableOfIntervalIntegral

variable {ι E : Type _} {μ : Measure ℝ} {l : Filter ι} [Filter.NeBot l] [IsCountablyGenerated l] [NormedAddCommGroup E]
  {a b : ι → ℝ} {f : ℝ → E}

theorem integrableOfIntervalIntegralNormBounded (I : ℝ) (hfi : ∀ i, IntegrableOn f (IocCat (a i) (b i)) μ)
    (ha : Tendsto a l atBot) (hb : Tendsto b l atTop) (h : ∀ᶠ i in l, (∫ x in a i..b i, ∥f x∥ ∂μ) ≤ I) :
    Integrable f μ := by
  have hφ : ae_cover μ l _ := ae_cover_Ioc ha hb
  refine' hφ.integrable_of_integral_norm_bounded I hfi (h.mp _)
  filter_upwards [ha.eventually (eventually_le_at_bot 0), hb.eventually (eventually_ge_at_top 0)] with i hai hbi ht
  rwa [← intervalIntegral.integral_of_le (hai.trans hbi)]

/-- If `f` is integrable on intervals `Ioc (a i) (b i)`,
where `a i` tends to -∞ and `b i` tends to ∞, and
`∫ x in a i .. b i, ∥f x∥ ∂μ` converges to `I : ℝ` along a filter `l`,
then `f` is integrable on the interval (-∞, ∞) -/
theorem integrableOfIntervalIntegralNormTendsto (I : ℝ) (hfi : ∀ i, IntegrableOn f (IocCat (a i) (b i)) μ)
    (ha : Tendsto a l atBot) (hb : Tendsto b l atTop) (h : Tendsto (fun i => ∫ x in a i..b i, ∥f x∥ ∂μ) l (𝓝 I)) :
    Integrable f μ :=
  let ⟨I', hI'⟩ := h.is_bounded_under_le
  integrableOfIntervalIntegralNormBounded I' hfi ha hb hI'

theorem integrableOnIicOfIntervalIntegralNormBounded (I b : ℝ) (hfi : ∀ i, IntegrableOn f (IocCat (a i) b) μ)
    (ha : Tendsto a l atBot) (h : ∀ᶠ i in l, (∫ x in a i..b, ∥f x∥ ∂μ) ≤ I) : IntegrableOn f (IicCat b) μ := by
  have hφ : ae_cover (μ.restrict <| Iic b) l _ := ae_cover_Ioi ha
  have hfi : ∀ i, integrable_on f (Ioi (a i)) (μ.restrict <| Iic b) := by
    intro i
    rw [integrable_on, measure.restrict_restrict (hφ.measurable i)]
    exact hfi i
  refine' hφ.integrable_of_integral_norm_bounded I hfi (h.mp _)
  filter_upwards [ha.eventually (eventually_le_at_bot b)] with i hai
  rw [intervalIntegral.integral_of_le hai, measure.restrict_restrict (hφ.measurable i)]
  exact id

/-- If `f` is integrable on intervals `Ioc (a i) b`,
where `a i` tends to -∞, and
`∫ x in a i .. b, ∥f x∥ ∂μ` converges to `I : ℝ` along a filter `l`,
then `f` is integrable on the interval (-∞, b) -/
theorem integrableOnIicOfIntervalIntegralNormTendsto (I b : ℝ) (hfi : ∀ i, IntegrableOn f (IocCat (a i) b) μ)
    (ha : Tendsto a l atBot) (h : Tendsto (fun i => ∫ x in a i..b, ∥f x∥ ∂μ) l (𝓝 I)) : IntegrableOn f (IicCat b) μ :=
  let ⟨I', hI'⟩ := h.is_bounded_under_le
  integrableOnIicOfIntervalIntegralNormBounded I' b hfi ha hI'

theorem integrableOnIoiOfIntervalIntegralNormBounded (I a : ℝ) (hfi : ∀ i, IntegrableOn f (IocCat a (b i)) μ)
    (hb : Tendsto b l atTop) (h : ∀ᶠ i in l, (∫ x in a..b i, ∥f x∥ ∂μ) ≤ I) : IntegrableOn f (IoiCat a) μ := by
  have hφ : ae_cover (μ.restrict <| Ioi a) l _ := ae_cover_Iic hb
  have hfi : ∀ i, integrable_on f (Iic (b i)) (μ.restrict <| Ioi a) := by
    intro i
    rw [integrable_on, measure.restrict_restrict (hφ.measurable i), inter_comm]
    exact hfi i
  refine' hφ.integrable_of_integral_norm_bounded I hfi (h.mp _)
  filter_upwards [hb.eventually (eventually_ge_at_top a)] with i hbi
  rw [intervalIntegral.integral_of_le hbi, measure.restrict_restrict (hφ.measurable i), inter_comm]
  exact id

/-- If `f` is integrable on intervals `Ioc a (b i)`,
where `b i` tends to ∞, and
`∫ x in a .. b i, ∥f x∥ ∂μ` converges to `I : ℝ` along a filter `l`,
then `f` is integrable on the interval (a, ∞) -/
theorem integrableOnIoiOfIntervalIntegralNormTendsto (I a : ℝ) (hfi : ∀ i, IntegrableOn f (IocCat a (b i)) μ)
    (hb : Tendsto b l atTop) (h : Tendsto (fun i => ∫ x in a..b i, ∥f x∥ ∂μ) l (𝓝 <| I)) :
    IntegrableOn f (IoiCat a) μ :=
  let ⟨I', hI'⟩ := h.is_bounded_under_le
  integrableOnIoiOfIntervalIntegralNormBounded I' a hfi hb hI'

theorem integrableOnIocOfIntervalIntegralNormBounded {I a₀ b₀ : ℝ} (hfi : ∀ i, IntegrableOn f <| IocCat (a i) (b i))
    (ha : Tendsto a l <| 𝓝 a₀) (hb : Tendsto b l <| 𝓝 b₀) (h : ∀ᶠ i in l, (∫ x in IocCat (a i) (b i), ∥f x∥) ≤ I) :
    IntegrableOn f (IocCat a₀ b₀) := by
  refine'
    (ae_cover_Ioc_of_Ioc ha hb).integrableOfIntegralNormBounded I (fun i => (hfi i).restrict measurableSetIoc)
      (eventually.mono h _)
  intro i hi
  simp only [measure.restrict_restrict measurableSetIoc]
  refine' le_trans (set_integral_mono_set (hfi i).norm _ _) hi
  · apply ae_of_all
    simp only [Pi.zero_apply, norm_nonneg, forall_const]
    
  · apply ae_of_all
    intro c hc
    exact hc.1
    

theorem integrableOnIocOfIntervalIntegralNormBoundedLeft {I a₀ b : ℝ} (hfi : ∀ i, IntegrableOn f <| IocCat (a i) b)
    (ha : Tendsto a l <| 𝓝 a₀) (h : ∀ᶠ i in l, (∫ x in IocCat (a i) b, ∥f x∥) ≤ I) : IntegrableOn f (IocCat a₀ b) :=
  integrableOnIocOfIntervalIntegralNormBounded hfi ha tendsto_const_nhds h

theorem integrableOnIocOfIntervalIntegralNormBoundedRight {I a b₀ : ℝ} (hfi : ∀ i, IntegrableOn f <| IocCat a (b i))
    (hb : Tendsto b l <| 𝓝 b₀) (h : ∀ᶠ i in l, (∫ x in IocCat a (b i), ∥f x∥) ≤ I) : IntegrableOn f (IocCat a b₀) :=
  integrableOnIocOfIntervalIntegralNormBounded hfi tendsto_const_nhds hb h

end IntegrableOfIntervalIntegral

section IntegralOfIntervalIntegral

variable {ι E : Type _} {μ : Measure ℝ} {l : Filter ι} [IsCountablyGenerated l] [NormedAddCommGroup E] [NormedSpace ℝ E]
  [CompleteSpace E] {a b : ι → ℝ} {f : ℝ → E}

theorem interval_integral_tendsto_integral (hfi : Integrable f μ) (ha : Tendsto a l atBot) (hb : Tendsto b l atTop) :
    Tendsto (fun i => ∫ x in a i..b i, f x ∂μ) l (𝓝 <| ∫ x, f x ∂μ) := by
  let φ i := Ioc (a i) (b i)
  have hφ : ae_cover μ l φ := ae_cover_Ioc ha hb
  refine' (hφ.integral_tendsto_of_countably_generated hfi).congr' _
  filter_upwards [ha.eventually (eventually_le_at_bot 0), hb.eventually (eventually_ge_at_top 0)] with i hai hbi
  exact (intervalIntegral.integral_of_le (hai.trans hbi)).symm

theorem interval_integral_tendsto_integral_Iic (b : ℝ) (hfi : IntegrableOn f (IicCat b) μ) (ha : Tendsto a l atBot) :
    Tendsto (fun i => ∫ x in a i..b, f x ∂μ) l (𝓝 <| ∫ x in IicCat b, f x ∂μ) := by
  let φ i := Ioi (a i)
  have hφ : ae_cover (μ.restrict <| Iic b) l φ := ae_cover_Ioi ha
  refine' (hφ.integral_tendsto_of_countably_generated hfi).congr' _
  filter_upwards [ha.eventually (eventually_le_at_bot <| b)] with i hai
  rw [intervalIntegral.integral_of_le hai, measure.restrict_restrict (hφ.measurable i)]
  rfl

theorem interval_integral_tendsto_integral_Ioi (a : ℝ) (hfi : IntegrableOn f (IoiCat a) μ) (hb : Tendsto b l atTop) :
    Tendsto (fun i => ∫ x in a..b i, f x ∂μ) l (𝓝 <| ∫ x in IoiCat a, f x ∂μ) := by
  let φ i := Iic (b i)
  have hφ : ae_cover (μ.restrict <| Ioi a) l φ := ae_cover_Iic hb
  refine' (hφ.integral_tendsto_of_countably_generated hfi).congr' _
  filter_upwards [hb.eventually (eventually_ge_at_top <| a)] with i hbi
  rw [intervalIntegral.integral_of_le hbi, measure.restrict_restrict (hφ.measurable i), inter_comm]
  rfl

end IntegralOfIntervalIntegral

end MeasureTheory

