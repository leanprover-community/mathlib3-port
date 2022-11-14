/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Devon Tuma
-/
import Mathbin.Probability.ProbabilityMassFunction.Monad

/-!
# Specific Constructions of Probability Mass Functions

This file gives a number of different `pmf` constructions for common probability distributions.

`map` and `seq` allow pushing a `pmf α` along a function `f : α → β` (or distribution of
functions `f : pmf (α → β)`) to get a `pmf β`

`of_finset` and `of_fintype` simplify the construction of a `pmf α` from a function `f : α → ℝ≥0`,
by allowing the "sum equals 1" constraint to be in terms of `finset.sum` instead of `tsum`.

`normalize` constructs a `pmf α` by normalizing a function `f : α → ℝ≥0` by its sum,
and `filter` uses this to filter the support of a `pmf` and re-normalize the new distribution.

`bernoulli` represents the bernoulli distribution on `bool`

-/


namespace Pmf

noncomputable section

variable {α β γ : Type _}

open Classical BigOperators Nnreal Ennreal

section Map

/-- The functorial action of a function on a `pmf`. -/
def map (f : α → β) (p : Pmf α) : Pmf β :=
  bind p (pure ∘ f)
#align pmf.map Pmf.map

variable (f : α → β) (p : Pmf α) (b : β)

theorem monad_map_eq_map {α β : Type _} (f : α → β) (p : Pmf α) : f <$> p = p.map f :=
  rfl
#align pmf.monad_map_eq_map Pmf.monad_map_eq_map

@[simp]
theorem map_apply : (map f p) b = ∑' a, if b = f a then p a else 0 := by simp [map]
#align pmf.map_apply Pmf.map_apply

@[simp]
theorem support_map : (map f p).support = f '' p.support :=
  Set.ext fun b => by simp [map, @eq_comm β b]
#align pmf.support_map Pmf.support_map

theorem mem_support_map_iff : b ∈ (map f p).support ↔ ∃ a ∈ p.support, f a = b := by simp
#align pmf.mem_support_map_iff Pmf.mem_support_map_iff

theorem bind_pure_comp : bind p (pure ∘ f) = map f p :=
  rfl
#align pmf.bind_pure_comp Pmf.bind_pure_comp

theorem map_id : map id p = p := by simp [map]
#align pmf.map_id Pmf.map_id

theorem map_comp (g : β → γ) : (p.map f).map g = p.map (g ∘ f) := by simp [map]
#align pmf.map_comp Pmf.map_comp

theorem pure_map (a : α) : (pure a).map f = pure (f a) := by simp [map]
#align pmf.pure_map Pmf.pure_map

section Measure

variable (s : Set β)

@[simp]
theorem to_outer_measure_map_apply : (p.map f).toOuterMeasure s = p.toOuterMeasure (f ⁻¹' s) := by
  simp [map, Set.indicator, to_outer_measure_apply p (f ⁻¹' s)]
#align pmf.to_outer_measure_map_apply Pmf.to_outer_measure_map_apply

@[simp]
theorem to_measure_map_apply [MeasurableSpace α] [MeasurableSpace β] (hf : Measurable f) (hs : MeasurableSet s) :
    (p.map f).toMeasure s = p.toMeasure (f ⁻¹' s) := by
  rw [to_measure_apply_eq_to_outer_measure_apply _ s hs,
    to_measure_apply_eq_to_outer_measure_apply _ (f ⁻¹' s) (measurableSetPreimage hf hs)]
  exact to_outer_measure_map_apply f p s
#align pmf.to_measure_map_apply Pmf.to_measure_map_apply

end Measure

end Map

section Seq

/-- The monadic sequencing operation for `pmf`. -/
def seq (q : Pmf (α → β)) (p : Pmf α) : Pmf β :=
  q.bind fun m => p.bind fun a => pure (m a)
#align pmf.seq Pmf.seq

variable (q : Pmf (α → β)) (p : Pmf α) (b : β)

theorem monad_seq_eq_seq {α β : Type _} (q : Pmf (α → β)) (p : Pmf α) : q <*> p = q.seq p :=
  rfl
#align pmf.monad_seq_eq_seq Pmf.monad_seq_eq_seq

@[simp]
theorem seq_apply : (seq q p) b = ∑' (f : α → β) (a : α), if b = f a then q f * p a else 0 := by
  simp only [seq, mul_boole, bind_apply, pure_apply]
  refine' tsum_congr fun f => (Nnreal.tsum_mul_left (q f) _).symm.trans (tsum_congr fun a => _)
  simpa only [mul_zero] using mul_ite (b = f a) (q f) (p a) 0
#align pmf.seq_apply Pmf.seq_apply

@[simp]
theorem support_seq : (seq q p).support = ⋃ f ∈ q.support, f '' p.support :=
  Set.ext fun b => by simp [-mem_support_iff, seq, @eq_comm β b]
#align pmf.support_seq Pmf.support_seq

theorem mem_support_seq_iff : b ∈ (seq q p).support ↔ ∃ f ∈ q.support, b ∈ f '' p.support := by simp
#align pmf.mem_support_seq_iff Pmf.mem_support_seq_iff

end Seq

instance : IsLawfulFunctor Pmf where
  map_const_eq α β := rfl
  id_map α := bind_pure
  comp_map α β γ g h x := (map_comp _ _ _).symm

instance : LawfulMonad Pmf where
  bind_pure_comp_eq_map α β f x := rfl
  bind_map_eq_seq α β f x := rfl
  pure_bind α β := pure_bind
  bind_assoc α β γ := bind_bind

section OfFinset

/- ./././Mathport/Syntax/Translate/Basic.lean:610:2: warning: expanding binder collection (a «expr ∉ » s) -/
/-- Given a finset `s` and a function `f : α → ℝ≥0` with sum `1` on `s`,
  such that `f a = 0` for `a ∉ s`, we get a `pmf` -/
def ofFinset (f : α → ℝ≥0) (s : Finset α) (h : (∑ a in s, f a) = 1) (h' : ∀ (a) (_ : a ∉ s), f a = 0) : Pmf α :=
  ⟨f, h ▸ has_sum_sum_of_ne_finset_zero h'⟩
#align pmf.of_finset Pmf.ofFinset

/- ./././Mathport/Syntax/Translate/Basic.lean:610:2: warning: expanding binder collection (a «expr ∉ » s) -/
variable {f : α → ℝ≥0} {s : Finset α} (h : (∑ a in s, f a) = 1) (h' : ∀ (a) (_ : a ∉ s), f a = 0)

@[simp]
theorem of_finset_apply (a : α) : ofFinset f s h h' a = f a :=
  rfl
#align pmf.of_finset_apply Pmf.of_finset_apply

@[simp]
theorem support_of_finset : (ofFinset f s h h').support = s ∩ Function.support f :=
  Set.ext fun a => by simpa [mem_support_iff] using mt (h' a)
#align pmf.support_of_finset Pmf.support_of_finset

theorem mem_support_of_finset_iff (a : α) : a ∈ (ofFinset f s h h').support ↔ a ∈ s ∧ f a ≠ 0 := by simp
#align pmf.mem_support_of_finset_iff Pmf.mem_support_of_finset_iff

theorem of_finset_apply_of_not_mem {a : α} (ha : a ∉ s) : ofFinset f s h h' a = 0 :=
  h' a ha
#align pmf.of_finset_apply_of_not_mem Pmf.of_finset_apply_of_not_mem

section Measure

variable (t : Set α)

@[simp]
theorem to_outer_measure_of_finset_apply : (ofFinset f s h h').toOuterMeasure t = ↑(∑' x, t.indicator f x) :=
  to_outer_measure_apply' (ofFinset f s h h') t
#align pmf.to_outer_measure_of_finset_apply Pmf.to_outer_measure_of_finset_apply

@[simp]
theorem to_measure_of_finset_apply [MeasurableSpace α] (ht : MeasurableSet t) :
    (ofFinset f s h h').toMeasure t = ↑(∑' x, t.indicator f x) :=
  (to_measure_apply_eq_to_outer_measure_apply _ t ht).trans (to_outer_measure_of_finset_apply h h' t)
#align pmf.to_measure_of_finset_apply Pmf.to_measure_of_finset_apply

end Measure

end OfFinset

section OfFintype

/-- Given a finite type `α` and a function `f : α → ℝ≥0` with sum 1, we get a `pmf`. -/
def ofFintype [Fintype α] (f : α → ℝ≥0) (h : (∑ a, f a) = 1) : Pmf α :=
  ofFinset f Finset.univ h fun a ha => absurd (Finset.mem_univ a) ha
#align pmf.of_fintype Pmf.ofFintype

variable [Fintype α] {f : α → ℝ≥0} (h : (∑ a, f a) = 1)

@[simp]
theorem of_fintype_apply (a : α) : ofFintype f h a = f a :=
  rfl
#align pmf.of_fintype_apply Pmf.of_fintype_apply

@[simp]
theorem support_of_fintype : (ofFintype f h).support = Function.support f :=
  rfl
#align pmf.support_of_fintype Pmf.support_of_fintype

theorem mem_support_of_fintype_iff (a : α) : a ∈ (ofFintype f h).support ↔ f a ≠ 0 :=
  Iff.rfl
#align pmf.mem_support_of_fintype_iff Pmf.mem_support_of_fintype_iff

section Measure

variable (s : Set α)

@[simp]
theorem to_outer_measure_of_fintype_apply : (ofFintype f h).toOuterMeasure s = ↑(∑' x, s.indicator f x) :=
  to_outer_measure_apply' (ofFintype f h) s
#align pmf.to_outer_measure_of_fintype_apply Pmf.to_outer_measure_of_fintype_apply

@[simp]
theorem to_measure_of_fintype_apply [MeasurableSpace α] (hs : MeasurableSet s) :
    (ofFintype f h).toMeasure s = ↑(∑' x, s.indicator f x) :=
  (to_measure_apply_eq_to_outer_measure_apply _ s hs).trans (to_outer_measure_of_fintype_apply h s)
#align pmf.to_measure_of_fintype_apply Pmf.to_measure_of_fintype_apply

end Measure

end OfFintype

section normalize

/-- Given a `f` with non-zero sum, we get a `pmf` by normalizing `f` by it's `tsum` -/
def normalize (f : α → ℝ≥0) (hf0 : tsum f ≠ 0) : Pmf α :=
  ⟨fun a => f a * (∑' x, f x)⁻¹,
    mul_inv_cancel hf0 ▸
      HasSum.mul_right (∑' x, f x)⁻¹ (not_not.mp (mt tsum_eq_zero_of_not_summable hf0 : ¬¬Summable f)).HasSum⟩
#align pmf.normalize Pmf.normalize

variable {f : α → ℝ≥0} (hf0 : tsum f ≠ 0)

@[simp]
theorem normalize_apply (a : α) : (normalize f hf0) a = f a * (∑' x, f x)⁻¹ :=
  rfl
#align pmf.normalize_apply Pmf.normalize_apply

@[simp]
theorem support_normalize : (normalize f hf0).support = Function.support f :=
  Set.ext (by simp [mem_support_iff, hf0])
#align pmf.support_normalize Pmf.support_normalize

theorem mem_support_normalize_iff (a : α) : a ∈ (normalize f hf0).support ↔ f a ≠ 0 := by simp
#align pmf.mem_support_normalize_iff Pmf.mem_support_normalize_iff

end normalize

section Filter

/-- Create new `pmf` by filtering on a set with non-zero measure and normalizing -/
def filter (p : Pmf α) (s : Set α) (h : ∃ a ∈ s, a ∈ p.support) : Pmf α :=
  Pmf.normalize (s.indicator p) <| Nnreal.tsum_indicator_ne_zero p.2.Summable h
#align pmf.filter Pmf.filter

variable {p : Pmf α} {s : Set α} (h : ∃ a ∈ s, a ∈ p.support)

@[simp]
theorem filter_apply (a : α) : (p.filter s h) a = s.indicator p a * (∑' a', (s.indicator p) a')⁻¹ := by
  rw [Filter, normalize_apply]
#align pmf.filter_apply Pmf.filter_apply

theorem filter_apply_eq_zero_of_not_mem {a : α} (ha : a ∉ s) : (p.filter s h) a = 0 := by
  rw [filter_apply, set.indicator_apply_eq_zero.mpr fun ha' => absurd ha' ha, zero_mul]
#align pmf.filter_apply_eq_zero_of_not_mem Pmf.filter_apply_eq_zero_of_not_mem

theorem mem_support_filter_iff {a : α} : a ∈ (p.filter s h).support ↔ a ∈ s ∧ a ∈ p.support :=
  (mem_support_normalize_iff _ _).trans Set.indicator_apply_ne_zero
#align pmf.mem_support_filter_iff Pmf.mem_support_filter_iff

@[simp]
theorem support_filter : (p.filter s h).support = s ∩ p.support :=
  Set.ext fun x => mem_support_filter_iff _
#align pmf.support_filter Pmf.support_filter

theorem filter_apply_eq_zero_iff (a : α) : (p.filter s h) a = 0 ↔ a ∉ s ∨ a ∉ p.support := by
  erw [apply_eq_zero_iff, support_filter, Set.mem_inter_iff, not_and_or]
#align pmf.filter_apply_eq_zero_iff Pmf.filter_apply_eq_zero_iff

theorem filter_apply_ne_zero_iff (a : α) : (p.filter s h) a ≠ 0 ↔ a ∈ s ∧ a ∈ p.support := by
  rw [Ne.def, filter_apply_eq_zero_iff, not_or, not_not, not_not]
#align pmf.filter_apply_ne_zero_iff Pmf.filter_apply_ne_zero_iff

end Filter

section Bernoulli

/-- A `pmf` which assigns probability `p` to `tt` and `1 - p` to `ff`. -/
def bernoulli (p : ℝ≥0) (h : p ≤ 1) : Pmf Bool :=
  ofFintype (fun b => cond b p (1 - p)) (Nnreal.eq <| by simp [h])
#align pmf.bernoulli Pmf.bernoulli

variable {p : ℝ≥0} (h : p ≤ 1) (b : Bool)

@[simp]
theorem bernoulli_apply : bernoulli p h b = cond b p (1 - p) :=
  rfl
#align pmf.bernoulli_apply Pmf.bernoulli_apply

@[simp]
theorem support_bernoulli : (bernoulli p h).support = { b | cond b (p ≠ 0) (p ≠ 1) } := by
  refine' Set.ext fun b => _
  induction b
  · simp_rw [mem_support_iff, bernoulli_apply, Bool.cond_false, Ne.def, tsub_eq_zero_iff_le, not_le]
    exact ⟨ne_of_lt, lt_of_le_of_ne h⟩
    
  · simp only [mem_support_iff, bernoulli_apply, Bool.cond_true, Set.mem_set_of_eq]
    
#align pmf.support_bernoulli Pmf.support_bernoulli

theorem mem_support_bernoulli_iff : b ∈ (bernoulli p h).support ↔ cond b (p ≠ 0) (p ≠ 1) := by simp
#align pmf.mem_support_bernoulli_iff Pmf.mem_support_bernoulli_iff

end Bernoulli

end Pmf

