/-
Copyright (c) 2020 Joseph Myers. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Myers
-/
import Mathbin.Algebra.Invertible
import Mathbin.Algebra.IndicatorFunction
import Mathbin.LinearAlgebra.AffineSpace.AffineMap
import Mathbin.LinearAlgebra.AffineSpace.AffineSubspace
import Mathbin.LinearAlgebra.Finsupp
import Mathbin.Tactic.FinCases

/-!
# Affine combinations of points

This file defines affine combinations of points.

## Main definitions

* `weighted_vsub_of_point` is a general weighted combination of
  subtractions with an explicit base point, yielding a vector.

* `weighted_vsub` uses an arbitrary choice of base point and is intended
  to be used when the sum of weights is 0, in which case the result is
  independent of the choice of base point.

* `affine_combination` adds the weighted combination to the arbitrary
  base point, yielding a point rather than a vector, and is intended
  to be used when the sum of weights is 1, in which case the result is
  independent of the choice of base point.

These definitions are for sums over a `finset`; versions for a
`fintype` may be obtained using `finset.univ`, while versions for a
`finsupp` may be obtained using `finsupp.support`.

## References

* https://en.wikipedia.org/wiki/Affine_space

-/


noncomputable section

open BigOperators Affine

namespace Finset

/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:31:4: unsupported: too many args: fin_cases ... #[[]] -/
theorem univ_fin2 : (univ : Finset (Fin 2)) = {0, 1} := by
  ext x
  fin_cases x <;> simp
#align finset.univ_fin2 Finset.univ_fin2

variable {k : Type _} {V : Type _} {P : Type _} [Ring k] [AddCommGroup V] [Module k V]

variable [S : affine_space V P]

include S

variable {ι : Type _} (s : Finset ι)

variable {ι₂ : Type _} (s₂ : Finset ι₂)

/-- A weighted sum of the results of subtracting a base point from the
given points, as a linear map on the weights.  The main cases of
interest are where the sum of the weights is 0, in which case the sum
is independent of the choice of base point, and where the sum of the
weights is 1, in which case the sum added to the base point is
independent of the choice of base point. -/
def weightedVsubOfPoint (p : ι → P) (b : P) : (ι → k) →ₗ[k] V :=
  ∑ i in s, (LinearMap.proj i : (ι → k) →ₗ[k] k).smul_right (p i -ᵥ b)
#align finset.weighted_vsub_of_point Finset.weightedVsubOfPoint

@[simp]
theorem weighted_vsub_of_point_apply (w : ι → k) (p : ι → P) (b : P) :
    s.weightedVsubOfPoint p b w = ∑ i in s, w i • (p i -ᵥ b) := by simp [weighted_vsub_of_point, LinearMap.sum_apply]
#align finset.weighted_vsub_of_point_apply Finset.weighted_vsub_of_point_apply

/-- The value of `weighted_vsub_of_point`, where the given points are equal. -/
@[simp]
theorem weighted_vsub_of_point_apply_const (w : ι → k) (p : P) (b : P) :
    s.weightedVsubOfPoint (fun _ => p) b w = (∑ i in s, w i) • (p -ᵥ b) := by
  rw [weighted_vsub_of_point_apply, sum_smul]
#align finset.weighted_vsub_of_point_apply_const Finset.weighted_vsub_of_point_apply_const

/-- Given a family of points, if we use a member of the family as a base point, the
`weighted_vsub_of_point` does not depend on the value of the weights at this point. -/
theorem weighted_vsub_of_point_eq_of_weights_eq (p : ι → P) (j : ι) (w₁ w₂ : ι → k) (hw : ∀ i, i ≠ j → w₁ i = w₂ i) :
    s.weightedVsubOfPoint p (p j) w₁ = s.weightedVsubOfPoint p (p j) w₂ := by
  simp only [Finset.weighted_vsub_of_point_apply]
  congr
  ext i
  cases' eq_or_ne i j with h h
  · simp [h]
    
  · simp [hw i h]
    
#align finset.weighted_vsub_of_point_eq_of_weights_eq Finset.weighted_vsub_of_point_eq_of_weights_eq

/-- The weighted sum is independent of the base point when the sum of
the weights is 0. -/
theorem weighted_vsub_of_point_eq_of_sum_eq_zero (w : ι → k) (p : ι → P) (h : (∑ i in s, w i) = 0) (b₁ b₂ : P) :
    s.weightedVsubOfPoint p b₁ w = s.weightedVsubOfPoint p b₂ w := by
  apply eq_of_sub_eq_zero
  rw [weighted_vsub_of_point_apply, weighted_vsub_of_point_apply, ← sum_sub_distrib]
  conv_lhs =>
  congr
  skip
  ext
  rw [← smul_sub, vsub_sub_vsub_cancel_left]
  rw [← sum_smul, h, zero_smul]
#align finset.weighted_vsub_of_point_eq_of_sum_eq_zero Finset.weighted_vsub_of_point_eq_of_sum_eq_zero

/-- The weighted sum, added to the base point, is independent of the
base point when the sum of the weights is 1. -/
theorem weighted_vsub_of_point_vadd_eq_of_sum_eq_one (w : ι → k) (p : ι → P) (h : (∑ i in s, w i) = 1) (b₁ b₂ : P) :
    s.weightedVsubOfPoint p b₁ w +ᵥ b₁ = s.weightedVsubOfPoint p b₂ w +ᵥ b₂ := by
  erw [weighted_vsub_of_point_apply, weighted_vsub_of_point_apply, ← @vsub_eq_zero_iff_eq V, vadd_vsub_assoc,
    vsub_vadd_eq_vsub_sub, ← add_sub_assoc, add_comm, add_sub_assoc, ← sum_sub_distrib]
  conv_lhs =>
  congr
  skip
  congr
  skip
  ext
  rw [← smul_sub, vsub_sub_vsub_cancel_left]
  rw [← sum_smul, h, one_smul, vsub_add_vsub_cancel, vsub_self]
#align finset.weighted_vsub_of_point_vadd_eq_of_sum_eq_one Finset.weighted_vsub_of_point_vadd_eq_of_sum_eq_one

/-- The weighted sum is unaffected by removing the base point, if
present, from the set of points. -/
@[simp]
theorem weighted_vsub_of_point_erase [DecidableEq ι] (w : ι → k) (p : ι → P) (i : ι) :
    (s.erase i).weightedVsubOfPoint p (p i) w = s.weightedVsubOfPoint p (p i) w := by
  rw [weighted_vsub_of_point_apply, weighted_vsub_of_point_apply]
  apply sum_erase
  rw [vsub_self, smul_zero]
#align finset.weighted_vsub_of_point_erase Finset.weighted_vsub_of_point_erase

/-- The weighted sum is unaffected by adding the base point, whether
or not present, to the set of points. -/
@[simp]
theorem weighted_vsub_of_point_insert [DecidableEq ι] (w : ι → k) (p : ι → P) (i : ι) :
    (insert i s).weightedVsubOfPoint p (p i) w = s.weightedVsubOfPoint p (p i) w := by
  rw [weighted_vsub_of_point_apply, weighted_vsub_of_point_apply]
  apply sum_insert_zero
  rw [vsub_self, smul_zero]
#align finset.weighted_vsub_of_point_insert Finset.weighted_vsub_of_point_insert

/-- The weighted sum is unaffected by changing the weights to the
corresponding indicator function and adding points to the set. -/
theorem weighted_vsub_of_point_indicator_subset (w : ι → k) (p : ι → P) (b : P) {s₁ s₂ : Finset ι} (h : s₁ ⊆ s₂) :
    s₁.weightedVsubOfPoint p b w = s₂.weightedVsubOfPoint p b (Set.indicator (↑s₁) w) := by
  rw [weighted_vsub_of_point_apply, weighted_vsub_of_point_apply]
  exact Set.sum_indicator_subset_of_eq_zero w (fun i wi => wi • (p i -ᵥ b : V)) h fun i => zero_smul k _
#align finset.weighted_vsub_of_point_indicator_subset Finset.weighted_vsub_of_point_indicator_subset

/-- A weighted sum, over the image of an embedding, equals a weighted
sum with the same points and weights over the original
`finset`. -/
theorem weighted_vsub_of_point_map (e : ι₂ ↪ ι) (w : ι → k) (p : ι → P) (b : P) :
    (s₂.map e).weightedVsubOfPoint p b w = s₂.weightedVsubOfPoint (p ∘ e) b (w ∘ e) := by
  simp_rw [weighted_vsub_of_point_apply]
  exact Finset.sum_map _ _ _
#align finset.weighted_vsub_of_point_map Finset.weighted_vsub_of_point_map

/-- A weighted sum of pairwise subtractions, expressed as a subtraction of two
`weighted_vsub_of_point` expressions. -/
theorem sum_smul_vsub_eq_weighted_vsub_of_point_sub (w : ι → k) (p₁ p₂ : ι → P) (b : P) :
    (∑ i in s, w i • (p₁ i -ᵥ p₂ i)) = s.weightedVsubOfPoint p₁ b w - s.weightedVsubOfPoint p₂ b w := by
  simp_rw [weighted_vsub_of_point_apply, ← sum_sub_distrib, ← smul_sub, vsub_sub_vsub_cancel_right]
#align finset.sum_smul_vsub_eq_weighted_vsub_of_point_sub Finset.sum_smul_vsub_eq_weighted_vsub_of_point_sub

/-- A weighted sum of pairwise subtractions, where the point on the right is constant,
expressed as a subtraction involving a `weighted_vsub_of_point` expression. -/
theorem sum_smul_vsub_const_eq_weighted_vsub_of_point_sub (w : ι → k) (p₁ : ι → P) (p₂ b : P) :
    (∑ i in s, w i • (p₁ i -ᵥ p₂)) = s.weightedVsubOfPoint p₁ b w - (∑ i in s, w i) • (p₂ -ᵥ b) := by
  rw [sum_smul_vsub_eq_weighted_vsub_of_point_sub, weighted_vsub_of_point_apply_const]
#align finset.sum_smul_vsub_const_eq_weighted_vsub_of_point_sub Finset.sum_smul_vsub_const_eq_weighted_vsub_of_point_sub

/-- A weighted sum of pairwise subtractions, where the point on the left is constant,
expressed as a subtraction involving a `weighted_vsub_of_point` expression. -/
theorem sum_smul_const_vsub_eq_sub_weighted_vsub_of_point (w : ι → k) (p₂ : ι → P) (p₁ b : P) :
    (∑ i in s, w i • (p₁ -ᵥ p₂ i)) = (∑ i in s, w i) • (p₁ -ᵥ b) - s.weightedVsubOfPoint p₂ b w := by
  rw [sum_smul_vsub_eq_weighted_vsub_of_point_sub, weighted_vsub_of_point_apply_const]
#align finset.sum_smul_const_vsub_eq_sub_weighted_vsub_of_point Finset.sum_smul_const_vsub_eq_sub_weighted_vsub_of_point

/-- A weighted sum may be split into such sums over two subsets. -/
theorem weighted_vsub_of_point_sdiff [DecidableEq ι] {s₂ : Finset ι} (h : s₂ ⊆ s) (w : ι → k) (p : ι → P) (b : P) :
    (s \ s₂).weightedVsubOfPoint p b w + s₂.weightedVsubOfPoint p b w = s.weightedVsubOfPoint p b w := by
  simp_rw [weighted_vsub_of_point_apply, sum_sdiff h]
#align finset.weighted_vsub_of_point_sdiff Finset.weighted_vsub_of_point_sdiff

/-- A weighted sum may be split into a subtraction of such sums over two subsets. -/
theorem weighted_vsub_of_point_sdiff_sub [DecidableEq ι] {s₂ : Finset ι} (h : s₂ ⊆ s) (w : ι → k) (p : ι → P) (b : P) :
    (s \ s₂).weightedVsubOfPoint p b w - s₂.weightedVsubOfPoint p b (-w) = s.weightedVsubOfPoint p b w := by
  rw [map_neg, sub_neg_eq_add, s.weighted_vsub_of_point_sdiff h]
#align finset.weighted_vsub_of_point_sdiff_sub Finset.weighted_vsub_of_point_sdiff_sub

/-- A weighted sum over `s.subtype pred` equals one over `s.filter pred`. -/
theorem weighted_vsub_of_point_subtype_eq_filter (w : ι → k) (p : ι → P) (b : P) (pred : ι → Prop)
    [DecidablePred pred] :
    ((s.Subtype pred).weightedVsubOfPoint (fun i => p i) b fun i => w i) = (s.filter pred).weightedVsubOfPoint p b w :=
  by rw [weighted_vsub_of_point_apply, weighted_vsub_of_point_apply, ← sum_subtype_eq_sum_filter]
#align finset.weighted_vsub_of_point_subtype_eq_filter Finset.weighted_vsub_of_point_subtype_eq_filter

/-- A weighted sum over `s.filter pred` equals one over `s` if all the weights at indices in `s`
not satisfying `pred` are zero. -/
theorem weighted_vsub_of_point_filter_of_ne (w : ι → k) (p : ι → P) (b : P) {pred : ι → Prop} [DecidablePred pred]
    (h : ∀ i ∈ s, w i ≠ 0 → pred i) : (s.filter pred).weightedVsubOfPoint p b w = s.weightedVsubOfPoint p b w := by
  rw [weighted_vsub_of_point_apply, weighted_vsub_of_point_apply, sum_filter_of_ne]
  intro i hi hne
  refine' h i hi _
  intro hw
  simpa [hw] using hne
#align finset.weighted_vsub_of_point_filter_of_ne Finset.weighted_vsub_of_point_filter_of_ne

/-- A weighted sum of the results of subtracting a default base point
from the given points, as a linear map on the weights.  This is
intended to be used when the sum of the weights is 0; that condition
is specified as a hypothesis on those lemmas that require it. -/
def weightedVsub (p : ι → P) : (ι → k) →ₗ[k] V :=
  s.weightedVsubOfPoint p (Classical.choice S.Nonempty)
#align finset.weighted_vsub Finset.weightedVsub

/-- Applying `weighted_vsub` with given weights.  This is for the case
where a result involving a default base point is OK (for example, when
that base point will cancel out later); a more typical use case for
`weighted_vsub` would involve selecting a preferred base point with
`weighted_vsub_eq_weighted_vsub_of_point_of_sum_eq_zero` and then
using `weighted_vsub_of_point_apply`. -/
theorem weighted_vsub_apply (w : ι → k) (p : ι → P) :
    s.weightedVsub p w = ∑ i in s, w i • (p i -ᵥ Classical.choice S.Nonempty) := by
  simp [weighted_vsub, LinearMap.sum_apply]
#align finset.weighted_vsub_apply Finset.weighted_vsub_apply

/-- `weighted_vsub` gives the sum of the results of subtracting any
base point, when the sum of the weights is 0. -/
theorem weighted_vsub_eq_weighted_vsub_of_point_of_sum_eq_zero (w : ι → k) (p : ι → P) (h : (∑ i in s, w i) = 0)
    (b : P) : s.weightedVsub p w = s.weightedVsubOfPoint p b w :=
  s.weighted_vsub_of_point_eq_of_sum_eq_zero w p h _ _
#align
  finset.weighted_vsub_eq_weighted_vsub_of_point_of_sum_eq_zero Finset.weighted_vsub_eq_weighted_vsub_of_point_of_sum_eq_zero

/-- The value of `weighted_vsub`, where the given points are equal and the sum of the weights
is 0. -/
@[simp]
theorem weighted_vsub_apply_const (w : ι → k) (p : P) (h : (∑ i in s, w i) = 0) : s.weightedVsub (fun _ => p) w = 0 :=
  by rw [weighted_vsub, weighted_vsub_of_point_apply_const, h, zero_smul]
#align finset.weighted_vsub_apply_const Finset.weighted_vsub_apply_const

/-- The `weighted_vsub` for an empty set is 0. -/
@[simp]
theorem weighted_vsub_empty (w : ι → k) (p : ι → P) : (∅ : Finset ι).weightedVsub p w = (0 : V) := by
  simp [weighted_vsub_apply]
#align finset.weighted_vsub_empty Finset.weighted_vsub_empty

/-- The weighted sum is unaffected by changing the weights to the
corresponding indicator function and adding points to the set. -/
theorem weighted_vsub_indicator_subset (w : ι → k) (p : ι → P) {s₁ s₂ : Finset ι} (h : s₁ ⊆ s₂) :
    s₁.weightedVsub p w = s₂.weightedVsub p (Set.indicator (↑s₁) w) :=
  weighted_vsub_of_point_indicator_subset _ _ _ h
#align finset.weighted_vsub_indicator_subset Finset.weighted_vsub_indicator_subset

/-- A weighted subtraction, over the image of an embedding, equals a
weighted subtraction with the same points and weights over the
original `finset`. -/
theorem weighted_vsub_map (e : ι₂ ↪ ι) (w : ι → k) (p : ι → P) :
    (s₂.map e).weightedVsub p w = s₂.weightedVsub (p ∘ e) (w ∘ e) :=
  s₂.weighted_vsub_of_point_map _ _ _ _
#align finset.weighted_vsub_map Finset.weighted_vsub_map

/-- A weighted sum of pairwise subtractions, expressed as a subtraction of two `weighted_vsub`
expressions. -/
theorem sum_smul_vsub_eq_weighted_vsub_sub (w : ι → k) (p₁ p₂ : ι → P) :
    (∑ i in s, w i • (p₁ i -ᵥ p₂ i)) = s.weightedVsub p₁ w - s.weightedVsub p₂ w :=
  s.sum_smul_vsub_eq_weighted_vsub_of_point_sub _ _ _ _
#align finset.sum_smul_vsub_eq_weighted_vsub_sub Finset.sum_smul_vsub_eq_weighted_vsub_sub

/-- A weighted sum of pairwise subtractions, where the point on the right is constant and the
sum of the weights is 0. -/
theorem sum_smul_vsub_const_eq_weighted_vsub (w : ι → k) (p₁ : ι → P) (p₂ : P) (h : (∑ i in s, w i) = 0) :
    (∑ i in s, w i • (p₁ i -ᵥ p₂)) = s.weightedVsub p₁ w := by
  rw [sum_smul_vsub_eq_weighted_vsub_sub, s.weighted_vsub_apply_const _ _ h, sub_zero]
#align finset.sum_smul_vsub_const_eq_weighted_vsub Finset.sum_smul_vsub_const_eq_weighted_vsub

/-- A weighted sum of pairwise subtractions, where the point on the left is constant and the
sum of the weights is 0. -/
theorem sum_smul_const_vsub_eq_neg_weighted_vsub (w : ι → k) (p₂ : ι → P) (p₁ : P) (h : (∑ i in s, w i) = 0) :
    (∑ i in s, w i • (p₁ -ᵥ p₂ i)) = -s.weightedVsub p₂ w := by
  rw [sum_smul_vsub_eq_weighted_vsub_sub, s.weighted_vsub_apply_const _ _ h, zero_sub]
#align finset.sum_smul_const_vsub_eq_neg_weighted_vsub Finset.sum_smul_const_vsub_eq_neg_weighted_vsub

/-- A weighted sum may be split into such sums over two subsets. -/
theorem weighted_vsub_sdiff [DecidableEq ι] {s₂ : Finset ι} (h : s₂ ⊆ s) (w : ι → k) (p : ι → P) :
    (s \ s₂).weightedVsub p w + s₂.weightedVsub p w = s.weightedVsub p w :=
  s.weighted_vsub_of_point_sdiff h _ _ _
#align finset.weighted_vsub_sdiff Finset.weighted_vsub_sdiff

/-- A weighted sum may be split into a subtraction of such sums over two subsets. -/
theorem weighted_vsub_sdiff_sub [DecidableEq ι] {s₂ : Finset ι} (h : s₂ ⊆ s) (w : ι → k) (p : ι → P) :
    (s \ s₂).weightedVsub p w - s₂.weightedVsub p (-w) = s.weightedVsub p w :=
  s.weighted_vsub_of_point_sdiff_sub h _ _ _
#align finset.weighted_vsub_sdiff_sub Finset.weighted_vsub_sdiff_sub

/-- A weighted sum over `s.subtype pred` equals one over `s.filter pred`. -/
theorem weighted_vsub_subtype_eq_filter (w : ι → k) (p : ι → P) (pred : ι → Prop) [DecidablePred pred] :
    ((s.Subtype pred).weightedVsub (fun i => p i) fun i => w i) = (s.filter pred).weightedVsub p w :=
  s.weighted_vsub_of_point_subtype_eq_filter _ _ _ _
#align finset.weighted_vsub_subtype_eq_filter Finset.weighted_vsub_subtype_eq_filter

/-- A weighted sum over `s.filter pred` equals one over `s` if all the weights at indices in `s`
not satisfying `pred` are zero. -/
theorem weighted_vsub_filter_of_ne (w : ι → k) (p : ι → P) {pred : ι → Prop} [DecidablePred pred]
    (h : ∀ i ∈ s, w i ≠ 0 → pred i) : (s.filter pred).weightedVsub p w = s.weightedVsub p w :=
  s.weighted_vsub_of_point_filter_of_ne _ _ _ h
#align finset.weighted_vsub_filter_of_ne Finset.weighted_vsub_filter_of_ne

/-- A weighted sum of the results of subtracting a default base point
from the given points, added to that base point, as an affine map on
the weights.  This is intended to be used when the sum of the weights
is 1, in which case it is an affine combination (barycenter) of the
points with the given weights; that condition is specified as a
hypothesis on those lemmas that require it. -/
def affineCombination (p : ι → P) : (ι → k) →ᵃ[k] P where
  toFun w := s.weightedVsubOfPoint p (Classical.choice S.Nonempty) w +ᵥ Classical.choice S.Nonempty
  linear := s.weightedVsub p
  map_vadd' w₁ w₂ := by simp_rw [vadd_vadd, weighted_vsub, vadd_eq_add, LinearMap.map_add]
#align finset.affine_combination Finset.affineCombination

/-- The linear map corresponding to `affine_combination` is
`weighted_vsub`. -/
@[simp]
theorem affine_combination_linear (p : ι → P) : (s.affineCombination p : (ι → k) →ᵃ[k] P).linear = s.weightedVsub p :=
  rfl
#align finset.affine_combination_linear Finset.affine_combination_linear

/-- Applying `affine_combination` with given weights.  This is for the
case where a result involving a default base point is OK (for example,
when that base point will cancel out later); a more typical use case
for `affine_combination` would involve selecting a preferred base
point with
`affine_combination_eq_weighted_vsub_of_point_vadd_of_sum_eq_one` and
then using `weighted_vsub_of_point_apply`. -/
theorem affine_combination_apply (w : ι → k) (p : ι → P) :
    s.affineCombination p w = s.weightedVsubOfPoint p (Classical.choice S.Nonempty) w +ᵥ Classical.choice S.Nonempty :=
  rfl
#align finset.affine_combination_apply Finset.affine_combination_apply

/-- The value of `affine_combination`, where the given points are equal. -/
@[simp]
theorem affine_combination_apply_const (w : ι → k) (p : P) (h : (∑ i in s, w i) = 1) :
    s.affineCombination (fun _ => p) w = p := by
  rw [affine_combination_apply, s.weighted_vsub_of_point_apply_const, h, one_smul, vsub_vadd]
#align finset.affine_combination_apply_const Finset.affine_combination_apply_const

/-- `affine_combination` gives the sum with any base point, when the
sum of the weights is 1. -/
theorem affine_combination_eq_weighted_vsub_of_point_vadd_of_sum_eq_one (w : ι → k) (p : ι → P)
    (h : (∑ i in s, w i) = 1) (b : P) : s.affineCombination p w = s.weightedVsubOfPoint p b w +ᵥ b :=
  s.weighted_vsub_of_point_vadd_eq_of_sum_eq_one w p h _ _
#align
  finset.affine_combination_eq_weighted_vsub_of_point_vadd_of_sum_eq_one Finset.affine_combination_eq_weighted_vsub_of_point_vadd_of_sum_eq_one

/-- Adding a `weighted_vsub` to an `affine_combination`. -/
theorem weighted_vsub_vadd_affine_combination (w₁ w₂ : ι → k) (p : ι → P) :
    s.weightedVsub p w₁ +ᵥ s.affineCombination p w₂ = s.affineCombination p (w₁ + w₂) := by
  rw [← vadd_eq_add, AffineMap.map_vadd, affine_combination_linear]
#align finset.weighted_vsub_vadd_affine_combination Finset.weighted_vsub_vadd_affine_combination

/-- Subtracting two `affine_combination`s. -/
theorem affine_combination_vsub (w₁ w₂ : ι → k) (p : ι → P) :
    s.affineCombination p w₁ -ᵥ s.affineCombination p w₂ = s.weightedVsub p (w₁ - w₂) := by
  rw [← AffineMap.linear_map_vsub, affine_combination_linear, vsub_eq_sub]
#align finset.affine_combination_vsub Finset.affine_combination_vsub

theorem attach_affine_combination_of_injective [DecidableEq P] (s : Finset P) (w : P → k) (f : s → P)
    (hf : Function.Injective f) : s.attach.affineCombination f (w ∘ f) = (image f univ).affineCombination id w := by
  simp only [affine_combination, weighted_vsub_of_point_apply, id.def, vadd_right_cancel_iff, Function.comp_apply,
    AffineMap.coe_mk]
  let g₁ : s → V := fun i => w (f i) • (f i -ᵥ Classical.choice S.nonempty)
  let g₂ : P → V := fun i => w i • (i -ᵥ Classical.choice S.nonempty)
  change univ.sum g₁ = (image f univ).Sum g₂
  have hgf : g₁ = g₂ ∘ f := by
    ext
    simp
  rw [hgf, sum_image]
  exact fun _ _ _ _ hxy => hf hxy
#align finset.attach_affine_combination_of_injective Finset.attach_affine_combination_of_injective

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `attach_affine_combination_coe [])
      (Command.declSig
       [(Term.explicitBinder "(" [`s] [":" (Term.app `Finset [`P])] [] ")")
        (Term.explicitBinder "(" [`w] [":" (Term.arrow `P "→" `k)] [] ")")]
       (Term.typeSpec
        ":"
        («term_=_»
         (Term.app
          (Term.proj (Term.proj `s "." `attach) "." `affineCombination)
          [(Term.paren "(" [`coe [(Term.typeAscription ":" [(Term.arrow `s "→" `P)])]] ")") («term_∘_» `w "∘" `coe)])
         "="
         (Term.app (Term.proj `s "." `affineCombination) [`id `w]))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.«tactic_<;>_»
            (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
            "<;>"
            (Tactic.rwSeq
             "rw"
             []
             (Tactic.rwRuleSeq
              "["
              [(Tactic.rwRule
                []
                (Term.app
                 `attach_affine_combination_of_injective
                 [`s
                  `w
                  (Term.paren "(" [`coe [(Term.typeAscription ":" [(Term.arrow `s "→" `P)])]] ")")
                  `Subtype.coe_injective]))
               ","
               (Tactic.rwRule [] `univ_eq_attach)
               ","
               (Tactic.rwRule [] `attach_image_coe)]
              "]")
             []))])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.«tactic_<;>_»
           (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
           "<;>"
           (Tactic.rwSeq
            "rw"
            []
            (Tactic.rwRuleSeq
             "["
             [(Tactic.rwRule
               []
               (Term.app
                `attach_affine_combination_of_injective
                [`s
                 `w
                 (Term.paren "(" [`coe [(Term.typeAscription ":" [(Term.arrow `s "→" `P)])]] ")")
                 `Subtype.coe_injective]))
              ","
              (Tactic.rwRule [] `univ_eq_attach)
              ","
              (Tactic.rwRule [] `attach_image_coe)]
             "]")
            []))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.«tactic_<;>_»
       (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
       "<;>"
       (Tactic.rwSeq
        "rw"
        []
        (Tactic.rwRuleSeq
         "["
         [(Tactic.rwRule
           []
           (Term.app
            `attach_affine_combination_of_injective
            [`s
             `w
             (Term.paren "(" [`coe [(Term.typeAscription ":" [(Term.arrow `s "→" `P)])]] ")")
             `Subtype.coe_injective]))
          ","
          (Tactic.rwRule [] `univ_eq_attach)
          ","
          (Tactic.rwRule [] `attach_image_coe)]
         "]")
        []))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule
          []
          (Term.app
           `attach_affine_combination_of_injective
           [`s
            `w
            (Term.paren "(" [`coe [(Term.typeAscription ":" [(Term.arrow `s "→" `P)])]] ")")
            `Subtype.coe_injective]))
         ","
         (Tactic.rwRule [] `univ_eq_attach)
         ","
         (Tactic.rwRule [] `attach_image_coe)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `attach_image_coe
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `univ_eq_attach
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       `attach_affine_combination_of_injective
       [`s `w (Term.paren "(" [`coe [(Term.typeAscription ":" [(Term.arrow `s "→" `P)])]] ")") `Subtype.coe_injective])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `Subtype.coe_injective
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.paren', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.paren', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.paren "(" [`coe [(Term.typeAscription ":" [(Term.arrow `s "→" `P)])]] ")")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.typeAscription', expected 'Lean.Parser.Term.tupleTail'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.arrow `s "→" `P)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `P
[PrettyPrinter.parenthesize] ...precedences are 25 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 25, term))
      `s
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 25, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 25, (some 25, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      `coe
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1023, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, term))
      `w
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (some 1023, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `s
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `attach_affine_combination_of_injective
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1, tactic))
      (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.skip', expected 'Lean.Parser.Tactic.tacticSeq'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.declValEqns'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.whereStructInst'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  attach_affine_combination_coe
  ( s : Finset P ) ( w : P → k ) : s . attach . affineCombination ( coe : s → P ) w ∘ coe = s . affineCombination id w
  :=
    by
      skip
        <;>
        rw
          [
            attach_affine_combination_of_injective s w ( coe : s → P ) Subtype.coe_injective
              ,
              univ_eq_attach
              ,
              attach_image_coe
            ]
#align finset.attach_affine_combination_coe Finset.attach_affine_combination_coe

omit S

/-- Viewing a module as an affine space modelled on itself, a `weighted_vsub` is just a linear
combination. -/
@[simp]
theorem weighted_vsub_eq_linear_combination {ι} (s : Finset ι) {w : ι → k} {p : ι → V} (hw : s.Sum w = 0) :
    s.weightedVsub p w = ∑ i in s, w i • p i := by
  simp [s.weighted_vsub_apply, vsub_eq_sub, smul_sub, ← Finset.sum_smul, hw]
#align finset.weighted_vsub_eq_linear_combination Finset.weighted_vsub_eq_linear_combination

/-- Viewing a module as an affine space modelled on itself, affine combinations are just linear
combinations. -/
@[simp]
theorem affine_combination_eq_linear_combination (s : Finset ι) (p : ι → V) (w : ι → k) (hw : (∑ i in s, w i) = 1) :
    s.affineCombination p w = ∑ i in s, w i • p i := by
  simp [s.affine_combination_eq_weighted_vsub_of_point_vadd_of_sum_eq_one w p hw 0]
#align finset.affine_combination_eq_linear_combination Finset.affine_combination_eq_linear_combination

include S

/-- An `affine_combination` equals a point if that point is in the set
and has weight 1 and the other points in the set have weight 0. -/
@[simp]
theorem affine_combination_of_eq_one_of_eq_zero (w : ι → k) (p : ι → P) {i : ι} (his : i ∈ s) (hwi : w i = 1)
    (hw0 : ∀ i2 ∈ s, i2 ≠ i → w i2 = 0) : s.affineCombination p w = p i := by
  have h1 : (∑ i in s, w i) = 1 := hwi ▸ sum_eq_single i hw0 fun h => False.elim (h his)
  rw [s.affine_combination_eq_weighted_vsub_of_point_vadd_of_sum_eq_one w p h1 (p i), weighted_vsub_of_point_apply]
  convert zero_vadd V (p i)
  convert sum_eq_zero _
  intro i2 hi2
  by_cases h:i2 = i
  · simp [h]
    
  · simp [hw0 i2 hi2 h]
    
#align finset.affine_combination_of_eq_one_of_eq_zero Finset.affine_combination_of_eq_one_of_eq_zero

/-- An affine combination is unaffected by changing the weights to the
corresponding indicator function and adding points to the set. -/
theorem affine_combination_indicator_subset (w : ι → k) (p : ι → P) {s₁ s₂ : Finset ι} (h : s₁ ⊆ s₂) :
    s₁.affineCombination p w = s₂.affineCombination p (Set.indicator (↑s₁) w) := by
  rw [affine_combination_apply, affine_combination_apply, weighted_vsub_of_point_indicator_subset _ _ _ h]
#align finset.affine_combination_indicator_subset Finset.affine_combination_indicator_subset

/-- An affine combination, over the image of an embedding, equals an
affine combination with the same points and weights over the original
`finset`. -/
theorem affine_combination_map (e : ι₂ ↪ ι) (w : ι → k) (p : ι → P) :
    (s₂.map e).affineCombination p w = s₂.affineCombination (p ∘ e) (w ∘ e) := by
  simp_rw [affine_combination_apply, weighted_vsub_of_point_map]
#align finset.affine_combination_map Finset.affine_combination_map

/-- A weighted sum of pairwise subtractions, expressed as a subtraction of two `affine_combination`
expressions. -/
theorem sum_smul_vsub_eq_affine_combination_vsub (w : ι → k) (p₁ p₂ : ι → P) :
    (∑ i in s, w i • (p₁ i -ᵥ p₂ i)) = s.affineCombination p₁ w -ᵥ s.affineCombination p₂ w := by
  simp_rw [affine_combination_apply, vadd_vsub_vadd_cancel_right]
  exact s.sum_smul_vsub_eq_weighted_vsub_of_point_sub _ _ _ _
#align finset.sum_smul_vsub_eq_affine_combination_vsub Finset.sum_smul_vsub_eq_affine_combination_vsub

/-- A weighted sum of pairwise subtractions, where the point on the right is constant and the
sum of the weights is 1. -/
theorem sum_smul_vsub_const_eq_affine_combination_vsub (w : ι → k) (p₁ : ι → P) (p₂ : P) (h : (∑ i in s, w i) = 1) :
    (∑ i in s, w i • (p₁ i -ᵥ p₂)) = s.affineCombination p₁ w -ᵥ p₂ := by
  rw [sum_smul_vsub_eq_affine_combination_vsub, affine_combination_apply_const _ _ _ h]
#align finset.sum_smul_vsub_const_eq_affine_combination_vsub Finset.sum_smul_vsub_const_eq_affine_combination_vsub

/-- A weighted sum of pairwise subtractions, where the point on the left is constant and the
sum of the weights is 1. -/
theorem sum_smul_const_vsub_eq_vsub_affine_combination (w : ι → k) (p₂ : ι → P) (p₁ : P) (h : (∑ i in s, w i) = 1) :
    (∑ i in s, w i • (p₁ -ᵥ p₂ i)) = p₁ -ᵥ s.affineCombination p₂ w := by
  rw [sum_smul_vsub_eq_affine_combination_vsub, affine_combination_apply_const _ _ _ h]
#align finset.sum_smul_const_vsub_eq_vsub_affine_combination Finset.sum_smul_const_vsub_eq_vsub_affine_combination

/-- A weighted sum may be split into a subtraction of affine combinations over two subsets. -/
theorem affine_combination_sdiff_sub [DecidableEq ι] {s₂ : Finset ι} (h : s₂ ⊆ s) (w : ι → k) (p : ι → P) :
    (s \ s₂).affineCombination p w -ᵥ s₂.affineCombination p (-w) = s.weightedVsub p w := by
  simp_rw [affine_combination_apply, vadd_vsub_vadd_cancel_right]
  exact s.weighted_vsub_sdiff_sub h _ _
#align finset.affine_combination_sdiff_sub Finset.affine_combination_sdiff_sub

/-- If a weighted sum is zero and one of the weights is `-1`, the corresponding point is
the affine combination of the other points with the given weights. -/
theorem affine_combination_eq_of_weighted_vsub_eq_zero_of_eq_neg_one {w : ι → k} {p : ι → P}
    (hw : s.weightedVsub p w = (0 : V)) {i : ι} [DecidablePred (· ≠ i)] (his : i ∈ s) (hwi : w i = -1) :
    (s.filter (· ≠ i)).affineCombination p w = p i := by
  classical rw [← @vsub_eq_zero_iff_eq V, ← hw, ← s.affine_combination_sdiff_sub (singleton_subset_iff.2 his),
      sdiff_singleton_eq_erase, ← filter_ne']
    refine' (affine_combination_of_eq_one_of_eq_zero _ _ _ (mem_singleton_self _) _ _).symm
    · simp
      
#align
  finset.affine_combination_eq_of_weighted_vsub_eq_zero_of_eq_neg_one Finset.affine_combination_eq_of_weighted_vsub_eq_zero_of_eq_neg_one

/-- An affine combination over `s.subtype pred` equals one over `s.filter pred`. -/
theorem affine_combination_subtype_eq_filter (w : ι → k) (p : ι → P) (pred : ι → Prop) [DecidablePred pred] :
    ((s.Subtype pred).affineCombination (fun i => p i) fun i => w i) = (s.filter pred).affineCombination p w := by
  rw [affine_combination_apply, affine_combination_apply, weighted_vsub_of_point_subtype_eq_filter]
#align finset.affine_combination_subtype_eq_filter Finset.affine_combination_subtype_eq_filter

/-- An affine combination over `s.filter pred` equals one over `s` if all the weights at indices
in `s` not satisfying `pred` are zero. -/
theorem affine_combination_filter_of_ne (w : ι → k) (p : ι → P) {pred : ι → Prop} [DecidablePred pred]
    (h : ∀ i ∈ s, w i ≠ 0 → pred i) : (s.filter pred).affineCombination p w = s.affineCombination p w := by
  rw [affine_combination_apply, affine_combination_apply, s.weighted_vsub_of_point_filter_of_ne _ _ _ h]
#align finset.affine_combination_filter_of_ne Finset.affine_combination_filter_of_ne

variable {V}

/-- Suppose an indexed family of points is given, along with a subset
of the index type.  A vector can be expressed as
`weighted_vsub_of_point` using a `finset` lying within that subset and
with a given sum of weights if and only if it can be expressed as
`weighted_vsub_of_point` with that sum of weights for the
corresponding indexed family whose index type is the subtype
corresponding to that subset. -/
theorem eq_weighted_vsub_of_point_subset_iff_eq_weighted_vsub_of_point_subtype {v : V} {x : k} {s : Set ι} {p : ι → P}
    {b : P} :
    (∃ (fs : Finset ι)(hfs : ↑fs ⊆ s)(w : ι → k)(hw : (∑ i in fs, w i) = x), v = fs.weightedVsubOfPoint p b w) ↔
      ∃ (fs : Finset s)(w : s → k)(hw : (∑ i in fs, w i) = x), v = fs.weightedVsubOfPoint (fun i : s => p i) b w :=
  by
  classical simp_rw [weighted_vsub_of_point_apply]
    · rintro ⟨fs, hfs, w, rfl, rfl⟩
      use fs.subtype s, fun i => w i, sum_subtype_of_mem _ hfs, (sum_subtype_of_mem _ hfs).symm
      
#align
  finset.eq_weighted_vsub_of_point_subset_iff_eq_weighted_vsub_of_point_subtype Finset.eq_weighted_vsub_of_point_subset_iff_eq_weighted_vsub_of_point_subtype

variable (k)

/-- Suppose an indexed family of points is given, along with a subset
of the index type.  A vector can be expressed as `weighted_vsub` using
a `finset` lying within that subset and with sum of weights 0 if and
only if it can be expressed as `weighted_vsub` with sum of weights 0
for the corresponding indexed family whose index type is the subtype
corresponding to that subset. -/
theorem eq_weighted_vsub_subset_iff_eq_weighted_vsub_subtype {v : V} {s : Set ι} {p : ι → P} :
    (∃ (fs : Finset ι)(hfs : ↑fs ⊆ s)(w : ι → k)(hw : (∑ i in fs, w i) = 0), v = fs.weightedVsub p w) ↔
      ∃ (fs : Finset s)(w : s → k)(hw : (∑ i in fs, w i) = 0), v = fs.weightedVsub (fun i : s => p i) w :=
  eq_weighted_vsub_of_point_subset_iff_eq_weighted_vsub_of_point_subtype
#align
  finset.eq_weighted_vsub_subset_iff_eq_weighted_vsub_subtype Finset.eq_weighted_vsub_subset_iff_eq_weighted_vsub_subtype

variable (V)

/-- Suppose an indexed family of points is given, along with a subset
of the index type.  A point can be expressed as an
`affine_combination` using a `finset` lying within that subset and
with sum of weights 1 if and only if it can be expressed an
`affine_combination` with sum of weights 1 for the corresponding
indexed family whose index type is the subtype corresponding to that
subset. -/
theorem eq_affine_combination_subset_iff_eq_affine_combination_subtype {p0 : P} {s : Set ι} {p : ι → P} :
    (∃ (fs : Finset ι)(hfs : ↑fs ⊆ s)(w : ι → k)(hw : (∑ i in fs, w i) = 1), p0 = fs.affineCombination p w) ↔
      ∃ (fs : Finset s)(w : s → k)(hw : (∑ i in fs, w i) = 1), p0 = fs.affineCombination (fun i : s => p i) w :=
  by
  simp_rw [affine_combination_apply, eq_vadd_iff_vsub_eq]
  exact eq_weighted_vsub_of_point_subset_iff_eq_weighted_vsub_of_point_subtype
#align
  finset.eq_affine_combination_subset_iff_eq_affine_combination_subtype Finset.eq_affine_combination_subset_iff_eq_affine_combination_subtype

variable {k V}

/-- Affine maps commute with affine combinations. -/
theorem map_affine_combination {V₂ P₂ : Type _} [AddCommGroup V₂] [Module k V₂] [affine_space V₂ P₂] (p : ι → P)
    (w : ι → k) (hw : s.Sum w = 1) (f : P →ᵃ[k] P₂) : f (s.affineCombination p w) = s.affineCombination (f ∘ p) w := by
  have b := Classical.choice (inferInstance : affine_space V P).Nonempty
  have b₂ := Classical.choice (inferInstance : affine_space V₂ P₂).Nonempty
  rw [s.affine_combination_eq_weighted_vsub_of_point_vadd_of_sum_eq_one w p hw b,
    s.affine_combination_eq_weighted_vsub_of_point_vadd_of_sum_eq_one w (f ∘ p) hw b₂, ←
    s.weighted_vsub_of_point_vadd_eq_of_sum_eq_one w (f ∘ p) hw (f b) b₂]
  simp only [weighted_vsub_of_point_apply, RingHom.id_apply, AffineMap.map_vadd, LinearMap.map_smulₛₗ,
    AffineMap.linear_map_vsub, LinearMap.map_sum]
#align finset.map_affine_combination Finset.map_affine_combination

end Finset

namespace Finset

variable (k : Type _) {V : Type _} {P : Type _} [DivisionRing k] [AddCommGroup V] [Module k V]

variable [affine_space V P] {ι : Type _} (s : Finset ι) {ι₂ : Type _} (s₂ : Finset ι₂)

/-- The weights for the centroid of some points. -/
def centroidWeights : ι → k :=
  Function.const ι (card s : k)⁻¹
#align finset.centroid_weights Finset.centroidWeights

/-- `centroid_weights` at any point. -/
@[simp]
theorem centroid_weights_apply (i : ι) : s.centroidWeights k i = (card s : k)⁻¹ :=
  rfl
#align finset.centroid_weights_apply Finset.centroid_weights_apply

/-- `centroid_weights` equals a constant function. -/
theorem centroid_weights_eq_const : s.centroidWeights k = Function.const ι (card s : k)⁻¹ :=
  rfl
#align finset.centroid_weights_eq_const Finset.centroid_weights_eq_const

variable {k}

/-- The weights in the centroid sum to 1, if the number of points,
converted to `k`, is not zero. -/
theorem sum_centroid_weights_eq_one_of_cast_card_ne_zero (h : (card s : k) ≠ 0) :
    (∑ i in s, s.centroidWeights k i) = 1 := by simp [h]
#align finset.sum_centroid_weights_eq_one_of_cast_card_ne_zero Finset.sum_centroid_weights_eq_one_of_cast_card_ne_zero

variable (k)

/-- In the characteristic zero case, the weights in the centroid sum
to 1 if the number of points is not zero. -/
theorem sum_centroid_weights_eq_one_of_card_ne_zero [CharZero k] (h : card s ≠ 0) :
    (∑ i in s, s.centroidWeights k i) = 1 := by simp [h]
#align finset.sum_centroid_weights_eq_one_of_card_ne_zero Finset.sum_centroid_weights_eq_one_of_card_ne_zero

/-- In the characteristic zero case, the weights in the centroid sum
to 1 if the set is nonempty. -/
theorem sum_centroid_weights_eq_one_of_nonempty [CharZero k] (h : s.Nonempty) : (∑ i in s, s.centroidWeights k i) = 1 :=
  s.sum_centroid_weights_eq_one_of_card_ne_zero k (ne_of_gt (card_pos.2 h))
#align finset.sum_centroid_weights_eq_one_of_nonempty Finset.sum_centroid_weights_eq_one_of_nonempty

/-- In the characteristic zero case, the weights in the centroid sum
to 1 if the number of points is `n + 1`. -/
theorem sum_centroid_weights_eq_one_of_card_eq_add_one [CharZero k] {n : ℕ} (h : card s = n + 1) :
    (∑ i in s, s.centroidWeights k i) = 1 :=
  s.sum_centroid_weights_eq_one_of_card_ne_zero k (h.symm ▸ Nat.succ_ne_zero n)
#align finset.sum_centroid_weights_eq_one_of_card_eq_add_one Finset.sum_centroid_weights_eq_one_of_card_eq_add_one

include V

/-- The centroid of some points.  Although defined for any `s`, this
is intended to be used in the case where the number of points,
converted to `k`, is not zero. -/
def centroid (p : ι → P) : P :=
  s.affineCombination p (s.centroidWeights k)
#align finset.centroid Finset.centroid

/-- The definition of the centroid. -/
theorem centroid_def (p : ι → P) : s.centroid k p = s.affineCombination p (s.centroidWeights k) :=
  rfl
#align finset.centroid_def Finset.centroid_def

theorem centroid_univ (s : Finset P) : univ.centroid k (coe : s → P) = s.centroid k id := by
  rw [centroid, centroid, ← s.attach_affine_combination_coe]
  congr
  ext
  simp
#align finset.centroid_univ Finset.centroid_univ

/-- The centroid of a single point. -/
@[simp]
theorem centroid_singleton (p : ι → P) (i : ι) : ({i} : Finset ι).centroid k p = p i := by
  simp [centroid_def, affine_combination_apply]
#align finset.centroid_singleton Finset.centroid_singleton

/-- The centroid of two points, expressed directly as adding a vector
to a point. -/
theorem centroid_pair [DecidableEq ι] [Invertible (2 : k)] (p : ι → P) (i₁ i₂ : ι) :
    ({i₁, i₂} : Finset ι).centroid k p = (2⁻¹ : k) • (p i₂ -ᵥ p i₁) +ᵥ p i₁ := by
  by_cases h:i₁ = i₂
  · simp [h]
    
  · have hc : (card ({i₁, i₂} : Finset ι) : k) ≠ 0 := by
      rw [card_insert_of_not_mem (not_mem_singleton.2 h), card_singleton]
      norm_num
      exact nonzero_of_invertible _
    rw [centroid_def,
      affine_combination_eq_weighted_vsub_of_point_vadd_of_sum_eq_one _ _ _
        (sum_centroid_weights_eq_one_of_cast_card_ne_zero _ hc) (p i₁)]
    simp [h]
    
#align finset.centroid_pair Finset.centroid_pair

/-- The centroid of two points indexed by `fin 2`, expressed directly
as adding a vector to the first point. -/
theorem centroid_pair_fin [Invertible (2 : k)] (p : Fin 2 → P) : univ.centroid k p = (2⁻¹ : k) • (p 1 -ᵥ p 0) +ᵥ p 0 :=
  by
  rw [univ_fin2]
  convert centroid_pair k p 0 1
#align finset.centroid_pair_fin Finset.centroid_pair_fin

/-- A centroid, over the image of an embedding, equals a centroid with
the same points and weights over the original `finset`. -/
theorem centroid_map (e : ι₂ ↪ ι) (p : ι → P) : (s₂.map e).centroid k p = s₂.centroid k (p ∘ e) := by
  simp [centroid_def, affine_combination_map, centroid_weights]
#align finset.centroid_map Finset.centroid_map

omit V

/-- `centroid_weights` gives the weights for the centroid as a
constant function, which is suitable when summing over the points
whose centroid is being taken.  This function gives the weights in a
form suitable for summing over a larger set of points, as an indicator
function that is zero outside the set whose centroid is being taken.
In the case of a `fintype`, the sum may be over `univ`. -/
def centroidWeightsIndicator : ι → k :=
  Set.indicator (↑s) (s.centroidWeights k)
#align finset.centroid_weights_indicator Finset.centroidWeightsIndicator

/-- The definition of `centroid_weights_indicator`. -/
theorem centroid_weights_indicator_def : s.centroidWeightsIndicator k = Set.indicator (↑s) (s.centroidWeights k) :=
  rfl
#align finset.centroid_weights_indicator_def Finset.centroid_weights_indicator_def

/-- The sum of the weights for the centroid indexed by a `fintype`. -/
theorem sum_centroid_weights_indicator [Fintype ι] :
    (∑ i, s.centroidWeightsIndicator k i) = ∑ i in s, s.centroidWeights k i :=
  (Set.sum_indicator_subset _ (subset_univ _)).symm
#align finset.sum_centroid_weights_indicator Finset.sum_centroid_weights_indicator

/-- In the characteristic zero case, the weights in the centroid
indexed by a `fintype` sum to 1 if the number of points is not
zero. -/
theorem sum_centroid_weights_indicator_eq_one_of_card_ne_zero [CharZero k] [Fintype ι] (h : card s ≠ 0) :
    (∑ i, s.centroidWeightsIndicator k i) = 1 := by
  rw [sum_centroid_weights_indicator]
  exact s.sum_centroid_weights_eq_one_of_card_ne_zero k h
#align
  finset.sum_centroid_weights_indicator_eq_one_of_card_ne_zero Finset.sum_centroid_weights_indicator_eq_one_of_card_ne_zero

/-- In the characteristic zero case, the weights in the centroid
indexed by a `fintype` sum to 1 if the set is nonempty. -/
theorem sum_centroid_weights_indicator_eq_one_of_nonempty [CharZero k] [Fintype ι] (h : s.Nonempty) :
    (∑ i, s.centroidWeightsIndicator k i) = 1 := by
  rw [sum_centroid_weights_indicator]
  exact s.sum_centroid_weights_eq_one_of_nonempty k h
#align finset.sum_centroid_weights_indicator_eq_one_of_nonempty Finset.sum_centroid_weights_indicator_eq_one_of_nonempty

/-- In the characteristic zero case, the weights in the centroid
indexed by a `fintype` sum to 1 if the number of points is `n + 1`. -/
theorem sum_centroid_weights_indicator_eq_one_of_card_eq_add_one [CharZero k] [Fintype ι] {n : ℕ} (h : card s = n + 1) :
    (∑ i, s.centroidWeightsIndicator k i) = 1 := by
  rw [sum_centroid_weights_indicator]
  exact s.sum_centroid_weights_eq_one_of_card_eq_add_one k h
#align
  finset.sum_centroid_weights_indicator_eq_one_of_card_eq_add_one Finset.sum_centroid_weights_indicator_eq_one_of_card_eq_add_one

include V

/-- The centroid as an affine combination over a `fintype`. -/
theorem centroid_eq_affine_combination_fintype [Fintype ι] (p : ι → P) :
    s.centroid k p = univ.affineCombination p (s.centroidWeightsIndicator k) :=
  affine_combination_indicator_subset _ _ (subset_univ _)
#align finset.centroid_eq_affine_combination_fintype Finset.centroid_eq_affine_combination_fintype

/- ./././Mathport/Syntax/Translate/Basic.lean:610:2: warning: expanding binder collection (i j «expr ∈ » s) -/
/-- An indexed family of points that is injective on the given
`finset` has the same centroid as the image of that `finset`.  This is
stated in terms of a set equal to the image to provide control of
definitional equality for the index type used for the centroid of the
image. -/
theorem centroid_eq_centroid_image_of_inj_on {p : ι → P} (hi : ∀ (i j) (_ : i ∈ s) (_ : j ∈ s), p i = p j → i = j)
    {ps : Set P} [Fintype ps] (hps : ps = p '' ↑s) : s.centroid k p = (univ : Finset ps).centroid k fun x => x := by
  let f : p '' ↑s → ι := fun x => x.property.some
  have hf : ∀ x, f x ∈ s ∧ p (f x) = x := fun x => x.property.some_spec
  let f' : ps → ι := fun x => f ⟨x, hps ▸ x.property⟩
  have hf' : ∀ x, f' x ∈ s ∧ p (f' x) = x := fun x => hf ⟨x, hps ▸ x.property⟩
  have hf'i : Function.Injective f' := by
    intro x y h
    rw [Subtype.ext_iff, ← (hf' x).2, ← (hf' y).2, h]
  let f'e : ps ↪ ι := ⟨f', hf'i⟩
  have hu : finset.univ.map f'e = s := by
    ext x
    rw [mem_map]
    constructor
    · rintro ⟨i, _, rfl⟩
      exact (hf' i).1
      
    · intro hx
      use ⟨p x, hps.symm ▸ Set.mem_image_of_mem _ hx⟩, mem_univ _
      refine' hi _ (hf' _).1 _ hx _
      rw [(hf' _).2]
      rfl
      
  rw [← hu, centroid_map]
  congr with x
  change p (f' x) = ↑x
  rw [(hf' x).2]
#align finset.centroid_eq_centroid_image_of_inj_on Finset.centroid_eq_centroid_image_of_inj_on

/- ./././Mathport/Syntax/Translate/Basic.lean:610:2: warning: expanding binder collection (i j «expr ∈ » s) -/
/- ./././Mathport/Syntax/Translate/Basic.lean:610:2: warning: expanding binder collection (i j «expr ∈ » s₂) -/
/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers
      [(Command.docComment
        "/--"
        "Two indexed families of points that are injective on the given\n`finset`s and with the same points in the image of those `finset`s\nhave the same centroid. -/")]
      []
      []
      []
      []
      [])
     (Command.theorem
      "theorem"
      (Command.declId `centroid_eq_of_inj_on_of_image_eq [])
      (Command.declSig
       [(Term.implicitBinder "{" [`p] [":" (Term.arrow `ι "→" `P)] "}")
        (Term.explicitBinder
         "("
         [`hi]
         [":"
          (Term.forall
           "∀"
           [(Term.explicitBinder "(" [`i `j] [] [] ")")
            (Term.explicitBinder "(" [(Term.hole "_")] [":" («term_∈_» `i "∈" `s)] [] ")")
            (Term.explicitBinder "(" [(Term.hole "_")] [":" («term_∈_» `j "∈" `s)] [] ")")]
           []
           ","
           (Term.arrow («term_=_» (Term.app `p [`i]) "=" (Term.app `p [`j])) "→" («term_=_» `i "=" `j)))]
         []
         ")")
        (Term.implicitBinder "{" [`p₂] [":" (Term.arrow `ι₂ "→" `P)] "}")
        (Term.explicitBinder
         "("
         [`hi₂]
         [":"
          (Term.forall
           "∀"
           [(Term.explicitBinder "(" [`i `j] [] [] ")")
            (Term.explicitBinder "(" [(Term.hole "_")] [":" («term_∈_» `i "∈" `s₂)] [] ")")
            (Term.explicitBinder "(" [(Term.hole "_")] [":" («term_∈_» `j "∈" `s₂)] [] ")")]
           []
           ","
           (Term.arrow («term_=_» (Term.app `p₂ [`i]) "=" (Term.app `p₂ [`j])) "→" («term_=_» `i "=" `j)))]
         []
         ")")
        (Term.explicitBinder
         "("
         [`he]
         [":"
          («term_=_»
           (Set.Data.Set.Basic.term_''_ `p " '' " (coeNotation "↑" `s))
           "="
           (Set.Data.Set.Basic.term_''_ `p₂ " '' " (coeNotation "↑" `s₂)))]
         []
         ")")]
       (Term.typeSpec
        ":"
        («term_=_»
         (Term.app (Term.proj `s "." `centroid) [`k `p])
         "="
         (Term.app (Term.proj `s₂ "." `centroid) [`k `p₂]))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.«tactic_<;>_»
            (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
            "<;>"
            (Tactic.rwSeq
             "rw"
             []
             (Tactic.rwRuleSeq
              "["
              [(Tactic.rwRule [] (Term.app `s.centroid_eq_centroid_image_of_inj_on [`k `hi `rfl]))
               ","
               (Tactic.rwRule [] (Term.app `s₂.centroid_eq_centroid_image_of_inj_on [`k `hi₂ `he]))]
              "]")
             []))])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.«tactic_<;>_»
           (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
           "<;>"
           (Tactic.rwSeq
            "rw"
            []
            (Tactic.rwRuleSeq
             "["
             [(Tactic.rwRule [] (Term.app `s.centroid_eq_centroid_image_of_inj_on [`k `hi `rfl]))
              ","
              (Tactic.rwRule [] (Term.app `s₂.centroid_eq_centroid_image_of_inj_on [`k `hi₂ `he]))]
             "]")
            []))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.«tactic_<;>_»
       (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
       "<;>"
       (Tactic.rwSeq
        "rw"
        []
        (Tactic.rwRuleSeq
         "["
         [(Tactic.rwRule [] (Term.app `s.centroid_eq_centroid_image_of_inj_on [`k `hi `rfl]))
          ","
          (Tactic.rwRule [] (Term.app `s₂.centroid_eq_centroid_image_of_inj_on [`k `hi₂ `he]))]
         "]")
        []))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [] (Term.app `s.centroid_eq_centroid_image_of_inj_on [`k `hi `rfl]))
         ","
         (Tactic.rwRule [] (Term.app `s₂.centroid_eq_centroid_image_of_inj_on [`k `hi₂ `he]))]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `s₂.centroid_eq_centroid_image_of_inj_on [`k `hi₂ `he])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `he
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `hi₂
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `k
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `s₂.centroid_eq_centroid_image_of_inj_on
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `s.centroid_eq_centroid_image_of_inj_on [`k `hi `rfl])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `rfl
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `hi
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `k
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `s.centroid_eq_centroid_image_of_inj_on
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none, [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1, tactic))
      (Mathlib.Tactic.tacticClassical_ (Tactic.skip "skip"))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.skip', expected 'Lean.Parser.Tactic.tacticSeq'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.declValEqns'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.whereStructInst'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
/--
    Two indexed families of points that are injective on the given
    `finset`s and with the same points in the image of those `finset`s
    have the same centroid. -/
  theorem
    centroid_eq_of_inj_on_of_image_eq
    { p : ι → P }
        ( hi : ∀ ( i j ) ( _ : i ∈ s ) ( _ : j ∈ s ) , p i = p j → i = j )
        { p₂ : ι₂ → P }
        ( hi₂ : ∀ ( i j ) ( _ : i ∈ s₂ ) ( _ : j ∈ s₂ ) , p₂ i = p₂ j → i = j )
        ( he : p '' ↑ s = p₂ '' ↑ s₂ )
      : s . centroid k p = s₂ . centroid k p₂
    :=
      by
        skip
          <;>
          rw [ s.centroid_eq_centroid_image_of_inj_on k hi rfl , s₂.centroid_eq_centroid_image_of_inj_on k hi₂ he ]
#align finset.centroid_eq_of_inj_on_of_image_eq Finset.centroid_eq_of_inj_on_of_image_eq

end Finset

section AffineSpace'

variable {k : Type _} {V : Type _} {P : Type _} [Ring k] [AddCommGroup V] [Module k V] [affine_space V P]

variable {ι : Type _}

include V

/-- A `weighted_vsub` with sum of weights 0 is in the `vector_span` of
an indexed family. -/
theorem weighted_vsub_mem_vector_span {s : Finset ι} {w : ι → k} (h : (∑ i in s, w i) = 0) (p : ι → P) :
    s.weightedVsub p w ∈ vectorSpan k (Set.range p) := by
  classical rcases isEmpty_or_nonempty ι with (hι | ⟨⟨i0⟩⟩)
    · rw [vector_span_range_eq_span_range_vsub_right k p i0, ← Set.image_univ, Finsupp.mem_span_image_iff_total,
        Finset.weighted_vsub_eq_weighted_vsub_of_point_of_sum_eq_zero s w p h (p i0),
        Finset.weighted_vsub_of_point_apply]
      let w' := Set.indicator (↑s) w
      have hwx : ∀ i, w' i ≠ 0 → i ∈ s := fun i => Set.mem_of_indicator_ne_zero
      use Finsupp.onFinset s w' hwx, Set.subset_univ _
      rw [Finsupp.total_apply, Finsupp.on_finset_sum hwx]
      · apply Finset.sum_congr rfl
        intro i hi
        simp [w', Set.indicator_apply, if_pos hi]
        
      · exact fun _ => zero_smul k _
        
      
#align weighted_vsub_mem_vector_span weighted_vsub_mem_vector_span

/-- An `affine_combination` with sum of weights 1 is in the
`affine_span` of an indexed family, if the underlying ring is
nontrivial. -/
theorem affine_combination_mem_affine_span [Nontrivial k] {s : Finset ι} {w : ι → k} (h : (∑ i in s, w i) = 1)
    (p : ι → P) : s.affineCombination p w ∈ affineSpan k (Set.range p) := by
  classical have hnz : (∑ i in s, w i) ≠ 0 := h.symm ▸ one_ne_zero
    cases' hn with i1 hi1
    have hw1 : (∑ i in s, w1 i) = 1
    have hw1s : s.affine_combination p w1 = p i1 :=
      s.affine_combination_of_eq_one_of_eq_zero w1 p hi1 (Function.update_same _ _ _) fun _ _ hne =>
        Function.update_noteq hne _ _
    · rw [direction_affine_span, ← hw1s, Finset.affine_combination_vsub]
      apply weighted_vsub_mem_vector_span
      simp [Pi.sub_apply, h, hw1]
      
    exact AffineSubspace.vadd_mem_of_mem_direction hv (mem_affine_span k (Set.mem_range_self _))
#align affine_combination_mem_affine_span affine_combination_mem_affine_span

variable (k) {V}

/-- A vector is in the `vector_span` of an indexed family if and only
if it is a `weighted_vsub` with sum of weights 0. -/
theorem mem_vector_span_iff_eq_weighted_vsub {v : V} {p : ι → P} :
    v ∈ vectorSpan k (Set.range p) ↔ ∃ (s : Finset ι)(w : ι → k)(h : (∑ i in s, w i) = 0), v = s.weightedVsub p w := by
  classical constructor
    · rintro ⟨s, w, hw, rfl⟩
      exact weighted_vsub_mem_vector_span hw p
      
#align mem_vector_span_iff_eq_weighted_vsub mem_vector_span_iff_eq_weighted_vsub

variable {k}

/-- A point in the `affine_span` of an indexed family is an
`affine_combination` with sum of weights 1. See also
`eq_affine_combination_of_mem_affine_span_of_fintype`. -/
theorem eq_affine_combination_of_mem_affine_span {p1 : P} {p : ι → P} (h : p1 ∈ affineSpan k (Set.range p)) :
    ∃ (s : Finset ι)(w : ι → k)(hw : (∑ i in s, w i) = 1), p1 = s.affineCombination p w := by
  classical have hn : (affineSpan k (Set.range p) : Set P).Nonempty := ⟨p1, h⟩
    cases' hn with i0
    have hd : p1 -ᵥ p i0 ∈ (affineSpan k (Set.range p)).direction := AffineSubspace.vsub_mem_direction h h0
    rcases hd with ⟨s, w, h, hs⟩
    let w' := Set.indicator (↑s) w
    · rw [← h, Set.sum_indicator_subset _ (Finset.subset_insert i0 s)]
      
    · rw [hs]
      exact (Finset.weighted_vsub_indicator_subset _ _ (Finset.subset_insert i0 s)).symm
      
    have hw0 : (∑ i in s', w0 i) = 1
    have hw0s : s'.affine_combination p w0 = p i0 :=
      s'.affine_combination_of_eq_one_of_eq_zero w0 p (Finset.mem_insert_self _ _) (Function.update_same _ _ _)
        fun _ _ hne => Function.update_noteq hne _ _
    constructor
    · rw [add_comm, ← Finset.weighted_vsub_vadd_affine_combination, hw0s, hs', vsub_vadd]
      
#align eq_affine_combination_of_mem_affine_span eq_affine_combination_of_mem_affine_span

theorem eq_affine_combination_of_mem_affine_span_of_fintype [Fintype ι] {p1 : P} {p : ι → P}
    (h : p1 ∈ affineSpan k (Set.range p)) :
    ∃ (w : ι → k)(hw : (∑ i, w i) = 1), p1 = Finset.univ.affineCombination p w := by
  classical obtain ⟨s, w, hw, rfl⟩ := eq_affine_combination_of_mem_affine_span h
    simp only [Finset.mem_coe, Set.indicator_apply, ← hw]
#align eq_affine_combination_of_mem_affine_span_of_fintype eq_affine_combination_of_mem_affine_span_of_fintype

variable (k V)

/-- A point is in the `affine_span` of an indexed family if and only
if it is an `affine_combination` with sum of weights 1, provided the
underlying ring is nontrivial. -/
theorem mem_affine_span_iff_eq_affine_combination [Nontrivial k] {p1 : P} {p : ι → P} :
    p1 ∈ affineSpan k (Set.range p) ↔
      ∃ (s : Finset ι)(w : ι → k)(hw : (∑ i in s, w i) = 1), p1 = s.affineCombination p w :=
  by
  constructor
  · exact eq_affine_combination_of_mem_affine_span
    
  · rintro ⟨s, w, hw, rfl⟩
    exact affine_combination_mem_affine_span hw p
    
#align mem_affine_span_iff_eq_affine_combination mem_affine_span_iff_eq_affine_combination

/-- Given a family of points together with a chosen base point in that family, membership of the
affine span of this family corresponds to an identity in terms of `weighted_vsub_of_point`, with
weights that are not required to sum to 1. -/
theorem mem_affine_span_iff_eq_weighted_vsub_of_point_vadd [Nontrivial k] (p : ι → P) (j : ι) (q : P) :
    q ∈ affineSpan k (Set.range p) ↔ ∃ (s : Finset ι)(w : ι → k), q = s.weightedVsubOfPoint p (p j) w +ᵥ p j := by
  constructor
  · intro hq
    obtain ⟨s, w, hw, rfl⟩ := eq_affine_combination_of_mem_affine_span hq
    exact ⟨s, w, s.affine_combination_eq_weighted_vsub_of_point_vadd_of_sum_eq_one w p hw (p j)⟩
    
  · rintro ⟨s, w, rfl⟩
    classical let w' : ι → k := Function.update w j (1 - (s \ {j}).Sum w)
      · by_cases hj:j ∈ s
        · simp [Finset.sum_update_of_mem hj, Finset.insert_eq_of_mem hj]
          
        · simp [w', Finset.sum_insert hj, Finset.sum_update_of_not_mem hj, hj]
          
        
      · intro i hij
        simp [w', hij]
        
      exact affine_combination_mem_affine_span h₁ p
    
#align mem_affine_span_iff_eq_weighted_vsub_of_point_vadd mem_affine_span_iff_eq_weighted_vsub_of_point_vadd

variable {k V}

/-- Given a set of points, together with a chosen base point in this set, if we affinely transport
all other members of the set along the line joining them to this base point, the affine span is
unchanged. -/
theorem affine_span_eq_affine_span_line_map_units [Nontrivial k] {s : Set P} {p : P} (hp : p ∈ s) (w : s → Units k) :
    affineSpan k (Set.range fun q : s => AffineMap.lineMap p ↑q (w q : k)) = affineSpan k s := by
  have : s = Set.range (coe : s → P) := by simp
  conv_rhs => rw [this]
  apply le_antisymm <;>
    intro q hq <;>
      erw [mem_affine_span_iff_eq_weighted_vsub_of_point_vadd k V _ (⟨p, hp⟩ : s) q] at hq⊢ <;>
        obtain ⟨t, μ, rfl⟩ := hq <;>
          use t <;> [use fun x => μ x * ↑(w x), use fun x => μ x * ↑(w x)⁻¹] <;> simp [smul_smul]
#align affine_span_eq_affine_span_line_map_units affine_span_eq_affine_span_line_map_units

end AffineSpace'

section DivisionRing

variable {k : Type _} {V : Type _} {P : Type _} [DivisionRing k] [AddCommGroup V] [Module k V]

variable [affine_space V P] {ι : Type _}

include V

open Set Finset

/-- The centroid lies in the affine span if the number of points,
converted to `k`, is not zero. -/
theorem centroid_mem_affine_span_of_cast_card_ne_zero {s : Finset ι} (p : ι → P) (h : (card s : k) ≠ 0) :
    s.centroid k p ∈ affineSpan k (range p) :=
  affine_combination_mem_affine_span (s.sum_centroid_weights_eq_one_of_cast_card_ne_zero h) p
#align centroid_mem_affine_span_of_cast_card_ne_zero centroid_mem_affine_span_of_cast_card_ne_zero

variable (k)

/-- In the characteristic zero case, the centroid lies in the affine
span if the number of points is not zero. -/
theorem centroid_mem_affine_span_of_card_ne_zero [CharZero k] {s : Finset ι} (p : ι → P) (h : card s ≠ 0) :
    s.centroid k p ∈ affineSpan k (range p) :=
  affine_combination_mem_affine_span (s.sum_centroid_weights_eq_one_of_card_ne_zero k h) p
#align centroid_mem_affine_span_of_card_ne_zero centroid_mem_affine_span_of_card_ne_zero

/-- In the characteristic zero case, the centroid lies in the affine
span if the set is nonempty. -/
theorem centroid_mem_affine_span_of_nonempty [CharZero k] {s : Finset ι} (p : ι → P) (h : s.Nonempty) :
    s.centroid k p ∈ affineSpan k (range p) :=
  affine_combination_mem_affine_span (s.sum_centroid_weights_eq_one_of_nonempty k h) p
#align centroid_mem_affine_span_of_nonempty centroid_mem_affine_span_of_nonempty

/-- In the characteristic zero case, the centroid lies in the affine
span if the number of points is `n + 1`. -/
theorem centroid_mem_affine_span_of_card_eq_add_one [CharZero k] {s : Finset ι} (p : ι → P) {n : ℕ}
    (h : card s = n + 1) : s.centroid k p ∈ affineSpan k (range p) :=
  affine_combination_mem_affine_span (s.sum_centroid_weights_eq_one_of_card_eq_add_one k h) p
#align centroid_mem_affine_span_of_card_eq_add_one centroid_mem_affine_span_of_card_eq_add_one

end DivisionRing

namespace AffineMap

variable {k : Type _} {V : Type _} (P : Type _) [CommRing k] [AddCommGroup V] [Module k V]

variable [affine_space V P] {ι : Type _} (s : Finset ι)

include V

-- TODO: define `affine_map.proj`, `affine_map.fst`, `affine_map.snd`
/-- A weighted sum, as an affine map on the points involved. -/
def weightedVsubOfPoint (w : ι → k) : (ι → P) × P →ᵃ[k] V where
  toFun p := s.weightedVsubOfPoint p.fst p.snd w
  linear := ∑ i in s, w i • ((LinearMap.proj i).comp (LinearMap.fst _ _ _) - LinearMap.snd _ _ _)
  map_vadd' := by
    rintro ⟨p, b⟩ ⟨v, b'⟩
    simp [LinearMap.sum_apply, Finset.weightedVsubOfPoint, vsub_vadd_eq_vsub_sub, vadd_vsub_assoc, add_sub, ←
      sub_add_eq_add_sub, smul_add, Finset.sum_add_distrib]
#align affine_map.weighted_vsub_of_point AffineMap.weightedVsubOfPoint

end AffineMap

