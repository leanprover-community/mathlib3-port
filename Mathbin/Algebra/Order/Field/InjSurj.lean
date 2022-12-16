/-
Copyright (c) 2014 Robert Lewis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Robert Lewis, Leonardo de Moura, Mario Carneiro, Floris van Doorn

! This file was ported from Lean 3 source module algebra.order.field.inj_surj
! leanprover-community/mathlib commit d012cd09a9b256d870751284dd6a29882b0be105
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Field.Defs
import Mathbin.Algebra.Field.Basic
import Mathbin.Algebra.Order.Ring.InjSurj

/-!
# Pulling back linearly ordered fields along injective maps.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> https://github.com/leanprover-community/mathlib4/pull/1017
> Any changes to this file require a corresponding PR to mathlib4.

-/


open Function OrderDual

variable {ι α β : Type _}

namespace Function

-- See note [reducible non-instances]
/-- Pullback a `linear_ordered_semifield` under an injective map. -/
@[reducible]
def Injective.linearOrderedSemifield [LinearOrderedSemifield α] [Zero β] [One β] [Add β] [Mul β]
    [Pow β ℕ] [HasSmul ℕ β] [NatCast β] [Inv β] [Div β] [Pow β ℤ] [HasSup β] [HasInf β] (f : β → α)
    (hf : Injective f) (zero : f 0 = 0) (one : f 1 = 1) (add : ∀ x y, f (x + y) = f x + f y)
    (mul : ∀ x y, f (x * y) = f x * f y) (inv : ∀ x, f x⁻¹ = (f x)⁻¹)
    (div : ∀ x y, f (x / y) = f x / f y) (nsmul : ∀ (x) (n : ℕ), f (n • x) = n • f x)
    (npow : ∀ (x) (n : ℕ), f (x ^ n) = f x ^ n) (zpow : ∀ (x) (n : ℤ), f (x ^ n) = f x ^ n)
    (nat_cast : ∀ n : ℕ, f n = n) (hsup : ∀ x y, f (x ⊔ y) = max (f x) (f y))
    (hinf : ∀ x y, f (x ⊓ y) = min (f x) (f y)) : LinearOrderedSemifield β :=
  { hf.LinearOrderedSemiring f zero one add mul nsmul npow nat_cast hsup hinf,
    hf.Semifield f zero one add mul inv div nsmul npow zpow nat_cast with }
#align function.injective.linear_ordered_semifield Function.Injective.linearOrderedSemifield

-- See note [reducible non-instances]
/-- Pullback a `linear_ordered_field` under an injective map. -/
@[reducible]
def Injective.linearOrderedField [LinearOrderedField α] [Zero β] [One β] [Add β] [Mul β] [Neg β]
    [Sub β] [Pow β ℕ] [HasSmul ℕ β] [HasSmul ℤ β] [HasSmul ℚ β] [NatCast β] [IntCast β]
    [HasRatCast β] [Inv β] [Div β] [Pow β ℤ] [HasSup β] [HasInf β] (f : β → α) (hf : Injective f)
    (zero : f 0 = 0) (one : f 1 = 1) (add : ∀ x y, f (x + y) = f x + f y)
    (mul : ∀ x y, f (x * y) = f x * f y) (neg : ∀ x, f (-x) = -f x)
    (sub : ∀ x y, f (x - y) = f x - f y) (inv : ∀ x, f x⁻¹ = (f x)⁻¹)
    (div : ∀ x y, f (x / y) = f x / f y) (nsmul : ∀ (x) (n : ℕ), f (n • x) = n • f x)
    (zsmul : ∀ (x) (n : ℤ), f (n • x) = n • f x) (qsmul : ∀ (x) (n : ℚ), f (n • x) = n • f x)
    (npow : ∀ (x) (n : ℕ), f (x ^ n) = f x ^ n) (zpow : ∀ (x) (n : ℤ), f (x ^ n) = f x ^ n)
    (nat_cast : ∀ n : ℕ, f n = n) (int_cast : ∀ n : ℤ, f n = n) (rat_cast : ∀ n : ℚ, f n = n)
    (hsup : ∀ x y, f (x ⊔ y) = max (f x) (f y)) (hinf : ∀ x y, f (x ⊓ y) = min (f x) (f y)) :
    LinearOrderedField β :=
  { hf.LinearOrderedRing f zero one add mul neg sub nsmul zsmul npow nat_cast int_cast hsup hinf,
    hf.Field f zero one add mul neg sub inv div nsmul zsmul qsmul npow zpow nat_cast int_cast
      rat_cast with }
#align function.injective.linear_ordered_field Function.Injective.linearOrderedField

end Function

