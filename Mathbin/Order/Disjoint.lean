/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl

! This file was ported from Lean 3 source module order.disjoint
! leanprover-community/mathlib commit 26f081a2fb920140ed5bc5cc5344e84bcc7cb2b2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.BoundedOrder

/-!
# Disjointness and complements

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines `disjoint`, `codisjoint`, and the `is_compl` predicate.

## Main declarations

* `disjoint x y`: two elements of a lattice are disjoint if their `inf` is the bottom element.
* `codisjoint x y`: two elements of a lattice are codisjoint if their `join` is the top element.
* `is_compl x y`: In a bounded lattice, predicate for "`x` is a complement of `y`". Note that in a
  non distributive lattice, an element can have several complements.
* `complemented_lattice α`: Typeclass stating that any element of a lattice has a complement.

-/


variable {α : Type _}

section Disjoint

section PartialOrderBot

variable [PartialOrder α] [OrderBot α] {a b c d : α}

#print Disjoint /-
/-- Two elements of a lattice are disjoint if their inf is the bottom element.
  (This generalizes disjoint sets, viewed as members of the subset lattice.)

Note that we define this without reference to `⊓`, as this allows us to talk about orders where
the infimum is not unique, or where implementing `has_inf` would require additional `decidable`
arguments. -/
def Disjoint (a b : α) : Prop :=
  ∀ ⦃x⦄, x ≤ a → x ≤ b → x ≤ ⊥
#align disjoint Disjoint
-/

#print Disjoint.comm /-
theorem Disjoint.comm : Disjoint a b ↔ Disjoint b a :=
  forall_congr' fun _ => forall_swap
#align disjoint.comm Disjoint.comm
-/

#print Disjoint.symm /-
@[symm]
theorem Disjoint.symm ⦃a b : α⦄ : Disjoint a b → Disjoint b a :=
  Disjoint.comm.1
#align disjoint.symm Disjoint.symm
-/

#print symmetric_disjoint /-
theorem symmetric_disjoint : Symmetric (Disjoint : α → α → Prop) :=
  Disjoint.symm
#align symmetric_disjoint symmetric_disjoint
-/

/- warning: disjoint_bot_left -> disjoint_bot_left is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Disjoint.{u1} α _inst_1 _inst_2 (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)) a
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Disjoint.{u1} α _inst_1 _inst_2 (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)) a
Case conversion may be inaccurate. Consider using '#align disjoint_bot_left disjoint_bot_leftₓ'. -/
@[simp]
theorem disjoint_bot_left : Disjoint ⊥ a := fun x hbot ha => hbot
#align disjoint_bot_left disjoint_bot_left

/- warning: disjoint_bot_right -> disjoint_bot_right is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Disjoint.{u1} α _inst_1 _inst_2 a (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Disjoint.{u1} α _inst_1 _inst_2 a (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))
Case conversion may be inaccurate. Consider using '#align disjoint_bot_right disjoint_bot_rightₓ'. -/
@[simp]
theorem disjoint_bot_right : Disjoint a ⊥ := fun x ha hbot => hbot
#align disjoint_bot_right disjoint_bot_right

#print Disjoint.mono /-
theorem Disjoint.mono (h₁ : a ≤ b) (h₂ : c ≤ d) : Disjoint b d → Disjoint a c := fun h x ha hc =>
  h (ha.trans h₁) (hc.trans h₂)
#align disjoint.mono Disjoint.mono
-/

#print Disjoint.mono_left /-
theorem Disjoint.mono_left (h : a ≤ b) : Disjoint b c → Disjoint a c :=
  Disjoint.mono h le_rfl
#align disjoint.mono_left Disjoint.mono_left
-/

#print Disjoint.mono_right /-
theorem Disjoint.mono_right : b ≤ c → Disjoint a c → Disjoint a b :=
  Disjoint.mono le_rfl
#align disjoint.mono_right Disjoint.mono_right
-/

/- warning: disjoint_self -> disjoint_self is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Iff (Disjoint.{u1} α _inst_1 _inst_2 a a) (Eq.{succ u1} α a (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Iff (Disjoint.{u1} α _inst_1 _inst_2 a a) (Eq.{succ u1} α a (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))
Case conversion may be inaccurate. Consider using '#align disjoint_self disjoint_selfₓ'. -/
@[simp]
theorem disjoint_self : Disjoint a a ↔ a = ⊥ :=
  ⟨fun hd => bot_unique <| hd le_rfl le_rfl, fun h x ha hb => ha.trans_eq h⟩
#align disjoint_self disjoint_self

/- TODO: Rename `disjoint.eq_bot` to `disjoint.inf_eq` and `disjoint.eq_bot_of_self` to
`disjoint.eq_bot` -/
alias disjoint_self ↔ Disjoint.eq_bot_of_self _

/- warning: disjoint.ne -> Disjoint.ne is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α} {b : α}, (Ne.{succ u1} α a (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))) -> (Disjoint.{u1} α _inst_1 _inst_2 a b) -> (Ne.{succ u1} α a b)
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α} {b : α}, (Ne.{succ u1} α a (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))) -> (Disjoint.{u1} α _inst_1 _inst_2 a b) -> (Ne.{succ u1} α a b)
Case conversion may be inaccurate. Consider using '#align disjoint.ne Disjoint.neₓ'. -/
theorem Disjoint.ne (ha : a ≠ ⊥) (hab : Disjoint a b) : a ≠ b := fun h =>
  ha <| disjoint_self.1 <| by rwa [← h] at hab
#align disjoint.ne Disjoint.ne

/- warning: disjoint.eq_bot_of_le -> Disjoint.eq_bot_of_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α} {b : α}, (Disjoint.{u1} α _inst_1 _inst_2 a b) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) a b) -> (Eq.{succ u1} α a (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α} {b : α}, (Disjoint.{u1} α _inst_1 _inst_2 a b) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) a b) -> (Eq.{succ u1} α a (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))
Case conversion may be inaccurate. Consider using '#align disjoint.eq_bot_of_le Disjoint.eq_bot_of_leₓ'. -/
theorem Disjoint.eq_bot_of_le (hab : Disjoint a b) (h : a ≤ b) : a = ⊥ :=
  eq_bot_iff.2 <| hab le_rfl h
#align disjoint.eq_bot_of_le Disjoint.eq_bot_of_le

/- warning: disjoint.eq_bot_of_ge -> Disjoint.eq_bot_of_ge is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α} {b : α}, (Disjoint.{u1} α _inst_1 _inst_2 a b) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) b a) -> (Eq.{succ u1} α b (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α} {b : α}, (Disjoint.{u1} α _inst_1 _inst_2 a b) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) b a) -> (Eq.{succ u1} α b (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))
Case conversion may be inaccurate. Consider using '#align disjoint.eq_bot_of_ge Disjoint.eq_bot_of_geₓ'. -/
theorem Disjoint.eq_bot_of_ge (hab : Disjoint a b) : b ≤ a → b = ⊥ :=
  hab.symm.eq_bot_of_le
#align disjoint.eq_bot_of_ge Disjoint.eq_bot_of_ge

end PartialOrderBot

section PartialBoundedOrder

variable [PartialOrder α] [BoundedOrder α] {a : α}

/- warning: disjoint_top -> disjoint_top is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Iff (Disjoint.{u1} α _inst_1 (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2) a (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))) (Eq.{succ u1} α a (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Iff (Disjoint.{u1} α _inst_1 (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2) a (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))) (Eq.{succ u1} α a (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))))
Case conversion may be inaccurate. Consider using '#align disjoint_top disjoint_topₓ'. -/
@[simp]
theorem disjoint_top : Disjoint a ⊤ ↔ a = ⊥ :=
  ⟨fun h => bot_unique <| h le_rfl le_top, fun h x ha htop => ha.trans_eq h⟩
#align disjoint_top disjoint_top

/- warning: top_disjoint -> top_disjoint is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Iff (Disjoint.{u1} α _inst_1 (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2) (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))) a) (Eq.{succ u1} α a (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Iff (Disjoint.{u1} α _inst_1 (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2) (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))) a) (Eq.{succ u1} α a (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))))
Case conversion may be inaccurate. Consider using '#align top_disjoint top_disjointₓ'. -/
@[simp]
theorem top_disjoint : Disjoint ⊤ a ↔ a = ⊥ :=
  ⟨fun h => bot_unique <| h le_top le_rfl, fun h x htop ha => ha.trans_eq h⟩
#align top_disjoint top_disjoint

end PartialBoundedOrder

section SemilatticeInfBot

variable [SemilatticeInf α] [OrderBot α] {a b c d : α}

/- warning: disjoint_iff_inf_le -> disjoint_iff_inf_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : SemilatticeInf.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, Iff (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1) _inst_2 a b) (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α _inst_1) a b) (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) _inst_2)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : SemilatticeInf.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, Iff (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1) _inst_2 a b) (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α _inst_1) a b) (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) _inst_2)))
Case conversion may be inaccurate. Consider using '#align disjoint_iff_inf_le disjoint_iff_inf_leₓ'. -/
theorem disjoint_iff_inf_le : Disjoint a b ↔ a ⊓ b ≤ ⊥ :=
  ⟨fun hd => hd inf_le_left inf_le_right, fun h x ha hb => (le_inf ha hb).trans h⟩
#align disjoint_iff_inf_le disjoint_iff_inf_le

/- warning: disjoint_iff -> disjoint_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : SemilatticeInf.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, Iff (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1) _inst_2 a b) (Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α _inst_1) a b) (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) _inst_2)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : SemilatticeInf.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, Iff (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1) _inst_2 a b) (Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α _inst_1) a b) (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) _inst_2)))
Case conversion may be inaccurate. Consider using '#align disjoint_iff disjoint_iffₓ'. -/
theorem disjoint_iff : Disjoint a b ↔ a ⊓ b = ⊥ :=
  disjoint_iff_inf_le.trans le_bot_iff
#align disjoint_iff disjoint_iff

/- warning: disjoint.le_bot -> Disjoint.le_bot is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : SemilatticeInf.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1) _inst_2 a b) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α _inst_1) a b) (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) _inst_2)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : SemilatticeInf.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1) _inst_2 a b) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α _inst_1) a b) (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) _inst_2)))
Case conversion may be inaccurate. Consider using '#align disjoint.le_bot Disjoint.le_botₓ'. -/
theorem Disjoint.le_bot : Disjoint a b → a ⊓ b ≤ ⊥ :=
  disjoint_iff_inf_le.mp
#align disjoint.le_bot Disjoint.le_bot

/- warning: disjoint.eq_bot -> Disjoint.eq_bot is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : SemilatticeInf.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1) _inst_2 a b) -> (Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α _inst_1) a b) (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) _inst_2)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : SemilatticeInf.{u1} α] [_inst_2 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, (Disjoint.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1) _inst_2 a b) -> (Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α _inst_1) a b) (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) _inst_2)))
Case conversion may be inaccurate. Consider using '#align disjoint.eq_bot Disjoint.eq_botₓ'. -/
theorem Disjoint.eq_bot : Disjoint a b → a ⊓ b = ⊥ :=
  bot_unique ∘ Disjoint.le_bot
#align disjoint.eq_bot Disjoint.eq_bot

#print disjoint_assoc /-
theorem disjoint_assoc : Disjoint (a ⊓ b) c ↔ Disjoint a (b ⊓ c) := by
  rw [disjoint_iff_inf_le, disjoint_iff_inf_le, inf_assoc]
#align disjoint_assoc disjoint_assoc
-/

#print disjoint_left_comm /-
theorem disjoint_left_comm : Disjoint a (b ⊓ c) ↔ Disjoint b (a ⊓ c) := by
  simp_rw [disjoint_iff_inf_le, inf_left_comm]
#align disjoint_left_comm disjoint_left_comm
-/

#print disjoint_right_comm /-
theorem disjoint_right_comm : Disjoint (a ⊓ b) c ↔ Disjoint (a ⊓ c) b := by
  simp_rw [disjoint_iff_inf_le, inf_right_comm]
#align disjoint_right_comm disjoint_right_comm
-/

variable (c)

#print Disjoint.inf_left /-
theorem Disjoint.inf_left (h : Disjoint a b) : Disjoint (a ⊓ c) b :=
  h.mono_left inf_le_left
#align disjoint.inf_left Disjoint.inf_left
-/

#print Disjoint.inf_left' /-
theorem Disjoint.inf_left' (h : Disjoint a b) : Disjoint (c ⊓ a) b :=
  h.mono_left inf_le_right
#align disjoint.inf_left' Disjoint.inf_left'
-/

#print Disjoint.inf_right /-
theorem Disjoint.inf_right (h : Disjoint a b) : Disjoint a (b ⊓ c) :=
  h.mono_right inf_le_left
#align disjoint.inf_right Disjoint.inf_right
-/

#print Disjoint.inf_right' /-
theorem Disjoint.inf_right' (h : Disjoint a b) : Disjoint a (c ⊓ b) :=
  h.mono_right inf_le_right
#align disjoint.inf_right' Disjoint.inf_right'
-/

variable {c}

#print Disjoint.of_disjoint_inf_of_le /-
theorem Disjoint.of_disjoint_inf_of_le (h : Disjoint (a ⊓ b) c) (hle : a ≤ c) : Disjoint a b :=
  disjoint_iff.2 <| h.eq_bot_of_le <| inf_le_of_left_le hle
#align disjoint.of_disjoint_inf_of_le Disjoint.of_disjoint_inf_of_le
-/

#print Disjoint.of_disjoint_inf_of_le' /-
theorem Disjoint.of_disjoint_inf_of_le' (h : Disjoint (a ⊓ b) c) (hle : b ≤ c) : Disjoint a b :=
  disjoint_iff.2 <| h.eq_bot_of_le <| inf_le_of_right_le hle
#align disjoint.of_disjoint_inf_of_le' Disjoint.of_disjoint_inf_of_le'
-/

end SemilatticeInfBot

section DistribLatticeBot

variable [DistribLattice α] [OrderBot α] {a b c : α}

#print disjoint_sup_left /-
@[simp]
theorem disjoint_sup_left : Disjoint (a ⊔ b) c ↔ Disjoint a c ∧ Disjoint b c := by
  simp only [disjoint_iff, inf_sup_right, sup_eq_bot_iff]
#align disjoint_sup_left disjoint_sup_left
-/

#print disjoint_sup_right /-
@[simp]
theorem disjoint_sup_right : Disjoint a (b ⊔ c) ↔ Disjoint a b ∧ Disjoint a c := by
  simp only [disjoint_iff, inf_sup_left, sup_eq_bot_iff]
#align disjoint_sup_right disjoint_sup_right
-/

#print Disjoint.sup_left /-
theorem Disjoint.sup_left (ha : Disjoint a c) (hb : Disjoint b c) : Disjoint (a ⊔ b) c :=
  disjoint_sup_left.2 ⟨ha, hb⟩
#align disjoint.sup_left Disjoint.sup_left
-/

#print Disjoint.sup_right /-
theorem Disjoint.sup_right (hb : Disjoint a b) (hc : Disjoint a c) : Disjoint a (b ⊔ c) :=
  disjoint_sup_right.2 ⟨hb, hc⟩
#align disjoint.sup_right Disjoint.sup_right
-/

#print Disjoint.left_le_of_le_sup_right /-
theorem Disjoint.left_le_of_le_sup_right (h : a ≤ b ⊔ c) (hd : Disjoint a c) : a ≤ b :=
  le_of_inf_le_sup_le (le_trans hd.le_bot bot_le) <| sup_le h le_sup_right
#align disjoint.left_le_of_le_sup_right Disjoint.left_le_of_le_sup_right
-/

#print Disjoint.left_le_of_le_sup_left /-
theorem Disjoint.left_le_of_le_sup_left (h : a ≤ c ⊔ b) (hd : Disjoint a c) : a ≤ b :=
  hd.left_le_of_le_sup_right <| by rwa [sup_comm]
#align disjoint.left_le_of_le_sup_left Disjoint.left_le_of_le_sup_left
-/

end DistribLatticeBot

end Disjoint

section Codisjoint

section PartialOrderTop

variable [PartialOrder α] [OrderTop α] {a b c d : α}

#print Codisjoint /-
/-- Two elements of a lattice are codisjoint if their sup is the top element.

Note that we define this without reference to `⊔`, as this allows us to talk about orders where
the supremum is not unique, or where implement `has_sup` would require additional `decidable`
arguments. -/
def Codisjoint (a b : α) : Prop :=
  ∀ ⦃x⦄, a ≤ x → b ≤ x → ⊤ ≤ x
#align codisjoint Codisjoint
-/

#print Codisjoint.comm /-
theorem Codisjoint.comm : Codisjoint a b ↔ Codisjoint b a :=
  forall_congr' fun _ => forall_swap
#align codisjoint.comm Codisjoint.comm
-/

#print Codisjoint.symm /-
@[symm]
theorem Codisjoint.symm ⦃a b : α⦄ : Codisjoint a b → Codisjoint b a :=
  Codisjoint.comm.1
#align codisjoint.symm Codisjoint.symm
-/

#print symmetric_codisjoint /-
theorem symmetric_codisjoint : Symmetric (Codisjoint : α → α → Prop) :=
  Codisjoint.symm
#align symmetric_codisjoint symmetric_codisjoint
-/

/- warning: codisjoint_top_left -> codisjoint_top_left is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Codisjoint.{u1} α _inst_1 _inst_2 (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)) a
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Codisjoint.{u1} α _inst_1 _inst_2 (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)) a
Case conversion may be inaccurate. Consider using '#align codisjoint_top_left codisjoint_top_leftₓ'. -/
@[simp]
theorem codisjoint_top_left : Codisjoint ⊤ a := fun x htop ha => htop
#align codisjoint_top_left codisjoint_top_left

/- warning: codisjoint_top_right -> codisjoint_top_right is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Codisjoint.{u1} α _inst_1 _inst_2 a (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Codisjoint.{u1} α _inst_1 _inst_2 a (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))
Case conversion may be inaccurate. Consider using '#align codisjoint_top_right codisjoint_top_rightₓ'. -/
@[simp]
theorem codisjoint_top_right : Codisjoint a ⊤ := fun x ha htop => htop
#align codisjoint_top_right codisjoint_top_right

#print Codisjoint.mono /-
theorem Codisjoint.mono (h₁ : a ≤ b) (h₂ : c ≤ d) : Codisjoint a c → Codisjoint b d :=
  fun h x ha hc => h (h₁.trans ha) (h₂.trans hc)
#align codisjoint.mono Codisjoint.mono
-/

#print Codisjoint.mono_left /-
theorem Codisjoint.mono_left (h : a ≤ b) : Codisjoint a c → Codisjoint b c :=
  Codisjoint.mono h le_rfl
#align codisjoint.mono_left Codisjoint.mono_left
-/

#print Codisjoint.mono_right /-
theorem Codisjoint.mono_right : b ≤ c → Codisjoint a b → Codisjoint a c :=
  Codisjoint.mono le_rfl
#align codisjoint.mono_right Codisjoint.mono_right
-/

/- warning: codisjoint_self -> codisjoint_self is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Iff (Codisjoint.{u1} α _inst_1 _inst_2 a a) (Eq.{succ u1} α a (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Iff (Codisjoint.{u1} α _inst_1 _inst_2 a a) (Eq.{succ u1} α a (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))
Case conversion may be inaccurate. Consider using '#align codisjoint_self codisjoint_selfₓ'. -/
@[simp]
theorem codisjoint_self : Codisjoint a a ↔ a = ⊤ :=
  ⟨fun hd => top_unique <| hd le_rfl le_rfl, fun h x ha hb => h.symm.trans_le ha⟩
#align codisjoint_self codisjoint_self

/- TODO: Rename `codisjoint.eq_top` to `codisjoint.sup_eq` and `codisjoint.eq_top_of_self` to
`codisjoint.eq_top` -/
alias codisjoint_self ↔ Codisjoint.eq_top_of_self _

/- warning: codisjoint.ne -> Codisjoint.ne is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α} {b : α}, (Ne.{succ u1} α a (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))) -> (Codisjoint.{u1} α _inst_1 _inst_2 a b) -> (Ne.{succ u1} α a b)
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α} {b : α}, (Ne.{succ u1} α a (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))) -> (Codisjoint.{u1} α _inst_1 _inst_2 a b) -> (Ne.{succ u1} α a b)
Case conversion may be inaccurate. Consider using '#align codisjoint.ne Codisjoint.neₓ'. -/
theorem Codisjoint.ne (ha : a ≠ ⊤) (hab : Codisjoint a b) : a ≠ b := fun h =>
  ha <| codisjoint_self.1 <| by rwa [← h] at hab
#align codisjoint.ne Codisjoint.ne

/- warning: codisjoint.eq_top_of_le -> Codisjoint.eq_top_of_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α} {b : α}, (Codisjoint.{u1} α _inst_1 _inst_2 a b) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) b a) -> (Eq.{succ u1} α a (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α} {b : α}, (Codisjoint.{u1} α _inst_1 _inst_2 a b) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) b a) -> (Eq.{succ u1} α a (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))
Case conversion may be inaccurate. Consider using '#align codisjoint.eq_top_of_le Codisjoint.eq_top_of_leₓ'. -/
theorem Codisjoint.eq_top_of_le (hab : Codisjoint a b) (h : b ≤ a) : a = ⊤ :=
  eq_top_iff.2 <| hab le_rfl h
#align codisjoint.eq_top_of_le Codisjoint.eq_top_of_le

/- warning: codisjoint.eq_top_of_ge -> Codisjoint.eq_top_of_ge is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α} {b : α}, (Codisjoint.{u1} α _inst_1 _inst_2 a b) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) a b) -> (Eq.{succ u1} α b (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α} {b : α}, (Codisjoint.{u1} α _inst_1 _inst_2 a b) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) a b) -> (Eq.{succ u1} α b (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))
Case conversion may be inaccurate. Consider using '#align codisjoint.eq_top_of_ge Codisjoint.eq_top_of_geₓ'. -/
theorem Codisjoint.eq_top_of_ge (hab : Codisjoint a b) : a ≤ b → b = ⊤ :=
  hab.symm.eq_top_of_le
#align codisjoint.eq_top_of_ge Codisjoint.eq_top_of_ge

end PartialOrderTop

section PartialBoundedOrder

variable [PartialOrder α] [BoundedOrder α] {a : α}

/- warning: codisjoint_bot -> codisjoint_bot is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Iff (Codisjoint.{u1} α _inst_1 (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2) a (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))) (Eq.{succ u1} α a (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Iff (Codisjoint.{u1} α _inst_1 (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2) a (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2)))) (Eq.{succ u1} α a (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))))
Case conversion may be inaccurate. Consider using '#align codisjoint_bot codisjoint_botₓ'. -/
@[simp]
theorem codisjoint_bot : Codisjoint a ⊥ ↔ a = ⊤ :=
  ⟨fun h => top_unique <| h le_rfl bot_le, fun h x ha htop => h.symm.trans_le ha⟩
#align codisjoint_bot codisjoint_bot

/- warning: bot_codisjoint -> bot_codisjoint is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Iff (Codisjoint.{u1} α _inst_1 (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2) (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))) a) (Eq.{succ u1} α a (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] {a : α}, Iff (Codisjoint.{u1} α _inst_1 (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2) (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))) a) (Eq.{succ u1} α a (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) _inst_2))))
Case conversion may be inaccurate. Consider using '#align bot_codisjoint bot_codisjointₓ'. -/
@[simp]
theorem bot_codisjoint : Codisjoint ⊥ a ↔ a = ⊤ :=
  ⟨fun h => top_unique <| h bot_le le_rfl, fun h x htop ha => h.symm.trans_le ha⟩
#align bot_codisjoint bot_codisjoint

end PartialBoundedOrder

section SemilatticeSupTop

variable [SemilatticeSup α] [OrderTop α] {a b c d : α}

/- warning: codisjoint_iff_le_sup -> codisjoint_iff_le_sup is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : SemilatticeSup.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, Iff (Codisjoint.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1) _inst_2 a b) (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) _inst_2)) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α _inst_1) a b))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : SemilatticeSup.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, Iff (Codisjoint.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1) _inst_2 a b) (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) _inst_2)) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α _inst_1) a b))
Case conversion may be inaccurate. Consider using '#align codisjoint_iff_le_sup codisjoint_iff_le_supₓ'. -/
theorem codisjoint_iff_le_sup : Codisjoint a b ↔ ⊤ ≤ a ⊔ b :=
  @disjoint_iff_inf_le αᵒᵈ _ _ _ _
#align codisjoint_iff_le_sup codisjoint_iff_le_sup

/- warning: codisjoint_iff -> codisjoint_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : SemilatticeSup.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, Iff (Codisjoint.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1) _inst_2 a b) (Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α _inst_1) a b) (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) _inst_2)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : SemilatticeSup.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, Iff (Codisjoint.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1) _inst_2 a b) (Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α _inst_1) a b) (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) _inst_2)))
Case conversion may be inaccurate. Consider using '#align codisjoint_iff codisjoint_iffₓ'. -/
theorem codisjoint_iff : Codisjoint a b ↔ a ⊔ b = ⊤ :=
  @disjoint_iff αᵒᵈ _ _ _ _
#align codisjoint_iff codisjoint_iff

/- warning: codisjoint.top_le -> Codisjoint.top_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : SemilatticeSup.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, (Codisjoint.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1) _inst_2 a b) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) _inst_2)) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α _inst_1) a b))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : SemilatticeSup.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, (Codisjoint.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1) _inst_2 a b) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) _inst_2)) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α _inst_1) a b))
Case conversion may be inaccurate. Consider using '#align codisjoint.top_le Codisjoint.top_leₓ'. -/
theorem Codisjoint.top_le : Codisjoint a b → ⊤ ≤ a ⊔ b :=
  @Disjoint.le_bot αᵒᵈ _ _ _ _
#align codisjoint.top_le Codisjoint.top_le

/- warning: codisjoint.eq_top -> Codisjoint.eq_top is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : SemilatticeSup.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, (Codisjoint.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1) _inst_2 a b) -> (Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α _inst_1) a b) (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) _inst_2)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : SemilatticeSup.{u1} α] [_inst_2 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))] {a : α} {b : α}, (Codisjoint.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1) _inst_2 a b) -> (Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α _inst_1) a b) (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) _inst_2)))
Case conversion may be inaccurate. Consider using '#align codisjoint.eq_top Codisjoint.eq_topₓ'. -/
theorem Codisjoint.eq_top : Codisjoint a b → a ⊔ b = ⊤ :=
  @Disjoint.eq_bot αᵒᵈ _ _ _ _
#align codisjoint.eq_top Codisjoint.eq_top

#print codisjoint_assoc /-
theorem codisjoint_assoc : Codisjoint (a ⊔ b) c ↔ Codisjoint a (b ⊔ c) :=
  @disjoint_assoc αᵒᵈ _ _ _ _ _
#align codisjoint_assoc codisjoint_assoc
-/

#print codisjoint_left_comm /-
theorem codisjoint_left_comm : Codisjoint a (b ⊔ c) ↔ Codisjoint b (a ⊔ c) :=
  @disjoint_left_comm αᵒᵈ _ _ _ _ _
#align codisjoint_left_comm codisjoint_left_comm
-/

#print codisjoint_right_comm /-
theorem codisjoint_right_comm : Codisjoint (a ⊔ b) c ↔ Codisjoint (a ⊔ c) b :=
  @disjoint_right_comm αᵒᵈ _ _ _ _ _
#align codisjoint_right_comm codisjoint_right_comm
-/

variable (c)

#print Codisjoint.sup_left /-
theorem Codisjoint.sup_left (h : Codisjoint a b) : Codisjoint (a ⊔ c) b :=
  h.mono_left le_sup_left
#align codisjoint.sup_left Codisjoint.sup_left
-/

#print Codisjoint.sup_left' /-
theorem Codisjoint.sup_left' (h : Codisjoint a b) : Codisjoint (c ⊔ a) b :=
  h.mono_left le_sup_right
#align codisjoint.sup_left' Codisjoint.sup_left'
-/

#print Codisjoint.sup_right /-
theorem Codisjoint.sup_right (h : Codisjoint a b) : Codisjoint a (b ⊔ c) :=
  h.mono_right le_sup_left
#align codisjoint.sup_right Codisjoint.sup_right
-/

#print Codisjoint.sup_right' /-
theorem Codisjoint.sup_right' (h : Codisjoint a b) : Codisjoint a (c ⊔ b) :=
  h.mono_right le_sup_right
#align codisjoint.sup_right' Codisjoint.sup_right'
-/

variable {c}

#print Codisjoint.of_codisjoint_sup_of_le /-
theorem Codisjoint.of_codisjoint_sup_of_le (h : Codisjoint (a ⊔ b) c) (hle : c ≤ a) :
    Codisjoint a b :=
  @Disjoint.of_disjoint_inf_of_le αᵒᵈ _ _ _ _ _ h hle
#align codisjoint.of_codisjoint_sup_of_le Codisjoint.of_codisjoint_sup_of_le
-/

#print Codisjoint.of_codisjoint_sup_of_le' /-
theorem Codisjoint.of_codisjoint_sup_of_le' (h : Codisjoint (a ⊔ b) c) (hle : c ≤ b) :
    Codisjoint a b :=
  @Disjoint.of_disjoint_inf_of_le' αᵒᵈ _ _ _ _ _ h hle
#align codisjoint.of_codisjoint_sup_of_le' Codisjoint.of_codisjoint_sup_of_le'
-/

end SemilatticeSupTop

section DistribLatticeTop

variable [DistribLattice α] [OrderTop α] {a b c : α}

#print codisjoint_inf_left /-
@[simp]
theorem codisjoint_inf_left : Codisjoint (a ⊓ b) c ↔ Codisjoint a c ∧ Codisjoint b c := by
  simp only [codisjoint_iff, sup_inf_right, inf_eq_top_iff]
#align codisjoint_inf_left codisjoint_inf_left
-/

#print codisjoint_inf_right /-
@[simp]
theorem codisjoint_inf_right : Codisjoint a (b ⊓ c) ↔ Codisjoint a b ∧ Codisjoint a c := by
  simp only [codisjoint_iff, sup_inf_left, inf_eq_top_iff]
#align codisjoint_inf_right codisjoint_inf_right
-/

#print Codisjoint.inf_left /-
theorem Codisjoint.inf_left (ha : Codisjoint a c) (hb : Codisjoint b c) : Codisjoint (a ⊓ b) c :=
  codisjoint_inf_left.2 ⟨ha, hb⟩
#align codisjoint.inf_left Codisjoint.inf_left
-/

#print Codisjoint.inf_right /-
theorem Codisjoint.inf_right (hb : Codisjoint a b) (hc : Codisjoint a c) : Codisjoint a (b ⊓ c) :=
  codisjoint_inf_right.2 ⟨hb, hc⟩
#align codisjoint.inf_right Codisjoint.inf_right
-/

#print Codisjoint.left_le_of_le_inf_right /-
theorem Codisjoint.left_le_of_le_inf_right (h : a ⊓ b ≤ c) (hd : Codisjoint b c) : a ≤ c :=
  @Disjoint.left_le_of_le_sup_right αᵒᵈ _ _ _ _ _ h hd.symm
#align codisjoint.left_le_of_le_inf_right Codisjoint.left_le_of_le_inf_right
-/

#print Codisjoint.left_le_of_le_inf_left /-
theorem Codisjoint.left_le_of_le_inf_left (h : b ⊓ a ≤ c) (hd : Codisjoint b c) : a ≤ c :=
  hd.left_le_of_le_inf_right <| by rwa [inf_comm]
#align codisjoint.left_le_of_le_inf_left Codisjoint.left_le_of_le_inf_left
-/

end DistribLatticeTop

end Codisjoint

open OrderDual

#print Disjoint.dual /-
theorem Disjoint.dual [SemilatticeInf α] [OrderBot α] {a b : α} :
    Disjoint a b → Codisjoint (toDual a) (toDual b) :=
  id
#align disjoint.dual Disjoint.dual
-/

#print Codisjoint.dual /-
theorem Codisjoint.dual [SemilatticeSup α] [OrderTop α] {a b : α} :
    Codisjoint a b → Disjoint (toDual a) (toDual b) :=
  id
#align codisjoint.dual Codisjoint.dual
-/

#print disjoint_toDual_iff /-
@[simp]
theorem disjoint_toDual_iff [SemilatticeSup α] [OrderTop α] {a b : α} :
    Disjoint (toDual a) (toDual b) ↔ Codisjoint a b :=
  Iff.rfl
#align disjoint_to_dual_iff disjoint_toDual_iff
-/

#print disjoint_ofDual_iff /-
@[simp]
theorem disjoint_ofDual_iff [SemilatticeInf α] [OrderBot α] {a b : αᵒᵈ} :
    Disjoint (ofDual a) (ofDual b) ↔ Codisjoint a b :=
  Iff.rfl
#align disjoint_of_dual_iff disjoint_ofDual_iff
-/

#print codisjoint_toDual_iff /-
@[simp]
theorem codisjoint_toDual_iff [SemilatticeInf α] [OrderBot α] {a b : α} :
    Codisjoint (toDual a) (toDual b) ↔ Disjoint a b :=
  Iff.rfl
#align codisjoint_to_dual_iff codisjoint_toDual_iff
-/

#print codisjoint_ofDual_iff /-
@[simp]
theorem codisjoint_ofDual_iff [SemilatticeSup α] [OrderTop α] {a b : αᵒᵈ} :
    Codisjoint (ofDual a) (ofDual b) ↔ Disjoint a b :=
  Iff.rfl
#align codisjoint_of_dual_iff codisjoint_ofDual_iff
-/

section DistribLattice

variable [DistribLattice α] [BoundedOrder α] {a b c : α}

#print Disjoint.le_of_codisjoint /-
theorem Disjoint.le_of_codisjoint (hab : Disjoint a b) (hbc : Codisjoint b c) : a ≤ c :=
  by
  rw [← @inf_top_eq _ _ _ a, ← @bot_sup_eq _ _ _ c, ← hab.eq_bot, ← hbc.eq_top, sup_inf_right]
  exact inf_le_inf_right _ le_sup_left
#align disjoint.le_of_codisjoint Disjoint.le_of_codisjoint
-/

end DistribLattice

section IsCompl

#print IsCompl /-
/-- Two elements `x` and `y` are complements of each other if `x ⊔ y = ⊤` and `x ⊓ y = ⊥`. -/
@[protect_proj]
structure IsCompl [PartialOrder α] [BoundedOrder α] (x y : α) : Prop where
  Disjoint : Disjoint x y
  Codisjoint : Codisjoint x y
#align is_compl IsCompl
-/

#print isCompl_iff /-
theorem isCompl_iff [PartialOrder α] [BoundedOrder α] {a b : α} :
    IsCompl a b ↔ Disjoint a b ∧ Codisjoint a b :=
  ⟨fun h => ⟨h.1, h.2⟩, fun h => ⟨h.1, h.2⟩⟩
#align is_compl_iff isCompl_iff
-/

namespace IsCompl

section BoundedPartialOrder

variable [PartialOrder α] [BoundedOrder α] {x y z : α}

#print IsCompl.symm /-
@[symm]
protected theorem symm (h : IsCompl x y) : IsCompl y x :=
  ⟨h.1.symm, h.2.symm⟩
#align is_compl.symm IsCompl.symm
-/

#print IsCompl.dual /-
theorem dual (h : IsCompl x y) : IsCompl (toDual x) (toDual y) :=
  ⟨h.2, h.1⟩
#align is_compl.dual IsCompl.dual
-/

#print IsCompl.ofDual /-
theorem ofDual {a b : αᵒᵈ} (h : IsCompl a b) : IsCompl (ofDual a) (ofDual b) :=
  ⟨h.2, h.1⟩
#align is_compl.of_dual IsCompl.ofDual
-/

end BoundedPartialOrder

section BoundedLattice

variable [Lattice α] [BoundedOrder α] {x y z : α}

/- warning: is_compl.of_le -> IsCompl.of_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α} {y : α}, (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) x y) (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2)))) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α _inst_1)) x y)) -> (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 x y)
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α} {y : α}, (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α _inst_1) x y) (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2)))) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))) (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α _inst_1)) x y)) -> (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 x y)
Case conversion may be inaccurate. Consider using '#align is_compl.of_le IsCompl.of_leₓ'. -/
theorem of_le (h₁ : x ⊓ y ≤ ⊥) (h₂ : ⊤ ≤ x ⊔ y) : IsCompl x y :=
  ⟨disjoint_iff_inf_le.mpr h₁, codisjoint_iff_le_sup.mpr h₂⟩
#align is_compl.of_le IsCompl.of_le

/- warning: is_compl.of_eq -> IsCompl.of_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α} {y : α}, (Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) x y) (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2)))) -> (Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α _inst_1)) x y) (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2)))) -> (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 x y)
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α} {y : α}, (Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α _inst_1) x y) (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2)))) -> (Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α _inst_1)) x y) (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2)))) -> (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 x y)
Case conversion may be inaccurate. Consider using '#align is_compl.of_eq IsCompl.of_eqₓ'. -/
theorem of_eq (h₁ : x ⊓ y = ⊥) (h₂ : x ⊔ y = ⊤) : IsCompl x y :=
  ⟨disjoint_iff.mpr h₁, codisjoint_iff.mpr h₂⟩
#align is_compl.of_eq IsCompl.of_eq

/- warning: is_compl.inf_eq_bot -> IsCompl.inf_eq_bot is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α} {y : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 x y) -> (Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) x y) (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α} {y : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 x y) -> (Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α _inst_1) x y) (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))))
Case conversion may be inaccurate. Consider using '#align is_compl.inf_eq_bot IsCompl.inf_eq_botₓ'. -/
theorem inf_eq_bot (h : IsCompl x y) : x ⊓ y = ⊥ :=
  h.Disjoint.eq_bot
#align is_compl.inf_eq_bot IsCompl.inf_eq_bot

/- warning: is_compl.sup_eq_top -> IsCompl.sup_eq_top is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α} {y : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 x y) -> (Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α _inst_1)) x y) (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α} {y : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 x y) -> (Eq.{succ u1} α (HasSup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α (Lattice.toSemilatticeSup.{u1} α _inst_1)) x y) (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))))
Case conversion may be inaccurate. Consider using '#align is_compl.sup_eq_top IsCompl.sup_eq_topₓ'. -/
theorem sup_eq_top (h : IsCompl x y) : x ⊔ y = ⊤ :=
  h.Codisjoint.eq_top
#align is_compl.sup_eq_top IsCompl.sup_eq_top

end BoundedLattice

variable [DistribLattice α] [BoundedOrder α] {a b x y z : α}

#print IsCompl.inf_left_le_of_le_sup_right /-
theorem inf_left_le_of_le_sup_right (h : IsCompl x y) (hle : a ≤ b ⊔ y) : a ⊓ x ≤ b :=
  calc
    a ⊓ x ≤ (b ⊔ y) ⊓ x := inf_le_inf hle le_rfl
    _ = b ⊓ x ⊔ y ⊓ x := inf_sup_right
    _ = b ⊓ x := by rw [h.symm.inf_eq_bot, sup_bot_eq]
    _ ≤ b := inf_le_left
    
#align is_compl.inf_left_le_of_le_sup_right IsCompl.inf_left_le_of_le_sup_right
-/

#print IsCompl.le_sup_right_iff_inf_left_le /-
theorem le_sup_right_iff_inf_left_le {a b} (h : IsCompl x y) : a ≤ b ⊔ y ↔ a ⊓ x ≤ b :=
  ⟨h.inf_left_le_of_le_sup_right, h.symm.dual.inf_left_le_of_le_sup_right⟩
#align is_compl.le_sup_right_iff_inf_left_le IsCompl.le_sup_right_iff_inf_left_le
-/

/- warning: is_compl.inf_left_eq_bot_iff -> IsCompl.inf_left_eq_bot_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : DistribLattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1)))))] {x : α} {y : α} {z : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))) _inst_2 y z) -> (Iff (Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))) x y) (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))))) _inst_2)))) (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))))) x z))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : DistribLattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1)))))] {x : α} {y : α} {z : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))) _inst_2 y z) -> (Iff (Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1)) x y) (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))))) _inst_2)))) (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))))) x z))
Case conversion may be inaccurate. Consider using '#align is_compl.inf_left_eq_bot_iff IsCompl.inf_left_eq_bot_iffₓ'. -/
theorem inf_left_eq_bot_iff (h : IsCompl y z) : x ⊓ y = ⊥ ↔ x ≤ z := by
  rw [← le_bot_iff, ← h.le_sup_right_iff_inf_left_le, bot_sup_eq]
#align is_compl.inf_left_eq_bot_iff IsCompl.inf_left_eq_bot_iff

/- warning: is_compl.inf_right_eq_bot_iff -> IsCompl.inf_right_eq_bot_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : DistribLattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1)))))] {x : α} {y : α} {z : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))) _inst_2 y z) -> (Iff (Eq.{succ u1} α (HasInf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))) x z) (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))))) _inst_2)))) (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))))) x y))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : DistribLattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1)))))] {x : α} {y : α} {z : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))) _inst_2 y z) -> (Iff (Eq.{succ u1} α (HasInf.inf.{u1} α (Lattice.toHasInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1)) x z) (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))))) _inst_2)))) (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α _inst_1))))) x y))
Case conversion may be inaccurate. Consider using '#align is_compl.inf_right_eq_bot_iff IsCompl.inf_right_eq_bot_iffₓ'. -/
theorem inf_right_eq_bot_iff (h : IsCompl y z) : x ⊓ z = ⊥ ↔ x ≤ y :=
  h.symm.inf_left_eq_bot_iff
#align is_compl.inf_right_eq_bot_iff IsCompl.inf_right_eq_bot_iff

#print IsCompl.disjoint_left_iff /-
theorem disjoint_left_iff (h : IsCompl y z) : Disjoint x y ↔ x ≤ z :=
  by
  rw [disjoint_iff]
  exact h.inf_left_eq_bot_iff
#align is_compl.disjoint_left_iff IsCompl.disjoint_left_iff
-/

#print IsCompl.disjoint_right_iff /-
theorem disjoint_right_iff (h : IsCompl y z) : Disjoint x z ↔ x ≤ y :=
  h.symm.disjoint_left_iff
#align is_compl.disjoint_right_iff IsCompl.disjoint_right_iff
-/

#print IsCompl.le_left_iff /-
theorem le_left_iff (h : IsCompl x y) : z ≤ x ↔ Disjoint z y :=
  h.disjoint_right_iff.symm
#align is_compl.le_left_iff IsCompl.le_left_iff
-/

#print IsCompl.le_right_iff /-
theorem le_right_iff (h : IsCompl x y) : z ≤ y ↔ Disjoint z x :=
  h.symm.le_left_iff
#align is_compl.le_right_iff IsCompl.le_right_iff
-/

#print IsCompl.left_le_iff /-
theorem left_le_iff (h : IsCompl x y) : x ≤ z ↔ Codisjoint z y :=
  h.dual.le_left_iff
#align is_compl.left_le_iff IsCompl.left_le_iff
-/

#print IsCompl.right_le_iff /-
theorem right_le_iff (h : IsCompl x y) : y ≤ z ↔ Codisjoint z x :=
  h.symm.left_le_iff
#align is_compl.right_le_iff IsCompl.right_le_iff
-/

#print IsCompl.Antitone /-
protected theorem Antitone {x' y'} (h : IsCompl x y) (h' : IsCompl x' y') (hx : x ≤ x') : y' ≤ y :=
  h'.right_le_iff.2 <| h.symm.Codisjoint.mono_right hx
#align is_compl.antitone IsCompl.Antitone
-/

#print IsCompl.right_unique /-
theorem right_unique (hxy : IsCompl x y) (hxz : IsCompl x z) : y = z :=
  le_antisymm (hxz.Antitone hxy <| le_refl x) (hxy.Antitone hxz <| le_refl x)
#align is_compl.right_unique IsCompl.right_unique
-/

#print IsCompl.left_unique /-
theorem left_unique (hxz : IsCompl x z) (hyz : IsCompl y z) : x = y :=
  hxz.symm.RightUnique hyz.symm
#align is_compl.left_unique IsCompl.left_unique
-/

#print IsCompl.sup_inf /-
theorem sup_inf {x' y'} (h : IsCompl x y) (h' : IsCompl x' y') : IsCompl (x ⊔ x') (y ⊓ y') :=
  of_eq
    (by
      rw [inf_sup_right, ← inf_assoc, h.inf_eq_bot, bot_inf_eq, bot_sup_eq, inf_left_comm,
        h'.inf_eq_bot, inf_bot_eq])
    (by
      rw [sup_inf_left, @sup_comm _ _ x, sup_assoc, h.sup_eq_top, sup_top_eq, top_inf_eq, sup_assoc,
        sup_left_comm, h'.sup_eq_top, sup_top_eq])
#align is_compl.sup_inf IsCompl.sup_inf
-/

#print IsCompl.inf_sup /-
theorem inf_sup {x' y'} (h : IsCompl x y) (h' : IsCompl x' y') : IsCompl (x ⊓ x') (y ⊔ y') :=
  (h.symm.sup_inf h'.symm).symm
#align is_compl.inf_sup IsCompl.inf_sup
-/

end IsCompl

namespace Prod

variable {β : Type _} [PartialOrder α] [PartialOrder β]

/- warning: prod.disjoint_iff -> Prod.disjoint_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : PartialOrder.{u2} β] [_inst_3 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] [_inst_4 : OrderBot.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β _inst_2))] {x : Prod.{u1, u2} α β} {y : Prod.{u1, u2} α β}, Iff (Disjoint.{max u1 u2} (Prod.{u1, u2} α β) (Prod.partialOrder.{u1, u2} α β _inst_1 _inst_2) (Prod.orderBot.{u1, u2} α β (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β _inst_2)) _inst_3 _inst_4) x y) (And (Disjoint.{u1} α _inst_1 _inst_3 (Prod.fst.{u1, u2} α β x) (Prod.fst.{u1, u2} α β y)) (Disjoint.{u2} β _inst_2 _inst_4 (Prod.snd.{u1, u2} α β x) (Prod.snd.{u1, u2} α β y)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : PartialOrder.{u2} α] [_inst_2 : PartialOrder.{u1} β] [_inst_3 : OrderBot.{u2} α (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α _inst_1))] [_inst_4 : OrderBot.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β _inst_2))] {x : Prod.{u2, u1} α β} {y : Prod.{u2, u1} α β}, Iff (Disjoint.{max u2 u1} (Prod.{u2, u1} α β) (Prod.instPartialOrderProd.{u2, u1} α β _inst_1 _inst_2) (Prod.orderBot.{u2, u1} α β (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α _inst_1)) (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β _inst_2)) _inst_3 _inst_4) x y) (And (Disjoint.{u2} α _inst_1 _inst_3 (Prod.fst.{u2, u1} α β x) (Prod.fst.{u2, u1} α β y)) (Disjoint.{u1} β _inst_2 _inst_4 (Prod.snd.{u2, u1} α β x) (Prod.snd.{u2, u1} α β y)))
Case conversion may be inaccurate. Consider using '#align prod.disjoint_iff Prod.disjoint_iffₓ'. -/
protected theorem disjoint_iff [OrderBot α] [OrderBot β] {x y : α × β} :
    Disjoint x y ↔ Disjoint x.1 y.1 ∧ Disjoint x.2 y.2 :=
  by
  constructor
  · intro h
    refine'
      ⟨fun a hx hy => (@h (a, ⊥) ⟨hx, _⟩ ⟨hy, _⟩).1, fun b hx hy => (@h (⊥, b) ⟨_, hx⟩ ⟨_, hy⟩).2⟩
    all_goals exact bot_le
  · rintro ⟨ha, hb⟩ z hza hzb
    refine' ⟨ha hza.1 hzb.1, hb hza.2 hzb.2⟩
#align prod.disjoint_iff Prod.disjoint_iff

/- warning: prod.codisjoint_iff -> Prod.codisjoint_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : PartialOrder.{u2} β] [_inst_3 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] [_inst_4 : OrderTop.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β _inst_2))] {x : Prod.{u1, u2} α β} {y : Prod.{u1, u2} α β}, Iff (Codisjoint.{max u1 u2} (Prod.{u1, u2} α β) (Prod.partialOrder.{u1, u2} α β _inst_1 _inst_2) (Prod.orderTop.{u1, u2} α β (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β _inst_2)) _inst_3 _inst_4) x y) (And (Codisjoint.{u1} α _inst_1 _inst_3 (Prod.fst.{u1, u2} α β x) (Prod.fst.{u1, u2} α β y)) (Codisjoint.{u2} β _inst_2 _inst_4 (Prod.snd.{u1, u2} α β x) (Prod.snd.{u1, u2} α β y)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : PartialOrder.{u2} α] [_inst_2 : PartialOrder.{u1} β] [_inst_3 : OrderTop.{u2} α (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α _inst_1))] [_inst_4 : OrderTop.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β _inst_2))] {x : Prod.{u2, u1} α β} {y : Prod.{u2, u1} α β}, Iff (Codisjoint.{max u2 u1} (Prod.{u2, u1} α β) (Prod.instPartialOrderProd.{u2, u1} α β _inst_1 _inst_2) (Prod.orderTop.{u2, u1} α β (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α _inst_1)) (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β _inst_2)) _inst_3 _inst_4) x y) (And (Codisjoint.{u2} α _inst_1 _inst_3 (Prod.fst.{u2, u1} α β x) (Prod.fst.{u2, u1} α β y)) (Codisjoint.{u1} β _inst_2 _inst_4 (Prod.snd.{u2, u1} α β x) (Prod.snd.{u2, u1} α β y)))
Case conversion may be inaccurate. Consider using '#align prod.codisjoint_iff Prod.codisjoint_iffₓ'. -/
protected theorem codisjoint_iff [OrderTop α] [OrderTop β] {x y : α × β} :
    Codisjoint x y ↔ Codisjoint x.1 y.1 ∧ Codisjoint x.2 y.2 :=
  @Prod.disjoint_iff αᵒᵈ βᵒᵈ _ _ _ _ _ _
#align prod.codisjoint_iff Prod.codisjoint_iff

/- warning: prod.is_compl_iff -> Prod.isCompl_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : PartialOrder.{u1} α] [_inst_2 : PartialOrder.{u2} β] [_inst_3 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1))] [_inst_4 : BoundedOrder.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β _inst_2))] {x : Prod.{u1, u2} α β} {y : Prod.{u1, u2} α β}, Iff (IsCompl.{max u1 u2} (Prod.{u1, u2} α β) (Prod.partialOrder.{u1, u2} α β _inst_1 _inst_2) (Prod.boundedOrder.{u1, u2} α β (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α _inst_1)) (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β _inst_2)) _inst_3 _inst_4) x y) (And (IsCompl.{u1} α _inst_1 _inst_3 (Prod.fst.{u1, u2} α β x) (Prod.fst.{u1, u2} α β y)) (IsCompl.{u2} β _inst_2 _inst_4 (Prod.snd.{u1, u2} α β x) (Prod.snd.{u1, u2} α β y)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : PartialOrder.{u2} α] [_inst_2 : PartialOrder.{u1} β] [_inst_3 : BoundedOrder.{u2} α (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α _inst_1))] [_inst_4 : BoundedOrder.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β _inst_2))] {x : Prod.{u2, u1} α β} {y : Prod.{u2, u1} α β}, Iff (IsCompl.{max u2 u1} (Prod.{u2, u1} α β) (Prod.instPartialOrderProd.{u2, u1} α β _inst_1 _inst_2) (Prod.boundedOrder.{u2, u1} α β (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α _inst_1)) (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β _inst_2)) _inst_3 _inst_4) x y) (And (IsCompl.{u2} α _inst_1 _inst_3 (Prod.fst.{u2, u1} α β x) (Prod.fst.{u2, u1} α β y)) (IsCompl.{u1} β _inst_2 _inst_4 (Prod.snd.{u2, u1} α β x) (Prod.snd.{u2, u1} α β y)))
Case conversion may be inaccurate. Consider using '#align prod.is_compl_iff Prod.isCompl_iffₓ'. -/
protected theorem isCompl_iff [BoundedOrder α] [BoundedOrder β] {x y : α × β} :
    IsCompl x y ↔ IsCompl x.1 y.1 ∧ IsCompl x.2 y.2 := by
  simp_rw [isCompl_iff, Prod.disjoint_iff, Prod.codisjoint_iff, and_and_and_comm]
#align prod.is_compl_iff Prod.isCompl_iff

end Prod

section

variable [Lattice α] [BoundedOrder α] {a b x : α}

#print isCompl_toDual_iff /-
@[simp]
theorem isCompl_toDual_iff : IsCompl (toDual a) (toDual b) ↔ IsCompl a b :=
  ⟨IsCompl.ofDual, IsCompl.dual⟩
#align is_compl_to_dual_iff isCompl_toDual_iff
-/

#print isCompl_ofDual_iff /-
@[simp]
theorem isCompl_ofDual_iff {a b : αᵒᵈ} : IsCompl (ofDual a) (ofDual b) ↔ IsCompl a b :=
  ⟨IsCompl.dual, IsCompl.ofDual⟩
#align is_compl_of_dual_iff isCompl_ofDual_iff
-/

/- warning: is_compl_bot_top -> isCompl_bot_top is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))], IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))) (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))], IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))) (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2)))
Case conversion may be inaccurate. Consider using '#align is_compl_bot_top isCompl_bot_topₓ'. -/
theorem isCompl_bot_top : IsCompl (⊥ : α) ⊤ :=
  IsCompl.of_eq bot_inf_eq sup_top_eq
#align is_compl_bot_top isCompl_bot_top

/- warning: is_compl_top_bot -> isCompl_top_bot is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))], IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))) (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))], IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))) (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2)))
Case conversion may be inaccurate. Consider using '#align is_compl_top_bot isCompl_top_botₓ'. -/
theorem isCompl_top_bot : IsCompl (⊤ : α) ⊥ :=
  IsCompl.of_eq inf_bot_eq top_sup_eq
#align is_compl_top_bot isCompl_top_bot

/- warning: eq_top_of_is_compl_bot -> eq_top_of_isCompl_bot is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 x (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2)))) -> (Eq.{succ u1} α x (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 x (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2)))) -> (Eq.{succ u1} α x (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))))
Case conversion may be inaccurate. Consider using '#align eq_top_of_is_compl_bot eq_top_of_isCompl_botₓ'. -/
theorem eq_top_of_isCompl_bot (h : IsCompl x ⊥) : x = ⊤ :=
  sup_bot_eq.symm.trans h.sup_eq_top
#align eq_top_of_is_compl_bot eq_top_of_isCompl_bot

/- warning: eq_top_of_bot_is_compl -> eq_top_of_bot_isCompl is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))) x) -> (Eq.{succ u1} α x (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))) x) -> (Eq.{succ u1} α x (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))))
Case conversion may be inaccurate. Consider using '#align eq_top_of_bot_is_compl eq_top_of_bot_isComplₓ'. -/
theorem eq_top_of_bot_isCompl (h : IsCompl ⊥ x) : x = ⊤ :=
  eq_top_of_isCompl_bot h.symm
#align eq_top_of_bot_is_compl eq_top_of_bot_isCompl

/- warning: eq_bot_of_is_compl_top -> eq_bot_of_isCompl_top is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 x (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2)))) -> (Eq.{succ u1} α x (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 x (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2)))) -> (Eq.{succ u1} α x (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))))
Case conversion may be inaccurate. Consider using '#align eq_bot_of_is_compl_top eq_bot_of_isCompl_topₓ'. -/
theorem eq_bot_of_isCompl_top (h : IsCompl x ⊤) : x = ⊥ :=
  eq_top_of_isCompl_bot h.dual
#align eq_bot_of_is_compl_top eq_bot_of_isCompl_top

/- warning: eq_bot_of_top_is_compl -> eq_bot_of_top_isCompl is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 (Top.top.{u1} α (OrderTop.toHasTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))) x) -> (Eq.{succ u1} α x (Bot.bot.{u1} α (OrderBot.toHasBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Lattice.{u1} α] [_inst_2 : BoundedOrder.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1))))] {x : α}, (IsCompl.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)) _inst_2 (Top.top.{u1} α (OrderTop.toTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))) x) -> (Eq.{succ u1} α x (Bot.bot.{u1} α (OrderBot.toBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) (BoundedOrder.toOrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α _inst_1)))) _inst_2))))
Case conversion may be inaccurate. Consider using '#align eq_bot_of_top_is_compl eq_bot_of_top_isComplₓ'. -/
theorem eq_bot_of_top_isCompl (h : IsCompl ⊤ x) : x = ⊥ :=
  eq_top_of_bot_isCompl h.dual
#align eq_bot_of_top_is_compl eq_bot_of_top_isCompl

end

#print ComplementedLattice /-
/-- A complemented bounded lattice is one where every element has a (not necessarily unique)
complement. -/
class ComplementedLattice (α) [Lattice α] [BoundedOrder α] : Prop where
  exists_is_compl : ∀ a : α, ∃ b : α, IsCompl a b
#align complemented_lattice ComplementedLattice
-/

export ComplementedLattice (exists_is_compl)

namespace ComplementedLattice

variable [Lattice α] [BoundedOrder α] [ComplementedLattice α]

instance : ComplementedLattice αᵒᵈ :=
  ⟨fun a =>
    let ⟨b, hb⟩ := exists_is_compl (show α from a)
    ⟨b, hb.dual⟩⟩

end ComplementedLattice

end IsCompl

