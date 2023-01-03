/-
Copyright (c) 2021 Lu-Ming Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Lu-Ming Zhang

! This file was ported from Lean 3 source module linear_algebra.matrix.is_diag
! leanprover-community/mathlib commit 9830a300340708eaa85d477c3fb96dd25f9468a5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Matrix.Symmetric
import Mathbin.LinearAlgebra.Matrix.Orthogonal
import Mathbin.Data.Matrix.Kronecker

/-!
# Diagonal matrices

This file contains the definition and basic results about diagonal matrices.

## Main results

- `matrix.is_diag`: a proposition that states a given square matrix `A` is diagonal.

## Tags

diag, diagonal, matrix
-/


namespace Matrix

variable {α β R n m : Type _}

open Function

open Matrix Kronecker

/-- `A.is_diag` means square matrix `A` is a diagonal matrix. -/
def IsDiag [Zero α] (A : Matrix n n α) : Prop :=
  ∀ ⦃i j⦄, i ≠ j → A i j = 0
#align matrix.is_diag Matrix.IsDiag

@[simp]
theorem is_diag_diagonal [Zero α] [DecidableEq n] (d : n → α) : (diagonal d).IsDiag := fun i j =>
  Matrix.diagonal_apply_ne _
#align matrix.is_diag_diagonal Matrix.is_diag_diagonal

/-- Diagonal matrices are generated by the `matrix.diagonal` of their `matrix.diag`. -/
theorem IsDiag.diagonal_diag [Zero α] [DecidableEq n] {A : Matrix n n α} (h : A.IsDiag) :
    diagonal (diag A) = A :=
  ext fun i j => by
    obtain rfl | hij := Decidable.eq_or_ne i j
    · rw [diagonal_apply_eq, diag]
    · rw [diagonal_apply_ne _ hij, h hij]
#align matrix.is_diag.diagonal_diag Matrix.IsDiag.diagonal_diag

/-- `matrix.is_diag.diagonal_diag` as an iff. -/
theorem is_diag_iff_diagonal_diag [Zero α] [DecidableEq n] (A : Matrix n n α) :
    A.IsDiag ↔ diagonal (diag A) = A :=
  ⟨IsDiag.diagonal_diag, fun hd => hd ▸ is_diag_diagonal (diag A)⟩
#align matrix.is_diag_iff_diagonal_diag Matrix.is_diag_iff_diagonal_diag

/-- Every matrix indexed by a subsingleton is diagonal. -/
theorem is_diag_of_subsingleton [Zero α] [Subsingleton n] (A : Matrix n n α) : A.IsDiag :=
  fun i j h => (h <| Subsingleton.elim i j).elim
#align matrix.is_diag_of_subsingleton Matrix.is_diag_of_subsingleton

/-- Every zero matrix is diagonal. -/
@[simp]
theorem is_diag_zero [Zero α] : (0 : Matrix n n α).IsDiag := fun i j h => rfl
#align matrix.is_diag_zero Matrix.is_diag_zero

/-- Every identity matrix is diagonal. -/
@[simp]
theorem is_diag_one [DecidableEq n] [Zero α] [One α] : (1 : Matrix n n α).IsDiag := fun i j =>
  one_apply_ne
#align matrix.is_diag_one Matrix.is_diag_one

theorem IsDiag.map [Zero α] [Zero β] {A : Matrix n n α} (ha : A.IsDiag) {f : α → β} (hf : f 0 = 0) :
    (A.map f).IsDiag := by
  intro i j h
  simp [ha h, hf]
#align matrix.is_diag.map Matrix.IsDiag.map

theorem IsDiag.neg [AddGroup α] {A : Matrix n n α} (ha : A.IsDiag) : (-A).IsDiag :=
  by
  intro i j h
  simp [ha h]
#align matrix.is_diag.neg Matrix.IsDiag.neg

@[simp]
theorem is_diag_neg_iff [AddGroup α] {A : Matrix n n α} : (-A).IsDiag ↔ A.IsDiag :=
  ⟨fun ha i j h => neg_eq_zero.1 (ha h), IsDiag.neg⟩
#align matrix.is_diag_neg_iff Matrix.is_diag_neg_iff

theorem IsDiag.add [AddZeroClass α] {A B : Matrix n n α} (ha : A.IsDiag) (hb : B.IsDiag) :
    (A + B).IsDiag := by
  intro i j h
  simp [ha h, hb h]
#align matrix.is_diag.add Matrix.IsDiag.add

theorem IsDiag.sub [AddGroup α] {A B : Matrix n n α} (ha : A.IsDiag) (hb : B.IsDiag) :
    (A - B).IsDiag := by
  intro i j h
  simp [ha h, hb h]
#align matrix.is_diag.sub Matrix.IsDiag.sub

theorem IsDiag.smul [Monoid R] [AddMonoid α] [DistribMulAction R α] (k : R) {A : Matrix n n α}
    (ha : A.IsDiag) : (k • A).IsDiag := by
  intro i j h
  simp [ha h]
#align matrix.is_diag.smul Matrix.IsDiag.smul

@[simp]
theorem is_diag_smul_one (n) [Semiring α] [DecidableEq n] (k : α) :
    (k • (1 : Matrix n n α)).IsDiag :=
  is_diag_one.smul k
#align matrix.is_diag_smul_one Matrix.is_diag_smul_one

theorem IsDiag.transpose [Zero α] {A : Matrix n n α} (ha : A.IsDiag) : Aᵀ.IsDiag := fun i j h =>
  ha h.symm
#align matrix.is_diag.transpose Matrix.IsDiag.transpose

@[simp]
theorem is_diag_transpose_iff [Zero α] {A : Matrix n n α} : Aᵀ.IsDiag ↔ A.IsDiag :=
  ⟨IsDiag.transpose, IsDiag.transpose⟩
#align matrix.is_diag_transpose_iff Matrix.is_diag_transpose_iff

theorem IsDiag.conj_transpose [Semiring α] [StarRing α] {A : Matrix n n α} (ha : A.IsDiag) :
    Aᴴ.IsDiag :=
  ha.transpose.map (star_zero _)
#align matrix.is_diag.conj_transpose Matrix.IsDiag.conj_transpose

@[simp]
theorem is_diag_conj_transpose_iff [Semiring α] [StarRing α] {A : Matrix n n α} :
    Aᴴ.IsDiag ↔ A.IsDiag :=
  ⟨fun ha => by
    convert ha.conj_transpose
    simp, IsDiag.conj_transpose⟩
#align matrix.is_diag_conj_transpose_iff Matrix.is_diag_conj_transpose_iff

theorem IsDiag.submatrix [Zero α] {A : Matrix n n α} (ha : A.IsDiag) {f : m → n}
    (hf : Injective f) : (A.submatrix f f).IsDiag := fun i j h => ha (hf.Ne h)
#align matrix.is_diag.submatrix Matrix.IsDiag.submatrix

/-- `(A ⊗ B).is_diag` if both `A` and `B` are diagonal. -/
theorem IsDiag.kronecker [MulZeroClass α] {A : Matrix m m α} {B : Matrix n n α} (hA : A.IsDiag)
    (hB : B.IsDiag) : (A ⊗ₖ B).IsDiag :=
  by
  rintro ⟨a, b⟩ ⟨c, d⟩ h
  simp only [Prod.mk.inj_iff, Ne.def, not_and_or] at h
  cases' h with hac hbd
  · simp [hA hac]
  · simp [hB hbd]
#align matrix.is_diag.kronecker Matrix.IsDiag.kronecker

theorem IsDiag.is_symm [Zero α] {A : Matrix n n α} (h : A.IsDiag) : A.IsSymm :=
  by
  ext (i j)
  by_cases g : i = j; · rw [g]
  simp [h g, h (Ne.symm g)]
#align matrix.is_diag.is_symm Matrix.IsDiag.is_symm

/-- The block matrix `A.from_blocks 0 0 D` is diagonal if `A` and `D` are diagonal. -/
theorem IsDiag.from_blocks [Zero α] {A : Matrix m m α} {D : Matrix n n α} (ha : A.IsDiag)
    (hd : D.IsDiag) : (A.fromBlocks 0 0 D).IsDiag :=
  by
  rintro (i | i) (j | j) hij
  · exact ha (ne_of_apply_ne _ hij)
  · rfl
  · rfl
  · exact hd (ne_of_apply_ne _ hij)
#align matrix.is_diag.from_blocks Matrix.IsDiag.from_blocks

/-- This is the `iff` version of `matrix.is_diag.from_blocks`. -/
theorem is_diag_from_blocks_iff [Zero α] {A : Matrix m m α} {B : Matrix m n α} {C : Matrix n m α}
    {D : Matrix n n α} : (A.fromBlocks B C D).IsDiag ↔ A.IsDiag ∧ B = 0 ∧ C = 0 ∧ D.IsDiag :=
  by
  constructor
  · intro h
    refine' ⟨fun i j hij => _, ext fun i j => _, ext fun i j => _, fun i j hij => _⟩
    · exact h (sum.inl_injective.ne hij)
    · exact h Sum.inl_ne_inr
    · exact h Sum.inr_ne_inl
    · exact h (sum.inr_injective.ne hij)
  · rintro ⟨ha, hb, hc, hd⟩
    convert is_diag.from_blocks ha hd
#align matrix.is_diag_from_blocks_iff Matrix.is_diag_from_blocks_iff

/-- A symmetric block matrix `A.from_blocks B C D` is diagonal
    if  `A` and `D` are diagonal and `B` is `0`. -/
theorem IsDiag.from_blocks_of_is_symm [Zero α] {A : Matrix m m α} {C : Matrix n m α}
    {D : Matrix n n α} (h : (A.fromBlocks 0 C D).IsSymm) (ha : A.IsDiag) (hd : D.IsDiag) :
    (A.fromBlocks 0 C D).IsDiag :=
  by
  rw [← (is_symm_from_blocks_iff.1 h).2.1]
  exact ha.from_blocks hd
#align matrix.is_diag.from_blocks_of_is_symm Matrix.IsDiag.from_blocks_of_is_symm

theorem mul_transpose_self_is_diag_iff_has_orthogonal_rows [Fintype n] [Mul α] [AddCommMonoid α]
    {A : Matrix m n α} : (A ⬝ Aᵀ).IsDiag ↔ A.HasOrthogonalRows :=
  Iff.rfl
#align
  matrix.mul_transpose_self_is_diag_iff_has_orthogonal_rows Matrix.mul_transpose_self_is_diag_iff_has_orthogonal_rows

theorem transpose_mul_self_is_diag_iff_has_orthogonal_cols [Fintype m] [Mul α] [AddCommMonoid α]
    {A : Matrix m n α} : (Aᵀ ⬝ A).IsDiag ↔ A.HasOrthogonalCols :=
  Iff.rfl
#align
  matrix.transpose_mul_self_is_diag_iff_has_orthogonal_cols Matrix.transpose_mul_self_is_diag_iff_has_orthogonal_cols

end Matrix

