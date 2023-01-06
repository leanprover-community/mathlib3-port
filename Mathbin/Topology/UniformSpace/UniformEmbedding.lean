/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Sébastien Gouëzel, Patrick Massot

! This file was ported from Lean 3 source module topology.uniform_space.uniform_embedding
! leanprover-community/mathlib commit 18a5306c091183ac90884daa9373fa3b178e8607
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.UniformSpace.Cauchy
import Mathbin.Topology.UniformSpace.Separation
import Mathbin.Topology.DenseEmbedding

/-!
# Uniform embeddings of uniform spaces.

Extension of uniform continuous functions.
-/


open Filter TopologicalSpace Set Classical

open Classical uniformity TopologicalSpace Filter

section

variable {α : Type _} {β : Type _} {γ : Type _} [UniformSpace α] [UniformSpace β] [UniformSpace γ]

universe u v

/-- A map `f : α → β` between uniform spaces is called *uniform inducing* if the uniformity filter
on `α` is the pullback of the uniformity filter on `β` under `prod.map f f`. If `α` is a separated
space, then this implies that `f` is injective, hence it is a `uniform_embedding`. -/
structure UniformInducing (f : α → β) : Prop where
  comap_uniformity : comap (fun x : α × α => (f x.1, f x.2)) (𝓤 β) = 𝓤 α
#align uniform_inducing UniformInducing

theorem UniformInducing.mk' {f : α → β}
    (h : ∀ s, s ∈ 𝓤 α ↔ ∃ t ∈ 𝓤 β, ∀ x y : α, (f x, f y) ∈ t → (x, y) ∈ s) : UniformInducing f :=
  ⟨by simp [eq_comm, Filter.ext_iff, subset_def, h]⟩
#align uniform_inducing.mk' UniformInducing.mk'

theorem uniform_inducing_id : UniformInducing (@id α) :=
  ⟨by rw [← Prod.map_def, Prod.map_id, comap_id]⟩
#align uniform_inducing_id uniform_inducing_id

theorem UniformInducing.comp {g : β → γ} (hg : UniformInducing g) {f : α → β}
    (hf : UniformInducing f) : UniformInducing (g ∘ f) :=
  ⟨by
    rw [show
        (fun x : α × α => ((g ∘ f) x.1, (g ∘ f) x.2)) =
          (fun y : β × β => (g y.1, g y.2)) ∘ fun x : α × α => (f x.1, f x.2)
        by ext <;> simp,
      ← Filter.comap_comap, hg.1, hf.1]⟩
#align uniform_inducing.comp UniformInducing.comp

theorem UniformInducing.basis_uniformity {f : α → β} (hf : UniformInducing f) {ι : Sort _}
    {p : ι → Prop} {s : ι → Set (β × β)} (H : (𝓤 β).HasBasis p s) :
    (𝓤 α).HasBasis p fun i => Prod.map f f ⁻¹' s i :=
  hf.1 ▸ H.comap _
#align uniform_inducing.basis_uniformity UniformInducing.basis_uniformity

theorem UniformInducing.cauchy_map_iff {f : α → β} (hf : UniformInducing f) {F : Filter α} :
    Cauchy (map f F) ↔ Cauchy F := by
  simp only [Cauchy, map_ne_bot_iff, prod_map_map_eq, map_le_iff_le_comap, ← hf.comap_uniformity]
#align uniform_inducing.cauchy_map_iff UniformInducing.cauchy_map_iff

theorem uniform_inducing_of_compose {f : α → β} {g : β → γ} (hf : UniformContinuous f)
    (hg : UniformContinuous g) (hgf : UniformInducing (g ∘ f)) : UniformInducing f :=
  by
  refine' ⟨le_antisymm _ hf.le_comap⟩
  rw [← hgf.1, ← Prod.map_def, ← Prod.map_def, ← Prod.map_comp_map f f g g, ←
    @comap_comap _ _ _ _ (Prod.map f f)]
  exact comap_mono hg.le_comap
#align uniform_inducing_of_compose uniform_inducing_of_compose

/-- A map `f : α → β` between uniform spaces is a *uniform embedding* if it is uniform inducing and
injective. If `α` is a separated space, then the latter assumption follows from the former. -/
structure UniformEmbedding (f : α → β) extends UniformInducing f : Prop where
  inj : Function.Injective f
#align uniform_embedding UniformEmbedding

theorem uniform_embedding_subtype_val {p : α → Prop} :
    UniformEmbedding (Subtype.val : Subtype p → α) :=
  { comap_uniformity := rfl
    inj := Subtype.val_injective }
#align uniform_embedding_subtype_val uniform_embedding_subtype_val

theorem uniform_embedding_subtype_coe {p : α → Prop} : UniformEmbedding (coe : Subtype p → α) :=
  uniform_embedding_subtype_val
#align uniform_embedding_subtype_coe uniform_embedding_subtype_coe

theorem uniform_embedding_set_inclusion {s t : Set α} (hst : s ⊆ t) :
    UniformEmbedding (inclusion hst) :=
  { comap_uniformity :=
      by
      erw [uniformity_subtype, uniformity_subtype, comap_comap]
      congr
    inj := inclusion_injective hst }
#align uniform_embedding_set_inclusion uniform_embedding_set_inclusion

theorem UniformEmbedding.comp {g : β → γ} (hg : UniformEmbedding g) {f : α → β}
    (hf : UniformEmbedding f) : UniformEmbedding (g ∘ f) :=
  { hg.to_uniform_inducing.comp hf.to_uniform_inducing with inj := hg.inj.comp hf.inj }
#align uniform_embedding.comp UniformEmbedding.comp

theorem uniform_embedding_def {f : α → β} :
    UniformEmbedding f ↔
      Function.Injective f ∧ ∀ s, s ∈ 𝓤 α ↔ ∃ t ∈ 𝓤 β, ∀ x y : α, (f x, f y) ∈ t → (x, y) ∈ s :=
  by
  constructor
  · rintro ⟨⟨h⟩, h'⟩
    rw [eq_comm, Filter.ext_iff] at h
    simp [*, subset_def]
  · rintro ⟨h, h'⟩
    refine' UniformEmbedding.mk ⟨_⟩ h
    rw [eq_comm, Filter.ext_iff]
    simp [*, subset_def]
#align uniform_embedding_def uniform_embedding_def

theorem uniform_embedding_def' {f : α → β} :
    UniformEmbedding f ↔
      Function.Injective f ∧
        UniformContinuous f ∧ ∀ s, s ∈ 𝓤 α → ∃ t ∈ 𝓤 β, ∀ x y : α, (f x, f y) ∈ t → (x, y) ∈ s :=
  by
  simp only [uniform_embedding_def, uniform_continuous_def] <;>
    exact
      ⟨fun ⟨I, H⟩ => ⟨I, fun s su => (H _).2 ⟨s, su, fun x y => id⟩, fun s => (H s).1⟩,
        fun ⟨I, H₁, H₂⟩ =>
        ⟨I, fun s => ⟨H₂ s, fun ⟨t, tu, h⟩ => mem_of_superset (H₁ t tu) fun ⟨a, b⟩ => h a b⟩⟩⟩
#align uniform_embedding_def' uniform_embedding_def'

theorem Equiv.uniform_embedding {α β : Type _} [UniformSpace α] [UniformSpace β] (f : α ≃ β)
    (h₁ : UniformContinuous f) (h₂ : UniformContinuous f.symm) : UniformEmbedding f :=
  { comap_uniformity := by
      refine' le_antisymm _ _
      · change comap (f.prod_congr f) _ ≤ _
        rw [← map_equiv_symm (f.prod_congr f)]
        exact h₂
      · rw [← map_le_iff_le_comap]
        exact h₁
    inj := f.Injective }
#align equiv.uniform_embedding Equiv.uniform_embedding

theorem uniform_embedding_inl : UniformEmbedding (Sum.inl : α → Sum α β) :=
  by
  apply uniform_embedding_def.2 ⟨Sum.inl_injective, fun s => ⟨_, _⟩⟩
  · intro hs
    refine'
      ⟨(fun p : α × α => (Sum.inl p.1, Sum.inl p.2)) '' s ∪
          (fun p : β × β => (Sum.inr p.1, Sum.inr p.2)) '' univ,
        _, _⟩
    · exact union_mem_uniformity_sum hs univ_mem
    · simp
  · rintro ⟨t, ht, h't⟩
    simp only [Sum.uniformity, mem_sup, mem_map] at ht
    apply Filter.mem_of_superset ht.1
    rintro ⟨x, y⟩ hx
    exact h't _ _ hx
#align uniform_embedding_inl uniform_embedding_inl

theorem uniform_embedding_inr : UniformEmbedding (Sum.inr : β → Sum α β) :=
  by
  apply uniform_embedding_def.2 ⟨Sum.inr_injective, fun s => ⟨_, _⟩⟩
  · intro hs
    refine'
      ⟨(fun p : α × α => (Sum.inl p.1, Sum.inl p.2)) '' univ ∪
          (fun p : β × β => (Sum.inr p.1, Sum.inr p.2)) '' s,
        _, _⟩
    · exact union_mem_uniformity_sum univ_mem hs
    · simp
  · rintro ⟨t, ht, h't⟩
    simp only [Sum.uniformity, mem_sup, mem_map] at ht
    apply Filter.mem_of_superset ht.2
    rintro ⟨x, y⟩ hx
    exact h't _ _ hx
#align uniform_embedding_inr uniform_embedding_inr

/-- If the domain of a `uniform_inducing` map `f` is a `separated_space`, then `f` is injective,
hence it is a `uniform_embedding`. -/
protected theorem UniformInducing.uniform_embedding [SeparatedSpace α] {f : α → β}
    (hf : UniformInducing f) : UniformEmbedding f :=
  ⟨hf, fun x y h =>
    (eq_of_uniformity_basis (hf.basis_uniformity (𝓤 β).basis_sets)) fun s hs =>
      mem_preimage.2 <| mem_uniformity_of_eq hs h⟩
#align uniform_inducing.uniform_embedding UniformInducing.uniform_embedding

/-- If a map `f : α → β` sends any two distinct points to point that are **not** related by a fixed
`s ∈ 𝓤 β`, then `f` is uniform inducing with respect to the discrete uniformity on `α`:
the preimage of `𝓤 β` under `prod.map f f` is the principal filter generated by the diagonal in
`α × α`. -/
theorem comap_uniformity_of_spaced_out {α} {f : α → β} {s : Set (β × β)} (hs : s ∈ 𝓤 β)
    (hf : Pairwise fun x y => (f x, f y) ∉ s) : comap (Prod.map f f) (𝓤 β) = 𝓟 idRel :=
  by
  refine' le_antisymm _ (@refl_le_uniformity α (UniformSpace.comap f ‹_›))
  calc
    comap (Prod.map f f) (𝓤 β) ≤ comap (Prod.map f f) (𝓟 s) := comap_mono (le_principal_iff.2 hs)
    _ = 𝓟 (Prod.map f f ⁻¹' s) := comap_principal
    _ ≤ 𝓟 idRel := principal_mono.2 _
    
  rintro ⟨x, y⟩; simpa [not_imp_not] using @hf x y
#align comap_uniformity_of_spaced_out comap_uniformity_of_spaced_out

/-- If a map `f : α → β` sends any two distinct points to point that are **not** related by a fixed
`s ∈ 𝓤 β`, then `f` is a uniform embedding with respect to the discrete uniformity on `α`. -/
theorem uniform_embedding_of_spaced_out {α} {f : α → β} {s : Set (β × β)} (hs : s ∈ 𝓤 β)
    (hf : Pairwise fun x y => (f x, f y) ∉ s) : @UniformEmbedding α β ⊥ ‹_› f :=
  by
  letI : UniformSpace α := ⊥; haveI : SeparatedSpace α := separated_iff_t2.2 inferInstance
  exact UniformInducing.uniform_embedding ⟨comap_uniformity_of_spaced_out hs hf⟩
#align uniform_embedding_of_spaced_out uniform_embedding_of_spaced_out

theorem UniformInducing.uniform_continuous {f : α → β} (hf : UniformInducing f) :
    UniformContinuous f := by simp [UniformContinuous, hf.comap_uniformity.symm, tendsto_comap]
#align uniform_inducing.uniform_continuous UniformInducing.uniform_continuous

theorem UniformInducing.uniform_continuous_iff {f : α → β} {g : β → γ} (hg : UniformInducing g) :
    UniformContinuous f ↔ UniformContinuous (g ∘ f) :=
  by
  dsimp only [UniformContinuous, tendsto]
  rw [← hg.comap_uniformity, ← map_le_iff_le_comap, Filter.map_map]
#align uniform_inducing.uniform_continuous_iff UniformInducing.uniform_continuous_iff

theorem UniformInducing.inducing {f : α → β} (h : UniformInducing f) : Inducing f :=
  by
  refine' ⟨eq_of_nhds_eq_nhds fun a => _⟩
  rw [nhds_induced, nhds_eq_uniformity, nhds_eq_uniformity, ← h.comap_uniformity, comap_lift'_eq,
    comap_lift'_eq2]
  exacts[rfl, monotone_preimage]
#align uniform_inducing.inducing UniformInducing.inducing

theorem UniformInducing.prod {α' : Type _} {β' : Type _} [UniformSpace α'] [UniformSpace β']
    {e₁ : α → α'} {e₂ : β → β'} (h₁ : UniformInducing e₁) (h₂ : UniformInducing e₂) :
    UniformInducing fun p : α × β => (e₁ p.1, e₂ p.2) :=
  ⟨by
    simp [(· ∘ ·), uniformity_prod, h₁.comap_uniformity.symm, h₂.comap_uniformity.symm, comap_inf,
      comap_comap]⟩
#align uniform_inducing.prod UniformInducing.prod

theorem UniformInducing.dense_inducing {f : α → β} (h : UniformInducing f) (hd : DenseRange f) :
    DenseInducing f :=
  { dense := hd
    induced := h.Inducing.induced }
#align uniform_inducing.dense_inducing UniformInducing.dense_inducing

theorem UniformEmbedding.embedding {f : α → β} (h : UniformEmbedding f) : Embedding f :=
  { induced := h.to_uniform_inducing.Inducing.induced
    inj := h.inj }
#align uniform_embedding.embedding UniformEmbedding.embedding

theorem UniformEmbedding.dense_embedding {f : α → β} (h : UniformEmbedding f) (hd : DenseRange f) :
    DenseEmbedding f :=
  { dense := hd
    inj := h.inj
    induced := h.Embedding.induced }
#align uniform_embedding.dense_embedding UniformEmbedding.dense_embedding

theorem closed_embedding_of_spaced_out {α} [TopologicalSpace α] [DiscreteTopology α]
    [SeparatedSpace β] {f : α → β} {s : Set (β × β)} (hs : s ∈ 𝓤 β)
    (hf : Pairwise fun x y => (f x, f y) ∉ s) : ClosedEmbedding f :=
  by
  rcases DiscreteTopology.eq_bot α with rfl; letI : UniformSpace α := ⊥
  exact
    { (uniform_embedding_of_spaced_out hs hf).Embedding with
      closed_range := is_closed_range_of_spaced_out hs hf }
#align closed_embedding_of_spaced_out closed_embedding_of_spaced_out

theorem closure_image_mem_nhds_of_uniform_inducing {s : Set (α × α)} {e : α → β} (b : β)
    (he₁ : UniformInducing e) (he₂ : DenseInducing e) (hs : s ∈ 𝓤 α) :
    ∃ a, closure (e '' { a' | (a, a') ∈ s }) ∈ 𝓝 b :=
  have : s ∈ comap (fun p : α × α => (e p.1, e p.2)) (𝓤 β) := he₁.comap_uniformity.symm ▸ hs
  let ⟨t₁, ht₁u, ht₁⟩ := this
  have ht₁ : ∀ p : α × α, (e p.1, e p.2) ∈ t₁ → p ∈ s := ht₁
  let ⟨t₂, ht₂u, ht₂s, ht₂c⟩ := comp_symm_of_uniformity ht₁u
  let ⟨t, htu, hts, htc⟩ := comp_symm_of_uniformity ht₂u
  have : preimage e { b' | (b, b') ∈ t₂ } ∈ comap e (𝓝 b) :=
    preimage_mem_comap <| mem_nhds_left b ht₂u
  let ⟨a, (ha : (b, e a) ∈ t₂)⟩ := (he₂.comap_nhds_ne_bot _).nonempty_of_mem this
  have :
    ∀ (b') (s' : Set (β × β)),
      (b, b') ∈ t →
        s' ∈ 𝓤 β → ({ y : β | (b', y) ∈ s' } ∩ e '' { a' : α | (a, a') ∈ s }).Nonempty :=
    fun b' s' hb' hs' =>
    have : preimage e { b'' | (b', b'') ∈ s' ∩ t } ∈ comap e (𝓝 b') :=
      preimage_mem_comap <| mem_nhds_left b' <| inter_mem hs' htu
    let ⟨a₂, ha₂s', ha₂t⟩ := (he₂.comap_nhds_ne_bot _).nonempty_of_mem this
    have : (e a, e a₂) ∈ t₁ :=
      ht₂c <| prod_mk_mem_comp_rel (ht₂s ha) <| htc <| prod_mk_mem_comp_rel hb' ha₂t
    have : e a₂ ∈ { b'' : β | (b', b'') ∈ s' } ∩ e '' { a' | (a, a') ∈ s } :=
      ⟨ha₂s', mem_image_of_mem _ <| ht₁ (a, a₂) this⟩
    ⟨_, this⟩
  have : ∀ b', (b, b') ∈ t → NeBot (𝓝 b' ⊓ 𝓟 (e '' { a' | (a, a') ∈ s })) :=
    by
    intro b' hb'
    rw [nhds_eq_uniformity, lift'_inf_principal_eq, lift'_ne_bot_iff]
    exact fun s => this b' s hb'
    exact monotone_preimage.inter monotone_const
  have : ∀ b', (b, b') ∈ t → b' ∈ closure (e '' { a' | (a, a') ∈ s }) := fun b' hb' => by
    rw [closure_eq_cluster_pts] <;> exact this b' hb'
  ⟨a, (𝓝 b).sets_of_superset (mem_nhds_left b htu) this⟩
#align closure_image_mem_nhds_of_uniform_inducing closure_image_mem_nhds_of_uniform_inducing

theorem uniform_embedding_subtype_emb (p : α → Prop) {e : α → β} (ue : UniformEmbedding e)
    (de : DenseEmbedding e) : UniformEmbedding (DenseEmbedding.subtypeEmb p e) :=
  { comap_uniformity := by
      simp [comap_comap, (· ∘ ·), DenseEmbedding.subtypeEmb, uniformity_subtype,
        ue.comap_uniformity.symm]
    inj := (de.Subtype p).inj }
#align uniform_embedding_subtype_emb uniform_embedding_subtype_emb

theorem UniformEmbedding.prod {α' : Type _} {β' : Type _} [UniformSpace α'] [UniformSpace β']
    {e₁ : α → α'} {e₂ : β → β'} (h₁ : UniformEmbedding e₁) (h₂ : UniformEmbedding e₂) :
    UniformEmbedding fun p : α × β => (e₁ p.1, e₂ p.2) :=
  { h₁.to_uniform_inducing.Prod h₂.to_uniform_inducing with inj := h₁.inj.prod_map h₂.inj }
#align uniform_embedding.prod UniformEmbedding.prod

theorem is_complete_of_complete_image {m : α → β} {s : Set α} (hm : UniformInducing m)
    (hs : IsComplete (m '' s)) : IsComplete s :=
  by
  intro f hf hfs
  rw [le_principal_iff] at hfs
  obtain ⟨_, ⟨x, hx, rfl⟩, hyf⟩ : ∃ y ∈ m '' s, map m f ≤ 𝓝 y
  exact hs (f.map m) (hf.map hm.uniform_continuous) (le_principal_iff.2 (image_mem_map hfs))
  rw [map_le_iff_le_comap, ← nhds_induced, ← hm.inducing.induced] at hyf
  exact ⟨x, hx, hyf⟩
#align is_complete_of_complete_image is_complete_of_complete_image

theorem IsComplete.complete_space_coe {s : Set α} (hs : IsComplete s) : CompleteSpace s :=
  complete_space_iff_is_complete_univ.2 <|
    is_complete_of_complete_image uniform_embedding_subtype_coe.to_uniform_inducing <| by simp [hs]
#align is_complete.complete_space_coe IsComplete.complete_space_coe

/-- A set is complete iff its image under a uniform inducing map is complete. -/
theorem is_complete_image_iff {m : α → β} {s : Set α} (hm : UniformInducing m) :
    IsComplete (m '' s) ↔ IsComplete s :=
  by
  refine' ⟨is_complete_of_complete_image hm, fun c => _⟩
  haveI : CompleteSpace s := c.complete_space_coe
  set m' : s → β := m ∘ coe
  suffices IsComplete (range m') by rwa [range_comp, Subtype.range_coe] at this
  have hm' : UniformInducing m' := hm.comp uniform_embedding_subtype_coe.to_uniform_inducing
  intro f hf hfm
  rw [Filter.le_principal_iff] at hfm
  have cf' : Cauchy (comap m' f) :=
    hf.comap' hm'.comap_uniformity.le (ne_bot.comap_of_range_mem hf.1 hfm)
  rcases CompleteSpace.complete cf' with ⟨x, hx⟩
  rw [hm'.inducing.nhds_eq_comap, comap_le_comap_iff hfm] at hx
  use m' x, mem_range_self _, hx
#align is_complete_image_iff is_complete_image_iff

theorem complete_space_iff_is_complete_range {f : α → β} (hf : UniformInducing f) :
    CompleteSpace α ↔ IsComplete (range f) := by
  rw [complete_space_iff_is_complete_univ, ← is_complete_image_iff hf, image_univ]
#align complete_space_iff_is_complete_range complete_space_iff_is_complete_range

theorem UniformInducing.is_complete_range [CompleteSpace α] {f : α → β} (hf : UniformInducing f) :
    IsComplete (range f) :=
  (complete_space_iff_is_complete_range hf).1 ‹_›
#align uniform_inducing.is_complete_range UniformInducing.is_complete_range

theorem complete_space_congr {e : α ≃ β} (he : UniformEmbedding e) :
    CompleteSpace α ↔ CompleteSpace β := by
  rw [complete_space_iff_is_complete_range he.to_uniform_inducing, e.range_eq_univ,
    complete_space_iff_is_complete_univ]
#align complete_space_congr complete_space_congr

theorem complete_space_coe_iff_is_complete {s : Set α} : CompleteSpace s ↔ IsComplete s :=
  (complete_space_iff_is_complete_range uniform_embedding_subtype_coe.to_uniform_inducing).trans <|
    by rw [Subtype.range_coe]
#align complete_space_coe_iff_is_complete complete_space_coe_iff_is_complete

theorem IsClosed.complete_space_coe [CompleteSpace α] {s : Set α} (hs : IsClosed s) :
    CompleteSpace s :=
  hs.IsComplete.complete_space_coe
#align is_closed.complete_space_coe IsClosed.complete_space_coe

/-- The lift of a complete space to another universe is still complete. -/
instance ULift.complete_space [h : CompleteSpace α] : CompleteSpace (ULift α) :=
  haveI : UniformEmbedding (@Equiv.ulift α) := ⟨⟨rfl⟩, ULift.down_injective⟩
  (complete_space_congr this).2 h
#align ulift.complete_space ULift.complete_space

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem complete_space_extension {m : β → α} (hm : UniformInducing m) (dense : DenseRange m)
    (h : ∀ f : Filter β, Cauchy f → ∃ x : α, map m f ≤ 𝓝 x) : CompleteSpace α :=
  ⟨fun f : Filter α => fun hf : Cauchy f =>
    let p : Set (α × α) → Set α → Set α := fun s t => { y : α | ∃ x : α, x ∈ t ∧ (x, y) ∈ s }
    let g := (𝓤 α).lift fun s => f.lift' (p s)
    have mp₀ : Monotone p := fun a b h t s ⟨x, xs, xa⟩ => ⟨x, xs, h xa⟩
    have mp₁ : ∀ {s}, Monotone (p s) := fun s a b h x ⟨y, ya, yxs⟩ => ⟨y, h ya, yxs⟩
    have : f ≤ g :=
      le_infᵢ fun s =>
        le_infᵢ fun hs =>
          le_infᵢ fun t =>
            le_infᵢ fun ht =>
              le_principal_iff.mpr <|
                (mem_of_superset ht) fun x hx => ⟨x, hx, refl_mem_uniformity hs⟩
    have : NeBot g := hf.left.mono this
    have : NeBot (comap m g) :=
      comap_ne_bot fun t ht =>
        let ⟨t', ht', ht_mem⟩ := (mem_lift_sets <| monotone_lift' monotone_const mp₀).mp ht
        let ⟨t'', ht'', ht'_sub⟩ := (mem_lift'_sets mp₁).mp ht_mem
        let ⟨x, (hx : x ∈ t'')⟩ := hf.left.nonempty_of_mem ht''
        have h₀ : NeBot (𝓝[range m] x) := Dense.nhds_within_ne_bot x
        have h₁ : { y | (x, y) ∈ t' } ∈ 𝓝[range m] x :=
          @mem_inf_of_left α (𝓝 x) (𝓟 (range m)) _ <| mem_nhds_left x ht'
        have h₂ : range m ∈ 𝓝[range m] x :=
          @mem_inf_of_right α (𝓝 x) (𝓟 (range m)) _ <| Subset.refl _
        have : { y | (x, y) ∈ t' } ∩ range m ∈ 𝓝[range m] x := @inter_mem α (𝓝[range m] x) _ _ h₁ h₂
        let ⟨y, xyt', b, b_eq⟩ := h₀.nonempty_of_mem this
        ⟨b, b_eq.symm ▸ ht'_sub ⟨x, hx, xyt'⟩⟩
    have : Cauchy g :=
      ⟨‹NeBot g›, fun s hs =>
        let ⟨s₁, hs₁, (comp_s₁ : compRel s₁ s₁ ⊆ s)⟩ := comp_mem_uniformity_sets hs
        let ⟨s₂, hs₂, (comp_s₂ : compRel s₂ s₂ ⊆ s₁)⟩ := comp_mem_uniformity_sets hs₁
        let ⟨t, ht, (prod_t : t ×ˢ t ⊆ s₂)⟩ := mem_prod_same_iff.mp (hf.right hs₂)
        have hg₁ : p (preimage Prod.swap s₁) t ∈ g :=
          mem_lift (symm_le_uniformity hs₁) <| @mem_lift' α α f _ t ht
        have hg₂ : p s₂ t ∈ g := mem_lift hs₂ <| @mem_lift' α α f _ t ht
        have hg : p (Prod.swap ⁻¹' s₁) t ×ˢ p s₂ t ∈ g ×ᶠ g := @prod_mem_prod α α _ _ g g hg₁ hg₂
        (g ×ᶠ g).sets_of_superset hg fun ⟨a, b⟩ ⟨⟨c₁, c₁t, hc₁⟩, ⟨c₂, c₂t, hc₂⟩⟩ =>
          have : (c₁, c₂) ∈ t ×ˢ t := ⟨c₁t, c₂t⟩
          comp_s₁ <| prod_mk_mem_comp_rel hc₁ <| comp_s₂ <| prod_mk_mem_comp_rel (prod_t this) hc₂⟩
    have : Cauchy (Filter.comap m g) := ‹Cauchy g›.comap' (le_of_eq hm.comap_uniformity) ‹_›
    let ⟨x, (hx : map m (Filter.comap m g) ≤ 𝓝 x)⟩ := h _ this
    have : ClusterPt x (map m (Filter.comap m g)) :=
      (le_nhds_iff_adhp_of_cauchy (this.map hm.UniformContinuous)).mp hx
    have : ClusterPt x g := this.mono map_comap_le
    ⟨x,
      calc
        f ≤ g := by assumption
        _ ≤ 𝓝 x := le_nhds_of_cauchy_adhp ‹Cauchy g› this
        ⟩⟩
#align complete_space_extension complete_space_extension

theorem totally_bounded_preimage {f : α → β} {s : Set β} (hf : UniformEmbedding f)
    (hs : TotallyBounded s) : TotallyBounded (f ⁻¹' s) := fun t ht =>
  by
  rw [← hf.comap_uniformity] at ht
  rcases mem_comap.2 ht with ⟨t', ht', ts⟩
  rcases totally_bounded_iff_subset.1 (totally_bounded_subset (image_preimage_subset f s) hs) _
      ht' with
    ⟨c, cs, hfc, hct⟩
  refine' ⟨f ⁻¹' c, hfc.preimage (hf.inj.inj_on _), fun x h => _⟩
  have := hct (mem_image_of_mem f h); simp at this⊢
  rcases this with ⟨z, zc, zt⟩
  rcases cs zc with ⟨y, yc, rfl⟩
  exact ⟨y, zc, ts zt⟩
#align totally_bounded_preimage totally_bounded_preimage

instance CompleteSpace.sum [CompleteSpace α] [CompleteSpace β] : CompleteSpace (Sum α β) :=
  by
  rw [complete_space_iff_is_complete_univ, ← range_inl_union_range_inr]
  exact
    uniform_embedding_inl.to_uniform_inducing.is_complete_range.union
      uniform_embedding_inr.to_uniform_inducing.is_complete_range
#align complete_space.sum CompleteSpace.sum

end

theorem uniform_embedding_comap {α : Type _} {β : Type _} {f : α → β} [u : UniformSpace β]
    (hf : Function.Injective f) : @UniformEmbedding α β (UniformSpace.comap f u) u f :=
  @UniformEmbedding.mk _ _ (UniformSpace.comap f u) _ _
    (@UniformInducing.mk _ _ (UniformSpace.comap f u) _ _ rfl) hf
#align uniform_embedding_comap uniform_embedding_comap

/-- Pull back a uniform space structure by an embedding, adjusting the new uniform structure to
make sure that its topology is defeq to the original one. -/
def Embedding.comapUniformSpace {α β} [TopologicalSpace α] [u : UniformSpace β] (f : α → β)
    (h : Embedding f) : UniformSpace α :=
  (u.comap f).replaceTopology h.induced
#align embedding.comap_uniform_space Embedding.comapUniformSpace

theorem Embedding.to_uniform_embedding {α β} [TopologicalSpace α] [u : UniformSpace β] (f : α → β)
    (h : Embedding f) : @UniformEmbedding α β (h.comapUniformSpace f) u f :=
  { comap_uniformity := rfl
    inj := h.inj }
#align embedding.to_uniform_embedding Embedding.to_uniform_embedding

section UniformExtension

variable {α : Type _} {β : Type _} {γ : Type _} [UniformSpace α] [UniformSpace β] [UniformSpace γ]
  {e : β → α} (h_e : UniformInducing e) (h_dense : DenseRange e) {f : β → γ}
  (h_f : UniformContinuous f)

-- mathport name: exprψ
local notation "ψ" => (h_e.DenseInducing h_dense).extend f

theorem uniformly_extend_exists [CompleteSpace γ] (a : α) : ∃ c, Tendsto f (comap e (𝓝 a)) (𝓝 c) :=
  let de := h_e.DenseInducing h_dense
  have : Cauchy (𝓝 a) := cauchy_nhds
  have : Cauchy (comap e (𝓝 a)) :=
    this.comap' (le_of_eq h_e.comap_uniformity) (de.comap_nhds_ne_bot _)
  have : Cauchy (map f (comap e (𝓝 a))) := this.map h_f
  CompleteSpace.complete this
#align uniformly_extend_exists uniformly_extend_exists

theorem uniform_extend_subtype [CompleteSpace γ] {p : α → Prop} {e : α → β} {f : α → γ} {b : β}
    {s : Set α} (hf : UniformContinuous fun x : Subtype p => f x.val) (he : UniformEmbedding e)
    (hd : ∀ x : β, x ∈ closure (range e)) (hb : closure (e '' s) ∈ 𝓝 b) (hs : IsClosed s)
    (hp : ∀ x ∈ s, p x) : ∃ c, Tendsto f (comap e (𝓝 b)) (𝓝 c) :=
  by
  have de : DenseEmbedding e := he.DenseEmbedding hd
  have de' : DenseEmbedding (DenseEmbedding.subtypeEmb p e) := de.subtype p
  have ue' : UniformEmbedding (DenseEmbedding.subtypeEmb p e) :=
    uniform_embedding_subtype_emb _ he de
  have : b ∈ closure (e '' { x | p x }) :=
    (closure_mono <| monotone_image <| hp) (mem_of_mem_nhds hb)
  let
    ⟨c,
      (hc :
        tendsto (f ∘ Subtype.val) (comap (DenseEmbedding.subtypeEmb p e) (𝓝 ⟨b, this⟩)) (𝓝 c))⟩ :=
    uniformly_extend_exists ue'.to_uniform_inducing de'.dense hf _
  rw [nhds_subtype_eq_comap] at hc
  simp [comap_comap] at hc
  change tendsto (f ∘ @Subtype.val α p) (comap (e ∘ @Subtype.val α p) (𝓝 b)) (𝓝 c) at hc
  rw [← comap_comap, tendsto_comap'_iff] at hc
  exact ⟨c, hc⟩
  exact
    ⟨_, hb, fun x => by
      change e x ∈ closure (e '' s) → x ∈ range Subtype.val
      rw [← closure_induced, mem_closure_iff_cluster_pt, ClusterPt, ne_bot_iff, nhds_induced, ←
        de.to_dense_inducing.nhds_eq_comap, ← mem_closure_iff_nhds_ne_bot, hs.closure_eq]
      exact fun hxs => ⟨⟨x, hp x hxs⟩, rfl⟩⟩
#align uniform_extend_subtype uniform_extend_subtype

include h_f

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `uniformly_extend_spec [])
      (Command.declSig
       [(Term.instBinder "[" [] (Term.app `CompleteSpace [`γ]) "]")
        (Term.explicitBinder "(" [`a] [":" `α] [] ")")]
       (Term.typeSpec
        ":"
        (Term.app
         `Tendsto
         [`f
          (Term.app `comap [`e (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`a])])
          (Term.app
           (TopologicalSpace.Topology.Basic.nhds "𝓝")
           [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a])])])))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Std.Tactic.Simpa.simpa
            "simpa"
            []
            []
            (Std.Tactic.Simpa.simpaArgsRest
             []
             []
             ["only"]
             [(Tactic.simpArgs "[" [(Tactic.simpLemma [] [] `DenseInducing.extend)] "]")]
             ["using"
              (Term.app
               `tendsto_nhds_lim
               [(Term.app
                 `uniformly_extend_exists
                 [`h_e («term‹_›» "‹" (Term.hole "_") "›") `h_f (Term.hole "_")])])]))])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Std.Tactic.Simpa.simpa
           "simpa"
           []
           []
           (Std.Tactic.Simpa.simpaArgsRest
            []
            []
            ["only"]
            [(Tactic.simpArgs "[" [(Tactic.simpLemma [] [] `DenseInducing.extend)] "]")]
            ["using"
             (Term.app
              `tendsto_nhds_lim
              [(Term.app
                `uniformly_extend_exists
                [`h_e («term‹_›» "‹" (Term.hole "_") "›") `h_f (Term.hole "_")])])]))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.Simpa.simpa
       "simpa"
       []
       []
       (Std.Tactic.Simpa.simpaArgsRest
        []
        []
        ["only"]
        [(Tactic.simpArgs "[" [(Tactic.simpLemma [] [] `DenseInducing.extend)] "]")]
        ["using"
         (Term.app
          `tendsto_nhds_lim
          [(Term.app
            `uniformly_extend_exists
            [`h_e («term‹_›» "‹" (Term.hole "_") "›") `h_f (Term.hole "_")])])]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       `tendsto_nhds_lim
       [(Term.app
         `uniformly_extend_exists
         [`h_e («term‹_›» "‹" (Term.hole "_") "›") `h_f (Term.hole "_")])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       `uniformly_extend_exists
       [`h_e («term‹_›» "‹" (Term.hole "_") "›") `h_f (Term.hole "_")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, term))
      `h_f
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1023, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term‹_›»', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term‹_›»', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      («term‹_›» "‹" (Term.hole "_") "›")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, term))
      `h_e
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1023, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `uniformly_extend_exists
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app
      `uniformly_extend_exists
      [`h_e («term‹_›» "‹" (Term.hole "_") "›") `h_f (Term.hole "_")])
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `tendsto_nhds_lim
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpStar'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.simpLemma', expected 'Lean.Parser.Tactic.simpErase'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `DenseInducing.extend
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      (Term.app
       `Tendsto
       [`f
        (Term.app `comap [`e (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`a])])
        (Term.app
         (TopologicalSpace.Topology.Basic.nhds "𝓝")
         [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a])])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       (TopologicalSpace.Topology.Basic.nhds "𝓝")
       [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `a
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Topology.UniformSpace.UniformEmbedding.termψ', expected 'Topology.UniformSpace.UniformEmbedding.termψ._@.Topology.UniformSpace.UniformEmbedding._hyg.9'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  uniformly_extend_spec
  [ CompleteSpace γ ] ( a : α ) : Tendsto f comap e 𝓝 a 𝓝 ψ a
  :=
    by
      simpa
        only [ DenseInducing.extend ] using tendsto_nhds_lim uniformly_extend_exists h_e ‹ _ › h_f _
#align uniformly_extend_spec uniformly_extend_spec

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `uniform_continuous_uniformly_extend [])
      (Command.declSig
       [(Term.instBinder "[" [`cγ ":"] (Term.app `CompleteSpace [`γ]) "]")]
       (Term.typeSpec
        ":"
        (Term.app `UniformContinuous [(Topology.UniformSpace.UniformEmbedding.termψ "ψ")])))
      (Command.declValSimple
       ":="
       (Term.fun
        "fun"
        (Term.basicFun
         [`d `hd]
         []
         "=>"
         (Term.let
          "let"
          (Term.letDecl
           (Term.letPatDecl
            (Term.anonymousCtor "⟨" [`s "," `hs "," `hs_comp] "⟩")
            []
            []
            ":="
            (Term.app
             (Term.proj
              («term_<|_»
               `mem_lift'_sets
               "<|"
               («term_<|_»
                (Term.app `monotone_comp_rel [`monotone_id])
                "<|"
                (Term.app `monotone_comp_rel [`monotone_id `monotone_id])))
              "."
              `mp)
             [(Term.app `comp_le_uniformity3 [`hd])])))
          []
          (Term.have
           "have"
           (Term.haveDecl
            (Term.haveIdDecl
             [`h_pnt []]
             [(Term.typeSpec
               ":"
               (Term.forall
                "∀"
                [(Term.implicitBinder "{" [`a `m] [] "}")]
                []
                ","
                (Term.arrow
                 («term_∈_» `m "∈" (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`a]))
                 "→"
                 («term∃_,_»
                  "∃"
                  (Lean.explicitBinders
                   (Lean.unbracketedExplicitBinders [(Lean.binderIdent `c)] []))
                  ","
                  («term_∧_»
                   («term_∈_»
                    `c
                    "∈"
                    (Set.Data.Set.Image.term_''_ `f " '' " (Term.app `preimage [`e `m])))
                   "∧"
                   («term_∧_»
                    («term_∈_»
                     (Term.tuple
                      "("
                      [`c "," [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a])]]
                      ")")
                     "∈"
                     `s)
                    "∧"
                    («term_∈_»
                     (Term.tuple
                      "("
                      [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a]) "," [`c]]
                      ")")
                     "∈"
                     `s)))))))]
             ":="
             (Term.fun
              "fun"
              (Term.basicFun
               [`a `m `hm]
               []
               "=>"
               (Term.have
                "have"
                (Term.haveDecl
                 (Term.haveIdDecl
                  [`nb []]
                  [(Term.typeSpec
                    ":"
                    (Term.app
                     `NeBot
                     [(Term.app
                       `map
                       [`f
                        (Term.app
                         `comap
                         [`e (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`a])])])]))]
                  ":="
                  (Term.app
                   (Term.proj
                    (Term.app
                     (Term.proj
                      (Term.app (Term.proj `h_e "." `DenseInducing) [`h_dense])
                      "."
                      `comap_nhds_ne_bot)
                     [(Term.hole "_")])
                    "."
                    `map)
                   [(Term.hole "_")])))
                []
                (Term.have
                 "have"
                 (Term.haveDecl
                  (Term.haveIdDecl
                   []
                   [(Term.typeSpec
                     ":"
                     («term_∈_»
                      («term_∩_»
                       (Set.Data.Set.Image.term_''_ `f " '' " (Term.app `preimage [`e `m]))
                       "∩"
                       («term_∩_»
                        (Set.«term{_|_}»
                         "{"
                         (Std.ExtendedBinder.extBinder (Lean.binderIdent `c) [])
                         "|"
                         («term_∈_»
                          (Term.tuple
                           "("
                           [`c
                            ","
                            [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a])]]
                           ")")
                          "∈"
                          `s)
                         "}")
                        "∩"
                        (Set.«term{_|_}»
                         "{"
                         (Std.ExtendedBinder.extBinder (Lean.binderIdent `c) [])
                         "|"
                         («term_∈_»
                          (Term.tuple
                           "("
                           [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a])
                            ","
                            [`c]]
                           ")")
                          "∈"
                          `s)
                         "}")))
                      "∈"
                      (Term.app
                       `map
                       [`f
                        (Term.app
                         `comap
                         [`e (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`a])])])))]
                   ":="
                   (Term.app
                    `inter_mem
                    [(«term_<|_» `image_mem_map "<|" («term_<|_» `preimage_mem_comap "<|" `hm))
                     (Term.app
                      `uniformly_extend_spec
                      [`h_e
                       `h_dense
                       `h_f
                       (Term.hole "_")
                       (Term.app
                        `inter_mem
                        [(Term.app `mem_nhds_right [(Term.hole "_") `hs])
                         (Term.app `mem_nhds_left [(Term.hole "_") `hs])])])])))
                 []
                 (Term.app (Term.proj `nb "." `nonempty_of_mem) [`this])))))))
           []
           (Term.have
            "have"
            (Term.haveDecl
             (Term.haveIdDecl
              []
              [(Term.typeSpec
                ":"
                («term_∈_»
                 (Term.app
                  `preimage
                  [(Term.fun
                    "fun"
                    (Term.basicFun
                     [`p]
                     [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                     "=>"
                     (Term.tuple
                      "("
                      [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                       ","
                       [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                      ")")))
                   `s])
                 "∈"
                 (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`β])))]
              ":="
              (Term.app `h_f [`hs])))
            []
            (Term.have
             "have"
             (Term.haveDecl
              (Term.haveIdDecl
               []
               [(Term.typeSpec
                 ":"
                 («term_∈_»
                  (Term.app
                   `preimage
                   [(Term.fun
                     "fun"
                     (Term.basicFun
                      [`p]
                      [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                      "=>"
                      (Term.tuple
                       "("
                       [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                        ","
                        [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                       ")")))
                    `s])
                  "∈"
                  (Term.app
                   `comap
                   [(Term.fun
                     "fun"
                     (Term.basicFun
                      [`x]
                      [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                      "=>"
                      (Term.tuple
                       "("
                       [(Term.app `e [(Term.proj `x "." (fieldIdx "1"))])
                        ","
                        [(Term.app `e [(Term.proj `x "." (fieldIdx "2"))])]]
                       ")")))
                    (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α])])))]
               ":="
               (Term.byTactic
                "by"
                (Tactic.tacticSeq
                 (Tactic.tacticSeq1Indented
                  [(Std.Tactic.tacticRwa__
                    "rwa"
                    (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `h_e.comap_uniformity.symm)] "]")
                    [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
             []
             (Term.let
              "let"
              (Term.letDecl
               (Term.letPatDecl (Term.anonymousCtor "⟨" [`t "," `ht "," `ts] "⟩") [] [] ":=" `this))
              []
              (Term.show
               "show"
               («term_∈_»
                (Term.app
                 `preimage
                 [(Term.fun
                   "fun"
                   (Term.basicFun
                    [`p]
                    [(Term.typeSpec ":" («term_×_» `α "×" `α))]
                    "=>"
                    (Term.tuple
                     "("
                     [(Term.app
                       (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                       [(Term.proj `p "." (fieldIdx "1"))])
                      ","
                      [(Term.app
                        (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                        [(Term.proj `p "." (fieldIdx "2"))])]]
                     ")")))
                  `d])
                "∈"
                (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α]))
               (Term.fromTerm
                "from"
                (Term.app
                 (Term.app
                  (Term.proj
                   (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α])
                   "."
                   `sets_of_superset)
                  [(Term.app `interior_mem_uniformity [`ht])])
                 [(Term.fun
                   "fun"
                   (Term.basicFun
                    [(Term.anonymousCtor "⟨" [`x₁ "," `x₂] "⟩") `hx_t]
                    []
                    "=>"
                    (Term.have
                     "have"
                     (Term.haveDecl
                      (Term.haveIdDecl
                       []
                       [(Term.typeSpec
                         ":"
                         («term_≤_»
                          (Term.app
                           (TopologicalSpace.Topology.Basic.nhds "𝓝")
                           [(Term.tuple "(" [`x₁ "," [`x₂]] ")")])
                          "≤"
                          (Term.app
                           (Filter.Order.Filter.Basic.filter.principal "𝓟")
                           [(Term.app `interior [`t])])))]
                       ":="
                       (Term.app
                        (Term.proj `is_open_iff_nhds "." `mp)
                        [`is_open_interior (Term.tuple "(" [`x₁ "," [`x₂]] ")") `hx_t])))
                     []
                     (Term.have
                      "have"
                      (Term.haveDecl
                       (Term.haveIdDecl
                        []
                        [(Term.typeSpec
                          ":"
                          («term_∈_»
                           (Term.app `interior [`t])
                           "∈"
                           (Filter.Order.Filter.Prod.filter.prod
                            (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₁])
                            " ×ᶠ "
                            (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₂]))))]
                        ":="
                        (Term.byTactic
                         "by"
                         (Tactic.tacticSeq
                          (Tactic.tacticSeq1Indented
                           [(Std.Tactic.tacticRwa__
                             "rwa"
                             (Tactic.rwRuleSeq
                              "["
                              [(Tactic.rwRule [] `nhds_prod_eq)
                               ","
                               (Tactic.rwRule [] `le_principal_iff)]
                              "]")
                             [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
                      []
                      (Term.let
                       "let"
                       (Term.letDecl
                        (Term.letPatDecl
                         (Term.anonymousCtor
                          "⟨"
                          [`m₁
                           ","
                           `hm₁
                           ","
                           `m₂
                           ","
                           `hm₂
                           ","
                           (Term.typeAscription
                            "("
                            `hm
                            ":"
                            [(«term_⊆_»
                              (LowerSet.Order.UpperLower.lower_set.prod `m₁ " ×ˢ " `m₂)
                              "⊆"
                              (Term.app `interior [`t]))]
                            ")")]
                          "⟩")
                         []
                         []
                         ":="
                         (Term.app (Term.proj `mem_prod_iff "." `mp) [`this])))
                       []
                       (Term.let
                        "let"
                        (Term.letDecl
                         (Term.letPatDecl
                          (Term.anonymousCtor "⟨" [`a "," `ha₁ "," (Term.hole "_") "," `ha₂] "⟩")
                          []
                          []
                          ":="
                          (Term.app `h_pnt [`hm₁])))
                        []
                        (Term.let
                         "let"
                         (Term.letDecl
                          (Term.letPatDecl
                           (Term.anonymousCtor "⟨" [`b "," `hb₁ "," `hb₂ "," (Term.hole "_")] "⟩")
                           []
                           []
                           ":="
                           (Term.app `h_pnt [`hm₂])))
                         []
                         (Term.have
                          "have"
                          (Term.haveDecl
                           (Term.haveIdDecl
                            []
                            [(Term.typeSpec
                              ":"
                              («term_⊆_»
                               (LowerSet.Order.UpperLower.lower_set.prod
                                (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                                " ×ˢ "
                                (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
                               "⊆"
                               (Set.Data.Set.Image.«term_⁻¹'_»
                                (Term.fun
                                 "fun"
                                 (Term.basicFun
                                  [`p]
                                  [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                  "=>"
                                  (Term.tuple
                                   "("
                                   [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                    ","
                                    [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                   ")")))
                                " ⁻¹' "
                                `s)))]
                            ":="
                            (calc
                             "calc"
                             (calcStep
                              («term_⊆_»
                               (Term.hole "_")
                               "⊆"
                               (Term.app
                                `preimage
                                [(Term.fun
                                  "fun"
                                  (Term.basicFun
                                   [`p]
                                   [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                   "=>"
                                   (Term.tuple
                                    "("
                                    [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                                     ","
                                     [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                                    ")")))
                                 (Term.app `interior [`t])]))
                              ":="
                              (Term.app `preimage_mono [`hm]))
                             [(calcStep
                               («term_⊆_»
                                (Term.hole "_")
                                "⊆"
                                (Term.app
                                 `preimage
                                 [(Term.fun
                                   "fun"
                                   (Term.basicFun
                                    [`p]
                                    [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                    "=>"
                                    (Term.tuple
                                     "("
                                     [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                                      ","
                                      [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                                     ")")))
                                  `t]))
                               ":="
                               (Term.app `preimage_mono [`interior_subset]))
                              (calcStep
                               («term_⊆_»
                                (Term.hole "_")
                                "⊆"
                                (Term.app
                                 `preimage
                                 [(Term.fun
                                   "fun"
                                   (Term.basicFun
                                    [`p]
                                    [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                    "=>"
                                    (Term.tuple
                                     "("
                                     [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                      ","
                                      [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                     ")")))
                                  `s]))
                               ":="
                               `ts)])))
                          []
                          (Term.have
                           "have"
                           (Term.haveDecl
                            (Term.haveIdDecl
                             []
                             [(Term.typeSpec
                               ":"
                               («term_⊆_»
                                (LowerSet.Order.UpperLower.lower_set.prod
                                 (Set.Data.Set.Image.term_''_
                                  `f
                                  " '' "
                                  (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                                 " ×ˢ "
                                 (Set.Data.Set.Image.term_''_
                                  `f
                                  " '' "
                                  (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                                "⊆"
                                `s))]
                             ":="
                             (calc
                              "calc"
                              (calcStep
                               («term_=_»
                                (LowerSet.Order.UpperLower.lower_set.prod
                                 (Set.Data.Set.Image.term_''_
                                  `f
                                  " '' "
                                  (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                                 " ×ˢ "
                                 (Set.Data.Set.Image.term_''_
                                  `f
                                  " '' "
                                  (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                                "="
                                (Set.Data.Set.Image.term_''_
                                 (Term.fun
                                  "fun"
                                  (Term.basicFun
                                   [`p]
                                   [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                   "=>"
                                   (Term.tuple
                                    "("
                                    [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                     ","
                                     [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                    ")")))
                                 " '' "
                                 (LowerSet.Order.UpperLower.lower_set.prod
                                  (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                                  " ×ˢ "
                                  (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
                               ":="
                               `prod_image_image_eq)
                              [(calcStep
                                («term_⊆_»
                                 (Term.hole "_")
                                 "⊆"
                                 (Set.Data.Set.Image.term_''_
                                  (Term.fun
                                   "fun"
                                   (Term.basicFun
                                    [`p]
                                    [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                    "=>"
                                    (Term.tuple
                                     "("
                                     [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                      ","
                                      [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                     ")")))
                                  " '' "
                                  (Set.Data.Set.Image.«term_⁻¹'_»
                                   (Term.fun
                                    "fun"
                                    (Term.basicFun
                                     [`p]
                                     [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                     "=>"
                                     (Term.tuple
                                      "("
                                      [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                       ","
                                       [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                      ")")))
                                   " ⁻¹' "
                                   `s)))
                                ":="
                                (Term.app `monotone_image [`this]))
                               (calcStep
                                («term_⊆_» (Term.hole "_") "⊆" `s)
                                ":="
                                (Term.app
                                 `image_preimage_subset
                                 [(Term.hole "_") (Term.hole "_")]))])))
                           []
                           (Term.have
                            "have"
                            (Term.haveDecl
                             (Term.haveIdDecl
                              []
                              [(Term.typeSpec
                                ":"
                                («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
                              ":="
                              (Term.app
                               (Term.explicit "@" `this)
                               [(Term.tuple "(" [`a "," [`b]] ")")
                                (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
                            []
                            («term_<|_»
                             `hs_comp
                             "<|"
                             (Term.show
                              "show"
                              («term_∈_»
                               (Term.tuple
                                "("
                                [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
                                 ","
                                 [(Term.app
                                   (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                                   [`x₂])]]
                                ")")
                               "∈"
                               (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
                              (Term.fromTerm
                               "from"
                               (Term.anonymousCtor
                                "⟨"
                                [`a
                                 ","
                                 `ha₂
                                 ","
                                 (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
                                "⟩"))))))))))))))]))))))))))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`d `hd]
        []
        "=>"
        (Term.let
         "let"
         (Term.letDecl
          (Term.letPatDecl
           (Term.anonymousCtor "⟨" [`s "," `hs "," `hs_comp] "⟩")
           []
           []
           ":="
           (Term.app
            (Term.proj
             («term_<|_»
              `mem_lift'_sets
              "<|"
              («term_<|_»
               (Term.app `monotone_comp_rel [`monotone_id])
               "<|"
               (Term.app `monotone_comp_rel [`monotone_id `monotone_id])))
             "."
             `mp)
            [(Term.app `comp_le_uniformity3 [`hd])])))
         []
         (Term.have
          "have"
          (Term.haveDecl
           (Term.haveIdDecl
            [`h_pnt []]
            [(Term.typeSpec
              ":"
              (Term.forall
               "∀"
               [(Term.implicitBinder "{" [`a `m] [] "}")]
               []
               ","
               (Term.arrow
                («term_∈_» `m "∈" (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`a]))
                "→"
                («term∃_,_»
                 "∃"
                 (Lean.explicitBinders (Lean.unbracketedExplicitBinders [(Lean.binderIdent `c)] []))
                 ","
                 («term_∧_»
                  («term_∈_»
                   `c
                   "∈"
                   (Set.Data.Set.Image.term_''_ `f " '' " (Term.app `preimage [`e `m])))
                  "∧"
                  («term_∧_»
                   («term_∈_»
                    (Term.tuple
                     "("
                     [`c "," [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a])]]
                     ")")
                    "∈"
                    `s)
                   "∧"
                   («term_∈_»
                    (Term.tuple
                     "("
                     [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a]) "," [`c]]
                     ")")
                    "∈"
                    `s)))))))]
            ":="
            (Term.fun
             "fun"
             (Term.basicFun
              [`a `m `hm]
              []
              "=>"
              (Term.have
               "have"
               (Term.haveDecl
                (Term.haveIdDecl
                 [`nb []]
                 [(Term.typeSpec
                   ":"
                   (Term.app
                    `NeBot
                    [(Term.app
                      `map
                      [`f
                       (Term.app
                        `comap
                        [`e (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`a])])])]))]
                 ":="
                 (Term.app
                  (Term.proj
                   (Term.app
                    (Term.proj
                     (Term.app (Term.proj `h_e "." `DenseInducing) [`h_dense])
                     "."
                     `comap_nhds_ne_bot)
                    [(Term.hole "_")])
                   "."
                   `map)
                  [(Term.hole "_")])))
               []
               (Term.have
                "have"
                (Term.haveDecl
                 (Term.haveIdDecl
                  []
                  [(Term.typeSpec
                    ":"
                    («term_∈_»
                     («term_∩_»
                      (Set.Data.Set.Image.term_''_ `f " '' " (Term.app `preimage [`e `m]))
                      "∩"
                      («term_∩_»
                       (Set.«term{_|_}»
                        "{"
                        (Std.ExtendedBinder.extBinder (Lean.binderIdent `c) [])
                        "|"
                        («term_∈_»
                         (Term.tuple
                          "("
                          [`c
                           ","
                           [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a])]]
                          ")")
                         "∈"
                         `s)
                        "}")
                       "∩"
                       (Set.«term{_|_}»
                        "{"
                        (Std.ExtendedBinder.extBinder (Lean.binderIdent `c) [])
                        "|"
                        («term_∈_»
                         (Term.tuple
                          "("
                          [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a])
                           ","
                           [`c]]
                          ")")
                         "∈"
                         `s)
                        "}")))
                     "∈"
                     (Term.app
                      `map
                      [`f
                       (Term.app
                        `comap
                        [`e (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`a])])])))]
                  ":="
                  (Term.app
                   `inter_mem
                   [(«term_<|_» `image_mem_map "<|" («term_<|_» `preimage_mem_comap "<|" `hm))
                    (Term.app
                     `uniformly_extend_spec
                     [`h_e
                      `h_dense
                      `h_f
                      (Term.hole "_")
                      (Term.app
                       `inter_mem
                       [(Term.app `mem_nhds_right [(Term.hole "_") `hs])
                        (Term.app `mem_nhds_left [(Term.hole "_") `hs])])])])))
                []
                (Term.app (Term.proj `nb "." `nonempty_of_mem) [`this])))))))
          []
          (Term.have
           "have"
           (Term.haveDecl
            (Term.haveIdDecl
             []
             [(Term.typeSpec
               ":"
               («term_∈_»
                (Term.app
                 `preimage
                 [(Term.fun
                   "fun"
                   (Term.basicFun
                    [`p]
                    [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                    "=>"
                    (Term.tuple
                     "("
                     [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                      ","
                      [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                     ")")))
                  `s])
                "∈"
                (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`β])))]
             ":="
             (Term.app `h_f [`hs])))
           []
           (Term.have
            "have"
            (Term.haveDecl
             (Term.haveIdDecl
              []
              [(Term.typeSpec
                ":"
                («term_∈_»
                 (Term.app
                  `preimage
                  [(Term.fun
                    "fun"
                    (Term.basicFun
                     [`p]
                     [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                     "=>"
                     (Term.tuple
                      "("
                      [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                       ","
                       [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                      ")")))
                   `s])
                 "∈"
                 (Term.app
                  `comap
                  [(Term.fun
                    "fun"
                    (Term.basicFun
                     [`x]
                     [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                     "=>"
                     (Term.tuple
                      "("
                      [(Term.app `e [(Term.proj `x "." (fieldIdx "1"))])
                       ","
                       [(Term.app `e [(Term.proj `x "." (fieldIdx "2"))])]]
                      ")")))
                   (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α])])))]
              ":="
              (Term.byTactic
               "by"
               (Tactic.tacticSeq
                (Tactic.tacticSeq1Indented
                 [(Std.Tactic.tacticRwa__
                   "rwa"
                   (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `h_e.comap_uniformity.symm)] "]")
                   [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
            []
            (Term.let
             "let"
             (Term.letDecl
              (Term.letPatDecl (Term.anonymousCtor "⟨" [`t "," `ht "," `ts] "⟩") [] [] ":=" `this))
             []
             (Term.show
              "show"
              («term_∈_»
               (Term.app
                `preimage
                [(Term.fun
                  "fun"
                  (Term.basicFun
                   [`p]
                   [(Term.typeSpec ":" («term_×_» `α "×" `α))]
                   "=>"
                   (Term.tuple
                    "("
                    [(Term.app
                      (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                      [(Term.proj `p "." (fieldIdx "1"))])
                     ","
                     [(Term.app
                       (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                       [(Term.proj `p "." (fieldIdx "2"))])]]
                    ")")))
                 `d])
               "∈"
               (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α]))
              (Term.fromTerm
               "from"
               (Term.app
                (Term.app
                 (Term.proj
                  (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α])
                  "."
                  `sets_of_superset)
                 [(Term.app `interior_mem_uniformity [`ht])])
                [(Term.fun
                  "fun"
                  (Term.basicFun
                   [(Term.anonymousCtor "⟨" [`x₁ "," `x₂] "⟩") `hx_t]
                   []
                   "=>"
                   (Term.have
                    "have"
                    (Term.haveDecl
                     (Term.haveIdDecl
                      []
                      [(Term.typeSpec
                        ":"
                        («term_≤_»
                         (Term.app
                          (TopologicalSpace.Topology.Basic.nhds "𝓝")
                          [(Term.tuple "(" [`x₁ "," [`x₂]] ")")])
                         "≤"
                         (Term.app
                          (Filter.Order.Filter.Basic.filter.principal "𝓟")
                          [(Term.app `interior [`t])])))]
                      ":="
                      (Term.app
                       (Term.proj `is_open_iff_nhds "." `mp)
                       [`is_open_interior (Term.tuple "(" [`x₁ "," [`x₂]] ")") `hx_t])))
                    []
                    (Term.have
                     "have"
                     (Term.haveDecl
                      (Term.haveIdDecl
                       []
                       [(Term.typeSpec
                         ":"
                         («term_∈_»
                          (Term.app `interior [`t])
                          "∈"
                          (Filter.Order.Filter.Prod.filter.prod
                           (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₁])
                           " ×ᶠ "
                           (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₂]))))]
                       ":="
                       (Term.byTactic
                        "by"
                        (Tactic.tacticSeq
                         (Tactic.tacticSeq1Indented
                          [(Std.Tactic.tacticRwa__
                            "rwa"
                            (Tactic.rwRuleSeq
                             "["
                             [(Tactic.rwRule [] `nhds_prod_eq)
                              ","
                              (Tactic.rwRule [] `le_principal_iff)]
                             "]")
                            [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
                     []
                     (Term.let
                      "let"
                      (Term.letDecl
                       (Term.letPatDecl
                        (Term.anonymousCtor
                         "⟨"
                         [`m₁
                          ","
                          `hm₁
                          ","
                          `m₂
                          ","
                          `hm₂
                          ","
                          (Term.typeAscription
                           "("
                           `hm
                           ":"
                           [(«term_⊆_»
                             (LowerSet.Order.UpperLower.lower_set.prod `m₁ " ×ˢ " `m₂)
                             "⊆"
                             (Term.app `interior [`t]))]
                           ")")]
                         "⟩")
                        []
                        []
                        ":="
                        (Term.app (Term.proj `mem_prod_iff "." `mp) [`this])))
                      []
                      (Term.let
                       "let"
                       (Term.letDecl
                        (Term.letPatDecl
                         (Term.anonymousCtor "⟨" [`a "," `ha₁ "," (Term.hole "_") "," `ha₂] "⟩")
                         []
                         []
                         ":="
                         (Term.app `h_pnt [`hm₁])))
                       []
                       (Term.let
                        "let"
                        (Term.letDecl
                         (Term.letPatDecl
                          (Term.anonymousCtor "⟨" [`b "," `hb₁ "," `hb₂ "," (Term.hole "_")] "⟩")
                          []
                          []
                          ":="
                          (Term.app `h_pnt [`hm₂])))
                        []
                        (Term.have
                         "have"
                         (Term.haveDecl
                          (Term.haveIdDecl
                           []
                           [(Term.typeSpec
                             ":"
                             («term_⊆_»
                              (LowerSet.Order.UpperLower.lower_set.prod
                               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                               " ×ˢ "
                               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
                              "⊆"
                              (Set.Data.Set.Image.«term_⁻¹'_»
                               (Term.fun
                                "fun"
                                (Term.basicFun
                                 [`p]
                                 [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                 "=>"
                                 (Term.tuple
                                  "("
                                  [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                   ","
                                   [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                  ")")))
                               " ⁻¹' "
                               `s)))]
                           ":="
                           (calc
                            "calc"
                            (calcStep
                             («term_⊆_»
                              (Term.hole "_")
                              "⊆"
                              (Term.app
                               `preimage
                               [(Term.fun
                                 "fun"
                                 (Term.basicFun
                                  [`p]
                                  [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                  "=>"
                                  (Term.tuple
                                   "("
                                   [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                                    ","
                                    [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                                   ")")))
                                (Term.app `interior [`t])]))
                             ":="
                             (Term.app `preimage_mono [`hm]))
                            [(calcStep
                              («term_⊆_»
                               (Term.hole "_")
                               "⊆"
                               (Term.app
                                `preimage
                                [(Term.fun
                                  "fun"
                                  (Term.basicFun
                                   [`p]
                                   [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                   "=>"
                                   (Term.tuple
                                    "("
                                    [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                                     ","
                                     [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                                    ")")))
                                 `t]))
                              ":="
                              (Term.app `preimage_mono [`interior_subset]))
                             (calcStep
                              («term_⊆_»
                               (Term.hole "_")
                               "⊆"
                               (Term.app
                                `preimage
                                [(Term.fun
                                  "fun"
                                  (Term.basicFun
                                   [`p]
                                   [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                   "=>"
                                   (Term.tuple
                                    "("
                                    [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                     ","
                                     [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                    ")")))
                                 `s]))
                              ":="
                              `ts)])))
                         []
                         (Term.have
                          "have"
                          (Term.haveDecl
                           (Term.haveIdDecl
                            []
                            [(Term.typeSpec
                              ":"
                              («term_⊆_»
                               (LowerSet.Order.UpperLower.lower_set.prod
                                (Set.Data.Set.Image.term_''_
                                 `f
                                 " '' "
                                 (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                                " ×ˢ "
                                (Set.Data.Set.Image.term_''_
                                 `f
                                 " '' "
                                 (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                               "⊆"
                               `s))]
                            ":="
                            (calc
                             "calc"
                             (calcStep
                              («term_=_»
                               (LowerSet.Order.UpperLower.lower_set.prod
                                (Set.Data.Set.Image.term_''_
                                 `f
                                 " '' "
                                 (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                                " ×ˢ "
                                (Set.Data.Set.Image.term_''_
                                 `f
                                 " '' "
                                 (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                               "="
                               (Set.Data.Set.Image.term_''_
                                (Term.fun
                                 "fun"
                                 (Term.basicFun
                                  [`p]
                                  [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                  "=>"
                                  (Term.tuple
                                   "("
                                   [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                    ","
                                    [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                   ")")))
                                " '' "
                                (LowerSet.Order.UpperLower.lower_set.prod
                                 (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                                 " ×ˢ "
                                 (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
                              ":="
                              `prod_image_image_eq)
                             [(calcStep
                               («term_⊆_»
                                (Term.hole "_")
                                "⊆"
                                (Set.Data.Set.Image.term_''_
                                 (Term.fun
                                  "fun"
                                  (Term.basicFun
                                   [`p]
                                   [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                   "=>"
                                   (Term.tuple
                                    "("
                                    [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                     ","
                                     [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                    ")")))
                                 " '' "
                                 (Set.Data.Set.Image.«term_⁻¹'_»
                                  (Term.fun
                                   "fun"
                                   (Term.basicFun
                                    [`p]
                                    [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                    "=>"
                                    (Term.tuple
                                     "("
                                     [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                      ","
                                      [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                     ")")))
                                  " ⁻¹' "
                                  `s)))
                               ":="
                               (Term.app `monotone_image [`this]))
                              (calcStep
                               («term_⊆_» (Term.hole "_") "⊆" `s)
                               ":="
                               (Term.app
                                `image_preimage_subset
                                [(Term.hole "_") (Term.hole "_")]))])))
                          []
                          (Term.have
                           "have"
                           (Term.haveDecl
                            (Term.haveIdDecl
                             []
                             [(Term.typeSpec
                               ":"
                               («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
                             ":="
                             (Term.app
                              (Term.explicit "@" `this)
                              [(Term.tuple "(" [`a "," [`b]] ")")
                               (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
                           []
                           («term_<|_»
                            `hs_comp
                            "<|"
                            (Term.show
                             "show"
                             («term_∈_»
                              (Term.tuple
                               "("
                               [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
                                ","
                                [(Term.app
                                  (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                                  [`x₂])]]
                               ")")
                              "∈"
                              (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
                             (Term.fromTerm
                              "from"
                              (Term.anonymousCtor
                               "⟨"
                               [`a
                                ","
                                `ha₂
                                ","
                                (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
                               "⟩"))))))))))))))]))))))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.let
       "let"
       (Term.letDecl
        (Term.letPatDecl
         (Term.anonymousCtor "⟨" [`s "," `hs "," `hs_comp] "⟩")
         []
         []
         ":="
         (Term.app
          (Term.proj
           («term_<|_»
            `mem_lift'_sets
            "<|"
            («term_<|_»
             (Term.app `monotone_comp_rel [`monotone_id])
             "<|"
             (Term.app `monotone_comp_rel [`monotone_id `monotone_id])))
           "."
           `mp)
          [(Term.app `comp_le_uniformity3 [`hd])])))
       []
       (Term.have
        "have"
        (Term.haveDecl
         (Term.haveIdDecl
          [`h_pnt []]
          [(Term.typeSpec
            ":"
            (Term.forall
             "∀"
             [(Term.implicitBinder "{" [`a `m] [] "}")]
             []
             ","
             (Term.arrow
              («term_∈_» `m "∈" (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`a]))
              "→"
              («term∃_,_»
               "∃"
               (Lean.explicitBinders (Lean.unbracketedExplicitBinders [(Lean.binderIdent `c)] []))
               ","
               («term_∧_»
                («term_∈_»
                 `c
                 "∈"
                 (Set.Data.Set.Image.term_''_ `f " '' " (Term.app `preimage [`e `m])))
                "∧"
                («term_∧_»
                 («term_∈_»
                  (Term.tuple
                   "("
                   [`c "," [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a])]]
                   ")")
                  "∈"
                  `s)
                 "∧"
                 («term_∈_»
                  (Term.tuple
                   "("
                   [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a]) "," [`c]]
                   ")")
                  "∈"
                  `s)))))))]
          ":="
          (Term.fun
           "fun"
           (Term.basicFun
            [`a `m `hm]
            []
            "=>"
            (Term.have
             "have"
             (Term.haveDecl
              (Term.haveIdDecl
               [`nb []]
               [(Term.typeSpec
                 ":"
                 (Term.app
                  `NeBot
                  [(Term.app
                    `map
                    [`f
                     (Term.app
                      `comap
                      [`e (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`a])])])]))]
               ":="
               (Term.app
                (Term.proj
                 (Term.app
                  (Term.proj
                   (Term.app (Term.proj `h_e "." `DenseInducing) [`h_dense])
                   "."
                   `comap_nhds_ne_bot)
                  [(Term.hole "_")])
                 "."
                 `map)
                [(Term.hole "_")])))
             []
             (Term.have
              "have"
              (Term.haveDecl
               (Term.haveIdDecl
                []
                [(Term.typeSpec
                  ":"
                  («term_∈_»
                   («term_∩_»
                    (Set.Data.Set.Image.term_''_ `f " '' " (Term.app `preimage [`e `m]))
                    "∩"
                    («term_∩_»
                     (Set.«term{_|_}»
                      "{"
                      (Std.ExtendedBinder.extBinder (Lean.binderIdent `c) [])
                      "|"
                      («term_∈_»
                       (Term.tuple
                        "("
                        [`c
                         ","
                         [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a])]]
                        ")")
                       "∈"
                       `s)
                      "}")
                     "∩"
                     (Set.«term{_|_}»
                      "{"
                      (Std.ExtendedBinder.extBinder (Lean.binderIdent `c) [])
                      "|"
                      («term_∈_»
                       (Term.tuple
                        "("
                        [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a])
                         ","
                         [`c]]
                        ")")
                       "∈"
                       `s)
                      "}")))
                   "∈"
                   (Term.app
                    `map
                    [`f
                     (Term.app
                      `comap
                      [`e (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`a])])])))]
                ":="
                (Term.app
                 `inter_mem
                 [(«term_<|_» `image_mem_map "<|" («term_<|_» `preimage_mem_comap "<|" `hm))
                  (Term.app
                   `uniformly_extend_spec
                   [`h_e
                    `h_dense
                    `h_f
                    (Term.hole "_")
                    (Term.app
                     `inter_mem
                     [(Term.app `mem_nhds_right [(Term.hole "_") `hs])
                      (Term.app `mem_nhds_left [(Term.hole "_") `hs])])])])))
              []
              (Term.app (Term.proj `nb "." `nonempty_of_mem) [`this])))))))
        []
        (Term.have
         "have"
         (Term.haveDecl
          (Term.haveIdDecl
           []
           [(Term.typeSpec
             ":"
             («term_∈_»
              (Term.app
               `preimage
               [(Term.fun
                 "fun"
                 (Term.basicFun
                  [`p]
                  [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                  "=>"
                  (Term.tuple
                   "("
                   [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                    ","
                    [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                   ")")))
                `s])
              "∈"
              (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`β])))]
           ":="
           (Term.app `h_f [`hs])))
         []
         (Term.have
          "have"
          (Term.haveDecl
           (Term.haveIdDecl
            []
            [(Term.typeSpec
              ":"
              («term_∈_»
               (Term.app
                `preimage
                [(Term.fun
                  "fun"
                  (Term.basicFun
                   [`p]
                   [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                   "=>"
                   (Term.tuple
                    "("
                    [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                     ","
                     [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                    ")")))
                 `s])
               "∈"
               (Term.app
                `comap
                [(Term.fun
                  "fun"
                  (Term.basicFun
                   [`x]
                   [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                   "=>"
                   (Term.tuple
                    "("
                    [(Term.app `e [(Term.proj `x "." (fieldIdx "1"))])
                     ","
                     [(Term.app `e [(Term.proj `x "." (fieldIdx "2"))])]]
                    ")")))
                 (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α])])))]
            ":="
            (Term.byTactic
             "by"
             (Tactic.tacticSeq
              (Tactic.tacticSeq1Indented
               [(Std.Tactic.tacticRwa__
                 "rwa"
                 (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `h_e.comap_uniformity.symm)] "]")
                 [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
          []
          (Term.let
           "let"
           (Term.letDecl
            (Term.letPatDecl (Term.anonymousCtor "⟨" [`t "," `ht "," `ts] "⟩") [] [] ":=" `this))
           []
           (Term.show
            "show"
            («term_∈_»
             (Term.app
              `preimage
              [(Term.fun
                "fun"
                (Term.basicFun
                 [`p]
                 [(Term.typeSpec ":" («term_×_» `α "×" `α))]
                 "=>"
                 (Term.tuple
                  "("
                  [(Term.app
                    (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                    [(Term.proj `p "." (fieldIdx "1"))])
                   ","
                   [(Term.app
                     (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                     [(Term.proj `p "." (fieldIdx "2"))])]]
                  ")")))
               `d])
             "∈"
             (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α]))
            (Term.fromTerm
             "from"
             (Term.app
              (Term.app
               (Term.proj
                (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α])
                "."
                `sets_of_superset)
               [(Term.app `interior_mem_uniformity [`ht])])
              [(Term.fun
                "fun"
                (Term.basicFun
                 [(Term.anonymousCtor "⟨" [`x₁ "," `x₂] "⟩") `hx_t]
                 []
                 "=>"
                 (Term.have
                  "have"
                  (Term.haveDecl
                   (Term.haveIdDecl
                    []
                    [(Term.typeSpec
                      ":"
                      («term_≤_»
                       (Term.app
                        (TopologicalSpace.Topology.Basic.nhds "𝓝")
                        [(Term.tuple "(" [`x₁ "," [`x₂]] ")")])
                       "≤"
                       (Term.app
                        (Filter.Order.Filter.Basic.filter.principal "𝓟")
                        [(Term.app `interior [`t])])))]
                    ":="
                    (Term.app
                     (Term.proj `is_open_iff_nhds "." `mp)
                     [`is_open_interior (Term.tuple "(" [`x₁ "," [`x₂]] ")") `hx_t])))
                  []
                  (Term.have
                   "have"
                   (Term.haveDecl
                    (Term.haveIdDecl
                     []
                     [(Term.typeSpec
                       ":"
                       («term_∈_»
                        (Term.app `interior [`t])
                        "∈"
                        (Filter.Order.Filter.Prod.filter.prod
                         (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₁])
                         " ×ᶠ "
                         (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₂]))))]
                     ":="
                     (Term.byTactic
                      "by"
                      (Tactic.tacticSeq
                       (Tactic.tacticSeq1Indented
                        [(Std.Tactic.tacticRwa__
                          "rwa"
                          (Tactic.rwRuleSeq
                           "["
                           [(Tactic.rwRule [] `nhds_prod_eq)
                            ","
                            (Tactic.rwRule [] `le_principal_iff)]
                           "]")
                          [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
                   []
                   (Term.let
                    "let"
                    (Term.letDecl
                     (Term.letPatDecl
                      (Term.anonymousCtor
                       "⟨"
                       [`m₁
                        ","
                        `hm₁
                        ","
                        `m₂
                        ","
                        `hm₂
                        ","
                        (Term.typeAscription
                         "("
                         `hm
                         ":"
                         [(«term_⊆_»
                           (LowerSet.Order.UpperLower.lower_set.prod `m₁ " ×ˢ " `m₂)
                           "⊆"
                           (Term.app `interior [`t]))]
                         ")")]
                       "⟩")
                      []
                      []
                      ":="
                      (Term.app (Term.proj `mem_prod_iff "." `mp) [`this])))
                    []
                    (Term.let
                     "let"
                     (Term.letDecl
                      (Term.letPatDecl
                       (Term.anonymousCtor "⟨" [`a "," `ha₁ "," (Term.hole "_") "," `ha₂] "⟩")
                       []
                       []
                       ":="
                       (Term.app `h_pnt [`hm₁])))
                     []
                     (Term.let
                      "let"
                      (Term.letDecl
                       (Term.letPatDecl
                        (Term.anonymousCtor "⟨" [`b "," `hb₁ "," `hb₂ "," (Term.hole "_")] "⟩")
                        []
                        []
                        ":="
                        (Term.app `h_pnt [`hm₂])))
                      []
                      (Term.have
                       "have"
                       (Term.haveDecl
                        (Term.haveIdDecl
                         []
                         [(Term.typeSpec
                           ":"
                           («term_⊆_»
                            (LowerSet.Order.UpperLower.lower_set.prod
                             (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                             " ×ˢ "
                             (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
                            "⊆"
                            (Set.Data.Set.Image.«term_⁻¹'_»
                             (Term.fun
                              "fun"
                              (Term.basicFun
                               [`p]
                               [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                               "=>"
                               (Term.tuple
                                "("
                                [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                 ","
                                 [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                ")")))
                             " ⁻¹' "
                             `s)))]
                         ":="
                         (calc
                          "calc"
                          (calcStep
                           («term_⊆_»
                            (Term.hole "_")
                            "⊆"
                            (Term.app
                             `preimage
                             [(Term.fun
                               "fun"
                               (Term.basicFun
                                [`p]
                                [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                "=>"
                                (Term.tuple
                                 "("
                                 [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                                  ","
                                  [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                                 ")")))
                              (Term.app `interior [`t])]))
                           ":="
                           (Term.app `preimage_mono [`hm]))
                          [(calcStep
                            («term_⊆_»
                             (Term.hole "_")
                             "⊆"
                             (Term.app
                              `preimage
                              [(Term.fun
                                "fun"
                                (Term.basicFun
                                 [`p]
                                 [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                 "=>"
                                 (Term.tuple
                                  "("
                                  [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                                   ","
                                   [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                                  ")")))
                               `t]))
                            ":="
                            (Term.app `preimage_mono [`interior_subset]))
                           (calcStep
                            («term_⊆_»
                             (Term.hole "_")
                             "⊆"
                             (Term.app
                              `preimage
                              [(Term.fun
                                "fun"
                                (Term.basicFun
                                 [`p]
                                 [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                 "=>"
                                 (Term.tuple
                                  "("
                                  [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                   ","
                                   [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                  ")")))
                               `s]))
                            ":="
                            `ts)])))
                       []
                       (Term.have
                        "have"
                        (Term.haveDecl
                         (Term.haveIdDecl
                          []
                          [(Term.typeSpec
                            ":"
                            («term_⊆_»
                             (LowerSet.Order.UpperLower.lower_set.prod
                              (Set.Data.Set.Image.term_''_
                               `f
                               " '' "
                               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                              " ×ˢ "
                              (Set.Data.Set.Image.term_''_
                               `f
                               " '' "
                               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                             "⊆"
                             `s))]
                          ":="
                          (calc
                           "calc"
                           (calcStep
                            («term_=_»
                             (LowerSet.Order.UpperLower.lower_set.prod
                              (Set.Data.Set.Image.term_''_
                               `f
                               " '' "
                               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                              " ×ˢ "
                              (Set.Data.Set.Image.term_''_
                               `f
                               " '' "
                               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                             "="
                             (Set.Data.Set.Image.term_''_
                              (Term.fun
                               "fun"
                               (Term.basicFun
                                [`p]
                                [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                "=>"
                                (Term.tuple
                                 "("
                                 [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                  ","
                                  [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                 ")")))
                              " '' "
                              (LowerSet.Order.UpperLower.lower_set.prod
                               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                               " ×ˢ "
                               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
                            ":="
                            `prod_image_image_eq)
                           [(calcStep
                             («term_⊆_»
                              (Term.hole "_")
                              "⊆"
                              (Set.Data.Set.Image.term_''_
                               (Term.fun
                                "fun"
                                (Term.basicFun
                                 [`p]
                                 [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                 "=>"
                                 (Term.tuple
                                  "("
                                  [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                   ","
                                   [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                  ")")))
                               " '' "
                               (Set.Data.Set.Image.«term_⁻¹'_»
                                (Term.fun
                                 "fun"
                                 (Term.basicFun
                                  [`p]
                                  [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                  "=>"
                                  (Term.tuple
                                   "("
                                   [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                    ","
                                    [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                   ")")))
                                " ⁻¹' "
                                `s)))
                             ":="
                             (Term.app `monotone_image [`this]))
                            (calcStep
                             («term_⊆_» (Term.hole "_") "⊆" `s)
                             ":="
                             (Term.app
                              `image_preimage_subset
                              [(Term.hole "_") (Term.hole "_")]))])))
                        []
                        (Term.have
                         "have"
                         (Term.haveDecl
                          (Term.haveIdDecl
                           []
                           [(Term.typeSpec
                             ":"
                             («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
                           ":="
                           (Term.app
                            (Term.explicit "@" `this)
                            [(Term.tuple "(" [`a "," [`b]] ")")
                             (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
                         []
                         («term_<|_»
                          `hs_comp
                          "<|"
                          (Term.show
                           "show"
                           («term_∈_»
                            (Term.tuple
                             "("
                             [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
                              ","
                              [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
                             ")")
                            "∈"
                            (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
                           (Term.fromTerm
                            "from"
                            (Term.anonymousCtor
                             "⟨"
                             [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
                             "⟩"))))))))))))))]))))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.have
       "have"
       (Term.haveDecl
        (Term.haveIdDecl
         [`h_pnt []]
         [(Term.typeSpec
           ":"
           (Term.forall
            "∀"
            [(Term.implicitBinder "{" [`a `m] [] "}")]
            []
            ","
            (Term.arrow
             («term_∈_» `m "∈" (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`a]))
             "→"
             («term∃_,_»
              "∃"
              (Lean.explicitBinders (Lean.unbracketedExplicitBinders [(Lean.binderIdent `c)] []))
              ","
              («term_∧_»
               («term_∈_»
                `c
                "∈"
                (Set.Data.Set.Image.term_''_ `f " '' " (Term.app `preimage [`e `m])))
               "∧"
               («term_∧_»
                («term_∈_»
                 (Term.tuple
                  "("
                  [`c "," [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a])]]
                  ")")
                 "∈"
                 `s)
                "∧"
                («term_∈_»
                 (Term.tuple
                  "("
                  [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a]) "," [`c]]
                  ")")
                 "∈"
                 `s)))))))]
         ":="
         (Term.fun
          "fun"
          (Term.basicFun
           [`a `m `hm]
           []
           "=>"
           (Term.have
            "have"
            (Term.haveDecl
             (Term.haveIdDecl
              [`nb []]
              [(Term.typeSpec
                ":"
                (Term.app
                 `NeBot
                 [(Term.app
                   `map
                   [`f
                    (Term.app
                     `comap
                     [`e (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`a])])])]))]
              ":="
              (Term.app
               (Term.proj
                (Term.app
                 (Term.proj
                  (Term.app (Term.proj `h_e "." `DenseInducing) [`h_dense])
                  "."
                  `comap_nhds_ne_bot)
                 [(Term.hole "_")])
                "."
                `map)
               [(Term.hole "_")])))
            []
            (Term.have
             "have"
             (Term.haveDecl
              (Term.haveIdDecl
               []
               [(Term.typeSpec
                 ":"
                 («term_∈_»
                  («term_∩_»
                   (Set.Data.Set.Image.term_''_ `f " '' " (Term.app `preimage [`e `m]))
                   "∩"
                   («term_∩_»
                    (Set.«term{_|_}»
                     "{"
                     (Std.ExtendedBinder.extBinder (Lean.binderIdent `c) [])
                     "|"
                     («term_∈_»
                      (Term.tuple
                       "("
                       [`c "," [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a])]]
                       ")")
                      "∈"
                      `s)
                     "}")
                    "∩"
                    (Set.«term{_|_}»
                     "{"
                     (Std.ExtendedBinder.extBinder (Lean.binderIdent `c) [])
                     "|"
                     («term_∈_»
                      (Term.tuple
                       "("
                       [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`a]) "," [`c]]
                       ")")
                      "∈"
                      `s)
                     "}")))
                  "∈"
                  (Term.app
                   `map
                   [`f
                    (Term.app
                     `comap
                     [`e (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`a])])])))]
               ":="
               (Term.app
                `inter_mem
                [(«term_<|_» `image_mem_map "<|" («term_<|_» `preimage_mem_comap "<|" `hm))
                 (Term.app
                  `uniformly_extend_spec
                  [`h_e
                   `h_dense
                   `h_f
                   (Term.hole "_")
                   (Term.app
                    `inter_mem
                    [(Term.app `mem_nhds_right [(Term.hole "_") `hs])
                     (Term.app `mem_nhds_left [(Term.hole "_") `hs])])])])))
             []
             (Term.app (Term.proj `nb "." `nonempty_of_mem) [`this])))))))
       []
       (Term.have
        "have"
        (Term.haveDecl
         (Term.haveIdDecl
          []
          [(Term.typeSpec
            ":"
            («term_∈_»
             (Term.app
              `preimage
              [(Term.fun
                "fun"
                (Term.basicFun
                 [`p]
                 [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                 "=>"
                 (Term.tuple
                  "("
                  [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                   ","
                   [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                  ")")))
               `s])
             "∈"
             (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`β])))]
          ":="
          (Term.app `h_f [`hs])))
        []
        (Term.have
         "have"
         (Term.haveDecl
          (Term.haveIdDecl
           []
           [(Term.typeSpec
             ":"
             («term_∈_»
              (Term.app
               `preimage
               [(Term.fun
                 "fun"
                 (Term.basicFun
                  [`p]
                  [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                  "=>"
                  (Term.tuple
                   "("
                   [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                    ","
                    [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                   ")")))
                `s])
              "∈"
              (Term.app
               `comap
               [(Term.fun
                 "fun"
                 (Term.basicFun
                  [`x]
                  [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                  "=>"
                  (Term.tuple
                   "("
                   [(Term.app `e [(Term.proj `x "." (fieldIdx "1"))])
                    ","
                    [(Term.app `e [(Term.proj `x "." (fieldIdx "2"))])]]
                   ")")))
                (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α])])))]
           ":="
           (Term.byTactic
            "by"
            (Tactic.tacticSeq
             (Tactic.tacticSeq1Indented
              [(Std.Tactic.tacticRwa__
                "rwa"
                (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `h_e.comap_uniformity.symm)] "]")
                [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
         []
         (Term.let
          "let"
          (Term.letDecl
           (Term.letPatDecl (Term.anonymousCtor "⟨" [`t "," `ht "," `ts] "⟩") [] [] ":=" `this))
          []
          (Term.show
           "show"
           («term_∈_»
            (Term.app
             `preimage
             [(Term.fun
               "fun"
               (Term.basicFun
                [`p]
                [(Term.typeSpec ":" («term_×_» `α "×" `α))]
                "=>"
                (Term.tuple
                 "("
                 [(Term.app
                   (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                   [(Term.proj `p "." (fieldIdx "1"))])
                  ","
                  [(Term.app
                    (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                    [(Term.proj `p "." (fieldIdx "2"))])]]
                 ")")))
              `d])
            "∈"
            (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α]))
           (Term.fromTerm
            "from"
            (Term.app
             (Term.app
              (Term.proj
               (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α])
               "."
               `sets_of_superset)
              [(Term.app `interior_mem_uniformity [`ht])])
             [(Term.fun
               "fun"
               (Term.basicFun
                [(Term.anonymousCtor "⟨" [`x₁ "," `x₂] "⟩") `hx_t]
                []
                "=>"
                (Term.have
                 "have"
                 (Term.haveDecl
                  (Term.haveIdDecl
                   []
                   [(Term.typeSpec
                     ":"
                     («term_≤_»
                      (Term.app
                       (TopologicalSpace.Topology.Basic.nhds "𝓝")
                       [(Term.tuple "(" [`x₁ "," [`x₂]] ")")])
                      "≤"
                      (Term.app
                       (Filter.Order.Filter.Basic.filter.principal "𝓟")
                       [(Term.app `interior [`t])])))]
                   ":="
                   (Term.app
                    (Term.proj `is_open_iff_nhds "." `mp)
                    [`is_open_interior (Term.tuple "(" [`x₁ "," [`x₂]] ")") `hx_t])))
                 []
                 (Term.have
                  "have"
                  (Term.haveDecl
                   (Term.haveIdDecl
                    []
                    [(Term.typeSpec
                      ":"
                      («term_∈_»
                       (Term.app `interior [`t])
                       "∈"
                       (Filter.Order.Filter.Prod.filter.prod
                        (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₁])
                        " ×ᶠ "
                        (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₂]))))]
                    ":="
                    (Term.byTactic
                     "by"
                     (Tactic.tacticSeq
                      (Tactic.tacticSeq1Indented
                       [(Std.Tactic.tacticRwa__
                         "rwa"
                         (Tactic.rwRuleSeq
                          "["
                          [(Tactic.rwRule [] `nhds_prod_eq)
                           ","
                           (Tactic.rwRule [] `le_principal_iff)]
                          "]")
                         [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
                  []
                  (Term.let
                   "let"
                   (Term.letDecl
                    (Term.letPatDecl
                     (Term.anonymousCtor
                      "⟨"
                      [`m₁
                       ","
                       `hm₁
                       ","
                       `m₂
                       ","
                       `hm₂
                       ","
                       (Term.typeAscription
                        "("
                        `hm
                        ":"
                        [(«term_⊆_»
                          (LowerSet.Order.UpperLower.lower_set.prod `m₁ " ×ˢ " `m₂)
                          "⊆"
                          (Term.app `interior [`t]))]
                        ")")]
                      "⟩")
                     []
                     []
                     ":="
                     (Term.app (Term.proj `mem_prod_iff "." `mp) [`this])))
                   []
                   (Term.let
                    "let"
                    (Term.letDecl
                     (Term.letPatDecl
                      (Term.anonymousCtor "⟨" [`a "," `ha₁ "," (Term.hole "_") "," `ha₂] "⟩")
                      []
                      []
                      ":="
                      (Term.app `h_pnt [`hm₁])))
                    []
                    (Term.let
                     "let"
                     (Term.letDecl
                      (Term.letPatDecl
                       (Term.anonymousCtor "⟨" [`b "," `hb₁ "," `hb₂ "," (Term.hole "_")] "⟩")
                       []
                       []
                       ":="
                       (Term.app `h_pnt [`hm₂])))
                     []
                     (Term.have
                      "have"
                      (Term.haveDecl
                       (Term.haveIdDecl
                        []
                        [(Term.typeSpec
                          ":"
                          («term_⊆_»
                           (LowerSet.Order.UpperLower.lower_set.prod
                            (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                            " ×ˢ "
                            (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
                           "⊆"
                           (Set.Data.Set.Image.«term_⁻¹'_»
                            (Term.fun
                             "fun"
                             (Term.basicFun
                              [`p]
                              [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                              "=>"
                              (Term.tuple
                               "("
                               [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                ","
                                [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                               ")")))
                            " ⁻¹' "
                            `s)))]
                        ":="
                        (calc
                         "calc"
                         (calcStep
                          («term_⊆_»
                           (Term.hole "_")
                           "⊆"
                           (Term.app
                            `preimage
                            [(Term.fun
                              "fun"
                              (Term.basicFun
                               [`p]
                               [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                               "=>"
                               (Term.tuple
                                "("
                                [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                                 ","
                                 [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                                ")")))
                             (Term.app `interior [`t])]))
                          ":="
                          (Term.app `preimage_mono [`hm]))
                         [(calcStep
                           («term_⊆_»
                            (Term.hole "_")
                            "⊆"
                            (Term.app
                             `preimage
                             [(Term.fun
                               "fun"
                               (Term.basicFun
                                [`p]
                                [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                "=>"
                                (Term.tuple
                                 "("
                                 [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                                  ","
                                  [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                                 ")")))
                              `t]))
                           ":="
                           (Term.app `preimage_mono [`interior_subset]))
                          (calcStep
                           («term_⊆_»
                            (Term.hole "_")
                            "⊆"
                            (Term.app
                             `preimage
                             [(Term.fun
                               "fun"
                               (Term.basicFun
                                [`p]
                                [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                "=>"
                                (Term.tuple
                                 "("
                                 [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                  ","
                                  [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                 ")")))
                              `s]))
                           ":="
                           `ts)])))
                      []
                      (Term.have
                       "have"
                       (Term.haveDecl
                        (Term.haveIdDecl
                         []
                         [(Term.typeSpec
                           ":"
                           («term_⊆_»
                            (LowerSet.Order.UpperLower.lower_set.prod
                             (Set.Data.Set.Image.term_''_
                              `f
                              " '' "
                              (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                             " ×ˢ "
                             (Set.Data.Set.Image.term_''_
                              `f
                              " '' "
                              (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                            "⊆"
                            `s))]
                         ":="
                         (calc
                          "calc"
                          (calcStep
                           («term_=_»
                            (LowerSet.Order.UpperLower.lower_set.prod
                             (Set.Data.Set.Image.term_''_
                              `f
                              " '' "
                              (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                             " ×ˢ "
                             (Set.Data.Set.Image.term_''_
                              `f
                              " '' "
                              (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                            "="
                            (Set.Data.Set.Image.term_''_
                             (Term.fun
                              "fun"
                              (Term.basicFun
                               [`p]
                               [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                               "=>"
                               (Term.tuple
                                "("
                                [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                 ","
                                 [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                ")")))
                             " '' "
                             (LowerSet.Order.UpperLower.lower_set.prod
                              (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                              " ×ˢ "
                              (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
                           ":="
                           `prod_image_image_eq)
                          [(calcStep
                            («term_⊆_»
                             (Term.hole "_")
                             "⊆"
                             (Set.Data.Set.Image.term_''_
                              (Term.fun
                               "fun"
                               (Term.basicFun
                                [`p]
                                [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                "=>"
                                (Term.tuple
                                 "("
                                 [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                  ","
                                  [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                 ")")))
                              " '' "
                              (Set.Data.Set.Image.«term_⁻¹'_»
                               (Term.fun
                                "fun"
                                (Term.basicFun
                                 [`p]
                                 [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                 "=>"
                                 (Term.tuple
                                  "("
                                  [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                   ","
                                   [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                  ")")))
                               " ⁻¹' "
                               `s)))
                            ":="
                            (Term.app `monotone_image [`this]))
                           (calcStep
                            («term_⊆_» (Term.hole "_") "⊆" `s)
                            ":="
                            (Term.app `image_preimage_subset [(Term.hole "_") (Term.hole "_")]))])))
                       []
                       (Term.have
                        "have"
                        (Term.haveDecl
                         (Term.haveIdDecl
                          []
                          [(Term.typeSpec
                            ":"
                            («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
                          ":="
                          (Term.app
                           (Term.explicit "@" `this)
                           [(Term.tuple "(" [`a "," [`b]] ")")
                            (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
                        []
                        («term_<|_»
                         `hs_comp
                         "<|"
                         (Term.show
                          "show"
                          («term_∈_»
                           (Term.tuple
                            "("
                            [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
                             ","
                             [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
                            ")")
                           "∈"
                           (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
                          (Term.fromTerm
                           "from"
                           (Term.anonymousCtor
                            "⟨"
                            [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
                            "⟩"))))))))))))))])))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.have
       "have"
       (Term.haveDecl
        (Term.haveIdDecl
         []
         [(Term.typeSpec
           ":"
           («term_∈_»
            (Term.app
             `preimage
             [(Term.fun
               "fun"
               (Term.basicFun
                [`p]
                [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                "=>"
                (Term.tuple
                 "("
                 [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                  ","
                  [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                 ")")))
              `s])
            "∈"
            (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`β])))]
         ":="
         (Term.app `h_f [`hs])))
       []
       (Term.have
        "have"
        (Term.haveDecl
         (Term.haveIdDecl
          []
          [(Term.typeSpec
            ":"
            («term_∈_»
             (Term.app
              `preimage
              [(Term.fun
                "fun"
                (Term.basicFun
                 [`p]
                 [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                 "=>"
                 (Term.tuple
                  "("
                  [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                   ","
                   [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                  ")")))
               `s])
             "∈"
             (Term.app
              `comap
              [(Term.fun
                "fun"
                (Term.basicFun
                 [`x]
                 [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                 "=>"
                 (Term.tuple
                  "("
                  [(Term.app `e [(Term.proj `x "." (fieldIdx "1"))])
                   ","
                   [(Term.app `e [(Term.proj `x "." (fieldIdx "2"))])]]
                  ")")))
               (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α])])))]
          ":="
          (Term.byTactic
           "by"
           (Tactic.tacticSeq
            (Tactic.tacticSeq1Indented
             [(Std.Tactic.tacticRwa__
               "rwa"
               (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `h_e.comap_uniformity.symm)] "]")
               [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
        []
        (Term.let
         "let"
         (Term.letDecl
          (Term.letPatDecl (Term.anonymousCtor "⟨" [`t "," `ht "," `ts] "⟩") [] [] ":=" `this))
         []
         (Term.show
          "show"
          («term_∈_»
           (Term.app
            `preimage
            [(Term.fun
              "fun"
              (Term.basicFun
               [`p]
               [(Term.typeSpec ":" («term_×_» `α "×" `α))]
               "=>"
               (Term.tuple
                "("
                [(Term.app
                  (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                  [(Term.proj `p "." (fieldIdx "1"))])
                 ","
                 [(Term.app
                   (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                   [(Term.proj `p "." (fieldIdx "2"))])]]
                ")")))
             `d])
           "∈"
           (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α]))
          (Term.fromTerm
           "from"
           (Term.app
            (Term.app
             (Term.proj
              (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α])
              "."
              `sets_of_superset)
             [(Term.app `interior_mem_uniformity [`ht])])
            [(Term.fun
              "fun"
              (Term.basicFun
               [(Term.anonymousCtor "⟨" [`x₁ "," `x₂] "⟩") `hx_t]
               []
               "=>"
               (Term.have
                "have"
                (Term.haveDecl
                 (Term.haveIdDecl
                  []
                  [(Term.typeSpec
                    ":"
                    («term_≤_»
                     (Term.app
                      (TopologicalSpace.Topology.Basic.nhds "𝓝")
                      [(Term.tuple "(" [`x₁ "," [`x₂]] ")")])
                     "≤"
                     (Term.app
                      (Filter.Order.Filter.Basic.filter.principal "𝓟")
                      [(Term.app `interior [`t])])))]
                  ":="
                  (Term.app
                   (Term.proj `is_open_iff_nhds "." `mp)
                   [`is_open_interior (Term.tuple "(" [`x₁ "," [`x₂]] ")") `hx_t])))
                []
                (Term.have
                 "have"
                 (Term.haveDecl
                  (Term.haveIdDecl
                   []
                   [(Term.typeSpec
                     ":"
                     («term_∈_»
                      (Term.app `interior [`t])
                      "∈"
                      (Filter.Order.Filter.Prod.filter.prod
                       (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₁])
                       " ×ᶠ "
                       (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₂]))))]
                   ":="
                   (Term.byTactic
                    "by"
                    (Tactic.tacticSeq
                     (Tactic.tacticSeq1Indented
                      [(Std.Tactic.tacticRwa__
                        "rwa"
                        (Tactic.rwRuleSeq
                         "["
                         [(Tactic.rwRule [] `nhds_prod_eq) "," (Tactic.rwRule [] `le_principal_iff)]
                         "]")
                        [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
                 []
                 (Term.let
                  "let"
                  (Term.letDecl
                   (Term.letPatDecl
                    (Term.anonymousCtor
                     "⟨"
                     [`m₁
                      ","
                      `hm₁
                      ","
                      `m₂
                      ","
                      `hm₂
                      ","
                      (Term.typeAscription
                       "("
                       `hm
                       ":"
                       [(«term_⊆_»
                         (LowerSet.Order.UpperLower.lower_set.prod `m₁ " ×ˢ " `m₂)
                         "⊆"
                         (Term.app `interior [`t]))]
                       ")")]
                     "⟩")
                    []
                    []
                    ":="
                    (Term.app (Term.proj `mem_prod_iff "." `mp) [`this])))
                  []
                  (Term.let
                   "let"
                   (Term.letDecl
                    (Term.letPatDecl
                     (Term.anonymousCtor "⟨" [`a "," `ha₁ "," (Term.hole "_") "," `ha₂] "⟩")
                     []
                     []
                     ":="
                     (Term.app `h_pnt [`hm₁])))
                   []
                   (Term.let
                    "let"
                    (Term.letDecl
                     (Term.letPatDecl
                      (Term.anonymousCtor "⟨" [`b "," `hb₁ "," `hb₂ "," (Term.hole "_")] "⟩")
                      []
                      []
                      ":="
                      (Term.app `h_pnt [`hm₂])))
                    []
                    (Term.have
                     "have"
                     (Term.haveDecl
                      (Term.haveIdDecl
                       []
                       [(Term.typeSpec
                         ":"
                         («term_⊆_»
                          (LowerSet.Order.UpperLower.lower_set.prod
                           (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                           " ×ˢ "
                           (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
                          "⊆"
                          (Set.Data.Set.Image.«term_⁻¹'_»
                           (Term.fun
                            "fun"
                            (Term.basicFun
                             [`p]
                             [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                             "=>"
                             (Term.tuple
                              "("
                              [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                               ","
                               [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                              ")")))
                           " ⁻¹' "
                           `s)))]
                       ":="
                       (calc
                        "calc"
                        (calcStep
                         («term_⊆_»
                          (Term.hole "_")
                          "⊆"
                          (Term.app
                           `preimage
                           [(Term.fun
                             "fun"
                             (Term.basicFun
                              [`p]
                              [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                              "=>"
                              (Term.tuple
                               "("
                               [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                                ","
                                [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                               ")")))
                            (Term.app `interior [`t])]))
                         ":="
                         (Term.app `preimage_mono [`hm]))
                        [(calcStep
                          («term_⊆_»
                           (Term.hole "_")
                           "⊆"
                           (Term.app
                            `preimage
                            [(Term.fun
                              "fun"
                              (Term.basicFun
                               [`p]
                               [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                               "=>"
                               (Term.tuple
                                "("
                                [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                                 ","
                                 [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                                ")")))
                             `t]))
                          ":="
                          (Term.app `preimage_mono [`interior_subset]))
                         (calcStep
                          («term_⊆_»
                           (Term.hole "_")
                           "⊆"
                           (Term.app
                            `preimage
                            [(Term.fun
                              "fun"
                              (Term.basicFun
                               [`p]
                               [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                               "=>"
                               (Term.tuple
                                "("
                                [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                 ","
                                 [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                ")")))
                             `s]))
                          ":="
                          `ts)])))
                     []
                     (Term.have
                      "have"
                      (Term.haveDecl
                       (Term.haveIdDecl
                        []
                        [(Term.typeSpec
                          ":"
                          («term_⊆_»
                           (LowerSet.Order.UpperLower.lower_set.prod
                            (Set.Data.Set.Image.term_''_
                             `f
                             " '' "
                             (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                            " ×ˢ "
                            (Set.Data.Set.Image.term_''_
                             `f
                             " '' "
                             (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                           "⊆"
                           `s))]
                        ":="
                        (calc
                         "calc"
                         (calcStep
                          («term_=_»
                           (LowerSet.Order.UpperLower.lower_set.prod
                            (Set.Data.Set.Image.term_''_
                             `f
                             " '' "
                             (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                            " ×ˢ "
                            (Set.Data.Set.Image.term_''_
                             `f
                             " '' "
                             (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                           "="
                           (Set.Data.Set.Image.term_''_
                            (Term.fun
                             "fun"
                             (Term.basicFun
                              [`p]
                              [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                              "=>"
                              (Term.tuple
                               "("
                               [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                ","
                                [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                               ")")))
                            " '' "
                            (LowerSet.Order.UpperLower.lower_set.prod
                             (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                             " ×ˢ "
                             (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
                          ":="
                          `prod_image_image_eq)
                         [(calcStep
                           («term_⊆_»
                            (Term.hole "_")
                            "⊆"
                            (Set.Data.Set.Image.term_''_
                             (Term.fun
                              "fun"
                              (Term.basicFun
                               [`p]
                               [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                               "=>"
                               (Term.tuple
                                "("
                                [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                 ","
                                 [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                ")")))
                             " '' "
                             (Set.Data.Set.Image.«term_⁻¹'_»
                              (Term.fun
                               "fun"
                               (Term.basicFun
                                [`p]
                                [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                                "=>"
                                (Term.tuple
                                 "("
                                 [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                  ","
                                  [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                 ")")))
                              " ⁻¹' "
                              `s)))
                           ":="
                           (Term.app `monotone_image [`this]))
                          (calcStep
                           («term_⊆_» (Term.hole "_") "⊆" `s)
                           ":="
                           (Term.app `image_preimage_subset [(Term.hole "_") (Term.hole "_")]))])))
                      []
                      (Term.have
                       "have"
                       (Term.haveDecl
                        (Term.haveIdDecl
                         []
                         [(Term.typeSpec ":" («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
                         ":="
                         (Term.app
                          (Term.explicit "@" `this)
                          [(Term.tuple "(" [`a "," [`b]] ")")
                           (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
                       []
                       («term_<|_»
                        `hs_comp
                        "<|"
                        (Term.show
                         "show"
                         («term_∈_»
                          (Term.tuple
                           "("
                           [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
                            ","
                            [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
                           ")")
                          "∈"
                          (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
                         (Term.fromTerm
                          "from"
                          (Term.anonymousCtor
                           "⟨"
                           [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
                           "⟩"))))))))))))))]))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.have
       "have"
       (Term.haveDecl
        (Term.haveIdDecl
         []
         [(Term.typeSpec
           ":"
           («term_∈_»
            (Term.app
             `preimage
             [(Term.fun
               "fun"
               (Term.basicFun
                [`p]
                [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                "=>"
                (Term.tuple
                 "("
                 [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                  ","
                  [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                 ")")))
              `s])
            "∈"
            (Term.app
             `comap
             [(Term.fun
               "fun"
               (Term.basicFun
                [`x]
                [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                "=>"
                (Term.tuple
                 "("
                 [(Term.app `e [(Term.proj `x "." (fieldIdx "1"))])
                  ","
                  [(Term.app `e [(Term.proj `x "." (fieldIdx "2"))])]]
                 ")")))
              (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α])])))]
         ":="
         (Term.byTactic
          "by"
          (Tactic.tacticSeq
           (Tactic.tacticSeq1Indented
            [(Std.Tactic.tacticRwa__
              "rwa"
              (Tactic.rwRuleSeq "[" [(Tactic.rwRule [] `h_e.comap_uniformity.symm)] "]")
              [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
       []
       (Term.let
        "let"
        (Term.letDecl
         (Term.letPatDecl (Term.anonymousCtor "⟨" [`t "," `ht "," `ts] "⟩") [] [] ":=" `this))
        []
        (Term.show
         "show"
         («term_∈_»
          (Term.app
           `preimage
           [(Term.fun
             "fun"
             (Term.basicFun
              [`p]
              [(Term.typeSpec ":" («term_×_» `α "×" `α))]
              "=>"
              (Term.tuple
               "("
               [(Term.app
                 (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                 [(Term.proj `p "." (fieldIdx "1"))])
                ","
                [(Term.app
                  (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                  [(Term.proj `p "." (fieldIdx "2"))])]]
               ")")))
            `d])
          "∈"
          (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α]))
         (Term.fromTerm
          "from"
          (Term.app
           (Term.app
            (Term.proj
             (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α])
             "."
             `sets_of_superset)
            [(Term.app `interior_mem_uniformity [`ht])])
           [(Term.fun
             "fun"
             (Term.basicFun
              [(Term.anonymousCtor "⟨" [`x₁ "," `x₂] "⟩") `hx_t]
              []
              "=>"
              (Term.have
               "have"
               (Term.haveDecl
                (Term.haveIdDecl
                 []
                 [(Term.typeSpec
                   ":"
                   («term_≤_»
                    (Term.app
                     (TopologicalSpace.Topology.Basic.nhds "𝓝")
                     [(Term.tuple "(" [`x₁ "," [`x₂]] ")")])
                    "≤"
                    (Term.app
                     (Filter.Order.Filter.Basic.filter.principal "𝓟")
                     [(Term.app `interior [`t])])))]
                 ":="
                 (Term.app
                  (Term.proj `is_open_iff_nhds "." `mp)
                  [`is_open_interior (Term.tuple "(" [`x₁ "," [`x₂]] ")") `hx_t])))
               []
               (Term.have
                "have"
                (Term.haveDecl
                 (Term.haveIdDecl
                  []
                  [(Term.typeSpec
                    ":"
                    («term_∈_»
                     (Term.app `interior [`t])
                     "∈"
                     (Filter.Order.Filter.Prod.filter.prod
                      (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₁])
                      " ×ᶠ "
                      (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₂]))))]
                  ":="
                  (Term.byTactic
                   "by"
                   (Tactic.tacticSeq
                    (Tactic.tacticSeq1Indented
                     [(Std.Tactic.tacticRwa__
                       "rwa"
                       (Tactic.rwRuleSeq
                        "["
                        [(Tactic.rwRule [] `nhds_prod_eq) "," (Tactic.rwRule [] `le_principal_iff)]
                        "]")
                       [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
                []
                (Term.let
                 "let"
                 (Term.letDecl
                  (Term.letPatDecl
                   (Term.anonymousCtor
                    "⟨"
                    [`m₁
                     ","
                     `hm₁
                     ","
                     `m₂
                     ","
                     `hm₂
                     ","
                     (Term.typeAscription
                      "("
                      `hm
                      ":"
                      [(«term_⊆_»
                        (LowerSet.Order.UpperLower.lower_set.prod `m₁ " ×ˢ " `m₂)
                        "⊆"
                        (Term.app `interior [`t]))]
                      ")")]
                    "⟩")
                   []
                   []
                   ":="
                   (Term.app (Term.proj `mem_prod_iff "." `mp) [`this])))
                 []
                 (Term.let
                  "let"
                  (Term.letDecl
                   (Term.letPatDecl
                    (Term.anonymousCtor "⟨" [`a "," `ha₁ "," (Term.hole "_") "," `ha₂] "⟩")
                    []
                    []
                    ":="
                    (Term.app `h_pnt [`hm₁])))
                  []
                  (Term.let
                   "let"
                   (Term.letDecl
                    (Term.letPatDecl
                     (Term.anonymousCtor "⟨" [`b "," `hb₁ "," `hb₂ "," (Term.hole "_")] "⟩")
                     []
                     []
                     ":="
                     (Term.app `h_pnt [`hm₂])))
                   []
                   (Term.have
                    "have"
                    (Term.haveDecl
                     (Term.haveIdDecl
                      []
                      [(Term.typeSpec
                        ":"
                        («term_⊆_»
                         (LowerSet.Order.UpperLower.lower_set.prod
                          (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                          " ×ˢ "
                          (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
                         "⊆"
                         (Set.Data.Set.Image.«term_⁻¹'_»
                          (Term.fun
                           "fun"
                           (Term.basicFun
                            [`p]
                            [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                            "=>"
                            (Term.tuple
                             "("
                             [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                              ","
                              [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                             ")")))
                          " ⁻¹' "
                          `s)))]
                      ":="
                      (calc
                       "calc"
                       (calcStep
                        («term_⊆_»
                         (Term.hole "_")
                         "⊆"
                         (Term.app
                          `preimage
                          [(Term.fun
                            "fun"
                            (Term.basicFun
                             [`p]
                             [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                             "=>"
                             (Term.tuple
                              "("
                              [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                               ","
                               [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                              ")")))
                           (Term.app `interior [`t])]))
                        ":="
                        (Term.app `preimage_mono [`hm]))
                       [(calcStep
                         («term_⊆_»
                          (Term.hole "_")
                          "⊆"
                          (Term.app
                           `preimage
                           [(Term.fun
                             "fun"
                             (Term.basicFun
                              [`p]
                              [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                              "=>"
                              (Term.tuple
                               "("
                               [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                                ","
                                [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                               ")")))
                            `t]))
                         ":="
                         (Term.app `preimage_mono [`interior_subset]))
                        (calcStep
                         («term_⊆_»
                          (Term.hole "_")
                          "⊆"
                          (Term.app
                           `preimage
                           [(Term.fun
                             "fun"
                             (Term.basicFun
                              [`p]
                              [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                              "=>"
                              (Term.tuple
                               "("
                               [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                ","
                                [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                               ")")))
                            `s]))
                         ":="
                         `ts)])))
                    []
                    (Term.have
                     "have"
                     (Term.haveDecl
                      (Term.haveIdDecl
                       []
                       [(Term.typeSpec
                         ":"
                         («term_⊆_»
                          (LowerSet.Order.UpperLower.lower_set.prod
                           (Set.Data.Set.Image.term_''_
                            `f
                            " '' "
                            (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                           " ×ˢ "
                           (Set.Data.Set.Image.term_''_
                            `f
                            " '' "
                            (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                          "⊆"
                          `s))]
                       ":="
                       (calc
                        "calc"
                        (calcStep
                         («term_=_»
                          (LowerSet.Order.UpperLower.lower_set.prod
                           (Set.Data.Set.Image.term_''_
                            `f
                            " '' "
                            (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                           " ×ˢ "
                           (Set.Data.Set.Image.term_''_
                            `f
                            " '' "
                            (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                          "="
                          (Set.Data.Set.Image.term_''_
                           (Term.fun
                            "fun"
                            (Term.basicFun
                             [`p]
                             [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                             "=>"
                             (Term.tuple
                              "("
                              [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                               ","
                               [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                              ")")))
                           " '' "
                           (LowerSet.Order.UpperLower.lower_set.prod
                            (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                            " ×ˢ "
                            (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
                         ":="
                         `prod_image_image_eq)
                        [(calcStep
                          («term_⊆_»
                           (Term.hole "_")
                           "⊆"
                           (Set.Data.Set.Image.term_''_
                            (Term.fun
                             "fun"
                             (Term.basicFun
                              [`p]
                              [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                              "=>"
                              (Term.tuple
                               "("
                               [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                ","
                                [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                               ")")))
                            " '' "
                            (Set.Data.Set.Image.«term_⁻¹'_»
                             (Term.fun
                              "fun"
                              (Term.basicFun
                               [`p]
                               [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                               "=>"
                               (Term.tuple
                                "("
                                [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                 ","
                                 [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                                ")")))
                             " ⁻¹' "
                             `s)))
                          ":="
                          (Term.app `monotone_image [`this]))
                         (calcStep
                          («term_⊆_» (Term.hole "_") "⊆" `s)
                          ":="
                          (Term.app `image_preimage_subset [(Term.hole "_") (Term.hole "_")]))])))
                     []
                     (Term.have
                      "have"
                      (Term.haveDecl
                       (Term.haveIdDecl
                        []
                        [(Term.typeSpec ":" («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
                        ":="
                        (Term.app
                         (Term.explicit "@" `this)
                         [(Term.tuple "(" [`a "," [`b]] ")")
                          (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
                      []
                      («term_<|_»
                       `hs_comp
                       "<|"
                       (Term.show
                        "show"
                        («term_∈_»
                         (Term.tuple
                          "("
                          [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
                           ","
                           [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
                          ")")
                         "∈"
                         (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
                        (Term.fromTerm
                         "from"
                         (Term.anonymousCtor
                          "⟨"
                          [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
                          "⟩"))))))))))))))])))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.let
       "let"
       (Term.letDecl
        (Term.letPatDecl (Term.anonymousCtor "⟨" [`t "," `ht "," `ts] "⟩") [] [] ":=" `this))
       []
       (Term.show
        "show"
        («term_∈_»
         (Term.app
          `preimage
          [(Term.fun
            "fun"
            (Term.basicFun
             [`p]
             [(Term.typeSpec ":" («term_×_» `α "×" `α))]
             "=>"
             (Term.tuple
              "("
              [(Term.app
                (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                [(Term.proj `p "." (fieldIdx "1"))])
               ","
               [(Term.app
                 (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                 [(Term.proj `p "." (fieldIdx "2"))])]]
              ")")))
           `d])
         "∈"
         (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α]))
        (Term.fromTerm
         "from"
         (Term.app
          (Term.app
           (Term.proj
            (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α])
            "."
            `sets_of_superset)
           [(Term.app `interior_mem_uniformity [`ht])])
          [(Term.fun
            "fun"
            (Term.basicFun
             [(Term.anonymousCtor "⟨" [`x₁ "," `x₂] "⟩") `hx_t]
             []
             "=>"
             (Term.have
              "have"
              (Term.haveDecl
               (Term.haveIdDecl
                []
                [(Term.typeSpec
                  ":"
                  («term_≤_»
                   (Term.app
                    (TopologicalSpace.Topology.Basic.nhds "𝓝")
                    [(Term.tuple "(" [`x₁ "," [`x₂]] ")")])
                   "≤"
                   (Term.app
                    (Filter.Order.Filter.Basic.filter.principal "𝓟")
                    [(Term.app `interior [`t])])))]
                ":="
                (Term.app
                 (Term.proj `is_open_iff_nhds "." `mp)
                 [`is_open_interior (Term.tuple "(" [`x₁ "," [`x₂]] ")") `hx_t])))
              []
              (Term.have
               "have"
               (Term.haveDecl
                (Term.haveIdDecl
                 []
                 [(Term.typeSpec
                   ":"
                   («term_∈_»
                    (Term.app `interior [`t])
                    "∈"
                    (Filter.Order.Filter.Prod.filter.prod
                     (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₁])
                     " ×ᶠ "
                     (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₂]))))]
                 ":="
                 (Term.byTactic
                  "by"
                  (Tactic.tacticSeq
                   (Tactic.tacticSeq1Indented
                    [(Std.Tactic.tacticRwa__
                      "rwa"
                      (Tactic.rwRuleSeq
                       "["
                       [(Tactic.rwRule [] `nhds_prod_eq) "," (Tactic.rwRule [] `le_principal_iff)]
                       "]")
                      [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
               []
               (Term.let
                "let"
                (Term.letDecl
                 (Term.letPatDecl
                  (Term.anonymousCtor
                   "⟨"
                   [`m₁
                    ","
                    `hm₁
                    ","
                    `m₂
                    ","
                    `hm₂
                    ","
                    (Term.typeAscription
                     "("
                     `hm
                     ":"
                     [(«term_⊆_»
                       (LowerSet.Order.UpperLower.lower_set.prod `m₁ " ×ˢ " `m₂)
                       "⊆"
                       (Term.app `interior [`t]))]
                     ")")]
                   "⟩")
                  []
                  []
                  ":="
                  (Term.app (Term.proj `mem_prod_iff "." `mp) [`this])))
                []
                (Term.let
                 "let"
                 (Term.letDecl
                  (Term.letPatDecl
                   (Term.anonymousCtor "⟨" [`a "," `ha₁ "," (Term.hole "_") "," `ha₂] "⟩")
                   []
                   []
                   ":="
                   (Term.app `h_pnt [`hm₁])))
                 []
                 (Term.let
                  "let"
                  (Term.letDecl
                   (Term.letPatDecl
                    (Term.anonymousCtor "⟨" [`b "," `hb₁ "," `hb₂ "," (Term.hole "_")] "⟩")
                    []
                    []
                    ":="
                    (Term.app `h_pnt [`hm₂])))
                  []
                  (Term.have
                   "have"
                   (Term.haveDecl
                    (Term.haveIdDecl
                     []
                     [(Term.typeSpec
                       ":"
                       («term_⊆_»
                        (LowerSet.Order.UpperLower.lower_set.prod
                         (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                         " ×ˢ "
                         (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
                        "⊆"
                        (Set.Data.Set.Image.«term_⁻¹'_»
                         (Term.fun
                          "fun"
                          (Term.basicFun
                           [`p]
                           [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                           "=>"
                           (Term.tuple
                            "("
                            [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                             ","
                             [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                            ")")))
                         " ⁻¹' "
                         `s)))]
                     ":="
                     (calc
                      "calc"
                      (calcStep
                       («term_⊆_»
                        (Term.hole "_")
                        "⊆"
                        (Term.app
                         `preimage
                         [(Term.fun
                           "fun"
                           (Term.basicFun
                            [`p]
                            [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                            "=>"
                            (Term.tuple
                             "("
                             [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                              ","
                              [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                             ")")))
                          (Term.app `interior [`t])]))
                       ":="
                       (Term.app `preimage_mono [`hm]))
                      [(calcStep
                        («term_⊆_»
                         (Term.hole "_")
                         "⊆"
                         (Term.app
                          `preimage
                          [(Term.fun
                            "fun"
                            (Term.basicFun
                             [`p]
                             [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                             "=>"
                             (Term.tuple
                              "("
                              [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                               ","
                               [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                              ")")))
                           `t]))
                        ":="
                        (Term.app `preimage_mono [`interior_subset]))
                       (calcStep
                        («term_⊆_»
                         (Term.hole "_")
                         "⊆"
                         (Term.app
                          `preimage
                          [(Term.fun
                            "fun"
                            (Term.basicFun
                             [`p]
                             [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                             "=>"
                             (Term.tuple
                              "("
                              [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                               ","
                               [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                              ")")))
                           `s]))
                        ":="
                        `ts)])))
                   []
                   (Term.have
                    "have"
                    (Term.haveDecl
                     (Term.haveIdDecl
                      []
                      [(Term.typeSpec
                        ":"
                        («term_⊆_»
                         (LowerSet.Order.UpperLower.lower_set.prod
                          (Set.Data.Set.Image.term_''_
                           `f
                           " '' "
                           (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                          " ×ˢ "
                          (Set.Data.Set.Image.term_''_
                           `f
                           " '' "
                           (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                         "⊆"
                         `s))]
                      ":="
                      (calc
                       "calc"
                       (calcStep
                        («term_=_»
                         (LowerSet.Order.UpperLower.lower_set.prod
                          (Set.Data.Set.Image.term_''_
                           `f
                           " '' "
                           (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                          " ×ˢ "
                          (Set.Data.Set.Image.term_''_
                           `f
                           " '' "
                           (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                         "="
                         (Set.Data.Set.Image.term_''_
                          (Term.fun
                           "fun"
                           (Term.basicFun
                            [`p]
                            [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                            "=>"
                            (Term.tuple
                             "("
                             [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                              ","
                              [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                             ")")))
                          " '' "
                          (LowerSet.Order.UpperLower.lower_set.prod
                           (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                           " ×ˢ "
                           (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
                        ":="
                        `prod_image_image_eq)
                       [(calcStep
                         («term_⊆_»
                          (Term.hole "_")
                          "⊆"
                          (Set.Data.Set.Image.term_''_
                           (Term.fun
                            "fun"
                            (Term.basicFun
                             [`p]
                             [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                             "=>"
                             (Term.tuple
                              "("
                              [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                               ","
                               [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                              ")")))
                           " '' "
                           (Set.Data.Set.Image.«term_⁻¹'_»
                            (Term.fun
                             "fun"
                             (Term.basicFun
                              [`p]
                              [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                              "=>"
                              (Term.tuple
                               "("
                               [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                                ","
                                [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                               ")")))
                            " ⁻¹' "
                            `s)))
                         ":="
                         (Term.app `monotone_image [`this]))
                        (calcStep
                         («term_⊆_» (Term.hole "_") "⊆" `s)
                         ":="
                         (Term.app `image_preimage_subset [(Term.hole "_") (Term.hole "_")]))])))
                    []
                    (Term.have
                     "have"
                     (Term.haveDecl
                      (Term.haveIdDecl
                       []
                       [(Term.typeSpec ":" («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
                       ":="
                       (Term.app
                        (Term.explicit "@" `this)
                        [(Term.tuple "(" [`a "," [`b]] ")")
                         (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
                     []
                     («term_<|_»
                      `hs_comp
                      "<|"
                      (Term.show
                       "show"
                       («term_∈_»
                        (Term.tuple
                         "("
                         [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
                          ","
                          [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
                         ")")
                        "∈"
                        (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
                       (Term.fromTerm
                        "from"
                        (Term.anonymousCtor
                         "⟨"
                         [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
                         "⟩"))))))))))))))]))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.show
       "show"
       («term_∈_»
        (Term.app
         `preimage
         [(Term.fun
           "fun"
           (Term.basicFun
            [`p]
            [(Term.typeSpec ":" («term_×_» `α "×" `α))]
            "=>"
            (Term.tuple
             "("
             [(Term.app
               (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
               [(Term.proj `p "." (fieldIdx "1"))])
              ","
              [(Term.app
                (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
                [(Term.proj `p "." (fieldIdx "2"))])]]
             ")")))
          `d])
        "∈"
        (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α]))
       (Term.fromTerm
        "from"
        (Term.app
         (Term.app
          (Term.proj
           (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α])
           "."
           `sets_of_superset)
          [(Term.app `interior_mem_uniformity [`ht])])
         [(Term.fun
           "fun"
           (Term.basicFun
            [(Term.anonymousCtor "⟨" [`x₁ "," `x₂] "⟩") `hx_t]
            []
            "=>"
            (Term.have
             "have"
             (Term.haveDecl
              (Term.haveIdDecl
               []
               [(Term.typeSpec
                 ":"
                 («term_≤_»
                  (Term.app
                   (TopologicalSpace.Topology.Basic.nhds "𝓝")
                   [(Term.tuple "(" [`x₁ "," [`x₂]] ")")])
                  "≤"
                  (Term.app
                   (Filter.Order.Filter.Basic.filter.principal "𝓟")
                   [(Term.app `interior [`t])])))]
               ":="
               (Term.app
                (Term.proj `is_open_iff_nhds "." `mp)
                [`is_open_interior (Term.tuple "(" [`x₁ "," [`x₂]] ")") `hx_t])))
             []
             (Term.have
              "have"
              (Term.haveDecl
               (Term.haveIdDecl
                []
                [(Term.typeSpec
                  ":"
                  («term_∈_»
                   (Term.app `interior [`t])
                   "∈"
                   (Filter.Order.Filter.Prod.filter.prod
                    (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₁])
                    " ×ᶠ "
                    (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₂]))))]
                ":="
                (Term.byTactic
                 "by"
                 (Tactic.tacticSeq
                  (Tactic.tacticSeq1Indented
                   [(Std.Tactic.tacticRwa__
                     "rwa"
                     (Tactic.rwRuleSeq
                      "["
                      [(Tactic.rwRule [] `nhds_prod_eq) "," (Tactic.rwRule [] `le_principal_iff)]
                      "]")
                     [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
              []
              (Term.let
               "let"
               (Term.letDecl
                (Term.letPatDecl
                 (Term.anonymousCtor
                  "⟨"
                  [`m₁
                   ","
                   `hm₁
                   ","
                   `m₂
                   ","
                   `hm₂
                   ","
                   (Term.typeAscription
                    "("
                    `hm
                    ":"
                    [(«term_⊆_»
                      (LowerSet.Order.UpperLower.lower_set.prod `m₁ " ×ˢ " `m₂)
                      "⊆"
                      (Term.app `interior [`t]))]
                    ")")]
                  "⟩")
                 []
                 []
                 ":="
                 (Term.app (Term.proj `mem_prod_iff "." `mp) [`this])))
               []
               (Term.let
                "let"
                (Term.letDecl
                 (Term.letPatDecl
                  (Term.anonymousCtor "⟨" [`a "," `ha₁ "," (Term.hole "_") "," `ha₂] "⟩")
                  []
                  []
                  ":="
                  (Term.app `h_pnt [`hm₁])))
                []
                (Term.let
                 "let"
                 (Term.letDecl
                  (Term.letPatDecl
                   (Term.anonymousCtor "⟨" [`b "," `hb₁ "," `hb₂ "," (Term.hole "_")] "⟩")
                   []
                   []
                   ":="
                   (Term.app `h_pnt [`hm₂])))
                 []
                 (Term.have
                  "have"
                  (Term.haveDecl
                   (Term.haveIdDecl
                    []
                    [(Term.typeSpec
                      ":"
                      («term_⊆_»
                       (LowerSet.Order.UpperLower.lower_set.prod
                        (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                        " ×ˢ "
                        (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
                       "⊆"
                       (Set.Data.Set.Image.«term_⁻¹'_»
                        (Term.fun
                         "fun"
                         (Term.basicFun
                          [`p]
                          [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                          "=>"
                          (Term.tuple
                           "("
                           [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                            ","
                            [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                           ")")))
                        " ⁻¹' "
                        `s)))]
                    ":="
                    (calc
                     "calc"
                     (calcStep
                      («term_⊆_»
                       (Term.hole "_")
                       "⊆"
                       (Term.app
                        `preimage
                        [(Term.fun
                          "fun"
                          (Term.basicFun
                           [`p]
                           [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                           "=>"
                           (Term.tuple
                            "("
                            [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                             ","
                             [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                            ")")))
                         (Term.app `interior [`t])]))
                      ":="
                      (Term.app `preimage_mono [`hm]))
                     [(calcStep
                       («term_⊆_»
                        (Term.hole "_")
                        "⊆"
                        (Term.app
                         `preimage
                         [(Term.fun
                           "fun"
                           (Term.basicFun
                            [`p]
                            [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                            "=>"
                            (Term.tuple
                             "("
                             [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                              ","
                              [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                             ")")))
                          `t]))
                       ":="
                       (Term.app `preimage_mono [`interior_subset]))
                      (calcStep
                       («term_⊆_»
                        (Term.hole "_")
                        "⊆"
                        (Term.app
                         `preimage
                         [(Term.fun
                           "fun"
                           (Term.basicFun
                            [`p]
                            [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                            "=>"
                            (Term.tuple
                             "("
                             [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                              ","
                              [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                             ")")))
                          `s]))
                       ":="
                       `ts)])))
                  []
                  (Term.have
                   "have"
                   (Term.haveDecl
                    (Term.haveIdDecl
                     []
                     [(Term.typeSpec
                       ":"
                       («term_⊆_»
                        (LowerSet.Order.UpperLower.lower_set.prod
                         (Set.Data.Set.Image.term_''_
                          `f
                          " '' "
                          (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                         " ×ˢ "
                         (Set.Data.Set.Image.term_''_
                          `f
                          " '' "
                          (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                        "⊆"
                        `s))]
                     ":="
                     (calc
                      "calc"
                      (calcStep
                       («term_=_»
                        (LowerSet.Order.UpperLower.lower_set.prod
                         (Set.Data.Set.Image.term_''_
                          `f
                          " '' "
                          (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                         " ×ˢ "
                         (Set.Data.Set.Image.term_''_
                          `f
                          " '' "
                          (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                        "="
                        (Set.Data.Set.Image.term_''_
                         (Term.fun
                          "fun"
                          (Term.basicFun
                           [`p]
                           [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                           "=>"
                           (Term.tuple
                            "("
                            [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                             ","
                             [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                            ")")))
                         " '' "
                         (LowerSet.Order.UpperLower.lower_set.prod
                          (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                          " ×ˢ "
                          (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
                       ":="
                       `prod_image_image_eq)
                      [(calcStep
                        («term_⊆_»
                         (Term.hole "_")
                         "⊆"
                         (Set.Data.Set.Image.term_''_
                          (Term.fun
                           "fun"
                           (Term.basicFun
                            [`p]
                            [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                            "=>"
                            (Term.tuple
                             "("
                             [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                              ","
                              [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                             ")")))
                          " '' "
                          (Set.Data.Set.Image.«term_⁻¹'_»
                           (Term.fun
                            "fun"
                            (Term.basicFun
                             [`p]
                             [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                             "=>"
                             (Term.tuple
                              "("
                              [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                               ","
                               [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                              ")")))
                           " ⁻¹' "
                           `s)))
                        ":="
                        (Term.app `monotone_image [`this]))
                       (calcStep
                        («term_⊆_» (Term.hole "_") "⊆" `s)
                        ":="
                        (Term.app `image_preimage_subset [(Term.hole "_") (Term.hole "_")]))])))
                   []
                   (Term.have
                    "have"
                    (Term.haveDecl
                     (Term.haveIdDecl
                      []
                      [(Term.typeSpec ":" («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
                      ":="
                      (Term.app
                       (Term.explicit "@" `this)
                       [(Term.tuple "(" [`a "," [`b]] ")")
                        (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
                    []
                    («term_<|_»
                     `hs_comp
                     "<|"
                     (Term.show
                      "show"
                      («term_∈_»
                       (Term.tuple
                        "("
                        [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
                         ","
                         [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
                        ")")
                       "∈"
                       (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
                      (Term.fromTerm
                       "from"
                       (Term.anonymousCtor
                        "⟨"
                        [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
                        "⟩"))))))))))))))])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       (Term.app
        (Term.proj
         (Term.app (uniformity.Topology.UniformSpace.Basic.uniformity "𝓤") [`α])
         "."
         `sets_of_superset)
        [(Term.app `interior_mem_uniformity [`ht])])
       [(Term.fun
         "fun"
         (Term.basicFun
          [(Term.anonymousCtor "⟨" [`x₁ "," `x₂] "⟩") `hx_t]
          []
          "=>"
          (Term.have
           "have"
           (Term.haveDecl
            (Term.haveIdDecl
             []
             [(Term.typeSpec
               ":"
               («term_≤_»
                (Term.app
                 (TopologicalSpace.Topology.Basic.nhds "𝓝")
                 [(Term.tuple "(" [`x₁ "," [`x₂]] ")")])
                "≤"
                (Term.app
                 (Filter.Order.Filter.Basic.filter.principal "𝓟")
                 [(Term.app `interior [`t])])))]
             ":="
             (Term.app
              (Term.proj `is_open_iff_nhds "." `mp)
              [`is_open_interior (Term.tuple "(" [`x₁ "," [`x₂]] ")") `hx_t])))
           []
           (Term.have
            "have"
            (Term.haveDecl
             (Term.haveIdDecl
              []
              [(Term.typeSpec
                ":"
                («term_∈_»
                 (Term.app `interior [`t])
                 "∈"
                 (Filter.Order.Filter.Prod.filter.prod
                  (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₁])
                  " ×ᶠ "
                  (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₂]))))]
              ":="
              (Term.byTactic
               "by"
               (Tactic.tacticSeq
                (Tactic.tacticSeq1Indented
                 [(Std.Tactic.tacticRwa__
                   "rwa"
                   (Tactic.rwRuleSeq
                    "["
                    [(Tactic.rwRule [] `nhds_prod_eq) "," (Tactic.rwRule [] `le_principal_iff)]
                    "]")
                   [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
            []
            (Term.let
             "let"
             (Term.letDecl
              (Term.letPatDecl
               (Term.anonymousCtor
                "⟨"
                [`m₁
                 ","
                 `hm₁
                 ","
                 `m₂
                 ","
                 `hm₂
                 ","
                 (Term.typeAscription
                  "("
                  `hm
                  ":"
                  [(«term_⊆_»
                    (LowerSet.Order.UpperLower.lower_set.prod `m₁ " ×ˢ " `m₂)
                    "⊆"
                    (Term.app `interior [`t]))]
                  ")")]
                "⟩")
               []
               []
               ":="
               (Term.app (Term.proj `mem_prod_iff "." `mp) [`this])))
             []
             (Term.let
              "let"
              (Term.letDecl
               (Term.letPatDecl
                (Term.anonymousCtor "⟨" [`a "," `ha₁ "," (Term.hole "_") "," `ha₂] "⟩")
                []
                []
                ":="
                (Term.app `h_pnt [`hm₁])))
              []
              (Term.let
               "let"
               (Term.letDecl
                (Term.letPatDecl
                 (Term.anonymousCtor "⟨" [`b "," `hb₁ "," `hb₂ "," (Term.hole "_")] "⟩")
                 []
                 []
                 ":="
                 (Term.app `h_pnt [`hm₂])))
               []
               (Term.have
                "have"
                (Term.haveDecl
                 (Term.haveIdDecl
                  []
                  [(Term.typeSpec
                    ":"
                    («term_⊆_»
                     (LowerSet.Order.UpperLower.lower_set.prod
                      (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                      " ×ˢ "
                      (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
                     "⊆"
                     (Set.Data.Set.Image.«term_⁻¹'_»
                      (Term.fun
                       "fun"
                       (Term.basicFun
                        [`p]
                        [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                        "=>"
                        (Term.tuple
                         "("
                         [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                          ","
                          [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                         ")")))
                      " ⁻¹' "
                      `s)))]
                  ":="
                  (calc
                   "calc"
                   (calcStep
                    («term_⊆_»
                     (Term.hole "_")
                     "⊆"
                     (Term.app
                      `preimage
                      [(Term.fun
                        "fun"
                        (Term.basicFun
                         [`p]
                         [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                         "=>"
                         (Term.tuple
                          "("
                          [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                           ","
                           [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                          ")")))
                       (Term.app `interior [`t])]))
                    ":="
                    (Term.app `preimage_mono [`hm]))
                   [(calcStep
                     («term_⊆_»
                      (Term.hole "_")
                      "⊆"
                      (Term.app
                       `preimage
                       [(Term.fun
                         "fun"
                         (Term.basicFun
                          [`p]
                          [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                          "=>"
                          (Term.tuple
                           "("
                           [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                            ","
                            [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                           ")")))
                        `t]))
                     ":="
                     (Term.app `preimage_mono [`interior_subset]))
                    (calcStep
                     («term_⊆_»
                      (Term.hole "_")
                      "⊆"
                      (Term.app
                       `preimage
                       [(Term.fun
                         "fun"
                         (Term.basicFun
                          [`p]
                          [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                          "=>"
                          (Term.tuple
                           "("
                           [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                            ","
                            [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                           ")")))
                        `s]))
                     ":="
                     `ts)])))
                []
                (Term.have
                 "have"
                 (Term.haveDecl
                  (Term.haveIdDecl
                   []
                   [(Term.typeSpec
                     ":"
                     («term_⊆_»
                      (LowerSet.Order.UpperLower.lower_set.prod
                       (Set.Data.Set.Image.term_''_
                        `f
                        " '' "
                        (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                       " ×ˢ "
                       (Set.Data.Set.Image.term_''_
                        `f
                        " '' "
                        (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                      "⊆"
                      `s))]
                   ":="
                   (calc
                    "calc"
                    (calcStep
                     («term_=_»
                      (LowerSet.Order.UpperLower.lower_set.prod
                       (Set.Data.Set.Image.term_''_
                        `f
                        " '' "
                        (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                       " ×ˢ "
                       (Set.Data.Set.Image.term_''_
                        `f
                        " '' "
                        (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                      "="
                      (Set.Data.Set.Image.term_''_
                       (Term.fun
                        "fun"
                        (Term.basicFun
                         [`p]
                         [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                         "=>"
                         (Term.tuple
                          "("
                          [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                           ","
                           [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                          ")")))
                       " '' "
                       (LowerSet.Order.UpperLower.lower_set.prod
                        (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                        " ×ˢ "
                        (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
                     ":="
                     `prod_image_image_eq)
                    [(calcStep
                      («term_⊆_»
                       (Term.hole "_")
                       "⊆"
                       (Set.Data.Set.Image.term_''_
                        (Term.fun
                         "fun"
                         (Term.basicFun
                          [`p]
                          [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                          "=>"
                          (Term.tuple
                           "("
                           [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                            ","
                            [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                           ")")))
                        " '' "
                        (Set.Data.Set.Image.«term_⁻¹'_»
                         (Term.fun
                          "fun"
                          (Term.basicFun
                           [`p]
                           [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                           "=>"
                           (Term.tuple
                            "("
                            [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                             ","
                             [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                            ")")))
                         " ⁻¹' "
                         `s)))
                      ":="
                      (Term.app `monotone_image [`this]))
                     (calcStep
                      («term_⊆_» (Term.hole "_") "⊆" `s)
                      ":="
                      (Term.app `image_preimage_subset [(Term.hole "_") (Term.hole "_")]))])))
                 []
                 (Term.have
                  "have"
                  (Term.haveDecl
                   (Term.haveIdDecl
                    []
                    [(Term.typeSpec ":" («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
                    ":="
                    (Term.app
                     (Term.explicit "@" `this)
                     [(Term.tuple "(" [`a "," [`b]] ")")
                      (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
                  []
                  («term_<|_»
                   `hs_comp
                   "<|"
                   (Term.show
                    "show"
                    («term_∈_»
                     (Term.tuple
                      "("
                      [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
                       ","
                       [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
                      ")")
                     "∈"
                     (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
                    (Term.fromTerm
                     "from"
                     (Term.anonymousCtor
                      "⟨"
                      [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
                      "⟩"))))))))))))))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [(Term.anonymousCtor "⟨" [`x₁ "," `x₂] "⟩") `hx_t]
        []
        "=>"
        (Term.have
         "have"
         (Term.haveDecl
          (Term.haveIdDecl
           []
           [(Term.typeSpec
             ":"
             («term_≤_»
              (Term.app
               (TopologicalSpace.Topology.Basic.nhds "𝓝")
               [(Term.tuple "(" [`x₁ "," [`x₂]] ")")])
              "≤"
              (Term.app
               (Filter.Order.Filter.Basic.filter.principal "𝓟")
               [(Term.app `interior [`t])])))]
           ":="
           (Term.app
            (Term.proj `is_open_iff_nhds "." `mp)
            [`is_open_interior (Term.tuple "(" [`x₁ "," [`x₂]] ")") `hx_t])))
         []
         (Term.have
          "have"
          (Term.haveDecl
           (Term.haveIdDecl
            []
            [(Term.typeSpec
              ":"
              («term_∈_»
               (Term.app `interior [`t])
               "∈"
               (Filter.Order.Filter.Prod.filter.prod
                (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₁])
                " ×ᶠ "
                (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₂]))))]
            ":="
            (Term.byTactic
             "by"
             (Tactic.tacticSeq
              (Tactic.tacticSeq1Indented
               [(Std.Tactic.tacticRwa__
                 "rwa"
                 (Tactic.rwRuleSeq
                  "["
                  [(Tactic.rwRule [] `nhds_prod_eq) "," (Tactic.rwRule [] `le_principal_iff)]
                  "]")
                 [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
          []
          (Term.let
           "let"
           (Term.letDecl
            (Term.letPatDecl
             (Term.anonymousCtor
              "⟨"
              [`m₁
               ","
               `hm₁
               ","
               `m₂
               ","
               `hm₂
               ","
               (Term.typeAscription
                "("
                `hm
                ":"
                [(«term_⊆_»
                  (LowerSet.Order.UpperLower.lower_set.prod `m₁ " ×ˢ " `m₂)
                  "⊆"
                  (Term.app `interior [`t]))]
                ")")]
              "⟩")
             []
             []
             ":="
             (Term.app (Term.proj `mem_prod_iff "." `mp) [`this])))
           []
           (Term.let
            "let"
            (Term.letDecl
             (Term.letPatDecl
              (Term.anonymousCtor "⟨" [`a "," `ha₁ "," (Term.hole "_") "," `ha₂] "⟩")
              []
              []
              ":="
              (Term.app `h_pnt [`hm₁])))
            []
            (Term.let
             "let"
             (Term.letDecl
              (Term.letPatDecl
               (Term.anonymousCtor "⟨" [`b "," `hb₁ "," `hb₂ "," (Term.hole "_")] "⟩")
               []
               []
               ":="
               (Term.app `h_pnt [`hm₂])))
             []
             (Term.have
              "have"
              (Term.haveDecl
               (Term.haveIdDecl
                []
                [(Term.typeSpec
                  ":"
                  («term_⊆_»
                   (LowerSet.Order.UpperLower.lower_set.prod
                    (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                    " ×ˢ "
                    (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
                   "⊆"
                   (Set.Data.Set.Image.«term_⁻¹'_»
                    (Term.fun
                     "fun"
                     (Term.basicFun
                      [`p]
                      [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                      "=>"
                      (Term.tuple
                       "("
                       [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                        ","
                        [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                       ")")))
                    " ⁻¹' "
                    `s)))]
                ":="
                (calc
                 "calc"
                 (calcStep
                  («term_⊆_»
                   (Term.hole "_")
                   "⊆"
                   (Term.app
                    `preimage
                    [(Term.fun
                      "fun"
                      (Term.basicFun
                       [`p]
                       [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                       "=>"
                       (Term.tuple
                        "("
                        [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                         ","
                         [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                        ")")))
                     (Term.app `interior [`t])]))
                  ":="
                  (Term.app `preimage_mono [`hm]))
                 [(calcStep
                   («term_⊆_»
                    (Term.hole "_")
                    "⊆"
                    (Term.app
                     `preimage
                     [(Term.fun
                       "fun"
                       (Term.basicFun
                        [`p]
                        [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                        "=>"
                        (Term.tuple
                         "("
                         [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                          ","
                          [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                         ")")))
                      `t]))
                   ":="
                   (Term.app `preimage_mono [`interior_subset]))
                  (calcStep
                   («term_⊆_»
                    (Term.hole "_")
                    "⊆"
                    (Term.app
                     `preimage
                     [(Term.fun
                       "fun"
                       (Term.basicFun
                        [`p]
                        [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                        "=>"
                        (Term.tuple
                         "("
                         [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                          ","
                          [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                         ")")))
                      `s]))
                   ":="
                   `ts)])))
              []
              (Term.have
               "have"
               (Term.haveDecl
                (Term.haveIdDecl
                 []
                 [(Term.typeSpec
                   ":"
                   («term_⊆_»
                    (LowerSet.Order.UpperLower.lower_set.prod
                     (Set.Data.Set.Image.term_''_
                      `f
                      " '' "
                      (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                     " ×ˢ "
                     (Set.Data.Set.Image.term_''_
                      `f
                      " '' "
                      (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                    "⊆"
                    `s))]
                 ":="
                 (calc
                  "calc"
                  (calcStep
                   («term_=_»
                    (LowerSet.Order.UpperLower.lower_set.prod
                     (Set.Data.Set.Image.term_''_
                      `f
                      " '' "
                      (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                     " ×ˢ "
                     (Set.Data.Set.Image.term_''_
                      `f
                      " '' "
                      (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                    "="
                    (Set.Data.Set.Image.term_''_
                     (Term.fun
                      "fun"
                      (Term.basicFun
                       [`p]
                       [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                       "=>"
                       (Term.tuple
                        "("
                        [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                         ","
                         [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                        ")")))
                     " '' "
                     (LowerSet.Order.UpperLower.lower_set.prod
                      (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                      " ×ˢ "
                      (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
                   ":="
                   `prod_image_image_eq)
                  [(calcStep
                    («term_⊆_»
                     (Term.hole "_")
                     "⊆"
                     (Set.Data.Set.Image.term_''_
                      (Term.fun
                       "fun"
                       (Term.basicFun
                        [`p]
                        [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                        "=>"
                        (Term.tuple
                         "("
                         [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                          ","
                          [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                         ")")))
                      " '' "
                      (Set.Data.Set.Image.«term_⁻¹'_»
                       (Term.fun
                        "fun"
                        (Term.basicFun
                         [`p]
                         [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                         "=>"
                         (Term.tuple
                          "("
                          [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                           ","
                           [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                          ")")))
                       " ⁻¹' "
                       `s)))
                    ":="
                    (Term.app `monotone_image [`this]))
                   (calcStep
                    («term_⊆_» (Term.hole "_") "⊆" `s)
                    ":="
                    (Term.app `image_preimage_subset [(Term.hole "_") (Term.hole "_")]))])))
               []
               (Term.have
                "have"
                (Term.haveDecl
                 (Term.haveIdDecl
                  []
                  [(Term.typeSpec ":" («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
                  ":="
                  (Term.app
                   (Term.explicit "@" `this)
                   [(Term.tuple "(" [`a "," [`b]] ")")
                    (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
                []
                («term_<|_»
                 `hs_comp
                 "<|"
                 (Term.show
                  "show"
                  («term_∈_»
                   (Term.tuple
                    "("
                    [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
                     ","
                     [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
                    ")")
                   "∈"
                   (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
                  (Term.fromTerm
                   "from"
                   (Term.anonymousCtor
                    "⟨"
                    [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
                    "⟩"))))))))))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.have
       "have"
       (Term.haveDecl
        (Term.haveIdDecl
         []
         [(Term.typeSpec
           ":"
           («term_≤_»
            (Term.app
             (TopologicalSpace.Topology.Basic.nhds "𝓝")
             [(Term.tuple "(" [`x₁ "," [`x₂]] ")")])
            "≤"
            (Term.app
             (Filter.Order.Filter.Basic.filter.principal "𝓟")
             [(Term.app `interior [`t])])))]
         ":="
         (Term.app
          (Term.proj `is_open_iff_nhds "." `mp)
          [`is_open_interior (Term.tuple "(" [`x₁ "," [`x₂]] ")") `hx_t])))
       []
       (Term.have
        "have"
        (Term.haveDecl
         (Term.haveIdDecl
          []
          [(Term.typeSpec
            ":"
            («term_∈_»
             (Term.app `interior [`t])
             "∈"
             (Filter.Order.Filter.Prod.filter.prod
              (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₁])
              " ×ᶠ "
              (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₂]))))]
          ":="
          (Term.byTactic
           "by"
           (Tactic.tacticSeq
            (Tactic.tacticSeq1Indented
             [(Std.Tactic.tacticRwa__
               "rwa"
               (Tactic.rwRuleSeq
                "["
                [(Tactic.rwRule [] `nhds_prod_eq) "," (Tactic.rwRule [] `le_principal_iff)]
                "]")
               [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
        []
        (Term.let
         "let"
         (Term.letDecl
          (Term.letPatDecl
           (Term.anonymousCtor
            "⟨"
            [`m₁
             ","
             `hm₁
             ","
             `m₂
             ","
             `hm₂
             ","
             (Term.typeAscription
              "("
              `hm
              ":"
              [(«term_⊆_»
                (LowerSet.Order.UpperLower.lower_set.prod `m₁ " ×ˢ " `m₂)
                "⊆"
                (Term.app `interior [`t]))]
              ")")]
            "⟩")
           []
           []
           ":="
           (Term.app (Term.proj `mem_prod_iff "." `mp) [`this])))
         []
         (Term.let
          "let"
          (Term.letDecl
           (Term.letPatDecl
            (Term.anonymousCtor "⟨" [`a "," `ha₁ "," (Term.hole "_") "," `ha₂] "⟩")
            []
            []
            ":="
            (Term.app `h_pnt [`hm₁])))
          []
          (Term.let
           "let"
           (Term.letDecl
            (Term.letPatDecl
             (Term.anonymousCtor "⟨" [`b "," `hb₁ "," `hb₂ "," (Term.hole "_")] "⟩")
             []
             []
             ":="
             (Term.app `h_pnt [`hm₂])))
           []
           (Term.have
            "have"
            (Term.haveDecl
             (Term.haveIdDecl
              []
              [(Term.typeSpec
                ":"
                («term_⊆_»
                 (LowerSet.Order.UpperLower.lower_set.prod
                  (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                  " ×ˢ "
                  (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
                 "⊆"
                 (Set.Data.Set.Image.«term_⁻¹'_»
                  (Term.fun
                   "fun"
                   (Term.basicFun
                    [`p]
                    [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                    "=>"
                    (Term.tuple
                     "("
                     [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                      ","
                      [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                     ")")))
                  " ⁻¹' "
                  `s)))]
              ":="
              (calc
               "calc"
               (calcStep
                («term_⊆_»
                 (Term.hole "_")
                 "⊆"
                 (Term.app
                  `preimage
                  [(Term.fun
                    "fun"
                    (Term.basicFun
                     [`p]
                     [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                     "=>"
                     (Term.tuple
                      "("
                      [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                       ","
                       [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                      ")")))
                   (Term.app `interior [`t])]))
                ":="
                (Term.app `preimage_mono [`hm]))
               [(calcStep
                 («term_⊆_»
                  (Term.hole "_")
                  "⊆"
                  (Term.app
                   `preimage
                   [(Term.fun
                     "fun"
                     (Term.basicFun
                      [`p]
                      [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                      "=>"
                      (Term.tuple
                       "("
                       [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                        ","
                        [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                       ")")))
                    `t]))
                 ":="
                 (Term.app `preimage_mono [`interior_subset]))
                (calcStep
                 («term_⊆_»
                  (Term.hole "_")
                  "⊆"
                  (Term.app
                   `preimage
                   [(Term.fun
                     "fun"
                     (Term.basicFun
                      [`p]
                      [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                      "=>"
                      (Term.tuple
                       "("
                       [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                        ","
                        [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                       ")")))
                    `s]))
                 ":="
                 `ts)])))
            []
            (Term.have
             "have"
             (Term.haveDecl
              (Term.haveIdDecl
               []
               [(Term.typeSpec
                 ":"
                 («term_⊆_»
                  (LowerSet.Order.UpperLower.lower_set.prod
                   (Set.Data.Set.Image.term_''_
                    `f
                    " '' "
                    (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                   " ×ˢ "
                   (Set.Data.Set.Image.term_''_
                    `f
                    " '' "
                    (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                  "⊆"
                  `s))]
               ":="
               (calc
                "calc"
                (calcStep
                 («term_=_»
                  (LowerSet.Order.UpperLower.lower_set.prod
                   (Set.Data.Set.Image.term_''_
                    `f
                    " '' "
                    (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                   " ×ˢ "
                   (Set.Data.Set.Image.term_''_
                    `f
                    " '' "
                    (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                  "="
                  (Set.Data.Set.Image.term_''_
                   (Term.fun
                    "fun"
                    (Term.basicFun
                     [`p]
                     [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                     "=>"
                     (Term.tuple
                      "("
                      [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                       ","
                       [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                      ")")))
                   " '' "
                   (LowerSet.Order.UpperLower.lower_set.prod
                    (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                    " ×ˢ "
                    (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
                 ":="
                 `prod_image_image_eq)
                [(calcStep
                  («term_⊆_»
                   (Term.hole "_")
                   "⊆"
                   (Set.Data.Set.Image.term_''_
                    (Term.fun
                     "fun"
                     (Term.basicFun
                      [`p]
                      [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                      "=>"
                      (Term.tuple
                       "("
                       [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                        ","
                        [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                       ")")))
                    " '' "
                    (Set.Data.Set.Image.«term_⁻¹'_»
                     (Term.fun
                      "fun"
                      (Term.basicFun
                       [`p]
                       [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                       "=>"
                       (Term.tuple
                        "("
                        [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                         ","
                         [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                        ")")))
                     " ⁻¹' "
                     `s)))
                  ":="
                  (Term.app `monotone_image [`this]))
                 (calcStep
                  («term_⊆_» (Term.hole "_") "⊆" `s)
                  ":="
                  (Term.app `image_preimage_subset [(Term.hole "_") (Term.hole "_")]))])))
             []
             (Term.have
              "have"
              (Term.haveDecl
               (Term.haveIdDecl
                []
                [(Term.typeSpec ":" («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
                ":="
                (Term.app
                 (Term.explicit "@" `this)
                 [(Term.tuple "(" [`a "," [`b]] ")")
                  (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
              []
              («term_<|_»
               `hs_comp
               "<|"
               (Term.show
                "show"
                («term_∈_»
                 (Term.tuple
                  "("
                  [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
                   ","
                   [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
                  ")")
                 "∈"
                 (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
                (Term.fromTerm
                 "from"
                 (Term.anonymousCtor
                  "⟨"
                  [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
                  "⟩"))))))))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.have
       "have"
       (Term.haveDecl
        (Term.haveIdDecl
         []
         [(Term.typeSpec
           ":"
           («term_∈_»
            (Term.app `interior [`t])
            "∈"
            (Filter.Order.Filter.Prod.filter.prod
             (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₁])
             " ×ᶠ "
             (Term.app (TopologicalSpace.Topology.Basic.nhds "𝓝") [`x₂]))))]
         ":="
         (Term.byTactic
          "by"
          (Tactic.tacticSeq
           (Tactic.tacticSeq1Indented
            [(Std.Tactic.tacticRwa__
              "rwa"
              (Tactic.rwRuleSeq
               "["
               [(Tactic.rwRule [] `nhds_prod_eq) "," (Tactic.rwRule [] `le_principal_iff)]
               "]")
              [(Tactic.location "at" (Tactic.locationHyp [`this] []))])])))))
       []
       (Term.let
        "let"
        (Term.letDecl
         (Term.letPatDecl
          (Term.anonymousCtor
           "⟨"
           [`m₁
            ","
            `hm₁
            ","
            `m₂
            ","
            `hm₂
            ","
            (Term.typeAscription
             "("
             `hm
             ":"
             [(«term_⊆_»
               (LowerSet.Order.UpperLower.lower_set.prod `m₁ " ×ˢ " `m₂)
               "⊆"
               (Term.app `interior [`t]))]
             ")")]
           "⟩")
          []
          []
          ":="
          (Term.app (Term.proj `mem_prod_iff "." `mp) [`this])))
        []
        (Term.let
         "let"
         (Term.letDecl
          (Term.letPatDecl
           (Term.anonymousCtor "⟨" [`a "," `ha₁ "," (Term.hole "_") "," `ha₂] "⟩")
           []
           []
           ":="
           (Term.app `h_pnt [`hm₁])))
         []
         (Term.let
          "let"
          (Term.letDecl
           (Term.letPatDecl
            (Term.anonymousCtor "⟨" [`b "," `hb₁ "," `hb₂ "," (Term.hole "_")] "⟩")
            []
            []
            ":="
            (Term.app `h_pnt [`hm₂])))
          []
          (Term.have
           "have"
           (Term.haveDecl
            (Term.haveIdDecl
             []
             [(Term.typeSpec
               ":"
               («term_⊆_»
                (LowerSet.Order.UpperLower.lower_set.prod
                 (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                 " ×ˢ "
                 (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
                "⊆"
                (Set.Data.Set.Image.«term_⁻¹'_»
                 (Term.fun
                  "fun"
                  (Term.basicFun
                   [`p]
                   [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                   "=>"
                   (Term.tuple
                    "("
                    [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                     ","
                     [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                    ")")))
                 " ⁻¹' "
                 `s)))]
             ":="
             (calc
              "calc"
              (calcStep
               («term_⊆_»
                (Term.hole "_")
                "⊆"
                (Term.app
                 `preimage
                 [(Term.fun
                   "fun"
                   (Term.basicFun
                    [`p]
                    [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                    "=>"
                    (Term.tuple
                     "("
                     [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                      ","
                      [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                     ")")))
                  (Term.app `interior [`t])]))
               ":="
               (Term.app `preimage_mono [`hm]))
              [(calcStep
                («term_⊆_»
                 (Term.hole "_")
                 "⊆"
                 (Term.app
                  `preimage
                  [(Term.fun
                    "fun"
                    (Term.basicFun
                     [`p]
                     [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                     "=>"
                     (Term.tuple
                      "("
                      [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                       ","
                       [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                      ")")))
                   `t]))
                ":="
                (Term.app `preimage_mono [`interior_subset]))
               (calcStep
                («term_⊆_»
                 (Term.hole "_")
                 "⊆"
                 (Term.app
                  `preimage
                  [(Term.fun
                    "fun"
                    (Term.basicFun
                     [`p]
                     [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                     "=>"
                     (Term.tuple
                      "("
                      [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                       ","
                       [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                      ")")))
                   `s]))
                ":="
                `ts)])))
           []
           (Term.have
            "have"
            (Term.haveDecl
             (Term.haveIdDecl
              []
              [(Term.typeSpec
                ":"
                («term_⊆_»
                 (LowerSet.Order.UpperLower.lower_set.prod
                  (Set.Data.Set.Image.term_''_
                   `f
                   " '' "
                   (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                  " ×ˢ "
                  (Set.Data.Set.Image.term_''_
                   `f
                   " '' "
                   (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                 "⊆"
                 `s))]
              ":="
              (calc
               "calc"
               (calcStep
                («term_=_»
                 (LowerSet.Order.UpperLower.lower_set.prod
                  (Set.Data.Set.Image.term_''_
                   `f
                   " '' "
                   (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                  " ×ˢ "
                  (Set.Data.Set.Image.term_''_
                   `f
                   " '' "
                   (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                 "="
                 (Set.Data.Set.Image.term_''_
                  (Term.fun
                   "fun"
                   (Term.basicFun
                    [`p]
                    [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                    "=>"
                    (Term.tuple
                     "("
                     [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                      ","
                      [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                     ")")))
                  " '' "
                  (LowerSet.Order.UpperLower.lower_set.prod
                   (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                   " ×ˢ "
                   (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
                ":="
                `prod_image_image_eq)
               [(calcStep
                 («term_⊆_»
                  (Term.hole "_")
                  "⊆"
                  (Set.Data.Set.Image.term_''_
                   (Term.fun
                    "fun"
                    (Term.basicFun
                     [`p]
                     [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                     "=>"
                     (Term.tuple
                      "("
                      [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                       ","
                       [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                      ")")))
                   " '' "
                   (Set.Data.Set.Image.«term_⁻¹'_»
                    (Term.fun
                     "fun"
                     (Term.basicFun
                      [`p]
                      [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                      "=>"
                      (Term.tuple
                       "("
                       [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                        ","
                        [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                       ")")))
                    " ⁻¹' "
                    `s)))
                 ":="
                 (Term.app `monotone_image [`this]))
                (calcStep
                 («term_⊆_» (Term.hole "_") "⊆" `s)
                 ":="
                 (Term.app `image_preimage_subset [(Term.hole "_") (Term.hole "_")]))])))
            []
            (Term.have
             "have"
             (Term.haveDecl
              (Term.haveIdDecl
               []
               [(Term.typeSpec ":" («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
               ":="
               (Term.app
                (Term.explicit "@" `this)
                [(Term.tuple "(" [`a "," [`b]] ")") (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
             []
             («term_<|_»
              `hs_comp
              "<|"
              (Term.show
               "show"
               («term_∈_»
                (Term.tuple
                 "("
                 [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
                  ","
                  [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
                 ")")
                "∈"
                (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
               (Term.fromTerm
                "from"
                (Term.anonymousCtor
                 "⟨"
                 [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
                 "⟩")))))))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.let
       "let"
       (Term.letDecl
        (Term.letPatDecl
         (Term.anonymousCtor
          "⟨"
          [`m₁
           ","
           `hm₁
           ","
           `m₂
           ","
           `hm₂
           ","
           (Term.typeAscription
            "("
            `hm
            ":"
            [(«term_⊆_»
              (LowerSet.Order.UpperLower.lower_set.prod `m₁ " ×ˢ " `m₂)
              "⊆"
              (Term.app `interior [`t]))]
            ")")]
          "⟩")
         []
         []
         ":="
         (Term.app (Term.proj `mem_prod_iff "." `mp) [`this])))
       []
       (Term.let
        "let"
        (Term.letDecl
         (Term.letPatDecl
          (Term.anonymousCtor "⟨" [`a "," `ha₁ "," (Term.hole "_") "," `ha₂] "⟩")
          []
          []
          ":="
          (Term.app `h_pnt [`hm₁])))
        []
        (Term.let
         "let"
         (Term.letDecl
          (Term.letPatDecl
           (Term.anonymousCtor "⟨" [`b "," `hb₁ "," `hb₂ "," (Term.hole "_")] "⟩")
           []
           []
           ":="
           (Term.app `h_pnt [`hm₂])))
         []
         (Term.have
          "have"
          (Term.haveDecl
           (Term.haveIdDecl
            []
            [(Term.typeSpec
              ":"
              («term_⊆_»
               (LowerSet.Order.UpperLower.lower_set.prod
                (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                " ×ˢ "
                (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
               "⊆"
               (Set.Data.Set.Image.«term_⁻¹'_»
                (Term.fun
                 "fun"
                 (Term.basicFun
                  [`p]
                  [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                  "=>"
                  (Term.tuple
                   "("
                   [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                    ","
                    [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                   ")")))
                " ⁻¹' "
                `s)))]
            ":="
            (calc
             "calc"
             (calcStep
              («term_⊆_»
               (Term.hole "_")
               "⊆"
               (Term.app
                `preimage
                [(Term.fun
                  "fun"
                  (Term.basicFun
                   [`p]
                   [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                   "=>"
                   (Term.tuple
                    "("
                    [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                     ","
                     [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                    ")")))
                 (Term.app `interior [`t])]))
              ":="
              (Term.app `preimage_mono [`hm]))
             [(calcStep
               («term_⊆_»
                (Term.hole "_")
                "⊆"
                (Term.app
                 `preimage
                 [(Term.fun
                   "fun"
                   (Term.basicFun
                    [`p]
                    [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                    "=>"
                    (Term.tuple
                     "("
                     [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                      ","
                      [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                     ")")))
                  `t]))
               ":="
               (Term.app `preimage_mono [`interior_subset]))
              (calcStep
               («term_⊆_»
                (Term.hole "_")
                "⊆"
                (Term.app
                 `preimage
                 [(Term.fun
                   "fun"
                   (Term.basicFun
                    [`p]
                    [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                    "=>"
                    (Term.tuple
                     "("
                     [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                      ","
                      [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                     ")")))
                  `s]))
               ":="
               `ts)])))
          []
          (Term.have
           "have"
           (Term.haveDecl
            (Term.haveIdDecl
             []
             [(Term.typeSpec
               ":"
               («term_⊆_»
                (LowerSet.Order.UpperLower.lower_set.prod
                 (Set.Data.Set.Image.term_''_
                  `f
                  " '' "
                  (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                 " ×ˢ "
                 (Set.Data.Set.Image.term_''_
                  `f
                  " '' "
                  (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                "⊆"
                `s))]
             ":="
             (calc
              "calc"
              (calcStep
               («term_=_»
                (LowerSet.Order.UpperLower.lower_set.prod
                 (Set.Data.Set.Image.term_''_
                  `f
                  " '' "
                  (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                 " ×ˢ "
                 (Set.Data.Set.Image.term_''_
                  `f
                  " '' "
                  (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
                "="
                (Set.Data.Set.Image.term_''_
                 (Term.fun
                  "fun"
                  (Term.basicFun
                   [`p]
                   [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                   "=>"
                   (Term.tuple
                    "("
                    [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                     ","
                     [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                    ")")))
                 " '' "
                 (LowerSet.Order.UpperLower.lower_set.prod
                  (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                  " ×ˢ "
                  (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
               ":="
               `prod_image_image_eq)
              [(calcStep
                («term_⊆_»
                 (Term.hole "_")
                 "⊆"
                 (Set.Data.Set.Image.term_''_
                  (Term.fun
                   "fun"
                   (Term.basicFun
                    [`p]
                    [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                    "=>"
                    (Term.tuple
                     "("
                     [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                      ","
                      [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                     ")")))
                  " '' "
                  (Set.Data.Set.Image.«term_⁻¹'_»
                   (Term.fun
                    "fun"
                    (Term.basicFun
                     [`p]
                     [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                     "=>"
                     (Term.tuple
                      "("
                      [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                       ","
                       [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                      ")")))
                   " ⁻¹' "
                   `s)))
                ":="
                (Term.app `monotone_image [`this]))
               (calcStep
                («term_⊆_» (Term.hole "_") "⊆" `s)
                ":="
                (Term.app `image_preimage_subset [(Term.hole "_") (Term.hole "_")]))])))
           []
           (Term.have
            "have"
            (Term.haveDecl
             (Term.haveIdDecl
              []
              [(Term.typeSpec ":" («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
              ":="
              (Term.app
               (Term.explicit "@" `this)
               [(Term.tuple "(" [`a "," [`b]] ")") (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
            []
            («term_<|_»
             `hs_comp
             "<|"
             (Term.show
              "show"
              («term_∈_»
               (Term.tuple
                "("
                [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
                 ","
                 [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
                ")")
               "∈"
               (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
              (Term.fromTerm
               "from"
               (Term.anonymousCtor
                "⟨"
                [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
                "⟩"))))))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.let
       "let"
       (Term.letDecl
        (Term.letPatDecl
         (Term.anonymousCtor "⟨" [`a "," `ha₁ "," (Term.hole "_") "," `ha₂] "⟩")
         []
         []
         ":="
         (Term.app `h_pnt [`hm₁])))
       []
       (Term.let
        "let"
        (Term.letDecl
         (Term.letPatDecl
          (Term.anonymousCtor "⟨" [`b "," `hb₁ "," `hb₂ "," (Term.hole "_")] "⟩")
          []
          []
          ":="
          (Term.app `h_pnt [`hm₂])))
        []
        (Term.have
         "have"
         (Term.haveDecl
          (Term.haveIdDecl
           []
           [(Term.typeSpec
             ":"
             («term_⊆_»
              (LowerSet.Order.UpperLower.lower_set.prod
               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
               " ×ˢ "
               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
              "⊆"
              (Set.Data.Set.Image.«term_⁻¹'_»
               (Term.fun
                "fun"
                (Term.basicFun
                 [`p]
                 [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                 "=>"
                 (Term.tuple
                  "("
                  [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                   ","
                   [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                  ")")))
               " ⁻¹' "
               `s)))]
           ":="
           (calc
            "calc"
            (calcStep
             («term_⊆_»
              (Term.hole "_")
              "⊆"
              (Term.app
               `preimage
               [(Term.fun
                 "fun"
                 (Term.basicFun
                  [`p]
                  [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                  "=>"
                  (Term.tuple
                   "("
                   [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                    ","
                    [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                   ")")))
                (Term.app `interior [`t])]))
             ":="
             (Term.app `preimage_mono [`hm]))
            [(calcStep
              («term_⊆_»
               (Term.hole "_")
               "⊆"
               (Term.app
                `preimage
                [(Term.fun
                  "fun"
                  (Term.basicFun
                   [`p]
                   [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                   "=>"
                   (Term.tuple
                    "("
                    [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                     ","
                     [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                    ")")))
                 `t]))
              ":="
              (Term.app `preimage_mono [`interior_subset]))
             (calcStep
              («term_⊆_»
               (Term.hole "_")
               "⊆"
               (Term.app
                `preimage
                [(Term.fun
                  "fun"
                  (Term.basicFun
                   [`p]
                   [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                   "=>"
                   (Term.tuple
                    "("
                    [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                     ","
                     [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                    ")")))
                 `s]))
              ":="
              `ts)])))
         []
         (Term.have
          "have"
          (Term.haveDecl
           (Term.haveIdDecl
            []
            [(Term.typeSpec
              ":"
              («term_⊆_»
               (LowerSet.Order.UpperLower.lower_set.prod
                (Set.Data.Set.Image.term_''_
                 `f
                 " '' "
                 (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                " ×ˢ "
                (Set.Data.Set.Image.term_''_
                 `f
                 " '' "
                 (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
               "⊆"
               `s))]
            ":="
            (calc
             "calc"
             (calcStep
              («term_=_»
               (LowerSet.Order.UpperLower.lower_set.prod
                (Set.Data.Set.Image.term_''_
                 `f
                 " '' "
                 (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
                " ×ˢ "
                (Set.Data.Set.Image.term_''_
                 `f
                 " '' "
                 (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
               "="
               (Set.Data.Set.Image.term_''_
                (Term.fun
                 "fun"
                 (Term.basicFun
                  [`p]
                  [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                  "=>"
                  (Term.tuple
                   "("
                   [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                    ","
                    [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                   ")")))
                " '' "
                (LowerSet.Order.UpperLower.lower_set.prod
                 (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                 " ×ˢ "
                 (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
              ":="
              `prod_image_image_eq)
             [(calcStep
               («term_⊆_»
                (Term.hole "_")
                "⊆"
                (Set.Data.Set.Image.term_''_
                 (Term.fun
                  "fun"
                  (Term.basicFun
                   [`p]
                   [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                   "=>"
                   (Term.tuple
                    "("
                    [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                     ","
                     [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                    ")")))
                 " '' "
                 (Set.Data.Set.Image.«term_⁻¹'_»
                  (Term.fun
                   "fun"
                   (Term.basicFun
                    [`p]
                    [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                    "=>"
                    (Term.tuple
                     "("
                     [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                      ","
                      [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                     ")")))
                  " ⁻¹' "
                  `s)))
               ":="
               (Term.app `monotone_image [`this]))
              (calcStep
               («term_⊆_» (Term.hole "_") "⊆" `s)
               ":="
               (Term.app `image_preimage_subset [(Term.hole "_") (Term.hole "_")]))])))
          []
          (Term.have
           "have"
           (Term.haveDecl
            (Term.haveIdDecl
             []
             [(Term.typeSpec ":" («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
             ":="
             (Term.app
              (Term.explicit "@" `this)
              [(Term.tuple "(" [`a "," [`b]] ")") (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
           []
           («term_<|_»
            `hs_comp
            "<|"
            (Term.show
             "show"
             («term_∈_»
              (Term.tuple
               "("
               [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
                ","
                [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
               ")")
              "∈"
              (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
             (Term.fromTerm
              "from"
              (Term.anonymousCtor
               "⟨"
               [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
               "⟩")))))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.let
       "let"
       (Term.letDecl
        (Term.letPatDecl
         (Term.anonymousCtor "⟨" [`b "," `hb₁ "," `hb₂ "," (Term.hole "_")] "⟩")
         []
         []
         ":="
         (Term.app `h_pnt [`hm₂])))
       []
       (Term.have
        "have"
        (Term.haveDecl
         (Term.haveIdDecl
          []
          [(Term.typeSpec
            ":"
            («term_⊆_»
             (LowerSet.Order.UpperLower.lower_set.prod
              (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
              " ×ˢ "
              (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
             "⊆"
             (Set.Data.Set.Image.«term_⁻¹'_»
              (Term.fun
               "fun"
               (Term.basicFun
                [`p]
                [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                "=>"
                (Term.tuple
                 "("
                 [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                  ","
                  [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                 ")")))
              " ⁻¹' "
              `s)))]
          ":="
          (calc
           "calc"
           (calcStep
            («term_⊆_»
             (Term.hole "_")
             "⊆"
             (Term.app
              `preimage
              [(Term.fun
                "fun"
                (Term.basicFun
                 [`p]
                 [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                 "=>"
                 (Term.tuple
                  "("
                  [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                   ","
                   [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                  ")")))
               (Term.app `interior [`t])]))
            ":="
            (Term.app `preimage_mono [`hm]))
           [(calcStep
             («term_⊆_»
              (Term.hole "_")
              "⊆"
              (Term.app
               `preimage
               [(Term.fun
                 "fun"
                 (Term.basicFun
                  [`p]
                  [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                  "=>"
                  (Term.tuple
                   "("
                   [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                    ","
                    [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                   ")")))
                `t]))
             ":="
             (Term.app `preimage_mono [`interior_subset]))
            (calcStep
             («term_⊆_»
              (Term.hole "_")
              "⊆"
              (Term.app
               `preimage
               [(Term.fun
                 "fun"
                 (Term.basicFun
                  [`p]
                  [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                  "=>"
                  (Term.tuple
                   "("
                   [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                    ","
                    [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                   ")")))
                `s]))
             ":="
             `ts)])))
        []
        (Term.have
         "have"
         (Term.haveDecl
          (Term.haveIdDecl
           []
           [(Term.typeSpec
             ":"
             («term_⊆_»
              (LowerSet.Order.UpperLower.lower_set.prod
               (Set.Data.Set.Image.term_''_
                `f
                " '' "
                (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
               " ×ˢ "
               (Set.Data.Set.Image.term_''_
                `f
                " '' "
                (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
              "⊆"
              `s))]
           ":="
           (calc
            "calc"
            (calcStep
             («term_=_»
              (LowerSet.Order.UpperLower.lower_set.prod
               (Set.Data.Set.Image.term_''_
                `f
                " '' "
                (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
               " ×ˢ "
               (Set.Data.Set.Image.term_''_
                `f
                " '' "
                (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
              "="
              (Set.Data.Set.Image.term_''_
               (Term.fun
                "fun"
                (Term.basicFun
                 [`p]
                 [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                 "=>"
                 (Term.tuple
                  "("
                  [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                   ","
                   [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                  ")")))
               " '' "
               (LowerSet.Order.UpperLower.lower_set.prod
                (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
                " ×ˢ "
                (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
             ":="
             `prod_image_image_eq)
            [(calcStep
              («term_⊆_»
               (Term.hole "_")
               "⊆"
               (Set.Data.Set.Image.term_''_
                (Term.fun
                 "fun"
                 (Term.basicFun
                  [`p]
                  [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                  "=>"
                  (Term.tuple
                   "("
                   [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                    ","
                    [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                   ")")))
                " '' "
                (Set.Data.Set.Image.«term_⁻¹'_»
                 (Term.fun
                  "fun"
                  (Term.basicFun
                   [`p]
                   [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                   "=>"
                   (Term.tuple
                    "("
                    [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                     ","
                     [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                    ")")))
                 " ⁻¹' "
                 `s)))
              ":="
              (Term.app `monotone_image [`this]))
             (calcStep
              («term_⊆_» (Term.hole "_") "⊆" `s)
              ":="
              (Term.app `image_preimage_subset [(Term.hole "_") (Term.hole "_")]))])))
         []
         (Term.have
          "have"
          (Term.haveDecl
           (Term.haveIdDecl
            []
            [(Term.typeSpec ":" («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
            ":="
            (Term.app
             (Term.explicit "@" `this)
             [(Term.tuple "(" [`a "," [`b]] ")") (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
          []
          («term_<|_»
           `hs_comp
           "<|"
           (Term.show
            "show"
            («term_∈_»
             (Term.tuple
              "("
              [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
               ","
               [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
              ")")
             "∈"
             (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
            (Term.fromTerm
             "from"
             (Term.anonymousCtor
              "⟨"
              [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
              "⟩"))))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.have
       "have"
       (Term.haveDecl
        (Term.haveIdDecl
         []
         [(Term.typeSpec
           ":"
           («term_⊆_»
            (LowerSet.Order.UpperLower.lower_set.prod
             (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
             " ×ˢ "
             (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))
            "⊆"
            (Set.Data.Set.Image.«term_⁻¹'_»
             (Term.fun
              "fun"
              (Term.basicFun
               [`p]
               [(Term.typeSpec ":" («term_×_» `β "×" `β))]
               "=>"
               (Term.tuple
                "("
                [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                 ","
                 [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                ")")))
             " ⁻¹' "
             `s)))]
         ":="
         (calc
          "calc"
          (calcStep
           («term_⊆_»
            (Term.hole "_")
            "⊆"
            (Term.app
             `preimage
             [(Term.fun
               "fun"
               (Term.basicFun
                [`p]
                [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                "=>"
                (Term.tuple
                 "("
                 [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                  ","
                  [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                 ")")))
              (Term.app `interior [`t])]))
           ":="
           (Term.app `preimage_mono [`hm]))
          [(calcStep
            («term_⊆_»
             (Term.hole "_")
             "⊆"
             (Term.app
              `preimage
              [(Term.fun
                "fun"
                (Term.basicFun
                 [`p]
                 [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                 "=>"
                 (Term.tuple
                  "("
                  [(Term.app `e [(Term.proj `p "." (fieldIdx "1"))])
                   ","
                   [(Term.app `e [(Term.proj `p "." (fieldIdx "2"))])]]
                  ")")))
               `t]))
            ":="
            (Term.app `preimage_mono [`interior_subset]))
           (calcStep
            («term_⊆_»
             (Term.hole "_")
             "⊆"
             (Term.app
              `preimage
              [(Term.fun
                "fun"
                (Term.basicFun
                 [`p]
                 [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                 "=>"
                 (Term.tuple
                  "("
                  [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                   ","
                   [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                  ")")))
               `s]))
            ":="
            `ts)])))
       []
       (Term.have
        "have"
        (Term.haveDecl
         (Term.haveIdDecl
          []
          [(Term.typeSpec
            ":"
            («term_⊆_»
             (LowerSet.Order.UpperLower.lower_set.prod
              (Set.Data.Set.Image.term_''_
               `f
               " '' "
               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
              " ×ˢ "
              (Set.Data.Set.Image.term_''_
               `f
               " '' "
               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
             "⊆"
             `s))]
          ":="
          (calc
           "calc"
           (calcStep
            («term_=_»
             (LowerSet.Order.UpperLower.lower_set.prod
              (Set.Data.Set.Image.term_''_
               `f
               " '' "
               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
              " ×ˢ "
              (Set.Data.Set.Image.term_''_
               `f
               " '' "
               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
             "="
             (Set.Data.Set.Image.term_''_
              (Term.fun
               "fun"
               (Term.basicFun
                [`p]
                [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                "=>"
                (Term.tuple
                 "("
                 [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                  ","
                  [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                 ")")))
              " '' "
              (LowerSet.Order.UpperLower.lower_set.prod
               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
               " ×ˢ "
               (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
            ":="
            `prod_image_image_eq)
           [(calcStep
             («term_⊆_»
              (Term.hole "_")
              "⊆"
              (Set.Data.Set.Image.term_''_
               (Term.fun
                "fun"
                (Term.basicFun
                 [`p]
                 [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                 "=>"
                 (Term.tuple
                  "("
                  [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                   ","
                   [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                  ")")))
               " '' "
               (Set.Data.Set.Image.«term_⁻¹'_»
                (Term.fun
                 "fun"
                 (Term.basicFun
                  [`p]
                  [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                  "=>"
                  (Term.tuple
                   "("
                   [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                    ","
                    [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                   ")")))
                " ⁻¹' "
                `s)))
             ":="
             (Term.app `monotone_image [`this]))
            (calcStep
             («term_⊆_» (Term.hole "_") "⊆" `s)
             ":="
             (Term.app `image_preimage_subset [(Term.hole "_") (Term.hole "_")]))])))
        []
        (Term.have
         "have"
         (Term.haveDecl
          (Term.haveIdDecl
           []
           [(Term.typeSpec ":" («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
           ":="
           (Term.app
            (Term.explicit "@" `this)
            [(Term.tuple "(" [`a "," [`b]] ")") (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
         []
         («term_<|_»
          `hs_comp
          "<|"
          (Term.show
           "show"
           («term_∈_»
            (Term.tuple
             "("
             [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
              ","
              [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
             ")")
            "∈"
            (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
           (Term.fromTerm
            "from"
            (Term.anonymousCtor
             "⟨"
             [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
             "⟩")))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.have
       "have"
       (Term.haveDecl
        (Term.haveIdDecl
         []
         [(Term.typeSpec
           ":"
           («term_⊆_»
            (LowerSet.Order.UpperLower.lower_set.prod
             (Set.Data.Set.Image.term_''_ `f " '' " (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
             " ×ˢ "
             (Set.Data.Set.Image.term_''_
              `f
              " '' "
              (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
            "⊆"
            `s))]
         ":="
         (calc
          "calc"
          (calcStep
           («term_=_»
            (LowerSet.Order.UpperLower.lower_set.prod
             (Set.Data.Set.Image.term_''_ `f " '' " (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁))
             " ×ˢ "
             (Set.Data.Set.Image.term_''_
              `f
              " '' "
              (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂)))
            "="
            (Set.Data.Set.Image.term_''_
             (Term.fun
              "fun"
              (Term.basicFun
               [`p]
               [(Term.typeSpec ":" («term_×_» `β "×" `β))]
               "=>"
               (Term.tuple
                "("
                [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                 ","
                 [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                ")")))
             " '' "
             (LowerSet.Order.UpperLower.lower_set.prod
              (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₁)
              " ×ˢ "
              (Set.Data.Set.Image.«term_⁻¹'_» `e " ⁻¹' " `m₂))))
           ":="
           `prod_image_image_eq)
          [(calcStep
            («term_⊆_»
             (Term.hole "_")
             "⊆"
             (Set.Data.Set.Image.term_''_
              (Term.fun
               "fun"
               (Term.basicFun
                [`p]
                [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                "=>"
                (Term.tuple
                 "("
                 [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                  ","
                  [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                 ")")))
              " '' "
              (Set.Data.Set.Image.«term_⁻¹'_»
               (Term.fun
                "fun"
                (Term.basicFun
                 [`p]
                 [(Term.typeSpec ":" («term_×_» `β "×" `β))]
                 "=>"
                 (Term.tuple
                  "("
                  [(Term.app `f [(Term.proj `p "." (fieldIdx "1"))])
                   ","
                   [(Term.app `f [(Term.proj `p "." (fieldIdx "2"))])]]
                  ")")))
               " ⁻¹' "
               `s)))
            ":="
            (Term.app `monotone_image [`this]))
           (calcStep
            («term_⊆_» (Term.hole "_") "⊆" `s)
            ":="
            (Term.app `image_preimage_subset [(Term.hole "_") (Term.hole "_")]))])))
       []
       (Term.have
        "have"
        (Term.haveDecl
         (Term.haveIdDecl
          []
          [(Term.typeSpec ":" («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
          ":="
          (Term.app
           (Term.explicit "@" `this)
           [(Term.tuple "(" [`a "," [`b]] ")") (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
        []
        («term_<|_»
         `hs_comp
         "<|"
         (Term.show
          "show"
          («term_∈_»
           (Term.tuple
            "("
            [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
             ","
             [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
            ")")
           "∈"
           (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
          (Term.fromTerm
           "from"
           (Term.anonymousCtor
            "⟨"
            [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
            "⟩"))))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.have
       "have"
       (Term.haveDecl
        (Term.haveIdDecl
         []
         [(Term.typeSpec ":" («term_∈_» (Term.tuple "(" [`a "," [`b]] ")") "∈" `s))]
         ":="
         (Term.app
          (Term.explicit "@" `this)
          [(Term.tuple "(" [`a "," [`b]] ")") (Term.anonymousCtor "⟨" [`ha₁ "," `hb₁] "⟩")])))
       []
       («term_<|_»
        `hs_comp
        "<|"
        (Term.show
         "show"
         («term_∈_»
          (Term.tuple
           "("
           [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
            ","
            [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
           ")")
          "∈"
          (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
         (Term.fromTerm
          "from"
          (Term.anonymousCtor
           "⟨"
           [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
           "⟩")))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_<|_»
       `hs_comp
       "<|"
       (Term.show
        "show"
        («term_∈_»
         (Term.tuple
          "("
          [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
           ","
           [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
          ")")
         "∈"
         (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
        (Term.fromTerm
         "from"
         (Term.anonymousCtor
          "⟨"
          [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
          "⟩"))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.show
       "show"
       («term_∈_»
        (Term.tuple
         "("
         [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
          ","
          [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
         ")")
        "∈"
        (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
       (Term.fromTerm
        "from"
        (Term.anonymousCtor
         "⟨"
         [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
         "⟩")))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor
       "⟨"
       [`a "," `ha₂ "," (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")]
       "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor "⟨" [`b "," `this "," `hb₂] "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hb₂
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `this
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `b
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `ha₂
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `a
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_∈_»
       (Term.tuple
        "("
        [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
         ","
         [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
        ")")
       "∈"
       (Term.app `compRel [`s (Term.app `compRel [`s `s])]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `compRel [`s (Term.app `compRel [`s `s])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `compRel [`s `s])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `s
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `s
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `compRel
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `compRel [`s `s]) ")")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `s
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `compRel
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      (Term.tuple
       "("
       [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₁])
        ","
        [(Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])]]
       ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [`x₂])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `x₂
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Topology.UniformSpace.UniformEmbedding.termψ', expected 'Topology.UniformSpace.UniformEmbedding.termψ._@.Topology.UniformSpace.UniformEmbedding._hyg.9'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.basicFun', expected 'Lean.Parser.Term.matchAlts'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fromTerm', expected 'Lean.Parser.Term.byTactic''
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.basicFun', expected 'Lean.Parser.Term.matchAlts'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.declValEqns'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.whereStructInst'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  uniform_continuous_uniformly_extend
  [ cγ : CompleteSpace γ ] : UniformContinuous ψ
  :=
    fun
      d hd
        =>
        let
          ⟨ s , hs , hs_comp ⟩
            :=
            mem_lift'_sets
                  <|
                  monotone_comp_rel monotone_id <| monotone_comp_rel monotone_id monotone_id
                .
                mp
              comp_le_uniformity3 hd
          have
            h_pnt
              :
                ∀
                  { a m }
                  ,
                  m ∈ 𝓝 a → ∃ c , c ∈ f '' preimage e m ∧ ( c , ψ a ) ∈ s ∧ ( ψ a , c ) ∈ s
              :=
              fun
                a m hm
                  =>
                  have
                    nb
                      : NeBot map f comap e 𝓝 a
                      :=
                      h_e . DenseInducing h_dense . comap_nhds_ne_bot _ . map _
                    have
                      :
                          f '' preimage e m ∩ { c | ( c , ψ a ) ∈ s } ∩ { c | ( ψ a , c ) ∈ s }
                            ∈
                            map f comap e 𝓝 a
                        :=
                        inter_mem
                          image_mem_map <| preimage_mem_comap <| hm
                            uniformly_extend_spec
                              h_e h_dense h_f _ inter_mem mem_nhds_right _ hs mem_nhds_left _ hs
                      nb . nonempty_of_mem this
            have
              : preimage fun p : β × β => ( f p . 1 , f p . 2 ) s ∈ 𝓤 β := h_f hs
              have
                :
                    preimage fun p : β × β => ( f p . 1 , f p . 2 ) s
                      ∈
                      comap fun x : β × β => ( e x . 1 , e x . 2 ) 𝓤 α
                  :=
                  by rwa [ h_e.comap_uniformity.symm ] at this
                let
                  ⟨ t , ht , ts ⟩ := this
                  show
                    preimage fun p : α × α => ( ψ p . 1 , ψ p . 2 ) d ∈ 𝓤 α
                    from
                      𝓤 α . sets_of_superset interior_mem_uniformity ht
                        fun
                          ⟨ x₁ , x₂ ⟩ hx_t
                            =>
                            have
                              : 𝓝 ( x₁ , x₂ ) ≤ 𝓟 interior t
                                :=
                                is_open_iff_nhds . mp is_open_interior ( x₁ , x₂ ) hx_t
                              have
                                : interior t ∈ 𝓝 x₁ ×ᶠ 𝓝 x₂
                                  :=
                                  by rwa [ nhds_prod_eq , le_principal_iff ] at this
                                let
                                  ⟨ m₁ , hm₁ , m₂ , hm₂ , ( hm : m₁ ×ˢ m₂ ⊆ interior t ) ⟩
                                    :=
                                    mem_prod_iff . mp this
                                  let
                                    ⟨ a , ha₁ , _ , ha₂ ⟩ := h_pnt hm₁
                                    let
                                      ⟨ b , hb₁ , hb₂ , _ ⟩ := h_pnt hm₂
                                      have
                                        :
                                            e ⁻¹' m₁ ×ˢ e ⁻¹' m₂
                                              ⊆
                                              fun p : β × β => ( f p . 1 , f p . 2 ) ⁻¹' s
                                          :=
                                          calc
                                            _
                                                ⊆
                                                preimage
                                                  fun p : β × β => ( e p . 1 , e p . 2 ) interior t
                                              :=
                                              preimage_mono hm
                                            _ ⊆ preimage fun p : β × β => ( e p . 1 , e p . 2 ) t
                                                :=
                                                preimage_mono interior_subset
                                              _ ⊆ preimage fun p : β × β => ( f p . 1 , f p . 2 ) s
                                                :=
                                                ts
                                        have
                                          : f '' e ⁻¹' m₁ ×ˢ f '' e ⁻¹' m₂ ⊆ s
                                            :=
                                            calc
                                              f '' e ⁻¹' m₁ ×ˢ f '' e ⁻¹' m₂
                                                  =
                                                  fun p : β × β => ( f p . 1 , f p . 2 )
                                                    ''
                                                    e ⁻¹' m₁ ×ˢ e ⁻¹' m₂
                                                :=
                                                prod_image_image_eq
                                              _
                                                    ⊆
                                                    fun p : β × β => ( f p . 1 , f p . 2 )
                                                      ''
                                                      fun p : β × β => ( f p . 1 , f p . 2 ) ⁻¹' s
                                                  :=
                                                  monotone_image this
                                                _ ⊆ s := image_preimage_subset _ _
                                          have
                                            : ( a , b ) ∈ s := @ this ( a , b ) ⟨ ha₁ , hb₁ ⟩
                                            hs_comp
                                              <|
                                              show
                                                ( ψ x₁ , ψ x₂ ) ∈ compRel s compRel s s
                                                from ⟨ a , ha₂ , ⟨ b , this , hb₂ ⟩ ⟩
#align uniform_continuous_uniformly_extend uniform_continuous_uniformly_extend

omit h_f

variable [SeparatedSpace γ]

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `uniformly_extend_of_ind [])
      (Command.declSig
       [(Term.explicitBinder "(" [`b] [":" `β] [] ")")]
       (Term.typeSpec
        ":"
        («term_=_»
         (Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [(Term.app `e [`b])])
         "="
         (Term.app `f [`b]))))
      (Command.declValSimple
       ":="
       (Term.app
        `DenseInducing.extend_eq_at
        [(Term.hole "_") (Term.proj (Term.proj `h_f "." `Continuous) "." `ContinuousAt)])
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       `DenseInducing.extend_eq_at
       [(Term.hole "_") (Term.proj (Term.proj `h_f "." `Continuous) "." `ContinuousAt)])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.proj', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.proj', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.proj (Term.proj `h_f "." `Continuous) "." `ContinuousAt)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.proj `h_f "." `Continuous)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `h_f
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `DenseInducing.extend_eq_at
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_=_»
       (Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [(Term.app `e [`b])])
       "="
       (Term.app `f [`b]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `f [`b])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `b
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `f
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      (Term.app (Topology.UniformSpace.UniformEmbedding.termψ "ψ") [(Term.app `e [`b])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `e [`b])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `b
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `e
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `e [`b]) ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Topology.UniformSpace.UniformEmbedding.termψ', expected 'Topology.UniformSpace.UniformEmbedding.termψ._@.Topology.UniformSpace.UniformEmbedding._hyg.9'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  uniformly_extend_of_ind
  ( b : β ) : ψ e b = f b
  := DenseInducing.extend_eq_at _ h_f . Continuous . ContinuousAt
#align uniformly_extend_of_ind uniformly_extend_of_ind

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `uniformly_extend_unique [])
      (Command.declSig
       [(Term.implicitBinder "{" [`g] [":" (Term.arrow `α "→" `γ)] "}")
        (Term.explicitBinder
         "("
         [`hg]
         [":"
          (Term.forall
           "∀"
           [`b]
           []
           ","
           («term_=_» (Term.app `g [(Term.app `e [`b])]) "=" (Term.app `f [`b])))]
         []
         ")")
        (Term.explicitBinder "(" [`hc] [":" (Term.app `Continuous [`g])] [] ")")]
       (Term.typeSpec ":" («term_=_» (Topology.UniformSpace.UniformEmbedding.termψ "ψ") "=" `g)))
      (Command.declValSimple
       ":="
       (Term.app `DenseInducing.extend_unique [(Term.hole "_") `hg `hc])
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `DenseInducing.extend_unique [(Term.hole "_") `hg `hc])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hc
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `hg
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `DenseInducing.extend_unique
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_=_» (Topology.UniformSpace.UniformEmbedding.termψ "ψ") "=" `g)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `g
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      (Topology.UniformSpace.UniformEmbedding.termψ "ψ")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Topology.UniformSpace.UniformEmbedding.termψ', expected 'Topology.UniformSpace.UniformEmbedding.termψ._@.Topology.UniformSpace.UniformEmbedding._hyg.9'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  uniformly_extend_unique
  { g : α → γ } ( hg : ∀ b , g e b = f b ) ( hc : Continuous g ) : ψ = g
  := DenseInducing.extend_unique _ hg hc
#align uniformly_extend_unique uniformly_extend_unique

end UniformExtension

