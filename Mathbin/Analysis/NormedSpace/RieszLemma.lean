/-
Copyright (c) 2019 Jean Lo. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jean Lo, Yury Kudryashov

! This file was ported from Lean 3 source module analysis.normed_space.riesz_lemma
! leanprover-community/mathlib commit 9a48a083b390d9b84a71efbdc4e8dfa26a687104
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.Basic
import Mathbin.Topology.MetricSpace.HausdorffDistance

/-!
# Applications of the Hausdorff distance in normed spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Riesz's lemma, stated for a normed space over a normed field: for any
closed proper subspace `F` of `E`, there is a nonzero `x` such that `‖x - F‖`
is at least `r * ‖x‖` for any `r < 1`. This is `riesz_lemma`.

In a nontrivially normed field (with an element `c` of norm `> 1`) and any `R > ‖c‖`, one can
guarantee `‖x‖ ≤ R` and `‖x - y‖ ≥ 1` for any `y` in `F`. This is `riesz_lemma_of_norm_lt`.

A further lemma, `metric.closed_ball_inf_dist_compl_subset_closure`, finds a *closed* ball within
the closure of a set `s` of optimal distance from a point in `x` to the frontier of `s`.
-/


open Set Metric

open Topology

variable {𝕜 : Type _} [NormedField 𝕜]

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace 𝕜 E]

variable {F : Type _} [SeminormedAddCommGroup F] [NormedSpace ℝ F]

/- warning: riesz_lemma -> riesz_lemma is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align riesz_lemma riesz_lemmaₓ'. -/
/-- Riesz's lemma, which usually states that it is possible to find a
vector with norm 1 whose distance to a closed proper subspace is
arbitrarily close to 1. The statement here is in terms of multiples of
norms, since in general the existence of an element of norm exactly 1
is not guaranteed. For a variant giving an element with norm in `[1, R]`, see
`riesz_lemma_of_norm_lt`. -/
theorem riesz_lemma {F : Subspace 𝕜 E} (hFc : IsClosed (F : Set E)) (hF : ∃ x : E, x ∉ F) {r : ℝ}
    (hr : r < 1) : ∃ x₀ : E, x₀ ∉ F ∧ ∀ y ∈ F, r * ‖x₀‖ ≤ ‖x₀ - y‖ := by
  classical
    obtain ⟨x, hx⟩ : ∃ x : E, x ∉ F := hF
    let d := Metric.infDist x F
    have hFn : (F : Set E).Nonempty := ⟨_, F.zero_mem⟩
    have hdp : 0 < d :=
      lt_of_le_of_ne Metric.infDist_nonneg fun heq =>
        hx ((hFc.mem_iff_inf_dist_zero hFn).2 HEq.symm)
    let r' := max r 2⁻¹
    have hr' : r' < 1 := by simp [r', hr]; norm_num
    have hlt : 0 < r' := lt_of_lt_of_le (by norm_num) (le_max_right r 2⁻¹)
    have hdlt : d < d / r' := (lt_div_iff hlt).mpr ((mul_lt_iff_lt_one_right hdp).2 hr')
    obtain ⟨y₀, hy₀F, hxy₀⟩ : ∃ y ∈ F, dist x y < d / r' := (Metric.infDist_lt_iff hFn).mp hdlt
    have x_ne_y₀ : x - y₀ ∉ F := by
      by_contra h
      have : x - y₀ + y₀ ∈ F := F.add_mem h hy₀F
      simp only [neg_add_cancel_right, sub_eq_add_neg] at this
      exact hx this
    refine' ⟨x - y₀, x_ne_y₀, fun y hy => le_of_lt _⟩
    have hy₀y : y₀ + y ∈ F := F.add_mem hy₀F hy
    calc
      r * ‖x - y₀‖ ≤ r' * ‖x - y₀‖ := mul_le_mul_of_nonneg_right (le_max_left _ _) (norm_nonneg _)
      _ < d := by rw [← dist_eq_norm]; exact (lt_div_iff' hlt).1 hxy₀
      _ ≤ dist x (y₀ + y) := (Metric.infDist_le_dist_of_mem hy₀y)
      _ = ‖x - y₀ - y‖ := by rw [sub_sub, dist_eq_norm]
      
#align riesz_lemma riesz_lemma

/- warning: riesz_lemma_of_norm_lt -> riesz_lemma_of_norm_lt is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {c : 𝕜}, (LT.lt.{0} Real Real.hasLt (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne))) (Norm.norm.{u1} 𝕜 (NormedField.toHasNorm.{u1} 𝕜 _inst_1) c)) -> (forall {R : Real}, (LT.lt.{0} Real Real.hasLt (Norm.norm.{u1} 𝕜 (NormedField.toHasNorm.{u1} 𝕜 _inst_1) c) R) -> (forall {F : Subspace.{u1, u2} 𝕜 E (NormedDivisionRing.toDivisionRing.{u1} 𝕜 (NormedField.toNormedDivisionRing.{u1} 𝕜 _inst_1)) (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2) (NormedSpace.toModule.{u1, u2} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3)}, (IsClosed.{u2} E (UniformSpace.toTopologicalSpace.{u2} E (PseudoMetricSpace.toUniformSpace.{u2} E (SeminormedAddCommGroup.toPseudoMetricSpace.{u2} E (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)))) ((fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (Subspace.{u1, u2} 𝕜 E (NormedDivisionRing.toDivisionRing.{u1} 𝕜 (NormedField.toNormedDivisionRing.{u1} 𝕜 _inst_1)) (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2) (NormedSpace.toModule.{u1, u2} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3)) (Set.{u2} E) (HasLiftT.mk.{succ u2, succ u2} (Subspace.{u1, u2} 𝕜 E (NormedDivisionRing.toDivisionRing.{u1} 𝕜 (NormedField.toNormedDivisionRing.{u1} 𝕜 _inst_1)) (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2) (NormedSpace.toModule.{u1, u2} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3)) (Set.{u2} E) (CoeTCₓ.coe.{succ u2, succ u2} (Subspace.{u1, u2} 𝕜 E (NormedDivisionRing.toDivisionRing.{u1} 𝕜 (NormedField.toNormedDivisionRing.{u1} 𝕜 _inst_1)) (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2) (NormedSpace.toModule.{u1, u2} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3)) (Set.{u2} E) (SetLike.Set.hasCoeT.{u2, u2} (Subspace.{u1, u2} 𝕜 E (NormedDivisionRing.toDivisionRing.{u1} 𝕜 (NormedField.toNormedDivisionRing.{u1} 𝕜 _inst_1)) (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2) (NormedSpace.toModule.{u1, u2} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3)) E (Submodule.setLike.{u1, u2} 𝕜 E (Ring.toSemiring.{u1} 𝕜 (DivisionRing.toRing.{u1} 𝕜 (NormedDivisionRing.toDivisionRing.{u1} 𝕜 (NormedField.toNormedDivisionRing.{u1} 𝕜 _inst_1)))) (AddCommGroup.toAddCommMonoid.{u2} E (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2)) (NormedSpace.toModule.{u1, u2} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3))))) F)) -> (Exists.{succ u2} E (fun (x : E) => Not (Membership.Mem.{u2, u2} E (Subspace.{u1, u2} 𝕜 E (NormedDivisionRing.toDivisionRing.{u1} 𝕜 (NormedField.toNormedDivisionRing.{u1} 𝕜 _inst_1)) (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2) (NormedSpace.toModule.{u1, u2} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3)) (SetLike.hasMem.{u2, u2} (Subspace.{u1, u2} 𝕜 E (NormedDivisionRing.toDivisionRing.{u1} 𝕜 (NormedField.toNormedDivisionRing.{u1} 𝕜 _inst_1)) (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2) (NormedSpace.toModule.{u1, u2} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3)) E (Submodule.setLike.{u1, u2} 𝕜 E (Ring.toSemiring.{u1} 𝕜 (DivisionRing.toRing.{u1} 𝕜 (NormedDivisionRing.toDivisionRing.{u1} 𝕜 (NormedField.toNormedDivisionRing.{u1} 𝕜 _inst_1)))) (AddCommGroup.toAddCommMonoid.{u2} E (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2)) (NormedSpace.toModule.{u1, u2} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3))) x F))) -> (Exists.{succ u2} E (fun (x₀ : E) => And (LE.le.{0} Real Real.hasLe (Norm.norm.{u2} E (NormedAddCommGroup.toHasNorm.{u2} E _inst_2) x₀) R) (forall (y : E), (Membership.Mem.{u2, u2} E (Subspace.{u1, u2} 𝕜 E (NormedDivisionRing.toDivisionRing.{u1} 𝕜 (NormedField.toNormedDivisionRing.{u1} 𝕜 _inst_1)) (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2) (NormedSpace.toModule.{u1, u2} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3)) (SetLike.hasMem.{u2, u2} (Subspace.{u1, u2} 𝕜 E (NormedDivisionRing.toDivisionRing.{u1} 𝕜 (NormedField.toNormedDivisionRing.{u1} 𝕜 _inst_1)) (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2) (NormedSpace.toModule.{u1, u2} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3)) E (Submodule.setLike.{u1, u2} 𝕜 E (Ring.toSemiring.{u1} 𝕜 (DivisionRing.toRing.{u1} 𝕜 (NormedDivisionRing.toDivisionRing.{u1} 𝕜 (NormedField.toNormedDivisionRing.{u1} 𝕜 _inst_1)))) (AddCommGroup.toAddCommMonoid.{u2} E (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2)) (NormedSpace.toModule.{u1, u2} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3))) y F) -> (LE.le.{0} Real Real.hasLe (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne))) (Norm.norm.{u2} E (NormedAddCommGroup.toHasNorm.{u2} E _inst_2) (HSub.hSub.{u2, u2, u2} E E E (instHSub.{u2} E (SubNegMonoid.toHasSub.{u2} E (AddGroup.toSubNegMonoid.{u2} E (NormedAddGroup.toAddGroup.{u2} E (NormedAddCommGroup.toNormedAddGroup.{u2} E _inst_2))))) x₀ y))))))))
but is expected to have type
  forall {𝕜 : Type.{u2}} [_inst_1 : NormedField.{u2} 𝕜] {E : Type.{u1}} [_inst_2 : NormedAddCommGroup.{u1} E] [_inst_3 : NormedSpace.{u2, u1} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2)] {c : 𝕜}, (LT.lt.{0} Real Real.instLTReal (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal)) (Norm.norm.{u2} 𝕜 (NormedField.toNorm.{u2} 𝕜 _inst_1) c)) -> (forall {R : Real}, (LT.lt.{0} Real Real.instLTReal (Norm.norm.{u2} 𝕜 (NormedField.toNorm.{u2} 𝕜 _inst_1) c) R) -> (forall {F : Subspace.{u2, u1} 𝕜 E (NormedDivisionRing.toDivisionRing.{u2} 𝕜 (NormedField.toNormedDivisionRing.{u2} 𝕜 _inst_1)) (NormedAddCommGroup.toAddCommGroup.{u1} E _inst_2) (NormedSpace.toModule.{u2, u1} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2) _inst_3)}, (IsClosed.{u1} E (UniformSpace.toTopologicalSpace.{u1} E (PseudoMetricSpace.toUniformSpace.{u1} E (SeminormedAddCommGroup.toPseudoMetricSpace.{u1} E (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2)))) (SetLike.coe.{u1, u1} (Subspace.{u2, u1} 𝕜 E (NormedDivisionRing.toDivisionRing.{u2} 𝕜 (NormedField.toNormedDivisionRing.{u2} 𝕜 _inst_1)) (NormedAddCommGroup.toAddCommGroup.{u1} E _inst_2) (NormedSpace.toModule.{u2, u1} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2) _inst_3)) E (Submodule.setLike.{u2, u1} 𝕜 E (DivisionSemiring.toSemiring.{u2} 𝕜 (DivisionRing.toDivisionSemiring.{u2} 𝕜 (NormedDivisionRing.toDivisionRing.{u2} 𝕜 (NormedField.toNormedDivisionRing.{u2} 𝕜 _inst_1)))) (AddCommGroup.toAddCommMonoid.{u1} E (NormedAddCommGroup.toAddCommGroup.{u1} E _inst_2)) (NormedSpace.toModule.{u2, u1} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2) _inst_3)) F)) -> (Exists.{succ u1} E (fun (x : E) => Not (Membership.mem.{u1, u1} E (Subspace.{u2, u1} 𝕜 E (NormedDivisionRing.toDivisionRing.{u2} 𝕜 (NormedField.toNormedDivisionRing.{u2} 𝕜 _inst_1)) (NormedAddCommGroup.toAddCommGroup.{u1} E _inst_2) (NormedSpace.toModule.{u2, u1} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2) _inst_3)) (SetLike.instMembership.{u1, u1} (Subspace.{u2, u1} 𝕜 E (NormedDivisionRing.toDivisionRing.{u2} 𝕜 (NormedField.toNormedDivisionRing.{u2} 𝕜 _inst_1)) (NormedAddCommGroup.toAddCommGroup.{u1} E _inst_2) (NormedSpace.toModule.{u2, u1} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2) _inst_3)) E (Submodule.setLike.{u2, u1} 𝕜 E (DivisionSemiring.toSemiring.{u2} 𝕜 (DivisionRing.toDivisionSemiring.{u2} 𝕜 (NormedDivisionRing.toDivisionRing.{u2} 𝕜 (NormedField.toNormedDivisionRing.{u2} 𝕜 _inst_1)))) (AddCommGroup.toAddCommMonoid.{u1} E (NormedAddCommGroup.toAddCommGroup.{u1} E _inst_2)) (NormedSpace.toModule.{u2, u1} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2) _inst_3))) x F))) -> (Exists.{succ u1} E (fun (x₀ : E) => And (LE.le.{0} Real Real.instLEReal (Norm.norm.{u1} E (NormedAddCommGroup.toNorm.{u1} E _inst_2) x₀) R) (forall (y : E), (Membership.mem.{u1, u1} E (Subspace.{u2, u1} 𝕜 E (NormedDivisionRing.toDivisionRing.{u2} 𝕜 (NormedField.toNormedDivisionRing.{u2} 𝕜 _inst_1)) (NormedAddCommGroup.toAddCommGroup.{u1} E _inst_2) (NormedSpace.toModule.{u2, u1} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2) _inst_3)) (SetLike.instMembership.{u1, u1} (Subspace.{u2, u1} 𝕜 E (NormedDivisionRing.toDivisionRing.{u2} 𝕜 (NormedField.toNormedDivisionRing.{u2} 𝕜 _inst_1)) (NormedAddCommGroup.toAddCommGroup.{u1} E _inst_2) (NormedSpace.toModule.{u2, u1} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2) _inst_3)) E (Submodule.setLike.{u2, u1} 𝕜 E (DivisionSemiring.toSemiring.{u2} 𝕜 (DivisionRing.toDivisionSemiring.{u2} 𝕜 (NormedDivisionRing.toDivisionRing.{u2} 𝕜 (NormedField.toNormedDivisionRing.{u2} 𝕜 _inst_1)))) (AddCommGroup.toAddCommMonoid.{u1} E (NormedAddCommGroup.toAddCommGroup.{u1} E _inst_2)) (NormedSpace.toModule.{u2, u1} 𝕜 E _inst_1 (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2) _inst_3))) y F) -> (LE.le.{0} Real Real.instLEReal (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal)) (Norm.norm.{u1} E (NormedAddCommGroup.toNorm.{u1} E _inst_2) (HSub.hSub.{u1, u1, u1} E E E (instHSub.{u1} E (SubNegMonoid.toSub.{u1} E (AddGroup.toSubNegMonoid.{u1} E (NormedAddGroup.toAddGroup.{u1} E (NormedAddCommGroup.toNormedAddGroup.{u1} E _inst_2))))) x₀ y))))))))
Case conversion may be inaccurate. Consider using '#align riesz_lemma_of_norm_lt riesz_lemma_of_norm_ltₓ'. -/
/--
A version of Riesz lemma: given a strict closed subspace `F`, one may find an element of norm `≤ R`
which is at distance  at least `1` of every element of `F`. Here, `R` is any given constant
strictly larger than the norm of an element of norm `> 1`. For a version without an `R`, see
`riesz_lemma`.

Since we are considering a general nontrivially normed field, there may be a gap in possible norms
(for instance no element of norm in `(1,2)`). Hence, we can not allow `R` arbitrarily close to `1`,
and require `R > ‖c‖` for some `c : 𝕜` with norm `> 1`.
-/
theorem riesz_lemma_of_norm_lt {c : 𝕜} (hc : 1 < ‖c‖) {R : ℝ} (hR : ‖c‖ < R) {F : Subspace 𝕜 E}
    (hFc : IsClosed (F : Set E)) (hF : ∃ x : E, x ∉ F) :
    ∃ x₀ : E, ‖x₀‖ ≤ R ∧ ∀ y ∈ F, 1 ≤ ‖x₀ - y‖ :=
  by
  have Rpos : 0 < R := (norm_nonneg _).trans_lt hR
  have : ‖c‖ / R < 1 := by rw [div_lt_iff Rpos]; simpa using hR
  rcases riesz_lemma hFc hF this with ⟨x, xF, hx⟩
  have x0 : x ≠ 0 := fun H => by simpa [H] using xF
  obtain ⟨d, d0, dxlt, ledx, -⟩ :
    ∃ d : 𝕜, d ≠ 0 ∧ ‖d • x‖ < R ∧ R / ‖c‖ ≤ ‖d • x‖ ∧ ‖d‖⁻¹ ≤ R⁻¹ * ‖c‖ * ‖x‖ :=
    rescale_to_shell hc Rpos x0
  refine' ⟨d • x, dxlt.le, fun y hy => _⟩
  set y' := d⁻¹ • y with hy'
  have y'F : y' ∈ F := by simp [hy', Submodule.smul_mem _ _ hy]
  have yy' : y = d • y' := by simp [hy', smul_smul, mul_inv_cancel d0]
  calc
    1 = ‖c‖ / R * (R / ‖c‖) := by field_simp [Rpos.ne', (zero_lt_one.trans hc).ne']
    _ ≤ ‖c‖ / R * ‖d • x‖ := (mul_le_mul_of_nonneg_left ledx (div_nonneg (norm_nonneg _) Rpos.le))
    _ = ‖d‖ * (‖c‖ / R * ‖x‖) := by simp [norm_smul]; ring
    _ ≤ ‖d‖ * ‖x - y'‖ :=
      (mul_le_mul_of_nonneg_left (hx y' (by simp [hy', Submodule.smul_mem _ _ hy])) (norm_nonneg _))
    _ = ‖d • x - y‖ := by simp [yy', ← smul_sub, norm_smul]
    
#align riesz_lemma_of_norm_lt riesz_lemma_of_norm_lt

#print Metric.closedBall_infDist_compl_subset_closure /-
theorem Metric.closedBall_infDist_compl_subset_closure {x : F} {s : Set F} (hx : x ∈ s) :
    closedBall x (infDist x (sᶜ)) ⊆ closure s :=
  by
  cases' eq_or_ne (inf_dist x (sᶜ)) 0 with h₀ h₀
  · rw [h₀, closed_ball_zero']
    exact closure_mono (singleton_subset_iff.2 hx)
  · rw [← closure_ball x h₀]
    exact closure_mono ball_inf_dist_compl_subset
#align metric.closed_ball_inf_dist_compl_subset_closure Metric.closedBall_infDist_compl_subset_closure
-/

