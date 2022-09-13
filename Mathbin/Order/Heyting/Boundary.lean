/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies
-/
import Mathbin.Order.BooleanAlgebra

/-!
# Co-Heyting boundary

The boundary of an element of a co-Heyting algebra is the intersection of its Heyting negation with
itself. The boundary in the co-Heyting algebra of closed sets coincides with the topological
boundary.

## Main declarations

* `coheyting.boundary`: Co-Heyting boundary. `coheyting.boundary a = a ⊓ ￢a`

## Notation

`∂ a` is notation for `coheyting.boundary a` in locale `heyting`.
-/


variable {α : Type _}

namespace Coheyting

variable [CoheytingAlgebra α] {a b : α}

/-- The boundary of an element of a co-Heyting algebra is the intersection of its Heyting negation
with itself. Note that this is always `⊥` for a boolean algebra. -/
def boundary (a : α) : α :=
  a ⊓ ￢a

-- mathport name: «expr∂ »
localized [Heyting] prefix:120 "∂ " => Coheyting.boundary

theorem inf_hnot_self (a : α) : a ⊓ ￢a = ∂ a :=
  rfl

theorem boundary_le : ∂ a ≤ a :=
  inf_le_left

theorem boundary_le_hnot : ∂ a ≤ ￢a :=
  inf_le_right

@[simp]
theorem boundary_bot : ∂ (⊥ : α) = ⊥ :=
  bot_inf_eq

@[simp]
theorem boundary_top : ∂ (⊤ : α) = ⊥ := by
  rw [boundary, hnot_top, inf_bot_eq]

theorem boundary_hnot_le (a : α) : ∂ (￢a) ≤ ∂ a :=
  inf_comm.trans_le <| inf_le_inf_right _ hnot_hnot_le

@[simp]
theorem boundary_hnot_hnot (a : α) : ∂ (￢￢a) = ∂ (￢a) := by
  simp_rw [boundary, hnot_hnot_hnot, inf_comm]

@[simp]
theorem hnot_boundary (a : α) : ￢∂ a = ⊤ := by
  rw [boundary, hnot_inf_distrib, sup_hnot_self]

/-- **Leibniz rule** for the co-Heyting boundary. -/
theorem boundary_inf (a b : α) : ∂ (a ⊓ b) = ∂ a ⊓ b ⊔ a ⊓ ∂ b := by
  unfold boundary
  rw [hnot_inf_distrib, inf_sup_left, inf_right_comm, ← inf_assoc]

theorem boundary_inf_le : ∂ (a ⊓ b) ≤ ∂ a ⊔ ∂ b :=
  (boundary_inf _ _).trans_le <| sup_le_sup inf_le_left inf_le_right

theorem boundary_sup_le : ∂ (a ⊔ b) ≤ ∂ a ⊔ ∂ b := by
  rw [boundary, inf_sup_right]
  exact sup_le_sup (inf_le_inf_left _ <| hnot_anti le_sup_left) (inf_le_inf_left _ <| hnot_anti le_sup_right)

/- The intuitionistic version of `coheyting.boundary_le_boundary_sup_sup_boundary_inf_left`. Either
proof can be obtained from the other using the equivalence of Heyting algebras and intuitionistic
logic and duality between Heyting and co-Heyting algebras. It is crucial that the following proof be
intuitionistic. -/
example (a b : Prop) : (a ∧ b ∨ ¬(a ∧ b)) ∧ ((a ∨ b) ∨ ¬(a ∨ b)) → a ∨ ¬a := by
  rintro ⟨⟨ha, hb⟩ | hnab, (ha | hb) | hnab⟩ <;>
    try
      exact Or.inl ha
  · exact Or.inr fun ha => hnab ⟨ha, hb⟩
    
  · exact Or.inr fun ha => hnab <| Or.inl ha
    

theorem boundary_le_boundary_sup_sup_boundary_inf_left : ∂ a ≤ ∂ (a ⊔ b) ⊔ ∂ (a ⊓ b) := by
  simp only [boundary, sup_inf_left, sup_inf_right, sup_right_idem, le_inf_iff, sup_assoc, @sup_comm _ _ _ a]
  refine' ⟨⟨⟨_, _⟩, _⟩, ⟨_, _⟩, _⟩ <;>
    try
        exact le_sup_of_le_left inf_le_left <;>
      refine' inf_le_of_right_le _
  · rw [hnot_le_iff_codisjoint_right, codisjoint_left_comm]
    exact codisjoint_hnot_left
    
  · refine' le_sup_of_le_right _
    rw [hnot_le_iff_codisjoint_right]
    exact codisjoint_hnot_right.mono_right (hnot_anti inf_le_left)
    

theorem boundary_le_boundary_sup_sup_boundary_inf_right : ∂ b ≤ ∂ (a ⊔ b) ⊔ ∂ (a ⊓ b) := by
  rw [@sup_comm _ _ a, inf_comm]
  exact boundary_le_boundary_sup_sup_boundary_inf_left

theorem boundary_sup_sup_boundary_inf (a b : α) : ∂ (a ⊔ b) ⊔ ∂ (a ⊓ b) = ∂ a ⊔ ∂ b :=
  le_antisymmₓ (sup_le boundary_sup_le boundary_inf_le) <|
    sup_le boundary_le_boundary_sup_sup_boundary_inf_left boundary_le_boundary_sup_sup_boundary_inf_right

@[simp]
theorem boundary_idem (a : α) : ∂ ∂ a = ∂ a := by
  rw [boundary, hnot_boundary, inf_top_eq]

theorem hnot_hnot_sup_boundary (a : α) : ￢￢a ⊔ ∂ a = a := by
  rw [boundary, sup_inf_left, hnot_sup_self, inf_top_eq, sup_eq_right]
  exact hnot_hnot_le

theorem hnot_eq_top_iff_exists_boundary : ￢a = ⊤ ↔ ∃ b, ∂ b = a :=
  ⟨fun h =>
    ⟨a, by
      rw [boundary, h, inf_top_eq]⟩,
    by
    rintro ⟨b, rfl⟩
    exact hnot_boundary _⟩

end Coheyting

open Heyting

section BooleanAlgebra

variable [BooleanAlgebra α]

@[simp]
theorem Coheyting.boundary_eq_bot (a : α) : ∂ a = ⊥ :=
  inf_compl_eq_bot

end BooleanAlgebra

