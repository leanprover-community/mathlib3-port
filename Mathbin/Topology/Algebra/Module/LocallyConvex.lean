/-
Copyright (c) 2022 Anatole Dedecker. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anatole Dedecker

! This file was ported from Lean 3 source module topology.algebra.module.locally_convex
! leanprover-community/mathlib commit 9830a300340708eaa85d477c3fb96dd25f9468a5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Convex.Topology

/-!
# Locally convex topological modules

A `locally_convex_space` is a topological semimodule over an ordered semiring in which any point
admits a neighborhood basis made of convex sets, or equivalently, in which convex neighborhoods of
a point form a neighborhood basis at that point.

In a module, this is equivalent to `0` satisfying such properties.

## Main results

- `locally_convex_space_iff_zero` : in a module, local convexity at zero gives
  local convexity everywhere
- `seminorm.locally_convex_space` : a topology generated by a family of seminorms is locally convex
- `normed_space.locally_convex_space` : a normed space is locally convex

## TODO

- define a structure `locally_convex_filter_basis`, extending `module_filter_basis`, for filter
  bases generating a locally convex topology

-/


open TopologicalSpace Filter Set

open TopologicalSpace Pointwise

section Semimodule

/-- A `locally_convex_space` is a topological semimodule over an ordered semiring in which convex
neighborhoods of a point form a neighborhood basis at that point. -/
class LocallyConvexSpace (𝕜 E : Type _) [OrderedSemiring 𝕜] [AddCommMonoid E] [Module 𝕜 E]
  [TopologicalSpace E] : Prop where
  convex_basis : ∀ x : E, (𝓝 x).HasBasis (fun s : Set E => s ∈ 𝓝 x ∧ Convex 𝕜 s) id
#align locally_convex_space LocallyConvexSpace

variable (𝕜 E : Type _) [OrderedSemiring 𝕜] [AddCommMonoid E] [Module 𝕜 E] [TopologicalSpace E]

theorem locally_convex_space_iff :
    LocallyConvexSpace 𝕜 E ↔ ∀ x : E, (𝓝 x).HasBasis (fun s : Set E => s ∈ 𝓝 x ∧ Convex 𝕜 s) id :=
  ⟨@LocallyConvexSpace.convex_basis _ _ _ _ _ _, LocallyConvexSpace.mk⟩
#align locally_convex_space_iff locally_convex_space_iff

theorem LocallyConvexSpace.ofBases {ι : Type _} (b : E → ι → Set E) (p : E → ι → Prop)
    (hbasis : ∀ x : E, (𝓝 x).HasBasis (p x) (b x)) (hconvex : ∀ x i, p x i → Convex 𝕜 (b x i)) :
    LocallyConvexSpace 𝕜 E :=
  ⟨fun x =>
    (hbasis x).to_has_basis
      (fun i hi => ⟨b x i, ⟨⟨(hbasis x).mem_of_mem hi, hconvex x i hi⟩, le_refl (b x i)⟩⟩)
      fun s hs =>
      ⟨(hbasis x).index s hs.1, ⟨(hbasis x).property_index hs.1, (hbasis x).set_index_subset hs.1⟩⟩⟩
#align locally_convex_space.of_bases LocallyConvexSpace.ofBases

theorem LocallyConvexSpace.convex_basis_zero [LocallyConvexSpace 𝕜 E] :
    (𝓝 0 : Filter E).HasBasis (fun s => s ∈ (𝓝 0 : Filter E) ∧ Convex 𝕜 s) id :=
  LocallyConvexSpace.convex_basis 0
#align locally_convex_space.convex_basis_zero LocallyConvexSpace.convex_basis_zero

theorem locally_convex_space_iff_exists_convex_subset :
    LocallyConvexSpace 𝕜 E ↔ ∀ x : E, ∀ U ∈ 𝓝 x, ∃ S ∈ 𝓝 x, Convex 𝕜 S ∧ S ⊆ U :=
  (locally_convex_space_iff 𝕜 E).trans (forall_congr' fun x => has_basis_self)
#align locally_convex_space_iff_exists_convex_subset locally_convex_space_iff_exists_convex_subset

end Semimodule

section Module

variable (𝕜 E : Type _) [OrderedSemiring 𝕜] [AddCommGroup E] [Module 𝕜 E] [TopologicalSpace E]
  [TopologicalAddGroup E]

theorem LocallyConvexSpace.ofBasisZero {ι : Type _} (b : ι → Set E) (p : ι → Prop)
    (hbasis : (𝓝 0).HasBasis p b) (hconvex : ∀ i, p i → Convex 𝕜 (b i)) : LocallyConvexSpace 𝕜 E :=
  by
  refine'
    LocallyConvexSpace.ofBases 𝕜 E (fun (x : E) (i : ι) => (· + ·) x '' b i) (fun _ => p)
      (fun x => _) fun x i hi => (hconvex i hi).translate x
  rw [← map_add_left_nhds_zero]
  exact hbasis.map _
#align locally_convex_space.of_basis_zero LocallyConvexSpace.ofBasisZero

theorem locally_convex_space_iff_zero :
    LocallyConvexSpace 𝕜 E ↔
      (𝓝 0 : Filter E).HasBasis (fun s : Set E => s ∈ (𝓝 0 : Filter E) ∧ Convex 𝕜 s) id :=
  ⟨fun h => @LocallyConvexSpace.convex_basis _ _ _ _ _ _ h 0, fun h =>
    LocallyConvexSpace.ofBasisZero 𝕜 E _ _ h fun s => And.right⟩
#align locally_convex_space_iff_zero locally_convex_space_iff_zero

theorem locally_convex_space_iff_exists_convex_subset_zero :
    LocallyConvexSpace 𝕜 E ↔ ∀ U ∈ (𝓝 0 : Filter E), ∃ S ∈ (𝓝 0 : Filter E), Convex 𝕜 S ∧ S ⊆ U :=
  (locally_convex_space_iff_zero 𝕜 E).trans has_basis_self
#align
  locally_convex_space_iff_exists_convex_subset_zero locally_convex_space_iff_exists_convex_subset_zero

-- see Note [lower instance priority]
instance (priority := 100) LocallyConvexSpace.to_locally_connected_space [Module ℝ E]
    [HasContinuousSmul ℝ E] [LocallyConvexSpace ℝ E] : LocallyConnectedSpace E :=
  locally_connected_space_of_connected_bases _ _
    (fun x => @LocallyConvexSpace.convex_basis ℝ _ _ _ _ _ _ x) fun x s hs => hs.2.IsPreconnected
#align locally_convex_space.to_locally_connected_space LocallyConvexSpace.to_locally_connected_space

end Module

section LinearOrderedField

variable (𝕜 E : Type _) [LinearOrderedField 𝕜] [AddCommGroup E] [Module 𝕜 E] [TopologicalSpace E]
  [TopologicalAddGroup E] [HasContinuousConstSmul 𝕜 E]

theorem LocallyConvexSpace.convex_open_basis_zero [LocallyConvexSpace 𝕜 E] :
    (𝓝 0 : Filter E).HasBasis (fun s => (0 : E) ∈ s ∧ IsOpen s ∧ Convex 𝕜 s) id :=
  (LocallyConvexSpace.convex_basis_zero 𝕜 E).to_has_basis
    (fun s hs =>
      ⟨interior s, ⟨mem_interior_iff_mem_nhds.mpr hs.1, is_open_interior, hs.2.interior⟩,
        interior_subset⟩)
    fun s hs => ⟨s, ⟨hs.2.1.mem_nhds hs.1, hs.2.2⟩, subset_rfl⟩
#align locally_convex_space.convex_open_basis_zero LocallyConvexSpace.convex_open_basis_zero

variable {𝕜 E}

/-- In a locally convex space, if `s`, `t` are disjoint convex sets, `s` is compact and `t` is
closed, then we can find open disjoint convex sets containing them. -/
theorem Disjoint.exists_open_convexes [LocallyConvexSpace 𝕜 E] {s t : Set E} (disj : Disjoint s t)
    (hs₁ : Convex 𝕜 s) (hs₂ : IsCompact s) (ht₁ : Convex 𝕜 t) (ht₂ : IsClosed t) :
    ∃ u v, IsOpen u ∧ IsOpen v ∧ Convex 𝕜 u ∧ Convex 𝕜 v ∧ s ⊆ u ∧ t ⊆ v ∧ Disjoint u v :=
  by
  letI : UniformSpace E := TopologicalAddGroup.toUniformSpace E
  haveI : UniformAddGroup E := topological_add_comm_group_is_uniform
  have := (LocallyConvexSpace.convex_open_basis_zero 𝕜 E).comap fun x : E × E => x.2 - x.1
  rw [← uniformity_eq_comap_nhds_zero] at this
  rcases disj.exists_uniform_thickening_of_basis this hs₂ ht₂ with ⟨V, ⟨hV0, hVopen, hVconvex⟩, hV⟩
  refine'
    ⟨s + V, t + V, hVopen.add_left, hVopen.add_left, hs₁.add hVconvex, ht₁.add hVconvex,
      subset_add_left _ hV0, subset_add_left _ hV0, _⟩
  simp_rw [← Union_add_left_image, image_add_left]
  simp_rw [UniformSpace.ball, ← preimage_comp, sub_eq_neg_add] at hV
  exact hV
#align disjoint.exists_open_convexes Disjoint.exists_open_convexes

end LinearOrderedField

section LatticeOps

variable {ι : Sort _} {𝕜 E F : Type _} [OrderedSemiring 𝕜] [AddCommMonoid E] [Module 𝕜 E]
  [AddCommMonoid F] [Module 𝕜 F]

theorem locallyConvexSpaceInf {ts : Set (TopologicalSpace E)}
    (h : ∀ t ∈ ts, @LocallyConvexSpace 𝕜 E _ _ _ t) : @LocallyConvexSpace 𝕜 E _ _ _ (infₛ ts) :=
  by
  letI : TopologicalSpace E := Inf ts
  refine'
    LocallyConvexSpace.ofBases 𝕜 E (fun x => fun If : Set ts × (ts → Set E) => ⋂ i ∈ If.1, If.2 i)
      (fun x => fun If : Set ts × (ts → Set E) =>
        If.1.Finite ∧ ∀ i ∈ If.1, If.2 i ∈ @nhds _ (↑i) x ∧ Convex 𝕜 (If.2 i))
      (fun x => _) fun x If hif => convex_Inter fun i => convex_Inter fun hi => (hif.2 i hi).2
  rw [nhds_Inf, ← infᵢ_subtype'']
  exact has_basis_infi' fun i : ts => (@locally_convex_space_iff 𝕜 E _ _ _ ↑i).mp (h (↑i) i.2) x
#align locally_convex_space_Inf locallyConvexSpaceInf

theorem locallyConvexSpaceInfi {ts' : ι → TopologicalSpace E}
    (h' : ∀ i, @LocallyConvexSpace 𝕜 E _ _ _ (ts' i)) :
    @LocallyConvexSpace 𝕜 E _ _ _ (⨅ i, ts' i) :=
  by
  refine' locallyConvexSpaceInf _
  rwa [forall_range_iff]
#align locally_convex_space_infi locallyConvexSpaceInfi

/- warning: locally_convex_space_inf clashes with locally_convex_space_Inf -> locallyConvexSpaceInf
Case conversion may be inaccurate. Consider using '#align locally_convex_space_inf locallyConvexSpaceInfₓ'. -/
#print locallyConvexSpaceInf /-
theorem locallyConvexSpaceInf {t₁ t₂ : TopologicalSpace E} (h₁ : @LocallyConvexSpace 𝕜 E _ _ _ t₁)
    (h₂ : @LocallyConvexSpace 𝕜 E _ _ _ t₂) : @LocallyConvexSpace 𝕜 E _ _ _ (t₁ ⊓ t₂) :=
  by
  rw [inf_eq_infᵢ]
  refine' locallyConvexSpaceInfi fun b => _
  cases b <;> assumption
#align locally_convex_space_inf locallyConvexSpaceInf
-/

theorem locallyConvexSpaceInduced {t : TopologicalSpace F} [LocallyConvexSpace 𝕜 F]
    (f : E →ₗ[𝕜] F) : @LocallyConvexSpace 𝕜 E _ _ _ (t.induced f) :=
  by
  letI : TopologicalSpace E := t.induced f
  refine'
    LocallyConvexSpace.ofBases 𝕜 E (fun x => preimage f)
      (fun x => fun s : Set F => s ∈ 𝓝 (f x) ∧ Convex 𝕜 s) (fun x => _) fun x s ⟨_, hs⟩ =>
      hs.linear_preimage f
  rw [nhds_induced]
  exact (LocallyConvexSpace.convex_basis <| f x).comap f
#align locally_convex_space_induced locallyConvexSpaceInduced

instance {ι : Type _} {X : ι → Type _} [∀ i, AddCommMonoid (X i)] [∀ i, TopologicalSpace (X i)]
    [∀ i, Module 𝕜 (X i)] [∀ i, LocallyConvexSpace 𝕜 (X i)] : LocallyConvexSpace 𝕜 (∀ i, X i) :=
  locallyConvexSpaceInfi fun i => locallyConvexSpaceInduced (LinearMap.proj i)

instance [TopologicalSpace E] [TopologicalSpace F] [LocallyConvexSpace 𝕜 E]
    [LocallyConvexSpace 𝕜 F] : LocallyConvexSpace 𝕜 (E × F) :=
  locallyConvexSpaceInf (locallyConvexSpaceInduced (LinearMap.fst _ _ _))
    (locallyConvexSpaceInduced (LinearMap.snd _ _ _))

end LatticeOps

