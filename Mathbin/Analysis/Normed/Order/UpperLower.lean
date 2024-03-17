/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies
-/
import Algebra.Order.Field.Pi
import Analysis.Normed.Group.Pointwise
import Analysis.Normed.Order.Basic
import Topology.Algebra.Order.UpperLower

#align_import analysis.normed.order.upper_lower from "leanprover-community/mathlib"@"b1abe23ae96fef89ad30d9f4362c307f72a55010"

/-!
# Upper/lower/order-connected sets in normed groups

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The topological closure and interior of an upper/lower/order-connected set is an
upper/lower/order-connected set (with the notable exception of the closure of an order-connected
set).

We also prove lemmas specific to `ℝⁿ`. Those are helpful to prove that order-connected sets in `ℝⁿ`
are measurable.
-/


open Function Metric Set

open scoped Pointwise

variable {α ι : Type _}

section NormedOrderedGroup

variable [NormedOrderedGroup α] {s : Set α}

#print IsUpperSet.thickening' /-
@[to_additive IsUpperSet.thickening]
protected theorem IsUpperSet.thickening' (hs : IsUpperSet s) (ε : ℝ) :
    IsUpperSet (thickening ε s) := by rw [← ball_mul_one]; exact hs.mul_left
#align is_upper_set.thickening' IsUpperSet.thickening'
#align is_upper_set.thickening IsUpperSet.thickening
-/

#print IsLowerSet.thickening' /-
@[to_additive IsLowerSet.thickening]
protected theorem IsLowerSet.thickening' (hs : IsLowerSet s) (ε : ℝ) :
    IsLowerSet (thickening ε s) := by rw [← ball_mul_one]; exact hs.mul_left
#align is_lower_set.thickening' IsLowerSet.thickening'
#align is_lower_set.thickening IsLowerSet.thickening
-/

#print IsUpperSet.cthickening' /-
@[to_additive IsUpperSet.cthickening]
protected theorem IsUpperSet.cthickening' (hs : IsUpperSet s) (ε : ℝ) :
    IsUpperSet (cthickening ε s) := by rw [cthickening_eq_Inter_thickening''];
  exact isUpperSet_iInter₂ fun δ hδ => hs.thickening' _
#align is_upper_set.cthickening' IsUpperSet.cthickening'
#align is_upper_set.cthickening IsUpperSet.cthickening
-/

#print IsLowerSet.cthickening' /-
@[to_additive IsLowerSet.cthickening]
protected theorem IsLowerSet.cthickening' (hs : IsLowerSet s) (ε : ℝ) :
    IsLowerSet (cthickening ε s) := by rw [cthickening_eq_Inter_thickening''];
  exact isLowerSet_iInter₂ fun δ hδ => hs.thickening' _
#align is_lower_set.cthickening' IsLowerSet.cthickening'
#align is_lower_set.cthickening IsLowerSet.cthickening
-/

@[to_additive upper_closure_interior_subset]
theorem upperClosure_interior_subset' (s : Set α) :
    (upperClosure (interior s) : Set α) ⊆ interior (upperClosure s) :=
  upperClosure_min (interior_mono subset_upperClosure) (upperClosure s).upper.interior
#align upper_closure_interior_subset' upperClosure_interior_subset'
#align upper_closure_interior_subset upper_closure_interior_subset

@[to_additive lower_closure_interior_subset]
theorem lower_closure_interior_subset' (s : Set α) :
    (upperClosure (interior s) : Set α) ⊆ interior (upperClosure s) :=
  upperClosure_min (interior_mono subset_upperClosure) (upperClosure s).upper.interior
#align lower_closure_interior_subset' lower_closure_interior_subset'
#align lower_closure_interior_subset lower_closure_interior_subset

end NormedOrderedGroup

/-! ### `ℝⁿ` -/


section Finite

variable [Finite ι] {s : Set (ι → ℝ)} {x y : ι → ℝ}

#print IsUpperSet.mem_interior_of_forall_lt /-
theorem IsUpperSet.mem_interior_of_forall_lt (hs : IsUpperSet s) (hx : x ∈ closure s)
    (h : ∀ i, x i < y i) : y ∈ interior s :=
  by
  cases nonempty_fintype ι
  obtain ⟨ε, hε, hxy⟩ := Pi.exists_forall_pos_add_lt h
  obtain ⟨z, hz, hxz⟩ := Metric.mem_closure_iff.1 hx _ hε
  rw [dist_pi_lt_iff hε] at hxz
  have hyz : ∀ i, z i < y i :=
    by
    refine' fun i => (hxy _).trans_le' (sub_le_iff_le_add'.1 <| (le_abs_self _).trans _)
    rw [← Real.norm_eq_abs, ← dist_eq_norm']
    exact (hxz _).le
  obtain ⟨δ, hδ, hyz⟩ := Pi.exists_forall_pos_add_lt hyz
  refine' mem_interior.2 ⟨ball y δ, _, is_open_ball, mem_ball_self hδ⟩
  rintro w hw
  refine' hs (fun i => _) hz
  simp_rw [ball_pi _ hδ, Real.ball_eq_Ioo] at hw
  exact ((lt_sub_iff_add_lt.2 <| hyz _).trans (hw _ <| mem_univ _).1).le
#align is_upper_set.mem_interior_of_forall_lt IsUpperSet.mem_interior_of_forall_lt
-/

#print IsLowerSet.mem_interior_of_forall_lt /-
theorem IsLowerSet.mem_interior_of_forall_lt (hs : IsLowerSet s) (hx : x ∈ closure s)
    (h : ∀ i, y i < x i) : y ∈ interior s :=
  by
  cases nonempty_fintype ι
  obtain ⟨ε, hε, hxy⟩ := Pi.exists_forall_pos_add_lt h
  obtain ⟨z, hz, hxz⟩ := Metric.mem_closure_iff.1 hx _ hε
  rw [dist_pi_lt_iff hε] at hxz
  have hyz : ∀ i, y i < z i :=
    by
    refine' fun i =>
      (lt_sub_iff_add_lt.2 <| hxy _).trans_le (sub_le_comm.1 <| (le_abs_self _).trans _)
    rw [← Real.norm_eq_abs, ← dist_eq_norm]
    exact (hxz _).le
  obtain ⟨δ, hδ, hyz⟩ := Pi.exists_forall_pos_add_lt hyz
  refine' mem_interior.2 ⟨ball y δ, _, is_open_ball, mem_ball_self hδ⟩
  rintro w hw
  refine' hs (fun i => _) hz
  simp_rw [ball_pi _ hδ, Real.ball_eq_Ioo] at hw
  exact ((hw _ <| mem_univ _).2.trans <| hyz _).le
#align is_lower_set.mem_interior_of_forall_lt IsLowerSet.mem_interior_of_forall_lt
-/

end Finite

section Fintype

variable [Fintype ι] {s t : Set (ι → ℝ)} {a₁ a₂ b₁ b₂ x y : ι → ℝ} {δ : ℝ}

-- TODO: Generalise those lemmas so that they also apply to `ℝ` and `euclidean_space ι ℝ`
theorem dist_inf_sup (x y : ι → ℝ) : dist (x ⊓ y) (x ⊔ y) = dist x y :=
  by
  refine' congr_arg coe (Finset.sup_congr rfl fun i _ => _)
  simp only [Real.nndist_eq', sup_eq_max, inf_eq_min, max_sub_min_eq_abs, Pi.inf_apply,
    Pi.sup_apply, Real.nnabs_of_nonneg, abs_nonneg, Real.toNNReal_abs]
#align dist_inf_sup dist_inf_sup

theorem dist_mono_left : MonotoneOn (fun x => dist x y) (Ici y) :=
  by
  refine' fun y₁ hy₁ y₂ hy₂ hy => NNReal.coe_le_coe.2 (Finset.sup_mono_fun fun i _ => _)
  rw [Real.nndist_eq, Real.nnabs_of_nonneg (sub_nonneg_of_le (‹y ≤ _› i : y i ≤ y₁ i)),
    Real.nndist_eq, Real.nnabs_of_nonneg (sub_nonneg_of_le (‹y ≤ _› i : y i ≤ y₂ i))]
  exact Real.toNNReal_mono (sub_le_sub_right (hy _) _)
#align dist_mono_left dist_mono_left

theorem dist_mono_right : MonotoneOn (dist x) (Ici x) := by
  simpa only [dist_comm] using dist_mono_left
#align dist_mono_right dist_mono_right

theorem dist_anti_left : AntitoneOn (fun x => dist x y) (Iic y) :=
  by
  refine' fun y₁ hy₁ y₂ hy₂ hy => NNReal.coe_le_coe.2 (Finset.sup_mono_fun fun i _ => _)
  rw [Real.nndist_eq', Real.nnabs_of_nonneg (sub_nonneg_of_le (‹_ ≤ y› i : y₂ i ≤ y i)),
    Real.nndist_eq', Real.nnabs_of_nonneg (sub_nonneg_of_le (‹_ ≤ y› i : y₁ i ≤ y i))]
  exact Real.toNNReal_mono (sub_le_sub_left (hy _) _)
#align dist_anti_left dist_anti_left

theorem dist_anti_right : AntitoneOn (dist x) (Iic x) := by
  simpa only [dist_comm] using dist_anti_left
#align dist_anti_right dist_anti_right

theorem dist_le_dist_of_le (ha : a₂ ≤ a₁) (h₁ : a₁ ≤ b₁) (hb : b₁ ≤ b₂) : dist a₁ b₁ ≤ dist a₂ b₂ :=
  (dist_mono_right h₁ (h₁.trans hb) hb).trans <|
    dist_anti_left (ha.trans <| h₁.trans hb) (h₁.trans hb) ha
#align dist_le_dist_of_le dist_le_dist_of_le

protected theorem Bornology.IsBounded.bddBelow : Bounded s → BddBelow s :=
  by
  rintro ⟨r, hr⟩
  obtain rfl | ⟨x, hx⟩ := s.eq_empty_or_nonempty
  · exact bddBelow_empty
  ·
    exact
      ⟨x - const _ r, fun y hy i =>
        sub_le_comm.1 (abs_sub_le_iff.1 <| (dist_le_pi_dist _ _ _).trans <| hr _ hx _ hy).1⟩
#align metric.bounded.bdd_below Bornology.IsBounded.bddBelow

protected theorem Bornology.IsBounded.bddAbove : Bounded s → BddAbove s :=
  by
  rintro ⟨r, hr⟩
  obtain rfl | ⟨x, hx⟩ := s.eq_empty_or_nonempty
  · exact bddAbove_empty
  ·
    exact
      ⟨x + const _ r, fun y hy i =>
        sub_le_iff_le_add'.1 <|
          (abs_sub_le_iff.1 <| (dist_le_pi_dist _ _ _).trans <| hr _ hx _ hy).2⟩
#align metric.bounded.bdd_above Bornology.IsBounded.bddAbove

protected theorem BddBelow.isBounded : BddBelow s → BddAbove s → Bounded s :=
  by
  rintro ⟨a, ha⟩ ⟨b, hb⟩
  refine' ⟨dist a b, fun x hx y hy => _⟩
  rw [← dist_inf_sup]
  exact dist_le_dist_of_le (le_inf (ha hx) <| ha hy) inf_le_sup (sup_le (hb hx) <| hb hy)
#align bdd_below.bounded BddBelow.isBounded

protected theorem BddAbove.isBounded : BddAbove s → BddBelow s → Bounded s :=
  flip BddBelow.isBounded
#align bdd_above.bounded BddAbove.isBounded

theorem isBounded_iff_bddBelow_bddAbove : Bounded s ↔ BddBelow s ∧ BddAbove s :=
  ⟨fun h => ⟨h.BddBelow, h.BddAbove⟩, fun h => h.1.Bounded h.2⟩
#align bounded_iff_bdd_below_bdd_above isBounded_iff_bddBelow_bddAbove

theorem BddBelow.isBounded_inter (hs : BddBelow s) (ht : BddAbove t) : Bounded (s ∩ t) :=
  (hs.mono <| inter_subset_left _ _).Bounded <| ht.mono <| inter_subset_right _ _
#align bdd_below.bounded_inter BddBelow.isBounded_inter

theorem BddAbove.isBounded_inter (hs : BddAbove s) (ht : BddBelow t) : Bounded (s ∩ t) :=
  (hs.mono <| inter_subset_left _ _).Bounded <| ht.mono <| inter_subset_right _ _
#align bdd_above.bounded_inter BddAbove.isBounded_inter

#print IsUpperSet.exists_subset_ball /-
theorem IsUpperSet.exists_subset_ball (hs : IsUpperSet s) (hx : x ∈ closure s) (hδ : 0 < δ) :
    ∃ y, closedBall y (δ / 4) ⊆ closedBall x δ ∧ closedBall y (δ / 4) ⊆ interior s :=
  by
  refine' ⟨x + const _ (3 / 4 * δ), closed_ball_subset_closed_ball' _, _⟩
  · rw [dist_self_add_left]
    refine' (add_le_add_left (pi_norm_const_le <| 3 / 4 * δ) _).trans_eq _
    simp [Real.norm_of_nonneg, hδ.le, zero_le_three]
    ring_nf
  obtain ⟨y, hy, hxy⟩ := Metric.mem_closure_iff.1 hx _ (div_pos hδ zero_lt_four)
  refine' fun z hz => hs.mem_interior_of_forall_lt (subset_closure hy) fun i => _
  rw [mem_closed_ball, dist_eq_norm'] at hz
  rw [dist_eq_norm] at hxy
  replace hxy := (norm_le_pi_norm _ i).trans hxy.le
  replace hz := (norm_le_pi_norm _ i).trans hz
  dsimp at hxy hz
  rw [abs_sub_le_iff] at hxy hz
  linarith
#align is_upper_set.exists_subset_ball IsUpperSet.exists_subset_ball
-/

#print IsLowerSet.exists_subset_ball /-
theorem IsLowerSet.exists_subset_ball (hs : IsLowerSet s) (hx : x ∈ closure s) (hδ : 0 < δ) :
    ∃ y, closedBall y (δ / 4) ⊆ closedBall x δ ∧ closedBall y (δ / 4) ⊆ interior s :=
  by
  refine' ⟨x - const _ (3 / 4 * δ), closed_ball_subset_closed_ball' _, _⟩
  · rw [dist_self_sub_left]
    refine' (add_le_add_left (pi_norm_const_le <| 3 / 4 * δ) _).trans_eq _
    simp [Real.norm_of_nonneg, hδ.le, zero_le_three]
    ring_nf
  obtain ⟨y, hy, hxy⟩ := Metric.mem_closure_iff.1 hx _ (div_pos hδ zero_lt_four)
  refine' fun z hz => hs.mem_interior_of_forall_lt (subset_closure hy) fun i => _
  rw [mem_closed_ball, dist_eq_norm'] at hz
  rw [dist_eq_norm] at hxy
  replace hxy := (norm_le_pi_norm _ i).trans hxy.le
  replace hz := (norm_le_pi_norm _ i).trans hz
  dsimp at hxy hz
  rw [abs_sub_le_iff] at hxy hz
  linarith
#align is_lower_set.exists_subset_ball IsLowerSet.exists_subset_ball
-/

end Fintype

section Finite

variable [Finite ι] {s t : Set (ι → ℝ)} {a₁ a₂ b₁ b₂ x y : ι → ℝ} {δ : ℝ}

#print IsAntichain.interior_eq_empty /-
theorem IsAntichain.interior_eq_empty [Nonempty ι] (hs : IsAntichain (· ≤ ·) s) : interior s = ∅ :=
  by
  cases nonempty_fintype ι
  refine' eq_empty_of_forall_not_mem fun x hx => _
  have hx' := interior_subset hx
  rw [mem_interior_iff_mem_nhds, Metric.mem_nhds_iff] at hx
  obtain ⟨ε, hε, hx⟩ := hx
  refine' hs.not_lt hx' (hx _) (lt_add_of_pos_right _ (by positivity : 0 < const ι (ε / 2)))
  simpa [const, @pi_norm_const ι ℝ _ _ _ (ε / 2), abs_of_nonneg hε.lt.le]
#align is_antichain.interior_eq_empty IsAntichain.interior_eq_empty
-/

/-!
#### Note

The closure and frontier of an antichain might not be antichains. Take for example the union
of the open segments from `(0, 2)` to `(1, 1)` and from `(2, 1)` to `(3, 0)`. `(1, 1)` and `(2, 1)`
are comparable and both in the closure/frontier.
-/


protected theorem IsClosed.upperClosure (hs : IsClosed s) (hs' : BddBelow s) :
    IsClosed (upperClosure s : Set (ι → ℝ)) :=
  by
  cases nonempty_fintype ι
  refine' IsSeqClosed.isClosed fun f x hf hx => _
  choose g hg hgf using hf
  obtain ⟨a, ha⟩ := hx.bdd_above_range
  obtain ⟨b, hb, φ, hφ, hbf⟩ :=
    tendsto_subseq_of_bounded (hs'.bounded_inter bddAbove_Iic) fun n =>
      ⟨hg n, (hgf _).trans <| ha <| mem_range_self _⟩
  exact
    ⟨b, closure_minimal (inter_subset_left _ _) hs hb,
      le_of_tendsto_of_tendsto' hbf (hx.comp hφ.tendsto_at_top) fun _ => hgf _⟩
#align is_closed.upper_closure IsClosed.upperClosure

protected theorem IsClosed.lowerClosure (hs : IsClosed s) (hs' : BddAbove s) :
    IsClosed (lowerClosure s : Set (ι → ℝ)) :=
  by
  cases nonempty_fintype ι
  refine' IsSeqClosed.isClosed fun f x hf hx => _
  choose g hg hfg using hf
  haveI : BoundedGENhdsClass ℝ := by infer_instance
  obtain ⟨a, ha⟩ := hx.bdd_below_range
  obtain ⟨b, hb, φ, hφ, hbf⟩ :=
    tendsto_subseq_of_bounded (hs'.bounded_inter bddBelow_Ici) fun n =>
      ⟨hg n, (ha <| mem_range_self _).trans <| hfg _⟩
  exact
    ⟨b, closure_minimal (inter_subset_left _ _) hs hb,
      le_of_tendsto_of_tendsto' (hx.comp hφ.tendsto_at_top) hbf fun _ => hfg _⟩
#align is_closed.lower_closure IsClosed.lowerClosure

protected theorem IsClopen.upperClosure (hs : IsClopen s) (hs' : BddBelow s) :
    IsClopen (upperClosure s : Set (ι → ℝ)) :=
  ⟨hs.1.upperClosure, hs.2.upperClosure hs'⟩
#align is_clopen.upper_closure IsClopen.upperClosure

protected theorem IsClopen.lowerClosure (hs : IsClopen s) (hs' : BddAbove s) :
    IsClopen (lowerClosure s : Set (ι → ℝ)) :=
  ⟨hs.1.lowerClosure, hs.2.lowerClosure hs'⟩
#align is_clopen.lower_closure IsClopen.lowerClosure

theorem closure_upperClosure_comm (hs : BddBelow s) :
    closure (upperClosure s : Set (ι → ℝ)) = upperClosure (closure s) :=
  (closure_minimal (upperClosure_anti subset_closure) <|
        isClosed_closure.upperClosure hs.closure).antisymm <|
    upperClosure_min (closure_mono subset_upperClosure) (upperClosure s).upper.closure
#align closure_upper_closure_comm closure_upperClosure_comm

theorem closure_lowerClosure_comm (hs : BddAbove s) :
    closure (lowerClosure s : Set (ι → ℝ)) = lowerClosure (closure s) :=
  (closure_minimal (lowerClosure_mono subset_closure) <|
        isClosed_closure.lowerClosure hs.closure).antisymm <|
    lowerClosure_min (closure_mono subset_lowerClosure) (lowerClosure s).lower.closure
#align closure_lower_closure_comm closure_lowerClosure_comm

end Finite

