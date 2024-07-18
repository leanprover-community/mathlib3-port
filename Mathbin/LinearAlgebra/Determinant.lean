/-
Copyright (c) 2019 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Patrick Massot, Casper Putz, Anne Baanen
-/
import LinearAlgebra.FiniteDimensional.Defs
import LinearAlgebra.GeneralLinearGroup
import LinearAlgebra.Matrix.Reindex
import Tactic.FieldSimp
import LinearAlgebra.Matrix.NonsingularInverse
import LinearAlgebra.Matrix.Basis

#align_import linear_algebra.determinant from "leanprover-community/mathlib"@"0c1d80f5a86b36c1db32e021e8d19ae7809d5b79"

/-!
# Determinant of families of vectors

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the determinant of an endomorphism, and of a family of vectors
with respect to some basis. For the determinant of a matrix, see the file
`linear_algebra.matrix.determinant`.

## Main definitions

In the list below, and in all this file, `R` is a commutative ring (semiring
is sometimes enough), `M` and its variations are `R`-modules, `ι`, `κ`, `n` and `m` are finite
types used for indexing.

 * `basis.det`: the determinant of a family of vectors with respect to a basis,
   as a multilinear map
 * `linear_map.det`: the determinant of an endomorphism `f : End R M` as a
   multiplicative homomorphism (if `M` does not have a finite `R`-basis, the
   result is `1` instead)
 * `linear_equiv.det`: the determinant of an isomorphism `f : M ≃ₗ[R] M` as a
   multiplicative homomorphism (if `M` does not have a finite `R`-basis, the
   result is `1` instead)

## Tags

basis, det, determinant
-/


noncomputable section

open scoped BigOperators

open scoped Matrix

open LinearMap

open Submodule

universe u v w

open LinearMap Matrix Set Function

variable {R : Type _} [CommRing R]

variable {M : Type _} [AddCommGroup M] [Module R M]

variable {M' : Type _} [AddCommGroup M'] [Module R M']

variable {ι : Type _} [DecidableEq ι] [Fintype ι]

variable (e : Basis ι R M)

section Conjugate

variable {A : Type _} [CommRing A]

variable {m n : Type _} [Fintype m] [Fintype n]

#print equivOfPiLEquivPi /-
/-- If `R^m` and `R^n` are linearly equivalent, then `m` and `n` are also equivalent. -/
def equivOfPiLEquivPi {R : Type _} [CommRing R] [Nontrivial R] (e : (m → R) ≃ₗ[R] n → R) : m ≃ n :=
  Basis.indexEquiv (Basis.ofEquivFun e.symm) (Pi.basisFun _ _)
#align equiv_of_pi_lequiv_pi equivOfPiLEquivPi
-/

namespace Matrix

#print Matrix.indexEquivOfInv /-
/-- If `M` and `M'` are each other's inverse matrices, they are square matrices up to
equivalence of types. -/
def indexEquivOfInv [Nontrivial A] [DecidableEq m] [DecidableEq n] {M : Matrix m n A}
    {M' : Matrix n m A} (hMM' : M ⬝ M' = 1) (hM'M : M' ⬝ M = 1) : m ≃ n :=
  equivOfPiLEquivPi (toLin'OfInv hMM' hM'M)
#align matrix.index_equiv_of_inv Matrix.indexEquivOfInv
-/

#print Matrix.det_comm /-
theorem det_comm [DecidableEq n] (M N : Matrix n n A) : det (M ⬝ N) = det (N ⬝ M) := by
  rw [det_mul, det_mul, mul_comm]
#align matrix.det_comm Matrix.det_comm
-/

#print Matrix.det_comm' /-
/-- If there exists a two-sided inverse `M'` for `M` (indexed differently),
then `det (N ⬝ M) = det (M ⬝ N)`. -/
theorem det_comm' [DecidableEq m] [DecidableEq n] {M : Matrix n m A} {N : Matrix m n A}
    {M' : Matrix m n A} (hMM' : M ⬝ M' = 1) (hM'M : M' ⬝ M = 1) : det (M ⬝ N) = det (N ⬝ M) :=
  by
  nontriviality A
  -- Although `m` and `n` are different a priori, we will show they have the same cardinality.
  -- This turns the problem into one for square matrices, which is easy.
  let e := index_equiv_of_inv hMM' hM'M
  rw [← det_submatrix_equiv_self e, ← submatrix_mul_equiv _ _ _ (Equiv.refl n) _, det_comm,
    submatrix_mul_equiv, Equiv.coe_refl, submatrix_id_id]
#align matrix.det_comm' Matrix.det_comm'
-/

#print Matrix.det_conj_of_mul_eq_one /-
/-- If `M'` is a two-sided inverse for `M` (indexed differently), `det (M ⬝ N ⬝ M') = det N`.

See `matrix.det_conj` and `matrix.det_conj'` for the case when `M' = M⁻¹` or vice versa. -/
theorem det_conj_of_mul_eq_one [DecidableEq m] [DecidableEq n] {M : Matrix m n A}
    {M' : Matrix n m A} {N : Matrix n n A} (hMM' : M ⬝ M' = 1) (hM'M : M' ⬝ M = 1) :
    det (M ⬝ N ⬝ M') = det N := by
  rw [← det_comm' hM'M hMM', ← Matrix.mul_assoc, hM'M, Matrix.one_mul]
#align matrix.det_conj_of_mul_eq_one Matrix.det_conj_of_mul_eq_one
-/

end Matrix

end Conjugate

namespace LinearMap

/-! ### Determinant of a linear map -/


variable {A : Type _} [CommRing A] [Module A M]

variable {κ : Type _} [Fintype κ]

#print LinearMap.det_toMatrix_eq_det_toMatrix /-
/-- The determinant of `linear_map.to_matrix` does not depend on the choice of basis. -/
theorem det_toMatrix_eq_det_toMatrix [DecidableEq κ] (b : Basis ι A M) (c : Basis κ A M)
    (f : M →ₗ[A] M) : det (LinearMap.toMatrix b b f) = det (LinearMap.toMatrix c c f) := by
  rw [← linearMap_toMatrix_mul_basis_toMatrix c b c, ← basis_toMatrix_mul_linearMap_toMatrix b c b,
      Matrix.det_conj_of_mul_eq_one] <;>
    rw [Basis.toMatrix_mul_toMatrix, Basis.toMatrix_self]
#align linear_map.det_to_matrix_eq_det_to_matrix LinearMap.det_toMatrix_eq_det_toMatrix
-/

#print LinearMap.detAux /-
/-- The determinant of an endomorphism given a basis.

See `linear_map.det` for a version that populates the basis non-computably.

Although the `trunc (basis ι A M)` parameter makes it slightly more convenient to switch bases,
there is no good way to generalize over universe parameters, so we can't fully state in `det_aux`'s
type that it does not depend on the choice of basis. Instead you can use the `det_aux_def'` lemma,
or avoid mentioning a basis at all using `linear_map.det`.
-/
irreducible_def detAux : Trunc (Basis ι A M) → (M →ₗ[A] M) →* A :=
  Trunc.lift
    (fun b : Basis ι A M => detMonoidHom.comp (toMatrixAlgEquiv b : (M →ₗ[A] M) →* Matrix ι ι A))
    fun b c => MonoidHom.ext <| det_toMatrix_eq_det_toMatrix b c
#align linear_map.det_aux LinearMap.detAux
-/

#print LinearMap.detAux_def' /-
/-- Unfold lemma for `det_aux`.

See also `det_aux_def'` which allows you to vary the basis.
-/
theorem detAux_def' (b : Basis ι A M) (f : M →ₗ[A] M) :
    LinearMap.detAux (Trunc.mk b) f = Matrix.det (LinearMap.toMatrix b b f) := by rw [det_aux]; rfl
#align linear_map.det_aux_def LinearMap.detAux_def'
-/

#print LinearMap.detAux_def'' /-
theorem detAux_def'' {ι' : Type _} [Fintype ι'] [DecidableEq ι'] (tb : Trunc <| Basis ι A M)
    (b' : Basis ι' A M) (f : M →ₗ[A] M) :
    LinearMap.detAux tb f = Matrix.det (LinearMap.toMatrix b' b' f) := by
  apply Trunc.induction_on tb; intro b; rw [det_aux_def, det_to_matrix_eq_det_to_matrix b b']
#align linear_map.det_aux_def' LinearMap.detAux_def''
-/

#print LinearMap.detAux_id /-
@[simp]
theorem detAux_id (b : Trunc <| Basis ι A M) : LinearMap.detAux b LinearMap.id = 1 :=
  (LinearMap.detAux b).map_one
#align linear_map.det_aux_id LinearMap.detAux_id
-/

#print LinearMap.detAux_comp /-
@[simp]
theorem detAux_comp (b : Trunc <| Basis ι A M) (f g : M →ₗ[A] M) :
    LinearMap.detAux b (f.comp g) = LinearMap.detAux b f * LinearMap.detAux b g :=
  (LinearMap.detAux b).map_hMul f g
#align linear_map.det_aux_comp LinearMap.detAux_comp
-/

section

open scoped Classical

#print LinearMap.det /-
-- Discourage the elaborator from unfolding `det` and producing a huge term by marking it
-- as irreducible.
/-- The determinant of an endomorphism independent of basis.

If there is no finite basis on `M`, the result is `1` instead.
-/
protected irreducible_def det : (M →ₗ[A] M) →* A :=
  if H : ∃ s : Finset M, Nonempty (Basis s A M) then LinearMap.detAux (Trunc.mk H.choose_spec.some)
  else 1
#align linear_map.det LinearMap.det
-/

#print LinearMap.coe_det /-
theorem coe_det [DecidableEq M] :
    ⇑(LinearMap.det : (M →ₗ[A] M) →* A) =
      if H : ∃ s : Finset M, Nonempty (Basis s A M) then
        LinearMap.detAux (Trunc.mk H.choose_spec.some)
      else 1 :=
  by
  ext; unfold LinearMap.det
  split_ifs
  · congr
  -- use the correct `decidable_eq` instance
  rfl
#align linear_map.coe_det LinearMap.coe_det
-/

end

#print LinearMap.det_eq_det_toMatrix_of_finset /-
-- Auxiliary lemma, the `simp` normal form goes in the other direction
-- (using `linear_map.det_to_matrix`)
theorem det_eq_det_toMatrix_of_finset [DecidableEq M] {s : Finset M} (b : Basis s A M)
    (f : M →ₗ[A] M) : f.det = Matrix.det (LinearMap.toMatrix b b f) :=
  by
  have : ∃ s : Finset M, Nonempty (Basis s A M) := ⟨s, ⟨b⟩⟩
  rw [LinearMap.coe_det, dif_pos, det_aux_def' _ b] <;> assumption
#align linear_map.det_eq_det_to_matrix_of_finset LinearMap.det_eq_det_toMatrix_of_finset
-/

#print LinearMap.det_toMatrix /-
@[simp]
theorem det_toMatrix (b : Basis ι A M) (f : M →ₗ[A] M) : Matrix.det (toMatrix b b f) = f.det :=
  by
  haveI := Classical.decEq M
  rw [det_eq_det_to_matrix_of_finset b.reindex_finset_range, det_to_matrix_eq_det_to_matrix b]
#align linear_map.det_to_matrix LinearMap.det_toMatrix
-/

#print LinearMap.det_toMatrix' /-
@[simp]
theorem det_toMatrix' {ι : Type _} [Fintype ι] [DecidableEq ι] (f : (ι → A) →ₗ[A] ι → A) :
    det f.toMatrix' = f.det := by simp [← to_matrix_eq_to_matrix']
#align linear_map.det_to_matrix' LinearMap.det_toMatrix'
-/

#print LinearMap.det_toLin /-
@[simp]
theorem det_toLin (b : Basis ι R M) (f : Matrix ι ι R) :
    LinearMap.det (Matrix.toLin b b f) = f.det := by
  rw [← LinearMap.det_toMatrix b, LinearMap.toMatrix_toLin]
#align linear_map.det_to_lin LinearMap.det_toLin
-/

#print LinearMap.det_toLin' /-
@[simp]
theorem det_toLin' (f : Matrix ι ι R) : LinearMap.det f.toLin' = f.det := by
  simp only [← to_lin_eq_to_lin', det_to_lin]
#align linear_map.det_to_lin' LinearMap.det_toLin'
-/

#print LinearMap.det_cases /-
/-- To show `P f.det` it suffices to consider `P (to_matrix _ _ f).det` and `P 1`. -/
@[elab_as_elim]
theorem det_cases [DecidableEq M] {P : A → Prop} (f : M →ₗ[A] M)
    (hb : ∀ (s : Finset M) (b : Basis s A M), P (toMatrix b b f).det) (h1 : P 1) : P f.det :=
  by
  unfold LinearMap.det
  split_ifs with h
  · convert hb _ h.some_spec.some
    apply det_aux_def'
  · exact h1
#align linear_map.det_cases LinearMap.det_cases
-/

#print LinearMap.det_comp /-
@[simp]
theorem det_comp (f g : M →ₗ[A] M) : (f.comp g).det = f.det * g.det :=
  LinearMap.det.map_hMul f g
#align linear_map.det_comp LinearMap.det_comp
-/

#print LinearMap.det_id /-
@[simp]
theorem det_id : (LinearMap.id : M →ₗ[A] M).det = 1 :=
  LinearMap.det.map_one
#align linear_map.det_id LinearMap.det_id
-/

#print LinearMap.det_smul /-
/-- Multiplying a map by a scalar `c` multiplies its determinant by `c ^ dim M`. -/
@[simp]
theorem det_smul {𝕜 : Type _} [Field 𝕜] {M : Type _} [AddCommGroup M] [Module 𝕜 M] (c : 𝕜)
    (f : M →ₗ[𝕜] M) : LinearMap.det (c • f) = c ^ FiniteDimensional.finrank 𝕜 M * LinearMap.det f :=
  by
  by_cases H : ∃ s : Finset M, Nonempty (Basis s 𝕜 M)
  · have : FiniteDimensional 𝕜 M := by rcases H with ⟨s, ⟨hs⟩⟩;
      exact FiniteDimensional.of_fintype_basis hs
    simp only [← det_to_matrix (FiniteDimensional.finBasis 𝕜 M), LinearEquiv.map_smul,
      Fintype.card_fin, det_smul]
  ·
    classical
    have : FiniteDimensional.finrank 𝕜 M = 0 := finrank_eq_zero_of_not_exists_basis H
    simp [coe_det, H, this]
#align linear_map.det_smul LinearMap.det_smul
-/

#print LinearMap.det_zero' /-
theorem det_zero' {ι : Type _} [Finite ι] [Nonempty ι] (b : Basis ι A M) :
    LinearMap.det (0 : M →ₗ[A] M) = 0 :=
  by
  haveI := Classical.decEq ι; cases nonempty_fintype ι
  rwa [← det_to_matrix b, LinearEquiv.map_zero, det_zero]
#align linear_map.det_zero' LinearMap.det_zero'
-/

#print LinearMap.det_zero /-
/-- In a finite-dimensional vector space, the zero map has determinant `1` in dimension `0`,
and `0` otherwise. We give a formula that also works in infinite dimension, where we define
the determinant to be `1`. -/
@[simp]
theorem det_zero {𝕜 : Type _} [Field 𝕜] {M : Type _} [AddCommGroup M] [Module 𝕜 M] :
    LinearMap.det (0 : M →ₗ[𝕜] M) = (0 : 𝕜) ^ FiniteDimensional.finrank 𝕜 M := by
  simp only [← zero_smul 𝕜 (1 : M →ₗ[𝕜] M), det_smul, mul_one, MonoidHom.map_one]
#align linear_map.det_zero LinearMap.det_zero
-/

#print LinearMap.det_eq_one_of_subsingleton /-
theorem det_eq_one_of_subsingleton [Subsingleton M] (f : M →ₗ[R] M) : (f : M →ₗ[R] M).det = 1 :=
  by
  have b : Basis (Fin 0) R M := Basis.empty M
  rw [← f.det_to_matrix b]
  exact Matrix.det_isEmpty
#align linear_map.det_eq_one_of_subsingleton LinearMap.det_eq_one_of_subsingleton
-/

#print LinearMap.det_eq_one_of_finrank_eq_zero /-
theorem det_eq_one_of_finrank_eq_zero {𝕜 : Type _} [Field 𝕜] {M : Type _} [AddCommGroup M]
    [Module 𝕜 M] (h : FiniteDimensional.finrank 𝕜 M = 0) (f : M →ₗ[𝕜] M) :
    (f : M →ₗ[𝕜] M).det = 1 := by
  classical
  refine' @LinearMap.det_cases M _ 𝕜 _ _ _ (fun t => t = 1) f _ rfl
  intro s b
  have : IsEmpty s := by
    rw [← Fintype.card_eq_zero_iff]
    exact (FiniteDimensional.finrank_eq_card_basis b).symm.trans h
  exact Matrix.det_isEmpty
#align linear_map.det_eq_one_of_finrank_eq_zero LinearMap.det_eq_one_of_finrank_eq_zero
-/

#print LinearMap.det_conj /-
/-- Conjugating a linear map by a linear equiv does not change its determinant. -/
@[simp]
theorem det_conj {N : Type _} [AddCommGroup N] [Module A N] (f : M →ₗ[A] M) (e : M ≃ₗ[A] N) :
    LinearMap.det ((e : M →ₗ[A] N) ∘ₗ f ∘ₗ (e.symm : N →ₗ[A] M)) = LinearMap.det f := by
  classical
  by_cases H : ∃ s : Finset M, Nonempty (Basis s A M)
  · rcases H with ⟨s, ⟨b⟩⟩
    rw [← det_to_matrix b f, ← det_to_matrix (b.map e), to_matrix_comp (b.map e) b (b.map e),
      to_matrix_comp (b.map e) b b, ← Matrix.mul_assoc, Matrix.det_conj_of_mul_eq_one]
    ·
      rw [← to_matrix_comp, LinearEquiv.comp_coe, e.symm_trans_self, LinearEquiv.refl_toLinearMap,
        to_matrix_id]
    ·
      rw [← to_matrix_comp, LinearEquiv.comp_coe, e.self_trans_symm, LinearEquiv.refl_toLinearMap,
        to_matrix_id]
  · have H' : ¬∃ t : Finset N, Nonempty (Basis t A N) :=
      by
      contrapose! H
      rcases H with ⟨s, ⟨b⟩⟩
      exact ⟨_, ⟨(b.map e.symm).reindexFinsetRange⟩⟩
    simp only [coe_det, H, H', Pi.one_apply, dif_neg, not_false_iff]
#align linear_map.det_conj LinearMap.det_conj
-/

#print LinearMap.isUnit_det /-
/-- If a linear map is invertible, so is its determinant. -/
theorem isUnit_det {A : Type _} [CommRing A] [Module A M] (f : M →ₗ[A] M) (hf : IsUnit f) :
    IsUnit f.det := by
  obtain ⟨g, hg⟩ : ∃ g, f.comp g = 1 := hf.exists_right_inv
  have : LinearMap.det f * LinearMap.det g = 1 := by
    simp only [← LinearMap.det_comp, hg, MonoidHom.map_one]
  exact isUnit_of_mul_eq_one _ _ this
#align linear_map.is_unit_det LinearMap.isUnit_det
-/

#print LinearMap.finiteDimensional_of_det_ne_one /-
/-- If a linear map has determinant different from `1`, then the space is finite-dimensional. -/
theorem finiteDimensional_of_det_ne_one {𝕜 : Type _} [Field 𝕜] [Module 𝕜 M] (f : M →ₗ[𝕜] M)
    (hf : f.det ≠ 1) : FiniteDimensional 𝕜 M :=
  by
  by_cases H : ∃ s : Finset M, Nonempty (Basis s 𝕜 M)
  · rcases H with ⟨s, ⟨hs⟩⟩; exact FiniteDimensional.of_fintype_basis hs
  ·
    classical
    simp [LinearMap.coe_det, H] at hf
    exact hf.elim
#align linear_map.finite_dimensional_of_det_ne_one LinearMap.finiteDimensional_of_det_ne_one
-/

#print LinearMap.range_lt_top_of_det_eq_zero /-
/-- If the determinant of a map vanishes, then the map is not onto. -/
theorem range_lt_top_of_det_eq_zero {𝕜 : Type _} [Field 𝕜] [Module 𝕜 M] {f : M →ₗ[𝕜] M}
    (hf : f.det = 0) : f.range < ⊤ :=
  by
  have : FiniteDimensional 𝕜 M := by simp [f.finite_dimensional_of_det_ne_one, hf]
  contrapose hf
  simp only [lt_top_iff_ne_top, Classical.not_not, ← is_unit_iff_range_eq_top] at hf
  exact isUnit_iff_ne_zero.1 (f.is_unit_det hf)
#align linear_map.range_lt_top_of_det_eq_zero LinearMap.range_lt_top_of_det_eq_zero
-/

#print LinearMap.bot_lt_ker_of_det_eq_zero /-
/-- If the determinant of a map vanishes, then the map is not injective. -/
theorem bot_lt_ker_of_det_eq_zero {𝕜 : Type _} [Field 𝕜] [Module 𝕜 M] {f : M →ₗ[𝕜] M}
    (hf : f.det = 0) : ⊥ < f.ker :=
  by
  have : FiniteDimensional 𝕜 M := by simp [f.finite_dimensional_of_det_ne_one, hf]
  contrapose hf
  simp only [bot_lt_iff_ne_bot, Classical.not_not, ← is_unit_iff_ker_eq_bot] at hf
  exact isUnit_iff_ne_zero.1 (f.is_unit_det hf)
#align linear_map.bot_lt_ker_of_det_eq_zero LinearMap.bot_lt_ker_of_det_eq_zero
-/

end LinearMap

namespace LinearEquiv

#print LinearEquiv.det /-
/-- On a `linear_equiv`, the domain of `linear_map.det` can be promoted to `Rˣ`. -/
protected def det : (M ≃ₗ[R] M) →* Rˣ :=
  (Units.map (LinearMap.det : (M →ₗ[R] M) →* R)).comp
    (LinearMap.GeneralLinearGroup.generalLinearEquiv R M).symm.toMonoidHom
#align linear_equiv.det LinearEquiv.det
-/

#print LinearEquiv.coe_det /-
@[simp]
theorem coe_det (f : M ≃ₗ[R] M) : ↑f.det = LinearMap.det (f : M →ₗ[R] M) :=
  rfl
#align linear_equiv.coe_det LinearEquiv.coe_det
-/

#print LinearEquiv.coe_inv_det /-
@[simp]
theorem coe_inv_det (f : M ≃ₗ[R] M) : ↑f.det⁻¹ = LinearMap.det (f.symm : M →ₗ[R] M) :=
  rfl
#align linear_equiv.coe_inv_det LinearEquiv.coe_inv_det
-/

#print LinearEquiv.det_refl /-
@[simp]
theorem det_refl : (LinearEquiv.refl R M).det = 1 :=
  Units.ext <| LinearMap.det_id
#align linear_equiv.det_refl LinearEquiv.det_refl
-/

#print LinearEquiv.det_trans /-
@[simp]
theorem det_trans (f g : M ≃ₗ[R] M) : (f.trans g).det = g.det * f.det :=
  map_mul _ g f
#align linear_equiv.det_trans LinearEquiv.det_trans
-/

#print LinearEquiv.det_symm /-
@[simp]
theorem det_symm (f : M ≃ₗ[R] M) : f.symm.det = f.det⁻¹ :=
  map_inv _ f
#align linear_equiv.det_symm LinearEquiv.det_symm
-/

#print LinearEquiv.det_conj /-
/-- Conjugating a linear equiv by a linear equiv does not change its determinant. -/
@[simp]
theorem det_conj (f : M ≃ₗ[R] M) (e : M ≃ₗ[R] M') : ((e.symm.trans f).trans e).det = f.det := by
  rw [← Units.eq_iff, coe_det, coe_det, ← comp_coe, ← comp_coe, LinearMap.det_conj]
#align linear_equiv.det_conj LinearEquiv.det_conj
-/

end LinearEquiv

#print LinearEquiv.det_mul_det_symm /-
/-- The determinants of a `linear_equiv` and its inverse multiply to 1. -/
@[simp]
theorem LinearEquiv.det_mul_det_symm {A : Type _} [CommRing A] [Module A M] (f : M ≃ₗ[A] M) :
    (f : M →ₗ[A] M).det * (f.symm : M →ₗ[A] M).det = 1 := by simp [← LinearMap.det_comp]
#align linear_equiv.det_mul_det_symm LinearEquiv.det_mul_det_symm
-/

#print LinearEquiv.det_symm_mul_det /-
/-- The determinants of a `linear_equiv` and its inverse multiply to 1. -/
@[simp]
theorem LinearEquiv.det_symm_mul_det {A : Type _} [CommRing A] [Module A M] (f : M ≃ₗ[A] M) :
    (f.symm : M →ₗ[A] M).det * (f : M →ₗ[A] M).det = 1 := by simp [← LinearMap.det_comp]
#align linear_equiv.det_symm_mul_det LinearEquiv.det_symm_mul_det
-/

#print LinearEquiv.isUnit_det /-
-- Cannot be stated using `linear_map.det` because `f` is not an endomorphism.
theorem LinearEquiv.isUnit_det (f : M ≃ₗ[R] M') (v : Basis ι R M) (v' : Basis ι R M') :
    IsUnit (LinearMap.toMatrix v v' f).det :=
  by
  apply is_unit_det_of_left_inverse
  simpa using (LinearMap.toMatrix_comp v v' v f.symm f).symm
#align linear_equiv.is_unit_det LinearEquiv.isUnit_det
-/

#print LinearEquiv.isUnit_det' /-
/-- Specialization of `linear_equiv.is_unit_det` -/
theorem LinearEquiv.isUnit_det' {A : Type _} [CommRing A] [Module A M] (f : M ≃ₗ[A] M) :
    IsUnit (LinearMap.det (f : M →ₗ[A] M)) :=
  isUnit_of_mul_eq_one _ _ f.det_mul_det_symm
#align linear_equiv.is_unit_det' LinearEquiv.isUnit_det'
-/

#print LinearEquiv.det_coe_symm /-
/-- The determinant of `f.symm` is the inverse of that of `f` when `f` is a linear equiv. -/
theorem LinearEquiv.det_coe_symm {𝕜 : Type _} [Field 𝕜] [Module 𝕜 M] (f : M ≃ₗ[𝕜] M) :
    (f.symm : M →ₗ[𝕜] M).det = (f : M →ₗ[𝕜] M).det⁻¹ := by
  field_simp [IsUnit.ne_zero f.is_unit_det']
#align linear_equiv.det_coe_symm LinearEquiv.det_coe_symm
-/

#print LinearEquiv.ofIsUnitDet /-
/-- Builds a linear equivalence from a linear map whose determinant in some bases is a unit. -/
@[simps]
def LinearEquiv.ofIsUnitDet {f : M →ₗ[R] M'} {v : Basis ι R M} {v' : Basis ι R M'}
    (h : IsUnit (LinearMap.toMatrix v v' f).det) : M ≃ₗ[R] M'
    where
  toFun := f
  map_add' := f.map_add
  map_smul' := f.map_smul
  invFun := toLin v' v (toMatrix v v' f)⁻¹
  left_inv x :=
    calc
      toLin v' v (toMatrix v v' f)⁻¹ (f x) = toLin v v ((toMatrix v v' f)⁻¹ ⬝ toMatrix v v' f) x :=
        by rw [to_lin_mul v v' v, to_lin_to_matrix, LinearMap.comp_apply]
      _ = x := by simp [h]
  right_inv x :=
    calc
      f (toLin v' v (toMatrix v v' f)⁻¹ x) =
          toLin v' v' (toMatrix v v' f ⬝ (toMatrix v v' f)⁻¹) x :=
        by rw [to_lin_mul v' v v', LinearMap.comp_apply, to_lin_to_matrix v v']
      _ = x := by simp [h]
#align linear_equiv.of_is_unit_det LinearEquiv.ofIsUnitDet
-/

#print LinearEquiv.coe_ofIsUnitDet /-
@[simp]
theorem LinearEquiv.coe_ofIsUnitDet {f : M →ₗ[R] M'} {v : Basis ι R M} {v' : Basis ι R M'}
    (h : IsUnit (LinearMap.toMatrix v v' f).det) : (LinearEquiv.ofIsUnitDet h : M →ₗ[R] M') = f :=
  by ext x; rfl
#align linear_equiv.coe_of_is_unit_det LinearEquiv.coe_ofIsUnitDet
-/

#print LinearMap.equivOfDetNeZero /-
/-- Builds a linear equivalence from a linear map on a finite-dimensional vector space whose
determinant is nonzero. -/
@[reducible]
def LinearMap.equivOfDetNeZero {𝕜 : Type _} [Field 𝕜] {M : Type _} [AddCommGroup M] [Module 𝕜 M]
    [FiniteDimensional 𝕜 M] (f : M →ₗ[𝕜] M) (hf : LinearMap.det f ≠ 0) : M ≃ₗ[𝕜] M :=
  have :
    IsUnit
      (LinearMap.toMatrix (FiniteDimensional.finBasis 𝕜 M) (FiniteDimensional.finBasis 𝕜 M)
          f).det :=
    by simp only [LinearMap.det_toMatrix, isUnit_iff_ne_zero.2 hf]
  LinearEquiv.ofIsUnitDet this
#align linear_map.equiv_of_det_ne_zero LinearMap.equivOfDetNeZero
-/

#print LinearMap.associated_det_of_eq_comp /-
theorem LinearMap.associated_det_of_eq_comp (e : M ≃ₗ[R] M) (f f' : M →ₗ[R] M)
    (h : ∀ x, f x = f' (e x)) : Associated f.det f'.det :=
  by
  suffices Associated (f' ∘ₗ ↑e).det f'.det by convert this using 2; ext x; exact h x
  rw [← mul_one f'.det, LinearMap.det_comp]
  exact Associated.mul_left _ (associated_one_iff_is_unit.mpr e.is_unit_det')
#align linear_map.associated_det_of_eq_comp LinearMap.associated_det_of_eq_comp
-/

#print LinearMap.associated_det_comp_equiv /-
theorem LinearMap.associated_det_comp_equiv {N : Type _} [AddCommGroup N] [Module R N]
    (f : N →ₗ[R] M) (e e' : M ≃ₗ[R] N) : Associated (f ∘ₗ ↑e).det (f ∘ₗ ↑e').det :=
  by
  refine' LinearMap.associated_det_of_eq_comp (e.trans e'.symm) _ _ _
  intro x
  simp only [LinearMap.comp_apply, LinearEquiv.coe_coe, LinearEquiv.trans_apply,
    LinearEquiv.apply_symm_apply]
#align linear_map.associated_det_comp_equiv LinearMap.associated_det_comp_equiv
-/

#print Basis.det /-
/-- The determinant of a family of vectors with respect to some basis, as an alternating
multilinear map. -/
def Basis.det : AlternatingMap R M R ι
    where
  toFun v := det (e.toMatrix v)
  map_add' := by
    intro inst v i x y
    cases Subsingleton.elim inst ‹_›
    simp only [e.to_matrix_update, LinearEquiv.map_add, Finsupp.coe_add]
    exact det_update_column_add _ _ _ _
  map_smul' := by
    intro inst u i c x
    cases Subsingleton.elim inst ‹_›
    simp only [e.to_matrix_update, Algebra.id.smul_eq_mul, LinearEquiv.map_smul]
    apply det_update_column_smul
  map_eq_zero_of_eq' := by
    intro v i j h hij
    rw [← Function.update_eq_self i v, h, ← det_transpose, e.to_matrix_update, ←
      update_row_transpose, ← e.to_matrix_transpose_apply]
    apply det_zero_of_row_eq hij
    rw [update_row_ne hij.symm, update_row_self]
#align basis.det Basis.det
-/

#print Basis.det_apply /-
theorem Basis.det_apply (v : ι → M) : e.det v = det (e.toMatrix v) :=
  rfl
#align basis.det_apply Basis.det_apply
-/

#print Basis.det_self /-
theorem Basis.det_self : e.det e = 1 := by simp [e.det_apply]
#align basis.det_self Basis.det_self
-/

#print Basis.det_isEmpty /-
@[simp]
theorem Basis.det_isEmpty [IsEmpty ι] : e.det = AlternatingMap.constOfIsEmpty R M ι 1 :=
  by
  ext v
  exact Matrix.det_isEmpty
#align basis.det_is_empty Basis.det_isEmpty
-/

#print Basis.det_ne_zero /-
/-- `basis.det` is not the zero map. -/
theorem Basis.det_ne_zero [Nontrivial R] : e.det ≠ 0 := fun h => by simpa [h] using e.det_self
#align basis.det_ne_zero Basis.det_ne_zero
-/

#print is_basis_iff_det /-
theorem is_basis_iff_det {v : ι → M} :
    LinearIndependent R v ∧ span R (Set.range v) = ⊤ ↔ IsUnit (e.det v) :=
  by
  constructor
  · rintro ⟨hli, hspan⟩
    set v' := Basis.mk hli hspan.ge with v'_eq
    rw [e.det_apply]
    convert LinearEquiv.isUnit_det (LinearEquiv.refl _ _) v' e using 2
    ext i j
    simp
  · intro h
    rw [Basis.det_apply, Basis.toMatrix_eq_toMatrix_constr] at h
    set v' := Basis.map e (LinearEquiv.ofIsUnitDet h) with v'_def
    have : ⇑v' = v := by ext i;
      rw [v'_def, Basis.map_apply, LinearEquiv.ofIsUnitDet_apply, e.constr_basis]
    rw [← this]
    exact ⟨v'.linear_independent, v'.span_eq⟩
#align is_basis_iff_det is_basis_iff_det
-/

#print Basis.isUnit_det /-
theorem Basis.isUnit_det (e' : Basis ι R M) : IsUnit (e.det e') :=
  (is_basis_iff_det e).mp ⟨e'.LinearIndependent, e'.span_eq⟩
#align basis.is_unit_det Basis.isUnit_det
-/

#print AlternatingMap.eq_smul_basis_det /-
/-- Any alternating map to `R` where `ι` has the cardinality of a basis equals the determinant
map with respect to that basis, multiplied by the value of that alternating map on that basis. -/
theorem AlternatingMap.eq_smul_basis_det (f : AlternatingMap R M R ι) : f = f e • e.det :=
  by
  refine' Basis.ext_alternating e fun i h => _
  let σ : Equiv.Perm ι := Equiv.ofBijective i (Finite.injective_iff_bijective.1 h)
  change f (e ∘ σ) = (f e • e.det) (e ∘ σ)
  simp [AlternatingMap.map_perm, Basis.det_self]
#align alternating_map.eq_smul_basis_det AlternatingMap.eq_smul_basis_det
-/

#print AlternatingMap.map_basis_eq_zero_iff /-
@[simp]
theorem AlternatingMap.map_basis_eq_zero_iff {ι : Type _} [Finite ι] (e : Basis ι R M)
    (f : AlternatingMap R M R ι) : f e = 0 ↔ f = 0 :=
  ⟨fun h => by
    cases nonempty_fintype ι
    letI := Classical.decEq ι
    simpa [h] using f.eq_smul_basis_det e, fun h => h.symm ▸ AlternatingMap.zero_apply _⟩
#align alternating_map.map_basis_eq_zero_iff AlternatingMap.map_basis_eq_zero_iff
-/

#print AlternatingMap.map_basis_ne_zero_iff /-
theorem AlternatingMap.map_basis_ne_zero_iff {ι : Type _} [Finite ι] (e : Basis ι R M)
    (f : AlternatingMap R M R ι) : f e ≠ 0 ↔ f ≠ 0 :=
  not_congr <| f.map_basis_eq_zero_iff e
#align alternating_map.map_basis_ne_zero_iff AlternatingMap.map_basis_ne_zero_iff
-/

variable {A : Type _} [CommRing A] [Module A M]

#print Basis.det_comp /-
@[simp]
theorem Basis.det_comp (e : Basis ι A M) (f : M →ₗ[A] M) (v : ι → M) :
    e.det (f ∘ v) = f.det * e.det v := by
  rw [Basis.det_apply, Basis.det_apply, ← f.det_to_matrix e, ← Matrix.det_mul,
    e.to_matrix_eq_to_matrix_constr (f ∘ v), e.to_matrix_eq_to_matrix_constr v, ← to_matrix_comp,
    e.constr_comp]
#align basis.det_comp Basis.det_comp
-/

#print Basis.det_comp_basis /-
@[simp]
theorem Basis.det_comp_basis [Module A M'] (b : Basis ι A M) (b' : Basis ι A M') (f : M →ₗ[A] M') :
    b'.det (f ∘ b) = LinearMap.det (f ∘ₗ (b'.Equiv b (Equiv.refl ι) : M' →ₗ[A] M)) :=
  by
  rw [Basis.det_apply, ← LinearMap.det_toMatrix b', LinearMap.toMatrix_comp _ b, Matrix.det_mul,
    LinearMap.toMatrix_basis_equiv, Matrix.det_one, mul_one]
  congr 1; ext i j
  rw [Basis.toMatrix_apply, LinearMap.toMatrix_apply]
#align basis.det_comp_basis Basis.det_comp_basis
-/

#print Basis.det_reindex /-
theorem Basis.det_reindex {ι' : Type _} [Fintype ι'] [DecidableEq ι'] (b : Basis ι R M) (v : ι' → M)
    (e : ι ≃ ι') : (b.reindex e).det v = b.det (v ∘ e) := by
  rw [Basis.det_apply, Basis.toMatrix_reindex', det_reindex_alg_equiv, Basis.det_apply]
#align basis.det_reindex Basis.det_reindex
-/

#print Basis.det_reindex' /-
theorem Basis.det_reindex' {ι' : Type _} [Fintype ι'] [DecidableEq ι'] (b : Basis ι R M)
    (e : ι ≃ ι') : (b.reindex e).det = b.det.domDomCongr e :=
  AlternatingMap.ext fun _ => Basis.det_reindex _ _ _
#align basis.det_reindex' Basis.det_reindex'
-/

#print Basis.det_reindex_symm /-
theorem Basis.det_reindex_symm {ι' : Type _} [Fintype ι'] [DecidableEq ι'] (b : Basis ι R M)
    (v : ι → M) (e : ι' ≃ ι) : (b.reindex e.symm).det (v ∘ e) = b.det v := by
  rw [Basis.det_reindex, Function.comp.assoc, e.self_comp_symm, Function.comp_id]
#align basis.det_reindex_symm Basis.det_reindex_symm
-/

#print Basis.det_map /-
@[simp]
theorem Basis.det_map (b : Basis ι R M) (f : M ≃ₗ[R] M') (v : ι → M') :
    (b.map f).det v = b.det (f.symm ∘ v) := by
  rw [Basis.det_apply, Basis.toMatrix_map, Basis.det_apply]
#align basis.det_map Basis.det_map
-/

#print Basis.det_map' /-
theorem Basis.det_map' (b : Basis ι R M) (f : M ≃ₗ[R] M') :
    (b.map f).det = b.det.compLinearMap f.symm :=
  AlternatingMap.ext <| b.det_map f
#align basis.det_map' Basis.det_map'
-/

#print Pi.basisFun_det /-
@[simp]
theorem Pi.basisFun_det : (Pi.basisFun R ι).det = Matrix.detRowAlternating :=
  by
  ext M
  rw [Basis.det_apply, Basis.coePiBasisFun.toMatrix_eq_transpose, det_transpose]
#align pi.basis_fun_det Pi.basisFun_det
-/

#print Basis.det_smul_mk_coord_eq_det_update /-
/-- If we fix a background basis `e`, then for any other basis `v`, we can characterise the
coordinates provided by `v` in terms of determinants relative to `e`. -/
theorem Basis.det_smul_mk_coord_eq_det_update {v : ι → M} (hli : LinearIndependent R v)
    (hsp : ⊤ ≤ span R (range v)) (i : ι) :
    e.det v • (Basis.mk hli hsp).Coord i = e.det.toMultilinearMap.toLinearMap v i :=
  by
  apply (Basis.mk hli hsp).ext
  intro k
  rcases eq_or_ne k i with (rfl | hik) <;>
    simp only [Algebra.id.smul_eq_mul, Basis.coe_mk, LinearMap.smul_apply, LinearMap.coe_mk,
      MultilinearMap.toLinearMap_apply]
  · rw [Basis.mk_coord_apply_eq, mul_one, update_eq_self]; congr
  · rw [Basis.mk_coord_apply_ne hik, MulZeroClass.mul_zero, eq_comm]
    exact e.det.map_eq_zero_of_eq _ (by simp [hik, Function.update_apply]) hik
#align basis.det_smul_mk_coord_eq_det_update Basis.det_smul_mk_coord_eq_det_update
-/

#print Basis.det_unitsSMul /-
/-- If a basis is multiplied columnwise by scalars `w : ι → Rˣ`, then the determinant with respect
to this basis is multiplied by the product of the inverse of these scalars. -/
theorem Basis.det_unitsSMul (e : Basis ι R M) (w : ι → Rˣ) :
    (e.units_smul w).det = (↑(∏ i, w i)⁻¹ : R) • e.det :=
  by
  ext f
  change
    (Matrix.det fun i j => (e.units_smul w).repr (f j) i) =
      (↑(∏ i, w i)⁻¹ : R) • Matrix.det fun i j => e.repr (f j) i
  simp only [e.repr_units_smul]
  convert Matrix.det_mul_column (fun i => (↑(w i)⁻¹ : R)) fun i j => e.repr (f j) i
  simp [← Finset.prod_inv_distrib]
#align basis.det_units_smul Basis.det_unitsSMul
-/

#print Basis.det_unitsSMul_self /-
/-- The determinant of a basis constructed by `units_smul` is the product of the given units. -/
@[simp]
theorem Basis.det_unitsSMul_self (w : ι → Rˣ) : e.det (e.units_smul w) = ∏ i, w i := by
  simp [Basis.det_apply]
#align basis.det_units_smul_self Basis.det_unitsSMul_self
-/

#print Basis.det_isUnitSMul /-
/-- The determinant of a basis constructed by `is_unit_smul` is the product of the given units. -/
@[simp]
theorem Basis.det_isUnitSMul {w : ι → R} (hw : ∀ i, IsUnit (w i)) :
    e.det (e.isUnitSMul hw) = ∏ i, w i :=
  e.det_unitsSMul_self _
#align basis.det_is_unit_smul Basis.det_isUnitSMul
-/

