/-
Copyright (c) 2021 Christopher Hoskin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Christopher Hoskin

! This file was ported from Lean 3 source module topology.order.lattice
! leanprover-community/mathlib commit 3e32bc908f617039c74c06ea9a897e30c30803c2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Order.Basic
import Mathbin.Topology.Constructions

/-!
# Topological lattices

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define mixin classes `has_continuous_inf` and `has_continuous_sup`. We define the
class `topological_lattice` as a topological space and lattice `L` extending `has_continuous_inf`
and `has_continuous_sup`.

## References

* [Gierz et al, A Compendium of Continuous Lattices][GierzEtAl1980]

## Tags

topological, lattice
-/


open Filter

open scoped Topology

#print ContinuousInf /-
/-- Let `L` be a topological space and let `L×L` be equipped with the product topology and let
`⊓:L×L → L` be an infimum. Then `L` is said to have *(jointly) continuous infimum* if the map
`⊓:L×L → L` is continuous.
-/
class ContinuousInf (L : Type _) [TopologicalSpace L] [Inf L] : Prop where
  continuous_inf : Continuous fun p : L × L => p.1 ⊓ p.2
#align has_continuous_inf ContinuousInf
-/

#print ContinuousSup /-
/-- Let `L` be a topological space and let `L×L` be equipped with the product topology and let
`⊓:L×L → L` be a supremum. Then `L` is said to have *(jointly) continuous supremum* if the map
`⊓:L×L → L` is continuous.
-/
class ContinuousSup (L : Type _) [TopologicalSpace L] [Sup L] : Prop where
  continuous_sup : Continuous fun p : L × L => p.1 ⊔ p.2
#align has_continuous_sup ContinuousSup
-/

#print OrderDual.continuousSup /-
-- see Note [lower instance priority]
instance (priority := 100) OrderDual.continuousSup (L : Type _) [TopologicalSpace L] [Inf L]
    [ContinuousInf L] : ContinuousSup Lᵒᵈ
    where continuous_sup := @ContinuousInf.continuous_inf L _ _ _
#align order_dual.has_continuous_sup OrderDual.continuousSup
-/

#print OrderDual.continuousInf /-
-- see Note [lower instance priority]
instance (priority := 100) OrderDual.continuousInf (L : Type _) [TopologicalSpace L] [Sup L]
    [ContinuousSup L] : ContinuousInf Lᵒᵈ
    where continuous_inf := @ContinuousSup.continuous_sup L _ _ _
#align order_dual.has_continuous_inf OrderDual.continuousInf
-/

#print TopologicalLattice /-
/-- Let `L` be a lattice equipped with a topology such that `L` has continuous infimum and supremum.
Then `L` is said to be a *topological lattice*.
-/
class TopologicalLattice (L : Type _) [TopologicalSpace L] [Lattice L] extends ContinuousInf L,
    ContinuousSup L
#align topological_lattice TopologicalLattice
-/

#print OrderDual.topologicalLattice /-
-- see Note [lower instance priority]
instance (priority := 100) OrderDual.topologicalLattice (L : Type _) [TopologicalSpace L]
    [Lattice L] [TopologicalLattice L] : TopologicalLattice Lᵒᵈ where
#align order_dual.topological_lattice OrderDual.topologicalLattice
-/

#print LinearOrder.topologicalLattice /-
-- see Note [lower instance priority]
instance (priority := 100) LinearOrder.topologicalLattice {L : Type _} [TopologicalSpace L]
    [LinearOrder L] [OrderClosedTopology L] : TopologicalLattice L
    where
  continuous_inf := continuous_min
  continuous_sup := continuous_max
#align linear_order.topological_lattice LinearOrder.topologicalLattice
-/

variable {L : Type _} [TopologicalSpace L]

variable {X : Type _} [TopologicalSpace X]

#print continuous_inf /-
@[continuity]
theorem continuous_inf [Inf L] [ContinuousInf L] : Continuous fun p : L × L => p.1 ⊓ p.2 :=
  ContinuousInf.continuous_inf
#align continuous_inf continuous_inf
-/

#print Continuous.inf /-
@[continuity]
theorem Continuous.inf [Inf L] [ContinuousInf L] {f g : X → L} (hf : Continuous f)
    (hg : Continuous g) : Continuous fun x => f x ⊓ g x :=
  continuous_inf.comp (hf.prod_mk hg : _)
#align continuous.inf Continuous.inf
-/

#print continuous_sup /-
@[continuity]
theorem continuous_sup [Sup L] [ContinuousSup L] : Continuous fun p : L × L => p.1 ⊔ p.2 :=
  ContinuousSup.continuous_sup
#align continuous_sup continuous_sup
-/

#print Continuous.sup /-
@[continuity]
theorem Continuous.sup [Sup L] [ContinuousSup L] {f g : X → L} (hf : Continuous f)
    (hg : Continuous g) : Continuous fun x => f x ⊔ g x :=
  continuous_sup.comp (hf.prod_mk hg : _)
#align continuous.sup Continuous.sup
-/

#print Filter.Tendsto.sup_right_nhds' /-
theorem Filter.Tendsto.sup_right_nhds' {ι β} [TopologicalSpace β] [Sup β] [ContinuousSup β]
    {l : Filter ι} {f g : ι → β} {x y : β} (hf : Tendsto f l (𝓝 x)) (hg : Tendsto g l (𝓝 y)) :
    Tendsto (f ⊔ g) l (𝓝 (x ⊔ y)) :=
  (continuous_sup.Tendsto _).comp (Tendsto.prod_mk_nhds hf hg)
#align filter.tendsto.sup_right_nhds' Filter.Tendsto.sup_right_nhds'
-/

#print Filter.Tendsto.sup_right_nhds /-
theorem Filter.Tendsto.sup_right_nhds {ι β} [TopologicalSpace β] [Sup β] [ContinuousSup β]
    {l : Filter ι} {f g : ι → β} {x y : β} (hf : Tendsto f l (𝓝 x)) (hg : Tendsto g l (𝓝 y)) :
    Tendsto (fun i => f i ⊔ g i) l (𝓝 (x ⊔ y)) :=
  hf.sup_right_nhds' hg
#align filter.tendsto.sup_right_nhds Filter.Tendsto.sup_right_nhds
-/

#print Filter.Tendsto.inf_right_nhds' /-
theorem Filter.Tendsto.inf_right_nhds' {ι β} [TopologicalSpace β] [Inf β] [ContinuousInf β]
    {l : Filter ι} {f g : ι → β} {x y : β} (hf : Tendsto f l (𝓝 x)) (hg : Tendsto g l (𝓝 y)) :
    Tendsto (f ⊓ g) l (𝓝 (x ⊓ y)) :=
  (continuous_inf.Tendsto _).comp (Tendsto.prod_mk_nhds hf hg)
#align filter.tendsto.inf_right_nhds' Filter.Tendsto.inf_right_nhds'
-/

#print Filter.Tendsto.inf_right_nhds /-
theorem Filter.Tendsto.inf_right_nhds {ι β} [TopologicalSpace β] [Inf β] [ContinuousInf β]
    {l : Filter ι} {f g : ι → β} {x y : β} (hf : Tendsto f l (𝓝 x)) (hg : Tendsto g l (𝓝 y)) :
    Tendsto (fun i => f i ⊓ g i) l (𝓝 (x ⊓ y)) :=
  hf.inf_right_nhds' hg
#align filter.tendsto.inf_right_nhds Filter.Tendsto.inf_right_nhds
-/

