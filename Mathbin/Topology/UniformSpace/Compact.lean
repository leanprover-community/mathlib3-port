/-
Copyright (c) 2020 Patrick Massot. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Massot, Yury Kudryashov

! This file was ported from Lean 3 source module topology.uniform_space.compact
! leanprover-community/mathlib commit ee05e9ce1322178f0c12004eb93c00d2c8c00ed2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.UniformSpace.UniformConvergence
import Mathbin.Topology.UniformSpace.Equicontinuity
import Mathbin.Topology.Separation
import Mathbin.Topology.Support

/-!
# Compact separated uniform spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main statements

* `compact_space_uniformity`: On a compact uniform space, the topology determines the
  uniform structure, entourages are exactly the neighborhoods of the diagonal.

* `uniform_space_of_compact_t2`: every compact T2 topological structure is induced by a uniform
  structure. This uniform structure is described in the previous item.

* **Heine-Cantor** theorem: continuous functions on compact uniform spaces with values in uniform
  spaces are automatically uniformly continuous. There are several variations, the main one is
  `compact_space.uniform_continuous_of_continuous`.

## Implementation notes

The construction `uniform_space_of_compact_t2` is not declared as an instance, as it would badly
loop.

## tags

uniform space, uniform continuity, compact space
-/


open Classical uniformity Topology Filter

open Filter UniformSpace Set

variable {α β γ : Type _} [UniformSpace α] [UniformSpace β]

/-!
### Uniformity on compact spaces
-/


/- warning: nhds_set_diagonal_eq_uniformity -> nhdsSet_diagonal_eq_uniformity is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : UniformSpace.{u1} α] [_inst_3 : CompactSpace.{u1} α (UniformSpace.toTopologicalSpace.{u1} α _inst_1)], Eq.{succ u1} (Filter.{u1} (Prod.{u1, u1} α α)) (nhdsSet.{u1} (Prod.{u1, u1} α α) (Prod.topologicalSpace.{u1, u1} α α (UniformSpace.toTopologicalSpace.{u1} α _inst_1) (UniformSpace.toTopologicalSpace.{u1} α _inst_1)) (Set.diagonal.{u1} α)) (uniformity.{u1} α _inst_1)
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : UniformSpace.{u1} α] [_inst_3 : CompactSpace.{u1} α (UniformSpace.toTopologicalSpace.{u1} α _inst_1)], Eq.{succ u1} (Filter.{u1} (Prod.{u1, u1} α α)) (nhdsSet.{u1} (Prod.{u1, u1} α α) (instTopologicalSpaceProd.{u1, u1} α α (UniformSpace.toTopologicalSpace.{u1} α _inst_1) (UniformSpace.toTopologicalSpace.{u1} α _inst_1)) (Set.diagonal.{u1} α)) (uniformity.{u1} α _inst_1)
Case conversion may be inaccurate. Consider using '#align nhds_set_diagonal_eq_uniformity nhdsSet_diagonal_eq_uniformityₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- On a compact uniform space, the topology determines the uniform structure, entourages are
exactly the neighborhoods of the diagonal. -/
theorem nhdsSet_diagonal_eq_uniformity [CompactSpace α] : 𝓝ˢ (diagonal α) = 𝓤 α :=
  by
  refine' nhds_set_diagonal_le_uniformity.antisymm _
  have :
    (𝓤 (α × α)).HasBasis (fun U => U ∈ 𝓤 α) fun U =>
      (fun p : (α × α) × α × α => ((p.1.1, p.2.1), p.1.2, p.2.2)) ⁻¹' U ×ˢ U :=
    by
    rw [uniformity_prod_eq_comap_prod]
    exact (𝓤 α).basis_sets.prod_self.comap _
  refine' (is_compact_diagonal.nhds_set_basis_uniformity this).ge_iff.2 fun U hU => _
  exact mem_of_superset hU fun ⟨x, y⟩ hxy => mem_Union₂.2 ⟨(x, x), rfl, refl_mem_uniformity hU, hxy⟩
#align nhds_set_diagonal_eq_uniformity nhdsSet_diagonal_eq_uniformity

/- warning: compact_space_uniformity -> compactSpace_uniformity is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : UniformSpace.{u1} α] [_inst_3 : CompactSpace.{u1} α (UniformSpace.toTopologicalSpace.{u1} α _inst_1)], Eq.{succ u1} (Filter.{u1} (Prod.{u1, u1} α α)) (uniformity.{u1} α _inst_1) (iSup.{u1, succ u1} (Filter.{u1} (Prod.{u1, u1} α α)) (ConditionallyCompleteLattice.toHasSup.{u1} (Filter.{u1} (Prod.{u1, u1} α α)) (CompleteLattice.toConditionallyCompleteLattice.{u1} (Filter.{u1} (Prod.{u1, u1} α α)) (Filter.completeLattice.{u1} (Prod.{u1, u1} α α)))) α (fun (x : α) => nhds.{u1} (Prod.{u1, u1} α α) (Prod.topologicalSpace.{u1, u1} α α (UniformSpace.toTopologicalSpace.{u1} α _inst_1) (UniformSpace.toTopologicalSpace.{u1} α _inst_1)) (Prod.mk.{u1, u1} α α x x)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : UniformSpace.{u1} α] [_inst_3 : CompactSpace.{u1} α (UniformSpace.toTopologicalSpace.{u1} α _inst_1)], Eq.{succ u1} (Filter.{u1} (Prod.{u1, u1} α α)) (uniformity.{u1} α _inst_1) (iSup.{u1, succ u1} (Filter.{u1} (Prod.{u1, u1} α α)) (ConditionallyCompleteLattice.toSupSet.{u1} (Filter.{u1} (Prod.{u1, u1} α α)) (CompleteLattice.toConditionallyCompleteLattice.{u1} (Filter.{u1} (Prod.{u1, u1} α α)) (Filter.instCompleteLatticeFilter.{u1} (Prod.{u1, u1} α α)))) α (fun (x : α) => nhds.{u1} (Prod.{u1, u1} α α) (instTopologicalSpaceProd.{u1, u1} α α (UniformSpace.toTopologicalSpace.{u1} α _inst_1) (UniformSpace.toTopologicalSpace.{u1} α _inst_1)) (Prod.mk.{u1, u1} α α x x)))
Case conversion may be inaccurate. Consider using '#align compact_space_uniformity compactSpace_uniformityₓ'. -/
/-- On a compact uniform space, the topology determines the uniform structure, entourages are
exactly the neighborhoods of the diagonal. -/
theorem compactSpace_uniformity [CompactSpace α] : 𝓤 α = ⨆ x, 𝓝 (x, x) :=
  nhdsSet_diagonal_eq_uniformity.symm.trans (nhdsSet_diagonal _)
#align compact_space_uniformity compactSpace_uniformity

#print unique_uniformity_of_compact /-
theorem unique_uniformity_of_compact [t : TopologicalSpace γ] [CompactSpace γ]
    {u u' : UniformSpace γ} (h : u.toTopologicalSpace = t) (h' : u'.toTopologicalSpace = t) :
    u = u' := by
  apply uniformSpace_eq
  change uniformity _ = uniformity _
  have : @CompactSpace γ u.to_topological_space := by rwa [h]
  have : @CompactSpace γ u'.to_topological_space := by rwa [h']
  rw [compactSpace_uniformity, compactSpace_uniformity, h, h']
#align unique_uniformity_of_compact unique_uniformity_of_compact
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Basic.lean:635:2: warning: expanding binder collection (y «expr ≠ » x) -/
#print uniformSpaceOfCompactT2 /-
/-- The unique uniform structure inducing a given compact topological structure. -/
def uniformSpaceOfCompactT2 [TopologicalSpace γ] [CompactSpace γ] [T2Space γ] : UniformSpace γ
    where
  uniformity := 𝓝ˢ (diagonal γ)
  refl := principal_le_nhdsSet
  symm := continuous_swap.tendsto_nhdsSet fun x => Eq.symm
  comp :=
    by
    /-
        This is the difficult part of the proof. We need to prove that, for each neighborhood `W`
        of the diagonal `Δ`, there exists a smaller neighborhood `V` such that `V ○ V ⊆ W`.
        -/
    set 𝓝Δ := 𝓝ˢ (diagonal γ)
    -- The filter of neighborhoods of Δ
    set F := 𝓝Δ.lift' fun s : Set (γ × γ) => s ○ s
    -- Compositions of neighborhoods of Δ
    -- If this weren't true, then there would be V ∈ 𝓝Δ such that F ⊓ 𝓟 Vᶜ ≠ ⊥
    rw [le_iff_forall_inf_principal_compl]
    intro V V_in
    by_contra H
    haveI : ne_bot (F ⊓ 𝓟 (Vᶜ)) := ⟨H⟩
    -- Hence compactness would give us a cluster point (x, y) for F ⊓ 𝓟 Vᶜ
    obtain ⟨⟨x, y⟩, hxy⟩ : ∃ p : γ × γ, ClusterPt p (F ⊓ 𝓟 (Vᶜ)) := cluster_point_of_compact _
    -- In particular (x, y) is a cluster point of 𝓟 Vᶜ, hence is not in the interior of V,
    -- and a fortiori not in Δ, so x ≠ y
    have clV : ClusterPt (x, y) (𝓟 <| Vᶜ) := hxy.of_inf_right
    have : (x, y) ∉ interior V :=
      by
      have : (x, y) ∈ closure (Vᶜ) := by rwa [mem_closure_iff_clusterPt]
      rwa [closure_compl] at this
    have diag_subset : diagonal γ ⊆ interior V := subset_interior_iff_mem_nhdsSet.2 V_in
    have x_ne_y : x ≠ y := mt (@diag_subset (x, y)) this
    -- Since γ is compact and Hausdorff, it is normal, hence T₃.
    haveI : NormalSpace γ := normalOfCompactT2
    -- So there are closed neighboords V₁ and V₂ of x and y contained in disjoint open neighborhoods
    -- U₁ and U₂.
    obtain
      ⟨U₁, U₁_in, V₁, V₁_in, U₂, U₂_in₂, V₂, V₂_in, V₁_cl, V₂_cl, U₁_op, U₂_op, VU₁, VU₂, hU₁₂⟩ :=
      disjoint_nested_nhds x_ne_y
    -- We set U₃ := (V₁ ∪ V₂)ᶜ so that W := U₁ ×ˢ U₁ ∪ U₂ ×ˢ U₂ ∪ U₃ ×ˢ U₃ is an open
    -- neighborhood of Δ.
    let U₃ := (V₁ ∪ V₂)ᶜ
    have U₃_op : IsOpen U₃ := (V₁_cl.union V₂_cl).isOpen_compl
    let W := U₁ ×ˢ U₁ ∪ U₂ ×ˢ U₂ ∪ U₃ ×ˢ U₃
    have W_in : W ∈ 𝓝Δ := by
      rw [mem_nhdsSet_iff_forall]
      rintro ⟨z, z'⟩ (rfl : z = z')
      refine' IsOpen.mem_nhds _ _
      · apply_rules [IsOpen.union, IsOpen.prod]
      · simp only [mem_union, mem_prod, and_self_iff]
        exact (em _).imp_left fun h => union_subset_union VU₁ VU₂ h
    -- So W ○ W ∈ F by definition of F
    have : W ○ W ∈ F := by simpa only using mem_lift' W_in
    -- And V₁ ×ˢ V₂ ∈ 𝓝 (x, y)
    have hV₁₂ : V₁ ×ˢ V₂ ∈ 𝓝 (x, y) := prod_mem_nhds V₁_in V₂_in
    -- But (x, y) is also a cluster point of F so (V₁ ×ˢ V₂) ∩ (W ○ W) ≠ ∅
    -- However the construction of W implies (V₁ ×ˢ V₂) ∩ (W ○ W) = ∅.
    -- Indeed assume for contradiction there is some (u, v) in the intersection.
    obtain ⟨⟨u, v⟩, ⟨u_in, v_in⟩, w, huw, hwv⟩ := cluster_pt_iff.mp hxy.of_inf_left hV₁₂ this
    -- So u ∈ V₁, v ∈ V₂, and there exists some w such that (u, w) ∈ W and (w ,v) ∈ W.
    -- Because u is in V₁ which is disjoint from U₂ and U₃, (u, w) ∈ W forces (u, w) ∈ U₁ ×ˢ U₁.
    have uw_in : (u, w) ∈ U₁ ×ˢ U₁ :=
      (huw.resolve_right fun h => h.1 <| Or.inl u_in).resolve_right fun h =>
        hU₁₂.le_bot ⟨VU₁ u_in, h.1⟩
    -- Similarly, because v ∈ V₂, (w ,v) ∈ W forces (w, v) ∈ U₂ ×ˢ U₂.
    have wv_in : (w, v) ∈ U₂ ×ˢ U₂ :=
      (hwv.resolve_right fun h => h.2 <| Or.inr v_in).resolve_left fun h =>
        hU₁₂.le_bot ⟨h.2, VU₂ v_in⟩
    -- Hence w ∈ U₁ ∩ U₂ which is empty.
    -- So we have a contradiction
    exact hU₁₂.le_bot ⟨uw_in.2, wv_in.1⟩
  isOpen_uniformity :=
    by
    -- Here we need to prove the topology induced by the constructed uniformity is the
    -- topology we started with.
    suffices ∀ x : γ, Filter.comap (Prod.mk x) (𝓝ˢ (diagonal γ)) = 𝓝 x
      by
      intro s
      simp_rw [isOpen_fold, isOpen_iff_mem_nhds, ← mem_comap_prod_mk, this]
    intro x
    simp_rw [nhdsSet_diagonal, comap_supr, nhds_prod_eq, comap_prod, (· ∘ ·), comap_id']
    rw [iSup_split_single _ x, comap_const_of_mem fun V => mem_of_mem_nhds]
    suffices ∀ (y) (_ : y ≠ x), comap (fun y : γ => x) (𝓝 y) ⊓ 𝓝 y ≤ 𝓝 x by simpa
    intro y hxy
    simp [comap_const_of_not_mem (compl_singleton_mem_nhds hxy) (Classical.not_not.2 rfl)]
#align uniform_space_of_compact_t2 uniformSpaceOfCompactT2
-/

/-!
### Heine-Cantor theorem
-/


/- warning: compact_space.uniform_continuous_of_continuous -> CompactSpace.uniformContinuous_of_continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : UniformSpace.{u1} α] [_inst_2 : UniformSpace.{u2} β] [_inst_3 : CompactSpace.{u1} α (UniformSpace.toTopologicalSpace.{u1} α _inst_1)] {f : α -> β}, (Continuous.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α _inst_1) (UniformSpace.toTopologicalSpace.{u2} β _inst_2) f) -> (UniformContinuous.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : UniformSpace.{u2} α] [_inst_2 : UniformSpace.{u1} β] [_inst_3 : CompactSpace.{u2} α (UniformSpace.toTopologicalSpace.{u2} α _inst_1)] {f : α -> β}, (Continuous.{u2, u1} α β (UniformSpace.toTopologicalSpace.{u2} α _inst_1) (UniformSpace.toTopologicalSpace.{u1} β _inst_2) f) -> (UniformContinuous.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align compact_space.uniform_continuous_of_continuous CompactSpace.uniformContinuous_of_continuousₓ'. -/
/-- Heine-Cantor: a continuous function on a compact uniform space is uniformly
continuous. -/
theorem CompactSpace.uniformContinuous_of_continuous [CompactSpace α] {f : α → β}
    (h : Continuous f) : UniformContinuous f :=
  have : Tendsto (Prod.map f f) (𝓝ˢ (diagonal α)) (𝓝ˢ (diagonal β)) :=
    (h.Prod_map h).tendsto_nhdsSet mapsTo_prod_map_diagonal
  (this.mono_left nhdsSet_diagonal_eq_uniformity.ge).mono_right nhdsSet_diagonal_le_uniformity
#align compact_space.uniform_continuous_of_continuous CompactSpace.uniformContinuous_of_continuous

/- warning: is_compact.uniform_continuous_on_of_continuous -> IsCompact.uniformContinuousOn_of_continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : UniformSpace.{u1} α] [_inst_2 : UniformSpace.{u2} β] {s : Set.{u1} α} {f : α -> β}, (IsCompact.{u1} α (UniformSpace.toTopologicalSpace.{u1} α _inst_1) s) -> (ContinuousOn.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α _inst_1) (UniformSpace.toTopologicalSpace.{u2} β _inst_2) f s) -> (UniformContinuousOn.{u1, u2} α β _inst_1 _inst_2 f s)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : UniformSpace.{u2} α] [_inst_2 : UniformSpace.{u1} β] {s : Set.{u2} α} {f : α -> β}, (IsCompact.{u2} α (UniformSpace.toTopologicalSpace.{u2} α _inst_1) s) -> (ContinuousOn.{u2, u1} α β (UniformSpace.toTopologicalSpace.{u2} α _inst_1) (UniformSpace.toTopologicalSpace.{u1} β _inst_2) f s) -> (UniformContinuousOn.{u2, u1} α β _inst_1 _inst_2 f s)
Case conversion may be inaccurate. Consider using '#align is_compact.uniform_continuous_on_of_continuous IsCompact.uniformContinuousOn_of_continuousₓ'. -/
/-- Heine-Cantor: a continuous function on a compact set of a uniform space is uniformly
continuous. -/
theorem IsCompact.uniformContinuousOn_of_continuous {s : Set α} {f : α → β} (hs : IsCompact s)
    (hf : ContinuousOn f s) : UniformContinuousOn f s :=
  by
  rw [uniformContinuousOn_iff_restrict]
  rw [isCompact_iff_compactSpace] at hs
  rw [continuousOn_iff_continuous_restrict] at hf
  skip
  exact CompactSpace.uniformContinuous_of_continuous hf
#align is_compact.uniform_continuous_on_of_continuous IsCompact.uniformContinuousOn_of_continuous

#print IsCompact.uniformContinuousAt_of_continuousAt /-
/-- If `s` is compact and `f` is continuous at all points of `s`, then `f` is
"uniformly continuous at the set `s`", i.e. `f x` is close to `f y` whenever `x ∈ s` and `y` is
close to `x` (even if `y` is not itself in `s`, so this is a stronger assertion than
`uniform_continuous_on s`). -/
theorem IsCompact.uniformContinuousAt_of_continuousAt {r : Set (β × β)} {s : Set α}
    (hs : IsCompact s) (f : α → β) (hf : ∀ a ∈ s, ContinuousAt f a) (hr : r ∈ 𝓤 β) :
    { x : α × α | x.1 ∈ s → (f x.1, f x.2) ∈ r } ∈ 𝓤 α :=
  by
  obtain ⟨t, ht, htsymm, htr⟩ := comp_symm_mem_uniformity_sets hr
  choose U hU T hT hb using fun a ha =>
    exists_mem_nhds_ball_subset_of_mem_nhds ((hf a ha).preimage_mem_nhds <| mem_nhds_left _ ht)
  obtain ⟨fs, hsU⟩ := hs.elim_nhds_subcover' U hU
  apply mem_of_superset ((bInter_finset_mem fs).2 fun a _ => hT a a.2)
  rintro ⟨a₁, a₂⟩ h h₁
  obtain ⟨a, ha, haU⟩ := Set.mem_iUnion₂.1 (hsU h₁)
  apply htr
  refine' ⟨f a, htsymm.mk_mem_comm.1 (hb _ _ _ haU _), hb _ _ _ haU _⟩
  exacts[mem_ball_self _ (hT a a.2), mem_Inter₂.1 h a ha]
#align is_compact.uniform_continuous_at_of_continuous_at IsCompact.uniformContinuousAt_of_continuousAt
-/

/- warning: continuous.uniform_continuous_of_tendsto_cocompact -> Continuous.uniformContinuous_of_tendsto_cocompact is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : UniformSpace.{u1} α] [_inst_2 : UniformSpace.{u2} β] {f : α -> β} {x : β}, (Continuous.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α _inst_1) (UniformSpace.toTopologicalSpace.{u2} β _inst_2) f) -> (Filter.Tendsto.{u1, u2} α β f (Filter.cocompact.{u1} α (UniformSpace.toTopologicalSpace.{u1} α _inst_1)) (nhds.{u2} β (UniformSpace.toTopologicalSpace.{u2} β _inst_2) x)) -> (UniformContinuous.{u1, u2} α β _inst_1 _inst_2 f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : UniformSpace.{u2} α] [_inst_2 : UniformSpace.{u1} β] {f : α -> β} {x : β}, (Continuous.{u2, u1} α β (UniformSpace.toTopologicalSpace.{u2} α _inst_1) (UniformSpace.toTopologicalSpace.{u1} β _inst_2) f) -> (Filter.Tendsto.{u2, u1} α β f (Filter.cocompact.{u2} α (UniformSpace.toTopologicalSpace.{u2} α _inst_1)) (nhds.{u1} β (UniformSpace.toTopologicalSpace.{u1} β _inst_2) x)) -> (UniformContinuous.{u2, u1} α β _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align continuous.uniform_continuous_of_tendsto_cocompact Continuous.uniformContinuous_of_tendsto_cocompactₓ'. -/
theorem Continuous.uniformContinuous_of_tendsto_cocompact {f : α → β} {x : β}
    (h_cont : Continuous f) (hx : Tendsto f (cocompact α) (𝓝 x)) : UniformContinuous f :=
  uniformContinuous_def.2 fun r hr =>
    by
    obtain ⟨t, ht, htsymm, htr⟩ := comp_symm_mem_uniformity_sets hr
    obtain ⟨s, hs, hst⟩ := mem_cocompact.1 (hx <| mem_nhds_left _ ht)
    apply
      mem_of_superset
        (symmetrize_mem_uniformity <|
          (hs.uniform_continuous_at_of_continuous_at f fun _ _ => h_cont.continuous_at) <|
            symmetrize_mem_uniformity hr)
    rintro ⟨b₁, b₂⟩ h
    by_cases h₁ : b₁ ∈ s; · exact (h.1 h₁).1
    by_cases h₂ : b₂ ∈ s; · exact (h.2 h₂).2
    apply htr
    exact ⟨x, htsymm.mk_mem_comm.1 (hst h₁), hst h₂⟩
#align continuous.uniform_continuous_of_tendsto_cocompact Continuous.uniformContinuous_of_tendsto_cocompact

#print HasCompactMulSupport.is_one_at_infty /-
/-- If `f` has compact multiplicative support, then `f` tends to 1 at infinity. -/
@[to_additive "If `f` has compact support, then `f` tends to zero at infinity."]
theorem HasCompactMulSupport.is_one_at_infty {f : α → γ} [TopologicalSpace γ] [One γ]
    (h : HasCompactMulSupport f) : Tendsto f (cocompact α) (𝓝 1) :=
  by
  -- porting note: move to src/topology/support.lean once the port is over
  intro N hN
  rw [mem_map, mem_cocompact']
  refine' ⟨mulTSupport f, h.is_compact, _⟩
  rw [compl_subset_comm]
  intro v hv
  rw [mem_preimage, image_eq_one_of_nmem_mulTSupport hv]
  exact mem_of_mem_nhds hN
#align has_compact_mul_support.is_one_at_infty HasCompactMulSupport.is_one_at_infty
#align has_compact_support.is_zero_at_infty HasCompactSupport.is_zero_at_infty
-/

#print HasCompactMulSupport.uniformContinuous_of_continuous /-
@[to_additive]
theorem HasCompactMulSupport.uniformContinuous_of_continuous {f : α → β} [One β]
    (h1 : HasCompactMulSupport f) (h2 : Continuous f) : UniformContinuous f :=
  h2.uniformContinuous_of_tendsto_cocompact h1.is_one_at_infty
#align has_compact_mul_support.uniform_continuous_of_continuous HasCompactMulSupport.uniformContinuous_of_continuous
#align has_compact_support.uniform_continuous_of_continuous HasCompactSupport.uniformContinuous_of_continuous
-/

/- warning: continuous_on.tendsto_uniformly -> ContinuousOn.tendstoUniformly is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : UniformSpace.{u1} α] [_inst_2 : UniformSpace.{u2} β] [_inst_3 : LocallyCompactSpace.{u1} α (UniformSpace.toTopologicalSpace.{u1} α _inst_1)] [_inst_4 : CompactSpace.{u2} β (UniformSpace.toTopologicalSpace.{u2} β _inst_2)] [_inst_5 : UniformSpace.{u3} γ] {f : α -> β -> γ} {x : α} {U : Set.{u1} α}, (Membership.Mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (Filter.hasMem.{u1} α) U (nhds.{u1} α (UniformSpace.toTopologicalSpace.{u1} α _inst_1) x)) -> (ContinuousOn.{max u1 u2, u3} (Prod.{u1, u2} α β) γ (Prod.topologicalSpace.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α _inst_1) (UniformSpace.toTopologicalSpace.{u2} β _inst_2)) (UniformSpace.toTopologicalSpace.{u3} γ _inst_5) (Function.HasUncurry.uncurry.{max u1 u2 u3, max u1 u2, u3} (α -> β -> γ) (Prod.{u1, u2} α β) γ (Function.hasUncurryInduction.{u1, max u2 u3, u2, u3} α (β -> γ) β γ (Function.hasUncurryBase.{u2, u3} β γ)) f) (Set.prod.{u1, u2} α β U (Set.univ.{u2} β))) -> (TendstoUniformly.{u2, u3, u1} β γ α _inst_5 f (f x) (nhds.{u1} α (UniformSpace.toTopologicalSpace.{u1} α _inst_1) x))
but is expected to have type
  forall {α : Type.{u3}} {β : Type.{u2}} {γ : Type.{u1}} [_inst_1 : UniformSpace.{u3} α] [_inst_2 : UniformSpace.{u2} β] [_inst_3 : LocallyCompactSpace.{u3} α (UniformSpace.toTopologicalSpace.{u3} α _inst_1)] [_inst_4 : CompactSpace.{u2} β (UniformSpace.toTopologicalSpace.{u2} β _inst_2)] [_inst_5 : UniformSpace.{u1} γ] {f : α -> β -> γ} {x : α} {U : Set.{u3} α}, (Membership.mem.{u3, u3} (Set.{u3} α) (Filter.{u3} α) (instMembershipSetFilter.{u3} α) U (nhds.{u3} α (UniformSpace.toTopologicalSpace.{u3} α _inst_1) x)) -> (ContinuousOn.{max u3 u2, u1} (Prod.{u3, u2} α β) γ (instTopologicalSpaceProd.{u3, u2} α β (UniformSpace.toTopologicalSpace.{u3} α _inst_1) (UniformSpace.toTopologicalSpace.{u2} β _inst_2)) (UniformSpace.toTopologicalSpace.{u1} γ _inst_5) (Function.HasUncurry.uncurry.{max (max u3 u2) u1, max u3 u2, u1} (α -> β -> γ) (Prod.{u3, u2} α β) γ (Function.hasUncurryInduction.{u3, max u2 u1, u2, u1} α (β -> γ) β γ (Function.hasUncurryBase.{u2, u1} β γ)) f) (Set.prod.{u3, u2} α β U (Set.univ.{u2} β))) -> (TendstoUniformly.{u2, u1, u3} β γ α _inst_5 f (f x) (nhds.{u3} α (UniformSpace.toTopologicalSpace.{u3} α _inst_1) x))
Case conversion may be inaccurate. Consider using '#align continuous_on.tendsto_uniformly ContinuousOn.tendstoUniformlyₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- A family of functions `α → β → γ` tends uniformly to its value at `x` if `α` is locally compact,
`β` is compact and `f` is continuous on `U × (univ : set β)` for some neighborhood `U` of `x`. -/
theorem ContinuousOn.tendstoUniformly [LocallyCompactSpace α] [CompactSpace β] [UniformSpace γ]
    {f : α → β → γ} {x : α} {U : Set α} (hxU : U ∈ 𝓝 x) (h : ContinuousOn (↿f) (U ×ˢ univ)) :
    TendstoUniformly f (f x) (𝓝 x) :=
  by
  rcases LocallyCompactSpace.local_compact_nhds _ _ hxU with ⟨K, hxK, hKU, hK⟩
  have : UniformContinuousOn (↿f) (K ×ˢ univ) :=
    IsCompact.uniformContinuousOn_of_continuous (hK.prod isCompact_univ)
      (h.mono <| prod_mono hKU subset.rfl)
  exact this.tendsto_uniformly hxK
#align continuous_on.tendsto_uniformly ContinuousOn.tendstoUniformly

/- warning: continuous.tendsto_uniformly -> Continuous.tendstoUniformly is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : UniformSpace.{u1} α] [_inst_2 : UniformSpace.{u2} β] [_inst_3 : LocallyCompactSpace.{u1} α (UniformSpace.toTopologicalSpace.{u1} α _inst_1)] [_inst_4 : CompactSpace.{u2} β (UniformSpace.toTopologicalSpace.{u2} β _inst_2)] [_inst_5 : UniformSpace.{u3} γ] (f : α -> β -> γ), (Continuous.{max u1 u2, u3} (Prod.{u1, u2} α β) γ (Prod.topologicalSpace.{u1, u2} α β (UniformSpace.toTopologicalSpace.{u1} α _inst_1) (UniformSpace.toTopologicalSpace.{u2} β _inst_2)) (UniformSpace.toTopologicalSpace.{u3} γ _inst_5) (Function.HasUncurry.uncurry.{max u1 u2 u3, max u1 u2, u3} (α -> β -> γ) (Prod.{u1, u2} α β) γ (Function.hasUncurryInduction.{u1, max u2 u3, u2, u3} α (β -> γ) β γ (Function.hasUncurryBase.{u2, u3} β γ)) f)) -> (forall (x : α), TendstoUniformly.{u2, u3, u1} β γ α _inst_5 f (f x) (nhds.{u1} α (UniformSpace.toTopologicalSpace.{u1} α _inst_1) x))
but is expected to have type
  forall {α : Type.{u3}} {β : Type.{u2}} {γ : Type.{u1}} [_inst_1 : UniformSpace.{u3} α] [_inst_2 : UniformSpace.{u2} β] [_inst_3 : LocallyCompactSpace.{u3} α (UniformSpace.toTopologicalSpace.{u3} α _inst_1)] [_inst_4 : CompactSpace.{u2} β (UniformSpace.toTopologicalSpace.{u2} β _inst_2)] [_inst_5 : UniformSpace.{u1} γ] (f : α -> β -> γ), (Continuous.{max u3 u2, u1} (Prod.{u3, u2} α β) γ (instTopologicalSpaceProd.{u3, u2} α β (UniformSpace.toTopologicalSpace.{u3} α _inst_1) (UniformSpace.toTopologicalSpace.{u2} β _inst_2)) (UniformSpace.toTopologicalSpace.{u1} γ _inst_5) (Function.HasUncurry.uncurry.{max (max u3 u2) u1, max u3 u2, u1} (α -> β -> γ) (Prod.{u3, u2} α β) γ (Function.hasUncurryInduction.{u3, max u2 u1, u2, u1} α (β -> γ) β γ (Function.hasUncurryBase.{u2, u1} β γ)) f)) -> (forall (x : α), TendstoUniformly.{u2, u1, u3} β γ α _inst_5 f (f x) (nhds.{u3} α (UniformSpace.toTopologicalSpace.{u3} α _inst_1) x))
Case conversion may be inaccurate. Consider using '#align continuous.tendsto_uniformly Continuous.tendstoUniformlyₓ'. -/
/-- A continuous family of functions `α → β → γ` tends uniformly to its value at `x` if `α` is
locally compact and `β` is compact. -/
theorem Continuous.tendstoUniformly [LocallyCompactSpace α] [CompactSpace β] [UniformSpace γ]
    (f : α → β → γ) (h : Continuous ↿f) (x : α) : TendstoUniformly f (f x) (𝓝 x) :=
  h.ContinuousOn.TendstoUniformly univ_mem
#align continuous.tendsto_uniformly Continuous.tendstoUniformly

section UniformConvergence

#print CompactSpace.uniformEquicontinuous_of_equicontinuous /-
/-- An equicontinuous family of functions defined on a compact uniform space is automatically
uniformly equicontinuous. -/
theorem CompactSpace.uniformEquicontinuous_of_equicontinuous {ι : Type _} {F : ι → β → α}
    [CompactSpace β] (h : Equicontinuous F) : UniformEquicontinuous F :=
  by
  rw [equicontinuous_iff_continuous] at h
  rw [uniformEquicontinuous_iff_uniformContinuous]
  exact CompactSpace.uniformContinuous_of_continuous h
#align compact_space.uniform_equicontinuous_of_equicontinuous CompactSpace.uniformEquicontinuous_of_equicontinuous
-/

end UniformConvergence

