/-
Copyright (c) 2021 Patrick Massot. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Massot, Yury Kudryashov

! This file was ported from Lean 3 source module topology.algebra.order.compact
! leanprover-community/mathlib commit dc6c365e751e34d100e80fe6e314c3c3e0fd2988
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Algebra.Order.IntermediateValue
import Mathbin.Topology.LocalExtr

/-!
# Compactness of a closed interval

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove that a closed interval in a conditionally complete linear ordered type with
order topology (or a product of such types) is compact.

We prove the extreme value theorem (`is_compact.exists_forall_le`, `is_compact.exists_forall_ge`):
a continuous function on a compact set takes its minimum and maximum values. We provide many
variations of this theorem.

We also prove that the image of a closed interval under a continuous map is a closed interval, see
`continuous_on.image_Icc`.

## Tags

compact, extreme value theorem
-/


open Filter OrderDual TopologicalSpace Function Set

open Filter Topology

/-!
### Compactness of a closed interval

In this section we define a typeclass `compact_Icc_space α` saying that all closed intervals in `α`
are compact. Then we provide an instance for a `conditionally_complete_linear_order` and prove that
the product (both `α × β` and an indexed product) of spaces with this property inherits the
property.

We also prove some simple lemmas about spaces with this property.
-/


#print CompactIccSpace /-
/-- This typeclass says that all closed intervals in `α` are compact. This is true for all
conditionally complete linear orders with order topology and products (finite or infinite)
of such spaces. -/
class CompactIccSpace (α : Type _) [TopologicalSpace α] [Preorder α] : Prop where
  isCompact_Icc : ∀ {a b : α}, IsCompact (Icc a b)
#align compact_Icc_space CompactIccSpace
-/

export CompactIccSpace (isCompact_Icc)

#print ConditionallyCompleteLinearOrder.toCompactIccSpace /-
/-- A closed interval in a conditionally complete linear order is compact. -/
instance (priority := 100) ConditionallyCompleteLinearOrder.toCompactIccSpace (α : Type _)
    [ConditionallyCompleteLinearOrder α] [TopologicalSpace α] [OrderTopology α] :
    CompactIccSpace α := by
  refine' ⟨fun a b => _⟩
  cases' le_or_lt a b with hab hab
  swap
  · simp [hab]
  refine' isCompact_iff_ultrafilter_le_nhds.2 fun f hf => _
  contrapose! hf
  rw [le_principal_iff]
  have hpt : ∀ x ∈ Icc a b, {x} ∉ f := fun x hx hxf =>
    hf x hx ((le_pure_iff.2 hxf).trans (pure_le_nhds x))
  set s := { x ∈ Icc a b | Icc a x ∉ f }
  have hsb : b ∈ upperBounds s := fun x hx => hx.1.2
  have sbd : BddAbove s := ⟨b, hsb⟩
  have ha : a ∈ s := by simp [hpt, hab]
  rcases hab.eq_or_lt with (rfl | hlt)
  · exact ha.2
  set c := Sup s
  have hsc : IsLUB s c := isLUB_csupₛ ⟨a, ha⟩ sbd
  have hc : c ∈ Icc a b := ⟨hsc.1 ha, hsc.2 hsb⟩
  specialize hf c hc
  have hcs : c ∈ s := by
    cases' hc.1.eq_or_lt with heq hlt
    · rwa [← HEq]
    refine' ⟨hc, fun hcf => hf fun U hU => _⟩
    rcases(mem_nhdsWithin_Iic_iff_exists_Ioc_subset' hlt).1 (mem_nhdsWithin_of_mem_nhds hU) with
      ⟨x, hxc, hxU⟩
    rcases((hsc.frequently_mem ⟨a, ha⟩).and_eventually
          (Ioc_mem_nhdsWithin_Iic ⟨hxc, le_rfl⟩)).exists with
      ⟨y, ⟨hyab, hyf⟩, hy⟩
    refine' mem_of_superset (f.diff_mem_iff.2 ⟨hcf, hyf⟩) (subset.trans _ hxU)
    rw [diff_subset_iff]
    exact
      subset.trans Icc_subset_Icc_union_Ioc
        (union_subset_union subset.rfl <| Ioc_subset_Ioc_left hy.1.le)
  cases' hc.2.eq_or_lt with heq hlt
  · rw [← HEq]
    exact hcs.2
  contrapose! hf
  intro U hU
  rcases(mem_nhdsWithin_Ici_iff_exists_mem_Ioc_Ico_subset hlt).1
      (mem_nhdsWithin_of_mem_nhds hU) with
    ⟨y, hxy, hyU⟩
  refine' mem_of_superset _ hyU
  clear! U
  have hy : y ∈ Icc a b := ⟨hc.1.trans hxy.1.le, hxy.2⟩
  by_cases hay : Icc a y ∈ f
  · refine' mem_of_superset (f.diff_mem_iff.2 ⟨f.diff_mem_iff.2 ⟨hay, hcs.2⟩, hpt y hy⟩) _
    rw [diff_subset_iff, union_comm, Ico_union_right hxy.1.le, diff_subset_iff]
    exact Icc_subset_Icc_union_Icc
  · exact ((hsc.1 ⟨hy, hay⟩).not_lt hxy.1).elim
#align conditionally_complete_linear_order.to_compact_Icc_space ConditionallyCompleteLinearOrder.toCompactIccSpace
-/

instance {ι : Type _} {α : ι → Type _} [∀ i, Preorder (α i)] [∀ i, TopologicalSpace (α i)]
    [∀ i, CompactIccSpace (α i)] : CompactIccSpace (∀ i, α i) :=
  ⟨fun a b => (pi_univ_Icc a b ▸ isCompact_univ_pi) fun i => isCompact_Icc⟩

#print Pi.compact_Icc_space' /-
instance Pi.compact_Icc_space' {α β : Type _} [Preorder β] [TopologicalSpace β]
    [CompactIccSpace β] : CompactIccSpace (α → β) :=
  Pi.compactIccSpace
#align pi.compact_Icc_space' Pi.compact_Icc_space'
-/

instance {α β : Type _} [Preorder α] [TopologicalSpace α] [CompactIccSpace α] [Preorder β]
    [TopologicalSpace β] [CompactIccSpace β] : CompactIccSpace (α × β) :=
  ⟨fun a b => (Icc_prod_eq a b).symm ▸ isCompact_Icc.Prod isCompact_Icc⟩

#print isCompact_uIcc /-
/-- An unordered closed interval is compact. -/
theorem isCompact_uIcc {α : Type _} [LinearOrder α] [TopologicalSpace α] [CompactIccSpace α]
    {a b : α} : IsCompact (uIcc a b) :=
  isCompact_Icc
#align is_compact_uIcc isCompact_uIcc
-/

#print compactSpace_of_completeLinearOrder /-
-- See note [lower instance priority]
/-- A complete linear order is a compact space.

We do not register an instance for a `[compact_Icc_space α]` because this would only add instances
for products (indexed or not) of complete linear orders, and we have instances with higher priority
that cover these cases. -/
instance (priority := 100) compactSpace_of_completeLinearOrder {α : Type _} [CompleteLinearOrder α]
    [TopologicalSpace α] [OrderTopology α] : CompactSpace α :=
  ⟨by simp only [← Icc_bot_top, is_compact_Icc]⟩
#align compact_space_of_complete_linear_order compactSpace_of_completeLinearOrder
-/

section

variable {α : Type _} [Preorder α] [TopologicalSpace α] [CompactIccSpace α]

#print compactSpace_Icc /-
instance compactSpace_Icc (a b : α) : CompactSpace (Icc a b) :=
  isCompact_iff_compactSpace.mp isCompact_Icc
#align compact_space_Icc compactSpace_Icc
-/

end

/-!
### Min and max elements of a compact set
-/


variable {α β γ : Type _} [ConditionallyCompleteLinearOrder α] [TopologicalSpace α]
  [OrderTopology α] [TopologicalSpace β] [TopologicalSpace γ]

/- warning: is_compact.Inf_mem -> IsCompact.infₛ_mem is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) (InfSet.infₛ.{u1} α (ConditionallyCompleteLattice.toHasInf.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s) s)
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) (InfSet.infₛ.{u1} α (ConditionallyCompleteLattice.toInfSet.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s) s)
Case conversion may be inaccurate. Consider using '#align is_compact.Inf_mem IsCompact.infₛ_memₓ'. -/
theorem IsCompact.infₛ_mem {s : Set α} (hs : IsCompact s) (ne_s : s.Nonempty) : infₛ s ∈ s :=
  hs.IsClosed.cinfₛ_mem ne_s hs.BddBelow
#align is_compact.Inf_mem IsCompact.infₛ_mem

/- warning: is_compact.Sup_mem -> IsCompact.supₛ_mem is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) (SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toHasSup.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s) s)
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) (SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toSupSet.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s) s)
Case conversion may be inaccurate. Consider using '#align is_compact.Sup_mem IsCompact.supₛ_memₓ'. -/
theorem IsCompact.supₛ_mem {s : Set α} (hs : IsCompact s) (ne_s : s.Nonempty) : supₛ s ∈ s :=
  @IsCompact.infₛ_mem αᵒᵈ _ _ _ _ hs ne_s
#align is_compact.Sup_mem IsCompact.supₛ_mem

/- warning: is_compact.is_glb_Inf -> IsCompact.isGLB_infₛ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (IsGLB.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) s (InfSet.infₛ.{u1} α (ConditionallyCompleteLattice.toHasInf.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (IsGLB.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) s (InfSet.infₛ.{u1} α (ConditionallyCompleteLattice.toInfSet.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s))
Case conversion may be inaccurate. Consider using '#align is_compact.is_glb_Inf IsCompact.isGLB_infₛₓ'. -/
theorem IsCompact.isGLB_infₛ {s : Set α} (hs : IsCompact s) (ne_s : s.Nonempty) :
    IsGLB s (infₛ s) :=
  isGLB_cinfₛ ne_s hs.BddBelow
#align is_compact.is_glb_Inf IsCompact.isGLB_infₛ

/- warning: is_compact.is_lub_Sup -> IsCompact.isLUB_supₛ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (IsLUB.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) s (SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toHasSup.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (IsLUB.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) s (SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toSupSet.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s))
Case conversion may be inaccurate. Consider using '#align is_compact.is_lub_Sup IsCompact.isLUB_supₛₓ'. -/
theorem IsCompact.isLUB_supₛ {s : Set α} (hs : IsCompact s) (ne_s : s.Nonempty) :
    IsLUB s (supₛ s) :=
  @IsCompact.isGLB_infₛ αᵒᵈ _ _ _ _ hs ne_s
#align is_compact.is_lub_Sup IsCompact.isLUB_supₛ

/- warning: is_compact.is_least_Inf -> IsCompact.isLeast_infₛ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (IsLeast.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) s (InfSet.infₛ.{u1} α (ConditionallyCompleteLattice.toHasInf.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (IsLeast.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) s (InfSet.infₛ.{u1} α (ConditionallyCompleteLattice.toInfSet.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s))
Case conversion may be inaccurate. Consider using '#align is_compact.is_least_Inf IsCompact.isLeast_infₛₓ'. -/
theorem IsCompact.isLeast_infₛ {s : Set α} (hs : IsCompact s) (ne_s : s.Nonempty) :
    IsLeast s (infₛ s) :=
  ⟨hs.cinfₛ_mem ne_s, (hs.isGLB_infₛ ne_s).1⟩
#align is_compact.is_least_Inf IsCompact.isLeast_infₛ

/- warning: is_compact.is_greatest_Sup -> IsCompact.isGreatest_supₛ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (IsGreatest.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) s (SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toHasSup.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (IsGreatest.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) s (SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toSupSet.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s))
Case conversion may be inaccurate. Consider using '#align is_compact.is_greatest_Sup IsCompact.isGreatest_supₛₓ'. -/
theorem IsCompact.isGreatest_supₛ {s : Set α} (hs : IsCompact s) (ne_s : s.Nonempty) :
    IsGreatest s (supₛ s) :=
  @IsCompact.isLeast_infₛ αᵒᵈ _ _ _ _ hs ne_s
#align is_compact.is_greatest_Sup IsCompact.isGreatest_supₛ

#print IsCompact.exists_isLeast /-
theorem IsCompact.exists_isLeast {s : Set α} (hs : IsCompact s) (ne_s : s.Nonempty) :
    ∃ x, IsLeast s x :=
  ⟨_, hs.isLeast_cinfₛ ne_s⟩
#align is_compact.exists_is_least IsCompact.exists_isLeast
-/

#print IsCompact.exists_isGreatest /-
theorem IsCompact.exists_isGreatest {s : Set α} (hs : IsCompact s) (ne_s : s.Nonempty) :
    ∃ x, IsGreatest s x :=
  ⟨_, hs.isGreatest_supₛ ne_s⟩
#align is_compact.exists_is_greatest IsCompact.exists_isGreatest
-/

/- warning: is_compact.exists_is_glb -> IsCompact.exists_isGLB is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (Exists.{succ u1} α (fun (x : α) => Exists.{0} (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) (fun (H : Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) => IsGLB.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) s x)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (Exists.{succ u1} α (fun (x : α) => And (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) (IsGLB.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) s x)))
Case conversion may be inaccurate. Consider using '#align is_compact.exists_is_glb IsCompact.exists_isGLBₓ'. -/
theorem IsCompact.exists_isGLB {s : Set α} (hs : IsCompact s) (ne_s : s.Nonempty) :
    ∃ x ∈ s, IsGLB s x :=
  ⟨_, hs.cinfₛ_mem ne_s, hs.isGLB_infₛ ne_s⟩
#align is_compact.exists_is_glb IsCompact.exists_isGLB

/- warning: is_compact.exists_is_lub -> IsCompact.exists_isLUB is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (Exists.{succ u1} α (fun (x : α) => Exists.{0} (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) (fun (H : Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) => IsLUB.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) s x)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsCompact.{u1} α _inst_2 s) -> (Set.Nonempty.{u1} α s) -> (Exists.{succ u1} α (fun (x : α) => And (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) (IsLUB.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) s x)))
Case conversion may be inaccurate. Consider using '#align is_compact.exists_is_lub IsCompact.exists_isLUBₓ'. -/
theorem IsCompact.exists_isLUB {s : Set α} (hs : IsCompact s) (ne_s : s.Nonempty) :
    ∃ x ∈ s, IsLUB s x :=
  ⟨_, hs.csupₛ_mem ne_s, hs.isLUB_supₛ ne_s⟩
#align is_compact.exists_is_lub IsCompact.exists_isLUB

/- warning: is_compact.exists_Inf_image_eq_and_le -> IsCompact.exists_infₛ_image_eq_and_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β}, (IsCompact.{u2} β _inst_4 s) -> (Set.Nonempty.{u2} β s) -> (forall {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (Exists.{succ u2} β (fun (x : β) => Exists.{0} (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) (fun (H : Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) => And (Eq.{succ u1} α (InfSet.infₛ.{u1} α (ConditionallyCompleteLattice.toHasInf.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) (Set.image.{u2, u1} β α f s)) (f x)) (forall (y : β), (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) y s) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f x) (f y)))))))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β}, (IsCompact.{u2} β _inst_4 s) -> (Set.Nonempty.{u2} β s) -> (forall {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (Exists.{succ u2} β (fun (x : β) => And (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) x s) (And (Eq.{succ u1} α (InfSet.infₛ.{u1} α (ConditionallyCompleteLattice.toInfSet.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) (Set.image.{u2, u1} β α f s)) (f x)) (forall (y : β), (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) y s) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f x) (f y)))))))
Case conversion may be inaccurate. Consider using '#align is_compact.exists_Inf_image_eq_and_le IsCompact.exists_infₛ_image_eq_and_leₓ'. -/
theorem IsCompact.exists_infₛ_image_eq_and_le {s : Set β} (hs : IsCompact s) (ne_s : s.Nonempty)
    {f : β → α} (hf : ContinuousOn f s) : ∃ x ∈ s, infₛ (f '' s) = f x ∧ ∀ y ∈ s, f x ≤ f y :=
  let ⟨x, hxs, hx⟩ := (hs.image_of_continuousOn hf).cinfₛ_mem (ne_s.image f)
  ⟨x, hxs, hx.symm, fun y hy =>
    hx.trans_le <| cinfₛ_le (hs.image_of_continuousOn hf).BddBelow <| mem_image_of_mem f hy⟩
#align is_compact.exists_Inf_image_eq_and_le IsCompact.exists_infₛ_image_eq_and_le

/- warning: is_compact.exists_Sup_image_eq_and_ge -> IsCompact.exists_supₛ_image_eq_and_ge is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β}, (IsCompact.{u2} β _inst_4 s) -> (Set.Nonempty.{u2} β s) -> (forall {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (Exists.{succ u2} β (fun (x : β) => Exists.{0} (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) (fun (H : Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) => And (Eq.{succ u1} α (SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toHasSup.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) (Set.image.{u2, u1} β α f s)) (f x)) (forall (y : β), (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) y s) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f y) (f x)))))))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β}, (IsCompact.{u2} β _inst_4 s) -> (Set.Nonempty.{u2} β s) -> (forall {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (Exists.{succ u2} β (fun (x : β) => And (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) x s) (And (Eq.{succ u1} α (SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toSupSet.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) (Set.image.{u2, u1} β α f s)) (f x)) (forall (y : β), (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) y s) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f y) (f x)))))))
Case conversion may be inaccurate. Consider using '#align is_compact.exists_Sup_image_eq_and_ge IsCompact.exists_supₛ_image_eq_and_geₓ'. -/
theorem IsCompact.exists_supₛ_image_eq_and_ge {s : Set β} (hs : IsCompact s) (ne_s : s.Nonempty)
    {f : β → α} (hf : ContinuousOn f s) : ∃ x ∈ s, supₛ (f '' s) = f x ∧ ∀ y ∈ s, f y ≤ f x :=
  @IsCompact.exists_infₛ_image_eq_and_le αᵒᵈ _ _ _ _ _ _ hs ne_s _ hf
#align is_compact.exists_Sup_image_eq_and_ge IsCompact.exists_supₛ_image_eq_and_ge

/- warning: is_compact.exists_Inf_image_eq -> IsCompact.exists_infₛ_image_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β}, (IsCompact.{u2} β _inst_4 s) -> (Set.Nonempty.{u2} β s) -> (forall {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (Exists.{succ u2} β (fun (x : β) => Exists.{0} (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) (fun (H : Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) => Eq.{succ u1} α (InfSet.infₛ.{u1} α (ConditionallyCompleteLattice.toHasInf.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) (Set.image.{u2, u1} β α f s)) (f x)))))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β}, (IsCompact.{u2} β _inst_4 s) -> (Set.Nonempty.{u2} β s) -> (forall {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (Exists.{succ u2} β (fun (x : β) => And (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) x s) (Eq.{succ u1} α (InfSet.infₛ.{u1} α (ConditionallyCompleteLattice.toInfSet.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) (Set.image.{u2, u1} β α f s)) (f x)))))
Case conversion may be inaccurate. Consider using '#align is_compact.exists_Inf_image_eq IsCompact.exists_infₛ_image_eqₓ'. -/
theorem IsCompact.exists_infₛ_image_eq {s : Set β} (hs : IsCompact s) (ne_s : s.Nonempty)
    {f : β → α} (hf : ContinuousOn f s) : ∃ x ∈ s, infₛ (f '' s) = f x :=
  let ⟨x, hxs, hx, _⟩ := hs.exists_infₛ_image_eq_and_le ne_s hf
  ⟨x, hxs, hx⟩
#align is_compact.exists_Inf_image_eq IsCompact.exists_infₛ_image_eq

/- warning: is_compact.exists_Sup_image_eq -> IsCompact.exists_supₛ_image_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β}, (IsCompact.{u2} β _inst_4 s) -> (Set.Nonempty.{u2} β s) -> (forall {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (Exists.{succ u2} β (fun (x : β) => Exists.{0} (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) (fun (H : Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) => Eq.{succ u1} α (SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toHasSup.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) (Set.image.{u2, u1} β α f s)) (f x)))))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β}, (IsCompact.{u2} β _inst_4 s) -> (Set.Nonempty.{u2} β s) -> (forall {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (Exists.{succ u2} β (fun (x : β) => And (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) x s) (Eq.{succ u1} α (SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toSupSet.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) (Set.image.{u2, u1} β α f s)) (f x)))))
Case conversion may be inaccurate. Consider using '#align is_compact.exists_Sup_image_eq IsCompact.exists_supₛ_image_eqₓ'. -/
theorem IsCompact.exists_supₛ_image_eq :
    ∀ {s : Set β},
      IsCompact s → s.Nonempty → ∀ {f : β → α}, ContinuousOn f s → ∃ x ∈ s, supₛ (f '' s) = f x :=
  @IsCompact.exists_infₛ_image_eq αᵒᵈ _ _ _ _ _
#align is_compact.exists_Sup_image_eq IsCompact.exists_supₛ_image_eq

/- warning: eq_Icc_of_connected_compact -> eq_Icc_of_connected_compact is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsConnected.{u1} α _inst_2 s) -> (IsCompact.{u1} α _inst_2 s) -> (Eq.{succ u1} (Set.{u1} α) s (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) (InfSet.infₛ.{u1} α (ConditionallyCompleteLattice.toHasInf.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s) (SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toHasSup.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] {s : Set.{u1} α}, (IsConnected.{u1} α _inst_2 s) -> (IsCompact.{u1} α _inst_2 s) -> (Eq.{succ u1} (Set.{u1} α) s (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) (InfSet.infₛ.{u1} α (ConditionallyCompleteLattice.toInfSet.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s) (SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toSupSet.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) s)))
Case conversion may be inaccurate. Consider using '#align eq_Icc_of_connected_compact eq_Icc_of_connected_compactₓ'. -/
theorem eq_Icc_of_connected_compact {s : Set α} (h₁ : IsConnected s) (h₂ : IsCompact s) :
    s = Icc (infₛ s) (supₛ s) :=
  eq_Icc_cinfₛ_csupₛ_of_connected_bdd_closed h₁ h₂.BddBelow h₂.BddAbove h₂.IsClosed
#align eq_Icc_of_connected_compact eq_Icc_of_connected_compact

/-!
### Extreme value theorem
-/


/- warning: is_compact.exists_forall_le -> IsCompact.exists_forall_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β}, (IsCompact.{u2} β _inst_4 s) -> (Set.Nonempty.{u2} β s) -> (forall {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (Exists.{succ u2} β (fun (x : β) => Exists.{0} (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) (fun (H : Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) => forall (y : β), (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) y s) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f x) (f y))))))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β}, (IsCompact.{u2} β _inst_4 s) -> (Set.Nonempty.{u2} β s) -> (forall {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (Exists.{succ u2} β (fun (x : β) => And (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) x s) (forall (y : β), (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) y s) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f x) (f y))))))
Case conversion may be inaccurate. Consider using '#align is_compact.exists_forall_le IsCompact.exists_forall_leₓ'. -/
/-- The **extreme value theorem**: a continuous function realizes its minimum on a compact set. -/
theorem IsCompact.exists_forall_le {s : Set β} (hs : IsCompact s) (ne_s : s.Nonempty) {f : β → α}
    (hf : ContinuousOn f s) : ∃ x ∈ s, ∀ y ∈ s, f x ≤ f y :=
  by
  rcases(hs.image_of_continuous_on hf).exists_isLeast (ne_s.image f) with ⟨_, ⟨x, hxs, rfl⟩, hx⟩
  exact ⟨x, hxs, ball_image_iff.1 hx⟩
#align is_compact.exists_forall_le IsCompact.exists_forall_le

/- warning: is_compact.exists_forall_ge -> IsCompact.exists_forall_ge is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β}, (IsCompact.{u2} β _inst_4 s) -> (Set.Nonempty.{u2} β s) -> (forall {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (Exists.{succ u2} β (fun (x : β) => Exists.{0} (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) (fun (H : Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) => forall (y : β), (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) y s) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f y) (f x))))))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β}, (IsCompact.{u2} β _inst_4 s) -> (Set.Nonempty.{u2} β s) -> (forall {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (Exists.{succ u2} β (fun (x : β) => And (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) x s) (forall (y : β), (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) y s) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f y) (f x))))))
Case conversion may be inaccurate. Consider using '#align is_compact.exists_forall_ge IsCompact.exists_forall_geₓ'. -/
/-- The **extreme value theorem**: a continuous function realizes its maximum on a compact set. -/
theorem IsCompact.exists_forall_ge :
    ∀ {s : Set β},
      IsCompact s → s.Nonempty → ∀ {f : β → α}, ContinuousOn f s → ∃ x ∈ s, ∀ y ∈ s, f y ≤ f x :=
  @IsCompact.exists_forall_le αᵒᵈ _ _ _ _ _
#align is_compact.exists_forall_ge IsCompact.exists_forall_ge

/- warning: continuous_on.exists_forall_le' -> ContinuousOn.exists_forall_le' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β} {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (IsClosed.{u2} β _inst_4 s) -> (forall {x₀ : β}, (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x₀ s) -> (Filter.Eventually.{u2} β (fun (x : β) => LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f x₀) (f x)) (HasInf.inf.{u2} (Filter.{u2} β) (Filter.hasInf.{u2} β) (Filter.cocompact.{u2} β _inst_4) (Filter.principal.{u2} β s))) -> (Exists.{succ u2} β (fun (x : β) => Exists.{0} (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) (fun (H : Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) => forall (y : β), (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) y s) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f x) (f y))))))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β} {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (IsClosed.{u2} β _inst_4 s) -> (forall {x₀ : β}, (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) x₀ s) -> (Filter.Eventually.{u2} β (fun (x : β) => LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f x₀) (f x)) (HasInf.inf.{u2} (Filter.{u2} β) (Filter.instHasInfFilter.{u2} β) (Filter.cocompact.{u2} β _inst_4) (Filter.principal.{u2} β s))) -> (Exists.{succ u2} β (fun (x : β) => And (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) x s) (forall (y : β), (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) y s) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f x) (f y))))))
Case conversion may be inaccurate. Consider using '#align continuous_on.exists_forall_le' ContinuousOn.exists_forall_le'ₓ'. -/
/-- The **extreme value theorem**: if a function `f` is continuous on a closed set `s` and it is
larger than a value in its image away from compact sets, then it has a minimum on this set. -/
theorem ContinuousOn.exists_forall_le' {s : Set β} {f : β → α} (hf : ContinuousOn f s)
    (hsc : IsClosed s) {x₀ : β} (h₀ : x₀ ∈ s) (hc : ∀ᶠ x in cocompact β ⊓ 𝓟 s, f x₀ ≤ f x) :
    ∃ x ∈ s, ∀ y ∈ s, f x ≤ f y :=
  by
  rcases(has_basis_cocompact.inf_principal _).eventually_iff.1 hc with ⟨K, hK, hKf⟩
  have hsub : insert x₀ (K ∩ s) ⊆ s := insert_subset.2 ⟨h₀, inter_subset_right _ _⟩
  obtain ⟨x, hx, hxf⟩ : ∃ x ∈ insert x₀ (K ∩ s), ∀ y ∈ insert x₀ (K ∩ s), f x ≤ f y :=
    ((hK.inter_right hsc).insert x₀).exists_forall_le (insert_nonempty _ _) (hf.mono hsub)
  refine' ⟨x, hsub hx, fun y hy => _⟩
  by_cases hyK : y ∈ K
  exacts[hxf _ (Or.inr ⟨hyK, hy⟩), (hxf _ (Or.inl rfl)).trans (hKf ⟨hyK, hy⟩)]
#align continuous_on.exists_forall_le' ContinuousOn.exists_forall_le'

/- warning: continuous_on.exists_forall_ge' -> ContinuousOn.exists_forall_ge' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β} {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (IsClosed.{u2} β _inst_4 s) -> (forall {x₀ : β}, (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x₀ s) -> (Filter.Eventually.{u2} β (fun (x : β) => LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f x) (f x₀)) (HasInf.inf.{u2} (Filter.{u2} β) (Filter.hasInf.{u2} β) (Filter.cocompact.{u2} β _inst_4) (Filter.principal.{u2} β s))) -> (Exists.{succ u2} β (fun (x : β) => Exists.{0} (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) (fun (H : Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) => forall (y : β), (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) y s) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f y) (f x))))))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {s : Set.{u2} β} {f : β -> α}, (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f s) -> (IsClosed.{u2} β _inst_4 s) -> (forall {x₀ : β}, (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) x₀ s) -> (Filter.Eventually.{u2} β (fun (x : β) => LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f x) (f x₀)) (HasInf.inf.{u2} (Filter.{u2} β) (Filter.instHasInfFilter.{u2} β) (Filter.cocompact.{u2} β _inst_4) (Filter.principal.{u2} β s))) -> (Exists.{succ u2} β (fun (x : β) => And (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) x s) (forall (y : β), (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) y s) -> (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f y) (f x))))))
Case conversion may be inaccurate. Consider using '#align continuous_on.exists_forall_ge' ContinuousOn.exists_forall_ge'ₓ'. -/
/-- The **extreme value theorem**: if a function `f` is continuous on a closed set `s` and it is
smaller than a value in its image away from compact sets, then it has a maximum on this set. -/
theorem ContinuousOn.exists_forall_ge' {s : Set β} {f : β → α} (hf : ContinuousOn f s)
    (hsc : IsClosed s) {x₀ : β} (h₀ : x₀ ∈ s) (hc : ∀ᶠ x in cocompact β ⊓ 𝓟 s, f x ≤ f x₀) :
    ∃ x ∈ s, ∀ y ∈ s, f y ≤ f x :=
  @ContinuousOn.exists_forall_le' αᵒᵈ _ _ _ _ _ _ _ hf hsc _ h₀ hc
#align continuous_on.exists_forall_ge' ContinuousOn.exists_forall_ge'

#print Continuous.exists_forall_le' /-
/-- The **extreme value theorem**: if a continuous function `f` is larger than a value in its range
away from compact sets, then it has a global minimum. -/
theorem Continuous.exists_forall_le' {f : β → α} (hf : Continuous f) (x₀ : β)
    (h : ∀ᶠ x in cocompact β, f x₀ ≤ f x) : ∃ x : β, ∀ y : β, f x ≤ f y :=
  let ⟨x, _, hx⟩ :=
    hf.ContinuousOn.exists_forall_le' isClosed_univ (mem_univ x₀)
      (by rwa [principal_univ, inf_top_eq])
  ⟨x, fun y => hx y (mem_univ y)⟩
#align continuous.exists_forall_le' Continuous.exists_forall_le'
-/

#print Continuous.exists_forall_ge' /-
/-- The **extreme value theorem**: if a continuous function `f` is smaller than a value in its range
away from compact sets, then it has a global maximum. -/
theorem Continuous.exists_forall_ge' {f : β → α} (hf : Continuous f) (x₀ : β)
    (h : ∀ᶠ x in cocompact β, f x ≤ f x₀) : ∃ x : β, ∀ y : β, f y ≤ f x :=
  @Continuous.exists_forall_le' αᵒᵈ _ _ _ _ _ _ hf x₀ h
#align continuous.exists_forall_ge' Continuous.exists_forall_ge'
-/

#print Continuous.exists_forall_le /-
/-- The **extreme value theorem**: if a continuous function `f` tends to infinity away from compact
sets, then it has a global minimum. -/
theorem Continuous.exists_forall_le [Nonempty β] {f : β → α} (hf : Continuous f)
    (hlim : Tendsto f (cocompact β) atTop) : ∃ x, ∀ y, f x ≤ f y :=
  by
  inhabit β
  exact hf.exists_forall_le' default (hlim.eventually <| eventually_ge_at_top _)
#align continuous.exists_forall_le Continuous.exists_forall_le
-/

#print Continuous.exists_forall_ge /-
/-- The **extreme value theorem**: if a continuous function `f` tends to negative infinity away from
compact sets, then it has a global maximum. -/
theorem Continuous.exists_forall_ge [Nonempty β] {f : β → α} (hf : Continuous f)
    (hlim : Tendsto f (cocompact β) atBot) : ∃ x, ∀ y, f y ≤ f x :=
  @Continuous.exists_forall_le αᵒᵈ _ _ _ _ _ _ _ hf hlim
#align continuous.exists_forall_ge Continuous.exists_forall_ge
-/

/- warning: is_compact.Sup_lt_iff_of_continuous -> IsCompact.supₛ_lt_iff_of_continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {f : β -> α} {K : Set.{u2} β}, (IsCompact.{u2} β _inst_4 K) -> (Set.Nonempty.{u2} β K) -> (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f K) -> (forall (y : α), Iff (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toHasSup.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) (Set.image.{u2, u1} β α f K)) y) (forall (x : β), (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x K) -> (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f x) y)))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {f : β -> α} {K : Set.{u2} β}, (IsCompact.{u2} β _inst_4 K) -> (Set.Nonempty.{u2} β K) -> (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f K) -> (forall (y : α), Iff (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toSupSet.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) (Set.image.{u2, u1} β α f K)) y) (forall (x : β), (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) x K) -> (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f x) y)))
Case conversion may be inaccurate. Consider using '#align is_compact.Sup_lt_iff_of_continuous IsCompact.supₛ_lt_iff_of_continuousₓ'. -/
theorem IsCompact.supₛ_lt_iff_of_continuous {f : β → α} {K : Set β} (hK : IsCompact K)
    (h0K : K.Nonempty) (hf : ContinuousOn f K) (y : α) : supₛ (f '' K) < y ↔ ∀ x ∈ K, f x < y :=
  by
  refine'
    ⟨fun h x hx => (le_csupₛ (hK.bdd_above_image hf) <| mem_image_of_mem f hx).trans_lt h, fun h =>
      _⟩
  obtain ⟨x, hx, h2x⟩ := hK.exists_forall_ge h0K hf
  refine' (csupₛ_le (h0K.image f) _).trans_lt (h x hx)
  rintro _ ⟨x', hx', rfl⟩; exact h2x x' hx'
#align is_compact.Sup_lt_iff_of_continuous IsCompact.supₛ_lt_iff_of_continuous

/- warning: is_compact.lt_Inf_iff_of_continuous -> IsCompact.lt_infₛ_iff_of_continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_6 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_7 : TopologicalSpace.{u1} α] [_inst_8 : OrderTopology.{u1} α _inst_7 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_6)))))] [_inst_9 : TopologicalSpace.{u2} β] {f : β -> α} {K : Set.{u2} β}, (IsCompact.{u2} β _inst_9 K) -> (Set.Nonempty.{u2} β K) -> (ContinuousOn.{u2, u1} β α _inst_9 _inst_7 f K) -> (forall (y : α), Iff (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_6)))))) y (InfSet.infₛ.{u1} α (ConditionallyCompleteLattice.toHasInf.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_6)) (Set.image.{u2, u1} β α f K))) (forall (x : β), (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x K) -> (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_6)))))) y (f x))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_6 : ConditionallyCompleteLinearOrder.{u2} α] [_inst_7 : TopologicalSpace.{u2} α] [_inst_8 : OrderTopology.{u2} α _inst_7 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_6)))))] [_inst_9 : TopologicalSpace.{u1} β] {f : β -> α} {K : Set.{u1} β}, (IsCompact.{u1} β _inst_9 K) -> (Set.Nonempty.{u1} β K) -> (ContinuousOn.{u1, u2} β α _inst_9 _inst_7 f K) -> (forall (y : α), Iff (LT.lt.{u2} α (Preorder.toLT.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_6)))))) y (InfSet.infₛ.{u2} α (ConditionallyCompleteLattice.toInfSet.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_6)) (Set.image.{u1, u2} β α f K))) (forall (x : β), (Membership.mem.{u1, u1} β (Set.{u1} β) (Set.instMembershipSet.{u1} β) x K) -> (LT.lt.{u2} α (Preorder.toLT.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_6)))))) y (f x))))
Case conversion may be inaccurate. Consider using '#align is_compact.lt_Inf_iff_of_continuous IsCompact.lt_infₛ_iff_of_continuousₓ'. -/
theorem IsCompact.lt_infₛ_iff_of_continuous {α β : Type _} [ConditionallyCompleteLinearOrder α]
    [TopologicalSpace α] [OrderTopology α] [TopologicalSpace β] {f : β → α} {K : Set β}
    (hK : IsCompact K) (h0K : K.Nonempty) (hf : ContinuousOn f K) (y : α) :
    y < infₛ (f '' K) ↔ ∀ x ∈ K, y < f x :=
  @IsCompact.supₛ_lt_iff_of_continuous αᵒᵈ β _ _ _ _ _ _ hK h0K hf y
#align is_compact.lt_Inf_iff_of_continuous IsCompact.lt_infₛ_iff_of_continuous

#print Continuous.exists_forall_le_of_hasCompactMulSupport /-
/-- A continuous function with compact support has a global minimum. -/
@[to_additive "A continuous function with compact support has a global minimum."]
theorem Continuous.exists_forall_le_of_hasCompactMulSupport [Nonempty β] [One α] {f : β → α}
    (hf : Continuous f) (h : HasCompactMulSupport f) : ∃ x : β, ∀ y : β, f x ≤ f y :=
  by
  obtain ⟨_, ⟨x, rfl⟩, hx⟩ := (h.is_compact_range hf).exists_isLeast (range_nonempty _)
  rw [mem_lowerBounds, forall_range_iff] at hx
  exact ⟨x, hx⟩
#align continuous.exists_forall_le_of_has_compact_mul_support Continuous.exists_forall_le_of_hasCompactMulSupport
#align continuous.exists_forall_le_of_has_compact_support Continuous.exists_forall_le_of_hasCompactSupport
-/

#print Continuous.exists_forall_ge_of_hasCompactMulSupport /-
/-- A continuous function with compact support has a global maximum. -/
@[to_additive "A continuous function with compact support has a global maximum."]
theorem Continuous.exists_forall_ge_of_hasCompactMulSupport [Nonempty β] [One α] {f : β → α}
    (hf : Continuous f) (h : HasCompactMulSupport f) : ∃ x : β, ∀ y : β, f y ≤ f x :=
  @Continuous.exists_forall_le_of_hasCompactMulSupport αᵒᵈ _ _ _ _ _ _ _ _ hf h
#align continuous.exists_forall_ge_of_has_compact_mul_support Continuous.exists_forall_ge_of_hasCompactMulSupport
#align continuous.exists_forall_ge_of_has_compact_support Continuous.exists_forall_ge_of_hasCompactSupport
-/

/- warning: is_compact.continuous_Sup -> IsCompact.continuous_supₛ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] [_inst_5 : TopologicalSpace.{u3} γ] {f : γ -> β -> α} {K : Set.{u2} β}, (IsCompact.{u2} β _inst_4 K) -> (Continuous.{max u3 u2, u1} (Prod.{u3, u2} γ β) α (Prod.topologicalSpace.{u3, u2} γ β _inst_5 _inst_4) _inst_2 (Function.HasUncurry.uncurry.{max u3 u2 u1, max u3 u2, u1} (γ -> β -> α) (Prod.{u3, u2} γ β) α (Function.hasUncurryInduction.{u3, max u2 u1, u2, u1} γ (β -> α) β α (Function.hasUncurryBase.{u2, u1} β α)) f)) -> (Continuous.{u3, u1} γ α _inst_5 _inst_2 (fun (x : γ) => SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toHasSup.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) (Set.image.{u2, u1} β α (f x) K)))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u3} β] [_inst_5 : TopologicalSpace.{u2} γ] {f : γ -> β -> α} {K : Set.{u3} β}, (IsCompact.{u3} β _inst_4 K) -> (Continuous.{max u3 u2, u1} (Prod.{u2, u3} γ β) α (instTopologicalSpaceProd.{u2, u3} γ β _inst_5 _inst_4) _inst_2 (Function.HasUncurry.uncurry.{max (max u1 u3) u2, max u3 u2, u1} (γ -> β -> α) (Prod.{u2, u3} γ β) α (Function.hasUncurryInduction.{u2, max u1 u3, u3, u1} γ (β -> α) β α (Function.hasUncurryBase.{u3, u1} β α)) f)) -> (Continuous.{u2, u1} γ α _inst_5 _inst_2 (fun (x : γ) => SupSet.supₛ.{u1} α (ConditionallyCompleteLattice.toSupSet.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) (Set.image.{u3, u1} β α (f x) K)))
Case conversion may be inaccurate. Consider using '#align is_compact.continuous_Sup IsCompact.continuous_supₛₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem IsCompact.continuous_supₛ {f : γ → β → α} {K : Set β} (hK : IsCompact K)
    (hf : Continuous ↿f) : Continuous fun x => supₛ (f x '' K) :=
  by
  rcases eq_empty_or_nonempty K with (rfl | h0K)
  · simp_rw [image_empty]
    exact continuous_const
  rw [continuous_iff_continuousAt]
  intro x
  obtain ⟨y, hyK, h2y, hy⟩ :=
    hK.exists_Sup_image_eq_and_ge h0K
      (show Continuous fun y => f x y from hf.comp <| Continuous.Prod.mk x).ContinuousOn
  rw [ContinuousAt, h2y, tendsto_order]
  have :=
    tendsto_order.mp
      ((show Continuous fun x => f x y from
            hf.comp <| continuous_id.prod_mk continuous_const).Tendsto
        x)
  refine' ⟨fun z hz => _, fun z hz => _⟩
  · refine'
      (this.1 z hz).mono fun x' hx' => hx'.trans_le <| le_csupₛ _ <| mem_image_of_mem (f x') hyK
    exact hK.bdd_above_image (hf.comp <| Continuous.Prod.mk x').ContinuousOn
  · have h : ({x} : Set γ) ×ˢ K ⊆ ↿f ⁻¹' Iio z :=
      by
      rintro ⟨x', y'⟩ ⟨hx', hy'⟩
      cases hx'
      exact (hy y' hy').trans_lt hz
    obtain ⟨u, v, hu, hv, hxu, hKv, huv⟩ :=
      generalized_tube_lemma isCompact_singleton hK (is_open_Iio.preimage hf) h
    refine' eventually_of_mem (hu.mem_nhds (singleton_subset_iff.mp hxu)) fun x' hx' => _
    rw [hK.Sup_lt_iff_of_continuous h0K
        (show Continuous (f x') from hf.comp <| Continuous.Prod.mk x').ContinuousOn]
    exact fun y' hy' => huv (mk_mem_prod hx' (hKv hy'))
#align is_compact.continuous_Sup IsCompact.continuous_supₛ

/- warning: is_compact.continuous_Inf -> IsCompact.continuous_infₛ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] [_inst_5 : TopologicalSpace.{u3} γ] {f : γ -> β -> α} {K : Set.{u2} β}, (IsCompact.{u2} β _inst_4 K) -> (Continuous.{max u3 u2, u1} (Prod.{u3, u2} γ β) α (Prod.topologicalSpace.{u3, u2} γ β _inst_5 _inst_4) _inst_2 (Function.HasUncurry.uncurry.{max u3 u2 u1, max u3 u2, u1} (γ -> β -> α) (Prod.{u3, u2} γ β) α (Function.hasUncurryInduction.{u3, max u2 u1, u2, u1} γ (β -> α) β α (Function.hasUncurryBase.{u2, u1} β α)) f)) -> (Continuous.{u3, u1} γ α _inst_5 _inst_2 (fun (x : γ) => InfSet.infₛ.{u1} α (ConditionallyCompleteLattice.toHasInf.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) (Set.image.{u2, u1} β α (f x) K)))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u3}} {γ : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u3} β] [_inst_5 : TopologicalSpace.{u2} γ] {f : γ -> β -> α} {K : Set.{u3} β}, (IsCompact.{u3} β _inst_4 K) -> (Continuous.{max u3 u2, u1} (Prod.{u2, u3} γ β) α (instTopologicalSpaceProd.{u2, u3} γ β _inst_5 _inst_4) _inst_2 (Function.HasUncurry.uncurry.{max (max u1 u3) u2, max u3 u2, u1} (γ -> β -> α) (Prod.{u2, u3} γ β) α (Function.hasUncurryInduction.{u2, max u1 u3, u3, u1} γ (β -> α) β α (Function.hasUncurryBase.{u3, u1} β α)) f)) -> (Continuous.{u2, u1} γ α _inst_5 _inst_2 (fun (x : γ) => InfSet.infₛ.{u1} α (ConditionallyCompleteLattice.toInfSet.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) (Set.image.{u3, u1} β α (f x) K)))
Case conversion may be inaccurate. Consider using '#align is_compact.continuous_Inf IsCompact.continuous_infₛₓ'. -/
theorem IsCompact.continuous_infₛ {f : γ → β → α} {K : Set β} (hK : IsCompact K)
    (hf : Continuous ↿f) : Continuous fun x => infₛ (f x '' K) :=
  @IsCompact.continuous_supₛ αᵒᵈ β γ _ _ _ _ _ _ _ hK hf
#align is_compact.continuous_Inf IsCompact.continuous_infₛ

namespace ContinuousOn

/-!
### Image of a closed interval
-/


variable [DenselyOrdered α] [ConditionallyCompleteLinearOrder β] [OrderTopology β] {f : α → β}
  {a b c : α}

open Interval

/- warning: continuous_on.image_Icc -> ContinuousOn.image_Icc is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] [_inst_6 : DenselyOrdered.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))))] [_inst_7 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_8 : OrderTopology.{u2} β _inst_4 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)))))] {f : α -> β} {a : α} {b : α}, (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) a b) -> (ContinuousOn.{u1, u2} α β _inst_2 _inst_4 f (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) a b)) -> (Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β f (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) a b)) (Set.Icc.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7))))) (InfSet.infₛ.{u2} β (ConditionallyCompleteLattice.toHasInf.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)) (Set.image.{u1, u2} α β f (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) a b))) (SupSet.supₛ.{u2} β (ConditionallyCompleteLattice.toHasSup.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)) (Set.image.{u1, u2} α β f (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) a b)))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u2} α] [_inst_2 : TopologicalSpace.{u2} α] [_inst_3 : OrderTopology.{u2} α _inst_2 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u1} β] [_inst_6 : DenselyOrdered.{u2} α (Preorder.toLT.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1))))))] [_inst_7 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_8 : OrderTopology.{u1} β _inst_4 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)))))] {f : α -> β} {a : α} {b : α}, (LE.le.{u2} α (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1)))))) a b) -> (ContinuousOn.{u2, u1} α β _inst_2 _inst_4 f (Set.Icc.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1))))) a b)) -> (Eq.{succ u1} (Set.{u1} β) (Set.image.{u2, u1} α β f (Set.Icc.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1))))) a b)) (Set.Icc.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7))))) (InfSet.infₛ.{u1} β (ConditionallyCompleteLattice.toInfSet.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)) (Set.image.{u2, u1} α β f (Set.Icc.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1))))) a b))) (SupSet.supₛ.{u1} β (ConditionallyCompleteLattice.toSupSet.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)) (Set.image.{u2, u1} α β f (Set.Icc.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1))))) a b)))))
Case conversion may be inaccurate. Consider using '#align continuous_on.image_Icc ContinuousOn.image_Iccₓ'. -/
theorem image_Icc (hab : a ≤ b) (h : ContinuousOn f <| Icc a b) :
    f '' Icc a b = Icc (infₛ <| f '' Icc a b) (supₛ <| f '' Icc a b) :=
  eq_Icc_of_connected_compact ⟨(nonempty_Icc.2 hab).image f, isPreconnected_Icc.image f h⟩
    (isCompact_Icc.image_of_continuousOn h)
#align continuous_on.image_Icc ContinuousOn.image_Icc

/- warning: continuous_on.image_uIcc_eq_Icc -> ContinuousOn.image_uIcc_eq_Icc is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] [_inst_6 : DenselyOrdered.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))))] [_inst_7 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_8 : OrderTopology.{u2} β _inst_4 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)))))] {f : α -> β} {a : α} {b : α}, (ContinuousOn.{u1, u2} α β _inst_2 _inst_4 f (Set.uIcc.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) a b)) -> (Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β f (Set.uIcc.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) a b)) (Set.Icc.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7))))) (InfSet.infₛ.{u2} β (ConditionallyCompleteLattice.toHasInf.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)) (Set.image.{u1, u2} α β f (Set.uIcc.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) a b))) (SupSet.supₛ.{u2} β (ConditionallyCompleteLattice.toHasSup.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)) (Set.image.{u1, u2} α β f (Set.uIcc.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) a b)))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u2} α] [_inst_2 : TopologicalSpace.{u2} α] [_inst_3 : OrderTopology.{u2} α _inst_2 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u1} β] [_inst_6 : DenselyOrdered.{u2} α (Preorder.toLT.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1))))))] [_inst_7 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_8 : OrderTopology.{u1} β _inst_4 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)))))] {f : α -> β} {a : α} {b : α}, (ContinuousOn.{u2, u1} α β _inst_2 _inst_4 f (Set.uIcc.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1)) a b)) -> (Eq.{succ u1} (Set.{u1} β) (Set.image.{u2, u1} α β f (Set.uIcc.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1)) a b)) (Set.Icc.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7))))) (InfSet.infₛ.{u1} β (ConditionallyCompleteLattice.toInfSet.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)) (Set.image.{u2, u1} α β f (Set.uIcc.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1)) a b))) (SupSet.supₛ.{u1} β (ConditionallyCompleteLattice.toSupSet.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)) (Set.image.{u2, u1} α β f (Set.uIcc.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1)) a b)))))
Case conversion may be inaccurate. Consider using '#align continuous_on.image_uIcc_eq_Icc ContinuousOn.image_uIcc_eq_Iccₓ'. -/
theorem image_uIcc_eq_Icc (h : ContinuousOn f <| [a, b]) :
    f '' [a, b] = Icc (infₛ (f '' [a, b])) (supₛ (f '' [a, b])) :=
  by
  cases' le_total a b with h2 h2
  · simp_rw [uIcc_of_le h2] at h⊢
    exact h.image_Icc h2
  · simp_rw [uIcc_of_ge h2] at h⊢
    exact h.image_Icc h2
#align continuous_on.image_uIcc_eq_Icc ContinuousOn.image_uIcc_eq_Icc

/- warning: continuous_on.image_uIcc -> ContinuousOn.image_uIcc is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] [_inst_6 : DenselyOrdered.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))))] [_inst_7 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_8 : OrderTopology.{u2} β _inst_4 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)))))] {f : α -> β} {a : α} {b : α}, (ContinuousOn.{u1, u2} α β _inst_2 _inst_4 f (Set.uIcc.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) a b)) -> (Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β f (Set.uIcc.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) a b)) (Set.uIcc.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)) (InfSet.infₛ.{u2} β (ConditionallyCompleteLattice.toHasInf.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)) (Set.image.{u1, u2} α β f (Set.uIcc.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) a b))) (SupSet.supₛ.{u2} β (ConditionallyCompleteLattice.toHasSup.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)) (Set.image.{u1, u2} α β f (Set.uIcc.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)) a b)))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u2} α] [_inst_2 : TopologicalSpace.{u2} α] [_inst_3 : OrderTopology.{u2} α _inst_2 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u1} β] [_inst_6 : DenselyOrdered.{u2} α (Preorder.toLT.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1))))))] [_inst_7 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_8 : OrderTopology.{u1} β _inst_4 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)))))] {f : α -> β} {a : α} {b : α}, (ContinuousOn.{u2, u1} α β _inst_2 _inst_4 f (Set.uIcc.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1)) a b)) -> (Eq.{succ u1} (Set.{u1} β) (Set.image.{u2, u1} α β f (Set.uIcc.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1)) a b)) (Set.uIcc.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)) (InfSet.infₛ.{u1} β (ConditionallyCompleteLattice.toInfSet.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)) (Set.image.{u2, u1} α β f (Set.uIcc.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1)) a b))) (SupSet.supₛ.{u1} β (ConditionallyCompleteLattice.toSupSet.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)) (Set.image.{u2, u1} α β f (Set.uIcc.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1)) a b)))))
Case conversion may be inaccurate. Consider using '#align continuous_on.image_uIcc ContinuousOn.image_uIccₓ'. -/
theorem image_uIcc (h : ContinuousOn f <| [a, b]) :
    f '' [a, b] = [infₛ (f '' [a, b]), supₛ (f '' [a, b])] :=
  by
  refine' h.image_uIcc_eq_Icc.trans (uIcc_of_le _).symm
  refine' cinfₛ_le_csupₛ _ _ (nonempty_uIcc.image _) <;> rw [h.image_uIcc_eq_Icc]
  exacts[bddBelow_Icc, bddAbove_Icc]
#align continuous_on.image_uIcc ContinuousOn.image_uIcc

/- warning: continuous_on.Inf_image_Icc_le -> ContinuousOn.infₛ_image_Icc_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] [_inst_6 : DenselyOrdered.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))))] [_inst_7 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_8 : OrderTopology.{u2} β _inst_4 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)))))] {f : α -> β} {a : α} {b : α} {c : α}, (ContinuousOn.{u1, u2} α β _inst_2 _inst_4 f (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) a b)) -> (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) c (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) a b)) -> (LE.le.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)))))) (InfSet.infₛ.{u2} β (ConditionallyCompleteLattice.toHasInf.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)) (Set.image.{u1, u2} α β f (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) a b))) (f c))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u2} α] [_inst_2 : TopologicalSpace.{u2} α] [_inst_3 : OrderTopology.{u2} α _inst_2 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u1} β] [_inst_6 : DenselyOrdered.{u2} α (Preorder.toLT.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1))))))] [_inst_7 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_8 : OrderTopology.{u1} β _inst_4 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)))))] {f : α -> β} {a : α} {b : α} {c : α}, (ContinuousOn.{u2, u1} α β _inst_2 _inst_4 f (Set.Icc.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1))))) a b)) -> (Membership.mem.{u2, u2} α (Set.{u2} α) (Set.instMembershipSet.{u2} α) c (Set.Icc.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1))))) a b)) -> (LE.le.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)))))) (InfSet.infₛ.{u1} β (ConditionallyCompleteLattice.toInfSet.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)) (Set.image.{u2, u1} α β f (Set.Icc.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1))))) a b))) (f c))
Case conversion may be inaccurate. Consider using '#align continuous_on.Inf_image_Icc_le ContinuousOn.infₛ_image_Icc_leₓ'. -/
theorem infₛ_image_Icc_le (h : ContinuousOn f <| Icc a b) (hc : c ∈ Icc a b) :
    infₛ (f '' Icc a b) ≤ f c :=
  by
  rw [h.image_Icc (nonempty_Icc.mp (Set.nonempty_of_mem hc))]
  exact
    cinfₛ_le bddBelow_Icc
      (mem_Icc.mpr
        ⟨cinfₛ_le (is_compact_Icc.bdd_below_image h) ⟨c, hc, rfl⟩,
          le_csupₛ (is_compact_Icc.bdd_above_image h) ⟨c, hc, rfl⟩⟩)
#align continuous_on.Inf_image_Icc_le ContinuousOn.infₛ_image_Icc_le

/- warning: continuous_on.le_Sup_image_Icc -> ContinuousOn.le_supₛ_image_Icc is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] [_inst_6 : DenselyOrdered.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))))] [_inst_7 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_8 : OrderTopology.{u2} β _inst_4 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)))))] {f : α -> β} {a : α} {b : α} {c : α}, (ContinuousOn.{u1, u2} α β _inst_2 _inst_4 f (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) a b)) -> (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) c (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) a b)) -> (LE.le.{u2} β (Preorder.toLE.{u2} β (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)))))) (f c) (SupSet.supₛ.{u2} β (ConditionallyCompleteLattice.toHasSup.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_7)) (Set.image.{u1, u2} α β f (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) a b))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : ConditionallyCompleteLinearOrder.{u2} α] [_inst_2 : TopologicalSpace.{u2} α] [_inst_3 : OrderTopology.{u2} α _inst_2 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u1} β] [_inst_6 : DenselyOrdered.{u2} α (Preorder.toLT.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1))))))] [_inst_7 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_8 : OrderTopology.{u1} β _inst_4 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)))))] {f : α -> β} {a : α} {b : α} {c : α}, (ContinuousOn.{u2, u1} α β _inst_2 _inst_4 f (Set.Icc.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1))))) a b)) -> (Membership.mem.{u2, u2} α (Set.{u2} α) (Set.instMembershipSet.{u2} α) c (Set.Icc.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1))))) a b)) -> (LE.le.{u1} β (Preorder.toLE.{u1} β (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)))))) (f c) (SupSet.supₛ.{u1} β (ConditionallyCompleteLattice.toSupSet.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_7)) (Set.image.{u2, u1} α β f (Set.Icc.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (ConditionallyCompleteLattice.toLattice.{u2} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} α _inst_1))))) a b))))
Case conversion may be inaccurate. Consider using '#align continuous_on.le_Sup_image_Icc ContinuousOn.le_supₛ_image_Iccₓ'. -/
theorem le_supₛ_image_Icc (h : ContinuousOn f <| Icc a b) (hc : c ∈ Icc a b) :
    f c ≤ supₛ (f '' Icc a b) :=
  by
  rw [h.image_Icc (nonempty_Icc.mp (Set.nonempty_of_mem hc))]
  exact
    le_csupₛ bddAbove_Icc
      (mem_Icc.mpr
        ⟨cinfₛ_le (is_compact_Icc.bdd_below_image h) ⟨c, hc, rfl⟩,
          le_csupₛ (is_compact_Icc.bdd_above_image h) ⟨c, hc, rfl⟩⟩)
#align continuous_on.le_Sup_image_Icc ContinuousOn.le_supₛ_image_Icc

end ContinuousOn

/- warning: is_compact.exists_local_min_on_mem_subset -> IsCompact.exists_isLocalMinOn_mem_subset is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {f : β -> α} {s : Set.{u2} β} {t : Set.{u2} β} {z : β}, (IsCompact.{u2} β _inst_4 t) -> (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f t) -> (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) z t) -> (forall (z' : β), (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) z' (SDiff.sdiff.{u2} (Set.{u2} β) (BooleanAlgebra.toHasSdiff.{u2} (Set.{u2} β) (Set.booleanAlgebra.{u2} β)) t s)) -> (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f z) (f z'))) -> (Exists.{succ u2} β (fun (x : β) => Exists.{0} (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) (fun (H : Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) => IsLocalMinOn.{u2, u1} β α _inst_4 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) f t x)))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {f : β -> α} {s : Set.{u2} β} {t : Set.{u2} β} {z : β}, (IsCompact.{u2} β _inst_4 t) -> (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f t) -> (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) z t) -> (forall (z' : β), (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) z' (SDiff.sdiff.{u2} (Set.{u2} β) (Set.instSDiffSet.{u2} β) t s)) -> (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f z) (f z'))) -> (Exists.{succ u2} β (fun (x : β) => And (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) x s) (IsLocalMinOn.{u2, u1} β α _inst_4 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) f t x)))
Case conversion may be inaccurate. Consider using '#align is_compact.exists_local_min_on_mem_subset IsCompact.exists_isLocalMinOn_mem_subsetₓ'. -/
theorem IsCompact.exists_isLocalMinOn_mem_subset {f : β → α} {s t : Set β} {z : β}
    (ht : IsCompact t) (hf : ContinuousOn f t) (hz : z ∈ t) (hfz : ∀ z' ∈ t \ s, f z < f z') :
    ∃ x ∈ s, IsLocalMinOn f t x :=
  by
  obtain ⟨x, hx, hfx⟩ : ∃ x ∈ t, ∀ y ∈ t, f x ≤ f y := ht.exists_forall_le ⟨z, hz⟩ hf
  have key : ∀ ⦃y⦄, y ∈ t → (∀ z' ∈ t \ s, f y < f z') → y ∈ s := fun y hy hfy => by
    by_contra <;> simpa using hfy y ((mem_diff y).mpr ⟨hy, h⟩)
  have h1 : ∀ z' ∈ t \ s, f x < f z' := fun z' hz' => (hfx z hz).trans_lt (hfz z' hz')
  have h2 : x ∈ s := key hx h1
  refine' ⟨x, h2, eventually_nhdsWithin_of_forall hfx⟩
#align is_compact.exists_local_min_on_mem_subset IsCompact.exists_isLocalMinOn_mem_subset

/- warning: is_compact.exists_local_min_mem_open -> IsCompact.exists_local_min_mem_open is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {f : β -> α} {s : Set.{u2} β} {t : Set.{u2} β} {z : β}, (IsCompact.{u2} β _inst_4 t) -> (HasSubset.Subset.{u2} (Set.{u2} β) (Set.hasSubset.{u2} β) s t) -> (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f t) -> (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) z t) -> (forall (z' : β), (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) z' (SDiff.sdiff.{u2} (Set.{u2} β) (BooleanAlgebra.toHasSdiff.{u2} (Set.{u2} β) (Set.booleanAlgebra.{u2} β)) t s)) -> (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f z) (f z'))) -> (IsOpen.{u2} β _inst_4 s) -> (Exists.{succ u2} β (fun (x : β) => Exists.{0} (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) (fun (H : Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x s) => IsLocalMin.{u2, u1} β α _inst_4 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) f x)))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : ConditionallyCompleteLinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u1} α] [_inst_3 : OrderTopology.{u1} α _inst_2 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))] [_inst_4 : TopologicalSpace.{u2} β] {f : β -> α} {s : Set.{u2} β} {t : Set.{u2} β} {z : β}, (IsCompact.{u2} β _inst_4 t) -> (HasSubset.Subset.{u2} (Set.{u2} β) (Set.instHasSubsetSet.{u2} β) s t) -> (ContinuousOn.{u2, u1} β α _inst_4 _inst_2 f t) -> (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) z t) -> (forall (z' : β), (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) z' (SDiff.sdiff.{u2} (Set.{u2} β) (Set.instSDiffSet.{u2} β) t s)) -> (LT.lt.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1)))))) (f z) (f z'))) -> (IsOpen.{u2} β _inst_4 s) -> (Exists.{succ u2} β (fun (x : β) => And (Membership.mem.{u2, u2} β (Set.{u2} β) (Set.instMembershipSet.{u2} β) x s) (IsLocalMin.{u2, u1} β α _inst_4 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (ConditionallyCompleteLattice.toLattice.{u1} α (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} α _inst_1))))) f x)))
Case conversion may be inaccurate. Consider using '#align is_compact.exists_local_min_mem_open IsCompact.exists_local_min_mem_openₓ'. -/
theorem IsCompact.exists_local_min_mem_open {f : β → α} {s t : Set β} {z : β} (ht : IsCompact t)
    (hst : s ⊆ t) (hf : ContinuousOn f t) (hz : z ∈ t) (hfz : ∀ z' ∈ t \ s, f z < f z')
    (hs : IsOpen s) : ∃ x ∈ s, IsLocalMin f x :=
  by
  obtain ⟨x, hx, hfx⟩ := ht.exists_local_min_on_mem_subset hf hz hfz
  exact ⟨x, hx, hfx.is_local_min (Filter.mem_of_superset (hs.mem_nhds hx) hst)⟩
#align is_compact.exists_local_min_mem_open IsCompact.exists_local_min_mem_open

