/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison, Minchao Wu
-/
import Mathbin.Data.Equiv.Basic
import Mathbin.Data.Prod
import Mathbin.Tactic.Basic

/-!
# Lexicographic order

This file defines the lexicographic relation for pairs and dependent pairs of orders, partial orders
and linear orders.

## Main declarations

* `lex α`: A type synonym of `α` to equip it with its lexicographic order.
* `prod.lex.<pre/partial_/linear_>order`: Instances lifting the orders on `α` and `β` to `α ×ₗ β`.

## Notation

* `α ×ₗ β`: `α × β` equipped with the lexicographic order

## See also

Related files are:
* `data.finset.colex`: Colexicographic order on finite sets.
* `data.list.lex`: Lexicographic order on lists.
* `data.psigma.order`: Lexicographic order on `Σ' i, α i`.
* `data.sigma.order`: Lexicographic order on `Σ i, α i`.
-/


universe u v

/-- A type synonym to equip a type with its lexicographic order. -/
def Lex (α : Type u) :=
  α

variable {α : Type u} {β : Type v} {γ : Type _}

/-- `to_lex` is the identity function to the `lex` of a type.  -/
@[matchPattern]
def toLex : α ≃ Lex α :=
  ⟨id, id, fun h => rfl, fun h => rfl⟩

/-- `of_lex` is the identity function from the `lex` of a type.  -/
@[matchPattern]
def ofLex : Lex α ≃ α :=
  toLex.symm

@[simp]
theorem to_lex_symm_eq : (@toLex α).symm = ofLex :=
  rfl

@[simp]
theorem of_lex_symm_eq : (@ofLex α).symm = toLex :=
  rfl

@[simp]
theorem to_lex_of_lex (a : Lex α) : toLex (ofLex a) = a :=
  rfl

@[simp]
theorem of_lex_to_lex (a : α) : ofLex (toLex a) = a :=
  rfl

@[simp]
theorem to_lex_inj {a b : α} : toLex a = toLex b ↔ a = b :=
  Iff.rfl

@[simp]
theorem of_lex_inj {a b : Lex α} : ofLex a = ofLex b ↔ a = b :=
  Iff.rfl

/-- A recursor for `lex`. Use as `induction x using lex.rec`. -/
protected def Lex.rec {β : Lex α → Sort _} (h : ∀ a, β (toLex a)) : ∀ a, β a := fun a => h (ofLex a)

namespace Prod.Lex

notation:35 α " ×ₗ " β:34 => Lex (Prod α β)

unsafe instance [has_to_format α] [has_to_format β] : has_to_format (α ×ₗ β) :=
  prod.has_to_format

instance decidableEq (α β : Type _) [DecidableEq α] [DecidableEq β] : DecidableEq (α ×ₗ β) :=
  Prod.decidableEq

instance inhabited (α β : Type _) [Inhabited α] [Inhabited β] : Inhabited (α ×ₗ β) :=
  Prod.inhabited

/-- Dictionary / lexicographic ordering on pairs.  -/
instance hasLe (α β : Type _) [LT α] [LE β] : LE (α ×ₗ β) where
  le := Prod.Lex (· < ·) (· ≤ ·)

instance hasLt (α β : Type _) [LT α] [LT β] : LT (α ×ₗ β) where
  lt := Prod.Lex (· < ·) (· < ·)

theorem le_iff [LT α] [LE β] (a b : α × β) : toLex a ≤ toLex b ↔ a.1 < b.1 ∨ a.1 = b.1 ∧ a.2 ≤ b.2 :=
  Prod.lex_def (· < ·) (· ≤ ·)

theorem lt_iff [LT α] [LT β] (a b : α × β) : toLex a < toLex b ↔ a.1 < b.1 ∨ a.1 = b.1 ∧ a.2 < b.2 :=
  Prod.lex_def (· < ·) (· < ·)

/-- Dictionary / lexicographic preorder for pairs. -/
instance preorder (α β : Type _) [Preorderₓ α] [Preorderₓ β] : Preorderₓ (α ×ₗ β) :=
  { Prod.Lex.hasLe α β, Prod.Lex.hasLt α β with
    le_refl :=
      have : IsRefl β (· ≤ ·) := ⟨le_reflₓ⟩
      refl_of (Prod.Lex _ _),
    le_trans := fun _ _ _ => by
      have : IsTrans α (· < ·) := ⟨fun _ _ _ => lt_transₓ⟩
      have : IsTrans β (· ≤ ·) := ⟨fun _ _ _ => le_transₓ⟩
      exact trans_of (Prod.Lex _ _),
    lt_iff_le_not_le := fun x₁ x₂ =>
      match x₁, x₂ with
      | toLex (a₁, b₁), toLex (a₂, b₂) => by
        constructor
        · rintro (⟨_, _, _, _, hlt⟩ | ⟨_, _, _, hlt⟩)
          · constructor
            · left
              assumption
              
            · rintro ⟨l, r⟩
              · apply lt_asymmₓ hlt
                assumption
                
              · apply lt_irreflₓ _ hlt
                
              
            
          · constructor
            · right
              rw [lt_iff_le_not_leₓ] at hlt
              exact hlt.1
              
            · rintro ⟨l, r⟩
              · apply lt_irreflₓ a₁
                assumption
                
              · rw [lt_iff_le_not_leₓ] at hlt
                apply hlt.2
                assumption
                
              
            
          
        · rintro ⟨⟨h₁ll, h₁lr⟩, h₂r⟩
          · left
            assumption
            
          · right
            rw [lt_iff_le_not_leₓ]
            constructor
            · assumption
              
            · intro h
              apply h₂r
              right
              exact h
              
            
           }

/-- Dictionary / lexicographic partial_order for pairs. -/
instance partialOrder (α β : Type _) [PartialOrderₓ α] [PartialOrderₓ β] : PartialOrderₓ (α ×ₗ β) :=
  { Prod.Lex.preorder α β with
    le_antisymm := by
      have : IsStrictOrder α (· < ·) := { irrefl := lt_irreflₓ, trans := fun _ _ _ => lt_transₓ }
      have : IsAntisymm β (· ≤ ·) := ⟨fun _ _ => le_antisymmₓ⟩
      exact @antisymm _ (Prod.Lex _ _) _ }

/-- Dictionary / lexicographic linear_order for pairs. -/
instance linearOrder (α β : Type _) [LinearOrderₓ α] [LinearOrderₓ β] : LinearOrderₓ (α ×ₗ β) :=
  { Prod.Lex.partialOrder α β with le_total := total_of (Prod.Lex _ _), decidableLe := Prod.Lex.decidable _ _,
    decidableLt := Prod.Lex.decidable _ _, DecidableEq := Lex.decidableEq _ _ }

end Prod.Lex

