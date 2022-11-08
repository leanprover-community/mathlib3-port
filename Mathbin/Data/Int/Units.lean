/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad
-/
import Mathbin.Data.Int.Order
import Mathbin.Algebra.GroupPower.Order

/-!
# Lemmas about units in `ℤ`.
-/


namespace Int

theorem is_unit_sq {a : ℤ} (ha : IsUnit a) : a ^ 2 = 1 := by rw [sq, is_unit_mul_self ha]

@[simp]
theorem units_sq (u : ℤˣ) : u ^ 2 = 1 := by rw [Units.ext_iff, Units.coe_pow, Units.coe_one, is_unit_sq u.is_unit]

alias units_sq ← units_pow_two

@[simp]
theorem units_mul_self (u : ℤˣ) : u * u = 1 := by rw [← sq, units_sq]

@[simp]
theorem units_inv_eq_self (u : ℤˣ) : u⁻¹ = u := by rw [inv_eq_iff_mul_eq_one, units_mul_self]

-- `units.coe_mul` is a "wrong turn" for the simplifier, this undoes it and simplifies further
@[simp]
theorem units_coe_mul_self (u : ℤˣ) : (u * u : ℤ) = 1 := by rw [← Units.coe_mul, units_mul_self, Units.coe_one]

@[simp]
theorem neg_one_pow_ne_zero {n : ℕ} : (-1 : ℤ) ^ n ≠ 0 :=
  pow_ne_zero _ (abs_pos.mp (by simp))

theorem sq_eq_one_of_sq_lt_four {x : ℤ} (h1 : x ^ 2 < 4) (h2 : x ≠ 0) : x ^ 2 = 1 :=
  sq_eq_one_iff.mpr
    ((abs_eq (zero_le_one' ℤ)).mp
      (le_antisymm (lt_add_one_iff.mp (abs_lt_of_sq_lt_sq h1 zero_le_two)) (sub_one_lt_iff.mp (abs_pos.mpr h2))))

theorem sq_eq_one_of_sq_le_three {x : ℤ} (h1 : x ^ 2 ≤ 3) (h2 : x ≠ 0) : x ^ 2 = 1 :=
  sq_eq_one_of_sq_lt_four (lt_of_le_of_lt h1 (lt_add_one 3)) h2

theorem units_pow_eq_pow_mod_two (u : ℤˣ) (n : ℕ) : u ^ n = u ^ (n % 2) := by
  conv =>
    lhs
    rw [← Nat.mod_add_div n 2] <;> rw [pow_add, pow_mul, units_sq, one_pow, mul_one]

end Int

