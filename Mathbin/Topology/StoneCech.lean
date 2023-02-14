/-
Copyright (c) 2018 Reid Barton. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Reid Barton

! This file was ported from Lean 3 source module topology.stone_cech
! leanprover-community/mathlib commit 48085f140e684306f9e7da907cd5932056d1aded
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Bases
import Mathbin.Topology.DenseEmbedding

/-! # Stone-Čech compactification

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Construction of the Stone-Čech compactification using ultrafilters.

Parts of the formalization are based on "Ultrafilters and Topology"
by Marius Stekelenburg, particularly section 5.
-/


noncomputable section

open Filter Set

open Topology

universe u v

section Ultrafilter

#print ultrafilterBasis /-
/- The set of ultrafilters on α carries a natural topology which makes
  it the Stone-Čech compactification of α (viewed as a discrete space). -/
/-- Basis for the topology on `ultrafilter α`. -/
def ultrafilterBasis (α : Type u) : Set (Set (Ultrafilter α)) :=
  range fun s : Set α => { u | s ∈ u }
#align ultrafilter_basis ultrafilterBasis
-/

variable {α : Type u}

instance : TopologicalSpace (Ultrafilter α) :=
  TopologicalSpace.generateFrom (ultrafilterBasis α)

#print ultrafilterBasis_is_basis /-
theorem ultrafilterBasis_is_basis : TopologicalSpace.IsTopologicalBasis (ultrafilterBasis α) :=
  ⟨by
    rintro _ ⟨a, rfl⟩ _ ⟨b, rfl⟩ u ⟨ua, ub⟩
    refine' ⟨_, ⟨a ∩ b, rfl⟩, inter_mem ua ub, fun v hv => ⟨_, _⟩⟩ <;> apply mem_of_superset hv <;>
      simp [inter_subset_right a b],
    eq_univ_of_univ_subset <| subset_unionₛ_of_mem <| ⟨univ, eq_univ_of_forall fun u => univ_mem⟩,
    rfl⟩
#align ultrafilter_basis_is_basis ultrafilterBasis_is_basis
-/

#print ultrafilter_isOpen_basic /-
/-- The basic open sets for the topology on ultrafilters are open. -/
theorem ultrafilter_isOpen_basic (s : Set α) : IsOpen { u : Ultrafilter α | s ∈ u } :=
  ultrafilterBasis_is_basis.IsOpen ⟨s, rfl⟩
#align ultrafilter_is_open_basic ultrafilter_isOpen_basic
-/

#print ultrafilter_isClosed_basic /-
/-- The basic open sets for the topology on ultrafilters are also closed. -/
theorem ultrafilter_isClosed_basic (s : Set α) : IsClosed { u : Ultrafilter α | s ∈ u } :=
  by
  rw [← isOpen_compl_iff]
  convert ultrafilter_isOpen_basic (sᶜ)
  ext u
  exact ultrafilter.compl_mem_iff_not_mem.symm
#align ultrafilter_is_closed_basic ultrafilter_isClosed_basic
-/

/- warning: ultrafilter_converges_iff -> ultrafilter_converges_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {u : Ultrafilter.{u1} (Ultrafilter.{u1} α)} {x : Ultrafilter.{u1} α}, Iff (LE.le.{u1} (Filter.{u1} (Ultrafilter.{u1} α)) (Preorder.toLE.{u1} (Filter.{u1} (Ultrafilter.{u1} α)) (PartialOrder.toPreorder.{u1} (Filter.{u1} (Ultrafilter.{u1} α)) (Filter.partialOrder.{u1} (Ultrafilter.{u1} α)))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Ultrafilter.{u1} (Ultrafilter.{u1} α)) (Filter.{u1} (Ultrafilter.{u1} α)) (HasLiftT.mk.{succ u1, succ u1} (Ultrafilter.{u1} (Ultrafilter.{u1} α)) (Filter.{u1} (Ultrafilter.{u1} α)) (CoeTCₓ.coe.{succ u1, succ u1} (Ultrafilter.{u1} (Ultrafilter.{u1} α)) (Filter.{u1} (Ultrafilter.{u1} α)) (Ultrafilter.Filter.hasCoeT.{u1} (Ultrafilter.{u1} α)))) u) (nhds.{u1} (Ultrafilter.{u1} α) (Ultrafilter.topologicalSpace.{u1} α) x)) (Eq.{succ u1} (Ultrafilter.{u1} α) x (joinM.{u1} Ultrafilter.{u1} Ultrafilter.monad.{u1} α u))
but is expected to have type
  forall {α : Type.{u1}} {u : Ultrafilter.{u1} (Ultrafilter.{u1} α)} {x : Ultrafilter.{u1} α}, Iff (LE.le.{u1} (Filter.{u1} (Ultrafilter.{u1} α)) (Preorder.toLE.{u1} (Filter.{u1} (Ultrafilter.{u1} α)) (PartialOrder.toPreorder.{u1} (Filter.{u1} (Ultrafilter.{u1} α)) (Filter.instPartialOrderFilter.{u1} (Ultrafilter.{u1} α)))) (Ultrafilter.toFilter.{u1} (Ultrafilter.{u1} α) u) (nhds.{u1} (Ultrafilter.{u1} α) (Ultrafilter.topologicalSpace.{u1} α) x)) (Eq.{succ u1} (Ultrafilter.{u1} α) x (joinM.{u1} Ultrafilter.{u1} Ultrafilter.monad.{u1} α u))
Case conversion may be inaccurate. Consider using '#align ultrafilter_converges_iff ultrafilter_converges_iffₓ'. -/
/-- Every ultrafilter `u` on `ultrafilter α` converges to a unique
  point of `ultrafilter α`, namely `mjoin u`. -/
theorem ultrafilter_converges_iff {u : Ultrafilter (Ultrafilter α)} {x : Ultrafilter α} :
    ↑u ≤ 𝓝 x ↔ x = joinM u := by
  rw [eq_comm, ← Ultrafilter.coe_le_coe]
  change ↑u ≤ 𝓝 x ↔ ∀ s ∈ x, { v : Ultrafilter α | s ∈ v } ∈ u
  simp only [TopologicalSpace.nhds_generateFrom, le_infᵢ_iff, ultrafilterBasis, le_principal_iff,
    mem_set_of_eq]
  constructor
  · intro h a ha
    exact h _ ⟨ha, a, rfl⟩
  · rintro h a ⟨xi, a, rfl⟩
    exact h _ xi
#align ultrafilter_converges_iff ultrafilter_converges_iff

#print ultrafilter_compact /-
instance ultrafilter_compact : CompactSpace (Ultrafilter α) :=
  ⟨isCompact_iff_ultrafilter_le_nhds.mpr fun f _ =>
      ⟨joinM f, trivial, ultrafilter_converges_iff.mpr rfl⟩⟩
#align ultrafilter_compact ultrafilter_compact
-/

#print Ultrafilter.t2Space /-
instance Ultrafilter.t2Space : T2Space (Ultrafilter α) :=
  t2_iff_ultrafilter.mpr fun x y f fx fy =>
    have hx : x = joinM f := ultrafilter_converges_iff.mp fx
    have hy : y = joinM f := ultrafilter_converges_iff.mp fy
    hx.trans hy.symm
#align ultrafilter.t2_space Ultrafilter.t2Space
-/

instance : TotallyDisconnectedSpace (Ultrafilter α) :=
  by
  rw [totallyDisconnectedSpace_iff_connectedComponent_singleton]
  intro A
  simp only [Set.eq_singleton_iff_unique_mem, mem_connectedComponent, true_and_iff]
  intro B hB
  rw [← Ultrafilter.coe_le_coe]
  intro s hs
  rw [connectedComponent_eq_interᵢ_clopen, Set.mem_interᵢ] at hB
  let Z := { F : Ultrafilter α | s ∈ F }
  have hZ : IsClopen Z := ⟨ultrafilter_isOpen_basic s, ultrafilter_isClosed_basic s⟩
  exact hB ⟨Z, hZ, hs⟩

/- warning: ultrafilter_comap_pure_nhds -> ultrafilter_comap_pure_nhds is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} (b : Ultrafilter.{u1} α), LE.le.{u1} (Filter.{u1} α) (Preorder.toLE.{u1} (Filter.{u1} α) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.partialOrder.{u1} α))) (Filter.comap.{u1, u1} α (Ultrafilter.{u1} α) (Pure.pure.{u1, u1} Ultrafilter.{u1} Ultrafilter.hasPure.{u1} α) (nhds.{u1} (Ultrafilter.{u1} α) (Ultrafilter.topologicalSpace.{u1} α) b)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Ultrafilter.{u1} α) (Filter.{u1} α) (HasLiftT.mk.{succ u1, succ u1} (Ultrafilter.{u1} α) (Filter.{u1} α) (CoeTCₓ.coe.{succ u1, succ u1} (Ultrafilter.{u1} α) (Filter.{u1} α) (Ultrafilter.Filter.hasCoeT.{u1} α))) b)
but is expected to have type
  forall {α : Type.{u1}} (b : Ultrafilter.{u1} α), LE.le.{u1} (Filter.{u1} α) (Preorder.toLE.{u1} (Filter.{u1} α) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.instPartialOrderFilter.{u1} α))) (Filter.comap.{u1, u1} α (Ultrafilter.{u1} α) (Pure.pure.{u1, u1} Ultrafilter.{u1} Ultrafilter.instPureUltrafilter.{u1} α) (nhds.{u1} (Ultrafilter.{u1} α) (Ultrafilter.topologicalSpace.{u1} α) b)) (Ultrafilter.toFilter.{u1} α b)
Case conversion may be inaccurate. Consider using '#align ultrafilter_comap_pure_nhds ultrafilter_comap_pure_nhdsₓ'. -/
theorem ultrafilter_comap_pure_nhds (b : Ultrafilter α) : comap pure (𝓝 b) ≤ b :=
  by
  rw [TopologicalSpace.nhds_generateFrom]
  simp only [comap_infi, comap_principal]
  intro s hs
  rw [← le_principal_iff]
  refine' infᵢ_le_of_le { u | s ∈ u } _
  refine' infᵢ_le_of_le ⟨hs, ⟨s, rfl⟩⟩ _
  exact principal_mono.2 fun a => id
#align ultrafilter_comap_pure_nhds ultrafilter_comap_pure_nhds

section Embedding

/- warning: ultrafilter_pure_injective -> ultrafilter_pure_injective is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}}, Function.Injective.{succ u1, succ u1} α (Ultrafilter.{u1} α) (Pure.pure.{u1, u1} (fun {α : Type.{u1}} => Ultrafilter.{u1} α) Ultrafilter.hasPure.{u1} α)
but is expected to have type
  forall {α : Type.{u1}}, Function.Injective.{succ u1, succ u1} α (Ultrafilter.{u1} α) (Pure.pure.{u1, u1} Ultrafilter.{u1} Ultrafilter.instPureUltrafilter.{u1} α)
Case conversion may be inaccurate. Consider using '#align ultrafilter_pure_injective ultrafilter_pure_injectiveₓ'. -/
theorem ultrafilter_pure_injective : Function.Injective (pure : α → Ultrafilter α) :=
  by
  intro x y h
  have : {x} ∈ (pure x : Ultrafilter α) := singleton_mem_pure
  rw [h] at this
  exact (mem_singleton_iff.mp (mem_pure.mp this)).symm
#align ultrafilter_pure_injective ultrafilter_pure_injective

open TopologicalSpace

/- warning: dense_range_pure -> denseRange_pure is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}}, DenseRange.{u1, u1} (Ultrafilter.{u1} α) (Ultrafilter.topologicalSpace.{u1} α) α (Pure.pure.{u1, u1} (fun {α : Type.{u1}} => Ultrafilter.{u1} α) Ultrafilter.hasPure.{u1} α)
but is expected to have type
  forall {α : Type.{u1}}, DenseRange.{u1, u1} (Ultrafilter.{u1} α) (Ultrafilter.topologicalSpace.{u1} α) α (Pure.pure.{u1, u1} Ultrafilter.{u1} Ultrafilter.instPureUltrafilter.{u1} α)
Case conversion may be inaccurate. Consider using '#align dense_range_pure denseRange_pureₓ'. -/
/-- The range of `pure : α → ultrafilter α` is dense in `ultrafilter α`. -/
theorem denseRange_pure : DenseRange (pure : α → Ultrafilter α) := fun x =>
  mem_closure_iff_ultrafilter.mpr
    ⟨x.map pure, range_mem_map, ultrafilter_converges_iff.mpr (bind_pure x).symm⟩
#align dense_range_pure denseRange_pure

/- warning: induced_topology_pure -> induced_topology_pure is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}}, Eq.{succ u1} (TopologicalSpace.{u1} α) (TopologicalSpace.induced.{u1, u1} α (Ultrafilter.{u1} α) (Pure.pure.{u1, u1} (fun {α : Type.{u1}} => Ultrafilter.{u1} α) Ultrafilter.hasPure.{u1} α) (Ultrafilter.topologicalSpace.{u1} α)) (Bot.bot.{u1} (TopologicalSpace.{u1} α) (CompleteLattice.toHasBot.{u1} (TopologicalSpace.{u1} α) (TopologicalSpace.completeLattice.{u1} α)))
but is expected to have type
  forall {α : Type.{u1}}, Eq.{succ u1} (TopologicalSpace.{u1} α) (TopologicalSpace.induced.{u1, u1} α (Ultrafilter.{u1} α) (Pure.pure.{u1, u1} Ultrafilter.{u1} Ultrafilter.instPureUltrafilter.{u1} α) (Ultrafilter.topologicalSpace.{u1} α)) (Bot.bot.{u1} (TopologicalSpace.{u1} α) (CompleteLattice.toBot.{u1} (TopologicalSpace.{u1} α) (TopologicalSpace.instCompleteLatticeTopologicalSpace.{u1} α)))
Case conversion may be inaccurate. Consider using '#align induced_topology_pure induced_topology_pureₓ'. -/
/-- The map `pure : α → ultra_filter α` induces on `α` the discrete topology. -/
theorem induced_topology_pure :
    TopologicalSpace.induced (pure : α → Ultrafilter α) Ultrafilter.topologicalSpace = ⊥ :=
  by
  apply eq_bot_of_singletons_open
  intro x
  use { u : Ultrafilter α | {x} ∈ u }, ultrafilter_isOpen_basic _
  simp
#align induced_topology_pure induced_topology_pure

/- warning: dense_inducing_pure -> denseInducing_pure is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}}, DenseInducing.{u1, u1} α (Ultrafilter.{u1} α) (Bot.bot.{u1} (TopologicalSpace.{u1} α) (CompleteLattice.toHasBot.{u1} (TopologicalSpace.{u1} α) (TopologicalSpace.completeLattice.{u1} α))) (Ultrafilter.topologicalSpace.{u1} α) (Pure.pure.{u1, u1} (fun {α : Type.{u1}} => Ultrafilter.{u1} α) Ultrafilter.hasPure.{u1} α)
but is expected to have type
  forall {α : Type.{u1}}, DenseInducing.{u1, u1} α (Ultrafilter.{u1} α) (Bot.bot.{u1} (TopologicalSpace.{u1} α) (CompleteLattice.toBot.{u1} (TopologicalSpace.{u1} α) (TopologicalSpace.instCompleteLatticeTopologicalSpace.{u1} α))) (Ultrafilter.topologicalSpace.{u1} α) (Pure.pure.{u1, u1} Ultrafilter.{u1} Ultrafilter.instPureUltrafilter.{u1} α)
Case conversion may be inaccurate. Consider using '#align dense_inducing_pure denseInducing_pureₓ'. -/
/-- `pure : α → ultrafilter α` defines a dense inducing of `α` in `ultrafilter α`. -/
theorem denseInducing_pure : @DenseInducing _ _ ⊥ _ (pure : α → Ultrafilter α) :=
  letI : TopologicalSpace α := ⊥
  ⟨⟨induced_topology_pure.symm⟩, denseRange_pure⟩
#align dense_inducing_pure denseInducing_pure

/- warning: dense_embedding_pure -> denseEmbedding_pure is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}}, DenseEmbedding.{u1, u1} α (Ultrafilter.{u1} α) (Bot.bot.{u1} (TopologicalSpace.{u1} α) (CompleteLattice.toHasBot.{u1} (TopologicalSpace.{u1} α) (TopologicalSpace.completeLattice.{u1} α))) (Ultrafilter.topologicalSpace.{u1} α) (Pure.pure.{u1, u1} (fun {α : Type.{u1}} => Ultrafilter.{u1} α) Ultrafilter.hasPure.{u1} α)
but is expected to have type
  forall {α : Type.{u1}}, DenseEmbedding.{u1, u1} α (Ultrafilter.{u1} α) (Bot.bot.{u1} (TopologicalSpace.{u1} α) (CompleteLattice.toBot.{u1} (TopologicalSpace.{u1} α) (TopologicalSpace.instCompleteLatticeTopologicalSpace.{u1} α))) (Ultrafilter.topologicalSpace.{u1} α) (Pure.pure.{u1, u1} Ultrafilter.{u1} Ultrafilter.instPureUltrafilter.{u1} α)
Case conversion may be inaccurate. Consider using '#align dense_embedding_pure denseEmbedding_pureₓ'. -/
-- The following refined version will never be used
/-- `pure : α → ultrafilter α` defines a dense embedding of `α` in `ultrafilter α`. -/
theorem denseEmbedding_pure : @DenseEmbedding _ _ ⊥ _ (pure : α → Ultrafilter α) :=
  letI : TopologicalSpace α := ⊥
  { denseInducing_pure with inj := ultrafilter_pure_injective }
#align dense_embedding_pure denseEmbedding_pure

end Embedding

section Extension

/- Goal: Any function `α → γ` to a compact Hausdorff space `γ` has a
  unique extension to a continuous function `ultrafilter α → γ`. We
  already know it must be unique because `α → ultrafilter α` is a
  dense embedding and `γ` is Hausdorff. For existence, we will invoke
  `dense_embedding.continuous_extend`. -/
variable {γ : Type _} [TopologicalSpace γ]

#print Ultrafilter.extend /-
/-- The extension of a function `α → γ` to a function `ultrafilter α → γ`.
  When `γ` is a compact Hausdorff space it will be continuous. -/
def Ultrafilter.extend (f : α → γ) : Ultrafilter α → γ :=
  letI : TopologicalSpace α := ⊥
  dense_inducing_pure.extend f
#align ultrafilter.extend Ultrafilter.extend
-/

variable [T2Space γ]

/- warning: ultrafilter_extend_extends -> ultrafilter_extend_extends is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u2} γ] [_inst_2 : T2Space.{u2} γ _inst_1] (f : α -> γ), Eq.{max (succ u1) (succ u2)} (α -> γ) (Function.comp.{succ u1, succ u1, succ u2} α (Ultrafilter.{u1} α) γ (Ultrafilter.extend.{u1, u2} α γ _inst_1 f) (Pure.pure.{u1, u1} Ultrafilter.{u1} Ultrafilter.hasPure.{u1} α)) f
but is expected to have type
  forall {α : Type.{u2}} {γ : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} γ] [_inst_2 : T2Space.{u1} γ _inst_1] (f : α -> γ), Eq.{max (succ u2) (succ u1)} (α -> γ) (Function.comp.{succ u2, succ u2, succ u1} α (Ultrafilter.{u2} α) γ (Ultrafilter.extend.{u2, u1} α γ _inst_1 f) (Pure.pure.{u2, u2} Ultrafilter.{u2} Ultrafilter.instPureUltrafilter.{u2} α)) f
Case conversion may be inaccurate. Consider using '#align ultrafilter_extend_extends ultrafilter_extend_extendsₓ'. -/
theorem ultrafilter_extend_extends (f : α → γ) : Ultrafilter.extend f ∘ pure = f :=
  by
  letI : TopologicalSpace α := ⊥
  haveI : DiscreteTopology α := ⟨rfl⟩
  exact funext (dense_inducing_pure.extend_eq continuous_of_discreteTopology)
#align ultrafilter_extend_extends ultrafilter_extend_extends

variable [CompactSpace γ]

/- warning: continuous_ultrafilter_extend -> continuous_ultrafilter_extend is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u2} γ] [_inst_2 : T2Space.{u2} γ _inst_1] [_inst_3 : CompactSpace.{u2} γ _inst_1] (f : α -> γ), Continuous.{u1, u2} (Ultrafilter.{u1} α) γ (Ultrafilter.topologicalSpace.{u1} α) _inst_1 (Ultrafilter.extend.{u1, u2} α γ _inst_1 f)
but is expected to have type
  forall {α : Type.{u2}} {γ : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} γ] [_inst_2 : T2Space.{u1} γ _inst_1] [_inst_3 : CompactSpace.{u1} γ _inst_1] (f : α -> γ), Continuous.{u2, u1} (Ultrafilter.{u2} α) γ (Ultrafilter.topologicalSpace.{u2} α) _inst_1 (Ultrafilter.extend.{u2, u1} α γ _inst_1 f)
Case conversion may be inaccurate. Consider using '#align continuous_ultrafilter_extend continuous_ultrafilter_extendₓ'. -/
theorem continuous_ultrafilter_extend (f : α → γ) : Continuous (Ultrafilter.extend f) :=
  by
  have : ∀ b : Ultrafilter α, ∃ c, Tendsto f (comap pure (𝓝 b)) (𝓝 c) := fun b =>
    -- b.map f is an ultrafilter on γ, which is compact, so it converges to some c in γ.
    let ⟨c, _, h⟩ :=
      isCompact_univ.ultrafilter_le_nhds (b.map f) (by rw [le_principal_iff] <;> exact univ_mem)
    ⟨c, le_trans (map_mono (ultrafilter_comap_pure_nhds _)) h⟩
  letI : TopologicalSpace α := ⊥
  haveI : NormalSpace γ := normalOfCompactT2
  exact dense_inducing_pure.continuous_extend this
#align continuous_ultrafilter_extend continuous_ultrafilter_extend

/- warning: ultrafilter_extend_eq_iff -> ultrafilter_extend_eq_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {γ : Type.{u2}} [_inst_1 : TopologicalSpace.{u2} γ] [_inst_2 : T2Space.{u2} γ _inst_1] [_inst_3 : CompactSpace.{u2} γ _inst_1] {f : α -> γ} {b : Ultrafilter.{u1} α} {c : γ}, Iff (Eq.{succ u2} γ (Ultrafilter.extend.{u1, u2} α γ _inst_1 f b) c) (LE.le.{u2} (Filter.{u2} γ) (Preorder.toLE.{u2} (Filter.{u2} γ) (PartialOrder.toPreorder.{u2} (Filter.{u2} γ) (Filter.partialOrder.{u2} γ))) ((fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (Ultrafilter.{u2} γ) (Filter.{u2} γ) (HasLiftT.mk.{succ u2, succ u2} (Ultrafilter.{u2} γ) (Filter.{u2} γ) (CoeTCₓ.coe.{succ u2, succ u2} (Ultrafilter.{u2} γ) (Filter.{u2} γ) (Ultrafilter.Filter.hasCoeT.{u2} γ))) (Ultrafilter.map.{u1, u2} α γ f b)) (nhds.{u2} γ _inst_1 c))
but is expected to have type
  forall {α : Type.{u2}} {γ : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} γ] [_inst_2 : T2Space.{u1} γ _inst_1] [_inst_3 : CompactSpace.{u1} γ _inst_1] {f : α -> γ} {b : Ultrafilter.{u2} α} {c : γ}, Iff (Eq.{succ u1} γ (Ultrafilter.extend.{u2, u1} α γ _inst_1 f b) c) (LE.le.{u1} (Filter.{u1} γ) (Preorder.toLE.{u1} (Filter.{u1} γ) (PartialOrder.toPreorder.{u1} (Filter.{u1} γ) (Filter.instPartialOrderFilter.{u1} γ))) (Ultrafilter.toFilter.{u1} γ (Ultrafilter.map.{u2, u1} α γ f b)) (nhds.{u1} γ _inst_1 c))
Case conversion may be inaccurate. Consider using '#align ultrafilter_extend_eq_iff ultrafilter_extend_eq_iffₓ'. -/
/-- The value of `ultrafilter.extend f` on an ultrafilter `b` is the
  unique limit of the ultrafilter `b.map f` in `γ`. -/
theorem ultrafilter_extend_eq_iff {f : α → γ} {b : Ultrafilter α} {c : γ} :
    Ultrafilter.extend f b = c ↔ ↑(b.map f) ≤ 𝓝 c :=
  ⟨fun h =>
    by
    -- Write b as an ultrafilter limit of pure ultrafilters, and use
    -- the facts that ultrafilter.extend is a continuous extension of f.
    let b' : Ultrafilter (Ultrafilter α) := b.map pure
    have t : ↑b' ≤ 𝓝 b := ultrafilter_converges_iff.mpr (bind_pure _).symm
    rw [← h]
    have := (continuous_ultrafilter_extend f).Tendsto b
    refine' le_trans _ (le_trans (map_mono t) this)
    change _ ≤ map (Ultrafilter.extend f ∘ pure) ↑b
    rw [ultrafilter_extend_extends]
    exact le_rfl, fun h =>
    letI : TopologicalSpace α := ⊥
    dense_inducing_pure.extend_eq_of_tendsto
      (le_trans (map_mono (ultrafilter_comap_pure_nhds _)) h)⟩
#align ultrafilter_extend_eq_iff ultrafilter_extend_eq_iff

end Extension

end Ultrafilter

section StoneCech

/- Now, we start with a (not necessarily discrete) topological space α
  and we want to construct its Stone-Čech compactification. We can
  build it as a quotient of `ultrafilter α` by the relation which
  identifies two points if the extension of every continuous function
  α → γ to a compact Hausdorff space sends the two points to the same
  point of γ. -/
variable (α : Type u) [TopologicalSpace α]

#print stoneCechSetoid /-
instance stoneCechSetoid : Setoid (Ultrafilter α)
    where
  R x y :=
    ∀ (γ : Type u) [TopologicalSpace γ],
      ∀ [T2Space γ] [CompactSpace γ] (f : α → γ) (hf : Continuous f),
        Ultrafilter.extend f x = Ultrafilter.extend f y
  iseqv :=
    ⟨fun x γ tγ h₁ h₂ f hf => rfl, fun x y xy γ tγ h₁ h₂ f hf => (xy γ f hf).symm,
      fun x y z xy yz γ tγ h₁ h₂ f hf => (xy γ f hf).trans (yz γ f hf)⟩
#align stone_cech_setoid stoneCechSetoid
-/

#print StoneCech /-
/-- The Stone-Čech compactification of a topological space. -/
def StoneCech : Type u :=
  Quotient (stoneCechSetoid α)
#align stone_cech StoneCech
-/

variable {α}

instance : TopologicalSpace (StoneCech α) := by unfold StoneCech <;> infer_instance

instance [Inhabited α] : Inhabited (StoneCech α) := by unfold StoneCech <;> infer_instance

#print stoneCechUnit /-
/-- The natural map from α to its Stone-Čech compactification. -/
def stoneCechUnit (x : α) : StoneCech α :=
  ⟦pure x⟧
#align stone_cech_unit stoneCechUnit
-/

#print denseRange_stoneCechUnit /-
/-- The image of stone_cech_unit is dense. (But stone_cech_unit need
  not be an embedding, for example if α is not Hausdorff.) -/
theorem denseRange_stoneCechUnit : DenseRange (stoneCechUnit : α → StoneCech α) :=
  denseRange_pure.Quotient
#align dense_range_stone_cech_unit denseRange_stoneCechUnit
-/

section Extension

variable {γ : Type u} [TopologicalSpace γ] [T2Space γ] [CompactSpace γ]

variable {γ' : Type u} [TopologicalSpace γ'] [T2Space γ']

variable {f : α → γ} (hf : Continuous f)

attribute [local elab_with_expected_type] Quotient.lift

#print stoneCechExtend /-
/-- The extension of a continuous function from α to a compact
  Hausdorff space γ to the Stone-Čech compactification of α. -/
def stoneCechExtend : StoneCech α → γ :=
  Quotient.lift (Ultrafilter.extend f) fun x y xy => xy γ f hf
#align stone_cech_extend stoneCechExtend
-/

#print stoneCechExtend_extends /-
theorem stoneCechExtend_extends : stoneCechExtend hf ∘ stoneCechUnit = f :=
  ultrafilter_extend_extends f
#align stone_cech_extend_extends stoneCechExtend_extends
-/

#print continuous_stoneCechExtend /-
theorem continuous_stoneCechExtend : Continuous (stoneCechExtend hf) :=
  continuous_quot_lift _ (continuous_ultrafilter_extend f)
#align continuous_stone_cech_extend continuous_stoneCechExtend
-/

#print stoneCech_hom_ext /-
theorem stoneCech_hom_ext {g₁ g₂ : StoneCech α → γ'} (h₁ : Continuous g₁) (h₂ : Continuous g₂)
    (h : g₁ ∘ stoneCechUnit = g₂ ∘ stoneCechUnit) : g₁ = g₂ :=
  by
  apply Continuous.ext_on denseRange_stoneCechUnit h₁ h₂
  rintro x ⟨x, rfl⟩
  apply congr_fun h x
#align stone_cech_hom_ext stoneCech_hom_ext
-/

end Extension

/- warning: convergent_eqv_pure -> convergent_eqv_pure is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {u : Ultrafilter.{u1} α} {x : α}, (LE.le.{u1} (Filter.{u1} α) (Preorder.toLE.{u1} (Filter.{u1} α) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.partialOrder.{u1} α))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Ultrafilter.{u1} α) (Filter.{u1} α) (HasLiftT.mk.{succ u1, succ u1} (Ultrafilter.{u1} α) (Filter.{u1} α) (CoeTCₓ.coe.{succ u1, succ u1} (Ultrafilter.{u1} α) (Filter.{u1} α) (Ultrafilter.Filter.hasCoeT.{u1} α))) u) (nhds.{u1} α _inst_1 x)) -> (HasEquivₓ.Equiv.{succ u1} (Ultrafilter.{u1} α) (setoidHasEquiv.{succ u1} (Ultrafilter.{u1} α) (stoneCechSetoid.{u1} α _inst_1)) u (Pure.pure.{u1, u1} Ultrafilter.{u1} Ultrafilter.hasPure.{u1} α x))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {u : Ultrafilter.{u1} α} {x : α}, (LE.le.{u1} (Filter.{u1} α) (Preorder.toLE.{u1} (Filter.{u1} α) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.instPartialOrderFilter.{u1} α))) (Ultrafilter.toFilter.{u1} α u) (nhds.{u1} α _inst_1 x)) -> (HasEquiv.Equiv.{succ u1, 0} (Ultrafilter.{u1} α) (instHasEquiv.{succ u1} (Ultrafilter.{u1} α) (stoneCechSetoid.{u1} α _inst_1)) u (Pure.pure.{u1, u1} Ultrafilter.{u1} Ultrafilter.instPureUltrafilter.{u1} α x))
Case conversion may be inaccurate. Consider using '#align convergent_eqv_pure convergent_eqv_pureₓ'. -/
theorem convergent_eqv_pure {u : Ultrafilter α} {x : α} (ux : ↑u ≤ 𝓝 x) : u ≈ pure x :=
  fun γ tγ h₁ h₂ f hf => by
  skip
  trans f x; swap; symm
  all_goals refine' ultrafilter_extend_eq_iff.mpr (le_trans (map_mono _) (hf.tendsto _))
  · apply pure_le_nhds; · exact ux
#align convergent_eqv_pure convergent_eqv_pure

#print continuous_stoneCechUnit /-
theorem continuous_stoneCechUnit : Continuous (stoneCechUnit : α → StoneCech α) :=
  continuous_iff_ultrafilter.mpr fun x g gx =>
    by
    have : ↑(g.map pure) ≤ 𝓝 g := by rw [ultrafilter_converges_iff] <;> exact (bind_pure _).symm
    have : (g.map stoneCechUnit : Filter (StoneCech α)) ≤ 𝓝 ⟦g⟧ :=
      continuousAt_iff_ultrafilter.mp (continuous_quotient_mk'.Tendsto g) _ this
    rwa [show ⟦g⟧ = ⟦pure x⟧ from Quotient.sound <| convergent_eqv_pure gx] at this
#align continuous_stone_cech_unit continuous_stoneCechUnit
-/

#print StoneCech.t2Space /-
instance StoneCech.t2Space : T2Space (StoneCech α) :=
  by
  rw [t2_iff_ultrafilter]
  rintro ⟨x⟩ ⟨y⟩ g gx gy
  apply Quotient.sound
  intro γ tγ h₁ h₂ f hf
  skip
  let ff := stoneCechExtend hf
  change ff ⟦x⟧ = ff ⟦y⟧
  have lim := fun (z : Ultrafilter α) (gz : (g : Filter (StoneCech α)) ≤ 𝓝 ⟦z⟧) =>
    ((continuous_stoneCechExtend hf).Tendsto _).mono_left gz
  exact tendsto_nhds_unique (limUnder x gx) (limUnder y gy)
#align stone_cech.t2_space StoneCech.t2Space
-/

#print StoneCech.compactSpace /-
instance StoneCech.compactSpace : CompactSpace (StoneCech α) :=
  Quotient.compactSpace
#align stone_cech.compact_space StoneCech.compactSpace
-/

end StoneCech

