/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro, Patrick Massot

! This file was ported from Lean 3 source module topology.algebra.group.compact
! leanprover-community/mathlib commit 23aa88e32dcc9d2a24cca7bc23268567ed4cd7d6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Algebra.Group.Basic
import Mathbin.Topology.CompactOpen
import Mathbin.Topology.Sets.Compacts

/-!
# Additional results on topological groups

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Two results on topological groups that have been separated out as they require more substantial
imports developing either positive compacts or the compact open topology.

-/


open Classical Set Filter TopologicalSpace Function

open scoped Classical Topology Filter Pointwise

universe u v w x

variable {α : Type u} {β : Type v} {G : Type w} {H : Type x}

section

/-! Some results about an open set containing the product of two sets in a topological group. -/


variable [TopologicalSpace G] [Group G] [TopologicalGroup G]

#print TopologicalSpace.PositiveCompacts.locallyCompactSpace_of_group /-
/-- Every separated topological group in which there exists a compact set with nonempty interior
is locally compact. -/
@[to_additive
      "Every separated topological group in which there exists a compact set with nonempty\ninterior is locally compact."]
theorem TopologicalSpace.PositiveCompacts.locallyCompactSpace_of_group [T2Space G]
    (K : PositiveCompacts G) : LocallyCompactSpace G :=
  by
  refine' locally_compact_of_compact_nhds fun x => _
  obtain ⟨y, hy⟩ := K.interior_nonempty
  let F := Homeomorph.mulLeft (x * y⁻¹)
  refine' ⟨F '' K, _, K.is_compact.image F.continuous⟩
  suffices F.symm ⁻¹' K ∈ 𝓝 x by convert this; apply Equiv.image_eq_preimage
  apply ContinuousAt.preimage_mem_nhds F.symm.continuous.continuous_at
  have : F.symm x = y := by simp [F, Homeomorph.mulLeft_symm]
  rw [this]
  exact mem_interior_iff_mem_nhds.1 hy
#align topological_space.positive_compacts.locally_compact_space_of_group TopologicalSpace.PositiveCompacts.locallyCompactSpace_of_group
#align topological_space.positive_compacts.locally_compact_space_of_add_group TopologicalSpace.PositiveCompacts.locallyCompactSpace_of_addGroup
-/

end

section Quotient

variable [Group G] [TopologicalSpace G] [TopologicalGroup G] {Γ : Subgroup G}

#print QuotientGroup.continuousSMul /-
@[to_additive]
instance QuotientGroup.continuousSMul [LocallyCompactSpace G] : ContinuousSMul G (G ⧸ Γ)
    where continuous_smul :=
    by
    let F : G × G ⧸ Γ → G ⧸ Γ := fun p => p.1 • p.2
    change Continuous F
    have H : Continuous (F ∘ fun p : G × G => (p.1, QuotientGroup.mk p.2)) :=
      by
      change Continuous fun p : G × G => QuotientGroup.mk (p.1 * p.2)
      refine' continuous_coinduced_rng.comp continuous_mul
    exact QuotientMap.continuous_lift_prod_right quotientMap_quotient_mk' H
#align quotient_group.has_continuous_smul QuotientGroup.continuousSMul
#align quotient_add_group.has_continuous_vadd QuotientAddGroup.continuousVAdd
-/

end Quotient

