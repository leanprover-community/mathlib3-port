/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.special_functions.compare_exp
! leanprover-community/mathlib commit 46a64b5b4268c594af770c44d9e502afc6a515cb
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecialFunctions.Pow
import Mathbin.Analysis.Asymptotics.SpecificAsymptotics

/-!
# Growth estimates on `x ^ y` for complex `x`, `y`

Let `l` be a filter on `ℂ` such that `complex.re` tends to infinity along `l` and `complex.im z`
grows at a subexponential rate compared to `complex.re z`. Then

- `complex.is_o_log_abs_re_of_subexponential_im_re`: `real.log ∘ complex.abs` is `o`-small of
  `complex.re` along `l`;

- `complex.is_o_cpow_mul_exp`: $z^{a_1}e^{b_1 * z} = o\left(z^{a_1}e^{b_1 * z}\right)$ along `l`
  for any complex `a₁`, `a₂` and real `b₁ < b₂`.

We use these assumptions on `l` for two reasons. First, these are the assumptions that naturally
appear in the proof. Second, in some applications (e.g., in Ilyashenko's proof of the individual
finiteness theorem for limit cycles of polynomial ODEs with hyperbolic singularities only) natural
stronger assumptions (e.g., `im z` is bounded from below and from above) are not available.

-/


open Asymptotics Filter Function

open TopologicalSpace

namespace Complex

/-- We say that `l : filter ℂ` is an *exponential comparison filter* if the real part tends to
infinity along `l` and the imaginary part grows subexponentially compared to the real part. These
properties guarantee that `(λ z, z ^ a₁ * exp (b₁ * z)) =o[l] (λ z, z ^ a₂ * exp (b₂ * z))` for any
complex `a₁`, `a₂` and real `b₁ < b₂`.

In particular, the second property is automatically satisfied if the imaginary part is bounded along
`l`. -/
structure IsExpCmpFilter (l : Filter ℂ) : Prop where
  tendsto_re : Tendsto re l atTop
  is_O_im_pow_re : ∀ n : ℕ, (fun z : ℂ => z.im ^ n) =O[l] fun z => Real.exp z.re
#align complex.is_exp_cmp_filter Complex.IsExpCmpFilter

namespace IsExpCmpFilter

variable {l : Filter ℂ}

/-!
### Alternative constructors
-/


theorem of_is_O_im_re_rpow (hre : Tendsto re l atTop) (r : ℝ) (hr : im =O[l] fun z => z.re ^ r) :
    IsExpCmpFilter l :=
  ⟨hre, fun n =>
    is_o.is_O <|
      calc
        (fun z : ℂ => z.im ^ n) =O[l] fun z => (z.re ^ r) ^ n := hr.pow n
        _ =ᶠ[l] fun z => z.re ^ (r * n) :=
          (hre.eventually_ge_at_top 0).mono fun z hz => by
            simp only [Real.rpow_mul hz r n, Real.rpow_nat_cast]
        _ =o[l] fun z => Real.exp z.re := (is_o_rpow_exp_at_top _).comp_tendsto hre
        ⟩
#align complex.is_exp_cmp_filter.of_is_O_im_re_rpow Complex.IsExpCmpFilter.of_is_O_im_re_rpow

theorem of_is_O_im_re_pow (hre : Tendsto re l atTop) (n : ℕ) (hr : im =O[l] fun z => z.re ^ n) :
    IsExpCmpFilter l :=
  of_is_O_im_re_rpow hre n <| by simpa only [Real.rpow_nat_cast]
#align complex.is_exp_cmp_filter.of_is_O_im_re_pow Complex.IsExpCmpFilter.of_is_O_im_re_pow

theorem of_bounded_under_abs_im (hre : Tendsto re l atTop)
    (him : IsBoundedUnder (· ≤ ·) l fun z => |z.im|) : IsExpCmpFilter l :=
  of_is_O_im_re_pow hre 0 <| by
    simpa only [pow_zero] using @is_bounded_under.is_O_const ℂ ℝ ℝ _ _ _ l him 1 one_ne_zero
#align
  complex.is_exp_cmp_filter.of_bounded_under_abs_im Complex.IsExpCmpFilter.of_bounded_under_abs_im

theorem of_bounded_under_im (hre : Tendsto re l atTop) (him_le : IsBoundedUnder (· ≤ ·) l im)
    (him_ge : IsBoundedUnder (· ≥ ·) l im) : IsExpCmpFilter l :=
  of_bounded_under_abs_im hre <| is_bounded_under_le_abs.2 ⟨him_le, him_ge⟩
#align complex.is_exp_cmp_filter.of_bounded_under_im Complex.IsExpCmpFilter.of_bounded_under_im

/-!
### Preliminary lemmas
-/


theorem eventually_ne (hl : IsExpCmpFilter l) : ∀ᶠ w : ℂ in l, w ≠ 0 :=
  hl.tendsto_re.eventually_ne_at_top' _
#align complex.is_exp_cmp_filter.eventually_ne Complex.IsExpCmpFilter.eventually_ne

theorem tendsto_abs_re (hl : IsExpCmpFilter l) : Tendsto (fun z : ℂ => |z.re|) l atTop :=
  tendsto_abs_at_top_at_top.comp hl.tendsto_re
#align complex.is_exp_cmp_filter.tendsto_abs_re Complex.IsExpCmpFilter.tendsto_abs_re

theorem tendsto_abs (hl : IsExpCmpFilter l) : Tendsto abs l atTop :=
  tendsto_at_top_mono abs_re_le_abs hl.tendsto_abs_re
#align complex.is_exp_cmp_filter.tendsto_abs Complex.IsExpCmpFilter.tendsto_abs

theorem is_o_log_re_re (hl : IsExpCmpFilter l) : (fun z => Real.log z.re) =o[l] re :=
  Real.is_o_log_id_at_top.comp_tendsto hl.tendsto_re
#align complex.is_exp_cmp_filter.is_o_log_re_re Complex.IsExpCmpFilter.is_o_log_re_re

theorem is_o_im_pow_exp_re (hl : IsExpCmpFilter l) (n : ℕ) :
    (fun z : ℂ => z.im ^ n) =o[l] fun z => Real.exp z.re :=
  flip IsO.of_pow two_ne_zero <|
    calc
      (fun z : ℂ => (z.im ^ n) ^ 2) = fun z => z.im ^ (2 * n) := by simp only [pow_mul']
      _ =O[l] fun z => Real.exp z.re := hl.is_O_im_pow_re _
      _ = fun z => Real.exp z.re ^ 1 := by simp only [pow_one]
      _ =o[l] fun z => Real.exp z.re ^ 2 :=
        (is_o_pow_pow_at_top_of_lt one_lt_two).comp_tendsto <|
          Real.tendsto_exp_at_top.comp hl.tendsto_re
      
#align complex.is_exp_cmp_filter.is_o_im_pow_exp_re Complex.IsExpCmpFilter.is_o_im_pow_exp_re

theorem abs_im_pow_eventually_le_exp_re (hl : IsExpCmpFilter l) (n : ℕ) :
    (fun z : ℂ => |z.im| ^ n) ≤ᶠ[l] fun z => Real.exp z.re := by
  simpa using (hl.is_o_im_pow_exp_re n).bound zero_lt_one
#align
  complex.is_exp_cmp_filter.abs_im_pow_eventually_le_exp_re Complex.IsExpCmpFilter.abs_im_pow_eventually_le_exp_re

/-- If `l : filter ℂ` is an "exponential comparison filter", then $\log |z| =o(ℜ z)$ along `l`.
This is the main lemma in the proof of `complex.is_exp_cmp_filter.is_o_cpow_exp` below.
-/
theorem is_o_log_abs_re (hl : IsExpCmpFilter l) : (fun z => Real.log (abs z)) =o[l] re :=
  calc
    (fun z => Real.log (abs z)) =O[l] fun z =>
        Real.log (Real.sqrt 2) + Real.log (max z.re (|z.im|)) :=
      IsO.of_bound 1 <|
        (hl.tendsto_re.eventually_ge_at_top 1).mono fun z hz =>
          by
          have h2 : 0 < Real.sqrt 2 := by simp
          have hz' : 1 ≤ abs z := hz.trans (re_le_abs z)
          have hz₀ : 0 < abs z := one_pos.trans_le hz'
          have hm₀ : 0 < max z.re (|z.im|) := lt_max_iff.2 (Or.inl <| one_pos.trans_le hz)
          rw [one_mul, Real.norm_eq_abs, _root_.abs_of_nonneg (Real.log_nonneg hz')]
          refine' le_trans _ (le_abs_self _)
          rw [← Real.log_mul, Real.log_le_log, ← _root_.abs_of_nonneg (le_trans zero_le_one hz)]
          exacts[abs_le_sqrt_two_mul_max z, one_pos.trans_le hz', mul_pos h2 hm₀, h2.ne', hm₀.ne']
    _ =o[l] re :=
      IsO.add (is_o_const_left.2 <| Or.inr <| hl.tendsto_abs_re) <|
        is_o_iff_nat_mul_le.2 fun n =>
          by
          filter_upwards [is_o_iff_nat_mul_le.1 hl.is_o_log_re_re n,
            hl.abs_im_pow_eventually_le_exp_re n,
            hl.tendsto_re.eventually_gt_at_top 1] with z hre him h₁
          cases' le_total (|z.im|) z.re with hle hle
          · rwa [max_eq_left hle]
          · have H : 1 < |z.im| := h₁.trans_le hle
            rwa [max_eq_right hle, Real.norm_eq_abs, Real.norm_eq_abs, abs_of_pos (Real.log_pos H),
              ← Real.log_pow, Real.log_le_iff_le_exp (pow_pos (one_pos.trans H) _),
              abs_of_pos (one_pos.trans h₁)]
    
#align complex.is_exp_cmp_filter.is_o_log_abs_re Complex.IsExpCmpFilter.is_o_log_abs_re

/-!
### Main results
-/


/-- If `l : filter ℂ` is an "exponential comparison filter", then for any complex `a` and any
positive real `b`, we have `(λ z, z ^ a) =o[l] (λ z, exp (b * z))`. -/
theorem is_o_cpow_exp (hl : IsExpCmpFilter l) (a : ℂ) {b : ℝ} (hb : 0 < b) :
    (fun z => z ^ a) =o[l] fun z => exp (b * z) :=
  calc
    (fun z => z ^ a) =Θ[l] fun z => abs z ^ re a :=
      is_Theta_cpow_const_rpow fun _ _ => hl.eventually_ne
    _ =ᶠ[l] fun z => Real.exp (re a * Real.log (abs z)) :=
      hl.eventually_ne.mono fun z hz => by simp only [Real.rpow_def_of_pos, abs.pos hz, mul_comm]
    _ =o[l] fun z => exp (b * z) :=
      is_o.of_norm_right <|
        by
        simp only [norm_eq_abs, abs_exp, of_real_mul_re, Real.is_o_exp_comp_exp_comp]
        refine'
          (is_equivalent.refl.sub_is_o _).symm.tendsto_at_top (hl.tendsto_re.const_mul_at_top hb)
        exact (hl.is_o_log_abs_re.const_mul_left _).const_mul_right hb.ne'
    
#align complex.is_exp_cmp_filter.is_o_cpow_exp Complex.IsExpCmpFilter.is_o_cpow_exp

/-- If `l : filter ℂ` is an "exponential comparison filter", then for any complex `a₁`, `a₂` and any
real `b₁ < b₂`, we have `(λ z, z ^ a₁ * exp (b₁ * z)) =o[l] (λ z, z ^ a₂ * exp (b₂ * z))`. -/
theorem is_o_cpow_mul_exp {b₁ b₂ : ℝ} (hl : IsExpCmpFilter l) (hb : b₁ < b₂) (a₁ a₂ : ℂ) :
    (fun z => z ^ a₁ * exp (b₁ * z)) =o[l] fun z => z ^ a₂ * exp (b₂ * z) :=
  calc
    (fun z => z ^ a₁ * exp (b₁ * z)) =ᶠ[l] fun z => z ^ a₂ * exp (b₁ * z) * z ^ (a₁ - a₂) :=
      hl.eventually_ne.mono fun z hz => by
        simp only
        rw [mul_right_comm, ← cpow_add _ _ hz, add_sub_cancel'_right]
    _ =o[l] fun z => z ^ a₂ * exp (b₁ * z) * exp (↑(b₂ - b₁) * z) :=
      (is_O_refl (fun z => z ^ a₂ * exp (b₁ * z)) l).mul_is_o <| hl.is_o_cpow_exp _ (sub_pos.2 hb)
    _ =ᶠ[l] fun z => z ^ a₂ * exp (b₂ * z) := by
      simp only [of_real_sub, sub_mul, mul_assoc, ← exp_add, add_sub_cancel'_right]
    
#align complex.is_exp_cmp_filter.is_o_cpow_mul_exp Complex.IsExpCmpFilter.is_o_cpow_mul_exp

/-- If `l : filter ℂ` is an "exponential comparison filter", then for any complex `a` and any
negative real `b`, we have `(λ z, exp (b * z)) =o[l] (λ z, z ^ a)`. -/
theorem is_o_exp_cpow (hl : IsExpCmpFilter l) (a : ℂ) {b : ℝ} (hb : b < 0) :
    (fun z => exp (b * z)) =o[l] fun z => z ^ a := by simpa using hl.is_o_cpow_mul_exp hb 0 a
#align complex.is_exp_cmp_filter.is_o_exp_cpow Complex.IsExpCmpFilter.is_o_exp_cpow

/-- If `l : filter ℂ` is an "exponential comparison filter", then for any complex `a₁`, `a₂` and any
natural `b₁ < b₂`, we have `(λ z, z ^ a₁ * exp (b₁ * z)) =o[l] (λ z, z ^ a₂ * exp (b₂ * z))`. -/
theorem is_o_pow_mul_exp {b₁ b₂ : ℝ} (hl : IsExpCmpFilter l) (hb : b₁ < b₂) (m n : ℕ) :
    (fun z => z ^ m * exp (b₁ * z)) =o[l] fun z => z ^ n * exp (b₂ * z) := by
  simpa only [cpow_nat_cast] using hl.is_o_cpow_mul_exp hb m n
#align complex.is_exp_cmp_filter.is_o_pow_mul_exp Complex.IsExpCmpFilter.is_o_pow_mul_exp

/-- If `l : filter ℂ` is an "exponential comparison filter", then for any complex `a₁`, `a₂` and any
integer `b₁ < b₂`, we have `(λ z, z ^ a₁ * exp (b₁ * z)) =o[l] (λ z, z ^ a₂ * exp (b₂ * z))`. -/
theorem is_o_zpow_mul_exp {b₁ b₂ : ℝ} (hl : IsExpCmpFilter l) (hb : b₁ < b₂) (m n : ℤ) :
    (fun z => z ^ m * exp (b₁ * z)) =o[l] fun z => z ^ n * exp (b₂ * z) := by
  simpa only [cpow_int_cast] using hl.is_o_cpow_mul_exp hb m n
#align complex.is_exp_cmp_filter.is_o_zpow_mul_exp Complex.IsExpCmpFilter.is_o_zpow_mul_exp

end IsExpCmpFilter

end Complex

