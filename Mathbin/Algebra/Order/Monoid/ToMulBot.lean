/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro, Johannes Hölzl

! This file was ported from Lean 3 source module algebra.order.monoid.to_mul_bot
! leanprover-community/mathlib commit aba57d4d3dae35460225919dcd82fe91355162f9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.WithZero
import Mathbin.Algebra.Order.Monoid.WithTop
import Mathbin.Algebra.Order.Monoid.TypeTags

/-!
Making an additive monoid multiplicative then adding a zero is the same as adding a bottom
element then making it multiplicative.
-/


universe u

variable {α : Type u}

namespace WithZero

attribute [local semireducible] WithZero

variable [Add α]

/-- Making an additive monoid multiplicative then adding a zero is the same as adding a bottom
element then making it multiplicative. -/
def toMulBot : WithZero (Multiplicative α) ≃* Multiplicative (WithBot α) :=
  MulEquiv.refl _
#align with_zero.to_mul_bot WithZero.toMulBot

@[simp]
theorem to_mul_bot_zero : toMulBot (0 : WithZero (Multiplicative α)) = Multiplicative.ofAdd ⊥ :=
  rfl
#align with_zero.to_mul_bot_zero WithZero.to_mul_bot_zero

@[simp]
theorem to_mul_bot_coe (x : Multiplicative α) :
    toMulBot ↑x = Multiplicative.ofAdd (x.toAdd : WithBot α) :=
  rfl
#align with_zero.to_mul_bot_coe WithZero.to_mul_bot_coe

@[simp]
theorem to_mul_bot_symm_bot : toMulBot.symm (Multiplicative.ofAdd (⊥ : WithBot α)) = 0 :=
  rfl
#align with_zero.to_mul_bot_symm_bot WithZero.to_mul_bot_symm_bot

@[simp]
theorem to_mul_bot_coe_of_add (x : α) :
    toMulBot.symm (Multiplicative.ofAdd (x : WithBot α)) = Multiplicative.ofAdd x :=
  rfl
#align with_zero.to_mul_bot_coe_of_add WithZero.to_mul_bot_coe_of_add

variable [Preorder α] (a b : WithZero (Multiplicative α))

theorem to_mul_bot_strict_mono : StrictMono (@toMulBot α _) := fun x y => id
#align with_zero.to_mul_bot_strict_mono WithZero.to_mul_bot_strict_mono

@[simp]
theorem to_mul_bot_le : toMulBot a ≤ toMulBot b ↔ a ≤ b :=
  Iff.rfl
#align with_zero.to_mul_bot_le WithZero.to_mul_bot_le

@[simp]
theorem to_mul_bot_lt : toMulBot a < toMulBot b ↔ a < b :=
  Iff.rfl
#align with_zero.to_mul_bot_lt WithZero.to_mul_bot_lt

end WithZero

