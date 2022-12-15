/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro

! This file was ported from Lean 3 source module measure_theory.measure.outer_measure
! leanprover-community/mathlib commit aba57d4d3dae35460225919dcd82fe91355162f9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecificLimits.Basic
import Mathbin.MeasureTheory.PiSystem
import Mathbin.Data.Countable.Basic
import Mathbin.Data.Fin.VecNotation
import Mathbin.Topology.Algebra.InfiniteSum

/-!
# Outer Measures

An outer measure is a function `μ : set α → ℝ≥0∞`, from the powerset of a type to the extended
nonnegative real numbers that satisfies the following conditions:
1. `μ ∅ = 0`;
2. `μ` is monotone;
3. `μ` is countably subadditive. This means that the outer measure of a countable union is at most
   the sum of the outer measure on the individual sets.

Note that we do not need `α` to be measurable to define an outer measure.

The outer measures on a type `α` form a complete lattice.

Given an arbitrary function `m : set α → ℝ≥0∞` that sends `∅` to `0` we can define an outer
measure on `α` that on `s` is defined to be the infimum of `∑ᵢ, m (sᵢ)` for all collections of sets
`sᵢ` that cover `s`. This is the unique maximal outer measure that is at most the given function.
We also define this for functions `m` defined on a subset of `set α`, by treating the function as
having value `∞` outside its domain.

Given an outer measure `m`, the Carathéodory-measurable sets are the sets `s` such that
for all sets `t` we have `m t = m (t ∩ s) + m (t \ s)`. This forms a measurable space.

## Main definitions and statements

* `outer_measure.bounded_by` is the greatest outer measure that is at most the given function.
  If you know that the given functions sends `∅` to `0`, then `outer_measure.of_function` is a
  special case.
* `caratheodory` is the Carathéodory-measurable space of an outer measure.
* `Inf_eq_of_function_Inf_gen` is a characterization of the infimum of outer measures.
* `induced_outer_measure` is the measure induced by a function on a subset of `set α`

## References

* <https://en.wikipedia.org/wiki/Outer_measure>
* <https://en.wikipedia.org/wiki/Carath%C3%A9odory%27s_criterion>

## Tags

outer measure, Carathéodory-measurable, Carathéodory's criterion
-/


noncomputable section

open Set Function Filter

open TopologicalSpace (SecondCountableTopology)

open Classical BigOperators Nnreal TopologicalSpace Ennreal MeasureTheory

namespace MeasureTheory

/-- An outer measure is a countably subadditive monotone function that sends `∅` to `0`. -/
structure OuterMeasure (α : Type _) where
  measureOf : Set α → ℝ≥0∞
  Empty : measure_of ∅ = 0
  mono : ∀ {s₁ s₂}, s₁ ⊆ s₂ → measure_of s₁ ≤ measure_of s₂
  Union_nat : ∀ s : ℕ → Set α, measure_of (⋃ i, s i) ≤ ∑' i, measure_of (s i)
#align measure_theory.outer_measure MeasureTheory.OuterMeasure

namespace OuterMeasure

section Basic

variable {α β R R' : Type _} {ms : Set (OuterMeasure α)} {m : OuterMeasure α}

instance : CoeFun (OuterMeasure α) fun _ => Set α → ℝ≥0∞ :=
  ⟨fun m => m.measureOf⟩

@[simp]
theorem measure_of_eq_coe (m : OuterMeasure α) : m.measureOf = m :=
  rfl
#align measure_theory.outer_measure.measure_of_eq_coe MeasureTheory.OuterMeasure.measure_of_eq_coe

@[simp]
theorem empty' (m : OuterMeasure α) : m ∅ = 0 :=
  m.Empty
#align measure_theory.outer_measure.empty' MeasureTheory.OuterMeasure.empty'

theorem mono' (m : OuterMeasure α) {s₁ s₂} (h : s₁ ⊆ s₂) : m s₁ ≤ m s₂ :=
  m.mono h
#align measure_theory.outer_measure.mono' MeasureTheory.OuterMeasure.mono'

theorem mono_null (m : OuterMeasure α) {s t} (h : s ⊆ t) (ht : m t = 0) : m s = 0 :=
  nonpos_iff_eq_zero.mp <| ht ▸ m.mono' h
#align measure_theory.outer_measure.mono_null MeasureTheory.OuterMeasure.mono_null

theorem pos_of_subset_ne_zero (m : OuterMeasure α) {a b : Set α} (hs : a ⊆ b) (hnz : m a ≠ 0) :
    0 < m b :=
  lt_of_lt_of_le (pos_iff_ne_zero.mpr hnz) (m.mono hs)
#align
  measure_theory.outer_measure.pos_of_subset_ne_zero MeasureTheory.OuterMeasure.pos_of_subset_ne_zero

protected theorem Union (m : OuterMeasure α) {β} [Countable β] (s : β → Set α) :
    m (⋃ i, s i) ≤ ∑' i, m (s i) :=
  relSuprTsum m m.Empty (· ≤ ·) m.Union_nat s
#align measure_theory.outer_measure.Union MeasureTheory.OuterMeasure.Union

theorem Union_null [Countable β] (m : OuterMeasure α) {s : β → Set α} (h : ∀ i, m (s i) = 0) :
    m (⋃ i, s i) = 0 := by simpa [h] using m.Union s
#align measure_theory.outer_measure.Union_null MeasureTheory.OuterMeasure.Union_null

@[simp]
theorem Union_null_iff [Countable β] (m : OuterMeasure α) {s : β → Set α} :
    m (⋃ i, s i) = 0 ↔ ∀ i, m (s i) = 0 :=
  ⟨fun h i => m.mono_null (subset_Union _ _) h, m.Union_null⟩
#align measure_theory.outer_measure.Union_null_iff MeasureTheory.OuterMeasure.Union_null_iff

/-- A version of `Union_null_iff` for unions indexed by Props.
TODO: in the long run it would be better to combine this with `Union_null_iff` by
generalising to `Sort`. -/
@[simp]
theorem Union_null_iff' (m : OuterMeasure α) {ι : Prop} {s : ι → Set α} :
    m (⋃ i, s i) = 0 ↔ ∀ i, m (s i) = 0 := by by_cases i : ι <;> simp [i]
#align measure_theory.outer_measure.Union_null_iff' MeasureTheory.OuterMeasure.Union_null_iff'

theorem bUnion_null_iff (m : OuterMeasure α) {s : Set β} (hs : s.Countable) {t : β → Set α} :
    m (⋃ i ∈ s, t i) = 0 ↔ ∀ i ∈ s, m (t i) = 0 := by
  haveI := hs.to_encodable
  rw [bUnion_eq_Union, Union_null_iff, SetCoe.forall']
#align measure_theory.outer_measure.bUnion_null_iff MeasureTheory.OuterMeasure.bUnion_null_iff

theorem sUnion_null_iff (m : OuterMeasure α) {S : Set (Set α)} (hS : S.Countable) :
    m (⋃₀S) = 0 ↔ ∀ s ∈ S, m s = 0 := by rw [sUnion_eq_bUnion, m.bUnion_null_iff hS]
#align measure_theory.outer_measure.sUnion_null_iff MeasureTheory.OuterMeasure.sUnion_null_iff

protected theorem Union_finset (m : OuterMeasure α) (s : β → Set α) (t : Finset β) :
    m (⋃ i ∈ t, s i) ≤ ∑ i in t, m (s i) :=
  relSuprSum m m.Empty (· ≤ ·) m.Union_nat s t
#align measure_theory.outer_measure.Union_finset MeasureTheory.OuterMeasure.Union_finset

protected theorem union (m : OuterMeasure α) (s₁ s₂ : Set α) : m (s₁ ∪ s₂) ≤ m s₁ + m s₂ :=
  relSupAdd m m.Empty (· ≤ ·) m.Union_nat s₁ s₂
#align measure_theory.outer_measure.union MeasureTheory.OuterMeasure.union

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (t «expr ⊆ » s) -/
/-- If a set has zero measure in a neighborhood of each of its points, then it has zero measure
in a second-countable space. -/
theorem null_of_locally_null [TopologicalSpace α] [SecondCountableTopology α] (m : OuterMeasure α)
    (s : Set α) (hs : ∀ x ∈ s, ∃ u ∈ 𝓝[s] x, m u = 0) : m s = 0 := by
  choose! u hxu hu₀ using hs
  obtain ⟨t, ts, t_count, ht⟩ : ∃ (t : _)(_ : t ⊆ s), t.Countable ∧ s ⊆ ⋃ x ∈ t, u x :=
    TopologicalSpace.countable_cover_nhds_within hxu
  apply m.mono_null ht
  exact (m.bUnion_null_iff t_count).2 fun x hx => hu₀ x (ts hx)
#align
  measure_theory.outer_measure.null_of_locally_null MeasureTheory.OuterMeasure.null_of_locally_null

/-- If `m s ≠ 0`, then for some point `x ∈ s` and any `t ∈ 𝓝[s] x` we have `0 < m t`. -/
theorem exists_mem_forall_mem_nhds_within_pos [TopologicalSpace α] [SecondCountableTopology α]
    (m : OuterMeasure α) {s : Set α} (hs : m s ≠ 0) : ∃ x ∈ s, ∀ t ∈ 𝓝[s] x, 0 < m t := by
  contrapose! hs
  simp only [nonpos_iff_eq_zero, ← exists_prop] at hs
  exact m.null_of_locally_null s hs
#align
  measure_theory.outer_measure.exists_mem_forall_mem_nhds_within_pos MeasureTheory.OuterMeasure.exists_mem_forall_mem_nhds_within_pos

/-- If `s : ι → set α` is a sequence of sets, `S = ⋃ n, s n`, and `m (S \ s n)` tends to zero along
some nontrivial filter (usually `at_top` on `ι = ℕ`), then `m S = ⨆ n, m (s n)`. -/
theorem Union_of_tendsto_zero {ι} (m : OuterMeasure α) {s : ι → Set α} (l : Filter ι) [NeBot l]
    (h0 : Tendsto (fun k => m ((⋃ n, s n) \ s k)) l (𝓝 0)) : m (⋃ n, s n) = ⨆ n, m (s n) := by
  set S := ⋃ n, s n
  set M := ⨆ n, m (s n)
  have hsS : ∀ {k}, s k ⊆ S := fun k => subset_Union _ _
  refine' le_antisymm _ (supr_le fun n => m.mono hsS)
  have A : ∀ k, m S ≤ M + m (S \ s k) := fun k =>
    calc
      m S = m (s k ∪ S \ s k) := by rw [union_diff_self, union_eq_self_of_subset_left hsS]
      _ ≤ m (s k) + m (S \ s k) := m.union _ _
      _ ≤ M + m (S \ s k) := add_le_add_right (le_supr _ k) _
      
  have B : tendsto (fun k => M + m (S \ s k)) l (𝓝 (M + 0)) := tendsto_const_nhds.add h0
  rw [add_zero] at B
  exact ge_of_tendsto' B A
#align
  measure_theory.outer_measure.Union_of_tendsto_zero MeasureTheory.OuterMeasure.Union_of_tendsto_zero

/-- If `s : ℕ → set α` is a monotone sequence of sets such that `∑' k, m (s (k + 1) \ s k) ≠ ∞`,
then `m (⋃ n, s n) = ⨆ n, m (s n)`. -/
theorem Union_nat_of_monotone_of_tsum_ne_top (m : OuterMeasure α) {s : ℕ → Set α}
    (h_mono : ∀ n, s n ⊆ s (n + 1)) (h0 : (∑' k, m (s (k + 1) \ s k)) ≠ ∞) :
    m (⋃ n, s n) = ⨆ n, m (s n) := by
  refine' m.Union_of_tendsto_zero at_top _
  refine' tendsto_nhds_bot_mono' (Ennreal.tendsto_sum_nat_add _ h0) fun n => _
  refine' (m.mono _).trans (m.Union _)
  -- Current goal: `(⋃ k, s k) \ s n ⊆ ⋃ k, s (k + n + 1) \ s (k + n)`
  have h' : Monotone s := @monotone_nat_of_le_succ (Set α) _ _ h_mono
  simp only [diff_subset_iff, Union_subset_iff]
  intro i x hx
  rcases Nat.findX ⟨i, hx⟩ with ⟨j, hj, hlt⟩
  clear hx i
  cases' le_or_lt j n with hjn hnj
  · exact Or.inl (h' hjn hj)
  have : j - (n + 1) + n + 1 = j := by rw [add_assoc, tsub_add_cancel_of_le hnj.nat_succ_le]
  refine' Or.inr (mem_Union.2 ⟨j - (n + 1), _, hlt _ _⟩)
  · rwa [this]
  · rw [← Nat.succ_le_iff, Nat.succ_eq_add_one, this]
#align
  measure_theory.outer_measure.Union_nat_of_monotone_of_tsum_ne_top MeasureTheory.OuterMeasure.Union_nat_of_monotone_of_tsum_ne_top

theorem le_inter_add_diff {m : OuterMeasure α} {t : Set α} (s : Set α) :
    m t ≤ m (t ∩ s) + m (t \ s) := by 
  convert m.union _ _
  rw [inter_union_diff t s]
#align measure_theory.outer_measure.le_inter_add_diff MeasureTheory.OuterMeasure.le_inter_add_diff

theorem diff_null (m : OuterMeasure α) (s : Set α) {t : Set α} (ht : m t = 0) : m (s \ t) = m s :=
  by 
  refine' le_antisymm (m.mono <| diff_subset _ _) _
  calc
    m s ≤ m (s ∩ t) + m (s \ t) := le_inter_add_diff _
    _ ≤ m t + m (s \ t) := add_le_add_right (m.mono <| inter_subset_right _ _) _
    _ = m (s \ t) := by rw [ht, zero_add]
    
#align measure_theory.outer_measure.diff_null MeasureTheory.OuterMeasure.diff_null

theorem union_null (m : OuterMeasure α) {s₁ s₂ : Set α} (h₁ : m s₁ = 0) (h₂ : m s₂ = 0) :
    m (s₁ ∪ s₂) = 0 := by simpa [h₁, h₂] using m.union s₁ s₂
#align measure_theory.outer_measure.union_null MeasureTheory.OuterMeasure.union_null

theorem coe_fn_injective : Injective fun (μ : OuterMeasure α) (s : Set α) => μ s := fun μ₁ μ₂ h =>
  by 
  cases μ₁
  cases μ₂
  congr
  exact h
#align measure_theory.outer_measure.coe_fn_injective MeasureTheory.OuterMeasure.coe_fn_injective

@[ext]
theorem ext {μ₁ μ₂ : OuterMeasure α} (h : ∀ s, μ₁ s = μ₂ s) : μ₁ = μ₂ :=
  coe_fn_injective <| funext h
#align measure_theory.outer_measure.ext MeasureTheory.OuterMeasure.ext

/-- A version of `measure_theory.outer_measure.ext` that assumes `μ₁ s = μ₂ s` on all *nonempty*
sets `s`, and gets `μ₁ ∅ = μ₂ ∅` from `measure_theory.outer_measure.empty'`. -/
theorem ext_nonempty {μ₁ μ₂ : OuterMeasure α} (h : ∀ s : Set α, s.Nonempty → μ₁ s = μ₂ s) :
    μ₁ = μ₂ :=
  ext fun s => s.eq_empty_or_nonempty.elim (fun he => by rw [he, empty', empty']) (h s)
#align measure_theory.outer_measure.ext_nonempty MeasureTheory.OuterMeasure.ext_nonempty

instance : Zero (OuterMeasure α) :=
  ⟨{  measureOf := fun _ => 0
      Empty := rfl
      mono := fun _ _ _ => le_refl 0
      Union_nat := fun s => zero_le _ }⟩

@[simp]
theorem coe_zero : ⇑(0 : OuterMeasure α) = 0 :=
  rfl
#align measure_theory.outer_measure.coe_zero MeasureTheory.OuterMeasure.coe_zero

instance : Inhabited (OuterMeasure α) :=
  ⟨0⟩

instance : Add (OuterMeasure α) :=
  ⟨fun m₁ m₂ =>
    { measureOf := fun s => m₁ s + m₂ s
      Empty := show m₁ ∅ + m₂ ∅ = 0 by simp [outer_measure.empty]
      mono := fun s₁ s₂ h => add_le_add (m₁.mono h) (m₂.mono h)
      Union_nat := fun s =>
        calc
          m₁ (⋃ i, s i) + m₂ (⋃ i, s i) ≤ (∑' i, m₁ (s i)) + ∑' i, m₂ (s i) :=
            add_le_add (m₁.Union_nat s) (m₂.Union_nat s)
          _ = _ := Ennreal.tsum_add.symm
           }⟩

@[simp]
theorem coe_add (m₁ m₂ : OuterMeasure α) : ⇑(m₁ + m₂) = m₁ + m₂ :=
  rfl
#align measure_theory.outer_measure.coe_add MeasureTheory.OuterMeasure.coe_add

theorem add_apply (m₁ m₂ : OuterMeasure α) (s : Set α) : (m₁ + m₂) s = m₁ s + m₂ s :=
  rfl
#align measure_theory.outer_measure.add_apply MeasureTheory.OuterMeasure.add_apply

section HasSmul

variable [HasSmul R ℝ≥0∞] [IsScalarTower R ℝ≥0∞ ℝ≥0∞]

variable [HasSmul R' ℝ≥0∞] [IsScalarTower R' ℝ≥0∞ ℝ≥0∞]

instance : HasSmul R (OuterMeasure α) :=
  ⟨fun c m =>
    { measureOf := fun s => c • m s
      Empty := by rw [← smul_one_mul c (_ : ℝ≥0∞), empty', mul_zero]
      mono := fun s t h => by
        rw [← smul_one_mul c (m s), ← smul_one_mul c (m t)]
        exact Ennreal.mul_left_mono (m.mono h)
      Union_nat := fun s => by
        simp_rw [← smul_one_mul c (m _), Ennreal.tsum_mul_left]
        exact Ennreal.mul_left_mono (m.Union _) }⟩

@[simp]
theorem coe_smul (c : R) (m : OuterMeasure α) : ⇑(c • m) = c • m :=
  rfl
#align measure_theory.outer_measure.coe_smul MeasureTheory.OuterMeasure.coe_smul

theorem smul_apply (c : R) (m : OuterMeasure α) (s : Set α) : (c • m) s = c • m s :=
  rfl
#align measure_theory.outer_measure.smul_apply MeasureTheory.OuterMeasure.smul_apply

instance [SMulCommClass R R' ℝ≥0∞] : SMulCommClass R R' (OuterMeasure α) :=
  ⟨fun _ _ _ => ext fun _ => smul_comm _ _ _⟩

instance [HasSmul R R'] [IsScalarTower R R' ℝ≥0∞] : IsScalarTower R R' (OuterMeasure α) :=
  ⟨fun _ _ _ => ext fun _ => smul_assoc _ _ _⟩

instance [HasSmul Rᵐᵒᵖ ℝ≥0∞] [IsCentralScalar R ℝ≥0∞] : IsCentralScalar R (OuterMeasure α) :=
  ⟨fun _ _ => ext fun _ => op_smul_eq_smul _ _⟩

end HasSmul

instance [Monoid R] [MulAction R ℝ≥0∞] [IsScalarTower R ℝ≥0∞ ℝ≥0∞] : MulAction R (OuterMeasure α) :=
  Injective.mulAction _ coe_fn_injective coe_smul

instance addCommMonoid : AddCommMonoid (OuterMeasure α) :=
  Injective.addCommMonoid (show OuterMeasure α → Set α → ℝ≥0∞ from coeFn) coe_fn_injective rfl
    (fun _ _ => rfl) fun _ _ => rfl
#align measure_theory.outer_measure.add_comm_monoid MeasureTheory.OuterMeasure.addCommMonoid

/-- `coe_fn` as an `add_monoid_hom`. -/
@[simps]
def coeFnAddMonoidHom : OuterMeasure α →+ Set α → ℝ≥0∞ :=
  ⟨coeFn, coe_zero, coe_add⟩
#align
  measure_theory.outer_measure.coe_fn_add_monoid_hom MeasureTheory.OuterMeasure.coeFnAddMonoidHom

instance [Monoid R] [DistribMulAction R ℝ≥0∞] [IsScalarTower R ℝ≥0∞ ℝ≥0∞] :
    DistribMulAction R (OuterMeasure α) :=
  Injective.distribMulAction coeFnAddMonoidHom coe_fn_injective coe_smul

instance [Semiring R] [Module R ℝ≥0∞] [IsScalarTower R ℝ≥0∞ ℝ≥0∞] : Module R (OuterMeasure α) :=
  Injective.module R coeFnAddMonoidHom coe_fn_injective coe_smul

instance : Bot (OuterMeasure α) :=
  ⟨0⟩

@[simp]
theorem coe_bot : (⊥ : OuterMeasure α) = 0 :=
  rfl
#align measure_theory.outer_measure.coe_bot MeasureTheory.OuterMeasure.coe_bot

instance OuterMeasure.partialOrder :
    PartialOrder (OuterMeasure
        α) where 
  le m₁ m₂ := ∀ s, m₁ s ≤ m₂ s
  le_refl a s := le_rfl
  le_trans a b c hab hbc s := le_trans (hab s) (hbc s)
  le_antisymm a b hab hba := ext fun s => le_antisymm (hab s) (hba s)
#align
  measure_theory.outer_measure.outer_measure.partial_order MeasureTheory.OuterMeasure.OuterMeasure.partialOrder

instance OuterMeasure.orderBot : OrderBot (OuterMeasure α) :=
  { OuterMeasure.hasBot with
    bot_le := fun a s => by simp only [coe_zero, Pi.zero_apply, coe_bot, zero_le] }
#align
  measure_theory.outer_measure.outer_measure.order_bot MeasureTheory.OuterMeasure.OuterMeasure.orderBot

theorem univ_eq_zero_iff (m : OuterMeasure α) : m univ = 0 ↔ m = 0 :=
  ⟨fun h => bot_unique fun s => (m.mono' <| subset_univ s).trans_eq h, fun h => h.symm ▸ rfl⟩
#align measure_theory.outer_measure.univ_eq_zero_iff MeasureTheory.OuterMeasure.univ_eq_zero_iff

section Supremum

instance : HasSup (OuterMeasure α) :=
  ⟨fun ms =>
    { measureOf := fun s => ⨆ m ∈ ms, (m : OuterMeasure α) s
      Empty := nonpos_iff_eq_zero.1 <| supr₂_le fun m h => le_of_eq m.Empty
      mono := fun s₁ s₂ hs => supr₂_mono fun m hm => m.mono hs
      Union_nat := fun f =>
        supr₂_le fun m hm =>
          calc
            m (⋃ i, f i) ≤ ∑' i : ℕ, m (f i) := m.Union_nat _
            _ ≤ ∑' i, ⨆ m ∈ ms, (m : OuterMeasure α) (f i) :=
              Ennreal.tsum_le_tsum fun i => le_supr₂ m hm
             }⟩

instance : CompleteLattice (OuterMeasure α) :=
  { OuterMeasure.orderBot,
    completeLatticeOfSup (OuterMeasure α) fun ms =>
      ⟨fun m hm s => le_supr₂ m hm, fun m hm s => supr₂_le fun m' hm' => hm hm' s⟩ with }

@[simp]
theorem Sup_apply (ms : Set (OuterMeasure α)) (s : Set α) :
    (sup ms) s = ⨆ m ∈ ms, (m : OuterMeasure α) s :=
  rfl
#align measure_theory.outer_measure.Sup_apply MeasureTheory.OuterMeasure.Sup_apply

@[simp]
theorem supr_apply {ι} (f : ι → OuterMeasure α) (s : Set α) : (⨆ i : ι, f i) s = ⨆ i, f i s := by
  rw [supr, Sup_apply, supr_range, supr]
#align measure_theory.outer_measure.supr_apply MeasureTheory.OuterMeasure.supr_apply

@[norm_cast]
theorem coe_supr {ι} (f : ι → OuterMeasure α) : ⇑(⨆ i, f i) = ⨆ i, f i :=
  funext fun s => by rw [supr_apply, _root_.supr_apply]
#align measure_theory.outer_measure.coe_supr MeasureTheory.OuterMeasure.coe_supr

@[simp]
theorem sup_apply (m₁ m₂ : OuterMeasure α) (s : Set α) : (m₁ ⊔ m₂) s = m₁ s ⊔ m₂ s := by
  have := supr_apply (fun b => cond b m₁ m₂) s <;> rwa [supr_bool_eq, supr_bool_eq] at this
#align measure_theory.outer_measure.sup_apply MeasureTheory.OuterMeasure.sup_apply

theorem smul_supr [HasSmul R ℝ≥0∞] [IsScalarTower R ℝ≥0∞ ℝ≥0∞] {ι} (f : ι → OuterMeasure α)
    (c : R) : (c • ⨆ i, f i) = ⨆ i, c • f i :=
  ext fun s => by
    simp only [smul_apply, supr_apply, ← smul_one_mul c (f _ _), ← smul_one_mul c (supr _),
      Ennreal.mul_supr]
#align measure_theory.outer_measure.smul_supr MeasureTheory.OuterMeasure.smul_supr

end Supremum

@[mono]
theorem mono'' {m₁ m₂ : OuterMeasure α} {s₁ s₂ : Set α} (hm : m₁ ≤ m₂) (hs : s₁ ⊆ s₂) :
    m₁ s₁ ≤ m₂ s₂ :=
  (hm s₁).trans (m₂.mono hs)
#align measure_theory.outer_measure.mono'' MeasureTheory.OuterMeasure.mono''

/-- The pushforward of `m` along `f`. The outer measure on `s` is defined to be `m (f ⁻¹' s)`. -/
def map {β} (f : α → β) :
    OuterMeasure α →ₗ[ℝ≥0∞]
      OuterMeasure
        β where 
  toFun m :=
    { measureOf := fun s => m (f ⁻¹' s)
      Empty := m.Empty
      mono := fun s t h => m.mono (preimage_mono h)
      Union_nat := fun s => by rw [preimage_Union] <;> exact m.Union_nat fun i => f ⁻¹' s i }
  map_add' m₁ m₂ := coe_fn_injective rfl
  map_smul' c m := coe_fn_injective rfl
#align measure_theory.outer_measure.map MeasureTheory.OuterMeasure.map

@[simp]
theorem map_apply {β} (f : α → β) (m : OuterMeasure α) (s : Set β) : map f m s = m (f ⁻¹' s) :=
  rfl
#align measure_theory.outer_measure.map_apply MeasureTheory.OuterMeasure.map_apply

@[simp]
theorem map_id (m : OuterMeasure α) : map id m = m :=
  ext fun s => rfl
#align measure_theory.outer_measure.map_id MeasureTheory.OuterMeasure.map_id

@[simp]
theorem map_map {β γ} (f : α → β) (g : β → γ) (m : OuterMeasure α) :
    map g (map f m) = map (g ∘ f) m :=
  ext fun s => rfl
#align measure_theory.outer_measure.map_map MeasureTheory.OuterMeasure.map_map

@[mono]
theorem map_mono {β} (f : α → β) : Monotone (map f) := fun m m' h s => h _
#align measure_theory.outer_measure.map_mono MeasureTheory.OuterMeasure.map_mono

@[simp]
theorem map_sup {β} (f : α → β) (m m' : OuterMeasure α) : map f (m ⊔ m') = map f m ⊔ map f m' :=
  ext fun s => by simp only [map_apply, sup_apply]
#align measure_theory.outer_measure.map_sup MeasureTheory.OuterMeasure.map_sup

@[simp]
theorem map_supr {β ι} (f : α → β) (m : ι → OuterMeasure α) : map f (⨆ i, m i) = ⨆ i, map f (m i) :=
  ext fun s => by simp only [map_apply, supr_apply]
#align measure_theory.outer_measure.map_supr MeasureTheory.OuterMeasure.map_supr

instance : Functor OuterMeasure where map α β f := map f

instance : IsLawfulFunctor OuterMeasure where 
  id_map α := map_id
  comp_map α β γ f g m := (map_map f g m).symm

/-- The dirac outer measure. -/
def dirac (a : α) :
    OuterMeasure α where 
  measureOf s := indicator s (fun _ => 1) a
  Empty := by simp
  mono s t h := indicator_le_indicator_of_subset h (fun _ => zero_le _) a
  Union_nat s :=
    if hs : a ∈ ⋃ n, s n then
      let ⟨i, hi⟩ := mem_Union.1 hs
      calc
        indicator (⋃ n, s n) (fun _ => (1 : ℝ≥0∞)) a = 1 := indicator_of_mem hs _
        _ = indicator (s i) (fun _ => 1) a := (indicator_of_mem hi _).symm
        _ ≤ ∑' n, indicator (s n) (fun _ => 1) a := Ennreal.le_tsum _
        
    else by simp only [indicator_of_not_mem hs, zero_le]
#align measure_theory.outer_measure.dirac MeasureTheory.OuterMeasure.dirac

@[simp]
theorem dirac_apply (a : α) (s : Set α) : dirac a s = indicator s (fun _ => 1) a :=
  rfl
#align measure_theory.outer_measure.dirac_apply MeasureTheory.OuterMeasure.dirac_apply

/-- The sum of an (arbitrary) collection of outer measures. -/
def sum {ι} (f : ι → OuterMeasure α) :
    OuterMeasure α where 
  measureOf s := ∑' i, f i s
  Empty := by simp
  mono s t h := Ennreal.tsum_le_tsum fun i => (f i).mono' h
  Union_nat s := by rw [Ennreal.tsum_comm] <;> exact Ennreal.tsum_le_tsum fun i => (f i).Union_nat _
#align measure_theory.outer_measure.sum MeasureTheory.OuterMeasure.sum

@[simp]
theorem sum_apply {ι} (f : ι → OuterMeasure α) (s : Set α) : sum f s = ∑' i, f i s :=
  rfl
#align measure_theory.outer_measure.sum_apply MeasureTheory.OuterMeasure.sum_apply

theorem smul_dirac_apply (a : ℝ≥0∞) (b : α) (s : Set α) :
    (a • dirac b) s = indicator s (fun _ => a) b := by
  simp only [smul_apply, smul_eq_mul, dirac_apply, ← indicator_mul_right _ fun _ => a, mul_one]
#align measure_theory.outer_measure.smul_dirac_apply MeasureTheory.OuterMeasure.smul_dirac_apply

/-- Pullback of an `outer_measure`: `comap f μ s = μ (f '' s)`. -/
def comap {β} (f : α → β) :
    OuterMeasure β →ₗ[ℝ≥0∞]
      OuterMeasure
        α where 
  toFun m :=
    { measureOf := fun s => m (f '' s)
      Empty := by simp
      mono := fun s t h => m.mono <| image_subset f h
      Union_nat := fun s => by 
        rw [image_Union]
        apply m.Union_nat }
  map_add' m₁ m₂ := rfl
  map_smul' c m := rfl
#align measure_theory.outer_measure.comap MeasureTheory.OuterMeasure.comap

@[simp]
theorem comap_apply {β} (f : α → β) (m : OuterMeasure β) (s : Set α) : comap f m s = m (f '' s) :=
  rfl
#align measure_theory.outer_measure.comap_apply MeasureTheory.OuterMeasure.comap_apply

@[mono]
theorem comap_mono {β} (f : α → β) : Monotone (comap f) := fun m m' h s => h _
#align measure_theory.outer_measure.comap_mono MeasureTheory.OuterMeasure.comap_mono

@[simp]
theorem comap_supr {β ι} (f : α → β) (m : ι → OuterMeasure β) :
    comap f (⨆ i, m i) = ⨆ i, comap f (m i) :=
  ext fun s => by simp only [comap_apply, supr_apply]
#align measure_theory.outer_measure.comap_supr MeasureTheory.OuterMeasure.comap_supr

/-- Restrict an `outer_measure` to a set. -/
def restrict (s : Set α) : OuterMeasure α →ₗ[ℝ≥0∞] OuterMeasure α :=
  (map coe).comp (comap (coe : s → α))
#align measure_theory.outer_measure.restrict MeasureTheory.OuterMeasure.restrict

@[simp]
theorem restrict_apply (s t : Set α) (m : OuterMeasure α) : restrict s m t = m (t ∩ s) := by
  simp [restrict]
#align measure_theory.outer_measure.restrict_apply MeasureTheory.OuterMeasure.restrict_apply

@[mono]
theorem restrict_mono {s t : Set α} (h : s ⊆ t) {m m' : OuterMeasure α} (hm : m ≤ m') :
    restrict s m ≤ restrict t m' := fun u => by
  simp only [restrict_apply]
  exact (hm _).trans (m'.mono <| inter_subset_inter_right _ h)
#align measure_theory.outer_measure.restrict_mono MeasureTheory.OuterMeasure.restrict_mono

@[simp]
theorem restrict_univ (m : OuterMeasure α) : restrict univ m = m :=
  ext fun s => by simp
#align measure_theory.outer_measure.restrict_univ MeasureTheory.OuterMeasure.restrict_univ

@[simp]
theorem restrict_empty (m : OuterMeasure α) : restrict ∅ m = 0 :=
  ext fun s => by simp
#align measure_theory.outer_measure.restrict_empty MeasureTheory.OuterMeasure.restrict_empty

@[simp]
theorem restrict_supr {ι} (s : Set α) (m : ι → OuterMeasure α) :
    restrict s (⨆ i, m i) = ⨆ i, restrict s (m i) := by simp [restrict]
#align measure_theory.outer_measure.restrict_supr MeasureTheory.OuterMeasure.restrict_supr

theorem map_comap {β} (f : α → β) (m : OuterMeasure β) : map f (comap f m) = restrict (range f) m :=
  ext fun s => congr_arg m <| by simp only [image_preimage_eq_inter_range, Subtype.range_coe]
#align measure_theory.outer_measure.map_comap MeasureTheory.OuterMeasure.map_comap

theorem map_comap_le {β} (f : α → β) (m : OuterMeasure β) : map f (comap f m) ≤ m := fun s =>
  m.mono <| image_preimage_subset _ _
#align measure_theory.outer_measure.map_comap_le MeasureTheory.OuterMeasure.map_comap_le

theorem restrict_le_self (m : OuterMeasure α) (s : Set α) : restrict s m ≤ m :=
  map_comap_le _ _
#align measure_theory.outer_measure.restrict_le_self MeasureTheory.OuterMeasure.restrict_le_self

@[simp]
theorem map_le_restrict_range {β} {ma : OuterMeasure α} {mb : OuterMeasure β} {f : α → β} :
    map f ma ≤ restrict (range f) mb ↔ map f ma ≤ mb :=
  ⟨fun h => h.trans (restrict_le_self _ _), fun h s => by simpa using h (s ∩ range f)⟩
#align
  measure_theory.outer_measure.map_le_restrict_range MeasureTheory.OuterMeasure.map_le_restrict_range

theorem map_comap_of_surjective {β} {f : α → β} (hf : Surjective f) (m : OuterMeasure β) :
    map f (comap f m) = m :=
  ext fun s => by rw [map_apply, comap_apply, hf.image_preimage]
#align
  measure_theory.outer_measure.map_comap_of_surjective MeasureTheory.OuterMeasure.map_comap_of_surjective

theorem le_comap_map {β} (f : α → β) (m : OuterMeasure α) : m ≤ comap f (map f m) := fun s =>
  m.mono <| subset_preimage_image _ _
#align measure_theory.outer_measure.le_comap_map MeasureTheory.OuterMeasure.le_comap_map

theorem comap_map {β} {f : α → β} (hf : Injective f) (m : OuterMeasure α) : comap f (map f m) = m :=
  ext fun s => by rw [comap_apply, map_apply, hf.preimage_image]
#align measure_theory.outer_measure.comap_map MeasureTheory.OuterMeasure.comap_map

@[simp]
theorem top_apply {s : Set α} (h : s.Nonempty) : (⊤ : OuterMeasure α) s = ∞ :=
  let ⟨a, as⟩ := h
  top_unique <| le_trans (by simp [smul_dirac_apply, as]) (le_supr₂ (∞ • dirac a) trivial)
#align measure_theory.outer_measure.top_apply MeasureTheory.OuterMeasure.top_apply

theorem top_apply' (s : Set α) : (⊤ : OuterMeasure α) s = ⨅ h : s = ∅, 0 :=
  s.eq_empty_or_nonempty.elim (fun h => by simp [h]) fun h => by simp [h, h.ne_empty]
#align measure_theory.outer_measure.top_apply' MeasureTheory.OuterMeasure.top_apply'

@[simp]
theorem comap_top (f : α → β) : comap f ⊤ = ⊤ :=
  ext_nonempty fun s hs => by rw [comap_apply, top_apply hs, top_apply (hs.image _)]
#align measure_theory.outer_measure.comap_top MeasureTheory.OuterMeasure.comap_top

theorem map_top (f : α → β) : map f ⊤ = restrict (range f) ⊤ :=
  ext fun s => by
    rw [map_apply, restrict_apply, ← image_preimage_eq_inter_range, top_apply', top_apply',
      Set.image_eq_empty]
#align measure_theory.outer_measure.map_top MeasureTheory.OuterMeasure.map_top

theorem map_top_of_surjective (f : α → β) (hf : Surjective f) : map f ⊤ = ⊤ := by
  rw [map_top, hf.range_eq, restrict_univ]
#align
  measure_theory.outer_measure.map_top_of_surjective MeasureTheory.OuterMeasure.map_top_of_surjective

end Basic

section OfFunction

/- ./././Mathport/Syntax/Translate/Basic.lean:334:40: warning: unsupported option eqn_compiler.zeta -/
set_option eqn_compiler.zeta true

variable {α : Type _} (m : Set α → ℝ≥0∞) (m_empty : m ∅ = 0)

include m_empty

/-- Given any function `m` assigning measures to sets satisying `m ∅ = 0`, there is
  a unique maximal outer measure `μ` satisfying `μ s ≤ m s` for all `s : set α`. -/
protected def ofFunction : OuterMeasure α :=
  let μ s := ⨅ (f : ℕ → Set α) (h : s ⊆ ⋃ i, f i), ∑' i, m (f i)
  { measureOf := μ
    Empty :=
      le_antisymm
        ((infi_le_of_le fun _ => ∅) <| infi_le_of_le (empty_subset _) <| by simp [m_empty])
        (zero_le _)
    mono := fun s₁ s₂ hs => infi_mono fun f => infi_mono' fun hb => ⟨hs.trans hb, le_rfl⟩
    Union_nat := fun s =>
      Ennreal.le_of_forall_pos_le_add <| by
        intro ε hε(hb : (∑' i, μ (s i)) < ∞)
        rcases Ennreal.exists_pos_sum_of_countable (Ennreal.coe_pos.2 hε).ne' ℕ with ⟨ε', hε', hl⟩
        refine' le_trans _ (add_le_add_left (le_of_lt hl) _)
        rw [← Ennreal.tsum_add]
        choose f hf using
          show ∀ i, ∃ f : ℕ → Set α, (s i ⊆ ⋃ i, f i) ∧ (∑' i, m (f i)) < μ (s i) + ε' i by
            intro
            have : μ (s i) < μ (s i) + ε' i :=
              Ennreal.lt_add_right (ne_top_of_le_ne_top hb.ne <| Ennreal.le_tsum _)
                (by simpa using (hε' i).ne')
            simpa [μ, infi_lt_iff]
        refine' le_trans _ (Ennreal.tsum_le_tsum fun i => le_of_lt (hf i).2)
        rw [← Ennreal.tsum_prod, ← nat.mkpair_equiv.symm.tsum_eq]
        swap; · infer_instance
        refine' infi_le_of_le _ (infi_le _ _)
        exact
          Union_subset fun i =>
            subset.trans (hf i).1 <|
              Union_subset fun j =>
                subset.trans (by simp) <| subset_Union _ <| Nat.mkpairEquiv (i, j) }
#align measure_theory.outer_measure.of_function MeasureTheory.OuterMeasure.ofFunction

theorem of_function_apply (s : Set α) :
    OuterMeasure.ofFunction m m_empty s = ⨅ (t : ℕ → Set α) (h : s ⊆ union t), ∑' n, m (t n) :=
  rfl
#align measure_theory.outer_measure.of_function_apply MeasureTheory.OuterMeasure.of_function_apply

variable {m m_empty}

theorem of_function_le (s : Set α) : OuterMeasure.ofFunction m m_empty s ≤ m s :=
  let f : ℕ → Set α := fun i => Nat.casesOn i s fun _ => ∅
  infi_le_of_le f <|
    infi_le_of_le (subset_Union f 0) <|
      le_of_eq <| tsum_eq_single 0 <| by rintro (_ | i) <;> simp [f, m_empty]
#align measure_theory.outer_measure.of_function_le MeasureTheory.OuterMeasure.of_function_le

theorem of_function_eq (s : Set α) (m_mono : ∀ ⦃t : Set α⦄, s ⊆ t → m s ≤ m t)
    (m_subadd : ∀ s : ℕ → Set α, m (⋃ i, s i) ≤ ∑' i, m (s i)) :
    OuterMeasure.ofFunction m m_empty s = m s :=
  le_antisymm (of_function_le s) <|
    le_infi fun f => le_infi fun hf => le_trans (m_mono hf) (m_subadd f)
#align measure_theory.outer_measure.of_function_eq MeasureTheory.OuterMeasure.of_function_eq

theorem le_of_function {μ : OuterMeasure α} :
    μ ≤ OuterMeasure.ofFunction m m_empty ↔ ∀ s, μ s ≤ m s :=
  ⟨fun H s => le_trans (H s) (of_function_le s), fun H s =>
    le_infi fun f =>
      le_infi fun hs =>
        le_trans (μ.mono hs) <| le_trans (μ.union f) <| Ennreal.tsum_le_tsum fun i => H _⟩
#align measure_theory.outer_measure.le_of_function MeasureTheory.OuterMeasure.le_of_function

theorem is_greatest_of_function :
    IsGreatest { μ : OuterMeasure α | ∀ s, μ s ≤ m s } (OuterMeasure.ofFunction m m_empty) :=
  ⟨fun s => of_function_le _, fun μ => le_of_function.2⟩
#align
  measure_theory.outer_measure.is_greatest_of_function MeasureTheory.OuterMeasure.is_greatest_of_function

theorem of_function_eq_Sup : OuterMeasure.ofFunction m m_empty = sup { μ | ∀ s, μ s ≤ m s } :=
  (@is_greatest_of_function α m m_empty).IsLub.Sup_eq.symm
#align measure_theory.outer_measure.of_function_eq_Sup MeasureTheory.OuterMeasure.of_function_eq_Sup

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (u «expr ⊆ » «expr ∪ »(s, t)) -/
/-- If `m u = ∞` for any set `u` that has nonempty intersection both with `s` and `t`, then
`μ (s ∪ t) = μ s + μ t`, where `μ = measure_theory.outer_measure.of_function m m_empty`.

E.g., if `α` is an (e)metric space and `m u = ∞` on any set of diameter `≥ r`, then this lemma
implies that `μ (s ∪ t) = μ s + μ t` on any two sets such that `r ≤ edist x y` for all `x ∈ s`
and `y ∈ t`.  -/
theorem of_function_union_of_top_of_nonempty_inter {s t : Set α}
    (h : ∀ u, (s ∩ u).Nonempty → (t ∩ u).Nonempty → m u = ∞) :
    OuterMeasure.ofFunction m m_empty (s ∪ t) =
      OuterMeasure.ofFunction m m_empty s + OuterMeasure.ofFunction m m_empty t :=
  by 
  refine' le_antisymm (outer_measure.union _ _ _) (le_infi fun f => le_infi fun hf => _)
  set μ := outer_measure.of_function m m_empty
  rcases em (∃ i, (s ∩ f i).Nonempty ∧ (t ∩ f i).Nonempty) with (⟨i, hs, ht⟩ | he)
  ·
    calc
      μ s + μ t ≤ ∞ := le_top
      _ = m (f i) := (h (f i) hs ht).symm
      _ ≤ ∑' i, m (f i) := Ennreal.le_tsum i
      
  set I := fun s => { i : ℕ | (s ∩ f i).Nonempty }
  have hd : Disjoint (I s) (I t) := disjoint_iff_inf_le.mpr fun i hi => he ⟨i, hi⟩
  have hI : ∀ (u) (_ : u ⊆ s ∪ t), μ u ≤ ∑' i : I u, μ (f i) := fun u hu =>
    calc
      μ u ≤ μ (⋃ i : I u, f i) :=
        μ.mono fun x hx =>
          let ⟨i, hi⟩ := mem_Union.1 (hf (hu hx))
          mem_Union.2 ⟨⟨i, ⟨x, hx, hi⟩⟩, hi⟩
      _ ≤ ∑' i : I u, μ (f i) := μ.Union _
      
  calc
    μ s + μ t ≤ (∑' i : I s, μ (f i)) + ∑' i : I t, μ (f i) :=
      add_le_add (hI _ <| subset_union_left _ _) (hI _ <| subset_union_right _ _)
    _ = ∑' i : I s ∪ I t, μ (f i) :=
      (@tsum_union_disjoint _ _ _ _ _ (fun i => μ (f i)) _ _ _ hd Ennreal.summable
          Ennreal.summable).symm
    _ ≤ ∑' i, μ (f i) :=
      tsum_le_tsum_of_inj coe Subtype.coe_injective (fun _ _ => zero_le _) (fun _ => le_rfl)
        Ennreal.summable Ennreal.summable
    _ ≤ ∑' i, m (f i) := Ennreal.tsum_le_tsum fun i => of_function_le _
    
#align
  measure_theory.outer_measure.of_function_union_of_top_of_nonempty_inter MeasureTheory.OuterMeasure.of_function_union_of_top_of_nonempty_inter

theorem comap_of_function {β} (f : β → α) (h : Monotone m ∨ Surjective f) :
    comap f (OuterMeasure.ofFunction m m_empty) =
      OuterMeasure.ofFunction (fun s => m (f '' s)) (by rwa [Set.image_empty]) :=
  by 
  refine' le_antisymm (le_of_function.2 fun s => _) fun s => _
  · rw [comap_apply]
    apply of_function_le
  · rw [comap_apply, of_function_apply, of_function_apply]
    refine' infi_mono' fun t => ⟨fun k => f ⁻¹' t k, _⟩
    refine' infi_mono' fun ht => _
    rw [Set.image_subset_iff, preimage_Union] at ht
    refine' ⟨ht, Ennreal.tsum_le_tsum fun n => _⟩
    cases h
    exacts[h (image_preimage_subset _ _), (congr_arg m (h.image_preimage (t n))).le]
#align measure_theory.outer_measure.comap_of_function MeasureTheory.OuterMeasure.comap_of_function

theorem map_of_function_le {β} (f : α → β) :
    map f (OuterMeasure.ofFunction m m_empty) ≤
      OuterMeasure.ofFunction (fun s => m (f ⁻¹' s)) m_empty :=
  le_of_function.2 fun s => by 
    rw [map_apply]
    apply of_function_le
#align measure_theory.outer_measure.map_of_function_le MeasureTheory.OuterMeasure.map_of_function_le

theorem map_of_function {β} {f : α → β} (hf : Injective f) :
    map f (OuterMeasure.ofFunction m m_empty) =
      OuterMeasure.ofFunction (fun s => m (f ⁻¹' s)) m_empty :=
  by 
  refine' (map_of_function_le _).antisymm fun s => _
  simp only [of_function_apply, map_apply, le_infi_iff]
  intro t ht
  refine' infi_le_of_le (fun n => range fᶜ ∪ f '' t n) (infi_le_of_le _ _)
  · rw [← union_Union, ← inter_subset, ← image_preimage_eq_inter_range, ← image_Union]
    exact image_subset _ ht
  · refine' Ennreal.tsum_le_tsum fun n => le_of_eq _
    simp [hf.preimage_image]
#align measure_theory.outer_measure.map_of_function MeasureTheory.OuterMeasure.map_of_function

theorem restrict_of_function (s : Set α) (hm : Monotone m) :
    restrict s (OuterMeasure.ofFunction m m_empty) =
      OuterMeasure.ofFunction (fun t => m (t ∩ s)) (by rwa [Set.empty_inter]) :=
  by
  simp only [restrict, LinearMap.comp_apply, comap_of_function _ (Or.inl hm),
    map_of_function Subtype.coe_injective, Subtype.image_preimage_coe]
#align
  measure_theory.outer_measure.restrict_of_function MeasureTheory.OuterMeasure.restrict_of_function

theorem smul_of_function {c : ℝ≥0∞} (hc : c ≠ ∞) :
    c • OuterMeasure.ofFunction m m_empty = OuterMeasure.ofFunction (c • m) (by simp [m_empty]) :=
  by 
  ext1 s
  haveI : Nonempty { t : ℕ → Set α // s ⊆ ⋃ i, t i } := ⟨⟨fun _ => s, subset_Union (fun _ => s) 0⟩⟩
  simp only [smul_apply, of_function_apply, Ennreal.tsum_mul_left, Pi.smul_apply, smul_eq_mul,
    infi_subtype', Ennreal.infi_mul_left fun h => (hc h).elim]
#align measure_theory.outer_measure.smul_of_function MeasureTheory.OuterMeasure.smul_of_function

end OfFunction

section BoundedBy

variable {α : Type _} (m : Set α → ℝ≥0∞)

/-- Given any function `m` assigning measures to sets, there is a unique maximal outer measure `μ`
  satisfying `μ s ≤ m s` for all `s : set α`. This is the same as `outer_measure.of_function`,
  except that it doesn't require `m ∅ = 0`. -/
def boundedBy : OuterMeasure α :=
  OuterMeasure.ofFunction (fun s => ⨆ h : s.Nonempty, m s) (by simp [not_nonempty_empty])
#align measure_theory.outer_measure.bounded_by MeasureTheory.OuterMeasure.boundedBy

variable {m}

theorem bounded_by_le (s : Set α) : boundedBy m s ≤ m s :=
  (of_function_le _).trans supr_const_le
#align measure_theory.outer_measure.bounded_by_le MeasureTheory.OuterMeasure.bounded_by_le

theorem bounded_by_eq_of_function (m_empty : m ∅ = 0) (s : Set α) :
    boundedBy m s = OuterMeasure.ofFunction m m_empty s := by
  have : (fun s : Set α => ⨆ h : s.Nonempty, m s) = m := by
    ext1 t
    cases' t.eq_empty_or_nonempty with h h <;> simp [h, not_nonempty_empty, m_empty]
  simp [bounded_by, this]
#align
  measure_theory.outer_measure.bounded_by_eq_of_function MeasureTheory.OuterMeasure.bounded_by_eq_of_function

theorem bounded_by_apply (s : Set α) :
    boundedBy m s = ⨅ (t : ℕ → Set α) (h : s ⊆ union t), ∑' n, ⨆ h : (t n).Nonempty, m (t n) := by
  simp [bounded_by, of_function_apply]
#align measure_theory.outer_measure.bounded_by_apply MeasureTheory.OuterMeasure.bounded_by_apply

theorem bounded_by_eq (s : Set α) (m_empty : m ∅ = 0) (m_mono : ∀ ⦃t : Set α⦄, s ⊆ t → m s ≤ m t)
    (m_subadd : ∀ s : ℕ → Set α, m (⋃ i, s i) ≤ ∑' i, m (s i)) : boundedBy m s = m s := by
  rw [bounded_by_eq_of_function m_empty, of_function_eq s m_mono m_subadd]
#align measure_theory.outer_measure.bounded_by_eq MeasureTheory.OuterMeasure.bounded_by_eq

@[simp]
theorem bounded_by_eq_self (m : OuterMeasure α) : boundedBy m = m :=
  ext fun s => bounded_by_eq _ m.empty' (fun t ht => m.mono' ht) m.union
#align measure_theory.outer_measure.bounded_by_eq_self MeasureTheory.OuterMeasure.bounded_by_eq_self

theorem le_bounded_by {μ : OuterMeasure α} : μ ≤ boundedBy m ↔ ∀ s, μ s ≤ m s := by
  rw [bounded_by, le_of_function, forall_congr']; intro s
  cases' s.eq_empty_or_nonempty with h h <;> simp [h, not_nonempty_empty]
#align measure_theory.outer_measure.le_bounded_by MeasureTheory.OuterMeasure.le_bounded_by

theorem le_bounded_by' {μ : OuterMeasure α} :
    μ ≤ boundedBy m ↔ ∀ s : Set α, s.Nonempty → μ s ≤ m s := by
  rw [le_bounded_by, forall_congr']
  intro s
  cases' s.eq_empty_or_nonempty with h h <;> simp [h]
#align measure_theory.outer_measure.le_bounded_by' MeasureTheory.OuterMeasure.le_bounded_by'

theorem smul_bounded_by {c : ℝ≥0∞} (hc : c ≠ ∞) : c • boundedBy m = boundedBy (c • m) := by
  simp only [bounded_by, smul_of_function hc]
  congr 1 with s : 1
  rcases s.eq_empty_or_nonempty with (rfl | hs) <;> simp [*]
#align measure_theory.outer_measure.smul_bounded_by MeasureTheory.OuterMeasure.smul_bounded_by

theorem comap_bounded_by {β} (f : β → α)
    (h : (Monotone fun s : { s : Set α // s.Nonempty } => m s) ∨ Surjective f) :
    comap f (boundedBy m) = boundedBy fun s => m (f '' s) := by
  refine' (comap_of_function _ _).trans _
  · refine' h.imp (fun H s t hst => supr_le fun hs => _) id
    have ht : t.nonempty := hs.mono hst
    exact (@H ⟨s, hs⟩ ⟨t, ht⟩ hst).trans (le_supr (fun h : t.nonempty => m t) ht)
  · dsimp only [bounded_by]
    congr with s : 1
    rw [nonempty_image_iff]
#align measure_theory.outer_measure.comap_bounded_by MeasureTheory.OuterMeasure.comap_bounded_by

/-- If `m u = ∞` for any set `u` that has nonempty intersection both with `s` and `t`, then
`μ (s ∪ t) = μ s + μ t`, where `μ = measure_theory.outer_measure.bounded_by m`.

E.g., if `α` is an (e)metric space and `m u = ∞` on any set of diameter `≥ r`, then this lemma
implies that `μ (s ∪ t) = μ s + μ t` on any two sets such that `r ≤ edist x y` for all `x ∈ s`
and `y ∈ t`.  -/
theorem bounded_by_union_of_top_of_nonempty_inter {s t : Set α}
    (h : ∀ u, (s ∩ u).Nonempty → (t ∩ u).Nonempty → m u = ∞) :
    boundedBy m (s ∪ t) = boundedBy m s + boundedBy m t :=
  of_function_union_of_top_of_nonempty_inter fun u hs ht =>
    top_unique <| (h u hs ht).ge.trans <| le_supr (fun h => m u) (hs.mono <| inter_subset_right s u)
#align
  measure_theory.outer_measure.bounded_by_union_of_top_of_nonempty_inter MeasureTheory.OuterMeasure.bounded_by_union_of_top_of_nonempty_inter

end BoundedBy

section CaratheodoryMeasurable

universe u

parameter {α : Type u}(m : OuterMeasure α)

include m

attribute [local simp] Set.inter_comm Set.inter_left_comm Set.inter_assoc

variable {s s₁ s₂ : Set α}

/-- A set `s` is Carathéodory-measurable for an outer measure `m` if for all sets `t` we have
  `m t = m (t ∩ s) + m (t \ s)`. -/
def IsCaratheodory (s : Set α) : Prop :=
  ∀ t, m t = m (t ∩ s) + m (t \ s)
#align measure_theory.outer_measure.is_caratheodory MeasureTheory.OuterMeasure.IsCaratheodory

theorem is_caratheodory_iff_le' {s : Set α} :
    is_caratheodory s ↔ ∀ t, m (t ∩ s) + m (t \ s) ≤ m t :=
  forall_congr' fun t => le_antisymm_iff.trans <| and_iff_right <| le_inter_add_diff _
#align
  measure_theory.outer_measure.is_caratheodory_iff_le' MeasureTheory.OuterMeasure.is_caratheodory_iff_le'

@[simp]
theorem isCaratheodoryEmpty : is_caratheodory ∅ := by simp [is_caratheodory, m.empty, diff_empty]
#align
  measure_theory.outer_measure.is_caratheodory_empty MeasureTheory.OuterMeasure.isCaratheodoryEmpty

theorem isCaratheodoryCompl : is_caratheodory s₁ → is_caratheodory (s₁ᶜ) := by
  simp [is_caratheodory, diff_eq, add_comm]
#align
  measure_theory.outer_measure.is_caratheodory_compl MeasureTheory.OuterMeasure.isCaratheodoryCompl

@[simp]
theorem is_caratheodory_compl_iff : is_caratheodory (sᶜ) ↔ is_caratheodory s :=
  ⟨fun h => by simpa using is_caratheodory_compl m h, is_caratheodory_compl⟩
#align
  measure_theory.outer_measure.is_caratheodory_compl_iff MeasureTheory.OuterMeasure.is_caratheodory_compl_iff

theorem isCaratheodoryUnion (h₁ : is_caratheodory s₁) (h₂ : is_caratheodory s₂) :
    is_caratheodory (s₁ ∪ s₂) := fun t => by
  rw [h₁ t, h₂ (t ∩ s₁), h₂ (t \ s₁), h₁ (t ∩ (s₁ ∪ s₂)), inter_diff_assoc _ _ s₁,
    Set.inter_assoc _ _ s₁, inter_eq_self_of_subset_right (Set.subset_union_left _ _),
    union_diff_left, h₂ (t ∩ s₁)]
  simp [diff_eq, add_assoc]
#align
  measure_theory.outer_measure.is_caratheodory_union MeasureTheory.OuterMeasure.isCaratheodoryUnion

theorem measure_inter_union (h : s₁ ∩ s₂ ⊆ ∅) (h₁ : is_caratheodory s₁) {t : Set α} :
    m (t ∩ (s₁ ∪ s₂)) = m (t ∩ s₁) + m (t ∩ s₂) := by
  rw [h₁, Set.inter_assoc, Set.union_inter_cancel_left, inter_diff_assoc, union_diff_cancel_left h]
#align
  measure_theory.outer_measure.measure_inter_union MeasureTheory.OuterMeasure.measure_inter_union

theorem isCaratheodoryUnionLt {s : ℕ → Set α} :
    ∀ {n : ℕ}, (∀ i < n, is_caratheodory (s i)) → is_caratheodory (⋃ i < n, s i)
  | 0, h => by simp [Nat.not_lt_zero]
  | n + 1, h => by
    rw [bUnion_lt_succ] <;>
      exact
        is_caratheodory_union m
          (is_caratheodory_Union_lt fun i hi => h i <| lt_of_lt_of_le hi <| Nat.le_succ _)
          (h n (le_refl (n + 1)))
#align
  measure_theory.outer_measure.is_caratheodory_Union_lt MeasureTheory.OuterMeasure.isCaratheodoryUnionLt

theorem isCaratheodoryInter (h₁ : is_caratheodory s₁) (h₂ : is_caratheodory s₂) :
    is_caratheodory (s₁ ∩ s₂) := by
  rw [← is_caratheodory_compl_iff, Set.compl_inter]
  exact is_caratheodory_union _ (is_caratheodory_compl _ h₁) (is_caratheodory_compl _ h₂)
#align
  measure_theory.outer_measure.is_caratheodory_inter MeasureTheory.OuterMeasure.isCaratheodoryInter

theorem is_caratheodory_sum {s : ℕ → Set α} (h : ∀ i, is_caratheodory (s i))
    (hd : Pairwise (Disjoint on s)) {t : Set α} :
    ∀ {n}, (∑ i in Finset.range n, m (t ∩ s i)) = m (t ∩ ⋃ i < n, s i)
  | 0 => by simp [Nat.not_lt_zero, m.empty]
  | Nat.succ n => by
    rw [bUnion_lt_succ, Finset.sum_range_succ, Set.union_comm, is_caratheodory_sum,
      m.measure_inter_union _ (h n), add_comm]
    intro a
    simpa using fun (h₁ : a ∈ s n) i (hi : i < n) h₂ => (hd (ne_of_gt hi)).le_bot ⟨h₁, h₂⟩
#align
  measure_theory.outer_measure.is_caratheodory_sum MeasureTheory.OuterMeasure.is_caratheodory_sum

theorem isCaratheodoryUnionNat {s : ℕ → Set α} (h : ∀ i, is_caratheodory (s i))
    (hd : Pairwise (Disjoint on s)) : is_caratheodory (⋃ i, s i) :=
  is_caratheodory_iff_le'.2 fun t => by
    have hp : m (t ∩ ⋃ i, s i) ≤ ⨆ n, m (t ∩ ⋃ i < n, s i) := by
      convert m.Union fun i => t ∩ s i
      · rw [inter_Union]
      · simp [Ennreal.tsum_eq_supr_nat, is_caratheodory_sum m h hd]
    refine' le_trans (add_le_add_right hp _) _
    rw [Ennreal.supr_add]
    refine'
      supr_le fun n =>
        le_trans (add_le_add_left _ _) (ge_of_eq (is_caratheodory_Union_lt m (fun i _ => h i) _))
    refine' m.mono (diff_subset_diff_right _)
    exact Union₂_subset fun i _ => subset_Union _ i
#align
  measure_theory.outer_measure.is_caratheodory_Union_nat MeasureTheory.OuterMeasure.isCaratheodoryUnionNat

theorem f_Union {s : ℕ → Set α} (h : ∀ i, is_caratheodory (s i)) (hd : Pairwise (Disjoint on s)) :
    m (⋃ i, s i) = ∑' i, m (s i) := by
  refine' le_antisymm (m.Union_nat s) _
  rw [Ennreal.tsum_eq_supr_nat]
  refine' supr_le fun n => _
  have := @is_caratheodory_sum _ m _ h hd univ n
  simp at this; simp [this]
  exact m.mono (Union₂_subset fun i _ => subset_Union _ i)
#align measure_theory.outer_measure.f_Union MeasureTheory.OuterMeasure.f_Union

/-- The Carathéodory-measurable sets for an outer measure `m` form a Dynkin system.  -/
def caratheodoryDynkin :
    MeasurableSpace.DynkinSystem α where 
  Has := is_caratheodory
  hasEmpty := is_caratheodory_empty
  HasCompl s := is_caratheodory_compl
  hasUnionNat f hf hn := is_caratheodory_Union_nat hn hf
#align
  measure_theory.outer_measure.caratheodory_dynkin MeasureTheory.OuterMeasure.caratheodoryDynkin

/-- Given an outer measure `μ`, the Carathéodory-measurable space is
  defined such that `s` is measurable if `∀t, μ t = μ (t ∩ s) + μ (t \ s)`. -/
protected def caratheodory : MeasurableSpace α :=
  caratheodory_dynkin.toMeasurableSpace fun s₁ s₂ => is_caratheodory_inter
#align measure_theory.outer_measure.caratheodory MeasureTheory.OuterMeasure.caratheodory

theorem is_caratheodory_iff {s : Set α} :
    measurable_set[caratheodory] s ↔ ∀ t, m t = m (t ∩ s) + m (t \ s) :=
  Iff.rfl
#align
  measure_theory.outer_measure.is_caratheodory_iff MeasureTheory.OuterMeasure.is_caratheodory_iff

theorem is_caratheodory_iff_le {s : Set α} :
    measurable_set[caratheodory] s ↔ ∀ t, m (t ∩ s) + m (t \ s) ≤ m t :=
  is_caratheodory_iff_le'
#align
  measure_theory.outer_measure.is_caratheodory_iff_le MeasureTheory.OuterMeasure.is_caratheodory_iff_le

protected theorem Union_eq_of_caratheodory {s : ℕ → Set α}
    (h : ∀ i, measurable_set[caratheodory] (s i)) (hd : Pairwise (Disjoint on s)) :
    m (⋃ i, s i) = ∑' i, m (s i) :=
  f_Union h hd
#align
  measure_theory.outer_measure.Union_eq_of_caratheodory MeasureTheory.OuterMeasure.Union_eq_of_caratheodory

end CaratheodoryMeasurable

variable {α : Type _}

theorem ofFunctionCaratheodory {m : Set α → ℝ≥0∞} {s : Set α} {h₀ : m ∅ = 0}
    (hs : ∀ t, m (t ∩ s) + m (t \ s) ≤ m t) :
    measurable_set[(OuterMeasure.ofFunction m h₀).caratheodory] s := by
  apply (is_caratheodory_iff_le _).mpr
  refine' fun t => le_infi fun f => le_infi fun hf => _
  refine'
    le_trans
      (add_le_add ((infi_le_of_le fun i => f i ∩ s) <| infi_le _ _)
        ((infi_le_of_le fun i => f i \ s) <| infi_le _ _))
      _
  · rw [← Union_inter]
    exact inter_subset_inter_left _ hf
  · rw [← Union_diff]
    exact diff_subset_diff_left hf
  · rw [← Ennreal.tsum_add]
    exact Ennreal.tsum_le_tsum fun i => hs _
#align
  measure_theory.outer_measure.of_function_caratheodory MeasureTheory.OuterMeasure.ofFunctionCaratheodory

theorem boundedByCaratheodory {m : Set α → ℝ≥0∞} {s : Set α}
    (hs : ∀ t, m (t ∩ s) + m (t \ s) ≤ m t) : measurable_set[(boundedBy m).caratheodory] s := by
  apply of_function_caratheodory; intro t
  cases' t.eq_empty_or_nonempty with h h
  · simp [h, not_nonempty_empty]
  · convert le_trans _ (hs t)
    · simp [h]
    exact add_le_add supr_const_le supr_const_le
#align
  measure_theory.outer_measure.bounded_by_caratheodory MeasureTheory.OuterMeasure.boundedByCaratheodory

@[simp]
theorem zero_caratheodory : (0 : OuterMeasure α).caratheodory = ⊤ :=
  top_unique fun s _ t => (add_zero _).symm
#align measure_theory.outer_measure.zero_caratheodory MeasureTheory.OuterMeasure.zero_caratheodory

theorem top_caratheodory : (⊤ : OuterMeasure α).caratheodory = ⊤ :=
  top_unique fun s hs =>
    (is_caratheodory_iff_le _).2 fun t =>
      t.eq_empty_or_nonempty.elim (fun ht => by simp [ht]) fun ht => by
        simp only [ht, top_apply, le_top]
#align measure_theory.outer_measure.top_caratheodory MeasureTheory.OuterMeasure.top_caratheodory

theorem le_add_caratheodory (m₁ m₂ : OuterMeasure α) :
    m₁.caratheodory ⊓ m₂.caratheodory ≤ (m₁ + m₂ : OuterMeasure α).caratheodory :=
  fun s ⟨hs₁, hs₂⟩ t => by simp [hs₁ t, hs₂ t, add_left_comm, add_assoc]
#align
  measure_theory.outer_measure.le_add_caratheodory MeasureTheory.OuterMeasure.le_add_caratheodory

theorem le_sum_caratheodory {ι} (m : ι → OuterMeasure α) :
    (⨅ i, (m i).caratheodory) ≤ (sum m).caratheodory := fun s h t => by
  simp [fun i => MeasurableSpace.measurable_set_infi.1 h i t, Ennreal.tsum_add]
#align
  measure_theory.outer_measure.le_sum_caratheodory MeasureTheory.OuterMeasure.le_sum_caratheodory

theorem le_smul_caratheodory (a : ℝ≥0∞) (m : OuterMeasure α) :
    m.caratheodory ≤ (a • m).caratheodory := fun s h t => by simp [h t, mul_add]
#align
  measure_theory.outer_measure.le_smul_caratheodory MeasureTheory.OuterMeasure.le_smul_caratheodory

@[simp]
theorem dirac_caratheodory (a : α) : (dirac a).caratheodory = ⊤ :=
  top_unique fun s _ t => by 
    by_cases ht : a ∈ t; swap; · simp [ht]
    by_cases hs : a ∈ s <;> simp [*]
#align measure_theory.outer_measure.dirac_caratheodory MeasureTheory.OuterMeasure.dirac_caratheodory

section InfGen

/-- Given a set of outer measures, we define a new function that on a set `s` is defined to be the
  infimum of `μ(s)` for the outer measures `μ` in the collection. We ensure that this
  function is defined to be `0` on `∅`, even if the collection of outer measures is empty.
  The outer measure generated by this function is the infimum of the given outer measures. -/
def infGen (m : Set (OuterMeasure α)) (s : Set α) : ℝ≥0∞ :=
  ⨅ (μ : OuterMeasure α) (h : μ ∈ m), μ s
#align measure_theory.outer_measure.Inf_gen MeasureTheory.OuterMeasure.infGen

theorem Inf_gen_def (m : Set (OuterMeasure α)) (t : Set α) :
    infGen m t = ⨅ (μ : OuterMeasure α) (h : μ ∈ m), μ t :=
  rfl
#align measure_theory.outer_measure.Inf_gen_def MeasureTheory.OuterMeasure.Inf_gen_def

theorem Inf_eq_bounded_by_Inf_gen (m : Set (OuterMeasure α)) :
    inf m = OuterMeasure.boundedBy (infGen m) := by
  refine' le_antisymm _ _
  · refine' le_bounded_by.2 fun s => le_infi₂ fun μ hμ => _
    exact (show Inf m ≤ μ from Inf_le hμ) s
  · refine' le_Inf _
    intro μ hμ t
    refine' le_trans (bounded_by_le t) (infi₂_le μ hμ)
#align
  measure_theory.outer_measure.Inf_eq_bounded_by_Inf_gen MeasureTheory.OuterMeasure.Inf_eq_bounded_by_Inf_gen

theorem supr_Inf_gen_nonempty {m : Set (OuterMeasure α)} (h : m.Nonempty) (t : Set α) :
    (⨆ h : t.Nonempty, infGen m t) = ⨅ (μ : OuterMeasure α) (h : μ ∈ m), μ t := by
  rcases t.eq_empty_or_nonempty with (rfl | ht)
  · rcases h with ⟨μ, hμ⟩
    rw [eq_false not_nonempty_empty, supr_false, eq_comm]
    simp_rw [empty']
    apply bot_unique
    refine' infi_le_of_le μ (infi_le _ hμ)
  · simp [ht, Inf_gen_def]
#align
  measure_theory.outer_measure.supr_Inf_gen_nonempty MeasureTheory.OuterMeasure.supr_Inf_gen_nonempty

/-- The value of the Infimum of a nonempty set of outer measures on a set is not simply
the minimum value of a measure on that set: it is the infimum sum of measures of countable set of
sets that covers that set, where a different measure can be used for each set in the cover. -/
theorem Inf_apply {m : Set (OuterMeasure α)} {s : Set α} (h : m.Nonempty) :
    inf m s =
      ⨅ (t : ℕ → Set α) (h2 : s ⊆ union t), ∑' n, ⨅ (μ : OuterMeasure α) (h3 : μ ∈ m), μ (t n) :=
  by simp_rw [Inf_eq_bounded_by_Inf_gen, bounded_by_apply, supr_Inf_gen_nonempty h]
#align measure_theory.outer_measure.Inf_apply MeasureTheory.OuterMeasure.Inf_apply

/-- The value of the Infimum of a set of outer measures on a nonempty set is not simply
the minimum value of a measure on that set: it is the infimum sum of measures of countable set of
sets that covers that set, where a different measure can be used for each set in the cover. -/
theorem Inf_apply' {m : Set (OuterMeasure α)} {s : Set α} (h : s.Nonempty) :
    inf m s =
      ⨅ (t : ℕ → Set α) (h2 : s ⊆ union t), ∑' n, ⨅ (μ : OuterMeasure α) (h3 : μ ∈ m), μ (t n) :=
  m.eq_empty_or_nonempty.elim (fun hm => by simp [hm, h]) Inf_apply
#align measure_theory.outer_measure.Inf_apply' MeasureTheory.OuterMeasure.Inf_apply'

/-- The value of the Infimum of a nonempty family of outer measures on a set is not simply
the minimum value of a measure on that set: it is the infimum sum of measures of countable set of
sets that covers that set, where a different measure can be used for each set in the cover. -/
theorem infi_apply {ι} [Nonempty ι] (m : ι → OuterMeasure α) (s : Set α) :
    (⨅ i, m i) s = ⨅ (t : ℕ → Set α) (h2 : s ⊆ union t), ∑' n, ⨅ i, m i (t n) := by
  rw [infi, Inf_apply (range_nonempty m)]
  simp only [infi_range]
#align measure_theory.outer_measure.infi_apply MeasureTheory.OuterMeasure.infi_apply

/-- The value of the Infimum of a family of outer measures on a nonempty set is not simply
the minimum value of a measure on that set: it is the infimum sum of measures of countable set of
sets that covers that set, where a different measure can be used for each set in the cover. -/
theorem infi_apply' {ι} (m : ι → OuterMeasure α) {s : Set α} (hs : s.Nonempty) :
    (⨅ i, m i) s = ⨅ (t : ℕ → Set α) (h2 : s ⊆ union t), ∑' n, ⨅ i, m i (t n) := by
  rw [infi, Inf_apply' hs]
  simp only [infi_range]
#align measure_theory.outer_measure.infi_apply' MeasureTheory.OuterMeasure.infi_apply'

/-- The value of the Infimum of a nonempty family of outer measures on a set is not simply
the minimum value of a measure on that set: it is the infimum sum of measures of countable set of
sets that covers that set, where a different measure can be used for each set in the cover. -/
theorem binfi_apply {ι} {I : Set ι} (hI : I.Nonempty) (m : ι → OuterMeasure α) (s : Set α) :
    (⨅ i ∈ I, m i) s = ⨅ (t : ℕ → Set α) (h2 : s ⊆ union t), ∑' n, ⨅ i ∈ I, m i (t n) := by
  haveI := hI.to_subtype
  simp only [← infi_subtype'', infi_apply]
#align measure_theory.outer_measure.binfi_apply MeasureTheory.OuterMeasure.binfi_apply

/-- The value of the Infimum of a nonempty family of outer measures on a set is not simply
the minimum value of a measure on that set: it is the infimum sum of measures of countable set of
sets that covers that set, where a different measure can be used for each set in the cover. -/
theorem binfi_apply' {ι} (I : Set ι) (m : ι → OuterMeasure α) {s : Set α} (hs : s.Nonempty) :
    (⨅ i ∈ I, m i) s = ⨅ (t : ℕ → Set α) (h2 : s ⊆ union t), ∑' n, ⨅ i ∈ I, m i (t n) := by
  simp only [← infi_subtype'', infi_apply' _ hs]
#align measure_theory.outer_measure.binfi_apply' MeasureTheory.OuterMeasure.binfi_apply'

theorem map_infi_le {ι β} (f : α → β) (m : ι → OuterMeasure α) :
    map f (⨅ i, m i) ≤ ⨅ i, map f (m i) :=
  (map_mono f).map_infi_le
#align measure_theory.outer_measure.map_infi_le MeasureTheory.OuterMeasure.map_infi_le

theorem comap_infi {ι β} (f : α → β) (m : ι → OuterMeasure β) :
    comap f (⨅ i, m i) = ⨅ i, comap f (m i) := by
  refine' ext_nonempty fun s hs => _
  refine' ((comap_mono f).map_infi_le s).antisymm _
  simp only [comap_apply, infi_apply' _ hs, infi_apply' _ (hs.image _), le_infi_iff,
    Set.image_subset_iff, preimage_Union]
  refine' fun t ht => infi_le_of_le _ (infi_le_of_le ht <| Ennreal.tsum_le_tsum fun k => _)
  exact infi_mono fun i => (m i).mono (image_preimage_subset _ _)
#align measure_theory.outer_measure.comap_infi MeasureTheory.OuterMeasure.comap_infi

theorem map_infi {ι β} {f : α → β} (hf : Injective f) (m : ι → OuterMeasure α) :
    map f (⨅ i, m i) = restrict (range f) (⨅ i, map f (m i)) := by
  refine' Eq.trans _ (map_comap _ _)
  simp only [comap_infi, comap_map hf]
#align measure_theory.outer_measure.map_infi MeasureTheory.OuterMeasure.map_infi

theorem map_infi_comap {ι β} [Nonempty ι] {f : α → β} (m : ι → OuterMeasure β) :
    map f (⨅ i, comap f (m i)) = ⨅ i, map f (comap f (m i)) := by
  refine' (map_infi_le _ _).antisymm fun s => _
  simp only [map_apply, comap_apply, infi_apply, le_infi_iff]
  refine' fun t ht => infi_le_of_le (fun n => f '' t n ∪ range fᶜ) (infi_le_of_le _ _)
  · rw [← Union_union, Set.union_comm, ← inter_subset, ← image_Union, ←
      image_preimage_eq_inter_range]
    exact image_subset _ ht
  · refine' Ennreal.tsum_le_tsum fun n => infi_mono fun i => (m i).mono _
    simp
#align measure_theory.outer_measure.map_infi_comap MeasureTheory.OuterMeasure.map_infi_comap

theorem map_binfi_comap {ι β} {I : Set ι} (hI : I.Nonempty) {f : α → β} (m : ι → OuterMeasure β) :
    map f (⨅ i ∈ I, comap f (m i)) = ⨅ i ∈ I, map f (comap f (m i)) := by
  haveI := hI.to_subtype
  rw [← infi_subtype'', ← infi_subtype'']
  exact map_infi_comap _
#align measure_theory.outer_measure.map_binfi_comap MeasureTheory.OuterMeasure.map_binfi_comap

theorem restrict_infi_restrict {ι} (s : Set α) (m : ι → OuterMeasure α) :
    restrict s (⨅ i, restrict s (m i)) = restrict s (⨅ i, m i) :=
  calc
    restrict s (⨅ i, restrict s (m i)) = restrict (range (coe : s → α)) (⨅ i, restrict s (m i)) :=
      by rw [Subtype.range_coe]
    _ = map (coe : s → α) (⨅ i, comap coe (m i)) := (map_infi Subtype.coe_injective _).symm
    _ = restrict s (⨅ i, m i) := congr_arg (map coe) (comap_infi _ _).symm
    
#align
  measure_theory.outer_measure.restrict_infi_restrict MeasureTheory.OuterMeasure.restrict_infi_restrict

theorem restrict_infi {ι} [Nonempty ι] (s : Set α) (m : ι → OuterMeasure α) :
    restrict s (⨅ i, m i) = ⨅ i, restrict s (m i) :=
  (congr_arg (map coe) (comap_infi _ _)).trans (map_infi_comap _)
#align measure_theory.outer_measure.restrict_infi MeasureTheory.OuterMeasure.restrict_infi

theorem restrict_binfi {ι} {I : Set ι} (hI : I.Nonempty) (s : Set α) (m : ι → OuterMeasure α) :
    restrict s (⨅ i ∈ I, m i) = ⨅ i ∈ I, restrict s (m i) := by
  haveI := hI.to_subtype
  rw [← infi_subtype'', ← infi_subtype'']
  exact restrict_infi _ _
#align measure_theory.outer_measure.restrict_binfi MeasureTheory.OuterMeasure.restrict_binfi

/-- This proves that Inf and restrict commute for outer measures, so long as the set of
outer measures is nonempty. -/
theorem restrict_Inf_eq_Inf_restrict (m : Set (OuterMeasure α)) {s : Set α} (hm : m.Nonempty) :
    restrict s (inf m) = inf (restrict s '' m) := by
  simp only [Inf_eq_infi, restrict_binfi, hm, infi_image]
#align
  measure_theory.outer_measure.restrict_Inf_eq_Inf_restrict MeasureTheory.OuterMeasure.restrict_Inf_eq_Inf_restrict

end InfGen

end OuterMeasure

open OuterMeasure

/-! ### Induced Outer Measure

  We can extend a function defined on a subset of `set α` to an outer measure.
  The underlying function is called `extend`, and the measure it induces is called
  `induced_outer_measure`.

  Some lemmas below are proven twice, once in the general case, and one where the function `m`
  is only defined on measurable sets (i.e. when `P = measurable_set`). In the latter cases, we can
  remove some hypotheses in the statement. The general version has the same name, but with a prime
  at the end. -/


section Extend

variable {α : Type _} {P : α → Prop}

variable (m : ∀ s : α, P s → ℝ≥0∞)

/-- We can trivially extend a function defined on a subclass of objects (with codomain `ℝ≥0∞`)
  to all objects by defining it to be `∞` on the objects not in the class. -/
def extend (s : α) : ℝ≥0∞ :=
  ⨅ h : P s, m s h
#align measure_theory.extend MeasureTheory.extend

theorem extend_eq {s : α} (h : P s) : extend m s = m s h := by simp [extend, h]
#align measure_theory.extend_eq MeasureTheory.extend_eq

theorem extend_eq_top {s : α} (h : ¬P s) : extend m s = ∞ := by simp [extend, h]
#align measure_theory.extend_eq_top MeasureTheory.extend_eq_top

theorem le_extend {s : α} (h : P s) : m s h ≤ extend m s := by
  simp only [extend, le_infi_iff]
  intro
  rfl
#align measure_theory.le_extend MeasureTheory.le_extend

-- TODO: why this is a bad `congr` lemma?
theorem extend_congr {β : Type _} {Pb : β → Prop} {mb : ∀ s : β, Pb s → ℝ≥0∞} {sa : α} {sb : β}
    (hP : P sa ↔ Pb sb) (hm : ∀ (ha : P sa) (hb : Pb sb), m sa ha = mb sb hb) :
    extend m sa = extend mb sb :=
  infi_congr_Prop hP fun h => hm _ _
#align measure_theory.extend_congr MeasureTheory.extend_congr

end Extend

section ExtendSet

variable {α : Type _} {P : Set α → Prop}

variable {m : ∀ s : Set α, P s → ℝ≥0∞}

variable (P0 : P ∅) (m0 : m ∅ P0 = 0)

variable (PU : ∀ ⦃f : ℕ → Set α⦄ (hm : ∀ i, P (f i)), P (⋃ i, f i))

variable
  (mU :
    ∀ ⦃f : ℕ → Set α⦄ (hm : ∀ i, P (f i)),
      Pairwise (Disjoint on f) → m (⋃ i, f i) (PU hm) = ∑' i, m (f i) (hm i))

variable (msU : ∀ ⦃f : ℕ → Set α⦄ (hm : ∀ i, P (f i)), m (⋃ i, f i) (PU hm) ≤ ∑' i, m (f i) (hm i))

variable (m_mono : ∀ ⦃s₁ s₂ : Set α⦄ (hs₁ : P s₁) (hs₂ : P s₂), s₁ ⊆ s₂ → m s₁ hs₁ ≤ m s₂ hs₂)

theorem extend_empty : extend m ∅ = 0 :=
  (extend_eq _ P0).trans m0
#align measure_theory.extend_empty MeasureTheory.extend_empty

theorem extend_Union_nat {f : ℕ → Set α} (hm : ∀ i, P (f i))
    (mU : m (⋃ i, f i) (PU hm) = ∑' i, m (f i) (hm i)) :
    extend m (⋃ i, f i) = ∑' i, extend m (f i) :=
  (extend_eq _ _).trans <|
    mU.trans <| by 
      congr with i
      rw [extend_eq]
#align measure_theory.extend_Union_nat MeasureTheory.extend_Union_nat

section Subadditive

include PU msU

theorem extend_Union_le_tsum_nat' (s : ℕ → Set α) : extend m (⋃ i, s i) ≤ ∑' i, extend m (s i) := by
  by_cases h : ∀ i, P (s i)
  · rw [extend_eq _ (PU h), congr_arg tsum _]
    · apply msU h
    funext i
    apply extend_eq _ (h i)
  · cases' not_forall.1 h with i hi
    exact le_trans (le_infi fun h => hi.elim h) (Ennreal.le_tsum i)
#align measure_theory.extend_Union_le_tsum_nat' MeasureTheory.extend_Union_le_tsum_nat'

end Subadditive

section Mono

include m_mono

theorem extend_mono' ⦃s₁ s₂ : Set α⦄ (h₁ : P s₁) (hs : s₁ ⊆ s₂) : extend m s₁ ≤ extend m s₂ := by
  refine' le_infi _
  intro h₂
  rw [extend_eq m h₁]
  exact m_mono h₁ h₂ hs
#align measure_theory.extend_mono' MeasureTheory.extend_mono'

end Mono

section Unions

include P0 m0 PU mU

theorem extend_Union {β} [Countable β] {f : β → Set α} (hd : Pairwise (Disjoint on f))
    (hm : ∀ i, P (f i)) : extend m (⋃ i, f i) = ∑' i, extend m (f i) := by
  cases nonempty_encodable β
  rw [← Encodable.Union_decode₂, ← tsum_Union_decode₂]
  ·
    exact
      extend_Union_nat PU (fun n => Encodable.Union_decode₂_cases P0 hm)
        (mU _ (Encodable.Union_decode₂_disjoint_on hd))
  · exact extend_empty P0 m0
#align measure_theory.extend_Union MeasureTheory.extend_Union

theorem extend_union {s₁ s₂ : Set α} (hd : Disjoint s₁ s₂) (h₁ : P s₁) (h₂ : P s₂) :
    extend m (s₁ ∪ s₂) = extend m s₁ + extend m s₂ := by
  rw [union_eq_Union,
    extend_Union P0 m0 PU mU (pairwise_disjoint_on_bool.2 hd) (Bool.forall_bool.2 ⟨h₂, h₁⟩),
    tsum_fintype]
  simp
#align measure_theory.extend_union MeasureTheory.extend_union

end Unions

variable (m)

/-- Given an arbitrary function on a subset of sets, we can define the outer measure corresponding
  to it (this is the unique maximal outer measure that is at most `m` on the domain of `m`). -/
def inducedOuterMeasure : OuterMeasure α :=
  OuterMeasure.ofFunction (extend m) (extend_empty P0 m0)
#align measure_theory.induced_outer_measure MeasureTheory.inducedOuterMeasure

variable {m P0 m0}

theorem le_induced_outer_measure {μ : OuterMeasure α} :
    μ ≤ inducedOuterMeasure m P0 m0 ↔ ∀ (s) (hs : P s), μ s ≤ m s hs :=
  le_of_function.trans <| forall_congr' fun s => le_infi_iff
#align measure_theory.le_induced_outer_measure MeasureTheory.le_induced_outer_measure

/-- If `P u` is `false` for any set `u` that has nonempty intersection both with `s` and `t`, then
`μ (s ∪ t) = μ s + μ t`, where `μ = induced_outer_measure m P0 m0`.

E.g., if `α` is an (e)metric space and `P u = diam u < r`, then this lemma implies that
`μ (s ∪ t) = μ s + μ t` on any two sets such that `r ≤ edist x y` for all `x ∈ s` and `y ∈ t`. -/
theorem induced_outer_measure_union_of_false_of_nonempty_inter {s t : Set α}
    (h : ∀ u, (s ∩ u).Nonempty → (t ∩ u).Nonempty → ¬P u) :
    inducedOuterMeasure m P0 m0 (s ∪ t) =
      inducedOuterMeasure m P0 m0 s + inducedOuterMeasure m P0 m0 t :=
  of_function_union_of_top_of_nonempty_inter fun u hsu htu => @infi_of_empty _ _ _ ⟨h u hsu htu⟩ _
#align
  measure_theory.induced_outer_measure_union_of_false_of_nonempty_inter MeasureTheory.induced_outer_measure_union_of_false_of_nonempty_inter

include msU m_mono

theorem induced_outer_measure_eq_extend' {s : Set α} (hs : P s) :
    inducedOuterMeasure m P0 m0 s = extend m s :=
  of_function_eq s (fun t => extend_mono' m_mono hs) (extend_Union_le_tsum_nat' PU msU)
#align
  measure_theory.induced_outer_measure_eq_extend' MeasureTheory.induced_outer_measure_eq_extend'

theorem induced_outer_measure_eq' {s : Set α} (hs : P s) : inducedOuterMeasure m P0 m0 s = m s hs :=
  (induced_outer_measure_eq_extend' PU msU m_mono hs).trans <| extend_eq _ _
#align measure_theory.induced_outer_measure_eq' MeasureTheory.induced_outer_measure_eq'

theorem induced_outer_measure_eq_infi (s : Set α) :
    inducedOuterMeasure m P0 m0 s = ⨅ (t : Set α) (ht : P t) (h : s ⊆ t), m t ht := by
  apply le_antisymm
  · simp only [le_infi_iff]
    intro t ht hs
    refine' le_trans (mono' _ hs) _
    exact le_of_eq (induced_outer_measure_eq' _ msU m_mono _)
  · refine' le_infi _
    intro f
    refine' le_infi _
    intro hf
    refine' le_trans _ (extend_Union_le_tsum_nat' _ msU _)
    refine' le_infi _
    intro h2f
    refine' infi_le_of_le _ (infi_le_of_le h2f <| infi_le _ hf)
#align measure_theory.induced_outer_measure_eq_infi MeasureTheory.induced_outer_measure_eq_infi

theorem induced_outer_measure_preimage (f : α ≃ α) (Pm : ∀ s : Set α, P (f ⁻¹' s) ↔ P s)
    (mm : ∀ (s : Set α) (hs : P s), m (f ⁻¹' s) ((Pm _).mpr hs) = m s hs) {A : Set α} :
    inducedOuterMeasure m P0 m0 (f ⁻¹' A) = inducedOuterMeasure m P0 m0 A := by
  simp only [induced_outer_measure_eq_infi _ msU m_mono]; symm
  refine' f.injective.preimage_surjective.infi_congr (preimage f) fun s => _
  refine' infi_congr_Prop (Pm s) _; intro hs
  refine' infi_congr_Prop f.surjective.preimage_subset_preimage_iff _
  intro h2s; exact mm s hs
#align measure_theory.induced_outer_measure_preimage MeasureTheory.induced_outer_measure_preimage

theorem induced_outer_measure_exists_set {s : Set α} (hs : inducedOuterMeasure m P0 m0 s ≠ ∞)
    {ε : ℝ≥0∞} (hε : ε ≠ 0) :
    ∃ (t : Set α)(ht : P t),
      s ⊆ t ∧ inducedOuterMeasure m P0 m0 t ≤ inducedOuterMeasure m P0 m0 s + ε :=
  by 
  have := Ennreal.lt_add_right hs hε
  conv at this => 
    lhs
    rw [induced_outer_measure_eq_infi _ msU m_mono]
  simp only [infi_lt_iff] at this
  rcases this with ⟨t, h1t, h2t, h3t⟩
  exact
    ⟨t, h1t, h2t, le_trans (le_of_eq <| induced_outer_measure_eq' _ msU m_mono h1t) (le_of_lt h3t)⟩
#align
  measure_theory.induced_outer_measure_exists_set MeasureTheory.induced_outer_measure_exists_set

/-- To test whether `s` is Carathéodory-measurable we only need to check the sets `t` for which
  `P t` holds. See `of_function_caratheodory` for another way to show the Carathéodory-measurability
  of `s`.
-/
theorem induced_outer_measure_caratheodory (s : Set α) :
    measurable_set[(inducedOuterMeasure m P0 m0).caratheodory] s ↔
      ∀ t : Set α,
        P t →
          inducedOuterMeasure m P0 m0 (t ∩ s) + inducedOuterMeasure m P0 m0 (t \ s) ≤
            inducedOuterMeasure m P0 m0 t :=
  by 
  rw [is_caratheodory_iff_le]
  constructor
  · intro h t ht
    exact h t
  · intro h u
    conv_rhs => rw [induced_outer_measure_eq_infi _ msU m_mono]
    refine' le_infi _
    intro t
    refine' le_infi _
    intro ht
    refine' le_infi _
    intro h2t
    refine' le_trans _ (le_trans (h t ht) <| le_of_eq <| induced_outer_measure_eq' _ msU m_mono ht)
    refine'
      add_le_add (mono' _ <| Set.inter_subset_inter_left _ h2t)
        (mono' _ <| diff_subset_diff_left h2t)
#align
  measure_theory.induced_outer_measure_caratheodory MeasureTheory.induced_outer_measure_caratheodory

end ExtendSet

/-! If `P` is `measurable_set` for some measurable space, then we can remove some hypotheses of the
  above lemmas. -/


section MeasurableSpace

variable {α : Type _} [MeasurableSpace α]

variable {m : ∀ s : Set α, MeasurableSet s → ℝ≥0∞}

variable (m0 : m ∅ MeasurableSet.empty = 0)

variable
  (mU :
    ∀ ⦃f : ℕ → Set α⦄ (hm : ∀ i, MeasurableSet (f i)),
      Pairwise (Disjoint on f) → m (⋃ i, f i) (MeasurableSet.union hm) = ∑' i, m (f i) (hm i))

include m0 mU

theorem extend_mono {s₁ s₂ : Set α} (h₁ : MeasurableSet s₁) (hs : s₁ ⊆ s₂) :
    extend m s₁ ≤ extend m s₂ := by 
  refine' le_infi _; intro h₂
  have := extend_union MeasurableSet.empty m0 MeasurableSet.union mU disjoint_diff h₁ (h₂.diff h₁)
  rw [union_diff_cancel hs] at this
  rw [← extend_eq m]
  exact le_iff_exists_add.2 ⟨_, this⟩
#align measure_theory.extend_mono MeasureTheory.extend_mono

theorem extend_Union_le_tsum_nat : ∀ s : ℕ → Set α, extend m (⋃ i, s i) ≤ ∑' i, extend m (s i) := by
  refine' extend_Union_le_tsum_nat' MeasurableSet.union _; intro f h
  simp (config := { singlePass := true }) [Union_disjointed.symm]
  rw [mU (MeasurableSet.disjointed h) (disjoint_disjointed _)]
  refine' Ennreal.tsum_le_tsum fun i => _
  rw [← extend_eq m, ← extend_eq m]
  exact extend_mono m0 mU (MeasurableSet.disjointed h _) (disjointed_le f _)
#align measure_theory.extend_Union_le_tsum_nat MeasureTheory.extend_Union_le_tsum_nat

theorem induced_outer_measure_eq_extend {s : Set α} (hs : MeasurableSet s) :
    inducedOuterMeasure m MeasurableSet.empty m0 s = extend m s :=
  of_function_eq s (fun t => extend_mono m0 mU hs) (extend_Union_le_tsum_nat m0 mU)
#align measure_theory.induced_outer_measure_eq_extend MeasureTheory.induced_outer_measure_eq_extend

theorem induced_outer_measure_eq {s : Set α} (hs : MeasurableSet s) :
    inducedOuterMeasure m MeasurableSet.empty m0 s = m s hs :=
  (induced_outer_measure_eq_extend m0 mU hs).trans <| extend_eq _ _
#align measure_theory.induced_outer_measure_eq MeasureTheory.induced_outer_measure_eq

end MeasurableSpace

namespace OuterMeasure

variable {α : Type _} [MeasurableSpace α] (m : OuterMeasure α)

/-- Given an outer measure `m` we can forget its value on non-measurable sets, and then consider
  `m.trim`, the unique maximal outer measure less than that function. -/
def trim : OuterMeasure α :=
  inducedOuterMeasure (fun s _ => m s) MeasurableSet.empty m.Empty
#align measure_theory.outer_measure.trim MeasureTheory.OuterMeasure.trim

theorem le_trim : m ≤ m.trim :=
  le_of_function.mpr fun s => le_infi fun _ => le_rfl
#align measure_theory.outer_measure.le_trim MeasureTheory.OuterMeasure.le_trim

theorem trim_eq {s : Set α} (hs : MeasurableSet s) : m.trim s = m s :=
  induced_outer_measure_eq' MeasurableSet.union (fun f hf => m.Union_nat f)
    (fun _ _ _ _ h => m.mono h) hs
#align measure_theory.outer_measure.trim_eq MeasureTheory.OuterMeasure.trim_eq

theorem trim_congr {m₁ m₂ : OuterMeasure α} (H : ∀ {s : Set α}, MeasurableSet s → m₁ s = m₂ s) :
    m₁.trim = m₂.trim := by 
  unfold trim
  congr
  funext s hs
  exact H hs
#align measure_theory.outer_measure.trim_congr MeasureTheory.OuterMeasure.trim_congr

@[mono]
theorem trim_mono : Monotone (trim : OuterMeasure α → OuterMeasure α) := fun m₁ m₂ H s =>
  infi₂_mono fun f hs => Ennreal.tsum_le_tsum fun b => infi_mono fun hf => H _
#align measure_theory.outer_measure.trim_mono MeasureTheory.OuterMeasure.trim_mono

theorem le_trim_iff {m₁ m₂ : OuterMeasure α} : m₁ ≤ m₂.trim ↔ ∀ s, MeasurableSet s → m₁ s ≤ m₂ s :=
  le_of_function.trans <| forall_congr' fun s => le_infi_iff
#align measure_theory.outer_measure.le_trim_iff MeasureTheory.OuterMeasure.le_trim_iff

theorem trim_le_trim_iff {m₁ m₂ : OuterMeasure α} :
    m₁.trim ≤ m₂.trim ↔ ∀ s, MeasurableSet s → m₁ s ≤ m₂ s :=
  le_trim_iff.trans <| forall₂_congr fun s hs => by rw [trim_eq _ hs]
#align measure_theory.outer_measure.trim_le_trim_iff MeasureTheory.OuterMeasure.trim_le_trim_iff

theorem trim_eq_trim_iff {m₁ m₂ : OuterMeasure α} :
    m₁.trim = m₂.trim ↔ ∀ s, MeasurableSet s → m₁ s = m₂ s := by
  simp only [le_antisymm_iff, trim_le_trim_iff, forall_and]
#align measure_theory.outer_measure.trim_eq_trim_iff MeasureTheory.OuterMeasure.trim_eq_trim_iff

theorem trim_eq_infi (s : Set α) : m.trim s = ⨅ (t) (st : s ⊆ t) (ht : MeasurableSet t), m t := by
  simp (config := { singlePass := true }) only [infi_comm]
  exact
    induced_outer_measure_eq_infi MeasurableSet.union (fun f _ => m.Union_nat f)
      (fun _ _ _ _ h => m.mono h) s
#align measure_theory.outer_measure.trim_eq_infi MeasureTheory.OuterMeasure.trim_eq_infi

theorem trim_eq_infi' (s : Set α) : m.trim s = ⨅ t : { t // s ⊆ t ∧ MeasurableSet t }, m t := by
  simp [infi_subtype, infi_and, trim_eq_infi]
#align measure_theory.outer_measure.trim_eq_infi' MeasureTheory.OuterMeasure.trim_eq_infi'

theorem trim_trim (m : OuterMeasure α) : m.trim.trim = m.trim :=
  trim_eq_trim_iff.2 fun s => m.trim_eq
#align measure_theory.outer_measure.trim_trim MeasureTheory.OuterMeasure.trim_trim

@[simp]
theorem trim_zero : (0 : OuterMeasure α).trim = 0 :=
  ext fun s =>
    le_antisymm
      (le_trans ((trim 0).mono (subset_univ s)) <| le_of_eq <| trim_eq _ MeasurableSet.univ)
      (zero_le _)
#align measure_theory.outer_measure.trim_zero MeasureTheory.OuterMeasure.trim_zero

theorem trim_sum_ge {ι} (m : ι → OuterMeasure α) : (sum fun i => (m i).trim) ≤ (sum m).trim :=
  fun s => by
  simp [trim_eq_infi] <;>
    exact fun t st ht =>
      Ennreal.tsum_le_tsum fun i => infi_le_of_le t <| infi_le_of_le st <| infi_le _ ht
#align measure_theory.outer_measure.trim_sum_ge MeasureTheory.OuterMeasure.trim_sum_ge

theorem exists_measurable_superset_eq_trim (m : OuterMeasure α) (s : Set α) :
    ∃ t, s ⊆ t ∧ MeasurableSet t ∧ m t = m.trim s := by
  simp only [trim_eq_infi]; set ms := ⨅ (t : Set α) (st : s ⊆ t) (ht : MeasurableSet t), m t
  by_cases hs : ms = ∞
  · simp only [hs]
    simp only [infi_eq_top] at hs
    exact ⟨univ, subset_univ s, MeasurableSet.univ, hs _ (subset_univ s) MeasurableSet.univ⟩
  · have : ∀ r > ms, ∃ t, s ⊆ t ∧ MeasurableSet t ∧ m t < r := by
      intro r hs
      simpa [infi_lt_iff] using hs
    have : ∀ n : ℕ, ∃ t, s ⊆ t ∧ MeasurableSet t ∧ m t < ms + n⁻¹ := by
      intro n
      refine' this _ (Ennreal.lt_add_right hs _)
      simp
    choose t hsub hm hm'
    refine' ⟨⋂ n, t n, subset_Inter hsub, MeasurableSet.inter hm, _⟩
    have : tendsto (fun n : ℕ => ms + n⁻¹) at_top (𝓝 (ms + 0)) :=
      tendsto_const_nhds.add Ennreal.tendsto_inv_nat_nhds_zero
    rw [add_zero] at this
    refine' le_antisymm ((ge_of_tendsto' this) fun n => _) _
    · exact le_trans (m.mono' <| Inter_subset t n) (hm' n).le
    · refine' infi_le_of_le (⋂ n, t n) _
      refine' infi_le_of_le (subset_Inter hsub) _
      refine' infi_le _ (MeasurableSet.inter hm)
#align
  measure_theory.outer_measure.exists_measurable_superset_eq_trim MeasureTheory.OuterMeasure.exists_measurable_superset_eq_trim

theorem exists_measurable_superset_of_trim_eq_zero {m : OuterMeasure α} {s : Set α}
    (h : m.trim s = 0) : ∃ t, s ⊆ t ∧ MeasurableSet t ∧ m t = 0 := by
  rcases exists_measurable_superset_eq_trim m s with ⟨t, hst, ht, hm⟩
  exact ⟨t, hst, ht, h ▸ hm⟩
#align
  measure_theory.outer_measure.exists_measurable_superset_of_trim_eq_zero MeasureTheory.OuterMeasure.exists_measurable_superset_of_trim_eq_zero

/-- If `μ i` is a countable family of outer measures, then for every set `s` there exists
a measurable set `t ⊇ s` such that `μ i t = (μ i).trim s` for all `i`. -/
theorem exists_measurable_superset_forall_eq_trim {ι} [Countable ι] (μ : ι → OuterMeasure α)
    (s : Set α) : ∃ t, s ⊆ t ∧ MeasurableSet t ∧ ∀ i, μ i t = (μ i).trim s := by
  choose t hst ht hμt using fun i => (μ i).exists_measurable_superset_eq_trim s
  replace hst := subset_Inter hst
  replace ht := MeasurableSet.inter ht
  refine' ⟨⋂ i, t i, hst, ht, fun i => le_antisymm _ _⟩
  exacts[hμt i ▸ (μ i).mono (Inter_subset _ _), (mono' _ hst).trans_eq ((μ i).trim_eq ht)]
#align
  measure_theory.outer_measure.exists_measurable_superset_forall_eq_trim MeasureTheory.OuterMeasure.exists_measurable_superset_forall_eq_trim

/-- If `m₁ s = op (m₂ s) (m₃ s)` for all `s`, then the same is true for `m₁.trim`, `m₂.trim`,
and `m₃ s`. -/
theorem trim_binop {m₁ m₂ m₃ : OuterMeasure α} {op : ℝ≥0∞ → ℝ≥0∞ → ℝ≥0∞}
    (h : ∀ s, m₁ s = op (m₂ s) (m₃ s)) (s : Set α) : m₁.trim s = op (m₂.trim s) (m₃.trim s) := by
  rcases exists_measurable_superset_forall_eq_trim ![m₁, m₂, m₃] s with ⟨t, hst, ht, htm⟩
  simp only [Fin.forall_fin_succ, Matrix.cons_val_zero, Matrix.cons_val_succ] at htm
  rw [← htm.1, ← htm.2.1, ← htm.2.2.1, h]
#align measure_theory.outer_measure.trim_binop MeasureTheory.OuterMeasure.trim_binop

/-- If `m₁ s = op (m₂ s)` for all `s`, then the same is true for `m₁.trim` and `m₂.trim`. -/
theorem trim_op {m₁ m₂ : OuterMeasure α} {op : ℝ≥0∞ → ℝ≥0∞} (h : ∀ s, m₁ s = op (m₂ s))
    (s : Set α) : m₁.trim s = op (m₂.trim s) :=
  @trim_binop α _ m₁ m₂ 0 (fun a b => op a) h s
#align measure_theory.outer_measure.trim_op MeasureTheory.OuterMeasure.trim_op

/-- `trim` is additive. -/
theorem trim_add (m₁ m₂ : OuterMeasure α) : (m₁ + m₂).trim = m₁.trim + m₂.trim :=
  ext <| trim_binop (add_apply m₁ m₂)
#align measure_theory.outer_measure.trim_add MeasureTheory.OuterMeasure.trim_add

/-- `trim` respects scalar multiplication. -/
theorem trim_smul {R : Type _} [HasSmul R ℝ≥0∞] [IsScalarTower R ℝ≥0∞ ℝ≥0∞] (c : R)
    (m : OuterMeasure α) : (c • m).trim = c • m.trim :=
  ext <| trim_op (smul_apply c m)
#align measure_theory.outer_measure.trim_smul MeasureTheory.OuterMeasure.trim_smul

/-- `trim` sends the supremum of two outer measures to the supremum of the trimmed measures. -/
theorem trim_sup (m₁ m₂ : OuterMeasure α) : (m₁ ⊔ m₂).trim = m₁.trim ⊔ m₂.trim :=
  ext fun s => (trim_binop (sup_apply m₁ m₂) s).trans (sup_apply _ _ _).symm
#align measure_theory.outer_measure.trim_sup MeasureTheory.OuterMeasure.trim_sup

/-- `trim` sends the supremum of a countable family of outer measures to the supremum
of the trimmed measures. -/
theorem trim_supr {ι} [Countable ι] (μ : ι → OuterMeasure α) : trim (⨆ i, μ i) = ⨆ i, trim (μ i) :=
  by 
  simp_rw [← @supr_plift_down _ ι]
  ext1 s
  haveI : Countable (Option <| PLift ι) := @Option.countable (PLift ι) _
  obtain ⟨t, hst, ht, hμt⟩ :=
    exists_measurable_superset_forall_eq_trim
      (Option.elim' (⨆ i, μ (PLift.down i)) (μ ∘ PLift.down)) s
  simp only [Option.forall, Option.elim'] at hμt
  simp only [supr_apply, ← hμt.1, ← hμt.2]
#align measure_theory.outer_measure.trim_supr MeasureTheory.OuterMeasure.trim_supr

/-- The trimmed property of a measure μ states that `μ.to_outer_measure.trim = μ.to_outer_measure`.
This theorem shows that a restricted trimmed outer measure is a trimmed outer measure. -/
theorem restrict_trim {μ : OuterMeasure α} {s : Set α} (hs : MeasurableSet s) :
    (restrict s μ).trim = restrict s μ.trim := by
  refine' le_antisymm (fun t => _) (le_trim_iff.2 fun t ht => _)
  · rw [restrict_apply]
    rcases μ.exists_measurable_superset_eq_trim (t ∩ s) with ⟨t', htt', ht', hμt'⟩
    rw [← hμt']
    rw [inter_subset] at htt'
    refine' (mono' _ htt').trans _
    rw [trim_eq _ (hs.compl.union ht'), restrict_apply, union_inter_distrib_right, compl_inter_self,
      Set.empty_union]
    exact μ.mono' (inter_subset_left _ _)
  · rw [restrict_apply, trim_eq _ (ht.inter hs), restrict_apply]
    exact le_rfl
#align measure_theory.outer_measure.restrict_trim MeasureTheory.OuterMeasure.restrict_trim

end OuterMeasure

end MeasureTheory

