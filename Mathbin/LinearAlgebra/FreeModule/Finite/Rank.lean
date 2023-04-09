/-
Copyright (c) 2021 Riccardo Brasca. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Riccardo Brasca

! This file was ported from Lean 3 source module linear_algebra.free_module.finite.rank
! leanprover-community/mathlib commit 8535b76e601f11868af3e612fbecb730998a5631
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Finrank
import Mathbin.LinearAlgebra.FreeModule.Rank
import Mathbin.LinearAlgebra.FreeModule.Finite.Basic

/-!

# Rank of finite free modules

This is a basic API for the rank of finite free modules.

-/


--TODO: many results from `linear_algebra/finite_dimensional` should be moved here.
universe u v w

variable (R : Type u) (M : Type v) (N : Type w)

open TensorProduct DirectSum BigOperators Cardinal

open Cardinal FiniteDimensional Fintype

namespace FiniteDimensional

open Module.Free

section Ring

variable [Ring R] [StrongRankCondition R]

variable [AddCommGroup M] [Module R M] [Module.Free R M] [Module.Finite R M]

variable [AddCommGroup N] [Module R N] [Module.Free R N] [Module.Finite R N]

/-- The rank of a finite and free module is finite. -/
theorem rank_lt_aleph0 : Module.rank R M < ℵ₀ :=
  by
  letI := nontrivial_of_invariantBasisNumber R
  rw [← (choose_basis R M).mk_eq_rank'', lt_aleph_0_iff_fintype]
  exact Nonempty.intro inferInstance
#align finite_dimensional.rank_lt_aleph_0 FiniteDimensional.rank_lt_aleph0

/-- If `M` is finite and free, `finrank M = rank M`. -/
@[simp]
theorem finrank_eq_rank : ↑(finrank R M) = Module.rank R M := by
  rw [finrank, cast_to_nat_of_lt_aleph_0 (rank_lt_aleph_0 R M)]
#align finite_dimensional.finrank_eq_rank FiniteDimensional.finrank_eq_rank

/-- The finrank of a free module `M` over `R` is the cardinality of `choose_basis_index R M`. -/
theorem finrank_eq_card_chooseBasisIndex :
    finrank R M =
      @card (ChooseBasisIndex R M)
        (@ChooseBasisIndex.fintype R M _ _ _ _ (nontrivial_of_invariantBasisNumber R) _) :=
  by
  letI := nontrivial_of_invariantBasisNumber R
  simp [finrank, rank_eq_card_choose_basis_index]
#align finite_dimensional.finrank_eq_card_choose_basis_index FiniteDimensional.finrank_eq_card_chooseBasisIndex

/-- The finrank of `(ι →₀ R)` is `fintype.card ι`. -/
@[simp]
theorem finrank_finsupp {ι : Type v} [Fintype ι] : finrank R (ι →₀ R) = card ι := by
  rw [finrank, rank_finsupp_self, ← mk_to_nat_eq_card, to_nat_lift]
#align finite_dimensional.finrank_finsupp FiniteDimensional.finrank_finsupp

/-- The finrank of `(ι → R)` is `fintype.card ι`. -/
theorem finrank_pi {ι : Type v} [Fintype ι] : finrank R (ι → R) = card ι := by simp [finrank]
#align finite_dimensional.finrank_pi FiniteDimensional.finrank_pi

/-- The finrank of the direct sum is the sum of the finranks. -/
@[simp]
theorem finrank_directSum {ι : Type v} [Fintype ι] (M : ι → Type w) [∀ i : ι, AddCommGroup (M i)]
    [∀ i : ι, Module R (M i)] [∀ i : ι, Module.Free R (M i)] [∀ i : ι, Module.Finite R (M i)] :
    finrank R (⨁ i, M i) = ∑ i, finrank R (M i) :=
  by
  letI := nontrivial_of_invariantBasisNumber R
  simp only [finrank, fun i => rank_eq_card_choose_basis_index R (M i), rank_directSum, ← mk_sigma,
    mk_to_nat_eq_card, card_sigma]
#align finite_dimensional.finrank_direct_sum FiniteDimensional.finrank_directSum

/-- The finrank of `M × N` is `(finrank R M) + (finrank R N)`. -/
@[simp]
theorem finrank_prod : finrank R (M × N) = finrank R M + finrank R N := by
  simp [finrank, rank_lt_aleph_0 R M, rank_lt_aleph_0 R N]
#align finite_dimensional.finrank_prod FiniteDimensional.finrank_prod

--TODO: this should follow from `linear_equiv.finrank_eq`, that is over a field.
/-- The finrank of a finite product is the sum of the finranks. -/
theorem finrank_pi_fintype {ι : Type v} [Fintype ι] {M : ι → Type w} [∀ i : ι, AddCommGroup (M i)]
    [∀ i : ι, Module R (M i)] [∀ i : ι, Module.Free R (M i)] [∀ i : ι, Module.Finite R (M i)] :
    finrank R (∀ i, M i) = ∑ i, finrank R (M i) :=
  by
  letI := nontrivial_of_invariantBasisNumber R
  simp only [finrank, fun i => rank_eq_card_choose_basis_index R (M i), rank_pi, ← mk_sigma,
    mk_to_nat_eq_card, card_sigma]
#align finite_dimensional.finrank_pi_fintype FiniteDimensional.finrank_pi_fintype

/-- If `m` and `n` are `fintype`, the finrank of `m × n` matrices is
  `(fintype.card m) * (fintype.card n)`. -/
theorem finrank_matrix (m n : Type v) [Fintype m] [Fintype n] :
    finrank R (Matrix m n R) = card m * card n := by simp [finrank]
#align finite_dimensional.finrank_matrix FiniteDimensional.finrank_matrix

end Ring

section CommRing

variable [CommRing R] [StrongRankCondition R]

variable [AddCommGroup M] [Module R M] [Module.Free R M] [Module.Finite R M]

variable [AddCommGroup N] [Module R N] [Module.Free R N] [Module.Finite R N]

/-- The finrank of `M ⊗[R] N` is `(finrank R M) * (finrank R N)`. -/
@[simp]
theorem finrank_tensorProduct (M : Type v) (N : Type w) [AddCommGroup M] [Module R M]
    [Module.Free R M] [AddCommGroup N] [Module R N] [Module.Free R N] :
    finrank R (M ⊗[R] N) = finrank R M * finrank R N := by simp [finrank]
#align finite_dimensional.finrank_tensor_product FiniteDimensional.finrank_tensorProduct

end CommRing

end FiniteDimensional

section

open FiniteDimensional

variable {R M N}

variable [Ring R] [StrongRankCondition R]

variable [AddCommGroup M] [Module R M]

variable [AddCommGroup N] [Module R N]

theorem LinearMap.finrank_le_finrank_of_injective [Module.Free R N] [Module.Finite R N]
    {f : M →ₗ[R] N} (hf : Function.Injective f) : finrank R M ≤ finrank R N :=
  finrank_le_finrank_of_rank_le_rank (LinearMap.lift_rank_le_of_injective _ hf) (rank_lt_aleph0 _ _)
#align linear_map.finrank_le_finrank_of_injective LinearMap.finrank_le_finrank_of_injective

theorem LinearMap.finrank_range_le [Module.Free R M] [Module.Finite R M] (f : M →ₗ[R] N) :
    finrank R f.range ≤ finrank R M :=
  finrank_le_finrank_of_rank_le_rank (lift_rank_range_le f) (rank_lt_aleph0 _ _)
#align linear_map.finrank_range_le LinearMap.finrank_range_le

/-- The dimension of a submodule is bounded by the dimension of the ambient space. -/
theorem Submodule.finrank_le [Module.Free R M] [Module.Finite R M] (s : Submodule R M) :
    finrank R s ≤ finrank R M := by
  simpa only [Cardinal.toNat_lift] using
    to_nat_le_of_le_of_lt_aleph_0 (rank_lt_aleph_0 _ _) (rank_submodule_le s)
#align submodule.finrank_le Submodule.finrank_le

/-- The dimension of a quotient is bounded by the dimension of the ambient space. -/
theorem Submodule.finrank_quotient_le [Module.Free R M] [Module.Finite R M] (s : Submodule R M) :
    finrank R (M ⧸ s) ≤ finrank R M := by
  simpa only [Cardinal.toNat_lift] using
    to_nat_le_of_le_of_lt_aleph_0 (rank_lt_aleph_0 _ _)
      ((Submodule.mkQ s).rank_le_of_surjective (surjective_quot_mk _))
#align submodule.finrank_quotient_le Submodule.finrank_quotient_le

end

