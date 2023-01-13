/-
Copyright (c) 2021 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module algebra.monoid_algebra.to_direct_sum
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.DirectSum.Algebra
import Mathbin.Algebra.MonoidAlgebra.Basic
import Mathbin.Data.Finsupp.ToDfinsupp

/-!
# Conversion between `add_monoid_algebra` and homogenous `direct_sum`

This module provides conversions between `add_monoid_algebra` and `direct_sum`.
The latter is essentially a dependent version of the former.

Note that since `direct_sum.has_mul` combines indices additively, there is no equivalent to
`monoid_algebra`.

## Main definitions

* `add_monoid_algebra.to_direct_sum : add_monoid_algebra M ι → (⨁ i : ι, M)`
* `direct_sum.to_add_monoid_algebra : (⨁ i : ι, M) → add_monoid_algebra M ι`
* Bundled equiv versions of the above:
  * `add_monoid_algebra_equiv_direct_sum : add_monoid_algebra M ι ≃ (⨁ i : ι, M)`
  * `add_monoid_algebra_add_equiv_direct_sum : add_monoid_algebra M ι ≃+ (⨁ i : ι, M)`
  * `add_monoid_algebra_ring_equiv_direct_sum R : add_monoid_algebra M ι ≃+* (⨁ i : ι, M)`
  * `add_monoid_algebra_alg_equiv_direct_sum R : add_monoid_algebra A ι ≃ₐ[R] (⨁ i : ι, A)`

## Theorems

The defining feature of these operations is that they map `finsupp.single` to
`direct_sum.of` and vice versa:

* `add_monoid_algebra.to_direct_sum_single`
* `direct_sum.to_add_monoid_algebra_of`

as well as preserving arithmetic operations.

For the bundled equivalences, we provide lemmas that they reduce to
`add_monoid_algebra.to_direct_sum`:

* `add_monoid_algebra_add_equiv_direct_sum_apply`
* `add_monoid_algebra_lequiv_direct_sum_apply`
* `add_monoid_algebra_add_equiv_direct_sum_symm_apply`
* `add_monoid_algebra_lequiv_direct_sum_symm_apply`

## Implementation notes

This file largely just copies the API of `data/finsupp/to_dfinsupp`, and reuses the proofs.
Recall that `add_monoid_algebra M ι` is defeq to `ι →₀ M` and `⨁ i : ι, M` is defeq to
`Π₀ i : ι, M`.

Note that there is no `add_monoid_algebra` equivalent to `finsupp.single`, so many statements
still involve this definition.
-/


variable {ι : Type _} {R : Type _} {M : Type _} {A : Type _}

open DirectSum

/-! ### Basic definitions and lemmas -/


section Defs

/-- Interpret a `add_monoid_algebra` as a homogenous `direct_sum`. -/
def AddMonoidAlgebra.toDirectSum [Semiring M] (f : AddMonoidAlgebra M ι) : ⨁ i : ι, M :=
  Finsupp.toDfinsupp f
#align add_monoid_algebra.to_direct_sum AddMonoidAlgebra.toDirectSum

section

variable [DecidableEq ι] [Semiring M]

@[simp]
theorem AddMonoidAlgebra.to_direct_sum_single (i : ι) (m : M) :
    AddMonoidAlgebra.toDirectSum (Finsupp.single i m) = DirectSum.of _ i m :=
  Finsupp.to_dfinsupp_single i m
#align add_monoid_algebra.to_direct_sum_single AddMonoidAlgebra.to_direct_sum_single

variable [∀ m : M, Decidable (m ≠ 0)]

/-- Interpret a homogenous `direct_sum` as a `add_monoid_algebra`. -/
def DirectSum.toAddMonoidAlgebra (f : ⨁ i : ι, M) : AddMonoidAlgebra M ι :=
  Dfinsupp.toFinsupp f
#align direct_sum.to_add_monoid_algebra DirectSum.toAddMonoidAlgebra

@[simp]
theorem DirectSum.to_add_monoid_algebra_of (i : ι) (m : M) :
    (DirectSum.of _ i m : ⨁ i : ι, M).toAddMonoidAlgebra = Finsupp.single i m :=
  Dfinsupp.to_finsupp_single i m
#align direct_sum.to_add_monoid_algebra_of DirectSum.to_add_monoid_algebra_of

@[simp]
theorem AddMonoidAlgebra.to_direct_sum_to_add_monoid_algebra (f : AddMonoidAlgebra M ι) :
    f.toDirectSum.toAddMonoidAlgebra = f :=
  Finsupp.to_dfinsupp_to_finsupp f
#align
  add_monoid_algebra.to_direct_sum_to_add_monoid_algebra AddMonoidAlgebra.to_direct_sum_to_add_monoid_algebra

@[simp]
theorem DirectSum.to_add_monoid_algebra_to_direct_sum (f : ⨁ i : ι, M) :
    f.toAddMonoidAlgebra.toDirectSum = f :=
  Dfinsupp.to_finsupp_to_dfinsupp f
#align direct_sum.to_add_monoid_algebra_to_direct_sum DirectSum.to_add_monoid_algebra_to_direct_sum

end

end Defs

/-! ### Lemmas about arithmetic operations -/


section Lemmas

namespace AddMonoidAlgebra

@[simp]
theorem to_direct_sum_zero [Semiring M] : (0 : AddMonoidAlgebra M ι).toDirectSum = 0 :=
  Finsupp.to_dfinsupp_zero
#align add_monoid_algebra.to_direct_sum_zero AddMonoidAlgebra.to_direct_sum_zero

@[simp]
theorem to_direct_sum_add [Semiring M] (f g : AddMonoidAlgebra M ι) :
    (f + g).toDirectSum = f.toDirectSum + g.toDirectSum :=
  Finsupp.to_dfinsupp_add _ _
#align add_monoid_algebra.to_direct_sum_add AddMonoidAlgebra.to_direct_sum_add

@[simp]
theorem to_direct_sum_mul [DecidableEq ι] [AddMonoid ι] [Semiring M] (f g : AddMonoidAlgebra M ι) :
    (f * g).toDirectSum = f.toDirectSum * g.toDirectSum :=
  by
  let to_hom : AddMonoidAlgebra M ι →+ ⨁ i : ι, M :=
    ⟨to_direct_sum, to_direct_sum_zero, to_direct_sum_add⟩
  show to_hom (f * g) = to_hom f * to_hom g
  revert f g
  rw [AddMonoidHom.map_mul_iff]
  ext (xi xv yi yv) : 4
  dsimp only [AddMonoidHom.comp_apply, AddMonoidHom.compl₂_apply, AddMonoidHom.compr₂_apply,
    AddMonoidHom.mul_apply, AddEquiv.coe_toAddMonoidHom, Finsupp.single_add_hom_apply]
  simp only [AddMonoidAlgebra.single_mul_single, to_hom, AddMonoidHom.coe_mk,
    AddMonoidAlgebra.to_direct_sum_single, DirectSum.of_mul_of, Mul.ghas_mul_mul]
#align add_monoid_algebra.to_direct_sum_mul AddMonoidAlgebra.to_direct_sum_mul

end AddMonoidAlgebra

namespace DirectSum

variable [DecidableEq ι]

@[simp]
theorem to_add_monoid_algebra_zero [Semiring M] [∀ m : M, Decidable (m ≠ 0)] :
    toAddMonoidAlgebra 0 = (0 : AddMonoidAlgebra M ι) :=
  Dfinsupp.to_finsupp_zero
#align direct_sum.to_add_monoid_algebra_zero DirectSum.to_add_monoid_algebra_zero

@[simp]
theorem to_add_monoid_algebra_add [Semiring M] [∀ m : M, Decidable (m ≠ 0)] (f g : ⨁ i : ι, M) :
    (f + g).toAddMonoidAlgebra = toAddMonoidAlgebra f + toAddMonoidAlgebra g :=
  Dfinsupp.to_finsupp_add _ _
#align direct_sum.to_add_monoid_algebra_add DirectSum.to_add_monoid_algebra_add

@[simp]
theorem to_add_monoid_algebra_mul [AddMonoid ι] [Semiring M] [∀ m : M, Decidable (m ≠ 0)]
    (f g : ⨁ i : ι, M) : (f * g).toAddMonoidAlgebra = toAddMonoidAlgebra f * toAddMonoidAlgebra g :=
  by
  apply_fun AddMonoidAlgebra.toDirectSum
  · simp
  · apply Function.LeftInverse.injective
    apply AddMonoidAlgebra.to_direct_sum_to_add_monoid_algebra
#align direct_sum.to_add_monoid_algebra_mul DirectSum.to_add_monoid_algebra_mul

end DirectSum

end Lemmas

/-! ### Bundled `equiv`s -/


section Equivs

/-- `add_monoid_algebra.to_direct_sum` and `direct_sum.to_add_monoid_algebra` together form an
equiv. -/
@[simps (config := { fullyApplied := false })]
def addMonoidAlgebraEquivDirectSum [DecidableEq ι] [Semiring M] [∀ m : M, Decidable (m ≠ 0)] :
    AddMonoidAlgebra M ι ≃ ⨁ i : ι, M :=
  { finsuppEquivDfinsupp with
    toFun := AddMonoidAlgebra.toDirectSum
    invFun := DirectSum.toAddMonoidAlgebra }
#align add_monoid_algebra_equiv_direct_sum addMonoidAlgebraEquivDirectSum

/-- The additive version of `add_monoid_algebra.to_add_monoid_algebra`. Note that this is
`noncomputable` because `add_monoid_algebra.has_add` is noncomputable. -/
@[simps (config := { fullyApplied := false })]
def addMonoidAlgebraAddEquivDirectSum [DecidableEq ι] [Semiring M] [∀ m : M, Decidable (m ≠ 0)] :
    AddMonoidAlgebra M ι ≃+ ⨁ i : ι, M :=
  {
    addMonoidAlgebraEquivDirectSum with
    toFun := AddMonoidAlgebra.toDirectSum
    invFun := DirectSum.toAddMonoidAlgebra
    map_add' := AddMonoidAlgebra.to_direct_sum_add }
#align add_monoid_algebra_add_equiv_direct_sum addMonoidAlgebraAddEquivDirectSum

/-- The ring version of `add_monoid_algebra.to_add_monoid_algebra`. Note that this is
`noncomputable` because `add_monoid_algebra.has_add` is noncomputable. -/
@[simps (config := { fullyApplied := false })]
def addMonoidAlgebraRingEquivDirectSum [DecidableEq ι] [AddMonoid ι] [Semiring M]
    [∀ m : M, Decidable (m ≠ 0)] : AddMonoidAlgebra M ι ≃+* ⨁ i : ι, M :=
  {
    (addMonoidAlgebraAddEquivDirectSum :
      AddMonoidAlgebra M ι ≃+
        ⨁ i : ι, M) with
    toFun := AddMonoidAlgebra.toDirectSum
    invFun := DirectSum.toAddMonoidAlgebra
    map_mul' := AddMonoidAlgebra.to_direct_sum_mul }
#align add_monoid_algebra_ring_equiv_direct_sum addMonoidAlgebraRingEquivDirectSum

/-- The algebra version of `add_monoid_algebra.to_add_monoid_algebra`. Note that this is
`noncomputable` because `add_monoid_algebra.has_add` is noncomputable. -/
@[simps (config := { fullyApplied := false })]
def addMonoidAlgebraAlgEquivDirectSum [DecidableEq ι] [AddMonoid ι] [CommSemiring R] [Semiring A]
    [Algebra R A] [∀ m : A, Decidable (m ≠ 0)] : AddMonoidAlgebra A ι ≃ₐ[R] ⨁ i : ι, A :=
  {
    (addMonoidAlgebraRingEquivDirectSum :
      AddMonoidAlgebra A ι ≃+*
        ⨁ i : ι, A) with
    toFun := AddMonoidAlgebra.toDirectSum
    invFun := DirectSum.toAddMonoidAlgebra
    commutes' := fun r => AddMonoidAlgebra.to_direct_sum_single _ _ }
#align add_monoid_algebra_alg_equiv_direct_sum addMonoidAlgebraAlgEquivDirectSum

end Equivs

