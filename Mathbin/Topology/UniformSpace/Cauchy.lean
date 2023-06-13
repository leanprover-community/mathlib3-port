/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro

! This file was ported from Lean 3 source module topology.uniform_space.cauchy
! leanprover-community/mathlib commit 22131150f88a2d125713ffa0f4693e3355b1eb49
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Algebra.Constructions
import Mathbin.Topology.Bases
import Mathbin.Topology.UniformSpace.Basic

/-!
# Theory of Cauchy filters in uniform spaces. Complete uniform spaces. Totally bounded subsets.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


universe u v

open Filter TopologicalSpace Set Classical UniformSpace Function

open scoped Classical uniformity Topology Filter

variable {α : Type u} {β : Type v} [UniformSpace α]

#print Cauchy /-
/-- A filter `f` is Cauchy if for every entourage `r`, there exists an
  `s ∈ f` such that `s × s ⊆ r`. This is a generalization of Cauchy
  sequences, because if `a : ℕ → α` then the filter of sets containing
  cofinitely many of the `a n` is Cauchy iff `a` is a Cauchy sequence. -/
def Cauchy (f : Filter α) :=
  NeBot f ∧ f ×ᶠ f ≤ 𝓤 α
#align cauchy Cauchy
-/

#print IsComplete /-
/-- A set `s` is called *complete*, if any Cauchy filter `f` such that `s ∈ f`
has a limit in `s` (formally, it satisfies `f ≤ 𝓝 x` for some `x ∈ s`). -/
def IsComplete (s : Set α) :=
  ∀ f, Cauchy f → f ≤ 𝓟 s → ∃ x ∈ s, f ≤ 𝓝 x
#align is_complete IsComplete
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (x y «expr ∈ » t) -/
#print Filter.HasBasis.cauchy_iff /-
theorem Filter.HasBasis.cauchy_iff {ι} {p : ι → Prop} {s : ι → Set (α × α)} (h : (𝓤 α).HasBasis p s)
    {f : Filter α} :
    Cauchy f ↔ NeBot f ∧ ∀ i, p i → ∃ t ∈ f, ∀ (x) (_ : x ∈ t) (y) (_ : y ∈ t), (x, y) ∈ s i :=
  and_congr Iff.rfl <|
    (f.basis_sets.prod_self.le_basis_iffₓ h).trans <| by
      simp only [subset_def, Prod.forall, mem_prod_eq, and_imp, id, ball_mem_comm]
#align filter.has_basis.cauchy_iff Filter.HasBasis.cauchy_iff
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (x y «expr ∈ » t) -/
#print cauchy_iff' /-
theorem cauchy_iff' {f : Filter α} :
    Cauchy f ↔ NeBot f ∧ ∀ s ∈ 𝓤 α, ∃ t ∈ f, ∀ (x) (_ : x ∈ t) (y) (_ : y ∈ t), (x, y) ∈ s :=
  (𝓤 α).basis_sets.cauchy_iff
#align cauchy_iff' cauchy_iff'
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print cauchy_iff /-
theorem cauchy_iff {f : Filter α} : Cauchy f ↔ NeBot f ∧ ∀ s ∈ 𝓤 α, ∃ t ∈ f, t ×ˢ t ⊆ s :=
  cauchy_iff'.trans <| by
    simp only [subset_def, Prod.forall, mem_prod_eq, and_imp, id, ball_mem_comm]
#align cauchy_iff cauchy_iff
-/

#print Cauchy.ultrafilter_of /-
theorem Cauchy.ultrafilter_of {l : Filter α} (h : Cauchy l) :
    Cauchy (@Ultrafilter.of _ l h.1 : Filter α) :=
  by
  haveI := h.1
  have := Ultrafilter.of_le l
  exact ⟨Ultrafilter.neBot _, (Filter.prod_mono this this).trans h.2⟩
#align cauchy.ultrafilter_of Cauchy.ultrafilter_of
-/

#print cauchy_map_iff /-
theorem cauchy_map_iff {l : Filter β} {f : β → α} :
    Cauchy (l.map f) ↔ NeBot l ∧ Tendsto (fun p : β × β => (f p.1, f p.2)) (l ×ᶠ l) (𝓤 α) := by
  rw [Cauchy, map_ne_bot_iff, prod_map_map_eq, tendsto]
#align cauchy_map_iff cauchy_map_iff
-/

#print cauchy_map_iff' /-
theorem cauchy_map_iff' {l : Filter β} [hl : NeBot l] {f : β → α} :
    Cauchy (l.map f) ↔ Tendsto (fun p : β × β => (f p.1, f p.2)) (l ×ᶠ l) (𝓤 α) :=
  cauchy_map_iff.trans <| and_iff_right hl
#align cauchy_map_iff' cauchy_map_iff'
-/

#print Cauchy.mono /-
theorem Cauchy.mono {f g : Filter α} [hg : NeBot g] (h_c : Cauchy f) (h_le : g ≤ f) : Cauchy g :=
  ⟨hg, le_trans (Filter.prod_mono h_le h_le) h_c.right⟩
#align cauchy.mono Cauchy.mono
-/

#print Cauchy.mono' /-
theorem Cauchy.mono' {f g : Filter α} (h_c : Cauchy f) (hg : NeBot g) (h_le : g ≤ f) : Cauchy g :=
  h_c.mono h_le
#align cauchy.mono' Cauchy.mono'
-/

#print cauchy_nhds /-
theorem cauchy_nhds {a : α} : Cauchy (𝓝 a) :=
  ⟨nhds_neBot, nhds_prod_eq.symm.trans_le (nhds_le_uniformity a)⟩
#align cauchy_nhds cauchy_nhds
-/

#print cauchy_pure /-
theorem cauchy_pure {a : α} : Cauchy (pure a) :=
  cauchy_nhds.mono (pure_le_nhds a)
#align cauchy_pure cauchy_pure
-/

#print Filter.Tendsto.cauchy_map /-
theorem Filter.Tendsto.cauchy_map {l : Filter β} [NeBot l] {f : β → α} {a : α}
    (h : Tendsto f l (𝓝 a)) : Cauchy (map f l) :=
  cauchy_nhds.mono h
#align filter.tendsto.cauchy_map Filter.Tendsto.cauchy_map
-/

#print Cauchy.prod /-
theorem Cauchy.prod [UniformSpace β] {f : Filter α} {g : Filter β} (hf : Cauchy f) (hg : Cauchy g) :
    Cauchy (f ×ᶠ g) := by
  refine' ⟨hf.1.Prod hg.1, _⟩
  simp only [uniformity_prod, le_inf_iff, ← map_le_iff_le_comap, ← prod_map_map_eq]
  exact
    ⟨le_trans (prod_mono tendsto_fst tendsto_fst) hf.2,
      le_trans (prod_mono tendsto_snd tendsto_snd) hg.2⟩
#align cauchy.prod Cauchy.prod
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print le_nhds_of_cauchy_adhp_aux /-
/-- The common part of the proofs of `le_nhds_of_cauchy_adhp` and
`sequentially_complete.le_nhds_of_seq_tendsto_nhds`: if for any entourage `s`
one can choose a set `t ∈ f` of diameter `s` such that it contains a point `y`
with `(x, y) ∈ s`, then `f` converges to `x`. -/
theorem le_nhds_of_cauchy_adhp_aux {f : Filter α} {x : α}
    (adhs : ∀ s ∈ 𝓤 α, ∃ t ∈ f, t ×ˢ t ⊆ s ∧ ∃ y, (x, y) ∈ s ∧ y ∈ t) : f ≤ 𝓝 x :=
  by
  -- Consider a neighborhood `s` of `x`
  intro s hs
  -- Take an entourage twice smaller than `s`
  rcases comp_mem_uniformity_sets (mem_nhds_uniformity_iff_right.1 hs) with ⟨U, U_mem, hU⟩
  -- Take a set `t ∈ f`, `t × t ⊆ U`, and a point `y ∈ t` such that `(x, y) ∈ U`
  rcases adhs U U_mem with ⟨t, t_mem, ht, y, hxy, hy⟩
  apply mem_of_superset t_mem
  -- Given a point `z ∈ t`, we have `(x, y) ∈ U` and `(y, z) ∈ t × t ⊆ U`, hence `z ∈ s`
  exact fun z hz => hU (prod_mk_mem_compRel hxy (ht <| mk_mem_prod hy hz)) rfl
#align le_nhds_of_cauchy_adhp_aux le_nhds_of_cauchy_adhp_aux
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print le_nhds_of_cauchy_adhp /-
/-- If `x` is an adherent (cluster) point for a Cauchy filter `f`, then it is a limit point
for `f`. -/
theorem le_nhds_of_cauchy_adhp {f : Filter α} {x : α} (hf : Cauchy f) (adhs : ClusterPt x f) :
    f ≤ 𝓝 x :=
  le_nhds_of_cauchy_adhp_aux
    (by
      intro s hs
      obtain ⟨t, t_mem, ht⟩ : ∃ t ∈ f, t ×ˢ t ⊆ s
      exact (cauchy_iff.1 hf).2 s hs
      use t, t_mem, ht
      exact forall_mem_nonempty_iff_ne_bot.2 adhs _ (inter_mem_inf (mem_nhds_left x hs) t_mem))
#align le_nhds_of_cauchy_adhp le_nhds_of_cauchy_adhp
-/

#print le_nhds_iff_adhp_of_cauchy /-
theorem le_nhds_iff_adhp_of_cauchy {f : Filter α} {x : α} (hf : Cauchy f) :
    f ≤ 𝓝 x ↔ ClusterPt x f :=
  ⟨fun h => ClusterPt.of_le_nhds' h hf.1, le_nhds_of_cauchy_adhp hf⟩
#align le_nhds_iff_adhp_of_cauchy le_nhds_iff_adhp_of_cauchy
-/

#print Cauchy.map /-
theorem Cauchy.map [UniformSpace β] {f : Filter α} {m : α → β} (hf : Cauchy f)
    (hm : UniformContinuous m) : Cauchy (map m f) :=
  ⟨hf.1.map _,
    calc
      map m f ×ᶠ map m f = map (fun p : α × α => (m p.1, m p.2)) (f ×ᶠ f) := Filter.prod_map_map_eq
      _ ≤ map (fun p : α × α => (m p.1, m p.2)) (𝓤 α) := (map_mono hf.right)
      _ ≤ 𝓤 β := hm⟩
#align cauchy.map Cauchy.map
-/

#print Cauchy.comap /-
theorem Cauchy.comap [UniformSpace β] {f : Filter β} {m : α → β} (hf : Cauchy f)
    (hm : comap (fun p : α × α => (m p.1, m p.2)) (𝓤 β) ≤ 𝓤 α) [NeBot (comap m f)] :
    Cauchy (comap m f) :=
  ⟨‹_›,
    calc
      comap m f ×ᶠ comap m f = comap (fun p : α × α => (m p.1, m p.2)) (f ×ᶠ f) :=
        Filter.prod_comap_comap_eq
      _ ≤ comap (fun p : α × α => (m p.1, m p.2)) (𝓤 β) := (comap_mono hf.right)
      _ ≤ 𝓤 α := hm⟩
#align cauchy.comap Cauchy.comap
-/

#print Cauchy.comap' /-
theorem Cauchy.comap' [UniformSpace β] {f : Filter β} {m : α → β} (hf : Cauchy f)
    (hm : comap (fun p : α × α => (m p.1, m p.2)) (𝓤 β) ≤ 𝓤 α) (hb : NeBot (comap m f)) :
    Cauchy (comap m f) :=
  hf.comap hm
#align cauchy.comap' Cauchy.comap'
-/

#print CauchySeq /-
/-- Cauchy sequences. Usually defined on ℕ, but often it is also useful to say that a function
defined on ℝ is Cauchy at +∞ to deduce convergence. Therefore, we define it in a type class that
is general enough to cover both ℕ and ℝ, which are the main motivating examples. -/
def CauchySeq [SemilatticeSup β] (u : β → α) :=
  Cauchy (atTop.map u)
#align cauchy_seq CauchySeq
-/

#print CauchySeq.tendsto_uniformity /-
theorem CauchySeq.tendsto_uniformity [SemilatticeSup β] {u : β → α} (h : CauchySeq u) :
    Tendsto (Prod.map u u) atTop (𝓤 α) := by
  simpa only [tendsto, prod_map_map_eq', prod_at_top_at_top_eq] using h.right
#align cauchy_seq.tendsto_uniformity CauchySeq.tendsto_uniformity
-/

#print CauchySeq.nonempty /-
theorem CauchySeq.nonempty [SemilatticeSup β] {u : β → α} (hu : CauchySeq u) : Nonempty β :=
  @nonempty_of_neBot _ _ <| (map_neBot_iff _).1 hu.1
#align cauchy_seq.nonempty CauchySeq.nonempty
-/

#print CauchySeq.mem_entourage /-
theorem CauchySeq.mem_entourage {β : Type _} [SemilatticeSup β] {u : β → α} (h : CauchySeq u)
    {V : Set (α × α)} (hV : V ∈ 𝓤 α) : ∃ k₀, ∀ i j, k₀ ≤ i → k₀ ≤ j → (u i, u j) ∈ V :=
  by
  haveI := h.nonempty
  have := h.tendsto_uniformity; rw [← prod_at_top_at_top_eq] at this 
  simpa [maps_to] using at_top_basis.prod_self.tendsto_left_iff.1 this V hV
#align cauchy_seq.mem_entourage CauchySeq.mem_entourage
-/

#print Filter.Tendsto.cauchySeq /-
theorem Filter.Tendsto.cauchySeq [SemilatticeSup β] [Nonempty β] {f : β → α} {x}
    (hx : Tendsto f atTop (𝓝 x)) : CauchySeq f :=
  hx.cauchy_map
#align filter.tendsto.cauchy_seq Filter.Tendsto.cauchySeq
-/

#print cauchySeq_const /-
theorem cauchySeq_const [SemilatticeSup β] [Nonempty β] (x : α) : CauchySeq fun n : β => x :=
  tendsto_const_nhds.CauchySeq
#align cauchy_seq_const cauchySeq_const
-/

#print cauchySeq_iff_tendsto /-
theorem cauchySeq_iff_tendsto [Nonempty β] [SemilatticeSup β] {u : β → α} :
    CauchySeq u ↔ Tendsto (Prod.map u u) atTop (𝓤 α) :=
  cauchy_map_iff'.trans <| by simp only [prod_at_top_at_top_eq, Prod.map_def]
#align cauchy_seq_iff_tendsto cauchySeq_iff_tendsto
-/

#print CauchySeq.comp_tendsto /-
theorem CauchySeq.comp_tendsto {γ} [SemilatticeSup β] [SemilatticeSup γ] [Nonempty γ] {f : β → α}
    (hf : CauchySeq f) {g : γ → β} (hg : Tendsto g atTop atTop) : CauchySeq (f ∘ g) :=
  cauchySeq_iff_tendsto.2 <| hf.tendsto_uniformity.comp (hg.prod_atTop hg)
#align cauchy_seq.comp_tendsto CauchySeq.comp_tendsto
-/

#print CauchySeq.comp_injective /-
theorem CauchySeq.comp_injective [SemilatticeSup β] [NoMaxOrder β] [Nonempty β] {u : ℕ → α}
    (hu : CauchySeq u) {f : β → ℕ} (hf : Injective f) : CauchySeq (u ∘ f) :=
  hu.comp_tendsto <| Nat.cofinite_eq_atTop ▸ hf.tendsto_cofinite.mono_left atTop_le_cofinite
#align cauchy_seq.comp_injective CauchySeq.comp_injective
-/

#print Function.Bijective.cauchySeq_comp_iff /-
theorem Function.Bijective.cauchySeq_comp_iff {f : ℕ → ℕ} (hf : Bijective f) (u : ℕ → α) :
    CauchySeq (u ∘ f) ↔ CauchySeq u :=
  by
  refine' ⟨fun H => _, fun H => H.comp_injective hf.injective⟩
  lift f to ℕ ≃ ℕ using hf
  simpa only [(· ∘ ·), f.apply_symm_apply] using H.comp_injective f.symm.injective
#align function.bijective.cauchy_seq_comp_iff Function.Bijective.cauchySeq_comp_iff
-/

#print CauchySeq.subseq_subseq_mem /-
theorem CauchySeq.subseq_subseq_mem {V : ℕ → Set (α × α)} (hV : ∀ n, V n ∈ 𝓤 α) {u : ℕ → α}
    (hu : CauchySeq u) {f g : ℕ → ℕ} (hf : Tendsto f atTop atTop) (hg : Tendsto g atTop atTop) :
    ∃ φ : ℕ → ℕ, StrictMono φ ∧ ∀ n, ((u ∘ f ∘ φ) n, (u ∘ g ∘ φ) n) ∈ V n :=
  by
  rw [cauchySeq_iff_tendsto] at hu 
  exact ((hu.comp <| hf.prod_at_top hg).comp tendsto_at_top_diagonal).subseq_mem hV
#align cauchy_seq.subseq_subseq_mem CauchySeq.subseq_subseq_mem
-/

#print cauchySeq_iff' /-
theorem cauchySeq_iff' {u : ℕ → α} :
    CauchySeq u ↔ ∀ V ∈ 𝓤 α, ∀ᶠ k in atTop, k ∈ Prod.map u u ⁻¹' V := by
  simpa only [cauchySeq_iff_tendsto]
#align cauchy_seq_iff' cauchySeq_iff'
-/

#print cauchySeq_iff /-
theorem cauchySeq_iff {u : ℕ → α} :
    CauchySeq u ↔ ∀ V ∈ 𝓤 α, ∃ N, ∀ k ≥ N, ∀ l ≥ N, (u k, u l) ∈ V := by
  simp [cauchySeq_iff', Filter.eventually_atTop_prod_self', Prod_map]
#align cauchy_seq_iff cauchySeq_iff
-/

#print CauchySeq.prod_map /-
theorem CauchySeq.prod_map {γ δ} [UniformSpace β] [SemilatticeSup γ] [SemilatticeSup δ] {u : γ → α}
    {v : δ → β} (hu : CauchySeq u) (hv : CauchySeq v) : CauchySeq (Prod.map u v) := by
  simpa only [CauchySeq, prod_map_map_eq', prod_at_top_at_top_eq] using hu.prod hv
#align cauchy_seq.prod_map CauchySeq.prod_map
-/

#print CauchySeq.prod /-
theorem CauchySeq.prod {γ} [UniformSpace β] [SemilatticeSup γ] {u : γ → α} {v : γ → β}
    (hu : CauchySeq u) (hv : CauchySeq v) : CauchySeq fun x => (u x, v x) :=
  haveI := hu.nonempty
  (hu.prod hv).mono (tendsto.prod_mk le_rfl le_rfl)
#align cauchy_seq.prod CauchySeq.prod
-/

#print CauchySeq.eventually_eventually /-
theorem CauchySeq.eventually_eventually [SemilatticeSup β] {u : β → α} (hu : CauchySeq u)
    {V : Set (α × α)} (hV : V ∈ 𝓤 α) : ∀ᶠ k in atTop, ∀ᶠ l in atTop, (u k, u l) ∈ V :=
  eventually_atTop_curry <| hu.tendsto_uniformity hV
#align cauchy_seq.eventually_eventually CauchySeq.eventually_eventually
-/

#print UniformContinuous.comp_cauchySeq /-
theorem UniformContinuous.comp_cauchySeq {γ} [UniformSpace β] [SemilatticeSup γ] {f : α → β}
    (hf : UniformContinuous f) {u : γ → α} (hu : CauchySeq u) : CauchySeq (f ∘ u) :=
  hu.map hf
#align uniform_continuous.comp_cauchy_seq UniformContinuous.comp_cauchySeq
-/

#print CauchySeq.subseq_mem /-
theorem CauchySeq.subseq_mem {V : ℕ → Set (α × α)} (hV : ∀ n, V n ∈ 𝓤 α) {u : ℕ → α}
    (hu : CauchySeq u) : ∃ φ : ℕ → ℕ, StrictMono φ ∧ ∀ n, (u <| φ (n + 1), u <| φ n) ∈ V n :=
  by
  have : ∀ n, ∃ N, ∀ k ≥ N, ∀ l ≥ k, (u l, u k) ∈ V n :=
    by
    intro n
    rw [cauchySeq_iff] at hu 
    rcases hu _ (hV n) with ⟨N, H⟩
    exact ⟨N, fun k hk l hl => H _ (le_trans hk hl) _ hk⟩
  obtain ⟨φ : ℕ → ℕ, φ_extr : StrictMono φ, hφ : ∀ n, ∀ l ≥ φ n, (u l, u <| φ n) ∈ V n⟩ :=
    extraction_forall_of_eventually' this
  exact ⟨φ, φ_extr, fun n => hφ _ _ (φ_extr <| lt_add_one n).le⟩
#align cauchy_seq.subseq_mem CauchySeq.subseq_mem
-/

#print Filter.Tendsto.subseq_mem_entourage /-
theorem Filter.Tendsto.subseq_mem_entourage {V : ℕ → Set (α × α)} (hV : ∀ n, V n ∈ 𝓤 α) {u : ℕ → α}
    {a : α} (hu : Tendsto u atTop (𝓝 a)) :
    ∃ φ : ℕ → ℕ, StrictMono φ ∧ (u (φ 0), a) ∈ V 0 ∧ ∀ n, (u <| φ (n + 1), u <| φ n) ∈ V (n + 1) :=
  by
  rcases mem_at_top_sets.1 (hu (ball_mem_nhds a (symm_le_uniformity <| hV 0))) with ⟨n, hn⟩
  rcases(hu.comp (tendsto_add_at_top_nat n)).CauchySeq.subseq_mem fun n => hV (n + 1) with
    ⟨φ, φ_mono, hφV⟩
  exact ⟨fun k => φ k + n, φ_mono.add_const _, hn _ le_add_self, hφV⟩
#align filter.tendsto.subseq_mem_entourage Filter.Tendsto.subseq_mem_entourage
-/

#print tendsto_nhds_of_cauchySeq_of_subseq /-
/-- If a Cauchy sequence has a convergent subsequence, then it converges. -/
theorem tendsto_nhds_of_cauchySeq_of_subseq [SemilatticeSup β] {u : β → α} (hu : CauchySeq u)
    {ι : Type _} {f : ι → β} {p : Filter ι} [NeBot p] (hf : Tendsto f p atTop) {a : α}
    (ha : Tendsto (u ∘ f) p (𝓝 a)) : Tendsto u atTop (𝓝 a) :=
  le_nhds_of_cauchy_adhp hu (mapClusterPt_of_comp hf ha)
#align tendsto_nhds_of_cauchy_seq_of_subseq tendsto_nhds_of_cauchySeq_of_subseq
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (m n «expr ≥ » N) -/
#print Filter.HasBasis.cauchySeq_iff /-
-- see Note [nolint_ge]
@[nolint ge_or_gt]
theorem Filter.HasBasis.cauchySeq_iff {γ} [Nonempty β] [SemilatticeSup β] {u : β → α} {p : γ → Prop}
    {s : γ → Set (α × α)} (h : (𝓤 α).HasBasis p s) :
    CauchySeq u ↔ ∀ i, p i → ∃ N, ∀ (m) (_ : m ≥ N) (n) (_ : n ≥ N), (u m, u n) ∈ s i :=
  by
  rw [cauchySeq_iff_tendsto, ← prod_at_top_at_top_eq]
  refine' (at_top_basis.prod_self.tendsto_iff h).trans _
  simp only [exists_prop, true_and_iff, maps_to, preimage, subset_def, Prod.forall, mem_prod_eq,
    mem_set_of_eq, mem_Ici, and_imp, Prod.map, ge_iff_le, @forall_swap (_ ≤ _) β]
#align filter.has_basis.cauchy_seq_iff Filter.HasBasis.cauchySeq_iff
-/

#print Filter.HasBasis.cauchySeq_iff' /-
theorem Filter.HasBasis.cauchySeq_iff' {γ} [Nonempty β] [SemilatticeSup β] {u : β → α}
    {p : γ → Prop} {s : γ → Set (α × α)} (H : (𝓤 α).HasBasis p s) :
    CauchySeq u ↔ ∀ i, p i → ∃ N, ∀ n ≥ N, (u n, u N) ∈ s i :=
  by
  refine' H.cauchy_seq_iff.trans ⟨fun h i hi => _, fun h i hi => _⟩
  · exact (h i hi).imp fun N hN n hn => hN n hn N le_rfl
  · rcases comp_symm_of_uniformity (H.mem_of_mem hi) with ⟨t, ht, ht', hts⟩
    rcases H.mem_iff.1 ht with ⟨j, hj, hjt⟩
    refine' (h j hj).imp fun N hN m hm n hn => hts ⟨u N, hjt _, ht' <| hjt _⟩
    · exact hN m hm
    · exact hN n hn
#align filter.has_basis.cauchy_seq_iff' Filter.HasBasis.cauchySeq_iff'
-/

#print cauchySeq_of_controlled /-
theorem cauchySeq_of_controlled [SemilatticeSup β] [Nonempty β] (U : β → Set (α × α))
    (hU : ∀ s ∈ 𝓤 α, ∃ n, U n ⊆ s) {f : β → α}
    (hf : ∀ {N m n : β}, N ≤ m → N ≤ n → (f m, f n) ∈ U N) : CauchySeq f :=
  cauchySeq_iff_tendsto.2
    (by
      intro s hs
      rw [mem_map, mem_at_top_sets]
      cases' hU s hs with N hN
      refine' ⟨(N, N), fun mn hmn => _⟩
      cases' mn with m n
      exact hN (hf hmn.1 hmn.2))
#align cauchy_seq_of_controlled cauchySeq_of_controlled
-/

#print isComplete_iff_clusterPt /-
theorem isComplete_iff_clusterPt {s : Set α} :
    IsComplete s ↔ ∀ l, Cauchy l → l ≤ 𝓟 s → ∃ x ∈ s, ClusterPt x l :=
  forall₃_congr fun l hl hls => exists₂_congr fun x hx => le_nhds_iff_adhp_of_cauchy hl
#align is_complete_iff_cluster_pt isComplete_iff_clusterPt
-/

#print isComplete_iff_ultrafilter /-
theorem isComplete_iff_ultrafilter {s : Set α} :
    IsComplete s ↔ ∀ l : Ultrafilter α, Cauchy (l : Filter α) → ↑l ≤ 𝓟 s → ∃ x ∈ s, ↑l ≤ 𝓝 x :=
  by
  refine' ⟨fun h l => h l, fun H => isComplete_iff_clusterPt.2 fun l hl hls => _⟩
  haveI := hl.1
  rcases H (Ultrafilter.of l) hl.ultrafilter_of ((Ultrafilter.of_le l).trans hls) with ⟨x, hxs, hxl⟩
  exact ⟨x, hxs, (ClusterPt.of_le_nhds hxl).mono (Ultrafilter.of_le l)⟩
#align is_complete_iff_ultrafilter isComplete_iff_ultrafilter
-/

#print isComplete_iff_ultrafilter' /-
theorem isComplete_iff_ultrafilter' {s : Set α} :
    IsComplete s ↔ ∀ l : Ultrafilter α, Cauchy (l : Filter α) → s ∈ l → ∃ x ∈ s, ↑l ≤ 𝓝 x :=
  isComplete_iff_ultrafilter.trans <| by simp only [le_principal_iff, Ultrafilter.mem_coe]
#align is_complete_iff_ultrafilter' isComplete_iff_ultrafilter'
-/

#print IsComplete.union /-
protected theorem IsComplete.union {s t : Set α} (hs : IsComplete s) (ht : IsComplete t) :
    IsComplete (s ∪ t) :=
  by
  simp only [isComplete_iff_ultrafilter', Ultrafilter.union_mem_iff, or_imp] at *
  exact fun l hl =>
    ⟨fun hsl => (hs l hl hsl).imp fun x hx => ⟨Or.inl hx.fst, hx.snd⟩, fun htl =>
      (ht l hl htl).imp fun x hx => ⟨Or.inr hx.fst, hx.snd⟩⟩
#align is_complete.union IsComplete.union
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (t «expr ⊆ » S) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print isComplete_iUnion_separated /-
theorem isComplete_iUnion_separated {ι : Sort _} {s : ι → Set α} (hs : ∀ i, IsComplete (s i))
    {U : Set (α × α)} (hU : U ∈ 𝓤 α) (hd : ∀ (i j : ι), ∀ x ∈ s i, ∀ y ∈ s j, (x, y) ∈ U → i = j) :
    IsComplete (⋃ i, s i) := by
  set S := ⋃ i, s i
  intro l hl hls
  rw [le_principal_iff] at hls 
  cases' cauchy_iff.1 hl with hl_ne hl'
  obtain ⟨t, htS, htl, htU⟩ : ∃ (t : _) (_ : t ⊆ S), t ∈ l ∧ t ×ˢ t ⊆ U :=
    by
    rcases hl' U hU with ⟨t, htl, htU⟩
    exact
      ⟨t ∩ S, inter_subset_right _ _, inter_mem htl hls,
        (Set.prod_mono (inter_subset_left _ _) (inter_subset_left _ _)).trans htU⟩
  obtain ⟨i, hi⟩ : ∃ i, t ⊆ s i :=
    by
    rcases Filter.nonempty_of_mem htl with ⟨x, hx⟩
    rcases mem_Union.1 (htS hx) with ⟨i, hi⟩
    refine' ⟨i, fun y hy => _⟩
    rcases mem_Union.1 (htS hy) with ⟨j, hj⟩
    convert hj; exact hd i j x hi y hj (htU <| mk_mem_prod hx hy)
  rcases hs i l hl (le_principal_iff.2 <| mem_of_superset htl hi) with ⟨x, hxs, hlx⟩
  exact ⟨x, mem_Union.2 ⟨i, hxs⟩, hlx⟩
#align is_complete_Union_separated isComplete_iUnion_separated
-/

#print CompleteSpace /-
/-- A complete space is defined here using uniformities. A uniform space
  is complete if every Cauchy filter converges. -/
class CompleteSpace (α : Type u) [UniformSpace α] : Prop where
  complete : ∀ {f : Filter α}, Cauchy f → ∃ x, f ≤ 𝓝 x
#align complete_space CompleteSpace
-/

#print complete_univ /-
theorem complete_univ {α : Type u} [UniformSpace α] [CompleteSpace α] : IsComplete (univ : Set α) :=
  by
  intro f hf _
  rcases CompleteSpace.complete hf with ⟨x, hx⟩
  exact ⟨x, mem_univ x, hx⟩
#align complete_univ complete_univ
-/

#print CompleteSpace.prod /-
instance CompleteSpace.prod [UniformSpace β] [CompleteSpace α] [CompleteSpace β] :
    CompleteSpace (α × β)
    where complete f hf :=
    let ⟨x1, hx1⟩ := CompleteSpace.complete <| hf.map uniformContinuous_fst
    let ⟨x2, hx2⟩ := CompleteSpace.complete <| hf.map uniformContinuous_snd
    ⟨(x1, x2), by
      rw [nhds_prod_eq, Filter.prod_def] <;>
        exact
          Filter.le_lift.2 fun s hs => Filter.le_lift'.2 fun t ht => inter_mem (hx1 hs) (hx2 ht)⟩
#align complete_space.prod CompleteSpace.prod
-/

#print CompleteSpace.mulOpposite /-
@[to_additive]
instance CompleteSpace.mulOpposite [CompleteSpace α] : CompleteSpace αᵐᵒᵖ
    where complete f hf :=
    MulOpposite.op_surjective.exists.mpr <|
      let ⟨x, hx⟩ := CompleteSpace.complete (hf.map MulOpposite.uniformContinuous_unop)
      ⟨x, (map_le_iff_le_comap.mp hx).trans_eq <| MulOpposite.comap_unop_nhds _⟩
#align complete_space.mul_opposite CompleteSpace.mulOpposite
#align complete_space.add_opposite CompleteSpace.addOpposite
-/

#print completeSpace_of_isComplete_univ /-
/-- If `univ` is complete, the space is a complete space -/
theorem completeSpace_of_isComplete_univ (h : IsComplete (univ : Set α)) : CompleteSpace α :=
  ⟨fun f hf =>
    let ⟨x, _, hx⟩ := h f hf ((@principal_univ α).symm ▸ le_top)
    ⟨x, hx⟩⟩
#align complete_space_of_is_complete_univ completeSpace_of_isComplete_univ
-/

#print completeSpace_iff_isComplete_univ /-
theorem completeSpace_iff_isComplete_univ : CompleteSpace α ↔ IsComplete (univ : Set α) :=
  ⟨@complete_univ α _, completeSpace_of_isComplete_univ⟩
#align complete_space_iff_is_complete_univ completeSpace_iff_isComplete_univ
-/

#print completeSpace_iff_ultrafilter /-
theorem completeSpace_iff_ultrafilter :
    CompleteSpace α ↔ ∀ l : Ultrafilter α, Cauchy (l : Filter α) → ∃ x : α, ↑l ≤ 𝓝 x := by
  simp [completeSpace_iff_isComplete_univ, isComplete_iff_ultrafilter]
#align complete_space_iff_ultrafilter completeSpace_iff_ultrafilter
-/

#print cauchy_iff_exists_le_nhds /-
theorem cauchy_iff_exists_le_nhds [CompleteSpace α] {l : Filter α} [NeBot l] :
    Cauchy l ↔ ∃ x, l ≤ 𝓝 x :=
  ⟨CompleteSpace.complete, fun ⟨x, hx⟩ => cauchy_nhds.mono hx⟩
#align cauchy_iff_exists_le_nhds cauchy_iff_exists_le_nhds
-/

#print cauchy_map_iff_exists_tendsto /-
theorem cauchy_map_iff_exists_tendsto [CompleteSpace α] {l : Filter β} {f : β → α} [NeBot l] :
    Cauchy (l.map f) ↔ ∃ x, Tendsto f l (𝓝 x) :=
  cauchy_iff_exists_le_nhds
#align cauchy_map_iff_exists_tendsto cauchy_map_iff_exists_tendsto
-/

#print cauchySeq_tendsto_of_complete /-
/-- A Cauchy sequence in a complete space converges -/
theorem cauchySeq_tendsto_of_complete [SemilatticeSup β] [CompleteSpace α] {u : β → α}
    (H : CauchySeq u) : ∃ x, Tendsto u atTop (𝓝 x) :=
  CompleteSpace.complete H
#align cauchy_seq_tendsto_of_complete cauchySeq_tendsto_of_complete
-/

#print cauchySeq_tendsto_of_isComplete /-
/-- If `K` is a complete subset, then any cauchy sequence in `K` converges to a point in `K` -/
theorem cauchySeq_tendsto_of_isComplete [SemilatticeSup β] {K : Set α} (h₁ : IsComplete K)
    {u : β → α} (h₂ : ∀ n, u n ∈ K) (h₃ : CauchySeq u) : ∃ v ∈ K, Tendsto u atTop (𝓝 v) :=
  h₁ _ h₃ <|
    le_principal_iff.2 <|
      mem_map_iff_exists_image.2
        ⟨univ, univ_mem, by simp only [image_univ]; rintro _ ⟨n, rfl⟩; exact h₂ n⟩
#align cauchy_seq_tendsto_of_is_complete cauchySeq_tendsto_of_isComplete
-/

#print Cauchy.le_nhds_lim /-
theorem Cauchy.le_nhds_lim [CompleteSpace α] [Nonempty α] {f : Filter α} (hf : Cauchy f) :
    f ≤ 𝓝 (lim f) :=
  le_nhds_lim (CompleteSpace.complete hf)
#align cauchy.le_nhds_Lim Cauchy.le_nhds_lim
-/

#print CauchySeq.tendsto_limUnder /-
theorem CauchySeq.tendsto_limUnder [SemilatticeSup β] [CompleteSpace α] [Nonempty α] {u : β → α}
    (h : CauchySeq u) : Tendsto u atTop (𝓝 <| limUnder atTop u) :=
  h.le_nhds_lim
#align cauchy_seq.tendsto_lim CauchySeq.tendsto_limUnder
-/

#print IsClosed.isComplete /-
theorem IsClosed.isComplete [CompleteSpace α] {s : Set α} (h : IsClosed s) : IsComplete s :=
  fun f cf fs =>
  let ⟨x, hx⟩ := CompleteSpace.complete cf
  ⟨x, isClosed_iff_clusterPt.mp h x (cf.left.mono (le_inf hx fs)), hx⟩
#align is_closed.is_complete IsClosed.isComplete
-/

#print TotallyBounded /-
/-- A set `s` is totally bounded if for every entourage `d` there is a finite
  set of points `t` such that every element of `s` is `d`-near to some element of `t`. -/
def TotallyBounded (s : Set α) : Prop :=
  ∀ d ∈ 𝓤 α, ∃ t : Set α, t.Finite ∧ s ⊆ ⋃ y ∈ t, {x | (x, y) ∈ d}
#align totally_bounded TotallyBounded
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (t «expr ⊆ » s) -/
#print TotallyBounded.exists_subset /-
theorem TotallyBounded.exists_subset {s : Set α} (hs : TotallyBounded s) {U : Set (α × α)}
    (hU : U ∈ 𝓤 α) : ∃ (t : _) (_ : t ⊆ s), Set.Finite t ∧ s ⊆ ⋃ y ∈ t, {x | (x, y) ∈ U} :=
  by
  rcases comp_symm_of_uniformity hU with ⟨r, hr, rs, rU⟩
  rcases hs r hr with ⟨k, fk, ks⟩
  let u := k ∩ {y | ∃ x ∈ s, (x, y) ∈ r}
  choose hk f hfs hfr using fun x : u => x.coe_prop
  refine' ⟨range f, _, _, _⟩
  · exact range_subset_iff.2 hfs
  · haveI : Fintype u := (fk.inter_of_left _).Fintype
    exact finite_range f
  · intro x xs
    obtain ⟨y, hy, xy⟩ : ∃ y ∈ k, (x, y) ∈ r; exact mem_Union₂.1 (ks xs)
    rw [bUnion_range, mem_Union]
    set z : ↥u := ⟨y, hy, ⟨x, xs, xy⟩⟩
    exact ⟨z, rU <| mem_compRel.2 ⟨y, xy, rs (hfr z)⟩⟩
#align totally_bounded.exists_subset TotallyBounded.exists_subset
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (t «expr ⊆ » s) -/
#print totallyBounded_iff_subset /-
theorem totallyBounded_iff_subset {s : Set α} :
    TotallyBounded s ↔
      ∀ d ∈ 𝓤 α, ∃ (t : _) (_ : t ⊆ s), Set.Finite t ∧ s ⊆ ⋃ y ∈ t, {x | (x, y) ∈ d} :=
  ⟨fun H d hd => H.exists_subset hd, fun H d hd =>
    let ⟨t, _, ht⟩ := H d hd
    ⟨t, ht⟩⟩
#align totally_bounded_iff_subset totallyBounded_iff_subset
-/

#print Filter.HasBasis.totallyBounded_iff /-
theorem Filter.HasBasis.totallyBounded_iff {ι} {p : ι → Prop} {U : ι → Set (α × α)}
    (H : (𝓤 α).HasBasis p U) {s : Set α} :
    TotallyBounded s ↔ ∀ i, p i → ∃ t : Set α, Set.Finite t ∧ s ⊆ ⋃ y ∈ t, {x | (x, y) ∈ U i} :=
  H.forall_iff fun U V hUV h =>
    h.imp fun t ht => ⟨ht.1, ht.2.trans <| iUnion₂_mono fun x hx y hy => hUV hy⟩
#align filter.has_basis.totally_bounded_iff Filter.HasBasis.totallyBounded_iff
-/

#print totallyBounded_of_forall_symm /-
theorem totallyBounded_of_forall_symm {s : Set α}
    (h : ∀ V ∈ 𝓤 α, SymmetricRel V → ∃ t : Set α, Set.Finite t ∧ s ⊆ ⋃ y ∈ t, ball y V) :
    TotallyBounded s :=
  UniformSpace.hasBasis_symmetric.totallyBounded_iff.2 fun V hV => by
    simpa only [ball_eq_of_symmetry hV.2] using h V hV.1 hV.2
#align totally_bounded_of_forall_symm totallyBounded_of_forall_symm
-/

#print totallyBounded_subset /-
theorem totallyBounded_subset {s₁ s₂ : Set α} (hs : s₁ ⊆ s₂) (h : TotallyBounded s₂) :
    TotallyBounded s₁ := fun d hd =>
  let ⟨t, ht₁, ht₂⟩ := h d hd
  ⟨t, ht₁, Subset.trans hs ht₂⟩
#align totally_bounded_subset totallyBounded_subset
-/

#print totallyBounded_empty /-
theorem totallyBounded_empty : TotallyBounded (∅ : Set α) := fun d hd =>
  ⟨∅, finite_empty, empty_subset _⟩
#align totally_bounded_empty totallyBounded_empty
-/

#print TotallyBounded.closure /-
/-- The closure of a totally bounded set is totally bounded. -/
theorem TotallyBounded.closure {s : Set α} (h : TotallyBounded s) : TotallyBounded (closure s) :=
  uniformity_hasBasis_closed.totallyBounded_iff.2 fun V hV =>
    let ⟨t, htf, hst⟩ := h V hV.1
    ⟨t, htf,
      closure_minimal hst <|
        isClosed_biUnion htf fun y hy => hV.2.Preimage (continuous_id.prod_mk continuous_const)⟩
#align totally_bounded.closure TotallyBounded.closure
-/

#print TotallyBounded.image /-
/-- The image of a totally bounded set under a uniformly continuous map is totally bounded. -/
theorem TotallyBounded.image [UniformSpace β] {f : α → β} {s : Set α} (hs : TotallyBounded s)
    (hf : UniformContinuous f) : TotallyBounded (f '' s) := fun t ht =>
  have : {p : α × α | (f p.1, f p.2) ∈ t} ∈ 𝓤 α := hf ht
  let ⟨c, hfc, hct⟩ := hs _ this
  ⟨f '' c, hfc.image f, by
    simp [image_subset_iff]
    simp [subset_def] at hct 
    intro x hx; simp
    exact hct x hx⟩
#align totally_bounded.image TotallyBounded.image
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Ultrafilter.cauchy_of_totallyBounded /-
theorem Ultrafilter.cauchy_of_totallyBounded {s : Set α} (f : Ultrafilter α) (hs : TotallyBounded s)
    (h : ↑f ≤ 𝓟 s) : Cauchy (f : Filter α) :=
  ⟨f.ne_bot', fun t ht =>
    let ⟨t', ht'₁, ht'_symm, ht'_t⟩ := comp_symm_of_uniformity ht
    let ⟨i, hi, hs_union⟩ := hs t' ht'₁
    have : (⋃ y ∈ i, {x | (x, y) ∈ t'}) ∈ f := mem_of_superset (le_principal_iff.mp h) hs_union
    have : ∃ y ∈ i, {x | (x, y) ∈ t'} ∈ f := (Ultrafilter.finite_biUnion_mem_iff hi).1 this
    let ⟨y, hy, hif⟩ := this
    have : {x | (x, y) ∈ t'} ×ˢ {x | (x, y) ∈ t'} ⊆ compRel t' t' :=
      fun ⟨x₁, x₂⟩ ⟨(h₁ : (x₁, y) ∈ t'), (h₂ : (x₂, y) ∈ t')⟩ => ⟨y, h₁, ht'_symm h₂⟩
    mem_of_superset (prod_mem_prod hif hif) (Subset.trans this ht'_t)⟩
#align ultrafilter.cauchy_of_totally_bounded Ultrafilter.cauchy_of_totallyBounded
-/

#print totallyBounded_iff_filter /-
theorem totallyBounded_iff_filter {s : Set α} :
    TotallyBounded s ↔ ∀ f, NeBot f → f ≤ 𝓟 s → ∃ c ≤ f, Cauchy c :=
  by
  constructor
  · intro H f hf hfs
    exact
      ⟨Ultrafilter.of f, Ultrafilter.of_le f,
        (Ultrafilter.of f).cauchy_of_totallyBounded H ((Ultrafilter.of_le f).trans hfs)⟩
  · intro H d hd
    contrapose! H with hd_cover
    set f := ⨅ t : Finset α, 𝓟 (s \ ⋃ y ∈ t, {x | (x, y) ∈ d})
    have : ne_bot f := by
      refine' infi_ne_bot_of_directed' (directed_of_sup _) _
      · intro t₁ t₂ h
        exact principal_mono.2 (diff_subset_diff_right <| bUnion_subset_bUnion_left h)
      · intro t
        simpa [nonempty_diff] using hd_cover t t.finite_to_set
    have : f ≤ 𝓟 s := iInf_le_of_le ∅ (by simp)
    refine' ⟨f, ‹_›, ‹_›, fun c hcf hc => _⟩
    rcases mem_prod_same_iff.1 (hc.2 hd) with ⟨m, hm, hmd⟩
    have : m ∩ s ∈ c := inter_mem hm (le_principal_iff.mp (hcf.trans ‹_›))
    rcases hc.1.nonempty_of_mem this with ⟨y, hym, hys⟩
    set ys := ⋃ y' ∈ ({y} : Finset α), {x | (x, y') ∈ d}
    have : m ⊆ ys := by simpa [ys] using fun x hx => hmd (mk_mem_prod hx hym)
    have : c ≤ 𝓟 (s \ ys) := hcf.trans (iInf_le_of_le {y} le_rfl)
    refine' hc.1.Ne (empty_mem_iff_bot.mp _)
    filter_upwards [le_principal_iff.1 this, hm]
    refine' fun x hx hxm => hx.2 _
    simpa [ys] using hmd (mk_mem_prod hxm hym)
#align totally_bounded_iff_filter totallyBounded_iff_filter
-/

#print totallyBounded_iff_ultrafilter /-
theorem totallyBounded_iff_ultrafilter {s : Set α} :
    TotallyBounded s ↔ ∀ f : Ultrafilter α, ↑f ≤ 𝓟 s → Cauchy (f : Filter α) :=
  by
  refine' ⟨fun hs f => f.cauchy_of_totallyBounded hs, fun H => totallyBounded_iff_filter.2 _⟩
  intro f hf hfs
  exact ⟨Ultrafilter.of f, Ultrafilter.of_le f, H _ ((Ultrafilter.of_le f).trans hfs)⟩
#align totally_bounded_iff_ultrafilter totallyBounded_iff_ultrafilter
-/

#print isCompact_iff_totallyBounded_isComplete /-
theorem isCompact_iff_totallyBounded_isComplete {s : Set α} :
    IsCompact s ↔ TotallyBounded s ∧ IsComplete s :=
  ⟨fun hs =>
    ⟨totallyBounded_iff_ultrafilter.2 fun f hf =>
        let ⟨x, xs, fx⟩ := isCompact_iff_ultrafilter_le_nhds.1 hs f hf
        cauchy_nhds.mono fx,
      fun f fc fs =>
      let ⟨a, as, fa⟩ := @hs f fc.1 fs
      ⟨a, as, le_nhds_of_cauchy_adhp fc fa⟩⟩,
    fun ⟨ht, hc⟩ =>
    isCompact_iff_ultrafilter_le_nhds.2 fun f hf =>
      hc _ (totallyBounded_iff_ultrafilter.1 ht f hf) hf⟩
#align is_compact_iff_totally_bounded_is_complete isCompact_iff_totallyBounded_isComplete
-/

#print IsCompact.totallyBounded /-
protected theorem IsCompact.totallyBounded {s : Set α} (h : IsCompact s) : TotallyBounded s :=
  (isCompact_iff_totallyBounded_isComplete.1 h).1
#align is_compact.totally_bounded IsCompact.totallyBounded
-/

#print IsCompact.isComplete /-
protected theorem IsCompact.isComplete {s : Set α} (h : IsCompact s) : IsComplete s :=
  (isCompact_iff_totallyBounded_isComplete.1 h).2
#align is_compact.is_complete IsCompact.isComplete
-/

#print complete_of_compact /-
-- see Note [lower instance priority]
instance (priority := 100) complete_of_compact {α : Type u} [UniformSpace α] [CompactSpace α] :
    CompleteSpace α :=
  ⟨fun f hf => by simpa using (isCompact_iff_totallyBounded_isComplete.1 isCompact_univ).2 f hf⟩
#align complete_of_compact complete_of_compact
-/

#print isCompact_of_totallyBounded_isClosed /-
theorem isCompact_of_totallyBounded_isClosed [CompleteSpace α] {s : Set α} (ht : TotallyBounded s)
    (hc : IsClosed s) : IsCompact s :=
  (@isCompact_iff_totallyBounded_isComplete α _ s).2 ⟨ht, hc.IsComplete⟩
#align is_compact_of_totally_bounded_is_closed isCompact_of_totallyBounded_isClosed
-/

#print CauchySeq.totallyBounded_range /-
/-- Every Cauchy sequence over `ℕ` is totally bounded. -/
theorem CauchySeq.totallyBounded_range {s : ℕ → α} (hs : CauchySeq s) : TotallyBounded (range s) :=
  by
  refine' totallyBounded_iff_subset.2 fun a ha => _
  cases' cauchySeq_iff.1 hs a ha with n hn
  refine' ⟨s '' {k | k ≤ n}, image_subset_range _ _, (finite_le_nat _).image _, _⟩
  rw [range_subset_iff, bUnion_image]
  intro m
  rw [mem_Union₂]
  cases' le_total m n with hm hm
  exacts [⟨m, hm, refl_mem_uniformity ha⟩, ⟨n, le_refl n, hn m hm n le_rfl⟩]
#align cauchy_seq.totally_bounded_range CauchySeq.totallyBounded_range
-/

/-!
### Sequentially complete space

In this section we prove that a uniform space is complete provided that it is sequentially complete
(i.e., any Cauchy sequence converges) and its uniformity filter admits a countable generating set.
In particular, this applies to (e)metric spaces, see the files `topology/metric_space/emetric_space`
and `topology/metric_space/basic`.

More precisely, we assume that there is a sequence of entourages `U_n` such that any other
entourage includes one of `U_n`. Then any Cauchy filter `f` generates a decreasing sequence of
sets `s_n ∈ f` such that `s_n × s_n ⊆ U_n`. Choose a sequence `x_n∈s_n`. It is easy to show
that this is a Cauchy sequence. If this sequence converges to some `a`, then `f ≤ 𝓝 a`. -/


namespace SequentiallyComplete

variable {f : Filter α} (hf : Cauchy f) {U : ℕ → Set (α × α)} (U_mem : ∀ n, U n ∈ 𝓤 α)
  (U_le : ∀ s ∈ 𝓤 α, ∃ n, U n ⊆ s)

open Set Finset

noncomputable section

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print SequentiallyComplete.setSeqAux /-
/-- An auxiliary sequence of sets approximating a Cauchy filter. -/
def setSeqAux (n : ℕ) : { s : Set α // ∃ _ : s ∈ f, s ×ˢ s ⊆ U n } :=
  indefiniteDescription _ <| (cauchy_iff.1 hf).2 (U n) (U_mem n)
#align sequentially_complete.set_seq_aux SequentiallyComplete.setSeqAux
-/

#print SequentiallyComplete.setSeq /-
/-- Given a Cauchy filter `f` and a sequence `U` of entourages, `set_seq` provides
an antitone sequence of sets `s n ∈ f` such that `s n ×ˢ s n ⊆ U`. -/
def setSeq (n : ℕ) : Set α :=
  ⋂ m ∈ Set.Iic n, (setSeqAux hf U_mem m).val
#align sequentially_complete.set_seq SequentiallyComplete.setSeq
-/

#print SequentiallyComplete.setSeq_mem /-
theorem setSeq_mem (n : ℕ) : setSeq hf U_mem n ∈ f :=
  (biInter_mem (finite_le_nat n)).2 fun m _ => (setSeqAux hf U_mem m).2.fst
#align sequentially_complete.set_seq_mem SequentiallyComplete.setSeq_mem
-/

#print SequentiallyComplete.setSeq_mono /-
theorem setSeq_mono ⦃m n : ℕ⦄ (h : m ≤ n) : setSeq hf U_mem n ⊆ setSeq hf U_mem m :=
  biInter_subset_biInter_left fun k hk => le_trans hk h
#align sequentially_complete.set_seq_mono SequentiallyComplete.setSeq_mono
-/

#print SequentiallyComplete.setSeq_sub_aux /-
theorem setSeq_sub_aux (n : ℕ) : setSeq hf U_mem n ⊆ setSeqAux hf U_mem n :=
  biInter_subset_of_mem right_mem_Iic
#align sequentially_complete.set_seq_sub_aux SequentiallyComplete.setSeq_sub_aux
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print SequentiallyComplete.setSeq_prod_subset /-
theorem setSeq_prod_subset {N m n} (hm : N ≤ m) (hn : N ≤ n) :
    setSeq hf U_mem m ×ˢ setSeq hf U_mem n ⊆ U N :=
  by
  intro p hp
  refine' (set_seq_aux hf U_mem N).2.snd ⟨_, _⟩ <;> apply set_seq_sub_aux
  exact set_seq_mono hf U_mem hm hp.1
  exact set_seq_mono hf U_mem hn hp.2
#align sequentially_complete.set_seq_prod_subset SequentiallyComplete.setSeq_prod_subset
-/

#print SequentiallyComplete.seq /-
/-- A sequence of points such that `seq n ∈ set_seq n`. Here `set_seq` is an antitone
sequence of sets `set_seq n ∈ f` with diameters controlled by a given sequence
of entourages. -/
def seq (n : ℕ) : α :=
  choose <| hf.1.nonempty_of_mem (setSeq_mem hf U_mem n)
#align sequentially_complete.seq SequentiallyComplete.seq
-/

#print SequentiallyComplete.seq_mem /-
theorem seq_mem (n : ℕ) : seq hf U_mem n ∈ setSeq hf U_mem n :=
  choose_spec <| hf.1.nonempty_of_mem (setSeq_mem hf U_mem n)
#align sequentially_complete.seq_mem SequentiallyComplete.seq_mem
-/

#print SequentiallyComplete.seq_pair_mem /-
theorem seq_pair_mem ⦃N m n : ℕ⦄ (hm : N ≤ m) (hn : N ≤ n) :
    (seq hf U_mem m, seq hf U_mem n) ∈ U N :=
  setSeq_prod_subset hf U_mem hm hn ⟨seq_mem hf U_mem m, seq_mem hf U_mem n⟩
#align sequentially_complete.seq_pair_mem SequentiallyComplete.seq_pair_mem
-/

#print SequentiallyComplete.seq_is_cauchySeq /-
theorem seq_is_cauchySeq : CauchySeq <| seq hf U_mem :=
  cauchySeq_of_controlled U U_le <| seq_pair_mem hf U_mem
#align sequentially_complete.seq_is_cauchy_seq SequentiallyComplete.seq_is_cauchySeq
-/

#print SequentiallyComplete.le_nhds_of_seq_tendsto_nhds /-
/-- If the sequence `sequentially_complete.seq` converges to `a`, then `f ≤ 𝓝 a`. -/
theorem le_nhds_of_seq_tendsto_nhds ⦃a : α⦄ (ha : Tendsto (seq hf U_mem) atTop (𝓝 a)) : f ≤ 𝓝 a :=
  le_nhds_of_cauchy_adhp_aux
    (by
      intro s hs
      rcases U_le s hs with ⟨m, hm⟩
      rcases tendsto_at_top'.1 ha _ (mem_nhds_left a (U_mem m)) with ⟨n, hn⟩
      refine'
        ⟨set_seq hf U_mem (max m n), set_seq_mem hf U_mem _, _, seq hf U_mem (max m n), _,
          seq_mem hf U_mem _⟩
      · have := le_max_left m n
        exact Set.Subset.trans (set_seq_prod_subset hf U_mem this this) hm
      · exact hm (hn _ <| le_max_right m n))
#align sequentially_complete.le_nhds_of_seq_tendsto_nhds SequentiallyComplete.le_nhds_of_seq_tendsto_nhds
-/

end SequentiallyComplete

namespace UniformSpace

open SequentiallyComplete

variable [IsCountablyGenerated (𝓤 α)]

#print UniformSpace.complete_of_convergent_controlled_sequences /-
/-- A uniform space is complete provided that (a) its uniformity filter has a countable basis;
(b) any sequence satisfying a "controlled" version of the Cauchy condition converges. -/
theorem complete_of_convergent_controlled_sequences (U : ℕ → Set (α × α)) (U_mem : ∀ n, U n ∈ 𝓤 α)
    (HU : ∀ u : ℕ → α, (∀ N m n, N ≤ m → N ≤ n → (u m, u n) ∈ U N) → ∃ a, Tendsto u atTop (𝓝 a)) :
    CompleteSpace α :=
  by
  obtain ⟨U', U'_mono, hU'⟩ := (𝓤 α).exists_antitone_seq
  have Hmem : ∀ n, U n ∩ U' n ∈ 𝓤 α := fun n => inter_mem (U_mem n) (hU'.2 ⟨n, subset.refl _⟩)
  refine'
    ⟨fun f hf =>
      (HU (seq hf Hmem) fun N m n hm hn => _).imp <| le_nhds_of_seq_tendsto_nhds _ _ fun s hs => _⟩
  · rcases hU'.1 hs with ⟨N, hN⟩
    exact ⟨N, subset.trans (inter_subset_right _ _) hN⟩
  · exact inter_subset_left _ _ (seq_pair_mem hf Hmem hm hn)
#align uniform_space.complete_of_convergent_controlled_sequences UniformSpace.complete_of_convergent_controlled_sequences
-/

#print UniformSpace.complete_of_cauchySeq_tendsto /-
/-- A sequentially complete uniform space with a countable basis of the uniformity filter is
complete. -/
theorem complete_of_cauchySeq_tendsto (H' : ∀ u : ℕ → α, CauchySeq u → ∃ a, Tendsto u atTop (𝓝 a)) :
    CompleteSpace α :=
  let ⟨U', U'_mono, hU'⟩ := (𝓤 α).exists_antitone_seq
  complete_of_convergent_controlled_sequences U' (fun n => hU'.2 ⟨n, Subset.refl _⟩) fun u hu =>
    H' u <| cauchySeq_of_controlled U' (fun s hs => hU'.1 hs) hu
#align uniform_space.complete_of_cauchy_seq_tendsto UniformSpace.complete_of_cauchySeq_tendsto
-/

variable (α)

#print UniformSpace.firstCountableTopology /-
instance (priority := 100) firstCountableTopology : FirstCountableTopology α :=
  ⟨fun a => by rw [nhds_eq_comap_uniformity]; infer_instance⟩
#align uniform_space.first_countable_topology UniformSpace.firstCountableTopology
-/

#print UniformSpace.secondCountable_of_separable /-
/-- A separable uniform space with countably generated uniformity filter is second countable:
one obtains a countable basis by taking the balls centered at points in a dense subset,
and with rational "radii" from a countable open symmetric antitone basis of `𝓤 α`. We do not
register this as an instance, as there is already an instance going in the other direction
from second countable spaces to separable spaces, and we want to avoid loops. -/
theorem secondCountable_of_separable [SeparableSpace α] : SecondCountableTopology α :=
  by
  rcases exists_countable_dense α with ⟨s, hsc, hsd⟩
  obtain
    ⟨t : ℕ → Set (α × α), hto : ∀ i : ℕ, t i ∈ (𝓤 α).sets ∧ IsOpen (t i) ∧ SymmetricRel (t i),
      h_basis : (𝓤 α).HasAntitoneBasis t⟩ :=
    (@uniformity_hasBasis_open_symmetric α _).exists_antitone_subbasis
  choose ht_mem hto hts using hto
  refine' ⟨⟨⋃ x ∈ s, range fun k => ball x (t k), hsc.bUnion fun x hx => countable_range _, _⟩⟩
  refine' (is_topological_basis_of_open_of_nhds _ _).eq_generateFrom
  · simp only [mem_Union₂, mem_range]
    rintro _ ⟨x, hxs, k, rfl⟩
    exact is_open_ball x (hto k)
  · intro x V hxV hVo
    simp only [mem_Union₂, mem_range, exists_prop]
    rcases UniformSpace.mem_nhds_iff.1 (IsOpen.mem_nhds hVo hxV) with ⟨U, hU, hUV⟩
    rcases comp_symm_of_uniformity hU with ⟨U', hU', hsymm, hUU'⟩
    rcases h_basis.to_has_basis.mem_iff.1 hU' with ⟨k, -, hk⟩
    rcases hsd.inter_open_nonempty (ball x <| t k) (is_open_ball x (hto k))
        ⟨x, UniformSpace.mem_ball_self _ (ht_mem k)⟩ with
      ⟨y, hxy, hys⟩
    refine' ⟨_, ⟨y, hys, k, rfl⟩, (hts k).Subset hxy, fun z hz => _⟩
    exact hUV (ball_subset_of_comp_subset (hk hxy) hUU' (hk hz))
#align uniform_space.second_countable_of_separable UniformSpace.secondCountable_of_separable
-/

end UniformSpace

