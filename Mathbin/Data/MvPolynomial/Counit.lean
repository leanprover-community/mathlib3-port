/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin

! This file was ported from Lean 3 source module data.mv_polynomial.counit
! leanprover-community/mathlib commit 26f081a2fb920140ed5bc5cc5344e84bcc7cb2b2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.MvPolynomial.Basic

/-!
## Counit morphisms for multivariate polynomials

One may consider the ring of multivariate polynomials `mv_polynomial A R` with coefficients in `R`
and variables indexed by `A`. If `A` is not just a type, but an algebra over `R`,
then there is a natural surjective algebra homomorphism `mv_polynomial A R →ₐ[R] A`
obtained by `X a ↦ a`.

### Main declarations

* `mv_polynomial.acounit R A` is the natural surjective algebra homomorphism
  `mv_polynomial A R →ₐ[R] A` obtained by `X a ↦ a`
* `mv_polynomial.counit` is an “absolute” variant with `R = ℤ`
* `mv_polynomial.counit_nat` is an “absolute” variant with `R = ℕ`

-/


namespace MvPolynomial

open Function

variable (A B R : Type _) [CommSemiring A] [CommSemiring B] [CommRing R] [Algebra A B]

/-- `mv_polynomial.acounit A B` is the natural surjective algebra homomorphism
`mv_polynomial B A →ₐ[A] B` obtained by `X a ↦ a`.

See `mv_polynomial.counit` for the “absolute” variant with `A = ℤ`,
and `mv_polynomial.counit_nat` for the “absolute” variant with `A = ℕ`. -/
noncomputable def acounit : MvPolynomial B A →ₐ[A] B :=
  aeval id
#align mv_polynomial.acounit MvPolynomial.acounit

variable {B}

@[simp]
theorem acounit_X (b : B) : acounit A B (x b) = b :=
  aeval_X _ b
#align mv_polynomial.acounit_X MvPolynomial.acounit_X

variable {A} (B)

@[simp]
theorem acounit_C (a : A) : acounit A B (c a) = algebraMap A B a :=
  aeval_C _ a
#align mv_polynomial.acounit_C MvPolynomial.acounit_C

variable (A)

theorem acounit_surjective : Surjective (acounit A B) := fun b => ⟨x b, acounit_X A b⟩
#align mv_polynomial.acounit_surjective MvPolynomial.acounit_surjective

/-- `mv_polynomial.counit R` is the natural surjective ring homomorphism
`mv_polynomial R ℤ →+* R` obtained by `X r ↦ r`.

See `mv_polynomial.acounit` for a “relative” variant for algebras over a base ring,
and `mv_polynomial.counit_nat` for the “absolute” variant with `R = ℕ`. -/
noncomputable def counit : MvPolynomial R ℤ →+* R :=
  acounit ℤ R
#align mv_polynomial.counit MvPolynomial.counit

/-- `mv_polynomial.counit_nat A` is the natural surjective ring homomorphism
`mv_polynomial A ℕ →+* A` obtained by `X a ↦ a`.

See `mv_polynomial.acounit` for a “relative” variant for algebras over a base ring
and `mv_polynomial.counit` for the “absolute” variant with `A = ℤ`. -/
noncomputable def counitNat : MvPolynomial A ℕ →+* A :=
  acounit ℕ A
#align mv_polynomial.counit_nat MvPolynomial.counitNat

theorem counit_surjective : Surjective (counit R) :=
  acounit_surjective ℤ R
#align mv_polynomial.counit_surjective MvPolynomial.counit_surjective

theorem counit_nat_surjective : Surjective (counitNat A) :=
  acounit_surjective ℕ A
#align mv_polynomial.counit_nat_surjective MvPolynomial.counit_nat_surjective

theorem counit_C (n : ℤ) : counit R (c n) = n :=
  acounit_C _ _
#align mv_polynomial.counit_C MvPolynomial.counit_C

theorem counit_nat_C (n : ℕ) : counitNat A (c n) = n :=
  acounit_C _ _
#align mv_polynomial.counit_nat_C MvPolynomial.counit_nat_C

variable {R A}

@[simp]
theorem counit_X (r : R) : counit R (x r) = r :=
  acounit_X _ _
#align mv_polynomial.counit_X MvPolynomial.counit_X

@[simp]
theorem counit_nat_X (a : A) : counitNat A (x a) = a :=
  acounit_X _ _
#align mv_polynomial.counit_nat_X MvPolynomial.counit_nat_X

end MvPolynomial

