/-
Copyright (c) 2020 Johan Commelin, Robert Y. Lewis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Robert Y. Lewis
-/
import Mathbin.Data.MvPolynomial.Basic
import Mathbin.RingTheory.AlgebraTower

/-!
# Invertible polynomials

This file is a stub containing some basic facts about
invertible elements in the ring of polynomials.
-/


open MvPolynomial

noncomputable instance MvPolynomial.invertibleC (σ : Type _) {R : Type _} [CommSemiringₓ R] (r : R) [Invertible r] :
    Invertible (c r : MvPolynomial σ R) :=
  Invertible.map (c.toMonoidHom : R →* MvPolynomial σ R) _

/-- A natural number that is invertible when coerced to a commutative semiring `R`
is also invertible when coerced to any polynomial ring with rational coefficients.

Short-cut for typeclass resolution. -/
noncomputable instance MvPolynomial.invertibleCoeNat (σ R : Type _) (p : ℕ) [CommSemiringₓ R] [Invertible (p : R)] :
    Invertible (p : MvPolynomial σ R) :=
  IsScalarTower.invertibleAlgebraCoeNat R _ _

