/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Abhimanyu Pallavi Sudhir, Jean Lo, Calle Sönne, Benjamin Davidson

! This file was ported from Lean 3 source module analysis.special_functions.trigonometric.complex_deriv
! leanprover-community/mathlib commit 198161d833f2c01498c39c266b0b3dbe2c7a8c07
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecialFunctions.Trigonometric.Complex
import Mathbin.Analysis.SpecialFunctions.Trigonometric.Deriv

/-!
# Complex trigonometric functions

Basic facts and derivatives for the complex trigonometric functions.
-/


noncomputable section

namespace Complex

open Set Filter

open Real

theorem hasStrictDerivAtTan {x : ℂ} (h : cos x ≠ 0) : HasStrictDerivAt tan (1 / cos x ^ 2) x := by
  convert (has_strict_deriv_at_sin x).div (has_strict_deriv_at_cos x) h
  rw [← sin_sq_add_cos_sq x]
  ring
#align complex.has_strict_deriv_at_tan Complex.hasStrictDerivAtTan

theorem hasDerivAtTan {x : ℂ} (h : cos x ≠ 0) : HasDerivAt tan (1 / cos x ^ 2) x :=
  (hasStrictDerivAtTan h).HasDerivAt
#align complex.has_deriv_at_tan Complex.hasDerivAtTan

open TopologicalSpace

theorem tendsto_abs_tan_of_cos_eq_zero {x : ℂ} (hx : cos x = 0) :
    Tendsto (fun x => abs (tan x)) (𝓝[≠] x) atTop := by
  simp only [tan_eq_sin_div_cos, ← norm_eq_abs, norm_div]
  have A : sin x ≠ 0 := fun h => by simpa [*, sq] using sin_sq_add_cos_sq x
  have B : tendsto cos (𝓝[≠] x) (𝓝[≠] 0) :=
    hx ▸ (has_deriv_at_cos x).tendsto_punctured_nhds (neg_ne_zero.2 A)
  exact
    continuous_sin.continuous_within_at.norm.mul_at_top (norm_pos_iff.2 A)
      (tendsto_norm_nhds_within_zero.comp B).inv_tendsto_zero
#align complex.tendsto_abs_tan_of_cos_eq_zero Complex.tendsto_abs_tan_of_cos_eq_zero

theorem tendsto_abs_tan_at_top (k : ℤ) :
    Tendsto (fun x => abs (tan x)) (𝓝[≠] ((2 * k + 1) * π / 2)) atTop :=
  tendsto_abs_tan_of_cos_eq_zero <| cos_eq_zero_iff.2 ⟨k, rfl⟩
#align complex.tendsto_abs_tan_at_top Complex.tendsto_abs_tan_at_top

@[simp]
theorem continuous_at_tan {x : ℂ} : ContinuousAt tan x ↔ cos x ≠ 0 := by
  refine' ⟨fun hc h₀ => _, fun h => (has_deriv_at_tan h).ContinuousAt⟩
  exact
    not_tendsto_nhds_of_tendsto_at_top (tendsto_abs_tan_of_cos_eq_zero h₀) _
      (hc.norm.tendsto.mono_left inf_le_left)
#align complex.continuous_at_tan Complex.continuous_at_tan

@[simp]
theorem differentiable_at_tan {x : ℂ} : DifferentiableAt ℂ tan x ↔ cos x ≠ 0 :=
  ⟨fun h => continuous_at_tan.1 h.ContinuousAt, fun h => (hasDerivAtTan h).DifferentiableAt⟩
#align complex.differentiable_at_tan Complex.differentiable_at_tan

@[simp]
theorem deriv_tan (x : ℂ) : deriv tan x = 1 / cos x ^ 2 :=
  if h : cos x = 0 then by
    have : ¬DifferentiableAt ℂ tan x := mt differentiable_at_tan.1 (not_not.2 h)
    simp [deriv_zero_of_not_differentiable_at this, h, sq]
  else (hasDerivAtTan h).deriv
#align complex.deriv_tan Complex.deriv_tan

@[simp]
theorem cont_diff_at_tan {x : ℂ} {n : ℕ∞} : ContDiffAt ℂ n tan x ↔ cos x ≠ 0 :=
  ⟨fun h => continuous_at_tan.1 h.ContinuousAt, contDiffSin.ContDiffAt.div contDiffCos.ContDiffAt⟩
#align complex.cont_diff_at_tan Complex.cont_diff_at_tan

end Complex

