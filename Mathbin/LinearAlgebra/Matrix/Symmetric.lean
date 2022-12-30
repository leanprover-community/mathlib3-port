/-
Copyright (c) 2021 Lu-Ming Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Lu-Ming Zhang

! This file was ported from Lean 3 source module linear_algebra.matrix.symmetric
! leanprover-community/mathlib commit 09597669f02422ed388036273d8848119699c22f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Matrix.Block

/-!
# Symmetric matrices

This file contains the definition and basic results about symmetric matrices.

## Main definition

 * `matrix.is_symm `: a matrix `A : matrix n n α` is "symmetric" if `Aᵀ = A`.

## Tags

symm, symmetric, matrix
-/


variable {α β n m R : Type _}

namespace Matrix

open Matrix

/-- A matrix `A : matrix n n α` is "symmetric" if `Aᵀ = A`. -/
def IsSymm (A : Matrix n n α) : Prop :=
  Aᵀ = A
#align matrix.is_symm Matrix.IsSymm

theorem IsSymm.eq {A : Matrix n n α} (h : A.IsSymm) : Aᵀ = A :=
  h
#align matrix.is_symm.eq Matrix.IsSymm.eq

/-- A version of `matrix.ext_iff` that unfolds the `matrix.transpose`. -/
theorem IsSymm.ext_iff {A : Matrix n n α} : A.IsSymm ↔ ∀ i j, A j i = A i j :=
  Matrix.ext_iff.symm
#align matrix.is_symm.ext_iff Matrix.IsSymm.ext_iff

/-- A version of `matrix.ext` that unfolds the `matrix.transpose`. -/
@[ext]
theorem IsSymm.ext {A : Matrix n n α} : (∀ i j, A j i = A i j) → A.IsSymm :=
  Matrix.ext
#align matrix.is_symm.ext Matrix.IsSymm.ext

theorem IsSymm.apply {A : Matrix n n α} (h : A.IsSymm) (i j : n) : A j i = A i j :=
  IsSymm.ext_iff.1 h i j
#align matrix.is_symm.apply Matrix.IsSymm.apply

theorem is_symm_mul_transpose_self [Fintype n] [CommSemiring α] (A : Matrix n n α) :
    (A ⬝ Aᵀ).IsSymm :=
  transpose_mul _ _
#align matrix.is_symm_mul_transpose_self Matrix.is_symm_mul_transpose_self

theorem is_symm_transpose_mul_self [Fintype n] [CommSemiring α] (A : Matrix n n α) :
    (Aᵀ ⬝ A).IsSymm :=
  transpose_mul _ _
#align matrix.is_symm_transpose_mul_self Matrix.is_symm_transpose_mul_self

theorem is_symm_add_transpose_self [AddCommSemigroup α] (A : Matrix n n α) : (A + Aᵀ).IsSymm :=
  add_comm _ _
#align matrix.is_symm_add_transpose_self Matrix.is_symm_add_transpose_self

theorem is_symm_transpose_add_self [AddCommSemigroup α] (A : Matrix n n α) : (Aᵀ + A).IsSymm :=
  add_comm _ _
#align matrix.is_symm_transpose_add_self Matrix.is_symm_transpose_add_self

@[simp]
theorem is_symm_zero [Zero α] : (0 : Matrix n n α).IsSymm :=
  transpose_zero
#align matrix.is_symm_zero Matrix.is_symm_zero

@[simp]
theorem is_symm_one [DecidableEq n] [Zero α] [One α] : (1 : Matrix n n α).IsSymm :=
  transpose_one
#align matrix.is_symm_one Matrix.is_symm_one

@[simp]
theorem IsSymm.map {A : Matrix n n α} (h : A.IsSymm) (f : α → β) : (A.map f).IsSymm :=
  transpose_map.symm.trans (h.symm ▸ rfl)
#align matrix.is_symm.map Matrix.IsSymm.map

@[simp]
theorem IsSymm.transpose {A : Matrix n n α} (h : A.IsSymm) : Aᵀ.IsSymm :=
  congr_arg _ h
#align matrix.is_symm.transpose Matrix.IsSymm.transpose

@[simp]
theorem IsSymm.conj_transpose [HasStar α] {A : Matrix n n α} (h : A.IsSymm) : Aᴴ.IsSymm :=
  h.transpose.map _
#align matrix.is_symm.conj_transpose Matrix.IsSymm.conj_transpose

@[simp]
theorem IsSymm.neg [Neg α] {A : Matrix n n α} (h : A.IsSymm) : (-A).IsSymm :=
  (transpose_neg _).trans (congr_arg _ h)
#align matrix.is_symm.neg Matrix.IsSymm.neg

@[simp]
theorem IsSymm.add {A B : Matrix n n α} [Add α] (hA : A.IsSymm) (hB : B.IsSymm) : (A + B).IsSymm :=
  (transpose_add _ _).trans (hA.symm ▸ hB.symm ▸ rfl)
#align matrix.is_symm.add Matrix.IsSymm.add

@[simp]
theorem IsSymm.sub {A B : Matrix n n α} [Sub α] (hA : A.IsSymm) (hB : B.IsSymm) : (A - B).IsSymm :=
  (transpose_sub _ _).trans (hA.symm ▸ hB.symm ▸ rfl)
#align matrix.is_symm.sub Matrix.IsSymm.sub

@[simp]
theorem IsSymm.smul [HasSmul R α] {A : Matrix n n α} (h : A.IsSymm) (k : R) : (k • A).IsSymm :=
  (transpose_smul _ _).trans (congr_arg _ h)
#align matrix.is_symm.smul Matrix.IsSymm.smul

@[simp]
theorem IsSymm.submatrix {A : Matrix n n α} (h : A.IsSymm) (f : m → n) : (A.submatrix f f).IsSymm :=
  (transpose_submatrix _ _ _).trans (h.symm ▸ rfl)
#align matrix.is_symm.submatrix Matrix.IsSymm.submatrix

/-- The diagonal matrix `diagonal v` is symmetric. -/
@[simp]
theorem is_symm_diagonal [DecidableEq n] [Zero α] (v : n → α) : (diagonal v).IsSymm :=
  diagonal_transpose _
#align matrix.is_symm_diagonal Matrix.is_symm_diagonal

/-- A block matrix `A.from_blocks B C D` is symmetric,
    if `A` and `D` are symmetric and `Bᵀ = C`. -/
theorem IsSymm.from_blocks {A : Matrix m m α} {B : Matrix m n α} {C : Matrix n m α}
    {D : Matrix n n α} (hA : A.IsSymm) (hBC : Bᵀ = C) (hD : D.IsSymm) :
    (A.fromBlocks B C D).IsSymm :=
  by
  have hCB : Cᵀ = B := by
    rw [← hBC]
    simp
  unfold Matrix.IsSymm
  rw [from_blocks_transpose]
  congr <;> assumption
#align matrix.is_symm.from_blocks Matrix.IsSymm.from_blocks

/-- This is the `iff` version of `matrix.is_symm.from_blocks`. -/
theorem is_symm_from_blocks_iff {A : Matrix m m α} {B : Matrix m n α} {C : Matrix n m α}
    {D : Matrix n n α} : (A.fromBlocks B C D).IsSymm ↔ A.IsSymm ∧ Bᵀ = C ∧ Cᵀ = B ∧ D.IsSymm :=
  ⟨fun h =>
    ⟨congr_arg toBlocks₁₁ h, congr_arg toBlocks₂₁ h, congr_arg toBlocks₁₂ h,
      congr_arg toBlocks₂₂ h⟩,
    fun ⟨hA, hBC, hCB, hD⟩ => IsSymm.from_blocks hA hBC hD⟩
#align matrix.is_symm_from_blocks_iff Matrix.is_symm_from_blocks_iff

end Matrix

