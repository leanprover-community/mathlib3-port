import Mathbin.Algebra.IndicatorFunction 
import Mathbin.Data.Equiv.Fin 
import Mathbin.Data.Tprod 
import Mathbin.GroupTheory.Coset 
import Mathbin.MeasureTheory.MeasurableSpaceDef 
import Mathbin.MeasureTheory.Tactic 
import Mathbin.Order.Filter.Lift

/-!
# Measurable spaces and measurable functions

This file provides properties of measurable spaces and the functions and isomorphisms
between them. The definition of a measurable space is in `measure_theory.measurable_space_def`.

A measurable space is a set equipped with a σ-algebra, a collection of
subsets closed under complementation and countable union. A function
between measurable spaces is measurable if the preimage of each
measurable subset is measurable.

σ-algebras on a fixed set `α` form a complete lattice. Here we order
σ-algebras by writing `m₁ ≤ m₂` if every set which is `m₁`-measurable is
also `m₂`-measurable (that is, `m₁` is a subset of `m₂`). In particular, any
collection of subsets of `α` generates a smallest σ-algebra which
contains all of them. A function `f : α → β` induces a Galois connection
between the lattices of σ-algebras on `α` and `β`.

A measurable equivalence between measurable spaces is an equivalence
which respects the σ-algebras, that is, for which both directions of
the equivalence are measurable functions.

We say that a filter `f` is measurably generated if every set `s ∈ f` includes a measurable
set `t ∈ f`. This property is useful, e.g., to extract a measurable witness of `filter.eventually`.

## Notation

* We write `α ≃ᵐ β` for measurable equivalences between the measurable spaces `α` and `β`.
  This should not be confused with `≃ₘ` which is used for diffeomorphisms between manifolds.

## Implementation notes

Measurability of a function `f : α → β` between measurable spaces is
defined in terms of the Galois connection induced by f.

## References

* <https://en.wikipedia.org/wiki/Measurable_space>
* <https://en.wikipedia.org/wiki/Sigma-algebra>
* <https://en.wikipedia.org/wiki/Dynkin_system>

## Tags

measurable space, σ-algebra, measurable function, measurable equivalence, dynkin system,
π-λ theorem, π-system
-/


open Set Encodable Function Equiv

open_locale Classical Filter

variable{α β γ δ δ' : Type _}{ι : Sort _}{s t u : Set α}

namespace MeasurableSpace

section Functors

variable{m m₁ m₂ : MeasurableSpace α}{m' : MeasurableSpace β}{f : α → β}{g : β → α}

/-- The forward image of a measurable space under a function. `map f m` contains the sets
  `s : set β` whose preimage under `f` is measurable. -/
protected def map (f : α → β) (m : MeasurableSpace α) : MeasurableSpace β :=
  { MeasurableSet' := fun s => m.measurable_set'$ f ⁻¹' s, measurable_set_empty := m.measurable_set_empty,
    measurable_set_compl := fun s hs => m.measurable_set_compl _ hs,
    measurable_set_Union :=
      fun f hf =>
        by 
          rw [preimage_Union]
          exact m.measurable_set_Union _ hf }

@[simp]
theorem map_id : m.map id = m :=
  MeasurableSpace.ext$ fun s => Iff.rfl

@[simp]
theorem map_comp {f : α → β} {g : β → γ} : (m.map f).map g = m.map (g ∘ f) :=
  MeasurableSpace.ext$ fun s => Iff.rfl

/-- The reverse image of a measurable space under a function. `comap f m` contains the sets
  `s : set α` such that `s` is the `f`-preimage of a measurable set in `β`. -/
protected def comap (f : α → β) (m : MeasurableSpace β) : MeasurableSpace α :=
  { MeasurableSet' := fun s => ∃ s', m.measurable_set' s' ∧ f ⁻¹' s' = s,
    measurable_set_empty := ⟨∅, m.measurable_set_empty, rfl⟩,
    measurable_set_compl := fun s ⟨s', h₁, h₂⟩ => ⟨«expr ᶜ» s', m.measurable_set_compl _ h₁, h₂ ▸ rfl⟩,
    measurable_set_Union :=
      fun s hs =>
        let ⟨s', hs'⟩ := Classical.axiom_of_choice hs
        ⟨⋃i, s' i, m.measurable_set_Union _ fun i => (hs' i).left,
          by 
            simp [hs']⟩ }

@[simp]
theorem comap_id : m.comap id = m :=
  MeasurableSpace.ext$ fun s => ⟨fun ⟨s', hs', h⟩ => h ▸ hs', fun h => ⟨s, h, rfl⟩⟩

@[simp]
theorem comap_comp {f : β → α} {g : γ → β} : (m.comap f).comap g = m.comap (f ∘ g) :=
  MeasurableSpace.ext$
    fun s => ⟨fun ⟨t, ⟨u, h, hu⟩, ht⟩ => ⟨u, h, ht ▸ hu ▸ rfl⟩, fun ⟨t, h, ht⟩ => ⟨f ⁻¹' t, ⟨_, h, rfl⟩, ht⟩⟩

theorem comap_le_iff_le_map {f : α → β} : m'.comap f ≤ m ↔ m' ≤ m.map f :=
  ⟨fun h s hs => h _ ⟨_, hs, rfl⟩, fun h s ⟨t, ht, HEq⟩ => HEq ▸ h _ ht⟩

theorem gc_comap_map (f : α → β) : GaloisConnection (MeasurableSpace.comap f) (MeasurableSpace.map f) :=
  fun f g => comap_le_iff_le_map

theorem map_mono (h : m₁ ≤ m₂) : m₁.map f ≤ m₂.map f :=
  (gc_comap_map f).monotone_u h

theorem monotone_map : Monotone (MeasurableSpace.map f) :=
  fun a b h => map_mono h

theorem comap_mono (h : m₁ ≤ m₂) : m₁.comap g ≤ m₂.comap g :=
  (gc_comap_map g).monotone_l h

theorem monotone_comap : Monotone (MeasurableSpace.comap g) :=
  fun a b h => comap_mono h

@[simp]
theorem comap_bot : (⊥ : MeasurableSpace α).comap g = ⊥ :=
  (gc_comap_map g).l_bot

@[simp]
theorem comap_sup : (m₁⊔m₂).comap g = m₁.comap g⊔m₂.comap g :=
  (gc_comap_map g).l_sup

@[simp]
theorem comap_supr {m : ι → MeasurableSpace α} : (⨆i, m i).comap g = ⨆i, (m i).comap g :=
  (gc_comap_map g).l_supr

@[simp]
theorem map_top : (⊤ : MeasurableSpace α).map f = ⊤ :=
  (gc_comap_map f).u_top

@[simp]
theorem map_inf : (m₁⊓m₂).map f = m₁.map f⊓m₂.map f :=
  (gc_comap_map f).u_inf

@[simp]
theorem map_infi {m : ι → MeasurableSpace α} : (⨅i, m i).map f = ⨅i, (m i).map f :=
  (gc_comap_map f).u_infi

theorem comap_map_le : (m.map f).comap f ≤ m :=
  (gc_comap_map f).l_u_le _

theorem le_map_comap : m ≤ (m.comap g).map g :=
  (gc_comap_map g).le_u_l _

end Functors

@[mono]
theorem generate_from_mono {s t : Set (Set α)} (h : s ⊆ t) : generate_from s ≤ generate_from t :=
  giGenerateFrom.gc.monotone_l h

theorem generate_from_sup_generate_from {s t : Set (Set α)} : generate_from s⊔generate_from t = generate_from (s ∪ t) :=
  (@giGenerateFrom α).gc.l_sup.symm

theorem comap_generate_from {f : α → β} {s : Set (Set β)} :
  (generate_from s).comap f = generate_from (preimage f '' s) :=
  le_antisymmₓ
    (comap_le_iff_le_map.2$ generate_from_le$ fun t hts => generate_measurable.basic _$ mem_image_of_mem _$ hts)
    (generate_from_le$ fun t ⟨u, hu, Eq⟩ => Eq ▸ ⟨u, generate_measurable.basic _ hu, rfl⟩)

end MeasurableSpace

section MeasurableFunctions

open MeasurableSpace

theorem measurable_iff_le_map {m₁ : MeasurableSpace α} {m₂ : MeasurableSpace β} {f : α → β} :
  Measurable f ↔ m₂ ≤ m₁.map f :=
  Iff.rfl

alias measurable_iff_le_map ↔ Measurable.le_map Measurable.of_le_map

theorem measurable_iff_comap_le {m₁ : MeasurableSpace α} {m₂ : MeasurableSpace β} {f : α → β} :
  Measurable f ↔ m₂.comap f ≤ m₁ :=
  comap_le_iff_le_map.symm

alias measurable_iff_comap_le ↔ Measurable.comap_le Measurable.of_comap_le

theorem Measurable.mono {ma ma' : MeasurableSpace α} {mb mb' : MeasurableSpace β} {f : α → β}
  (hf : @Measurable α β ma mb f) (ha : ma ≤ ma') (hb : mb' ≤ mb) : @Measurable α β ma' mb' f :=
  fun t ht => ha _$ hf$ hb _ ht

@[measurability]
theorem measurable_from_top [MeasurableSpace β] {f : α → β} : @Measurable _ _ ⊤ _ f :=
  fun s hs => trivialₓ

theorem measurable_generate_from [MeasurableSpace α] {s : Set (Set β)} {f : α → β}
  (h : ∀ t (_ : t ∈ s), MeasurableSet (f ⁻¹' t)) : @Measurable _ _ _ (generate_from s) f :=
  Measurable.of_le_map$ generate_from_le h

variable[MeasurableSpace α][MeasurableSpace β][MeasurableSpace γ]

@[measurability]
theorem measurable_set_preimage {f : α → β} {t : Set β} (hf : Measurable f) (ht : MeasurableSet t) :
  MeasurableSet (f ⁻¹' t) :=
  hf ht

@[measurability]
theorem Measurable.iterate {f : α → α} (hf : Measurable f) : ∀ n, Measurable (f^[n])
| 0 => measurable_id
| n+1 => (Measurable.iterate n).comp hf

@[nontriviality, measurability]
theorem Subsingleton.measurable [Subsingleton α] {f : α → β} : Measurable f :=
  fun s hs => @Subsingleton.measurable_set α _ _ _

@[nontriviality, measurability]
theorem measurable_of_subsingleton_codomain [Subsingleton β] (f : α → β) : Measurable f :=
  fun s hs => Subsingleton.set_cases MeasurableSet.empty MeasurableSet.univ s

@[measurability]
theorem Measurable.piecewise {s : Set α} {_ : DecidablePred (· ∈ s)} {f g : α → β} (hs : MeasurableSet s)
  (hf : Measurable f) (hg : Measurable g) : Measurable (piecewise s f g) :=
  by 
    intro t ht 
    rw [piecewise_preimage]
    exact hs.ite (hf ht) (hg ht)

/-- this is slightly different from `measurable.piecewise`. It can be used to show
`measurable (ite (x=0) 0 1)` by
`exact measurable.ite (measurable_set_singleton 0) measurable_const measurable_const`,
but replacing `measurable.ite` by `measurable.piecewise` in that example proof does not work. -/
theorem Measurable.ite {p : α → Prop} {_ : DecidablePred p} {f g : α → β} (hp : MeasurableSet { a:α | p a })
  (hf : Measurable f) (hg : Measurable g) : Measurable fun x => ite (p x) (f x) (g x) :=
  Measurable.piecewise hp hf hg

@[measurability]
theorem Measurable.indicator [HasZero β] {s : Set α} {f : α → β} (hf : Measurable f) (hs : MeasurableSet s) :
  Measurable (s.indicator f) :=
  hf.piecewise hs measurable_const

@[toAdditive]
theorem measurable_one [HasOne α] : Measurable (1 : β → α) :=
  @measurable_const _ _ _ _ 1

theorem measurable_of_empty [IsEmpty α] (f : α → β) : Measurable f :=
  Subsingleton.measurable

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem measurable_of_empty_codomain [is_empty β] (f : α → β) : measurable f :=
by { haveI [] [] [":=", expr function.is_empty f],
  exact [expr measurable_of_empty f] }

/-- A version of `measurable_const` that assumes `f x = f y` for all `x, y`. This version works
for functions between empty types. -/
theorem measurable_const' {f : β → α} (hf : ∀ x y, f x = f y) : Measurable f :=
  by 
    cases' is_empty_or_nonempty β
    ·
      exact measurable_of_empty f
    ·
      convert measurable_const 
      exact funext fun x => hf x h.some

@[toAdditive, measurability]
theorem measurable_set_mul_support [HasOne β] [MeasurableSingletonClass β] {f : α → β} (hf : Measurable f) :
  MeasurableSet (mul_support f) :=
  hf (measurable_set_singleton 1).Compl

attribute [measurability] measurable_set_support

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If a function coincides with a measurable function outside of a countable set, it is
measurable. -/
theorem measurable.measurable_of_countable_ne
[measurable_singleton_class α]
{f g : α → β}
(hf : measurable f)
(h : countable {x | «expr ≠ »(f x, g x)}) : measurable g :=
begin
  assume [binders (t ht)],
  have [] [":", expr «expr = »(«expr ⁻¹' »(g, t), «expr ∪ »(«expr ∩ »(«expr ⁻¹' »(g, t), «expr ᶜ»({x | «expr = »(f x, g x)})), «expr ∩ »(«expr ⁻¹' »(g, t), {x | «expr = »(f x, g x)})))] [],
  by simp [] [] [] ["[", "<-", expr inter_union_distrib_left, "]"] [] [],
  rw [expr this] [],
  apply [expr measurable_set.union (h.mono (inter_subset_right _ _)).measurable_set],
  have [] [":", expr «expr = »(«expr ∩ »(«expr ⁻¹' »(g, t), {x : α | «expr = »(f x, g x)}), «expr ∩ »(«expr ⁻¹' »(f, t), {x : α | «expr = »(f x, g x)}))] [],
  by { ext [] [ident x] [],
    simp [] [] [] [] [] [] { contextual := tt } },
  rw [expr this] [],
  exact [expr (hf ht).inter h.measurable_set.of_compl]
end

theorem measurable_of_fintype [Fintype α] [MeasurableSingletonClass α] (f : α → β) : Measurable f :=
  fun s hs => (finite.of_fintype (f ⁻¹' s)).MeasurableSet

end MeasurableFunctions

section Constructions

variable[MeasurableSpace α][MeasurableSpace β][MeasurableSpace γ]

instance  : MeasurableSpace Empty :=
  ⊤

instance  : MeasurableSpace PUnit :=
  ⊤

instance  : MeasurableSpace Bool :=
  ⊤

instance  : MeasurableSpace ℕ :=
  ⊤

instance  : MeasurableSpace ℤ :=
  ⊤

instance  : MeasurableSpace ℚ :=
  ⊤

theorem measurable_to_encodable [Encodable α] {f : β → α} (h : ∀ y, MeasurableSet (f ⁻¹' {f y})) : Measurable f :=
  by 
    intro s hs 
    rw [←bUnion_preimage_singleton]
    refine' MeasurableSet.Union fun y => MeasurableSet.Union_Prop$ fun hy => _ 
    byCases' hyf : y ∈ range f
    ·
      rcases hyf with ⟨y, rfl⟩
      apply h
    ·
      simp only [preimage_singleton_eq_empty.2 hyf, MeasurableSet.empty]

@[measurability]
theorem measurable_unit (f : Unit → α) : Measurable f :=
  measurable_from_top

section Nat

@[measurability]
theorem measurable_from_nat {f : ℕ → α} : Measurable f :=
  measurable_from_top

theorem measurable_to_nat {f : α → ℕ} : (∀ y, MeasurableSet (f ⁻¹' {f y})) → Measurable f :=
  measurable_to_encodable

theorem measurable_find_greatest' {p : α → ℕ → Prop} {N}
  (hN : ∀ k (_ : k ≤ N), MeasurableSet { x | Nat.findGreatest (p x) N = k }) :
  Measurable fun x => Nat.findGreatest (p x) N :=
  measurable_to_nat$ fun x => hN _ Nat.find_greatest_le

theorem measurable_find_greatest {p : α → ℕ → Prop} {N} (hN : ∀ k (_ : k ≤ N), MeasurableSet { x | p x k }) :
  Measurable fun x => Nat.findGreatest (p x) N :=
  by 
    refine' measurable_find_greatest' fun k hk => _ 
    simp only [Nat.find_greatest_eq_iff, set_of_and, set_of_forall, ←compl_set_of]
    repeat' 
      applyRules [MeasurableSet.inter, MeasurableSet.const, MeasurableSet.Inter, MeasurableSet.Inter_Prop,
          MeasurableSet.compl, hN] <;>
        try 
          intros 

theorem measurable_find {p : α → ℕ → Prop} (hp : ∀ x, ∃ N, p x N) (hm : ∀ k, MeasurableSet { x | p x k }) :
  Measurable fun x => Nat.findₓ (hp x) :=
  by 
    refine' measurable_to_nat fun x => _ 
    rw [preimage_find_eq_disjointed]
    exact MeasurableSet.disjointed hm _

end Nat

section Quotientₓ

instance  {α} {r : α → α → Prop} [m : MeasurableSpace α] : MeasurableSpace (Quot r) :=
  m.map (Quot.mk r)

instance  {α} {s : Setoidₓ α} [m : MeasurableSpace α] : MeasurableSpace (Quotientₓ s) :=
  m.map Quotientₓ.mk'

@[toAdditive]
instance  {G} [Groupₓ G] [MeasurableSpace G] (S : Subgroup G) : MeasurableSpace (QuotientGroup.Quotient S) :=
  Quotientₓ.measurableSpace

theorem measurable_set_quotient {s : Setoidₓ α} {t : Set (Quotientₓ s)} :
  MeasurableSet t ↔ MeasurableSet (Quotientₓ.mk' ⁻¹' t) :=
  Iff.rfl

theorem measurable_from_quotient {s : Setoidₓ α} {f : Quotientₓ s → β} :
  Measurable f ↔ Measurable (f ∘ Quotientₓ.mk') :=
  Iff.rfl

@[measurability]
theorem measurable_quotient_mk [s : Setoidₓ α] : Measurable (Quotientₓ.mk : α → Quotientₓ s) :=
  fun s => id

@[measurability]
theorem measurable_quotient_mk' {s : Setoidₓ α} : Measurable (Quotientₓ.mk' : α → Quotientₓ s) :=
  fun s => id

@[measurability]
theorem measurable_quot_mk {r : α → α → Prop} : Measurable (Quot.mk r) :=
  fun s => id

@[toAdditive]
theorem QuotientGroup.measurable_coe {G} [Groupₓ G] [MeasurableSpace G] {S : Subgroup G} :
  Measurable (coeₓ : G → QuotientGroup.Quotient S) :=
  measurable_quotient_mk'

attribute [measurability] QuotientGroup.measurable_coe QuotientAddGroup.measurable_coe

@[toAdditive]
theorem QuotientGroup.measurable_from_quotient {G} [Groupₓ G] [MeasurableSpace G] {S : Subgroup G}
  {f : QuotientGroup.Quotient S → α} : Measurable f ↔ Measurable (f ∘ (coeₓ : G → QuotientGroup.Quotient S)) :=
  measurable_from_quotient

end Quotientₓ

section Subtype

instance  {α} {p : α → Prop} [m : MeasurableSpace α] : MeasurableSpace (Subtype p) :=
  m.comap (coeₓ : _ → α)

@[measurability]
theorem measurable_subtype_coe {p : α → Prop} : Measurable (coeₓ : Subtype p → α) :=
  MeasurableSpace.le_map_comap

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[measurability #[]]
theorem measurable.subtype_coe
{p : β → exprProp()}
{f : α → subtype p}
(hf : measurable f) : measurable (λ a : α, (f a : β)) :=
measurable_subtype_coe.comp hf

@[measurability]
theorem Measurable.subtype_mk {p : β → Prop} {f : α → β} (hf : Measurable f) {h : ∀ x, p (f x)} :
  Measurable fun x => (⟨f x, h x⟩ : Subtype p) :=
  fun t ⟨s, hs⟩ =>
    hs.2 ▸
      by 
        simp only [←preimage_comp, · ∘ ·, Subtype.coe_mk, hf hs.1]

theorem MeasurableSet.subtype_image {s : Set α} {t : Set s} (hs : MeasurableSet s) :
  MeasurableSet t → MeasurableSet ((coeₓ : s → α) '' t)
| ⟨u, (hu : MeasurableSet u), (Eq : coeₓ ⁻¹' u = t)⟩ =>
  by 
    rw [←Eq, Subtype.image_preimage_coe]
    exact hu.inter hs

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem measurable_of_measurable_union_cover
{f : α → β}
(s t : set α)
(hs : measurable_set s)
(ht : measurable_set t)
(h : «expr ⊆ »(univ, «expr ∪ »(s, t)))
(hc : measurable (λ a : s, f a))
(hd : measurable (λ a : t, f a)) : measurable f :=
begin
  intros [ident u, ident hu],
  convert [] [expr (hs.subtype_image (hc hu)).union (ht.subtype_image (hd hu))] [],
  change [expr «expr = »(«expr ⁻¹' »(f, u), «expr ∪ »(«expr '' »(coe, («expr ⁻¹' »(coe, «expr ⁻¹' »(f, u)) : set s)), «expr '' »(coe, («expr ⁻¹' »(coe, «expr ⁻¹' »(f, u)) : set t))))] [] [],
  rw ["[", expr image_preimage_eq_inter_range, ",", expr image_preimage_eq_inter_range, ",", expr subtype.range_coe, ",", expr subtype.range_coe, ",", "<-", expr inter_distrib_left, ",", expr univ_subset_iff.1 h, ",", expr inter_univ, "]"] []
end

theorem measurable_of_restrict_of_restrict_compl {f : α → β} {s : Set α} (hs : MeasurableSet s)
  (h₁ : Measurable (restrict f s)) (h₂ : Measurable (restrict f («expr ᶜ» s))) : Measurable f :=
  measurable_of_measurable_union_cover s («expr ᶜ» s) hs hs.compl (union_compl_self s).Ge h₁ h₂

theorem Measurable.dite [∀ x, Decidable (x ∈ s)] {f : s → β} (hf : Measurable f) {g : «expr ᶜ» s → β}
  (hg : Measurable g) (hs : MeasurableSet s) : Measurable fun x => if hx : x ∈ s then f ⟨x, hx⟩ else g ⟨x, hx⟩ :=
  measurable_of_restrict_of_restrict_compl hs
    (by 
      simpa)
    (by 
      simpa)

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
instance
{α}
{p : α → exprProp()}
[measurable_space α]
[measurable_singleton_class α] : measurable_singleton_class (subtype p) :=
{ measurable_set_singleton := λ x, begin
    have [] [":", expr measurable_set {(x : α)}] [":=", expr measurable_set_singleton _],
    convert [] [expr @measurable_subtype_coe α _ p _ this] [],
    ext [] [ident y] [],
    simp [] [] [] ["[", expr subtype.ext_iff, "]"] [] []
  end }

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem measurable_of_measurable_on_compl_finite
[measurable_singleton_class α]
{f : α → β}
(s : set α)
(hs : finite s)
(hf : measurable (set.restrict f «expr ᶜ»(s))) : measurable f :=
begin
  letI [] [":", expr fintype s] [":=", expr finite.fintype hs],
  exact [expr measurable_of_restrict_of_restrict_compl hs.measurable_set (measurable_of_fintype _) hf]
end

theorem measurable_of_measurable_on_compl_singleton [MeasurableSingletonClass α] {f : α → β} (a : α)
  (hf : Measurable (Set.restrict f { x | x ≠ a })) : Measurable f :=
  measurable_of_measurable_on_compl_finite {a} (finite_singleton a) hf

end Subtype

section Prod

instance  {α β} [m₁ : MeasurableSpace α] [m₂ : MeasurableSpace β] : MeasurableSpace (α × β) :=
  m₁.comap Prod.fst⊔m₂.comap Prod.snd

@[measurability]
theorem measurable_fst : Measurable (Prod.fst : α × β → α) :=
  Measurable.of_comap_le le_sup_left

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem measurable.fst {f : α → «expr × »(β, γ)} (hf : measurable f) : measurable (λ a : α, (f a).1) :=
measurable_fst.comp hf

@[measurability]
theorem measurable_snd : Measurable (Prod.snd : α × β → β) :=
  Measurable.of_comap_le le_sup_right

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem measurable.snd {f : α → «expr × »(β, γ)} (hf : measurable f) : measurable (λ a : α, (f a).2) :=
measurable_snd.comp hf

@[measurability]
theorem Measurable.prod {f : α → β × γ} (hf₁ : Measurable fun a => (f a).1) (hf₂ : Measurable fun a => (f a).2) :
  Measurable f :=
  Measurable.of_le_map$
    sup_le
      (by 
        rw [MeasurableSpace.comap_le_iff_le_map, MeasurableSpace.map_comp]
        exact hf₁)
      (by 
        rw [MeasurableSpace.comap_le_iff_le_map, MeasurableSpace.map_comp]
        exact hf₂)

theorem measurable_prod {f : α → β × γ} : Measurable f ↔ (Measurable fun a => (f a).1) ∧ Measurable fun a => (f a).2 :=
  ⟨fun hf => ⟨measurable_fst.comp hf, measurable_snd.comp hf⟩, fun h => Measurable.prod h.1 h.2⟩

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem measurable.prod_mk
{f : α → β}
{g : α → γ}
(hf : measurable f)
(hg : measurable g) : measurable (λ a : α, (f a, g a)) :=
measurable.prod hf hg

theorem measurable_prod_mk_left {x : α} : Measurable (@Prod.mk _ β x) :=
  measurable_const.prod_mk measurable_id

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem measurable_prod_mk_right {y : β} : measurable (λ x : α, (x, y)) := measurable_id.prod_mk measurable_const

theorem Measurable.prod_map [MeasurableSpace δ] {f : α → β} {g : γ → δ} (hf : Measurable f) (hg : Measurable g) :
  Measurable (Prod.mapₓ f g) :=
  (hf.comp measurable_fst).prod_mk (hg.comp measurable_snd)

theorem Measurable.of_uncurry_left {f : α → β → γ} (hf : Measurable (uncurry f)) {x : α} : Measurable (f x) :=
  hf.comp measurable_prod_mk_left

theorem Measurable.of_uncurry_right {f : α → β → γ} (hf : Measurable (uncurry f)) {y : β} : Measurable fun x => f x y :=
  hf.comp measurable_prod_mk_right

@[measurability]
theorem measurable_swap : Measurable (Prod.swap : α × β → β × α) :=
  Measurable.prod measurable_snd measurable_fst

theorem measurable_swap_iff {f : α × β → γ} : Measurable (f ∘ Prod.swap) ↔ Measurable f :=
  ⟨fun hf =>
      by 
        convert hf.comp measurable_swap 
        ext ⟨x, y⟩
        rfl,
    fun hf => hf.comp measurable_swap⟩

@[measurability]
theorem MeasurableSet.prod {s : Set α} {t : Set β} (hs : MeasurableSet s) (ht : MeasurableSet t) :
  MeasurableSet (s.prod t) :=
  MeasurableSet.inter (measurable_fst hs) (measurable_snd ht)

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem measurable_set_prod_of_nonempty
{s : set α}
{t : set β}
(h : (s.prod t).nonempty) : «expr ↔ »(measurable_set (s.prod t), «expr ∧ »(measurable_set s, measurable_set t)) :=
begin
  rcases [expr h, "with", "⟨", "⟨", ident x, ",", ident y, "⟩", ",", ident hx, ",", ident hy, "⟩"],
  refine [expr ⟨λ hst, _, λ h, h.1.prod h.2⟩],
  have [] [":", expr measurable_set «expr ⁻¹' »(λ
    x, (x, y), s.prod t)] [":=", expr measurable_id.prod_mk measurable_const hst],
  have [] [":", expr measurable_set «expr ⁻¹' »(prod.mk x, s.prod t)] [":=", expr measurable_const.prod_mk measurable_id hst],
  simp [] [] [] ["*"] [] ["at", "*"]
end

theorem measurable_set_prod {s : Set α} {t : Set β} :
  MeasurableSet (s.prod t) ↔ MeasurableSet s ∧ MeasurableSet t ∨ s = ∅ ∨ t = ∅ :=
  by 
    cases' (s.prod t).eq_empty_or_nonempty with h h
    ·
      simp [h, prod_eq_empty_iff.mp h]
    ·
      simp [←not_nonempty_iff_eq_empty, prod_nonempty_iff.mp h, measurable_set_prod_of_nonempty h]

theorem measurable_set_swap_iff {s : Set (α × β)} : MeasurableSet (Prod.swap ⁻¹' s) ↔ MeasurableSet s :=
  ⟨fun hs =>
      by 
        convert measurable_swap hs 
        ext ⟨x, y⟩
        rfl,
    fun hs => measurable_swap hs⟩

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem measurable_from_prod_encodable
[encodable β]
[measurable_singleton_class β]
{f : «expr × »(α, β) → γ}
(hf : ∀ y, measurable (λ x, f (x, y))) : measurable f :=
begin
  intros [ident s, ident hs],
  have [] [":", expr «expr = »(«expr ⁻¹' »(f, s), «expr⋃ , »((y), «expr ⁻¹' »(λ x, f (x, y), s).prod {y}))] [],
  { ext1 [] ["⟨", ident x, ",", ident y, "⟩"],
    simp [] [] [] ["[", expr and_assoc, ",", expr and.left_comm, "]"] [] [] },
  rw [expr this] [],
  exact [expr measurable_set.Union (λ y, (hf y hs).prod (measurable_set_singleton y))]
end

end Prod

section Pi

variable{π : δ → Type _}

instance MeasurableSpace.pi [m : ∀ a, MeasurableSpace (π a)] : MeasurableSpace (∀ a, π a) :=
  ⨆a, (m a).comap fun b => b a

variable[∀ a, MeasurableSpace (π a)][MeasurableSpace γ]

theorem measurable_pi_iff {g : α → ∀ a, π a} : Measurable g ↔ ∀ a, Measurable fun x => g x a :=
  by 
    simpRw [measurable_iff_comap_le, MeasurableSpace.pi, MeasurableSpace.comap_supr, MeasurableSpace.comap_comp,
      Function.comp, supr_le_iff]

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
@[measurability #[]] theorem measurable_pi_apply (a : δ) : measurable (λ f : ∀ a, π a, f a) :=
«expr $ »(measurable.of_comap_le, le_supr _ a)

@[measurability]
theorem Measurable.eval {a : δ} {g : α → ∀ a, π a} (hg : Measurable g) : Measurable fun x => g x a :=
  (measurable_pi_apply a).comp hg

@[measurability]
theorem measurable_pi_lambda (f : α → ∀ a, π a) (hf : ∀ a, Measurable fun c => f c a) : Measurable f :=
  measurable_pi_iff.mpr hf

/-- The function `update f a : π a → Π a, π a` is always measurable.
  This doesn't require `f` to be measurable.
  This should not be confused with the statement that `update f a x` is measurable. -/
@[measurability]
theorem measurable_update (f : ∀ (a : δ), π a) {a : δ} : Measurable (update f a) :=
  by 
    apply measurable_pi_lambda 
    intro x 
    byCases' hx : x = a
    ·
      cases hx 
      convert measurable_id 
      ext 
      simp 
    simpRw [update_noteq hx]
    apply measurable_const

@[measurability]
theorem MeasurableSet.pi {s : Set δ} {t : ∀ (i : δ), Set (π i)} (hs : countable s)
  (ht : ∀ i (_ : i ∈ s), MeasurableSet (t i)) : MeasurableSet (s.pi t) :=
  by 
    rw [pi_def]
    exact MeasurableSet.bInter hs fun i hi => measurable_pi_apply _ (ht i hi)

theorem MeasurableSet.univ_pi [Encodable δ] {t : ∀ (i : δ), Set (π i)} (ht : ∀ i, MeasurableSet (t i)) :
  MeasurableSet (pi univ t) :=
  MeasurableSet.pi (countable_encodable _) fun i _ => ht i

theorem measurable_set_pi_of_nonempty {s : Set δ} {t : ∀ i, Set (π i)} (hs : countable s) (h : (pi s t).Nonempty) :
  MeasurableSet (pi s t) ↔ ∀ i (_ : i ∈ s), MeasurableSet (t i) :=
  by 
    rcases h with ⟨f, hf⟩
    refine' ⟨fun hst i hi => _, MeasurableSet.pi hs⟩
    convert measurable_update f hst 
    rw [update_preimage_pi hi]
    exact fun j hj _ => hf j hj

theorem measurable_set_pi {s : Set δ} {t : ∀ i, Set (π i)} (hs : countable s) :
  MeasurableSet (pi s t) ↔ (∀ i (_ : i ∈ s), MeasurableSet (t i)) ∨ pi s t = ∅ :=
  by 
    cases' (pi s t).eq_empty_or_nonempty with h h
    ·
      simp [h]
    ·
      simp [measurable_set_pi_of_nonempty hs, h, ←not_nonempty_iff_eq_empty]

section 

variable(π)

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[measurability #[]]
theorem measurable_pi_equiv_pi_subtype_prod_symm
(p : δ → exprProp())
[decidable_pred p] : measurable (equiv.pi_equiv_pi_subtype_prod p π).symm :=
begin
  apply [expr measurable_pi_iff.2 (λ j, _)],
  by_cases [expr hj, ":", expr p j],
  { simp [] [] ["only"] ["[", expr hj, ",", expr dif_pos, ",", expr equiv.pi_equiv_pi_subtype_prod_symm_apply, "]"] [] [],
    have [] [":", expr measurable (λ
      f : ∀ i : {x // p x}, π «expr↑ »(i), f ⟨j, hj⟩)] [":=", expr measurable_pi_apply ⟨j, hj⟩],
    exact [expr measurable.comp this measurable_fst] },
  { simp [] [] ["only"] ["[", expr hj, ",", expr equiv.pi_equiv_pi_subtype_prod_symm_apply, ",", expr dif_neg, ",", expr not_false_iff, "]"] [] [],
    have [] [":", expr measurable (λ
      f : ∀ i : {x // «expr¬ »(p x)}, π «expr↑ »(i), f ⟨j, hj⟩)] [":=", expr measurable_pi_apply ⟨j, hj⟩],
    exact [expr measurable.comp this measurable_snd] }
end

@[measurability]
theorem measurable_pi_equiv_pi_subtype_prod (p : δ → Prop) [DecidablePred p] :
  Measurable (Equiv.piEquivPiSubtypeProd p π) :=
  by 
    refine' measurable_prod.2 _ 
    split  <;>
      ·
        apply measurable_pi_iff.2 fun j => _ 
        simp only [pi_equiv_pi_subtype_prod_apply, measurable_pi_apply]

end 

section Fintype

attribute [local instance] Fintype.encodable

theorem MeasurableSet.pi_fintype [Fintype δ] {s : Set δ} {t : ∀ i, Set (π i)}
  (ht : ∀ i (_ : i ∈ s), MeasurableSet (t i)) : MeasurableSet (pi s t) :=
  MeasurableSet.pi (countable_encodable _) ht

theorem MeasurableSet.univ_pi_fintype [Fintype δ] {t : ∀ i, Set (π i)} (ht : ∀ i, MeasurableSet (t i)) :
  MeasurableSet (pi univ t) :=
  MeasurableSet.pi_fintype fun i _ => ht i

end Fintype

end Pi

instance Tprod.measurableSpaceₓ (π : δ → Type _) [∀ x, MeasurableSpace (π x)] :
  ∀ (l : List δ), MeasurableSpace (List.Tprod π l)
| [] => PUnit.measurableSpace
| i :: is => @Prod.measurableSpace _ _ _ (Tprod.measurableSpaceₓ is)

section Tprod

open List

variable{π : δ → Type _}[∀ x, MeasurableSpace (π x)]

theorem measurable_tprod_mk (l : List δ) : Measurable (@tprod.mk δ π l) :=
  by 
    induction' l with i l ih
    ·
      exact measurable_const
    ·
      exact (measurable_pi_apply i).prod_mk ih

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem measurable_tprod_elim : ∀ {l : list δ} {i : δ} (hi : «expr ∈ »(i, l)), measurable (λ v : tprod π l, v.elim hi)
| [«expr :: »/«expr :: »/«expr :: »](i, is), j, hj := begin
  by_cases [expr hji, ":", expr «expr = »(j, i)],
  { subst [expr hji],
    simp [] [] [] ["[", expr measurable_fst, "]"] [] [] },
  { rw ["[", expr «expr $ »(funext, tprod.elim_of_ne _ hji), "]"] [],
    exact [expr (measurable_tprod_elim (hj.resolve_left hji)).comp measurable_snd] }
end

theorem measurable_tprod_elim' {l : List δ} (h : ∀ i, i ∈ l) : Measurable (tprod.elim' h : tprod π l → ∀ i, π i) :=
  measurable_pi_lambda _ fun i => measurable_tprod_elim (h i)

theorem MeasurableSet.tprod (l : List δ) {s : ∀ i, Set (π i)} (hs : ∀ i, MeasurableSet (s i)) :
  MeasurableSet (Set.Tprodₓ l s) :=
  by 
    induction' l with i l ih 
    exact MeasurableSet.univ 
    exact (hs i).Prod ih

end Tprod

instance  {α β} [m₁ : MeasurableSpace α] [m₂ : MeasurableSpace β] : MeasurableSpace (Sum α β) :=
  m₁.map Sum.inl⊓m₂.map Sum.inr

section Sum

@[measurability]
theorem measurable_inl : Measurable (@Sum.inl α β) :=
  Measurable.of_le_map inf_le_left

@[measurability]
theorem measurable_inr : Measurable (@Sum.inr α β) :=
  Measurable.of_le_map inf_le_right

theorem measurable_sum {f : Sum α β → γ} (hl : Measurable (f ∘ Sum.inl)) (hr : Measurable (f ∘ Sum.inr)) :
  Measurable f :=
  Measurable.of_comap_le$ le_inf (MeasurableSpace.comap_le_iff_le_map.2$ hl) (MeasurableSpace.comap_le_iff_le_map.2$ hr)

@[measurability]
theorem Measurable.sum_elim {f : α → γ} {g : β → γ} (hf : Measurable f) (hg : Measurable g) :
  Measurable (Sum.elim f g) :=
  measurable_sum hf hg

theorem MeasurableSet.inl_image {s : Set α} (hs : MeasurableSet s) : MeasurableSet (Sum.inl '' s : Set (Sum α β)) :=
  ⟨show MeasurableSet (Sum.inl ⁻¹' _)by 
      rwa [preimage_image_eq]
      exact fun a b => Sum.inl.injₓ,
    have  : Sum.inr ⁻¹' (Sum.inl '' s : Set (Sum α β)) = ∅ :=
      eq_empty_of_subset_empty$
        fun x ⟨y, hy, Eq⟩ =>
          by 
            contradiction 
    show MeasurableSet (Sum.inr ⁻¹' _)by 
      rw [this]
      exact MeasurableSet.empty⟩

theorem measurable_set_range_inl : MeasurableSet (range Sum.inl : Set (Sum α β)) :=
  by 
    rw [←image_univ]
    exact measurable_set.univ.inl_image

theorem measurable_set_inr_image {s : Set β} (hs : MeasurableSet s) : MeasurableSet (Sum.inr '' s : Set (Sum α β)) :=
  ⟨have  : Sum.inl ⁻¹' (Sum.inr '' s : Set (Sum α β)) = ∅ :=
      eq_empty_of_subset_empty$
        fun x ⟨y, hy, Eq⟩ =>
          by 
            contradiction 
    show MeasurableSet (Sum.inl ⁻¹' _)by 
      rw [this]
      exact MeasurableSet.empty,
    show MeasurableSet (Sum.inr ⁻¹' _)by 
      rwa [preimage_image_eq]
      exact fun a b => Sum.inr.injₓ⟩

theorem measurable_set_range_inr : MeasurableSet (range Sum.inr : Set (Sum α β)) :=
  by 
    rw [←image_univ]
    exact measurable_set_inr_image MeasurableSet.univ

end Sum

instance  {α} {β : α → Type _} [m : ∀ a, MeasurableSpace (β a)] : MeasurableSpace (Sigma β) :=
  ⨅a, (m a).map (Sigma.mk a)

end Constructions

/-- A map `f : α → β` is called a *measurable embedding* if it is injective, measurable, and sends
measurable sets to measurable sets. The latter assumption can be replaced with “`f` has measurable
inverse `g : range f → α`”, see `measurable_embedding.measurable_range_splitting`,
`measurable_embedding.of_measurable_inverse_range`, and
`measurable_embedding.of_measurable_inverse`.

One more interpretation: `f` is a measurable embedding if it defines a measurable equivalence to its
range and the range is a measurable set. One implication is formalized as
`measurable_embedding.equiv_range`; the other one follows from
`measurable_equiv.measurable_embedding`, `measurable_embedding.subtype_coe`, and
`measurable_embedding.comp`. -/
@[protectProj]
structure MeasurableEmbedding{α β : Type _}[MeasurableSpace α][MeasurableSpace β](f : α → β) : Prop where 
  Injective : injective f 
  Measurable : Measurable f 
  measurable_set_image' : ∀ ⦃s⦄, MeasurableSet s → MeasurableSet (f '' s)

namespace MeasurableEmbedding

variable[MeasurableSpace α][MeasurableSpace β][MeasurableSpace γ]{f : α → β}{g : β → γ}

theorem measurable_set_image (hf : MeasurableEmbedding f) {s : Set α} : MeasurableSet (f '' s) ↔ MeasurableSet s :=
  ⟨fun h =>
      by 
        simpa only [hf.injective.preimage_image] using hf.measurable h,
    fun h => hf.measurable_set_image' h⟩

theorem id : MeasurableEmbedding (id : α → α) :=
  ⟨injective_id, measurable_id,
    fun s hs =>
      by 
        rwa [image_id]⟩

theorem comp (hg : MeasurableEmbedding g) (hf : MeasurableEmbedding f) : MeasurableEmbedding (g ∘ f) :=
  ⟨hg.injective.comp hf.injective, hg.measurable.comp hf.measurable,
    fun s hs =>
      by 
        rwa [←image_image, hg.measurable_set_image, hf.measurable_set_image]⟩

theorem subtype_coe {s : Set α} (hs : MeasurableSet s) : MeasurableEmbedding (coeₓ : s → α) :=
  { Injective := Subtype.coe_injective, Measurable := measurable_subtype_coe,
    measurable_set_image' := fun _ => MeasurableSet.subtype_image hs }

theorem measurable_set_range (hf : MeasurableEmbedding f) : MeasurableSet (range f) :=
  by 
    rw [←image_univ]
    exact hf.measurable_set_image' MeasurableSet.univ

theorem measurable_set_preimage (hf : MeasurableEmbedding f) {s : Set β} :
  MeasurableSet (f ⁻¹' s) ↔ MeasurableSet (s ∩ range f) :=
  by 
    rw [←image_preimage_eq_inter_range, hf.measurable_set_image]

theorem measurable_range_splitting (hf : MeasurableEmbedding f) : Measurable (range_splitting f) :=
  fun s hs =>
    by 
      rwa [preimage_range_splitting hf.injective, ←(subtype_coe hf.measurable_set_range).measurable_set_image,
        ←image_comp, coe_comp_range_factorization, hf.measurable_set_image]

theorem measurable_extend (hf : MeasurableEmbedding f) {g : α → γ} {g' : β → γ} (hg : Measurable g)
  (hg' : Measurable g') : Measurable (extend f g g') :=
  by 
    refine' measurable_of_restrict_of_restrict_compl hf.measurable_set_range _ _
    ·
      rw [restrict_extend_range]
      simpa only [range_splitting] using hg.comp hf.measurable_range_splitting
    ·
      rw [restrict_extend_compl_range]
      exact hg'.comp measurable_subtype_coe

theorem exists_measurable_extend (hf : MeasurableEmbedding f) {g : α → γ} (hg : Measurable g) (hne : β → Nonempty γ) :
  ∃ g' : β → γ, Measurable g' ∧ (g' ∘ f) = g :=
  ⟨extend f g fun x => Classical.choice (hne x), hf.measurable_extend hg (measurable_const'$ fun _ _ => rfl),
    funext$ fun x => extend_apply hf.injective _ _ _⟩

theorem measurable_comp_iff (hg : MeasurableEmbedding g) : Measurable (g ∘ f) ↔ Measurable f :=
  by 
    refine' ⟨fun H => _, hg.measurable.comp⟩
    suffices  : Measurable ((range_splitting g ∘ range_factorization g) ∘ f)
    ·
      rwa [(right_inverse_range_splitting hg.injective).comp_eq_id] at this 
    exact hg.measurable_range_splitting.comp H.subtype_mk

end MeasurableEmbedding

theorem MeasurableSet.exists_measurable_proj [MeasurableSpace α] {s : Set α} (hs : MeasurableSet s) (hne : s.nonempty) :
  ∃ f : α → s, Measurable f ∧ ∀ (x : s), f x = x :=
  let ⟨f, hfm, hf⟩ :=
    (MeasurableEmbedding.subtype_coe hs).exists_measurable_extend measurable_id fun _ => hne.to_subtype
  ⟨f, hfm, congr_funₓ hf⟩

/-- Equivalences between measurable spaces. Main application is the simplification of measurability
statements along measurable equivalences. -/
structure MeasurableEquiv(α β : Type _)[MeasurableSpace α][MeasurableSpace β] extends α ≃ β where 
  measurable_to_fun : Measurable to_equiv 
  measurable_inv_fun : Measurable to_equiv.symm

infixl:25 " ≃ᵐ " => MeasurableEquiv

namespace MeasurableEquiv

variable(α β)[MeasurableSpace α][MeasurableSpace β][MeasurableSpace γ][MeasurableSpace δ]

instance  : CoeFun (α ≃ᵐ β) fun _ => α → β :=
  ⟨fun e => e.to_fun⟩

variable{α β}

@[simp]
theorem coe_to_equiv (e : α ≃ᵐ β) : (e.to_equiv : α → β) = e :=
  rfl

@[measurability]
protected theorem Measurable (e : α ≃ᵐ β) : Measurable (e : α → β) :=
  e.measurable_to_fun

@[simp]
theorem coe_mk (e : α ≃ β) (h1 : Measurable e) (h2 : Measurable e.symm) : ((⟨e, h1, h2⟩ : α ≃ᵐ β) : α → β) = e :=
  rfl

/-- Any measurable space is equivalent to itself. -/
def refl (α : Type _) [MeasurableSpace α] : α ≃ᵐ α :=
  { toEquiv := Equiv.refl α, measurable_to_fun := measurable_id, measurable_inv_fun := measurable_id }

instance  : Inhabited (α ≃ᵐ α) :=
  ⟨refl α⟩

/-- The composition of equivalences between measurable spaces. -/
def trans (ab : α ≃ᵐ β) (bc : β ≃ᵐ γ) : α ≃ᵐ γ :=
  { toEquiv := ab.to_equiv.trans bc.to_equiv, measurable_to_fun := bc.measurable_to_fun.comp ab.measurable_to_fun,
    measurable_inv_fun := ab.measurable_inv_fun.comp bc.measurable_inv_fun }

/-- The inverse of an equivalence between measurable spaces. -/
def symm (ab : α ≃ᵐ β) : β ≃ᵐ α :=
  { toEquiv := ab.to_equiv.symm, measurable_to_fun := ab.measurable_inv_fun,
    measurable_inv_fun := ab.measurable_to_fun }

@[simp]
theorem coe_to_equiv_symm (e : α ≃ᵐ β) : (e.to_equiv.symm : β → α) = e.symm :=
  rfl

/-- See Note [custom simps projection]. We need to specify this projection explicitly in this case,
  because it is a composition of multiple projections. -/
def simps.apply (h : α ≃ᵐ β) : α → β :=
  h

/-- See Note [custom simps projection] -/
def simps.symm_apply (h : α ≃ᵐ β) : β → α :=
  h.symm

initialize_simps_projections MeasurableEquiv (to_equiv_to_fun → apply, to_equiv_inv_fun → symmApply)

theorem to_equiv_injective : injective (to_equiv : α ≃ᵐ β → α ≃ β) :=
  by 
    rintro ⟨e₁, _, _⟩ ⟨e₂, _, _⟩ (rfl : e₁ = e₂)
    rfl

@[ext]
theorem ext {e₁ e₂ : α ≃ᵐ β} (h : (e₁ : α → β) = e₂) : e₁ = e₂ :=
  to_equiv_injective$ Equiv.coe_fn_injective h

@[simp]
theorem symm_mk (e : α ≃ β) (h1 : Measurable e) (h2 : Measurable e.symm) :
  (⟨e, h1, h2⟩ : α ≃ᵐ β).symm = ⟨e.symm, h2, h1⟩ :=
  rfl

attribute [simps apply toEquiv] trans refl

@[simp]
theorem symm_refl (α : Type _) [MeasurableSpace α] : (refl α).symm = refl α :=
  rfl

@[simp]
theorem symm_comp_self (e : α ≃ᵐ β) : (e.symm ∘ e) = id :=
  funext e.left_inv

@[simp]
theorem self_comp_symm (e : α ≃ᵐ β) : (e ∘ e.symm) = id :=
  funext e.right_inv

@[simp]
theorem apply_symm_apply (e : α ≃ᵐ β) (y : β) : e (e.symm y) = y :=
  e.right_inv y

@[simp]
theorem symm_apply_apply (e : α ≃ᵐ β) (x : α) : e.symm (e x) = x :=
  e.left_inv x

@[simp]
theorem symm_trans_self (e : α ≃ᵐ β) : e.symm.trans e = refl β :=
  ext e.self_comp_symm

@[simp]
theorem self_trans_symm (e : α ≃ᵐ β) : e.trans e.symm = refl α :=
  ext e.symm_comp_self

protected theorem surjective (e : α ≃ᵐ β) : surjective e :=
  e.to_equiv.surjective

protected theorem bijective (e : α ≃ᵐ β) : bijective e :=
  e.to_equiv.bijective

protected theorem injective (e : α ≃ᵐ β) : injective e :=
  e.to_equiv.injective

@[simp]
theorem symm_preimage_preimage (e : α ≃ᵐ β) (s : Set β) : e.symm ⁻¹' (e ⁻¹' s) = s :=
  e.to_equiv.symm_preimage_preimage s

theorem image_eq_preimage (e : α ≃ᵐ β) (s : Set α) : e '' s = e.symm ⁻¹' s :=
  e.to_equiv.image_eq_preimage s

@[simp]
theorem measurable_set_preimage (e : α ≃ᵐ β) {s : Set β} : MeasurableSet (e ⁻¹' s) ↔ MeasurableSet s :=
  ⟨fun h =>
      by 
        simpa only [symm_preimage_preimage] using e.symm.measurable h,
    fun h => e.measurable h⟩

@[simp]
theorem measurable_set_image (e : α ≃ᵐ β) {s : Set α} : MeasurableSet (e '' s) ↔ MeasurableSet s :=
  by 
    rw [image_eq_preimage, measurable_set_preimage]

/-- A measurable equivalence is a measurable embedding. -/
protected theorem MeasurableEmbedding (e : α ≃ᵐ β) : MeasurableEmbedding e :=
  { Injective := e.injective, Measurable := e.measurable, measurable_set_image' := fun s => e.measurable_set_image.2 }

/-- Equal measurable spaces are equivalent. -/
protected def cast {α β} [i₁ : MeasurableSpace α] [i₂ : MeasurableSpace β] (h : α = β) (hi : HEq i₁ i₂) : α ≃ᵐ β :=
  { toEquiv := Equiv.cast h,
    measurable_to_fun :=
      by 
        subst h 
        subst hi 
        exact measurable_id,
    measurable_inv_fun :=
      by 
        subst h 
        subst hi 
        exact measurable_id }

protected theorem measurable_comp_iff {f : β → γ} (e : α ≃ᵐ β) : Measurable (f ∘ e) ↔ Measurable f :=
  Iff.intro
    (fun hfe =>
      have  : Measurable (f ∘ (e.symm.trans e).toEquiv) := hfe.comp e.symm.measurable 
      by 
        rwa [coe_to_equiv, symm_trans_self] at this)
    fun h => h.comp e.measurable

/-- Any two types with unique elements are measurably equivalent. -/
def of_unique_of_unique (α β : Type _) [MeasurableSpace α] [MeasurableSpace β] [Unique α] [Unique β] : α ≃ᵐ β :=
  { toEquiv := equivOfUniqueOfUnique, measurable_to_fun := Subsingleton.measurable,
    measurable_inv_fun := Subsingleton.measurable }

/-- Products of equivalent measurable spaces are equivalent. -/
def prod_congr (ab : α ≃ᵐ β) (cd : γ ≃ᵐ δ) : α × γ ≃ᵐ β × δ :=
  { toEquiv := prod_congr ab.to_equiv cd.to_equiv,
    measurable_to_fun :=
      (ab.measurable_to_fun.comp measurable_id.fst).prod_mk (cd.measurable_to_fun.comp measurable_id.snd),
    measurable_inv_fun :=
      (ab.measurable_inv_fun.comp measurable_id.fst).prod_mk (cd.measurable_inv_fun.comp measurable_id.snd) }

/-- Products of measurable spaces are symmetric. -/
def prod_comm : α × β ≃ᵐ β × α :=
  { toEquiv := prod_comm α β, measurable_to_fun := measurable_id.snd.prod_mk measurable_id.fst,
    measurable_inv_fun := measurable_id.snd.prod_mk measurable_id.fst }

/-- Products of measurable spaces are associative. -/
def prod_assoc : (α × β) × γ ≃ᵐ α × β × γ :=
  { toEquiv := prod_assoc α β γ,
    measurable_to_fun := measurable_fst.fst.prod_mk$ measurable_fst.snd.prod_mk measurable_snd,
    measurable_inv_fun := (measurable_fst.prod_mk measurable_snd.fst).prod_mk measurable_snd.snd }

/-- Sums of measurable spaces are symmetric. -/
def sum_congr (ab : α ≃ᵐ β) (cd : γ ≃ᵐ δ) : Sum α γ ≃ᵐ Sum β δ :=
  { toEquiv := sum_congr ab.to_equiv cd.to_equiv,
    measurable_to_fun :=
      by 
        cases' ab with ab' abm 
        cases ab' 
        cases' cd with cd' cdm 
        cases cd' 
        refine' measurable_sum (measurable_inl.comp abm) (measurable_inr.comp cdm),
    measurable_inv_fun :=
      by 
        cases' ab with ab' _ abm 
        cases ab' 
        cases' cd with cd' _ cdm 
        cases cd' 
        refine' measurable_sum (measurable_inl.comp abm) (measurable_inr.comp cdm) }

/-- `set.prod s t ≃ (s × t)` as measurable spaces. -/
def Set.Prod (s : Set α) (t : Set β) : s.prod t ≃ᵐ s × t :=
  { toEquiv := Equiv.Set.prod s t,
    measurable_to_fun := measurable_id.subtype_coe.fst.subtype_mk.prod_mk measurable_id.subtype_coe.snd.subtype_mk,
    measurable_inv_fun := Measurable.subtype_mk$ measurable_id.fst.subtype_coe.prod_mk measurable_id.snd.subtype_coe }

/-- `univ α ≃ α` as measurable spaces. -/
def Set.Univ (α : Type _) [MeasurableSpace α] : (univ : Set α) ≃ᵐ α :=
  { toEquiv := Equiv.Set.univ α, measurable_to_fun := measurable_id.subtype_coe,
    measurable_inv_fun := measurable_id.subtype_mk }

/-- `{a} ≃ unit` as measurable spaces. -/
def set.singleton (a : α) : ({a} : Set α) ≃ᵐ Unit :=
  { toEquiv := Equiv.Set.singleton a, measurable_to_fun := measurable_const, measurable_inv_fun := measurable_const }

/-- A set is equivalent to its image under a function `f` as measurable spaces,
  if `f` is an injective measurable function that sends measurable sets to measurable sets. -/
noncomputable def Set.Image (f : α → β) (s : Set α) (hf : injective f) (hfm : Measurable f)
  (hfi : ∀ s, MeasurableSet s → MeasurableSet (f '' s)) : s ≃ᵐ f '' s :=
  { toEquiv := Equiv.Set.image f s hf, measurable_to_fun := (hfm.comp measurable_id.subtype_coe).subtype_mk,
    measurable_inv_fun :=
      by 
        rintro t ⟨u, hu, rfl⟩
        simp [preimage_preimage, set.image_symm_preimage hf]
        exact measurable_subtype_coe (hfi u hu) }

/-- The domain of `f` is equivalent to its range as measurable spaces,
  if `f` is an injective measurable function that sends measurable sets to measurable sets. -/
noncomputable def Set.Range (f : α → β) (hf : injective f) (hfm : Measurable f)
  (hfi : ∀ s, MeasurableSet s → MeasurableSet (f '' s)) : α ≃ᵐ range f :=
  (MeasurableEquiv.Set.univ _).symm.trans$
    (MeasurableEquiv.Set.image f univ hf hfm hfi).trans$
      MeasurableEquiv.cast
        (by 
          rw [image_univ])
        (by 
          rw [image_univ])

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- `α` is equivalent to its image in `α ⊕ β` as measurable spaces. -/
def set.range_inl : «expr ≃ᵐ »((range sum.inl : set «expr ⊕ »(α, β)), α) :=
{ to_fun := λ ab, match ab with
  | ⟨sum.inl a, _⟩ := a
  | ⟨sum.inr b, p⟩ := have false, by { cases [expr p] [],
    contradiction },
  this.elim
  end,
  inv_fun := λ a, ⟨sum.inl a, a, rfl⟩,
  left_inv := by { rintro ["⟨", ident ab, ",", ident a, ",", ident rfl, "⟩"],
    refl },
  right_inv := assume a, rfl,
  measurable_to_fun := assume (s) (hs : measurable_set s), begin
    refine [expr ⟨_, hs.inl_image, set.ext _⟩],
    rintros ["⟨", ident ab, ",", ident a, ",", ident rfl, "⟩"],
    simp [] [] [] ["[", expr set.range_inl._match_1, "]"] [] []
  end,
  measurable_inv_fun := measurable.subtype_mk measurable_inl }

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- `β` is equivalent to its image in `α ⊕ β` as measurable spaces. -/
def set.range_inr : «expr ≃ᵐ »((range sum.inr : set «expr ⊕ »(α, β)), β) :=
{ to_fun := λ ab, match ab with
  | ⟨sum.inr b, _⟩ := b
  | ⟨sum.inl a, p⟩ := have false, by { cases [expr p] [],
    contradiction },
  this.elim
  end,
  inv_fun := λ b, ⟨sum.inr b, b, rfl⟩,
  left_inv := by { rintro ["⟨", ident ab, ",", ident b, ",", ident rfl, "⟩"],
    refl },
  right_inv := assume b, rfl,
  measurable_to_fun := assume (s) (hs : measurable_set s), begin
    refine [expr ⟨_, measurable_set_inr_image hs, set.ext _⟩],
    rintros ["⟨", ident ab, ",", ident b, ",", ident rfl, "⟩"],
    simp [] [] [] ["[", expr set.range_inr._match_1, "]"] [] []
  end,
  measurable_inv_fun := measurable.subtype_mk measurable_inr }

/-- Products distribute over sums (on the right) as measurable spaces. -/
def sum_prod_distrib α β γ [MeasurableSpace α] [MeasurableSpace β] [MeasurableSpace γ] :
  Sum α β × γ ≃ᵐ Sum (α × γ) (β × γ) :=
  { toEquiv := sum_prod_distrib α β γ,
    measurable_to_fun :=
      by 
        refine'
          measurable_of_measurable_union_cover ((range Sum.inl).Prod univ) ((range Sum.inr).Prod univ)
            (measurable_set_range_inl.prod MeasurableSet.univ) (measurable_set_range_inr.prod MeasurableSet.univ)
            (by 
              rintro ⟨a | b, c⟩ <;> simp [Set.prod_eq])
            _ _
        ·
          refine' (Set.Prod (range Sum.inl) univ).symm.measurable_comp_iff.1 _ 
          refine' (prod_congr set.range_inl (Set.Univ _)).symm.measurable_comp_iff.1 _ 
          dsimp [· ∘ ·]
          convert measurable_inl 
          ext ⟨a, c⟩
          rfl
        ·
          refine' (Set.Prod (range Sum.inr) univ).symm.measurable_comp_iff.1 _ 
          refine' (prod_congr set.range_inr (Set.Univ _)).symm.measurable_comp_iff.1 _ 
          dsimp [· ∘ ·]
          convert measurable_inr 
          ext ⟨b, c⟩
          rfl,
    measurable_inv_fun :=
      measurable_sum ((measurable_inl.comp measurable_fst).prod_mk measurable_snd)
        ((measurable_inr.comp measurable_fst).prod_mk measurable_snd) }

/-- Products distribute over sums (on the left) as measurable spaces. -/
def prod_sum_distrib α β γ [MeasurableSpace α] [MeasurableSpace β] [MeasurableSpace γ] :
  α × Sum β γ ≃ᵐ Sum (α × β) (α × γ) :=
  prod_comm.trans$ (sum_prod_distrib _ _ _).trans$ sum_congr prod_comm prod_comm

/-- Products distribute over sums as measurable spaces. -/
def sum_prod_sum α β γ δ [MeasurableSpace α] [MeasurableSpace β] [MeasurableSpace γ] [MeasurableSpace δ] :
  Sum α β × Sum γ δ ≃ᵐ Sum (Sum (α × γ) (α × δ)) (Sum (β × γ) (β × δ)) :=
  (sum_prod_distrib _ _ _).trans$ sum_congr (prod_sum_distrib _ _ _) (prod_sum_distrib _ _ _)

variable{π π' : δ' → Type _}[∀ x, MeasurableSpace (π x)][∀ x, MeasurableSpace (π' x)]

/-- A family of measurable equivalences `Π a, β₁ a ≃ᵐ β₂ a` generates a measurable equivalence
  between  `Π a, β₁ a` and `Π a, β₂ a`. -/
def Pi_congr_right (e : ∀ a, π a ≃ᵐ π' a) : (∀ a, π a) ≃ᵐ ∀ a, π' a :=
  { toEquiv := Pi_congr_right fun a => (e a).toEquiv,
    measurable_to_fun := measurable_pi_lambda _ fun i => (e i).measurable_to_fun.comp (measurable_pi_apply i),
    measurable_inv_fun := measurable_pi_lambda _ fun i => (e i).measurable_inv_fun.comp (measurable_pi_apply i) }

/-- Pi-types are measurably equivalent to iterated products. -/
@[simps (config := { fullyApplied := ff })]
noncomputable def pi_measurable_equiv_tprod {l : List δ'} (hnd : l.nodup) (h : ∀ i, i ∈ l) :
  (∀ i, π i) ≃ᵐ List.Tprod π l :=
  { toEquiv := List.Tprod.piEquivTprod hnd h, measurable_to_fun := measurable_tprod_mk l,
    measurable_inv_fun := measurable_tprod_elim' h }

/-- If `α` has a unique term, then the type of function `α → β` is measurably equivalent to `β`. -/
@[simps (config := { fullyApplied := ff })]
def fun_unique (α β : Type _) [Unique α] [MeasurableSpace β] : (α → β) ≃ᵐ β :=
  { toEquiv := Equiv.funUnique α β, measurable_to_fun := measurable_pi_apply _,
    measurable_inv_fun := measurable_pi_iff.2$ fun b => measurable_id }

/-- The space `Π i : fin 2, α i` is measurably equivalent to `α 0 × α 1`. -/
@[simps (config := { fullyApplied := ff })]
def pi_fin_two (α : Finₓ 2 → Type _) [∀ i, MeasurableSpace (α i)] : (∀ i, α i) ≃ᵐ α 0 × α 1 :=
  { toEquiv := piFinTwoEquiv α, measurable_to_fun := Measurable.prod (measurable_pi_apply _) (measurable_pi_apply _),
    measurable_inv_fun := measurable_pi_iff.2$ Finₓ.forall_fin_two.2 ⟨measurable_fst, measurable_snd⟩ }

/-- The space `fin 2 → α` is measurably equivalent to `α × α`. -/
@[simps (config := { fullyApplied := ff })]
def fin_two_arrow : (Finₓ 2 → α) ≃ᵐ α × α :=
  pi_fin_two fun _ => α

end MeasurableEquiv

namespace MeasurableEmbedding

variable[MeasurableSpace α][MeasurableSpace β][MeasurableSpace γ]{f : α → β}

/-- A measurable embedding defines a measurable equivalence between its domain
and its range. -/
noncomputable def equiv_range (f : α → β) (hf : MeasurableEmbedding f) : α ≃ᵐ range f :=
  { toEquiv := Equiv.ofInjective f hf.injective, measurable_to_fun := hf.measurable.subtype_mk,
    measurable_inv_fun :=
      by 
        rw [coe_of_injective_symm]
        exact hf.measurable_range_splitting }

theorem of_measurable_inverse_on_range {g : range f → α} (hf₁ : Measurable f) (hf₂ : MeasurableSet (range f))
  (hg : Measurable g) (H : left_inverse g (range_factorization f)) : MeasurableEmbedding f :=
  by 
    set e : α ≃ᵐ range f :=
      ⟨⟨range_factorization f, g, H, H.right_inverse_of_surjective surjective_onto_range⟩, hf₁.subtype_mk, hg⟩
    exact (MeasurableEmbedding.subtype_coe hf₂).comp e.measurable_embedding

theorem of_measurable_inverse {g : β → α} (hf₁ : Measurable f) (hf₂ : MeasurableSet (range f)) (hg : Measurable g)
  (H : left_inverse g f) : MeasurableEmbedding f :=
  of_measurable_inverse_on_range hf₁ hf₂ (hg.comp measurable_subtype_coe) H

end MeasurableEmbedding

namespace Filter

variable[MeasurableSpace α]

/-- A filter `f` is measurably generates if each `s ∈ f` includes a measurable `t ∈ f`. -/
class is_measurably_generated(f : Filter α) : Prop where 
  exists_measurable_subset : ∀ ⦃s⦄, s ∈ f → ∃ (t : _)(_ : t ∈ f), MeasurableSet t ∧ t ⊆ s

instance is_measurably_generated_bot : is_measurably_generated (⊥ : Filter α) :=
  ⟨fun _ _ => ⟨∅, mem_bot, MeasurableSet.empty, empty_subset _⟩⟩

instance is_measurably_generated_top : is_measurably_generated (⊤ : Filter α) :=
  ⟨fun s hs => ⟨univ, univ_mem, MeasurableSet.univ, fun x _ => hs x⟩⟩

theorem eventually.exists_measurable_mem {f : Filter α} [is_measurably_generated f] {p : α → Prop} (h : ∀ᶠx in f, p x) :
  ∃ (s : _)(_ : s ∈ f), MeasurableSet s ∧ ∀ x (_ : x ∈ s), p x :=
  is_measurably_generated.exists_measurable_subset h

theorem eventually.exists_measurable_mem_of_lift' {f : Filter α} [is_measurably_generated f] {p : Set α → Prop}
  (h : ∀ᶠs in f.lift' powerset, p s) : ∃ (s : _)(_ : s ∈ f), MeasurableSet s ∧ p s :=
  let ⟨s, hsf, hs⟩ := eventually_lift'_powerset.1 h 
  let ⟨t, htf, htm, hts⟩ := is_measurably_generated.exists_measurable_subset hsf
  ⟨t, htf, htm, hs t hts⟩

instance inf_is_measurably_generated (f g : Filter α) [is_measurably_generated f] [is_measurably_generated g] :
  is_measurably_generated (f⊓g) :=
  by 
    refine' ⟨_⟩
    rintro t ⟨sf, hsf, sg, hsg, rfl⟩
    rcases is_measurably_generated.exists_measurable_subset hsf with ⟨s'f, hs'f, hmf, hs'sf⟩
    rcases is_measurably_generated.exists_measurable_subset hsg with ⟨s'g, hs'g, hmg, hs'sg⟩
    refine' ⟨s'f ∩ s'g, inter_mem_inf hs'f hs'g, hmf.inter hmg, _⟩
    exact inter_subset_inter hs'sf hs'sg

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem principal_is_measurably_generated_iff
{s : set α} : «expr ↔ »(is_measurably_generated (expr𝓟() s), measurable_set s) :=
begin
  refine [expr ⟨_, λ hs, ⟨λ t ht, ⟨s, mem_principal_self s, hs, ht⟩⟩⟩],
  rintros ["⟨", ident hs, "⟩"],
  rcases [expr hs (mem_principal_self s), "with", "⟨", ident t, ",", ident ht, ",", ident htm, ",", ident hts, "⟩"],
  have [] [":", expr «expr = »(t, s)] [":=", expr subset.antisymm hts ht],
  rwa ["<-", expr this] []
end

alias principal_is_measurably_generated_iff ↔ _ MeasurableSet.principal_is_measurably_generated

-- error in MeasureTheory.MeasurableSpace: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
instance infi_is_measurably_generated
{f : ι → filter α}
[∀ i, is_measurably_generated (f i)] : is_measurably_generated «expr⨅ , »((i), f i) :=
begin
  refine [expr ⟨λ s hs, _⟩],
  rw ["[", "<-", expr equiv.plift.surjective.infi_comp, ",", expr mem_infi, "]"] ["at", ident hs],
  rcases [expr hs, "with", "⟨", ident t, ",", ident ht, ",", "⟨", ident V, ",", ident hVf, ",", ident rfl, "⟩", "⟩"],
  choose [] [ident U] [ident hUf, ident hU] ["using", expr λ
   i, is_measurably_generated.exists_measurable_subset (hVf i)],
  refine [expr ⟨«expr⋂ , »((i : t), U i), _, _, _⟩],
  { rw ["[", "<-", expr equiv.plift.surjective.infi_comp, ",", expr mem_infi, "]"] [],
    refine [expr ⟨t, ht, U, hUf, rfl⟩] },
  { haveI [] [] [":=", expr ht.countable.to_encodable],
    refine [expr measurable_set.Inter (λ i, (hU i).1)] },
  { exact [expr Inter_subset_Inter (λ i, (hU i).2)] }
end

end Filter

/-- We say that a collection of sets is countably spanning if a countable subset spans the
  whole type. This is a useful condition in various parts of measure theory. For example, it is
  a needed condition to show that the product of two collections generate the product sigma algebra,
  see `generate_from_prod_eq`. -/
def IsCountablySpanning (C : Set (Set α)) : Prop :=
  ∃ s : ℕ → Set α, (∀ n, s n ∈ C) ∧ (⋃n, s n) = univ

theorem is_countably_spanning_measurable_set [MeasurableSpace α] : IsCountablySpanning { s:Set α | MeasurableSet s } :=
  ⟨fun _ => univ, fun _ => MeasurableSet.univ, Union_const _⟩

namespace MeasurableSet

/-!
### Typeclasses on `subtype measurable_set`
-/


variable[MeasurableSpace α]

instance  : HasMem α (Subtype (MeasurableSet : Set α → Prop)) :=
  ⟨fun a s => a ∈ (s : Set α)⟩

@[simp]
theorem mem_coe (a : α) (s : Subtype (MeasurableSet : Set α → Prop)) : a ∈ (s : Set α) ↔ a ∈ s :=
  Iff.rfl

instance  : HasEmptyc (Subtype (MeasurableSet : Set α → Prop)) :=
  ⟨⟨∅, MeasurableSet.empty⟩⟩

@[simp]
theorem coe_empty : «expr↑ » (∅ : Subtype (MeasurableSet : Set α → Prop)) = (∅ : Set α) :=
  rfl

instance  [MeasurableSingletonClass α] : HasInsert α (Subtype (MeasurableSet : Set α → Prop)) :=
  ⟨fun a s => ⟨HasInsert.insert a s, s.prop.insert a⟩⟩

@[simp]
theorem coe_insert [MeasurableSingletonClass α] (a : α) (s : Subtype (MeasurableSet : Set α → Prop)) :
  «expr↑ » (HasInsert.insert a s) = (HasInsert.insert a s : Set α) :=
  rfl

instance  : HasCompl (Subtype (MeasurableSet : Set α → Prop)) :=
  ⟨fun x => ⟨«expr ᶜ» x, x.prop.compl⟩⟩

@[simp]
theorem coe_compl (s : Subtype (MeasurableSet : Set α → Prop)) : «expr↑ » («expr ᶜ» s) = («expr ᶜ» s : Set α) :=
  rfl

instance  : HasUnion (Subtype (MeasurableSet : Set α → Prop)) :=
  ⟨fun x y => ⟨x ∪ y, x.prop.union y.prop⟩⟩

@[simp]
theorem coe_union (s t : Subtype (MeasurableSet : Set α → Prop)) : «expr↑ » (s ∪ t) = (s ∪ t : Set α) :=
  rfl

instance  : HasInter (Subtype (MeasurableSet : Set α → Prop)) :=
  ⟨fun x y => ⟨x ∩ y, x.prop.inter y.prop⟩⟩

@[simp]
theorem coe_inter (s t : Subtype (MeasurableSet : Set α → Prop)) : «expr↑ » (s ∩ t) = (s ∩ t : Set α) :=
  rfl

instance  : HasSdiff (Subtype (MeasurableSet : Set α → Prop)) :=
  ⟨fun x y => ⟨x \ y, x.prop.diff y.prop⟩⟩

@[simp]
theorem coe_sdiff (s t : Subtype (MeasurableSet : Set α → Prop)) : «expr↑ » (s \ t) = (s \ t : Set α) :=
  rfl

instance  : HasBot (Subtype (MeasurableSet : Set α → Prop)) :=
  ⟨⟨⊥, MeasurableSet.empty⟩⟩

@[simp]
theorem coe_bot : «expr↑ » (⊥ : Subtype (MeasurableSet : Set α → Prop)) = (⊥ : Set α) :=
  rfl

instance  : HasTop (Subtype (MeasurableSet : Set α → Prop)) :=
  ⟨⟨⊤, MeasurableSet.univ⟩⟩

@[simp]
theorem coe_top : «expr↑ » (⊤ : Subtype (MeasurableSet : Set α → Prop)) = (⊤ : Set α) :=
  rfl

instance  : PartialOrderₓ (Subtype (MeasurableSet : Set α → Prop)) :=
  PartialOrderₓ.lift _ Subtype.coe_injective

instance  : DistribLattice (Subtype (MeasurableSet : Set α → Prop)) :=
  { MeasurableSet.Subtype.partialOrder with sup := · ∪ ·,
    le_sup_left := fun a b => show (a : Set α) ≤ a⊔b from le_sup_left,
    le_sup_right := fun a b => show (b : Set α) ≤ a⊔b from le_sup_right,
    sup_le := fun a b c ha hb => show (a⊔b : Set α) ≤ c from sup_le ha hb, inf := · ∩ ·,
    inf_le_left := fun a b => show (a⊓b : Set α) ≤ a from inf_le_left,
    inf_le_right := fun a b => show (a⊓b : Set α) ≤ b from inf_le_right,
    le_inf := fun a b c ha hb => show (a : Set α) ≤ b⊓c from le_inf ha hb,
    le_sup_inf := fun x y z => show ((x⊔y)⊓(x⊔z) : Set α) ≤ x⊔y⊓z from le_sup_inf }

instance  : BoundedOrder (Subtype (MeasurableSet : Set α → Prop)) :=
  { top := ⊤, le_top := fun a => show (a : Set α) ≤ ⊤ from le_top, bot := ⊥,
    bot_le := fun a => show (⊥ : Set α) ≤ a from bot_le }

instance  : BooleanAlgebra (Subtype (MeasurableSet : Set α → Prop)) :=
  { MeasurableSet.Subtype.boundedOrder, MeasurableSet.Subtype.distribLattice with sdiff := · \ ·,
    sup_inf_sdiff := fun a b => Subtype.eq$ sup_inf_sdiff a b,
    inf_inf_sdiff := fun a b => Subtype.eq$ inf_inf_sdiff a b, Compl := HasCompl.compl,
    inf_compl_le_bot := fun a => BooleanAlgebra.inf_compl_le_bot (a : Set α),
    top_le_sup_compl := fun a => BooleanAlgebra.top_le_sup_compl (a : Set α),
    sdiff_eq := fun a b => Subtype.eq$ sdiff_eq }

end MeasurableSet

