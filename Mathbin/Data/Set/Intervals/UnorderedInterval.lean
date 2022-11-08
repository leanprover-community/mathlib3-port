/-
Copyright (c) 2020 Zhouhang Zhou. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Zhouhang Zhou
-/
import Mathbin.Order.Bounds.Basic
import Mathbin.Data.Set.Intervals.Basic

/-!
# Intervals without endpoints ordering

In any decidable linear order `α`, we define the set of elements lying between two elements `a` and
`b` as `Icc (min a b) (max a b)`.

`Icc a b` requires the assumption `a ≤ b` to be meaningful, which is sometimes inconvenient. The
interval as defined in this file is always the set of things lying between `a` and `b`, regardless
of the relative order of `a` and `b`.

For real numbers, `Icc (min a b) (max a b)` is the same as `segment ℝ a b`.

## Notation

We use the localized notation `[a, b]` for `interval a b`. One can open the locale `interval` to
make the notation available.

-/


universe u

open Function

open OrderDual (toDual ofDual)

namespace Set

section LinearOrder

variable {α : Type u} [LinearOrder α] {a a₁ a₂ b b₁ b₂ c x : α}

/-- `interval a b` is the set of elements lying between `a` and `b`, with `a` and `b` included. -/
def Interval (a b : α) :=
  IccCat (min a b) (max a b)

-- mathport name: set.interval
localized [Interval] notation "[" a ", " b "]" => Set.Interval a b

@[simp]
theorem dual_interval (a b : α) : [toDual a, toDual b] = of_dual ⁻¹' [a, b] :=
  dual_Icc

@[simp]
theorem interval_of_le (h : a ≤ b) : [a, b] = IccCat a b := by rw [interval, min_eq_left h, max_eq_right h]

@[simp]
theorem interval_of_ge (h : b ≤ a) : [a, b] = IccCat b a := by rw [interval, min_eq_right h, max_eq_left h]

theorem interval_swap (a b : α) : [a, b] = [b, a] := by rw [interval, interval, min_comm, max_comm]

theorem interval_of_lt (h : a < b) : [a, b] = IccCat a b :=
  interval_of_le (le_of_lt h)

theorem interval_of_gt (h : b < a) : [a, b] = IccCat b a :=
  interval_of_ge (le_of_lt h)

theorem interval_of_not_le (h : ¬a ≤ b) : [a, b] = IccCat b a :=
  interval_of_gt (lt_of_not_ge h)

theorem interval_of_not_ge (h : ¬b ≤ a) : [a, b] = IccCat a b :=
  interval_of_lt (lt_of_not_ge h)

theorem interval_eq_union : [a, b] = IccCat a b ∪ IccCat b a := by rw [Icc_union_Icc', max_comm] <;> rfl

theorem mem_interval : a ∈ [b, c] ↔ b ≤ a ∧ a ≤ c ∨ c ≤ a ∧ a ≤ b := by simp [interval_eq_union]

@[simp]
theorem interval_self : [a, a] = {a} :=
  Set.ext <| by simp [le_antisymm_iff, and_comm']

@[simp]
theorem nonempty_interval : Set.Nonempty [a, b] := by
  simp only [interval, min_le_iff, le_max_iff, nonempty_Icc]
  left
  left
  rfl

@[simp]
theorem left_mem_interval : a ∈ [a, b] := by simp [mem_interval, le_total]

@[simp]
theorem right_mem_interval : b ∈ [a, b] := by simp [mem_interval, le_total]

theorem Icc_subset_interval : IccCat a b ⊆ [a, b] :=
  Icc_subset_Icc (min_le_left _ _) (le_max_right _ _)

theorem Icc_subset_interval' : IccCat b a ⊆ [a, b] := by
  rw [interval_swap]
  apply Icc_subset_interval

theorem mem_interval_of_le (ha : a ≤ x) (hb : x ≤ b) : x ∈ [a, b] :=
  Icc_subset_interval ⟨ha, hb⟩

theorem mem_interval_of_ge (hb : b ≤ x) (ha : x ≤ a) : x ∈ [a, b] :=
  Icc_subset_interval' ⟨hb, ha⟩

theorem not_mem_interval_of_lt (ha : c < a) (hb : c < b) : c ∉ [a, b] :=
  not_mem_Icc_of_lt <| lt_min_iff.mpr ⟨ha, hb⟩

theorem not_mem_interval_of_gt (ha : a < c) (hb : b < c) : c ∉ [a, b] :=
  not_mem_Icc_of_gt <| max_lt_iff.mpr ⟨ha, hb⟩

theorem interval_subset_interval (h₁ : a₁ ∈ [a₂, b₂]) (h₂ : b₁ ∈ [a₂, b₂]) : [a₁, b₁] ⊆ [a₂, b₂] :=
  Icc_subset_Icc (le_min h₁.1 h₂.1) (max_le h₁.2 h₂.2)

theorem interval_subset_Icc (ha : a₁ ∈ IccCat a₂ b₂) (hb : b₁ ∈ IccCat a₂ b₂) : [a₁, b₁] ⊆ IccCat a₂ b₂ :=
  Icc_subset_Icc (le_min ha.1 hb.1) (max_le ha.2 hb.2)

theorem interval_subset_interval_iff_mem : [a₁, b₁] ⊆ [a₂, b₂] ↔ a₁ ∈ [a₂, b₂] ∧ b₁ ∈ [a₂, b₂] :=
  Iff.intro (fun h => ⟨h left_mem_interval, h right_mem_interval⟩) fun h => interval_subset_interval h.1 h.2

theorem interval_subset_interval_iff_le : [a₁, b₁] ⊆ [a₂, b₂] ↔ min a₂ b₂ ≤ min a₁ b₁ ∧ max a₁ b₁ ≤ max a₂ b₂ := by
  rw [interval, interval, Icc_subset_Icc_iff]
  exact min_le_max

theorem interval_subset_interval_right (h : x ∈ [a, b]) : [x, b] ⊆ [a, b] :=
  interval_subset_interval h right_mem_interval

theorem interval_subset_interval_left (h : x ∈ [a, b]) : [a, x] ⊆ [a, b] :=
  interval_subset_interval left_mem_interval h

/-- A sort of triangle inequality. -/
theorem interval_subset_interval_union_interval : [a, c] ⊆ [a, b] ∪ [b, c] := fun x => by
  simp only [mem_interval, mem_union] <;> cases le_total a c <;> cases le_total x b <;> tauto

theorem eq_of_mem_interval_of_mem_interval : a ∈ [b, c] → b ∈ [a, c] → a = b := by
  simp_rw [mem_interval] <;>
    rintro (⟨_, _⟩ | ⟨_, _⟩) (⟨_, _⟩ | ⟨_, _⟩) <;>
      apply le_antisymm <;>
        first
          |assumption|· exact le_trans ‹_› ‹_›
            

theorem eq_of_mem_interval_of_mem_interval' : b ∈ [a, c] → c ∈ [a, b] → b = c := by
  simpa only [interval_swap a] using eq_of_mem_interval_of_mem_interval

theorem interval_injective_right (a : α) : Injective fun b => Interval b a := fun b c h => by
  rw [ext_iff] at h
  exact eq_of_mem_interval_of_mem_interval ((h _).1 left_mem_interval) ((h _).2 left_mem_interval)

theorem interval_injective_left (a : α) : Injective (Interval a) := by
  simpa only [interval_swap] using interval_injective_right a

theorem bdd_below_bdd_above_iff_subset_interval (s : Set α) : BddBelow s ∧ BddAbove s ↔ ∃ a b, s ⊆ [a, b] := by
  rw [bdd_below_bdd_above_iff_subset_Icc]
  constructor
  · rintro ⟨a, b, h⟩
    exact ⟨a, b, fun x hx => Icc_subset_interval (h hx)⟩
    
  · rintro ⟨a, b, h⟩
    exact ⟨min a b, max a b, h⟩
    

/-- The open-closed interval with unordered bounds. -/
def IntervalOc : α → α → Set α := fun a b => IocCat (min a b) (max a b)

-- mathport name: exprΙ
-- Below is a capital iota
localized [Interval] notation "Ι" => Set.IntervalOc

@[simp]
theorem interval_oc_of_le (h : a ≤ b) : Ι a b = IocCat a b := by simp [interval_oc, h]

@[simp]
theorem interval_oc_of_lt (h : b < a) : Ι a b = IocCat b a := by simp [interval_oc, le_of_lt h]

theorem interval_oc_eq_union : Ι a b = IocCat a b ∪ IocCat b a := by cases le_total a b <;> simp [interval_oc, *]

theorem mem_interval_oc : a ∈ Ι b c ↔ b < a ∧ a ≤ c ∨ c < a ∧ a ≤ b := by
  simp only [interval_oc_eq_union, mem_union, mem_Ioc]

theorem not_mem_interval_oc : a ∉ Ι b c ↔ a ≤ b ∧ a ≤ c ∨ c < a ∧ b < a := by
  simp only [interval_oc_eq_union, mem_union, mem_Ioc, not_lt, ← not_le]
  tauto

@[simp]
theorem left_mem_interval_oc : a ∈ Ι a b ↔ b < a := by simp [mem_interval_oc]

@[simp]
theorem right_mem_interval_oc : b ∈ Ι a b ↔ a < b := by simp [mem_interval_oc]

theorem forall_interval_oc_iff {P : α → Prop} : (∀ x ∈ Ι a b, P x) ↔ (∀ x ∈ IocCat a b, P x) ∧ ∀ x ∈ IocCat b a, P x :=
  by simp only [interval_oc_eq_union, mem_union, or_imp, forall_and]

theorem interval_oc_subset_interval_oc_of_interval_subset_interval {a b c d : α} (h : [a, b] ⊆ [c, d]) :
    Ι a b ⊆ Ι c d :=
  Ioc_subset_Ioc (interval_subset_interval_iff_le.1 h).1 (interval_subset_interval_iff_le.1 h).2

theorem interval_oc_swap (a b : α) : Ι a b = Ι b a := by simp only [interval_oc, min_comm a b, max_comm a b]

theorem Ioc_subset_interval_oc : IocCat a b ⊆ Ι a b :=
  Ioc_subset_Ioc (min_le_left _ _) (le_max_right _ _)

theorem Ioc_subset_interval_oc' : IocCat a b ⊆ Ι b a :=
  Ioc_subset_Ioc (min_le_right _ _) (le_max_left _ _)

theorem eq_of_mem_interval_oc_of_mem_interval_oc : a ∈ Ι b c → b ∈ Ι a c → a = b := by
  simp_rw [mem_interval_oc] <;>
    rintro (⟨_, _⟩ | ⟨_, _⟩) (⟨_, _⟩ | ⟨_, _⟩) <;>
      apply le_antisymm <;> first |assumption|exact le_of_lt ‹_›|exact le_trans ‹_› (le_of_lt ‹_›)

theorem eq_of_mem_interval_oc_of_mem_interval_oc' : b ∈ Ι a c → c ∈ Ι a b → b = c := by
  simpa only [interval_oc_swap a] using eq_of_mem_interval_oc_of_mem_interval_oc

theorem eq_of_not_mem_interval_oc_of_not_mem_interval_oc (ha : a ≤ c) (hb : b ≤ c) : a ∉ Ι b c → b ∉ Ι a c → a = b := by
  simp_rw [not_mem_interval_oc] <;>
    rintro (⟨_, _⟩ | ⟨_, _⟩) (⟨_, _⟩ | ⟨_, _⟩) <;>
      apply le_antisymm <;> first |assumption|exact le_of_lt ‹_›|cases not_le_of_lt ‹_› ‹_›

theorem interval_oc_injective_right (a : α) : Injective fun b => Ι b a := by
  rintro b c h
  rw [ext_iff] at h
  obtain ha | ha := le_or_lt b a
  · have hb := (h b).Not
    simp only [ha, left_mem_interval_oc, not_lt, true_iff_iff, not_mem_interval_oc, ← not_le, and_true_iff, not_true,
      false_and_iff, not_false_iff, true_iff_iff, or_false_iff] at hb
    refine' hb.eq_of_not_lt fun hc => _
    simpa [ha, and_iff_right hc, ← @not_le _ _ _ a, -not_le] using h c
    
  · refine'
      eq_of_mem_interval_oc_of_mem_interval_oc ((h _).1 <| left_mem_interval_oc.2 ha)
        ((h _).2 <| left_mem_interval_oc.2 <| ha.trans_le _)
    simpa [ha, ha.not_le, mem_interval_oc] using h b
    

theorem interval_oc_injective_left (a : α) : Injective (Ι a) := by
  simpa only [interval_oc_swap] using interval_oc_injective_right a

end LinearOrder

end Set

