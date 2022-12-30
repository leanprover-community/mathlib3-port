/-
Copyright (c) 2021 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin

! This file was ported from Lean 3 source module analysis.normed_space.int
! leanprover-community/mathlib commit 09597669f02422ed388036273d8848119699c22f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Normed.Field.Basic

/-!
# The integers as normed ring

This file contains basic facts about the integers as normed ring.

Recall that `‖n‖` denotes the norm of `n` as real number.
This norm is always nonnegative, so we can bundle the norm together with this fact,
to obtain a term of type `nnreal` (the nonnegative real numbers).
The resulting nonnegative real number is denoted by `‖n‖₊`.
-/


open BigOperators

namespace Int

theorem nnnorm_coe_units (e : ℤˣ) : ‖(e : ℤ)‖₊ = 1 := by
  obtain rfl | rfl := Int.units_eq_one_or e <;>
    simp only [Units.coe_neg_one, Units.val_one, nnnorm_neg, nnnorm_one]
#align int.nnnorm_coe_units Int.nnnorm_coe_units

theorem norm_coe_units (e : ℤˣ) : ‖(e : ℤ)‖ = 1 := by
  rw [← coe_nnnorm, Int.nnnorm_coe_units, Nnreal.coe_one]
#align int.norm_coe_units Int.norm_coe_units

@[simp]
theorem nnnorm_coe_nat (n : ℕ) : ‖(n : ℤ)‖₊ = n :=
  Real.nnnorm_coe_nat _
#align int.nnnorm_coe_nat Int.nnnorm_coe_nat

@[simp]
theorem to_nat_add_to_nat_neg_eq_nnnorm (n : ℤ) : ↑n.toNat + ↑(-n).toNat = ‖n‖₊ := by
  rw [← Nat.cast_add, to_nat_add_to_nat_neg_eq_nat_abs, Nnreal.coe_nat_abs]
#align int.to_nat_add_to_nat_neg_eq_nnnorm Int.to_nat_add_to_nat_neg_eq_nnnorm

@[simp]
theorem to_nat_add_to_nat_neg_eq_norm (n : ℤ) : ↑n.toNat + ↑(-n).toNat = ‖n‖ := by
  simpa only [Nnreal.coe_nat_cast, Nnreal.coe_add] using
    congr_arg (coe : _ → ℝ) (to_nat_add_to_nat_neg_eq_nnnorm n)
#align int.to_nat_add_to_nat_neg_eq_norm Int.to_nat_add_to_nat_neg_eq_norm

end Int

