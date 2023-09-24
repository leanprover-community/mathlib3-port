/-
Copyright (c) 2021 Thomas Browning. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Thomas Browning
-/
import Topology.LocalHomeomorph

#align_import topology.is_locally_homeomorph from "leanprover-community/mathlib"@"23aa88e32dcc9d2a24cca7bc23268567ed4cd7d6"

/-!
# Local homeomorphisms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines local homeomorphisms.

## Main definitions

* `is_locally_homeomorph`: A function `f : X → Y` satisfies `is_locally_homeomorph` if for each
  point `x : X`, the restriction of `f` to some open neighborhood `U` of `x` gives a homeomorphism
  between `U` and an open subset of `Y`.

  Note that `is_locally_homeomorph` is a global condition. This is in contrast to
  `local_homeomorph`, which is a homeomorphism between specific open subsets.
-/


open scoped Topology

variable {X Y Z : Type _} [TopologicalSpace X] [TopologicalSpace Y] [TopologicalSpace Z] (g : Y → Z)
  (f : X → Y) (s : Set X) (t : Set Y)

#print IsLocallyHomeomorphOn /-
/-- A function `f : X → Y` satisfies `is_locally_homeomorph_on f s` if each `x ∈ s` is contained in
the source of some `e : local_homeomorph X Y` with `f = e`. -/
def IsLocallyHomeomorphOn :=
  ∀ x ∈ s, ∃ e : LocalHomeomorph X Y, x ∈ e.source ∧ f = e
#align is_locally_homeomorph_on IsLocallyHomeomorphOn
-/

namespace IsLocallyHomeomorphOn

#print IsLocallyHomeomorphOn.mk /-
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
        continuous_toFun := (continuousOn_congr he).mpr e.continuous_to_fun },
      hx, rfl⟩
#align is_locally_homeomorph_on.mk IsLocallyHomeomorphOn.mk
-/

variable {g f s t}

#print IsLocallyHomeomorphOn.map_nhds_eq /-
theorem map_nhds_eq (hf : IsLocallyHomeomorphOn f s) {x : X} (hx : x ∈ s) : (𝓝 x).map f = 𝓝 (f x) :=
  let ⟨e, hx, he⟩ := hf x hx
  he.symm ▸ e.map_nhds_eq hx
#align is_locally_homeomorph_on.map_nhds_eq IsLocallyHomeomorphOn.map_nhds_eq
-/

#print IsLocallyHomeomorphOn.continuousAt /-
protected theorem continuousAt (hf : IsLocallyHomeomorphOn f s) {x : X} (hx : x ∈ s) :
    ContinuousAt f x :=
  (hf.map_nhds_eq hx).le
#align is_locally_homeomorph_on.continuous_at IsLocallyHomeomorphOn.continuousAt
-/

#print IsLocallyHomeomorphOn.continuousOn /-
protected theorem continuousOn (hf : IsLocallyHomeomorphOn f s) : ContinuousOn f s :=
  ContinuousAt.continuousOn fun x => hf.ContinuousAt
#align is_locally_homeomorph_on.continuous_on IsLocallyHomeomorphOn.continuousOn
-/

#print IsLocallyHomeomorphOn.comp /-
protected theorem comp (hg : IsLocallyHomeomorphOn g t) (hf : IsLocallyHomeomorphOn f s)
    (h : Set.MapsTo f s t) : IsLocallyHomeomorphOn (g ∘ f) s :=
  by
  intro x hx
  obtain ⟨eg, hxg, rfl⟩ := hg (f x) (h hx)
  obtain ⟨ef, hxf, rfl⟩ := hf x hx
  exact ⟨ef.trans eg, ⟨hxf, hxg⟩, rfl⟩
#align is_locally_homeomorph_on.comp IsLocallyHomeomorphOn.comp
-/

end IsLocallyHomeomorphOn

#print IsLocallyHomeomorph /-
/-- A function `f : X → Y` satisfies `is_locally_homeomorph f` if each `x : x` is contained in
  the source of some `e : local_homeomorph X Y` with `f = e`. -/
def IsLocallyHomeomorph :=
  ∀ x : X, ∃ e : LocalHomeomorph X Y, x ∈ e.source ∧ f = e
#align is_locally_homeomorph IsLocallyHomeomorph
-/

variable {f}

#print isLocallyHomeomorph_iff_isLocallyHomeomorphOn_univ /-
theorem isLocallyHomeomorph_iff_isLocallyHomeomorphOn_univ :
    IsLocallyHomeomorph f ↔ IsLocallyHomeomorphOn f Set.univ := by
  simp only [IsLocallyHomeomorph, IsLocallyHomeomorphOn, Set.mem_univ, forall_true_left]
#align is_locally_homeomorph_iff_is_locally_homeomorph_on_univ isLocallyHomeomorph_iff_isLocallyHomeomorphOn_univ
-/

#print IsLocallyHomeomorph.isLocallyHomeomorphOn /-
protected theorem IsLocallyHomeomorph.isLocallyHomeomorphOn (hf : IsLocallyHomeomorph f) :
    IsLocallyHomeomorphOn f Set.univ :=
  isLocallyHomeomorph_iff_isLocallyHomeomorphOn_univ.mp hf
#align is_locally_homeomorph.is_locally_homeomorph_on IsLocallyHomeomorph.isLocallyHomeomorphOn
-/

variable (f)

namespace IsLocallyHomeomorph

#print IsLocallyHomeomorph.mk /-
/-- Proves that `f` satisfies `is_locally_homeomorph f`. The condition `h` is weaker than the
definition of `is_locally_homeomorph f`, since it only requires `e : local_homeomorph X Y` to
agree with `f` on its source `e.source`, as opposed to on the whole space `X`. -/
theorem mk (h : ∀ x : X, ∃ e : LocalHomeomorph X Y, x ∈ e.source ∧ ∀ y ∈ e.source, f y = e y) :
    IsLocallyHomeomorph f :=
  isLocallyHomeomorph_iff_isLocallyHomeomorphOn_univ.mpr
    (IsLocallyHomeomorphOn.mk f Set.univ fun x hx => h x)
#align is_locally_homeomorph.mk IsLocallyHomeomorph.mk
-/

variable {g f}

#print IsLocallyHomeomorph.map_nhds_eq /-
theorem map_nhds_eq (hf : IsLocallyHomeomorph f) (x : X) : (𝓝 x).map f = 𝓝 (f x) :=
  hf.IsLocallyHomeomorphOn.map_nhds_eq (Set.mem_univ x)
#align is_locally_homeomorph.map_nhds_eq IsLocallyHomeomorph.map_nhds_eq
-/

#print IsLocallyHomeomorph.continuous /-
protected theorem continuous (hf : IsLocallyHomeomorph f) : Continuous f :=
  continuous_iff_continuousOn_univ.mpr hf.IsLocallyHomeomorphOn.ContinuousOn
#align is_locally_homeomorph.continuous IsLocallyHomeomorph.continuous
-/

#print IsLocallyHomeomorph.isOpenMap /-
protected theorem isOpenMap (hf : IsLocallyHomeomorph f) : IsOpenMap f :=
  IsOpenMap.of_nhds_le fun x => ge_of_eq (hf.map_nhds_eq x)
#align is_locally_homeomorph.is_open_map IsLocallyHomeomorph.isOpenMap
-/

#print IsLocallyHomeomorph.comp /-
protected theorem comp (hg : IsLocallyHomeomorph g) (hf : IsLocallyHomeomorph f) :
    IsLocallyHomeomorph (g ∘ f) :=
  isLocallyHomeomorph_iff_isLocallyHomeomorphOn_univ.mpr
    (hg.IsLocallyHomeomorphOn.comp hf.IsLocallyHomeomorphOn (Set.univ.mapsTo_univ f))
#align is_locally_homeomorph.comp IsLocallyHomeomorph.comp
-/

end IsLocallyHomeomorph

