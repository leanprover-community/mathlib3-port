import Mathbin.Topology.Separation 
import Mathbin.Topology.Bases

/-!
# Dense embeddings

This file defines three properties of functions:

* `dense_range f`      means `f` has dense image;
* `dense_inducing i`   means `i` is also `inducing`;
* `dense_embedding e`  means `e` is also an `embedding`.

The main theorem `continuous_extend` gives a criterion for a function
`f : X → Z` to a regular (T₃) space Z to extend along a dense embedding
`i : X → Y` to a continuous function `g : Y → Z`. Actually `i` only
has to be `dense_inducing` (not necessarily injective).

-/


noncomputable theory

open Set Filter

open_locale Classical TopologicalSpace Filter

variable{α : Type _}{β : Type _}{γ : Type _}{δ : Type _}

/-- `i : α → β` is "dense inducing" if it has dense range and the topology on `α`
  is the one induced by `i` from the topology on `β`. -/
@[protectProj]
structure DenseInducing[TopologicalSpace α][TopologicalSpace β](i : α → β) extends Inducing i : Prop where 
  dense : DenseRange i

namespace DenseInducing

variable[TopologicalSpace α][TopologicalSpace β]

variable{i : α → β}(di : DenseInducing i)

theorem nhds_eq_comap (di : DenseInducing i) : ∀ (a : α), 𝓝 a = comap i (𝓝$ i a) :=
  di.to_inducing.nhds_eq_comap

protected theorem Continuous (di : DenseInducing i) : Continuous i :=
  di.to_inducing.continuous

theorem closure_range : Closure (range i) = univ :=
  di.dense.closure_range

theorem PreconnectedSpace [PreconnectedSpace α] (di : DenseInducing i) : PreconnectedSpace β :=
  di.dense.preconnected_space di.continuous

theorem closure_image_mem_nhds {s : Set α} {a : α} (di : DenseInducing i) (hs : s ∈ 𝓝 a) : Closure (i '' s) ∈ 𝓝 (i a) :=
  by 
    rw [di.nhds_eq_comap a, ((nhds_basis_opens _).comap _).mem_iff] at hs 
    rcases hs with ⟨U, ⟨haU, hUo⟩, sub : i ⁻¹' U ⊆ s⟩
    refine' mem_of_superset (hUo.mem_nhds haU) _ 
    calc U ⊆ Closure (i '' (i ⁻¹' U)) := di.dense.subset_closure_image_preimage_of_is_open hUo _ ⊆ Closure (i '' s) :=
      closure_mono (image_subset i sub)

theorem dense_image (di : DenseInducing i) {s : Set α} : Dense (i '' s) ↔ Dense s :=
  by 
    refine' ⟨fun H x => _, di.dense.dense_image di.continuous⟩
    rw [di.to_inducing.closure_eq_preimage_closure_image, H.closure_eq, preimage_univ]
    trivial

-- error in Topology.DenseEmbedding: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- The product of two dense inducings is a dense inducing -/
protected
theorem prod
[topological_space γ]
[topological_space δ]
{e₁ : α → β}
{e₂ : γ → δ}
(de₁ : dense_inducing e₁)
(de₂ : dense_inducing e₂) : dense_inducing (λ p : «expr × »(α, γ), (e₁ p.1, e₂ p.2)) :=
{ induced := (de₁.to_inducing.prod_mk de₂.to_inducing).induced, dense := de₁.dense.prod_map de₂.dense }

open TopologicalSpace

/-- If the domain of a `dense_inducing` map is a separable space, then so is the codomain. -/
protected theorem separable_space [separable_space α] : separable_space β :=
  di.dense.separable_space di.continuous

variable[TopologicalSpace δ]{f : γ → α}{g : γ → δ}{h : δ → β}

-- error in Topology.DenseEmbedding: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
 γ -f→ α
g↓     ↓e
 δ -h→ β
-/
theorem tendsto_comap_nhds_nhds
{d : δ}
{a : α}
(di : dense_inducing i)
(H : tendsto h (expr𝓝() d) (expr𝓝() (i a)))
(comm : «expr = »(«expr ∘ »(h, g), «expr ∘ »(i, f))) : tendsto f (comap g (expr𝓝() d)) (expr𝓝() a) :=
begin
  have [ident lim1] [":", expr «expr ≤ »(map g (comap g (expr𝓝() d)), expr𝓝() d)] [":=", expr map_comap_le],
  replace [ident lim1] [":", expr «expr ≤ »(map h (map g (comap g (expr𝓝() d))), map h (expr𝓝() d))] [":=", expr map_mono lim1],
  rw ["[", expr filter.map_map, ",", expr comm, ",", "<-", expr filter.map_map, ",", expr map_le_iff_le_comap, "]"] ["at", ident lim1],
  have [ident lim2] [":", expr «expr ≤ »(comap i (map h (expr𝓝() d)), comap i (expr𝓝() (i a)))] [":=", expr comap_mono H],
  rw ["<-", expr di.nhds_eq_comap] ["at", ident lim2],
  exact [expr le_trans lim1 lim2]
end

protected theorem nhds_within_ne_bot (di : DenseInducing i) (b : β) : ne_bot (𝓝[range i] b) :=
  di.dense.nhds_within_ne_bot b

theorem comap_nhds_ne_bot (di : DenseInducing i) (b : β) : ne_bot (comap i (𝓝 b)) :=
  comap_ne_bot$
    fun s hs =>
      let ⟨_, ⟨ha, a, rfl⟩⟩ := mem_closure_iff_nhds.1 (di.dense b) s hs
      ⟨a, ha⟩

variable[TopologicalSpace γ]

/-- If `i : α → β` is a dense inducing, then any function `f : α → γ` "extends"
  to a function `g = extend di f : β → γ`. If `γ` is Hausdorff and `f` has a
  continuous extension, then `g` is the unique such extension. In general,
  `g` might not be continuous or even extend `f`. -/
def extend (di : DenseInducing i) (f : α → γ) (b : β) : γ :=
  @limₓ _ ⟨f (di.dense.some b)⟩ (comap i (𝓝 b)) f

-- error in Topology.DenseEmbedding: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem extend_eq_of_tendsto
[t2_space γ]
{b : β}
{c : γ}
{f : α → γ}
(hf : tendsto f (comap i (expr𝓝() b)) (expr𝓝() c)) : «expr = »(di.extend f b, c) :=
by haveI [] [] [":=", expr di.comap_nhds_ne_bot]; exact [expr hf.lim_eq]

theorem extend_eq_at [T2Space γ] {f : α → γ} {a : α} (hf : ContinuousAt f a) : di.extend f (i a) = f a :=
  extend_eq_of_tendsto _$ di.nhds_eq_comap a ▸ hf

theorem extend_eq_at' [T2Space γ] {f : α → γ} {a : α} (c : γ) (hf : tendsto f (𝓝 a) (𝓝 c)) : di.extend f (i a) = f a :=
  di.extend_eq_at (continuous_at_of_tendsto_nhds hf)

theorem extend_eq [T2Space γ] {f : α → γ} (hf : Continuous f) (a : α) : di.extend f (i a) = f a :=
  di.extend_eq_at hf.continuous_at

/-- Variation of `extend_eq` where we ask that `f` has a limit along `comap i (𝓝 b)` for each
`b : β`. This is a strictly stronger assumption than continuity of `f`, but in a lot of cases
you'd have to prove it anyway to use `continuous_extend`, so this avoids doing the work twice. -/
theorem extend_eq' [T2Space γ] {f : α → γ} (di : DenseInducing i) (hf : ∀ b, ∃ c, tendsto f (comap i (𝓝 b)) (𝓝 c))
  (a : α) : di.extend f (i a) = f a :=
  by 
    rcases hf (i a) with ⟨b, hb⟩
    refine' di.extend_eq_at' b _ 
    rwa [←di.to_inducing.nhds_eq_comap] at hb

theorem extend_unique_at [T2Space γ] {b : β} {f : α → γ} {g : β → γ} (di : DenseInducing i)
  (hf : ∀ᶠx in comap i (𝓝 b), g (i x) = f x) (hg : ContinuousAt g b) : di.extend f b = g b :=
  by 
    refine' di.extend_eq_of_tendsto fun s hs => mem_map.2 _ 
    suffices  : ∀ᶠx : α in comap i (𝓝 b), g (i x) ∈ s 
    exact hf.mp (this.mono$ fun x hgx hfx => hfx ▸ hgx)
    clear hf f 
    refine' eventually_comap.2 ((hg.eventually hs).mono _)
    rintro _ hxs x rfl 
    exact hxs

theorem extend_unique [T2Space γ] {f : α → γ} {g : β → γ} (di : DenseInducing i) (hf : ∀ x, g (i x) = f x)
  (hg : Continuous g) : di.extend f = g :=
  funext$ fun b => extend_unique_at di (eventually_of_forall hf) hg.continuous_at

-- error in Topology.DenseEmbedding: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem continuous_at_extend
[regular_space γ]
{b : β}
{f : α → γ}
(di : dense_inducing i)
(hf : «expr∀ᶠ in , »((x), expr𝓝() b, «expr∃ , »((c), tendsto f «expr $ »(comap i, expr𝓝() x) (expr𝓝() c)))) : continuous_at (di.extend f) b :=
begin
  set [] [ident φ] [] [":="] [expr di.extend f] [],
  haveI [] [] [":=", expr di.comap_nhds_ne_bot],
  suffices [] [":", expr ∀ V' «expr ∈ » expr𝓝() (φ b), is_closed V' → «expr ∈ »(«expr ⁻¹' »(φ, V'), expr𝓝() b)],
  by simpa [] [] [] ["[", expr continuous_at, ",", expr (closed_nhds_basis _).tendsto_right_iff, "]"] [] [],
  intros [ident V', ident V'_in, ident V'_closed],
  set [] [ident V₁] [] [":="] [expr {x | tendsto f «expr $ »(comap i, expr𝓝() x) «expr $ »(expr𝓝(), φ x)}] [],
  have [ident V₁_in] [":", expr «expr ∈ »(V₁, expr𝓝() b)] [],
  { filter_upwards ["[", expr hf, "]"] [],
    rintros [ident x, "⟨", ident c, ",", ident hc, "⟩"],
    dsimp [] ["[", expr V₁, ",", expr φ, "]"] [] [],
    rwa [expr di.extend_eq_of_tendsto hc] [] },
  obtain ["⟨", ident V₂, ",", ident V₂_in, ",", ident V₂_op, ",", ident hV₂, "⟩", ":", expr «expr∃ , »((V₂ «expr ∈ » expr𝓝() b), «expr ∧ »(is_open V₂, ∀
     x «expr ∈ » «expr ⁻¹' »(i, V₂), «expr ∈ »(f x, V')))],
  { simpa [] [] [] ["[", expr and_assoc, "]"] [] ["using", expr ((nhds_basis_opens' b).comap i).tendsto_left_iff.mp (mem_of_mem_nhds V₁_in : «expr ∈ »(b, V₁)) V' V'_in] },
  suffices [] [":", expr ∀ x «expr ∈ » «expr ∩ »(V₁, V₂), «expr ∈ »(φ x, V')],
  { filter_upwards ["[", expr inter_mem V₁_in V₂_in, "]"] [],
    exact [expr this] },
  rintros [ident x, "⟨", ident x_in₁, ",", ident x_in₂, "⟩"],
  have [ident hV₂x] [":", expr «expr ∈ »(V₂, expr𝓝() x)] [":=", expr is_open.mem_nhds V₂_op x_in₂],
  apply [expr V'_closed.mem_of_tendsto x_in₁],
  use [expr V₂],
  tauto []
end

theorem continuous_extend [RegularSpace γ] {f : α → γ} (di : DenseInducing i)
  (hf : ∀ b, ∃ c, tendsto f (comap i (𝓝 b)) (𝓝 c)) : Continuous (di.extend f) :=
  continuous_iff_continuous_at.mpr$ fun b => di.continuous_at_extend$ univ_mem' hf

theorem mk' (i : α → β) (c : Continuous i) (dense : ∀ x, x ∈ Closure (range i))
  (H : ∀ (a : α) s (_ : s ∈ 𝓝 a), ∃ (t : _)(_ : t ∈ 𝓝 (i a)), ∀ b, i b ∈ t → b ∈ s) : DenseInducing i :=
  { induced :=
      (induced_iff_nhds_eq i).2$
        fun a =>
          le_antisymmₓ (tendsto_iff_comap.1$ c.tendsto _)
            (by 
              simpa [Filter.le_def] using H a),
    dense }

end DenseInducing

/-- A dense embedding is an embedding with dense image. -/
structure DenseEmbedding[TopologicalSpace α][TopologicalSpace β](e : α → β) extends DenseInducing e : Prop where 
  inj : Function.Injective e

theorem DenseEmbedding.mk' [TopologicalSpace α] [TopologicalSpace β] (e : α → β) (c : Continuous e)
  (dense : DenseRange e) (inj : Function.Injective e)
  (H : ∀ (a : α) s (_ : s ∈ 𝓝 a), ∃ (t : _)(_ : t ∈ 𝓝 (e a)), ∀ b, e b ∈ t → b ∈ s) : DenseEmbedding e :=
  { DenseInducing.mk' e c Dense H with inj }

namespace DenseEmbedding

open TopologicalSpace

variable[TopologicalSpace α][TopologicalSpace β][TopologicalSpace γ][TopologicalSpace δ]

variable{e : α → β}(de : DenseEmbedding e)

theorem inj_iff {x y} : e x = e y ↔ x = y :=
  de.inj.eq_iff

theorem to_embedding : Embedding e :=
  { induced := de.induced, inj := de.inj }

/-- If the domain of a `dense_embedding` is a separable space, then so is its codomain. -/
protected theorem separable_space [separable_space α] : separable_space β :=
  de.to_dense_inducing.separable_space

-- error in Topology.DenseEmbedding: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- The product of two dense embeddings is a dense embedding. -/
protected
theorem prod
{e₁ : α → β}
{e₂ : γ → δ}
(de₁ : dense_embedding e₁)
(de₂ : dense_embedding e₂) : dense_embedding (λ p : «expr × »(α, γ), (e₁ p.1, e₂ p.2)) :=
{ inj := assume ⟨x₁, x₂⟩ ⟨y₁, y₂⟩, by simp [] [] [] [] [] []; exact [expr assume h₁ h₂, ⟨de₁.inj h₁, de₂.inj h₂⟩],
  ..dense_inducing.prod de₁.to_dense_inducing de₂.to_dense_inducing }

/-- The dense embedding of a subtype inside its closure. -/
@[simps]
def subtype_emb {α : Type _} (p : α → Prop) (e : α → β) (x : { x // p x }) : { x // x ∈ Closure (e '' { x | p x }) } :=
  ⟨e x, subset_closure$ mem_image_of_mem e x.prop⟩

protected theorem Subtype (p : α → Prop) : DenseEmbedding (subtype_emb p e) :=
  { dense :=
      dense_iff_closure_eq.2$
        by 
          ext ⟨x, hx⟩
          rw [image_eq_range] at hx 
          simpa [closure_subtype, ←range_comp, · ∘ ·],
    inj := (de.inj.comp Subtype.coe_injective).codRestrict _,
    induced :=
      (induced_iff_nhds_eq _).2
        fun ⟨x, hx⟩ =>
          by 
            simp [subtype_emb, nhds_subtype_eq_comap, de.to_inducing.nhds_eq_comap, comap_comap, · ∘ ·] }

theorem dense_image {s : Set α} : Dense (e '' s) ↔ Dense s :=
  de.to_dense_inducing.dense_image

end DenseEmbedding

theorem Dense.dense_embedding_coe [TopologicalSpace α] {s : Set α} (hs : Dense s) : DenseEmbedding (coeₓ : s → α) :=
  { embedding_subtype_coe with dense := hs.dense_range_coe }

theorem is_closed_property [TopologicalSpace β] {e : α → β} {p : β → Prop} (he : DenseRange e)
  (hp : IsClosed { x | p x }) (h : ∀ a, p (e a)) : ∀ b, p b :=
  have  : univ ⊆ { b | p b } :=
    calc univ = Closure (range e) := he.closure_range.symm 
      _ ⊆ Closure { b | p b } := closure_mono$ range_subset_iff.mpr h 
      _ = _ := hp.closure_eq 
      
  fun b => this trivialₓ

theorem is_closed_property2 [TopologicalSpace β] {e : α → β} {p : β → β → Prop} (he : DenseRange e)
  (hp : IsClosed { q:β × β | p q.1 q.2 }) (h : ∀ a₁ a₂, p (e a₁) (e a₂)) : ∀ b₁ b₂, p b₁ b₂ :=
  have  : ∀ (q : β × β), p q.1 q.2 := is_closed_property (he.prod_map he) hp$ fun _ => h _ _ 
  fun b₁ b₂ => this ⟨b₁, b₂⟩

theorem is_closed_property3 [TopologicalSpace β] {e : α → β} {p : β → β → β → Prop} (he : DenseRange e)
  (hp : IsClosed { q:β × β × β | p q.1 q.2.1 q.2.2 }) (h : ∀ a₁ a₂ a₃, p (e a₁) (e a₂) (e a₃)) :
  ∀ b₁ b₂ b₃, p b₁ b₂ b₃ :=
  have  : ∀ (q : β × β × β), p q.1 q.2.1 q.2.2 := is_closed_property (he.prod_map$ he.prod_map he) hp$ fun _ => h _ _ _ 
  fun b₁ b₂ b₃ => this ⟨b₁, b₂, b₃⟩

@[elab_as_eliminator]
theorem DenseRange.induction_on [TopologicalSpace β] {e : α → β} (he : DenseRange e) {p : β → Prop} (b₀ : β)
  (hp : IsClosed { b | p b }) (ih : ∀ (a : α), p$ e a) : p b₀ :=
  is_closed_property he hp ih b₀

@[elab_as_eliminator]
theorem DenseRange.induction_on₂ [TopologicalSpace β] {e : α → β} {p : β → β → Prop} (he : DenseRange e)
  (hp : IsClosed { q:β × β | p q.1 q.2 }) (h : ∀ a₁ a₂, p (e a₁) (e a₂)) (b₁ b₂ : β) : p b₁ b₂ :=
  is_closed_property2 he hp h _ _

@[elab_as_eliminator]
theorem DenseRange.induction_on₃ [TopologicalSpace β] {e : α → β} {p : β → β → β → Prop} (he : DenseRange e)
  (hp : IsClosed { q:β × β × β | p q.1 q.2.1 q.2.2 }) (h : ∀ a₁ a₂ a₃, p (e a₁) (e a₂) (e a₃)) (b₁ b₂ b₃ : β) :
  p b₁ b₂ b₃ :=
  is_closed_property3 he hp h _ _ _

section 

variable[TopologicalSpace β][TopologicalSpace γ][T2Space γ]

variable{f : α → β}

/-- Two continuous functions to a t2-space that agree on the dense range of a function are equal. -/
theorem DenseRange.equalizer (hfd : DenseRange f) {g h : β → γ} (hg : Continuous g) (hh : Continuous h)
  (H : (g ∘ f) = (h ∘ f)) : g = h :=
  funext$ fun y => hfd.induction_on y (is_closed_eq hg hh)$ congr_funₓ H

end 

