/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies
-/
import Data.Finset.Sum
import Data.Sum.Order
import Order.Interval.Finset.Defs

#align_import data.sum.interval from "leanprover-community/mathlib"@"48a058d7e39a80ed56858505719a0b2197900999"

/-!
# Finite intervals in a disjoint union

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file provides the `locally_finite_order` instance for the disjoint sum and linear sum of two
orders and calculates the cardinality of their finite intervals.
-/


open Function Sum

namespace Finset

variable {α₁ α₂ β₁ β₂ γ₁ γ₂ : Type _}

section SumLift₂

variable (f f₁ g₁ : α₁ → β₁ → Finset γ₁) (g f₂ g₂ : α₂ → β₂ → Finset γ₂)

#print Finset.sumLift₂ /-
/-- Lifts maps `α₁ → β₁ → finset γ₁` and `α₂ → β₂ → finset γ₂` to a map
`α₁ ⊕ α₂ → β₁ ⊕ β₂ → finset (γ₁ ⊕ γ₂)`. Could be generalized to `alternative` functors if we can
make sure to keep computability and universe polymorphism. -/
@[simp]
def sumLift₂ : ∀ (a : Sum α₁ α₂) (b : Sum β₁ β₂), Finset (Sum γ₁ γ₂)
  | inl a, inl b => (f a b).map Embedding.inl
  | inl a, inr b => ∅
  | inr a, inl b => ∅
  | inr a, inr b => (g a b).map Embedding.inr
#align finset.sum_lift₂ Finset.sumLift₂
-/

variable {f f₁ g₁ g f₂ g₂} {a : Sum α₁ α₂} {b : Sum β₁ β₂} {c : Sum γ₁ γ₂}

#print Finset.mem_sumLift₂ /-
theorem mem_sumLift₂ :
    c ∈ sumLift₂ f g a b ↔
      (∃ a₁ b₁ c₁, a = inl a₁ ∧ b = inl b₁ ∧ c = inl c₁ ∧ c₁ ∈ f a₁ b₁) ∨
        ∃ a₂ b₂ c₂, a = inr a₂ ∧ b = inr b₂ ∧ c = inr c₂ ∧ c₂ ∈ g a₂ b₂ :=
  by
  constructor
  · cases a <;> cases b
    · rw [sum_lift₂, mem_map]
      rintro ⟨c, hc, rfl⟩
      exact Or.inl ⟨a, b, c, rfl, rfl, rfl, hc⟩
    · refine' fun h => (not_mem_empty _ h).elim
    · refine' fun h => (not_mem_empty _ h).elim
    · rw [sum_lift₂, mem_map]
      rintro ⟨c, hc, rfl⟩
      exact Or.inr ⟨a, b, c, rfl, rfl, rfl, hc⟩
  · rintro (⟨a, b, c, rfl, rfl, rfl, h⟩ | ⟨a, b, c, rfl, rfl, rfl, h⟩) <;> exact mem_map_of_mem _ h
#align finset.mem_sum_lift₂ Finset.mem_sumLift₂
-/

#print Finset.inl_mem_sumLift₂ /-
theorem inl_mem_sumLift₂ {c₁ : γ₁} :
    inl c₁ ∈ sumLift₂ f g a b ↔ ∃ a₁ b₁, a = inl a₁ ∧ b = inl b₁ ∧ c₁ ∈ f a₁ b₁ :=
  by
  rw [mem_sum_lift₂, or_iff_left]
  simp only [exists_and_left, exists_eq_left']
  rintro ⟨_, _, c₂, _, _, h, _⟩
  exact inl_ne_inr h
#align finset.inl_mem_sum_lift₂ Finset.inl_mem_sumLift₂
-/

#print Finset.inr_mem_sumLift₂ /-
theorem inr_mem_sumLift₂ {c₂ : γ₂} :
    inr c₂ ∈ sumLift₂ f g a b ↔ ∃ a₂ b₂, a = inr a₂ ∧ b = inr b₂ ∧ c₂ ∈ g a₂ b₂ :=
  by
  rw [mem_sum_lift₂, or_iff_right]
  simp only [exists_and_left, exists_eq_left']
  rintro ⟨_, _, c₂, _, _, h, _⟩
  exact inr_ne_inl h
#align finset.inr_mem_sum_lift₂ Finset.inr_mem_sumLift₂
-/

#print Finset.sumLift₂_eq_empty /-
theorem sumLift₂_eq_empty :
    sumLift₂ f g a b = ∅ ↔
      (∀ a₁ b₁, a = inl a₁ → b = inl b₁ → f a₁ b₁ = ∅) ∧
        ∀ a₂ b₂, a = inr a₂ → b = inr b₂ → g a₂ b₂ = ∅ :=
  by
  refine' ⟨fun h => _, fun h => _⟩
  · constructor <;> · rintro a b rfl rfl; exact map_eq_empty.1 h
  cases a <;> cases b
  · exact map_eq_empty.2 (h.1 _ _ rfl rfl)
  · rfl
  · rfl
  · exact map_eq_empty.2 (h.2 _ _ rfl rfl)
#align finset.sum_lift₂_eq_empty Finset.sumLift₂_eq_empty
-/

#print Finset.sumLift₂_nonempty /-
theorem sumLift₂_nonempty :
    (sumLift₂ f g a b).Nonempty ↔
      (∃ a₁ b₁, a = inl a₁ ∧ b = inl b₁ ∧ (f a₁ b₁).Nonempty) ∨
        ∃ a₂ b₂, a = inr a₂ ∧ b = inr b₂ ∧ (g a₂ b₂).Nonempty :=
  by simp [nonempty_iff_ne_empty, sum_lift₂_eq_empty, not_and_or]
#align finset.sum_lift₂_nonempty Finset.sumLift₂_nonempty
-/

#print Finset.sumLift₂_mono /-
theorem sumLift₂_mono (h₁ : ∀ a b, f₁ a b ⊆ g₁ a b) (h₂ : ∀ a b, f₂ a b ⊆ g₂ a b) :
    ∀ a b, sumLift₂ f₁ f₂ a b ⊆ sumLift₂ g₁ g₂ a b
  | inl a, inl b => map_subset_map.2 (h₁ _ _)
  | inl a, inr b => Subset.rfl
  | inr a, inl b => Subset.rfl
  | inr a, inr b => map_subset_map.2 (h₂ _ _)
#align finset.sum_lift₂_mono Finset.sumLift₂_mono
-/

end SumLift₂

section SumLexLift

variable (f₁ f₁' : α₁ → β₁ → Finset γ₁) (f₂ f₂' : α₂ → β₂ → Finset γ₂)
  (g₁ g₁' : α₁ → β₂ → Finset γ₁) (g₂ g₂' : α₁ → β₂ → Finset γ₂)

#print Finset.sumLexLift /-
/-- Lifts maps `α₁ → β₁ → finset γ₁`, `α₂ → β₂ → finset γ₂`, `α₁ → β₂ → finset γ₁`,
`α₂ → β₂ → finset γ₂`  to a map `α₁ ⊕ α₂ → β₁ ⊕ β₂ → finset (γ₁ ⊕ γ₂)`. Could be generalized to
alternative monads if we can make sure to keep computability and universe polymorphism. -/
def sumLexLift : ∀ (a : Sum α₁ α₂) (b : Sum β₁ β₂), Finset (Sum γ₁ γ₂)
  | inl a, inl b => (f₁ a b).map Embedding.inl
  | inl a, inr b => (g₁ a b).disjSum (g₂ a b)
  | inr a, inl b => ∅
  | inr a, inr b => (f₂ a b).map ⟨_, inr_injective⟩
#align finset.sum_lex_lift Finset.sumLexLift
-/

#print Finset.sumLexLift_inl_inl /-
@[simp]
theorem sumLexLift_inl_inl (a : α₁) (b : β₁) :
    sumLexLift f₁ f₂ g₁ g₂ (inl a) (inl b) = (f₁ a b).map Embedding.inl :=
  rfl
#align finset.sum_lex_lift_inl_inl Finset.sumLexLift_inl_inl
-/

#print Finset.sumLexLift_inl_inr /-
@[simp]
theorem sumLexLift_inl_inr (a : α₁) (b : β₂) :
    sumLexLift f₁ f₂ g₁ g₂ (inl a) (inr b) = (g₁ a b).disjSum (g₂ a b) :=
  rfl
#align finset.sum_lex_lift_inl_inr Finset.sumLexLift_inl_inr
-/

#print Finset.sumLexLift_inr_inl /-
@[simp]
theorem sumLexLift_inr_inl (a : α₂) (b : β₁) : sumLexLift f₁ f₂ g₁ g₂ (inr a) (inl b) = ∅ :=
  rfl
#align finset.sum_lex_lift_inr_inl Finset.sumLexLift_inr_inl
-/

#print Finset.sumLexLift_inr_inr /-
@[simp]
theorem sumLexLift_inr_inr (a : α₂) (b : β₂) :
    sumLexLift f₁ f₂ g₁ g₂ (inr a) (inr b) = (f₂ a b).map ⟨_, inr_injective⟩ :=
  rfl
#align finset.sum_lex_lift_inr_inr Finset.sumLexLift_inr_inr
-/

variable {f₁ g₁ f₂ g₂ f₁' g₁' f₂' g₂'} {a : Sum α₁ α₂} {b : Sum β₁ β₂} {c : Sum γ₁ γ₂}

#print Finset.mem_sumLexLift /-
theorem mem_sumLexLift :
    c ∈ sumLexLift f₁ f₂ g₁ g₂ a b ↔
      (∃ a₁ b₁ c₁, a = inl a₁ ∧ b = inl b₁ ∧ c = inl c₁ ∧ c₁ ∈ f₁ a₁ b₁) ∨
        (∃ a₁ b₂ c₁, a = inl a₁ ∧ b = inr b₂ ∧ c = inl c₁ ∧ c₁ ∈ g₁ a₁ b₂) ∨
          (∃ a₁ b₂ c₂, a = inl a₁ ∧ b = inr b₂ ∧ c = inr c₂ ∧ c₂ ∈ g₂ a₁ b₂) ∨
            ∃ a₂ b₂ c₂, a = inr a₂ ∧ b = inr b₂ ∧ c = inr c₂ ∧ c₂ ∈ f₂ a₂ b₂ :=
  by
  constructor
  · cases a <;> cases b
    · rw [sum_lex_lift, mem_map]
      rintro ⟨c, hc, rfl⟩
      exact Or.inl ⟨a, b, c, rfl, rfl, rfl, hc⟩
    · refine' fun h => (mem_disj_sum.1 h).elim _ _
      · rintro ⟨c, hc, rfl⟩
        refine' Or.inr (Or.inl ⟨a, b, c, rfl, rfl, rfl, hc⟩)
      · rintro ⟨c, hc, rfl⟩
        refine' Or.inr (Or.inr <| Or.inl ⟨a, b, c, rfl, rfl, rfl, hc⟩)
    · refine' fun h => (not_mem_empty _ h).elim
    · rw [sum_lex_lift, mem_map]
      rintro ⟨c, hc, rfl⟩
      exact Or.inr (Or.inr <| Or.inr <| ⟨a, b, c, rfl, rfl, rfl, hc⟩)
  · rintro
      (⟨a, b, c, rfl, rfl, rfl, hc⟩ | ⟨a, b, c, rfl, rfl, rfl, hc⟩ | ⟨a, b, c, rfl, rfl, rfl, hc⟩ |
          ⟨a, b, c, rfl, rfl, rfl, hc⟩)
    · exact mem_map_of_mem _ hc
    · exact inl_mem_disj_sum.2 hc
    · exact inr_mem_disj_sum.2 hc
    · exact mem_map_of_mem _ hc
#align finset.mem_sum_lex_lift Finset.mem_sumLexLift
-/

#print Finset.inl_mem_sumLexLift /-
theorem inl_mem_sumLexLift {c₁ : γ₁} :
    inl c₁ ∈ sumLexLift f₁ f₂ g₁ g₂ a b ↔
      (∃ a₁ b₁, a = inl a₁ ∧ b = inl b₁ ∧ c₁ ∈ f₁ a₁ b₁) ∨
        ∃ a₁ b₂, a = inl a₁ ∧ b = inr b₂ ∧ c₁ ∈ g₁ a₁ b₂ :=
  by simp [mem_sum_lex_lift]
#align finset.inl_mem_sum_lex_lift Finset.inl_mem_sumLexLift
-/

#print Finset.inr_mem_sumLexLift /-
theorem inr_mem_sumLexLift {c₂ : γ₂} :
    inr c₂ ∈ sumLexLift f₁ f₂ g₁ g₂ a b ↔
      (∃ a₁ b₂, a = inl a₁ ∧ b = inr b₂ ∧ c₂ ∈ g₂ a₁ b₂) ∨
        ∃ a₂ b₂, a = inr a₂ ∧ b = inr b₂ ∧ c₂ ∈ f₂ a₂ b₂ :=
  by simp [mem_sum_lex_lift]
#align finset.inr_mem_sum_lex_lift Finset.inr_mem_sumLexLift
-/

#print Finset.sumLexLift_mono /-
theorem sumLexLift_mono (hf₁ : ∀ a b, f₁ a b ⊆ f₁' a b) (hf₂ : ∀ a b, f₂ a b ⊆ f₂' a b)
    (hg₁ : ∀ a b, g₁ a b ⊆ g₁' a b) (hg₂ : ∀ a b, g₂ a b ⊆ g₂' a b) (a : Sum α₁ α₂)
    (b : Sum β₁ β₂) : sumLexLift f₁ f₂ g₁ g₂ a b ⊆ sumLexLift f₁' f₂' g₁' g₂' a b :=
  by
  cases a <;> cases b
  exacts [map_subset_map.2 (hf₁ _ _), disj_sum_mono (hg₁ _ _) (hg₂ _ _), subset.rfl,
    map_subset_map.2 (hf₂ _ _)]
#align finset.sum_lex_lift_mono Finset.sumLexLift_mono
-/

#print Finset.sumLexLift_eq_empty /-
theorem sumLexLift_eq_empty :
    sumLexLift f₁ f₂ g₁ g₂ a b = ∅ ↔
      (∀ a₁ b₁, a = inl a₁ → b = inl b₁ → f₁ a₁ b₁ = ∅) ∧
        (∀ a₁ b₂, a = inl a₁ → b = inr b₂ → g₁ a₁ b₂ = ∅ ∧ g₂ a₁ b₂ = ∅) ∧
          ∀ a₂ b₂, a = inr a₂ → b = inr b₂ → f₂ a₂ b₂ = ∅ :=
  by
  refine' ⟨fun h => ⟨_, _, _⟩, fun h => _⟩
  any_goals rintro a b rfl rfl; exact map_eq_empty.1 h
  · rintro a b rfl rfl; exact disj_sum_eq_empty.1 h
  cases a <;> cases b
  · exact map_eq_empty.2 (h.1 _ _ rfl rfl)
  · simp [h.2.1 _ _ rfl rfl]
  · rfl
  · exact map_eq_empty.2 (h.2.2 _ _ rfl rfl)
#align finset.sum_lex_lift_eq_empty Finset.sumLexLift_eq_empty
-/

#print Finset.sumLexLift_nonempty /-
theorem sumLexLift_nonempty :
    (sumLexLift f₁ f₂ g₁ g₂ a b).Nonempty ↔
      (∃ a₁ b₁, a = inl a₁ ∧ b = inl b₁ ∧ (f₁ a₁ b₁).Nonempty) ∨
        (∃ a₁ b₂, a = inl a₁ ∧ b = inr b₂ ∧ ((g₁ a₁ b₂).Nonempty ∨ (g₂ a₁ b₂).Nonempty)) ∨
          ∃ a₂ b₂, a = inr a₂ ∧ b = inr b₂ ∧ (f₂ a₂ b₂).Nonempty :=
  by simp [nonempty_iff_ne_empty, sum_lex_lift_eq_empty, not_and_or]
#align finset.sum_lex_lift_nonempty Finset.sumLexLift_nonempty
-/

end SumLexLift

end Finset

open Finset Function

namespace Sum

variable {α β : Type _}

/-! ### Disjoint sum of orders -/


section Disjoint

variable [Preorder α] [Preorder β] [LocallyFiniteOrder α] [LocallyFiniteOrder β]

instance : LocallyFiniteOrder (Sum α β)
    where
  finsetIcc := sumLift₂ Icc Icc
  finsetIco := sumLift₂ Ico Ico
  finsetIoc := sumLift₂ Ioc Ioc
  finsetIoo := sumLift₂ Ioo Ioo
  finset_mem_Icc := by rintro (a | a) (b | b) (x | x) <;> simp
  finset_mem_Ico := by rintro (a | a) (b | b) (x | x) <;> simp
  finset_mem_Ioc := by rintro (a | a) (b | b) (x | x) <;> simp
  finset_mem_Ioo := by rintro (a | a) (b | b) (x | x) <;> simp

variable (a₁ a₂ : α) (b₁ b₂ : β) (a b : Sum α β)

#print Sum.Icc_inl_inl /-
theorem Icc_inl_inl : Icc (inl a₁ : Sum α β) (inl a₂) = (Icc a₁ a₂).map Embedding.inl :=
  rfl
#align sum.Icc_inl_inl Sum.Icc_inl_inl
-/

#print Sum.Ico_inl_inl /-
theorem Ico_inl_inl : Ico (inl a₁ : Sum α β) (inl a₂) = (Ico a₁ a₂).map Embedding.inl :=
  rfl
#align sum.Ico_inl_inl Sum.Ico_inl_inl
-/

#print Sum.Ioc_inl_inl /-
theorem Ioc_inl_inl : Ioc (inl a₁ : Sum α β) (inl a₂) = (Ioc a₁ a₂).map Embedding.inl :=
  rfl
#align sum.Ioc_inl_inl Sum.Ioc_inl_inl
-/

#print Sum.Ioo_inl_inl /-
theorem Ioo_inl_inl : Ioo (inl a₁ : Sum α β) (inl a₂) = (Ioo a₁ a₂).map Embedding.inl :=
  rfl
#align sum.Ioo_inl_inl Sum.Ioo_inl_inl
-/

#print Sum.Icc_inl_inr /-
@[simp]
theorem Icc_inl_inr : Icc (inl a₁) (inr b₂) = ∅ :=
  rfl
#align sum.Icc_inl_inr Sum.Icc_inl_inr
-/

#print Sum.Ico_inl_inr /-
@[simp]
theorem Ico_inl_inr : Ico (inl a₁) (inr b₂) = ∅ :=
  rfl
#align sum.Ico_inl_inr Sum.Ico_inl_inr
-/

#print Sum.Ioc_inl_inr /-
@[simp]
theorem Ioc_inl_inr : Ioc (inl a₁) (inr b₂) = ∅ :=
  rfl
#align sum.Ioc_inl_inr Sum.Ioc_inl_inr
-/

#print Sum.Ioo_inl_inr /-
@[simp]
theorem Ioo_inl_inr : Ioo (inl a₁) (inr b₂) = ∅ :=
  rfl
#align sum.Ioo_inl_inr Sum.Ioo_inl_inr
-/

#print Sum.Icc_inr_inl /-
@[simp]
theorem Icc_inr_inl : Icc (inr b₁) (inl a₂) = ∅ :=
  rfl
#align sum.Icc_inr_inl Sum.Icc_inr_inl
-/

#print Sum.Ico_inr_inl /-
@[simp]
theorem Ico_inr_inl : Ico (inr b₁) (inl a₂) = ∅ :=
  rfl
#align sum.Ico_inr_inl Sum.Ico_inr_inl
-/

#print Sum.Ioc_inr_inl /-
@[simp]
theorem Ioc_inr_inl : Ioc (inr b₁) (inl a₂) = ∅ :=
  rfl
#align sum.Ioc_inr_inl Sum.Ioc_inr_inl
-/

#print Sum.Ioo_inr_inl /-
@[simp]
theorem Ioo_inr_inl : Ioo (inr b₁) (inl a₂) = ∅ :=
  rfl
#align sum.Ioo_inr_inl Sum.Ioo_inr_inl
-/

#print Sum.Icc_inr_inr /-
theorem Icc_inr_inr : Icc (inr b₁ : Sum α β) (inr b₂) = (Icc b₁ b₂).map Embedding.inr :=
  rfl
#align sum.Icc_inr_inr Sum.Icc_inr_inr
-/

#print Sum.Ico_inr_inr /-
theorem Ico_inr_inr : Ico (inr b₁ : Sum α β) (inr b₂) = (Ico b₁ b₂).map Embedding.inr :=
  rfl
#align sum.Ico_inr_inr Sum.Ico_inr_inr
-/

#print Sum.Ioc_inr_inr /-
theorem Ioc_inr_inr : Ioc (inr b₁ : Sum α β) (inr b₂) = (Ioc b₁ b₂).map Embedding.inr :=
  rfl
#align sum.Ioc_inr_inr Sum.Ioc_inr_inr
-/

#print Sum.Ioo_inr_inr /-
theorem Ioo_inr_inr : Ioo (inr b₁ : Sum α β) (inr b₂) = (Ioo b₁ b₂).map Embedding.inr :=
  rfl
#align sum.Ioo_inr_inr Sum.Ioo_inr_inr
-/

end Disjoint

/-! ### Lexicographical sum of orders -/


namespace Lex

variable [Preorder α] [Preorder β] [OrderTop α] [OrderBot β] [LocallyFiniteOrder α]
  [LocallyFiniteOrder β]

/- ././././Mathport/Syntax/Translate/Expr.lean:338:4: warning: unsupported (TODO): `[tacs] -/
/-- Throwaway tactic. -/
private unsafe def simp_lex : tactic Unit :=
  sorry

/- ././././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.1221522619.simp_lex -/
/- ././././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.1221522619.simp_lex -/
/- ././././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.1221522619.simp_lex -/
/- ././././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.1221522619.simp_lex -/
#print Sum.Lex.locallyFiniteOrder /-
instance locallyFiniteOrder : LocallyFiniteOrder (α ⊕ₗ β)
    where
  finsetIcc a b :=
    (sumLexLift Icc Icc (fun a _ => Ici a) (fun _ => Iic) (ofLex a) (ofLex b)).map toLex.toEmbedding
  finsetIco a b :=
    (sumLexLift Ico Ico (fun a _ => Ici a) (fun _ => Iio) (ofLex a) (ofLex b)).map toLex.toEmbedding
  finsetIoc a b :=
    (sumLexLift Ioc Ioc (fun a _ => Ioi a) (fun _ => Iic) (ofLex a) (ofLex b)).map toLex.toEmbedding
  finsetIoo a b :=
    (sumLexLift Ioo Ioo (fun a _ => Ioi a) (fun _ => Iio) (ofLex a) (ofLex b)).map toLex.toEmbedding
  finset_mem_Icc := by
    run_tac
      simp_lex
  finset_mem_Ico := by
    run_tac
      simp_lex
  finset_mem_Ioc := by
    run_tac
      simp_lex
  finset_mem_Ioo := by
    run_tac
      simp_lex
#align sum.lex.locally_finite_order Sum.Lex.locallyFiniteOrder
-/

variable (a a₁ a₂ : α) (b b₁ b₂ : β)

#print Sum.Lex.Icc_inl_inl /-
theorem Icc_inl_inl :
    Icc (inlₗ a₁ : α ⊕ₗ β) (inlₗ a₂) = (Icc a₁ a₂).map (Embedding.inl.trans toLex.toEmbedding) := by
  rw [← Finset.map_map]; rfl
#align sum.lex.Icc_inl_inl Sum.Lex.Icc_inl_inl
-/

#print Sum.Lex.Ico_inl_inl /-
theorem Ico_inl_inl :
    Ico (inlₗ a₁ : α ⊕ₗ β) (inlₗ a₂) = (Ico a₁ a₂).map (Embedding.inl.trans toLex.toEmbedding) := by
  rw [← Finset.map_map]; rfl
#align sum.lex.Ico_inl_inl Sum.Lex.Ico_inl_inl
-/

#print Sum.Lex.Ioc_inl_inl /-
theorem Ioc_inl_inl :
    Ioc (inlₗ a₁ : α ⊕ₗ β) (inlₗ a₂) = (Ioc a₁ a₂).map (Embedding.inl.trans toLex.toEmbedding) := by
  rw [← Finset.map_map]; rfl
#align sum.lex.Ioc_inl_inl Sum.Lex.Ioc_inl_inl
-/

#print Sum.Lex.Ioo_inl_inl /-
theorem Ioo_inl_inl :
    Ioo (inlₗ a₁ : α ⊕ₗ β) (inlₗ a₂) = (Ioo a₁ a₂).map (Embedding.inl.trans toLex.toEmbedding) := by
  rw [← Finset.map_map]; rfl
#align sum.lex.Ioo_inl_inl Sum.Lex.Ioo_inl_inl
-/

#print Sum.Lex.Icc_inl_inr /-
@[simp]
theorem Icc_inl_inr : Icc (inlₗ a) (inrₗ b) = ((Ici a).disjSum (Iic b)).map toLex.toEmbedding :=
  rfl
#align sum.lex.Icc_inl_inr Sum.Lex.Icc_inl_inr
-/

#print Sum.Lex.Ico_inl_inr /-
@[simp]
theorem Ico_inl_inr : Ico (inlₗ a) (inrₗ b) = ((Ici a).disjSum (Iio b)).map toLex.toEmbedding :=
  rfl
#align sum.lex.Ico_inl_inr Sum.Lex.Ico_inl_inr
-/

#print Sum.Lex.Ioc_inl_inr /-
@[simp]
theorem Ioc_inl_inr : Ioc (inlₗ a) (inrₗ b) = ((Ioi a).disjSum (Iic b)).map toLex.toEmbedding :=
  rfl
#align sum.lex.Ioc_inl_inr Sum.Lex.Ioc_inl_inr
-/

#print Sum.Lex.Ioo_inl_inr /-
@[simp]
theorem Ioo_inl_inr : Ioo (inlₗ a) (inrₗ b) = ((Ioi a).disjSum (Iio b)).map toLex.toEmbedding :=
  rfl
#align sum.lex.Ioo_inl_inr Sum.Lex.Ioo_inl_inr
-/

#print Sum.Lex.Icc_inr_inl /-
@[simp]
theorem Icc_inr_inl : Icc (inrₗ b) (inlₗ a) = ∅ :=
  rfl
#align sum.lex.Icc_inr_inl Sum.Lex.Icc_inr_inl
-/

#print Sum.Lex.Ico_inr_inl /-
@[simp]
theorem Ico_inr_inl : Ico (inrₗ b) (inlₗ a) = ∅ :=
  rfl
#align sum.lex.Ico_inr_inl Sum.Lex.Ico_inr_inl
-/

#print Sum.Lex.Ioc_inr_inl /-
@[simp]
theorem Ioc_inr_inl : Ioc (inrₗ b) (inlₗ a) = ∅ :=
  rfl
#align sum.lex.Ioc_inr_inl Sum.Lex.Ioc_inr_inl
-/

#print Sum.Lex.Ioo_inr_inl /-
@[simp]
theorem Ioo_inr_inl : Ioo (inrₗ b) (inlₗ a) = ∅ :=
  rfl
#align sum.lex.Ioo_inr_inl Sum.Lex.Ioo_inr_inl
-/

#print Sum.Lex.Icc_inr_inr /-
theorem Icc_inr_inr :
    Icc (inrₗ b₁ : α ⊕ₗ β) (inrₗ b₂) = (Icc b₁ b₂).map (Embedding.inr.trans toLex.toEmbedding) := by
  rw [← Finset.map_map]; rfl
#align sum.lex.Icc_inr_inr Sum.Lex.Icc_inr_inr
-/

#print Sum.Lex.Ico_inr_inr /-
theorem Ico_inr_inr :
    Ico (inrₗ b₁ : α ⊕ₗ β) (inrₗ b₂) = (Ico b₁ b₂).map (Embedding.inr.trans toLex.toEmbedding) := by
  rw [← Finset.map_map]; rfl
#align sum.lex.Ico_inr_inr Sum.Lex.Ico_inr_inr
-/

#print Sum.Lex.Ioc_inr_inr /-
theorem Ioc_inr_inr :
    Ioc (inrₗ b₁ : α ⊕ₗ β) (inrₗ b₂) = (Ioc b₁ b₂).map (Embedding.inr.trans toLex.toEmbedding) := by
  rw [← Finset.map_map]; rfl
#align sum.lex.Ioc_inr_inr Sum.Lex.Ioc_inr_inr
-/

#print Sum.Lex.Ioo_inr_inr /-
theorem Ioo_inr_inr :
    Ioo (inrₗ b₁ : α ⊕ₗ β) (inrₗ b₂) = (Ioo b₁ b₂).map (Embedding.inr.trans toLex.toEmbedding) := by
  rw [← Finset.map_map]; rfl
#align sum.lex.Ioo_inr_inr Sum.Lex.Ioo_inr_inr
-/

end Lex

end Sum

