/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Robert Y. Lewis

! This file was ported from Lean 3 source module ring_theory.witt_vector.witt_polynomial
! leanprover-community/mathlib commit f7fc89d5d5ff1db2d1242c7bb0e9062ce47ef47c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.CharP.Invertible
import Mathbin.Data.Fintype.BigOperators
import Mathbin.Data.MvPolynomial.Variables
import Mathbin.Data.MvPolynomial.CommRing
import Mathbin.Data.MvPolynomial.Expand
import Mathbin.Data.Zmod.Basic

/-!
# Witt polynomials

To endow `witt_vector p R` with a ring structure,
we need to study the so-called Witt polynomials.

Fix a base value `p : ℕ`.
The `p`-adic Witt polynomials are an infinite family of polynomials
indexed by a natural number `n`, taking values in an arbitrary ring `R`.
The variables of these polynomials are represented by natural numbers.
The variable set of the `n`th Witt polynomial contains at most `n+1` elements `{0, ..., n}`,
with exactly these variables when `R` has characteristic `0`.

These polynomials are used to define the addition and multiplication operators
on the type of Witt vectors. (While this type itself is not complicated,
the ring operations are what make it interesting.)

When the base `p` is invertible in `R`, the `p`-adic Witt polynomials
form a basis for `mv_polynomial ℕ R`, equivalent to the standard basis.

## Main declarations

* `witt_polynomial p R n`: the `n`-th Witt polynomial, viewed as polynomial over the ring `R`
* `X_in_terms_of_W p R n`: if `p` is invertible, the polynomial `X n` is contained in the subalgebra
  generated by the Witt polynomials. `X_in_terms_of_W p R n` is the explicit polynomial,
  which upon being bound to the Witt polynomials yields `X n`.
* `bind₁_witt_polynomial_X_in_terms_of_W`: the proof of the claim that
  `bind₁ (X_in_terms_of_W p R) (W_ R n) = X n`
* `bind₁_X_in_terms_of_W_witt_polynomial`: the converse of the above statement

## Notation

In this file we use the following notation

* `p` is a natural number, typically assumed to be prime.
* `R` and `S` are commutative rings
* `W n` (and `W_ R n` when the ring needs to be explicit) denotes the `n`th Witt polynomial

## References

* [Hazewinkel, *Witt Vectors*][Haze09]

* [Commelin and Lewis, *Formalizing the Ring of Witt Vectors*][CL21]
-/


open MvPolynomial

open Finset hiding map

open Finsupp (single)

open BigOperators

attribute [-simp] coe_eval₂_hom

variable (p : ℕ)

variable (R : Type _) [CommRing R]

/-- `witt_polynomial p R n` is the `n`-th Witt polynomial
with respect to a prime `p` with coefficients in a commutative ring `R`.
It is defined as:

`∑_{i ≤ n} p^i X_i^{p^{n-i}} ∈ R[X_0, X_1, X_2, …]`. -/
noncomputable def wittPolynomial (n : ℕ) : MvPolynomial ℕ R :=
  ∑ i in range (n + 1), monomial (single i (p ^ (n - i))) (p ^ i : R)
#align witt_polynomial wittPolynomial

theorem wittPolynomial_eq_sum_c_mul_x_pow (n : ℕ) :
    wittPolynomial p R n = ∑ i in range (n + 1), c (p ^ i : R) * x i ^ p ^ (n - i) :=
  by
  apply sum_congr rfl
  rintro i -
  rw [monomial_eq, Finsupp.prod_single_index]
  rw [pow_zero]
#align witt_polynomial_eq_sum_C_mul_X_pow wittPolynomial_eq_sum_c_mul_x_pow

/-! We set up notation locally to this file, to keep statements short and comprehensible.
This allows us to simply write `W n` or `W_ ℤ n`. -/


-- mathport name: witt_polynomial
-- Notation with ring of coefficients explicit
scoped[Witt] notation "W_" => wittPolynomial p

-- mathport name: witt_polynomial.infer
-- Notation with ring of coefficients implicit
scoped[Witt] notation "W" => wittPolynomial p hole!

open Witt

open MvPolynomial

/- The first observation is that the Witt polynomial doesn't really depend on the coefficient ring.
If we map the coefficients through a ring homomorphism, we obtain the corresponding Witt polynomial
over the target ring. -/
section

variable {R} {S : Type _} [CommRing S]

@[simp]
theorem map_wittPolynomial (f : R →+* S) (n : ℕ) : map f (W n) = W n :=
  by
  rw [wittPolynomial, RingHom.map_sum, wittPolynomial, sum_congr rfl]
  intro i hi
  rw [map_monomial, RingHom.map_pow, map_natCast]
#align map_witt_polynomial map_wittPolynomial

variable (R)

@[simp]
theorem constantCoeff_wittPolynomial [hp : Fact p.Prime] (n : ℕ) :
    constantCoeff (wittPolynomial p R n) = 0 :=
  by
  simp only [wittPolynomial, RingHom.map_sum, constant_coeff_monomial]
  rw [sum_eq_zero]
  rintro i hi
  rw [if_neg]
  rw [Finsupp.single_eq_zero]
  exact ne_of_gt (pow_pos hp.1.Pos _)
#align constant_coeff_witt_polynomial constantCoeff_wittPolynomial

@[simp]
theorem wittPolynomial_zero : wittPolynomial p R 0 = x 0 := by
  simp only [wittPolynomial, X, sum_singleton, range_one, pow_zero]
#align witt_polynomial_zero wittPolynomial_zero

@[simp]
theorem wittPolynomial_one : wittPolynomial p R 1 = c ↑p * x 1 + x 0 ^ p := by
  simp only [wittPolynomial_eq_sum_c_mul_x_pow, sum_range_succ_comm, range_one, sum_singleton,
    one_mul, pow_one, C_1, pow_zero]
#align witt_polynomial_one wittPolynomial_one

theorem aeval_wittPolynomial {A : Type _} [CommRing A] [Algebra R A] (f : ℕ → A) (n : ℕ) :
    aeval f (W_ R n) = ∑ i in range (n + 1), p ^ i * f i ^ p ^ (n - i) := by
  simp [wittPolynomial, AlgHom.map_sum, aeval_monomial, Finsupp.prod_single_index]
#align aeval_witt_polynomial aeval_wittPolynomial

/-- Over the ring `zmod (p^(n+1))`, we produce the `n+1`st Witt polynomial
by expanding the `n`th Witt polynomial by `p`.
-/
@[simp]
theorem wittPolynomial_zMod_self (n : ℕ) :
    W_ (ZMod (p ^ (n + 1))) (n + 1) = expand p (W_ (ZMod (p ^ (n + 1))) n) :=
  by
  simp only [wittPolynomial_eq_sum_c_mul_x_pow]
  rw [sum_range_succ, ← Nat.cast_pow, CharP.cast_eq_zero (ZMod (p ^ (n + 1))) (p ^ (n + 1)), C_0,
    zero_mul, add_zero, AlgHom.map_sum, sum_congr rfl]
  intro k hk
  rw [AlgHom.map_mul, AlgHom.map_pow, expand_X, alg_hom_C, ← pow_mul, ← pow_succ]
  congr
  rw [mem_range] at hk
  rw [add_comm, add_tsub_assoc_of_le (nat.lt_succ_iff.mp hk), ← add_comm]
#align witt_polynomial_zmod_self wittPolynomial_zMod_self

section PPrime

variable [hp : NeZero p]

include hp

theorem wittPolynomial_vars [CharZero R] (n : ℕ) : (wittPolynomial p R n).vars = range (n + 1) :=
  by
  have : ∀ i, (monomial (Finsupp.single i (p ^ (n - i))) (p ^ i : R)).vars = {i} :=
    by
    intro i
    refine' vars_monomial_single i (pow_ne_zero _ hp.1) _
    rw [← Nat.cast_pow, Nat.cast_ne_zero]
    exact pow_ne_zero i hp.1
  rw [wittPolynomial, vars_sum_of_disjoint]
  · simp only [this, bUnion_singleton_eq_self]
  · simp only [this]
    intro a b h
    apply disjoint_singleton_left.mpr
    rwa [mem_singleton]
#align witt_polynomial_vars wittPolynomial_vars

theorem wittPolynomial_vars_subset (n : ℕ) : (wittPolynomial p R n).vars ⊆ range (n + 1) :=
  by
  rw [← map_wittPolynomial p (Int.castRingHom R), ← wittPolynomial_vars p ℤ]
  apply vars_map
#align witt_polynomial_vars_subset wittPolynomial_vars_subset

end PPrime

end

/-!

## Witt polynomials as a basis of the polynomial algebra

If `p` is invertible in `R`, then the Witt polynomials form a basis
of the polynomial algebra `mv_polynomial ℕ R`.
The polynomials `X_in_terms_of_W` give the coordinate transformation in the backwards direction.
-/


/-- The `X_in_terms_of_W p R n` is the polynomial on the basis of Witt polynomials
that corresponds to the ordinary `X n`. -/
noncomputable def xInTermsOfW [Invertible (p : R)] : ℕ → MvPolynomial ℕ R
  | n =>
    (x n -
        ∑ i : Fin n,
          have := i.2
          c (p ^ (i : ℕ) : R) * xInTermsOfW i ^ p ^ (n - i)) *
      c (⅟ p ^ n : R)
#align X_in_terms_of_W xInTermsOfW

theorem xInTermsOfW_eq [Invertible (p : R)] {n : ℕ} :
    xInTermsOfW p R n =
      (x n - ∑ i in range n, c (p ^ i : R) * xInTermsOfW p R i ^ p ^ (n - i)) * c (⅟ p ^ n : R) :=
  by rw [xInTermsOfW, ← Fin.sum_univ_eq_sum_range]
#align X_in_terms_of_W_eq xInTermsOfW_eq

@[simp]
theorem constantCoeff_xInTermsOfW [hp : Fact p.Prime] [Invertible (p : R)] (n : ℕ) :
    constantCoeff (xInTermsOfW p R n) = 0 :=
  by
  apply Nat.strong_induction_on n <;> clear n
  intro n IH
  rw [xInTermsOfW_eq, mul_comm, RingHom.map_mul, RingHom.map_sub, RingHom.map_sum, constant_coeff_C,
    sum_eq_zero]
  · simp only [constant_coeff_X, sub_zero, mul_zero]
  · intro m H
    rw [mem_range] at H
    simp only [RingHom.map_mul, RingHom.map_pow, constant_coeff_C, IH m H]
    rw [zero_pow, mul_zero]
    apply pow_pos hp.1.Pos
#align constant_coeff_X_in_terms_of_W constantCoeff_xInTermsOfW

@[simp]
theorem xInTermsOfW_zero [Invertible (p : R)] : xInTermsOfW p R 0 = x 0 := by
  rw [xInTermsOfW_eq, range_zero, sum_empty, pow_zero, C_1, mul_one, sub_zero]
#align X_in_terms_of_W_zero xInTermsOfW_zero

section PPrime

variable [hp : Fact p.Prime]

include hp

theorem xInTermsOfW_vars_aux (n : ℕ) :
    n ∈ (xInTermsOfW p ℚ n).vars ∧ (xInTermsOfW p ℚ n).vars ⊆ range (n + 1) :=
  by
  apply Nat.strong_induction_on n; clear n
  intro n ih
  rw [xInTermsOfW_eq, mul_comm, vars_C_mul, vars_sub_of_disjoint, vars_X, range_succ, insert_eq]
  pick_goal 3; · apply nonzero_of_invertible
  on_goal
    1 =>
    simp only [true_and_iff, true_or_iff, eq_self_iff_true, mem_union, mem_singleton]
    intro i
    rw [mem_union, mem_union]
    apply Or.imp id
  on_goal 2 => rw [vars_X, disjoint_singleton_left]
  all_goals
    intro H
    replace H := vars_sum_subset _ _ H
    rw [mem_bUnion] at H
    rcases H with ⟨j, hj, H⟩
    rw [vars_C_mul] at H
    swap
    · apply pow_ne_zero
      exact_mod_cast hp.1.NeZero
    rw [mem_range] at hj
    replace H := (ih j hj).2 (vars_pow _ _ H)
    rw [mem_range] at H
  · rw [mem_range]
    exact lt_of_lt_of_le H hj
  · exact lt_irrefl n (lt_of_lt_of_le H hj)
#align X_in_terms_of_W_vars_aux xInTermsOfW_vars_aux

theorem xInTermsOfW_vars_subset (n : ℕ) : (xInTermsOfW p ℚ n).vars ⊆ range (n + 1) :=
  (xInTermsOfW_vars_aux p n).2
#align X_in_terms_of_W_vars_subset xInTermsOfW_vars_subset

end PPrime

theorem xInTermsOfW_aux [Invertible (p : R)] (n : ℕ) :
    xInTermsOfW p R n * c (p ^ n : R) =
      x n - ∑ i in range n, c (p ^ i : R) * xInTermsOfW p R i ^ p ^ (n - i) :=
  by rw [xInTermsOfW_eq, mul_assoc, ← C_mul, ← mul_pow, invOf_mul_self, one_pow, C_1, mul_one]
#align X_in_terms_of_W_aux xInTermsOfW_aux

@[simp]
theorem bind₁_xInTermsOfW_wittPolynomial [Invertible (p : R)] (k : ℕ) :
    bind₁ (xInTermsOfW p R) (W_ R k) = x k :=
  by
  rw [wittPolynomial_eq_sum_c_mul_x_pow, AlgHom.map_sum]
  simp only [AlgHom.map_pow, C_pow, AlgHom.map_mul, alg_hom_C]
  rw [sum_range_succ_comm, tsub_self, pow_zero, pow_one, bind₁_X_right, mul_comm, ← C_pow,
    xInTermsOfW_aux]
  simp only [C_pow, bind₁_X_right, sub_add_cancel]
#align bind₁_X_in_terms_of_W_witt_polynomial bind₁_xInTermsOfW_wittPolynomial

@[simp]
theorem bind₁_wittPolynomial_xInTermsOfW [Invertible (p : R)] (n : ℕ) :
    bind₁ (W_ R) (xInTermsOfW p R n) = x n :=
  by
  apply Nat.strong_induction_on n
  clear n
  intro n H
  rw [xInTermsOfW_eq, AlgHom.map_mul, AlgHom.map_sub, bind₁_X_right, alg_hom_C, AlgHom.map_sum]
  have : (W_ R n - ∑ i in range n, C (p ^ i : R) * X i ^ p ^ (n - i)) = C (p ^ n : R) * X n := by
    simp only [wittPolynomial_eq_sum_c_mul_x_pow, tsub_self, sum_range_succ_comm, pow_one,
      add_sub_cancel, pow_zero]
  rw [sum_congr rfl, this]
  ·-- this is really slow for some reason
    rw [mul_right_comm, ← C_mul, ← mul_pow, mul_invOf_self, one_pow, C_1, one_mul]
  · intro i h
    rw [mem_range] at h
    simp only [AlgHom.map_mul, AlgHom.map_pow, alg_hom_C, H i h]
#align bind₁_witt_polynomial_X_in_terms_of_W bind₁_wittPolynomial_xInTermsOfW

