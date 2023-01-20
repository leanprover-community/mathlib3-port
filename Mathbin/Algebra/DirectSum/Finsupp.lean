/-
Copyright (c) 2019 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl

! This file was ported from Lean 3 source module algebra.direct_sum.finsupp
! leanprover-community/mathlib commit 1126441d6bccf98c81214a0780c73d499f6721fe
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.DirectSum.Module
import Mathbin.Data.Finsupp.ToDfinsupp

/-!
# Results on direct sums and finitely supported functions.

1. The linear equivalence between finitely supported functions `ι →₀ M` and
the direct sum of copies of `M` indexed by `ι`.
-/


universe u v w

noncomputable section

open DirectSum

open LinearMap Submodule

variable {R : Type u} {M : Type v} [Ring R] [AddCommGroup M] [Module R M]

section finsuppLequivDirectSum

variable (R M) (ι : Type _) [DecidableEq ι]

/-- The finitely supported functions `ι →₀ M` are in linear equivalence with the direct sum of
copies of M indexed by ι. -/
def finsuppLequivDirectSum : (ι →₀ M) ≃ₗ[R] ⨁ i : ι, M :=
  haveI : ∀ m : M, Decidable (m ≠ 0) := Classical.decPred _
  finsuppLequivDfinsupp R
#align finsupp_lequiv_direct_sum finsuppLequivDirectSum

@[simp]
theorem finsuppLequivDirectSum_single (i : ι) (m : M) :
    finsuppLequivDirectSum R M ι (Finsupp.single i m) = DirectSum.lof R ι _ i m :=
  Finsupp.toDfinsupp_single i m
#align finsupp_lequiv_direct_sum_single finsuppLequivDirectSum_single

@[simp]
theorem finsuppLequivDirectSum_symm_lof (i : ι) (m : M) :
    (finsuppLequivDirectSum R M ι).symm (DirectSum.lof R ι _ i m) = Finsupp.single i m :=
  letI : ∀ m : M, Decidable (m ≠ 0) := Classical.decPred _
  Dfinsupp.toFinsupp_single i m
#align finsupp_lequiv_direct_sum_symm_lof finsuppLequivDirectSum_symm_lof

end finsuppLequivDirectSum

