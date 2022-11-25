/-
Copyright (c) 2018 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel
-/
import Mathbin.Order.ConditionallyCompleteLattice.Basic
import Mathbin.Data.Set.Finite

/-!
# Conditionally complete lattices and finite sets.

-/


open Set

variable {α β γ : Type _}

section ConditionallyCompleteLattice

variable [ConditionallyCompleteLattice α] {s t : Set α} {a b : α}

theorem Finset.Nonempty.sup'_eq_cSup_image {s : Finset β} (hs : s.Nonempty) (f : β → α) : s.sup' hs f = sup (f '' s) :=
  eq_of_forall_ge_iff fun a => by simp [cSup_le_iff (s.finite_to_set.image f).BddAbove (hs.to_set.image f)]
#align finset.nonempty.sup'_eq_cSup_image Finset.Nonempty.sup'_eq_cSup_image

theorem Finset.Nonempty.sup'_id_eq_cSup {s : Finset α} (hs : s.Nonempty) : s.sup' hs id = sup s := by
  rw [hs.sup'_eq_cSup_image, image_id]
#align finset.nonempty.sup'_id_eq_cSup Finset.Nonempty.sup'_id_eq_cSup

end ConditionallyCompleteLattice

section ConditionallyCompleteLinearOrder

variable [ConditionallyCompleteLinearOrder α] {s t : Set α} {a b : α}

theorem Finset.Nonempty.cSup_eq_max' {s : Finset α} (h : s.Nonempty) : sup ↑s = s.max' h :=
  eq_of_forall_ge_iff fun a => (cSup_le_iff s.BddAbove h.to_set).trans (s.max'_le_iff h).symm
#align finset.nonempty.cSup_eq_max' Finset.Nonempty.cSup_eq_max'

theorem Finset.Nonempty.cInf_eq_min' {s : Finset α} (h : s.Nonempty) : inf ↑s = s.min' h :=
  @Finset.Nonempty.cSup_eq_max' αᵒᵈ _ s h
#align finset.nonempty.cInf_eq_min' Finset.Nonempty.cInf_eq_min'

theorem Finset.Nonempty.cSup_mem {s : Finset α} (h : s.Nonempty) : sup (s : Set α) ∈ s := by
  rw [h.cSup_eq_max']
  exact s.max'_mem _
#align finset.nonempty.cSup_mem Finset.Nonempty.cSup_mem

theorem Finset.Nonempty.cInf_mem {s : Finset α} (h : s.Nonempty) : inf (s : Set α) ∈ s :=
  @Finset.Nonempty.cSup_mem αᵒᵈ _ _ h
#align finset.nonempty.cInf_mem Finset.Nonempty.cInf_mem

theorem Set.Nonempty.cSup_mem (h : s.Nonempty) (hs : s.Finite) : sup s ∈ s := by
  lift s to Finset α using hs
  exact Finset.Nonempty.cSup_mem h
#align set.nonempty.cSup_mem Set.Nonempty.cSup_mem

theorem Set.Nonempty.cInf_mem (h : s.Nonempty) (hs : s.Finite) : inf s ∈ s :=
  @Set.Nonempty.cSup_mem αᵒᵈ _ _ h hs
#align set.nonempty.cInf_mem Set.Nonempty.cInf_mem

theorem Set.Finite.cSup_lt_iff (hs : s.Finite) (h : s.Nonempty) : sup s < a ↔ ∀ x ∈ s, x < a :=
  ⟨fun h x hx => (le_cSup hs.BddAbove hx).trans_lt h, fun H => H _ <| h.cSup_mem hs⟩
#align set.finite.cSup_lt_iff Set.Finite.cSup_lt_iff

theorem Set.Finite.lt_cInf_iff (hs : s.Finite) (h : s.Nonempty) : a < inf s ↔ ∀ x ∈ s, a < x :=
  @Set.Finite.cSup_lt_iff αᵒᵈ _ _ _ hs h
#align set.finite.lt_cInf_iff Set.Finite.lt_cInf_iff

end ConditionallyCompleteLinearOrder

/-!
### Relation between `Sup` / `Inf` and `finset.sup'` / `finset.inf'`

Like the `Sup` of a `conditionally_complete_lattice`, `finset.sup'` also requires the set to be
non-empty. As a result, we can translate between the two.
-/


namespace Finset

theorem sup'_eq_cSup_image [ConditionallyCompleteLattice β] (s : Finset α) (H) (f : α → β) :
    s.sup' H f = sup (f '' s) := by
  apply le_antisymm
  · refine' (Finset.sup'_le _ _) fun a ha => _
    refine' le_cSup ⟨s.sup' H f, _⟩ ⟨a, ha, rfl⟩
    rintro i ⟨j, hj, rfl⟩
    exact Finset.le_sup' _ hj
    
  · apply cSup_le ((coe_nonempty.mpr H).image _)
    rintro _ ⟨a, ha, rfl⟩
    exact Finset.le_sup' _ ha
    
#align finset.sup'_eq_cSup_image Finset.sup'_eq_cSup_image

theorem inf'_eq_cInf_image [ConditionallyCompleteLattice β] (s : Finset α) (H) (f : α → β) :
    s.inf' H f = inf (f '' s) :=
  @sup'_eq_cSup_image _ βᵒᵈ _ _ H _
#align finset.inf'_eq_cInf_image Finset.inf'_eq_cInf_image

theorem sup'_id_eq_cSup [ConditionallyCompleteLattice α] (s : Finset α) (H) : s.sup' H id = sup s := by
  rw [sup'_eq_cSup_image s H, Set.image_id]
#align finset.sup'_id_eq_cSup Finset.sup'_id_eq_cSup

theorem inf'_id_eq_cInf [ConditionallyCompleteLattice α] (s : Finset α) (H) : s.inf' H id = inf s :=
  @sup'_id_eq_cSup αᵒᵈ _ _ H
#align finset.inf'_id_eq_cInf Finset.inf'_id_eq_cInf

end Finset

