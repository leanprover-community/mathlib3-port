/-
Copyright (c) 2022 Jireh Loreaux. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jireh Loreaux

! This file was ported from Lean 3 source module analysis.normed_space.star.exponential
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.Exponential

/-! # The exponential map from selfadjoint to unitary
In this file, we establish various propreties related to the map `λ a, exp ℂ A (I • a)` between the
subtypes `self_adjoint A` and `unitary A`.

## TODO

* Show that any exponential unitary is path-connected in `unitary A` to `1 : unitary A`.
* Prove any unitary whose distance to `1 : unitary A` is less than `1` can be expressed as an
  exponential unitary.
* A unitary is in the path component of `1` if and only if it is a finite product of exponential
  unitaries.
-/


section Star

variable {A : Type _} [NormedRing A] [NormedAlgebra ℂ A] [StarRing A] [HasContinuousStar A]
  [CompleteSpace A] [StarModule ℂ A]

open Complex

theorem IsSelfAdjoint.exp_i_smul_unitary {a : A} (ha : IsSelfAdjoint a) :
    exp ℂ (I • a) ∈ unitary A := by
  rw [unitary.mem_iff, star_exp]
  simp only [star_smul, IsROrC.star_def, self_adjoint.mem_iff.mp ha, conj_I, neg_smul]
  rw [← @exp_add_of_commute ℂ A _ _ _ _ _ _ (Commute.refl (I • a)).neg_left]
  rw [← @exp_add_of_commute ℂ A _ _ _ _ _ _ (Commute.refl (I • a)).neg_right]
  simpa only [add_right_neg, add_left_neg, and_self_iff] using (exp_zero : exp ℂ (0 : A) = 1)
#align is_self_adjoint.exp_i_smul_unitary IsSelfAdjoint.exp_i_smul_unitary

/-- The map from the selfadjoint real subspace to the unitary group. This map only makes sense
over ℂ. -/
@[simps]
noncomputable def selfAdjoint.expUnitary (a : selfAdjoint A) : unitary A :=
  ⟨exp ℂ (I • a), a.Prop.exp_i_smul_unitary⟩
#align self_adjoint.exp_unitary selfAdjoint.expUnitary

open selfAdjoint

theorem Commute.exp_unitary_add {a b : selfAdjoint A} (h : Commute (a : A) (b : A)) :
    expUnitary (a + b) = expUnitary a * expUnitary b :=
  by
  ext
  have hcomm : Commute (I • (a : A)) (I • (b : A))
  calc
    _ = _ := by simp only [h.eq, Algebra.smul_mul_assoc, Algebra.mul_smul_comm]
    
  simpa only [exp_unitary_coe, AddSubgroup.coe_add, smul_add] using exp_add_of_commute hcomm
#align commute.exp_unitary_add Commute.exp_unitary_add

theorem Commute.exp_unitary {a b : selfAdjoint A} (h : Commute (a : A) (b : A)) :
    Commute (expUnitary a) (expUnitary b) :=
  calc
    expUnitary a * expUnitary b = expUnitary b * expUnitary a := by
      rw [← h.exp_unitary_add, ← h.symm.exp_unitary_add, add_comm]
    
#align commute.exp_unitary Commute.exp_unitary

end Star

