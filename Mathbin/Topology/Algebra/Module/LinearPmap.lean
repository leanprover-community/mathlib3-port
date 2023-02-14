/-
Copyright (c) 2022 Moritz Doll. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Moritz Doll

! This file was ported from Lean 3 source module topology.algebra.module.linear_pmap
! leanprover-community/mathlib commit 48085f140e684306f9e7da907cd5932056d1aded
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.LinearPmap
import Mathbin.Topology.Algebra.Module.Basic

/-!
# Partially defined linear operators over topological vector spaces

We define basic notions of partially defined linear operators, which we call unbounded operators
for short.
In this file we prove all elementary properties of unbounded operators that do not assume that the
underlying spaces are normed.

## Main definitions

* `linear_pmap.is_closed`: An unbounded operator is closed iff its graph is closed.
* `linear_pmap.is_closable`: An unbounded operator is closable iff the closure of its graph is a
  graph.
* `linear_pmap.closure`: For a closable unbounded operator `f : linear_pmap R E F` the closure is
  the smallest closed extension of `f`. If `f` is not closable, then `f.closure` is defined as `f`.
* `linear_pmap.has_core`: a submodule contained in the domain is a core if restricting to the core
  does not lose information about the unbounded operator.

## Main statements

* `linear_pmap.closable_iff_exists_closed_extension`: an unbounded operator is closable iff it has a
  closed extension.
* `linear_pmap.closable.exists_unique`: there exists a unique closure
* `linear_pmap.closure_has_core`: the domain of `f` is a core of its closure

## References

* [J. Weidmann, *Linear Operators in Hilbert Spaces*][weidmann_linear]

## Tags

Unbounded operators, closed operators
-/


open Topology

variable {R E F : Type _}

variable [CommRing R] [AddCommGroup E] [AddCommGroup F]

variable [Module R E] [Module R F]

variable [TopologicalSpace E] [TopologicalSpace F]

namespace LinearPmap

/-! ### Closed and closable operators -/


/-- An unbounded operator is closed iff its graph is closed. -/
def IsClosed (f : E →ₗ.[R] F) : Prop :=
  IsClosed (f.graph : Set (E × F))
#align linear_pmap.is_closed LinearPmap.IsClosed

variable [ContinuousAdd E] [ContinuousAdd F]

variable [TopologicalSpace R] [ContinuousSMul R E] [ContinuousSMul R F]

/-- An unbounded operator is closable iff the closure of its graph is a graph. -/
def IsClosable (f : E →ₗ.[R] F) : Prop :=
  ∃ f' : LinearPmap R E F, f.graph.topologicalClosure = f'.graph
#align linear_pmap.is_closable LinearPmap.IsClosable

/-- A closed operator is trivially closable. -/
theorem IsClosed.isClosable {f : E →ₗ.[R] F} (hf : f.IsClosed) : f.IsClosable :=
  ⟨f, hf.submodule_topologicalClosure_eq⟩
#align linear_pmap.is_closed.is_closable LinearPmap.IsClosed.isClosable

/-- If `g` has a closable extension `f`, then `g` itself is closable. -/
theorem IsClosable.leIsClosable {f g : E →ₗ.[R] F} (hf : f.IsClosable) (hfg : g ≤ f) :
    g.IsClosable := by
  cases' hf with f' hf
  have : g.graph.topological_closure ≤ f'.graph :=
    by
    rw [← hf]
    exact Submodule.topologicalClosure_mono (le_graph_of_le hfg)
  refine' ⟨g.graph.topological_closure.to_linear_pmap _, _⟩
  · intro x hx hx'
    cases x
    exact f'.graph_fst_eq_zero_snd (this hx) hx'
  rw [Submodule.toLinearPmap_graph_eq]
#align linear_pmap.is_closable.le_is_closable LinearPmap.IsClosable.leIsClosable

/-- The closure is unique. -/
theorem IsClosable.existsUnique {f : E →ₗ.[R] F} (hf : f.IsClosable) :
    ∃! f' : E →ₗ.[R] F, f.graph.topologicalClosure = f'.graph :=
  by
  refine' existsUnique_of_exists_of_unique hf fun _ _ hy₁ hy₂ => eq_of_eq_graph _
  rw [← hy₁, ← hy₂]
#align linear_pmap.is_closable.exists_unique LinearPmap.IsClosable.existsUnique

open Classical

/-- If `f` is closable, then `f.closure` is the closure. Otherwise it is defined
as `f.closure = f`. -/
noncomputable def closure (f : E →ₗ.[R] F) : E →ₗ.[R] F :=
  if hf : f.IsClosable then hf.some else f
#align linear_pmap.closure LinearPmap.closure

theorem closure_def {f : E →ₗ.[R] F} (hf : f.IsClosable) : f.closure = hf.some := by
  simp [closure, hf]
#align linear_pmap.closure_def LinearPmap.closure_def

theorem closure_def' {f : E →ₗ.[R] F} (hf : ¬f.IsClosable) : f.closure = f := by simp [closure, hf]
#align linear_pmap.closure_def' LinearPmap.closure_def'

/-- The closure (as a submodule) of the graph is equal to the graph of the closure
  (as a `linear_pmap`). -/
theorem IsClosable.graph_closure_eq_closure_graph {f : E →ₗ.[R] F} (hf : f.IsClosable) :
    f.graph.topologicalClosure = f.closure.graph :=
  by
  rw [closure_def hf]
  exact hf.some_spec
#align linear_pmap.is_closable.graph_closure_eq_closure_graph LinearPmap.IsClosable.graph_closure_eq_closure_graph

/-- A `linear_pmap` is contained in its closure. -/
theorem le_closure (f : E →ₗ.[R] F) : f ≤ f.closure :=
  by
  by_cases hf : f.is_closable
  · refine' le_of_le_graph _
    rw [← hf.graph_closure_eq_closure_graph]
    exact (graph f).le_topologicalClosure
  rw [closure_def' hf]
#align linear_pmap.le_closure LinearPmap.le_closure

theorem IsClosable.closure_mono {f g : E →ₗ.[R] F} (hg : g.IsClosable) (h : f ≤ g) :
    f.closure ≤ g.closure := by
  refine' le_of_le_graph _
  rw [← (hg.le_is_closable h).graph_closure_eq_closure_graph]
  rw [← hg.graph_closure_eq_closure_graph]
  exact Submodule.topologicalClosure_mono (le_graph_of_le h)
#align linear_pmap.is_closable.closure_mono LinearPmap.IsClosable.closure_mono

/-- If `f` is closable, then the closure is closed. -/
theorem IsClosable.closure_isClosed {f : E →ₗ.[R] F} (hf : f.IsClosable) : f.closure.IsClosed :=
  by
  rw [IsClosed, ← hf.graph_closure_eq_closure_graph]
  exact f.graph.is_closed_topological_closure
#align linear_pmap.is_closable.closure_is_closed LinearPmap.IsClosable.closure_isClosed

/-- If `f` is closable, then the closure is closable. -/
theorem IsClosable.closureIsClosable {f : E →ₗ.[R] F} (hf : f.IsClosable) : f.closure.IsClosable :=
  hf.closure_isClosed.IsClosable
#align linear_pmap.is_closable.closure_is_closable LinearPmap.IsClosable.closureIsClosable

theorem isClosable_iff_exists_closed_extension {f : E →ₗ.[R] F} :
    f.IsClosable ↔ ∃ (g : E →ₗ.[R] F)(hg : g.IsClosed), f ≤ g :=
  ⟨fun h => ⟨f.closure, h.closure_isClosed, f.le_closure⟩, fun ⟨_, hg, h⟩ =>
    hg.IsClosable.leIsClosable h⟩
#align linear_pmap.is_closable_iff_exists_closed_extension LinearPmap.isClosable_iff_exists_closed_extension

/-! ### The core of a linear operator -/


/-- A submodule `S` is a core of `f` if the closure of the restriction of `f` to `S` is again `f`.-/
structure HasCore (f : E →ₗ.[R] F) (S : Submodule R E) : Prop where
  le_domain : S ≤ f.domain
  closure_eq : (f.domRestrict S).closure = f
#align linear_pmap.has_core LinearPmap.HasCore

theorem hasCore_def {f : E →ₗ.[R] F} {S : Submodule R E} (h : f.HasCore S) :
    (f.domRestrict S).closure = f :=
  h.2
#align linear_pmap.has_core_def LinearPmap.hasCore_def

/-- For every unbounded operator `f` the submodule `f.domain` is a core of its closure.

Note that we don't require that `f` is closable, due to the definition of the closure. -/
theorem closureHasCore (f : E →ₗ.[R] F) : f.closure.HasCore f.domain :=
  by
  refine' ⟨f.le_closure.1, _⟩
  congr
  ext
  · simp only [dom_restrict_domain, Submodule.mem_inf, and_iff_left_iff_imp]
    intro hx
    exact f.le_closure.1 hx
  intro x y hxy
  let z : f.closure.domain := ⟨y.1, f.le_closure.1 y.2⟩
  have hyz : (y : E) = z := by simp
  rw [f.le_closure.2 hyz]
  exact dom_restrict_apply (hxy.trans hyz)
#align linear_pmap.closure_has_core LinearPmap.closureHasCore

end LinearPmap

