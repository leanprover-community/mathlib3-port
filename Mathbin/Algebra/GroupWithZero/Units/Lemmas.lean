/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin
-/
import Algebra.GroupWithZero.Commute
import Algebra.Group.Units.Hom
import Algebra.Group.Action.Units

#align_import algebra.group_with_zero.units.lemmas from "leanprover-community/mathlib"@"dc6c365e751e34d100e80fe6e314c3c3e0fd2988"

/-!
# Further lemmas about units in a `monoid_with_zero` or a `group_with_zero`.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

-/


variable {α M₀ G₀ M₀' G₀' F F' : Type _}

variable [MonoidWithZero M₀]

section GroupWithZero

variable [GroupWithZero G₀] {a b c : G₀}

#print div_self /-
@[simp]
theorem div_self (h : a ≠ 0) : a / a = 1 :=
  h.IsUnit.div_self
#align div_self div_self
-/

#print eq_mul_inv_iff_mul_eq₀ /-
theorem eq_mul_inv_iff_mul_eq₀ (hc : c ≠ 0) : a = b * c⁻¹ ↔ a * c = b :=
  hc.IsUnit.eq_mul_inv_iff_mul_eq
#align eq_mul_inv_iff_mul_eq₀ eq_mul_inv_iff_mul_eq₀
-/

#print eq_inv_mul_iff_mul_eq₀ /-
theorem eq_inv_mul_iff_mul_eq₀ (hb : b ≠ 0) : a = b⁻¹ * c ↔ b * a = c :=
  hb.IsUnit.eq_inv_mul_iff_mul_eq
#align eq_inv_mul_iff_mul_eq₀ eq_inv_mul_iff_mul_eq₀
-/

#print inv_mul_eq_iff_eq_mul₀ /-
theorem inv_mul_eq_iff_eq_mul₀ (ha : a ≠ 0) : a⁻¹ * b = c ↔ b = a * c :=
  ha.IsUnit.inv_mul_eq_iff_eq_mul
#align inv_mul_eq_iff_eq_mul₀ inv_mul_eq_iff_eq_mul₀
-/

#print mul_inv_eq_iff_eq_mul₀ /-
theorem mul_inv_eq_iff_eq_mul₀ (hb : b ≠ 0) : a * b⁻¹ = c ↔ a = c * b :=
  hb.IsUnit.mul_inv_eq_iff_eq_mul
#align mul_inv_eq_iff_eq_mul₀ mul_inv_eq_iff_eq_mul₀
-/

#print mul_inv_eq_one₀ /-
theorem mul_inv_eq_one₀ (hb : b ≠ 0) : a * b⁻¹ = 1 ↔ a = b :=
  hb.IsUnit.mul_inv_eq_one
#align mul_inv_eq_one₀ mul_inv_eq_one₀
-/

#print inv_mul_eq_one₀ /-
theorem inv_mul_eq_one₀ (ha : a ≠ 0) : a⁻¹ * b = 1 ↔ a = b :=
  ha.IsUnit.inv_mul_eq_one
#align inv_mul_eq_one₀ inv_mul_eq_one₀
-/

#print mul_eq_one_iff_eq_inv₀ /-
theorem mul_eq_one_iff_eq_inv₀ (hb : b ≠ 0) : a * b = 1 ↔ a = b⁻¹ :=
  hb.IsUnit.mul_eq_one_iff_eq_inv
#align mul_eq_one_iff_eq_inv₀ mul_eq_one_iff_eq_inv₀
-/

#print mul_eq_one_iff_inv_eq₀ /-
theorem mul_eq_one_iff_inv_eq₀ (ha : a ≠ 0) : a * b = 1 ↔ a⁻¹ = b :=
  ha.IsUnit.mul_eq_one_iff_inv_eq
#align mul_eq_one_iff_inv_eq₀ mul_eq_one_iff_inv_eq₀
-/

#print div_mul_cancel₀ /-
@[simp]
theorem div_mul_cancel₀ (a : G₀) (h : b ≠ 0) : a / b * b = a :=
  h.IsUnit.div_mul_cancelₓ _
#align div_mul_cancel div_mul_cancel₀
-/

#print mul_div_cancel_right₀ /-
@[simp]
theorem mul_div_cancel_right₀ (a : G₀) (h : b ≠ 0) : a * b / b = a :=
  h.IsUnit.mul_div_cancel _
#align mul_div_cancel mul_div_cancel_right₀
-/

#print mul_one_div_cancel /-
theorem mul_one_div_cancel (h : a ≠ 0) : a * (1 / a) = 1 :=
  h.IsUnit.mul_one_div_cancel
#align mul_one_div_cancel mul_one_div_cancel
-/

#print one_div_mul_cancel /-
theorem one_div_mul_cancel (h : a ≠ 0) : 1 / a * a = 1 :=
  h.IsUnit.one_div_mul_cancel
#align one_div_mul_cancel one_div_mul_cancel
-/

#print div_left_inj' /-
theorem div_left_inj' (hc : c ≠ 0) : a / c = b / c ↔ a = b :=
  hc.IsUnit.div_left_inj
#align div_left_inj' div_left_inj'
-/

#print div_eq_iff /-
@[field_simps]
theorem div_eq_iff (hb : b ≠ 0) : a / b = c ↔ a = c * b :=
  hb.IsUnit.div_eq_iff
#align div_eq_iff div_eq_iff
-/

#print eq_div_iff /-
@[field_simps]
theorem eq_div_iff (hb : b ≠ 0) : c = a / b ↔ c * b = a :=
  hb.IsUnit.eq_div_iff
#align eq_div_iff eq_div_iff
-/

#print div_eq_iff_mul_eq /-
theorem div_eq_iff_mul_eq (hb : b ≠ 0) : a / b = c ↔ c * b = a :=
  hb.IsUnit.div_eq_iff.trans eq_comm
#align div_eq_iff_mul_eq div_eq_iff_mul_eq
-/

#print eq_div_iff_mul_eq /-
theorem eq_div_iff_mul_eq (hc : c ≠ 0) : a = b / c ↔ a * c = b :=
  hc.IsUnit.eq_div_iff
#align eq_div_iff_mul_eq eq_div_iff_mul_eq
-/

#print div_eq_of_eq_mul /-
theorem div_eq_of_eq_mul (hb : b ≠ 0) : a = c * b → a / b = c :=
  hb.IsUnit.div_eq_of_eq_mul
#align div_eq_of_eq_mul div_eq_of_eq_mul
-/

#print eq_div_of_mul_eq /-
theorem eq_div_of_mul_eq (hc : c ≠ 0) : a * c = b → a = b / c :=
  hc.IsUnit.eq_div_of_mul_eq
#align eq_div_of_mul_eq eq_div_of_mul_eq
-/

#print div_eq_one_iff_eq /-
theorem div_eq_one_iff_eq (hb : b ≠ 0) : a / b = 1 ↔ a = b :=
  hb.IsUnit.div_eq_one_iff_eq
#align div_eq_one_iff_eq div_eq_one_iff_eq
-/

#print div_mul_left /-
theorem div_mul_left (hb : b ≠ 0) : b / (a * b) = 1 / a :=
  hb.IsUnit.div_mul_left
#align div_mul_left div_mul_left
-/

#print mul_div_mul_right /-
theorem mul_div_mul_right (a b : G₀) (hc : c ≠ 0) : a * c / (b * c) = a / b :=
  hc.IsUnit.mul_div_mul_right _ _
#align mul_div_mul_right mul_div_mul_right
-/

#print mul_mul_div /-
theorem mul_mul_div (a : G₀) (hb : b ≠ 0) : a = a * b * (1 / b) :=
  (hb.IsUnit.mul_mul_div _).symm
#align mul_mul_div mul_mul_div
-/

#print div_div_div_cancel_right /-
theorem div_div_div_cancel_right (a : G₀) (hc : c ≠ 0) : a / c / (b / c) = a / b := by
  rw [div_div_eq_mul_div, div_mul_cancel₀ _ hc]
#align div_div_div_cancel_right div_div_div_cancel_right
-/

#print div_mul_div_cancel /-
theorem div_mul_div_cancel (a : G₀) (hc : c ≠ 0) : a / c * (c / b) = a / b := by
  rw [← mul_div_assoc, div_mul_cancel₀ _ hc]
#align div_mul_div_cancel div_mul_div_cancel
-/

#print div_mul_cancel_of_imp /-
theorem div_mul_cancel_of_imp {a b : G₀} (h : b = 0 → a = 0) : a / b * b = a :=
  by_cases (fun hb : b = 0 => by simp [*]) (div_mul_cancel₀ a)
#align div_mul_cancel_of_imp div_mul_cancel_of_imp
-/

#print mul_div_cancel_of_imp /-
theorem mul_div_cancel_of_imp {a b : G₀} (h : b = 0 → a = 0) : a * b / b = a :=
  by_cases (fun hb : b = 0 => by simp [*]) (mul_div_cancel_right₀ a)
#align mul_div_cancel_of_imp mul_div_cancel_of_imp
-/

#print divp_mk0 /-
@[simp]
theorem divp_mk0 (a : G₀) {b : G₀} (hb : b ≠ 0) : a /ₚ Units.mk0 b hb = a / b :=
  divp_eq_div _ _
#align divp_mk0 divp_mk0
-/

end GroupWithZero

section CommGroupWithZero

-- comm
variable [CommGroupWithZero G₀] {a b c d : G₀}

#print div_mul_right /-
theorem div_mul_right (b : G₀) (ha : a ≠ 0) : a / (a * b) = 1 / b :=
  ha.IsUnit.div_mul_right _
#align div_mul_right div_mul_right
-/

#print mul_div_cancel_left_of_imp /-
theorem mul_div_cancel_left_of_imp {a b : G₀} (h : a = 0 → b = 0) : a * b / a = b := by
  rw [mul_comm, mul_div_cancel_of_imp h]
#align mul_div_cancel_left_of_imp mul_div_cancel_left_of_imp
-/

#print mul_div_cancel_left₀ /-
theorem mul_div_cancel_left₀ (b : G₀) (ha : a ≠ 0) : a * b / a = b :=
  ha.IsUnit.mul_div_cancel_left _
#align mul_div_cancel_left mul_div_cancel_left₀
-/

#print mul_div_cancel_of_imp' /-
theorem mul_div_cancel_of_imp' {a b : G₀} (h : b = 0 → a = 0) : b * (a / b) = a := by
  rw [mul_comm, div_mul_cancel_of_imp h]
#align mul_div_cancel_of_imp' mul_div_cancel_of_imp'
-/

#print mul_div_cancel₀ /-
theorem mul_div_cancel₀ (a : G₀) (hb : b ≠ 0) : b * (a / b) = a :=
  hb.IsUnit.mul_div_cancel'ₓ _
#align mul_div_cancel' mul_div_cancel₀
-/

#print mul_div_mul_left /-
theorem mul_div_mul_left (a b : G₀) (hc : c ≠ 0) : c * a / (c * b) = a / b :=
  hc.IsUnit.mul_div_mul_left _ _
#align mul_div_mul_left mul_div_mul_left
-/

#print mul_eq_mul_of_div_eq_div /-
theorem mul_eq_mul_of_div_eq_div (a : G₀) {b : G₀} (c : G₀) {d : G₀} (hb : b ≠ 0) (hd : d ≠ 0)
    (h : a / b = c / d) : a * d = c * b := by
  rw [← mul_one a, ← div_self hb, ← mul_comm_div, h, div_mul_eq_mul_div, div_mul_cancel₀ _ hd]
#align mul_eq_mul_of_div_eq_div mul_eq_mul_of_div_eq_div
-/

#print div_eq_div_iff /-
@[field_simps]
theorem div_eq_div_iff (hb : b ≠ 0) (hd : d ≠ 0) : a / b = c / d ↔ a * d = c * b :=
  hb.IsUnit.div_eq_div_iff hd.IsUnit
#align div_eq_div_iff div_eq_div_iff
-/

#print div_div_cancel' /-
theorem div_div_cancel' (ha : a ≠ 0) : a / (a / b) = b :=
  ha.IsUnit.div_div_cancel
#align div_div_cancel' div_div_cancel'
-/

#print div_div_cancel_left' /-
theorem div_div_cancel_left' (ha : a ≠ 0) : a / b / a = b⁻¹ :=
  ha.IsUnit.div_div_cancel_left
#align div_div_cancel_left' div_div_cancel_left'
-/

#print div_helper /-
theorem div_helper (b : G₀) (h : a ≠ 0) : 1 / (a * b) * a = 1 / b := by
  rw [div_mul_eq_mul_div, one_mul, div_mul_right _ h]
#align div_helper div_helper
-/

end CommGroupWithZero

section MonoidWithZero

variable [GroupWithZero G₀] [Nontrivial M₀] [MonoidWithZero M₀'] [MonoidWithZeroHomClass F G₀ M₀]
  [MonoidWithZeroHomClass F' G₀ M₀'] (f : F) {a : G₀}

#print map_ne_zero /-
theorem map_ne_zero : f a ≠ 0 ↔ a ≠ 0 :=
  ⟨fun hfa ha => hfa <| ha.symm ▸ map_zero f, fun ha => ((IsUnit.mk0 a ha).map f).NeZero⟩
#align map_ne_zero map_ne_zero
-/

#print map_eq_zero /-
@[simp]
theorem map_eq_zero : f a = 0 ↔ a = 0 :=
  not_iff_not.1 (map_ne_zero f)
#align map_eq_zero map_eq_zero
-/

#print eq_on_inv₀ /-
theorem eq_on_inv₀ (f g : F') (h : f a = g a) : f a⁻¹ = g a⁻¹ :=
  by
  rcases eq_or_ne a 0 with (rfl | ha)
  · rw [inv_zero, map_zero, map_zero]
  · exact (IsUnit.mk0 a ha).eq_on_inv f g h
#align eq_on_inv₀ eq_on_inv₀
-/

end MonoidWithZero

section GroupWithZero

variable [GroupWithZero G₀] [GroupWithZero G₀'] [MonoidWithZeroHomClass F G₀ G₀'] (f : F) (a b : G₀)

#print map_inv₀ /-
/-- A monoid homomorphism between groups with zeros sending `0` to `0` sends `a⁻¹` to `(f a)⁻¹`. -/
@[simp]
theorem map_inv₀ : f a⁻¹ = (f a)⁻¹ := by
  by_cases h : a = 0; · simp [h]
  apply eq_inv_of_mul_eq_one_left
  rw [← map_mul, inv_mul_cancel h, map_one]
#align map_inv₀ map_inv₀
-/

#print map_div₀ /-
@[simp]
theorem map_div₀ : f (a / b) = f a / f b :=
  map_div' f (map_inv₀ f) a b
#align map_div₀ map_div₀
-/

end GroupWithZero

#print MonoidWithZero.inverse /-
/-- We define the inverse as a `monoid_with_zero_hom` by extending the inverse map by zero
on non-units. -/
noncomputable def MonoidWithZero.inverse {M : Type _} [CommMonoidWithZero M] : M →*₀ M
    where
  toFun := Ring.inverse
  map_zero' := Ring.inverse_zero _
  map_one' := Ring.inverse_one _
  map_mul' x y := (Ring.mul_inverse_rev x y).trans (mul_comm _ _)
#align monoid_with_zero.inverse MonoidWithZero.inverse
-/

#print MonoidWithZero.coe_inverse /-
@[simp]
theorem MonoidWithZero.coe_inverse {M : Type _} [CommMonoidWithZero M] :
    (MonoidWithZero.inverse : M → M) = Ring.inverse :=
  rfl
#align monoid_with_zero.coe_inverse MonoidWithZero.coe_inverse
-/

#print MonoidWithZero.inverse_apply /-
@[simp]
theorem MonoidWithZero.inverse_apply {M : Type _} [CommMonoidWithZero M] (a : M) :
    MonoidWithZero.inverse a = Ring.inverse a :=
  rfl
#align monoid_with_zero.inverse_apply MonoidWithZero.inverse_apply
-/

#print invMonoidWithZeroHom /-
/-- Inversion on a commutative group with zero, considered as a monoid with zero homomorphism. -/
def invMonoidWithZeroHom {G₀ : Type _} [CommGroupWithZero G₀] : G₀ →*₀ G₀ :=
  { invMonoidHom with map_zero' := inv_zero }
#align inv_monoid_with_zero_hom invMonoidWithZeroHom
-/

namespace Units

variable [GroupWithZero G₀]

variable {a b : G₀}

#print Units.smul_mk0 /-
@[simp]
theorem smul_mk0 {α : Type _} [SMul G₀ α] {g : G₀} (hg : g ≠ 0) (a : α) : mk0 g hg • a = g • a :=
  rfl
#align units.smul_mk0 Units.smul_mk0
-/

end Units

