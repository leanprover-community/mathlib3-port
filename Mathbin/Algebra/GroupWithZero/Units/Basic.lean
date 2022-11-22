/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin
-/
import Mathbin.Algebra.GroupWithZero.Basic
import Mathbin.Algebra.Group.Units
import Mathbin.Tactic.Nontriviality
import Mathbin.Tactic.AssertExists

/-!
# Lemmas about units in a `monoid_with_zero` or a `group_with_zero`.

We also define `ring.inverse`, a globally defined function on any ring
(in fact any `monoid_with_zero`), which inverts units and sends non-units to zero.
-/


variable {α M₀ G₀ M₀' G₀' F F' : Type _}

variable [MonoidWithZero M₀]

namespace Units

/-- An element of the unit group of a nonzero monoid with zero represented as an element
    of the monoid is nonzero. -/
@[simp]
theorem ne_zero [Nontrivial M₀] (u : M₀ˣ) : (u : M₀) ≠ 0 :=
  left_ne_zero_of_mul_eq_one u.mul_inv
#align units.ne_zero Units.ne_zero

-- We can't use `mul_eq_zero` + `units.ne_zero` in the next two lemmas because we don't assume
-- `nonzero M₀`.
@[simp]
theorem mul_left_eq_zero (u : M₀ˣ) {a : M₀} : a * u = 0 ↔ a = 0 :=
  ⟨fun h => by simpa using mul_eq_zero_of_left h ↑u⁻¹, fun h => mul_eq_zero_of_left h u⟩
#align units.mul_left_eq_zero Units.mul_left_eq_zero

@[simp]
theorem mul_right_eq_zero (u : M₀ˣ) {a : M₀} : ↑u * a = 0 ↔ a = 0 :=
  ⟨fun h => by simpa using mul_eq_zero_of_right (↑u⁻¹) h, mul_eq_zero_of_right u⟩
#align units.mul_right_eq_zero Units.mul_right_eq_zero

end Units

namespace IsUnit

theorem ne_zero [Nontrivial M₀] {a : M₀} (ha : IsUnit a) : a ≠ 0 :=
  let ⟨u, hu⟩ := ha
  hu ▸ u.NeZero
#align is_unit.ne_zero IsUnit.ne_zero

theorem mul_right_eq_zero {a b : M₀} (ha : IsUnit a) : a * b = 0 ↔ b = 0 :=
  let ⟨u, hu⟩ := ha
  hu ▸ u.mul_right_eq_zero
#align is_unit.mul_right_eq_zero IsUnit.mul_right_eq_zero

theorem mul_left_eq_zero {a b : M₀} (hb : IsUnit b) : a * b = 0 ↔ a = 0 :=
  let ⟨u, hu⟩ := hb
  hu ▸ u.mul_left_eq_zero
#align is_unit.mul_left_eq_zero IsUnit.mul_left_eq_zero

end IsUnit

@[simp]
theorem is_unit_zero_iff : IsUnit (0 : M₀) ↔ (0 : M₀) = 1 :=
  ⟨fun ⟨⟨_, a, (a0 : 0 * a = 1), _⟩, rfl⟩ => by rwa [zero_mul] at a0, fun h =>
    @is_unit_of_subsingleton _ _ (subsingleton_of_zero_eq_one h) 0⟩
#align is_unit_zero_iff is_unit_zero_iff

@[simp]
theorem not_is_unit_zero [Nontrivial M₀] : ¬IsUnit (0 : M₀) :=
  mt is_unit_zero_iff.1 zero_ne_one
#align not_is_unit_zero not_is_unit_zero

namespace Ring

open Classical

/-- Introduce a function `inverse` on a monoid with zero `M₀`, which sends `x` to `x⁻¹` if `x` is
invertible and to `0` otherwise.  This definition is somewhat ad hoc, but one needs a fully (rather
than partially) defined inverse function for some purposes, including for calculus.

Note that while this is in the `ring` namespace for brevity, it requires the weaker assumption
`monoid_with_zero M₀` instead of `ring M₀`. -/
noncomputable def inverse : M₀ → M₀ := fun x => if h : IsUnit x then ((h.Unit⁻¹ : M₀ˣ) : M₀) else 0
#align ring.inverse Ring.inverse

/-- By definition, if `x` is invertible then `inverse x = x⁻¹`. -/
@[simp]
theorem inverse_unit (u : M₀ˣ) : inverse (u : M₀) = (u⁻¹ : M₀ˣ) := by
  simp only [Units.is_unit, inverse, dif_pos]
  exact Units.inv_unique rfl
#align ring.inverse_unit Ring.inverse_unit

/-- By definition, if `x` is not invertible then `inverse x = 0`. -/
@[simp]
theorem inverse_non_unit (x : M₀) (h : ¬IsUnit x) : inverse x = 0 :=
  dif_neg h
#align ring.inverse_non_unit Ring.inverse_non_unit

theorem mul_inverse_cancel (x : M₀) (h : IsUnit x) : x * inverse x = 1 := by
  rcases h with ⟨u, rfl⟩
  rw [inverse_unit, Units.mul_inv]
#align ring.mul_inverse_cancel Ring.mul_inverse_cancel

theorem inverse_mul_cancel (x : M₀) (h : IsUnit x) : inverse x * x = 1 := by
  rcases h with ⟨u, rfl⟩
  rw [inverse_unit, Units.inv_mul]
#align ring.inverse_mul_cancel Ring.inverse_mul_cancel

theorem mul_inverse_cancel_right (x y : M₀) (h : IsUnit x) : y * x * inverse x = y := by
  rw [mul_assoc, mul_inverse_cancel x h, mul_one]
#align ring.mul_inverse_cancel_right Ring.mul_inverse_cancel_right

theorem inverse_mul_cancel_right (x y : M₀) (h : IsUnit x) : y * inverse x * x = y := by
  rw [mul_assoc, inverse_mul_cancel x h, mul_one]
#align ring.inverse_mul_cancel_right Ring.inverse_mul_cancel_right

theorem mul_inverse_cancel_left (x y : M₀) (h : IsUnit x) : x * (inverse x * y) = y := by
  rw [← mul_assoc, mul_inverse_cancel x h, one_mul]
#align ring.mul_inverse_cancel_left Ring.mul_inverse_cancel_left

theorem inverse_mul_cancel_left (x y : M₀) (h : IsUnit x) : inverse x * (x * y) = y := by
  rw [← mul_assoc, inverse_mul_cancel x h, one_mul]
#align ring.inverse_mul_cancel_left Ring.inverse_mul_cancel_left

theorem inverse_mul_eq_iff_eq_mul (x y z : M₀) (h : IsUnit x) : inverse x * y = z ↔ y = x * z :=
  ⟨fun h1 => by rw [← h1, mul_inverse_cancel_left _ _ h], fun h1 => by rw [h1, inverse_mul_cancel_left _ _ h]⟩
#align ring.inverse_mul_eq_iff_eq_mul Ring.inverse_mul_eq_iff_eq_mul

theorem eq_mul_inverse_iff_mul_eq (x y z : M₀) (h : IsUnit z) : x = y * inverse z ↔ x * z = y :=
  ⟨fun h1 => by rw [h1, inverse_mul_cancel_right _ _ h], fun h1 => by rw [← h1, mul_inverse_cancel_right _ _ h]⟩
#align ring.eq_mul_inverse_iff_mul_eq Ring.eq_mul_inverse_iff_mul_eq

variable (M₀)

@[simp]
theorem inverse_one : inverse (1 : M₀) = 1 :=
  inverse_unit 1
#align ring.inverse_one Ring.inverse_one

@[simp]
theorem inverse_zero : inverse (0 : M₀) = 0 := by
  nontriviality
  exact inverse_non_unit _ not_is_unit_zero
#align ring.inverse_zero Ring.inverse_zero

variable {M₀}

end Ring

theorem IsUnit.ring_inverse {a : M₀} : IsUnit a → IsUnit (Ring.inverse a)
  | ⟨u, hu⟩ => hu ▸ ⟨u⁻¹, (Ring.inverse_unit u).symm⟩
#align is_unit.ring_inverse IsUnit.ring_inverse

@[simp]
theorem is_unit_ring_inverse {a : M₀} : IsUnit (Ring.inverse a) ↔ IsUnit a :=
  ⟨fun h => by
    cases subsingleton_or_nontrivial M₀
    · convert h
      
    · contrapose h
      rw [Ring.inverse_non_unit _ h]
      exact not_is_unit_zero
      ,
    IsUnit.ring_inverse⟩
#align is_unit_ring_inverse is_unit_ring_inverse

namespace Units

variable [GroupWithZero G₀]

variable {a b : G₀}

/-- Embed a non-zero element of a `group_with_zero` into the unit group.
  By combining this function with the operations on units,
  or the `/ₚ` operation, it is possible to write a division
  as a partial function with three arguments. -/
def mk0 (a : G₀) (ha : a ≠ 0) : G₀ˣ :=
  ⟨a, a⁻¹, mul_inv_cancel ha, inv_mul_cancel ha⟩
#align units.mk0 Units.mk0

@[simp]
theorem mk0_one (h := one_ne_zero) : mk0 (1 : G₀) h = 1 := by
  ext
  rfl
#align units.mk0_one Units.mk0_one

@[simp]
theorem coe_mk0 {a : G₀} (h : a ≠ 0) : (mk0 a h : G₀) = a :=
  rfl
#align units.coe_mk0 Units.coe_mk0

@[simp]
theorem mk0_coe (u : G₀ˣ) (h : (u : G₀) ≠ 0) : mk0 (u : G₀) h = u :=
  Units.ext rfl
#align units.mk0_coe Units.mk0_coe

@[simp]
theorem mul_inv' (u : G₀ˣ) : (u : G₀) * u⁻¹ = 1 :=
  mul_inv_cancel u.NeZero
#align units.mul_inv' Units.mul_inv'

@[simp]
theorem inv_mul' (u : G₀ˣ) : (u⁻¹ : G₀) * u = 1 :=
  inv_mul_cancel u.NeZero
#align units.inv_mul' Units.inv_mul'

@[simp]
theorem mk0_inj {a b : G₀} (ha : a ≠ 0) (hb : b ≠ 0) : Units.mk0 a ha = Units.mk0 b hb ↔ a = b :=
  ⟨fun h => by injection h, fun h => Units.ext h⟩
#align units.mk0_inj Units.mk0_inj

/-- In a group with zero, an existential over a unit can be rewritten in terms of `units.mk0`. -/
theorem exists0 {p : G₀ˣ → Prop} : (∃ g : G₀ˣ, p g) ↔ ∃ (g : G₀)(hg : g ≠ 0), p (Units.mk0 g hg) :=
  ⟨fun ⟨g, pg⟩ => ⟨g, g.NeZero, (g.mk0_coe g.NeZero).symm ▸ pg⟩, fun ⟨g, hg, pg⟩ => ⟨Units.mk0 g hg, pg⟩⟩
#align units.exists0 Units.exists0

/-- An alternative version of `units.exists0`. This one is useful if Lean cannot
figure out `p` when using `units.exists0` from right to left. -/
theorem exists0' {p : ∀ g : G₀, g ≠ 0 → Prop} : (∃ (g : G₀)(hg : g ≠ 0), p g hg) ↔ ∃ g : G₀ˣ, p g g.NeZero :=
  Iff.trans (by simp_rw [coe_mk0]) exists0.symm
#align units.exists0' Units.exists0'

@[simp]
theorem exists_iff_ne_zero {x : G₀} : (∃ u : G₀ˣ, ↑u = x) ↔ x ≠ 0 := by simp [exists0]
#align units.exists_iff_ne_zero Units.exists_iff_ne_zero

theorem _root_.group_with_zero.eq_zero_or_unit (a : G₀) : a = 0 ∨ ∃ u : G₀ˣ, a = u := by
  by_cases h : a = 0
  · left
    exact h
    
  · right
    simpa only [eq_comm] using units.exists_iff_ne_zero.mpr h
    
#align units._root_.group_with_zero.eq_zero_or_unit units._root_.group_with_zero.eq_zero_or_unit

end Units

section GroupWithZero

variable [GroupWithZero G₀] {a b c : G₀}

theorem IsUnit.mk0 (x : G₀) (hx : x ≠ 0) : IsUnit x :=
  (Units.mk0 x hx).IsUnit
#align is_unit.mk0 IsUnit.mk0

theorem is_unit_iff_ne_zero : IsUnit a ↔ a ≠ 0 :=
  Units.exists_iff_ne_zero
#align is_unit_iff_ne_zero is_unit_iff_ne_zero

alias is_unit_iff_ne_zero ↔ _ Ne.is_unit

attribute [protected] Ne.is_unit

-- see Note [lower instance priority]
instance (priority := 10) GroupWithZero.no_zero_divisors : NoZeroDivisors G₀ :=
  { (‹_› : GroupWithZero G₀) with
    eq_zero_or_eq_zero_of_mul_eq_zero := fun a b h => by
      contrapose! h
      exact (Units.mk0 a h.1 * Units.mk0 b h.2).NeZero }
#align group_with_zero.no_zero_divisors GroupWithZero.no_zero_divisors

-- see Note [lower instance priority]
instance (priority := 10) GroupWithZero.cancelMonoidWithZero : CancelMonoidWithZero G₀ :=
  { (‹_› : GroupWithZero G₀) with
    mul_left_cancel_of_ne_zero := fun x y z hx h => by rw [← inv_mul_cancel_left₀ hx y, h, inv_mul_cancel_left₀ hx z],
    mul_right_cancel_of_ne_zero := fun x y z hy h => by
      rw [← mul_inv_cancel_right₀ hy x, h, mul_inv_cancel_right₀ hy z] }
#align group_with_zero.cancel_monoid_with_zero GroupWithZero.cancelMonoidWithZero

-- Can't be put next to the other `mk0` lemmas because it depends on the
-- `no_zero_divisors` instance, which depends on `mk0`.
@[simp]
theorem Units.mk0_mul (x y : G₀) (hxy) :
    Units.mk0 (x * y) hxy = Units.mk0 x (mul_ne_zero_iff.mp hxy).1 * Units.mk0 y (mul_ne_zero_iff.mp hxy).2 := by
  ext
  rfl
#align units.mk0_mul Units.mk0_mul

theorem div_ne_zero (ha : a ≠ 0) (hb : b ≠ 0) : a / b ≠ 0 := by
  rw [div_eq_mul_inv]
  exact mul_ne_zero ha (inv_ne_zero hb)
#align div_ne_zero div_ne_zero

@[simp]
theorem div_eq_zero_iff : a / b = 0 ↔ a = 0 ∨ b = 0 := by simp [div_eq_mul_inv]
#align div_eq_zero_iff div_eq_zero_iff

theorem div_ne_zero_iff : a / b ≠ 0 ↔ a ≠ 0 ∧ b ≠ 0 :=
  div_eq_zero_iff.Not.trans not_or
#align div_ne_zero_iff div_ne_zero_iff

theorem Ring.inverse_eq_inv (a : G₀) : Ring.inverse a = a⁻¹ := by
  obtain rfl | ha := eq_or_ne a 0
  · simp
    
  · exact Ring.inverse_unit (Units.mk0 a ha)
    
#align ring.inverse_eq_inv Ring.inverse_eq_inv

@[simp]
theorem Ring.inverse_eq_inv' : (Ring.inverse : G₀ → G₀) = Inv.inv :=
  funext Ring.inverse_eq_inv
#align ring.inverse_eq_inv' Ring.inverse_eq_inv'

end GroupWithZero

section CommGroupWithZero

-- comm
variable [CommGroupWithZero G₀] {a b c d : G₀}

-- see Note [lower instance priority]
instance (priority := 10) CommGroupWithZero.cancelCommMonoidWithZero : CancelCommMonoidWithZero G₀ :=
  { GroupWithZero.cancelMonoidWithZero, CommGroupWithZero.toCommMonoidWithZero G₀ with }
#align comm_group_with_zero.cancel_comm_monoid_with_zero CommGroupWithZero.cancelCommMonoidWithZero

-- See note [lower instance priority]
instance (priority := 100) CommGroupWithZero.toDivisionCommMonoid : DivisionCommMonoid G₀ :=
  { ‹CommGroupWithZero G₀›, GroupWithZero.toDivisionMonoid with }
#align comm_group_with_zero.to_division_comm_monoid CommGroupWithZero.toDivisionCommMonoid

end CommGroupWithZero

section NoncomputableDefs

open Classical

variable {M : Type _} [Nontrivial M]

/-- Constructs a `group_with_zero` structure on a `monoid_with_zero`
  consisting only of units and 0. -/
noncomputable def groupWithZeroOfIsUnitOrEqZero [hM : MonoidWithZero M] (h : ∀ a : M, IsUnit a ∨ a = 0) :
    GroupWithZero M :=
  { hM with inv := fun a => if h0 : a = 0 then 0 else ↑((h a).resolve_right h0).Unit⁻¹, inv_zero := dif_pos rfl,
    mul_inv_cancel := fun a h0 => by
      change (a * if h0 : a = 0 then 0 else ↑((h a).resolve_right h0).Unit⁻¹) = 1
      rw [dif_neg h0, Units.mul_inv_eq_iff_eq_mul, one_mul, IsUnit.unit_spec],
    exists_pair_ne := Nontrivial.exists_pair_ne }
#align group_with_zero_of_is_unit_or_eq_zero groupWithZeroOfIsUnitOrEqZero

/-- Constructs a `comm_group_with_zero` structure on a `comm_monoid_with_zero`
  consisting only of units and 0. -/
noncomputable def commGroupWithZeroOfIsUnitOrEqZero [hM : CommMonoidWithZero M] (h : ∀ a : M, IsUnit a ∨ a = 0) :
    CommGroupWithZero M :=
  { groupWithZeroOfIsUnitOrEqZero h, hM with }
#align comm_group_with_zero_of_is_unit_or_eq_zero commGroupWithZeroOfIsUnitOrEqZero

end NoncomputableDefs

/- ./././Mathport/Syntax/Translate/Command.lean:719:14: unsupported user command assert_not_exists -/
-- Guard against import creep
