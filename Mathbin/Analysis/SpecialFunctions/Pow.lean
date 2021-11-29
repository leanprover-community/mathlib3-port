import Mathbin.Analysis.SpecialFunctions.Complex.Log

/-!
# Power function on `ℂ`, `ℝ`, `ℝ≥0`, and `ℝ≥0∞`

We construct the power functions `x ^ y` where
* `x` and `y` are complex numbers,
* or `x` and `y` are real numbers,
* or `x` is a nonnegative real number and `y` is a real number;
* or `x` is a number from `[0, +∞]` (a.k.a. `ℝ≥0∞`) and `y` is a real number.

We also prove basic properties of these functions.
-/


noncomputable theory

open_locale Classical Real TopologicalSpace Nnreal Ennreal Filter

open Filter

namespace Complex

/-- The complex power function `x^y`, given by `x^y = exp(y log x)` (where `log` is the principal
determination of the logarithm), unless `x = 0` where one sets `0^0 = 1` and `0^y = 0` for
`y ≠ 0`. -/
noncomputable def cpow (x y : ℂ) : ℂ :=
  if x = 0 then if y = 0 then 1 else 0 else exp (log x*y)

noncomputable instance  : Pow ℂ ℂ :=
  ⟨cpow⟩

@[simp]
theorem cpow_eq_pow (x y : ℂ) : cpow x y = (x^y) :=
  rfl

theorem cpow_def (x y : ℂ) : (x^y) = if x = 0 then if y = 0 then 1 else 0 else exp (log x*y) :=
  rfl

theorem cpow_def_of_ne_zero {x : ℂ} (hx : x ≠ 0) (y : ℂ) : (x^y) = exp (log x*y) :=
  if_neg hx

@[simp]
theorem cpow_zero (x : ℂ) : (x^(0 : ℂ)) = 1 :=
  by 
    simp [cpow_def]

@[simp]
theorem cpow_eq_zero_iff (x y : ℂ) : (x^y) = 0 ↔ x = 0 ∧ y ≠ 0 :=
  by 
    simp only [cpow_def]
    splitIfs <;> simp [exp_ne_zero]

@[simp]
theorem zero_cpow {x : ℂ} (h : x ≠ 0) : ((0 : ℂ)^x) = 0 :=
  by 
    simp [cpow_def]

theorem zero_cpow_eq_iff {x : ℂ} {a : ℂ} : (0^x) = a ↔ x ≠ 0 ∧ a = 0 ∨ x = 0 ∧ a = 1 :=
  by 
    split 
    ·
      intro hyp 
      simp [cpow_def] at hyp 
      byCases' x = 0
      ·
        subst h 
        simp only [if_true, eq_self_iff_true] at hyp 
        right 
        exact ⟨rfl, hyp.symm⟩
      ·
        rw [if_neg h] at hyp 
        left 
        exact ⟨h, hyp.symm⟩
    ·
      rintro (⟨h, rfl⟩ | ⟨rfl, rfl⟩)
      ·
        exact zero_cpow h
      ·
        exact cpow_zero _

theorem eq_zero_cpow_iff {x : ℂ} {a : ℂ} : a = (0^x) ↔ x ≠ 0 ∧ a = 0 ∨ x = 0 ∧ a = 1 :=
  by 
    rw [←zero_cpow_eq_iff, eq_comm]

@[simp]
theorem cpow_one (x : ℂ) : (x^(1 : ℂ)) = x :=
  if hx : x = 0 then
    by 
      simp [hx, cpow_def]
  else
    by 
      rw [cpow_def, if_neg (one_ne_zero : (1 : ℂ) ≠ 0), if_neg hx, mul_oneₓ, exp_log hx]

@[simp]
theorem one_cpow (x : ℂ) : ((1 : ℂ)^x) = 1 :=
  by 
    rw [cpow_def] <;> splitIfs <;> simp_all [one_ne_zero]

theorem cpow_add {x : ℂ} (y z : ℂ) (hx : x ≠ 0) : (x^y+z) = (x^y)*x^z :=
  by 
    simp [cpow_def] <;> splitIfs <;> simp_all [exp_add, mul_addₓ]

theorem cpow_mul {x y : ℂ} (z : ℂ) (h₁ : -π < (log x*y).im) (h₂ : (log x*y).im ≤ π) : (x^y*z) = ((x^y)^z) :=
  by 
    simp only [cpow_def]
    splitIfs <;> simp_all [exp_ne_zero, log_exp h₁ h₂, mul_assocₓ]

theorem cpow_neg (x y : ℂ) : (x^-y) = (x^y)⁻¹ :=
  by 
    simp [cpow_def] <;> splitIfs <;> simp [exp_neg]

theorem cpow_sub {x : ℂ} (y z : ℂ) (hx : x ≠ 0) : (x^y - z) = (x^y) / (x^z) :=
  by 
    rw [sub_eq_add_neg, cpow_add _ _ hx, cpow_neg, div_eq_mul_inv]

theorem cpow_neg_one (x : ℂ) : (x^(-1 : ℂ)) = x⁻¹ :=
  by 
    simpa using cpow_neg x 1

@[simp]
theorem cpow_nat_cast (x : ℂ) : ∀ (n : ℕ), (x^(n : ℂ)) = (x^n)
| 0 =>
  by 
    simp 
| n+1 =>
  if hx : x = 0 then
    by 
      simp only [hx, pow_succₓ, Complex.zero_cpow (Nat.cast_ne_zero.2 (Nat.succ_ne_zero _)), zero_mul]
  else
    by 
      simp [cpow_add, hx, pow_addₓ, cpow_nat_cast n]

@[simp]
theorem cpow_int_cast (x : ℂ) : ∀ (n : ℤ), (x^(n : ℂ)) = (x^n)
| (n : ℕ) =>
  by 
    simp  <;> rfl
| -[1+ n] =>
  by 
    rw [zpow_neg_succ_of_nat] <;>
      simp only [Int.neg_succ_of_nat_coe, Int.cast_neg, Complex.cpow_neg, inv_eq_one_div, Int.cast_coe_nat,
        cpow_nat_cast]

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem cpow_nat_inv_pow
(x : exprℂ())
{n : exprℕ()}
(hn : «expr < »(0, n)) : «expr = »(«expr ^ »(«expr ^ »(x, («expr ⁻¹»(n) : exprℂ())), n), x) :=
begin
  suffices [] [":", expr «expr ∈ »(im «expr * »(log x, «expr ⁻¹»(n)), set.Ioc «expr- »(exprπ()) exprπ())],
  { rw ["[", "<-", expr cpow_nat_cast, ",", "<-", expr cpow_mul _ this.1 this.2, ",", expr inv_mul_cancel, ",", expr cpow_one, "]"] [],
    exact_mod_cast [expr hn.ne'] },
  rw ["[", expr mul_comm, ",", "<-", expr of_real_nat_cast, ",", "<-", expr of_real_inv, ",", expr of_real_mul_im, ",", "<-", expr div_eq_inv_mul, "]"] [],
  have [ident hn'] [":", expr «expr < »(0, (n : exprℝ()))] [],
  by assumption_mod_cast,
  have [ident hn1] [":", expr «expr ≤ »(1, (n : exprℝ()))] [],
  by exact_mod_cast [expr nat.succ_le_iff.2 hn],
  split,
  { rw [expr lt_div_iff hn'] [],
    calc
      «expr ≤ »(«expr * »(«expr- »(exprπ()), n), «expr * »(«expr- »(exprπ()), 1)) : mul_le_mul_of_nonpos_left hn1 (neg_nonpos.2 real.pi_pos.le)
      «expr = »(..., «expr- »(exprπ())) : mul_one _
      «expr < »(..., im (log x)) : neg_pi_lt_log_im _ },
  { rw [expr div_le_iff hn'] [],
    calc
      «expr ≤ »(im (log x), exprπ()) : log_im_le_pi _
      «expr = »(..., «expr * »(exprπ(), 1)) : (mul_one exprπ()).symm
      «expr ≤ »(..., «expr * »(exprπ(), n)) : mul_le_mul_of_nonneg_left hn1 real.pi_pos.le }
end

end Complex

section limₓ

open Complex

variable{α : Type _}

theorem zero_cpow_eq_nhds {b : ℂ} (hb : b ≠ 0) : (0 : ℂ).cpow =ᶠ[𝓝 b] 0 :=
  by 
    suffices  : ∀ᶠx : ℂ in 𝓝 b, x ≠ 0 
    exact
      this.mono
        fun x hx =>
          by 
            rw [cpow_eq_pow, zero_cpow hx, Pi.zero_apply]
    exact IsOpen.eventually_mem is_open_ne hb

theorem cpow_eq_nhds {a b : ℂ} (ha : a ≠ 0) : (fun x => x.cpow b) =ᶠ[𝓝 a] fun x => exp (log x*b) :=
  by 
    suffices  : ∀ᶠx : ℂ in 𝓝 a, x ≠ 0 
    exact
      this.mono
        fun x hx =>
          by 
            dsimp only 
            rw [cpow_eq_pow, cpow_def_of_ne_zero hx]
    exact IsOpen.eventually_mem is_open_ne ha

theorem cpow_eq_nhds' {p : ℂ × ℂ} (hp_fst : p.fst ≠ 0) : (fun x => x.1^x.2) =ᶠ[𝓝 p] fun x => exp (log x.1*x.2) :=
  by 
    suffices  : ∀ᶠx : ℂ × ℂ in 𝓝 p, x.1 ≠ 0 
    exact
      this.mono
        fun x hx =>
          by 
            dsimp only 
            rw [cpow_def_of_ne_zero hx]
    refine' IsOpen.eventually_mem _ hp_fst 
    change IsOpen («expr ᶜ» { x:ℂ × ℂ | x.1 = 0 })
    rw [is_open_compl_iff]
    exact is_closed_eq continuous_fst continuous_const

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem continuous_at_const_cpow {a b : exprℂ()} (ha : «expr ≠ »(a, 0)) : continuous_at (cpow a) b :=
begin
  have [ident cpow_eq] [":", expr «expr = »(cpow a, λ b, exp «expr * »(log a, b))] [],
  by { ext1 [] [ident b],
    rw ["[", expr cpow_eq_pow, ",", expr cpow_def_of_ne_zero ha, "]"] [] },
  rw [expr cpow_eq] [],
  exact [expr continuous_exp.continuous_at.comp (continuous_at.mul continuous_at_const continuous_at_id)]
end

theorem continuous_at_const_cpow' {a b : ℂ} (h : b ≠ 0) : ContinuousAt (cpow a) b :=
  by 
    byCases' ha : a = 0
    ·
      rw [ha, continuous_at_congr (zero_cpow_eq_nhds h)]
      exact continuous_at_const
    ·
      exact continuous_at_const_cpow ha

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem continuous_at_cpow_const
{a b : exprℂ()}
(ha : «expr ∨ »(«expr < »(0, a.re), «expr ≠ »(a.im, 0))) : continuous_at (λ x, cpow x b) a :=
begin
  have [ident ha_ne_zero] [":", expr «expr ≠ »(a, 0)] [],
  by { intro [ident h],
    cases [expr ha] []; { rw [expr h] ["at", ident ha],
      simpa [] [] [] [] [] ["using", expr ha] } },
  rw [expr continuous_at_congr (cpow_eq_nhds ha_ne_zero)] [],
  refine [expr continuous_exp.continuous_at.comp _],
  exact [expr continuous_at.mul (continuous_at_clog ha) continuous_at_const]
end

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem continuous_at_cpow
{p : «expr × »(exprℂ(), exprℂ())}
(hp_fst : «expr ∨ »(«expr < »(0, p.fst.re), «expr ≠ »(p.fst.im, 0))) : continuous_at (λ
 x : «expr × »(exprℂ(), exprℂ()), «expr ^ »(x.1, x.2)) p :=
begin
  have [ident hp_fst_ne_zero] [":", expr «expr ≠ »(p.fst, 0)] [],
  by { intro [ident h],
    cases [expr hp_fst] []; { rw [expr h] ["at", ident hp_fst],
      simpa [] [] [] [] [] ["using", expr hp_fst] } },
  rw [expr continuous_at_congr (cpow_eq_nhds' hp_fst_ne_zero)] [],
  refine [expr continuous_exp.continuous_at.comp _],
  refine [expr continuous_at.mul (continuous_at.comp _ continuous_fst.continuous_at) continuous_snd.continuous_at],
  exact [expr continuous_at_clog hp_fst]
end

theorem Filter.Tendsto.cpow {l : Filter α} {f g : α → ℂ} {a b : ℂ} (hf : tendsto f l (𝓝 a)) (hg : tendsto g l (𝓝 b))
  (ha : 0 < a.re ∨ a.im ≠ 0) : tendsto (fun x => f x^g x) l (𝓝 (a^b)) :=
  (@continuous_at_cpow (a, b) ha).Tendsto.comp (hf.prod_mk_nhds hg)

theorem Filter.Tendsto.const_cpow {l : Filter α} {f : α → ℂ} {a b : ℂ} (hf : tendsto f l (𝓝 b)) (h : a ≠ 0 ∨ b ≠ 0) :
  tendsto (fun x => a^f x) l (𝓝 (a^b)) :=
  by 
    cases h
    ·
      exact (continuous_at_const_cpow h).Tendsto.comp hf
    ·
      exact (continuous_at_const_cpow' h).Tendsto.comp hf

variable[TopologicalSpace α]{f g : α → ℂ}{s : Set α}{a : α}

theorem ContinuousWithinAt.cpow (hf : ContinuousWithinAt f s a) (hg : ContinuousWithinAt g s a)
  (h0 : 0 < (f a).re ∨ (f a).im ≠ 0) : ContinuousWithinAt (fun x => f x^g x) s a :=
  hf.cpow hg h0

theorem ContinuousWithinAt.const_cpow {b : ℂ} (hf : ContinuousWithinAt f s a) (h : b ≠ 0 ∨ f a ≠ 0) :
  ContinuousWithinAt (fun x => b^f x) s a :=
  hf.const_cpow h

theorem ContinuousAt.cpow (hf : ContinuousAt f a) (hg : ContinuousAt g a) (h0 : 0 < (f a).re ∨ (f a).im ≠ 0) :
  ContinuousAt (fun x => f x^g x) a :=
  hf.cpow hg h0

theorem ContinuousAt.const_cpow {b : ℂ} (hf : ContinuousAt f a) (h : b ≠ 0 ∨ f a ≠ 0) :
  ContinuousAt (fun x => b^f x) a :=
  hf.const_cpow h

theorem ContinuousOn.cpow (hf : ContinuousOn f s) (hg : ContinuousOn g s)
  (h0 : ∀ a (_ : a ∈ s), 0 < (f a).re ∨ (f a).im ≠ 0) : ContinuousOn (fun x => f x^g x) s :=
  fun a ha => (hf a ha).cpow (hg a ha) (h0 a ha)

theorem ContinuousOn.const_cpow {b : ℂ} (hf : ContinuousOn f s) (h : b ≠ 0 ∨ ∀ a (_ : a ∈ s), f a ≠ 0) :
  ContinuousOn (fun x => b^f x) s :=
  fun a ha => (hf a ha).const_cpow (h.imp id$ fun h => h a ha)

theorem Continuous.cpow (hf : Continuous f) (hg : Continuous g) (h0 : ∀ a, 0 < (f a).re ∨ (f a).im ≠ 0) :
  Continuous fun x => f x^g x :=
  continuous_iff_continuous_at.2$ fun a => hf.continuous_at.cpow hg.continuous_at (h0 a)

theorem Continuous.const_cpow {b : ℂ} (hf : Continuous f) (h : b ≠ 0 ∨ ∀ a, f a ≠ 0) : Continuous fun x => b^f x :=
  continuous_iff_continuous_at.2$ fun a => hf.continuous_at.const_cpow$ h.imp id$ fun h => h a

end limₓ

namespace Real

/-- The real power function `x^y`, defined as the real part of the complex power function.
For `x > 0`, it is equal to `exp(y log x)`. For `x = 0`, one sets `0^0=1` and `0^y=0` for `y ≠ 0`.
For `x < 0`, the definition is somewhat arbitary as it depends on the choice of a complex
determination of the logarithm. With our conventions, it is equal to `exp (y log x) cos (πy)`. -/
noncomputable def rpow (x y : ℝ) :=
  ((x : ℂ)^(y : ℂ)).re

noncomputable instance  : Pow ℝ ℝ :=
  ⟨rpow⟩

@[simp]
theorem rpow_eq_pow (x y : ℝ) : rpow x y = (x^y) :=
  rfl

theorem rpow_def (x y : ℝ) : (x^y) = ((x : ℂ)^(y : ℂ)).re :=
  rfl

theorem rpow_def_of_nonneg {x : ℝ} (hx : 0 ≤ x) (y : ℝ) :
  (x^y) = if x = 0 then if y = 0 then 1 else 0 else exp (log x*y) :=
  by 
    simp only [rpow_def, Complex.cpow_def] <;>
      splitIfs <;>
        simp_all [(Complex.of_real_log hx).symm, -Complex.of_real_mul, -IsROrC.of_real_mul,
          (Complex.of_real_mul _ _).symm, Complex.exp_of_real_re]

theorem rpow_def_of_pos {x : ℝ} (hx : 0 < x) (y : ℝ) : (x^y) = exp (log x*y) :=
  by 
    rw [rpow_def_of_nonneg (le_of_ltₓ hx), if_neg (ne_of_gtₓ hx)]

theorem exp_mul (x y : ℝ) : exp (x*y) = (exp x^y) :=
  by 
    rw [rpow_def_of_pos (exp_pos _), log_exp]

theorem rpow_eq_zero_iff_of_nonneg {x y : ℝ} (hx : 0 ≤ x) : (x^y) = 0 ↔ x = 0 ∧ y ≠ 0 :=
  by 
    simp only [rpow_def_of_nonneg hx]
    splitIfs <;> simp [exp_ne_zero]

open_locale Real

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem rpow_def_of_neg
{x : exprℝ()}
(hx : «expr < »(x, 0))
(y : exprℝ()) : «expr = »(«expr ^ »(x, y), «expr * »(exp «expr * »(log x, y), cos «expr * »(y, exprπ()))) :=
begin
  rw ["[", expr rpow_def, ",", expr complex.cpow_def, ",", expr if_neg, "]"] [],
  have [] [":", expr «expr = »(«expr * »(complex.log x, y), «expr + »(«expr↑ »(«expr * »(log «expr- »(x), y)), «expr * »(«expr↑ »(«expr * »(y, exprπ())), complex.I)))] [],
  { simp [] [] ["only"] ["[", expr complex.log, ",", expr abs_of_neg hx, ",", expr complex.arg_of_real_of_neg hx, ",", expr complex.abs_of_real, ",", expr complex.of_real_mul, "]"] [] [],
    ring [] },
  { rw ["[", expr this, ",", expr complex.exp_add_mul_I, ",", "<-", expr complex.of_real_exp, ",", "<-", expr complex.of_real_cos, ",", "<-", expr complex.of_real_sin, ",", expr mul_add, ",", "<-", expr complex.of_real_mul, ",", "<-", expr mul_assoc, ",", "<-", expr complex.of_real_mul, ",", expr complex.add_re, ",", expr complex.of_real_re, ",", expr complex.mul_re, ",", expr complex.I_re, ",", expr complex.of_real_im, ",", expr real.log_neg_eq_log, "]"] [],
    ring [] },
  { rw [expr complex.of_real_eq_zero] [],
    exact [expr ne_of_lt hx] }
end

theorem rpow_def_of_nonpos {x : ℝ} (hx : x ≤ 0) (y : ℝ) :
  (x^y) = if x = 0 then if y = 0 then 1 else 0 else exp (log x*y)*cos (y*π) :=
  by 
    splitIfs <;> simp [rpow_def] <;> exact rpow_def_of_neg (lt_of_le_of_neₓ hx h) _

theorem rpow_pos_of_pos {x : ℝ} (hx : 0 < x) (y : ℝ) : 0 < (x^y) :=
  by 
    rw [rpow_def_of_pos hx] <;> apply exp_pos

@[simp]
theorem rpow_zero (x : ℝ) : (x^(0 : ℝ)) = 1 :=
  by 
    simp [rpow_def]

@[simp]
theorem zero_rpow {x : ℝ} (h : x ≠ 0) : ((0 : ℝ)^x) = 0 :=
  by 
    simp [rpow_def]

theorem zero_rpow_eq_iff {x : ℝ} {a : ℝ} : (0^x) = a ↔ x ≠ 0 ∧ a = 0 ∨ x = 0 ∧ a = 1 :=
  by 
    split 
    ·
      intro hyp 
      simp [rpow_def] at hyp 
      byCases' x = 0
      ·
        subst h 
        simp only [Complex.one_re, Complex.of_real_zero, Complex.cpow_zero] at hyp 
        exact Or.inr ⟨rfl, hyp.symm⟩
      ·
        rw [Complex.zero_cpow (complex.of_real_ne_zero.mpr h)] at hyp 
        exact Or.inl ⟨h, hyp.symm⟩
    ·
      rintro (⟨h, rfl⟩ | ⟨rfl, rfl⟩)
      ·
        exact zero_rpow h
      ·
        exact rpow_zero _

theorem eq_zero_rpow_iff {x : ℝ} {a : ℝ} : a = (0^x) ↔ x ≠ 0 ∧ a = 0 ∨ x = 0 ∧ a = 1 :=
  by 
    rw [←zero_rpow_eq_iff, eq_comm]

@[simp]
theorem rpow_one (x : ℝ) : (x^(1 : ℝ)) = x :=
  by 
    simp [rpow_def]

@[simp]
theorem one_rpow (x : ℝ) : ((1 : ℝ)^x) = 1 :=
  by 
    simp [rpow_def]

theorem zero_rpow_le_one (x : ℝ) : ((0 : ℝ)^x) ≤ 1 :=
  by 
    byCases' h : x = 0 <;> simp [h, zero_le_one]

theorem zero_rpow_nonneg (x : ℝ) : 0 ≤ ((0 : ℝ)^x) :=
  by 
    byCases' h : x = 0 <;> simp [h, zero_le_one]

theorem rpow_nonneg_of_nonneg {x : ℝ} (hx : 0 ≤ x) (y : ℝ) : 0 ≤ (x^y) :=
  by 
    rw [rpow_def_of_nonneg hx] <;> splitIfs <;> simp only [zero_le_one, le_reflₓ, le_of_ltₓ (exp_pos _)]

theorem abs_rpow_le_abs_rpow (x y : ℝ) : |x^y| ≤ (|x|^y) :=
  by 
    rcases lt_trichotomyₓ 0 x with (hx | rfl | hx)
    ·
      rw [abs_of_pos hx, abs_of_pos (rpow_pos_of_pos hx _)]
    ·
      rw [abs_zero, abs_of_nonneg (rpow_nonneg_of_nonneg le_rfl _)]
    ·
      rw [abs_of_neg hx, rpow_def_of_neg hx, rpow_def_of_pos (neg_pos.2 hx), log_neg_eq_log, abs_mul,
        abs_of_pos (exp_pos _)]
      exact mul_le_of_le_one_right (exp_pos _).le (abs_cos_le_one _)

theorem abs_rpow_le_exp_log_mul (x y : ℝ) : |x^y| ≤ exp (log x*y) :=
  by 
    refine' (abs_rpow_le_abs_rpow x y).trans _ 
    byCases' hx : x = 0
    ·
      byCases' hy : y = 0 <;> simp [hx, hy, zero_le_one]
    ·
      rw [rpow_def_of_pos (abs_pos.2 hx), log_abs]

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem abs_rpow_of_nonneg
{x y : exprℝ()}
(hx_nonneg : «expr ≤ »(0, x)) : «expr = »(«expr| |»(«expr ^ »(x, y)), «expr ^ »(«expr| |»(x), y)) :=
begin
  have [ident h_rpow_nonneg] [":", expr «expr ≤ »(0, «expr ^ »(x, y))] [],
  from [expr real.rpow_nonneg_of_nonneg hx_nonneg _],
  rw ["[", expr abs_eq_self.mpr hx_nonneg, ",", expr abs_eq_self.mpr h_rpow_nonneg, "]"] []
end

theorem norm_rpow_of_nonneg {x y : ℝ} (hx_nonneg : 0 ≤ x) : ∥x^y∥ = (∥x∥^y) :=
  by 
    simpRw [Real.norm_eq_abs]
    exact abs_rpow_of_nonneg hx_nonneg

end Real

namespace Complex

theorem of_real_cpow {x : ℝ} (hx : 0 ≤ x) (y : ℝ) : ((x^y : ℝ) : ℂ) = ((x : ℂ)^(y : ℂ)) :=
  by 
    simp [Real.rpow_def_of_nonneg hx, Complex.cpow_def] <;> splitIfs <;> simp [Complex.of_real_log hx]

@[simp]
theorem abs_cpow_real (x : ℂ) (y : ℝ) : abs (x^(y : ℂ)) = (x.abs^y) :=
  by 
    rw [Real.rpow_def_of_nonneg (abs_nonneg _), Complex.cpow_def]
    splitIfs <;>
      simp_all [abs_of_nonneg (le_of_ltₓ (Real.exp_pos _)), Complex.log, Complex.exp_add, add_mulₓ, mul_right_commₓ _ I,
        exp_mul_I, abs_cos_add_sin_mul_I, (Complex.of_real_mul _ _).symm, -Complex.of_real_mul, -IsROrC.of_real_mul]

@[simp]
theorem abs_cpow_inv_nat (x : ℂ) (n : ℕ) : abs (x^(n⁻¹ : ℂ)) = (x.abs^(n⁻¹ : ℝ)) :=
  by 
    rw [←abs_cpow_real] <;> simp [-abs_cpow_real]

end Complex

namespace Real

variable{x y z : ℝ}

theorem rpow_add {x : ℝ} (hx : 0 < x) (y z : ℝ) : (x^y+z) = (x^y)*x^z :=
  by 
    simp only [rpow_def_of_pos hx, mul_addₓ, exp_add]

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem rpow_add'
{x : exprℝ()}
(hx : «expr ≤ »(0, x))
{y z : exprℝ()}
(h : «expr ≠ »(«expr + »(y, z), 0)) : «expr = »(«expr ^ »(x, «expr + »(y, z)), «expr * »(«expr ^ »(x, y), «expr ^ »(x, z))) :=
begin
  rcases [expr hx.eq_or_lt, "with", ident rfl, "|", ident pos],
  { rw ["[", expr zero_rpow h, ",", expr zero_eq_mul, "]"] [],
    have [] [":", expr «expr ∨ »(«expr ≠ »(y, 0), «expr ≠ »(z, 0))] [],
    from [expr not_and_distrib.1 (λ ⟨hy, hz⟩, «expr $ »(h, «expr ▸ »(hy.symm, «expr ▸ »(hz.symm, zero_add 0))))],
    exact [expr this.imp zero_rpow zero_rpow] },
  { exact [expr rpow_add pos _ _] }
end

/-- For `0 ≤ x`, the only problematic case in the equality `x ^ y * x ^ z = x ^ (y + z)` is for
`x = 0` and `y + z = 0`, where the right hand side is `1` while the left hand side can vanish.
The inequality is always true, though, and given in this lemma. -/
theorem le_rpow_add {x : ℝ} (hx : 0 ≤ x) (y z : ℝ) : ((x^y)*x^z) ≤ (x^y+z) :=
  by 
    rcases le_iff_eq_or_lt.1 hx with (H | pos)
    ·
      byCases' h : (y+z) = 0
      ·
        simp only [H.symm, h, rpow_zero]
        calc (((0 : ℝ)^y)*0^z) ≤ 1*1 :=
          mul_le_mul (zero_rpow_le_one y) (zero_rpow_le_one z) (zero_rpow_nonneg z) zero_le_one _ = 1 :=
          by 
            simp 
      ·
        simp [rpow_add', ←H, h]
    ·
      simp [rpow_add Pos]

theorem rpow_mul {x : ℝ} (hx : 0 ≤ x) (y z : ℝ) : (x^y*z) = ((x^y)^z) :=
  by 
    rw [←Complex.of_real_inj, Complex.of_real_cpow (rpow_nonneg_of_nonneg hx _), Complex.of_real_cpow hx,
        Complex.of_real_mul, Complex.cpow_mul, Complex.of_real_cpow hx] <;>
      simp only [(Complex.of_real_mul _ _).symm, (Complex.of_real_log hx).symm, Complex.of_real_im, neg_lt_zero, pi_pos,
        le_of_ltₓ pi_pos]

theorem rpow_neg {x : ℝ} (hx : 0 ≤ x) (y : ℝ) : (x^-y) = (x^y)⁻¹ :=
  by 
    simp only [rpow_def_of_nonneg hx] <;> splitIfs <;> simp_all [exp_neg]

theorem rpow_sub {x : ℝ} (hx : 0 < x) (y z : ℝ) : (x^y - z) = (x^y) / (x^z) :=
  by 
    simp only [sub_eq_add_neg, rpow_add hx, rpow_neg (le_of_ltₓ hx), div_eq_mul_inv]

theorem rpow_sub' {x : ℝ} (hx : 0 ≤ x) {y z : ℝ} (h : y - z ≠ 0) : (x^y - z) = (x^y) / (x^z) :=
  by 
    simp only [sub_eq_add_neg] at h⊢
    simp only [rpow_add' hx h, rpow_neg hx, div_eq_mul_inv]

theorem rpow_add_int {x : ℝ} (hx : x ≠ 0) (y : ℝ) (n : ℤ) : (x^y+n) = (x^y)*x^n :=
  by 
    rw [rpow_def, Complex.of_real_add, Complex.cpow_add _ _ (complex.of_real_ne_zero.mpr hx), Complex.of_real_int_cast,
      Complex.cpow_int_cast, ←Complex.of_real_zpow, mul_commₓ, Complex.of_real_mul_re, ←rpow_def, mul_commₓ]

theorem rpow_add_nat {x : ℝ} (hx : x ≠ 0) (y : ℝ) (n : ℕ) : (x^y+n) = (x^y)*x^n :=
  rpow_add_int hx y n

theorem rpow_sub_int {x : ℝ} (hx : x ≠ 0) (y : ℝ) (n : ℤ) : (x^y - n) = (x^y) / (x^n) :=
  by 
    simpa using rpow_add_int hx y (-n)

theorem rpow_sub_nat {x : ℝ} (hx : x ≠ 0) (y : ℝ) (n : ℕ) : (x^y - n) = (x^y) / (x^n) :=
  rpow_sub_int hx y n

theorem rpow_add_one {x : ℝ} (hx : x ≠ 0) (y : ℝ) : (x^y+1) = (x^y)*x :=
  by 
    simpa using rpow_add_nat hx y 1

theorem rpow_sub_one {x : ℝ} (hx : x ≠ 0) (y : ℝ) : (x^y - 1) = (x^y) / x :=
  by 
    simpa using rpow_sub_nat hx y 1

@[simp]
theorem rpow_int_cast (x : ℝ) (n : ℤ) : (x^(n : ℝ)) = (x^n) :=
  by 
    simp only [rpow_def, ←Complex.of_real_zpow, Complex.cpow_int_cast, Complex.of_real_int_cast, Complex.of_real_re]

@[simp]
theorem rpow_nat_cast (x : ℝ) (n : ℕ) : (x^(n : ℝ)) = (x^n) :=
  rpow_int_cast x n

theorem rpow_neg_one (x : ℝ) : (x^(-1 : ℝ)) = x⁻¹ :=
  by 
    suffices H : (x^((-1 : ℤ) : ℝ)) = x⁻¹
    ·
      exactModCast H 
    simp only [rpow_int_cast, zpow_one, zpow_neg₀]

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem mul_rpow
{x y z : exprℝ()}
(h : «expr ≤ »(0, x))
(h₁ : «expr ≤ »(0, y)) : «expr = »(«expr ^ »(«expr * »(x, y), z), «expr * »(«expr ^ »(x, z), «expr ^ »(y, z))) :=
begin
  iterate [3] { rw [expr real.rpow_def_of_nonneg] [] },
  split_ifs [] []; simp [] [] [] ["*"] [] ["at", "*"],
  { have [ident hx] [":", expr «expr < »(0, x)] [],
    { cases [expr lt_or_eq_of_le h] ["with", ident h₂, ident h₂],
      { exact [expr h₂] },
      exfalso,
      apply [expr h_2],
      exact [expr eq.symm h₂] },
    have [ident hy] [":", expr «expr < »(0, y)] [],
    { cases [expr lt_or_eq_of_le h₁] ["with", ident h₂, ident h₂],
      { exact [expr h₂] },
      exfalso,
      apply [expr h_3],
      exact [expr eq.symm h₂] },
    rw ["[", expr log_mul (ne_of_gt hx) (ne_of_gt hy), ",", expr add_mul, ",", expr exp_add, "]"] [] },
  { exact [expr h₁] },
  { exact [expr h] },
  { exact [expr mul_nonneg h h₁] }
end

theorem inv_rpow (hx : 0 ≤ x) (y : ℝ) : (x⁻¹^y) = (x^y)⁻¹ :=
  by 
    simp only [←rpow_neg_one, ←rpow_mul hx, mul_commₓ]

theorem div_rpow (hx : 0 ≤ x) (hy : 0 ≤ y) (z : ℝ) : (x / y^z) = (x^z) / (y^z) :=
  by 
    simp only [div_eq_mul_inv, mul_rpow hx (inv_nonneg.2 hy), inv_rpow hy]

theorem log_rpow {x : ℝ} (hx : 0 < x) (y : ℝ) : log (x^y) = y*log x :=
  by 
    apply exp_injective 
    rw [exp_log (rpow_pos_of_pos hx y), ←exp_log hx, mul_commₓ, rpow_def_of_pos (exp_pos (log x)) y]

theorem rpow_lt_rpow (hx : 0 ≤ x) (hxy : x < y) (hz : 0 < z) : (x^z) < (y^z) :=
  by 
    rw [le_iff_eq_or_lt] at hx 
    cases hx
    ·
      rw [←hx, zero_rpow (ne_of_gtₓ hz)]
      exact
        rpow_pos_of_pos
          (by 
            rwa [←hx] at hxy)
          _ 
    rw [rpow_def_of_pos hx, rpow_def_of_pos (lt_transₓ hx hxy), exp_lt_exp]
    exact mul_lt_mul_of_pos_right (log_lt_log hx hxy) hz

theorem rpow_le_rpow {x y z : ℝ} (h : 0 ≤ x) (h₁ : x ≤ y) (h₂ : 0 ≤ z) : (x^z) ≤ (y^z) :=
  by 
    rcases eq_or_lt_of_le h₁ with (rfl | h₁')
    ·
      rfl 
    rcases eq_or_lt_of_le h₂ with (rfl | h₂')
    ·
      simp 
    exact le_of_ltₓ (rpow_lt_rpow h h₁' h₂')

theorem rpow_lt_rpow_iff (hx : 0 ≤ x) (hy : 0 ≤ y) (hz : 0 < z) : (x^z) < (y^z) ↔ x < y :=
  ⟨lt_imp_lt_of_le_imp_le$ fun h => rpow_le_rpow hy h (le_of_ltₓ hz), fun h => rpow_lt_rpow hx h hz⟩

theorem rpow_le_rpow_iff (hx : 0 ≤ x) (hy : 0 ≤ y) (hz : 0 < z) : (x^z) ≤ (y^z) ↔ x ≤ y :=
  le_iff_le_iff_lt_iff_lt.2$ rpow_lt_rpow_iff hy hx hz

theorem rpow_lt_rpow_of_exponent_lt (hx : 1 < x) (hyz : y < z) : (x^y) < (x^z) :=
  by 
    repeat' 
      rw [rpow_def_of_pos (lt_transₓ zero_lt_one hx)]
    rw [exp_lt_exp]
    exact mul_lt_mul_of_pos_left hyz (log_pos hx)

theorem rpow_le_rpow_of_exponent_le (hx : 1 ≤ x) (hyz : y ≤ z) : (x^y) ≤ (x^z) :=
  by 
    repeat' 
      rw [rpow_def_of_pos (lt_of_lt_of_leₓ zero_lt_one hx)]
    rw [exp_le_exp]
    exact mul_le_mul_of_nonneg_left hyz (log_nonneg hx)

theorem rpow_lt_rpow_of_exponent_gt (hx0 : 0 < x) (hx1 : x < 1) (hyz : z < y) : (x^y) < (x^z) :=
  by 
    repeat' 
      rw [rpow_def_of_pos hx0]
    rw [exp_lt_exp]
    exact mul_lt_mul_of_neg_left hyz (log_neg hx0 hx1)

theorem rpow_le_rpow_of_exponent_ge (hx0 : 0 < x) (hx1 : x ≤ 1) (hyz : z ≤ y) : (x^y) ≤ (x^z) :=
  by 
    repeat' 
      rw [rpow_def_of_pos hx0]
    rw [exp_le_exp]
    exact mul_le_mul_of_nonpos_left hyz (log_nonpos (le_of_ltₓ hx0) hx1)

theorem rpow_lt_one {x z : ℝ} (hx1 : 0 ≤ x) (hx2 : x < 1) (hz : 0 < z) : (x^z) < 1 :=
  by 
    rw [←one_rpow z]
    exact rpow_lt_rpow hx1 hx2 hz

theorem rpow_le_one {x z : ℝ} (hx1 : 0 ≤ x) (hx2 : x ≤ 1) (hz : 0 ≤ z) : (x^z) ≤ 1 :=
  by 
    rw [←one_rpow z]
    exact rpow_le_rpow hx1 hx2 hz

theorem rpow_lt_one_of_one_lt_of_neg {x z : ℝ} (hx : 1 < x) (hz : z < 0) : (x^z) < 1 :=
  by 
    convert rpow_lt_rpow_of_exponent_lt hx hz 
    exact (rpow_zero x).symm

theorem rpow_le_one_of_one_le_of_nonpos {x z : ℝ} (hx : 1 ≤ x) (hz : z ≤ 0) : (x^z) ≤ 1 :=
  by 
    convert rpow_le_rpow_of_exponent_le hx hz 
    exact (rpow_zero x).symm

theorem one_lt_rpow {x z : ℝ} (hx : 1 < x) (hz : 0 < z) : 1 < (x^z) :=
  by 
    rw [←one_rpow z]
    exact rpow_lt_rpow zero_le_one hx hz

theorem one_le_rpow {x z : ℝ} (hx : 1 ≤ x) (hz : 0 ≤ z) : 1 ≤ (x^z) :=
  by 
    rw [←one_rpow z]
    exact rpow_le_rpow zero_le_one hx hz

theorem one_lt_rpow_of_pos_of_lt_one_of_neg (hx1 : 0 < x) (hx2 : x < 1) (hz : z < 0) : 1 < (x^z) :=
  by 
    convert rpow_lt_rpow_of_exponent_gt hx1 hx2 hz 
    exact (rpow_zero x).symm

theorem one_le_rpow_of_pos_of_le_one_of_nonpos (hx1 : 0 < x) (hx2 : x ≤ 1) (hz : z ≤ 0) : 1 ≤ (x^z) :=
  by 
    convert rpow_le_rpow_of_exponent_ge hx1 hx2 hz 
    exact (rpow_zero x).symm

theorem rpow_lt_one_iff_of_pos (hx : 0 < x) : (x^y) < 1 ↔ 1 < x ∧ y < 0 ∨ x < 1 ∧ 0 < y :=
  by 
    rw [rpow_def_of_pos hx, exp_lt_one_iff, mul_neg_iff, log_pos_iff hx, log_neg_iff hx]

theorem rpow_lt_one_iff (hx : 0 ≤ x) : (x^y) < 1 ↔ x = 0 ∧ y ≠ 0 ∨ 1 < x ∧ y < 0 ∨ x < 1 ∧ 0 < y :=
  by 
    rcases hx.eq_or_lt with (rfl | hx)
    ·
      rcases em (y = 0) with (rfl | hy) <;> simp [lt_irreflₓ, zero_lt_one]
    ·
      simp [rpow_lt_one_iff_of_pos hx, hx.ne.symm]

theorem one_lt_rpow_iff_of_pos (hx : 0 < x) : 1 < (x^y) ↔ 1 < x ∧ 0 < y ∨ x < 1 ∧ y < 0 :=
  by 
    rw [rpow_def_of_pos hx, one_lt_exp_iff, mul_pos_iff, log_pos_iff hx, log_neg_iff hx]

theorem one_lt_rpow_iff (hx : 0 ≤ x) : 1 < (x^y) ↔ 1 < x ∧ 0 < y ∨ 0 < x ∧ x < 1 ∧ y < 0 :=
  by 
    rcases hx.eq_or_lt with (rfl | hx)
    ·
      rcases em (y = 0) with (rfl | hy) <;> simp [lt_irreflₓ, (@zero_lt_one ℝ _ _).not_lt]
    ·
      simp [one_lt_rpow_iff_of_pos hx, hx]

theorem le_rpow_iff_log_le (hx : 0 < x) (hy : 0 < y) : x ≤ (y^z) ↔ Real.log x ≤ z*Real.log y :=
  by 
    rw [←Real.log_le_log hx (Real.rpow_pos_of_pos hy z), Real.log_rpow hy]

theorem le_rpow_of_log_le (hx : 0 ≤ x) (hy : 0 < y) (h : Real.log x ≤ z*Real.log y) : x ≤ (y^z) :=
  by 
    obtain hx | rfl := hx.lt_or_eq
    ·
      exact (le_rpow_iff_log_le hx hy).2 h 
    exact (Real.rpow_pos_of_pos hy z).le

theorem lt_rpow_iff_log_lt (hx : 0 < x) (hy : 0 < y) : x < (y^z) ↔ Real.log x < z*Real.log y :=
  by 
    rw [←Real.log_lt_log_iff hx (Real.rpow_pos_of_pos hy z), Real.log_rpow hy]

theorem lt_rpow_of_log_lt (hx : 0 ≤ x) (hy : 0 < y) (h : Real.log x < z*Real.log y) : x < (y^z) :=
  by 
    obtain hx | rfl := hx.lt_or_eq
    ·
      exact (lt_rpow_iff_log_lt hx hy).2 h 
    exact Real.rpow_pos_of_pos hy z

theorem rpow_le_one_iff_of_pos (hx : 0 < x) : (x^y) ≤ 1 ↔ 1 ≤ x ∧ y ≤ 0 ∨ x ≤ 1 ∧ 0 ≤ y :=
  by 
    rw [rpow_def_of_pos hx, exp_le_one_iff, mul_nonpos_iff, log_nonneg_iff hx, log_nonpos_iff hx]

theorem pow_nat_rpow_nat_inv {x : ℝ} (hx : 0 ≤ x) {n : ℕ} (hn : 0 < n) : ((x^n)^(n⁻¹ : ℝ)) = x :=
  have hn0 : (n : ℝ) ≠ 0 :=
    by 
      simpa [pos_iff_ne_zero] using hn 
  by 
    rw [←rpow_nat_cast, ←rpow_mul hx, mul_inv_cancel hn0, rpow_one]

theorem rpow_nat_inv_pow_nat {x : ℝ} (hx : 0 ≤ x) {n : ℕ} (hn : 0 < n) : ((x^(n⁻¹ : ℝ))^n) = x :=
  have hn0 : (n : ℝ) ≠ 0 :=
    by 
      simpa [pos_iff_ne_zero] using hn 
  by 
    rw [←rpow_nat_cast, ←rpow_mul hx, inv_mul_cancel hn0, rpow_one]

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem continuous_at_const_rpow {a b : exprℝ()} (h : «expr ≠ »(a, 0)) : continuous_at (rpow a) b :=
begin
  have [] [":", expr «expr = »(rpow a, λ x : exprℝ(), «expr ^ »((a : exprℂ()), (x : exprℂ())).re)] [],
  by { ext1 [] [ident x],
    rw ["[", expr rpow_eq_pow, ",", expr rpow_def, "]"] [] },
  rw [expr this] [],
  refine [expr complex.continuous_re.continuous_at.comp _],
  refine [expr (continuous_at_const_cpow _).comp complex.continuous_of_real.continuous_at],
  norm_cast [],
  exact [expr h]
end

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem continuous_at_const_rpow' {a b : exprℝ()} (h : «expr ≠ »(b, 0)) : continuous_at (rpow a) b :=
begin
  have [] [":", expr «expr = »(rpow a, λ x : exprℝ(), «expr ^ »((a : exprℂ()), (x : exprℂ())).re)] [],
  by { ext1 [] [ident x],
    rw ["[", expr rpow_eq_pow, ",", expr rpow_def, "]"] [] },
  rw [expr this] [],
  refine [expr complex.continuous_re.continuous_at.comp _],
  refine [expr (continuous_at_const_cpow' _).comp complex.continuous_of_real.continuous_at],
  norm_cast [],
  exact [expr h]
end

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem rpow_eq_nhds_of_neg
{p : «expr × »(exprℝ(), exprℝ())}
(hp_fst : «expr < »(p.fst, 0)) : «expr =ᶠ[ ] »(λ
 x : «expr × »(exprℝ(), exprℝ()), «expr ^ »(x.1, x.2), expr𝓝() p, λ
 x, «expr * »(exp «expr * »(log x.1, x.2), cos «expr * »(x.2, exprπ()))) :=
begin
  suffices [] [":", expr «expr∀ᶠ in , »((x : «expr × »(exprℝ(), exprℝ())), expr𝓝() p, «expr < »(x.1, 0))],
  from [expr this.mono (λ x hx, by { dsimp ["only"] [] [] [], rw [expr rpow_def_of_neg hx] [] })],
  exact [expr is_open.eventually_mem (is_open_lt continuous_fst continuous_const) hp_fst]
end

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem rpow_eq_nhds_of_pos
{p : «expr × »(exprℝ(), exprℝ())}
(hp_fst : «expr < »(0, p.fst)) : «expr =ᶠ[ ] »(λ
 x : «expr × »(exprℝ(), exprℝ()), «expr ^ »(x.1, x.2), expr𝓝() p, λ x, exp «expr * »(log x.1, x.2)) :=
begin
  suffices [] [":", expr «expr∀ᶠ in , »((x : «expr × »(exprℝ(), exprℝ())), expr𝓝() p, «expr < »(0, x.1))],
  from [expr this.mono (λ x hx, by { dsimp ["only"] [] [] [], rw [expr rpow_def_of_pos hx] [] })],
  exact [expr is_open.eventually_mem (is_open_lt continuous_const continuous_fst) hp_fst]
end

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem continuous_at_rpow_of_ne
(p : «expr × »(exprℝ(), exprℝ()))
(hp : «expr ≠ »(p.1, 0)) : continuous_at (λ p : «expr × »(exprℝ(), exprℝ()), «expr ^ »(p.1, p.2)) p :=
begin
  rw [expr ne_iff_lt_or_gt] ["at", ident hp],
  cases [expr hp] [],
  { rw [expr continuous_at_congr (rpow_eq_nhds_of_neg hp)] [],
    refine [expr continuous_at.mul _ (continuous_cos.continuous_at.comp _)],
    { refine [expr continuous_exp.continuous_at.comp (continuous_at.mul _ continuous_snd.continuous_at)],
      refine [expr (continuous_at_log _).comp continuous_fst.continuous_at],
      exact [expr hp.ne] },
    { exact [expr continuous_snd.continuous_at.mul continuous_at_const] } },
  { rw [expr continuous_at_congr (rpow_eq_nhds_of_pos hp)] [],
    refine [expr continuous_exp.continuous_at.comp (continuous_at.mul _ continuous_snd.continuous_at)],
    refine [expr (continuous_at_log _).comp continuous_fst.continuous_at],
    exact [expr hp.lt.ne.symm] }
end

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem continuous_at_rpow_of_pos
(p : «expr × »(exprℝ(), exprℝ()))
(hp : «expr < »(0, p.2)) : continuous_at (λ p : «expr × »(exprℝ(), exprℝ()), «expr ^ »(p.1, p.2)) p :=
begin
  cases [expr p] ["with", ident x, ident y],
  obtain [ident hx, "|", ident rfl, ":=", expr ne_or_eq x 0],
  { exact [expr continuous_at_rpow_of_ne (x, y) hx] },
  have [ident A] [":", expr tendsto (λ
    p : «expr × »(exprℝ(), exprℝ()), exp «expr * »(log p.1, p.2)) «expr ×ᶠ »(«expr𝓝[ ] »(«expr ᶜ»({0}), 0), expr𝓝() y) (expr𝓝() 0)] [":=", expr tendsto_exp_at_bot.comp ((tendsto_log_nhds_within_zero.comp tendsto_fst).at_bot_mul hp tendsto_snd)],
  have [ident B] [":", expr tendsto (λ
    p : «expr × »(exprℝ(), exprℝ()), «expr ^ »(p.1, p.2)) «expr ×ᶠ »(«expr𝓝[ ] »(«expr ᶜ»({0}), 0), expr𝓝() y) (expr𝓝() 0)] [":=", expr squeeze_zero_norm (λ
    p, abs_rpow_le_exp_log_mul p.1 p.2) A],
  have [ident C] [":", expr tendsto (λ
    p : «expr × »(exprℝ(), exprℝ()), «expr ^ »(p.1, p.2)) «expr ×ᶠ »(«expr𝓝[ ] »({0}, 0), expr𝓝() y) (pure 0)] [],
  { rw ["[", expr nhds_within_singleton, ",", expr tendsto_pure, ",", expr pure_prod, ",", expr eventually_map, "]"] [],
    exact [expr (lt_mem_nhds hp).mono (λ y hy, zero_rpow hy.ne')] },
  simpa [] [] ["only"] ["[", "<-", expr sup_prod, ",", "<-", expr nhds_within_union, ",", expr set.compl_union_self, ",", expr nhds_within_univ, ",", expr nhds_prod_eq, ",", expr continuous_at, ",", expr zero_rpow hp.ne', "]"] [] ["using", expr B.sup (C.mono_right (pure_le_nhds _))]
end

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem continuous_at_rpow
(p : «expr × »(exprℝ(), exprℝ()))
(h : «expr ∨ »(«expr ≠ »(p.1, 0), «expr < »(0, p.2))) : continuous_at (λ
 p : «expr × »(exprℝ(), exprℝ()), «expr ^ »(p.1, p.2)) p :=
h.elim (λ h, continuous_at_rpow_of_ne p h) (λ h, continuous_at_rpow_of_pos p h)

end Real

section 

variable{α : Type _}

theorem Filter.Tendsto.rpow {l : Filter α} {f g : α → ℝ} {x y : ℝ} (hf : tendsto f l (𝓝 x)) (hg : tendsto g l (𝓝 y))
  (h : x ≠ 0 ∨ 0 < y) : tendsto (fun t => f t^g t) l (𝓝 (x^y)) :=
  (Real.continuous_at_rpow (x, y) h).Tendsto.comp (hf.prod_mk_nhds hg)

theorem Filter.Tendsto.rpow_const {l : Filter α} {f : α → ℝ} {x p : ℝ} (hf : tendsto f l (𝓝 x)) (h : x ≠ 0 ∨ 0 ≤ p) :
  tendsto (fun a => f a^p) l (𝓝 (x^p)) :=
  if h0 : 0 = p then
    h0 ▸
      by 
        simp [tendsto_const_nhds]
  else hf.rpow tendsto_const_nhds (h.imp id$ fun h' => h'.lt_of_ne h0)

variable[TopologicalSpace α]{f g : α → ℝ}{s : Set α}{x : α}{p : ℝ}

theorem ContinuousAt.rpow (hf : ContinuousAt f x) (hg : ContinuousAt g x) (h : f x ≠ 0 ∨ 0 < g x) :
  ContinuousAt (fun t => f t^g t) x :=
  hf.rpow hg h

theorem ContinuousWithinAt.rpow (hf : ContinuousWithinAt f s x) (hg : ContinuousWithinAt g s x)
  (h : f x ≠ 0 ∨ 0 < g x) : ContinuousWithinAt (fun t => f t^g t) s x :=
  hf.rpow hg h

theorem ContinuousOn.rpow (hf : ContinuousOn f s) (hg : ContinuousOn g s) (h : ∀ x (_ : x ∈ s), f x ≠ 0 ∨ 0 < g x) :
  ContinuousOn (fun t => f t^g t) s :=
  fun t ht => (hf t ht).rpow (hg t ht) (h t ht)

theorem Continuous.rpow (hf : Continuous f) (hg : Continuous g) (h : ∀ x, f x ≠ 0 ∨ 0 < g x) :
  Continuous fun x => f x^g x :=
  continuous_iff_continuous_at.2$ fun x => hf.continuous_at.rpow hg.continuous_at (h x)

theorem ContinuousWithinAt.rpow_const (hf : ContinuousWithinAt f s x) (h : f x ≠ 0 ∨ 0 ≤ p) :
  ContinuousWithinAt (fun x => f x^p) s x :=
  hf.rpow_const h

theorem ContinuousAt.rpow_const (hf : ContinuousAt f x) (h : f x ≠ 0 ∨ 0 ≤ p) : ContinuousAt (fun x => f x^p) x :=
  hf.rpow_const h

theorem ContinuousOn.rpow_const (hf : ContinuousOn f s) (h : ∀ x (_ : x ∈ s), f x ≠ 0 ∨ 0 ≤ p) :
  ContinuousOn (fun x => f x^p) s :=
  fun x hx => (hf x hx).rpow_const (h x hx)

theorem Continuous.rpow_const (hf : Continuous f) (h : ∀ x, f x ≠ 0 ∨ 0 ≤ p) : Continuous fun x => f x^p :=
  continuous_iff_continuous_at.2$ fun x => hf.continuous_at.rpow_const (h x)

end 

namespace Real

variable{z x y : ℝ}

section Sqrt

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem sqrt_eq_rpow (x : exprℝ()) : «expr = »(sqrt x, «expr ^ »(x, «expr / »(1, (2 : exprℝ())))) :=
begin
  obtain [ident h, "|", ident h, ":=", expr le_or_lt 0 x],
  { rw ["[", "<-", expr mul_self_inj_of_nonneg (sqrt_nonneg _) (rpow_nonneg_of_nonneg h _), ",", expr mul_self_sqrt h, ",", "<-", expr sq, ",", "<-", expr rpow_nat_cast, ",", "<-", expr rpow_mul h, "]"] [],
    norm_num [] [] },
  { have [] [":", expr «expr = »(«expr * »(«expr / »(1, (2 : exprℝ())), exprπ()), «expr / »(exprπ(), (2 : exprℝ())))] [],
    ring [],
    rw ["[", expr sqrt_eq_zero_of_nonpos h.le, ",", expr rpow_def_of_neg h, ",", expr this, ",", expr cos_pi_div_two, ",", expr mul_zero, "]"] [] }
end

end Sqrt

end Real

section Limits

open Real Filter

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- The function `x ^ y` tends to `+∞` at `+∞` for any positive real `y`. -/
theorem tendsto_rpow_at_top
{y : exprℝ()}
(hy : «expr < »(0, y)) : tendsto (λ x : exprℝ(), «expr ^ »(x, y)) at_top at_top :=
begin
  rw [expr tendsto_at_top_at_top] [],
  intro [ident b],
  use [expr «expr ^ »(max b 0, «expr / »(1, y))],
  intros [ident x, ident hx],
  exact [expr le_of_max_le_left (by { convert [] [expr rpow_le_rpow (rpow_nonneg_of_nonneg (le_max_right b 0) «expr / »(1, y)) hx (le_of_lt hy)] [],
      rw ["[", "<-", expr rpow_mul (le_max_right b 0), ",", expr (eq_div_iff (ne_of_gt hy)).mp rfl, ",", expr rpow_one, "]"] [] })]
end

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- The function `x ^ (-y)` tends to `0` at `+∞` for any positive real `y`. -/
theorem tendsto_rpow_neg_at_top
{y : exprℝ()}
(hy : «expr < »(0, y)) : tendsto (λ x : exprℝ(), «expr ^ »(x, «expr- »(y))) at_top (expr𝓝() 0) :=
tendsto.congr' (eventually_eq_of_mem (Ioi_mem_at_top 0) (λ
  x hx, (rpow_neg (le_of_lt hx) y).symm)) (tendsto_rpow_at_top hy).inv_tendsto_at_top

/-- The function `x ^ (a / (b * x + c))` tends to `1` at `+∞`, for any real numbers `a`, `b`, and
`c` such that `b` is nonzero. -/
theorem tendsto_rpow_div_mul_add (a b c : ℝ) (hb : 0 ≠ b) : tendsto (fun x => x^a / (b*x)+c) at_top (𝓝 1) :=
  by 
    refine'
      tendsto.congr' _
        ((tendsto_exp_nhds_0_nhds_1.comp
              (by 
                simpa only [mul_zero, pow_oneₓ] using
                  (@tendsto_const_nhds _ _ _ a _).mul
                    (tendsto_div_pow_mul_exp_add_at_top b c 1 hb
                      (by 
                        normNum)))).comp
          tendsto_log_at_top)
    apply eventually_eq_of_mem (Ioi_mem_at_top (0 : ℝ))
    intro x hx 
    simp only [Set.mem_Ioi, Function.comp_app] at hx⊢
    rw [exp_log hx, ←exp_log (rpow_pos_of_pos hx (a / (b*x)+c)), log_rpow hx (a / (b*x)+c)]
    fieldSimp

/-- The function `x ^ (1 / x)` tends to `1` at `+∞`. -/
theorem tendsto_rpow_div : tendsto (fun x => x^(1 : ℝ) / x) at_top (𝓝 1) :=
  by 
    convert tendsto_rpow_div_mul_add (1 : ℝ) _ (0 : ℝ) zero_ne_one 
    ringNF

/-- The function `x ^ (-1 / x)` tends to `1` at `+∞`. -/
theorem tendsto_rpow_neg_div : tendsto (fun x => x^-(1 : ℝ) / x) at_top (𝓝 1) :=
  by 
    convert tendsto_rpow_div_mul_add (-(1 : ℝ)) _ (0 : ℝ) zero_ne_one 
    ringNF

end Limits

namespace Nnreal

/-- The nonnegative real power function `x^y`, defined for `x : ℝ≥0` and `y : ℝ ` as the
restriction of the real power function. For `x > 0`, it is equal to `exp (y log x)`. For `x = 0`,
one sets `0 ^ 0 = 1` and `0 ^ y = 0` for `y ≠ 0`. -/
noncomputable def rpow (x :  ℝ≥0 ) (y : ℝ) :  ℝ≥0  :=
  ⟨(x : ℝ)^y, Real.rpow_nonneg_of_nonneg x.2 y⟩

noncomputable instance  : Pow ℝ≥0  ℝ :=
  ⟨rpow⟩

@[simp]
theorem rpow_eq_pow (x :  ℝ≥0 ) (y : ℝ) : rpow x y = (x^y) :=
  rfl

@[simp, normCast]
theorem coe_rpow (x :  ℝ≥0 ) (y : ℝ) : ((x^y :  ℝ≥0 ) : ℝ) = ((x : ℝ)^y) :=
  rfl

@[simp]
theorem rpow_zero (x :  ℝ≥0 ) : (x^(0 : ℝ)) = 1 :=
  Nnreal.eq$ Real.rpow_zero _

@[simp]
theorem rpow_eq_zero_iff {x :  ℝ≥0 } {y : ℝ} : (x^y) = 0 ↔ x = 0 ∧ y ≠ 0 :=
  by 
    rw [←Nnreal.coe_eq, coe_rpow, ←Nnreal.coe_eq_zero]
    exact Real.rpow_eq_zero_iff_of_nonneg x.2

@[simp]
theorem zero_rpow {x : ℝ} (h : x ≠ 0) : ((0 :  ℝ≥0 )^x) = 0 :=
  Nnreal.eq$ Real.zero_rpow h

@[simp]
theorem rpow_one (x :  ℝ≥0 ) : (x^(1 : ℝ)) = x :=
  Nnreal.eq$ Real.rpow_one _

@[simp]
theorem one_rpow (x : ℝ) : ((1 :  ℝ≥0 )^x) = 1 :=
  Nnreal.eq$ Real.one_rpow _

theorem rpow_add {x :  ℝ≥0 } (hx : x ≠ 0) (y z : ℝ) : (x^y+z) = (x^y)*x^z :=
  Nnreal.eq$ Real.rpow_add (pos_iff_ne_zero.2 hx) _ _

theorem rpow_add' (x :  ℝ≥0 ) {y z : ℝ} (h : (y+z) ≠ 0) : (x^y+z) = (x^y)*x^z :=
  Nnreal.eq$ Real.rpow_add' x.2 h

theorem rpow_mul (x :  ℝ≥0 ) (y z : ℝ) : (x^y*z) = ((x^y)^z) :=
  Nnreal.eq$ Real.rpow_mul x.2 y z

theorem rpow_neg (x :  ℝ≥0 ) (y : ℝ) : (x^-y) = (x^y)⁻¹ :=
  Nnreal.eq$ Real.rpow_neg x.2 _

theorem rpow_neg_one (x :  ℝ≥0 ) : (x^(-1 : ℝ)) = x⁻¹ :=
  by 
    simp [rpow_neg]

theorem rpow_sub {x :  ℝ≥0 } (hx : x ≠ 0) (y z : ℝ) : (x^y - z) = (x^y) / (x^z) :=
  Nnreal.eq$ Real.rpow_sub (pos_iff_ne_zero.2 hx) y z

theorem rpow_sub' (x :  ℝ≥0 ) {y z : ℝ} (h : y - z ≠ 0) : (x^y - z) = (x^y) / (x^z) :=
  Nnreal.eq$ Real.rpow_sub' x.2 h

theorem inv_rpow (x :  ℝ≥0 ) (y : ℝ) : (x⁻¹^y) = (x^y)⁻¹ :=
  Nnreal.eq$ Real.inv_rpow x.2 y

theorem div_rpow (x y :  ℝ≥0 ) (z : ℝ) : (x / y^z) = (x^z) / (y^z) :=
  Nnreal.eq$ Real.div_rpow x.2 y.2 z

theorem sqrt_eq_rpow (x :  ℝ≥0 ) : sqrt x = (x^1 / (2 : ℝ)) :=
  by 
    refine' Nnreal.eq _ 
    pushCast 
    exact Real.sqrt_eq_rpow x.1

@[simp, normCast]
theorem rpow_nat_cast (x :  ℝ≥0 ) (n : ℕ) : (x^(n : ℝ)) = (x^n) :=
  Nnreal.eq$
    by 
      simpa only [coe_rpow, coe_pow] using Real.rpow_nat_cast x n

theorem mul_rpow {x y :  ℝ≥0 } {z : ℝ} : ((x*y)^z) = (x^z)*y^z :=
  Nnreal.eq$ Real.mul_rpow x.2 y.2

theorem rpow_le_rpow {x y :  ℝ≥0 } {z : ℝ} (h₁ : x ≤ y) (h₂ : 0 ≤ z) : (x^z) ≤ (y^z) :=
  Real.rpow_le_rpow x.2 h₁ h₂

theorem rpow_lt_rpow {x y :  ℝ≥0 } {z : ℝ} (h₁ : x < y) (h₂ : 0 < z) : (x^z) < (y^z) :=
  Real.rpow_lt_rpow x.2 h₁ h₂

theorem rpow_lt_rpow_iff {x y :  ℝ≥0 } {z : ℝ} (hz : 0 < z) : (x^z) < (y^z) ↔ x < y :=
  Real.rpow_lt_rpow_iff x.2 y.2 hz

theorem rpow_le_rpow_iff {x y :  ℝ≥0 } {z : ℝ} (hz : 0 < z) : (x^z) ≤ (y^z) ↔ x ≤ y :=
  Real.rpow_le_rpow_iff x.2 y.2 hz

theorem rpow_lt_rpow_of_exponent_lt {x :  ℝ≥0 } {y z : ℝ} (hx : 1 < x) (hyz : y < z) : (x^y) < (x^z) :=
  Real.rpow_lt_rpow_of_exponent_lt hx hyz

theorem rpow_le_rpow_of_exponent_le {x :  ℝ≥0 } {y z : ℝ} (hx : 1 ≤ x) (hyz : y ≤ z) : (x^y) ≤ (x^z) :=
  Real.rpow_le_rpow_of_exponent_le hx hyz

theorem rpow_lt_rpow_of_exponent_gt {x :  ℝ≥0 } {y z : ℝ} (hx0 : 0 < x) (hx1 : x < 1) (hyz : z < y) : (x^y) < (x^z) :=
  Real.rpow_lt_rpow_of_exponent_gt hx0 hx1 hyz

theorem rpow_le_rpow_of_exponent_ge {x :  ℝ≥0 } {y z : ℝ} (hx0 : 0 < x) (hx1 : x ≤ 1) (hyz : z ≤ y) : (x^y) ≤ (x^z) :=
  Real.rpow_le_rpow_of_exponent_ge hx0 hx1 hyz

theorem rpow_lt_one {x :  ℝ≥0 } {z : ℝ} (hx : 0 ≤ x) (hx1 : x < 1) (hz : 0 < z) : (x^z) < 1 :=
  Real.rpow_lt_one hx hx1 hz

theorem rpow_le_one {x :  ℝ≥0 } {z : ℝ} (hx2 : x ≤ 1) (hz : 0 ≤ z) : (x^z) ≤ 1 :=
  Real.rpow_le_one x.2 hx2 hz

theorem rpow_lt_one_of_one_lt_of_neg {x :  ℝ≥0 } {z : ℝ} (hx : 1 < x) (hz : z < 0) : (x^z) < 1 :=
  Real.rpow_lt_one_of_one_lt_of_neg hx hz

theorem rpow_le_one_of_one_le_of_nonpos {x :  ℝ≥0 } {z : ℝ} (hx : 1 ≤ x) (hz : z ≤ 0) : (x^z) ≤ 1 :=
  Real.rpow_le_one_of_one_le_of_nonpos hx hz

theorem one_lt_rpow {x :  ℝ≥0 } {z : ℝ} (hx : 1 < x) (hz : 0 < z) : 1 < (x^z) :=
  Real.one_lt_rpow hx hz

theorem one_le_rpow {x :  ℝ≥0 } {z : ℝ} (h : 1 ≤ x) (h₁ : 0 ≤ z) : 1 ≤ (x^z) :=
  Real.one_le_rpow h h₁

theorem one_lt_rpow_of_pos_of_lt_one_of_neg {x :  ℝ≥0 } {z : ℝ} (hx1 : 0 < x) (hx2 : x < 1) (hz : z < 0) : 1 < (x^z) :=
  Real.one_lt_rpow_of_pos_of_lt_one_of_neg hx1 hx2 hz

theorem one_le_rpow_of_pos_of_le_one_of_nonpos {x :  ℝ≥0 } {z : ℝ} (hx1 : 0 < x) (hx2 : x ≤ 1) (hz : z ≤ 0) :
  1 ≤ (x^z) :=
  Real.one_le_rpow_of_pos_of_le_one_of_nonpos hx1 hx2 hz

theorem pow_nat_rpow_nat_inv (x :  ℝ≥0 ) {n : ℕ} (hn : 0 < n) : ((x^n)^(n⁻¹ : ℝ)) = x :=
  by 
    rw [←Nnreal.coe_eq, coe_rpow, Nnreal.coe_pow]
    exact Real.pow_nat_rpow_nat_inv x.2 hn

theorem rpow_nat_inv_pow_nat (x :  ℝ≥0 ) {n : ℕ} (hn : 0 < n) : ((x^(n⁻¹ : ℝ))^n) = x :=
  by 
    rw [←Nnreal.coe_eq, Nnreal.coe_pow, coe_rpow]
    exact Real.rpow_nat_inv_pow_nat x.2 hn

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem continuous_at_rpow
{x : «exprℝ≥0»()}
{y : exprℝ()}
(h : «expr ∨ »(«expr ≠ »(x, 0), «expr < »(0, y))) : continuous_at (λ
 p : «expr × »(«exprℝ≥0»(), exprℝ()), «expr ^ »(p.1, p.2)) (x, y) :=
begin
  have [] [":", expr «expr = »(λ
    p : «expr × »(«exprℝ≥0»(), exprℝ()), «expr ^ »(p.1, p.2), «expr ∘ »(real.to_nnreal, «expr ∘ »(λ
      p : «expr × »(exprℝ(), exprℝ()), «expr ^ »(p.1, p.2), λ p : «expr × »(«exprℝ≥0»(), exprℝ()), (p.1.1, p.2))))] [],
  { ext [] [ident p] [],
    rw ["[", expr coe_rpow, ",", expr real.coe_to_nnreal _ (real.rpow_nonneg_of_nonneg p.1.2 _), "]"] [],
    refl },
  rw [expr this] [],
  refine [expr nnreal.continuous_of_real.continuous_at.comp (continuous_at.comp _ _)],
  { apply [expr real.continuous_at_rpow],
    simp [] [] [] [] [] ["at", ident h],
    rw ["<-", expr nnreal.coe_eq_zero x] ["at", ident h],
    exact [expr h] },
  { exact [expr ((continuous_subtype_val.comp continuous_fst).prod_mk continuous_snd).continuous_at] }
end

theorem _root_.real.to_nnreal_rpow_of_nonneg {x y : ℝ} (hx : 0 ≤ x) : Real.toNnreal (x^y) = (Real.toNnreal x^y) :=
  by 
    nthRw 0[←Real.coe_to_nnreal x hx]
    rw [←Nnreal.coe_rpow, Real.to_nnreal_coe]

end Nnreal

open Filter

theorem Filter.Tendsto.nnrpow {α : Type _} {f : Filter α} {u : α →  ℝ≥0 } {v : α → ℝ} {x :  ℝ≥0 } {y : ℝ}
  (hx : tendsto u f (𝓝 x)) (hy : tendsto v f (𝓝 y)) (h : x ≠ 0 ∨ 0 < y) : tendsto (fun a => u a^v a) f (𝓝 (x^y)) :=
  tendsto.comp (Nnreal.continuous_at_rpow h) (hx.prod_mk_nhds hy)

namespace Nnreal

theorem continuous_at_rpow_const {x :  ℝ≥0 } {y : ℝ} (h : x ≠ 0 ∨ 0 ≤ y) : ContinuousAt (fun z => z^y) x :=
  (h.elim fun h => tendsto_id.nnrpow tendsto_const_nhds (Or.inl h))$
    fun h =>
      h.eq_or_lt.elim
        (fun h =>
          h ▸
            by 
              simp only [rpow_zero, continuous_at_const])
        fun h => tendsto_id.nnrpow tendsto_const_nhds (Or.inr h)

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem continuous_rpow_const {y : exprℝ()} (h : «expr ≤ »(0, y)) : continuous (λ x : «exprℝ≥0»(), «expr ^ »(x, y)) :=
«expr $ »(continuous_iff_continuous_at.2, λ x, continuous_at_rpow_const (or.inr h))

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem tendsto_rpow_at_top
{y : exprℝ()}
(hy : «expr < »(0, y)) : tendsto (λ x : «exprℝ≥0»(), «expr ^ »(x, y)) at_top at_top :=
begin
  rw [expr filter.tendsto_at_top_at_top] [],
  intros [ident b],
  obtain ["⟨", ident c, ",", ident hc, "⟩", ":=", expr tendsto_at_top_at_top.mp (tendsto_rpow_at_top hy) b],
  use [expr c.to_nnreal],
  intros [ident a, ident ha],
  exact_mod_cast [expr hc a (real.to_nnreal_le_iff_le_coe.mp ha)]
end

end Nnreal

namespace Ennreal

/-- The real power function `x^y` on extended nonnegative reals, defined for `x : ℝ≥0∞` and
`y : ℝ` as the restriction of the real power function if `0 < x < ⊤`, and with the natural values
for `0` and `⊤` (i.e., `0 ^ x = 0` for `x > 0`, `1` for `x = 0` and `⊤` for `x < 0`, and
`⊤ ^ x = 1 / 0 ^ x`). -/
noncomputable def rpow : ℝ≥0∞ → ℝ → ℝ≥0∞
| some x, y => if x = 0 ∧ y < 0 then ⊤ else (x^y :  ℝ≥0 )
| none, y => if 0 < y then ⊤ else if y = 0 then 1 else 0

noncomputable instance  : Pow ℝ≥0∞ ℝ :=
  ⟨rpow⟩

@[simp]
theorem rpow_eq_pow (x : ℝ≥0∞) (y : ℝ) : rpow x y = (x^y) :=
  rfl

@[simp]
theorem rpow_zero {x : ℝ≥0∞} : (x^(0 : ℝ)) = 1 :=
  by 
    cases x <;>
      ·
        dsimp only [·^·, rpow]
        simp [lt_irreflₓ]

theorem top_rpow_def (y : ℝ) : ((⊤ : ℝ≥0∞)^y) = if 0 < y then ⊤ else if y = 0 then 1 else 0 :=
  rfl

@[simp]
theorem top_rpow_of_pos {y : ℝ} (h : 0 < y) : ((⊤ : ℝ≥0∞)^y) = ⊤ :=
  by 
    simp [top_rpow_def, h]

@[simp]
theorem top_rpow_of_neg {y : ℝ} (h : y < 0) : ((⊤ : ℝ≥0∞)^y) = 0 :=
  by 
    simp [top_rpow_def, asymm h, ne_of_ltₓ h]

@[simp]
theorem zero_rpow_of_pos {y : ℝ} (h : 0 < y) : ((0 : ℝ≥0∞)^y) = 0 :=
  by 
    rw [←Ennreal.coe_zero, ←Ennreal.some_eq_coe]
    dsimp only [·^·, rpow]
    simp [h, asymm h, ne_of_gtₓ h]

@[simp]
theorem zero_rpow_of_neg {y : ℝ} (h : y < 0) : ((0 : ℝ≥0∞)^y) = ⊤ :=
  by 
    rw [←Ennreal.coe_zero, ←Ennreal.some_eq_coe]
    dsimp only [·^·, rpow]
    simp [h, ne_of_gtₓ h]

theorem zero_rpow_def (y : ℝ) : ((0 : ℝ≥0∞)^y) = if 0 < y then 0 else if y = 0 then 1 else ⊤ :=
  by 
    rcases lt_trichotomyₓ 0 y with (H | rfl | H)
    ·
      simp [H, ne_of_gtₓ, zero_rpow_of_pos, lt_irreflₓ]
    ·
      simp [lt_irreflₓ]
    ·
      simp [H, asymm H, ne_of_ltₓ, zero_rpow_of_neg]

@[simp]
theorem zero_rpow_mul_self (y : ℝ) : (((0 : ℝ≥0∞)^y)*0^y) = (0^y) :=
  by 
    rw [zero_rpow_def]
    splitIfs 
    exacts[zero_mul _, one_mulₓ _, top_mul_top]

@[normCast]
theorem coe_rpow_of_ne_zero {x :  ℝ≥0 } (h : x ≠ 0) (y : ℝ) : ((x : ℝ≥0∞)^y) = (x^y :  ℝ≥0 ) :=
  by 
    rw [←Ennreal.some_eq_coe]
    dsimp only [·^·, rpow]
    simp [h]

@[normCast]
theorem coe_rpow_of_nonneg (x :  ℝ≥0 ) {y : ℝ} (h : 0 ≤ y) : ((x : ℝ≥0∞)^y) = (x^y :  ℝ≥0 ) :=
  by 
    byCases' hx : x = 0
    ·
      rcases le_iff_eq_or_lt.1 h with (H | H)
      ·
        simp [hx, H.symm]
      ·
        simp [hx, zero_rpow_of_pos H, Nnreal.zero_rpow (ne_of_gtₓ H)]
    ·
      exact coe_rpow_of_ne_zero hx _

theorem coe_rpow_def (x :  ℝ≥0 ) (y : ℝ) : ((x : ℝ≥0∞)^y) = if x = 0 ∧ y < 0 then ⊤ else (x^y :  ℝ≥0 ) :=
  rfl

@[simp]
theorem rpow_one (x : ℝ≥0∞) : (x^(1 : ℝ)) = x :=
  by 
    cases x <;> dsimp only [·^·, rpow] <;> simp [zero_lt_one, not_lt_of_le zero_le_one]

@[simp]
theorem one_rpow (x : ℝ) : ((1 : ℝ≥0∞)^x) = 1 :=
  by 
    rw [←coe_one, coe_rpow_of_ne_zero one_ne_zero]
    simp 

@[simp]
theorem rpow_eq_zero_iff {x : ℝ≥0∞} {y : ℝ} : (x^y) = 0 ↔ x = 0 ∧ 0 < y ∨ x = ⊤ ∧ y < 0 :=
  by 
    cases x
    ·
      rcases lt_trichotomyₓ y 0 with (H | H | H) <;> simp [H, top_rpow_of_neg, top_rpow_of_pos, le_of_ltₓ]
    ·
      byCases' h : x = 0
      ·
        rcases lt_trichotomyₓ y 0 with (H | H | H) <;> simp [h, H, zero_rpow_of_neg, zero_rpow_of_pos, le_of_ltₓ]
      ·
        simp [coe_rpow_of_ne_zero h, h]

@[simp]
theorem rpow_eq_top_iff {x : ℝ≥0∞} {y : ℝ} : (x^y) = ⊤ ↔ x = 0 ∧ y < 0 ∨ x = ⊤ ∧ 0 < y :=
  by 
    cases x
    ·
      rcases lt_trichotomyₓ y 0 with (H | H | H) <;> simp [H, top_rpow_of_neg, top_rpow_of_pos, le_of_ltₓ]
    ·
      byCases' h : x = 0
      ·
        rcases lt_trichotomyₓ y 0 with (H | H | H) <;> simp [h, H, zero_rpow_of_neg, zero_rpow_of_pos, le_of_ltₓ]
      ·
        simp [coe_rpow_of_ne_zero h, h]

theorem rpow_eq_top_iff_of_pos {x : ℝ≥0∞} {y : ℝ} (hy : 0 < y) : (x^y) = ⊤ ↔ x = ⊤ :=
  by 
    simp [rpow_eq_top_iff, hy, asymm hy]

theorem rpow_eq_top_of_nonneg (x : ℝ≥0∞) {y : ℝ} (hy0 : 0 ≤ y) : (x^y) = ⊤ → x = ⊤ :=
  by 
    rw [Ennreal.rpow_eq_top_iff]
    intro h 
    cases h
    ·
      exfalso 
      rw [lt_iff_not_geₓ] at h 
      exact h.right hy0
    ·
      exact h.left

theorem rpow_ne_top_of_nonneg {x : ℝ≥0∞} {y : ℝ} (hy0 : 0 ≤ y) (h : x ≠ ⊤) : (x^y) ≠ ⊤ :=
  mt (Ennreal.rpow_eq_top_of_nonneg x hy0) h

theorem rpow_lt_top_of_nonneg {x : ℝ≥0∞} {y : ℝ} (hy0 : 0 ≤ y) (h : x ≠ ⊤) : (x^y) < ⊤ :=
  lt_top_iff_ne_top.mpr (Ennreal.rpow_ne_top_of_nonneg hy0 h)

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem rpow_add
{x : «exprℝ≥0∞»()}
(y z : exprℝ())
(hx : «expr ≠ »(x, 0))
(h'x : «expr ≠ »(x, «expr⊤»())) : «expr = »(«expr ^ »(x, «expr + »(y, z)), «expr * »(«expr ^ »(x, y), «expr ^ »(x, z))) :=
begin
  cases [expr x] [],
  { exact [expr (h'x rfl).elim] },
  have [] [":", expr «expr ≠ »(x, 0)] [":=", expr λ h, by simpa [] [] [] ["[", expr h, "]"] [] ["using", expr hx]],
  simp [] [] [] ["[", expr coe_rpow_of_ne_zero this, ",", expr nnreal.rpow_add this, "]"] [] []
end

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem rpow_neg (x : «exprℝ≥0∞»()) (y : exprℝ()) : «expr = »(«expr ^ »(x, «expr- »(y)), «expr ⁻¹»(«expr ^ »(x, y))) :=
begin
  cases [expr x] [],
  { rcases [expr lt_trichotomy y 0, "with", ident H, "|", ident H, "|", ident H]; simp [] [] [] ["[", expr top_rpow_of_pos, ",", expr top_rpow_of_neg, ",", expr H, ",", expr neg_pos.mpr, "]"] [] [] },
  { by_cases [expr h, ":", expr «expr = »(x, 0)],
    { rcases [expr lt_trichotomy y 0, "with", ident H, "|", ident H, "|", ident H]; simp [] [] [] ["[", expr h, ",", expr zero_rpow_of_pos, ",", expr zero_rpow_of_neg, ",", expr H, ",", expr neg_pos.mpr, "]"] [] [] },
    { have [ident A] [":", expr «expr ≠ »(«expr ^ »(x, y), 0)] [],
      by simp [] [] [] ["[", expr h, "]"] [] [],
      simp [] [] [] ["[", expr coe_rpow_of_ne_zero h, ",", "<-", expr coe_inv A, ",", expr nnreal.rpow_neg, "]"] [] [] } }
end

theorem rpow_sub {x : ℝ≥0∞} (y z : ℝ) (hx : x ≠ 0) (h'x : x ≠ ⊤) : (x^y - z) = (x^y) / (x^z) :=
  by 
    rw [sub_eq_add_neg, rpow_add _ _ hx h'x, rpow_neg, div_eq_mul_inv]

theorem rpow_neg_one (x : ℝ≥0∞) : (x^(-1 : ℝ)) = x⁻¹ :=
  by 
    simp [rpow_neg]

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem rpow_mul
(x : «exprℝ≥0∞»())
(y z : exprℝ()) : «expr = »(«expr ^ »(x, «expr * »(y, z)), «expr ^ »(«expr ^ »(x, y), z)) :=
begin
  cases [expr x] [],
  { rcases [expr lt_trichotomy y 0, "with", ident Hy, "|", ident Hy, "|", ident Hy]; rcases [expr lt_trichotomy z 0, "with", ident Hz, "|", ident Hz, "|", ident Hz]; simp [] [] [] ["[", expr Hy, ",", expr Hz, ",", expr zero_rpow_of_neg, ",", expr zero_rpow_of_pos, ",", expr top_rpow_of_neg, ",", expr top_rpow_of_pos, ",", expr mul_pos_of_neg_of_neg, ",", expr mul_neg_of_neg_of_pos, ",", expr mul_neg_of_pos_of_neg, "]"] [] [] },
  { by_cases [expr h, ":", expr «expr = »(x, 0)],
    { rcases [expr lt_trichotomy y 0, "with", ident Hy, "|", ident Hy, "|", ident Hy]; rcases [expr lt_trichotomy z 0, "with", ident Hz, "|", ident Hz, "|", ident Hz]; simp [] [] [] ["[", expr h, ",", expr Hy, ",", expr Hz, ",", expr zero_rpow_of_neg, ",", expr zero_rpow_of_pos, ",", expr top_rpow_of_neg, ",", expr top_rpow_of_pos, ",", expr mul_pos_of_neg_of_neg, ",", expr mul_neg_of_neg_of_pos, ",", expr mul_neg_of_pos_of_neg, "]"] [] [] },
    { have [] [":", expr «expr ≠ »(«expr ^ »(x, y), 0)] [],
      by simp [] [] [] ["[", expr h, "]"] [] [],
      simp [] [] [] ["[", expr coe_rpow_of_ne_zero h, ",", expr coe_rpow_of_ne_zero this, ",", expr nnreal.rpow_mul, "]"] [] [] } }
end

@[simp, normCast]
theorem rpow_nat_cast (x : ℝ≥0∞) (n : ℕ) : (x^(n : ℝ)) = (x^n) :=
  by 
    cases x
    ·
      cases n <;> simp [top_rpow_of_pos (Nat.cast_add_one_pos _), top_pow (Nat.succ_posₓ _)]
    ·
      simp [coe_rpow_of_nonneg _ (Nat.cast_nonneg n)]

theorem mul_rpow_eq_ite (x y : ℝ≥0∞) (z : ℝ) :
  ((x*y)^z) = if (x = 0 ∧ y = ⊤ ∨ x = ⊤ ∧ y = 0) ∧ z < 0 then ⊤ else (x^z)*y^z :=
  by 
    rcases eq_or_ne z 0 with (rfl | hz)
    ·
      simp 
    replace hz := hz.lt_or_lt 
    wlog (discharger := tactic.skip) hxy : x ≤ y := le_totalₓ x y using x y, y x
    ·
      rcases eq_or_ne x 0 with (rfl | hx0)
      ·
        induction y using WithTop.recTopCoe <;> cases' hz with hz hz <;> simp [hz.not_lt]
      rcases eq_or_ne y 0 with (rfl | hy0)
      ·
        exact (hx0 (bot_unique hxy)).elim 
      induction x using WithTop.recTopCoe
      ·
        cases' hz with hz hz <;> simp [hz, top_unique hxy]
      induction y using WithTop.recTopCoe
      ·
        cases' hz with hz hz <;> simp 
      simp only [false_andₓ, and_falseₓ, false_orₓ, if_false]
      normCast  at *
      rw [coe_rpow_of_ne_zero (mul_ne_zero hx0 hy0), Nnreal.mul_rpow]
    ·
      convert this using 2 <;> simp only [mul_commₓ, and_comm, or_comm]

theorem mul_rpow_of_ne_top {x y : ℝ≥0∞} (hx : x ≠ ⊤) (hy : y ≠ ⊤) (z : ℝ) : ((x*y)^z) = (x^z)*y^z :=
  by 
    simp [mul_rpow_eq_ite]

@[normCast]
theorem coe_mul_rpow (x y :  ℝ≥0 ) (z : ℝ) : (((x : ℝ≥0∞)*y)^z) = (x^z)*y^z :=
  mul_rpow_of_ne_top coe_ne_top coe_ne_top z

theorem mul_rpow_of_ne_zero {x y : ℝ≥0∞} (hx : x ≠ 0) (hy : y ≠ 0) (z : ℝ) : ((x*y)^z) = (x^z)*y^z :=
  by 
    simp [mul_rpow_eq_ite]

theorem mul_rpow_of_nonneg (x y : ℝ≥0∞) {z : ℝ} (hz : 0 ≤ z) : ((x*y)^z) = (x^z)*y^z :=
  by 
    simp [hz.not_lt, mul_rpow_eq_ite]

theorem inv_rpow (x : ℝ≥0∞) (y : ℝ) : (x⁻¹^y) = (x^y)⁻¹ :=
  by 
    rcases eq_or_ne y 0 with (rfl | hy)
    ·
      simp only [rpow_zero, inv_one]
    replace hy := hy.lt_or_lt 
    rcases eq_or_ne x 0 with (rfl | h0)
    ·
      cases hy <;> simp 
    rcases eq_or_ne x ⊤ with (rfl | h_top)
    ·
      cases hy <;> simp 
    apply eq_inv_of_mul_eq_one 
    rw [←mul_rpow_of_ne_zero (inv_ne_zero.2 h_top) h0, inv_mul_cancel h0 h_top, one_rpow]

theorem div_rpow_of_nonneg (x y : ℝ≥0∞) {z : ℝ} (hz : 0 ≤ z) : (x / y^z) = (x^z) / (y^z) :=
  by 
    rw [div_eq_mul_inv, mul_rpow_of_nonneg _ _ hz, inv_rpow, div_eq_mul_inv]

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem strict_mono_rpow_of_pos
{z : exprℝ()}
(h : «expr < »(0, z)) : strict_mono (λ x : «exprℝ≥0∞»(), «expr ^ »(x, z)) :=
begin
  intros [ident x, ident y, ident hxy],
  lift [expr x] ["to", expr «exprℝ≥0»()] ["using", expr ne_top_of_lt hxy] [],
  rcases [expr eq_or_ne y «expr∞»(), "with", ident rfl, "|", ident hy],
  { simp [] [] ["only"] ["[", expr top_rpow_of_pos h, ",", expr coe_rpow_of_nonneg _ h.le, ",", expr coe_lt_top, "]"] [] [] },
  { lift [expr y] ["to", expr «exprℝ≥0»()] ["using", expr hy] [],
    simp [] [] ["only"] ["[", expr coe_rpow_of_nonneg _ h.le, ",", expr nnreal.rpow_lt_rpow (coe_lt_coe.1 hxy) h, ",", expr coe_lt_coe, "]"] [] [] }
end

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem monotone_rpow_of_nonneg {z : exprℝ()} (h : «expr ≤ »(0, z)) : monotone (λ x : «exprℝ≥0∞»(), «expr ^ »(x, z)) :=
h.eq_or_lt.elim (λ
 h0, «expr ▸ »(h0, by simp [] [] ["only"] ["[", expr rpow_zero, ",", expr monotone_const, "]"] [] [])) (λ
 h0, (strict_mono_rpow_of_pos h0).monotone)

theorem rpow_le_rpow {x y : ℝ≥0∞} {z : ℝ} (h₁ : x ≤ y) (h₂ : 0 ≤ z) : (x^z) ≤ (y^z) :=
  monotone_rpow_of_nonneg h₂ h₁

theorem rpow_lt_rpow {x y : ℝ≥0∞} {z : ℝ} (h₁ : x < y) (h₂ : 0 < z) : (x^z) < (y^z) :=
  strict_mono_rpow_of_pos h₂ h₁

theorem rpow_le_rpow_iff {x y : ℝ≥0∞} {z : ℝ} (hz : 0 < z) : (x^z) ≤ (y^z) ↔ x ≤ y :=
  (strict_mono_rpow_of_pos hz).le_iff_le

theorem rpow_lt_rpow_iff {x y : ℝ≥0∞} {z : ℝ} (hz : 0 < z) : (x^z) < (y^z) ↔ x < y :=
  (strict_mono_rpow_of_pos hz).lt_iff_lt

theorem le_rpow_one_div_iff {x y : ℝ≥0∞} {z : ℝ} (hz : 0 < z) : x ≤ (y^1 / z) ↔ (x^z) ≤ y :=
  by 
    nthRw 0[←rpow_one x]
    nthRw 0[←@_root_.mul_inv_cancel _ _ z hz.ne']
    rw [rpow_mul, ←one_div,
      @rpow_le_rpow_iff _ _ (1 / z)
        (by 
          simp [hz])]

theorem lt_rpow_one_div_iff {x y : ℝ≥0∞} {z : ℝ} (hz : 0 < z) : x < (y^1 / z) ↔ (x^z) < y :=
  by 
    nthRw 0[←rpow_one x]
    nthRw 0[←@_root_.mul_inv_cancel _ _ z (ne_of_ltₓ hz).symm]
    rw [rpow_mul, ←one_div,
      @rpow_lt_rpow_iff _ _ (1 / z)
        (by 
          simp [hz])]

theorem rpow_lt_rpow_of_exponent_lt {x : ℝ≥0∞} {y z : ℝ} (hx : 1 < x) (hx' : x ≠ ⊤) (hyz : y < z) : (x^y) < (x^z) :=
  by 
    lift x to  ℝ≥0  using hx' 
    rw [one_lt_coe_iff] at hx 
    simp [coe_rpow_of_ne_zero (ne_of_gtₓ (lt_transₓ zero_lt_one hx)), Nnreal.rpow_lt_rpow_of_exponent_lt hx hyz]

theorem rpow_le_rpow_of_exponent_le {x : ℝ≥0∞} {y z : ℝ} (hx : 1 ≤ x) (hyz : y ≤ z) : (x^y) ≤ (x^z) :=
  by 
    cases x
    ·
      rcases lt_trichotomyₓ y 0 with (Hy | Hy | Hy) <;>
        rcases lt_trichotomyₓ z 0 with (Hz | Hz | Hz) <;>
          simp [Hy, Hz, top_rpow_of_neg, top_rpow_of_pos, le_reflₓ] <;> linarith
    ·
      simp only [one_le_coe_iff, some_eq_coe] at hx 
      simp [coe_rpow_of_ne_zero (ne_of_gtₓ (lt_of_lt_of_leₓ zero_lt_one hx)), Nnreal.rpow_le_rpow_of_exponent_le hx hyz]

theorem rpow_lt_rpow_of_exponent_gt {x : ℝ≥0∞} {y z : ℝ} (hx0 : 0 < x) (hx1 : x < 1) (hyz : z < y) : (x^y) < (x^z) :=
  by 
    lift x to  ℝ≥0  using ne_of_ltₓ (lt_of_lt_of_leₓ hx1 le_top)
    simp  at hx0 hx1 
    simp [coe_rpow_of_ne_zero (ne_of_gtₓ hx0), Nnreal.rpow_lt_rpow_of_exponent_gt hx0 hx1 hyz]

theorem rpow_le_rpow_of_exponent_ge {x : ℝ≥0∞} {y z : ℝ} (hx1 : x ≤ 1) (hyz : z ≤ y) : (x^y) ≤ (x^z) :=
  by 
    lift x to  ℝ≥0  using ne_of_ltₓ (lt_of_le_of_ltₓ hx1 coe_lt_top)
    byCases' h : x = 0
    ·
      rcases lt_trichotomyₓ y 0 with (Hy | Hy | Hy) <;>
        rcases lt_trichotomyₓ z 0 with (Hz | Hz | Hz) <;>
          simp [Hy, Hz, h, zero_rpow_of_neg, zero_rpow_of_pos, le_reflₓ] <;> linarith
    ·
      simp  at hx1 
      simp [coe_rpow_of_ne_zero h, Nnreal.rpow_le_rpow_of_exponent_ge (bot_lt_iff_ne_bot.mpr h) hx1 hyz]

theorem rpow_le_self_of_le_one {x : ℝ≥0∞} {z : ℝ} (hx : x ≤ 1) (h_one_le : 1 ≤ z) : (x^z) ≤ x :=
  by 
    nthRw 1[←Ennreal.rpow_one x]
    exact Ennreal.rpow_le_rpow_of_exponent_ge hx h_one_le

theorem le_rpow_self_of_one_le {x : ℝ≥0∞} {z : ℝ} (hx : 1 ≤ x) (h_one_le : 1 ≤ z) : x ≤ (x^z) :=
  by 
    nthRw 0[←Ennreal.rpow_one x]
    exact Ennreal.rpow_le_rpow_of_exponent_le hx h_one_le

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem rpow_pos_of_nonneg
{p : exprℝ()}
{x : «exprℝ≥0∞»()}
(hx_pos : «expr < »(0, x))
(hp_nonneg : «expr ≤ »(0, p)) : «expr < »(0, «expr ^ »(x, p)) :=
begin
  by_cases [expr hp_zero, ":", expr «expr = »(p, 0)],
  { simp [] [] [] ["[", expr hp_zero, ",", expr ennreal.zero_lt_one, "]"] [] [] },
  { rw ["<-", expr ne.def] ["at", ident hp_zero],
    have [ident hp_pos] [] [":=", expr lt_of_le_of_ne hp_nonneg hp_zero.symm],
    rw ["<-", expr zero_rpow_of_pos hp_pos] [],
    exact [expr rpow_lt_rpow hx_pos hp_pos] }
end

theorem rpow_pos {p : ℝ} {x : ℝ≥0∞} (hx_pos : 0 < x) (hx_ne_top : x ≠ ⊤) : 0 < (x^p) :=
  by 
    cases' lt_or_leₓ 0 p with hp_pos hp_nonpos
    ·
      exact rpow_pos_of_nonneg hx_pos (le_of_ltₓ hp_pos)
    ·
      rw [←neg_negₓ p, rpow_neg, inv_pos]
      exact
        rpow_ne_top_of_nonneg
          (by 
            simp [hp_nonpos])
          hx_ne_top

theorem rpow_lt_one {x : ℝ≥0∞} {z : ℝ} (hx : x < 1) (hz : 0 < z) : (x^z) < 1 :=
  by 
    lift x to  ℝ≥0  using ne_of_ltₓ (lt_of_lt_of_leₓ hx le_top)
    simp only [coe_lt_one_iff] at hx 
    simp [coe_rpow_of_nonneg _ (le_of_ltₓ hz), Nnreal.rpow_lt_one (zero_le x) hx hz]

theorem rpow_le_one {x : ℝ≥0∞} {z : ℝ} (hx : x ≤ 1) (hz : 0 ≤ z) : (x^z) ≤ 1 :=
  by 
    lift x to  ℝ≥0  using ne_of_ltₓ (lt_of_le_of_ltₓ hx coe_lt_top)
    simp only [coe_le_one_iff] at hx 
    simp [coe_rpow_of_nonneg _ hz, Nnreal.rpow_le_one hx hz]

theorem rpow_lt_one_of_one_lt_of_neg {x : ℝ≥0∞} {z : ℝ} (hx : 1 < x) (hz : z < 0) : (x^z) < 1 :=
  by 
    cases x
    ·
      simp [top_rpow_of_neg hz, Ennreal.zero_lt_one]
    ·
      simp only [some_eq_coe, one_lt_coe_iff] at hx 
      simp [coe_rpow_of_ne_zero (ne_of_gtₓ (lt_transₓ zero_lt_one hx)), Nnreal.rpow_lt_one_of_one_lt_of_neg hx hz]

theorem rpow_le_one_of_one_le_of_neg {x : ℝ≥0∞} {z : ℝ} (hx : 1 ≤ x) (hz : z < 0) : (x^z) ≤ 1 :=
  by 
    cases x
    ·
      simp [top_rpow_of_neg hz, Ennreal.zero_lt_one]
    ·
      simp only [one_le_coe_iff, some_eq_coe] at hx 
      simp [coe_rpow_of_ne_zero (ne_of_gtₓ (lt_of_lt_of_leₓ zero_lt_one hx)),
        Nnreal.rpow_le_one_of_one_le_of_nonpos hx (le_of_ltₓ hz)]

theorem one_lt_rpow {x : ℝ≥0∞} {z : ℝ} (hx : 1 < x) (hz : 0 < z) : 1 < (x^z) :=
  by 
    cases x
    ·
      simp [top_rpow_of_pos hz]
    ·
      simp only [some_eq_coe, one_lt_coe_iff] at hx 
      simp [coe_rpow_of_nonneg _ (le_of_ltₓ hz), Nnreal.one_lt_rpow hx hz]

theorem one_le_rpow {x : ℝ≥0∞} {z : ℝ} (hx : 1 ≤ x) (hz : 0 < z) : 1 ≤ (x^z) :=
  by 
    cases x
    ·
      simp [top_rpow_of_pos hz]
    ·
      simp only [one_le_coe_iff, some_eq_coe] at hx 
      simp [coe_rpow_of_nonneg _ (le_of_ltₓ hz), Nnreal.one_le_rpow hx (le_of_ltₓ hz)]

theorem one_lt_rpow_of_pos_of_lt_one_of_neg {x : ℝ≥0∞} {z : ℝ} (hx1 : 0 < x) (hx2 : x < 1) (hz : z < 0) : 1 < (x^z) :=
  by 
    lift x to  ℝ≥0  using ne_of_ltₓ (lt_of_lt_of_leₓ hx2 le_top)
    simp only [coe_lt_one_iff, coe_pos] at hx1 hx2⊢
    simp [coe_rpow_of_ne_zero (ne_of_gtₓ hx1), Nnreal.one_lt_rpow_of_pos_of_lt_one_of_neg hx1 hx2 hz]

theorem one_le_rpow_of_pos_of_le_one_of_neg {x : ℝ≥0∞} {z : ℝ} (hx1 : 0 < x) (hx2 : x ≤ 1) (hz : z < 0) : 1 ≤ (x^z) :=
  by 
    lift x to  ℝ≥0  using ne_of_ltₓ (lt_of_le_of_ltₓ hx2 coe_lt_top)
    simp only [coe_le_one_iff, coe_pos] at hx1 hx2⊢
    simp [coe_rpow_of_ne_zero (ne_of_gtₓ hx1), Nnreal.one_le_rpow_of_pos_of_le_one_of_nonpos hx1 hx2 (le_of_ltₓ hz)]

theorem to_nnreal_rpow (x : ℝ≥0∞) (z : ℝ) : (x.to_nnreal^z) = (x^z).toNnreal :=
  by 
    rcases lt_trichotomyₓ z 0 with (H | H | H)
    ·
      cases x
      ·
        simp [H, ne_of_ltₓ]
      byCases' hx : x = 0
      ·
        simp [hx, H, ne_of_ltₓ]
      ·
        simp [coe_rpow_of_ne_zero hx]
    ·
      simp [H]
    ·
      cases x
      ·
        simp [H, ne_of_gtₓ]
      simp [coe_rpow_of_nonneg _ (le_of_ltₓ H)]

theorem to_real_rpow (x : ℝ≥0∞) (z : ℝ) : (x.to_real^z) = (x^z).toReal :=
  by 
    rw [Ennreal.toReal, Ennreal.toReal, ←Nnreal.coe_rpow, Ennreal.to_nnreal_rpow]

theorem of_real_rpow_of_pos {x p : ℝ} (hx_pos : 0 < x) : (Ennreal.ofReal x^p) = Ennreal.ofReal (x^p) :=
  by 
    simpRw [Ennreal.ofReal]
    rw [coe_rpow_of_ne_zero, coe_eq_coe, Real.to_nnreal_rpow_of_nonneg hx_pos.le]
    simp [hx_pos]

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem of_real_rpow_of_nonneg
{x p : exprℝ()}
(hx_nonneg : «expr ≤ »(0, x))
(hp_nonneg : «expr ≤ »(0, p)) : «expr = »(«expr ^ »(ennreal.of_real x, p), ennreal.of_real «expr ^ »(x, p)) :=
begin
  by_cases [expr hp0, ":", expr «expr = »(p, 0)],
  { simp [] [] [] ["[", expr hp0, "]"] [] [] },
  by_cases [expr hx0, ":", expr «expr = »(x, 0)],
  { rw ["<-", expr ne.def] ["at", ident hp0],
    have [ident hp_pos] [":", expr «expr < »(0, p)] [":=", expr lt_of_le_of_ne hp_nonneg hp0.symm],
    simp [] [] [] ["[", expr hx0, ",", expr hp_pos, ",", expr hp_pos.ne.symm, "]"] [] [] },
  rw ["<-", expr ne.def] ["at", ident hx0],
  exact [expr of_real_rpow_of_pos (hx_nonneg.lt_of_ne hx0.symm)]
end

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem rpow_left_injective
{x : exprℝ()}
(hx : «expr ≠ »(x, 0)) : function.injective (λ y : «exprℝ≥0∞»(), «expr ^ »(y, x)) :=
begin
  intros [ident y, ident z, ident hyz],
  dsimp ["only"] [] [] ["at", ident hyz],
  rw ["[", "<-", expr rpow_one y, ",", "<-", expr rpow_one z, ",", "<-", expr _root_.mul_inv_cancel hx, ",", expr rpow_mul, ",", expr rpow_mul, ",", expr hyz, "]"] []
end

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem rpow_left_surjective
{x : exprℝ()}
(hx : «expr ≠ »(x, 0)) : function.surjective (λ y : «exprℝ≥0∞»(), «expr ^ »(y, x)) :=
λ
y, ⟨«expr ^ »(y, «expr ⁻¹»(x)), by simp_rw ["[", "<-", expr rpow_mul, ",", expr _root_.inv_mul_cancel hx, ",", expr rpow_one, "]"] []⟩

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem rpow_left_bijective
{x : exprℝ()}
(hx : «expr ≠ »(x, 0)) : function.bijective (λ y : «exprℝ≥0∞»(), «expr ^ »(y, x)) :=
⟨rpow_left_injective hx, rpow_left_surjective hx⟩

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem rpow_left_monotone_of_nonneg
{x : exprℝ()}
(hx : «expr ≤ »(0, x)) : monotone (λ y : «exprℝ≥0∞»(), «expr ^ »(y, x)) :=
λ y z hyz, rpow_le_rpow hyz hx

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem rpow_left_strict_mono_of_pos
{x : exprℝ()}
(hx : «expr < »(0, x)) : strict_mono (λ y : «exprℝ≥0∞»(), «expr ^ »(y, x)) :=
λ y z hyz, rpow_lt_rpow hyz hx

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem tendsto_rpow_at_top
{y : exprℝ()}
(hy : «expr < »(0, y)) : tendsto (λ x : «exprℝ≥0∞»(), «expr ^ »(x, y)) (expr𝓝() «expr⊤»()) (expr𝓝() «expr⊤»()) :=
begin
  rw [expr tendsto_nhds_top_iff_nnreal] [],
  intros [ident x],
  obtain ["⟨", ident c, ",", "_", ",", ident hc, "⟩", ":=", expr (at_top_basis_Ioi.tendsto_iff at_top_basis_Ioi).mp (nnreal.tendsto_rpow_at_top hy) x trivial],
  have [ident hc'] [":", expr «expr ∈ »(set.Ioi «expr↑ »(c), expr𝓝() («expr⊤»() : «exprℝ≥0∞»()))] [":=", expr Ioi_mem_nhds coe_lt_top],
  refine [expr eventually_of_mem hc' _],
  intros [ident a, ident ha],
  by_cases [expr ha', ":", expr «expr = »(a, «expr⊤»())],
  { simp [] [] [] ["[", expr ha', ",", expr hy, "]"] [] [] },
  lift [expr a] ["to", expr «exprℝ≥0»()] ["using", expr ha'] [],
  change [expr «expr < »(«expr↑ »(c), «expr↑ »(a))] [] ["at", ident ha],
  rw [expr coe_rpow_of_nonneg _ hy.le] [],
  exact_mod_cast [expr hc a (by exact_mod_cast [expr ha])]
end

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
private
theorem continuous_at_rpow_const_of_pos
{x : «exprℝ≥0∞»()}
{y : exprℝ()}
(h : «expr < »(0, y)) : continuous_at (λ a : ennreal, «expr ^ »(a, y)) x :=
begin
  by_cases [expr hx, ":", expr «expr = »(x, «expr⊤»())],
  { rw ["[", expr hx, ",", expr continuous_at, "]"] [],
    convert [] [expr tendsto_rpow_at_top h] [],
    simp [] [] [] ["[", expr h, "]"] [] [] },
  lift [expr x] ["to", expr «exprℝ≥0»()] ["using", expr hx] [],
  rw [expr continuous_at_coe_iff] [],
  convert [] [expr continuous_coe.continuous_at.comp (nnreal.continuous_at_rpow_const (or.inr h.le))] ["using", 1],
  ext1 [] [ident x],
  simp [] [] [] ["[", expr coe_rpow_of_nonneg _ h.le, "]"] [] []
end

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[continuity #[]] theorem continuous_rpow_const {y : exprℝ()} : continuous (λ a : ennreal, «expr ^ »(a, y)) :=
begin
  apply [expr continuous_iff_continuous_at.2 (λ x, _)],
  rcases [expr lt_trichotomy 0 y, "with", ident hy, "|", ident rfl, "|", ident hy],
  { exact [expr continuous_at_rpow_const_of_pos hy] },
  { simp [] [] [] [] [] [],
    exact [expr continuous_at_const] },
  { obtain ["⟨", ident z, ",", ident hz, "⟩", ":", expr «expr∃ , »((z), «expr = »(y, «expr- »(z))), ":=", expr ⟨«expr- »(y), (neg_neg _).symm⟩],
    have [ident z_pos] [":", expr «expr < »(0, z)] [],
    by simpa [] [] [] ["[", expr hz, "]"] [] ["using", expr hy],
    simp_rw ["[", expr hz, ",", expr rpow_neg, "]"] [],
    exact [expr ennreal.continuous_inv.continuous_at.comp (continuous_at_rpow_const_of_pos z_pos)] }
end

-- error in Analysis.SpecialFunctions.Pow: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem tendsto_const_mul_rpow_nhds_zero_of_pos
{c : «exprℝ≥0∞»()}
(hc : «expr ≠ »(c, «expr∞»()))
{y : exprℝ()}
(hy : «expr < »(0, y)) : tendsto (λ x : «exprℝ≥0∞»(), «expr * »(c, «expr ^ »(x, y))) (expr𝓝() 0) (expr𝓝() 0) :=
begin
  convert [] [expr ennreal.tendsto.const_mul (ennreal.continuous_rpow_const.tendsto 0) _] [],
  { simp [] [] [] ["[", expr hy, "]"] [] [] },
  { exact [expr or.inr hc] }
end

end Ennreal

