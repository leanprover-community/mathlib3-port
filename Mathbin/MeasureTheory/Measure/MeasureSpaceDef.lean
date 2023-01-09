/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro

! This file was ported from Lean 3 source module measure_theory.measure.measure_space_def
! leanprover-community/mathlib commit 40acfb6aa7516ffe6f91136691df012a64683390
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Measure.OuterMeasure
import Mathbin.Order.Filter.CountableInter

/-!
# Measure spaces

This file defines measure spaces, the almost-everywhere filter and ae_measurable functions.
See `measure_theory.measure_space` for their properties and for extended documentation.

Given a measurable space `α`, a measure on `α` is a function that sends measurable sets to the
extended nonnegative reals that satisfies the following conditions:
1. `μ ∅ = 0`;
2. `μ` is countably additive. This means that the measure of a countable union of pairwise disjoint
   sets is equal to the measure of the individual sets.

Every measure can be canonically extended to an outer measure, so that it assigns values to
all subsets, not just the measurable subsets. On the other hand, a measure that is countably
additive on measurable sets can be restricted to measurable sets to obtain a measure.
In this file a measure is defined to be an outer measure that is countably additive on
measurable sets, with the additional assumption that the outer measure is the canonical
extension of the restricted measure.

Measures on `α` form a complete lattice, and are closed under scalar multiplication with `ℝ≥0∞`.

## Implementation notes

Given `μ : measure α`, `μ s` is the value of the *outer measure* applied to `s`.
This conveniently allows us to apply the measure to sets without proving that they are measurable.
We get countable subadditivity for all sets, but only countable additivity for measurable sets.

See the documentation of `measure_theory.measure_space` for ways to construct measures and proving
that two measure are equal.

A `measure_space` is a class that is a measurable space with a canonical measure.
The measure is denoted `volume`.

This file does not import `measure_theory.measurable_space`, but only `measurable_space_def`.

## References

* <https://en.wikipedia.org/wiki/Measure_(mathematics)>
* <https://en.wikipedia.org/wiki/Almost_everywhere>

## Tags

measure, almost everywhere, measure space
-/


noncomputable section

open Classical Set

open Filter hiding map

open Function MeasurableSpace

open Classical TopologicalSpace BigOperators Filter Ennreal Nnreal

variable {α β γ δ ι : Type _}

namespace MeasureTheory

/-- A measure is defined to be an outer measure that is countably additive on
measurable sets, with the additional assumption that the outer measure is the canonical
extension of the restricted measure. -/
structure Measure (α : Type _) [MeasurableSpace α] extends OuterMeasure α where
  m_Union ⦃f : ℕ → Set α⦄ :
    (∀ i, MeasurableSet (f i)) →
      Pairwise (Disjoint on f) → measure_of (⋃ i, f i) = ∑' i, measure_of (f i)
  trimmed : to_outer_measure.trim = to_outer_measure
#align measure_theory.measure MeasureTheory.Measure

/-- Measure projections for a measure space.

For measurable sets this returns the measure assigned by the `measure_of` field in `measure`.
But we can extend this to _all_ sets, but using the outer measure. This gives us monotonicity and
subadditivity for all sets.
-/
instance Measure.hasCoeToFun [MeasurableSpace α] : CoeFun (Measure α) fun _ => Set α → ℝ≥0∞ :=
  ⟨fun m => m.toOuterMeasure⟩
#align measure_theory.measure.has_coe_to_fun MeasureTheory.Measure.hasCoeToFun

section

variable [MeasurableSpace α] {μ μ₁ μ₂ : Measure α} {s s₁ s₂ t : Set α}

namespace Measure

/-! ### General facts about measures -/


/-- Obtain a measure by giving a countably additive function that sends `∅` to `0`. -/
def ofMeasurable (m : ∀ s : Set α, MeasurableSet s → ℝ≥0∞) (m0 : m ∅ MeasurableSet.empty = 0)
    (mU :
      ∀ ⦃f : ℕ → Set α⦄ (h : ∀ i, MeasurableSet (f i)),
        Pairwise (Disjoint on f) → m (⋃ i, f i) (MeasurableSet.Union h) = ∑' i, m (f i) (h i)) :
    Measure α :=
  {
    inducedOuterMeasure m _
      m0 with
    m_Union := fun f hf hd =>
      show inducedOuterMeasure m _ m0 (unionᵢ f) = ∑' i, inducedOuterMeasure m _ m0 (f i)
        by
        rw [induced_outer_measure_eq m0 mU, mU hf hd]
        congr ; funext n; rw [induced_outer_measure_eq m0 mU]
    trimmed :=
      show (inducedOuterMeasure m _ m0).trim = inducedOuterMeasure m _ m0
        by
        unfold outer_measure.trim
        congr ; funext s hs
        exact induced_outer_measure_eq m0 mU hs }
#align measure_theory.measure.of_measurable MeasureTheory.Measure.ofMeasurable

theorem of_measurable_apply {m : ∀ s : Set α, MeasurableSet s → ℝ≥0∞}
    {m0 : m ∅ MeasurableSet.empty = 0}
    {mU :
      ∀ ⦃f : ℕ → Set α⦄ (h : ∀ i, MeasurableSet (f i)),
        Pairwise (Disjoint on f) → m (⋃ i, f i) (MeasurableSet.Union h) = ∑' i, m (f i) (h i)}
    (s : Set α) (hs : MeasurableSet s) : ofMeasurable m m0 mU s = m s hs :=
  induced_outer_measure_eq m0 mU hs
#align measure_theory.measure.of_measurable_apply MeasureTheory.Measure.of_measurable_apply

theorem to_outer_measure_injective : Injective (toOuterMeasure : Measure α → OuterMeasure α) :=
  fun ⟨m₁, u₁, h₁⟩ ⟨m₂, u₂, h₂⟩ h => by
  congr
  exact h
#align
  measure_theory.measure.to_outer_measure_injective MeasureTheory.Measure.to_outer_measure_injective

@[ext]
theorem ext (h : ∀ s, MeasurableSet s → μ₁ s = μ₂ s) : μ₁ = μ₂ :=
  to_outer_measure_injective <| by rw [← trimmed, outer_measure.trim_congr h, trimmed]
#align measure_theory.measure.ext MeasureTheory.Measure.ext

theorem ext_iff : μ₁ = μ₂ ↔ ∀ s, MeasurableSet s → μ₁ s = μ₂ s :=
  ⟨by
    rintro rfl s hs
    rfl, Measure.ext⟩
#align measure_theory.measure.ext_iff MeasureTheory.Measure.ext_iff

end Measure

@[simp]
theorem coe_to_outer_measure : ⇑μ.toOuterMeasure = μ :=
  rfl
#align measure_theory.coe_to_outer_measure MeasureTheory.coe_to_outer_measure

theorem to_outer_measure_apply (s : Set α) : μ.toOuterMeasure s = μ s :=
  rfl
#align measure_theory.to_outer_measure_apply MeasureTheory.to_outer_measure_apply

theorem measure_eq_trim (s : Set α) : μ s = μ.toOuterMeasure.trim s := by rw [μ.trimmed] <;> rfl
#align measure_theory.measure_eq_trim MeasureTheory.measure_eq_trim

theorem measure_eq_infi (s : Set α) : μ s = ⨅ (t) (st : s ⊆ t) (ht : MeasurableSet t), μ t := by
  rw [measure_eq_trim, outer_measure.trim_eq_infi] <;> rfl
#align measure_theory.measure_eq_infi MeasureTheory.measure_eq_infi

/-- A variant of `measure_eq_infi` which has a single `infi`. This is useful when applying a
  lemma next that only works for non-empty infima, in which case you can use
  `nonempty_measurable_superset`. -/
theorem measure_eq_infi' (μ : Measure α) (s : Set α) :
    μ s = ⨅ t : { t // s ⊆ t ∧ MeasurableSet t }, μ t := by
  simp_rw [infᵢ_subtype, infᵢ_and, Subtype.coe_mk, ← measure_eq_infi]
#align measure_theory.measure_eq_infi' MeasureTheory.measure_eq_infi'

theorem measure_eq_induced_outer_measure :
    μ s = inducedOuterMeasure (fun s _ => μ s) MeasurableSet.empty μ.Empty s :=
  measure_eq_trim _
#align
  measure_theory.measure_eq_induced_outer_measure MeasureTheory.measure_eq_induced_outer_measure

theorem to_outer_measure_eq_induced_outer_measure :
    μ.toOuterMeasure = inducedOuterMeasure (fun s _ => μ s) MeasurableSet.empty μ.Empty :=
  μ.trimmed.symm
#align
  measure_theory.to_outer_measure_eq_induced_outer_measure MeasureTheory.to_outer_measure_eq_induced_outer_measure

theorem measure_eq_extend (hs : MeasurableSet s) :
    μ s = extend (fun t (ht : MeasurableSet t) => μ t) s :=
  (extend_eq _ hs).symm
#align measure_theory.measure_eq_extend MeasureTheory.measure_eq_extend

@[simp]
theorem measure_empty : μ ∅ = 0 :=
  μ.Empty
#align measure_theory.measure_empty MeasureTheory.measure_empty

theorem nonempty_of_measure_ne_zero (h : μ s ≠ 0) : s.Nonempty :=
  nonempty_iff_ne_empty.2 fun h' => h <| h'.symm ▸ measure_empty
#align measure_theory.nonempty_of_measure_ne_zero MeasureTheory.nonempty_of_measure_ne_zero

theorem measure_mono (h : s₁ ⊆ s₂) : μ s₁ ≤ μ s₂ :=
  μ.mono h
#align measure_theory.measure_mono MeasureTheory.measure_mono

theorem measure_mono_null (h : s₁ ⊆ s₂) (h₂ : μ s₂ = 0) : μ s₁ = 0 :=
  nonpos_iff_eq_zero.1 <| h₂ ▸ measure_mono h
#align measure_theory.measure_mono_null MeasureTheory.measure_mono_null

theorem measure_mono_top (h : s₁ ⊆ s₂) (h₁ : μ s₁ = ∞) : μ s₂ = ∞ :=
  top_unique <| h₁ ▸ measure_mono h
#align measure_theory.measure_mono_top MeasureTheory.measure_mono_top

/-- For every set there exists a measurable superset of the same measure. -/
theorem exists_measurable_superset (μ : Measure α) (s : Set α) :
    ∃ t, s ⊆ t ∧ MeasurableSet t ∧ μ t = μ s := by
  simpa only [← measure_eq_trim] using μ.to_outer_measure.exists_measurable_superset_eq_trim s
#align measure_theory.exists_measurable_superset MeasureTheory.exists_measurable_superset

/-- For every set `s` and a countable collection of measures `μ i` there exists a measurable
superset `t ⊇ s` such that each measure `μ i` takes the same value on `s` and `t`. -/
theorem exists_measurable_superset_forall_eq {ι} [Countable ι] (μ : ι → Measure α) (s : Set α) :
    ∃ t, s ⊆ t ∧ MeasurableSet t ∧ ∀ i, μ i t = μ i s := by
  simpa only [← measure_eq_trim] using
    outer_measure.exists_measurable_superset_forall_eq_trim (fun i => (μ i).toOuterMeasure) s
#align
  measure_theory.exists_measurable_superset_forall_eq MeasureTheory.exists_measurable_superset_forall_eq

theorem exists_measurable_superset₂ (μ ν : Measure α) (s : Set α) :
    ∃ t, s ⊆ t ∧ MeasurableSet t ∧ μ t = μ s ∧ ν t = ν s := by
  simpa only [bool.forall_bool.trans and_comm] using
    exists_measurable_superset_forall_eq (fun b => cond b μ ν) s
#align measure_theory.exists_measurable_superset₂ MeasureTheory.exists_measurable_superset₂

theorem exists_measurable_superset_of_null (h : μ s = 0) : ∃ t, s ⊆ t ∧ MeasurableSet t ∧ μ t = 0 :=
  h ▸ exists_measurable_superset μ s
#align
  measure_theory.exists_measurable_superset_of_null MeasureTheory.exists_measurable_superset_of_null

theorem exists_measurable_superset_iff_measure_eq_zero :
    (∃ t, s ⊆ t ∧ MeasurableSet t ∧ μ t = 0) ↔ μ s = 0 :=
  ⟨fun ⟨t, hst, _, ht⟩ => measure_mono_null hst ht, exists_measurable_superset_of_null⟩
#align
  measure_theory.exists_measurable_superset_iff_measure_eq_zero MeasureTheory.exists_measurable_superset_iff_measure_eq_zero

theorem measure_Union_le [Countable β] (s : β → Set α) : μ (⋃ i, s i) ≤ ∑' i, μ (s i) :=
  μ.toOuterMeasure.union _
#align measure_theory.measure_Union_le MeasureTheory.measure_Union_le

theorem measure_bUnion_le {s : Set β} (hs : s.Countable) (f : β → Set α) :
    μ (⋃ b ∈ s, f b) ≤ ∑' p : s, μ (f p) :=
  by
  haveI := hs.to_subtype
  rw [bUnion_eq_Union]
  apply measure_Union_le
#align measure_theory.measure_bUnion_le MeasureTheory.measure_bUnion_le

theorem measure_bUnion_finset_le (s : Finset β) (f : β → Set α) :
    μ (⋃ b ∈ s, f b) ≤ ∑ p in s, μ (f p) :=
  by
  rw [← Finset.sum_attach, Finset.attach_eq_univ, ← tsum_fintype]
  exact measure_bUnion_le s.countable_to_set f
#align measure_theory.measure_bUnion_finset_le MeasureTheory.measure_bUnion_finset_le

theorem measure_Union_fintype_le [Fintype β] (f : β → Set α) : μ (⋃ b, f b) ≤ ∑ p, μ (f p) :=
  by
  convert measure_bUnion_finset_le Finset.univ f
  simp
#align measure_theory.measure_Union_fintype_le MeasureTheory.measure_Union_fintype_le

theorem measure_bUnion_lt_top {s : Set β} {f : β → Set α} (hs : s.Finite)
    (hfin : ∀ i ∈ s, μ (f i) ≠ ∞) : μ (⋃ i ∈ s, f i) < ∞ :=
  by
  convert (measure_bUnion_finset_le hs.to_finset f).trans_lt _
  · ext
    rw [finite.mem_to_finset]
  apply Ennreal.sum_lt_top; simpa only [finite.mem_to_finset]
#align measure_theory.measure_bUnion_lt_top MeasureTheory.measure_bUnion_lt_top

theorem measure_Union_null [Countable β] {s : β → Set α} : (∀ i, μ (s i) = 0) → μ (⋃ i, s i) = 0 :=
  μ.toOuterMeasure.Union_null
#align measure_theory.measure_Union_null MeasureTheory.measure_Union_null

@[simp]
theorem measure_Union_null_iff [Countable ι] {s : ι → Set α} :
    μ (⋃ i, s i) = 0 ↔ ∀ i, μ (s i) = 0 :=
  μ.toOuterMeasure.Union_null_iff
#align measure_theory.measure_Union_null_iff MeasureTheory.measure_Union_null_iff

/-- A version of `measure_Union_null_iff` for unions indexed by Props
TODO: in the long run it would be better to combine this with `measure_Union_null_iff` by
generalising to `Sort`. -/
@[simp]
theorem measure_Union_null_iff' {ι : Prop} {s : ι → Set α} : μ (⋃ i, s i) = 0 ↔ ∀ i, μ (s i) = 0 :=
  μ.toOuterMeasure.Union_null_iff'
#align measure_theory.measure_Union_null_iff' MeasureTheory.measure_Union_null_iff'

theorem measure_bUnion_null_iff {s : Set ι} (hs : s.Countable) {t : ι → Set α} :
    μ (⋃ i ∈ s, t i) = 0 ↔ ∀ i ∈ s, μ (t i) = 0 :=
  μ.toOuterMeasure.bUnion_null_iff hs
#align measure_theory.measure_bUnion_null_iff MeasureTheory.measure_bUnion_null_iff

theorem measure_sUnion_null_iff {S : Set (Set α)} (hS : S.Countable) :
    μ (⋃₀ S) = 0 ↔ ∀ s ∈ S, μ s = 0 :=
  μ.toOuterMeasure.sUnion_null_iff hS
#align measure_theory.measure_sUnion_null_iff MeasureTheory.measure_sUnion_null_iff

theorem measure_union_le (s₁ s₂ : Set α) : μ (s₁ ∪ s₂) ≤ μ s₁ + μ s₂ :=
  μ.toOuterMeasure.union _ _
#align measure_theory.measure_union_le MeasureTheory.measure_union_le

theorem measure_union_null : μ s₁ = 0 → μ s₂ = 0 → μ (s₁ ∪ s₂) = 0 :=
  μ.toOuterMeasure.union_null
#align measure_theory.measure_union_null MeasureTheory.measure_union_null

@[simp]
theorem measure_union_null_iff : μ (s₁ ∪ s₂) = 0 ↔ μ s₁ = 0 ∧ μ s₂ = 0 :=
  ⟨fun h =>
    ⟨measure_mono_null (subset_union_left _ _) h, measure_mono_null (subset_union_right _ _) h⟩,
    fun h => measure_union_null h.1 h.2⟩
#align measure_theory.measure_union_null_iff MeasureTheory.measure_union_null_iff

theorem measure_union_lt_top (hs : μ s < ∞) (ht : μ t < ∞) : μ (s ∪ t) < ∞ :=
  (measure_union_le s t).trans_lt (Ennreal.add_lt_top.mpr ⟨hs, ht⟩)
#align measure_theory.measure_union_lt_top MeasureTheory.measure_union_lt_top

@[simp]
theorem measure_union_lt_top_iff : μ (s ∪ t) < ∞ ↔ μ s < ∞ ∧ μ t < ∞ :=
  by
  refine' ⟨fun h => ⟨_, _⟩, fun h => measure_union_lt_top h.1 h.2⟩
  · exact (measure_mono (Set.subset_union_left s t)).trans_lt h
  · exact (measure_mono (Set.subset_union_right s t)).trans_lt h
#align measure_theory.measure_union_lt_top_iff MeasureTheory.measure_union_lt_top_iff

theorem measure_union_ne_top (hs : μ s ≠ ∞) (ht : μ t ≠ ∞) : μ (s ∪ t) ≠ ∞ :=
  (measure_union_lt_top hs.lt_top ht.lt_top).Ne
#align measure_theory.measure_union_ne_top MeasureTheory.measure_union_ne_top

@[simp]
theorem measure_union_eq_top_iff : μ (s ∪ t) = ∞ ↔ μ s = ∞ ∨ μ t = ∞ :=
  not_iff_not.1 <| by simp only [← lt_top_iff_ne_top, ← Ne.def, not_or, measure_union_lt_top_iff]
#align measure_theory.measure_union_eq_top_iff MeasureTheory.measure_union_eq_top_iff

theorem exists_measure_pos_of_not_measure_Union_null [Countable β] {s : β → Set α}
    (hs : μ (⋃ n, s n) ≠ 0) : ∃ n, 0 < μ (s n) :=
  by
  contrapose! hs
  exact measure_Union_null fun n => nonpos_iff_eq_zero.1 (hs n)
#align
  measure_theory.exists_measure_pos_of_not_measure_Union_null MeasureTheory.exists_measure_pos_of_not_measure_Union_null

theorem measure_inter_lt_top_of_left_ne_top (hs_finite : μ s ≠ ∞) : μ (s ∩ t) < ∞ :=
  (measure_mono (Set.inter_subset_left s t)).trans_lt hs_finite.lt_top
#align
  measure_theory.measure_inter_lt_top_of_left_ne_top MeasureTheory.measure_inter_lt_top_of_left_ne_top

theorem measure_inter_lt_top_of_right_ne_top (ht_finite : μ t ≠ ∞) : μ (s ∩ t) < ∞ :=
  inter_comm t s ▸ measure_inter_lt_top_of_left_ne_top ht_finite
#align
  measure_theory.measure_inter_lt_top_of_right_ne_top MeasureTheory.measure_inter_lt_top_of_right_ne_top

theorem measure_inter_null_of_null_right (S : Set α) {T : Set α} (h : μ T = 0) : μ (S ∩ T) = 0 :=
  measure_mono_null (inter_subset_right S T) h
#align
  measure_theory.measure_inter_null_of_null_right MeasureTheory.measure_inter_null_of_null_right

theorem measure_inter_null_of_null_left {S : Set α} (T : Set α) (h : μ S = 0) : μ (S ∩ T) = 0 :=
  measure_mono_null (inter_subset_left S T) h
#align measure_theory.measure_inter_null_of_null_left MeasureTheory.measure_inter_null_of_null_left

/-! ### The almost everywhere filter -/


/-- The “almost everywhere” filter of co-null sets. -/
def Measure.ae {α} {m : MeasurableSpace α} (μ : Measure α) : Filter α
    where
  sets := { s | μ (sᶜ) = 0 }
  univ_sets := by simp
  inter_sets s t hs ht := by
    simp only [compl_inter, mem_set_of_eq] <;> exact measure_union_null hs ht
  sets_of_superset s t hs hst := measure_mono_null (Set.compl_subset_compl.2 hst) hs
#align measure_theory.measure.ae MeasureTheory.Measure.ae

-- mathport name: «expr∀ᵐ ∂ , »
notation3"∀ᵐ "(...)" ∂"μ", "r:(scoped P => Filter.Eventually P Measure.ae μ) => r

-- mathport name: «expr∃ᵐ ∂ , »
notation3"∃ᵐ "(...)" ∂"μ", "r:(scoped P => Filter.Frequently P Measure.ae μ) => r

-- mathport name: «expr =ᵐ[ ] »
notation:50 f " =ᵐ[" μ:50 "] " g:50 => f =ᶠ[Measure.ae μ] g

-- mathport name: «expr ≤ᵐ[ ] »
notation:50 f " ≤ᵐ[" μ:50 "] " g:50 => f ≤ᶠ[Measure.ae μ] g

theorem mem_ae_iff {s : Set α} : s ∈ μ.ae ↔ μ (sᶜ) = 0 :=
  Iff.rfl
#align measure_theory.mem_ae_iff MeasureTheory.mem_ae_iff

theorem ae_iff {p : α → Prop} : (∀ᵐ a ∂μ, p a) ↔ μ { a | ¬p a } = 0 :=
  Iff.rfl
#align measure_theory.ae_iff MeasureTheory.ae_iff

theorem compl_mem_ae_iff {s : Set α} : sᶜ ∈ μ.ae ↔ μ s = 0 := by simp only [mem_ae_iff, compl_compl]
#align measure_theory.compl_mem_ae_iff MeasureTheory.compl_mem_ae_iff

theorem frequently_ae_iff {p : α → Prop} : (∃ᵐ a ∂μ, p a) ↔ μ { a | p a } ≠ 0 :=
  not_congr compl_mem_ae_iff
#align measure_theory.frequently_ae_iff MeasureTheory.frequently_ae_iff

theorem frequently_ae_mem_iff {s : Set α} : (∃ᵐ a ∂μ, a ∈ s) ↔ μ s ≠ 0 :=
  not_congr compl_mem_ae_iff
#align measure_theory.frequently_ae_mem_iff MeasureTheory.frequently_ae_mem_iff

theorem measure_zero_iff_ae_nmem {s : Set α} : μ s = 0 ↔ ∀ᵐ a ∂μ, a ∉ s :=
  compl_mem_ae_iff.symm
#align measure_theory.measure_zero_iff_ae_nmem MeasureTheory.measure_zero_iff_ae_nmem

theorem ae_of_all {p : α → Prop} (μ : Measure α) : (∀ a, p a) → ∀ᵐ a ∂μ, p a :=
  eventually_of_forall
#align measure_theory.ae_of_all MeasureTheory.ae_of_all

--instance ae_is_measurably_generated : is_measurably_generated μ.ae :=
--⟨λ s hs, let ⟨t, hst, htm, htμ⟩ := exists_measurable_superset_of_null hs in
--  ⟨tᶜ, compl_mem_ae_iff.2 htμ, htm.compl, compl_subset_comm.1 hst⟩⟩
instance : CountableInterFilter μ.ae :=
  ⟨by
    intro S hSc hS
    rw [mem_ae_iff, compl_sInter, sUnion_image]
    exact (measure_bUnion_null_iff hSc).2 hS⟩

theorem ae_all_iff {ι : Sort _} [Countable ι] {p : α → ι → Prop} :
    (∀ᵐ a ∂μ, ∀ i, p a i) ↔ ∀ i, ∀ᵐ a ∂μ, p a i :=
  eventually_countable_forall
#align measure_theory.ae_all_iff MeasureTheory.ae_all_iff

theorem ae_ball_iff {S : Set ι} (hS : S.Countable) {p : ∀ (x : α), ∀ i ∈ S, Prop} :
    (∀ᵐ x ∂μ, ∀ i ∈ S, p x i ‹_›) ↔ ∀ i ∈ S, ∀ᵐ x ∂μ, p x i ‹_› :=
  eventually_countable_ball hS
#align measure_theory.ae_ball_iff MeasureTheory.ae_ball_iff

theorem ae_eq_refl (f : α → δ) : f =ᵐ[μ] f :=
  eventually_eq.rfl
#align measure_theory.ae_eq_refl MeasureTheory.ae_eq_refl

theorem ae_eq_symm {f g : α → δ} (h : f =ᵐ[μ] g) : g =ᵐ[μ] f :=
  h.symm
#align measure_theory.ae_eq_symm MeasureTheory.ae_eq_symm

theorem ae_eq_trans {f g h : α → δ} (h₁ : f =ᵐ[μ] g) (h₂ : g =ᵐ[μ] h) : f =ᵐ[μ] h :=
  h₁.trans h₂
#align measure_theory.ae_eq_trans MeasureTheory.ae_eq_trans

theorem ae_le_of_ae_lt {f g : α → ℝ≥0∞} (h : ∀ᵐ x ∂μ, f x < g x) : f ≤ᵐ[μ] g :=
  by
  rw [Filter.EventuallyLe, ae_iff]
  rw [ae_iff] at h
  refine' measure_mono_null (fun x hx => _) h
  exact not_lt.2 (le_of_lt (not_le.1 hx))
#align measure_theory.ae_le_of_ae_lt MeasureTheory.ae_le_of_ae_lt

@[simp]
theorem ae_eq_empty : s =ᵐ[μ] (∅ : Set α) ↔ μ s = 0 :=
  eventually_eq_empty.trans <| by simp only [ae_iff, not_not, set_of_mem_eq]
#align measure_theory.ae_eq_empty MeasureTheory.ae_eq_empty

@[simp]
theorem ae_eq_univ : s =ᵐ[μ] (univ : Set α) ↔ μ (sᶜ) = 0 :=
  eventually_eq_univ
#align measure_theory.ae_eq_univ MeasureTheory.ae_eq_univ

theorem ae_le_set : s ≤ᵐ[μ] t ↔ μ (s \ t) = 0 :=
  calc
    s ≤ᵐ[μ] t ↔ ∀ᵐ x ∂μ, x ∈ s → x ∈ t := Iff.rfl
    _ ↔ μ (s \ t) = 0 := by simp [ae_iff] <;> rfl
    
#align measure_theory.ae_le_set MeasureTheory.ae_le_set

theorem ae_le_set_inter {s' t' : Set α} (h : s ≤ᵐ[μ] t) (h' : s' ≤ᵐ[μ] t') :
    (s ∩ s' : Set α) ≤ᵐ[μ] (t ∩ t' : Set α) :=
  h.inter h'
#align measure_theory.ae_le_set_inter MeasureTheory.ae_le_set_inter

theorem ae_le_set_union {s' t' : Set α} (h : s ≤ᵐ[μ] t) (h' : s' ≤ᵐ[μ] t') :
    (s ∪ s' : Set α) ≤ᵐ[μ] (t ∪ t' : Set α) :=
  h.union h'
#align measure_theory.ae_le_set_union MeasureTheory.ae_le_set_union

theorem union_ae_eq_right : (s ∪ t : Set α) =ᵐ[μ] t ↔ μ (s \ t) = 0 := by
  simp [eventually_le_antisymm_iff, ae_le_set, union_diff_right,
    diff_eq_empty.2 (Set.subset_union_right _ _)]
#align measure_theory.union_ae_eq_right MeasureTheory.union_ae_eq_right

theorem diff_ae_eq_self : (s \ t : Set α) =ᵐ[μ] s ↔ μ (s ∩ t) = 0 := by
  simp [eventually_le_antisymm_iff, ae_le_set, diff_diff_right, diff_diff,
    diff_eq_empty.2 (Set.subset_union_right _ _)]
#align measure_theory.diff_ae_eq_self MeasureTheory.diff_ae_eq_self

theorem diff_null_ae_eq_self (ht : μ t = 0) : (s \ t : Set α) =ᵐ[μ] s :=
  diff_ae_eq_self.mpr (measure_mono_null (inter_subset_right _ _) ht)
#align measure_theory.diff_null_ae_eq_self MeasureTheory.diff_null_ae_eq_self

theorem ae_eq_set {s t : Set α} : s =ᵐ[μ] t ↔ μ (s \ t) = 0 ∧ μ (t \ s) = 0 := by
  simp [eventually_le_antisymm_iff, ae_le_set]
#align measure_theory.ae_eq_set MeasureTheory.ae_eq_set

@[simp]
theorem measure_symm_diff_eq_zero_iff {s t : Set α} : μ (s ∆ t) = 0 ↔ s =ᵐ[μ] t := by
  simp [ae_eq_set, symmDiff_def]
#align measure_theory.measure_symm_diff_eq_zero_iff MeasureTheory.measure_symm_diff_eq_zero_iff

@[simp]
theorem ae_eq_set_compl_compl {s t : Set α} : sᶜ =ᵐ[μ] tᶜ ↔ s =ᵐ[μ] t := by
  simp only [← measure_symm_diff_eq_zero_iff, compl_symmDiff_compl]
#align measure_theory.ae_eq_set_compl_compl MeasureTheory.ae_eq_set_compl_compl

theorem ae_eq_set_compl {s t : Set α} : sᶜ =ᵐ[μ] t ↔ s =ᵐ[μ] tᶜ := by
  rw [← ae_eq_set_compl_compl, compl_compl]
#align measure_theory.ae_eq_set_compl MeasureTheory.ae_eq_set_compl

theorem ae_eq_set_inter {s' t' : Set α} (h : s =ᵐ[μ] t) (h' : s' =ᵐ[μ] t') :
    (s ∩ s' : Set α) =ᵐ[μ] (t ∩ t' : Set α) :=
  h.inter h'
#align measure_theory.ae_eq_set_inter MeasureTheory.ae_eq_set_inter

theorem ae_eq_set_union {s' t' : Set α} (h : s =ᵐ[μ] t) (h' : s' =ᵐ[μ] t') :
    (s ∪ s' : Set α) =ᵐ[μ] (t ∪ t' : Set α) :=
  h.union h'
#align measure_theory.ae_eq_set_union MeasureTheory.ae_eq_set_union

theorem union_ae_eq_univ_of_ae_eq_univ_left (h : s =ᵐ[μ] univ) : (s ∪ t : Set α) =ᵐ[μ] univ :=
  by
  convert ae_eq_set_union h (ae_eq_refl t)
  rw [univ_union]
#align
  measure_theory.union_ae_eq_univ_of_ae_eq_univ_left MeasureTheory.union_ae_eq_univ_of_ae_eq_univ_left

theorem union_ae_eq_univ_of_ae_eq_univ_right (h : t =ᵐ[μ] univ) : (s ∪ t : Set α) =ᵐ[μ] univ :=
  by
  convert ae_eq_set_union (ae_eq_refl s) h
  rw [union_univ]
#align
  measure_theory.union_ae_eq_univ_of_ae_eq_univ_right MeasureTheory.union_ae_eq_univ_of_ae_eq_univ_right

theorem union_ae_eq_right_of_ae_eq_empty (h : s =ᵐ[μ] (∅ : Set α)) : (s ∪ t : Set α) =ᵐ[μ] t :=
  by
  convert ae_eq_set_union h (ae_eq_refl t)
  rw [empty_union]
#align
  measure_theory.union_ae_eq_right_of_ae_eq_empty MeasureTheory.union_ae_eq_right_of_ae_eq_empty

theorem union_ae_eq_left_of_ae_eq_empty (h : t =ᵐ[μ] (∅ : Set α)) : (s ∪ t : Set α) =ᵐ[μ] s :=
  by
  convert ae_eq_set_union (ae_eq_refl s) h
  rw [union_empty]
#align measure_theory.union_ae_eq_left_of_ae_eq_empty MeasureTheory.union_ae_eq_left_of_ae_eq_empty

theorem inter_ae_eq_right_of_ae_eq_univ (h : s =ᵐ[μ] univ) : (s ∩ t : Set α) =ᵐ[μ] t :=
  by
  convert ae_eq_set_inter h (ae_eq_refl t)
  rw [univ_inter]
#align measure_theory.inter_ae_eq_right_of_ae_eq_univ MeasureTheory.inter_ae_eq_right_of_ae_eq_univ

theorem inter_ae_eq_left_of_ae_eq_univ (h : t =ᵐ[μ] univ) : (s ∩ t : Set α) =ᵐ[μ] s :=
  by
  convert ae_eq_set_inter (ae_eq_refl s) h
  rw [inter_univ]
#align measure_theory.inter_ae_eq_left_of_ae_eq_univ MeasureTheory.inter_ae_eq_left_of_ae_eq_univ

theorem inter_ae_eq_empty_of_ae_eq_empty_left (h : s =ᵐ[μ] (∅ : Set α)) :
    (s ∩ t : Set α) =ᵐ[μ] (∅ : Set α) :=
  by
  convert ae_eq_set_inter h (ae_eq_refl t)
  rw [empty_inter]
#align
  measure_theory.inter_ae_eq_empty_of_ae_eq_empty_left MeasureTheory.inter_ae_eq_empty_of_ae_eq_empty_left

theorem inter_ae_eq_empty_of_ae_eq_empty_right (h : t =ᵐ[μ] (∅ : Set α)) :
    (s ∩ t : Set α) =ᵐ[μ] (∅ : Set α) :=
  by
  convert ae_eq_set_inter (ae_eq_refl s) h
  rw [inter_empty]
#align
  measure_theory.inter_ae_eq_empty_of_ae_eq_empty_right MeasureTheory.inter_ae_eq_empty_of_ae_eq_empty_right

@[to_additive]
theorem Set.mul_indicator_ae_eq_one {M : Type _} [One M] {f : α → M} {s : Set α}
    (h : s.mulIndicator f =ᵐ[μ] 1) : μ (s ∩ Function.mulSupport f) = 0 := by
  simpa [Filter.EventuallyEq, ae_iff] using h
#align set.mul_indicator_ae_eq_one Set.mul_indicator_ae_eq_one

/-- If `s ⊆ t` modulo a set of measure `0`, then `μ s ≤ μ t`. -/
@[mono]
theorem measure_mono_ae (H : s ≤ᵐ[μ] t) : μ s ≤ μ t :=
  calc
    μ s ≤ μ (s ∪ t) := measure_mono <| subset_union_left s t
    _ = μ (t ∪ s \ t) := by rw [union_diff_self, Set.union_comm]
    _ ≤ μ t + μ (s \ t) := measure_union_le _ _
    _ = μ t := by rw [ae_le_set.1 H, add_zero]
    
#align measure_theory.measure_mono_ae MeasureTheory.measure_mono_ae

alias measure_mono_ae ← _root_.filter.eventually_le.measure_le

/-- If two sets are equal modulo a set of measure zero, then `μ s = μ t`. -/
theorem measure_congr (H : s =ᵐ[μ] t) : μ s = μ t :=
  le_antisymm H.le.measure_le H.symm.le.measure_le
#align measure_theory.measure_congr MeasureTheory.measure_congr

alias measure_congr ← _root_.filter.eventually_eq.measure_eq

theorem measure_mono_null_ae (H : s ≤ᵐ[μ] t) (ht : μ t = 0) : μ s = 0 :=
  nonpos_iff_eq_zero.1 <| ht ▸ H.measure_le
#align measure_theory.measure_mono_null_ae MeasureTheory.measure_mono_null_ae

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (t «expr ⊇ » s) -/
/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (t «expr ⊇ » s) -/
/-- A measurable set `t ⊇ s` such that `μ t = μ s`. It even satisfies `μ (t ∩ u) = μ (s ∩ u)` for
any measurable set `u` if `μ s ≠ ∞`, see `measure_to_measurable_inter`.
(This property holds without the assumption `μ s ≠ ∞` when the space is sigma-finite,
see `measure_to_measurable_inter_of_sigma_finite`).
If `s` is a null measurable set, then
we also have `t =ᵐ[μ] s`, see `null_measurable_set.to_measurable_ae_eq`.
This notion is sometimes called a "measurable hull" in the literature. -/
irreducible_def toMeasurable (μ : Measure α) (s : Set α) : Set α :=
  if h : ∃ (t : _)(_ : t ⊇ s), MeasurableSet t ∧ t =ᵐ[μ] s then h.some
  else
    if h' :
        ∃ (t : _)(_ : t ⊇ s), MeasurableSet t ∧ ∀ u, MeasurableSet u → μ (t ∩ u) = μ (s ∩ u) then
      h'.some
    else (exists_measurable_superset μ s).some
#align measure_theory.to_measurable MeasureTheory.toMeasurable

theorem subset_to_measurable (μ : Measure α) (s : Set α) : s ⊆ toMeasurable μ s :=
  by
  rw [to_measurable]; split_ifs with hs h's
  exacts[hs.some_spec.fst, h's.some_spec.fst, (exists_measurable_superset μ s).some_spec.1]
#align measure_theory.subset_to_measurable MeasureTheory.subset_to_measurable

theorem ae_le_to_measurable : s ≤ᵐ[μ] toMeasurable μ s :=
  (subset_to_measurable _ _).EventuallyLe
#align measure_theory.ae_le_to_measurable MeasureTheory.ae_le_to_measurable

@[simp]
theorem measurable_set_to_measurable (μ : Measure α) (s : Set α) :
    MeasurableSet (toMeasurable μ s) := by
  rw [to_measurable]; split_ifs with hs h's
  exacts[hs.some_spec.snd.1, h's.some_spec.snd.1, (exists_measurable_superset μ s).some_spec.2.1]
#align measure_theory.measurable_set_to_measurable MeasureTheory.measurable_set_to_measurable

@[simp]
theorem measure_to_measurable (s : Set α) : μ (toMeasurable μ s) = μ s :=
  by
  rw [to_measurable]; split_ifs with hs h's
  · exact measure_congr hs.some_spec.snd.2
  · simpa only [inter_univ] using h's.some_spec.snd.2 univ MeasurableSet.univ
  · exact (exists_measurable_superset μ s).some_spec.2.2
#align measure_theory.measure_to_measurable MeasureTheory.measure_to_measurable

/-- A measure space is a measurable space equipped with a
  measure, referred to as `volume`. -/
class MeasureSpace (α : Type _) extends MeasurableSpace α where
  volume : Measure α
#align measure_theory.measure_space MeasureTheory.MeasureSpace

export MeasureSpace (volume)

/-- `volume` is the canonical  measure on `α`. -/
add_decl_doc volume

section MeasureSpace

-- mathport name: «expr∀ᵐ , »
notation3"∀ᵐ "(...)", "r:(scoped P =>
  Filter.Eventually P MeasureTheory.Measure.ae MeasureTheory.MeasureSpace.volume) => r

-- mathport name: «expr∃ᵐ , »
notation3"∃ᵐ "(...)", "r:(scoped P =>
  Filter.Frequently P MeasureTheory.Measure.ae MeasureTheory.MeasureSpace.volume) => r

/- ./././Mathport/Syntax/Translate/Expr.lean:333:4: warning: unsupported (TODO): `[tacs] -/
/-- The tactic `exact volume`, to be used in optional (`auto_param`) arguments. -/
unsafe def volume_tac : tactic Unit :=
  sorry
#align measure_theory.volume_tac measure_theory.volume_tac

end MeasureSpace

end

end MeasureTheory

section

open MeasureTheory

/-!
# Almost everywhere measurable functions

A function is almost everywhere measurable if it coincides almost everywhere with a measurable
function. We define this property, called `ae_measurable f μ`. It's properties are discussed in
`measure_theory.measure_space`.
-/


variable {m : MeasurableSpace α} [MeasurableSpace β] {f g : α → β} {μ ν : Measure α}

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic measure_theory.volume_tac -/
/-- A function is almost everywhere measurable if it coincides almost everywhere with a measurable
function. -/
def AeMeasurable {m : MeasurableSpace α} (f : α → β)
    (μ : Measure α := by
      run_tac
        measure_theory.volume_tac) :
    Prop :=
  ∃ g : α → β, Measurable g ∧ f =ᵐ[μ] g
#align ae_measurable AeMeasurable

theorem Measurable.aeMeasurable (h : Measurable f) : AeMeasurable f μ :=
  ⟨f, h, ae_eq_refl f⟩
#align measurable.ae_measurable Measurable.aeMeasurable

namespace AeMeasurable

/-- Given an almost everywhere measurable function `f`, associate to it a measurable function
that coincides with it almost everywhere. `f` is explicit in the definition to make sure that
it shows in pretty-printing. -/
def mk (f : α → β) (h : AeMeasurable f μ) : α → β :=
  Classical.choose h
#align ae_measurable.mk AeMeasurable.mk

theorem measurable_mk (h : AeMeasurable f μ) : Measurable (h.mk f) :=
  (Classical.choose_spec h).1
#align ae_measurable.measurable_mk AeMeasurable.measurable_mk

theorem ae_eq_mk (h : AeMeasurable f μ) : f =ᵐ[μ] h.mk f :=
  (Classical.choose_spec h).2
#align ae_measurable.ae_eq_mk AeMeasurable.ae_eq_mk

theorem congr (hf : AeMeasurable f μ) (h : f =ᵐ[μ] g) : AeMeasurable g μ :=
  ⟨hf.mk f, hf.measurable_mk, h.symm.trans hf.ae_eq_mk⟩
#align ae_measurable.congr AeMeasurable.congr

end AeMeasurable

theorem ae_measurable_congr (h : f =ᵐ[μ] g) : AeMeasurable f μ ↔ AeMeasurable g μ :=
  ⟨fun hf => AeMeasurable.congr hf h, fun hg => AeMeasurable.congr hg h.symm⟩
#align ae_measurable_congr ae_measurable_congr

@[simp]
theorem aeMeasurableConst {b : β} : AeMeasurable (fun a : α => b) μ :=
  measurable_const.AeMeasurable
#align ae_measurable_const aeMeasurableConst

theorem aeMeasurableId : AeMeasurable id μ :=
  measurable_id.AeMeasurable
#align ae_measurable_id aeMeasurableId

theorem aeMeasurableId' : AeMeasurable (fun x => x) μ :=
  measurable_id.AeMeasurable
#align ae_measurable_id' aeMeasurableId'

theorem Measurable.compAeMeasurable [MeasurableSpace δ] {f : α → δ} {g : δ → β} (hg : Measurable g)
    (hf : AeMeasurable f μ) : AeMeasurable (g ∘ f) μ :=
  ⟨g ∘ hf.mk f, hg.comp hf.measurable_mk, EventuallyEq.fun_comp hf.ae_eq_mk _⟩
#align measurable.comp_ae_measurable Measurable.compAeMeasurable

end

