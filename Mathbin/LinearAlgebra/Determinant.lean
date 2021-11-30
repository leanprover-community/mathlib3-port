import Mathbin.LinearAlgebra.Multilinear.Basis 
import Mathbin.LinearAlgebra.Matrix.Reindex 
import Mathbin.RingTheory.AlgebraTower 
import Mathbin.LinearAlgebra.Matrix.NonsingularInverse 
import Mathbin.LinearAlgebra.Matrix.Basis

/-!
# Determinant of families of vectors

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

## Tags

basis, det, determinant
-/


noncomputable theory

open_locale BigOperators

open_locale Matrix

open LinearMap

open Submodule

universe u v w

open LinearMap Matrix Set Function

variable {R : Type _} [CommRingₓ R]

variable {M : Type _} [AddCommGroupₓ M] [Module R M]

variable {M' : Type _} [AddCommGroupₓ M'] [Module R M']

variable {ι : Type _} [DecidableEq ι] [Fintype ι]

variable (e : Basis ι R M)

section Conjugate

variable {A : Type _} [CommRingₓ A]

variable {m n : Type _} [Fintype m] [Fintype n]

/-- If `R^m` and `R^n` are linearly equivalent, then `m` and `n` are also equivalent. -/
def equivOfPiLequivPi {R : Type _} [CommRingₓ R] [IsDomain R] (e : (m → R) ≃ₗ[R] n → R) : m ≃ n :=
  Basis.indexEquiv (Basis.ofEquivFun e.symm) (Pi.basisFun _ _)

namespace Matrix

/-- If `M` and `M'` are each other's inverse matrices, they are square matrices up to
equivalence of types. -/
def index_equiv_of_inv [IsDomain A] [DecidableEq m] [DecidableEq n] {M : Matrix m n A} {M' : Matrix n m A}
  (hMM' : M ⬝ M' = 1) (hM'M : M' ⬝ M = 1) : m ≃ n :=
  equivOfPiLequivPi (to_lin'_of_inv hMM' hM'M)

theorem det_comm [DecidableEq n] (M N : Matrix n n A) : det (M ⬝ N) = det (N ⬝ M) :=
  by 
    rw [det_mul, det_mul, mul_commₓ]

/-- If there exists a two-sided inverse `M'` for `M` (indexed differently),
then `det (N ⬝ M) = det (M ⬝ N)`. -/
theorem det_comm' [IsDomain A] [DecidableEq m] [DecidableEq n] {M : Matrix n m A} {N : Matrix m n A} {M' : Matrix m n A}
  (hMM' : M ⬝ M' = 1) (hM'M : M' ⬝ M = 1) : det (M ⬝ N) = det (N ⬝ M) :=
  let e := index_equiv_of_inv hMM' hM'M 
  by 
    rw [←det_minor_equiv_self e, minor_mul_equiv _ _ _ (Equiv.refl n) _, det_comm, ←minor_mul_equiv, Equiv.coe_refl,
      minor_id_id]

/-- If `M'` is a two-sided inverse for `M` (indexed differently), `det (M ⬝ N ⬝ M') = det N`. -/
theorem det_conj [IsDomain A] [DecidableEq m] [DecidableEq n] {M : Matrix m n A} {M' : Matrix n m A} {N : Matrix n n A}
  (hMM' : M ⬝ M' = 1) (hM'M : M' ⬝ M = 1) : det (M ⬝ N ⬝ M') = det N :=
  by 
    rw [←det_comm' hM'M hMM', ←Matrix.mul_assoc, hM'M, Matrix.one_mul]

end Matrix

end Conjugate

namespace LinearMap

/-! ### Determinant of a linear map -/


variable {A : Type _} [CommRingₓ A] [IsDomain A] [Module A M]

variable {κ : Type _} [Fintype κ]

/-- The determinant of `linear_map.to_matrix` does not depend on the choice of basis. -/
theorem det_to_matrix_eq_det_to_matrix [DecidableEq κ] (b : Basis ι A M) (c : Basis κ A M) (f : M →ₗ[A] M) :
  det (LinearMap.toMatrix b b f) = det (LinearMap.toMatrix c c f) :=
  by 
    rw [←linear_map_to_matrix_mul_basis_to_matrix c b c, ←basis_to_matrix_mul_linear_map_to_matrix b c b,
        Matrix.det_conj] <;>
      rw [Basis.to_matrix_mul_to_matrix, Basis.to_matrix_self]

/-- The determinant of an endomorphism given a basis.

See `linear_map.det` for a version that populates the basis non-computably.

Although the `trunc (basis ι A M)` parameter makes it slightly more convenient to switch bases,
there is no good way to generalize over universe parameters, so we can't fully state in `det_aux`'s
type that it does not depend on the choice of basis. Instead you can use the `det_aux_def'` lemma,
or avoid mentioning a basis at all using `linear_map.det`.
-/
def det_aux : Trunc (Basis ι A M) → (M →ₗ[A] M) →* A :=
  Trunc.lift (fun b : Basis ι A M => det_monoid_hom.comp (to_matrix_alg_equiv b : (M →ₗ[A] M) →* Matrix ι ι A))
    fun b c => MonoidHom.ext$ det_to_matrix_eq_det_to_matrix b c

/-- Unfold lemma for `det_aux`.

See also `det_aux_def'` which allows you to vary the basis.
-/
theorem det_aux_def (b : Basis ι A M) (f : M →ₗ[A] M) :
  LinearMap.detAux (Trunc.mk b) f = Matrix.det (LinearMap.toMatrix b b f) :=
  rfl

theorem det_aux_def' {ι' : Type _} [Fintype ι'] [DecidableEq ι'] (tb : Trunc$ Basis ι A M) (b' : Basis ι' A M)
  (f : M →ₗ[A] M) : LinearMap.detAux tb f = Matrix.det (LinearMap.toMatrix b' b' f) :=
  by 
    apply Trunc.induction_on tb 
    intro b 
    rw [det_aux_def, det_to_matrix_eq_det_to_matrix b b']

@[simp]
theorem det_aux_id (b : Trunc$ Basis ι A M) : LinearMap.detAux b LinearMap.id = 1 :=
  (LinearMap.detAux b).map_one

@[simp]
theorem det_aux_comp (b : Trunc$ Basis ι A M) (f g : M →ₗ[A] M) :
  LinearMap.detAux b (f.comp g) = LinearMap.detAux b f*LinearMap.detAux b g :=
  (LinearMap.detAux b).map_mul f g

section 

open_locale Classical

/-- The determinant of an endomorphism independent of basis.

If there is no finite basis on `M`, the result is `1` instead.
-/
protected irreducible_def det : (M →ₗ[A] M) →* A :=
  if H : ∃ s : Finset M, Nonempty (Basis s A M) then LinearMap.detAux (Trunc.mk H.some_spec.some) else 1

theorem coe_det [DecidableEq M] :
  «expr⇑ » (LinearMap.det : (M →ₗ[A] M) →* A) =
    if H : ∃ s : Finset M, Nonempty (Basis s A M) then LinearMap.detAux (Trunc.mk H.some_spec.some) else 1 :=
  by 
    ext 
    unfold LinearMap.det 
    splitIfs
    ·
      congr 
    rfl

end 

theorem det_eq_det_to_matrix_of_finset [DecidableEq M] {s : Finset M} (b : Basis s A M) (f : M →ₗ[A] M) :
  f.det = Matrix.det (LinearMap.toMatrix b b f) :=
  have  : ∃ s : Finset M, Nonempty (Basis s A M) := ⟨s, ⟨b⟩⟩
  by 
    rw [LinearMap.coe_det, dif_pos, det_aux_def' _ b] <;> assumption

-- error in LinearAlgebra.Determinant: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem det_to_matrix (b : basis ι A M) (f : «expr →ₗ[ ] »(M, A, M)) : «expr = »(matrix.det (to_matrix b b f), f.det) :=
by { haveI [] [] [":=", expr classical.dec_eq M],
  rw ["[", expr det_eq_det_to_matrix_of_finset b.reindex_finset_range, ",", expr det_to_matrix_eq_det_to_matrix b, "]"] [] }

@[simp]
theorem det_to_matrix' {ι : Type _} [Fintype ι] [DecidableEq ι] (f : (ι → A) →ₗ[A] ι → A) : det f.to_matrix' = f.det :=
  by 
    simp [←to_matrix_eq_to_matrix']

/-- To show `P f.det` it suffices to consider `P (to_matrix _ _ f).det` and `P 1`. -/
@[elab_as_eliminator]
theorem det_cases [DecidableEq M] {P : A → Prop} (f : M →ₗ[A] M)
  (hb : ∀ s : Finset M b : Basis s A M, P (to_matrix b b f).det) (h1 : P 1) : P f.det :=
  by 
    unfold LinearMap.det 
    splitIfs with h
    ·
      convert hb _ h.some_spec.some 
      apply det_aux_def'
    ·
      exact h1

@[simp]
theorem det_comp (f g : M →ₗ[A] M) : (f.comp g).det = f.det*g.det :=
  LinearMap.det.map_mul f g

@[simp]
theorem det_id : (LinearMap.id : M →ₗ[A] M).det = 1 :=
  LinearMap.det.map_one

-- error in LinearAlgebra.Determinant: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Multiplying a map by a scalar `c` multiplies its determinant by `c ^ dim M`. -/
@[simp]
theorem det_smul
{𝕜 : Type*}
[field 𝕜]
{M : Type*}
[add_comm_group M]
[module 𝕜 M]
(c : 𝕜)
(f : «expr →ₗ[ ] »(M, 𝕜, M)) : «expr = »(linear_map.det «expr • »(c, f), «expr * »(«expr ^ »(c, finite_dimensional.finrank 𝕜 M), linear_map.det f)) :=
begin
  by_cases [expr H, ":", expr «expr∃ , »((s : finset M), nonempty (basis s 𝕜 M))],
  { haveI [] [":", expr finite_dimensional 𝕜 M] [],
    { rcases [expr H, "with", "⟨", ident s, ",", "⟨", ident hs, "⟩", "⟩"],
      exact [expr finite_dimensional.of_finset_basis hs] },
    simp [] [] ["only"] ["[", "<-", expr det_to_matrix (finite_dimensional.fin_basis 𝕜 M), ",", expr linear_equiv.map_smul, ",", expr fintype.card_fin, ",", expr det_smul, "]"] [] [] },
  { classical,
    have [] [":", expr «expr = »(finite_dimensional.finrank 𝕜 M, 0)] [":=", expr finrank_eq_zero_of_not_exists_basis H],
    simp [] [] [] ["[", expr coe_det, ",", expr H, ",", expr this, "]"] [] [] }
end

-- error in LinearAlgebra.Determinant: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem det_zero'
{ι : Type*}
[fintype ι]
[nonempty ι]
(b : basis ι A M) : «expr = »(linear_map.det (0 : «expr →ₗ[ ] »(M, A, M)), 0) :=
by { haveI [] [] [":=", expr classical.dec_eq ι],
  rw ["[", "<-", expr det_to_matrix b, ",", expr linear_equiv.map_zero, ",", expr det_zero, "]"] [],
  assumption }

/-- In a finite-dimensional vector space, the zero map has determinant `1` in dimension `0`,
and `0` otherwise. -/
@[simp]
theorem det_zero {𝕜 : Type _} [Field 𝕜] {M : Type _} [AddCommGroupₓ M] [Module 𝕜 M] :
  LinearMap.det (0 : M →ₗ[𝕜] M) = ((0 : 𝕜)^FiniteDimensional.finrank 𝕜 M) :=
  by 
    simp only [←zero_smul 𝕜 (1 : M →ₗ[𝕜] M), det_smul, mul_oneₓ, MonoidHom.map_one]

-- error in LinearAlgebra.Determinant: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Conjugating a linear map by a linear equiv does not change its determinant. -/
@[simp]
theorem det_conj
{N : Type*}
[add_comm_group N]
[module A N]
(f : «expr →ₗ[ ] »(M, A, M))
(e : «expr ≃ₗ[ ] »(M, A, N)) : «expr = »(linear_map.det «expr ∘ₗ »((e : «expr →ₗ[ ] »(M, A, N)), «expr ∘ₗ »(f, (e.symm : «expr →ₗ[ ] »(N, A, M)))), linear_map.det f) :=
begin
  classical,
  by_cases [expr H, ":", expr «expr∃ , »((s : finset M), nonempty (basis s A M))],
  { rcases [expr H, "with", "⟨", ident s, ",", "⟨", ident b, "⟩", "⟩"],
    rw ["[", "<-", expr det_to_matrix b f, ",", "<-", expr det_to_matrix (b.map e), ",", expr to_matrix_comp (b.map e) b (b.map e), ",", expr to_matrix_comp (b.map e) b b, ",", "<-", expr matrix.mul_assoc, ",", expr matrix.det_conj, "]"] [],
    { rw ["[", "<-", expr to_matrix_comp, ",", expr linear_equiv.comp_coe, ",", expr e.symm_trans_self, ",", expr linear_equiv.refl_to_linear_map, ",", expr to_matrix_id, "]"] [] },
    { rw ["[", "<-", expr to_matrix_comp, ",", expr linear_equiv.comp_coe, ",", expr e.self_trans_symm, ",", expr linear_equiv.refl_to_linear_map, ",", expr to_matrix_id, "]"] [] } },
  { have [ident H'] [":", expr «expr¬ »(«expr∃ , »((t : finset N), nonempty (basis t A N)))] [],
    { contrapose ["!"] [ident H],
      rcases [expr H, "with", "⟨", ident s, ",", "⟨", ident b, "⟩", "⟩"],
      exact [expr ⟨_, ⟨(b.map e.symm).reindex_finset_range⟩⟩] },
    simp [] [] ["only"] ["[", expr coe_det, ",", expr H, ",", expr H', ",", expr pi.one_apply, ",", expr dif_neg, ",", expr not_false_iff, "]"] [] [] }
end

end LinearMap

theorem LinearEquiv.is_unit_det (f : M ≃ₗ[R] M') (v : Basis ι R M) (v' : Basis ι R M') :
  IsUnit (LinearMap.toMatrix v v' f).det :=
  by 
    apply is_unit_det_of_left_inverse 
    simpa using (LinearMap.to_matrix_comp v v' v f.symm f).symm

-- error in LinearAlgebra.Determinant: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Specialization of `linear_equiv.is_unit_det` -/
theorem linear_equiv.is_unit_det'
{A : Type*}
[comm_ring A]
[is_domain A]
[module A M]
(f : «expr ≃ₗ[ ] »(M, A, M)) : is_unit (linear_map.det (f : «expr →ₗ[ ] »(M, A, M))) :=
by haveI [] [] [":=", expr classical.dec_eq M]; exact [expr (f : «expr →ₗ[ ] »(M, A, M)).det_cases (λ
  s b, f.is_unit_det _ _) is_unit_one]

/-- Builds a linear equivalence from a linear map whose determinant in some bases is a unit. -/
@[simps]
def LinearEquiv.ofIsUnitDet {f : M →ₗ[R] M'} {v : Basis ι R M} {v' : Basis ι R M'}
  (h : IsUnit (LinearMap.toMatrix v v' f).det) : M ≃ₗ[R] M' :=
  { toFun := f, map_add' := f.map_add, map_smul' := f.map_smul, invFun := to_lin v' v (to_matrix v v' f⁻¹),
    left_inv :=
      fun x =>
        calc to_lin v' v (to_matrix v v' f⁻¹) (f x) = to_lin v v (to_matrix v v' f⁻¹ ⬝ to_matrix v v' f) x :=
          by 
            rw [to_lin_mul v v' v, to_lin_to_matrix, LinearMap.comp_apply]
          _ = x :=
          by 
            simp [h]
          ,
    right_inv :=
      fun x =>
        calc f (to_lin v' v (to_matrix v v' f⁻¹) x) = to_lin v' v' (to_matrix v v' f ⬝ to_matrix v v' f⁻¹) x :=
          by 
            rw [to_lin_mul v' v v', LinearMap.comp_apply, to_lin_to_matrix v v']
          _ = x :=
          by 
            simp [h]
           }

/-- Builds a linear equivalence from a linear map on a finite-dimensional vector space whose
determinant is nonzero. -/
@[reducible]
def LinearMap.equivOfDetNeZero {𝕜 : Type _} [Field 𝕜] {M : Type _} [AddCommGroupₓ M] [Module 𝕜 M]
  [FiniteDimensional 𝕜 M] (f : M →ₗ[𝕜] M) (hf : LinearMap.det f ≠ 0) : M ≃ₗ[𝕜] M :=
  have  : IsUnit (LinearMap.toMatrix (FiniteDimensional.finBasis 𝕜 M) (FiniteDimensional.finBasis 𝕜 M) f).det :=
    by 
      simp only [LinearMap.det_to_matrix, is_unit_iff_ne_zero.2 hf]
  LinearEquiv.ofIsUnitDet this

/-- The determinant of a family of vectors with respect to some basis, as an alternating
multilinear map. -/
def Basis.det : AlternatingMap R M R ι :=
  { toFun := fun v => det (e.to_matrix v),
    map_add' :=
      by 
        intro v i x y 
        simp only [e.to_matrix_update, LinearEquiv.map_add]
        apply det_update_column_add,
    map_smul' :=
      by 
        intro u i c x 
        simp only [e.to_matrix_update, Algebra.id.smul_eq_mul, LinearEquiv.map_smul]
        apply det_update_column_smul,
    map_eq_zero_of_eq' :=
      by 
        intro v i j h hij 
        rw [←Function.update_eq_self i v, h, ←det_transpose, e.to_matrix_update, ←update_row_transpose,
          ←e.to_matrix_transpose_apply]
        apply det_zero_of_row_eq hij 
        rw [update_row_ne hij.symm, update_row_self] }

theorem Basis.det_apply (v : ι → M) : e.det v = det (e.to_matrix v) :=
  rfl

theorem Basis.det_self : e.det e = 1 :=
  by 
    simp [e.det_apply]

/-- `basis.det` is not the zero map. -/
theorem Basis.det_ne_zero [Nontrivial R] : e.det ≠ 0 :=
  fun h =>
    by 
      simpa [h] using e.det_self

-- error in LinearAlgebra.Determinant: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem is_basis_iff_det
{v : ι → M} : «expr ↔ »(«expr ∧ »(linear_independent R v, «expr = »(span R (set.range v), «expr⊤»())), is_unit (e.det v)) :=
begin
  split,
  { rintro ["⟨", ident hli, ",", ident hspan, "⟩"],
    set [] [ident v'] [] [":="] [expr basis.mk hli hspan] ["with", ident v'_eq],
    rw [expr e.det_apply] [],
    convert [] [expr linear_equiv.is_unit_det (linear_equiv.refl _ _) v' e] ["using", 2],
    ext [] [ident i, ident j] [],
    simp [] [] [] [] [] [] },
  { intro [ident h],
    rw ["[", expr basis.det_apply, ",", expr basis.to_matrix_eq_to_matrix_constr, "]"] ["at", ident h],
    set [] [ident v'] [] [":="] [expr basis.map e (linear_equiv.of_is_unit_det h)] ["with", ident v'_def],
    have [] [":", expr «expr = »(«expr⇑ »(v'), v)] [],
    { ext [] [ident i] [],
      rw ["[", expr v'_def, ",", expr basis.map_apply, ",", expr linear_equiv.of_is_unit_det_apply, ",", expr e.constr_basis, "]"] [] },
    rw ["<-", expr this] [],
    exact [expr ⟨v'.linear_independent, v'.span_eq⟩] }
end

theorem Basis.is_unit_det (e' : Basis ι R M) : IsUnit (e.det e') :=
  (is_basis_iff_det e).mp ⟨e'.linear_independent, e'.span_eq⟩

/-- Any alternating map to `R` where `ι` has the cardinality of a basis equals the determinant
map with respect to that basis, multiplied by the value of that alternating map on that basis. -/
theorem AlternatingMap.eq_smul_basis_det (f : AlternatingMap R M R ι) : f = f e • e.det :=
  by 
    refine' Basis.ext_alternating e fun i h => _ 
    let σ : Equiv.Perm ι := Equiv.ofBijective i (Fintype.injective_iff_bijective.1 h)
    change f (e ∘ σ) = (f e • e.det) (e ∘ σ)
    simp [AlternatingMap.map_perm, Basis.det_self]

variable {A : Type _} [CommRingₓ A] [IsDomain A] [Module A M]

@[simp]
theorem Basis.det_comp (e : Basis ι A M) (f : M →ₗ[A] M) (v : ι → M) : e.det (f ∘ v) = f.det*e.det v :=
  by 
    rw [Basis.det_apply, Basis.det_apply, ←f.det_to_matrix e, ←Matrix.det_mul, e.to_matrix_eq_to_matrix_constr (f ∘ v),
      e.to_matrix_eq_to_matrix_constr v, ←to_matrix_comp, e.constr_comp]

theorem Basis.det_reindex {ι' : Type _} [Fintype ι'] [DecidableEq ι'] (b : Basis ι R M) (v : ι' → M) (e : ι ≃ ι') :
  (b.reindex e).det v = b.det (v ∘ e) :=
  by 
    rw [Basis.det_apply, Basis.to_matrix_reindex', det_reindex_alg_equiv, Basis.det_apply]

theorem Basis.det_reindex_symm {ι' : Type _} [Fintype ι'] [DecidableEq ι'] (b : Basis ι R M) (v : ι → M) (e : ι' ≃ ι) :
  (b.reindex e.symm).det (v ∘ e) = b.det v :=
  by 
    rw [Basis.det_reindex, Function.comp.assoc, e.self_comp_symm, Function.comp.right_id]

@[simp]
theorem Basis.det_map (b : Basis ι R M) (f : M ≃ₗ[R] M') (v : ι → M') : (b.map f).det v = b.det (f.symm ∘ v) :=
  by 
    rw [Basis.det_apply, Basis.to_matrix_map, Basis.det_apply]

@[simp]
theorem Pi.basis_fun_det : (Pi.basisFun R ι).det = Matrix.detRowAlternating :=
  by 
    ext M 
    rw [Basis.det_apply, Basis.CoePiBasisFun.to_matrix_eq_transpose, det_transpose]

/-- If we fix a background basis `e`, then for any other basis `v`, we can characterise the
coordinates provided by `v` in terms of determinants relative to `e`. -/
theorem Basis.det_smul_mk_coord_eq_det_update {v : ι → M} (hli : LinearIndependent R v) (hsp : span R (range v) = ⊤)
  (i : ι) : e.det v • (Basis.mk hli hsp).Coord i = e.det.to_multilinear_map.to_linear_map v i :=
  by 
    apply (Basis.mk hli hsp).ext 
    intro k 
    rcases eq_or_ne k i with (rfl | hik) <;>
      simp only [Algebra.id.smul_eq_mul, Basis.coe_mk, LinearMap.smul_apply, LinearMap.coe_mk,
        MultilinearMap.to_linear_map_apply]
    ·
      rw [Basis.mk_coord_apply_eq, mul_oneₓ, update_eq_self]
      congr
    ·
      rw [Basis.mk_coord_apply_ne hik, mul_zero, eq_comm]
      exact
        e.det.map_eq_zero_of_eq _
          (by 
            simp [hik, Function.update_apply])
          hik

