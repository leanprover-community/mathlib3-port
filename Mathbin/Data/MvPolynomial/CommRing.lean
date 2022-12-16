/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Johan Commelin, Mario Carneiro

! This file was ported from Lean 3 source module data.mv_polynomial.comm_ring
! leanprover-community/mathlib commit d012cd09a9b256d870751284dd6a29882b0be105
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.MvPolynomial.Variables

/-!
# Multivariate polynomials over a ring

Many results about polynomials hold when the coefficient ring is a commutative semiring.
Some stronger results can be derived when we assume this semiring is a ring.

This file does not define any new operations, but proves some of these stronger results.

## Notation

As in other polynomial files, we typically use the notation:

+ `σ : Type*` (indexing the variables)

+ `R : Type*` `[comm_ring R]` (the coefficients)

+ `s : σ →₀ ℕ`, a function from `σ` to `ℕ` which is zero away from a finite set.
This will give rise to a monomial in `mv_polynomial σ R` which mathematicians might call `X^s`

+ `a : R`

+ `i : σ`, with corresponding monomial `X i`, often denoted `X_i` by mathematicians

+ `p : mv_polynomial σ R`

-/


noncomputable section

open Classical BigOperators

open Set Function Finsupp AddMonoidAlgebra

open BigOperators

universe u v

variable {R : Type u} {S : Type v}

namespace MvPolynomial

variable {σ : Type _} {a a' a₁ a₂ : R} {e : ℕ} {n m : σ} {s : σ →₀ ℕ}

section CommRing

variable [CommRing R]

variable {p q : MvPolynomial σ R}

instance : CommRing (MvPolynomial σ R) :=
  AddMonoidAlgebra.commRing

variable (σ a a')

@[simp]
theorem C_sub : (c (a - a') : MvPolynomial σ R) = c a - c a' :=
  RingHom.map_sub _ _ _
#align mv_polynomial.C_sub MvPolynomial.C_sub

@[simp]
theorem C_neg : (c (-a) : MvPolynomial σ R) = -c a :=
  RingHom.map_neg _ _
#align mv_polynomial.C_neg MvPolynomial.C_neg

@[simp]
theorem coeff_neg (m : σ →₀ ℕ) (p : MvPolynomial σ R) : coeff m (-p) = -coeff m p :=
  Finsupp.neg_apply _ _
#align mv_polynomial.coeff_neg MvPolynomial.coeff_neg

@[simp]
theorem coeff_sub (m : σ →₀ ℕ) (p q : MvPolynomial σ R) : coeff m (p - q) = coeff m p - coeff m q :=
  Finsupp.sub_apply _ _ _
#align mv_polynomial.coeff_sub MvPolynomial.coeff_sub

@[simp]
theorem support_neg : (-p).support = p.support :=
  Finsupp.support_neg p
#align mv_polynomial.support_neg MvPolynomial.support_neg

theorem support_sub (p q : MvPolynomial σ R) : (p - q).support ⊆ p.support ∪ q.support :=
  Finsupp.support_sub
#align mv_polynomial.support_sub MvPolynomial.support_sub

variable {σ} (p)

section Degrees

theorem degrees_neg (p : MvPolynomial σ R) : (-p).degrees = p.degrees := by
  rw [degrees, support_neg] <;> rfl
#align mv_polynomial.degrees_neg MvPolynomial.degrees_neg

theorem degrees_sub (p q : MvPolynomial σ R) : (p - q).degrees ≤ p.degrees ⊔ q.degrees := by
  simpa only [sub_eq_add_neg] using le_trans (degrees_add p (-q)) (by rw [degrees_neg])
#align mv_polynomial.degrees_sub MvPolynomial.degrees_sub

end Degrees

section Vars

variable (p q)

@[simp]
theorem vars_neg : (-p).vars = p.vars := by simp [vars, degrees_neg]
#align mv_polynomial.vars_neg MvPolynomial.vars_neg

theorem vars_sub_subset : (p - q).vars ⊆ p.vars ∪ q.vars := by
  convert vars_add_subset p (-q) using 2 <;> simp [sub_eq_add_neg]
#align mv_polynomial.vars_sub_subset MvPolynomial.vars_sub_subset

variable {p q}

@[simp]
theorem vars_sub_of_disjoint (hpq : Disjoint p.vars q.vars) : (p - q).vars = p.vars ∪ q.vars := by
  rw [← vars_neg q] at hpq
  convert vars_add_of_disjoint hpq using 2 <;> simp [sub_eq_add_neg]
#align mv_polynomial.vars_sub_of_disjoint MvPolynomial.vars_sub_of_disjoint

end Vars

section Eval₂

variable [CommRing S]

variable (f : R →+* S) (g : σ → S)

@[simp]
theorem eval₂_sub : (p - q).eval₂ f g = p.eval₂ f g - q.eval₂ f g :=
  (eval₂Hom f g).map_sub _ _
#align mv_polynomial.eval₂_sub MvPolynomial.eval₂_sub

@[simp]
theorem eval₂_neg : (-p).eval₂ f g = -p.eval₂ f g :=
  (eval₂Hom f g).map_neg _
#align mv_polynomial.eval₂_neg MvPolynomial.eval₂_neg

theorem hom_C (f : MvPolynomial σ ℤ →+* S) (n : ℤ) : f (c n) = (n : S) :=
  eq_int_cast (f.comp c) n
#align mv_polynomial.hom_C MvPolynomial.hom_C

/-- A ring homomorphism f : Z[X_1, X_2, ...] → R
is determined by the evaluations f(X_1), f(X_2), ... -/
@[simp]
theorem eval₂_hom_X {R : Type u} (c : ℤ →+* S) (f : MvPolynomial R ℤ →+* S) (x : MvPolynomial R ℤ) :
    eval₂ c (f ∘ X) x = f x :=
  MvPolynomial.induction_on x
    (fun n => by 
      rw [hom_C f, eval₂_C]
      exact eq_int_cast c n)
    (fun p q hp hq => by 
      rw [eval₂_add, hp, hq]
      exact (f.map_add _ _).symm)
    fun p n hp => by 
    rw [eval₂_mul, eval₂_X, hp]
    exact (f.map_mul _ _).symm
#align mv_polynomial.eval₂_hom_X MvPolynomial.eval₂_hom_X

/-- Ring homomorphisms out of integer polynomials on a type `σ` are the same as
functions out of the type `σ`, -/
def homEquiv : (MvPolynomial σ ℤ →+* S) ≃
      (σ → S) where 
  toFun f := ⇑f ∘ X
  invFun f := eval₂Hom (Int.castRingHom S) f
  left_inv f := RingHom.ext <| eval₂_hom_X _ _
  right_inv f := funext fun x => by simp only [coe_eval₂_hom, Function.comp_apply, eval₂_X]
#align mv_polynomial.hom_equiv MvPolynomial.homEquiv

end Eval₂

section DegreeOf

theorem degree_of_sub_lt {x : σ} {f g : MvPolynomial σ R} {k : ℕ} (h : 0 < k)
    (hf : ∀ m : σ →₀ ℕ, m ∈ f.support → k ≤ m x → coeff m f = coeff m g)
    (hg : ∀ m : σ →₀ ℕ, m ∈ g.support → k ≤ m x → coeff m f = coeff m g) : degreeOf x (f - g) < k :=
  by 
  rw [degree_of_lt_iff h]
  intro m hm
  by_contra hc
  simp only [not_lt] at hc
  have h := support_sub σ f g hm
  simp only [mem_support_iff, Ne.def, coeff_sub, sub_eq_zero] at hm
  cases' Finset.mem_union.1 h with cf cg
  · exact hm (hf m cf hc)
  · exact hm (hg m cg hc)
#align mv_polynomial.degree_of_sub_lt MvPolynomial.degree_of_sub_lt

end DegreeOf

section TotalDegree

@[simp]
theorem total_degree_neg (a : MvPolynomial σ R) : (-a).totalDegree = a.totalDegree := by
  simp only [total_degree, support_neg]
#align mv_polynomial.total_degree_neg MvPolynomial.total_degree_neg

theorem total_degree_sub (a b : MvPolynomial σ R) :
    (a - b).totalDegree ≤ max a.totalDegree b.totalDegree :=
  calc
    (a - b).totalDegree = (a + -b).totalDegree := by rw [sub_eq_add_neg]
    _ ≤ max a.totalDegree (-b).totalDegree := total_degree_add a (-b)
    _ = max a.totalDegree b.totalDegree := by rw [total_degree_neg]
    
#align mv_polynomial.total_degree_sub MvPolynomial.total_degree_sub

end TotalDegree

end CommRing

end MvPolynomial

