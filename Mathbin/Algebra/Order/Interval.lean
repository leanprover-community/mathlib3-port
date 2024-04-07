/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies
-/
import Algebra.Order.BigOperators.Group.Finset
import Algebra.Group.Prod
import Data.Option.NAry
import Data.Set.Pointwise.Basic
import Order.Interval
import Tactic.Positivity

#align_import algebra.order.interval from "leanprover-community/mathlib"@"6b31d1eebd64eab86d5bd9936bfaada6ca8b5842"

/-!
# Interval arithmetic

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines arithmetic operations on intervals and prove their correctness. Note that this is
full precision operations. The essentials of float operations can be found
in `data.fp.basic`. We have not yet integrated these with the rest of the library.
-/


open Function Set

open scoped BigOperators Pointwise

universe u

variable {ι α : Type _}

/-! ### One/zero -/


section One

section Preorder

variable [Preorder α] [One α]

@[to_additive]
instance : One (NonemptyInterval α) :=
  ⟨NonemptyInterval.pure 1⟩

@[to_additive]
instance : One (Interval α) :=
  ⟨Interval.pure 1⟩

namespace NonemptyInterval

#print NonemptyInterval.toProd_one /-
@[simp, to_additive to_prod_zero]
theorem toProd_one : (1 : NonemptyInterval α).toProd = 1 :=
  rfl
#align nonempty_interval.to_prod_one NonemptyInterval.toProd_one
#align nonempty_interval.to_prod_zero NonemptyInterval.toProd_zero
-/

#print NonemptyInterval.fst_one /-
@[to_additive]
theorem fst_one : (1 : NonemptyInterval α).fst = 1 :=
  rfl
#align nonempty_interval.fst_one NonemptyInterval.fst_one
#align nonempty_interval.fst_zero NonemptyInterval.fst_zero
-/

#print NonemptyInterval.snd_one /-
@[to_additive]
theorem snd_one : (1 : NonemptyInterval α).snd = 1 :=
  rfl
#align nonempty_interval.snd_one NonemptyInterval.snd_one
#align nonempty_interval.snd_zero NonemptyInterval.snd_zero
-/

#print NonemptyInterval.coe_one_interval /-
@[simp, norm_cast, to_additive]
theorem coe_one_interval : ((1 : NonemptyInterval α) : Interval α) = 1 :=
  rfl
#align nonempty_interval.coe_one_interval NonemptyInterval.coe_one_interval
#align nonempty_interval.coe_zero_interval NonemptyInterval.coe_zero_interval
-/

#print NonemptyInterval.pure_one /-
@[simp, to_additive]
theorem pure_one : pure (1 : α) = 1 :=
  rfl
#align nonempty_interval.pure_one NonemptyInterval.pure_one
#align nonempty_interval.pure_zero NonemptyInterval.pure_zero
-/

end NonemptyInterval

namespace Interval

#print Interval.pure_one /-
@[simp, to_additive]
theorem pure_one : pure (1 : α) = 1 :=
  rfl
#align interval.pure_one Interval.pure_one
#align interval.pure_zero Interval.pure_zero
-/

#print Interval.one_ne_bot /-
@[simp, to_additive]
theorem one_ne_bot : (1 : Interval α) ≠ ⊥ :=
  pure_ne_bot
#align interval.one_ne_bot Interval.one_ne_bot
#align interval.zero_ne_bot Interval.zero_ne_bot
-/

#print Interval.bot_ne_one /-
@[simp, to_additive]
theorem bot_ne_one : (⊥ : Interval α) ≠ 1 :=
  bot_ne_pure
#align interval.bot_ne_one Interval.bot_ne_one
#align interval.bot_ne_zero Interval.bot_ne_zero
-/

end Interval

end Preorder

section PartialOrder

variable [PartialOrder α] [One α]

namespace NonemptyInterval

#print NonemptyInterval.coe_one /-
@[simp, to_additive]
theorem coe_one : ((1 : NonemptyInterval α) : Set α) = 1 :=
  coe_pure _
#align nonempty_interval.coe_one NonemptyInterval.coe_one
#align nonempty_interval.coe_zero NonemptyInterval.coe_zero
-/

#print NonemptyInterval.one_mem_one /-
@[to_additive]
theorem one_mem_one : (1 : α) ∈ (1 : NonemptyInterval α) :=
  ⟨le_rfl, le_rfl⟩
#align nonempty_interval.one_mem_one NonemptyInterval.one_mem_one
#align nonempty_interval.zero_mem_zero NonemptyInterval.zero_mem_zero
-/

end NonemptyInterval

namespace Interval

#print Interval.coe_one /-
@[simp, to_additive]
theorem coe_one : ((1 : Interval α) : Set α) = 1 :=
  Icc_self _
#align interval.coe_one Interval.coe_one
#align interval.coe_zero Interval.coe_zero
-/

#print Interval.one_mem_one /-
@[to_additive]
theorem one_mem_one : (1 : α) ∈ (1 : Interval α) :=
  ⟨le_rfl, le_rfl⟩
#align interval.one_mem_one Interval.one_mem_one
#align interval.zero_mem_zero Interval.zero_mem_zero
-/

end Interval

end PartialOrder

end One

/-!
### Addition/multiplication

Note that this multiplication does not apply to `ℚ` or `ℝ`.
-/


section Mul

variable [Preorder α] [Mul α] [CovariantClass α α (· * ·) (· ≤ ·)]
  [CovariantClass α α (swap (· * ·)) (· ≤ ·)]

@[to_additive]
instance : Mul (NonemptyInterval α) :=
  ⟨fun s t => ⟨s.toProd * t.toProd, mul_le_mul' s.fst_le_snd t.fst_le_snd⟩⟩

@[to_additive]
instance : Mul (Interval α) :=
  ⟨Option.map₂ (· * ·)⟩

namespace NonemptyInterval

variable (s t : NonemptyInterval α) (a b : α)

#print NonemptyInterval.toProd_mul /-
@[simp, to_additive to_prod_add]
theorem toProd_mul : (s * t).toProd = s.toProd * t.toProd :=
  rfl
#align nonempty_interval.to_prod_mul NonemptyInterval.toProd_mul
#align nonempty_interval.to_prod_add NonemptyInterval.toProd_add
-/

#print NonemptyInterval.fst_mul /-
@[to_additive]
theorem fst_mul : (s * t).fst = s.fst * t.fst :=
  rfl
#align nonempty_interval.fst_mul NonemptyInterval.fst_mul
#align nonempty_interval.fst_add NonemptyInterval.fst_add
-/

#print NonemptyInterval.snd_mul /-
@[to_additive]
theorem snd_mul : (s * t).snd = s.snd * t.snd :=
  rfl
#align nonempty_interval.snd_mul NonemptyInterval.snd_mul
#align nonempty_interval.snd_add NonemptyInterval.snd_add
-/

#print NonemptyInterval.coe_mul_interval /-
@[simp, to_additive]
theorem coe_mul_interval : (↑(s * t) : Interval α) = s * t :=
  rfl
#align nonempty_interval.coe_mul_interval NonemptyInterval.coe_mul_interval
#align nonempty_interval.coe_add_interval NonemptyInterval.coe_add_interval
-/

#print NonemptyInterval.pure_mul_pure /-
@[simp, to_additive]
theorem pure_mul_pure : pure a * pure b = pure (a * b) :=
  rfl
#align nonempty_interval.pure_mul_pure NonemptyInterval.pure_mul_pure
#align nonempty_interval.pure_add_pure NonemptyInterval.pure_add_pure
-/

end NonemptyInterval

namespace Interval

variable (s t : Interval α)

#print Interval.bot_mul /-
@[simp, to_additive]
theorem bot_mul : ⊥ * t = ⊥ :=
  rfl
#align interval.bot_mul Interval.bot_mul
#align interval.bot_add Interval.bot_add
-/

#print Interval.mul_bot /-
@[simp, to_additive]
theorem mul_bot : s * ⊥ = ⊥ :=
  Option.map₂_none_right _ _
#align interval.mul_bot Interval.mul_bot
#align interval.add_bot Interval.add_bot
-/

end Interval

end Mul

/-! ### Powers -/


#print NonemptyInterval.hasNSMul /-
-- TODO: if `to_additive` gets improved sufficiently, derive this from `has_pow`
instance NonemptyInterval.hasNSMul [AddMonoid α] [Preorder α] [CovariantClass α α (· + ·) (· ≤ ·)]
    [CovariantClass α α (swap (· + ·)) (· ≤ ·)] : SMul ℕ (NonemptyInterval α) :=
  ⟨fun n s => ⟨(n • s.fst, n • s.snd), nsmul_le_nsmul_right s.fst_le_snd _⟩⟩
#align nonempty_interval.has_nsmul NonemptyInterval.hasNSMul
-/

section Pow

variable [Monoid α] [Preorder α] [CovariantClass α α (· * ·) (· ≤ ·)]
  [CovariantClass α α (swap (· * ·)) (· ≤ ·)]

#print NonemptyInterval.hasPow /-
@[to_additive NonemptyInterval.hasNSMul]
instance NonemptyInterval.hasPow : Pow (NonemptyInterval α) ℕ :=
  ⟨fun s n => ⟨s.toProd ^ n, pow_le_pow_left' s.fst_le_snd _⟩⟩
#align nonempty_interval.has_pow NonemptyInterval.hasPow
#align nonempty_interval.has_nsmul NonemptyInterval.hasNSMul
-/

namespace NonemptyInterval

variable (s : NonemptyInterval α) (a : α) (n : ℕ)

#print NonemptyInterval.toProd_pow /-
@[simp, to_additive to_prod_nsmul]
theorem toProd_pow : (s ^ n).toProd = s.toProd ^ n :=
  rfl
#align nonempty_interval.to_prod_pow NonemptyInterval.toProd_pow
#align nonempty_interval.to_prod_nsmul NonemptyInterval.toProd_nsmul
-/

#print NonemptyInterval.fst_pow /-
@[to_additive]
theorem fst_pow : (s ^ n).fst = s.fst ^ n :=
  rfl
#align nonempty_interval.fst_pow NonemptyInterval.fst_pow
#align nonempty_interval.fst_nsmul NonemptyInterval.fst_nsmul
-/

#print NonemptyInterval.snd_pow /-
@[to_additive]
theorem snd_pow : (s ^ n).snd = s.snd ^ n :=
  rfl
#align nonempty_interval.snd_pow NonemptyInterval.snd_pow
#align nonempty_interval.snd_nsmul NonemptyInterval.snd_nsmul
-/

#print NonemptyInterval.pure_pow /-
@[simp, to_additive]
theorem pure_pow : pure a ^ n = pure (a ^ n) :=
  rfl
#align nonempty_interval.pure_pow NonemptyInterval.pure_pow
#align nonempty_interval.pure_nsmul NonemptyInterval.pure_nsmul
-/

end NonemptyInterval

end Pow

namespace NonemptyInterval

@[to_additive]
instance [OrderedCommMonoid α] : CommMonoid (NonemptyInterval α) :=
  NonemptyInterval.toProd_injective.CommMonoid _ toProd_one toProd_mul toProd_pow

end NonemptyInterval

@[to_additive]
instance [OrderedCommMonoid α] : MulOneClass (Interval α)
    where
  mul := (· * ·)
  one := 1
  one_mul s :=
    (Option.map₂_coe_left _ _ _).trans <| by
      simp only [NonemptyInterval.pure_one, one_mul, ← id_def, Option.map_id, id]
  mul_one s :=
    (Option.map₂_coe_right _ _ _).trans <| by
      simp only [NonemptyInterval.pure_one, mul_one, ← id_def, Option.map_id, id]

@[to_additive]
instance [OrderedCommMonoid α] : CommMonoid (Interval α) :=
  {
    Interval.mulOneClass with
    mul_comm := fun _ _ => Option.map₂_comm mul_comm
    mul_assoc := fun _ _ _ => Option.map₂_assoc mul_assoc }

namespace NonemptyInterval

#print NonemptyInterval.coe_pow_interval /-
@[simp, to_additive]
theorem coe_pow_interval [OrderedCommMonoid α] (s : NonemptyInterval α) (n : ℕ) :
    (↑(s ^ n) : Interval α) = s ^ n :=
  map_pow (⟨coe, coe_one_interval, coe_mul_interval⟩ : NonemptyInterval α →* Interval α) _ _
#align nonempty_interval.coe_pow_interval NonemptyInterval.coe_pow_interval
#align nonempty_interval.coe_nsmul_interval NonemptyInterval.coe_nsmul_interval
-/

end NonemptyInterval

namespace Interval

variable [OrderedCommMonoid α] (s : Interval α) {n : ℕ}

#print Interval.bot_pow /-
@[to_additive]
theorem bot_pow : ∀ {n : ℕ} (hn : n ≠ 0), (⊥ : Interval α) ^ n = ⊥
  | 0, h => (h rfl).elim
  | Nat.succ n, _ => bot_mul (⊥ ^ n)
#align interval.bot_pow Interval.bot_pow
#align interval.bot_nsmul Interval.bot_nsmul
-/

end Interval

/-!
### Subtraction

Subtraction is defined more generally than division so that it applies to `ℕ` (and `has_ordered_div`
is not a thing and probably should not become one).
-/


section Sub

variable [Preorder α] [AddCommSemigroup α] [Sub α] [OrderedSub α]
  [CovariantClass α α (· + ·) (· ≤ ·)]

instance : Sub (NonemptyInterval α) :=
  ⟨fun s t => ⟨(s.fst - t.snd, s.snd - t.fst), tsub_le_tsub s.fst_le_snd t.fst_le_snd⟩⟩

instance : Sub (Interval α) :=
  ⟨Option.map₂ Sub.sub⟩

namespace NonemptyInterval

variable (s t : NonemptyInterval α) {a b : α}

#print NonemptyInterval.fst_sub /-
@[simp]
theorem fst_sub : (s - t).fst = s.fst - t.snd :=
  rfl
#align nonempty_interval.fst_sub NonemptyInterval.fst_sub
-/

#print NonemptyInterval.snd_sub /-
@[simp]
theorem snd_sub : (s - t).snd = s.snd - t.fst :=
  rfl
#align nonempty_interval.snd_sub NonemptyInterval.snd_sub
-/

#print NonemptyInterval.coe_sub_interval /-
@[simp]
theorem coe_sub_interval : (↑(s - t) : Interval α) = s - t :=
  rfl
#align nonempty_interval.coe_sub_interval NonemptyInterval.coe_sub_interval
-/

#print NonemptyInterval.sub_mem_sub /-
theorem sub_mem_sub (ha : a ∈ s) (hb : b ∈ t) : a - b ∈ s - t :=
  ⟨tsub_le_tsub ha.1 hb.2, tsub_le_tsub ha.2 hb.1⟩
#align nonempty_interval.sub_mem_sub NonemptyInterval.sub_mem_sub
-/

#print NonemptyInterval.pure_sub_pure /-
@[simp]
theorem pure_sub_pure (a b : α) : pure a - pure b = pure (a - b) :=
  rfl
#align nonempty_interval.pure_sub_pure NonemptyInterval.pure_sub_pure
-/

end NonemptyInterval

namespace Interval

variable (s t : Interval α)

#print Interval.bot_sub /-
@[simp]
theorem bot_sub : ⊥ - t = ⊥ :=
  rfl
#align interval.bot_sub Interval.bot_sub
-/

#print Interval.sub_bot /-
@[simp]
theorem sub_bot : s - ⊥ = ⊥ :=
  Option.map₂_none_right _ _
#align interval.sub_bot Interval.sub_bot
-/

end Interval

end Sub

/-!
### Division in ordered groups

Note that this division does not apply to `ℚ` or `ℝ`.
-/


section Div

variable [Preorder α] [CommGroup α] [CovariantClass α α (· * ·) (· ≤ ·)]

@[to_additive]
instance : Div (NonemptyInterval α) :=
  ⟨fun s t => ⟨(s.fst / t.snd, s.snd / t.fst), div_le_div'' s.fst_le_snd t.fst_le_snd⟩⟩

@[to_additive]
instance : Div (Interval α) :=
  ⟨Option.map₂ (· / ·)⟩

namespace NonemptyInterval

variable (s t : NonemptyInterval α) (a b : α)

#print NonemptyInterval.fst_div /-
@[simp, to_additive]
theorem fst_div : (s / t).fst = s.fst / t.snd :=
  rfl
#align nonempty_interval.fst_div NonemptyInterval.fst_div
#align nonempty_interval.fst_sub NonemptyInterval.fst_sub
-/

#print NonemptyInterval.snd_div /-
@[simp, to_additive]
theorem snd_div : (s / t).snd = s.snd / t.fst :=
  rfl
#align nonempty_interval.snd_div NonemptyInterval.snd_div
#align nonempty_interval.snd_sub NonemptyInterval.snd_sub
-/

#print NonemptyInterval.coe_div_interval /-
@[simp, to_additive]
theorem coe_div_interval : (↑(s / t) : Interval α) = s / t :=
  rfl
#align nonempty_interval.coe_div_interval NonemptyInterval.coe_div_interval
#align nonempty_interval.coe_sub_interval NonemptyInterval.coe_sub_interval
-/

#print NonemptyInterval.div_mem_div /-
@[to_additive]
theorem div_mem_div (ha : a ∈ s) (hb : b ∈ t) : a / b ∈ s / t :=
  ⟨div_le_div'' ha.1 hb.2, div_le_div'' ha.2 hb.1⟩
#align nonempty_interval.div_mem_div NonemptyInterval.div_mem_div
#align nonempty_interval.sub_mem_sub NonemptyInterval.sub_mem_sub
-/

#print NonemptyInterval.pure_div_pure /-
@[simp, to_additive]
theorem pure_div_pure : pure a / pure b = pure (a / b) :=
  rfl
#align nonempty_interval.pure_div_pure NonemptyInterval.pure_div_pure
#align nonempty_interval.pure_sub_pure NonemptyInterval.pure_sub_pure
-/

end NonemptyInterval

namespace Interval

variable (s t : Interval α)

#print Interval.bot_div /-
@[simp, to_additive]
theorem bot_div : ⊥ / t = ⊥ :=
  rfl
#align interval.bot_div Interval.bot_div
#align interval.bot_sub Interval.bot_sub
-/

#print Interval.div_bot /-
@[simp, to_additive]
theorem div_bot : s / ⊥ = ⊥ :=
  Option.map₂_none_right _ _
#align interval.div_bot Interval.div_bot
#align interval.sub_bot Interval.sub_bot
-/

end Interval

end Div

/-! ### Negation/inversion -/


section Inv

variable [OrderedCommGroup α]

@[to_additive]
instance : Inv (NonemptyInterval α) :=
  ⟨fun s => ⟨(s.snd⁻¹, s.fst⁻¹), inv_le_inv' s.fst_le_snd⟩⟩

@[to_additive]
instance : Inv (Interval α) :=
  ⟨Option.map Inv.inv⟩

namespace NonemptyInterval

variable (s t : NonemptyInterval α) (a : α)

#print NonemptyInterval.fst_inv /-
@[simp, to_additive]
theorem fst_inv : s⁻¹.fst = s.snd⁻¹ :=
  rfl
#align nonempty_interval.fst_inv NonemptyInterval.fst_inv
#align nonempty_interval.fst_neg NonemptyInterval.fst_neg
-/

#print NonemptyInterval.snd_inv /-
@[simp, to_additive]
theorem snd_inv : s⁻¹.snd = s.fst⁻¹ :=
  rfl
#align nonempty_interval.snd_inv NonemptyInterval.snd_inv
#align nonempty_interval.snd_neg NonemptyInterval.snd_neg
-/

#print NonemptyInterval.coe_inv_interval /-
@[simp, to_additive]
theorem coe_inv_interval : (↑s⁻¹ : Interval α) = s⁻¹ :=
  rfl
#align nonempty_interval.coe_inv_interval NonemptyInterval.coe_inv_interval
#align nonempty_interval.coe_neg_interval NonemptyInterval.coe_neg_interval
-/

#print NonemptyInterval.inv_mem_inv /-
@[to_additive]
theorem inv_mem_inv (ha : a ∈ s) : a⁻¹ ∈ s⁻¹ :=
  ⟨inv_le_inv' ha.2, inv_le_inv' ha.1⟩
#align nonempty_interval.inv_mem_inv NonemptyInterval.inv_mem_inv
#align nonempty_interval.neg_mem_neg NonemptyInterval.neg_mem_neg
-/

#print NonemptyInterval.inv_pure /-
@[simp, to_additive]
theorem inv_pure : (pure a)⁻¹ = pure a⁻¹ :=
  rfl
#align nonempty_interval.inv_pure NonemptyInterval.inv_pure
#align nonempty_interval.neg_pure NonemptyInterval.neg_pure
-/

end NonemptyInterval

#print Interval.inv_bot /-
@[simp, to_additive]
theorem Interval.inv_bot : (⊥ : Interval α)⁻¹ = ⊥ :=
  rfl
#align interval.inv_bot Interval.inv_bot
#align interval.neg_bot Interval.neg_bot
-/

end Inv

namespace NonemptyInterval

variable [OrderedCommGroup α] {s t : NonemptyInterval α}

#print NonemptyInterval.mul_eq_one_iff /-
@[to_additive]
protected theorem mul_eq_one_iff : s * t = 1 ↔ ∃ a b, s = pure a ∧ t = pure b ∧ a * b = 1 :=
  by
  refine' ⟨fun h => _, _⟩
  · rw [ext_iff, Prod.ext_iff] at h
    have := (mul_le_mul_iff_of_ge s.fst_le_snd t.fst_le_snd).1 (h.2.trans h.1.symm).le
    refine' ⟨s.fst, t.fst, _, _, h.1⟩ <;> ext <;> try rfl
    exacts [this.1.symm, this.2.symm]
  · rintro ⟨b, c, rfl, rfl, h⟩
    rw [pure_mul_pure, h, pure_one]
#align nonempty_interval.mul_eq_one_iff NonemptyInterval.mul_eq_one_iff
#align nonempty_interval.add_eq_zero_iff NonemptyInterval.add_eq_zero_iff
-/

instance {α : Type u} [OrderedAddCommGroup α] : SubtractionCommMonoid (NonemptyInterval α) :=
  { NonemptyInterval.addCommMonoid with
    neg := Neg.neg
    sub := Sub.sub
    sub_eq_add_neg := fun s t => by ext <;> exact sub_eq_add_neg _ _
    neg_neg := fun s => by ext <;> exact neg_neg _
    neg_add_rev := fun s t => by ext <;> exact neg_add_rev _ _
    neg_eq_of_add := fun s t h =>
      by
      obtain ⟨a, b, rfl, rfl, hab⟩ := NonemptyInterval.add_eq_zero_iff.1 h
      rw [neg_pure, neg_eq_of_add_eq_zero_right hab] }

@[to_additive NonemptyInterval.subtractionCommMonoid]
instance : DivisionCommMonoid (NonemptyInterval α) :=
  { NonemptyInterval.commMonoid with
    inv := Inv.inv
    div := (· / ·)
    div_eq_hMul_inv := fun s t => by ext <;> exact div_eq_mul_inv _ _
    inv_inv := fun s => by ext <;> exact inv_inv _
    mul_inv_rev := fun s t => by ext <;> exact mul_inv_rev _ _
    inv_eq_of_hMul := fun s t h =>
      by
      obtain ⟨a, b, rfl, rfl, hab⟩ := NonemptyInterval.mul_eq_one_iff.1 h
      rw [inv_pure, inv_eq_of_mul_eq_one_right hab] }

end NonemptyInterval

namespace Interval

variable [OrderedCommGroup α] {s t : Interval α}

#print Interval.mul_eq_one_iff /-
@[to_additive]
protected theorem mul_eq_one_iff : s * t = 1 ↔ ∃ a b, s = pure a ∧ t = pure b ∧ a * b = 1 :=
  by
  cases s
  · simp [WithBot.none_eq_bot]
  cases t
  · simp [WithBot.none_eq_bot]
  · simp [WithBot.some_eq_coe, ← NonemptyInterval.coe_mul_interval, NonemptyInterval.mul_eq_one_iff]
#align interval.mul_eq_one_iff Interval.mul_eq_one_iff
#align interval.add_eq_zero_iff Interval.add_eq_zero_iff
-/

instance {α : Type u} [OrderedAddCommGroup α] : SubtractionCommMonoid (Interval α) :=
  { Interval.addCommMonoid with
    neg := Neg.neg
    sub := Sub.sub
    sub_eq_add_neg := by
      rintro (_ | s) (_ | t) <;>
        first
        | rfl
        | exact congr_arg some (sub_eq_add_neg _ _)
    neg_neg := by
      rintro (_ | s) <;>
        first
        | rfl
        | exact congr_arg some (neg_neg _)
    neg_add_rev := by
      rintro (_ | s) (_ | t) <;>
        first
        | rfl
        | exact congr_arg some (neg_add_rev _ _)
    neg_eq_of_add := by
      rintro (_ | s) (_ | t) h <;>
        first
        | cases h
        | exact congr_arg some (neg_eq_of_add_eq_zero_right <| Option.some_injective _ h) }

@[to_additive Interval.subtractionCommMonoid]
instance : DivisionCommMonoid (Interval α) :=
  { Interval.commMonoid with
    inv := Inv.inv
    div := (· / ·)
    div_eq_hMul_inv := by
      rintro (_ | s) (_ | t) <;>
        first
        | rfl
        | exact congr_arg some (div_eq_mul_inv _ _)
    inv_inv := by
      rintro (_ | s) <;>
        first
        | rfl
        | exact congr_arg some (inv_inv _)
    mul_inv_rev := by
      rintro (_ | s) (_ | t) <;>
        first
        | rfl
        | exact congr_arg some (mul_inv_rev _ _)
    inv_eq_of_hMul := by
      rintro (_ | s) (_ | t) h <;>
        first
        | cases h
        | exact congr_arg some (inv_eq_of_mul_eq_one_right <| Option.some_injective _ h) }

end Interval

section Length

variable [OrderedAddCommGroup α]

namespace NonemptyInterval

variable (s t : NonemptyInterval α) (a : α)

#print NonemptyInterval.length /-
/-- The length of an interval is its first component minus its second component. This measures the
accuracy of the approximation by an interval. -/
def length : α :=
  s.snd - s.fst
#align nonempty_interval.length NonemptyInterval.length
-/

#print NonemptyInterval.length_nonneg /-
@[simp]
theorem length_nonneg : 0 ≤ s.length :=
  sub_nonneg_of_le s.fst_le_snd
#align nonempty_interval.length_nonneg NonemptyInterval.length_nonneg
-/

#print NonemptyInterval.length_pure /-
@[simp]
theorem length_pure : (pure a).length = 0 :=
  sub_self _
#align nonempty_interval.length_pure NonemptyInterval.length_pure
-/

#print NonemptyInterval.length_zero /-
@[simp]
theorem length_zero : (0 : NonemptyInterval α).length = 0 :=
  length_pure _
#align nonempty_interval.length_zero NonemptyInterval.length_zero
-/

#print NonemptyInterval.length_neg /-
@[simp]
theorem length_neg : (-s).length = s.length :=
  neg_sub_neg _ _
#align nonempty_interval.length_neg NonemptyInterval.length_neg
-/

#print NonemptyInterval.length_add /-
@[simp]
theorem length_add : (s + t).length = s.length + t.length :=
  add_sub_add_comm _ _ _ _
#align nonempty_interval.length_add NonemptyInterval.length_add
-/

#print NonemptyInterval.length_sub /-
@[simp]
theorem length_sub : (s - t).length = s.length + t.length := by simp [sub_eq_add_neg]
#align nonempty_interval.length_sub NonemptyInterval.length_sub
-/

#print NonemptyInterval.length_sum /-
@[simp]
theorem length_sum (f : ι → NonemptyInterval α) (s : Finset ι) :
    (∑ i in s, f i).length = ∑ i in s, (f i).length :=
  map_sum (⟨length, length_zero, length_add⟩ : NonemptyInterval α →+ α) _ _
#align nonempty_interval.length_sum NonemptyInterval.length_sum
-/

end NonemptyInterval

namespace Interval

variable (s t : Interval α) (a : α)

#print Interval.length /-
/-- The length of an interval is its first component minus its second component. This measures the
accuracy of the approximation by an interval. -/
def length : Interval α → α
  | ⊥ => 0
  | (s : NonemptyInterval α) => s.length
#align interval.length Interval.length
-/

#print Interval.length_nonneg /-
@[simp]
theorem length_nonneg : ∀ s : Interval α, 0 ≤ s.length
  | ⊥ => le_rfl
  | (s : NonemptyInterval α) => s.length_nonneg
#align interval.length_nonneg Interval.length_nonneg
-/

#print Interval.length_pure /-
@[simp]
theorem length_pure : (pure a).length = 0 :=
  NonemptyInterval.length_pure _
#align interval.length_pure Interval.length_pure
-/

#print Interval.length_zero /-
@[simp]
theorem length_zero : (0 : Interval α).length = 0 :=
  length_pure _
#align interval.length_zero Interval.length_zero
-/

#print Interval.length_neg /-
@[simp]
theorem length_neg : ∀ s : Interval α, (-s).length = s.length
  | ⊥ => rfl
  | (s : NonemptyInterval α) => s.length_neg
#align interval.length_neg Interval.length_neg
-/

#print Interval.length_add_le /-
theorem length_add_le : ∀ s t : Interval α, (s + t).length ≤ s.length + t.length
  | ⊥, _ => by simp
  | _, ⊥ => by simp
  | (s : NonemptyInterval α), (t : NonemptyInterval α) => (s.length_add t).le
#align interval.length_add_le Interval.length_add_le
-/

#print Interval.length_sub_le /-
theorem length_sub_le : (s - t).length ≤ s.length + t.length := by
  simpa [sub_eq_add_neg] using length_add_le s (-t)
#align interval.length_sub_le Interval.length_sub_le
-/

#print Interval.length_sum_le /-
theorem length_sum_le (f : ι → Interval α) (s : Finset ι) :
    (∑ i in s, f i).length ≤ ∑ i in s, (f i).length :=
  Finset.le_sum_of_subadditive _ length_zero length_add_le _ _
#align interval.length_sum_le Interval.length_sum_le
-/

end Interval

end Length

namespace Tactic

open Positivity

/-- Extension for the `positivity` tactic: The length of an interval is always nonnegative. -/
@[positivity]
unsafe def positivity_interval_length : expr → tactic strictness
  | q(NonemptyInterval.length $(s)) => nonnegative <$> mk_app `nonempty_interval.length_nonneg [s]
  | q(Interval.length $(s)) => nonnegative <$> mk_app `interval.length_nonneg [s]
  | e =>
    pp e >>=
      fail ∘
        format.bracket "The expression `"
          "` isn't of the form `nonempty_interval.length s` or `interval.length s`"
#align tactic.positivity_interval_length tactic.positivity_interval_length

end Tactic

