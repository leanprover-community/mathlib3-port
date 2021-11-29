import Mathbin.Algebra.Algebra.Tower 
import Mathbin.Data.Finsupp.Antidiagonal 
import Mathbin.Algebra.MonoidAlgebra.Basic

/-!
# Multivariate polynomials

This file defines polynomial rings over a base ring (or even semiring),
with variables from a general type `σ` (which could be infinite).

## Important definitions

Let `R` be a commutative ring (or a semiring) and let `σ` be an arbitrary
type. This file creates the type `mv_polynomial σ R`, which mathematicians
might denote $R[X_i : i \in σ]$. It is the type of multivariate
(a.k.a. multivariable) polynomials, with variables
corresponding to the terms in `σ`, and coefficients in `R`.

### Notation

In the definitions below, we use the following notation:

+ `σ : Type*` (indexing the variables)

+ `R : Type*` `[comm_semiring R]` (the coefficients)

+ `s : σ →₀ ℕ`, a function from `σ` to `ℕ` which is zero away from a finite set.
This will give rise to a monomial in `mv_polynomial σ R` which mathematicians might call `X^s`

+ `a : R`

+ `i : σ`, with corresponding monomial `X i`, often denoted `X_i` by mathematicians

+ `p : mv_polynomial σ R`

### Definitions

* `mv_polynomial σ R` : the type of polynomials with variables of type `σ` and coefficients
  in the commutative semiring `R`

* `monomial s a` : the monomial which mathematically would be denoted `a * X^s`

* `C a` : the constant polynomial with value `a`

* `X i` : the degree one monomial corresponding to i; mathematically this might be denoted `Xᵢ`.

* `coeff s p` : the coefficient of `s` in `p`.

* `eval₂ (f : R → S₁) (g : σ → S₁) p` : given a semiring homomorphism from `R` to another
  semiring `S₁`, and a map `σ → S₁`, evaluates `p` at this valuation, returning a term of type `S₁`.
  Note that `eval₂` can be made using `eval` and `map` (see below), and it has been suggested
  that sticking to `eval` and `map` might make the code less brittle.

* `eval (g : σ → R) p` : given a map `σ → R`, evaluates `p` at this valuation,
  returning a term of type `R`

* `map (f : R → S₁) p` : returns the multivariate polynomial obtained from `p` by the change of
  coefficient semiring corresponding to `f`

## Implementation notes

Recall that if `Y` has a zero, then `X →₀ Y` is the type of functions from `X` to `Y` with finite
support, i.e. such that only finitely many elements of `X` get sent to non-zero terms in `Y`.
The definition of `mv_polynomial σ R` is `(σ →₀ ℕ) →₀ R` ; here `σ →₀ ℕ` denotes the space of all
monomials in the variables, and the function to `R` sends a monomial to its coefficient in
the polynomial being represented.

## Tags

polynomial, multivariate polynomial, multivariable polynomial

-/


noncomputable theory

open_locale Classical BigOperators

open Set Function Finsupp AddMonoidAlgebra

open_locale BigOperators

universe u v w x

variable{R : Type u}{S₁ : Type v}{S₂ : Type w}{S₃ : Type x}

/-- Multivariate polynomial, where `σ` is the index set of the variables and
  `R` is the coefficient ring -/
def MvPolynomial (σ : Type _) (R : Type _) [CommSemiringₓ R] :=
  AddMonoidAlgebra R (σ →₀ ℕ)

namespace MvPolynomial

variable{σ : Type _}{a a' a₁ a₂ : R}{e : ℕ}{n m : σ}{s : σ →₀ ℕ}

section CommSemiringₓ

section Instances

instance decidable_eq_mv_polynomial [CommSemiringₓ R] [DecidableEq σ] [DecidableEq R] :
  DecidableEq (MvPolynomial σ R) :=
  Finsupp.decidableEq

instance  [CommSemiringₓ R] : CommSemiringₓ (MvPolynomial σ R) :=
  AddMonoidAlgebra.commSemiring

instance  [CommSemiringₓ R] : Inhabited (MvPolynomial σ R) :=
  ⟨0⟩

instance  [Monoidₓ R] [CommSemiringₓ S₁] [DistribMulAction R S₁] : DistribMulAction R (MvPolynomial σ S₁) :=
  AddMonoidAlgebra.distribMulAction

instance  [Monoidₓ R] [CommSemiringₓ S₁] [DistribMulAction R S₁] [HasFaithfulScalar R S₁] :
  HasFaithfulScalar R (MvPolynomial σ S₁) :=
  AddMonoidAlgebra.has_faithful_scalar

instance  [Semiringₓ R] [CommSemiringₓ S₁] [Module R S₁] : Module R (MvPolynomial σ S₁) :=
  AddMonoidAlgebra.module

instance  [Monoidₓ R] [Monoidₓ S₁] [CommSemiringₓ S₂] [HasScalar R S₁] [DistribMulAction R S₂] [DistribMulAction S₁ S₂]
  [IsScalarTower R S₁ S₂] : IsScalarTower R S₁ (MvPolynomial σ S₂) :=
  AddMonoidAlgebra.is_scalar_tower

instance  [Monoidₓ R] [Monoidₓ S₁] [CommSemiringₓ S₂] [DistribMulAction R S₂] [DistribMulAction S₁ S₂]
  [SmulCommClass R S₁ S₂] : SmulCommClass R S₁ (MvPolynomial σ S₂) :=
  AddMonoidAlgebra.smul_comm_class

instance  [CommSemiringₓ R] [CommSemiringₓ S₁] [Algebra R S₁] : Algebra R (MvPolynomial σ S₁) :=
  AddMonoidAlgebra.algebra

/-- If `R` is a subsingleton, then `mv_polynomial σ R` has a unique element -/
protected def Unique [CommSemiringₓ R] [Subsingleton R] : Unique (MvPolynomial σ R) :=
  AddMonoidAlgebra.unique

end Instances

variable[CommSemiringₓ R][CommSemiringₓ S₁]{p q : MvPolynomial σ R}

/-- `monomial s a` is the monomial with coefficient `a` and exponents given by `s`  -/
def monomial (s : σ →₀ ℕ) : R →ₗ[R] MvPolynomial σ R :=
  lsingle s

theorem single_eq_monomial (s : σ →₀ ℕ) (a : R) : single s a = monomial s a :=
  rfl

theorem mul_def : (p*q) = p.sum fun m a => q.sum$ fun n b => monomial (m+n) (a*b) :=
  rfl

/-- `C a` is the constant polynomial with value `a` -/
def C : R →+* MvPolynomial σ R :=
  { single_zero_ring_hom with toFun := monomial 0 }

variable(R σ)

theorem algebra_map_eq : algebraMap R (MvPolynomial σ R) = C :=
  rfl

variable{R σ}

/-- `X n` is the degree `1` monomial $X_n$. -/
def X (n : σ) : MvPolynomial σ R :=
  monomial (single n 1) 1

theorem C_apply : (C a : MvPolynomial σ R) = monomial 0 a :=
  rfl

@[simp]
theorem C_0 : C 0 = (0 : MvPolynomial σ R) :=
  by 
    simp [C_apply, monomial]

@[simp]
theorem C_1 : C 1 = (1 : MvPolynomial σ R) :=
  rfl

theorem C_mul_monomial : (C a*monomial s a') = monomial s (a*a') :=
  by 
    simp [C_apply, monomial, single_mul_single]

@[simp]
theorem C_add : (C (a+a') : MvPolynomial σ R) = C a+C a' :=
  single_add

@[simp]
theorem C_mul : (C (a*a') : MvPolynomial σ R) = C a*C a' :=
  C_mul_monomial.symm

@[simp]
theorem C_pow (a : R) (n : ℕ) : (C (a ^ n) : MvPolynomial σ R) = C a ^ n :=
  by 
    induction n <;> simp [pow_succₓ]

theorem C_injective (σ : Type _) (R : Type _) [CommSemiringₓ R] : Function.Injective (C : R → MvPolynomial σ R) :=
  Finsupp.single_injective _

theorem C_surjective {R : Type _} [CommSemiringₓ R] (σ : Type _) [IsEmpty σ] :
  Function.Surjective (C : R → MvPolynomial σ R) :=
  by 
    refine' fun p => ⟨p.to_fun 0, Finsupp.ext fun a => _⟩
    simpa [(Finsupp.ext isEmptyElim : a = 0), C_apply, monomial]

@[simp]
theorem C_inj {σ : Type _} (R : Type _) [CommSemiringₓ R] (r s : R) : (C r : MvPolynomial σ R) = C s ↔ r = s :=
  (C_injective σ R).eq_iff

instance infinite_of_infinite (σ : Type _) (R : Type _) [CommSemiringₓ R] [Infinite R] : Infinite (MvPolynomial σ R) :=
  Infinite.of_injective C (C_injective _ _)

-- error in Data.MvPolynomial.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
instance infinite_of_nonempty
(σ : Type*)
(R : Type*)
[nonempty σ]
[comm_semiring R]
[nontrivial R] : infinite (mv_polynomial σ R) :=
«expr $ »(infinite.of_injective «expr ∘ »(λ
  s : «expr →₀ »(σ, exprℕ()), monomial s 1, single (classical.arbitrary σ)), function.injective.comp (λ
  m n, (finsupp.single_left_inj one_ne_zero).mp) (finsupp.single_injective _))

theorem C_eq_coe_nat (n : ℕ) : (C («expr↑ » n) : MvPolynomial σ R) = n :=
  by 
    induction n <;> simp [Nat.succ_eq_add_one]

theorem C_mul' : (MvPolynomial.c a*p) = a • p :=
  (Algebra.smul_def a p).symm

theorem smul_eq_C_mul (p : MvPolynomial σ R) (a : R) : a • p = C a*p :=
  C_mul'.symm

theorem C_eq_smul_one : (C a : MvPolynomial σ R) = a • 1 :=
  by 
    rw [←C_mul', mul_oneₓ]

theorem monomial_pow : monomial s a ^ e = monomial (e • s) (a ^ e) :=
  AddMonoidAlgebra.single_pow e

@[simp]
theorem monomial_mul {s s' : σ →₀ ℕ} {a b : R} : (monomial s a*monomial s' b) = monomial (s+s') (a*b) :=
  AddMonoidAlgebra.single_mul_single

variable(σ R)

/-- `λ s, monomial s 1` as a homomorphism. -/
def monomial_one_hom : Multiplicative (σ →₀ ℕ) →* MvPolynomial σ R :=
  AddMonoidAlgebra.of _ _

variable{σ R}

@[simp]
theorem monomial_one_hom_apply : monomial_one_hom R σ s = (monomial s 1 : MvPolynomial σ R) :=
  rfl

theorem X_pow_eq_monomial : X n ^ e = monomial (single n e) (1 : R) :=
  by 
    simp [X, monomial_pow]

theorem monomial_add_single : monomial (s+single n e) a = monomial s a*X n ^ e :=
  by 
    rw [X_pow_eq_monomial, monomial_mul, mul_oneₓ]

theorem monomial_single_add : monomial (single n e+s) a = (X n ^ e)*monomial s a :=
  by 
    rw [X_pow_eq_monomial, monomial_mul, one_mulₓ]

theorem monomial_eq_C_mul_X {s : σ} {a : R} {n : ℕ} : monomial (single s n) a = C a*X s ^ n :=
  by 
    rw [←zero_addₓ (single s n), monomial_add_single, C_apply]

@[simp]
theorem monomial_zero {s : σ →₀ ℕ} : monomial s (0 : R) = 0 :=
  single_zero

@[simp]
theorem monomial_zero' : (monomial (0 : σ →₀ ℕ) : R → MvPolynomial σ R) = C :=
  rfl

@[simp]
theorem sum_monomial_eq {A : Type _} [AddCommMonoidₓ A] {u : σ →₀ ℕ} {r : R} {b : (σ →₀ ℕ) → R → A} (w : b u 0 = 0) :
  Sum (monomial u r) b = b u r :=
  sum_single_index w

@[simp]
theorem sum_C {A : Type _} [AddCommMonoidₓ A] {b : (σ →₀ ℕ) → R → A} (w : b 0 0 = 0) : Sum (C a) b = b 0 a :=
  sum_monomial_eq w

theorem monomial_sum_one {α : Type _} (s : Finset α) (f : α → σ →₀ ℕ) :
  (monomial (∑i in s, f i) 1 : MvPolynomial σ R) = ∏i in s, monomial (f i) 1 :=
  (monomial_one_hom R σ).map_prod (fun i => Multiplicative.ofAdd (f i)) s

theorem monomial_sum_index {α : Type _} (s : Finset α) (f : α → σ →₀ ℕ) (a : R) :
  monomial (∑i in s, f i) a = C a*∏i in s, monomial (f i) 1 :=
  by 
    rw [←monomial_sum_one, C_mul', ←(monomial _).map_smul, smul_eq_mul, mul_oneₓ]

theorem monomial_finsupp_sum_index {α β : Type _} [HasZero β] (f : α →₀ β) (g : α → β → σ →₀ ℕ) (a : R) :
  monomial (f.sum g) a = C a*f.prod fun a b => monomial (g a b) 1 :=
  monomial_sum_index _ _ _

theorem monomial_eq : monomial s a = C a*(s.prod$ fun n e => X n ^ e : MvPolynomial σ R) :=
  by 
    simp only [X_pow_eq_monomial, ←monomial_finsupp_sum_index, Finsupp.sum_single]

-- error in Data.MvPolynomial.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[recursor  5]
theorem induction_on
{M : mv_polynomial σ R → exprProp()}
(p : mv_polynomial σ R)
(h_C : ∀ a, M (C a))
(h_add : ∀ p q, M p → M q → M «expr + »(p, q))
(h_X : ∀ p n, M p → M «expr * »(p, X n)) : M p :=
have ∀ s a, M (monomial s a), begin
  assume [binders (s a)],
  apply [expr @finsupp.induction σ exprℕ() _ _ s],
  { show [expr M (monomial 0 a)],
    from [expr h_C a] },
  { assume [binders (n e p hpn he ih)],
    have [] [":", expr ∀ e : exprℕ(), M «expr * »(monomial p a, «expr ^ »(X n, e))] [],
    { intro [ident e],
      induction [expr e] [] [] [],
      { simp [] [] [] ["[", expr ih, "]"] [] [] },
      { simp [] [] [] ["[", expr ih, ",", expr pow_succ', ",", expr (mul_assoc _ _ _).symm, ",", expr h_X, ",", expr e_ih, "]"] [] [] } },
    simp [] [] [] ["[", expr add_comm, ",", expr monomial_add_single, ",", expr this, "]"] [] [] }
end,
finsupp.induction p (by have [] [":", expr M (C 0)] [":=", expr h_C 0]; rwa ["[", expr C_0, "]"] ["at", ident this]) (assume
 s a p hsp ha hp, h_add _ _ (this s a) hp)

@[elab_as_eliminator]
theorem induction_on' {P : MvPolynomial σ R → Prop} (p : MvPolynomial σ R)
  (h1 : ∀ (u : σ →₀ ℕ) (a : R), P (monomial u a)) (h2 : ∀ (p q : MvPolynomial σ R), P p → P q → P (p+q)) : P p :=
  Finsupp.induction p
    (suffices P (monomial 0 0)by 
      rwa [monomial_zero] at this 
    show P (monomial 0 0) from h1 0 0)
    fun a b f ha hb hPf => h2 _ _ (h1 _ _) hPf

theorem ring_hom_ext {A : Type _} [Semiringₓ A] {f g : MvPolynomial σ R →+* A} (hC : ∀ r, f (C r) = g (C r))
  (hX : ∀ i, f (X i) = g (X i)) : f = g :=
  by 
    ext 
    exacts[hC _, hX _]

/-- See note [partially-applied ext lemmas]. -/
@[ext]
theorem ring_hom_ext' {A : Type _} [Semiringₓ A] {f g : MvPolynomial σ R →+* A} (hC : f.comp C = g.comp C)
  (hX : ∀ i, f (X i) = g (X i)) : f = g :=
  ring_hom_ext (RingHom.ext_iff.1 hC) hX

theorem hom_eq_hom [Semiringₓ S₂] (f g : MvPolynomial σ R →+* S₂) (hC : f.comp C = g.comp C)
  (hX : ∀ (n : σ), f (X n) = g (X n)) (p : MvPolynomial σ R) : f p = g p :=
  RingHom.congr_fun (ring_hom_ext' hC hX) p

theorem is_id (f : MvPolynomial σ R →+* MvPolynomial σ R) (hC : f.comp C = C) (hX : ∀ (n : σ), f (X n) = X n)
  (p : MvPolynomial σ R) : f p = p :=
  hom_eq_hom f (RingHom.id _) hC hX p

@[ext]
theorem alg_hom_ext' {A B : Type _} [CommSemiringₓ A] [CommSemiringₓ B] [Algebra R A] [Algebra R B]
  {f g : MvPolynomial σ A →ₐ[R] B}
  (h₁ : f.comp (IsScalarTower.toAlgHom R A (MvPolynomial σ A)) = g.comp (IsScalarTower.toAlgHom R A (MvPolynomial σ A)))
  (h₂ : ∀ i, f (X i) = g (X i)) : f = g :=
  AlgHom.coe_ring_hom_injective (MvPolynomial.ring_hom_ext' (congr_argₓ AlgHom.toRingHom h₁) h₂)

-- error in Data.MvPolynomial.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[ext #[]]
theorem alg_hom_ext
{A : Type*}
[comm_semiring A]
[algebra R A]
{f g : «expr →ₐ[ ] »(mv_polynomial σ R, R, A)}
(hf : ∀ i : σ, «expr = »(f (X i), g (X i))) : «expr = »(f, g) :=
add_monoid_algebra.alg_hom_ext' (mul_hom_ext' (λ x : σ, monoid_hom.ext_mnat (hf x)))

@[simp]
theorem alg_hom_C (f : MvPolynomial σ R →ₐ[R] MvPolynomial σ R) (r : R) : f (C r) = C r :=
  f.commutes r

section Support

/--
The finite set of all `m : σ →₀ ℕ` such that `X^m` has a non-zero coefficient.
-/
def support (p : MvPolynomial σ R) : Finset (σ →₀ ℕ) :=
  p.support

theorem finsupp_support_eq_support (p : MvPolynomial σ R) : Finsupp.support p = p.support :=
  rfl

theorem support_monomial [Decidable (a = 0)] : (monomial s a).support = if a = 0 then ∅ else {s} :=
  by 
    convert rfl

theorem support_monomial_subset : (monomial s a).support ⊆ {s} :=
  support_single_subset

theorem support_add : (p+q).support ⊆ p.support ∪ q.support :=
  Finsupp.support_add

theorem support_X [Nontrivial R] : (X n : MvPolynomial σ R).support = {single n 1} :=
  by 
    rw [X, support_monomial, if_neg] <;> exact one_ne_zero

end Support

section Coeff

/-- The coefficient of the monomial `m` in the multi-variable polynomial `p`. -/
def coeff (m : σ →₀ ℕ) (p : MvPolynomial σ R) : R :=
  @coeFn _ _ (MonoidAlgebra.hasCoeToFun _ _) p m

@[simp]
theorem mem_support_iff {p : MvPolynomial σ R} {m : σ →₀ ℕ} : m ∈ p.support ↔ p.coeff m ≠ 0 :=
  by 
    simp [support, coeff]

theorem not_mem_support_iff {p : MvPolynomial σ R} {m : σ →₀ ℕ} : m ∉ p.support ↔ p.coeff m = 0 :=
  by 
    simp 

theorem sum_def {A} [AddCommMonoidₓ A] {p : MvPolynomial σ R} {b : (σ →₀ ℕ) → R → A} :
  p.sum b = ∑m in p.support, b m (p.coeff m) :=
  by 
    simp [support, Finsupp.sum, coeff]

theorem support_mul (p q : MvPolynomial σ R) :
  (p*q).support ⊆ p.support.bUnion fun a => q.support.bUnion$ fun b => {a+b} :=
  by 
    convert AddMonoidAlgebra.support_mul p q <;> ext <;> convert Iff.rfl

@[ext]
theorem ext (p q : MvPolynomial σ R) : (∀ m, coeff m p = coeff m q) → p = q :=
  ext

theorem ext_iff (p q : MvPolynomial σ R) : p = q ↔ ∀ m, coeff m p = coeff m q :=
  ⟨fun h m =>
      by 
        rw [h],
    ext p q⟩

@[simp]
theorem coeff_add (m : σ →₀ ℕ) (p q : MvPolynomial σ R) : coeff m (p+q) = coeff m p+coeff m q :=
  add_apply p q m

@[simp]
theorem coeff_smul {S₁ : Type _} [Monoidₓ S₁] [DistribMulAction S₁ R] (m : σ →₀ ℕ) (c : S₁) (p : MvPolynomial σ R) :
  coeff m (c • p) = c • coeff m p :=
  smul_apply c p m

@[simp]
theorem coeff_zero (m : σ →₀ ℕ) : coeff m (0 : MvPolynomial σ R) = 0 :=
  rfl

@[simp]
theorem coeff_zero_X (i : σ) : coeff 0 (X i : MvPolynomial σ R) = 0 :=
  single_eq_of_ne
    fun h =>
      by 
        cases single_eq_zero.1 h

/-- `mv_polynomial.coeff m` but promoted to an `add_monoid_hom`. -/
@[simps]
def coeff_add_monoid_hom (m : σ →₀ ℕ) : MvPolynomial σ R →+ R :=
  { toFun := coeff m, map_zero' := coeff_zero m, map_add' := coeff_add m }

theorem coeff_sum {X : Type _} (s : Finset X) (f : X → MvPolynomial σ R) (m : σ →₀ ℕ) :
  coeff m (∑x in s, f x) = ∑x in s, coeff m (f x) :=
  (coeff_add_monoid_hom _).map_sum _ s

theorem monic_monomial_eq m : monomial m (1 : R) = (m.prod$ fun n e => X n ^ e : MvPolynomial σ R) :=
  by 
    simp [monomial_eq]

@[simp]
theorem coeff_monomial [DecidableEq σ] m n a : coeff m (monomial n a : MvPolynomial σ R) = if n = m then a else 0 :=
  single_apply

@[simp]
theorem coeff_C [DecidableEq σ] m a : coeff m (C a : MvPolynomial σ R) = if 0 = m then a else 0 :=
  single_apply

theorem coeff_one [DecidableEq σ] m : coeff m (1 : MvPolynomial σ R) = if 0 = m then 1 else 0 :=
  coeff_C m 1

@[simp]
theorem coeff_zero_C a : coeff 0 (C a : MvPolynomial σ R) = a :=
  single_eq_same

@[simp]
theorem coeff_zero_one : coeff 0 (1 : MvPolynomial σ R) = 1 :=
  coeff_zero_C 1

-- error in Data.MvPolynomial.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem coeff_X_pow
[decidable_eq σ]
(i : σ)
(m)
(k : exprℕ()) : «expr = »(coeff m («expr ^ »(X i, k) : mv_polynomial σ R), if «expr = »(single i k, m) then 1 else 0) :=
begin
  have [] [] [":=", expr coeff_monomial m (finsupp.single i k) (1 : R)],
  rwa ["[", expr @monomial_eq _ _ (1 : R) (finsupp.single i k) _, ",", expr C_1, ",", expr one_mul, ",", expr finsupp.prod_single_index, "]"] ["at", ident this],
  exact [expr pow_zero _]
end

theorem coeff_X' [DecidableEq σ] (i : σ) m : coeff m (X i : MvPolynomial σ R) = if single i 1 = m then 1 else 0 :=
  by 
    rw [←coeff_X_pow, pow_oneₓ]

@[simp]
theorem coeff_X (i : σ) : coeff (single i 1) (X i : MvPolynomial σ R) = 1 :=
  by 
    rw [coeff_X', if_pos rfl]

-- error in Data.MvPolynomial.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem coeff_C_mul
(m)
(a : R)
(p : mv_polynomial σ R) : «expr = »(coeff m «expr * »(C a, p), «expr * »(a, coeff m p)) :=
begin
  rw ["[", expr mul_def, ",", expr sum_C, "]"] [],
  { simp [] [] [] ["[", expr sum_def, ",", expr coeff_sum, "]"] [] [] { contextual := tt } },
  simp [] [] [] [] [] []
end

theorem coeff_mul (p q : MvPolynomial σ R) (n : σ →₀ ℕ) :
  coeff n (p*q) = ∑x in antidiagonal n, coeff x.1 p*coeff x.2 q :=
  AddMonoidAlgebra.mul_apply_antidiagonal p q _ _$ fun p => mem_antidiagonal

@[simp]
theorem coeff_mul_monomial m (s : σ →₀ ℕ) (r : R) (p : MvPolynomial σ R) : coeff (m+s) (p*monomial s r) = coeff m p*r :=
  AddMonoidAlgebra.mul_single_apply_aux p _ _ _ _ fun a => add_left_injₓ _

@[simp]
theorem coeff_monomial_mul m (s : σ →₀ ℕ) (r : R) (p : MvPolynomial σ R) : coeff (s+m) (monomial s r*p) = r*coeff m p :=
  AddMonoidAlgebra.single_mul_apply_aux p _ _ _ _ fun a => add_right_injₓ _

@[simp]
theorem coeff_mul_X m (s : σ) (p : MvPolynomial σ R) : coeff (m+single s 1) (p*X s) = coeff m p :=
  (coeff_mul_monomial _ _ _ _).trans (mul_oneₓ _)

@[simp]
theorem coeff_X_mul m (s : σ) (p : MvPolynomial σ R) : coeff (single s 1+m) (X s*p) = coeff m p :=
  (coeff_monomial_mul _ _ _ _).trans (one_mulₓ _)

@[simp]
theorem support_mul_X (s : σ) (p : MvPolynomial σ R) :
  (p*X s).support = p.support.map (addRightEmbedding (single s 1)) :=
  AddMonoidAlgebra.support_mul_single p _
    (by 
      simp )
    _

@[simp]
theorem support_X_mul (s : σ) (p : MvPolynomial σ R) :
  (X s*p).support = p.support.map (addLeftEmbedding (single s 1)) :=
  AddMonoidAlgebra.support_single_mul p _
    (by 
      simp )
    _

-- error in Data.MvPolynomial.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem coeff_mul_monomial'
(m)
(s : «expr →₀ »(σ, exprℕ()))
(r : R)
(p : mv_polynomial σ R) : «expr = »(coeff m «expr * »(p, monomial s r), if «expr ≤ »(s, m) then «expr * »(coeff «expr - »(m, s) p, r) else 0) :=
begin
  obtain [ident rfl, "|", ident hr, ":=", expr eq_or_ne r 0],
  { simp [] [] ["only"] ["[", expr monomial_zero, ",", expr coeff_zero, ",", expr mul_zero, ",", expr if_t_t, "]"] [] [] },
  haveI [] [":", expr nontrivial R] [":=", expr nontrivial_of_ne _ _ hr],
  split_ifs [] ["with", ident h, ident h],
  { conv_rhs [] [] { rw ["<-", expr coeff_mul_monomial _ s] },
    congr' [] ["with", ident t],
    rw [expr tsub_add_cancel_of_le h] [] },
  { rw ["<-", expr not_mem_support_iff] [],
    intro [ident hm],
    apply [expr h],
    have [ident H] [] [":=", expr support_mul _ _ hm],
    simp [] [] ["only"] ["[", expr finset.mem_bUnion, "]"] [] ["at", ident H],
    rcases [expr H, "with", "⟨", ident j, ",", ident hj, ",", ident i', ",", ident hi', ",", ident H, "⟩"],
    rw ["[", expr support_monomial, ",", expr if_neg hr, ",", expr finset.mem_singleton, "]"] ["at", ident hi'],
    subst [expr i'],
    rw [expr finset.mem_singleton] ["at", ident H],
    subst [expr m],
    exact [expr le_add_left le_rfl] }
end

theorem coeff_monomial_mul' m (s : σ →₀ ℕ) (r : R) (p : MvPolynomial σ R) :
  coeff m (monomial s r*p) = if s ≤ m then r*coeff (m - s) p else 0 :=
  by 
    rw [mul_commₓ, mul_commₓ r]
    exact coeff_mul_monomial' _ _ _ _

theorem coeff_mul_X' [DecidableEq σ] m (s : σ) (p : MvPolynomial σ R) :
  coeff m (p*X s) = if s ∈ m.support then coeff (m - single s 1) p else 0 :=
  by 
    refine' (coeff_mul_monomial' _ _ _ _).trans _ 
    simpRw [Finsupp.single_le_iff, Finsupp.mem_support_iff, Nat.succ_le_iff, pos_iff_ne_zero, mul_oneₓ]
    congr

theorem coeff_X_mul' [DecidableEq σ] m (s : σ) (p : MvPolynomial σ R) :
  coeff m (X s*p) = if s ∈ m.support then coeff (m - single s 1) p else 0 :=
  by 
    refine' (coeff_monomial_mul' _ _ _ _).trans _ 
    simpRw [Finsupp.single_le_iff, Finsupp.mem_support_iff, Nat.succ_le_iff, pos_iff_ne_zero, one_mulₓ]
    congr

theorem eq_zero_iff {p : MvPolynomial σ R} : p = 0 ↔ ∀ d, coeff d p = 0 :=
  by 
    rw [ext_iff]
    simp only [coeff_zero]

theorem ne_zero_iff {p : MvPolynomial σ R} : p ≠ 0 ↔ ∃ d, coeff d p ≠ 0 :=
  by 
    rw [Ne.def, eq_zero_iff]
    pushNeg

theorem exists_coeff_ne_zero {p : MvPolynomial σ R} (h : p ≠ 0) : ∃ d, coeff d p ≠ 0 :=
  ne_zero_iff.mp h

theorem C_dvd_iff_dvd_coeff (r : R) (φ : MvPolynomial σ R) : C r ∣ φ ↔ ∀ i, r ∣ φ.coeff i :=
  by 
    split 
    ·
      rintro ⟨φ, rfl⟩ c 
      rw [coeff_C_mul]
      apply dvd_mul_right
    ·
      intro h 
      choose c hc using h 
      classical 
      let c' : (σ →₀ ℕ) → R := fun i => if i ∈ φ.support then c i else 0
      let ψ : MvPolynomial σ R := ∑i in φ.support, monomial i (c' i)
      use ψ 
      apply MvPolynomial.ext 
      intro i 
      simp only [coeff_C_mul, coeff_sum, coeff_monomial, Finset.sum_ite_eq', c']
      splitIfs with hi hi
      ·
        rw [hc]
      ·
        rw [not_mem_support_iff] at hi 
        rwa [mul_zero]

end Coeff

section ConstantCoeff

/--
`constant_coeff p` returns the constant term of the polynomial `p`, defined as `coeff 0 p`.
This is a ring homomorphism.
-/
def constant_coeff : MvPolynomial σ R →+* R :=
  { toFun := coeff 0,
    map_one' :=
      by 
        simp [coeff, AddMonoidAlgebra.one_def],
    map_mul' :=
      by 
        simp [coeff_mul, Finsupp.support_single_ne_zero],
    map_zero' := coeff_zero _, map_add' := coeff_add _ }

theorem constant_coeff_eq : (constant_coeff : MvPolynomial σ R → R) = coeff 0 :=
  rfl

@[simp]
theorem constant_coeff_C (r : R) : constant_coeff (C r : MvPolynomial σ R) = r :=
  by 
    simp [constant_coeff_eq]

@[simp]
theorem constant_coeff_X (i : σ) : constant_coeff (X i : MvPolynomial σ R) = 0 :=
  by 
    simp [constant_coeff_eq]

theorem constant_coeff_monomial [DecidableEq σ] (d : σ →₀ ℕ) (r : R) :
  constant_coeff (monomial d r) = if d = 0 then r else 0 :=
  by 
    rw [constant_coeff_eq, coeff_monomial]

variable(σ R)

@[simp]
theorem constant_coeff_comp_C : constant_coeff.comp (C : R →+* MvPolynomial σ R) = RingHom.id R :=
  by 
    ext 
    apply constant_coeff_C

@[simp]
theorem constant_coeff_comp_algebra_map : constant_coeff.comp (algebraMap R (MvPolynomial σ R)) = RingHom.id R :=
  constant_coeff_comp_C _ _

end ConstantCoeff

section AsSum

@[simp]
theorem support_sum_monomial_coeff (p : MvPolynomial σ R) : (∑v in p.support, monomial v (coeff v p)) = p :=
  Finsupp.sum_single p

theorem as_sum (p : MvPolynomial σ R) : p = ∑v in p.support, monomial v (coeff v p) :=
  (support_sum_monomial_coeff p).symm

end AsSum

section Eval₂

variable(f : R →+* S₁)(g : σ → S₁)

/-- Evaluate a polynomial `p` given a valuation `g` of all the variables
  and a ring hom `f` from the scalar ring to the target -/
def eval₂ (p : MvPolynomial σ R) : S₁ :=
  p.sum fun s a => f a*s.prod fun n e => g n ^ e

theorem eval₂_eq (g : R →+* S₁) (x : σ → S₁) (f : MvPolynomial σ R) :
  f.eval₂ g x = ∑d in f.support, g (f.coeff d)*∏i in d.support, x i ^ d i :=
  rfl

theorem eval₂_eq' [Fintype σ] (g : R →+* S₁) (x : σ → S₁) (f : MvPolynomial σ R) :
  f.eval₂ g x = ∑d in f.support, g (f.coeff d)*∏i, x i ^ d i :=
  by 
    simp only [eval₂_eq, ←Finsupp.prod_pow]
    rfl

@[simp]
theorem eval₂_zero : (0 : MvPolynomial σ R).eval₂ f g = 0 :=
  Finsupp.sum_zero_index

section 

@[simp]
theorem eval₂_add : (p+q).eval₂ f g = p.eval₂ f g+q.eval₂ f g :=
  Finsupp.sum_add_index
    (by 
      simp [f.map_zero])
    (by 
      simp [add_mulₓ, f.map_add])

@[simp]
theorem eval₂_monomial : (monomial s a).eval₂ f g = f a*s.prod fun n e => g n ^ e :=
  Finsupp.sum_single_index
    (by 
      simp [f.map_zero])

@[simp]
theorem eval₂_C a : (C a).eval₂ f g = f a :=
  by 
    rw [C_apply, eval₂_monomial, prod_zero_index, mul_oneₓ]

@[simp]
theorem eval₂_one : (1 : MvPolynomial σ R).eval₂ f g = 1 :=
  (eval₂_C _ _ _).trans f.map_one

@[simp]
theorem eval₂_X n : (X n).eval₂ f g = g n :=
  by 
    simp [eval₂_monomial, f.map_one, X, prod_single_index, pow_oneₓ]

theorem eval₂_mul_monomial : ∀ {s a}, (p*monomial s a).eval₂ f g = (p.eval₂ f g*f a)*s.prod fun n e => g n ^ e :=
  by 
    apply MvPolynomial.induction_on p
    ·
      intro a' s a 
      simp [C_mul_monomial, eval₂_monomial, f.map_mul]
    ·
      intro p q ih_p ih_q 
      simp [add_mulₓ, eval₂_add, ih_p, ih_q]
    ·
      intro p n ih s a 
      exact
        calc ((p*X n)*monomial s a).eval₂ f g = (p*monomial (single n 1+s) a).eval₂ f g :=
          by 
            rw [monomial_single_add, pow_oneₓ, mul_assocₓ]
          _ = ((p*monomial (single n 1) 1).eval₂ f g*f a)*s.prod fun n e => g n ^ e :=
          by 
            simp [ih, prod_single_index, prod_add_index, pow_oneₓ, pow_addₓ, mul_assocₓ, mul_left_commₓ, f.map_one,
              -add_commₓ]
          

theorem eval₂_mul_C : (p*C a).eval₂ f g = p.eval₂ f g*f a :=
  (eval₂_mul_monomial _ _).trans$
    by 
      simp 

-- error in Data.MvPolynomial.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp] theorem eval₂_mul : ∀ {p}, «expr = »(«expr * »(p, q).eval₂ f g, «expr * »(p.eval₂ f g, q.eval₂ f g)) :=
begin
  apply [expr mv_polynomial.induction_on q],
  { simp [] [] [] ["[", expr eval₂_C, ",", expr eval₂_mul_C, "]"] [] [] },
  { simp [] [] [] ["[", expr mul_add, ",", expr eval₂_add, "]"] [] [] { contextual := tt } },
  { simp [] [] [] ["[", expr X, ",", expr eval₂_monomial, ",", expr eval₂_mul_monomial, ",", "<-", expr mul_assoc, "]"] [] [] { contextual := tt } }
end

@[simp]
theorem eval₂_pow {p : MvPolynomial σ R} : ∀ {n : ℕ}, (p ^ n).eval₂ f g = p.eval₂ f g ^ n
| 0 =>
  by 
    rw [pow_zeroₓ, pow_zeroₓ]
    exact eval₂_one _ _
| n+1 =>
  by 
    rw [pow_addₓ, pow_oneₓ, pow_addₓ, pow_oneₓ, eval₂_mul, eval₂_pow]

/-- `mv_polynomial.eval₂` as a `ring_hom`. -/
def eval₂_hom (f : R →+* S₁) (g : σ → S₁) : MvPolynomial σ R →+* S₁ :=
  { toFun := eval₂ f g, map_one' := eval₂_one _ _, map_mul' := fun p q => eval₂_mul _ _, map_zero' := eval₂_zero _ _,
    map_add' := fun p q => eval₂_add _ _ }

@[simp]
theorem coe_eval₂_hom (f : R →+* S₁) (g : σ → S₁) : «expr⇑ » (eval₂_hom f g) = eval₂ f g :=
  rfl

theorem eval₂_hom_congr {f₁ f₂ : R →+* S₁} {g₁ g₂ : σ → S₁} {p₁ p₂ : MvPolynomial σ R} :
  f₁ = f₂ → g₁ = g₂ → p₁ = p₂ → eval₂_hom f₁ g₁ p₁ = eval₂_hom f₂ g₂ p₂ :=
  by 
    rintro rfl rfl rfl <;> rfl

end 

@[simp]
theorem eval₂_hom_C (f : R →+* S₁) (g : σ → S₁) (r : R) : eval₂_hom f g (C r) = f r :=
  eval₂_C f g r

@[simp]
theorem eval₂_hom_X' (f : R →+* S₁) (g : σ → S₁) (i : σ) : eval₂_hom f g (X i) = g i :=
  eval₂_X f g i

@[simp]
theorem comp_eval₂_hom [CommSemiringₓ S₂] (f : R →+* S₁) (g : σ → S₁) (φ : S₁ →+* S₂) :
  φ.comp (eval₂_hom f g) = eval₂_hom (φ.comp f) fun i => φ (g i) :=
  by 
    apply MvPolynomial.ring_hom_ext
    ·
      intro r 
      rw [RingHom.comp_apply, eval₂_hom_C, eval₂_hom_C, RingHom.comp_apply]
    ·
      intro i 
      rw [RingHom.comp_apply, eval₂_hom_X', eval₂_hom_X']

theorem map_eval₂_hom [CommSemiringₓ S₂] (f : R →+* S₁) (g : σ → S₁) (φ : S₁ →+* S₂) (p : MvPolynomial σ R) :
  φ (eval₂_hom f g p) = eval₂_hom (φ.comp f) (fun i => φ (g i)) p :=
  by 
    rw [←comp_eval₂_hom]
    rfl

theorem eval₂_hom_monomial (f : R →+* S₁) (g : σ → S₁) (d : σ →₀ ℕ) (r : R) :
  eval₂_hom f g (monomial d r) = f r*d.prod fun i k => g i ^ k :=
  by 
    simp only [monomial_eq, RingHom.map_mul, eval₂_hom_C, Finsupp.prod, RingHom.map_prod, RingHom.map_pow, eval₂_hom_X']

section 

-- error in Data.MvPolynomial.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem eval₂_comp_left
{S₂}
[comm_semiring S₂]
(k : «expr →+* »(S₁, S₂))
(f : «expr →+* »(R, S₁))
(g : σ → S₁)
(p) : «expr = »(k (eval₂ f g p), eval₂ (k.comp f) «expr ∘ »(k, g) p) :=
by apply [expr mv_polynomial.induction_on p]; simp [] [] [] ["[", expr eval₂_add, ",", expr k.map_add, ",", expr eval₂_mul, ",", expr k.map_mul, "]"] [] [] { contextual := tt }

end 

-- error in Data.MvPolynomial.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp] theorem eval₂_eta (p : mv_polynomial σ R) : «expr = »(eval₂ C X p, p) :=
by apply [expr mv_polynomial.induction_on p]; simp [] [] [] ["[", expr eval₂_add, ",", expr eval₂_mul, "]"] [] [] { contextual := tt }

theorem eval₂_congr (g₁ g₂ : σ → S₁) (h : ∀ {i : σ} {c : σ →₀ ℕ}, i ∈ c.support → coeff c p ≠ 0 → g₁ i = g₂ i) :
  p.eval₂ f g₁ = p.eval₂ f g₂ :=
  by 
    apply Finset.sum_congr rfl 
    intro c hc 
    dsimp 
    congr 1
    apply Finset.prod_congr rfl 
    intro i hi 
    dsimp 
    congr 1
    apply h hi 
    rwa [Finsupp.mem_support_iff] at hc

@[simp]
theorem eval₂_prod (s : Finset S₂) (p : S₂ → MvPolynomial σ R) : eval₂ f g (∏x in s, p x) = ∏x in s, eval₂ f g (p x) :=
  (eval₂_hom f g).map_prod _ s

@[simp]
theorem eval₂_sum (s : Finset S₂) (p : S₂ → MvPolynomial σ R) : eval₂ f g (∑x in s, p x) = ∑x in s, eval₂ f g (p x) :=
  (eval₂_hom f g).map_sum _ s

attribute [toAdditive] eval₂_prod

theorem eval₂_assoc (q : S₂ → MvPolynomial σ R) (p : MvPolynomial S₂ R) :
  eval₂ f (fun t => eval₂ f g (q t)) p = eval₂ f g (eval₂ C q p) :=
  by 
    show _ = eval₂_hom f g (eval₂ C q p)
    rw [eval₂_comp_left (eval₂_hom f g)]
    congr with a 
    simp 

end Eval₂

section Eval

variable{f : σ → R}

/-- Evaluate a polynomial `p` given a valuation `f` of all the variables -/
def eval (f : σ → R) : MvPolynomial σ R →+* R :=
  eval₂_hom (RingHom.id _) f

theorem eval_eq (x : σ → R) (f : MvPolynomial σ R) : eval x f = ∑d in f.support, f.coeff d*∏i in d.support, x i ^ d i :=
  rfl

theorem eval_eq' [Fintype σ] (x : σ → R) (f : MvPolynomial σ R) : eval x f = ∑d in f.support, f.coeff d*∏i, x i ^ d i :=
  eval₂_eq' (RingHom.id R) x f

theorem eval_monomial : eval f (monomial s a) = a*s.prod fun n e => f n ^ e :=
  eval₂_monomial _ _

@[simp]
theorem eval_C : ∀ a, eval f (C a) = a :=
  eval₂_C _ _

@[simp]
theorem eval_X : ∀ n, eval f (X n) = f n :=
  eval₂_X _ _

@[simp]
theorem smul_eval x (p : MvPolynomial σ R) s : eval x (s • p) = s*eval x p :=
  by 
    rw [smul_eq_C_mul, (eval x).map_mul, eval_C]

theorem eval_sum {ι : Type _} (s : Finset ι) (f : ι → MvPolynomial σ R) (g : σ → R) :
  eval g (∑i in s, f i) = ∑i in s, eval g (f i) :=
  (eval g).map_sum _ _

@[toAdditive]
theorem eval_prod {ι : Type _} (s : Finset ι) (f : ι → MvPolynomial σ R) (g : σ → R) :
  eval g (∏i in s, f i) = ∏i in s, eval g (f i) :=
  (eval g).map_prod _ _

theorem eval_assoc {τ} (f : σ → MvPolynomial τ R) (g : τ → R) (p : MvPolynomial σ R) :
  eval (eval g ∘ f) p = eval g (eval₂ C f p) :=
  by 
    rw [eval₂_comp_left (eval g)]
    unfold eval 
    simp only [coe_eval₂_hom]
    congr with a 
    simp 

end Eval

section Map

variable(f : R →+* S₁)

/-- `map f p` maps a polynomial `p` across a ring hom `f` -/
def map : MvPolynomial σ R →+* MvPolynomial σ S₁ :=
  eval₂_hom (C.comp f) X

@[simp]
theorem map_monomial (s : σ →₀ ℕ) (a : R) : map f (monomial s a) = monomial s (f a) :=
  (eval₂_monomial _ _).trans monomial_eq.symm

@[simp]
theorem map_C : ∀ (a : R), map f (C a : MvPolynomial σ R) = C (f a) :=
  map_monomial _ _

@[simp]
theorem map_X : ∀ (n : σ), map f (X n : MvPolynomial σ R) = X n :=
  eval₂_X _ _

theorem map_id : ∀ (p : MvPolynomial σ R), map (RingHom.id R) p = p :=
  eval₂_eta

theorem map_map [CommSemiringₓ S₂] (g : S₁ →+* S₂) (p : MvPolynomial σ R) : map g (map f p) = map (g.comp f) p :=
  (eval₂_comp_left (map g) (C.comp f) X p).trans$
    by 
      congr
      ·
        ext1 a 
        simp only [map_C, comp_app, RingHom.coe_comp]
      ·
        ext1 n 
        simp only [map_X, comp_app]

-- error in Data.MvPolynomial.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem eval₂_eq_eval_map (g : σ → S₁) (p : mv_polynomial σ R) : «expr = »(p.eval₂ f g, eval g (map f p)) :=
begin
  unfold [ident map, ident eval] [],
  simp [] [] ["only"] ["[", expr coe_eval₂_hom, "]"] [] [],
  have [ident h] [] [":=", expr eval₂_comp_left (eval₂_hom _ g)],
  dsimp [] [] [] ["at", ident h],
  rw [expr h] [],
  congr,
  { ext1 [] [ident a],
    simp [] [] ["only"] ["[", expr coe_eval₂_hom, ",", expr ring_hom.id_apply, ",", expr comp_app, ",", expr eval₂_C, ",", expr ring_hom.coe_comp, "]"] [] [] },
  { ext1 [] [ident n],
    simp [] [] ["only"] ["[", expr comp_app, ",", expr eval₂_X, "]"] [] [] }
end

theorem eval₂_comp_right {S₂} [CommSemiringₓ S₂] (k : S₁ →+* S₂) (f : R →+* S₁) (g : σ → S₁) p :
  k (eval₂ f g p) = eval₂ k (k ∘ g) (map f p) :=
  by 
    apply MvPolynomial.induction_on p
    ·
      intro r 
      rw [eval₂_C, map_C, eval₂_C]
    ·
      intro p q hp hq 
      rw [eval₂_add, k.map_add, (map f).map_add, eval₂_add, hp, hq]
    ·
      intro p s hp 
      rw [eval₂_mul, k.map_mul, (map f).map_mul, eval₂_mul, map_X, hp, eval₂_X, eval₂_X]

theorem map_eval₂ (f : R →+* S₁) (g : S₂ → MvPolynomial S₃ R) (p : MvPolynomial S₂ R) :
  map f (eval₂ C g p) = eval₂ C (map f ∘ g) (map f p) :=
  by 
    apply MvPolynomial.induction_on p
    ·
      intro r 
      rw [eval₂_C, map_C, map_C, eval₂_C]
    ·
      intro p q hp hq 
      rw [eval₂_add, (map f).map_add, hp, hq, (map f).map_add, eval₂_add]
    ·
      intro p s hp 
      rw [eval₂_mul, (map f).map_mul, hp, (map f).map_mul, map_X, eval₂_mul, eval₂_X, eval₂_X]

theorem coeff_map (p : MvPolynomial σ R) : ∀ (m : σ →₀ ℕ), coeff m (map f p) = f (coeff m p) :=
  by 
    apply MvPolynomial.induction_on p <;> clear p
    ·
      intro r m 
      rw [map_C]
      simp only [coeff_C]
      splitIfs
      ·
        rfl 
      rw [f.map_zero]
    ·
      intro p q hp hq m 
      simp only [hp, hq, (map f).map_add, coeff_add]
      rw [f.map_add]
    ·
      intro p i hp m 
      simp only [hp, (map f).map_mul, map_X]
      simp only [hp, mem_support_iff, coeff_mul_X']
      splitIfs
      ·
        rfl 
      rw [f.map_zero]

theorem map_injective (hf : Function.Injective f) : Function.Injective (map f : MvPolynomial σ R → MvPolynomial σ S₁) :=
  by 
    intro p q h 
    simp only [ext_iff, coeff_map] at h⊢
    intro m 
    exact hf (h m)

theorem map_surjective (hf : Function.Surjective f) :
  Function.Surjective (map f : MvPolynomial σ R → MvPolynomial σ S₁) :=
  fun p =>
    by 
      induction' p using MvPolynomial.induction_on' with i fr a b ha hb
      ·
        obtain ⟨r, rfl⟩ := hf fr 
        exact ⟨monomial i r, map_monomial _ _ _⟩
      ·
        obtain ⟨a, rfl⟩ := ha 
        obtain ⟨b, rfl⟩ := hb 
        exact ⟨a+b, RingHom.map_add _ _ _⟩

/-- If `f` is a left-inverse of `g` then `map f` is a left-inverse of `map g`. -/
theorem map_left_inverse {f : R →+* S₁} {g : S₁ →+* R} (hf : Function.LeftInverse f g) :
  Function.LeftInverse (map f : MvPolynomial σ R → MvPolynomial σ S₁) (map g) :=
  fun x =>
    by 
      rw [map_map, (RingHom.ext hf : f.comp g = RingHom.id _), map_id]

/-- If `f` is a right-inverse of `g` then `map f` is a right-inverse of `map g`. -/
theorem map_right_inverse {f : R →+* S₁} {g : S₁ →+* R} (hf : Function.RightInverse f g) :
  Function.RightInverse (map f : MvPolynomial σ R → MvPolynomial σ S₁) (map g) :=
  (map_left_inverse hf.left_inverse).RightInverse

-- error in Data.MvPolynomial.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem eval_map
(f : «expr →+* »(R, S₁))
(g : σ → S₁)
(p : mv_polynomial σ R) : «expr = »(eval g (map f p), eval₂ f g p) :=
by { apply [expr mv_polynomial.induction_on p]; { simp [] [] [] [] [] [] { contextual := tt } } }

@[simp]
theorem eval₂_map [CommSemiringₓ S₂] (f : R →+* S₁) (g : σ → S₂) (φ : S₁ →+* S₂) (p : MvPolynomial σ R) :
  eval₂ φ g (map f p) = eval₂ (φ.comp f) g p :=
  by 
    rw [←eval_map, ←eval_map, map_map]

@[simp]
theorem eval₂_hom_map_hom [CommSemiringₓ S₂] (f : R →+* S₁) (g : σ → S₂) (φ : S₁ →+* S₂) (p : MvPolynomial σ R) :
  eval₂_hom φ g (map f p) = eval₂_hom (φ.comp f) g p :=
  eval₂_map f g φ p

@[simp]
theorem constant_coeff_map (f : R →+* S₁) (φ : MvPolynomial σ R) :
  constant_coeff (MvPolynomial.map f φ) = f (constant_coeff φ) :=
  coeff_map f φ 0

theorem constant_coeff_comp_map (f : R →+* S₁) :
  (constant_coeff : MvPolynomial σ S₁ →+* S₁).comp (MvPolynomial.map f) = f.comp constant_coeff :=
  by 
    ext <;> simp 

theorem support_map_subset (p : MvPolynomial σ R) : (map f p).support ⊆ p.support :=
  by 
    intro x 
    simp only [mem_support_iff]
    contrapose! 
    change p.coeff x = 0 → (map f p).coeff x = 0
    rw [coeff_map]
    intro hx 
    rw [hx]
    exact RingHom.map_zero f

theorem support_map_of_injective (p : MvPolynomial σ R) {f : R →+* S₁} (hf : injective f) :
  (map f p).support = p.support :=
  by 
    apply Finset.Subset.antisymm
    ·
      exact MvPolynomial.support_map_subset _ _ 
    intro x hx 
    rw [mem_support_iff]
    contrapose! hx 
    simp only [not_not, mem_support_iff]
    change (map f p).coeff x = 0 at hx 
    rw [coeff_map, ←f.map_zero] at hx 
    exact hf hx

theorem C_dvd_iff_map_hom_eq_zero (q : R →+* S₁) (r : R) (hr : ∀ (r' : R), q r' = 0 ↔ r ∣ r') (φ : MvPolynomial σ R) :
  C r ∣ φ ↔ map q φ = 0 :=
  by 
    rw [C_dvd_iff_dvd_coeff, MvPolynomial.ext_iff]
    simp only [coeff_map, coeff_zero, hr]

theorem map_map_range_eq_iff (f : R →+* S₁) (g : S₁ → R) (hg : g 0 = 0) (φ : MvPolynomial σ S₁) :
  map f (Finsupp.mapRange g hg φ) = φ ↔ ∀ d, f (g (coeff d φ)) = coeff d φ :=
  by 
    rw [MvPolynomial.ext_iff]
    apply forall_congrₓ 
    intro m 
    rw [coeff_map]
    apply eq_iff_eq_cancel_right.mpr 
    rfl

-- error in Data.MvPolynomial.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If `f : S₁ →ₐ[R] S₂` is a morphism of `R`-algebras, then so is `mv_polynomial.map f`. -/
@[simps #[]]
def map_alg_hom
[comm_semiring S₂]
[algebra R S₁]
[algebra R S₂]
(f : «expr →ₐ[ ] »(S₁, R, S₂)) : «expr →ₐ[ ] »(mv_polynomial σ S₁, R, mv_polynomial σ S₂) :=
{ to_fun := map «expr↑ »(f),
  commutes' := λ r, begin
    have [ident h₁] [":", expr «expr = »(algebra_map R (mv_polynomial σ S₁) r, C (algebra_map R S₁ r))] [":=", expr rfl],
    have [ident h₂] [":", expr «expr = »(algebra_map R (mv_polynomial σ S₂) r, C (algebra_map R S₂ r))] [":=", expr rfl],
    rw ["[", expr h₁, ",", expr h₂, ",", expr map, ",", expr eval₂_hom_C, ",", expr ring_hom.comp_apply, ",", expr alg_hom.coe_to_ring_hom, ",", expr alg_hom.commutes, "]"] []
  end,
  ..map «expr↑ »(f) }

@[simp]
theorem map_alg_hom_id [Algebra R S₁] : map_alg_hom (AlgHom.id R S₁) = AlgHom.id R (MvPolynomial σ S₁) :=
  AlgHom.ext map_id

@[simp]
theorem map_alg_hom_coe_ring_hom [CommSemiringₓ S₂] [Algebra R S₁] [Algebra R S₂] (f : S₁ →ₐ[R] S₂) :
  «expr↑ » (map_alg_hom f : _ →ₐ[R] MvPolynomial σ S₂) = (map («expr↑ » f) : MvPolynomial σ S₁ →+* MvPolynomial σ S₂) :=
  RingHom.mk_coe _ _ _ _ _

end Map

section Aeval

/-! ### The algebra of multivariate polynomials -/


variable[Algebra R S₁][CommSemiringₓ S₂]

variable(f : σ → S₁)

/-- A map `σ → S₁` where `S₁` is an algebra over `R` generates an `R`-algebra homomorphism
from multivariate polynomials over `σ` to `S₁`. -/
def aeval : MvPolynomial σ R →ₐ[R] S₁ :=
  { eval₂_hom (algebraMap R S₁) f with commutes' := fun r => eval₂_C _ _ _ }

theorem aeval_def (p : MvPolynomial σ R) : aeval f p = eval₂ (algebraMap R S₁) f p :=
  rfl

theorem aeval_eq_eval₂_hom (p : MvPolynomial σ R) : aeval f p = eval₂_hom (algebraMap R S₁) f p :=
  rfl

@[simp]
theorem aeval_X (s : σ) : aeval f (X s : MvPolynomial _ R) = f s :=
  eval₂_X _ _ _

@[simp]
theorem aeval_C (r : R) : aeval f (C r) = algebraMap R S₁ r :=
  eval₂_C _ _ _

theorem aeval_unique (φ : MvPolynomial σ R →ₐ[R] S₁) : φ = aeval (φ ∘ X) :=
  by 
    ext i 
    simp 

theorem comp_aeval {B : Type _} [CommSemiringₓ B] [Algebra R B] (φ : S₁ →ₐ[R] B) :
  φ.comp (aeval f) = aeval fun i => φ (f i) :=
  by 
    ext i 
    simp 

@[simp]
theorem map_aeval {B : Type _} [CommSemiringₓ B] (g : σ → S₁) (φ : S₁ →+* B) (p : MvPolynomial σ R) :
  φ (aeval g p) = eval₂_hom (φ.comp (algebraMap R S₁)) (fun i => φ (g i)) p :=
  by 
    rw [←comp_eval₂_hom]
    rfl

@[simp]
theorem eval₂_hom_zero (f : R →+* S₂) (p : MvPolynomial σ R) : eval₂_hom f (0 : σ → S₂) p = f (constant_coeff p) :=
  by 
    suffices  : eval₂_hom f (0 : σ → S₂) = f.comp constant_coeff 
    exact RingHom.congr_fun this p 
    ext <;> simp 

@[simp]
theorem eval₂_hom_zero' (f : R →+* S₂) (p : MvPolynomial σ R) :
  eval₂_hom f (fun _ => 0 : σ → S₂) p = f (constant_coeff p) :=
  eval₂_hom_zero f p

@[simp]
theorem aeval_zero (p : MvPolynomial σ R) : aeval (0 : σ → S₁) p = algebraMap _ _ (constant_coeff p) :=
  eval₂_hom_zero (algebraMap R S₁) p

@[simp]
theorem aeval_zero' (p : MvPolynomial σ R) : aeval (fun _ => 0 : σ → S₁) p = algebraMap _ _ (constant_coeff p) :=
  aeval_zero p

theorem aeval_monomial (g : σ → S₁) (d : σ →₀ ℕ) (r : R) :
  aeval g (monomial d r) = algebraMap _ _ r*d.prod fun i k => g i ^ k :=
  eval₂_hom_monomial _ _ _ _

theorem eval₂_hom_eq_zero (f : R →+* S₂) (g : σ → S₂) (φ : MvPolynomial σ R)
  (h : ∀ d, φ.coeff d ≠ 0 → ∃ (i : _)(_ : i ∈ d.support), g i = 0) : eval₂_hom f g φ = 0 :=
  by 
    rw [φ.as_sum, RingHom.map_sum, Finset.sum_eq_zero]
    intro d hd 
    obtain ⟨i, hi, hgi⟩ : ∃ (i : _)(_ : i ∈ d.support), g i = 0 := h d (finsupp.mem_support_iff.mp hd)
    rw [eval₂_hom_monomial, Finsupp.prod, Finset.prod_eq_zero hi, mul_zero]
    rw [hgi, zero_pow]
    rwa [pos_iff_ne_zero, ←Finsupp.mem_support_iff]

theorem aeval_eq_zero [Algebra R S₂] (f : σ → S₂) (φ : MvPolynomial σ R)
  (h : ∀ d, φ.coeff d ≠ 0 → ∃ (i : _)(_ : i ∈ d.support), f i = 0) : aeval f φ = 0 :=
  eval₂_hom_eq_zero _ _ _ h

end Aeval

section AevalTower

variable{S A B : Type _}[CommSemiringₓ S][CommSemiringₓ A][CommSemiringₓ B]

variable[Algebra S R][Algebra S A][Algebra S B]

/-- Version of `aeval` for defining algebra homs out of `mv_polynomial σ R` over a smaller base ring
  than `R`. -/
def aeval_tower (f : R →ₐ[S] A) (x : σ → A) : MvPolynomial σ R →ₐ[S] A :=
  { eval₂_hom («expr↑ » f) x with
    commutes' :=
      fun r =>
        by 
          simp [IsScalarTower.algebra_map_eq S R (MvPolynomial σ R), algebra_map_eq] }

variable(g : R →ₐ[S] A)(y : σ → A)

@[simp]
theorem aeval_tower_X (i : σ) : aeval_tower g y (X i) = y i :=
  eval₂_X _ _ _

@[simp]
theorem aeval_tower_C (x : R) : aeval_tower g y (C x) = g x :=
  eval₂_C _ _ _

@[simp]
theorem aeval_tower_comp_C : (aeval_tower g y : MvPolynomial σ R →+* A).comp C = g :=
  RingHom.ext$ aeval_tower_C _ _

@[simp]
theorem aeval_tower_algebra_map (x : R) : aeval_tower g y (algebraMap R (MvPolynomial σ R) x) = g x :=
  eval₂_C _ _ _

@[simp]
theorem aeval_tower_comp_algebra_map :
  (aeval_tower g y : MvPolynomial σ R →+* A).comp (algebraMap R (MvPolynomial σ R)) = g :=
  aeval_tower_comp_C _ _

theorem aeval_tower_to_alg_hom (x : R) : aeval_tower g y (IsScalarTower.toAlgHom S R (MvPolynomial σ R) x) = g x :=
  aeval_tower_algebra_map _ _ _

@[simp]
theorem aeval_tower_comp_to_alg_hom : (aeval_tower g y).comp (IsScalarTower.toAlgHom S R (MvPolynomial σ R)) = g :=
  AlgHom.coe_ring_hom_injective$ aeval_tower_comp_algebra_map _ _

@[simp]
theorem aeval_tower_id : aeval_tower (AlgHom.id S S) = (aeval : (σ → S) → MvPolynomial σ S →ₐ[S] S) :=
  by 
    ext 
    simp only [aeval_tower_X, aeval_X]

@[simp]
theorem aeval_tower_of_id : aeval_tower (Algebra.ofId S A) = (aeval : (σ → A) → MvPolynomial σ S →ₐ[S] A) :=
  by 
    ext 
    simp only [aeval_X, aeval_tower_X]

end AevalTower

end CommSemiringₓ

end MvPolynomial

