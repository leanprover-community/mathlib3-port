/-
Copyright (c) 2021 Patrick Massot. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Massot

! This file was ported from Lean 3 source module topology.algebra.filter_basis
! leanprover-community/mathlib commit bd9851ca476957ea4549eb19b40e7b5ade9428cc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Filter.Bases
import Mathbin.Topology.Algebra.Module.Basic

/-!
# Group and ring filter bases

A `group_filter_basis` is a `filter_basis` on a group with some properties relating
the basis to the group structure. The main theorem is that a `group_filter_basis`
on a group gives a topology on the group which makes it into a topological group
with neighborhoods of the neutral element generated by the given basis.

## Main definitions and results

Given a group `G` and a ring `R`:

* `group_filter_basis G`: the type of filter bases that will become neighborhood of `1`
  for a topology on `G` compatible with the group structure
* `group_filter_basis.topology`: the associated topology
* `group_filter_basis.is_topological_group`: the compatibility between the above topology
  and the group structure
* `ring_filter_basis R`: the type of filter bases that will become neighborhood of `0`
  for a topology on `R` compatible with the ring structure
* `ring_filter_basis.topology`: the associated topology
* `ring_filter_basis.is_topological_ring`: the compatibility between the above topology
  and the ring structure

## References

* [N. Bourbaki, *General Topology*][bourbaki1966]
-/


open Filter Set TopologicalSpace Function

open Topology Filter Pointwise

universe u

/-- A `group_filter_basis` on a group is a `filter_basis` satisfying some additional axioms.
  Example : if `G` is a topological group then the neighbourhoods of the identity are a
  `group_filter_basis`. Conversely given a `group_filter_basis` one can define a topology
  compatible with the group structure on `G`.  -/
class GroupFilterBasis (G : Type u) [Group G] extends FilterBasis G where
  one' : ∀ {U}, U ∈ sets → (1 : G) ∈ U
  mul' : ∀ {U}, U ∈ sets → ∃ V ∈ sets, V * V ⊆ U
  inv' : ∀ {U}, U ∈ sets → ∃ V ∈ sets, V ⊆ (fun x => x⁻¹) ⁻¹' U
  conj' : ∀ x₀, ∀ {U}, U ∈ sets → ∃ V ∈ sets, V ⊆ (fun x => x₀ * x * x₀⁻¹) ⁻¹' U
#align group_filter_basis GroupFilterBasis

/-- A `add_group_filter_basis` on an additive group is a `filter_basis` satisfying some additional
  axioms. Example : if `G` is a topological group then the neighbourhoods of the identity are a
  `add_group_filter_basis`. Conversely given a `add_group_filter_basis` one can define a topology
  compatible with the group structure on `G`. -/
class AddGroupFilterBasis (A : Type u) [AddGroup A] extends FilterBasis A where
  zero' : ∀ {U}, U ∈ sets → (0 : A) ∈ U
  add' : ∀ {U}, U ∈ sets → ∃ V ∈ sets, V + V ⊆ U
  neg' : ∀ {U}, U ∈ sets → ∃ V ∈ sets, V ⊆ (fun x => -x) ⁻¹' U
  conj' : ∀ x₀, ∀ {U}, U ∈ sets → ∃ V ∈ sets, V ⊆ (fun x => x₀ + x + -x₀) ⁻¹' U
#align add_group_filter_basis AddGroupFilterBasis

attribute [to_additive] GroupFilterBasis

attribute [to_additive] GroupFilterBasis.one'

attribute [to_additive] GroupFilterBasis.mul'

attribute [to_additive] GroupFilterBasis.inv'

attribute [to_additive] GroupFilterBasis.conj'

attribute [to_additive] GroupFilterBasis.toFilterBasis

/-- `group_filter_basis` constructor in the commutative group case. -/
@[to_additive "`add_group_filter_basis` constructor in the additive commutative group case."]
def groupFilterBasisOfComm {G : Type _} [CommGroup G] (sets : Set (Set G))
    (nonempty : sets.Nonempty) (inter_sets : ∀ x y, x ∈ sets → y ∈ sets → ∃ z ∈ sets, z ⊆ x ∩ y)
    (one : ∀ U ∈ sets, (1 : G) ∈ U) (mul : ∀ U ∈ sets, ∃ V ∈ sets, V * V ⊆ U)
    (inv : ∀ U ∈ sets, ∃ V ∈ sets, V ⊆ (fun x => x⁻¹) ⁻¹' U) : GroupFilterBasis G :=
  { sets
    Nonempty
    inter_sets
    one' := one
    mul' := mul
    inv' := inv
    conj' := fun x U U_in => ⟨U, U_in, by simp⟩ }
#align group_filter_basis_of_comm groupFilterBasisOfComm
#align add_group_filter_basis_of_comm addGroupFilterBasisOfComm

namespace GroupFilterBasis

variable {G : Type u} [Group G] {B : GroupFilterBasis G}

@[to_additive]
instance : Membership (Set G) (GroupFilterBasis G) :=
  ⟨fun s f => s ∈ f.sets⟩

@[to_additive]
theorem one {U : Set G} : U ∈ B → (1 : G) ∈ U :=
  GroupFilterBasis.one'
#align group_filter_basis.one GroupFilterBasis.one
#align add_group_filter_basis.zero AddGroupFilterBasis.zero

@[to_additive]
theorem mul {U : Set G} : U ∈ B → ∃ V ∈ B, V * V ⊆ U :=
  GroupFilterBasis.mul'
#align group_filter_basis.mul GroupFilterBasis.mul
#align add_group_filter_basis.add AddGroupFilterBasis.add

@[to_additive]
theorem inv {U : Set G} : U ∈ B → ∃ V ∈ B, V ⊆ (fun x => x⁻¹) ⁻¹' U :=
  GroupFilterBasis.inv'
#align group_filter_basis.inv GroupFilterBasis.inv
#align add_group_filter_basis.neg AddGroupFilterBasis.neg

@[to_additive]
theorem conj : ∀ x₀, ∀ {U}, U ∈ B → ∃ V ∈ B, V ⊆ (fun x => x₀ * x * x₀⁻¹) ⁻¹' U :=
  GroupFilterBasis.conj'
#align group_filter_basis.conj GroupFilterBasis.conj
#align add_group_filter_basis.conj AddGroupFilterBasis.conj

/-- The trivial group filter basis consists of `{1}` only. The associated topology
is discrete. -/
@[to_additive
      "The trivial additive group filter basis consists of `{0}` only. The associated\ntopology is discrete."]
instance : Inhabited (GroupFilterBasis G) :=
  ⟨by
    refine'
      { sets := {{1}}
        Nonempty := singleton_nonempty _.. }
    all_goals simp only [exists_prop, mem_singleton_iff]
    · rintro - - rfl rfl
      use {1}
      simp
    · simp
    · rintro - rfl
      use {1}
      simp
    · rintro - rfl
      use {1}
      simp
    · rintro x₀ - rfl
      use {1}
      simp⟩

@[to_additive]
theorem prod_subset_self (B : GroupFilterBasis G) {U : Set G} (h : U ∈ B) : U ⊆ U * U :=
  fun x x_in => ⟨1, x, one h, x_in, one_mul x⟩
#align group_filter_basis.prod_subset_self GroupFilterBasis.prod_subset_self
#align add_group_filter_basis.sum_subset_self AddGroupFilterBasis.sum_subset_self

/-- The neighborhood function of a `group_filter_basis` -/
@[to_additive "The neighborhood function of a `add_group_filter_basis`"]
def n (B : GroupFilterBasis G) : G → Filter G := fun x =>
  map (fun y => x * y) B.toFilterBasis.filterₓ
#align group_filter_basis.N GroupFilterBasis.n
#align add_group_filter_basis.N AddGroupFilterBasis.n

@[simp, to_additive]
theorem n_one (B : GroupFilterBasis G) : B.n 1 = B.toFilterBasis.filterₓ := by
  simp only [N, one_mul, map_id']
#align group_filter_basis.N_one GroupFilterBasis.n_one
#align add_group_filter_basis.N_zero AddGroupFilterBasis.n_zero

@[to_additive]
protected theorem hasBasis (B : GroupFilterBasis G) (x : G) :
    HasBasis (B.n x) (fun V : Set G => V ∈ B) fun V => (fun y => x * y) '' V :=
  HasBasis.map (fun y => x * y) toFilterBasis.HasBasis
#align group_filter_basis.has_basis GroupFilterBasis.hasBasis
#align add_group_filter_basis.has_basis AddGroupFilterBasis.hasBasis

/-- The topological space structure coming from a group filter basis. -/
@[to_additive "The topological space structure coming from an additive group filter basis."]
def topology (B : GroupFilterBasis G) : TopologicalSpace G :=
  TopologicalSpace.mkOfNhds B.n
#align group_filter_basis.topology GroupFilterBasis.topology
#align add_group_filter_basis.topology AddGroupFilterBasis.topology

@[to_additive]
theorem nhds_eq (B : GroupFilterBasis G) {x₀ : G} : @nhds G B.topology x₀ = B.n x₀ :=
  by
  rw [TopologicalSpace.nhds_mkOfNhds]
  · intro x U U_in
    rw [(B.has_basis x).mem_iff] at U_in
    rcases U_in with ⟨V, V_in, H⟩
    simpa [mem_pure] using H (mem_image_of_mem _ (GroupFilterBasis.one V_in))
  · intro x U U_in
    rw [(B.has_basis x).mem_iff] at U_in
    rcases U_in with ⟨V, V_in, H⟩
    rcases GroupFilterBasis.mul V_in with ⟨W, W_in, hW⟩
    use (fun y => x * y) '' W, image_mem_map (FilterBasis.mem_filter_of_mem _ W_in)
    constructor
    · rw [image_subset_iff] at H⊢
      exact ((B.prod_subset_self W_in).trans hW).trans H
    · rintro y ⟨t, tW, rfl⟩
      rw [(B.has_basis _).mem_iff]
      use W, W_in
      apply subset.trans _ H
      clear H
      rintro z ⟨w, wW, rfl⟩
      exact ⟨t * w, hW (mul_mem_mul tW wW), by simp [mul_assoc]⟩
#align group_filter_basis.nhds_eq GroupFilterBasis.nhds_eq
#align add_group_filter_basis.nhds_eq AddGroupFilterBasis.nhds_eq

@[to_additive]
theorem nhds_one_eq (B : GroupFilterBasis G) :
    @nhds G B.topology (1 : G) = B.toFilterBasis.filterₓ :=
  by
  rw [B.nhds_eq]
  simp only [N, one_mul]
  exact map_id
#align group_filter_basis.nhds_one_eq GroupFilterBasis.nhds_one_eq
#align add_group_filter_basis.nhds_zero_eq AddGroupFilterBasis.nhds_zero_eq

@[to_additive]
theorem nhds_hasBasis (B : GroupFilterBasis G) (x₀ : G) :
    HasBasis (@nhds G B.topology x₀) (fun V : Set G => V ∈ B) fun V => (fun y => x₀ * y) '' V :=
  by
  rw [B.nhds_eq]
  apply B.has_basis
#align group_filter_basis.nhds_has_basis GroupFilterBasis.nhds_hasBasis
#align add_group_filter_basis.nhds_has_basis AddGroupFilterBasis.nhds_hasBasis

@[to_additive]
theorem nhds_one_hasBasis (B : GroupFilterBasis G) :
    HasBasis (@nhds G B.topology 1) (fun V : Set G => V ∈ B) id :=
  by
  rw [B.nhds_one_eq]
  exact B.to_filter_basis.has_basis
#align group_filter_basis.nhds_one_has_basis GroupFilterBasis.nhds_one_hasBasis
#align add_group_filter_basis.nhds_zero_has_basis AddGroupFilterBasis.nhds_zero_hasBasis

@[to_additive]
theorem mem_nhds_one (B : GroupFilterBasis G) {U : Set G} (hU : U ∈ B) : U ∈ @nhds G B.topology 1 :=
  by
  rw [B.nhds_one_has_basis.mem_iff]
  exact ⟨U, hU, rfl.subset⟩
#align group_filter_basis.mem_nhds_one GroupFilterBasis.mem_nhds_one
#align add_group_filter_basis.mem_nhds_zero AddGroupFilterBasis.mem_nhds_zero

-- See note [lower instance priority]
/-- If a group is endowed with a topological structure coming from a group filter basis then it's a
topological group. -/
@[to_additive
      "If a group is endowed with a topological structure coming from a group filter basis\nthen it's a topological group."]
instance (priority := 100) is_topologicalGroup (B : GroupFilterBasis G) :
    @TopologicalGroup G B.topology _ := by
  letI := B.topology
  have basis := B.nhds_one_has_basis
  have basis' := basis.prod basis
  refine' TopologicalGroup.of_nhds_one _ _ _ _
  · rw [basis'.tendsto_iff basis]
    suffices ∀ U ∈ B, ∃ V W, (V ∈ B ∧ W ∈ B) ∧ ∀ a b, a ∈ V → b ∈ W → a * b ∈ U by simpa
    intro U U_in
    rcases mul U_in with ⟨V, V_in, hV⟩
    use V, V, V_in, V_in
    intro a b a_in b_in
    exact hV ⟨a, b, a_in, b_in, rfl⟩
  · rw [basis.tendsto_iff basis]
    intro U U_in
    simpa using inv U_in
  · intro x₀
    rw [nhds_eq, nhds_one_eq]
    rfl
  · intro x₀
    rw [basis.tendsto_iff basis]
    intro U U_in
    exact conj x₀ U_in
#align group_filter_basis.is_topological_group GroupFilterBasis.is_topologicalGroup
#align add_group_filter_basis.is_topological_add_group AddGroupFilterBasis.is_topological_add_group

end GroupFilterBasis

/-- A `ring_filter_basis` on a ring is a `filter_basis` satisfying some additional axioms.
  Example : if `R` is a topological ring then the neighbourhoods of the identity are a
  `ring_filter_basis`. Conversely given a `ring_filter_basis` on a ring `R`, one can define a
  topology on `R` which is compatible with the ring structure.  -/
class RingFilterBasis (R : Type u) [Ring R] extends AddGroupFilterBasis R where
  mul' : ∀ {U}, U ∈ sets → ∃ V ∈ sets, V * V ⊆ U
  mul_left' : ∀ (x₀ : R) {U}, U ∈ sets → ∃ V ∈ sets, V ⊆ (fun x => x₀ * x) ⁻¹' U
  mul_right' : ∀ (x₀ : R) {U}, U ∈ sets → ∃ V ∈ sets, V ⊆ (fun x => x * x₀) ⁻¹' U
#align ring_filter_basis RingFilterBasis

namespace RingFilterBasis

variable {R : Type u} [Ring R] (B : RingFilterBasis R)

instance : Membership (Set R) (RingFilterBasis R) :=
  ⟨fun s B => s ∈ B.sets⟩

theorem mul {U : Set R} (hU : U ∈ B) : ∃ V ∈ B, V * V ⊆ U :=
  mul' hU
#align ring_filter_basis.mul RingFilterBasis.mul

theorem mul_left (x₀ : R) {U : Set R} (hU : U ∈ B) : ∃ V ∈ B, V ⊆ (fun x => x₀ * x) ⁻¹' U :=
  mul_left' x₀ hU
#align ring_filter_basis.mul_left RingFilterBasis.mul_left

theorem mul_right (x₀ : R) {U : Set R} (hU : U ∈ B) : ∃ V ∈ B, V ⊆ (fun x => x * x₀) ⁻¹' U :=
  mul_right' x₀ hU
#align ring_filter_basis.mul_right RingFilterBasis.mul_right

/-- The topology associated to a ring filter basis.
It has the given basis as a basis of neighborhoods of zero. -/
def topology : TopologicalSpace R :=
  B.toAddGroupFilterBasis.topology
#align ring_filter_basis.topology RingFilterBasis.topology

/-- If a ring is endowed with a topological structure coming from
a ring filter basis then it's a topological ring. -/
instance (priority := 100) is_topologicalRing {R : Type u} [Ring R] (B : RingFilterBasis R) :
    @TopologicalRing R B.topology _ :=
  by
  let B' := B.to_add_group_filter_basis
  letI := B'.topology
  have basis := B'.nhds_zero_has_basis
  have basis' := basis.prod basis
  haveI := B'.is_topological_add_group
  apply TopologicalRing.of_add_group_of_nhds_zero
  · rw [basis'.tendsto_iff basis]
    suffices ∀ U ∈ B', ∃ V W, (V ∈ B' ∧ W ∈ B') ∧ ∀ a b, a ∈ V → b ∈ W → a * b ∈ U by simpa
    intro U U_in
    rcases B.mul U_in with ⟨V, V_in, hV⟩
    use V, V, V_in, V_in
    intro a b a_in b_in
    exact hV ⟨a, b, a_in, b_in, rfl⟩
  · intro x₀
    rw [basis.tendsto_iff basis]
    intro U
    simpa using B.mul_left x₀
  · intro x₀
    rw [basis.tendsto_iff basis]
    intro U
    simpa using B.mul_right x₀
#align ring_filter_basis.is_topological_ring RingFilterBasis.is_topologicalRing

end RingFilterBasis

/-- A `module_filter_basis` on a module is a `filter_basis` satisfying some additional axioms.
  Example : if `M` is a topological module then the neighbourhoods of zero are a
  `module_filter_basis`. Conversely given a `module_filter_basis` one can define a topology
  compatible with the module structure on `M`.  -/
structure ModuleFilterBasis (R M : Type _) [CommRing R] [TopologicalSpace R] [AddCommGroup M]
  [Module R M] extends AddGroupFilterBasis M where
  smul' : ∀ {U}, U ∈ sets → ∃ V ∈ 𝓝 (0 : R), ∃ W ∈ sets, V • W ⊆ U
  smul_left' : ∀ (x₀ : R) {U}, U ∈ sets → ∃ V ∈ sets, V ⊆ (fun x => x₀ • x) ⁻¹' U
  smul_right' : ∀ (m₀ : M) {U}, U ∈ sets → ∀ᶠ x in 𝓝 (0 : R), x • m₀ ∈ U
#align module_filter_basis ModuleFilterBasis

namespace ModuleFilterBasis

variable {R M : Type _} [CommRing R] [TopologicalSpace R] [AddCommGroup M] [Module R M]
  (B : ModuleFilterBasis R M)

instance GroupFilterBasis.hasMem : Membership (Set M) (ModuleFilterBasis R M) :=
  ⟨fun s B => s ∈ B.sets⟩
#align module_filter_basis.group_filter_basis.has_mem ModuleFilterBasis.GroupFilterBasis.hasMem

theorem smul {U : Set M} (hU : U ∈ B) : ∃ V ∈ 𝓝 (0 : R), ∃ W ∈ B, V • W ⊆ U :=
  B.smul' hU
#align module_filter_basis.smul ModuleFilterBasis.smul

theorem smul_left (x₀ : R) {U : Set M} (hU : U ∈ B) : ∃ V ∈ B, V ⊆ (fun x => x₀ • x) ⁻¹' U :=
  B.smul_left' x₀ hU
#align module_filter_basis.smul_left ModuleFilterBasis.smul_left

theorem smul_right (m₀ : M) {U : Set M} (hU : U ∈ B) : ∀ᶠ x in 𝓝 (0 : R), x • m₀ ∈ U :=
  B.smul_right' m₀ hU
#align module_filter_basis.smul_right ModuleFilterBasis.smul_right

/-- If `R` is discrete then the trivial additive group filter basis on any `R`-module is a
module filter basis. -/
instance [DiscreteTopology R] : Inhabited (ModuleFilterBasis R M) :=
  ⟨{
      show AddGroupFilterBasis M from
        default with
      smul' := by
        rintro U (h : U ∈ {{(0 : M)}})
        rw [mem_singleton_iff] at h
        use univ, univ_mem, {0}, rfl
        rintro a ⟨x, m, -, hm, rfl⟩
        simp [mem_singleton_iff.1 hm, h]
      smul_left' := by
        rintro x₀ U (h : U ∈ {{(0 : M)}})
        rw [mem_singleton_iff] at h
        use {0}, rfl
        simp [h]
      smul_right' := by
        rintro m₀ U (h : U ∈ (0 : Set (Set M)))
        rw [Set.mem_zero] at h
        simp [h, nhds_discrete] }⟩

/-- The topology associated to a module filter basis on a module over a topological ring.
It has the given basis as a basis of neighborhoods of zero. -/
def topology : TopologicalSpace M :=
  B.toAddGroupFilterBasis.topology
#align module_filter_basis.topology ModuleFilterBasis.topology

/-- The topology associated to a module filter basis on a module over a topological ring.
It has the given basis as a basis of neighborhoods of zero. This version gets the ring
topology by unification instead of type class inference. -/
def topology' {R M : Type _} [CommRing R] {tR : TopologicalSpace R} [AddCommGroup M] [Module R M]
    (B : ModuleFilterBasis R M) : TopologicalSpace M :=
  B.toAddGroupFilterBasis.topology
#align module_filter_basis.topology' ModuleFilterBasis.topology'

/-- A topological add group whith a basis of `𝓝 0` satisfying the axioms of `module_filter_basis`
is a topological module.

This lemma is mathematically useless because one could obtain such a result by applying
`module_filter_basis.has_continuous_smul` and use the fact that group topologies are characterized
by their neighborhoods of 0 to obtain the `has_continuous_smul` on the pre-existing topology.

But it turns out it's just easier to get it as a biproduct of the proof, so this is just a free
quality-of-life improvement. -/
theorem ContinuousSMul.of_basis_zero {ι : Type _} [TopologicalRing R] [TopologicalSpace M]
    [TopologicalAddGroup M] {p : ι → Prop} {b : ι → Set M} (h : HasBasis (𝓝 0) p b)
    (hsmul : ∀ {i}, p i → ∃ V ∈ 𝓝 (0 : R), ∃ (j : _)(hj : p j), V • b j ⊆ b i)
    (hsmul_left : ∀ (x₀ : R) {i}, p i → ∃ (j : _)(hj : p j), b j ⊆ (fun x => x₀ • x) ⁻¹' b i)
    (hsmul_right : ∀ (m₀ : M) {i}, p i → ∀ᶠ x in 𝓝 (0 : R), x • m₀ ∈ b i) : ContinuousSMul R M :=
  by
  apply ContinuousSMul.of_nhds_zero
  · rw [h.tendsto_right_iff]
    intro i hi
    rcases hsmul hi with ⟨V, V_in, j, hj, hVj⟩
    apply mem_of_superset (prod_mem_prod V_in <| h.mem_of_mem hj)
    rintro ⟨v, w⟩ ⟨v_in : v ∈ V, w_in : w ∈ b j⟩
    exact hVj (Set.smul_mem_smul v_in w_in)
  · intro m₀
    rw [h.tendsto_right_iff]
    intro i hi
    exact hsmul_right m₀ hi
  · intro x₀
    rw [h.tendsto_right_iff]
    intro i hi
    rcases hsmul_left x₀ hi with ⟨j, hj, hji⟩
    exact mem_of_superset (h.mem_of_mem hj) hji
#align has_continuous_smul.of_basis_zero ContinuousSMul.of_basis_zero

/-- If a module is endowed with a topological structure coming from
a module filter basis then it's a topological module. -/
instance (priority := 100) continuousSMul [TopologicalRing R] :
    @ContinuousSMul R M _ _ B.topology :=
  by
  let B' := B.to_add_group_filter_basis
  letI := B'.topology
  haveI := B'.is_topological_add_group
  exact
    ContinuousSMul.of_basis_zero B'.nhds_zero_has_basis (fun _ => B.smul) B.smul_left B.smul_right
#align module_filter_basis.has_continuous_smul ModuleFilterBasis.continuousSMul

/-- Build a module filter basis from compatible ring and additive group filter bases. -/
def ofBases {R M : Type _} [CommRing R] [AddCommGroup M] [Module R M] (BR : RingFilterBasis R)
    (BM : AddGroupFilterBasis M) (smul : ∀ {U}, U ∈ BM → ∃ V ∈ BR, ∃ W ∈ BM, V • W ⊆ U)
    (smul_left : ∀ (x₀ : R) {U}, U ∈ BM → ∃ V ∈ BM, V ⊆ (fun x => x₀ • x) ⁻¹' U)
    (smul_right : ∀ (m₀ : M) {U}, U ∈ BM → ∃ V ∈ BR, V ⊆ (fun x => x • m₀) ⁻¹' U) :
    @ModuleFilterBasis R M _ BR.topology _ _ :=
  {
    BM with
    smul' := by
      intro U U_in
      rcases smul U_in with ⟨V, V_in, W, W_in, H⟩
      exact ⟨V, BR.to_add_group_filter_basis.mem_nhds_zero V_in, W, W_in, H⟩
    smul_left' := smul_left
    smul_right' := by
      intro m₀ U U_in
      rcases smul_right m₀ U_in with ⟨V, V_in, H⟩
      exact mem_of_superset (BR.to_add_group_filter_basis.mem_nhds_zero V_in) H }
#align module_filter_basis.of_bases ModuleFilterBasis.ofBases

end ModuleFilterBasis

