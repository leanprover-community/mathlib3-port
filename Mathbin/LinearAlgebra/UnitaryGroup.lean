/-
Copyright (c) 2021 Shing Tak Lam. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Shing Tak Lam

! This file was ported from Lean 3 source module linear_algebra.unitary_group
! leanprover-community/mathlib commit d101e93197bb5f6ea89bd7ba386b7f7dff1f3903
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.GeneralLinearGroup
import Mathbin.LinearAlgebra.Matrix.ToLin
import Mathbin.LinearAlgebra.Matrix.NonsingularInverse
import Mathbin.Algebra.Star.Unitary

/-!
# The Unitary Group

This file defines elements of the unitary group `unitary_group n α`, where `α` is a `star_ring`.
This consists of all `n` by `n` matrices with entries in `α` such that the star-transpose is its
inverse. In addition, we define the group structure on `unitary_group n α`, and the embedding into
the general linear group `general_linear_group α (n → α)`.

We also define the orthogonal group `orthogonal_group n β`, where `β` is a `comm_ring`.

## Main Definitions

 * `matrix.unitary_group` is the type of matrices where the star-transpose is the inverse
 * `matrix.unitary_group.group` is the group structure (under multiplication)
 * `matrix.unitary_group.embedding_GL` is the embedding `unitary_group n α → GLₙ(α)`
 * `matrix.orthogonal_group` is the type of matrices where the transpose is the inverse

## References

 * https://en.wikipedia.org/wiki/Unitary_group

## Tags

matrix group, group, unitary group, orthogonal group

-/


universe u v

namespace Matrix

open LinearMap

open Matrix

section

variable (n : Type u) [DecidableEq n] [Fintype n]

variable (α : Type v) [CommRing α] [StarRing α]

/-- `unitary_group n` is the group of `n` by `n` matrices where the star-transpose is the inverse.
-/
abbrev unitaryGroup :=
  unitary (Matrix n n α)
#align matrix.unitary_group Matrix.unitaryGroup

end

variable {n : Type u} [DecidableEq n] [Fintype n]

variable {α : Type v} [CommRing α] [StarRing α]

theorem mem_unitaryGroup_iff {A : Matrix n n α} : A ∈ Matrix.unitaryGroup n α ↔ A * star A = 1 :=
  by
  refine' ⟨And.right, fun hA => ⟨_, hA⟩⟩
  simpa only [mul_eq_mul, mul_eq_one_comm] using hA
#align matrix.mem_unitary_group_iff Matrix.mem_unitaryGroup_iff

theorem mem_unitaryGroup_iff' {A : Matrix n n α} : A ∈ Matrix.unitaryGroup n α ↔ star A * A = 1 :=
  by
  refine' ⟨And.left, fun hA => ⟨hA, _⟩⟩
  rwa [mul_eq_mul, mul_eq_one_comm] at hA
#align matrix.mem_unitary_group_iff' Matrix.mem_unitaryGroup_iff'

theorem det_of_mem_unitary {A : Matrix n n α} (hA : A ∈ Matrix.unitaryGroup n α) :
    A.det ∈ unitary α := by
  constructor
  · simpa [star, det_transpose] using congr_arg det hA.1
  · simpa [star, det_transpose] using congr_arg det hA.2
#align matrix.det_of_mem_unitary Matrix.det_of_mem_unitary

namespace UnitaryGroup

instance coeMatrix : Coe (unitaryGroup n α) (Matrix n n α) :=
  ⟨Subtype.val⟩
#align matrix.unitary_group.coe_matrix Matrix.unitaryGroup.coeMatrix

instance coeFun : CoeFun (unitaryGroup n α) fun _ => n → n → α where coe A := A.val
#align matrix.unitary_group.coe_fun Matrix.unitaryGroup.coeFun

/-- `to_lin' A` is matrix multiplication of vectors by `A`, as a linear map.

After the group structure on `unitary_group n` is defined,
we show in `to_linear_equiv` that this gives a linear equivalence.
-/
def toLin' (A : unitaryGroup n α) :=
  Matrix.toLin' A
#align matrix.unitary_group.to_lin' Matrix.unitaryGroup.toLin'

theorem ext_iff (A B : unitaryGroup n α) : A = B ↔ ∀ i j, A i j = B i j :=
  Subtype.ext_iff_val.trans ⟨fun h i j => congr_fun (congr_fun h i) j, Matrix.ext⟩
#align matrix.unitary_group.ext_iff Matrix.unitaryGroup.ext_iff

@[ext]
theorem ext (A B : unitaryGroup n α) : (∀ i j, A i j = B i j) → A = B :=
  (unitaryGroup.ext_iff A B).mpr
#align matrix.unitary_group.ext Matrix.unitaryGroup.ext

@[simp]
theorem star_mul_self (A : unitaryGroup n α) : star A ⬝ A = 1 :=
  A.2.1
#align matrix.unitary_group.star_mul_self Matrix.unitaryGroup.star_mul_self

section CoeLemmas

variable (A B : unitaryGroup n α)

@[simp]
theorem inv_val : ↑A⁻¹ = (star A : Matrix n n α) :=
  rfl
#align matrix.unitary_group.inv_val Matrix.unitaryGroup.inv_val

@[simp]
theorem inv_apply : ⇑A⁻¹ = (star A : Matrix n n α) :=
  rfl
#align matrix.unitary_group.inv_apply Matrix.unitaryGroup.inv_apply

@[simp]
theorem mul_val : ↑(A * B) = A ⬝ B :=
  rfl
#align matrix.unitary_group.mul_val Matrix.unitaryGroup.mul_val

@[simp]
theorem mul_apply : ⇑(A * B) = A ⬝ B :=
  rfl
#align matrix.unitary_group.mul_apply Matrix.unitaryGroup.mul_apply

@[simp]
theorem one_val : ↑(1 : unitaryGroup n α) = (1 : Matrix n n α) :=
  rfl
#align matrix.unitary_group.one_val Matrix.unitaryGroup.one_val

@[simp]
theorem one_apply : ⇑(1 : unitaryGroup n α) = (1 : Matrix n n α) :=
  rfl
#align matrix.unitary_group.one_apply Matrix.unitaryGroup.one_apply

@[simp]
theorem toLin'_mul : toLin' (A * B) = (toLin' A).comp (toLin' B) :=
  Matrix.toLin'_mul A B
#align matrix.unitary_group.to_lin'_mul Matrix.unitaryGroup.toLin'_mul

@[simp]
theorem toLin'_one : toLin' (1 : unitaryGroup n α) = LinearMap.id :=
  Matrix.toLin'_one
#align matrix.unitary_group.to_lin'_one Matrix.unitaryGroup.toLin'_one

end CoeLemmas

/-- `to_linear_equiv A` is matrix multiplication of vectors by `A`, as a linear equivalence. -/
def toLinearEquiv (A : unitaryGroup n α) : (n → α) ≃ₗ[α] n → α :=
  { Matrix.toLin' A with
    invFun := toLin' A⁻¹
    left_inv := fun x =>
      calc
        (toLin' A⁻¹).comp (toLin' A) x = (toLin' (A⁻¹ * A)) x := by rw [← to_lin'_mul]
        _ = x := by rw [mul_left_inv, to_lin'_one, id_apply]
        
    right_inv := fun x =>
      calc
        (toLin' A).comp (toLin' A⁻¹) x = toLin' (A * A⁻¹) x := by rw [← to_lin'_mul]
        _ = x := by rw [mul_right_inv, to_lin'_one, id_apply]
         }
#align matrix.unitary_group.to_linear_equiv Matrix.unitaryGroup.toLinearEquiv

/-- `to_GL` is the map from the unitary group to the general linear group -/
def toGL (A : unitaryGroup n α) : GeneralLinearGroup α (n → α) :=
  GeneralLinearGroup.ofLinearEquiv (toLinearEquiv A)
#align matrix.unitary_group.to_GL Matrix.unitaryGroup.toGL

theorem coe_toGL (A : unitaryGroup n α) : ↑(toGL A) = toLin' A :=
  rfl
#align matrix.unitary_group.coe_to_GL Matrix.unitaryGroup.coe_toGL

@[simp]
theorem toGL_one : toGL (1 : unitaryGroup n α) = 1 :=
  by
  ext1 v i
  rw [coe_to_GL, to_lin'_one]
  rfl
#align matrix.unitary_group.to_GL_one Matrix.unitaryGroup.toGL_one

@[simp]
theorem toGL_mul (A B : unitaryGroup n α) : toGL (A * B) = toGL A * toGL B :=
  by
  ext1 v i
  rw [coe_to_GL, to_lin'_mul]
  rfl
#align matrix.unitary_group.to_GL_mul Matrix.unitaryGroup.toGL_mul

/-- `unitary_group.embedding_GL` is the embedding from `unitary_group n α`
to `general_linear_group n α`. -/
def embeddingGL : unitaryGroup n α →* GeneralLinearGroup α (n → α) :=
  ⟨fun A => toGL A, by simp, by simp⟩
#align matrix.unitary_group.embedding_GL Matrix.unitaryGroup.embeddingGL

end UnitaryGroup

section OrthogonalGroup

variable (n) (β : Type v) [CommRing β]

attribute [local instance] starRingOfComm

/-- `orthogonal_group n` is the group of `n` by `n` matrices where the transpose is the inverse.
-/
abbrev orthogonalGroup :=
  unitaryGroup n β
#align matrix.orthogonal_group Matrix.orthogonalGroup

theorem mem_orthogonalGroup_iff {A : Matrix n n β} :
    A ∈ Matrix.orthogonalGroup n β ↔ A * star A = 1 :=
  by
  refine' ⟨And.right, fun hA => ⟨_, hA⟩⟩
  simpa only [mul_eq_mul, mul_eq_one_comm] using hA
#align matrix.mem_orthogonal_group_iff Matrix.mem_orthogonalGroup_iff

theorem mem_orthogonalGroup_iff' {A : Matrix n n β} :
    A ∈ Matrix.orthogonalGroup n β ↔ star A * A = 1 :=
  by
  refine' ⟨And.left, fun hA => ⟨hA, _⟩⟩
  rwa [mul_eq_mul, mul_eq_one_comm] at hA
#align matrix.mem_orthogonal_group_iff' Matrix.mem_orthogonalGroup_iff'

end OrthogonalGroup

end Matrix

