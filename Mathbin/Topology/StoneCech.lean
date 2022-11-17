/-
Copyright (c) 2018 Reid Barton. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Reid Barton
-/
import Mathbin.Topology.Bases
import Mathbin.Topology.DenseEmbedding

/-! # Stone-Čech compactification

Construction of the Stone-Čech compactification using ultrafilters.

Parts of the formalization are based on "Ultrafilters and Topology"
by Marius Stekelenburg, particularly section 5.
-/


noncomputable section

open Filter Set

open TopologicalSpace

universe u v

section Ultrafilter

/- The set of ultrafilters on α carries a natural topology which makes
  it the Stone-Čech compactification of α (viewed as a discrete space). -/
/-- Basis for the topology on `ultrafilter α`. -/
def ultrafilterBasis (α : Type u) : Set (Set (Ultrafilter α)) :=
  range $ fun s : Set α => { u | s ∈ u }
#align ultrafilter_basis ultrafilterBasis

variable {α : Type u}

instance : TopologicalSpace (Ultrafilter α) :=
  TopologicalSpace.generateFrom (ultrafilterBasis α)

theorem ultrafilter_basis_is_basis : TopologicalSpace.IsTopologicalBasis (ultrafilterBasis α) :=
  ⟨by
    rintro _ ⟨a, rfl⟩ _ ⟨b, rfl⟩ u ⟨ua, ub⟩
    refine' ⟨_, ⟨a ∩ b, rfl⟩, inter_mem ua ub, fun v hv => ⟨_, _⟩⟩ <;>
      apply mem_of_superset hv <;> simp [inter_subset_right a b],
    eq_univ_of_univ_subset $ subset_sUnion_of_mem $ ⟨univ, eq_univ_of_forall fun u => univ_mem⟩, rfl⟩
#align ultrafilter_basis_is_basis ultrafilter_basis_is_basis

/-- The basic open sets for the topology on ultrafilters are open. -/
theorem ultrafilter_is_open_basic (s : Set α) : IsOpen { u : Ultrafilter α | s ∈ u } :=
  ultrafilter_basis_is_basis.IsOpen ⟨s, rfl⟩
#align ultrafilter_is_open_basic ultrafilter_is_open_basic

/-- The basic open sets for the topology on ultrafilters are also closed. -/
theorem ultrafilterIsClosedBasic (s : Set α) : IsClosed { u : Ultrafilter α | s ∈ u } := by
  rw [← is_open_compl_iff]
  convert ultrafilter_is_open_basic (sᶜ)
  ext u
  exact ultrafilter.compl_mem_iff_not_mem.symm
#align ultrafilter_is_closed_basic ultrafilterIsClosedBasic

/-- Every ultrafilter `u` on `ultrafilter α` converges to a unique
  point of `ultrafilter α`, namely `mjoin u`. -/
theorem ultrafilter_converges_iff {u : Ultrafilter (Ultrafilter α)} {x : Ultrafilter α} : ↑u ≤ 𝓝 x ↔ x = joinM u := by
  rw [eq_comm, ← Ultrafilter.coe_le_coe]
  change ↑u ≤ 𝓝 x ↔ ∀ s ∈ x, { v : Ultrafilter α | s ∈ v } ∈ u
  simp only [TopologicalSpace.nhds_generate_from, le_infi_iff, ultrafilterBasis, le_principal_iff, mem_set_of_eq]
  constructor
  · intro h a ha
    exact h _ ⟨ha, a, rfl⟩
    
  · rintro h a ⟨xi, a, rfl⟩
    exact h _ xi
    
#align ultrafilter_converges_iff ultrafilter_converges_iff

instance ultrafilter_compact : CompactSpace (Ultrafilter α) :=
  ⟨is_compact_iff_ultrafilter_le_nhds.mpr $ fun f _ => ⟨joinM f, trivial, ultrafilter_converges_iff.mpr rfl⟩⟩
#align ultrafilter_compact ultrafilter_compact

instance Ultrafilter.t2Space : T2Space (Ultrafilter α) :=
  t2_iff_ultrafilter.mpr $ fun x y f fx fy =>
    have hx : x = joinM f := ultrafilter_converges_iff.mp fx
    have hy : y = joinM f := ultrafilter_converges_iff.mp fy
    hx.trans hy.symm
#align ultrafilter.t2_space Ultrafilter.t2Space

instance : TotallyDisconnectedSpace (Ultrafilter α) := by
  rw [totally_disconnected_space_iff_connected_component_singleton]
  intro A
  simp only [Set.eq_singleton_iff_unique_mem, mem_connected_component, true_and_iff]
  intro B hB
  rw [← Ultrafilter.coe_le_coe]
  intro s hs
  rw [connected_component_eq_Inter_clopen, Set.mem_Inter] at hB
  let Z := { F : Ultrafilter α | s ∈ F }
  have hZ : IsClopen Z := ⟨ultrafilter_is_open_basic s, ultrafilterIsClosedBasic s⟩
  exact hB ⟨Z, hZ, hs⟩

theorem ultrafilter_comap_pure_nhds (b : Ultrafilter α) : comap pure (𝓝 b) ≤ b := by
  rw [TopologicalSpace.nhds_generate_from]
  simp only [comap_infi, comap_principal]
  intro s hs
  rw [← le_principal_iff]
  refine' infi_le_of_le { u | s ∈ u } _
  refine' infi_le_of_le ⟨hs, ⟨s, rfl⟩⟩ _
  exact principal_mono.2 fun a => id
#align ultrafilter_comap_pure_nhds ultrafilter_comap_pure_nhds

section Embedding

theorem ultrafilter_pure_injective : Function.Injective (pure : α → Ultrafilter α) := by
  intro x y h
  have : {x} ∈ (pure x : Ultrafilter α) := singleton_mem_pure
  rw [h] at this
  exact (mem_singleton_iff.mp (mem_pure.mp this)).symm
#align ultrafilter_pure_injective ultrafilter_pure_injective

open TopologicalSpace

/-- The range of `pure : α → ultrafilter α` is dense in `ultrafilter α`. -/
theorem dense_range_pure : DenseRange (pure : α → Ultrafilter α) := fun x =>
  mem_closure_iff_ultrafilter.mpr ⟨x.map pure, range_mem_map, ultrafilter_converges_iff.mpr (bind_pure x).symm⟩
#align dense_range_pure dense_range_pure

/-- The map `pure : α → ultra_filter α` induces on `α` the discrete topology. -/
theorem induced_topology_pure : TopologicalSpace.induced (pure : α → Ultrafilter α) Ultrafilter.topologicalSpace = ⊥ :=
  by
  apply eq_bot_of_singletons_open
  intro x
  use { u : Ultrafilter α | {x} ∈ u }, ultrafilter_is_open_basic _
  simp
#align induced_topology_pure induced_topology_pure

/-- `pure : α → ultrafilter α` defines a dense inducing of `α` in `ultrafilter α`. -/
theorem dense_inducing_pure : @DenseInducing _ _ ⊥ _ (pure : α → Ultrafilter α) :=
  letI : TopologicalSpace α := ⊥
  ⟨⟨induced_topology_pure.symm⟩, dense_range_pure⟩
#align dense_inducing_pure dense_inducing_pure

-- The following refined version will never be used
/-- `pure : α → ultrafilter α` defines a dense embedding of `α` in `ultrafilter α`. -/
theorem dense_embedding_pure : @DenseEmbedding _ _ ⊥ _ (pure : α → Ultrafilter α) :=
  letI : TopologicalSpace α := ⊥
  { dense_inducing_pure with inj := ultrafilter_pure_injective }
#align dense_embedding_pure dense_embedding_pure

end Embedding

section Extension

/- Goal: Any function `α → γ` to a compact Hausdorff space `γ` has a
  unique extension to a continuous function `ultrafilter α → γ`. We
  already know it must be unique because `α → ultrafilter α` is a
  dense embedding and `γ` is Hausdorff. For existence, we will invoke
  `dense_embedding.continuous_extend`. -/
variable {γ : Type _} [TopologicalSpace γ]

/-- The extension of a function `α → γ` to a function `ultrafilter α → γ`.
  When `γ` is a compact Hausdorff space it will be continuous. -/
def Ultrafilter.extend (f : α → γ) : Ultrafilter α → γ :=
  letI : TopologicalSpace α := ⊥
  dense_inducing_pure.extend f
#align ultrafilter.extend Ultrafilter.extend

variable [T2Space γ]

theorem ultrafilter_extend_extends (f : α → γ) : Ultrafilter.extend f ∘ pure = f := by
  letI : TopologicalSpace α := ⊥
  haveI : DiscreteTopology α := ⟨rfl⟩
  exact funext (dense_inducing_pure.extend_eq continuous_of_discrete_topology)
#align ultrafilter_extend_extends ultrafilter_extend_extends

variable [CompactSpace γ]

theorem continuous_ultrafilter_extend (f : α → γ) : Continuous (Ultrafilter.extend f) := by
  have : ∀ b : Ultrafilter α, ∃ c, Tendsto f (comap pure (𝓝 b)) (𝓝 c) := fun b =>
    -- b.map f is an ultrafilter on γ, which is compact, so it converges to some c in γ.
    let ⟨c, _, h⟩ := is_compact_univ.ultrafilter_le_nhds (b.map f) (by rw [le_principal_iff] <;> exact univ_mem)
    ⟨c, le_trans (map_mono (ultrafilter_comap_pure_nhds _)) h⟩
  letI : TopologicalSpace α := ⊥
  haveI : NormalSpace γ := normalOfCompactT2
  exact dense_inducing_pure.continuous_extend this
#align continuous_ultrafilter_extend continuous_ultrafilter_extend

/-- The value of `ultrafilter.extend f` on an ultrafilter `b` is the
  unique limit of the ultrafilter `b.map f` in `γ`. -/
theorem ultrafilter_extend_eq_iff {f : α → γ} {b : Ultrafilter α} {c : γ} :
    Ultrafilter.extend f b = c ↔ ↑(b.map f) ≤ 𝓝 c :=
  ⟨fun h => by
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
    dense_inducing_pure.extend_eq_of_tendsto (le_trans (map_mono (ultrafilter_comap_pure_nhds _)) h)⟩
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

instance stoneCechSetoid : Setoid (Ultrafilter α) where
  R x y :=
    ∀ (γ : Type u) [TopologicalSpace γ],
      ∀ [T2Space γ] [CompactSpace γ] (f : α → γ) (hf : Continuous f), Ultrafilter.extend f x = Ultrafilter.extend f y
  iseqv :=
    ⟨fun x γ tγ h₁ h₂ f hf => rfl, fun x y xy γ tγ h₁ h₂ f hf => (xy γ f hf).symm, fun x y z xy yz γ tγ h₁ h₂ f hf =>
      (xy γ f hf).trans (yz γ f hf)⟩
#align stone_cech_setoid stoneCechSetoid

/-- The Stone-Čech compactification of a topological space. -/
def StoneCech : Type u :=
  Quotient (stoneCechSetoid α)
#align stone_cech StoneCech

variable {α}

instance : TopologicalSpace (StoneCech α) := by unfold StoneCech <;> infer_instance

instance [Inhabited α] : Inhabited (StoneCech α) := by unfold StoneCech <;> infer_instance

/-- The natural map from α to its Stone-Čech compactification. -/
def stoneCechUnit (x : α) : StoneCech α :=
  ⟦pure x⟧
#align stone_cech_unit stoneCechUnit

/-- The image of stone_cech_unit is dense. (But stone_cech_unit need
  not be an embedding, for example if α is not Hausdorff.) -/
theorem dense_range_stone_cech_unit : DenseRange (stoneCechUnit : α → StoneCech α) :=
  dense_range_pure.Quotient
#align dense_range_stone_cech_unit dense_range_stone_cech_unit

section Extension

variable {γ : Type u} [TopologicalSpace γ] [T2Space γ] [CompactSpace γ]

variable {γ' : Type u} [TopologicalSpace γ'] [T2Space γ']

variable {f : α → γ} (hf : Continuous f)

attribute [local elab_with_expected_type] Quotient.lift

/-- The extension of a continuous function from α to a compact
  Hausdorff space γ to the Stone-Čech compactification of α. -/
def stoneCechExtend : StoneCech α → γ :=
  Quotient.lift (Ultrafilter.extend f) fun x y xy => xy γ f hf
#align stone_cech_extend stoneCechExtend

theorem stone_cech_extend_extends : stoneCechExtend hf ∘ stoneCechUnit = f :=
  ultrafilter_extend_extends f
#align stone_cech_extend_extends stone_cech_extend_extends

theorem continuous_stone_cech_extend : Continuous (stoneCechExtend hf) :=
  continuous_quot_lift _ (continuous_ultrafilter_extend f)
#align continuous_stone_cech_extend continuous_stone_cech_extend

theorem stone_cech_hom_ext {g₁ g₂ : StoneCech α → γ'} (h₁ : Continuous g₁) (h₂ : Continuous g₂)
    (h : g₁ ∘ stoneCechUnit = g₂ ∘ stoneCechUnit) : g₁ = g₂ := by
  apply Continuous.ext_on dense_range_stone_cech_unit h₁ h₂
  rintro x ⟨x, rfl⟩
  apply congr_fun h x
#align stone_cech_hom_ext stone_cech_hom_ext

end Extension

theorem convergent_eqv_pure {u : Ultrafilter α} {x : α} (ux : ↑u ≤ 𝓝 x) : u ≈ pure x := fun γ tγ h₁ h₂ f hf => by
  skip
  trans f x
  swap
  symm
  all_goals refine' ultrafilter_extend_eq_iff.mpr (le_trans (map_mono _) (hf.tendsto _))
  · apply pure_le_nhds
    
  · exact ux
    
#align convergent_eqv_pure convergent_eqv_pure

theorem continuous_stone_cech_unit : Continuous (stoneCechUnit : α → StoneCech α) :=
  continuous_iff_ultrafilter.mpr $ fun x g gx => by
    have : ↑(g.map pure) ≤ 𝓝 g := by rw [ultrafilter_converges_iff] <;> exact (bind_pure _).symm
    have : (g.map stoneCechUnit : Filter (StoneCech α)) ≤ 𝓝 ⟦g⟧ :=
      continuous_at_iff_ultrafilter.mp (continuous_quotient_mk.Tendsto g) _ this
    rwa [show ⟦g⟧ = ⟦pure x⟧ from Quotient.sound $ convergent_eqv_pure gx] at this
#align continuous_stone_cech_unit continuous_stone_cech_unit

instance StoneCech.t2Space : T2Space (StoneCech α) := by
  rw [t2_iff_ultrafilter]
  rintro ⟨x⟩ ⟨y⟩ g gx gy
  apply Quotient.sound
  intro γ tγ h₁ h₂ f hf
  skip
  let ff := stoneCechExtend hf
  change ff ⟦x⟧ = ff ⟦y⟧
  have lim := fun (z : Ultrafilter α) (gz : (g : Filter (StoneCech α)) ≤ 𝓝 ⟦z⟧) =>
    ((continuous_stone_cech_extend hf).Tendsto _).mono_left gz
  exact tendsto_nhds_unique (lim x gx) (lim y gy)
#align stone_cech.t2_space StoneCech.t2Space

instance StoneCech.compact_space : CompactSpace (StoneCech α) :=
  Quotient.compact_space
#align stone_cech.compact_space StoneCech.compact_space

end StoneCech

