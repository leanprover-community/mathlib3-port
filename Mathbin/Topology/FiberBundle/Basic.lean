/-
Copyright (c) 2019 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel
-/
import Mathbin.Topology.FiberBundle.Trivialization

/-!
# Fiber bundles

A topological fiber bundle with fiber `F` over a base `B` is a space projecting on `B` for which the
fibers are all homeomorphic to `F`, such that the local situation around each point is a direct
product. We define a predicate `is_topological_fiber_bundle F p` saying that `p : Z → B` is a
topological fiber bundle with fiber `F`.

It is in general nontrivial to construct a fiber bundle. A way is to start from the knowledge of
how changes of local trivializations act on the fiber. From this, one can construct the total space
of the bundle and its topology by a suitable gluing construction. The main content of this file is
an implementation of this construction: starting from an object of type
`topological_fiber_bundle_core` registering the trivialization changes, one gets the corresponding
fiber bundle and projection.

Similarly we implement the object `topological_fiber_prebundle` which allows to define a topological
fiber bundle from trivializations given as local equivalences with minimum additional properties.

## Main definitions

### Basic definitions

* `is_topological_fiber_bundle F p` : Prop saying that the map `p` between topological spaces is a
                  fiber bundle with fiber `F`.

* `is_trivial_topological_fiber_bundle F p` : Prop saying that the map `p : Z → B` between
  topological spaces is a trivial topological fiber bundle, i.e., there exists a homeomorphism
  `h : Z ≃ₜ B × F` such that `proj x = (h x).1`.

### Operations on bundles

* `is_topological_fiber_bundle.comap`: if `p : Z → B` is a topological fiber bundle, then its
  pullback along a continuous map `f : B' → B` is a topological fiber bundle as well.

* `is_topological_fiber_bundle.comp_homeomorph`: if `p : Z → B` is a topological fiber bundle
  and `h : Z' ≃ₜ Z` is a homeomorphism, then `p ∘ h : Z' → B` is a topological fiber bundle with
  the same fiber.

### Construction of a bundle from trivializations

* `bundle.total_space E` is a type synonym for `Σ (x : B), E x`, that we can endow with a suitable
  topology.
* `topological_fiber_bundle_core ι B F` : structure registering how changes of coordinates act
  on the fiber `F` above open subsets of `B`, where local trivializations are indexed by `ι`.

Let `Z : topological_fiber_bundle_core ι B F`. Then we define

* `Z.fiber x`     : the fiber above `x`, homeomorphic to `F` (and defeq to `F` as a type).
* `Z.total_space` : the total space of `Z`, defined as a `Type` as `Σ (b : B), F`, but with a
  twisted topology coming from the fiber bundle structure. It is (reducibly) the same as
  `bundle.total_space Z.fiber`.
* `Z.proj`        : projection from `Z.total_space` to `B`. It is continuous.
* `Z.local_triv i`: for `i : ι`, bundle trivialization above the set `Z.base_set i`, which is an
                    open set in `B`.

* `topological_fiber_prebundle F proj` : structure registering a cover of prebundle trivializations
  and requiring that the relative transition maps are local homeomorphisms.
* `topological_fiber_prebundle.total_space_topology a` : natural topology of the total space, making
  the prebundle into a bundle.

## Implementation notes

### Core construction

A topological fiber bundle with fiber `F` over a base `B` is a family of spaces isomorphic to `F`,
indexed by `B`, which is locally trivial in the following sense: there is a covering of `B` by open
sets such that, on each such open set `s`, the bundle is isomorphic to `s × F`.

To construct a fiber bundle formally, the main data is what happens when one changes trivializations
from `s × F` to `s' × F` on `s ∩ s'`: one should get a family of homeomorphisms of `F`, depending
continuously on the base point, satisfying basic compatibility conditions (cocycle property).
Useful classes of bundles can then be specified by requiring that these homeomorphisms of `F`
belong to some subgroup, preserving some structure (the "structure group of the bundle"): then
these structures are inherited by the fibers of the bundle.

Given such trivialization change data (encoded below in a structure called
`topological_fiber_bundle_core`), one can construct the fiber bundle. The intrinsic canonical
mathematical construction is the following.
The fiber above `x` is the disjoint union of `F` over all trivializations, modulo the gluing
identifications: one gets a fiber which is isomorphic to `F`, but non-canonically
(each choice of one of the trivializations around `x` gives such an isomorphism). Given a
trivialization over a set `s`, one gets an isomorphism between `s × F` and `proj^{-1} s`, by using
the identification corresponding to this trivialization. One chooses the topology on the bundle that
makes all of these into homeomorphisms.

For the practical implementation, it turns out to be more convenient to avoid completely the
gluing and quotienting construction above, and to declare above each `x` that the fiber is `F`,
but thinking that it corresponds to the `F` coming from the choice of one trivialization around `x`.
This has several practical advantages:
* without any work, one gets a topological space structure on the fiber. And if `F` has more
structure it is inherited for free by the fiber.
* In the case of the tangent bundle of manifolds, this implies that on vector spaces the derivative
(from `F` to `F`) and the manifold derivative (from `tangent_space I x` to `tangent_space I' (f x)`)
are equal.

A drawback is that some silly constructions will typecheck: in the case of the tangent bundle, one
can add two vectors in different tangent spaces (as they both are elements of `F` from the point of
view of Lean). To solve this, one could mark the tangent space as irreducible, but then one would
lose the identification of the tangent space to `F` with `F`. There is however a big advantage of
this situation: even if Lean can not check that two basepoints are defeq, it will accept the fact
that the tangent spaces are the same. For instance, if two maps `f` and `g` are locally inverse to
each other, one can express that the composition of their derivatives is the identity of
`tangent_space I x`. One could fear issues as this composition goes from `tangent_space I x` to
`tangent_space I (g (f x))` (which should be the same, but should not be obvious to Lean
as it does not know that `g (f x) = x`). As these types are the same to Lean (equal to `F`), there
are in fact no dependent type difficulties here!

For this construction of a fiber bundle from a `topological_fiber_bundle_core`, we should thus
choose for each `x` one specific trivialization around it. We include this choice in the definition
of the `topological_fiber_bundle_core`, as it makes some constructions more
functorial and it is a nice way to say that the trivializations cover the whole space `B`.

With this definition, the type of the fiber bundle space constructed from the core data is just
`Σ (b : B), F `, but the topology is not the product one, in general.

We also take the indexing type (indexing all the trivializations) as a parameter to the fiber bundle
core: it could always be taken as a subtype of all the maps from open subsets of `B` to continuous
maps of `F`, but in practice it will sometimes be something else. For instance, on a manifold, one
will use the set of charts as a good parameterization for the trivializations of the tangent bundle.
Or for the pullback of a `topological_fiber_bundle_core`, the indexing type will be the same as
for the initial bundle.

## Tags
Fiber bundle, topological bundle, structure group
-/


variable {ι : Type _} {B : Type _} {F : Type _}

open TopologicalSpace Filter Set Bundle

open TopologicalSpace Classical

/-! ### General definition of topological fiber bundles -/


section TopologicalFiberBundle

variable (F) {Z : Type _} [TopologicalSpace B] [TopologicalSpace F] {proj : Z → B}

variable [TopologicalSpace Z]

/-- A topological fiber bundle with fiber `F` over a base `B` is a space projecting on `B`
for which the fibers are all homeomorphic to `F`, such that the local situation around each point
is a direct product. -/
def IsTopologicalFiberBundle (proj : Z → B) : Prop :=
  ∀ x : B, ∃ e : Trivialization F proj, x ∈ e.baseSet
#align is_topological_fiber_bundle IsTopologicalFiberBundle

/-- A trivial topological fiber bundle with fiber `F` over a base `B` is a space `Z`
projecting on `B` for which there exists a homeomorphism to `B × F` that sends `proj`
to `prod.fst`. -/
def IsTrivialTopologicalFiberBundle (proj : Z → B) : Prop :=
  ∃ e : Z ≃ₜ B × F, ∀ x, (e x).1 = proj x
#align is_trivial_topological_fiber_bundle IsTrivialTopologicalFiberBundle

variable {F}

theorem IsTrivialTopologicalFiberBundle.is_topological_fiber_bundle (h : IsTrivialTopologicalFiberBundle F proj) :
    IsTopologicalFiberBundle F proj :=
  let ⟨e, he⟩ := h
  fun x => ⟨⟨e.toLocalHomeomorph, univ, is_open_univ, rfl, univ_prod_univ.symm, fun x _ => he x⟩, mem_univ x⟩
#align
  is_trivial_topological_fiber_bundle.is_topological_fiber_bundle IsTrivialTopologicalFiberBundle.is_topological_fiber_bundle

theorem IsTopologicalFiberBundle.map_proj_nhds (h : IsTopologicalFiberBundle F proj) (x : Z) :
    map proj (𝓝 x) = 𝓝 (proj x) :=
  let ⟨e, ex⟩ := h (proj x)
  e.map_proj_nhds <| e.mem_source.2 ex
#align is_topological_fiber_bundle.map_proj_nhds IsTopologicalFiberBundle.map_proj_nhds

/-- The projection from a topological fiber bundle to its base is continuous. -/
theorem IsTopologicalFiberBundle.continuous_proj (h : IsTopologicalFiberBundle F proj) : Continuous proj :=
  continuous_iff_continuous_at.2 fun x => (h.map_proj_nhds _).le
#align is_topological_fiber_bundle.continuous_proj IsTopologicalFiberBundle.continuous_proj

/-- The projection from a topological fiber bundle to its base is an open map. -/
theorem IsTopologicalFiberBundle.is_open_map_proj (h : IsTopologicalFiberBundle F proj) : IsOpenMap proj :=
  IsOpenMap.of_nhds_le fun x => (h.map_proj_nhds x).ge
#align is_topological_fiber_bundle.is_open_map_proj IsTopologicalFiberBundle.is_open_map_proj

/-- The projection from a topological fiber bundle with a nonempty fiber to its base is a surjective
map. -/
theorem IsTopologicalFiberBundle.surjective_proj [Nonempty F] (h : IsTopologicalFiberBundle F proj) :
    Function.Surjective proj := fun b =>
  let ⟨e, eb⟩ := h b
  let ⟨x, _, hx⟩ := e.proj_surj_on_base_set eb
  ⟨x, hx⟩
#align is_topological_fiber_bundle.surjective_proj IsTopologicalFiberBundle.surjective_proj

/-- The projection from a topological fiber bundle with a nonempty fiber to its base is a quotient
map. -/
theorem IsTopologicalFiberBundle.quotient_map_proj [Nonempty F] (h : IsTopologicalFiberBundle F proj) :
    QuotientMap proj :=
  h.is_open_map_proj.to_quotient_map h.continuous_proj h.surjective_proj
#align is_topological_fiber_bundle.quotient_map_proj IsTopologicalFiberBundle.quotient_map_proj

/-- The first projection in a product is a trivial topological fiber bundle. -/
theorem is_trivial_topological_fiber_bundle_fst : IsTrivialTopologicalFiberBundle F (Prod.fst : B × F → B) :=
  ⟨Homeomorph.refl _, fun x => rfl⟩
#align is_trivial_topological_fiber_bundle_fst is_trivial_topological_fiber_bundle_fst

/-- The first projection in a product is a topological fiber bundle. -/
theorem is_topological_fiber_bundle_fst : IsTopologicalFiberBundle F (Prod.fst : B × F → B) :=
  is_trivial_topological_fiber_bundle_fst.IsTopologicalFiberBundle
#align is_topological_fiber_bundle_fst is_topological_fiber_bundle_fst

/-- The second projection in a product is a trivial topological fiber bundle. -/
theorem is_trivial_topological_fiber_bundle_snd : IsTrivialTopologicalFiberBundle F (Prod.snd : F × B → B) :=
  ⟨Homeomorph.prodComm _ _, fun x => rfl⟩
#align is_trivial_topological_fiber_bundle_snd is_trivial_topological_fiber_bundle_snd

/-- The second projection in a product is a topological fiber bundle. -/
theorem is_topological_fiber_bundle_snd : IsTopologicalFiberBundle F (Prod.snd : F × B → B) :=
  is_trivial_topological_fiber_bundle_snd.IsTopologicalFiberBundle
#align is_topological_fiber_bundle_snd is_topological_fiber_bundle_snd

theorem IsTopologicalFiberBundle.comp_homeomorph {Z' : Type _} [TopologicalSpace Z']
    (e : IsTopologicalFiberBundle F proj) (h : Z' ≃ₜ Z) : IsTopologicalFiberBundle F (proj ∘ h) := fun x =>
  let ⟨e, he⟩ := e x
  ⟨e.comp_homeomorph h, by simpa [Trivialization.compHomeomorph] using he⟩
#align is_topological_fiber_bundle.comp_homeomorph IsTopologicalFiberBundle.comp_homeomorph

section Comap

open Classical

variable {B' : Type _} [TopologicalSpace B']

/-- If `proj : Z → B` is a topological fiber bundle with fiber `F` and `f : B' → B` is a continuous
map, then the pullback bundle (a.k.a. induced bundle) is the topological bundle with the total space
`{(x, y) : B' × Z | f x = proj y}` given by `λ ⟨(x, y), h⟩, x`. -/
theorem IsTopologicalFiberBundle.comap (h : IsTopologicalFiberBundle F proj) {f : B' → B} (hf : Continuous f) :
    IsTopologicalFiberBundle F fun x : { p : B' × Z | f p.1 = proj p.2 } => (x : B' × Z).1 := fun x =>
  let ⟨e, he⟩ := h (f x)
  ⟨e.comap f hf x he, he⟩
#align is_topological_fiber_bundle.comap IsTopologicalFiberBundle.comap

end Comap

/-- If `h` is a topological fiber bundle over a conditionally complete linear order,
then it is trivial over any closed interval. -/
theorem IsTopologicalFiberBundle.exists_trivialization_Icc_subset [ConditionallyCompleteLinearOrder B] [OrderTopology B]
    (h : IsTopologicalFiberBundle F proj) (a b : B) : ∃ e : Trivialization F proj, icc a b ⊆ e.baseSet := by
  classical obtain ⟨ea, hea⟩ : ∃ ea : Trivialization F proj, a ∈ ea.baseSet := h a
    /- Let `s` be the set of points `x ∈ [a, b]` such that `proj` is trivializable over `[a, x]`.
      We need to show that `b ∈ s`. Let `c = Sup s`. We will show that `c ∈ s` and `c = b`. -/
    set s : Set B := { x ∈ Icc a b | ∃ e : Trivialization F proj, Icc a x ⊆ e.baseSet }
    exact ⟨left_mem_Icc.2 hab, ea, by simp [hea]⟩
    have hsb : b ∈ upperBounds s
    have sbd : BddAbove s := ⟨b, hsb⟩
    have hsc : IsLub s c
    have hc : c ∈ Icc a b
    obtain ⟨-, ec : Trivialization F proj, hec : Icc a c ⊆ ec.base_set⟩ : c ∈ s
    /- So, `c ∈ s`. Let `ec` be a trivialization of `proj` over `[a, c]`.  If `c = b`, then we are
      done. Otherwise we show that `proj` can be trivialized over a larger interval `[a, d]`,
      `d ∈ (c, b]`, hence `c` is not an upper bound of `s`. -/
    cases' hc.2.eq_or_lt with heq hlt
    rsuffices ⟨d, hdcb, hd⟩ : ∃ d ∈ Ioc c b, ∃ e : Trivialization F proj, Icc a d ⊆ e.baseSet
    /- Since the base set of `ec` is open, it includes `[c, d)` (hence, `[a, d)`) for some
      `d ∈ (c, b]`. -/
    obtain ⟨d, hdcb, hd⟩ : ∃ d ∈ Ioc c b, Ico c d ⊆ ec.base_set :=
      (mem_nhds_within_Ici_iff_exists_mem_Ioc_Ico_subset hlt).1
        (mem_nhds_within_of_mem_nhds <| IsOpen.mem_nhds ec.open_base_set (hec ⟨hc.1, le_rfl⟩))
    exact Ico_subset_Icc_union_Ico.trans (union_subset hec hd)
    · /- If `(c, d) = ∅`, then let `ed` be a trivialization of `proj` over a neighborhood of `d`.
          Then the disjoint union of `ec` restricted to `(-∞, d)` and `ed` restricted to `(c, ∞)` is
          a trivialization over `[a, d]`. -/
      rcases h d with ⟨ed, hed⟩
      refine'
        ⟨d, hdcb,
          (ec.restr_open (Iio d) is_open_Iio).disjointUnion (ed.restr_open (Ioi c) is_open_Ioi)
            (he.mono (inter_subset_right _ _) (inter_subset_right _ _)),
          fun x hx => _⟩
      rcases hx.2.eq_or_lt with (rfl | hxd)
      exacts[Or.inr ⟨hed, hdcb.1⟩, Or.inl ⟨had ⟨hx.1, hxd⟩, hxd⟩]
      
#align
  is_topological_fiber_bundle.exists_trivialization_Icc_subset IsTopologicalFiberBundle.exists_trivialization_Icc_subset

end TopologicalFiberBundle

/-! ### Constructing topological fiber bundles -/


namespace Bundle

variable (E : B → Type _)

attribute [mfld_simps]
  total_space.proj total_space_mk coe_fst coe_snd coe_snd_map_apply coe_snd_map_smul total_space.mk_cast

instance [I : TopologicalSpace F] : ∀ x : B, TopologicalSpace (Trivial B F x) := fun x => I

instance [t₁ : TopologicalSpace B] [t₂ : TopologicalSpace F] : TopologicalSpace (TotalSpace (Trivial B F)) :=
  induced TotalSpace.proj t₁ ⊓ induced (Trivial.projSnd B F) t₂

end Bundle

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- Core data defining a locally trivial topological bundle with fiber `F` over a topological
space `B`. Note that "bundle" is used in its mathematical sense. This is the (computer science)
bundled version, i.e., all the relevant data is contained in the following structure. A family of
local trivializations is indexed by a type `ι`, on open subsets `base_set i` for each `i : ι`.
Trivialization changes from `i` to `j` are given by continuous maps `coord_change i j` from
`base_set i ∩ base_set j` to the set of homeomorphisms of `F`, but we express them as maps
`B → F → F` and require continuity on `(base_set i ∩ base_set j) × F` to avoid the topology on the
space of continuous maps on `F`. -/
@[nolint has_nonempty_instance]
structure TopologicalFiberBundleCore (ι : Type _) (B : Type _) [TopologicalSpace B] (F : Type _)
  [TopologicalSpace F] where
  baseSet : ι → Set B
  is_open_base_set : ∀ i, IsOpen (base_set i)
  indexAt : B → ι
  mem_base_set_at : ∀ x, x ∈ base_set (index_at x)
  coordChange : ι → ι → B → F → F
  coord_change_self : ∀ i, ∀ x ∈ base_set i, ∀ v, coord_change i i x v = v
  coord_change_continuous :
    ∀ i j, ContinuousOn (fun p : B × F => coord_change i j p.1 p.2) ((base_set i ∩ base_set j) ×ˢ univ)
  coord_change_comp :
    ∀ i j k,
      ∀ x ∈ base_set i ∩ base_set j ∩ base_set k,
        ∀ v, (coord_change j k x) (coord_change i j x v) = coord_change i k x v
#align topological_fiber_bundle_core TopologicalFiberBundleCore

namespace TopologicalFiberBundleCore

variable [TopologicalSpace B] [TopologicalSpace F] (Z : TopologicalFiberBundleCore ι B F)

include Z

/-- The index set of a topological fiber bundle core, as a convenience function for dot notation -/
@[nolint unused_arguments has_nonempty_instance]
def Index :=
  ι
#align topological_fiber_bundle_core.index TopologicalFiberBundleCore.Index

/-- The base space of a topological fiber bundle core, as a convenience function for dot notation -/
@[nolint unused_arguments, reducible]
def Base :=
  B
#align topological_fiber_bundle_core.base TopologicalFiberBundleCore.Base

/-- The fiber of a topological fiber bundle core, as a convenience function for dot notation and
typeclass inference -/
@[nolint unused_arguments has_nonempty_instance]
def Fiber (x : B) :=
  F
#align topological_fiber_bundle_core.fiber TopologicalFiberBundleCore.Fiber

section FiberInstances

attribute [local reducible] fiber

instance topologicalSpaceFiber (x : B) : TopologicalSpace (Z.Fiber x) := by infer_instance
#align topological_fiber_bundle_core.topological_space_fiber TopologicalFiberBundleCore.topologicalSpaceFiber

end FiberInstances

/-- The total space of the topological fiber bundle, as a convenience function for dot notation.
It is by definition equal to `bundle.total_space Z.fiber`, a.k.a. `Σ x, Z.fiber x` but with a
different name for typeclass inference. -/
@[nolint unused_arguments, reducible]
def TotalSpace :=
  Bundle.TotalSpace Z.Fiber
#align topological_fiber_bundle_core.total_space TopologicalFiberBundleCore.TotalSpace

/-- The projection from the total space of a topological fiber bundle core, on its base. -/
@[reducible, simp, mfld_simps]
def proj : Z.TotalSpace → B :=
  Bundle.TotalSpace.proj
#align topological_fiber_bundle_core.proj TopologicalFiberBundleCore.proj

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- Local homeomorphism version of the trivialization change. -/
def trivChange (i j : ι) : LocalHomeomorph (B × F) (B × F) where
  source := (Z.baseSet i ∩ Z.baseSet j) ×ˢ univ
  target := (Z.baseSet i ∩ Z.baseSet j) ×ˢ univ
  toFun p := ⟨p.1, Z.coordChange i j p.1 p.2⟩
  invFun p := ⟨p.1, Z.coordChange j i p.1 p.2⟩
  map_source' p hp := by simpa using hp
  map_target' p hp := by simpa using hp
  left_inv' := by
    rintro ⟨x, v⟩ hx
    simp only [prod_mk_mem_set_prod_eq, mem_inter_iff, and_true_iff, mem_univ] at hx
    rw [Z.coord_change_comp, Z.coord_change_self]
    · exact hx.1
      
    · simp [hx]
      
  right_inv' := by
    rintro ⟨x, v⟩ hx
    simp only [prod_mk_mem_set_prod_eq, mem_inter_iff, and_true_iff, mem_univ] at hx
    rw [Z.coord_change_comp, Z.coord_change_self]
    · exact hx.2
      
    · simp [hx]
      
  open_source := (IsOpen.inter (Z.is_open_base_set i) (Z.is_open_base_set j)).Prod is_open_univ
  open_target := (IsOpen.inter (Z.is_open_base_set i) (Z.is_open_base_set j)).Prod is_open_univ
  continuous_to_fun := ContinuousOn.prod continuous_fst.ContinuousOn (Z.coord_change_continuous i j)
  continuous_inv_fun := by
    simpa [inter_comm] using ContinuousOn.prod continuous_fst.continuous_on (Z.coord_change_continuous j i)
#align topological_fiber_bundle_core.triv_change TopologicalFiberBundleCore.trivChange

@[simp, mfld_simps]
theorem mem_triv_change_source (i j : ι) (p : B × F) :
    p ∈ (Z.trivChange i j).source ↔ p.1 ∈ Z.baseSet i ∩ Z.baseSet j := by
  erw [mem_prod]
  simp
#align topological_fiber_bundle_core.mem_triv_change_source TopologicalFiberBundleCore.mem_triv_change_source

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- Associate to a trivialization index `i : ι` the corresponding trivialization, i.e., a bijection
between `proj ⁻¹ (base_set i)` and `base_set i × F`. As the fiber above `x` is `F` but read in the
chart with index `index_at x`, the trivialization in the fiber above x is by definition the
coordinate change from i to `index_at x`, so it depends on `x`.
The local trivialization will ultimately be a local homeomorphism. For now, we only introduce the
local equiv version, denoted with a prime. In further developments, avoid this auxiliary version,
and use `Z.local_triv` instead.
-/
def localTrivAsLocalEquiv (i : ι) : LocalEquiv Z.TotalSpace (B × F) where
  source := Z.proj ⁻¹' Z.baseSet i
  target := Z.baseSet i ×ˢ univ
  invFun p := ⟨p.1, Z.coordChange i (Z.indexAt p.1) p.1 p.2⟩
  toFun p := ⟨p.1, Z.coordChange (Z.indexAt p.1) i p.1 p.2⟩
  map_source' p hp := by simpa only [Set.mem_preimage, and_true_iff, Set.mem_univ, Set.prod_mk_mem_set_prod_eq] using hp
  map_target' p hp := by simpa only [Set.mem_preimage, and_true_iff, Set.mem_univ, Set.mem_prod] using hp
  left_inv' := by
    rintro ⟨x, v⟩ hx
    change x ∈ Z.base_set i at hx
    dsimp only
    rw [Z.coord_change_comp, Z.coord_change_self]
    · exact Z.mem_base_set_at _
      
    · simp only [hx, mem_inter_iff, and_self_iff, mem_base_set_at]
      
  right_inv' := by
    rintro ⟨x, v⟩ hx
    simp only [prod_mk_mem_set_prod_eq, and_true_iff, mem_univ] at hx
    rw [Z.coord_change_comp, Z.coord_change_self]
    · exact hx
      
    · simp only [hx, mem_inter_iff, and_self_iff, mem_base_set_at]
      
#align topological_fiber_bundle_core.local_triv_as_local_equiv TopologicalFiberBundleCore.localTrivAsLocalEquiv

variable (i : ι)

theorem mem_local_triv_as_local_equiv_source (p : Z.TotalSpace) :
    p ∈ (Z.localTrivAsLocalEquiv i).source ↔ p.1 ∈ Z.baseSet i :=
  Iff.rfl
#align
  topological_fiber_bundle_core.mem_local_triv_as_local_equiv_source TopologicalFiberBundleCore.mem_local_triv_as_local_equiv_source

theorem mem_local_triv_as_local_equiv_target (p : B × F) : p ∈ (Z.localTrivAsLocalEquiv i).target ↔ p.1 ∈ Z.baseSet i :=
  by
  erw [mem_prod]
  simp only [and_true_iff, mem_univ]
#align
  topological_fiber_bundle_core.mem_local_triv_as_local_equiv_target TopologicalFiberBundleCore.mem_local_triv_as_local_equiv_target

theorem local_triv_as_local_equiv_apply (p : Z.TotalSpace) :
    (Z.localTrivAsLocalEquiv i) p = ⟨p.1, Z.coordChange (Z.indexAt p.1) i p.1 p.2⟩ :=
  rfl
#align
  topological_fiber_bundle_core.local_triv_as_local_equiv_apply TopologicalFiberBundleCore.local_triv_as_local_equiv_apply

/-- The composition of two local trivializations is the trivialization change Z.triv_change i j. -/
theorem local_triv_as_local_equiv_trans (i j : ι) :
    (Z.localTrivAsLocalEquiv i).symm.trans (Z.localTrivAsLocalEquiv j) ≈ (Z.trivChange i j).toLocalEquiv := by
  constructor
  · ext x
    simp only [mem_local_triv_as_local_equiv_target, mfld_simps]
    rfl
    
  · rintro ⟨x, v⟩ hx
    simp only [triv_change, local_triv_as_local_equiv, LocalEquiv.symm, true_and_iff, Prod.mk.inj_iff,
      prod_mk_mem_set_prod_eq, LocalEquiv.trans_source, mem_inter_iff, and_true_iff, mem_preimage, proj, mem_univ,
      LocalEquiv.coe_mk, eq_self_iff_true, LocalEquiv.coe_trans, total_space.proj] at hx⊢
    simp only [Z.coord_change_comp, hx, mem_inter_iff, and_self_iff, mem_base_set_at]
    
#align
  topological_fiber_bundle_core.local_triv_as_local_equiv_trans TopologicalFiberBundleCore.local_triv_as_local_equiv_trans

variable (ι)

/-- Topological structure on the total space of a topological bundle created from core, designed so
that all the local trivialization are continuous. -/
instance toTopologicalSpace : TopologicalSpace (Bundle.TotalSpace Z.Fiber) :=
  TopologicalSpace.generateFrom <| ⋃ (i : ι) (s : Set (B × F)) (s_open : IsOpen s), {(Z i).source ∩ Z i ⁻¹' s}
#align topological_fiber_bundle_core.to_topological_space TopologicalFiberBundleCore.toTopologicalSpace

variable {ι}

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem open_source' (i : ι) : IsOpen (Z.localTrivAsLocalEquiv i).source := by
  apply TopologicalSpace.GenerateOpen.basic
  simp only [exists_prop, mem_Union, mem_singleton_iff]
  refine' ⟨i, Z.base_set i ×ˢ univ, (Z.is_open_base_set i).Prod is_open_univ, _⟩
  ext p
  simp only [local_triv_as_local_equiv_apply, prod_mk_mem_set_prod_eq, mem_inter_iff, and_self_iff,
    mem_local_triv_as_local_equiv_source, and_true_iff, mem_univ, mem_preimage]
#align topological_fiber_bundle_core.open_source' TopologicalFiberBundleCore.open_source'

/-- Extended version of the local trivialization of a fiber bundle constructed from core,
registering additionally in its type that it is a local bundle trivialization. -/
def localTriv (i : ι) : Trivialization F Z.proj where
  baseSet := Z.baseSet i
  open_base_set := Z.is_open_base_set i
  source_eq := rfl
  target_eq := rfl
  proj_to_fun p hp := by
    simp only [mfld_simps]
    rfl
  open_source := Z.open_source' i
  open_target := (Z.is_open_base_set i).Prod is_open_univ
  continuous_to_fun := by
    rw [continuous_on_open_iff (Z.open_source' i)]
    intro s s_open
    apply TopologicalSpace.GenerateOpen.basic
    simp only [exists_prop, mem_Union, mem_singleton_iff]
    exact ⟨i, s, s_open, rfl⟩
  continuous_inv_fun := by
    apply continuous_on_open_of_generate_from ((Z.is_open_base_set i).Prod is_open_univ)
    intro t ht
    simp only [exists_prop, mem_Union, mem_singleton_iff] at ht
    obtain ⟨j, s, s_open, ts⟩ :
      ∃ j s, IsOpen s ∧ t = (local_triv_as_local_equiv Z j).source ∩ local_triv_as_local_equiv Z j ⁻¹' s := ht
    rw [ts]
    simp only [LocalEquiv.right_inv, preimage_inter, LocalEquiv.left_inv]
    let e := Z.local_triv_as_local_equiv i
    let e' := Z.local_triv_as_local_equiv j
    let f := e.symm.trans e'
    have : IsOpen (f.source ∩ f ⁻¹' s) := by
      rw [(Z.local_triv_as_local_equiv_trans i j).source_inter_preimage_eq]
      exact (continuous_on_open_iff (Z.triv_change i j).open_source).1 (Z.triv_change i j).ContinuousOn _ s_open
    convert this using 1
    dsimp [LocalEquiv.trans_source]
    rw [← preimage_comp, inter_assoc]
    rfl
  toLocalEquiv := Z.localTrivAsLocalEquiv i
#align topological_fiber_bundle_core.local_triv TopologicalFiberBundleCore.localTriv

/-- A topological fiber bundle constructed from core is indeed a topological fiber bundle. -/
protected theorem is_topological_fiber_bundle : IsTopologicalFiberBundle F Z.proj := fun x =>
  ⟨Z.localTriv (Z.indexAt x), Z.mem_base_set_at x⟩
#align topological_fiber_bundle_core.is_topological_fiber_bundle TopologicalFiberBundleCore.is_topological_fiber_bundle

/-- The projection on the base of a topological bundle created from core is continuous -/
theorem continuous_proj : Continuous Z.proj :=
  Z.IsTopologicalFiberBundle.continuous_proj
#align topological_fiber_bundle_core.continuous_proj TopologicalFiberBundleCore.continuous_proj

/-- The projection on the base of a topological bundle created from core is an open map -/
theorem is_open_map_proj : IsOpenMap Z.proj :=
  Z.IsTopologicalFiberBundle.is_open_map_proj
#align topological_fiber_bundle_core.is_open_map_proj TopologicalFiberBundleCore.is_open_map_proj

/-- Preferred local trivialization of a fiber bundle constructed from core, at a given point, as
a bundle trivialization -/
def localTrivAt (b : B) : Trivialization F Z.proj :=
  Z.localTriv (Z.indexAt b)
#align topological_fiber_bundle_core.local_triv_at TopologicalFiberBundleCore.localTrivAt

@[simp, mfld_simps]
theorem local_triv_at_def (b : B) : Z.localTriv (Z.indexAt b) = Z.localTrivAt b :=
  rfl
#align topological_fiber_bundle_core.local_triv_at_def TopologicalFiberBundleCore.local_triv_at_def

/-- If an element of `F` is invariant under all coordinate changes, then one can define a
corresponding section of the fiber bundle, which is continuous. This applies in particular to the
zero section of a vector bundle. Another example (not yet defined) would be the identity
section of the endomorphism bundle of a vector bundle. -/
theorem continuous_const_section (v : F) (h : ∀ i j, ∀ x ∈ Z.baseSet i ∩ Z.baseSet j, Z.coordChange i j x v = v) :
    Continuous (show B → Z.TotalSpace from fun x => ⟨x, v⟩) := by
  apply continuous_iff_continuous_at.2 fun x => _
  have A : Z.base_set (Z.index_at x) ∈ 𝓝 x := IsOpen.mem_nhds (Z.is_open_base_set (Z.index_at x)) (Z.mem_base_set_at x)
  apply ((Z.local_triv_at x).toLocalHomeomorph.continuous_at_iff_continuous_at_comp_left _).2
  · simp only [(· ∘ ·), mfld_simps]
    apply continuous_at_id.prod
    have : ContinuousOn (fun y : B => v) (Z.base_set (Z.index_at x)) := continuous_on_const
    apply (this.congr _).ContinuousAt A
    intro y hy
    simp only [h, hy, mem_base_set_at, mfld_simps]
    
  · exact A
    
#align topological_fiber_bundle_core.continuous_const_section TopologicalFiberBundleCore.continuous_const_section

@[simp, mfld_simps]
theorem local_triv_as_local_equiv_coe : ⇑(Z.localTrivAsLocalEquiv i) = Z.localTriv i :=
  rfl
#align
  topological_fiber_bundle_core.local_triv_as_local_equiv_coe TopologicalFiberBundleCore.local_triv_as_local_equiv_coe

@[simp, mfld_simps]
theorem local_triv_as_local_equiv_source : (Z.localTrivAsLocalEquiv i).source = (Z.localTriv i).source :=
  rfl
#align
  topological_fiber_bundle_core.local_triv_as_local_equiv_source TopologicalFiberBundleCore.local_triv_as_local_equiv_source

@[simp, mfld_simps]
theorem local_triv_as_local_equiv_target : (Z.localTrivAsLocalEquiv i).target = (Z.localTriv i).target :=
  rfl
#align
  topological_fiber_bundle_core.local_triv_as_local_equiv_target TopologicalFiberBundleCore.local_triv_as_local_equiv_target

@[simp, mfld_simps]
theorem local_triv_as_local_equiv_symm : (Z.localTrivAsLocalEquiv i).symm = (Z.localTriv i).toLocalEquiv.symm :=
  rfl
#align
  topological_fiber_bundle_core.local_triv_as_local_equiv_symm TopologicalFiberBundleCore.local_triv_as_local_equiv_symm

@[simp, mfld_simps]
theorem base_set_at : Z.baseSet i = (Z.localTriv i).baseSet :=
  rfl
#align topological_fiber_bundle_core.base_set_at TopologicalFiberBundleCore.base_set_at

@[simp, mfld_simps]
theorem local_triv_apply (p : Z.TotalSpace) : (Z.localTriv i) p = ⟨p.1, Z.coordChange (Z.indexAt p.1) i p.1 p.2⟩ :=
  rfl
#align topological_fiber_bundle_core.local_triv_apply TopologicalFiberBundleCore.local_triv_apply

@[simp, mfld_simps]
theorem local_triv_at_apply (p : Z.TotalSpace) : (Z.localTrivAt p.1) p = ⟨p.1, p.2⟩ := by
  rw [local_triv_at, local_triv_apply, coord_change_self]
  exact Z.mem_base_set_at p.1
#align topological_fiber_bundle_core.local_triv_at_apply TopologicalFiberBundleCore.local_triv_at_apply

@[simp, mfld_simps]
theorem local_triv_at_apply_mk (b : B) (a : F) : (Z.localTrivAt b) ⟨b, a⟩ = ⟨b, a⟩ :=
  Z.local_triv_at_apply _
#align topological_fiber_bundle_core.local_triv_at_apply_mk TopologicalFiberBundleCore.local_triv_at_apply_mk

@[simp, mfld_simps]
theorem mem_local_triv_source (p : Z.TotalSpace) : p ∈ (Z.localTriv i).source ↔ p.1 ∈ (Z.localTriv i).baseSet :=
  Iff.rfl
#align topological_fiber_bundle_core.mem_local_triv_source TopologicalFiberBundleCore.mem_local_triv_source

@[simp, mfld_simps]
theorem mem_local_triv_at_source (p : Z.TotalSpace) (b : B) :
    p ∈ (Z.localTrivAt b).source ↔ p.1 ∈ (Z.localTrivAt b).baseSet :=
  Iff.rfl
#align topological_fiber_bundle_core.mem_local_triv_at_source TopologicalFiberBundleCore.mem_local_triv_at_source

@[simp, mfld_simps]
theorem mem_local_triv_target (p : B × F) : p ∈ (Z.localTriv i).target ↔ p.1 ∈ (Z.localTriv i).baseSet :=
  Trivialization.mem_target _
#align topological_fiber_bundle_core.mem_local_triv_target TopologicalFiberBundleCore.mem_local_triv_target

@[simp, mfld_simps]
theorem mem_local_triv_at_target (p : B × F) (b : B) : p ∈ (Z.localTrivAt b).target ↔ p.1 ∈ (Z.localTrivAt b).baseSet :=
  Trivialization.mem_target _
#align topological_fiber_bundle_core.mem_local_triv_at_target TopologicalFiberBundleCore.mem_local_triv_at_target

@[simp, mfld_simps]
theorem local_triv_symm_apply (p : B × F) :
    (Z.localTriv i).toLocalHomeomorph.symm p = ⟨p.1, Z.coordChange i (Z.indexAt p.1) p.1 p.2⟩ :=
  rfl
#align topological_fiber_bundle_core.local_triv_symm_apply TopologicalFiberBundleCore.local_triv_symm_apply

@[simp, mfld_simps]
theorem mem_local_triv_at_base_set (b : B) : b ∈ (Z.localTrivAt b).baseSet := by
  rw [local_triv_at, ← base_set_at]
  exact Z.mem_base_set_at b
#align topological_fiber_bundle_core.mem_local_triv_at_base_set TopologicalFiberBundleCore.mem_local_triv_at_base_set

/-- The inclusion of a fiber into the total space is a continuous map. -/
@[continuity]
theorem continuous_total_space_mk (b : B) : Continuous (totalSpaceMk b : Z.Fiber b → Bundle.TotalSpace Z.Fiber) := by
  rw [continuous_iff_le_induced, TopologicalFiberBundleCore.toTopologicalSpace]
  apply le_induced_generate_from
  simp only [total_space_mk, mem_Union, mem_singleton_iff, local_triv_as_local_equiv_source,
    local_triv_as_local_equiv_coe]
  rintro s ⟨i, t, ht, rfl⟩
  rw [← (Z.local_triv i).source_inter_preimage_target_inter t, preimage_inter, ← preimage_comp,
    Trivialization.source_eq]
  apply IsOpen.inter
  · simp only [total_space.proj, proj, ← preimage_comp]
    by_cases b ∈ (Z.local_triv i).baseSet
    · rw [preimage_const_of_mem h]
      exact is_open_univ
      
    · rw [preimage_const_of_not_mem h]
      exact is_open_empty
      
    
  · simp only [Function.comp, local_triv_apply]
    rw [preimage_inter, preimage_comp]
    by_cases b ∈ Z.base_set i
    · have hc : Continuous fun x : Z.fiber b => (Z.coord_change (Z.index_at b) i b) x :=
        (Z.coord_change_continuous (Z.index_at b) i).comp_continuous (continuous_const.prod_mk continuous_id) fun x =>
          ⟨⟨Z.mem_base_set_at b, h⟩, mem_univ x⟩
      exact (((Z.local_triv i).open_target.inter ht).Preimage (Continuous.Prod.mk b)).Preimage hc
      
    · rw [(Z.local_triv i).target_eq, ← base_set_at, mk_preimage_prod_right_eq_empty h, preimage_empty, empty_inter]
      exact is_open_empty
      
    
#align topological_fiber_bundle_core.continuous_total_space_mk TopologicalFiberBundleCore.continuous_total_space_mk

end TopologicalFiberBundleCore

variable (F) {Z : Type _} [TopologicalSpace B] [TopologicalSpace F] {proj : Z → B}

/- ./././Mathport/Syntax/Translate/Basic.lean:610:2: warning: expanding binder collection (e e' «expr ∈ » pretrivialization_atlas) -/
/-- This structure permits to define a fiber bundle when trivializations are given as local
equivalences but there is not yet a topology on the total space. The total space is hence given a
topology in such a way that there is a fiber bundle structure for which the local equivalences
are also local homeomorphism and hence local trivializations. -/
@[nolint has_nonempty_instance]
structure TopologicalFiberPrebundle (proj : Z → B) where
  pretrivializationAtlas : Set (Pretrivialization F proj)
  pretrivializationAt : B → Pretrivialization F proj
  mem_base_pretrivialization_at : ∀ x : B, x ∈ (pretrivialization_at x).baseSet
  pretrivialization_mem_atlas : ∀ x : B, pretrivialization_at x ∈ pretrivialization_atlas
  continuous_triv_change :
    ∀ (e e') (_ : e ∈ pretrivialization_atlas) (_ : e' ∈ pretrivialization_atlas),
      ContinuousOn (e ∘ e'.toLocalEquiv.symm) (e'.target ∩ e'.toLocalEquiv.symm ⁻¹' e.source)
#align topological_fiber_prebundle TopologicalFiberPrebundle

namespace TopologicalFiberPrebundle

variable {F} (a : TopologicalFiberPrebundle F proj) {e : Pretrivialization F proj}

/-- Topology on the total space that will make the prebundle into a bundle. -/
def totalSpaceTopology (a : TopologicalFiberPrebundle F proj) : TopologicalSpace Z :=
  ⨆ (e : Pretrivialization F proj) (he : e ∈ a.pretrivializationAtlas), coinduced e.setSymm Subtype.topologicalSpace
#align topological_fiber_prebundle.total_space_topology TopologicalFiberPrebundle.totalSpaceTopology

theorem continuous_symm_of_mem_pretrivialization_atlas (he : e ∈ a.pretrivializationAtlas) :
    @ContinuousOn _ _ _ a.totalSpaceTopology e.toLocalEquiv.symm e.target := by
  refine' id fun z H => id fun U h => preimage_nhds_within_coinduced' H e.open_target (le_def.1 (nhds_mono _) U h)
  exact le_supr₂ e he
#align
  topological_fiber_prebundle.continuous_symm_of_mem_pretrivialization_atlas TopologicalFiberPrebundle.continuous_symm_of_mem_pretrivialization_atlas

theorem is_open_source (e : Pretrivialization F proj) : @IsOpen _ a.totalSpaceTopology e.source := by
  letI := a.total_space_topology
  refine' is_open_supr_iff.mpr fun e' => _
  refine' is_open_supr_iff.mpr fun he' => _
  refine' is_open_coinduced.mpr (is_open_induced_iff.mpr ⟨e.target, e.open_target, _⟩)
  rw [Pretrivialization.setSymm, restrict, e.target_eq, e.source_eq, preimage_comp,
    Subtype.preimage_coe_eq_preimage_coe_iff, e'.target_eq, prod_inter_prod, inter_univ,
    Pretrivialization.preimage_symm_proj_inter]
#align topological_fiber_prebundle.is_open_source TopologicalFiberPrebundle.is_open_source

theorem is_open_target_of_mem_pretrivialization_atlas_inter (e e' : Pretrivialization F proj)
    (he' : e' ∈ a.pretrivializationAtlas) : IsOpen (e'.toLocalEquiv.target ∩ e'.toLocalEquiv.symm ⁻¹' e.source) := by
  letI := a.total_space_topology
  obtain ⟨u, hu1, hu2⟩ :=
    continuous_on_iff'.mp (a.continuous_symm_of_mem_pretrivialization_atlas he') e.source (a.is_open_source e)
  rw [inter_comm, hu2]
  exact hu1.inter e'.open_target
#align
  topological_fiber_prebundle.is_open_target_of_mem_pretrivialization_atlas_inter TopologicalFiberPrebundle.is_open_target_of_mem_pretrivialization_atlas_inter

/-- Promotion from a `pretrivialization` to a `trivialization`. -/
def trivializationOfMemPretrivializationAtlas (he : e ∈ a.pretrivializationAtlas) :
    @Trivialization B F Z _ _ a.totalSpaceTopology proj :=
  { e with open_source := a.is_open_source e,
    continuous_to_fun := by
      letI := a.total_space_topology
      refine'
        continuous_on_iff'.mpr fun s hs =>
          ⟨e ⁻¹' s ∩ e.source, is_open_supr_iff.mpr fun e' => _, by
            rw [inter_assoc, inter_self]
            rfl⟩
      refine' is_open_supr_iff.mpr fun he' => _
      rw [is_open_coinduced, is_open_induced_iff]
      obtain ⟨u, hu1, hu2⟩ := continuous_on_iff'.mp (a.continuous_triv_change _ he _ he') s hs
      have hu3 := congr_arg (fun s => (fun x : e'.target => (x : B × F)) ⁻¹' s) hu2
      simp only [Subtype.coe_preimage_self, preimage_inter, univ_inter] at hu3
      refine'
        ⟨u ∩ e'.to_local_equiv.target ∩ e'.to_local_equiv.symm ⁻¹' e.source, _, by
          simp only [preimage_inter, inter_univ, Subtype.coe_preimage_self, hu3.symm]
          rfl⟩
      rw [inter_assoc]
      exact hu1.inter (a.is_open_target_of_mem_pretrivialization_atlas_inter e e' he'),
    continuous_inv_fun := a.continuous_symm_of_mem_pretrivialization_atlas he }
#align
  topological_fiber_prebundle.trivialization_of_mem_pretrivialization_atlas TopologicalFiberPrebundle.trivializationOfMemPretrivializationAtlas

theorem is_topological_fiber_bundle : @IsTopologicalFiberBundle B F Z _ _ a.totalSpaceTopology proj := fun x =>
  ⟨a.trivializationOfMemPretrivializationAtlas (a.pretrivialization_mem_atlas x), a.mem_base_pretrivialization_at x⟩
#align topological_fiber_prebundle.is_topological_fiber_bundle TopologicalFiberPrebundle.is_topological_fiber_bundle

theorem continuous_proj : @Continuous _ _ a.totalSpaceTopology _ proj :=
  letI := a.total_space_topology
  a.is_topological_fiber_bundle.continuous_proj
#align topological_fiber_prebundle.continuous_proj TopologicalFiberPrebundle.continuous_proj

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- For a fiber bundle `Z` over `B` constructed using the `topological_fiber_prebundle` mechanism,
continuity of a function `Z → X` on an open set `s` can be checked by precomposing at each point
with the pretrivialization used for the construction at that point. -/
theorem continuous_on_of_comp_right {X : Type _} [TopologicalSpace X] {f : Z → X} {s : Set B} (hs : IsOpen s)
    (hf :
      ∀ b ∈ s,
        ContinuousOn (f ∘ (a.pretrivializationAt b).toLocalEquiv.symm)
          ((s ∩ (a.pretrivializationAt b).baseSet) ×ˢ (Set.univ : Set F))) :
    @ContinuousOn _ _ a.totalSpaceTopology _ f (proj ⁻¹' s) := by
  letI := a.total_space_topology
  intro z hz
  let e : Trivialization F proj :=
    a.trivialization_of_mem_pretrivialization_atlas (a.pretrivialization_mem_atlas (proj z))
  refine' (e.continuous_at_of_comp_right _ ((hf (proj z) hz).ContinuousAt (IsOpen.mem_nhds _ _))).ContinuousWithinAt
  · exact a.mem_base_pretrivialization_at (proj z)
    
  · exact (hs.inter (a.pretrivialization_at (proj z)).open_base_set).Prod is_open_univ
    
  refine' ⟨_, mem_univ _⟩
  rw [e.coe_fst]
  · exact ⟨hz, a.mem_base_pretrivialization_at (proj z)⟩
    
  · rw [e.mem_source]
    exact a.mem_base_pretrivialization_at (proj z)
    
#align topological_fiber_prebundle.continuous_on_of_comp_right TopologicalFiberPrebundle.continuous_on_of_comp_right

end TopologicalFiberPrebundle

