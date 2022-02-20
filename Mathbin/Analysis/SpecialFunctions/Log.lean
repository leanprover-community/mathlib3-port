/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Abhimanyu Pallavi Sudhir, Jean Lo, Calle Sönne
-/
import Mathbin.Analysis.SpecialFunctions.Exp

/-!
# Real logarithm

In this file we define `real.log` to be the logarithm of a real number. As usual, we extend it from
its domain `(0, +∞)` to a globally defined function. We choose to do it so that `log 0 = 0` and
`log (-x) = log x`.

We prove some basic properties of this function and show that it is continuous.

## Tags

logarithm, continuity
-/


open Set Filter Function

open_locale TopologicalSpace

noncomputable section

namespace Real

variable {x y : ℝ}

/-- The real logarithm function, equal to the inverse of the exponential for `x > 0`,
to `log |x|` for `x < 0`, and to `0` for `0`. We use this unconventional extension to
`(-∞, 0]` as it gives the formula `log (x * y) = log x + log y` for all nonzero `x` and `y`, and
the derivative of `log` is `1/x` away from `0`. -/
@[pp_nodot]
noncomputable def log (x : ℝ) : ℝ :=
  if hx : x = 0 then 0 else expOrderIso.symm ⟨abs x, abs_pos.2 hx⟩

theorem log_of_ne_zero (hx : x ≠ 0) : log x = expOrderIso.symm ⟨abs x, abs_pos.2 hx⟩ :=
  dif_neg hx

theorem log_of_pos (hx : 0 < x) : log x = expOrderIso.symm ⟨x, hx⟩ := by
  rw [log_of_ne_zero hx.ne']
  congr
  exact abs_of_pos hx

theorem exp_log_eq_abs (hx : x ≠ 0) : exp (log x) = abs x := by
  rw [log_of_ne_zero hx, ← coe_exp_order_iso_apply, OrderIso.apply_symm_apply, Subtype.coe_mk]

theorem exp_log (hx : 0 < x) : exp (log x) = x := by
  rw [exp_log_eq_abs hx.ne']
  exact abs_of_pos hx

theorem exp_log_of_neg (hx : x < 0) : exp (log x) = -x := by
  rw [exp_log_eq_abs (ne_of_ltₓ hx)]
  exact abs_of_neg hx

@[simp]
theorem log_exp (x : ℝ) : log (exp x) = x :=
  exp_injective <| exp_log (exp_pos x)

theorem surj_on_log : SurjOn log (Ioi 0) Univ := fun x _ => ⟨exp x, exp_pos x, log_exp x⟩

theorem log_surjective : Surjective log := fun x => ⟨exp x, log_exp x⟩

@[simp]
theorem range_log : Range log = univ :=
  log_surjective.range_eq

@[simp]
theorem log_zero : log 0 = 0 :=
  dif_pos rfl

@[simp]
theorem log_one : log 1 = 0 :=
  exp_injective <| by
    rw [exp_log zero_lt_one, exp_zero]

@[simp]
theorem log_abs (x : ℝ) : log (abs x) = log x := by
  by_cases' h : x = 0
  · simp [h]
    
  · rw [← exp_eq_exp, exp_log_eq_abs h, exp_log_eq_abs (abs_pos.2 h).ne', abs_abs]
    

@[simp]
theorem log_neg_eq_log (x : ℝ) : log (-x) = log x := by
  rw [← log_abs x, ← log_abs (-x), abs_neg]

theorem surj_on_log' : SurjOn log (Iio 0) Univ := fun x _ =>
  ⟨-exp x, neg_lt_zero.2 <| exp_pos x, by
    rw [log_neg_eq_log, log_exp]⟩

theorem log_mul (hx : x ≠ 0) (hy : y ≠ 0) : log (x * y) = log x + log y :=
  exp_injective <| by
    rw [exp_log_eq_abs (mul_ne_zero hx hy), exp_add, exp_log_eq_abs hx, exp_log_eq_abs hy, abs_mul]

theorem log_div (hx : x ≠ 0) (hy : y ≠ 0) : log (x / y) = log x - log y :=
  exp_injective <| by
    rw [exp_log_eq_abs (div_ne_zero hx hy), exp_sub, exp_log_eq_abs hx, exp_log_eq_abs hy, abs_div]

@[simp]
theorem log_inv (x : ℝ) : log x⁻¹ = -log x := by
  by_cases' hx : x = 0
  · simp [hx]
    
  rw [← exp_eq_exp, exp_log_eq_abs (inv_ne_zero hx), exp_neg, exp_log_eq_abs hx, abs_inv]

theorem log_le_log (h : 0 < x) (h₁ : 0 < y) : log x ≤ log y ↔ x ≤ y := by
  rw [← exp_le_exp, exp_log h, exp_log h₁]

theorem log_lt_log (hx : 0 < x) : x < y → log x < log y := by
  intro h
  rwa [← exp_lt_exp, exp_log hx, exp_log (lt_transₓ hx h)]

theorem log_lt_log_iff (hx : 0 < x) (hy : 0 < y) : log x < log y ↔ x < y := by
  rw [← exp_lt_exp, exp_log hx, exp_log hy]

theorem log_le_iff_le_exp (hx : 0 < x) : log x ≤ y ↔ x ≤ exp y := by
  rw [← exp_le_exp, exp_log hx]

theorem log_lt_iff_lt_exp (hx : 0 < x) : log x < y ↔ x < exp y := by
  rw [← exp_lt_exp, exp_log hx]

theorem le_log_iff_exp_le (hy : 0 < y) : x ≤ log y ↔ exp x ≤ y := by
  rw [← exp_le_exp, exp_log hy]

theorem lt_log_iff_exp_lt (hy : 0 < y) : x < log y ↔ exp x < y := by
  rw [← exp_lt_exp, exp_log hy]

theorem log_pos_iff (hx : 0 < x) : 0 < log x ↔ 1 < x := by
  rw [← log_one]
  exact log_lt_log_iff zero_lt_one hx

theorem log_pos (hx : 1 < x) : 0 < log x :=
  (log_pos_iff (lt_transₓ zero_lt_one hx)).2 hx

theorem log_neg_iff (h : 0 < x) : log x < 0 ↔ x < 1 := by
  rw [← log_one]
  exact log_lt_log_iff h zero_lt_one

theorem log_neg (h0 : 0 < x) (h1 : x < 1) : log x < 0 :=
  (log_neg_iff h0).2 h1

theorem log_nonneg_iff (hx : 0 < x) : 0 ≤ log x ↔ 1 ≤ x := by
  rw [← not_ltₓ, log_neg_iff hx, not_ltₓ]

theorem log_nonneg (hx : 1 ≤ x) : 0 ≤ log x :=
  (log_nonneg_iff (zero_lt_one.trans_le hx)).2 hx

theorem log_nonpos_iff (hx : 0 < x) : log x ≤ 0 ↔ x ≤ 1 := by
  rw [← not_ltₓ, log_pos_iff hx, not_ltₓ]

theorem log_nonpos_iff' (hx : 0 ≤ x) : log x ≤ 0 ↔ x ≤ 1 := by
  rcases hx.eq_or_lt with (rfl | hx)
  · simp [le_reflₓ, zero_le_one]
    
  exact log_nonpos_iff hx

theorem log_nonpos (hx : 0 ≤ x) (h'x : x ≤ 1) : log x ≤ 0 :=
  (log_nonpos_iff' hx).2 h'x

theorem strict_mono_on_log : StrictMonoOn log (Set.Ioi 0) := fun x hx y hy hxy => log_lt_log hx hxy

theorem strict_anti_on_log : StrictAntiOn log (Set.Iio 0) := by
  rintro x (hx : x < 0) y (hy : y < 0) hxy
  rw [← log_abs y, ← log_abs x]
  refine' log_lt_log (abs_pos.2 hy.ne) _
  rwa [abs_of_neg hy, abs_of_neg hx, neg_lt_neg_iff]

theorem log_inj_on_pos : Set.InjOn log (Set.Ioi 0) :=
  strict_mono_on_log.InjOn

theorem eq_one_of_pos_of_log_eq_zero {x : ℝ} (h₁ : 0 < x) (h₂ : log x = 0) : x = 1 :=
  log_inj_on_pos (Set.mem_Ioi.2 h₁) (Set.mem_Ioi.2 zero_lt_one) (h₂.trans Real.log_one.symm)

theorem log_ne_zero_of_pos_of_ne_one {x : ℝ} (hx_pos : 0 < x) (hx : x ≠ 1) : log x ≠ 0 :=
  mt (eq_one_of_pos_of_log_eq_zero hx_pos) hx

@[simp]
theorem log_eq_zero {x : ℝ} : log x = 0 ↔ x = 0 ∨ x = 1 ∨ x = -1 := by
  constructor
  · intro h
    rcases lt_trichotomyₓ x 0 with (x_lt_zero | rfl | x_gt_zero)
    · refine' Or.inr (Or.inr (eq_neg_iff_eq_neg.mp _))
      rw [← log_neg_eq_log x] at h
      exact (eq_one_of_pos_of_log_eq_zero (neg_pos.mpr x_lt_zero) h).symm
      
    · exact Or.inl rfl
      
    · exact Or.inr (Or.inl (eq_one_of_pos_of_log_eq_zero x_gt_zero h))
      
    
  · rintro (rfl | rfl | rfl) <;> simp only [log_one, log_zero, log_neg_eq_log]
    

@[simp]
theorem log_pow (x : ℝ) (n : ℕ) : log (x ^ n) = n * log x := by
  induction' n with n ih
  · simp
    
  rcases eq_or_ne x 0 with (rfl | hx)
  · simp
    
  rw [pow_succ'ₓ, log_mul (pow_ne_zero _ hx) hx, ih, Nat.cast_succₓ, add_mulₓ, one_mulₓ]

@[simp]
theorem log_zpow (x : ℝ) (n : ℤ) : log (x ^ n) = n * log x := by
  induction n
  · rw [Int.of_nat_eq_coe, zpow_coe_nat, log_pow, Int.cast_coe_nat]
    
  rw [zpow_neg_succ_of_nat, log_inv, log_pow, Int.cast_neg_succ_of_nat, Nat.cast_add_one, neg_mul_eq_neg_mulₓ]

theorem log_le_sub_one_of_pos {x : ℝ} (hx : 0 < x) : log x ≤ x - 1 := by
  rw [le_sub_iff_add_le]
  convert add_one_le_exp (log x)
  rw [exp_log hx]

theorem log_div_self_antitone_on : AntitoneOn (fun x : ℝ => log x / x) { x | exp 1 ≤ x } := by
  simp only [AntitoneOn, mem_set_of_eq]
  intro x hex y hey hxy
  have x_pos : 0 < x := (exp_pos 1).trans_le hex
  have y_pos : 0 < y := (exp_pos 1).trans_le hey
  have hlogx : 1 ≤ log x := by
    rwa [le_log_iff_exp_le x_pos]
  have hyx : 0 ≤ y / x - 1 := by
    rwa [le_sub_iff_add_le, le_div_iff x_pos, zero_addₓ, one_mulₓ]
  rw [div_le_iff y_pos, ← sub_le_sub_iff_right (log x)]
  calc log y - log x = log (y / x) := by
      rw [log_div y_pos.ne' x_pos.ne']_ ≤ y / x - 1 :=
      log_le_sub_one_of_pos (div_pos y_pos x_pos)_ ≤ log x * (y / x - 1) :=
      le_mul_of_one_le_left hyx hlogx _ = log x / x * y - log x := by
      ring

/-- The real logarithm function tends to `+∞` at `+∞`. -/
theorem tendsto_log_at_top : Tendsto log atTop atTop :=
  tendsto_comp_exp_at_top.1 <| by
    simpa only [log_exp] using tendsto_id

theorem tendsto_log_nhds_within_zero : Tendsto log (𝓝[≠] 0) atBot := by
  rw [← show _ = log from funext log_abs]
  refine' tendsto.comp _ tendsto_abs_nhds_within_zero
  simpa [← tendsto_comp_exp_at_bot] using tendsto_id

theorem continuous_on_log : ContinuousOn log ({0}ᶜ) := by
  rw [continuous_on_iff_continuous_restrict, restrict]
  conv in log _ => rw [log_of_ne_zero (show (x : ℝ) ≠ 0 from x.2)]
  exact exp_order_iso.symm.continuous.comp (continuous_subtype_mk _ continuous_subtype_coe.norm)

@[continuity]
theorem continuous_log : Continuous fun x : { x : ℝ // x ≠ 0 } => log x :=
  continuous_on_iff_continuous_restrict.1 <| continuous_on_log.mono fun x hx => hx

@[continuity]
theorem continuous_log' : Continuous fun x : { x : ℝ // 0 < x } => log x :=
  continuous_on_iff_continuous_restrict.1 <| continuous_on_log.mono fun x hx => ne_of_gtₓ hx

theorem continuous_at_log (hx : x ≠ 0) : ContinuousAt log x :=
  (continuous_on_log x hx).ContinuousAt <| IsOpen.mem_nhds is_open_compl_singleton hx

@[simp]
theorem continuous_at_log_iff : ContinuousAt log x ↔ x ≠ 0 := by
  refine' ⟨_, continuous_at_log⟩
  rintro h rfl
  exact not_tendsto_nhds_of_tendsto_at_bot tendsto_log_nhds_within_zero _ (h.tendsto.mono_left inf_le_left)

open_locale BigOperators

theorem log_prod {α : Type _} (s : Finset α) (f : α → ℝ) (hf : ∀, ∀ x ∈ s, ∀, f x ≠ 0) :
    log (∏ i in s, f i) = ∑ i in s, log (f i) := by
  classical
  induction' s using Finset.induction_on with a s ha ih
  · simp
    
  simp only [Finset.mem_insert, forall_eq_or_imp] at hf
  simp [ha, ih hf.2, log_mul hf.1 (Finset.prod_ne_zero_iff.2 hf.2)]

end Real

section Continuity

open Real

variable {α : Type _}

theorem Filter.Tendsto.log {f : α → ℝ} {l : Filter α} {x : ℝ} (h : Tendsto f l (𝓝 x)) (hx : x ≠ 0) :
    Tendsto (fun x => log (f x)) l (𝓝 (log x)) :=
  (continuous_at_log hx).Tendsto.comp h

variable [TopologicalSpace α] {f : α → ℝ} {s : Set α} {a : α}

theorem Continuous.log (hf : Continuous f) (h₀ : ∀ x, f x ≠ 0) : Continuous fun x => log (f x) :=
  continuous_on_log.comp_continuous hf h₀

theorem ContinuousAt.log (hf : ContinuousAt f a) (h₀ : f a ≠ 0) : ContinuousAt (fun x => log (f x)) a :=
  hf.log h₀

theorem ContinuousWithinAt.log (hf : ContinuousWithinAt f s a) (h₀ : f a ≠ 0) :
    ContinuousWithinAt (fun x => log (f x)) s a :=
  hf.log h₀

theorem ContinuousOn.log (hf : ContinuousOn f s) (h₀ : ∀, ∀ x ∈ s, ∀, f x ≠ 0) : ContinuousOn (fun x => log (f x)) s :=
  fun x hx => (hf x hx).log (h₀ x hx)

end Continuity

