import Mathbin.Data.MvPolynomial.Rename 
import Mathbin.Data.Equiv.Fin 
import Mathbin.Data.Polynomial.AlgebraMap

/-!
# Equivalences between polynomial rings

This file establishes a number of equivalences between polynomial rings,
based on equivalences between the underlying types.

## Notation

As in other polynomial files, we typically use the notation:

+ `σ : Type*` (indexing the variables)

+ `R : Type*` `[comm_semiring R]` (the coefficients)

+ `s : σ →₀ ℕ`, a function from `σ` to `ℕ` which is zero away from a finite set.
This will give rise to a monomial in `mv_polynomial σ R` which mathematicians might call `X^s`

+ `a : R`

+ `i : σ`, with corresponding monomial `X i`, often denoted `X_i` by mathematicians

+ `p : mv_polynomial σ R`

## Tags

equivalence, isomorphism, morphism, ring hom, hom

-/


noncomputable theory

open_locale Classical BigOperators

open Set Function Finsupp AddMonoidAlgebra

universe u v w x

variable{R : Type u}{S₁ : Type v}{S₂ : Type w}{S₃ : Type x}

namespace MvPolynomial

variable{σ : Type _}{a a' a₁ a₂ : R}{e : ℕ}{n m : σ}{s : σ →₀ ℕ}

section Equiv

variable(R)[CommSemiringₓ R]

-- error in Data.MvPolynomial.Equiv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/--
The ring isomorphism between multivariable polynomials in a single variable and
polynomials over the ground ring.
-/ @[simps #[]] def punit_alg_equiv : «expr ≃ₐ[ ] »(mv_polynomial punit R, R, polynomial R) :=
{ to_fun := eval₂ polynomial.C (λ u : punit, polynomial.X),
  inv_fun := polynomial.eval₂ mv_polynomial.C (X punit.star),
  left_inv := begin
    let [ident f] [":", expr «expr →+* »(polynomial R, mv_polynomial punit R)] [":=", expr polynomial.eval₂_ring_hom mv_polynomial.C (X punit.star)],
    let [ident g] [":", expr «expr →+* »(mv_polynomial punit R, polynomial R)] [":=", expr eval₂_hom polynomial.C (λ
      u : punit, polynomial.X)],
    show [expr ∀ p, «expr = »(f.comp g p, p)],
    apply [expr is_id],
    { ext [] [ident a] [],
      dsimp [] [] [] [],
      rw ["[", expr eval₂_C, ",", expr polynomial.eval₂_C, "]"] [] },
    { rintros ["⟨", "⟩"],
      dsimp [] [] [] [],
      rw ["[", expr eval₂_X, ",", expr polynomial.eval₂_X, "]"] [] }
  end,
  right_inv := assume
  p, polynomial.induction_on p (assume
   a, by rw ["[", expr polynomial.eval₂_C, ",", expr mv_polynomial.eval₂_C, "]"] []) (assume
   p
   q
   hp
   hq, by rw ["[", expr polynomial.eval₂_add, ",", expr mv_polynomial.eval₂_add, ",", expr hp, ",", expr hq, "]"] []) (assume
   p
   n
   hp, by rw ["[", expr polynomial.eval₂_mul, ",", expr polynomial.eval₂_pow, ",", expr polynomial.eval₂_X, ",", expr polynomial.eval₂_C, ",", expr eval₂_mul, ",", expr eval₂_C, ",", expr eval₂_pow, ",", expr eval₂_X, "]"] []),
  map_mul' := λ _ _, eval₂_mul _ _,
  map_add' := λ _ _, eval₂_add _ _,
  commutes' := λ _, eval₂_C _ _ _ }

section Map

variable{R}(σ)

/-- If `e : A ≃+* B` is an isomorphism of rings, then so is `map e`. -/
@[simps apply]
def map_equiv [CommSemiringₓ S₁] [CommSemiringₓ S₂] (e : S₁ ≃+* S₂) : MvPolynomial σ S₁ ≃+* MvPolynomial σ S₂ :=
  { map (e : S₁ →+* S₂) with toFun := map (e : S₁ →+* S₂), invFun := map (e.symm : S₂ →+* S₁),
    left_inv := map_left_inverse e.left_inv, right_inv := map_right_inverse e.right_inv }

@[simp]
theorem map_equiv_refl : map_equiv σ (RingEquiv.refl R) = RingEquiv.refl _ :=
  RingEquiv.ext map_id

@[simp]
theorem map_equiv_symm [CommSemiringₓ S₁] [CommSemiringₓ S₂] (e : S₁ ≃+* S₂) :
  (map_equiv σ e).symm = map_equiv σ e.symm :=
  rfl

@[simp]
theorem map_equiv_trans [CommSemiringₓ S₁] [CommSemiringₓ S₂] [CommSemiringₓ S₃] (e : S₁ ≃+* S₂) (f : S₂ ≃+* S₃) :
  (map_equiv σ e).trans (map_equiv σ f) = map_equiv σ (e.trans f) :=
  RingEquiv.ext (map_map e f)

variable{A₁ A₂ A₃ : Type _}[CommSemiringₓ A₁][CommSemiringₓ A₂][CommSemiringₓ A₃]

variable[Algebra R A₁][Algebra R A₂][Algebra R A₃]

/-- If `e : A ≃ₐ[R] B` is an isomorphism of `R`-algebras, then so is `map e`. -/
@[simps apply]
def map_alg_equiv (e : A₁ ≃ₐ[R] A₂) : MvPolynomial σ A₁ ≃ₐ[R] MvPolynomial σ A₂ :=
  { map_alg_hom (e : A₁ →ₐ[R] A₂), map_equiv σ (e : A₁ ≃+* A₂) with toFun := map (e : A₁ →+* A₂) }

@[simp]
theorem map_alg_equiv_refl : map_alg_equiv σ (AlgEquiv.refl : A₁ ≃ₐ[R] A₁) = AlgEquiv.refl :=
  AlgEquiv.ext map_id

@[simp]
theorem map_alg_equiv_symm (e : A₁ ≃ₐ[R] A₂) : (map_alg_equiv σ e).symm = map_alg_equiv σ e.symm :=
  rfl

@[simp]
theorem map_alg_equiv_trans (e : A₁ ≃ₐ[R] A₂) (f : A₂ ≃ₐ[R] A₃) :
  (map_alg_equiv σ e).trans (map_alg_equiv σ f) = map_alg_equiv σ (e.trans f) :=
  AlgEquiv.ext (map_map e f)

end Map

section 

variable(S₁ S₂ S₃)

/--
The function from multivariable polynomials in a sum of two types,
to multivariable polynomials in one of the types,
with coefficents in multivariable polynomials in the other type.

See `sum_ring_equiv` for the ring isomorphism.
-/
def sum_to_iter : MvPolynomial (Sum S₁ S₂) R →+* MvPolynomial S₁ (MvPolynomial S₂ R) :=
  eval₂_hom (C.comp C) fun bc => Sum.recOn bc X (C ∘ X)

@[simp]
theorem sum_to_iter_C (a : R) : sum_to_iter R S₁ S₂ (C a) = C (C a) :=
  eval₂_C _ _ a

@[simp]
theorem sum_to_iter_Xl (b : S₁) : sum_to_iter R S₁ S₂ (X (Sum.inl b)) = X b :=
  eval₂_X _ _ (Sum.inl b)

@[simp]
theorem sum_to_iter_Xr (c : S₂) : sum_to_iter R S₁ S₂ (X (Sum.inr c)) = C (X c) :=
  eval₂_X _ _ (Sum.inr c)

/--
The function from multivariable polynomials in one type,
with coefficents in multivariable polynomials in another type,
to multivariable polynomials in the sum of the two types.

See `sum_ring_equiv` for the ring isomorphism.
-/
def iter_to_sum : MvPolynomial S₁ (MvPolynomial S₂ R) →+* MvPolynomial (Sum S₁ S₂) R :=
  eval₂_hom (eval₂_hom C (X ∘ Sum.inr)) (X ∘ Sum.inl)

theorem iter_to_sum_C_C (a : R) : iter_to_sum R S₁ S₂ (C (C a)) = C a :=
  Eq.trans (eval₂_C _ _ (C a)) (eval₂_C _ _ _)

theorem iter_to_sum_X (b : S₁) : iter_to_sum R S₁ S₂ (X b) = X (Sum.inl b) :=
  eval₂_X _ _ _

theorem iter_to_sum_C_X (c : S₂) : iter_to_sum R S₁ S₂ (C (X c)) = X (Sum.inr c) :=
  Eq.trans (eval₂_C _ _ (X c)) (eval₂_X _ _ _)

variable(σ)

/-- The algebra isomorphism between multivariable polynomials in no variables
and the ground ring. -/
@[simps]
def is_empty_alg_equiv [he : IsEmpty σ] : MvPolynomial σ R ≃ₐ[R] R :=
  AlgEquiv.ofAlgHom (aeval (IsEmpty.elim he)) (Algebra.ofId _ _)
    (by 
      ext 
      simp [Algebra.of_id_apply, algebra_map_eq])
    (by 
      ext i m 
      exact IsEmpty.elim' he i)

/-- The ring isomorphism between multivariable polynomials in no variables
and the ground ring. -/
@[simps]
def is_empty_ring_equiv [he : IsEmpty σ] : MvPolynomial σ R ≃+* R :=
  (is_empty_alg_equiv R σ).toRingEquiv

variable{σ}

/-- A helper function for `sum_ring_equiv`. -/
@[simps]
def mv_polynomial_equiv_mv_polynomial [CommSemiringₓ S₃] (f : MvPolynomial S₁ R →+* MvPolynomial S₂ S₃)
  (g : MvPolynomial S₂ S₃ →+* MvPolynomial S₁ R) (hfgC : (f.comp g).comp C = C) (hfgX : ∀ n, f (g (X n)) = X n)
  (hgfC : (g.comp f).comp C = C) (hgfX : ∀ n, g (f (X n)) = X n) : MvPolynomial S₁ R ≃+* MvPolynomial S₂ S₃ :=
  { toFun := f, invFun := g, left_inv := is_id (RingHom.comp _ _) hgfC hgfX,
    right_inv := is_id (RingHom.comp _ _) hfgC hfgX, map_mul' := f.map_mul, map_add' := f.map_add }

/--
The ring isomorphism between multivariable polynomials in a sum of two types,
and multivariable polynomials in one of the types,
with coefficents in multivariable polynomials in the other type.
-/
def sum_ring_equiv : MvPolynomial (Sum S₁ S₂) R ≃+* MvPolynomial S₁ (MvPolynomial S₂ R) :=
  by 
    apply @mv_polynomial_equiv_mv_polynomial R (Sum S₁ S₂) _ _ _ _ (sum_to_iter R S₁ S₂) (iter_to_sum R S₁ S₂)
    ·
      refine' RingHom.ext fun p => _ 
      rw [RingHom.comp_apply]
      convert hom_eq_hom ((sum_to_iter R S₁ S₂).comp ((iter_to_sum R S₁ S₂).comp C)) C _ _ p
      ·
        ext1 a 
        dsimp 
        rw [iter_to_sum_C_C R S₁ S₂, sum_to_iter_C R S₁ S₂]
      ·
        intro c 
        dsimp 
        rw [iter_to_sum_C_X R S₁ S₂, sum_to_iter_Xr R S₁ S₂]
    ·
      intro b 
      rw [iter_to_sum_X R S₁ S₂, sum_to_iter_Xl R S₁ S₂]
    ·
      ext1 a 
      rw [RingHom.comp_apply, RingHom.comp_apply, sum_to_iter_C R S₁ S₂, iter_to_sum_C_C R S₁ S₂]
    ·
      intro n 
      cases' n with b c
      ·
        rw [sum_to_iter_Xl, iter_to_sum_X]
      ·
        rw [sum_to_iter_Xr, iter_to_sum_C_X]

-- error in Data.MvPolynomial.Equiv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
The algebra isomorphism between multivariable polynomials in a sum of two types,
and multivariable polynomials in one of the types,
with coefficents in multivariable polynomials in the other type.
-/ def sum_alg_equiv : «expr ≃ₐ[ ] »(mv_polynomial «expr ⊕ »(S₁, S₂) R, R, mv_polynomial S₁ (mv_polynomial S₂ R)) :=
{ commutes' := begin
    intro [ident r],
    have [ident A] [":", expr «expr = »(algebra_map R (mv_polynomial S₁ (mv_polynomial S₂ R)) r, (C (C r) : _))] [],
    by refl,
    have [ident B] [":", expr «expr = »(algebra_map R (mv_polynomial «expr ⊕ »(S₁, S₂) R) r, C r)] [],
    by refl,
    simp [] [] ["only"] ["[", expr sum_ring_equiv, ",", expr sum_to_iter_C, ",", expr mv_polynomial_equiv_mv_polynomial_apply, ",", expr ring_equiv.to_fun_eq_coe, ",", expr A, ",", expr B, "]"] [] []
  end,
  ..sum_ring_equiv R S₁ S₂ }

section 

attribute [local instance] IsScalarTower.right

/--
The algebra isomorphism between multivariable polynomials in `option S₁` and
polynomials with coefficients in `mv_polynomial S₁ R`.
-/
@[simps]
def option_equiv_left : MvPolynomial (Option S₁) R ≃ₐ[R] Polynomial (MvPolynomial S₁ R) :=
  AlgEquiv.ofAlgHom (MvPolynomial.aeval fun o => o.elim Polynomial.x fun s => Polynomial.c (X s))
    (Polynomial.aevalTower (MvPolynomial.rename some) (X none))
    (by 
      ext : 2 <;> simp [←Polynomial.C_eq_algebra_map])
    (by 
      ext i : 2 <;> cases i <;> simp )

end 

/--
The algebra isomorphism between multivariable polynomials in `option S₁` and
multivariable polynomials with coefficients in polynomials.
-/
def option_equiv_right : MvPolynomial (Option S₁) R ≃ₐ[R] MvPolynomial S₁ (Polynomial R) :=
  AlgEquiv.ofAlgHom (MvPolynomial.aeval fun o => o.elim (C Polynomial.x) X)
    (MvPolynomial.aevalTower (Polynomial.aeval (X none)) fun i => X (Option.some i))
    (by 
      ext : 2 <;> simp [MvPolynomial.algebra_map_eq])
    (by 
      ext i : 2 <;> cases i <;> simp )

/--
The algebra isomorphism between multivariable polynomials in `fin (n + 1)` and
polynomials over multivariable polynomials in `fin n`.
-/
def finSuccEquiv (n : ℕ) : MvPolynomial (Finₓ (n+1)) R ≃ₐ[R] Polynomial (MvPolynomial (Finₓ n) R) :=
  (rename_equiv R (finSuccEquiv n)).trans (option_equiv_left R (Finₓ n))

-- error in Data.MvPolynomial.Equiv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem fin_succ_equiv_eq
(n : exprℕ()) : «expr = »((fin_succ_equiv R n : «expr →+* »(mv_polynomial (fin «expr + »(n, 1)) R, polynomial (mv_polynomial (fin n) R))), eval₂_hom (polynomial.C.comp (C : «expr →+* »(R, mv_polynomial (fin n) R))) (λ
  i : fin «expr + »(n, 1), fin.cases polynomial.X (λ k, polynomial.C (X k)) i)) :=
begin
  ext [] [] [":", 2],
  { simp [] [] ["only"] ["[", expr fin_succ_equiv, ",", expr option_equiv_left_apply, ",", expr aeval_C, ",", expr alg_equiv.coe_trans, ",", expr alg_equiv.coe_alg_hom, ",", expr coe_eval₂_hom, ",", expr alg_hom.coe_to_ring_hom, ",", expr comp_app, ",", expr rename_equiv_apply, ",", expr eval₂_C, ",", expr ring_hom.coe_comp, ",", expr coe_coe, ",", expr rename_C, "]"] [] [],
    refl },
  { intro [ident i],
    refine [expr fin.cases _ _ i]; simp [] [] [] ["[", expr fin_succ_equiv, "]"] [] [] }
end

-- error in Data.MvPolynomial.Equiv: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[simp]
theorem fin_succ_equiv_apply
(n : exprℕ())
(p : mv_polynomial (fin «expr + »(n, 1)) R) : «expr = »(fin_succ_equiv R n p, eval₂_hom (polynomial.C.comp (C : «expr →+* »(R, mv_polynomial (fin n) R))) (λ
  i : fin «expr + »(n, 1), fin.cases polynomial.X (λ k, polynomial.C (X k)) i) p) :=
by { rw ["<-", expr fin_succ_equiv_eq] [],
  refl }

theorem fin_succ_equiv_comp_C_eq_C {R : Type u} [CommSemiringₓ R] (n : ℕ) :
  («expr↑ » (MvPolynomial.finSuccEquiv R n).symm : Polynomial (MvPolynomial (Finₓ n) R) →+* _).comp
      (Polynomial.c.comp MvPolynomial.c) =
    (MvPolynomial.c : R →+* MvPolynomial (Finₓ n.succ) R) :=
  by 
    refine' RingHom.ext fun x => _ 
    rw [RingHom.comp_apply]
    refine' (MvPolynomial.finSuccEquiv R n).Injective (trans ((MvPolynomial.finSuccEquiv R n).apply_symm_apply _) _)
    simp only [MvPolynomial.fin_succ_equiv_apply, MvPolynomial.eval₂_hom_C]

end 

end Equiv

end MvPolynomial

