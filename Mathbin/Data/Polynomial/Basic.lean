/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Johannes Hölzl, Scott Morrison, Jens Wagemaker
-/
import Mathbin.Algebra.MonoidAlgebra.Basic

/-!
# Theory of univariate polynomials

This file defines `polynomial R`, the type of univariate polynomials over the semiring `R`, builds
a semiring structure on it, and gives basic definitions that are expanded in other files in this
directory.

## Main definitions

* `monomial n a` is the polynomial `a X^n`. Note that `monomial n` is defined as an `R`-linear map.
* `C a` is the constant polynomial `a`. Note that `C` is defined as a ring homomorphism.
* `X` is the polynomial `X`, i.e., `monomial 1 1`.
* `p.sum f` is `∑ n in p.support, f n (p.coeff n)`, i.e., one sums the values of functions applied
  to coefficients of the polynomial `p`.
* `p.erase n` is the polynomial `p` in which one removes the `c X^n` term.

There are often two natural variants of lemmas involving sums, depending on whether one acts on the
polynomials, or on the function. The naming convention is that one adds `index` when acting on
the polynomials. For instance,
* `sum_add_index` states that `(p + q).sum f = p.sum f + q.sum f`;
* `sum_add` states that `p.sum (λ n x, f n x + g n x) = p.sum f + p.sum g`.
* Notation to refer to `polynomial R`, as `R[X]` or `R[t]`.

## Implementation

Polynomials are defined using `add_monoid_algebra R ℕ`, where `R` is a semiring.
The variable `X` commutes with every polynomial `p`: lemma `X_mul` proves the identity
`X * p = p * X`.  The relationship to `add_monoid_algebra R ℕ` is through a structure
to make polynomials irreducible from the point of view of the kernel. Most operations
are irreducible since Lean can not compute anyway with `add_monoid_algebra`. There are two
exceptions that we make semireducible:
* The zero polynomial, so that its coefficients are definitionally equal to `0`.
* The scalar action, to permit typeclass search to unfold it to resolve potential instance
  diamonds.

The raw implementation of the equivalence between `R[X]` and `add_monoid_algebra R ℕ` is
done through `of_finsupp` and `to_finsupp` (or, equivalently, `rcases p` when `p` is a polynomial
gives an element `q` of `add_monoid_algebra R ℕ`, and conversely `⟨q⟩` gives back `p`). The
equivalence is also registered as a ring equiv in `polynomial.to_finsupp_iso`. These should
in general not be used once the basic API for polynomials is constructed.
-/


noncomputable section

/-- `polynomial R` is the type of univariate polynomials over `R`.

Polynomials should be seen as (semi-)rings with the additional constructor `X`.
The embedding from `R` is called `C`. -/
structure Polynomial (R : Type _) [Semiring R] where of_finsupp ::
  toFinsupp : AddMonoidAlgebra R ℕ
#align polynomial Polynomial

-- mathport name: polynomial
scoped[Polynomial] notation:9000 R "[X]" => Polynomial R

open AddMonoidAlgebra Finsupp Function

open BigOperators Polynomial

namespace Polynomial

universe u

variable {R : Type u} {a b : R} {m n : ℕ}

section Semiring

variable [Semiring R] {p q : R[X]}

theorem forall_iff_forall_finsupp (P : R[X] → Prop) : (∀ p, P p) ↔ ∀ q : AddMonoidAlgebra R ℕ, P ⟨q⟩ :=
  ⟨fun h q => h ⟨q⟩, fun h ⟨p⟩ => h p⟩
#align polynomial.forall_iff_forall_finsupp Polynomial.forall_iff_forall_finsupp

theorem exists_iff_exists_finsupp (P : R[X] → Prop) : (∃ p, P p) ↔ ∃ q : AddMonoidAlgebra R ℕ, P ⟨q⟩ :=
  ⟨fun ⟨⟨p⟩, hp⟩ => ⟨p, hp⟩, fun ⟨q, hq⟩ => ⟨⟨q⟩, hq⟩⟩
#align polynomial.exists_iff_exists_finsupp Polynomial.exists_iff_exists_finsupp

/-! ### Conversions to and from `add_monoid_algebra`

Since `R[X]` is not defeq to `add_monoid_algebra R ℕ`, but instead is a structure wrapping
it, we have to copy across all the arithmetic operators manually, along with the lemmas about how
they unfold around `polynomial.of_finsupp` and `polynomial.to_finsupp`.
-/


section AddMonoidAlgebra

private irreducible_def add : R[X] → R[X] → R[X]
  | ⟨a⟩, ⟨b⟩ => ⟨a + b⟩
#align polynomial.add polynomial.add

private irreducible_def neg {R : Type u} [Ring R] : R[X] → R[X]
  | ⟨a⟩ => ⟨-a⟩
#align polynomial.neg polynomial.neg

private irreducible_def mul : R[X] → R[X] → R[X]
  | ⟨a⟩, ⟨b⟩ => ⟨a * b⟩
#align polynomial.mul polynomial.mul

instance : Zero R[X] :=
  ⟨⟨0⟩⟩

instance : One R[X] :=
  ⟨⟨1⟩⟩

instance : Add R[X] :=
  ⟨add⟩

instance {R : Type u} [Ring R] : Neg R[X] :=
  ⟨neg⟩

instance {R : Type u} [Ring R] : Sub R[X] :=
  ⟨fun a b => a + -b⟩

instance : Mul R[X] :=
  ⟨mul⟩

instance {S : Type _} [SmulZeroClass S R] : SmulZeroClass S R[X] where
  smul r p := ⟨r • p.toFinsupp⟩
  smul_zero a := congr_arg of_finsupp (smul_zero a)

-- to avoid a bug in the `ring` tactic
instance (priority := 1) hasPow : Pow R[X] ℕ where pow p n := npowRec n p
#align polynomial.has_pow Polynomial.hasPow

@[simp]
theorem of_finsupp_zero : (⟨0⟩ : R[X]) = 0 :=
  rfl
#align polynomial.of_finsupp_zero Polynomial.of_finsupp_zero

@[simp]
theorem of_finsupp_one : (⟨1⟩ : R[X]) = 1 :=
  rfl
#align polynomial.of_finsupp_one Polynomial.of_finsupp_one

@[simp]
theorem of_finsupp_add {a b} : (⟨a + b⟩ : R[X]) = ⟨a⟩ + ⟨b⟩ :=
  show _ = add _ _ by rw [add]
#align polynomial.of_finsupp_add Polynomial.of_finsupp_add

@[simp]
theorem of_finsupp_neg {R : Type u} [Ring R] {a} : (⟨-a⟩ : R[X]) = -⟨a⟩ :=
  show _ = neg _ by rw [neg]
#align polynomial.of_finsupp_neg Polynomial.of_finsupp_neg

@[simp]
theorem of_finsupp_sub {R : Type u} [Ring R] {a b} : (⟨a - b⟩ : R[X]) = ⟨a⟩ - ⟨b⟩ := by
  rw [sub_eq_add_neg, of_finsupp_add, of_finsupp_neg]
  rfl
#align polynomial.of_finsupp_sub Polynomial.of_finsupp_sub

@[simp]
theorem of_finsupp_mul (a b) : (⟨a * b⟩ : R[X]) = ⟨a⟩ * ⟨b⟩ :=
  show _ = mul _ _ by rw [mul]
#align polynomial.of_finsupp_mul Polynomial.of_finsupp_mul

@[simp]
theorem of_finsupp_smul {S : Type _} [SmulZeroClass S R] (a : S) (b) : (⟨a • b⟩ : R[X]) = (a • ⟨b⟩ : R[X]) :=
  rfl
#align polynomial.of_finsupp_smul Polynomial.of_finsupp_smul

@[simp]
theorem of_finsupp_pow (a) (n : ℕ) : (⟨a ^ n⟩ : R[X]) = ⟨a⟩ ^ n := by
  change _ = npowRec n _
  induction n
  · simp [npowRec]
    
  · simp [npowRec, n_ih, pow_succ]
    
#align polynomial.of_finsupp_pow Polynomial.of_finsupp_pow

@[simp]
theorem to_finsupp_zero : (0 : R[X]).toFinsupp = 0 :=
  rfl
#align polynomial.to_finsupp_zero Polynomial.to_finsupp_zero

@[simp]
theorem to_finsupp_one : (1 : R[X]).toFinsupp = 1 :=
  rfl
#align polynomial.to_finsupp_one Polynomial.to_finsupp_one

@[simp]
theorem to_finsupp_add (a b : R[X]) : (a + b).toFinsupp = a.toFinsupp + b.toFinsupp := by
  cases a
  cases b
  rw [← of_finsupp_add]
#align polynomial.to_finsupp_add Polynomial.to_finsupp_add

@[simp]
theorem to_finsupp_neg {R : Type u} [Ring R] (a : R[X]) : (-a).toFinsupp = -a.toFinsupp := by
  cases a
  rw [← of_finsupp_neg]
#align polynomial.to_finsupp_neg Polynomial.to_finsupp_neg

@[simp]
theorem to_finsupp_sub {R : Type u} [Ring R] (a b : R[X]) : (a - b).toFinsupp = a.toFinsupp - b.toFinsupp := by
  rw [sub_eq_add_neg, ← to_finsupp_neg, ← to_finsupp_add]
  rfl
#align polynomial.to_finsupp_sub Polynomial.to_finsupp_sub

@[simp]
theorem to_finsupp_mul (a b : R[X]) : (a * b).toFinsupp = a.toFinsupp * b.toFinsupp := by
  cases a
  cases b
  rw [← of_finsupp_mul]
#align polynomial.to_finsupp_mul Polynomial.to_finsupp_mul

@[simp]
theorem to_finsupp_smul {S : Type _} [SmulZeroClass S R] (a : S) (b : R[X]) : (a • b).toFinsupp = a • b.toFinsupp :=
  rfl
#align polynomial.to_finsupp_smul Polynomial.to_finsupp_smul

@[simp]
theorem to_finsupp_pow (a : R[X]) (n : ℕ) : (a ^ n).toFinsupp = a.toFinsupp ^ n := by
  cases a
  rw [← of_finsupp_pow]
#align polynomial.to_finsupp_pow Polynomial.to_finsupp_pow

theorem _root_.is_smul_regular.polynomial {S : Type _} [Monoid S] [DistribMulAction S R] {a : S}
    (ha : IsSmulRegular R a) : IsSmulRegular R[X] a
  | ⟨x⟩, ⟨y⟩, h => congr_arg _ <| ha.Finsupp (Polynomial.of_finsupp.inj h)
#align polynomial._root_.is_smul_regular.polynomial polynomial._root_.is_smul_regular.polynomial

theorem to_finsupp_injective : Function.Injective (toFinsupp : R[X] → AddMonoidAlgebra _ _) := fun ⟨x⟩ ⟨y⟩ =>
  congr_arg _
#align polynomial.to_finsupp_injective Polynomial.to_finsupp_injective

@[simp]
theorem to_finsupp_inj {a b : R[X]} : a.toFinsupp = b.toFinsupp ↔ a = b :=
  to_finsupp_injective.eq_iff
#align polynomial.to_finsupp_inj Polynomial.to_finsupp_inj

@[simp]
theorem to_finsupp_eq_zero {a : R[X]} : a.toFinsupp = 0 ↔ a = 0 := by rw [← to_finsupp_zero, to_finsupp_inj]
#align polynomial.to_finsupp_eq_zero Polynomial.to_finsupp_eq_zero

@[simp]
theorem to_finsupp_eq_one {a : R[X]} : a.toFinsupp = 1 ↔ a = 1 := by rw [← to_finsupp_one, to_finsupp_inj]
#align polynomial.to_finsupp_eq_one Polynomial.to_finsupp_eq_one

/-- A more convenient spelling of `polynomial.of_finsupp.inj_eq` in terms of `iff`. -/
theorem of_finsupp_inj {a b} : (⟨a⟩ : R[X]) = ⟨b⟩ ↔ a = b :=
  iff_of_eq of_finsupp.inj_eq
#align polynomial.of_finsupp_inj Polynomial.of_finsupp_inj

@[simp]
theorem of_finsupp_eq_zero {a} : (⟨a⟩ : R[X]) = 0 ↔ a = 0 := by rw [← of_finsupp_zero, of_finsupp_inj]
#align polynomial.of_finsupp_eq_zero Polynomial.of_finsupp_eq_zero

@[simp]
theorem of_finsupp_eq_one {a} : (⟨a⟩ : R[X]) = 1 ↔ a = 1 := by rw [← of_finsupp_one, of_finsupp_inj]
#align polynomial.of_finsupp_eq_one Polynomial.of_finsupp_eq_one

instance : Inhabited R[X] :=
  ⟨0⟩

instance : NatCast R[X] :=
  ⟨fun n => Polynomial.of_finsupp n⟩

instance : Semiring R[X] :=
  Function.Injective.semiring toFinsupp to_finsupp_injective to_finsupp_zero to_finsupp_one to_finsupp_add
    to_finsupp_mul (fun _ _ => to_finsupp_smul _ _) to_finsupp_pow fun _ => rfl

instance {S} [Monoid S] [DistribMulAction S R] : DistribMulAction S R[X] :=
  Function.Injective.distribMulAction ⟨toFinsupp, to_finsupp_zero, to_finsupp_add⟩ to_finsupp_injective to_finsupp_smul

instance {S} [Monoid S] [DistribMulAction S R] [HasFaithfulSmul S R] :
    HasFaithfulSmul S
      R[X] where eq_of_smul_eq_smul s₁ s₂ h := eq_of_smul_eq_smul fun a : ℕ →₀ R => congr_arg toFinsupp (h ⟨a⟩)

instance {S} [Semiring S] [Module S R] : Module S R[X] :=
  Function.Injective.module _ ⟨toFinsupp, to_finsupp_zero, to_finsupp_add⟩ to_finsupp_injective to_finsupp_smul

instance {S₁ S₂} [Monoid S₁] [Monoid S₂] [DistribMulAction S₁ R] [DistribMulAction S₂ R] [SmulCommClass S₁ S₂ R] :
    SmulCommClass S₁ S₂ R[X] :=
  ⟨by
    rintro _ _ ⟨⟩
    simp_rw [← of_finsupp_smul, smul_comm]⟩

instance {S₁ S₂} [HasSmul S₁ S₂] [Monoid S₁] [Monoid S₂] [DistribMulAction S₁ R] [DistribMulAction S₂ R]
    [IsScalarTower S₁ S₂ R] : IsScalarTower S₁ S₂ R[X] :=
  ⟨by
    rintro _ _ ⟨⟩
    simp_rw [← of_finsupp_smul, smul_assoc]⟩

instance is_scalar_tower_right {α K : Type _} [Semiring K] [DistribSmul α K] [IsScalarTower α K K] :
    IsScalarTower α K[X] K[X] :=
  ⟨by rintro _ ⟨⟩ ⟨⟩ <;> simp_rw [smul_eq_mul, ← of_finsupp_smul, ← of_finsupp_mul, ← of_finsupp_smul, smul_mul_assoc]⟩
#align polynomial.is_scalar_tower_right Polynomial.is_scalar_tower_right

instance {S} [Monoid S] [DistribMulAction S R] [DistribMulAction Sᵐᵒᵖ R] [IsCentralScalar S R] :
    IsCentralScalar S R[X] :=
  ⟨by
    rintro _ ⟨⟩
    simp_rw [← of_finsupp_smul, op_smul_eq_smul]⟩

instance [Subsingleton R] : Unique R[X] :=
  { Polynomial.inhabited with
    uniq := by
      rintro ⟨x⟩
      refine' congr_arg of_finsupp _
      simp }

variable (R)

/-- Ring isomorphism between `R[X]` and `add_monoid_algebra R ℕ`. This is just an
implementation detail, but it can be useful to transfer results from `finsupp` to polynomials. -/
@[simps apply symmApply]
def toFinsuppIso : R[X] ≃+* AddMonoidAlgebra R ℕ where
  toFun := toFinsupp
  invFun := of_finsupp
  left_inv := fun ⟨p⟩ => rfl
  right_inv p := rfl
  map_mul' := to_finsupp_mul
  map_add' := to_finsupp_add
#align polynomial.to_finsupp_iso Polynomial.toFinsuppIso

end AddMonoidAlgebra

variable {R}

theorem of_finsupp_sum {ι : Type _} (s : Finset ι) (f : ι → AddMonoidAlgebra R ℕ) :
    (⟨∑ i in s, f i⟩ : R[X]) = ∑ i in s, ⟨f i⟩ :=
  map_sum (toFinsuppIso R).symm f s
#align polynomial.of_finsupp_sum Polynomial.of_finsupp_sum

theorem to_finsupp_sum {ι : Type _} (s : Finset ι) (f : ι → R[X]) :
    (∑ i in s, f i : R[X]).toFinsupp = ∑ i in s, (f i).toFinsupp :=
  map_sum (toFinsuppIso R) f s
#align polynomial.to_finsupp_sum Polynomial.to_finsupp_sum

/-- The set of all `n` such that `X^n` has a non-zero coefficient.
-/
@[simp]
def support : R[X] → Finset ℕ
  | ⟨p⟩ => p.support
#align polynomial.support Polynomial.support

@[simp]
theorem support_of_finsupp (p) : support (⟨p⟩ : R[X]) = p.support := by rw [support]
#align polynomial.support_of_finsupp Polynomial.support_of_finsupp

@[simp]
theorem support_zero : (0 : R[X]).support = ∅ :=
  rfl
#align polynomial.support_zero Polynomial.support_zero

@[simp]
theorem support_eq_empty : p.support = ∅ ↔ p = 0 := by
  rcases p with ⟨⟩
  simp [support]
#align polynomial.support_eq_empty Polynomial.support_eq_empty

theorem card_support_eq_zero : p.support.card = 0 ↔ p = 0 := by simp
#align polynomial.card_support_eq_zero Polynomial.card_support_eq_zero

/-- `monomial s a` is the monomial `a * X^s` -/
def monomial (n : ℕ) : R →ₗ[R] R[X] where
  toFun t := ⟨Finsupp.single n t⟩
  map_add' := by simp
  map_smul' := by simp [← of_finsupp_smul]
#align polynomial.monomial Polynomial.monomial

@[simp]
theorem to_finsupp_monomial (n : ℕ) (r : R) : (monomial n r).toFinsupp = Finsupp.single n r := by simp [monomial]
#align polynomial.to_finsupp_monomial Polynomial.to_finsupp_monomial

@[simp]
theorem of_finsupp_single (n : ℕ) (r : R) : (⟨Finsupp.single n r⟩ : R[X]) = monomial n r := by simp [monomial]
#align polynomial.of_finsupp_single Polynomial.of_finsupp_single

@[simp]
theorem monomial_zero_right (n : ℕ) : monomial n (0 : R) = 0 :=
  (monomial n).map_zero
#align polynomial.monomial_zero_right Polynomial.monomial_zero_right

-- This is not a `simp` lemma as `monomial_zero_left` is more general.
theorem monomial_zero_one : monomial 0 (1 : R) = 1 :=
  rfl
#align polynomial.monomial_zero_one Polynomial.monomial_zero_one

-- TODO: can't we just delete this one?
theorem monomial_add (n : ℕ) (r s : R) : monomial n (r + s) = monomial n r + monomial n s :=
  (monomial n).map_add _ _
#align polynomial.monomial_add Polynomial.monomial_add

theorem monomial_mul_monomial (n m : ℕ) (r s : R) : monomial n r * monomial m s = monomial (n + m) (r * s) :=
  to_finsupp_injective <| by simp only [to_finsupp_monomial, to_finsupp_mul, AddMonoidAlgebra.single_mul_single]
#align polynomial.monomial_mul_monomial Polynomial.monomial_mul_monomial

@[simp]
theorem monomial_pow (n : ℕ) (r : R) (k : ℕ) : monomial n r ^ k = monomial (n * k) (r ^ k) := by
  induction' k with k ih
  · simp [pow_zero, monomial_zero_one]
    
  · simp [pow_succ, ih, monomial_mul_monomial, Nat.succ_eq_add_one, mul_add, add_comm]
    
#align polynomial.monomial_pow Polynomial.monomial_pow

theorem smul_monomial {S} [Monoid S] [DistribMulAction S R] (a : S) (n : ℕ) (b : R) :
    a • monomial n b = monomial n (a • b) :=
  to_finsupp_injective <| by simp
#align polynomial.smul_monomial Polynomial.smul_monomial

theorem monomial_injective (n : ℕ) : Function.Injective (monomial n : R → R[X]) :=
  (toFinsuppIso R).symm.Injective.comp (single_injective n)
#align polynomial.monomial_injective Polynomial.monomial_injective

@[simp]
theorem monomial_eq_zero_iff (t : R) (n : ℕ) : monomial n t = 0 ↔ t = 0 :=
  LinearMap.map_eq_zero_iff _ (Polynomial.monomial_injective n)
#align polynomial.monomial_eq_zero_iff Polynomial.monomial_eq_zero_iff

theorem support_add : (p + q).support ⊆ p.support ∪ q.support := by
  rcases p with ⟨⟩
  rcases q with ⟨⟩
  simp only [← of_finsupp_add, support]
  exact support_add
#align polynomial.support_add Polynomial.support_add

/-- `C a` is the constant polynomial `a`.
`C` is provided as a ring homomorphism.
-/
def c : R →+* R[X] :=
  { monomial 0 with map_one' := by simp [monomial_zero_one], map_mul' := by simp [monomial_mul_monomial],
    map_zero' := by simp }
#align polynomial.C Polynomial.c

@[simp]
theorem monomial_zero_left (a : R) : monomial 0 a = c a :=
  rfl
#align polynomial.monomial_zero_left Polynomial.monomial_zero_left

@[simp]
theorem to_finsupp_C (a : R) : (c a).toFinsupp = single 0 a := by rw [← monomial_zero_left, to_finsupp_monomial]
#align polynomial.to_finsupp_C Polynomial.to_finsupp_C

theorem C_0 : c (0 : R) = 0 := by simp
#align polynomial.C_0 Polynomial.C_0

theorem C_1 : c (1 : R) = 1 :=
  rfl
#align polynomial.C_1 Polynomial.C_1

theorem C_mul : c (a * b) = c a * c b :=
  c.map_mul a b
#align polynomial.C_mul Polynomial.C_mul

theorem C_add : c (a + b) = c a + c b :=
  c.map_add a b
#align polynomial.C_add Polynomial.C_add

@[simp]
theorem smul_C {S} [Monoid S] [DistribMulAction S R] (s : S) (r : R) : s • c r = c (s • r) :=
  smul_monomial _ _ r
#align polynomial.smul_C Polynomial.smul_C

@[simp]
theorem C_bit0 : c (bit0 a) = bit0 (c a) :=
  C_add
#align polynomial.C_bit0 Polynomial.C_bit0

@[simp]
theorem C_bit1 : c (bit1 a) = bit1 (c a) := by simp [bit1, C_bit0]
#align polynomial.C_bit1 Polynomial.C_bit1

theorem C_pow : c (a ^ n) = c a ^ n :=
  c.map_pow a n
#align polynomial.C_pow Polynomial.C_pow

@[simp]
theorem C_eq_nat_cast (n : ℕ) : c (n : R) = (n : R[X]) :=
  map_nat_cast c n
#align polynomial.C_eq_nat_cast Polynomial.C_eq_nat_cast

@[simp]
theorem C_mul_monomial : c a * monomial n b = monomial n (a * b) := by
  simp only [← monomial_zero_left, monomial_mul_monomial, zero_add]
#align polynomial.C_mul_monomial Polynomial.C_mul_monomial

@[simp]
theorem monomial_mul_C : monomial n a * c b = monomial n (a * b) := by
  simp only [← monomial_zero_left, monomial_mul_monomial, add_zero]
#align polynomial.monomial_mul_C Polynomial.monomial_mul_C

/-- `X` is the polynomial variable (aka indeterminate). -/
def x : R[X] :=
  monomial 1 1
#align polynomial.X Polynomial.x

theorem monomial_one_one_eq_X : monomial 1 (1 : R) = X :=
  rfl
#align polynomial.monomial_one_one_eq_X Polynomial.monomial_one_one_eq_X

theorem monomial_one_right_eq_X_pow (n : ℕ) : monomial n (1 : R) = X ^ n := by
  induction' n with n ih
  · simp [monomial_zero_one]
    
  · rw [pow_succ, ← ih, ← monomial_one_one_eq_X, monomial_mul_monomial, add_comm, one_mul]
    
#align polynomial.monomial_one_right_eq_X_pow Polynomial.monomial_one_right_eq_X_pow

/-- `X` commutes with everything, even when the coefficients are noncommutative. -/
theorem X_mul : X * p = p * X := by
  rcases p with ⟨⟩
  simp only [X, ← of_finsupp_single, ← of_finsupp_mul, LinearMap.coe_mk]
  ext
  simp [AddMonoidAlgebra.mul_apply, sum_single_index, add_comm]
#align polynomial.X_mul Polynomial.X_mul

theorem X_pow_mul {n : ℕ} : X ^ n * p = p * X ^ n := by
  induction' n with n ih
  · simp
    
  · conv_lhs => rw [pow_succ']
    rw [mul_assoc, X_mul, ← mul_assoc, ih, mul_assoc, ← pow_succ']
    
#align polynomial.X_pow_mul Polynomial.X_pow_mul

/-- Prefer putting constants to the left of `X`.

This lemma is the loop-avoiding `simp` version of `polynomial.X_mul`. -/
@[simp]
theorem X_mul_C (r : R) : X * c r = c r * X :=
  X_mul
#align polynomial.X_mul_C Polynomial.X_mul_C

/-- Prefer putting constants to the left of `X ^ n`.

This lemma is the loop-avoiding `simp` version of `X_pow_mul`. -/
@[simp]
theorem X_pow_mul_C (r : R) (n : ℕ) : X ^ n * c r = c r * X ^ n :=
  X_pow_mul
#align polynomial.X_pow_mul_C Polynomial.X_pow_mul_C

theorem X_pow_mul_assoc {n : ℕ} : p * X ^ n * q = p * q * X ^ n := by rw [mul_assoc, X_pow_mul, ← mul_assoc]
#align polynomial.X_pow_mul_assoc Polynomial.X_pow_mul_assoc

/-- Prefer putting constants to the left of `X ^ n`.

This lemma is the loop-avoiding `simp` version of `X_pow_mul_assoc`. -/
@[simp]
theorem X_pow_mul_assoc_C {n : ℕ} (r : R) : p * X ^ n * c r = p * c r * X ^ n :=
  X_pow_mul_assoc
#align polynomial.X_pow_mul_assoc_C Polynomial.X_pow_mul_assoc_C

theorem commute_X (p : R[X]) : Commute x p :=
  X_mul
#align polynomial.commute_X Polynomial.commute_X

theorem commute_X_pow (p : R[X]) (n : ℕ) : Commute (X ^ n) p :=
  X_pow_mul
#align polynomial.commute_X_pow Polynomial.commute_X_pow

@[simp]
theorem monomial_mul_X (n : ℕ) (r : R) : monomial n r * X = monomial (n + 1) r := by
  erw [monomial_mul_monomial, mul_one]
#align polynomial.monomial_mul_X Polynomial.monomial_mul_X

@[simp]
theorem monomial_mul_X_pow (n : ℕ) (r : R) (k : ℕ) : monomial n r * X ^ k = monomial (n + k) r := by
  induction' k with k ih
  · simp
    
  · simp [ih, pow_succ', ← mul_assoc, add_assoc]
    
#align polynomial.monomial_mul_X_pow Polynomial.monomial_mul_X_pow

@[simp]
theorem X_mul_monomial (n : ℕ) (r : R) : X * monomial n r = monomial (n + 1) r := by rw [X_mul, monomial_mul_X]
#align polynomial.X_mul_monomial Polynomial.X_mul_monomial

@[simp]
theorem X_pow_mul_monomial (k n : ℕ) (r : R) : X ^ k * monomial n r = monomial (n + k) r := by
  rw [X_pow_mul, monomial_mul_X_pow]
#align polynomial.X_pow_mul_monomial Polynomial.X_pow_mul_monomial

/-- `coeff p n` (often denoted `p.coeff n`) is the coefficient of `X^n` in `p`. -/
@[simp]
def coeff : R[X] → ℕ → R
  | ⟨p⟩ => p
#align polynomial.coeff Polynomial.coeff

theorem coeff_injective : Injective (coeff : R[X] → ℕ → R) := by
  rintro ⟨p⟩ ⟨q⟩
  simp only [coeff, FunLike.coe_fn_eq, imp_self]
#align polynomial.coeff_injective Polynomial.coeff_injective

@[simp]
theorem coeff_inj : p.coeff = q.coeff ↔ p = q :=
  coeff_injective.eq_iff
#align polynomial.coeff_inj Polynomial.coeff_inj

theorem coeff_monomial : coeff (monomial n a) m = if n = m then a else 0 := by
  simp only [← of_finsupp_single, coeff, LinearMap.coe_mk]
  rw [Finsupp.single_apply]
#align polynomial.coeff_monomial Polynomial.coeff_monomial

@[simp]
theorem coeff_zero (n : ℕ) : coeff (0 : R[X]) n = 0 :=
  rfl
#align polynomial.coeff_zero Polynomial.coeff_zero

@[simp]
theorem coeff_one_zero : coeff (1 : R[X]) 0 = 1 := by
  rw [← monomial_zero_one, coeff_monomial]
  simp
#align polynomial.coeff_one_zero Polynomial.coeff_one_zero

@[simp]
theorem coeff_X_one : coeff (x : R[X]) 1 = 1 :=
  coeff_monomial
#align polynomial.coeff_X_one Polynomial.coeff_X_one

@[simp]
theorem coeff_X_zero : coeff (x : R[X]) 0 = 0 :=
  coeff_monomial
#align polynomial.coeff_X_zero Polynomial.coeff_X_zero

@[simp]
theorem coeff_monomial_succ : coeff (monomial (n + 1) a) 0 = 0 := by simp [coeff_monomial]
#align polynomial.coeff_monomial_succ Polynomial.coeff_monomial_succ

theorem coeff_X : coeff (x : R[X]) n = if 1 = n then 1 else 0 :=
  coeff_monomial
#align polynomial.coeff_X Polynomial.coeff_X

theorem coeff_X_of_ne_one {n : ℕ} (hn : n ≠ 1) : coeff (x : R[X]) n = 0 := by rw [coeff_X, if_neg hn.symm]
#align polynomial.coeff_X_of_ne_one Polynomial.coeff_X_of_ne_one

@[simp]
theorem mem_support_iff : n ∈ p.support ↔ p.coeff n ≠ 0 := by
  rcases p with ⟨⟩
  simp
#align polynomial.mem_support_iff Polynomial.mem_support_iff

theorem not_mem_support_iff : n ∉ p.support ↔ p.coeff n = 0 := by simp
#align polynomial.not_mem_support_iff Polynomial.not_mem_support_iff

theorem coeff_C : coeff (c a) n = ite (n = 0) a 0 := by
  convert coeff_monomial using 2
  simp [eq_comm]
#align polynomial.coeff_C Polynomial.coeff_C

@[simp]
theorem coeff_C_zero : coeff (c a) 0 = a :=
  coeff_monomial
#align polynomial.coeff_C_zero Polynomial.coeff_C_zero

theorem coeff_C_ne_zero (h : n ≠ 0) : (c a).coeff n = 0 := by rw [coeff_C, if_neg h]
#align polynomial.coeff_C_ne_zero Polynomial.coeff_C_ne_zero

theorem C_mul_X_pow_eq_monomial : ∀ {n : ℕ}, c a * X ^ n = monomial n a
  | 0 => mul_one _
  | n + 1 => by rw [pow_succ', ← mul_assoc, C_mul_X_pow_eq_monomial, X, monomial_mul_monomial, mul_one]
#align polynomial.C_mul_X_pow_eq_monomial Polynomial.C_mul_X_pow_eq_monomial

theorem C_mul_X_eq_monomial : c a * X = monomial 1 a := by rw [← C_mul_X_pow_eq_monomial, pow_one]
#align polynomial.C_mul_X_eq_monomial Polynomial.C_mul_X_eq_monomial

theorem C_injective : Injective (c : R → R[X]) :=
  monomial_injective 0
#align polynomial.C_injective Polynomial.C_injective

@[simp]
theorem C_inj : c a = c b ↔ a = b :=
  C_injective.eq_iff
#align polynomial.C_inj Polynomial.C_inj

@[simp]
theorem C_eq_zero : c a = 0 ↔ a = 0 :=
  C_injective.eq_iff' (map_zero c)
#align polynomial.C_eq_zero Polynomial.C_eq_zero

theorem subsingleton_iff_subsingleton : Subsingleton R[X] ↔ Subsingleton R :=
  ⟨@Injective.subsingleton _ _ _ C_injective, by
    intro
    infer_instance⟩
#align polynomial.subsingleton_iff_subsingleton Polynomial.subsingleton_iff_subsingleton

theorem Nontrivial.of_polynomial_ne (h : p ≠ q) : Nontrivial R :=
  (subsingleton_or_nontrivial R).resolve_left fun hI => h <| Subsingleton.elim _ _
#align polynomial.nontrivial.of_polynomial_ne Polynomial.Nontrivial.of_polynomial_ne

theorem forall_eq_iff_forall_eq : (∀ f g : R[X], f = g) ↔ ∀ a b : R, a = b := by
  simpa only [← subsingleton_iff] using subsingleton_iff_subsingleton
#align polynomial.forall_eq_iff_forall_eq Polynomial.forall_eq_iff_forall_eq

theorem ext_iff {p q : R[X]} : p = q ↔ ∀ n, coeff p n = coeff q n := by
  rcases p with ⟨⟩
  rcases q with ⟨⟩
  simp [coeff, Finsupp.ext_iff]
#align polynomial.ext_iff Polynomial.ext_iff

@[ext.1]
theorem ext {p q : R[X]} : (∀ n, coeff p n = coeff q n) → p = q :=
  ext_iff.2
#align polynomial.ext Polynomial.ext

/-- Monomials generate the additive monoid of polynomials. -/
theorem add_submonoid_closure_set_of_eq_monomial : AddSubmonoid.closure { p : R[X] | ∃ n a, p = monomial n a } = ⊤ := by
  apply top_unique
  rw [← AddSubmonoid.map_equiv_top (to_finsupp_iso R).symm.toAddEquiv, ← Finsupp.add_closure_set_of_eq_single,
    AddMonoidHom.map_mclosure]
  refine' AddSubmonoid.closure_mono (Set.image_subset_iff.2 _)
  rintro _ ⟨n, a, rfl⟩
  exact ⟨n, a, Polynomial.of_finsupp_single _ _⟩
#align polynomial.add_submonoid_closure_set_of_eq_monomial Polynomial.add_submonoid_closure_set_of_eq_monomial

theorem add_hom_ext {M : Type _} [AddMonoid M] {f g : R[X] →+ M} (h : ∀ n a, f (monomial n a) = g (monomial n a)) :
    f = g :=
  AddMonoidHom.eq_of_eq_on_mdense add_submonoid_closure_set_of_eq_monomial <| by
    rintro p ⟨n, a, rfl⟩
    exact h n a
#align polynomial.add_hom_ext Polynomial.add_hom_ext

@[ext.1]
theorem add_hom_ext' {M : Type _} [AddMonoid M] {f g : R[X] →+ M}
    (h : ∀ n, f.comp (monomial n).toAddMonoidHom = g.comp (monomial n).toAddMonoidHom) : f = g :=
  add_hom_ext fun n => AddMonoidHom.congr_fun (h n)
#align polynomial.add_hom_ext' Polynomial.add_hom_ext'

@[ext.1]
theorem lhom_ext' {M : Type _} [AddCommMonoid M] [Module R M] {f g : R[X] →ₗ[R] M}
    (h : ∀ n, f.comp (monomial n) = g.comp (monomial n)) : f = g :=
  LinearMap.to_add_monoid_hom_injective <| add_hom_ext fun n => LinearMap.congr_fun (h n)
#align polynomial.lhom_ext' Polynomial.lhom_ext'

-- this has the same content as the subsingleton
theorem eq_zero_of_eq_zero (h : (0 : R) = (1 : R)) (p : R[X]) : p = 0 := by rw [← one_smul R p, ← h, zero_smul]
#align polynomial.eq_zero_of_eq_zero Polynomial.eq_zero_of_eq_zero

section Fewnomials

theorem support_monomial (n) {a : R} (H : a ≠ 0) : (monomial n a).support = singleton n := by
  rw [← of_finsupp_single, support, Finsupp.support_single_ne_zero _ H]
#align polynomial.support_monomial Polynomial.support_monomial

theorem support_monomial' (n) (a : R) : (monomial n a).support ⊆ singleton n := by
  rw [← of_finsupp_single, support]
  exact Finsupp.support_single_subset
#align polynomial.support_monomial' Polynomial.support_monomial'

theorem support_C_mul_X {c : R} (h : c ≠ 0) : (c c * X).support = singleton 1 := by
  rw [C_mul_X_eq_monomial, support_monomial 1 h]
#align polynomial.support_C_mul_X Polynomial.support_C_mul_X

theorem support_C_mul_X' (c : R) : (c c * X).support ⊆ singleton 1 := by
  simpa only [C_mul_X_eq_monomial] using support_monomial' 1 c
#align polynomial.support_C_mul_X' Polynomial.support_C_mul_X'

theorem support_C_mul_X_pow (n : ℕ) {c : R} (h : c ≠ 0) : (c c * X ^ n).support = singleton n := by
  rw [C_mul_X_pow_eq_monomial, support_monomial n h]
#align polynomial.support_C_mul_X_pow Polynomial.support_C_mul_X_pow

theorem support_C_mul_X_pow' (n : ℕ) (c : R) : (c c * X ^ n).support ⊆ singleton n := by
  simpa only [C_mul_X_pow_eq_monomial] using support_monomial' n c
#align polynomial.support_C_mul_X_pow' Polynomial.support_C_mul_X_pow'

open Finset

theorem support_binomial' (k m : ℕ) (x y : R) : (c x * X ^ k + c y * X ^ m).support ⊆ {k, m} :=
  support_add.trans
    (union_subset ((support_C_mul_X_pow' k x).trans (singleton_subset_iff.mpr (mem_insert_self k {m})))
      ((support_C_mul_X_pow' m y).trans (singleton_subset_iff.mpr (mem_insert_of_mem (mem_singleton_self m)))))
#align polynomial.support_binomial' Polynomial.support_binomial'

theorem support_trinomial' (k m n : ℕ) (x y z : R) : (c x * X ^ k + c y * X ^ m + c z * X ^ n).support ⊆ {k, m, n} :=
  support_add.trans
    (union_subset
      (support_add.trans
        (union_subset ((support_C_mul_X_pow' k x).trans (singleton_subset_iff.mpr (mem_insert_self k {m, n})))
          ((support_C_mul_X_pow' m y).trans (singleton_subset_iff.mpr (mem_insert_of_mem (mem_insert_self m {n}))))))
      ((support_C_mul_X_pow' n z).trans
        (singleton_subset_iff.mpr (mem_insert_of_mem (mem_insert_of_mem (mem_singleton_self n))))))
#align polynomial.support_trinomial' Polynomial.support_trinomial'

end Fewnomials

theorem X_pow_eq_monomial (n) : X ^ n = monomial n (1 : R) := by
  induction' n with n hn
  · rw [pow_zero, monomial_zero_one]
    
  · rw [pow_succ', hn, X, monomial_mul_monomial, one_mul]
    
#align polynomial.X_pow_eq_monomial Polynomial.X_pow_eq_monomial

theorem smul_X_eq_monomial {n} : a • X ^ n = monomial n (a : R) := by
  rw [X_pow_eq_monomial, smul_monomial, smul_eq_mul, mul_one]
#align polynomial.smul_X_eq_monomial Polynomial.smul_X_eq_monomial

theorem support_X_pow (H : ¬(1 : R) = 0) (n : ℕ) : (X ^ n : R[X]).support = singleton n := by
  convert support_monomial n H
  exact X_pow_eq_monomial n
#align polynomial.support_X_pow Polynomial.support_X_pow

theorem support_X_empty (H : (1 : R) = 0) : (x : R[X]).support = ∅ := by rw [X, H, monomial_zero_right, support_zero]
#align polynomial.support_X_empty Polynomial.support_X_empty

theorem support_X (H : ¬(1 : R) = 0) : (x : R[X]).support = singleton 1 := by rw [← pow_one X, support_X_pow H 1]
#align polynomial.support_X Polynomial.support_X

theorem monomial_left_inj {a : R} (ha : a ≠ 0) {i j : ℕ} : monomial i a = monomial j a ↔ i = j := by
  simp_rw [← of_finsupp_single, Finsupp.single_left_inj ha]
#align polynomial.monomial_left_inj Polynomial.monomial_left_inj

theorem binomial_eq_binomial {k l m n : ℕ} {u v : R} (hu : u ≠ 0) (hv : v ≠ 0) :
    c u * X ^ k + c v * X ^ l = c u * X ^ m + c v * X ^ n ↔
      k = m ∧ l = n ∨ u = v ∧ k = n ∧ l = m ∨ u + v = 0 ∧ k = l ∧ m = n :=
  by
  simp_rw [C_mul_X_pow_eq_monomial, ← to_finsupp_inj, to_finsupp_add, to_finsupp_monomial]
  exact Finsupp.single_add_single_eq_single_add_single hu hv
#align polynomial.binomial_eq_binomial Polynomial.binomial_eq_binomial

theorem nat_cast_mul (n : ℕ) (p : R[X]) : (n : R[X]) * p = n • p :=
  (nsmul_eq_mul _ _).symm
#align polynomial.nat_cast_mul Polynomial.nat_cast_mul

/-- Summing the values of a function applied to the coefficients of a polynomial -/
def sum {S : Type _} [AddCommMonoid S] (p : R[X]) (f : ℕ → R → S) : S :=
  ∑ n in p.support, f n (p.coeff n)
#align polynomial.sum Polynomial.sum

theorem sum_def {S : Type _} [AddCommMonoid S] (p : R[X]) (f : ℕ → R → S) :
    p.Sum f = ∑ n in p.support, f n (p.coeff n) :=
  rfl
#align polynomial.sum_def Polynomial.sum_def

theorem sum_eq_of_subset {S : Type _} [AddCommMonoid S] (p : R[X]) (f : ℕ → R → S) (hf : ∀ i, f i 0 = 0) (s : Finset ℕ)
    (hs : p.support ⊆ s) : p.Sum f = ∑ n in s, f n (p.coeff n) := by
  apply Finset.sum_subset hs fun n hn h'n => _
  rw [not_mem_support_iff] at h'n
  simp [h'n, hf]
#align polynomial.sum_eq_of_subset Polynomial.sum_eq_of_subset

/-- Expressing the product of two polynomials as a double sum. -/
theorem mul_eq_sum_sum : p * q = ∑ i in p.support, q.Sum fun j a => (monomial (i + j)) (p.coeff i * a) := by
  apply to_finsupp_injective
  rcases p with ⟨⟩
  rcases q with ⟨⟩
  simp [support, Sum, coeff, to_finsupp_sum]
  rfl
#align polynomial.mul_eq_sum_sum Polynomial.mul_eq_sum_sum

@[simp]
theorem sum_zero_index {S : Type _} [AddCommMonoid S] (f : ℕ → R → S) : (0 : R[X]).Sum f = 0 := by simp [Sum]
#align polynomial.sum_zero_index Polynomial.sum_zero_index

@[simp]
theorem sum_monomial_index {S : Type _} [AddCommMonoid S] (n : ℕ) (a : R) (f : ℕ → R → S) (hf : f n 0 = 0) :
    (monomial n a : R[X]).Sum f = f n a := by
  by_cases h : a = 0
  · simp [h, hf]
    
  · simp [Sum, support_monomial, h, coeff_monomial]
    
#align polynomial.sum_monomial_index Polynomial.sum_monomial_index

@[simp]
theorem sum_C_index {a} {β} [AddCommMonoid β] {f : ℕ → R → β} (h : f 0 0 = 0) : (c a).Sum f = f 0 a :=
  sum_monomial_index 0 a f h
#align polynomial.sum_C_index Polynomial.sum_C_index

-- the assumption `hf` is only necessary when the ring is trivial
@[simp]
theorem sum_X_index {S : Type _} [AddCommMonoid S] {f : ℕ → R → S} (hf : f 1 0 = 0) : (x : R[X]).Sum f = f 1 1 :=
  sum_monomial_index 1 1 f hf
#align polynomial.sum_X_index Polynomial.sum_X_index

theorem sum_add_index {S : Type _} [AddCommMonoid S] (p q : R[X]) (f : ℕ → R → S) (hf : ∀ i, f i 0 = 0)
    (h_add : ∀ a b₁ b₂, f a (b₁ + b₂) = f a b₁ + f a b₂) : (p + q).Sum f = p.Sum f + q.Sum f := by
  rcases p with ⟨⟩
  rcases q with ⟨⟩
  simp only [← of_finsupp_add, Sum, support, coeff, Pi.add_apply, coe_add]
  exact Finsupp.sum_add_index' hf h_add
#align polynomial.sum_add_index Polynomial.sum_add_index

theorem sum_add' {S : Type _} [AddCommMonoid S] (p : R[X]) (f g : ℕ → R → S) : p.Sum (f + g) = p.Sum f + p.Sum g := by
  simp [sum_def, Finset.sum_add_distrib]
#align polynomial.sum_add' Polynomial.sum_add'

theorem sum_add {S : Type _} [AddCommMonoid S] (p : R[X]) (f g : ℕ → R → S) :
    (p.Sum fun n x => f n x + g n x) = p.Sum f + p.Sum g :=
  sum_add' _ _ _
#align polynomial.sum_add Polynomial.sum_add

theorem sum_smul_index {S : Type _} [AddCommMonoid S] (p : R[X]) (b : R) (f : ℕ → R → S) (hf : ∀ i, f i 0 = 0) :
    (b • p).Sum f = p.Sum fun n a => f n (b * a) := by
  rcases p with ⟨⟩
  simpa [Sum, support, coeff] using Finsupp.sum_smul_index hf
#align polynomial.sum_smul_index Polynomial.sum_smul_index

theorem sum_monomial_eq : ∀ p : R[X], (p.Sum fun n a => monomial n a) = p
  | ⟨p⟩ => (of_finsupp_sum _ _).symm.trans (congr_arg _ <| Finsupp.sum_single _)
#align polynomial.sum_monomial_eq Polynomial.sum_monomial_eq

theorem sum_C_mul_X_pow_eq (p : R[X]) : (p.Sum fun n a => c a * X ^ n) = p := by
  simp_rw [C_mul_X_pow_eq_monomial, sum_monomial_eq]
#align polynomial.sum_C_mul_X_pow_eq Polynomial.sum_C_mul_X_pow_eq

/-- `erase p n` is the polynomial `p` in which the `X^n` term has been erased. -/
irreducible_def erase (n : ℕ) : R[X] → R[X]
  | ⟨p⟩ => ⟨p.erase n⟩
#align polynomial.erase Polynomial.erase

@[simp]
theorem to_finsupp_erase (p : R[X]) (n : ℕ) : toFinsupp (p.erase n) = p.toFinsupp.erase n := by
  rcases p with ⟨⟩
  simp only [erase]
#align polynomial.to_finsupp_erase Polynomial.to_finsupp_erase

@[simp]
theorem of_finsupp_erase (p : AddMonoidAlgebra R ℕ) (n : ℕ) : (⟨p.erase n⟩ : R[X]) = (⟨p⟩ : R[X]).erase n := by
  rcases p with ⟨⟩
  simp only [erase]
#align polynomial.of_finsupp_erase Polynomial.of_finsupp_erase

@[simp]
theorem support_erase (p : R[X]) (n : ℕ) : support (p.erase n) = (support p).erase n := by
  rcases p with ⟨⟩
  simp only [support, erase, support_erase]
#align polynomial.support_erase Polynomial.support_erase

theorem monomial_add_erase (p : R[X]) (n : ℕ) : monomial n (coeff p n) + p.erase n = p :=
  to_finsupp_injective <| by
    rcases p with ⟨⟩
    rw [to_finsupp_add, to_finsupp_monomial, to_finsupp_erase, coeff]
    exact Finsupp.single_add_erase _ _
#align polynomial.monomial_add_erase Polynomial.monomial_add_erase

theorem coeff_erase (p : R[X]) (n i : ℕ) : (p.erase n).coeff i = if i = n then 0 else p.coeff i := by
  rcases p with ⟨⟩
  simp only [erase, coeff]
  convert rfl
#align polynomial.coeff_erase Polynomial.coeff_erase

@[simp]
theorem erase_zero (n : ℕ) : (0 : R[X]).erase n = 0 :=
  to_finsupp_injective <| by simp
#align polynomial.erase_zero Polynomial.erase_zero

@[simp]
theorem erase_monomial {n : ℕ} {a : R} : erase n (monomial n a) = 0 :=
  to_finsupp_injective <| by simp
#align polynomial.erase_monomial Polynomial.erase_monomial

@[simp]
theorem erase_same (p : R[X]) (n : ℕ) : coeff (p.erase n) n = 0 := by simp [coeff_erase]
#align polynomial.erase_same Polynomial.erase_same

@[simp]
theorem erase_ne (p : R[X]) (n i : ℕ) (h : i ≠ n) : coeff (p.erase n) i = coeff p i := by simp [coeff_erase, h]
#align polynomial.erase_ne Polynomial.erase_ne

section Update

/-- Replace the coefficient of a `p : R[X]` at a given degree `n : ℕ`
by a given value `a : R`. If `a = 0`, this is equal to `p.erase n`
If `p.nat_degree < n` and `a ≠ 0`, this increases the degree to `n`.  -/
def update (p : R[X]) (n : ℕ) (a : R) : R[X] :=
  Polynomial.of_finsupp (p.toFinsupp.update n a)
#align polynomial.update Polynomial.update

theorem coeff_update (p : R[X]) (n : ℕ) (a : R) : (p.update n a).coeff = Function.update p.coeff n a := by
  ext
  cases p
  simp only [coeff, update, Function.update_apply, coe_update]
#align polynomial.coeff_update Polynomial.coeff_update

theorem coeff_update_apply (p : R[X]) (n : ℕ) (a : R) (i : ℕ) :
    (p.update n a).coeff i = if i = n then a else p.coeff i := by rw [coeff_update, Function.update_apply]
#align polynomial.coeff_update_apply Polynomial.coeff_update_apply

@[simp]
theorem coeff_update_same (p : R[X]) (n : ℕ) (a : R) : (p.update n a).coeff n = a := by
  rw [p.coeff_update_apply, if_pos rfl]
#align polynomial.coeff_update_same Polynomial.coeff_update_same

theorem coeff_update_ne (p : R[X]) {n : ℕ} (a : R) {i : ℕ} (h : i ≠ n) : (p.update n a).coeff i = p.coeff i := by
  rw [p.coeff_update_apply, if_neg h]
#align polynomial.coeff_update_ne Polynomial.coeff_update_ne

@[simp]
theorem update_zero_eq_erase (p : R[X]) (n : ℕ) : p.update n 0 = p.erase n := by
  ext
  rw [coeff_update_apply, coeff_erase]
#align polynomial.update_zero_eq_erase Polynomial.update_zero_eq_erase

theorem support_update (p : R[X]) (n : ℕ) (a : R) [Decidable (a = 0)] :
    support (p.update n a) = if a = 0 then p.support.erase n else insert n p.support := by
  cases p
  simp only [support, update, support_update]
  congr
#align polynomial.support_update Polynomial.support_update

theorem support_update_zero (p : R[X]) (n : ℕ) : support (p.update n 0) = p.support.erase n := by
  rw [update_zero_eq_erase, support_erase]
#align polynomial.support_update_zero Polynomial.support_update_zero

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `support_update_ne_zero [])
      (Command.declSig
       [(Term.explicitBinder "(" [`p] [":" (Polynomial.Data.Polynomial.Basic.polynomial `R "[X]")] [] ")")
        (Term.explicitBinder "(" [`n] [":" (termℕ "ℕ")] [] ")")
        (Term.implicitBinder "{" [`a] [":" `R] "}")
        (Term.explicitBinder "(" [`ha] [":" («term_≠_» `a "≠" (num "0"))] [] ")")]
       (Term.typeSpec
        ":"
        («term_=_»
         (Term.app `support [(Term.app (Term.proj `p "." `update) [`n `a])])
         "="
         (Term.app `insert [`n (Term.proj `p "." `support)]))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.«tactic_<;>_»
            (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
            "<;>"
            (Tactic.rwSeq
             "rw"
             []
             (Tactic.rwRuleSeq
              "["
              [(Tactic.rwRule [] `support_update) "," (Tactic.rwRule [] (Term.app `if_neg [`ha]))]
              "]")
             []))])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.«tactic_<;>_»
           (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
           "<;>"
           (Tactic.rwSeq
            "rw"
            []
            (Tactic.rwRuleSeq
             "["
             [(Tactic.rwRule [] `support_update) "," (Tactic.rwRule [] (Term.app `if_neg [`ha]))]
             "]")
            []))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.«tactic_<;>_»
       (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
       "<;>"
       (Tactic.rwSeq
        "rw"
        []
        (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `support_update) "," (Tactic.rwRule [] (Term.app `if_neg [`ha]))] "]")
        []))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `support_update) "," (Tactic.rwRule [] (Term.app `if_neg [`ha]))] "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `if_neg [`ha])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `ha
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `if_neg
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `support_update
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1, tactic))
      (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.skip', expected 'Lean.Parser.Tactic.tacticSeq'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.declValEqns'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.whereStructInst'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  support_update_ne_zero
  ( p : R [X] ) ( n : ℕ ) { a : R } ( ha : a ≠ 0 ) : support p . update n a = insert n p . support
  := by skip <;> rw [ support_update , if_neg ha ]
#align polynomial.support_update_ne_zero Polynomial.support_update_ne_zero

end Update

end Semiring

section CommSemiring

variable [CommSemiring R]

instance : CommSemiring R[X] :=
  Function.Injective.commSemiring toFinsupp to_finsupp_injective to_finsupp_zero to_finsupp_one to_finsupp_add
    to_finsupp_mul (fun _ _ => to_finsupp_smul _ _) to_finsupp_pow fun _ => rfl

end CommSemiring

section Ring

variable [Ring R]

instance : IntCast R[X] :=
  ⟨fun n => of_finsupp n⟩

instance : Ring R[X] :=
  Function.Injective.ring toFinsupp to_finsupp_injective to_finsupp_zero to_finsupp_one to_finsupp_add to_finsupp_mul
    to_finsupp_neg to_finsupp_sub (fun _ _ => to_finsupp_smul _ _) (fun _ _ => to_finsupp_smul _ _) to_finsupp_pow
    (fun _ => rfl) fun _ => rfl

@[simp]
theorem coeff_neg (p : R[X]) (n : ℕ) : coeff (-p) n = -coeff p n := by
  rcases p with ⟨⟩
  rw [← of_finsupp_neg, coeff, coeff, Finsupp.neg_apply]
#align polynomial.coeff_neg Polynomial.coeff_neg

@[simp]
theorem coeff_sub (p q : R[X]) (n : ℕ) : coeff (p - q) n = coeff p n - coeff q n := by
  rcases p with ⟨⟩
  rcases q with ⟨⟩
  rw [← of_finsupp_sub, coeff, coeff, coeff, Finsupp.sub_apply]
#align polynomial.coeff_sub Polynomial.coeff_sub

@[simp]
theorem monomial_neg (n : ℕ) (a : R) : monomial n (-a) = -monomial n a := by
  rw [eq_neg_iff_add_eq_zero, ← monomial_add, neg_add_self, monomial_zero_right]
#align polynomial.monomial_neg Polynomial.monomial_neg

@[simp]
theorem support_neg {p : R[X]} : (-p).support = p.support := by
  rcases p with ⟨⟩
  rw [← of_finsupp_neg, support, support, Finsupp.support_neg]
#align polynomial.support_neg Polynomial.support_neg

@[simp]
theorem C_eq_int_cast (n : ℤ) : c (n : R) = n :=
  map_int_cast c n
#align polynomial.C_eq_int_cast Polynomial.C_eq_int_cast

end Ring

instance [CommRing R] : CommRing R[X] :=
  Function.Injective.commRing toFinsupp to_finsupp_injective to_finsupp_zero to_finsupp_one to_finsupp_add
    to_finsupp_mul to_finsupp_neg to_finsupp_sub (fun _ _ => to_finsupp_smul _ _) (fun _ _ => to_finsupp_smul _ _)
    to_finsupp_pow (fun _ => rfl) fun _ => rfl

section NonzeroSemiring

variable [Semiring R] [Nontrivial R]

instance : Nontrivial R[X] := by
  have h : Nontrivial (AddMonoidAlgebra R ℕ) := by infer_instance
  rcases h.exists_pair_ne with ⟨x, y, hxy⟩
  refine' ⟨⟨⟨x⟩, ⟨y⟩, _⟩⟩
  simp [hxy]

theorem X_ne_zero : (x : R[X]) ≠ 0 :=
  mt (congr_arg fun p => coeff p 1) (by simp)
#align polynomial.X_ne_zero Polynomial.X_ne_zero

end NonzeroSemiring

@[simp]
theorem nontrivial_iff [Semiring R] : Nontrivial R[X] ↔ Nontrivial R :=
  ⟨fun h =>
    let ⟨r, s, hrs⟩ := @exists_pair_ne _ h
    Nontrivial.of_polynomial_ne hrs,
    fun h => @Polynomial.nontrivial _ _ h⟩
#align polynomial.nontrivial_iff Polynomial.nontrivial_iff

section repr

variable [Semiring R]

open Classical

instance [Repr R] : Repr R[X] :=
  ⟨fun p =>
    if p = 0 then "0"
    else
      (p.support.sort (· ≤ ·)).foldr
        (fun n a =>
          (a ++ if a = "" then "" else " + ") ++
            if n = 0 then "C (" ++ repr (coeff p n) ++ ")"
            else
              if n = 1 then if coeff p n = 1 then "X" else "C (" ++ repr (coeff p n) ++ ") * X"
              else if coeff p n = 1 then "X ^ " ++ repr n else "C (" ++ repr (coeff p n) ++ ") * X ^ " ++ repr n)
        ""⟩

end repr

end Polynomial

