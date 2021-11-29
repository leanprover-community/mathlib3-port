import Mathbin.Order.Filter.Basic 
import Mathbin.Data.Set.Countable 
import Mathbin.Data.Pprod

/-!
# Filter bases

A filter basis `B : filter_basis α` on a type `α` is a nonempty collection of sets of `α`
such that the intersection of two elements of this collection contains some element of
the collection. Compared to filters, filter bases do not require that any set containing
an element of `B` belongs to `B`.
A filter basis `B` can be used to construct `B.filter : filter α` such that a set belongs
to `B.filter` if and only if it contains an element of `B`.

Given an indexing type `ι`, a predicate `p : ι → Prop`, and a map `s : ι → set α`,
the proposition `h : filter.is_basis p s` makes sure the range of `s` bounded by `p`
(ie. `s '' set_of p`) defines a filter basis `h.filter_basis`.

If one already has a filter `l` on `α`, `filter.has_basis l p s` (where `p : ι → Prop`
and `s : ι → set α` as above) means that a set belongs to `l` if and
only if it contains some `s i` with `p i`. It implies `h : filter.is_basis p s`, and
`l = h.filter_basis.filter`. The point of this definition is that checking statements
involving elements of `l` often reduces to checking them on the basis elements.

We define a function `has_basis.index (h : filter.has_basis l p s) (t) (ht : t ∈ l)` that returns
some index `i` such that `p i` and `s i ⊆ t`. This function can be useful to avoid manual
destruction of `h.mem_iff.mpr ht` using `cases` or `let`.

This file also introduces more restricted classes of bases, involving monotonicity or
countability. In particular, for `l : filter α`, `l.is_countably_generated` means
there is a countable set of sets which generates `s`. This is reformulated in term of bases,
and consequences are derived.

## Main statements

* `has_basis.mem_iff`, `has_basis.mem_of_superset`, `has_basis.mem_of_mem` : restate `t ∈ f`
  in terms of a basis;
* `basis_sets` : all sets of a filter form a basis;
* `has_basis.inf`, `has_basis.inf_principal`, `has_basis.prod`, `has_basis.prod_self`,
  `has_basis.map`, `has_basis.comap` : combinators to construct filters of `l ⊓ l'`,
  `l ⊓ 𝓟 t`, `l ×ᶠ l'`, `l ×ᶠ l`, `l.map f`, `l.comap f` respectively;
* `has_basis.le_iff`, `has_basis.ge_iff`, has_basis.le_basis_iff` : restate `l ≤ l'` in terms
  of bases.
* `has_basis.tendsto_right_iff`, `has_basis.tendsto_left_iff`, `has_basis.tendsto_iff` : restate
  `tendsto f l l'` in terms of bases.
* `is_countably_generated_iff_exists_antitone_basis` : proves a filter is
  countably generated if and only if it admits a basis parametrized by a
  decreasing sequence of sets indexed by `ℕ`.
* `tendsto_iff_seq_tendsto ` : an abstract version of "sequentially continuous implies continuous".

## Implementation notes

As with `Union`/`bUnion`/`sUnion`, there are three different approaches to filter bases:

* `has_basis l s`, `s : set (set α)`;
* `has_basis l s`, `s : ι → set α`;
* `has_basis l p s`, `p : ι → Prop`, `s : ι → set α`.

We use the latter one because, e.g., `𝓝 x` in an `emetric_space` or in a `metric_space` has a basis
of this form. The other two can be emulated using `s = id` or `p = λ _, true`.

With this approach sometimes one needs to `simp` the statement provided by the `has_basis`
machinery, e.g., `simp only [exists_prop, true_and]` or `simp only [forall_const]` can help
with the case `p = λ _, true`.
-/


open Set Filter

open_locale Filter Classical

section Sort

variable{α β γ : Type _}{ι ι' : Sort _}

/-- A filter basis `B` on a type `α` is a nonempty collection of sets of `α`
such that the intersection of two elements of this collection contains some element
of the collection. -/
structure FilterBasis(α : Type _) where 
  Sets : Set (Set α)
  Nonempty : sets.nonempty 
  inter_sets {x y} : x ∈ sets → y ∈ sets → ∃ (z : _)(_ : z ∈ sets), z ⊆ x ∩ y

instance FilterBasis.nonempty_sets (B : FilterBasis α) : Nonempty B.sets :=
  B.nonempty.to_subtype

/-- If `B` is a filter basis on `α`, and `U` a subset of `α` then we can write `U ∈ B` as
on paper. -/
@[reducible]
instance  {α : Type _} : HasMem (Set α) (FilterBasis α) :=
  ⟨fun U B => U ∈ B.sets⟩

instance  : Inhabited (FilterBasis ℕ) :=
  ⟨{ Sets := range Ici, Nonempty := ⟨Ici 0, mem_range_self 0⟩,
      inter_sets :=
        by 
          rintro _ _ ⟨n, rfl⟩ ⟨m, rfl⟩
          refine' ⟨Ici (max n m), mem_range_self _, _⟩
          rintro p p_in 
          split  <;> rw [mem_Ici] at *
          exact le_of_max_le_left p_in 
          exact le_of_max_le_right p_in }⟩

/-- `is_basis p s` means the image of `s` bounded by `p` is a filter basis. -/
protected structure Filter.IsBasis(p : ι → Prop)(s : ι → Set α) : Prop where 
  Nonempty : ∃ i, p i 
  inter : ∀ {i j}, p i → p j → ∃ k, p k ∧ s k ⊆ s i ∩ s j

namespace Filter

namespace IsBasis

/-- Constructs a filter basis from an indexed family of sets satisfying `is_basis`. -/
protected def FilterBasis {p : ι → Prop} {s : ι → Set α} (h : is_basis p s) : FilterBasis α :=
  { Sets := { t | ∃ i, p i ∧ s i = t },
    Nonempty :=
      let ⟨i, hi⟩ := h.nonempty
      ⟨s i, ⟨i, hi, rfl⟩⟩,
    inter_sets :=
      by 
        rintro _ _ ⟨i, hi, rfl⟩ ⟨j, hj, rfl⟩
        rcases h.inter hi hj with ⟨k, hk, hk'⟩
        exact ⟨_, ⟨k, hk, rfl⟩, hk'⟩ }

variable{p : ι → Prop}{s : ι → Set α}(h : is_basis p s)

theorem mem_filter_basis_iff {U : Set α} : U ∈ h.filter_basis ↔ ∃ i, p i ∧ s i = U :=
  Iff.rfl

end IsBasis

end Filter

namespace FilterBasis

/-- The filter associated to a filter basis. -/
protected def Filter (B : FilterBasis α) : Filter α :=
  { Sets := { s | ∃ (t : _)(_ : t ∈ B), t ⊆ s },
    univ_sets :=
      let ⟨s, s_in⟩ := B.nonempty
      ⟨s, s_in, s.subset_univ⟩,
    sets_of_superset := fun x y ⟨s, s_in, h⟩ hxy => ⟨s, s_in, Set.Subset.trans h hxy⟩,
    inter_sets :=
      fun x y ⟨s, s_in, hs⟩ ⟨t, t_in, ht⟩ =>
        let ⟨u, u_in, u_sub⟩ := B.inter_sets s_in t_in
        ⟨u, u_in, Set.Subset.trans u_sub$ Set.inter_subset_inter hs ht⟩ }

theorem mem_filter_iff (B : FilterBasis α) {U : Set α} : U ∈ B.filter ↔ ∃ (s : _)(_ : s ∈ B), s ⊆ U :=
  Iff.rfl

theorem mem_filter_of_mem (B : FilterBasis α) {U : Set α} : U ∈ B → U ∈ B.filter :=
  fun U_in => ⟨U, U_in, subset.refl _⟩

-- error in Order.Filter.Bases: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem eq_infi_principal (B : filter_basis α) : «expr = »(B.filter, «expr⨅ , »((s : B.sets), expr𝓟() s)) :=
begin
  have [] [":", expr directed ((«expr ≥ »)) (λ s : B.sets, expr𝓟() (s : set α))] [],
  { rintros ["⟨", ident U, ",", ident U_in, "⟩", "⟨", ident V, ",", ident V_in, "⟩"],
    rcases [expr B.inter_sets U_in V_in, "with", "⟨", ident W, ",", ident W_in, ",", ident W_sub, "⟩"],
    use ["[", expr W, ",", expr W_in, "]"],
    finish [] [] },
  ext [] [ident U] [],
  simp [] [] [] ["[", expr mem_filter_iff, ",", expr mem_infi_of_directed this, "]"] [] []
end

protected theorem generate (B : FilterBasis α) : generate B.sets = B.filter :=
  by 
    apply le_antisymmₓ
    ·
      intro U U_in 
      rcases B.mem_filter_iff.mp U_in with ⟨V, V_in, h⟩
      exact generate_sets.superset (generate_sets.basic V_in) h
    ·
      rw [sets_iff_generate]
      apply mem_filter_of_mem

end FilterBasis

namespace Filter

namespace IsBasis

variable{p : ι → Prop}{s : ι → Set α}

/-- Constructs a filter from an indexed family of sets satisfying `is_basis`. -/
protected def Filter (h : is_basis p s) : Filter α :=
  h.filter_basis.filter

protected theorem mem_filter_iff (h : is_basis p s) {U : Set α} : U ∈ h.filter ↔ ∃ i, p i ∧ s i ⊆ U :=
  by 
    erw [h.filter_basis.mem_filter_iff]
    simp only [mem_filter_basis_iff h, exists_prop]
    split 
    ·
      rintro ⟨_, ⟨i, pi, rfl⟩, h⟩
      tauto
    ·
      tauto

theorem filter_eq_generate (h : is_basis p s) : h.filter = generate { U | ∃ i, p i ∧ s i = U } :=
  by 
    erw [h.filter_basis.generate] <;> rfl

end IsBasis

/-- We say that a filter `l` has a basis `s : ι → set α` bounded by `p : ι → Prop`,
if `t ∈ l` if and only if `t` includes `s i` for some `i` such that `p i`. -/
protected structure has_basis(l : Filter α)(p : ι → Prop)(s : ι → Set α) : Prop where 
  mem_iff' : ∀ (t : Set α), t ∈ l ↔ ∃ (i : _)(hi : p i), s i ⊆ t

section SameType

variable{l l' : Filter α}{p : ι → Prop}{s : ι → Set α}{t : Set α}{i : ι}{p' : ι' → Prop}{s' : ι' → Set α}{i' : ι'}

theorem has_basis_generate (s : Set (Set α)) : (generate s).HasBasis (fun t => finite t ∧ t ⊆ s) fun t => ⋂₀t :=
  ⟨by 
      intro U 
      rw [mem_generate_iff]
      apply exists_congr 
      tauto⟩

/-- The smallest filter basis containing a given collection of sets. -/
def filter_basis.of_sets (s : Set (Set α)) : FilterBasis α :=
  { Sets := sInter '' { t | finite t ∧ t ⊆ s }, Nonempty := ⟨univ, ∅, ⟨⟨finite_empty, empty_subset s⟩, sInter_empty⟩⟩,
    inter_sets :=
      by 
        rintro _ _ ⟨a, ⟨fina, suba⟩, rfl⟩ ⟨b, ⟨finb, subb⟩, rfl⟩
        exact
          ⟨⋂₀(a ∪ b), mem_image_of_mem _ ⟨fina.union finb, union_subset suba subb⟩,
            by 
              rw [sInter_union]⟩ }

/-- Definition of `has_basis` unfolded with implicit set argument. -/
theorem has_basis.mem_iff (hl : l.has_basis p s) : t ∈ l ↔ ∃ (i : _)(hi : p i), s i ⊆ t :=
  hl.mem_iff' t

theorem has_basis.eq_of_same_basis (hl : l.has_basis p s) (hl' : l'.has_basis p s) : l = l' :=
  by 
    ext t 
    rw [hl.mem_iff, hl'.mem_iff]

theorem has_basis_iff : l.has_basis p s ↔ ∀ t, t ∈ l ↔ ∃ (i : _)(hi : p i), s i ⊆ t :=
  ⟨fun ⟨h⟩ => h, fun h => ⟨h⟩⟩

theorem has_basis.ex_mem (h : l.has_basis p s) : ∃ i, p i :=
  let ⟨i, pi, h⟩ := h.mem_iff.mp univ_mem
  ⟨i, pi⟩

protected theorem has_basis.nonempty (h : l.has_basis p s) : Nonempty ι :=
  nonempty_of_exists h.ex_mem

protected theorem is_basis.has_basis (h : is_basis p s) : has_basis h.filter p s :=
  ⟨fun t =>
      by 
        simp only [h.mem_filter_iff, exists_prop]⟩

theorem has_basis.mem_of_superset (hl : l.has_basis p s) (hi : p i) (ht : s i ⊆ t) : t ∈ l :=
  hl.mem_iff.2 ⟨i, hi, ht⟩

theorem has_basis.mem_of_mem (hl : l.has_basis p s) (hi : p i) : s i ∈ l :=
  hl.mem_of_superset hi$ subset.refl _

/-- Index of a basis set such that `s i ⊆ t` as an element of `subtype p`. -/
noncomputable def has_basis.index (h : l.has_basis p s) (t : Set α) (ht : t ∈ l) : { i : ι // p i } :=
  ⟨(h.mem_iff.1 ht).some, (h.mem_iff.1 ht).some_spec.fst⟩

theorem has_basis.property_index (h : l.has_basis p s) (ht : t ∈ l) : p (h.index t ht) :=
  (h.index t ht).2

theorem has_basis.set_index_mem (h : l.has_basis p s) (ht : t ∈ l) : s (h.index t ht) ∈ l :=
  h.mem_of_mem$ h.property_index _

theorem has_basis.set_index_subset (h : l.has_basis p s) (ht : t ∈ l) : s (h.index t ht) ⊆ t :=
  (h.mem_iff.1 ht).some_spec.snd

theorem has_basis.is_basis (h : l.has_basis p s) : is_basis p s :=
  { Nonempty :=
      let ⟨i, hi, H⟩ := h.mem_iff.mp univ_mem
      ⟨i, hi⟩,
    inter :=
      fun i j hi hj =>
        by 
          simpa [h.mem_iff] using l.inter_sets (h.mem_of_mem hi) (h.mem_of_mem hj) }

theorem has_basis.filter_eq (h : l.has_basis p s) : h.is_basis.filter = l :=
  by 
    ext U 
    simp [h.mem_iff, is_basis.mem_filter_iff]

theorem has_basis.eq_generate (h : l.has_basis p s) : l = generate { U | ∃ i, p i ∧ s i = U } :=
  by 
    rw [←h.is_basis.filter_eq_generate, h.filter_eq]

theorem generate_eq_generate_inter (s : Set (Set α)) : generate s = generate (sInter '' { t | finite t ∧ t ⊆ s }) :=
  by 
    erw [(filter_basis.of_sets s).generate, ←(has_basis_generate s).filter_eq] <;> rfl

theorem of_sets_filter_eq_generate (s : Set (Set α)) : (filter_basis.of_sets s).filter = generate s :=
  by 
    rw [←(filter_basis.of_sets s).generate, generate_eq_generate_inter s] <;> rfl

-- error in Order.Filter.Bases: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
protected
theorem _root_.filter_basis.has_basis
{α : Type*}
(B : filter_basis α) : has_basis B.filter (λ s : set α, «expr ∈ »(s, B)) id :=
⟨λ t, B.mem_filter_iff⟩

theorem has_basis.to_has_basis' (hl : l.has_basis p s) (h : ∀ i, p i → ∃ i', p' i' ∧ s' i' ⊆ s i)
  (h' : ∀ i', p' i' → s' i' ∈ l) : l.has_basis p' s' :=
  by 
    refine' ⟨fun t => ⟨fun ht => _, fun ⟨i', hi', ht⟩ => mem_of_superset (h' i' hi') ht⟩⟩
    rcases hl.mem_iff.1 ht with ⟨i, hi, ht⟩
    rcases h i hi with ⟨i', hi', hs's⟩
    exact ⟨i', hi', subset.trans hs's ht⟩

theorem has_basis.to_has_basis (hl : l.has_basis p s) (h : ∀ i, p i → ∃ i', p' i' ∧ s' i' ⊆ s i)
  (h' : ∀ i', p' i' → ∃ i, p i ∧ s i ⊆ s' i') : l.has_basis p' s' :=
  hl.to_has_basis' h$
    fun i' hi' =>
      let ⟨i, hi, hss'⟩ := h' i' hi' 
      hl.mem_iff.2 ⟨i, hi, hss'⟩

theorem has_basis.to_subset (hl : l.has_basis p s) {t : ι → Set α} (h : ∀ i, p i → t i ⊆ s i)
  (ht : ∀ i, p i → t i ∈ l) : l.has_basis p t :=
  hl.to_has_basis' (fun i hi => ⟨i, hi, h i hi⟩) ht

theorem has_basis.eventually_iff (hl : l.has_basis p s) {q : α → Prop} :
  (∀ᶠx in l, q x) ↔ ∃ i, p i ∧ ∀ ⦃x⦄, x ∈ s i → q x :=
  by 
    simpa using hl.mem_iff

theorem has_basis.frequently_iff (hl : l.has_basis p s) {q : α → Prop} :
  (∃ᶠx in l, q x) ↔ ∀ i, p i → ∃ (x : _)(_ : x ∈ s i), q x :=
  by 
    simp [Filter.Frequently, hl.eventually_iff]

theorem has_basis.exists_iff (hl : l.has_basis p s) {P : Set α → Prop} (mono : ∀ ⦃s t⦄, s ⊆ t → P t → P s) :
  (∃ (s : _)(_ : s ∈ l), P s) ↔ ∃ (i : _)(hi : p i), P (s i) :=
  ⟨fun ⟨s, hs, hP⟩ =>
      let ⟨i, hi, his⟩ := hl.mem_iff.1 hs
      ⟨i, hi, mono his hP⟩,
    fun ⟨i, hi, hP⟩ => ⟨s i, hl.mem_of_mem hi, hP⟩⟩

theorem has_basis.forall_iff (hl : l.has_basis p s) {P : Set α → Prop} (mono : ∀ ⦃s t⦄, s ⊆ t → P s → P t) :
  (∀ s (_ : s ∈ l), P s) ↔ ∀ i, p i → P (s i) :=
  ⟨fun H i hi => H (s i)$ hl.mem_of_mem hi,
    fun H s hs =>
      let ⟨i, hi, his⟩ := hl.mem_iff.1 hs 
      mono his (H i hi)⟩

theorem has_basis.ne_bot_iff (hl : l.has_basis p s) : ne_bot l ↔ ∀ {i}, p i → (s i).Nonempty :=
  forall_mem_nonempty_iff_ne_bot.symm.trans$ hl.forall_iff$ fun _ _ => nonempty.mono

theorem has_basis.eq_bot_iff (hl : l.has_basis p s) : l = ⊥ ↔ ∃ i, p i ∧ s i = ∅ :=
  not_iff_not.1$
    ne_bot_iff.symm.trans$
      hl.ne_bot_iff.trans$
        by 
          simp only [not_exists, not_and, ←ne_empty_iff_nonempty]

-- error in Order.Filter.Bases: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem basis_sets (l : filter α) : l.has_basis (λ s : set α, «expr ∈ »(s, l)) id := ⟨λ t, exists_mem_subset_iff.symm⟩

theorem has_basis_self {l : Filter α} {P : Set α → Prop} :
  has_basis l (fun s => s ∈ l ∧ P s) id ↔ ∀ t (_ : t ∈ l), ∃ (r : _)(_ : r ∈ l), P r ∧ r ⊆ t :=
  by 
    simp only [has_basis_iff, exists_prop, id, and_assoc]
    exact forall_congrₓ fun s => ⟨fun h => h.1, fun h => ⟨h, fun ⟨t, hl, hP, hts⟩ => mem_of_superset hl hts⟩⟩

/-- If `{s i | p i}` is a basis of a filter `l` and each `s i` includes `s j` such that
`p j ∧ q j`, then `{s j | p j ∧ q j}` is a basis of `l`. -/
theorem has_basis.restrict (h : l.has_basis p s) {q : ι → Prop} (hq : ∀ i, p i → ∃ j, p j ∧ q j ∧ s j ⊆ s i) :
  l.has_basis (fun i => p i ∧ q i) s :=
  by 
    refine' ⟨fun t => ⟨fun ht => _, fun ⟨i, hpi, hti⟩ => h.mem_iff.2 ⟨i, hpi.1, hti⟩⟩⟩
    rcases h.mem_iff.1 ht with ⟨i, hpi, hti⟩
    rcases hq i hpi with ⟨j, hpj, hqj, hji⟩
    exact ⟨j, ⟨hpj, hqj⟩, subset.trans hji hti⟩

/-- If `{s i | p i}` is a basis of a filter `l` and `V ∈ l`, then `{s i | p i ∧ s i ⊆ V}`
is a basis of `l`. -/
theorem has_basis.restrict_subset (h : l.has_basis p s) {V : Set α} (hV : V ∈ l) :
  l.has_basis (fun i => p i ∧ s i ⊆ V) s :=
  h.restrict$
    fun i hi => (h.mem_iff.1 (inter_mem hV (h.mem_of_mem hi))).imp$ fun j hj => ⟨hj.fst, subset_inter_iff.1 hj.snd⟩

theorem has_basis.has_basis_self_subset {p : Set α → Prop} (h : l.has_basis (fun s => s ∈ l ∧ p s) id) {V : Set α}
  (hV : V ∈ l) : l.has_basis (fun s => s ∈ l ∧ p s ∧ s ⊆ V) id :=
  by 
    simpa only [and_assoc] using h.restrict_subset hV

theorem has_basis.ge_iff (hl' : l'.has_basis p' s') : l ≤ l' ↔ ∀ i', p' i' → s' i' ∈ l :=
  ⟨fun h i' hi' => h$ hl'.mem_of_mem hi',
    fun h s hs =>
      let ⟨i', hi', hs⟩ := hl'.mem_iff.1 hs 
      mem_of_superset (h _ hi') hs⟩

theorem has_basis.le_iff (hl : l.has_basis p s) : l ≤ l' ↔ ∀ t (_ : t ∈ l'), ∃ (i : _)(hi : p i), s i ⊆ t :=
  by 
    simp only [le_def, hl.mem_iff]

theorem has_basis.le_basis_iff (hl : l.has_basis p s) (hl' : l'.has_basis p' s') :
  l ≤ l' ↔ ∀ i', p' i' → ∃ (i : _)(hi : p i), s i ⊆ s' i' :=
  by 
    simp only [hl'.ge_iff, hl.mem_iff]

theorem has_basis.ext (hl : l.has_basis p s) (hl' : l'.has_basis p' s') (h : ∀ i, p i → ∃ i', p' i' ∧ s' i' ⊆ s i)
  (h' : ∀ i', p' i' → ∃ i, p i ∧ s i ⊆ s' i') : l = l' :=
  by 
    apply le_antisymmₓ
    ·
      rw [hl.le_basis_iff hl']
      simpa using h'
    ·
      rw [hl'.le_basis_iff hl]
      simpa using h

-- error in Order.Filter.Bases: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem has_basis.inf'
(hl : l.has_basis p s)
(hl' : l'.has_basis p' s') : «expr ⊓ »(l, l').has_basis (λ
 i : pprod ι ι', «expr ∧ »(p i.1, p' i.2)) (λ i, «expr ∩ »(s i.1, s' i.2)) :=
⟨begin
   intro [ident t],
   split,
   { simp [] [] ["only"] ["[", expr mem_inf_iff, ",", expr exists_prop, ",", expr hl.mem_iff, ",", expr hl'.mem_iff, "]"] [] [],
     rintros ["⟨", ident t, ",", "⟨", ident i, ",", ident hi, ",", ident ht, "⟩", ",", ident t', ",", "⟨", ident i', ",", ident hi', ",", ident ht', "⟩", ",", ident rfl, "⟩"],
     use ["[", expr ⟨i, i'⟩, ",", expr ⟨hi, hi'⟩, ",", expr inter_subset_inter ht ht', "]"] },
   { rintros ["⟨", "⟨", ident i, ",", ident i', "⟩", ",", "⟨", ident hi, ",", ident hi', "⟩", ",", ident H, "⟩"],
     exact [expr mem_inf_of_inter (hl.mem_of_mem hi) (hl'.mem_of_mem hi') H] }
 end⟩

-- error in Order.Filter.Bases: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem has_basis.inf
{ι ι' : Type*}
{p : ι → exprProp()}
{s : ι → set α}
{p' : ι' → exprProp()}
{s' : ι' → set α}
(hl : l.has_basis p s)
(hl' : l'.has_basis p' s') : «expr ⊓ »(l, l').has_basis (λ
 i : «expr × »(ι, ι'), «expr ∧ »(p i.1, p' i.2)) (λ i, «expr ∩ »(s i.1, s' i.2)) :=
(hl.inf' hl').to_has_basis (λ i hi, ⟨⟨i.1, i.2⟩, hi, subset.rfl⟩) (λ i hi, ⟨⟨i.1, i.2⟩, hi, subset.rfl⟩)

-- error in Order.Filter.Bases: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem has_basis_principal (t : set α) : (expr𝓟() t).has_basis (λ i : unit, true) (λ i, t) :=
⟨λ U, by simp [] [] [] [] [] []⟩

-- error in Order.Filter.Bases: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem has_basis_pure (x : α) : (pure x : filter α).has_basis (λ i : unit, true) (λ i, {x}) :=
by simp [] [] ["only"] ["[", "<-", expr principal_singleton, ",", expr has_basis_principal, "]"] [] []

-- error in Order.Filter.Bases: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem has_basis.sup'
(hl : l.has_basis p s)
(hl' : l'.has_basis p' s') : «expr ⊔ »(l, l').has_basis (λ
 i : pprod ι ι', «expr ∧ »(p i.1, p' i.2)) (λ i, «expr ∪ »(s i.1, s' i.2)) :=
⟨begin
   intros [ident t],
   simp [] [] ["only"] ["[", expr mem_sup, ",", expr hl.mem_iff, ",", expr hl'.mem_iff, ",", expr pprod.exists, ",", expr union_subset_iff, ",", expr exists_prop, ",", expr and_assoc, ",", expr exists_and_distrib_left, "]"] [] [],
   simp [] [] ["only"] ["[", "<-", expr and_assoc, ",", expr exists_and_distrib_right, ",", expr and_comm, "]"] [] []
 end⟩

-- error in Order.Filter.Bases: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem has_basis.sup
{ι ι' : Type*}
{p : ι → exprProp()}
{s : ι → set α}
{p' : ι' → exprProp()}
{s' : ι' → set α}
(hl : l.has_basis p s)
(hl' : l'.has_basis p' s') : «expr ⊔ »(l, l').has_basis (λ
 i : «expr × »(ι, ι'), «expr ∧ »(p i.1, p' i.2)) (λ i, «expr ∪ »(s i.1, s' i.2)) :=
(hl.sup' hl').to_has_basis (λ i hi, ⟨⟨i.1, i.2⟩, hi, subset.rfl⟩) (λ i hi, ⟨⟨i.1, i.2⟩, hi, subset.rfl⟩)

-- error in Order.Filter.Bases: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem has_basis_supr
{ι : Sort*}
{ι' : ι → Type*}
{l : ι → filter α}
{p : ∀ i, ι' i → exprProp()}
{s : ∀ i, ι' i → set α}
(hl : ∀
 i, (l i).has_basis (p i) (s i)) : «expr⨆ , »((i), l i).has_basis (λ
 f : ∀ i, ι' i, ∀ i, p i (f i)) (λ f : ∀ i, ι' i, «expr⋃ , »((i), s i (f i))) :=
«expr $ »(has_basis_iff.mpr, λ
 t, by simp [] [] ["only"] ["[", expr has_basis_iff, ",", expr (hl _).mem_iff, ",", expr classical.skolem, ",", expr forall_and_distrib, ",", expr Union_subset_iff, ",", expr mem_supr, "]"] [] [])

theorem has_basis.sup_principal (hl : l.has_basis p s) (t : Set α) : (l⊔𝓟 t).HasBasis p fun i => s i ∪ t :=
  ⟨fun u =>
      by 
        simp only [(hl.sup' (has_basis_principal t)).mem_iff, PProd.exists, exists_prop, and_trueₓ, Unique.exists_iff]⟩

theorem has_basis.sup_pure (hl : l.has_basis p s) (x : α) : (l⊔pure x).HasBasis p fun i => s i ∪ {x} :=
  by 
    simp only [←principal_singleton, hl.sup_principal]

theorem has_basis.inf_principal (hl : l.has_basis p s) (s' : Set α) : (l⊓𝓟 s').HasBasis p fun i => s i ∩ s' :=
  ⟨fun t =>
      by 
        simp only [mem_inf_principal, hl.mem_iff, subset_def, mem_set_of_eq, mem_inter_iff, and_imp]⟩

theorem has_basis.inf_basis_ne_bot_iff (hl : l.has_basis p s) (hl' : l'.has_basis p' s') :
  ne_bot (l⊓l') ↔ ∀ ⦃i⦄ (hi : p i) ⦃i'⦄ (hi' : p' i'), (s i ∩ s' i').Nonempty :=
  (hl.inf' hl').ne_bot_iff.trans$
    by 
      simp [@forall_swap _ ι']

theorem has_basis.inf_ne_bot_iff (hl : l.has_basis p s) :
  ne_bot (l⊓l') ↔ ∀ ⦃i⦄ (hi : p i) ⦃s'⦄ (hs' : s' ∈ l'), (s i ∩ s').Nonempty :=
  hl.inf_basis_ne_bot_iff l'.basis_sets

theorem has_basis.inf_principal_ne_bot_iff (hl : l.has_basis p s) {t : Set α} :
  ne_bot (l⊓𝓟 t) ↔ ∀ ⦃i⦄ (hi : p i), (s i ∩ t).Nonempty :=
  (hl.inf_principal t).ne_bot_iff

theorem inf_ne_bot_iff : ne_bot (l⊓l') ↔ ∀ ⦃s : Set α⦄ (hs : s ∈ l) ⦃s'⦄ (hs' : s' ∈ l'), (s ∩ s').Nonempty :=
  l.basis_sets.inf_ne_bot_iff

theorem inf_principal_ne_bot_iff {s : Set α} : ne_bot (l⊓𝓟 s) ↔ ∀ U (_ : U ∈ l), (U ∩ s).Nonempty :=
  l.basis_sets.inf_principal_ne_bot_iff

theorem inf_eq_bot_iff {f g : Filter α} : f⊓g = ⊥ ↔ ∃ (U : _)(_ : U ∈ f)(V : _)(_ : V ∈ g), U ∩ V = ∅ :=
  not_iff_not.1$
    ne_bot_iff.symm.trans$
      inf_ne_bot_iff.trans$
        by 
          simp [←ne_empty_iff_nonempty]

protected theorem disjoint_iff {f g : Filter α} : Disjoint f g ↔ ∃ (U : _)(_ : U ∈ f)(V : _)(_ : V ∈ g), U ∩ V = ∅ :=
  disjoint_iff.trans inf_eq_bot_iff

theorem mem_iff_inf_principal_compl {f : Filter α} {s : Set α} : s ∈ f ↔ f⊓𝓟 («expr ᶜ» s) = ⊥ :=
  by 
    refine' not_iff_not.1 ((inf_principal_ne_bot_iff.trans _).symm.trans ne_bot_iff)
    exact
      ⟨fun h hs =>
          by 
            simpa [empty_not_nonempty] using h s hs,
        fun hs t ht => inter_compl_nonempty_iff.2$ fun hts => hs$ mem_of_superset ht hts⟩

theorem not_mem_iff_inf_principal_compl {f : Filter α} {s : Set α} : s ∉ f ↔ ne_bot (f⊓𝓟 («expr ᶜ» s)) :=
  (not_congr mem_iff_inf_principal_compl).trans ne_bot_iff.symm

theorem mem_iff_disjoint_principal_compl {f : Filter α} {s : Set α} : s ∈ f ↔ Disjoint f (𝓟 («expr ᶜ» s)) :=
  mem_iff_inf_principal_compl.trans disjoint_iff.symm

theorem le_iff_forall_disjoint_principal_compl {f g : Filter α} :
  f ≤ g ↔ ∀ V (_ : V ∈ g), Disjoint f (𝓟 («expr ᶜ» V)) :=
  forall_congrₓ$ fun _ => forall_congrₓ$ fun _ => mem_iff_disjoint_principal_compl

theorem le_iff_forall_inf_principal_compl {f g : Filter α} : f ≤ g ↔ ∀ V (_ : V ∈ g), f⊓𝓟 («expr ᶜ» V) = ⊥ :=
  forall_congrₓ$ fun _ => forall_congrₓ$ fun _ => mem_iff_inf_principal_compl

theorem inf_ne_bot_iff_frequently_left {f g : Filter α} :
  ne_bot (f⊓g) ↔ ∀ {p : α → Prop}, (∀ᶠx in f, p x) → ∃ᶠx in g, p x :=
  by 
    simpa only [inf_ne_bot_iff, frequently_iff, exists_prop, and_comm]

theorem inf_ne_bot_iff_frequently_right {f g : Filter α} :
  ne_bot (f⊓g) ↔ ∀ {p : α → Prop}, (∀ᶠx in g, p x) → ∃ᶠx in f, p x :=
  by 
    rw [inf_comm]
    exact inf_ne_bot_iff_frequently_left

theorem has_basis.eq_binfi (h : l.has_basis p s) : l = ⨅(i : _)(_ : p i), 𝓟 (s i) :=
  eq_binfi_of_mem_iff_exists_mem$
    fun t =>
      by 
        simp only [h.mem_iff, mem_principal]

theorem has_basis.eq_infi (h : l.has_basis (fun _ => True) s) : l = ⨅i, 𝓟 (s i) :=
  by 
    simpa only [infi_true] using h.eq_binfi

theorem has_basis_infi_principal {s : ι → Set α} (h : Directed (· ≥ ·) s) [Nonempty ι] :
  (⨅i, 𝓟 (s i)).HasBasis (fun _ => True) s :=
  ⟨by 
      refine'
        fun t =>
          (mem_infi_of_directed (h.mono_comp _ _) t).trans$
            by 
              simp only [exists_prop, true_andₓ, mem_principal]
      exact fun _ _ => principal_mono.2⟩

-- error in Order.Filter.Bases: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- If `s : ι → set α` is an indexed family of sets, then finite intersections of `s i` form a basis
of `⨅ i, 𝓟 (s i)`.  -/
theorem has_basis_infi_principal_finite
{ι : Type*}
(s : ι → set α) : «expr⨅ , »((i), expr𝓟() (s i)).has_basis (λ
 t : set ι, finite t) (λ t, «expr⋂ , »((i «expr ∈ » t), s i)) :=
begin
  refine [expr ⟨λ U, (mem_infi_finite _).trans _⟩],
  simp [] [] ["only"] ["[", expr infi_principal_finset, ",", expr mem_Union, ",", expr mem_principal, ",", expr exists_prop, ",", expr exists_finite_iff_finset, ",", expr finset.set_bInter_coe, "]"] [] []
end

theorem has_basis_binfi_principal {s : β → Set α} {S : Set β} (h : DirectedOn (s ⁻¹'o (· ≥ ·)) S) (ne : S.nonempty) :
  (⨅(i : _)(_ : i ∈ S), 𝓟 (s i)).HasBasis (fun i => i ∈ S) s :=
  ⟨by 
      refine'
        fun t =>
          (mem_binfi_of_directed _ Ne).trans$
            by 
              simp only [mem_principal]
      rw [directed_on_iff_directed, ←directed_comp, · ∘ ·] at h⊢
      apply h.mono_comp _ _ 
      exact fun _ _ => principal_mono.2⟩

theorem has_basis_binfi_principal' {ι : Type _} {p : ι → Prop} {s : ι → Set α}
  (h : ∀ i, p i → ∀ j, p j → ∃ (k : _)(h : p k), s k ⊆ s i ∧ s k ⊆ s j) (ne : ∃ i, p i) :
  (⨅(i : _)(h : p i), 𝓟 (s i)).HasBasis p s :=
  Filter.has_basis_binfi_principal h Ne

theorem has_basis.map (f : α → β) (hl : l.has_basis p s) : (l.map f).HasBasis p fun i => f '' s i :=
  ⟨fun t =>
      by 
        simp only [mem_map, image_subset_iff, hl.mem_iff, preimage]⟩

theorem has_basis.comap (f : β → α) (hl : l.has_basis p s) : (l.comap f).HasBasis p fun i => f ⁻¹' s i :=
  ⟨by 
      intro t 
      simp only [mem_comap, exists_prop, hl.mem_iff]
      split 
      ·
        rintro ⟨t', ⟨i, hi, ht'⟩, H⟩
        exact ⟨i, hi, subset.trans (preimage_mono ht') H⟩
      ·
        rintro ⟨i, hi, H⟩
        exact ⟨s i, ⟨i, hi, subset.refl _⟩, H⟩⟩

-- error in Order.Filter.Bases: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem comap_has_basis
(f : α → β)
(l : filter β) : has_basis (comap f l) (λ s : set β, «expr ∈ »(s, l)) (λ s, «expr ⁻¹' »(f, s)) :=
⟨λ t, mem_comap⟩

theorem has_basis.prod_self (hl : l.has_basis p s) : (l ×ᶠ l).HasBasis p fun i => (s i).Prod (s i) :=
  ⟨by 
      intro t 
      apply mem_prod_iff.trans 
      split 
      ·
        rintro ⟨t₁, ht₁, t₂, ht₂, H⟩
        rcases hl.mem_iff.1 (inter_mem ht₁ ht₂) with ⟨i, hi, ht⟩
        exact ⟨i, hi, fun p ⟨hp₁, hp₂⟩ => H ⟨(ht hp₁).1, (ht hp₂).2⟩⟩
      ·
        rintro ⟨i, hi, H⟩
        exact ⟨s i, hl.mem_of_mem hi, s i, hl.mem_of_mem hi, H⟩⟩

theorem mem_prod_self_iff {s} : s ∈ l ×ᶠ l ↔ ∃ (t : _)(_ : t ∈ l), Set.Prod t t ⊆ s :=
  l.basis_sets.prod_self.mem_iff

theorem has_basis.sInter_sets (h : has_basis l p s) : ⋂₀l.sets = ⋂(i : _)(hi : p i), s i :=
  by 
    ext x 
    suffices  : (∀ t (_ : t ∈ l), x ∈ t) ↔ ∀ i, p i → x ∈ s i
    ·
      simpa only [mem_Inter, mem_set_of_eq, mem_sInter]
    simpRw [h.mem_iff]
    split 
    ·
      intro h i hi 
      exact h (s i) ⟨i, hi, subset.refl _⟩
    ·
      rintro h _ ⟨i, hi, sub⟩
      exact sub (h i hi)

variable{ι'' : Type _}[Preorderₓ ι''](l)(p'' : ι'' → Prop)(s'' : ι'' → Set α)

/-- `is_antitone_basis p s` means the image of `s` bounded by `p` is a filter basis
such that `s` is decreasing and `p` is increasing, ie `i ≤ j → p i → p j`. -/
structure is_antitone_basis extends is_basis p'' s'' : Prop where 
  decreasing : ∀ {i j}, p'' i → p'' j → i ≤ j → s'' j ⊆ s'' i 
  mono : Monotone p''

/-- We say that a filter `l` has an antitone basis `s : ι → set α` bounded by `p : ι → Prop`,
if `t ∈ l` if and only if `t` includes `s i` for some `i` such that `p i`,
and `s` is decreasing and `p` is increasing, ie `i ≤ j → p i → p j`. -/
structure has_antitone_basis(l : Filter α)(p : ι'' → Prop)(s : ι'' → Set α) extends has_basis l p s : Prop where 
  decreasing : ∀ {i j}, p i → p j → i ≤ j → s j ⊆ s i 
  mono : Monotone p

end SameType

section TwoTypes

variable{la : Filter α}{pa : ι → Prop}{sa : ι → Set α}{lb : Filter β}{pb : ι' → Prop}{sb : ι' → Set β}{f : α → β}

theorem has_basis.tendsto_left_iff (hla : la.has_basis pa sa) :
  tendsto f la lb ↔ ∀ t (_ : t ∈ lb), ∃ (i : _)(hi : pa i), maps_to f (sa i) t :=
  by 
    simp only [tendsto, (hla.map f).le_iff, image_subset_iff]
    rfl

theorem has_basis.tendsto_right_iff (hlb : lb.has_basis pb sb) :
  tendsto f la lb ↔ ∀ i (hi : pb i), ∀ᶠx in la, f x ∈ sb i :=
  by 
    simpa only [tendsto, hlb.ge_iff, mem_map, Filter.Eventually]

theorem has_basis.tendsto_iff (hla : la.has_basis pa sa) (hlb : lb.has_basis pb sb) :
  tendsto f la lb ↔ ∀ ib (hib : pb ib), ∃ (ia : _)(hia : pa ia), ∀ x (_ : x ∈ sa ia), f x ∈ sb ib :=
  by 
    simp [hlb.tendsto_right_iff, hla.eventually_iff]

theorem tendsto.basis_left (H : tendsto f la lb) (hla : la.has_basis pa sa) :
  ∀ t (_ : t ∈ lb), ∃ (i : _)(hi : pa i), maps_to f (sa i) t :=
  hla.tendsto_left_iff.1 H

theorem tendsto.basis_right (H : tendsto f la lb) (hlb : lb.has_basis pb sb) : ∀ i (hi : pb i), ∀ᶠx in la, f x ∈ sb i :=
  hlb.tendsto_right_iff.1 H

theorem tendsto.basis_both (H : tendsto f la lb) (hla : la.has_basis pa sa) (hlb : lb.has_basis pb sb) :
  ∀ ib (hib : pb ib), ∃ (ia : _)(hia : pa ia), ∀ x (_ : x ∈ sa ia), f x ∈ sb ib :=
  (hla.tendsto_iff hlb).1 H

-- error in Order.Filter.Bases: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem has_basis.prod''
(hla : la.has_basis pa sa)
(hlb : lb.has_basis pb sb) : «expr ×ᶠ »(la, lb).has_basis (λ
 i : pprod ι ι', «expr ∧ »(pa i.1, pb i.2)) (λ i, (sa i.1).prod (sb i.2)) :=
(hla.comap prod.fst).inf' (hlb.comap prod.snd)

-- error in Order.Filter.Bases: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem has_basis.prod
{ι ι' : Type*}
{pa : ι → exprProp()}
{sa : ι → set α}
{pb : ι' → exprProp()}
{sb : ι' → set β}
(hla : la.has_basis pa sa)
(hlb : lb.has_basis pb sb) : «expr ×ᶠ »(la, lb).has_basis (λ
 i : «expr × »(ι, ι'), «expr ∧ »(pa i.1, pb i.2)) (λ i, (sa i.1).prod (sb i.2)) :=
(hla.comap prod.fst).inf (hlb.comap prod.snd)

theorem has_basis.prod' {la : Filter α} {lb : Filter β} {ι : Type _} {p : ι → Prop} {sa : ι → Set α} {sb : ι → Set β}
  (hla : la.has_basis p sa) (hlb : lb.has_basis p sb)
  (h_dir : ∀ {i j}, p i → p j → ∃ k, p k ∧ sa k ⊆ sa i ∧ sb k ⊆ sb j) :
  (la ×ᶠ lb).HasBasis p fun i => (sa i).Prod (sb i) :=
  by 
    simp only [has_basis_iff, (hla.prod hlb).mem_iff]
    refine' fun t => ⟨_, _⟩
    ·
      rintro ⟨⟨i, j⟩, ⟨hi, hj⟩, hsub : (sa i).Prod (sb j) ⊆ t⟩
      rcases h_dir hi hj with ⟨k, hk, ki, kj⟩
      exact ⟨k, hk, (Set.prod_mono ki kj).trans hsub⟩
    ·
      rintro ⟨i, hi, h⟩
      exact ⟨⟨i, i⟩, ⟨hi, hi⟩, h⟩

end TwoTypes

end Filter

end Sort

namespace Filter

variable{α β γ ι ι' : Type _}

/-- `is_countably_generated f` means `f = generate s` for some countable `s`. -/
class is_countably_generated(f : Filter α) : Prop where 
  out{} : ∃ s : Set (Set α), countable s ∧ f = generate s

/-- `is_countable_basis p s` means the image of `s` bounded by `p` is a countable filter basis. -/
structure is_countable_basis(p : ι → Prop)(s : ι → Set α) extends is_basis p s : Prop where 
  Countable : countable$ SetOf p

/-- We say that a filter `l` has a countable basis `s : ι → set α` bounded by `p : ι → Prop`,
if `t ∈ l` if and only if `t` includes `s i` for some `i` such that `p i`, and the set
defined by `p` is countable. -/
structure has_countable_basis(l : Filter α)(p : ι → Prop)(s : ι → Set α) extends has_basis l p s : Prop where 
  Countable : countable$ SetOf p

/-- A countable filter basis `B` on a type `α` is a nonempty countable collection of sets of `α`
such that the intersection of two elements of this collection contains some element
of the collection. -/
structure countable_filter_basis(α : Type _) extends FilterBasis α where 
  Countable : countable sets

instance nat.inhabited_countable_filter_basis : Inhabited (countable_filter_basis ℕ) :=
  ⟨{ default$ FilterBasis ℕ with Countable := countable_range fun n => Ici n }⟩

theorem has_countable_basis.is_countably_generated {f : Filter α} {p : ι → Prop} {s : ι → Set α}
  (h : f.has_countable_basis p s) : f.is_countably_generated :=
  ⟨⟨{ t | ∃ i, p i ∧ s i = t }, h.countable.image s, h.to_has_basis.eq_generate⟩⟩

theorem antitone_seq_of_seq (s : ℕ → Set α) :
  ∃ t : ℕ → Set α, (∀ i j, i ≤ j → t j ⊆ t i) ∧ (⨅i, 𝓟$ s i) = ⨅i, 𝓟 (t i) :=
  by 
    use fun n => ⋂(m : _)(_ : m ≤ n), s m 
    split 
    ·
      exact fun i j hij => bInter_mono' (Iic_subset_Iic.2 hij) fun n hn => subset.refl _ 
    apply le_antisymmₓ <;> rw [le_infi_iff] <;> intro i
    ·
      rw [le_principal_iff]
      refine' (bInter_mem (finite_le_nat _)).2 fun j hji => _ 
      rw [←le_principal_iff]
      apply infi_le_of_le j _ 
      apply le_reflₓ _
    ·
      apply infi_le_of_le i _ 
      rw [principal_mono]
      intro a 
      simp 
      intro h 
      apply h 
      rfl

theorem countable_binfi_eq_infi_seq [CompleteLattice α] {B : Set ι} (Bcbl : countable B) (Bne : B.nonempty)
  (f : ι → α) : ∃ x : ℕ → ι, (⨅(t : _)(_ : t ∈ B), f t) = ⨅i, f (x i) :=
  by 
    rw [countable_iff_exists_surjective_to_subtype Bne] at Bcbl 
    rcases Bcbl with ⟨g, gsurj⟩
    rw [infi_subtype']
    use fun n => g n 
    apply le_antisymmₓ <;> rw [le_infi_iff]
    ·
      intro i 
      apply infi_le_of_le (g i) _ 
      apply le_reflₓ _
    ·
      intro a 
      rcases gsurj a with ⟨i, rfl⟩
      apply infi_le

theorem countable_binfi_eq_infi_seq' [CompleteLattice α] {B : Set ι} (Bcbl : countable B) (f : ι → α) {i₀ : ι}
  (h : f i₀ = ⊤) : ∃ x : ℕ → ι, (⨅(t : _)(_ : t ∈ B), f t) = ⨅i, f (x i) :=
  by 
    cases' B.eq_empty_or_nonempty with hB Bnonempty
    ·
      rw [hB, infi_emptyset]
      use fun n => i₀ 
      simp [h]
    ·
      exact countable_binfi_eq_infi_seq Bcbl Bnonempty f

theorem countable_binfi_principal_eq_seq_infi {B : Set (Set α)} (Bcbl : countable B) :
  ∃ x : ℕ → Set α, (⨅(t : _)(_ : t ∈ B), 𝓟 t) = ⨅i, 𝓟 (x i) :=
  countable_binfi_eq_infi_seq' Bcbl 𝓟 principal_univ

section IsCountablyGenerated

-- error in Order.Filter.Bases: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If `f` is countably generated and `f.has_basis p s`, then `f` admits a decreasing basis
enumerated by natural numbers such that all sets have the form `s i`. More precisely, there is a
sequence `i n` such that `p (i n)` for all `n` and `s (i n)` is a decreasing sequence of sets which
forms a basis of `f`-/
theorem has_basis.exists_antitone_subbasis
{f : filter α}
[h : f.is_countably_generated]
{p : ι → exprProp()}
{s : ι → set α}
(hs : f.has_basis p s) : «expr∃ , »((x : exprℕ() → ι), «expr ∧ »(∀
  i, p (x i), f.has_antitone_basis (λ _, true) (λ i, s (x i)))) :=
begin
  obtain ["⟨", ident x', ",", ident hx', "⟩", ":", expr «expr∃ , »((x : exprℕ() → set α), «expr = »(f, «expr⨅ , »((i), expr𝓟() (x i))))],
  { unfreezingI { rcases [expr h, "with", "⟨", ident s, ",", ident hsc, ",", ident rfl, "⟩"] },
    rw [expr generate_eq_binfi] [],
    exact [expr countable_binfi_principal_eq_seq_infi hsc] },
  have [] [":", expr ∀
   i, «expr ∈ »(x' i, f)] [":=", expr λ i, «expr ▸ »(hx'.symm, infi_le (λ i, expr𝓟() (x' i)) i (mem_principal_self _))],
  let [ident x] [":", expr exprℕ() → {i : ι // p i}] [":=", expr λ
   n, nat.rec_on n «expr $ »(hs.index _, this 0) (λ
    n xn, «expr $ »(hs.index _, inter_mem «expr $ »(this, «expr + »(n, 1)) (hs.mem_of_mem xn.coe_prop)))],
  have [ident x_mono] [":", expr antitone (λ i, s (x i))] [],
  { refine [expr antitone_nat_of_succ_le (λ i, _)],
    exact [expr (hs.set_index_subset _).trans (inter_subset_right _ _)] },
  have [ident x_subset] [":", expr ∀ i, «expr ⊆ »(s (x i), x' i)] [],
  { rintro ["(", "_", "|", ident i, ")"],
    exacts ["[", expr hs.set_index_subset _, ",", expr subset.trans (hs.set_index_subset _) (inter_subset_left _ _), "]"] },
  refine [expr ⟨λ i, x i, λ i, (x i).2, _⟩],
  have [] [":", expr «expr⨅ , »((i), expr𝓟() (s (x i))).has_antitone_basis (λ
    _, true) (λ
    i, s (x i))] [":=", expr ⟨has_basis_infi_principal (directed_of_sup x_mono), λ
    i j _ _ hij, x_mono hij, monotone_const⟩],
  convert [] [expr this] [],
  exact [expr le_antisymm «expr $ »(le_infi, λ
    i, «expr $ »(le_principal_iff.2, by cases [expr i] []; apply [expr hs.set_index_mem])) «expr ▸ »(hx'.symm, le_infi (λ
     i, «expr $ »(le_principal_iff.2, this.to_has_basis.mem_iff.2 ⟨i, trivial, x_subset i⟩)))]
end

/-- A countably generated filter admits a basis formed by an antitone sequence of sets. -/
theorem exists_antitone_basis (f : Filter α) [f.is_countably_generated] :
  ∃ x : ℕ → Set α, f.has_antitone_basis (fun _ => True) x :=
  let ⟨x, hxf, hx⟩ := f.basis_sets.exists_antitone_subbasis
  ⟨x, hx⟩

theorem exists_antitone_eq_infi_principal (f : Filter α) [f.is_countably_generated] :
  ∃ x : ℕ → Set α, Antitone x ∧ f = ⨅n, 𝓟 (x n) :=
  let ⟨x, hxf⟩ := f.exists_antitone_basis
  ⟨x, fun i j => hxf.decreasing trivialₓ trivialₓ, hxf.to_has_basis.eq_infi⟩

theorem exists_antitone_seq (f : Filter α) [f.is_countably_generated] :
  ∃ x : ℕ → Set α, Antitone x ∧ ∀ {s}, s ∈ f ↔ ∃ i, x i ⊆ s :=
  let ⟨x, hx⟩ := f.exists_antitone_basis
  ⟨x, fun i j => hx.decreasing trivialₓ trivialₓ,
    fun s =>
      by 
        simp [hx.to_has_basis.mem_iff]⟩

instance inf.is_countably_generated (f g : Filter α) [is_countably_generated f] [is_countably_generated g] :
  is_countably_generated (f⊓g) :=
  by 
    rcases f.exists_antitone_basis with ⟨s, hs⟩
    rcases g.exists_antitone_basis with ⟨t, ht⟩
    exact has_countable_basis.is_countably_generated ⟨hs.to_has_basis.inf ht.to_has_basis, Set.countable_encodable _⟩

instance comap.is_countably_generated (l : Filter β) [l.is_countably_generated] (f : α → β) :
  (comap f l).IsCountablyGenerated :=
  let ⟨x, hxl⟩ := l.exists_antitone_basis 
  has_countable_basis.is_countably_generated ⟨hxl.to_has_basis.comap _, countable_encodable _⟩

instance sup.is_countably_generated (f g : Filter α) [is_countably_generated f] [is_countably_generated g] :
  is_countably_generated (f⊔g) :=
  by 
    rcases f.exists_antitone_basis with ⟨s, hs⟩
    rcases g.exists_antitone_basis with ⟨t, ht⟩
    exact has_countable_basis.is_countably_generated ⟨hs.to_has_basis.sup ht.to_has_basis, Set.countable_encodable _⟩

end IsCountablyGenerated

@[instance]
theorem is_countably_generated_seq [Encodable β] (x : β → Set α) : is_countably_generated (⨅i, 𝓟$ x i) :=
  by 
    use range x, countable_range x 
    rw [generate_eq_binfi, infi_range]

theorem is_countably_generated_of_seq {f : Filter α} (h : ∃ x : ℕ → Set α, f = ⨅i, 𝓟$ x i) : f.is_countably_generated :=
  let ⟨x, h⟩ := h 
  by 
    rw [h] <;> apply is_countably_generated_seq

theorem is_countably_generated_binfi_principal {B : Set$ Set α} (h : countable B) :
  is_countably_generated (⨅(s : _)(_ : s ∈ B), 𝓟 s) :=
  is_countably_generated_of_seq (countable_binfi_principal_eq_seq_infi h)

theorem is_countably_generated_iff_exists_antitone_basis {f : Filter α} :
  is_countably_generated f ↔ ∃ x : ℕ → Set α, f.has_antitone_basis (fun _ => True) x :=
  by 
    split 
    ·
      intro h 
      exact f.exists_antitone_basis
    ·
      rintro ⟨x, h⟩
      rw [h.to_has_basis.eq_infi]
      exact is_countably_generated_seq x

@[instance]
theorem is_countably_generated_principal (s : Set α) : is_countably_generated (𝓟 s) :=
  is_countably_generated_of_seq ⟨fun _ => s, infi_const.symm⟩

@[instance]
theorem is_countably_generated_bot : is_countably_generated (⊥ : Filter α) :=
  @principal_empty α ▸ is_countably_generated_principal _

@[instance]
theorem is_countably_generated_top : is_countably_generated (⊤ : Filter α) :=
  @principal_univ α ▸ is_countably_generated_principal _

end Filter

