/-
Copyright (c) 2019 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl

! This file was ported from Lean 3 source module ring_theory.mv_polynomial.basic
! leanprover-community/mathlib commit 422e70f7ce183d2900c586a8cda8381e788a0c62
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.CharP.Basic
import Mathbin.Data.Polynomial.AlgebraMap
import Mathbin.Data.MvPolynomial.Variables
import Mathbin.LinearAlgebra.FinsuppVectorSpace

/-!
# Multivariate polynomials over commutative rings

This file contains basic facts about multivariate polynomials over commutative rings, for example
that the monomials form a basis.

## Main definitions

* `restrict_total_degree σ R m`: the subspace of multivariate polynomials indexed by `σ` over the
  commutative ring `R` of total degree at most `m`.
* `restrict_degree σ R m`: the subspace of multivariate polynomials indexed by `σ` over the
  commutative ring `R` such that the degree in each individual variable is at most `m`.

## Main statements

* The multivariate polynomial ring over a commutative ring of positive characteristic has positive
  characteristic.
* `basis_monomials`: shows that the monomials form a basis of the vector space of multivariate
  polynomials.

## TODO

Generalise to noncommutative (semi)rings
-/


noncomputable section

open Classical

open Set LinearMap Submodule

open BigOperators Polynomial

universe u v

variable (σ : Type u) (R : Type v) [CommRing R] (p m : ℕ)

namespace MvPolynomial

section CharP

instance [CharP R p] : CharP (MvPolynomial σ R) p
    where cast_eq_zero_iff n := by rw [← C_eq_coe_nat, ← C_0, C_inj, CharP.cast_eq_zero_iff R p]

end CharP

section Homomorphism

theorem map_range_eq_map {R S : Type _} [CommRing R] [CommRing S] (p : MvPolynomial σ R)
    (f : R →+* S) : Finsupp.mapRange f f.map_zero p = map f p :=
  by
  -- `finsupp.map_range_finset_sum` expects `f : R →+ S`
  change Finsupp.mapRange (f : R →+ S) (f : R →+ S).map_zero p = map f p
  rw [p.as_sum, Finsupp.map_range_finset_sum, (map f).map_sum]
  refine' Finset.sum_congr rfl fun n _ => _
  rw [map_monomial, ← single_eq_monomial, Finsupp.map_range_single, single_eq_monomial,
    f.coe_add_monoid_hom]
#align mv_polynomial.map_range_eq_map MvPolynomial.map_range_eq_map

end Homomorphism

section Degree

/-- The submodule of polynomials of total degree less than or equal to `m`.-/
def restrictTotalDegree : Submodule R (MvPolynomial σ R) :=
  Finsupp.supported _ _ { n | (n.Sum fun n e => e) ≤ m }
#align mv_polynomial.restrict_total_degree MvPolynomial.restrictTotalDegree

/-- The submodule of polynomials such that the degree with respect to each individual variable is
less than or equal to `m`.-/
def restrictDegree (m : ℕ) : Submodule R (MvPolynomial σ R) :=
  Finsupp.supported _ _ { n | ∀ i, n i ≤ m }
#align mv_polynomial.restrict_degree MvPolynomial.restrictDegree

variable {R}

theorem mem_restrict_total_degree (p : MvPolynomial σ R) :
    p ∈ restrictTotalDegree σ R m ↔ p.totalDegree ≤ m :=
  by
  rw [total_degree, Finset.sup_le_iff]
  rfl
#align mv_polynomial.mem_restrict_total_degree MvPolynomial.mem_restrict_total_degree

theorem mem_restrict_degree (p : MvPolynomial σ R) (n : ℕ) :
    p ∈ restrictDegree σ R n ↔ ∀ s ∈ p.support, ∀ i, (s : σ →₀ ℕ) i ≤ n :=
  by
  rw [restrict_degree, Finsupp.mem_supported]
  rfl
#align mv_polynomial.mem_restrict_degree MvPolynomial.mem_restrict_degree

theorem mem_restrict_degree_iff_sup (p : MvPolynomial σ R) (n : ℕ) :
    p ∈ restrictDegree σ R n ↔ ∀ i, p.degrees.count i ≤ n :=
  by
  simp only [mem_restrict_degree, degrees, Multiset.count_finset_sup, Finsupp.count_to_multiset,
    Finset.sup_le_iff]
  exact ⟨fun h n s hs => h s hs n, fun h s hs n => h n s hs⟩
#align mv_polynomial.mem_restrict_degree_iff_sup MvPolynomial.mem_restrict_degree_iff_sup

variable (σ R)

/-- The monomials form a basis on `mv_polynomial σ R`. -/
def basisMonomials : Basis (σ →₀ ℕ) R (MvPolynomial σ R) :=
  Finsupp.basisSingleOne
#align mv_polynomial.basis_monomials MvPolynomial.basisMonomials

@[simp]
theorem coe_basis_monomials :
    (basisMonomials σ R : (σ →₀ ℕ) → MvPolynomial σ R) = fun s => monomial s 1 :=
  rfl
#align mv_polynomial.coe_basis_monomials MvPolynomial.coe_basis_monomials

theorem linear_independent_X : LinearIndependent R (x : σ → MvPolynomial σ R) :=
  (basisMonomials σ R).LinearIndependent.comp (fun s : σ => Finsupp.single s 1)
    (Finsupp.single_left_injective one_ne_zero)
#align mv_polynomial.linear_independent_X MvPolynomial.linear_independent_X

end Degree

end MvPolynomial

-- this is here to avoid import cycle issues
namespace Polynomial

/-- The monomials form a basis on `R[X]`. -/
noncomputable def basisMonomials : Basis ℕ R R[X] :=
  Basis.of_repr (toFinsuppIsoAlg R).toLinearEquiv
#align polynomial.basis_monomials Polynomial.basisMonomials

@[simp]
theorem coe_basis_monomials : (basisMonomials R : ℕ → R[X]) = fun s => monomial s 1 :=
  _root_.funext fun n => of_finsupp_single _ _
#align polynomial.coe_basis_monomials Polynomial.coe_basis_monomials

end Polynomial

