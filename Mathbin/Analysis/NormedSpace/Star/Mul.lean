/-
Copyright (c) 2022 Jireh Loreaux. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jireh Loreaux

! This file was ported from Lean 3 source module analysis.normed_space.star.mul
! leanprover-community/mathlib commit d101e93197bb5f6ea89bd7ba386b7f7dff1f3903
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.Star.Basic
import Mathbin.Analysis.NormedSpace.OperatorNorm

/-! # The left-regular representation is an isometry for C⋆-algebras -/


open ContinuousLinearMap

-- mathport name: «expr ⋆»
local postfix:max "⋆" => star

variable (𝕜 : Type _) {E : Type _}

variable [DenselyNormedField 𝕜] [NonUnitalNormedRing E] [StarRing E] [CstarRing E]

variable [NormedSpace 𝕜 E] [IsScalarTower 𝕜 E E] [SMulCommClass 𝕜 E E] (a : E)

/-- In a C⋆-algebra `E`, either unital or non-unital, multiplication on the left by `a : E` has
norm equal to the norm of `a`. -/
@[simp]
theorem op_nnnorm_mul : ‖mul 𝕜 E a‖₊ = ‖a‖₊ :=
  by
  rw [← Sup_closed_unit_ball_eq_nnnorm]
  refine' csupₛ_eq_of_forall_le_of_forall_lt_exists_gt _ _ fun r hr => _
  · exact (metric.nonempty_closed_ball.mpr zero_le_one).image _
  · rintro - ⟨x, hx, rfl⟩
    exact
      ((mul 𝕜 E a).unit_le_op_norm x <| mem_closed_ball_zero_iff.mp hx).trans
        (op_norm_mul_apply_le 𝕜 E a)
  · have ha : 0 < ‖a‖₊ := zero_le'.trans_lt hr
    rw [← inv_inv ‖a‖₊, Nnreal.lt_inv_iff_mul_lt (inv_ne_zero ha.ne')] at hr
    obtain ⟨k, hk₁, hk₂⟩ :=
      NormedField.exists_lt_nnnorm_lt 𝕜 (mul_lt_mul_of_pos_right hr <| Nnreal.inv_pos.2 ha)
    refine' ⟨_, ⟨k • star a, _, rfl⟩, _⟩
    ·
      simpa only [mem_closedBall_zero_iff, norm_smul, one_mul, norm_star] using
        (Nnreal.le_inv_iff_mul_le ha.ne').1 (one_mul ‖a‖₊⁻¹ ▸ hk₂.le : ‖k‖₊ ≤ ‖a‖₊⁻¹)
    · simp only [map_smul, nnnorm_smul, mul_apply', mul_smul_comm, CstarRing.nnnorm_self_mul_star]
      rwa [← Nnreal.div_lt_iff (mul_pos ha ha).ne', div_eq_mul_inv, mul_inv, ← mul_assoc]
#align op_nnnorm_mul op_nnnorm_mul

/-- In a C⋆-algebra `E`, either unital or non-unital, multiplication on the right by `a : E` has
norm eqaul to the norm of `a`. -/
@[simp]
theorem op_nnnorm_mul_flip : ‖(mul 𝕜 E).flip a‖₊ = ‖a‖₊ :=
  by
  rw [← Sup_unit_ball_eq_nnnorm, ← nnnorm_star, ← @op_nnnorm_mul 𝕜 E, ← Sup_unit_ball_eq_nnnorm]
  congr 1
  simp only [mul_apply', flip_apply]
  refine' Set.Subset.antisymm _ _ <;> rintro - ⟨b, hb, rfl⟩ <;>
    refine' ⟨star b, by simpa only [norm_star, mem_ball_zero_iff] using hb, _⟩
  · simp only [← star_mul, nnnorm_star]
  · simpa using (nnnorm_star (star b * a)).symm
#align op_nnnorm_mul_flip op_nnnorm_mul_flip

variable (E)

/-- In a C⋆-algebra `E`, either unital or non-unital, the left regular representation is an
isometry. -/
theorem mul_isometry : Isometry (mul 𝕜 E) :=
  AddMonoidHomClass.isometry_of_norm _ fun a => congr_arg coe <| op_nnnorm_mul 𝕜 a
#align mul_isometry mul_isometry

/-- In a C⋆-algebra `E`, either unital or non-unital, the right regular anti-representation is an
isometry. -/
theorem mul_flip_isometry : Isometry (mul 𝕜 E).flip :=
  AddMonoidHomClass.isometry_of_norm _ fun a => congr_arg coe <| op_nnnorm_mul_flip 𝕜 a
#align mul_flip_isometry mul_flip_isometry

