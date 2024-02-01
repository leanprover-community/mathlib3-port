/-
Copyright (c) 2019 Reid Barton. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel
-/
import Topology.Constructions

#align_import topology.continuous_on from "leanprover-community/mathlib"@"d4f691b9e5f94cfc64639973f3544c95f8d5d494"

/-!
# Neighborhoods and continuity relative to a subset

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines relative versions

* `nhds_within`           of `nhds`
* `continuous_on`         of `continuous`
* `continuous_within_at`  of `continuous_at`

and proves their basic properties, including the relationships between
these restricted notions and the corresponding notions for the subtype
equipped with the subspace topology.

## Notation

* `𝓝 x`: the filter of neighborhoods of a point `x`;
* `𝓟 s`: the principal filter of a set `s`;
* `𝓝[s] x`: the filter `nhds_within x s` of neighborhoods of a point `x` within a set `s`.

-/


open Set Filter Function

open scoped Topology Filter

variable {α : Type _} {β : Type _} {γ : Type _} {δ : Type _}

variable [TopologicalSpace α]

#print nhds_bind_nhdsWithin /-
@[simp]
theorem nhds_bind_nhdsWithin {a : α} {s : Set α} : ((𝓝 a).bind fun x => 𝓝[s] x) = 𝓝[s] a :=
  bind_inf_principal.trans <| congr_arg₂ _ nhds_bind_nhds rfl
#align nhds_bind_nhds_within nhds_bind_nhdsWithin
-/

#print eventually_nhds_nhdsWithin /-
@[simp]
theorem eventually_nhds_nhdsWithin {a : α} {s : Set α} {p : α → Prop} :
    (∀ᶠ y in 𝓝 a, ∀ᶠ x in 𝓝[s] y, p x) ↔ ∀ᶠ x in 𝓝[s] a, p x :=
  Filter.ext_iff.1 nhds_bind_nhdsWithin {x | p x}
#align eventually_nhds_nhds_within eventually_nhds_nhdsWithin
-/

#print eventually_nhdsWithin_iff /-
theorem eventually_nhdsWithin_iff {a : α} {s : Set α} {p : α → Prop} :
    (∀ᶠ x in 𝓝[s] a, p x) ↔ ∀ᶠ x in 𝓝 a, x ∈ s → p x :=
  eventually_inf_principal
#align eventually_nhds_within_iff eventually_nhdsWithin_iff
-/

#print frequently_nhdsWithin_iff /-
theorem frequently_nhdsWithin_iff {z : α} {s : Set α} {p : α → Prop} :
    (∃ᶠ x in 𝓝[s] z, p x) ↔ ∃ᶠ x in 𝓝 z, p x ∧ x ∈ s :=
  Iff.not (by simp [eventually_nhdsWithin_iff, not_and'])
#align frequently_nhds_within_iff frequently_nhdsWithin_iff
-/

#print mem_closure_ne_iff_frequently_within /-
theorem mem_closure_ne_iff_frequently_within {z : α} {s : Set α} :
    z ∈ closure (s \ {z}) ↔ ∃ᶠ x in 𝓝[≠] z, x ∈ s := by
  simp [mem_closure_iff_frequently, frequently_nhdsWithin_iff]
#align mem_closure_ne_iff_frequently_within mem_closure_ne_iff_frequently_within
-/

#print eventually_nhdsWithin_nhdsWithin /-
@[simp]
theorem eventually_nhdsWithin_nhdsWithin {a : α} {s : Set α} {p : α → Prop} :
    (∀ᶠ y in 𝓝[s] a, ∀ᶠ x in 𝓝[s] y, p x) ↔ ∀ᶠ x in 𝓝[s] a, p x :=
  by
  refine' ⟨fun h => _, fun h => (eventually_nhds_nhdsWithin.2 h).filter_mono inf_le_left⟩
  simp only [eventually_nhdsWithin_iff] at h ⊢
  exact h.mono fun x hx hxs => (hx hxs).self_of_nhds hxs
#align eventually_nhds_within_nhds_within eventually_nhdsWithin_nhdsWithin
-/

#print nhdsWithin_eq /-
theorem nhdsWithin_eq (a : α) (s : Set α) :
    𝓝[s] a = ⨅ t ∈ {t : Set α | a ∈ t ∧ IsOpen t}, 𝓟 (t ∩ s) :=
  ((nhds_basis_opens a).inf_principal s).eq_biInf
#align nhds_within_eq nhdsWithin_eq
-/

#print nhdsWithin_univ /-
theorem nhdsWithin_univ (a : α) : 𝓝[Set.univ] a = 𝓝 a := by
  rw [nhdsWithin, principal_univ, inf_top_eq]
#align nhds_within_univ nhdsWithin_univ
-/

#print nhdsWithin_hasBasis /-
theorem nhdsWithin_hasBasis {p : β → Prop} {s : β → Set α} {a : α} (h : (𝓝 a).HasBasis p s)
    (t : Set α) : (𝓝[t] a).HasBasis p fun i => s i ∩ t :=
  h.inf_principal t
#align nhds_within_has_basis nhdsWithin_hasBasis
-/

#print nhdsWithin_basis_open /-
theorem nhdsWithin_basis_open (a : α) (t : Set α) :
    (𝓝[t] a).HasBasis (fun u => a ∈ u ∧ IsOpen u) fun u => u ∩ t :=
  nhdsWithin_hasBasis (nhds_basis_opens a) t
#align nhds_within_basis_open nhdsWithin_basis_open
-/

#print mem_nhdsWithin /-
theorem mem_nhdsWithin {t : Set α} {a : α} {s : Set α} :
    t ∈ 𝓝[s] a ↔ ∃ u, IsOpen u ∧ a ∈ u ∧ u ∩ s ⊆ t := by
  simpa only [exists_prop, and_assoc', and_comm'] using (nhdsWithin_basis_open a s).mem_iff
#align mem_nhds_within mem_nhdsWithin
-/

#print mem_nhdsWithin_iff_exists_mem_nhds_inter /-
theorem mem_nhdsWithin_iff_exists_mem_nhds_inter {t : Set α} {a : α} {s : Set α} :
    t ∈ 𝓝[s] a ↔ ∃ u ∈ 𝓝 a, u ∩ s ⊆ t :=
  (nhdsWithin_hasBasis (𝓝 a).basis_sets s).mem_iff
#align mem_nhds_within_iff_exists_mem_nhds_inter mem_nhdsWithin_iff_exists_mem_nhds_inter
-/

#print diff_mem_nhdsWithin_compl /-
theorem diff_mem_nhdsWithin_compl {x : α} {s : Set α} (hs : s ∈ 𝓝 x) (t : Set α) :
    s \ t ∈ 𝓝[tᶜ] x :=
  diff_mem_inf_principal_compl hs t
#align diff_mem_nhds_within_compl diff_mem_nhdsWithin_compl
-/

#print diff_mem_nhdsWithin_diff /-
theorem diff_mem_nhdsWithin_diff {x : α} {s t : Set α} (hs : s ∈ 𝓝[t] x) (t' : Set α) :
    s \ t' ∈ 𝓝[t \ t'] x :=
  by
  rw [nhdsWithin, diff_eq, diff_eq, ← inf_principal, ← inf_assoc]
  exact inter_mem_inf hs (mem_principal_self _)
#align diff_mem_nhds_within_diff diff_mem_nhdsWithin_diff
-/

#print nhds_of_nhdsWithin_of_nhds /-
theorem nhds_of_nhdsWithin_of_nhds {s t : Set α} {a : α} (h1 : s ∈ 𝓝 a) (h2 : t ∈ 𝓝[s] a) :
    t ∈ 𝓝 a :=
  by
  rcases mem_nhds_within_iff_exists_mem_nhds_inter.mp h2 with ⟨_, Hw, hw⟩
  exact (nhds a).sets_of_superset ((nhds a).inter_sets Hw h1) hw
#align nhds_of_nhds_within_of_nhds nhds_of_nhdsWithin_of_nhds
-/

#print mem_nhdsWithin_iff_eventually /-
theorem mem_nhdsWithin_iff_eventually {s t : Set α} {x : α} :
    t ∈ 𝓝[s] x ↔ ∀ᶠ y in 𝓝 x, y ∈ s → y ∈ t :=
  set_eventuallyLE_iff_mem_inf_principal.symm
#align mem_nhds_within_iff_eventually mem_nhdsWithin_iff_eventually
-/

#print mem_nhdsWithin_iff_eventuallyEq /-
theorem mem_nhdsWithin_iff_eventuallyEq {s t : Set α} {x : α} :
    t ∈ 𝓝[s] x ↔ s =ᶠ[𝓝 x] (s ∩ t : Set α) := by
  simp_rw [mem_nhdsWithin_iff_eventually, eventually_eq_set, mem_inter_iff, iff_self_and]
#align mem_nhds_within_iff_eventually_eq mem_nhdsWithin_iff_eventuallyEq
-/

#print nhdsWithin_eq_iff_eventuallyEq /-
theorem nhdsWithin_eq_iff_eventuallyEq {s t : Set α} {x : α} : 𝓝[s] x = 𝓝[t] x ↔ s =ᶠ[𝓝 x] t :=
  set_eventuallyEq_iff_inf_principal.symm
#align nhds_within_eq_iff_eventually_eq nhdsWithin_eq_iff_eventuallyEq
-/

#print nhdsWithin_le_iff /-
theorem nhdsWithin_le_iff {s t : Set α} {x : α} : 𝓝[s] x ≤ 𝓝[t] x ↔ t ∈ 𝓝[s] x :=
  set_eventuallyLE_iff_inf_principal_le.symm.trans set_eventuallyLE_iff_mem_inf_principal
#align nhds_within_le_iff nhdsWithin_le_iff
-/

theorem preimage_nhdsWithin_coinduced' {π : α → β} {s : Set β} {t : Set α} {a : α} (h : a ∈ t)
    (ht : IsOpen t)
    (hs :
      s ∈ @nhds β (TopologicalSpace.coinduced (fun x : t => π x) Subtype.topologicalSpace) (π a)) :
    π ⁻¹' s ∈ 𝓝[t] a :=
  by
  letI := TopologicalSpace.coinduced (fun x : t => π x) Subtype.topologicalSpace
  rcases mem_nhds_iff.mp hs with ⟨V, hVs, V_op, mem_V⟩
  refine'
    mem_nhds_within_iff_exists_mem_nhds_inter.mpr
      ⟨π ⁻¹' V, mem_nhds_iff.mpr ⟨t ∩ π ⁻¹' V, inter_subset_right t (π ⁻¹' V), _, mem_sep h mem_V⟩,
        subset.trans (inter_subset_left _ _) (preimage_mono hVs)⟩
  obtain ⟨u, hu1, hu2⟩ := is_open_induced_iff.mp (isOpen_coinduced.1 V_op)
  rw [preimage_comp] at hu2 
  rw [Set.inter_comm, ← subtype.preimage_coe_eq_preimage_coe_iff.mp hu2]
  exact hu1.inter ht
#align preimage_nhds_within_coinduced' preimage_nhdsWithin_coinduced'ₓ

#print mem_nhdsWithin_of_mem_nhds /-
theorem mem_nhdsWithin_of_mem_nhds {s t : Set α} {a : α} (h : s ∈ 𝓝 a) : s ∈ 𝓝[t] a :=
  mem_inf_of_left h
#align mem_nhds_within_of_mem_nhds mem_nhdsWithin_of_mem_nhds
-/

#print self_mem_nhdsWithin /-
theorem self_mem_nhdsWithin {a : α} {s : Set α} : s ∈ 𝓝[s] a :=
  mem_inf_of_right (mem_principal_self s)
#align self_mem_nhds_within self_mem_nhdsWithin
-/

#print eventually_mem_nhdsWithin /-
theorem eventually_mem_nhdsWithin {a : α} {s : Set α} : ∀ᶠ x in 𝓝[s] a, x ∈ s :=
  self_mem_nhdsWithin
#align eventually_mem_nhds_within eventually_mem_nhdsWithin
-/

#print inter_mem_nhdsWithin /-
theorem inter_mem_nhdsWithin (s : Set α) {t : Set α} {a : α} (h : t ∈ 𝓝 a) : s ∩ t ∈ 𝓝[s] a :=
  inter_mem self_mem_nhdsWithin (mem_inf_of_left h)
#align inter_mem_nhds_within inter_mem_nhdsWithin
-/

#print nhdsWithin_mono /-
theorem nhdsWithin_mono (a : α) {s t : Set α} (h : s ⊆ t) : 𝓝[s] a ≤ 𝓝[t] a :=
  inf_le_inf_left _ (principal_mono.mpr h)
#align nhds_within_mono nhdsWithin_mono
-/

#print pure_le_nhdsWithin /-
theorem pure_le_nhdsWithin {a : α} {s : Set α} (ha : a ∈ s) : pure a ≤ 𝓝[s] a :=
  le_inf (pure_le_nhds a) (le_principal_iff.2 ha)
#align pure_le_nhds_within pure_le_nhdsWithin
-/

#print mem_of_mem_nhdsWithin /-
theorem mem_of_mem_nhdsWithin {a : α} {s t : Set α} (ha : a ∈ s) (ht : t ∈ 𝓝[s] a) : a ∈ t :=
  pure_le_nhdsWithin ha ht
#align mem_of_mem_nhds_within mem_of_mem_nhdsWithin
-/

#print Filter.Eventually.self_of_nhdsWithin /-
theorem Filter.Eventually.self_of_nhdsWithin {p : α → Prop} {s : Set α} {x : α}
    (h : ∀ᶠ y in 𝓝[s] x, p y) (hx : x ∈ s) : p x :=
  mem_of_mem_nhdsWithin hx h
#align filter.eventually.self_of_nhds_within Filter.Eventually.self_of_nhdsWithin
-/

#print tendsto_const_nhdsWithin /-
theorem tendsto_const_nhdsWithin {l : Filter β} {s : Set α} {a : α} (ha : a ∈ s) :
    Tendsto (fun x : β => a) l (𝓝[s] a) :=
  tendsto_const_pure.mono_right <| pure_le_nhdsWithin ha
#align tendsto_const_nhds_within tendsto_const_nhdsWithin
-/

#print nhdsWithin_restrict'' /-
theorem nhdsWithin_restrict'' {a : α} (s : Set α) {t : Set α} (h : t ∈ 𝓝[s] a) :
    𝓝[s] a = 𝓝[s ∩ t] a :=
  le_antisymm (le_inf inf_le_left (le_principal_iff.mpr (inter_mem self_mem_nhdsWithin h)))
    (inf_le_inf_left _ (principal_mono.mpr (Set.inter_subset_left _ _)))
#align nhds_within_restrict'' nhdsWithin_restrict''
-/

#print nhdsWithin_restrict' /-
theorem nhdsWithin_restrict' {a : α} (s : Set α) {t : Set α} (h : t ∈ 𝓝 a) : 𝓝[s] a = 𝓝[s ∩ t] a :=
  nhdsWithin_restrict'' s <| mem_inf_of_left h
#align nhds_within_restrict' nhdsWithin_restrict'
-/

#print nhdsWithin_restrict /-
theorem nhdsWithin_restrict {a : α} (s : Set α) {t : Set α} (h₀ : a ∈ t) (h₁ : IsOpen t) :
    𝓝[s] a = 𝓝[s ∩ t] a :=
  nhdsWithin_restrict' s (IsOpen.mem_nhds h₁ h₀)
#align nhds_within_restrict nhdsWithin_restrict
-/

#print nhdsWithin_le_of_mem /-
theorem nhdsWithin_le_of_mem {a : α} {s t : Set α} (h : s ∈ 𝓝[t] a) : 𝓝[t] a ≤ 𝓝[s] a :=
  nhdsWithin_le_iff.mpr h
#align nhds_within_le_of_mem nhdsWithin_le_of_mem
-/

#print nhdsWithin_le_nhds /-
theorem nhdsWithin_le_nhds {a : α} {s : Set α} : 𝓝[s] a ≤ 𝓝 a := by rw [← nhdsWithin_univ];
  apply nhdsWithin_le_of_mem; exact univ_mem
#align nhds_within_le_nhds nhdsWithin_le_nhds
-/

#print nhdsWithin_eq_nhdsWithin' /-
theorem nhdsWithin_eq_nhdsWithin' {a : α} {s t u : Set α} (hs : s ∈ 𝓝 a) (h₂ : t ∩ s = u ∩ s) :
    𝓝[t] a = 𝓝[u] a := by rw [nhdsWithin_restrict' t hs, nhdsWithin_restrict' u hs, h₂]
#align nhds_within_eq_nhds_within' nhdsWithin_eq_nhdsWithin'
-/

#print nhdsWithin_eq_nhdsWithin /-
theorem nhdsWithin_eq_nhdsWithin {a : α} {s t u : Set α} (h₀ : a ∈ s) (h₁ : IsOpen s)
    (h₂ : t ∩ s = u ∩ s) : 𝓝[t] a = 𝓝[u] a := by
  rw [nhdsWithin_restrict t h₀ h₁, nhdsWithin_restrict u h₀ h₁, h₂]
#align nhds_within_eq_nhds_within nhdsWithin_eq_nhdsWithin
-/

#print nhdsWithin_eq_nhds /-
@[simp]
theorem nhdsWithin_eq_nhds {a : α} {s : Set α} : 𝓝[s] a = 𝓝 a ↔ s ∈ 𝓝 a := by
  rw [nhdsWithin, inf_eq_left, le_principal_iff]
#align nhds_within_eq_nhds nhdsWithin_eq_nhds
-/

#print IsOpen.nhdsWithin_eq /-
theorem IsOpen.nhdsWithin_eq {a : α} {s : Set α} (h : IsOpen s) (ha : a ∈ s) : 𝓝[s] a = 𝓝 a :=
  nhdsWithin_eq_nhds.2 <| IsOpen.mem_nhds h ha
#align is_open.nhds_within_eq IsOpen.nhdsWithin_eq
-/

#print preimage_nhds_within_coinduced /-
theorem preimage_nhds_within_coinduced {π : α → β} {s : Set β} {t : Set α} {a : α} (h : a ∈ t)
    (ht : IsOpen t)
    (hs :
      s ∈ @nhds β (TopologicalSpace.coinduced (fun x : t => π x) Subtype.topologicalSpace) (π a)) :
    π ⁻¹' s ∈ 𝓝 a := by rw [← ht.nhds_within_eq h]; exact preimage_nhdsWithin_coinduced' h ht hs
#align preimage_nhds_within_coinduced preimage_nhds_within_coinduced
-/

#print nhdsWithin_empty /-
@[simp]
theorem nhdsWithin_empty (a : α) : 𝓝[∅] a = ⊥ := by rw [nhdsWithin, principal_empty, inf_bot_eq]
#align nhds_within_empty nhdsWithin_empty
-/

#print nhdsWithin_union /-
theorem nhdsWithin_union (a : α) (s t : Set α) : 𝓝[s ∪ t] a = 𝓝[s] a ⊔ 𝓝[t] a := by
  delta nhdsWithin; rw [← inf_sup_left, sup_principal]
#align nhds_within_union nhdsWithin_union
-/

#print nhdsWithin_biUnion /-
theorem nhdsWithin_biUnion {ι} {I : Set ι} (hI : I.Finite) (s : ι → Set α) (a : α) :
    𝓝[⋃ i ∈ I, s i] a = ⨆ i ∈ I, 𝓝[s i] a :=
  Set.Finite.induction_on hI (by simp) fun t T _ _ hT => by
    simp only [hT, nhdsWithin_union, iSup_insert, bUnion_insert]
#align nhds_within_bUnion nhdsWithin_biUnion
-/

#print nhdsWithin_sUnion /-
theorem nhdsWithin_sUnion {S : Set (Set α)} (hS : S.Finite) (a : α) : 𝓝[⋃₀ S] a = ⨆ s ∈ S, 𝓝[s] a :=
  by rw [sUnion_eq_bUnion, nhdsWithin_biUnion hS]
#align nhds_within_sUnion nhdsWithin_sUnion
-/

#print nhdsWithin_iUnion /-
theorem nhdsWithin_iUnion {ι} [Finite ι] (s : ι → Set α) (a : α) : 𝓝[⋃ i, s i] a = ⨆ i, 𝓝[s i] a :=
  by rw [← sUnion_range, nhdsWithin_sUnion (finite_range s), iSup_range]
#align nhds_within_Union nhdsWithin_iUnion
-/

#print nhdsWithin_inter /-
theorem nhdsWithin_inter (a : α) (s t : Set α) : 𝓝[s ∩ t] a = 𝓝[s] a ⊓ 𝓝[t] a := by
  delta nhdsWithin; rw [inf_left_comm, inf_assoc, inf_principal, ← inf_assoc, inf_idem]
#align nhds_within_inter nhdsWithin_inter
-/

#print nhdsWithin_inter' /-
theorem nhdsWithin_inter' (a : α) (s t : Set α) : 𝓝[s ∩ t] a = 𝓝[s] a ⊓ 𝓟 t := by delta nhdsWithin;
  rw [← inf_principal, inf_assoc]
#align nhds_within_inter' nhdsWithin_inter'
-/

#print nhdsWithin_inter_of_mem /-
theorem nhdsWithin_inter_of_mem {a : α} {s t : Set α} (h : s ∈ 𝓝[t] a) : 𝓝[s ∩ t] a = 𝓝[t] a := by
  rw [nhdsWithin_inter, inf_eq_right]; exact nhdsWithin_le_of_mem h
#align nhds_within_inter_of_mem nhdsWithin_inter_of_mem
-/

#print nhdsWithin_inter_of_mem' /-
theorem nhdsWithin_inter_of_mem' {a : α} {s t : Set α} (h : s ∈ 𝓝[t] a) : 𝓝[t ∩ s] a = 𝓝[t] a := by
  rw [inter_comm, nhdsWithin_inter_of_mem h]
#align nhds_within_inter_of_mem' nhdsWithin_inter_of_mem'
-/

#print nhdsWithin_singleton /-
@[simp]
theorem nhdsWithin_singleton (a : α) : 𝓝[{a}] a = pure a := by
  rw [nhdsWithin, principal_singleton, inf_eq_right.2 (pure_le_nhds a)]
#align nhds_within_singleton nhdsWithin_singleton
-/

#print nhdsWithin_insert /-
@[simp]
theorem nhdsWithin_insert (a : α) (s : Set α) : 𝓝[insert a s] a = pure a ⊔ 𝓝[s] a := by
  rw [← singleton_union, nhdsWithin_union, nhdsWithin_singleton]
#align nhds_within_insert nhdsWithin_insert
-/

#print mem_nhdsWithin_insert /-
theorem mem_nhdsWithin_insert {a : α} {s t : Set α} : t ∈ 𝓝[insert a s] a ↔ a ∈ t ∧ t ∈ 𝓝[s] a := by
  simp
#align mem_nhds_within_insert mem_nhdsWithin_insert
-/

#print insert_mem_nhdsWithin_insert /-
theorem insert_mem_nhdsWithin_insert {a : α} {s t : Set α} (h : t ∈ 𝓝[s] a) :
    insert a t ∈ 𝓝[insert a s] a := by simp [mem_of_superset h]
#align insert_mem_nhds_within_insert insert_mem_nhdsWithin_insert
-/

#print insert_mem_nhds_iff /-
theorem insert_mem_nhds_iff {a : α} {s : Set α} : insert a s ∈ 𝓝 a ↔ s ∈ 𝓝[≠] a := by
  simp only [nhdsWithin, mem_inf_principal, mem_compl_iff, mem_singleton_iff,
    Classical.or_iff_not_imp_left, insert_def]
#align insert_mem_nhds_iff insert_mem_nhds_iff
-/

#print nhdsWithin_compl_singleton_sup_pure /-
@[simp]
theorem nhdsWithin_compl_singleton_sup_pure (a : α) : 𝓝[≠] a ⊔ pure a = 𝓝 a := by
  rw [← nhdsWithin_singleton, ← nhdsWithin_union, compl_union_self, nhdsWithin_univ]
#align nhds_within_compl_singleton_sup_pure nhdsWithin_compl_singleton_sup_pure
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print nhdsWithin_prod_eq /-
theorem nhdsWithin_prod_eq {α : Type _} [TopologicalSpace α] {β : Type _} [TopologicalSpace β]
    (a : α) (b : β) (s : Set α) (t : Set β) : 𝓝[s ×ˢ t] (a, b) = 𝓝[s] a ×ᶠ 𝓝[t] b := by
  delta nhdsWithin; rw [nhds_prod_eq, ← Filter.prod_inf_prod, Filter.prod_principal_principal]
#align nhds_within_prod_eq nhdsWithin_prod_eq
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print nhdsWithin_prod /-
theorem nhdsWithin_prod {α : Type _} [TopologicalSpace α] {β : Type _} [TopologicalSpace β]
    {s u : Set α} {t v : Set β} {a : α} {b : β} (hu : u ∈ 𝓝[s] a) (hv : v ∈ 𝓝[t] b) :
    u ×ˢ v ∈ 𝓝[s ×ˢ t] (a, b) := by rw [nhdsWithin_prod_eq]; exact prod_mem_prod hu hv
#align nhds_within_prod nhdsWithin_prod
-/

#print nhdsWithin_pi_eq' /-
theorem nhdsWithin_pi_eq' {ι : Type _} {α : ι → Type _} [∀ i, TopologicalSpace (α i)] {I : Set ι}
    (hI : I.Finite) (s : ∀ i, Set (α i)) (x : ∀ i, α i) :
    𝓝[pi I s] x = ⨅ i, comap (fun x => x i) (𝓝 (x i) ⊓ ⨅ hi : i ∈ I, 𝓟 (s i)) := by
  simp only [nhdsWithin, nhds_pi, Filter.pi, comap_inf, comap_infi, pi_def, comap_principal, ←
    infi_principal_finite hI, ← iInf_inf_eq]
#align nhds_within_pi_eq' nhdsWithin_pi_eq'
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:641:2: warning: expanding binder collection (i «expr ∉ » I) -/
#print nhdsWithin_pi_eq /-
theorem nhdsWithin_pi_eq {ι : Type _} {α : ι → Type _} [∀ i, TopologicalSpace (α i)] {I : Set ι}
    (hI : I.Finite) (s : ∀ i, Set (α i)) (x : ∀ i, α i) :
    𝓝[pi I s] x =
      (⨅ i ∈ I, comap (fun x => x i) (𝓝[s i] x i)) ⊓
        ⨅ (i) (_ : i ∉ I), comap (fun x => x i) (𝓝 (x i)) :=
  by
  simp only [nhdsWithin, nhds_pi, Filter.pi, pi_def, ← infi_principal_finite hI, comap_inf,
    comap_principal, eval]
  rw [iInf_split _ fun i => i ∈ I, inf_right_comm]
  simp only [iInf_inf_eq]
#align nhds_within_pi_eq nhdsWithin_pi_eq
-/

#print nhdsWithin_pi_univ_eq /-
theorem nhdsWithin_pi_univ_eq {ι : Type _} {α : ι → Type _} [Finite ι] [∀ i, TopologicalSpace (α i)]
    (s : ∀ i, Set (α i)) (x : ∀ i, α i) : 𝓝[pi univ s] x = ⨅ i, comap (fun x => x i) (𝓝[s i] x i) :=
  by simpa [nhdsWithin] using nhdsWithin_pi_eq finite_univ s x
#align nhds_within_pi_univ_eq nhdsWithin_pi_univ_eq
-/

#print nhdsWithin_pi_eq_bot /-
theorem nhdsWithin_pi_eq_bot {ι : Type _} {α : ι → Type _} [∀ i, TopologicalSpace (α i)] {I : Set ι}
    {s : ∀ i, Set (α i)} {x : ∀ i, α i} : 𝓝[pi I s] x = ⊥ ↔ ∃ i ∈ I, 𝓝[s i] x i = ⊥ := by
  simp only [nhdsWithin, nhds_pi, pi_inf_principal_pi_eq_bot]
#align nhds_within_pi_eq_bot nhdsWithin_pi_eq_bot
-/

#print nhdsWithin_pi_neBot /-
theorem nhdsWithin_pi_neBot {ι : Type _} {α : ι → Type _} [∀ i, TopologicalSpace (α i)] {I : Set ι}
    {s : ∀ i, Set (α i)} {x : ∀ i, α i} : (𝓝[pi I s] x).ne_bot ↔ ∀ i ∈ I, (𝓝[s i] x i).ne_bot := by
  simp [ne_bot_iff, nhdsWithin_pi_eq_bot]
#align nhds_within_pi_ne_bot nhdsWithin_pi_neBot
-/

#print Filter.Tendsto.piecewise_nhdsWithin /-
theorem Filter.Tendsto.piecewise_nhdsWithin {f g : α → β} {t : Set α} [∀ x, Decidable (x ∈ t)]
    {a : α} {s : Set α} {l : Filter β} (h₀ : Tendsto f (𝓝[s ∩ t] a) l)
    (h₁ : Tendsto g (𝓝[s ∩ tᶜ] a) l) : Tendsto (piecewise t f g) (𝓝[s] a) l := by
  apply tendsto.piecewise <;> rwa [← nhdsWithin_inter']
#align filter.tendsto.piecewise_nhds_within Filter.Tendsto.piecewise_nhdsWithin
-/

#print Filter.Tendsto.if_nhdsWithin /-
theorem Filter.Tendsto.if_nhdsWithin {f g : α → β} {p : α → Prop} [DecidablePred p] {a : α}
    {s : Set α} {l : Filter β} (h₀ : Tendsto f (𝓝[s ∩ {x | p x}] a) l)
    (h₁ : Tendsto g (𝓝[s ∩ {x | ¬p x}] a) l) :
    Tendsto (fun x => if p x then f x else g x) (𝓝[s] a) l :=
  h₀.piecewise_nhdsWithin h₁
#align filter.tendsto.if_nhds_within Filter.Tendsto.if_nhdsWithin
-/

#print map_nhdsWithin /-
theorem map_nhdsWithin (f : α → β) (a : α) (s : Set α) :
    map f (𝓝[s] a) = ⨅ t ∈ {t : Set α | a ∈ t ∧ IsOpen t}, 𝓟 (f '' (t ∩ s)) :=
  ((nhdsWithin_basis_open a s).map f).eq_biInf
#align map_nhds_within map_nhdsWithin
-/

#print tendsto_nhdsWithin_mono_left /-
theorem tendsto_nhdsWithin_mono_left {f : α → β} {a : α} {s t : Set α} {l : Filter β} (hst : s ⊆ t)
    (h : Tendsto f (𝓝[t] a) l) : Tendsto f (𝓝[s] a) l :=
  h.mono_left <| nhdsWithin_mono a hst
#align tendsto_nhds_within_mono_left tendsto_nhdsWithin_mono_left
-/

#print tendsto_nhdsWithin_mono_right /-
theorem tendsto_nhdsWithin_mono_right {f : β → α} {l : Filter β} {a : α} {s t : Set α} (hst : s ⊆ t)
    (h : Tendsto f l (𝓝[s] a)) : Tendsto f l (𝓝[t] a) :=
  h.mono_right (nhdsWithin_mono a hst)
#align tendsto_nhds_within_mono_right tendsto_nhdsWithin_mono_right
-/

#print tendsto_nhdsWithin_of_tendsto_nhds /-
theorem tendsto_nhdsWithin_of_tendsto_nhds {f : α → β} {a : α} {s : Set α} {l : Filter β}
    (h : Tendsto f (𝓝 a) l) : Tendsto f (𝓝[s] a) l :=
  h.mono_left inf_le_left
#align tendsto_nhds_within_of_tendsto_nhds tendsto_nhdsWithin_of_tendsto_nhds
-/

#print eventually_mem_of_tendsto_nhdsWithin /-
theorem eventually_mem_of_tendsto_nhdsWithin {f : β → α} {a : α} {s : Set α} {l : Filter β}
    (h : Tendsto f l (𝓝[s] a)) : ∀ᶠ i in l, f i ∈ s :=
  by
  simp_rw [nhdsWithin_eq, tendsto_infi, mem_set_of_eq, tendsto_principal, mem_inter_iff,
    eventually_and] at h 
  exact (h univ ⟨mem_univ a, isOpen_univ⟩).2
#align eventually_mem_of_tendsto_nhds_within eventually_mem_of_tendsto_nhdsWithin
-/

#print tendsto_nhds_of_tendsto_nhdsWithin /-
theorem tendsto_nhds_of_tendsto_nhdsWithin {f : β → α} {a : α} {s : Set α} {l : Filter β}
    (h : Tendsto f l (𝓝[s] a)) : Tendsto f l (𝓝 a) :=
  h.mono_right nhdsWithin_le_nhds
#align tendsto_nhds_of_tendsto_nhds_within tendsto_nhds_of_tendsto_nhdsWithin
-/

#print principal_subtype /-
theorem principal_subtype {α : Type _} (s : Set α) (t : Set { x // x ∈ s }) :
    𝓟 t = comap coe (𝓟 ((coe : s → α) '' t)) := by
  rw [comap_principal, Set.preimage_image_eq _ Subtype.coe_injective]
#align principal_subtype principal_subtype
-/

#print nhdsWithin_neBot_of_mem /-
theorem nhdsWithin_neBot_of_mem {s : Set α} {x : α} (hx : x ∈ s) : NeBot (𝓝[s] x) :=
  mem_closure_iff_nhdsWithin_neBot.1 <| subset_closure hx
#align nhds_within_ne_bot_of_mem nhdsWithin_neBot_of_mem
-/

#print IsClosed.mem_of_nhdsWithin_neBot /-
theorem IsClosed.mem_of_nhdsWithin_neBot {s : Set α} (hs : IsClosed s) {x : α}
    (hx : NeBot <| 𝓝[s] x) : x ∈ s := by
  simpa only [hs.closure_eq] using mem_closure_iff_nhdsWithin_neBot.2 hx
#align is_closed.mem_of_nhds_within_ne_bot IsClosed.mem_of_nhdsWithin_neBot
-/

#print DenseRange.nhdsWithin_neBot /-
theorem DenseRange.nhdsWithin_neBot {ι : Type _} {f : ι → α} (h : DenseRange f) (x : α) :
    NeBot (𝓝[range f] x) :=
  mem_closure_iff_clusterPt.1 (h x)
#align dense_range.nhds_within_ne_bot DenseRange.nhdsWithin_neBot
-/

#print mem_closure_pi /-
theorem mem_closure_pi {ι : Type _} {α : ι → Type _} [∀ i, TopologicalSpace (α i)] {I : Set ι}
    {s : ∀ i, Set (α i)} {x : ∀ i, α i} : x ∈ closure (pi I s) ↔ ∀ i ∈ I, x i ∈ closure (s i) := by
  simp only [mem_closure_iff_nhdsWithin_neBot, nhdsWithin_pi_neBot]
#align mem_closure_pi mem_closure_pi
-/

#print closure_pi_set /-
theorem closure_pi_set {ι : Type _} {α : ι → Type _} [∀ i, TopologicalSpace (α i)] (I : Set ι)
    (s : ∀ i, Set (α i)) : closure (pi I s) = pi I fun i => closure (s i) :=
  Set.ext fun x => mem_closure_pi
#align closure_pi_set closure_pi_set
-/

#print dense_pi /-
theorem dense_pi {ι : Type _} {α : ι → Type _} [∀ i, TopologicalSpace (α i)] {s : ∀ i, Set (α i)}
    (I : Set ι) (hs : ∀ i ∈ I, Dense (s i)) : Dense (pi I s) := by
  simp only [dense_iff_closure_eq, closure_pi_set, pi_congr rfl fun i hi => (hs i hi).closure_eq,
    pi_univ]
#align dense_pi dense_pi
-/

#print eventuallyEq_nhdsWithin_iff /-
theorem eventuallyEq_nhdsWithin_iff {f g : α → β} {s : Set α} {a : α} :
    f =ᶠ[𝓝[s] a] g ↔ ∀ᶠ x in 𝓝 a, x ∈ s → f x = g x :=
  mem_inf_principal
#align eventually_eq_nhds_within_iff eventuallyEq_nhdsWithin_iff
-/

#print eventuallyEq_nhdsWithin_of_eqOn /-
theorem eventuallyEq_nhdsWithin_of_eqOn {f g : α → β} {s : Set α} {a : α} (h : EqOn f g s) :
    f =ᶠ[𝓝[s] a] g :=
  mem_inf_of_right h
#align eventually_eq_nhds_within_of_eq_on eventuallyEq_nhdsWithin_of_eqOn
-/

#print Set.EqOn.eventuallyEq_nhdsWithin /-
theorem Set.EqOn.eventuallyEq_nhdsWithin {f g : α → β} {s : Set α} {a : α} (h : EqOn f g s) :
    f =ᶠ[𝓝[s] a] g :=
  eventuallyEq_nhdsWithin_of_eqOn h
#align set.eq_on.eventually_eq_nhds_within Set.EqOn.eventuallyEq_nhdsWithin
-/

#print tendsto_nhdsWithin_congr /-
theorem tendsto_nhdsWithin_congr {f g : α → β} {s : Set α} {a : α} {l : Filter β}
    (hfg : ∀ x ∈ s, f x = g x) (hf : Tendsto f (𝓝[s] a) l) : Tendsto g (𝓝[s] a) l :=
  (tendsto_congr' <| eventuallyEq_nhdsWithin_of_eqOn hfg).1 hf
#align tendsto_nhds_within_congr tendsto_nhdsWithin_congr
-/

#print eventually_nhdsWithin_of_forall /-
theorem eventually_nhdsWithin_of_forall {s : Set α} {a : α} {p : α → Prop} (h : ∀ x ∈ s, p x) :
    ∀ᶠ x in 𝓝[s] a, p x :=
  mem_inf_of_right h
#align eventually_nhds_within_of_forall eventually_nhdsWithin_of_forall
-/

#print tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within /-
theorem tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within {a : α} {l : Filter β} {s : Set α}
    (f : β → α) (h1 : Tendsto f l (𝓝 a)) (h2 : ∀ᶠ x in l, f x ∈ s) : Tendsto f l (𝓝[s] a) :=
  tendsto_inf.2 ⟨h1, tendsto_principal.2 h2⟩
#align tendsto_nhds_within_of_tendsto_nhds_of_eventually_within tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within
-/

#print tendsto_nhdsWithin_iff /-
theorem tendsto_nhdsWithin_iff {a : α} {l : Filter β} {s : Set α} {f : β → α} :
    Tendsto f l (𝓝[s] a) ↔ Tendsto f l (𝓝 a) ∧ ∀ᶠ n in l, f n ∈ s :=
  ⟨fun h => ⟨tendsto_nhds_of_tendsto_nhdsWithin h, eventually_mem_of_tendsto_nhdsWithin h⟩, fun h =>
    tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within _ h.1 h.2⟩
#align tendsto_nhds_within_iff tendsto_nhdsWithin_iff
-/

#print tendsto_nhdsWithin_range /-
@[simp]
theorem tendsto_nhdsWithin_range {a : α} {l : Filter β} {f : β → α} :
    Tendsto f l (𝓝[range f] a) ↔ Tendsto f l (𝓝 a) :=
  ⟨fun h => h.mono_right inf_le_left, fun h =>
    tendsto_inf.2 ⟨h, tendsto_principal.2 <| eventually_of_forall mem_range_self⟩⟩
#align tendsto_nhds_within_range tendsto_nhdsWithin_range
-/

#print Filter.EventuallyEq.eq_of_nhdsWithin /-
theorem Filter.EventuallyEq.eq_of_nhdsWithin {s : Set α} {f g : α → β} {a : α} (h : f =ᶠ[𝓝[s] a] g)
    (hmem : a ∈ s) : f a = g a :=
  h.self_of_nhdsWithin hmem
#align filter.eventually_eq.eq_of_nhds_within Filter.EventuallyEq.eq_of_nhdsWithin
-/

#print eventually_nhdsWithin_of_eventually_nhds /-
theorem eventually_nhdsWithin_of_eventually_nhds {α : Type _} [TopologicalSpace α] {s : Set α}
    {a : α} {p : α → Prop} (h : ∀ᶠ x in 𝓝 a, p x) : ∀ᶠ x in 𝓝[s] a, p x :=
  mem_nhdsWithin_of_mem_nhds h
#align eventually_nhds_within_of_eventually_nhds eventually_nhdsWithin_of_eventually_nhds
-/

/-!
### `nhds_within` and subtypes
-/


#print mem_nhdsWithin_subtype /-
theorem mem_nhdsWithin_subtype {s : Set α} {a : { x // x ∈ s }} {t u : Set { x // x ∈ s }} :
    t ∈ 𝓝[u] a ↔ t ∈ comap (coe : s → α) (𝓝[coe '' u] a) := by
  rw [nhdsWithin, nhds_subtype, principal_subtype, ← comap_inf, ← nhdsWithin]
#align mem_nhds_within_subtype mem_nhdsWithin_subtype
-/

#print nhdsWithin_subtype /-
theorem nhdsWithin_subtype (s : Set α) (a : { x // x ∈ s }) (t : Set { x // x ∈ s }) :
    𝓝[t] a = comap (coe : s → α) (𝓝[coe '' t] a) :=
  Filter.ext fun u => mem_nhdsWithin_subtype
#align nhds_within_subtype nhdsWithin_subtype
-/

#print nhdsWithin_eq_map_subtype_coe /-
theorem nhdsWithin_eq_map_subtype_coe {s : Set α} {a : α} (h : a ∈ s) :
    𝓝[s] a = map (coe : s → α) (𝓝 ⟨a, h⟩) := by
  simpa only [Subtype.range_coe] using (embedding_subtype_coe.map_nhds_eq ⟨a, h⟩).symm
#align nhds_within_eq_map_subtype_coe nhdsWithin_eq_map_subtype_coe
-/

#print mem_nhds_subtype_iff_nhdsWithin /-
theorem mem_nhds_subtype_iff_nhdsWithin {s : Set α} {a : s} {t : Set s} :
    t ∈ 𝓝 a ↔ coe '' t ∈ 𝓝[s] (a : α) := by
  rw [nhdsWithin_eq_map_subtype_coe a.coe_prop, mem_map, preimage_image_eq _ Subtype.coe_injective,
    Subtype.coe_eta]
#align mem_nhds_subtype_iff_nhds_within mem_nhds_subtype_iff_nhdsWithin
-/

#print preimage_coe_mem_nhds_subtype /-
theorem preimage_coe_mem_nhds_subtype {s t : Set α} {a : s} : coe ⁻¹' t ∈ 𝓝 a ↔ t ∈ 𝓝[s] ↑a := by
  simp only [mem_nhds_subtype_iff_nhdsWithin, Subtype.image_preimage_coe, inter_mem_iff,
    self_mem_nhdsWithin, and_true_iff]
#align preimage_coe_mem_nhds_subtype preimage_coe_mem_nhds_subtype
-/

#print tendsto_nhdsWithin_iff_subtype /-
theorem tendsto_nhdsWithin_iff_subtype {s : Set α} {a : α} (h : a ∈ s) (f : α → β) (l : Filter β) :
    Tendsto f (𝓝[s] a) l ↔ Tendsto (s.restrict f) (𝓝 ⟨a, h⟩) l := by
  simp only [tendsto, nhdsWithin_eq_map_subtype_coe h, Filter.map_map, restrict]
#align tendsto_nhds_within_iff_subtype tendsto_nhdsWithin_iff_subtype
-/

variable [TopologicalSpace β] [TopologicalSpace γ] [TopologicalSpace δ]

#print ContinuousWithinAt /-
/-- A function between topological spaces is continuous at a point `x₀` within a subset `s`
if `f x` tends to `f x₀` when `x` tends to `x₀` while staying within `s`. -/
def ContinuousWithinAt (f : α → β) (s : Set α) (x : α) : Prop :=
  Tendsto f (𝓝[s] x) (𝓝 (f x))
#align continuous_within_at ContinuousWithinAt
-/

#print ContinuousWithinAt.tendsto /-
/-- If a function is continuous within `s` at `x`, then it tends to `f x` within `s` by definition.
We register this fact for use with the dot notation, especially to use `tendsto.comp` as
`continuous_within_at.comp` will have a different meaning. -/
theorem ContinuousWithinAt.tendsto {f : α → β} {s : Set α} {x : α} (h : ContinuousWithinAt f s x) :
    Tendsto f (𝓝[s] x) (𝓝 (f x)) :=
  h
#align continuous_within_at.tendsto ContinuousWithinAt.tendsto
-/

#print ContinuousOn /-
/-- A function between topological spaces is continuous on a subset `s`
when it's continuous at every point of `s` within `s`. -/
def ContinuousOn (f : α → β) (s : Set α) : Prop :=
  ∀ x ∈ s, ContinuousWithinAt f s x
#align continuous_on ContinuousOn
-/

#print ContinuousOn.continuousWithinAt /-
theorem ContinuousOn.continuousWithinAt {f : α → β} {s : Set α} {x : α} (hf : ContinuousOn f s)
    (hx : x ∈ s) : ContinuousWithinAt f s x :=
  hf x hx
#align continuous_on.continuous_within_at ContinuousOn.continuousWithinAt
-/

#print continuousWithinAt_univ /-
theorem continuousWithinAt_univ (f : α → β) (x : α) :
    ContinuousWithinAt f Set.univ x ↔ ContinuousAt f x := by
  rw [ContinuousAt, ContinuousWithinAt, nhdsWithin_univ]
#align continuous_within_at_univ continuousWithinAt_univ
-/

#print continuousWithinAt_iff_continuousAt_restrict /-
theorem continuousWithinAt_iff_continuousAt_restrict (f : α → β) {x : α} {s : Set α} (h : x ∈ s) :
    ContinuousWithinAt f s x ↔ ContinuousAt (s.restrict f) ⟨x, h⟩ :=
  tendsto_nhdsWithin_iff_subtype h f _
#align continuous_within_at_iff_continuous_at_restrict continuousWithinAt_iff_continuousAt_restrict
-/

#print ContinuousWithinAt.tendsto_nhdsWithin /-
theorem ContinuousWithinAt.tendsto_nhdsWithin {f : α → β} {x : α} {s : Set α} {t : Set β}
    (h : ContinuousWithinAt f s x) (ht : MapsTo f s t) : Tendsto f (𝓝[s] x) (𝓝[t] f x) :=
  tendsto_inf.2 ⟨h, tendsto_principal.2 <| mem_inf_of_right <| mem_principal.2 <| ht⟩
#align continuous_within_at.tendsto_nhds_within ContinuousWithinAt.tendsto_nhdsWithin
-/

#print ContinuousWithinAt.tendsto_nhdsWithin_image /-
theorem ContinuousWithinAt.tendsto_nhdsWithin_image {f : α → β} {x : α} {s : Set α}
    (h : ContinuousWithinAt f s x) : Tendsto f (𝓝[s] x) (𝓝[f '' s] f x) :=
  h.tendsto_nhdsWithin (mapsTo_image _ _)
#align continuous_within_at.tendsto_nhds_within_image ContinuousWithinAt.tendsto_nhdsWithin_image
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ContinuousWithinAt.prod_map /-
theorem ContinuousWithinAt.prod_map {f : α → γ} {g : β → δ} {s : Set α} {t : Set β} {x : α} {y : β}
    (hf : ContinuousWithinAt f s x) (hg : ContinuousWithinAt g t y) :
    ContinuousWithinAt (Prod.map f g) (s ×ˢ t) (x, y) :=
  by
  unfold ContinuousWithinAt at *
  rw [nhdsWithin_prod_eq, Prod.map, nhds_prod_eq]
  exact hf.prod_map hg
#align continuous_within_at.prod_map ContinuousWithinAt.prod_map
-/

#print continuousWithinAt_pi /-
theorem continuousWithinAt_pi {ι : Type _} {π : ι → Type _} [∀ i, TopologicalSpace (π i)]
    {f : α → ∀ i, π i} {s : Set α} {x : α} :
    ContinuousWithinAt f s x ↔ ∀ i, ContinuousWithinAt (fun y => f y i) s x :=
  tendsto_pi_nhds
#align continuous_within_at_pi continuousWithinAt_pi
-/

#print continuousOn_pi /-
theorem continuousOn_pi {ι : Type _} {π : ι → Type _} [∀ i, TopologicalSpace (π i)]
    {f : α → ∀ i, π i} {s : Set α} : ContinuousOn f s ↔ ∀ i, ContinuousOn (fun y => f y i) s :=
  ⟨fun h i x hx => tendsto_pi_nhds.1 (h x hx) i, fun h x hx => tendsto_pi_nhds.2 fun i => h i x hx⟩
#align continuous_on_pi continuousOn_pi
-/

#print ContinuousWithinAt.fin_insertNth /-
theorem ContinuousWithinAt.fin_insertNth {n} {π : Fin (n + 1) → Type _}
    [∀ i, TopologicalSpace (π i)] (i : Fin (n + 1)) {f : α → π i} {a : α} {s : Set α}
    (hf : ContinuousWithinAt f s a) {g : α → ∀ j : Fin n, π (i.succAboveEmb j)}
    (hg : ContinuousWithinAt g s a) : ContinuousWithinAt (fun a => i.insertNth (f a) (g a)) s a :=
  hf.fin_insertNth i hg
#align continuous_within_at.fin_insert_nth ContinuousWithinAt.fin_insertNth
-/

#print ContinuousOn.fin_insertNth /-
theorem ContinuousOn.fin_insertNth {n} {π : Fin (n + 1) → Type _} [∀ i, TopologicalSpace (π i)]
    (i : Fin (n + 1)) {f : α → π i} {s : Set α} (hf : ContinuousOn f s)
    {g : α → ∀ j : Fin n, π (i.succAboveEmb j)} (hg : ContinuousOn g s) :
    ContinuousOn (fun a => i.insertNth (f a) (g a)) s := fun a ha =>
  (hf a ha).fin_insertNth i (hg a ha)
#align continuous_on.fin_insert_nth ContinuousOn.fin_insertNth
-/

#print continuousOn_iff /-
theorem continuousOn_iff {f : α → β} {s : Set α} :
    ContinuousOn f s ↔
      ∀ x ∈ s, ∀ t : Set β, IsOpen t → f x ∈ t → ∃ u, IsOpen u ∧ x ∈ u ∧ u ∩ s ⊆ f ⁻¹' t :=
  by simp only [ContinuousOn, ContinuousWithinAt, tendsto_nhds, mem_nhdsWithin]
#align continuous_on_iff continuousOn_iff
-/

#print continuousOn_iff_continuous_restrict /-
theorem continuousOn_iff_continuous_restrict {f : α → β} {s : Set α} :
    ContinuousOn f s ↔ Continuous (s.restrict f) :=
  by
  rw [ContinuousOn, continuous_iff_continuousAt]; constructor
  · rintro h ⟨x, xs⟩
    exact (continuousWithinAt_iff_continuousAt_restrict f xs).mp (h x xs)
  intro h x xs
  exact (continuousWithinAt_iff_continuousAt_restrict f xs).mpr (h ⟨x, xs⟩)
#align continuous_on_iff_continuous_restrict continuousOn_iff_continuous_restrict
-/

#print continuousOn_iff' /-
theorem continuousOn_iff' {f : α → β} {s : Set α} :
    ContinuousOn f s ↔ ∀ t : Set β, IsOpen t → ∃ u, IsOpen u ∧ f ⁻¹' t ∩ s = u ∩ s :=
  by
  have : ∀ t, IsOpen (s.restrict f ⁻¹' t) ↔ ∃ u : Set α, IsOpen u ∧ f ⁻¹' t ∩ s = u ∩ s :=
    by
    intro t
    rw [isOpen_induced_iff, Set.restrict_eq, Set.preimage_comp]
    simp only [Subtype.preimage_coe_eq_preimage_coe_iff]
    constructor <;> · rintro ⟨u, ou, useq⟩; exact ⟨u, ou, useq.symm⟩
  rw [continuousOn_iff_continuous_restrict, continuous_def] <;> simp only [this]
#align continuous_on_iff' continuousOn_iff'
-/

#print ContinuousOn.mono_dom /-
/-- If a function is continuous on a set for some topologies, then it is
continuous on the same set with respect to any finer topology on the source space. -/
theorem ContinuousOn.mono_dom {α β : Type _} {t₁ t₂ : TopologicalSpace α} {t₃ : TopologicalSpace β}
    (h₁ : t₂ ≤ t₁) {s : Set α} {f : α → β} (h₂ : @ContinuousOn α β t₁ t₃ f s) :
    @ContinuousOn α β t₂ t₃ f s :=
  by
  rw [continuousOn_iff'] at h₂ ⊢
  intro t ht
  rcases h₂ t ht with ⟨u, hu, h'u⟩
  exact ⟨u, h₁ u hu, h'u⟩
#align continuous_on.mono_dom ContinuousOn.mono_dom
-/

#print ContinuousOn.mono_rng /-
/-- If a function is continuous on a set for some topologies, then it is
continuous on the same set with respect to any coarser topology on the target space. -/
theorem ContinuousOn.mono_rng {α β : Type _} {t₁ : TopologicalSpace α} {t₂ t₃ : TopologicalSpace β}
    (h₁ : t₂ ≤ t₃) {s : Set α} {f : α → β} (h₂ : @ContinuousOn α β t₁ t₂ f s) :
    @ContinuousOn α β t₁ t₃ f s :=
  by
  rw [continuousOn_iff'] at h₂ ⊢
  intro t ht
  exact h₂ t (h₁ t ht)
#align continuous_on.mono_rng ContinuousOn.mono_rng
-/

#print continuousOn_iff_isClosed /-
theorem continuousOn_iff_isClosed {f : α → β} {s : Set α} :
    ContinuousOn f s ↔ ∀ t : Set β, IsClosed t → ∃ u, IsClosed u ∧ f ⁻¹' t ∩ s = u ∩ s :=
  by
  have : ∀ t, IsClosed (s.restrict f ⁻¹' t) ↔ ∃ u : Set α, IsClosed u ∧ f ⁻¹' t ∩ s = u ∩ s :=
    by
    intro t
    rw [isClosed_induced_iff, Set.restrict_eq, Set.preimage_comp]
    simp only [Subtype.preimage_coe_eq_preimage_coe_iff, eq_comm]
  rw [continuousOn_iff_continuous_restrict, continuous_iff_isClosed] <;> simp only [this]
#align continuous_on_iff_is_closed continuousOn_iff_isClosed
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ContinuousOn.prod_map /-
theorem ContinuousOn.prod_map {f : α → γ} {g : β → δ} {s : Set α} {t : Set β}
    (hf : ContinuousOn f s) (hg : ContinuousOn g t) : ContinuousOn (Prod.map f g) (s ×ˢ t) :=
  fun ⟨x, y⟩ ⟨hx, hy⟩ => ContinuousWithinAt.prod_map (hf x hx) (hg y hy)
#align continuous_on.prod_map ContinuousOn.prod_map
-/

#print continuous_of_cover_nhds /-
theorem continuous_of_cover_nhds {ι : Sort _} {f : α → β} {s : ι → Set α}
    (hs : ∀ x : α, ∃ i, s i ∈ 𝓝 x) (hf : ∀ i, ContinuousOn f (s i)) : Continuous f :=
  continuous_iff_continuousAt.mpr fun x =>
    by
    let ⟨i, hi⟩ := hs x
    rw [ContinuousAt, ← nhdsWithin_eq_nhds.2 hi]; exact hf _ _ (mem_of_mem_nhds hi)
#align continuous_of_cover_nhds continuous_of_cover_nhds
-/

#print continuousOn_empty /-
theorem continuousOn_empty (f : α → β) : ContinuousOn f ∅ := fun x => False.elim
#align continuous_on_empty continuousOn_empty
-/

#print continuousOn_singleton /-
theorem continuousOn_singleton (f : α → β) (a : α) : ContinuousOn f {a} :=
  forall_eq.2 <| by
    simpa only [ContinuousWithinAt, nhdsWithin_singleton, tendsto_pure_left] using fun s =>
      mem_of_mem_nhds
#align continuous_on_singleton continuousOn_singleton
-/

#print Set.Subsingleton.continuousOn /-
theorem Set.Subsingleton.continuousOn {s : Set α} (hs : s.Subsingleton) (f : α → β) :
    ContinuousOn f s :=
  hs.inductionOn (continuousOn_empty f) (continuousOn_singleton f)
#align set.subsingleton.continuous_on Set.Subsingleton.continuousOn
-/

#print nhdsWithin_le_comap /-
theorem nhdsWithin_le_comap {x : α} {s : Set α} {f : α → β} (ctsf : ContinuousWithinAt f s x) :
    𝓝[s] x ≤ comap f (𝓝[f '' s] f x) :=
  ctsf.tendsto_nhdsWithin_image.le_comap
#align nhds_within_le_comap nhdsWithin_le_comap
-/

#print comap_nhdsWithin_range /-
@[simp]
theorem comap_nhdsWithin_range {α} (f : α → β) (y : β) : comap f (𝓝[range f] y) = comap f (𝓝 y) :=
  comap_inf_principal_range
#align comap_nhds_within_range comap_nhdsWithin_range
-/

#print continuous_iff_continuousOn_univ /-
theorem continuous_iff_continuousOn_univ {f : α → β} : Continuous f ↔ ContinuousOn f univ := by
  simp [continuous_iff_continuousAt, ContinuousOn, ContinuousAt, ContinuousWithinAt,
    nhdsWithin_univ]
#align continuous_iff_continuous_on_univ continuous_iff_continuousOn_univ
-/

#print ContinuousWithinAt.mono /-
theorem ContinuousWithinAt.mono {f : α → β} {s t : Set α} {x : α} (h : ContinuousWithinAt f t x)
    (hs : s ⊆ t) : ContinuousWithinAt f s x :=
  h.mono_left (nhdsWithin_mono x hs)
#align continuous_within_at.mono ContinuousWithinAt.mono
-/

#print ContinuousWithinAt.mono_of_mem /-
theorem ContinuousWithinAt.mono_of_mem {f : α → β} {s t : Set α} {x : α}
    (h : ContinuousWithinAt f t x) (hs : t ∈ 𝓝[s] x) : ContinuousWithinAt f s x :=
  h.mono_left (nhdsWithin_le_of_mem hs)
#align continuous_within_at.mono_of_mem ContinuousWithinAt.mono_of_mem
-/

#print continuousWithinAt_inter' /-
theorem continuousWithinAt_inter' {f : α → β} {s t : Set α} {x : α} (h : t ∈ 𝓝[s] x) :
    ContinuousWithinAt f (s ∩ t) x ↔ ContinuousWithinAt f s x := by
  simp [ContinuousWithinAt, nhdsWithin_restrict'' s h]
#align continuous_within_at_inter' continuousWithinAt_inter'
-/

#print continuousWithinAt_inter /-
theorem continuousWithinAt_inter {f : α → β} {s t : Set α} {x : α} (h : t ∈ 𝓝 x) :
    ContinuousWithinAt f (s ∩ t) x ↔ ContinuousWithinAt f s x := by
  simp [ContinuousWithinAt, nhdsWithin_restrict' s h]
#align continuous_within_at_inter continuousWithinAt_inter
-/

#print continuousWithinAt_union /-
theorem continuousWithinAt_union {f : α → β} {s t : Set α} {x : α} :
    ContinuousWithinAt f (s ∪ t) x ↔ ContinuousWithinAt f s x ∧ ContinuousWithinAt f t x := by
  simp only [ContinuousWithinAt, nhdsWithin_union, tendsto_sup]
#align continuous_within_at_union continuousWithinAt_union
-/

#print ContinuousWithinAt.union /-
theorem ContinuousWithinAt.union {f : α → β} {s t : Set α} {x : α} (hs : ContinuousWithinAt f s x)
    (ht : ContinuousWithinAt f t x) : ContinuousWithinAt f (s ∪ t) x :=
  continuousWithinAt_union.2 ⟨hs, ht⟩
#align continuous_within_at.union ContinuousWithinAt.union
-/

#print ContinuousWithinAt.mem_closure_image /-
theorem ContinuousWithinAt.mem_closure_image {f : α → β} {s : Set α} {x : α}
    (h : ContinuousWithinAt f s x) (hx : x ∈ closure s) : f x ∈ closure (f '' s) :=
  haveI := mem_closure_iff_nhdsWithin_neBot.1 hx
  mem_closure_of_tendsto h <| mem_of_superset self_mem_nhdsWithin (subset_preimage_image f s)
#align continuous_within_at.mem_closure_image ContinuousWithinAt.mem_closure_image
-/

#print ContinuousWithinAt.mem_closure /-
theorem ContinuousWithinAt.mem_closure {f : α → β} {s : Set α} {x : α} {A : Set β}
    (h : ContinuousWithinAt f s x) (hx : x ∈ closure s) (hA : MapsTo f s A) : f x ∈ closure A :=
  closure_mono (image_subset_iff.2 hA) (h.mem_closure_image hx)
#align continuous_within_at.mem_closure ContinuousWithinAt.mem_closure
-/

#print Set.MapsTo.closure_of_continuousWithinAt /-
theorem Set.MapsTo.closure_of_continuousWithinAt {f : α → β} {s : Set α} {t : Set β}
    (h : MapsTo f s t) (hc : ∀ x ∈ closure s, ContinuousWithinAt f s x) :
    MapsTo f (closure s) (closure t) := fun x hx => (hc x hx).mem_closure hx h
#align set.maps_to.closure_of_continuous_within_at Set.MapsTo.closure_of_continuousWithinAt
-/

#print Set.MapsTo.closure_of_continuousOn /-
theorem Set.MapsTo.closure_of_continuousOn {f : α → β} {s : Set α} {t : Set β} (h : MapsTo f s t)
    (hc : ContinuousOn f (closure s)) : MapsTo f (closure s) (closure t) :=
  h.closure_of_continuousWithinAt fun x hx => (hc x hx).mono subset_closure
#align set.maps_to.closure_of_continuous_on Set.MapsTo.closure_of_continuousOn
-/

#print ContinuousWithinAt.image_closure /-
theorem ContinuousWithinAt.image_closure {f : α → β} {s : Set α}
    (hf : ∀ x ∈ closure s, ContinuousWithinAt f s x) : f '' closure s ⊆ closure (f '' s) :=
  mapsTo'.1 <| (mapsTo_image f s).closure_of_continuousWithinAt hf
#align continuous_within_at.image_closure ContinuousWithinAt.image_closure
-/

#print ContinuousOn.image_closure /-
theorem ContinuousOn.image_closure {f : α → β} {s : Set α} (hf : ContinuousOn f (closure s)) :
    f '' closure s ⊆ closure (f '' s) :=
  ContinuousWithinAt.image_closure fun x hx => (hf x hx).mono subset_closure
#align continuous_on.image_closure ContinuousOn.image_closure
-/

#print continuousWithinAt_singleton /-
@[simp]
theorem continuousWithinAt_singleton {f : α → β} {x : α} : ContinuousWithinAt f {x} x := by
  simp only [ContinuousWithinAt, nhdsWithin_singleton, tendsto_pure_nhds]
#align continuous_within_at_singleton continuousWithinAt_singleton
-/

#print continuousWithinAt_insert_self /-
@[simp]
theorem continuousWithinAt_insert_self {f : α → β} {x : α} {s : Set α} :
    ContinuousWithinAt f (insert x s) x ↔ ContinuousWithinAt f s x := by
  simp only [← singleton_union, continuousWithinAt_union, continuousWithinAt_singleton,
    true_and_iff]
#align continuous_within_at_insert_self continuousWithinAt_insert_self
-/

alias ⟨_, ContinuousWithinAt.insert_self⟩ := continuousWithinAt_insert_self
#align continuous_within_at.insert_self ContinuousWithinAt.insert_self

#print ContinuousWithinAt.diff_iff /-
theorem ContinuousWithinAt.diff_iff {f : α → β} {s t : Set α} {x : α}
    (ht : ContinuousWithinAt f t x) : ContinuousWithinAt f (s \ t) x ↔ ContinuousWithinAt f s x :=
  ⟨fun h => (h.union ht).mono <| by simp only [diff_union_self, subset_union_left], fun h =>
    h.mono (diff_subset _ _)⟩
#align continuous_within_at.diff_iff ContinuousWithinAt.diff_iff
-/

#print continuousWithinAt_diff_self /-
@[simp]
theorem continuousWithinAt_diff_self {f : α → β} {s : Set α} {x : α} :
    ContinuousWithinAt f (s \ {x}) x ↔ ContinuousWithinAt f s x :=
  continuousWithinAt_singleton.diff_iff
#align continuous_within_at_diff_self continuousWithinAt_diff_self
-/

#print continuousWithinAt_compl_self /-
@[simp]
theorem continuousWithinAt_compl_self {f : α → β} {a : α} :
    ContinuousWithinAt f ({a}ᶜ) a ↔ ContinuousAt f a := by
  rw [compl_eq_univ_diff, continuousWithinAt_diff_self, continuousWithinAt_univ]
#align continuous_within_at_compl_self continuousWithinAt_compl_self
-/

#print continuousWithinAt_update_same /-
@[simp]
theorem continuousWithinAt_update_same [DecidableEq α] {f : α → β} {s : Set α} {x : α} {y : β} :
    ContinuousWithinAt (update f x y) s x ↔ Tendsto f (𝓝[s \ {x}] x) (𝓝 y) :=
  calc
    ContinuousWithinAt (update f x y) s x ↔ Tendsto (update f x y) (𝓝[s \ {x}] x) (𝓝 y) := by
      rw [← continuousWithinAt_diff_self, ContinuousWithinAt, Function.update_same]
    _ ↔ Tendsto f (𝓝[s \ {x}] x) (𝓝 y) :=
      tendsto_congr' <|
        eventually_nhdsWithin_iff.2 <| eventually_of_forall fun z hz => update_noteq hz.2 _ _
#align continuous_within_at_update_same continuousWithinAt_update_same
-/

#print continuousAt_update_same /-
@[simp]
theorem continuousAt_update_same [DecidableEq α] {f : α → β} {x : α} {y : β} :
    ContinuousAt (Function.update f x y) x ↔ Tendsto f (𝓝[≠] x) (𝓝 y) := by
  rw [← continuousWithinAt_univ, continuousWithinAt_update_same, compl_eq_univ_diff]
#align continuous_at_update_same continuousAt_update_same
-/

#print IsOpenMap.continuousOn_image_of_leftInvOn /-
theorem IsOpenMap.continuousOn_image_of_leftInvOn {f : α → β} {s : Set α}
    (h : IsOpenMap (s.restrict f)) {finv : β → α} (hleft : LeftInvOn finv f s) :
    ContinuousOn finv (f '' s) :=
  by
  refine' continuousOn_iff'.2 fun t ht => ⟨f '' (t ∩ s), _, _⟩
  · rw [← image_restrict]; exact h _ (ht.preimage continuous_subtype_val)
  · rw [inter_eq_self_of_subset_left (image_subset f (inter_subset_right t s)), hleft.image_inter']
#align is_open_map.continuous_on_image_of_left_inv_on IsOpenMap.continuousOn_image_of_leftInvOn
-/

#print IsOpenMap.continuousOn_range_of_leftInverse /-
theorem IsOpenMap.continuousOn_range_of_leftInverse {f : α → β} (hf : IsOpenMap f) {finv : β → α}
    (hleft : Function.LeftInverse finv f) : ContinuousOn finv (range f) :=
  by
  rw [← image_univ]
  exact (hf.restrict isOpen_univ).continuousOn_image_of_leftInvOn fun x _ => hleft x
#align is_open_map.continuous_on_range_of_left_inverse IsOpenMap.continuousOn_range_of_leftInverse
-/

#print ContinuousOn.congr_mono /-
theorem ContinuousOn.congr_mono {f g : α → β} {s s₁ : Set α} (h : ContinuousOn f s)
    (h' : EqOn g f s₁) (h₁ : s₁ ⊆ s) : ContinuousOn g s₁ :=
  by
  intro x hx
  unfold ContinuousWithinAt
  have A := (h x (h₁ hx)).mono h₁
  unfold ContinuousWithinAt at A 
  rw [← h' hx] at A 
  exact A.congr' h'.eventually_eq_nhds_within.symm
#align continuous_on.congr_mono ContinuousOn.congr_mono
-/

#print ContinuousOn.congr /-
theorem ContinuousOn.congr {f g : α → β} {s : Set α} (h : ContinuousOn f s) (h' : EqOn g f s) :
    ContinuousOn g s :=
  h.congr_mono h' (Subset.refl _)
#align continuous_on.congr ContinuousOn.congr
-/

#print continuousOn_congr /-
theorem continuousOn_congr {f g : α → β} {s : Set α} (h' : EqOn g f s) :
    ContinuousOn g s ↔ ContinuousOn f s :=
  ⟨fun h => ContinuousOn.congr h h'.symm, fun h => h.congr h'⟩
#align continuous_on_congr continuousOn_congr
-/

#print ContinuousAt.continuousWithinAt /-
theorem ContinuousAt.continuousWithinAt {f : α → β} {s : Set α} {x : α} (h : ContinuousAt f x) :
    ContinuousWithinAt f s x :=
  ContinuousWithinAt.mono ((continuousWithinAt_univ f x).2 h) (subset_univ _)
#align continuous_at.continuous_within_at ContinuousAt.continuousWithinAt
-/

#print continuousWithinAt_iff_continuousAt /-
theorem continuousWithinAt_iff_continuousAt {f : α → β} {s : Set α} {x : α} (h : s ∈ 𝓝 x) :
    ContinuousWithinAt f s x ↔ ContinuousAt f x := by
  rw [← univ_inter s, continuousWithinAt_inter h, continuousWithinAt_univ]
#align continuous_within_at_iff_continuous_at continuousWithinAt_iff_continuousAt
-/

#print ContinuousWithinAt.continuousAt /-
theorem ContinuousWithinAt.continuousAt {f : α → β} {s : Set α} {x : α}
    (h : ContinuousWithinAt f s x) (hs : s ∈ 𝓝 x) : ContinuousAt f x :=
  (continuousWithinAt_iff_continuousAt hs).mp h
#align continuous_within_at.continuous_at ContinuousWithinAt.continuousAt
-/

#print IsOpen.continuousOn_iff /-
theorem IsOpen.continuousOn_iff {f : α → β} {s : Set α} (hs : IsOpen s) :
    ContinuousOn f s ↔ ∀ ⦃a⦄, a ∈ s → ContinuousAt f a :=
  ball_congr fun _ => continuousWithinAt_iff_continuousAt ∘ hs.mem_nhds
#align is_open.continuous_on_iff IsOpen.continuousOn_iff
-/

#print ContinuousOn.continuousAt /-
theorem ContinuousOn.continuousAt {f : α → β} {s : Set α} {x : α} (h : ContinuousOn f s)
    (hx : s ∈ 𝓝 x) : ContinuousAt f x :=
  (h x (mem_of_mem_nhds hx)).ContinuousAt hx
#align continuous_on.continuous_at ContinuousOn.continuousAt
-/

#print ContinuousAt.continuousOn /-
theorem ContinuousAt.continuousOn {f : α → β} {s : Set α} (hcont : ∀ x ∈ s, ContinuousAt f x) :
    ContinuousOn f s := fun x hx => (hcont x hx).ContinuousWithinAt
#align continuous_at.continuous_on ContinuousAt.continuousOn
-/

#print ContinuousWithinAt.comp /-
theorem ContinuousWithinAt.comp {g : β → γ} {f : α → β} {s : Set α} {t : Set β} {x : α}
    (hg : ContinuousWithinAt g t (f x)) (hf : ContinuousWithinAt f s x) (h : MapsTo f s t) :
    ContinuousWithinAt (g ∘ f) s x :=
  hg.Tendsto.comp (hf.tendsto_nhdsWithin h)
#align continuous_within_at.comp ContinuousWithinAt.comp
-/

#print ContinuousWithinAt.comp' /-
theorem ContinuousWithinAt.comp' {g : β → γ} {f : α → β} {s : Set α} {t : Set β} {x : α}
    (hg : ContinuousWithinAt g t (f x)) (hf : ContinuousWithinAt f s x) :
    ContinuousWithinAt (g ∘ f) (s ∩ f ⁻¹' t) x :=
  hg.comp (hf.mono (inter_subset_left _ _)) (inter_subset_right _ _)
#align continuous_within_at.comp' ContinuousWithinAt.comp'
-/

#print ContinuousAt.comp_continuousWithinAt /-
theorem ContinuousAt.comp_continuousWithinAt {g : β → γ} {f : α → β} {s : Set α} {x : α}
    (hg : ContinuousAt g (f x)) (hf : ContinuousWithinAt f s x) : ContinuousWithinAt (g ∘ f) s x :=
  hg.ContinuousWithinAt.comp hf (mapsTo_univ _ _)
#align continuous_at.comp_continuous_within_at ContinuousAt.comp_continuousWithinAt
-/

#print ContinuousOn.comp /-
theorem ContinuousOn.comp {g : β → γ} {f : α → β} {s : Set α} {t : Set β} (hg : ContinuousOn g t)
    (hf : ContinuousOn f s) (h : MapsTo f s t) : ContinuousOn (g ∘ f) s := fun x hx =>
  ContinuousWithinAt.comp (hg _ (h hx)) (hf x hx) h
#align continuous_on.comp ContinuousOn.comp
-/

#print ContinuousOn.mono /-
theorem ContinuousOn.mono {f : α → β} {s t : Set α} (hf : ContinuousOn f s) (h : t ⊆ s) :
    ContinuousOn f t := fun x hx => (hf x (h hx)).mono_left (nhdsWithin_mono _ h)
#align continuous_on.mono ContinuousOn.mono
-/

#print antitone_continuousOn /-
theorem antitone_continuousOn {f : α → β} : Antitone (ContinuousOn f) := fun s t hst hf =>
  hf.mono hst
#align antitone_continuous_on antitone_continuousOn
-/

#print ContinuousOn.comp' /-
theorem ContinuousOn.comp' {g : β → γ} {f : α → β} {s : Set α} {t : Set β} (hg : ContinuousOn g t)
    (hf : ContinuousOn f s) : ContinuousOn (g ∘ f) (s ∩ f ⁻¹' t) :=
  hg.comp (hf.mono (inter_subset_left _ _)) (inter_subset_right _ _)
#align continuous_on.comp' ContinuousOn.comp'
-/

#print Continuous.continuousOn /-
theorem Continuous.continuousOn {f : α → β} {s : Set α} (h : Continuous f) : ContinuousOn f s :=
  by
  rw [continuous_iff_continuousOn_univ] at h 
  exact h.mono (subset_univ _)
#align continuous.continuous_on Continuous.continuousOn
-/

#print Continuous.continuousWithinAt /-
theorem Continuous.continuousWithinAt {f : α → β} {s : Set α} {x : α} (h : Continuous f) :
    ContinuousWithinAt f s x :=
  h.ContinuousAt.ContinuousWithinAt
#align continuous.continuous_within_at Continuous.continuousWithinAt
-/

#print Continuous.comp_continuousOn /-
theorem Continuous.comp_continuousOn {g : β → γ} {f : α → β} {s : Set α} (hg : Continuous g)
    (hf : ContinuousOn f s) : ContinuousOn (g ∘ f) s :=
  hg.ContinuousOn.comp hf (mapsTo_univ _ _)
#align continuous.comp_continuous_on Continuous.comp_continuousOn
-/

#print ContinuousOn.comp_continuous /-
theorem ContinuousOn.comp_continuous {g : β → γ} {f : α → β} {s : Set β} (hg : ContinuousOn g s)
    (hf : Continuous f) (hs : ∀ x, f x ∈ s) : Continuous (g ∘ f) :=
  by
  rw [continuous_iff_continuousOn_univ] at *
  exact hg.comp hf fun x _ => hs x
#align continuous_on.comp_continuous ContinuousOn.comp_continuous
-/

#print ContinuousWithinAt.preimage_mem_nhdsWithin /-
theorem ContinuousWithinAt.preimage_mem_nhdsWithin {f : α → β} {x : α} {s : Set α} {t : Set β}
    (h : ContinuousWithinAt f s x) (ht : t ∈ 𝓝 (f x)) : f ⁻¹' t ∈ 𝓝[s] x :=
  h ht
#align continuous_within_at.preimage_mem_nhds_within ContinuousWithinAt.preimage_mem_nhdsWithin
-/

#print Set.LeftInvOn.map_nhdsWithin_eq /-
theorem Set.LeftInvOn.map_nhdsWithin_eq {f : α → β} {g : β → α} {x : β} {s : Set β}
    (h : LeftInvOn f g s) (hx : f (g x) = x) (hf : ContinuousWithinAt f (g '' s) (g x))
    (hg : ContinuousWithinAt g s x) : map g (𝓝[s] x) = 𝓝[g '' s] g x :=
  by
  apply le_antisymm
  · exact hg.tendsto_nhds_within (maps_to_image _ _)
  · have A : g ∘ f =ᶠ[𝓝[g '' s] g x] id :=
      h.right_inv_on_image.eq_on.eventually_eq_of_mem self_mem_nhdsWithin
    refine' le_map_of_right_inverse A _
    simpa only [hx] using hf.tendsto_nhds_within (h.maps_to (surj_on_image _ _))
#align set.left_inv_on.map_nhds_within_eq Set.LeftInvOn.map_nhdsWithin_eq
-/

#print Function.LeftInverse.map_nhds_eq /-
theorem Function.LeftInverse.map_nhds_eq {f : α → β} {g : β → α} {x : β}
    (h : Function.LeftInverse f g) (hf : ContinuousWithinAt f (range g) (g x))
    (hg : ContinuousAt g x) : map g (𝓝 x) = 𝓝[range g] g x := by
  simpa only [nhdsWithin_univ, image_univ] using
    (h.left_inv_on univ).map_nhdsWithin_eq (h x) (by rwa [image_univ]) hg.continuous_within_at
#align function.left_inverse.map_nhds_eq Function.LeftInverse.map_nhds_eq
-/

#print ContinuousWithinAt.preimage_mem_nhdsWithin' /-
theorem ContinuousWithinAt.preimage_mem_nhdsWithin' {f : α → β} {x : α} {s : Set α} {t : Set β}
    (h : ContinuousWithinAt f s x) (ht : t ∈ 𝓝[f '' s] f x) : f ⁻¹' t ∈ 𝓝[s] x :=
  h.tendsto_nhdsWithin (mapsTo_image _ _) ht
#align continuous_within_at.preimage_mem_nhds_within' ContinuousWithinAt.preimage_mem_nhdsWithin'
-/

#print Filter.EventuallyEq.congr_continuousWithinAt /-
theorem Filter.EventuallyEq.congr_continuousWithinAt {f g : α → β} {s : Set α} {x : α}
    (h : f =ᶠ[𝓝[s] x] g) (hx : f x = g x) : ContinuousWithinAt f s x ↔ ContinuousWithinAt g s x :=
  by rw [ContinuousWithinAt, hx, tendsto_congr' h, ContinuousWithinAt]
#align filter.eventually_eq.congr_continuous_within_at Filter.EventuallyEq.congr_continuousWithinAt
-/

#print ContinuousWithinAt.congr_of_eventuallyEq /-
theorem ContinuousWithinAt.congr_of_eventuallyEq {f f₁ : α → β} {s : Set α} {x : α}
    (h : ContinuousWithinAt f s x) (h₁ : f₁ =ᶠ[𝓝[s] x] f) (hx : f₁ x = f x) :
    ContinuousWithinAt f₁ s x :=
  (h₁.congr_continuousWithinAt hx).2 h
#align continuous_within_at.congr_of_eventually_eq ContinuousWithinAt.congr_of_eventuallyEq
-/

#print ContinuousWithinAt.congr /-
theorem ContinuousWithinAt.congr {f f₁ : α → β} {s : Set α} {x : α} (h : ContinuousWithinAt f s x)
    (h₁ : ∀ y ∈ s, f₁ y = f y) (hx : f₁ x = f x) : ContinuousWithinAt f₁ s x :=
  h.congr_of_eventuallyEq (mem_of_superset self_mem_nhdsWithin h₁) hx
#align continuous_within_at.congr ContinuousWithinAt.congr
-/

#print ContinuousWithinAt.congr_mono /-
theorem ContinuousWithinAt.congr_mono {f g : α → β} {s s₁ : Set α} {x : α}
    (h : ContinuousWithinAt f s x) (h' : EqOn g f s₁) (h₁ : s₁ ⊆ s) (hx : g x = f x) :
    ContinuousWithinAt g s₁ x :=
  (h.mono h₁).congr h' hx
#align continuous_within_at.congr_mono ContinuousWithinAt.congr_mono
-/

#print continuousOn_const /-
theorem continuousOn_const {s : Set α} {c : β} : ContinuousOn (fun x => c) s :=
  continuous_const.ContinuousOn
#align continuous_on_const continuousOn_const
-/

#print continuousWithinAt_const /-
theorem continuousWithinAt_const {b : β} {s : Set α} {x : α} :
    ContinuousWithinAt (fun _ : α => b) s x :=
  continuous_const.ContinuousWithinAt
#align continuous_within_at_const continuousWithinAt_const
-/

#print continuousOn_id /-
theorem continuousOn_id {s : Set α} : ContinuousOn id s :=
  continuous_id.ContinuousOn
#align continuous_on_id continuousOn_id
-/

#print continuousWithinAt_id /-
theorem continuousWithinAt_id {s : Set α} {x : α} : ContinuousWithinAt id s x :=
  continuous_id.ContinuousWithinAt
#align continuous_within_at_id continuousWithinAt_id
-/

#print continuousOn_open_iff /-
theorem continuousOn_open_iff {f : α → β} {s : Set α} (hs : IsOpen s) :
    ContinuousOn f s ↔ ∀ t, IsOpen t → IsOpen (s ∩ f ⁻¹' t) :=
  by
  rw [continuousOn_iff']
  constructor
  · intro h t ht
    rcases h t ht with ⟨u, u_open, hu⟩
    rw [inter_comm, hu]
    apply IsOpen.inter u_open hs
  · intro h t ht
    refine' ⟨s ∩ f ⁻¹' t, h t ht, _⟩
    rw [@inter_comm _ s (f ⁻¹' t), inter_assoc, inter_self]
#align continuous_on_open_iff continuousOn_open_iff
-/

#print ContinuousOn.isOpen_inter_preimage /-
theorem ContinuousOn.isOpen_inter_preimage {f : α → β} {s : Set α} {t : Set β}
    (hf : ContinuousOn f s) (hs : IsOpen s) (ht : IsOpen t) : IsOpen (s ∩ f ⁻¹' t) :=
  (continuousOn_open_iff hs).1 hf t ht
#align continuous_on.preimage_open_of_open ContinuousOn.isOpen_inter_preimage
-/

#print ContinuousOn.isOpen_preimage /-
theorem ContinuousOn.isOpen_preimage {f : α → β} {s : Set α} {t : Set β} (h : ContinuousOn f s)
    (hs : IsOpen s) (hp : f ⁻¹' t ⊆ s) (ht : IsOpen t) : IsOpen (f ⁻¹' t) :=
  by
  convert (continuousOn_open_iff hs).mp h t ht
  rw [inter_comm, inter_eq_self_of_subset_left hp]
#align continuous_on.is_open_preimage ContinuousOn.isOpen_preimage
-/

#print ContinuousOn.preimage_isClosed_of_isClosed /-
theorem ContinuousOn.preimage_isClosed_of_isClosed {f : α → β} {s : Set α} {t : Set β}
    (hf : ContinuousOn f s) (hs : IsClosed s) (ht : IsClosed t) : IsClosed (s ∩ f ⁻¹' t) :=
  by
  rcases continuousOn_iff_isClosed.1 hf t ht with ⟨u, hu⟩
  rw [inter_comm, hu.2]
  apply IsClosed.inter hu.1 hs
#align continuous_on.preimage_closed_of_closed ContinuousOn.preimage_isClosed_of_isClosed
-/

#print ContinuousOn.preimage_interior_subset_interior_preimage /-
theorem ContinuousOn.preimage_interior_subset_interior_preimage {f : α → β} {s : Set α} {t : Set β}
    (hf : ContinuousOn f s) (hs : IsOpen s) : s ∩ f ⁻¹' interior t ⊆ s ∩ interior (f ⁻¹' t) :=
  calc
    s ∩ f ⁻¹' interior t ⊆ interior (s ∩ f ⁻¹' t) :=
      interior_maximal (inter_subset_inter (Subset.refl _) (preimage_mono interior_subset))
        (hf.isOpen_inter_preimage hs isOpen_interior)
    _ = s ∩ interior (f ⁻¹' t) := by rw [interior_inter, hs.interior_eq]
#align continuous_on.preimage_interior_subset_interior_preimage ContinuousOn.preimage_interior_subset_interior_preimage
-/

#print continuousOn_of_locally_continuousOn /-
theorem continuousOn_of_locally_continuousOn {f : α → β} {s : Set α}
    (h : ∀ x ∈ s, ∃ t, IsOpen t ∧ x ∈ t ∧ ContinuousOn f (s ∩ t)) : ContinuousOn f s :=
  by
  intro x xs
  rcases h x xs with ⟨t, open_t, xt, ct⟩
  have := ct x ⟨xs, xt⟩
  rwa [ContinuousWithinAt, ← nhdsWithin_restrict _ xt open_t] at this 
#align continuous_on_of_locally_continuous_on continuousOn_of_locally_continuousOn
-/

theorem continuousOn_isOpen_of_generateFrom {β : Type _} {s : Set α} {T : Set (Set β)} {f : α → β}
    (hs : IsOpen s) (h : ∀ t ∈ T, IsOpen (s ∩ f ⁻¹' t)) :
    @ContinuousOn α β _ (TopologicalSpace.generateFrom T) f s :=
  by
  rw [continuousOn_open_iff]
  intro t ht
  induction' ht with u hu u v Tu Tv hu hv U hU hU'
  · exact h u hu
  · simp only [preimage_univ, inter_univ]; exact hs
  · have : s ∩ f ⁻¹' (u ∩ v) = s ∩ f ⁻¹' u ∩ (s ∩ f ⁻¹' v) := by
      rw [preimage_inter, inter_assoc, inter_left_comm _ s, ← inter_assoc s s, inter_self]
    rw [this]
    exact hu.inter hv
  · rw [preimage_sUnion, inter_Union₂]
    exact isOpen_biUnion hU'
  · exact hs
#align continuous_on_open_of_generate_from continuousOn_isOpen_of_generateFromₓ

#print ContinuousWithinAt.prod /-
theorem ContinuousWithinAt.prod {f : α → β} {g : α → γ} {s : Set α} {x : α}
    (hf : ContinuousWithinAt f s x) (hg : ContinuousWithinAt g s x) :
    ContinuousWithinAt (fun x => (f x, g x)) s x :=
  hf.prod_mk_nhds hg
#align continuous_within_at.prod ContinuousWithinAt.prod
-/

#print ContinuousOn.prod /-
theorem ContinuousOn.prod {f : α → β} {g : α → γ} {s : Set α} (hf : ContinuousOn f s)
    (hg : ContinuousOn g s) : ContinuousOn (fun x => (f x, g x)) s := fun x hx =>
  ContinuousWithinAt.prod (hf x hx) (hg x hx)
#align continuous_on.prod ContinuousOn.prod
-/

#print Inducing.continuousWithinAt_iff /-
theorem Inducing.continuousWithinAt_iff {f : α → β} {g : β → γ} (hg : Inducing g) {s : Set α}
    {x : α} : ContinuousWithinAt f s x ↔ ContinuousWithinAt (g ∘ f) s x := by
  simp_rw [ContinuousWithinAt, Inducing.tendsto_nhds_iff hg]
#align inducing.continuous_within_at_iff Inducing.continuousWithinAt_iff
-/

#print Inducing.continuousOn_iff /-
theorem Inducing.continuousOn_iff {f : α → β} {g : β → γ} (hg : Inducing g) {s : Set α} :
    ContinuousOn f s ↔ ContinuousOn (g ∘ f) s := by
  simp_rw [ContinuousOn, hg.continuous_within_at_iff]
#align inducing.continuous_on_iff Inducing.continuousOn_iff
-/

#print Embedding.continuousOn_iff /-
theorem Embedding.continuousOn_iff {f : α → β} {g : β → γ} (hg : Embedding g) {s : Set α} :
    ContinuousOn f s ↔ ContinuousOn (g ∘ f) s :=
  Inducing.continuousOn_iff hg.1
#align embedding.continuous_on_iff Embedding.continuousOn_iff
-/

#print Embedding.map_nhdsWithin_eq /-
theorem Embedding.map_nhdsWithin_eq {f : α → β} (hf : Embedding f) (s : Set α) (x : α) :
    map f (𝓝[s] x) = 𝓝[f '' s] f x := by
  rw [nhdsWithin, map_inf hf.inj, hf.map_nhds_eq, map_principal, ← nhdsWithin_inter',
    inter_eq_self_of_subset_right (image_subset_range _ _)]
#align embedding.map_nhds_within_eq Embedding.map_nhdsWithin_eq
-/

#print OpenEmbedding.map_nhdsWithin_preimage_eq /-
theorem OpenEmbedding.map_nhdsWithin_preimage_eq {f : α → β} (hf : OpenEmbedding f) (s : Set β)
    (x : α) : map f (𝓝[f ⁻¹' s] x) = 𝓝[s] f x :=
  by
  rw [hf.to_embedding.map_nhds_within_eq, image_preimage_eq_inter_range]
  apply nhdsWithin_eq_nhdsWithin (mem_range_self _) hf.open_range
  rw [inter_assoc, inter_self]
#align open_embedding.map_nhds_within_preimage_eq OpenEmbedding.map_nhdsWithin_preimage_eq
-/

#print continuousWithinAt_of_not_mem_closure /-
theorem continuousWithinAt_of_not_mem_closure {f : α → β} {s : Set α} {x : α} :
    x ∉ closure s → ContinuousWithinAt f s x :=
  by
  intro hx
  rw [mem_closure_iff_nhdsWithin_neBot, ne_bot_iff, Classical.not_not] at hx 
  rw [ContinuousWithinAt, hx]
  exact tendsto_bot
#align continuous_within_at_of_not_mem_closure continuousWithinAt_of_not_mem_closure
-/

#print ContinuousOn.piecewise' /-
theorem ContinuousOn.piecewise' {s t : Set α} {f g : α → β} [∀ a, Decidable (a ∈ t)]
    (hpf : ∀ a ∈ s ∩ frontier t, Tendsto f (𝓝[s ∩ t] a) (𝓝 (piecewise t f g a)))
    (hpg : ∀ a ∈ s ∩ frontier t, Tendsto g (𝓝[s ∩ tᶜ] a) (𝓝 (piecewise t f g a)))
    (hf : ContinuousOn f <| s ∩ t) (hg : ContinuousOn g <| s ∩ tᶜ) :
    ContinuousOn (piecewise t f g) s := by
  intro x hx
  by_cases hx' : x ∈ frontier t
  · exact (hpf x ⟨hx, hx'⟩).piecewise_nhdsWithin (hpg x ⟨hx, hx'⟩)
  · rw [← inter_univ s, ← union_compl_self t, inter_union_distrib_left] at hx ⊢
    cases hx
    · apply ContinuousWithinAt.union
      ·
        exact
          (hf x hx).congr (fun y hy => piecewise_eq_of_mem _ _ _ hy.2)
            (piecewise_eq_of_mem _ _ _ hx.2)
      · have : x ∉ closure (tᶜ) := fun h => hx' ⟨subset_closure hx.2, by rwa [closure_compl] at h ⟩
        exact
          continuousWithinAt_of_not_mem_closure fun h =>
            this (closure_inter_subset_inter_closure _ _ h).2
    · apply ContinuousWithinAt.union
      · have : x ∉ closure t := fun h =>
          hx' ⟨h, fun h' : x ∈ interior t => hx.2 (interior_subset h')⟩
        exact
          continuousWithinAt_of_not_mem_closure fun h =>
            this (closure_inter_subset_inter_closure _ _ h).2
      ·
        exact
          (hg x hx).congr (fun y hy => piecewise_eq_of_not_mem _ _ _ hy.2)
            (piecewise_eq_of_not_mem _ _ _ hx.2)
#align continuous_on.piecewise' ContinuousOn.piecewise'
-/

#print ContinuousOn.if' /-
theorem ContinuousOn.if' {s : Set α} {p : α → Prop} {f g : α → β} [∀ a, Decidable (p a)]
    (hpf :
      ∀ a ∈ s ∩ frontier {a | p a}, Tendsto f (𝓝[s ∩ {a | p a}] a) (𝓝 <| if p a then f a else g a))
    (hpg :
      ∀ a ∈ s ∩ frontier {a | p a}, Tendsto g (𝓝[s ∩ {a | ¬p a}] a) (𝓝 <| if p a then f a else g a))
    (hf : ContinuousOn f <| s ∩ {a | p a}) (hg : ContinuousOn g <| s ∩ {a | ¬p a}) :
    ContinuousOn (fun a => if p a then f a else g a) s :=
  hf.piecewise' hpf hpg hg
#align continuous_on.if' ContinuousOn.if'
-/

#print ContinuousOn.if /-
theorem ContinuousOn.if {α β : Type _} [TopologicalSpace α] [TopologicalSpace β] {p : α → Prop}
    [∀ a, Decidable (p a)] {s : Set α} {f g : α → β} (hp : ∀ a ∈ s ∩ frontier {a | p a}, f a = g a)
    (hf : ContinuousOn f <| s ∩ closure {a | p a}) (hg : ContinuousOn g <| s ∩ closure {a | ¬p a}) :
    ContinuousOn (fun a => if p a then f a else g a) s :=
  by
  apply ContinuousOn.if'
  · rintro a ha
    simp only [← hp a ha, if_t_t]
    apply tendsto_nhdsWithin_mono_left (inter_subset_inter_right s subset_closure)
    exact hf a ⟨ha.1, ha.2.1⟩
  · rintro a ha
    simp only [hp a ha, if_t_t]
    apply tendsto_nhdsWithin_mono_left (inter_subset_inter_right s subset_closure)
    rcases ha with ⟨has, ⟨_, ha⟩⟩
    rw [← mem_compl_iff, ← closure_compl] at ha 
    apply hg a ⟨has, ha⟩
  · exact hf.mono (inter_subset_inter_right s subset_closure)
  · exact hg.mono (inter_subset_inter_right s subset_closure)
#align continuous_on.if ContinuousOn.if
-/

#print ContinuousOn.piecewise /-
theorem ContinuousOn.piecewise {s t : Set α} {f g : α → β} [∀ a, Decidable (a ∈ t)]
    (ht : ∀ a ∈ s ∩ frontier t, f a = g a) (hf : ContinuousOn f <| s ∩ closure t)
    (hg : ContinuousOn g <| s ∩ closure (tᶜ)) : ContinuousOn (piecewise t f g) s :=
  hf.if ht hg
#align continuous_on.piecewise ContinuousOn.piecewise
-/

#print continuous_if' /-
theorem continuous_if' {p : α → Prop} {f g : α → β} [∀ a, Decidable (p a)]
    (hpf : ∀ a ∈ frontier {x | p x}, Tendsto f (𝓝[{x | p x}] a) (𝓝 <| ite (p a) (f a) (g a)))
    (hpg : ∀ a ∈ frontier {x | p x}, Tendsto g (𝓝[{x | ¬p x}] a) (𝓝 <| ite (p a) (f a) (g a)))
    (hf : ContinuousOn f {x | p x}) (hg : ContinuousOn g {x | ¬p x}) :
    Continuous fun a => ite (p a) (f a) (g a) :=
  by
  rw [continuous_iff_continuousOn_univ]
  apply ContinuousOn.if' <;> simp [*] <;> assumption
#align continuous_if' continuous_if'
-/

#print continuous_if /-
theorem continuous_if {p : α → Prop} {f g : α → β} [∀ a, Decidable (p a)]
    (hp : ∀ a ∈ frontier {x | p x}, f a = g a) (hf : ContinuousOn f (closure {x | p x}))
    (hg : ContinuousOn g (closure {x | ¬p x})) : Continuous fun a => if p a then f a else g a :=
  by
  rw [continuous_iff_continuousOn_univ]
  apply ContinuousOn.if <;> simp <;> assumption
#align continuous_if continuous_if
-/

#print Continuous.if /-
theorem Continuous.if {p : α → Prop} {f g : α → β} [∀ a, Decidable (p a)]
    (hp : ∀ a ∈ frontier {x | p x}, f a = g a) (hf : Continuous f) (hg : Continuous g) :
    Continuous fun a => if p a then f a else g a :=
  continuous_if hp hf.ContinuousOn hg.ContinuousOn
#align continuous.if Continuous.if
-/

#print continuous_if_const /-
theorem continuous_if_const (p : Prop) {f g : α → β} [Decidable p] (hf : p → Continuous f)
    (hg : ¬p → Continuous g) : Continuous fun a => if p then f a else g a := by split_ifs;
  exact hf h; exact hg h
#align continuous_if_const continuous_if_const
-/

#print Continuous.if_const /-
theorem Continuous.if_const (p : Prop) {f g : α → β} [Decidable p] (hf : Continuous f)
    (hg : Continuous g) : Continuous fun a => if p then f a else g a :=
  continuous_if_const p (fun _ => hf) fun _ => hg
#align continuous.if_const Continuous.if_const
-/

#print continuous_piecewise /-
theorem continuous_piecewise {s : Set α} {f g : α → β} [∀ a, Decidable (a ∈ s)]
    (hs : ∀ a ∈ frontier s, f a = g a) (hf : ContinuousOn f (closure s))
    (hg : ContinuousOn g (closure (sᶜ))) : Continuous (piecewise s f g) :=
  continuous_if hs hf hg
#align continuous_piecewise continuous_piecewise
-/

#print Continuous.piecewise /-
theorem Continuous.piecewise {s : Set α} {f g : α → β} [∀ a, Decidable (a ∈ s)]
    (hs : ∀ a ∈ frontier s, f a = g a) (hf : Continuous f) (hg : Continuous g) :
    Continuous (piecewise s f g) :=
  hf.if hs hg
#align continuous.piecewise Continuous.piecewise
-/

#print IsOpen.ite' /-
theorem IsOpen.ite' {s s' t : Set α} (hs : IsOpen s) (hs' : IsOpen s')
    (ht : ∀ x ∈ frontier t, x ∈ s ↔ x ∈ s') : IsOpen (t.ite s s') := by
  classical
  simp only [isOpen_iff_continuous_mem, Set.ite] at *
  convert continuous_piecewise (fun x hx => propext (ht x hx)) hs.continuous_on hs'.continuous_on
  ext x
  by_cases hx : x ∈ t <;> simp [hx]
#align is_open.ite' IsOpen.ite'
-/

#print IsOpen.ite /-
theorem IsOpen.ite {s s' t : Set α} (hs : IsOpen s) (hs' : IsOpen s')
    (ht : s ∩ frontier t = s' ∩ frontier t) : IsOpen (t.ite s s') :=
  hs.ite' hs' fun x hx => by simpa [hx] using ext_iff.1 ht x
#align is_open.ite IsOpen.ite
-/

#print ite_inter_closure_eq_of_inter_frontier_eq /-
theorem ite_inter_closure_eq_of_inter_frontier_eq {s s' t : Set α}
    (ht : s ∩ frontier t = s' ∩ frontier t) : t.ite s s' ∩ closure t = s ∩ closure t := by
  rw [closure_eq_self_union_frontier, inter_union_distrib_left, inter_union_distrib_left,
    ite_inter_self, ite_inter_of_inter_eq _ ht]
#align ite_inter_closure_eq_of_inter_frontier_eq ite_inter_closure_eq_of_inter_frontier_eq
-/

#print ite_inter_closure_compl_eq_of_inter_frontier_eq /-
theorem ite_inter_closure_compl_eq_of_inter_frontier_eq {s s' t : Set α}
    (ht : s ∩ frontier t = s' ∩ frontier t) : t.ite s s' ∩ closure (tᶜ) = s' ∩ closure (tᶜ) := by
  rw [← ite_compl, ite_inter_closure_eq_of_inter_frontier_eq]; rwa [frontier_compl, eq_comm]
#align ite_inter_closure_compl_eq_of_inter_frontier_eq ite_inter_closure_compl_eq_of_inter_frontier_eq
-/

#print continuousOn_piecewise_ite' /-
theorem continuousOn_piecewise_ite' {s s' t : Set α} {f f' : α → β} [∀ x, Decidable (x ∈ t)]
    (h : ContinuousOn f (s ∩ closure t)) (h' : ContinuousOn f' (s' ∩ closure (tᶜ)))
    (H : s ∩ frontier t = s' ∩ frontier t) (Heq : EqOn f f' (s ∩ frontier t)) :
    ContinuousOn (t.piecewise f f') (t.ite s s') :=
  by
  apply ContinuousOn.piecewise
  · rwa [ite_inter_of_inter_eq _ H]
  · rwa [ite_inter_closure_eq_of_inter_frontier_eq H]
  · rwa [ite_inter_closure_compl_eq_of_inter_frontier_eq H]
#align continuous_on_piecewise_ite' continuousOn_piecewise_ite'
-/

#print continuousOn_piecewise_ite /-
theorem continuousOn_piecewise_ite {s s' t : Set α} {f f' : α → β} [∀ x, Decidable (x ∈ t)]
    (h : ContinuousOn f s) (h' : ContinuousOn f' s') (H : s ∩ frontier t = s' ∩ frontier t)
    (Heq : EqOn f f' (s ∩ frontier t)) : ContinuousOn (t.piecewise f f') (t.ite s s') :=
  continuousOn_piecewise_ite' (h.mono (inter_subset_left _ _)) (h'.mono (inter_subset_left _ _)) H
    Heq
#align continuous_on_piecewise_ite continuousOn_piecewise_ite
-/

#print frontier_inter_open_inter /-
theorem frontier_inter_open_inter {s t : Set α} (ht : IsOpen t) :
    frontier (s ∩ t) ∩ t = frontier s ∩ t := by
  simp only [← Subtype.preimage_coe_eq_preimage_coe_iff,
    ht.is_open_map_subtype_coe.preimage_frontier_eq_frontier_preimage continuous_subtype_val,
    Subtype.preimage_coe_inter_self]
#align frontier_inter_open_inter frontier_inter_open_inter
-/

#print continuousOn_fst /-
theorem continuousOn_fst {s : Set (α × β)} : ContinuousOn Prod.fst s :=
  continuous_fst.ContinuousOn
#align continuous_on_fst continuousOn_fst
-/

#print continuousWithinAt_fst /-
theorem continuousWithinAt_fst {s : Set (α × β)} {p : α × β} : ContinuousWithinAt Prod.fst s p :=
  continuous_fst.ContinuousWithinAt
#align continuous_within_at_fst continuousWithinAt_fst
-/

#print ContinuousOn.fst /-
theorem ContinuousOn.fst {f : α → β × γ} {s : Set α} (hf : ContinuousOn f s) :
    ContinuousOn (fun x => (f x).1) s :=
  continuous_fst.comp_continuousOn hf
#align continuous_on.fst ContinuousOn.fst
-/

#print ContinuousWithinAt.fst /-
theorem ContinuousWithinAt.fst {f : α → β × γ} {s : Set α} {a : α} (h : ContinuousWithinAt f s a) :
    ContinuousWithinAt (fun x => (f x).fst) s a :=
  continuousAt_fst.comp_continuousWithinAt h
#align continuous_within_at.fst ContinuousWithinAt.fst
-/

#print continuousOn_snd /-
theorem continuousOn_snd {s : Set (α × β)} : ContinuousOn Prod.snd s :=
  continuous_snd.ContinuousOn
#align continuous_on_snd continuousOn_snd
-/

#print continuousWithinAt_snd /-
theorem continuousWithinAt_snd {s : Set (α × β)} {p : α × β} : ContinuousWithinAt Prod.snd s p :=
  continuous_snd.ContinuousWithinAt
#align continuous_within_at_snd continuousWithinAt_snd
-/

#print ContinuousOn.snd /-
theorem ContinuousOn.snd {f : α → β × γ} {s : Set α} (hf : ContinuousOn f s) :
    ContinuousOn (fun x => (f x).2) s :=
  continuous_snd.comp_continuousOn hf
#align continuous_on.snd ContinuousOn.snd
-/

#print ContinuousWithinAt.snd /-
theorem ContinuousWithinAt.snd {f : α → β × γ} {s : Set α} {a : α} (h : ContinuousWithinAt f s a) :
    ContinuousWithinAt (fun x => (f x).snd) s a :=
  continuousAt_snd.comp_continuousWithinAt h
#align continuous_within_at.snd ContinuousWithinAt.snd
-/

#print continuousWithinAt_prod_iff /-
theorem continuousWithinAt_prod_iff {f : α → β × γ} {s : Set α} {x : α} :
    ContinuousWithinAt f s x ↔
      ContinuousWithinAt (Prod.fst ∘ f) s x ∧ ContinuousWithinAt (Prod.snd ∘ f) s x :=
  ⟨fun h => ⟨h.fst, h.snd⟩, by rintro ⟨h1, h2⟩; convert h1.prod h2; ext; rfl; rfl⟩
#align continuous_within_at_prod_iff continuousWithinAt_prod_iff
-/

