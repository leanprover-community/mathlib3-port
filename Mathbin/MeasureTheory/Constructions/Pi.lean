/-
Copyright (c) 2020 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn
-/
import Mathbin.MeasureTheory.Constructions.Prod
import Mathbin.MeasureTheory.Group.Measure

/-!
# Product measures

In this file we define and prove properties about finite products of measures
(and at some point, countable products of measures).

## Main definition

* `measure_theory.measure.pi`: The product of finitely many σ-finite measures.
  Given `μ : Π i : ι, measure (α i)` for `[fintype ι]` it has type `measure (Π i : ι, α i)`.

To apply Fubini along some subset of the variables, use
`measure_theory.measure.map_pi_equiv_pi_subtype_prod` to reduce to the situation of a product
of two measures: this lemma states that the bijection `equiv.pi_equiv_pi_subtype_prod p α`
between `(Π i : ι, α i)` and `(Π i : {i // p i}, α i) × (Π i : {i // ¬ p i}, α i)` maps a product
measure to a direct product of product measures, to which one can apply the usual Fubini for
direct product of measures.

## Implementation Notes

We define `measure_theory.outer_measure.pi`, the product of finitely many outer measures, as the
maximal outer measure `n` with the property that `n (pi univ s) ≤ ∏ i, m i (s i)`,
where `pi univ s` is the product of the sets `{s i | i : ι}`.

We then show that this induces a product of measures, called `measure_theory.measure.pi`.
For a collection of σ-finite measures `μ` and a collection of measurable sets `s` we show that
`measure.pi μ (pi univ s) = ∏ i, m i (s i)`. To do this, we follow the following steps:
* We know that there is some ordering on `ι`, given by an element of `[encodable ι]`.
* Using this, we have an equivalence `measurable_equiv.pi_measurable_equiv_tprod` between
  `Π ι, α i` and an iterated product of `α i`, called `list.tprod α l` for some list `l`.
* On this iterated product we can easily define a product measure `measure_theory.measure.tprod`
  by iterating `measure_theory.measure.prod`
* Using the previous two steps we construct `measure_theory.measure.pi'` on `Π ι, α i` for encodable
  `ι`.
* We know that `measure_theory.measure.pi'` sends products of sets to products of measures, and
  since `measure_theory.measure.pi` is the maximal such measure (or at least, it comes from an outer
  measure which is the maximal such outer measure), we get the same rule for
  `measure_theory.measure.pi`.

## Tags

finitary product measure

-/


noncomputable section

open Function Set MeasureTheory.OuterMeasure Filter MeasurableSpace Encodable

open_locale Classical BigOperators TopologicalSpace Ennreal

universe u v

variable {ι ι' : Type _} {α : ι → Type _}

/-! We start with some measurability properties -/


/-- Boxes formed by π-systems form a π-system. -/
theorem IsPiSystem.pi {C : ∀ i, Set (Set (α i))} (hC : ∀ i, IsPiSystem (C i)) : IsPiSystem (pi Univ '' pi Univ C) := by
  rintro _ ⟨s₁, hs₁, rfl⟩ _ ⟨s₂, hs₂, rfl⟩ hst
  rw [← pi_inter_distrib] at hst⊢
  rw [univ_pi_nonempty_iff] at hst
  exact mem_image_of_mem _ fun i _ => hC i _ (hs₁ i (mem_univ i)) _ (hs₂ i (mem_univ i)) (hst i)

/-- Boxes form a π-system. -/
theorem is_pi_system_pi [∀ i, MeasurableSpace (α i)] :
    IsPiSystem (pi Univ '' pi Univ fun i => { s : Set (α i) | MeasurableSet s }) :=
  IsPiSystem.pi fun i => is_pi_system_measurable_set

variable [Fintype ι] [Fintype ι']

/-- Boxes of countably spanning sets are countably spanning. -/
theorem IsCountablySpanning.pi {C : ∀ i, Set (Set (α i))} (hC : ∀ i, IsCountablySpanning (C i)) :
    IsCountablySpanning (pi Univ '' pi Univ C) := by
  choose s h1s h2s using hC
  have := Fintype.encodable ι
  let e : ℕ → ι → ℕ := fun n => (decode (ι → ℕ) n).iget
  refine' ⟨fun n => pi univ fun i => s i (e n i), fun n => mem_image_of_mem _ fun i _ => h1s i _, _⟩
  simp_rw [(surjective_decode_iget (ι → ℕ)).Union_comp fun x => pi univ fun i => s i (x i), Union_univ_pi s, h2s,
    pi_univ]

/-- The product of generated σ-algebras is the one generated by boxes, if both generating sets
  are countably spanning. -/
theorem generate_from_pi_eq {C : ∀ i, Set (Set (α i))} (hC : ∀ i, IsCountablySpanning (C i)) :
    (@MeasurableSpace.pi _ _ fun i => generateFrom (C i)) = generateFrom (pi Univ '' pi Univ C) := by
  have := Fintype.encodable ι
  apply le_antisymmₓ
  · refine' supr_le _
    intro i
    rw [comap_generate_from]
    apply generate_from_le
    rintro _ ⟨s, hs, rfl⟩
    dsimp
    choose t h1t h2t using hC
    simp_rw [eval_preimage, ← h2t]
    rw [← @Union_const _ ℕ _ s]
    have :
      pi univ (update (fun i' : ι => Union (t i')) i (⋃ i' : ℕ, s)) =
        pi univ fun k => ⋃ j : ℕ, @update ι (fun i' => Set (α i')) _ (fun i' => t i' j) i s k :=
      by
      ext
      simp_rw [mem_univ_pi]
      apply forall_congrₓ
      intro i'
      by_cases' i' = i
      · subst h
        simp
        
      · rw [← Ne.def] at h
        simp [h]
        
    rw [this, ← Union_univ_pi]
    apply MeasurableSet.Union
    intro n
    apply measurable_set_generate_from
    apply mem_image_of_mem
    intro j _
    dsimp only
    by_cases' h : j = i
    subst h
    rwa [update_same]
    rw [update_noteq h]
    apply h1t
    
  · apply generate_from_le
    rintro _ ⟨s, hs, rfl⟩
    rw [univ_pi_eq_Inter]
    apply MeasurableSet.Inter
    intro i
    apply measurable_pi_apply
    exact measurable_set_generate_from (hs i (mem_univ i))
    

/-- If `C` and `D` generate the σ-algebras on `α` resp. `β`, then rectangles formed by `C` and `D`
  generate the σ-algebra on `α × β`. -/
theorem generate_from_eq_pi [h : ∀ i, MeasurableSpace (α i)] {C : ∀ i, Set (Set (α i))}
    (hC : ∀ i, generateFrom (C i) = h i) (h2C : ∀ i, IsCountablySpanning (C i)) :
    generateFrom (pi Univ '' pi Univ C) = MeasurableSpace.pi := by
  rw [← funext hC, generate_from_pi_eq h2C]

/-- The product σ-algebra is generated from boxes, i.e. `s ×ˢ t` for sets `s : set α` and
  `t : set β`. -/
theorem generate_from_pi [∀ i, MeasurableSpace (α i)] :
    generateFrom (pi Univ '' pi Univ fun i => { s : Set (α i) | MeasurableSet s }) = MeasurableSpace.pi :=
  generate_from_eq_pi (fun i => generate_from_measurable_set) fun i => is_countably_spanning_measurable_set

namespace MeasureTheory

variable {m : ∀ i, OuterMeasure (α i)}

/-- An upper bound for the measure in a finite product space.
  It is defined to by taking the image of the set under all projections, and taking the product
  of the measures of these images.
  For measurable boxes it is equal to the correct measure. -/
@[simp]
def piPremeasure (m : ∀ i, OuterMeasure (α i)) (s : Set (∀ i, α i)) : ℝ≥0∞ :=
  ∏ i, m i (eval i '' s)

theorem pi_premeasure_pi {s : ∀ i, Set (α i)} (hs : (pi Univ s).Nonempty) :
    piPremeasure m (pi Univ s) = ∏ i, m i (s i) := by
  simp [hs]

theorem pi_premeasure_pi' [Nonempty ι] {s : ∀ i, Set (α i)} : piPremeasure m (pi Univ s) = ∏ i, m i (s i) := by
  cases' (pi univ s).eq_empty_or_nonempty with h h
  · rcases univ_pi_eq_empty_iff.mp h with ⟨i, hi⟩
    have : ∃ i, m i (s i) = 0 :=
      ⟨i, by
        simp [hi]⟩
    simpa [h, Finset.card_univ, zero_pow (fintype.card_pos_iff.mpr ‹_›), @eq_comm _ (0 : ℝ≥0∞), Finset.prod_eq_zero_iff]
    
  · simp [h]
    

theorem pi_premeasure_pi_mono {s t : Set (∀ i, α i)} (h : s ⊆ t) : piPremeasure m s ≤ piPremeasure m t :=
  Finset.prod_le_prod' fun i _ => (m i).mono' (image_subset _ h)

theorem pi_premeasure_pi_eval [Nonempty ι] {s : Set (∀ i, α i)} :
    piPremeasure m (pi Univ fun i => eval i '' s) = piPremeasure m s := by
  simp [pi_premeasure_pi']

namespace OuterMeasure

/-- `outer_measure.pi m` is the finite product of the outer measures `{m i | i : ι}`.
  It is defined to be the maximal outer measure `n` with the property that
  `n (pi univ s) ≤ ∏ i, m i (s i)`, where `pi univ s` is the product of the sets
  `{s i | i : ι}`. -/
protected def pi (m : ∀ i, OuterMeasure (α i)) : OuterMeasure (∀ i, α i) :=
  boundedBy (piPremeasure m)

theorem pi_pi_le (m : ∀ i, OuterMeasure (α i)) (s : ∀ i, Set (α i)) : OuterMeasure.pi m (pi Univ s) ≤ ∏ i, m i (s i) :=
  by
  cases' (pi univ s).eq_empty_or_nonempty with h h
  simp [h]
  exact (bounded_by_le _).trans_eq (pi_premeasure_pi h)

theorem le_pi {m : ∀ i, OuterMeasure (α i)} {n : OuterMeasure (∀ i, α i)} :
    n ≤ OuterMeasure.pi m ↔ ∀ s : ∀ i, Set (α i), (pi Univ s).Nonempty → n (pi Univ s) ≤ ∏ i, m i (s i) := by
  rw [outer_measure.pi, le_bounded_by']
  constructor
  · intro h s hs
    refine' (h _ hs).trans_eq (pi_premeasure_pi hs)
    
  · intro h s hs
    refine' le_transₓ (n.mono <| subset_pi_eval_image univ s) (h _ _)
    simp [univ_pi_nonempty_iff, hs]
    

end OuterMeasure

namespace Measureₓ

variable [∀ i, MeasurableSpace (α i)] (μ : ∀ i, Measure (α i))

section Tprod

open List

variable {δ : Type _} {π : δ → Type _} [∀ x, MeasurableSpace (π x)]

/-- A product of measures in `tprod α l`. -/
-- for some reason the equation compiler doesn't like this definition
protected def tprod (l : List δ) (μ : ∀ i, Measure (π i)) : Measure (Tprod π l) := by
  induction' l with i l ih
  exact dirac PUnit.unit
  exact (μ i).Prod ih

@[simp]
theorem tprod_nil (μ : ∀ i, Measure (π i)) : Measure.tprod [] μ = dirac PUnit.unit :=
  rfl

@[simp]
theorem tprod_cons (i : δ) (l : List δ) (μ : ∀ i, Measure (π i)) :
    Measure.tprod (i :: l) μ = (μ i).Prod (Measure.tprod l μ) :=
  rfl

instance sigma_finite_tprod (l : List δ) (μ : ∀ i, Measure (π i)) [∀ i, SigmaFinite (μ i)] :
    SigmaFinite (Measure.tprod l μ) := by
  induction' l with i l ih
  · rw [tprod_nil]
    infer_instance
    
  · rw [tprod_cons]
    skip
    infer_instance
    

theorem tprod_tprod (l : List δ) (μ : ∀ i, Measure (π i)) [∀ i, SigmaFinite (μ i)] (s : ∀ i, Set (π i)) :
    Measure.tprod l μ (Set.Tprodₓ l s) = (l.map fun i => (μ i) (s i)).Prod := by
  induction' l with i l ih
  · simp
    
  rw [tprod_cons, Set.Tprodₓ, prod_prod, map_cons, prod_cons, ih]

end Tprod

section Encodable

open List MeasurableEquiv

variable [Encodable ι]

/-- The product measure on an encodable finite type, defined by mapping `measure.tprod` along the
  equivalence `measurable_equiv.pi_measurable_equiv_tprod`.
  The definition `measure_theory.measure.pi` should be used instead of this one. -/
def pi' : Measure (∀ i, α i) :=
  Measure.map (Tprod.elim' mem_sorted_univ) (Measure.tprod (sortedUniv ι) μ)

theorem pi'_pi [∀ i, SigmaFinite (μ i)] (s : ∀ i, Set (α i)) : pi' μ (pi Univ s) = ∏ i, μ i (s i) := by
  rw [pi', ← MeasurableEquiv.pi_measurable_equiv_tprod_symm_apply, MeasurableEquiv.map_apply,
      MeasurableEquiv.pi_measurable_equiv_tprod_symm_apply, elim_preimage_pi, tprod_tprod _ μ, ← List.prod_to_finset,
      sorted_univ_to_finset] <;>
    exact sorted_univ_nodup ι

end Encodable

theorem pi_caratheodory : MeasurableSpace.pi ≤ (OuterMeasure.pi fun i => (μ i).toOuterMeasure).caratheodory := by
  refine' supr_le _
  intro i s hs
  rw [MeasurableSpace.comap] at hs
  rcases hs with ⟨s, hs, rfl⟩
  apply bounded_by_caratheodory
  intro t
  simp_rw [pi_premeasure]
  refine' Finset.prod_add_prod_le' (Finset.mem_univ i) _ _ _
  · simp [image_inter_preimage, image_diff_preimage, measure_inter_add_diff _ hs, le_reflₓ]
    
  · rintro j - hj
    apply mono'
    apply image_subset
    apply inter_subset_left
    
  · rintro j - hj
    apply mono'
    apply image_subset
    apply diff_subset
    

/-- `measure.pi μ` is the finite product of the measures `{μ i | i : ι}`.
  It is defined to be measure corresponding to `measure_theory.outer_measure.pi`. -/
protected irreducible_def pi : Measure (∀ i, α i) :=
  toMeasure (OuterMeasure.pi fun i => (μ i).toOuterMeasure) (pi_caratheodory μ)

theorem pi_pi_aux [∀ i, SigmaFinite (μ i)] (s : ∀ i, Set (α i)) (hs : ∀ i, MeasurableSet (s i)) :
    Measure.pi μ (pi Univ s) = ∏ i, μ i (s i) := by
  refine' le_antisymmₓ _ _
  · rw [measure.pi, to_measure_apply _ _ (MeasurableSet.pi_fintype fun i _ => hs i)]
    apply outer_measure.pi_pi_le
    
  · have : Encodable ι := Fintype.encodable ι
    rw [← pi'_pi μ s]
    simp_rw [← pi'_pi μ s, measure.pi, to_measure_apply _ _ (MeasurableSet.pi_fintype fun i _ => hs i), ←
      to_outer_measure_apply]
    suffices (pi' μ).toOuterMeasure ≤ outer_measure.pi fun i => (μ i).toOuterMeasure by
      exact this _
    clear hs s
    rw [outer_measure.le_pi]
    intro s hs
    simp_rw [to_outer_measure_apply]
    exact (pi'_pi μ s).le
    

variable {μ}

/-- `measure.pi μ` has finite spanning sets in rectangles of finite spanning sets. -/
def FiniteSpanningSetsIn.pi {C : ∀ i, Set (Set (α i))} (hμ : ∀ i, (μ i).FiniteSpanningSetsIn (C i)) :
    (Measure.pi μ).FiniteSpanningSetsIn (pi Univ '' pi Univ C) := by
  have := fun i => (hμ i).SigmaFinite
  have := Fintype.encodable ι
  let e : ℕ → ι → ℕ := fun n => (decode (ι → ℕ) n).iget
  refine' ⟨fun n => pi univ fun i => (hμ i).Set (e n i), fun n => _, fun n => _, _⟩
  · refine' mem_image_of_mem _ fun i _ => (hμ i).set_mem _
    
  · calc
      measure.pi μ (pi univ fun i => (hμ i).Set (e n i)) ≤
          measure.pi μ (pi univ fun i => to_measurable (μ i) ((hμ i).Set (e n i))) :=
        measure_mono
          (pi_mono fun i hi => subset_to_measurable _ _)_ = ∏ i, μ i (to_measurable (μ i) ((hμ i).Set (e n i))) :=
        pi_pi_aux μ _ fun i => measurable_set_to_measurable _ _ _ = ∏ i, μ i ((hμ i).Set (e n i)) := by
        simp only [measure_to_measurable]_ < ∞ := Ennreal.prod_lt_top fun i hi => ((hμ i).Finite _).Ne
    
  · simp_rw [(surjective_decode_iget (ι → ℕ)).Union_comp fun x => pi univ fun i => (hμ i).Set (x i),
      Union_univ_pi fun i => (hμ i).Set, (hμ _).spanning, Set.pi_univ]
    

/-- A measure on a finite product space equals the product measure if they are equal on rectangles
  with as sides sets that generate the corresponding σ-algebras. -/
theorem pi_eq_generate_from {C : ∀ i, Set (Set (α i))} (hC : ∀ i, generateFrom (C i) = _inst_3 i)
    (h2C : ∀ i, IsPiSystem (C i)) (h3C : ∀ i, (μ i).FiniteSpanningSetsIn (C i)) {μν : Measure (∀ i, α i)}
    (h₁ : ∀ s : ∀ i, Set (α i), (∀ i, s i ∈ C i) → μν (pi Univ s) = ∏ i, μ i (s i)) : Measure.pi μ = μν := by
  have h4C : ∀ i s : Set (α i), s ∈ C i → MeasurableSet s := by
    intro i s hs
    rw [← hC]
    exact measurable_set_generate_from hs
  refine'
    (finite_spanning_sets_in.pi h3C).ext (generate_from_eq_pi hC fun i => (h3C i).IsCountablySpanning).symm
      (IsPiSystem.pi h2C) _
  rintro _ ⟨s, hs, rfl⟩
  rw [mem_univ_pi] at hs
  have := fun i => (h3C i).SigmaFinite
  simp_rw [h₁ s hs, pi_pi_aux μ s fun i => h4C i _ (hs i)]

variable [∀ i, SigmaFinite (μ i)]

/-- A measure on a finite product space equals the product measure if they are equal on
  rectangles. -/
theorem pi_eq {μ' : Measure (∀ i, α i)}
    (h : ∀ s : ∀ i, Set (α i), (∀ i, MeasurableSet (s i)) → μ' (pi Univ s) = ∏ i, μ i (s i)) : Measure.pi μ = μ' :=
  pi_eq_generate_from (fun i => generate_from_measurable_set) (fun i => is_pi_system_measurable_set)
    (fun i => (μ i).toFiniteSpanningSetsIn) h

variable (μ)

theorem pi'_eq_pi [Encodable ι] : pi' μ = Measure.pi μ :=
  Eq.symm <| pi_eq fun s hs => pi'_pi μ s

@[simp]
theorem pi_pi (s : ∀ i, Set (α i)) : Measure.pi μ (pi Univ s) = ∏ i, μ i (s i) := by
  have : Encodable ι := Fintype.encodable ι
  rw [← pi'_eq_pi, pi'_pi]

theorem pi_univ : Measure.pi μ Univ = ∏ i, μ i Univ := by
  rw [← pi_univ, pi_pi μ]

theorem pi_ball [∀ i, MetricSpace (α i)] (x : ∀ i, α i) {r : ℝ} (hr : 0 < r) :
    Measure.pi μ (Metric.Ball x r) = ∏ i, μ i (Metric.Ball (x i) r) := by
  rw [ball_pi _ hr, pi_pi]

theorem pi_closed_ball [∀ i, MetricSpace (α i)] (x : ∀ i, α i) {r : ℝ} (hr : 0 ≤ r) :
    Measure.pi μ (Metric.ClosedBall x r) = ∏ i, μ i (Metric.ClosedBall (x i) r) := by
  rw [closed_ball_pi _ hr, pi_pi]

instance pi.sigma_finite : SigmaFinite (Measure.pi μ) :=
  (FiniteSpanningSetsIn.pi fun i => (μ i).toFiniteSpanningSetsIn).SigmaFinite

theorem pi_of_empty {α : Type _} [IsEmpty α] {β : α → Type _} {m : ∀ a, MeasurableSpace (β a)}
    (μ : ∀ a : α, Measure (β a)) (x : ∀ a, β a := isEmptyElim) : Measure.pi μ = dirac x := by
  have : ∀ a, sigma_finite (μ a) := isEmptyElim
  refine' pi_eq fun s hs => _
  rw [Fintype.prod_empty, dirac_apply_of_mem]
  exact isEmptyElim

theorem pi_eval_preimage_null {i : ι} {s : Set (α i)} (hs : μ i s = 0) : Measure.pi μ (eval i ⁻¹' s) = 0 := by
  -- WLOG, `s` is measurable
  rcases exists_measurable_superset_of_null hs with ⟨t, hst, htm, hμt⟩
  suffices : measure.pi μ (eval i ⁻¹' t) = 0
  exact measure_mono_null (preimage_mono hst) this
  clear! s
  -- Now rewrite it as `set.pi`, and apply `pi_pi`
  rw [← univ_pi_update_univ, pi_pi]
  apply Finset.prod_eq_zero (Finset.mem_univ i)
  simp [hμt]

theorem pi_hyperplane (i : ι) [HasNoAtoms (μ i)] (x : α i) : Measure.pi μ { f : ∀ i, α i | f i = x } = 0 :=
  show Measure.pi μ (eval i ⁻¹' {x}) = 0 from pi_eval_preimage_null _ (measure_singleton x)

theorem ae_eval_ne (i : ι) [HasNoAtoms (μ i)] (x : α i) : ∀ᵐ y : ∀ i, α i ∂Measure.pi μ, y i ≠ x :=
  compl_mem_ae_iff.2 (pi_hyperplane μ i x)

variable {μ}

theorem tendsto_eval_ae_ae {i : ι} : Tendsto (eval i) (Measure.pi μ).ae (μ i).ae := fun s hs =>
  pi_eval_preimage_null μ hs

theorem ae_pi_le_pi : (Measure.pi μ).ae ≤ Filter.pi fun i => (μ i).ae :=
  le_infi fun i => tendsto_eval_ae_ae.le_comap

theorem ae_eq_pi {β : ι → Type _} {f f' : ∀ i, α i → β i} (h : ∀ i, f i =ᵐ[μ i] f' i) :
    (fun i => f i (x i)) =ᵐ[Measure.pi μ] fun x i => f' i (x i) :=
  (eventually_all.2 fun i => tendsto_eval_ae_ae.Eventually (h i)).mono fun x hx => funext hx

theorem ae_le_pi {β : ι → Type _} [∀ i, Preorderₓ (β i)] {f f' : ∀ i, α i → β i} (h : ∀ i, f i ≤ᵐ[μ i] f' i) :
    (fun i => f i (x i)) ≤ᵐ[Measure.pi μ] fun x i => f' i (x i) :=
  (eventually_all.2 fun i => tendsto_eval_ae_ae.Eventually (h i)).mono fun x hx => hx

theorem ae_le_set_pi {I : Set ι} {s t : ∀ i, Set (α i)} (h : ∀, ∀ i ∈ I, ∀, s i ≤ᵐ[μ i] t i) :
    Set.Pi I s ≤ᵐ[Measure.pi μ] Set.Pi I t :=
  ((eventually_all_finite (Finite.of_fintype I)).2 fun i hi => tendsto_eval_ae_ae.Eventually (h i hi)).mono
    fun x hst hx i hi => hst i hi <| hx i hi

theorem ae_eq_set_pi {I : Set ι} {s t : ∀ i, Set (α i)} (h : ∀, ∀ i ∈ I, ∀, s i =ᵐ[μ i] t i) :
    Set.Pi I s =ᵐ[Measure.pi μ] Set.Pi I t :=
  (ae_le_set_pi fun i hi => (h i hi).le).antisymm (ae_le_set_pi fun i hi => (h i hi).symm.le)

section Intervals

variable {μ} [∀ i, PartialOrderₓ (α i)] [∀ i, HasNoAtoms (μ i)]

theorem pi_Iio_ae_eq_pi_Iic {s : Set ι} {f : ∀ i, α i} :
    (pi s fun i => Iio (f i)) =ᵐ[Measure.pi μ] pi s fun i => Iic (f i) :=
  ae_eq_set_pi fun i hi => Iio_ae_eq_Iic

theorem pi_Ioi_ae_eq_pi_Ici {s : Set ι} {f : ∀ i, α i} :
    (pi s fun i => Ioi (f i)) =ᵐ[Measure.pi μ] pi s fun i => Ici (f i) :=
  ae_eq_set_pi fun i hi => Ioi_ae_eq_Ici

theorem univ_pi_Iio_ae_eq_Iic {f : ∀ i, α i} : (pi Univ fun i => Iio (f i)) =ᵐ[Measure.pi μ] Iic f := by
  rw [← pi_univ_Iic]
  exact pi_Iio_ae_eq_pi_Iic

theorem univ_pi_Ioi_ae_eq_Ici {f : ∀ i, α i} : (pi Univ fun i => Ioi (f i)) =ᵐ[Measure.pi μ] Ici f := by
  rw [← pi_univ_Ici]
  exact pi_Ioi_ae_eq_pi_Ici

theorem pi_Ioo_ae_eq_pi_Icc {s : Set ι} {f g : ∀ i, α i} :
    (pi s fun i => Ioo (f i) (g i)) =ᵐ[Measure.pi μ] pi s fun i => Icc (f i) (g i) :=
  ae_eq_set_pi fun i hi => Ioo_ae_eq_Icc

theorem pi_Ioo_ae_eq_pi_Ioc {s : Set ι} {f g : ∀ i, α i} :
    (pi s fun i => Ioo (f i) (g i)) =ᵐ[Measure.pi μ] pi s fun i => Ioc (f i) (g i) :=
  ae_eq_set_pi fun i hi => Ioo_ae_eq_Ioc

theorem univ_pi_Ioo_ae_eq_Icc {f g : ∀ i, α i} : (pi Univ fun i => Ioo (f i) (g i)) =ᵐ[Measure.pi μ] Icc f g := by
  rw [← pi_univ_Icc]
  exact pi_Ioo_ae_eq_pi_Icc

theorem pi_Ioc_ae_eq_pi_Icc {s : Set ι} {f g : ∀ i, α i} :
    (pi s fun i => Ioc (f i) (g i)) =ᵐ[Measure.pi μ] pi s fun i => Icc (f i) (g i) :=
  ae_eq_set_pi fun i hi => Ioc_ae_eq_Icc

theorem univ_pi_Ioc_ae_eq_Icc {f g : ∀ i, α i} : (pi Univ fun i => Ioc (f i) (g i)) =ᵐ[Measure.pi μ] Icc f g := by
  rw [← pi_univ_Icc]
  exact pi_Ioc_ae_eq_pi_Icc

theorem pi_Ico_ae_eq_pi_Icc {s : Set ι} {f g : ∀ i, α i} :
    (pi s fun i => Ico (f i) (g i)) =ᵐ[Measure.pi μ] pi s fun i => Icc (f i) (g i) :=
  ae_eq_set_pi fun i hi => Ico_ae_eq_Icc

theorem univ_pi_Ico_ae_eq_Icc {f g : ∀ i, α i} : (pi Univ fun i => Ico (f i) (g i)) =ᵐ[Measure.pi μ] Icc f g := by
  rw [← pi_univ_Icc]
  exact pi_Ico_ae_eq_pi_Icc

end Intervals

/-- If one of the measures `μ i` has no atoms, them `measure.pi µ`
has no atoms. The instance below assumes that all `μ i` have no atoms. -/
theorem pi_has_no_atoms (i : ι) [HasNoAtoms (μ i)] : HasNoAtoms (Measure.pi μ) :=
  ⟨fun x => flip measure_mono_null (pi_hyperplane μ i (x i)) (singleton_subset_iff.2 rfl)⟩

instance [h : Nonempty ι] [∀ i, HasNoAtoms (μ i)] : HasNoAtoms (Measure.pi μ) :=
  h.elim fun i => pi_has_no_atoms i

instance [∀ i, TopologicalSpace (α i)] [∀ i, IsLocallyFiniteMeasure (μ i)] : IsLocallyFiniteMeasure (Measure.pi μ) := by
  refine' ⟨fun x => _⟩
  choose s hxs ho hμ using fun i => (μ i).exists_is_open_measure_lt_top (x i)
  refine' ⟨pi univ s, set_pi_mem_nhds finite_univ fun i hi => IsOpen.mem_nhds (ho i) (hxs i), _⟩
  rw [pi_pi]
  exact Ennreal.prod_lt_top fun i _ => (hμ i).Ne

variable (μ)

/-- Separating the indices into those that satisfy a predicate `p` and those that don't maps
a product measure to a product of product measures. This is useful to apply Fubini to some subset
of the variables. The converse is `measure_theory.measure.map_pi_equiv_pi_subtype_prod`. -/
theorem map_pi_equiv_pi_subtype_prod_symm (p : ι → Prop) [DecidablePred p] :
    map (Equivₓ.piEquivPiSubtypeProd p α).symm (Measure.prod (Measure.pi fun i => μ i) (Measure.pi fun i => μ i)) =
      Measure.pi μ :=
  by
  refine' (measure.pi_eq fun s hs => _).symm
  have A :
    ((Equivₓ.piEquivPiSubtypeProd p α).symm ⁻¹' Set.Pi Set.Univ fun i : ι => s i) =
      (Set.Pi Set.Univ fun i : { i // p i } => s i) ×ˢ Set.Pi Set.Univ fun i : { i // ¬p i } => s i :=
    by
    ext x
    simp only [Equivₓ.pi_equiv_pi_subtype_prod_symm_apply, mem_prod, mem_univ_pi, mem_preimage, Subtype.forall]
    constructor
    · exact fun h =>
        ⟨fun i hi => by
          simpa [dif_pos hi] using h i, fun i hi => by
          simpa [dif_neg hi] using h i⟩
      
    · intro h i
      by_cases' hi : p i
      · simpa only [dif_pos hi] using h.1 i hi
        
      · simpa only [dif_neg hi] using h.2 i hi
        
      
  rw [measure.map_apply (measurable_pi_equiv_pi_subtype_prod_symm _ p) (MeasurableSet.univ_pi_fintype hs), A,
    measure.prod_prod, pi_pi, pi_pi, ← Fintype.prod_subtype_mul_prod_subtype p fun i => μ i (s i)]

theorem map_pi_equiv_pi_subtype_prod (p : ι → Prop) [DecidablePred p] :
    map (Equivₓ.piEquivPiSubtypeProd p α) (Measure.pi μ) =
      Measure.prod (Measure.pi fun i => μ i) (Measure.pi fun i => μ i) :=
  by
  rw [← map_pi_equiv_pi_subtype_prod_symm μ p,
    measure.map_map (measurable_pi_equiv_pi_subtype_prod _ p) (measurable_pi_equiv_pi_subtype_prod_symm _ p)]
  simp only [Equivₓ.self_comp_symm, map_id]

@[to_additive]
instance pi.is_mul_left_invariant [∀ i, Groupₓ (α i)] [∀ i, HasMeasurableMul (α i)] [∀ i, IsMulLeftInvariant (μ i)] :
    IsMulLeftInvariant (Measure.pi μ) := by
  refine' ⟨fun x => (measure.pi_eq fun s hs => _).symm⟩
  have A : (Mul.mul x ⁻¹' Set.Pi univ fun i : ι => s i) = Set.Pi univ fun i : ι => (· * ·) (x i) ⁻¹' s i := by
    ext
    simp
  rw [measure.map_apply (measurable_const_mul x) (MeasurableSet.univ_pi_fintype hs), A, pi_pi]
  simp only [measure_preimage_mul]

end Measureₓ

instance MeasureSpace.pi [∀ i, MeasureSpace (α i)] : MeasureSpace (∀ i, α i) :=
  ⟨Measure.pi fun i => volume⟩

theorem volume_pi [∀ i, MeasureSpace (α i)] : (volume : Measure (∀ i, α i)) = Measure.pi fun i => volume :=
  rfl

theorem volume_pi_pi [∀ i, MeasureSpace (α i)] [∀ i, SigmaFinite (volume : Measure (α i))] (s : ∀ i, Set (α i)) :
    volume (pi Univ s) = ∏ i, volume (s i) :=
  Measure.pi_pi (fun i => volume) s

theorem volume_pi_ball [∀ i, MeasureSpace (α i)] [∀ i, SigmaFinite (volume : Measure (α i))] [∀ i, MetricSpace (α i)]
    (x : ∀ i, α i) {r : ℝ} (hr : 0 < r) : volume (Metric.Ball x r) = ∏ i, volume (Metric.Ball (x i) r) :=
  Measure.pi_ball _ _ hr

theorem volume_pi_closed_ball [∀ i, MeasureSpace (α i)] [∀ i, SigmaFinite (volume : Measure (α i))]
    [∀ i, MetricSpace (α i)] (x : ∀ i, α i) {r : ℝ} (hr : 0 ≤ r) :
    volume (Metric.ClosedBall x r) = ∏ i, volume (Metric.ClosedBall (x i) r) :=
  Measure.pi_closed_ball _ _ hr

open Measureₓ

@[to_additive]
instance Pi.is_mul_left_invariant_volume [∀ i, Groupₓ (α i)] [∀ i, MeasureSpace (α i)]
    [∀ i, SigmaFinite (volume : Measure (α i))] [∀ i, HasMeasurableMul (α i)]
    [∀ i, IsMulLeftInvariant (volume : Measure (α i))] : IsMulLeftInvariant (volume : Measure (∀ i, α i)) :=
  pi.is_mul_left_invariant _

/-!
### Measure preserving equivalences

In this section we prove that some measurable equivalences (e.g., between `fin 1 → α` and `α` or
between `fin 2 → α` and `α × α`) preserve measure or volume. These lemmas can be used to prove that
measures of corresponding sets (images or preimages) have equal measures and functions `f ∘ e` and
`f` have equal integrals, see lemmas in the `measure_theory.measure_preserving` prefix.
-/


section MeasurePreserving

theorem measure_preserving_fun_unique {β : Type u} {m : MeasurableSpace β} (μ : Measure β) (α : Type v) [Unique α] :
    MeasurePreserving (MeasurableEquiv.funUnique α β) (Measure.pi fun a : α => μ) μ := by
  set e := MeasurableEquiv.funUnique α β
  have : (pi_premeasure fun _ : α => μ.to_outer_measure) = measure.map e.symm μ := by
    ext1 s
    rw [pi_premeasure, Fintype.prod_unique, to_outer_measure_apply, e.symm.map_apply]
    congr 1
    exact e.to_equiv.image_eq_preimage s
  simp only [measure.pi, outer_measure.pi, this, bounded_by_measure, to_outer_measure_to_measure]
  exact ((MeasurableEquiv.funUnique α β).symm.Measurable.MeasurePreserving _).symm

theorem volume_preserving_fun_unique (α : Type u) (β : Type v) [Unique α] [MeasureSpace β] :
    MeasurePreserving (MeasurableEquiv.funUnique α β) volume volume :=
  measure_preserving_fun_unique volume α

theorem measure_preserving_pi_fin_two {α : Finₓ 2 → Type u} {m : ∀ i, MeasurableSpace (α i)} (μ : ∀ i, Measure (α i))
    [∀ i, SigmaFinite (μ i)] : MeasurePreserving (MeasurableEquiv.piFinTwo α) (Measure.pi μ) ((μ 0).Prod (μ 1)) := by
  refine' ⟨MeasurableEquiv.measurable _, (measure.prod_eq fun s t hs ht => _).symm⟩
  rw [MeasurableEquiv.map_apply, MeasurableEquiv.pi_fin_two_apply, Finₓ.preimage_apply_01_prod, measure.pi_pi,
    Finₓ.prod_univ_two]
  rfl

theorem volume_preserving_pi_fin_two (α : Finₓ 2 → Type u) [∀ i, MeasureSpace (α i)]
    [∀ i, SigmaFinite (volume : Measure (α i))] : MeasurePreserving (MeasurableEquiv.piFinTwo α) volume volume :=
  measure_preserving_pi_fin_two _

-- ././Mathport/Syntax/Translate/Basic.lean:826:4: warning: unsupported notation `«expr![ , ]»
-- ././Mathport/Syntax/Translate/Basic.lean:827:71: unsupported notation `«expr![ , ]»
-- ././Mathport/Syntax/Translate/Basic.lean:826:4: warning: unsupported notation `«expr![ , ]»
-- ././Mathport/Syntax/Translate/Basic.lean:827:71: unsupported notation `«expr![ , ]»
theorem measure_preserving_fin_two_arrow_vec {α : Type u} {m : MeasurableSpace α} (μ ν : Measure α) [SigmaFinite μ]
    [SigmaFinite ν] :
    MeasurePreserving MeasurableEquiv.finTwoArrow
      (Measure.pi («expr![ , ]» "././Mathport/Syntax/Translate/Basic.lean:827:71: unsupported notation `«expr![ , ]»"))
      (μ.Prod ν) :=
  have :
    ∀ i,
      sigma_finite
        ((«expr![ , ]» "././Mathport/Syntax/Translate/Basic.lean:827:71: unsupported notation `«expr![ , ]»") i) :=
    Finₓ.forall_fin_two.2 ⟨‹_›, ‹_›⟩
  measure_preserving_pi_fin_two _

theorem measure_preserving_fin_two_arrow {α : Type u} {m : MeasurableSpace α} (μ : Measure α) [SigmaFinite μ] :
    MeasurePreserving MeasurableEquiv.finTwoArrow (Measure.pi fun _ => μ) (μ.Prod μ) := by
  simpa only [Matrix.vec_single_eq_const, Matrix.vec_cons_const] using measure_preserving_fin_two_arrow_vec μ μ

theorem volume_preserving_fin_two_arrow (α : Type u) [MeasureSpace α] [SigmaFinite (volume : Measure α)] :
    MeasurePreserving (@MeasurableEquiv.finTwoArrow α _) volume volume :=
  measure_preserving_fin_two_arrow volume

theorem measure_preserving_pi_empty {ι : Type u} {α : ι → Type v} [IsEmpty ι] {m : ∀ i, MeasurableSpace (α i)}
    (μ : ∀ i, Measure (α i)) :
    MeasurePreserving (MeasurableEquiv.ofUniqueOfUnique (∀ i, α i) Unit) (Measure.pi μ) (Measure.dirac ()) := by
  set e := MeasurableEquiv.ofUniqueOfUnique (∀ i, α i) Unit
  refine' ⟨e.measurable, _⟩
  rw [measure.pi_of_empty, measure.map_dirac e.measurable]
  rfl

theorem volume_preserving_pi_empty {ι : Type u} (α : ι → Type v) [IsEmpty ι] [∀ i, MeasureSpace (α i)] :
    MeasurePreserving (MeasurableEquiv.ofUniqueOfUnique (∀ i, α i) Unit) volume volume :=
  measure_preserving_pi_empty fun _ => volume

end MeasurePreserving

end MeasureTheory

