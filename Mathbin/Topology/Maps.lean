/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro, Patrick Massot

! This file was ported from Lean 3 source module topology.maps
! leanprover-community/mathlib commit 369525b73f229ccd76a6ec0e0e0bf2be57599768
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Order
import Mathbin.Topology.NhdsSet

/-!
# Specific classes of maps between topological spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file introduces the following properties of a map `f : X → Y` between topological spaces:

* `is_open_map f` means the image of an open set under `f` is open.
* `is_closed_map f` means the image of a closed set under `f` is closed.

(Open and closed maps need not be continuous.)

* `inducing f` means the topology on `X` is the one induced via `f` from the topology on `Y`.
  These behave like embeddings except they need not be injective. Instead, points of `X` which
  are identified by `f` are also inseparable in the topology on `X`.
* `embedding f` means `f` is inducing and also injective. Equivalently, `f` identifies `X` with
  a subspace of `Y`.
* `open_embedding f` means `f` is an embedding with open image, so it identifies `X` with an
  open subspace of `Y`. Equivalently, `f` is an embedding and an open map.
* `closed_embedding f` similarly means `f` is an embedding with closed image, so it identifies
  `X` with a closed subspace of `Y`. Equivalently, `f` is an embedding and a closed map.

* `quotient_map f` is the dual condition to `embedding f`: `f` is surjective and the topology
  on `Y` is the one coinduced via `f` from the topology on `X`. Equivalently, `f` identifies
  `Y` with a quotient of `X`. Quotient maps are also sometimes known as identification maps.

## References

* <https://en.wikipedia.org/wiki/Open_and_closed_maps>
* <https://en.wikipedia.org/wiki/Embedding#General_topology>
* <https://en.wikipedia.org/wiki/Quotient_space_(topology)#Quotient_map>

## Tags

open map, closed map, embedding, quotient map, identification map

-/


open Set Filter Function

open Topology Filter

variable {α : Type _} {β : Type _} {γ : Type _} {δ : Type _}

section Inducing

#print Inducing /-
/-- A function `f : α → β` between topological spaces is inducing if the topology on `α` is induced
by the topology on `β` through `f`, meaning that a set `s : set α` is open iff it is the preimage
under `f` of some open set `t : set β`. -/
@[mk_iff]
structure Inducing [tα : TopologicalSpace α] [tβ : TopologicalSpace β] (f : α → β) : Prop where
  induced : tα = tβ.induced f
#align inducing Inducing
-/

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ] [TopologicalSpace δ]

#print inducing_id /-
theorem inducing_id : Inducing (@id α) :=
  ⟨induced_id.symm⟩
#align inducing_id inducing_id
-/

/- warning: inducing.comp -> Inducing.comp is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {g : β -> γ} {f : α -> β}, (Inducing.{u2, u3} β γ _inst_2 _inst_3 g) -> (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (Inducing.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u3} β] [_inst_3 : TopologicalSpace.{u2} γ] {g : β -> γ} {f : α -> β}, (Inducing.{u3, u2} β γ _inst_2 _inst_3 g) -> (Inducing.{u1, u3} α β _inst_1 _inst_2 f) -> (Inducing.{u1, u2} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u3, succ u2} α β γ g f))
Case conversion may be inaccurate. Consider using '#align inducing.comp Inducing.compₓ'. -/
protected theorem Inducing.comp {g : β → γ} {f : α → β} (hg : Inducing g) (hf : Inducing f) :
    Inducing (g ∘ f) :=
  ⟨by rw [hf.induced, hg.induced, induced_compose]⟩
#align inducing.comp Inducing.comp

/- warning: inducing_of_inducing_compose -> inducing_of_inducing_compose is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {f : α -> β} {g : β -> γ}, (Continuous.{u1, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u3} β γ _inst_2 _inst_3 g) -> (Inducing.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f)) -> (Inducing.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u3}} {β : Type.{u2}} {γ : Type.{u1}} [_inst_1 : TopologicalSpace.{u3} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u1} γ] {f : α -> β} {g : β -> γ}, (Continuous.{u3, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u1} β γ _inst_2 _inst_3 g) -> (Inducing.{u3, u1} α γ _inst_1 _inst_3 (Function.comp.{succ u3, succ u2, succ u1} α β γ g f)) -> (Inducing.{u3, u2} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align inducing_of_inducing_compose inducing_of_inducing_composeₓ'. -/
theorem inducing_of_inducing_compose {f : α → β} {g : β → γ} (hf : Continuous f) (hg : Continuous g)
    (hgf : Inducing (g ∘ f)) : Inducing f :=
  ⟨le_antisymm (by rwa [← continuous_iff_le_induced])
      (by
        rw [hgf.induced, ← continuous_iff_le_induced]
        apply hg.comp continuous_induced_dom)⟩
#align inducing_of_inducing_compose inducing_of_inducing_compose

/- warning: inducing_iff_nhds -> inducing_iff_nhds is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, Iff (Inducing.{u1, u2} α β _inst_1 _inst_2 f) (forall (a : α), Eq.{succ u1} (Filter.{u1} α) (nhds.{u1} α _inst_1 a) (Filter.comap.{u1, u2} α β f (nhds.{u2} β _inst_2 (f a))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, Iff (Inducing.{u2, u1} α β _inst_1 _inst_2 f) (forall (a : α), Eq.{succ u2} (Filter.{u2} α) (nhds.{u2} α _inst_1 a) (Filter.comap.{u2, u1} α β f (nhds.{u1} β _inst_2 (f a))))
Case conversion may be inaccurate. Consider using '#align inducing_iff_nhds inducing_iff_nhdsₓ'. -/
theorem inducing_iff_nhds {f : α → β} : Inducing f ↔ ∀ a, 𝓝 a = comap f (𝓝 (f a)) :=
  (inducing_iff _).trans (induced_iff_nhds_eq f)
#align inducing_iff_nhds inducing_iff_nhds

/- warning: inducing.nhds_eq_comap -> Inducing.nhds_eq_comap is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (a : α), Eq.{succ u1} (Filter.{u1} α) (nhds.{u1} α _inst_1 a) (Filter.comap.{u1, u2} α β f (nhds.{u2} β _inst_2 (f a))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Inducing.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (a : α), Eq.{succ u2} (Filter.{u2} α) (nhds.{u2} α _inst_1 a) (Filter.comap.{u2, u1} α β f (nhds.{u1} β _inst_2 (f a))))
Case conversion may be inaccurate. Consider using '#align inducing.nhds_eq_comap Inducing.nhds_eq_comapₓ'. -/
theorem Inducing.nhds_eq_comap {f : α → β} (hf : Inducing f) : ∀ a : α, 𝓝 a = comap f (𝓝 <| f a) :=
  inducing_iff_nhds.1 hf
#align inducing.nhds_eq_comap Inducing.nhds_eq_comap

/- warning: inducing.nhds_set_eq_comap -> Inducing.nhdsSet_eq_comap is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u1} α), Eq.{succ u1} (Filter.{u1} α) (nhdsSet.{u1} α _inst_1 s) (Filter.comap.{u1, u2} α β f (nhdsSet.{u2} β _inst_2 (Set.image.{u1, u2} α β f s))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Inducing.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u2} α), Eq.{succ u2} (Filter.{u2} α) (nhdsSet.{u2} α _inst_1 s) (Filter.comap.{u2, u1} α β f (nhdsSet.{u1} β _inst_2 (Set.image.{u2, u1} α β f s))))
Case conversion may be inaccurate. Consider using '#align inducing.nhds_set_eq_comap Inducing.nhdsSet_eq_comapₓ'. -/
theorem Inducing.nhdsSet_eq_comap {f : α → β} (hf : Inducing f) (s : Set α) :
    𝓝ˢ s = comap f (𝓝ˢ (f '' s)) := by
  simp only [nhdsSet, supₛ_image, comap_supr, hf.nhds_eq_comap, supᵢ_image]
#align inducing.nhds_set_eq_comap Inducing.nhdsSet_eq_comap

/- warning: inducing.map_nhds_eq -> Inducing.map_nhds_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (a : α), Eq.{succ u2} (Filter.{u2} β) (Filter.map.{u1, u2} α β f (nhds.{u1} α _inst_1 a)) (nhdsWithin.{u2} β _inst_2 (f a) (Set.range.{u2, succ u1} β α f)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Inducing.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (a : α), Eq.{succ u1} (Filter.{u1} β) (Filter.map.{u2, u1} α β f (nhds.{u2} α _inst_1 a)) (nhdsWithin.{u1} β _inst_2 (f a) (Set.range.{u1, succ u2} β α f)))
Case conversion may be inaccurate. Consider using '#align inducing.map_nhds_eq Inducing.map_nhds_eqₓ'. -/
theorem Inducing.map_nhds_eq {f : α → β} (hf : Inducing f) (a : α) : (𝓝 a).map f = 𝓝[range f] f a :=
  hf.induced.symm ▸ map_nhds_induced_eq a
#align inducing.map_nhds_eq Inducing.map_nhds_eq

/- warning: inducing.map_nhds_of_mem -> Inducing.map_nhds_of_mem is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (a : α), (Membership.Mem.{u2, u2} (Set.{u2} β) (Filter.{u2} β) (Filter.hasMem.{u2} β) (Set.range.{u2, succ u1} β α f) (nhds.{u2} β _inst_2 (f a))) -> (Eq.{succ u2} (Filter.{u2} β) (Filter.map.{u1, u2} α β f (nhds.{u1} α _inst_1 a)) (nhds.{u2} β _inst_2 (f a))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Inducing.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (a : α), (Membership.mem.{u1, u1} (Set.{u1} β) (Filter.{u1} β) (instMembershipSetFilter.{u1} β) (Set.range.{u1, succ u2} β α f) (nhds.{u1} β _inst_2 (f a))) -> (Eq.{succ u1} (Filter.{u1} β) (Filter.map.{u2, u1} α β f (nhds.{u2} α _inst_1 a)) (nhds.{u1} β _inst_2 (f a))))
Case conversion may be inaccurate. Consider using '#align inducing.map_nhds_of_mem Inducing.map_nhds_of_memₓ'. -/
theorem Inducing.map_nhds_of_mem {f : α → β} (hf : Inducing f) (a : α) (h : range f ∈ 𝓝 (f a)) :
    (𝓝 a).map f = 𝓝 (f a) :=
  hf.induced.symm ▸ map_nhds_induced_of_mem h
#align inducing.map_nhds_of_mem Inducing.map_nhds_of_mem

/- warning: inducing.image_mem_nhds_within -> Inducing.image_mem_nhdsWithin is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {a : α} {s : Set.{u1} α}, (Membership.Mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (Filter.hasMem.{u1} α) s (nhds.{u1} α _inst_1 a)) -> (Membership.Mem.{u2, u2} (Set.{u2} β) (Filter.{u2} β) (Filter.hasMem.{u2} β) (Set.image.{u1, u2} α β f s) (nhdsWithin.{u2} β _inst_2 (f a) (Set.range.{u2, succ u1} β α f))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Inducing.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {a : α} {s : Set.{u2} α}, (Membership.mem.{u2, u2} (Set.{u2} α) (Filter.{u2} α) (instMembershipSetFilter.{u2} α) s (nhds.{u2} α _inst_1 a)) -> (Membership.mem.{u1, u1} (Set.{u1} β) (Filter.{u1} β) (instMembershipSetFilter.{u1} β) (Set.image.{u2, u1} α β f s) (nhdsWithin.{u1} β _inst_2 (f a) (Set.range.{u1, succ u2} β α f))))
Case conversion may be inaccurate. Consider using '#align inducing.image_mem_nhds_within Inducing.image_mem_nhdsWithinₓ'. -/
theorem Inducing.image_mem_nhdsWithin {f : α → β} (hf : Inducing f) {a : α} {s : Set α}
    (hs : s ∈ 𝓝 a) : f '' s ∈ 𝓝[range f] f a :=
  hf.map_nhds_eq a ▸ image_mem_map hs
#align inducing.image_mem_nhds_within Inducing.image_mem_nhdsWithin

/- warning: inducing.tendsto_nhds_iff -> Inducing.tendsto_nhds_iff is a dubious translation:
lean 3 declaration is
  forall {β : Type.{u1}} {γ : Type.{u2}} [_inst_2 : TopologicalSpace.{u1} β] [_inst_3 : TopologicalSpace.{u2} γ] {ι : Type.{u3}} {f : ι -> β} {g : β -> γ} {a : Filter.{u3} ι} {b : β}, (Inducing.{u1, u2} β γ _inst_2 _inst_3 g) -> (Iff (Filter.Tendsto.{u3, u1} ι β f a (nhds.{u1} β _inst_2 b)) (Filter.Tendsto.{u3, u2} ι γ (Function.comp.{succ u3, succ u1, succ u2} ι β γ g f) a (nhds.{u2} γ _inst_3 (g b))))
but is expected to have type
  forall {β : Type.{u2}} {γ : Type.{u1}} [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u1} γ] {ι : Type.{u3}} {f : ι -> β} {g : β -> γ} {a : Filter.{u3} ι} {b : β}, (Inducing.{u2, u1} β γ _inst_2 _inst_3 g) -> (Iff (Filter.Tendsto.{u3, u2} ι β f a (nhds.{u2} β _inst_2 b)) (Filter.Tendsto.{u3, u1} ι γ (Function.comp.{succ u3, succ u2, succ u1} ι β γ g f) a (nhds.{u1} γ _inst_3 (g b))))
Case conversion may be inaccurate. Consider using '#align inducing.tendsto_nhds_iff Inducing.tendsto_nhds_iffₓ'. -/
theorem Inducing.tendsto_nhds_iff {ι : Type _} {f : ι → β} {g : β → γ} {a : Filter ι} {b : β}
    (hg : Inducing g) : Tendsto f a (𝓝 b) ↔ Tendsto (g ∘ f) a (𝓝 (g b)) := by
  rw [hg.nhds_eq_comap, tendsto_comap_iff]
#align inducing.tendsto_nhds_iff Inducing.tendsto_nhds_iff

/- warning: inducing.continuous_at_iff -> Inducing.continuousAt_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {f : α -> β} {g : β -> γ}, (Inducing.{u2, u3} β γ _inst_2 _inst_3 g) -> (forall {x : α}, Iff (ContinuousAt.{u1, u2} α β _inst_1 _inst_2 f x) (ContinuousAt.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f) x))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u3} β] [_inst_3 : TopologicalSpace.{u2} γ] {f : α -> β} {g : β -> γ}, (Inducing.{u3, u2} β γ _inst_2 _inst_3 g) -> (forall {x : α}, Iff (ContinuousAt.{u1, u3} α β _inst_1 _inst_2 f x) (ContinuousAt.{u1, u2} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u3, succ u2} α β γ g f) x))
Case conversion may be inaccurate. Consider using '#align inducing.continuous_at_iff Inducing.continuousAt_iffₓ'. -/
theorem Inducing.continuousAt_iff {f : α → β} {g : β → γ} (hg : Inducing g) {x : α} :
    ContinuousAt f x ↔ ContinuousAt (g ∘ f) x := by
  simp_rw [ContinuousAt, Inducing.tendsto_nhds_iff hg]
#align inducing.continuous_at_iff Inducing.continuousAt_iff

/- warning: inducing.continuous_iff -> Inducing.continuous_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {f : α -> β} {g : β -> γ}, (Inducing.{u2, u3} β γ _inst_2 _inst_3 g) -> (Iff (Continuous.{u1, u2} α β _inst_1 _inst_2 f) (Continuous.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f)))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u3} β] [_inst_3 : TopologicalSpace.{u2} γ] {f : α -> β} {g : β -> γ}, (Inducing.{u3, u2} β γ _inst_2 _inst_3 g) -> (Iff (Continuous.{u1, u3} α β _inst_1 _inst_2 f) (Continuous.{u1, u2} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u3, succ u2} α β γ g f)))
Case conversion may be inaccurate. Consider using '#align inducing.continuous_iff Inducing.continuous_iffₓ'. -/
theorem Inducing.continuous_iff {f : α → β} {g : β → γ} (hg : Inducing g) :
    Continuous f ↔ Continuous (g ∘ f) := by
  simp_rw [continuous_iff_continuousAt, hg.continuous_at_iff]
#align inducing.continuous_iff Inducing.continuous_iff

/- warning: inducing.continuous_at_iff' -> Inducing.continuousAt_iff' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {f : α -> β} {g : β -> γ}, (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {x : α}, (Membership.Mem.{u2, u2} (Set.{u2} β) (Filter.{u2} β) (Filter.hasMem.{u2} β) (Set.range.{u2, succ u1} β α f) (nhds.{u2} β _inst_2 (f x))) -> (Iff (ContinuousAt.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f) x) (ContinuousAt.{u2, u3} β γ _inst_2 _inst_3 g (f x))))
but is expected to have type
  forall {α : Type.{u3}} {β : Type.{u2}} {γ : Type.{u1}} [_inst_1 : TopologicalSpace.{u3} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u1} γ] {f : α -> β} {g : β -> γ}, (Inducing.{u3, u2} α β _inst_1 _inst_2 f) -> (forall {x : α}, (Membership.mem.{u2, u2} (Set.{u2} β) (Filter.{u2} β) (instMembershipSetFilter.{u2} β) (Set.range.{u2, succ u3} β α f) (nhds.{u2} β _inst_2 (f x))) -> (Iff (ContinuousAt.{u3, u1} α γ _inst_1 _inst_3 (Function.comp.{succ u3, succ u2, succ u1} α β γ g f) x) (ContinuousAt.{u2, u1} β γ _inst_2 _inst_3 g (f x))))
Case conversion may be inaccurate. Consider using '#align inducing.continuous_at_iff' Inducing.continuousAt_iff'ₓ'. -/
theorem Inducing.continuousAt_iff' {f : α → β} {g : β → γ} (hf : Inducing f) {x : α}
    (h : range f ∈ 𝓝 (f x)) : ContinuousAt (g ∘ f) x ↔ ContinuousAt g (f x) := by
  simp_rw [ContinuousAt, Filter.Tendsto, ← hf.map_nhds_of_mem _ h, Filter.map_map]
#align inducing.continuous_at_iff' Inducing.continuousAt_iff'

/- warning: inducing.continuous -> Inducing.continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Inducing.{u2, u1} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align inducing.continuous Inducing.continuousₓ'. -/
protected theorem Inducing.continuous {f : α → β} (hf : Inducing f) : Continuous f :=
  hf.continuous_iff.mp continuous_id
#align inducing.continuous Inducing.continuous

/- warning: inducing.inducing_iff -> Inducing.inducing_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {f : α -> β} {g : β -> γ}, (Inducing.{u2, u3} β γ _inst_2 _inst_3 g) -> (Iff (Inducing.{u1, u2} α β _inst_1 _inst_2 f) (Inducing.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f)))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u3} β] [_inst_3 : TopologicalSpace.{u2} γ] {f : α -> β} {g : β -> γ}, (Inducing.{u3, u2} β γ _inst_2 _inst_3 g) -> (Iff (Inducing.{u1, u3} α β _inst_1 _inst_2 f) (Inducing.{u1, u2} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u3, succ u2} α β γ g f)))
Case conversion may be inaccurate. Consider using '#align inducing.inducing_iff Inducing.inducing_iffₓ'. -/
protected theorem Inducing.inducing_iff {f : α → β} {g : β → γ} (hg : Inducing g) :
    Inducing f ↔ Inducing (g ∘ f) :=
  by
  refine' ⟨fun h => hg.comp h, fun hgf => inducing_of_inducing_compose _ hg.continuous hgf⟩
  rw [hg.continuous_iff]
  exact hgf.continuous
#align inducing.inducing_iff Inducing.inducing_iff

/- warning: inducing.closure_eq_preimage_closure_image -> Inducing.closure_eq_preimage_closure_image is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u1} α), Eq.{succ u1} (Set.{u1} α) (closure.{u1} α _inst_1 s) (Set.preimage.{u1, u2} α β f (closure.{u2} β _inst_2 (Set.image.{u1, u2} α β f s))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Inducing.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u2} α), Eq.{succ u2} (Set.{u2} α) (closure.{u2} α _inst_1 s) (Set.preimage.{u2, u1} α β f (closure.{u1} β _inst_2 (Set.image.{u2, u1} α β f s))))
Case conversion may be inaccurate. Consider using '#align inducing.closure_eq_preimage_closure_image Inducing.closure_eq_preimage_closure_imageₓ'. -/
theorem Inducing.closure_eq_preimage_closure_image {f : α → β} (hf : Inducing f) (s : Set α) :
    closure s = f ⁻¹' closure (f '' s) := by
  ext x
  rw [Set.mem_preimage, ← closure_induced, hf.induced]
#align inducing.closure_eq_preimage_closure_image Inducing.closure_eq_preimage_closure_image

/- warning: inducing.is_closed_iff -> Inducing.isClosed_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u1} α}, Iff (IsClosed.{u1} α _inst_1 s) (Exists.{succ u2} (Set.{u2} β) (fun (t : Set.{u2} β) => And (IsClosed.{u2} β _inst_2 t) (Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β f t) s))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Inducing.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u2} α}, Iff (IsClosed.{u2} α _inst_1 s) (Exists.{succ u1} (Set.{u1} β) (fun (t : Set.{u1} β) => And (IsClosed.{u1} β _inst_2 t) (Eq.{succ u2} (Set.{u2} α) (Set.preimage.{u2, u1} α β f t) s))))
Case conversion may be inaccurate. Consider using '#align inducing.is_closed_iff Inducing.isClosed_iffₓ'. -/
theorem Inducing.isClosed_iff {f : α → β} (hf : Inducing f) {s : Set α} :
    IsClosed s ↔ ∃ t, IsClosed t ∧ f ⁻¹' t = s := by rw [hf.induced, isClosed_induced_iff]
#align inducing.is_closed_iff Inducing.isClosed_iff

/- warning: inducing.is_closed_iff' -> Inducing.isClosed_iff' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u1} α}, Iff (IsClosed.{u1} α _inst_1 s) (forall (x : α), (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) (f x) (closure.{u2} β _inst_2 (Set.image.{u1, u2} α β f s))) -> (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Inducing.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u2} α}, Iff (IsClosed.{u2} α _inst_1 s) (forall (x : α), (Membership.mem.{u1, u1} β (Set.{u1} β) (Set.instMembershipSet.{u1} β) (f x) (closure.{u1} β _inst_2 (Set.image.{u2, u1} α β f s))) -> (Membership.mem.{u2, u2} α (Set.{u2} α) (Set.instMembershipSet.{u2} α) x s)))
Case conversion may be inaccurate. Consider using '#align inducing.is_closed_iff' Inducing.isClosed_iff'ₓ'. -/
theorem Inducing.isClosed_iff' {f : α → β} (hf : Inducing f) {s : Set α} :
    IsClosed s ↔ ∀ x, f x ∈ closure (f '' s) → x ∈ s := by rw [hf.induced, isClosed_induced_iff']
#align inducing.is_closed_iff' Inducing.isClosed_iff'

/- warning: inducing.is_closed_preimage -> Inducing.isClosed_preimage is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u2} β), (IsClosed.{u2} β _inst_2 s) -> (IsClosed.{u1} α _inst_1 (Set.preimage.{u1, u2} α β f s)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Inducing.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u1} β), (IsClosed.{u1} β _inst_2 s) -> (IsClosed.{u2} α _inst_1 (Set.preimage.{u2, u1} α β f s)))
Case conversion may be inaccurate. Consider using '#align inducing.is_closed_preimage Inducing.isClosed_preimageₓ'. -/
theorem Inducing.isClosed_preimage {f : α → β} (h : Inducing f) (s : Set β) (hs : IsClosed s) :
    IsClosed (f ⁻¹' s) :=
  (Inducing.isClosed_iff h).mpr ⟨s, hs, rfl⟩
#align inducing.is_closed_preimage Inducing.isClosed_preimage

/- warning: inducing.is_open_iff -> Inducing.isOpen_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u1} α}, Iff (IsOpen.{u1} α _inst_1 s) (Exists.{succ u2} (Set.{u2} β) (fun (t : Set.{u2} β) => And (IsOpen.{u2} β _inst_2 t) (Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β f t) s))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Inducing.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u2} α}, Iff (IsOpen.{u2} α _inst_1 s) (Exists.{succ u1} (Set.{u1} β) (fun (t : Set.{u1} β) => And (IsOpen.{u1} β _inst_2 t) (Eq.{succ u2} (Set.{u2} α) (Set.preimage.{u2, u1} α β f t) s))))
Case conversion may be inaccurate. Consider using '#align inducing.is_open_iff Inducing.isOpen_iffₓ'. -/
theorem Inducing.isOpen_iff {f : α → β} (hf : Inducing f) {s : Set α} :
    IsOpen s ↔ ∃ t, IsOpen t ∧ f ⁻¹' t = s := by rw [hf.induced, isOpen_induced_iff]
#align inducing.is_open_iff Inducing.isOpen_iff

/- warning: inducing.dense_iff -> Inducing.dense_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u1} α}, Iff (Dense.{u1} α _inst_1 s) (forall (x : α), Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) (f x) (closure.{u2} β _inst_2 (Set.image.{u1, u2} α β f s))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Inducing.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u2} α}, Iff (Dense.{u2} α _inst_1 s) (forall (x : α), Membership.mem.{u1, u1} β (Set.{u1} β) (Set.instMembershipSet.{u1} β) (f x) (closure.{u1} β _inst_2 (Set.image.{u2, u1} α β f s))))
Case conversion may be inaccurate. Consider using '#align inducing.dense_iff Inducing.dense_iffₓ'. -/
theorem Inducing.dense_iff {f : α → β} (hf : Inducing f) {s : Set α} :
    Dense s ↔ ∀ x, f x ∈ closure (f '' s) := by
  simp only [Dense, hf.closure_eq_preimage_closure_image, mem_preimage]
#align inducing.dense_iff Inducing.dense_iff

end Inducing

section Embedding

#print Embedding /-
/-- A function between topological spaces is an embedding if it is injective,
  and for all `s : set α`, `s` is open iff it is the preimage of an open set. -/
@[mk_iff]
structure Embedding [tα : TopologicalSpace α] [tβ : TopologicalSpace β] (f : α → β) extends
  Inducing f : Prop where
  inj : Injective f
#align embedding Embedding
-/

#print Function.Injective.embedding_induced /-
theorem Function.Injective.embedding_induced [t : TopologicalSpace β] {f : α → β}
    (hf : Injective f) : @Embedding α β (t.induced f) t f :=
  { induced := rfl
    inj := hf }
#align function.injective.embedding_induced Function.Injective.embedding_induced
-/

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ]

/- warning: embedding.mk' -> Embedding.mk' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] (f : α -> β), (Function.Injective.{succ u1, succ u2} α β f) -> (forall (a : α), Eq.{succ u1} (Filter.{u1} α) (Filter.comap.{u1, u2} α β f (nhds.{u2} β _inst_2 (f a))) (nhds.{u1} α _inst_1 a)) -> (Embedding.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] (f : α -> β), (Function.Injective.{succ u2, succ u1} α β f) -> (forall (a : α), Eq.{succ u2} (Filter.{u2} α) (Filter.comap.{u2, u1} α β f (nhds.{u1} β _inst_2 (f a))) (nhds.{u2} α _inst_1 a)) -> (Embedding.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align embedding.mk' Embedding.mk'ₓ'. -/
theorem Embedding.mk' (f : α → β) (inj : Injective f) (induced : ∀ a, comap f (𝓝 (f a)) = 𝓝 a) :
    Embedding f :=
  ⟨inducing_iff_nhds.2 fun a => (induced a).symm, inj⟩
#align embedding.mk' Embedding.mk'

#print embedding_id /-
theorem embedding_id : Embedding (@id α) :=
  ⟨inducing_id, fun a₁ a₂ h => h⟩
#align embedding_id embedding_id
-/

/- warning: embedding.comp -> Embedding.comp is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {g : β -> γ} {f : α -> β}, (Embedding.{u2, u3} β γ _inst_2 _inst_3 g) -> (Embedding.{u1, u2} α β _inst_1 _inst_2 f) -> (Embedding.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u3} β] [_inst_3 : TopologicalSpace.{u2} γ] {g : β -> γ} {f : α -> β}, (Embedding.{u3, u2} β γ _inst_2 _inst_3 g) -> (Embedding.{u1, u3} α β _inst_1 _inst_2 f) -> (Embedding.{u1, u2} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u3, succ u2} α β γ g f))
Case conversion may be inaccurate. Consider using '#align embedding.comp Embedding.compₓ'. -/
theorem Embedding.comp {g : β → γ} {f : α → β} (hg : Embedding g) (hf : Embedding f) :
    Embedding (g ∘ f) :=
  { hg.to_inducing.comp hf.to_inducing with inj := fun a₁ a₂ h => hf.inj <| hg.inj h }
#align embedding.comp Embedding.comp

/- warning: embedding_of_embedding_compose -> embedding_of_embedding_compose is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {f : α -> β} {g : β -> γ}, (Continuous.{u1, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u3} β γ _inst_2 _inst_3 g) -> (Embedding.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f)) -> (Embedding.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u3}} {β : Type.{u2}} {γ : Type.{u1}} [_inst_1 : TopologicalSpace.{u3} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u1} γ] {f : α -> β} {g : β -> γ}, (Continuous.{u3, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u1} β γ _inst_2 _inst_3 g) -> (Embedding.{u3, u1} α γ _inst_1 _inst_3 (Function.comp.{succ u3, succ u2, succ u1} α β γ g f)) -> (Embedding.{u3, u2} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align embedding_of_embedding_compose embedding_of_embedding_composeₓ'. -/
theorem embedding_of_embedding_compose {f : α → β} {g : β → γ} (hf : Continuous f)
    (hg : Continuous g) (hgf : Embedding (g ∘ f)) : Embedding f :=
  { induced := (inducing_of_inducing_compose hf hg hgf.to_inducing).induced
    inj := fun a₁ a₂ h => hgf.inj <| by simp [h, (· ∘ ·)] }
#align embedding_of_embedding_compose embedding_of_embedding_compose

#print Function.LeftInverse.embedding /-
protected theorem Function.LeftInverse.embedding {f : α → β} {g : β → α} (h : LeftInverse f g)
    (hf : Continuous f) (hg : Continuous g) : Embedding g :=
  embedding_of_embedding_compose hg hf <| h.comp_eq_id.symm ▸ embedding_id
#align function.left_inverse.embedding Function.LeftInverse.embedding
-/

/- warning: embedding.map_nhds_eq -> Embedding.map_nhds_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Embedding.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (a : α), Eq.{succ u2} (Filter.{u2} β) (Filter.map.{u1, u2} α β f (nhds.{u1} α _inst_1 a)) (nhdsWithin.{u2} β _inst_2 (f a) (Set.range.{u2, succ u1} β α f)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Embedding.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (a : α), Eq.{succ u1} (Filter.{u1} β) (Filter.map.{u2, u1} α β f (nhds.{u2} α _inst_1 a)) (nhdsWithin.{u1} β _inst_2 (f a) (Set.range.{u1, succ u2} β α f)))
Case conversion may be inaccurate. Consider using '#align embedding.map_nhds_eq Embedding.map_nhds_eqₓ'. -/
theorem Embedding.map_nhds_eq {f : α → β} (hf : Embedding f) (a : α) :
    (𝓝 a).map f = 𝓝[range f] f a :=
  hf.1.map_nhds_eq a
#align embedding.map_nhds_eq Embedding.map_nhds_eq

/- warning: embedding.map_nhds_of_mem -> Embedding.map_nhds_of_mem is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Embedding.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (a : α), (Membership.Mem.{u2, u2} (Set.{u2} β) (Filter.{u2} β) (Filter.hasMem.{u2} β) (Set.range.{u2, succ u1} β α f) (nhds.{u2} β _inst_2 (f a))) -> (Eq.{succ u2} (Filter.{u2} β) (Filter.map.{u1, u2} α β f (nhds.{u1} α _inst_1 a)) (nhds.{u2} β _inst_2 (f a))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Embedding.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (a : α), (Membership.mem.{u1, u1} (Set.{u1} β) (Filter.{u1} β) (instMembershipSetFilter.{u1} β) (Set.range.{u1, succ u2} β α f) (nhds.{u1} β _inst_2 (f a))) -> (Eq.{succ u1} (Filter.{u1} β) (Filter.map.{u2, u1} α β f (nhds.{u2} α _inst_1 a)) (nhds.{u1} β _inst_2 (f a))))
Case conversion may be inaccurate. Consider using '#align embedding.map_nhds_of_mem Embedding.map_nhds_of_memₓ'. -/
theorem Embedding.map_nhds_of_mem {f : α → β} (hf : Embedding f) (a : α) (h : range f ∈ 𝓝 (f a)) :
    (𝓝 a).map f = 𝓝 (f a) :=
  hf.1.map_nhds_of_mem a h
#align embedding.map_nhds_of_mem Embedding.map_nhds_of_mem

/- warning: embedding.tendsto_nhds_iff -> Embedding.tendsto_nhds_iff is a dubious translation:
lean 3 declaration is
  forall {β : Type.{u1}} {γ : Type.{u2}} [_inst_2 : TopologicalSpace.{u1} β] [_inst_3 : TopologicalSpace.{u2} γ] {ι : Type.{u3}} {f : ι -> β} {g : β -> γ} {a : Filter.{u3} ι} {b : β}, (Embedding.{u1, u2} β γ _inst_2 _inst_3 g) -> (Iff (Filter.Tendsto.{u3, u1} ι β f a (nhds.{u1} β _inst_2 b)) (Filter.Tendsto.{u3, u2} ι γ (Function.comp.{succ u3, succ u1, succ u2} ι β γ g f) a (nhds.{u2} γ _inst_3 (g b))))
but is expected to have type
  forall {β : Type.{u2}} {γ : Type.{u1}} [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u1} γ] {ι : Type.{u3}} {f : ι -> β} {g : β -> γ} {a : Filter.{u3} ι} {b : β}, (Embedding.{u2, u1} β γ _inst_2 _inst_3 g) -> (Iff (Filter.Tendsto.{u3, u2} ι β f a (nhds.{u2} β _inst_2 b)) (Filter.Tendsto.{u3, u1} ι γ (Function.comp.{succ u3, succ u2, succ u1} ι β γ g f) a (nhds.{u1} γ _inst_3 (g b))))
Case conversion may be inaccurate. Consider using '#align embedding.tendsto_nhds_iff Embedding.tendsto_nhds_iffₓ'. -/
theorem Embedding.tendsto_nhds_iff {ι : Type _} {f : ι → β} {g : β → γ} {a : Filter ι} {b : β}
    (hg : Embedding g) : Tendsto f a (𝓝 b) ↔ Tendsto (g ∘ f) a (𝓝 (g b)) :=
  hg.to_inducing.tendsto_nhds_iff
#align embedding.tendsto_nhds_iff Embedding.tendsto_nhds_iff

/- warning: embedding.continuous_iff -> Embedding.continuous_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {f : α -> β} {g : β -> γ}, (Embedding.{u2, u3} β γ _inst_2 _inst_3 g) -> (Iff (Continuous.{u1, u2} α β _inst_1 _inst_2 f) (Continuous.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f)))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u3} β] [_inst_3 : TopologicalSpace.{u2} γ] {f : α -> β} {g : β -> γ}, (Embedding.{u3, u2} β γ _inst_2 _inst_3 g) -> (Iff (Continuous.{u1, u3} α β _inst_1 _inst_2 f) (Continuous.{u1, u2} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u3, succ u2} α β γ g f)))
Case conversion may be inaccurate. Consider using '#align embedding.continuous_iff Embedding.continuous_iffₓ'. -/
theorem Embedding.continuous_iff {f : α → β} {g : β → γ} (hg : Embedding g) :
    Continuous f ↔ Continuous (g ∘ f) :=
  Inducing.continuous_iff hg.1
#align embedding.continuous_iff Embedding.continuous_iff

/- warning: embedding.continuous -> Embedding.continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Embedding.{u1, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Embedding.{u2, u1} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align embedding.continuous Embedding.continuousₓ'. -/
theorem Embedding.continuous {f : α → β} (hf : Embedding f) : Continuous f :=
  Inducing.continuous hf.1
#align embedding.continuous Embedding.continuous

/- warning: embedding.closure_eq_preimage_closure_image -> Embedding.closure_eq_preimage_closure_image is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {e : α -> β}, (Embedding.{u1, u2} α β _inst_1 _inst_2 e) -> (forall (s : Set.{u1} α), Eq.{succ u1} (Set.{u1} α) (closure.{u1} α _inst_1 s) (Set.preimage.{u1, u2} α β e (closure.{u2} β _inst_2 (Set.image.{u1, u2} α β e s))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {e : α -> β}, (Embedding.{u2, u1} α β _inst_1 _inst_2 e) -> (forall (s : Set.{u2} α), Eq.{succ u2} (Set.{u2} α) (closure.{u2} α _inst_1 s) (Set.preimage.{u2, u1} α β e (closure.{u1} β _inst_2 (Set.image.{u2, u1} α β e s))))
Case conversion may be inaccurate. Consider using '#align embedding.closure_eq_preimage_closure_image Embedding.closure_eq_preimage_closure_imageₓ'. -/
theorem Embedding.closure_eq_preimage_closure_image {e : α → β} (he : Embedding e) (s : Set α) :
    closure s = e ⁻¹' closure (e '' s) :=
  he.1.closure_eq_preimage_closure_image s
#align embedding.closure_eq_preimage_closure_image Embedding.closure_eq_preimage_closure_image

/- warning: embedding.discrete_topology -> Embedding.discreteTopology is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} {Y : Type.{u2}} [_inst_4 : TopologicalSpace.{u1} X] [tY : TopologicalSpace.{u2} Y] [_inst_5 : DiscreteTopology.{u2} Y tY] {f : X -> Y}, (Embedding.{u1, u2} X Y _inst_4 tY f) -> (DiscreteTopology.{u1} X _inst_4)
but is expected to have type
  forall {X : Type.{u2}} {Y : Type.{u1}} [_inst_4 : TopologicalSpace.{u2} X] [tY : TopologicalSpace.{u1} Y] [_inst_5 : DiscreteTopology.{u1} Y tY] {f : X -> Y}, (Embedding.{u2, u1} X Y _inst_4 tY f) -> (DiscreteTopology.{u2} X _inst_4)
Case conversion may be inaccurate. Consider using '#align embedding.discrete_topology Embedding.discreteTopologyₓ'. -/
/-- The topology induced under an inclusion `f : X → Y` from the discrete topological space `Y`
is the discrete topology on `X`. -/
theorem Embedding.discreteTopology {X Y : Type _} [TopologicalSpace X] [tY : TopologicalSpace Y]
    [DiscreteTopology Y] {f : X → Y} (hf : Embedding f) : DiscreteTopology X :=
  discreteTopology_iff_nhds.2 fun x => by
    rw [hf.nhds_eq_comap, nhds_discrete, comap_pure, ← image_singleton, hf.inj.preimage_image,
      principal_singleton]
#align embedding.discrete_topology Embedding.discreteTopology

end Embedding

#print QuotientMap /-
/-- A function between topological spaces is a quotient map if it is surjective,
  and for all `s : set β`, `s` is open iff its preimage is an open set. -/
def QuotientMap {α : Type _} {β : Type _} [tα : TopologicalSpace α] [tβ : TopologicalSpace β]
    (f : α → β) : Prop :=
  Surjective f ∧ tβ = tα.coinduced f
#align quotient_map QuotientMap
-/

/- warning: quotient_map_iff -> quotientMap_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, Iff (QuotientMap.{u1, u2} α β _inst_1 _inst_2 f) (And (Function.Surjective.{succ u1, succ u2} α β f) (forall (s : Set.{u2} β), Iff (IsOpen.{u2} β _inst_2 s) (IsOpen.{u1} α _inst_1 (Set.preimage.{u1, u2} α β f s))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, Iff (QuotientMap.{u2, u1} α β _inst_1 _inst_2 f) (And (Function.Surjective.{succ u2, succ u1} α β f) (forall (s : Set.{u1} β), Iff (IsOpen.{u1} β _inst_2 s) (IsOpen.{u2} α _inst_1 (Set.preimage.{u2, u1} α β f s))))
Case conversion may be inaccurate. Consider using '#align quotient_map_iff quotientMap_iffₓ'. -/
theorem quotientMap_iff {α β : Type _} [TopologicalSpace α] [TopologicalSpace β] {f : α → β} :
    QuotientMap f ↔ Surjective f ∧ ∀ s : Set β, IsOpen s ↔ IsOpen (f ⁻¹' s) :=
  and_congr Iff.rfl topologicalSpace_eq_iff
#align quotient_map_iff quotientMap_iff

namespace QuotientMap

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ] [TopologicalSpace δ]
  {g : β → γ} {f : α → β}

#print QuotientMap.id /-
protected theorem id : QuotientMap (@id α) :=
  ⟨fun a => ⟨a, rfl⟩, coinduced_id.symm⟩
#align quotient_map.id QuotientMap.id
-/

/- warning: quotient_map.comp -> QuotientMap.comp is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {g : β -> γ} {f : α -> β}, (QuotientMap.{u2, u3} β γ _inst_2 _inst_3 g) -> (QuotientMap.{u1, u2} α β _inst_1 _inst_2 f) -> (QuotientMap.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u3} β] [_inst_3 : TopologicalSpace.{u2} γ] {g : β -> γ} {f : α -> β}, (QuotientMap.{u3, u2} β γ _inst_2 _inst_3 g) -> (QuotientMap.{u1, u3} α β _inst_1 _inst_2 f) -> (QuotientMap.{u1, u2} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u3, succ u2} α β γ g f))
Case conversion may be inaccurate. Consider using '#align quotient_map.comp QuotientMap.compₓ'. -/
protected theorem comp (hg : QuotientMap g) (hf : QuotientMap f) : QuotientMap (g ∘ f) :=
  ⟨hg.left.comp hf.left, by rw [hg.right, hf.right, coinduced_compose]⟩
#align quotient_map.comp QuotientMap.comp

/- warning: quotient_map.of_quotient_map_compose -> QuotientMap.of_quotientMap_compose is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {g : β -> γ} {f : α -> β}, (Continuous.{u1, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u3} β γ _inst_2 _inst_3 g) -> (QuotientMap.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f)) -> (QuotientMap.{u2, u3} β γ _inst_2 _inst_3 g)
but is expected to have type
  forall {α : Type.{u3}} {β : Type.{u2}} {γ : Type.{u1}} [_inst_1 : TopologicalSpace.{u3} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u1} γ] {g : β -> γ} {f : α -> β}, (Continuous.{u3, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u1} β γ _inst_2 _inst_3 g) -> (QuotientMap.{u3, u1} α γ _inst_1 _inst_3 (Function.comp.{succ u3, succ u2, succ u1} α β γ g f)) -> (QuotientMap.{u2, u1} β γ _inst_2 _inst_3 g)
Case conversion may be inaccurate. Consider using '#align quotient_map.of_quotient_map_compose QuotientMap.of_quotientMap_composeₓ'. -/
protected theorem of_quotientMap_compose (hf : Continuous f) (hg : Continuous g)
    (hgf : QuotientMap (g ∘ f)) : QuotientMap g :=
  ⟨hgf.1.of_comp,
    le_antisymm
      (by
        rw [hgf.right, ← continuous_iff_coinduced_le]
        apply continuous_coinduced_rng.comp hf)
      (by rwa [← continuous_iff_coinduced_le])⟩
#align quotient_map.of_quotient_map_compose QuotientMap.of_quotientMap_compose

/- warning: quotient_map.of_inverse -> QuotientMap.of_inverse is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β} {g : β -> α}, (Continuous.{u1, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u1} β α _inst_2 _inst_1 g) -> (Function.LeftInverse.{succ u1, succ u2} α β g f) -> (QuotientMap.{u2, u1} β α _inst_2 _inst_1 g)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β} {g : β -> α}, (Continuous.{u2, u1} α β _inst_1 _inst_2 f) -> (Continuous.{u1, u2} β α _inst_2 _inst_1 g) -> (Function.LeftInverse.{succ u2, succ u1} α β g f) -> (QuotientMap.{u1, u2} β α _inst_2 _inst_1 g)
Case conversion may be inaccurate. Consider using '#align quotient_map.of_inverse QuotientMap.of_inverseₓ'. -/
theorem of_inverse {g : β → α} (hf : Continuous f) (hg : Continuous g) (h : LeftInverse g f) :
    QuotientMap g :=
  QuotientMap.of_quotientMap_compose hf hg <| h.comp_eq_id.symm ▸ QuotientMap.id
#align quotient_map.of_inverse QuotientMap.of_inverse

/- warning: quotient_map.continuous_iff -> QuotientMap.continuous_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {g : β -> γ} {f : α -> β}, (QuotientMap.{u1, u2} α β _inst_1 _inst_2 f) -> (Iff (Continuous.{u2, u3} β γ _inst_2 _inst_3 g) (Continuous.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f)))
but is expected to have type
  forall {α : Type.{u3}} {β : Type.{u2}} {γ : Type.{u1}} [_inst_1 : TopologicalSpace.{u3} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u1} γ] {g : β -> γ} {f : α -> β}, (QuotientMap.{u3, u2} α β _inst_1 _inst_2 f) -> (Iff (Continuous.{u2, u1} β γ _inst_2 _inst_3 g) (Continuous.{u3, u1} α γ _inst_1 _inst_3 (Function.comp.{succ u3, succ u2, succ u1} α β γ g f)))
Case conversion may be inaccurate. Consider using '#align quotient_map.continuous_iff QuotientMap.continuous_iffₓ'. -/
protected theorem continuous_iff (hf : QuotientMap f) : Continuous g ↔ Continuous (g ∘ f) := by
  rw [continuous_iff_coinduced_le, continuous_iff_coinduced_le, hf.right, coinduced_compose]
#align quotient_map.continuous_iff QuotientMap.continuous_iff

/- warning: quotient_map.continuous -> QuotientMap.continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (QuotientMap.{u1, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (QuotientMap.{u2, u1} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align quotient_map.continuous QuotientMap.continuousₓ'. -/
protected theorem continuous (hf : QuotientMap f) : Continuous f :=
  hf.continuous_iff.mp continuous_id
#align quotient_map.continuous QuotientMap.continuous

/- warning: quotient_map.surjective -> QuotientMap.surjective is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (QuotientMap.{u1, u2} α β _inst_1 _inst_2 f) -> (Function.Surjective.{succ u1, succ u2} α β f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (QuotientMap.{u2, u1} α β _inst_1 _inst_2 f) -> (Function.Surjective.{succ u2, succ u1} α β f)
Case conversion may be inaccurate. Consider using '#align quotient_map.surjective QuotientMap.surjectiveₓ'. -/
protected theorem surjective (hf : QuotientMap f) : Surjective f :=
  hf.1
#align quotient_map.surjective QuotientMap.surjective

/- warning: quotient_map.is_open_preimage -> QuotientMap.isOpen_preimage is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (QuotientMap.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u2} β}, Iff (IsOpen.{u1} α _inst_1 (Set.preimage.{u1, u2} α β f s)) (IsOpen.{u2} β _inst_2 s))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (QuotientMap.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u1} β}, Iff (IsOpen.{u2} α _inst_1 (Set.preimage.{u2, u1} α β f s)) (IsOpen.{u1} β _inst_2 s))
Case conversion may be inaccurate. Consider using '#align quotient_map.is_open_preimage QuotientMap.isOpen_preimageₓ'. -/
protected theorem isOpen_preimage (hf : QuotientMap f) {s : Set β} : IsOpen (f ⁻¹' s) ↔ IsOpen s :=
  ((quotientMap_iff.1 hf).2 s).symm
#align quotient_map.is_open_preimage QuotientMap.isOpen_preimage

/- warning: quotient_map.is_closed_preimage -> QuotientMap.isClosed_preimage is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (QuotientMap.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u2} β}, Iff (IsClosed.{u1} α _inst_1 (Set.preimage.{u1, u2} α β f s)) (IsClosed.{u2} β _inst_2 s))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (QuotientMap.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u1} β}, Iff (IsClosed.{u2} α _inst_1 (Set.preimage.{u2, u1} α β f s)) (IsClosed.{u1} β _inst_2 s))
Case conversion may be inaccurate. Consider using '#align quotient_map.is_closed_preimage QuotientMap.isClosed_preimageₓ'. -/
protected theorem isClosed_preimage (hf : QuotientMap f) {s : Set β} :
    IsClosed (f ⁻¹' s) ↔ IsClosed s := by
  simp only [← isOpen_compl_iff, ← preimage_compl, hf.is_open_preimage]
#align quotient_map.is_closed_preimage QuotientMap.isClosed_preimage

end QuotientMap

#print IsOpenMap /-
/-- A map `f : α → β` is said to be an *open map*, if the image of any open `U : set α`
is open in `β`. -/
def IsOpenMap [TopologicalSpace α] [TopologicalSpace β] (f : α → β) :=
  ∀ U : Set α, IsOpen U → IsOpen (f '' U)
#align is_open_map IsOpenMap
-/

namespace IsOpenMap

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ] {f : α → β}

#print IsOpenMap.id /-
protected theorem id : IsOpenMap (@id α) := fun s hs => by rwa [image_id]
#align is_open_map.id IsOpenMap.id
-/

/- warning: is_open_map.comp -> IsOpenMap.comp is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {g : β -> γ} {f : α -> β}, (IsOpenMap.{u2, u3} β γ _inst_2 _inst_3 g) -> (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (IsOpenMap.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u3} β] [_inst_3 : TopologicalSpace.{u2} γ] {g : β -> γ} {f : α -> β}, (IsOpenMap.{u3, u2} β γ _inst_2 _inst_3 g) -> (IsOpenMap.{u1, u3} α β _inst_1 _inst_2 f) -> (IsOpenMap.{u1, u2} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u3, succ u2} α β γ g f))
Case conversion may be inaccurate. Consider using '#align is_open_map.comp IsOpenMap.compₓ'. -/
protected theorem comp {g : β → γ} {f : α → β} (hg : IsOpenMap g) (hf : IsOpenMap f) :
    IsOpenMap (g ∘ f) := by intro s hs <;> rw [image_comp] <;> exact hg _ (hf _ hs)
#align is_open_map.comp IsOpenMap.comp

/- warning: is_open_map.is_open_range -> IsOpenMap.isOpen_range is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (IsOpen.{u2} β _inst_2 (Set.range.{u2, succ u1} β α f))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) -> (IsOpen.{u1} β _inst_2 (Set.range.{u1, succ u2} β α f))
Case conversion may be inaccurate. Consider using '#align is_open_map.is_open_range IsOpenMap.isOpen_rangeₓ'. -/
theorem isOpen_range (hf : IsOpenMap f) : IsOpen (range f) :=
  by
  rw [← image_univ]
  exact hf _ isOpen_univ
#align is_open_map.is_open_range IsOpenMap.isOpen_range

/- warning: is_open_map.image_mem_nhds -> IsOpenMap.image_mem_nhds is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {x : α} {s : Set.{u1} α}, (Membership.Mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (Filter.hasMem.{u1} α) s (nhds.{u1} α _inst_1 x)) -> (Membership.Mem.{u2, u2} (Set.{u2} β) (Filter.{u2} β) (Filter.hasMem.{u2} β) (Set.image.{u1, u2} α β f s) (nhds.{u2} β _inst_2 (f x))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {x : α} {s : Set.{u2} α}, (Membership.mem.{u2, u2} (Set.{u2} α) (Filter.{u2} α) (instMembershipSetFilter.{u2} α) s (nhds.{u2} α _inst_1 x)) -> (Membership.mem.{u1, u1} (Set.{u1} β) (Filter.{u1} β) (instMembershipSetFilter.{u1} β) (Set.image.{u2, u1} α β f s) (nhds.{u1} β _inst_2 (f x))))
Case conversion may be inaccurate. Consider using '#align is_open_map.image_mem_nhds IsOpenMap.image_mem_nhdsₓ'. -/
theorem image_mem_nhds (hf : IsOpenMap f) {x : α} {s : Set α} (hx : s ∈ 𝓝 x) : f '' s ∈ 𝓝 (f x) :=
  let ⟨t, hts, ht, hxt⟩ := mem_nhds_iff.1 hx
  mem_of_superset (IsOpen.mem_nhds (hf t ht) (mem_image_of_mem _ hxt)) (image_subset _ hts)
#align is_open_map.image_mem_nhds IsOpenMap.image_mem_nhds

/- warning: is_open_map.range_mem_nhds -> IsOpenMap.range_mem_nhds is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (x : α), Membership.Mem.{u2, u2} (Set.{u2} β) (Filter.{u2} β) (Filter.hasMem.{u2} β) (Set.range.{u2, succ u1} β α f) (nhds.{u2} β _inst_2 (f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (x : α), Membership.mem.{u1, u1} (Set.{u1} β) (Filter.{u1} β) (instMembershipSetFilter.{u1} β) (Set.range.{u1, succ u2} β α f) (nhds.{u1} β _inst_2 (f x)))
Case conversion may be inaccurate. Consider using '#align is_open_map.range_mem_nhds IsOpenMap.range_mem_nhdsₓ'. -/
theorem range_mem_nhds (hf : IsOpenMap f) (x : α) : range f ∈ 𝓝 (f x) :=
  hf.isOpen_range.mem_nhds <| mem_range_self _
#align is_open_map.range_mem_nhds IsOpenMap.range_mem_nhds

/- warning: is_open_map.maps_to_interior -> IsOpenMap.mapsTo_interior is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u1} α} {t : Set.{u2} β}, (Set.MapsTo.{u1, u2} α β f s t) -> (Set.MapsTo.{u1, u2} α β f (interior.{u1} α _inst_1 s) (interior.{u2} β _inst_2 t)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u2} α} {t : Set.{u1} β}, (Set.MapsTo.{u2, u1} α β f s t) -> (Set.MapsTo.{u2, u1} α β f (interior.{u2} α _inst_1 s) (interior.{u1} β _inst_2 t)))
Case conversion may be inaccurate. Consider using '#align is_open_map.maps_to_interior IsOpenMap.mapsTo_interiorₓ'. -/
theorem mapsTo_interior (hf : IsOpenMap f) {s : Set α} {t : Set β} (h : MapsTo f s t) :
    MapsTo f (interior s) (interior t) :=
  mapsTo'.2 <|
    interior_maximal (h.mono interior_subset Subset.rfl).image_subset (hf _ isOpen_interior)
#align is_open_map.maps_to_interior IsOpenMap.mapsTo_interior

/- warning: is_open_map.image_interior_subset -> IsOpenMap.image_interior_subset is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u1} α), HasSubset.Subset.{u2} (Set.{u2} β) (Set.hasSubset.{u2} β) (Set.image.{u1, u2} α β f (interior.{u1} α _inst_1 s)) (interior.{u2} β _inst_2 (Set.image.{u1, u2} α β f s)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u2} α), HasSubset.Subset.{u1} (Set.{u1} β) (Set.instHasSubsetSet.{u1} β) (Set.image.{u2, u1} α β f (interior.{u2} α _inst_1 s)) (interior.{u1} β _inst_2 (Set.image.{u2, u1} α β f s)))
Case conversion may be inaccurate. Consider using '#align is_open_map.image_interior_subset IsOpenMap.image_interior_subsetₓ'. -/
theorem image_interior_subset (hf : IsOpenMap f) (s : Set α) :
    f '' interior s ⊆ interior (f '' s) :=
  (hf.mapsTo_interior (mapsTo_image f s)).image_subset
#align is_open_map.image_interior_subset IsOpenMap.image_interior_subset

/- warning: is_open_map.nhds_le -> IsOpenMap.nhds_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (a : α), LE.le.{u2} (Filter.{u2} β) (Preorder.toLE.{u2} (Filter.{u2} β) (PartialOrder.toPreorder.{u2} (Filter.{u2} β) (Filter.partialOrder.{u2} β))) (nhds.{u2} β _inst_2 (f a)) (Filter.map.{u1, u2} α β f (nhds.{u1} α _inst_1 a)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (a : α), LE.le.{u1} (Filter.{u1} β) (Preorder.toLE.{u1} (Filter.{u1} β) (PartialOrder.toPreorder.{u1} (Filter.{u1} β) (Filter.instPartialOrderFilter.{u1} β))) (nhds.{u1} β _inst_2 (f a)) (Filter.map.{u2, u1} α β f (nhds.{u2} α _inst_1 a)))
Case conversion may be inaccurate. Consider using '#align is_open_map.nhds_le IsOpenMap.nhds_leₓ'. -/
theorem nhds_le (hf : IsOpenMap f) (a : α) : 𝓝 (f a) ≤ (𝓝 a).map f :=
  le_map fun s => hf.image_mem_nhds
#align is_open_map.nhds_le IsOpenMap.nhds_le

/- warning: is_open_map.of_nhds_le -> IsOpenMap.of_nhds_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (forall (a : α), LE.le.{u2} (Filter.{u2} β) (Preorder.toLE.{u2} (Filter.{u2} β) (PartialOrder.toPreorder.{u2} (Filter.{u2} β) (Filter.partialOrder.{u2} β))) (nhds.{u2} β _inst_2 (f a)) (Filter.map.{u1, u2} α β f (nhds.{u1} α _inst_1 a))) -> (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (forall (a : α), LE.le.{u2} (Filter.{u2} β) (Preorder.toLE.{u2} (Filter.{u2} β) (PartialOrder.toPreorder.{u2} (Filter.{u2} β) (Filter.instPartialOrderFilter.{u2} β))) (nhds.{u2} β _inst_2 (f a)) (Filter.map.{u1, u2} α β f (nhds.{u1} α _inst_1 a))) -> (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align is_open_map.of_nhds_le IsOpenMap.of_nhds_leₓ'. -/
theorem of_nhds_le (hf : ∀ a, 𝓝 (f a) ≤ map f (𝓝 a)) : IsOpenMap f := fun s hs =>
  isOpen_iff_mem_nhds.2 fun b ⟨a, has, hab⟩ => hab ▸ hf _ (image_mem_map <| IsOpen.mem_nhds hs has)
#align is_open_map.of_nhds_le IsOpenMap.of_nhds_le

/- warning: is_open_map.of_sections -> IsOpenMap.of_sections is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (forall (x : α), Exists.{max (succ u2) (succ u1)} (β -> α) (fun (g : β -> α) => And (ContinuousAt.{u2, u1} β α _inst_2 _inst_1 g (f x)) (And (Eq.{succ u1} α (g (f x)) x) (Function.RightInverse.{succ u1, succ u2} α β g f)))) -> (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (forall (x : α), Exists.{max (succ u2) (succ u1)} (β -> α) (fun (g : β -> α) => And (ContinuousAt.{u1, u2} β α _inst_2 _inst_1 g (f x)) (And (Eq.{succ u2} α (g (f x)) x) (Function.RightInverse.{succ u2, succ u1} α β g f)))) -> (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align is_open_map.of_sections IsOpenMap.of_sectionsₓ'. -/
theorem of_sections {f : α → β}
    (h : ∀ x, ∃ g : β → α, ContinuousAt g (f x) ∧ g (f x) = x ∧ RightInverse g f) : IsOpenMap f :=
  of_nhds_le fun x =>
    let ⟨g, hgc, hgx, hgf⟩ := h x
    calc
      𝓝 (f x) = map f (map g (𝓝 (f x))) := by rw [map_map, hgf.comp_eq_id, map_id]
      _ ≤ map f (𝓝 (g (f x))) := map_mono hgc
      _ = map f (𝓝 x) := by rw [hgx]
      
#align is_open_map.of_sections IsOpenMap.of_sections

#print IsOpenMap.of_inverse /-
theorem of_inverse {f : α → β} {f' : β → α} (h : Continuous f') (l_inv : LeftInverse f f')
    (r_inv : RightInverse f f') : IsOpenMap f :=
  of_sections fun x => ⟨f', h.ContinuousAt, r_inv _, l_inv⟩
#align is_open_map.of_inverse IsOpenMap.of_inverse
-/

/- warning: is_open_map.to_quotient_map -> IsOpenMap.to_quotientMap is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u1, u2} α β _inst_1 _inst_2 f) -> (Function.Surjective.{succ u1, succ u2} α β f) -> (QuotientMap.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u1} α β _inst_1 _inst_2 f) -> (Function.Surjective.{succ u2, succ u1} α β f) -> (QuotientMap.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align is_open_map.to_quotient_map IsOpenMap.to_quotientMapₓ'. -/
/-- A continuous surjective open map is a quotient map. -/
theorem to_quotientMap {f : α → β} (open_map : IsOpenMap f) (cont : Continuous f)
    (surj : Surjective f) : QuotientMap f :=
  quotientMap_iff.2
    ⟨surj, fun s => ⟨fun h => h.Preimage cont, fun h => surj.image_preimage s ▸ open_map _ h⟩⟩
#align is_open_map.to_quotient_map IsOpenMap.to_quotientMap

/- warning: is_open_map.interior_preimage_subset_preimage_interior -> IsOpenMap.interior_preimage_subset_preimage_interior is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u2} β}, HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) (interior.{u1} α _inst_1 (Set.preimage.{u1, u2} α β f s)) (Set.preimage.{u1, u2} α β f (interior.{u2} β _inst_2 s)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u1} β}, HasSubset.Subset.{u2} (Set.{u2} α) (Set.instHasSubsetSet.{u2} α) (interior.{u2} α _inst_1 (Set.preimage.{u2, u1} α β f s)) (Set.preimage.{u2, u1} α β f (interior.{u1} β _inst_2 s)))
Case conversion may be inaccurate. Consider using '#align is_open_map.interior_preimage_subset_preimage_interior IsOpenMap.interior_preimage_subset_preimage_interiorₓ'. -/
theorem interior_preimage_subset_preimage_interior (hf : IsOpenMap f) {s : Set β} :
    interior (f ⁻¹' s) ⊆ f ⁻¹' interior s :=
  hf.mapsTo_interior (mapsTo_preimage _ _)
#align is_open_map.interior_preimage_subset_preimage_interior IsOpenMap.interior_preimage_subset_preimage_interior

/- warning: is_open_map.preimage_interior_eq_interior_preimage -> IsOpenMap.preimage_interior_eq_interior_preimage is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u2} β), Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β f (interior.{u2} β _inst_2 s)) (interior.{u1} α _inst_1 (Set.preimage.{u1, u2} α β f s)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u1} β), Eq.{succ u2} (Set.{u2} α) (Set.preimage.{u2, u1} α β f (interior.{u1} β _inst_2 s)) (interior.{u2} α _inst_1 (Set.preimage.{u2, u1} α β f s)))
Case conversion may be inaccurate. Consider using '#align is_open_map.preimage_interior_eq_interior_preimage IsOpenMap.preimage_interior_eq_interior_preimageₓ'. -/
theorem preimage_interior_eq_interior_preimage (hf₁ : IsOpenMap f) (hf₂ : Continuous f)
    (s : Set β) : f ⁻¹' interior s = interior (f ⁻¹' s) :=
  Subset.antisymm (preimage_interior_subset_interior_preimage hf₂)
    (interior_preimage_subset_preimage_interior hf₁)
#align is_open_map.preimage_interior_eq_interior_preimage IsOpenMap.preimage_interior_eq_interior_preimage

/- warning: is_open_map.preimage_closure_subset_closure_preimage -> IsOpenMap.preimage_closure_subset_closure_preimage is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u2} β}, HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) (Set.preimage.{u1, u2} α β f (closure.{u2} β _inst_2 s)) (closure.{u1} α _inst_1 (Set.preimage.{u1, u2} α β f s)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u1} β}, HasSubset.Subset.{u2} (Set.{u2} α) (Set.instHasSubsetSet.{u2} α) (Set.preimage.{u2, u1} α β f (closure.{u1} β _inst_2 s)) (closure.{u2} α _inst_1 (Set.preimage.{u2, u1} α β f s)))
Case conversion may be inaccurate. Consider using '#align is_open_map.preimage_closure_subset_closure_preimage IsOpenMap.preimage_closure_subset_closure_preimageₓ'. -/
theorem preimage_closure_subset_closure_preimage (hf : IsOpenMap f) {s : Set β} :
    f ⁻¹' closure s ⊆ closure (f ⁻¹' s) :=
  by
  rw [← compl_subset_compl]
  simp only [← interior_compl, ← preimage_compl, hf.interior_preimage_subset_preimage_interior]
#align is_open_map.preimage_closure_subset_closure_preimage IsOpenMap.preimage_closure_subset_closure_preimage

/- warning: is_open_map.preimage_closure_eq_closure_preimage -> IsOpenMap.preimage_closure_eq_closure_preimage is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u2} β), Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β f (closure.{u2} β _inst_2 s)) (closure.{u1} α _inst_1 (Set.preimage.{u1, u2} α β f s)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u1} β), Eq.{succ u2} (Set.{u2} α) (Set.preimage.{u2, u1} α β f (closure.{u1} β _inst_2 s)) (closure.{u2} α _inst_1 (Set.preimage.{u2, u1} α β f s)))
Case conversion may be inaccurate. Consider using '#align is_open_map.preimage_closure_eq_closure_preimage IsOpenMap.preimage_closure_eq_closure_preimageₓ'. -/
theorem preimage_closure_eq_closure_preimage (hf : IsOpenMap f) (hfc : Continuous f) (s : Set β) :
    f ⁻¹' closure s = closure (f ⁻¹' s) :=
  hf.preimage_closure_subset_closure_preimage.antisymm (hfc.closure_preimage_subset s)
#align is_open_map.preimage_closure_eq_closure_preimage IsOpenMap.preimage_closure_eq_closure_preimage

/- warning: is_open_map.preimage_frontier_subset_frontier_preimage -> IsOpenMap.preimage_frontier_subset_frontier_preimage is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u2} β}, HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) (Set.preimage.{u1, u2} α β f (frontier.{u2} β _inst_2 s)) (frontier.{u1} α _inst_1 (Set.preimage.{u1, u2} α β f s)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u1} β}, HasSubset.Subset.{u2} (Set.{u2} α) (Set.instHasSubsetSet.{u2} α) (Set.preimage.{u2, u1} α β f (frontier.{u1} β _inst_2 s)) (frontier.{u2} α _inst_1 (Set.preimage.{u2, u1} α β f s)))
Case conversion may be inaccurate. Consider using '#align is_open_map.preimage_frontier_subset_frontier_preimage IsOpenMap.preimage_frontier_subset_frontier_preimageₓ'. -/
theorem preimage_frontier_subset_frontier_preimage (hf : IsOpenMap f) {s : Set β} :
    f ⁻¹' frontier s ⊆ frontier (f ⁻¹' s) := by
  simpa only [frontier_eq_closure_inter_closure, preimage_inter] using
    inter_subset_inter hf.preimage_closure_subset_closure_preimage
      hf.preimage_closure_subset_closure_preimage
#align is_open_map.preimage_frontier_subset_frontier_preimage IsOpenMap.preimage_frontier_subset_frontier_preimage

/- warning: is_open_map.preimage_frontier_eq_frontier_preimage -> IsOpenMap.preimage_frontier_eq_frontier_preimage is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u2} β), Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β f (frontier.{u2} β _inst_2 s)) (frontier.{u1} α _inst_1 (Set.preimage.{u1, u2} α β f s)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u1} β), Eq.{succ u2} (Set.{u2} α) (Set.preimage.{u2, u1} α β f (frontier.{u1} β _inst_2 s)) (frontier.{u2} α _inst_1 (Set.preimage.{u2, u1} α β f s)))
Case conversion may be inaccurate. Consider using '#align is_open_map.preimage_frontier_eq_frontier_preimage IsOpenMap.preimage_frontier_eq_frontier_preimageₓ'. -/
theorem preimage_frontier_eq_frontier_preimage (hf : IsOpenMap f) (hfc : Continuous f) (s : Set β) :
    f ⁻¹' frontier s = frontier (f ⁻¹' s) := by
  simp only [frontier_eq_closure_inter_closure, preimage_inter, preimage_compl,
    hf.preimage_closure_eq_closure_preimage hfc]
#align is_open_map.preimage_frontier_eq_frontier_preimage IsOpenMap.preimage_frontier_eq_frontier_preimage

end IsOpenMap

/- warning: is_open_map_iff_nhds_le -> isOpenMap_iff_nhds_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, Iff (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) (forall (a : α), LE.le.{u2} (Filter.{u2} β) (Preorder.toLE.{u2} (Filter.{u2} β) (PartialOrder.toPreorder.{u2} (Filter.{u2} β) (Filter.partialOrder.{u2} β))) (nhds.{u2} β _inst_2 (f a)) (Filter.map.{u1, u2} α β f (nhds.{u1} α _inst_1 a)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, Iff (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) (forall (a : α), LE.le.{u1} (Filter.{u1} β) (Preorder.toLE.{u1} (Filter.{u1} β) (PartialOrder.toPreorder.{u1} (Filter.{u1} β) (Filter.instPartialOrderFilter.{u1} β))) (nhds.{u1} β _inst_2 (f a)) (Filter.map.{u2, u1} α β f (nhds.{u2} α _inst_1 a)))
Case conversion may be inaccurate. Consider using '#align is_open_map_iff_nhds_le isOpenMap_iff_nhds_leₓ'. -/
theorem isOpenMap_iff_nhds_le [TopologicalSpace α] [TopologicalSpace β] {f : α → β} :
    IsOpenMap f ↔ ∀ a : α, 𝓝 (f a) ≤ (𝓝 a).map f :=
  ⟨fun hf => hf.nhds_le, IsOpenMap.of_nhds_le⟩
#align is_open_map_iff_nhds_le isOpenMap_iff_nhds_le

/- warning: is_open_map_iff_interior -> isOpenMap_iff_interior is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, Iff (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) (forall (s : Set.{u1} α), HasSubset.Subset.{u2} (Set.{u2} β) (Set.hasSubset.{u2} β) (Set.image.{u1, u2} α β f (interior.{u1} α _inst_1 s)) (interior.{u2} β _inst_2 (Set.image.{u1, u2} α β f s)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, Iff (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) (forall (s : Set.{u2} α), HasSubset.Subset.{u1} (Set.{u1} β) (Set.instHasSubsetSet.{u1} β) (Set.image.{u2, u1} α β f (interior.{u2} α _inst_1 s)) (interior.{u1} β _inst_2 (Set.image.{u2, u1} α β f s)))
Case conversion may be inaccurate. Consider using '#align is_open_map_iff_interior isOpenMap_iff_interiorₓ'. -/
theorem isOpenMap_iff_interior [TopologicalSpace α] [TopologicalSpace β] {f : α → β} :
    IsOpenMap f ↔ ∀ s, f '' interior s ⊆ interior (f '' s) :=
  ⟨IsOpenMap.image_interior_subset, fun hs u hu =>
    subset_interior_iff_isOpen.mp <|
      calc
        f '' u = f '' interior u := by rw [hu.interior_eq]
        _ ⊆ interior (f '' u) := hs u
        ⟩
#align is_open_map_iff_interior isOpenMap_iff_interior

/- warning: inducing.is_open_map -> Inducing.isOpenMap is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (IsOpen.{u2} β _inst_2 (Set.range.{u2, succ u1} β α f)) -> (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Inducing.{u2, u1} α β _inst_1 _inst_2 f) -> (IsOpen.{u1} β _inst_2 (Set.range.{u1, succ u2} β α f)) -> (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align inducing.is_open_map Inducing.isOpenMapₓ'. -/
/-- An inducing map with an open range is an open map. -/
protected theorem Inducing.isOpenMap [TopologicalSpace α] [TopologicalSpace β] {f : α → β}
    (hi : Inducing f) (ho : IsOpen (range f)) : IsOpenMap f :=
  IsOpenMap.of_nhds_le fun x => (hi.map_nhds_of_mem _ <| IsOpen.mem_nhds ho <| mem_range_self _).ge
#align inducing.is_open_map Inducing.isOpenMap

section IsClosedMap

variable [TopologicalSpace α] [TopologicalSpace β]

#print IsClosedMap /-
/-- A map `f : α → β` is said to be a *closed map*, if the image of any closed `U : set α`
is closed in `β`. -/
def IsClosedMap (f : α → β) :=
  ∀ U : Set α, IsClosed U → IsClosed (f '' U)
#align is_closed_map IsClosedMap
-/

end IsClosedMap

namespace IsClosedMap

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ]

open Function

#print IsClosedMap.id /-
protected theorem id : IsClosedMap (@id α) := fun s hs => by rwa [image_id]
#align is_closed_map.id IsClosedMap.id
-/

/- warning: is_closed_map.comp -> IsClosedMap.comp is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {g : β -> γ} {f : α -> β}, (IsClosedMap.{u2, u3} β γ _inst_2 _inst_3 g) -> (IsClosedMap.{u1, u2} α β _inst_1 _inst_2 f) -> (IsClosedMap.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u3} β] [_inst_3 : TopologicalSpace.{u2} γ] {g : β -> γ} {f : α -> β}, (IsClosedMap.{u3, u2} β γ _inst_2 _inst_3 g) -> (IsClosedMap.{u1, u3} α β _inst_1 _inst_2 f) -> (IsClosedMap.{u1, u2} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u3, succ u2} α β γ g f))
Case conversion may be inaccurate. Consider using '#align is_closed_map.comp IsClosedMap.compₓ'. -/
protected theorem comp {g : β → γ} {f : α → β} (hg : IsClosedMap g) (hf : IsClosedMap f) :
    IsClosedMap (g ∘ f) := by
  intro s hs
  rw [image_comp]
  exact hg _ (hf _ hs)
#align is_closed_map.comp IsClosedMap.comp

/- warning: is_closed_map.closure_image_subset -> IsClosedMap.closure_image_subset is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (IsClosedMap.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u1} α), HasSubset.Subset.{u2} (Set.{u2} β) (Set.hasSubset.{u2} β) (closure.{u2} β _inst_2 (Set.image.{u1, u2} α β f s)) (Set.image.{u1, u2} α β f (closure.{u1} α _inst_1 s)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (IsClosedMap.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u2} α), HasSubset.Subset.{u1} (Set.{u1} β) (Set.instHasSubsetSet.{u1} β) (closure.{u1} β _inst_2 (Set.image.{u2, u1} α β f s)) (Set.image.{u2, u1} α β f (closure.{u2} α _inst_1 s)))
Case conversion may be inaccurate. Consider using '#align is_closed_map.closure_image_subset IsClosedMap.closure_image_subsetₓ'. -/
theorem closure_image_subset {f : α → β} (hf : IsClosedMap f) (s : Set α) :
    closure (f '' s) ⊆ f '' closure s :=
  closure_minimal (image_subset _ subset_closure) (hf _ isClosed_closure)
#align is_closed_map.closure_image_subset IsClosedMap.closure_image_subset

#print IsClosedMap.of_inverse /-
theorem of_inverse {f : α → β} {f' : β → α} (h : Continuous f') (l_inv : LeftInverse f f')
    (r_inv : RightInverse f f') : IsClosedMap f := fun s hs =>
  have : f' ⁻¹' s = f '' s := by ext x <;> simp [mem_image_iff_of_inverse r_inv l_inv]
  this ▸ hs.Preimage h
#align is_closed_map.of_inverse IsClosedMap.of_inverse
-/

/- warning: is_closed_map.of_nonempty -> IsClosedMap.of_nonempty is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (forall (s : Set.{u1} α), (IsClosed.{u1} α _inst_1 s) -> (Set.Nonempty.{u1} α s) -> (IsClosed.{u2} β _inst_2 (Set.image.{u1, u2} α β f s))) -> (IsClosedMap.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (forall (s : Set.{u2} α), (IsClosed.{u2} α _inst_1 s) -> (Set.Nonempty.{u2} α s) -> (IsClosed.{u1} β _inst_2 (Set.image.{u2, u1} α β f s))) -> (IsClosedMap.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align is_closed_map.of_nonempty IsClosedMap.of_nonemptyₓ'. -/
theorem of_nonempty {f : α → β} (h : ∀ s, IsClosed s → s.Nonempty → IsClosed (f '' s)) :
    IsClosedMap f := by
  intro s hs; cases' eq_empty_or_nonempty s with h2s h2s
  · simp_rw [h2s, image_empty, isClosed_empty]
  · exact h s hs h2s
#align is_closed_map.of_nonempty IsClosedMap.of_nonempty

/- warning: is_closed_map.closed_range -> IsClosedMap.closed_range is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (IsClosedMap.{u1, u2} α β _inst_1 _inst_2 f) -> (IsClosed.{u2} β _inst_2 (Set.range.{u2, succ u1} β α f))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (IsClosedMap.{u2, u1} α β _inst_1 _inst_2 f) -> (IsClosed.{u1} β _inst_2 (Set.range.{u1, succ u2} β α f))
Case conversion may be inaccurate. Consider using '#align is_closed_map.closed_range IsClosedMap.closed_rangeₓ'. -/
theorem closed_range {f : α → β} (hf : IsClosedMap f) : IsClosed (range f) :=
  @image_univ _ _ f ▸ hf _ isClosed_univ
#align is_closed_map.closed_range IsClosedMap.closed_range

end IsClosedMap

/- warning: inducing.is_closed_map -> Inducing.isClosedMap is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Inducing.{u1, u2} α β _inst_1 _inst_2 f) -> (IsClosed.{u2} β _inst_2 (Set.range.{u2, succ u1} β α f)) -> (IsClosedMap.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Inducing.{u2, u1} α β _inst_1 _inst_2 f) -> (IsClosed.{u1} β _inst_2 (Set.range.{u1, succ u2} β α f)) -> (IsClosedMap.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align inducing.is_closed_map Inducing.isClosedMapₓ'. -/
theorem Inducing.isClosedMap [TopologicalSpace α] [TopologicalSpace β] {f : α → β} (hf : Inducing f)
    (h : IsClosed (range f)) : IsClosedMap f :=
  by
  intro s hs
  rcases hf.is_closed_iff.1 hs with ⟨t, ht, rfl⟩
  rw [image_preimage_eq_inter_range]
  exact ht.inter h
#align inducing.is_closed_map Inducing.isClosedMap

/- warning: is_closed_map_iff_closure_image -> isClosedMap_iff_closure_image is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, Iff (IsClosedMap.{u1, u2} α β _inst_1 _inst_2 f) (forall (s : Set.{u1} α), HasSubset.Subset.{u2} (Set.{u2} β) (Set.hasSubset.{u2} β) (closure.{u2} β _inst_2 (Set.image.{u1, u2} α β f s)) (Set.image.{u1, u2} α β f (closure.{u1} α _inst_1 s)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, Iff (IsClosedMap.{u2, u1} α β _inst_1 _inst_2 f) (forall (s : Set.{u2} α), HasSubset.Subset.{u1} (Set.{u1} β) (Set.instHasSubsetSet.{u1} β) (closure.{u1} β _inst_2 (Set.image.{u2, u1} α β f s)) (Set.image.{u2, u1} α β f (closure.{u2} α _inst_1 s)))
Case conversion may be inaccurate. Consider using '#align is_closed_map_iff_closure_image isClosedMap_iff_closure_imageₓ'. -/
theorem isClosedMap_iff_closure_image [TopologicalSpace α] [TopologicalSpace β] {f : α → β} :
    IsClosedMap f ↔ ∀ s, closure (f '' s) ⊆ f '' closure s :=
  ⟨IsClosedMap.closure_image_subset, fun hs c hc =>
    isClosed_of_closure_subset <|
      calc
        closure (f '' c) ⊆ f '' closure c := hs c
        _ = f '' c := by rw [hc.closure_eq]
        ⟩
#align is_closed_map_iff_closure_image isClosedMap_iff_closure_image

section OpenEmbedding

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ]

#print OpenEmbedding /-
/-- An open embedding is an embedding with open image. -/
@[mk_iff]
structure OpenEmbedding (f : α → β) extends Embedding f : Prop where
  open_range : IsOpen <| range f
#align open_embedding OpenEmbedding
-/

/- warning: open_embedding.is_open_map -> OpenEmbedding.isOpenMap is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (OpenEmbedding.{u1, u2} α β _inst_1 _inst_2 f) -> (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (OpenEmbedding.{u2, u1} α β _inst_1 _inst_2 f) -> (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align open_embedding.is_open_map OpenEmbedding.isOpenMapₓ'. -/
theorem OpenEmbedding.isOpenMap {f : α → β} (hf : OpenEmbedding f) : IsOpenMap f :=
  hf.toEmbedding.to_inducing.IsOpenMap hf.open_range
#align open_embedding.is_open_map OpenEmbedding.isOpenMap

/- warning: open_embedding.map_nhds_eq -> OpenEmbedding.map_nhds_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (OpenEmbedding.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (a : α), Eq.{succ u2} (Filter.{u2} β) (Filter.map.{u1, u2} α β f (nhds.{u1} α _inst_1 a)) (nhds.{u2} β _inst_2 (f a)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (OpenEmbedding.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (a : α), Eq.{succ u1} (Filter.{u1} β) (Filter.map.{u2, u1} α β f (nhds.{u2} α _inst_1 a)) (nhds.{u1} β _inst_2 (f a)))
Case conversion may be inaccurate. Consider using '#align open_embedding.map_nhds_eq OpenEmbedding.map_nhds_eqₓ'. -/
theorem OpenEmbedding.map_nhds_eq {f : α → β} (hf : OpenEmbedding f) (a : α) :
    map f (𝓝 a) = 𝓝 (f a) :=
  hf.toEmbedding.map_nhds_of_mem _ <| hf.open_range.mem_nhds <| mem_range_self _
#align open_embedding.map_nhds_eq OpenEmbedding.map_nhds_eq

/- warning: open_embedding.open_iff_image_open -> OpenEmbedding.open_iff_image_open is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (OpenEmbedding.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u1} α}, Iff (IsOpen.{u1} α _inst_1 s) (IsOpen.{u2} β _inst_2 (Set.image.{u1, u2} α β f s)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (OpenEmbedding.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u2} α}, Iff (IsOpen.{u2} α _inst_1 s) (IsOpen.{u1} β _inst_2 (Set.image.{u2, u1} α β f s)))
Case conversion may be inaccurate. Consider using '#align open_embedding.open_iff_image_open OpenEmbedding.open_iff_image_openₓ'. -/
theorem OpenEmbedding.open_iff_image_open {f : α → β} (hf : OpenEmbedding f) {s : Set α} :
    IsOpen s ↔ IsOpen (f '' s) :=
  ⟨hf.IsOpenMap s, fun h =>
    by
    convert ← h.preimage hf.to_embedding.continuous
    apply preimage_image_eq _ hf.inj⟩
#align open_embedding.open_iff_image_open OpenEmbedding.open_iff_image_open

/- warning: open_embedding.tendsto_nhds_iff -> OpenEmbedding.tendsto_nhds_iff is a dubious translation:
lean 3 declaration is
  forall {β : Type.{u1}} {γ : Type.{u2}} [_inst_2 : TopologicalSpace.{u1} β] [_inst_3 : TopologicalSpace.{u2} γ] {ι : Type.{u3}} {f : ι -> β} {g : β -> γ} {a : Filter.{u3} ι} {b : β}, (OpenEmbedding.{u1, u2} β γ _inst_2 _inst_3 g) -> (Iff (Filter.Tendsto.{u3, u1} ι β f a (nhds.{u1} β _inst_2 b)) (Filter.Tendsto.{u3, u2} ι γ (Function.comp.{succ u3, succ u1, succ u2} ι β γ g f) a (nhds.{u2} γ _inst_3 (g b))))
but is expected to have type
  forall {β : Type.{u2}} {γ : Type.{u1}} [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u1} γ] {ι : Type.{u3}} {f : ι -> β} {g : β -> γ} {a : Filter.{u3} ι} {b : β}, (OpenEmbedding.{u2, u1} β γ _inst_2 _inst_3 g) -> (Iff (Filter.Tendsto.{u3, u2} ι β f a (nhds.{u2} β _inst_2 b)) (Filter.Tendsto.{u3, u1} ι γ (Function.comp.{succ u3, succ u2, succ u1} ι β γ g f) a (nhds.{u1} γ _inst_3 (g b))))
Case conversion may be inaccurate. Consider using '#align open_embedding.tendsto_nhds_iff OpenEmbedding.tendsto_nhds_iffₓ'. -/
theorem OpenEmbedding.tendsto_nhds_iff {ι : Type _} {f : ι → β} {g : β → γ} {a : Filter ι} {b : β}
    (hg : OpenEmbedding g) : Tendsto f a (𝓝 b) ↔ Tendsto (g ∘ f) a (𝓝 (g b)) :=
  hg.toEmbedding.tendsto_nhds_iff
#align open_embedding.tendsto_nhds_iff OpenEmbedding.tendsto_nhds_iff

/- warning: open_embedding.continuous -> OpenEmbedding.continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (OpenEmbedding.{u1, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (OpenEmbedding.{u2, u1} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align open_embedding.continuous OpenEmbedding.continuousₓ'. -/
theorem OpenEmbedding.continuous {f : α → β} (hf : OpenEmbedding f) : Continuous f :=
  hf.toEmbedding.Continuous
#align open_embedding.continuous OpenEmbedding.continuous

/- warning: open_embedding.open_iff_preimage_open -> OpenEmbedding.open_iff_preimage_open is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (OpenEmbedding.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u2} β}, (HasSubset.Subset.{u2} (Set.{u2} β) (Set.hasSubset.{u2} β) s (Set.range.{u2, succ u1} β α f)) -> (Iff (IsOpen.{u2} β _inst_2 s) (IsOpen.{u1} α _inst_1 (Set.preimage.{u1, u2} α β f s))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (OpenEmbedding.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u1} β}, (HasSubset.Subset.{u1} (Set.{u1} β) (Set.instHasSubsetSet.{u1} β) s (Set.range.{u1, succ u2} β α f)) -> (Iff (IsOpen.{u1} β _inst_2 s) (IsOpen.{u2} α _inst_1 (Set.preimage.{u2, u1} α β f s))))
Case conversion may be inaccurate. Consider using '#align open_embedding.open_iff_preimage_open OpenEmbedding.open_iff_preimage_openₓ'. -/
theorem OpenEmbedding.open_iff_preimage_open {f : α → β} (hf : OpenEmbedding f) {s : Set β}
    (hs : s ⊆ range f) : IsOpen s ↔ IsOpen (f ⁻¹' s) :=
  by
  convert ← hf.open_iff_image_open.symm
  rwa [image_preimage_eq_inter_range, inter_eq_self_of_subset_left]
#align open_embedding.open_iff_preimage_open OpenEmbedding.open_iff_preimage_open

/- warning: open_embedding_of_embedding_open -> openEmbedding_of_embedding_open is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Embedding.{u1, u2} α β _inst_1 _inst_2 f) -> (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (OpenEmbedding.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Embedding.{u2, u1} α β _inst_1 _inst_2 f) -> (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) -> (OpenEmbedding.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align open_embedding_of_embedding_open openEmbedding_of_embedding_openₓ'. -/
theorem openEmbedding_of_embedding_open {f : α → β} (h₁ : Embedding f) (h₂ : IsOpenMap f) :
    OpenEmbedding f :=
  ⟨h₁, h₂.isOpen_range⟩
#align open_embedding_of_embedding_open openEmbedding_of_embedding_open

/- warning: open_embedding_iff_embedding_open -> openEmbedding_iff_embedding_open is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, Iff (OpenEmbedding.{u1, u2} α β _inst_1 _inst_2 f) (And (Embedding.{u1, u2} α β _inst_1 _inst_2 f) (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, Iff (OpenEmbedding.{u2, u1} α β _inst_1 _inst_2 f) (And (Embedding.{u2, u1} α β _inst_1 _inst_2 f) (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f))
Case conversion may be inaccurate. Consider using '#align open_embedding_iff_embedding_open openEmbedding_iff_embedding_openₓ'. -/
theorem openEmbedding_iff_embedding_open {f : α → β} :
    OpenEmbedding f ↔ Embedding f ∧ IsOpenMap f :=
  ⟨fun h => ⟨h.1, h.IsOpenMap⟩, fun h => openEmbedding_of_embedding_open h.1 h.2⟩
#align open_embedding_iff_embedding_open openEmbedding_iff_embedding_open

/- warning: open_embedding_of_continuous_injective_open -> openEmbedding_of_continuous_injective_open is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Continuous.{u1, u2} α β _inst_1 _inst_2 f) -> (Function.Injective.{succ u1, succ u2} α β f) -> (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) -> (OpenEmbedding.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Continuous.{u2, u1} α β _inst_1 _inst_2 f) -> (Function.Injective.{succ u2, succ u1} α β f) -> (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f) -> (OpenEmbedding.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align open_embedding_of_continuous_injective_open openEmbedding_of_continuous_injective_openₓ'. -/
theorem openEmbedding_of_continuous_injective_open {f : α → β} (h₁ : Continuous f)
    (h₂ : Injective f) (h₃ : IsOpenMap f) : OpenEmbedding f :=
  by
  simp only [openEmbedding_iff_embedding_open, embedding_iff, inducing_iff_nhds, *, and_true_iff]
  exact fun a =>
    le_antisymm (h₁.tendsto _).le_comap (@comap_map _ _ (𝓝 a) _ h₂ ▸ comap_mono (h₃.nhds_le _))
#align open_embedding_of_continuous_injective_open openEmbedding_of_continuous_injective_open

/- warning: open_embedding_iff_continuous_injective_open -> openEmbedding_iff_continuous_injective_open is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, Iff (OpenEmbedding.{u1, u2} α β _inst_1 _inst_2 f) (And (Continuous.{u1, u2} α β _inst_1 _inst_2 f) (And (Function.Injective.{succ u1, succ u2} α β f) (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, Iff (OpenEmbedding.{u2, u1} α β _inst_1 _inst_2 f) (And (Continuous.{u2, u1} α β _inst_1 _inst_2 f) (And (Function.Injective.{succ u2, succ u1} α β f) (IsOpenMap.{u2, u1} α β _inst_1 _inst_2 f)))
Case conversion may be inaccurate. Consider using '#align open_embedding_iff_continuous_injective_open openEmbedding_iff_continuous_injective_openₓ'. -/
theorem openEmbedding_iff_continuous_injective_open {f : α → β} :
    OpenEmbedding f ↔ Continuous f ∧ Injective f ∧ IsOpenMap f :=
  ⟨fun h => ⟨h.Continuous, h.inj, h.IsOpenMap⟩, fun h =>
    openEmbedding_of_continuous_injective_open h.1 h.2.1 h.2.2⟩
#align open_embedding_iff_continuous_injective_open openEmbedding_iff_continuous_injective_open

#print openEmbedding_id /-
theorem openEmbedding_id : OpenEmbedding (@id α) :=
  ⟨embedding_id, IsOpenMap.id.isOpen_range⟩
#align open_embedding_id openEmbedding_id
-/

/- warning: open_embedding.comp -> OpenEmbedding.comp is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {g : β -> γ} {f : α -> β}, (OpenEmbedding.{u2, u3} β γ _inst_2 _inst_3 g) -> (OpenEmbedding.{u1, u2} α β _inst_1 _inst_2 f) -> (OpenEmbedding.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u3} β] [_inst_3 : TopologicalSpace.{u2} γ] {g : β -> γ} {f : α -> β}, (OpenEmbedding.{u3, u2} β γ _inst_2 _inst_3 g) -> (OpenEmbedding.{u1, u3} α β _inst_1 _inst_2 f) -> (OpenEmbedding.{u1, u2} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u3, succ u2} α β γ g f))
Case conversion may be inaccurate. Consider using '#align open_embedding.comp OpenEmbedding.compₓ'. -/
theorem OpenEmbedding.comp {g : β → γ} {f : α → β} (hg : OpenEmbedding g) (hf : OpenEmbedding f) :
    OpenEmbedding (g ∘ f) :=
  ⟨hg.1.comp hf.1, (hg.IsOpenMap.comp hf.IsOpenMap).isOpen_range⟩
#align open_embedding.comp OpenEmbedding.comp

/- warning: open_embedding.is_open_map_iff -> OpenEmbedding.isOpenMap_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {g : β -> γ} {f : α -> β}, (OpenEmbedding.{u2, u3} β γ _inst_2 _inst_3 g) -> (Iff (IsOpenMap.{u1, u2} α β _inst_1 _inst_2 f) (IsOpenMap.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f)))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u3} β] [_inst_3 : TopologicalSpace.{u2} γ] {g : β -> γ} {f : α -> β}, (OpenEmbedding.{u3, u2} β γ _inst_2 _inst_3 g) -> (Iff (IsOpenMap.{u1, u3} α β _inst_1 _inst_2 f) (IsOpenMap.{u1, u2} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u3, succ u2} α β γ g f)))
Case conversion may be inaccurate. Consider using '#align open_embedding.is_open_map_iff OpenEmbedding.isOpenMap_iffₓ'. -/
theorem OpenEmbedding.isOpenMap_iff {g : β → γ} {f : α → β} (hg : OpenEmbedding g) :
    IsOpenMap f ↔ IsOpenMap (g ∘ f) := by
  simp only [isOpenMap_iff_nhds_le, ← @map_map _ _ _ _ f g, ← hg.map_nhds_eq, map_le_map_iff hg.inj]
#align open_embedding.is_open_map_iff OpenEmbedding.isOpenMap_iff

/- warning: open_embedding.of_comp_iff -> OpenEmbedding.of_comp_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] (f : α -> β) {g : β -> γ}, (OpenEmbedding.{u2, u3} β γ _inst_2 _inst_3 g) -> (Iff (OpenEmbedding.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f)) (OpenEmbedding.{u1, u2} α β _inst_1 _inst_2 f))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u3} β] [_inst_3 : TopologicalSpace.{u2} γ] (f : α -> β) {g : β -> γ}, (OpenEmbedding.{u3, u2} β γ _inst_2 _inst_3 g) -> (Iff (OpenEmbedding.{u1, u2} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u3, succ u2} α β γ g f)) (OpenEmbedding.{u1, u3} α β _inst_1 _inst_2 f))
Case conversion may be inaccurate. Consider using '#align open_embedding.of_comp_iff OpenEmbedding.of_comp_iffₓ'. -/
theorem OpenEmbedding.of_comp_iff (f : α → β) {g : β → γ} (hg : OpenEmbedding g) :
    OpenEmbedding (g ∘ f) ↔ OpenEmbedding f := by
  simp only [openEmbedding_iff_continuous_injective_open, ← hg.is_open_map_iff, ←
    hg.1.continuous_iff, hg.inj.of_comp_iff]
#align open_embedding.of_comp_iff OpenEmbedding.of_comp_iff

/- warning: open_embedding.of_comp -> OpenEmbedding.of_comp is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] (f : α -> β) {g : β -> γ}, (OpenEmbedding.{u2, u3} β γ _inst_2 _inst_3 g) -> (OpenEmbedding.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f)) -> (OpenEmbedding.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u3} β] [_inst_3 : TopologicalSpace.{u2} γ] (f : α -> β) {g : β -> γ}, (OpenEmbedding.{u3, u2} β γ _inst_2 _inst_3 g) -> (OpenEmbedding.{u1, u2} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u3, succ u2} α β γ g f)) -> (OpenEmbedding.{u1, u3} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align open_embedding.of_comp OpenEmbedding.of_compₓ'. -/
theorem OpenEmbedding.of_comp (f : α → β) {g : β → γ} (hg : OpenEmbedding g)
    (h : OpenEmbedding (g ∘ f)) : OpenEmbedding f :=
  (OpenEmbedding.of_comp_iff f hg).1 h
#align open_embedding.of_comp OpenEmbedding.of_comp

end OpenEmbedding

section ClosedEmbedding

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ]

#print ClosedEmbedding /-
/-- A closed embedding is an embedding with closed image. -/
@[mk_iff]
structure ClosedEmbedding (f : α → β) extends Embedding f : Prop where
  closed_range : IsClosed <| range f
#align closed_embedding ClosedEmbedding
-/

variable {f : α → β}

/- warning: closed_embedding.tendsto_nhds_iff -> ClosedEmbedding.tendsto_nhds_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β} {ι : Type.{u3}} {g : ι -> α} {a : Filter.{u3} ι} {b : α}, (ClosedEmbedding.{u1, u2} α β _inst_1 _inst_2 f) -> (Iff (Filter.Tendsto.{u3, u1} ι α g a (nhds.{u1} α _inst_1 b)) (Filter.Tendsto.{u3, u2} ι β (Function.comp.{succ u3, succ u1, succ u2} ι α β f g) a (nhds.{u2} β _inst_2 (f b))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β} {ι : Type.{u3}} {g : ι -> α} {a : Filter.{u3} ι} {b : α}, (ClosedEmbedding.{u2, u1} α β _inst_1 _inst_2 f) -> (Iff (Filter.Tendsto.{u3, u2} ι α g a (nhds.{u2} α _inst_1 b)) (Filter.Tendsto.{u3, u1} ι β (Function.comp.{succ u3, succ u2, succ u1} ι α β f g) a (nhds.{u1} β _inst_2 (f b))))
Case conversion may be inaccurate. Consider using '#align closed_embedding.tendsto_nhds_iff ClosedEmbedding.tendsto_nhds_iffₓ'. -/
theorem ClosedEmbedding.tendsto_nhds_iff {ι : Type _} {g : ι → α} {a : Filter ι} {b : α}
    (hf : ClosedEmbedding f) : Tendsto g a (𝓝 b) ↔ Tendsto (f ∘ g) a (𝓝 (f b)) :=
  hf.toEmbedding.tendsto_nhds_iff
#align closed_embedding.tendsto_nhds_iff ClosedEmbedding.tendsto_nhds_iff

/- warning: closed_embedding.continuous -> ClosedEmbedding.continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (ClosedEmbedding.{u1, u2} α β _inst_1 _inst_2 f) -> (Continuous.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (ClosedEmbedding.{u2, u1} α β _inst_1 _inst_2 f) -> (Continuous.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align closed_embedding.continuous ClosedEmbedding.continuousₓ'. -/
theorem ClosedEmbedding.continuous (hf : ClosedEmbedding f) : Continuous f :=
  hf.toEmbedding.Continuous
#align closed_embedding.continuous ClosedEmbedding.continuous

/- warning: closed_embedding.is_closed_map -> ClosedEmbedding.isClosedMap is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (ClosedEmbedding.{u1, u2} α β _inst_1 _inst_2 f) -> (IsClosedMap.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (ClosedEmbedding.{u2, u1} α β _inst_1 _inst_2 f) -> (IsClosedMap.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align closed_embedding.is_closed_map ClosedEmbedding.isClosedMapₓ'. -/
theorem ClosedEmbedding.isClosedMap (hf : ClosedEmbedding f) : IsClosedMap f :=
  hf.toEmbedding.to_inducing.IsClosedMap hf.closed_range
#align closed_embedding.is_closed_map ClosedEmbedding.isClosedMap

/- warning: closed_embedding.closed_iff_image_closed -> ClosedEmbedding.closed_iff_image_closed is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (ClosedEmbedding.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u1} α}, Iff (IsClosed.{u1} α _inst_1 s) (IsClosed.{u2} β _inst_2 (Set.image.{u1, u2} α β f s)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (ClosedEmbedding.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u2} α}, Iff (IsClosed.{u2} α _inst_1 s) (IsClosed.{u1} β _inst_2 (Set.image.{u2, u1} α β f s)))
Case conversion may be inaccurate. Consider using '#align closed_embedding.closed_iff_image_closed ClosedEmbedding.closed_iff_image_closedₓ'. -/
theorem ClosedEmbedding.closed_iff_image_closed (hf : ClosedEmbedding f) {s : Set α} :
    IsClosed s ↔ IsClosed (f '' s) :=
  ⟨hf.IsClosedMap s, fun h =>
    by
    convert ← continuous_iff_is_closed.mp hf.continuous _ h
    apply preimage_image_eq _ hf.inj⟩
#align closed_embedding.closed_iff_image_closed ClosedEmbedding.closed_iff_image_closed

/- warning: closed_embedding.closed_iff_preimage_closed -> ClosedEmbedding.closed_iff_preimage_closed is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (ClosedEmbedding.{u1, u2} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u2} β}, (HasSubset.Subset.{u2} (Set.{u2} β) (Set.hasSubset.{u2} β) s (Set.range.{u2, succ u1} β α f)) -> (Iff (IsClosed.{u2} β _inst_2 s) (IsClosed.{u1} α _inst_1 (Set.preimage.{u1, u2} α β f s))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (ClosedEmbedding.{u2, u1} α β _inst_1 _inst_2 f) -> (forall {s : Set.{u1} β}, (HasSubset.Subset.{u1} (Set.{u1} β) (Set.instHasSubsetSet.{u1} β) s (Set.range.{u1, succ u2} β α f)) -> (Iff (IsClosed.{u1} β _inst_2 s) (IsClosed.{u2} α _inst_1 (Set.preimage.{u2, u1} α β f s))))
Case conversion may be inaccurate. Consider using '#align closed_embedding.closed_iff_preimage_closed ClosedEmbedding.closed_iff_preimage_closedₓ'. -/
theorem ClosedEmbedding.closed_iff_preimage_closed (hf : ClosedEmbedding f) {s : Set β}
    (hs : s ⊆ range f) : IsClosed s ↔ IsClosed (f ⁻¹' s) :=
  by
  convert ← hf.closed_iff_image_closed.symm
  rwa [image_preimage_eq_inter_range, inter_eq_self_of_subset_left]
#align closed_embedding.closed_iff_preimage_closed ClosedEmbedding.closed_iff_preimage_closed

/- warning: closed_embedding_of_embedding_closed -> closedEmbedding_of_embedding_closed is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Embedding.{u1, u2} α β _inst_1 _inst_2 f) -> (IsClosedMap.{u1, u2} α β _inst_1 _inst_2 f) -> (ClosedEmbedding.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Embedding.{u2, u1} α β _inst_1 _inst_2 f) -> (IsClosedMap.{u2, u1} α β _inst_1 _inst_2 f) -> (ClosedEmbedding.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align closed_embedding_of_embedding_closed closedEmbedding_of_embedding_closedₓ'. -/
theorem closedEmbedding_of_embedding_closed (h₁ : Embedding f) (h₂ : IsClosedMap f) :
    ClosedEmbedding f :=
  ⟨h₁, by convert h₂ univ isClosed_univ <;> simp⟩
#align closed_embedding_of_embedding_closed closedEmbedding_of_embedding_closed

/- warning: closed_embedding_of_continuous_injective_closed -> closedEmbedding_of_continuous_injective_closed is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (Continuous.{u1, u2} α β _inst_1 _inst_2 f) -> (Function.Injective.{succ u1, succ u2} α β f) -> (IsClosedMap.{u1, u2} α β _inst_1 _inst_2 f) -> (ClosedEmbedding.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (Continuous.{u2, u1} α β _inst_1 _inst_2 f) -> (Function.Injective.{succ u2, succ u1} α β f) -> (IsClosedMap.{u2, u1} α β _inst_1 _inst_2 f) -> (ClosedEmbedding.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align closed_embedding_of_continuous_injective_closed closedEmbedding_of_continuous_injective_closedₓ'. -/
theorem closedEmbedding_of_continuous_injective_closed (h₁ : Continuous f) (h₂ : Injective f)
    (h₃ : IsClosedMap f) : ClosedEmbedding f :=
  by
  refine' closedEmbedding_of_embedding_closed ⟨⟨_⟩, h₂⟩ h₃
  apply le_antisymm (continuous_iff_le_induced.mp h₁) _
  intro s'
  change IsOpen _ ≤ IsOpen _
  rw [← isClosed_compl_iff, ← isClosed_compl_iff]
  generalize s'ᶜ = s
  rw [isClosed_induced_iff]
  refine' fun hs => ⟨f '' s, h₃ s hs, _⟩
  rw [preimage_image_eq _ h₂]
#align closed_embedding_of_continuous_injective_closed closedEmbedding_of_continuous_injective_closed

#print closedEmbedding_id /-
theorem closedEmbedding_id : ClosedEmbedding (@id α) :=
  ⟨embedding_id, by convert isClosed_univ <;> apply range_id⟩
#align closed_embedding_id closedEmbedding_id
-/

/- warning: closed_embedding.comp -> ClosedEmbedding.comp is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : TopologicalSpace.{u3} γ] {g : β -> γ} {f : α -> β}, (ClosedEmbedding.{u2, u3} β γ _inst_2 _inst_3 g) -> (ClosedEmbedding.{u1, u2} α β _inst_1 _inst_2 f) -> (ClosedEmbedding.{u1, u3} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u2, succ u3} α β γ g f))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u3} β] [_inst_3 : TopologicalSpace.{u2} γ] {g : β -> γ} {f : α -> β}, (ClosedEmbedding.{u3, u2} β γ _inst_2 _inst_3 g) -> (ClosedEmbedding.{u1, u3} α β _inst_1 _inst_2 f) -> (ClosedEmbedding.{u1, u2} α γ _inst_1 _inst_3 (Function.comp.{succ u1, succ u3, succ u2} α β γ g f))
Case conversion may be inaccurate. Consider using '#align closed_embedding.comp ClosedEmbedding.compₓ'. -/
theorem ClosedEmbedding.comp {g : β → γ} {f : α → β} (hg : ClosedEmbedding g)
    (hf : ClosedEmbedding f) : ClosedEmbedding (g ∘ f) :=
  ⟨hg.toEmbedding.comp hf.toEmbedding,
    show IsClosed (range (g ∘ f)) by
      rw [range_comp, ← hg.closed_iff_image_closed] <;> exact hf.closed_range⟩
#align closed_embedding.comp ClosedEmbedding.comp

/- warning: closed_embedding.closure_image_eq -> ClosedEmbedding.closure_image_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (ClosedEmbedding.{u1, u2} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u1} α), Eq.{succ u2} (Set.{u2} β) (closure.{u2} β _inst_2 (Set.image.{u1, u2} α β f s)) (Set.image.{u1, u2} α β f (closure.{u1} α _inst_1 s)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (ClosedEmbedding.{u2, u1} α β _inst_1 _inst_2 f) -> (forall (s : Set.{u2} α), Eq.{succ u1} (Set.{u1} β) (closure.{u1} β _inst_2 (Set.image.{u2, u1} α β f s)) (Set.image.{u2, u1} α β f (closure.{u2} α _inst_1 s)))
Case conversion may be inaccurate. Consider using '#align closed_embedding.closure_image_eq ClosedEmbedding.closure_image_eqₓ'. -/
theorem ClosedEmbedding.closure_image_eq {f : α → β} (hf : ClosedEmbedding f) (s : Set α) :
    closure (f '' s) = f '' closure s :=
  (hf.IsClosedMap.closure_image_subset _).antisymm
    (image_closure_subset_closure_image hf.Continuous)
#align closed_embedding.closure_image_eq ClosedEmbedding.closure_image_eq

end ClosedEmbedding

