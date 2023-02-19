/-
Copyright (c) 2018 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad

! This file was ported from Lean 3 source module topology.partial
! leanprover-community/mathlib commit e97cf15cd1aec9bd5c193b2ffac5a6dc9118912b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.ContinuousOn
import Mathbin.Order.Filter.Partial

/-!
# Partial functions and topological spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove properties of `filter.ptendsto` etc in topological spaces. We also introduce
`pcontinuous`, a version of `continuous` for partially defined functions.
-/


open Filter

open Topology

variable {α β : Type _} [TopologicalSpace α]

#print rtendsto_nhds /-
theorem rtendsto_nhds {r : Rel β α} {l : Filter β} {a : α} :
    Rtendsto r l (𝓝 a) ↔ ∀ s, IsOpen s → a ∈ s → r.Core s ∈ l :=
  all_mem_nhds_filter _ _ (fun s t => id) _
#align rtendsto_nhds rtendsto_nhds
-/

#print rtendsto'_nhds /-
theorem rtendsto'_nhds {r : Rel β α} {l : Filter β} {a : α} :
    Rtendsto' r l (𝓝 a) ↔ ∀ s, IsOpen s → a ∈ s → r.Preimage s ∈ l :=
  by
  rw [rtendsto'_def]
  apply all_mem_nhds_filter
  apply Rel.preimage_mono
#align rtendsto'_nhds rtendsto'_nhds
-/

#print ptendsto_nhds /-
theorem ptendsto_nhds {f : β →. α} {l : Filter β} {a : α} :
    Ptendsto f l (𝓝 a) ↔ ∀ s, IsOpen s → a ∈ s → f.Core s ∈ l :=
  rtendsto_nhds
#align ptendsto_nhds ptendsto_nhds
-/

#print ptendsto'_nhds /-
theorem ptendsto'_nhds {f : β →. α} {l : Filter β} {a : α} :
    Ptendsto' f l (𝓝 a) ↔ ∀ s, IsOpen s → a ∈ s → f.Preimage s ∈ l :=
  rtendsto'_nhds
#align ptendsto'_nhds ptendsto'_nhds
-/

/-! ### Continuity and partial functions -/


variable [TopologicalSpace β]

#print Pcontinuous /-
/-- Continuity of a partial function -/
def Pcontinuous (f : α →. β) :=
  ∀ s, IsOpen s → IsOpen (f.Preimage s)
#align pcontinuous Pcontinuous
-/

/- warning: open_dom_of_pcontinuous -> open_dom_of_pcontinuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : PFun.{u1, u2} α β}, (Pcontinuous.{u1, u2} α β _inst_1 _inst_2 f) -> (IsOpen.{u1} α _inst_1 (PFun.Dom.{u1, u2} α β f))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : PFun.{u2, u1} α β}, (Pcontinuous.{u2, u1} α β _inst_1 _inst_2 f) -> (IsOpen.{u2} α _inst_1 (PFun.Dom.{u2, u1} α β f))
Case conversion may be inaccurate. Consider using '#align open_dom_of_pcontinuous open_dom_of_pcontinuousₓ'. -/
theorem open_dom_of_pcontinuous {f : α →. β} (h : Pcontinuous f) : IsOpen f.Dom := by
  rw [← PFun.preimage_univ] <;> exact h _ isOpen_univ
#align open_dom_of_pcontinuous open_dom_of_pcontinuous

/- warning: pcontinuous_iff' -> pcontinuous_iff' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : PFun.{u1, u2} α β}, Iff (Pcontinuous.{u1, u2} α β _inst_1 _inst_2 f) (forall {x : α} {y : β}, (Membership.Mem.{u2, u2} β (Part.{u2} β) (Part.hasMem.{u2} β) y (f x)) -> (Filter.Ptendsto'.{u1, u2} α β f (nhds.{u1} α _inst_1 x) (nhds.{u2} β _inst_2 y)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : PFun.{u2, u1} α β}, Iff (Pcontinuous.{u2, u1} α β _inst_1 _inst_2 f) (forall {x : α} {y : β}, (Membership.mem.{u1, u1} β (Part.{u1} β) (Part.instMembershipPart.{u1} β) y (f x)) -> (Filter.Ptendsto'.{u2, u1} α β f (nhds.{u2} α _inst_1 x) (nhds.{u1} β _inst_2 y)))
Case conversion may be inaccurate. Consider using '#align pcontinuous_iff' pcontinuous_iff'ₓ'. -/
theorem pcontinuous_iff' {f : α →. β} :
    Pcontinuous f ↔ ∀ {x y} (h : y ∈ f x), Ptendsto' f (𝓝 x) (𝓝 y) :=
  by
  constructor
  · intro h x y h'
    simp only [ptendsto'_def, mem_nhds_iff]
    rintro s ⟨t, tsubs, opent, yt⟩
    exact ⟨f.preimage t, PFun.preimage_mono _ tsubs, h _ opent, ⟨y, yt, h'⟩⟩
  intro hf s os
  rw [isOpen_iff_nhds]
  rintro x ⟨y, ys, fxy⟩ t
  rw [mem_principal]
  intro (h : f.preimage s ⊆ t)
  change t ∈ 𝓝 x
  apply mem_of_superset _ h
  have h' : ∀ s ∈ 𝓝 y, f.preimage s ∈ 𝓝 x := by
    intro s hs
    have : ptendsto' f (𝓝 x) (𝓝 y) := hf fxy
    rw [ptendsto'_def] at this
    exact this s hs
  show f.preimage s ∈ 𝓝 x
  apply h'
  rw [mem_nhds_iff]
  exact ⟨s, Set.Subset.refl _, os, ys⟩
#align pcontinuous_iff' pcontinuous_iff'

/- warning: continuous_within_at_iff_ptendsto_res -> continuousWithinAt_iff_ptendsto_res is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] (f : α -> β) {x : α} {s : Set.{u1} α}, Iff (ContinuousWithinAt.{u1, u2} α β _inst_1 _inst_2 f s x) (Filter.Ptendsto.{u1, u2} α β (PFun.res.{u1, u2} α β f s) (nhds.{u1} α _inst_1 x) (nhds.{u2} β _inst_2 (f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] (f : α -> β) {x : α} {s : Set.{u2} α}, Iff (ContinuousWithinAt.{u2, u1} α β _inst_1 _inst_2 f s x) (Filter.Ptendsto.{u2, u1} α β (PFun.res.{u2, u1} α β f s) (nhds.{u2} α _inst_1 x) (nhds.{u1} β _inst_2 (f x)))
Case conversion may be inaccurate. Consider using '#align continuous_within_at_iff_ptendsto_res continuousWithinAt_iff_ptendsto_resₓ'. -/
theorem continuousWithinAt_iff_ptendsto_res (f : α → β) {x : α} {s : Set α} :
    ContinuousWithinAt f s x ↔ Ptendsto (PFun.res f s) (𝓝 x) (𝓝 (f x)) :=
  tendsto_iff_ptendsto _ _ _ _
#align continuous_within_at_iff_ptendsto_res continuousWithinAt_iff_ptendsto_res

