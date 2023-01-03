/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro, Patrick Massot

! This file was ported from Lean 3 source module topology.maps
! leanprover-community/mathlib commit 9830a300340708eaa85d477c3fb96dd25f9468a5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Order
import Mathbin.Topology.NhdsSet

/-!
# Specific classes of maps between topological spaces

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

open TopologicalSpace Filter

variable {α : Type _} {β : Type _} {γ : Type _} {δ : Type _}

section Inducing

/-- A function `f : α → β` between topological spaces is inducing if the topology on `α` is induced
by the topology on `β` through `f`, meaning that a set `s : set α` is open iff it is the preimage
under `f` of some open set `t : set β`. -/
@[mk_iff]
structure Inducing [tα : TopologicalSpace α] [tβ : TopologicalSpace β] (f : α → β) : Prop where
  induced : tα = tβ.induced f
#align inducing Inducing

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ] [TopologicalSpace δ]

theorem inducing_id : Inducing (@id α) :=
  ⟨induced_id.symm⟩
#align inducing_id inducing_id

protected theorem Inducing.comp {g : β → γ} {f : α → β} (hg : Inducing g) (hf : Inducing f) :
    Inducing (g ∘ f) :=
  ⟨by rw [hf.induced, hg.induced, induced_compose]⟩
#align inducing.comp Inducing.comp

theorem inducing_of_inducing_compose {f : α → β} {g : β → γ} (hf : Continuous f) (hg : Continuous g)
    (hgf : Inducing (g ∘ f)) : Inducing f :=
  ⟨le_antisymm (by rwa [← continuous_iff_le_induced])
      (by
        rw [hgf.induced, ← continuous_iff_le_induced]
        apply hg.comp continuous_induced_dom)⟩
#align inducing_of_inducing_compose inducing_of_inducing_compose

theorem inducing_iff_nhds {f : α → β} : Inducing f ↔ ∀ a, 𝓝 a = comap f (𝓝 (f a)) :=
  (inducing_iff _).trans (induced_iff_nhds_eq f)
#align inducing_iff_nhds inducing_iff_nhds

theorem Inducing.nhds_eq_comap {f : α → β} (hf : Inducing f) : ∀ a : α, 𝓝 a = comap f (𝓝 <| f a) :=
  inducing_iff_nhds.1 hf
#align inducing.nhds_eq_comap Inducing.nhds_eq_comap

theorem Inducing.nhds_set_eq_comap {f : α → β} (hf : Inducing f) (s : Set α) :
    𝓝ˢ s = comap f (𝓝ˢ (f '' s)) := by
  simp only [nhdsSet, supₛ_image, comap_supr, hf.nhds_eq_comap, supᵢ_image]
#align inducing.nhds_set_eq_comap Inducing.nhds_set_eq_comap

theorem Inducing.map_nhds_eq {f : α → β} (hf : Inducing f) (a : α) : (𝓝 a).map f = 𝓝[range f] f a :=
  hf.induced.symm ▸ map_nhds_induced_eq a
#align inducing.map_nhds_eq Inducing.map_nhds_eq

theorem Inducing.map_nhds_of_mem {f : α → β} (hf : Inducing f) (a : α) (h : range f ∈ 𝓝 (f a)) :
    (𝓝 a).map f = 𝓝 (f a) :=
  hf.induced.symm ▸ map_nhds_induced_of_mem h
#align inducing.map_nhds_of_mem Inducing.map_nhds_of_mem

theorem Inducing.image_mem_nhds_within {f : α → β} (hf : Inducing f) {a : α} {s : Set α}
    (hs : s ∈ 𝓝 a) : f '' s ∈ 𝓝[range f] f a :=
  hf.map_nhds_eq a ▸ image_mem_map hs
#align inducing.image_mem_nhds_within Inducing.image_mem_nhds_within

theorem Inducing.tendsto_nhds_iff {ι : Type _} {f : ι → β} {g : β → γ} {a : Filter ι} {b : β}
    (hg : Inducing g) : Tendsto f a (𝓝 b) ↔ Tendsto (g ∘ f) a (𝓝 (g b)) := by
  rw [hg.nhds_eq_comap, tendsto_comap_iff]
#align inducing.tendsto_nhds_iff Inducing.tendsto_nhds_iff

theorem Inducing.continuous_at_iff {f : α → β} {g : β → γ} (hg : Inducing g) {x : α} :
    ContinuousAt f x ↔ ContinuousAt (g ∘ f) x := by
  simp_rw [ContinuousAt, Inducing.tendsto_nhds_iff hg]
#align inducing.continuous_at_iff Inducing.continuous_at_iff

theorem Inducing.continuous_iff {f : α → β} {g : β → γ} (hg : Inducing g) :
    Continuous f ↔ Continuous (g ∘ f) := by
  simp_rw [continuous_iff_continuous_at, hg.continuous_at_iff]
#align inducing.continuous_iff Inducing.continuous_iff

theorem Inducing.continuous_at_iff' {f : α → β} {g : β → γ} (hf : Inducing f) {x : α}
    (h : range f ∈ 𝓝 (f x)) : ContinuousAt (g ∘ f) x ↔ ContinuousAt g (f x) := by
  simp_rw [ContinuousAt, Filter.Tendsto, ← hf.map_nhds_of_mem _ h, Filter.map_map]
#align inducing.continuous_at_iff' Inducing.continuous_at_iff'

protected theorem Inducing.continuous {f : α → β} (hf : Inducing f) : Continuous f :=
  hf.continuous_iff.mp continuous_id
#align inducing.continuous Inducing.continuous

protected theorem Inducing.inducing_iff {f : α → β} {g : β → γ} (hg : Inducing g) :
    Inducing f ↔ Inducing (g ∘ f) :=
  by
  refine' ⟨fun h => hg.comp h, fun hgf => inducing_of_inducing_compose _ hg.continuous hgf⟩
  rw [hg.continuous_iff]
  exact hgf.continuous
#align inducing.inducing_iff Inducing.inducing_iff

theorem Inducing.closure_eq_preimage_closure_image {f : α → β} (hf : Inducing f) (s : Set α) :
    closure s = f ⁻¹' closure (f '' s) := by
  ext x
  rw [Set.mem_preimage, ← closure_induced, hf.induced]
#align inducing.closure_eq_preimage_closure_image Inducing.closure_eq_preimage_closure_image

theorem Inducing.is_closed_iff {f : α → β} (hf : Inducing f) {s : Set α} :
    IsClosed s ↔ ∃ t, IsClosed t ∧ f ⁻¹' t = s := by rw [hf.induced, is_closed_induced_iff]
#align inducing.is_closed_iff Inducing.is_closed_iff

theorem Inducing.is_closed_iff' {f : α → β} (hf : Inducing f) {s : Set α} :
    IsClosed s ↔ ∀ x, f x ∈ closure (f '' s) → x ∈ s := by rw [hf.induced, is_closed_induced_iff']
#align inducing.is_closed_iff' Inducing.is_closed_iff'

theorem Inducing.is_closed_preimage {f : α → β} (h : Inducing f) (s : Set β) (hs : IsClosed s) :
    IsClosed (f ⁻¹' s) :=
  (Inducing.is_closed_iff h).mpr ⟨s, hs, rfl⟩
#align inducing.is_closed_preimage Inducing.is_closed_preimage

theorem Inducing.is_open_iff {f : α → β} (hf : Inducing f) {s : Set α} :
    IsOpen s ↔ ∃ t, IsOpen t ∧ f ⁻¹' t = s := by rw [hf.induced, is_open_induced_iff]
#align inducing.is_open_iff Inducing.is_open_iff

theorem Inducing.dense_iff {f : α → β} (hf : Inducing f) {s : Set α} :
    Dense s ↔ ∀ x, f x ∈ closure (f '' s) := by
  simp only [Dense, hf.closure_eq_preimage_closure_image, mem_preimage]
#align inducing.dense_iff Inducing.dense_iff

end Inducing

section Embedding

/-- A function between topological spaces is an embedding if it is injective,
  and for all `s : set α`, `s` is open iff it is the preimage of an open set. -/
@[mk_iff]
structure Embedding [tα : TopologicalSpace α] [tβ : TopologicalSpace β] (f : α → β) extends
  Inducing f : Prop where
  inj : Injective f
#align embedding Embedding

theorem Function.Injective.embedding_induced [t : TopologicalSpace β] {f : α → β}
    (hf : Injective f) : @Embedding α β (t.induced f) t f :=
  { induced := rfl
    inj := hf }
#align function.injective.embedding_induced Function.Injective.embedding_induced

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ]

theorem Embedding.mk' (f : α → β) (inj : Injective f) (induced : ∀ a, comap f (𝓝 (f a)) = 𝓝 a) :
    Embedding f :=
  ⟨inducing_iff_nhds.2 fun a => (induced a).symm, inj⟩
#align embedding.mk' Embedding.mk'

theorem embedding_id : Embedding (@id α) :=
  ⟨inducing_id, fun a₁ a₂ h => h⟩
#align embedding_id embedding_id

theorem Embedding.comp {g : β → γ} {f : α → β} (hg : Embedding g) (hf : Embedding f) :
    Embedding (g ∘ f) :=
  { hg.to_inducing.comp hf.to_inducing with inj := fun a₁ a₂ h => hf.inj <| hg.inj h }
#align embedding.comp Embedding.comp

theorem embedding_of_embedding_compose {f : α → β} {g : β → γ} (hf : Continuous f)
    (hg : Continuous g) (hgf : Embedding (g ∘ f)) : Embedding f :=
  { induced := (inducing_of_inducing_compose hf hg hgf.to_inducing).induced
    inj := fun a₁ a₂ h => hgf.inj <| by simp [h, (· ∘ ·)] }
#align embedding_of_embedding_compose embedding_of_embedding_compose

protected theorem Function.LeftInverse.embedding {f : α → β} {g : β → α} (h : LeftInverse f g)
    (hf : Continuous f) (hg : Continuous g) : Embedding g :=
  embedding_of_embedding_compose hg hf <| h.comp_eq_id.symm ▸ embedding_id
#align function.left_inverse.embedding Function.LeftInverse.embedding

theorem Embedding.map_nhds_eq {f : α → β} (hf : Embedding f) (a : α) :
    (𝓝 a).map f = 𝓝[range f] f a :=
  hf.1.map_nhds_eq a
#align embedding.map_nhds_eq Embedding.map_nhds_eq

theorem Embedding.map_nhds_of_mem {f : α → β} (hf : Embedding f) (a : α) (h : range f ∈ 𝓝 (f a)) :
    (𝓝 a).map f = 𝓝 (f a) :=
  hf.1.map_nhds_of_mem a h
#align embedding.map_nhds_of_mem Embedding.map_nhds_of_mem

theorem Embedding.tendsto_nhds_iff {ι : Type _} {f : ι → β} {g : β → γ} {a : Filter ι} {b : β}
    (hg : Embedding g) : Tendsto f a (𝓝 b) ↔ Tendsto (g ∘ f) a (𝓝 (g b)) :=
  hg.to_inducing.tendsto_nhds_iff
#align embedding.tendsto_nhds_iff Embedding.tendsto_nhds_iff

theorem Embedding.continuous_iff {f : α → β} {g : β → γ} (hg : Embedding g) :
    Continuous f ↔ Continuous (g ∘ f) :=
  Inducing.continuous_iff hg.1
#align embedding.continuous_iff Embedding.continuous_iff

theorem Embedding.continuous {f : α → β} (hf : Embedding f) : Continuous f :=
  Inducing.continuous hf.1
#align embedding.continuous Embedding.continuous

theorem Embedding.closure_eq_preimage_closure_image {e : α → β} (he : Embedding e) (s : Set α) :
    closure s = e ⁻¹' closure (e '' s) :=
  he.1.closure_eq_preimage_closure_image s
#align embedding.closure_eq_preimage_closure_image Embedding.closure_eq_preimage_closure_image

end Embedding

/-- A function between topological spaces is a quotient map if it is surjective,
  and for all `s : set β`, `s` is open iff its preimage is an open set. -/
def QuotientMap {α : Type _} {β : Type _} [tα : TopologicalSpace α] [tβ : TopologicalSpace β]
    (f : α → β) : Prop :=
  Surjective f ∧ tβ = tα.coinduced f
#align quotient_map QuotientMap

theorem quotient_map_iff {α β : Type _} [TopologicalSpace α] [TopologicalSpace β] {f : α → β} :
    QuotientMap f ↔ Surjective f ∧ ∀ s : Set β, IsOpen s ↔ IsOpen (f ⁻¹' s) :=
  and_congr Iff.rfl topological_space_eq_iff
#align quotient_map_iff quotient_map_iff

namespace QuotientMap

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ] [TopologicalSpace δ]
  {g : β → γ} {f : α → β}

protected theorem id : QuotientMap (@id α) :=
  ⟨fun a => ⟨a, rfl⟩, coinduced_id.symm⟩
#align quotient_map.id QuotientMap.id

protected theorem comp (hg : QuotientMap g) (hf : QuotientMap f) : QuotientMap (g ∘ f) :=
  ⟨hg.left.comp hf.left, by rw [hg.right, hf.right, coinduced_compose]⟩
#align quotient_map.comp QuotientMap.comp

protected theorem of_quotient_map_compose (hf : Continuous f) (hg : Continuous g)
    (hgf : QuotientMap (g ∘ f)) : QuotientMap g :=
  ⟨hgf.1.of_comp,
    le_antisymm
      (by
        rw [hgf.right, ← continuous_iff_coinduced_le]
        apply continuous_coinduced_rng.comp hf)
      (by rwa [← continuous_iff_coinduced_le])⟩
#align quotient_map.of_quotient_map_compose QuotientMap.of_quotient_map_compose

theorem of_inverse {g : β → α} (hf : Continuous f) (hg : Continuous g) (h : LeftInverse g f) :
    QuotientMap g :=
  QuotientMap.of_quotient_map_compose hf hg <| h.comp_eq_id.symm ▸ QuotientMap.id
#align quotient_map.of_inverse QuotientMap.of_inverse

protected theorem continuous_iff (hf : QuotientMap f) : Continuous g ↔ Continuous (g ∘ f) := by
  rw [continuous_iff_coinduced_le, continuous_iff_coinduced_le, hf.right, coinduced_compose]
#align quotient_map.continuous_iff QuotientMap.continuous_iff

protected theorem continuous (hf : QuotientMap f) : Continuous f :=
  hf.continuous_iff.mp continuous_id
#align quotient_map.continuous QuotientMap.continuous

protected theorem surjective (hf : QuotientMap f) : Surjective f :=
  hf.1
#align quotient_map.surjective QuotientMap.surjective

protected theorem is_open_preimage (hf : QuotientMap f) {s : Set β} : IsOpen (f ⁻¹' s) ↔ IsOpen s :=
  ((quotient_map_iff.1 hf).2 s).symm
#align quotient_map.is_open_preimage QuotientMap.is_open_preimage

protected theorem is_closed_preimage (hf : QuotientMap f) {s : Set β} :
    IsClosed (f ⁻¹' s) ↔ IsClosed s := by
  simp only [← is_open_compl_iff, ← preimage_compl, hf.is_open_preimage]
#align quotient_map.is_closed_preimage QuotientMap.is_closed_preimage

end QuotientMap

/-- A map `f : α → β` is said to be an *open map*, if the image of any open `U : set α`
is open in `β`. -/
def IsOpenMap [TopologicalSpace α] [TopologicalSpace β] (f : α → β) :=
  ∀ U : Set α, IsOpen U → IsOpen (f '' U)
#align is_open_map IsOpenMap

namespace IsOpenMap

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ] {f : α → β}

protected theorem id : IsOpenMap (@id α) := fun s hs => by rwa [image_id]
#align is_open_map.id IsOpenMap.id

protected theorem comp {g : β → γ} {f : α → β} (hg : IsOpenMap g) (hf : IsOpenMap f) :
    IsOpenMap (g ∘ f) := by intro s hs <;> rw [image_comp] <;> exact hg _ (hf _ hs)
#align is_open_map.comp IsOpenMap.comp

theorem is_open_range (hf : IsOpenMap f) : IsOpen (range f) :=
  by
  rw [← image_univ]
  exact hf _ is_open_univ
#align is_open_map.is_open_range IsOpenMap.is_open_range

theorem image_mem_nhds (hf : IsOpenMap f) {x : α} {s : Set α} (hx : s ∈ 𝓝 x) : f '' s ∈ 𝓝 (f x) :=
  let ⟨t, hts, ht, hxt⟩ := mem_nhds_iff.1 hx
  mem_of_superset (IsOpen.mem_nhds (hf t ht) (mem_image_of_mem _ hxt)) (image_subset _ hts)
#align is_open_map.image_mem_nhds IsOpenMap.image_mem_nhds

theorem range_mem_nhds (hf : IsOpenMap f) (x : α) : range f ∈ 𝓝 (f x) :=
  hf.is_open_range.mem_nhds <| mem_range_self _
#align is_open_map.range_mem_nhds IsOpenMap.range_mem_nhds

theorem maps_to_interior (hf : IsOpenMap f) {s : Set α} {t : Set β} (h : MapsTo f s t) :
    MapsTo f (interior s) (interior t) :=
  mapsTo'.2 <|
    interior_maximal (h.mono interior_subset Subset.rfl).image_subset (hf _ is_open_interior)
#align is_open_map.maps_to_interior IsOpenMap.maps_to_interior

theorem image_interior_subset (hf : IsOpenMap f) (s : Set α) :
    f '' interior s ⊆ interior (f '' s) :=
  (hf.maps_to_interior (mapsTo_image f s)).image_subset
#align is_open_map.image_interior_subset IsOpenMap.image_interior_subset

theorem nhds_le (hf : IsOpenMap f) (a : α) : 𝓝 (f a) ≤ (𝓝 a).map f :=
  le_map fun s => hf.image_mem_nhds
#align is_open_map.nhds_le IsOpenMap.nhds_le

theorem of_nhds_le (hf : ∀ a, 𝓝 (f a) ≤ map f (𝓝 a)) : IsOpenMap f := fun s hs =>
  is_open_iff_mem_nhds.2 fun b ⟨a, has, hab⟩ => hab ▸ hf _ (image_mem_map <| IsOpen.mem_nhds hs has)
#align is_open_map.of_nhds_le IsOpenMap.of_nhds_le

theorem of_sections {f : α → β}
    (h : ∀ x, ∃ g : β → α, ContinuousAt g (f x) ∧ g (f x) = x ∧ RightInverse g f) : IsOpenMap f :=
  of_nhds_le fun x =>
    let ⟨g, hgc, hgx, hgf⟩ := h x
    calc
      𝓝 (f x) = map f (map g (𝓝 (f x))) := by rw [map_map, hgf.comp_eq_id, map_id]
      _ ≤ map f (𝓝 (g (f x))) := map_mono hgc
      _ = map f (𝓝 x) := by rw [hgx]
      
#align is_open_map.of_sections IsOpenMap.of_sections

theorem of_inverse {f : α → β} {f' : β → α} (h : Continuous f') (l_inv : LeftInverse f f')
    (r_inv : RightInverse f f') : IsOpenMap f :=
  of_sections fun x => ⟨f', h.ContinuousAt, r_inv _, l_inv⟩
#align is_open_map.of_inverse IsOpenMap.of_inverse

/-- A continuous surjective open map is a quotient map. -/
theorem to_quotient_map {f : α → β} (open_map : IsOpenMap f) (cont : Continuous f)
    (surj : Surjective f) : QuotientMap f :=
  quotient_map_iff.2
    ⟨surj, fun s => ⟨fun h => h.Preimage cont, fun h => surj.image_preimage s ▸ open_map _ h⟩⟩
#align is_open_map.to_quotient_map IsOpenMap.to_quotient_map

theorem interior_preimage_subset_preimage_interior (hf : IsOpenMap f) {s : Set β} :
    interior (f ⁻¹' s) ⊆ f ⁻¹' interior s :=
  hf.maps_to_interior (mapsTo_preimage _ _)
#align
  is_open_map.interior_preimage_subset_preimage_interior IsOpenMap.interior_preimage_subset_preimage_interior

theorem preimage_interior_eq_interior_preimage (hf₁ : IsOpenMap f) (hf₂ : Continuous f)
    (s : Set β) : f ⁻¹' interior s = interior (f ⁻¹' s) :=
  Subset.antisymm (preimage_interior_subset_interior_preimage hf₂)
    (interior_preimage_subset_preimage_interior hf₁)
#align
  is_open_map.preimage_interior_eq_interior_preimage IsOpenMap.preimage_interior_eq_interior_preimage

theorem preimage_closure_subset_closure_preimage (hf : IsOpenMap f) {s : Set β} :
    f ⁻¹' closure s ⊆ closure (f ⁻¹' s) :=
  by
  rw [← compl_subset_compl]
  simp only [← interior_compl, ← preimage_compl, hf.interior_preimage_subset_preimage_interior]
#align
  is_open_map.preimage_closure_subset_closure_preimage IsOpenMap.preimage_closure_subset_closure_preimage

theorem preimage_closure_eq_closure_preimage (hf : IsOpenMap f) (hfc : Continuous f) (s : Set β) :
    f ⁻¹' closure s = closure (f ⁻¹' s) :=
  hf.preimage_closure_subset_closure_preimage.antisymm (hfc.closure_preimage_subset s)
#align
  is_open_map.preimage_closure_eq_closure_preimage IsOpenMap.preimage_closure_eq_closure_preimage

theorem preimage_frontier_subset_frontier_preimage (hf : IsOpenMap f) {s : Set β} :
    f ⁻¹' frontier s ⊆ frontier (f ⁻¹' s) := by
  simpa only [frontier_eq_closure_inter_closure, preimage_inter] using
    inter_subset_inter hf.preimage_closure_subset_closure_preimage
      hf.preimage_closure_subset_closure_preimage
#align
  is_open_map.preimage_frontier_subset_frontier_preimage IsOpenMap.preimage_frontier_subset_frontier_preimage

theorem preimage_frontier_eq_frontier_preimage (hf : IsOpenMap f) (hfc : Continuous f) (s : Set β) :
    f ⁻¹' frontier s = frontier (f ⁻¹' s) := by
  simp only [frontier_eq_closure_inter_closure, preimage_inter, preimage_compl,
    hf.preimage_closure_eq_closure_preimage hfc]
#align
  is_open_map.preimage_frontier_eq_frontier_preimage IsOpenMap.preimage_frontier_eq_frontier_preimage

end IsOpenMap

theorem is_open_map_iff_nhds_le [TopologicalSpace α] [TopologicalSpace β] {f : α → β} :
    IsOpenMap f ↔ ∀ a : α, 𝓝 (f a) ≤ (𝓝 a).map f :=
  ⟨fun hf => hf.nhds_le, IsOpenMap.of_nhds_le⟩
#align is_open_map_iff_nhds_le is_open_map_iff_nhds_le

theorem is_open_map_iff_interior [TopologicalSpace α] [TopologicalSpace β] {f : α → β} :
    IsOpenMap f ↔ ∀ s, f '' interior s ⊆ interior (f '' s) :=
  ⟨IsOpenMap.image_interior_subset, fun hs u hu =>
    subset_interior_iff_is_open.mp <|
      calc
        f '' u = f '' interior u := by rw [hu.interior_eq]
        _ ⊆ interior (f '' u) := hs u
        ⟩
#align is_open_map_iff_interior is_open_map_iff_interior

/-- An inducing map with an open range is an open map. -/
protected theorem Inducing.is_open_map [TopologicalSpace α] [TopologicalSpace β] {f : α → β}
    (hi : Inducing f) (ho : IsOpen (range f)) : IsOpenMap f :=
  IsOpenMap.of_nhds_le fun x => (hi.map_nhds_of_mem _ <| IsOpen.mem_nhds ho <| mem_range_self _).ge
#align inducing.is_open_map Inducing.is_open_map

section IsClosedMap

variable [TopologicalSpace α] [TopologicalSpace β]

/-- A map `f : α → β` is said to be a *closed map*, if the image of any closed `U : set α`
is closed in `β`. -/
def IsClosedMap (f : α → β) :=
  ∀ U : Set α, IsClosed U → IsClosed (f '' U)
#align is_closed_map IsClosedMap

end IsClosedMap

namespace IsClosedMap

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ]

open Function

protected theorem id : IsClosedMap (@id α) := fun s hs => by rwa [image_id]
#align is_closed_map.id IsClosedMap.id

protected theorem comp {g : β → γ} {f : α → β} (hg : IsClosedMap g) (hf : IsClosedMap f) :
    IsClosedMap (g ∘ f) := by
  intro s hs
  rw [image_comp]
  exact hg _ (hf _ hs)
#align is_closed_map.comp IsClosedMap.comp

theorem closure_image_subset {f : α → β} (hf : IsClosedMap f) (s : Set α) :
    closure (f '' s) ⊆ f '' closure s :=
  closure_minimal (image_subset _ subset_closure) (hf _ is_closed_closure)
#align is_closed_map.closure_image_subset IsClosedMap.closure_image_subset

theorem of_inverse {f : α → β} {f' : β → α} (h : Continuous f') (l_inv : LeftInverse f f')
    (r_inv : RightInverse f f') : IsClosedMap f := fun s hs =>
  have : f' ⁻¹' s = f '' s := by ext x <;> simp [mem_image_iff_of_inverse r_inv l_inv]
  this ▸ hs.Preimage h
#align is_closed_map.of_inverse IsClosedMap.of_inverse

theorem of_nonempty {f : α → β} (h : ∀ s, IsClosed s → s.Nonempty → IsClosed (f '' s)) :
    IsClosedMap f := by
  intro s hs; cases' eq_empty_or_nonempty s with h2s h2s
  · simp_rw [h2s, image_empty, is_closed_empty]
  · exact h s hs h2s
#align is_closed_map.of_nonempty IsClosedMap.of_nonempty

theorem closed_range {f : α → β} (hf : IsClosedMap f) : IsClosed (range f) :=
  @image_univ _ _ f ▸ hf _ is_closed_univ
#align is_closed_map.closed_range IsClosedMap.closed_range

end IsClosedMap

theorem Inducing.is_closed_map [TopologicalSpace α] [TopologicalSpace β] {f : α → β}
    (hf : Inducing f) (h : IsClosed (range f)) : IsClosedMap f :=
  by
  intro s hs
  rcases hf.is_closed_iff.1 hs with ⟨t, ht, rfl⟩
  rw [image_preimage_eq_inter_range]
  exact ht.inter h
#align inducing.is_closed_map Inducing.is_closed_map

theorem is_closed_map_iff_closure_image [TopologicalSpace α] [TopologicalSpace β] {f : α → β} :
    IsClosedMap f ↔ ∀ s, closure (f '' s) ⊆ f '' closure s :=
  ⟨IsClosedMap.closure_image_subset, fun hs c hc =>
    is_closed_of_closure_subset <|
      calc
        closure (f '' c) ⊆ f '' closure c := hs c
        _ = f '' c := by rw [hc.closure_eq]
        ⟩
#align is_closed_map_iff_closure_image is_closed_map_iff_closure_image

section OpenEmbedding

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ]

/-- An open embedding is an embedding with open image. -/
@[mk_iff]
structure OpenEmbedding (f : α → β) extends Embedding f : Prop where
  open_range : IsOpen <| range f
#align open_embedding OpenEmbedding

theorem OpenEmbedding.is_open_map {f : α → β} (hf : OpenEmbedding f) : IsOpenMap f :=
  hf.toEmbedding.to_inducing.IsOpenMap hf.open_range
#align open_embedding.is_open_map OpenEmbedding.is_open_map

theorem OpenEmbedding.map_nhds_eq {f : α → β} (hf : OpenEmbedding f) (a : α) :
    map f (𝓝 a) = 𝓝 (f a) :=
  hf.toEmbedding.map_nhds_of_mem _ <| hf.open_range.mem_nhds <| mem_range_self _
#align open_embedding.map_nhds_eq OpenEmbedding.map_nhds_eq

theorem OpenEmbedding.open_iff_image_open {f : α → β} (hf : OpenEmbedding f) {s : Set α} :
    IsOpen s ↔ IsOpen (f '' s) :=
  ⟨hf.IsOpenMap s, fun h =>
    by
    convert ← h.preimage hf.to_embedding.continuous
    apply preimage_image_eq _ hf.inj⟩
#align open_embedding.open_iff_image_open OpenEmbedding.open_iff_image_open

theorem OpenEmbedding.tendsto_nhds_iff {ι : Type _} {f : ι → β} {g : β → γ} {a : Filter ι} {b : β}
    (hg : OpenEmbedding g) : Tendsto f a (𝓝 b) ↔ Tendsto (g ∘ f) a (𝓝 (g b)) :=
  hg.toEmbedding.tendsto_nhds_iff
#align open_embedding.tendsto_nhds_iff OpenEmbedding.tendsto_nhds_iff

theorem OpenEmbedding.continuous {f : α → β} (hf : OpenEmbedding f) : Continuous f :=
  hf.toEmbedding.Continuous
#align open_embedding.continuous OpenEmbedding.continuous

theorem OpenEmbedding.open_iff_preimage_open {f : α → β} (hf : OpenEmbedding f) {s : Set β}
    (hs : s ⊆ range f) : IsOpen s ↔ IsOpen (f ⁻¹' s) :=
  by
  convert ← hf.open_iff_image_open.symm
  rwa [image_preimage_eq_inter_range, inter_eq_self_of_subset_left]
#align open_embedding.open_iff_preimage_open OpenEmbedding.open_iff_preimage_open

theorem open_embedding_of_embedding_open {f : α → β} (h₁ : Embedding f) (h₂ : IsOpenMap f) :
    OpenEmbedding f :=
  ⟨h₁, h₂.is_open_range⟩
#align open_embedding_of_embedding_open open_embedding_of_embedding_open

theorem open_embedding_iff_embedding_open {f : α → β} :
    OpenEmbedding f ↔ Embedding f ∧ IsOpenMap f :=
  ⟨fun h => ⟨h.1, h.IsOpenMap⟩, fun h => open_embedding_of_embedding_open h.1 h.2⟩
#align open_embedding_iff_embedding_open open_embedding_iff_embedding_open

theorem open_embedding_of_continuous_injective_open {f : α → β} (h₁ : Continuous f)
    (h₂ : Injective f) (h₃ : IsOpenMap f) : OpenEmbedding f :=
  by
  simp only [open_embedding_iff_embedding_open, embedding_iff, inducing_iff_nhds, *, and_true_iff]
  exact fun a =>
    le_antisymm (h₁.tendsto _).le_comap (@comap_map _ _ (𝓝 a) _ h₂ ▸ comap_mono (h₃.nhds_le _))
#align open_embedding_of_continuous_injective_open open_embedding_of_continuous_injective_open

theorem open_embedding_iff_continuous_injective_open {f : α → β} :
    OpenEmbedding f ↔ Continuous f ∧ Injective f ∧ IsOpenMap f :=
  ⟨fun h => ⟨h.Continuous, h.inj, h.IsOpenMap⟩, fun h =>
    open_embedding_of_continuous_injective_open h.1 h.2.1 h.2.2⟩
#align open_embedding_iff_continuous_injective_open open_embedding_iff_continuous_injective_open

theorem open_embedding_id : OpenEmbedding (@id α) :=
  ⟨embedding_id, IsOpenMap.id.is_open_range⟩
#align open_embedding_id open_embedding_id

theorem OpenEmbedding.comp {g : β → γ} {f : α → β} (hg : OpenEmbedding g) (hf : OpenEmbedding f) :
    OpenEmbedding (g ∘ f) :=
  ⟨hg.1.comp hf.1, (hg.IsOpenMap.comp hf.IsOpenMap).is_open_range⟩
#align open_embedding.comp OpenEmbedding.comp

theorem OpenEmbedding.is_open_map_iff {g : β → γ} {f : α → β} (hg : OpenEmbedding g) :
    IsOpenMap f ↔ IsOpenMap (g ∘ f) := by
  simp only [is_open_map_iff_nhds_le, ← @map_map _ _ _ _ f g, ← hg.map_nhds_eq,
    map_le_map_iff hg.inj]
#align open_embedding.is_open_map_iff OpenEmbedding.is_open_map_iff

theorem OpenEmbedding.of_comp_iff (f : α → β) {g : β → γ} (hg : OpenEmbedding g) :
    OpenEmbedding (g ∘ f) ↔ OpenEmbedding f := by
  simp only [open_embedding_iff_continuous_injective_open, ← hg.is_open_map_iff, ←
    hg.1.continuous_iff, hg.inj.of_comp_iff]
#align open_embedding.of_comp_iff OpenEmbedding.of_comp_iff

theorem OpenEmbedding.of_comp (f : α → β) {g : β → γ} (hg : OpenEmbedding g)
    (h : OpenEmbedding (g ∘ f)) : OpenEmbedding f :=
  (OpenEmbedding.of_comp_iff f hg).1 h
#align open_embedding.of_comp OpenEmbedding.of_comp

end OpenEmbedding

section ClosedEmbedding

variable [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ]

/-- A closed embedding is an embedding with closed image. -/
@[mk_iff]
structure ClosedEmbedding (f : α → β) extends Embedding f : Prop where
  closed_range : IsClosed <| range f
#align closed_embedding ClosedEmbedding

variable {f : α → β}

theorem ClosedEmbedding.tendsto_nhds_iff {ι : Type _} {g : ι → α} {a : Filter ι} {b : α}
    (hf : ClosedEmbedding f) : Tendsto g a (𝓝 b) ↔ Tendsto (f ∘ g) a (𝓝 (f b)) :=
  hf.toEmbedding.tendsto_nhds_iff
#align closed_embedding.tendsto_nhds_iff ClosedEmbedding.tendsto_nhds_iff

theorem ClosedEmbedding.continuous (hf : ClosedEmbedding f) : Continuous f :=
  hf.toEmbedding.Continuous
#align closed_embedding.continuous ClosedEmbedding.continuous

theorem ClosedEmbedding.is_closed_map (hf : ClosedEmbedding f) : IsClosedMap f :=
  hf.toEmbedding.to_inducing.IsClosedMap hf.closed_range
#align closed_embedding.is_closed_map ClosedEmbedding.is_closed_map

theorem ClosedEmbedding.closed_iff_image_closed (hf : ClosedEmbedding f) {s : Set α} :
    IsClosed s ↔ IsClosed (f '' s) :=
  ⟨hf.IsClosedMap s, fun h =>
    by
    convert ← continuous_iff_is_closed.mp hf.continuous _ h
    apply preimage_image_eq _ hf.inj⟩
#align closed_embedding.closed_iff_image_closed ClosedEmbedding.closed_iff_image_closed

theorem ClosedEmbedding.closed_iff_preimage_closed (hf : ClosedEmbedding f) {s : Set β}
    (hs : s ⊆ range f) : IsClosed s ↔ IsClosed (f ⁻¹' s) :=
  by
  convert ← hf.closed_iff_image_closed.symm
  rwa [image_preimage_eq_inter_range, inter_eq_self_of_subset_left]
#align closed_embedding.closed_iff_preimage_closed ClosedEmbedding.closed_iff_preimage_closed

theorem closed_embedding_of_embedding_closed (h₁ : Embedding f) (h₂ : IsClosedMap f) :
    ClosedEmbedding f :=
  ⟨h₁, by convert h₂ univ is_closed_univ <;> simp⟩
#align closed_embedding_of_embedding_closed closed_embedding_of_embedding_closed

theorem closed_embedding_of_continuous_injective_closed (h₁ : Continuous f) (h₂ : Injective f)
    (h₃ : IsClosedMap f) : ClosedEmbedding f :=
  by
  refine' closed_embedding_of_embedding_closed ⟨⟨_⟩, h₂⟩ h₃
  apply le_antisymm (continuous_iff_le_induced.mp h₁) _
  intro s'
  change IsOpen _ ≤ IsOpen _
  rw [← is_closed_compl_iff, ← is_closed_compl_iff]
  generalize s'ᶜ = s
  rw [is_closed_induced_iff]
  refine' fun hs => ⟨f '' s, h₃ s hs, _⟩
  rw [preimage_image_eq _ h₂]
#align
  closed_embedding_of_continuous_injective_closed closed_embedding_of_continuous_injective_closed

theorem closed_embedding_id : ClosedEmbedding (@id α) :=
  ⟨embedding_id, by convert is_closed_univ <;> apply range_id⟩
#align closed_embedding_id closed_embedding_id

theorem ClosedEmbedding.comp {g : β → γ} {f : α → β} (hg : ClosedEmbedding g)
    (hf : ClosedEmbedding f) : ClosedEmbedding (g ∘ f) :=
  ⟨hg.toEmbedding.comp hf.toEmbedding,
    show IsClosed (range (g ∘ f)) by
      rw [range_comp, ← hg.closed_iff_image_closed] <;> exact hf.closed_range⟩
#align closed_embedding.comp ClosedEmbedding.comp

theorem ClosedEmbedding.closure_image_eq {f : α → β} (hf : ClosedEmbedding f) (s : Set α) :
    closure (f '' s) = f '' closure s :=
  (hf.IsClosedMap.closure_image_subset _).antisymm
    (image_closure_subset_closure_image hf.Continuous)
#align closed_embedding.closure_image_eq ClosedEmbedding.closure_image_eq

end ClosedEmbedding

