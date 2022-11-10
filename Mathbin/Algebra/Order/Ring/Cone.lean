/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro
-/
import Mathbin.Algebra.Order.Ring.Defs

/-!
# Constructing an ordered ring from a ring with a specified positive cone.

-/


/-! ### Positive cones -/


namespace Ring

/-- A positive cone in a ring consists of a positive cone in underlying `add_comm_group`,
which contains `1` and such that the positive elements are closed under multiplication. -/
@[nolint has_nonempty_instance]
structure PositiveCone (α : Type _) [Ring α] extends AddCommGroup.PositiveCone α where
  one_nonneg : nonneg 1
  mul_pos : ∀ a b, Pos a → Pos b → Pos (a * b)

/-- Forget that a positive cone in a ring respects the multiplicative structure. -/
add_decl_doc positive_cone.to_positive_cone

/-- A positive cone in a ring induces a linear order if `1` is a positive element. -/
@[nolint has_nonempty_instance]
structure TotalPositiveCone (α : Type _) [Ring α] extends PositiveCone α, AddCommGroup.TotalPositiveCone α where
  one_pos : Pos 1

/-- Forget that a `total_positive_cone` in a ring is total. -/
add_decl_doc total_positive_cone.to_positive_cone

/-- Forget that a `total_positive_cone` in a ring respects the multiplicative structure. -/
add_decl_doc total_positive_cone.to_total_positive_cone

end Ring

namespace StrictOrderedRing

open Ring

/-- Construct a `strict_ordered_ring` by designating a positive cone in an existing `ring`. -/
def mkOfPositiveCone {α : Type _} [Ring α] (C : PositiveCone α) : StrictOrderedRing α :=
  { ‹Ring α›, OrderedAddCommGroup.mkOfPositiveCone C.toPositiveCone with
    zero_le_one := by
      change C.nonneg (1 - 0)
      convert C.one_nonneg
      simp,
    mul_pos := fun x y xp yp => by
      change C.pos (x * y - 0)
      convert
        C.mul_pos x y
          (by
            convert xp
            simp)
          (by
            convert yp
            simp)
      simp }

end StrictOrderedRing

namespace LinearOrderedRing

open Ring

/-- Construct a `linear_ordered_ring` by
designating a positive cone in an existing `ring`. -/
def mkOfPositiveCone {α : Type _} [Ring α] (C : TotalPositiveCone α) : LinearOrderedRing α :=
  { StrictOrderedRing.mkOfPositiveCone C.toPositiveCone,
    LinearOrderedAddCommGroup.mkOfPositiveCone C.toTotalPositiveCone with
    exists_pair_ne :=
      ⟨0, 1, by
        intro h
        have one_pos := C.one_pos
        rw [← h, C.pos_iff] at one_pos
        simpa using one_pos⟩ }

end LinearOrderedRing

