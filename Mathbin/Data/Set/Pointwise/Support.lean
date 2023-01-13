/-
Copyright (c) 2022 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module data.set.pointwise.support
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Pointwise.Smul
import Mathbin.Algebra.Support

/-!
# Support of a function composed with a scalar action

We show that the support of `x ↦ f (c⁻¹ • x)` is equal to `c • support f`.
-/


open Pointwise

open Function Set

section Group

variable {α β γ : Type _} [Group α] [MulAction α β]

theorem mul_support_comp_inv_smul [One γ] (c : α) (f : β → γ) :
    (mulSupport fun x => f (c⁻¹ • x)) = c • mulSupport f :=
  by
  ext x
  simp only [mem_smul_set_iff_inv_smul_mem, mem_mul_support]
#align mul_support_comp_inv_smul mul_support_comp_inv_smul

theorem support_comp_inv_smul [Zero γ] (c : α) (f : β → γ) :
    (support fun x => f (c⁻¹ • x)) = c • support f :=
  by
  ext x
  simp only [mem_smul_set_iff_inv_smul_mem, mem_support]
#align support_comp_inv_smul support_comp_inv_smul

attribute [to_additive support_comp_inv_smul] mul_support_comp_inv_smul

end Group

section GroupWithZero

variable {α β γ : Type _} [GroupWithZero α] [MulAction α β]

theorem mul_support_comp_inv_smul₀ [One γ] {c : α} (hc : c ≠ 0) (f : β → γ) :
    (mulSupport fun x => f (c⁻¹ • x)) = c • mulSupport f :=
  by
  ext x
  simp only [mem_smul_set_iff_inv_smul_mem₀ hc, mem_mul_support]
#align mul_support_comp_inv_smul₀ mul_support_comp_inv_smul₀

theorem support_comp_inv_smul₀ [Zero γ] {c : α} (hc : c ≠ 0) (f : β → γ) :
    (support fun x => f (c⁻¹ • x)) = c • support f :=
  by
  ext x
  simp only [mem_smul_set_iff_inv_smul_mem₀ hc, mem_support]
#align support_comp_inv_smul₀ support_comp_inv_smul₀

attribute [to_additive support_comp_inv_smul₀] mul_support_comp_inv_smul₀

end GroupWithZero

