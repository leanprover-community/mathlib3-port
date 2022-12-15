/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module order.succ_pred.interval_succ
! leanprover-community/mathlib commit aba57d4d3dae35460225919dcd82fe91355162f9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Pairwise
import Mathbin.Order.SuccPred.Basic

/-!
# Intervals `Ixx (f x) (f (order.succ x))`

In this file we prove

* `monotone.bUnion_Ico_Ioc_map_succ`: if `α` is a linear archimedean succ order and `β` is a linear
  order, then for any monotone function `f` and `m n : α`, the union of intervals
  `set.Ioc (f i) (f (order.succ i))`, `m ≤ i < n`, is equal to `set.Ioc (f m) (f n)`;

* `monotone.pairwise_disjoint_on_Ioc_succ`: if `α` is a linear succ order, `β` is a preorder, and
  `f : α → β` is a monotone function, then the intervals `set.Ioc (f n) (f (order.succ n))` are
  pairwise disjoint.

For the latter lemma, we also prove various order dual versions.
-/


open Set Order

variable {α β : Type _} [LinearOrder α]

namespace Monotone

/-- If `α` is a linear archimedean succ order and `β` is a linear order, then for any monotone
function `f` and `m n : α`, the union of intervals `set.Ioc (f i) (f (order.succ i))`, `m ≤ i < n`,
is equal to `set.Ioc (f m) (f n)` -/
theorem bUnion_Ico_Ioc_map_succ [SuccOrder α] [IsSuccArchimedean α] [LinearOrder β] {f : α → β}
    (hf : Monotone f) (m n : α) : (⋃ i ∈ ico m n, ioc (f i) (f (succ i))) = ioc (f m) (f n) := by
  cases' le_total n m with hnm hmn
  · rw [Ico_eq_empty_of_le hnm, Ioc_eq_empty_of_le (hf hnm), bUnion_empty]
  · refine' Succ.rec _ _ hmn
    · simp only [Ioc_self, Ico_self, bUnion_empty]
    · intro k hmk ihk
      rw [← Ioc_union_Ioc_eq_Ioc (hf hmk) (hf <| le_succ _), union_comm, ← ihk]
      by_cases hk : IsMax k
      · rw [hk.succ_eq, Ioc_self, empty_union]
      · rw [Ico_succ_right_eq_insert_of_not_is_max hmk hk, bUnion_insert]
#align monotone.bUnion_Ico_Ioc_map_succ Monotone.bUnion_Ico_Ioc_map_succ

/-- If `α` is a linear succ order, `β` is a preorder, and `f : α → β` is a monotone function, then
the intervals `set.Ioc (f n) (f (order.succ n))` are pairwise disjoint. -/
theorem pairwise_disjoint_on_Ioc_succ [SuccOrder α] [Preorder β] {f : α → β} (hf : Monotone f) :
    Pairwise (Disjoint on fun n => ioc (f n) (f (succ n))) :=
  (pairwise_disjoint_on _).2 fun m n hmn =>
    disjoint_iff_inf_le.mpr fun x ⟨⟨_, h₁⟩, ⟨h₂, _⟩⟩ =>
      h₂.not_le <| h₁.trans <| hf <| succ_le_of_lt hmn
#align monotone.pairwise_disjoint_on_Ioc_succ Monotone.pairwise_disjoint_on_Ioc_succ

/-- If `α` is a linear succ order, `β` is a preorder, and `f : α → β` is a monotone function, then
the intervals `set.Ico (f n) (f (order.succ n))` are pairwise disjoint. -/
theorem pairwise_disjoint_on_Ico_succ [SuccOrder α] [Preorder β] {f : α → β} (hf : Monotone f) :
    Pairwise (Disjoint on fun n => ico (f n) (f (succ n))) :=
  (pairwise_disjoint_on _).2 fun m n hmn =>
    disjoint_iff_inf_le.mpr fun x ⟨⟨_, h₁⟩, ⟨h₂, _⟩⟩ =>
      h₁.not_le <| (hf <| succ_le_of_lt hmn).trans h₂
#align monotone.pairwise_disjoint_on_Ico_succ Monotone.pairwise_disjoint_on_Ico_succ

/-- If `α` is a linear succ order, `β` is a preorder, and `f : α → β` is a monotone function, then
the intervals `set.Ioo (f n) (f (order.succ n))` are pairwise disjoint. -/
theorem pairwise_disjoint_on_Ioo_succ [SuccOrder α] [Preorder β] {f : α → β} (hf : Monotone f) :
    Pairwise (Disjoint on fun n => ioo (f n) (f (succ n))) :=
  hf.pairwise_disjoint_on_Ico_succ.mono fun i j h => h.mono Ioo_subset_Ico_self Ioo_subset_Ico_self
#align monotone.pairwise_disjoint_on_Ioo_succ Monotone.pairwise_disjoint_on_Ioo_succ

/-- If `α` is a linear pred order, `β` is a preorder, and `f : α → β` is a monotone function, then
the intervals `set.Ioc (f order.pred n) (f n)` are pairwise disjoint. -/
theorem pairwise_disjoint_on_Ioc_pred [PredOrder α] [Preorder β] {f : α → β} (hf : Monotone f) :
    Pairwise (Disjoint on fun n => ioc (f (pred n)) (f n)) := by
  simpa only [(· ∘ ·), dual_Ico] using hf.dual.pairwise_disjoint_on_Ico_succ
#align monotone.pairwise_disjoint_on_Ioc_pred Monotone.pairwise_disjoint_on_Ioc_pred

/-- If `α` is a linear pred order, `β` is a preorder, and `f : α → β` is a monotone function, then
the intervals `set.Ico (f order.pred n) (f n)` are pairwise disjoint. -/
theorem pairwise_disjoint_on_Ico_pred [PredOrder α] [Preorder β] {f : α → β} (hf : Monotone f) :
    Pairwise (Disjoint on fun n => ico (f (pred n)) (f n)) := by
  simpa only [(· ∘ ·), dual_Ioc] using hf.dual.pairwise_disjoint_on_Ioc_succ
#align monotone.pairwise_disjoint_on_Ico_pred Monotone.pairwise_disjoint_on_Ico_pred

/-- If `α` is a linear pred order, `β` is a preorder, and `f : α → β` is a monotone function, then
the intervals `set.Ioo (f order.pred n) (f n)` are pairwise disjoint. -/
theorem pairwise_disjoint_on_Ioo_pred [PredOrder α] [Preorder β] {f : α → β} (hf : Monotone f) :
    Pairwise (Disjoint on fun n => ioo (f (pred n)) (f n)) := by
  simpa only [(· ∘ ·), dual_Ioo] using hf.dual.pairwise_disjoint_on_Ioo_succ
#align monotone.pairwise_disjoint_on_Ioo_pred Monotone.pairwise_disjoint_on_Ioo_pred

end Monotone

namespace Antitone

/-- If `α` is a linear succ order, `β` is a preorder, and `f : α → β` is an antitone function, then
the intervals `set.Ioc (f (order.succ n)) (f n)` are pairwise disjoint. -/
theorem pairwise_disjoint_on_Ioc_succ [SuccOrder α] [Preorder β] {f : α → β} (hf : Antitone f) :
    Pairwise (Disjoint on fun n => ioc (f (succ n)) (f n)) :=
  hf.dual_left.pairwise_disjoint_on_Ioc_pred
#align antitone.pairwise_disjoint_on_Ioc_succ Antitone.pairwise_disjoint_on_Ioc_succ

/-- If `α` is a linear succ order, `β` is a preorder, and `f : α → β` is an antitone function, then
the intervals `set.Ico (f (order.succ n)) (f n)` are pairwise disjoint. -/
theorem pairwise_disjoint_on_Ico_succ [SuccOrder α] [Preorder β] {f : α → β} (hf : Antitone f) :
    Pairwise (Disjoint on fun n => ico (f (succ n)) (f n)) :=
  hf.dual_left.pairwise_disjoint_on_Ico_pred
#align antitone.pairwise_disjoint_on_Ico_succ Antitone.pairwise_disjoint_on_Ico_succ

/-- If `α` is a linear succ order, `β` is a preorder, and `f : α → β` is an antitone function, then
the intervals `set.Ioo (f (order.succ n)) (f n)` are pairwise disjoint. -/
theorem pairwise_disjoint_on_Ioo_succ [SuccOrder α] [Preorder β] {f : α → β} (hf : Antitone f) :
    Pairwise (Disjoint on fun n => ioo (f (succ n)) (f n)) :=
  hf.dual_left.pairwise_disjoint_on_Ioo_pred
#align antitone.pairwise_disjoint_on_Ioo_succ Antitone.pairwise_disjoint_on_Ioo_succ

/-- If `α` is a linear pred order, `β` is a preorder, and `f : α → β` is an antitone function, then
the intervals `set.Ioc (f n) (f (order.pred n))` are pairwise disjoint. -/
theorem pairwise_disjoint_on_Ioc_pred [PredOrder α] [Preorder β] {f : α → β} (hf : Antitone f) :
    Pairwise (Disjoint on fun n => ioc (f n) (f (pred n))) :=
  hf.dual_left.pairwise_disjoint_on_Ioc_succ
#align antitone.pairwise_disjoint_on_Ioc_pred Antitone.pairwise_disjoint_on_Ioc_pred

/-- If `α` is a linear pred order, `β` is a preorder, and `f : α → β` is an antitone function, then
the intervals `set.Ico (f n) (f (order.pred n))` are pairwise disjoint. -/
theorem pairwise_disjoint_on_Ico_pred [PredOrder α] [Preorder β] {f : α → β} (hf : Antitone f) :
    Pairwise (Disjoint on fun n => ico (f n) (f (pred n))) :=
  hf.dual_left.pairwise_disjoint_on_Ico_succ
#align antitone.pairwise_disjoint_on_Ico_pred Antitone.pairwise_disjoint_on_Ico_pred

/-- If `α` is a linear pred order, `β` is a preorder, and `f : α → β` is an antitone function, then
the intervals `set.Ioo (f n) (f (order.pred n))` are pairwise disjoint. -/
theorem pairwise_disjoint_on_Ioo_pred [PredOrder α] [Preorder β] {f : α → β} (hf : Antitone f) :
    Pairwise (Disjoint on fun n => ioo (f n) (f (pred n))) :=
  hf.dual_left.pairwise_disjoint_on_Ioo_succ
#align antitone.pairwise_disjoint_on_Ioo_pred Antitone.pairwise_disjoint_on_Ioo_pred

end Antitone

