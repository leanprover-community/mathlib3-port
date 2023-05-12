/-
Copyright (c) 2022 Rishikesh Vaishnav. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rishikesh Vaishnav

! This file was ported from Lean 3 source module probability.conditional_probability
! leanprover-community/mathlib commit 781cb2eed038c4caf53bdbd8d20a95e5822d77df
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Measure.MeasureSpace

/-!
# Conditional Probability

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines conditional probability and includes basic results relating to it.

Given some measure `μ` defined on a measure space on some type `Ω` and some `s : set Ω`,
we define the measure of `μ` conditioned on `s` as the restricted measure scaled by
the inverse of the measure of `s`: `cond μ s = (μ s)⁻¹ • μ.restrict s`. The scaling
ensures that this is a probability measure (when `μ` is a finite measure).

From this definition, we derive the "axiomatic" definition of conditional probability
based on application: for any `s t : set Ω`, we have `μ[t|s] = (μ s)⁻¹ * μ (s ∩ t)`.

## Main Statements

* `cond_cond_eq_cond_inter`: conditioning on one set and then another is equivalent
  to conditioning on their intersection.
* `cond_eq_inv_mul_cond_mul`: Bayes' Theorem, `μ[t|s] = (μ s)⁻¹ * μ[s|t] * (μ t)`.

## Notations

This file uses the notation `μ[|s]` the measure of `μ` conditioned on `s`,
and `μ[t|s]` for the probability of `t` given `s` under `μ` (equivalent to the
application `μ[|s] t`).

These notations are contained in the locale `probability_theory`.

## Implementation notes

Because we have the alternative measure restriction application principles
`measure.restrict_apply` and `measure.restrict_apply'`, which require
measurability of the restricted and restricting sets, respectively,
many of the theorems here will have corresponding alternatives as well.
For the sake of brevity, we've chosen to only go with `measure.restrict_apply'`
for now, but the alternative theorems can be added if needed.

Use of `@[simp]` generally follows the rule of removing conditions on a measure
when possible.

Hypotheses that are used to "define" a conditional distribution by requiring that
the conditioning set has non-zero measure should be named using the abbreviation
"c" (which stands for "conditionable") rather than "nz". For example `(hci : μ (s ∩ t) ≠ 0)`
(rather than `hnzi`) should be used for a hypothesis ensuring that `μ[|s ∩ t]` is defined.

## Tags
conditional, conditioned, bayes
-/


noncomputable section

open ENNReal

open MeasureTheory MeasurableSpace

variable {Ω : Type _} {m : MeasurableSpace Ω} (μ : Measure Ω) {s t : Set Ω}

namespace ProbabilityTheory

section Definitions

#print ProbabilityTheory.cond /-
/-- The conditional probability measure of measure `μ` on set `s` is `μ` restricted to `s`
and scaled by the inverse of `μ s` (to make it a probability measure):
`(μ s)⁻¹ • μ.restrict s`. -/
def cond (s : Set Ω) : Measure Ω :=
  (μ s)⁻¹ • μ.restrict s
#align probability_theory.cond ProbabilityTheory.cond
-/

end Definitions

-- mathport name: probability_theory.cond
scoped notation μ "[" s "|" t "]" => ProbabilityTheory.cond μ t s

-- mathport name: probability_theory.cond_fn
scoped notation:60 μ "[|" t "]" => ProbabilityTheory.cond μ t

/- warning: probability_theory.cond_is_probability_measure -> ProbabilityTheory.cond_probabilityMeasure is a dubious translation:
lean 3 declaration is
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} [_inst_1 : MeasureTheory.FiniteMeasure.{u1} Ω m μ], (Ne.{1} ENNReal (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ s) (OfNat.ofNat.{0} ENNReal 0 (OfNat.mk.{0} ENNReal 0 (Zero.zero.{0} ENNReal ENNReal.hasZero)))) -> (MeasureTheory.ProbabilityMeasure.{u1} Ω m (ProbabilityTheory.cond.{u1} Ω m μ s))
but is expected to have type
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} [_inst_1 : MeasureTheory.FiniteMeasure.{u1} Ω m μ], (Ne.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) s) (OfNat.ofNat.{0} ENNReal 0 (Zero.toOfNat0.{0} ENNReal instENNRealZero))) -> (MeasureTheory.ProbabilityMeasure.{u1} Ω m (ProbabilityTheory.cond.{u1} Ω m μ s))
Case conversion may be inaccurate. Consider using '#align probability_theory.cond_is_probability_measure ProbabilityTheory.cond_probabilityMeasureₓ'. -/
/-- The conditional probability measure of any finite measure on any set of positive measure
is a probability measure. -/
theorem cond_probabilityMeasure [FiniteMeasure μ] (hcs : μ s ≠ 0) : ProbabilityMeasure <| μ[|s] :=
  ⟨by
    rw [cond, measure.smul_apply, measure.restrict_apply MeasurableSet.univ, Set.univ_inter]
    exact ENNReal.inv_mul_cancel hcs (measure_ne_top _ s)⟩
#align probability_theory.cond_is_probability_measure ProbabilityTheory.cond_probabilityMeasure

section Bayes

#print ProbabilityTheory.cond_empty /-
@[simp]
theorem cond_empty : μ[|∅] = 0 := by simp [cond]
#align probability_theory.cond_empty ProbabilityTheory.cond_empty
-/

#print ProbabilityTheory.cond_univ /-
@[simp]
theorem cond_univ [ProbabilityMeasure μ] : μ[|Set.univ] = μ := by
  simp [cond, measure_univ, measure.restrict_univ]
#align probability_theory.cond_univ ProbabilityTheory.cond_univ
-/

/- warning: probability_theory.cond_apply -> ProbabilityTheory.cond_apply is a dubious translation:
lean 3 declaration is
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω}, (MeasurableSet.{u1} Ω m s) -> (forall (t : Set.{u1} Ω), Eq.{1} ENNReal (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) (ProbabilityTheory.cond.{u1} Ω m μ s) t) (HMul.hMul.{0, 0, 0} ENNReal ENNReal ENNReal (instHMul.{0} ENNReal (Distrib.toHasMul.{0} ENNReal (NonUnitalNonAssocSemiring.toDistrib.{0} ENNReal (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} ENNReal (Semiring.toNonAssocSemiring.{0} ENNReal (OrderedSemiring.toSemiring.{0} ENNReal (OrderedCommSemiring.toOrderedSemiring.{0} ENNReal (CanonicallyOrderedCommSemiring.toOrderedCommSemiring.{0} ENNReal ENNReal.canonicallyOrderedCommSemiring)))))))) (Inv.inv.{0} ENNReal ENNReal.hasInv (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ s)) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ (Inter.inter.{u1} (Set.{u1} Ω) (Set.hasInter.{u1} Ω) s t))))
but is expected to have type
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω}, (MeasurableSet.{u1} Ω m s) -> (forall (t : Set.{u1} Ω), Eq.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m (ProbabilityTheory.cond.{u1} Ω m μ s)) t) (HMul.hMul.{0, 0, 0} ENNReal ENNReal ENNReal (instHMul.{0} ENNReal (CanonicallyOrderedCommSemiring.toMul.{0} ENNReal ENNReal.instCanonicallyOrderedCommSemiringENNReal)) (Inv.inv.{0} ENNReal ENNReal.instInvENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) s)) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) (Inter.inter.{u1} (Set.{u1} Ω) (Set.instInterSet.{u1} Ω) s t))))
Case conversion may be inaccurate. Consider using '#align probability_theory.cond_apply ProbabilityTheory.cond_applyₓ'. -/
/-- The axiomatic definition of conditional probability derived from a measure-theoretic one. -/
theorem cond_apply (hms : MeasurableSet s) (t : Set Ω) : μ[t|s] = (μ s)⁻¹ * μ (s ∩ t) :=
  by
  rw [cond, measure.smul_apply, measure.restrict_apply' hms, Set.inter_comm]
  rfl
#align probability_theory.cond_apply ProbabilityTheory.cond_apply

#print ProbabilityTheory.cond_inter_self /-
theorem cond_inter_self (hms : MeasurableSet s) (t : Set Ω) : μ[s ∩ t|s] = μ[t|s] := by
  rw [cond_apply _ hms, ← Set.inter_assoc, Set.inter_self, ← cond_apply _ hms]
#align probability_theory.cond_inter_self ProbabilityTheory.cond_inter_self
-/

/- warning: probability_theory.inter_pos_of_cond_ne_zero -> ProbabilityTheory.inter_pos_of_cond_ne_zero is a dubious translation:
lean 3 declaration is
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} {t : Set.{u1} Ω}, (MeasurableSet.{u1} Ω m s) -> (Ne.{1} ENNReal (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) (ProbabilityTheory.cond.{u1} Ω m μ s) t) (OfNat.ofNat.{0} ENNReal 0 (OfNat.mk.{0} ENNReal 0 (Zero.zero.{0} ENNReal ENNReal.hasZero)))) -> (LT.lt.{0} ENNReal (Preorder.toLT.{0} ENNReal (PartialOrder.toPreorder.{0} ENNReal (CompleteSemilatticeInf.toPartialOrder.{0} ENNReal (CompleteLattice.toCompleteSemilatticeInf.{0} ENNReal (CompleteLinearOrder.toCompleteLattice.{0} ENNReal ENNReal.completeLinearOrder))))) (OfNat.ofNat.{0} ENNReal 0 (OfNat.mk.{0} ENNReal 0 (Zero.zero.{0} ENNReal ENNReal.hasZero))) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ (Inter.inter.{u1} (Set.{u1} Ω) (Set.hasInter.{u1} Ω) s t)))
but is expected to have type
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} {t : Set.{u1} Ω}, (MeasurableSet.{u1} Ω m s) -> (Ne.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m (ProbabilityTheory.cond.{u1} Ω m μ s)) t) (OfNat.ofNat.{0} ENNReal 0 (Zero.toOfNat0.{0} ENNReal instENNRealZero))) -> (LT.lt.{0} ENNReal (Preorder.toLT.{0} ENNReal (PartialOrder.toPreorder.{0} ENNReal (OmegaCompletePartialOrder.toPartialOrder.{0} ENNReal (CompleteLattice.instOmegaCompletePartialOrder.{0} ENNReal (CompleteLinearOrder.toCompleteLattice.{0} ENNReal ENNReal.instCompleteLinearOrderENNReal))))) (OfNat.ofNat.{0} ENNReal 0 (Zero.toOfNat0.{0} ENNReal instENNRealZero)) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) (Inter.inter.{u1} (Set.{u1} Ω) (Set.instInterSet.{u1} Ω) s t)))
Case conversion may be inaccurate. Consider using '#align probability_theory.inter_pos_of_cond_ne_zero ProbabilityTheory.inter_pos_of_cond_ne_zeroₓ'. -/
theorem inter_pos_of_cond_ne_zero (hms : MeasurableSet s) (hcst : μ[t|s] ≠ 0) : 0 < μ (s ∩ t) :=
  by
  refine' pos_iff_ne_zero.mpr (right_ne_zero_of_mul _)
  · exact (μ s)⁻¹
  convert hcst
  simp [hms, Set.inter_comm]
#align probability_theory.inter_pos_of_cond_ne_zero ProbabilityTheory.inter_pos_of_cond_ne_zero

/- warning: probability_theory.cond_pos_of_inter_ne_zero -> ProbabilityTheory.cond_pos_of_inter_ne_zero is a dubious translation:
lean 3 declaration is
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} {t : Set.{u1} Ω} [_inst_1 : MeasureTheory.FiniteMeasure.{u1} Ω m μ], (MeasurableSet.{u1} Ω m s) -> (Ne.{1} ENNReal (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ (Inter.inter.{u1} (Set.{u1} Ω) (Set.hasInter.{u1} Ω) s t)) (OfNat.ofNat.{0} ENNReal 0 (OfNat.mk.{0} ENNReal 0 (Zero.zero.{0} ENNReal ENNReal.hasZero)))) -> (LT.lt.{0} ENNReal (Preorder.toLT.{0} ENNReal (PartialOrder.toPreorder.{0} ENNReal (CompleteSemilatticeInf.toPartialOrder.{0} ENNReal (CompleteLattice.toCompleteSemilatticeInf.{0} ENNReal (CompleteLinearOrder.toCompleteLattice.{0} ENNReal ENNReal.completeLinearOrder))))) (OfNat.ofNat.{0} ENNReal 0 (OfNat.mk.{0} ENNReal 0 (Zero.zero.{0} ENNReal ENNReal.hasZero))) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) (ProbabilityTheory.cond.{u1} Ω m μ s) t))
but is expected to have type
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} {t : Set.{u1} Ω} [_inst_1 : MeasureTheory.FiniteMeasure.{u1} Ω m μ], (MeasurableSet.{u1} Ω m s) -> (Ne.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) (Inter.inter.{u1} (Set.{u1} Ω) (Set.instInterSet.{u1} Ω) s t)) (OfNat.ofNat.{0} ENNReal 0 (Zero.toOfNat0.{0} ENNReal instENNRealZero))) -> (LT.lt.{0} ENNReal (Preorder.toLT.{0} ENNReal (PartialOrder.toPreorder.{0} ENNReal (OmegaCompletePartialOrder.toPartialOrder.{0} ENNReal (CompleteLattice.instOmegaCompletePartialOrder.{0} ENNReal (CompleteLinearOrder.toCompleteLattice.{0} ENNReal ENNReal.instCompleteLinearOrderENNReal))))) (OfNat.ofNat.{0} ENNReal 0 (Zero.toOfNat0.{0} ENNReal instENNRealZero)) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m (ProbabilityTheory.cond.{u1} Ω m μ s)) t))
Case conversion may be inaccurate. Consider using '#align probability_theory.cond_pos_of_inter_ne_zero ProbabilityTheory.cond_pos_of_inter_ne_zeroₓ'. -/
theorem cond_pos_of_inter_ne_zero [FiniteMeasure μ] (hms : MeasurableSet s) (hci : μ (s ∩ t) ≠ 0) :
    0 < (μ[|s]) t := by
  rw [cond_apply _ hms]
  refine' ENNReal.mul_pos _ hci
  exact ennreal.inv_ne_zero.mpr (measure_ne_top _ _)
#align probability_theory.cond_pos_of_inter_ne_zero ProbabilityTheory.cond_pos_of_inter_ne_zero

/- warning: probability_theory.cond_cond_eq_cond_inter' -> ProbabilityTheory.cond_cond_eq_cond_inter' is a dubious translation:
lean 3 declaration is
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} {t : Set.{u1} Ω}, (MeasurableSet.{u1} Ω m s) -> (MeasurableSet.{u1} Ω m t) -> (Ne.{1} ENNReal (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ s) (Top.top.{0} ENNReal (CompleteLattice.toHasTop.{0} ENNReal (CompleteLinearOrder.toCompleteLattice.{0} ENNReal ENNReal.completeLinearOrder)))) -> (Ne.{1} ENNReal (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ (Inter.inter.{u1} (Set.{u1} Ω) (Set.hasInter.{u1} Ω) s t)) (OfNat.ofNat.{0} ENNReal 0 (OfNat.mk.{0} ENNReal 0 (Zero.zero.{0} ENNReal ENNReal.hasZero)))) -> (Eq.{succ u1} (MeasureTheory.Measure.{u1} Ω m) (ProbabilityTheory.cond.{u1} Ω m (ProbabilityTheory.cond.{u1} Ω m μ s) t) (ProbabilityTheory.cond.{u1} Ω m μ (Inter.inter.{u1} (Set.{u1} Ω) (Set.hasInter.{u1} Ω) s t)))
but is expected to have type
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} {t : Set.{u1} Ω}, (MeasurableSet.{u1} Ω m s) -> (MeasurableSet.{u1} Ω m t) -> (Ne.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) s) (Top.top.{0} ENNReal (CompleteLattice.toTop.{0} ENNReal (CompleteLinearOrder.toCompleteLattice.{0} ENNReal ENNReal.instCompleteLinearOrderENNReal)))) -> (Ne.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) (Inter.inter.{u1} (Set.{u1} Ω) (Set.instInterSet.{u1} Ω) s t)) (OfNat.ofNat.{0} ENNReal 0 (Zero.toOfNat0.{0} ENNReal instENNRealZero))) -> (Eq.{succ u1} (MeasureTheory.Measure.{u1} Ω m) (ProbabilityTheory.cond.{u1} Ω m (ProbabilityTheory.cond.{u1} Ω m μ s) t) (ProbabilityTheory.cond.{u1} Ω m μ (Inter.inter.{u1} (Set.{u1} Ω) (Set.instInterSet.{u1} Ω) s t)))
Case conversion may be inaccurate. Consider using '#align probability_theory.cond_cond_eq_cond_inter' ProbabilityTheory.cond_cond_eq_cond_inter'ₓ'. -/
theorem cond_cond_eq_cond_inter' (hms : MeasurableSet s) (hmt : MeasurableSet t) (hcs : μ s ≠ ∞)
    (hci : μ (s ∩ t) ≠ 0) : μ[|s][|t] = μ[|s ∩ t] :=
  by
  have hcs : μ s ≠ 0 :=
    (μ.to_outer_measure.pos_of_subset_ne_zero (Set.inter_subset_left _ _) hci).ne'
  ext u
  simp [*, hms.inter hmt, cond_apply, ← mul_assoc, ← Set.inter_assoc, ENNReal.mul_inv, mul_comm, ←
    mul_assoc, ENNReal.inv_mul_cancel]
#align probability_theory.cond_cond_eq_cond_inter' ProbabilityTheory.cond_cond_eq_cond_inter'

/- warning: probability_theory.cond_cond_eq_cond_inter -> ProbabilityTheory.cond_cond_eq_cond_inter is a dubious translation:
lean 3 declaration is
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} {t : Set.{u1} Ω} [_inst_1 : MeasureTheory.FiniteMeasure.{u1} Ω m μ], (MeasurableSet.{u1} Ω m s) -> (MeasurableSet.{u1} Ω m t) -> (Ne.{1} ENNReal (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ (Inter.inter.{u1} (Set.{u1} Ω) (Set.hasInter.{u1} Ω) s t)) (OfNat.ofNat.{0} ENNReal 0 (OfNat.mk.{0} ENNReal 0 (Zero.zero.{0} ENNReal ENNReal.hasZero)))) -> (Eq.{succ u1} (MeasureTheory.Measure.{u1} Ω m) (ProbabilityTheory.cond.{u1} Ω m (ProbabilityTheory.cond.{u1} Ω m μ s) t) (ProbabilityTheory.cond.{u1} Ω m μ (Inter.inter.{u1} (Set.{u1} Ω) (Set.hasInter.{u1} Ω) s t)))
but is expected to have type
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} {t : Set.{u1} Ω} [_inst_1 : MeasureTheory.FiniteMeasure.{u1} Ω m μ], (MeasurableSet.{u1} Ω m s) -> (MeasurableSet.{u1} Ω m t) -> (Ne.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) (Inter.inter.{u1} (Set.{u1} Ω) (Set.instInterSet.{u1} Ω) s t)) (OfNat.ofNat.{0} ENNReal 0 (Zero.toOfNat0.{0} ENNReal instENNRealZero))) -> (Eq.{succ u1} (MeasureTheory.Measure.{u1} Ω m) (ProbabilityTheory.cond.{u1} Ω m (ProbabilityTheory.cond.{u1} Ω m μ s) t) (ProbabilityTheory.cond.{u1} Ω m μ (Inter.inter.{u1} (Set.{u1} Ω) (Set.instInterSet.{u1} Ω) s t)))
Case conversion may be inaccurate. Consider using '#align probability_theory.cond_cond_eq_cond_inter ProbabilityTheory.cond_cond_eq_cond_interₓ'. -/
/-- Conditioning first on `s` and then on `t` results in the same measure as conditioning
on `s ∩ t`. -/
theorem cond_cond_eq_cond_inter [FiniteMeasure μ] (hms : MeasurableSet s) (hmt : MeasurableSet t)
    (hci : μ (s ∩ t) ≠ 0) : μ[|s][|t] = μ[|s ∩ t] :=
  cond_cond_eq_cond_inter' μ hms hmt (measure_ne_top μ s) hci
#align probability_theory.cond_cond_eq_cond_inter ProbabilityTheory.cond_cond_eq_cond_inter

/- warning: probability_theory.cond_mul_eq_inter' -> ProbabilityTheory.cond_mul_eq_inter' is a dubious translation:
lean 3 declaration is
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω}, (MeasurableSet.{u1} Ω m s) -> (Ne.{1} ENNReal (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ s) (OfNat.ofNat.{0} ENNReal 0 (OfNat.mk.{0} ENNReal 0 (Zero.zero.{0} ENNReal ENNReal.hasZero)))) -> (Ne.{1} ENNReal (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ s) (Top.top.{0} ENNReal (CompleteLattice.toHasTop.{0} ENNReal (CompleteLinearOrder.toCompleteLattice.{0} ENNReal ENNReal.completeLinearOrder)))) -> (forall (t : Set.{u1} Ω), Eq.{1} ENNReal (HMul.hMul.{0, 0, 0} ENNReal ENNReal ENNReal (instHMul.{0} ENNReal (Distrib.toHasMul.{0} ENNReal (NonUnitalNonAssocSemiring.toDistrib.{0} ENNReal (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} ENNReal (Semiring.toNonAssocSemiring.{0} ENNReal (OrderedSemiring.toSemiring.{0} ENNReal (OrderedCommSemiring.toOrderedSemiring.{0} ENNReal (CanonicallyOrderedCommSemiring.toOrderedCommSemiring.{0} ENNReal ENNReal.canonicallyOrderedCommSemiring)))))))) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) (ProbabilityTheory.cond.{u1} Ω m μ s) t) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ s)) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ (Inter.inter.{u1} (Set.{u1} Ω) (Set.hasInter.{u1} Ω) s t)))
but is expected to have type
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω}, (MeasurableSet.{u1} Ω m s) -> (Ne.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) s) (OfNat.ofNat.{0} ENNReal 0 (Zero.toOfNat0.{0} ENNReal instENNRealZero))) -> (Ne.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) s) (Top.top.{0} ENNReal (CompleteLattice.toTop.{0} ENNReal (CompleteLinearOrder.toCompleteLattice.{0} ENNReal ENNReal.instCompleteLinearOrderENNReal)))) -> (forall (t : Set.{u1} Ω), Eq.{1} ENNReal (HMul.hMul.{0, 0, 0} ENNReal ENNReal ENNReal (instHMul.{0} ENNReal (CanonicallyOrderedCommSemiring.toMul.{0} ENNReal ENNReal.instCanonicallyOrderedCommSemiringENNReal)) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m (ProbabilityTheory.cond.{u1} Ω m μ s)) t) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) s)) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) (Inter.inter.{u1} (Set.{u1} Ω) (Set.instInterSet.{u1} Ω) s t)))
Case conversion may be inaccurate. Consider using '#align probability_theory.cond_mul_eq_inter' ProbabilityTheory.cond_mul_eq_inter'ₓ'. -/
theorem cond_mul_eq_inter' (hms : MeasurableSet s) (hcs : μ s ≠ 0) (hcs' : μ s ≠ ∞) (t : Set Ω) :
    μ[t|s] * μ s = μ (s ∩ t) := by
  rw [cond_apply μ hms t, mul_comm, ← mul_assoc, ENNReal.mul_inv_cancel hcs hcs', one_mul]
#align probability_theory.cond_mul_eq_inter' ProbabilityTheory.cond_mul_eq_inter'

/- warning: probability_theory.cond_mul_eq_inter -> ProbabilityTheory.cond_mul_eq_inter is a dubious translation:
lean 3 declaration is
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} [_inst_1 : MeasureTheory.FiniteMeasure.{u1} Ω m μ], (MeasurableSet.{u1} Ω m s) -> (Ne.{1} ENNReal (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ s) (OfNat.ofNat.{0} ENNReal 0 (OfNat.mk.{0} ENNReal 0 (Zero.zero.{0} ENNReal ENNReal.hasZero)))) -> (forall (t : Set.{u1} Ω), Eq.{1} ENNReal (HMul.hMul.{0, 0, 0} ENNReal ENNReal ENNReal (instHMul.{0} ENNReal (Distrib.toHasMul.{0} ENNReal (NonUnitalNonAssocSemiring.toDistrib.{0} ENNReal (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} ENNReal (Semiring.toNonAssocSemiring.{0} ENNReal (OrderedSemiring.toSemiring.{0} ENNReal (OrderedCommSemiring.toOrderedSemiring.{0} ENNReal (CanonicallyOrderedCommSemiring.toOrderedCommSemiring.{0} ENNReal ENNReal.canonicallyOrderedCommSemiring)))))))) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) (ProbabilityTheory.cond.{u1} Ω m μ s) t) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ s)) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ (Inter.inter.{u1} (Set.{u1} Ω) (Set.hasInter.{u1} Ω) s t)))
but is expected to have type
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} [_inst_1 : MeasureTheory.FiniteMeasure.{u1} Ω m μ], (MeasurableSet.{u1} Ω m s) -> (Ne.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) s) (OfNat.ofNat.{0} ENNReal 0 (Zero.toOfNat0.{0} ENNReal instENNRealZero))) -> (forall (t : Set.{u1} Ω), Eq.{1} ENNReal (HMul.hMul.{0, 0, 0} ENNReal ENNReal ENNReal (instHMul.{0} ENNReal (CanonicallyOrderedCommSemiring.toMul.{0} ENNReal ENNReal.instCanonicallyOrderedCommSemiringENNReal)) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m (ProbabilityTheory.cond.{u1} Ω m μ s)) t) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) s)) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) (Inter.inter.{u1} (Set.{u1} Ω) (Set.instInterSet.{u1} Ω) s t)))
Case conversion may be inaccurate. Consider using '#align probability_theory.cond_mul_eq_inter ProbabilityTheory.cond_mul_eq_interₓ'. -/
theorem cond_mul_eq_inter [FiniteMeasure μ] (hms : MeasurableSet s) (hcs : μ s ≠ 0) (t : Set Ω) :
    μ[t|s] * μ s = μ (s ∩ t) :=
  cond_mul_eq_inter' μ hms hcs (measure_ne_top _ s) t
#align probability_theory.cond_mul_eq_inter ProbabilityTheory.cond_mul_eq_inter

/- warning: probability_theory.cond_add_cond_compl_eq -> ProbabilityTheory.cond_add_cond_compl_eq is a dubious translation:
lean 3 declaration is
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} {t : Set.{u1} Ω} [_inst_1 : MeasureTheory.FiniteMeasure.{u1} Ω m μ], (MeasurableSet.{u1} Ω m s) -> (Ne.{1} ENNReal (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ s) (OfNat.ofNat.{0} ENNReal 0 (OfNat.mk.{0} ENNReal 0 (Zero.zero.{0} ENNReal ENNReal.hasZero)))) -> (Ne.{1} ENNReal (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ (HasCompl.compl.{u1} (Set.{u1} Ω) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} Ω) (Set.booleanAlgebra.{u1} Ω)) s)) (OfNat.ofNat.{0} ENNReal 0 (OfNat.mk.{0} ENNReal 0 (Zero.zero.{0} ENNReal ENNReal.hasZero)))) -> (Eq.{1} ENNReal (HAdd.hAdd.{0, 0, 0} ENNReal ENNReal ENNReal (instHAdd.{0} ENNReal (Distrib.toHasAdd.{0} ENNReal (NonUnitalNonAssocSemiring.toDistrib.{0} ENNReal (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} ENNReal (Semiring.toNonAssocSemiring.{0} ENNReal (OrderedSemiring.toSemiring.{0} ENNReal (OrderedCommSemiring.toOrderedSemiring.{0} ENNReal (CanonicallyOrderedCommSemiring.toOrderedCommSemiring.{0} ENNReal ENNReal.canonicallyOrderedCommSemiring)))))))) (HMul.hMul.{0, 0, 0} ENNReal ENNReal ENNReal (instHMul.{0} ENNReal (Distrib.toHasMul.{0} ENNReal (NonUnitalNonAssocSemiring.toDistrib.{0} ENNReal (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} ENNReal (Semiring.toNonAssocSemiring.{0} ENNReal (OrderedSemiring.toSemiring.{0} ENNReal (OrderedCommSemiring.toOrderedSemiring.{0} ENNReal (CanonicallyOrderedCommSemiring.toOrderedCommSemiring.{0} ENNReal ENNReal.canonicallyOrderedCommSemiring)))))))) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) (ProbabilityTheory.cond.{u1} Ω m μ s) t) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ s)) (HMul.hMul.{0, 0, 0} ENNReal ENNReal ENNReal (instHMul.{0} ENNReal (Distrib.toHasMul.{0} ENNReal (NonUnitalNonAssocSemiring.toDistrib.{0} ENNReal (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} ENNReal (Semiring.toNonAssocSemiring.{0} ENNReal (OrderedSemiring.toSemiring.{0} ENNReal (OrderedCommSemiring.toOrderedSemiring.{0} ENNReal (CanonicallyOrderedCommSemiring.toOrderedCommSemiring.{0} ENNReal ENNReal.canonicallyOrderedCommSemiring)))))))) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) (ProbabilityTheory.cond.{u1} Ω m μ (HasCompl.compl.{u1} (Set.{u1} Ω) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} Ω) (Set.booleanAlgebra.{u1} Ω)) s)) t) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ (HasCompl.compl.{u1} (Set.{u1} Ω) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} Ω) (Set.booleanAlgebra.{u1} Ω)) s)))) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ t))
but is expected to have type
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} {t : Set.{u1} Ω} [_inst_1 : MeasureTheory.FiniteMeasure.{u1} Ω m μ], (MeasurableSet.{u1} Ω m s) -> (Ne.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) s) (OfNat.ofNat.{0} ENNReal 0 (Zero.toOfNat0.{0} ENNReal instENNRealZero))) -> (Ne.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) (HasCompl.compl.{u1} (Set.{u1} Ω) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} Ω) (Set.instBooleanAlgebraSet.{u1} Ω)) s)) (OfNat.ofNat.{0} ENNReal 0 (Zero.toOfNat0.{0} ENNReal instENNRealZero))) -> (Eq.{1} ENNReal (HAdd.hAdd.{0, 0, 0} ENNReal ENNReal ENNReal (instHAdd.{0} ENNReal (Distrib.toAdd.{0} ENNReal (NonUnitalNonAssocSemiring.toDistrib.{0} ENNReal (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} ENNReal (Semiring.toNonAssocSemiring.{0} ENNReal (OrderedSemiring.toSemiring.{0} ENNReal (OrderedCommSemiring.toOrderedSemiring.{0} ENNReal (CanonicallyOrderedCommSemiring.toOrderedCommSemiring.{0} ENNReal ENNReal.instCanonicallyOrderedCommSemiringENNReal)))))))) (HMul.hMul.{0, 0, 0} ENNReal ENNReal ENNReal (instHMul.{0} ENNReal (CanonicallyOrderedCommSemiring.toMul.{0} ENNReal ENNReal.instCanonicallyOrderedCommSemiringENNReal)) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m (ProbabilityTheory.cond.{u1} Ω m μ s)) t) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) s)) (HMul.hMul.{0, 0, 0} ENNReal ENNReal ENNReal (instHMul.{0} ENNReal (CanonicallyOrderedCommSemiring.toMul.{0} ENNReal ENNReal.instCanonicallyOrderedCommSemiringENNReal)) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m (ProbabilityTheory.cond.{u1} Ω m μ (HasCompl.compl.{u1} (Set.{u1} Ω) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} Ω) (Set.instBooleanAlgebraSet.{u1} Ω)) s))) t) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) (HasCompl.compl.{u1} (Set.{u1} Ω) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} Ω) (Set.instBooleanAlgebraSet.{u1} Ω)) s)))) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) t))
Case conversion may be inaccurate. Consider using '#align probability_theory.cond_add_cond_compl_eq ProbabilityTheory.cond_add_cond_compl_eqₓ'. -/
/-- A version of the law of total probability. -/
theorem cond_add_cond_compl_eq [FiniteMeasure μ] (hms : MeasurableSet s) (hcs : μ s ≠ 0)
    (hcs' : μ (sᶜ) ≠ 0) : μ[t|s] * μ s + μ[t|sᶜ] * μ (sᶜ) = μ t :=
  by
  rw [cond_mul_eq_inter μ hms hcs, cond_mul_eq_inter μ hms.compl hcs', Set.inter_comm _ t,
    Set.inter_comm _ t]
  exact measure_inter_add_diff t hms
#align probability_theory.cond_add_cond_compl_eq ProbabilityTheory.cond_add_cond_compl_eq

/- warning: probability_theory.cond_eq_inv_mul_cond_mul -> ProbabilityTheory.cond_eq_inv_mul_cond_mul is a dubious translation:
lean 3 declaration is
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} {t : Set.{u1} Ω} [_inst_1 : MeasureTheory.FiniteMeasure.{u1} Ω m μ], (MeasurableSet.{u1} Ω m s) -> (MeasurableSet.{u1} Ω m t) -> (Eq.{1} ENNReal (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) (ProbabilityTheory.cond.{u1} Ω m μ s) t) (HMul.hMul.{0, 0, 0} ENNReal ENNReal ENNReal (instHMul.{0} ENNReal (Distrib.toHasMul.{0} ENNReal (NonUnitalNonAssocSemiring.toDistrib.{0} ENNReal (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} ENNReal (Semiring.toNonAssocSemiring.{0} ENNReal (OrderedSemiring.toSemiring.{0} ENNReal (OrderedCommSemiring.toOrderedSemiring.{0} ENNReal (CanonicallyOrderedCommSemiring.toOrderedCommSemiring.{0} ENNReal ENNReal.canonicallyOrderedCommSemiring)))))))) (HMul.hMul.{0, 0, 0} ENNReal ENNReal ENNReal (instHMul.{0} ENNReal (Distrib.toHasMul.{0} ENNReal (NonUnitalNonAssocSemiring.toDistrib.{0} ENNReal (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} ENNReal (Semiring.toNonAssocSemiring.{0} ENNReal (OrderedSemiring.toSemiring.{0} ENNReal (OrderedCommSemiring.toOrderedSemiring.{0} ENNReal (CanonicallyOrderedCommSemiring.toOrderedCommSemiring.{0} ENNReal ENNReal.canonicallyOrderedCommSemiring)))))))) (Inv.inv.{0} ENNReal ENNReal.hasInv (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ s)) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) (ProbabilityTheory.cond.{u1} Ω m μ t) s)) (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} Ω m) (fun (_x : MeasureTheory.Measure.{u1} Ω m) => (Set.{u1} Ω) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} Ω m) μ t)))
but is expected to have type
  forall {Ω : Type.{u1}} {m : MeasurableSpace.{u1} Ω} (μ : MeasureTheory.Measure.{u1} Ω m) {s : Set.{u1} Ω} {t : Set.{u1} Ω} [_inst_1 : MeasureTheory.FiniteMeasure.{u1} Ω m μ], (MeasurableSet.{u1} Ω m s) -> (MeasurableSet.{u1} Ω m t) -> (Eq.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m (ProbabilityTheory.cond.{u1} Ω m μ s)) t) (HMul.hMul.{0, 0, 0} ENNReal ENNReal ENNReal (instHMul.{0} ENNReal (CanonicallyOrderedCommSemiring.toMul.{0} ENNReal ENNReal.instCanonicallyOrderedCommSemiringENNReal)) (HMul.hMul.{0, 0, 0} ENNReal ENNReal ENNReal (instHMul.{0} ENNReal (CanonicallyOrderedCommSemiring.toMul.{0} ENNReal ENNReal.instCanonicallyOrderedCommSemiringENNReal)) (Inv.inv.{0} ENNReal ENNReal.instInvENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) s)) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m (ProbabilityTheory.cond.{u1} Ω m μ t)) s)) (MeasureTheory.OuterMeasure.measureOf.{u1} Ω (MeasureTheory.Measure.toOuterMeasure.{u1} Ω m μ) t)))
Case conversion may be inaccurate. Consider using '#align probability_theory.cond_eq_inv_mul_cond_mul ProbabilityTheory.cond_eq_inv_mul_cond_mulₓ'. -/
/-- **Bayes' Theorem** -/
theorem cond_eq_inv_mul_cond_mul [FiniteMeasure μ] (hms : MeasurableSet s) (hmt : MeasurableSet t) :
    μ[t|s] = (μ s)⁻¹ * μ[s|t] * μ t := by
  by_cases ht : μ t = 0
  · simp [cond, ht, measure.restrict_apply hmt, Or.inr (measure_inter_null_of_null_left s ht)]
  · rw [mul_assoc, cond_mul_eq_inter μ hmt ht s, Set.inter_comm, cond_apply _ hms]
#align probability_theory.cond_eq_inv_mul_cond_mul ProbabilityTheory.cond_eq_inv_mul_cond_mul

end Bayes

end ProbabilityTheory

