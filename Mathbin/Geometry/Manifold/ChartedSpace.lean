/-
Copyright (c) 2019 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module geometry.manifold.charted_space
! leanprover-community/mathlib commit 814d76e2247d5ba8bc024843552da1278bfe9e5c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.LocalHomeomorph

/-!
# Charted spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A smooth manifold is a topological space `M` locally modelled on a euclidean space (or a euclidean
half-space for manifolds with boundaries, or an infinite dimensional vector space for more general
notions of manifolds), i.e., the manifold is covered by open subsets on which there are local
homeomorphisms (the charts) going to a model space `H`, and the changes of charts should be smooth
maps.

In this file, we introduce a general framework describing these notions, where the model space is an
arbitrary topological space. We avoid the word *manifold*, which should be reserved for the
situation where the model space is a (subset of a) vector space, and use the terminology
*charted space* instead.

If the changes of charts satisfy some additional property (for instance if they are smooth), then
`M` inherits additional structure (it makes sense to talk about smooth manifolds). There are
therefore two different ingredients in a charted space:
* the set of charts, which is data
* the fact that changes of charts belong to some group (in fact groupoid), which is additional Prop.

We separate these two parts in the definition: the charted space structure is just the set of
charts, and then the different smoothness requirements (smooth manifold, orientable manifold,
contact manifold, and so on) are additional properties of these charts. These properties are
formalized through the notion of structure groupoid, i.e., a set of local homeomorphisms stable
under composition and inverse, to which the change of coordinates should belong.

## Main definitions

* `structure_groupoid H` : a subset of local homeomorphisms of `H` stable under composition,
  inverse and restriction (ex: local diffeos).
* `continuous_groupoid H` : the groupoid of all local homeomorphisms of `H`
* `charted_space H M` : charted space structure on `M` modelled on `H`, given by an atlas of
  local homeomorphisms from `M` to `H` whose sources cover `M`. This is a type class.
* `has_groupoid M G` : when `G` is a structure groupoid on `H` and `M` is a charted space
  modelled on `H`, require that all coordinate changes belong to `G`. This is a type class.
* `atlas H M` : when `M` is a charted space modelled on `H`, the atlas of this charted
  space structure, i.e., the set of charts.
* `G.maximal_atlas M` : when `M` is a charted space modelled on `H` and admitting `G` as a
  structure groupoid, one can consider all the local homeomorphisms from `M` to `H` such that
  changing coordinate from any chart to them belongs to `G`. This is a larger atlas, called the
  maximal atlas (for the groupoid `G`).
* `structomorph G M M'` : the type of diffeomorphisms between the charted spaces `M` and `M'` for
  the groupoid `G`. We avoid the word diffeomorphism, keeping it for the smooth category.

As a basic example, we give the instance
`instance charted_space_model_space (H : Type*) [topological_space H] : charted_space H H`
saying that a topological space is a charted space over itself, with the identity as unique chart.
This charted space structure is compatible with any groupoid.

Additional useful definitions:

* `pregroupoid H` : a subset of local mas of `H` stable under composition and
  restriction, but not inverse (ex: smooth maps)
* `groupoid_of_pregroupoid` : construct a groupoid from a pregroupoid, by requiring that a map and
  its inverse both belong to the pregroupoid (ex: construct diffeos from smooth maps)
* `chart_at H x` is a preferred chart at `x : M` when `M` has a charted space structure modelled on
  `H`.
* `G.compatible he he'` states that, for any two charts `e` and `e'` in the atlas, the composition
  of `e.symm` and `e'` belongs to the groupoid `G` when `M` admits `G` as a structure groupoid.
* `G.compatible_of_mem_maximal_atlas he he'` states that, for any two charts `e` and `e'` in the
  maximal atlas associated to the groupoid `G`, the composition of `e.symm` and `e'` belongs to the
  `G` if `M` admits `G` as a structure groupoid.
* `charted_space_core.to_charted_space`: consider a space without a topology, but endowed with a set
  of charts (which are local equivs) for which the change of coordinates are local homeos. Then
  one can construct a topology on the space for which the charts become local homeos, defining
  a genuine charted space structure.

## Implementation notes

The atlas in a charted space is *not* a maximal atlas in general: the notion of maximality depends
on the groupoid one considers, and changing groupoids changes the maximal atlas. With the current
formalization, it makes sense first to choose the atlas, and then to ask whether this precise atlas
defines a smooth manifold, an orientable manifold, and so on. A consequence is that structomorphisms
between `M` and `M'` do *not* induce a bijection between the atlases of `M` and `M'`: the
definition is only that, read in charts, the structomorphism locally belongs to the groupoid under
consideration. (This is equivalent to inducing a bijection between elements of the maximal atlas).
A consequence is that the invariance under structomorphisms of properties defined in terms of the
atlas is not obvious in general, and could require some work in theory (amounting to the fact
that these properties only depend on the maximal atlas, for instance). In practice, this does not
create any real difficulty.

We use the letter `H` for the model space thinking of the case of manifolds with boundary, where the
model space is a half space.

Manifolds are sometimes defined as topological spaces with an atlas of local diffeomorphisms, and
sometimes as spaces with an atlas from which a topology is deduced. We use the former approach:
otherwise, there would be an instance from manifolds to topological spaces, which means that any
instance search for topological spaces would try to find manifold structures involving a yet
unknown model space, leading to problems. However, we also introduce the latter approach,
through a structure `charted_space_core` making it possible to construct a topology out of a set of
local equivs with compatibility conditions (but we do not register it as an instance).

In the definition of a charted space, the model space is written as an explicit parameter as there
can be several model spaces for a given topological space. For instance, a complex manifold
(modelled over `ℂ^n`) will also be seen sometimes as a real manifold modelled over `ℝ^(2n)`.

## Notations

In the locale `manifold`, we denote the composition of local homeomorphisms with `≫ₕ`, and the
composition of local equivs with `≫`.
-/


noncomputable section

open Classical Topology

open Filter

universe u

variable {H : Type u} {H' : Type _} {M : Type _} {M' : Type _} {M'' : Type _}

-- mathport name: local_homeomorph.trans
/- Notational shortcut for the composition of local homeomorphisms and local equivs, i.e.,
`local_homeomorph.trans` and `local_equiv.trans`.
Note that, as is usual for equivs, the composition is from left to right, hence the direction of
the arrow. -/
scoped[Manifold] infixr:100 " ≫ₕ " => LocalHomeomorph.trans

-- mathport name: local_equiv.trans
scoped[Manifold] infixr:100 " ≫ " => LocalEquiv.trans

open Set LocalHomeomorph

/-! ### Structure groupoids-/


section Groupoid

/-! One could add to the definition of a structure groupoid the fact that the restriction of an
element of the groupoid to any open set still belongs to the groupoid.
(This is in Kobayashi-Nomizu.)
I am not sure I want this, for instance on `H × E` where `E` is a vector space, and the groupoid is
made of functions respecting the fibers and linear in the fibers (so that a charted space over this
groupoid is naturally a vector bundle) I prefer that the members of the groupoid are always
defined on sets of the form `s × E`.  There is a typeclass `closed_under_restriction` for groupoids
which have the restriction property.

The only nontrivial requirement is locality: if a local homeomorphism belongs to the groupoid
around each point in its domain of definition, then it belongs to the groupoid. Without this
requirement, the composition of structomorphisms does not have to be a structomorphism. Note that
this implies that a local homeomorphism with empty source belongs to any structure groupoid, as
it trivially satisfies this condition.

There is also a technical point, related to the fact that a local homeomorphism is by definition a
global map which is a homeomorphism when restricted to its source subset (and its values outside
of the source are not relevant). Therefore, we also require that being a member of the groupoid only
depends on the values on the source.

We use primes in the structure names as we will reformulate them below (without primes) using a
`has_mem` instance, writing `e ∈ G` instead of `e ∈ G.members`.
-/


#print StructureGroupoid /-
/-- A structure groupoid is a set of local homeomorphisms of a topological space stable under
composition and inverse. They appear in the definition of the smoothness class of a manifold. -/
structure StructureGroupoid (H : Type u) [TopologicalSpace H] where
  members : Set (LocalHomeomorph H H)
  trans' : ∀ e e' : LocalHomeomorph H H, e ∈ members → e' ∈ members → e ≫ₕ e' ∈ members
  symm' : ∀ e : LocalHomeomorph H H, e ∈ members → e.symm ∈ members
  id_mem' : LocalHomeomorph.refl H ∈ members
  locality' :
    ∀ e : LocalHomeomorph H H,
      (∀ x ∈ e.source, ∃ s, IsOpen s ∧ x ∈ s ∧ e.restr s ∈ members) → e ∈ members
  eq_on_source' : ∀ e e' : LocalHomeomorph H H, e ∈ members → e' ≈ e → e' ∈ members
#align structure_groupoid StructureGroupoid
-/

variable [TopologicalSpace H]

instance : Membership (LocalHomeomorph H H) (StructureGroupoid H) :=
  ⟨fun (e : LocalHomeomorph H H) (G : StructureGroupoid H) => e ∈ G.members⟩

#print StructureGroupoid.trans /-
theorem StructureGroupoid.trans (G : StructureGroupoid H) {e e' : LocalHomeomorph H H} (he : e ∈ G)
    (he' : e' ∈ G) : e ≫ₕ e' ∈ G :=
  G.trans' e e' he he'
#align structure_groupoid.trans StructureGroupoid.trans
-/

#print StructureGroupoid.symm /-
theorem StructureGroupoid.symm (G : StructureGroupoid H) {e : LocalHomeomorph H H} (he : e ∈ G) :
    e.symm ∈ G :=
  G.symm' e he
#align structure_groupoid.symm StructureGroupoid.symm
-/

#print StructureGroupoid.id_mem /-
theorem StructureGroupoid.id_mem (G : StructureGroupoid H) : LocalHomeomorph.refl H ∈ G :=
  G.id_mem'
#align structure_groupoid.id_mem StructureGroupoid.id_mem
-/

#print StructureGroupoid.locality /-
theorem StructureGroupoid.locality (G : StructureGroupoid H) {e : LocalHomeomorph H H}
    (h : ∀ x ∈ e.source, ∃ s, IsOpen s ∧ x ∈ s ∧ e.restr s ∈ G) : e ∈ G :=
  G.locality' e h
#align structure_groupoid.locality StructureGroupoid.locality
-/

/- warning: structure_groupoid.eq_on_source -> StructureGroupoid.eq_on_source is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} H] (G : StructureGroupoid.{u1} H _inst_1) {e : LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1} {e' : LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1}, (Membership.Mem.{u1, u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (StructureGroupoid.{u1} H _inst_1) (StructureGroupoid.hasMem.{u1} H _inst_1) e G) -> (HasEquivₓ.Equiv.{succ u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (setoidHasEquiv.{succ u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (LocalHomeomorph.setoid.{u1, u1} H H _inst_1 _inst_1)) e' e) -> (Membership.Mem.{u1, u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (StructureGroupoid.{u1} H _inst_1) (StructureGroupoid.hasMem.{u1} H _inst_1) e' G)
but is expected to have type
  forall {H : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} H] (G : StructureGroupoid.{u1} H _inst_1) {e : LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1} {e' : LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1}, (Membership.mem.{u1, u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (StructureGroupoid.{u1} H _inst_1) (instMembershipLocalHomeomorphStructureGroupoid.{u1} H _inst_1) e G) -> (HasEquiv.Equiv.{succ u1, 0} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (instHasEquiv.{succ u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (LocalHomeomorph.eqOnSourceSetoid.{u1, u1} H H _inst_1 _inst_1)) e' e) -> (Membership.mem.{u1, u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (StructureGroupoid.{u1} H _inst_1) (instMembershipLocalHomeomorphStructureGroupoid.{u1} H _inst_1) e' G)
Case conversion may be inaccurate. Consider using '#align structure_groupoid.eq_on_source StructureGroupoid.eq_on_sourceₓ'. -/
theorem StructureGroupoid.eq_on_source (G : StructureGroupoid H) {e e' : LocalHomeomorph H H}
    (he : e ∈ G) (h : e' ≈ e) : e' ∈ G :=
  G.eq_on_source' e e' he h
#align structure_groupoid.eq_on_source StructureGroupoid.eq_on_source

#print StructureGroupoid.partialOrder /-
/-- Partial order on the set of groupoids, given by inclusion of the members of the groupoid -/
instance StructureGroupoid.partialOrder : PartialOrder (StructureGroupoid H) :=
  PartialOrder.lift StructureGroupoid.members fun a b h =>
    by
    cases a
    cases b
    dsimp at h
    induction h
    rfl
#align structure_groupoid.partial_order StructureGroupoid.partialOrder
-/

#print StructureGroupoid.le_iff /-
theorem StructureGroupoid.le_iff {G₁ G₂ : StructureGroupoid H} : G₁ ≤ G₂ ↔ ∀ e, e ∈ G₁ → e ∈ G₂ :=
  Iff.rfl
#align structure_groupoid.le_iff StructureGroupoid.le_iff
-/

#print idGroupoid /-
/-- The trivial groupoid, containing only the identity (and maps with empty source, as this is
necessary from the definition) -/
def idGroupoid (H : Type u) [TopologicalSpace H] : StructureGroupoid H
    where
  members := {LocalHomeomorph.refl H} ∪ { e : LocalHomeomorph H H | e.source = ∅ }
  trans' e e' he he' := by
    cases he <;> simp at he he'
    · simpa only [he, refl_trans]
    · have : (e ≫ₕ e').source ⊆ e.source := sep_subset _ _
      rw [he] at this
      have : e ≫ₕ e' ∈ { e : LocalHomeomorph H H | e.source = ∅ } := eq_bot_iff.2 this
      exact (mem_union _ _ _).2 (Or.inr this)
  symm' e he := by
    cases' (mem_union _ _ _).1 he with E E
    · simp [mem_singleton_iff.mp E]
    · right
      simpa only [e.to_local_equiv.image_source_eq_target.symm, mfld_simps] using E
  id_mem' := mem_union_left _ rfl
  locality' e he := by
    cases' e.source.eq_empty_or_nonempty with h h
    · right
      exact h
    · left
      rcases h with ⟨x, hx⟩
      rcases he x hx with ⟨s, open_s, xs, hs⟩
      have x's : x ∈ (e.restr s).source :=
        by
        rw [restr_source, open_s.interior_eq]
        exact ⟨hx, xs⟩
      cases hs
      · replace hs : LocalHomeomorph.restr e s = LocalHomeomorph.refl H
        · simpa only using hs
        have : (e.restr s).source = univ := by
          rw [hs]
          simp
        change e.to_local_equiv.source ∩ interior s = univ at this
        have : univ ⊆ interior s := by
          rw [← this]
          exact inter_subset_right _ _
        have : s = univ := by rwa [open_s.interior_eq, univ_subset_iff] at this
        simpa only [this, restr_univ] using hs
      · exfalso
        rw [mem_set_of_eq] at hs
        rwa [hs] at x's
  eq_on_source' e e' he he'e := by
    cases he
    · left
      have : e = e' := by
        refine' eq_of_eq_on_source_univ (Setoid.symm he'e) _ _ <;>
            rw [Set.mem_singleton_iff.1 he] <;>
          rfl
      rwa [← this]
    · right
      change e.to_local_equiv.source = ∅ at he
      rwa [Set.mem_setOf_eq, he'e.source_eq]
#align id_groupoid idGroupoid
-/

/-- Every structure groupoid contains the identity groupoid -/
instance : OrderBot (StructureGroupoid H)
    where
  bot := idGroupoid H
  bot_le := by
    intro u f hf
    change f ∈ {LocalHomeomorph.refl H} ∪ { e : LocalHomeomorph H H | e.source = ∅ } at hf
    simp only [singleton_union, mem_set_of_eq, mem_insert_iff] at hf
    cases hf
    · rw [hf]
      apply u.id_mem
    · apply u.locality
      intro x hx
      rw [hf, mem_empty_iff_false] at hx
      exact hx.elim

instance (H : Type u) [TopologicalSpace H] : Inhabited (StructureGroupoid H) :=
  ⟨idGroupoid H⟩

#print Pregroupoid /-
/-- To construct a groupoid, one may consider classes of local homeos such that both the function
and its inverse have some property. If this property is stable under composition,
one gets a groupoid. `pregroupoid` bundles the properties needed for this construction, with the
groupoid of smooth functions with smooth inverses as an application. -/
structure Pregroupoid (H : Type _) [TopologicalSpace H] where
  property : (H → H) → Set H → Prop
  comp :
    ∀ {f g u v},
      property f u →
        property g v → IsOpen u → IsOpen v → IsOpen (u ∩ f ⁻¹' v) → property (g ∘ f) (u ∩ f ⁻¹' v)
  id_mem : property id univ
  locality :
    ∀ {f u}, IsOpen u → (∀ x ∈ u, ∃ v, IsOpen v ∧ x ∈ v ∧ property f (u ∩ v)) → property f u
  congr : ∀ {f g : H → H} {u}, IsOpen u → (∀ x ∈ u, g x = f x) → property f u → property g u
#align pregroupoid Pregroupoid
-/

#print Pregroupoid.groupoid /-
/-- Construct a groupoid of local homeos for which the map and its inverse have some property,
from a pregroupoid asserting that this property is stable under composition. -/
def Pregroupoid.groupoid (PG : Pregroupoid H) : StructureGroupoid H
    where
  members := { e : LocalHomeomorph H H | PG.property e e.source ∧ PG.property e.symm e.target }
  trans' e e' he he' := by
    constructor
    · apply PG.comp he.1 he'.1 e.open_source e'.open_source
      apply e.continuous_to_fun.preimage_open_of_open e.open_source e'.open_source
    · apply PG.comp he'.2 he.2 e'.open_target e.open_target
      apply e'.continuous_inv_fun.preimage_open_of_open e'.open_target e.open_target
  symm' e he := ⟨he.2, he.1⟩
  id_mem' := ⟨PG.id_mem, PG.id_mem⟩
  locality' e he := by
    constructor
    · apply PG.locality e.open_source fun x xu => _
      rcases he x xu with ⟨s, s_open, xs, hs⟩
      refine' ⟨s, s_open, xs, _⟩
      convert hs.1 using 1
      dsimp [LocalHomeomorph.restr]
      rw [s_open.interior_eq]
    · apply PG.locality e.open_target fun x xu => _
      rcases he (e.symm x) (e.map_target xu) with ⟨s, s_open, xs, hs⟩
      refine' ⟨e.target ∩ e.symm ⁻¹' s, _, ⟨xu, xs⟩, _⟩
      · exact ContinuousOn.preimage_open_of_open e.continuous_inv_fun e.open_target s_open
      · rw [← inter_assoc, inter_self]
        convert hs.2 using 1
        dsimp [LocalHomeomorph.restr]
        rw [s_open.interior_eq]
  eq_on_source' e e' he ee' := by
    constructor
    · apply PG.congr e'.open_source ee'.2
      simp only [ee'.1, he.1]
    · have A := ee'.symm'
      apply PG.congr e'.symm.open_source A.2
      convert he.2
      rw [A.1]
      rfl
#align pregroupoid.groupoid Pregroupoid.groupoid
-/

#print mem_groupoid_of_pregroupoid /-
theorem mem_groupoid_of_pregroupoid {PG : Pregroupoid H} {e : LocalHomeomorph H H} :
    e ∈ PG.groupoid ↔ PG.property e e.source ∧ PG.property e.symm e.target :=
  Iff.rfl
#align mem_groupoid_of_pregroupoid mem_groupoid_of_pregroupoid
-/

#print groupoid_of_pregroupoid_le /-
theorem groupoid_of_pregroupoid_le (PG₁ PG₂ : Pregroupoid H)
    (h : ∀ f s, PG₁.property f s → PG₂.property f s) : PG₁.groupoid ≤ PG₂.groupoid :=
  by
  refine' StructureGroupoid.le_iff.2 fun e he => _
  rw [mem_groupoid_of_pregroupoid] at he⊢
  exact ⟨h _ _ he.1, h _ _ he.2⟩
#align groupoid_of_pregroupoid_le groupoid_of_pregroupoid_le
-/

/- warning: mem_pregroupoid_of_eq_on_source -> mem_pregroupoid_of_eq_on_source is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} H] (PG : Pregroupoid.{u1} H _inst_1) {e : LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1} {e' : LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1}, (HasEquivₓ.Equiv.{succ u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (setoidHasEquiv.{succ u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (LocalHomeomorph.setoid.{u1, u1} H H _inst_1 _inst_1)) e e') -> (Pregroupoid.Property.{u1} H _inst_1 PG (coeFn.{succ u1, succ u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (fun (_x : LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) => H -> H) (LocalHomeomorph.hasCoeToFun.{u1, u1} H H _inst_1 _inst_1) e) (LocalEquiv.source.{u1, u1} H H (LocalHomeomorph.toLocalEquiv.{u1, u1} H H _inst_1 _inst_1 e))) -> (Pregroupoid.Property.{u1} H _inst_1 PG (coeFn.{succ u1, succ u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (fun (_x : LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) => H -> H) (LocalHomeomorph.hasCoeToFun.{u1, u1} H H _inst_1 _inst_1) e') (LocalEquiv.source.{u1, u1} H H (LocalHomeomorph.toLocalEquiv.{u1, u1} H H _inst_1 _inst_1 e')))
but is expected to have type
  forall {H : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} H] (PG : Pregroupoid.{u1} H _inst_1) {e : LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1} {e' : LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1}, (HasEquiv.Equiv.{succ u1, 0} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (instHasEquiv.{succ u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (LocalHomeomorph.eqOnSourceSetoid.{u1, u1} H H _inst_1 _inst_1)) e e') -> (Pregroupoid.property.{u1} H _inst_1 PG (LocalHomeomorph.toFun'.{u1, u1} H H _inst_1 _inst_1 e) (LocalEquiv.source.{u1, u1} H H (LocalHomeomorph.toLocalEquiv.{u1, u1} H H _inst_1 _inst_1 e))) -> (Pregroupoid.property.{u1} H _inst_1 PG (LocalHomeomorph.toFun'.{u1, u1} H H _inst_1 _inst_1 e') (LocalEquiv.source.{u1, u1} H H (LocalHomeomorph.toLocalEquiv.{u1, u1} H H _inst_1 _inst_1 e')))
Case conversion may be inaccurate. Consider using '#align mem_pregroupoid_of_eq_on_source mem_pregroupoid_of_eq_on_sourceₓ'. -/
theorem mem_pregroupoid_of_eq_on_source (PG : Pregroupoid H) {e e' : LocalHomeomorph H H}
    (he' : e ≈ e') (he : PG.property e e.source) : PG.property e' e'.source :=
  by
  rw [← he'.1]
  exact PG.congr e.open_source he'.eq_on.symm he
#align mem_pregroupoid_of_eq_on_source mem_pregroupoid_of_eq_on_source

#print continuousPregroupoid /-
/-- The pregroupoid of all local maps on a topological space `H` -/
@[reducible]
def continuousPregroupoid (H : Type _) [TopologicalSpace H] : Pregroupoid H
    where
  property f s := True
  comp f g u v hf hg hu hv huv := trivial
  id_mem := trivial
  locality f u u_open h := trivial
  congr f g u u_open hcongr hf := trivial
#align continuous_pregroupoid continuousPregroupoid
-/

instance (H : Type _) [TopologicalSpace H] : Inhabited (Pregroupoid H) :=
  ⟨continuousPregroupoid H⟩

#print continuousGroupoid /-
/-- The groupoid of all local homeomorphisms on a topological space `H` -/
def continuousGroupoid (H : Type _) [TopologicalSpace H] : StructureGroupoid H :=
  Pregroupoid.groupoid (continuousPregroupoid H)
#align continuous_groupoid continuousGroupoid
-/

/-- Every structure groupoid is contained in the groupoid of all local homeomorphisms -/
instance : OrderTop (StructureGroupoid H)
    where
  top := continuousGroupoid H
  le_top u f hf := by constructor <;> exact by decide

#print ClosedUnderRestriction /-
/-- A groupoid is closed under restriction if it contains all restrictions of its element local
homeomorphisms to open subsets of the source. -/
class ClosedUnderRestriction (G : StructureGroupoid H) : Prop where
  ClosedUnderRestriction :
    ∀ {e : LocalHomeomorph H H}, e ∈ G → ∀ s : Set H, IsOpen s → e.restr s ∈ G
#align closed_under_restriction ClosedUnderRestriction
-/

#print closedUnderRestriction' /-
theorem closedUnderRestriction' {G : StructureGroupoid H} [ClosedUnderRestriction G]
    {e : LocalHomeomorph H H} (he : e ∈ G) {s : Set H} (hs : IsOpen s) : e.restr s ∈ G :=
  ClosedUnderRestriction.closedUnderRestriction he s hs
#align closed_under_restriction' closedUnderRestriction'
-/

#print idRestrGroupoid /-
/-- The trivial restriction-closed groupoid, containing only local homeomorphisms equivalent to the
restriction of the identity to the various open subsets. -/
def idRestrGroupoid : StructureGroupoid H
    where
  members := { e | ∃ (s : Set H)(h : IsOpen s), e ≈ LocalHomeomorph.ofSet s h }
  trans' := by
    rintro e e' ⟨s, hs, hse⟩ ⟨s', hs', hse'⟩
    refine' ⟨s ∩ s', IsOpen.inter hs hs', _⟩
    have := LocalHomeomorph.EqOnSource.trans' hse hse'
    rwa [LocalHomeomorph.ofSet_trans_ofSet] at this
  symm' := by
    rintro e ⟨s, hs, hse⟩
    refine' ⟨s, hs, _⟩
    rw [← of_set_symm]
    exact LocalHomeomorph.EqOnSource.symm' hse
  id_mem' := ⟨univ, isOpen_univ, by simp only [mfld_simps]⟩
  locality' := by
    intro e h
    refine' ⟨e.source, e.open_source, by simp only [mfld_simps], _⟩
    intro x hx
    rcases h x hx with ⟨s, hs, hxs, s', hs', hes'⟩
    have hes : x ∈ (e.restr s).source := by
      rw [e.restr_source]
      refine' ⟨hx, _⟩
      rw [hs.interior_eq]
      exact hxs
    simpa only [mfld_simps] using LocalHomeomorph.EqOnSource.eqOn hes' hes
  eq_on_source' := by
    rintro e e' ⟨s, hs, hse⟩ hee'
    exact ⟨s, hs, Setoid.trans hee' hse⟩
#align id_restr_groupoid idRestrGroupoid
-/

#print idRestrGroupoid_mem /-
theorem idRestrGroupoid_mem {s : Set H} (hs : IsOpen s) : ofSet s hs ∈ @idRestrGroupoid H _ :=
  ⟨s, hs, by rfl⟩
#align id_restr_groupoid_mem idRestrGroupoid_mem
-/

#print closedUnderRestriction_idRestrGroupoid /-
/-- The trivial restriction-closed groupoid is indeed `closed_under_restriction`. -/
instance closedUnderRestriction_idRestrGroupoid : ClosedUnderRestriction (@idRestrGroupoid H _) :=
  ⟨by
    rintro e ⟨s', hs', he⟩ s hs
    use s' ∩ s, IsOpen.inter hs' hs
    refine' Setoid.trans (LocalHomeomorph.EqOnSource.restr he s) _
    exact ⟨by simp only [hs.interior_eq, mfld_simps], by simp only [mfld_simps]⟩⟩
#align closed_under_restriction_id_restr_groupoid closedUnderRestriction_idRestrGroupoid
-/

#print closedUnderRestriction_iff_id_le /-
/-- A groupoid is closed under restriction if and only if it contains the trivial restriction-closed
groupoid. -/
theorem closedUnderRestriction_iff_id_le (G : StructureGroupoid H) :
    ClosedUnderRestriction G ↔ idRestrGroupoid ≤ G :=
  by
  constructor
  · intro _i
    apply structure_groupoid.le_iff.mpr
    rintro e ⟨s, hs, hes⟩
    refine' G.eq_on_source _ hes
    convert closedUnderRestriction' G.id_mem hs
    change s = _ ∩ _
    rw [hs.interior_eq]
    simp only [mfld_simps]
  · intro h
    constructor
    intro e he s hs
    rw [← of_set_trans (e : LocalHomeomorph H H) hs]
    refine' G.trans _ he
    apply structure_groupoid.le_iff.mp h
    exact idRestrGroupoid_mem hs
#align closed_under_restriction_iff_id_le closedUnderRestriction_iff_id_le
-/

/-- The groupoid of all local homeomorphisms on a topological space `H` is closed under restriction.
-/
instance : ClosedUnderRestriction (continuousGroupoid H) :=
  (closedUnderRestriction_iff_id_le _).mpr (by convert le_top)

end Groupoid

/-! ### Charted spaces -/


#print ChartedSpace /-
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`atlas] [] -/
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`chartAt] [] -/
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`mem_chart_source] [] -/
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`chart_mem_atlas] [] -/
/-- A charted space is a topological space endowed with an atlas, i.e., a set of local
homeomorphisms taking value in a model space `H`, called charts, such that the domains of the charts
cover the whole space. We express the covering property by chosing for each `x` a member
`chart_at H x` of the atlas containing `x` in its source: in the smooth case, this is convenient to
construct the tangent bundle in an efficient way.
The model space is written as an explicit parameter as there can be several model spaces for a
given topological space. For instance, a complex manifold (modelled over `ℂ^n`) will also be seen
sometimes as a real manifold over `ℝ^(2n)`.
-/
@[ext]
class ChartedSpace (H : Type _) [TopologicalSpace H] (M : Type _) [TopologicalSpace M] where
  atlas : Set (LocalHomeomorph M H)
  chartAt : M → LocalHomeomorph M H
  mem_chart_source : ∀ x, x ∈ (chart_at x).source
  chart_mem_atlas : ∀ x, chart_at x ∈ atlas
#align charted_space ChartedSpace
-/

export ChartedSpace ()

attribute [simp, mfld_simps] mem_chart_source chart_mem_atlas

section ChartedSpace

#print chartedSpaceSelf /-
/-- Any space is a charted_space modelled over itself, by just using the identity chart -/
instance chartedSpaceSelf (H : Type _) [TopologicalSpace H] : ChartedSpace H H
    where
  atlas := {LocalHomeomorph.refl H}
  chartAt x := LocalHomeomorph.refl H
  mem_chart_source x := mem_univ x
  chart_mem_atlas x := mem_singleton _
#align charted_space_self chartedSpaceSelf
-/

#print chartedSpaceSelf_atlas /-
/-- In the trivial charted_space structure of a space modelled over itself through the identity, the
atlas members are just the identity -/
@[simp, mfld_simps]
theorem chartedSpaceSelf_atlas {H : Type _} [TopologicalSpace H] {e : LocalHomeomorph H H} :
    e ∈ atlas H H ↔ e = LocalHomeomorph.refl H := by simp [atlas, ChartedSpace.atlas]
#align charted_space_self_atlas chartedSpaceSelf_atlas
-/

#print chartAt_self_eq /-
/-- In the model space, chart_at is always the identity -/
theorem chartAt_self_eq {H : Type _} [TopologicalSpace H] {x : H} :
    chartAt H x = LocalHomeomorph.refl H := by simpa using chart_mem_atlas H x
#align chart_at_self_eq chartAt_self_eq
-/

section

variable (H) [TopologicalSpace H] [TopologicalSpace M] [ChartedSpace H M]

/- warning: mem_chart_target -> mem_chart_target is a dubious translation:
lean 3 declaration is
  forall (H : Type.{u1}) {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] (x : M), Membership.Mem.{u1, u1} H (Set.{u1} H) (Set.hasMem.{u1} H) (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (fun (_x : LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) => M -> H) (LocalHomeomorph.hasCoeToFun.{u2, u1} M H _inst_2 _inst_1) (ChartedSpace.chartAt.{u1, u2} H _inst_1 M _inst_2 _inst_3 x) x) (LocalEquiv.target.{u2, u1} M H (LocalHomeomorph.toLocalEquiv.{u2, u1} M H _inst_2 _inst_1 (ChartedSpace.chartAt.{u1, u2} H _inst_1 M _inst_2 _inst_3 x)))
but is expected to have type
  forall (H : Type.{u2}) {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] (x : M), Membership.mem.{u2, u2} H (Set.{u2} H) (Set.instMembershipSet.{u2} H) (LocalHomeomorph.toFun'.{u1, u2} M H _inst_2 _inst_1 (ChartedSpace.chartAt.{u2, u1} H _inst_1 M _inst_2 _inst_3 x) x) (LocalEquiv.target.{u1, u2} M H (LocalHomeomorph.toLocalEquiv.{u1, u2} M H _inst_2 _inst_1 (ChartedSpace.chartAt.{u2, u1} H _inst_1 M _inst_2 _inst_3 x)))
Case conversion may be inaccurate. Consider using '#align mem_chart_target mem_chart_targetₓ'. -/
theorem mem_chart_target (x : M) : chartAt H x x ∈ (chartAt H x).target :=
  (chartAt H x).map_source (mem_chart_source _ _)
#align mem_chart_target mem_chart_target

/- warning: chart_source_mem_nhds -> chart_source_mem_nhds is a dubious translation:
lean 3 declaration is
  forall (H : Type.{u1}) {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] (x : M), Membership.Mem.{u2, u2} (Set.{u2} M) (Filter.{u2} M) (Filter.hasMem.{u2} M) (LocalEquiv.source.{u2, u1} M H (LocalHomeomorph.toLocalEquiv.{u2, u1} M H _inst_2 _inst_1 (ChartedSpace.chartAt.{u1, u2} H _inst_1 M _inst_2 _inst_3 x))) (nhds.{u2} M _inst_2 x)
but is expected to have type
  forall (H : Type.{u2}) {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] (x : M), Membership.mem.{u1, u1} (Set.{u1} M) (Filter.{u1} M) (instMembershipSetFilter.{u1} M) (LocalEquiv.source.{u1, u2} M H (LocalHomeomorph.toLocalEquiv.{u1, u2} M H _inst_2 _inst_1 (ChartedSpace.chartAt.{u2, u1} H _inst_1 M _inst_2 _inst_3 x))) (nhds.{u1} M _inst_2 x)
Case conversion may be inaccurate. Consider using '#align chart_source_mem_nhds chart_source_mem_nhdsₓ'. -/
theorem chart_source_mem_nhds (x : M) : (chartAt H x).source ∈ 𝓝 x :=
  (chartAt H x).open_source.mem_nhds <| mem_chart_source H x
#align chart_source_mem_nhds chart_source_mem_nhds

/- warning: chart_target_mem_nhds -> chart_target_mem_nhds is a dubious translation:
lean 3 declaration is
  forall (H : Type.{u1}) {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] (x : M), Membership.Mem.{u1, u1} (Set.{u1} H) (Filter.{u1} H) (Filter.hasMem.{u1} H) (LocalEquiv.target.{u2, u1} M H (LocalHomeomorph.toLocalEquiv.{u2, u1} M H _inst_2 _inst_1 (ChartedSpace.chartAt.{u1, u2} H _inst_1 M _inst_2 _inst_3 x))) (nhds.{u1} H _inst_1 (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (fun (_x : LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) => M -> H) (LocalHomeomorph.hasCoeToFun.{u2, u1} M H _inst_2 _inst_1) (ChartedSpace.chartAt.{u1, u2} H _inst_1 M _inst_2 _inst_3 x) x))
but is expected to have type
  forall (H : Type.{u2}) {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] (x : M), Membership.mem.{u2, u2} (Set.{u2} H) (Filter.{u2} H) (instMembershipSetFilter.{u2} H) (LocalEquiv.target.{u1, u2} M H (LocalHomeomorph.toLocalEquiv.{u1, u2} M H _inst_2 _inst_1 (ChartedSpace.chartAt.{u2, u1} H _inst_1 M _inst_2 _inst_3 x))) (nhds.{u2} H _inst_1 (LocalHomeomorph.toFun'.{u1, u2} M H _inst_2 _inst_1 (ChartedSpace.chartAt.{u2, u1} H _inst_1 M _inst_2 _inst_3 x) x))
Case conversion may be inaccurate. Consider using '#align chart_target_mem_nhds chart_target_mem_nhdsₓ'. -/
theorem chart_target_mem_nhds (x : M) : (chartAt H x).target ∈ 𝓝 (chartAt H x x) :=
  (chartAt H x).open_target.mem_nhds <| mem_chart_target H x
#align chart_target_mem_nhds chart_target_mem_nhds

#print achart /-
/-- `achart H x` is the chart at `x`, considered as an element of the atlas.
Especially useful for working with `basic_smooth_vector_bundle_core` -/
def achart (x : M) : atlas H M :=
  ⟨chartAt H x, chart_mem_atlas H x⟩
#align achart achart
-/

/- warning: achart_def -> achart_def is a dubious translation:
lean 3 declaration is
  forall (H : Type.{u1}) {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] (x : M), Eq.{succ (max u2 u1)} (coeSort.{succ (max u2 u1), succ (succ (max u2 u1))} (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) Type.{max u2 u1} (Set.hasCoeToSort.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (ChartedSpace.atlas.{u1, u2} H _inst_1 M _inst_2 _inst_3)) (achart.{u1, u2} H M _inst_1 _inst_2 _inst_3 x) (Subtype.mk.{succ (max u2 u1)} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (fun (x : LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) => Membership.Mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (Set.hasMem.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) x (ChartedSpace.atlas.{u1, u2} H _inst_1 M _inst_2 _inst_3)) (ChartedSpace.chartAt.{u1, u2} H _inst_1 M _inst_2 _inst_3 x) (ChartedSpace.chart_mem_atlas.{u1, u2} H _inst_1 M _inst_2 _inst_3 x))
but is expected to have type
  forall (H : Type.{u2}) {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] (x : M), Eq.{max (succ u2) (succ u1)} (Set.Elem.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (ChartedSpace.atlas.{u2, u1} H _inst_1 M _inst_2 _inst_3)) (achart.{u2, u1} H M _inst_1 _inst_2 _inst_3 x) (Subtype.mk.{max (succ u2) (succ u1)} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (fun (x : LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) => Membership.mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) (Set.instMembershipSet.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) x (ChartedSpace.atlas.{u2, u1} H _inst_1 M _inst_2 _inst_3)) (ChartedSpace.chartAt.{u2, u1} H _inst_1 M _inst_2 _inst_3 x) (ChartedSpace.chart_mem_atlas.{u2, u1} H _inst_1 M _inst_2 _inst_3 x))
Case conversion may be inaccurate. Consider using '#align achart_def achart_defₓ'. -/
theorem achart_def (x : M) : achart H x = ⟨chartAt H x, chart_mem_atlas H x⟩ :=
  rfl
#align achart_def achart_def

/- warning: coe_achart -> coe_achart is a dubious translation:
lean 3 declaration is
  forall (H : Type.{u1}) {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] (x : M), Eq.{max (succ u2) (succ u1)} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) ((fun (a : Type.{max u2 u1}) (b : Sort.{max (succ u2) (succ u1)}) [self : HasLiftT.{succ (max u2 u1), max (succ u2) (succ u1)} a b] => self.0) (coeSort.{succ (max u2 u1), succ (succ (max u2 u1))} (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) Type.{max u2 u1} (Set.hasCoeToSort.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (ChartedSpace.atlas.{u1, u2} H _inst_1 M _inst_2 _inst_3)) (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (HasLiftT.mk.{succ (max u2 u1), max (succ u2) (succ u1)} (coeSort.{succ (max u2 u1), succ (succ (max u2 u1))} (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) Type.{max u2 u1} (Set.hasCoeToSort.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (ChartedSpace.atlas.{u1, u2} H _inst_1 M _inst_2 _inst_3)) (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (CoeTCₓ.coe.{succ (max u2 u1), max (succ u2) (succ u1)} (coeSort.{succ (max u2 u1), succ (succ (max u2 u1))} (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) Type.{max u2 u1} (Set.hasCoeToSort.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (ChartedSpace.atlas.{u1, u2} H _inst_1 M _inst_2 _inst_3)) (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (coeBase.{succ (max u2 u1), max (succ u2) (succ u1)} (coeSort.{succ (max u2 u1), succ (succ (max u2 u1))} (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) Type.{max u2 u1} (Set.hasCoeToSort.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (ChartedSpace.atlas.{u1, u2} H _inst_1 M _inst_2 _inst_3)) (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (coeSubtype.{max (succ u2) (succ u1)} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (fun (x : LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) => Membership.Mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (Set.hasMem.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) x (ChartedSpace.atlas.{u1, u2} H _inst_1 M _inst_2 _inst_3)))))) (achart.{u1, u2} H M _inst_1 _inst_2 _inst_3 x)) (ChartedSpace.chartAt.{u1, u2} H _inst_1 M _inst_2 _inst_3 x)
but is expected to have type
  forall (H : Type.{u2}) {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] (x : M), Eq.{max (succ u2) (succ u1)} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (Subtype.val.{succ (max u2 u1)} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (fun (x : LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) => Membership.mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) (Set.instMembershipSet.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) x (ChartedSpace.atlas.{u2, u1} H _inst_1 M _inst_2 _inst_3)) (achart.{u2, u1} H M _inst_1 _inst_2 _inst_3 x)) (ChartedSpace.chartAt.{u2, u1} H _inst_1 M _inst_2 _inst_3 x)
Case conversion may be inaccurate. Consider using '#align coe_achart coe_achartₓ'. -/
@[simp, mfld_simps]
theorem coe_achart (x : M) : (achart H x : LocalHomeomorph M H) = chartAt H x :=
  rfl
#align coe_achart coe_achart

/- warning: achart_val -> achart_val is a dubious translation:
lean 3 declaration is
  forall (H : Type.{u1}) {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] (x : M), Eq.{max (succ u2) (succ u1)} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (Subtype.val.{succ (max u2 u1)} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (fun (x : LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) => Membership.Mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (Set.hasMem.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) x (ChartedSpace.atlas.{u1, u2} H _inst_1 M _inst_2 _inst_3)) (achart.{u1, u2} H M _inst_1 _inst_2 _inst_3 x)) (ChartedSpace.chartAt.{u1, u2} H _inst_1 M _inst_2 _inst_3 x)
but is expected to have type
  forall (H : Type.{u2}) {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] (x : M), Eq.{max (succ u2) (succ u1)} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (Subtype.val.{max (succ u2) (succ u1)} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (fun (x : LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) => Membership.mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) (Set.instMembershipSet.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) x (ChartedSpace.atlas.{u2, u1} H _inst_1 M _inst_2 _inst_3)) (achart.{u2, u1} H M _inst_1 _inst_2 _inst_3 x)) (ChartedSpace.chartAt.{u2, u1} H _inst_1 M _inst_2 _inst_3 x)
Case conversion may be inaccurate. Consider using '#align achart_val achart_valₓ'. -/
@[simp, mfld_simps]
theorem achart_val (x : M) : (achart H x).1 = chartAt H x :=
  rfl
#align achart_val achart_val

/- warning: mem_achart_source -> mem_achart_source is a dubious translation:
lean 3 declaration is
  forall (H : Type.{u1}) {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] (x : M), Membership.Mem.{u2, u2} M (Set.{u2} M) (Set.hasMem.{u2} M) x (LocalEquiv.source.{u2, u1} M H (LocalHomeomorph.toLocalEquiv.{u2, u1} M H _inst_2 _inst_1 (Subtype.val.{succ (max u2 u1)} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (fun (x : LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) => Membership.Mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (Set.hasMem.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) x (ChartedSpace.atlas.{u1, u2} H _inst_1 M _inst_2 _inst_3)) (achart.{u1, u2} H M _inst_1 _inst_2 _inst_3 x))))
but is expected to have type
  forall (H : Type.{u2}) {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] (x : M), Membership.mem.{u1, u1} M (Set.{u1} M) (Set.instMembershipSet.{u1} M) x (LocalEquiv.source.{u1, u2} M H (LocalHomeomorph.toLocalEquiv.{u1, u2} M H _inst_2 _inst_1 (Subtype.val.{max (succ u2) (succ u1)} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (fun (x : LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) => Membership.mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) (Set.instMembershipSet.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) x (ChartedSpace.atlas.{u2, u1} H _inst_1 M _inst_2 _inst_3)) (achart.{u2, u1} H M _inst_1 _inst_2 _inst_3 x))))
Case conversion may be inaccurate. Consider using '#align mem_achart_source mem_achart_sourceₓ'. -/
theorem mem_achart_source (x : M) : x ∈ (achart H x).1.source :=
  mem_chart_source H x
#align mem_achart_source mem_achart_source

open TopologicalSpace

/- warning: charted_space.second_countable_of_countable_cover -> ChartedSpace.secondCountable_of_countable_cover is a dubious translation:
lean 3 declaration is
  forall (H : Type.{u1}) {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] [_inst_4 : TopologicalSpace.SecondCountableTopology.{u1} H _inst_1] {s : Set.{u2} M}, (Eq.{succ u2} (Set.{u2} M) (Set.iUnion.{u2, succ u2} M M (fun (x : M) => Set.iUnion.{u2, 0} M (Membership.Mem.{u2, u2} M (Set.{u2} M) (Set.hasMem.{u2} M) x s) (fun (hx : Membership.Mem.{u2, u2} M (Set.{u2} M) (Set.hasMem.{u2} M) x s) => LocalEquiv.source.{u2, u1} M H (LocalHomeomorph.toLocalEquiv.{u2, u1} M H _inst_2 _inst_1 (ChartedSpace.chartAt.{u1, u2} H _inst_1 M _inst_2 _inst_3 x))))) (Set.univ.{u2} M)) -> (Set.Countable.{u2} M s) -> (TopologicalSpace.SecondCountableTopology.{u2} M _inst_2)
but is expected to have type
  forall (H : Type.{u2}) {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] [_inst_4 : TopologicalSpace.SecondCountableTopology.{u2} H _inst_1] {s : Set.{u1} M}, (Eq.{succ u1} (Set.{u1} M) (Set.iUnion.{u1, succ u1} M M (fun (x : M) => Set.iUnion.{u1, 0} M (Membership.mem.{u1, u1} M (Set.{u1} M) (Set.instMembershipSet.{u1} M) x s) (fun (hx : Membership.mem.{u1, u1} M (Set.{u1} M) (Set.instMembershipSet.{u1} M) x s) => LocalEquiv.source.{u1, u2} M H (LocalHomeomorph.toLocalEquiv.{u1, u2} M H _inst_2 _inst_1 (ChartedSpace.chartAt.{u2, u1} H _inst_1 M _inst_2 _inst_3 x))))) (Set.univ.{u1} M)) -> (Set.Countable.{u1} M s) -> (TopologicalSpace.SecondCountableTopology.{u1} M _inst_2)
Case conversion may be inaccurate. Consider using '#align charted_space.second_countable_of_countable_cover ChartedSpace.secondCountable_of_countable_coverₓ'. -/
theorem ChartedSpace.secondCountable_of_countable_cover [SecondCountableTopology H] {s : Set M}
    (hs : (⋃ (x) (hx : x ∈ s), (chartAt H x).source) = univ) (hsc : s.Countable) :
    SecondCountableTopology M :=
  by
  haveI : ∀ x : M, second_countable_topology (chart_at H x).source := fun x =>
    (chart_at H x).secondCountableTopology_source
  haveI := hsc.to_encodable
  rw [bUnion_eq_Union] at hs
  exact
    second_countable_topology_of_countable_cover (fun x : s => (chart_at H (x : M)).open_source) hs
#align charted_space.second_countable_of_countable_cover ChartedSpace.secondCountable_of_countable_cover

variable (M)

/- warning: charted_space.second_countable_of_sigma_compact -> ChartedSpace.secondCountable_of_sigma_compact is a dubious translation:
lean 3 declaration is
  forall (H : Type.{u1}) (M : Type.{u2}) [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] [_inst_4 : TopologicalSpace.SecondCountableTopology.{u1} H _inst_1] [_inst_5 : SigmaCompactSpace.{u2} M _inst_2], TopologicalSpace.SecondCountableTopology.{u2} M _inst_2
but is expected to have type
  forall (H : Type.{u2}) (M : Type.{u1}) [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] [_inst_4 : TopologicalSpace.SecondCountableTopology.{u2} H _inst_1] [_inst_5 : SigmaCompactSpace.{u1} M _inst_2], TopologicalSpace.SecondCountableTopology.{u1} M _inst_2
Case conversion may be inaccurate. Consider using '#align charted_space.second_countable_of_sigma_compact ChartedSpace.secondCountable_of_sigma_compactₓ'. -/
theorem ChartedSpace.secondCountable_of_sigma_compact [SecondCountableTopology H]
    [SigmaCompactSpace M] : SecondCountableTopology M :=
  by
  obtain ⟨s, hsc, hsU⟩ :
    ∃ s, Set.Countable s ∧ (⋃ (x) (hx : x ∈ s), (chart_at H x).source) = univ :=
    countable_cover_nhds_of_sigma_compact fun x : M => chart_source_mem_nhds H x
  exact ChartedSpace.secondCountable_of_countable_cover H hsU hsc
#align charted_space.second_countable_of_sigma_compact ChartedSpace.secondCountable_of_sigma_compact

/- warning: charted_space.locally_compact -> ChartedSpace.locallyCompact is a dubious translation:
lean 3 declaration is
  forall (H : Type.{u1}) (M : Type.{u2}) [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] [_inst_4 : LocallyCompactSpace.{u1} H _inst_1], LocallyCompactSpace.{u2} M _inst_2
but is expected to have type
  forall (H : Type.{u2}) (M : Type.{u1}) [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] [_inst_4 : LocallyCompactSpace.{u2} H _inst_1], LocallyCompactSpace.{u1} M _inst_2
Case conversion may be inaccurate. Consider using '#align charted_space.locally_compact ChartedSpace.locallyCompactₓ'. -/
/-- If a topological space admits an atlas with locally compact charts, then the space itself
is locally compact. -/
theorem ChartedSpace.locallyCompact [LocallyCompactSpace H] : LocallyCompactSpace M :=
  by
  have :
    ∀ x : M,
      (𝓝 x).HasBasis (fun s => s ∈ 𝓝 (chart_at H x x) ∧ IsCompact s ∧ s ⊆ (chart_at H x).target)
        fun s => (chart_at H x).symm '' s :=
    by
    intro x
    rw [← (chart_at H x).symm_map_nhds_eq (mem_chart_source H x)]
    exact
      ((compact_basis_nhds (chart_at H x x)).hasBasis_self_subset (chart_target_mem_nhds H x)).map _
  refine' locallyCompactSpace_of_hasBasis this _
  rintro x s ⟨h₁, h₂, h₃⟩
  exact h₂.image_of_continuous_on ((chart_at H x).continuousOn_symm.mono h₃)
#align charted_space.locally_compact ChartedSpace.locallyCompact

/- warning: charted_space.locally_connected_space -> ChartedSpace.locallyConnectedSpace is a dubious translation:
lean 3 declaration is
  forall (H : Type.{u1}) (M : Type.{u2}) [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] [_inst_4 : LocallyConnectedSpace.{u1} H _inst_1], LocallyConnectedSpace.{u2} M _inst_2
but is expected to have type
  forall (H : Type.{u2}) (M : Type.{u1}) [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] [_inst_4 : LocallyConnectedSpace.{u2} H _inst_1], LocallyConnectedSpace.{u1} M _inst_2
Case conversion may be inaccurate. Consider using '#align charted_space.locally_connected_space ChartedSpace.locallyConnectedSpaceₓ'. -/
/-- If a topological space admits an atlas with locally connected charts, then the space itself is
locally connected. -/
theorem ChartedSpace.locallyConnectedSpace [LocallyConnectedSpace H] : LocallyConnectedSpace M :=
  by
  let E : M → LocalHomeomorph M H := chart_at H
  refine'
    locallyConnectedSpace_of_connected_bases (fun x s => (E x).symm '' s)
      (fun x s => (IsOpen s ∧ E x x ∈ s ∧ IsConnected s) ∧ s ⊆ (E x).target) _ _
  · intro x
    simpa only [LocalHomeomorph.symm_map_nhds_eq, mem_chart_source] using
      ((LocallyConnectedSpace.open_connected_basis (E x x)).restrict_subset
            ((E x).open_target.mem_nhds (mem_chart_target H x))).map
        (E x).symm
  · rintro x s ⟨⟨-, -, hsconn⟩, hssubset⟩
    exact hsconn.is_preconnected.image _ ((E x).continuousOn_symm.mono hssubset)
#align charted_space.locally_connected_space ChartedSpace.locallyConnectedSpace

#print ChartedSpace.comp /-
/-- If `M` is modelled on `H'` and `H'` is itself modelled on `H`, then we can consider `M` as being
modelled on `H`. -/
def ChartedSpace.comp (H : Type _) [TopologicalSpace H] (H' : Type _) [TopologicalSpace H']
    (M : Type _) [TopologicalSpace M] [ChartedSpace H H'] [ChartedSpace H' M] : ChartedSpace H M
    where
  atlas := image2 LocalHomeomorph.trans (atlas H' M) (atlas H H')
  chartAt := fun p : M => (chartAt H' p).trans (chartAt H (chartAt H' p p))
  mem_chart_source p := by simp only [mfld_simps]
  chart_mem_atlas p := ⟨chartAt H' p, chartAt H _, chart_mem_atlas H' p, chart_mem_atlas H _, rfl⟩
#align charted_space.comp ChartedSpace.comp
-/

end

library_note "Manifold type tags"/-- For technical reasons we introduce two type tags:

* `model_prod H H'` is the same as `H × H'`;
* `model_pi H` is the same as `Π i, H i`, where `H : ι → Type*` and `ι` is a finite type.

In both cases the reason is the same, so we explain it only in the case of the product. A charted
space `M` with model `H` is a set of local charts from `M` to `H` covering the space. Every space is
registered as a charted space over itself, using the only chart `id`, in `manifold_model_space`. You
can also define a product of charted space `M` and `M'` (with model space `H × H'`) by taking the
products of the charts. Now, on `H × H'`, there are two charted space structures with model space
`H × H'` itself, the one coming from `manifold_model_space`, and the one coming from the product of
the two `manifold_model_space` on each component. They are equal, but not defeq (because the product
of `id` and `id` is not defeq to `id`), which is bad as we know. This expedient of renaming `H × H'`
solves this problem. -/


#print ModelProd /-
/-- Same thing as `H × H'` We introduce it for technical reasons,
see note [Manifold type tags]. -/
def ModelProd (H : Type _) (H' : Type _) :=
  H × H'
#align model_prod ModelProd
-/

#print ModelPi /-
/-- Same thing as `Π i, H i` We introduce it for technical reasons,
see note [Manifold type tags]. -/
def ModelPi {ι : Type _} (H : ι → Type _) :=
  ∀ i, H i
#align model_pi ModelPi
-/

section

attribute [local reducible] ModelProd

#print modelProdInhabited /-
instance modelProdInhabited [Inhabited H] [Inhabited H'] : Inhabited (ModelProd H H') :=
  Prod.inhabited
#align model_prod_inhabited modelProdInhabited
-/

instance (H : Type _) [TopologicalSpace H] (H' : Type _) [TopologicalSpace H'] :
    TopologicalSpace (ModelProd H H') :=
  Prod.topologicalSpace

/- warning: model_prod_range_prod_id -> modelProd_range_prod_id is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} {H' : Type.{u2}} {α : Type.{u3}} (f : H -> α), Eq.{succ (max u3 u2)} (Set.{max u3 u2} (Prod.{u3, u2} α H')) (Set.range.{max u3 u2, max (succ u1) (succ u2)} (Prod.{u3, u2} α H') (ModelProd.{u1, u2} H H') (fun (p : ModelProd.{u1, u2} H H') => Prod.mk.{u3, u2} α H' (f (Prod.fst.{u1, u2} H H' p)) (Prod.snd.{u1, u2} H H' p))) (Set.prod.{u3, u2} α H' (Set.range.{u3, succ u1} α H f) (Set.univ.{u2} H'))
but is expected to have type
  forall {H : Type.{u3}} {H' : Type.{u2}} {α : Type.{u1}} (f : H -> α), Eq.{max (succ u2) (succ u1)} (Set.{max u2 u1} (Prod.{u1, u2} α H')) (Set.range.{max u2 u1, max (succ u3) (succ u2)} (Prod.{u1, u2} α H') (ModelProd.{u3, u2} H H') (fun (p : ModelProd.{u3, u2} H H') => Prod.mk.{u1, u2} α H' (f (Prod.fst.{u3, u2} H H' p)) (Prod.snd.{u3, u2} H H' p))) (Set.prod.{u1, u2} α H' (Set.range.{u1, succ u3} α H f) (Set.univ.{u2} H'))
Case conversion may be inaccurate. Consider using '#align model_prod_range_prod_id modelProd_range_prod_idₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
-- Next lemma shows up often when dealing with derivatives, register it as simp.
@[simp, mfld_simps]
theorem modelProd_range_prod_id {H : Type _} {H' : Type _} {α : Type _} (f : H → α) :
    (range fun p : ModelProd H H' => (f p.1, p.2)) = range f ×ˢ (univ : Set H') := by
  rw [prod_range_univ_eq]
#align model_prod_range_prod_id modelProd_range_prod_id

end

section

variable {ι : Type _} {Hi : ι → Type _}

#print modelPiInhabited /-
instance modelPiInhabited [∀ i, Inhabited (Hi i)] : Inhabited (ModelPi Hi) :=
  Pi.inhabited _
#align model_pi_inhabited modelPiInhabited
-/

instance [∀ i, TopologicalSpace (Hi i)] : TopologicalSpace (ModelPi Hi) :=
  Pi.topologicalSpace

end

/- warning: prod_charted_space -> prodChartedSpace is a dubious translation:
lean 3 declaration is
  forall (H : Type.{u1}) [_inst_1 : TopologicalSpace.{u1} H] (M : Type.{u2}) [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] (H' : Type.{u3}) [_inst_4 : TopologicalSpace.{u3} H'] (M' : Type.{u4}) [_inst_5 : TopologicalSpace.{u4} M'] [_inst_6 : ChartedSpace.{u3, u4} H' _inst_4 M' _inst_5], ChartedSpace.{max u1 u3, max u2 u4} (ModelProd.{u1, u3} H H') (ModelProd.topologicalSpace.{u1, u3} H _inst_1 H' _inst_4) (Prod.{u2, u4} M M') (Prod.topologicalSpace.{u2, u4} M M' _inst_2 _inst_5)
but is expected to have type
  forall (H : Type.{u1}) [_inst_1 : TopologicalSpace.{u1} H] (M : Type.{u2}) [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] (H' : Type.{u3}) [_inst_4 : TopologicalSpace.{u3} H'] (M' : Type.{u4}) [_inst_5 : TopologicalSpace.{u4} M'] [_inst_6 : ChartedSpace.{u3, u4} H' _inst_4 M' _inst_5], ChartedSpace.{max u3 u1, max u4 u2} (ModelProd.{u1, u3} H H') (instTopologicalSpaceModelProd.{u1, u3} H _inst_1 H' _inst_4) (Prod.{u2, u4} M M') (instTopologicalSpaceProd.{u2, u4} M M' _inst_2 _inst_5)
Case conversion may be inaccurate. Consider using '#align prod_charted_space prodChartedSpaceₓ'. -/
/-- The product of two charted spaces is naturally a charted space, with the canonical
construction of the atlas of product maps. -/
instance prodChartedSpace (H : Type _) [TopologicalSpace H] (M : Type _) [TopologicalSpace M]
    [ChartedSpace H M] (H' : Type _) [TopologicalSpace H'] (M' : Type _) [TopologicalSpace M']
    [ChartedSpace H' M'] : ChartedSpace (ModelProd H H') (M × M')
    where
  atlas := image2 LocalHomeomorph.prod (atlas H M) (atlas H' M')
  chartAt := fun x : M × M' => (chartAt H x.1).Prod (chartAt H' x.2)
  mem_chart_source x := ⟨mem_chart_source _ _, mem_chart_source _ _⟩
  chart_mem_atlas x := mem_image2_of_mem (chart_mem_atlas _ _) (chart_mem_atlas _ _)
#align prod_charted_space prodChartedSpace

section prodChartedSpace

variable [TopologicalSpace H] [TopologicalSpace M] [ChartedSpace H M] [TopologicalSpace H']
  [TopologicalSpace M'] [ChartedSpace H' M'] {x : M × M'}

/- warning: prod_charted_space_chart_at -> prodChartedSpace_chartAt is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} {H' : Type.{u2}} {M : Type.{u3}} {M' : Type.{u4}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u3} M] [_inst_3 : ChartedSpace.{u1, u3} H _inst_1 M _inst_2] [_inst_4 : TopologicalSpace.{u2} H'] [_inst_5 : TopologicalSpace.{u4} M'] [_inst_6 : ChartedSpace.{u2, u4} H' _inst_4 M' _inst_5] {x : Prod.{u3, u4} M M'}, Eq.{max (succ (max u3 u4)) (succ (max u1 u2))} (LocalHomeomorph.{max u3 u4, max u1 u2} (Prod.{u3, u4} M M') (ModelProd.{u1, u2} H H') (Prod.topologicalSpace.{u3, u4} M M' _inst_2 _inst_5) (ModelProd.topologicalSpace.{u1, u2} H _inst_1 H' _inst_4)) (ChartedSpace.chartAt.{max u1 u2, max u3 u4} (ModelProd.{u1, u2} H H') (ModelProd.topologicalSpace.{u1, u2} H _inst_1 H' _inst_4) (Prod.{u3, u4} M M') (Prod.topologicalSpace.{u3, u4} M M' _inst_2 _inst_5) (prodChartedSpace.{u1, u3, u2, u4} H _inst_1 M _inst_2 _inst_3 H' _inst_4 M' _inst_5 _inst_6) x) (LocalHomeomorph.prod.{u3, u1, u4, u2} M H M' H' _inst_2 _inst_1 _inst_5 _inst_4 (ChartedSpace.chartAt.{u1, u3} H _inst_1 M _inst_2 _inst_3 (Prod.fst.{u3, u4} M M' x)) (ChartedSpace.chartAt.{u2, u4} H' _inst_4 M' _inst_5 _inst_6 (Prod.snd.{u3, u4} M M' x)))
but is expected to have type
  forall {H : Type.{u4}} {H' : Type.{u3}} {M : Type.{u2}} {M' : Type.{u1}} [_inst_1 : TopologicalSpace.{u4} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u4, u2} H _inst_1 M _inst_2] [_inst_4 : TopologicalSpace.{u3} H'] [_inst_5 : TopologicalSpace.{u1} M'] [_inst_6 : ChartedSpace.{u3, u1} H' _inst_4 M' _inst_5] {x : Prod.{u2, u1} M M'}, Eq.{max (max (max (succ u4) (succ u3)) (succ u2)) (succ u1)} (LocalHomeomorph.{max u2 u1, max u3 u4} (Prod.{u2, u1} M M') (ModelProd.{u4, u3} H H') (instTopologicalSpaceProd.{u2, u1} M M' _inst_2 _inst_5) (instTopologicalSpaceModelProd.{u4, u3} H _inst_1 H' _inst_4)) (ChartedSpace.chartAt.{max u3 u4, max u2 u1} (ModelProd.{u4, u3} H H') (instTopologicalSpaceModelProd.{u4, u3} H _inst_1 H' _inst_4) (Prod.{u2, u1} M M') (instTopologicalSpaceProd.{u2, u1} M M' _inst_2 _inst_5) (prodChartedSpace.{u4, u2, u3, u1} H _inst_1 M _inst_2 _inst_3 H' _inst_4 M' _inst_5 _inst_6) x) (LocalHomeomorph.prod.{u2, u4, u1, u3} M H M' H' _inst_2 _inst_1 _inst_5 _inst_4 (ChartedSpace.chartAt.{u4, u2} H _inst_1 M _inst_2 _inst_3 (Prod.fst.{u2, u1} M M' x)) (ChartedSpace.chartAt.{u3, u1} H' _inst_4 M' _inst_5 _inst_6 (Prod.snd.{u2, u1} M M' x)))
Case conversion may be inaccurate. Consider using '#align prod_charted_space_chart_at prodChartedSpace_chartAtₓ'. -/
@[simp, mfld_simps]
theorem prodChartedSpace_chartAt :
    chartAt (ModelProd H H') x = (chartAt H x.fst).Prod (chartAt H' x.snd) :=
  rfl
#align prod_charted_space_chart_at prodChartedSpace_chartAt

/- warning: charted_space_self_prod -> chartedSpaceSelf_prod is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} {H' : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_4 : TopologicalSpace.{u2} H'], Eq.{succ (max u1 u2)} (ChartedSpace.{max u1 u2, max u1 u2} (ModelProd.{u1, u2} H H') (ModelProd.topologicalSpace.{u1, u2} H _inst_1 H' _inst_4) (Prod.{u1, u2} H H') (Prod.topologicalSpace.{u1, u2} H H' _inst_1 _inst_4)) (prodChartedSpace.{u1, u1, u2, u2} H _inst_1 H _inst_1 (chartedSpaceSelf.{u1} H _inst_1) H' _inst_4 H' _inst_4 (chartedSpaceSelf.{u2} H' _inst_4)) (chartedSpaceSelf.{max u1 u2} (Prod.{u1, u2} H H') (ModelProd.topologicalSpace.{u1, u2} H _inst_1 H' _inst_4))
but is expected to have type
  forall {H : Type.{u2}} {H' : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] [_inst_4 : TopologicalSpace.{u1} H'], Eq.{max (succ u2) (succ u1)} (ChartedSpace.{max u1 u2, max u1 u2} (ModelProd.{u2, u1} H H') (instTopologicalSpaceModelProd.{u2, u1} H _inst_1 H' _inst_4) (Prod.{u2, u1} H H') (instTopologicalSpaceProd.{u2, u1} H H' _inst_1 _inst_4)) (prodChartedSpace.{u2, u2, u1, u1} H _inst_1 H _inst_1 (chartedSpaceSelf.{u2} H _inst_1) H' _inst_4 H' _inst_4 (chartedSpaceSelf.{u1} H' _inst_4)) (chartedSpaceSelf.{max u1 u2} (Prod.{u2, u1} H H') (instTopologicalSpaceProd.{u2, u1} H H' _inst_1 _inst_4))
Case conversion may be inaccurate. Consider using '#align charted_space_self_prod chartedSpaceSelf_prodₓ'. -/
theorem chartedSpaceSelf_prod : prodChartedSpace H H H' H' = chartedSpaceSelf (H × H') :=
  by
  ext1
  · simp [prodChartedSpace, atlas]
  · ext1
    simp [chartAt_self_eq]
    rfl
#align charted_space_self_prod chartedSpaceSelf_prod

end prodChartedSpace

#print piChartedSpace /-
/-- The product of a finite family of charted spaces is naturally a charted space, with the
canonical construction of the atlas of finite product maps. -/
instance piChartedSpace {ι : Type _} [Fintype ι] (H : ι → Type _) [∀ i, TopologicalSpace (H i)]
    (M : ι → Type _) [∀ i, TopologicalSpace (M i)] [∀ i, ChartedSpace (H i) (M i)] :
    ChartedSpace (ModelPi H) (∀ i, M i)
    where
  atlas := LocalHomeomorph.pi '' Set.pi univ fun i => atlas (H i) (M i)
  chartAt f := LocalHomeomorph.pi fun i => chartAt (H i) (f i)
  mem_chart_source f i hi := mem_chart_source (H i) (f i)
  chart_mem_atlas f := mem_image_of_mem _ fun i hi => chart_mem_atlas (H i) (f i)
#align pi_charted_space piChartedSpace
-/

/- warning: pi_charted_space_chart_at -> piChartedSpace_chartAt is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (H : ι -> Type.{u2}) [_inst_2 : forall (i : ι), TopologicalSpace.{u2} (H i)] (M : ι -> Type.{u3}) [_inst_3 : forall (i : ι), TopologicalSpace.{u3} (M i)] [_inst_4 : forall (i : ι), ChartedSpace.{u2, u3} (H i) (_inst_2 i) (M i) (_inst_3 i)] (f : forall (i : ι), M i), Eq.{max (succ (max u1 u3)) (succ (max u1 u2))} (LocalHomeomorph.{max u1 u3, max u1 u2} (forall (i : ι), M i) (ModelPi.{u1, u2} ι H) (Pi.topologicalSpace.{u1, u3} ι (fun (i : ι) => M i) (fun (a : ι) => _inst_3 a)) (ModelPi.topologicalSpace.{u1, u2} ι H (fun (i : ι) => _inst_2 i))) (ChartedSpace.chartAt.{max u1 u2, max u1 u3} (ModelPi.{u1, u2} ι H) (ModelPi.topologicalSpace.{u1, u2} ι H (fun (i : ι) => _inst_2 i)) (forall (i : ι), M i) (Pi.topologicalSpace.{u1, u3} ι (fun (i : ι) => M i) (fun (a : ι) => _inst_3 a)) (piChartedSpace.{u1, u2, u3} ι _inst_1 H (fun (i : ι) => _inst_2 i) (fun (i : ι) => M i) (fun (a : ι) => _inst_3 a) (fun (i : ι) => _inst_4 i)) f) (LocalHomeomorph.pi.{u1, u3, u2} ι _inst_1 (fun (i : ι) => M i) (fun (i : ι) => H i) (fun (i : ι) => _inst_3 i) (fun (a : ι) => (fun (i : ι) => _inst_2 i) a) (fun (i : ι) => ChartedSpace.chartAt.{u2, u3} (H i) ((fun (i : ι) => _inst_2 i) i) (M i) (_inst_3 i) (_inst_4 i) (f i)))
but is expected to have type
  forall {ι : Type.{u3}} [_inst_1 : Fintype.{u3} ι] (H : ι -> Type.{u2}) [_inst_2 : forall (i : ι), TopologicalSpace.{u2} (H i)] (M : ι -> Type.{u1}) [_inst_3 : forall (i : ι), TopologicalSpace.{u1} (M i)] [_inst_4 : forall (i : ι), ChartedSpace.{u2, u1} (H i) (_inst_2 i) (M i) (_inst_3 i)] (f : forall (i : ι), M i), Eq.{max (max (succ u3) (succ u2)) (succ u1)} (LocalHomeomorph.{max u3 u1, max u2 u3} (forall (i : ι), M i) (ModelPi.{u3, u2} ι H) (Pi.topologicalSpace.{u3, u1} ι (fun (i : ι) => M i) (fun (a : ι) => _inst_3 a)) (instTopologicalSpaceModelPi.{u3, u2} ι H (fun (i : ι) => _inst_2 i))) (ChartedSpace.chartAt.{max u2 u3, max u3 u1} (ModelPi.{u3, u2} ι H) (instTopologicalSpaceModelPi.{u3, u2} ι H (fun (i : ι) => _inst_2 i)) (forall (i : ι), M i) (Pi.topologicalSpace.{u3, u1} ι (fun (i : ι) => M i) (fun (a : ι) => _inst_3 a)) (piChartedSpace.{u3, u2, u1} ι _inst_1 H (fun (i : ι) => _inst_2 i) (fun (i : ι) => M i) (fun (a : ι) => _inst_3 a) (fun (i : ι) => _inst_4 i)) f) (LocalHomeomorph.pi.{u3, u1, u2} ι _inst_1 (fun (i : ι) => M i) (fun (i : ι) => H i) (fun (i : ι) => _inst_3 i) (fun (a : ι) => (fun (i : ι) => _inst_2 i) a) (fun (i : ι) => ChartedSpace.chartAt.{u2, u1} (H i) ((fun (i : ι) => _inst_2 i) i) (M i) (_inst_3 i) (_inst_4 i) (f i)))
Case conversion may be inaccurate. Consider using '#align pi_charted_space_chart_at piChartedSpace_chartAtₓ'. -/
@[simp, mfld_simps]
theorem piChartedSpace_chartAt {ι : Type _} [Fintype ι] (H : ι → Type _)
    [∀ i, TopologicalSpace (H i)] (M : ι → Type _) [∀ i, TopologicalSpace (M i)]
    [∀ i, ChartedSpace (H i) (M i)] (f : ∀ i, M i) :
    chartAt (ModelPi H) f = LocalHomeomorph.pi fun i => chartAt (H i) (f i) :=
  rfl
#align pi_charted_space_chart_at piChartedSpace_chartAt

end ChartedSpace

/-! ### Constructing a topology from an atlas -/


#print ChartedSpaceCore /-
/-- Sometimes, one may want to construct a charted space structure on a space which does not yet
have a topological structure, where the topology would come from the charts. For this, one needs
charts that are only local equivs, and continuity properties for their composition.
This is formalised in `charted_space_core`. -/
@[nolint has_nonempty_instance]
structure ChartedSpaceCore (H : Type _) [TopologicalSpace H] (M : Type _) where
  atlas : Set (LocalEquiv M H)
  chartAt : M → LocalEquiv M H
  mem_chart_source : ∀ x, x ∈ (chart_at x).source
  chart_mem_atlas : ∀ x, chart_at x ∈ atlas
  open_source : ∀ e e' : LocalEquiv M H, e ∈ atlas → e' ∈ atlas → IsOpen (e.symm.trans e').source
  continuous_toFun :
    ∀ e e' : LocalEquiv M H,
      e ∈ atlas → e' ∈ atlas → ContinuousOn (e.symm.trans e') (e.symm.trans e').source
#align charted_space_core ChartedSpaceCore
-/

namespace ChartedSpaceCore

variable [TopologicalSpace H] (c : ChartedSpaceCore H M) {e : LocalEquiv M H}

#print ChartedSpaceCore.toTopologicalSpace /-
/-- Topology generated by a set of charts on a Type. -/
protected def toTopologicalSpace : TopologicalSpace M :=
  TopologicalSpace.generateFrom <|
    ⋃ (e : LocalEquiv M H) (he : e ∈ c.atlas) (s : Set H) (s_open : IsOpen s), {e ⁻¹' s ∩ e.source}
#align charted_space_core.to_topological_space ChartedSpaceCore.toTopologicalSpace
-/

/- warning: charted_space_core.open_source' -> ChartedSpaceCore.open_source' is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] (c : ChartedSpaceCore.{u1, u2} H _inst_1 M) {e : LocalEquiv.{u2, u1} M H}, (Membership.Mem.{max u2 u1, max u2 u1} (LocalEquiv.{u2, u1} M H) (Set.{max u2 u1} (LocalEquiv.{u2, u1} M H)) (Set.hasMem.{max u2 u1} (LocalEquiv.{u2, u1} M H)) e (ChartedSpaceCore.atlas.{u1, u2} H _inst_1 M c)) -> (IsOpen.{u2} M (ChartedSpaceCore.toTopologicalSpace.{u1, u2} H M _inst_1 c) (LocalEquiv.source.{u2, u1} M H e))
but is expected to have type
  forall {H : Type.{u2}} {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] (c : ChartedSpaceCore.{u2, u1} H _inst_1 M) {e : LocalEquiv.{u1, u2} M H}, (Membership.mem.{max u2 u1, max u2 u1} (LocalEquiv.{u1, u2} M H) (Set.{max u2 u1} (LocalEquiv.{u1, u2} M H)) (Set.instMembershipSet.{max u2 u1} (LocalEquiv.{u1, u2} M H)) e (ChartedSpaceCore.atlas.{u2, u1} H _inst_1 M c)) -> (IsOpen.{u1} M (ChartedSpaceCore.toTopologicalSpace.{u2, u1} H M _inst_1 c) (LocalEquiv.source.{u1, u2} M H e))
Case conversion may be inaccurate. Consider using '#align charted_space_core.open_source' ChartedSpaceCore.open_source'ₓ'. -/
theorem open_source' (he : e ∈ c.atlas) : is_open[c.toTopologicalSpace] e.source :=
  by
  apply TopologicalSpace.GenerateOpen.basic
  simp only [exists_prop, mem_Union, mem_singleton_iff]
  refine' ⟨e, he, univ, isOpen_univ, _⟩
  simp only [Set.univ_inter, Set.preimage_univ]
#align charted_space_core.open_source' ChartedSpaceCore.open_source'

/- warning: charted_space_core.open_target -> ChartedSpaceCore.open_target is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] (c : ChartedSpaceCore.{u1, u2} H _inst_1 M) {e : LocalEquiv.{u2, u1} M H}, (Membership.Mem.{max u2 u1, max u2 u1} (LocalEquiv.{u2, u1} M H) (Set.{max u2 u1} (LocalEquiv.{u2, u1} M H)) (Set.hasMem.{max u2 u1} (LocalEquiv.{u2, u1} M H)) e (ChartedSpaceCore.atlas.{u1, u2} H _inst_1 M c)) -> (IsOpen.{u1} H _inst_1 (LocalEquiv.target.{u2, u1} M H e))
but is expected to have type
  forall {H : Type.{u2}} {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] (c : ChartedSpaceCore.{u2, u1} H _inst_1 M) {e : LocalEquiv.{u1, u2} M H}, (Membership.mem.{max u2 u1, max u2 u1} (LocalEquiv.{u1, u2} M H) (Set.{max u2 u1} (LocalEquiv.{u1, u2} M H)) (Set.instMembershipSet.{max u2 u1} (LocalEquiv.{u1, u2} M H)) e (ChartedSpaceCore.atlas.{u2, u1} H _inst_1 M c)) -> (IsOpen.{u2} H _inst_1 (LocalEquiv.target.{u1, u2} M H e))
Case conversion may be inaccurate. Consider using '#align charted_space_core.open_target ChartedSpaceCore.open_targetₓ'. -/
theorem open_target (he : e ∈ c.atlas) : IsOpen e.target :=
  by
  have E : e.target ∩ e.symm ⁻¹' e.source = e.target :=
    subset.antisymm (inter_subset_left _ _) fun x hx =>
      ⟨hx, LocalEquiv.target_subset_preimage_source _ hx⟩
  simpa [LocalEquiv.trans_source, E] using c.open_source e e he he
#align charted_space_core.open_target ChartedSpaceCore.open_target

#print ChartedSpaceCore.localHomeomorph /-
/-- An element of the atlas in a charted space without topology becomes a local homeomorphism
for the topology constructed from this atlas. The `local_homeomorph` version is given in this
definition. -/
protected def localHomeomorph (e : LocalEquiv M H) (he : e ∈ c.atlas) :
    @LocalHomeomorph M H c.toTopologicalSpace _ :=
  { e with
    open_source := by convert c.open_source' he
    open_target := by convert c.open_target he
    continuous_toFun := by
      letI : TopologicalSpace M := c.to_topological_space
      rw [continuousOn_open_iff (c.open_source' he)]
      intro s s_open
      rw [inter_comm]
      apply TopologicalSpace.GenerateOpen.basic
      simp only [exists_prop, mem_Union, mem_singleton_iff]
      exact ⟨e, he, ⟨s, s_open, rfl⟩⟩
    continuous_invFun := by
      letI : TopologicalSpace M := c.to_topological_space
      apply continuousOn_open_of_generateFrom (c.open_target he)
      intro t ht
      simp only [exists_prop, mem_Union, mem_singleton_iff] at ht
      rcases ht with ⟨e', e'_atlas, s, s_open, ts⟩
      rw [ts]
      let f := e.symm.trans e'
      have : IsOpen (f ⁻¹' s ∩ f.source) := by
        simpa [inter_comm] using
          (continuousOn_open_iff (c.open_source e e' he e'_atlas)).1
            (c.continuous_to_fun e e' he e'_atlas) s s_open
      have A :
        e' ∘ e.symm ⁻¹' s ∩ (e.target ∩ e.symm ⁻¹' e'.source) =
          e.target ∩ (e' ∘ e.symm ⁻¹' s ∩ e.symm ⁻¹' e'.source) :=
        by
        rw [← inter_assoc, ← inter_assoc]
        congr 1
        exact inter_comm _ _
      simpa [LocalEquiv.trans_source, preimage_inter, preimage_comp.symm, A] using this }
#align charted_space_core.local_homeomorph ChartedSpaceCore.localHomeomorph
-/

#print ChartedSpaceCore.toChartedSpace /-
/-- Given a charted space without topology, endow it with a genuine charted space structure with
respect to the topology constructed from the atlas. -/
def toChartedSpace : @ChartedSpace H _ M c.toTopologicalSpace
    where
  atlas := ⋃ (e : LocalEquiv M H) (he : e ∈ c.atlas), {c.LocalHomeomorph e he}
  chartAt x := c.LocalHomeomorph (c.chartAt x) (c.chart_mem_atlas x)
  mem_chart_source x := c.mem_chart_source x
  chart_mem_atlas x := by
    simp only [mem_Union, mem_singleton_iff]
    exact ⟨c.chart_at x, c.chart_mem_atlas x, rfl⟩
#align charted_space_core.to_charted_space ChartedSpaceCore.toChartedSpace
-/

end ChartedSpaceCore

/-! ### Charted space with a given structure groupoid -/


section HasGroupoid

variable [TopologicalSpace H] [TopologicalSpace M] [ChartedSpace H M]

#print HasGroupoid /-
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`compatible] [] -/
/-- A charted space has an atlas in a groupoid `G` if the change of coordinates belong to the
groupoid -/
class HasGroupoid {H : Type _} [TopologicalSpace H] (M : Type _) [TopologicalSpace M]
  [ChartedSpace H M] (G : StructureGroupoid H) : Prop where
  compatible : ∀ {e e' : LocalHomeomorph M H}, e ∈ atlas H M → e' ∈ atlas H M → e.symm ≫ₕ e' ∈ G
#align has_groupoid HasGroupoid
-/

/- warning: structure_groupoid.compatible -> StructureGroupoid.compatible is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} [_inst_4 : TopologicalSpace.{u1} H] (G : StructureGroupoid.{u1} H _inst_4) {M : Type.{u2}} [_inst_5 : TopologicalSpace.{u2} M] [_inst_6 : ChartedSpace.{u1, u2} H _inst_4 M _inst_5] [_inst_7 : HasGroupoid.{u1, u2} H _inst_4 M _inst_5 _inst_6 G] {e : LocalHomeomorph.{u2, u1} M H _inst_5 _inst_4} {e' : LocalHomeomorph.{u2, u1} M H _inst_5 _inst_4}, (Membership.Mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_5 _inst_4) (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_5 _inst_4)) (Set.hasMem.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_5 _inst_4)) e (ChartedSpace.atlas.{u1, u2} H _inst_4 M _inst_5 _inst_6)) -> (Membership.Mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_5 _inst_4) (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_5 _inst_4)) (Set.hasMem.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_5 _inst_4)) e' (ChartedSpace.atlas.{u1, u2} H _inst_4 M _inst_5 _inst_6)) -> (Membership.Mem.{u1, u1} (LocalHomeomorph.{u1, u1} H H _inst_4 _inst_4) (StructureGroupoid.{u1} H _inst_4) (StructureGroupoid.hasMem.{u1} H _inst_4) (LocalHomeomorph.trans.{u1, u2, u1} H M H _inst_4 _inst_5 _inst_4 (LocalHomeomorph.symm.{u2, u1} M H _inst_5 _inst_4 e) e') G)
but is expected to have type
  forall {H : Type.{u2}} [_inst_4 : TopologicalSpace.{u2} H] (G : StructureGroupoid.{u2} H _inst_4) {M : Type.{u1}} [_inst_5 : TopologicalSpace.{u1} M] [_inst_6 : ChartedSpace.{u2, u1} H _inst_4 M _inst_5] [_inst_7 : HasGroupoid.{u2, u1} H _inst_4 M _inst_5 _inst_6 G] {e : LocalHomeomorph.{u1, u2} M H _inst_5 _inst_4} {e' : LocalHomeomorph.{u1, u2} M H _inst_5 _inst_4}, (Membership.mem.{max u2 u1, max u1 u2} (LocalHomeomorph.{u1, u2} M H _inst_5 _inst_4) (Set.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_5 _inst_4)) (Set.instMembershipSet.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_5 _inst_4)) e (ChartedSpace.atlas.{u2, u1} H _inst_4 M _inst_5 _inst_6)) -> (Membership.mem.{max u2 u1, max u1 u2} (LocalHomeomorph.{u1, u2} M H _inst_5 _inst_4) (Set.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_5 _inst_4)) (Set.instMembershipSet.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_5 _inst_4)) e' (ChartedSpace.atlas.{u2, u1} H _inst_4 M _inst_5 _inst_6)) -> (Membership.mem.{u2, u2} (LocalHomeomorph.{u2, u2} H H _inst_4 _inst_4) (StructureGroupoid.{u2} H _inst_4) (instMembershipLocalHomeomorphStructureGroupoid.{u2} H _inst_4) (LocalHomeomorph.trans.{u2, u1, u2} H M H _inst_4 _inst_5 _inst_4 (LocalHomeomorph.symm.{u1, u2} M H _inst_5 _inst_4 e) e') G)
Case conversion may be inaccurate. Consider using '#align structure_groupoid.compatible StructureGroupoid.compatibleₓ'. -/
/-- Reformulate in the `structure_groupoid` namespace the compatibility condition of charts in a
charted space admitting a structure groupoid, to make it more easily accessible with dot
notation. -/
theorem StructureGroupoid.compatible {H : Type _} [TopologicalSpace H] (G : StructureGroupoid H)
    {M : Type _} [TopologicalSpace M] [ChartedSpace H M] [HasGroupoid M G]
    {e e' : LocalHomeomorph M H} (he : e ∈ atlas H M) (he' : e' ∈ atlas H M) : e.symm ≫ₕ e' ∈ G :=
  HasGroupoid.compatible G he he'
#align structure_groupoid.compatible StructureGroupoid.compatible

/- warning: has_groupoid_of_le -> hasGroupoid_of_le is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] {G₁ : StructureGroupoid.{u1} H _inst_1} {G₂ : StructureGroupoid.{u1} H _inst_1}, (HasGroupoid.{u1, u2} H _inst_1 M _inst_2 _inst_3 G₁) -> (LE.le.{u1} (StructureGroupoid.{u1} H _inst_1) (Preorder.toLE.{u1} (StructureGroupoid.{u1} H _inst_1) (PartialOrder.toPreorder.{u1} (StructureGroupoid.{u1} H _inst_1) (StructureGroupoid.partialOrder.{u1} H _inst_1))) G₁ G₂) -> (HasGroupoid.{u1, u2} H _inst_1 M _inst_2 _inst_3 G₂)
but is expected to have type
  forall {H : Type.{u2}} {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] {G₁ : StructureGroupoid.{u2} H _inst_1} {G₂ : StructureGroupoid.{u2} H _inst_1}, (HasGroupoid.{u2, u1} H _inst_1 M _inst_2 _inst_3 G₁) -> (LE.le.{u2} (StructureGroupoid.{u2} H _inst_1) (Preorder.toLE.{u2} (StructureGroupoid.{u2} H _inst_1) (PartialOrder.toPreorder.{u2} (StructureGroupoid.{u2} H _inst_1) (StructureGroupoid.partialOrder.{u2} H _inst_1))) G₁ G₂) -> (HasGroupoid.{u2, u1} H _inst_1 M _inst_2 _inst_3 G₂)
Case conversion may be inaccurate. Consider using '#align has_groupoid_of_le hasGroupoid_of_leₓ'. -/
theorem hasGroupoid_of_le {G₁ G₂ : StructureGroupoid H} (h : HasGroupoid M G₁) (hle : G₁ ≤ G₂) :
    HasGroupoid M G₂ :=
  ⟨fun e e' he he' => hle (h.compatible he he')⟩
#align has_groupoid_of_le hasGroupoid_of_le

/- warning: has_groupoid_of_pregroupoid -> hasGroupoid_of_pregroupoid is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] (PG : Pregroupoid.{u1} H _inst_1), (forall {e : LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1} {e' : LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1}, (Membership.Mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (Set.hasMem.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) e (ChartedSpace.atlas.{u1, u2} H _inst_1 M _inst_2 _inst_3)) -> (Membership.Mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (Set.hasMem.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) e' (ChartedSpace.atlas.{u1, u2} H _inst_1 M _inst_2 _inst_3)) -> (Pregroupoid.Property.{u1} H _inst_1 PG (coeFn.{succ u1, succ u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (fun (_x : LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) => H -> H) (LocalHomeomorph.hasCoeToFun.{u1, u1} H H _inst_1 _inst_1) (LocalHomeomorph.trans.{u1, u2, u1} H M H _inst_1 _inst_2 _inst_1 (LocalHomeomorph.symm.{u2, u1} M H _inst_2 _inst_1 e) e')) (LocalEquiv.source.{u1, u1} H H (LocalHomeomorph.toLocalEquiv.{u1, u1} H H _inst_1 _inst_1 (LocalHomeomorph.trans.{u1, u2, u1} H M H _inst_1 _inst_2 _inst_1 (LocalHomeomorph.symm.{u2, u1} M H _inst_2 _inst_1 e) e'))))) -> (HasGroupoid.{u1, u2} H _inst_1 M _inst_2 _inst_3 (Pregroupoid.groupoid.{u1} H _inst_1 PG))
but is expected to have type
  forall {H : Type.{u2}} {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] (PG : Pregroupoid.{u2} H _inst_1), (forall {e : LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1} {e' : LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1}, (Membership.mem.{max u2 u1, max u1 u2} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) (Set.instMembershipSet.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) e (ChartedSpace.atlas.{u2, u1} H _inst_1 M _inst_2 _inst_3)) -> (Membership.mem.{max u2 u1, max u1 u2} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) (Set.instMembershipSet.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) e' (ChartedSpace.atlas.{u2, u1} H _inst_1 M _inst_2 _inst_3)) -> (Pregroupoid.property.{u2} H _inst_1 PG (LocalHomeomorph.toFun'.{u2, u2} H H _inst_1 _inst_1 (LocalHomeomorph.trans.{u2, u1, u2} H M H _inst_1 _inst_2 _inst_1 (LocalHomeomorph.symm.{u1, u2} M H _inst_2 _inst_1 e) e')) (LocalEquiv.source.{u2, u2} H H (LocalHomeomorph.toLocalEquiv.{u2, u2} H H _inst_1 _inst_1 (LocalHomeomorph.trans.{u2, u1, u2} H M H _inst_1 _inst_2 _inst_1 (LocalHomeomorph.symm.{u1, u2} M H _inst_2 _inst_1 e) e'))))) -> (HasGroupoid.{u2, u1} H _inst_1 M _inst_2 _inst_3 (Pregroupoid.groupoid.{u2} H _inst_1 PG))
Case conversion may be inaccurate. Consider using '#align has_groupoid_of_pregroupoid hasGroupoid_of_pregroupoidₓ'. -/
theorem hasGroupoid_of_pregroupoid (PG : Pregroupoid H)
    (h :
      ∀ {e e' : LocalHomeomorph M H},
        e ∈ atlas H M → e' ∈ atlas H M → PG.property (e.symm ≫ₕ e') (e.symm ≫ₕ e').source) :
    HasGroupoid M PG.groupoid :=
  ⟨fun e e' he he' => mem_groupoid_of_pregroupoid.mpr ⟨h he he', h he' he⟩⟩
#align has_groupoid_of_pregroupoid hasGroupoid_of_pregroupoid

#print hasGroupoid_model_space /-
/-- The trivial charted space structure on the model space is compatible with any groupoid -/
instance hasGroupoid_model_space (H : Type _) [TopologicalSpace H] (G : StructureGroupoid H) :
    HasGroupoid H G
    where compatible e e' he he' :=
    by
    replace he : e ∈ atlas H H := he
    replace he' : e' ∈ atlas H H := he'
    rw [chartedSpaceSelf_atlas] at he he'
    simp [he, he', StructureGroupoid.id_mem]
#align has_groupoid_model_space hasGroupoid_model_space
-/

#print hasGroupoid_continuousGroupoid /-
/-- Any charted space structure is compatible with the groupoid of all local homeomorphisms -/
instance hasGroupoid_continuousGroupoid : HasGroupoid M (continuousGroupoid H) :=
  ⟨by
    intro e e' he he'
    rw [continuousGroupoid, mem_groupoid_of_pregroupoid]
    simp only [and_self_iff]⟩
#align has_groupoid_continuous_groupoid hasGroupoid_continuousGroupoid
-/

section MaximalAtlas

variable (M) (G : StructureGroupoid H)

#print StructureGroupoid.maximalAtlas /-
/-- Given a charted space admitting a structure groupoid, the maximal atlas associated to this
structure groupoid is the set of all local charts that are compatible with the atlas, i.e., such
that changing coordinates with an atlas member gives an element of the groupoid. -/
def StructureGroupoid.maximalAtlas : Set (LocalHomeomorph M H) :=
  { e | ∀ e' ∈ atlas H M, e.symm ≫ₕ e' ∈ G ∧ e'.symm ≫ₕ e ∈ G }
#align structure_groupoid.maximal_atlas StructureGroupoid.maximalAtlas
-/

variable {M}

/- warning: structure_groupoid.subset_maximal_atlas -> StructureGroupoid.subset_maximalAtlas is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] (G : StructureGroupoid.{u1} H _inst_1) [_inst_4 : HasGroupoid.{u1, u2} H _inst_1 M _inst_2 _inst_3 G], HasSubset.Subset.{max u2 u1} (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (Set.hasSubset.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (ChartedSpace.atlas.{u1, u2} H _inst_1 M _inst_2 _inst_3) (StructureGroupoid.maximalAtlas.{u1, u2} H M _inst_1 _inst_2 _inst_3 G)
but is expected to have type
  forall {H : Type.{u2}} {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] (G : StructureGroupoid.{u2} H _inst_1) [_inst_4 : HasGroupoid.{u2, u1} H _inst_1 M _inst_2 _inst_3 G], HasSubset.Subset.{max u1 u2} (Set.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) (Set.instHasSubsetSet.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) (ChartedSpace.atlas.{u2, u1} H _inst_1 M _inst_2 _inst_3) (StructureGroupoid.maximalAtlas.{u2, u1} H M _inst_1 _inst_2 _inst_3 G)
Case conversion may be inaccurate. Consider using '#align structure_groupoid.subset_maximal_atlas StructureGroupoid.subset_maximalAtlasₓ'. -/
/-- The elements of the atlas belong to the maximal atlas for any structure groupoid -/
theorem StructureGroupoid.subset_maximalAtlas [HasGroupoid M G] : atlas H M ⊆ G.maximalAtlas M :=
  fun e he e' he' => ⟨G.compatible he he', G.compatible he' he⟩
#align structure_groupoid.subset_maximal_atlas StructureGroupoid.subset_maximalAtlas

/- warning: structure_groupoid.chart_mem_maximal_atlas -> StructureGroupoid.chart_mem_maximalAtlas is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] (G : StructureGroupoid.{u1} H _inst_1) [_inst_4 : HasGroupoid.{u1, u2} H _inst_1 M _inst_2 _inst_3 G] (x : M), Membership.Mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (Set.hasMem.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (ChartedSpace.chartAt.{u1, u2} H _inst_1 M _inst_2 _inst_3 x) (StructureGroupoid.maximalAtlas.{u1, u2} H M _inst_1 _inst_2 _inst_3 G)
but is expected to have type
  forall {H : Type.{u2}} {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] (G : StructureGroupoid.{u2} H _inst_1) [_inst_4 : HasGroupoid.{u2, u1} H _inst_1 M _inst_2 _inst_3 G] (x : M), Membership.mem.{max u1 u2, max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) (Set.instMembershipSet.{max u1 u2} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) (ChartedSpace.chartAt.{u2, u1} H _inst_1 M _inst_2 _inst_3 x) (StructureGroupoid.maximalAtlas.{u2, u1} H M _inst_1 _inst_2 _inst_3 G)
Case conversion may be inaccurate. Consider using '#align structure_groupoid.chart_mem_maximal_atlas StructureGroupoid.chart_mem_maximalAtlasₓ'. -/
theorem StructureGroupoid.chart_mem_maximalAtlas [HasGroupoid M G] (x : M) :
    chartAt H x ∈ G.maximalAtlas M :=
  G.subset_maximalAtlas (chart_mem_atlas H x)
#align structure_groupoid.chart_mem_maximal_atlas StructureGroupoid.chart_mem_maximalAtlas

variable {G}

/- warning: mem_maximal_atlas_iff -> mem_maximalAtlas_iff is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] {G : StructureGroupoid.{u1} H _inst_1} {e : LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1}, Iff (Membership.Mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (Set.hasMem.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) e (StructureGroupoid.maximalAtlas.{u1, u2} H M _inst_1 _inst_2 _inst_3 G)) (forall (e' : LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1), (Membership.Mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (Set.hasMem.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) e' (ChartedSpace.atlas.{u1, u2} H _inst_1 M _inst_2 _inst_3)) -> (And (Membership.Mem.{u1, u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (StructureGroupoid.{u1} H _inst_1) (StructureGroupoid.hasMem.{u1} H _inst_1) (LocalHomeomorph.trans.{u1, u2, u1} H M H _inst_1 _inst_2 _inst_1 (LocalHomeomorph.symm.{u2, u1} M H _inst_2 _inst_1 e) e') G) (Membership.Mem.{u1, u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (StructureGroupoid.{u1} H _inst_1) (StructureGroupoid.hasMem.{u1} H _inst_1) (LocalHomeomorph.trans.{u1, u2, u1} H M H _inst_1 _inst_2 _inst_1 (LocalHomeomorph.symm.{u2, u1} M H _inst_2 _inst_1 e') e) G)))
but is expected to have type
  forall {H : Type.{u2}} {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] {G : StructureGroupoid.{u2} H _inst_1} {e : LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1}, Iff (Membership.mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) (Set.instMembershipSet.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) e (StructureGroupoid.maximalAtlas.{u2, u1} H M _inst_1 _inst_2 _inst_3 G)) (forall (e' : LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1), (Membership.mem.{max u1 u2, max u1 u2} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) (Set.instMembershipSet.{max u1 u2} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) e' (ChartedSpace.atlas.{u2, u1} H _inst_1 M _inst_2 _inst_3)) -> (And (Membership.mem.{u2, u2} (LocalHomeomorph.{u2, u2} H H _inst_1 _inst_1) (StructureGroupoid.{u2} H _inst_1) (instMembershipLocalHomeomorphStructureGroupoid.{u2} H _inst_1) (LocalHomeomorph.trans.{u2, u1, u2} H M H _inst_1 _inst_2 _inst_1 (LocalHomeomorph.symm.{u1, u2} M H _inst_2 _inst_1 e) e') G) (Membership.mem.{u2, u2} (LocalHomeomorph.{u2, u2} H H _inst_1 _inst_1) (StructureGroupoid.{u2} H _inst_1) (instMembershipLocalHomeomorphStructureGroupoid.{u2} H _inst_1) (LocalHomeomorph.trans.{u2, u1, u2} H M H _inst_1 _inst_2 _inst_1 (LocalHomeomorph.symm.{u1, u2} M H _inst_2 _inst_1 e') e) G)))
Case conversion may be inaccurate. Consider using '#align mem_maximal_atlas_iff mem_maximalAtlas_iffₓ'. -/
theorem mem_maximalAtlas_iff {e : LocalHomeomorph M H} :
    e ∈ G.maximalAtlas M ↔ ∀ e' ∈ atlas H M, e.symm ≫ₕ e' ∈ G ∧ e'.symm ≫ₕ e ∈ G :=
  Iff.rfl
#align mem_maximal_atlas_iff mem_maximalAtlas_iff

/- warning: structure_groupoid.compatible_of_mem_maximal_atlas -> StructureGroupoid.compatible_of_mem_maximalAtlas is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} {M : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} H] [_inst_2 : TopologicalSpace.{u2} M] [_inst_3 : ChartedSpace.{u1, u2} H _inst_1 M _inst_2] {G : StructureGroupoid.{u1} H _inst_1} {e : LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1} {e' : LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1}, (Membership.Mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (Set.hasMem.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) e (StructureGroupoid.maximalAtlas.{u1, u2} H M _inst_1 _inst_2 _inst_3 G)) -> (Membership.Mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) (Set.hasMem.{max u2 u1} (LocalHomeomorph.{u2, u1} M H _inst_2 _inst_1)) e' (StructureGroupoid.maximalAtlas.{u1, u2} H M _inst_1 _inst_2 _inst_3 G)) -> (Membership.Mem.{u1, u1} (LocalHomeomorph.{u1, u1} H H _inst_1 _inst_1) (StructureGroupoid.{u1} H _inst_1) (StructureGroupoid.hasMem.{u1} H _inst_1) (LocalHomeomorph.trans.{u1, u2, u1} H M H _inst_1 _inst_2 _inst_1 (LocalHomeomorph.symm.{u2, u1} M H _inst_2 _inst_1 e) e') G)
but is expected to have type
  forall {H : Type.{u2}} {M : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} H] [_inst_2 : TopologicalSpace.{u1} M] [_inst_3 : ChartedSpace.{u2, u1} H _inst_1 M _inst_2] {G : StructureGroupoid.{u2} H _inst_1} {e : LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1} {e' : LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1}, (Membership.mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) (Set.instMembershipSet.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) e (StructureGroupoid.maximalAtlas.{u2, u1} H M _inst_1 _inst_2 _inst_3 G)) -> (Membership.mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) (Set.instMembershipSet.{max u2 u1} (LocalHomeomorph.{u1, u2} M H _inst_2 _inst_1)) e' (StructureGroupoid.maximalAtlas.{u2, u1} H M _inst_1 _inst_2 _inst_3 G)) -> (Membership.mem.{u2, u2} (LocalHomeomorph.{u2, u2} H H _inst_1 _inst_1) (StructureGroupoid.{u2} H _inst_1) (instMembershipLocalHomeomorphStructureGroupoid.{u2} H _inst_1) (LocalHomeomorph.trans.{u2, u1, u2} H M H _inst_1 _inst_2 _inst_1 (LocalHomeomorph.symm.{u1, u2} M H _inst_2 _inst_1 e) e') G)
Case conversion may be inaccurate. Consider using '#align structure_groupoid.compatible_of_mem_maximal_atlas StructureGroupoid.compatible_of_mem_maximalAtlasₓ'. -/
/-- Changing coordinates between two elements of the maximal atlas gives rise to an element
of the structure groupoid. -/
theorem StructureGroupoid.compatible_of_mem_maximalAtlas {e e' : LocalHomeomorph M H}
    (he : e ∈ G.maximalAtlas M) (he' : e' ∈ G.maximalAtlas M) : e.symm ≫ₕ e' ∈ G :=
  by
  apply G.locality fun x hx => _
  set f := chart_at H (e.symm x) with hf
  let s := e.target ∩ e.symm ⁻¹' f.source
  have hs : IsOpen s := by
    apply e.symm.continuous_to_fun.preimage_open_of_open <;> apply open_source
  have xs : x ∈ s := by
    dsimp at hx
    simp [s, hx]
  refine' ⟨s, hs, xs, _⟩
  have A : e.symm ≫ₕ f ∈ G := (mem_maximalAtlas_iff.1 he f (chart_mem_atlas _ _)).1
  have B : f.symm ≫ₕ e' ∈ G := (mem_maximalAtlas_iff.1 he' f (chart_mem_atlas _ _)).2
  have C : (e.symm ≫ₕ f) ≫ₕ f.symm ≫ₕ e' ∈ G := G.trans A B
  have D : (e.symm ≫ₕ f) ≫ₕ f.symm ≫ₕ e' ≈ (e.symm ≫ₕ e').restr s :=
    calc
      (e.symm ≫ₕ f) ≫ₕ f.symm ≫ₕ e' = e.symm ≫ₕ (f ≫ₕ f.symm) ≫ₕ e' := by simp [trans_assoc]
      _ ≈ e.symm ≫ₕ of_set f.source f.open_source ≫ₕ e' := by
        simp [eq_on_source.trans', trans_self_symm]
      _ ≈ (e.symm ≫ₕ of_set f.source f.open_source) ≫ₕ e' := by simp [trans_assoc]
      _ ≈ e.symm.restr s ≫ₕ e' := by simp [s, trans_of_set']
      _ ≈ (e.symm ≫ₕ e').restr s := by simp [restr_trans]
      
  exact G.eq_on_source C (Setoid.symm D)
#align structure_groupoid.compatible_of_mem_maximal_atlas StructureGroupoid.compatible_of_mem_maximalAtlas

variable (G)

#print StructureGroupoid.id_mem_maximalAtlas /-
/-- In the model space, the identity is in any maximal atlas. -/
theorem StructureGroupoid.id_mem_maximalAtlas : LocalHomeomorph.refl H ∈ G.maximalAtlas H :=
  G.subset_maximalAtlas <| by simp
#align structure_groupoid.id_mem_maximal_atlas StructureGroupoid.id_mem_maximalAtlas
-/

#print StructureGroupoid.mem_maximalAtlas_of_mem_groupoid /-
/-- In the model space, any element of the groupoid is in the maximal atlas. -/
theorem StructureGroupoid.mem_maximalAtlas_of_mem_groupoid {f : LocalHomeomorph H H} (hf : f ∈ G) :
    f ∈ G.maximalAtlas H := by
  rintro e (rfl : e = LocalHomeomorph.refl H)
  exact ⟨G.trans (G.symm hf) G.id_mem, G.trans (G.symm G.id_mem) hf⟩
#align structure_groupoid.mem_maximal_atlas_of_mem_groupoid StructureGroupoid.mem_maximalAtlas_of_mem_groupoid
-/

end MaximalAtlas

section Singleton

variable {α : Type _} [TopologicalSpace α]

namespace LocalHomeomorph

variable (e : LocalHomeomorph α H)

#print LocalHomeomorph.singletonChartedSpace /-
/-- If a single local homeomorphism `e` from a space `α` into `H` has source covering the whole
space `α`, then that local homeomorphism induces an `H`-charted space structure on `α`.
(This condition is equivalent to `e` being an open embedding of `α` into `H`; see
`open_embedding.singleton_charted_space`.) -/
def singletonChartedSpace (h : e.source = Set.univ) : ChartedSpace H α
    where
  atlas := {e}
  chartAt _ := e
  mem_chart_source _ := by simp only [h, mfld_simps]
  chart_mem_atlas _ := by tauto
#align local_homeomorph.singleton_charted_space LocalHomeomorph.singletonChartedSpace
-/

/- warning: local_homeomorph.singleton_charted_space_chart_at_eq -> LocalHomeomorph.singletonChartedSpace_chartAt_eq is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} H] {α : Type.{u2}} [_inst_4 : TopologicalSpace.{u2} α] (e : LocalHomeomorph.{u2, u1} α H _inst_4 _inst_1) (h : Eq.{succ u2} (Set.{u2} α) (LocalEquiv.source.{u2, u1} α H (LocalHomeomorph.toLocalEquiv.{u2, u1} α H _inst_4 _inst_1 e)) (Set.univ.{u2} α)) {x : α}, Eq.{max (succ u2) (succ u1)} (LocalHomeomorph.{u2, u1} α H _inst_4 _inst_1) (ChartedSpace.chartAt.{u1, u2} H _inst_1 α _inst_4 (LocalHomeomorph.singletonChartedSpace.{u1, u2} H _inst_1 α _inst_4 e h) x) e
but is expected to have type
  forall {H : Type.{u2}} [_inst_1 : TopologicalSpace.{u2} H] {α : Type.{u1}} [_inst_4 : TopologicalSpace.{u1} α] (e : LocalHomeomorph.{u1, u2} α H _inst_4 _inst_1) (h : Eq.{succ u1} (Set.{u1} α) (LocalEquiv.source.{u1, u2} α H (LocalHomeomorph.toLocalEquiv.{u1, u2} α H _inst_4 _inst_1 e)) (Set.univ.{u1} α)) {x : α}, Eq.{max (succ u2) (succ u1)} (LocalHomeomorph.{u1, u2} α H _inst_4 _inst_1) (ChartedSpace.chartAt.{u2, u1} H _inst_1 α _inst_4 (LocalHomeomorph.singletonChartedSpace.{u2, u1} H _inst_1 α _inst_4 e h) x) e
Case conversion may be inaccurate. Consider using '#align local_homeomorph.singleton_charted_space_chart_at_eq LocalHomeomorph.singletonChartedSpace_chartAt_eqₓ'. -/
@[simp, mfld_simps]
theorem singletonChartedSpace_chartAt_eq (h : e.source = Set.univ) {x : α} :
    @chartAt H _ α _ (e.singletonChartedSpace h) x = e :=
  rfl
#align local_homeomorph.singleton_charted_space_chart_at_eq LocalHomeomorph.singletonChartedSpace_chartAt_eq

/- warning: local_homeomorph.singleton_charted_space_chart_at_source -> LocalHomeomorph.singletonChartedSpace_chartAt_source is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} H] {α : Type.{u2}} [_inst_4 : TopologicalSpace.{u2} α] (e : LocalHomeomorph.{u2, u1} α H _inst_4 _inst_1) (h : Eq.{succ u2} (Set.{u2} α) (LocalEquiv.source.{u2, u1} α H (LocalHomeomorph.toLocalEquiv.{u2, u1} α H _inst_4 _inst_1 e)) (Set.univ.{u2} α)) {x : α}, Eq.{succ u2} (Set.{u2} α) (LocalEquiv.source.{u2, u1} α H (LocalHomeomorph.toLocalEquiv.{u2, u1} α H _inst_4 _inst_1 (ChartedSpace.chartAt.{u1, u2} H _inst_1 α _inst_4 (LocalHomeomorph.singletonChartedSpace.{u1, u2} H _inst_1 α _inst_4 e h) x))) (Set.univ.{u2} α)
but is expected to have type
  forall {H : Type.{u2}} [_inst_1 : TopologicalSpace.{u2} H] {α : Type.{u1}} [_inst_4 : TopologicalSpace.{u1} α] (e : LocalHomeomorph.{u1, u2} α H _inst_4 _inst_1) (h : Eq.{succ u1} (Set.{u1} α) (LocalEquiv.source.{u1, u2} α H (LocalHomeomorph.toLocalEquiv.{u1, u2} α H _inst_4 _inst_1 e)) (Set.univ.{u1} α)) {x : α}, Eq.{succ u1} (Set.{u1} α) (LocalEquiv.source.{u1, u2} α H (LocalHomeomorph.toLocalEquiv.{u1, u2} α H _inst_4 _inst_1 (ChartedSpace.chartAt.{u2, u1} H _inst_1 α _inst_4 (LocalHomeomorph.singletonChartedSpace.{u2, u1} H _inst_1 α _inst_4 e h) x))) (Set.univ.{u1} α)
Case conversion may be inaccurate. Consider using '#align local_homeomorph.singleton_charted_space_chart_at_source LocalHomeomorph.singletonChartedSpace_chartAt_sourceₓ'. -/
theorem singletonChartedSpace_chartAt_source (h : e.source = Set.univ) {x : α} :
    (@chartAt H _ α _ (e.singletonChartedSpace h) x).source = Set.univ :=
  h
#align local_homeomorph.singleton_charted_space_chart_at_source LocalHomeomorph.singletonChartedSpace_chartAt_source

/- warning: local_homeomorph.singleton_charted_space_mem_atlas_eq -> LocalHomeomorph.singletonChartedSpace_mem_atlas_eq is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} H] {α : Type.{u2}} [_inst_4 : TopologicalSpace.{u2} α] (e : LocalHomeomorph.{u2, u1} α H _inst_4 _inst_1) (h : Eq.{succ u2} (Set.{u2} α) (LocalEquiv.source.{u2, u1} α H (LocalHomeomorph.toLocalEquiv.{u2, u1} α H _inst_4 _inst_1 e)) (Set.univ.{u2} α)) (e' : LocalHomeomorph.{u2, u1} α H _inst_4 _inst_1), (Membership.Mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u2, u1} α H _inst_4 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u2, u1} α H _inst_4 _inst_1)) (Set.hasMem.{max u2 u1} (LocalHomeomorph.{u2, u1} α H _inst_4 _inst_1)) e' (ChartedSpace.atlas.{u1, u2} H _inst_1 α _inst_4 (LocalHomeomorph.singletonChartedSpace.{u1, u2} H _inst_1 α _inst_4 e h))) -> (Eq.{max (succ u2) (succ u1)} (LocalHomeomorph.{u2, u1} α H _inst_4 _inst_1) e' e)
but is expected to have type
  forall {H : Type.{u2}} [_inst_1 : TopologicalSpace.{u2} H] {α : Type.{u1}} [_inst_4 : TopologicalSpace.{u1} α] (e : LocalHomeomorph.{u1, u2} α H _inst_4 _inst_1) (h : Eq.{succ u1} (Set.{u1} α) (LocalEquiv.source.{u1, u2} α H (LocalHomeomorph.toLocalEquiv.{u1, u2} α H _inst_4 _inst_1 e)) (Set.univ.{u1} α)) (e' : LocalHomeomorph.{u1, u2} α H _inst_4 _inst_1), (Membership.mem.{max u2 u1, max u2 u1} (LocalHomeomorph.{u1, u2} α H _inst_4 _inst_1) (Set.{max u2 u1} (LocalHomeomorph.{u1, u2} α H _inst_4 _inst_1)) (Set.instMembershipSet.{max u2 u1} (LocalHomeomorph.{u1, u2} α H _inst_4 _inst_1)) e' (ChartedSpace.atlas.{u2, u1} H _inst_1 α _inst_4 (LocalHomeomorph.singletonChartedSpace.{u2, u1} H _inst_1 α _inst_4 e h))) -> (Eq.{max (succ u2) (succ u1)} (LocalHomeomorph.{u1, u2} α H _inst_4 _inst_1) e' e)
Case conversion may be inaccurate. Consider using '#align local_homeomorph.singleton_charted_space_mem_atlas_eq LocalHomeomorph.singletonChartedSpace_mem_atlas_eqₓ'. -/
theorem singletonChartedSpace_mem_atlas_eq (h : e.source = Set.univ) (e' : LocalHomeomorph α H)
    (h' : e' ∈ (e.singletonChartedSpace h).atlas) : e' = e :=
  h'
#align local_homeomorph.singleton_charted_space_mem_atlas_eq LocalHomeomorph.singletonChartedSpace_mem_atlas_eq

/- warning: local_homeomorph.singleton_has_groupoid -> LocalHomeomorph.singleton_hasGroupoid is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} H] {α : Type.{u2}} [_inst_4 : TopologicalSpace.{u2} α] (e : LocalHomeomorph.{u2, u1} α H _inst_4 _inst_1) (h : Eq.{succ u2} (Set.{u2} α) (LocalEquiv.source.{u2, u1} α H (LocalHomeomorph.toLocalEquiv.{u2, u1} α H _inst_4 _inst_1 e)) (Set.univ.{u2} α)) (G : StructureGroupoid.{u1} H _inst_1) [_inst_5 : ClosedUnderRestriction.{u1} H _inst_1 G], HasGroupoid.{u1, u2} H _inst_1 α _inst_4 (LocalHomeomorph.singletonChartedSpace.{u1, u2} H _inst_1 α _inst_4 e h) G
but is expected to have type
  forall {H : Type.{u2}} [_inst_1 : TopologicalSpace.{u2} H] {α : Type.{u1}} [_inst_4 : TopologicalSpace.{u1} α] (e : LocalHomeomorph.{u1, u2} α H _inst_4 _inst_1) (h : Eq.{succ u1} (Set.{u1} α) (LocalEquiv.source.{u1, u2} α H (LocalHomeomorph.toLocalEquiv.{u1, u2} α H _inst_4 _inst_1 e)) (Set.univ.{u1} α)) (G : StructureGroupoid.{u2} H _inst_1) [_inst_5 : ClosedUnderRestriction.{u2} H _inst_1 G], HasGroupoid.{u2, u1} H _inst_1 α _inst_4 (LocalHomeomorph.singletonChartedSpace.{u2, u1} H _inst_1 α _inst_4 e h) G
Case conversion may be inaccurate. Consider using '#align local_homeomorph.singleton_has_groupoid LocalHomeomorph.singleton_hasGroupoidₓ'. -/
/-- Given a local homeomorphism `e` from a space `α` into `H`, if its source covers the whole
space `α`, then the induced charted space structure on `α` is `has_groupoid G` for any structure
groupoid `G` which is closed under restrictions. -/
theorem singleton_hasGroupoid (h : e.source = Set.univ) (G : StructureGroupoid H)
    [ClosedUnderRestriction G] : @HasGroupoid _ _ _ _ (e.singletonChartedSpace h) G :=
  {
    compatible := by
      intro e' e'' he' he''
      rw [e.singleton_charted_space_mem_atlas_eq h e' he']
      rw [e.singleton_charted_space_mem_atlas_eq h e'' he'']
      refine' G.eq_on_source _ e.trans_symm_self
      have hle : idRestrGroupoid ≤ G := (closedUnderRestriction_iff_id_le G).mp (by assumption)
      exact structure_groupoid.le_iff.mp hle _ (idRestrGroupoid_mem _) }
#align local_homeomorph.singleton_has_groupoid LocalHomeomorph.singleton_hasGroupoid

end LocalHomeomorph

namespace OpenEmbedding

variable [Nonempty α]

#print OpenEmbedding.singletonChartedSpace /-
/-- An open embedding of `α` into `H` induces an `H`-charted space structure on `α`.
See `local_homeomorph.singleton_charted_space` -/
def singletonChartedSpace {f : α → H} (h : OpenEmbedding f) : ChartedSpace H α :=
  (h.toLocalHomeomorph f).singletonChartedSpace (by simp)
#align open_embedding.singleton_charted_space OpenEmbedding.singletonChartedSpace
-/

/- warning: open_embedding.singleton_charted_space_chart_at_eq -> OpenEmbedding.singletonChartedSpace_chartAt_eq is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} H] {α : Type.{u2}} [_inst_4 : TopologicalSpace.{u2} α] [_inst_5 : Nonempty.{succ u2} α] {f : α -> H} (h : OpenEmbedding.{u2, u1} α H _inst_4 _inst_1 f) {x : α}, Eq.{max (succ u2) (succ u1)} (α -> H) (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (LocalHomeomorph.{u2, u1} α H _inst_4 _inst_1) (fun (_x : LocalHomeomorph.{u2, u1} α H _inst_4 _inst_1) => α -> H) (LocalHomeomorph.hasCoeToFun.{u2, u1} α H _inst_4 _inst_1) (ChartedSpace.chartAt.{u1, u2} H _inst_1 α _inst_4 (OpenEmbedding.singletonChartedSpace.{u1, u2} H _inst_1 α _inst_4 _inst_5 f h) x)) f
but is expected to have type
  forall {H : Type.{u2}} [_inst_1 : TopologicalSpace.{u2} H] {α : Type.{u1}} [_inst_4 : TopologicalSpace.{u1} α] [_inst_5 : Nonempty.{succ u1} α] {f : α -> H} (h : OpenEmbedding.{u1, u2} α H _inst_4 _inst_1 f) {x : α}, Eq.{max (succ u2) (succ u1)} (α -> H) (LocalHomeomorph.toFun'.{u1, u2} α H _inst_4 _inst_1 (ChartedSpace.chartAt.{u2, u1} H _inst_1 α _inst_4 (OpenEmbedding.singletonChartedSpace.{u2, u1} H _inst_1 α _inst_4 _inst_5 f h) x)) f
Case conversion may be inaccurate. Consider using '#align open_embedding.singleton_charted_space_chart_at_eq OpenEmbedding.singletonChartedSpace_chartAt_eqₓ'. -/
theorem singletonChartedSpace_chartAt_eq {f : α → H} (h : OpenEmbedding f) {x : α} :
    ⇑(@chartAt H _ α _ h.singletonChartedSpace x) = f :=
  rfl
#align open_embedding.singleton_charted_space_chart_at_eq OpenEmbedding.singletonChartedSpace_chartAt_eq

/- warning: open_embedding.singleton_has_groupoid -> OpenEmbedding.singleton_hasGroupoid is a dubious translation:
lean 3 declaration is
  forall {H : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} H] {α : Type.{u2}} [_inst_4 : TopologicalSpace.{u2} α] [_inst_5 : Nonempty.{succ u2} α] {f : α -> H} (h : OpenEmbedding.{u2, u1} α H _inst_4 _inst_1 f) (G : StructureGroupoid.{u1} H _inst_1) [_inst_6 : ClosedUnderRestriction.{u1} H _inst_1 G], HasGroupoid.{u1, u2} H _inst_1 α _inst_4 (OpenEmbedding.singletonChartedSpace.{u1, u2} H _inst_1 α _inst_4 _inst_5 f h) G
but is expected to have type
  forall {H : Type.{u2}} [_inst_1 : TopologicalSpace.{u2} H] {α : Type.{u1}} [_inst_4 : TopologicalSpace.{u1} α] [_inst_5 : Nonempty.{succ u1} α] {f : α -> H} (h : OpenEmbedding.{u1, u2} α H _inst_4 _inst_1 f) (G : StructureGroupoid.{u2} H _inst_1) [_inst_6 : ClosedUnderRestriction.{u2} H _inst_1 G], HasGroupoid.{u2, u1} H _inst_1 α _inst_4 (OpenEmbedding.singletonChartedSpace.{u2, u1} H _inst_1 α _inst_4 _inst_5 f h) G
Case conversion may be inaccurate. Consider using '#align open_embedding.singleton_has_groupoid OpenEmbedding.singleton_hasGroupoidₓ'. -/
theorem singleton_hasGroupoid {f : α → H} (h : OpenEmbedding f) (G : StructureGroupoid H)
    [ClosedUnderRestriction G] : @HasGroupoid _ _ _ _ h.singletonChartedSpace G :=
  (h.toLocalHomeomorph f).singleton_hasGroupoid (by simp) G
#align open_embedding.singleton_has_groupoid OpenEmbedding.singleton_hasGroupoid

end OpenEmbedding

end Singleton

namespace TopologicalSpace.Opens

open TopologicalSpace

variable (G : StructureGroupoid H) [HasGroupoid M G]

variable (s : Opens M)

/-- An open subset of a charted space is naturally a charted space. -/
instance : ChartedSpace H s
    where
  atlas := ⋃ x : s, {@LocalHomeomorph.subtypeRestr _ _ _ _ (chartAt H x.1) s ⟨x⟩}
  chartAt x := @LocalHomeomorph.subtypeRestr _ _ _ _ (chartAt H x.1) s ⟨x⟩
  mem_chart_source x := by
    simp only [mfld_simps]
    exact mem_chart_source H x.1
  chart_mem_atlas x := by
    simp only [mem_Union, mem_singleton_iff]
    use x

/-- If a groupoid `G` is `closed_under_restriction`, then an open subset of a space which is
`has_groupoid G` is naturally `has_groupoid G`. -/
instance [ClosedUnderRestriction G] : HasGroupoid s G
    where compatible := by
    rintro e e' ⟨_, ⟨x, hc⟩, he⟩ ⟨_, ⟨x', hc'⟩, he'⟩
    haveI : Nonempty s := ⟨x⟩
    simp only [hc.symm, mem_singleton_iff, Subtype.val_eq_coe] at he
    simp only [hc'.symm, mem_singleton_iff, Subtype.val_eq_coe] at he'
    rw [he, he']
    convert G.eq_on_source _
        (subtype_restr_symm_trans_subtype_restr s (chart_at H x) (chart_at H x'))
    apply closedUnderRestriction'
    · exact G.compatible (chart_mem_atlas H x) (chart_mem_atlas H x')
    · exact preimage_open_of_open_symm (chart_at H x) s.2

end TopologicalSpace.Opens

/-! ### Structomorphisms -/


#print Structomorph /-
/-- A `G`-diffeomorphism between two charted spaces is a homeomorphism which, when read in the
charts, belongs to `G`. We avoid the word diffeomorph as it is too related to the smooth category,
and use structomorph instead. -/
@[nolint has_nonempty_instance]
structure Structomorph (G : StructureGroupoid H) (M : Type _) (M' : Type _) [TopologicalSpace M]
  [TopologicalSpace M'] [ChartedSpace H M] [ChartedSpace H M'] extends Homeomorph M M' where
  mem_groupoid :
    ∀ c : LocalHomeomorph M H,
      ∀ c' : LocalHomeomorph M' H,
        c ∈ atlas H M → c' ∈ atlas H M' → c.symm ≫ₕ to_homeomorph.toLocalHomeomorph ≫ₕ c' ∈ G
#align structomorph Structomorph
-/

variable [TopologicalSpace M'] [TopologicalSpace M''] {G : StructureGroupoid H} [ChartedSpace H M']
  [ChartedSpace H M'']

#print Structomorph.refl /-
/-- The identity is a diffeomorphism of any charted space, for any groupoid. -/
def Structomorph.refl (M : Type _) [TopologicalSpace M] [ChartedSpace H M] [HasGroupoid M G] :
    Structomorph G M M :=
  { Homeomorph.refl M with
    mem_groupoid := fun c c' hc hc' =>
      by
      change LocalHomeomorph.symm c ≫ₕ LocalHomeomorph.refl M ≫ₕ c' ∈ G
      rw [LocalHomeomorph.refl_trans]
      exact HasGroupoid.compatible G hc hc' }
#align structomorph.refl Structomorph.refl
-/

#print Structomorph.symm /-
/-- The inverse of a structomorphism is a structomorphism -/
def Structomorph.symm (e : Structomorph G M M') : Structomorph G M' M :=
  { e.toHomeomorph.symm with
    mem_groupoid := by
      intro c c' hc hc'
      have : (c'.symm ≫ₕ e.to_homeomorph.to_local_homeomorph ≫ₕ c).symm ∈ G :=
        G.symm (e.mem_groupoid c' c hc' hc)
      rwa [trans_symm_eq_symm_trans_symm, trans_symm_eq_symm_trans_symm, symm_symm, trans_assoc] at
        this }
#align structomorph.symm Structomorph.symm
-/

#print Structomorph.trans /-
/-- The composition of structomorphisms is a structomorphism -/
def Structomorph.trans (e : Structomorph G M M') (e' : Structomorph G M' M'') :
    Structomorph G M M'' :=
  {/- Let c and c' be two charts in M and M''. We want to show that e' ∘ e is smooth in these
          charts, around any point x. For this, let y = e (c⁻¹ x), and consider a chart g around y.
          Then g ∘ e ∘ c⁻¹ and c' ∘ e' ∘ g⁻¹ are both smooth as e and e' are structomorphisms, so
          their composition is smooth, and it coincides with c' ∘ e' ∘ e ∘ c⁻¹ around x. -/
      -- define the atlas g around y
      Homeomorph.trans
      e.toHomeomorph e'.toHomeomorph with
    mem_groupoid := by
      intro c c' hc hc'
      refine' G.locality fun x hx => _
      let f₁ := e.to_homeomorph.to_local_homeomorph
      let f₂ := e'.to_homeomorph.to_local_homeomorph
      let f := (e.to_homeomorph.trans e'.to_homeomorph).toLocalHomeomorph
      have feq : f = f₁ ≫ₕ f₂ := Homeomorph.trans_toLocalHomeomorph _ _
      let y := (c.symm ≫ₕ f₁) x
      let g := chart_at H y
      have hg₁ := chart_mem_atlas H y
      have hg₂ := mem_chart_source H y
      let s := (c.symm ≫ₕ f₁).source ∩ c.symm ≫ₕ f₁ ⁻¹' g.source
      have open_s : IsOpen s := by
        apply (c.symm ≫ₕ f₁).continuous_toFun.preimage_open_of_open <;> apply open_source
      have : x ∈ s := by
        constructor
        · simp only [trans_source, preimage_univ, inter_univ, Homeomorph.toLocalHomeomorph_source]
          rw [trans_source] at hx
          exact hx.1
        · exact hg₂
      refine' ⟨s, open_s, this, _⟩
      let F₁ := (c.symm ≫ₕ f₁ ≫ₕ g) ≫ₕ g.symm ≫ₕ f₂ ≫ₕ c'
      have A : F₁ ∈ G := G.trans (e.mem_groupoid c g hc hg₁) (e'.mem_groupoid g c' hg₁ hc')
      let F₂ := (c.symm ≫ₕ f ≫ₕ c').restr s
      have : F₁ ≈ F₂ :=
        calc
          F₁ ≈ c.symm ≫ₕ f₁ ≫ₕ (g ≫ₕ g.symm) ≫ₕ f₂ ≫ₕ c' := by simp [F₁, trans_assoc]
          _ ≈ c.symm ≫ₕ f₁ ≫ₕ of_set g.source g.open_source ≫ₕ f₂ ≫ₕ c' := by
            simp [eq_on_source.trans', trans_self_symm g]
          _ ≈ ((c.symm ≫ₕ f₁) ≫ₕ of_set g.source g.open_source) ≫ₕ f₂ ≫ₕ c' := by simp [trans_assoc]
          _ ≈ (c.symm ≫ₕ f₁).restr s ≫ₕ f₂ ≫ₕ c' := by simp [s, trans_of_set']
          _ ≈ ((c.symm ≫ₕ f₁) ≫ₕ f₂ ≫ₕ c').restr s := by simp [restr_trans]
          _ ≈ (c.symm ≫ₕ (f₁ ≫ₕ f₂) ≫ₕ c').restr s := by simp [eq_on_source.restr, trans_assoc]
          _ ≈ F₂ := by simp [F₂, feq]
          
      have : F₂ ∈ G := G.eq_on_source A (Setoid.symm this)
      exact this }
#align structomorph.trans Structomorph.trans
-/

end HasGroupoid

