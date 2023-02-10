/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module measure_theory.measure.ae_disjoint
! leanprover-community/mathlib commit dde670c9a3f503647fd5bfdf1037bad526d3397a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Measure.MeasureSpaceDef

/-!
# Almost everywhere disjoint sets

We say that sets `s` and `t` are `μ`-a.e. disjoint (see `measure_theory.ae_disjoint`) if their
intersection has measure zero. This assumption can be used instead of `disjoint` in most theorems in
measure theory.
-/


open Set Function

namespace MeasureTheory

variable {ι α : Type _} {m : MeasurableSpace α} (μ : Measure α)

/-- Two sets are said to be `μ`-a.e. disjoint if their intersection has measure zero. -/
def AeDisjoint (s t : Set α) :=
  μ (s ∩ t) = 0
#align measure_theory.ae_disjoint MeasureTheory.AeDisjoint

variable {μ} {s t u v : Set α}

/- ./././Mathport/Syntax/Translate/Basic.lean:628:2: warning: expanding binder collection (j «expr ≠ » i) -/
/-- If `s : ι → set α` is a countable family of pairwise a.e. disjoint sets, then there exists a
family of measurable null sets `t i` such that `s i \ t i` are pairwise disjoint. -/
theorem exists_null_pairwise_disjoint_diff [Countable ι] {s : ι → Set α}
    (hd : Pairwise (AeDisjoint μ on s)) :
    ∃ t : ι → Set α,
      (∀ i, MeasurableSet (t i)) ∧ (∀ i, μ (t i) = 0) ∧ Pairwise (Disjoint on fun i => s i \ t i) :=
  by
  refine'
    ⟨fun i => to_measurable μ (s i ∩ ⋃ j ∈ ({i}ᶜ : Set ι), s j), fun i =>
      measurable_set_to_measurable _ _, fun i => _, _⟩
  · simp only [measure_to_measurable, inter_Union]
    exact (measure_bUnion_null_iff <| to_countable _).2 fun j hj => hd (Ne.symm hj)
  · simp only [Pairwise, disjoint_left, on_fun, mem_diff, not_and, and_imp, Classical.not_not]
    intro i j hne x hi hU hj
    replace hU : x ∉ s i ∩ ⋃ (j) (_ : j ≠ i), s j := fun h => hU (subset_to_measurable _ _ h)
    simp only [mem_inter_iff, mem_Union, not_and, not_exists] at hU
    exact (hU hi j hne.symm hj).elim
#align measure_theory.exists_null_pairwise_disjoint_diff MeasureTheory.exists_null_pairwise_disjoint_diff

namespace AeDisjoint

protected theorem eq (h : AeDisjoint μ s t) : μ (s ∩ t) = 0 :=
  h
#align measure_theory.ae_disjoint.eq MeasureTheory.AeDisjoint.eq

@[symm]
protected theorem symm (h : AeDisjoint μ s t) : AeDisjoint μ t s := by rwa [ae_disjoint, inter_comm]
#align measure_theory.ae_disjoint.symm MeasureTheory.AeDisjoint.symm

protected theorem symmetric : Symmetric (AeDisjoint μ) := fun s t h => h.symm
#align measure_theory.ae_disjoint.symmetric MeasureTheory.AeDisjoint.symmetric

protected theorem comm : AeDisjoint μ s t ↔ AeDisjoint μ t s :=
  ⟨fun h => h.symm, fun h => h.symm⟩
#align measure_theory.ae_disjoint.comm MeasureTheory.AeDisjoint.comm

protected theorem Disjoint.aeDisjoint (h : Disjoint s t) : AeDisjoint μ s t := by
  rw [ae_disjoint, disjoint_iff_inter_eq_empty.1 h, measure_empty]
#align disjoint.ae_disjoint Disjoint.aeDisjoint

protected theorem Pairwise.aeDisjoint {f : ι → Set α} (hf : Pairwise (Disjoint on f)) :
    Pairwise (AeDisjoint μ on f) :=
  hf.mono fun i j h => h.AeDisjoint
#align pairwise.ae_disjoint Pairwise.aeDisjoint

protected theorem Set.PairwiseDisjoint.aeDisjoint {f : ι → Set α} {s : Set ι}
    (hf : s.PairwiseDisjoint f) : s.Pairwise (AeDisjoint μ on f) :=
  hf.mono' fun i j h => h.AeDisjoint
#align set.pairwise_disjoint.ae_disjoint Set.PairwiseDisjoint.aeDisjoint

theorem monoAe (h : AeDisjoint μ s t) (hu : u ≤ᵐ[μ] s) (hv : v ≤ᵐ[μ] t) : AeDisjoint μ u v :=
  measure_mono_null_ae (hu.inter hv) h
#align measure_theory.ae_disjoint.mono_ae MeasureTheory.AeDisjoint.monoAe

protected theorem mono (h : AeDisjoint μ s t) (hu : u ⊆ s) (hv : v ⊆ t) : AeDisjoint μ u v :=
  h.monoAe hu.EventuallyLe hv.EventuallyLe
#align measure_theory.ae_disjoint.mono MeasureTheory.AeDisjoint.mono

protected theorem congr (h : AeDisjoint μ s t) (hu : u =ᵐ[μ] s) (hv : v =ᵐ[μ] t) :
    AeDisjoint μ u v :=
  h.monoAe (Filter.EventuallyEq.le hu) (Filter.EventuallyEq.le hv)
#align measure_theory.ae_disjoint.congr MeasureTheory.AeDisjoint.congr

@[simp]
theorem unionᵢ_left_iff [Countable ι] {s : ι → Set α} :
    AeDisjoint μ (⋃ i, s i) t ↔ ∀ i, AeDisjoint μ (s i) t := by
  simp only [ae_disjoint, Union_inter, measure_Union_null_iff]
#align measure_theory.ae_disjoint.Union_left_iff MeasureTheory.AeDisjoint.unionᵢ_left_iff

@[simp]
theorem unionᵢ_right_iff [Countable ι] {t : ι → Set α} :
    AeDisjoint μ s (⋃ i, t i) ↔ ∀ i, AeDisjoint μ s (t i) := by
  simp only [ae_disjoint, inter_Union, measure_Union_null_iff]
#align measure_theory.ae_disjoint.Union_right_iff MeasureTheory.AeDisjoint.unionᵢ_right_iff

@[simp]
theorem union_left_iff : AeDisjoint μ (s ∪ t) u ↔ AeDisjoint μ s u ∧ AeDisjoint μ t u := by
  simp [union_eq_Union, and_comm]
#align measure_theory.ae_disjoint.union_left_iff MeasureTheory.AeDisjoint.union_left_iff

@[simp]
theorem union_right_iff : AeDisjoint μ s (t ∪ u) ↔ AeDisjoint μ s t ∧ AeDisjoint μ s u := by
  simp [union_eq_Union, and_comm]
#align measure_theory.ae_disjoint.union_right_iff MeasureTheory.AeDisjoint.union_right_iff

theorem unionLeft (hs : AeDisjoint μ s u) (ht : AeDisjoint μ t u) : AeDisjoint μ (s ∪ t) u :=
  union_left_iff.mpr ⟨hs, ht⟩
#align measure_theory.ae_disjoint.union_left MeasureTheory.AeDisjoint.unionLeft

theorem unionRight (ht : AeDisjoint μ s t) (hu : AeDisjoint μ s u) : AeDisjoint μ s (t ∪ u) :=
  union_right_iff.2 ⟨ht, hu⟩
#align measure_theory.ae_disjoint.union_right MeasureTheory.AeDisjoint.unionRight

theorem diff_ae_eq_left (h : AeDisjoint μ s t) : (s \ t : Set α) =ᵐ[μ] s :=
  @diff_self_inter _ s t ▸ diff_null_ae_eq_self h
#align measure_theory.ae_disjoint.diff_ae_eq_left MeasureTheory.AeDisjoint.diff_ae_eq_left

theorem diff_ae_eq_right (h : AeDisjoint μ s t) : (t \ s : Set α) =ᵐ[μ] t :=
  h.symm.diff_ae_eq_left
#align measure_theory.ae_disjoint.diff_ae_eq_right MeasureTheory.AeDisjoint.diff_ae_eq_right

theorem measure_diff_left (h : AeDisjoint μ s t) : μ (s \ t) = μ s :=
  measure_congr h.diff_ae_eq_left
#align measure_theory.ae_disjoint.measure_diff_left MeasureTheory.AeDisjoint.measure_diff_left

theorem measure_diff_right (h : AeDisjoint μ s t) : μ (t \ s) = μ t :=
  measure_congr h.diff_ae_eq_right
#align measure_theory.ae_disjoint.measure_diff_right MeasureTheory.AeDisjoint.measure_diff_right

/-- If `s` and `t` are `μ`-a.e. disjoint, then `s \ u` and `t` are disjoint for some measurable null
set `u`. -/
theorem exists_disjoint_diff (h : AeDisjoint μ s t) :
    ∃ u, MeasurableSet u ∧ μ u = 0 ∧ Disjoint (s \ u) t :=
  ⟨toMeasurable μ (s ∩ t), measurableSet_toMeasurable _ _, (measure_toMeasurable _).trans h,
    disjoint_sdiff_self_left.mono_left fun x hx =>
      ⟨hx.1, fun hxt => hx.2 <| subset_toMeasurable _ _ ⟨hx.1, hxt⟩⟩⟩
#align measure_theory.ae_disjoint.exists_disjoint_diff MeasureTheory.AeDisjoint.exists_disjoint_diff

theorem ofNullRight (h : μ t = 0) : AeDisjoint μ s t :=
  measure_mono_null (inter_subset_right _ _) h
#align measure_theory.ae_disjoint.of_null_right MeasureTheory.AeDisjoint.ofNullRight

theorem ofNullLeft (h : μ s = 0) : AeDisjoint μ s t :=
  (ofNullRight h).symm
#align measure_theory.ae_disjoint.of_null_left MeasureTheory.AeDisjoint.ofNullLeft

end AeDisjoint

theorem aeDisjointComplLeft : AeDisjoint μ (sᶜ) s :=
  (@disjoint_compl_left _ _ s).AeDisjoint
#align measure_theory.ae_disjoint_compl_left MeasureTheory.aeDisjointComplLeft

theorem aeDisjointComplRight : AeDisjoint μ s (sᶜ) :=
  (@disjoint_compl_right _ _ s).AeDisjoint
#align measure_theory.ae_disjoint_compl_right MeasureTheory.aeDisjointComplRight

end MeasureTheory

