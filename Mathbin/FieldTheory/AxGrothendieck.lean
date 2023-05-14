/-
Copyright (c) 2023 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes

! This file was ported from Lean 3 source module field_theory.ax_grothendieck
! leanprover-community/mathlib commit 4e529b03dd62b7b7d13806c3fb974d9d4848910e
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.MvPolynomial.Basic
import Mathbin.RingTheory.Algebraic
import Mathbin.Data.Fintype.Card

/-!
# Ax-Grothendieck for algebraic extensions of `zmod p`

This file proves that if `R` is an algebraic extension of a finite field,
then any injective polynomial map `R^n -> R^n` is also surjective.

This proof is required for the true Ax-Grothendieck theorem, which proves the same result
for any algebraically closed field of characteristic zero.

## TODO

The proof of the theorem for characteristic zero is not in mathlib, but it is at
https://github.com/Jlh18/ModelTheoryInLean8
-/


noncomputable section

open MvPolynomial Finset Function

/-- Any injective polynomial map over an algebraic extension of a finite field is surjective. -/
theorem ax_grothendieck_of_locally_finite {ι K R : Type _} [Field K] [Finite K] [CommRing R]
    [Finite ι] [Algebra K R] (alg : Algebra.IsAlgebraic K R) (ps : ι → MvPolynomial ι R)
    (hinj : Injective fun v i => eval v (ps i)) : Surjective fun v i => eval v (ps i) :=
  by
  have is_int : ∀ x : R, IsIntegral K x := fun x => isAlgebraic_iff_isIntegral.1 (alg x)
  classical
    intro v
    cases nonempty_fintype ι
    /- `s` is the set of all coefficients of the polynomial, as well as all of
      the coordinates of `v`, the point I am trying to find the preimage of. -/
    let s : Finset R :=
      (Finset.biUnion (univ : Finset ι) fun i => (ps i).support.image fun x => coeff x (ps i)) ∪
        (univ : Finset ι).image v
    have hv : ∀ i, v i ∈ Algebra.adjoin K (s : Set R) := fun j =>
      Algebra.subset_adjoin (mem_union_right _ (mem_image.2 ⟨j, mem_univ _, rfl⟩))
    have hs₁ :
      ∀ (i : ι) (k : ι →₀ ℕ), k ∈ (ps i).support → coeff k (ps i) ∈ Algebra.adjoin K (s : Set R) :=
      fun i k hk =>
      Algebra.subset_adjoin (mem_union_left _ (mem_bUnion.2 ⟨i, mem_univ _, mem_image_of_mem _ hk⟩))
    have hs : ∀ i, MvPolynomial.eval v (ps i) ∈ Algebra.adjoin K (s : Set R) := fun i =>
      eval_mem (hs₁ _) hv
    letI := isNoetherian_adjoin_finset s fun x _ => is_int x
    letI := Module.IsNoetherian.finite K (Algebra.adjoin K (s : Set R))
    letI : Finite (Algebra.adjoin K (s : Set R)) :=
      FiniteDimensional.finite_of_finite K (Algebra.adjoin K (s : Set R))
    -- The restriction of the polynomial map, `ps`, to the subalgebra generated by `s`
    let res : (ι → Algebra.adjoin K (s : Set R)) → ι → Algebra.adjoin K (s : Set R) := fun x i =>
      ⟨eval (fun j : ι => (x j : R)) (ps i), eval_mem (hs₁ _) fun i => (x i).2⟩
    have hres_inj : injective res := by
      intro x y hxy
      ext i
      simp only [res, Subtype.ext_iff, funext_iff] at hxy
      exact congr_fun (hinj (funext hxy)) i
    have hres_surj : surjective res := Finite.injective_iff_surjective.1 hres_inj
    cases' hres_surj fun i => ⟨v i, hv i⟩ with w hw
    use fun i => w i
    simpa only [res, Subtype.ext_iff, funext_iff] using hw
#align ax_grothendieck_of_locally_finite ax_grothendieck_of_locally_finite

