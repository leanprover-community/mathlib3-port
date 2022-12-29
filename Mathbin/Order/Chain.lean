/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl

! This file was ported from Lean 3 source module order.chain
! leanprover-community/mathlib commit 422e70f7ce183d2900c586a8cda8381e788a0c62
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Pairwise
import Mathbin.Data.SetLike.Basic

/-!
# Chains and flags

This file defines chains for an arbitrary relation and flags for an order and proves Hausdorff's
Maximality Principle.

## Main declarations

* `is_chain s`: A chain `s` is a set of comparable elements.
* `max_chain_spec`: Hausdorff's Maximality Principle.
* `flag`: The type of flags, aka maximal chains, of an order.

## Notes

Originally ported from Isabelle/HOL. The
[original file](https://isabelle.in.tum.de/dist/library/HOL/HOL/Zorn.html) was written by Jacques D.
Fleuriot, Tobias Nipkow, Christian Sternagel.
-/


open Classical Set

variable {α β : Type _}

/-! ### Chains -/


section Chain

variable (r : α → α → Prop)

-- mathport name: «expr ≺ »
local infixl:50 " ≺ " => r

/-- A chain is a set `s` satisfying `x ≺ y ∨ x = y ∨ y ≺ x` for all `x y ∈ s`. -/
def IsChain (s : Set α) : Prop :=
  s.Pairwise fun x y => x ≺ y ∨ y ≺ x
#align is_chain IsChain

/-- `super_chain s t` means that `t` is a chain that strictly includes `s`. -/
def SuperChain (s t : Set α) : Prop :=
  IsChain r t ∧ s ⊂ t
#align super_chain SuperChain

/-- A chain `s` is a maximal chain if there does not exists a chain strictly including `s`. -/
def IsMaxChain (s : Set α) : Prop :=
  IsChain r s ∧ ∀ ⦃t⦄, IsChain r t → s ⊆ t → s = t
#align is_max_chain IsMaxChain

variable {r} {c c₁ c₂ c₃ s t : Set α} {a b x y : α}

theorem is_chain_empty : IsChain r ∅ :=
  Set.pairwise_empty _
#align is_chain_empty is_chain_empty

theorem Set.Subsingleton.is_chain (hs : s.Subsingleton) : IsChain r s :=
  hs.Pairwise _
#align set.subsingleton.is_chain Set.Subsingleton.is_chain

theorem IsChain.mono : s ⊆ t → IsChain r t → IsChain r s :=
  Set.Pairwise.mono
#align is_chain.mono IsChain.mono

theorem IsChain.mono_rel {r' : α → α → Prop} (h : IsChain r s) (h_imp : ∀ x y, r x y → r' x y) :
    IsChain r' s :=
  h.mono' fun x y => Or.imp (h_imp x y) (h_imp y x)
#align is_chain.mono_rel IsChain.mono_rel

/-- This can be used to turn `is_chain (≥)` into `is_chain (≤)` and vice-versa. -/
theorem IsChain.symm (h : IsChain r s) : IsChain (flip r) s :=
  h.mono' fun _ _ => Or.symm
#align is_chain.symm IsChain.symm

theorem is_chain_of_trichotomous [IsTrichotomous α r] (s : Set α) : IsChain r s :=
  fun a _ b _ hab => (trichotomous_of r a b).imp_right fun h => h.resolve_left hab
#align is_chain_of_trichotomous is_chain_of_trichotomous

theorem IsChain.insert (hs : IsChain r s) (ha : ∀ b ∈ s, a ≠ b → a ≺ b ∨ b ≺ a) :
    IsChain r (insert a s) :=
  hs.insert_of_symmetric (fun _ _ => Or.symm) ha
#align is_chain.insert IsChain.insert

theorem is_chain_univ_iff : IsChain r (univ : Set α) ↔ IsTrichotomous α r :=
  by
  refine' ⟨fun h => ⟨fun a b => _⟩, fun h => @is_chain_of_trichotomous _ _ h univ⟩
  rw [or_left_comm, or_iff_not_imp_left]
  exact h trivial trivial
#align is_chain_univ_iff is_chain_univ_iff

theorem IsChain.image (r : α → α → Prop) (s : β → β → Prop) (f : α → β)
    (h : ∀ x y, r x y → s (f x) (f y)) {c : Set α} (hrc : IsChain r c) : IsChain s (f '' c) :=
  fun x ⟨a, ha₁, ha₂⟩ y ⟨b, hb₁, hb₂⟩ =>
  ha₂ ▸ hb₂ ▸ fun hxy => (hrc ha₁ hb₁ <| ne_of_apply_ne f hxy).imp (h _ _) (h _ _)
#align is_chain.image IsChain.image

section Total

variable [IsRefl α r]

theorem IsChain.total (h : IsChain r s) (hx : x ∈ s) (hy : y ∈ s) : x ≺ y ∨ y ≺ x :=
  (eq_or_ne x y).elim (fun e => Or.inl <| e ▸ refl _) (h hx hy)
#align is_chain.total IsChain.total

theorem IsChain.directed_on (H : IsChain r s) : DirectedOn r s := fun x hx y hy =>
  ((H.Total hx hy).elim fun h => ⟨y, hy, h, refl _⟩) fun h => ⟨x, hx, refl _, h⟩
#align is_chain.directed_on IsChain.directed_on

protected theorem IsChain.directed {f : β → α} {c : Set β} (h : IsChain (f ⁻¹'o r) c) :
    Directed r fun x : { a : β // a ∈ c } => f x := fun ⟨a, ha⟩ ⟨b, hb⟩ =>
  (by_cases fun hab : a = b => by
      simp only [hab, exists_prop, and_self_iff, Subtype.exists] <;> exact ⟨b, hb, refl _⟩)
    fun hab => ((h ha hb hab).elim fun h => ⟨⟨b, hb⟩, h, refl _⟩) fun h => ⟨⟨a, ha⟩, refl _, h⟩
#align is_chain.directed IsChain.directed

theorem IsChain.exists3 (hchain : IsChain r s) [IsTrans α r] {a b c} (mem1 : a ∈ s) (mem2 : b ∈ s)
    (mem3 : c ∈ s) : ∃ (z : _)(mem4 : z ∈ s), r a z ∧ r b z ∧ r c z :=
  by
  rcases directed_on_iff_directed.mpr (IsChain.directed hchain) a mem1 b mem2 with ⟨z, mem4, H1, H2⟩
  rcases directed_on_iff_directed.mpr (IsChain.directed hchain) z mem4 c mem3 with
    ⟨z', mem5, H3, H4⟩
  exact ⟨z', mem5, trans H1 H3, trans H2 H3, H4⟩
#align is_chain.exists3 IsChain.exists3

end Total

theorem IsMaxChain.is_chain (h : IsMaxChain r s) : IsChain r s :=
  h.1
#align is_max_chain.is_chain IsMaxChain.is_chain

theorem IsMaxChain.not_super_chain (h : IsMaxChain r s) : ¬SuperChain r s t := fun ht =>
  ht.2.Ne <| h.2 ht.1 ht.2.1
#align is_max_chain.not_super_chain IsMaxChain.not_super_chain

theorem IsMaxChain.bot_mem [LE α] [OrderBot α] (h : IsMaxChain (· ≤ ·) s) : ⊥ ∈ s :=
  (h.2 (h.1.insert fun a _ _ => Or.inl bot_le) <| subset_insert _ _).symm ▸ mem_insert _ _
#align is_max_chain.bot_mem IsMaxChain.bot_mem

theorem IsMaxChain.top_mem [LE α] [OrderTop α] (h : IsMaxChain (· ≤ ·) s) : ⊤ ∈ s :=
  (h.2 (h.1.insert fun a _ _ => Or.inr le_top) <| subset_insert _ _).symm ▸ mem_insert _ _
#align is_max_chain.top_mem IsMaxChain.top_mem

open Classical

/-- Given a set `s`, if there exists a chain `t` strictly including `s`, then `succ_chain s`
is one of these chains. Otherwise it is `s`. -/
def succChain (r : α → α → Prop) (s : Set α) : Set α :=
  if h : ∃ t, IsChain r s ∧ SuperChain r s t then choose h else s
#align succ_chain succChain

theorem succ_chain_spec (h : ∃ t, IsChain r s ∧ SuperChain r s t) :
    SuperChain r s (succChain r s) := by
  let ⟨t, hc'⟩ := h
  have : IsChain r s ∧ SuperChain r s (choose h) :=
    @choose_spec _ (fun t => IsChain r s ∧ SuperChain r s t) _
  simp [succChain, dif_pos, h, this.right]
#align succ_chain_spec succ_chain_spec

theorem IsChain.succ (hs : IsChain r s) : IsChain r (succChain r s) :=
  if h : ∃ t, IsChain r s ∧ SuperChain r s t then (succ_chain_spec h).1
  else by
    simp [succChain, dif_neg, h]
    exact hs
#align is_chain.succ IsChain.succ

theorem IsChain.super_chain_succ_chain (hs₁ : IsChain r s) (hs₂ : ¬IsMaxChain r s) :
    SuperChain r s (succChain r s) :=
  by
  simp [IsMaxChain, not_and_or, not_forall_not] at hs₂
  obtain ⟨t, ht, hst⟩ := hs₂.neg_resolve_left hs₁
  exact succ_chain_spec ⟨t, hs₁, ht, ssubset_iff_subset_ne.2 hst⟩
#align is_chain.super_chain_succ_chain IsChain.super_chain_succ_chain

theorem subset_succ_chain : s ⊆ succChain r s :=
  if h : ∃ t, IsChain r s ∧ SuperChain r s t then (succ_chain_spec h).2.1
  else by simp [succChain, dif_neg, h, subset.rfl]
#align subset_succ_chain subset_succ_chain

/-- Predicate for whether a set is reachable from `∅` using `succ_chain` and `⋃₀`. -/
inductive ChainClosure (r : α → α → Prop) : Set α → Prop
  | succ : ∀ {s}, ChainClosure s → ChainClosure (succChain r s)
  | union : ∀ {s}, (∀ a ∈ s, ChainClosure a) → ChainClosure (⋃₀s)
#align chain_closure ChainClosure

/-- An explicit maximal chain. `max_chain` is taken to be the union of all sets in `chain_closure`.
-/
def maxChain (r : α → α → Prop) :=
  ⋃₀setOf (ChainClosure r)
#align max_chain maxChain

theorem chain_closure_empty : ChainClosure r ∅ :=
  by
  have : ChainClosure r (⋃₀∅) := ChainClosure.union fun a h => h.rec _
  simpa using this
#align chain_closure_empty chain_closure_empty

theorem chain_closure_max_chain : ChainClosure r (maxChain r) :=
  ChainClosure.union fun s => id
#align chain_closure_max_chain chain_closure_max_chain

private theorem chain_closure_succ_total_aux (hc₁ : ChainClosure r c₁) (hc₂ : ChainClosure r c₂)
    (h : ∀ ⦃c₃⦄, ChainClosure r c₃ → c₃ ⊆ c₂ → c₂ = c₃ ∨ succChain r c₃ ⊆ c₂) :
    succChain r c₂ ⊆ c₁ ∨ c₁ ⊆ c₂ := by
  induction hc₁
  case succ c₃ hc₃ ih =>
    cases' ih with ih ih
    · exact Or.inl (ih.trans subset_succ_chain)
    · exact (h hc₃ ih).imp_left fun h => h ▸ subset.rfl
  case
    union s hs ih =>
    refine' or_iff_not_imp_left.2 fun hn => sUnion_subset fun a ha => _
    exact (ih a ha).resolve_left fun h => hn <| h.trans <| subset_sUnion_of_mem ha
#align chain_closure_succ_total_aux chain_closure_succ_total_aux

private theorem chain_closure_succ_total (hc₁ : ChainClosure r c₁) (hc₂ : ChainClosure r c₂)
    (h : c₁ ⊆ c₂) : c₂ = c₁ ∨ succChain r c₁ ⊆ c₂ :=
  by
  induction hc₂ generalizing c₁ hc₁ h
  case
    succ c₂ hc₂ ih =>
    refine' ((chain_closure_succ_total_aux hc₁ hc₂) fun c₁ => ih).imp h.antisymm' fun h₁ => _
    obtain rfl | h₂ := ih hc₁ h₁
    · exact subset.rfl
    · exact h₂.trans subset_succ_chain
  case union s hs ih =>
    apply Or.imp_left h.antisymm'
    apply by_contradiction
    simp [not_or, sUnion_subset_iff, not_forall]
    intro c₃ hc₃ h₁ h₂
    obtain h | h := chain_closure_succ_total_aux hc₁ (hs c₃ hc₃) fun c₄ => ih _ hc₃
    · exact h₁ (subset_succ_chain.trans h)
    obtain h' | h' := ih c₃ hc₃ hc₁ h
    · exact h₁ h'.subset
    · exact h₂ (h'.trans <| subset_sUnion_of_mem hc₃)
#align chain_closure_succ_total chain_closure_succ_total

theorem ChainClosure.total (hc₁ : ChainClosure r c₁) (hc₂ : ChainClosure r c₂) :
    c₁ ⊆ c₂ ∨ c₂ ⊆ c₁ :=
  ((chain_closure_succ_total_aux hc₂ hc₁) fun c₃ hc₃ => chain_closure_succ_total hc₃ hc₁).imp_left
    subset_succ_chain.trans
#align chain_closure.total ChainClosure.total

theorem ChainClosure.succ_fixpoint (hc₁ : ChainClosure r c₁) (hc₂ : ChainClosure r c₂)
    (hc : succChain r c₂ = c₂) : c₁ ⊆ c₂ :=
  by
  induction hc₁
  case succ s₁ hc₁ h => exact (chain_closure_succ_total hc₁ hc₂ h).elim (fun h => h ▸ hc.subset) id
  case union s hs ih => exact sUnion_subset ih
#align chain_closure.succ_fixpoint ChainClosure.succ_fixpoint

theorem ChainClosure.succ_fixpoint_iff (hc : ChainClosure r c) :
    succChain r c = c ↔ c = maxChain r :=
  ⟨fun h => (subset_unionₛ_of_mem hc).antisymm <| chain_closure_max_chain.succ_fixpoint hc h,
    fun h => subset_succ_chain.antisymm' <| (subset_unionₛ_of_mem hc.succ).trans h.symm.Subset⟩
#align chain_closure.succ_fixpoint_iff ChainClosure.succ_fixpoint_iff

theorem ChainClosure.is_chain (hc : ChainClosure r c) : IsChain r c :=
  by
  induction hc
  case succ c hc h => exact h.succ
  case union s hs h =>
    change ∀ c ∈ s, IsChain r c at h
    exact fun c₁ ⟨t₁, ht₁, (hc₁ : c₁ ∈ t₁)⟩ c₂ ⟨t₂, ht₂, (hc₂ : c₂ ∈ t₂)⟩ hneq =>
      ((hs _ ht₁).Total <| hs _ ht₂).elim (fun ht => h t₂ ht₂ (ht hc₁) hc₂ hneq) fun ht =>
        h t₁ ht₁ hc₁ (ht hc₂) hneq
#align chain_closure.is_chain ChainClosure.is_chain

/-- **Hausdorff's maximality principle**

There exists a maximal totally ordered set of `α`.
Note that we do not require `α` to be partially ordered by `r`. -/
theorem max_chain_spec : IsMaxChain r (maxChain r) :=
  by_contradiction fun h =>
    let ⟨h₁, H⟩ := chain_closure_max_chain.IsChain.super_chain_succ_chain h
    H.Ne (chain_closure_max_chain.succ_fixpoint_iff.mpr rfl).symm
#align max_chain_spec max_chain_spec

end Chain

/-! ### Flags -/


/-- The type of flags, aka maximal chains, of an order. -/
structure Flag (α : Type _) [LE α] where
  carrier : Set α
  Chain' : IsChain (· ≤ ·) carrier
  max_chain' : ∀ ⦃s⦄, IsChain (· ≤ ·) s → carrier ⊆ s → carrier = s
#align flag Flag

namespace Flag

section LE

variable [LE α] {s t : Flag α} {a : α}

instance : SetLike (Flag α) α where
  coe := carrier
  coe_injective' s t h := by
    cases s
    cases t
    congr

@[ext]
theorem ext : (s : Set α) = t → s = t :=
  SetLike.ext'
#align flag.ext Flag.ext

@[simp]
theorem mem_coe_iff : a ∈ (s : Set α) ↔ a ∈ s :=
  Iff.rfl
#align flag.mem_coe_iff Flag.mem_coe_iff

@[simp]
theorem coe_mk (s : Set α) (h₁ h₂) : (mk s h₁ h₂ : Set α) = s :=
  rfl
#align flag.coe_mk Flag.coe_mk

@[simp]
theorem mk_coe (s : Flag α) : mk (s : Set α) s.Chain' s.max_chain' = s :=
  ext rfl
#align flag.mk_coe Flag.mk_coe

theorem chain_le (s : Flag α) : IsChain (· ≤ ·) (s : Set α) :=
  s.Chain'
#align flag.chain_le Flag.chain_le

protected theorem max_chain (s : Flag α) : IsMaxChain (· ≤ ·) (s : Set α) :=
  ⟨s.chain_le, s.max_chain'⟩
#align flag.max_chain Flag.max_chain

theorem top_mem [OrderTop α] (s : Flag α) : (⊤ : α) ∈ s :=
  s.maxChain.top_mem
#align flag.top_mem Flag.top_mem

theorem bot_mem [OrderBot α] (s : Flag α) : (⊥ : α) ∈ s :=
  s.maxChain.bot_mem
#align flag.bot_mem Flag.bot_mem

end LE

section Preorder

variable [Preorder α] {a b : α}

protected theorem le_or_le (s : Flag α) (ha : a ∈ s) (hb : b ∈ s) : a ≤ b ∨ b ≤ a :=
  s.chain_le.Total ha hb
#align flag.le_or_le Flag.le_or_le

instance [OrderTop α] (s : Flag α) : OrderTop s :=
  Subtype.orderTop s.top_mem

instance [OrderBot α] (s : Flag α) : OrderBot s :=
  Subtype.orderBot s.bot_mem

instance [BoundedOrder α] (s : Flag α) : BoundedOrder s :=
  Subtype.boundedOrder s.bot_mem s.top_mem

end Preorder

section PartialOrder

variable [PartialOrder α]

theorem chain_lt (s : Flag α) : IsChain (· < ·) (s : Set α) := fun a ha b hb h =>
  (s.le_or_le ha hb).imp h.lt_of_le h.lt_of_le'
#align flag.chain_lt Flag.chain_lt

instance [DecidableEq α] [@DecidableRel α (· ≤ ·)] [@DecidableRel α (· < ·)] (s : Flag α) :
    LinearOrder s :=
  { Subtype.partialOrder _ with
    le_total := fun a b => s.le_or_le a.2 b.2
    DecidableEq := Subtype.decidableEq
    decidableLe := Subtype.decidableLE
    decidableLt := Subtype.decidableLT }

end PartialOrder

instance [LinearOrder α] : Unique (Flag α)
    where
  default := ⟨univ, is_chain_of_trichotomous _, fun s _ => s.subset_univ.antisymm'⟩
  uniq s := SetLike.coe_injective <| s.3 (is_chain_of_trichotomous _) <| subset_univ _

end Flag

