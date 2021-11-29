import Mathbin.Analysis.BoxIntegral.Box.Basic

/-!
# Partitions of rectangular boxes in `ℝⁿ`

In this file we define (pre)partitions of rectangular boxes in `ℝⁿ`.  A partition of a box `I` in
`ℝⁿ` (see `box_integral.prepartition` and `box_integral.prepartition.is_partition`) is a finite set
of pairwise disjoint boxes such that their union is exactly `I`. We use `boxes : finset (box ι)` to
store the set of boxes.

Many lemmas about box integrals deal with pairwise disjoint collections of subboxes, so we define a
structure `box_integral.prepartition (I : box_integral.box ι)` that stores a collection of boxes
such that

* each box `J ∈ boxes` is a subbox of `I`;
* the boxes are pairwise disjoint as sets in `ℝⁿ`.

Then we define a predicate `box_integral.prepartition.is_partition`; `π.is_partition` means that the
boxes of `π` actually cover the whole `I`. We also define some operations on prepartitions:

* `box_integral.partition.bUnion`: split each box of a partition into smaller boxes;
* `box_integral.partition.restrict`: restrict a partition to a smaller box.

We also define a `semilattice_inf` structure on `box_integral.partition I` for all
`I : box_integral.box ι`.

## Tags

rectangular box, partition
-/


open Set Finset Function

open_locale Classical Nnreal BigOperators

noncomputable theory

namespace BoxIntegral

variable{ι : Type _}

/-- A prepartition of `I : box_integral.box ι` is a finite set of pairwise disjoint subboxes of
`I`. -/
structure prepartition(I : box ι) where 
  boxes : Finset (box ι)
  le_of_mem' : ∀ J (_ : J ∈ boxes), J ≤ I 
  PairwiseDisjoint : Set.Pairwise («expr↑ » boxes) (Disjoint on (coeₓ : box ι → Set (ι → ℝ)))

namespace Prepartition

variable{I J J₁ J₂ : box ι}(π : prepartition I){π₁ π₂ : prepartition I}{x : ι → ℝ}

instance  : HasMem (box ι) (prepartition I) :=
  ⟨fun J π => J ∈ π.boxes⟩

@[simp]
theorem mem_boxes : J ∈ π.boxes ↔ J ∈ π :=
  Iff.rfl

@[simp]
theorem mem_mk {s h₁ h₂} : J ∈ (mk s h₁ h₂ : prepartition I) ↔ J ∈ s :=
  Iff.rfl

theorem disjoint_coe_of_mem (h₁ : J₁ ∈ π) (h₂ : J₂ ∈ π) (h : J₁ ≠ J₂) : Disjoint (J₁ : Set (ι → ℝ)) J₂ :=
  π.pairwise_disjoint J₁ h₁ J₂ h₂ h

theorem eq_of_mem_of_mem (h₁ : J₁ ∈ π) (h₂ : J₂ ∈ π) (hx₁ : x ∈ J₁) (hx₂ : x ∈ J₂) : J₁ = J₂ :=
  by_contra$ fun H => π.disjoint_coe_of_mem h₁ h₂ H ⟨hx₁, hx₂⟩

theorem eq_of_le_of_le (h₁ : J₁ ∈ π) (h₂ : J₂ ∈ π) (hle₁ : J ≤ J₁) (hle₂ : J ≤ J₂) : J₁ = J₂ :=
  π.eq_of_mem_of_mem h₁ h₂ (hle₁ J.upper_mem) (hle₂ J.upper_mem)

theorem eq_of_le (h₁ : J₁ ∈ π) (h₂ : J₂ ∈ π) (hle : J₁ ≤ J₂) : J₁ = J₂ :=
  π.eq_of_le_of_le h₁ h₂ le_rfl hle

theorem le_of_mem (hJ : J ∈ π) : J ≤ I :=
  π.le_of_mem' J hJ

theorem lower_le_lower (hJ : J ∈ π) : I.lower ≤ J.lower :=
  box.antitone_lower (π.le_of_mem hJ)

theorem upper_le_upper (hJ : J ∈ π) : J.upper ≤ I.upper :=
  box.monotone_upper (π.le_of_mem hJ)

theorem injective_boxes : Function.Injective (boxes : prepartition I → Finset (box ι)) :=
  by 
    rintro ⟨s₁, h₁, h₁'⟩ ⟨s₂, h₂, h₂'⟩ (rfl : s₁ = s₂)
    rfl

@[ext]
theorem ext (h : ∀ J, J ∈ π₁ ↔ J ∈ π₂) : π₁ = π₂ :=
  injective_boxes$ Finset.ext h

/-- The singleton prepartition `{J}`, `J ≤ I`. -/
@[simps]
def single (I J : box ι) (h : J ≤ I) : prepartition I :=
  ⟨{J},
    by 
      simpa,
    by 
      simp ⟩

@[simp]
theorem mem_single {J'} (h : J ≤ I) : J' ∈ single I J h ↔ J' = J :=
  mem_singleton

/-- We say that `π ≤ π'` if each box of `π` is a subbox of some box of `π'`. -/
instance  : LE (prepartition I) :=
  ⟨fun π π' => ∀ ⦃I⦄, I ∈ π → ∃ (I' : _)(_ : I' ∈ π'), I ≤ I'⟩

instance  : PartialOrderₓ (prepartition I) :=
  { le := · ≤ ·, le_refl := fun π I hI => ⟨I, hI, le_rfl⟩,
    le_trans :=
      fun π₁ π₂ π₃ h₁₂ h₂₃ I₁ hI₁ =>
        let ⟨I₂, hI₂, hI₁₂⟩ := h₁₂ hI₁ 
        let ⟨I₃, hI₃, hI₂₃⟩ := h₂₃ hI₂
        ⟨I₃, hI₃, hI₁₂.trans hI₂₃⟩,
    le_antisymm :=
      by 
        suffices  : ∀ {π₁ π₂ : prepartition I}, π₁ ≤ π₂ → π₂ ≤ π₁ → π₁.boxes ⊆ π₂.boxes 
        exact fun π₁ π₂ h₁ h₂ => injective_boxes (subset.antisymm (this h₁ h₂) (this h₂ h₁))
        intro π₁ π₂ h₁ h₂ J hJ 
        rcases h₁ hJ with ⟨J', hJ', hle⟩
        rcases h₂ hJ' with ⟨J'', hJ'', hle'⟩
        obtain rfl : J = J'' 
        exact π₁.eq_of_le hJ hJ'' (hle.trans hle')
        obtain rfl : J' = J 
        exact le_antisymmₓ ‹_› ‹_›
        assumption }

instance  : OrderTop (prepartition I) :=
  { top := single I I le_rfl,
    le_top :=
      fun π J hJ =>
        ⟨I,
          by 
            simp ,
          π.le_of_mem hJ⟩ }

instance  : OrderBot (prepartition I) :=
  { bot := ⟨∅, fun J hJ => False.elim hJ, fun J hJ => False.elim hJ⟩, bot_le := fun π J hJ => False.elim hJ }

instance  : Inhabited (prepartition I) :=
  ⟨⊤⟩

theorem le_def : π₁ ≤ π₂ ↔ ∀ J (_ : J ∈ π₁), ∃ (J' : _)(_ : J' ∈ π₂), J ≤ J' :=
  Iff.rfl

@[simp]
theorem mem_top : J ∈ (⊤ : prepartition I) ↔ J = I :=
  mem_singleton

@[simp]
theorem top_boxes : (⊤ : prepartition I).boxes = {I} :=
  rfl

@[simp]
theorem not_mem_bot : J ∉ (⊥ : prepartition I) :=
  id

@[simp]
theorem bot_boxes : (⊥ : prepartition I).boxes = ∅ :=
  rfl

-- error in Analysis.BoxIntegral.Partition.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- An auxiliary lemma used to prove that the same point can't belong to more than
`2 ^ fintype.card ι` closed boxes of a prepartition. -/
theorem inj_on_set_of_mem_Icc_set_of_lower_eq
(x : ι → exprℝ()) : inj_on (λ
 J : box ι, {i | «expr = »(J.lower i, x i)}) {J | «expr ∧ »(«expr ∈ »(J, π), «expr ∈ »(x, J.Icc))} :=
begin
  rintros [ident J₁, "⟨", ident h₁, ",", ident hx₁, "⟩", ident J₂, "⟨", ident h₂, ",", ident hx₂, "⟩", "(", ident H, ":", expr «expr = »({i | «expr = »(J₁.lower i, x i)}, {i | «expr = »(J₂.lower i, x i)}), ")"],
  suffices [] [":", expr ∀ i, «expr ∩ »(Ioc (J₁.lower i) (J₁.upper i), Ioc (J₂.lower i) (J₂.upper i)).nonempty],
  { choose [] [ident y] [ident hy₁, ident hy₂] [],
    exact [expr π.eq_of_mem_of_mem h₁ h₂ hy₁ hy₂] },
  intro [ident i],
  simp [] [] ["only"] ["[", expr set.ext_iff, ",", expr mem_set_of_eq, "]"] [] ["at", ident H],
  cases [expr (hx₁.1 i).eq_or_lt] ["with", ident hi₁, ident hi₁],
  { have [ident hi₂] [":", expr «expr = »(J₂.lower i, x i)] [],
    from [expr (H _).1 hi₁],
    have [ident H₁] [":", expr «expr < »(x i, J₁.upper i)] [],
    by simpa [] [] ["only"] ["[", expr hi₁, "]"] [] ["using", expr J₁.lower_lt_upper i],
    have [ident H₂] [":", expr «expr < »(x i, J₂.upper i)] [],
    by simpa [] [] ["only"] ["[", expr hi₂, "]"] [] ["using", expr J₂.lower_lt_upper i],
    rw ["[", expr Ioc_inter_Ioc, ",", expr hi₁, ",", expr hi₂, ",", expr sup_idem, ",", expr set.nonempty_Ioc, "]"] [],
    exact [expr lt_min H₁ H₂] },
  { have [ident hi₂] [":", expr «expr < »(J₂.lower i, x i)] [],
    from [expr (hx₂.1 i).lt_of_ne (mt (H _).2 hi₁.ne)],
    exact [expr ⟨x i, ⟨hi₁, hx₁.2 i⟩, ⟨hi₂, hx₂.2 i⟩⟩] }
end

-- error in Analysis.BoxIntegral.Partition.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- The set of boxes of a prepartition that contain `x` in their closures has cardinality
at most `2 ^ fintype.card ι`. -/
theorem card_filter_mem_Icc_le
[fintype ι]
(x : ι → exprℝ()) : «expr ≤ »((π.boxes.filter (λ J : box ι, «expr ∈ »(x, J.Icc))).card, «expr ^ »(2, fintype.card ι)) :=
begin
  rw ["[", "<-", expr fintype.card_set, "]"] [],
  refine [expr finset.card_le_card_of_inj_on (λ
    J : box ι, {i | «expr = »(J.lower i, x i)}) (λ _ _, finset.mem_univ _) _],
  simpa [] [] ["only"] ["[", expr finset.mem_filter, "]"] [] ["using", expr π.inj_on_set_of_mem_Icc_set_of_lower_eq x]
end

/-- Given a prepartition `π : box_integral.prepartition I`, `π.Union` is the part of `I` covered by
the boxes of `π`. -/
protected def Union : Set (ι → ℝ) :=
  ⋃(J : _)(_ : J ∈ π), «expr↑ » J

theorem Union_def : π.Union = ⋃(J : _)(_ : J ∈ π), «expr↑ » J :=
  rfl

theorem Union_def' : π.Union = ⋃(J : _)(_ : J ∈ π.boxes), «expr↑ » J :=
  rfl

@[simp]
theorem mem_Union : x ∈ π.Union ↔ ∃ (J : _)(_ : J ∈ π), x ∈ J :=
  Set.mem_bUnion_iff

@[simp]
theorem Union_single (h : J ≤ I) : (single I J h).Union = J :=
  by 
    simp [Union_def]

@[simp]
theorem Union_top : (⊤ : prepartition I).Union = I :=
  by 
    simp [prepartition.Union]

@[simp]
theorem Union_eq_empty : π₁.Union = ∅ ↔ π₁ = ⊥ :=
  by 
    simp [←injective_boxes.eq_iff, Finset.ext_iff, prepartition.Union, imp_false]

@[simp]
theorem Union_bot : (⊥ : prepartition I).Union = ∅ :=
  Union_eq_empty.2 rfl

theorem subset_Union (h : J ∈ π) : «expr↑ » J ⊆ π.Union :=
  subset_bUnion_of_mem h

theorem Union_subset : π.Union ⊆ I :=
  bUnion_subset π.le_of_mem'

@[mono]
theorem Union_mono (h : π₁ ≤ π₂) : π₁.Union ⊆ π₂.Union :=
  fun x hx =>
    let ⟨J₁, hJ₁, hx⟩ := π₁.mem_Union.1 hx 
    let ⟨J₂, hJ₂, hle⟩ := h hJ₁ 
    π₂.mem_Union.2 ⟨J₂, hJ₂, hle hx⟩

theorem disjoint_boxes_of_disjoint_Union (h : Disjoint π₁.Union π₂.Union) : Disjoint π₁.boxes π₂.boxes :=
  Finset.disjoint_left.2$ fun J h₁ h₂ => h.mono (π₁.subset_Union h₁) (π₂.subset_Union h₂) ⟨J.upper_mem, J.upper_mem⟩

theorem le_iff_nonempty_imp_le_and_Union_subset :
  π₁ ≤ π₂ ↔ (∀ J (_ : J ∈ π₁) J' (_ : J' ∈ π₂), (J ∩ J' : Set (ι → ℝ)).Nonempty → J ≤ J') ∧ π₁.Union ⊆ π₂.Union :=
  by 
    fsplit
    ·
      refine' fun H => ⟨fun J hJ J' hJ' Hne => _, Union_mono H⟩
      rcases H hJ with ⟨J'', hJ'', Hle⟩
      rcases Hne with ⟨x, hx, hx'⟩
      rwa [π₂.eq_of_mem_of_mem hJ' hJ'' hx' (Hle hx)]
    ·
      rintro ⟨H, HU⟩ J hJ 
      simp only [Set.subset_def, mem_Union] at HU 
      rcases HU J.upper ⟨J, hJ, J.upper_mem⟩ with ⟨J₂, hJ₂, hx⟩
      exact ⟨J₂, hJ₂, H _ hJ _ hJ₂ ⟨_, J.upper_mem, hx⟩⟩

theorem eq_of_boxes_subset_Union_superset (h₁ : π₁.boxes ⊆ π₂.boxes) (h₂ : π₂.Union ⊆ π₁.Union) : π₁ = π₂ :=
  (le_antisymmₓ fun J hJ => ⟨J, h₁ hJ, le_rfl⟩)$
    le_iff_nonempty_imp_le_and_Union_subset.2
      ⟨fun J₁ hJ₁ J₂ hJ₂ Hne => (π₂.eq_of_mem_of_mem hJ₁ (h₁ hJ₂) Hne.some_spec.1 Hne.some_spec.2).le, h₂⟩

/-- Given a prepartition `π` of a box `I` and a collection of prepartitions `πi J` of all boxes
`J ∈ π`, returns the prepartition of `I` into the union of the boxes of all `πi J`.

Though we only use the values of `πi` on the boxes of `π`, we require `πi` to be a globally defined
function. -/
@[simps]
def bUnion (πi : ∀ (J : box ι), prepartition J) : prepartition I :=
  { boxes := π.boxes.bUnion$ fun J => (πi J).boxes,
    le_of_mem' :=
      fun J hJ =>
        by 
          simp only [Finset.mem_bUnion, exists_prop, mem_boxes] at hJ 
          rcases hJ with ⟨J', hJ', hJ⟩
          exact ((πi J').le_of_mem hJ).trans (π.le_of_mem hJ'),
    PairwiseDisjoint :=
      by 
        simp only [Set.Pairwise, Finset.mem_coe, Finset.mem_bUnion]
        rintro J₁' ⟨J₁, hJ₁, hJ₁'⟩ J₂' ⟨J₂, hJ₂, hJ₂'⟩ Hne x ⟨hx₁, hx₂⟩
        apply Hne 
        obtain rfl : J₁ = J₂ 
        exact π.eq_of_mem_of_mem hJ₁ hJ₂ ((πi J₁).le_of_mem hJ₁' hx₁) ((πi J₂).le_of_mem hJ₂' hx₂)
        exact (πi J₁).eq_of_mem_of_mem hJ₁' hJ₂' hx₁ hx₂ }

variable{πi πi₁ πi₂ : ∀ (J : box ι), prepartition J}

@[simp]
theorem mem_bUnion : J ∈ π.bUnion πi ↔ ∃ (J' : _)(_ : J' ∈ π), J ∈ πi J' :=
  by 
    simp [bUnion]

theorem bUnion_le (πi : ∀ J, prepartition J) : π.bUnion πi ≤ π :=
  fun J hJ =>
    let ⟨J', hJ', hJ⟩ := π.mem_bUnion.1 hJ
    ⟨J', hJ', (πi J').le_of_mem hJ⟩

@[simp]
theorem bUnion_top : (π.bUnion fun _ => ⊤) = π :=
  by 
    ext 
    simp 

-- error in Analysis.BoxIntegral.Partition.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[congr]
theorem bUnion_congr
(h : «expr = »(π₁, π₂))
(hi : ∀ J «expr ∈ » π₁, «expr = »(πi₁ J, πi₂ J)) : «expr = »(π₁.bUnion πi₁, π₂.bUnion πi₂) :=
by { subst [expr π₂],
  ext [] [ident J] [],
  simp [] [] [] ["[", expr hi, "]"] [] [] { contextual := tt } }

theorem bUnion_congr_of_le (h : π₁ = π₂) (hi : ∀ J (_ : J ≤ I), πi₁ J = πi₂ J) : π₁.bUnion πi₁ = π₂.bUnion πi₂ :=
  bUnion_congr h$ fun J hJ => hi J (π₁.le_of_mem hJ)

@[simp]
theorem Union_bUnion (πi : ∀ (J : box ι), prepartition J) : (π.bUnion πi).Union = ⋃(J : _)(_ : J ∈ π), (πi J).Union :=
  by 
    simp [prepartition.Union]

@[simp]
theorem sum_bUnion_boxes {M : Type _} [AddCommMonoidₓ M] (π : prepartition I) (πi : ∀ J, prepartition J)
  (f : box ι → M) : (∑J in π.boxes.bUnion fun J => (πi J).boxes, f J) = ∑J in π.boxes, ∑J' in (πi J).boxes, f J' :=
  by 
    refine' Finset.sum_bUnion fun J₁ h₁ J₂ h₂ hne => Finset.disjoint_left.2$ fun J' h₁' h₂' => _ 
    exact hne (π.eq_of_le_of_le h₁ h₂ ((πi J₁).le_of_mem h₁') ((πi J₂).le_of_mem h₂'))

/-- Given a box `J ∈ π.bUnion πi`, returns the box `J' ∈ π` such that `J ∈ πi J'`.
For `J ∉ π.bUnion πi`, returns `I`. -/
def bUnion_index (πi : ∀ J, prepartition J) (J : box ι) : box ι :=
  if hJ : J ∈ π.bUnion πi then (π.mem_bUnion.1 hJ).some else I

theorem bUnion_index_mem (hJ : J ∈ π.bUnion πi) : π.bUnion_index πi J ∈ π :=
  by 
    rw [bUnion_index, dif_pos hJ]
    exact (π.mem_bUnion.1 hJ).some_spec.fst

theorem bUnion_index_le (πi : ∀ J, prepartition J) (J : box ι) : π.bUnion_index πi J ≤ I :=
  by 
    byCases' hJ : J ∈ π.bUnion πi
    ·
      exact π.le_of_mem (π.bUnion_index_mem hJ)
    ·
      rw [bUnion_index, dif_neg hJ]
      exact le_rfl

theorem mem_bUnion_index (hJ : J ∈ π.bUnion πi) : J ∈ πi (π.bUnion_index πi J) :=
  by 
    convert (π.mem_bUnion.1 hJ).some_spec.snd <;> exact dif_pos hJ

theorem le_bUnion_index (hJ : J ∈ π.bUnion πi) : J ≤ π.bUnion_index πi J :=
  le_of_mem _ (π.mem_bUnion_index hJ)

/-- Uniqueness property of `box_integral.partition.bUnion_index`. -/
theorem bUnion_index_of_mem (hJ : J ∈ π) {J'} (hJ' : J' ∈ πi J) : π.bUnion_index πi J' = J :=
  have  : J' ∈ π.bUnion πi := π.mem_bUnion.2 ⟨J, hJ, hJ'⟩
  π.eq_of_le_of_le (π.bUnion_index_mem this) hJ (π.le_bUnion_index this) (le_of_mem _ hJ')

theorem bUnion_assoc (πi : ∀ J, prepartition J) (πi' : box ι → ∀ (J : box ι), prepartition J) :
  (π.bUnion fun J => (πi J).bUnion (πi' J)) = (π.bUnion πi).bUnion fun J => πi' (π.bUnion_index πi J) J :=
  by 
    ext J 
    simp only [mem_bUnion, exists_prop]
    fsplit
    ·
      rintro ⟨J₁, hJ₁, J₂, hJ₂, hJ⟩
      refine' ⟨J₂, ⟨J₁, hJ₁, hJ₂⟩, _⟩
      rwa [π.bUnion_index_of_mem hJ₁ hJ₂]
    ·
      rintro ⟨J₁, ⟨J₂, hJ₂, hJ₁⟩, hJ⟩
      refine' ⟨J₂, hJ₂, J₁, hJ₁, _⟩
      rwa [π.bUnion_index_of_mem hJ₂ hJ₁] at hJ

/-- Create a `box_integral.prepartition` from a collection of possibly empty boxes by filtering out
the empty one if it exists. -/
def of_with_bot (boxes : Finset (WithBot (box ι))) (le_of_mem : ∀ J (_ : J ∈ boxes), (J : WithBot (box ι)) ≤ I)
  (pairwise_disjoint : Set.Pairwise (boxes : Set (WithBot (box ι))) Disjoint) : prepartition I :=
  { boxes := boxes.erase_none,
    le_of_mem' :=
      fun J hJ =>
        by 
          rw [mem_erase_none] at hJ 
          simpa only [WithBot.some_eq_coe, WithBot.coe_le_coe] using le_of_mem _ hJ,
    PairwiseDisjoint :=
      fun J₁ h₁ J₂ h₂ hne =>
        by 
          simp only [mem_coe, mem_erase_none] at h₁ h₂ 
          exact box.disjoint_coe.1 (pairwise_disjoint _ h₁ _ h₂ (mt Option.some_inj.1 hne)) }

@[simp]
theorem mem_of_with_bot {boxes : Finset (WithBot (box ι))} {h₁ h₂} :
  J ∈ (of_with_bot boxes h₁ h₂ : prepartition I) ↔ (J : WithBot (box ι)) ∈ boxes :=
  mem_erase_none

@[simp]
theorem Union_of_with_bot (boxes : Finset (WithBot (box ι)))
  (le_of_mem : ∀ J (_ : J ∈ boxes), (J : WithBot (box ι)) ≤ I)
  (pairwise_disjoint : Set.Pairwise (boxes : Set (WithBot (box ι))) Disjoint) :
  (of_with_bot boxes le_of_mem pairwise_disjoint).Union = ⋃(J : _)(_ : J ∈ boxes), «expr↑ » J :=
  by 
    suffices  : (⋃(J : box ι)(hJ : «expr↑ » J ∈ boxes), «expr↑ » J) = ⋃(J : _)(_ : J ∈ boxes), «expr↑ » J
    ·
      simpa [of_with_bot, prepartition.Union]
    simp only [←box.bUnion_coe_eq_coe, @Union_comm _ _ (box ι), @Union_comm _ _ (@Eq _ _ _), Union_Union_eq_right]

theorem of_with_bot_le {boxes : Finset (WithBot (box ι))} {le_of_mem : ∀ J (_ : J ∈ boxes), (J : WithBot (box ι)) ≤ I}
  {pairwise_disjoint : Set.Pairwise (boxes : Set (WithBot (box ι))) Disjoint}
  (H : ∀ J (_ : J ∈ boxes), J ≠ ⊥ → ∃ (J' : _)(_ : J' ∈ π), J ≤ «expr↑ » J') :
  of_with_bot boxes le_of_mem pairwise_disjoint ≤ π :=
  have  : ∀ (J : box ι), «expr↑ » J ∈ boxes → ∃ (J' : _)(_ : J' ∈ π), J ≤ J' :=
    fun J hJ =>
      by 
        simpa only [WithBot.coe_le_coe] using H J hJ (WithBot.coe_ne_bot J)
  by 
    simpa [of_with_bot, le_def]

theorem le_of_with_bot {boxes : Finset (WithBot (box ι))} {le_of_mem : ∀ J (_ : J ∈ boxes), (J : WithBot (box ι)) ≤ I}
  {pairwise_disjoint : Set.Pairwise (boxes : Set (WithBot (box ι))) Disjoint}
  (H : ∀ J (_ : J ∈ π), ∃ (J' : _)(_ : J' ∈ boxes), «expr↑ » J ≤ J') :
  π ≤ of_with_bot boxes le_of_mem pairwise_disjoint :=
  by 
    intro J hJ 
    rcases H J hJ with ⟨J', J'mem, hle⟩
    lift J' to box ι using ne_bot_of_le_ne_bot (WithBot.coe_ne_bot _) hle 
    exact ⟨J', mem_of_with_bot.2 J'mem, WithBot.coe_le_coe.1 hle⟩

theorem of_with_bot_mono {boxes₁ : Finset (WithBot (box ι))}
  {le_of_mem₁ : ∀ J (_ : J ∈ boxes₁), (J : WithBot (box ι)) ≤ I}
  {pairwise_disjoint₁ : Set.Pairwise (boxes₁ : Set (WithBot (box ι))) Disjoint} {boxes₂ : Finset (WithBot (box ι))}
  {le_of_mem₂ : ∀ J (_ : J ∈ boxes₂), (J : WithBot (box ι)) ≤ I}
  {pairwise_disjoint₂ : Set.Pairwise (boxes₂ : Set (WithBot (box ι))) Disjoint}
  (H : ∀ J (_ : J ∈ boxes₁), J ≠ ⊥ → ∃ (J' : _)(_ : J' ∈ boxes₂), J ≤ J') :
  of_with_bot boxes₁ le_of_mem₁ pairwise_disjoint₁ ≤ of_with_bot boxes₂ le_of_mem₂ pairwise_disjoint₂ :=
  le_of_with_bot _$ fun J hJ => H J (mem_of_with_bot.1 hJ) (WithBot.coe_ne_bot _)

theorem sum_of_with_bot {M : Type _} [AddCommMonoidₓ M] (boxes : Finset (WithBot (box ι)))
  (le_of_mem : ∀ J (_ : J ∈ boxes), (J : WithBot (box ι)) ≤ I)
  (pairwise_disjoint : Set.Pairwise (boxes : Set (WithBot (box ι))) Disjoint) (f : box ι → M) :
  (∑J in (of_with_bot boxes le_of_mem pairwise_disjoint).boxes, f J) = ∑J in boxes, Option.elim J 0 f :=
  Finset.sum_erase_none _ _

-- error in Analysis.BoxIntegral.Partition.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- Restrict a prepartition to a box. -/ def restrict (π : prepartition I) (J : box ι) : prepartition J :=
of_with_bot (π.boxes.image (λ
  J', «expr ⊓ »(J, J'))) (λ
 J' hJ', by { rcases [expr finset.mem_image.1 hJ', "with", "⟨", ident J', ",", "-", ",", ident rfl, "⟩"],
   exact [expr inf_le_left] }) (begin
   simp [] [] ["only"] ["[", expr set.pairwise, ",", expr on_fun, ",", expr finset.mem_coe, ",", expr finset.mem_image, "]"] [] [],
   rintro ["_", "⟨", ident J₁, ",", ident h₁, ",", ident rfl, "⟩", "_", "⟨", ident J₂, ",", ident h₂, ",", ident rfl, "⟩", ident Hne],
   have [] [":", expr «expr ≠ »(J₁, J₂)] [],
   by { rintro [ident rfl],
     exact [expr Hne rfl] },
   exact [expr («expr $ »(box.disjoint_coe.2, π.disjoint_coe_of_mem h₁ h₂ this).inf_left' _).inf_right' _]
 end)

@[simp]
theorem mem_restrict : J₁ ∈ π.restrict J ↔ ∃ (J' : _)(_ : J' ∈ π), (J₁ : WithBot (box ι)) = J⊓J' :=
  by 
    simp [restrict, eq_comm]

theorem mem_restrict' : J₁ ∈ π.restrict J ↔ ∃ (J' : _)(_ : J' ∈ π), (J₁ : Set (ι → ℝ)) = J ∩ J' :=
  by 
    simp only [mem_restrict, ←box.with_bot_coe_inj, box.coe_inf, box.coe_coe]

@[mono]
theorem restrict_mono {π₁ π₂ : prepartition I} (Hle : π₁ ≤ π₂) : π₁.restrict J ≤ π₂.restrict J :=
  by 
    refine' of_with_bot_mono fun J₁ hJ₁ hne => _ 
    rw [Finset.mem_image] at hJ₁ 
    rcases hJ₁ with ⟨J₁, hJ₁, rfl⟩
    rcases Hle hJ₁ with ⟨J₂, hJ₂, hle⟩
    exact ⟨_, Finset.mem_image_of_mem _ hJ₂, inf_le_inf_left _$ WithBot.coe_le_coe.2 hle⟩

-- error in Analysis.BoxIntegral.Partition.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem monotone_restrict : monotone (λ π : prepartition I, restrict π J) := λ π₁ π₂, restrict_mono

/-- Restricting to a larger box does not change the set of boxes. We cannot claim equality
of prepartitions because they have different types. -/
theorem restrict_boxes_of_le (π : prepartition I) (h : I ≤ J) : (π.restrict J).boxes = π.boxes :=
  by 
    simp only [restrict, of_with_bot, erase_none_eq_bUnion]
    refine' finset.image_bUnion.trans _ 
    refine' (Finset.bUnion_congr rfl _).trans Finset.bUnion_singleton_eq_self 
    intro J' hJ' 
    rw [inf_of_le_right, ←WithBot.some_eq_coe, Option.to_finset_some]
    exact WithBot.coe_le_coe.2 ((π.le_of_mem hJ').trans h)

@[simp]
theorem restrict_self : π.restrict I = π :=
  injective_boxes$ restrict_boxes_of_le π le_rfl

@[simp]
theorem Union_restrict : (π.restrict J).Union = J ∩ π.Union :=
  by 
    simp [restrict, ←inter_Union, ←Union_def]

@[simp]
theorem restrict_bUnion (πi : ∀ J, prepartition J) (hJ : J ∈ π) : (π.bUnion πi).restrict J = πi J :=
  by 
    refine' (eq_of_boxes_subset_Union_superset (fun J₁ h₁ => _) _).symm
    ·
      refine' (mem_restrict _).2 ⟨J₁, π.mem_bUnion.2 ⟨J, hJ, h₁⟩, (inf_of_le_right _).symm⟩
      exact WithBot.coe_le_coe.2 (le_of_mem _ h₁)
    ·
      simp only [Union_restrict, Union_bUnion, Set.subset_def, Set.mem_inter_eq, Set.mem_Union]
      rintro x ⟨hxJ, J₁, h₁, hx⟩
      obtain rfl : J = J₁ 
      exact π.eq_of_mem_of_mem hJ h₁ hxJ (Union_subset _ hx)
      exact hx

theorem bUnion_le_iff {πi : ∀ J, prepartition J} {π' : prepartition I} :
  π.bUnion πi ≤ π' ↔ ∀ J (_ : J ∈ π), πi J ≤ π'.restrict J :=
  by 
    fsplit <;> intro H J hJ
    ·
      rw [←π.restrict_bUnion πi hJ]
      exact restrict_mono H
    ·
      rw [mem_bUnion] at hJ 
      rcases hJ with ⟨J₁, h₁, hJ⟩
      rcases H J₁ h₁ hJ with ⟨J₂, h₂, Hle⟩
      rcases π'.mem_restrict.mp h₂ with ⟨J₃, h₃, H⟩
      exact ⟨J₃, h₃, Hle.trans$ WithBot.coe_le_coe.1$ H.trans_le inf_le_right⟩

-- error in Analysis.BoxIntegral.Partition.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem le_bUnion_iff
{πi : ∀ J, prepartition J}
{π' : prepartition I} : «expr ↔ »(«expr ≤ »(π', π.bUnion πi), «expr ∧ »(«expr ≤ »(π', π), ∀
  J «expr ∈ » π, «expr ≤ »(π'.restrict J, πi J))) :=
begin
  refine [expr ⟨λ H, ⟨H.trans (π.bUnion_le πi), λ J hJ, _⟩, _⟩],
  { rw ["<-", expr π.restrict_bUnion πi hJ] [],
    exact [expr restrict_mono H] },
  { rintro ["⟨", ident H, ",", ident Hi, "⟩", ident J', ident hJ'],
    rcases [expr H hJ', "with", "⟨", ident J, ",", ident hJ, ",", ident hle, "⟩"],
    have [] [":", expr «expr ∈ »(J', π'.restrict J)] [],
    from [expr π'.mem_restrict.2 ⟨J', hJ', «expr $ »(inf_of_le_right, with_bot.coe_le_coe.2 hle).symm⟩],
    rcases [expr Hi J hJ this, "with", "⟨", ident Ji, ",", ident hJi, ",", ident hlei, "⟩"],
    exact [expr ⟨Ji, π.mem_bUnion.2 ⟨J, hJ, hJi⟩, hlei⟩] }
end

instance  : HasInf (prepartition I) :=
  ⟨fun π₁ π₂ => π₁.bUnion fun J => π₂.restrict J⟩

theorem inf_def (π₁ π₂ : prepartition I) : π₁⊓π₂ = π₁.bUnion fun J => π₂.restrict J :=
  rfl

@[simp]
theorem mem_inf {π₁ π₂ : prepartition I} :
  J ∈ π₁⊓π₂ ↔ ∃ (J₁ : _)(_ : J₁ ∈ π₁)(J₂ : _)(_ : J₂ ∈ π₂), (J : WithBot (box ι)) = J₁⊓J₂ :=
  by 
    simp only [inf_def, mem_bUnion, mem_restrict]

@[simp]
theorem Union_inf (π₁ π₂ : prepartition I) : (π₁⊓π₂).Union = π₁.Union ∩ π₂.Union :=
  by 
    simp only [inf_def, Union_bUnion, Union_restrict, ←Union_inter, ←Union_def]

instance  : SemilatticeInf (prepartition I) :=
  { prepartition.has_inf, prepartition.partial_order with inf_le_left := fun π₁ π₂ => π₁.bUnion_le _,
    inf_le_right := fun π₁ π₂ => (bUnion_le_iff _).2 fun J hJ => le_rfl,
    le_inf := fun π π₁ π₂ h₁ h₂ => π₁.le_bUnion_iff.2 ⟨h₁, fun J hJ => restrict_mono h₂⟩ }

/-- The prepartition with boxes `{J ∈ π | p J}`. -/
@[simps]
def Filter (π : prepartition I) (p : box ι → Prop) : prepartition I :=
  { boxes := π.boxes.filter p, le_of_mem' := fun J hJ => π.le_of_mem (mem_filter.1 hJ).1,
    PairwiseDisjoint := fun J₁ h₁ J₂ h₂ => π.disjoint_coe_of_mem (mem_filter.1 h₁).1 (mem_filter.1 h₂).1 }

@[simp]
theorem mem_filter {p : box ι → Prop} : J ∈ π.filter p ↔ J ∈ π ∧ p J :=
  Finset.mem_filter

theorem filter_le (π : prepartition I) (p : box ι → Prop) : π.filter p ≤ π :=
  fun J hJ =>
    let ⟨hπ, hp⟩ := π.mem_filter.1 hJ
    ⟨J, hπ, le_rfl⟩

theorem filter_of_true {p : box ι → Prop} (hp : ∀ J (_ : J ∈ π), p J) : π.filter p = π :=
  by 
    ext J 
    simpa using hp J

@[simp]
theorem filter_true : (π.filter fun _ => True) = π :=
  π.filter_of_true fun _ _ => trivialₓ

-- error in Analysis.BoxIntegral.Partition.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem Union_filter_not
(π : prepartition I)
(p : box ι → exprProp()) : «expr = »((π.filter (λ J, «expr¬ »(p J))).Union, «expr \ »(π.Union, (π.filter p).Union)) :=
begin
  simp [] [] ["only"] ["[", expr prepartition.Union, "]"] [] [],
  convert [] [expr (@set.bUnion_diff_bUnion_eq _ (box ι) π.boxes (π.filter p).boxes coe _).symm] [],
  { ext [] [ident J, ident x] [],
    simp [] [] [] [] [] [] { contextual := tt } },
  { convert [] [expr π.pairwise_disjoint] [],
    simp [] [] [] [] [] [] }
end

theorem sum_fiberwise {α M} [AddCommMonoidₓ M] (π : prepartition I) (f : box ι → α) (g : box ι → M) :
  (∑y in π.boxes.image f, ∑J in (π.filter fun J => f J = y).boxes, g J) = ∑J in π.boxes, g J :=
  by 
    convert sum_fiberwise_of_maps_to (fun _ => Finset.mem_image_of_mem f) g

/-- Union of two disjoint prepartitions. -/
@[simps]
def disj_union (π₁ π₂ : prepartition I) (h : Disjoint π₁.Union π₂.Union) : prepartition I :=
  { boxes := π₁.boxes ∪ π₂.boxes, le_of_mem' := fun J hJ => (Finset.mem_union.1 hJ).elim π₁.le_of_mem π₂.le_of_mem,
    PairwiseDisjoint :=
      suffices ∀ J₁ (_ : J₁ ∈ π₁) J₂ (_ : J₂ ∈ π₂), J₁ ≠ J₂ → Disjoint (J₁ : Set (ι → ℝ)) J₂ by 
        simpa [pairwise_union_of_symmetric (symmetric_disjoint.comap _), pairwise_disjoint]
      fun J₁ h₁ J₂ h₂ _ => h.mono (π₁.subset_Union h₁) (π₂.subset_Union h₂) }

@[simp]
theorem mem_disj_union (H : Disjoint π₁.Union π₂.Union) : J ∈ π₁.disj_union π₂ H ↔ J ∈ π₁ ∨ J ∈ π₂ :=
  Finset.mem_union

@[simp]
theorem Union_disj_union (h : Disjoint π₁.Union π₂.Union) : (π₁.disj_union π₂ h).Union = π₁.Union ∪ π₂.Union :=
  by 
    simp [disj_union, prepartition.Union, Union_or, Union_union_distrib]

@[simp]
theorem sum_disj_union_boxes {M : Type _} [AddCommMonoidₓ M] (h : Disjoint π₁.Union π₂.Union) (f : box ι → M) :
  (∑J in π₁.boxes ∪ π₂.boxes, f J) = (∑J in π₁.boxes, f J)+∑J in π₂.boxes, f J :=
  sum_union$ disjoint_boxes_of_disjoint_Union h

section Distortion

variable[Fintype ι]

/-- The distortion of a prepartition is the maximum of the distortions of the boxes of this
prepartition. -/
def distortion :  ℝ≥0  :=
  π.boxes.sup box.distortion

theorem distortion_le_of_mem (h : J ∈ π) : J.distortion ≤ π.distortion :=
  le_sup h

theorem distortion_le_iff {c :  ℝ≥0 } : π.distortion ≤ c ↔ ∀ J (_ : J ∈ π), box.distortion J ≤ c :=
  sup_le_iff

theorem distortion_bUnion (π : prepartition I) (πi : ∀ J, prepartition J) :
  (π.bUnion πi).distortion = π.boxes.sup fun J => (πi J).distortion :=
  sup_bUnion _ _

@[simp]
theorem distortion_disj_union (h : Disjoint π₁.Union π₂.Union) :
  (π₁.disj_union π₂ h).distortion = max π₁.distortion π₂.distortion :=
  sup_union

theorem distortion_of_const {c} (h₁ : π.boxes.nonempty) (h₂ : ∀ J (_ : J ∈ π), box.distortion J = c) :
  π.distortion = c :=
  (sup_congr rfl h₂).trans (sup_const h₁ _)

@[simp]
theorem distortion_top (I : box ι) : distortion (⊤ : prepartition I) = I.distortion :=
  sup_singleton

@[simp]
theorem distortion_bot (I : box ι) : distortion (⊥ : prepartition I) = 0 :=
  sup_empty

end Distortion

/-- A prepartition `π` of `I` is a partition if the boxes of `π` cover the whole `I`. -/
def is_partition (π : prepartition I) :=
  ∀ x (_ : x ∈ I), ∃ (J : _)(_ : J ∈ π), x ∈ J

theorem is_partition_iff_Union_eq {π : prepartition I} : π.is_partition ↔ π.Union = I :=
  by 
    simpRw [is_partition, Set.Subset.antisymm_iff, π.Union_subset, true_andₓ, Set.subset_def, mem_Union, box.mem_coe]

@[simp]
theorem is_partition_single_iff (h : J ≤ I) : is_partition (single I J h) ↔ J = I :=
  by 
    simp [is_partition_iff_Union_eq]

theorem is_partition_top (I : box ι) : is_partition (⊤ : prepartition I) :=
  fun x hx => ⟨I, mem_top.2 rfl, hx⟩

namespace IsPartition

variable{π}

theorem Union_eq (h : π.is_partition) : π.Union = I :=
  is_partition_iff_Union_eq.1 h

theorem Union_subset (h : π.is_partition) (π₁ : prepartition I) : π₁.Union ⊆ π.Union :=
  h.Union_eq.symm ▸ π₁.Union_subset

protected theorem ExistsUnique (h : π.is_partition) (hx : x ∈ I) : ∃!(J : _)(_ : J ∈ π), x ∈ J :=
  by 
    rcases h x hx with ⟨J, h, hx⟩
    exact ExistsUnique.intro2 J h hx fun J' h' hx' => π.eq_of_mem_of_mem h' h hx' hx

theorem nonempty_boxes (h : π.is_partition) : π.boxes.nonempty :=
  let ⟨J, hJ, _⟩ := h _ I.upper_mem
  ⟨J, hJ⟩

theorem eq_of_boxes_subset (h₁ : π₁.is_partition) (h₂ : π₁.boxes ⊆ π₂.boxes) : π₁ = π₂ :=
  eq_of_boxes_subset_Union_superset h₂$ h₁.Union_subset _

theorem le_iff (h : π₂.is_partition) :
  π₁ ≤ π₂ ↔ ∀ J (_ : J ∈ π₁) J' (_ : J' ∈ π₂), (J ∩ J' : Set (ι → ℝ)).Nonempty → J ≤ J' :=
  le_iff_nonempty_imp_le_and_Union_subset.trans$ and_iff_left$ h.Union_subset _

protected theorem bUnion (h : is_partition π) (hi : ∀ J (_ : J ∈ π), is_partition (πi J)) :
  is_partition (π.bUnion πi) :=
  fun x hx =>
    let ⟨J, hJ, hxi⟩ := h x hx 
    let ⟨Ji, hJi, hx⟩ := hi J hJ x hxi
    ⟨Ji, π.mem_bUnion.2 ⟨J, hJ, hJi⟩, hx⟩

protected theorem restrict (h : is_partition π) (hJ : J ≤ I) : is_partition (π.restrict J) :=
  is_partition_iff_Union_eq.2$
    by 
      simp [h.Union_eq, hJ]

protected theorem inf (h₁ : is_partition π₁) (h₂ : is_partition π₂) : is_partition (π₁⊓π₂) :=
  is_partition_iff_Union_eq.2$
    by 
      simp [h₁.Union_eq, h₂.Union_eq]

end IsPartition

theorem Union_bUnion_partition (h : ∀ J (_ : J ∈ π), (πi J).IsPartition) : (π.bUnion πi).Union = π.Union :=
  (Union_bUnion _ _).trans$
    Union_congr id surjective_id$ fun J => Union_congr id surjective_id$ fun hJ => (h J hJ).Union_eq

theorem is_partition_disj_union_of_eq_diff (h : π₂.Union = I \ π₁.Union) :
  is_partition (π₁.disj_union π₂ (h.symm ▸ disjoint_diff)) :=
  is_partition_iff_Union_eq.2$
    (Union_disj_union _).trans$
      by 
        simp [h, π₁.Union_subset]

end Prepartition

end BoxIntegral

