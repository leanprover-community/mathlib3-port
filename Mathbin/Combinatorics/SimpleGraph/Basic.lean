import Mathbin.Data.Fintype.Basic 
import Mathbin.Data.Rel 
import Mathbin.Data.Set.Finite 
import Mathbin.Data.Sym.Sym2

/-!
# Simple graphs

This module defines simple graphs on a vertex type `V` as an
irreflexive symmetric relation.

There is a basic API for locally finite graphs and for graphs with
finitely many vertices.

## Main definitions

* `simple_graph` is a structure for symmetric, irreflexive relations

* `neighbor_set` is the `set` of vertices adjacent to a given vertex

* `common_neighbors` is the intersection of the neighbor sets of two given vertices

* `neighbor_finset` is the `finset` of vertices adjacent to a given vertex,
   if `neighbor_set` is finite

* `incidence_set` is the `set` of edges containing a given vertex

* `incidence_finset` is the `finset` of edges containing a given vertex,
   if `incidence_set` is finite

* `homo`, `embedding`, and `iso` for graph homomorphisms, graph embeddings, and
  graph isomorphisms. Note that a graph embedding is a stronger notion than an
  injective graph homomorphism, since its image is an induced subgraph.

* `boolean_algebra` instance: Under the subgraph relation, `simple_graph` forms a `boolean_algebra`.
  In other words, this is the lattice of spanning subgraphs of the complete graph.

## Notations

* `→g`, `↪g`, and `≃g` for graph homomorphisms, graph embeddings, and graph isomorphisms,
  respectively.

## Implementation notes

* A locally finite graph is one with instances `Π v, fintype (G.neighbor_set v)`.

* Given instances `decidable_rel G.adj` and `fintype V`, then the graph
  is locally finite, too.

* Morphisms of graphs are abbreviations for `rel_hom`, `rel_embedding`, and `rel_iso`.
  To make use of pre-existing simp lemmas, definitions involving morphisms are
  abbreviations as well.

## Naming Conventions

* If the vertex type of a graph is finite, we refer to its cardinality as `card_verts`.

## Todo

* Upgrade `simple_graph.boolean_algebra` to a `complete_boolean_algebra`.

* This is the simplest notion of an unoriented graph.  This should
  eventually fit into a more complete combinatorics hierarchy which
  includes multigraphs and directed graphs.  We begin with simple graphs
  in order to start learning what the combinatorics hierarchy should
  look like.
-/


open Finset

universe u v w

/--
A simple graph is an irreflexive symmetric relation `adj` on a vertex type `V`.
The relation describes which pairs of vertices are adjacent.
There is exactly one edge for every pair of adjacent edges;
see `simple_graph.edge_set` for the corresponding edge set.
-/
@[ext]
structure SimpleGraph(V : Type u) where 
  Adj : V → V → Prop 
  symm : Symmetric adj :=  by 
  runTac 
    obviously 
  loopless : Irreflexive adj :=  by 
  runTac 
    obviously

/--
Construct the simple graph induced by the given relation.  It
symmetrizes the relation and makes it irreflexive.
-/
def SimpleGraph.fromRel {V : Type u} (r : V → V → Prop) : SimpleGraph V :=
  { Adj := fun a b => a ≠ b ∧ (r a b ∨ r b a), symm := fun a b ⟨hn, hr⟩ => ⟨hn.symm, hr.symm⟩,
    loopless := fun a ⟨hn, _⟩ => hn rfl }

noncomputable instance  {V : Type u} [Fintype V] : Fintype (SimpleGraph V) :=
  by 
    classical 
    exact Fintype.ofInjective SimpleGraph.Adj SimpleGraph.ext

@[simp]
theorem SimpleGraph.from_rel_adj {V : Type u} (r : V → V → Prop) (v w : V) :
  (SimpleGraph.fromRel r).Adj v w ↔ v ≠ w ∧ (r v w ∨ r w v) :=
  Iff.rfl

/-- The complete graph on a type `V` is the simple graph with all pairs of distinct vertices
adjacent. In `mathlib`, this is usually referred to as `⊤`. -/
def completeGraph (V : Type u) : SimpleGraph V :=
  { Adj := Ne }

/-- The graph with no edges on a given vertex type `V`. `mathlib` prefers the notation `⊥`. -/
def emptyGraph (V : Type u) : SimpleGraph V :=
  { Adj := fun i j => False }

namespace SimpleGraph

variable{V : Type u}{W : Type v}{X : Type w}(G : SimpleGraph V)(G' : SimpleGraph W)

@[simp]
theorem irrefl {v : V} : ¬G.adj v v :=
  G.loopless v

theorem adj_comm (u v : V) : G.adj u v ↔ G.adj v u :=
  ⟨fun x => G.symm x, fun x => G.symm x⟩

@[symm]
theorem adj_symm {u v : V} (h : G.adj u v) : G.adj v u :=
  G.symm h

theorem ne_of_adj {a b : V} (hab : G.adj a b) : a ≠ b :=
  by 
    rintro rfl 
    exact G.irrefl hab

section Order

/-- The relation that one `simple_graph` is a subgraph of another.
Note that this should be spelled `≤`. -/
def is_subgraph (x y : SimpleGraph V) : Prop :=
  ∀ ⦃v w : V⦄, x.adj v w → y.adj v w

instance  : LE (SimpleGraph V) :=
  ⟨is_subgraph⟩

@[simp]
theorem is_subgraph_eq_le : (is_subgraph : SimpleGraph V → SimpleGraph V → Prop) = (· ≤ ·) :=
  rfl

/-- The supremum of two graphs `x ⊔ y` has edges where either `x` or `y` have edges. -/
instance  : HasSup (SimpleGraph V) :=
  ⟨fun x y =>
      { Adj := x.adj⊔y.adj,
        symm :=
          fun v w h =>
            by 
              rwa [Pi.sup_apply, Pi.sup_apply, x.adj_comm, y.adj_comm] }⟩

@[simp]
theorem sup_adj (x y : SimpleGraph V) (v w : V) : (x⊔y).Adj v w ↔ x.adj v w ∨ y.adj v w :=
  Iff.rfl

/-- The infinum of two graphs `x ⊓ y` has edges where both `x` and `y` have edges. -/
instance  : HasInf (SimpleGraph V) :=
  ⟨fun x y =>
      { Adj := x.adj⊓y.adj,
        symm :=
          fun v w h =>
            by 
              rwa [Pi.inf_apply, Pi.inf_apply, x.adj_comm, y.adj_comm] }⟩

@[simp]
theorem inf_adj (x y : SimpleGraph V) (v w : V) : (x⊓y).Adj v w ↔ x.adj v w ∧ y.adj v w :=
  Iff.rfl

/--
We define `Gᶜ` to be the `simple_graph V` such that no two adjacent vertices in `G`
are adjacent in the complement, and every nonadjacent pair of vertices is adjacent
(still ensuring that vertices are not adjacent to themselves).
-/
instance  : HasCompl (SimpleGraph V) :=
  ⟨fun G =>
      { Adj := fun v w => v ≠ w ∧ ¬G.adj v w,
        symm :=
          fun v w ⟨hne, _⟩ =>
            ⟨hne.symm,
              by 
                rwa [adj_comm]⟩,
        loopless := fun v ⟨hne, _⟩ => (hne rfl).elim }⟩

@[simp]
theorem compl_adj (G : SimpleGraph V) (v w : V) : («expr ᶜ» G).Adj v w ↔ v ≠ w ∧ ¬G.adj v w :=
  Iff.rfl

/-- The difference of two graphs `x / y` has the edges of `x` with the edges of `y` removed. -/
instance  : HasSdiff (SimpleGraph V) :=
  ⟨fun x y =>
      { Adj := x.adj \ y.adj,
        symm :=
          fun v w h =>
            by 
              change x.adj w v ∧ ¬y.adj w v <;> rwa [x.adj_comm, y.adj_comm] }⟩

@[simp]
theorem sdiff_adj (x y : SimpleGraph V) (v w : V) : (x \ y).Adj v w ↔ x.adj v w ∧ ¬y.adj v w :=
  Iff.rfl

instance  : BooleanAlgebra (SimpleGraph V) :=
  { PartialOrderₓ.lift adj ext with le := · ≤ ·, sup := ·⊔·, inf := ·⊓·, Compl := HasCompl.compl, sdiff := · \ ·,
    top := completeGraph V, bot := emptyGraph V, le_top := fun x v w h => x.ne_of_adj h,
    bot_le := fun x v w h => h.elim, sup_le := fun x y z hxy hyz v w h => h.cases_on (fun h => hxy h) fun h => hyz h,
    sdiff_eq :=
      fun x y =>
        by 
          ext v w 
          refine' ⟨fun h => ⟨h.1, ⟨_, h.2⟩⟩, fun h => ⟨h.1, h.2.2⟩⟩
          rintro rfl 
          exact x.irrefl h.1,
    sup_inf_sdiff :=
      fun a b =>
        by 
          ext v w 
          refine' ⟨fun h => _, fun h' => _⟩
          obtain ⟨ha, _⟩ | ⟨ha, _⟩ := h <;> exact ha 
          byCases' b.adj v w <;>
            first |
              exact Or.inl ⟨h', h⟩|
              exact Or.inr ⟨h', h⟩,
    inf_inf_sdiff :=
      fun a b =>
        by 
          ext v w 
          exact ⟨fun ⟨⟨_, hb⟩, ⟨_, hb'⟩⟩ => hb' hb, fun h => h.elim⟩,
    le_sup_left := fun x y v w h => Or.inl h, le_sup_right := fun x y v w h => Or.inr h,
    le_inf := fun x y z hxy hyz v w h => ⟨hxy h, hyz h⟩,
    le_sup_inf :=
      fun a b c v w h => Or.dcases_on h.2 Or.inl$ (Or.dcases_on h.1 fun h _ => Or.inl h)$ fun hb hc => Or.inr ⟨hb, hc⟩,
    inf_compl_le_bot := fun a v w h => False.elim$ h.2.2 h.1,
    top_le_sup_compl :=
      fun a v w ne =>
        by 
          byCases' a.adj v w 
          exact Or.inl h 
          exact Or.inr ⟨Ne, h⟩,
    inf_le_left := fun x y v w h => h.1, inf_le_right := fun x y v w h => h.2 }

@[simp]
theorem top_adj (v w : V) : (⊤ : SimpleGraph V).Adj v w ↔ v ≠ w :=
  Iff.rfl

@[simp]
theorem bot_adj (v w : V) : (⊥ : SimpleGraph V).Adj v w ↔ False :=
  Iff.rfl

@[simp]
theorem complete_graph_eq_top (V : Type u) : completeGraph V = ⊤ :=
  rfl

@[simp]
theorem empty_graph_eq_bot (V : Type u) : emptyGraph V = ⊥ :=
  rfl

instance  (V : Type u) : Inhabited (SimpleGraph V) :=
  ⟨⊤⟩

section Decidable

variable(V)(H : SimpleGraph V)[DecidableRel G.adj][DecidableRel H.adj]

instance bot.adj_decidable : DecidableRel (⊥ : SimpleGraph V).Adj :=
  fun v w => Decidable.false

instance sup.adj_decidable : DecidableRel (G⊔H).Adj :=
  fun v w => Or.decidable

instance inf.adj_decidable : DecidableRel (G⊓H).Adj :=
  fun v w => And.decidable

instance sdiff.adj_decidable : DecidableRel (G \ H).Adj :=
  fun v w => And.decidable

variable[DecidableEq V]

instance top.adj_decidable : DecidableRel (⊤ : SimpleGraph V).Adj :=
  fun v w => Not.decidable

instance compl.adj_decidable : DecidableRel («expr ᶜ» G).Adj :=
  fun v w => And.decidable

end Decidable

end Order

/-- `G.support` is the set of vertices that form edges in `G`. -/
def support : Set V :=
  Rel.Dom G.adj

theorem mem_support {v : V} : v ∈ G.support ↔ ∃ w, G.adj v w :=
  Iff.rfl

theorem support_mono {G G' : SimpleGraph V} (h : G ≤ G') : G.support ⊆ G'.support :=
  Rel.dom_mono h

/-- `G.neighbor_set v` is the set of vertices adjacent to `v` in `G`. -/
def neighbor_set (v : V) : Set V :=
  SetOf (G.adj v)

instance neighbor_set.mem_decidable (v : V) [DecidableRel G.adj] : DecidablePred (· ∈ G.neighbor_set v) :=
  by 
    unfold neighbor_set 
    infer_instance

/--
The edges of G consist of the unordered pairs of vertices related by
`G.adj`.

The way `edge_set` is defined is such that `mem_edge_set` is proved by `refl`.
(That is, `⟦(v, w)⟧ ∈ G.edge_set` is definitionally equal to `G.adj v w`.)
-/
def edge_set : Set (Sym2 V) :=
  Sym2.FromRel G.symm

/--
The `incidence_set` is the set of edges incident to a given vertex.
-/
def incidence_set (v : V) : Set (Sym2 V) :=
  { e∈G.edge_set | v ∈ e }

theorem incidence_set_subset (v : V) : G.incidence_set v ⊆ G.edge_set :=
  fun _ h => h.1

@[simp]
theorem mem_edge_set {v w : V} : «expr⟦ ⟧» (v, w) ∈ G.edge_set ↔ G.adj v w :=
  Iff.rfl

/--
Two vertices are adjacent iff there is an edge between them.  The
condition `v ≠ w` ensures they are different endpoints of the edge,
which is necessary since when `v = w` the existential
`∃ (e ∈ G.edge_set), v ∈ e ∧ w ∈ e` is satisfied by every edge
incident to `v`.
-/
theorem adj_iff_exists_edge {v w : V} : G.adj v w ↔ v ≠ w ∧ ∃ (e : _)(_ : e ∈ G.edge_set), v ∈ e ∧ w ∈ e :=
  by 
    refine' ⟨fun _ => ⟨G.ne_of_adj ‹_›, «expr⟦ ⟧» (v, w), _⟩, _⟩
    ·
      simpa
    ·
      rintro ⟨hne, e, he, hv⟩
      rw [Sym2.elems_iff_eq hne] at hv 
      subst e 
      rwa [mem_edge_set] at he

theorem edge_other_ne {e : Sym2 V} (he : e ∈ G.edge_set) {v : V} (h : v ∈ e) : h.other ≠ v :=
  by 
    erw [←Sym2.mem_other_spec h, Sym2.eq_swap] at he 
    exact G.ne_of_adj he

instance decidable_mem_edge_set [DecidableRel G.adj] : DecidablePred (· ∈ G.edge_set) :=
  Sym2.FromRel.decidablePred _

instance edges_fintype [DecidableEq V] [Fintype V] [DecidableRel G.adj] : Fintype G.edge_set :=
  Subtype.fintype _

instance decidable_mem_incidence_set [DecidableEq V] [DecidableRel G.adj] (v : V) :
  DecidablePred (· ∈ G.incidence_set v) :=
  fun e => And.decidable

/--
The `edge_set` of the graph as a `finset`.
-/
def edge_finset [DecidableEq V] [Fintype V] [DecidableRel G.adj] : Finset (Sym2 V) :=
  Set.toFinset G.edge_set

@[simp]
theorem mem_edge_finset [DecidableEq V] [Fintype V] [DecidableRel G.adj] (e : Sym2 V) :
  e ∈ G.edge_finset ↔ e ∈ G.edge_set :=
  Set.mem_to_finset

@[simp]
theorem edge_set_univ_card [DecidableEq V] [Fintype V] [DecidableRel G.adj] :
  (univ : Finset G.edge_set).card = G.edge_finset.card :=
  Fintype.card_of_subtype G.edge_finset (mem_edge_finset _)

@[simp]
theorem mem_neighbor_set (v w : V) : w ∈ G.neighbor_set v ↔ G.adj v w :=
  Iff.rfl

@[simp]
theorem mem_incidence_set (v w : V) : «expr⟦ ⟧» (v, w) ∈ G.incidence_set v ↔ G.adj v w :=
  by 
    simp [incidence_set]

theorem mem_incidence_iff_neighbor {v w : V} : «expr⟦ ⟧» (v, w) ∈ G.incidence_set v ↔ w ∈ G.neighbor_set v :=
  by 
    simp only [mem_incidence_set, mem_neighbor_set]

theorem adj_incidence_set_inter {v : V} {e : Sym2 V} (he : e ∈ G.edge_set) (h : v ∈ e) :
  G.incidence_set v ∩ G.incidence_set h.other = {e} :=
  by 
    ext e' 
    simp only [incidence_set, Set.mem_sep_eq, Set.mem_inter_eq, Set.mem_singleton_iff]
    split 
    ·
      intro h' 
      rw [←Sym2.mem_other_spec h]
      exact (Sym2.elems_iff_eq (edge_other_ne G he h).symm).mp ⟨h'.1.2, h'.2.2⟩
    ·
      rintro rfl 
      use he, h, he 
      apply Sym2.mem_other_mem

theorem compl_neighbor_set_disjoint (G : SimpleGraph V) (v : V) :
  Disjoint (G.neighbor_set v) ((«expr ᶜ» G).NeighborSet v) :=
  by 
    rw [Set.disjoint_iff]
    rintro w ⟨h, h'⟩
    rw [mem_neighbor_set, compl_adj] at h' 
    exact h'.2 h

-- error in Combinatorics.SimpleGraph.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem neighbor_set_union_compl_neighbor_set_eq
(G : simple_graph V)
(v : V) : «expr = »(«expr ∪ »(G.neighbor_set v, «expr ᶜ»(G).neighbor_set v), «expr ᶜ»({v})) :=
begin
  ext [] [ident w] [],
  have [ident h] [] [":=", expr @ne_of_adj _ G],
  simp_rw ["[", expr set.mem_union, ",", expr mem_neighbor_set, ",", expr compl_adj, ",", expr set.mem_compl_eq, ",", expr set.mem_singleton_iff, "]"] [],
  tauto []
end

/--
The set of common neighbors between two vertices `v` and `w` in a graph `G` is the
intersection of the neighbor sets of `v` and `w`.
-/
def common_neighbors (v w : V) : Set V :=
  G.neighbor_set v ∩ G.neighbor_set w

theorem common_neighbors_eq (v w : V) : G.common_neighbors v w = G.neighbor_set v ∩ G.neighbor_set w :=
  rfl

theorem mem_common_neighbors {u v w : V} : u ∈ G.common_neighbors v w ↔ G.adj v u ∧ G.adj w u :=
  by 
    simp [common_neighbors]

theorem common_neighbors_symm (v w : V) : G.common_neighbors v w = G.common_neighbors w v :=
  by 
    rw [common_neighbors, Set.inter_comm]
    rfl

theorem not_mem_common_neighbors_left (v w : V) : v ∉ G.common_neighbors v w :=
  fun h => ne_of_adj G h.1 rfl

theorem not_mem_common_neighbors_right (v w : V) : w ∉ G.common_neighbors v w :=
  fun h => ne_of_adj G h.2 rfl

theorem common_neighbors_subset_neighbor_set (v w : V) : G.common_neighbors v w ⊆ G.neighbor_set v :=
  by 
    simp [common_neighbors]

instance decidable_mem_common_neighbors [DecidableRel G.adj] (v w : V) : DecidablePred (· ∈ G.common_neighbors v w) :=
  fun a => And.decidable

section Incidence

variable[DecidableEq V]

/--
Given an edge incident to a particular vertex, get the other vertex on the edge.
-/
def other_vertex_of_incident {v : V} {e : Sym2 V} (h : e ∈ G.incidence_set v) : V :=
  h.2.other'

theorem edge_mem_other_incident_set {v : V} {e : Sym2 V} (h : e ∈ G.incidence_set v) :
  e ∈ G.incidence_set (G.other_vertex_of_incident h) :=
  by 
    use h.1
    simp [other_vertex_of_incident, Sym2.mem_other_mem']

theorem incidence_other_prop {v : V} {e : Sym2 V} (h : e ∈ G.incidence_set v) :
  G.other_vertex_of_incident h ∈ G.neighbor_set v :=
  by 
    cases' h with he hv 
    rwa [←Sym2.mem_other_spec' hv, mem_edge_set] at he

@[simp]
theorem incidence_other_neighbor_edge {v w : V} (h : w ∈ G.neighbor_set v) :
  G.other_vertex_of_incident (G.mem_incidence_iff_neighbor.mpr h) = w :=
  Sym2.congr_right.mp (Sym2.mem_other_spec' (G.mem_incidence_iff_neighbor.mpr h).right)

/--
There is an equivalence between the set of edges incident to a given
vertex and the set of vertices adjacent to the vertex.
-/
@[simps]
def incidence_set_equiv_neighbor_set (v : V) : G.incidence_set v ≃ G.neighbor_set v :=
  { toFun := fun e => ⟨G.other_vertex_of_incident e.2, G.incidence_other_prop e.2⟩,
    invFun := fun w => ⟨«expr⟦ ⟧» (v, w.1), G.mem_incidence_iff_neighbor.mpr w.2⟩,
    left_inv :=
      fun x =>
        by 
          simp [other_vertex_of_incident],
    right_inv :=
      fun ⟨w, hw⟩ =>
        by 
          simp  }

end Incidence

section FiniteAt

/-!
## Finiteness at a vertex

This section contains definitions and lemmas concerning vertices that
have finitely many adjacent vertices.  We denote this condition by
`fintype (G.neighbor_set v)`.

We define `G.neighbor_finset v` to be the `finset` version of `G.neighbor_set v`.
Use `neighbor_finset_eq_filter` to rewrite this definition as a `filter`.
-/


variable(v : V)[Fintype (G.neighbor_set v)]

/--
`G.neighbors v` is the `finset` version of `G.adj v` in case `G` is
locally finite at `v`.
-/
def neighbor_finset : Finset V :=
  (G.neighbor_set v).toFinset

@[simp]
theorem mem_neighbor_finset (w : V) : w ∈ G.neighbor_finset v ↔ G.adj v w :=
  Set.mem_to_finset

/--
`G.degree v` is the number of vertices adjacent to `v`.
-/
def degree : ℕ :=
  (G.neighbor_finset v).card

@[simp]
theorem card_neighbor_set_eq_degree : Fintype.card (G.neighbor_set v) = G.degree v :=
  (Set.to_finset_card _).symm

theorem degree_pos_iff_exists_adj : 0 < G.degree v ↔ ∃ w, G.adj v w :=
  by 
    simp only [degree, card_pos, Finset.Nonempty, mem_neighbor_finset]

instance incidence_set_fintype [DecidableEq V] : Fintype (G.incidence_set v) :=
  Fintype.ofEquiv (G.neighbor_set v) (G.incidence_set_equiv_neighbor_set v).symm

/--
This is the `finset` version of `incidence_set`.
-/
def incidence_finset [DecidableEq V] : Finset (Sym2 V) :=
  (G.incidence_set v).toFinset

@[simp]
theorem card_incidence_set_eq_degree [DecidableEq V] : Fintype.card (G.incidence_set v) = G.degree v :=
  by 
    rw [Fintype.card_congr (G.incidence_set_equiv_neighbor_set v)]
    simp 

@[simp]
theorem mem_incidence_finset [DecidableEq V] (e : Sym2 V) : e ∈ G.incidence_finset v ↔ e ∈ G.incidence_set v :=
  Set.mem_to_finset

end FiniteAt

section LocallyFinite

/--
A graph is locally finite if every vertex has a finite neighbor set.
-/
@[reducible]
def locally_finite :=
  ∀ (v : V), Fintype (G.neighbor_set v)

variable[locally_finite G]

/--
A locally finite simple graph is regular of degree `d` if every vertex has degree `d`.
-/
def is_regular_of_degree (d : ℕ) : Prop :=
  ∀ (v : V), G.degree v = d

theorem is_regular_of_degree_eq {d : ℕ} (h : G.is_regular_of_degree d) (v : V) : G.degree v = d :=
  h v

end LocallyFinite

section Finite

variable[Fintype V]

instance neighbor_set_fintype [DecidableRel G.adj] (v : V) : Fintype (G.neighbor_set v) :=
  @Subtype.fintype _ _
    (by 
      simpRw [mem_neighbor_set]
      infer_instance)
    _

theorem neighbor_finset_eq_filter {v : V} [DecidableRel G.adj] : G.neighbor_finset v = Finset.univ.filter (G.adj v) :=
  by 
    ext 
    simp 

@[simp]
theorem complete_graph_degree [DecidableEq V] (v : V) : (⊤ : SimpleGraph V).degree v = Fintype.card V - 1 :=
  by 
    convert univ.card.pred_eq_sub_one 
    erw [degree, neighbor_finset_eq_filter, filter_ne, card_erase_of_mem (mem_univ v)]

theorem complete_graph_is_regular [DecidableEq V] : (⊤ : SimpleGraph V).IsRegularOfDegree (Fintype.card V - 1) :=
  by 
    intro v 
    simp 

/--
The minimum degree of all vertices (and `0` if there are no vertices).
The key properties of this are given in `exists_minimal_degree_vertex`, `min_degree_le_degree`
and `le_min_degree_of_forall_le_degree`.
-/
def min_degree [DecidableRel G.adj] : ℕ :=
  Option.getOrElse (univ.Image fun v => G.degree v).min 0

/--
There exists a vertex of minimal degree. Note the assumption of being nonempty is necessary, as
the lemma implies there exists a vertex.
-/
theorem exists_minimal_degree_vertex [DecidableRel G.adj] [Nonempty V] : ∃ v, G.min_degree = G.degree v :=
  by 
    obtain ⟨t, ht : _ = _⟩ := min_of_nonempty (univ_nonempty.image fun v => G.degree v)
    obtain ⟨v, _, rfl⟩ := mem_image.mp (mem_of_min ht)
    refine'
      ⟨v,
        by 
          simp [min_degree, ht]⟩

-- error in Combinatorics.SimpleGraph.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The minimum degree in the graph is at most the degree of any particular vertex. -/
theorem min_degree_le_degree [decidable_rel G.adj] (v : V) : «expr ≤ »(G.min_degree, G.degree v) :=
begin
  obtain ["⟨", ident t, ",", ident ht, "⟩", ":=", expr finset.min_of_mem (mem_image_of_mem (λ
     v, G.degree v) (mem_univ v))],
  have [] [] [":=", expr finset.min_le_of_mem (mem_image_of_mem _ (mem_univ v)) ht],
  rw [expr option.mem_def] ["at", ident ht],
  rwa ["[", expr min_degree, ",", expr ht, ",", expr option.get_or_else_some, "]"] []
end

/--
In a nonempty graph, if `k` is at most the degree of every vertex, it is at most the minimum
degree. Note the assumption that the graph is nonempty is necessary as long as `G.min_degree` is
defined to be a natural.
-/
theorem le_min_degree_of_forall_le_degree [DecidableRel G.adj] [Nonempty V] (k : ℕ) (h : ∀ v, k ≤ G.degree v) :
  k ≤ G.min_degree :=
  by 
    rcases G.exists_minimal_degree_vertex with ⟨v, hv⟩
    rw [hv]
    apply h

/--
The maximum degree of all vertices (and `0` if there are no vertices).
The key properties of this are given in `exists_maximal_degree_vertex`, `degree_le_max_degree`
and `max_degree_le_of_forall_degree_le`.
-/
def max_degree [DecidableRel G.adj] : ℕ :=
  Option.getOrElse (univ.Image fun v => G.degree v).max 0

-- error in Combinatorics.SimpleGraph.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
There exists a vertex of maximal degree. Note the assumption of being nonempty is necessary, as
the lemma implies there exists a vertex.
-/
theorem exists_maximal_degree_vertex
[decidable_rel G.adj]
[nonempty V] : «expr∃ , »((v), «expr = »(G.max_degree, G.degree v)) :=
begin
  obtain ["⟨", ident t, ",", ident ht, "⟩", ":=", expr max_of_nonempty (univ_nonempty.image (λ v, G.degree v))],
  have [ident ht₂] [] [":=", expr mem_of_max ht],
  simp [] [] ["only"] ["[", expr mem_image, ",", expr mem_univ, ",", expr exists_prop_of_true, "]"] [] ["at", ident ht₂],
  rcases [expr ht₂, "with", "⟨", ident v, ",", ident rfl, "⟩"],
  rw [expr option.mem_def] ["at", ident ht],
  refine [expr ⟨v, _⟩],
  rw ["[", expr max_degree, ",", expr ht, "]"] [],
  refl
end

-- error in Combinatorics.SimpleGraph.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The maximum degree in the graph is at least the degree of any particular vertex. -/
theorem degree_le_max_degree [decidable_rel G.adj] (v : V) : «expr ≤ »(G.degree v, G.max_degree) :=
begin
  obtain ["⟨", ident t, ",", ident ht, ":", expr «expr = »(_, _), "⟩", ":=", expr finset.max_of_mem (mem_image_of_mem (λ
     v, G.degree v) (mem_univ v))],
  have [] [] [":=", expr finset.le_max_of_mem (mem_image_of_mem _ (mem_univ v)) ht],
  rwa ["[", expr max_degree, ",", expr ht, ",", expr option.get_or_else_some, "]"] []
end

-- error in Combinatorics.SimpleGraph.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
In a graph, if `k` is at least the degree of every vertex, then it is at least the maximum
degree.
-/
theorem max_degree_le_of_forall_degree_le
[decidable_rel G.adj]
(k : exprℕ())
(h : ∀ v, «expr ≤ »(G.degree v, k)) : «expr ≤ »(G.max_degree, k) :=
begin
  by_cases [expr hV, ":", expr (univ : finset V).nonempty],
  { haveI [] [":", expr nonempty V] [":=", expr univ_nonempty_iff.mp hV],
    obtain ["⟨", ident v, ",", ident hv, "⟩", ":=", expr G.exists_maximal_degree_vertex],
    rw [expr hv] [],
    apply [expr h] },
  { rw [expr not_nonempty_iff_eq_empty] ["at", ident hV],
    rw ["[", expr max_degree, ",", expr hV, ",", expr image_empty, "]"] [],
    exact [expr zero_le k] }
end

theorem degree_lt_card_verts [DecidableRel G.adj] (v : V) : G.degree v < Fintype.card V :=
  by 
    classical 
    apply Finset.card_lt_card 
    rw [Finset.ssubset_iff]
    exact
      ⟨v,
        by 
          simp ,
        Finset.subset_univ _⟩

/--
The maximum degree of a nonempty graph is less than the number of vertices. Note that the assumption
that `V` is nonempty is necessary, as otherwise this would assert the existence of a
natural number less than zero.
-/
theorem max_degree_lt_card_verts [DecidableRel G.adj] [Nonempty V] : G.max_degree < Fintype.card V :=
  by 
    cases' G.exists_maximal_degree_vertex with v hv 
    rw [hv]
    apply G.degree_lt_card_verts v

theorem card_common_neighbors_le_degree_left [DecidableRel G.adj] (v w : V) :
  Fintype.card (G.common_neighbors v w) ≤ G.degree v :=
  by 
    rw [←card_neighbor_set_eq_degree]
    exact Set.card_le_of_subset (Set.inter_subset_left _ _)

theorem card_common_neighbors_le_degree_right [DecidableRel G.adj] (v w : V) :
  Fintype.card (G.common_neighbors v w) ≤ G.degree w :=
  by 
    convert G.card_common_neighbors_le_degree_left w v using 3
    apply common_neighbors_symm

theorem card_common_neighbors_lt_card_verts [DecidableRel G.adj] (v w : V) :
  Fintype.card (G.common_neighbors v w) < Fintype.card V :=
  Nat.lt_of_le_of_ltₓ (G.card_common_neighbors_le_degree_left _ _) (G.degree_lt_card_verts v)

/--
If the condition `G.adj v w` fails, then `card_common_neighbors_le_degree` is
the best we can do in general.
-/
theorem adj.card_common_neighbors_lt_degree {G : SimpleGraph V} [DecidableRel G.adj] {v w : V} (h : G.adj v w) :
  Fintype.card (G.common_neighbors v w) < G.degree v :=
  by 
    classical 
    erw [←Set.to_finset_card]
    apply Finset.card_lt_card 
    rw [Finset.ssubset_iff]
    use w 
    split 
    ·
      rw [Set.mem_to_finset]
      apply not_mem_common_neighbors_right
    ·
      rw [Finset.insert_subset]
      split 
      ·
        simpa
      ·
        rw [neighbor_finset, ←Set.subset_iff_to_finset_subset]
        apply common_neighbors_subset_neighbor_set

end Finite

section Maps

/--
A graph homomorphism is a map on vertex sets that respects adjacency relations.

The notation `G →g G'` represents the type of graph homomorphisms.
-/
abbrev hom :=
  RelHom G.adj G'.adj

/--
A graph embedding is an embedding `f` such that for vertices `v w : V`,
`G.adj f(v) f(w) ↔ G.adj v w `. Its image is an induced subgraph of G'.

The notation `G ↪g G'` represents the type of graph embeddings.
-/
abbrev embedding :=
  RelEmbedding G.adj G'.adj

/--
A graph isomorphism is an bijective map on vertex sets that respects adjacency relations.

The notation `G ≃g G'` represents the type of graph isomorphisms.
-/
abbrev iso :=
  RelIso G.adj G'.adj

infixl:50 " →g " => hom

infixl:50 " ↪g " => embedding

infixl:50 " ≃g " => iso

namespace Hom

variable{G G'}(f : G →g G')

/-- The identity homomorphism from a graph to itself. -/
abbrev id : G →g G :=
  RelHom.id _

theorem map_adj {v w : V} (h : G.adj v w) : G'.adj (f v) (f w) :=
  f.map_rel' h

theorem map_mem_edge_set {e : Sym2 V} (h : e ∈ G.edge_set) : e.map f ∈ G'.edge_set :=
  Quotientₓ.ind (fun e h => Sym2.from_rel_prop.mpr (f.map_rel' h)) e h

theorem apply_mem_neighbor_set {v w : V} (h : w ∈ G.neighbor_set v) : f w ∈ G'.neighbor_set (f v) :=
  map_adj f h

/-- The map between edge sets induced by a homomorphism.
The underlying map on edges is given by `sym2.map`. -/
@[simps]
def map_edge_set (e : G.edge_set) : G'.edge_set :=
  ⟨Sym2.map f e, f.map_mem_edge_set e.property⟩

/-- The map between neighbor sets induced by a homomorphism. -/
@[simps]
def map_neighbor_set (v : V) (w : G.neighbor_set v) : G'.neighbor_set (f v) :=
  ⟨f w, f.apply_mem_neighbor_set w.property⟩

theorem map_edge_set.injective (hinj : Function.Injective f) : Function.Injective f.map_edge_set :=
  by 
    rintro ⟨e₁, h₁⟩ ⟨e₂, h₂⟩
    dsimp [hom.map_edge_set]
    repeat' 
      rw [Subtype.mk_eq_mk]
    apply Sym2.map.injective hinj

variable{G'' : SimpleGraph X}

/-- Composition of graph homomorphisms. -/
abbrev comp (f' : G' →g G'') (f : G →g G') : G →g G'' :=
  f'.comp f

@[simp]
theorem coe_comp (f' : G' →g G'') (f : G →g G') : «expr⇑ » (f'.comp f) = (f' ∘ f) :=
  rfl

end Hom

namespace Embedding

variable{G G'}(f : G ↪g G')

/-- The identity embedding from a graph to itself. -/
abbrev refl : G ↪g G :=
  RelEmbedding.refl _

/-- An embedding of graphs gives rise to a homomorphism of graphs. -/
abbrev to_hom : G →g G' :=
  f.to_rel_hom

theorem map_adj_iff {v w : V} : G'.adj (f v) (f w) ↔ G.adj v w :=
  f.map_rel_iff

theorem map_mem_edge_set_iff {e : Sym2 V} : e.map f ∈ G'.edge_set ↔ e ∈ G.edge_set :=
  Quotientₓ.ind (fun ⟨v, w⟩ => f.map_adj_iff) e

theorem apply_mem_neighbor_set_iff {v w : V} : f w ∈ G'.neighbor_set (f v) ↔ w ∈ G.neighbor_set v :=
  map_adj_iff f

/-- A graph embedding induces an embedding of edge sets. -/
@[simps]
def map_edge_set : G.edge_set ↪ G'.edge_set :=
  { toFun := hom.map_edge_set f, inj' := hom.map_edge_set.injective f f.inj' }

/-- A graph embedding induces an embedding of neighbor sets. -/
@[simps]
def map_neighbor_set (v : V) : G.neighbor_set v ↪ G'.neighbor_set (f v) :=
  { toFun := fun w => ⟨f w, f.apply_mem_neighbor_set_iff.mpr w.2⟩,
    inj' :=
      by 
        rintro ⟨w₁, h₁⟩ ⟨w₂, h₂⟩ h 
        rw [Subtype.mk_eq_mk] at h⊢
        exact f.inj' h }

variable{G'' : SimpleGraph X}

/-- Composition of graph embeddings. -/
abbrev comp (f' : G' ↪g G'') (f : G ↪g G') : G ↪g G'' :=
  f.trans f'

@[simp]
theorem coe_comp (f' : G' ↪g G'') (f : G ↪g G') : «expr⇑ » (f'.comp f) = (f' ∘ f) :=
  rfl

end Embedding

namespace Iso

variable{G G'}(f : G ≃g G')

/-- The identity isomorphism of a graph with itself. -/
abbrev refl : G ≃g G :=
  RelIso.refl _

/-- An isomorphism of graphs gives rise to an embedding of graphs. -/
abbrev to_embedding : G ↪g G' :=
  f.to_rel_embedding

/-- An isomorphism of graphs gives rise to a homomorphism of graphs. -/
abbrev to_hom : G →g G' :=
  f.to_embedding.to_hom

/-- The inverse of a graph isomorphism. --/
abbrev symm : G' ≃g G :=
  f.symm

theorem map_adj_iff {v w : V} : G'.adj (f v) (f w) ↔ G.adj v w :=
  f.map_rel_iff

theorem map_mem_edge_set_iff {e : Sym2 V} : e.map f ∈ G'.edge_set ↔ e ∈ G.edge_set :=
  Quotientₓ.ind (fun ⟨v, w⟩ => f.map_adj_iff) e

theorem apply_mem_neighbor_set_iff {v w : V} : f w ∈ G'.neighbor_set (f v) ↔ w ∈ G.neighbor_set v :=
  map_adj_iff f

/-- An isomorphism of graphs induces an equivalence of edge sets. -/
@[simps]
def map_edge_set : G.edge_set ≃ G'.edge_set :=
  { toFun := hom.map_edge_set f, invFun := hom.map_edge_set f.symm,
    left_inv :=
      by 
        rintro ⟨e, h⟩
        simp only [hom.map_edge_set, Sym2.map_map, RelIso.coe_coe_fn, RelEmbedding.coe_coe_fn, Subtype.mk_eq_mk,
          Subtype.coe_mk, coe_coe]
        apply congr_funₓ 
        convert Sym2.map_id 
        exact funext fun _ => RelIso.symm_apply_apply _ _,
    right_inv :=
      by 
        rintro ⟨e, h⟩
        simp only [hom.map_edge_set, Sym2.map_map, RelIso.coe_coe_fn, RelEmbedding.coe_coe_fn, Subtype.mk_eq_mk,
          Subtype.coe_mk, coe_coe]
        apply congr_funₓ 
        convert Sym2.map_id 
        exact funext fun _ => RelIso.apply_symm_apply _ _ }

/-- A graph isomorphism induces an equivalence of neighbor sets. -/
@[simps]
def map_neighbor_set (v : V) : G.neighbor_set v ≃ G'.neighbor_set (f v) :=
  { toFun := fun w => ⟨f w, f.apply_mem_neighbor_set_iff.mpr w.2⟩,
    invFun :=
      fun w =>
        ⟨f.symm w,
          by 
            convert f.symm.apply_mem_neighbor_set_iff.mpr w.2
            simp only [RelIso.symm_apply_apply]⟩,
    left_inv :=
      fun w =>
        by 
          simp ,
    right_inv :=
      fun w =>
        by 
          simp  }

theorem card_eq_of_iso [Fintype V] [Fintype W] (f : G ≃g G') : Fintype.card V = Fintype.card W :=
  by 
    convert (Fintype.of_equiv_card f.to_equiv).symm

variable{G'' : SimpleGraph X}

/-- Composition of graph isomorphisms. -/
abbrev comp (f' : G' ≃g G'') (f : G ≃g G') : G ≃g G'' :=
  f.trans f'

@[simp]
theorem coe_comp (f' : G' ≃g G'') (f : G ≃g G') : «expr⇑ » (f'.comp f) = (f' ∘ f) :=
  rfl

end Iso

end Maps

end SimpleGraph

