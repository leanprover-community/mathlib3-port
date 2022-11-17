/-
Copyright (c) 2019 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anne Baanen
-/
import Mathbin.Algebra.Associated
import Mathbin.Algebra.Regular.Basic
import Mathbin.LinearAlgebra.Matrix.MvPolynomial
import Mathbin.LinearAlgebra.Matrix.Polynomial
import Mathbin.RingTheory.Polynomial.Basic
import Mathbin.Tactic.Linarith.Default
import Mathbin.Tactic.RingExp

/-!
# Cramer's rule and adjugate matrices

The adjugate matrix is the transpose of the cofactor matrix.
It is calculated with Cramer's rule, which we introduce first.
The vectors returned by Cramer's rule are given by the linear map `cramer`,
which sends a matrix `A` and vector `b` to the vector consisting of the
determinant of replacing the `i`th column of `A` with `b` at index `i`
(written as `(A.update_column i b).det`).
Using Cramer's rule, we can compute for each matrix `A` the matrix `adjugate A`.
The entries of the adjugate are the minors of `A`.
Instead of defining a minor by deleting row `i` and column `j` of `A`, we
replace the `i`th row of `A` with the `j`th basis vector; the resulting matrix
has the same determinant but more importantly equals Cramer's rule applied
to `A` and the `j`th basis vector, simplifying the subsequent proofs.
We prove the adjugate behaves like `det A • A⁻¹`.

## Main definitions

 * `matrix.cramer A b`: the vector output by Cramer's rule on `A` and `b`.
 * `matrix.adjugate A`: the adjugate (or classical adjoint) of the matrix `A`.

## References

  * https://en.wikipedia.org/wiki/Cramer's_rule#Finding_inverse_matrix

## Tags

cramer, cramer's rule, adjugate
-/


namespace Matrix

universe u v

variable {n : Type u} [DecidableEq n] [Fintype n] {α : Type v} [CommRing α]

open Matrix BigOperators Polynomial

open Equiv Equiv.Perm Finset

section Cramer

/-!
  ### `cramer` section

  Introduce the linear map `cramer` with values defined by `cramer_map`.
  After defining `cramer_map` and showing it is linear,
  we will restrict our proofs to using `cramer`.
-/


variable (A : Matrix n n α) (b : n → α)

/-- `cramer_map A b i` is the determinant of the matrix `A` with column `i` replaced with `b`,
  and thus `cramer_map A b` is the vector output by Cramer's rule on `A` and `b`.

  If `A ⬝ x = b` has a unique solution in `x`, `cramer_map A` sends the vector `b` to `A.det • x`.
  Otherwise, the outcome of `cramer_map` is well-defined but not necessarily useful.
-/
def cramerMap (i : n) : α :=
  (A.updateColumn i b).det
#align matrix.cramer_map Matrix.cramerMap

theorem cramer_map_is_linear (i : n) : IsLinearMap α fun b => cramerMap A b i :=
  { map_add := det_update_column_add _ _, map_smul := det_update_column_smul _ _ }
#align matrix.cramer_map_is_linear Matrix.cramer_map_is_linear

theorem cramer_is_linear : IsLinearMap α (cramerMap A) := by
  constructor <;> intros <;> ext i
  · apply (cramer_map_is_linear A i).1
    
  · apply (cramer_map_is_linear A i).2
    
#align matrix.cramer_is_linear Matrix.cramer_is_linear

/-- `cramer A b i` is the determinant of the matrix `A` with column `i` replaced with `b`,
  and thus `cramer A b` is the vector output by Cramer's rule on `A` and `b`.

  If `A ⬝ x = b` has a unique solution in `x`, `cramer A` sends the vector `b` to `A.det • x`.
  Otherwise, the outcome of `cramer` is well-defined but not necessarily useful.
 -/
def cramer (A : Matrix n n α) : (n → α) →ₗ[α] n → α :=
  IsLinearMap.mk' (cramerMap A) (cramer_is_linear A)
#align matrix.cramer Matrix.cramer

theorem cramer_apply (i : n) : cramer A b i = (A.updateColumn i b).det :=
  rfl
#align matrix.cramer_apply Matrix.cramer_apply

theorem cramer_transpose_apply (i : n) : cramer Aᵀ b i = (A.updateRow i b).det := by
  rw [cramer_apply, update_column_transpose, det_transpose]
#align matrix.cramer_transpose_apply Matrix.cramer_transpose_apply

theorem cramer_transpose_row_self (i : n) : Aᵀ.cramer (A i) = Pi.single i A.det := by
  ext j
  rw [cramer_apply, Pi.single_apply]
  split_ifs with h
  · -- i = j: this entry should be `A.det`
    subst h
    simp only [update_column_transpose, det_transpose, update_row, Function.update_eq_self]
    
  · -- i ≠ j: this entry should be 0
    rw [update_column_transpose, det_transpose]
    apply det_zero_of_row_eq h
    rw [update_row_self, update_row_ne (Ne.symm h)]
    
#align matrix.cramer_transpose_row_self Matrix.cramer_transpose_row_self

theorem cramer_row_self (i : n) (h : ∀ j, b j = A j i) : A.cramer b = Pi.single i A.det := by
  rw [← transpose_transpose A, det_transpose]
  convert cramer_transpose_row_self Aᵀ i
  exact funext h
#align matrix.cramer_row_self Matrix.cramer_row_self

@[simp]
theorem cramer_one : cramer (1 : Matrix n n α) = 1 := by
  ext (i j)
  convert congr_fun (cramer_row_self (1 : Matrix n n α) (Pi.single i 1) i _) j
  · simp
    
  · intro j
    rw [Matrix.one_eq_pi_single, Pi.single_comm]
    
#align matrix.cramer_one Matrix.cramer_one

theorem cramer_smul (r : α) (A : Matrix n n α) : cramer (r • A) = r ^ (Fintype.card n - 1) • cramer A :=
  LinearMap.ext $ fun b => funext $ fun _ => det_update_column_smul' _ _ _ _
#align matrix.cramer_smul Matrix.cramer_smul

@[simp]
theorem cramer_subsingleton_apply [Subsingleton n] (A : Matrix n n α) (b : n → α) (i : n) : cramer A b i = b i := by
  rw [cramer_apply, det_eq_elem_of_subsingleton _ i, update_column_self]
#align matrix.cramer_subsingleton_apply Matrix.cramer_subsingleton_apply

theorem cramer_zero [Nontrivial n] : cramer (0 : Matrix n n α) = 0 := by
  ext (i j)
  obtain ⟨j', hj'⟩ : ∃ j', j' ≠ j := exists_ne j
  apply det_eq_zero_of_column_eq_zero j'
  intro j''
  simp [update_column_ne hj']
#align matrix.cramer_zero Matrix.cramer_zero

/-- Use linearity of `cramer` to take it out of a summation. -/
theorem sum_cramer {β} (s : Finset β) (f : β → n → α) : (∑ x in s, cramer A (f x)) = cramer A (∑ x in s, f x) :=
  (LinearMap.map_sum (cramer A)).symm
#align matrix.sum_cramer Matrix.sum_cramer

/-- Use linearity of `cramer` and vector evaluation to take `cramer A _ i` out of a summation. -/
theorem sum_cramer_apply {β} (s : Finset β) (f : n → β → α) (i : n) :
    (∑ x in s, cramer A (fun j => f j x) i) = cramer A (fun j : n => ∑ x in s, f j x) i :=
  calc
    (∑ x in s, cramer A (fun j => f j x) i) = (∑ x in s, cramer A fun j => f j x) i := (Finset.sum_apply i s _).symm
    _ = cramer A (fun j : n => ∑ x in s, f j x) i := by
      rw [sum_cramer, cramer_apply]
      congr with j
      apply Finset.sum_apply
    
#align matrix.sum_cramer_apply Matrix.sum_cramer_apply

end Cramer

section Adjugate

/-!
### `adjugate` section

Define the `adjugate` matrix and a few equations.
These will hold for any matrix over a commutative ring.
-/


/-- The adjugate matrix is the transpose of the cofactor matrix.

  Typically, the cofactor matrix is defined by taking minors,
  i.e. the determinant of the matrix with a row and column removed.
  However, the proof of `mul_adjugate` becomes a lot easier if we use the
  matrix replacing a column with a basis vector, since it allows us to use
  facts about the `cramer` map.
-/
def adjugate (A : Matrix n n α) : Matrix n n α := fun i => cramer Aᵀ (Pi.single i 1)
#align matrix.adjugate Matrix.adjugate

theorem adjugate_def (A : Matrix n n α) : adjugate A = fun i => cramer Aᵀ (Pi.single i 1) :=
  rfl
#align matrix.adjugate_def Matrix.adjugate_def

theorem adjugate_apply (A : Matrix n n α) (i j : n) : adjugate A i j = (A.updateRow j (Pi.single i 1)).det := by
  rw [adjugate_def]
  simp only
  rw [cramer_apply, update_column_transpose, det_transpose]
#align matrix.adjugate_apply Matrix.adjugate_apply

theorem adjugate_transpose (A : Matrix n n α) : (adjugate A)ᵀ = adjugate Aᵀ := by
  ext (i j)
  rw [transpose_apply, adjugate_apply, adjugate_apply, update_row_transpose, det_transpose]
  rw [det_apply', det_apply']
  apply Finset.sum_congr rfl
  intro σ _
  congr 1
  by_cases i = σ j
  · -- Everything except `(i , j)` (= `(σ j , j)`) is given by A, and the rest is a single `1`.
      congr <;>
      ext j'
    subst h
    have : σ j' = σ j ↔ j' = j := σ.injective.eq_iff
    rw [update_row_apply, update_column_apply]
    simp_rw [this]
    rw [← dite_eq_ite, ← dite_eq_ite]
    congr 1 with rfl
    rw [Pi.single_eq_same, Pi.single_eq_same]
    
  · -- Otherwise, we need to show that there is a `0` somewhere in the product.
    have : (∏ j' : n, update_column A j (Pi.single i 1) (σ j') j') = 0 := by
      apply prod_eq_zero (mem_univ j)
      rw [update_column_self, Pi.single_eq_of_ne' h]
    rw [this]
    apply prod_eq_zero (mem_univ (σ⁻¹ i))
    erw [apply_symm_apply σ i, update_row_self]
    apply Pi.single_eq_of_ne
    intro h'
    exact h ((symm_apply_eq σ).mp h')
    
#align matrix.adjugate_transpose Matrix.adjugate_transpose

/-- Since the map `b ↦ cramer A b` is linear in `b`, it must be multiplication by some matrix. This
matrix is `A.adjugate`. -/
theorem cramer_eq_adjugate_mul_vec (A : Matrix n n α) (b : n → α) : cramer A b = A.adjugate.mulVec b := by
  nth_rw 1 [← A.transpose_transpose]
  rw [← adjugate_transpose, adjugate_def]
  have : b = ∑ i, b i • Pi.single i 1 := by
    refine' (pi_eq_sum_univ b).trans _
    congr with j
    simp [Pi.single_apply, eq_comm]
  nth_rw 0 [this]
  ext k
  simp [mul_vec, dot_product, mul_comm]
#align matrix.cramer_eq_adjugate_mul_vec Matrix.cramer_eq_adjugate_mul_vec

theorem mul_adjugate_apply (A : Matrix n n α) (i j k) : A i k * adjugate A k j = cramer Aᵀ (Pi.single k (A i k)) j := by
  erw [← smul_eq_mul, ← Pi.smul_apply, ← LinearMap.map_smul, ← Pi.single_smul', smul_eq_mul, mul_one]
#align matrix.mul_adjugate_apply Matrix.mul_adjugate_apply

theorem mul_adjugate (A : Matrix n n α) : A ⬝ adjugate A = A.det • 1 := by
  ext (i j)
  rw [mul_apply, Pi.smul_apply, Pi.smul_apply, one_apply, smul_eq_mul, mul_boole]
  simp [mul_adjugate_apply, sum_cramer_apply, cramer_transpose_row_self, Pi.single_apply, eq_comm]
#align matrix.mul_adjugate Matrix.mul_adjugate

theorem adjugate_mul (A : Matrix n n α) : adjugate A ⬝ A = A.det • 1 :=
  calc
    adjugate A ⬝ A = (Aᵀ ⬝ adjugate Aᵀ)ᵀ := by rw [← adjugate_transpose, ← transpose_mul, transpose_transpose]
    _ = A.det • 1 := by rw [mul_adjugate Aᵀ, det_transpose, transpose_smul, transpose_one]
    
#align matrix.adjugate_mul Matrix.adjugate_mul

theorem adjugate_smul (r : α) (A : Matrix n n α) : adjugate (r • A) = r ^ (Fintype.card n - 1) • adjugate A := by
  rw [adjugate, adjugate, transpose_smul, cramer_smul]
  rfl
#align matrix.adjugate_smul Matrix.adjugate_smul

/-- A stronger form of **Cramer's rule** that allows us to solve some instances of `A ⬝ x = b` even
if the determinant is not a unit. A sufficient (but still not necessary) condition is that `A.det`
divides `b`. -/
@[simp]
theorem mul_vec_cramer (A : Matrix n n α) (b : n → α) : A.mulVec (cramer A b) = A.det • b := by
  rw [cramer_eq_adjugate_mul_vec, mul_vec_mul_vec, mul_adjugate, smul_mul_vec_assoc, one_mul_vec]
#align matrix.mul_vec_cramer Matrix.mul_vec_cramer

theorem adjugate_subsingleton [Subsingleton n] (A : Matrix n n α) : adjugate A = 1 := by
  ext (i j)
  simp [Subsingleton.elim i j, adjugate_apply, det_eq_elem_of_subsingleton _ i]
#align matrix.adjugate_subsingleton Matrix.adjugate_subsingleton

theorem adjugate_eq_one_of_card_eq_one {A : Matrix n n α} (h : Fintype.card n = 1) : adjugate A = 1 :=
  haveI : Subsingleton n := fintype.card_le_one_iff_subsingleton.mp h.le
  adjugate_subsingleton _
#align matrix.adjugate_eq_one_of_card_eq_one Matrix.adjugate_eq_one_of_card_eq_one

@[simp]
theorem adjugate_zero [Nontrivial n] : adjugate (0 : Matrix n n α) = 0 := by
  ext (i j)
  obtain ⟨j', hj'⟩ : ∃ j', j' ≠ j := exists_ne j
  apply det_eq_zero_of_column_eq_zero j'
  intro j''
  simp [update_column_ne hj']
#align matrix.adjugate_zero Matrix.adjugate_zero

@[simp]
theorem adjugate_one : adjugate (1 : Matrix n n α) = 1 := by
  ext
  simp [adjugate_def, Matrix.one_apply, Pi.single_apply, eq_comm]
#align matrix.adjugate_one Matrix.adjugate_one

@[simp]
theorem adjugate_diagonal (v : n → α) : adjugate (diagonal v) = diagonal fun i => ∏ j in Finset.univ.erase i, v j := by
  ext
  simp only [adjugate_def, cramer_apply, diagonal_transpose]
  obtain rfl | hij := eq_or_ne i j
  · rw [diagonal_apply_eq, diagonal_update_column_single, det_diagonal, prod_update_of_mem (Finset.mem_univ _),
      sdiff_singleton_eq_erase, one_mul]
    
  · rw [diagonal_apply_ne _ hij]
    refine' det_eq_zero_of_row_eq_zero j fun k => _
    obtain rfl | hjk := eq_or_ne k j
    · rw [update_column_self, Pi.single_eq_of_ne' hij]
      
    · rw [update_column_ne hjk, diagonal_apply_ne' _ hjk]
      
    
#align matrix.adjugate_diagonal Matrix.adjugate_diagonal

theorem _root_.ring_hom.map_adjugate {R S : Type _} [CommRing R] [CommRing S] (f : R →+* S) (M : Matrix n n R) :
    f.mapMatrix M.adjugate = Matrix.adjugate (f.mapMatrix M) := by
  ext (i k)
  have : Pi.single i (1 : S) = f ∘ Pi.single i 1 := by
    rw [← f.map_one]
    exact Pi.single_op (fun i => f) (fun i => f.map_zero) i (1 : R)
  rw [adjugate_apply, RingHom.map_matrix_apply, map_apply, RingHom.map_matrix_apply, this, ← map_update_row, ←
    RingHom.map_matrix_apply, ← RingHom.map_det, ← adjugate_apply]
#align matrix._root_.ring_hom.map_adjugate matrix._root_.ring_hom.map_adjugate

theorem _root_.alg_hom.map_adjugate {R A B : Type _} [CommSemiring R] [CommRing A] [CommRing B] [Algebra R A]
    [Algebra R B] (f : A →ₐ[R] B) (M : Matrix n n A) : f.mapMatrix M.adjugate = Matrix.adjugate (f.mapMatrix M) :=
  f.toRingHom.map_adjugate _
#align matrix._root_.alg_hom.map_adjugate matrix._root_.alg_hom.map_adjugate

theorem det_adjugate (A : Matrix n n α) : (adjugate A).det = A.det ^ (Fintype.card n - 1) := by
  -- get rid of the `- 1`
  cases' (Fintype.card n).eq_zero_or_pos with h_card h_card
  · haveI : IsEmpty n := fintype.card_eq_zero_iff.mp h_card
    rw [h_card, Nat.zero_sub, pow_zero, adjugate_subsingleton, det_one]
    
  replace h_card := tsub_add_cancel_of_le h_card.nat_succ_le
  -- express `A` as an evaluation of a polynomial in n^2 variables, and solve in the polynomial ring
  -- where `A'.det` is non-zero.
  let A' := mv_polynomial_X n n ℤ
  suffices A'.adjugate.det = A'.det ^ (Fintype.card n - 1) by
    rw [← mv_polynomial_X_map_matrix_aeval ℤ A, ← AlgHom.map_adjugate, ← AlgHom.map_det, ← AlgHom.map_det, ←
      AlgHom.map_pow, this]
  apply mul_left_cancel₀ (show A'.det ≠ 0 from det_mv_polynomial_X_ne_zero n ℤ)
  calc
    A'.det * A'.adjugate.det = (A' ⬝ adjugate A').det := (det_mul _ _).symm
    _ = A'.det ^ Fintype.card n := by rw [mul_adjugate, det_smul, det_one, mul_one]
    _ = A'.det * A'.det ^ (Fintype.card n - 1) := by rw [← pow_succ, h_card]
    
#align matrix.det_adjugate Matrix.det_adjugate

@[simp]
theorem adjugate_fin_zero (A : Matrix (Fin 0) (Fin 0) α) : adjugate A = 0 :=
  Subsingleton.elim _ _
#align matrix.adjugate_fin_zero Matrix.adjugate_fin_zero

@[simp]
theorem adjugate_fin_one (A : Matrix (Fin 1) (Fin 1) α) : adjugate A = 1 :=
  adjugate_subsingleton A
#align matrix.adjugate_fin_one Matrix.adjugate_fin_one

/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr!![ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:391:14: unsupported user notation matrix.notation -/
theorem adjugate_fin_two (A : Matrix (Fin 2) (Fin 2) α) :
    adjugate A =
      «expr!![ » "./././Mathport/Syntax/Translate/Expr.lean:391:14: unsupported user notation matrix.notation" :=
  by
  ext (i j)
  rw [adjugate_apply, det_fin_two]
  fin_cases i <;>
    fin_cases j <;>
      simp only [Nat.one_ne_zero, one_mul, Fin.one_eq_zero_iff, Pi.single_eq_same, zero_mul, Fin.zero_eq_one_iff,
        sub_zero, Pi.single_eq_of_ne, Ne.def, not_false_iff, update_row_self, update_row_ne, cons_val_zero, mul_zero,
        mul_one, zero_sub, cons_val_one, head_cons, of_apply]
#align matrix.adjugate_fin_two Matrix.adjugate_fin_two

/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr!![ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:391:14: unsupported user notation matrix.notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr!![ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:391:14: unsupported user notation matrix.notation -/
@[simp]
theorem adjugate_fin_two_of (a b c d : α) :
    adjugate
        («expr!![ » "./././Mathport/Syntax/Translate/Expr.lean:391:14: unsupported user notation matrix.notation") =
      «expr!![ » "./././Mathport/Syntax/Translate/Expr.lean:391:14: unsupported user notation matrix.notation" :=
  adjugate_fin_two _
#align matrix.adjugate_fin_two_of Matrix.adjugate_fin_two_of

theorem adjugate_conj_transpose [StarRing α] (A : Matrix n n α) : A.adjugateᴴ = adjugate Aᴴ := by
  dsimp only [conj_transpose]
  have : Aᵀ.adjugate.map star = adjugate (Aᵀ.map star) := (starRingEnd α).map_adjugate Aᵀ
  rw [A.adjugate_transpose, this]
#align matrix.adjugate_conj_transpose Matrix.adjugate_conj_transpose

theorem is_regular_of_is_left_regular_det {A : Matrix n n α} (hA : IsLeftRegular A.det) : IsRegular A := by
  constructor
  · intro B C h
    refine' hA.matrix _
    rw [← Matrix.one_mul B, ← Matrix.one_mul C, ← Matrix.smul_mul, ← Matrix.smul_mul, ← adjugate_mul, Matrix.mul_assoc,
      Matrix.mul_assoc, ← mul_eq_mul A, h, mul_eq_mul]
    
  · intro B C h
    simp only [mul_eq_mul] at h
    refine' hA.matrix _
    rw [← Matrix.mul_one B, ← Matrix.mul_one C, ← Matrix.mul_smul, ← Matrix.mul_smul, ← mul_adjugate, ←
      Matrix.mul_assoc, ← Matrix.mul_assoc, h]
    
#align matrix.is_regular_of_is_left_regular_det Matrix.is_regular_of_is_left_regular_det

theorem adjugate_mul_distrib_aux (A B : Matrix n n α) (hA : IsLeftRegular A.det) (hB : IsLeftRegular B.det) :
    adjugate (A ⬝ B) = adjugate B ⬝ adjugate A := by
  have hAB : IsLeftRegular (A ⬝ B).det := by
    rw [det_mul]
    exact hA.mul hB
  refine' (is_regular_of_is_left_regular_det hAB).left _
  rw [mul_eq_mul, mul_adjugate, mul_eq_mul, Matrix.mul_assoc, ← Matrix.mul_assoc B, mul_adjugate, smul_mul,
    Matrix.one_mul, mul_smul, mul_adjugate, smul_smul, mul_comm, ← det_mul]
#align matrix.adjugate_mul_distrib_aux Matrix.adjugate_mul_distrib_aux

/-- Proof follows from "The trace Cayley-Hamilton theorem" by Darij Grinberg, Section 5.3
-/
theorem adjugate_mul_distrib (A B : Matrix n n α) : adjugate (A ⬝ B) = adjugate B ⬝ adjugate A := by
  let g : Matrix n n α → Matrix n n α[X] := fun M => M.map Polynomial.c + (Polynomial.x : α[X]) • 1
  let f' : Matrix n n α[X] →+* Matrix n n α := (Polynomial.evalRingHom 0).mapMatrix
  have f'_inv : ∀ M, f' (g M) = M := by
    intro
    ext
    simp [f', g]
  have f'_adj : ∀ M : Matrix n n α, f' (adjugate (g M)) = adjugate M := by
    intro
    rw [RingHom.map_adjugate, f'_inv]
  have f'_g_mul : ∀ M N : Matrix n n α, f' (g M ⬝ g N) = M ⬝ N := by
    intros
    rw [← mul_eq_mul, RingHom.map_mul, f'_inv, f'_inv, mul_eq_mul]
  have hu : ∀ M : Matrix n n α, IsRegular (g M).det := by
    intro M
    refine' Polynomial.Monic.is_regular _
    simp only [g, Polynomial.Monic.def, ← Polynomial.leading_coeff_det_X_one_add_C M, add_comm]
  rw [← f'_adj, ← f'_adj, ← f'_adj, ← mul_eq_mul (f' (adjugate (g B))), ← f'.map_mul, mul_eq_mul, ←
    adjugate_mul_distrib_aux _ _ (hu A).left (hu B).left, RingHom.map_adjugate, RingHom.map_adjugate, f'_inv, f'_g_mul]
#align matrix.adjugate_mul_distrib Matrix.adjugate_mul_distrib

@[simp]
theorem adjugate_pow (A : Matrix n n α) (k : ℕ) : adjugate (A ^ k) = adjugate A ^ k := by
  induction' k with k IH
  · simp
    
  · rw [pow_succ', mul_eq_mul, adjugate_mul_distrib, IH, ← mul_eq_mul, pow_succ]
    
#align matrix.adjugate_pow Matrix.adjugate_pow

theorem det_smul_adjugate_adjugate (A : Matrix n n α) :
    det A • adjugate (adjugate A) = det A ^ (Fintype.card n - 1) • A := by
  have : A ⬝ (A.adjugate ⬝ A.adjugate.adjugate) = A ⬝ (A.det ^ (Fintype.card n - 1) • 1) := by
    rw [← adjugate_mul_distrib, adjugate_mul, adjugate_smul, adjugate_one]
  rwa [← Matrix.mul_assoc, mul_adjugate, Matrix.mul_smul, Matrix.mul_one, Matrix.smul_mul, Matrix.one_mul] at this
#align matrix.det_smul_adjugate_adjugate Matrix.det_smul_adjugate_adjugate

/-- Note that this is not true for `fintype.card n = 1` since `1 - 2 = 0` and not `-1`. -/
theorem adjugate_adjugate (A : Matrix n n α) (h : Fintype.card n ≠ 1) :
    adjugate (adjugate A) = det A ^ (Fintype.card n - 2) • A := by
  -- get rid of the `- 2`
  cases' h_card : Fintype.card n with n'
  · haveI : IsEmpty n := fintype.card_eq_zero_iff.mp h_card
    apply Subsingleton.elim
    
  cases n'
  · exact (h h_card).elim
    
  rw [← h_card]
  -- express `A` as an evaluation of a polynomial in n^2 variables, and solve in the polynomial ring
  -- where `A'.det` is non-zero.
  let A' := mv_polynomial_X n n ℤ
  suffices adjugate (adjugate A') = det A' ^ (Fintype.card n - 2) • A' by
    rw [← mv_polynomial_X_map_matrix_aeval ℤ A, ← AlgHom.map_adjugate, ← AlgHom.map_adjugate, this, ← AlgHom.map_det, ←
      AlgHom.map_pow, AlgHom.map_matrix_apply, AlgHom.map_matrix_apply, Matrix.map_smul' _ _ _ (_root_.map_mul _)]
  have h_card' : Fintype.card n - 2 + 1 = Fintype.card n - 1 := by simp [h_card]
  have is_reg : IsSmulRegular (MvPolynomial (n × n) ℤ) (det A') := fun x y =>
    mul_left_cancel₀ (det_mv_polynomial_X_ne_zero n ℤ)
  apply is_reg.matrix
  rw [smul_smul, ← pow_succ, h_card', det_smul_adjugate_adjugate]
#align matrix.adjugate_adjugate Matrix.adjugate_adjugate

/-- A weaker version of `matrix.adjugate_adjugate` that uses `nontrivial`. -/
theorem adjugate_adjugate' (A : Matrix n n α) [Nontrivial n] :
    adjugate (adjugate A) = det A ^ (Fintype.card n - 2) • A :=
  adjugate_adjugate _ $ Fintype.one_lt_card.ne'
#align matrix.adjugate_adjugate' Matrix.adjugate_adjugate'

end Adjugate

end Matrix

