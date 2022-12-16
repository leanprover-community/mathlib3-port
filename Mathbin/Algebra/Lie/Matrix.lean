/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module algebra.lie.matrix
! leanprover-community/mathlib commit d012cd09a9b256d870751284dd6a29882b0be105
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Lie.OfAssociative
import Mathbin.LinearAlgebra.Matrix.Reindex
import Mathbin.LinearAlgebra.Matrix.ToLinearEquiv

/-!
# Lie algebras of matrices

An important class of Lie algebras are those arising from the associative algebra structure on
square matrices over a commutative ring. This file provides some very basic definitions whose
primary value stems from their utility when constructing the classical Lie algebras using matrices.

## Main definitions

  * `lie_equiv_matrix'`
  * `matrix.lie_conj`
  * `matrix.reindex_lie_equiv`

## Tags

lie algebra, matrix
-/


universe u v w w₁ w₂

section Matrices

open Matrix

variable {R : Type u} [CommRing R]

variable {n : Type w} [DecidableEq n] [Fintype n]

/-- The natural equivalence between linear endomorphisms of finite free modules and square matrices
is compatible with the Lie algebra structures. -/
def lieEquivMatrix' : Module.EndCat R (n → R) ≃ₗ⁅R⁆ Matrix n n R :=
  { LinearMap.toMatrix' with
    map_lie' := fun T S => by 
      let f := @LinearMap.toMatrix' R _ n n _ _
      change f (T.comp S - S.comp T) = f T * f S - f S * f T
      have h : ∀ T S : Module.EndCat R _, f (T.comp S) = f T ⬝ f S := LinearMap.to_matrix'_comp
      rw [LinearEquiv.map_sub, h, h, Matrix.mul_eq_mul, Matrix.mul_eq_mul] }
#align lie_equiv_matrix' lieEquivMatrix'

@[simp]
theorem lie_equiv_matrix'_apply (f : Module.EndCat R (n → R)) : lieEquivMatrix' f = f.toMatrix' :=
  rfl
#align lie_equiv_matrix'_apply lie_equiv_matrix'_apply

@[simp]
theorem lie_equiv_matrix'_symm_apply (A : Matrix n n R) :
    (@lieEquivMatrix' R _ n _ _).symm A = A.toLin' :=
  rfl
#align lie_equiv_matrix'_symm_apply lie_equiv_matrix'_symm_apply

/-- An invertible matrix induces a Lie algebra equivalence from the space of matrices to itself. -/
def Matrix.lieConj (P : Matrix n n R) (h : Invertible P) : Matrix n n R ≃ₗ⁅R⁆ Matrix n n R :=
  ((@lieEquivMatrix' R _ n _ _).symm.trans (P.toLinearEquiv' h).lieConj).trans lieEquivMatrix'
#align matrix.lie_conj Matrix.lieConj

@[simp]
theorem Matrix.lie_conj_apply (P A : Matrix n n R) (h : Invertible P) :
    P.lieConj h A = P ⬝ A ⬝ P⁻¹ := by
  simp [LinearEquiv.conj_apply, Matrix.lieConj, LinearMap.to_matrix'_comp,
    LinearMap.to_matrix'_to_lin']
#align matrix.lie_conj_apply Matrix.lie_conj_apply

@[simp]
theorem Matrix.lie_conj_symm_apply (P A : Matrix n n R) (h : Invertible P) :
    (P.lieConj h).symm A = P⁻¹ ⬝ A ⬝ P := by
  simp [LinearEquiv.symm_conj_apply, Matrix.lieConj, LinearMap.to_matrix'_comp,
    LinearMap.to_matrix'_to_lin']
#align matrix.lie_conj_symm_apply Matrix.lie_conj_symm_apply

variable {m : Type w₁} [DecidableEq m] [Fintype m] (e : n ≃ m)

/-- For square matrices, the natural map that reindexes a matrix's rows and columns with equivalent
types, `matrix.reindex`, is an equivalence of Lie algebras. -/
def Matrix.reindexLieEquiv : Matrix n n R ≃ₗ⁅R⁆ Matrix m m R :=
  { Matrix.reindexLinearEquiv R R e e with
    toFun := Matrix.reindex e e
    map_lie' := fun M N => by
      simp only [LieRing.of_associative_ring_bracket, Matrix.reindex_apply,
        Matrix.submatrix_mul_equiv, Matrix.mul_eq_mul, Matrix.submatrix_sub, Pi.sub_apply] }
#align matrix.reindex_lie_equiv Matrix.reindexLieEquiv

@[simp]
theorem Matrix.reindex_lie_equiv_apply (M : Matrix n n R) :
    Matrix.reindexLieEquiv e M = Matrix.reindex e e M :=
  rfl
#align matrix.reindex_lie_equiv_apply Matrix.reindex_lie_equiv_apply

@[simp]
theorem Matrix.reindex_lie_equiv_symm :
    (Matrix.reindexLieEquiv e : _ ≃ₗ⁅R⁆ _).symm = Matrix.reindexLieEquiv e.symm :=
  rfl
#align matrix.reindex_lie_equiv_symm Matrix.reindex_lie_equiv_symm

end Matrices

