/-
Copyright (c) 2022 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module measure_theory.group.add_circle
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Integral.Periodic
import Mathbin.Data.Zmod.Quotient

/-!
# Measure-theoretic results about the additive circle

The file is a place to collect measure-theoretic results about the additive circle.

## Main definitions:

 * `add_circle.closed_ball_ae_eq_ball`: open and closed balls in the additive circle are almost
   equal
 * `add_circle.is_add_fundamental_domain_of_ae_ball`: a ball is a fundamental domain for rational
   angle rotation in the additive circle

-/


open Set Function Filter MeasureTheory MeasureTheory.Measure Metric

open MeasureTheory Pointwise BigOperators TopologicalSpace Ennreal

namespace AddCircle

variable {T : ℝ} [hT : Fact (0 < T)]

include hT

theorem closed_ball_ae_eq_ball {x : AddCircle T} {ε : ℝ} : closedBall x ε =ᵐ[volume] ball x ε :=
  by
  cases' le_or_lt ε 0 with hε hε
  · rw [ball_eq_empty.mpr hε, ae_eq_empty, volume_closed_ball,
      min_eq_right (by linarith [hT.out] : 2 * ε ≤ T), Ennreal.of_real_eq_zero]
    exact mul_nonpos_of_nonneg_of_nonpos zero_le_two hε
  · suffices volume (closed_ball x ε) ≤ volume (ball x ε) by
      exact
        (ae_eq_of_subset_of_measure_ge ball_subset_closed_ball this measurable_set_ball
            (measure_ne_top _ _)).symm
    have : tendsto (fun δ => volume (closed_ball x δ)) (𝓝[<] ε) (𝓝 <| volume (closed_ball x ε)) :=
      by
      simp_rw [volume_closed_ball]
      refine' Ennreal.tendsto_of_real (tendsto.min tendsto_const_nhds <| tendsto.const_mul _ _)
      convert (@monotone_id ℝ _).tendsto_nhds_within_Iio ε
      simp
    refine'
      le_of_tendsto this (mem_nhds_within_Iio_iff_exists_Ioo_subset.mpr ⟨0, hε, fun r hr => _⟩)
    exact measure_mono (closed_ball_subset_ball hr.2)
#align add_circle.closed_ball_ae_eq_ball AddCircle.closed_ball_ae_eq_ball

/-- Let `G` be the subgroup of `add_circle T` generated by a point `u` of finite order `n : ℕ`. Then
any set `I` that is almost equal to a ball of radius `T / 2n` is a fundamental domain for the action
of `G` on `add_circle T` by left addition. -/
theorem isAddFundamentalDomainOfAeBall (I : Set <| AddCircle T) (u x : AddCircle T)
    (hu : IsOfFinAddOrder u) (hI : I =ᵐ[volume] ball x (T / (2 * addOrderOf u))) :
    IsAddFundamentalDomain (AddSubgroup.zmultiples u) I :=
  by
  set G := AddSubgroup.zmultiples u
  set n := addOrderOf u
  set B := ball x (T / (2 * n))
  have hn : 1 ≤ (n : ℝ) := by
    norm_cast
    linarith [add_order_of_pos' hu]
  refine' is_add_fundamental_domain.mk_of_measure_univ_le _ _ _ _
  ·-- `null_measurable_set I volume`
    exact measurable_set_ball.null_measurable_set.congr hI.symm
  · -- `∀ (g : G), g ≠ 0 → ae_disjoint volume (g +ᵥ I) I`
    rintro ⟨g, hg⟩ hg'
    replace hg' : g ≠ 0
    · simpa only [Ne.def, AddSubgroup.mk_eq_zero_iff] using hg'
    change ae_disjoint volume (g +ᵥ I) I
    refine'
      ae_disjoint.congr (Disjoint.aeDisjoint _)
        ((quasi_measure_preserving_add_left volume (-g)).vadd_ae_eq_of_ae_eq g hI) hI
    have hBg : g +ᵥ B = ball (g + x) (T / (2 * n)) := by
      rw [add_comm g x, ← singleton_add_ball _ x g, add_ball, thickening_singleton]
    rw [hBg]
    apply ball_disjoint_ball
    rw [dist_eq_norm, add_sub_cancel, div_mul_eq_div_div, ← add_div, ← add_div, add_self_div_two,
      div_le_iff' (by positivity : 0 < (n : ℝ)), ← nsmul_eq_mul]
    refine'
      (le_add_order_smul_norm_of_is_of_fin_add_order (hu.of_mem_zmultiples hg) hg').trans
        (nsmul_le_nsmul (norm_nonneg g) _)
    exact Nat.le_of_dvd (add_order_of_pos_iff.mpr hu) (add_order_of_dvd_of_mem_zmultiples hg)
  ·-- `∀ (g : G), quasi_measure_preserving (has_vadd.vadd g) volume volume`
    exact fun g => quasi_measure_preserving_add_left volume g
  · -- `volume univ ≤ ∑' (g : G), volume (g +ᵥ I)`
    replace hI : I =ᵐ[volume] closed_ball x (T / (2 * ↑n)) := hI.trans closed_ball_ae_eq_ball.symm
    haveI : Fintype G := @Fintype.ofFinite _ hu.finite_zmultiples
    have hG_card : (Finset.univ : Finset G).card = n :=
      by
      show _ = addOrderOf u
      rw [add_order_eq_card_zmultiples', Nat.card_eq_fintype_card]
      rfl
    simp_rw [measure_vadd]
    rw [AddCircle.measure_univ, tsum_fintype, Finset.sum_const, measure_congr hI,
      volume_closed_ball, ← Ennreal.of_real_nsmul, mul_div, mul_div_mul_comm,
      div_self (@two_ne_zero ℝ _ _ _ _), one_mul, min_eq_right (div_le_self hT.out.le hn), hG_card,
      nsmul_eq_mul, mul_div_cancel' T (lt_of_lt_of_le zero_lt_one hn).Ne.symm]
    exact le_refl _
#align add_circle.is_add_fundamental_domain_of_ae_ball AddCircle.isAddFundamentalDomainOfAeBall

theorem volume_of_add_preimage_eq (s I : Set <| AddCircle T) (u x : AddCircle T)
    (hu : IsOfFinAddOrder u) (hs : (u +ᵥ s : Set <| AddCircle T) =ᵐ[volume] s)
    (hI : I =ᵐ[volume] ball x (T / (2 * addOrderOf u))) :
    volume s = addOrderOf u • volume (s ∩ I) :=
  by
  let G := AddSubgroup.zmultiples u
  haveI : Fintype G := @Fintype.ofFinite _ hu.finite_zmultiples
  have hsG : ∀ g : G, (g +ᵥ s : Set <| AddCircle T) =ᵐ[volume] s :=
    by
    rintro ⟨y, hy⟩
    exact (vadd_ae_eq_self_of_mem_zmultiples hs hy : _)
  rw [(is_add_fundamental_domain_of_ae_ball I u x hu hI).measure_eq_card_smul_of_vadd_ae_eq_self s
      hsG,
    add_order_eq_card_zmultiples' u, Nat.card_eq_fintype_card]
#align add_circle.volume_of_add_preimage_eq AddCircle.volume_of_add_preimage_eq

end AddCircle

