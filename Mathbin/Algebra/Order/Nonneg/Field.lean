/-
Copyright (c) 2021 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn

! This file was ported from Lean 3 source module algebra.order.nonneg.field
! leanprover-community/mathlib commit 26f081a2fb920140ed5bc5cc5344e84bcc7cb2b2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Archimedean
import Mathbin.Algebra.Order.Nonneg.Ring
import Mathbin.Algebra.Order.Field.InjSurj
import Mathbin.Algebra.Order.Field.Canonical.Defs

/-!
# Semifield structure on the type of nonnegative elements

This file defines instances and prove some properties about the nonnegative elements
`{x : α // 0 ≤ x}` of an arbitrary type `α`.

This is used to derive algebraic structures on `ℝ≥0` and `ℚ≥0` automatically.

## Main declarations

* `{x : α // 0 ≤ x}` is a `canonically_linear_ordered_semifield` if `α` is a `linear_ordered_field`.
-/


open Set

variable {α : Type _}

namespace Nonneg

section LinearOrderedSemifield

variable [LinearOrderedSemifield α] {x y : α}

instance hasInv : Inv { x : α // 0 ≤ x } :=
  ⟨fun x => ⟨x⁻¹, inv_nonneg.2 x.2⟩⟩
#align nonneg.has_inv Nonneg.hasInv

@[simp, norm_cast]
protected theorem coe_inv (a : { x : α // 0 ≤ x }) : ((a⁻¹ : { x : α // 0 ≤ x }) : α) = a⁻¹ :=
  rfl
#align nonneg.coe_inv Nonneg.coe_inv

@[simp]
theorem inv_mk (hx : 0 ≤ x) : (⟨x, hx⟩ : { x : α // 0 ≤ x })⁻¹ = ⟨x⁻¹, inv_nonneg.2 hx⟩ :=
  rfl
#align nonneg.inv_mk Nonneg.inv_mk

instance hasDiv : Div { x : α // 0 ≤ x } :=
  ⟨fun x y => ⟨x / y, div_nonneg x.2 y.2⟩⟩
#align nonneg.has_div Nonneg.hasDiv

@[simp, norm_cast]
protected theorem coe_div (a b : { x : α // 0 ≤ x }) : ((a / b : { x : α // 0 ≤ x }) : α) = a / b :=
  rfl
#align nonneg.coe_div Nonneg.coe_div

@[simp]
theorem mk_div_mk (hx : 0 ≤ x) (hy : 0 ≤ y) :
    (⟨x, hx⟩ : { x : α // 0 ≤ x }) / ⟨y, hy⟩ = ⟨x / y, div_nonneg hx hy⟩ :=
  rfl
#align nonneg.mk_div_mk Nonneg.mk_div_mk

instance hasZpow : Pow { x : α // 0 ≤ x } ℤ :=
  ⟨fun a n => ⟨a ^ n, zpow_nonneg a.2 _⟩⟩
#align nonneg.has_zpow Nonneg.hasZpow

@[simp, norm_cast]
protected theorem coe_zpow (a : { x : α // 0 ≤ x }) (n : ℤ) :
    ((a ^ n : { x : α // 0 ≤ x }) : α) = a ^ n :=
  rfl
#align nonneg.coe_zpow Nonneg.coe_zpow

@[simp]
theorem mk_zpow (hx : 0 ≤ x) (n : ℤ) :
    (⟨x, hx⟩ : { x : α // 0 ≤ x }) ^ n = ⟨x ^ n, zpow_nonneg hx n⟩ :=
  rfl
#align nonneg.mk_zpow Nonneg.mk_zpow

instance linearOrderedSemifield : LinearOrderedSemifield { x : α // 0 ≤ x } :=
  Subtype.coe_injective.LinearOrderedSemifield _ Nonneg.coe_zero Nonneg.coe_one Nonneg.coe_add
    Nonneg.coe_mul Nonneg.coe_inv Nonneg.coe_div (fun _ _ => rfl) Nonneg.coe_pow Nonneg.coe_zpow
    Nonneg.coe_nat_cast (fun _ _ => rfl) fun _ _ => rfl
#align nonneg.linear_ordered_semifield Nonneg.linearOrderedSemifield

end LinearOrderedSemifield

instance canonicallyLinearOrderedSemifield [LinearOrderedField α] :
    CanonicallyLinearOrderedSemifield { x : α // 0 ≤ x } :=
  { Nonneg.linearOrderedSemifield, Nonneg.canonicallyOrderedCommSemiring with }
#align nonneg.canonically_linear_ordered_semifield Nonneg.canonicallyLinearOrderedSemifield

instance linearOrderedCommGroupWithZero [LinearOrderedField α] :
    LinearOrderedCommGroupWithZero { x : α // 0 ≤ x } :=
  inferInstance
#align nonneg.linear_ordered_comm_group_with_zero Nonneg.linearOrderedCommGroupWithZero

/-! ### Floor -/


instance archimedean [OrderedAddCommMonoid α] [Archimedean α] : Archimedean { x : α // 0 ≤ x } :=
  ⟨fun x y hy =>
    let ⟨n, hr⟩ := Archimedean.arch (x : α) (hy : (0 : α) < y)
    ⟨n, show (x : α) ≤ (n • y : { x : α // 0 ≤ x }) by simp [*, -nsmul_eq_mul, nsmul_coe]⟩⟩
#align nonneg.archimedean Nonneg.archimedean

instance floorSemiring [OrderedSemiring α] [FloorSemiring α] : FloorSemiring { r : α // 0 ≤ r }
    where
  floor a := ⌊(a : α)⌋₊
  ceil a := ⌈(a : α)⌉₊
  floor_of_neg a ha := FloorSemiring.floor_of_neg ha
  gc_floor a n ha :=
    by
    refine' (FloorSemiring.gc_floor (show 0 ≤ (a : α) from ha)).trans _
    rw [← Subtype.coe_le_coe, Nonneg.coe_nat_cast]
  gc_ceil a n := by
    refine' (FloorSemiring.gc_ceil (a : α) n).trans _
    rw [← Subtype.coe_le_coe, Nonneg.coe_nat_cast]
#align nonneg.floor_semiring Nonneg.floorSemiring

@[norm_cast]
theorem nat_floor_coe [OrderedSemiring α] [FloorSemiring α] (a : { r : α // 0 ≤ r }) :
    ⌊(a : α)⌋₊ = ⌊a⌋₊ :=
  rfl
#align nonneg.nat_floor_coe Nonneg.nat_floor_coe

@[norm_cast]
theorem nat_ceil_coe [OrderedSemiring α] [FloorSemiring α] (a : { r : α // 0 ≤ r }) :
    ⌈(a : α)⌉₊ = ⌈a⌉₊ :=
  rfl
#align nonneg.nat_ceil_coe Nonneg.nat_ceil_coe

end Nonneg

