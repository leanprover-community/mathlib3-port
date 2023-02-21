/-
Copyright (c) 2021 Andrew Yang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Andrew Yang

! This file was ported from Lean 3 source module topology.sober
! leanprover-community/mathlib commit bd9851ca476957ea4549eb19b40e7b5ade9428cc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Separation

/-!
# Sober spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A quasi-sober space is a topological space where every
irreducible closed subset has a generic point.
A sober space is a quasi-sober space where every irreducible closed subset
has a *unique* generic point. This is if and only if the space is T0, and thus sober spaces can be
stated via `[quasi_sober α] [t0_space α]`.

## Main definition

* `is_generic_point` : `x` is the generic point of `S` if `S` is the closure of `x`.
* `quasi_sober` : A space is quasi-sober if every irreducible closed subset has a generic point.

-/


open Set

variable {α β : Type _} [TopologicalSpace α] [TopologicalSpace β]

section genericPoint

#print IsGenericPoint /-
/-- `x` is a generic point of `S` if `S` is the closure of `x`. -/
def IsGenericPoint (x : α) (S : Set α) : Prop :=
  closure ({x} : Set α) = S
#align is_generic_point IsGenericPoint
-/

#print isGenericPoint_def /-
theorem isGenericPoint_def {x : α} {S : Set α} : IsGenericPoint x S ↔ closure ({x} : Set α) = S :=
  Iff.rfl
#align is_generic_point_def isGenericPoint_def
-/

#print IsGenericPoint.def /-
theorem IsGenericPoint.def {x : α} {S : Set α} (h : IsGenericPoint x S) :
    closure ({x} : Set α) = S :=
  h
#align is_generic_point.def IsGenericPoint.def
-/

#print isGenericPoint_closure /-
theorem isGenericPoint_closure {x : α} : IsGenericPoint x (closure ({x} : Set α)) :=
  refl _
#align is_generic_point_closure isGenericPoint_closure
-/

variable {x y : α} {S U Z : Set α}

#print isGenericPoint_iff_specializes /-
theorem isGenericPoint_iff_specializes : IsGenericPoint x S ↔ ∀ y, x ⤳ y ↔ y ∈ S := by
  simp only [specializes_iff_mem_closure, IsGenericPoint, Set.ext_iff]
#align is_generic_point_iff_specializes isGenericPoint_iff_specializes
-/

namespace IsGenericPoint

#print IsGenericPoint.specializes_iff_mem /-
theorem specializes_iff_mem (h : IsGenericPoint x S) : x ⤳ y ↔ y ∈ S :=
  isGenericPoint_iff_specializes.1 h y
#align is_generic_point.specializes_iff_mem IsGenericPoint.specializes_iff_mem
-/

#print IsGenericPoint.specializes /-
theorem specializes (h : IsGenericPoint x S) (h' : y ∈ S) : x ⤳ y :=
  h.specializes_iff_mem.2 h'
#align is_generic_point.specializes IsGenericPoint.specializes
-/

#print IsGenericPoint.mem /-
theorem mem (h : IsGenericPoint x S) : x ∈ S :=
  h.specializes_iff_mem.1 specializes_rfl
#align is_generic_point.mem IsGenericPoint.mem
-/

#print IsGenericPoint.isClosed /-
protected theorem isClosed (h : IsGenericPoint x S) : IsClosed S :=
  h.def ▸ isClosed_closure
#align is_generic_point.is_closed IsGenericPoint.isClosed
-/

#print IsGenericPoint.isIrreducible /-
protected theorem isIrreducible (h : IsGenericPoint x S) : IsIrreducible S :=
  h.def ▸ isIrreducible_singleton.closure
#align is_generic_point.is_irreducible IsGenericPoint.isIrreducible
-/

#print IsGenericPoint.eq /-
/-- In a T₀ space, each set has at most one generic point. -/
protected theorem eq [T0Space α] (h : IsGenericPoint x S) (h' : IsGenericPoint y S) : x = y :=
  ((h.Specializes h'.Mem).antisymm (h'.Specializes h.Mem)).Eq
#align is_generic_point.eq IsGenericPoint.eq
-/

/- warning: is_generic_point.mem_open_set_iff -> IsGenericPoint.mem_open_set_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {x : α} {S : Set.{u1} α} {U : Set.{u1} α}, (IsGenericPoint.{u1} α _inst_1 x S) -> (IsOpen.{u1} α _inst_1 U) -> (Iff (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x U) (Set.Nonempty.{u1} α (Inter.inter.{u1} (Set.{u1} α) (Set.hasInter.{u1} α) S U)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {x : α} {S : Set.{u1} α} {U : Set.{u1} α}, (IsGenericPoint.{u1} α _inst_1 x S) -> (IsOpen.{u1} α _inst_1 U) -> (Iff (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x U) (Set.Nonempty.{u1} α (Inter.inter.{u1} (Set.{u1} α) (Set.instInterSet.{u1} α) S U)))
Case conversion may be inaccurate. Consider using '#align is_generic_point.mem_open_set_iff IsGenericPoint.mem_open_set_iffₓ'. -/
theorem mem_open_set_iff (h : IsGenericPoint x S) (hU : IsOpen U) : x ∈ U ↔ (S ∩ U).Nonempty :=
  ⟨fun h' => ⟨x, h.Mem, h'⟩, fun ⟨y, hyS, hyU⟩ => (h.Specializes hyS).mem_open hU hyU⟩
#align is_generic_point.mem_open_set_iff IsGenericPoint.mem_open_set_iff

/- warning: is_generic_point.disjoint_iff -> IsGenericPoint.disjoint_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {x : α} {S : Set.{u1} α} {U : Set.{u1} α}, (IsGenericPoint.{u1} α _inst_1 x S) -> (IsOpen.{u1} α _inst_1 U) -> (Iff (Disjoint.{u1} (Set.{u1} α) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} α) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} α) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} α) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} α) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} α) (Set.completeBooleanAlgebra.{u1} α)))))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} (Set.{u1} α) (BooleanAlgebra.toGeneralizedBooleanAlgebra.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α))) S U) (Not (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x U)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {x : α} {S : Set.{u1} α} {U : Set.{u1} α}, (IsGenericPoint.{u1} α _inst_1 x S) -> (IsOpen.{u1} α _inst_1 U) -> (Iff (Disjoint.{u1} (Set.{u1} α) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} α) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} α) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} α) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} α) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} α) (Set.instCompleteBooleanAlgebraSet.{u1} α)))))) (BoundedOrder.toOrderBot.{u1} (Set.{u1} α) (Preorder.toLE.{u1} (Set.{u1} α) (PartialOrder.toPreorder.{u1} (Set.{u1} α) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} α) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} α) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} α) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} α) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} α) (Set.instCompleteBooleanAlgebraSet.{u1} α)))))))) (CompleteLattice.toBoundedOrder.{u1} (Set.{u1} α) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} α) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} α) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} α) (Set.instCompleteBooleanAlgebraSet.{u1} α)))))) S U) (Not (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x U)))
Case conversion may be inaccurate. Consider using '#align is_generic_point.disjoint_iff IsGenericPoint.disjoint_iffₓ'. -/
theorem disjoint_iff (h : IsGenericPoint x S) (hU : IsOpen U) : Disjoint S U ↔ x ∉ U := by
  rw [h.mem_open_set_iff hU, ← not_disjoint_iff_nonempty_inter, Classical.not_not]
#align is_generic_point.disjoint_iff IsGenericPoint.disjoint_iff

#print IsGenericPoint.mem_closed_set_iff /-
theorem mem_closed_set_iff (h : IsGenericPoint x S) (hZ : IsClosed Z) : x ∈ Z ↔ S ⊆ Z := by
  rw [← h.def, hZ.closure_subset_iff, singleton_subset_iff]
#align is_generic_point.mem_closed_set_iff IsGenericPoint.mem_closed_set_iff
-/

/- warning: is_generic_point.image -> IsGenericPoint.image is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {x : α} {S : Set.{u1} α}, (IsGenericPoint.{u1} α _inst_1 x S) -> (forall {f : α -> β}, (Continuous.{u1, u2} α β _inst_1 _inst_2 f) -> (IsGenericPoint.{u2} β _inst_2 (f x) (closure.{u2} β _inst_2 (Set.image.{u1, u2} α β f S))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {x : α} {S : Set.{u2} α}, (IsGenericPoint.{u2} α _inst_1 x S) -> (forall {f : α -> β}, (Continuous.{u2, u1} α β _inst_1 _inst_2 f) -> (IsGenericPoint.{u1} β _inst_2 (f x) (closure.{u1} β _inst_2 (Set.image.{u2, u1} α β f S))))
Case conversion may be inaccurate. Consider using '#align is_generic_point.image IsGenericPoint.imageₓ'. -/
protected theorem image (h : IsGenericPoint x S) {f : α → β} (hf : Continuous f) :
    IsGenericPoint (f x) (closure (f '' S)) :=
  by
  rw [isGenericPoint_def, ← h.def, ← image_singleton]
  exact
    subset.antisymm (closure_mono (image_subset _ subset_closure))
      (closure_minimal (image_closure_subset_closure_image hf) isClosed_closure)
#align is_generic_point.image IsGenericPoint.image

end IsGenericPoint

#print isGenericPoint_iff_forall_closed /-
theorem isGenericPoint_iff_forall_closed (hS : IsClosed S) (hxS : x ∈ S) :
    IsGenericPoint x S ↔ ∀ Z : Set α, IsClosed Z → x ∈ Z → S ⊆ Z :=
  by
  have : closure {x} ⊆ S := closure_minimal (singleton_subset_iff.2 hxS) hS
  simp_rw [IsGenericPoint, subset_antisymm_iff, this, true_and_iff, closure, subset_sInter_iff,
    mem_set_of_eq, and_imp, singleton_subset_iff]
#align is_generic_point_iff_forall_closed isGenericPoint_iff_forall_closed
-/

end genericPoint

section Sober

#print QuasiSober /-
/-- A space is sober if every irreducible closed subset has a generic point. -/
@[mk_iff]
class QuasiSober (α : Type _) [TopologicalSpace α] : Prop where
  sober : ∀ {S : Set α} (hS₁ : IsIrreducible S) (hS₂ : IsClosed S), ∃ x, IsGenericPoint x S
#align quasi_sober QuasiSober
-/

#print IsIrreducible.genericPoint /-
/-- A generic point of the closure of an irreducible space. -/
noncomputable def IsIrreducible.genericPoint [QuasiSober α] {S : Set α} (hS : IsIrreducible S) :
    α :=
  (QuasiSober.sober hS.closure isClosed_closure).some
#align is_irreducible.generic_point IsIrreducible.genericPoint
-/

#print IsIrreducible.genericPoint_spec /-
theorem IsIrreducible.genericPoint_spec [QuasiSober α] {S : Set α} (hS : IsIrreducible S) :
    IsGenericPoint hS.genericPoint (closure S) :=
  (QuasiSober.sober hS.closure isClosed_closure).choose_spec
#align is_irreducible.generic_point_spec IsIrreducible.genericPoint_spec
-/

#print IsIrreducible.genericPoint_closure_eq /-
@[simp]
theorem IsIrreducible.genericPoint_closure_eq [QuasiSober α] {S : Set α} (hS : IsIrreducible S) :
    closure ({hS.genericPoint} : Set α) = closure S :=
  hS.genericPoint_spec
#align is_irreducible.generic_point_closure_eq IsIrreducible.genericPoint_closure_eq
-/

variable (α)

#print genericPoint /-
/-- A generic point of a sober irreducible space. -/
noncomputable def genericPoint [QuasiSober α] [IrreducibleSpace α] : α :=
  (IrreducibleSpace.isIrreducible_univ α).genericPoint
#align generic_point genericPoint
-/

/- warning: generic_point_spec -> genericPoint_spec is a dubious translation:
lean 3 declaration is
  forall (α : Type.{u1}) [_inst_1 : TopologicalSpace.{u1} α] [_inst_3 : QuasiSober.{u1} α _inst_1] [_inst_4 : IrreducibleSpace.{u1} α _inst_1], IsGenericPoint.{u1} α _inst_1 (genericPoint.{u1} α _inst_1 _inst_3 _inst_4) (Top.top.{u1} (Set.{u1} α) (CompleteLattice.toHasTop.{u1} (Set.{u1} α) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} α) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} α) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} α) (Set.completeBooleanAlgebra.{u1} α))))))
but is expected to have type
  forall (α : Type.{u1}) [_inst_1 : TopologicalSpace.{u1} α] [_inst_3 : QuasiSober.{u1} α _inst_1] [_inst_4 : IrreducibleSpace.{u1} α _inst_1], IsGenericPoint.{u1} α _inst_1 (genericPoint.{u1} α _inst_1 _inst_3 _inst_4) (Top.top.{u1} (Set.{u1} α) (CompleteLattice.toTop.{u1} (Set.{u1} α) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} α) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} α) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} α) (Set.instCompleteBooleanAlgebraSet.{u1} α))))))
Case conversion may be inaccurate. Consider using '#align generic_point_spec genericPoint_specₓ'. -/
theorem genericPoint_spec [QuasiSober α] [IrreducibleSpace α] : IsGenericPoint (genericPoint α) ⊤ :=
  by simpa using (IrreducibleSpace.isIrreducible_univ α).genericPoint_spec
#align generic_point_spec genericPoint_spec

/- warning: generic_point_closure -> genericPoint_closure is a dubious translation:
lean 3 declaration is
  forall (α : Type.{u1}) [_inst_1 : TopologicalSpace.{u1} α] [_inst_3 : QuasiSober.{u1} α _inst_1] [_inst_4 : IrreducibleSpace.{u1} α _inst_1], Eq.{succ u1} (Set.{u1} α) (closure.{u1} α _inst_1 (Singleton.singleton.{u1, u1} α (Set.{u1} α) (Set.hasSingleton.{u1} α) (genericPoint.{u1} α _inst_1 _inst_3 _inst_4))) (Top.top.{u1} (Set.{u1} α) (CompleteLattice.toHasTop.{u1} (Set.{u1} α) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} α) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} α) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} α) (Set.completeBooleanAlgebra.{u1} α))))))
but is expected to have type
  forall (α : Type.{u1}) [_inst_1 : TopologicalSpace.{u1} α] [_inst_3 : QuasiSober.{u1} α _inst_1] [_inst_4 : IrreducibleSpace.{u1} α _inst_1], Eq.{succ u1} (Set.{u1} α) (closure.{u1} α _inst_1 (Singleton.singleton.{u1, u1} α (Set.{u1} α) (Set.instSingletonSet.{u1} α) (genericPoint.{u1} α _inst_1 _inst_3 _inst_4))) (Top.top.{u1} (Set.{u1} α) (CompleteLattice.toTop.{u1} (Set.{u1} α) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} α) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} α) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} α) (Set.instCompleteBooleanAlgebraSet.{u1} α))))))
Case conversion may be inaccurate. Consider using '#align generic_point_closure genericPoint_closureₓ'. -/
@[simp]
theorem genericPoint_closure [QuasiSober α] [IrreducibleSpace α] :
    closure ({genericPoint α} : Set α) = ⊤ :=
  genericPoint_spec α
#align generic_point_closure genericPoint_closure

variable {α}

#print genericPoint_specializes /-
theorem genericPoint_specializes [QuasiSober α] [IrreducibleSpace α] (x : α) : genericPoint α ⤳ x :=
  (IsIrreducible.genericPoint_spec _).Specializes (by simp)
#align generic_point_specializes genericPoint_specializes
-/

attribute [local instance] specializationOrder

#print irreducibleSetEquivPoints /-
/-- The closed irreducible subsets of a sober space bijects with the points of the space. -/
noncomputable def irreducibleSetEquivPoints [QuasiSober α] [T0Space α] :
    { s : Set α | IsIrreducible s ∧ IsClosed s } ≃o α
    where
  toFun s := s.Prop.1.genericPoint
  invFun x := ⟨closure ({x} : Set α), isIrreducible_singleton.closure, isClosed_closure⟩
  left_inv s :=
    Subtype.eq <| Eq.trans s.Prop.1.genericPoint_spec <| closure_eq_iff_isClosed.mpr s.2.2
  right_inv x :=
    isIrreducible_singleton.closure.genericPoint_spec.Eq
      (by
        convert isGenericPoint_closure using 1
        rw [closure_closure])
  map_rel_iff' s t := by
    change _ ⤳ _ ↔ _
    rw [specializes_iff_closure_subset]
    simp [s.prop.2.closure_eq, t.prop.2.closure_eq, ← Subtype.coe_le_coe]
#align irreducible_set_equiv_points irreducibleSetEquivPoints
-/

/- warning: closed_embedding.quasi_sober -> ClosedEmbedding.quasiSober is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (ClosedEmbedding.{u1, u2} α β _inst_1 _inst_2 f) -> (forall [_inst_3 : QuasiSober.{u2} β _inst_2], QuasiSober.{u1} α _inst_1)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (ClosedEmbedding.{u2, u1} α β _inst_1 _inst_2 f) -> (forall [_inst_3 : QuasiSober.{u1} β _inst_2], QuasiSober.{u2} α _inst_1)
Case conversion may be inaccurate. Consider using '#align closed_embedding.quasi_sober ClosedEmbedding.quasiSoberₓ'. -/
theorem ClosedEmbedding.quasiSober {f : α → β} (hf : ClosedEmbedding f) [QuasiSober β] :
    QuasiSober α := by
  constructor
  intro S hS hS'
  have hS'' := hS.image f hf.continuous.continuous_on
  obtain ⟨x, hx⟩ := QuasiSober.sober hS'' (hf.is_closed_map _ hS')
  obtain ⟨y, hy, rfl⟩ := hx.mem
  use y
  change _ = _ at hx
  apply set.image_injective.mpr hf.inj
  rw [← hx, ← hf.closure_image_eq, Set.image_singleton]
#align closed_embedding.quasi_sober ClosedEmbedding.quasiSober

/- warning: open_embedding.quasi_sober -> OpenEmbedding.quasiSober is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : TopologicalSpace.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] {f : α -> β}, (OpenEmbedding.{u1, u2} α β _inst_1 _inst_2 f) -> (forall [_inst_3 : QuasiSober.{u2} β _inst_2], QuasiSober.{u1} α _inst_1)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : TopologicalSpace.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] {f : α -> β}, (OpenEmbedding.{u2, u1} α β _inst_1 _inst_2 f) -> (forall [_inst_3 : QuasiSober.{u1} β _inst_2], QuasiSober.{u2} α _inst_1)
Case conversion may be inaccurate. Consider using '#align open_embedding.quasi_sober OpenEmbedding.quasiSoberₓ'. -/
theorem OpenEmbedding.quasiSober {f : α → β} (hf : OpenEmbedding f) [QuasiSober β] : QuasiSober α :=
  by
  constructor
  intro S hS hS'
  have hS'' := hS.image f hf.continuous.continuous_on
  obtain ⟨x, hx⟩ := QuasiSober.sober hS''.closure isClosed_closure
  obtain ⟨T, hT, rfl⟩ := hf.to_inducing.is_closed_iff.mp hS'
  rw [Set.image_preimage_eq_inter_range] at hx hS''
  have hxT : x ∈ T := by
    rw [← hT.closure_eq]
    exact closure_mono (Set.inter_subset_left _ _) hx.mem
  have hxU : x ∈ Set.range f :=
    by
    rw [hx.mem_open_set_iff hf.open_range]
    refine' Set.Nonempty.mono _ hS''.1
    simpa using subset_closure
  rcases hxU with ⟨y, rfl⟩
  use y
  change _ = _
  rw [hf.to_embedding.closure_eq_preimage_closure_image, Set.image_singleton, show _ = _ from hx]
  apply set.image_injective.mpr hf.inj
  ext z
  simp only [Set.image_preimage_eq_inter_range, Set.mem_inter_iff, and_congr_left_iff]
  exact fun hy =>
    ⟨fun h => hT.closure_eq ▸ closure_mono (Set.inter_subset_left _ _) h, fun h =>
      subset_closure ⟨h, hy⟩⟩
#align open_embedding.quasi_sober OpenEmbedding.quasiSober

/- warning: quasi_sober_of_open_cover -> quasiSober_of_open_cover is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] (S : Set.{u1} (Set.{u1} α)), (forall (s : coeSort.{succ u1, succ (succ u1)} (Set.{u1} (Set.{u1} α)) Type.{u1} (Set.hasCoeToSort.{u1} (Set.{u1} α)) S), IsOpen.{u1} α _inst_1 ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} (Set.{u1} α)) Type.{u1} (Set.hasCoeToSort.{u1} (Set.{u1} α)) S) (Set.{u1} α) (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} (Set.{u1} α)) Type.{u1} (Set.hasCoeToSort.{u1} (Set.{u1} α)) S) (Set.{u1} α) (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} (Set.{u1} α)) Type.{u1} (Set.hasCoeToSort.{u1} (Set.{u1} α)) S) (Set.{u1} α) (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} (Set.{u1} α)) Type.{u1} (Set.hasCoeToSort.{u1} (Set.{u1} α)) S) (Set.{u1} α) (coeSubtype.{succ u1} (Set.{u1} α) (fun (x : Set.{u1} α) => Membership.Mem.{u1, u1} (Set.{u1} α) (Set.{u1} (Set.{u1} α)) (Set.hasMem.{u1} (Set.{u1} α)) x S))))) s)) -> (forall [hS' : forall (s : coeSort.{succ u1, succ (succ u1)} (Set.{u1} (Set.{u1} α)) Type.{u1} (Set.hasCoeToSort.{u1} (Set.{u1} α)) S), QuasiSober.{u1} (coeSort.{succ u1, succ (succ u1)} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} (Set.{u1} α)) Type.{u1} (Set.hasCoeToSort.{u1} (Set.{u1} α)) S) Type.{u1} (coeSortTrans.{succ (succ u1), succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} (Set.{u1} α)) Type.{u1} (Set.hasCoeToSort.{u1} (Set.{u1} α)) S) (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (coeBaseAux.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} (Set.{u1} α)) Type.{u1} (Set.hasCoeToSort.{u1} (Set.{u1} α)) S) (Set.{u1} α) (coeSubtype.{succ u1} (Set.{u1} α) (fun (x : Set.{u1} α) => Membership.Mem.{u1, u1} (Set.{u1} α) (Set.{u1} (Set.{u1} α)) (Set.hasMem.{u1} (Set.{u1} α)) x S)))) s) (Subtype.topologicalSpace.{u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x (HasCoeTAux.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} (Set.{u1} α)) Type.{u1} (Set.hasCoeToSort.{u1} (Set.{u1} α)) S) (Set.{u1} α) (coeBaseAux.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} (Set.{u1} α)) Type.{u1} (Set.hasCoeToSort.{u1} (Set.{u1} α)) S) (Set.{u1} α) (coeSubtype.{succ u1} (Set.{u1} α) (fun (x : Set.{u1} α) => Membership.Mem.{u1, u1} (Set.{u1} α) (Set.{u1} (Set.{u1} α)) (Set.hasMem.{u1} (Set.{u1} α)) x S))) s)) _inst_1)], (Eq.{succ u1} (Set.{u1} α) (Set.unionₛ.{u1} α S) (Top.top.{u1} (Set.{u1} α) (CompleteLattice.toHasTop.{u1} (Set.{u1} α) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} α) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} α) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} α) (Set.completeBooleanAlgebra.{u1} α))))))) -> (QuasiSober.{u1} α _inst_1))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] (S : Set.{u1} (Set.{u1} α)), (forall (s : Set.Elem.{u1} (Set.{u1} α) S), IsOpen.{u1} α _inst_1 (Subtype.val.{succ u1} (Set.{u1} α) (fun (x : Set.{u1} α) => Membership.mem.{u1, u1} (Set.{u1} α) (Set.{u1} (Set.{u1} α)) (Set.instMembershipSet.{u1} (Set.{u1} α)) x S) s)) -> (forall [hS' : forall (s : Set.Elem.{u1} (Set.{u1} α) S), QuasiSober.{u1} (Set.Elem.{u1} α (Subtype.val.{succ u1} (Set.{u1} α) (fun (x : Set.{u1} α) => Membership.mem.{u1, u1} (Set.{u1} α) (Set.{u1} (Set.{u1} α)) (Set.instMembershipSet.{u1} (Set.{u1} α)) x S) s)) (instTopologicalSpaceSubtype.{u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (Subtype.val.{succ u1} (Set.{u1} α) (fun (x : Set.{u1} α) => Membership.mem.{u1, u1} (Set.{u1} α) (Set.{u1} (Set.{u1} α)) (Set.instMembershipSet.{u1} (Set.{u1} α)) x S) s)) _inst_1)], (Eq.{succ u1} (Set.{u1} α) (Set.unionₛ.{u1} α S) (Top.top.{u1} (Set.{u1} α) (CompleteLattice.toTop.{u1} (Set.{u1} α) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} α) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} α) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} α) (Set.instCompleteBooleanAlgebraSet.{u1} α))))))) -> (QuasiSober.{u1} α _inst_1))
Case conversion may be inaccurate. Consider using '#align quasi_sober_of_open_cover quasiSober_of_open_coverₓ'. -/
/-- A space is quasi sober if it can be covered by open quasi sober subsets. -/
theorem quasiSober_of_open_cover (S : Set (Set α)) (hS : ∀ s : S, IsOpen (s : Set α))
    [hS' : ∀ s : S, QuasiSober s] (hS'' : ⋃₀ S = ⊤) : QuasiSober α :=
  by
  rw [quasiSober_iff]
  intro t h h'
  obtain ⟨x, hx⟩ := h.1
  obtain ⟨U, hU, hU'⟩ : x ∈ ⋃₀ S := by
    rw [hS'']
    trivial
  haveI : QuasiSober U := hS' ⟨U, hU⟩
  have H : IsPreirreducible (coe ⁻¹' t : Set U) :=
    h.2.Preimage (hS ⟨U, hU⟩).openEmbedding_subtype_val
  replace H : IsIrreducible (coe ⁻¹' t : Set U) := ⟨⟨⟨x, hU'⟩, by simpa using hx⟩, H⟩
  use H.generic_point
  have := continuous_subtype_coe.closure_preimage_subset _ H.generic_point_spec.mem
  rw [h'.closure_eq] at this
  apply le_antisymm
  · apply h'.closure_subset_iff.mpr
    simpa using this
  rw [← Set.image_singleton, ← closure_closure]
  have := closure_mono (image_closure_subset_closure_image (@continuous_subtype_val α _ U))
  refine' Set.Subset.trans _ this
  rw [H.generic_point_spec.def]
  refine'
    (subset_closure_inter_of_isPreirreducible_of_isOpen h.2 (hS ⟨U, hU⟩) ⟨x, hx, hU'⟩).trans
      (closure_mono _)
  rw [← Subtype.image_preimage_coe]
  exact Set.image_subset _ subset_closure
#align quasi_sober_of_open_cover quasiSober_of_open_cover

#print T2Space.quasiSober /-
instance (priority := 100) T2Space.quasiSober [T2Space α] : QuasiSober α :=
  by
  constructor
  rintro S h -
  obtain ⟨x, rfl⟩ := is_irreducible_iff_singleton.mp h
  exact ⟨x, closure_singleton⟩
#align t2_space.quasi_sober T2Space.quasiSober
-/

end Sober

