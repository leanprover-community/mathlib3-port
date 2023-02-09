/-
Copyright (c) 2022 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module analysis.special_functions.gaussian
! leanprover-community/mathlib commit d101e93197bb5f6ea89bd7ba386b7f7dff1f3903
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecialFunctions.Gamma
import Mathbin.Analysis.SpecialFunctions.PolarCoord
import Mathbin.Analysis.Convex.Complex
import Mathbin.Analysis.Normed.Group.Basic
import Mathbin.Analysis.Complex.CauchyIntegral
import Mathbin.MeasureTheory.Group.Integration

/-!
# Gaussian integral

We prove various versions of the formula for the Gaussian integral:
* `integral_gaussian`: for real `b` we have `∫ x:ℝ, exp (-b * x^2) = sqrt (π / b)`.
* `integral_gaussian_complex`: for complex `b` with `0 < re b` we have
  `∫ x:ℝ, exp (-b * x^2) = (π / b) ^ (1 / 2)`.
* `integral_gaussian_Ioi` and `integral_gaussian_complex_Ioi`: variants for integrals over `Ioi 0`.
* `complex.Gamma_one_half_eq`: the formula `Γ (1 / 2) = √π`.

We also prove, more generally, that the Fourier transform of the Gaussian
is another Gaussian:

* `integral_cexp_neg_mul_sq_add_const`: for all complex `b` and `c` with `0 < re b` we have
  `∫ (x : ℝ), exp (-b * (x + c) ^ 2) = (π / b) ^ (1 / 2)`.
* `fourier_transform_gaussian`: for all complex `b` and `t` with `0 < re b`, we have
  `∫ x:ℝ, exp (I * t * x) * exp (-b * x^2) = (π / b) ^ (1 / 2) * exp (-t ^ 2 / (4 * b))`.
* `fourier_transform_gaussian_pi`: a variant with `b` and `t` scaled to give a more symmetric
  statement, `∫ x:ℝ, exp (2 * π * I * t * x) * exp (-π * b * x^2) =
  (1 / b) ^ (1 / 2) * exp (-π * (1 / b) * t ^ 2)`.
-/


noncomputable section

open Real Set MeasureTheory Filter Asymptotics

open Real Topology

open Complex hiding exp continuous_exp abs_of_nonneg

-- mathport name: exprcexp
notation "cexp" => Complex.exp

theorem exp_neg_mul_sq_isOCat_exp_neg {b : ℝ} (hb : 0 < b) :
    (fun x : ℝ => exp (-b * x ^ 2)) =o[atTop] fun x : ℝ => exp (-x) :=
  by
  have A : (fun x : ℝ => -x - -b * x ^ 2) = fun x => x * (b * x + -1) :=
    by
    ext x
    ring
  rw [is_o_exp_comp_exp_comp, A]
  apply tendsto.at_top_mul_at_top tendsto_id
  apply tendsto_at_top_add_const_right at_top (-1 : ℝ)
  exact tendsto.const_mul_at_top hb tendsto_id
#align exp_neg_mul_sq_is_o_exp_neg exp_neg_mul_sq_isOCat_exp_neg

theorem rpow_mul_exp_neg_mul_sq_isOCat_exp_neg {b : ℝ} (hb : 0 < b) (s : ℝ) :
    (fun x : ℝ => x ^ s * exp (-b * x ^ 2)) =o[atTop] fun x : ℝ => exp (-(1 / 2) * x) :=
  by
  apply
    ((is_O_refl (fun x : ℝ => x ^ s) at_top).mul_isOCat (exp_neg_mul_sq_isOCat_exp_neg hb)).trans
  convert Gamma_integrand_is_o s
  simp_rw [mul_comm]
#align rpow_mul_exp_neg_mul_sq_is_o_exp_neg rpow_mul_exp_neg_mul_sq_isOCat_exp_neg

theorem integrableOnRpowMulExpNegMulSq {b : ℝ} (hb : 0 < b) {s : ℝ} (hs : -1 < s) :
    IntegrableOn (fun x : ℝ => x ^ s * exp (-b * x ^ 2)) (Ioi 0) :=
  by
  rw [← Ioc_union_Ioi_eq_Ioi (zero_le_one : (0 : ℝ) ≤ 1), integrable_on_union]
  constructor
  · rw [← integrableOn_Icc_iff_integrableOn_Ioc]
    refine' integrable_on.mul_continuous_on _ _ is_compact_Icc
    · refine' (intervalIntegrable_iff_integrable_Icc_of_le zero_le_one).mp _
      exact intervalIntegral.intervalIntegrableRpow' hs
    · exact (continuous_exp.comp (continuous_const.mul (continuous_pow 2))).ContinuousOn
  · have B : (0 : ℝ) < 1 / 2 := by norm_num
    apply integrableOfIsOExpNeg B _ (is_o.is_O (rpow_mul_exp_neg_mul_sq_isOCat_exp_neg hb _))
    intro x hx
    have N : x ≠ 0 := by
      refine' (zero_lt_one.trans_le _).ne'
      exact hx
    apply ((continuous_at_rpow_const _ _ (Or.inl N)).mul _).ContinuousWithinAt
    exact (continuous_exp.comp (continuous_const.mul (continuous_pow 2))).ContinuousAt
#align integrable_on_rpow_mul_exp_neg_mul_sq integrableOnRpowMulExpNegMulSq

theorem integrableRpowMulExpNegMulSq {b : ℝ} (hb : 0 < b) {s : ℝ} (hs : -1 < s) :
    Integrable fun x : ℝ => x ^ s * exp (-b * x ^ 2) :=
  by
  rw [← integrable_on_univ, ← @Iio_union_Ici _ _ (0 : ℝ), integrable_on_union,
    integrableOn_Ici_iff_integrableOn_Ioi]
  refine' ⟨_, integrableOnRpowMulExpNegMulSq hb hs⟩
  rw [←
    (measure.measure_preserving_neg (volume : Measure ℝ)).integrableOn_comp_preimage
      (Homeomorph.neg ℝ).toMeasurableEquiv.MeasurableEmbedding]
  simp only [Function.comp, neg_sq, neg_preimage, preimage_neg_Iio, neg_neg, neg_zero]
  apply integrable.mono' (integrableOnRpowMulExpNegMulSq hb hs)
  · apply Measurable.aeStronglyMeasurable
    exact
      (measurable_id'.neg.pow measurable_const).mul
        ((measurable_id'.pow measurable_const).const_mul (-b)).exp
  · have : MeasurableSet (Ioi (0 : ℝ)) := measurableSet_Ioi
    filter_upwards [ae_restrict_mem this]with x hx
    have h'x : 0 ≤ x := le_of_lt hx
    rw [Real.norm_eq_abs, abs_mul, abs_of_nonneg (exp_pos _).le]
    apply mul_le_mul_of_nonneg_right _ (exp_pos _).le
    simpa [abs_of_nonneg h'x] using abs_rpow_le_abs_rpow (-x) s
#align integrable_rpow_mul_exp_neg_mul_sq integrableRpowMulExpNegMulSq

theorem integrableExpNegMulSq {b : ℝ} (hb : 0 < b) : Integrable fun x : ℝ => exp (-b * x ^ 2) := by
  simpa using integrableRpowMulExpNegMulSq hb (by norm_num : (-1 : ℝ) < 0)
#align integrable_exp_neg_mul_sq integrableExpNegMulSq

theorem integrableOn_Ioi_exp_neg_mul_sq_iff {b : ℝ} :
    IntegrableOn (fun x : ℝ => exp (-b * x ^ 2)) (Ioi 0) ↔ 0 < b :=
  by
  refine' ⟨fun h => _, fun h => (integrableExpNegMulSq h).IntegrableOn⟩
  by_contra' hb
  have : (∫⁻ x : ℝ in Ioi 0, 1) ≤ ∫⁻ x : ℝ in Ioi 0, ‖exp (-b * x ^ 2)‖₊ :=
    by
    apply lintegral_mono fun x => _
    simp only [neg_mul, Ennreal.one_le_coe_iff, ← to_nnreal_one, to_nnreal_le_iff_le_coe,
      Real.norm_of_nonneg (exp_pos _).le, coe_nnnorm, one_le_exp_iff, Right.nonneg_neg_iff]
    exact mul_nonpos_of_nonpos_of_nonneg hb (sq_nonneg _)
  simpa using this.trans_lt h.2
#align integrable_on_Ioi_exp_neg_mul_sq_iff integrableOn_Ioi_exp_neg_mul_sq_iff

theorem integrable_exp_neg_mul_sq_iff {b : ℝ} :
    (Integrable fun x : ℝ => exp (-b * x ^ 2)) ↔ 0 < b :=
  ⟨fun h => integrableOn_Ioi_exp_neg_mul_sq_iff.mp h.IntegrableOn, integrableExpNegMulSq⟩
#align integrable_exp_neg_mul_sq_iff integrable_exp_neg_mul_sq_iff

theorem integrableMulExpNegMulSq {b : ℝ} (hb : 0 < b) :
    Integrable fun x : ℝ => x * exp (-b * x ^ 2) := by
  simpa using integrableRpowMulExpNegMulSq hb (by norm_num : (-1 : ℝ) < 1)
#align integrable_mul_exp_neg_mul_sq integrableMulExpNegMulSq

theorem norm_cexp_neg_mul_sq (b : ℂ) (x : ℝ) : ‖Complex.exp (-b * x ^ 2)‖ = exp (-b.re * x ^ 2) :=
  by
  rw [Complex.norm_eq_abs, Complex.abs_exp, ← of_real_pow, mul_comm (-b) _, of_real_mul_re, neg_re,
    mul_comm]
#align norm_cexp_neg_mul_sq norm_cexp_neg_mul_sq

theorem integrableCexpNegMulSq {b : ℂ} (hb : 0 < b.re) :
    Integrable fun x : ℝ => cexp (-b * x ^ 2) :=
  by
  refine'
    ⟨(complex.continuous_exp.comp
          (continuous_const.mul (continuous_of_real.pow 2))).AeStronglyMeasurable,
      _⟩
  rw [← has_finite_integral_norm_iff]
  simp_rw [norm_cexp_neg_mul_sq]
  exact (integrableExpNegMulSq hb).2
#align integrable_cexp_neg_mul_sq integrableCexpNegMulSq

theorem integrableMulCexpNegMulSq {b : ℂ} (hb : 0 < b.re) :
    Integrable fun x : ℝ => ↑x * cexp (-b * x ^ 2) :=
  by
  refine' ⟨(continuous_of_real.mul (complex.continuous_exp.comp _)).AeStronglyMeasurable, _⟩
  · exact continuous_const.mul (continuous_of_real.pow 2)
  have := (integrableMulExpNegMulSq hb).HasFiniteIntegral
  rw [← has_finite_integral_norm_iff] at this⊢
  convert this
  ext1 x
  rw [norm_mul, norm_mul, norm_cexp_neg_mul_sq b, Complex.norm_eq_abs, abs_of_real,
    Real.norm_eq_abs, norm_of_nonneg (exp_pos _).le]
#align integrable_mul_cexp_neg_mul_sq integrableMulCexpNegMulSq

theorem integral_mul_cexp_neg_mul_sq {b : ℂ} (hb : 0 < b.re) :
    (∫ r : ℝ in Ioi 0, (r : ℂ) * cexp (-b * r ^ 2)) = (2 * b)⁻¹ :=
  by
  have hb' : b ≠ 0 := by
    contrapose! hb
    rw [hb, zero_re]
  refine'
    tendsto_nhds_unique
      (interval_integral_tendsto_integral_Ioi _ (integrableMulCexpNegMulSq hb).IntegrableOn
        Filter.tendsto_id)
      _
  have A :
    ∀ x : ℂ, HasDerivAt (fun x => -(2 * b)⁻¹ * cexp (-b * x ^ 2)) (x * cexp (-b * x ^ 2)) x :=
    by
    intro x
    convert ((hasDerivAt_pow 2 x).const_mul (-b)).cexp.const_mul (-(2 * b)⁻¹) using 1
    field_simp [hb']
    ring
  have :
    ∀ y : ℝ,
      (∫ x in 0 ..id y, ↑x * cexp (-b * x ^ 2)) =
        -(2 * b)⁻¹ * cexp (-b * y ^ 2) - -(2 * b)⁻¹ * cexp (-b * 0 ^ 2) :=
    fun y =>
    intervalIntegral.integral_eq_sub_of_hasDerivAt (fun x hx => (A x).comp_of_real)
      (integrableMulCexpNegMulSq hb).IntervalIntegrable
  simp_rw [this]
  have L :
    tendsto (fun x : ℝ => (2 * b)⁻¹ - (2 * b)⁻¹ * cexp (-b * x ^ 2)) at_top
      (𝓝 ((2 * b)⁻¹ - (2 * b)⁻¹ * 0)) :=
    by
    refine' tendsto_const_nhds.sub (tendsto.const_mul _ <| tendsto_zero_iff_norm_tendsto_zero.mpr _)
    simp_rw [norm_cexp_neg_mul_sq b]
    exact
      tendsto_exp_at_bot.comp
        (tendsto.neg_const_mul_at_top (neg_lt_zero.2 hb) (tendsto_pow_at_top two_ne_zero))
  simpa using L
#align integral_mul_cexp_neg_mul_sq integral_mul_cexp_neg_mul_sq

/-- The *square* of the Gaussian integral `∫ x:ℝ, exp (-b * x^2)` is equal to `π / b`. -/
theorem integral_gaussian_sq_complex {b : ℂ} (hb : 0 < b.re) :
    (∫ x : ℝ, cexp (-b * x ^ 2)) ^ 2 = π / b :=
  by/- We compute `(∫ exp (-b x^2))^2` as an integral over `ℝ^2`, and then make a polar change
    of coordinates. We are left with `∫ r * exp (-b r^2)`, which has been computed in
    `integral_mul_cexp_neg_mul_sq` using the fact that this function has an obvious primitive. -/
  calc
    (∫ x : ℝ, cexp (-b * (x : ℂ) ^ 2)) ^ 2 =
        ∫ p : ℝ × ℝ, cexp (-b * (p.1 : ℂ) ^ 2) * cexp (-b * (p.2 : ℂ) ^ 2) :=
      by
      rw [pow_two, ← integral_prod_mul]
      rfl
    _ = ∫ p : ℝ × ℝ, cexp (-b * (p.1 ^ 2 + p.2 ^ 2)) :=
      by
      congr
      ext1 p
      rw [← Complex.exp_add, mul_add]
    _ = ∫ p in polar_coord.target, p.1 • cexp (-b * ((p.1 * cos p.2) ^ 2 + (p.1 * sin p.2) ^ 2)) :=
      by
      rw [← integral_comp_polarCoord_symm]
      simp only [polarCoord_symm_apply, of_real_mul, of_real_cos, of_real_sin]
    _ = (∫ r in Ioi (0 : ℝ), r * cexp (-b * r ^ 2)) * ∫ θ in Ioo (-π) π, 1 :=
      by
      rw [← set_integral_prod_mul]
      congr with p : 1
      rw [mul_one]
      congr
      conv_rhs => rw [← one_mul ((p.1 : ℂ) ^ 2), ← sin_sq_add_cos_sq (p.2 : ℂ)]
      ring
    _ = ↑π / b := by
      have : 0 ≤ π + π := by linarith [Real.pi_pos]
      simp only [integral_const, measure.restrict_apply', measurableSet_Ioo, univ_inter, volume_Ioo,
        sub_neg_eq_add, Ennreal.toReal_ofReal, this]
      rw [← two_mul, real_smul, mul_one, of_real_mul, of_real_bit0, of_real_one,
        integral_mul_cexp_neg_mul_sq hb]
      field_simp [(by
          contrapose! hb
          rw [hb, zero_re] : b ≠ 0)]
      ring
    
#align integral_gaussian_sq_complex integral_gaussian_sq_complex

theorem integral_gaussian (b : ℝ) : (∫ x, exp (-b * x ^ 2)) = sqrt (π / b) :=
  by
  -- First we deal with the crazy case where `b ≤ 0`: then both sides vanish.
  rcases le_or_lt b 0 with (hb | hb)
  · rw [integral_undef, sqrt_eq_zero_of_nonpos]
    · exact div_nonpos_of_nonneg_of_nonpos pi_pos.le hb
    · simpa only [not_lt, integrable_exp_neg_mul_sq_iff] using hb
  -- Assume now `b > 0`. Then both sides are non-negative and their squares agree.
  refine' (sq_eq_sq _ (sqrt_nonneg _)).1 _
  · exact integral_nonneg fun x => (exp_pos _).le
  rw [← of_real_inj, of_real_pow, ← integral_of_real, sq_sqrt (div_pos pi_pos hb).le, of_real_div]
  convert integral_gaussian_sq_complex (by rwa [of_real_re] : 0 < (b : ℂ).re)
  ext1 x
  rw [of_real_exp, of_real_mul, of_real_pow, of_real_neg]
#align integral_gaussian integral_gaussian

theorem continuousAt_gaussian_integral (b : ℂ) (hb : 0 < re b) :
    ContinuousAt (fun c : ℂ => ∫ x : ℝ, cexp (-c * x ^ 2)) b :=
  by
  let f : ℂ → ℝ → ℂ := fun (c : ℂ) (x : ℝ) => cexp (-c * x ^ 2)
  obtain ⟨d, hd, hd'⟩ := exists_between hb
  have f_meas : ∀ c : ℂ, ae_strongly_measurable (f c) volume := fun c =>
    by
    apply Continuous.aeStronglyMeasurable
    exact complex.continuous_exp.comp (continuous_const.mul (continuous_of_real.pow 2))
  have f_int : integrable (f b) volume :=
    by
    simp_rw [← integrable_norm_iff (f_meas b), norm_cexp_neg_mul_sq b]
    exact integrableExpNegMulSq hb
  have f_cts : ∀ x : ℝ, ContinuousAt (fun c => f c x) b := fun x =>
    (complex.continuous_exp.comp (continuous_id'.neg.mul continuous_const)).ContinuousAt
  have f_le_bd : ∀ᶠ c : ℂ in 𝓝 b, ∀ᵐ x : ℝ, ‖f c x‖ ≤ exp (-d * x ^ 2) :=
    by
    refine' eventually_of_mem ((continuous_re.is_open_preimage _ isOpen_Ioi).mem_nhds hd') _
    refine' fun c hc => ae_of_all _ fun x => _
    rw [norm_cexp_neg_mul_sq, exp_le_exp]
    exact mul_le_mul_of_nonneg_right (neg_le_neg (le_of_lt hc)) (sq_nonneg _)
  exact
    continuous_at_of_dominated (eventually_of_forall f_meas) f_le_bd (integrableExpNegMulSq hd)
      (ae_of_all _ f_cts)
#align continuous_at_gaussian_integral continuousAt_gaussian_integral

theorem integral_gaussian_complex {b : ℂ} (hb : 0 < re b) :
    (∫ x : ℝ, cexp (-b * x ^ 2)) = (π / b) ^ (1 / 2 : ℂ) :=
  by
  have nv : ∀ {b : ℂ}, 0 < re b → b ≠ 0 := by
    intro b hb
    contrapose! hb
    rw [hb]
    simp
  refine'
    (convex_halfspace_re_gt 0).IsPreconnected.eq_of_sq_eq _ _ (fun c hc => _) (fun c hc => _)
      (by simp : 0 < re (1 : ℂ)) _ hb
  ·-- integral is continuous
    exact ContinuousAt.continuousOn continuousAt_gaussian_integral
  · -- `(π / b) ^ (1 / 2 : ℂ)` is continuous
    refine'
      ContinuousAt.continuousOn fun b hb =>
        (continuousAt_cpow_const (Or.inl _)).comp (continuous_at_const.div continuousAt_id (nv hb))
    rw [div_re, of_real_im, of_real_re, zero_mul, zero_div, add_zero]
    exact div_pos (mul_pos pi_pos hb) (norm_sq_pos.mpr (nv hb))
  · -- squares of both sides agree
    dsimp only [Pi.pow_apply]
    rw [integral_gaussian_sq_complex hc, sq]
    conv_lhs => rw [← cpow_one (↑π / c)]
    rw [← cpow_add _ _ (div_ne_zero (of_real_ne_zero.mpr pi_ne_zero) (nv hc))]
    norm_num
  · -- RHS doesn't vanish
    rw [Ne.def, cpow_eq_zero_iff, not_and_or]
    exact Or.inl (div_ne_zero (of_real_ne_zero.mpr pi_ne_zero) (nv hc))
  · -- equality at 1
    have : ∀ x : ℝ, cexp (-1 * x ^ 2) = exp (-1 * x ^ 2) :=
      by
      intro x
      simp only [of_real_exp, neg_mul, one_mul, of_real_neg, of_real_pow]
    simp_rw [this, integral_of_real]
    conv_rhs =>
      congr
      rw [← of_real_one, ← of_real_div]
      skip
      rw [← of_real_one, ← of_real_bit0, ← of_real_div]
    rw [← of_real_cpow, of_real_inj]
    convert integral_gaussian (1 : ℝ)
    · rwa [sqrt_eq_rpow]
    · rw [div_one]
      exact pi_pos.le
#align integral_gaussian_complex integral_gaussian_complex

-- The Gaussian integral on the half-line, `∫ x in Ioi 0, exp (-b * x^2)`, for complex `b`.
theorem integral_gaussian_complex_Ioi {b : ℂ} (hb : 0 < re b) :
    (∫ x : ℝ in Ioi 0, cexp (-b * x ^ 2)) = (π / b) ^ (1 / 2 : ℂ) / 2 :=
  by
  have full_integral := integral_gaussian_complex hb
  have : MeasurableSet (Ioi (0 : ℝ)) := measurableSet_Ioi
  rw [← integral_add_compl this (integrableCexpNegMulSq hb), compl_Ioi] at full_integral
  suffices (∫ x : ℝ in Iic 0, cexp (-b * x ^ 2)) = ∫ x : ℝ in Ioi 0, cexp (-b * x ^ 2)
    by
    rw [this, ← mul_two] at full_integral
    rwa [eq_div_iff]
    exact two_ne_zero
  have : ∀ c : ℝ, (∫ x in 0 ..c, cexp (-b * x ^ 2)) = ∫ x in -c..0, cexp (-b * x ^ 2) :=
    by
    intro c
    have := @intervalIntegral.integral_comp_sub_left _ _ _ _ 0 c (fun x => cexp (-b * x ^ 2)) 0
    simpa [zero_sub, neg_sq, neg_zero] using this
  have t1 :=
    interval_integral_tendsto_integral_Ioi _ (integrableCexpNegMulSq hb).IntegrableOn tendsto_id
  have t2 :
    tendsto (fun c : ℝ => ∫ x : ℝ in 0 ..c, cexp (-b * x ^ 2)) at_top
      (𝓝 (∫ x : ℝ in Iic 0, cexp (-b * x ^ 2))) :=
    by
    simp_rw [this]
    refine' interval_integral_tendsto_integral_Iic _ _ tendsto_neg_at_top_at_bot
    apply (integrableCexpNegMulSq hb).IntegrableOn
  exact tendsto_nhds_unique t2 t1
#align integral_gaussian_complex_Ioi integral_gaussian_complex_Ioi

-- The Gaussian integral on the half-line, `∫ x in Ioi 0, exp (-b * x^2)`, for real `b`.
theorem integral_gaussian_Ioi (b : ℝ) : (∫ x in Ioi 0, exp (-b * x ^ 2)) = sqrt (π / b) / 2 :=
  by
  rcases le_or_lt b 0 with (hb | hb)
  · rw [integral_undef, sqrt_eq_zero_of_nonpos, zero_div]
    exact div_nonpos_of_nonneg_of_nonpos pi_pos.le hb
    rwa [← integrable_on, integrableOn_Ioi_exp_neg_mul_sq_iff, not_lt]
  rw [← of_real_inj, ← integral_of_real]
  convert integral_gaussian_complex_Ioi (by rwa [of_real_re] : 0 < (b : ℂ).re)
  · ext1 x
    simp
  · rw [sqrt_eq_rpow, ← of_real_div, of_real_div, of_real_cpow]
    norm_num
    exact (div_pos pi_pos hb).le
#align integral_gaussian_Ioi integral_gaussian_Ioi

/-- The special-value formula `Γ(1/2) = √π`, which is equivalent to the Gaussian integral. -/
theorem Real.gamma_one_half_eq : Real.gamma (1 / 2) = sqrt π :=
  by
  rw [Gamma_eq_integral one_half_pos, ← integral_comp_rpow_Ioi_of_pos zero_lt_two]
  convert congr_arg (fun x : ℝ => 2 * x) (integral_gaussian_Ioi 1)
  · rw [← integral_mul_left]
    refine' set_integral_congr measurableSet_Ioi fun x hx => _
    dsimp only
    have : (x ^ (2 : ℝ)) ^ (1 / (2 : ℝ) - 1) = x⁻¹ :=
      by
      rw [← rpow_mul (le_of_lt hx)]
      norm_num
      rw [rpow_neg (le_of_lt hx), rpow_one]
    rw [smul_eq_mul, this]
    field_simp [(ne_of_lt hx).symm]
    norm_num
    ring
  · rw [div_one, ← mul_div_assoc, mul_comm, mul_div_cancel _ (two_ne_zero' ℝ)]
#align real.Gamma_one_half_eq Real.gamma_one_half_eq

/-- The special-value formula `Γ(1/2) = √π`, which is equivalent to the Gaussian integral. -/
theorem Complex.gamma_one_half_eq : Complex.gamma (1 / 2) = π ^ (1 / 2 : ℂ) :=
  by
  convert congr_arg coe Real.gamma_one_half_eq
  · simpa only [one_div, of_real_inv, of_real_bit0] using Gamma_of_real (1 / 2)
  · rw [sqrt_eq_rpow, of_real_cpow pi_pos.le, of_real_div, of_real_bit0, of_real_one]
#align complex.Gamma_one_half_eq Complex.gamma_one_half_eq

namespace GaussianFourier

/-! ## Fourier transform of the Gaussian integral
-/


open intervalIntegral

open Real

variable {b : ℂ}

/-- The integral of the Gaussian function over the vertical edges of a rectangle
with vertices at `(±T, 0)` and `(±T, c)`.  -/
def verticalIntegral (b : ℂ) (c T : ℝ) : ℂ :=
  ∫ y : ℝ in 0 ..c, i * (cexp (-b * (T + y * i) ^ 2) - cexp (-b * (T - y * i) ^ 2))
#align gaussian_fourier.vertical_integral GaussianFourier.verticalIntegral

/-- Explicit formula for the norm of the Gaussian function along the vertical
edges. -/
theorem norm_cexp_neg_mul_sq_add_mul_i (b : ℂ) (c T : ℝ) :
    ‖cexp (-b * (T + c * i) ^ 2)‖ = exp (-(b.re * T ^ 2 - 2 * b.im * c * T - b.re * c ^ 2)) :=
  by
  rw [Complex.norm_eq_abs, Complex.abs_exp, neg_mul, neg_re, ← re_add_im b]
  simp only [sq, re_add_im, mul_re, mul_im, add_re, add_im, of_real_re, of_real_im, I_re, I_im]
  ring_nf
#align gaussian_fourier.norm_cexp_neg_mul_sq_add_mul_I GaussianFourier.norm_cexp_neg_mul_sq_add_mul_i

theorem norm_cexp_neg_mul_sq_add_mul_I' (hb : b.re ≠ 0) (c T : ℝ) :
    ‖cexp (-b * (T + c * i) ^ 2)‖ =
      exp (-(b.re * (T - b.im * c / b.re) ^ 2 - c ^ 2 * (b.im ^ 2 / b.re + b.re))) :=
  by
  have :
    b.re * T ^ 2 - 2 * b.im * c * T - b.re * c ^ 2 =
      b.re * (T - b.im * c / b.re) ^ 2 - c ^ 2 * (b.im ^ 2 / b.re + b.re) :=
    by
    field_simp
    ring
  rw [norm_cexp_neg_mul_sq_add_mul_I, this]
#align gaussian_fourier.norm_cexp_neg_mul_sq_add_mul_I' GaussianFourier.norm_cexp_neg_mul_sq_add_mul_I'

theorem verticalIntegral_norm_le (hb : 0 < b.re) (c : ℝ) {T : ℝ} (hT : 0 ≤ T) :
    ‖verticalIntegral b c T‖ ≤
      2 * |c| * exp (-(b.re * T ^ 2 - 2 * |b.im| * |c| * T - b.re * c ^ 2)) :=
  by
  -- first get uniform bound for integrand
  have vert_norm_bound :
    ∀ {T : ℝ},
      0 ≤ T →
        ∀ {c y : ℝ},
          |y| ≤ |c| →
            ‖cexp (-b * (T + y * I) ^ 2)‖ ≤
              exp (-(b.re * T ^ 2 - 2 * |b.im| * |c| * T - b.re * c ^ 2)) :=
    by
    intro T hT c y hy
    rw [norm_cexp_neg_mul_sq_add_mul_I b, exp_le_exp, neg_le_neg_iff]
    refine' sub_le_sub (sub_le_sub (le_refl _) (mul_le_mul_of_nonneg_right _ hT)) _
    · conv_lhs => rw [mul_assoc]
      conv_rhs => rw [mul_assoc]
      refine' mul_le_mul_of_nonneg_left ((le_abs_self _).trans _) zero_le_two
      rw [abs_mul]
      exact mul_le_mul_of_nonneg_left hy (abs_nonneg _)
    · refine' mul_le_mul_of_nonneg_left _ hb.le
      rwa [sq_le_sq]
  -- now main proof
  refine' (intervalIntegral.norm_integral_le_of_norm_le_const _).trans _
  pick_goal 3
  · rw [sub_zero]
    conv_lhs => rw [mul_comm]
    conv_rhs =>
      conv =>
        congr
        rw [mul_comm]
      rw [mul_assoc]
  · intro y hy
    have absy : |y| ≤ |c| := by
      rcases le_or_lt 0 c with ⟨⟩
      · rw [uIoc_of_le h] at hy
        rw [abs_of_nonneg h, abs_of_pos hy.1]
        exact hy.2
      · rw [uIoc_of_lt h] at hy
        rw [abs_of_neg h, abs_of_nonpos hy.2, neg_le_neg_iff]
        exact hy.1.le
    rw [norm_mul, Complex.norm_eq_abs, abs_I, one_mul, two_mul]
    refine' (norm_sub_le _ _).trans (add_le_add (vert_norm_bound hT absy) _)
    rw [← abs_neg y] at absy
    simpa only [neg_mul, of_real_neg] using vert_norm_bound hT absy
#align gaussian_fourier.vertical_integral_norm_le GaussianFourier.verticalIntegral_norm_le

theorem tendsto_verticalIntegral (hb : 0 < b.re) (c : ℝ) :
    Tendsto (verticalIntegral b c) atTop (𝓝 0) :=
  by
  -- complete proof using squeeze theorem:
  rw [tendsto_zero_iff_norm_tendsto_zero]
  refine'
    tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds _
      (eventually_of_forall fun _ => norm_nonneg _)
      ((eventually_ge_at_top (0 : ℝ)).mp
        (eventually_of_forall fun T hT => vertical_integral_norm_le hb c hT))
  rw [(by ring : 0 = 2 * |c| * 0)]
  refine' (tendsto_exp_at_bot.comp (tendsto_neg_at_top_at_bot.comp _)).const_mul _
  apply tendsto_at_top_add_const_right
  simp_rw [sq, ← mul_assoc, ← sub_mul]
  refine' tendsto.at_top_mul_at_top (tendsto_at_top_add_const_right _ _ _) tendsto_id
  exact (tendsto_const_mul_at_top_of_pos hb).mpr tendsto_id
#align gaussian_fourier.tendsto_vertical_integral GaussianFourier.tendsto_verticalIntegral

theorem integrableCexpNegMulSqAddRealMulI (hb : 0 < b.re) (c : ℝ) :
    Integrable fun x : ℝ => cexp (-b * (x + c * i) ^ 2) :=
  by
  refine'
    ⟨(complex.continuous_exp.comp
          (continuous_const.mul
            ((continuous_of_real.add continuous_const).pow 2))).AeStronglyMeasurable,
      _⟩
  rw [← has_finite_integral_norm_iff]
  simp_rw [norm_cexp_neg_mul_sq_add_mul_I' hb.ne', neg_sub _ (c ^ 2 * _),
    sub_eq_add_neg _ (b.re * _), Real.exp_add]
  suffices integrable fun x : ℝ => exp (-(b.re * x ^ 2)) by
    exact (integrable.comp_sub_right this (b.im * c / b.re)).HasFiniteIntegral.const_mul _
  simp_rw [← neg_mul]
  apply integrableExpNegMulSq hb
#align gaussian_fourier.integrable_cexp_neg_mul_sq_add_real_mul_I GaussianFourier.integrableCexpNegMulSqAddRealMulI

theorem integral_cexp_neg_mul_sq_add_real_mul_i (hb : 0 < b.re) (c : ℝ) :
    (∫ x : ℝ, cexp (-b * (x + c * i) ^ 2)) = (π / b) ^ (1 / 2 : ℂ) :=
  by
  refine'
    tendsto_nhds_unique
      (interval_integral_tendsto_integral (integrable_cexp_neg_mul_sq_add_real_mul_I hb c)
        tendsto_neg_at_top_at_bot tendsto_id)
      _
  set I₁ := fun T => ∫ x : ℝ in -T..T, cexp (-b * (x + c * I) ^ 2) with HI₁
  let I₂ := fun T : ℝ => ∫ x : ℝ in -T..T, cexp (-b * x ^ 2)
  let I₄ := fun T : ℝ => ∫ y : ℝ in 0 ..c, cexp (-b * (T + y * I) ^ 2)
  let I₅ := fun T : ℝ => ∫ y : ℝ in 0 ..c, cexp (-b * (-T + y * I) ^ 2)
  have C : ∀ T : ℝ, I₂ T - I₁ T + I * I₄ T - I * I₅ T = 0 :=
    by
    intro T
    have :=
      integral_boundary_rect_eq_zero_of_differentiable_on (fun z => cexp (-b * z ^ 2)) (-T)
        (T + c * I)
        (by
          refine' Differentiable.differentiableOn (Differentiable.const_mul _ _).cexp
          exact differentiable_pow 2)
    simpa only [neg_im, of_real_im, neg_zero, of_real_zero, zero_mul, add_zero, neg_re, of_real_re,
      add_re, mul_re, I_re, mul_zero, I_im, tsub_zero, add_im, mul_im, mul_one, zero_add,
      Algebra.id.smul_eq_mul, of_real_neg] using this
  simp_rw [id.def, ← HI₁]
  have : I₁ = fun T : ℝ => I₂ T + vertical_integral b c T :=
    by
    ext1 T
    specialize C T
    rw [sub_eq_zero] at C
    unfold vertical_integral
    rw [integral_const_mul, intervalIntegral.integral_sub]
    · simp_rw [(fun a b => by
          rw [sq]
          ring_nf : ∀ a b : ℂ, (a - b * I) ^ 2 = (-a + b * I) ^ 2)]
      change I₁ T = I₂ T + I * (I₄ T - I₅ T)
      rw [mul_sub, ← C]
      abel
    all_goals apply Continuous.intervalIntegrable; continuity
  rw [this, ← add_zero ((π / b : ℂ) ^ (1 / 2 : ℂ)), ← integral_gaussian_complex hb]
  refine' tendsto.add _ (tendsto_vertical_integral hb c)
  exact
    interval_integral_tendsto_integral (integrableCexpNegMulSq hb) tendsto_neg_at_top_at_bot
      tendsto_id
#align gaussian_fourier.integral_cexp_neg_mul_sq_add_real_mul_I GaussianFourier.integral_cexp_neg_mul_sq_add_real_mul_i

theorem integral_cexp_neg_mul_sq_add_const (hb : 0 < b.re) (c : ℂ) :
    (∫ x : ℝ, cexp (-b * (x + c) ^ 2)) = (π / b) ^ (1 / 2 : ℂ) :=
  by
  rw [← re_add_im c]
  simp_rw [← add_assoc, ← of_real_add]
  rw [integral_add_right_eq_self fun x : ℝ => cexp (-b * (↑x + ↑c.im * I) ^ 2)]
  · apply integral_cexp_neg_mul_sq_add_real_mul_I hb
  · infer_instance
#align integral_cexp_neg_mul_sq_add_const integral_cexp_neg_mul_sq_add_const

theorem fourier_transform_gaussian (hb : 0 < b.re) (t : ℂ) :
    (∫ x : ℝ, cexp (i * t * x) * cexp (-b * x ^ 2)) =
      cexp (-t ^ 2 / (4 * b)) * (π / b) ^ (1 / 2 : ℂ) :=
  by
  have : b ≠ 0 := by
    contrapose! hb
    rw [hb, zero_re]
  simp_rw [← Complex.exp_add]
  have : ∀ x : ℂ, I * t * x + -b * x ^ 2 = -t ^ 2 / (4 * b) + -b * (x + -I * t / 2 / b) ^ 2 :=
    by
    intro x
    ring_nf
    rw [I_sq]
    field_simp
    ring
  simp_rw [this, Complex.exp_add, integral_mul_left, integral_cexp_neg_mul_sq_add_const hb]
#align fourier_transform_gaussian fourier_transform_gaussian

theorem fourier_transform_gaussian_pi (hb : 0 < b.re) (t : ℂ) :
    (∫ x : ℝ, cexp (2 * π * i * t * x) * cexp (-π * b * x ^ 2)) =
      1 / b ^ (1 / 2 : ℂ) * cexp (-π * (1 / b) * t ^ 2) :=
  by
  have h1 : 0 < re (π * b) := by
    rw [of_real_mul_re]
    exact mul_pos pi_pos hb
  have h2 : b ≠ 0 := by
    contrapose! hb
    rw [hb, zero_re]
  convert _root_.fourier_transform_gaussian h1 (2 * π * t) using 1
  · congr 1
    ext1 x
    congr 2
    all_goals ring
  · conv_lhs => rw [mul_comm]
    congr 2
    · field_simp [of_real_ne_zero.mpr pi_ne_zero]
      ring
    · rw [← div_div, div_self (of_real_ne_zero.mpr pi_ne_zero), cpow_def_of_ne_zero h2,
        cpow_def_of_ne_zero (one_div_ne_zero h2), one_div, ← Complex.exp_neg, ← neg_mul]
      congr 2
      rw [one_div, Complex.log_inv]
      rw [Ne.def, arg_eq_pi_iff, not_and_or, not_lt]
      exact Or.inl hb.le
#align fourier_transform_gaussian_pi fourier_transform_gaussian_pi

end GaussianFourier

