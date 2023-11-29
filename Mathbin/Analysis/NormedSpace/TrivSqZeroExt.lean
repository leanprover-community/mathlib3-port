/-
Copyright (c) 2023 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser
-/
import Analysis.NormedSpace.Basic
import Analysis.NormedSpace.Exponential
import Topology.Instances.TrivSqZeroExt

#align_import analysis.normed_space.triv_sq_zero_ext from "leanprover-community/mathlib"@"5c1efce12ba86d4901463f61019832f6a4b1a0d0"

/-!
# Results on `triv_sq_zero_ext R M` related to the norm

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

For now, this file contains results about `exp` for this type.

## Main results

* `triv_sq_zero_ext.fst_exp`
* `triv_sq_zero_ext.snd_exp`
* `triv_sq_zero_ext.exp_inl`
* `triv_sq_zero_ext.exp_inr`

## TODO

* Actually define a sensible norm on `triv_sq_zero_ext R M`, so that we have access to lemmas
  like `exp_add`.
* Generalize more of these results to non-commutative `R`. In principle, under sufficient conditions
  we should expect
 `(exp 𝕜 x).snd = ∫ t in 0..1, exp 𝕜 (t • x.fst) • op (exp 𝕜 ((1 - t) • x.fst)) • x.snd`
  ([Physics.SE](https://physics.stackexchange.com/a/41671/185147), and
  https://link.springer.com/chapter/10.1007/978-3-540-44953-9_2).

-/


variable (𝕜 : Type _) {R M : Type _}

local notation "tsze" => TrivSqZeroExt

namespace TrivSqZeroExt

section Topology

variable [TopologicalSpace R] [TopologicalSpace M]

#print TrivSqZeroExt.hasSum_fst_expSeries /-
/-- If `exp R x.fst` converges to `e` then `(exp R x).fst` converges to `e`. -/
theorem hasSum_fst_expSeries [Field 𝕜] [Ring R] [AddCommGroup M] [Algebra 𝕜 R] [Module R M]
    [Module Rᵐᵒᵖ M] [SMulCommClass R Rᵐᵒᵖ M] [Module 𝕜 M] [IsScalarTower 𝕜 R M]
    [IsScalarTower 𝕜 Rᵐᵒᵖ M] [TopologicalRing R] [TopologicalAddGroup M] [ContinuousSMul R M]
    [ContinuousSMul Rᵐᵒᵖ M] (x : tsze R M) {e : R}
    (h : HasSum (fun n => NormedSpace.expSeries 𝕜 R n fun _ => x.fst) e) :
    HasSum (fun n => fst (NormedSpace.expSeries 𝕜 (tsze R M) n fun _ => x)) e := by
  simpa [NormedSpace.expSeries_apply_eq] using h
#align triv_sq_zero_ext.has_sum_fst_exp_series TrivSqZeroExt.hasSum_fst_expSeries
-/

#print TrivSqZeroExt.hasSum_snd_expSeries_of_smul_comm /-
/-- If `exp R x.fst` converges to `e` then `(exp R x).snd` converges to `e • x.snd`. -/
theorem hasSum_snd_expSeries_of_smul_comm [Field 𝕜] [CharZero 𝕜] [Ring R] [AddCommGroup M]
    [Algebra 𝕜 R] [Module R M] [Module Rᵐᵒᵖ M] [SMulCommClass R Rᵐᵒᵖ M] [Module 𝕜 M]
    [IsScalarTower 𝕜 R M] [IsScalarTower 𝕜 Rᵐᵒᵖ M] [TopologicalRing R] [TopologicalAddGroup M]
    [ContinuousSMul R M] [ContinuousSMul Rᵐᵒᵖ M] (x : tsze R M)
    (hx : MulOpposite.op x.fst • x.snd = x.fst • x.snd) {e : R}
    (h : HasSum (fun n => NormedSpace.expSeries 𝕜 R n fun _ => x.fst) e) :
    HasSum (fun n => snd (NormedSpace.expSeries 𝕜 (tsze R M) n fun _ => x)) (e • x.snd) :=
  by
  simp_rw [NormedSpace.expSeries_apply_eq] at *
  conv =>
    congr
    ext
    rw [snd_smul, snd_pow_of_smul_comm _ _ hx, nsmul_eq_smul_cast 𝕜 n, smul_smul, inv_mul_eq_div, ←
      inv_div, ← smul_assoc]
  apply HasSum.smul_const
  rw [← hasSum_nat_add_iff' 1]; swap; infer_instance
  rw [Finset.range_one, Finset.sum_singleton, Nat.cast_zero, div_zero, inv_zero, zero_smul,
    sub_zero]
  simp_rw [← Nat.succ_eq_add_one, Nat.pred_succ, Nat.factorial_succ, Nat.cast_mul, ←
    Nat.succ_eq_add_one,
    mul_div_cancel_left _ ((@Nat.cast_ne_zero 𝕜 _ _ _).mpr <| Nat.succ_ne_zero _)]
  exact h
#align triv_sq_zero_ext.has_sum_snd_exp_series_of_smul_comm TrivSqZeroExt.hasSum_snd_expSeries_of_smul_comm
-/

#print TrivSqZeroExt.hasSum_expSeries_of_smul_comm /-
/-- If `exp R x.fst` converges to `e` then `exp R x` converges to `inl e + inr (e • x.snd)`. -/
theorem hasSum_expSeries_of_smul_comm [Field 𝕜] [CharZero 𝕜] [Ring R] [AddCommGroup M] [Algebra 𝕜 R]
    [Module R M] [Module Rᵐᵒᵖ M] [SMulCommClass R Rᵐᵒᵖ M] [Module 𝕜 M] [IsScalarTower 𝕜 R M]
    [IsScalarTower 𝕜 Rᵐᵒᵖ M] [TopologicalRing R] [TopologicalAddGroup M] [ContinuousSMul R M]
    [ContinuousSMul Rᵐᵒᵖ M] (x : tsze R M) (hx : MulOpposite.op x.fst • x.snd = x.fst • x.snd)
    {e : R} (h : HasSum (fun n => NormedSpace.expSeries 𝕜 R n fun _ => x.fst) e) :
    HasSum (fun n => NormedSpace.expSeries 𝕜 (tsze R M) n fun _ => x) (inl e + inr (e • x.snd)) :=
  by
  simpa only [inl_fst_add_inr_snd_eq] using
    (has_sum_inl _ <| has_sum_fst_exp_series 𝕜 x h).add
      (has_sum_inr _ <| has_sum_snd_exp_series_of_smul_comm 𝕜 x hx h)
#align triv_sq_zero_ext.has_sum_exp_series_of_smul_comm TrivSqZeroExt.hasSum_expSeries_of_smul_comm
-/

end Topology

section NormedRing

variable [IsROrC 𝕜] [NormedRing R] [AddCommGroup M]

variable [NormedAlgebra 𝕜 R] [Module R M] [Module Rᵐᵒᵖ M] [SMulCommClass R Rᵐᵒᵖ M]

variable [Module 𝕜 M] [IsScalarTower 𝕜 R M] [IsScalarTower 𝕜 Rᵐᵒᵖ M]

variable [TopologicalSpace M] [TopologicalRing R]

variable [TopologicalAddGroup M] [ContinuousSMul R M] [ContinuousSMul Rᵐᵒᵖ M]

variable [CompleteSpace R] [T2Space R] [T2Space M]

#print TrivSqZeroExt.exp_def_of_smul_comm /-
theorem exp_def_of_smul_comm (x : tsze R M) (hx : MulOpposite.op x.fst • x.snd = x.fst • x.snd) :
    NormedSpace.exp 𝕜 x = inl (NormedSpace.exp 𝕜 x.fst) + inr (NormedSpace.exp 𝕜 x.fst • x.snd) :=
  by
  simp_rw [NormedSpace.exp, FormalMultilinearSeries.sum]
  refine' (has_sum_exp_series_of_smul_comm 𝕜 x hx _).tsum_eq
  exact NormedSpace.expSeries_hasSum_exp _
#align triv_sq_zero_ext.exp_def_of_smul_comm TrivSqZeroExt.exp_def_of_smul_comm
-/

#print TrivSqZeroExt.exp_inl /-
@[simp]
theorem exp_inl (x : R) : NormedSpace.exp 𝕜 (inl x : tsze R M) = inl (NormedSpace.exp 𝕜 x) :=
  by
  rw [exp_def_of_smul_comm, snd_inl, fst_inl, smul_zero, inr_zero, add_zero]
  · rw [snd_inl, fst_inl, smul_zero, smul_zero]
#align triv_sq_zero_ext.exp_inl TrivSqZeroExt.exp_inl
-/

#print TrivSqZeroExt.exp_inr /-
@[simp]
theorem exp_inr (m : M) : NormedSpace.exp 𝕜 (inr m : tsze R M) = 1 + inr m :=
  by
  rw [exp_def_of_smul_comm, snd_inr, fst_inr, NormedSpace.exp_zero, one_smul, inl_one]
  · rw [snd_inr, fst_inr, MulOpposite.op_zero, zero_smul, zero_smul]
#align triv_sq_zero_ext.exp_inr TrivSqZeroExt.exp_inr
-/

end NormedRing

section NormedCommRing

variable [IsROrC 𝕜] [NormedCommRing R] [AddCommGroup M]

variable [NormedAlgebra 𝕜 R] [Module R M] [Module Rᵐᵒᵖ M] [IsCentralScalar R M]

variable [Module 𝕜 M] [IsScalarTower 𝕜 R M]

variable [TopologicalSpace M] [TopologicalRing R]

variable [TopologicalAddGroup M] [ContinuousSMul R M]

variable [CompleteSpace R] [T2Space R] [T2Space M]

#print TrivSqZeroExt.exp_def /-
theorem exp_def (x : tsze R M) :
    NormedSpace.exp 𝕜 x = inl (NormedSpace.exp 𝕜 x.fst) + inr (NormedSpace.exp 𝕜 x.fst • x.snd) :=
  exp_def_of_smul_comm 𝕜 x (op_smul_eq_smul _ _)
#align triv_sq_zero_ext.exp_def TrivSqZeroExt.exp_def
-/

#print TrivSqZeroExt.fst_exp /-
@[simp]
theorem fst_exp (x : tsze R M) : fst (NormedSpace.exp 𝕜 x) = NormedSpace.exp 𝕜 x.fst := by
  rw [exp_def, fst_add, fst_inl, fst_inr, add_zero]
#align triv_sq_zero_ext.fst_exp TrivSqZeroExt.fst_exp
-/

#print TrivSqZeroExt.snd_exp /-
@[simp]
theorem snd_exp (x : tsze R M) : snd (NormedSpace.exp 𝕜 x) = NormedSpace.exp 𝕜 x.fst • x.snd := by
  rw [exp_def, snd_add, snd_inl, snd_inr, zero_add]
#align triv_sq_zero_ext.snd_exp TrivSqZeroExt.snd_exp
-/

#print TrivSqZeroExt.eq_smul_exp_of_invertible /-
/-- Polar form of trivial-square-zero extension. -/
theorem eq_smul_exp_of_invertible (x : tsze R M) [Invertible x.fst] :
    x = x.fst • NormedSpace.exp 𝕜 (⅟ x.fst • inr x.snd) := by
  rw [← inr_smul, exp_inr, smul_add, ← inl_one, ← inl_smul, ← inr_smul, smul_eq_mul, mul_one,
    smul_smul, mul_invOf_self, one_smul, inl_fst_add_inr_snd_eq]
#align triv_sq_zero_ext.eq_smul_exp_of_invertible TrivSqZeroExt.eq_smul_exp_of_invertible
-/

end NormedCommRing

section NormedField

variable [IsROrC 𝕜] [NormedField R] [AddCommGroup M]

variable [NormedAlgebra 𝕜 R] [Module R M] [Module Rᵐᵒᵖ M] [IsCentralScalar R M]

variable [Module 𝕜 M] [IsScalarTower 𝕜 R M]

variable [TopologicalSpace M] [TopologicalRing R]

variable [TopologicalAddGroup M] [ContinuousSMul R M]

variable [CompleteSpace R] [T2Space R] [T2Space M]

#print TrivSqZeroExt.eq_smul_exp_of_ne_zero /-
/-- More convenient version of `triv_sq_zero_ext.eq_smul_exp_of_invertible` for when `R` is a
field. -/
theorem eq_smul_exp_of_ne_zero (x : tsze R M) (hx : x.fst ≠ 0) :
    x = x.fst • NormedSpace.exp 𝕜 (x.fst⁻¹ • inr x.snd) :=
  letI : Invertible x.fst := invertibleOfNonzero hx
  eq_smul_exp_of_invertible _ _
#align triv_sq_zero_ext.eq_smul_exp_of_ne_zero TrivSqZeroExt.eq_smul_exp_of_ne_zero
-/

end NormedField

end TrivSqZeroExt

