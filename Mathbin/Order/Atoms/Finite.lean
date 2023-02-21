/-
Copyright (c) 2020 Aaron Anderson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson

! This file was ported from Lean 3 source module order.atoms.finite
! leanprover-community/mathlib commit bd9851ca476957ea4549eb19b40e7b5ade9428cc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Finite
import Mathbin.Order.Atoms

/-!
# Atoms, Coatoms, Simple Lattices, and Finiteness

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This module contains some results on atoms and simple lattices in the finite context.

## Main results
  * `finite.to_is_atomic`, `finite.to_is_coatomic`: Finite partial orders with bottom resp. top
    are atomic resp. coatomic.

-/


variable {α β : Type _}

namespace IsSimpleOrder

section DecidableEq

/- It is important that `is_simple_order` is the last type-class argument of this instance,
so that type-class inference fails quickly if it doesn't apply. -/
instance (priority := 200) {α} [DecidableEq α] [LE α] [BoundedOrder α] [IsSimpleOrder α] :
    Fintype α :=
  Fintype.ofEquiv Bool equivBool.symm

end DecidableEq

end IsSimpleOrder

namespace Fintype

namespace IsSimpleOrder

variable [PartialOrder α] [BoundedOrder α] [IsSimpleOrder α] [DecidableEq α]

/- warning: fintype.is_simple_order.univ -> Fintype.IsSimpleOrder.univ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] [_inst_3 : IsSimpleOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2] [_inst_4 : DecidableEq.{succ u1} α], Eq.{succ u1} (Finset.{u1} α) (Finset.univ.{u1} α (IsSimpleOrder.fintype.{u1} α (fun (a : α) (b : α) => _inst_4 a b) (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2 _inst_3)) (Insert.insert.{u1, u1} α (Finset.{u1} α) (Finset.hasInsert.{u1} α (fun (a : α) (b : α) => _inst_4 a b)) (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))) (Singleton.singleton.{u1, u1} α (Finset.{u1} α) (Finset.hasSingleton.{u1} α) (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] [_inst_3 : IsSimpleOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2] [_inst_4 : DecidableEq.{succ u1} α], Eq.{succ u1} (Finset.{u1} α) (Finset.univ.{u1} α (IsSimpleOrder.instFintype.{u1} α (fun (a : α) (b : α) => _inst_4 a b) (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2 _inst_3)) (Insert.insert.{u1, u1} α (Finset.{u1} α) (Finset.instInsertFinset.{u1} α (fun (a : α) (b : α) => _inst_4 a b)) (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))) (Singleton.singleton.{u1, u1} α (Finset.{u1} α) (Finset.instSingletonFinset.{u1} α) (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))))
Case conversion may be inaccurate. Consider using '#align fintype.is_simple_order.univ Fintype.IsSimpleOrder.univₓ'. -/
theorem univ : (Finset.univ : Finset α) = {⊤, ⊥} :=
  by
  change Finset.map _ (Finset.univ : Finset Bool) = _
  rw [Fintype.univ_bool]
  simp only [Finset.map_insert, Function.Embedding.coeFn_mk, Finset.map_singleton]
  rfl
#align fintype.is_simple_order.univ Fintype.IsSimpleOrder.univ

#print Fintype.IsSimpleOrder.card /-
theorem card : Fintype.card α = 2 :=
  (Fintype.ofEquiv_card _).trans Fintype.card_bool
#align fintype.is_simple_order.card Fintype.IsSimpleOrder.card
-/

end IsSimpleOrder

end Fintype

namespace Bool

instance : IsSimpleOrder Bool :=
  ⟨fun a =>
    by
    rw [← Finset.mem_singleton, or_comm, ← Finset.mem_insert, top_eq_true, bot_eq_false, ←
      Fintype.univ_bool]
    apply Finset.mem_univ⟩

end Bool

section Fintype

open Finset

#print Finite.to_isCoatomic /-
-- see Note [lower instance priority]
instance (priority := 100) Finite.to_isCoatomic [PartialOrder α] [OrderTop α] [Finite α] :
    IsCoatomic α :=
  by
  refine' IsCoatomic.mk fun b => or_iff_not_imp_left.2 fun ht => _
  obtain ⟨c, hc, hmax⟩ :=
    Set.Finite.exists_maximal_wrt id { x : α | b ≤ x ∧ x ≠ ⊤ } (Set.toFinite _) ⟨b, le_rfl, ht⟩
  refine' ⟨c, ⟨hc.2, fun y hcy => _⟩, hc.1⟩
  by_contra hyt
  obtain rfl : c = y := hmax y ⟨hc.1.trans hcy.le, hyt⟩ hcy.le
  exact (lt_self_iff_false _).mp hcy
#align finite.to_is_coatomic Finite.to_isCoatomic
-/

#print Finite.to_isAtomic /-
-- see Note [lower instance priority]
instance (priority := 100) Finite.to_isAtomic [PartialOrder α] [OrderBot α] [Finite α] :
    IsAtomic α :=
  isCoatomic_dual_iff_isAtomic.mp Finite.to_isCoatomic
#align finite.to_is_atomic Finite.to_isAtomic
-/

end Fintype

