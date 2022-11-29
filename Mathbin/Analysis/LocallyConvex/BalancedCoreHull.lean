/-
Copyright (c) 2022 Moritz Doll. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Moritz Doll
-/
import Mathbin.Analysis.LocallyConvex.Basic

/-!
# Balanced Core and Balanced Hull

## Main definitions

* `balanced_core`: The largest balanced subset of a set `s`.
* `balanced_hull`: The smallest balanced superset of a set `s`.

## Main statements

* `balanced_core_eq_Inter`: Characterization of the balanced core as an intersection over subsets.
* `nhds_basis_closed_balanced`: The closed balanced sets form a basis of the neighborhood filter.

## Implementation details

The balanced core and hull are implemented differently: for the core we take the obvious definition
of the union over all balanced sets that are contained in `s`, whereas for the hull, we take the
union over `r • s`, for `r` the scalars with `‖r‖ ≤ 1`. We show that `balanced_hull` has the
defining properties of a hull in `balanced.hull_minimal` and `subset_balanced_hull`.
For the core we need slightly stronger assumptions to obtain a characterization as an intersection,
this is `balanced_core_eq_Inter`.

## References

* [Bourbaki, *Topological Vector Spaces*][bourbaki1987]

## Tags

balanced
-/


open Set

open Pointwise TopologicalSpace Filter

variable {𝕜 E ι : Type _}

section balancedHull

section SemiNormedRing

variable [SemiNormedRing 𝕜]

section HasSmul

variable (𝕜) [HasSmul 𝕜 E] {s t : Set E} {x : E}

/-- The largest balanced subset of `s`.-/
def balancedCore (s : Set E) :=
  ⋃₀{ t : Set E | Balanced 𝕜 t ∧ t ⊆ s }
#align balanced_core balancedCore

/-- Helper definition to prove `balanced_core_eq_Inter`-/
def balancedCoreAux (s : Set E) :=
  ⋂ (r : 𝕜) (hr : 1 ≤ ‖r‖), r • s
#align balanced_core_aux balancedCoreAux

/-- The smallest balanced superset of `s`.-/
def balancedHull (s : Set E) :=
  ⋃ (r : 𝕜) (hr : ‖r‖ ≤ 1), r • s
#align balanced_hull balancedHull

variable {𝕜}

theorem balanced_core_subset (s : Set E) : balancedCore 𝕜 s ⊆ s :=
  sUnion_subset fun t ht => ht.2
#align balanced_core_subset balanced_core_subset

theorem balanced_core_empty : balancedCore 𝕜 (∅ : Set E) = ∅ :=
  eq_empty_of_subset_empty (balanced_core_subset _)
#align balanced_core_empty balanced_core_empty

theorem mem_balanced_core_iff : x ∈ balancedCore 𝕜 s ↔ ∃ t, Balanced 𝕜 t ∧ t ⊆ s ∧ x ∈ t := by
  simp_rw [balancedCore, mem_sUnion, mem_set_of_eq, exists_prop, and_assoc']
#align mem_balanced_core_iff mem_balanced_core_iff

theorem smul_balanced_core_subset (s : Set E) {a : 𝕜} (ha : ‖a‖ ≤ 1) :
    a • balancedCore 𝕜 s ⊆ balancedCore 𝕜 s := by
  rintro x ⟨y, hy, rfl⟩
  rw [mem_balanced_core_iff] at hy
  rcases hy with ⟨t, ht1, ht2, hy⟩
  exact ⟨t, ⟨ht1, ht2⟩, ht1 a ha (smul_mem_smul_set hy)⟩
#align smul_balanced_core_subset smul_balanced_core_subset

theorem balancedCoreBalanced (s : Set E) : Balanced 𝕜 (balancedCore 𝕜 s) := fun _ =>
  smul_balanced_core_subset s
#align balanced_core_balanced balancedCoreBalanced

/-- The balanced core of `t` is maximal in the sense that it contains any balanced subset
`s` of `t`.-/
theorem Balanced.subset_core_of_subset (hs : Balanced 𝕜 s) (h : s ⊆ t) : s ⊆ balancedCore 𝕜 t :=
  subset_sUnion_of_mem ⟨hs, h⟩
#align balanced.subset_core_of_subset Balanced.subset_core_of_subset

theorem mem_balanced_core_aux_iff : x ∈ balancedCoreAux 𝕜 s ↔ ∀ r : 𝕜, 1 ≤ ‖r‖ → x ∈ r • s :=
  mem_Inter₂
#align mem_balanced_core_aux_iff mem_balanced_core_aux_iff

theorem mem_balanced_hull_iff : x ∈ balancedHull 𝕜 s ↔ ∃ (r : 𝕜)(hr : ‖r‖ ≤ 1), x ∈ r • s :=
  mem_Union₂
#align mem_balanced_hull_iff mem_balanced_hull_iff

/-- The balanced hull of `s` is minimal in the sense that it is contained in any balanced superset
`t` of `s`. -/
theorem Balanced.hull_subset_of_subset (ht : Balanced 𝕜 t) (h : s ⊆ t) : balancedHull 𝕜 s ⊆ t :=
  fun x hx => by
  obtain ⟨r, hr, y, hy, rfl⟩ := mem_balanced_hull_iff.1 hx
  exact ht.smul_mem hr (h hy)
#align balanced.hull_subset_of_subset Balanced.hull_subset_of_subset

end HasSmul

section Module

variable [AddCommGroup E] [Module 𝕜 E] {s : Set E}

theorem balanced_core_zero_mem (hs : (0 : E) ∈ s) : (0 : E) ∈ balancedCore 𝕜 s :=
  mem_balanced_core_iff.2 ⟨0, balancedZero, zero_subset.2 hs, zero_mem_zero⟩
#align balanced_core_zero_mem balanced_core_zero_mem

theorem balanced_core_nonempty_iff : (balancedCore 𝕜 s).Nonempty ↔ (0 : E) ∈ s :=
  ⟨fun h =>
    zero_subset.1 <|
      (zero_smul_set h).Superset.trans <|
        (balancedCoreBalanced s (0 : 𝕜) <| norm_zero.trans_le zero_le_one).trans <|
          balanced_core_subset _,
    fun h => ⟨0, balanced_core_zero_mem h⟩⟩
#align balanced_core_nonempty_iff balanced_core_nonempty_iff

variable (𝕜)

theorem subset_balanced_hull [NormOneClass 𝕜] {s : Set E} : s ⊆ balancedHull 𝕜 s := fun _ hx =>
  mem_balanced_hull_iff.2 ⟨1, norm_one.le, _, hx, one_smul _ _⟩
#align subset_balanced_hull subset_balanced_hull

variable {𝕜}

theorem balancedHull.balanced (s : Set E) : Balanced 𝕜 (balancedHull 𝕜 s) := by
  intro a ha
  simp_rw [balancedHull, smul_set_Union₂, subset_def, mem_Union₂]
  rintro x ⟨r, hr, hx⟩
  rw [← smul_assoc] at hx
  exact ⟨a • r, (SemiNormedRing.norm_mul _ _).trans (mul_le_one ha (norm_nonneg r) hr), hx⟩
#align balanced_hull.balanced balancedHull.balanced

end Module

end SemiNormedRing

section NormedField

variable [NormedField 𝕜] [AddCommGroup E] [Module 𝕜 E] {s t : Set E}

@[simp]
theorem balanced_core_aux_empty : balancedCoreAux 𝕜 (∅ : Set E) = ∅ := by
  simp_rw [balancedCoreAux, Inter₂_eq_empty_iff, smul_set_empty]
  exact fun _ => ⟨1, norm_one.ge, not_mem_empty _⟩
#align balanced_core_aux_empty balanced_core_aux_empty

theorem balanced_core_aux_subset (s : Set E) : balancedCoreAux 𝕜 s ⊆ s := fun x hx => by
  simpa only [one_smul] using mem_balanced_core_aux_iff.1 hx 1 norm_one.ge
#align balanced_core_aux_subset balanced_core_aux_subset

theorem balancedCoreAuxBalanced (h0 : (0 : E) ∈ balancedCoreAux 𝕜 s) :
    Balanced 𝕜 (balancedCoreAux 𝕜 s) := by
  rintro a ha x ⟨y, hy, rfl⟩
  obtain rfl | h := eq_or_ne a 0
  · rwa [zero_smul]
    
  rw [mem_balanced_core_aux_iff] at hy⊢
  intro r hr
  have h'' : 1 ≤ ‖a⁻¹ • r‖ := by
    rw [norm_smul, norm_inv]
    exact one_le_mul_of_one_le_of_one_le (one_le_inv (norm_pos_iff.mpr h) ha) hr
  have h' := hy (a⁻¹ • r) h''
  rwa [smul_assoc, mem_inv_smul_set_iff₀ h] at h'
#align balanced_core_aux_balanced balancedCoreAuxBalanced

theorem balanced_core_aux_maximal (h : t ⊆ s) (ht : Balanced 𝕜 t) : t ⊆ balancedCoreAux 𝕜 s := by
  refine' fun x hx => mem_balanced_core_aux_iff.2 fun r hr => _
  rw [mem_smul_set_iff_inv_smul_mem₀ (norm_pos_iff.mp <| zero_lt_one.trans_le hr)]
  refine' h (ht.smul_mem _ hx)
  rw [norm_inv]
  exact inv_le_one hr
#align balanced_core_aux_maximal balanced_core_aux_maximal

theorem balanced_core_subset_balanced_core_aux : balancedCore 𝕜 s ⊆ balancedCoreAux 𝕜 s :=
  balanced_core_aux_maximal (balanced_core_subset s) (balancedCoreBalanced s)
#align balanced_core_subset_balanced_core_aux balanced_core_subset_balanced_core_aux

theorem balanced_core_eq_Inter (hs : (0 : E) ∈ s) :
    balancedCore 𝕜 s = ⋂ (r : 𝕜) (hr : 1 ≤ ‖r‖), r • s := by
  refine' balanced_core_subset_balanced_core_aux.antisymm _
  refine' (balancedCoreAuxBalanced _).subset_core_of_subset (balanced_core_aux_subset s)
  exact balanced_core_subset_balanced_core_aux (balanced_core_zero_mem hs)
#align balanced_core_eq_Inter balanced_core_eq_Inter

theorem subset_balanced_core (ht : (0 : E) ∈ t) (hst : ∀ (a : 𝕜) (ha : ‖a‖ ≤ 1), a • s ⊆ t) :
    s ⊆ balancedCore 𝕜 t := by
  rw [balanced_core_eq_Inter ht]
  refine' subset_Inter₂ fun a ha => _
  rw [← smul_inv_smul₀ (norm_pos_iff.mp <| zero_lt_one.trans_le ha) s]
  refine' smul_set_mono (hst _ _)
  rw [norm_inv]
  exact inv_le_one ha
#align subset_balanced_core subset_balanced_core

end NormedField

end balancedHull

/-! ### Topological properties -/


section Topology

variable [NontriviallyNormedField 𝕜] [AddCommGroup E] [Module 𝕜 E] [TopologicalSpace E]
  [HasContinuousSmul 𝕜 E] {U : Set E}

protected theorem IsClosed.balancedCore (hU : IsClosed U) : IsClosed (balancedCore 𝕜 U) := by
  by_cases h : (0 : E) ∈ U
  · rw [balanced_core_eq_Inter h]
    refine' isClosedInter fun a => _
    refine' isClosedInter fun ha => _
    have ha' := lt_of_lt_of_le zero_lt_one ha
    rw [norm_pos_iff] at ha'
    refine' is_closed_map_smul_of_ne_zero ha' U hU
    
  convert isClosedEmpty
  contrapose! h
  exact balanced_core_nonempty_iff.mp (set.ne_empty_iff_nonempty.mp h)
#align is_closed.balanced_core IsClosed.balancedCore

theorem balanced_core_mem_nhds_zero (hU : U ∈ 𝓝 (0 : E)) : balancedCore 𝕜 U ∈ 𝓝 (0 : E) := by
  -- Getting neighborhoods of the origin for `0 : 𝕜` and `0 : E`
  obtain ⟨r, V, hr, hV, hrVU⟩ :
    ∃ (r : ℝ)(V : Set E), 0 < r ∧ V ∈ 𝓝 (0 : E) ∧ ∀ (c : 𝕜) (y : E), ‖c‖ < r → y ∈ V → c • y ∈ U :=
    by
    have h : Filter.Tendsto (fun x : 𝕜 × E => x.fst • x.snd) (𝓝 (0, 0)) (𝓝 0) :=
      continuous_smul.tendsto' (0, 0) _ (smul_zero _)
    simpa only [← Prod.exists', ← Prod.forall', ← and_imp, ← and_assoc, exists_prop] using
      h.basis_left (normed_add_comm_group.nhds_zero_basis_norm_lt.prod_nhds (𝓝 _).basis_sets) U hU
  rcases NormedField.exists_norm_lt 𝕜 hr with ⟨y, hy₀, hyr⟩
  rw [norm_pos_iff] at hy₀
  have : y • V ∈ 𝓝 (0 : E) := (set_smul_mem_nhds_zero_iff hy₀).mpr hV
  -- It remains to show that `y • V ⊆ balanced_core 𝕜 U`
  refine' Filter.mem_of_superset this ((subset_balanced_core (mem_of_mem_nhds hU)) fun a ha => _)
  rw [smul_smul]
  rintro _ ⟨z, hz, rfl⟩
  refine' hrVU _ _ _ hz
  rw [norm_mul, ← one_mul r]
  exact mul_lt_mul' ha hyr (norm_nonneg y) one_pos
#align balanced_core_mem_nhds_zero balanced_core_mem_nhds_zero

variable (𝕜 E)

theorem nhds_basis_balanced :
    (𝓝 (0 : E)).HasBasis (fun s : Set E => s ∈ 𝓝 (0 : E) ∧ Balanced 𝕜 s) id :=
  Filter.has_basis_self.mpr fun s hs =>
    ⟨balancedCore 𝕜 s, balanced_core_mem_nhds_zero hs, balancedCoreBalanced s,
      balanced_core_subset s⟩
#align nhds_basis_balanced nhds_basis_balanced

theorem nhds_basis_closed_balanced [RegularSpace E] :
    (𝓝 (0 : E)).HasBasis (fun s : Set E => s ∈ 𝓝 (0 : E) ∧ IsClosed s ∧ Balanced 𝕜 s) id := by
  refine'
    (closed_nhds_basis 0).to_has_basis (fun s hs => _) fun s hs => ⟨s, ⟨hs.1, hs.2.1⟩, rfl.subset⟩
  refine' ⟨balancedCore 𝕜 s, ⟨balanced_core_mem_nhds_zero hs.1, _⟩, balanced_core_subset s⟩
  exact ⟨hs.2.balancedCore, balancedCoreBalanced s⟩
#align nhds_basis_closed_balanced nhds_basis_closed_balanced

end Topology

