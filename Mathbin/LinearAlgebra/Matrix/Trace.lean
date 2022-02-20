/-
Copyright (c) 2019 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Patrick Massot, Casper Putz, Anne Baanen
-/
import Mathbin.Data.Matrix.Basic

/-!
# Trace of a matrix

This file defines the trace of a matrix, the linear map
sending a matrix to the sum of its diagonal entries.

See also `linear_algebra.trace` for the trace of an endomorphism.

## Tags

matrix, trace, diagonal

-/


open_locale BigOperators

open_locale Matrix

namespace Matrix

section trace

universe u v w

variable {m : Type _} (n : Type _) {p : Type _}

variable (R : Type _) (M : Type _) [Semiringₓ R] [AddCommMonoidₓ M] [Module R M]

/-- The diagonal of a square matrix.
-/
def diag : Matrix n n M →ₗ[R] n → M where
  toFun := fun A i => A i i
  map_add' := by
    intros
    ext
    rfl
  map_smul' := by
    intros
    ext
    rfl

variable {n} {R} {M}

@[simp]
theorem diag_apply (A : Matrix n n M) (i : n) : diag n R M A i = A i i :=
  rfl

@[simp]
theorem diag_one [DecidableEq n] : diag n R R 1 = fun i => 1 := by
  dunfold diag
  ext
  simp [one_apply_eq]

@[simp]
theorem diag_transpose (A : Matrix n n M) : diag n R M (A)ᵀ = diag n R M A :=
  rfl

@[simp]
theorem diag_col_mul_row (a b : n → R) : diag n R R (colₓ a ⬝ rowₓ b) = a * b := by
  ext
  simp [Matrix.mul_apply]

variable (n) (R) (M)

/-- The trace of a square matrix.
-/
def trace [Fintype n] : Matrix n n M →ₗ[R] M where
  toFun := fun A => ∑ i, diag n R M A i
  map_add' := by
    intros
    apply Finset.sum_add_distrib
  map_smul' := by
    intros
    simp [Finset.smul_sum]

variable {n} {R} {M} [Fintype n] [Fintype m] [Fintype p]

@[simp]
theorem trace_diag (A : Matrix n n M) : trace n R M A = ∑ i, diag n R M A i :=
  rfl

theorem trace_apply (A : Matrix n n M) : trace n R M A = ∑ i, A i i :=
  rfl

@[simp]
theorem trace_one [DecidableEq n] : trace n R R 1 = Fintype.card n := by
  have h : trace n R R 1 = ∑ i, diag n R R 1 i := rfl
  simp_rw [h, diag_one, Finset.sum_const, nsmul_one] <;> rfl

@[simp]
theorem trace_transpose (A : Matrix n n M) : trace n R M (A)ᵀ = trace n R M A :=
  rfl

@[simp]
theorem trace_transpose_mul (A : Matrix m n R) (B : Matrix n m R) : trace n R R ((A)ᵀ ⬝ (B)ᵀ) = trace m R R (A ⬝ B) :=
  Finset.sum_comm

theorem trace_mul_comm {S : Type v} [CommSemiringₓ S] (A : Matrix m n S) (B : Matrix n m S) :
    trace m S S (A ⬝ B) = trace n S S (B ⬝ A) := by
  rw [← trace_transpose, ← trace_transpose_mul, transpose_mul]

theorem trace_mul_cycle {S : Type v} [CommSemiringₓ S] (A : Matrix m n S) (B : Matrix n p S) (C : Matrix p m S) :
    trace _ S S (A ⬝ B ⬝ C) = trace p S S (C ⬝ A ⬝ B) := by
  rw [trace_mul_comm, Matrix.mul_assoc]

theorem trace_mul_cycle' {S : Type v} [CommSemiringₓ S] (A : Matrix m n S) (B : Matrix n p S) (C : Matrix p m S) :
    trace _ S S (A ⬝ (B ⬝ C)) = trace p S S (C ⬝ (A ⬝ B)) := by
  rw [← Matrix.mul_assoc, trace_mul_comm]

@[simp]
theorem trace_col_mul_row (a b : n → R) : trace n R R (colₓ a ⬝ rowₓ b) = dotProduct a b := by
  simp [dot_product]

/-! ### Special cases for `fin n`

While `simp [fin.sum_univ_succ]` can prove these, we include them for convenience and consistency
with `matrix.det_fin_two` etc.
-/


@[simp]
theorem trace_fin_zero (A : Matrix (Finₓ 0) (Finₓ 0) R) : trace _ R R A = 0 :=
  rfl

theorem trace_fin_one (A : Matrix (Finₓ 1) (Finₓ 1) R) : trace _ R R A = A 0 0 :=
  add_zeroₓ _

theorem trace_fin_two (A : Matrix (Finₓ 2) (Finₓ 2) R) : trace _ R R A = A 0 0 + A 1 1 :=
  congr_argₓ ((· + ·) _) (add_zeroₓ (A 1 1))

theorem trace_fin_three (A : Matrix (Finₓ 3) (Finₓ 3) R) : trace _ R R A = A 0 0 + A 1 1 + A 2 2 := by
  rw [← add_zeroₓ (A 2 2), add_assocₓ]
  rfl

end trace

end Matrix

