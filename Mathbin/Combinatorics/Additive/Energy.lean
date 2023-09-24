/-
Copyright (c) 2022 Yaël Dillies, Ella Yu. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Ella Yu
-/
import Data.Finset.Prod
import Data.Fintype.Prod

#align_import combinatorics.additive.energy from "leanprover-community/mathlib"@"327c3c0d9232d80e250dc8f65e7835b82b266ea5"

/-!
# Additive energy

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the additive energy of two finsets of a group. This is a central quantity in
additive combinatorics.

## TODO

It's possibly interesting to have
`(s ×ˢ s) ×ˢ t ×ˢ t).filter (λ x : (α × α) × α × α, x.1.1 * x.2.1 = x.1.2 * x.2.2)` (whose `card` is
`multiplicative_energy s t`) as a standalone definition.
-/


section

variable {α : Type _} [PartialOrder α] {x y : α}

end

variable {α : Type _} [DecidableEq α]

namespace Finset

section Mul

variable [Mul α] {s s₁ s₂ t t₁ t₂ : Finset α}

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Finset.multiplicativeEnergy /-
/-- The multiplicative energy of two finsets `s` and `t` in a group is the number of quadruples
`(a₁, a₂, b₁, b₂) ∈ s × s × t × t` such that `a₁ * b₁ = a₂ * b₂`. -/
@[to_additive additive_energy
      "The additive energy of two finsets `s` and `t` in a group is the\nnumber of quadruples `(a₁, a₂, b₁, b₂) ∈ s × s × t × t` such that `a₁ + b₁ = a₂ + b₂`."]
def multiplicativeEnergy (s t : Finset α) : ℕ :=
  (((s ×ˢ s) ×ˢ t ×ˢ t).filterₓ fun x : (α × α) × α × α => x.1.1 * x.2.1 = x.1.2 * x.2.2).card
#align finset.multiplicative_energy Finset.multiplicativeEnergy
#align finset.additive_energy Finset.additiveEnergy
-/

#print Finset.multiplicativeEnergy_mono /-
@[to_additive additive_energy_mono]
theorem multiplicativeEnergy_mono (hs : s₁ ⊆ s₂) (ht : t₁ ⊆ t₂) :
    multiplicativeEnergy s₁ t₁ ≤ multiplicativeEnergy s₂ t₂ :=
  card_le_of_subset <|
    filter_subset_filter _ <|
      product_subset_product (product_subset_product hs hs) <| product_subset_product ht ht
#align finset.multiplicative_energy_mono Finset.multiplicativeEnergy_mono
#align finset.additive_energy_mono Finset.additiveEnergy_mono
-/

#print Finset.multiplicativeEnergy_mono_left /-
@[to_additive additive_energy_mono_left]
theorem multiplicativeEnergy_mono_left (hs : s₁ ⊆ s₂) :
    multiplicativeEnergy s₁ t ≤ multiplicativeEnergy s₂ t :=
  multiplicativeEnergy_mono hs Subset.rfl
#align finset.multiplicative_energy_mono_left Finset.multiplicativeEnergy_mono_left
#align finset.additive_energy_mono_left Finset.additiveEnergy_mono_left
-/

#print Finset.multiplicativeEnergy_mono_right /-
@[to_additive additive_energy_mono_right]
theorem multiplicativeEnergy_mono_right (ht : t₁ ⊆ t₂) :
    multiplicativeEnergy s t₁ ≤ multiplicativeEnergy s t₂ :=
  multiplicativeEnergy_mono Subset.rfl ht
#align finset.multiplicative_energy_mono_right Finset.multiplicativeEnergy_mono_right
#align finset.additive_energy_mono_right Finset.additiveEnergy_mono_right
-/

#print Finset.le_multiplicativeEnergy /-
@[to_additive le_additive_energy]
theorem le_multiplicativeEnergy : s.card * t.card ≤ multiplicativeEnergy s t :=
  by
  rw [← card_product]
  refine'
    card_le_card_of_inj_on (fun x => ((x.1, x.1), x.2, x.2)) (by simp [← and_imp]) fun a _ b _ => _
  simp only [Prod.mk.inj_iff, and_self_iff, and_imp]
  exact Prod.ext
#align finset.le_multiplicative_energy Finset.le_multiplicativeEnergy
#align finset.le_additive_energy Finset.le_additiveEnergy
-/

#print Finset.multiplicativeEnergy_pos /-
@[to_additive additive_energy_pos]
theorem multiplicativeEnergy_pos (hs : s.Nonempty) (ht : t.Nonempty) :
    0 < multiplicativeEnergy s t :=
  (mul_pos hs.card_pos ht.card_pos).trans_le le_multiplicativeEnergy
#align finset.multiplicative_energy_pos Finset.multiplicativeEnergy_pos
#align finset.additive_energy_pos Finset.additiveEnergy_pos
-/

variable (s t)

#print Finset.multiplicativeEnergy_empty_left /-
@[simp, to_additive additive_energy_empty_left]
theorem multiplicativeEnergy_empty_left : multiplicativeEnergy ∅ t = 0 := by
  simp [multiplicative_energy]
#align finset.multiplicative_energy_empty_left Finset.multiplicativeEnergy_empty_left
#align finset.additive_energy_empty_left Finset.additiveEnergy_empty_left
-/

#print Finset.multiplicativeEnergy_empty_right /-
@[simp, to_additive additive_energy_empty_right]
theorem multiplicativeEnergy_empty_right : multiplicativeEnergy s ∅ = 0 := by
  simp [multiplicative_energy]
#align finset.multiplicative_energy_empty_right Finset.multiplicativeEnergy_empty_right
#align finset.additive_energy_empty_right Finset.additiveEnergy_empty_right
-/

variable {s t}

#print Finset.multiplicativeEnergy_pos_iff /-
@[simp, to_additive additive_energy_pos_iff]
theorem multiplicativeEnergy_pos_iff : 0 < multiplicativeEnergy s t ↔ s.Nonempty ∧ t.Nonempty :=
  ⟨fun h =>
    of_not_not fun H => by
      simp_rw [not_and_or, not_nonempty_iff_eq_empty] at H 
      obtain rfl | rfl := H <;> simpa [Nat.not_lt_zero] using h,
    fun h => multiplicativeEnergy_pos h.1 h.2⟩
#align finset.multiplicative_energy_pos_iff Finset.multiplicativeEnergy_pos_iff
#align finset.additive_energy_pos_iff Finset.additiveEnergy_pos_iff
-/

#print Finset.multiplicativeEnergy_eq_zero_iff /-
@[simp, to_additive additive_energy_eq_zero_iff]
theorem multiplicativeEnergy_eq_zero_iff : multiplicativeEnergy s t = 0 ↔ s = ∅ ∨ t = ∅ := by
  simp [← (Nat.zero_le _).not_gt_iff_eq, not_and_or]
#align finset.multiplicative_energy_eq_zero_iff Finset.multiplicativeEnergy_eq_zero_iff
#align finset.additive_energy_eq_zero_iff Finset.additive_energy_eq_zero_iff
-/

end Mul

section CommMonoid

variable [CommMonoid α]

#print Finset.multiplicativeEnergy_comm /-
@[to_additive additive_energy_comm]
theorem multiplicativeEnergy_comm (s t : Finset α) :
    multiplicativeEnergy s t = multiplicativeEnergy t s :=
  by
  rw [multiplicative_energy, ← Finset.card_map (Equiv.prodComm _ _).toEmbedding, map_filter]
  simp [-Finset.card_map, eq_comm, multiplicative_energy, mul_comm, map_eq_image, Function.comp]
#align finset.multiplicative_energy_comm Finset.multiplicativeEnergy_comm
#align finset.additive_energy_comm Finset.additiveEnergy_comm
-/

end CommMonoid

section CommGroup

variable [CommGroup α] [Fintype α] (s t : Finset α)

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Finset.multiplicativeEnergy_univ_left /-
@[simp, to_additive additive_energy_univ_left]
theorem multiplicativeEnergy_univ_left :
    multiplicativeEnergy univ t = Fintype.card α * t.card ^ 2 :=
  by
  simp only [multiplicative_energy, univ_product_univ, Fintype.card, sq, ← card_product]
  set f : α × α × α → (α × α) × α × α := fun x => ((x.1 * x.2.2, x.1 * x.2.1), x.2) with hf
  have : (↑((univ : Finset α) ×ˢ t ×ˢ t) : Set (α × α × α)).InjOn f :=
    by
    rintro ⟨a₁, b₁, c₁⟩ h₁ ⟨a₂, b₂, c₂⟩ h₂ h
    simp_rw [Prod.ext_iff] at h 
    obtain ⟨h, rfl, rfl⟩ := h
    rw [mul_right_cancel h.1]
  rw [← card_image_of_inj_on this]
  congr with a
  simp only [hf, mem_filter, mem_product, mem_univ, true_and_iff, mem_image, exists_prop,
    Prod.exists]
  refine' ⟨fun h => ⟨a.1.1 * a.2.2⁻¹, _, _, h.1, by simp [mul_right_comm, h.2]⟩, _⟩
  rintro ⟨b, c, d, hcd, rfl⟩
  simpa [mul_right_comm]
#align finset.multiplicative_energy_univ_left Finset.multiplicativeEnergy_univ_left
#align finset.additive_energy_univ_left Finset.additiveEnergy_univ_left
-/

#print Finset.multiplicativeEnergy_univ_right /-
@[simp, to_additive additive_energy_univ_right]
theorem multiplicativeEnergy_univ_right :
    multiplicativeEnergy s univ = Fintype.card α * s.card ^ 2 := by
  rw [multiplicative_energy_comm, multiplicative_energy_univ_left]
#align finset.multiplicative_energy_univ_right Finset.multiplicativeEnergy_univ_right
#align finset.additive_energy_univ_right Finset.additiveEnergy_univ_right
-/

end CommGroup

end Finset

