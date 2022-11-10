/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro, Johannes Hölzl
-/
import Mathbin.Algebra.Group.OrderSynonym
import Mathbin.Algebra.Order.Monoid.Cancel.Defs

/-! # Ordered monoid structures on the order dual. -/


universe u

variable {α : Type u}

open Function

namespace OrderDual

@[to_additive]
instance contravariant_class_mul_le [LE α] [Mul α] [c : ContravariantClass α α (· * ·) (· ≤ ·)] :
    ContravariantClass αᵒᵈ αᵒᵈ (· * ·) (· ≤ ·) :=
  ⟨c.1.flip⟩

@[to_additive]
instance covariant_class_mul_le [LE α] [Mul α] [c : CovariantClass α α (· * ·) (· ≤ ·)] :
    CovariantClass αᵒᵈ αᵒᵈ (· * ·) (· ≤ ·) :=
  ⟨c.1.flip⟩

@[to_additive]
instance contravariant_class_swap_mul_le [LE α] [Mul α] [c : ContravariantClass α α (swap (· * ·)) (· ≤ ·)] :
    ContravariantClass αᵒᵈ αᵒᵈ (swap (· * ·)) (· ≤ ·) :=
  ⟨c.1.flip⟩

@[to_additive]
instance covariant_class_swap_mul_le [LE α] [Mul α] [c : CovariantClass α α (swap (· * ·)) (· ≤ ·)] :
    CovariantClass αᵒᵈ αᵒᵈ (swap (· * ·)) (· ≤ ·) :=
  ⟨c.1.flip⟩

@[to_additive]
instance contravariant_class_mul_lt [LT α] [Mul α] [c : ContravariantClass α α (· * ·) (· < ·)] :
    ContravariantClass αᵒᵈ αᵒᵈ (· * ·) (· < ·) :=
  ⟨c.1.flip⟩

@[to_additive]
instance covariant_class_mul_lt [LT α] [Mul α] [c : CovariantClass α α (· * ·) (· < ·)] :
    CovariantClass αᵒᵈ αᵒᵈ (· * ·) (· < ·) :=
  ⟨c.1.flip⟩

@[to_additive]
instance contravariant_class_swap_mul_lt [LT α] [Mul α] [c : ContravariantClass α α (swap (· * ·)) (· < ·)] :
    ContravariantClass αᵒᵈ αᵒᵈ (swap (· * ·)) (· < ·) :=
  ⟨c.1.flip⟩

@[to_additive]
instance covariant_class_swap_mul_lt [LT α] [Mul α] [c : CovariantClass α α (swap (· * ·)) (· < ·)] :
    CovariantClass αᵒᵈ αᵒᵈ (swap (· * ·)) (· < ·) :=
  ⟨c.1.flip⟩

@[to_additive]
instance [OrderedCommMonoid α] : OrderedCommMonoid αᵒᵈ :=
  { OrderDual.partialOrder α, OrderDual.commMonoid with mul_le_mul_left := fun a b h c => mul_le_mul_left' h c }

@[to_additive OrderedCancelAddCommMonoid.to_contravariant_class]
instance OrderedCancelCommMonoid.to_contravariant_class [OrderedCancelCommMonoid α] :
    ContravariantClass αᵒᵈ αᵒᵈ Mul.mul LE.le where elim a b c := OrderedCancelCommMonoid.le_of_mul_le_mul_left a c b

@[to_additive]
instance [OrderedCancelCommMonoid α] : OrderedCancelCommMonoid αᵒᵈ :=
  { OrderDual.orderedCommMonoid, OrderDual.cancelCommMonoid with
    le_of_mul_le_mul_left := fun a b c : α => le_of_mul_le_mul_left' }

@[to_additive]
instance [LinearOrderedCancelCommMonoid α] : LinearOrderedCancelCommMonoid αᵒᵈ :=
  { OrderDual.linearOrder α, OrderDual.orderedCancelCommMonoid with }

@[to_additive]
instance [LinearOrderedCommMonoid α] : LinearOrderedCommMonoid αᵒᵈ :=
  { OrderDual.linearOrder α, OrderDual.orderedCommMonoid with }

end OrderDual

