/-
Copyright (c) 2018 Rohan Mitta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rohan Mitta, Kevin Buzzard, Alistair Tucker, Johannes Hölzl, Yury Kudryashov
-/
import Logic.Function.Iterate
import Data.Set.Intervals.ProjIcc
import Topology.Algebra.Order.Field
import Topology.MetricSpace.Basic
import Topology.Bornology.Hom

#align_import topology.metric_space.lipschitz from "leanprover-community/mathlib"@"c8f305514e0d47dfaa710f5a52f0d21b588e6328"

/-!
# Lipschitz continuous functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A map `f : α → β` between two (extended) metric spaces is called *Lipschitz continuous*
with constant `K ≥ 0` if for all `x, y` we have `edist (f x) (f y) ≤ K * edist x y`.
For a metric space, the latter inequality is equivalent to `dist (f x) (f y) ≤ K * dist x y`.
There is also a version asserting this inequality only for `x` and `y` in some set `s`.

In this file we provide various ways to prove that various combinations of Lipschitz continuous
functions are Lipschitz continuous. We also prove that Lipschitz continuous functions are
uniformly continuous.

## Main definitions and lemmas

* `lipschitz_with K f`: states that `f` is Lipschitz with constant `K : ℝ≥0`
* `lipschitz_on_with K f`: states that `f` is Lipschitz with constant `K : ℝ≥0` on a set `s`
* `lipschitz_with.uniform_continuous`: a Lipschitz function is uniformly continuous
* `lipschitz_on_with.uniform_continuous_on`: a function which is Lipschitz on a set is uniformly
  continuous on that set.


## Implementation notes

The parameter `K` has type `ℝ≥0`. This way we avoid conjuction in the definition and have
coercions both to `ℝ` and `ℝ≥0∞`. Constructors whose names end with `'` take `K : ℝ` as an
argument, and return `lipschitz_with (real.to_nnreal K) f`.
-/


universe u v w x

open Filter Function Set

open scoped Topology NNReal ENNReal

variable {α : Type u} {β : Type v} {γ : Type w} {ι : Type x}

#print LipschitzWith /-
/-- A function `f` is Lipschitz continuous with constant `K ≥ 0` if for all `x, y`
we have `dist (f x) (f y) ≤ K * dist x y` -/
def LipschitzWith [PseudoEMetricSpace α] [PseudoEMetricSpace β] (K : ℝ≥0) (f : α → β) :=
  ∀ x y, edist (f x) (f y) ≤ K * edist x y
#align lipschitz_with LipschitzWith
-/

#print lipschitzWith_iff_dist_le_mul /-
theorem lipschitzWith_iff_dist_le_mul [PseudoMetricSpace α] [PseudoMetricSpace β] {K : ℝ≥0}
    {f : α → β} : LipschitzWith K f ↔ ∀ x y, dist (f x) (f y) ≤ K * dist x y := by
  simp only [LipschitzWith, edist_nndist, dist_nndist]; norm_cast
#align lipschitz_with_iff_dist_le_mul lipschitzWith_iff_dist_le_mul
-/

alias ⟨LipschitzWith.dist_le_mul, LipschitzWith.of_dist_le_mul⟩ := lipschitzWith_iff_dist_le_mul
#align lipschitz_with.dist_le_mul LipschitzWith.dist_le_mul
#align lipschitz_with.of_dist_le_mul LipschitzWith.of_dist_le_mul

#print LipschitzOnWith /-
/-- A function `f` is Lipschitz continuous with constant `K ≥ 0` on `s` if for all `x, y` in `s`
we have `dist (f x) (f y) ≤ K * dist x y` -/
def LipschitzOnWith [PseudoEMetricSpace α] [PseudoEMetricSpace β] (K : ℝ≥0) (f : α → β)
    (s : Set α) :=
  ∀ ⦃x⦄ (hx : x ∈ s) ⦃y⦄ (hy : y ∈ s), edist (f x) (f y) ≤ K * edist x y
#align lipschitz_on_with LipschitzOnWith
-/

#print lipschitzOnWith_empty /-
@[simp]
theorem lipschitzOnWith_empty [PseudoEMetricSpace α] [PseudoEMetricSpace β] (K : ℝ≥0) (f : α → β) :
    LipschitzOnWith K f ∅ := fun x x_in y y_in => False.elim x_in
#align lipschitz_on_with_empty lipschitzOnWith_empty
-/

#print LipschitzOnWith.mono /-
theorem LipschitzOnWith.mono [PseudoEMetricSpace α] [PseudoEMetricSpace β] {K : ℝ≥0} {s t : Set α}
    {f : α → β} (hf : LipschitzOnWith K f t) (h : s ⊆ t) : LipschitzOnWith K f s :=
  fun x x_in y y_in => hf (h x_in) (h y_in)
#align lipschitz_on_with.mono LipschitzOnWith.mono
-/

#print lipschitzOnWith_iff_dist_le_mul /-
theorem lipschitzOnWith_iff_dist_le_mul [PseudoMetricSpace α] [PseudoMetricSpace β] {K : ℝ≥0}
    {s : Set α} {f : α → β} :
    LipschitzOnWith K f s ↔ ∀ x ∈ s, ∀ y ∈ s, dist (f x) (f y) ≤ K * dist x y := by
  simp only [LipschitzOnWith, edist_nndist, dist_nndist]; norm_cast
#align lipschitz_on_with_iff_dist_le_mul lipschitzOnWith_iff_dist_le_mul
-/

alias ⟨LipschitzOnWith.dist_le_mul, LipschitzOnWith.of_dist_le_mul⟩ :=
  lipschitzOnWith_iff_dist_le_mul
#align lipschitz_on_with.dist_le_mul LipschitzOnWith.dist_le_mul
#align lipschitz_on_with.of_dist_le_mul LipschitzOnWith.of_dist_le_mul

#print lipschitzOn_univ /-
@[simp]
theorem lipschitzOn_univ [PseudoEMetricSpace α] [PseudoEMetricSpace β] {K : ℝ≥0} {f : α → β} :
    LipschitzOnWith K f univ ↔ LipschitzWith K f := by simp [LipschitzOnWith, LipschitzWith]
#align lipschitz_on_univ lipschitzOn_univ
-/

#print lipschitzOnWith_iff_restrict /-
theorem lipschitzOnWith_iff_restrict [PseudoEMetricSpace α] [PseudoEMetricSpace β] {K : ℝ≥0}
    {f : α → β} {s : Set α} : LipschitzOnWith K f s ↔ LipschitzWith K (s.restrict f) := by
  simp only [LipschitzOnWith, LipschitzWith, SetCoe.forall', restrict, Subtype.edist_eq]
#align lipschitz_on_with_iff_restrict lipschitzOnWith_iff_restrict
-/

alias ⟨LipschitzOnWith.to_restrict, _⟩ := lipschitzOnWith_iff_restrict
#align lipschitz_on_with.to_restrict LipschitzOnWith.to_restrict

#print MapsTo.lipschitzOnWith_iff_restrict /-
theorem MapsTo.lipschitzOnWith_iff_restrict [PseudoEMetricSpace α] [PseudoEMetricSpace β] {K : ℝ≥0}
    {f : α → β} {s : Set α} {t : Set β} (h : MapsTo f s t) :
    LipschitzOnWith K f s ↔ LipschitzWith K (h.restrict f s t) :=
  lipschitzOnWith_iff_restrict
#align maps_to.lipschitz_on_with_iff_restrict MapsTo.lipschitzOnWith_iff_restrict
-/

alias ⟨LipschitzOnWith.to_restrict_mapsTo, _⟩ := MapsTo.lipschitzOnWith_iff_restrict
#align lipschitz_on_with.to_restrict_maps_to LipschitzOnWith.to_restrict_mapsTo

namespace LipschitzWith

section Emetric

open Emetric

variable [PseudoEMetricSpace α] [PseudoEMetricSpace β] [PseudoEMetricSpace γ]

variable {K : ℝ≥0} {f : α → β} {x y : α} {r : ℝ≥0∞}

#print LipschitzWith.lipschitzOnWith /-
protected theorem lipschitzOnWith (h : LipschitzWith K f) (s : Set α) : LipschitzOnWith K f s :=
  fun x _ y _ => h x y
#align lipschitz_with.lipschitz_on_with LipschitzWith.lipschitzOnWith
-/

#print LipschitzWith.edist_le_mul /-
theorem edist_le_mul (h : LipschitzWith K f) (x y : α) : edist (f x) (f y) ≤ K * edist x y :=
  h x y
#align lipschitz_with.edist_le_mul LipschitzWith.edist_le_mul
-/

#print LipschitzWith.edist_le_mul_of_le /-
theorem edist_le_mul_of_le (h : LipschitzWith K f) (hr : edist x y ≤ r) :
    edist (f x) (f y) ≤ K * r :=
  (h x y).trans <| ENNReal.mul_left_mono hr
#align lipschitz_with.edist_le_mul_of_le LipschitzWith.edist_le_mul_of_le
-/

#print LipschitzWith.edist_lt_mul_of_lt /-
theorem edist_lt_mul_of_lt (h : LipschitzWith K f) (hK : K ≠ 0) (hr : edist x y < r) :
    edist (f x) (f y) < K * r :=
  (h x y).trans_lt <| (ENNReal.mul_lt_mul_left (ENNReal.coe_ne_zero.2 hK) ENNReal.coe_ne_top).2 hr
#align lipschitz_with.edist_lt_mul_of_lt LipschitzWith.edist_lt_mul_of_lt
-/

#print LipschitzWith.mapsTo_emetric_closedBall /-
theorem mapsTo_emetric_closedBall (h : LipschitzWith K f) (x : α) (r : ℝ≥0∞) :
    MapsTo f (closedBall x r) (closedBall (f x) (K * r)) := fun y hy => h.edist_le_mul_of_le hy
#align lipschitz_with.maps_to_emetric_closed_ball LipschitzWith.mapsTo_emetric_closedBall
-/

#print LipschitzWith.mapsTo_emetric_ball /-
theorem mapsTo_emetric_ball (h : LipschitzWith K f) (hK : K ≠ 0) (x : α) (r : ℝ≥0∞) :
    MapsTo f (ball x r) (ball (f x) (K * r)) := fun y hy => h.edist_lt_mul_of_lt hK hy
#align lipschitz_with.maps_to_emetric_ball LipschitzWith.mapsTo_emetric_ball
-/

#print LipschitzWith.edist_lt_top /-
theorem edist_lt_top (hf : LipschitzWith K f) {x y : α} (h : edist x y ≠ ⊤) :
    edist (f x) (f y) < ⊤ :=
  (hf x y).trans_lt <| ENNReal.mul_lt_top ENNReal.coe_ne_top h
#align lipschitz_with.edist_lt_top LipschitzWith.edist_lt_top
-/

#print LipschitzWith.mul_edist_le /-
theorem mul_edist_le (h : LipschitzWith K f) (x y : α) :
    (K⁻¹ : ℝ≥0∞) * edist (f x) (f y) ≤ edist x y :=
  by
  rw [mul_comm, ← div_eq_mul_inv]
  exact ENNReal.div_le_of_le_mul' (h x y)
#align lipschitz_with.mul_edist_le LipschitzWith.mul_edist_le
-/

#print LipschitzWith.of_edist_le /-
protected theorem of_edist_le (h : ∀ x y, edist (f x) (f y) ≤ edist x y) : LipschitzWith 1 f :=
  fun x y => by simp only [ENNReal.coe_one, one_mul, h]
#align lipschitz_with.of_edist_le LipschitzWith.of_edist_le
-/

#print LipschitzWith.weaken /-
protected theorem weaken (hf : LipschitzWith K f) {K' : ℝ≥0} (h : K ≤ K') : LipschitzWith K' f :=
  fun x y => le_trans (hf x y) <| ENNReal.mul_right_mono (ENNReal.coe_le_coe.2 h)
#align lipschitz_with.weaken LipschitzWith.weaken
-/

#print LipschitzWith.ediam_image_le /-
theorem ediam_image_le (hf : LipschitzWith K f) (s : Set α) :
    EMetric.diam (f '' s) ≤ K * EMetric.diam s :=
  by
  apply EMetric.diam_le
  rintro _ ⟨x, hx, rfl⟩ _ ⟨y, hy, rfl⟩
  exact hf.edist_le_mul_of_le (EMetric.edist_le_diam_of_mem hx hy)
#align lipschitz_with.ediam_image_le LipschitzWith.ediam_image_le
-/

#print LipschitzWith.edist_lt_of_edist_lt_div /-
theorem edist_lt_of_edist_lt_div (hf : LipschitzWith K f) {x y : α} {d : ℝ≥0∞}
    (h : edist x y < d / K) : edist (f x) (f y) < d :=
  calc
    edist (f x) (f y) ≤ K * edist x y := hf x y
    _ < d := ENNReal.mul_lt_of_lt_div' h
#align lipschitz_with.edist_lt_of_edist_lt_div LipschitzWith.edist_lt_of_edist_lt_div
-/

#print LipschitzWith.uniformContinuous /-
/-- A Lipschitz function is uniformly continuous -/
protected theorem uniformContinuous (hf : LipschitzWith K f) : UniformContinuous f :=
  by
  refine' EMetric.uniformContinuous_iff.2 fun ε εpos => _
  use ε / K, ENNReal.div_pos_iff.2 ⟨ne_of_gt εpos, ENNReal.coe_ne_top⟩
  exact fun x y => hf.edist_lt_of_edist_lt_div
#align lipschitz_with.uniform_continuous LipschitzWith.uniformContinuous
-/

#print LipschitzWith.continuous /-
/-- A Lipschitz function is continuous -/
protected theorem continuous (hf : LipschitzWith K f) : Continuous f :=
  hf.UniformContinuous.Continuous
#align lipschitz_with.continuous LipschitzWith.continuous
-/

#print LipschitzWith.const /-
protected theorem const (b : β) : LipschitzWith 0 fun a : α => b := fun x y => by
  simp only [edist_self, zero_le]
#align lipschitz_with.const LipschitzWith.const
-/

#print LipschitzWith.id /-
protected theorem id : LipschitzWith 1 (@id α) :=
  LipschitzWith.of_edist_le fun x y => le_rfl
#align lipschitz_with.id LipschitzWith.id
-/

#print LipschitzWith.subtype_val /-
protected theorem subtype_val (s : Set α) : LipschitzWith 1 (Subtype.val : s → α) :=
  LipschitzWith.of_edist_le fun x y => le_rfl
#align lipschitz_with.subtype_val LipschitzWith.subtype_val
-/

/- warning: lipschitz_with.subtype_coe clashes with lipschitz_with.subtype_val -> LipschitzWith.subtype_val
Case conversion may be inaccurate. Consider using '#align lipschitz_with.subtype_coe LipschitzWith.subtype_valₓ'. -/
#print LipschitzWith.subtype_val /-
protected theorem subtype_val (s : Set α) : LipschitzWith 1 (coe : s → α) :=
  LipschitzWith.subtype_val s
#align lipschitz_with.subtype_coe LipschitzWith.subtype_val
-/

#print LipschitzWith.subtype_mk /-
theorem subtype_mk (hf : LipschitzWith K f) {p : β → Prop} (hp : ∀ x, p (f x)) :
    LipschitzWith K (fun x => ⟨f x, hp x⟩ : α → { y // p y }) :=
  hf
#align lipschitz_with.subtype_mk LipschitzWith.subtype_mk
-/

#print LipschitzWith.eval /-
protected theorem eval {α : ι → Type u} [∀ i, PseudoEMetricSpace (α i)] [Fintype ι] (i : ι) :
    LipschitzWith 1 (Function.eval i : (∀ i, α i) → α i) :=
  LipschitzWith.of_edist_le fun f g => by convert edist_le_pi_edist f g i
#align lipschitz_with.eval LipschitzWith.eval
-/

#print LipschitzWith.restrict /-
protected theorem restrict (hf : LipschitzWith K f) (s : Set α) : LipschitzWith K (s.restrict f) :=
  fun x y => hf x y
#align lipschitz_with.restrict LipschitzWith.restrict
-/

#print LipschitzWith.comp /-
protected theorem comp {Kf Kg : ℝ≥0} {f : β → γ} {g : α → β} (hf : LipschitzWith Kf f)
    (hg : LipschitzWith Kg g) : LipschitzWith (Kf * Kg) (f ∘ g) := fun x y =>
  calc
    edist (f (g x)) (f (g y)) ≤ Kf * edist (g x) (g y) := hf _ _
    _ ≤ Kf * (Kg * edist x y) := (ENNReal.mul_left_mono (hg _ _))
    _ = (Kf * Kg : ℝ≥0) * edist x y := by rw [← mul_assoc, ENNReal.coe_mul]
#align lipschitz_with.comp LipschitzWith.comp
-/

#print LipschitzWith.comp_lipschitzOnWith /-
theorem comp_lipschitzOnWith {Kf Kg : ℝ≥0} {f : β → γ} {g : α → β} {s : Set α}
    (hf : LipschitzWith Kf f) (hg : LipschitzOnWith Kg g s) : LipschitzOnWith (Kf * Kg) (f ∘ g) s :=
  lipschitzOnWith_iff_restrict.mpr <| hf.comp hg.to_restrict
#align lipschitz_with.comp_lipschitz_on_with LipschitzWith.comp_lipschitzOnWith
-/

#print LipschitzWith.prod_fst /-
protected theorem prod_fst : LipschitzWith 1 (@Prod.fst α β) :=
  LipschitzWith.of_edist_le fun x y => le_max_left _ _
#align lipschitz_with.prod_fst LipschitzWith.prod_fst
-/

#print LipschitzWith.prod_snd /-
protected theorem prod_snd : LipschitzWith 1 (@Prod.snd α β) :=
  LipschitzWith.of_edist_le fun x y => le_max_right _ _
#align lipschitz_with.prod_snd LipschitzWith.prod_snd
-/

#print LipschitzWith.prod /-
protected theorem prod {f : α → β} {Kf : ℝ≥0} (hf : LipschitzWith Kf f) {g : α → γ} {Kg : ℝ≥0}
    (hg : LipschitzWith Kg g) : LipschitzWith (max Kf Kg) fun x => (f x, g x) :=
  by
  intro x y
  rw [ennreal.coe_mono.map_max, Prod.edist_eq, ENNReal.max_mul]
  exact max_le_max (hf x y) (hg x y)
#align lipschitz_with.prod LipschitzWith.prod
-/

#print LipschitzWith.prod_mk_left /-
protected theorem prod_mk_left (a : α) : LipschitzWith 1 (Prod.mk a : β → α × β) := by
  simpa only [max_eq_right zero_le_one] using (LipschitzWith.const a).Prod LipschitzWith.id
#align lipschitz_with.prod_mk_left LipschitzWith.prod_mk_left
-/

#print LipschitzWith.prod_mk_right /-
protected theorem prod_mk_right (b : β) : LipschitzWith 1 fun a : α => (a, b) := by
  simpa only [max_eq_left zero_le_one] using lipschitz_with.id.prod (LipschitzWith.const b)
#align lipschitz_with.prod_mk_right LipschitzWith.prod_mk_right
-/

#print LipschitzWith.uncurry /-
protected theorem uncurry {f : α → β → γ} {Kα Kβ : ℝ≥0} (hα : ∀ b, LipschitzWith Kα fun a => f a b)
    (hβ : ∀ a, LipschitzWith Kβ (f a)) : LipschitzWith (Kα + Kβ) (Function.uncurry f) :=
  by
  rintro ⟨a₁, b₁⟩ ⟨a₂, b₂⟩
  simp only [Function.uncurry, ENNReal.coe_add, add_mul]
  apply le_trans (edist_triangle _ (f a₂ b₁) _)
  exact
    add_le_add (le_trans (hα _ _ _) <| ENNReal.mul_left_mono <| le_max_left _ _)
      (le_trans (hβ _ _ _) <| ENNReal.mul_left_mono <| le_max_right _ _)
#align lipschitz_with.uncurry LipschitzWith.uncurry
-/

#print LipschitzWith.iterate /-
protected theorem iterate {f : α → α} (hf : LipschitzWith K f) : ∀ n, LipschitzWith (K ^ n) (f^[n])
  | 0 => by simpa only [pow_zero] using LipschitzWith.id
  | n + 1 => by rw [pow_succ'] <;> exact (iterate n).comp hf
#align lipschitz_with.iterate LipschitzWith.iterate
-/

#print LipschitzWith.edist_iterate_succ_le_geometric /-
theorem edist_iterate_succ_le_geometric {f : α → α} (hf : LipschitzWith K f) (x n) :
    edist ((f^[n]) x) ((f^[n + 1]) x) ≤ edist x (f x) * K ^ n :=
  by
  rw [iterate_succ, mul_comm]
  simpa only [ENNReal.coe_pow] using (hf.iterate n) x (f x)
#align lipschitz_with.edist_iterate_succ_le_geometric LipschitzWith.edist_iterate_succ_le_geometric
-/

#print LipschitzWith.mul_end /-
protected theorem mul_end {f g : Function.End α} {Kf Kg} (hf : LipschitzWith Kf f)
    (hg : LipschitzWith Kg g) : LipschitzWith (Kf * Kg) (f * g : Function.End α) :=
  hf.comp hg
#align lipschitz_with.mul LipschitzWith.mul_end
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print LipschitzWith.list_prod /-
/-- The product of a list of Lipschitz continuous endomorphisms is a Lipschitz continuous
endomorphism. -/
protected theorem list_prod (f : ι → Function.End α) (K : ι → ℝ≥0)
    (h : ∀ i, LipschitzWith (K i) (f i)) : ∀ l : List ι, LipschitzWith (l.map K).Prod (l.map f).Prod
  | [] => by simpa using LipschitzWith.id
  | i::l => by simp only [List.map_cons, List.prod_cons]; exact (h i).mul (list_prod l)
#align lipschitz_with.list_prod LipschitzWith.list_prod
-/

#print LipschitzWith.pow_end /-
protected theorem pow_end {f : Function.End α} {K} (h : LipschitzWith K f) :
    ∀ n : ℕ, LipschitzWith (K ^ n) (f ^ n : Function.End α)
  | 0 => by simpa only [pow_zero] using LipschitzWith.id
  | n + 1 => by rw [pow_succ, pow_succ]; exact h.mul (pow n)
#align lipschitz_with.pow LipschitzWith.pow_end
-/

end Emetric

section Metric

variable [PseudoMetricSpace α] [PseudoMetricSpace β] [PseudoMetricSpace γ] {K : ℝ≥0} {f : α → β}
  {x y : α} {r : ℝ}

#print LipschitzWith.of_dist_le' /-
protected theorem of_dist_le' {K : ℝ} (h : ∀ x y, dist (f x) (f y) ≤ K * dist x y) :
    LipschitzWith (Real.toNNReal K) f :=
  of_dist_le_mul fun x y =>
    le_trans (h x y) <| mul_le_mul_of_nonneg_right (Real.le_coe_toNNReal K) dist_nonneg
#align lipschitz_with.of_dist_le' LipschitzWith.of_dist_le'
-/

#print LipschitzWith.mk_one /-
protected theorem mk_one (h : ∀ x y, dist (f x) (f y) ≤ dist x y) : LipschitzWith 1 f :=
  of_dist_le_mul <| by simpa only [NNReal.coe_one, one_mul] using h
#align lipschitz_with.mk_one LipschitzWith.mk_one
-/

#print LipschitzWith.of_le_add_mul' /-
/-- For functions to `ℝ`, it suffices to prove `f x ≤ f y + K * dist x y`; this version
doesn't assume `0≤K`. -/
protected theorem of_le_add_mul' {f : α → ℝ} (K : ℝ) (h : ∀ x y, f x ≤ f y + K * dist x y) :
    LipschitzWith (Real.toNNReal K) f :=
  have I : ∀ x y, f x - f y ≤ K * dist x y := fun x y => sub_le_iff_le_add'.2 (h x y)
  LipschitzWith.of_dist_le' fun x y => abs_sub_le_iff.2 ⟨I x y, dist_comm y x ▸ I y x⟩
#align lipschitz_with.of_le_add_mul' LipschitzWith.of_le_add_mul'
-/

#print LipschitzWith.of_le_add_mul /-
/-- For functions to `ℝ`, it suffices to prove `f x ≤ f y + K * dist x y`; this version
assumes `0≤K`. -/
protected theorem of_le_add_mul {f : α → ℝ} (K : ℝ≥0) (h : ∀ x y, f x ≤ f y + K * dist x y) :
    LipschitzWith K f := by simpa only [Real.toNNReal_coe] using LipschitzWith.of_le_add_mul' K h
#align lipschitz_with.of_le_add_mul LipschitzWith.of_le_add_mul
-/

#print LipschitzWith.of_le_add /-
protected theorem of_le_add {f : α → ℝ} (h : ∀ x y, f x ≤ f y + dist x y) : LipschitzWith 1 f :=
  LipschitzWith.of_le_add_mul 1 <| by simpa only [NNReal.coe_one, one_mul]
#align lipschitz_with.of_le_add LipschitzWith.of_le_add
-/

#print LipschitzWith.le_add_mul /-
protected theorem le_add_mul {f : α → ℝ} {K : ℝ≥0} (h : LipschitzWith K f) (x y) :
    f x ≤ f y + K * dist x y :=
  sub_le_iff_le_add'.1 <| le_trans (le_abs_self _) <| h.dist_le_mul x y
#align lipschitz_with.le_add_mul LipschitzWith.le_add_mul
-/

#print LipschitzWith.iff_le_add_mul /-
protected theorem iff_le_add_mul {f : α → ℝ} {K : ℝ≥0} :
    LipschitzWith K f ↔ ∀ x y, f x ≤ f y + K * dist x y :=
  ⟨LipschitzWith.le_add_mul, LipschitzWith.of_le_add_mul K⟩
#align lipschitz_with.iff_le_add_mul LipschitzWith.iff_le_add_mul
-/

#print LipschitzWith.nndist_le /-
theorem nndist_le (hf : LipschitzWith K f) (x y : α) : nndist (f x) (f y) ≤ K * nndist x y :=
  hf.dist_le_mul x y
#align lipschitz_with.nndist_le LipschitzWith.nndist_le
-/

#print LipschitzWith.dist_le_mul_of_le /-
theorem dist_le_mul_of_le (hf : LipschitzWith K f) (hr : dist x y ≤ r) : dist (f x) (f y) ≤ K * r :=
  (hf.dist_le_mul x y).trans <| mul_le_mul_of_nonneg_left hr K.coe_nonneg
#align lipschitz_with.dist_le_mul_of_le LipschitzWith.dist_le_mul_of_le
-/

#print LipschitzWith.mapsTo_closedBall /-
theorem mapsTo_closedBall (hf : LipschitzWith K f) (x : α) (r : ℝ) :
    MapsTo f (Metric.closedBall x r) (Metric.closedBall (f x) (K * r)) := fun y hy =>
  hf.dist_le_mul_of_le hy
#align lipschitz_with.maps_to_closed_ball LipschitzWith.mapsTo_closedBall
-/

#print LipschitzWith.dist_lt_mul_of_lt /-
theorem dist_lt_mul_of_lt (hf : LipschitzWith K f) (hK : K ≠ 0) (hr : dist x y < r) :
    dist (f x) (f y) < K * r :=
  (hf.dist_le_mul x y).trans_lt <| (mul_lt_mul_left <| NNReal.coe_pos.2 hK.bot_lt).2 hr
#align lipschitz_with.dist_lt_mul_of_lt LipschitzWith.dist_lt_mul_of_lt
-/

#print LipschitzWith.mapsTo_ball /-
theorem mapsTo_ball (hf : LipschitzWith K f) (hK : K ≠ 0) (x : α) (r : ℝ) :
    MapsTo f (Metric.ball x r) (Metric.ball (f x) (K * r)) := fun y hy => hf.dist_lt_mul_of_lt hK hy
#align lipschitz_with.maps_to_ball LipschitzWith.mapsTo_ball
-/

#print LipschitzWith.toLocallyBoundedMap /-
/-- A Lipschitz continuous map is a locally bounded map. -/
def toLocallyBoundedMap (f : α → β) (hf : LipschitzWith K f) : LocallyBoundedMap α β :=
  LocallyBoundedMap.ofMapBounded f fun s hs =>
    let ⟨C, hC⟩ := Metric.isBounded_iff.1 hs
    Metric.isBounded_iff.2
      ⟨K * C,
        ball_image_iff.2 fun x hx => ball_image_iff.2 fun y hy => hf.dist_le_mul_of_le (hC hx hy)⟩
#align lipschitz_with.to_locally_bounded_map LipschitzWith.toLocallyBoundedMap
-/

#print LipschitzWith.coe_toLocallyBoundedMap /-
@[simp]
theorem coe_toLocallyBoundedMap (hf : LipschitzWith K f) : ⇑(hf.toLocallyBoundedMap f) = f :=
  rfl
#align lipschitz_with.coe_to_locally_bounded_map LipschitzWith.coe_toLocallyBoundedMap
-/

#print LipschitzWith.comap_cobounded_le /-
theorem comap_cobounded_le (hf : LipschitzWith K f) :
    comap f (Bornology.cobounded β) ≤ Bornology.cobounded α :=
  (hf.toLocallyBoundedMap f).2
#align lipschitz_with.comap_cobounded_le LipschitzWith.comap_cobounded_le
-/

#print LipschitzWith.isBounded_image /-
theorem isBounded_image (hf : LipschitzWith K f) {s : Set α} (hs : Bornology.IsBounded s) :
    Bornology.IsBounded (f '' s) :=
  Metric.isBounded_iff_ediam_ne_top.2 <|
    ne_top_of_le_ne_top (ENNReal.mul_ne_top ENNReal.coe_ne_top hs.ediam_ne_top)
      (hf.ediam_image_le s)
#align lipschitz_with.bounded_image LipschitzWith.isBounded_image
-/

#print LipschitzWith.diam_image_le /-
theorem diam_image_le (hf : LipschitzWith K f) (s : Set α) (hs : Bornology.IsBounded s) :
    Metric.diam (f '' s) ≤ K * Metric.diam s :=
  Metric.diam_le_of_forall_dist_le (mul_nonneg K.coe_nonneg Metric.diam_nonneg) <|
    ball_image_iff.2 fun x hx =>
      ball_image_iff.2 fun y hy => hf.dist_le_mul_of_le <| Metric.dist_le_diam_of_mem hs hx hy
#align lipschitz_with.diam_image_le LipschitzWith.diam_image_le
-/

#print LipschitzWith.dist_left /-
protected theorem dist_left (y : α) : LipschitzWith 1 fun x => dist x y :=
  LipschitzWith.of_le_add fun x z => by rw [add_comm]; apply dist_triangle
#align lipschitz_with.dist_left LipschitzWith.dist_left
-/

#print LipschitzWith.dist_right /-
protected theorem dist_right (x : α) : LipschitzWith 1 (dist x) :=
  LipschitzWith.of_le_add fun y z => dist_triangle_right _ _ _
#align lipschitz_with.dist_right LipschitzWith.dist_right
-/

#print LipschitzWith.dist /-
protected theorem dist : LipschitzWith 2 (Function.uncurry <| @dist α _) :=
  LipschitzWith.uncurry LipschitzWith.dist_left LipschitzWith.dist_right
#align lipschitz_with.dist LipschitzWith.dist
-/

#print LipschitzWith.dist_iterate_succ_le_geometric /-
theorem dist_iterate_succ_le_geometric {f : α → α} (hf : LipschitzWith K f) (x n) :
    dist ((f^[n]) x) ((f^[n + 1]) x) ≤ dist x (f x) * K ^ n :=
  by
  rw [iterate_succ, mul_comm]
  simpa only [NNReal.coe_pow] using (hf.iterate n).dist_le_mul x (f x)
#align lipschitz_with.dist_iterate_succ_le_geometric LipschitzWith.dist_iterate_succ_le_geometric
-/

#print lipschitzWith_max /-
theorem lipschitzWith_max : LipschitzWith 1 fun p : ℝ × ℝ => max p.1 p.2 :=
  LipschitzWith.of_le_add fun p₁ p₂ =>
    sub_le_iff_le_add'.1 <| (le_abs_self _).trans (abs_max_sub_max_le_max _ _ _ _)
#align lipschitz_with_max lipschitzWith_max
-/

#print lipschitzWith_min /-
theorem lipschitzWith_min : LipschitzWith 1 fun p : ℝ × ℝ => min p.1 p.2 :=
  LipschitzWith.of_le_add fun p₁ p₂ =>
    sub_le_iff_le_add'.1 <| (le_abs_self _).trans (abs_min_sub_min_le_max _ _ _ _)
#align lipschitz_with_min lipschitzWith_min
-/

end Metric

section Emetric

variable {α} [PseudoEMetricSpace α] {f g : α → ℝ} {Kf Kg : ℝ≥0}

#print LipschitzWith.max /-
protected theorem max (hf : LipschitzWith Kf f) (hg : LipschitzWith Kg g) :
    LipschitzWith (max Kf Kg) fun x => max (f x) (g x) := by
  simpa only [(· ∘ ·), one_mul] using lipschitz_with_max.comp (hf.prod hg)
#align lipschitz_with.max LipschitzWith.max
-/

#print LipschitzWith.min /-
protected theorem min (hf : LipschitzWith Kf f) (hg : LipschitzWith Kg g) :
    LipschitzWith (max Kf Kg) fun x => min (f x) (g x) := by
  simpa only [(· ∘ ·), one_mul] using lipschitz_with_min.comp (hf.prod hg)
#align lipschitz_with.min LipschitzWith.min
-/

#print LipschitzWith.max_const /-
theorem max_const (hf : LipschitzWith Kf f) (a : ℝ) : LipschitzWith Kf fun x => max (f x) a := by
  simpa only [max_eq_left (zero_le Kf)] using hf.max (LipschitzWith.const a)
#align lipschitz_with.max_const LipschitzWith.max_const
-/

#print LipschitzWith.const_max /-
theorem const_max (hf : LipschitzWith Kf f) (a : ℝ) : LipschitzWith Kf fun x => max a (f x) := by
  simpa only [max_comm] using hf.max_const a
#align lipschitz_with.const_max LipschitzWith.const_max
-/

#print LipschitzWith.min_const /-
theorem min_const (hf : LipschitzWith Kf f) (a : ℝ) : LipschitzWith Kf fun x => min (f x) a := by
  simpa only [max_eq_left (zero_le Kf)] using hf.min (LipschitzWith.const a)
#align lipschitz_with.min_const LipschitzWith.min_const
-/

#print LipschitzWith.const_min /-
theorem const_min (hf : LipschitzWith Kf f) (a : ℝ) : LipschitzWith Kf fun x => min a (f x) := by
  simpa only [min_comm] using hf.min_const a
#align lipschitz_with.const_min LipschitzWith.const_min
-/

end Emetric

#print LipschitzWith.projIcc /-
protected theorem projIcc {a b : ℝ} (h : a ≤ b) : LipschitzWith 1 (projIcc a b h) :=
  ((LipschitzWith.id.const_min _).const_max _).subtype_mk _
#align lipschitz_with.proj_Icc LipschitzWith.projIcc
-/

end LipschitzWith

namespace Metric

variable [PseudoMetricSpace α] [PseudoMetricSpace β] {s : Set α} {t : Set β}

/- warning: metric.bounded.left_of_prod clashes with bornology.is_bounded.fst_of_prod -> Bornology.IsBounded.fst_of_prod
Case conversion may be inaccurate. Consider using '#align metric.bounded.left_of_prod Bornology.IsBounded.fst_of_prodₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Bornology.IsBounded.fst_of_prod /-
theorem IsBounded.fst_of_prod (h : IsBounded (s ×ˢ t)) (ht : t.Nonempty) : IsBounded s := by
  simpa only [fst_image_prod s ht] using (@LipschitzWith.prod_fst α β _ _).isBounded_image h
#align metric.bounded.left_of_prod Bornology.IsBounded.fst_of_prod
-/

/- warning: metric.bounded.right_of_prod clashes with bornology.is_bounded.snd_of_prod -> Bornology.IsBounded.snd_of_prod
Case conversion may be inaccurate. Consider using '#align metric.bounded.right_of_prod Bornology.IsBounded.snd_of_prodₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Bornology.IsBounded.snd_of_prod /-
theorem IsBounded.snd_of_prod (h : IsBounded (s ×ˢ t)) (hs : s.Nonempty) : IsBounded t := by
  simpa only [snd_image_prod hs t] using (@LipschitzWith.prod_snd α β _ _).isBounded_image h
#align metric.bounded.right_of_prod Bornology.IsBounded.snd_of_prod
-/

/- warning: metric.bounded_prod_of_nonempty clashes with bornology.is_bounded_prod_of_nonempty -> Bornology.isBounded_prod_of_nonempty
Case conversion may be inaccurate. Consider using '#align metric.bounded_prod_of_nonempty Bornology.isBounded_prod_of_nonemptyₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Bornology.isBounded_prod_of_nonempty /-
theorem isBounded_prod_of_nonempty (hs : s.Nonempty) (ht : t.Nonempty) :
    IsBounded (s ×ˢ t) ↔ IsBounded s ∧ IsBounded t :=
  ⟨fun h => ⟨h.fst_of_prod ht, h.snd_of_prod hs⟩, fun h => h.1.Prod h.2⟩
#align metric.bounded_prod_of_nonempty Bornology.isBounded_prod_of_nonempty
-/

/- warning: metric.bounded_prod clashes with bornology.is_bounded_prod -> Bornology.isBounded_prod
Case conversion may be inaccurate. Consider using '#align metric.bounded_prod Bornology.isBounded_prodₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Bornology.isBounded_prod /-
theorem isBounded_prod : IsBounded (s ×ˢ t) ↔ s = ∅ ∨ t = ∅ ∨ IsBounded s ∧ IsBounded t :=
  by
  rcases s.eq_empty_or_nonempty with (rfl | hs); · simp
  rcases t.eq_empty_or_nonempty with (rfl | ht); · simp
  simp only [bounded_prod_of_nonempty hs ht, hs.ne_empty, ht.ne_empty, false_or_iff]
#align metric.bounded_prod Bornology.isBounded_prod
-/

end Metric

namespace LipschitzOnWith

section Emetric

variable [PseudoEMetricSpace α] [PseudoEMetricSpace β] [PseudoEMetricSpace γ]

variable {K : ℝ≥0} {s : Set α} {f : α → β}

#print LipschitzOnWith.uniformContinuousOn /-
protected theorem uniformContinuousOn (hf : LipschitzOnWith K f s) : UniformContinuousOn f s :=
  uniformContinuousOn_iff_restrict.mpr (lipschitzOnWith_iff_restrict.mp hf).UniformContinuous
#align lipschitz_on_with.uniform_continuous_on LipschitzOnWith.uniformContinuousOn
-/

#print LipschitzOnWith.continuousOn /-
protected theorem continuousOn (hf : LipschitzOnWith K f s) : ContinuousOn f s :=
  hf.UniformContinuousOn.ContinuousOn
#align lipschitz_on_with.continuous_on LipschitzOnWith.continuousOn
-/

#print LipschitzOnWith.edist_lt_of_edist_lt_div /-
theorem edist_lt_of_edist_lt_div (hf : LipschitzOnWith K f s) {x y : α} (hx : x ∈ s) (hy : y ∈ s)
    {d : ℝ≥0∞} (hd : edist x y < d / K) : edist (f x) (f y) < d :=
  (lipschitzOnWith_iff_restrict.mp hf).edist_lt_of_edist_lt_div <|
    show edist (⟨x, hx⟩ : s) ⟨y, hy⟩ < d / K from hd
#align lipschitz_on_with.edist_lt_of_edist_lt_div LipschitzOnWith.edist_lt_of_edist_lt_div
-/

#print LipschitzOnWith.comp /-
protected theorem comp {g : β → γ} {t : Set β} {Kg : ℝ≥0} (hg : LipschitzOnWith Kg g t)
    (hf : LipschitzOnWith K f s) (hmaps : MapsTo f s t) : LipschitzOnWith (Kg * K) (g ∘ f) s :=
  lipschitzOnWith_iff_restrict.mpr <| hg.to_restrict.comp (hf.to_restrict_mapsTo hmaps)
#align lipschitz_on_with.comp LipschitzOnWith.comp
-/

#print LipschitzOnWith.ediam_image2_le /-
theorem ediam_image2_le (f : α → β → γ) {K₁ K₂ : ℝ≥0} (s : Set α) (t : Set β)
    (hf₁ : ∀ b ∈ t, LipschitzOnWith K₁ (fun a => f a b) s)
    (hf₂ : ∀ a ∈ s, LipschitzOnWith K₂ (f a) t) :
    EMetric.diam (Set.image2 f s t) ≤ ↑K₁ * EMetric.diam s + ↑K₂ * EMetric.diam t :=
  by
  apply EMetric.diam_le
  rintro _ ⟨a₁, b₁, ha₁, hb₁, rfl⟩ _ ⟨a₂, b₂, ha₂, hb₂, rfl⟩
  refine' (edist_triangle _ (f a₂ b₁) _).trans _
  exact
    add_le_add
      ((hf₁ b₁ hb₁ ha₁ ha₂).trans <| ENNReal.mul_left_mono <| EMetric.edist_le_diam_of_mem ha₁ ha₂)
      ((hf₂ a₂ ha₂ hb₁ hb₂).trans <| ENNReal.mul_left_mono <| EMetric.edist_le_diam_of_mem hb₁ hb₂)
#align lipschitz_on_with.ediam_image2_le LipschitzOnWith.ediam_image2_le
-/

end Emetric

section Metric

variable [PseudoMetricSpace α] [PseudoMetricSpace β] [PseudoMetricSpace γ]

variable {K : ℝ≥0} {s : Set α} {f : α → β}

#print LipschitzOnWith.of_dist_le' /-
protected theorem of_dist_le' {K : ℝ} (h : ∀ x ∈ s, ∀ y ∈ s, dist (f x) (f y) ≤ K * dist x y) :
    LipschitzOnWith (Real.toNNReal K) f s :=
  of_dist_le_mul fun x hx y hy =>
    le_trans (h x hx y hy) <| mul_le_mul_of_nonneg_right (Real.le_coe_toNNReal K) dist_nonneg
#align lipschitz_on_with.of_dist_le' LipschitzOnWith.of_dist_le'
-/

#print LipschitzOnWith.mk_one /-
protected theorem mk_one (h : ∀ x ∈ s, ∀ y ∈ s, dist (f x) (f y) ≤ dist x y) :
    LipschitzOnWith 1 f s :=
  of_dist_le_mul <| by simpa only [NNReal.coe_one, one_mul] using h
#align lipschitz_on_with.mk_one LipschitzOnWith.mk_one
-/

#print LipschitzOnWith.of_le_add_mul' /-
/-- For functions to `ℝ`, it suffices to prove `f x ≤ f y + K * dist x y`; this version
doesn't assume `0≤K`. -/
protected theorem of_le_add_mul' {f : α → ℝ} (K : ℝ)
    (h : ∀ x ∈ s, ∀ y ∈ s, f x ≤ f y + K * dist x y) : LipschitzOnWith (Real.toNNReal K) f s :=
  have I : ∀ x ∈ s, ∀ y ∈ s, f x - f y ≤ K * dist x y := fun x hx y hy =>
    sub_le_iff_le_add'.2 (h x hx y hy)
  LipschitzOnWith.of_dist_le' fun x hx y hy =>
    abs_sub_le_iff.2 ⟨I x hx y hy, dist_comm y x ▸ I y hy x hx⟩
#align lipschitz_on_with.of_le_add_mul' LipschitzOnWith.of_le_add_mul'
-/

#print LipschitzOnWith.of_le_add_mul /-
/-- For functions to `ℝ`, it suffices to prove `f x ≤ f y + K * dist x y`; this version
assumes `0≤K`. -/
protected theorem of_le_add_mul {f : α → ℝ} (K : ℝ≥0)
    (h : ∀ x ∈ s, ∀ y ∈ s, f x ≤ f y + K * dist x y) : LipschitzOnWith K f s := by
  simpa only [Real.toNNReal_coe] using LipschitzOnWith.of_le_add_mul' K h
#align lipschitz_on_with.of_le_add_mul LipschitzOnWith.of_le_add_mul
-/

#print LipschitzOnWith.of_le_add /-
protected theorem of_le_add {f : α → ℝ} (h : ∀ x ∈ s, ∀ y ∈ s, f x ≤ f y + dist x y) :
    LipschitzOnWith 1 f s :=
  LipschitzOnWith.of_le_add_mul 1 <| by simpa only [NNReal.coe_one, one_mul]
#align lipschitz_on_with.of_le_add LipschitzOnWith.of_le_add
-/

#print LipschitzOnWith.le_add_mul /-
protected theorem le_add_mul {f : α → ℝ} {K : ℝ≥0} (h : LipschitzOnWith K f s) {x : α} (hx : x ∈ s)
    {y : α} (hy : y ∈ s) : f x ≤ f y + K * dist x y :=
  sub_le_iff_le_add'.1 <| le_trans (le_abs_self _) <| h.dist_le_mul x hx y hy
#align lipschitz_on_with.le_add_mul LipschitzOnWith.le_add_mul
-/

#print LipschitzOnWith.iff_le_add_mul /-
protected theorem iff_le_add_mul {f : α → ℝ} {K : ℝ≥0} :
    LipschitzOnWith K f s ↔ ∀ x ∈ s, ∀ y ∈ s, f x ≤ f y + K * dist x y :=
  ⟨LipschitzOnWith.le_add_mul, LipschitzOnWith.of_le_add_mul K⟩
#align lipschitz_on_with.iff_le_add_mul LipschitzOnWith.iff_le_add_mul
-/

#print LipschitzOnWith.isBounded_image2 /-
theorem isBounded_image2 (f : α → β → γ) {K₁ K₂ : ℝ≥0} {s : Set α} {t : Set β}
    (hs : Bornology.IsBounded s) (ht : Bornology.IsBounded t)
    (hf₁ : ∀ b ∈ t, LipschitzOnWith K₁ (fun a => f a b) s)
    (hf₂ : ∀ a ∈ s, LipschitzOnWith K₂ (f a) t) : Bornology.IsBounded (Set.image2 f s t) :=
  Metric.isBounded_iff_ediam_ne_top.2 <|
    ne_top_of_le_ne_top
      (ENNReal.add_ne_top.mpr
        ⟨ENNReal.mul_ne_top ENNReal.coe_ne_top hs.ediam_ne_top,
          ENNReal.mul_ne_top ENNReal.coe_ne_top ht.ediam_ne_top⟩)
      (ediam_image2_le _ _ _ hf₁ hf₂)
#align lipschitz_on_with.bounded_image2 LipschitzOnWith.isBounded_image2
-/

end Metric

end LipschitzOnWith

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print continuousOn_prod_of_continuousOn_lipschitzOnWith /-
/-- Consider a function `f : α × β → γ`. Suppose that it is continuous on each “vertical fiber”
`{a} × t`, `a ∈ s`, and is Lipschitz continuous on each “horizontal fiber” `s × {b}`, `b ∈ t`
with the same Lipschitz constant `K`. Then it is continuous on `s × t`.

The actual statement uses (Lipschitz) continuity of `λ y, f (a, y)` and `λ x, f (x, b)` instead
of continuity of `f` on subsets of the product space. -/
theorem continuousOn_prod_of_continuousOn_lipschitzOnWith [PseudoEMetricSpace α]
    [TopologicalSpace β] [PseudoEMetricSpace γ] (f : α × β → γ) {s : Set α} {t : Set β} (K : ℝ≥0)
    (ha : ∀ a ∈ s, ContinuousOn (fun y => f (a, y)) t)
    (hb : ∀ b ∈ t, LipschitzOnWith K (fun x => f (x, b)) s) : ContinuousOn f (s ×ˢ t) :=
  by
  rintro ⟨x, y⟩ ⟨hx : x ∈ s, hy : y ∈ t⟩
  refine' EMetric.tendsto_nhds.2 fun ε (ε0 : 0 < ε) => _
  replace ε0 : 0 < ε / 2 := ENNReal.half_pos (ne_of_gt ε0)
  have εK : 0 < ε / 2 / K := ENNReal.div_pos_iff.2 ⟨ε0.ne', ENNReal.coe_ne_top⟩
  have A : s ∩ EMetric.ball x (ε / 2 / K) ∈ 𝓝[s] x :=
    inter_mem_nhdsWithin _ (EMetric.ball_mem_nhds _ εK)
  have B : {b : β | b ∈ t ∧ edist (f (x, b)) (f (x, y)) < ε / 2} ∈ 𝓝[t] y :=
    inter_mem self_mem_nhdsWithin (ha x hx y hy (EMetric.ball_mem_nhds _ ε0))
  filter_upwards [nhdsWithin_prod A B]
  rintro ⟨a, b⟩
    ⟨⟨has : a ∈ s, hax : edist a x < ε / 2 / K⟩, hbt : b ∈ t, hby :
        edist (f (x, b)) (f (x, y)) < ε / 2⟩
  calc
    edist (f (a, b)) (f (x, y)) ≤ edist (f (a, b)) (f (x, b)) + edist (f (x, b)) (f (x, y)) :=
      edist_triangle _ _ _
    _ < ε / 2 + ε / 2 := (ENNReal.add_lt_add ((hb _ hbt).edist_lt_of_edist_lt_div has hx hax) hby)
    _ = ε := ENNReal.add_halves ε
#align continuous_on_prod_of_continuous_on_lipschitz_on continuousOn_prod_of_continuousOn_lipschitzOnWith
-/

#print continuous_prod_of_continuous_lipschitzWith /-
/-- Consider a function `f : α × β → γ`. Suppose that it is continuous on each “vertical section”
`{a} × univ`, `a : α`, and is Lipschitz continuous on each “horizontal section”
`univ × {b}`, `b : β` with the same Lipschitz constant `K`. Then it is continuous.

The actual statement uses (Lipschitz) continuity of `λ y, f (a, y)` and `λ x, f (x, b)` instead
of continuity of `f` on subsets of the product space. -/
theorem continuous_prod_of_continuous_lipschitzWith [PseudoEMetricSpace α] [TopologicalSpace β]
    [PseudoEMetricSpace γ] (f : α × β → γ) (K : ℝ≥0) (ha : ∀ a, Continuous fun y => f (a, y))
    (hb : ∀ b, LipschitzWith K fun x => f (x, b)) : Continuous f :=
  by
  simp only [continuous_iff_continuousOn_univ, ← univ_prod_univ, ← lipschitzOn_univ] at *
  exact continuousOn_prod_of_continuousOn_lipschitzOnWith f K (fun a _ => ha a) fun b _ => hb b
#align continuous_prod_of_continuous_lipschitz continuous_prod_of_continuous_lipschitzWith
-/

open Metric

#print continuousAt_of_locally_lipschitz /-
/-- If a function is locally Lipschitz around a point, then it is continuous at this point. -/
theorem continuousAt_of_locally_lipschitz [PseudoMetricSpace α] [PseudoMetricSpace β] {f : α → β}
    {x : α} {r : ℝ} (hr : 0 < r) (K : ℝ) (h : ∀ y, dist y x < r → dist (f y) (f x) ≤ K * dist y x) :
    ContinuousAt f x :=
  by
  -- We use `h` to squeeze `dist (f y) (f x)` between `0` and `K * dist y x`
  refine'
    tendsto_iff_dist_tendsto_zero.2
      (squeeze_zero' (eventually_of_forall fun _ => dist_nonneg)
        (mem_of_superset (ball_mem_nhds _ hr) h) _)
  -- Then show that `K * dist y x` tends to zero as `y → x`
  refine' (continuous_const.mul (continuous_id.dist continuous_const)).tendsto' _ _ _
  simp
#align continuous_at_of_locally_lipschitz continuousAt_of_locally_lipschitz
-/

#print LipschitzOnWith.extend_real /-
/-- A function `f : α → ℝ` which is `K`-Lipschitz on a subset `s` admits a `K`-Lipschitz extension
to the whole space. -/
theorem LipschitzOnWith.extend_real [PseudoMetricSpace α] {f : α → ℝ} {s : Set α} {K : ℝ≥0}
    (hf : LipschitzOnWith K f s) : ∃ g : α → ℝ, LipschitzWith K g ∧ EqOn f g s :=
  by
  /- An extension is given by `g y = Inf {f x + K * dist y x | x ∈ s}`. Taking `x = y`, one has
    `g y ≤ f y` for `y ∈ s`, and the other inequality holds because `f` is `K`-Lipschitz, so that it
    can not counterbalance the growth of `K * dist y x`. One readily checks from the formula that the
    extended function is also `K`-Lipschitz. -/
  rcases eq_empty_or_nonempty s with (rfl | hs)
  · exact ⟨fun x => 0, (LipschitzWith.const _).weaken (zero_le _), eq_on_empty _ _⟩
  have : Nonempty s := by simp only [hs, nonempty_coe_sort]
  let g := fun y : α => iInf fun x : s => f x + K * dist y x
  have B : ∀ y : α, BddBelow (range fun x : s => f x + K * dist y x) :=
    by
    intro y
    rcases hs with ⟨z, hz⟩
    refine' ⟨f z - K * dist y z, _⟩
    rintro w ⟨t, rfl⟩
    dsimp
    rw [sub_le_iff_le_add, add_assoc, ← mul_add, add_comm (dist y t)]
    calc
      f z ≤ f t + K * dist z t := hf.le_add_mul hz t.2
      _ ≤ f t + K * (dist y z + dist y t) :=
        add_le_add_left (mul_le_mul_of_nonneg_left (dist_triangle_left _ _ _) K.2) _
  have E : eq_on f g s := by
    intro x hx
    refine' le_antisymm (le_ciInf fun y => hf.le_add_mul hx y.2) _
    simpa only [add_zero, Subtype.coe_mk, MulZeroClass.mul_zero, dist_self] using
      ciInf_le (B x) ⟨x, hx⟩
  refine' ⟨g, LipschitzWith.of_le_add_mul K fun x y => _, E⟩
  rw [← sub_le_iff_le_add]
  refine' le_ciInf fun z => _
  rw [sub_le_iff_le_add]
  calc
    g x ≤ f z + K * dist x z := ciInf_le (B x) _
    _ ≤ f z + K * dist y z + K * dist x y :=
      by
      rw [add_assoc, ← mul_add, add_comm (dist y z)]
      exact add_le_add_left (mul_le_mul_of_nonneg_left (dist_triangle _ _ _) K.2) _
#align lipschitz_on_with.extend_real LipschitzOnWith.extend_real
-/

#print LipschitzOnWith.extend_pi /-
/-- A function `f : α → (ι → ℝ)` which is `K`-Lipschitz on a subset `s` admits a `K`-Lipschitz
extension to the whole space.
TODO: state the same result (with the same proof) for the space `ℓ^∞ (ι, ℝ)` over a possibly
infinite type `ι`. -/
theorem LipschitzOnWith.extend_pi [PseudoMetricSpace α] [Fintype ι] {f : α → ι → ℝ} {s : Set α}
    {K : ℝ≥0} (hf : LipschitzOnWith K f s) : ∃ g : α → ι → ℝ, LipschitzWith K g ∧ EqOn f g s :=
  by
  have : ∀ i, ∃ g : α → ℝ, LipschitzWith K g ∧ eq_on (fun x => f x i) g s :=
    by
    intro i
    have : LipschitzOnWith K (fun x : α => f x i) s :=
      by
      apply LipschitzOnWith.of_dist_le_mul fun x hx y hy => _
      exact (dist_le_pi_dist _ _ i).trans (hf.dist_le_mul x hx y hy)
    exact this.extend_real
  choose g hg using this
  refine' ⟨fun x i => g i x, LipschitzWith.of_dist_le_mul fun x y => _, _⟩
  · exact (dist_pi_le_iff (mul_nonneg K.2 dist_nonneg)).2 fun i => (hg i).1.dist_le_mul x y
  · intro x hx
    ext1 i
    exact (hg i).2 hx
#align lipschitz_on_with.extend_pi LipschitzOnWith.extend_pi
-/

