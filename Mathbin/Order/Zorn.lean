import Mathbin.Data.Set.Pairwise

/-!
# Chains and Zorn's lemmas

This file defines chains for an arbitrary relation and proves several formulations of Zorn's Lemma,
along with Hausdorff's Maximality Principle.

## Main declarations

* `chain c`: A chain `c` is a set of comparable elements.
* `max_chain_spec`: Hausdorff's Maximality Principle.
* `exists_maximal_of_chains_bounded`: Zorn's Lemma. Many variants are offered.

## Variants

The primary statement of Zorn's lemma is `exists_maximal_of_chains_bounded`. Then it is specialized
to particular relations:
* `(≤)` with `zorn_partial_order`
* `(⊆)` with `zorn_subset`
* `(⊇)` with `zorn_superset`

Lemma names carry modifiers:
* `₀`: Quantifies over a set, as opposed to over a type.
* `_nonempty`: Doesn't ask to prove that the empty chain is bounded and lets you give an element
  that will be smaller than the maximal element found (the maximal element is no smaller than any
  other element, but it can also be incomparable to some).

## How-to

This file comes across as confusing to those who haven't yet used it, so here is a detailed
walkthrough:
1. Know what relation on which type/set you're looking for. See Variants above. You can discharge
  some conditions to Zorn's lemma directly using a `_nonempty` variant.
2. Write down the definition of your type/set, put a `suffices : ∃ m, ∀ a, m ≺ a → a ≺ m, { ... },`
  (or whatever you actually need) followed by a `apply some_version_of_zorn`.
3. Fill in the details. This is where you start talking about chains.

A typical proof using Zorn could look like this
```lean
lemma zorny_lemma : zorny_statement :=
begin
  let s : set α := {x | whatever x},
  suffices : ∃ x ∈ s, ∀ y ∈ s, y ⊆ x → y = x, -- or with another operator
  { exact proof_post_zorn },
  apply zorn.zorn_subset, -- or another variant
  rintro c hcs hc,
  obtain rfl | hcnemp := c.eq_empty_or_nonempty, -- you might need to disjunct on c empty or not
  { exact ⟨edge_case_construction,
      proof_that_edge_case_construction_respects_whatever,
      proof_that_edge_case_construction_contains_all_stuff_in_c⟩ },
  exact ⟨construction,
    proof_that_construction_respects_whatever,
    proof_that_construction_contains_all_stuff_in_c⟩,
end
```

## Notes

Originally ported from Isabelle/HOL. The
[original file](https://isabelle.in.tum.de/dist/library/HOL/HOL/Zorn.html) was written by Jacques D.
Fleuriot, Tobias Nipkow, Christian Sternagel.
-/


noncomputable theory

universe u

open Set Classical

open_locale Classical

namespace Zorn

section Chain

parameter {α : Type u}(r : α → α → Prop)

local infixl:50 " ≺ " => r

/-- A chain is a subset `c` satisfying `x ≺ y ∨ x = y ∨ y ≺ x` for all `x y ∈ c`. -/
def chain (c : Set α) :=
  c.pairwise fun x y => x ≺ y ∨ y ≺ x

parameter {r}

theorem chain.total_of_refl [IsRefl α r] {c} (H : chain c) {x y} (hx : x ∈ c) (hy : y ∈ c) : x ≺ y ∨ y ≺ x :=
  if e : x = y then Or.inl (e ▸ refl _) else H _ hx _ hy e

theorem chain.mono {c c'} : c' ⊆ c → chain c → chain c' :=
  Set.Pairwise.mono

theorem chain_of_trichotomous [IsTrichotomous α r] (s : Set α) : chain s :=
  by 
    intro a _ b _ hab 
    obtain h | h | h := @trichotomous _ r _ a b
    ·
      exact Or.inl h
    ·
      exact (hab h).elim
    ·
      exact Or.inr h

theorem chain_univ_iff : chain (univ : Set α) ↔ IsTrichotomous α r :=
  by 
    refine' ⟨fun h => ⟨fun a b => _⟩, fun h => @chain_of_trichotomous _ _ h univ⟩
    rw [Or.left_comm, or_iff_not_imp_left]
    exact h a trivialₓ b trivialₓ

theorem chain.directed_on [IsRefl α r] {c} (H : chain c) : DirectedOn (· ≺ ·) c :=
  fun x hx y hy =>
    match H.total_of_refl hx hy with 
    | Or.inl h => ⟨y, hy, h, refl _⟩
    | Or.inr h => ⟨x, hx, refl _, h⟩

theorem chain_insert {c : Set α} {a : α} (hc : chain c) (ha : ∀ b (_ : b ∈ c), b ≠ a → a ≺ b ∨ b ≺ a) :
  chain (insert a c) :=
  forall_insert_of_forall (fun x hx => forall_insert_of_forall (hc x hx) fun hneq => (ha x hx hneq).symm)
    (forall_insert_of_forall (fun x hx hneq => ha x hx$ fun h' => hneq h'.symm) fun h => (h rfl).rec _)

/-- `super_chain c₁ c₂` means that `c₂` is a chain that strictly includes `c₁`. -/
def super_chain (c₁ c₂ : Set α) : Prop :=
  chain c₂ ∧ c₁ ⊂ c₂

/-- A chain `c` is a maximal chain if there does not exists a chain strictly including `c`. -/
def is_max_chain (c : Set α) :=
  chain c ∧ ¬∃ c', super_chain c c'

/-- Given a set `c`, if there exists a chain `c'` strictly including `c`, then `succ_chain c`
is one of these chains. Otherwise it is `c`. -/
def succ_chain (c : Set α) : Set α :=
  if h : ∃ c', chain c ∧ super_chain c c' then some h else c

theorem succ_spec {c : Set α} (h : ∃ c', chain c ∧ super_chain c c') : super_chain c (succ_chain c) :=
  let ⟨c', hc'⟩ := h 
  have  : chain c ∧ super_chain c (some h) := @some_spec _ (fun c' => chain c ∧ super_chain c c') _ 
  by 
    simp [succ_chain, dif_pos, h, this.right]

theorem chain_succ {c : Set α} (hc : chain c) : chain (succ_chain c) :=
  if h : ∃ c', chain c ∧ super_chain c c' then (succ_spec h).left else
    by 
      simp [succ_chain, dif_neg, h] <;> exact hc

theorem super_of_not_max {c : Set α} (hc₁ : chain c) (hc₂ : ¬is_max_chain c) : super_chain c (succ_chain c) :=
  by 
    simp [is_max_chain, not_and_distrib, not_forall_not] at hc₂ 
    cases' hc₂.neg_resolve_left hc₁ with c' hc' 
    exact succ_spec ⟨c', hc₁, hc'⟩

theorem succ_increasing {c : Set α} : c ⊆ succ_chain c :=
  if h : ∃ c', chain c ∧ super_chain c c' then
    have  : super_chain c (succ_chain c) := succ_spec h 
    this.right.left
  else
    by 
      simp [succ_chain, dif_neg, h, subset.refl]

/-- Set of sets reachable from `∅` using `succ_chain` and `⋃₀`. -/
inductive chain_closure : Set (Set α)
  | succ : ∀ {s}, chain_closure s → chain_closure (succ_chain s)
  | union : ∀ {s}, (∀ a (_ : a ∈ s), chain_closure a) → chain_closure (⋃₀s)

theorem chain_closure_empty : ∅ ∈ chain_closure :=
  have  : chain_closure (⋃₀∅) := chain_closure.union$ fun a h => h.rec _ 
  by 
    simp  at this <;> assumption

theorem chain_closure_closure : ⋃₀chain_closure ∈ chain_closure :=
  chain_closure.union$ fun s hs => hs

variable{c c₁ c₂ c₃ : Set α}

-- error in Order.Zorn: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
private
theorem chain_closure_succ_total_aux
(hc₁ : «expr ∈ »(c₁, chain_closure))
(hc₂ : «expr ∈ »(c₂, chain_closure))
(h : ∀
 {c₃}, «expr ∈ »(c₃, chain_closure) → «expr ⊆ »(c₃, c₂) → «expr ∨ »(«expr = »(c₂, c₃), «expr ⊆ »(succ_chain c₃, c₂))) : «expr ∨ »(«expr ⊆ »(c₁, c₂), «expr ⊆ »(succ_chain c₂, c₁)) :=
begin
  induction [expr hc₁] [] [] [],
  case [ident succ, ":", ident c₃, ident hc₃, ident ih] { cases [expr ih] ["with", ident ih, ident ih],
    { have [ident h] [] [":=", expr h hc₃ ih],
      cases [expr h] ["with", ident h, ident h],
      { exact [expr or.inr «expr ▸ »(h, subset.refl _)] },
      { exact [expr or.inl h] } },
    { exact [expr or.inr (subset.trans ih succ_increasing)] } },
  case [ident union, ":", ident s, ident hs, ident ih] { refine [expr «expr $ »(or_iff_not_imp_right.2, λ
      hn, «expr $ »(sUnion_subset, λ a ha, _))],
    apply [expr (ih a ha).resolve_right],
    apply [expr mt (λ h, _) hn],
    exact [expr subset.trans h (subset_sUnion_of_mem ha)] }
end

-- error in Order.Zorn: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
private
theorem chain_closure_succ_total
(hc₁ : «expr ∈ »(c₁, chain_closure))
(hc₂ : «expr ∈ »(c₂, chain_closure))
(h : «expr ⊆ »(c₁, c₂)) : «expr ∨ »(«expr = »(c₂, c₁), «expr ⊆ »(succ_chain c₁, c₂)) :=
begin
  induction [expr hc₂] [] [] ["generalizing", ident c₁, ident hc₁, ident h],
  case [ident succ, ":", ident c₂, ident hc₂, ident ih] { have [ident h₁] [":", expr «expr ∨ »(«expr ⊆ »(c₁, c₂), «expr ⊆ »(@succ_chain α r c₂, c₁))] [":=", expr «expr $ »(chain_closure_succ_total_aux hc₁ hc₂, λ
      c₁, ih)],
    cases [expr h₁] ["with", ident h₁, ident h₁],
    { have [ident h₂] [] [":=", expr ih hc₁ h₁],
      cases [expr h₂] ["with", ident h₂, ident h₂],
      { exact [expr «expr $ »(or.inr, «expr ▸ »(h₂, subset.refl _))] },
      { exact [expr «expr $ »(or.inr, subset.trans h₂ succ_increasing)] } },
    { exact [expr «expr $ »(or.inl, subset.antisymm h₁ h)] } },
  case [ident union, ":", ident s, ident hs, ident ih] { apply [expr or.imp_left (λ h', subset.antisymm h' h)],
    apply [expr classical.by_contradiction],
    simp [] [] [] ["[", expr not_or_distrib, ",", expr sUnion_subset_iff, ",", expr not_forall, "]"] [] [],
    intros [ident c₃, ident hc₃, ident h₁, ident h₂],
    have [ident h] [] [":=", expr chain_closure_succ_total_aux hc₁ (hs c₃ hc₃) (λ c₄, ih _ hc₃)],
    cases [expr h] ["with", ident h, ident h],
    { have [ident h'] [] [":=", expr ih c₃ hc₃ hc₁ h],
      cases [expr h'] ["with", ident h', ident h'],
      { exact [expr «expr $ »(h₁, «expr ▸ »(h', subset.refl _))] },
      { exact [expr «expr $ »(h₂, «expr $ »(subset.trans h', subset_sUnion_of_mem hc₃))] } },
    { exact [expr «expr $ »(h₁, subset.trans succ_increasing h)] } }
end

theorem chain_closure_total (hc₁ : c₁ ∈ chain_closure) (hc₂ : c₂ ∈ chain_closure) : c₁ ⊆ c₂ ∨ c₂ ⊆ c₁ :=
  Or.imp_rightₓ succ_increasing.trans$
    chain_closure_succ_total_aux hc₁ hc₂$ fun c₃ hc₃ => chain_closure_succ_total hc₃ hc₂

theorem chain_closure_succ_fixpoint (hc₁ : c₁ ∈ chain_closure) (hc₂ : c₂ ∈ chain_closure) (h_eq : succ_chain c₂ = c₂) :
  c₁ ⊆ c₂ :=
  by 
    induction hc₁ 
    case succ c₁ hc₁ h => 
      exact Or.elim (chain_closure_succ_total hc₁ hc₂ h) (fun h => h ▸ h_eq.symm ▸ subset.refl c₂) id 
    case union s hs ih => 
      exact sUnion_subset$ fun c₁ hc₁ => ih c₁ hc₁

theorem chain_closure_succ_fixpoint_iff (hc : c ∈ chain_closure) : succ_chain c = c ↔ c = ⋃₀chain_closure :=
  ⟨fun h => (subset_sUnion_of_mem hc).antisymm (chain_closure_succ_fixpoint chain_closure_closure hc h),
    fun h =>
      subset.antisymm
        (calc succ_chain c ⊆ ⋃₀{ c:Set α | c ∈ chain_closure } := subset_sUnion_of_mem$ chain_closure.succ hc 
          _ = c := h.symm
          )
        succ_increasing⟩

-- error in Order.Zorn: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem chain_chain_closure (hc : «expr ∈ »(c, chain_closure)) : chain c :=
begin
  induction [expr hc] [] [] [],
  case [ident succ, ":", ident c, ident hc, ident h] { exact [expr chain_succ h] },
  case [ident union, ":", ident s, ident hs, ident h] { have [ident h] [":", expr ∀
     c «expr ∈ » s, zorn.chain c] [":=", expr h],
    exact [expr λ
     (c₁)
     ⟨t₁, ht₁, (hc₁ : «expr ∈ »(c₁, t₁))⟩
     (c₂)
     ⟨t₂, ht₂, (hc₂ : «expr ∈ »(c₂, t₂))⟩
     (hneq), have «expr ∨ »(«expr ⊆ »(t₁, t₂), «expr ⊆ »(t₂, t₁)), from chain_closure_total (hs _ ht₁) (hs _ ht₂),
     or.elim this (λ ht, h t₂ ht₂ c₁ (ht hc₁) c₂ hc₂ hneq) (λ ht, h t₁ ht₁ c₁ hc₁ c₂ (ht hc₂) hneq)] }
end

/-- An explicit maximal chain. `max_chain` is taken to be the union of all sets in `chain_closure`.
-/
def max_chain :=
  ⋃₀chain_closure

/-- Hausdorff's maximality principle

There exists a maximal totally ordered subset of `α`.
Note that we do not require `α` to be partially ordered by `r`. -/
theorem max_chain_spec : is_max_chain max_chain :=
  Classical.by_contradiction$
    fun h =>
      by 
        obtain ⟨h₁, H⟩ := super_of_not_max (chain_chain_closure chain_closure_closure) h 
        obtain ⟨h₂, h₃⟩ := ssubset_iff_subset_ne.1 H 
        exact h₃ ((chain_closure_succ_fixpoint_iff chain_closure_closure).mpr rfl).symm

-- error in Order.Zorn: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- Zorn's lemma

If every chain has an upper bound, then there exists a maximal element. -/
theorem exists_maximal_of_chains_bounded
(h : ∀ c, chain c → «expr∃ , »((ub), ∀ a «expr ∈ » c, «expr ≺ »(a, ub)))
(trans : ∀
 {a
  b
  c}, «expr ≺ »(a, b) → «expr ≺ »(b, c) → «expr ≺ »(a, c)) : «expr∃ , »((m), ∀ a, «expr ≺ »(m, a) → «expr ≺ »(a, m)) :=
have «expr∃ , »((ub), ∀ a «expr ∈ » max_chain, «expr ≺ »(a, ub)), from «expr $ »(h _, max_chain_spec.left),
let ⟨ub, (hub : ∀ a «expr ∈ » max_chain, «expr ≺ »(a, ub))⟩ := this in
⟨ub, λ
 a
 ha, have chain (insert a max_chain), from «expr $ »(chain_insert max_chain_spec.left, λ
  b hb _, «expr $ »(or.inr, trans (hub b hb) ha)),
 have «expr ∈ »(a, max_chain), from «expr $ »(classical.by_contradiction, λ
  h : «expr ∉ »(a, max_chain), «expr $ »(max_chain_spec.right, ⟨insert a max_chain, this, ssubset_insert h⟩)),
 hub a this⟩

/-- A variant of Zorn's lemma. If every nonempty chain of a nonempty type has an upper bound, then
there is a maximal element.
-/
theorem exists_maximal_of_nonempty_chains_bounded [Nonempty α]
  (h : ∀ c, chain c → c.nonempty → ∃ ub, ∀ a (_ : a ∈ c), a ≺ ub) (trans : ∀ {a b c}, a ≺ b → b ≺ c → a ≺ c) :
  ∃ m, ∀ a, m ≺ a → a ≺ m :=
  exists_maximal_of_chains_bounded
    (fun c hc =>
      (eq_empty_or_nonempty c).elim (fun h => ⟨Classical.arbitrary α, fun x hx => (h ▸ hx : x ∈ (∅ : Set α)).elim⟩)
        (h c hc))
    fun a b c => trans

end Chain

/-- This can be used to turn `zorn.chain (≥)` into `zorn.chain (≤)` and vice-versa. -/
theorem chain.symm {α : Type u} {s : Set α} {q : α → α → Prop} (h : chain q s) : chain (flip q) s :=
  h.mono' fun _ _ => Or.symm

theorem zorn_partial_order {α : Type u} [PartialOrderₓ α]
  (h : ∀ (c : Set α), chain (· ≤ ·) c → ∃ ub, ∀ a (_ : a ∈ c), a ≤ ub) : ∃ m : α, ∀ a, m ≤ a → a = m :=
  let ⟨m, hm⟩ := @exists_maximal_of_chains_bounded α (· ≤ ·) h fun a b c => le_transₓ
  ⟨m, fun a ha => le_antisymmₓ (hm a ha) ha⟩

theorem zorn_nonempty_partial_order {α : Type u} [PartialOrderₓ α] [Nonempty α]
  (h : ∀ (c : Set α), chain (· ≤ ·) c → c.nonempty → ∃ ub, ∀ a (_ : a ∈ c), a ≤ ub) : ∃ m : α, ∀ a, m ≤ a → a = m :=
  let ⟨m, hm⟩ := @exists_maximal_of_nonempty_chains_bounded α (· ≤ ·) _ h fun a b c => le_transₓ
  ⟨m, fun a ha => le_antisymmₓ (hm a ha) ha⟩

theorem zorn_partial_order₀ {α : Type u} [PartialOrderₓ α] (s : Set α)
  (ih : ∀ c (_ : c ⊆ s), chain (· ≤ ·) c → ∃ (ub : _)(_ : ub ∈ s), ∀ z (_ : z ∈ c), z ≤ ub) :
  ∃ (m : _)(_ : m ∈ s), ∀ z (_ : z ∈ s), m ≤ z → z = m :=
  let ⟨⟨m, hms⟩, h⟩ :=
    @zorn_partial_order { m // m ∈ s } _
      fun c hc =>
        let ⟨ub, hubs, hub⟩ :=
          ih (Subtype.val '' c) (fun _ ⟨⟨x, hx⟩, _, h⟩ => h ▸ hx)
            (by 
              rintro _ ⟨p, hpc, rfl⟩ _ ⟨q, hqc, rfl⟩ hpq <;> refine' hc _ hpc _ hqc fun t => hpq (Subtype.ext_iff.1 t))
        ⟨⟨ub, hubs⟩, fun ⟨y, hy⟩ hc => hub _ ⟨_, hc, rfl⟩⟩
  ⟨m, hms, fun z hzs hmz => congr_argₓ Subtype.val (h ⟨z, hzs⟩ hmz)⟩

theorem zorn_nonempty_partial_order₀ {α : Type u} [PartialOrderₓ α] (s : Set α)
  (ih : ∀ c (_ : c ⊆ s), chain (· ≤ ·) c → ∀ y (_ : y ∈ c), ∃ (ub : _)(_ : ub ∈ s), ∀ z (_ : z ∈ c), z ≤ ub) (x : α)
  (hxs : x ∈ s) : ∃ (m : _)(_ : m ∈ s), x ≤ m ∧ ∀ z (_ : z ∈ s), m ≤ z → z = m :=
  let ⟨⟨m, hms, hxm⟩, h⟩ :=
    @zorn_partial_order { m // m ∈ s ∧ x ≤ m } _
      fun c hc =>
        c.eq_empty_or_nonempty.elim (fun hce => hce.symm ▸ ⟨⟨x, hxs, le_reflₓ _⟩, fun _ => False.elim⟩)
          fun ⟨m, hmc⟩ =>
            let ⟨ub, hubs, hub⟩ :=
              ih (Subtype.val '' c) (image_subset_iff.2$ fun z hzc => z.2.1)
                (by 
                  rintro _ ⟨p, hpc, rfl⟩ _ ⟨q, hqc, rfl⟩ hpq <;>
                    exact
                      hc p hpc q hqc
                        (mt
                          (by 
                            rintro rfl <;> rfl)
                          hpq))
                m.1 (mem_image_of_mem _ hmc)
            ⟨⟨ub, hubs, le_transₓ m.2.2$ hub m.1$ mem_image_of_mem _ hmc⟩, fun a hac => hub a.1 ⟨a, hac, rfl⟩⟩
  ⟨m, hms, hxm, fun z hzs hmz => congr_argₓ Subtype.val$ h ⟨z, hzs, le_transₓ hxm hmz⟩ hmz⟩

theorem zorn_subset {α : Type u} (S : Set (Set α))
  (h : ∀ c (_ : c ⊆ S), chain (· ⊆ ·) c → ∃ (ub : _)(_ : ub ∈ S), ∀ s (_ : s ∈ c), s ⊆ ub) :
  ∃ (m : _)(_ : m ∈ S), ∀ a (_ : a ∈ S), m ⊆ a → a = m :=
  zorn_partial_order₀ S h

theorem zorn_subset_nonempty {α : Type u} (S : Set (Set α))
  (H : ∀ c (_ : c ⊆ S), chain (· ⊆ ·) c → c.nonempty → ∃ (ub : _)(_ : ub ∈ S), ∀ s (_ : s ∈ c), s ⊆ ub) x (hx : x ∈ S) :
  ∃ (m : _)(_ : m ∈ S), x ⊆ m ∧ ∀ a (_ : a ∈ S), m ⊆ a → a = m :=
  zorn_nonempty_partial_order₀ _ (fun c cS hc y yc => H _ cS hc ⟨y, yc⟩) _ hx

theorem zorn_superset {α : Type u} (S : Set (Set α))
  (h : ∀ c (_ : c ⊆ S), chain (· ⊆ ·) c → ∃ (lb : _)(_ : lb ∈ S), ∀ s (_ : s ∈ c), lb ⊆ s) :
  ∃ (m : _)(_ : m ∈ S), ∀ a (_ : a ∈ S), a ⊆ m → a = m :=
  @zorn_partial_order₀ (OrderDual (Set α)) _ S$ fun c cS hc => h c cS hc.symm

theorem zorn_superset_nonempty {α : Type u} (S : Set (Set α))
  (H : ∀ c (_ : c ⊆ S), chain (· ⊆ ·) c → c.nonempty → ∃ (lb : _)(_ : lb ∈ S), ∀ s (_ : s ∈ c), lb ⊆ s) x (hx : x ∈ S) :
  ∃ (m : _)(_ : m ∈ S), m ⊆ x ∧ ∀ a (_ : a ∈ S), a ⊆ m → a = m :=
  @zorn_nonempty_partial_order₀ (OrderDual (Set α)) _ S (fun c cS hc y yc => H _ cS hc.symm ⟨y, yc⟩) _ hx

theorem chain.total {α : Type u} [Preorderₓ α] {c : Set α} (H : chain (· ≤ ·) c) :
  ∀ {x y}, x ∈ c → y ∈ c → x ≤ y ∨ y ≤ x :=
  fun x y => H.total_of_refl

theorem chain.image {α β : Type _} (r : α → α → Prop) (s : β → β → Prop) (f : α → β) (h : ∀ x y, r x y → s (f x) (f y))
  {c : Set α} (hrc : chain r c) : chain s (f '' c) :=
  fun x ⟨a, ha₁, ha₂⟩ y ⟨b, hb₁, hb₂⟩ =>
    ha₂ ▸ hb₂ ▸ fun hxy => (hrc a ha₁ b hb₁ (mt (congr_argₓ f)$ hxy)).elim (Or.inl ∘ h _ _) (Or.inr ∘ h _ _)

end Zorn

-- error in Order.Zorn: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem directed_of_chain
{α β r}
[is_refl β r]
{f : α → β}
{c : set α}
(h : zorn.chain «expr ⁻¹'o »(f, r) c) : directed r (λ x : {a : α // «expr ∈ »(a, c)}, f x) :=
λ
⟨a, ha⟩
⟨b, hb⟩, classical.by_cases (λ
 hab : «expr = »(a, b), by simp [] [] ["only"] ["[", expr hab, ",", expr exists_prop, ",", expr and_self, ",", expr subtype.exists, "]"] [] []; exact [expr ⟨b, hb, refl _⟩]) (λ
 hab, (h a ha b hb hab).elim (λ h : r (f a) (f b), ⟨⟨b, hb⟩, h, refl _⟩) (λ h : r (f b) (f a), ⟨⟨a, ha⟩, refl _, h⟩))

