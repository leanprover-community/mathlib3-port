/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module measure_theory.measure.open_pos
! leanprover-community/mathlib commit dcf2250875895376a142faeeac5eabff32c48655
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Measure.MeasureSpace

/-!
# Measures positive on nonempty opens

In this file we define a typeclass for measures that are positive on nonempty opens, see
`measure_theory.measure.is_open_pos_measure`. Examples include (additive) Haar measures, as well as
measures that have positive density with respect to a Haar measure. We also prove some basic facts
about these measures.

-/


open TopologicalSpace Ennreal MeasureTheory

open Set Function Filter

namespace MeasureTheory

namespace Measure

section Basic

variable {X Y : Type _} [TopologicalSpace X] {m : MeasurableSpace X} [TopologicalSpace Y]
  [T2Space Y] (μ ν : Measure X)

/-- A measure is said to be `is_open_pos_measure` if it is positive on nonempty open sets. -/
class IsOpenPosMeasure : Prop where
  open_pos : ∀ U : Set X, IsOpen U → U.Nonempty → μ U ≠ 0
#align measure_theory.measure.is_open_pos_measure MeasureTheory.Measure.IsOpenPosMeasure

variable [IsOpenPosMeasure μ] {s U : Set X} {x : X}

theorem IsOpen.measure_ne_zero (hU : IsOpen U) (hne : U.Nonempty) : μ U ≠ 0 :=
  IsOpenPosMeasure.open_pos U hU hne
#align is_open.measure_ne_zero IsOpen.measure_ne_zero

theorem IsOpen.measure_pos (hU : IsOpen U) (hne : U.Nonempty) : 0 < μ U :=
  (hU.measure_ne_zero μ hne).bot_lt
#align is_open.measure_pos IsOpen.measure_pos

theorem IsOpen.measure_pos_iff (hU : IsOpen U) : 0 < μ U ↔ U.Nonempty :=
  ⟨fun h => nonempty_iff_ne_empty.2 fun he => h.ne' <| he.symm ▸ measure_empty, hU.measure_pos μ⟩
#align is_open.measure_pos_iff IsOpen.measure_pos_iff

theorem IsOpen.measure_eq_zero_iff (hU : IsOpen U) : μ U = 0 ↔ U = ∅ := by
  simpa only [not_lt, nonpos_iff_eq_zero, not_nonempty_iff_eq_empty] using
    not_congr (hU.measure_pos_iff μ)
#align is_open.measure_eq_zero_iff IsOpen.measure_eq_zero_iff

theorem measure_pos_of_nonempty_interior (h : (interior s).Nonempty) : 0 < μ s :=
  (is_open_interior.measure_pos μ h).trans_le (measure_mono interior_subset)
#align
  measure_theory.measure.measure_pos_of_nonempty_interior MeasureTheory.Measure.measure_pos_of_nonempty_interior

theorem measure_pos_of_mem_nhds (h : s ∈ 𝓝 x) : 0 < μ s :=
  measure_pos_of_nonempty_interior _ ⟨x, mem_interior_iff_mem_nhds.2 h⟩
#align measure_theory.measure.measure_pos_of_mem_nhds MeasureTheory.Measure.measure_pos_of_mem_nhds

theorem isOpenPosMeasureSmul {c : ℝ≥0∞} (h : c ≠ 0) : IsOpenPosMeasure (c • μ) :=
  ⟨fun U Uo Une => mul_ne_zero h (Uo.measure_ne_zero μ Une)⟩
#align measure_theory.measure.is_open_pos_measure_smul MeasureTheory.Measure.isOpenPosMeasureSmul

variable {μ ν}

protected theorem AbsolutelyContinuous.isOpenPosMeasure (h : μ ≪ ν) : IsOpenPosMeasure ν :=
  ⟨fun U ho hne h₀ => ho.measure_ne_zero μ hne (h h₀)⟩
#align
  measure_theory.measure.absolutely_continuous.is_open_pos_measure MeasureTheory.Measure.AbsolutelyContinuous.isOpenPosMeasure

theorem LE.le.isOpenPosMeasure (h : μ ≤ ν) : IsOpenPosMeasure ν :=
  h.AbsolutelyContinuous.IsOpenPosMeasure
#align has_le.le.is_open_pos_measure LE.le.isOpenPosMeasure

theorem IsOpen.eq_empty_of_measure_zero (hU : IsOpen U) (h₀ : μ U = 0) : U = ∅ :=
  (hU.measure_eq_zero_iff μ).mp h₀
#align is_open.eq_empty_of_measure_zero IsOpen.eq_empty_of_measure_zero

theorem interior_eq_empty_of_null (hs : μ s = 0) : interior s = ∅ :=
  is_open_interior.eq_empty_of_measure_zero <| measure_mono_null interior_subset hs
#align
  measure_theory.measure.interior_eq_empty_of_null MeasureTheory.Measure.interior_eq_empty_of_null

/-- If two functions are a.e. equal on an open set and are continuous on this set, then they are
equal on this set. -/
theorem eq_on_open_of_ae_eq {f g : X → Y} (h : f =ᵐ[μ.restrict U] g) (hU : IsOpen U)
    (hf : ContinuousOn f U) (hg : ContinuousOn g U) : EqOn f g U := by
  replace h := ae_imp_of_ae_restrict h
  simp only [eventually_eq, ae_iff, not_imp] at h
  have : IsOpen (U ∩ { a | f a ≠ g a }) := by
    refine' is_open_iff_mem_nhds.mpr fun a ha => inter_mem (hU.mem_nhds ha.1) _
    rcases ha with ⟨ha : a ∈ U, ha' : (f a, g a) ∈ diagonal Yᶜ⟩
    exact
      (hf.continuous_at (hU.mem_nhds ha)).prod_mk_nhds (hg.continuous_at (hU.mem_nhds ha))
        (is_closed_diagonal.is_open_compl.mem_nhds ha')
  replace := (this.eq_empty_of_measure_zero h).le
  exact fun x hx => not_not.1 fun h => this ⟨hx, h⟩
#align measure_theory.measure.eq_on_open_of_ae_eq MeasureTheory.Measure.eq_on_open_of_ae_eq

/-- If two continuous functions are a.e. equal, then they are equal. -/
theorem eq_of_ae_eq {f g : X → Y} (h : f =ᵐ[μ] g) (hf : Continuous f) (hg : Continuous g) : f = g :=
  suffices EqOn f g univ from funext fun x => this trivial
  eq_on_open_of_ae_eq (ae_restrict_of_ae h) is_open_univ hf.ContinuousOn hg.ContinuousOn
#align measure_theory.measure.eq_of_ae_eq MeasureTheory.Measure.eq_of_ae_eq

theorem eq_on_of_ae_eq {f g : X → Y} (h : f =ᵐ[μ.restrict s] g) (hf : ContinuousOn f s)
    (hg : ContinuousOn g s) (hU : s ⊆ closure (interior s)) : EqOn f g s :=
  have : interior s ⊆ s := interior_subset
  (eq_on_open_of_ae_eq (ae_restrict_of_ae_restrict_of_subset this h) is_open_interior (hf.mono this)
        (hg.mono this)).of_subset_closure
    hf hg this hU
#align measure_theory.measure.eq_on_of_ae_eq MeasureTheory.Measure.eq_on_of_ae_eq

variable (μ)

theorem Continuous.ae_eq_iff_eq {f g : X → Y} (hf : Continuous f) (hg : Continuous g) :
    f =ᵐ[μ] g ↔ f = g :=
  ⟨fun h => eq_of_ae_eq h hf hg, fun h => h ▸ eventually_eq.rfl⟩
#align continuous.ae_eq_iff_eq Continuous.ae_eq_iff_eq

end Basic

section LinearOrder

variable {X Y : Type _} [TopologicalSpace X] [LinearOrder X] [OrderTopology X]
  {m : MeasurableSpace X} [TopologicalSpace Y] [T2Space Y] (μ : Measure X) [IsOpenPosMeasure μ]

theorem measure_Ioi_pos [NoMaxOrder X] (a : X) : 0 < μ (ioi a) :=
  is_open_Ioi.measure_pos μ nonempty_Ioi
#align measure_theory.measure.measure_Ioi_pos MeasureTheory.Measure.measure_Ioi_pos

theorem measure_Iio_pos [NoMinOrder X] (a : X) : 0 < μ (iio a) :=
  is_open_Iio.measure_pos μ nonempty_Iio
#align measure_theory.measure.measure_Iio_pos MeasureTheory.Measure.measure_Iio_pos

theorem measure_Ioo_pos [DenselyOrdered X] {a b : X} : 0 < μ (ioo a b) ↔ a < b :=
  (is_open_Ioo.measure_pos_iff μ).trans nonempty_Ioo
#align measure_theory.measure.measure_Ioo_pos MeasureTheory.Measure.measure_Ioo_pos

theorem measure_Ioo_eq_zero [DenselyOrdered X] {a b : X} : μ (ioo a b) = 0 ↔ b ≤ a :=
  (is_open_Ioo.measure_eq_zero_iff μ).trans (Ioo_eq_empty_iff.trans not_lt)
#align measure_theory.measure.measure_Ioo_eq_zero MeasureTheory.Measure.measure_Ioo_eq_zero

theorem eq_on_Ioo_of_ae_eq {a b : X} {f g : X → Y} (hfg : f =ᵐ[μ.restrict (ioo a b)] g)
    (hf : ContinuousOn f (ioo a b)) (hg : ContinuousOn g (ioo a b)) : EqOn f g (ioo a b) :=
  eq_on_of_ae_eq hfg hf hg Ioo_subset_closure_interior
#align measure_theory.measure.eq_on_Ioo_of_ae_eq MeasureTheory.Measure.eq_on_Ioo_of_ae_eq

theorem eq_on_Ioc_of_ae_eq [DenselyOrdered X] {a b : X} {f g : X → Y}
    (hfg : f =ᵐ[μ.restrict (ioc a b)] g) (hf : ContinuousOn f (ioc a b))
    (hg : ContinuousOn g (ioc a b)) : EqOn f g (ioc a b) :=
  eq_on_of_ae_eq hfg hf hg (Ioc_subset_closure_interior _ _)
#align measure_theory.measure.eq_on_Ioc_of_ae_eq MeasureTheory.Measure.eq_on_Ioc_of_ae_eq

theorem eq_on_Ico_of_ae_eq [DenselyOrdered X] {a b : X} {f g : X → Y}
    (hfg : f =ᵐ[μ.restrict (ico a b)] g) (hf : ContinuousOn f (ico a b))
    (hg : ContinuousOn g (ico a b)) : EqOn f g (ico a b) :=
  eq_on_of_ae_eq hfg hf hg (Ico_subset_closure_interior _ _)
#align measure_theory.measure.eq_on_Ico_of_ae_eq MeasureTheory.Measure.eq_on_Ico_of_ae_eq

theorem eq_on_Icc_of_ae_eq [DenselyOrdered X] {a b : X} (hne : a ≠ b) {f g : X → Y}
    (hfg : f =ᵐ[μ.restrict (icc a b)] g) (hf : ContinuousOn f (icc a b))
    (hg : ContinuousOn g (icc a b)) : EqOn f g (icc a b) :=
  eq_on_of_ae_eq hfg hf hg (closure_interior_Icc hne).symm.Subset
#align measure_theory.measure.eq_on_Icc_of_ae_eq MeasureTheory.Measure.eq_on_Icc_of_ae_eq

end LinearOrder

end Measure

end MeasureTheory

open MeasureTheory MeasureTheory.Measure

namespace Metric

variable {X : Type _} [PseudoMetricSpace X] {m : MeasurableSpace X} (μ : Measure X)
  [IsOpenPosMeasure μ]

theorem measure_ball_pos (x : X) {r : ℝ} (hr : 0 < r) : 0 < μ (ball x r) :=
  is_open_ball.measure_pos μ (nonempty_ball.2 hr)
#align metric.measure_ball_pos Metric.measure_ball_pos

theorem measure_closed_ball_pos (x : X) {r : ℝ} (hr : 0 < r) : 0 < μ (closedBall x r) :=
  (measure_ball_pos μ x hr).trans_le (measure_mono ball_subset_closed_ball)
#align metric.measure_closed_ball_pos Metric.measure_closed_ball_pos

end Metric

namespace Emetric

variable {X : Type _} [PseudoEmetricSpace X] {m : MeasurableSpace X} (μ : Measure X)
  [IsOpenPosMeasure μ]

theorem measure_ball_pos (x : X) {r : ℝ≥0∞} (hr : r ≠ 0) : 0 < μ (ball x r) :=
  is_open_ball.measure_pos μ ⟨x, mem_ball_self hr.bot_lt⟩
#align emetric.measure_ball_pos Emetric.measure_ball_pos

theorem measure_closed_ball_pos (x : X) {r : ℝ≥0∞} (hr : r ≠ 0) : 0 < μ (closedBall x r) :=
  (measure_ball_pos μ x hr).trans_le (measure_mono ball_subset_closed_ball)
#align emetric.measure_closed_ball_pos Emetric.measure_closed_ball_pos

end Emetric

