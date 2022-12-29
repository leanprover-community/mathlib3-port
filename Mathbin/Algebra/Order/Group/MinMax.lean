/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro, Johannes Hölzl

! This file was ported from Lean 3 source module algebra.order.group.min_max
! leanprover-community/mathlib commit 422e70f7ce183d2900c586a8cda8381e788a0c62
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Group.Abs
import Mathbin.Algebra.Order.Monoid.MinMax

/-!
# `min` and `max` in linearly ordered groups.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> https://github.com/leanprover-community/mathlib4/pull/933
> Any changes to this file require a corresponding PR to mathlib4.
-/


section

variable {α : Type _} [Group α] [LinearOrder α] [CovariantClass α α (· * ·) (· ≤ ·)]

/- warning: max_one_div_max_inv_one_eq_self -> max_one_div_max_inv_one_eq_self is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Group.{u1} α] [_inst_2 : LinearOrder.{u1} α] [_inst_3 : CovariantClass.{u1, u1} α α (HMul.hMul.{u1, u1, u1} α α α (instHMul.{u1} α (MulOneClass.toHasMul.{u1} α (Monoid.toMulOneClass.{u1} α (DivInvMonoid.toMonoid.{u1} α (Group.toDivInvMonoid.{u1} α _inst_1)))))) (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_2))))))] (a : α), Eq.{succ u1} α (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α (Group.toDivInvMonoid.{u1} α _inst_1))) (LinearOrder.max.{u1} α _inst_2 a (OfNat.ofNat.{u1} α 1 (OfNat.mk.{u1} α 1 (One.one.{u1} α (MulOneClass.toHasOne.{u1} α (Monoid.toMulOneClass.{u1} α (DivInvMonoid.toMonoid.{u1} α (Group.toDivInvMonoid.{u1} α _inst_1)))))))) (LinearOrder.max.{u1} α _inst_2 (Inv.inv.{u1} α (DivInvMonoid.toHasInv.{u1} α (Group.toDivInvMonoid.{u1} α _inst_1)) a) (OfNat.ofNat.{u1} α 1 (OfNat.mk.{u1} α 1 (One.one.{u1} α (MulOneClass.toHasOne.{u1} α (Monoid.toMulOneClass.{u1} α (DivInvMonoid.toMonoid.{u1} α (Group.toDivInvMonoid.{u1} α _inst_1))))))))) a
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Group.{u1} α] [_inst_2 : LinearOrder.{u1} α] [_inst_3 : CovariantClass.{u1, u1} α α (fun (x._@.Mathlib.Algebra.Order.Group.MinMax._hyg.65 : α) (x._@.Mathlib.Algebra.Order.Group.MinMax._hyg.67 : α) => HMul.hMul.{u1, u1, u1} α α α (instHMul.{u1} α (MulOneClass.toMul.{u1} α (Monoid.toMulOneClass.{u1} α (DivInvMonoid.toMonoid.{u1} α (Group.toDivInvMonoid.{u1} α _inst_1))))) x._@.Mathlib.Algebra.Order.Group.MinMax._hyg.65 x._@.Mathlib.Algebra.Order.Group.MinMax._hyg.67) (fun (x._@.Mathlib.Algebra.Order.Group.MinMax._hyg.80 : α) (x._@.Mathlib.Algebra.Order.Group.MinMax._hyg.82 : α) => LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α _inst_2)))))) x._@.Mathlib.Algebra.Order.Group.MinMax._hyg.80 x._@.Mathlib.Algebra.Order.Group.MinMax._hyg.82)] (a : α), Eq.{succ u1} α (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toDiv.{u1} α (Group.toDivInvMonoid.{u1} α _inst_1))) (Max.max.{u1} α (LinearOrder.toMax.{u1} α _inst_2) a (OfNat.ofNat.{u1} α 1 (One.toOfNat1.{u1} α (InvOneClass.toOne.{u1} α (DivInvOneMonoid.toInvOneClass.{u1} α (DivisionMonoid.toDivInvOneMonoid.{u1} α (Group.toDivisionMonoid.{u1} α _inst_1))))))) (Max.max.{u1} α (LinearOrder.toMax.{u1} α _inst_2) (Inv.inv.{u1} α (InvOneClass.toInv.{u1} α (DivInvOneMonoid.toInvOneClass.{u1} α (DivisionMonoid.toDivInvOneMonoid.{u1} α (Group.toDivisionMonoid.{u1} α _inst_1)))) a) (OfNat.ofNat.{u1} α 1 (One.toOfNat1.{u1} α (InvOneClass.toOne.{u1} α (DivInvOneMonoid.toInvOneClass.{u1} α (DivisionMonoid.toDivInvOneMonoid.{u1} α (Group.toDivisionMonoid.{u1} α _inst_1)))))))) a
Case conversion may be inaccurate. Consider using '#align max_one_div_max_inv_one_eq_self max_one_div_max_inv_one_eq_selfₓ'. -/
@[simp, to_additive]
theorem max_one_div_max_inv_one_eq_self (a : α) : max a 1 / max a⁻¹ 1 = a := by
  rcases le_total a 1 with (h | h) <;> simp [h]
#align max_one_div_max_inv_one_eq_self max_one_div_max_inv_one_eq_self

alias max_zero_sub_max_neg_zero_eq_self ← max_zero_sub_eq_self

end

section LinearOrderedCommGroup

variable {α : Type _} [LinearOrderedCommGroup α] {a b c : α}

/- warning: min_inv_inv' -> min_inv_inv' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedCommGroup.{u1} α] (a : α) (b : α), Eq.{succ u1} α (LinearOrder.min.{u1} α (LinearOrderedCommGroup.toLinearOrder.{u1} α _inst_1) (Inv.inv.{u1} α (DivInvMonoid.toHasInv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1))))) a) (Inv.inv.{u1} α (DivInvMonoid.toHasInv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1))))) b)) (Inv.inv.{u1} α (DivInvMonoid.toHasInv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1))))) (LinearOrder.max.{u1} α (LinearOrderedCommGroup.toLinearOrder.{u1} α _inst_1) a b))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedCommGroup.{u1} α] (a : α) (b : α), Eq.{succ u1} α (Min.min.{u1} α (LinearOrderedCommGroup.toMin.{u1} α _inst_1) (Inv.inv.{u1} α (InvOneClass.toInv.{u1} α (DivInvOneMonoid.toInvOneClass.{u1} α (DivisionMonoid.toDivInvOneMonoid.{u1} α (DivisionCommMonoid.toDivisionMonoid.{u1} α (CommGroup.toDivisionCommMonoid.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1))))))) a) (Inv.inv.{u1} α (InvOneClass.toInv.{u1} α (DivInvOneMonoid.toInvOneClass.{u1} α (DivisionMonoid.toDivInvOneMonoid.{u1} α (DivisionCommMonoid.toDivisionMonoid.{u1} α (CommGroup.toDivisionCommMonoid.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1))))))) b)) (Inv.inv.{u1} α (InvOneClass.toInv.{u1} α (DivInvOneMonoid.toInvOneClass.{u1} α (DivisionMonoid.toDivInvOneMonoid.{u1} α (DivisionCommMonoid.toDivisionMonoid.{u1} α (CommGroup.toDivisionCommMonoid.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1))))))) (Max.max.{u1} α (LinearOrderedCommGroup.toMax.{u1} α _inst_1) a b))
Case conversion may be inaccurate. Consider using '#align min_inv_inv' min_inv_inv'ₓ'. -/
@[to_additive min_neg_neg]
theorem min_inv_inv' (a b : α) : min a⁻¹ b⁻¹ = (max a b)⁻¹ :=
  Eq.symm <| (@Monotone.map_max α αᵒᵈ _ _ Inv.inv a b) fun a b => inv_le_inv_iff.mpr
#align min_inv_inv' min_inv_inv'

/- warning: max_inv_inv' -> max_inv_inv' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedCommGroup.{u1} α] (a : α) (b : α), Eq.{succ u1} α (LinearOrder.max.{u1} α (LinearOrderedCommGroup.toLinearOrder.{u1} α _inst_1) (Inv.inv.{u1} α (DivInvMonoid.toHasInv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1))))) a) (Inv.inv.{u1} α (DivInvMonoid.toHasInv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1))))) b)) (Inv.inv.{u1} α (DivInvMonoid.toHasInv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1))))) (LinearOrder.min.{u1} α (LinearOrderedCommGroup.toLinearOrder.{u1} α _inst_1) a b))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedCommGroup.{u1} α] (a : α) (b : α), Eq.{succ u1} α (Max.max.{u1} α (LinearOrderedCommGroup.toMax.{u1} α _inst_1) (Inv.inv.{u1} α (InvOneClass.toInv.{u1} α (DivInvOneMonoid.toInvOneClass.{u1} α (DivisionMonoid.toDivInvOneMonoid.{u1} α (DivisionCommMonoid.toDivisionMonoid.{u1} α (CommGroup.toDivisionCommMonoid.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1))))))) a) (Inv.inv.{u1} α (InvOneClass.toInv.{u1} α (DivInvOneMonoid.toInvOneClass.{u1} α (DivisionMonoid.toDivInvOneMonoid.{u1} α (DivisionCommMonoid.toDivisionMonoid.{u1} α (CommGroup.toDivisionCommMonoid.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1))))))) b)) (Inv.inv.{u1} α (InvOneClass.toInv.{u1} α (DivInvOneMonoid.toInvOneClass.{u1} α (DivisionMonoid.toDivInvOneMonoid.{u1} α (DivisionCommMonoid.toDivisionMonoid.{u1} α (CommGroup.toDivisionCommMonoid.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1))))))) (Min.min.{u1} α (LinearOrderedCommGroup.toMin.{u1} α _inst_1) a b))
Case conversion may be inaccurate. Consider using '#align max_inv_inv' max_inv_inv'ₓ'. -/
@[to_additive max_neg_neg]
theorem max_inv_inv' (a b : α) : max a⁻¹ b⁻¹ = (min a b)⁻¹ :=
  Eq.symm <| (@Monotone.map_min α αᵒᵈ _ _ Inv.inv a b) fun a b => inv_le_inv_iff.mpr
#align max_inv_inv' max_inv_inv'

/- warning: min_div_div_right' -> min_div_div_right' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedCommGroup.{u1} α] (a : α) (b : α) (c : α), Eq.{succ u1} α (LinearOrder.min.{u1} α (LinearOrderedCommGroup.toLinearOrder.{u1} α _inst_1) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a c) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) b c)) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) (LinearOrder.min.{u1} α (LinearOrderedCommGroup.toLinearOrder.{u1} α _inst_1) a b) c)
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedCommGroup.{u1} α] (a : α) (b : α) (c : α), Eq.{succ u1} α (Min.min.{u1} α (LinearOrderedCommGroup.toMin.{u1} α _inst_1) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a c) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) b c)) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) (Min.min.{u1} α (LinearOrderedCommGroup.toMin.{u1} α _inst_1) a b) c)
Case conversion may be inaccurate. Consider using '#align min_div_div_right' min_div_div_right'ₓ'. -/
@[to_additive min_sub_sub_right]
theorem min_div_div_right' (a b c : α) : min (a / c) (b / c) = min a b / c := by
  simpa only [div_eq_mul_inv] using min_mul_mul_right a b c⁻¹
#align min_div_div_right' min_div_div_right'

/- warning: max_div_div_right' -> max_div_div_right' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedCommGroup.{u1} α] (a : α) (b : α) (c : α), Eq.{succ u1} α (LinearOrder.max.{u1} α (LinearOrderedCommGroup.toLinearOrder.{u1} α _inst_1) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a c) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) b c)) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) (LinearOrder.max.{u1} α (LinearOrderedCommGroup.toLinearOrder.{u1} α _inst_1) a b) c)
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedCommGroup.{u1} α] (a : α) (b : α) (c : α), Eq.{succ u1} α (Max.max.{u1} α (LinearOrderedCommGroup.toMax.{u1} α _inst_1) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a c) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) b c)) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) (Max.max.{u1} α (LinearOrderedCommGroup.toMax.{u1} α _inst_1) a b) c)
Case conversion may be inaccurate. Consider using '#align max_div_div_right' max_div_div_right'ₓ'. -/
@[to_additive max_sub_sub_right]
theorem max_div_div_right' (a b c : α) : max (a / c) (b / c) = max a b / c := by
  simpa only [div_eq_mul_inv] using max_mul_mul_right a b c⁻¹
#align max_div_div_right' max_div_div_right'

/- warning: min_div_div_left' -> min_div_div_left' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedCommGroup.{u1} α] (a : α) (b : α) (c : α), Eq.{succ u1} α (LinearOrder.min.{u1} α (LinearOrderedCommGroup.toLinearOrder.{u1} α _inst_1) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a b) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a c)) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a (LinearOrder.max.{u1} α (LinearOrderedCommGroup.toLinearOrder.{u1} α _inst_1) b c))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedCommGroup.{u1} α] (a : α) (b : α) (c : α), Eq.{succ u1} α (Min.min.{u1} α (LinearOrderedCommGroup.toMin.{u1} α _inst_1) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a b) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a c)) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a (Max.max.{u1} α (LinearOrderedCommGroup.toMax.{u1} α _inst_1) b c))
Case conversion may be inaccurate. Consider using '#align min_div_div_left' min_div_div_left'ₓ'. -/
@[to_additive min_sub_sub_left]
theorem min_div_div_left' (a b c : α) : min (a / b) (a / c) = a / max b c := by
  simp only [div_eq_mul_inv, min_mul_mul_left, min_inv_inv']
#align min_div_div_left' min_div_div_left'

/- warning: max_div_div_left' -> max_div_div_left' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedCommGroup.{u1} α] (a : α) (b : α) (c : α), Eq.{succ u1} α (LinearOrder.max.{u1} α (LinearOrderedCommGroup.toLinearOrder.{u1} α _inst_1) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a b) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a c)) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a (LinearOrder.min.{u1} α (LinearOrderedCommGroup.toLinearOrder.{u1} α _inst_1) b c))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedCommGroup.{u1} α] (a : α) (b : α) (c : α), Eq.{succ u1} α (Max.max.{u1} α (LinearOrderedCommGroup.toMax.{u1} α _inst_1) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a b) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a c)) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toDiv.{u1} α (Group.toDivInvMonoid.{u1} α (CommGroup.toGroup.{u1} α (OrderedCommGroup.toCommGroup.{u1} α (LinearOrderedCommGroup.toOrderedCommGroup.{u1} α _inst_1)))))) a (Min.min.{u1} α (LinearOrderedCommGroup.toMin.{u1} α _inst_1) b c))
Case conversion may be inaccurate. Consider using '#align max_div_div_left' max_div_div_left'ₓ'. -/
@[to_additive max_sub_sub_left]
theorem max_div_div_left' (a b c : α) : max (a / b) (a / c) = a / min b c := by
  simp only [div_eq_mul_inv, max_mul_mul_left, max_inv_inv']
#align max_div_div_left' max_div_div_left'

end LinearOrderedCommGroup

section LinearOrderedAddCommGroup

variable {α : Type _} [LinearOrderedAddCommGroup α] {a b c : α}

/- warning: max_sub_max_le_max -> max_sub_max_le_max is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedAddCommGroup.{u1} α] (a : α) (b : α) (c : α) (d : α), LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (OrderedAddCommGroup.toPartialOrder.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toHasSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) (LinearOrder.max.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1) a b) (LinearOrder.max.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1) c d)) (LinearOrder.max.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toHasSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) a c) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toHasSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) b d))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedAddCommGroup.{u1} α] (a : α) (b : α) (c : α) (d : α), LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (OrderedAddCommGroup.toPartialOrder.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) (Max.max.{u1} α (LinearOrderedAddCommGroup.toMax.{u1} α _inst_1) a b) (Max.max.{u1} α (LinearOrderedAddCommGroup.toMax.{u1} α _inst_1) c d)) (Max.max.{u1} α (LinearOrderedAddCommGroup.toMax.{u1} α _inst_1) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) a c) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) b d))
Case conversion may be inaccurate. Consider using '#align max_sub_max_le_max max_sub_max_le_maxₓ'. -/
theorem max_sub_max_le_max (a b c d : α) : max a b - max c d ≤ max (a - c) (b - d) :=
  by
  simp only [sub_le_iff_le_add, max_le_iff]; constructor
  calc
    a = a - c + c := (sub_add_cancel a c).symm
    _ ≤ max (a - c) (b - d) + max c d := add_le_add (le_max_left _ _) (le_max_left _ _)
    
  calc
    b = b - d + d := (sub_add_cancel b d).symm
    _ ≤ max (a - c) (b - d) + max c d := add_le_add (le_max_right _ _) (le_max_right _ _)
    
#align max_sub_max_le_max max_sub_max_le_max

/- warning: abs_max_sub_max_le_max -> abs_max_sub_max_le_max is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedAddCommGroup.{u1} α] (a : α) (b : α) (c : α) (d : α), LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (OrderedAddCommGroup.toPartialOrder.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (SubNegMonoid.toHasNeg.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (LinearOrder.toLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toHasSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) (LinearOrder.max.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1) a b) (LinearOrder.max.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1) c d))) (LinearOrder.max.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (SubNegMonoid.toHasNeg.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (LinearOrder.toLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toHasSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) a c)) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (SubNegMonoid.toHasNeg.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (LinearOrder.toLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toHasSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) b d)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedAddCommGroup.{u1} α] (a : α) (b : α) (c : α) (d : α), LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (OrderedAddCommGroup.toPartialOrder.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (NegZeroClass.toNeg.{u1} α (SubNegZeroMonoid.toNegZeroClass.{u1} α (SubtractionMonoid.toSubNegZeroMonoid.{u1} α (SubtractionCommMonoid.toSubtractionMonoid.{u1} α (AddCommGroup.toDivisionAddCommMonoid.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1)))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) (Max.max.{u1} α (LinearOrderedAddCommGroup.toMax.{u1} α _inst_1) a b) (Max.max.{u1} α (LinearOrderedAddCommGroup.toMax.{u1} α _inst_1) c d))) (Max.max.{u1} α (LinearOrderedAddCommGroup.toMax.{u1} α _inst_1) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (NegZeroClass.toNeg.{u1} α (SubNegZeroMonoid.toNegZeroClass.{u1} α (SubtractionMonoid.toSubNegZeroMonoid.{u1} α (SubtractionCommMonoid.toSubtractionMonoid.{u1} α (AddCommGroup.toDivisionAddCommMonoid.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1)))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) a c)) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (NegZeroClass.toNeg.{u1} α (SubNegZeroMonoid.toNegZeroClass.{u1} α (SubtractionMonoid.toSubNegZeroMonoid.{u1} α (SubtractionCommMonoid.toSubtractionMonoid.{u1} α (AddCommGroup.toDivisionAddCommMonoid.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1)))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) b d)))
Case conversion may be inaccurate. Consider using '#align abs_max_sub_max_le_max abs_max_sub_max_le_maxₓ'. -/
theorem abs_max_sub_max_le_max (a b c d : α) : |max a b - max c d| ≤ max (|a - c|) (|b - d|) :=
  by
  refine' abs_sub_le_iff.2 ⟨_, _⟩
  · exact (max_sub_max_le_max _ _ _ _).trans (max_le_max (le_abs_self _) (le_abs_self _))
  · rw [abs_sub_comm a c, abs_sub_comm b d]
    exact (max_sub_max_le_max _ _ _ _).trans (max_le_max (le_abs_self _) (le_abs_self _))
#align abs_max_sub_max_le_max abs_max_sub_max_le_max

/- warning: abs_min_sub_min_le_max -> abs_min_sub_min_le_max is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedAddCommGroup.{u1} α] (a : α) (b : α) (c : α) (d : α), LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (OrderedAddCommGroup.toPartialOrder.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (SubNegMonoid.toHasNeg.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (LinearOrder.toLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toHasSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) (LinearOrder.min.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1) a b) (LinearOrder.min.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1) c d))) (LinearOrder.max.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (SubNegMonoid.toHasNeg.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (LinearOrder.toLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toHasSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) a c)) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (SubNegMonoid.toHasNeg.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (LinearOrder.toLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toHasSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) b d)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedAddCommGroup.{u1} α] (a : α) (b : α) (c : α) (d : α), LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (OrderedAddCommGroup.toPartialOrder.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (NegZeroClass.toNeg.{u1} α (SubNegZeroMonoid.toNegZeroClass.{u1} α (SubtractionMonoid.toSubNegZeroMonoid.{u1} α (SubtractionCommMonoid.toSubtractionMonoid.{u1} α (AddCommGroup.toDivisionAddCommMonoid.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1)))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) (Min.min.{u1} α (LinearOrderedAddCommGroup.toMin.{u1} α _inst_1) a b) (Min.min.{u1} α (LinearOrderedAddCommGroup.toMin.{u1} α _inst_1) c d))) (Max.max.{u1} α (LinearOrderedAddCommGroup.toMax.{u1} α _inst_1) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (NegZeroClass.toNeg.{u1} α (SubNegZeroMonoid.toNegZeroClass.{u1} α (SubtractionMonoid.toSubNegZeroMonoid.{u1} α (SubtractionCommMonoid.toSubtractionMonoid.{u1} α (AddCommGroup.toDivisionAddCommMonoid.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1)))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) a c)) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (NegZeroClass.toNeg.{u1} α (SubNegZeroMonoid.toNegZeroClass.{u1} α (SubtractionMonoid.toSubNegZeroMonoid.{u1} α (SubtractionCommMonoid.toSubtractionMonoid.{u1} α (AddCommGroup.toDivisionAddCommMonoid.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1)))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) b d)))
Case conversion may be inaccurate. Consider using '#align abs_min_sub_min_le_max abs_min_sub_min_le_maxₓ'. -/
theorem abs_min_sub_min_le_max (a b c d : α) : |min a b - min c d| ≤ max (|a - c|) (|b - d|) := by
  simpa only [max_neg_neg, neg_sub_neg, abs_sub_comm] using
    abs_max_sub_max_le_max (-a) (-b) (-c) (-d)
#align abs_min_sub_min_le_max abs_min_sub_min_le_max

/- warning: abs_max_sub_max_le_abs -> abs_max_sub_max_le_abs is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedAddCommGroup.{u1} α] (a : α) (b : α) (c : α), LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (OrderedAddCommGroup.toPartialOrder.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (SubNegMonoid.toHasNeg.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (LinearOrder.toLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toHasSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) (LinearOrder.max.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1) a c) (LinearOrder.max.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1) b c))) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (SubNegMonoid.toHasNeg.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (LinearOrder.toLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toHasSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) a b))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : LinearOrderedAddCommGroup.{u1} α] (a : α) (b : α) (c : α), LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (OrderedAddCommGroup.toPartialOrder.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (NegZeroClass.toNeg.{u1} α (SubNegZeroMonoid.toNegZeroClass.{u1} α (SubtractionMonoid.toSubNegZeroMonoid.{u1} α (SubtractionCommMonoid.toSubtractionMonoid.{u1} α (AddCommGroup.toDivisionAddCommMonoid.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1)))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) (Max.max.{u1} α (LinearOrderedAddCommGroup.toMax.{u1} α _inst_1) a c) (Max.max.{u1} α (LinearOrderedAddCommGroup.toMax.{u1} α _inst_1) b c))) (Abs.abs.{u1} α (Neg.toHasAbs.{u1} α (NegZeroClass.toNeg.{u1} α (SubNegZeroMonoid.toNegZeroClass.{u1} α (SubtractionMonoid.toSubNegZeroMonoid.{u1} α (SubtractionCommMonoid.toSubtractionMonoid.{u1} α (AddCommGroup.toDivisionAddCommMonoid.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1))))))) (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α (LinearOrderedAddCommGroup.toLinearOrder.{u1} α _inst_1)))))) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddCommGroup.toAddGroup.{u1} α (OrderedAddCommGroup.toAddCommGroup.{u1} α (LinearOrderedAddCommGroup.toOrderedAddCommGroup.{u1} α _inst_1)))))) a b))
Case conversion may be inaccurate. Consider using '#align abs_max_sub_max_le_abs abs_max_sub_max_le_absₓ'. -/
theorem abs_max_sub_max_le_abs (a b c : α) : |max a c - max b c| ≤ |a - b| := by
  simpa only [sub_self, abs_zero, max_eq_left (abs_nonneg _)] using abs_max_sub_max_le_max a c b c
#align abs_max_sub_max_le_abs abs_max_sub_max_le_abs

end LinearOrderedAddCommGroup

