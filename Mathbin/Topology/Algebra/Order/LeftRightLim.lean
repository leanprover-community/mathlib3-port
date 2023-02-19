/-
Copyright (c) 2022 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module topology.algebra.order.left_right_lim
! leanprover-community/mathlib commit e97cf15cd1aec9bd5c193b2ffac5a6dc9118912b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Order.Basic
import Mathbin.Topology.Algebra.Order.LeftRight

/-!
# Left and right limits

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define the (strict) left and right limits of a function.

* `left_lim f x` is the strict left limit of `f` at `x` (using `f x` as a garbage value if `x`
  is isolated to its left).
* `right_lim f x` is the strict right limit of `f` at `x` (using `f x` as a garbage value if `x`
  is isolated to its right).

We develop a comprehensive API for monotone functions. Notably,

* `monotone.continuous_at_iff_left_lim_eq_right_lim` states that a monotone function is continuous
  at a point if and only if its left and right limits coincide.
* `monotone.countable_not_continuous_at` asserts that a monotone function taking values in a
  second-countable space has at most countably many discontinuity points.

We also port the API to antitone functions.

## TODO

Prove corresponding stronger results for strict_mono and strict_anti functions.
-/


open Set Filter

open Topology

section

variable {α β : Type _} [LinearOrder α] [TopologicalSpace β]

#print Function.leftLim /-
/-- Let `f : α → β` be a function from a linear order `α` to a topological_space `β`, and
let `a : α`. The limit strictly to the left of `f` at `a`, denoted with `left_lim f a`, is defined
by using the order topology on `α`. If `a` is isolated to its left or the function has no left
limit, we use `f a` instead to guarantee a good behavior in most cases. -/
noncomputable irreducible_def Function.leftLim (f : α → β) (a : α) : β := by
  classical
    haveI : Nonempty β := ⟨f a⟩
    letI : TopologicalSpace α := Preorder.topology α
    exact if 𝓝[<] a = ⊥ ∨ ¬∃ y, tendsto f (𝓝[<] a) (𝓝 y) then f a else limUnder (𝓝[<] a) f
#align function.left_lim Function.leftLim
-/

#print Function.rightLim /-
/-- Let `f : α → β` be a function from a linear order `α` to a topological_space `β`, and
let `a : α`. The limit strictly to the right of `f` at `a`, denoted with `right_lim f a`, is defined
by using the order topology on `α`. If `a` is isolated to its right or the function has no right
limit, , we use `f a` instead to guarantee a good behavior in most cases. -/
noncomputable def Function.rightLim (f : α → β) (a : α) : β :=
  @Function.leftLim αᵒᵈ β _ _ f a
#align function.right_lim Function.rightLim
-/

open Function

/- warning: left_lim_eq_of_tendsto -> leftLim_eq_of_tendsto is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [hα : TopologicalSpace.{u1} α] [h'α : OrderTopology.{u1} α hα (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))] [_inst_3 : T2Space.{u2} β _inst_2] {f : α -> β} {a : α} {y : β}, (Ne.{succ u1} (Filter.{u1} α) (nhdsWithin.{u1} α hα a (Set.Iio.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) a)) (Bot.bot.{u1} (Filter.{u1} α) (CompleteLattice.toHasBot.{u1} (Filter.{u1} α) (Filter.completeLattice.{u1} α)))) -> (Filter.Tendsto.{u1, u2} α β f (nhdsWithin.{u1} α hα a (Set.Iio.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) a)) (nhds.{u2} β _inst_2 y)) -> (Eq.{succ u2} β (Function.leftLim.{u1, u2} α β _inst_1 _inst_2 f a) y)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] [hα : TopologicalSpace.{u2} α] [h'α : OrderTopology.{u2} α hα (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))] [_inst_3 : T2Space.{u1} β _inst_2] {f : α -> β} {a : α} {y : β}, (Ne.{succ u2} (Filter.{u2} α) (nhdsWithin.{u2} α hα a (Set.Iio.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) a)) (Bot.bot.{u2} (Filter.{u2} α) (CompleteLattice.toBot.{u2} (Filter.{u2} α) (Filter.instCompleteLatticeFilter.{u2} α)))) -> (Filter.Tendsto.{u2, u1} α β f (nhdsWithin.{u2} α hα a (Set.Iio.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) a)) (nhds.{u1} β _inst_2 y)) -> (Eq.{succ u1} β (Function.leftLim.{u2, u1} α β _inst_1 _inst_2 f a) y)
Case conversion may be inaccurate. Consider using '#align left_lim_eq_of_tendsto leftLim_eq_of_tendstoₓ'. -/
theorem leftLim_eq_of_tendsto [hα : TopologicalSpace α] [h'α : OrderTopology α] [T2Space β]
    {f : α → β} {a : α} {y : β} (h : 𝓝[<] a ≠ ⊥) (h' : Tendsto f (𝓝[<] a) (𝓝 y)) :
    leftLim f a = y := by
  have h'' : ∃ y, tendsto f (𝓝[<] a) (𝓝 y) := ⟨y, h'⟩
  rw [h'α.topology_eq_generate_intervals] at h h' h''
  simp only [left_lim, h, h'', not_true, or_self_iff, if_false]
  haveI := ne_bot_iff.2 h
  exact h'.lim_eq
#align left_lim_eq_of_tendsto leftLim_eq_of_tendsto

/- warning: left_lim_eq_of_eq_bot -> leftLim_eq_of_eq_bot is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [hα : TopologicalSpace.{u1} α] [h'α : OrderTopology.{u1} α hα (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))] (f : α -> β) {a : α}, (Eq.{succ u1} (Filter.{u1} α) (nhdsWithin.{u1} α hα a (Set.Iio.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) a)) (Bot.bot.{u1} (Filter.{u1} α) (CompleteLattice.toHasBot.{u1} (Filter.{u1} α) (Filter.completeLattice.{u1} α)))) -> (Eq.{succ u2} β (Function.leftLim.{u1, u2} α β _inst_1 _inst_2 f a) (f a))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] [hα : TopologicalSpace.{u2} α] [h'α : OrderTopology.{u2} α hα (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))] (f : α -> β) {a : α}, (Eq.{succ u2} (Filter.{u2} α) (nhdsWithin.{u2} α hα a (Set.Iio.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) a)) (Bot.bot.{u2} (Filter.{u2} α) (CompleteLattice.toBot.{u2} (Filter.{u2} α) (Filter.instCompleteLatticeFilter.{u2} α)))) -> (Eq.{succ u1} β (Function.leftLim.{u2, u1} α β _inst_1 _inst_2 f a) (f a))
Case conversion may be inaccurate. Consider using '#align left_lim_eq_of_eq_bot leftLim_eq_of_eq_botₓ'. -/
theorem leftLim_eq_of_eq_bot [hα : TopologicalSpace α] [h'α : OrderTopology α] (f : α → β) {a : α}
    (h : 𝓝[<] a = ⊥) : leftLim f a = f a :=
  by
  rw [h'α.topology_eq_generate_intervals] at h
  simp [left_lim, ite_eq_left_iff, h]
#align left_lim_eq_of_eq_bot leftLim_eq_of_eq_bot

end

open Function

namespace Monotone

variable {α β : Type _} [LinearOrder α] [ConditionallyCompleteLinearOrder β] [TopologicalSpace β]
  [OrderTopology β] {f : α → β} (hf : Monotone f) {x y : α}

include hf

/- warning: monotone.left_lim_eq_Sup -> Monotone.leftLim_eq_supₛ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))], (Ne.{succ u1} (Filter.{u1} α) (nhdsWithin.{u1} α _inst_5 x (Set.Iio.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x)) (Bot.bot.{u1} (Filter.{u1} α) (CompleteLattice.toHasBot.{u1} (Filter.{u1} α) (Filter.completeLattice.{u1} α)))) -> (Eq.{succ u2} β (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f x) (SupSet.supₛ.{u2} β (ConditionallyCompleteLattice.toHasSup.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)) (Set.image.{u1, u2} α β f (Set.Iio.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x)))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))], (Ne.{succ u2} (Filter.{u2} α) (nhdsWithin.{u2} α _inst_5 x (Set.Iio.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x)) (Bot.bot.{u2} (Filter.{u2} α) (CompleteLattice.toBot.{u2} (Filter.{u2} α) (Filter.instCompleteLatticeFilter.{u2} α)))) -> (Eq.{succ u1} β (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f x) (SupSet.supₛ.{u1} β (ConditionallyCompleteLattice.toSupSet.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)) (Set.image.{u2, u1} α β f (Set.Iio.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x)))))
Case conversion may be inaccurate. Consider using '#align monotone.left_lim_eq_Sup Monotone.leftLim_eq_supₛₓ'. -/
theorem leftLim_eq_supₛ [TopologicalSpace α] [OrderTopology α] (h : 𝓝[<] x ≠ ⊥) :
    leftLim f x = supₛ (f '' Iio x) :=
  leftLim_eq_of_tendsto h (hf.tendsto_nhdsWithin_Iio x)
#align monotone.left_lim_eq_Sup Monotone.leftLim_eq_supₛ

/- warning: monotone.left_lim_le -> Monotone.leftLim_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))) x y) -> (LE.le.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))) (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f x) (f y)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LE.le.{u2} α (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))) x y) -> (LE.le.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))) (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f x) (f y)))
Case conversion may be inaccurate. Consider using '#align monotone.left_lim_le Monotone.leftLim_leₓ'. -/
theorem leftLim_le (h : x ≤ y) : leftLim f x ≤ f y :=
  by
  letI : TopologicalSpace α := Preorder.topology α
  haveI : OrderTopology α := ⟨rfl⟩
  rcases eq_or_ne (𝓝[<] x) ⊥ with (h' | h')
  · simpa [left_lim, h'] using hf h
  haveI A : ne_bot (𝓝[<] x) := ne_bot_iff.2 h'
  rw [left_lim_eq_Sup hf h']
  refine' csupₛ_le _ _
  · simp only [nonempty_image_iff]
    exact (forall_mem_nonempty_iff_ne_bot.2 A) _ self_mem_nhdsWithin
  · simp only [mem_image, mem_Iio, forall_exists_index, and_imp, forall_apply_eq_imp_iff₂]
    intro z hz
    exact hf (hz.le.trans h)
#align monotone.left_lim_le Monotone.leftLim_le

/- warning: monotone.le_left_lim -> Monotone.le_leftLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))) x y) -> (LE.le.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))) (f x) (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f y)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LT.lt.{u2} α (Preorder.toLT.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))) x y) -> (LE.le.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))) (f x) (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f y)))
Case conversion may be inaccurate. Consider using '#align monotone.le_left_lim Monotone.le_leftLimₓ'. -/
theorem le_leftLim (h : x < y) : f x ≤ leftLim f y :=
  by
  letI : TopologicalSpace α := Preorder.topology α
  haveI : OrderTopology α := ⟨rfl⟩
  rcases eq_or_ne (𝓝[<] y) ⊥ with (h' | h')
  · rw [leftLim_eq_of_eq_bot _ h']
    exact hf h.le
  rw [left_lim_eq_Sup hf h']
  refine' le_csupₛ ⟨f y, _⟩ (mem_image_of_mem _ h)
  simp only [upperBounds, mem_image, mem_Iio, forall_exists_index, and_imp,
    forall_apply_eq_imp_iff₂, mem_set_of_eq]
  intro z hz
  exact hf hz.le
#align monotone.le_left_lim Monotone.le_leftLim

/- warning: monotone.left_lim -> Monotone.leftLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f))
Case conversion may be inaccurate. Consider using '#align monotone.left_lim Monotone.leftLimₓ'. -/
@[mono]
protected theorem leftLim : Monotone (leftLim f) :=
  by
  intro x y h
  rcases eq_or_lt_of_le h with (rfl | hxy)
  · exact le_rfl
  · exact (hf.left_lim_le le_rfl).trans (hf.le_left_lim hxy)
#align monotone.left_lim Monotone.leftLim

/- warning: monotone.le_right_lim -> Monotone.le_rightLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))) x y) -> (LE.le.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))) (f x) (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f y)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LE.le.{u2} α (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))) x y) -> (LE.le.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))) (f x) (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f y)))
Case conversion may be inaccurate. Consider using '#align monotone.le_right_lim Monotone.le_rightLimₓ'. -/
theorem le_rightLim (h : x ≤ y) : f x ≤ rightLim f y :=
  hf.dual.leftLim_le h
#align monotone.le_right_lim Monotone.le_rightLim

/- warning: monotone.right_lim_le -> Monotone.rightLim_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))) x y) -> (LE.le.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))) (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f x) (f y)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LT.lt.{u2} α (Preorder.toLT.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))) x y) -> (LE.le.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))) (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f x) (f y)))
Case conversion may be inaccurate. Consider using '#align monotone.right_lim_le Monotone.rightLim_leₓ'. -/
theorem rightLim_le (h : x < y) : rightLim f x ≤ f y :=
  hf.dual.le_leftLim h
#align monotone.right_lim_le Monotone.rightLim_le

/- warning: monotone.right_lim -> Monotone.rightLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f))
Case conversion may be inaccurate. Consider using '#align monotone.right_lim Monotone.rightLimₓ'. -/
@[mono]
protected theorem rightLim : Monotone (rightLim f) := fun x y h => hf.dual.leftLim h
#align monotone.right_lim Monotone.rightLim

/- warning: monotone.left_lim_le_right_lim -> Monotone.leftLim_le_rightLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))) x y) -> (LE.le.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))) (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f x) (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f y)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LE.le.{u2} α (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))) x y) -> (LE.le.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))) (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f x) (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f y)))
Case conversion may be inaccurate. Consider using '#align monotone.left_lim_le_right_lim Monotone.leftLim_le_rightLimₓ'. -/
theorem leftLim_le_rightLim (h : x ≤ y) : leftLim f x ≤ rightLim f y :=
  (hf.leftLim_le le_rfl).trans (hf.le_rightLim h)
#align monotone.left_lim_le_right_lim Monotone.leftLim_le_rightLim

/- warning: monotone.right_lim_le_left_lim -> Monotone.rightLim_le_leftLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))) x y) -> (LE.le.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))) (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f x) (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f y)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LT.lt.{u2} α (Preorder.toLT.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))) x y) -> (LE.le.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))) (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f x) (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f y)))
Case conversion may be inaccurate. Consider using '#align monotone.right_lim_le_left_lim Monotone.rightLim_le_leftLimₓ'. -/
theorem rightLim_le_leftLim (h : x < y) : rightLim f x ≤ leftLim f y :=
  by
  letI : TopologicalSpace α := Preorder.topology α
  haveI : OrderTopology α := ⟨rfl⟩
  rcases eq_or_ne (𝓝[<] y) ⊥ with (h' | h')
  · simp [left_lim, h']
    exact right_lim_le hf h
  obtain ⟨a, ⟨xa, ay⟩⟩ : (Ioo x y).Nonempty :=
    forall_mem_nonempty_iff_ne_bot.2 (ne_bot_iff.2 h') (Ioo x y)
      (Ioo_mem_nhdsWithin_Iio ⟨h, le_refl _⟩)
  calc
    right_lim f x ≤ f a := hf.right_lim_le xa
    _ ≤ left_lim f y := hf.le_left_lim ay
    
#align monotone.right_lim_le_left_lim Monotone.rightLim_le_leftLim

variable [TopologicalSpace α] [OrderTopology α]

/- warning: monotone.tendsto_left_lim -> Monotone.tendsto_leftLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))] (x : α), Filter.Tendsto.{u1, u2} α β f (nhdsWithin.{u1} α _inst_5 x (Set.Iio.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x)) (nhds.{u2} β _inst_3 (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))] (x : α), Filter.Tendsto.{u2, u1} α β f (nhdsWithin.{u2} α _inst_5 x (Set.Iio.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x)) (nhds.{u1} β _inst_3 (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f x)))
Case conversion may be inaccurate. Consider using '#align monotone.tendsto_left_lim Monotone.tendsto_leftLimₓ'. -/
theorem tendsto_leftLim (x : α) : Tendsto f (𝓝[<] x) (𝓝 (leftLim f x)) :=
  by
  rcases eq_or_ne (𝓝[<] x) ⊥ with (h' | h')
  · simp [h']
  rw [left_lim_eq_Sup hf h']
  exact hf.tendsto_nhds_within_Iio x
#align monotone.tendsto_left_lim Monotone.tendsto_leftLim

/- warning: monotone.tendsto_left_lim_within -> Monotone.tendsto_leftLim_within is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))] (x : α), Filter.Tendsto.{u1, u2} α β f (nhdsWithin.{u1} α _inst_5 x (Set.Iio.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x)) (nhdsWithin.{u2} β _inst_3 (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f x) (Set.Iic.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f x))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))] (x : α), Filter.Tendsto.{u2, u1} α β f (nhdsWithin.{u2} α _inst_5 x (Set.Iio.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x)) (nhdsWithin.{u1} β _inst_3 (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f x) (Set.Iic.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f x))))
Case conversion may be inaccurate. Consider using '#align monotone.tendsto_left_lim_within Monotone.tendsto_leftLim_withinₓ'. -/
theorem tendsto_leftLim_within (x : α) : Tendsto f (𝓝[<] x) (𝓝[≤] leftLim f x) :=
  by
  apply tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within f (hf.tendsto_left_lim x)
  filter_upwards [self_mem_nhdsWithin]with y hy using hf.le_left_lim hy
#align monotone.tendsto_left_lim_within Monotone.tendsto_leftLim_within

/- warning: monotone.tendsto_right_lim -> Monotone.tendsto_rightLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))] (x : α), Filter.Tendsto.{u1, u2} α β f (nhdsWithin.{u1} α _inst_5 x (Set.Ioi.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x)) (nhds.{u2} β _inst_3 (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))] (x : α), Filter.Tendsto.{u2, u1} α β f (nhdsWithin.{u2} α _inst_5 x (Set.Ioi.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x)) (nhds.{u1} β _inst_3 (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f x)))
Case conversion may be inaccurate. Consider using '#align monotone.tendsto_right_lim Monotone.tendsto_rightLimₓ'. -/
theorem tendsto_rightLim (x : α) : Tendsto f (𝓝[>] x) (𝓝 (rightLim f x)) :=
  hf.dual.tendsto_leftLim x
#align monotone.tendsto_right_lim Monotone.tendsto_rightLim

/- warning: monotone.tendsto_right_lim_within -> Monotone.tendsto_rightLim_within is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))] (x : α), Filter.Tendsto.{u1, u2} α β f (nhdsWithin.{u1} α _inst_5 x (Set.Ioi.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x)) (nhdsWithin.{u2} β _inst_3 (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f x) (Set.Ici.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f x))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))] (x : α), Filter.Tendsto.{u2, u1} α β f (nhdsWithin.{u2} α _inst_5 x (Set.Ioi.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x)) (nhdsWithin.{u1} β _inst_3 (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f x) (Set.Ici.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f x))))
Case conversion may be inaccurate. Consider using '#align monotone.tendsto_right_lim_within Monotone.tendsto_rightLim_withinₓ'. -/
theorem tendsto_rightLim_within (x : α) : Tendsto f (𝓝[>] x) (𝓝[≥] rightLim f x) :=
  hf.dual.tendsto_leftLim_within x
#align monotone.tendsto_right_lim_within Monotone.tendsto_rightLim_within

/- warning: monotone.continuous_within_at_Iio_iff_left_lim_eq -> Monotone.continuousWithinAt_Iio_iff_leftLim_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))], Iff (ContinuousWithinAt.{u1, u2} α β _inst_5 _inst_3 f (Set.Iio.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x) x) (Eq.{succ u2} β (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f x) (f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))], Iff (ContinuousWithinAt.{u2, u1} α β _inst_5 _inst_3 f (Set.Iio.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x) x) (Eq.{succ u1} β (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f x) (f x)))
Case conversion may be inaccurate. Consider using '#align monotone.continuous_within_at_Iio_iff_left_lim_eq Monotone.continuousWithinAt_Iio_iff_leftLim_eqₓ'. -/
/-- A monotone function is continuous to the left at a point if and only if its left limit
coincides with the value of the function. -/
theorem continuousWithinAt_Iio_iff_leftLim_eq :
    ContinuousWithinAt f (Iio x) x ↔ leftLim f x = f x :=
  by
  rcases eq_or_ne (𝓝[<] x) ⊥ with (h' | h')
  · simp [leftLim_eq_of_eq_bot f h', ContinuousWithinAt, h']
  haveI : (𝓝[Iio x] x).ne_bot := ne_bot_iff.2 h'
  refine' ⟨fun h => tendsto_nhds_unique (hf.tendsto_left_lim x) h.Tendsto, fun h => _⟩
  have := hf.tendsto_left_lim x
  rwa [h] at this
#align monotone.continuous_within_at_Iio_iff_left_lim_eq Monotone.continuousWithinAt_Iio_iff_leftLim_eq

/- warning: monotone.continuous_within_at_Ioi_iff_right_lim_eq -> Monotone.continuousWithinAt_Ioi_iff_rightLim_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))], Iff (ContinuousWithinAt.{u1, u2} α β _inst_5 _inst_3 f (Set.Ioi.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x) x) (Eq.{succ u2} β (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f x) (f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))], Iff (ContinuousWithinAt.{u2, u1} α β _inst_5 _inst_3 f (Set.Ioi.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x) x) (Eq.{succ u1} β (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f x) (f x)))
Case conversion may be inaccurate. Consider using '#align monotone.continuous_within_at_Ioi_iff_right_lim_eq Monotone.continuousWithinAt_Ioi_iff_rightLim_eqₓ'. -/
/-- A monotone function is continuous to the right at a point if and only if its right limit
coincides with the value of the function. -/
theorem continuousWithinAt_Ioi_iff_rightLim_eq :
    ContinuousWithinAt f (Ioi x) x ↔ rightLim f x = f x :=
  hf.dual.continuousWithinAt_Iio_iff_leftLim_eq
#align monotone.continuous_within_at_Ioi_iff_right_lim_eq Monotone.continuousWithinAt_Ioi_iff_rightLim_eq

/- warning: monotone.continuous_at_iff_left_lim_eq_right_lim -> Monotone.continuousAt_iff_leftLim_eq_rightLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))], Iff (ContinuousAt.{u1, u2} α β _inst_5 _inst_3 f x) (Eq.{succ u2} β (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f x) (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))], Iff (ContinuousAt.{u2, u1} α β _inst_5 _inst_3 f x) (Eq.{succ u1} β (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f x) (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f x)))
Case conversion may be inaccurate. Consider using '#align monotone.continuous_at_iff_left_lim_eq_right_lim Monotone.continuousAt_iff_leftLim_eq_rightLimₓ'. -/
/-- A monotone function is continuous at a point if and only if its left and right limits
coincide. -/
theorem continuousAt_iff_leftLim_eq_rightLim : ContinuousAt f x ↔ leftLim f x = rightLim f x :=
  by
  refine' ⟨fun h => _, fun h => _⟩
  · have A : left_lim f x = f x :=
      hf.continuous_within_at_Iio_iff_left_lim_eq.1 h.continuous_within_at
    have B : right_lim f x = f x :=
      hf.continuous_within_at_Ioi_iff_right_lim_eq.1 h.continuous_within_at
    exact A.trans B.symm
  · have h' : left_lim f x = f x :=
      by
      apply le_antisymm (left_lim_le hf (le_refl _))
      rw [h]
      exact le_right_lim hf (le_refl _)
    refine' continuousAt_iff_continuous_left'_right'.2 ⟨_, _⟩
    · exact hf.continuous_within_at_Iio_iff_left_lim_eq.2 h'
    · rw [h] at h'
      exact hf.continuous_within_at_Ioi_iff_right_lim_eq.2 h'
#align monotone.continuous_at_iff_left_lim_eq_right_lim Monotone.continuousAt_iff_leftLim_eq_rightLim

#print Monotone.countable_not_continuousWithinAt_Ioi /-
/-- In a second countable space, the set of points where a monotone function is not right-continuous
is at most countable. Superseded by `countable_not_continuous_at` which gives the two-sided
version. -/
theorem countable_not_continuousWithinAt_Ioi [TopologicalSpace.SecondCountableTopology β] :
    Set.Countable { x | ¬ContinuousWithinAt f (Ioi x) x } :=
  by
  /- If `f` is not continuous on the right at `x`, there is an interval `(f x, z x)` which is not
    reached by `f`. This gives a family of disjoint open intervals in `β`. Such a family can only
    be countable as `β` is second-countable. -/
  nontriviality α
  let s := { x | ¬ContinuousWithinAt f (Ioi x) x }
  have : ∀ x, x ∈ s → ∃ z, f x < z ∧ ∀ y, x < y → z ≤ f y :=
    by
    rintro x (hx : ¬ContinuousWithinAt f (Ioi x) x)
    contrapose! hx
    refine' tendsto_order.2 ⟨fun m hm => _, fun u hu => _⟩
    · filter_upwards [self_mem_nhdsWithin]with y hy using hm.trans_le (hf (le_of_lt hy))
    rcases hx u hu with ⟨v, xv, fvu⟩
    have : Ioo x v ∈ 𝓝[>] x := Ioo_mem_nhdsWithin_Ioi ⟨le_refl _, xv⟩
    filter_upwards [this]with y hy
    apply (hf hy.2.le).trans_lt fvu
  -- choose `z x` such that `f` does not take the values in `(f x, z x)`.
  choose! z hz using this
  have I : inj_on f s := by
    apply StrictMonoOn.injOn
    intro x hx y hy hxy
    calc
      f x < z x := (hz x hx).1
      _ ≤ f y := (hz x hx).2 y hxy
      
  -- show that `f s` is countable by arguing that a disjoint family of disjoint open intervals
  -- (the intervals `(f x, z x)`) is at most countable.
  have fs_count : (f '' s).Countable :=
    by
    have A : (f '' s).PairwiseDisjoint fun x => Ioo x (z (inv_fun_on f s x)) :=
      by
      rintro _ ⟨u, us, rfl⟩ _ ⟨v, vs, rfl⟩ huv
      wlog hle : u ≤ v generalizing u v
      · exact (this v vs u us huv.symm (le_of_not_le hle)).symm
      have hlt : u < v := hle.lt_of_ne (ne_of_apply_ne _ huv)
      apply disjoint_iff_forall_ne.2
      rintro a ha b hb rfl
      simp only [I.left_inv_on_inv_fun_on us, I.left_inv_on_inv_fun_on vs] at ha hb
      exact lt_irrefl _ ((ha.2.trans_le ((hz u us).2 v hlt)).trans hb.1)
    apply Set.PairwiseDisjoint.countable_of_Ioo A
    rintro _ ⟨y, ys, rfl⟩
    simpa only [I.left_inv_on_inv_fun_on ys] using (hz y ys).1
  exact maps_to.countable_of_inj_on (maps_to_image f s) I fs_count
#align monotone.countable_not_continuous_within_at_Ioi Monotone.countable_not_continuousWithinAt_Ioi
-/

#print Monotone.countable_not_continuousWithinAt_Iio /-
/-- In a second countable space, the set of points where a monotone function is not left-continuous
is at most countable. Superseded by `countable_not_continuous_at` which gives the two-sided
version. -/
theorem countable_not_continuousWithinAt_Iio [TopologicalSpace.SecondCountableTopology β] :
    Set.Countable { x | ¬ContinuousWithinAt f (Iio x) x } :=
  hf.dual.countable_not_continuousWithinAt_Ioi
#align monotone.countable_not_continuous_within_at_Iio Monotone.countable_not_continuousWithinAt_Iio
-/

#print Monotone.countable_not_continuousAt /-
/-- In a second countable space, the set of points where a monotone function is not continuous
is at most countable. -/
theorem countable_not_continuousAt [TopologicalSpace.SecondCountableTopology β] :
    Set.Countable { x | ¬ContinuousAt f x } :=
  by
  apply
    (hf.countable_not_continuous_within_at_Ioi.union hf.countable_not_continuous_within_at_Iio).mono
      _
  refine' compl_subset_compl.1 _
  simp only [compl_union]
  rintro x ⟨hx, h'x⟩
  simp only [mem_set_of_eq, Classical.not_not, mem_compl_iff] at hx h'x⊢
  exact continuousAt_iff_continuous_left'_right'.2 ⟨h'x, hx⟩
#align monotone.countable_not_continuous_at Monotone.countable_not_continuousAt
-/

end Monotone

namespace Antitone

variable {α β : Type _} [LinearOrder α] [ConditionallyCompleteLinearOrder β] [TopologicalSpace β]
  [OrderTopology β] {f : α → β} (hf : Antitone f) {x y : α}

include hf

/- warning: antitone.le_left_lim -> Antitone.le_leftLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))) x y) -> (LE.le.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))) (f y) (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LE.le.{u2} α (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))) x y) -> (LE.le.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))) (f y) (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f x)))
Case conversion may be inaccurate. Consider using '#align antitone.le_left_lim Antitone.le_leftLimₓ'. -/
theorem le_leftLim (h : x ≤ y) : f y ≤ leftLim f x :=
  hf.dual_right.leftLim_le h
#align antitone.le_left_lim Antitone.le_leftLim

/- warning: antitone.left_lim_le -> Antitone.leftLim_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))) x y) -> (LE.le.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))) (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f y) (f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LT.lt.{u2} α (Preorder.toLT.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))) x y) -> (LE.le.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))) (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f y) (f x)))
Case conversion may be inaccurate. Consider using '#align antitone.left_lim_le Antitone.leftLim_leₓ'. -/
theorem leftLim_le (h : x < y) : leftLim f y ≤ f x :=
  hf.dual_right.le_leftLim h
#align antitone.left_lim_le Antitone.leftLim_le

/- warning: antitone.left_lim -> Antitone.leftLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f))
Case conversion may be inaccurate. Consider using '#align antitone.left_lim Antitone.leftLimₓ'. -/
@[mono]
protected theorem leftLim : Antitone (leftLim f) :=
  hf.dual_right.leftLim
#align antitone.left_lim Antitone.leftLim

/- warning: antitone.right_lim_le -> Antitone.rightLim_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))) x y) -> (LE.le.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))) (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f y) (f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LE.le.{u2} α (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))) x y) -> (LE.le.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))) (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f y) (f x)))
Case conversion may be inaccurate. Consider using '#align antitone.right_lim_le Antitone.rightLim_leₓ'. -/
theorem rightLim_le (h : x ≤ y) : rightLim f y ≤ f x :=
  hf.dual_right.le_rightLim h
#align antitone.right_lim_le Antitone.rightLim_le

/- warning: antitone.le_right_lim -> Antitone.le_rightLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))) x y) -> (LE.le.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))) (f y) (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LT.lt.{u2} α (Preorder.toLT.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))) x y) -> (LE.le.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))) (f y) (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f x)))
Case conversion may be inaccurate. Consider using '#align antitone.le_right_lim Antitone.le_rightLimₓ'. -/
theorem le_rightLim (h : x < y) : f y ≤ rightLim f x :=
  hf.dual_right.rightLim_le h
#align antitone.le_right_lim Antitone.le_rightLim

/- warning: antitone.right_lim -> Antitone.rightLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f))
Case conversion may be inaccurate. Consider using '#align antitone.right_lim Antitone.rightLimₓ'. -/
@[mono]
protected theorem rightLim : Antitone (rightLim f) :=
  hf.dual_right.rightLim
#align antitone.right_lim Antitone.rightLim

/- warning: antitone.right_lim_le_left_lim -> Antitone.rightLim_le_leftLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))) x y) -> (LE.le.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))) (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f y) (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LE.le.{u2} α (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))) x y) -> (LE.le.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))) (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f y) (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f x)))
Case conversion may be inaccurate. Consider using '#align antitone.right_lim_le_left_lim Antitone.rightLim_le_leftLimₓ'. -/
theorem rightLim_le_leftLim (h : x ≤ y) : rightLim f y ≤ leftLim f x :=
  hf.dual_right.leftLim_le_rightLim h
#align antitone.right_lim_le_left_lim Antitone.rightLim_le_leftLim

/- warning: antitone.left_lim_le_right_lim -> Antitone.leftLim_le_rightLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))) x y) -> (LE.le.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))) (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f y) (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} {y : α}, (LT.lt.{u2} α (Preorder.toLT.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))) x y) -> (LE.le.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))) (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f y) (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f x)))
Case conversion may be inaccurate. Consider using '#align antitone.left_lim_le_right_lim Antitone.leftLim_le_rightLimₓ'. -/
theorem leftLim_le_rightLim (h : x < y) : leftLim f y ≤ rightLim f x :=
  hf.dual_right.rightLim_le_leftLim h
#align antitone.left_lim_le_right_lim Antitone.leftLim_le_rightLim

variable [TopologicalSpace α] [OrderTopology α]

/- warning: antitone.tendsto_left_lim -> Antitone.tendsto_leftLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))] (x : α), Filter.Tendsto.{u1, u2} α β f (nhdsWithin.{u1} α _inst_5 x (Set.Iio.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x)) (nhds.{u2} β _inst_3 (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))] (x : α), Filter.Tendsto.{u2, u1} α β f (nhdsWithin.{u2} α _inst_5 x (Set.Iio.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x)) (nhds.{u1} β _inst_3 (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f x)))
Case conversion may be inaccurate. Consider using '#align antitone.tendsto_left_lim Antitone.tendsto_leftLimₓ'. -/
theorem tendsto_leftLim (x : α) : Tendsto f (𝓝[<] x) (𝓝 (leftLim f x)) :=
  hf.dual_right.tendsto_leftLim x
#align antitone.tendsto_left_lim Antitone.tendsto_leftLim

/- warning: antitone.tendsto_left_lim_within -> Antitone.tendsto_leftLim_within is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))] (x : α), Filter.Tendsto.{u1, u2} α β f (nhdsWithin.{u1} α _inst_5 x (Set.Iio.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x)) (nhdsWithin.{u2} β _inst_3 (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f x) (Set.Ici.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f x))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))] (x : α), Filter.Tendsto.{u2, u1} α β f (nhdsWithin.{u2} α _inst_5 x (Set.Iio.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x)) (nhdsWithin.{u1} β _inst_3 (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f x) (Set.Ici.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f x))))
Case conversion may be inaccurate. Consider using '#align antitone.tendsto_left_lim_within Antitone.tendsto_leftLim_withinₓ'. -/
theorem tendsto_leftLim_within (x : α) : Tendsto f (𝓝[<] x) (𝓝[≥] leftLim f x) :=
  hf.dual_right.tendsto_leftLim_within x
#align antitone.tendsto_left_lim_within Antitone.tendsto_leftLim_within

/- warning: antitone.tendsto_right_lim -> Antitone.tendsto_rightLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))] (x : α), Filter.Tendsto.{u1, u2} α β f (nhdsWithin.{u1} α _inst_5 x (Set.Ioi.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x)) (nhds.{u2} β _inst_3 (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))] (x : α), Filter.Tendsto.{u2, u1} α β f (nhdsWithin.{u2} α _inst_5 x (Set.Ioi.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x)) (nhds.{u1} β _inst_3 (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f x)))
Case conversion may be inaccurate. Consider using '#align antitone.tendsto_right_lim Antitone.tendsto_rightLimₓ'. -/
theorem tendsto_rightLim (x : α) : Tendsto f (𝓝[>] x) (𝓝 (rightLim f x)) :=
  hf.dual_right.tendsto_rightLim x
#align antitone.tendsto_right_lim Antitone.tendsto_rightLim

/- warning: antitone.tendsto_right_lim_within -> Antitone.tendsto_rightLim_within is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))] (x : α), Filter.Tendsto.{u1, u2} α β f (nhdsWithin.{u1} α _inst_5 x (Set.Ioi.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x)) (nhdsWithin.{u2} β _inst_3 (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f x) (Set.Iic.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f x))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))] (x : α), Filter.Tendsto.{u2, u1} α β f (nhdsWithin.{u2} α _inst_5 x (Set.Ioi.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x)) (nhdsWithin.{u1} β _inst_3 (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f x) (Set.Iic.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f x))))
Case conversion may be inaccurate. Consider using '#align antitone.tendsto_right_lim_within Antitone.tendsto_rightLim_withinₓ'. -/
theorem tendsto_rightLim_within (x : α) : Tendsto f (𝓝[>] x) (𝓝[≤] rightLim f x) :=
  hf.dual_right.tendsto_rightLim_within x
#align antitone.tendsto_right_lim_within Antitone.tendsto_rightLim_within

/- warning: antitone.continuous_within_at_Iio_iff_left_lim_eq -> Antitone.continuousWithinAt_Iio_iff_leftLim_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))], Iff (ContinuousWithinAt.{u1, u2} α β _inst_5 _inst_3 f (Set.Iio.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x) x) (Eq.{succ u2} β (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f x) (f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))], Iff (ContinuousWithinAt.{u2, u1} α β _inst_5 _inst_3 f (Set.Iio.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x) x) (Eq.{succ u1} β (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f x) (f x)))
Case conversion may be inaccurate. Consider using '#align antitone.continuous_within_at_Iio_iff_left_lim_eq Antitone.continuousWithinAt_Iio_iff_leftLim_eqₓ'. -/
/-- An antitone function is continuous to the left at a point if and only if its left limit
coincides with the value of the function. -/
theorem continuousWithinAt_Iio_iff_leftLim_eq :
    ContinuousWithinAt f (Iio x) x ↔ leftLim f x = f x :=
  hf.dual_right.continuousWithinAt_Iio_iff_leftLim_eq
#align antitone.continuous_within_at_Iio_iff_left_lim_eq Antitone.continuousWithinAt_Iio_iff_leftLim_eq

/- warning: antitone.continuous_within_at_Ioi_iff_right_lim_eq -> Antitone.continuousWithinAt_Ioi_iff_rightLim_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))], Iff (ContinuousWithinAt.{u1, u2} α β _inst_5 _inst_3 f (Set.Ioi.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x) x) (Eq.{succ u2} β (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f x) (f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))], Iff (ContinuousWithinAt.{u2, u1} α β _inst_5 _inst_3 f (Set.Ioi.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x) x) (Eq.{succ u1} β (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f x) (f x)))
Case conversion may be inaccurate. Consider using '#align antitone.continuous_within_at_Ioi_iff_right_lim_eq Antitone.continuousWithinAt_Ioi_iff_rightLim_eqₓ'. -/
/-- An antitone function is continuous to the right at a point if and only if its right limit
coincides with the value of the function. -/
theorem continuousWithinAt_Ioi_iff_rightLim_eq :
    ContinuousWithinAt f (Ioi x) x ↔ rightLim f x = f x :=
  hf.dual_right.continuousWithinAt_Ioi_iff_rightLim_eq
#align antitone.continuous_within_at_Ioi_iff_right_lim_eq Antitone.continuousWithinAt_Ioi_iff_rightLim_eq

/- warning: antitone.continuous_at_iff_left_lim_eq_right_lim -> Antitone.continuousAt_iff_leftLim_eq_rightLim is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_3 : TopologicalSpace.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_3 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2)))))] {f : α -> β}, (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_2))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))], Iff (ContinuousAt.{u1, u2} α β _inst_5 _inst_3 f x) (Eq.{succ u2} β (Function.leftLim.{u1, u2} α β _inst_1 _inst_3 f x) (Function.rightLim.{u1, u2} α β _inst_1 _inst_3 f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_3 : TopologicalSpace.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_3 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2)))))] {f : α -> β}, (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_2))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))], Iff (ContinuousAt.{u2, u1} α β _inst_5 _inst_3 f x) (Eq.{succ u1} β (Function.leftLim.{u2, u1} α β _inst_1 _inst_3 f x) (Function.rightLim.{u2, u1} α β _inst_1 _inst_3 f x)))
Case conversion may be inaccurate. Consider using '#align antitone.continuous_at_iff_left_lim_eq_right_lim Antitone.continuousAt_iff_leftLim_eq_rightLimₓ'. -/
/-- An antitone function is continuous at a point if and only if its left and right limits
coincide. -/
theorem continuousAt_iff_leftLim_eq_rightLim : ContinuousAt f x ↔ leftLim f x = rightLim f x :=
  hf.dual_right.continuousAt_iff_leftLim_eq_rightLim
#align antitone.continuous_at_iff_left_lim_eq_right_lim Antitone.continuousAt_iff_leftLim_eq_rightLim

#print Antitone.countable_not_continuousAt /-
/-- In a second countable space, the set of points where an antitone function is not continuous
is at most countable. -/
theorem countable_not_continuousAt [TopologicalSpace.SecondCountableTopology β] :
    Set.Countable { x | ¬ContinuousAt f x } :=
  hf.dual_right.countable_not_continuousAt
#align antitone.countable_not_continuous_at Antitone.countable_not_continuousAt
-/

end Antitone

