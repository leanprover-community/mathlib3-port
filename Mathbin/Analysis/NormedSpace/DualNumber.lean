/-
Copyright (c) 2023 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser
-/
import Algebra.DualNumber
import Analysis.NormedSpace.TrivSqZeroExt

#align_import analysis.normed_space.dual_number from "leanprover-community/mathlib"@"5c1efce12ba86d4901463f61019832f6a4b1a0d0"

/-!
# Results on `dual_number R` related to the norm

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

These are just restatements of similar statements about `triv_sq_zero_ext R M`.

## Main results

* `exp_eps`

-/


namespace DualNumber

open TrivSqZeroExt

variable (𝕜 : Type _) {R : Type _}

variable [IsROrC 𝕜] [NormedCommRing R] [NormedAlgebra 𝕜 R]

variable [TopologicalRing R] [CompleteSpace R] [T2Space R]

#print DualNumber.exp_eps /-
@[simp]
theorem exp_eps : NormedSpace.exp 𝕜 (eps : DualNumber R) = 1 + eps :=
  exp_inr _ _
#align dual_number.exp_eps DualNumber.exp_eps
-/

#print DualNumber.exp_smul_eps /-
@[simp]
theorem exp_smul_eps (r : R) : NormedSpace.exp 𝕜 (r • eps : DualNumber R) = 1 + r • eps := by
  rw [eps, ← inr_smul, exp_inr]
#align dual_number.exp_smul_eps DualNumber.exp_smul_eps
-/

end DualNumber

