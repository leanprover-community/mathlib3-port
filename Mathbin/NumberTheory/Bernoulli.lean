/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Kevin Buzzard

! This file was ported from Lean 3 source module number_theory.bernoulli
! leanprover-community/mathlib commit d101e93197bb5f6ea89bd7ba386b7f7dff1f3903
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.BigOperators.NatAntidiagonal
import Mathbin.Algebra.GeomSum
import Mathbin.Data.Fintype.BigOperators
import Mathbin.RingTheory.PowerSeries.WellKnown
import Mathbin.Tactic.FieldSimp

/-!
# Bernoulli numbers

The Bernoulli numbers are a sequence of rational numbers that frequently show up in
number theory.

## Mathematical overview

The Bernoulli numbers $(B_0, B_1, B_2, \ldots)=(1, -1/2, 1/6, 0, -1/30, \ldots)$ are
a sequence of rational numbers. They show up in the formula for the sums of $k$th
powers. They are related to the Taylor series expansions of $x/\tan(x)$ and
of $\coth(x)$, and also show up in the values that the Riemann Zeta function
takes both at both negative and positive integers (and hence in the
theory of modular forms). For example, if $1 \leq n$ is even then

$$\zeta(2n)=\sum_{t\geq1}t^{-2n}=(-1)^{n+1}\frac{(2\pi)^{2n}B_{2n}}{2(2n)!}.$$

Note however that this result is not yet formalised in Lean.

The Bernoulli numbers can be formally defined using the power series

$$\sum B_n\frac{t^n}{n!}=\frac{t}{1-e^{-t}}$$

although that happens to not be the definition in mathlib (this is an *implementation
detail* and need not concern the mathematician).

Note that $B_1=-1/2$, meaning that we are using the $B_n^-$ of
[from Wikipedia](https://en.wikipedia.org/wiki/Bernoulli_number).

## Implementation detail

The Bernoulli numbers are defined using well-founded induction, by the formula
$$B_n=1-\sum_{k\lt n}\frac{\binom{n}{k}}{n-k+1}B_k.$$
This formula is true for all $n$ and in particular $B_0=1$. Note that this is the definition
for positive Bernoulli numbers, which we call `bernoulli'`. The negative Bernoulli numbers are
then defined as `bernoulli := (-1)^n * bernoulli'`.

## Main theorems

`sum_bernoulli : ∑ k in finset.range n, (n.choose k : ℚ) * bernoulli k = 0`
-/


open Nat BigOperators

open Finset Nat Finset.Nat PowerSeries

variable (A : Type _) [CommRing A] [Algebra ℚ A]

/-! ### Definitions -/


/-- The Bernoulli numbers:
the $n$-th Bernoulli number $B_n$ is defined recursively via
$$B_n = 1 - \sum_{k < n} \binom{n}{k}\frac{B_k}{n+1-k}$$ -/
def bernoulli' : ℕ → ℚ :=
  WellFounded.fix lt_wfRel fun n bernoulli' =>
    1 - ∑ k : Fin n, n.choose k / (n - k + 1) * bernoulli' k k.2
#align bernoulli' bernoulli'

theorem bernoulli'_def' (n : ℕ) :
    bernoulli' n = 1 - ∑ k : Fin n, n.choose k / (n - k + 1) * bernoulli' k :=
  WellFounded.fix_eq _ _ _
#align bernoulli'_def' bernoulli'_def'

theorem bernoulli'_def (n : ℕ) :
    bernoulli' n = 1 - ∑ k in range n, n.choose k / (n - k + 1) * bernoulli' k :=
  by
  rw [bernoulli'_def', ← Fin.sum_univ_eq_sum_range]
  rfl
#align bernoulli'_def bernoulli'_def

theorem bernoulli'_spec (n : ℕ) :
    (∑ k in range n.succ, (n.choose (n - k) : ℚ) / (n - k + 1) * bernoulli' k) = 1 :=
  by
  rw [sum_range_succ_comm, bernoulli'_def n, tsub_self]
  conv in n.choose (_ - _) => rw [choose_symm (mem_range.1 H).le]
  simp only [one_mul, cast_one, sub_self, sub_add_cancel, choose_zero_right, zero_add, div_one]
#align bernoulli'_spec bernoulli'_spec

theorem bernoulli'_spec' (n : ℕ) :
    (∑ k in antidiagonal n, ((k.1 + k.2).choose k.2 : ℚ) / (k.2 + 1) * bernoulli' k.1) = 1 :=
  by
  refine' ((sum_antidiagonal_eq_sum_range_succ_mk _ n).trans _).trans (bernoulli'_spec n)
  refine' sum_congr rfl fun x hx => _
  simp only [add_tsub_cancel_of_le, mem_range_succ_iff.mp hx, cast_sub]
#align bernoulli'_spec' bernoulli'_spec'

/-! ### Examples -/


section Examples

@[simp]
theorem bernoulli'_zero : bernoulli' 0 = 1 :=
  by
  rw [bernoulli'_def]
  norm_num
#align bernoulli'_zero bernoulli'_zero

@[simp]
theorem bernoulli'_one : bernoulli' 1 = 1 / 2 :=
  by
  rw [bernoulli'_def]
  norm_num
#align bernoulli'_one bernoulli'_one

@[simp]
theorem bernoulli'_two : bernoulli' 2 = 1 / 6 :=
  by
  rw [bernoulli'_def]
  norm_num [sum_range_succ]
#align bernoulli'_two bernoulli'_two

@[simp]
theorem bernoulli'_three : bernoulli' 3 = 0 :=
  by
  rw [bernoulli'_def]
  norm_num [sum_range_succ]
#align bernoulli'_three bernoulli'_three

@[simp]
theorem bernoulli'_four : bernoulli' 4 = -1 / 30 :=
  by
  have : Nat.choose 4 2 = 6 := by decide
  -- shrug
  rw [bernoulli'_def]
  norm_num [sum_range_succ, this]
#align bernoulli'_four bernoulli'_four

end Examples

@[simp]
theorem sum_bernoulli' (n : ℕ) : (∑ k in range n, (n.choose k : ℚ) * bernoulli' k) = n :=
  by
  cases n
  · simp
  suffices
    ((n + 1 : ℚ) * ∑ k in range n, ↑(n.choose k) / (n - k + 1) * bernoulli' k) =
      ∑ x in range n, ↑(n.succ.choose x) * bernoulli' x
    by
    rw_mod_cast [sum_range_succ, bernoulli'_def, ← this, choose_succ_self_right]
    ring
  simp_rw [mul_sum, ← mul_assoc]
  refine' sum_congr rfl fun k hk => _
  congr
  have : ((n - k : ℕ) : ℚ) + 1 ≠ 0 := by apply_mod_cast succ_ne_zero
  field_simp [← cast_sub (mem_range.1 hk).le, mul_comm]
  rw_mod_cast [tsub_add_eq_add_tsub (mem_range.1 hk).le, choose_mul_succ_eq]
#align sum_bernoulli' sum_bernoulli'

/-- The exponential generating function for the Bernoulli numbers `bernoulli' n`. -/
def bernoulli'PowerSeries :=
  mk fun n => algebraMap ℚ A (bernoulli' n / n !)
#align bernoulli'_power_series bernoulli'PowerSeries

theorem bernoulli'PowerSeries_mul_exp_sub_one : bernoulli'PowerSeries A * (exp A - 1) = x * exp A :=
  by
  ext n
  -- constant coefficient is a special case
  cases n
  · simp
  rw [bernoulli'PowerSeries, coeff_mul, mul_comm X, sum_antidiagonal_succ']
  suffices (∑ p in antidiagonal n, bernoulli' p.1 / p.1! * ((p.2 + 1) * p.2!)⁻¹) = n !⁻¹ by
    simpa [RingHom.map_sum] using congr_arg (algebraMap ℚ A) this
  apply eq_inv_of_mul_eq_one_left
  rw [sum_mul]
  convert bernoulli'_spec' n using 1
  apply sum_congr rfl
  simp_rw [mem_antidiagonal]
  rintro ⟨i, j⟩ rfl
  have : (j + 1 : ℚ) ≠ 0 := by exact_mod_cast succ_ne_zero j
  have : (j + 1 : ℚ) * j ! * i ! ≠ 0 := by simpa [factorial_ne_zero]
  have := factorial_mul_factorial_dvd_factorial_add i j
  field_simp [mul_comm _ (bernoulli' i), mul_assoc, add_choose]
  rw_mod_cast [mul_comm (j + 1), mul_div_assoc, ← mul_assoc]
  rw [cast_mul, cast_mul, mul_div_mul_right, cast_div_char_zero, cast_mul]
  assumption
  rwa [Nat.cast_succ]
#align bernoulli'_power_series_mul_exp_sub_one bernoulli'PowerSeries_mul_exp_sub_one

/-- Odd Bernoulli numbers (greater than 1) are zero. -/
theorem bernoulli'_odd_eq_zero {n : ℕ} (h_odd : Odd n) (hlt : 1 < n) : bernoulli' n = 0 :=
  by
  let B := mk fun n => bernoulli' n / n !
  suffices (B - eval_neg_hom B) * (exp ℚ - 1) = X * (exp ℚ - 1)
    by
    cases mul_eq_mul_right_iff.mp this <;>
      simp only [PowerSeries.ext_iff, eval_neg_hom, coeff_X] at h
    · apply eq_zero_of_neg_eq
      specialize h n
      split_ifs  at h <;> simp_all [h_odd.neg_one_pow, factorial_ne_zero]
    · simpa using h 1
  have h : B * (exp ℚ - 1) = X * exp ℚ := by
    simpa [bernoulli'PowerSeries] using bernoulli'PowerSeries_mul_exp_sub_one ℚ
  rw [sub_mul, h, mul_sub X, sub_right_inj, ← neg_sub, mul_neg, neg_eq_iff_neg_eq]
  suffices eval_neg_hom (B * (exp ℚ - 1)) * exp ℚ = eval_neg_hom (X * exp ℚ) * exp ℚ by
    simpa [mul_assoc, sub_mul, mul_comm (eval_neg_hom (exp ℚ)), exp_mul_exp_neg_eq_one, eq_comm]
  congr
#align bernoulli'_odd_eq_zero bernoulli'_odd_eq_zero

/-- The Bernoulli numbers are defined to be `bernoulli'` with a parity sign. -/
def bernoulli (n : ℕ) : ℚ :=
  (-1) ^ n * bernoulli' n
#align bernoulli bernoulli

theorem bernoulli'_eq_bernoulli (n : ℕ) : bernoulli' n = (-1) ^ n * bernoulli n := by
  simp [bernoulli, ← mul_assoc, ← sq, ← pow_mul, mul_comm n 2, pow_mul]
#align bernoulli'_eq_bernoulli bernoulli'_eq_bernoulli

@[simp]
theorem bernoulli_zero : bernoulli 0 = 1 := by simp [bernoulli]
#align bernoulli_zero bernoulli_zero

@[simp]
theorem bernoulli_one : bernoulli 1 = -1 / 2 := by norm_num [bernoulli]
#align bernoulli_one bernoulli_one

theorem bernoulli_eq_bernoulli'_of_ne_one {n : ℕ} (hn : n ≠ 1) : bernoulli n = bernoulli' n :=
  by
  by_cases h0 : n = 0; · simp [h0]
  rw [bernoulli, neg_one_pow_eq_pow_mod_two]
  cases mod_two_eq_zero_or_one n; · simp [h]
  simp [bernoulli'_odd_eq_zero (odd_iff.mpr h) (one_lt_iff_ne_zero_and_ne_one.mpr ⟨h0, hn⟩)]
#align bernoulli_eq_bernoulli'_of_ne_one bernoulli_eq_bernoulli'_of_ne_one

@[simp]
theorem sum_bernoulli (n : ℕ) :
    (∑ k in range n, (n.choose k : ℚ) * bernoulli k) = if n = 1 then 1 else 0 :=
  by
  cases n
  · simp
  cases n
  · simp
  suffices (∑ i in range n, ↑((n + 2).choose (i + 2)) * bernoulli (i + 2)) = n / 2
    by
    simp only [this, sum_range_succ', cast_succ, bernoulli_one, bernoulli_zero, choose_one_right,
      mul_one, choose_zero_right, cast_zero, if_false, zero_add, succ_succ_ne_one]
    ring
  have f := sum_bernoulli' n.succ.succ
  simp_rw [sum_range_succ', bernoulli'_one, choose_one_right, cast_succ, ← eq_sub_iff_add_eq] at f
  convert f
  · funext x
    rw [bernoulli_eq_bernoulli'_of_ne_one (succ_ne_zero x ∘ succ.inj)]
  · simp only [one_div, mul_one, bernoulli'_zero, cast_one, choose_zero_right, add_sub_cancel]
    ring
#align sum_bernoulli sum_bernoulli

theorem bernoulli_spec' (n : ℕ) :
    (∑ k in antidiagonal n, ((k.1 + k.2).choose k.2 : ℚ) / (k.2 + 1) * bernoulli k.1) =
      if n = 0 then 1 else 0 :=
  by
  cases n; · simp
  rw [if_neg (succ_ne_zero _)]
  -- algebra facts
  have h₁ : (1, n) ∈ antidiagonal n.succ := by simp [mem_antidiagonal, add_comm]
  have h₂ : (n : ℚ) + 1 ≠ 0 := by apply_mod_cast succ_ne_zero
  have h₃ : (1 + n).choose n = n + 1 := by simp [add_comm]
  -- key equation: the corresponding fact for `bernoulli'`
  have H := bernoulli'_spec' n.succ
  -- massage it to match the structure of the goal, then convert piece by piece
  rw [sum_eq_add_sum_diff_singleton h₁] at H⊢
  apply add_eq_of_eq_sub'
  convert eq_sub_of_add_eq' H using 1
  · refine' sum_congr rfl fun p h => _
    obtain ⟨h', h''⟩ : p ∈ _ ∧ p ≠ _ := by rwa [mem_sdiff, mem_singleton] at h
    simp [bernoulli_eq_bernoulli'_of_ne_one ((not_congr (antidiagonal_congr h' h₁)).mp h'')]
  · field_simp [h₃]
    norm_num
#align bernoulli_spec' bernoulli_spec'

/-- The exponential generating function for the Bernoulli numbers `bernoulli n`. -/
def bernoulliPowerSeries :=
  mk fun n => algebraMap ℚ A (bernoulli n / n !)
#align bernoulli_power_series bernoulliPowerSeries

theorem bernoulliPowerSeries_mul_exp_sub_one : bernoulliPowerSeries A * (exp A - 1) = x :=
  by
  ext n
  -- constant coefficient is a special case
  cases n;
  · simp
  simp only [bernoulliPowerSeries, coeff_mul, coeff_X, sum_antidiagonal_succ', one_div, coeff_mk,
    coeff_one, coeff_exp, LinearMap.map_sub, factorial, if_pos, cast_succ, cast_one, cast_mul,
    sub_zero, RingHom.map_one, add_eq_zero_iff, if_false, _root_.inv_one, zero_add, one_ne_zero,
    mul_zero, and_false_iff, sub_self, ← RingHom.map_mul, ← RingHom.map_sum]
  cases n; · simp
  rw [if_neg n.succ_succ_ne_one]
  have hfact : ∀ m, (m ! : ℚ) ≠ 0 := fun m => by exact_mod_cast factorial_ne_zero m
  have hite2 : ite (n.succ = 0) 1 0 = (0 : ℚ) := if_neg n.succ_ne_zero
  rw [← map_zero (algebraMap ℚ A), ← zero_div (n.succ ! : ℚ), ← hite2, ← bernoulli_spec', sum_div]
  refine' congr_arg (algebraMap ℚ A) (sum_congr rfl fun x h => eq_div_of_mul_eq (hfact n.succ) _)
  rw [mem_antidiagonal] at h
  have hj : (x.2 + 1 : ℚ) ≠ 0 := by exact_mod_cast succ_ne_zero _
  field_simp [← h, mul_ne_zero hj (hfact x.2), hfact x.1, mul_comm _ (bernoulli x.1), mul_assoc,
    add_choose, cast_div_char_zero (factorial_mul_factorial_dvd_factorial_add _ _),
    Nat.factorial_ne_zero, hj]
  cc
#align bernoulli_power_series_mul_exp_sub_one bernoulliPowerSeries_mul_exp_sub_one

section Faulhaber

/-- **Faulhaber's theorem** relating the **sum of of p-th powers** to the Bernoulli numbers:
$$\sum_{k=0}^{n-1} k^p = \sum_{i=0}^p B_i\binom{p+1}{i}\frac{n^{p+1-i}}{p+1}.$$
See https://proofwiki.org/wiki/Faulhaber%27s_Formula and [orosi2018faulhaber] for
the proof provided here. -/
theorem sum_range_pow (n p : ℕ) :
    (∑ k in range n, (k : ℚ) ^ p) =
      ∑ i in range (p + 1), bernoulli i * (p + 1).choose i * n ^ (p + 1 - i) / (p + 1) :=
  by
  have hne : ∀ m : ℕ, (m ! : ℚ) ≠ 0 := fun m => by exact_mod_cast factorial_ne_zero m
  -- compute the Cauchy product of two power series
  have h_cauchy :
    ((mk fun p => bernoulli p / p !) * mk fun q => coeff ℚ (q + 1) (exp ℚ ^ n)) =
      mk fun p =>
        ∑ i in range (p + 1), bernoulli i * (p + 1).choose i * n ^ (p + 1 - i) / (p + 1)! :=
    by
    ext q : 1
    let f a b := bernoulli a / a ! * coeff ℚ (b + 1) (exp ℚ ^ n)
    -- key step: use `power_series.coeff_mul` and then rewrite sums
    simp only [coeff_mul, coeff_mk, cast_mul, sum_antidiagonal_eq_sum_range_succ f]
    apply sum_congr rfl
    simp_intro m h only [Finset.mem_range]
    simp only [f, exp_pow_eq_rescale_exp, rescale, one_div, coeff_mk, RingHom.coe_mk, coeff_exp,
      RingHom.id_apply, cast_mul, algebraMap_rat_rat]
    -- manipulate factorials and binomial coefficients
    rw [choose_eq_factorial_div_factorial h.le, eq_comm, div_eq_iff (hne q.succ), succ_eq_add_one,
      mul_assoc _ _ ↑q.succ !, mul_comm _ ↑q.succ !, ← mul_assoc, div_mul_eq_mul_div,
      mul_comm (↑n ^ (q - m + 1)), ← mul_assoc _ _ (↑n ^ (q - m + 1)), ← one_div, mul_one_div,
      div_div, tsub_add_eq_add_tsub (le_of_lt_succ h), cast_div, cast_mul]
    · ring
    · exact factorial_mul_factorial_dvd_factorial h.le
    · simp [hne]
  -- same as our goal except we pull out `p!` for convenience
  have hps :
    (∑ k in range n, ↑k ^ p) =
      (∑ i in range (p + 1), bernoulli i * (p + 1).choose i * n ^ (p + 1 - i) / (p + 1)!) * p ! :=
    by
    suffices
      (mk fun p => ∑ k in range n, ↑k ^ p * algebraMap ℚ ℚ p !⁻¹) =
        mk fun p =>
          ∑ i in range (p + 1), bernoulli i * (p + 1).choose i * n ^ (p + 1 - i) / (p + 1)!
      by
      rw [← div_eq_iff (hne p), div_eq_mul_inv, sum_mul]
      rw [PowerSeries.ext_iff] at this
      simpa using this p
    -- the power series `exp ℚ - 1` is non-zero, a fact we need in order to use `mul_right_inj'`
    have hexp : exp ℚ - 1 ≠ 0 :=
      by
      simp only [exp, PowerSeries.ext_iff, Ne, not_forall]
      use 1
      simp
    have h_r : exp ℚ ^ n - 1 = X * mk fun p => coeff ℚ (p + 1) (exp ℚ ^ n) :=
      by
      have h_const : C ℚ (constant_coeff ℚ (exp ℚ ^ n)) = 1 := by simp
      rw [← h_const, sub_const_eq_X_mul_shift]
    -- key step: a chain of equalities of power series
    rw [← mul_right_inj' hexp, mul_comm, ← exp_pow_sum, geom_sum_mul, h_r, ←
      bernoulliPowerSeries_mul_exp_sub_one, bernoulliPowerSeries, mul_right_comm]
    simp [h_cauchy, mul_comm]
  -- massage `hps` into our goal
  rw [hps, sum_mul]
  refine' sum_congr rfl fun x hx => _
  field_simp [mul_right_comm _ ↑p !, ← mul_assoc _ _ ↑p !, cast_add_one_ne_zero, hne]
#align sum_range_pow sum_range_pow

/-- Alternate form of **Faulhaber's theorem**, relating the sum of p-th powers to the Bernoulli
numbers: $$\sum_{k=1}^{n} k^p = \sum_{i=0}^p (-1)^iB_i\binom{p+1}{i}\frac{n^{p+1-i}}{p+1}.$$
Deduced from `sum_range_pow`. -/
theorem sum_Ico_pow (n p : ℕ) :
    (∑ k in Ico 1 (n + 1), (k : ℚ) ^ p) =
      ∑ i in range (p + 1), bernoulli' i * (p + 1).choose i * n ^ (p + 1 - i) / (p + 1) :=
  by
  rw [← Nat.cast_succ]
  -- dispose of the trivial case
  cases p
  · simp
  let f i := bernoulli i * p.succ.succ.choose i * n ^ (p.succ.succ - i) / p.succ.succ
  let f' i := bernoulli' i * p.succ.succ.choose i * n ^ (p.succ.succ - i) / p.succ.succ
  suffices (∑ k in Ico 1 n.succ, ↑k ^ p.succ) = ∑ i in range p.succ.succ, f' i by convert this
  -- prove some algebraic facts that will make things easier for us later on
  have hle := Nat.le_add_left 1 n
  have hne : (p + 1 + 1 : ℚ) ≠ 0 := by exact_mod_cast succ_ne_zero p.succ
  have h1 : ∀ r : ℚ, r * (p + 1 + 1) * n ^ p.succ / (p + 1 + 1 : ℚ) = r * n ^ p.succ := fun r => by
    rw [mul_div_right_comm, mul_div_cancel _ hne]
  have h2 : f 1 + n ^ p.succ = 1 / 2 * n ^ p.succ :=
    by
    simp_rw [f, bernoulli_one, choose_one_right, succ_sub_succ_eq_sub, cast_succ, tsub_zero, h1]
    ring
  have :
    (∑ i in range p, bernoulli (i + 2) * (p + 2).choose (i + 2) * n ^ (p - i) / ↑(p + 2)) =
      ∑ i in range p, bernoulli' (i + 2) * (p + 2).choose (i + 2) * n ^ (p - i) / ↑(p + 2) :=
    sum_congr rfl fun i h => by rw [bernoulli_eq_bernoulli'_of_ne_one (succ_succ_ne_one i)]
  calc
    (-- replace sum over `Ico` with sum over `range` and simplify
        ∑ k in Ico 1 n.succ, ↑k ^ p.succ) =
        ∑ k in range n.succ, ↑k ^ p.succ :=
      by simp [sum_Ico_eq_sub _ hle, succ_ne_zero]
    -- extract the last term of the sum
        _ =
        (∑ k in range n, (k : ℚ) ^ p.succ) + n ^ p.succ :=
      by rw [sum_range_succ]
    -- apply the key lemma, `sum_range_pow`
        _ =
        (∑ i in range p.succ.succ, f i) + n ^ p.succ :=
      by simp [f, sum_range_pow]
    -- extract the first two terms of the sum
        _ =
        (∑ i in range p, f i.succ.succ) + f 1 + f 0 + n ^ p.succ :=
      by simp_rw [sum_range_succ']
    _ = (∑ i in range p, f i.succ.succ) + (f 1 + n ^ p.succ) + f 0 := by ring
    _ = (∑ i in range p, f i.succ.succ) + 1 / 2 * n ^ p.succ + f 0 := by rw [h2]
    -- convert from `bernoulli` to `bernoulli'`
        _ =
        (∑ i in range p, f' i.succ.succ) + f' 1 + f' 0 :=
      by
      simp only [f, f']
      simpa [h1, fun i => show i + 2 = i + 1 + 1 from rfl]
    -- rejoin the first two terms of the sum
        _ =
        ∑ i in range p.succ.succ, f' i :=
      by simp_rw [sum_range_succ']
    
#align sum_Ico_pow sum_Ico_pow

end Faulhaber

