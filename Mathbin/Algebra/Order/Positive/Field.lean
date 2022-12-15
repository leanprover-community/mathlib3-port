/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module algebra.order.positive.field
! leanprover-community/mathlib commit aba57d4d3dae35460225919dcd82fe91355162f9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Field.Basic
import Mathbin.Algebra.Order.Positive.Ring

/-!
# Algebraic structures on the set of positive numbers

In this file we prove that the set of positive elements of a linear ordered field is a linear
ordered commutative group.
-/


variable {K : Type _} [LinearOrderedField K]

namespace Positive

instance : Inv { x : K // 0 < x } :=
  ⟨fun x => ⟨x⁻¹, inv_pos.2 x.2⟩⟩

@[simp]
theorem coe_inv (x : { x : K // 0 < x }) : ↑x⁻¹ = (x⁻¹ : K) :=
  rfl
#align positive.coe_inv Positive.coe_inv

instance : Pow { x : K // 0 < x } ℤ :=
  ⟨fun x n => ⟨x ^ n, zpow_pos_of_pos x.2 _⟩⟩

@[simp]
theorem coe_zpow (x : { x : K // 0 < x }) (n : ℤ) : ↑(x ^ n) = (x ^ n : K) :=
  rfl
#align positive.coe_zpow Positive.coe_zpow

instance : LinearOrderedCommGroup { x : K // 0 < x } :=
  { Positive.Subtype.hasInv, Positive.Subtype.linearOrderedCancelCommMonoid with
    mul_left_inv := fun a => Subtype.ext <| inv_mul_cancel a.2.ne' }

end Positive

