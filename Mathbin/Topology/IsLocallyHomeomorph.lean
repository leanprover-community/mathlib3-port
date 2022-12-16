/-
Copyright (c) 2021 Thomas Browning. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Thomas Browning

! This file was ported from Lean 3 source module topology.is_locally_homeomorph
! leanprover-community/mathlib commit d012cd09a9b256d870751284dd6a29882b0be105
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.LocalHomeomorph

/-!
# Local homeomorphisms

This file defines local homeomorphisms.

## Main definitions

* `is_locally_homeomorph`: A function `f : X → Y` satisfies `is_locally_homeomorph` if for each
  point `x : X`, the restriction of `f` to some open neighborhood `U` of `x` gives a homeomorphism
  between `U` and an open subset of `Y`.

  Note that `is_locally_homeomorph` is a global condition. This is in contrast to
  `local_homeomorph`, which is a homeomorphism between specific open subsets.
-/


open TopologicalSpace

variable {X Y Z : Type _} [TopologicalSpace X] [TopologicalSpace Y] [TopologicalSpace Z] (g : Y → Z)
  (f : X → Y) (s : Set X) (t : Set Y)

/-- A function `f : X → Y` satisfies `is_locally_homeomorph_on f s` if each `x ∈ s` is contained in
the source of some `e : local_homeomorph X Y` with `f = e`. -/
def IsLocallyHomeomorphOn :=
  ∀ x ∈ s, ∃ e : LocalHomeomorph X Y, x ∈ e.source ∧ f = e
#align is_locally_homeomorph_on IsLocallyHomeomorphOn

namespace IsLocallyHomeomorphOn

/-- Proves that `f` satisfies `is_locally_homeomorph_on f s`. The condition `h` is weaker than the
definition of `is_locally_homeomorph_on f s`, since it only requires `e : local_homeomorph X Y` to
agree with `f` on its source `e.source`, as opposed to on the whole space `X`. -/
theorem mk (h : ∀ x ∈ s, ∃ e : LocalHomeomorph X Y, x ∈ e.source ∧ ∀ y ∈ e.source, f y = e y) :
    IsLocallyHomeomorphOn f s := by 
  intro x hx
  obtain ⟨e, hx, he⟩ := h x hx
  exact
    ⟨{ e with 
        toFun := f
        map_source' := fun x hx => by rw [he x hx] <;> exact e.map_source' hx
        left_inv' := fun x hx => by rw [he x hx] <;> exact e.left_inv' hx
        right_inv' := fun y hy => by rw [he _ (e.map_target' hy)] <;> exact e.right_inv' hy
        continuous_to_fun := (continuous_on_congr he).mpr e.continuous_to_fun },
      hx, rfl⟩
#align is_locally_homeomorph_on.mk IsLocallyHomeomorphOn.mk

variable {g f s t}

theorem map_nhds_eq (hf : IsLocallyHomeomorphOn f s) {x : X} (hx : x ∈ s) : (𝓝 x).map f = 𝓝 (f x) :=
  let ⟨e, hx, he⟩ := hf x hx
  he.symm ▸ e.map_nhds_eq hx
#align is_locally_homeomorph_on.map_nhds_eq IsLocallyHomeomorphOn.map_nhds_eq

protected theorem continuous_at (hf : IsLocallyHomeomorphOn f s) {x : X} (hx : x ∈ s) :
    ContinuousAt f x :=
  (hf.map_nhds_eq hx).le
#align is_locally_homeomorph_on.continuous_at IsLocallyHomeomorphOn.continuous_at

protected theorem continuous_on (hf : IsLocallyHomeomorphOn f s) : ContinuousOn f s :=
  ContinuousAt.continuous_on fun x => hf.ContinuousAt
#align is_locally_homeomorph_on.continuous_on IsLocallyHomeomorphOn.continuous_on

protected theorem comp (hg : IsLocallyHomeomorphOn g t) (hf : IsLocallyHomeomorphOn f s)
    (h : Set.MapsTo f s t) : IsLocallyHomeomorphOn (g ∘ f) s := by
  intro x hx
  obtain ⟨eg, hxg, rfl⟩ := hg (f x) (h hx)
  obtain ⟨ef, hxf, rfl⟩ := hf x hx
  exact ⟨ef.trans eg, ⟨hxf, hxg⟩, rfl⟩
#align is_locally_homeomorph_on.comp IsLocallyHomeomorphOn.comp

end IsLocallyHomeomorphOn

/-- A function `f : X → Y` satisfies `is_locally_homeomorph f` if each `x : x` is contained in
  the source of some `e : local_homeomorph X Y` with `f = e`. -/
def IsLocallyHomeomorph :=
  ∀ x : X, ∃ e : LocalHomeomorph X Y, x ∈ e.source ∧ f = e
#align is_locally_homeomorph IsLocallyHomeomorph

variable {f}

theorem is_locally_homeomorph_iff_is_locally_homeomorph_on_univ :
    IsLocallyHomeomorph f ↔ IsLocallyHomeomorphOn f Set.univ := by
  simp only [IsLocallyHomeomorph, IsLocallyHomeomorphOn, Set.mem_univ, forall_true_left]
#align
  is_locally_homeomorph_iff_is_locally_homeomorph_on_univ is_locally_homeomorph_iff_is_locally_homeomorph_on_univ

protected theorem IsLocallyHomeomorph.is_locally_homeomorph_on (hf : IsLocallyHomeomorph f) :
    IsLocallyHomeomorphOn f Set.univ :=
  is_locally_homeomorph_iff_is_locally_homeomorph_on_univ.mp hf
#align is_locally_homeomorph.is_locally_homeomorph_on IsLocallyHomeomorph.is_locally_homeomorph_on

variable (f)

namespace IsLocallyHomeomorph

/-- Proves that `f` satisfies `is_locally_homeomorph f`. The condition `h` is weaker than the
definition of `is_locally_homeomorph f`, since it only requires `e : local_homeomorph X Y` to
agree with `f` on its source `e.source`, as opposed to on the whole space `X`. -/
theorem mk (h : ∀ x : X, ∃ e : LocalHomeomorph X Y, x ∈ e.source ∧ ∀ y ∈ e.source, f y = e y) :
    IsLocallyHomeomorph f :=
  is_locally_homeomorph_iff_is_locally_homeomorph_on_univ.mpr
    (IsLocallyHomeomorphOn.mk f Set.univ fun x hx => h x)
#align is_locally_homeomorph.mk IsLocallyHomeomorph.mk

variable {g f}

theorem map_nhds_eq (hf : IsLocallyHomeomorph f) (x : X) : (𝓝 x).map f = 𝓝 (f x) :=
  hf.IsLocallyHomeomorphOn.map_nhds_eq (Set.mem_univ x)
#align is_locally_homeomorph.map_nhds_eq IsLocallyHomeomorph.map_nhds_eq

protected theorem continuous (hf : IsLocallyHomeomorph f) : Continuous f :=
  continuous_iff_continuous_on_univ.mpr hf.IsLocallyHomeomorphOn.ContinuousOn
#align is_locally_homeomorph.continuous IsLocallyHomeomorph.continuous

protected theorem is_open_map (hf : IsLocallyHomeomorph f) : IsOpenMap f :=
  IsOpenMap.of_nhds_le fun x => ge_of_eq (hf.map_nhds_eq x)
#align is_locally_homeomorph.is_open_map IsLocallyHomeomorph.is_open_map

protected theorem comp (hg : IsLocallyHomeomorph g) (hf : IsLocallyHomeomorph f) :
    IsLocallyHomeomorph (g ∘ f) :=
  is_locally_homeomorph_iff_is_locally_homeomorph_on_univ.mpr
    (hg.IsLocallyHomeomorphOn.comp hf.IsLocallyHomeomorphOn (Set.univ.maps_to_univ f))
#align is_locally_homeomorph.comp IsLocallyHomeomorph.comp

end IsLocallyHomeomorph

