/-
Copyright (c) 2022 Eric Rodriguez. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Rodriguez, Eric Wieser

! This file was ported from Lean 3 source module data.list.destutter
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.List.Chain

/-!
# Destuttering of Lists

This file proves theorems about `list.destutter` (in `data.list.defs`), which greedily removes all
non-related items that are adjacent in a list, e.g. `[2, 2, 3, 3, 2].destutter (≠) = [2, 3, 2]`.
Note that we make no guarantees of being the longest sublist with this property; e.g.,
`[123, 1, 2, 5, 543, 1000].destutter (<) = [123, 543, 1000]`, but a longer ascending chain could be
`[1, 2, 5, 543, 1000]`.

## Main statements

* `list.destutter_sublist`: `l.destutter` is a sublist of `l`.
* `list.destutter_is_chain'`: `l.destutter` satisfies `chain' R`.
* Analogies of these theorems for `list.destutter'`, which is the `destutter` equivalent of `chain`.

## Tags

adjacent, chain, duplicates, remove, list, stutter, destutter
-/


variable {α : Type _} (l : List α) (R : α → α → Prop) [DecidableRel R] {a b : α}

namespace List

#print List.destutter'_nil /-
@[simp]
theorem destutter'_nil : destutter' R a [] = [a] :=
  rfl
#align list.destutter'_nil List.destutter'_nil
-/

#print List.destutter'_cons /-
theorem destutter'_cons :
    (b :: l).destutter' R a = if R a b then a :: destutter' R b l else destutter' R a l :=
  rfl
#align list.destutter'_cons List.destutter'_cons
-/

variable {R}

#print List.destutter'_cons_pos /-
@[simp]
theorem destutter'_cons_pos (h : R b a) : (a :: l).destutter' R b = b :: l.destutter' R a := by
  rw [destutter', if_pos h]
#align list.destutter'_cons_pos List.destutter'_cons_pos
-/

#print List.destutter'_cons_neg /-
@[simp]
theorem destutter'_cons_neg (h : ¬R b a) : (a :: l).destutter' R b = l.destutter' R b := by
  rw [destutter', if_neg h]
#align list.destutter'_cons_neg List.destutter'_cons_neg
-/

variable (R)

#print List.destutter'_singleton /-
@[simp]
theorem destutter'_singleton : [b].destutter' R a = if R a b then [a, b] else [a] := by
  split_ifs <;> simp! [h]
#align list.destutter'_singleton List.destutter'_singleton
-/

#print List.destutter'_sublist /-
theorem destutter'_sublist (a) : l.destutter' R a <+ a :: l :=
  by
  induction' l with b l hl generalizing a
  · simp
  rw [destutter']
  split_ifs
  · exact sublist.cons2 _ _ _ (hl b)
  · exact (hl a).trans ((l.sublist_cons b).cons_cons a)
#align list.destutter'_sublist List.destutter'_sublist
-/

#print List.mem_destutter' /-
theorem mem_destutter' (a) : a ∈ l.destutter' R a :=
  by
  induction' l with b l hl
  · simp
  rw [destutter']
  split_ifs
  · simp
  · assumption
#align list.mem_destutter' List.mem_destutter'
-/

#print List.destutter'_is_chain /-
theorem destutter'_is_chain : ∀ l : List α, ∀ {a b}, R a b → (l.destutter' R b).Chain R a
  | [], a, b, h => chain_singleton.mpr h
  | c :: l, a, b, h => by
    rw [destutter']
    split_ifs with hbc
    · rw [chain_cons]
      exact ⟨h, destutter'_is_chain l hbc⟩
    · exact destutter'_is_chain l h
#align list.destutter'_is_chain List.destutter'_is_chain
-/

#print List.destutter'_is_chain' /-
theorem destutter'_is_chain' (a) : (l.destutter' R a).Chain' R :=
  by
  induction' l with b l hl generalizing a
  · simp
  rw [destutter']
  split_ifs
  · exact destutter'_is_chain R l h
  · exact hl a
#align list.destutter'_is_chain' List.destutter'_is_chain'
-/

#print List.destutter'_of_chain /-
theorem destutter'_of_chain (h : l.Chain R a) : l.destutter' R a = a :: l :=
  by
  induction' l with b l hb generalizing a
  · simp
  obtain ⟨h, hc⟩ := chain_cons.mp h
  rw [l.destutter'_cons_pos h, hb hc]
#align list.destutter'_of_chain List.destutter'_of_chain
-/

#print List.destutter'_eq_self_iff /-
@[simp]
theorem destutter'_eq_self_iff (a) : l.destutter' R a = a :: l ↔ l.Chain R a :=
  ⟨fun h => by
    rw [← chain', ← h]
    exact l.destutter'_is_chain' R a, destutter'_of_chain _ _⟩
#align list.destutter'_eq_self_iff List.destutter'_eq_self_iff
-/

#print List.destutter'_ne_nil /-
theorem destutter'_ne_nil : l.destutter' R a ≠ [] :=
  ne_nil_of_mem <| l.mem_destutter' R a
#align list.destutter'_ne_nil List.destutter'_ne_nil
-/

#print List.destutter_nil /-
@[simp]
theorem destutter_nil : ([] : List α).destutter R = [] :=
  rfl
#align list.destutter_nil List.destutter_nil
-/

#print List.destutter_cons' /-
theorem destutter_cons' : (a :: l).destutter R = destutter' R a l :=
  rfl
#align list.destutter_cons' List.destutter_cons'
-/

#print List.destutter_cons_cons /-
theorem destutter_cons_cons :
    (a :: b :: l).destutter R = if R a b then a :: destutter' R b l else destutter' R a l :=
  rfl
#align list.destutter_cons_cons List.destutter_cons_cons
-/

#print List.destutter_singleton /-
@[simp]
theorem destutter_singleton : destutter R [a] = [a] :=
  rfl
#align list.destutter_singleton List.destutter_singleton
-/

#print List.destutter_pair /-
@[simp]
theorem destutter_pair : destutter R [a, b] = if R a b then [a, b] else [a] :=
  destutter_cons_cons _ R
#align list.destutter_pair List.destutter_pair
-/

#print List.destutter_sublist /-
theorem destutter_sublist : ∀ l : List α, l.destutter R <+ l
  | [] => Sublist.slnil
  | h :: l => l.destutter'_sublist R h
#align list.destutter_sublist List.destutter_sublist
-/

#print List.destutter_is_chain' /-
theorem destutter_is_chain' : ∀ l : List α, (l.destutter R).Chain' R
  | [] => List.chain'_nil
  | h :: l => l.destutter'_is_chain' R h
#align list.destutter_is_chain' List.destutter_is_chain'
-/

#print List.destutter_of_chain' /-
theorem destutter_of_chain' : ∀ l : List α, l.Chain' R → l.destutter R = l
  | [], h => rfl
  | a :: l, h => l.destutter'_of_chain _ h
#align list.destutter_of_chain' List.destutter_of_chain'
-/

#print List.destutter_eq_self_iff /-
@[simp]
theorem destutter_eq_self_iff : ∀ l : List α, l.destutter R = l ↔ l.Chain' R
  | [] => by simp
  | a :: l => l.destutter'_eq_self_iff R a
#align list.destutter_eq_self_iff List.destutter_eq_self_iff
-/

#print List.destutter_idem /-
theorem destutter_idem : (l.destutter R).destutter R = l.destutter R :=
  destutter_of_chain' R _ <| l.destutter_is_chain' R
#align list.destutter_idem List.destutter_idem
-/

#print List.destutter_eq_nil /-
@[simp]
theorem destutter_eq_nil : ∀ {l : List α}, destutter R l = [] ↔ l = []
  | [] => Iff.rfl
  | a :: l => ⟨fun h => absurd h <| l.destutter'_ne_nil R, fun h => nomatch h⟩
#align list.destutter_eq_nil List.destutter_eq_nil
-/

end List

