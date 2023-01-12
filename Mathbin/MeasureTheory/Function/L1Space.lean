/-
Copyright (c) 2019 Zhouhang Zhou. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Zhouhang Zhou

! This file was ported from Lean 3 source module measure_theory.function.l1_space
! leanprover-community/mathlib commit 7c523cb78f4153682c2929e3006c863bfef463d0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Function.LpOrder

/-!
# Integrable functions and `L¹` space

In the first part of this file, the predicate `integrable` is defined and basic properties of
integrable functions are proved.

Such a predicate is already available under the name `mem_ℒp 1`. We give a direct definition which
is easier to use, and show that it is equivalent to `mem_ℒp 1`

In the second part, we establish an API between `integrable` and the space `L¹` of equivalence
classes of integrable functions, already defined as a special case of `L^p` spaces for `p = 1`.

## Notation

* `α →₁[μ] β` is the type of `L¹` space, where `α` is a `measure_space` and `β` is a
  `normed_add_comm_group` with a `second_countable_topology`. `f : α →ₘ β` is a "function" in `L¹`.
  In comments, `[f]` is also used to denote an `L¹` function.

  `₁` can be typed as `\1`.

## Main definitions

* Let `f : α → β` be a function, where `α` is a `measure_space` and `β` a `normed_add_comm_group`.
  Then `has_finite_integral f` means `(∫⁻ a, ‖f a‖₊) < ∞`.

* If `β` is moreover a `measurable_space` then `f` is called `integrable` if
  `f` is `measurable` and `has_finite_integral f` holds.

## Implementation notes

To prove something for an arbitrary integrable function, a useful theorem is
`integrable.induction` in the file `set_integral`.

## Tags

integrable, function space, l1

-/


noncomputable section

open Classical TopologicalSpace BigOperators Ennreal MeasureTheory Nnreal

open Set Filter TopologicalSpace Ennreal Emetric MeasureTheory

variable {α β γ δ : Type _} {m : MeasurableSpace α} {μ ν : Measure α} [MeasurableSpace δ]

variable [NormedAddCommGroup β]

variable [NormedAddCommGroup γ]

namespace MeasureTheory

/-! ### Some results about the Lebesgue integral involving a normed group -/


theorem lintegral_nnnorm_eq_lintegral_edist (f : α → β) :
    (∫⁻ a, ‖f a‖₊ ∂μ) = ∫⁻ a, edist (f a) 0 ∂μ := by simp only [edist_eq_coe_nnnorm]
#align
  measure_theory.lintegral_nnnorm_eq_lintegral_edist MeasureTheory.lintegral_nnnorm_eq_lintegral_edist

theorem lintegral_norm_eq_lintegral_edist (f : α → β) :
    (∫⁻ a, Ennreal.ofReal ‖f a‖ ∂μ) = ∫⁻ a, edist (f a) 0 ∂μ := by
  simp only [of_real_norm_eq_coe_nnnorm, edist_eq_coe_nnnorm]
#align
  measure_theory.lintegral_norm_eq_lintegral_edist MeasureTheory.lintegral_norm_eq_lintegral_edist

theorem lintegral_edist_triangle {f g h : α → β} (hf : AeStronglyMeasurable f μ)
    (hh : AeStronglyMeasurable h μ) :
    (∫⁻ a, edist (f a) (g a) ∂μ) ≤ (∫⁻ a, edist (f a) (h a) ∂μ) + ∫⁻ a, edist (g a) (h a) ∂μ :=
  by
  rw [← lintegral_add_left' (hf.edist hh)]
  refine' lintegral_mono fun a => _
  apply edist_triangle_right
#align measure_theory.lintegral_edist_triangle MeasureTheory.lintegral_edist_triangle

theorem lintegral_nnnorm_zero : (∫⁻ a : α, ‖(0 : β)‖₊ ∂μ) = 0 := by simp
#align measure_theory.lintegral_nnnorm_zero MeasureTheory.lintegral_nnnorm_zero

theorem lintegral_nnnorm_add_left {f : α → β} (hf : AeStronglyMeasurable f μ) (g : α → γ) :
    (∫⁻ a, ‖f a‖₊ + ‖g a‖₊ ∂μ) = (∫⁻ a, ‖f a‖₊ ∂μ) + ∫⁻ a, ‖g a‖₊ ∂μ :=
  lintegral_add_left' hf.ennnorm _
#align measure_theory.lintegral_nnnorm_add_left MeasureTheory.lintegral_nnnorm_add_left

theorem lintegral_nnnorm_add_right (f : α → β) {g : α → γ} (hg : AeStronglyMeasurable g μ) :
    (∫⁻ a, ‖f a‖₊ + ‖g a‖₊ ∂μ) = (∫⁻ a, ‖f a‖₊ ∂μ) + ∫⁻ a, ‖g a‖₊ ∂μ :=
  lintegral_add_right' _ hg.ennnorm
#align measure_theory.lintegral_nnnorm_add_right MeasureTheory.lintegral_nnnorm_add_right

theorem lintegral_nnnorm_neg {f : α → β} : (∫⁻ a, ‖(-f) a‖₊ ∂μ) = ∫⁻ a, ‖f a‖₊ ∂μ := by
  simp only [Pi.neg_apply, nnnorm_neg]
#align measure_theory.lintegral_nnnorm_neg MeasureTheory.lintegral_nnnorm_neg

/-! ### The predicate `has_finite_integral` -/


/-- `has_finite_integral f μ` means that the integral `∫⁻ a, ‖f a‖ ∂μ` is finite.
  `has_finite_integral f` means `has_finite_integral f volume`. -/
def HasFiniteIntegral {m : MeasurableSpace α} (f : α → β)
    (μ : Measure α := by exact MeasureTheory.MeasureSpace.volume) : Prop :=
  (∫⁻ a, ‖f a‖₊ ∂μ) < ∞
#align measure_theory.has_finite_integral MeasureTheory.HasFiniteIntegral

theorem has_finite_integral_iff_norm (f : α → β) :
    HasFiniteIntegral f μ ↔ (∫⁻ a, Ennreal.ofReal ‖f a‖ ∂μ) < ∞ := by
  simp only [has_finite_integral, of_real_norm_eq_coe_nnnorm]
#align measure_theory.has_finite_integral_iff_norm MeasureTheory.has_finite_integral_iff_norm

theorem has_finite_integral_iff_edist (f : α → β) :
    HasFiniteIntegral f μ ↔ (∫⁻ a, edist (f a) 0 ∂μ) < ∞ := by
  simp only [has_finite_integral_iff_norm, edist_dist, dist_zero_right]
#align measure_theory.has_finite_integral_iff_edist MeasureTheory.has_finite_integral_iff_edist

theorem has_finite_integral_iff_of_real {f : α → ℝ} (h : 0 ≤ᵐ[μ] f) :
    HasFiniteIntegral f μ ↔ (∫⁻ a, Ennreal.ofReal (f a) ∂μ) < ∞ := by
  rw [has_finite_integral, lintegral_nnnorm_eq_of_ae_nonneg h]
#align measure_theory.has_finite_integral_iff_of_real MeasureTheory.has_finite_integral_iff_of_real

theorem has_finite_integral_iff_of_nnreal {f : α → ℝ≥0} :
    HasFiniteIntegral (fun x => (f x : ℝ)) μ ↔ (∫⁻ a, f a ∂μ) < ∞ := by
  simp [has_finite_integral_iff_norm]
#align
  measure_theory.has_finite_integral_iff_of_nnreal MeasureTheory.has_finite_integral_iff_of_nnreal

theorem HasFiniteIntegral.mono {f : α → β} {g : α → γ} (hg : HasFiniteIntegral g μ)
    (h : ∀ᵐ a ∂μ, ‖f a‖ ≤ ‖g a‖) : HasFiniteIntegral f μ :=
  by
  simp only [has_finite_integral_iff_norm] at *
  calc
    (∫⁻ a, Ennreal.ofReal ‖f a‖ ∂μ) ≤ ∫⁻ a : α, Ennreal.ofReal ‖g a‖ ∂μ :=
      lintegral_mono_ae (h.mono fun a h => of_real_le_of_real h)
    _ < ∞ := hg
    
#align measure_theory.has_finite_integral.mono MeasureTheory.HasFiniteIntegral.mono

theorem HasFiniteIntegral.mono' {f : α → β} {g : α → ℝ} (hg : HasFiniteIntegral g μ)
    (h : ∀ᵐ a ∂μ, ‖f a‖ ≤ g a) : HasFiniteIntegral f μ :=
  hg.mono <| h.mono fun x hx => le_trans hx (le_abs_self _)
#align measure_theory.has_finite_integral.mono' MeasureTheory.HasFiniteIntegral.mono'

theorem HasFiniteIntegral.congr' {f : α → β} {g : α → γ} (hf : HasFiniteIntegral f μ)
    (h : ∀ᵐ a ∂μ, ‖f a‖ = ‖g a‖) : HasFiniteIntegral g μ :=
  hf.mono <| eventually_eq.le <| EventuallyEq.symm h
#align measure_theory.has_finite_integral.congr' MeasureTheory.HasFiniteIntegral.congr'

theorem has_finite_integral_congr' {f : α → β} {g : α → γ} (h : ∀ᵐ a ∂μ, ‖f a‖ = ‖g a‖) :
    HasFiniteIntegral f μ ↔ HasFiniteIntegral g μ :=
  ⟨fun hf => hf.congr' h, fun hg => hg.congr' <| EventuallyEq.symm h⟩
#align measure_theory.has_finite_integral_congr' MeasureTheory.has_finite_integral_congr'

theorem HasFiniteIntegral.congr {f g : α → β} (hf : HasFiniteIntegral f μ) (h : f =ᵐ[μ] g) :
    HasFiniteIntegral g μ :=
  hf.congr' <| h.fun_comp norm
#align measure_theory.has_finite_integral.congr MeasureTheory.HasFiniteIntegral.congr

theorem has_finite_integral_congr {f g : α → β} (h : f =ᵐ[μ] g) :
    HasFiniteIntegral f μ ↔ HasFiniteIntegral g μ :=
  has_finite_integral_congr' <| h.fun_comp norm
#align measure_theory.has_finite_integral_congr MeasureTheory.has_finite_integral_congr

theorem has_finite_integral_const_iff {c : β} :
    HasFiniteIntegral (fun x : α => c) μ ↔ c = 0 ∨ μ univ < ∞ := by
  simp [has_finite_integral, lintegral_const, lt_top_iff_ne_top, or_iff_not_imp_left]
#align measure_theory.has_finite_integral_const_iff MeasureTheory.has_finite_integral_const_iff

theorem hasFiniteIntegralConst [IsFiniteMeasure μ] (c : β) : HasFiniteIntegral (fun x : α => c) μ :=
  has_finite_integral_const_iff.2 (Or.inr <| measure_lt_top _ _)
#align measure_theory.has_finite_integral_const MeasureTheory.hasFiniteIntegralConst

theorem hasFiniteIntegralOfBounded [IsFiniteMeasure μ] {f : α → β} {C : ℝ}
    (hC : ∀ᵐ a ∂μ, ‖f a‖ ≤ C) : HasFiniteIntegral f μ :=
  (hasFiniteIntegralConst C).mono' hC
#align measure_theory.has_finite_integral_of_bounded MeasureTheory.hasFiniteIntegralOfBounded

theorem HasFiniteIntegral.monoMeasure {f : α → β} (h : HasFiniteIntegral f ν) (hμ : μ ≤ ν) :
    HasFiniteIntegral f μ :=
  lt_of_le_of_lt (lintegral_mono' hμ le_rfl) h
#align measure_theory.has_finite_integral.mono_measure MeasureTheory.HasFiniteIntegral.monoMeasure

theorem HasFiniteIntegral.addMeasure {f : α → β} (hμ : HasFiniteIntegral f μ)
    (hν : HasFiniteIntegral f ν) : HasFiniteIntegral f (μ + ν) :=
  by
  simp only [has_finite_integral, lintegral_add_measure] at *
  exact add_lt_top.2 ⟨hμ, hν⟩
#align measure_theory.has_finite_integral.add_measure MeasureTheory.HasFiniteIntegral.addMeasure

theorem HasFiniteIntegral.leftOfAddMeasure {f : α → β} (h : HasFiniteIntegral f (μ + ν)) :
    HasFiniteIntegral f μ :=
  h.monoMeasure <| measure.le_add_right <| le_rfl
#align
  measure_theory.has_finite_integral.left_of_add_measure MeasureTheory.HasFiniteIntegral.leftOfAddMeasure

theorem HasFiniteIntegral.rightOfAddMeasure {f : α → β} (h : HasFiniteIntegral f (μ + ν)) :
    HasFiniteIntegral f ν :=
  h.monoMeasure <| measure.le_add_left <| le_rfl
#align
  measure_theory.has_finite_integral.right_of_add_measure MeasureTheory.HasFiniteIntegral.rightOfAddMeasure

@[simp]
theorem has_finite_integral_add_measure {f : α → β} :
    HasFiniteIntegral f (μ + ν) ↔ HasFiniteIntegral f μ ∧ HasFiniteIntegral f ν :=
  ⟨fun h => ⟨h.leftOfAddMeasure, h.rightOfAddMeasure⟩, fun h => h.1.addMeasure h.2⟩
#align measure_theory.has_finite_integral_add_measure MeasureTheory.has_finite_integral_add_measure

theorem HasFiniteIntegral.smulMeasure {f : α → β} (h : HasFiniteIntegral f μ) {c : ℝ≥0∞}
    (hc : c ≠ ∞) : HasFiniteIntegral f (c • μ) :=
  by
  simp only [has_finite_integral, lintegral_smul_measure] at *
  exact mul_lt_top hc h.ne
#align measure_theory.has_finite_integral.smul_measure MeasureTheory.HasFiniteIntegral.smulMeasure

@[simp]
theorem hasFiniteIntegralZeroMeasure {m : MeasurableSpace α} (f : α → β) :
    HasFiniteIntegral f (0 : Measure α) := by
  simp only [has_finite_integral, lintegral_zero_measure, WithTop.zero_lt_top]
#align measure_theory.has_finite_integral_zero_measure MeasureTheory.hasFiniteIntegralZeroMeasure

variable (α β μ)

@[simp]
theorem hasFiniteIntegralZero : HasFiniteIntegral (fun a : α => (0 : β)) μ := by
  simp [has_finite_integral]
#align measure_theory.has_finite_integral_zero MeasureTheory.hasFiniteIntegralZero

variable {α β μ}

theorem HasFiniteIntegral.neg {f : α → β} (hfi : HasFiniteIntegral f μ) :
    HasFiniteIntegral (-f) μ := by simpa [has_finite_integral] using hfi
#align measure_theory.has_finite_integral.neg MeasureTheory.HasFiniteIntegral.neg

@[simp]
theorem has_finite_integral_neg_iff {f : α → β} :
    HasFiniteIntegral (-f) μ ↔ HasFiniteIntegral f μ :=
  ⟨fun h => neg_neg f ▸ h.neg, HasFiniteIntegral.neg⟩
#align measure_theory.has_finite_integral_neg_iff MeasureTheory.has_finite_integral_neg_iff

theorem HasFiniteIntegral.norm {f : α → β} (hfi : HasFiniteIntegral f μ) :
    HasFiniteIntegral (fun a => ‖f a‖) μ :=
  by
  have eq : (fun a => (nnnorm ‖f a‖ : ℝ≥0∞)) = fun a => (‖f a‖₊ : ℝ≥0∞) :=
    by
    funext
    rw [nnnorm_norm]
  rwa [has_finite_integral, Eq]
#align measure_theory.has_finite_integral.norm MeasureTheory.HasFiniteIntegral.norm

theorem has_finite_integral_norm_iff (f : α → β) :
    HasFiniteIntegral (fun a => ‖f a‖) μ ↔ HasFiniteIntegral f μ :=
  has_finite_integral_congr' <| eventually_of_forall fun x => norm_norm (f x)
#align measure_theory.has_finite_integral_norm_iff MeasureTheory.has_finite_integral_norm_iff

theorem hasFiniteIntegralToRealOfLintegralNeTop {f : α → ℝ≥0∞} (hf : (∫⁻ x, f x ∂μ) ≠ ∞) :
    HasFiniteIntegral (fun x => (f x).toReal) μ :=
  by
  have :
    ∀ x,
      (‖(f x).toReal‖₊ : ℝ≥0∞) = @coe ℝ≥0 ℝ≥0∞ _ (⟨(f x).toReal, Ennreal.to_real_nonneg⟩ : ℝ≥0) :=
    by
    intro x
    rw [Real.nnnorm_of_nonneg]
  simp_rw [has_finite_integral, this]
  refine' lt_of_le_of_lt (lintegral_mono fun x => _) (lt_top_iff_ne_top.2 hf)
  by_cases hfx : f x = ∞
  · simp [hfx]
  · lift f x to ℝ≥0 using hfx with fx
    simp [← h]
#align
  measure_theory.has_finite_integral_to_real_of_lintegral_ne_top MeasureTheory.hasFiniteIntegralToRealOfLintegralNeTop

theorem isFiniteMeasureWithDensityOfReal {f : α → ℝ} (hfi : HasFiniteIntegral f μ) :
    IsFiniteMeasure (μ.withDensity fun x => Ennreal.ofReal <| f x) :=
  by
  refine' is_finite_measure_with_density ((lintegral_mono fun x => _).trans_lt hfi).Ne
  exact Real.of_real_le_ennnorm (f x)
#align
  measure_theory.is_finite_measure_with_density_of_real MeasureTheory.isFiniteMeasureWithDensityOfReal

section DominatedConvergence

variable {F : ℕ → α → β} {f : α → β} {bound : α → ℝ}

theorem all_ae_of_real_F_le_bound (h : ∀ n, ∀ᵐ a ∂μ, ‖F n a‖ ≤ bound a) :
    ∀ n, ∀ᵐ a ∂μ, Ennreal.ofReal ‖F n a‖ ≤ Ennreal.ofReal (bound a) := fun n =>
  (h n).mono fun a h => Ennreal.of_real_le_of_real h
#align measure_theory.all_ae_of_real_F_le_bound MeasureTheory.all_ae_of_real_F_le_bound

theorem all_ae_tendsto_of_real_norm (h : ∀ᵐ a ∂μ, Tendsto (fun n => F n a) atTop <| 𝓝 <| f a) :
    ∀ᵐ a ∂μ, Tendsto (fun n => Ennreal.ofReal ‖F n a‖) atTop <| 𝓝 <| Ennreal.ofReal ‖f a‖ :=
  h.mono fun a h => tendsto_of_real <| Tendsto.comp (Continuous.tendsto continuous_norm _) h
#align measure_theory.all_ae_tendsto_of_real_norm MeasureTheory.all_ae_tendsto_of_real_norm

theorem all_ae_of_real_f_le_bound (h_bound : ∀ n, ∀ᵐ a ∂μ, ‖F n a‖ ≤ bound a)
    (h_lim : ∀ᵐ a ∂μ, Tendsto (fun n => F n a) atTop (𝓝 (f a))) :
    ∀ᵐ a ∂μ, Ennreal.ofReal ‖f a‖ ≤ Ennreal.ofReal (bound a) :=
  by
  have F_le_bound := all_ae_of_real_F_le_bound h_bound
  rw [← ae_all_iff] at F_le_bound
  apply F_le_bound.mp ((all_ae_tendsto_of_real_norm h_lim).mono _)
  intro a tendsto_norm F_le_bound
  exact le_of_tendsto' tendsto_norm F_le_bound
#align measure_theory.all_ae_of_real_f_le_bound MeasureTheory.all_ae_of_real_f_le_bound

theorem hasFiniteIntegralOfDominatedConvergence {F : ℕ → α → β} {f : α → β} {bound : α → ℝ}
    (bound_has_finite_integral : HasFiniteIntegral bound μ)
    (h_bound : ∀ n, ∀ᵐ a ∂μ, ‖F n a‖ ≤ bound a)
    (h_lim : ∀ᵐ a ∂μ, Tendsto (fun n => F n a) atTop (𝓝 (f a))) : HasFiniteIntegral f μ :=
  by
  /- `‖F n a‖ ≤ bound a` and `‖F n a‖ --> ‖f a‖` implies `‖f a‖ ≤ bound a`,
    and so `∫ ‖f‖ ≤ ∫ bound < ∞` since `bound` is has_finite_integral -/
  rw [has_finite_integral_iff_norm]
  calc
    (∫⁻ a, Ennreal.ofReal ‖f a‖ ∂μ) ≤ ∫⁻ a, Ennreal.ofReal (bound a) ∂μ :=
      lintegral_mono_ae <| all_ae_of_real_f_le_bound h_bound h_lim
    _ < ∞ := by
      rw [← has_finite_integral_iff_of_real]
      · exact bound_has_finite_integral
      exact (h_bound 0).mono fun a h => le_trans (norm_nonneg _) h
    
#align
  measure_theory.has_finite_integral_of_dominated_convergence MeasureTheory.hasFiniteIntegralOfDominatedConvergence

theorem tendsto_lintegral_norm_of_dominated_convergence {F : ℕ → α → β} {f : α → β} {bound : α → ℝ}
    (F_measurable : ∀ n, AeStronglyMeasurable (F n) μ)
    (bound_has_finite_integral : HasFiniteIntegral bound μ)
    (h_bound : ∀ n, ∀ᵐ a ∂μ, ‖F n a‖ ≤ bound a)
    (h_lim : ∀ᵐ a ∂μ, Tendsto (fun n => F n a) atTop (𝓝 (f a))) :
    Tendsto (fun n => ∫⁻ a, Ennreal.ofReal ‖F n a - f a‖ ∂μ) atTop (𝓝 0) :=
  by
  have f_measurable : AeStronglyMeasurable f μ :=
    aeStronglyMeasurableOfTendstoAe _ F_measurable h_lim
  let b a := 2 * Ennreal.ofReal (bound a)
  /- `‖F n a‖ ≤ bound a` and `F n a --> f a` implies `‖f a‖ ≤ bound a`, and thus by the
    triangle inequality, have `‖F n a - f a‖ ≤ 2 * (bound a). -/
  have hb : ∀ n, ∀ᵐ a ∂μ, Ennreal.ofReal ‖F n a - f a‖ ≤ b a :=
    by
    intro n
    filter_upwards [all_ae_of_real_F_le_bound h_bound n,
      all_ae_of_real_f_le_bound h_bound h_lim] with a h₁ h₂
    calc
      Ennreal.ofReal ‖F n a - f a‖ ≤ Ennreal.ofReal ‖F n a‖ + Ennreal.ofReal ‖f a‖ :=
        by
        rw [← Ennreal.of_real_add]
        apply of_real_le_of_real
        · apply norm_sub_le; · exact norm_nonneg _; · exact norm_nonneg _
      _ ≤ Ennreal.ofReal (bound a) + Ennreal.ofReal (bound a) := add_le_add h₁ h₂
      _ = b a := by rw [← two_mul]
      
  -- On the other hand, `F n a --> f a` implies that `‖F n a - f a‖ --> 0`
  have h : ∀ᵐ a ∂μ, Tendsto (fun n => Ennreal.ofReal ‖F n a - f a‖) atTop (𝓝 0) :=
    by
    rw [← Ennreal.of_real_zero]
    refine' h_lim.mono fun a h => (continuous_of_real.tendsto _).comp _
    rwa [← tendsto_iff_norm_tendsto_zero]
  /- Therefore, by the dominated convergence theorem for nonnegative integration, have
    ` ∫ ‖f a - F n a‖ --> 0 ` -/
  suffices h : tendsto (fun n => ∫⁻ a, Ennreal.ofReal ‖F n a - f a‖ ∂μ) at_top (𝓝 (∫⁻ a : α, 0 ∂μ))
  · rwa [lintegral_zero] at h
  -- Using the dominated convergence theorem.
  refine' tendsto_lintegral_of_dominated_convergence' _ _ hb _ _
  -- Show `λa, ‖f a - F n a‖` is almost everywhere measurable for all `n`
  ·
    exact fun n =>
      measurable_of_real.comp_ae_measurable ((F_measurable n).sub f_measurable).norm.AeMeasurable
  -- Show `2 * bound` is has_finite_integral
  · rw [has_finite_integral_iff_of_real] at bound_has_finite_integral
    ·
      calc
        (∫⁻ a, b a ∂μ) = 2 * ∫⁻ a, Ennreal.ofReal (bound a) ∂μ :=
          by
          rw [lintegral_const_mul']
          exact coe_ne_top
        _ ≠ ∞ := mul_ne_top coe_ne_top bound_has_finite_integral.ne
        
    filter_upwards [h_bound 0] with _ h using le_trans (norm_nonneg _) h
  -- Show `‖f a - F n a‖ --> 0`
  · exact h
#align
  measure_theory.tendsto_lintegral_norm_of_dominated_convergence MeasureTheory.tendsto_lintegral_norm_of_dominated_convergence

end DominatedConvergence

section PosPart

/-! Lemmas used for defining the positive part of a `L¹` function -/


theorem HasFiniteIntegral.maxZero {f : α → ℝ} (hf : HasFiniteIntegral f μ) :
    HasFiniteIntegral (fun a => max (f a) 0) μ :=
  hf.mono <| eventually_of_forall fun x => by simp [abs_le, le_abs_self]
#align measure_theory.has_finite_integral.max_zero MeasureTheory.HasFiniteIntegral.maxZero

theorem HasFiniteIntegral.minZero {f : α → ℝ} (hf : HasFiniteIntegral f μ) :
    HasFiniteIntegral (fun a => min (f a) 0) μ :=
  hf.mono <|
    eventually_of_forall fun x => by
      simp [abs_le, neg_le, neg_le_abs_self, abs_eq_max_neg, le_total]
#align measure_theory.has_finite_integral.min_zero MeasureTheory.HasFiniteIntegral.minZero

end PosPart

section NormedSpace

variable {𝕜 : Type _} [NormedField 𝕜] [NormedSpace 𝕜 β]

theorem HasFiniteIntegral.smul (c : 𝕜) {f : α → β} :
    HasFiniteIntegral f μ → HasFiniteIntegral (c • f) μ :=
  by
  simp only [has_finite_integral]; intro hfi
  calc
    (∫⁻ a : α, ‖c • f a‖₊ ∂μ) = ∫⁻ a : α, ‖c‖₊ * ‖f a‖₊ ∂μ := by
      simp only [nnnorm_smul, Ennreal.coe_mul]
    _ < ∞ := by
      rw [lintegral_const_mul']
      exacts[mul_lt_top coe_ne_top hfi.ne, coe_ne_top]
    
#align measure_theory.has_finite_integral.smul MeasureTheory.HasFiniteIntegral.smul

theorem has_finite_integral_smul_iff {c : 𝕜} (hc : c ≠ 0) (f : α → β) :
    HasFiniteIntegral (c • f) μ ↔ HasFiniteIntegral f μ :=
  by
  constructor
  · intro h
    simpa only [smul_smul, inv_mul_cancel hc, one_smul] using h.smul c⁻¹
  exact has_finite_integral.smul _
#align measure_theory.has_finite_integral_smul_iff MeasureTheory.has_finite_integral_smul_iff

theorem HasFiniteIntegral.constMul {f : α → ℝ} (h : HasFiniteIntegral f μ) (c : ℝ) :
    HasFiniteIntegral (fun x => c * f x) μ :=
  (HasFiniteIntegral.smul c h : _)
#align measure_theory.has_finite_integral.const_mul MeasureTheory.HasFiniteIntegral.constMul

theorem HasFiniteIntegral.mulConst {f : α → ℝ} (h : HasFiniteIntegral f μ) (c : ℝ) :
    HasFiniteIntegral (fun x => f x * c) μ := by simp_rw [mul_comm, h.const_mul _]
#align measure_theory.has_finite_integral.mul_const MeasureTheory.HasFiniteIntegral.mulConst

end NormedSpace

/-! ### The predicate `integrable` -/


-- variables [measurable_space β] [measurable_space γ] [measurable_space δ]
/-- `integrable f μ` means that `f` is measurable and that the integral `∫⁻ a, ‖f a‖ ∂μ` is finite.
  `integrable f` means `integrable f volume`. -/
def Integrable {α} {m : MeasurableSpace α} (f : α → β)
    (μ : Measure α := by exact MeasureTheory.MeasureSpace.volume) : Prop :=
  AeStronglyMeasurable f μ ∧ HasFiniteIntegral f μ
#align measure_theory.integrable MeasureTheory.Integrable

theorem mem_ℒp_one_iff_integrable {f : α → β} : Memℒp f 1 μ ↔ Integrable f μ := by
  simp_rw [integrable, has_finite_integral, mem_ℒp, snorm_one_eq_lintegral_nnnorm]
#align measure_theory.mem_ℒp_one_iff_integrable MeasureTheory.mem_ℒp_one_iff_integrable

theorem Integrable.aeStronglyMeasurable {f : α → β} (hf : Integrable f μ) :
    AeStronglyMeasurable f μ :=
  hf.1
#align
  measure_theory.integrable.ae_strongly_measurable MeasureTheory.Integrable.aeStronglyMeasurable

theorem Integrable.aeMeasurable [MeasurableSpace β] [BorelSpace β] {f : α → β}
    (hf : Integrable f μ) : AeMeasurable f μ :=
  hf.AeStronglyMeasurable.AeMeasurable
#align measure_theory.integrable.ae_measurable MeasureTheory.Integrable.aeMeasurable

theorem Integrable.hasFiniteIntegral {f : α → β} (hf : Integrable f μ) : HasFiniteIntegral f μ :=
  hf.2
#align measure_theory.integrable.has_finite_integral MeasureTheory.Integrable.hasFiniteIntegral

theorem Integrable.mono {f : α → β} {g : α → γ} (hg : Integrable g μ)
    (hf : AeStronglyMeasurable f μ) (h : ∀ᵐ a ∂μ, ‖f a‖ ≤ ‖g a‖) : Integrable f μ :=
  ⟨hf, hg.HasFiniteIntegral.mono h⟩
#align measure_theory.integrable.mono MeasureTheory.Integrable.mono

theorem Integrable.mono' {f : α → β} {g : α → ℝ} (hg : Integrable g μ)
    (hf : AeStronglyMeasurable f μ) (h : ∀ᵐ a ∂μ, ‖f a‖ ≤ g a) : Integrable f μ :=
  ⟨hf, hg.HasFiniteIntegral.mono' h⟩
#align measure_theory.integrable.mono' MeasureTheory.Integrable.mono'

theorem Integrable.congr' {f : α → β} {g : α → γ} (hf : Integrable f μ)
    (hg : AeStronglyMeasurable g μ) (h : ∀ᵐ a ∂μ, ‖f a‖ = ‖g a‖) : Integrable g μ :=
  ⟨hg, hf.HasFiniteIntegral.congr' h⟩
#align measure_theory.integrable.congr' MeasureTheory.Integrable.congr'

theorem integrable_congr' {f : α → β} {g : α → γ} (hf : AeStronglyMeasurable f μ)
    (hg : AeStronglyMeasurable g μ) (h : ∀ᵐ a ∂μ, ‖f a‖ = ‖g a‖) :
    Integrable f μ ↔ Integrable g μ :=
  ⟨fun h2f => h2f.congr' hg h, fun h2g => h2g.congr' hf <| EventuallyEq.symm h⟩
#align measure_theory.integrable_congr' MeasureTheory.integrable_congr'

theorem Integrable.congr {f g : α → β} (hf : Integrable f μ) (h : f =ᵐ[μ] g) : Integrable g μ :=
  ⟨hf.1.congr h, hf.2.congr h⟩
#align measure_theory.integrable.congr MeasureTheory.Integrable.congr

theorem integrable_congr {f g : α → β} (h : f =ᵐ[μ] g) : Integrable f μ ↔ Integrable g μ :=
  ⟨fun hf => hf.congr h, fun hg => hg.congr h.symm⟩
#align measure_theory.integrable_congr MeasureTheory.integrable_congr

theorem integrable_const_iff {c : β} : Integrable (fun x : α => c) μ ↔ c = 0 ∨ μ univ < ∞ :=
  by
  have : ae_strongly_measurable (fun x : α => c) μ := ae_strongly_measurable_const
  rw [integrable, and_iff_right this, has_finite_integral_const_iff]
#align measure_theory.integrable_const_iff MeasureTheory.integrable_const_iff

theorem integrableConst [IsFiniteMeasure μ] (c : β) : Integrable (fun x : α => c) μ :=
  integrable_const_iff.2 <| Or.inr <| measure_lt_top _ _
#align measure_theory.integrable_const MeasureTheory.integrableConst

theorem Memℒp.integrableNormRpow {f : α → β} {p : ℝ≥0∞} (hf : Memℒp f p μ) (hp_ne_zero : p ≠ 0)
    (hp_ne_top : p ≠ ∞) : Integrable (fun x : α => ‖f x‖ ^ p.toReal) μ :=
  by
  rw [← mem_ℒp_one_iff_integrable]
  exact hf.norm_rpow hp_ne_zero hp_ne_top
#align measure_theory.mem_ℒp.integrable_norm_rpow MeasureTheory.Memℒp.integrableNormRpow

theorem Memℒp.integrableNormRpow' [IsFiniteMeasure μ] {f : α → β} {p : ℝ≥0∞} (hf : Memℒp f p μ) :
    Integrable (fun x : α => ‖f x‖ ^ p.toReal) μ :=
  by
  by_cases h_zero : p = 0
  · simp [h_zero, integrable_const]
  by_cases h_top : p = ∞
  · simp [h_top, integrable_const]
  exact hf.integrable_norm_rpow h_zero h_top
#align measure_theory.mem_ℒp.integrable_norm_rpow' MeasureTheory.Memℒp.integrableNormRpow'

theorem Integrable.monoMeasure {f : α → β} (h : Integrable f ν) (hμ : μ ≤ ν) : Integrable f μ :=
  ⟨h.AeStronglyMeasurable.monoMeasure hμ, h.HasFiniteIntegral.monoMeasure hμ⟩
#align measure_theory.integrable.mono_measure MeasureTheory.Integrable.monoMeasure

theorem Integrable.ofMeasureLeSmul {μ' : Measure α} (c : ℝ≥0∞) (hc : c ≠ ∞) (hμ'_le : μ' ≤ c • μ)
    {f : α → β} (hf : Integrable f μ) : Integrable f μ' :=
  by
  rw [← mem_ℒp_one_iff_integrable] at hf⊢
  exact hf.of_measure_le_smul c hc hμ'_le
#align measure_theory.integrable.of_measure_le_smul MeasureTheory.Integrable.ofMeasureLeSmul

theorem Integrable.addMeasure {f : α → β} (hμ : Integrable f μ) (hν : Integrable f ν) :
    Integrable f (μ + ν) :=
  by
  simp_rw [← mem_ℒp_one_iff_integrable] at hμ hν⊢
  refine' ⟨hμ.ae_strongly_measurable.add_measure hν.ae_strongly_measurable, _⟩
  rw [snorm_one_add_measure, Ennreal.add_lt_top]
  exact ⟨hμ.snorm_lt_top, hν.snorm_lt_top⟩
#align measure_theory.integrable.add_measure MeasureTheory.Integrable.addMeasure

theorem Integrable.leftOfAddMeasure {f : α → β} (h : Integrable f (μ + ν)) : Integrable f μ :=
  by
  rw [← mem_ℒp_one_iff_integrable] at h⊢
  exact h.left_of_add_measure
#align measure_theory.integrable.left_of_add_measure MeasureTheory.Integrable.leftOfAddMeasure

theorem Integrable.rightOfAddMeasure {f : α → β} (h : Integrable f (μ + ν)) : Integrable f ν :=
  by
  rw [← mem_ℒp_one_iff_integrable] at h⊢
  exact h.right_of_add_measure
#align measure_theory.integrable.right_of_add_measure MeasureTheory.Integrable.rightOfAddMeasure

@[simp]
theorem integrable_add_measure {f : α → β} :
    Integrable f (μ + ν) ↔ Integrable f μ ∧ Integrable f ν :=
  ⟨fun h => ⟨h.leftOfAddMeasure, h.rightOfAddMeasure⟩, fun h => h.1.addMeasure h.2⟩
#align measure_theory.integrable_add_measure MeasureTheory.integrable_add_measure

@[simp]
theorem integrableZeroMeasure {m : MeasurableSpace α} {f : α → β} : Integrable f (0 : Measure α) :=
  ⟨aeStronglyMeasurableZeroMeasure f, hasFiniteIntegralZeroMeasure f⟩
#align measure_theory.integrable_zero_measure MeasureTheory.integrableZeroMeasure

theorem integrable_finset_sum_measure {ι} {m : MeasurableSpace α} {f : α → β} {μ : ι → Measure α}
    {s : Finset ι} : Integrable f (∑ i in s, μ i) ↔ ∀ i ∈ s, Integrable f (μ i) := by
  induction s using Finset.induction_on <;> simp [*]
#align measure_theory.integrable_finset_sum_measure MeasureTheory.integrable_finset_sum_measure

theorem Integrable.smulMeasure {f : α → β} (h : Integrable f μ) {c : ℝ≥0∞} (hc : c ≠ ∞) :
    Integrable f (c • μ) := by
  rw [← mem_ℒp_one_iff_integrable] at h⊢
  exact h.smul_measure hc
#align measure_theory.integrable.smul_measure MeasureTheory.Integrable.smulMeasure

theorem integrable_smul_measure {f : α → β} {c : ℝ≥0∞} (h₁ : c ≠ 0) (h₂ : c ≠ ∞) :
    Integrable f (c • μ) ↔ Integrable f μ :=
  ⟨fun h => by
    simpa only [smul_smul, Ennreal.inv_mul_cancel h₁ h₂, one_smul] using
      h.smul_measure (Ennreal.inv_ne_top.2 h₁),
    fun h => h.smulMeasure h₂⟩
#align measure_theory.integrable_smul_measure MeasureTheory.integrable_smul_measure

theorem integrable_inv_smul_measure {f : α → β} {c : ℝ≥0∞} (h₁ : c ≠ 0) (h₂ : c ≠ ∞) :
    Integrable f (c⁻¹ • μ) ↔ Integrable f μ :=
  integrable_smul_measure (by simpa using h₂) (by simpa using h₁)
#align measure_theory.integrable_inv_smul_measure MeasureTheory.integrable_inv_smul_measure

theorem Integrable.toAverage {f : α → β} (h : Integrable f μ) : Integrable f ((μ univ)⁻¹ • μ) :=
  by
  rcases eq_or_ne μ 0 with (rfl | hne)
  · rwa [smul_zero]
  · apply h.smul_measure
    simpa
#align measure_theory.integrable.to_average MeasureTheory.Integrable.toAverage

theorem integrable_average [IsFiniteMeasure μ] {f : α → β} :
    Integrable f ((μ univ)⁻¹ • μ) ↔ Integrable f μ :=
  ((eq_or_ne μ 0).byCases fun h => by simp [h]) fun h =>
    integrable_smul_measure (Ennreal.inv_ne_zero.2 <| measure_ne_top _ _)
      (Ennreal.inv_ne_top.2 <| mt Measure.measure_univ_eq_zero.1 h)
#align measure_theory.integrable_average MeasureTheory.integrable_average

theorem integrable_map_measure {f : α → δ} {g : δ → β}
    (hg : AeStronglyMeasurable g (Measure.map f μ)) (hf : AeMeasurable f μ) :
    Integrable g (Measure.map f μ) ↔ Integrable (g ∘ f) μ :=
  by
  simp_rw [← mem_ℒp_one_iff_integrable]
  exact mem_ℒp_map_measure_iff hg hf
#align measure_theory.integrable_map_measure MeasureTheory.integrable_map_measure

theorem Integrable.compAeMeasurable {f : α → δ} {g : δ → β} (hg : Integrable g (Measure.map f μ))
    (hf : AeMeasurable f μ) : Integrable (g ∘ f) μ :=
  (integrable_map_measure hg.AeStronglyMeasurable hf).mp hg
#align measure_theory.integrable.comp_ae_measurable MeasureTheory.Integrable.compAeMeasurable

theorem Integrable.compMeasurable {f : α → δ} {g : δ → β} (hg : Integrable g (Measure.map f μ))
    (hf : Measurable f) : Integrable (g ∘ f) μ :=
  hg.compAeMeasurable hf.AeMeasurable
#align measure_theory.integrable.comp_measurable MeasureTheory.Integrable.compMeasurable

theorem MeasurableEmbedding.integrable_map_iff {f : α → δ} (hf : MeasurableEmbedding f)
    {g : δ → β} : Integrable g (Measure.map f μ) ↔ Integrable (g ∘ f) μ :=
  by
  simp_rw [← mem_ℒp_one_iff_integrable]
  exact hf.mem_ℒp_map_measure_iff
#align measurable_embedding.integrable_map_iff MeasurableEmbedding.integrable_map_iff

theorem integrable_map_equiv (f : α ≃ᵐ δ) (g : δ → β) :
    Integrable g (Measure.map f μ) ↔ Integrable (g ∘ f) μ :=
  by
  simp_rw [← mem_ℒp_one_iff_integrable]
  exact f.mem_ℒp_map_measure_iff
#align measure_theory.integrable_map_equiv MeasureTheory.integrable_map_equiv

theorem MeasurePreserving.integrable_comp {ν : Measure δ} {g : δ → β} {f : α → δ}
    (hf : MeasurePreserving f μ ν) (hg : AeStronglyMeasurable g ν) :
    Integrable (g ∘ f) μ ↔ Integrable g ν :=
  by
  rw [← hf.map_eq] at hg⊢
  exact (integrable_map_measure hg hf.measurable.ae_measurable).symm
#align
  measure_theory.measure_preserving.integrable_comp MeasureTheory.MeasurePreserving.integrable_comp

theorem MeasurePreserving.integrable_comp_emb {f : α → δ} {ν} (h₁ : MeasurePreserving f μ ν)
    (h₂ : MeasurableEmbedding f) {g : δ → β} : Integrable (g ∘ f) μ ↔ Integrable g ν :=
  h₁.map_eq ▸ Iff.symm h₂.integrable_map_iff
#align
  measure_theory.measure_preserving.integrable_comp_emb MeasureTheory.MeasurePreserving.integrable_comp_emb

theorem lintegral_edist_lt_top {f g : α → β} (hf : Integrable f μ) (hg : Integrable g μ) :
    (∫⁻ a, edist (f a) (g a) ∂μ) < ∞ :=
  lt_of_le_of_lt (lintegral_edist_triangle hf.AeStronglyMeasurable aeStronglyMeasurableZero)
    (Ennreal.add_lt_top.2 <|
      by
      simp_rw [Pi.zero_apply, ← has_finite_integral_iff_edist]
      exact ⟨hf.has_finite_integral, hg.has_finite_integral⟩)
#align measure_theory.lintegral_edist_lt_top MeasureTheory.lintegral_edist_lt_top

variable (α β μ)

@[simp]
theorem integrableZero : Integrable (fun _ => (0 : β)) μ := by
  simp [integrable, ae_strongly_measurable_const]
#align measure_theory.integrable_zero MeasureTheory.integrableZero

variable {α β μ}

theorem Integrable.add' {f g : α → β} (hf : Integrable f μ) (hg : Integrable g μ) :
    HasFiniteIntegral (f + g) μ :=
  calc
    (∫⁻ a, ‖f a + g a‖₊ ∂μ) ≤ ∫⁻ a, ‖f a‖₊ + ‖g a‖₊ ∂μ :=
      lintegral_mono fun a => by exact_mod_cast nnnorm_add_le _ _
    _ = _ := lintegral_nnnorm_add_left hf.AeStronglyMeasurable _
    _ < ∞ := add_lt_top.2 ⟨hf.HasFiniteIntegral, hg.HasFiniteIntegral⟩
    
#align measure_theory.integrable.add' MeasureTheory.Integrable.add'

theorem Integrable.add {f g : α → β} (hf : Integrable f μ) (hg : Integrable g μ) :
    Integrable (f + g) μ :=
  ⟨hf.AeStronglyMeasurable.add hg.AeStronglyMeasurable, hf.add' hg⟩
#align measure_theory.integrable.add MeasureTheory.Integrable.add

theorem integrableFinsetSum' {ι} (s : Finset ι) {f : ι → α → β} (hf : ∀ i ∈ s, Integrable (f i) μ) :
    Integrable (∑ i in s, f i) μ :=
  Finset.sum_induction f (fun g => Integrable g μ) (fun _ _ => Integrable.add)
    (integrableZero _ _ _) hf
#align measure_theory.integrable_finset_sum' MeasureTheory.integrableFinsetSum'

theorem integrableFinsetSum {ι} (s : Finset ι) {f : ι → α → β} (hf : ∀ i ∈ s, Integrable (f i) μ) :
    Integrable (fun a => ∑ i in s, f i a) μ := by
  simpa only [← Finset.sum_apply] using integrable_finset_sum' s hf
#align measure_theory.integrable_finset_sum MeasureTheory.integrableFinsetSum

theorem Integrable.neg {f : α → β} (hf : Integrable f μ) : Integrable (-f) μ :=
  ⟨hf.AeStronglyMeasurable.neg, hf.HasFiniteIntegral.neg⟩
#align measure_theory.integrable.neg MeasureTheory.Integrable.neg

@[simp]
theorem integrable_neg_iff {f : α → β} : Integrable (-f) μ ↔ Integrable f μ :=
  ⟨fun h => neg_neg f ▸ h.neg, Integrable.neg⟩
#align measure_theory.integrable_neg_iff MeasureTheory.integrable_neg_iff

theorem Integrable.sub {f g : α → β} (hf : Integrable f μ) (hg : Integrable g μ) :
    Integrable (f - g) μ := by simpa only [sub_eq_add_neg] using hf.add hg.neg
#align measure_theory.integrable.sub MeasureTheory.Integrable.sub

theorem Integrable.norm {f : α → β} (hf : Integrable f μ) : Integrable (fun a => ‖f a‖) μ :=
  ⟨hf.AeStronglyMeasurable.norm, hf.HasFiniteIntegral.norm⟩
#align measure_theory.integrable.norm MeasureTheory.Integrable.norm

theorem Integrable.inf {β} [NormedLatticeAddCommGroup β] {f g : α → β} (hf : Integrable f μ)
    (hg : Integrable g μ) : Integrable (f ⊓ g) μ :=
  by
  rw [← mem_ℒp_one_iff_integrable] at hf hg⊢
  exact hf.inf hg
#align measure_theory.integrable.inf MeasureTheory.Integrable.inf

theorem Integrable.sup {β} [NormedLatticeAddCommGroup β] {f g : α → β} (hf : Integrable f μ)
    (hg : Integrable g μ) : Integrable (f ⊔ g) μ :=
  by
  rw [← mem_ℒp_one_iff_integrable] at hf hg⊢
  exact hf.sup hg
#align measure_theory.integrable.sup MeasureTheory.Integrable.sup

theorem Integrable.abs {β} [NormedLatticeAddCommGroup β] {f : α → β} (hf : Integrable f μ) :
    Integrable (fun a => |f a|) μ :=
  by
  rw [← mem_ℒp_one_iff_integrable] at hf⊢
  exact hf.abs
#align measure_theory.integrable.abs MeasureTheory.Integrable.abs

theorem Integrable.bddMul {F : Type _} [NormedDivisionRing F] {f g : α → F} (hint : Integrable g μ)
    (hm : AeStronglyMeasurable f μ) (hfbdd : ∃ C, ∀ x, ‖f x‖ ≤ C) :
    Integrable (fun x => f x * g x) μ :=
  by
  cases' isEmpty_or_nonempty α with hα hα
  · rw [μ.eq_zero_of_is_empty]
    exact integrable_zero_measure
  · refine' ⟨hm.mul hint.1, _⟩
    obtain ⟨C, hC⟩ := hfbdd
    have hCnonneg : 0 ≤ C := le_trans (norm_nonneg _) (hC hα.some)
    have : (fun x => ‖f x * g x‖₊) ≤ fun x => ⟨C, hCnonneg⟩ * ‖g x‖₊ :=
      by
      intro x
      simp only [nnnorm_mul]
      exact mul_le_mul_of_nonneg_right (hC x) (zero_le _)
    refine' lt_of_le_of_lt (lintegral_mono_nnreal this) _
    simp only [Ennreal.coe_mul]
    rw [lintegral_const_mul' _ _ Ennreal.coe_ne_top]
    exact Ennreal.mul_lt_top Ennreal.coe_ne_top (ne_of_lt hint.2)
#align measure_theory.integrable.bdd_mul MeasureTheory.Integrable.bddMul

theorem integrable_norm_iff {f : α → β} (hf : AeStronglyMeasurable f μ) :
    Integrable (fun a => ‖f a‖) μ ↔ Integrable f μ := by
  simp_rw [integrable, and_iff_right hf, and_iff_right hf.norm, has_finite_integral_norm_iff]
#align measure_theory.integrable_norm_iff MeasureTheory.integrable_norm_iff

theorem integrableOfNormSubLe {f₀ f₁ : α → β} {g : α → ℝ} (hf₁_m : AeStronglyMeasurable f₁ μ)
    (hf₀_i : Integrable f₀ μ) (hg_i : Integrable g μ) (h : ∀ᵐ a ∂μ, ‖f₀ a - f₁ a‖ ≤ g a) :
    Integrable f₁ μ :=
  haveI : ∀ᵐ a ∂μ, ‖f₁ a‖ ≤ ‖f₀ a‖ + g a := by
    apply h.mono
    intro a ha
    calc
      ‖f₁ a‖ ≤ ‖f₀ a‖ + ‖f₀ a - f₁ a‖ := norm_le_insert _ _
      _ ≤ ‖f₀ a‖ + g a := add_le_add_left ha _
      
  integrable.mono' (hf₀_i.norm.add hg_i) hf₁_m this
#align measure_theory.integrable_of_norm_sub_le MeasureTheory.integrableOfNormSubLe

theorem Integrable.prodMk {f : α → β} {g : α → γ} (hf : Integrable f μ) (hg : Integrable g μ) :
    Integrable (fun x => (f x, g x)) μ :=
  ⟨hf.AeStronglyMeasurable.prod_mk hg.AeStronglyMeasurable,
    (hf.norm.add' hg.norm).mono <|
      eventually_of_forall fun x =>
        calc
          max ‖f x‖ ‖g x‖ ≤ ‖f x‖ + ‖g x‖ := max_le_add_of_nonneg (norm_nonneg _) (norm_nonneg _)
          _ ≤ ‖‖f x‖ + ‖g x‖‖ := le_abs_self _
          ⟩
#align measure_theory.integrable.prod_mk MeasureTheory.Integrable.prodMk

theorem Memℒp.integrable {q : ℝ≥0∞} (hq1 : 1 ≤ q) {f : α → β} [IsFiniteMeasure μ]
    (hfq : Memℒp f q μ) : Integrable f μ :=
  mem_ℒp_one_iff_integrable.mp (hfq.memℒpOfExponentLe hq1)
#align measure_theory.mem_ℒp.integrable MeasureTheory.Memℒp.integrable

theorem LipschitzWith.integrable_comp_iff_of_antilipschitz {K K'} {f : α → β} {g : β → γ}
    (hg : LipschitzWith K g) (hg' : AntilipschitzWith K' g) (g0 : g 0 = 0) :
    Integrable (g ∘ f) μ ↔ Integrable f μ := by
  simp [← mem_ℒp_one_iff_integrable, hg.mem_ℒp_comp_iff_of_antilipschitz hg' g0]
#align
  measure_theory.lipschitz_with.integrable_comp_iff_of_antilipschitz MeasureTheory.LipschitzWith.integrable_comp_iff_of_antilipschitz

theorem Integrable.realToNnreal {f : α → ℝ} (hf : Integrable f μ) :
    Integrable (fun x => ((f x).toNnreal : ℝ)) μ :=
  by
  refine'
    ⟨hf.ae_strongly_measurable.ae_measurable.real_to_nnreal.coeNnrealReal.AeStronglyMeasurable, _⟩
  rw [has_finite_integral_iff_norm]
  refine' lt_of_le_of_lt _ ((has_finite_integral_iff_norm _).1 hf.has_finite_integral)
  apply lintegral_mono
  intro x
  simp [Ennreal.of_real_le_of_real, abs_le, le_abs_self]
#align measure_theory.integrable.real_to_nnreal MeasureTheory.Integrable.realToNnreal

theorem of_real_to_real_ae_eq {f : α → ℝ≥0∞} (hf : ∀ᵐ x ∂μ, f x < ∞) :
    (fun x => Ennreal.ofReal (f x).toReal) =ᵐ[μ] f :=
  by
  filter_upwards [hf]
  intro x hx
  simp only [hx.ne, of_real_to_real, Ne.def, not_false_iff]
#align measure_theory.of_real_to_real_ae_eq MeasureTheory.of_real_to_real_ae_eq

theorem coe_to_nnreal_ae_eq {f : α → ℝ≥0∞} (hf : ∀ᵐ x ∂μ, f x < ∞) :
    (fun x => ((f x).toNnreal : ℝ≥0∞)) =ᵐ[μ] f :=
  by
  filter_upwards [hf]
  intro x hx
  simp only [hx.ne, Ne.def, not_false_iff, coe_to_nnreal]
#align measure_theory.coe_to_nnreal_ae_eq MeasureTheory.coe_to_nnreal_ae_eq

section

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E]

theorem integrable_with_density_iff_integrable_coe_smul {f : α → ℝ≥0} (hf : Measurable f)
    {g : α → E} :
    Integrable g (μ.withDensity fun x => f x) ↔ Integrable (fun x => (f x : ℝ) • g x) μ :=
  by
  by_cases H : ae_strongly_measurable (fun x : α => (f x : ℝ) • g x) μ
  · simp only [integrable, ae_strongly_measurable_with_density_iff hf, has_finite_integral, H,
      true_and_iff]
    rw [lintegral_with_density_eq_lintegral_mul₀' hf.coe_nnreal_ennreal.ae_measurable]
    · congr
      ext1 x
      simp only [nnnorm_smul, Nnreal.nnnorm_eq, coe_mul, Pi.mul_apply]
    · rw [ae_measurable_with_density_ennreal_iff hf]
      convert H.ennnorm
      ext1 x
      simp only [nnnorm_smul, Nnreal.nnnorm_eq, coe_mul]
  · simp only [integrable, ae_strongly_measurable_with_density_iff hf, H, false_and_iff]
#align
  measure_theory.integrable_with_density_iff_integrable_coe_smul MeasureTheory.integrable_with_density_iff_integrable_coe_smul

theorem integrable_with_density_iff_integrable_smul {f : α → ℝ≥0} (hf : Measurable f) {g : α → E} :
    Integrable g (μ.withDensity fun x => f x) ↔ Integrable (fun x => f x • g x) μ :=
  integrable_with_density_iff_integrable_coe_smul hf
#align
  measure_theory.integrable_with_density_iff_integrable_smul MeasureTheory.integrable_with_density_iff_integrable_smul

theorem integrable_with_density_iff_integrable_smul' {f : α → ℝ≥0∞} (hf : Measurable f)
    (hflt : ∀ᵐ x ∂μ, f x < ∞) {g : α → E} :
    Integrable g (μ.withDensity f) ↔ Integrable (fun x => (f x).toReal • g x) μ :=
  by
  rw [← with_density_congr_ae (coe_to_nnreal_ae_eq hflt),
    integrable_with_density_iff_integrable_smul]
  · rfl
  · exact hf.ennreal_to_nnreal
#align
  measure_theory.integrable_with_density_iff_integrable_smul' MeasureTheory.integrable_with_density_iff_integrable_smul'

theorem integrable_with_density_iff_integrable_coe_smul₀ {f : α → ℝ≥0} (hf : AeMeasurable f μ)
    {g : α → E} :
    Integrable g (μ.withDensity fun x => f x) ↔ Integrable (fun x => (f x : ℝ) • g x) μ :=
  calc
    Integrable g (μ.withDensity fun x => f x) ↔ Integrable g (μ.withDensity fun x => hf.mk f x) :=
      by
      suffices (fun x => (f x : ℝ≥0∞)) =ᵐ[μ] fun x => hf.mk f x by rw [with_density_congr_ae this]
      filter_upwards [hf.ae_eq_mk] with x hx
      simp [hx]
    _ ↔ Integrable (fun x => (hf.mk f x : ℝ) • g x) μ :=
      integrable_with_density_iff_integrable_coe_smul hf.measurable_mk
    _ ↔ Integrable (fun x => (f x : ℝ) • g x) μ :=
      by
      apply integrable_congr
      filter_upwards [hf.ae_eq_mk] with x hx
      simp [hx]
    
#align
  measure_theory.integrable_with_density_iff_integrable_coe_smul₀ MeasureTheory.integrable_with_density_iff_integrable_coe_smul₀

theorem integrable_with_density_iff_integrable_smul₀ {f : α → ℝ≥0} (hf : AeMeasurable f μ)
    {g : α → E} : Integrable g (μ.withDensity fun x => f x) ↔ Integrable (fun x => f x • g x) μ :=
  integrable_with_density_iff_integrable_coe_smul₀ hf
#align
  measure_theory.integrable_with_density_iff_integrable_smul₀ MeasureTheory.integrable_with_density_iff_integrable_smul₀

end

theorem integrable_with_density_iff {f : α → ℝ≥0∞} (hf : Measurable f) (hflt : ∀ᵐ x ∂μ, f x < ∞)
    {g : α → ℝ} : Integrable g (μ.withDensity f) ↔ Integrable (fun x => g x * (f x).toReal) μ :=
  by
  have : (fun x => g x * (f x).toReal) = fun x => (f x).toReal • g x := by simp [mul_comm]
  rw [this]
  exact integrable_with_density_iff_integrable_smul' hf hflt
#align measure_theory.integrable_with_density_iff MeasureTheory.integrable_with_density_iff

section

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E]

theorem memℒ1SmulOfL1WithDensity {f : α → ℝ≥0} (f_meas : Measurable f)
    (u : lp E 1 (μ.withDensity fun x => f x)) : Memℒp (fun x => f x • u x) 1 μ :=
  mem_ℒp_one_iff_integrable.2 <|
    (integrable_with_density_iff_integrable_smul f_meas).1 <|
      mem_ℒp_one_iff_integrable.1 (lp.memℒp u)
#align measure_theory.mem_ℒ1_smul_of_L1_with_density MeasureTheory.memℒ1SmulOfL1WithDensity

variable (μ)

/-- The map `u ↦ f • u` is an isometry between the `L^1` spaces for `μ.with_density f` and `μ`. -/
noncomputable def withDensitySmulLi {f : α → ℝ≥0} (f_meas : Measurable f) :
    lp E 1 (μ.withDensity fun x => f x) →ₗᵢ[ℝ] lp E 1 μ
    where
  toFun u := (memℒ1SmulOfL1WithDensity f_meas u).toLp _
  map_add' := by
    intro u v
    ext1
    filter_upwards [(mem_ℒ1_smul_of_L1_with_density f_meas u).coe_fn_to_Lp,
      (mem_ℒ1_smul_of_L1_with_density f_meas v).coe_fn_to_Lp,
      (mem_ℒ1_smul_of_L1_with_density f_meas (u + v)).coe_fn_to_Lp,
      Lp.coe_fn_add ((mem_ℒ1_smul_of_L1_with_density f_meas u).toLp _)
        ((mem_ℒ1_smul_of_L1_with_density f_meas v).toLp _),
      (ae_with_density_iff f_meas.coe_nnreal_ennreal).1 (Lp.coe_fn_add u v)]
    intro x hu hv huv h' h''
    rw [huv, h', Pi.add_apply, hu, hv]
    rcases eq_or_ne (f x) 0 with (hx | hx)
    · simp only [hx, zero_smul, add_zero]
    · rw [h'' _, Pi.add_apply, smul_add]
      simpa only [Ne.def, Ennreal.coe_eq_zero] using hx
  map_smul' := by
    intro r u
    ext1
    filter_upwards [(ae_with_density_iff f_meas.coe_nnreal_ennreal).1 (Lp.coe_fn_smul r u),
      (mem_ℒ1_smul_of_L1_with_density f_meas (r • u)).coe_fn_to_Lp,
      Lp.coe_fn_smul r ((mem_ℒ1_smul_of_L1_with_density f_meas u).toLp _),
      (mem_ℒ1_smul_of_L1_with_density f_meas u).coe_fn_to_Lp]
    intro x h h' h'' h'''
    rw [RingHom.id_apply, h', h'', Pi.smul_apply, h''']
    rcases eq_or_ne (f x) 0 with (hx | hx)
    · simp only [hx, zero_smul, smul_zero]
    · rw [h _, smul_comm, Pi.smul_apply]
      simpa only [Ne.def, Ennreal.coe_eq_zero] using hx
  norm_map' := by
    intro u
    simp only [snorm, LinearMap.coe_mk, Lp.norm_to_Lp, one_ne_zero, Ennreal.one_ne_top,
      Ennreal.one_to_real, if_false, snorm', Ennreal.rpow_one, _root_.div_one, Lp.norm_def]
    rw [lintegral_with_density_eq_lintegral_mul_non_measurable _ f_meas.coe_nnreal_ennreal
        (Filter.eventually_of_forall fun x => Ennreal.coe_lt_top)]
    congr 1
    apply lintegral_congr_ae
    filter_upwards [(mem_ℒ1_smul_of_L1_with_density f_meas u).coe_fn_to_Lp] with x hx
    rw [hx, Pi.mul_apply]
    change ↑‖(f x : ℝ) • u x‖₊ = ↑(f x) * ↑‖u x‖₊
    simp only [nnnorm_smul, Nnreal.nnnorm_eq, Ennreal.coe_mul]
#align measure_theory.with_density_smul_li MeasureTheory.withDensitySmulLi

@[simp]
theorem with_density_smul_li_apply {f : α → ℝ≥0} (f_meas : Measurable f)
    (u : lp E 1 (μ.withDensity fun x => f x)) :
    withDensitySmulLi μ f_meas u = (memℒ1SmulOfL1WithDensity f_meas u).toLp fun x => f x • u x :=
  rfl
#align measure_theory.with_density_smul_li_apply MeasureTheory.with_density_smul_li_apply

end

theorem memℒ1ToRealOfLintegralNeTop {f : α → ℝ≥0∞} (hfm : AeMeasurable f μ)
    (hfi : (∫⁻ x, f x ∂μ) ≠ ∞) : Memℒp (fun x => (f x).toReal) 1 μ :=
  by
  rw [mem_ℒp, snorm_one_eq_lintegral_nnnorm]
  exact
    ⟨(AeMeasurable.ennrealToReal hfm).AeStronglyMeasurable,
      has_finite_integral_to_real_of_lintegral_ne_top hfi⟩
#align measure_theory.mem_ℒ1_to_real_of_lintegral_ne_top MeasureTheory.memℒ1ToRealOfLintegralNeTop

theorem integrableToRealOfLintegralNeTop {f : α → ℝ≥0∞} (hfm : AeMeasurable f μ)
    (hfi : (∫⁻ x, f x ∂μ) ≠ ∞) : Integrable (fun x => (f x).toReal) μ :=
  mem_ℒp_one_iff_integrable.1 <| memℒ1ToRealOfLintegralNeTop hfm hfi
#align
  measure_theory.integrable_to_real_of_lintegral_ne_top MeasureTheory.integrableToRealOfLintegralNeTop

section PosPart

/-! ### Lemmas used for defining the positive part of a `L¹` function -/


theorem Integrable.posPart {f : α → ℝ} (hf : Integrable f μ) :
    Integrable (fun a => max (f a) 0) μ :=
  ⟨(hf.AeStronglyMeasurable.AeMeasurable.max aeMeasurableConst).AeStronglyMeasurable,
    hf.HasFiniteIntegral.maxZero⟩
#align measure_theory.integrable.pos_part MeasureTheory.Integrable.posPart

theorem Integrable.negPart {f : α → ℝ} (hf : Integrable f μ) :
    Integrable (fun a => max (-f a) 0) μ :=
  hf.neg.posPart
#align measure_theory.integrable.neg_part MeasureTheory.Integrable.negPart

end PosPart

section NormedSpace

variable {𝕜 : Type _} [NormedField 𝕜] [NormedSpace 𝕜 β]

theorem Integrable.smul (c : 𝕜) {f : α → β} (hf : Integrable f μ) : Integrable (c • f) μ :=
  ⟨hf.AeStronglyMeasurable.const_smul c, hf.HasFiniteIntegral.smul c⟩
#align measure_theory.integrable.smul MeasureTheory.Integrable.smul

theorem integrable_smul_iff {c : 𝕜} (hc : c ≠ 0) (f : α → β) :
    Integrable (c • f) μ ↔ Integrable f μ :=
  and_congr (ae_strongly_measurable_const_smul_iff₀ hc) (has_finite_integral_smul_iff hc f)
#align measure_theory.integrable_smul_iff MeasureTheory.integrable_smul_iff

end NormedSpace

section NormedSpaceOverCompleteField

variable {𝕜 : Type _} [NontriviallyNormedField 𝕜] [CompleteSpace 𝕜]

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace 𝕜 E]

theorem integrable_smul_const {f : α → 𝕜} {c : E} (hc : c ≠ 0) :
    Integrable (fun x => f x • c) μ ↔ Integrable f μ :=
  by
  simp_rw [integrable, ae_strongly_measurable_smul_const_iff hc, and_congr_right_iff,
    has_finite_integral, nnnorm_smul, Ennreal.coe_mul]
  intro hf; rw [lintegral_mul_const' _ _ Ennreal.coe_ne_top, Ennreal.mul_lt_top_iff]
  have : ∀ x : ℝ≥0∞, x = 0 → x < ∞ := by simp
  simp [hc, or_iff_left_of_imp (this _)]
#align measure_theory.integrable_smul_const MeasureTheory.integrable_smul_const

end NormedSpaceOverCompleteField

section IsROrC

variable {𝕜 : Type _} [IsROrC 𝕜] {f : α → 𝕜}

theorem Integrable.constMul {f : α → 𝕜} (h : Integrable f μ) (c : 𝕜) :
    Integrable (fun x => c * f x) μ :=
  Integrable.smul c h
#align measure_theory.integrable.const_mul MeasureTheory.Integrable.constMul

theorem Integrable.constMul' {f : α → 𝕜} (h : Integrable f μ) (c : 𝕜) :
    Integrable ((fun x : α => c) * f) μ :=
  Integrable.smul c h
#align measure_theory.integrable.const_mul' MeasureTheory.Integrable.constMul'

theorem Integrable.mulConst {f : α → 𝕜} (h : Integrable f μ) (c : 𝕜) :
    Integrable (fun x => f x * c) μ := by simp_rw [mul_comm, h.const_mul _]
#align measure_theory.integrable.mul_const MeasureTheory.Integrable.mulConst

theorem Integrable.mulConst' {f : α → 𝕜} (h : Integrable f μ) (c : 𝕜) :
    Integrable (f * fun x : α => c) μ :=
  Integrable.mulConst h c
#align measure_theory.integrable.mul_const' MeasureTheory.Integrable.mulConst'

theorem Integrable.divConst {f : α → 𝕜} (h : Integrable f μ) (c : 𝕜) :
    Integrable (fun x => f x / c) μ := by simp_rw [div_eq_mul_inv, h.mul_const]
#align measure_theory.integrable.div_const MeasureTheory.Integrable.divConst

theorem Integrable.bddMul' {f g : α → 𝕜} {c : ℝ} (hg : Integrable g μ)
    (hf : AeStronglyMeasurable f μ) (hf_bound : ∀ᵐ x ∂μ, ‖f x‖ ≤ c) :
    Integrable (fun x => f x * g x) μ :=
  by
  refine' integrable.mono' (hg.norm.smul c) (hf.mul hg.1) _
  filter_upwards [hf_bound] with x hx
  rw [Pi.smul_apply, smul_eq_mul]
  exact (norm_mul_le _ _).trans (mul_le_mul_of_nonneg_right hx (norm_nonneg _))
#align measure_theory.integrable.bdd_mul' MeasureTheory.Integrable.bddMul'

theorem Integrable.ofReal {f : α → ℝ} (hf : Integrable f μ) : Integrable (fun x => (f x : 𝕜)) μ :=
  by
  rw [← mem_ℒp_one_iff_integrable] at hf⊢
  exact hf.of_real
#align measure_theory.integrable.of_real MeasureTheory.Integrable.ofReal

theorem Integrable.re_im_iff :
    Integrable (fun x => IsROrC.re (f x)) μ ∧ Integrable (fun x => IsROrC.im (f x)) μ ↔
      Integrable f μ :=
  by
  simp_rw [← mem_ℒp_one_iff_integrable]
  exact mem_ℒp_re_im_iff
#align measure_theory.integrable.re_im_iff MeasureTheory.Integrable.re_im_iff

theorem Integrable.re (hf : Integrable f μ) : Integrable (fun x => IsROrC.re (f x)) μ :=
  by
  rw [← mem_ℒp_one_iff_integrable] at hf⊢
  exact hf.re
#align measure_theory.integrable.re MeasureTheory.Integrable.re

theorem Integrable.im (hf : Integrable f μ) : Integrable (fun x => IsROrC.im (f x)) μ :=
  by
  rw [← mem_ℒp_one_iff_integrable] at hf⊢
  exact hf.im
#align measure_theory.integrable.im MeasureTheory.Integrable.im

end IsROrC

section InnerProduct

variable {𝕜 E : Type _} [IsROrC 𝕜] [InnerProductSpace 𝕜 E] {f : α → E}

-- mathport name: «expr⟪ , ⟫»
local notation "⟪" x ", " y "⟫" => @inner 𝕜 E _ x y

theorem Integrable.constInner (c : E) (hf : Integrable f μ) : Integrable (fun x => ⟪c, f x⟫) μ :=
  by
  rw [← mem_ℒp_one_iff_integrable] at hf⊢
  exact hf.const_inner c
#align measure_theory.integrable.const_inner MeasureTheory.Integrable.constInner

theorem Integrable.innerConst (hf : Integrable f μ) (c : E) : Integrable (fun x => ⟪f x, c⟫) μ :=
  by
  rw [← mem_ℒp_one_iff_integrable] at hf⊢
  exact hf.inner_const c
#align measure_theory.integrable.inner_const MeasureTheory.Integrable.innerConst

end InnerProduct

section Trim

variable {H : Type _} [NormedAddCommGroup H] {m0 : MeasurableSpace α} {μ' : Measure α} {f : α → H}

theorem Integrable.trim (hm : m ≤ m0) (hf_int : Integrable f μ') (hf : strongly_measurable[m] f) :
    Integrable f (μ'.trim hm) :=
  by
  refine' ⟨hf.ae_strongly_measurable, _⟩
  rw [has_finite_integral, lintegral_trim hm _]
  · exact hf_int.2
  · exact @strongly_measurable.ennnorm _ m _ _ f hf
#align measure_theory.integrable.trim MeasureTheory.Integrable.trim

theorem integrableOfIntegrableTrim (hm : m ≤ m0) (hf_int : Integrable f (μ'.trim hm)) :
    Integrable f μ' := by
  obtain ⟨hf_meas_ae, hf⟩ := hf_int
  refine' ⟨aeStronglyMeasurableOfAeStronglyMeasurableTrim hm hf_meas_ae, _⟩
  rw [has_finite_integral] at hf⊢
  rwa [lintegral_trim_ae hm _] at hf
  exact ae_strongly_measurable.ennnorm hf_meas_ae
#align measure_theory.integrable_of_integrable_trim MeasureTheory.integrableOfIntegrableTrim

end Trim

section SigmaFinite

variable {E : Type _} {m0 : MeasurableSpace α} [NormedAddCommGroup E]

theorem integrableOfForallFinMeasLe' {μ : Measure α} (hm : m ≤ m0) [SigmaFinite (μ.trim hm)]
    (C : ℝ≥0∞) (hC : C < ∞) {f : α → E} (hf_meas : AeStronglyMeasurable f μ)
    (hf : ∀ s, measurable_set[m] s → μ s ≠ ∞ → (∫⁻ x in s, ‖f x‖₊ ∂μ) ≤ C) : Integrable f μ :=
  ⟨hf_meas, (lintegral_le_of_forall_fin_meas_le' hm C hf_meas.ennnorm hf).trans_lt hC⟩
#align measure_theory.integrable_of_forall_fin_meas_le' MeasureTheory.integrableOfForallFinMeasLe'

theorem integrableOfForallFinMeasLe [SigmaFinite μ] (C : ℝ≥0∞) (hC : C < ∞) {f : α → E}
    (hf_meas : AeStronglyMeasurable f μ)
    (hf : ∀ s : Set α, MeasurableSet s → μ s ≠ ∞ → (∫⁻ x in s, ‖f x‖₊ ∂μ) ≤ C) : Integrable f μ :=
  @integrableOfForallFinMeasLe' _ _ _ _ _ _ _ (by rwa [trim_eq_self]) C hC _ hf_meas hf
#align measure_theory.integrable_of_forall_fin_meas_le MeasureTheory.integrableOfForallFinMeasLe

end SigmaFinite

/-! ### The predicate `integrable` on measurable functions modulo a.e.-equality -/


namespace AeEqFun

section

/-- A class of almost everywhere equal functions is `integrable` if its function representative
is integrable. -/
def Integrable (f : α →ₘ[μ] β) : Prop :=
  Integrable f μ
#align measure_theory.ae_eq_fun.integrable MeasureTheory.AeEqFun.Integrable

theorem integrable_mk {f : α → β} (hf : AeStronglyMeasurable f μ) :
    Integrable (mk f hf : α →ₘ[μ] β) ↔ MeasureTheory.Integrable f μ :=
  by
  simp [integrable]
  apply integrable_congr
  exact coe_fn_mk f hf
#align measure_theory.ae_eq_fun.integrable_mk MeasureTheory.AeEqFun.integrable_mk

theorem integrable_coe_fn {f : α →ₘ[μ] β} : MeasureTheory.Integrable f μ ↔ Integrable f := by
  rw [← integrable_mk, mk_coe_fn]
#align measure_theory.ae_eq_fun.integrable_coe_fn MeasureTheory.AeEqFun.integrable_coe_fn

theorem integrableZero : Integrable (0 : α →ₘ[μ] β) :=
  (integrableZero α β μ).congr (coe_fn_mk _ _).symm
#align measure_theory.ae_eq_fun.integrable_zero MeasureTheory.AeEqFun.integrableZero

end

section

theorem Integrable.neg {f : α →ₘ[μ] β} : Integrable f → Integrable (-f) :=
  (inductionOn f) fun f hfm hfi => (integrable_mk _).2 ((integrable_mk hfm).1 hfi).neg
#align measure_theory.ae_eq_fun.integrable.neg MeasureTheory.AeEqFun.Integrable.neg

section

theorem integrable_iff_mem_L1 {f : α →ₘ[μ] β} : Integrable f ↔ f ∈ (α →₁[μ] β) := by
  rw [← integrable_coe_fn, ← mem_ℒp_one_iff_integrable, Lp.mem_Lp_iff_mem_ℒp]
#align measure_theory.ae_eq_fun.integrable_iff_mem_L1 MeasureTheory.AeEqFun.integrable_iff_mem_L1

theorem Integrable.add {f g : α →ₘ[μ] β} : Integrable f → Integrable g → Integrable (f + g) :=
  by
  refine' induction_on₂ f g fun f hf g hg hfi hgi => _
  simp only [integrable_mk, mk_add_mk] at hfi hgi⊢
  exact hfi.add hgi
#align measure_theory.ae_eq_fun.integrable.add MeasureTheory.AeEqFun.Integrable.add

theorem Integrable.sub {f g : α →ₘ[μ] β} (hf : Integrable f) (hg : Integrable g) :
    Integrable (f - g) :=
  (sub_eq_add_neg f g).symm ▸ hf.add hg.neg
#align measure_theory.ae_eq_fun.integrable.sub MeasureTheory.AeEqFun.Integrable.sub

end

section NormedSpace

variable {𝕜 : Type _} [NormedField 𝕜] [NormedSpace 𝕜 β]

theorem Integrable.smul {c : 𝕜} {f : α →ₘ[μ] β} : Integrable f → Integrable (c • f) :=
  (inductionOn f) fun f hfm hfi => (integrable_mk _).2 <| ((integrable_mk hfm).1 hfi).smul _
#align measure_theory.ae_eq_fun.integrable.smul MeasureTheory.AeEqFun.Integrable.smul

end NormedSpace

end

end AeEqFun

namespace L1Cat

theorem integrableCoeFn (f : α →₁[μ] β) : Integrable f μ :=
  by
  rw [← mem_ℒp_one_iff_integrable]
  exact Lp.mem_ℒp f
#align measure_theory.L1.integrable_coe_fn MeasureTheory.L1Cat.integrableCoeFn

theorem hasFiniteIntegralCoeFn (f : α →₁[μ] β) : HasFiniteIntegral f μ :=
  (integrableCoeFn f).HasFiniteIntegral
#align measure_theory.L1.has_finite_integral_coe_fn MeasureTheory.L1Cat.hasFiniteIntegralCoeFn

theorem strongly_measurable_coe_fn (f : α →₁[μ] β) : StronglyMeasurable f :=
  lp.strongly_measurable f
#align measure_theory.L1.strongly_measurable_coe_fn MeasureTheory.L1Cat.strongly_measurable_coe_fn

theorem measurable_coe_fn [MeasurableSpace β] [BorelSpace β] (f : α →₁[μ] β) : Measurable f :=
  (lp.strongly_measurable f).Measurable
#align measure_theory.L1.measurable_coe_fn MeasureTheory.L1Cat.measurable_coe_fn

theorem aeStronglyMeasurableCoeFn (f : α →₁[μ] β) : AeStronglyMeasurable f μ :=
  lp.aeStronglyMeasurable f
#align measure_theory.L1.ae_strongly_measurable_coe_fn MeasureTheory.L1Cat.aeStronglyMeasurableCoeFn

theorem aeMeasurableCoeFn [MeasurableSpace β] [BorelSpace β] (f : α →₁[μ] β) : AeMeasurable f μ :=
  (lp.strongly_measurable f).Measurable.AeMeasurable
#align measure_theory.L1.ae_measurable_coe_fn MeasureTheory.L1Cat.aeMeasurableCoeFn

theorem edist_def (f g : α →₁[μ] β) : edist f g = ∫⁻ a, edist (f a) (g a) ∂μ :=
  by
  simp [Lp.edist_def, snorm, snorm']
  simp [edist_eq_coe_nnnorm_sub]
#align measure_theory.L1.edist_def MeasureTheory.L1Cat.edist_def

theorem dist_def (f g : α →₁[μ] β) : dist f g = (∫⁻ a, edist (f a) (g a) ∂μ).toReal :=
  by
  simp [Lp.dist_def, snorm, snorm']
  simp [edist_eq_coe_nnnorm_sub]
#align measure_theory.L1.dist_def MeasureTheory.L1Cat.dist_def

theorem norm_def (f : α →₁[μ] β) : ‖f‖ = (∫⁻ a, ‖f a‖₊ ∂μ).toReal := by
  simp [Lp.norm_def, snorm, snorm']
#align measure_theory.L1.norm_def MeasureTheory.L1Cat.norm_def

/-- Computing the norm of a difference between two L¹-functions. Note that this is not a
  special case of `norm_def` since `(f - g) x` and `f x - g x` are not equal
  (but only a.e.-equal). -/
theorem norm_sub_eq_lintegral (f g : α →₁[μ] β) :
    ‖f - g‖ = (∫⁻ x, (‖f x - g x‖₊ : ℝ≥0∞) ∂μ).toReal :=
  by
  rw [norm_def]
  congr 1
  rw [lintegral_congr_ae]
  filter_upwards [Lp.coe_fn_sub f g] with _ ha
  simp only [ha, Pi.sub_apply]
#align measure_theory.L1.norm_sub_eq_lintegral MeasureTheory.L1Cat.norm_sub_eq_lintegral

theorem of_real_norm_eq_lintegral (f : α →₁[μ] β) : Ennreal.ofReal ‖f‖ = ∫⁻ x, (‖f x‖₊ : ℝ≥0∞) ∂μ :=
  by
  rw [norm_def, Ennreal.of_real_to_real]
  exact ne_of_lt (has_finite_integral_coe_fn f)
#align measure_theory.L1.of_real_norm_eq_lintegral MeasureTheory.L1Cat.of_real_norm_eq_lintegral

/-- Computing the norm of a difference between two L¹-functions. Note that this is not a
  special case of `of_real_norm_eq_lintegral` since `(f - g) x` and `f x - g x` are not equal
  (but only a.e.-equal). -/
theorem of_real_norm_sub_eq_lintegral (f g : α →₁[μ] β) :
    Ennreal.ofReal ‖f - g‖ = ∫⁻ x, (‖f x - g x‖₊ : ℝ≥0∞) ∂μ :=
  by
  simp_rw [of_real_norm_eq_lintegral, ← edist_eq_coe_nnnorm]
  apply lintegral_congr_ae
  filter_upwards [Lp.coe_fn_sub f g] with _ ha
  simp only [ha, Pi.sub_apply]
#align
  measure_theory.L1.of_real_norm_sub_eq_lintegral MeasureTheory.L1Cat.of_real_norm_sub_eq_lintegral

end L1Cat

namespace Integrable

/-- Construct the equivalence class `[f]` of an integrable function `f`, as a member of the
space `L1 β 1 μ`. -/
def toL1 (f : α → β) (hf : Integrable f μ) : α →₁[μ] β :=
  (mem_ℒp_one_iff_integrable.2 hf).toLp f
#align measure_theory.integrable.to_L1 MeasureTheory.Integrable.toL1

@[simp]
theorem to_L1_coe_fn (f : α →₁[μ] β) (hf : Integrable f μ) : hf.toL1 f = f := by
  simp [integrable.to_L1]
#align measure_theory.integrable.to_L1_coe_fn MeasureTheory.Integrable.to_L1_coe_fn

theorem coe_fn_to_L1 {f : α → β} (hf : Integrable f μ) : hf.toL1 f =ᵐ[μ] f :=
  AeEqFun.coe_fn_mk _ _
#align measure_theory.integrable.coe_fn_to_L1 MeasureTheory.Integrable.coe_fn_to_L1

@[simp]
theorem to_L1_zero (h : Integrable (0 : α → β) μ) : h.toL1 0 = 0 :=
  rfl
#align measure_theory.integrable.to_L1_zero MeasureTheory.Integrable.to_L1_zero

@[simp]
theorem to_L1_eq_mk (f : α → β) (hf : Integrable f μ) :
    (hf.toL1 f : α →ₘ[μ] β) = AeEqFun.mk f hf.AeStronglyMeasurable :=
  rfl
#align measure_theory.integrable.to_L1_eq_mk MeasureTheory.Integrable.to_L1_eq_mk

@[simp]
theorem to_L1_eq_to_L1_iff (f g : α → β) (hf : Integrable f μ) (hg : Integrable g μ) :
    toL1 f hf = toL1 g hg ↔ f =ᵐ[μ] g :=
  Memℒp.to_Lp_eq_to_Lp_iff _ _
#align measure_theory.integrable.to_L1_eq_to_L1_iff MeasureTheory.Integrable.to_L1_eq_to_L1_iff

theorem to_L1_add (f g : α → β) (hf : Integrable f μ) (hg : Integrable g μ) :
    toL1 (f + g) (hf.add hg) = toL1 f hf + toL1 g hg :=
  rfl
#align measure_theory.integrable.to_L1_add MeasureTheory.Integrable.to_L1_add

theorem to_L1_neg (f : α → β) (hf : Integrable f μ) : toL1 (-f) (Integrable.neg hf) = -toL1 f hf :=
  rfl
#align measure_theory.integrable.to_L1_neg MeasureTheory.Integrable.to_L1_neg

theorem to_L1_sub (f g : α → β) (hf : Integrable f μ) (hg : Integrable g μ) :
    toL1 (f - g) (hf.sub hg) = toL1 f hf - toL1 g hg :=
  rfl
#align measure_theory.integrable.to_L1_sub MeasureTheory.Integrable.to_L1_sub

theorem norm_to_L1 (f : α → β) (hf : Integrable f μ) :
    ‖hf.toL1 f‖ = Ennreal.toReal (∫⁻ a, edist (f a) 0 ∂μ) :=
  by
  simp [to_L1, snorm, snorm']
  simp [edist_eq_coe_nnnorm]
#align measure_theory.integrable.norm_to_L1 MeasureTheory.Integrable.norm_to_L1

theorem norm_to_L1_eq_lintegral_norm (f : α → β) (hf : Integrable f μ) :
    ‖hf.toL1 f‖ = Ennreal.toReal (∫⁻ a, Ennreal.ofReal ‖f a‖ ∂μ) := by
  rw [norm_to_L1, lintegral_norm_eq_lintegral_edist]
#align
  measure_theory.integrable.norm_to_L1_eq_lintegral_norm MeasureTheory.Integrable.norm_to_L1_eq_lintegral_norm

@[simp]
theorem edist_to_L1_to_L1 (f g : α → β) (hf : Integrable f μ) (hg : Integrable g μ) :
    edist (hf.toL1 f) (hg.toL1 g) = ∫⁻ a, edist (f a) (g a) ∂μ :=
  by
  simp [integrable.to_L1, snorm, snorm']
  simp [edist_eq_coe_nnnorm_sub]
#align measure_theory.integrable.edist_to_L1_to_L1 MeasureTheory.Integrable.edist_to_L1_to_L1

@[simp]
theorem edist_to_L1_zero (f : α → β) (hf : Integrable f μ) :
    edist (hf.toL1 f) 0 = ∫⁻ a, edist (f a) 0 ∂μ :=
  by
  simp [integrable.to_L1, snorm, snorm']
  simp [edist_eq_coe_nnnorm]
#align measure_theory.integrable.edist_to_L1_zero MeasureTheory.Integrable.edist_to_L1_zero

variable {𝕜 : Type _} [NormedField 𝕜] [NormedSpace 𝕜 β]

theorem to_L1_smul (f : α → β) (hf : Integrable f μ) (k : 𝕜) :
    toL1 (fun a => k • f a) (hf.smul k) = k • toL1 f hf :=
  rfl
#align measure_theory.integrable.to_L1_smul MeasureTheory.Integrable.to_L1_smul

theorem to_L1_smul' (f : α → β) (hf : Integrable f μ) (k : 𝕜) :
    toL1 (k • f) (hf.smul k) = k • toL1 f hf :=
  rfl
#align measure_theory.integrable.to_L1_smul' MeasureTheory.Integrable.to_L1_smul'

end Integrable

end MeasureTheory

open MeasureTheory

variable {E : Type _} [NormedAddCommGroup E] {𝕜 : Type _} [NontriviallyNormedField 𝕜]
  [NormedSpace 𝕜 E] {H : Type _} [NormedAddCommGroup H] [NormedSpace 𝕜 H]

theorem MeasureTheory.Integrable.applyContinuousLinearMap {φ : α → H →L[𝕜] E}
    (φ_int : Integrable φ μ) (v : H) : Integrable (fun a => φ a v) μ :=
  (φ_int.norm.mul_const ‖v‖).mono' (φ_int.AeStronglyMeasurable.apply_continuous_linear_map v)
    (eventually_of_forall fun a => (φ a).le_op_norm v)
#align
  measure_theory.integrable.apply_continuous_linear_map MeasureTheory.Integrable.applyContinuousLinearMap

theorem ContinuousLinearMap.integrableComp {φ : α → H} (L : H →L[𝕜] E) (φ_int : Integrable φ μ) :
    Integrable (fun a : α => L (φ a)) μ :=
  ((Integrable.norm φ_int).const_mul ‖L‖).mono'
    (L.Continuous.compAeStronglyMeasurable φ_int.AeStronglyMeasurable)
    (eventually_of_forall fun a => L.le_op_norm (φ a))
#align continuous_linear_map.integrable_comp ContinuousLinearMap.integrableComp

