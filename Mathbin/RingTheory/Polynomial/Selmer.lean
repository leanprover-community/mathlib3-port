/-
Copyright (c) 2022 Thomas Browning. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Thomas Browning

! This file was ported from Lean 3 source module ring_theory.polynomial.selmer
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Polynomial.UnitTrinomial
import Mathbin.RingTheory.Polynomial.GaussLemma
import Mathbin.Tactic.LinearCombination

/-!
# Irreducibility of Selmer Polynomials

This file proves irreducibility of the Selmer polynomials `X ^ n - X - 1`.

## Main results

- `polynomial.selmer_irreducible`: The Selmer polynomials `X ^ n - X - 1` are irreducible.

TODO: Show that the Selmer polynomials have full Galois group.
-/


namespace Polynomial

open Polynomial

variable {n : ℕ}

theorem X_pow_sub_X_sub_one_irreducible_aux (z : ℂ) : ¬(z ^ n = z + 1 ∧ z ^ n + z ^ 2 = 0) :=
  by
  rintro ⟨h1, h2⟩
  replace h3 : z ^ 3 = 1
  · linear_combination (1 - z - z ^ 2 - z ^ n) * h1 + (z ^ n - 2) * h2
  -- thanks polyrith!
  have key : z ^ n = 1 ∨ z ^ n = z ∨ z ^ n = z ^ 2 :=
    by
    rw [← Nat.mod_add_div n 3, pow_add, pow_mul, h3, one_pow, mul_one]
    have : n % 3 < 3 := Nat.mod_lt n zero_lt_three
    interval_cases n % 3 <;>
      simp only [h, pow_zero, pow_one, eq_self_iff_true, or_true_iff, true_or_iff]
  have z_ne_zero : z ≠ 0 := fun h =>
    zero_ne_one ((zero_pow zero_lt_three).symm.trans (show (0 : ℂ) ^ 3 = 1 from h ▸ h3))
  rcases key with (key | key | key)
  · exact z_ne_zero (by rwa [key, self_eq_add_left] at h1)
  · exact one_ne_zero (by rwa [key, self_eq_add_right] at h1)
  · exact z_ne_zero (pow_eq_zero (by rwa [key, add_self_eq_zero] at h2))
#align polynomial.X_pow_sub_X_sub_one_irreducible_aux Polynomial.X_pow_sub_X_sub_one_irreducible_aux

theorem X_pow_sub_X_sub_one_irreducible (hn1 : n ≠ 1) : Irreducible (X ^ n - X - 1 : ℤ[X]) :=
  by
  by_cases hn0 : n = 0
  · rw [hn0, pow_zero, sub_sub, add_comm, ← sub_sub, sub_self, zero_sub]
    exact Associated.irreducible ⟨-1, mul_neg_one X⟩ irreducible_X
  have hn : 1 < n := nat.one_lt_iff_ne_zero_and_ne_one.mpr ⟨hn0, hn1⟩
  have hp : (X ^ n - X - 1 : ℤ[X]) = trinomial 0 1 n (-1) (-1) 1 := by
    simp only [trinomial, C_neg, C_1] <;> ring
  rw [hp]
  apply is_unit_trinomial.irreducible_of_coprime' ⟨0, 1, n, zero_lt_one, hn, -1, -1, 1, rfl⟩
  rintro z ⟨h1, h2⟩
  apply X_pow_sub_X_sub_one_irreducible_aux z
  rw [trinomial_mirror zero_lt_one hn (-1 : ℤˣ).NeZero (1 : ℤˣ).NeZero] at h2
  simp_rw [trinomial, aeval_add, aeval_mul, aeval_X_pow, aeval_C] at h1 h2
  simp_rw [Units.val_neg, Units.val_one, map_neg, map_one] at h1 h2
  replace h1 : z ^ n = z + 1 := by linear_combination h1
  replace h2 := mul_eq_zero_of_left h2 z
  rw [add_mul, add_mul, add_zero, mul_assoc (-1 : ℂ), ← pow_succ', Nat.sub_add_cancel hn.le] at h2
  rw [h1] at h2⊢
  exact ⟨rfl, by linear_combination -h2⟩
#align polynomial.X_pow_sub_X_sub_one_irreducible Polynomial.X_pow_sub_X_sub_one_irreducible

theorem X_pow_sub_X_sub_one_irreducible_rat (hn1 : n ≠ 1) : Irreducible (X ^ n - X - 1 : ℚ[X]) :=
  by
  by_cases hn0 : n = 0
  · rw [hn0, pow_zero, sub_sub, add_comm, ← sub_sub, sub_self, zero_sub]
    exact Associated.irreducible ⟨-1, mul_neg_one X⟩ irreducible_X
  have hp : (X ^ n - X - 1 : ℤ[X]) = trinomial 0 1 n (-1) (-1) 1 := by
    simp only [trinomial, C_neg, C_1] <;> ring
  have hn : 1 < n := nat.one_lt_iff_ne_zero_and_ne_one.mpr ⟨hn0, hn1⟩
  have h :=
    (is_primitive.int.irreducible_iff_irreducible_map_cast _).mp
      (X_pow_sub_X_sub_one_irreducible hn1)
  ·
    rwa [Polynomial.map_sub, Polynomial.map_sub, Polynomial.map_pow, Polynomial.map_one,
      Polynomial.map_X] at h
  · exact hp.symm ▸ (trinomial_monic zero_lt_one hn).IsPrimitive
#align polynomial.X_pow_sub_X_sub_one_irreducible_rat Polynomial.X_pow_sub_X_sub_one_irreducible_rat

end Polynomial

