/-
Copyright (c) 2021 Patrick Massot. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Massot
-/
import Mathbin.MeasureTheory.Integral.SetIntegral
import Mathbin.Analysis.Calculus.MeanValue

/-!
# Derivatives of integrals depending on parameters

A parametric integral is a function with shape `f = λ x : H, ∫ a : α, F x a ∂μ` for some
`F : H → α → E`, where `H` and `E` are normed spaces and `α` is a measured space with measure `μ`.

We already know from `continuous_of_dominated` in `measure_theory.integral.bochner` how to
guarantee that `f` is continuous using the dominated convergence theorem. In this file,
we want to express the derivative of `f` as the integral of the derivative of `F` with respect
to `x`.


## Main results

As explained above, all results express the derivative of a parametric integral as the integral of
a derivative. The variations come from the assumptions and from the different ways of expressing
derivative, especially Fréchet derivatives vs elementary derivative of function of one real
variable.

* `has_fderiv_at_integral_of_dominated_loc_of_lip`: this version assumes that
  - `F x` is ae-measurable for x near `x₀`,
  - `F x₀` is integrable,
  - `λ x, F x a` has derivative `F' a : H →L[ℝ] E` at `x₀` which is ae-measurable,
  - `λ x, F x a` is locally Lipschitz near `x₀` for almost every `a`, with a Lipschitz bound which
    is integrable with respect to `a`.

  A subtle point is that the "near x₀" in the last condition has to be uniform in `a`. This is
  controlled by a positive number `ε`.

* `has_fderiv_at_integral_of_dominated_of_fderiv_le`: this version assume `λ x, F x a` has
   derivative `F' x a` for `x` near `x₀` and `F' x` is bounded by an integrable function independent
   from `x` near `x₀`.


`has_deriv_at_integral_of_dominated_loc_of_lip` and
`has_deriv_at_integral_of_dominated_loc_of_deriv_le` are versions of the above two results that
assume `H = ℝ` or `H = ℂ` and use the high-school derivative `deriv` instead of Fréchet derivative
`fderiv`.

We also provide versions of these theorems for set integrals.

## Tags
integral, derivative
-/


noncomputable section

open TopologicalSpace MeasureTheory Filter Metric

open TopologicalSpace Filter

variable {α : Type _} [MeasurableSpace α] {μ : Measure α} {𝕜 : Type _} [IsROrC 𝕜] {E : Type _} [NormedAddCommGroup E]
  [NormedSpace ℝ E] [NormedSpace 𝕜 E] [CompleteSpace E] {H : Type _} [NormedAddCommGroup H] [NormedSpace 𝕜 H]

/-- Differentiation under integral of `x ↦ ∫ F x a` at a given point `x₀`, assuming `F x₀` is
integrable, `∥F x a - F x₀ a∥ ≤ bound a * ∥x - x₀∥` for `x` in a ball around `x₀` for ae `a` with
integrable Lipschitz bound `bound` (with a ball radius independent of `a`), and `F x` is
ae-measurable for `x` in the same ball. See `has_fderiv_at_integral_of_dominated_loc_of_lip` for a
slightly less general but usually more useful version. -/
theorem has_fderiv_at_integral_of_dominated_loc_of_lip' {F : H → α → E} {F' : α → H →L[𝕜] E} {x₀ : H} {bound : α → ℝ}
    {ε : ℝ} (ε_pos : 0 < ε) (hF_meas : ∀ x ∈ ball x₀ ε, AeStronglyMeasurable (F x) μ) (hF_int : Integrable (F x₀) μ)
    (hF'_meas : AeStronglyMeasurable F' μ) (h_lipsch : ∀ᵐ a ∂μ, ∀ x ∈ ball x₀ ε, ∥F x a - F x₀ a∥ ≤ bound a * ∥x - x₀∥)
    (bound_integrable : Integrable (bound : α → ℝ) μ) (h_diff : ∀ᵐ a ∂μ, HasFderivAt (fun x => F x a) (F' a) x₀) :
    Integrable F' μ ∧ HasFderivAt (fun x => ∫ a, F x a ∂μ) (∫ a, F' a ∂μ) x₀ := by
  have x₀_in : x₀ ∈ ball x₀ ε := mem_ball_self ε_pos
  have nneg : ∀ x, 0 ≤ ∥x - x₀∥⁻¹ := fun x => inv_nonneg.mpr (norm_nonneg _)
  set b : α → ℝ := fun a => |bound a|
  have b_int : integrable b μ := bound_integrable.norm
  have b_nonneg : ∀ a, 0 ≤ b a := fun a => abs_nonneg _
  replace h_lipsch : ∀ᵐ a ∂μ, ∀ x ∈ ball x₀ ε, ∥F x a - F x₀ a∥ ≤ b a * ∥x - x₀∥
  exact h_lipsch.mono fun a ha x hx => (ha x hx).trans $ mul_le_mul_of_nonneg_right (le_abs_self _) (norm_nonneg _)
  have hF_int' : ∀ x ∈ ball x₀ ε, integrable (F x) μ := by
    intro x x_in
    have : ∀ᵐ a ∂μ, ∥F x₀ a - F x a∥ ≤ ε * b a := by
      simp only [norm_sub_rev (F x₀ _)]
      refine' h_lipsch.mono fun a ha => (ha x x_in).trans _
      rw [mul_comm ε]
      rw [mem_ball, dist_eq_norm] at x_in
      exact mul_le_mul_of_nonneg_left x_in.le (b_nonneg _)
    exact integrable_of_norm_sub_le (hF_meas x x_in) hF_int (integrable.const_mul bound_integrable.norm ε) this
  have hF'_int : integrable F' μ :=
    haveI : ∀ᵐ a ∂μ, ∥F' a∥ ≤ b a := by
      apply (h_diff.and h_lipsch).mono
      rintro a ⟨ha_diff, ha_lip⟩
      refine' ha_diff.le_of_lip' (b_nonneg a) (mem_of_superset (ball_mem_nhds _ ε_pos) $ ha_lip)
    b_int.mono' hF'_meas this
  refine' ⟨hF'_int, _⟩
  have h_ball : ball x₀ ε ∈ 𝓝 x₀ := ball_mem_nhds x₀ ε_pos
  have :
    ∀ᶠ x in 𝓝 x₀,
      ∥x - x₀∥⁻¹ * ∥((∫ a, F x a ∂μ) - ∫ a, F x₀ a ∂μ) - (∫ a, F' a ∂μ) (x - x₀)∥ =
        ∥∫ a, ∥x - x₀∥⁻¹ • (F x a - F x₀ a - F' a (x - x₀)) ∂μ∥ :=
    by
    apply mem_of_superset (ball_mem_nhds _ ε_pos)
    intro x x_in
    rw [Set.mem_set_of_eq, ← norm_smul_of_nonneg (nneg _), integral_smul, integral_sub, integral_sub, ←
      ContinuousLinearMap.integral_apply hF'_int]
    exacts[hF_int' x x_in, hF_int, (hF_int' x x_in).sub hF_int, hF'_int.apply_continuous_linear_map _]
  rw [has_fderiv_at_iff_tendsto, tendsto_congr' this, ← tendsto_zero_iff_norm_tendsto_zero, ←
    show (∫ a : α, ∥x₀ - x₀∥⁻¹ • (F x₀ a - F x₀ a - (F' a) (x₀ - x₀)) ∂μ) = 0 by simp]
  apply tendsto_integral_filter_of_dominated_convergence
  · filter_upwards [h_ball] with _ x_in
    apply ae_strongly_measurable.const_smul
    exact ((hF_meas _ x_in).sub (hF_meas _ x₀_in)).sub (hF'_meas.apply_continuous_linear_map _)
    
  · apply mem_of_superset h_ball
    intro x hx
    apply (h_diff.and h_lipsch).mono
    rintro a ⟨ha_deriv, ha_bound⟩
    show ∥∥x - x₀∥⁻¹ • (F x a - F x₀ a - F' a (x - x₀))∥ ≤ b a + ∥F' a∥
    replace ha_bound : ∥F x a - F x₀ a∥ ≤ b a * ∥x - x₀∥ := ha_bound x hx
    calc
      ∥∥x - x₀∥⁻¹ • (F x a - F x₀ a - F' a (x - x₀))∥ = ∥∥x - x₀∥⁻¹ • (F x a - F x₀ a) - ∥x - x₀∥⁻¹ • F' a (x - x₀)∥ :=
        by rw [smul_sub]
      _ ≤ ∥∥x - x₀∥⁻¹ • (F x a - F x₀ a)∥ + ∥∥x - x₀∥⁻¹ • F' a (x - x₀)∥ := norm_sub_le _ _
      _ = ∥x - x₀∥⁻¹ * ∥F x a - F x₀ a∥ + ∥x - x₀∥⁻¹ * ∥F' a (x - x₀)∥ := by
        rw [norm_smul_of_nonneg, norm_smul_of_nonneg] <;> exact nneg _
      _ ≤ ∥x - x₀∥⁻¹ * (b a * ∥x - x₀∥) + ∥x - x₀∥⁻¹ * (∥F' a∥ * ∥x - x₀∥) := add_le_add _ _
      _ ≤ b a + ∥F' a∥ := _
      
    exact mul_le_mul_of_nonneg_left ha_bound (nneg _)
    apply mul_le_mul_of_nonneg_left ((F' a).le_op_norm _) (nneg _)
    by_cases h:∥x - x₀∥ = 0
    · simpa [h] using add_nonneg (b_nonneg a) (norm_nonneg (F' a))
      
    · field_simp [h]
      
    
  · exact b_int.add hF'_int.norm
    
  · apply h_diff.mono
    intro a ha
    suffices tendsto (fun x => ∥x - x₀∥⁻¹ • (F x a - F x₀ a - F' a (x - x₀))) (𝓝 x₀) (𝓝 0) by simpa
    rw [tendsto_zero_iff_norm_tendsto_zero]
    have :
      (fun x => ∥x - x₀∥⁻¹ * ∥F x a - F x₀ a - F' a (x - x₀)∥) = fun x =>
        ∥∥x - x₀∥⁻¹ • (F x a - F x₀ a - F' a (x - x₀))∥ :=
      by
      ext x
      rw [norm_smul_of_nonneg (nneg _)]
    rwa [has_fderiv_at_iff_tendsto, this] at ha
    
#align has_fderiv_at_integral_of_dominated_loc_of_lip' has_fderiv_at_integral_of_dominated_loc_of_lip'

/-- Differentiation under integral of `x ↦ ∫ F x a` at a given point `x₀`, assuming
`F x₀` is integrable, `x ↦ F x a` is locally Lipschitz on a ball around `x₀` for ae `a`
(with a ball radius independent of `a`) with integrable Lipschitz bound, and `F x` is ae-measurable
for `x` in a possibly smaller neighborhood of `x₀`. -/
theorem has_fderiv_at_integral_of_dominated_loc_of_lip {F : H → α → E} {F' : α → H →L[𝕜] E} {x₀ : H} {bound : α → ℝ}
    {ε : ℝ} (ε_pos : 0 < ε) (hF_meas : ∀ᶠ x in 𝓝 x₀, AeStronglyMeasurable (F x) μ) (hF_int : Integrable (F x₀) μ)
    (hF'_meas : AeStronglyMeasurable F' μ)
    (h_lip : ∀ᵐ a ∂μ, LipschitzOnWith (Real.nnabs $ bound a) (fun x => F x a) (ball x₀ ε))
    (bound_integrable : Integrable (bound : α → ℝ) μ) (h_diff : ∀ᵐ a ∂μ, HasFderivAt (fun x => F x a) (F' a) x₀) :
    Integrable F' μ ∧ HasFderivAt (fun x => ∫ a, F x a ∂μ) (∫ a, F' a ∂μ) x₀ := by
  obtain ⟨δ, δ_pos, hδ⟩ : ∃ δ > 0, ∀ x ∈ ball x₀ δ, ae_strongly_measurable (F x) μ ∧ x ∈ ball x₀ ε
  exact eventually_nhds_iff_ball.mp (hF_meas.and (ball_mem_nhds x₀ ε_pos))
  choose hδ_meas hδε using hδ
  replace h_lip : ∀ᵐ a : α ∂μ, ∀ x ∈ ball x₀ δ, ∥F x a - F x₀ a∥ ≤ |bound a| * ∥x - x₀∥
  exact h_lip.mono fun a lip x hx => lip.norm_sub_le (hδε x hx) (mem_ball_self ε_pos)
  replace bound_integrable := bound_integrable.norm
  apply has_fderiv_at_integral_of_dominated_loc_of_lip' δ_pos <;> assumption
#align has_fderiv_at_integral_of_dominated_loc_of_lip has_fderiv_at_integral_of_dominated_loc_of_lip

/-- Differentiation under integral of `x ↦ ∫ F x a` at a given point `x₀`, assuming
`F x₀` is integrable, `x ↦ F x a` is differentiable on a ball around `x₀` for ae `a` with
derivative norm uniformly bounded by an integrable function (the ball radius is independent of `a`),
and `F x` is ae-measurable for `x` in a possibly smaller neighborhood of `x₀`. -/
theorem hasFderivAtIntegralOfDominatedOfFderivLe {F : H → α → E} {F' : H → α → H →L[𝕜] E} {x₀ : H} {bound : α → ℝ}
    {ε : ℝ} (ε_pos : 0 < ε) (hF_meas : ∀ᶠ x in 𝓝 x₀, AeStronglyMeasurable (F x) μ) (hF_int : Integrable (F x₀) μ)
    (hF'_meas : AeStronglyMeasurable (F' x₀) μ) (h_bound : ∀ᵐ a ∂μ, ∀ x ∈ ball x₀ ε, ∥F' x a∥ ≤ bound a)
    (bound_integrable : Integrable (bound : α → ℝ) μ)
    (h_diff : ∀ᵐ a ∂μ, ∀ x ∈ ball x₀ ε, HasFderivAt (fun x => F x a) (F' x a) x) :
    HasFderivAt (fun x => ∫ a, F x a ∂μ) (∫ a, F' x₀ a ∂μ) x₀ := by
  letI : NormedSpace ℝ H := NormedSpace.restrictScalars ℝ 𝕜 H
  have x₀_in : x₀ ∈ ball x₀ ε := mem_ball_self ε_pos
  have diff_x₀ : ∀ᵐ a ∂μ, HasFderivAt (fun x => F x a) (F' x₀ a) x₀ := h_diff.mono fun a ha => ha x₀ x₀_in
  have : ∀ᵐ a ∂μ, LipschitzOnWith (Real.nnabs (bound a)) (fun x => F x a) (ball x₀ ε) := by
    apply (h_diff.and h_bound).mono
    rintro a ⟨ha_deriv, ha_bound⟩
    refine'
      (convex_ball _ _).lipschitzOnWithOfNnnormHasFderivWithinLe (fun x x_in => (ha_deriv x x_in).HasFderivWithinAt)
        fun x x_in => _
    rw [← Nnreal.coe_le_coe, coe_nnnorm, Real.coe_nnabs]
    exact (ha_bound x x_in).trans (le_abs_self _)
  exact (has_fderiv_at_integral_of_dominated_loc_of_lip ε_pos hF_meas hF_int hF'_meas this bound_integrable diff_x₀).2
#align has_fderiv_at_integral_of_dominated_of_fderiv_le hasFderivAtIntegralOfDominatedOfFderivLe

/-- Derivative under integral of `x ↦ ∫ F x a` at a given point `x₀ : 𝕜`, `𝕜 = ℝ` or `𝕜 = ℂ`,
assuming `F x₀` is integrable, `x ↦ F x a` is locally Lipschitz on a ball around `x₀` for ae `a`
(with ball radius independent of `a`) with integrable Lipschitz bound, and `F x` is
ae-measurable for `x` in a possibly smaller neighborhood of `x₀`. -/
theorem has_deriv_at_integral_of_dominated_loc_of_lip {F : 𝕜 → α → E} {F' : α → E} {x₀ : 𝕜} {ε : ℝ} (ε_pos : 0 < ε)
    (hF_meas : ∀ᶠ x in 𝓝 x₀, AeStronglyMeasurable (F x) μ) (hF_int : Integrable (F x₀) μ)
    (hF'_meas : AeStronglyMeasurable F' μ) {bound : α → ℝ}
    (h_lipsch : ∀ᵐ a ∂μ, LipschitzOnWith (Real.nnabs $ bound a) (fun x => F x a) (ball x₀ ε))
    (bound_integrable : Integrable (bound : α → ℝ) μ) (h_diff : ∀ᵐ a ∂μ, HasDerivAt (fun x => F x a) (F' a) x₀) :
    Integrable F' μ ∧ HasDerivAt (fun x => ∫ a, F x a ∂μ) (∫ a, F' a ∂μ) x₀ := by
  set L : E →L[𝕜] 𝕜 →L[𝕜] E := ContinuousLinearMap.smulRightL 𝕜 𝕜 E 1
  replace h_diff : ∀ᵐ a ∂μ, HasFderivAt (fun x => F x a) (L (F' a)) x₀ := h_diff.mono fun x hx => hx.HasFderivAt
  have hm : ae_strongly_measurable (L ∘ F') μ := L.continuous.comp_ae_strongly_measurable hF'_meas
  cases' has_fderiv_at_integral_of_dominated_loc_of_lip ε_pos hF_meas hF_int hm h_lipsch bound_integrable h_diff with
    hF'_int key
  replace hF'_int : integrable F' μ
  · rw [← integrable_norm_iff hm] at hF'_int
    simpa only [L, (· ∘ ·), integrable_norm_iff, hF'_meas, one_mul, norm_one, ContinuousLinearMap.comp_apply,
      ContinuousLinearMap.coe_restrict_scalarsL', ContinuousLinearMap.norm_restrict_scalars,
      ContinuousLinearMap.norm_smul_rightL_apply] using hF'_int
    
  refine' ⟨hF'_int, _⟩
  simp_rw [has_deriv_at_iff_has_fderiv_at] at h_diff⊢
  rwa [ContinuousLinearMap.integral_comp_comm _ hF'_int] at key
  all_goals infer_instance
#align has_deriv_at_integral_of_dominated_loc_of_lip has_deriv_at_integral_of_dominated_loc_of_lip

/-- Derivative under integral of `x ↦ ∫ F x a` at a given point `x₀ : ℝ`, assuming
`F x₀` is integrable, `x ↦ F x a` is differentiable on an interval around `x₀` for ae `a`
(with interval radius independent of `a`) with derivative uniformly bounded by an integrable
function, and `F x` is ae-measurable for `x` in a possibly smaller neighborhood of `x₀`. -/
theorem has_deriv_at_integral_of_dominated_loc_of_deriv_le {F : 𝕜 → α → E} {F' : 𝕜 → α → E} {x₀ : 𝕜} {ε : ℝ}
    (ε_pos : 0 < ε) (hF_meas : ∀ᶠ x in 𝓝 x₀, AeStronglyMeasurable (F x) μ) (hF_int : Integrable (F x₀) μ)
    (hF'_meas : AeStronglyMeasurable (F' x₀) μ) {bound : α → ℝ} (h_bound : ∀ᵐ a ∂μ, ∀ x ∈ ball x₀ ε, ∥F' x a∥ ≤ bound a)
    (bound_integrable : Integrable bound μ)
    (h_diff : ∀ᵐ a ∂μ, ∀ x ∈ ball x₀ ε, HasDerivAt (fun x => F x a) (F' x a) x) :
    Integrable (F' x₀) μ ∧ HasDerivAt (fun n => ∫ a, F n a ∂μ) (∫ a, F' x₀ a ∂μ) x₀ := by
  have x₀_in : x₀ ∈ ball x₀ ε := mem_ball_self ε_pos
  have diff_x₀ : ∀ᵐ a ∂μ, HasDerivAt (fun x => F x a) (F' x₀ a) x₀ := h_diff.mono fun a ha => ha x₀ x₀_in
  have : ∀ᵐ a ∂μ, LipschitzOnWith (Real.nnabs (bound a)) (fun x : 𝕜 => F x a) (ball x₀ ε) := by
    apply (h_diff.and h_bound).mono
    rintro a ⟨ha_deriv, ha_bound⟩
    refine'
      (convex_ball _ _).lipschitzOnWithOfNnnormHasDerivWithinLe (fun x x_in => (ha_deriv x x_in).HasDerivWithinAt)
        fun x x_in => _
    rw [← Nnreal.coe_le_coe, coe_nnnorm, Real.coe_nnabs]
    exact (ha_bound x x_in).trans (le_abs_self _)
  exact has_deriv_at_integral_of_dominated_loc_of_lip ε_pos hF_meas hF_int hF'_meas this bound_integrable diff_x₀
#align has_deriv_at_integral_of_dominated_loc_of_deriv_le has_deriv_at_integral_of_dominated_loc_of_deriv_le

