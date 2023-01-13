/-
Copyright (c) 2021 Lu-Ming Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Lu-Ming Zhang

! This file was ported from Lean 3 source module linear_algebra.matrix.circulant
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Matrix.Symmetric

/-!
# Circulant matrices

This file contains the definition and basic results about circulant matrices.
Given a vector `v : n → α` indexed by a type that is endowed with subtraction,
`matrix.circulant v` is the matrix whose `(i, j)`th entry is `v (i - j)`.

## Main results

- `matrix.circulant`: the circulant matrix generated by a given vector `v : n → α`.
- `matrix.circulant_mul`: the product of two circulant matrices `circulant v` and `circulant w` is
                          the circulant matrix generated by `mul_vec (circulant v) w`.
- `matrix.circulant_mul_comm`: multiplication of circulant matrices commutes when the elements do.

## Implementation notes

`matrix.fin.foo` is the `fin n` version of `matrix.foo`.
Namely, the index type of the circulant matrices in discussion is `fin n`.

## Tags

circulant, matrix
-/


variable {α β m n R : Type _}

namespace Matrix

open Function

open Matrix BigOperators

/-- Given the condition `[has_sub n]` and a vector `v : n → α`,
    we define `circulant v` to be the circulant matrix generated by `v` of type `matrix n n α`.
    The `(i,j)`th entry is defined to be `v (i - j)`. -/
@[simp]
def circulant [Sub n] (v : n → α) : Matrix n n α
  | i, j => v (i - j)
#align matrix.circulant Matrix.circulant

theorem circulant_col_zero_eq [AddGroup n] (v : n → α) (i : n) : circulant v i 0 = v i :=
  congr_arg v (sub_zero _)
#align matrix.circulant_col_zero_eq Matrix.circulant_col_zero_eq

theorem circulant_injective [AddGroup n] : Injective (circulant : (n → α) → Matrix n n α) :=
  by
  intro v w h
  ext k
  rw [← circulant_col_zero_eq v, ← circulant_col_zero_eq w, h]
#align matrix.circulant_injective Matrix.circulant_injective

theorem Fin.circulant_injective : ∀ n, Injective fun v : Fin n → α => circulant v
  | 0 => by decide
  | n + 1 => circulant_injective
#align matrix.fin.circulant_injective Matrix.Fin.circulant_injective

@[simp]
theorem circulant_inj [AddGroup n] {v w : n → α} : circulant v = circulant w ↔ v = w :=
  circulant_injective.eq_iff
#align matrix.circulant_inj Matrix.circulant_inj

@[simp]
theorem Fin.circulant_inj {n} {v w : Fin n → α} : circulant v = circulant w ↔ v = w :=
  (Fin.circulant_injective n).eq_iff
#align matrix.fin.circulant_inj Matrix.Fin.circulant_inj

theorem transpose_circulant [AddGroup n] (v : n → α) : (circulant v)ᵀ = circulant fun i => v (-i) :=
  by ext <;> simp
#align matrix.transpose_circulant Matrix.transpose_circulant

theorem conj_transpose_circulant [Star α] [AddGroup n] (v : n → α) :
    (circulant v)ᴴ = circulant (star fun i => v (-i)) := by ext <;> simp
#align matrix.conj_transpose_circulant Matrix.conj_transpose_circulant

theorem Fin.transpose_circulant : ∀ {n} (v : Fin n → α), (circulant v)ᵀ = circulant fun i => v (-i)
  | 0 => by decide
  | n + 1 => transpose_circulant
#align matrix.fin.transpose_circulant Matrix.Fin.transpose_circulant

theorem Fin.conj_transpose_circulant [Star α] :
    ∀ {n} (v : Fin n → α), (circulant v)ᴴ = circulant (star fun i => v (-i))
  | 0 => by decide
  | n + 1 => conj_transpose_circulant
#align matrix.fin.conj_transpose_circulant Matrix.Fin.conj_transpose_circulant

theorem map_circulant [Sub n] (v : n → α) (f : α → β) :
    (circulant v).map f = circulant fun i => f (v i) :=
  ext fun _ _ => rfl
#align matrix.map_circulant Matrix.map_circulant

theorem circulant_neg [Neg α] [Sub n] (v : n → α) : circulant (-v) = -circulant v :=
  ext fun _ _ => rfl
#align matrix.circulant_neg Matrix.circulant_neg

@[simp]
theorem circulant_zero (α n) [Zero α] [Sub n] : circulant 0 = (0 : Matrix n n α) :=
  ext fun _ _ => rfl
#align matrix.circulant_zero Matrix.circulant_zero

theorem circulant_add [Add α] [Sub n] (v w : n → α) :
    circulant (v + w) = circulant v + circulant w :=
  ext fun _ _ => rfl
#align matrix.circulant_add Matrix.circulant_add

theorem circulant_sub [Sub α] [Sub n] (v w : n → α) :
    circulant (v - w) = circulant v - circulant w :=
  ext fun _ _ => rfl
#align matrix.circulant_sub Matrix.circulant_sub

/-- The product of two circulant matrices `circulant v` and `circulant w` is
    the circulant matrix generated by `mul_vec (circulant v) w`. -/
theorem circulant_mul [Semiring α] [Fintype n] [AddGroup n] (v w : n → α) :
    circulant v ⬝ circulant w = circulant (mulVec (circulant v) w) :=
  by
  ext (i j)
  simp only [mul_apply, mul_vec, circulant, dot_product]
  refine' Fintype.sum_equiv (Equiv.subRight j) _ _ _
  intro x
  simp only [Equiv.sub_right_apply, sub_sub_sub_cancel_right]
#align matrix.circulant_mul Matrix.circulant_mul

theorem Fin.circulant_mul [Semiring α] :
    ∀ {n} (v w : Fin n → α), circulant v ⬝ circulant w = circulant (mulVec (circulant v) w)
  | 0 => by decide
  | n + 1 => circulant_mul
#align matrix.fin.circulant_mul Matrix.Fin.circulant_mul

/-- Multiplication of circulant matrices commutes when the elements do. -/
theorem circulant_mul_comm [CommSemigroup α] [AddCommMonoid α] [Fintype n] [AddCommGroup n]
    (v w : n → α) : circulant v ⬝ circulant w = circulant w ⬝ circulant v :=
  by
  ext (i j)
  simp only [mul_apply, circulant, mul_comm]
  refine' Fintype.sum_equiv ((Equiv.subLeft i).trans (Equiv.addRight j)) _ _ _
  intro x
  congr 2
  · simp
  · simp only [Equiv.coe_addRight, Function.comp_apply, Equiv.coe_trans, Equiv.sub_left_apply]
    abel
#align matrix.circulant_mul_comm Matrix.circulant_mul_comm

theorem Fin.circulant_mul_comm [CommSemigroup α] [AddCommMonoid α] :
    ∀ {n} (v w : Fin n → α), circulant v ⬝ circulant w = circulant w ⬝ circulant v
  | 0 => by decide
  | n + 1 => circulant_mul_comm
#align matrix.fin.circulant_mul_comm Matrix.Fin.circulant_mul_comm

/-- `k • circulant v` is another circulant matrix `circulant (k • v)`. -/
theorem circulant_smul [Sub n] [SMul R α] (k : R) (v : n → α) :
    circulant (k • v) = k • circulant v := by ext <;> simp
#align matrix.circulant_smul Matrix.circulant_smul

@[simp]
theorem circulant_single_one (α n) [Zero α] [One α] [DecidableEq n] [AddGroup n] :
    circulant (Pi.single 0 1 : n → α) = (1 : Matrix n n α) :=
  by
  ext (i j)
  simp [one_apply, Pi.single_apply, sub_eq_zero]
#align matrix.circulant_single_one Matrix.circulant_single_one

@[simp]
theorem circulant_single (n) [Semiring α] [DecidableEq n] [AddGroup n] [Fintype n] (a : α) :
    circulant (Pi.single 0 a : n → α) = scalar n a :=
  by
  ext (i j)
  simp [Pi.single_apply, one_apply, sub_eq_zero]
#align matrix.circulant_single Matrix.circulant_single

/-- Note we use `↑i = 0` instead of `i = 0` as `fin 0` has no `0`.
This means that we cannot state this with `pi.single` as we did with `matrix.circulant_single`. -/
theorem Fin.circulant_ite (α) [Zero α] [One α] :
    ∀ n, circulant (fun i => ite (↑i = 0) 1 0 : Fin n → α) = 1
  | 0 => by decide
  | n + 1 => by
    rw [← circulant_single_one]
    congr with j
    simp only [Pi.single_apply, Fin.ext_iff]
    congr
#align matrix.fin.circulant_ite Matrix.Fin.circulant_ite

/-- A circulant of `v` is symmetric iff `v` equals its reverse. -/
theorem circulant_is_symm_iff [AddGroup n] {v : n → α} : (circulant v).IsSymm ↔ ∀ i, v (-i) = v i :=
  by rw [IsSymm, transpose_circulant, circulant_inj, funext_iff]
#align matrix.circulant_is_symm_iff Matrix.circulant_is_symm_iff

theorem Fin.circulant_is_symm_iff : ∀ {n} {v : Fin n → α}, (circulant v).IsSymm ↔ ∀ i, v (-i) = v i
  | 0 => fun v => by simp [is_symm.ext_iff, IsEmpty.forall_iff]
  | n + 1 => fun v => circulant_is_symm_iff
#align matrix.fin.circulant_is_symm_iff Matrix.Fin.circulant_is_symm_iff

/-- If `circulant v` is symmetric, `∀ i j : I, v (- i) = v i`. -/
theorem circulant_is_symm_apply [AddGroup n] {v : n → α} (h : (circulant v).IsSymm) (i : n) :
    v (-i) = v i :=
  circulant_is_symm_iff.1 h i
#align matrix.circulant_is_symm_apply Matrix.circulant_is_symm_apply

theorem Fin.circulant_is_symm_apply {n} {v : Fin n → α} (h : (circulant v).IsSymm) (i : Fin n) :
    v (-i) = v i :=
  Fin.circulant_is_symm_iff.1 h i
#align matrix.fin.circulant_is_symm_apply Matrix.Fin.circulant_is_symm_apply

end Matrix

