import Mathbin.Order.Filter.Cofinite

/-!
# liminfs and limsups of functions and filters

Defines the Liminf/Limsup of a function taking values in a conditionally complete lattice, with
respect to an arbitrary filter.

We define `f.Limsup` (`f.Liminf`) where `f` is a filter taking values in a conditionally complete
lattice. `f.Limsup` is the smallest element `a` such that, eventually, `u ≤ a` (and vice versa for
`f.Liminf`). To work with the Limsup along a function `u` use `(f.map u).Limsup`.

Usually, one defines the Limsup as `Inf (Sup s)` where the Inf is taken over all sets in the filter.
For instance, in ℕ along a function `u`, this is `Inf_n (Sup_{k ≥ n} u k)` (and the latter quantity
decreases with `n`, so this is in fact a limit.). There is however a difficulty: it is well possible
that `u` is not bounded on the whole space, only eventually (think of `Limsup (λx, 1/x)` on ℝ. Then
there is no guarantee that the quantity above really decreases (the value of the `Sup` beforehand is
not really well defined, as one can not use ∞), so that the Inf could be anything. So one can not
use this `Inf Sup ...` definition in conditionally complete lattices, and one has to use a less
tractable definition.

In conditionally complete lattices, the definition is only useful for filters which are eventually
bounded above (otherwise, the Limsup would morally be +∞, which does not belong to the space) and
which are frequently bounded below (otherwise, the Limsup would morally be -∞, which is not in the
space either). We start with definitions of these concepts for arbitrary filters, before turning to
the definitions of Limsup and Liminf.

In complete lattices, however, it coincides with the `Inf Sup` definition.
-/


open Filter Set

open_locale Filter

variable{α β ι : Type _}

namespace Filter

section Relation

/-- `f.is_bounded (≺)`: the filter `f` is eventually bounded w.r.t. the relation `≺`, i.e.
eventually, it is bounded by some uniform bound.
`r` will be usually instantiated with `≤` or `≥`. -/
def is_bounded (r : α → α → Prop) (f : Filter α) :=
  ∃ b, ∀ᶠx in f, r x b

/-- `f.is_bounded_under (≺) u`: the image of the filter `f` under `u` is eventually bounded w.r.t.
the relation `≺`, i.e. eventually, it is bounded by some uniform bound. -/
def is_bounded_under (r : α → α → Prop) (f : Filter β) (u : β → α) :=
  (f.map u).IsBounded r

variable{r : α → α → Prop}{f g : Filter α}

/-- `f` is eventually bounded if and only if, there exists an admissible set on which it is
bounded. -/
theorem is_bounded_iff : f.is_bounded r ↔ ∃ (s : _)(_ : s ∈ f.sets), ∃ b, s ⊆ { x | r x b } :=
  Iff.intro (fun ⟨b, hb⟩ => ⟨{ a | r a b }, hb, b, subset.refl _⟩) fun ⟨s, hs, b, hb⟩ => ⟨b, mem_of_superset hs hb⟩

/-- A bounded function `u` is in particular eventually bounded. -/
theorem is_bounded_under_of {f : Filter β} {u : β → α} : (∃ b, ∀ x, r (u x) b) → f.is_bounded_under r u
| ⟨b, hb⟩ => ⟨b, show ∀ᶠx in f, r (u x) b from eventually_of_forall hb⟩

theorem is_bounded_bot : is_bounded r ⊥ ↔ Nonempty α :=
  by 
    simp [is_bounded, exists_true_iff_nonempty]

theorem is_bounded_top : is_bounded r ⊤ ↔ ∃ t, ∀ x, r x t :=
  by 
    simp [is_bounded, eq_univ_iff_forall]

theorem is_bounded_principal (s : Set α) : is_bounded r (𝓟 s) ↔ ∃ t, ∀ x (_ : x ∈ s), r x t :=
  by 
    simp [is_bounded, subset_def]

theorem is_bounded_sup [IsTrans α r] (hr : ∀ b₁ b₂, ∃ b, r b₁ b ∧ r b₂ b) :
  is_bounded r f → is_bounded r g → is_bounded r (f⊔g)
| ⟨b₁, h₁⟩, ⟨b₂, h₂⟩ =>
  let ⟨b, rb₁b, rb₂b⟩ := hr b₁ b₂
  ⟨b, eventually_sup.mpr ⟨h₁.mono fun x h => trans h rb₁b, h₂.mono fun x h => trans h rb₂b⟩⟩

theorem is_bounded.mono (h : f ≤ g) : is_bounded r g → is_bounded r f
| ⟨b, hb⟩ => ⟨b, h hb⟩

theorem is_bounded_under.mono {f g : Filter β} {u : β → α} (h : f ≤ g) :
  g.is_bounded_under r u → f.is_bounded_under r u :=
  fun hg => hg.mono (map_mono h)

theorem is_bounded.is_bounded_under {q : β → β → Prop} {u : α → β} (hf : ∀ a₀ a₁, r a₀ a₁ → q (u a₀) (u a₁)) :
  f.is_bounded r → f.is_bounded_under q u
| ⟨b, h⟩ => ⟨u b, show ∀ᶠx in f, q (u x) (u b) from h.mono fun x => hf x b⟩

-- error in Order.LiminfLimsup: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem not_is_bounded_under_of_tendsto_at_top
[preorder β]
[no_top_order β]
{f : α → β}
{l : filter α}
[l.ne_bot]
(hf : tendsto f l at_top) : «expr¬ »(is_bounded_under ((«expr ≤ »)) l f) :=
begin
  rintro ["⟨", ident b, ",", ident hb, "⟩"],
  rw [expr eventually_map] ["at", ident hb],
  obtain ["⟨", ident b', ",", ident h, "⟩", ":=", expr no_top b],
  have [ident hb'] [] [":=", expr tendsto_at_top.mp hf b'],
  have [] [":", expr «expr = »(«expr ∩ »({x : α | «expr ≤ »(f x, b)}, {x : α | «expr ≤ »(b', f x)}), «expr∅»())] [":=", expr eq_empty_of_subset_empty (λ
    x hx, not_le_of_lt h (le_trans hx.2 hx.1))],
  exact [expr (nonempty_of_mem (hb.and hb')).ne_empty this]
end

theorem not_is_bounded_under_of_tendsto_at_bot [Preorderₓ β] [NoBotOrder β] {f : α → β} {l : Filter α} [l.ne_bot]
  (hf : tendsto f l at_bot) : ¬is_bounded_under (· ≥ ·) l f :=
  @not_is_bounded_under_of_tendsto_at_top α (OrderDual β) _ _ _ _ _ hf

-- error in Order.LiminfLimsup: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem is_bounded_under.bdd_above_range_of_cofinite
[semilattice_sup β]
{f : α → β}
(hf : is_bounded_under ((«expr ≤ »)) cofinite f) : bdd_above (range f) :=
begin
  rcases [expr hf, "with", "⟨", ident b, ",", ident hb, "⟩"],
  haveI [] [":", expr nonempty β] [":=", expr ⟨b⟩],
  rw ["[", "<-", expr image_univ, ",", "<-", expr union_compl_self {x | «expr ≤ »(f x, b)}, ",", expr image_union, ",", expr bdd_above_union, "]"] [],
  exact [expr ⟨⟨b, «expr $ »(ball_image_iff.2, λ x, id)⟩, (hb.image f).bdd_above⟩]
end

theorem is_bounded_under.bdd_below_range_of_cofinite [SemilatticeInf β] {f : α → β}
  (hf : is_bounded_under (· ≥ ·) cofinite f) : BddBelow (range f) :=
  @is_bounded_under.bdd_above_range_of_cofinite α (OrderDual β) _ _ hf

theorem is_bounded_under.bdd_above_range [SemilatticeSup β] {f : ℕ → β} (hf : is_bounded_under (· ≤ ·) at_top f) :
  BddAbove (range f) :=
  by 
    rw [←Nat.cofinite_eq_at_top] at hf 
    exact hf.bdd_above_range_of_cofinite

theorem is_bounded_under.bdd_below_range [SemilatticeInf β] {f : ℕ → β} (hf : is_bounded_under (· ≥ ·) at_top f) :
  BddBelow (range f) :=
  @is_bounded_under.bdd_above_range (OrderDual β) _ _ hf

/-- `is_cobounded (≺) f` states that the filter `f` does not tend to infinity w.r.t. `≺`. This is
also called frequently bounded. Will be usually instantiated with `≤` or `≥`.

There is a subtlety in this definition: we want `f.is_cobounded` to hold for any `f` in the case of
complete lattices. This will be relevant to deduce theorems on complete lattices from their
versions on conditionally complete lattices with additional assumptions. We have to be careful in
the edge case of the trivial filter containing the empty set: the other natural definition
  `¬ ∀ a, ∀ᶠ n in f, a ≤ n`
would not work as well in this case.
-/
def is_cobounded (r : α → α → Prop) (f : Filter α) :=
  ∃ b, ∀ a, (∀ᶠx in f, r x a) → r b a

/-- `is_cobounded_under (≺) f u` states that the image of the filter `f` under the map `u` does not
tend to infinity w.r.t. `≺`. This is also called frequently bounded. Will be usually instantiated
with `≤` or `≥`. -/
def is_cobounded_under (r : α → α → Prop) (f : Filter β) (u : β → α) :=
  (f.map u).IsCobounded r

/-- To check that a filter is frequently bounded, it suffices to have a witness
which bounds `f` at some point for every admissible set.

This is only an implication, as the other direction is wrong for the trivial filter.-/
theorem is_cobounded.mk [IsTrans α r] (a : α) (h : ∀ s (_ : s ∈ f), ∃ (x : _)(_ : x ∈ s), r a x) : f.is_cobounded r :=
  ⟨a,
    fun y s =>
      let ⟨x, h₁, h₂⟩ := h _ s 
      trans h₂ h₁⟩

/-- A filter which is eventually bounded is in particular frequently bounded (in the opposite
direction). At least if the filter is not trivial. -/
theorem is_bounded.is_cobounded_flip [IsTrans α r] [ne_bot f] : f.is_bounded r → f.is_cobounded (flip r)
| ⟨a, ha⟩ =>
  ⟨a,
    fun b hb =>
      let ⟨x, rxa, rbx⟩ := (ha.and hb).exists 
      show r b a from trans rbx rxa⟩

theorem is_bounded.is_cobounded_ge [Preorderₓ α] [ne_bot f] (h : f.is_bounded (· ≤ ·)) : f.is_cobounded (· ≥ ·) :=
  h.is_cobounded_flip

theorem is_bounded.is_cobounded_le [Preorderₓ α] [ne_bot f] (h : f.is_bounded (· ≥ ·)) : f.is_cobounded (· ≤ ·) :=
  h.is_cobounded_flip

theorem is_cobounded_bot : is_cobounded r ⊥ ↔ ∃ b, ∀ x, r b x :=
  by 
    simp [is_cobounded]

-- error in Order.LiminfLimsup: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem is_cobounded_top : «expr ↔ »(is_cobounded r «expr⊤»(), nonempty α) :=
by simp [] [] [] ["[", expr is_cobounded, ",", expr eq_univ_iff_forall, ",", expr exists_true_iff_nonempty, "]"] [] [] { contextual := tt }

theorem is_cobounded_principal (s : Set α) : (𝓟 s).IsCobounded r ↔ ∃ b, ∀ a, (∀ x (_ : x ∈ s), r x a) → r b a :=
  by 
    simp [is_cobounded, subset_def]

theorem is_cobounded.mono (h : f ≤ g) : f.is_cobounded r → g.is_cobounded r
| ⟨b, hb⟩ => ⟨b, fun a ha => hb a (h ha)⟩

end Relation

theorem is_cobounded_le_of_bot [Preorderₓ α] [OrderBot α] {f : Filter α} : f.is_cobounded (· ≤ ·) :=
  ⟨⊥, fun a h => bot_le⟩

theorem is_cobounded_ge_of_top [Preorderₓ α] [OrderTop α] {f : Filter α} : f.is_cobounded (· ≥ ·) :=
  ⟨⊤, fun a h => le_top⟩

theorem is_bounded_le_of_top [Preorderₓ α] [OrderTop α] {f : Filter α} : f.is_bounded (· ≤ ·) :=
  ⟨⊤, eventually_of_forall$ fun _ => le_top⟩

theorem is_bounded_ge_of_bot [Preorderₓ α] [OrderBot α] {f : Filter α} : f.is_bounded (· ≥ ·) :=
  ⟨⊥, eventually_of_forall$ fun _ => bot_le⟩

theorem is_bounded_under_sup [SemilatticeSup α] {f : Filter β} {u v : β → α} :
  f.is_bounded_under (· ≤ ·) u → f.is_bounded_under (· ≤ ·) v → f.is_bounded_under (· ≤ ·) fun a => u a⊔v a
| ⟨bu, (hu : ∀ᶠx in f, u x ≤ bu)⟩, ⟨bv, (hv : ∀ᶠx in f, v x ≤ bv)⟩ =>
  ⟨bu⊔bv,
    show ∀ᶠx in f, u x⊔v x ≤ bu⊔bv by 
      filterUpwards [hu, hv] fun x => sup_le_sup⟩

theorem is_bounded_under_inf [SemilatticeInf α] {f : Filter β} {u v : β → α} :
  f.is_bounded_under (· ≥ ·) u → f.is_bounded_under (· ≥ ·) v → f.is_bounded_under (· ≥ ·) fun a => u a⊓v a
| ⟨bu, (hu : ∀ᶠx in f, u x ≥ bu)⟩, ⟨bv, (hv : ∀ᶠx in f, v x ≥ bv)⟩ =>
  ⟨bu⊓bv,
    show ∀ᶠx in f, u x⊓v x ≥ bu⊓bv by 
      filterUpwards [hu, hv] fun x => inf_le_inf⟩

/-- Filters are automatically bounded or cobounded in complete lattices. To use the same statements
in complete and conditionally complete lattices but let automation fill automatically the
boundedness proofs in complete lattices, we use the tactic `is_bounded_default` in the statements,
in the form `(hf : f.is_bounded (≥) . is_bounded_default)`. -/
unsafe def is_bounded_default : tactic Unit :=
  tactic.applyc `` is_cobounded_le_of_bot <|>
    tactic.applyc `` is_cobounded_ge_of_top <|>
      tactic.applyc `` is_bounded_le_of_top <|> tactic.applyc `` is_bounded_ge_of_bot

section ConditionallyCompleteLattice

variable[ConditionallyCompleteLattice α]

/-- The `Limsup` of a filter `f` is the infimum of the `a` such that, eventually for `f`,
holds `x ≤ a`. -/
def Limsup (f : Filter α) : α :=
  Inf { a | ∀ᶠn in f, n ≤ a }

/-- The `Liminf` of a filter `f` is the supremum of the `a` such that, eventually for `f`,
holds `x ≥ a`. -/
def Liminf (f : Filter α) : α :=
  Sup { a | ∀ᶠn in f, a ≤ n }

/-- The `limsup` of a function `u` along a filter `f` is the infimum of the `a` such that,
eventually for `f`, holds `u x ≤ a`. -/
def limsup (f : Filter β) (u : β → α) : α :=
  (f.map u).limsup

/-- The `liminf` of a function `u` along a filter `f` is the supremum of the `a` such that,
eventually for `f`, holds `u x ≥ a`. -/
def liminf (f : Filter β) (u : β → α) : α :=
  (f.map u).liminf

section 

variable{f : Filter β}{u : β → α}

theorem limsup_eq : f.limsup u = Inf { a | ∀ᶠn in f, u n ≤ a } :=
  rfl

theorem liminf_eq : f.liminf u = Sup { a | ∀ᶠn in f, a ≤ u n } :=
  rfl

end 

theorem Limsup_le_of_le {f : Filter α} {a}
  (hf : f.is_cobounded (· ≤ ·) :=  by 
    runTac 
      is_bounded_default)
  (h : ∀ᶠn in f, n ≤ a) : f.Limsup ≤ a :=
  cInf_le hf h

theorem le_Liminf_of_le {f : Filter α} {a}
  (hf : f.is_cobounded (· ≥ ·) :=  by 
    runTac 
      is_bounded_default)
  (h : ∀ᶠn in f, a ≤ n) : a ≤ f.Liminf :=
  le_cSup hf h

theorem le_Limsup_of_le {f : Filter α} {a}
  (hf : f.is_bounded (· ≤ ·) :=  by 
    runTac 
      is_bounded_default)
  (h : ∀ b, (∀ᶠn in f, n ≤ b) → a ≤ b) : a ≤ f.Limsup :=
  le_cInf hf h

theorem Liminf_le_of_le {f : Filter α} {a}
  (hf : f.is_bounded (· ≥ ·) :=  by 
    runTac 
      is_bounded_default)
  (h : ∀ b, (∀ᶠn in f, b ≤ n) → b ≤ a) : f.Liminf ≤ a :=
  cSup_le hf h

theorem Liminf_le_Limsup {f : Filter α} [ne_bot f]
  (h₁ : f.is_bounded (· ≤ ·) :=  by 
    runTac 
      is_bounded_default)
  (h₂ : f.is_bounded (· ≥ ·) :=  by 
    runTac 
      is_bounded_default) :
  f.Liminf ≤ f.Limsup :=
  Liminf_le_of_le h₂$
    fun a₀ ha₀ =>
      le_Limsup_of_le h₁$
        fun a₁ ha₁ =>
          show a₀ ≤ a₁ from
            let ⟨b, hb₀, hb₁⟩ := (ha₀.and ha₁).exists 
            le_transₓ hb₀ hb₁

theorem Liminf_le_Liminf {f g : Filter α}
  (hf : f.is_bounded (· ≥ ·) :=  by 
    runTac 
      is_bounded_default)
  (hg : g.is_cobounded (· ≥ ·) :=  by 
    runTac 
      is_bounded_default)
  (h : ∀ a, (∀ᶠn in f, a ≤ n) → ∀ᶠn in g, a ≤ n) : f.Liminf ≤ g.Liminf :=
  cSup_le_cSup hg hf h

theorem Limsup_le_Limsup {f g : Filter α}
  (hf : f.is_cobounded (· ≤ ·) :=  by 
    runTac 
      is_bounded_default)
  (hg : g.is_bounded (· ≤ ·) :=  by 
    runTac 
      is_bounded_default)
  (h : ∀ a, (∀ᶠn in g, n ≤ a) → ∀ᶠn in f, n ≤ a) : f.Limsup ≤ g.Limsup :=
  cInf_le_cInf hf hg h

theorem Limsup_le_Limsup_of_le {f g : Filter α} (h : f ≤ g)
  (hf : f.is_cobounded (· ≤ ·) :=  by 
    runTac 
      is_bounded_default)
  (hg : g.is_bounded (· ≤ ·) :=  by 
    runTac 
      is_bounded_default) :
  f.Limsup ≤ g.Limsup :=
  Limsup_le_Limsup hf hg fun a ha => h ha

theorem Liminf_le_Liminf_of_le {f g : Filter α} (h : g ≤ f)
  (hf : f.is_bounded (· ≥ ·) :=  by 
    runTac 
      is_bounded_default)
  (hg : g.is_cobounded (· ≥ ·) :=  by 
    runTac 
      is_bounded_default) :
  f.Liminf ≤ g.Liminf :=
  Liminf_le_Liminf hf hg fun a ha => h ha

theorem limsup_le_limsup {α : Type _} [ConditionallyCompleteLattice β] {f : Filter α} {u v : α → β} (h : u ≤ᶠ[f] v)
  (hu : f.is_cobounded_under (· ≤ ·) u :=  by 
    runTac 
      is_bounded_default)
  (hv : f.is_bounded_under (· ≤ ·) v :=  by 
    runTac 
      is_bounded_default) :
  f.limsup u ≤ f.limsup v :=
  Limsup_le_Limsup hu hv$ fun b => h.trans

theorem liminf_le_liminf {α : Type _} [ConditionallyCompleteLattice β] {f : Filter α} {u v : α → β}
  (h : ∀ᶠa in f, u a ≤ v a)
  (hu : f.is_bounded_under (· ≥ ·) u :=  by 
    runTac 
      is_bounded_default)
  (hv : f.is_cobounded_under (· ≥ ·) v :=  by 
    runTac 
      is_bounded_default) :
  f.liminf u ≤ f.liminf v :=
  @limsup_le_limsup (OrderDual β) α _ _ _ _ h hv hu

theorem limsup_le_limsup_of_le {α β} [ConditionallyCompleteLattice β] {f g : Filter α} (h : f ≤ g) {u : α → β}
  (hf : f.is_cobounded_under (· ≤ ·) u :=  by 
    runTac 
      is_bounded_default)
  (hg : g.is_bounded_under (· ≤ ·) u :=  by 
    runTac 
      is_bounded_default) :
  f.limsup u ≤ g.limsup u :=
  Limsup_le_Limsup_of_le (map_mono h) hf hg

theorem liminf_le_liminf_of_le {α β} [ConditionallyCompleteLattice β] {f g : Filter α} (h : g ≤ f) {u : α → β}
  (hf : f.is_bounded_under (· ≥ ·) u :=  by 
    runTac 
      is_bounded_default)
  (hg : g.is_cobounded_under (· ≥ ·) u :=  by 
    runTac 
      is_bounded_default) :
  f.liminf u ≤ g.liminf u :=
  Liminf_le_Liminf_of_le (map_mono h) hf hg

theorem Limsup_principal {s : Set α} (h : BddAbove s) (hs : s.nonempty) : (𝓟 s).limsup = Sup s :=
  by 
    simp [Limsup] <;> exact cInf_upper_bounds_eq_cSup h hs

theorem Liminf_principal {s : Set α} (h : BddBelow s) (hs : s.nonempty) : (𝓟 s).liminf = Inf s :=
  @Limsup_principal (OrderDual α) _ s h hs

theorem limsup_congr {α : Type _} [ConditionallyCompleteLattice β] {f : Filter α} {u v : α → β}
  (h : ∀ᶠa in f, u a = v a) : limsup f u = limsup f v :=
  by 
    rw [limsup_eq]
    congr with b 
    exact
      eventually_congr
        (h.mono$
          fun x hx =>
            by 
              simp [hx])

theorem liminf_congr {α : Type _} [ConditionallyCompleteLattice β] {f : Filter α} {u v : α → β}
  (h : ∀ᶠa in f, u a = v a) : liminf f u = liminf f v :=
  @limsup_congr (OrderDual β) _ _ _ _ _ h

theorem limsup_const {α : Type _} [ConditionallyCompleteLattice β] {f : Filter α} [ne_bot f] (b : β) :
  (limsup f fun x => b) = b :=
  by 
    simpa only [limsup_eq, eventually_const] using cInf_Ici

theorem liminf_const {α : Type _} [ConditionallyCompleteLattice β] {f : Filter α} [ne_bot f] (b : β) :
  (liminf f fun x => b) = b :=
  @limsup_const (OrderDual β) α _ f _ b

theorem liminf_le_limsup {f : Filter β} [ne_bot f] {u : β → α}
  (h : f.is_bounded_under (· ≤ ·) u :=  by 
    runTac 
      is_bounded_default)
  (h' : f.is_bounded_under (· ≥ ·) u :=  by 
    runTac 
      is_bounded_default) :
  liminf f u ≤ limsup f u :=
  Liminf_le_Limsup h h'

end ConditionallyCompleteLattice

section CompleteLattice

variable[CompleteLattice α]

@[simp]
theorem Limsup_bot : (⊥ : Filter α).limsup = ⊥ :=
  bot_unique$
    Inf_le$
      by 
        simp 

@[simp]
theorem Liminf_bot : (⊥ : Filter α).liminf = ⊤ :=
  top_unique$
    le_Sup$
      by 
        simp 

@[simp]
theorem Limsup_top : (⊤ : Filter α).limsup = ⊤ :=
  top_unique$
    le_Inf$
      by 
        simp [eq_univ_iff_forall] <;> exact fun b hb => top_unique$ hb _

@[simp]
theorem Liminf_top : (⊤ : Filter α).liminf = ⊥ :=
  bot_unique$
    Sup_le$
      by 
        simp [eq_univ_iff_forall] <;> exact fun b hb => bot_unique$ hb _

-- error in Order.LiminfLimsup: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Same as limsup_const applied to `⊥` but without the `ne_bot f` assumption -/
theorem limsup_const_bot {f : filter β} : «expr = »(limsup f (λ x : β, («expr⊥»() : α)), («expr⊥»() : α)) :=
begin
  rw ["[", expr limsup_eq, ",", expr eq_bot_iff, "]"] [],
  exact [expr Inf_le (eventually_of_forall (λ x, le_refl _))]
end

-- error in Order.LiminfLimsup: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Same as limsup_const applied to `⊤` but without the `ne_bot f` assumption -/
theorem liminf_const_top {f : filter β} : «expr = »(liminf f (λ x : β, («expr⊤»() : α)), («expr⊤»() : α)) :=
@limsup_const_bot (order_dual α) β _ _

theorem has_basis.Limsup_eq_infi_Sup {ι} {p : ι → Prop} {s} {f : Filter α} (h : f.has_basis p s) :
  f.Limsup = ⨅(i : _)(hi : p i), Sup (s i) :=
  le_antisymmₓ (le_binfi$ fun i hi => Inf_le$ h.eventually_iff.2 ⟨i, hi, fun x => le_Sup⟩)
    (le_Inf$
      fun a ha =>
        let ⟨i, hi, ha⟩ := h.eventually_iff.1 ha 
        infi_le_of_le _$ infi_le_of_le hi$ Sup_le ha)

theorem has_basis.Liminf_eq_supr_Inf {p : ι → Prop} {s : ι → Set α} {f : Filter α} (h : f.has_basis p s) :
  f.Liminf = ⨆(i : _)(hi : p i), Inf (s i) :=
  @has_basis.Limsup_eq_infi_Sup (OrderDual α) _ _ _ _ _ h

theorem Limsup_eq_infi_Sup {f : Filter α} : f.Limsup = ⨅(s : _)(_ : s ∈ f), Sup s :=
  f.basis_sets.Limsup_eq_infi_Sup

theorem Liminf_eq_supr_Inf {f : Filter α} : f.Liminf = ⨆(s : _)(_ : s ∈ f), Inf s :=
  @Limsup_eq_infi_Sup (OrderDual α) _ _

/-- In a complete lattice, the limsup of a function is the infimum over sets `s` in the filter
of the supremum of the function over `s` -/
theorem limsup_eq_infi_supr {f : Filter β} {u : β → α} : f.limsup u = ⨅(s : _)(_ : s ∈ f), ⨆(a : _)(_ : a ∈ s), u a :=
  (f.basis_sets.map u).Limsup_eq_infi_Sup.trans$
    by 
      simp only [Sup_image, id]

theorem limsup_eq_infi_supr_of_nat {u : ℕ → α} : limsup at_top u = ⨅n : ℕ, ⨆(i : _)(_ : i ≥ n), u i :=
  (at_top_basis.map u).Limsup_eq_infi_Sup.trans$
    by 
      simp only [Sup_image, infi_const] <;> rfl

theorem limsup_eq_infi_supr_of_nat' {u : ℕ → α} : limsup at_top u = ⨅n : ℕ, ⨆i : ℕ, u (i+n) :=
  by 
    simp only [limsup_eq_infi_supr_of_nat, supr_ge_eq_supr_nat_add]

theorem has_basis.limsup_eq_infi_supr {p : ι → Prop} {s : ι → Set β} {f : Filter β} {u : β → α} (h : f.has_basis p s) :
  f.limsup u = ⨅(i : _)(hi : p i), ⨆(a : _)(_ : a ∈ s i), u a :=
  (h.map u).Limsup_eq_infi_Sup.trans$
    by 
      simp only [Sup_image, id]

/-- In a complete lattice, the liminf of a function is the infimum over sets `s` in the filter
of the supremum of the function over `s` -/
theorem liminf_eq_supr_infi {f : Filter β} {u : β → α} : f.liminf u = ⨆(s : _)(_ : s ∈ f), ⨅(a : _)(_ : a ∈ s), u a :=
  @limsup_eq_infi_supr (OrderDual α) β _ _ _

theorem liminf_eq_supr_infi_of_nat {u : ℕ → α} : liminf at_top u = ⨆n : ℕ, ⨅(i : _)(_ : i ≥ n), u i :=
  @limsup_eq_infi_supr_of_nat (OrderDual α) _ u

theorem liminf_eq_supr_infi_of_nat' {u : ℕ → α} : liminf at_top u = ⨆n : ℕ, ⨅i : ℕ, u (i+n) :=
  @limsup_eq_infi_supr_of_nat' (OrderDual α) _ _

theorem has_basis.liminf_eq_supr_infi {p : ι → Prop} {s : ι → Set β} {f : Filter β} {u : β → α} (h : f.has_basis p s) :
  f.liminf u = ⨆(i : _)(hi : p i), ⨅(a : _)(_ : a ∈ s i), u a :=
  @has_basis.limsup_eq_infi_supr (OrderDual α) _ _ _ _ _ _ _ h

@[simp]
theorem liminf_nat_add (f : ℕ → α) (k : ℕ) : (at_top.liminf fun i => f (i+k)) = at_top.liminf f :=
  by 
    simpRw [liminf_eq_supr_infi_of_nat]
    exact supr_infi_ge_nat_add f k

@[simp]
theorem limsup_nat_add (f : ℕ → α) (k : ℕ) : (at_top.limsup fun i => f (i+k)) = at_top.limsup f :=
  @liminf_nat_add (OrderDual α) _ f k

-- error in Order.LiminfLimsup: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem liminf_le_of_frequently_le'
{α β}
[complete_lattice β]
{f : filter α}
{u : α → β}
{x : β}
(h : «expr∃ᶠ in , »((a), f, «expr ≤ »(u a, x))) : «expr ≤ »(f.liminf u, x) :=
begin
  rw [expr liminf_eq] [],
  refine [expr Sup_le (λ b hb, _)],
  have [ident hbx] [":", expr «expr∃ᶠ in , »((a), f, «expr ≤ »(b, x))] [],
  { revert [ident h],
    rw ["[", "<-", expr not_imp_not, ",", expr not_frequently, ",", expr not_frequently, "]"] [],
    exact [expr λ h, hb.mp (h.mono (λ a hbx hba hax, hbx (hba.trans hax)))] },
  exact [expr hbx.exists.some_spec]
end

theorem le_limsup_of_frequently_le' {α β} [CompleteLattice β] {f : Filter α} {u : α → β} {x : β}
  (h : ∃ᶠa in f, x ≤ u a) : x ≤ f.limsup u :=
  @liminf_le_of_frequently_le' _ (OrderDual β) _ _ _ _ h

end CompleteLattice

section ConditionallyCompleteLinearOrder

theorem eventually_lt_of_lt_liminf {f : Filter α} [ConditionallyCompleteLinearOrder β] {u : α → β} {b : β}
  (h : b < liminf f u)
  (hu : f.is_bounded_under (· ≥ ·) u :=  by 
    runTac 
      is_bounded_default) :
  ∀ᶠa in f, b < u a :=
  by 
    obtain ⟨c, hc, hbc⟩ : ∃ (c : β)(hc : c ∈ { c:β | ∀ᶠn : α in f, c ≤ u n }), b < c := exists_lt_of_lt_cSup hu h 
    exact hc.mono fun x hx => lt_of_lt_of_leₓ hbc hx

theorem eventually_lt_of_limsup_lt {f : Filter α} [ConditionallyCompleteLinearOrder β] {u : α → β} {b : β}
  (h : limsup f u < b)
  (hu : f.is_bounded_under (· ≤ ·) u :=  by 
    runTac 
      is_bounded_default) :
  ∀ᶠa in f, u a < b :=
  @eventually_lt_of_lt_liminf _ (OrderDual β) _ _ _ _ h hu

theorem le_limsup_of_frequently_le {α β} [ConditionallyCompleteLinearOrder β] {f : Filter α} {u : α → β} {b : β}
  (hu_le : ∃ᶠx in f, b ≤ u x)
  (hu : f.is_bounded_under (· ≤ ·) u :=  by 
    runTac 
      is_bounded_default) :
  b ≤ f.limsup u :=
  by 
    revert hu_le 
    rw [←not_imp_not, not_frequently]
    simpRw [←lt_iff_not_geₓ]
    exact fun h => eventually_lt_of_limsup_lt h hu

theorem liminf_le_of_frequently_le {α β} [ConditionallyCompleteLinearOrder β] {f : Filter α} {u : α → β} {b : β}
  (hu_le : ∃ᶠx in f, u x ≤ b)
  (hu : f.is_bounded_under (· ≥ ·) u :=  by 
    runTac 
      is_bounded_default) :
  f.liminf u ≤ b :=
  @le_limsup_of_frequently_le _ (OrderDual β) _ f u b hu_le hu

theorem frequently_lt_of_lt_limsup {α β} [ConditionallyCompleteLinearOrder β] {f : Filter α} {u : α → β} {b : β}
  (hu : f.is_cobounded_under (· ≤ ·) u :=  by 
    runTac 
      is_bounded_default)
  (h : b < f.limsup u) : ∃ᶠx in f, b < u x :=
  by 
    contrapose! h 
    apply Limsup_le_of_le hu 
    simpa using h

theorem frequently_lt_of_liminf_lt {α β} [ConditionallyCompleteLinearOrder β] {f : Filter α} {u : α → β} {b : β}
  (hu : f.is_cobounded_under (· ≥ ·) u :=  by 
    runTac 
      is_bounded_default)
  (h : f.liminf u < b) : ∃ᶠx in f, u x < b :=
  @frequently_lt_of_lt_limsup _ (OrderDual β) _ f u b hu h

end ConditionallyCompleteLinearOrder

end Filter

section Order

open Filter

theorem GaloisConnection.l_limsup_le {α β γ} [ConditionallyCompleteLattice β] [ConditionallyCompleteLattice γ]
  {f : Filter α} {v : α → β} {l : β → γ} {u : γ → β} (gc : GaloisConnection l u)
  (hlv : f.is_bounded_under (· ≤ ·) fun x => l (v x) :=  by 
    runTac 
      is_bounded_default)
  (hv_co : f.is_cobounded_under (· ≤ ·) v :=  by 
    runTac 
      is_bounded_default) :
  l (f.limsup v) ≤ f.limsup fun x => l (v x) :=
  by 
    refine' le_Limsup_of_le hlv fun c hc => _ 
    rw [Filter.eventually_map] at hc 
    simpRw [gc _ _]  at hc⊢
    exact Limsup_le_of_le hv_co hc

-- error in Order.LiminfLimsup: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem order_iso.limsup_apply
{γ}
[conditionally_complete_lattice β]
[conditionally_complete_lattice γ]
{f : filter α}
{u : α → β}
(g : «expr ≃o »(β, γ))
(hu : f.is_bounded_under ((«expr ≤ »)) u . is_bounded_default)
(hu_co : f.is_cobounded_under ((«expr ≤ »)) u . is_bounded_default)
(hgu : f.is_bounded_under ((«expr ≤ »)) (λ x, g (u x)) . is_bounded_default)
(hgu_co : f.is_cobounded_under ((«expr ≤ »)) (λ
  x, g (u x)) . is_bounded_default) : «expr = »(g (f.limsup u), f.limsup (λ x, g (u x))) :=
begin
  refine [expr le_antisymm (g.to_galois_connection.l_limsup_le hgu hu_co) _],
  rw ["[", "<-", expr g.symm.symm_apply_apply (f.limsup (λ x : α, g (u x))), ",", expr g.symm_symm, "]"] [],
  refine [expr g.monotone _],
  have [ident hf] [":", expr «expr = »(u, λ i, g.symm (g (u i)))] [],
  from [expr funext (λ i, (g.symm_apply_apply (u i)).symm)],
  nth_rewrite [0] [expr hf] [],
  refine [expr g.symm.to_galois_connection.l_limsup_le _ hgu_co],
  simp_rw [expr g.symm_apply_apply] [],
  exact [expr hu]
end

theorem OrderIso.liminf_apply {γ} [ConditionallyCompleteLattice β] [ConditionallyCompleteLattice γ] {f : Filter α}
  {u : α → β} (g : β ≃o γ)
  (hu : f.is_bounded_under (· ≥ ·) u :=  by 
    runTac 
      is_bounded_default)
  (hu_co : f.is_cobounded_under (· ≥ ·) u :=  by 
    runTac 
      is_bounded_default)
  (hgu : f.is_bounded_under (· ≥ ·) fun x => g (u x) :=  by 
    runTac 
      is_bounded_default)
  (hgu_co : f.is_cobounded_under (· ≥ ·) fun x => g (u x) :=  by 
    runTac 
      is_bounded_default) :
  g (f.liminf u) = f.liminf fun x => g (u x) :=
  @OrderIso.limsup_apply α (OrderDual β) (OrderDual γ) _ _ f u g.dual hu hu_co hgu hgu_co

end Order

