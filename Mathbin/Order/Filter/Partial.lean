/-
Copyright (c) 2019 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad
-/
import Order.Filter.Basic
import Data.PFun

#align_import order.filter.partial from "leanprover-community/mathlib"@"0a0ec35061ed9960bf0e7ffb0335f44447b58977"

/-!
# `tendsto` for relations and partial functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file generalizes `filter` definitions from functions to partial functions and relations.

## Considering functions and partial functions as relations

A function `f : α → β` can be considered as the relation `rel α β` which relates `x` and `f x` for
all `x`, and nothing else. This relation is called `function.graph f`.

A partial function `f : α →. β` can be considered as the relation `rel α β` which relates `x` and
`f x` for all `x` for which `f x` exists, and nothing else. This relation is called
`pfun.graph' f`.

In this regard, a function is a relation for which every element in `α` is related to exactly one
element in `β` and a partial function is a relation for which every element in `α` is related to at
most one element in `β`.

This file leverages this analogy to generalize `filter` definitions from functions to partial
functions and relations.

## Notes

`set.preimage` can be generalized to relations in two ways:
* `rel.preimage` returns the image of the set under the inverse relation.
* `rel.core` returns the set of elements that are only related to those in the set.
Both generalizations are sensible in the context of filters, so `filter.comap` and `filter.tendsto`
get two generalizations each.

We first take care of relations. Then the definitions for partial functions are taken as special
cases of the definitions for relations.
-/


universe u v w

namespace Filter

variable {α : Type u} {β : Type v} {γ : Type w}

open scoped Filter

/-! ### Relations -/


#print Filter.rmap /-
/-- The forward map of a filter under a relation. Generalization of `filter.map` to relations. Note
that `rel.core` generalizes `set.preimage`. -/
def rmap (r : Rel α β) (l : Filter α) : Filter β
    where
  sets := {s | r.core s ∈ l}
  univ_sets := by simp
  sets_of_superset s t hs st := mem_of_superset hs <| Rel.core_mono _ st
  inter_sets s t hs ht := by simp [Rel.core_inter, inter_mem hs ht]
#align filter.rmap Filter.rmap
-/

#print Filter.rmap_sets /-
theorem rmap_sets (r : Rel α β) (l : Filter α) : (l.rmap r).sets = r.core ⁻¹' l.sets :=
  rfl
#align filter.rmap_sets Filter.rmap_sets
-/

#print Filter.mem_rmap /-
@[simp]
theorem mem_rmap (r : Rel α β) (l : Filter α) (s : Set β) : s ∈ l.rmap r ↔ r.core s ∈ l :=
  Iff.rfl
#align filter.mem_rmap Filter.mem_rmap
-/

#print Filter.rmap_rmap /-
@[simp]
theorem rmap_rmap (r : Rel α β) (s : Rel β γ) (l : Filter α) :
    rmap s (rmap r l) = rmap (r.comp s) l :=
  filter_eq <| by simp [rmap_sets, Set.preimage, Rel.core_comp]
#align filter.rmap_rmap Filter.rmap_rmap
-/

#print Filter.rmap_compose /-
@[simp]
theorem rmap_compose (r : Rel α β) (s : Rel β γ) : rmap s ∘ rmap r = rmap (r.comp s) :=
  funext <| rmap_rmap _ _
#align filter.rmap_compose Filter.rmap_compose
-/

#print Filter.RTendsto /-
/-- Generic "limit of a relation" predicate. `rtendsto r l₁ l₂` asserts that for every
`l₂`-neighborhood `a`, the `r`-core of `a` is an `l₁`-neighborhood. One generalization of
`filter.tendsto` to relations. -/
def RTendsto (r : Rel α β) (l₁ : Filter α) (l₂ : Filter β) :=
  l₁.rmap r ≤ l₂
#align filter.rtendsto Filter.RTendsto
-/

#print Filter.rtendsto_def /-
theorem rtendsto_def (r : Rel α β) (l₁ : Filter α) (l₂ : Filter β) :
    RTendsto r l₁ l₂ ↔ ∀ s ∈ l₂, r.core s ∈ l₁ :=
  Iff.rfl
#align filter.rtendsto_def Filter.rtendsto_def
-/

#print Filter.rcomap /-
/-- One way of taking the inverse map of a filter under a relation. One generalization of
`filter.comap` to relations. Note that `rel.core` generalizes `set.preimage`. -/
def rcomap (r : Rel α β) (f : Filter β) : Filter α
    where
  sets := Rel.image (fun s t => r.core s ⊆ t) f.sets
  univ_sets := ⟨Set.univ, univ_mem, Set.subset_univ _⟩
  sets_of_superset := fun a b ⟨a', ha', ma'a⟩ ab => ⟨a', ha', ma'a.trans ab⟩
  inter_sets := fun a b ⟨a', ha₁, ha₂⟩ ⟨b', hb₁, hb₂⟩ =>
    ⟨a' ∩ b', inter_mem ha₁ hb₁, (r.core_inter a' b').Subset.trans (Set.inter_subset_inter ha₂ hb₂)⟩
#align filter.rcomap Filter.rcomap
-/

#print Filter.rcomap_sets /-
theorem rcomap_sets (r : Rel α β) (f : Filter β) :
    (rcomap r f).sets = Rel.image (fun s t => r.core s ⊆ t) f.sets :=
  rfl
#align filter.rcomap_sets Filter.rcomap_sets
-/

#print Filter.rcomap_rcomap /-
theorem rcomap_rcomap (r : Rel α β) (s : Rel β γ) (l : Filter γ) :
    rcomap r (rcomap s l) = rcomap (r.comp s) l :=
  filter_eq <| by
    ext t; simp [rcomap_sets, Rel.image, Rel.core_comp]; constructor
    · rintro ⟨u, ⟨v, vsets, hv⟩, h⟩
      exact ⟨v, vsets, Set.Subset.trans (Rel.core_mono _ hv) h⟩
    rintro ⟨t, tsets, ht⟩
    exact ⟨Rel.core s t, ⟨t, tsets, Set.Subset.rfl⟩, ht⟩
#align filter.rcomap_rcomap Filter.rcomap_rcomap
-/

#print Filter.rcomap_compose /-
@[simp]
theorem rcomap_compose (r : Rel α β) (s : Rel β γ) : rcomap r ∘ rcomap s = rcomap (r.comp s) :=
  funext <| rcomap_rcomap _ _
#align filter.rcomap_compose Filter.rcomap_compose
-/

#print Filter.rtendsto_iff_le_rcomap /-
theorem rtendsto_iff_le_rcomap (r : Rel α β) (l₁ : Filter α) (l₂ : Filter β) :
    RTendsto r l₁ l₂ ↔ l₁ ≤ l₂.rcomap r :=
  by
  rw [rtendsto_def]
  change (∀ s : Set β, s ∈ l₂.sets → r.core s ∈ l₁) ↔ l₁ ≤ rcomap r l₂
  simp [Filter.le_def, rcomap, Rel.mem_image]; constructor
  · exact fun h s t tl₂ => mem_of_superset (h t tl₂)
  · exact fun h t tl₂ => h _ t tl₂ Set.Subset.rfl
#align filter.rtendsto_iff_le_rcomap Filter.rtendsto_iff_le_rcomap
-/

#print Filter.rcomap' /-
-- Interestingly, there does not seem to be a way to express this relation using a forward map.
-- Given a filter `f` on `α`, we want a filter `f'` on `β` such that `r.preimage s ∈ f` if
-- and only if `s ∈ f'`. But the intersection of two sets satisfying the lhs may be empty.
/-- One way of taking the inverse map of a filter under a relation. Generalization of `filter.comap`
to relations. -/
def rcomap' (r : Rel α β) (f : Filter β) : Filter α
    where
  sets := Rel.image (fun s t => r.Preimage s ⊆ t) f.sets
  univ_sets := ⟨Set.univ, univ_mem, Set.subset_univ _⟩
  sets_of_superset := fun a b ⟨a', ha', ma'a⟩ ab => ⟨a', ha', ma'a.trans ab⟩
  inter_sets := fun a b ⟨a', ha₁, ha₂⟩ ⟨b', hb₁, hb₂⟩ =>
    ⟨a' ∩ b', inter_mem ha₁ hb₁,
      (@Rel.preimage_inter _ _ r _ _).trans (Set.inter_subset_inter ha₂ hb₂)⟩
#align filter.rcomap' Filter.rcomap'
-/

#print Filter.mem_rcomap' /-
@[simp]
theorem mem_rcomap' (r : Rel α β) (l : Filter β) (s : Set α) :
    s ∈ l.rcomap' r ↔ ∃ t ∈ l, r.Preimage t ⊆ s :=
  Iff.rfl
#align filter.mem_rcomap' Filter.mem_rcomap'
-/

#print Filter.rcomap'_sets /-
theorem rcomap'_sets (r : Rel α β) (f : Filter β) :
    (rcomap' r f).sets = Rel.image (fun s t => r.Preimage s ⊆ t) f.sets :=
  rfl
#align filter.rcomap'_sets Filter.rcomap'_sets
-/

#print Filter.rcomap'_rcomap' /-
@[simp]
theorem rcomap'_rcomap' (r : Rel α β) (s : Rel β γ) (l : Filter γ) :
    rcomap' r (rcomap' s l) = rcomap' (r.comp s) l :=
  Filter.ext fun t => by
    simp [rcomap'_sets, Rel.image, Rel.preimage_comp]; constructor
    · rintro ⟨u, ⟨v, vsets, hv⟩, h⟩
      exact ⟨v, vsets, (Rel.preimage_mono _ hv).trans h⟩
    rintro ⟨t, tsets, ht⟩
    exact ⟨s.preimage t, ⟨t, tsets, Set.Subset.rfl⟩, ht⟩
#align filter.rcomap'_rcomap' Filter.rcomap'_rcomap'
-/

#print Filter.rcomap'_compose /-
@[simp]
theorem rcomap'_compose (r : Rel α β) (s : Rel β γ) : rcomap' r ∘ rcomap' s = rcomap' (r.comp s) :=
  funext <| rcomap'_rcomap' _ _
#align filter.rcomap'_compose Filter.rcomap'_compose
-/

#print Filter.RTendsto' /-
/-- Generic "limit of a relation" predicate. `rtendsto' r l₁ l₂` asserts that for every
`l₂`-neighborhood `a`, the `r`-preimage of `a` is an `l₁`-neighborhood. One generalization of
`filter.tendsto` to relations. -/
def RTendsto' (r : Rel α β) (l₁ : Filter α) (l₂ : Filter β) :=
  l₁ ≤ l₂.rcomap' r
#align filter.rtendsto' Filter.RTendsto'
-/

#print Filter.rtendsto'_def /-
theorem rtendsto'_def (r : Rel α β) (l₁ : Filter α) (l₂ : Filter β) :
    RTendsto' r l₁ l₂ ↔ ∀ s ∈ l₂, r.Preimage s ∈ l₁ :=
  by
  unfold rtendsto' rcomap'; simp [le_def, Rel.mem_image]; constructor
  · exact fun h s hs => h _ _ hs Set.Subset.rfl
  · exact fun h s t ht => mem_of_superset (h t ht)
#align filter.rtendsto'_def Filter.rtendsto'_def
-/

#print Filter.tendsto_iff_rtendsto /-
theorem tendsto_iff_rtendsto (l₁ : Filter α) (l₂ : Filter β) (f : α → β) :
    Tendsto f l₁ l₂ ↔ RTendsto (Function.graph f) l₁ l₂ := by
  simp [tendsto_def, Function.graph, rtendsto_def, Rel.core, Set.preimage]
#align filter.tendsto_iff_rtendsto Filter.tendsto_iff_rtendsto
-/

#print Filter.tendsto_iff_rtendsto' /-
theorem tendsto_iff_rtendsto' (l₁ : Filter α) (l₂ : Filter β) (f : α → β) :
    Tendsto f l₁ l₂ ↔ RTendsto' (Function.graph f) l₁ l₂ := by
  simp [tendsto_def, Function.graph, rtendsto'_def, Rel.preimage_def, Set.preimage]
#align filter.tendsto_iff_rtendsto' Filter.tendsto_iff_rtendsto'
-/

/-! ### Partial functions -/


#print Filter.pmap /-
/-- The forward map of a filter under a partial function. Generalization of `filter.map` to partial
functions. -/
def pmap (f : α →. β) (l : Filter α) : Filter β :=
  Filter.rmap f.graph' l
#align filter.pmap Filter.pmap
-/

#print Filter.mem_pmap /-
@[simp]
theorem mem_pmap (f : α →. β) (l : Filter α) (s : Set β) : s ∈ l.pmap f ↔ f.core s ∈ l :=
  Iff.rfl
#align filter.mem_pmap Filter.mem_pmap
-/

#print Filter.PTendsto /-
/-- Generic "limit of a partial function" predicate. `ptendsto r l₁ l₂` asserts that for every
`l₂`-neighborhood `a`, the `p`-core of `a` is an `l₁`-neighborhood. One generalization of
`filter.tendsto` to partial function. -/
def PTendsto (f : α →. β) (l₁ : Filter α) (l₂ : Filter β) :=
  l₁.pmap f ≤ l₂
#align filter.ptendsto Filter.PTendsto
-/

#print Filter.ptendsto_def /-
theorem ptendsto_def (f : α →. β) (l₁ : Filter α) (l₂ : Filter β) :
    PTendsto f l₁ l₂ ↔ ∀ s ∈ l₂, f.core s ∈ l₁ :=
  Iff.rfl
#align filter.ptendsto_def Filter.ptendsto_def
-/

#print Filter.ptendsto_iff_rtendsto /-
theorem ptendsto_iff_rtendsto (l₁ : Filter α) (l₂ : Filter β) (f : α →. β) :
    PTendsto f l₁ l₂ ↔ RTendsto f.graph' l₁ l₂ :=
  Iff.rfl
#align filter.ptendsto_iff_rtendsto Filter.ptendsto_iff_rtendsto
-/

#print Filter.pmap_res /-
theorem pmap_res (l : Filter α) (s : Set α) (f : α → β) : pmap (PFun.res f s) l = map f (l ⊓ 𝓟 s) :=
  by
  ext t
  simp only [PFun.core_res, mem_pmap, mem_map, mem_inf_principal, imp_iff_not_or]
  rfl
#align filter.pmap_res Filter.pmap_res
-/

#print Filter.tendsto_iff_ptendsto /-
theorem tendsto_iff_ptendsto (l₁ : Filter α) (l₂ : Filter β) (s : Set α) (f : α → β) :
    Tendsto f (l₁ ⊓ 𝓟 s) l₂ ↔ PTendsto (PFun.res f s) l₁ l₂ := by
  simp only [tendsto, ptendsto, pmap_res]
#align filter.tendsto_iff_ptendsto Filter.tendsto_iff_ptendsto
-/

#print Filter.tendsto_iff_ptendsto_univ /-
theorem tendsto_iff_ptendsto_univ (l₁ : Filter α) (l₂ : Filter β) (f : α → β) :
    Tendsto f l₁ l₂ ↔ PTendsto (PFun.res f Set.univ) l₁ l₂ := by rw [← tendsto_iff_ptendsto];
  simp [principal_univ]
#align filter.tendsto_iff_ptendsto_univ Filter.tendsto_iff_ptendsto_univ
-/

#print Filter.pcomap' /-
/-- Inverse map of a filter under a partial function. One generalization of `filter.comap` to
partial functions. -/
def pcomap' (f : α →. β) (l : Filter β) : Filter α :=
  Filter.rcomap' f.graph' l
#align filter.pcomap' Filter.pcomap'
-/

#print Filter.PTendsto' /-
/-- Generic "limit of a partial function" predicate. `ptendsto' r l₁ l₂` asserts that for every
`l₂`-neighborhood `a`, the `p`-preimage of `a` is an `l₁`-neighborhood. One generalization of
`filter.tendsto` to partial functions. -/
def PTendsto' (f : α →. β) (l₁ : Filter α) (l₂ : Filter β) :=
  l₁ ≤ l₂.rcomap' f.graph'
#align filter.ptendsto' Filter.PTendsto'
-/

#print Filter.ptendsto'_def /-
theorem ptendsto'_def (f : α →. β) (l₁ : Filter α) (l₂ : Filter β) :
    PTendsto' f l₁ l₂ ↔ ∀ s ∈ l₂, f.Preimage s ∈ l₁ :=
  rtendsto'_def _ _ _
#align filter.ptendsto'_def Filter.ptendsto'_def
-/

#print Filter.ptendsto_of_ptendsto' /-
theorem ptendsto_of_ptendsto' {f : α →. β} {l₁ : Filter α} {l₂ : Filter β} :
    PTendsto' f l₁ l₂ → PTendsto f l₁ l₂ :=
  by
  rw [ptendsto_def, ptendsto'_def]
  exact fun h s sl₂ => mem_of_superset (h s sl₂) (PFun.preimage_subset_core _ _)
#align filter.ptendsto_of_ptendsto' Filter.ptendsto_of_ptendsto'
-/

#print Filter.ptendsto'_of_ptendsto /-
theorem ptendsto'_of_ptendsto {f : α →. β} {l₁ : Filter α} {l₂ : Filter β} (h : f.Dom ∈ l₁) :
    PTendsto f l₁ l₂ → PTendsto' f l₁ l₂ :=
  by
  rw [ptendsto_def, ptendsto'_def]
  intro h' s sl₂
  rw [PFun.preimage_eq]
  exact inter_mem (h' s sl₂) h
#align filter.ptendsto'_of_ptendsto Filter.ptendsto'_of_ptendsto
-/

end Filter

