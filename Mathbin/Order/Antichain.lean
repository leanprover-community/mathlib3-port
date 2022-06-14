/-
Copyright (c) 2021 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies
-/
import Mathbin.Data.Set.Pairwise

/-!
# Antichains

This file defines antichains. An antichain is a set where any two distinct elements are not related.
If the relation is `(≤)`, this corresponds to incomparability and usual order antichains. If the
relation is `G.adj` for `G : simple_graph α`, this corresponds to independent sets of `G`.

## Definitions

* `is_antichain r s`: Any two elements of `s : set α` are unrelated by `r : α → α → Prop`.
* `is_strong_antichain r s`: Any two elements of `s : set α` are not related by `r : α → α → Prop`
  to a common element.
* `is_antichain.mk r s`: Turns `s` into an antichain by keeping only the "maximal" elements.
-/


open Function Set

variable {α β : Type _} {r r₁ r₂ : α → α → Prop} {r' : β → β → Prop} {s t : Set α} {a : α}

protected theorem Symmetric.compl (h : Symmetric r) : Symmetric (rᶜ) := fun x y hr hr' => hr <| h hr'

/-- An antichain is a set such that no two distinct elements are related. -/
def IsAntichain (r : α → α → Prop) (s : Set α) : Prop :=
  s.Pairwise (rᶜ)

namespace IsAntichain

protected theorem subset (hs : IsAntichain r s) (h : t ⊆ s) : IsAntichain r t :=
  hs.mono h

theorem mono (hs : IsAntichain r₁ s) (h : r₂ ≤ r₁) : IsAntichain r₂ s :=
  hs.mono' <| compl_le_compl h

theorem mono_on (hs : IsAntichain r₁ s) (h : s.Pairwise fun ⦃a b⦄ => r₂ a b → r₁ a b) : IsAntichain r₂ s :=
  hs.imp_on <| h.imp fun a b h h₁ h₂ => h₁ <| h h₂

protected theorem eq (hs : IsAntichain r s) {a b : α} (ha : a ∈ s) (hb : b ∈ s) (h : r a b) : a = b :=
  hs.Eq ha hb <| not_not_intro h

protected theorem eq' (hs : IsAntichain r s) {a b : α} (ha : a ∈ s) (hb : b ∈ s) (h : r b a) : a = b :=
  (hs.Eq hb ha h).symm

protected theorem is_antisymm (h : IsAntichain r Univ) : IsAntisymm α r :=
  ⟨fun a b ha _ => h.Eq trivialₓ trivialₓ ha⟩

protected theorem subsingleton [IsTrichotomous α r] (h : IsAntichain r s) : s.Subsingleton := by
  rintro a ha b hb
  obtain hab | hab | hab := trichotomous_of r a b
  · exact h.eq ha hb hab
    
  · exact hab
    
  · exact h.eq' ha hb hab
    

protected theorem flip (hs : IsAntichain r s) : IsAntichain (flip r) s := fun a ha b hb h => hs hb ha h.symm

theorem swap (hs : IsAntichain r s) : IsAntichain (swap r) s :=
  hs.flip

theorem image (hs : IsAntichain r s) (f : α → β) (h : ∀ ⦃a b⦄, r' (f a) (f b) → r a b) : IsAntichain r' (f '' s) := by
  rintro _ ⟨b, hb, rfl⟩ _ ⟨c, hc, rfl⟩ hbc hr
  exact hs hb hc (ne_of_apply_ne _ hbc) (h hr)

theorem preimage (hs : IsAntichain r s) {f : β → α} (hf : Injective f) (h : ∀ ⦃a b⦄, r' a b → r (f a) (f b)) :
    IsAntichain r' (f ⁻¹' s) := fun b hb c hc hbc hr => hs hb hc (hf.Ne hbc) <| h hr

theorem _root_.is_antichain_insert :
    IsAntichain r (insert a s) ↔ IsAntichain r s ∧ ∀ ⦃b⦄, b ∈ s → a ≠ b → ¬r a b ∧ ¬r b a :=
  Set.pairwise_insert

protected theorem insert (hs : IsAntichain r s) (hl : ∀ ⦃b⦄, b ∈ s → a ≠ b → ¬r b a)
    (hr : ∀ ⦃b⦄, b ∈ s → a ≠ b → ¬r a b) : IsAntichain r (insert a s) :=
  is_antichain_insert.2 ⟨hs, fun b hb hab => ⟨hr hb hab, hl hb hab⟩⟩

theorem _root_.is_antichain_insert_of_symmetric (hr : Symmetric r) :
    IsAntichain r (insert a s) ↔ IsAntichain r s ∧ ∀ ⦃b⦄, b ∈ s → a ≠ b → ¬r a b :=
  pairwise_insert_of_symmetric hr.Compl

theorem insert_of_symmetric (hs : IsAntichain r s) (hr : Symmetric r) (h : ∀ ⦃b⦄, b ∈ s → a ≠ b → ¬r a b) :
    IsAntichain r (insert a s) :=
  (is_antichain_insert_of_symmetric hr).2 ⟨hs, h⟩

theorem image_rel_embedding (hs : IsAntichain r s) (φ : r ↪r r') : IsAntichain r' (φ '' s) := by
  intro b hb b' hb' h₁ h₂
  rw [Set.mem_image] at hb hb'
  obtain ⟨⟨a, has, rfl⟩, ⟨a', has', rfl⟩⟩ := hb, hb'
  exact
    hs has has'
      (fun haa' =>
        h₁
          (haa'.subst
            (by
              rfl)))
      (φ.map_rel_iff.mp h₂)

theorem preimage_rel_embedding {t : Set β} (ht : IsAntichain r' t) (φ : r ↪r r') : IsAntichain r (φ ⁻¹' t) :=
  fun a ha a' ha' hne hle => ht ha ha' (fun h => hne (φ.Injective h)) (φ.map_rel_iff.mpr hle)

theorem image_rel_iso (hs : IsAntichain r s) (φ : r ≃r r') : IsAntichain r' (φ '' s) :=
  hs.image_rel_embedding φ

theorem preimage_rel_iso {t : Set β} (hs : IsAntichain r' t) (φ : r ≃r r') : IsAntichain r (φ ⁻¹' t) :=
  hs.preimage_rel_embedding φ

theorem image_rel_embedding_iff {φ : r ↪r r'} : IsAntichain r' (φ '' s) ↔ IsAntichain r s :=
  ⟨fun h => (φ.Injective.preimage_image s).subst (h.preimage_rel_embedding φ), fun h => h.image_rel_embedding φ⟩

theorem image_rel_iso_iff {φ : r ≃r r'} : IsAntichain r' (φ '' s) ↔ IsAntichain r s :=
  @image_rel_embedding_iff _ _ _ _ _ (φ : r ↪r r')

theorem image_embedding [LE α] [LE β] (hs : IsAntichain (· ≤ ·) s) (φ : α ↪o β) : IsAntichain (· ≤ ·) (φ '' s) :=
  image_rel_embedding hs _

theorem preimage_embedding [LE α] [LE β] {t : Set β} (ht : IsAntichain (· ≤ ·) t) (φ : α ↪o β) :
    IsAntichain (· ≤ ·) (φ ⁻¹' t) :=
  preimage_rel_embedding ht _

theorem image_embedding_iff [LE α] [LE β] {φ : α ↪o β} : IsAntichain (· ≤ ·) (φ '' s) ↔ IsAntichain (· ≤ ·) s :=
  image_rel_embedding_iff

theorem image_iso [LE α] [LE β] (hs : IsAntichain (· ≤ ·) s) (φ : α ≃o β) : IsAntichain (· ≤ ·) (φ '' s) :=
  image_rel_embedding hs _

theorem image_iso_iff [LE α] [LE β] {φ : α ≃o β} : IsAntichain (· ≤ ·) (φ '' s) ↔ IsAntichain (· ≤ ·) s :=
  image_rel_embedding_iff

theorem preimage_iso [LE α] [LE β] {t : Set β} (ht : IsAntichain (· ≤ ·) t) (φ : α ≃o β) :
    IsAntichain (· ≤ ·) (φ ⁻¹' t) :=
  preimage_rel_embedding ht _

theorem preimage_iso_iff [LE α] [LE β] {t : Set β} {φ : α ≃o β} :
    IsAntichain (· ≤ ·) (φ ⁻¹' t) ↔ IsAntichain (· ≤ ·) t :=
  ⟨fun h => (φ.image_preimage t).subst (h.image_iso φ), fun h => h.preimage_iso _⟩

theorem to_dual [LE α] (hs : IsAntichain (· ≤ ·) s) : @IsAntichain αᵒᵈ (· ≤ ·) s := fun a ha b hb hab =>
  hs hb ha hab.symm

theorem to_dual_iff [LE α] : IsAntichain (· ≤ ·) s ↔ @IsAntichain αᵒᵈ (· ≤ ·) s :=
  ⟨to_dual, to_dual⟩

theorem image_compl [BooleanAlgebra α] (hs : IsAntichain (· ≤ ·) s) : IsAntichain (· ≤ ·) (compl '' s) :=
  (hs.image_embedding (OrderIso.compl α).toOrderEmbedding).flip

theorem preimage_compl [BooleanAlgebra α] (hs : IsAntichain (· ≤ ·) s) : IsAntichain (· ≤ ·) (compl ⁻¹' s) :=
  fun a ha a' ha' hne hle => hs ha' ha (fun h => hne (compl_inj_iff.mp h.symm)) (compl_le_compl hle)

end IsAntichain

theorem is_antichain_singleton (a : α) (r : α → α → Prop) : IsAntichain r {a} :=
  pairwise_singleton _ _

theorem Set.Subsingleton.is_antichain (hs : s.Subsingleton) (r : α → α → Prop) : IsAntichain r s :=
  hs.Pairwise _

section Preorderₓ

variable [Preorderₓ α]

theorem is_antichain_and_least_iff : IsAntichain (· ≤ ·) s ∧ IsLeast s a ↔ s = {a} :=
  ⟨fun h => eq_singleton_iff_unique_mem.2 ⟨h.2.1, fun b hb => h.1.eq' hb h.2.1 (h.2.2 hb)⟩, by
    rintro rfl
    exact ⟨is_antichain_singleton _ _, is_least_singleton⟩⟩

theorem is_antichain_and_greatest_iff : IsAntichain (· ≤ ·) s ∧ IsGreatest s a ↔ s = {a} :=
  ⟨fun h => eq_singleton_iff_unique_mem.2 ⟨h.2.1, fun b hb => h.1.Eq hb h.2.1 (h.2.2 hb)⟩, by
    rintro rfl
    exact ⟨is_antichain_singleton _ _, is_greatest_singleton⟩⟩

theorem IsAntichain.least_iff (hs : IsAntichain (· ≤ ·) s) : IsLeast s a ↔ s = {a} :=
  (and_iff_right hs).symm.trans is_antichain_and_least_iff

theorem IsAntichain.greatest_iff (hs : IsAntichain (· ≤ ·) s) : IsGreatest s a ↔ s = {a} :=
  (and_iff_right hs).symm.trans is_antichain_and_greatest_iff

theorem IsLeast.antichain_iff (hs : IsLeast s a) : IsAntichain (· ≤ ·) s ↔ s = {a} :=
  (and_iff_left hs).symm.trans is_antichain_and_least_iff

theorem IsGreatest.antichain_iff (hs : IsGreatest s a) : IsAntichain (· ≤ ·) s ↔ s = {a} :=
  (and_iff_left hs).symm.trans is_antichain_and_greatest_iff

theorem IsAntichain.bot_mem_iff [OrderBot α] (hs : IsAntichain (· ≤ ·) s) : ⊥ ∈ s ↔ s = {⊥} :=
  is_least_bot_iff.symm.trans hs.least_iff

theorem IsAntichain.top_mem_iff [OrderTop α] (hs : IsAntichain (· ≤ ·) s) : ⊤ ∈ s ↔ s = {⊤} :=
  is_greatest_top_iff.symm.trans hs.greatest_iff

end Preorderₓ

/-! ### Strong antichains -/


/-- An strong (upward) antichain is a set such that no two distinct elements are related to a common
element. -/
def IsStrongAntichain (r : α → α → Prop) (s : Set α) : Prop :=
  s.Pairwise fun a b => ∀ c, ¬r a c ∨ ¬r b c

namespace IsStrongAntichain

protected theorem subset (hs : IsStrongAntichain r s) (h : t ⊆ s) : IsStrongAntichain r t :=
  hs.mono h

theorem mono (hs : IsStrongAntichain r₁ s) (h : r₂ ≤ r₁) : IsStrongAntichain r₂ s :=
  hs.mono' fun a b hab c => (hab c).imp (compl_le_compl h _ _) (compl_le_compl h _ _)

theorem eq (hs : IsStrongAntichain r s) {a b c : α} (ha : a ∈ s) (hb : b ∈ s) (hac : r a c) (hbc : r b c) : a = b :=
  (hs.Eq ha hb) fun h => False.elim <| (h c).elim (not_not_intro hac) (not_not_intro hbc)

protected theorem is_antichain [IsRefl α r] (h : IsStrongAntichain r s) : IsAntichain r s :=
  h.imp fun a b hab => (hab b).resolve_right (not_not_intro <| refl _)

protected theorem subsingleton [IsDirected α r] (h : IsStrongAntichain r s) : s.Subsingleton := fun a ha b hb =>
  let ⟨c, hac, hbc⟩ := directed_of r a b
  h.Eq ha hb hac hbc

protected theorem flip [IsSymm α r] (hs : IsStrongAntichain r s) : IsStrongAntichain (flip r) s := fun a ha b hb h c =>
  (hs ha hb h c).imp (mt <| symm_of r) (mt <| symm_of r)

theorem swap [IsSymm α r] (hs : IsStrongAntichain r s) : IsStrongAntichain (swap r) s :=
  hs.flip

theorem image (hs : IsStrongAntichain r s) {f : α → β} (hf : Surjective f) (h : ∀ a b, r' (f a) (f b) → r a b) :
    IsStrongAntichain r' (f '' s) := by
  rintro _ ⟨a, ha, rfl⟩ _ ⟨b, hb, rfl⟩ hab c
  obtain ⟨c, rfl⟩ := hf c
  exact (hs ha hb (ne_of_apply_ne _ hab) _).imp (mt <| h _ _) (mt <| h _ _)

theorem preimage (hs : IsStrongAntichain r s) {f : β → α} (hf : Injective f) (h : ∀ a b, r' a b → r (f a) (f b)) :
    IsStrongAntichain r' (f ⁻¹' s) := fun a ha b hb hab c => (hs ha hb (hf.Ne hab) _).imp (mt <| h _ _) (mt <| h _ _)

theorem _root_.is_strong_antichain_insert :
    IsStrongAntichain r (insert a s) ↔ IsStrongAntichain r s ∧ ∀ ⦃b⦄, b ∈ s → a ≠ b → ∀ c, ¬r a c ∨ ¬r b c :=
  Set.pairwise_insert_of_symmetric fun a b h c => (h c).symm

protected theorem insert (hs : IsStrongAntichain r s) (h : ∀ ⦃b⦄, b ∈ s → a ≠ b → ∀ c, ¬r a c ∨ ¬r b c) :
    IsStrongAntichain r (insert a s) :=
  is_strong_antichain_insert.2 ⟨hs, h⟩

end IsStrongAntichain

theorem Set.Subsingleton.is_strong_antichain (hs : s.Subsingleton) (r : α → α → Prop) : IsStrongAntichain r s :=
  hs.Pairwise _

