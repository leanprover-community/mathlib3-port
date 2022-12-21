/-
Copyright (c) 2021 Kyle Miller. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kyle Miller

! This file was ported from Lean 3 source module combinatorics.simple_graph.connectivity
! leanprover-community/mathlib commit 0743cc5d9d86bcd1bba10f480e948a257d65056f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Combinatorics.SimpleGraph.Basic
import Mathbin.Combinatorics.SimpleGraph.Subgraph
import Mathbin.Data.List.Rotate

/-!

# Graph connectivity

In a simple graph,

* A *walk* is a finite sequence of adjacent vertices, and can be
  thought of equally well as a sequence of directed edges.

* A *trail* is a walk whose edges each appear no more than once.

* A *path* is a trail whose vertices appear no more than once.

* A *cycle* is a nonempty trail whose first and last vertices are the
  same and whose vertices except for the first appear no more than once.

**Warning:** graph theorists mean something different by "path" than
do homotopy theorists.  A "walk" in graph theory is a "path" in
homotopy theory.  Another warning: some graph theorists use "path" and
"simple path" for "walk" and "path."

Some definitions and theorems have inspiration from multigraph
counterparts in [Chou1994].

## Main definitions

* `simple_graph.walk` (with accompanying pattern definitions
  `simple_graph.walk.nil'` and `simple_graph.walk.cons'`)

* `simple_graph.walk.is_trail`, `simple_graph.walk.is_path`, and `simple_graph.walk.is_cycle`.

* `simple_graph.path`

* `simple_graph.walk.map` and `simple_graph.path.map` for the induced map on walks,
  given an (injective) graph homomorphism.

* `simple_graph.reachable` for the relation of whether there exists
  a walk between a given pair of vertices

* `simple_graph.preconnected` and `simple_graph.connected` are predicates
  on simple graphs for whether every vertex can be reached from every other,
  and in the latter case, whether the vertex type is nonempty.

* `simple_graph.subgraph.connected` gives subgraphs the connectivity
  predicate via `simple_graph.subgraph.coe`.

* `simple_graph.connected_component` is the type of connected components of
  a given graph.

* `simple_graph.is_bridge` for whether an edge is a bridge edge

## Main statements

* `simple_graph.is_bridge_iff_mem_and_forall_cycle_not_mem` characterizes bridge edges in terms of
  there being no cycle containing them.

## Tags
walks, trails, paths, circuits, cycles, bridge edges

-/


open Function

universe u v w

namespace SimpleGraph

variable {V : Type u} {V' : Type v} {V'' : Type w}

variable (G : SimpleGraph V) (G' : SimpleGraph V') (G'' : SimpleGraph V'')

/-- A walk is a sequence of adjacent vertices.  For vertices `u v : V`,
the type `walk u v` consists of all walks starting at `u` and ending at `v`.

We say that a walk *visits* the vertices it contains.  The set of vertices a
walk visits is `simple_graph.walk.support`.

See `simple_graph.walk.nil'` and `simple_graph.walk.cons'` for patterns that
can be useful in definitions since they make the vertices explicit. -/
inductive Walk : V → V → Type u
  | nil {u : V} : walk u u
  | cons {u v w : V} (h : G.Adj u v) (p : walk v w) : walk u w
  deriving DecidableEq
#align simple_graph.walk SimpleGraph.Walk

attribute [refl] walk.nil

@[simps]
instance Walk.inhabited (v : V) : Inhabited (G.Walk v v) :=
  ⟨Walk.nil⟩
#align simple_graph.walk.inhabited SimpleGraph.Walk.inhabited

/-- The one-edge walk associated to a pair of adjacent vertices. -/
@[match_pattern, reducible]
def Adj.toWalk {G : SimpleGraph V} {u v : V} (h : G.Adj u v) : G.Walk u v :=
  Walk.cons h Walk.nil
#align simple_graph.adj.to_walk SimpleGraph.Adj.toWalk

namespace Walk

variable {G}

/-- Pattern to get `walk.nil` with the vertex as an explicit argument. -/
@[match_pattern]
abbrev nil' (u : V) : G.Walk u u :=
  walk.nil
#align simple_graph.walk.nil' SimpleGraph.Walk.nil'

/-- Pattern to get `walk.cons` with the vertices as explicit arguments. -/
@[match_pattern]
abbrev cons' (u v w : V) (h : G.Adj u v) (p : G.Walk v w) : G.Walk u w :=
  Walk.cons h p
#align simple_graph.walk.cons' SimpleGraph.Walk.cons'

/-- Change the endpoints of a walk using equalities. This is helpful for relaxing
definitional equality constraints and to be able to state otherwise difficult-to-state
lemmas. While this is a simple wrapper around `eq.rec`, it gives a canonical way to write it.

The simp-normal form is for the `copy` to be pushed outward. That way calculations can
occur within the "copy context." -/
protected def copy {u v u' v'} (p : G.Walk u v) (hu : u = u') (hv : v = v') : G.Walk u' v' :=
  Eq.ndrec (Eq.ndrec p hv) hu
#align simple_graph.walk.copy SimpleGraph.Walk.copy

@[simp]
theorem copy_rfl_rfl {u v} (p : G.Walk u v) : p.copy rfl rfl = p :=
  rfl
#align simple_graph.walk.copy_rfl_rfl SimpleGraph.Walk.copy_rfl_rfl

@[simp]
theorem copy_copy {u v u' v' u'' v''} (p : G.Walk u v) (hu : u = u') (hv : v = v') (hu' : u' = u'')
    (hv' : v' = v'') : (p.copy hu hv).copy hu' hv' = p.copy (hu.trans hu') (hv.trans hv') := by
  subst_vars
  rfl
#align simple_graph.walk.copy_copy SimpleGraph.Walk.copy_copy

@[simp]
theorem copy_nil {u u'} (hu : u = u') : (Walk.nil : G.Walk u u).copy hu hu = walk.nil := by
  subst_vars
  rfl
#align simple_graph.walk.copy_nil SimpleGraph.Walk.copy_nil

theorem copy_cons {u v w u' w'} (h : G.Adj u v) (p : G.Walk v w) (hu : u = u') (hw : w = w') :
    (Walk.cons h p).copy hu hw = Walk.cons (by rwa [← hu]) (p.copy rfl hw) := by
  subst_vars
  rfl
#align simple_graph.walk.copy_cons SimpleGraph.Walk.copy_cons

@[simp]
theorem cons_copy {u v w v' w'} (h : G.Adj u v) (p : G.Walk v' w') (hv : v' = v) (hw : w' = w) :
    Walk.cons h (p.copy hv hw) = (Walk.cons (by rwa [hv]) p).copy rfl hw := by
  subst_vars
  rfl
#align simple_graph.walk.cons_copy SimpleGraph.Walk.cons_copy

theorem exists_eq_cons_of_ne :
    ∀ {u v : V} (hne : u ≠ v) (p : G.Walk u v),
      ∃ (w : V)(h : G.Adj u w)(p' : G.Walk w v), p = cons h p'
  | _, _, hne, nil => (hne rfl).elim
  | _, _, _, cons h p' => ⟨_, h, p', rfl⟩
#align simple_graph.walk.exists_eq_cons_of_ne SimpleGraph.Walk.exists_eq_cons_of_ne

/-- The length of a walk is the number of edges/darts along it. -/
def length : ∀ {u v : V}, G.Walk u v → ℕ
  | _, _, nil => 0
  | _, _, cons _ q => q.length.succ
#align simple_graph.walk.length SimpleGraph.Walk.length

/-- The concatenation of two compatible walks. -/
@[trans]
def append : ∀ {u v w : V}, G.Walk u v → G.Walk v w → G.Walk u w
  | _, _, _, nil, q => q
  | _, _, _, cons h p, q => cons h (p.append q)
#align simple_graph.walk.append SimpleGraph.Walk.append

/-- The concatenation of the reverse of the first walk with the second walk. -/
protected def reverseAux : ∀ {u v w : V}, G.Walk u v → G.Walk u w → G.Walk v w
  | _, _, _, nil, q => q
  | _, _, _, cons h p, q => reverse_aux p (cons (G.symm h) q)
#align simple_graph.walk.reverse_aux SimpleGraph.Walk.reverseAux

/-- The walk in reverse. -/
@[symm]
def reverse {u v : V} (w : G.Walk u v) : G.Walk v u :=
  w.reverseAux nil
#align simple_graph.walk.reverse SimpleGraph.Walk.reverse

/-- Get the `n`th vertex from a walk, where `n` is generally expected to be
between `0` and `p.length`, inclusive.
If `n` is greater than or equal to `p.length`, the result is the path's endpoint. -/
def getVert : ∀ {u v : V} (p : G.Walk u v) (n : ℕ), V
  | u, v, nil, _ => u
  | u, v, cons _ _, 0 => u
  | u, v, cons _ q, n + 1 => q.getVert n
#align simple_graph.walk.get_vert SimpleGraph.Walk.getVert

@[simp]
theorem get_vert_zero {u v} (w : G.Walk u v) : w.getVert 0 = u := by cases w <;> rfl
#align simple_graph.walk.get_vert_zero SimpleGraph.Walk.get_vert_zero

theorem get_vert_of_length_le {u v} (w : G.Walk u v) {i : ℕ} (hi : w.length ≤ i) :
    w.getVert i = v := by 
  induction' w with _ x y z hxy wyz IH generalizing i
  · rfl
  · cases i
    · cases hi
    · exact IH (Nat.succ_le_succ_iff.1 hi)
#align simple_graph.walk.get_vert_of_length_le SimpleGraph.Walk.get_vert_of_length_le

@[simp]
theorem get_vert_length {u v} (w : G.Walk u v) : w.getVert w.length = v :=
  w.get_vert_of_length_le rfl.le
#align simple_graph.walk.get_vert_length SimpleGraph.Walk.get_vert_length

theorem adj_get_vert_succ {u v} (w : G.Walk u v) {i : ℕ} (hi : i < w.length) :
    G.Adj (w.getVert i) (w.getVert (i + 1)) := by
  induction' w with _ x y z hxy wyz IH generalizing i
  · cases hi
  · cases i
    · simp [get_vert, hxy]
    · exact IH (Nat.succ_lt_succ_iff.1 hi)
#align simple_graph.walk.adj_get_vert_succ SimpleGraph.Walk.adj_get_vert_succ

@[simp]
theorem cons_append {u v w x : V} (h : G.Adj u v) (p : G.Walk v w) (q : G.Walk w x) :
    (cons h p).append q = cons h (p.append q) :=
  rfl
#align simple_graph.walk.cons_append SimpleGraph.Walk.cons_append

@[simp]
theorem cons_nil_append {u v w : V} (h : G.Adj u v) (p : G.Walk v w) :
    (cons h nil).append p = cons h p :=
  rfl
#align simple_graph.walk.cons_nil_append SimpleGraph.Walk.cons_nil_append

@[simp]
theorem append_nil : ∀ {u v : V} (p : G.Walk u v), p.append nil = p
  | _, _, nil => rfl
  | _, _, cons h p => by rw [cons_append, append_nil]
#align simple_graph.walk.append_nil SimpleGraph.Walk.append_nil

@[simp]
theorem nil_append {u v : V} (p : G.Walk u v) : nil.append p = p :=
  rfl
#align simple_graph.walk.nil_append SimpleGraph.Walk.nil_append

theorem append_assoc :
    ∀ {u v w x : V} (p : G.Walk u v) (q : G.Walk v w) (r : G.Walk w x),
      p.append (q.append r) = (p.append q).append r
  | _, _, _, _, nil, _, _ => rfl
  | _, _, _, _, cons h p', q, r => by 
    dsimp only [append]
    rw [append_assoc]
#align simple_graph.walk.append_assoc SimpleGraph.Walk.append_assoc

@[simp]
theorem append_copy_copy {u v w u' v' w'} (p : G.Walk u v) (q : G.Walk v w) (hu : u = u')
    (hv : v = v') (hw : w = w') : (p.copy hu hv).append (q.copy hv hw) = (p.append q).copy hu hw :=
  by 
  subst_vars
  rfl
#align simple_graph.walk.append_copy_copy SimpleGraph.Walk.append_copy_copy

@[simp]
theorem reverse_nil {u : V} : (nil : G.Walk u u).reverse = nil :=
  rfl
#align simple_graph.walk.reverse_nil SimpleGraph.Walk.reverse_nil

theorem reverse_singleton {u v : V} (h : G.Adj u v) : (cons h nil).reverse = cons (G.symm h) nil :=
  rfl
#align simple_graph.walk.reverse_singleton SimpleGraph.Walk.reverse_singleton

@[simp]
theorem cons_reverse_aux {u v w x : V} (p : G.Walk u v) (q : G.Walk w x) (h : G.Adj w u) :
    (cons h p).reverseAux q = p.reverseAux (cons (G.symm h) q) :=
  rfl
#align simple_graph.walk.cons_reverse_aux SimpleGraph.Walk.cons_reverse_aux

@[simp]
protected theorem append_reverse_aux :
    ∀ {u v w x : V} (p : G.Walk u v) (q : G.Walk v w) (r : G.Walk u x),
      (p.append q).reverseAux r = q.reverseAux (p.reverseAux r)
  | _, _, _, _, nil, _, _ => rfl
  | _, _, _, _, cons h p', q, r => append_reverse_aux p' q (cons (G.symm h) r)
#align simple_graph.walk.append_reverse_aux SimpleGraph.Walk.append_reverse_aux

@[simp]
protected theorem reverse_aux_append :
    ∀ {u v w x : V} (p : G.Walk u v) (q : G.Walk u w) (r : G.Walk w x),
      (p.reverseAux q).append r = p.reverseAux (q.append r)
  | _, _, _, _, nil, _, _ => rfl
  | _, _, _, _, cons h p', q, r => by simp [reverse_aux_append p' (cons (G.symm h) q) r]
#align simple_graph.walk.reverse_aux_append SimpleGraph.Walk.reverse_aux_append

protected theorem reverse_aux_eq_reverse_append {u v w : V} (p : G.Walk u v) (q : G.Walk u w) :
    p.reverseAux q = p.reverse.append q := by simp [reverse]
#align
  simple_graph.walk.reverse_aux_eq_reverse_append SimpleGraph.Walk.reverse_aux_eq_reverse_append

@[simp]
theorem reverse_cons {u v w : V} (h : G.Adj u v) (p : G.Walk v w) :
    (cons h p).reverse = p.reverse.append (cons (G.symm h) nil) := by simp [reverse]
#align simple_graph.walk.reverse_cons SimpleGraph.Walk.reverse_cons

@[simp]
theorem reverse_copy {u v u' v'} (p : G.Walk u v) (hu : u = u') (hv : v = v') :
    (p.copy hu hv).reverse = p.reverse.copy hv hu := by
  subst_vars
  rfl
#align simple_graph.walk.reverse_copy SimpleGraph.Walk.reverse_copy

@[simp]
theorem reverse_append {u v w : V} (p : G.Walk u v) (q : G.Walk v w) :
    (p.append q).reverse = q.reverse.append p.reverse := by simp [reverse]
#align simple_graph.walk.reverse_append SimpleGraph.Walk.reverse_append

@[simp]
theorem reverse_reverse : ∀ {u v : V} (p : G.Walk u v), p.reverse.reverse = p
  | _, _, nil => rfl
  | _, _, cons h p => by simp [reverse_reverse]
#align simple_graph.walk.reverse_reverse SimpleGraph.Walk.reverse_reverse

@[simp]
theorem length_nil {u : V} : (nil : G.Walk u u).length = 0 :=
  rfl
#align simple_graph.walk.length_nil SimpleGraph.Walk.length_nil

@[simp]
theorem length_cons {u v w : V} (h : G.Adj u v) (p : G.Walk v w) :
    (cons h p).length = p.length + 1 :=
  rfl
#align simple_graph.walk.length_cons SimpleGraph.Walk.length_cons

@[simp]
theorem length_copy {u v u' v'} (p : G.Walk u v) (hu : u = u') (hv : v = v') :
    (p.copy hu hv).length = p.length := by 
  subst_vars
  rfl
#align simple_graph.walk.length_copy SimpleGraph.Walk.length_copy

@[simp]
theorem length_append :
    ∀ {u v w : V} (p : G.Walk u v) (q : G.Walk v w), (p.append q).length = p.length + q.length
  | _, _, _, nil, _ => by simp
  | _, _, _, cons _ _, _ => by simp [length_append, add_left_comm, add_comm]
#align simple_graph.walk.length_append SimpleGraph.Walk.length_append

@[simp]
protected theorem length_reverse_aux :
    ∀ {u v w : V} (p : G.Walk u v) (q : G.Walk u w), (p.reverseAux q).length = p.length + q.length
  | _, _, _, nil, _ => by simp!
  | _, _, _, cons _ _, _ => by simp [length_reverse_aux, Nat.add_succ, Nat.succ_add]
#align simple_graph.walk.length_reverse_aux SimpleGraph.Walk.length_reverse_aux

@[simp]
theorem length_reverse {u v : V} (p : G.Walk u v) : p.reverse.length = p.length := by simp [reverse]
#align simple_graph.walk.length_reverse SimpleGraph.Walk.length_reverse

theorem eq_of_length_eq_zero : ∀ {u v : V} {p : G.Walk u v}, p.length = 0 → u = v
  | _, _, nil, _ => rfl
#align simple_graph.walk.eq_of_length_eq_zero SimpleGraph.Walk.eq_of_length_eq_zero

@[simp]
theorem exists_length_eq_zero_iff {u v : V} : (∃ p : G.Walk u v, p.length = 0) ↔ u = v := by
  constructor
  · rintro ⟨p, hp⟩
    exact eq_of_length_eq_zero hp
  · rintro rfl
    exact ⟨nil, rfl⟩
#align simple_graph.walk.exists_length_eq_zero_iff SimpleGraph.Walk.exists_length_eq_zero_iff

@[simp]
theorem length_eq_zero_iff {u : V} {p : G.Walk u u} : p.length = 0 ↔ p = nil := by cases p <;> simp
#align simple_graph.walk.length_eq_zero_iff SimpleGraph.Walk.length_eq_zero_iff

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- The `support` of a walk is the list of vertices it visits in order. -/
def support : ∀ {u v : V}, G.Walk u v → List V
  | u, v, nil => [u]
  | u, v, cons h p => u::p.support
#align simple_graph.walk.support SimpleGraph.Walk.support

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- The `darts` of a walk is the list of darts it visits in order. -/
def darts : ∀ {u v : V}, G.Walk u v → List G.Dart
  | u, v, nil => []
  | u, v, cons h p => ⟨(u, _), h⟩::p.darts
#align simple_graph.walk.darts SimpleGraph.Walk.darts

/-- The `edges` of a walk is the list of edges it visits in order.
This is defined to be the list of edges underlying `simple_graph.walk.darts`. -/
def edges {u v : V} (p : G.Walk u v) : List (Sym2 V) :=
  p.darts.map Dart.edge
#align simple_graph.walk.edges SimpleGraph.Walk.edges

@[simp]
theorem support_nil {u : V} : (nil : G.Walk u u).support = [u] :=
  rfl
#align simple_graph.walk.support_nil SimpleGraph.Walk.support_nil

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simp]
theorem support_cons {u v w : V} (h : G.Adj u v) (p : G.Walk v w) :
    (cons h p).support = u::p.support :=
  rfl
#align simple_graph.walk.support_cons SimpleGraph.Walk.support_cons

@[simp]
theorem support_copy {u v u' v'} (p : G.Walk u v) (hu : u = u') (hv : v = v') :
    (p.copy hu hv).support = p.support := by 
  subst_vars
  rfl
#align simple_graph.walk.support_copy SimpleGraph.Walk.support_copy

theorem support_append {u v w : V} (p : G.Walk u v) (p' : G.Walk v w) :
    (p.append p').support = p.support ++ p'.support.tail := by induction p <;> cases p' <;> simp [*]
#align simple_graph.walk.support_append SimpleGraph.Walk.support_append

@[simp]
theorem support_reverse {u v : V} (p : G.Walk u v) : p.reverse.support = p.support.reverse := by
  induction p <;> simp [support_append, *]
#align simple_graph.walk.support_reverse SimpleGraph.Walk.support_reverse

theorem support_ne_nil {u v : V} (p : G.Walk u v) : p.support ≠ [] := by cases p <;> simp
#align simple_graph.walk.support_ne_nil SimpleGraph.Walk.support_ne_nil

theorem tail_support_append {u v w : V} (p : G.Walk u v) (p' : G.Walk v w) :
    (p.append p').support.tail = p.support.tail ++ p'.support.tail := by
  rw [support_append, List.tail_append_of_ne_nil _ _ (support_ne_nil _)]
#align simple_graph.walk.tail_support_append SimpleGraph.Walk.tail_support_append

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem support_eq_cons {u v : V} (p : G.Walk u v) : p.support = u::p.support.tail := by
  cases p <;> simp
#align simple_graph.walk.support_eq_cons SimpleGraph.Walk.support_eq_cons

@[simp]
theorem start_mem_support {u v : V} (p : G.Walk u v) : u ∈ p.support := by cases p <;> simp
#align simple_graph.walk.start_mem_support SimpleGraph.Walk.start_mem_support

@[simp]
theorem end_mem_support {u v : V} (p : G.Walk u v) : v ∈ p.support := by induction p <;> simp [*]
#align simple_graph.walk.end_mem_support SimpleGraph.Walk.end_mem_support

theorem mem_support_iff {u v w : V} (p : G.Walk u v) : w ∈ p.support ↔ w = u ∨ w ∈ p.support.tail :=
  by cases p <;> simp
#align simple_graph.walk.mem_support_iff SimpleGraph.Walk.mem_support_iff

theorem mem_support_nil_iff {u v : V} : u ∈ (nil : G.Walk v v).support ↔ u = v := by simp
#align simple_graph.walk.mem_support_nil_iff SimpleGraph.Walk.mem_support_nil_iff

@[simp]
theorem mem_tail_support_append_iff {t u v w : V} (p : G.Walk u v) (p' : G.Walk v w) :
    t ∈ (p.append p').support.tail ↔ t ∈ p.support.tail ∨ t ∈ p'.support.tail := by
  rw [tail_support_append, List.mem_append]
#align simple_graph.walk.mem_tail_support_append_iff SimpleGraph.Walk.mem_tail_support_append_iff

@[simp]
theorem end_mem_tail_support_of_ne {u v : V} (h : u ≠ v) (p : G.Walk u v) : v ∈ p.support.tail := by
  obtain ⟨_, _, _, rfl⟩ := exists_eq_cons_of_ne h p
  simp
#align simple_graph.walk.end_mem_tail_support_of_ne SimpleGraph.Walk.end_mem_tail_support_of_ne

@[simp]
theorem mem_support_append_iff {t u v w : V} (p : G.Walk u v) (p' : G.Walk v w) :
    t ∈ (p.append p').support ↔ t ∈ p.support ∨ t ∈ p'.support := by
  simp only [mem_support_iff, mem_tail_support_append_iff]
  by_cases h : t = v <;> by_cases h' : t = u <;> subst_vars <;> try have := Ne.symm h' <;> simp [*]
#align simple_graph.walk.mem_support_append_iff SimpleGraph.Walk.mem_support_append_iff

@[simp]
theorem subset_support_append_left {V : Type u} {G : SimpleGraph V} {u v w : V} (p : G.Walk u v)
    (q : G.Walk v w) : p.support ⊆ (p.append q).support := by
  simp only [walk.support_append, List.subset_append_left]
#align simple_graph.walk.subset_support_append_left SimpleGraph.Walk.subset_support_append_left

@[simp]
theorem subset_support_append_right {V : Type u} {G : SimpleGraph V} {u v w : V} (p : G.Walk u v)
    (q : G.Walk v w) : q.support ⊆ (p.append q).support := by
  intro h
  simp (config := { contextual := true }) only [mem_support_append_iff, or_true_iff, imp_true_iff]
#align simple_graph.walk.subset_support_append_right SimpleGraph.Walk.subset_support_append_right

theorem coe_support {u v : V} (p : G.Walk u v) : (p.support : Multiset V) = {u} + p.support.tail :=
  by cases p <;> rfl
#align simple_graph.walk.coe_support SimpleGraph.Walk.coe_support

theorem coe_support_append {u v w : V} (p : G.Walk u v) (p' : G.Walk v w) :
    ((p.append p').support : Multiset V) = {u} + p.support.tail + p'.support.tail := by
  rw [support_append, ← Multiset.coe_add, coe_support]
#align simple_graph.walk.coe_support_append SimpleGraph.Walk.coe_support_append

theorem coe_support_append' [DecidableEq V] {u v w : V} (p : G.Walk u v) (p' : G.Walk v w) :
    ((p.append p').support : Multiset V) = p.support + p'.support - {v} := by
  rw [support_append, ← Multiset.coe_add]
  simp only [coe_support]
  rw [add_comm {v}]
  simp only [← add_assoc, add_tsub_cancel_right]
#align simple_graph.walk.coe_support_append' SimpleGraph.Walk.coe_support_append'

theorem chain_adj_support :
    ∀ {u v w : V} (h : G.Adj u v) (p : G.Walk v w), List.Chain G.Adj u p.support
  | _, _, _, h, nil => List.Chain.cons h List.Chain.nil
  | _, _, _, h, cons h' p => List.Chain.cons h (chain_adj_support h' p)
#align simple_graph.walk.chain_adj_support SimpleGraph.Walk.chain_adj_support

theorem chain'_adj_support : ∀ {u v : V} (p : G.Walk u v), List.Chain' G.Adj p.support
  | _, _, nil => List.Chain.nil
  | _, _, cons h p => chain_adj_support h p
#align simple_graph.walk.chain'_adj_support SimpleGraph.Walk.chain'_adj_support

theorem chain_dart_adj_darts :
    ∀ {d : G.Dart} {v w : V} (h : d.snd = v) (p : G.Walk v w), List.Chain G.DartAdj d p.darts
  | _, _, _, h, nil => List.Chain.nil
  | _, _, _, h, cons h' p => List.Chain.cons h (chain_dart_adj_darts rfl p)
#align simple_graph.walk.chain_dart_adj_darts SimpleGraph.Walk.chain_dart_adj_darts

theorem chain'_dart_adj_darts : ∀ {u v : V} (p : G.Walk u v), List.Chain' G.DartAdj p.darts
  | _, _, nil => trivial
  | _, _, cons h p => chain_dart_adj_darts rfl p
#align simple_graph.walk.chain'_dart_adj_darts SimpleGraph.Walk.chain'_dart_adj_darts

/-- Every edge in a walk's edge list is an edge of the graph.
It is written in this form (rather than using `⊆`) to avoid unsightly coercions. -/
theorem edges_subset_edge_set :
    ∀ {u v : V} (p : G.Walk u v) ⦃e : Sym2 V⦄ (h : e ∈ p.edges), e ∈ G.edgeSet
  | _, _, cons h' p', e, h => by rcases h with ⟨rfl, h⟩ <;> solve_by_elim
#align simple_graph.walk.edges_subset_edge_set SimpleGraph.Walk.edges_subset_edge_set

theorem adj_of_mem_edges {u v x y : V} (p : G.Walk u v) (h : ⟦(x, y)⟧ ∈ p.edges) : G.Adj x y :=
  edges_subset_edge_set p h
#align simple_graph.walk.adj_of_mem_edges SimpleGraph.Walk.adj_of_mem_edges

@[simp]
theorem darts_nil {u : V} : (nil : G.Walk u u).darts = [] :=
  rfl
#align simple_graph.walk.darts_nil SimpleGraph.Walk.darts_nil

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simp]
theorem darts_cons {u v w : V} (h : G.Adj u v) (p : G.Walk v w) :
    (cons h p).darts = ⟨(u, v), h⟩::p.darts :=
  rfl
#align simple_graph.walk.darts_cons SimpleGraph.Walk.darts_cons

@[simp]
theorem darts_copy {u v u' v'} (p : G.Walk u v) (hu : u = u') (hv : v = v') :
    (p.copy hu hv).darts = p.darts := by 
  subst_vars
  rfl
#align simple_graph.walk.darts_copy SimpleGraph.Walk.darts_copy

@[simp]
theorem darts_append {u v w : V} (p : G.Walk u v) (p' : G.Walk v w) :
    (p.append p').darts = p.darts ++ p'.darts := by induction p <;> simp [*]
#align simple_graph.walk.darts_append SimpleGraph.Walk.darts_append

@[simp]
theorem darts_reverse {u v : V} (p : G.Walk u v) :
    p.reverse.darts = (p.darts.map Dart.symm).reverse := by induction p <;> simp [*, Sym2.eq_swap]
#align simple_graph.walk.darts_reverse SimpleGraph.Walk.darts_reverse

theorem mem_darts_reverse {u v : V} {d : G.Dart} {p : G.Walk u v} :
    d ∈ p.reverse.darts ↔ d.symm ∈ p.darts := by simp
#align simple_graph.walk.mem_darts_reverse SimpleGraph.Walk.mem_darts_reverse

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem cons_map_snd_darts {u v : V} (p : G.Walk u v) : (u::p.darts.map Dart.snd) = p.support := by
  induction p <;> simp! [*]
#align simple_graph.walk.cons_map_snd_darts SimpleGraph.Walk.cons_map_snd_darts

theorem map_snd_darts {u v : V} (p : G.Walk u v) : p.darts.map Dart.snd = p.support.tail := by
  simpa using congr_arg List.tail (cons_map_snd_darts p)
#align simple_graph.walk.map_snd_darts SimpleGraph.Walk.map_snd_darts

theorem map_fst_darts_append {u v : V} (p : G.Walk u v) : p.darts.map Dart.fst ++ [v] = p.support :=
  by induction p <;> simp! [*]
#align simple_graph.walk.map_fst_darts_append SimpleGraph.Walk.map_fst_darts_append

theorem map_fst_darts {u v : V} (p : G.Walk u v) : p.darts.map Dart.fst = p.support.init := by
  simpa! using congr_arg List.init (map_fst_darts_append p)
#align simple_graph.walk.map_fst_darts SimpleGraph.Walk.map_fst_darts

@[simp]
theorem edges_nil {u : V} : (nil : G.Walk u u).edges = [] :=
  rfl
#align simple_graph.walk.edges_nil SimpleGraph.Walk.edges_nil

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simp]
theorem edges_cons {u v w : V} (h : G.Adj u v) (p : G.Walk v w) :
    (cons h p).edges = ⟦(u, v)⟧::p.edges :=
  rfl
#align simple_graph.walk.edges_cons SimpleGraph.Walk.edges_cons

@[simp]
theorem edges_copy {u v u' v'} (p : G.Walk u v) (hu : u = u') (hv : v = v') :
    (p.copy hu hv).edges = p.edges := by 
  subst_vars
  rfl
#align simple_graph.walk.edges_copy SimpleGraph.Walk.edges_copy

@[simp]
theorem edges_append {u v w : V} (p : G.Walk u v) (p' : G.Walk v w) :
    (p.append p').edges = p.edges ++ p'.edges := by simp [edges]
#align simple_graph.walk.edges_append SimpleGraph.Walk.edges_append

@[simp]
theorem edges_reverse {u v : V} (p : G.Walk u v) : p.reverse.edges = p.edges.reverse := by
  simp [edges]
#align simple_graph.walk.edges_reverse SimpleGraph.Walk.edges_reverse

@[simp]
theorem length_support {u v : V} (p : G.Walk u v) : p.support.length = p.length + 1 := by
  induction p <;> simp [*]
#align simple_graph.walk.length_support SimpleGraph.Walk.length_support

@[simp]
theorem length_darts {u v : V} (p : G.Walk u v) : p.darts.length = p.length := by
  induction p <;> simp [*]
#align simple_graph.walk.length_darts SimpleGraph.Walk.length_darts

@[simp]
theorem length_edges {u v : V} (p : G.Walk u v) : p.edges.length = p.length := by simp [edges]
#align simple_graph.walk.length_edges SimpleGraph.Walk.length_edges

theorem dart_fst_mem_support_of_mem_darts :
    ∀ {u v : V} (p : G.Walk u v) {d : G.Dart}, d ∈ p.darts → d.fst ∈ p.support
  | u, v, cons h p', d, hd => by
    simp only [support_cons, darts_cons, List.mem_cons_iff] at hd⊢
    rcases hd with (rfl | hd)
    · exact Or.inl rfl
    · exact Or.inr (dart_fst_mem_support_of_mem_darts _ hd)
#align
  simple_graph.walk.dart_fst_mem_support_of_mem_darts SimpleGraph.Walk.dart_fst_mem_support_of_mem_darts

theorem dart_snd_mem_support_of_mem_darts {u v : V} (p : G.Walk u v) {d : G.Dart}
    (h : d ∈ p.darts) : d.snd ∈ p.support := by
  simpa using p.reverse.dart_fst_mem_support_of_mem_darts (by simp [h] : d.symm ∈ p.reverse.darts)
#align
  simple_graph.walk.dart_snd_mem_support_of_mem_darts SimpleGraph.Walk.dart_snd_mem_support_of_mem_darts

theorem fst_mem_support_of_mem_edges {t u v w : V} (p : G.Walk v w) (he : ⟦(t, u)⟧ ∈ p.edges) :
    t ∈ p.support := by 
  obtain ⟨d, hd, he⟩ := list.mem_map.mp he
  rw [dart_edge_eq_mk_iff'] at he
  rcases he with (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
  · exact dart_fst_mem_support_of_mem_darts _ hd
  · exact dart_snd_mem_support_of_mem_darts _ hd
#align simple_graph.walk.fst_mem_support_of_mem_edges SimpleGraph.Walk.fst_mem_support_of_mem_edges

theorem snd_mem_support_of_mem_edges {t u v w : V} (p : G.Walk v w) (he : ⟦(t, u)⟧ ∈ p.edges) :
    u ∈ p.support := by 
  rw [Sym2.eq_swap] at he
  exact p.fst_mem_support_of_mem_edges he
#align simple_graph.walk.snd_mem_support_of_mem_edges SimpleGraph.Walk.snd_mem_support_of_mem_edges

theorem darts_nodup_of_support_nodup {u v : V} {p : G.Walk u v} (h : p.support.Nodup) :
    p.darts.Nodup := by 
  induction p
  · simp
  · simp only [darts_cons, support_cons, List.nodup_cons] at h⊢
    refine' ⟨fun h' => h.1 (dart_fst_mem_support_of_mem_darts p_p h'), p_ih h.2⟩
#align simple_graph.walk.darts_nodup_of_support_nodup SimpleGraph.Walk.darts_nodup_of_support_nodup

theorem edges_nodup_of_support_nodup {u v : V} {p : G.Walk u v} (h : p.support.Nodup) :
    p.edges.Nodup := by 
  induction p
  · simp
  · simp only [edges_cons, support_cons, List.nodup_cons] at h⊢
    exact ⟨fun h' => h.1 (fst_mem_support_of_mem_edges p_p h'), p_ih h.2⟩
#align simple_graph.walk.edges_nodup_of_support_nodup SimpleGraph.Walk.edges_nodup_of_support_nodup

/-! ### Trails, paths, circuits, cycles -/


/-- A *trail* is a walk with no repeating edges. -/
structure IsTrail {u v : V} (p : G.Walk u v) : Prop where
  edges_nodup : p.edges.Nodup
#align simple_graph.walk.is_trail SimpleGraph.Walk.IsTrail

/- ./././Mathport/Syntax/Translate/Command.lean:407:11: unsupported: advanced extends in structure -/
/-- A *path* is a walk with no repeating vertices.
Use `simple_graph.walk.is_path.mk'` for a simpler constructor. -/
structure IsPath {u v : V} (p : G.Walk u v) extends
  "./././Mathport/Syntax/Translate/Command.lean:407:11: unsupported: advanced extends in structure" :
  Prop where
  support_nodup : p.support.Nodup
#align simple_graph.walk.is_path SimpleGraph.Walk.IsPath

/- ./././Mathport/Syntax/Translate/Command.lean:407:11: unsupported: advanced extends in structure -/
/-- A *circuit* at `u : V` is a nonempty trail beginning and ending at `u`. -/
structure IsCircuit {u : V} (p : G.Walk u u) extends
  "./././Mathport/Syntax/Translate/Command.lean:407:11: unsupported: advanced extends in structure" :
  Prop where
  ne_nil : p ≠ nil
#align simple_graph.walk.is_circuit SimpleGraph.Walk.IsCircuit

/- ./././Mathport/Syntax/Translate/Command.lean:407:11: unsupported: advanced extends in structure -/
/-- A *cycle* at `u : V` is a circuit at `u` whose only repeating vertex
is `u` (which appears exactly twice). -/
structure IsCycle {u : V} (p : G.Walk u u) extends
  "./././Mathport/Syntax/Translate/Command.lean:407:11: unsupported: advanced extends in structure" :
  Prop where
  support_nodup : p.support.tail.Nodup
#align simple_graph.walk.is_cycle SimpleGraph.Walk.IsCycle

theorem is_trail_def {u v : V} (p : G.Walk u v) : p.IsTrail ↔ p.edges.Nodup :=
  ⟨IsTrail.edges_nodup, fun h => ⟨h⟩⟩
#align simple_graph.walk.is_trail_def SimpleGraph.Walk.is_trail_def

@[simp]
theorem is_trail_copy {u v u' v'} (p : G.Walk u v) (hu : u = u') (hv : v = v') :
    (p.copy hu hv).IsTrail ↔ p.IsTrail := by 
  subst_vars
  rfl
#align simple_graph.walk.is_trail_copy SimpleGraph.Walk.is_trail_copy

theorem IsPath.mk' {u v : V} {p : G.Walk u v} (h : p.support.Nodup) : IsPath p :=
  ⟨⟨edges_nodup_of_support_nodup h⟩, h⟩
#align simple_graph.walk.is_path.mk' SimpleGraph.Walk.IsPath.mk'

theorem is_path_def {u v : V} (p : G.Walk u v) : p.IsPath ↔ p.support.Nodup :=
  ⟨IsPath.support_nodup, IsPath.mk'⟩
#align simple_graph.walk.is_path_def SimpleGraph.Walk.is_path_def

@[simp]
theorem is_path_copy {u v u' v'} (p : G.Walk u v) (hu : u = u') (hv : v = v') :
    (p.copy hu hv).IsPath ↔ p.IsPath := by 
  subst_vars
  rfl
#align simple_graph.walk.is_path_copy SimpleGraph.Walk.is_path_copy

theorem is_circuit_def {u : V} (p : G.Walk u u) : p.IsCircuit ↔ IsTrail p ∧ p ≠ nil :=
  Iff.intro (fun h => ⟨h.1, h.2⟩) fun h => ⟨h.1, h.2⟩
#align simple_graph.walk.is_circuit_def SimpleGraph.Walk.is_circuit_def

@[simp]
theorem is_circuit_copy {u u'} (p : G.Walk u u) (hu : u = u') :
    (p.copy hu hu).IsCircuit ↔ p.IsCircuit := by
  subst_vars
  rfl
#align simple_graph.walk.is_circuit_copy SimpleGraph.Walk.is_circuit_copy

theorem is_cycle_def {u : V} (p : G.Walk u u) :
    p.IsCycle ↔ IsTrail p ∧ p ≠ nil ∧ p.support.tail.Nodup :=
  Iff.intro (fun h => ⟨h.1.1, h.1.2, h.2⟩) fun h => ⟨⟨h.1, h.2.1⟩, h.2.2⟩
#align simple_graph.walk.is_cycle_def SimpleGraph.Walk.is_cycle_def

@[simp]
theorem is_cycle_copy {u u'} (p : G.Walk u u) (hu : u = u') : (p.copy hu hu).IsCycle ↔ p.IsCycle :=
  by 
  subst_vars
  rfl
#align simple_graph.walk.is_cycle_copy SimpleGraph.Walk.is_cycle_copy

@[simp]
theorem IsTrail.nil {u : V} : (nil : G.Walk u u).IsTrail :=
  ⟨by simp [edges]⟩
#align simple_graph.walk.is_trail.nil SimpleGraph.Walk.IsTrail.nil

theorem IsTrail.of_cons {u v w : V} {h : G.Adj u v} {p : G.Walk v w} :
    (cons h p).IsTrail → p.IsTrail := by simp [is_trail_def]
#align simple_graph.walk.is_trail.of_cons SimpleGraph.Walk.IsTrail.of_cons

@[simp]
theorem cons_is_trail_iff {u v w : V} (h : G.Adj u v) (p : G.Walk v w) :
    (cons h p).IsTrail ↔ p.IsTrail ∧ ⟦(u, v)⟧ ∉ p.edges := by simp [is_trail_def, and_comm']
#align simple_graph.walk.cons_is_trail_iff SimpleGraph.Walk.cons_is_trail_iff

theorem IsTrail.reverse {u v : V} (p : G.Walk u v) (h : p.IsTrail) : p.reverse.IsTrail := by
  simpa [is_trail_def] using h
#align simple_graph.walk.is_trail.reverse SimpleGraph.Walk.IsTrail.reverse

@[simp]
theorem reverse_is_trail_iff {u v : V} (p : G.Walk u v) : p.reverse.IsTrail ↔ p.IsTrail := by
  constructor <;>
    · intro h
      convert h.reverse _
      try rw [reverse_reverse]
#align simple_graph.walk.reverse_is_trail_iff SimpleGraph.Walk.reverse_is_trail_iff

theorem IsTrail.of_append_left {u v w : V} {p : G.Walk u v} {q : G.Walk v w}
    (h : (p.append q).IsTrail) : p.IsTrail := by
  rw [is_trail_def, edges_append, List.nodup_append] at h
  exact ⟨h.1⟩
#align simple_graph.walk.is_trail.of_append_left SimpleGraph.Walk.IsTrail.of_append_left

theorem IsTrail.of_append_right {u v w : V} {p : G.Walk u v} {q : G.Walk v w}
    (h : (p.append q).IsTrail) : q.IsTrail := by
  rw [is_trail_def, edges_append, List.nodup_append] at h
  exact ⟨h.2.1⟩
#align simple_graph.walk.is_trail.of_append_right SimpleGraph.Walk.IsTrail.of_append_right

theorem IsTrail.count_edges_le_one [DecidableEq V] {u v : V} {p : G.Walk u v} (h : p.IsTrail)
    (e : Sym2 V) : p.edges.count e ≤ 1 :=
  List.nodup_iff_count_le_one.mp h.edges_nodup e
#align simple_graph.walk.is_trail.count_edges_le_one SimpleGraph.Walk.IsTrail.count_edges_le_one

theorem IsTrail.count_edges_eq_one [DecidableEq V] {u v : V} {p : G.Walk u v} (h : p.IsTrail)
    {e : Sym2 V} (he : e ∈ p.edges) : p.edges.count e = 1 :=
  List.count_eq_one_of_mem h.edges_nodup he
#align simple_graph.walk.is_trail.count_edges_eq_one SimpleGraph.Walk.IsTrail.count_edges_eq_one

theorem IsPath.nil {u : V} : (nil : G.Walk u u).IsPath := by fconstructor <;> simp
#align simple_graph.walk.is_path.nil SimpleGraph.Walk.IsPath.nil

theorem IsPath.of_cons {u v w : V} {h : G.Adj u v} {p : G.Walk v w} :
    (cons h p).IsPath → p.IsPath := by simp [is_path_def]
#align simple_graph.walk.is_path.of_cons SimpleGraph.Walk.IsPath.of_cons

@[simp]
theorem cons_is_path_iff {u v w : V} (h : G.Adj u v) (p : G.Walk v w) :
    (cons h p).IsPath ↔ p.IsPath ∧ u ∉ p.support := by
  constructor <;> simp (config := { contextual := true }) [is_path_def]
#align simple_graph.walk.cons_is_path_iff SimpleGraph.Walk.cons_is_path_iff

@[simp]
theorem is_path_iff_eq_nil {u : V} (p : G.Walk u u) : p.IsPath ↔ p = nil := by
  cases p <;> simp [is_path.nil]
#align simple_graph.walk.is_path_iff_eq_nil SimpleGraph.Walk.is_path_iff_eq_nil

theorem IsPath.reverse {u v : V} {p : G.Walk u v} (h : p.IsPath) : p.reverse.IsPath := by
  simpa [is_path_def] using h
#align simple_graph.walk.is_path.reverse SimpleGraph.Walk.IsPath.reverse

@[simp]
theorem is_path_reverse_iff {u v : V} (p : G.Walk u v) : p.reverse.IsPath ↔ p.IsPath := by
  constructor <;> intro h <;> convert h.reverse <;> simp
#align simple_graph.walk.is_path_reverse_iff SimpleGraph.Walk.is_path_reverse_iff

theorem IsPath.of_append_left {u v w : V} {p : G.Walk u v} {q : G.Walk v w} :
    (p.append q).IsPath → p.IsPath := by
  simp only [is_path_def, support_append]
  exact List.Nodup.of_append_left
#align simple_graph.walk.is_path.of_append_left SimpleGraph.Walk.IsPath.of_append_left

theorem IsPath.of_append_right {u v w : V} {p : G.Walk u v} {q : G.Walk v w}
    (h : (p.append q).IsPath) : q.IsPath := by
  rw [← is_path_reverse_iff] at h⊢
  rw [reverse_append] at h
  apply h.of_append_left
#align simple_graph.walk.is_path.of_append_right SimpleGraph.Walk.IsPath.of_append_right

@[simp]
theorem IsCycle.not_of_nil {u : V} : ¬(nil : G.Walk u u).IsCycle := fun h => h.ne_nil rfl
#align simple_graph.walk.is_cycle.not_of_nil SimpleGraph.Walk.IsCycle.not_of_nil

theorem cons_is_cycle_iff {u v : V} (p : G.Walk v u) (h : G.Adj u v) :
    (Walk.cons h p).IsCycle ↔ p.IsPath ∧ ¬⟦(u, v)⟧ ∈ p.edges := by
  simp only [walk.is_cycle_def, walk.is_path_def, walk.is_trail_def, edges_cons, List.nodup_cons,
    support_cons, List.tail_cons]
  have : p.support.nodup → p.edges.nodup := edges_nodup_of_support_nodup
  tauto
#align simple_graph.walk.cons_is_cycle_iff SimpleGraph.Walk.cons_is_cycle_iff

/-! ### About paths -/


instance [DecidableEq V] {u v : V} (p : G.Walk u v) : Decidable p.IsPath := by
  rw [is_path_def]
  infer_instance

theorem IsPath.length_lt [Fintype V] {u v : V} {p : G.Walk u v} (hp : p.IsPath) :
    p.length < Fintype.card V := by
  rw [Nat.lt_iff_add_one_le, ← length_support]
  exact hp.support_nodup.length_le_card
#align simple_graph.walk.is_path.length_lt SimpleGraph.Walk.IsPath.length_lt

/-! ### Walk decompositions -/


section WalkDecomp

variable [DecidableEq V]

/-- Given a vertex in the support of a path, give the path up until (and including) that vertex. -/
def takeUntil : ∀ {v w : V} (p : G.Walk v w) (u : V) (h : u ∈ p.support), G.Walk v u
  | v, w, nil, u, h => by rw [mem_support_nil_iff.mp h]
  | v, w, cons r p, u, h =>
    if hx : v = u then by subst u
    else cons r (take_until p _ <| h.casesOn (fun h' => (hx h'.symm).elim) id)
#align simple_graph.walk.take_until SimpleGraph.Walk.takeUntil

/-- Given a vertex in the support of a path, give the path from (and including) that vertex to
the end. In other words, drop vertices from the front of a path until (and not including)
that vertex. -/
def dropUntil : ∀ {v w : V} (p : G.Walk v w) (u : V) (h : u ∈ p.support), G.Walk u w
  | v, w, nil, u, h => by rw [mem_support_nil_iff.mp h]
  | v, w, cons r p, u, h =>
    if hx : v = u then by 
      subst u
      exact cons r p
    else drop_until p _ <| h.casesOn (fun h' => (hx h'.symm).elim) id
#align simple_graph.walk.drop_until SimpleGraph.Walk.dropUntil

/-- The `take_until` and `drop_until` functions split a walk into two pieces.
The lemma `count_support_take_until_eq_one` specifies where this split occurs. -/
@[simp]
theorem take_spec {u v w : V} (p : G.Walk v w) (h : u ∈ p.support) :
    (p.takeUntil u h).append (p.dropUntil u h) = p := by
  induction p
  · rw [mem_support_nil_iff] at h
    subst u
    rfl
  · obtain rfl | h := h
    · simp!
    · simp! only
      split_ifs with h' <;> subst_vars <;> simp [*]
#align simple_graph.walk.take_spec SimpleGraph.Walk.take_spec

theorem mem_support_iff_exists_append {V : Type u} {G : SimpleGraph V} {u v w : V}
    {p : G.Walk u v} : w ∈ p.support ↔ ∃ (q : G.Walk u w)(r : G.Walk w v), p = q.append r := by
  classical 
    constructor
    · exact fun h => ⟨_, _, (p.take_spec h).symm⟩
    · rintro ⟨q, r, rfl⟩
      simp only [mem_support_append_iff, end_mem_support, start_mem_support, or_self_iff]
#align
  simple_graph.walk.mem_support_iff_exists_append SimpleGraph.Walk.mem_support_iff_exists_append

@[simp]
theorem count_support_take_until_eq_one {u v w : V} (p : G.Walk v w) (h : u ∈ p.support) :
    (p.takeUntil u h).support.count u = 1 := by
  induction p
  · rw [mem_support_nil_iff] at h
    subst u
    simp!
  · obtain rfl | h := h
    · simp!
    · simp! only
      split_ifs with h' <;> rw [eq_comm] at h' <;> subst_vars <;> simp! [*, List.count_cons]
#align
  simple_graph.walk.count_support_take_until_eq_one SimpleGraph.Walk.count_support_take_until_eq_one

theorem count_edges_take_until_le_one {u v w : V} (p : G.Walk v w) (h : u ∈ p.support) (x : V) :
    (p.takeUntil u h).edges.count ⟦(u, x)⟧ ≤ 1 := by
  induction' p with u' u' v' w' ha p' ih
  · rw [mem_support_nil_iff] at h
    subst u
    simp!
  · obtain rfl | h := h
    · simp!
    · simp! only
      split_ifs with h'
      · subst h'
        simp
      · rw [edges_cons, List.count_cons]
        split_ifs with h''
        · rw [Sym2.eq_iff] at h''
          obtain ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ := h''
          · exact (h' rfl).elim
          · cases p' <;> simp!
        · apply ih
#align
  simple_graph.walk.count_edges_take_until_le_one SimpleGraph.Walk.count_edges_take_until_le_one

@[simp]
theorem take_until_copy {u v w v' w'} (p : G.Walk v w) (hv : v = v') (hw : w = w')
    (h : u ∈ (p.copy hv hw).support) :
    (p.copy hv hw).takeUntil u h =
      (p.takeUntil u
            (by 
              subst_vars
              exact h)).copy
        hv rfl :=
  by 
  subst_vars
  rfl
#align simple_graph.walk.take_until_copy SimpleGraph.Walk.take_until_copy

@[simp]
theorem drop_until_copy {u v w v' w'} (p : G.Walk v w) (hv : v = v') (hw : w = w')
    (h : u ∈ (p.copy hv hw).support) :
    (p.copy hv hw).dropUntil u h =
      (p.dropUntil u
            (by 
              subst_vars
              exact h)).copy
        rfl hw :=
  by 
  subst_vars
  rfl
#align simple_graph.walk.drop_until_copy SimpleGraph.Walk.drop_until_copy

theorem support_take_until_subset {u v w : V} (p : G.Walk v w) (h : u ∈ p.support) :
    (p.takeUntil u h).support ⊆ p.support := fun x hx => by
  rw [← take_spec p h, mem_support_append_iff]
  exact Or.inl hx
#align simple_graph.walk.support_take_until_subset SimpleGraph.Walk.support_take_until_subset

theorem support_drop_until_subset {u v w : V} (p : G.Walk v w) (h : u ∈ p.support) :
    (p.dropUntil u h).support ⊆ p.support := fun x hx => by
  rw [← take_spec p h, mem_support_append_iff]
  exact Or.inr hx
#align simple_graph.walk.support_drop_until_subset SimpleGraph.Walk.support_drop_until_subset

theorem darts_take_until_subset {u v w : V} (p : G.Walk v w) (h : u ∈ p.support) :
    (p.takeUntil u h).darts ⊆ p.darts := fun x hx => by
  rw [← take_spec p h, darts_append, List.mem_append]
  exact Or.inl hx
#align simple_graph.walk.darts_take_until_subset SimpleGraph.Walk.darts_take_until_subset

theorem darts_drop_until_subset {u v w : V} (p : G.Walk v w) (h : u ∈ p.support) :
    (p.dropUntil u h).darts ⊆ p.darts := fun x hx => by
  rw [← take_spec p h, darts_append, List.mem_append]
  exact Or.inr hx
#align simple_graph.walk.darts_drop_until_subset SimpleGraph.Walk.darts_drop_until_subset

theorem edges_take_until_subset {u v w : V} (p : G.Walk v w) (h : u ∈ p.support) :
    (p.takeUntil u h).edges ⊆ p.edges :=
  List.map_subset _ (p.darts_take_until_subset h)
#align simple_graph.walk.edges_take_until_subset SimpleGraph.Walk.edges_take_until_subset

theorem edges_drop_until_subset {u v w : V} (p : G.Walk v w) (h : u ∈ p.support) :
    (p.dropUntil u h).edges ⊆ p.edges :=
  List.map_subset _ (p.darts_drop_until_subset h)
#align simple_graph.walk.edges_drop_until_subset SimpleGraph.Walk.edges_drop_until_subset

theorem length_take_until_le {u v w : V} (p : G.Walk v w) (h : u ∈ p.support) :
    (p.takeUntil u h).length ≤ p.length := by
  have := congr_arg walk.length (p.take_spec h)
  rw [length_append] at this
  exact Nat.le.intro this
#align simple_graph.walk.length_take_until_le SimpleGraph.Walk.length_take_until_le

theorem length_drop_until_le {u v w : V} (p : G.Walk v w) (h : u ∈ p.support) :
    (p.dropUntil u h).length ≤ p.length := by
  have := congr_arg walk.length (p.take_spec h)
  rw [length_append, add_comm] at this
  exact Nat.le.intro this
#align simple_graph.walk.length_drop_until_le SimpleGraph.Walk.length_drop_until_le

protected theorem IsTrail.take_until {u v w : V} {p : G.Walk v w} (hc : p.IsTrail)
    (h : u ∈ p.support) : (p.takeUntil u h).IsTrail :=
  IsTrail.of_append_left (by rwa [← take_spec _ h] at hc)
#align simple_graph.walk.is_trail.take_until SimpleGraph.Walk.IsTrail.take_until

protected theorem IsTrail.drop_until {u v w : V} {p : G.Walk v w} (hc : p.IsTrail)
    (h : u ∈ p.support) : (p.dropUntil u h).IsTrail :=
  IsTrail.of_append_right (by rwa [← take_spec _ h] at hc)
#align simple_graph.walk.is_trail.drop_until SimpleGraph.Walk.IsTrail.drop_until

protected theorem IsPath.take_until {u v w : V} {p : G.Walk v w} (hc : p.IsPath)
    (h : u ∈ p.support) : (p.takeUntil u h).IsPath :=
  IsPath.of_append_left (by rwa [← take_spec _ h] at hc)
#align simple_graph.walk.is_path.take_until SimpleGraph.Walk.IsPath.take_until

protected theorem IsPath.drop_until {u v w : V} (p : G.Walk v w) (hc : p.IsPath)
    (h : u ∈ p.support) : (p.dropUntil u h).IsPath :=
  IsPath.of_append_right (by rwa [← take_spec _ h] at hc)
#align simple_graph.walk.is_path.drop_until SimpleGraph.Walk.IsPath.drop_until

/-- Rotate a loop walk such that it is centered at the given vertex. -/
def rotate {u v : V} (c : G.Walk v v) (h : u ∈ c.support) : G.Walk u u :=
  (c.dropUntil u h).append (c.takeUntil u h)
#align simple_graph.walk.rotate SimpleGraph.Walk.rotate

@[simp]
theorem support_rotate {u v : V} (c : G.Walk v v) (h : u ∈ c.support) :
    (c.rotate h).support.tail ~r c.support.tail := by
  simp only [rotate, tail_support_append]
  apply List.IsRotated.trans List.is_rotated_append
  rw [← tail_support_append, take_spec]
#align simple_graph.walk.support_rotate SimpleGraph.Walk.support_rotate

theorem rotate_darts {u v : V} (c : G.Walk v v) (h : u ∈ c.support) :
    (c.rotate h).darts ~r c.darts := by
  simp only [rotate, darts_append]
  apply List.IsRotated.trans List.is_rotated_append
  rw [← darts_append, take_spec]
#align simple_graph.walk.rotate_darts SimpleGraph.Walk.rotate_darts

theorem rotate_edges {u v : V} (c : G.Walk v v) (h : u ∈ c.support) :
    (c.rotate h).edges ~r c.edges :=
  (rotate_darts c h).map _
#align simple_graph.walk.rotate_edges SimpleGraph.Walk.rotate_edges

protected theorem IsTrail.rotate {u v : V} {c : G.Walk v v} (hc : c.IsTrail) (h : u ∈ c.support) :
    (c.rotate h).IsTrail := by
  rw [is_trail_def, (c.rotate_edges h).Perm.nodup_iff]
  exact hc.edges_nodup
#align simple_graph.walk.is_trail.rotate SimpleGraph.Walk.IsTrail.rotate

protected theorem IsCircuit.rotate {u v : V} {c : G.Walk v v} (hc : c.IsCircuit)
    (h : u ∈ c.support) : (c.rotate h).IsCircuit := by
  refine' ⟨hc.to_trail.rotate _, _⟩
  cases c
  · exact (hc.ne_nil rfl).elim
  · intro hn
    have hn' := congr_arg length hn
    rw [rotate, length_append, add_comm, ← length_append, take_spec] at hn'
    simpa using hn'
#align simple_graph.walk.is_circuit.rotate SimpleGraph.Walk.IsCircuit.rotate

protected theorem IsCycle.rotate {u v : V} {c : G.Walk v v} (hc : c.IsCycle) (h : u ∈ c.support) :
    (c.rotate h).IsCycle := by 
  refine' ⟨hc.to_circuit.rotate _, _⟩
  rw [List.IsRotated.nodup_iff (support_rotate _ _)]
  exact hc.support_nodup
#align simple_graph.walk.is_cycle.rotate SimpleGraph.Walk.IsCycle.rotate

end WalkDecomp

end Walk

/-! ### Type of paths -/


/-- The type for paths between two vertices. -/
abbrev Path (u v : V) :=
  { p : G.Walk u v // p.IsPath }
#align simple_graph.path SimpleGraph.Path

namespace Path

variable {G G'}

@[simp]
protected theorem is_path {u v : V} (p : G.Path u v) : (p : G.Walk u v).IsPath :=
  p.property
#align simple_graph.path.is_path SimpleGraph.Path.is_path

@[simp]
protected theorem is_trail {u v : V} (p : G.Path u v) : (p : G.Walk u v).IsTrail :=
  p.property.to_trail
#align simple_graph.path.is_trail SimpleGraph.Path.is_trail

/-- The length-0 path at a vertex. -/
@[refl, simps]
protected def nil {u : V} : G.Path u u :=
  ⟨Walk.nil, Walk.IsPath.nil⟩
#align simple_graph.path.nil SimpleGraph.Path.nil

/-- The length-1 path between a pair of adjacent vertices. -/
@[simps]
def singleton {u v : V} (h : G.Adj u v) : G.Path u v :=
  ⟨Walk.cons h Walk.nil, by simp [h.ne]⟩
#align simple_graph.path.singleton SimpleGraph.Path.singleton

theorem mk_mem_edges_singleton {u v : V} (h : G.Adj u v) :
    ⟦(u, v)⟧ ∈ (singleton h : G.Walk u v).edges := by simp [singleton]
#align simple_graph.path.mk_mem_edges_singleton SimpleGraph.Path.mk_mem_edges_singleton

/-- The reverse of a path is another path.  See also `simple_graph.walk.reverse`. -/
@[symm, simps]
def reverse {u v : V} (p : G.Path u v) : G.Path v u :=
  ⟨Walk.reverse p, p.property.reverse⟩
#align simple_graph.path.reverse SimpleGraph.Path.reverse

theorem count_support_eq_one [DecidableEq V] {u v w : V} {p : G.Path u v}
    (hw : w ∈ (p : G.Walk u v).support) : (p : G.Walk u v).support.count w = 1 :=
  List.count_eq_one_of_mem p.property.support_nodup hw
#align simple_graph.path.count_support_eq_one SimpleGraph.Path.count_support_eq_one

theorem count_edges_eq_one [DecidableEq V] {u v : V} {p : G.Path u v} (e : Sym2 V)
    (hw : e ∈ (p : G.Walk u v).edges) : (p : G.Walk u v).edges.count e = 1 :=
  List.count_eq_one_of_mem p.property.to_trail.edges_nodup hw
#align simple_graph.path.count_edges_eq_one SimpleGraph.Path.count_edges_eq_one

@[simp]
theorem nodup_support {u v : V} (p : G.Path u v) : (p : G.Walk u v).support.Nodup :=
  (Walk.is_path_def _).mp p.property
#align simple_graph.path.nodup_support SimpleGraph.Path.nodup_support

theorem loop_eq {v : V} (p : G.Path v v) : p = path.nil := by
  obtain ⟨_ | _, this⟩ := p
  · rfl
  · simpa
#align simple_graph.path.loop_eq SimpleGraph.Path.loop_eq

theorem not_mem_edges_of_loop {v : V} {e : Sym2 V} {p : G.Path v v} : ¬e ∈ (p : G.Walk v v).edges :=
  by simp [p.loop_eq]
#align simple_graph.path.not_mem_edges_of_loop SimpleGraph.Path.not_mem_edges_of_loop

theorem cons_is_cycle {u v : V} (p : G.Path v u) (h : G.Adj u v)
    (he : ¬⟦(u, v)⟧ ∈ (p : G.Walk v u).edges) : (Walk.cons h ↑p).IsCycle := by
  simp [walk.is_cycle_def, walk.cons_is_trail_iff, he]
#align simple_graph.path.cons_is_cycle SimpleGraph.Path.cons_is_cycle

end Path

/-! ### Walks to paths -/


namespace Walk

variable {G} [DecidableEq V]

/-- Given a walk, produces a walk from it by bypassing subwalks between repeated vertices.
The result is a path, as shown in `simple_graph.walk.bypass_is_path`.
This is packaged up in `simple_graph.walk.to_path`. -/
def bypass : ∀ {u v : V}, G.Walk u v → G.Walk u v
  | u, v, nil => nil
  | u, v, cons ha p =>
    let p' := p.bypass
    if hs : u ∈ p'.support then p'.dropUntil u hs else cons ha p'
#align simple_graph.walk.bypass SimpleGraph.Walk.bypass

@[simp]
theorem bypass_copy {u v u' v'} (p : G.Walk u v) (hu : u = u') (hv : v = v') :
    (p.copy hu hv).bypass = p.bypass.copy hu hv := by
  subst_vars
  rfl
#align simple_graph.walk.bypass_copy SimpleGraph.Walk.bypass_copy

theorem bypass_is_path {u v : V} (p : G.Walk u v) : p.bypass.IsPath := by
  induction p
  · simp!
  · simp only [bypass]
    split_ifs
    · apply is_path.drop_until
      assumption
    · simp [*, cons_is_path_iff]
#align simple_graph.walk.bypass_is_path SimpleGraph.Walk.bypass_is_path

theorem length_bypass_le {u v : V} (p : G.Walk u v) : p.bypass.length ≤ p.length := by
  induction p
  · rfl
  · simp only [bypass]
    split_ifs
    · trans
      apply length_drop_until_le
      rw [length_cons]
      exact le_add_right p_ih
    · rw [length_cons, length_cons]
      exact add_le_add_right p_ih 1
#align simple_graph.walk.length_bypass_le SimpleGraph.Walk.length_bypass_le

/-- Given a walk, produces a path with the same endpoints using `simple_graph.walk.bypass`. -/
def toPath {u v : V} (p : G.Walk u v) : G.Path u v :=
  ⟨p.bypass, p.bypass_is_path⟩
#align simple_graph.walk.to_path SimpleGraph.Walk.toPath

theorem support_bypass_subset {u v : V} (p : G.Walk u v) : p.bypass.support ⊆ p.support := by
  induction p
  · simp!
  · simp! only
    split_ifs
    · apply List.Subset.trans (support_drop_until_subset _ _)
      apply List.subset_cons_of_subset
      assumption
    · rw [support_cons]
      apply List.cons_subset_cons
      assumption
#align simple_graph.walk.support_bypass_subset SimpleGraph.Walk.support_bypass_subset

theorem support_to_path_subset {u v : V} (p : G.Walk u v) :
    (p.toPath : G.Walk u v).support ⊆ p.support :=
  support_bypass_subset _
#align simple_graph.walk.support_to_path_subset SimpleGraph.Walk.support_to_path_subset

theorem darts_bypass_subset {u v : V} (p : G.Walk u v) : p.bypass.darts ⊆ p.darts := by
  induction p
  · simp!
  · simp! only
    split_ifs
    · apply List.Subset.trans (darts_drop_until_subset _ _)
      apply List.subset_cons_of_subset _ p_ih
    · rw [darts_cons]
      exact List.cons_subset_cons _ p_ih
#align simple_graph.walk.darts_bypass_subset SimpleGraph.Walk.darts_bypass_subset

theorem edges_bypass_subset {u v : V} (p : G.Walk u v) : p.bypass.edges ⊆ p.edges :=
  List.map_subset _ p.darts_bypass_subset
#align simple_graph.walk.edges_bypass_subset SimpleGraph.Walk.edges_bypass_subset

theorem darts_to_path_subset {u v : V} (p : G.Walk u v) : (p.toPath : G.Walk u v).darts ⊆ p.darts :=
  darts_bypass_subset _
#align simple_graph.walk.darts_to_path_subset SimpleGraph.Walk.darts_to_path_subset

theorem edges_to_path_subset {u v : V} (p : G.Walk u v) : (p.toPath : G.Walk u v).edges ⊆ p.edges :=
  edges_bypass_subset _
#align simple_graph.walk.edges_to_path_subset SimpleGraph.Walk.edges_to_path_subset

end Walk

/-! ### Mapping paths -/


namespace Walk

variable {G G' G''}

/-- Given a graph homomorphism, map walks to walks. -/
protected def map (f : G →g G') : ∀ {u v : V}, G.Walk u v → G'.Walk (f u) (f v)
  | _, _, nil => nil
  | _, _, cons h p => cons (f.map_adj h) (map p)
#align simple_graph.walk.map SimpleGraph.Walk.map

variable (f : G →g G') (f' : G' →g G'') {u v u' v' : V} (p : G.Walk u v)

@[simp]
theorem map_nil : (nil : G.Walk u u).map f = nil :=
  rfl
#align simple_graph.walk.map_nil SimpleGraph.Walk.map_nil

@[simp]
theorem map_cons {w : V} (h : G.Adj w u) : (cons h p).map f = cons (f.map_adj h) (p.map f) :=
  rfl
#align simple_graph.walk.map_cons SimpleGraph.Walk.map_cons

@[simp]
theorem map_copy (hu : u = u') (hv : v = v') :
    (p.copy hu hv).map f = (p.map f).copy (by rw [hu]) (by rw [hv]) := by
  subst_vars
  rfl
#align simple_graph.walk.map_copy SimpleGraph.Walk.map_copy

@[simp]
theorem map_id (p : G.Walk u v) : p.map Hom.id = p := by induction p <;> simp [*]
#align simple_graph.walk.map_id SimpleGraph.Walk.map_id

@[simp]
theorem map_map : (p.map f).map f' = p.map (f'.comp f) := by induction p <;> simp [*]
#align simple_graph.walk.map_map SimpleGraph.Walk.map_map

/-- Unlike categories, for graphs vertex equality is an important notion, so needing to be able to
to work with equality of graph homomorphisms is a necessary evil. -/
theorem map_eq_of_eq {f : G →g G'} (f' : G →g G') (h : f = f') :
    p.map f = (p.map f').copy (by rw [h]) (by rw [h]) := by
  subst_vars
  rfl
#align simple_graph.walk.map_eq_of_eq SimpleGraph.Walk.map_eq_of_eq

@[simp]
theorem map_eq_nil_iff {p : G.Walk u u} : p.map f = nil ↔ p = nil := by cases p <;> simp
#align simple_graph.walk.map_eq_nil_iff SimpleGraph.Walk.map_eq_nil_iff

@[simp]
theorem length_map : (p.map f).length = p.length := by induction p <;> simp [*]
#align simple_graph.walk.length_map SimpleGraph.Walk.length_map

theorem map_append {u v w : V} (p : G.Walk u v) (q : G.Walk v w) :
    (p.append q).map f = (p.map f).append (q.map f) := by induction p <;> simp [*]
#align simple_graph.walk.map_append SimpleGraph.Walk.map_append

@[simp]
theorem reverse_map : (p.map f).reverse = p.reverse.map f := by induction p <;> simp [map_append, *]
#align simple_graph.walk.reverse_map SimpleGraph.Walk.reverse_map

@[simp]
theorem support_map : (p.map f).support = p.support.map f := by induction p <;> simp [*]
#align simple_graph.walk.support_map SimpleGraph.Walk.support_map

@[simp]
theorem darts_map : (p.map f).darts = p.darts.map f.mapDart := by induction p <;> simp [*]
#align simple_graph.walk.darts_map SimpleGraph.Walk.darts_map

@[simp]
theorem edges_map : (p.map f).edges = p.edges.map (Sym2.map f) := by induction p <;> simp [*]
#align simple_graph.walk.edges_map SimpleGraph.Walk.edges_map

variable {p f}

theorem map_is_path_of_injective (hinj : Function.Injective f) (hp : p.IsPath) : (p.map f).IsPath :=
  by 
  induction' p with w u v w huv hvw ih
  · simp
  · rw [walk.cons_is_path_iff] at hp
    simp [ih hp.1]
    intro x hx hf
    cases hinj hf
    exact hp.2 hx
#align simple_graph.walk.map_is_path_of_injective SimpleGraph.Walk.map_is_path_of_injective

protected theorem IsPath.of_map {f : G →g G'} (hp : (p.map f).IsPath) : p.IsPath := by
  induction' p with w u v w huv hvw ih
  · simp
  · rw [map_cons, walk.cons_is_path_iff, support_map] at hp
    rw [walk.cons_is_path_iff]
    cases' hp with hp1 hp2
    refine' ⟨ih hp1, _⟩
    contrapose! hp2
    exact List.mem_map_of_mem f hp2
#align simple_graph.walk.is_path.of_map SimpleGraph.Walk.IsPath.of_map

theorem map_is_path_iff_of_injective (hinj : Function.Injective f) : (p.map f).IsPath ↔ p.IsPath :=
  ⟨IsPath.of_map, map_is_path_of_injective hinj⟩
#align simple_graph.walk.map_is_path_iff_of_injective SimpleGraph.Walk.map_is_path_iff_of_injective

theorem map_is_trail_iff_of_injective (hinj : Function.Injective f) :
    (p.map f).IsTrail ↔ p.IsTrail := by
  induction' p with w u v w huv hvw ih
  · simp
  · rw [map_cons, cons_is_trail_iff, cons_is_trail_iff, edges_map]
    change _ ∧ Sym2.map f ⟦(u, v)⟧ ∉ _ ↔ _
    rw [List.mem_map_of_injective (Sym2.map.injective hinj)]
    exact and_congr_left' ih
#align
  simple_graph.walk.map_is_trail_iff_of_injective SimpleGraph.Walk.map_is_trail_iff_of_injective

alias map_is_trail_iff_of_injective ↔ _ map_is_trail_of_injective

theorem map_is_cycle_iff_of_injective {p : G.Walk u u} (hinj : Function.Injective f) :
    (p.map f).IsCycle ↔ p.IsCycle := by
  rw [is_cycle_def, is_cycle_def, map_is_trail_iff_of_injective hinj, Ne.def, map_eq_nil_iff,
    support_map, ← List.map_tail, List.nodup_map_iff hinj]
#align
  simple_graph.walk.map_is_cycle_iff_of_injective SimpleGraph.Walk.map_is_cycle_iff_of_injective

alias map_is_cycle_iff_of_injective ↔ _ map_is_cycle_of_injective

variable (p f)

theorem map_injective_of_injective {f : G →g G'} (hinj : Function.Injective f) (u v : V) :
    Function.Injective (Walk.map f : G.Walk u v → G'.Walk (f u) (f v)) := by
  intro p p' h
  induction' p with _ _ _ _ _ _ ih generalizing p'
  · cases p'
    · rfl
    simpa using h
  · induction p'
    · simpa using h
    · simp only [map_cons] at h
      cases hinj h.1
      simp only [eq_self_iff_true, heq_iff_eq, true_and_iff]
      apply ih
      simpa using h.2
#align simple_graph.walk.map_injective_of_injective SimpleGraph.Walk.map_injective_of_injective

/-- The specialization of `simple_graph.walk.map` for mapping walks to supergraphs. -/
@[reducible]
def mapLe {G G' : SimpleGraph V} (h : G ≤ G') {u v : V} (p : G.Walk u v) : G'.Walk u v :=
  p.map (Hom.mapSpanningSubgraphs h)
#align simple_graph.walk.map_le SimpleGraph.Walk.mapLe

@[simp]
theorem map_le_is_trail {G G' : SimpleGraph V} (h : G ≤ G') {u v : V} {p : G.Walk u v} :
    (p.mapLe h).IsTrail ↔ p.IsTrail :=
  map_is_trail_iff_of_injective Function.injective_id
#align simple_graph.walk.map_le_is_trail SimpleGraph.Walk.map_le_is_trail

alias map_le_is_trail ↔ is_trail.of_map_le is_trail.map_le

@[simp]
theorem map_le_is_path {G G' : SimpleGraph V} (h : G ≤ G') {u v : V} {p : G.Walk u v} :
    (p.mapLe h).IsPath ↔ p.IsPath :=
  map_is_path_iff_of_injective Function.injective_id
#align simple_graph.walk.map_le_is_path SimpleGraph.Walk.map_le_is_path

alias map_le_is_path ↔ is_path.of_map_le is_path.map_le

@[simp]
theorem map_le_is_cycle {G G' : SimpleGraph V} (h : G ≤ G') {u : V} {p : G.Walk u u} :
    (p.mapLe h).IsCycle ↔ p.IsCycle :=
  map_is_cycle_iff_of_injective Function.injective_id
#align simple_graph.walk.map_le_is_cycle SimpleGraph.Walk.map_le_is_cycle

alias map_le_is_cycle ↔ is_cycle.of_map_le is_cycle.map_le

end Walk

namespace Path

variable {G G'}

/-- Given an injective graph homomorphism, map paths to paths. -/
@[simps]
protected def map (f : G →g G') (hinj : Function.Injective f) {u v : V} (p : G.Path u v) :
    G'.Path (f u) (f v) :=
  ⟨Walk.map f p, Walk.map_is_path_of_injective hinj p.2⟩
#align simple_graph.path.map SimpleGraph.Path.map

theorem map_injective {f : G →g G'} (hinj : Function.Injective f) (u v : V) :
    Function.Injective (Path.map f hinj : G.Path u v → G'.Path (f u) (f v)) := by
  rintro ⟨p, hp⟩ ⟨p', hp'⟩ h
  simp only [path.map, Subtype.coe_mk] at h
  simp [walk.map_injective_of_injective hinj u v h]
#align simple_graph.path.map_injective SimpleGraph.Path.map_injective

/-- Given a graph embedding, map paths to paths. -/
@[simps]
protected def mapEmbedding (f : G ↪g G') {u v : V} (p : G.Path u v) : G'.Path (f u) (f v) :=
  Path.map f.toHom f.Injective p
#align simple_graph.path.map_embedding SimpleGraph.Path.mapEmbedding

theorem map_embedding_injective (f : G ↪g G') (u v : V) :
    Function.Injective (Path.mapEmbedding f : G.Path u v → G'.Path (f u) (f v)) :=
  map_injective f.Injective u v
#align simple_graph.path.map_embedding_injective SimpleGraph.Path.map_embedding_injective

end Path

/-! ### Transferring between graphs -/


namespace Walk

variable {G}

/-- The walk `p` transferred to lie in `H`, given that `H` contains its edges. -/
@[protected, simp]
def transfer :
    ∀ {u v : V} (p : G.Walk u v) (H : SimpleGraph V) (h : ∀ e, e ∈ p.edges → e ∈ H.edgeSet),
      H.Walk u v
  | _, _, walk.nil, H, h => Walk.nil
  | _, _, walk.cons' u v w a p, H, h =>
    Walk.cons (h (⟦(u, v)⟧ : Sym2 V) (by simp)) (p.transfer H fun e he => h e (by simp [he]))
#align simple_graph.walk.transfer SimpleGraph.Walk.transfer

variable {u v w : V} (p : G.Walk u v) (q : G.Walk v w) {H : SimpleGraph V}
  (hp : ∀ e, e ∈ p.edges → e ∈ H.edgeSet) (hq : ∀ e, e ∈ q.edges → e ∈ H.edgeSet)

theorem transfer_self : p.transfer G p.edges_subset_edge_set = p := by
  induction p <;> simp only [*, transfer, eq_self_iff_true, heq_iff_eq, and_self_iff]
#align simple_graph.walk.transfer_self SimpleGraph.Walk.transfer_self

theorem transfer_eq_map_of_le (GH : G ≤ H) :
    p.transfer H hp = p.map (SimpleGraph.Hom.mapSpanningSubgraphs GH) := by
  induction p <;>
    simp only [*, transfer, map_cons, hom.map_spanning_subgraphs_apply, eq_self_iff_true,
      heq_iff_eq, and_self_iff, map_nil]
#align simple_graph.walk.transfer_eq_map_of_le SimpleGraph.Walk.transfer_eq_map_of_le

@[simp]
theorem edges_transfer : (p.transfer H hp).edges = p.edges := by
  induction p <;> simp only [*, transfer, edges_nil, edges_cons, eq_self_iff_true, and_self_iff]
#align simple_graph.walk.edges_transfer SimpleGraph.Walk.edges_transfer

@[simp]
theorem support_transfer : (p.transfer H hp).support = p.support := by
  induction p <;> simp only [*, transfer, eq_self_iff_true, and_self_iff, support_nil, support_cons]
#align simple_graph.walk.support_transfer SimpleGraph.Walk.support_transfer

@[simp]
theorem length_transfer : (p.transfer H hp).length = p.length := by induction p <;> simp [*]
#align simple_graph.walk.length_transfer SimpleGraph.Walk.length_transfer

variable {p}

protected theorem IsPath.transfer (pp : p.IsPath) : (p.transfer H hp).IsPath := by
  induction p <;> simp only [transfer, is_path.nil, cons_is_path_iff, support_transfer] at pp⊢
  · tauto
#align simple_graph.walk.is_path.transfer SimpleGraph.Walk.IsPath.transfer

protected theorem IsCycle.transfer {p : G.Walk u u} (pc : p.IsCycle) (hp) :
    (p.transfer H hp).IsCycle := by
  cases p <;>
    simp only [transfer, is_cycle.not_of_nil, cons_is_cycle_iff, transfer, edges_transfer] at pc⊢
  · exact pc
  · exact ⟨pc.left.transfer _, pc.right⟩
#align simple_graph.walk.is_cycle.transfer SimpleGraph.Walk.IsCycle.transfer

variable (p)

@[simp]
theorem transfer_transfer {K : SimpleGraph V} (hp' : ∀ e, e ∈ p.edges → e ∈ K.edgeSet) :
    (p.transfer H hp).transfer K
        (by 
          rw [p.edges_transfer hp]
          exact hp') =
      p.transfer K hp' :=
  by 
  induction p <;> simp only [transfer, eq_self_iff_true, heq_iff_eq, true_and_iff]
  apply p_ih
#align simple_graph.walk.transfer_transfer SimpleGraph.Walk.transfer_transfer

@[simp]
theorem transfer_append (hpq) :
    (p.append q).transfer H hpq =
      (p.transfer H fun e he => by 
            apply hpq
            simp [he]).append
        (q.transfer H fun e he => by 
          apply hpq
          simp [he]) :=
  by
  induction p <;>
    simp only [transfer, nil_append, cons_append, eq_self_iff_true, heq_iff_eq, true_and_iff]
  apply p_ih
#align simple_graph.walk.transfer_append SimpleGraph.Walk.transfer_append

@[simp]
theorem reverse_transfer :
    (p.transfer H hp).reverse =
      p.reverse.transfer H
        (by 
          simp only [edges_reverse, List.mem_reverse]
          exact hp) :=
  by 
  induction p <;> simp only [*, transfer_append, transfer, reverse_nil, reverse_cons]
  rfl
#align simple_graph.walk.reverse_transfer SimpleGraph.Walk.reverse_transfer

end Walk

/-! ## Deleting edges -/


namespace Walk

variable {G}

/-- Given a walk that avoids a set of edges, produce a walk in the graph
with those edges deleted. -/
@[reducible]
def toDeleteEdges (s : Set (Sym2 V)) {v w : V} (p : G.Walk v w) (hp : ∀ e, e ∈ p.edges → ¬e ∈ s) :
    (G.deleteEdges s).Walk v w :=
  p.transfer _
    (by 
      simp only [edge_set_delete_edges, Set.mem_diff]
      exact fun e ep => ⟨edges_subset_edge_set p ep, hp e ep⟩)
#align simple_graph.walk.to_delete_edges SimpleGraph.Walk.toDeleteEdges

@[simp]
theorem to_delete_edges_nil (s : Set (Sym2 V)) {v : V} (hp) :
    (Walk.nil : G.Walk v v).toDeleteEdges s hp = walk.nil :=
  rfl
#align simple_graph.walk.to_delete_edges_nil SimpleGraph.Walk.to_delete_edges_nil

@[simp]
theorem to_delete_edges_cons (s : Set (Sym2 V)) {u v w : V} (h : G.Adj u v) (p : G.Walk v w) (hp) :
    (Walk.cons h p).toDeleteEdges s hp =
      Walk.cons ⟨h, hp _ (Or.inl rfl)⟩ ((p.toDeleteEdges s) fun _ he => hp _ <| Or.inr he) :=
  rfl
#align simple_graph.walk.to_delete_edges_cons SimpleGraph.Walk.to_delete_edges_cons

/-- Given a walk that avoids an edge, create a walk in the subgraph with that edge deleted.
This is an abbreviation for `simple_graph.walk.to_delete_edges`. -/
abbrev toDeleteEdge {v w : V} (e : Sym2 V) (p : G.Walk v w) (hp : e ∉ p.edges) :
    (G.deleteEdges {e}).Walk v w :=
  p.toDeleteEdges {e} fun e' => by 
    contrapose!
    simp (config := { contextual := true }) [hp]
#align simple_graph.walk.to_delete_edge SimpleGraph.Walk.toDeleteEdge

@[simp]
theorem map_to_delete_edges_eq (s : Set (Sym2 V)) {v w : V} {p : G.Walk v w} (hp) :
    Walk.map (Hom.mapSpanningSubgraphs (G.delete_edges_le s)) (p.toDeleteEdges s hp) = p := by
  rw [← transfer_eq_map_of_le, transfer_transfer, transfer_self]
#align simple_graph.walk.map_to_delete_edges_eq SimpleGraph.Walk.map_to_delete_edges_eq

protected theorem IsPath.to_delete_edges (s : Set (Sym2 V)) {v w : V} {p : G.Walk v w}
    (h : p.IsPath) (hp) : (p.toDeleteEdges s hp).IsPath :=
  h.transfer _
#align simple_graph.walk.is_path.to_delete_edges SimpleGraph.Walk.IsPath.to_delete_edges

protected theorem IsCycle.to_delete_edges (s : Set (Sym2 V)) {v : V} {p : G.Walk v v}
    (h : p.IsCycle) (hp) : (p.toDeleteEdges s hp).IsCycle :=
  h.transfer _
#align simple_graph.walk.is_cycle.to_delete_edges SimpleGraph.Walk.IsCycle.to_delete_edges

@[simp]
theorem to_delete_edges_copy (s : Set (Sym2 V)) {u v u' v'} (p : G.Walk u v) (hu : u = u')
    (hv : v = v') (h) :
    (p.copy hu hv).toDeleteEdges s h =
      (p.toDeleteEdges s
            (by 
              subst_vars
              exact h)).copy
        hu hv :=
  by 
  subst_vars
  rfl
#align simple_graph.walk.to_delete_edges_copy SimpleGraph.Walk.to_delete_edges_copy

end Walk

/-! ## `reachable` and `connected` -/


/-- Two vertices are *reachable* if there is a walk between them.
This is equivalent to `relation.refl_trans_gen` of `G.adj`.
See `simple_graph.reachable_iff_refl_trans_gen`. -/
def Reachable (u v : V) : Prop :=
  Nonempty (G.Walk u v)
#align simple_graph.reachable SimpleGraph.Reachable

variable {G}

theorem reachable_iff_nonempty_univ {u v : V} :
    G.Reachable u v ↔ (Set.univ : Set (G.Walk u v)).Nonempty :=
  Set.nonempty_iff_univ_nonempty
#align simple_graph.reachable_iff_nonempty_univ SimpleGraph.reachable_iff_nonempty_univ

protected theorem Reachable.elim {p : Prop} {u v : V} (h : G.Reachable u v) (hp : G.Walk u v → p) :
    p :=
  Nonempty.elim h hp
#align simple_graph.reachable.elim SimpleGraph.Reachable.elim

protected theorem Reachable.elim_path {p : Prop} {u v : V} (h : G.Reachable u v)
    (hp : G.Path u v → p) : p := by classical exact h.elim fun q => hp q.toPath
#align simple_graph.reachable.elim_path SimpleGraph.Reachable.elim_path

protected theorem Walk.reachable {G : SimpleGraph V} {u v : V} (p : G.Walk u v) : G.Reachable u v :=
  ⟨p⟩
#align simple_graph.walk.reachable SimpleGraph.Walk.reachable

protected theorem Adj.reachable {u v : V} (h : G.Adj u v) : G.Reachable u v :=
  h.toWalk.Reachable
#align simple_graph.adj.reachable SimpleGraph.Adj.reachable

@[refl]
protected theorem Reachable.refl (u : V) : G.Reachable u u := by
  fconstructor
  rfl
#align simple_graph.reachable.refl SimpleGraph.Reachable.refl

protected theorem Reachable.rfl {u : V} : G.Reachable u u :=
  Reachable.refl _
#align simple_graph.reachable.rfl SimpleGraph.Reachable.rfl

@[symm]
protected theorem Reachable.symm {u v : V} (huv : G.Reachable u v) : G.Reachable v u :=
  huv.elim fun p => ⟨p.reverse⟩
#align simple_graph.reachable.symm SimpleGraph.Reachable.symm

theorem reachable_comm {u v : V} : G.Reachable u v ↔ G.Reachable v u :=
  ⟨Reachable.symm, Reachable.symm⟩
#align simple_graph.reachable_comm SimpleGraph.reachable_comm

@[trans]
protected theorem Reachable.trans {u v w : V} (huv : G.Reachable u v) (hvw : G.Reachable v w) :
    G.Reachable u w :=
  huv.elim fun puv => hvw.elim fun pvw => ⟨puv.append pvw⟩
#align simple_graph.reachable.trans SimpleGraph.Reachable.trans

theorem reachable_iff_refl_trans_gen (u v : V) :
    G.Reachable u v ↔ Relation.ReflTransGen G.Adj u v := by
  constructor
  · rintro ⟨h⟩
    induction h
    · rfl
    · exact (Relation.ReflTransGen.single h_h).trans h_ih
  · intro h
    induction' h with _ _ _ ha hr
    · rfl
    · exact reachable.trans hr ⟨walk.cons ha walk.nil⟩
#align simple_graph.reachable_iff_refl_trans_gen SimpleGraph.reachable_iff_refl_trans_gen

protected theorem Reachable.map {G : SimpleGraph V} {G' : SimpleGraph V'} (f : G →g G') {u v : V}
    (h : G.Reachable u v) : G'.Reachable (f u) (f v) :=
  h.elim fun p => ⟨p.map f⟩
#align simple_graph.reachable.map SimpleGraph.Reachable.map

variable (G)

theorem reachable_is_equivalence : Equivalence G.Reachable :=
  Equivalence.mk _ (@Reachable.refl _ G) (@Reachable.symm _ G) (@Reachable.trans _ G)
#align simple_graph.reachable_is_equivalence SimpleGraph.reachable_is_equivalence

/-- The equivalence relation on vertices given by `simple_graph.reachable`. -/
def reachableSetoid : Setoid V :=
  Setoid.mk _ G.reachable_is_equivalence
#align simple_graph.reachable_setoid SimpleGraph.reachableSetoid

/-- A graph is preconnected if every pair of vertices is reachable from one another. -/
def Preconnected : Prop :=
  ∀ u v : V, G.Reachable u v
#align simple_graph.preconnected SimpleGraph.Preconnected

theorem Preconnected.map {G : SimpleGraph V} {H : SimpleGraph V'} (f : G →g H) (hf : Surjective f)
    (hG : G.Preconnected) : H.Preconnected :=
  hf.forall₂.2 fun a b => Nonempty.map (Walk.map _) <| hG _ _
#align simple_graph.preconnected.map SimpleGraph.Preconnected.map

theorem Iso.preconnected_iff {G : SimpleGraph V} {H : SimpleGraph V'} (e : G ≃g H) :
    G.Preconnected ↔ H.Preconnected :=
  ⟨Preconnected.map e.toHom e.toEquiv.Surjective,
    Preconnected.map e.symm.toHom e.symm.toEquiv.Surjective⟩
#align simple_graph.iso.preconnected_iff SimpleGraph.Iso.preconnected_iff

/-- A graph is connected if it's preconnected and contains at least one vertex.
This follows the convention observed by mathlib that something is connected iff it has
exactly one connected component.

There is a `has_coe_to_fun` instance so that `h u v` can be used instead
of `h.preconnected u v`. -/
@[protect_proj, mk_iff]
structure Connected : Prop where
  Preconnected : G.Preconnected
  [Nonempty : Nonempty V]
#align simple_graph.connected SimpleGraph.Connected

instance : CoeFun G.Connected fun _ => ∀ u v : V, G.Reachable u v :=
  ⟨fun h => h.Preconnected⟩

theorem Connected.map {G : SimpleGraph V} {H : SimpleGraph V'} (f : G →g H) (hf : Surjective f)
    (hG : G.Connected) : H.Connected :=
  haveI := hG.nonempty.map f
  ⟨hG.preconnected.map f hf⟩
#align simple_graph.connected.map SimpleGraph.Connected.map

theorem Iso.connected_iff {G : SimpleGraph V} {H : SimpleGraph V'} (e : G ≃g H) :
    G.Connected ↔ H.Connected :=
  ⟨Connected.map e.toHom e.toEquiv.Surjective, Connected.map e.symm.toHom e.symm.toEquiv.Surjective⟩
#align simple_graph.iso.connected_iff SimpleGraph.Iso.connected_iff

/-- The quotient of `V` by the `simple_graph.reachable` relation gives the connected
components of a graph. -/
def ConnectedComponent :=
  Quot G.Reachable
#align simple_graph.connected_component SimpleGraph.ConnectedComponent

/-- Gives the connected component containing a particular vertex. -/
def connectedComponentMk (v : V) : G.ConnectedComponent :=
  Quot.mk G.Reachable v
#align simple_graph.connected_component_mk SimpleGraph.connectedComponentMk

@[simps]
instance ConnectedComponent.inhabited [Inhabited V] : Inhabited G.ConnectedComponent :=
  ⟨G.connectedComponentMk default⟩
#align simple_graph.connected_component.inhabited SimpleGraph.ConnectedComponent.inhabited

section ConnectedComponent

variable {G}

@[elab_as_elim]
protected theorem ConnectedComponent.ind {β : G.ConnectedComponent → Prop}
    (h : ∀ v : V, β (G.connectedComponentMk v)) (c : G.ConnectedComponent) : β c :=
  Quot.ind h c
#align simple_graph.connected_component.ind SimpleGraph.ConnectedComponent.ind

@[elab_as_elim]
protected theorem ConnectedComponent.ind₂ {β : G.ConnectedComponent → G.ConnectedComponent → Prop}
    (h : ∀ v w : V, β (G.connectedComponentMk v) (G.connectedComponentMk w))
    (c d : G.ConnectedComponent) : β c d :=
  Quot.induction_on₂ c d h
#align simple_graph.connected_component.ind₂ SimpleGraph.ConnectedComponent.ind₂

protected theorem ConnectedComponent.sound {v w : V} :
    G.Reachable v w → G.connectedComponentMk v = G.connectedComponentMk w :=
  Quot.sound
#align simple_graph.connected_component.sound SimpleGraph.ConnectedComponent.sound

protected theorem ConnectedComponent.exact {v w : V} :
    G.connectedComponentMk v = G.connectedComponentMk w → G.Reachable v w :=
  @Quotient.exact _ G.reachableSetoid _ _
#align simple_graph.connected_component.exact SimpleGraph.ConnectedComponent.exact

@[simp]
protected theorem ConnectedComponent.eq {v w : V} :
    G.connectedComponentMk v = G.connectedComponentMk w ↔ G.Reachable v w :=
  @Quotient.eq _ G.reachableSetoid _ _
#align simple_graph.connected_component.eq SimpleGraph.ConnectedComponent.eq

/-- The `connected_component` specialization of `quot.lift`. Provides the stronger
assumption that the vertices are connected by a path. -/
protected def ConnectedComponent.lift {β : Sort _} (f : V → β)
    (h : ∀ (v w : V) (p : G.Walk v w), p.IsPath → f v = f w) : G.ConnectedComponent → β :=
  Quot.lift f fun v w (h' : G.Reachable v w) => h'.elim_path fun hp => h v w hp hp.2
#align simple_graph.connected_component.lift SimpleGraph.ConnectedComponent.lift

@[simp]
protected theorem ConnectedComponent.lift_mk {β : Sort _} {f : V → β}
    {h : ∀ (v w : V) (p : G.Walk v w), p.IsPath → f v = f w} {v : V} :
    ConnectedComponent.lift f h (G.connectedComponentMk v) = f v :=
  rfl
#align simple_graph.connected_component.lift_mk SimpleGraph.ConnectedComponent.lift_mk

protected theorem ConnectedComponent.exists {p : G.ConnectedComponent → Prop} :
    (∃ c : G.ConnectedComponent, p c) ↔ ∃ v, p (G.connectedComponentMk v) :=
  (surjective_quot_mk G.Reachable).exists
#align simple_graph.connected_component.exists SimpleGraph.ConnectedComponent.exists

protected theorem ConnectedComponent.forall {p : G.ConnectedComponent → Prop} :
    (∀ c : G.ConnectedComponent, p c) ↔ ∀ v, p (G.connectedComponentMk v) :=
  (surjective_quot_mk G.Reachable).forall
#align simple_graph.connected_component.forall SimpleGraph.ConnectedComponent.forall

theorem Preconnected.subsingleton_connected_component (h : G.Preconnected) :
    Subsingleton G.ConnectedComponent :=
  ⟨ConnectedComponent.ind₂ fun v w => ConnectedComponent.sound (h v w)⟩
#align
  simple_graph.preconnected.subsingleton_connected_component SimpleGraph.Preconnected.subsingleton_connected_component

end ConnectedComponent

variable {G}

/-- A subgraph is connected if it is connected as a simple graph. -/
abbrev Subgraph.Connected (H : G.Subgraph) : Prop :=
  H.coe.Connected
#align simple_graph.subgraph.connected SimpleGraph.Subgraph.Connected

theorem singleton_subgraph_connected {v : V} : (G.singletonSubgraph v).Connected := by
  constructor
  rintro ⟨a, ha⟩ ⟨b, hb⟩
  simp only [singleton_subgraph_verts, Set.mem_singleton_iff] at ha hb
  subst_vars
#align simple_graph.singleton_subgraph_connected SimpleGraph.singleton_subgraph_connected

@[simp]
theorem subgraph_of_adj_connected {v w : V} (hvw : G.Adj v w) : (G.subgraphOfAdj hvw).Connected :=
  by 
  constructor
  rintro ⟨a, ha⟩ ⟨b, hb⟩
  simp only [subgraph_of_adj_verts, Set.mem_insert_iff, Set.mem_singleton_iff] at ha hb
  obtain rfl | rfl := ha <;> obtain rfl | rfl := hb <;>
    first
      |rfl|· 
        apply adj.reachable
        simp
#align simple_graph.subgraph_of_adj_connected SimpleGraph.subgraph_of_adj_connected

theorem Preconnected.set_univ_walk_nonempty (hconn : G.Preconnected) (u v : V) :
    (Set.univ : Set (G.Walk u v)).Nonempty := by
  rw [← Set.nonempty_iff_univ_nonempty]
  exact hconn u v
#align
  simple_graph.preconnected.set_univ_walk_nonempty SimpleGraph.Preconnected.set_univ_walk_nonempty

theorem Connected.set_univ_walk_nonempty (hconn : G.Connected) (u v : V) :
    (Set.univ : Set (G.Walk u v)).Nonempty :=
  hconn.Preconnected.set_univ_walk_nonempty u v
#align simple_graph.connected.set_univ_walk_nonempty SimpleGraph.Connected.set_univ_walk_nonempty

/-! ### Walks of a given length -/


section WalkCounting

theorem set_walk_self_length_zero_eq (u : V) : { p : G.Walk u u | p.length = 0 } = {Walk.nil} := by
  ext p
  simp
#align simple_graph.set_walk_self_length_zero_eq SimpleGraph.set_walk_self_length_zero_eq

theorem set_walk_length_zero_eq_of_ne {u v : V} (h : u ≠ v) :
    { p : G.Walk u v | p.length = 0 } = ∅ := by 
  ext p
  simp only [Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false_iff]
  exact fun h' => absurd (walk.eq_of_length_eq_zero h') h
#align simple_graph.set_walk_length_zero_eq_of_ne SimpleGraph.set_walk_length_zero_eq_of_ne

theorem set_walk_length_succ_eq (u v : V) (n : ℕ) :
    { p : G.Walk u v | p.length = n.succ } =
      ⋃ (w : V) (h : G.Adj u w), Walk.cons h '' { p' : G.Walk w v | p'.length = n } :=
  by 
  ext p
  cases' p with _ _ w _ huw pwv
  · simp [eq_comm]
  · simp only [Nat.succ_eq_add_one, Set.mem_setOf_eq, walk.length_cons, add_left_inj, Set.mem_Union,
      Set.mem_image, exists_prop]
    constructor
    · rintro rfl
      exact ⟨w, huw, pwv, rfl, rfl, HEq.rfl⟩
    · rintro ⟨w, huw, pwv, rfl, rfl, rfl⟩
      rfl
#align simple_graph.set_walk_length_succ_eq SimpleGraph.set_walk_length_succ_eq

variable (G) [DecidableEq V]

section LocallyFinite

variable [LocallyFinite G]

/-- The `finset` of length-`n` walks from `u` to `v`.
This is used to give `{p : G.walk u v | p.length = n}` a `fintype` instance, and it
can also be useful as a recursive description of this set when `V` is finite.

See `simple_graph.coe_finset_walk_length_eq` for the relationship between this `finset` and
the set of length-`n` walks. -/
def finsetWalkLength : ∀ (n : ℕ) (u v : V), Finset (G.Walk u v)
  | 0, u, v =>
    if h : u = v then by 
      subst u
      exact {walk.nil}
    else ∅
  | n + 1, u, v =>
    Finset.univ.bUnion fun w : G.neighborSet u =>
      (finset_walk_length n w v).map ⟨fun p => Walk.cons w.property p, fun p q => by simp⟩
#align simple_graph.finset_walk_length SimpleGraph.finsetWalkLength

theorem coe_finset_walk_length_eq (n : ℕ) (u v : V) :
    (G.finsetWalkLength n u v : Set (G.Walk u v)) = { p : G.Walk u v | p.length = n } := by
  induction' n with n ih generalizing u v
  · obtain rfl | huv := eq_or_ne u v <;> simp [finset_walk_length, set_walk_length_zero_eq_of_ne, *]
  · simp only [finset_walk_length, set_walk_length_succ_eq, Finset.coe_bUnion, Finset.mem_coe,
      Finset.mem_univ, Set.Union_true]
    ext p
    simp only [mem_neighbor_set, Finset.coe_map, embedding.coe_fn_mk, Set.Union_coe_set,
      Set.mem_Union, Set.mem_image, Finset.mem_coe, Set.mem_setOf_eq]
    congr with w
    congr with h
    congr with q
    have := set.ext_iff.mp (ih w v) q
    simp only [Finset.mem_coe, Set.mem_setOf_eq] at this
    rw [← this]
    rfl
#align simple_graph.coe_finset_walk_length_eq SimpleGraph.coe_finset_walk_length_eq

variable {G}

theorem Walk.mem_finset_walk_length_iff_length_eq {n : ℕ} {u v : V} (p : G.Walk u v) :
    p ∈ G.finsetWalkLength n u v ↔ p.length = n :=
  Set.ext_iff.mp (G.coe_finset_walk_length_eq n u v) p
#align
  simple_graph.walk.mem_finset_walk_length_iff_length_eq SimpleGraph.Walk.mem_finset_walk_length_iff_length_eq

variable (G)

instance fintypeSetWalkLength (u v : V) (n : ℕ) : Fintype { p : G.Walk u v | p.length = n } :=
  (Fintype.ofFinset (G.finsetWalkLength n u v)) fun p => by
    rw [← Finset.mem_coe, coe_finset_walk_length_eq]
#align simple_graph.fintype_set_walk_length SimpleGraph.fintypeSetWalkLength

theorem set_walk_length_to_finset_eq (n : ℕ) (u v : V) :
    { p : G.Walk u v | p.length = n }.toFinset = G.finsetWalkLength n u v := by
  ext p
  simp [← coe_finset_walk_length_eq]
#align simple_graph.set_walk_length_to_finset_eq SimpleGraph.set_walk_length_to_finset_eq

/- See `simple_graph.adj_matrix_pow_apply_eq_card_walk` for the cardinality in terms of the `n`th
power of the adjacency matrix. -/
theorem card_set_walk_length_eq (u v : V) (n : ℕ) :
    Fintype.card { p : G.Walk u v | p.length = n } = (G.finsetWalkLength n u v).card :=
  (Fintype.card_of_finset (G.finsetWalkLength n u v)) fun p => by
    rw [← Finset.mem_coe, coe_finset_walk_length_eq]
#align simple_graph.card_set_walk_length_eq SimpleGraph.card_set_walk_length_eq

instance fintypeSetPathLength (u v : V) (n : ℕ) :
    Fintype { p : G.Walk u v | p.IsPath ∧ p.length = n } :=
  Fintype.ofFinset ((G.finsetWalkLength n u v).filter Walk.IsPath) <| by
    simp [walk.mem_finset_walk_length_iff_length_eq, and_comm']
#align simple_graph.fintype_set_path_length SimpleGraph.fintypeSetPathLength

end LocallyFinite

section Finite

variable [Fintype V] [DecidableRel G.Adj]

theorem reachable_iff_exists_finset_walk_length_nonempty (u v : V) :
    G.Reachable u v ↔ ∃ n : Fin (Fintype.card V), (G.finsetWalkLength n u v).Nonempty := by
  constructor
  · intro r
    refine' r.elim_path fun p => _
    refine' ⟨⟨_, p.is_path.length_lt⟩, p, _⟩
    simp [walk.mem_finset_walk_length_iff_length_eq]
  · rintro ⟨_, p, _⟩
    use p
#align
  simple_graph.reachable_iff_exists_finset_walk_length_nonempty SimpleGraph.reachable_iff_exists_finset_walk_length_nonempty

instance : DecidableRel G.Reachable := fun u v =>
  decidable_of_iff' _ (reachable_iff_exists_finset_walk_length_nonempty G u v)

instance : Fintype G.ConnectedComponent :=
  @Quotient.fintype _ _ G.reachableSetoid (inferInstance : DecidableRel G.Reachable)

instance : Decidable G.Preconnected := by 
  unfold preconnected
  infer_instance

instance : Decidable G.Connected := by
  rw [connected_iff, ← Finset.univ_nonempty_iff]
  exact And.decidable

end Finite

end WalkCounting

section BridgeEdges

/-! ### Bridge edges -/


/-- An edge of a graph is a *bridge* if, after removing it, its incident vertices
are no longer reachable from one another. -/
def IsBridge (G : SimpleGraph V) (e : Sym2 V) : Prop :=
  e ∈ G.edgeSet ∧
    Sym2.lift ⟨fun v w => ¬(G \ fromEdgeSet {e}).Reachable v w, by simp [reachable_comm]⟩ e
#align simple_graph.is_bridge SimpleGraph.IsBridge

theorem is_bridge_iff {u v : V} :
    G.IsBridge ⟦(u, v)⟧ ↔ G.Adj u v ∧ ¬(G \ fromEdgeSet {⟦(u, v)⟧}).Reachable u v :=
  Iff.rfl
#align simple_graph.is_bridge_iff SimpleGraph.is_bridge_iff

theorem reachable_delete_edges_iff_exists_walk {v w : V} :
    (G \ fromEdgeSet {⟦(v, w)⟧}).Reachable v w ↔ ∃ p : G.Walk v w, ¬⟦(v, w)⟧ ∈ p.edges := by
  constructor
  · rintro ⟨p⟩
    use p.map (hom.map_spanning_subgraphs (by simp))
    simp_rw [walk.edges_map, List.mem_map, hom.map_spanning_subgraphs_apply, Sym2.map_id', id.def]
    rintro ⟨e, h, rfl⟩
    simpa using p.edges_subset_edge_set h
  · rintro ⟨p, h⟩
    refine' ⟨p.transfer _ fun e ep => _⟩
    simp only [edge_set_sdiff, edge_set_from_edge_set, edge_set_sdiff_sdiff_is_diag, Set.mem_diff,
      Set.mem_singleton_iff]
    exact ⟨p.edges_subset_edge_set ep, fun h' => h (h' ▸ ep)⟩
#align
  simple_graph.reachable_delete_edges_iff_exists_walk SimpleGraph.reachable_delete_edges_iff_exists_walk

theorem is_bridge_iff_adj_and_forall_walk_mem_edges {v w : V} :
    G.IsBridge ⟦(v, w)⟧ ↔ G.Adj v w ∧ ∀ p : G.Walk v w, ⟦(v, w)⟧ ∈ p.edges := by
  rw [is_bridge_iff, and_congr_right']
  rw [reachable_delete_edges_iff_exists_walk, not_exists_not]
#align
  simple_graph.is_bridge_iff_adj_and_forall_walk_mem_edges SimpleGraph.is_bridge_iff_adj_and_forall_walk_mem_edges

theorem ReachableDeleteEdgesIffExistsCycle.aux [DecidableEq V] {u v w : V}
    (hb : ∀ p : G.Walk v w, ⟦(v, w)⟧ ∈ p.edges) (c : G.Walk u u) (hc : c.IsTrail)
    (he : ⟦(v, w)⟧ ∈ c.edges)
    (hw : w ∈ (c.takeUntil v (c.fst_mem_support_of_mem_edges he)).support) : False := by
  have hv := c.fst_mem_support_of_mem_edges he
  -- decompose c into
  --      puw     pwv     pvu
  --   u ----> w ----> v ----> u
  let puw := (c.take_until v hv).takeUntil w hw
  let pwv := (c.take_until v hv).dropUntil w hw
  let pvu := c.drop_until v hv
  have : c = (puw.append pwv).append pvu := by simp
  -- We have two walks from v to w
  --      pvu     puw
  --   v ----> u ----> w
  --   |               ^
  --    `-------------'
  --      pwv.reverse
  -- so they both contain the edge ⟦(v, w)⟧, but that's a contradiction since c is a trail.
  have hbq := hb (pvu.append puw)
  have hpq' := hb pwv.reverse
  rw [walk.edges_reverse, List.mem_reverse] at hpq'
  rw [walk.is_trail_def, this, walk.edges_append, walk.edges_append, List.nodup_append_comm, ←
    List.append_assoc, ← walk.edges_append] at hc
  exact List.disjoint_of_nodup_append hc hbq hpq'
#align
  simple_graph.reachable_delete_edges_iff_exists_cycle.aux SimpleGraph.ReachableDeleteEdgesIffExistsCycle.aux

theorem adj_and_reachable_delete_edges_iff_exists_cycle {v w : V} :
    G.Adj v w ∧ (G \ fromEdgeSet {⟦(v, w)⟧}).Reachable v w ↔
      ∃ (u : V)(p : G.Walk u u), p.IsCycle ∧ ⟦(v, w)⟧ ∈ p.edges :=
  by
  classical 
    rw [reachable_delete_edges_iff_exists_walk]
    constructor
    · rintro ⟨h, p, hp⟩
      refine' ⟨w, walk.cons h.symm p.to_path, _, _⟩
      · apply path.cons_is_cycle
        rw [Sym2.eq_swap]
        intro h
        exact absurd (walk.edges_to_path_subset p h) hp
      simp only [Sym2.eq_swap, walk.edges_cons, List.mem_cons_iff, eq_self_iff_true, true_or_iff]
    · rintro ⟨u, c, hc, he⟩
      have hvc : v ∈ c.support := walk.fst_mem_support_of_mem_edges c he
      have hwc : w ∈ c.support := walk.snd_mem_support_of_mem_edges c he
      let puv := c.take_until v hvc
      let pvu := c.drop_until v hvc
      obtain hw | hw' : w ∈ puv.support ∨ w ∈ pvu.support := by
        rwa [← walk.mem_support_append_iff, walk.take_spec]
      · by_contra' h
        specialize h (c.adj_of_mem_edges he)
        exact reachable_delete_edges_iff_exists_cycle.aux h c hc.to_trail he hw
      · by_contra' hb
        specialize hb (c.adj_of_mem_edges he)
        have hb' : ∀ p : G.walk w v, ⟦(w, v)⟧ ∈ p.edges := by
          intro p
          simpa [Sym2.eq_swap] using hb p.reverse
        apply
          reachable_delete_edges_iff_exists_cycle.aux hb' (pvu.append puv) (hc.to_trail.rotate hvc)
            _ (walk.start_mem_support _)
        rwa [walk.edges_append, List.mem_append, or_comm', ← List.mem_append, ← walk.edges_append,
          walk.take_spec, Sym2.eq_swap]
#align
  simple_graph.adj_and_reachable_delete_edges_iff_exists_cycle SimpleGraph.adj_and_reachable_delete_edges_iff_exists_cycle

theorem is_bridge_iff_adj_and_forall_cycle_not_mem {v w : V} :
    G.IsBridge ⟦(v, w)⟧ ↔ G.Adj v w ∧ ∀ ⦃u : V⦄ (p : G.Walk u u), p.IsCycle → ⟦(v, w)⟧ ∉ p.edges :=
  by 
  rw [is_bridge_iff, and_congr_right_iff]
  intro h
  rw [← not_iff_not]
  push_neg
  rw [← adj_and_reachable_delete_edges_iff_exists_cycle]
  simp only [h, true_and_iff]
#align
  simple_graph.is_bridge_iff_adj_and_forall_cycle_not_mem SimpleGraph.is_bridge_iff_adj_and_forall_cycle_not_mem

theorem is_bridge_iff_mem_and_forall_cycle_not_mem {e : Sym2 V} :
    G.IsBridge e ↔ e ∈ G.edgeSet ∧ ∀ ⦃u : V⦄ (p : G.Walk u u), p.IsCycle → e ∉ p.edges :=
  Sym2.ind (fun v w => is_bridge_iff_adj_and_forall_cycle_not_mem) e
#align
  simple_graph.is_bridge_iff_mem_and_forall_cycle_not_mem SimpleGraph.is_bridge_iff_mem_and_forall_cycle_not_mem

end BridgeEdges

end SimpleGraph

