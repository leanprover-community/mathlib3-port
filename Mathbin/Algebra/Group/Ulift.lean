/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import Mathbin.Data.Int.Cast.Defs
import Mathbin.Algebra.Hom.Equiv.Basic
import Mathbin.Algebra.GroupWithZero.Basic

/-!
# `ulift` instances for groups and monoids

This file defines instances for group, monoid, semigroup and related structures on `ulift` types.

(Recall `ulift α` is just a "copy" of a type `α` in a higher universe.)

We use `tactic.pi_instance_derive_field`, even though it wasn't intended for this purpose,
which seems to work fine.

We also provide `ulift.mul_equiv : ulift R ≃* R` (and its additive analogue).
-/


universe u v

variable {α : Type u} {β : Type _} {x y : ULift.{v} α}

namespace ULift

@[to_additive]
instance hasOne [One α] : One (ULift α) :=
  ⟨⟨1⟩⟩

@[simp, to_additive]
theorem one_down [One α] : (1 : ULift α).down = 1 :=
  rfl

@[to_additive]
instance hasMul [Mul α] : Mul (ULift α) :=
  ⟨fun f g => ⟨f.down * g.down⟩⟩

@[simp, to_additive]
theorem mul_down [Mul α] : (x * y).down = x.down * y.down :=
  rfl

@[to_additive]
instance hasDiv [Div α] : Div (ULift α) :=
  ⟨fun f g => ⟨f.down / g.down⟩⟩

@[simp, to_additive]
theorem div_down [Div α] : (x / y).down = x.down / y.down :=
  rfl

@[to_additive]
instance hasInv [Inv α] : Inv (ULift α) :=
  ⟨fun f => ⟨f.down⁻¹⟩⟩

@[simp, to_additive]
theorem inv_down [Inv α] : x⁻¹.down = x.down⁻¹ :=
  rfl

@[to_additive]
instance hasSmul [HasSmul α β] : HasSmul α (ULift β) :=
  ⟨fun n x => up (n • x.down)⟩

@[simp, to_additive]
theorem smul_down [HasSmul α β] (a : α) (b : ULift.{v} β) : (a • b).down = a • b.down :=
  rfl

@[to_additive HasSmul, to_additive_reorder 1]
instance hasPow [Pow α β] : Pow (ULift α) β :=
  ⟨fun x n => up (x.down ^ n)⟩

@[simp, to_additive smul_down, to_additive_reorder 1]
theorem pow_down [Pow α β] (a : ULift.{v} α) (b : β) : (a ^ b).down = a.down ^ b :=
  rfl

/-- The multiplicative equivalence between `ulift α` and `α`.
-/
@[to_additive "The additive equivalence between `ulift α` and `α`."]
def _root_.mul_equiv.ulift [Mul α] : ULift α ≃* α :=
  { Equiv.ulift with map_mul' := fun x y => rfl }

@[to_additive]
instance semigroup [Semigroup α] : Semigroup (ULift α) :=
  (MulEquiv.ulift.Injective.Semigroup _) fun x y => rfl

@[to_additive]
instance commSemigroup [CommSemigroup α] : CommSemigroup (ULift α) :=
  (Equiv.ulift.Injective.CommSemigroup _) fun x y => rfl

@[to_additive]
instance mulOneClass [MulOneClass α] : MulOneClass (ULift α) :=
  (Equiv.ulift.Injective.MulOneClass _ rfl) fun x y => rfl

instance mulZeroOneClass [MulZeroOneClass α] : MulZeroOneClass (ULift α) :=
  (Equiv.ulift.Injective.MulZeroOneClass _ rfl rfl) fun x y => rfl

@[to_additive]
instance monoid [Monoid α] : Monoid (ULift α) :=
  Equiv.ulift.Injective.Monoid _ rfl (fun _ _ => rfl) fun _ _ => rfl

instance addMonoidWithOne [AddMonoidWithOne α] : AddMonoidWithOne (ULift α) :=
  { ULift.hasOne, ULift.addMonoid with natCast := fun n => ⟨n⟩, nat_cast_zero := congr_arg ULift.up Nat.cast_zero,
    nat_cast_succ := fun n => congr_arg ULift.up (Nat.cast_succ _) }

@[simp]
theorem nat_cast_down [AddMonoidWithOne α] (n : ℕ) : (n : ULift α).down = n :=
  rfl

@[to_additive]
instance commMonoid [CommMonoid α] : CommMonoid (ULift α) :=
  Equiv.ulift.Injective.CommMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl

instance monoidWithZero [MonoidWithZero α] : MonoidWithZero (ULift α) :=
  Equiv.ulift.Injective.MonoidWithZero _ rfl rfl (fun _ _ => rfl) fun _ _ => rfl

instance commMonoidWithZero [CommMonoidWithZero α] : CommMonoidWithZero (ULift α) :=
  Equiv.ulift.Injective.CommMonoidWithZero _ rfl rfl (fun _ _ => rfl) fun _ _ => rfl

@[to_additive]
instance divInvMonoid [DivInvMonoid α] : DivInvMonoid (ULift α) :=
  Equiv.ulift.Injective.DivInvMonoid _ rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) fun _ _ =>
    rfl

@[to_additive]
instance group [Group α] : Group (ULift α) :=
  Equiv.ulift.Injective.Group _ rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) fun _ _ => rfl

instance addGroupWithOne [AddGroupWithOne α] : AddGroupWithOne (ULift α) :=
  { ULift.addMonoidWithOne, ULift.addGroup with intCast := fun n => ⟨n⟩,
    int_cast_of_nat := fun n => congr_arg ULift.up (Int.cast_of_nat _),
    int_cast_neg_succ_of_nat := fun n => congr_arg ULift.up (Int.cast_negSucc _) }

@[simp]
theorem int_cast_down [AddGroupWithOne α] (n : ℤ) : (n : ULift α).down = n :=
  rfl

@[to_additive]
instance commGroup [CommGroup α] : CommGroup (ULift α) :=
  Equiv.ulift.Injective.CommGroup _ rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) fun _ _ => rfl

instance groupWithZero [GroupWithZero α] : GroupWithZero (ULift α) :=
  Equiv.ulift.Injective.GroupWithZero _ rfl rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    fun _ _ => rfl

instance commGroupWithZero [CommGroupWithZero α] : CommGroupWithZero (ULift α) :=
  Equiv.ulift.Injective.CommGroupWithZero _ rfl rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    fun _ _ => rfl

@[to_additive AddLeftCancelSemigroup]
instance leftCancelSemigroup [LeftCancelSemigroup α] : LeftCancelSemigroup (ULift α) :=
  Equiv.ulift.Injective.LeftCancelSemigroup _ fun _ _ => rfl

@[to_additive AddRightCancelSemigroup]
instance rightCancelSemigroup [RightCancelSemigroup α] : RightCancelSemigroup (ULift α) :=
  Equiv.ulift.Injective.RightCancelSemigroup _ fun _ _ => rfl

@[to_additive AddLeftCancelMonoid]
instance leftCancelMonoid [LeftCancelMonoid α] : LeftCancelMonoid (ULift α) :=
  Equiv.ulift.Injective.LeftCancelMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl

@[to_additive AddRightCancelMonoid]
instance rightCancelMonoid [RightCancelMonoid α] : RightCancelMonoid (ULift α) :=
  Equiv.ulift.Injective.RightCancelMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl

@[to_additive AddCancelMonoid]
instance cancelMonoid [CancelMonoid α] : CancelMonoid (ULift α) :=
  Equiv.ulift.Injective.CancelMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl

@[to_additive AddCancelMonoid]
instance cancelCommMonoid [CancelCommMonoid α] : CancelCommMonoid (ULift α) :=
  Equiv.ulift.Injective.CancelCommMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl

instance nontrivial [Nontrivial α] : Nontrivial (ULift α) :=
  Equiv.ulift.symm.Injective.Nontrivial

-- TODO we don't do `ordered_cancel_comm_monoid` or `ordered_comm_group`
-- We'd need to add instances for `ulift` in `order.basic`.
end ULift

