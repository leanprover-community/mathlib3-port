/-
Copyright (c) 2020 Heather Macbeth, Patrick Massot. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Heather Macbeth, Patrick Massot
-/
import Mathbin.Algebra.Order.Archimedean
import Mathbin.GroupTheory.Subgroup.Basic

/-!
# Archimedean groups

This file proves a few facts about ordered groups which satisfy the `archimedean` property, that is:
`class archimedean (α) [ordered_add_comm_monoid α] : Prop :=`
`(arch : ∀ (x : α) {y}, 0 < y → ∃ n : ℕ, x ≤ n • y)`

They are placed here in a separate file (rather than incorporated as a continuation of
`algebra.order.archimedean`) because they rely on some imports from `group_theory` -- bundled
subgroups in particular.

The main result is `add_subgroup.cyclic_of_min`:  a subgroup of a decidable archimedean abelian
group is cyclic, if its set of positive elements has a minimal element.

This result is used in this file to deduce `int.subgroup_cyclic`, proving that every subgroup of `ℤ`
is cyclic.  (There are several other methods one could use to prove this fact, including more purely
algebraic methods, but none seem to exist in mathlib as of writing.  The closest is
`subgroup.is_cyclic`, but that has not been transferred to `add_subgroup`.)

The result is also used in `topology.instances.real` as an ingredient in the classification of
subgroups of `ℝ`.
-/


variable {G : Type _} [LinearOrderedAddCommGroup G] [Archimedean G]

open LinearOrderedAddCommGroup

/-- Given a subgroup `H` of a decidable linearly ordered archimedean abelian group `G`, if there
exists a minimal element `a` of `H ∩ G_{>0}` then `H` is generated by `a`. -/
theorem AddSubgroup.cyclic_of_min {H : AddSubgroup G} {a : G} (ha : IsLeast { g : G | g ∈ H ∧ 0 < g } a) :
    H = AddSubgroup.closure {a} := by
  obtain ⟨⟨a_in, a_pos⟩, a_min⟩ := ha
  refine'
    le_antisymmₓ _
      (H.closure_le.mpr <| by
        simp [a_in])
  intro g g_in
  obtain ⟨k, ⟨nonneg, lt⟩, _⟩ : ∃! k, 0 ≤ g - k • a ∧ g - k • a < a := exists_unique_zsmul_near_of_pos' a_pos g
  have h_zero : g - k • a = 0 := by
    by_contra h
    have h : a ≤ g - k • a := by
      refine' a_min ⟨_, _⟩
      · exact AddSubgroup.sub_mem H g_in (AddSubgroup.zsmul_mem H a_in k)
        
      · exact lt_of_le_of_neₓ nonneg (Ne.symm h)
        
    have h' : ¬a ≤ g - k • a := not_le.mpr lt
    contradiction
  simp [sub_eq_zero.mp h_zero, AddSubgroup.mem_closure_singleton]

/-- Every subgroup of `ℤ` is cyclic. -/
theorem Int.subgroup_cyclic (H : AddSubgroup ℤ) : ∃ a, H = AddSubgroup.closure {a} := by
  cases' AddSubgroup.bot_or_exists_ne_zero H with h h
  · use 0
    rw [h]
    exact add_subgroup.closure_singleton_zero.symm
    
  let s := { g : ℤ | g ∈ H ∧ 0 < g }
  have h_bdd : ∀, ∀ g ∈ s, ∀, (0 : ℤ) ≤ g := fun _ h => le_of_ltₓ h.2
  obtain ⟨g₀, g₀_in, g₀_ne⟩ := h
  obtain ⟨g₁, g₁_in, g₁_pos⟩ : ∃ g₁ : ℤ, g₁ ∈ H ∧ 0 < g₁ := by
    cases' lt_or_gt_of_neₓ g₀_ne with Hg₀ Hg₀
    · exact ⟨-g₀, H.neg_mem g₀_in, neg_pos.mpr Hg₀⟩
      
    · exact ⟨g₀, g₀_in, Hg₀⟩
      
  obtain ⟨a, ha, ha'⟩ := Int.exists_least_of_bdd ⟨(0 : ℤ), h_bdd⟩ ⟨g₁, g₁_in, g₁_pos⟩
  exact ⟨a, AddSubgroup.cyclic_of_min ⟨ha, ha'⟩⟩

