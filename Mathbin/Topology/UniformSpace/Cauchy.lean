import Mathbin.Topology.Bases 
import Mathbin.Topology.UniformSpace.Basic

/-!
# Theory of Cauchy filters in uniform spaces. Complete uniform spaces. Totally bounded subsets.
-/


universe u v

open Filter TopologicalSpace Set Classical UniformSpace

open_locale Classical uniformity TopologicalSpace Filter

variable{α : Type u}{β : Type v}[UniformSpace α]

/-- A filter `f` is Cauchy if for every entourage `r`, there exists an
  `s ∈ f` such that `s × s ⊆ r`. This is a generalization of Cauchy
  sequences, because if `a : ℕ → α` then the filter of sets containing
  cofinitely many of the `a n` is Cauchy iff `a` is a Cauchy sequence. -/
def Cauchy (f : Filter α) :=
  ne_bot f ∧ f ×ᶠ f ≤ 𝓤 α

/-- A set `s` is called *complete*, if any Cauchy filter `f` such that `s ∈ f`
has a limit in `s` (formally, it satisfies `f ≤ 𝓝 x` for some `x ∈ s`). -/
def IsComplete (s : Set α) :=
  ∀ f, Cauchy f → f ≤ 𝓟 s → ∃ (x : _)(_ : x ∈ s), f ≤ 𝓝 x

theorem Filter.HasBasis.cauchy_iff {ι} {p : ι → Prop} {s : ι → Set (α × α)} (h : (𝓤 α).HasBasis p s) {f : Filter α} :
  Cauchy f ↔ ne_bot f ∧ ∀ i, p i → ∃ (t : _)(_ : t ∈ f), ∀ x y (_ : x ∈ t) (_ : y ∈ t), (x, y) ∈ s i :=
  and_congr Iff.rfl$
    (f.basis_sets.prod_self.le_basis_iff h).trans$
      by 
        simp only [subset_def, Prod.forall, mem_prod_eq, and_imp, id]

theorem cauchy_iff' {f : Filter α} :
  Cauchy f ↔ ne_bot f ∧ ∀ s (_ : s ∈ 𝓤 α), ∃ (t : _)(_ : t ∈ f), ∀ x y (_ : x ∈ t) (_ : y ∈ t), (x, y) ∈ s :=
  (𝓤 α).basis_sets.cauchy_iff

theorem cauchy_iff {f : Filter α} : Cauchy f ↔ ne_bot f ∧ ∀ s (_ : s ∈ 𝓤 α), ∃ (t : _)(_ : t ∈ f), Set.Prod t t ⊆ s :=
  cauchy_iff'.trans$
    by 
      simp only [subset_def, Prod.forall, mem_prod_eq, and_imp, id]

-- error in Topology.UniformSpace.Cauchy: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem cauchy_map_iff
{l : filter β}
{f : β → α} : «expr ↔ »(cauchy (l.map f), «expr ∧ »(ne_bot l, tendsto (λ
   p : «expr × »(β, β), (f p.1, f p.2)) «expr ×ᶠ »(l, l) (expr𝓤() α))) :=
by rw ["[", expr cauchy, ",", expr map_ne_bot_iff, ",", expr prod_map_map_eq, ",", expr tendsto, "]"] []

-- error in Topology.UniformSpace.Cauchy: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem cauchy_map_iff'
{l : filter β}
[hl : ne_bot l]
{f : β → α} : «expr ↔ »(cauchy (l.map f), tendsto (λ
  p : «expr × »(β, β), (f p.1, f p.2)) «expr ×ᶠ »(l, l) (expr𝓤() α)) :=
«expr $ »(cauchy_map_iff.trans, and_iff_right hl)

theorem Cauchy.mono {f g : Filter α} [hg : ne_bot g] (h_c : Cauchy f) (h_le : g ≤ f) : Cauchy g :=
  ⟨hg, le_transₓ (Filter.prod_mono h_le h_le) h_c.right⟩

theorem Cauchy.mono' {f g : Filter α} (h_c : Cauchy f) (hg : ne_bot g) (h_le : g ≤ f) : Cauchy g :=
  h_c.mono h_le

theorem cauchy_nhds {a : α} : Cauchy (𝓝 a) :=
  ⟨nhds_ne_bot, nhds_prod_eq.symm.trans_le (nhds_le_uniformity a)⟩

theorem cauchy_pure {a : α} : Cauchy (pure a) :=
  cauchy_nhds.mono (pure_le_nhds a)

theorem Filter.Tendsto.cauchy_map {l : Filter β} [ne_bot l] {f : β → α} {a : α} (h : tendsto f l (𝓝 a)) :
  Cauchy (map f l) :=
  cauchy_nhds.mono h

theorem Cauchy.prod [UniformSpace β] {f : Filter α} {g : Filter β} (hf : Cauchy f) (hg : Cauchy g) : Cauchy (f ×ᶠ g) :=
  by 
    refine' ⟨hf.1.Prod hg.1, _⟩
    simp only [uniformity_prod, le_inf_iff, ←map_le_iff_le_comap, ←prod_map_map_eq]
    exact ⟨le_transₓ (prod_mono tendsto_fst tendsto_fst) hf.2, le_transₓ (prod_mono tendsto_snd tendsto_snd) hg.2⟩

/-- The common part of the proofs of `le_nhds_of_cauchy_adhp` and
`sequentially_complete.le_nhds_of_seq_tendsto_nhds`: if for any entourage `s`
one can choose a set `t ∈ f` of diameter `s` such that it contains a point `y`
with `(x, y) ∈ s`, then `f` converges to `x`. -/
theorem le_nhds_of_cauchy_adhp_aux {f : Filter α} {x : α}
  (adhs : ∀ s (_ : s ∈ 𝓤 α), ∃ (t : _)(_ : t ∈ f), Set.Prod t t ⊆ s ∧ ∃ y, (x, y) ∈ s ∧ y ∈ t) : f ≤ 𝓝 x :=
  by 
    intro s hs 
    rcases comp_mem_uniformity_sets (mem_nhds_uniformity_iff_right.1 hs) with ⟨U, U_mem, hU⟩
    rcases adhs U U_mem with ⟨t, t_mem, ht, y, hxy, hy⟩
    apply mem_of_superset t_mem 
    exact fun z hz => hU (prod_mk_mem_comp_rel hxy (ht$ mk_mem_prod hy hz)) rfl

/-- If `x` is an adherent (cluster) point for a Cauchy filter `f`, then it is a limit point
for `f`. -/
theorem le_nhds_of_cauchy_adhp {f : Filter α} {x : α} (hf : Cauchy f) (adhs : ClusterPt x f) : f ≤ 𝓝 x :=
  le_nhds_of_cauchy_adhp_aux
    (by 
      intro s hs 
      obtain ⟨t, t_mem, ht⟩ : ∃ (t : _)(_ : t ∈ f), Set.Prod t t ⊆ s 
      exact (cauchy_iff.1 hf).2 s hs 
      use t, t_mem, ht 
      exact forall_mem_nonempty_iff_ne_bot.2 adhs _ (inter_mem_inf (mem_nhds_left x hs) t_mem))

theorem le_nhds_iff_adhp_of_cauchy {f : Filter α} {x : α} (hf : Cauchy f) : f ≤ 𝓝 x ↔ ClusterPt x f :=
  ⟨fun h => ClusterPt.of_le_nhds' h hf.1, le_nhds_of_cauchy_adhp hf⟩

-- error in Topology.UniformSpace.Cauchy: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem cauchy.map
[uniform_space β]
{f : filter α}
{m : α → β}
(hf : cauchy f)
(hm : uniform_continuous m) : cauchy (map m f) :=
⟨hf.1.map _, calc
   «expr = »(«expr ×ᶠ »(map m f, map m f), map (λ
     p : «expr × »(α, α), (m p.1, m p.2)) «expr ×ᶠ »(f, f)) : filter.prod_map_map_eq
   «expr ≤ »(..., map (λ p : «expr × »(α, α), (m p.1, m p.2)) (expr𝓤() α)) : map_mono hf.right
   «expr ≤ »(..., expr𝓤() β) : hm⟩

-- error in Topology.UniformSpace.Cauchy: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem cauchy.comap
[uniform_space β]
{f : filter β}
{m : α → β}
(hf : cauchy f)
(hm : «expr ≤ »(comap (λ p : «expr × »(α, α), (m p.1, m p.2)) (expr𝓤() β), expr𝓤() α))
[ne_bot (comap m f)] : cauchy (comap m f) :=
⟨«expr‹ ›»(_), calc
   «expr = »(«expr ×ᶠ »(comap m f, comap m f), comap (λ
     p : «expr × »(α, α), (m p.1, m p.2)) «expr ×ᶠ »(f, f)) : filter.prod_comap_comap_eq
   «expr ≤ »(..., comap (λ p : «expr × »(α, α), (m p.1, m p.2)) (expr𝓤() β)) : comap_mono hf.right
   «expr ≤ »(..., expr𝓤() α) : hm⟩

-- error in Topology.UniformSpace.Cauchy: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem cauchy.comap'
[uniform_space β]
{f : filter β}
{m : α → β}
(hf : cauchy f)
(hm : «expr ≤ »(comap (λ p : «expr × »(α, α), (m p.1, m p.2)) (expr𝓤() β), expr𝓤() α))
(hb : ne_bot (comap m f)) : cauchy (comap m f) :=
hf.comap hm

/-- Cauchy sequences. Usually defined on ℕ, but often it is also useful to say that a function
defined on ℝ is Cauchy at +∞ to deduce convergence. Therefore, we define it in a type class that
is general enough to cover both ℕ and ℝ, which are the main motivating examples. -/
def CauchySeq [SemilatticeSup β] (u : β → α) :=
  Cauchy (at_top.map u)

theorem CauchySeq.tendsto_uniformity [SemilatticeSup β] {u : β → α} (h : CauchySeq u) :
  tendsto (Prod.mapₓ u u) at_top (𝓤 α) :=
  by 
    simpa only [tendsto, prod_map_map_eq', prod_at_top_at_top_eq] using h.right

theorem CauchySeq.nonempty [SemilatticeSup β] {u : β → α} (hu : CauchySeq u) : Nonempty β :=
  @nonempty_of_ne_bot _ _$ (map_ne_bot_iff _).1 hu.1

-- error in Topology.UniformSpace.Cauchy: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem cauchy_seq.mem_entourage
{β : Type*}
[semilattice_sup β]
{u : β → α}
(h : cauchy_seq u)
{V : set «expr × »(α, α)}
(hV : «expr ∈ »(V, expr𝓤() α)) : «expr∃ , »((k₀), ∀
 i j, «expr ≤ »(k₀, i) → «expr ≤ »(k₀, j) → «expr ∈ »((u i, u j), V)) :=
begin
  haveI [] [] [":=", expr h.nonempty],
  have [] [] [":=", expr h.tendsto_uniformity],
  rw ["<-", expr prod_at_top_at_top_eq] ["at", ident this],
  simpa [] [] [] ["[", expr maps_to, "]"] [] ["using", expr at_top_basis.prod_self.tendsto_left_iff.1 this V hV]
end

theorem Filter.Tendsto.cauchy_seq [SemilatticeSup β] [Nonempty β] {f : β → α} {x} (hx : tendsto f at_top (𝓝 x)) :
  CauchySeq f :=
  hx.cauchy_map

-- error in Topology.UniformSpace.Cauchy: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem cauchy_seq_const (x : α) : cauchy_seq (λ n : exprℕ(), x) := tendsto_const_nhds.cauchy_seq

theorem cauchy_seq_iff_tendsto [Nonempty β] [SemilatticeSup β] {u : β → α} :
  CauchySeq u ↔ tendsto (Prod.mapₓ u u) at_top (𝓤 α) :=
  cauchy_map_iff'.trans$
    by 
      simp only [prod_at_top_at_top_eq, Prod.map_defₓ]

theorem CauchySeq.comp_tendsto {γ} [SemilatticeSup β] [SemilatticeSup γ] [Nonempty γ] {f : β → α} (hf : CauchySeq f)
  {g : γ → β} (hg : tendsto g at_top at_top) : CauchySeq (f ∘ g) :=
  cauchy_seq_iff_tendsto.2$ hf.tendsto_uniformity.comp (hg.prod_at_top hg)

theorem CauchySeq.subseq_subseq_mem {V : ℕ → Set (α × α)} (hV : ∀ n, V n ∈ 𝓤 α) {u : ℕ → α} (hu : CauchySeq u)
  {f g : ℕ → ℕ} (hf : tendsto f at_top at_top) (hg : tendsto g at_top at_top) :
  ∃ φ : ℕ → ℕ, StrictMono φ ∧ ∀ n, ((u ∘ f ∘ φ) n, (u ∘ g ∘ φ) n) ∈ V n :=
  by 
    rw [cauchy_seq_iff_tendsto] at hu 
    exact ((hu.comp$ hf.prod_at_top hg).comp tendsto_at_top_diagonal).subseq_mem hV

theorem cauchy_seq_iff' {u : ℕ → α} : CauchySeq u ↔ ∀ V (_ : V ∈ 𝓤 α), ∀ᶠk in at_top, k ∈ Prod.mapₓ u u ⁻¹' V :=
  by 
    simpa only [cauchy_seq_iff_tendsto]

theorem cauchy_seq_iff {u : ℕ → α} :
  CauchySeq u ↔ ∀ V (_ : V ∈ 𝓤 α), ∃ N, ∀ k (_ : k ≥ N), ∀ l (_ : l ≥ N), (u k, u l) ∈ V :=
  by 
    simp [cauchy_seq_iff', Filter.eventually_at_top_prod_self', prod_mapₓ]

theorem CauchySeq.prod_map {γ δ} [UniformSpace β] [SemilatticeSup γ] [SemilatticeSup δ] {u : γ → α} {v : δ → β}
  (hu : CauchySeq u) (hv : CauchySeq v) : CauchySeq (Prod.mapₓ u v) :=
  by 
    simpa only [CauchySeq, prod_map_map_eq', prod_at_top_at_top_eq] using hu.prod hv

-- error in Topology.UniformSpace.Cauchy: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem cauchy_seq.prod
{γ}
[uniform_space β]
[semilattice_sup γ]
{u : γ → α}
{v : γ → β}
(hu : cauchy_seq u)
(hv : cauchy_seq v) : cauchy_seq (λ x, (u x, v x)) :=
begin
  haveI [] [] [":=", expr hu.nonempty],
  exact [expr (hu.prod hv).mono (tendsto.prod_mk le_rfl le_rfl)]
end

theorem UniformContinuous.comp_cauchy_seq {γ} [UniformSpace β] [SemilatticeSup γ] {f : α → β} (hf : UniformContinuous f)
  {u : γ → α} (hu : CauchySeq u) : CauchySeq (f ∘ u) :=
  hu.map hf

-- error in Topology.UniformSpace.Cauchy: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem cauchy_seq.subseq_mem
{V : exprℕ() → set «expr × »(α, α)}
(hV : ∀ n, «expr ∈ »(V n, expr𝓤() α))
{u : exprℕ() → α}
(hu : cauchy_seq u) : «expr∃ , »((φ : exprℕ() → exprℕ()), «expr ∧ »(strict_mono φ, ∀
  n, «expr ∈ »((«expr $ »(u, φ «expr + »(n, 1)), «expr $ »(u, φ n)), V n))) :=
begin
  have [] [":", expr ∀ n, «expr∃ , »((N), ∀ k «expr ≥ » N, ∀ l «expr ≥ » k, «expr ∈ »((u l, u k), V n))] [],
  { intro [ident n],
    rw ["[", expr cauchy_seq_iff, "]"] ["at", ident hu],
    rcases [expr hu _ (hV n), "with", "⟨", ident N, ",", ident H, "⟩"],
    exact [expr ⟨N, λ k hk l hl, H _ (le_trans hk hl) _ hk⟩] },
  obtain ["⟨", ident φ, ":", expr exprℕ() → exprℕ(), ",", ident φ_extr, ":", expr strict_mono φ, ",", ident hφ, ":", expr ∀
   n, ∀
   l «expr ≥ » φ n, «expr ∈ »((u l, «expr $ »(u, φ n)), V n), "⟩", ":=", expr extraction_forall_of_eventually' this],
  exact [expr ⟨φ, φ_extr, λ n, hφ _ _ «expr $ »(φ_extr, lt_add_one n).le⟩]
end

theorem Filter.Tendsto.subseq_mem_entourage {V : ℕ → Set (α × α)} (hV : ∀ n, V n ∈ 𝓤 α) {u : ℕ → α} {a : α}
  (hu : tendsto u at_top (𝓝 a)) :
  ∃ φ : ℕ → ℕ, StrictMono φ ∧ (u (φ 0), a) ∈ V 0 ∧ ∀ n, (u$ φ (n+1), u$ φ n) ∈ V (n+1) :=
  by 
    rcases mem_at_top_sets.1 (hu (ball_mem_nhds a (symm_le_uniformity$ hV 0))) with ⟨n, hn⟩
    rcases(hu.comp (tendsto_add_at_top_nat n)).CauchySeq.subseq_mem fun n => hV (n+1) with ⟨φ, φ_mono, hφV⟩
    exact ⟨fun k => φ k+n, φ_mono.add_const _, hn _ le_add_self, hφV⟩

/-- If a Cauchy sequence has a convergent subsequence, then it converges. -/
theorem tendsto_nhds_of_cauchy_seq_of_subseq [SemilatticeSup β] {u : β → α} (hu : CauchySeq u) {ι : Type _} {f : ι → β}
  {p : Filter ι} [ne_bot p] (hf : tendsto f p at_top) {a : α} (ha : tendsto (u ∘ f) p (𝓝 a)) : tendsto u at_top (𝓝 a) :=
  le_nhds_of_cauchy_adhp hu (map_cluster_pt_of_comp hf ha)

@[nolint ge_or_gt]
theorem Filter.HasBasis.cauchy_seq_iff {γ} [Nonempty β] [SemilatticeSup β] {u : β → α} {p : γ → Prop}
  {s : γ → Set (α × α)} (h : (𝓤 α).HasBasis p s) :
  CauchySeq u ↔ ∀ i, p i → ∃ N, ∀ m n (_ : m ≥ N) (_ : n ≥ N), (u m, u n) ∈ s i :=
  by 
    rw [cauchy_seq_iff_tendsto, ←prod_at_top_at_top_eq]
    refine' (at_top_basis.prod_self.tendsto_iff h).trans _ 
    simp only [exists_prop, true_andₓ, maps_to, preimage, subset_def, Prod.forall, mem_prod_eq, mem_set_of_eq, mem_Ici,
      and_imp, Prod.mapₓ]

theorem Filter.HasBasis.cauchy_seq_iff' {γ} [Nonempty β] [SemilatticeSup β] {u : β → α} {p : γ → Prop}
  {s : γ → Set (α × α)} (H : (𝓤 α).HasBasis p s) : CauchySeq u ↔ ∀ i, p i → ∃ N, ∀ n (_ : n ≥ N), (u n, u N) ∈ s i :=
  by 
    refine' H.cauchy_seq_iff.trans ⟨fun h i hi => _, fun h i hi => _⟩
    ·
      exact (h i hi).imp fun N hN n hn => hN n N hn (le_reflₓ N)
    ·
      rcases comp_symm_of_uniformity (H.mem_of_mem hi) with ⟨t, ht, ht', hts⟩
      rcases H.mem_iff.1 ht with ⟨j, hj, hjt⟩
      refine' (h j hj).imp fun N hN m n hm hn => hts ⟨u N, hjt _, ht'$ hjt _⟩
      ·
        exact hN m hm
      ·
        exact hN n hn

theorem cauchy_seq_of_controlled [SemilatticeSup β] [Nonempty β] (U : β → Set (α × α))
  (hU : ∀ s (_ : s ∈ 𝓤 α), ∃ n, U n ⊆ s) {f : β → α} (hf : ∀ {N m n : β}, N ≤ m → N ≤ n → (f m, f n) ∈ U N) :
  CauchySeq f :=
  cauchy_seq_iff_tendsto.2
    (by 
      intro s hs 
      rw [mem_map, mem_at_top_sets]
      cases' hU s hs with N hN 
      refine' ⟨(N, N), fun mn hmn => _⟩
      cases' mn with m n 
      exact hN (hf hmn.1 hmn.2))

/-- A complete space is defined here using uniformities. A uniform space
  is complete if every Cauchy filter converges. -/
class CompleteSpace(α : Type u)[UniformSpace α] : Prop where 
  complete : ∀ {f : Filter α}, Cauchy f → ∃ x, f ≤ 𝓝 x

theorem complete_univ {α : Type u} [UniformSpace α] [CompleteSpace α] : IsComplete (univ : Set α) :=
  by 
    intro f hf _ 
    rcases CompleteSpace.complete hf with ⟨x, hx⟩
    exact ⟨x, mem_univ x, hx⟩

instance CompleteSpace.prod [UniformSpace β] [CompleteSpace α] [CompleteSpace β] : CompleteSpace (α × β) :=
  { complete :=
      fun f hf =>
        let ⟨x1, hx1⟩ := CompleteSpace.complete$ hf.map uniform_continuous_fst 
        let ⟨x2, hx2⟩ := CompleteSpace.complete$ hf.map uniform_continuous_snd
        ⟨(x1, x2),
          by 
            rw [nhds_prod_eq, Filter.prod_def] <;>
              exact
                Filter.le_lift
                  fun s hs =>
                    Filter.le_lift'$
                      fun t ht =>
                        have H1 : Prod.fst ⁻¹' s ∈ f.sets := hx1 hs 
                        have H2 : Prod.snd ⁻¹' t ∈ f.sets := hx2 ht 
                        Filter.inter_mem H1 H2⟩ }

/--If `univ` is complete, the space is a complete space -/
theorem complete_space_of_is_complete_univ (h : IsComplete (univ : Set α)) : CompleteSpace α :=
  ⟨fun f hf =>
      let ⟨x, _, hx⟩ := h f hf ((@principal_univ α).symm ▸ le_top)
      ⟨x, hx⟩⟩

theorem complete_space_iff_is_complete_univ : CompleteSpace α ↔ IsComplete (univ : Set α) :=
  ⟨@complete_univ α _, complete_space_of_is_complete_univ⟩

theorem cauchy_iff_exists_le_nhds [CompleteSpace α] {l : Filter α} [ne_bot l] : Cauchy l ↔ ∃ x, l ≤ 𝓝 x :=
  ⟨CompleteSpace.complete, fun ⟨x, hx⟩ => cauchy_nhds.mono hx⟩

theorem cauchy_map_iff_exists_tendsto [CompleteSpace α] {l : Filter β} {f : β → α} [ne_bot l] :
  Cauchy (l.map f) ↔ ∃ x, tendsto f l (𝓝 x) :=
  cauchy_iff_exists_le_nhds

/-- A Cauchy sequence in a complete space converges -/
theorem cauchy_seq_tendsto_of_complete [SemilatticeSup β] [CompleteSpace α] {u : β → α} (H : CauchySeq u) :
  ∃ x, tendsto u at_top (𝓝 x) :=
  CompleteSpace.complete H

/-- If `K` is a complete subset, then any cauchy sequence in `K` converges to a point in `K` -/
theorem cauchy_seq_tendsto_of_is_complete [SemilatticeSup β] {K : Set α} (h₁ : IsComplete K) {u : β → α}
  (h₂ : ∀ n, u n ∈ K) (h₃ : CauchySeq u) : ∃ (v : _)(_ : v ∈ K), tendsto u at_top (𝓝 v) :=
  h₁ _ h₃$
    le_principal_iff.2$
      mem_map_iff_exists_image.2
        ⟨univ, univ_mem,
          by 
            simp only [image_univ]
            rintro _ ⟨n, rfl⟩
            exact h₂ n⟩

theorem Cauchy.le_nhds_Lim [CompleteSpace α] [Nonempty α] {f : Filter α} (hf : Cauchy f) : f ≤ 𝓝 (lim f) :=
  le_nhds_Lim (CompleteSpace.complete hf)

theorem CauchySeq.tendsto_lim [SemilatticeSup β] [CompleteSpace α] [Nonempty α] {u : β → α} (h : CauchySeq u) :
  tendsto u at_top (𝓝$ limₓ at_top u) :=
  h.le_nhds_Lim

theorem IsClosed.is_complete [CompleteSpace α] {s : Set α} (h : IsClosed s) : IsComplete s :=
  fun f cf fs =>
    let ⟨x, hx⟩ := CompleteSpace.complete cf
    ⟨x, is_closed_iff_cluster_pt.mp h x (cf.left.mono (le_inf hx fs)), hx⟩

/-- A set `s` is totally bounded if for every entourage `d` there is a finite
  set of points `t` such that every element of `s` is `d`-near to some element of `t`. -/
def TotallyBounded (s : Set α) : Prop :=
  ∀ d (_ : d ∈ 𝓤 α), ∃ t : Set α, finite t ∧ s ⊆ ⋃(y : _)(_ : y ∈ t), { x | (x, y) ∈ d }

-- error in Topology.UniformSpace.Cauchy: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem totally_bounded_iff_subset
{s : set α} : «expr ↔ »(totally_bounded s, ∀
 d «expr ∈ » expr𝓤() α, «expr∃ , »((t «expr ⊆ » s), «expr ∧ »(finite t, «expr ⊆ »(s, «expr⋃ , »((y «expr ∈ » t), {x | «expr ∈ »((x, y), d)}))))) :=
⟨λ H d hd, begin
   rcases [expr comp_symm_of_uniformity hd, "with", "⟨", ident r, ",", ident hr, ",", ident rs, ",", ident rd, "⟩"],
   rcases [expr H r hr, "with", "⟨", ident k, ",", ident fk, ",", ident ks, "⟩"],
   let [ident u] [] [":=", expr «expr ∩ »(k, {y | «expr∃ , »((x «expr ∈ » s), «expr ∈ »((x, y), r))})],
   choose [] [ident hk] [ident f, ident hfs, ident hfr] ["using", expr λ x : u, x.coe_prop],
   refine [expr ⟨range f, _, _, _⟩],
   { exact [expr range_subset_iff.2 hfs] },
   { haveI [] [":", expr fintype u] [":=", expr (fk.inter_of_left _).fintype],
     exact [expr finite_range f] },
   { intros [ident x, ident xs],
     obtain ["⟨", ident y, ",", ident hy, ",", ident xy, "⟩", ":", expr «expr∃ , »((y «expr ∈ » k), «expr ∈ »((x, y), r))],
     from [expr mem_bUnion_iff.1 (ks xs)],
     rw ["[", expr bUnion_range, ",", expr mem_Union, "]"] [],
     set [] [ident z] [":", expr «expr↥ »(u)] [":="] [expr ⟨y, hy, ⟨x, xs, xy⟩⟩] [],
     exact [expr ⟨z, «expr $ »(rd, mem_comp_rel.2 ⟨y, xy, rs (hfr z)⟩)⟩] }
 end, λ H d hd, let ⟨t, _, ht⟩ := H d hd in
 ⟨t, ht⟩⟩

theorem totally_bounded_of_forall_symm {s : Set α}
  (h : ∀ V (_ : V ∈ 𝓤 α), SymmetricRel V → ∃ t : Set α, finite t ∧ s ⊆ ⋃(y : _)(_ : y ∈ t), ball y V) :
  TotallyBounded s :=
  by 
    intro V V_in 
    rcases h _ (symmetrize_mem_uniformity V_in) (symmetric_symmetrize_rel V) with ⟨t, tfin, h⟩
    refine' ⟨t, tfin, subset.trans h _⟩
    mono 
    intro x x_in z z_in 
    exact z_in.right

theorem totally_bounded_subset {s₁ s₂ : Set α} (hs : s₁ ⊆ s₂) (h : TotallyBounded s₂) : TotallyBounded s₁ :=
  fun d hd =>
    let ⟨t, ht₁, ht₂⟩ := h d hd
    ⟨t, ht₁, subset.trans hs ht₂⟩

theorem totally_bounded_empty : TotallyBounded (∅ : Set α) :=
  fun d hd => ⟨∅, finite_empty, empty_subset _⟩

/-- The closure of a totally bounded set is totally bounded. -/
theorem TotallyBounded.closure {s : Set α} (h : TotallyBounded s) : TotallyBounded (Closure s) :=
  fun t ht =>
    let ⟨t', ht', hct', htt'⟩ := mem_uniformity_is_closed ht 
    let ⟨c, hcf, hc⟩ := h t' ht'
    ⟨c, hcf,
      calc Closure s ⊆ Closure (⋃(y : α)(H : y ∈ c), { x:α | (x, y) ∈ t' }) := closure_mono hc 
        _ = _ :=
        IsClosed.closure_eq$
          is_closed_bUnion hcf$ fun i hi => continuous_iff_is_closed.mp (continuous_id.prod_mk continuous_const) _ hct' 
        _ ⊆ _ := bUnion_subset$ fun i hi => subset.trans (fun x => @htt' (x, i)) (subset_bUnion_of_mem hi)
        ⟩

/-- The image of a totally bounded set under a unifromly continuous map is totally bounded. -/
theorem TotallyBounded.image [UniformSpace β] {f : α → β} {s : Set α} (hs : TotallyBounded s)
  (hf : UniformContinuous f) : TotallyBounded (f '' s) :=
  fun t ht =>
    have  : { p:α × α | (f p.1, f p.2) ∈ t } ∈ 𝓤 α := hf ht 
    let ⟨c, hfc, hct⟩ := hs _ this
    ⟨f '' c, hfc.image f,
      by 
        simp [image_subset_iff]
        simp [subset_def] at hct 
        intro x hx 
        simp 
        exact hct x hx⟩

theorem Ultrafilter.cauchy_of_totally_bounded {s : Set α} (f : Ultrafilter α) (hs : TotallyBounded s)
  (h : «expr↑ » f ≤ 𝓟 s) : Cauchy (f : Filter α) :=
  ⟨f.ne_bot',
    fun t ht =>
      let ⟨t', ht'₁, ht'_symm, ht'_t⟩ := comp_symm_of_uniformity ht 
      let ⟨i, hi, hs_union⟩ := hs t' ht'₁ 
      have  : (⋃(y : _)(_ : y ∈ i), { x | (x, y) ∈ t' }) ∈ f := mem_of_superset (le_principal_iff.mp h) hs_union 
      have  : ∃ (y : _)(_ : y ∈ i), { x | (x, y) ∈ t' } ∈ f := (Ultrafilter.finite_bUnion_mem_iff hi).1 this 
      let ⟨y, hy, hif⟩ := this 
      have  : Set.Prod { x | (x, y) ∈ t' } { x | (x, y) ∈ t' } ⊆ CompRel t' t' :=
        fun ⟨x₁, x₂⟩ ⟨(h₁ : (x₁, y) ∈ t'), (h₂ : (x₂, y) ∈ t')⟩ => ⟨y, h₁, ht'_symm h₂⟩
      mem_of_superset (prod_mem_prod hif hif) (subset.trans this ht'_t)⟩

-- error in Topology.UniformSpace.Cauchy: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem totally_bounded_iff_filter
{s : set α} : «expr ↔ »(totally_bounded s, ∀
 f, ne_bot f → «expr ≤ »(f, expr𝓟() s) → «expr∃ , »((c «expr ≤ » f), cauchy c)) :=
begin
  split,
  { introsI [ident H, ident f, ident hf, ident hfs],
    exact [expr ⟨ultrafilter.of f, ultrafilter.of_le f, (ultrafilter.of f).cauchy_of_totally_bounded H ((ultrafilter.of_le f).trans hfs)⟩] },
  { intros [ident H, ident d, ident hd],
    contrapose ["!"] [ident H, "with", ident hd_cover],
    set [] [ident f] [] [":="] [expr «expr⨅ , »((t : finset α), expr𝓟() «expr \ »(s, «expr⋃ , »((y «expr ∈ » t), {x | «expr ∈ »((x, y), d)})))] [],
    have [] [":", expr ne_bot f] [],
    { refine [expr infi_ne_bot_of_directed' (directed_of_sup _) _],
      { intros [ident t₁, ident t₂, ident h],
        exact [expr principal_mono.2 «expr $ »(diff_subset_diff_right, bUnion_subset_bUnion_left h)] },
      { intro [ident t],
        simpa [] [] [] ["[", expr nonempty_diff, "]"] [] ["using", expr hd_cover t t.finite_to_set] } },
    have [] [":", expr «expr ≤ »(f, expr𝓟() s)] [],
    from [expr infi_le_of_le «expr∅»() (by simp [] [] [] [] [] [])],
    refine [expr ⟨f, «expr‹ ›»(_), «expr‹ ›»(_), λ c hcf hc, _⟩],
    rcases [expr mem_prod_same_iff.1 (hc.2 hd), "with", "⟨", ident m, ",", ident hm, ",", ident hmd, "⟩"],
    have [] [":", expr «expr ∈ »(«expr ∩ »(m, s), c)] [],
    from [expr inter_mem hm (le_principal_iff.mp (hcf.trans «expr‹ ›»(_)))],
    rcases [expr hc.1.nonempty_of_mem this, "with", "⟨", ident y, ",", ident hym, ",", ident hys, "⟩"],
    set [] [ident ys] [] [":="] [expr «expr⋃ , »((y' «expr ∈ » ({y} : finset α)), {x | «expr ∈ »((x, y'), d)})] [],
    have [] [":", expr «expr ⊆ »(m, ys)] [],
    by simpa [] [] [] ["[", expr ys, "]"] [] ["using", expr λ x hx, hmd (mk_mem_prod hx hym)],
    have [] [":", expr «expr ≤ »(c, expr𝓟() «expr \ »(s, ys))] [":=", expr hcf.trans (infi_le_of_le {y} le_rfl)],
    refine [expr hc.1.ne (empty_mem_iff_bot.mp _)],
    filter_upwards ["[", expr le_principal_iff.1 this, ",", expr hm, "]"] [],
    refine [expr λ x hx hxm, hx.2 _],
    simpa [] [] [] ["[", expr ys, "]"] [] ["using", expr hmd (mk_mem_prod hxm hym)] }
end

theorem totally_bounded_iff_ultrafilter {s : Set α} :
  TotallyBounded s ↔ ∀ (f : Ultrafilter α), «expr↑ » f ≤ 𝓟 s → Cauchy (f : Filter α) :=
  by 
    refine' ⟨fun hs f => f.cauchy_of_totally_bounded hs, fun H => totally_bounded_iff_filter.2 _⟩
    intros f hf hfs 
    exact ⟨Ultrafilter.of f, Ultrafilter.of_le f, H _ ((Ultrafilter.of_le f).trans hfs)⟩

theorem compact_iff_totally_bounded_complete {s : Set α} : IsCompact s ↔ TotallyBounded s ∧ IsComplete s :=
  ⟨fun hs =>
      ⟨totally_bounded_iff_ultrafilter.2
          fun f hf =>
            let ⟨x, xs, fx⟩ := is_compact_iff_ultrafilter_le_nhds.1 hs f hf 
            cauchy_nhds.mono fx,
        fun f fc fs =>
          let ⟨a, as, fa⟩ := @hs f fc.1 fs
          ⟨a, as, le_nhds_of_cauchy_adhp fc fa⟩⟩,
    fun ⟨ht, hc⟩ =>
      is_compact_iff_ultrafilter_le_nhds.2 fun f hf => hc _ (totally_bounded_iff_ultrafilter.1 ht f hf) hf⟩

theorem IsCompact.totally_bounded {s : Set α} (h : IsCompact s) : TotallyBounded s :=
  (compact_iff_totally_bounded_complete.1 h).1

theorem IsCompact.is_complete {s : Set α} (h : IsCompact s) : IsComplete s :=
  (compact_iff_totally_bounded_complete.1 h).2

instance (priority := 100)complete_of_compact {α : Type u} [UniformSpace α] [CompactSpace α] : CompleteSpace α :=
  ⟨fun f hf =>
      by 
        simpa using (compact_iff_totally_bounded_complete.1 compact_univ).2 f hf⟩

theorem compact_of_totally_bounded_is_closed [CompleteSpace α] {s : Set α} (ht : TotallyBounded s) (hc : IsClosed s) :
  IsCompact s :=
  (@compact_iff_totally_bounded_complete α _ s).2 ⟨ht, hc.is_complete⟩

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

variable{f :
    Filter α}(hf : Cauchy f){U : ℕ → Set (α × α)}(U_mem : ∀ n, U n ∈ 𝓤 α)(U_le : ∀ s (_ : s ∈ 𝓤 α), ∃ n, U n ⊆ s)

open Set Finset

noncomputable theory

/-- An auxiliary sequence of sets approximating a Cauchy filter. -/
def set_seq_aux (n : ℕ) : { s : Set α // ∃ _ : s ∈ f, s.prod s ⊆ U n } :=
  indefinite_description _$ (cauchy_iff.1 hf).2 (U n) (U_mem n)

/-- Given a Cauchy filter `f` and a sequence `U` of entourages, `set_seq` provides
an antitone sequence of sets `s n ∈ f` such that `(s n).prod (s n) ⊆ U`. -/
def set_seq (n : ℕ) : Set α :=
  ⋂(m : _)(_ : m ∈ Iic n), (set_seq_aux hf U_mem m).val

theorem set_seq_mem (n : ℕ) : set_seq hf U_mem n ∈ f :=
  (bInter_mem (finite_le_nat n)).2 fun m _ => (set_seq_aux hf U_mem m).2.fst

theorem set_seq_mono ⦃m n : ℕ⦄ (h : m ≤ n) : set_seq hf U_mem n ⊆ set_seq hf U_mem m :=
  bInter_subset_bInter_left fun k hk => le_transₓ hk h

theorem set_seq_sub_aux (n : ℕ) : set_seq hf U_mem n ⊆ set_seq_aux hf U_mem n :=
  bInter_subset_of_mem right_mem_Iic

theorem set_seq_prod_subset {N m n} (hm : N ≤ m) (hn : N ≤ n) : (set_seq hf U_mem m).Prod (set_seq hf U_mem n) ⊆ U N :=
  by 
    intro p hp 
    refine' (set_seq_aux hf U_mem N).2.snd ⟨_, _⟩ <;> apply set_seq_sub_aux 
    exact set_seq_mono hf U_mem hm hp.1 
    exact set_seq_mono hf U_mem hn hp.2

/-- A sequence of points such that `seq n ∈ set_seq n`. Here `set_seq` is an antitone
sequence of sets `set_seq n ∈ f` with diameters controlled by a given sequence
of entourages. -/
def seq (n : ℕ) : α :=
  some$ hf.1.nonempty_of_mem (set_seq_mem hf U_mem n)

theorem seq_mem (n : ℕ) : seq hf U_mem n ∈ set_seq hf U_mem n :=
  some_spec$ hf.1.nonempty_of_mem (set_seq_mem hf U_mem n)

theorem seq_pair_mem ⦃N m n : ℕ⦄ (hm : N ≤ m) (hn : N ≤ n) : (seq hf U_mem m, seq hf U_mem n) ∈ U N :=
  set_seq_prod_subset hf U_mem hm hn ⟨seq_mem hf U_mem m, seq_mem hf U_mem n⟩

include U_le

theorem seq_is_cauchy_seq : CauchySeq$ seq hf U_mem :=
  cauchy_seq_of_controlled U U_le$ seq_pair_mem hf U_mem

-- error in Topology.UniformSpace.Cauchy: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If the sequence `sequentially_complete.seq` converges to `a`, then `f ≤ 𝓝 a`. -/
theorem le_nhds_of_seq_tendsto_nhds
{{a : α}}
(ha : tendsto (seq hf U_mem) at_top (expr𝓝() a)) : «expr ≤ »(f, expr𝓝() a) :=
le_nhds_of_cauchy_adhp_aux (begin
   assume [binders (s hs)],
   rcases [expr U_le s hs, "with", "⟨", ident m, ",", ident hm, "⟩"],
   rcases [expr tendsto_at_top'.1 ha _ (mem_nhds_left a (U_mem m)), "with", "⟨", ident n, ",", ident hn, "⟩"],
   refine [expr ⟨set_seq hf U_mem (max m n), set_seq_mem hf U_mem _, _, seq hf U_mem (max m n), _, seq_mem hf U_mem _⟩],
   { have [] [] [":=", expr le_max_left m n],
     exact [expr set.subset.trans (set_seq_prod_subset hf U_mem this this) hm] },
   { exact [expr hm «expr $ »(hn _, le_max_right m n)] }
 end)

end SequentiallyComplete

namespace UniformSpace

open SequentiallyComplete

variable[is_countably_generated (𝓤 α)]

-- error in Topology.UniformSpace.Cauchy: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- A uniform space is complete provided that (a) its uniformity filter has a countable basis;
(b) any sequence satisfying a "controlled" version of the Cauchy condition converges. -/
theorem complete_of_convergent_controlled_sequences
(U : exprℕ() → set «expr × »(α, α))
(U_mem : ∀ n, «expr ∈ »(U n, expr𝓤() α))
(HU : ∀
 u : exprℕ() → α, ∀
 N
 m
 n, «expr ≤ »(N, m) → «expr ≤ »(N, n) → «expr ∈ »((u m, u n), U N) → «expr∃ , »((a), tendsto u at_top (expr𝓝() a))) : complete_space α :=
begin
  obtain ["⟨", ident U', ",", ident U'_mono, ",", ident hU', "⟩", ":=", expr (expr𝓤() α).exists_antitone_seq],
  have [ident Hmem] [":", expr ∀ n, «expr ∈ »(«expr ∩ »(U n, U' n), expr𝓤() α)] [],
  from [expr λ n, inter_mem (U_mem n) (hU'.2 ⟨n, subset.refl _⟩)],
  refine [expr ⟨λ
    f hf, «expr $ »((HU (seq hf Hmem) (λ N m n hm hn, _)).imp, le_nhds_of_seq_tendsto_nhds _ _ (λ s hs, _))⟩],
  { rcases [expr hU'.1 hs, "with", "⟨", ident N, ",", ident hN, "⟩"],
    exact [expr ⟨N, subset.trans (inter_subset_right _ _) hN⟩] },
  { exact [expr inter_subset_left _ _ (seq_pair_mem hf Hmem hm hn)] }
end

/-- A sequentially complete uniform space with a countable basis of the uniformity filter is
complete. -/
theorem complete_of_cauchy_seq_tendsto (H' : ∀ (u : ℕ → α), CauchySeq u → ∃ a, tendsto u at_top (𝓝 a)) :
  CompleteSpace α :=
  let ⟨U', U'_mono, hU'⟩ := (𝓤 α).exists_antitone_seq 
  complete_of_convergent_controlled_sequences U' (fun n => hU'.2 ⟨n, subset.refl _⟩)
    fun u hu => H' u$ cauchy_seq_of_controlled U' (fun s hs => hU'.1 hs) hu

variable(α)

instance (priority := 100)first_countable_topology : first_countable_topology α :=
  ⟨fun a =>
      by 
        rw [nhds_eq_comap_uniformity]
        infer_instance⟩

/-- A separable uniform space with countably generated uniformity filter is second countable:
one obtains a countable basis by taking the balls centered at points in a dense subset,
and with rational "radii" from a countable open symmetric antitone basis of `𝓤 α`. We do not
register this as an instance, as there is already an instance going in the other direction
from second countable spaces to separable spaces, and we want to avoid loops. -/
theorem second_countable_of_separable [separable_space α] : second_countable_topology α :=
  by 
    rcases exists_countable_dense α with ⟨s, hsc, hsd⟩
    obtain
      ⟨t : ℕ → Set (α × α), hto : ∀ (i : ℕ), t i ∈ (𝓤 α).Sets ∧ IsOpen (t i) ∧ SymmetricRel (t i), h_basis :
        (𝓤 α).HasAntitoneBasis (fun _ => True) t⟩ :=
      (@uniformity_has_basis_open_symmetric α _).exists_antitone_subbasis 
    refine' ⟨⟨⋃(x : _)(_ : x ∈ s), range fun k => ball x (t k), hsc.bUnion fun x hx => countable_range _, _⟩⟩
    refine' (is_topological_basis_of_open_of_nhds _ _).eq_generate_from
    ·
      simp only [mem_bUnion_iff, mem_range]
      rintro _ ⟨x, hxs, k, rfl⟩
      exact is_open_ball x (hto k).2.1
    ·
      intro x V hxV hVo 
      simp only [mem_bUnion_iff, mem_range, exists_prop]
      rcases UniformSpace.mem_nhds_iff.1 (IsOpen.mem_nhds hVo hxV) with ⟨U, hU, hUV⟩
      rcases comp_symm_of_uniformity hU with ⟨U', hU', hsymm, hUU'⟩
      rcases h_basis.to_has_basis.mem_iff.1 hU' with ⟨k, -, hk⟩
      rcases
        hsd.inter_open_nonempty (ball x$ t k) (UniformSpace.is_open_ball x (hto k).2.1)
          ⟨x, UniformSpace.mem_ball_self _ (hto k).1⟩ with
        ⟨y, hxy, hys⟩
      refine' ⟨_, ⟨y, hys, k, rfl⟩, (hto k).2.2.Subset hxy, fun z hz => _⟩
      exact hUV (ball_subset_of_comp_subset (hk hxy) hUU' (hk hz))

end UniformSpace

