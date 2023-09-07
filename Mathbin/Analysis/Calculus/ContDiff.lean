/-
Copyright (c) 2019 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel, Floris van Doorn
-/
import Mathbin.Analysis.Calculus.ContDiffDef
import Mathbin.Analysis.Calculus.Deriv.Inverse
import Mathbin.Analysis.Calculus.MeanValue
import Mathbin.Analysis.NormedSpace.FiniteDimension
import Mathbin.Data.Nat.Choose.Cast

#align_import analysis.calculus.cont_diff from "leanprover-community/mathlib"@"575b4ea3738b017e30fb205cb9b4a8742e5e82b6"

/-!
# Higher differentiability of usual operations

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We prove that the usual operations (addition, multiplication, difference, composition, and
so on) preserve `C^n` functions. We also expand the API around `C^n` functions.

## Main results

* `cont_diff.comp` states that the composition of two `C^n` functions is `C^n`.
* `norm_iterated_fderiv_comp_le` gives the bound `n! * C * D ^ n` for the `n`-th derivative
  of `g ∘ f` assuming that the derivatives of `g` are bounded by `C` and the `i`-th
  derivative of `f` is bounded by `D ^ i`.

Similar results are given for `C^n` functions on domains.

## Notations

We use the notation `E [×n]→L[𝕜] F` for the space of continuous multilinear maps on `E^n` with
values in `F`. This is the space in which the `n`-th derivative of a function from `E` to `F` lives.

In this file, we denote `⊤ : ℕ∞` with `∞`.

## Tags

derivative, differentiability, higher derivative, `C^n`, multilinear, Taylor series, formal series
-/


noncomputable section

open scoped Classical BigOperators NNReal Nat

local notation "∞" => (⊤ : ℕ∞)

universe u v w uD uE uF uG

attribute [local instance 1001] NormedAddCommGroup.toAddCommGroup NormedSpace.toModule'
  AddCommGroup.toAddCommMonoid

namespace Finset

#print Finset.sum_choose_succ_mul /-
-- TODO porting note: move the next two lemmas to the file `data.nat.choose.sum`
/-- The sum of `(n+1).choose i * f i (n+1-i)` can be split into two sums at rank `n`,
respectively of `n.choose i * f i (n+1-i)` and `n.choose i * f (i+1) (n-i)`. -/
theorem sum_choose_succ_mul {R : Type _} [Semiring R] (f : ℕ → ℕ → R) (n : ℕ) :
    ∑ i in range (n + 2), ((n + 1).choose i : R) * f i (n + 1 - i) =
      ∑ i in range (n + 1), (n.choose i : R) * f i (n + 1 - i) +
        ∑ i in range (n + 1), (n.choose i : R) * f (i + 1) (n - i) :=
  by
  have A :
    ∑ i in range (n + 1), (n.choose (i + 1) : R) * f (i + 1) (n - i) + f 0 (n + 1) =
      ∑ i in range (n + 1), n.choose i * f i (n + 1 - i) :=
    by
    rw [Finset.sum_range_succ, Finset.sum_range_succ']
    simp only [Nat.choose_succ_self, algebraMap.coe_zero, MulZeroClass.zero_mul, add_zero,
      Nat.succ_sub_succ_eq_sub, Nat.choose_zero_right, algebraMap.coe_one, one_mul, tsub_zero]
  calc
    ∑ i in Finset.range (n + 2), ((n + 1).choose i : R) * f i (n + 1 - i) =
        ∑ i in Finset.range (n + 1), ((n + 1).choose (i + 1) : R) * f (i + 1) (n + 1 - (i + 1)) +
          f 0 (n + 1 - 0) :=
      by
      rw [Finset.sum_range_succ']
      simp only [Nat.choose_zero_right, algebraMap.coe_one, one_mul]
    _ =
        ∑ i in Finset.range (n + 1), (n.choose i : R) * f i (n + 1 - i) +
          ∑ i in Finset.range (n + 1), n.choose i * f (i + 1) (n - i) :=
      by
      simp only [Nat.choose_succ_succ, Nat.cast_add, Nat.succ_sub_succ_eq_sub, tsub_zero, add_mul]
      rw [Finset.sum_add_distrib, ← A]
      abel
#align finset.sum_choose_succ_mul Finset.sum_choose_succ_mul
-/

#print Finset.sum_antidiagonal_choose_succ_mul /-
/-- The sum along the antidiagonal of `(n+1).choose i * f i j` can be split into two sums along the
antidiagonal at rank `n`, respectively of `n.choose i * f i (j+1)` and `n.choose j * f (i+1) j`. -/
theorem sum_antidiagonal_choose_succ_mul {R : Type _} [Semiring R] (f : ℕ → ℕ → R) (n : ℕ) :
    ∑ ij in Nat.antidiagonal (n + 1), ((n + 1).choose ij.1 : R) * f ij.1 ij.2 =
      ∑ ij in Nat.antidiagonal n, (n.choose ij.1 : R) * f ij.1 (ij.2 + 1) +
        ∑ ij in Nat.antidiagonal n, (n.choose ij.2 : R) * f (ij.1 + 1) ij.2 :=
  by
  convert sum_choose_succ_mul f n using 1
  · exact nat.sum_antidiagonal_eq_sum_range_succ (fun i j => ((n + 1).choose i : R) * f i j) (n + 1)
  congr 1
  · rw [nat.sum_antidiagonal_eq_sum_range_succ (fun i j => (n.choose i : R) * f i (j + 1)) n]
    apply Finset.sum_congr rfl fun i hi => _
    have : n + 1 - i = n - i + 1 := Nat.sub_add_comm (Nat.lt_succ_iff.1 (Finset.mem_range.1 hi))
    simp only [this]
  · suffices H :
      ∑ ij in nat.antidiagonal n, (n.choose ij.2 : R) * f (ij.1 + 1) ij.2 =
        ∑ ij in nat.antidiagonal n, (n.choose ij.1 : R) * f (ij.1 + 1) ij.2
    · rw [H, nat.sum_antidiagonal_eq_sum_range_succ (fun i j => (n.choose i : R) * f (i + 1) j) n]
    apply Finset.sum_congr rfl fun i hi => _
    congr 2
    apply Nat.choose_symm_of_eq_add
    rw [← nat.mem_antidiagonal.1 hi, add_comm]
#align finset.sum_antidiagonal_choose_succ_mul Finset.sum_antidiagonal_choose_succ_mul
-/

end Finset

open Set Fin Filter Function

open scoped Topology

variable {𝕜 : Type _} [NontriviallyNormedField 𝕜] {D : Type uD} [NormedAddCommGroup D]
  [NormedSpace 𝕜 D] {E : Type uE} [NormedAddCommGroup E] [NormedSpace 𝕜 E] {F : Type uF}
  [NormedAddCommGroup F] [NormedSpace 𝕜 F] {G : Type uG} [NormedAddCommGroup G] [NormedSpace 𝕜 G]
  {X : Type _} [NormedAddCommGroup X] [NormedSpace 𝕜 X] {s s₁ t u : Set E} {f f₁ : E → F}
  {g : F → G} {x x₀ : E} {c : F} {b : E × F → G} {m n : ℕ∞} {p : E → FormalMultilinearSeries 𝕜 E F}

/-! ### Constants -/


#print iteratedFDeriv_zero_fun /-
@[simp]
theorem iteratedFDeriv_zero_fun {n : ℕ} : (iteratedFDeriv 𝕜 n fun x : E => (0 : F)) = 0 :=
  by
  induction' n with n IH
  · ext m; simp
  · ext x m
    rw [iteratedFDeriv_succ_apply_left, IH]
    change (fderiv 𝕜 (fun x : E => (0 : E[×n]→L[𝕜] F)) x : E → E[×n]→L[𝕜] F) (m 0) (tail m) = _
    rw [fderiv_const]
    rfl
#align iterated_fderiv_zero_fun iteratedFDeriv_zero_fun
-/

#print contDiff_zero_fun /-
theorem contDiff_zero_fun : ContDiff 𝕜 n fun x : E => (0 : F) :=
  by
  apply contDiff_of_differentiable_iteratedFDeriv fun m hm => _
  rw [iteratedFDeriv_zero_fun]
  exact differentiable_const (0 : E[×m]→L[𝕜] F)
#align cont_diff_zero_fun contDiff_zero_fun
-/

#print contDiff_const /-
/-- Constants are `C^∞`.
-/
theorem contDiff_const {c : F} : ContDiff 𝕜 n fun x : E => c :=
  by
  suffices h : ContDiff 𝕜 ∞ fun x : E => c; · exact h.of_le le_top
  rw [contDiff_top_iff_fderiv]
  refine' ⟨differentiable_const c, _⟩
  rw [fderiv_const]
  exact contDiff_zero_fun
#align cont_diff_const contDiff_const
-/

#print contDiffOn_const /-
theorem contDiffOn_const {c : F} {s : Set E} : ContDiffOn 𝕜 n (fun x : E => c) s :=
  contDiff_const.ContDiffOn
#align cont_diff_on_const contDiffOn_const
-/

#print contDiffAt_const /-
theorem contDiffAt_const {c : F} : ContDiffAt 𝕜 n (fun x : E => c) x :=
  contDiff_const.ContDiffAt
#align cont_diff_at_const contDiffAt_const
-/

#print contDiffWithinAt_const /-
theorem contDiffWithinAt_const {c : F} : ContDiffWithinAt 𝕜 n (fun x : E => c) s x :=
  contDiffAt_const.ContDiffWithinAt
#align cont_diff_within_at_const contDiffWithinAt_const
-/

#print contDiff_of_subsingleton /-
@[nontriviality]
theorem contDiff_of_subsingleton [Subsingleton F] : ContDiff 𝕜 n f := by
  rw [Subsingleton.elim f fun _ => 0]; exact contDiff_const
#align cont_diff_of_subsingleton contDiff_of_subsingleton
-/

#print contDiffAt_of_subsingleton /-
@[nontriviality]
theorem contDiffAt_of_subsingleton [Subsingleton F] : ContDiffAt 𝕜 n f x := by
  rw [Subsingleton.elim f fun _ => 0]; exact contDiffAt_const
#align cont_diff_at_of_subsingleton contDiffAt_of_subsingleton
-/

#print contDiffWithinAt_of_subsingleton /-
@[nontriviality]
theorem contDiffWithinAt_of_subsingleton [Subsingleton F] : ContDiffWithinAt 𝕜 n f s x := by
  rw [Subsingleton.elim f fun _ => 0]; exact contDiffWithinAt_const
#align cont_diff_within_at_of_subsingleton contDiffWithinAt_of_subsingleton
-/

#print contDiffOn_of_subsingleton /-
@[nontriviality]
theorem contDiffOn_of_subsingleton [Subsingleton F] : ContDiffOn 𝕜 n f s := by
  rw [Subsingleton.elim f fun _ => 0]; exact contDiffOn_const
#align cont_diff_on_of_subsingleton contDiffOn_of_subsingleton
-/

#print iteratedFDeriv_succ_const /-
theorem iteratedFDeriv_succ_const (n : ℕ) (c : F) : (iteratedFDeriv 𝕜 (n + 1) fun y : E => c) = 0 :=
  by
  ext x m
  simp only [iteratedFDeriv_succ_apply_right, fderiv_const, Pi.zero_apply, iteratedFDeriv_zero_fun,
    ContinuousMultilinearMap.zero_apply, ContinuousLinearMap.zero_apply]
#align iterated_fderiv_succ_const iteratedFDeriv_succ_const
-/

#print iteratedFDeriv_const_of_ne /-
theorem iteratedFDeriv_const_of_ne {n : ℕ} (hn : n ≠ 0) (c : F) :
    (iteratedFDeriv 𝕜 n fun y : E => c) = 0 :=
  by
  cases' Nat.exists_eq_succ_of_ne_zero hn with k hk
  rw [hk, iteratedFDeriv_succ_const]
#align iterated_fderiv_const_of_ne iteratedFDeriv_const_of_ne
-/

/-! ### Smoothness of linear functions -/


#print IsBoundedLinearMap.contDiff /-
/-- Unbundled bounded linear functions are `C^∞`.
-/
theorem IsBoundedLinearMap.contDiff (hf : IsBoundedLinearMap 𝕜 f) : ContDiff 𝕜 n f :=
  by
  suffices h : ContDiff 𝕜 ∞ f; · exact h.of_le le_top
  rw [contDiff_top_iff_fderiv]
  refine' ⟨hf.differentiable, _⟩
  simp_rw [hf.fderiv]
  exact contDiff_const
#align is_bounded_linear_map.cont_diff IsBoundedLinearMap.contDiff
-/

#print ContinuousLinearMap.contDiff /-
theorem ContinuousLinearMap.contDiff (f : E →L[𝕜] F) : ContDiff 𝕜 n f :=
  f.IsBoundedLinearMap.ContDiff
#align continuous_linear_map.cont_diff ContinuousLinearMap.contDiff
-/

#print ContinuousLinearEquiv.contDiff /-
theorem ContinuousLinearEquiv.contDiff (f : E ≃L[𝕜] F) : ContDiff 𝕜 n f :=
  (f : E →L[𝕜] F).ContDiff
#align continuous_linear_equiv.cont_diff ContinuousLinearEquiv.contDiff
-/

#print LinearIsometry.contDiff /-
theorem LinearIsometry.contDiff (f : E →ₗᵢ[𝕜] F) : ContDiff 𝕜 n f :=
  f.toContinuousLinearMap.ContDiff
#align linear_isometry.cont_diff LinearIsometry.contDiff
-/

#print LinearIsometryEquiv.contDiff /-
theorem LinearIsometryEquiv.contDiff (f : E ≃ₗᵢ[𝕜] F) : ContDiff 𝕜 n f :=
  (f : E →L[𝕜] F).ContDiff
#align linear_isometry_equiv.cont_diff LinearIsometryEquiv.contDiff
-/

#print contDiff_id /-
/-- The identity is `C^∞`.
-/
theorem contDiff_id : ContDiff 𝕜 n (id : E → E) :=
  IsBoundedLinearMap.id.ContDiff
#align cont_diff_id contDiff_id
-/

#print contDiffWithinAt_id /-
theorem contDiffWithinAt_id {s x} : ContDiffWithinAt 𝕜 n (id : E → E) s x :=
  contDiff_id.ContDiffWithinAt
#align cont_diff_within_at_id contDiffWithinAt_id
-/

#print contDiffAt_id /-
theorem contDiffAt_id {x} : ContDiffAt 𝕜 n (id : E → E) x :=
  contDiff_id.ContDiffAt
#align cont_diff_at_id contDiffAt_id
-/

#print contDiffOn_id /-
theorem contDiffOn_id {s} : ContDiffOn 𝕜 n (id : E → E) s :=
  contDiff_id.ContDiffOn
#align cont_diff_on_id contDiffOn_id
-/

#print IsBoundedBilinearMap.contDiff /-
/-- Bilinear functions are `C^∞`.
-/
theorem IsBoundedBilinearMap.contDiff (hb : IsBoundedBilinearMap 𝕜 b) : ContDiff 𝕜 n b :=
  by
  suffices h : ContDiff 𝕜 ∞ b; · exact h.of_le le_top
  rw [contDiff_top_iff_fderiv]
  refine' ⟨hb.differentiable, _⟩
  simp [hb.fderiv]
  exact hb.is_bounded_linear_map_deriv.cont_diff
#align is_bounded_bilinear_map.cont_diff IsBoundedBilinearMap.contDiff
-/

#print HasFTaylorSeriesUpToOn.continuousLinearMap_comp /-
/-- If `f` admits a Taylor series `p` in a set `s`, and `g` is linear, then `g ∘ f` admits a Taylor
series whose `k`-th term is given by `g ∘ (p k)`. -/
theorem HasFTaylorSeriesUpToOn.continuousLinearMap_comp (g : F →L[𝕜] G)
    (hf : HasFTaylorSeriesUpToOn n f p s) :
    HasFTaylorSeriesUpToOn n (g ∘ f) (fun x k => g.compContinuousMultilinearMap (p x k)) s :=
  by
  set L : ∀ m : ℕ, (E[×m]→L[𝕜] F) →L[𝕜] E[×m]→L[𝕜] G := fun m =>
    ContinuousLinearMap.compContinuousMultilinearMapL 𝕜 (fun _ => E) F G g
  constructor
  · exact fun x hx => congr_arg g (hf.zero_eq x hx)
  · intro m hm x hx
    convert (L m).HasFDerivAt.comp_hasFDerivWithinAt x (hf.fderiv_within m hm x hx)
  · intro m hm
    convert (L m).Continuous.comp_continuousOn (hf.cont m hm)
#align has_ftaylor_series_up_to_on.continuous_linear_map_comp HasFTaylorSeriesUpToOn.continuousLinearMap_comp
-/

#print ContDiffWithinAt.continuousLinearMap_comp /-
/-- Composition by continuous linear maps on the left preserves `C^n` functions in a domain
at a point. -/
theorem ContDiffWithinAt.continuousLinearMap_comp (g : F →L[𝕜] G)
    (hf : ContDiffWithinAt 𝕜 n f s x) : ContDiffWithinAt 𝕜 n (g ∘ f) s x :=
  by
  intro m hm
  rcases hf m hm with ⟨u, hu, p, hp⟩
  exact ⟨u, hu, _, hp.continuous_linear_map_comp g⟩
#align cont_diff_within_at.continuous_linear_map_comp ContDiffWithinAt.continuousLinearMap_comp
-/

#print ContDiffAt.continuousLinearMap_comp /-
/-- Composition by continuous linear maps on the left preserves `C^n` functions in a domain
at a point. -/
theorem ContDiffAt.continuousLinearMap_comp (g : F →L[𝕜] G) (hf : ContDiffAt 𝕜 n f x) :
    ContDiffAt 𝕜 n (g ∘ f) x :=
  ContDiffWithinAt.continuousLinearMap_comp g hf
#align cont_diff_at.continuous_linear_map_comp ContDiffAt.continuousLinearMap_comp
-/

#print ContDiffOn.continuousLinearMap_comp /-
/-- Composition by continuous linear maps on the left preserves `C^n` functions on domains. -/
theorem ContDiffOn.continuousLinearMap_comp (g : F →L[𝕜] G) (hf : ContDiffOn 𝕜 n f s) :
    ContDiffOn 𝕜 n (g ∘ f) s := fun x hx => (hf x hx).continuousLinearMap_comp g
#align cont_diff_on.continuous_linear_map_comp ContDiffOn.continuousLinearMap_comp
-/

#print ContDiff.continuousLinearMap_comp /-
/-- Composition by continuous linear maps on the left preserves `C^n` functions. -/
theorem ContDiff.continuousLinearMap_comp {f : E → F} (g : F →L[𝕜] G) (hf : ContDiff 𝕜 n f) :
    ContDiff 𝕜 n fun x => g (f x) :=
  contDiffOn_univ.1 <| ContDiffOn.continuousLinearMap_comp _ (contDiffOn_univ.2 hf)
#align cont_diff.continuous_linear_map_comp ContDiff.continuousLinearMap_comp
-/

#print ContinuousLinearMap.iteratedFDerivWithin_comp_left /-
/-- The iterated derivative within a set of the composition with a linear map on the left is
obtained by applying the linear map to the iterated derivative. -/
theorem ContinuousLinearMap.iteratedFDerivWithin_comp_left {f : E → F} (g : F →L[𝕜] G)
    (hf : ContDiffOn 𝕜 n f s) (hs : UniqueDiffOn 𝕜 s) (hx : x ∈ s) {i : ℕ} (hi : (i : ℕ∞) ≤ n) :
    iteratedFDerivWithin 𝕜 i (g ∘ f) s x =
      g.compContinuousMultilinearMap (iteratedFDerivWithin 𝕜 i f s x) :=
  (((hf.ftaylorSeriesWithin hs).continuousLinearMap_comp g).eq_ftaylor_series_of_uniqueDiffOn hi hs
      hx).symm
#align continuous_linear_map.iterated_fderiv_within_comp_left ContinuousLinearMap.iteratedFDerivWithin_comp_left
-/

#print ContinuousLinearMap.iteratedFDeriv_comp_left /-
/-- The iterated derivative of the composition with a linear map on the left is
obtained by applying the linear map to the iterated derivative. -/
theorem ContinuousLinearMap.iteratedFDeriv_comp_left {f : E → F} (g : F →L[𝕜] G)
    (hf : ContDiff 𝕜 n f) (x : E) {i : ℕ} (hi : (i : ℕ∞) ≤ n) :
    iteratedFDeriv 𝕜 i (g ∘ f) x = g.compContinuousMultilinearMap (iteratedFDeriv 𝕜 i f x) :=
  by
  simp only [← iteratedFDerivWithin_univ]
  exact g.iterated_fderiv_within_comp_left hf.cont_diff_on uniqueDiffOn_univ (mem_univ x) hi
#align continuous_linear_map.iterated_fderiv_comp_left ContinuousLinearMap.iteratedFDeriv_comp_left
-/

#print ContinuousLinearEquiv.iteratedFDerivWithin_comp_left /-
/-- The iterated derivative within a set of the composition with a linear equiv on the left is
obtained by applying the linear equiv to the iterated derivative. This is true without
differentiability assumptions. -/
theorem ContinuousLinearEquiv.iteratedFDerivWithin_comp_left (g : F ≃L[𝕜] G) (f : E → F)
    (hs : UniqueDiffOn 𝕜 s) (hx : x ∈ s) (i : ℕ) :
    iteratedFDerivWithin 𝕜 i (g ∘ f) s x =
      (g : F →L[𝕜] G).compContinuousMultilinearMap (iteratedFDerivWithin 𝕜 i f s x) :=
  by
  induction' i with i IH generalizing x
  · ext1 m
    simp only [iteratedFDerivWithin_zero_apply, ContinuousLinearEquiv.coe_coe,
      ContinuousLinearMap.compContinuousMultilinearMap_coe, EmbeddingLike.apply_eq_iff_eq]
  · ext1 m
    rw [iteratedFDerivWithin_succ_apply_left]
    have Z :
      fderivWithin 𝕜 (iteratedFDerivWithin 𝕜 i (g ∘ f) s) s x =
        fderivWithin 𝕜
          (fun y =>
            g.comp_continuous_multilinear_mapL (fun j : Fin i => E)
              (iteratedFDerivWithin 𝕜 i f s y))
          s x :=
      fderivWithin_congr' (@IH) hx
    simp_rw [Z]
    rw [(g.comp_continuous_multilinear_mapL fun j : Fin i => E).comp_fderivWithin (hs x hx)]
    simp only [ContinuousLinearMap.coe_comp', ContinuousLinearEquiv.coe_coe, comp_app,
      ContinuousLinearEquiv.compContinuousMultilinearMapL_apply,
      ContinuousLinearMap.compContinuousMultilinearMap_coe, EmbeddingLike.apply_eq_iff_eq]
    rw [iteratedFDerivWithin_succ_apply_left]
#align continuous_linear_equiv.iterated_fderiv_within_comp_left ContinuousLinearEquiv.iteratedFDerivWithin_comp_left
-/

#print LinearIsometry.norm_iteratedFDerivWithin_comp_left /-
/-- Composition with a linear isometry on the left preserves the norm of the iterated
derivative within a set. -/
theorem LinearIsometry.norm_iteratedFDerivWithin_comp_left {f : E → F} (g : F →ₗᵢ[𝕜] G)
    (hf : ContDiffOn 𝕜 n f s) (hs : UniqueDiffOn 𝕜 s) (hx : x ∈ s) {i : ℕ} (hi : (i : ℕ∞) ≤ n) :
    ‖iteratedFDerivWithin 𝕜 i (g ∘ f) s x‖ = ‖iteratedFDerivWithin 𝕜 i f s x‖ :=
  by
  have :
    iteratedFDerivWithin 𝕜 i (g ∘ f) s x =
      g.to_continuous_linear_map.comp_continuous_multilinear_map (iteratedFDerivWithin 𝕜 i f s x) :=
    g.to_continuous_linear_map.iterated_fderiv_within_comp_left hf hs hx hi
  rw [this]
  apply LinearIsometry.norm_compContinuousMultilinearMap
#align linear_isometry.norm_iterated_fderiv_within_comp_left LinearIsometry.norm_iteratedFDerivWithin_comp_left
-/

#print LinearIsometry.norm_iteratedFDeriv_comp_left /-
/-- Composition with a linear isometry on the left preserves the norm of the iterated
derivative. -/
theorem LinearIsometry.norm_iteratedFDeriv_comp_left {f : E → F} (g : F →ₗᵢ[𝕜] G)
    (hf : ContDiff 𝕜 n f) (x : E) {i : ℕ} (hi : (i : ℕ∞) ≤ n) :
    ‖iteratedFDeriv 𝕜 i (g ∘ f) x‖ = ‖iteratedFDeriv 𝕜 i f x‖ :=
  by
  simp only [← iteratedFDerivWithin_univ]
  exact g.norm_iterated_fderiv_within_comp_left hf.cont_diff_on uniqueDiffOn_univ (mem_univ x) hi
#align linear_isometry.norm_iterated_fderiv_comp_left LinearIsometry.norm_iteratedFDeriv_comp_left
-/

#print LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_left /-
/-- Composition with a linear isometry equiv on the left preserves the norm of the iterated
derivative within a set. -/
theorem LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_left (g : F ≃ₗᵢ[𝕜] G) (f : E → F)
    (hs : UniqueDiffOn 𝕜 s) (hx : x ∈ s) (i : ℕ) :
    ‖iteratedFDerivWithin 𝕜 i (g ∘ f) s x‖ = ‖iteratedFDerivWithin 𝕜 i f s x‖ :=
  by
  have :
    iteratedFDerivWithin 𝕜 i (g ∘ f) s x =
      (g : F →L[𝕜] G).compContinuousMultilinearMap (iteratedFDerivWithin 𝕜 i f s x) :=
    g.to_continuous_linear_equiv.iterated_fderiv_within_comp_left f hs hx i
  rw [this]
  apply LinearIsometry.norm_compContinuousMultilinearMap g.to_linear_isometry
#align linear_isometry_equiv.norm_iterated_fderiv_within_comp_left LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_left
-/

#print LinearIsometryEquiv.norm_iteratedFDeriv_comp_left /-
/-- Composition with a linear isometry equiv on the left preserves the norm of the iterated
derivative. -/
theorem LinearIsometryEquiv.norm_iteratedFDeriv_comp_left (g : F ≃ₗᵢ[𝕜] G) (f : E → F) (x : E)
    (i : ℕ) : ‖iteratedFDeriv 𝕜 i (g ∘ f) x‖ = ‖iteratedFDeriv 𝕜 i f x‖ :=
  by
  rw [← iteratedFDerivWithin_univ, ← iteratedFDerivWithin_univ]
  apply g.norm_iterated_fderiv_within_comp_left f uniqueDiffOn_univ (mem_univ x) i
#align linear_isometry_equiv.norm_iterated_fderiv_comp_left LinearIsometryEquiv.norm_iteratedFDeriv_comp_left
-/

#print ContinuousLinearEquiv.comp_contDiffWithinAt_iff /-
/-- Composition by continuous linear equivs on the left respects higher differentiability at a
point in a domain. -/
theorem ContinuousLinearEquiv.comp_contDiffWithinAt_iff (e : F ≃L[𝕜] G) :
    ContDiffWithinAt 𝕜 n (e ∘ f) s x ↔ ContDiffWithinAt 𝕜 n f s x :=
  ⟨fun H => by
    simpa only [(· ∘ ·), e.symm.coe_coe, e.symm_apply_apply] using
      H.continuous_linear_map_comp (e.symm : G →L[𝕜] F),
    fun H => H.continuousLinearMap_comp (e : F →L[𝕜] G)⟩
#align continuous_linear_equiv.comp_cont_diff_within_at_iff ContinuousLinearEquiv.comp_contDiffWithinAt_iff
-/

#print ContinuousLinearEquiv.comp_contDiffAt_iff /-
/-- Composition by continuous linear equivs on the left respects higher differentiability at a
point. -/
theorem ContinuousLinearEquiv.comp_contDiffAt_iff (e : F ≃L[𝕜] G) :
    ContDiffAt 𝕜 n (e ∘ f) x ↔ ContDiffAt 𝕜 n f x := by
  simp only [← contDiffWithinAt_univ, e.comp_cont_diff_within_at_iff]
#align continuous_linear_equiv.comp_cont_diff_at_iff ContinuousLinearEquiv.comp_contDiffAt_iff
-/

#print ContinuousLinearEquiv.comp_contDiffOn_iff /-
/-- Composition by continuous linear equivs on the left respects higher differentiability on
domains. -/
theorem ContinuousLinearEquiv.comp_contDiffOn_iff (e : F ≃L[𝕜] G) :
    ContDiffOn 𝕜 n (e ∘ f) s ↔ ContDiffOn 𝕜 n f s := by
  simp [ContDiffOn, e.comp_cont_diff_within_at_iff]
#align continuous_linear_equiv.comp_cont_diff_on_iff ContinuousLinearEquiv.comp_contDiffOn_iff
-/

#print ContinuousLinearEquiv.comp_contDiff_iff /-
/-- Composition by continuous linear equivs on the left respects higher differentiability. -/
theorem ContinuousLinearEquiv.comp_contDiff_iff (e : F ≃L[𝕜] G) :
    ContDiff 𝕜 n (e ∘ f) ↔ ContDiff 𝕜 n f := by
  simp only [← contDiffOn_univ, e.comp_cont_diff_on_iff]
#align continuous_linear_equiv.comp_cont_diff_iff ContinuousLinearEquiv.comp_contDiff_iff
-/

#print HasFTaylorSeriesUpToOn.compContinuousLinearMap /-
/-- If `f` admits a Taylor series `p` in a set `s`, and `g` is linear, then `f ∘ g` admits a Taylor
series in `g ⁻¹' s`, whose `k`-th term is given by `p k (g v₁, ..., g vₖ)` . -/
theorem HasFTaylorSeriesUpToOn.compContinuousLinearMap (hf : HasFTaylorSeriesUpToOn n f p s)
    (g : G →L[𝕜] E) :
    HasFTaylorSeriesUpToOn n (f ∘ g) (fun x k => (p (g x) k).compContinuousLinearMap fun _ => g)
      (g ⁻¹' s) :=
  by
  let A : ∀ m : ℕ, (E[×m]→L[𝕜] F) → G[×m]→L[𝕜] F := fun m h => h.compContinuousLinearMap fun _ => g
  have hA : ∀ m, IsBoundedLinearMap 𝕜 (A m) := fun m =>
    isBoundedLinearMap_continuousMultilinearMap_comp_linear g
  constructor
  · intro x hx
    simp only [(hf.zero_eq (g x) hx).symm, Function.comp_apply]
    change (p (g x) 0 fun i : Fin 0 => g 0) = p (g x) 0 0
    rw [ContinuousLinearMap.map_zero]
    rfl
  · intro m hm x hx
    convert
      (hA m).HasFDerivAt.comp_hasFDerivWithinAt x
        ((hf.fderiv_within m hm (g x) hx).comp x g.has_fderiv_within_at (subset.refl _))
    ext y v
    change p (g x) (Nat.succ m) (g ∘ cons y v) = p (g x) m.succ (cons (g y) (g ∘ v))
    rw [comp_cons]
  · intro m hm
    exact
      (hA m).Continuous.comp_continuousOn
        ((hf.cont m hm).comp g.continuous.continuous_on (subset.refl _))
#align has_ftaylor_series_up_to_on.comp_continuous_linear_map HasFTaylorSeriesUpToOn.compContinuousLinearMap
-/

#print ContDiffWithinAt.comp_continuousLinearMap /-
/-- Composition by continuous linear maps on the right preserves `C^n` functions at a point on
a domain. -/
theorem ContDiffWithinAt.comp_continuousLinearMap {x : G} (g : G →L[𝕜] E)
    (hf : ContDiffWithinAt 𝕜 n f s (g x)) : ContDiffWithinAt 𝕜 n (f ∘ g) (g ⁻¹' s) x :=
  by
  intro m hm
  rcases hf m hm with ⟨u, hu, p, hp⟩
  refine' ⟨g ⁻¹' u, _, _, hp.comp_continuous_linear_map g⟩
  apply ContinuousWithinAt.preimage_mem_nhdsWithin'
  · exact g.continuous.continuous_within_at
  · apply nhdsWithin_mono (g x) _ hu
    rw [image_insert_eq]
    exact insert_subset_insert (image_preimage_subset g s)
#align cont_diff_within_at.comp_continuous_linear_map ContDiffWithinAt.comp_continuousLinearMap
-/

#print ContDiffOn.comp_continuousLinearMap /-
/-- Composition by continuous linear maps on the right preserves `C^n` functions on domains. -/
theorem ContDiffOn.comp_continuousLinearMap (hf : ContDiffOn 𝕜 n f s) (g : G →L[𝕜] E) :
    ContDiffOn 𝕜 n (f ∘ g) (g ⁻¹' s) := fun x hx => (hf (g x) hx).compContinuousLinearMap g
#align cont_diff_on.comp_continuous_linear_map ContDiffOn.comp_continuousLinearMap
-/

#print ContDiff.comp_continuousLinearMap /-
/-- Composition by continuous linear maps on the right preserves `C^n` functions. -/
theorem ContDiff.comp_continuousLinearMap {f : E → F} {g : G →L[𝕜] E} (hf : ContDiff 𝕜 n f) :
    ContDiff 𝕜 n (f ∘ g) :=
  contDiffOn_univ.1 <| ContDiffOn.comp_continuousLinearMap (contDiffOn_univ.2 hf) _
#align cont_diff.comp_continuous_linear_map ContDiff.comp_continuousLinearMap
-/

#print ContinuousLinearMap.iteratedFDerivWithin_comp_right /-
/-- The iterated derivative within a set of the composition with a linear map on the right is
obtained by composing the iterated derivative with the linear map. -/
theorem ContinuousLinearMap.iteratedFDerivWithin_comp_right {f : E → F} (g : G →L[𝕜] E)
    (hf : ContDiffOn 𝕜 n f s) (hs : UniqueDiffOn 𝕜 s) (h's : UniqueDiffOn 𝕜 (g ⁻¹' s)) {x : G}
    (hx : g x ∈ s) {i : ℕ} (hi : (i : ℕ∞) ≤ n) :
    iteratedFDerivWithin 𝕜 i (f ∘ g) (g ⁻¹' s) x =
      (iteratedFDerivWithin 𝕜 i f s (g x)).compContinuousLinearMap fun _ => g :=
  (((hf.ftaylorSeriesWithin hs).compContinuousLinearMap g).eq_ftaylor_series_of_uniqueDiffOn hi h's
      hx).symm
#align continuous_linear_map.iterated_fderiv_within_comp_right ContinuousLinearMap.iteratedFDerivWithin_comp_right
-/

#print ContinuousLinearEquiv.iteratedFDerivWithin_comp_right /-
/-- The iterated derivative within a set of the composition with a linear equiv on the right is
obtained by composing the iterated derivative with the linear equiv. -/
theorem ContinuousLinearEquiv.iteratedFDerivWithin_comp_right (g : G ≃L[𝕜] E) (f : E → F)
    (hs : UniqueDiffOn 𝕜 s) {x : G} (hx : g x ∈ s) (i : ℕ) :
    iteratedFDerivWithin 𝕜 i (f ∘ g) (g ⁻¹' s) x =
      (iteratedFDerivWithin 𝕜 i f s (g x)).compContinuousLinearMap fun _ => g :=
  by
  induction' i with i IH generalizing x
  · ext1 m
    simp only [iteratedFDerivWithin_zero_apply,
      ContinuousMultilinearMap.compContinuousLinearMap_apply]
  · ext1 m
    simp only [ContinuousMultilinearMap.compContinuousLinearMap_apply,
      ContinuousLinearEquiv.coe_coe, iteratedFDerivWithin_succ_apply_left]
    have :
      fderivWithin 𝕜 (iteratedFDerivWithin 𝕜 i (f ∘ ⇑g) (⇑g ⁻¹' s)) (⇑g ⁻¹' s) x =
        fderivWithin 𝕜
          (fun y =>
            ContinuousMultilinearMap.compContinuousLinearMapEquivL _ (fun _x : Fin i => g)
              (iteratedFDerivWithin 𝕜 i f s (g y)))
          (g ⁻¹' s) x :=
      fderivWithin_congr' (@IH) hx
    rw [this]
    rw [ContinuousLinearEquiv.comp_fderivWithin _ (g.unique_diff_on_preimage_iff.2 hs x hx)]
    simp only [ContinuousLinearMap.coe_comp', ContinuousLinearEquiv.coe_coe, comp_app,
      ContinuousMultilinearMap.compContinuousLinearMapEquivL_apply,
      ContinuousMultilinearMap.compContinuousLinearMap_apply]
    rw [ContinuousLinearEquiv.comp_right_fderivWithin _ (g.unique_diff_on_preimage_iff.2 hs x hx)]
    rfl
#align continuous_linear_equiv.iterated_fderiv_within_comp_right ContinuousLinearEquiv.iteratedFDerivWithin_comp_right
-/

#print ContinuousLinearMap.iteratedFDeriv_comp_right /-
/-- The iterated derivative of the composition with a linear map on the right is
obtained by composing the iterated derivative with the linear map. -/
theorem ContinuousLinearMap.iteratedFDeriv_comp_right (g : G →L[𝕜] E) {f : E → F}
    (hf : ContDiff 𝕜 n f) (x : G) {i : ℕ} (hi : (i : ℕ∞) ≤ n) :
    iteratedFDeriv 𝕜 i (f ∘ g) x =
      (iteratedFDeriv 𝕜 i f (g x)).compContinuousLinearMap fun _ => g :=
  by
  simp only [← iteratedFDerivWithin_univ]
  apply
    g.iterated_fderiv_within_comp_right hf.cont_diff_on uniqueDiffOn_univ uniqueDiffOn_univ
      (mem_univ _) hi
#align continuous_linear_map.iterated_fderiv_comp_right ContinuousLinearMap.iteratedFDeriv_comp_right
-/

#print LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_right /-
/-- Composition with a linear isometry on the right preserves the norm of the iterated derivative
within a set. -/
theorem LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_right (g : G ≃ₗᵢ[𝕜] E) (f : E → F)
    (hs : UniqueDiffOn 𝕜 s) {x : G} (hx : g x ∈ s) (i : ℕ) :
    ‖iteratedFDerivWithin 𝕜 i (f ∘ g) (g ⁻¹' s) x‖ = ‖iteratedFDerivWithin 𝕜 i f s (g x)‖ :=
  by
  have :
    iteratedFDerivWithin 𝕜 i (f ∘ g) (g ⁻¹' s) x =
      (iteratedFDerivWithin 𝕜 i f s (g x)).compContinuousLinearMap fun _ => g :=
    g.to_continuous_linear_equiv.iterated_fderiv_within_comp_right f hs hx i
  rw [this, ContinuousMultilinearMap.norm_compContinuous_linearIsometryEquiv]
#align linear_isometry_equiv.norm_iterated_fderiv_within_comp_right LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_right
-/

#print LinearIsometryEquiv.norm_iteratedFDeriv_comp_right /-
/-- Composition with a linear isometry on the right preserves the norm of the iterated derivative
within a set. -/
theorem LinearIsometryEquiv.norm_iteratedFDeriv_comp_right (g : G ≃ₗᵢ[𝕜] E) (f : E → F) (x : G)
    (i : ℕ) : ‖iteratedFDeriv 𝕜 i (f ∘ g) x‖ = ‖iteratedFDeriv 𝕜 i f (g x)‖ :=
  by
  simp only [← iteratedFDerivWithin_univ]
  apply g.norm_iterated_fderiv_within_comp_right f uniqueDiffOn_univ (mem_univ (g x)) i
#align linear_isometry_equiv.norm_iterated_fderiv_comp_right LinearIsometryEquiv.norm_iteratedFDeriv_comp_right
-/

#print ContinuousLinearEquiv.contDiffWithinAt_comp_iff /-
/-- Composition by continuous linear equivs on the right respects higher differentiability at a
point in a domain. -/
theorem ContinuousLinearEquiv.contDiffWithinAt_comp_iff (e : G ≃L[𝕜] E) :
    ContDiffWithinAt 𝕜 n (f ∘ e) (e ⁻¹' s) (e.symm x) ↔ ContDiffWithinAt 𝕜 n f s x :=
  by
  constructor
  · intro H
    simpa [← preimage_comp, (· ∘ ·)] using H.comp_continuous_linear_map (e.symm : E →L[𝕜] G)
  · intro H
    rw [← e.apply_symm_apply x, ← e.coe_coe] at H 
    exact H.comp_continuous_linear_map _
#align continuous_linear_equiv.cont_diff_within_at_comp_iff ContinuousLinearEquiv.contDiffWithinAt_comp_iff
-/

#print ContinuousLinearEquiv.contDiffAt_comp_iff /-
/-- Composition by continuous linear equivs on the right respects higher differentiability at a
point. -/
theorem ContinuousLinearEquiv.contDiffAt_comp_iff (e : G ≃L[𝕜] E) :
    ContDiffAt 𝕜 n (f ∘ e) (e.symm x) ↔ ContDiffAt 𝕜 n f x :=
  by
  rw [← contDiffWithinAt_univ, ← contDiffWithinAt_univ, ← preimage_univ]
  exact e.cont_diff_within_at_comp_iff
#align continuous_linear_equiv.cont_diff_at_comp_iff ContinuousLinearEquiv.contDiffAt_comp_iff
-/

#print ContinuousLinearEquiv.contDiffOn_comp_iff /-
/-- Composition by continuous linear equivs on the right respects higher differentiability on
domains. -/
theorem ContinuousLinearEquiv.contDiffOn_comp_iff (e : G ≃L[𝕜] E) :
    ContDiffOn 𝕜 n (f ∘ e) (e ⁻¹' s) ↔ ContDiffOn 𝕜 n f s :=
  by
  refine' ⟨fun H => _, fun H => H.compContinuousLinearMap (e : G →L[𝕜] E)⟩
  have A : f = (f ∘ e) ∘ e.symm := by ext y; simp only [Function.comp_apply];
    rw [e.apply_symm_apply y]
  have B : e.symm ⁻¹' (e ⁻¹' s) = s := by rw [← preimage_comp, e.self_comp_symm]; rfl
  rw [A, ← B]
  exact H.comp_continuous_linear_map (e.symm : E →L[𝕜] G)
#align continuous_linear_equiv.cont_diff_on_comp_iff ContinuousLinearEquiv.contDiffOn_comp_iff
-/

#print ContinuousLinearEquiv.contDiff_comp_iff /-
/-- Composition by continuous linear equivs on the right respects higher differentiability. -/
theorem ContinuousLinearEquiv.contDiff_comp_iff (e : G ≃L[𝕜] E) :
    ContDiff 𝕜 n (f ∘ e) ↔ ContDiff 𝕜 n f :=
  by
  rw [← contDiffOn_univ, ← contDiffOn_univ, ← preimage_univ]
  exact e.cont_diff_on_comp_iff
#align continuous_linear_equiv.cont_diff_comp_iff ContinuousLinearEquiv.contDiff_comp_iff
-/

#print HasFTaylorSeriesUpToOn.prod /-
/-- If two functions `f` and `g` admit Taylor series `p` and `q` in a set `s`, then the cartesian
product of `f` and `g` admits the cartesian product of `p` and `q` as a Taylor series. -/
theorem HasFTaylorSeriesUpToOn.prod (hf : HasFTaylorSeriesUpToOn n f p s) {g : E → G}
    {q : E → FormalMultilinearSeries 𝕜 E G} (hg : HasFTaylorSeriesUpToOn n g q s) :
    HasFTaylorSeriesUpToOn n (fun y => (f y, g y)) (fun y k => (p y k).Prod (q y k)) s :=
  by
  set L := fun m => ContinuousMultilinearMap.prodL 𝕜 (fun i : Fin m => E) F G
  constructor
  · intro x hx; rw [← hf.zero_eq x hx, ← hg.zero_eq x hx]; rfl
  · intro m hm x hx
    convert
      (L m).HasFDerivAt.comp_hasFDerivWithinAt x
        ((hf.fderiv_within m hm x hx).Prod (hg.fderiv_within m hm x hx))
  · intro m hm
    exact (L m).Continuous.comp_continuousOn ((hf.cont m hm).Prod (hg.cont m hm))
#align has_ftaylor_series_up_to_on.prod HasFTaylorSeriesUpToOn.prod
-/

#print ContDiffWithinAt.prod /-
/-- The cartesian product of `C^n` functions at a point in a domain is `C^n`. -/
theorem ContDiffWithinAt.prod {s : Set E} {f : E → F} {g : E → G} (hf : ContDiffWithinAt 𝕜 n f s x)
    (hg : ContDiffWithinAt 𝕜 n g s x) : ContDiffWithinAt 𝕜 n (fun x : E => (f x, g x)) s x :=
  by
  intro m hm
  rcases hf m hm with ⟨u, hu, p, hp⟩
  rcases hg m hm with ⟨v, hv, q, hq⟩
  exact
    ⟨u ∩ v, Filter.inter_mem hu hv, _,
      (hp.mono (inter_subset_left u v)).Prod (hq.mono (inter_subset_right u v))⟩
#align cont_diff_within_at.prod ContDiffWithinAt.prod
-/

#print ContDiffOn.prod /-
/-- The cartesian product of `C^n` functions on domains is `C^n`. -/
theorem ContDiffOn.prod {s : Set E} {f : E → F} {g : E → G} (hf : ContDiffOn 𝕜 n f s)
    (hg : ContDiffOn 𝕜 n g s) : ContDiffOn 𝕜 n (fun x : E => (f x, g x)) s := fun x hx =>
  (hf x hx).Prod (hg x hx)
#align cont_diff_on.prod ContDiffOn.prod
-/

#print ContDiffAt.prod /-
/-- The cartesian product of `C^n` functions at a point is `C^n`. -/
theorem ContDiffAt.prod {f : E → F} {g : E → G} (hf : ContDiffAt 𝕜 n f x)
    (hg : ContDiffAt 𝕜 n g x) : ContDiffAt 𝕜 n (fun x : E => (f x, g x)) x :=
  contDiffWithinAt_univ.1 <|
    ContDiffWithinAt.prod (contDiffWithinAt_univ.2 hf) (contDiffWithinAt_univ.2 hg)
#align cont_diff_at.prod ContDiffAt.prod
-/

#print ContDiff.prod /-
/-- The cartesian product of `C^n` functions is `C^n`.-/
theorem ContDiff.prod {f : E → F} {g : E → G} (hf : ContDiff 𝕜 n f) (hg : ContDiff 𝕜 n g) :
    ContDiff 𝕜 n fun x : E => (f x, g x) :=
  contDiffOn_univ.1 <| ContDiffOn.prod (contDiffOn_univ.2 hf) (contDiffOn_univ.2 hg)
#align cont_diff.prod ContDiff.prod
-/

/-!
### Composition of `C^n` functions

We show that the composition of `C^n` functions is `C^n`. One way to prove it would be to write
the `n`-th derivative of the composition (this is Faà di Bruno's formula) and check its continuity,
but this is very painful. Instead, we go for a simple inductive proof. Assume it is done for `n`.
Then, to check it for `n+1`, one needs to check that the derivative of `g ∘ f` is `C^n`, i.e.,
that `Dg(f x) ⬝ Df(x)` is `C^n`. The term `Dg (f x)` is the composition of two `C^n` functions, so
it is `C^n` by the inductive assumption. The term `Df(x)` is also `C^n`. Then, the matrix
multiplication is the application of a bilinear map (which is `C^∞`, and therefore `C^n`) to
`x ↦ (Dg(f x), Df x)`. As the composition of two `C^n` maps, it is again `C^n`, and we are done.

There is a subtlety in this argument: we apply the inductive assumption to functions on other Banach
spaces. In maths, one would say: prove by induction over `n` that, for all `C^n` maps between all
pairs of Banach spaces, their composition is `C^n`. In Lean, this is fine as long as the spaces
stay in the same universe. This is not the case in the above argument: if `E` lives in universe `u`
and `F` lives in universe `v`, then linear maps from `E` to `F` (to which the derivative of `f`
belongs) is in universe `max u v`. If one could quantify over finitely many universes, the above
proof would work fine, but this is not the case. One could still write the proof considering spaces
in any universe in `u, v, w, max u v, max v w, max u v w`, but it would be extremely tedious and
lead to a lot of duplication. Instead, we formulate the above proof when all spaces live in the same
universe (where everything is fine), and then we deduce the general result by lifting all our spaces
to a common universe. We use the trick that any space `H` is isomorphic through a continuous linear
equiv to `continuous_multilinear_map (λ (i : fin 0), E × F × G) H` to change the universe level,
and then argue that composing with such a linear equiv does not change the fact of being `C^n`,
which we have already proved previously.
-/


/-- Auxiliary lemma proving that the composition of `C^n` functions on domains is `C^n` when all
spaces live in the same universe. Use instead `cont_diff_on.comp` which removes the universe
assumption (but is deduced from this one). -/
private theorem cont_diff_on.comp_same_univ {Eu : Type u} [NormedAddCommGroup Eu] [NormedSpace 𝕜 Eu]
    {Fu : Type u} [NormedAddCommGroup Fu] [NormedSpace 𝕜 Fu] {Gu : Type u} [NormedAddCommGroup Gu]
    [NormedSpace 𝕜 Gu] {s : Set Eu} {t : Set Fu} {g : Fu → Gu} {f : Eu → Fu}
    (hg : ContDiffOn 𝕜 n g t) (hf : ContDiffOn 𝕜 n f s) (st : s ⊆ f ⁻¹' t) :
    ContDiffOn 𝕜 n (g ∘ f) s :=
  by
  induction' n using ENat.nat_induction with n IH Itop generalizing Eu Fu Gu
  · rw [contDiffOn_zero] at hf hg ⊢
    exact ContinuousOn.comp hg hf st
  · rw [contDiffOn_succ_iff_hasFDerivWithinAt] at hg ⊢
    intro x hx
    rcases(contDiffOn_succ_iff_hasFDerivWithinAt.1 hf) x hx with ⟨u, hu, f', hf', f'_diff⟩
    rcases hg (f x) (st hx) with ⟨v, hv, g', hg', g'_diff⟩
    rw [insert_eq_of_mem hx] at hu ⊢
    have xu : x ∈ u := mem_of_mem_nhdsWithin hx hu
    let w := s ∩ (u ∩ f ⁻¹' v)
    have wv : w ⊆ f ⁻¹' v := fun y hy => hy.2.2
    have wu : w ⊆ u := fun y hy => hy.2.1
    have ws : w ⊆ s := fun y hy => hy.1
    refine' ⟨w, _, fun y => (g' (f y)).comp (f' y), _, _⟩
    show w ∈ 𝓝[s] x
    · apply Filter.inter_mem self_mem_nhdsWithin
      apply Filter.inter_mem hu
      apply ContinuousWithinAt.preimage_mem_nhdsWithin'
      · rw [← continuousWithinAt_inter' hu]
        exact (hf' x xu).DifferentiableWithinAt.ContinuousWithinAt.mono (inter_subset_right _ _)
      · apply nhdsWithin_mono _ _ hv
        exact subset.trans (image_subset_iff.mpr st) (subset_insert (f x) t)
    show ∀ y ∈ w, HasFDerivWithinAt (g ∘ f) ((g' (f y)).comp (f' y)) w y
    · rintro y ⟨ys, yu, yv⟩
      exact (hg' (f y) yv).comp y ((hf' y yu).mono wu) wv
    show ContDiffOn 𝕜 n (fun y => (g' (f y)).comp (f' y)) w
    · have A : ContDiffOn 𝕜 n (fun y => g' (f y)) w :=
        IH g'_diff ((hf.of_le (WithTop.coe_le_coe.2 (Nat.le_succ n))).mono ws) wv
      have B : ContDiffOn 𝕜 n f' w := f'_diff.mono wu
      have C : ContDiffOn 𝕜 n (fun y => (g' (f y), f' y)) w := A.prod B
      have D : ContDiffOn 𝕜 n (fun p : (Fu →L[𝕜] Gu) × (Eu →L[𝕜] Fu) => p.1.comp p.2) univ :=
        is_bounded_bilinear_map_comp.cont_diff.cont_diff_on
      exact IH D C (subset_univ _)
  · rw [contDiffOn_top] at hf hg ⊢
    exact fun n => Itop n (hg n) (hf n) st

#print ContDiffOn.comp /-
/-- The composition of `C^n` functions on domains is `C^n`. -/
theorem ContDiffOn.comp {s : Set E} {t : Set F} {g : F → G} {f : E → F} (hg : ContDiffOn 𝕜 n g t)
    (hf : ContDiffOn 𝕜 n f s) (st : s ⊆ f ⁻¹' t) : ContDiffOn 𝕜 n (g ∘ f) s :=
  by
  /- we lift all the spaces to a common universe, as we have already proved the result in this
    situation. -/
  let Eu : Type max uE uF uG := ULift E
  let Fu : Type max uE uF uG := ULift.{max uE uG, uF} F
  let Gu : Type max uE uF uG := ULift.{max uE uF, uG} G
  -- declare the isomorphisms
  have isoE : Eu ≃L[𝕜] E := ContinuousLinearEquiv.ulift
  have isoF : Fu ≃L[𝕜] F := ContinuousLinearEquiv.ulift
  have isoG : Gu ≃L[𝕜] G := ContinuousLinearEquiv.ulift
  -- lift the functions to the new spaces, check smoothness there, and then go back.
  let fu : Eu → Fu := (isoF.symm ∘ f) ∘ isoE
  have fu_diff : ContDiffOn 𝕜 n fu (isoE ⁻¹' s) := by
    rwa [isoE.cont_diff_on_comp_iff, isoF.symm.comp_cont_diff_on_iff]
  let gu : Fu → Gu := (isoG.symm ∘ g) ∘ isoF
  have gu_diff : ContDiffOn 𝕜 n gu (isoF ⁻¹' t) := by
    rwa [isoF.cont_diff_on_comp_iff, isoG.symm.comp_cont_diff_on_iff]
  have main : ContDiffOn 𝕜 n (gu ∘ fu) (isoE ⁻¹' s) :=
    by
    apply cont_diff_on.comp_same_univ gu_diff fu_diff
    intro y hy
    simp only [fu, ContinuousLinearEquiv.coe_apply, Function.comp_apply, mem_preimage]
    rw [isoF.apply_symm_apply (f (isoE y))]
    exact st hy
  have : gu ∘ fu = (isoG.symm ∘ g ∘ f) ∘ isoE :=
    by
    ext y
    simp only [Function.comp_apply, gu, fu]
    rw [isoF.apply_symm_apply (f (isoE y))]
  rwa [this, isoE.cont_diff_on_comp_iff, isoG.symm.comp_cont_diff_on_iff] at main 
#align cont_diff_on.comp ContDiffOn.comp
-/

#print ContDiffOn.comp' /-
/-- The composition of `C^n` functions on domains is `C^n`. -/
theorem ContDiffOn.comp' {s : Set E} {t : Set F} {g : F → G} {f : E → F} (hg : ContDiffOn 𝕜 n g t)
    (hf : ContDiffOn 𝕜 n f s) : ContDiffOn 𝕜 n (g ∘ f) (s ∩ f ⁻¹' t) :=
  hg.comp (hf.mono (inter_subset_left _ _)) (inter_subset_right _ _)
#align cont_diff_on.comp' ContDiffOn.comp'
-/

#print ContDiff.comp_contDiffOn /-
/-- The composition of a `C^n` function on a domain with a `C^n` function is `C^n`. -/
theorem ContDiff.comp_contDiffOn {s : Set E} {g : F → G} {f : E → F} (hg : ContDiff 𝕜 n g)
    (hf : ContDiffOn 𝕜 n f s) : ContDiffOn 𝕜 n (g ∘ f) s :=
  (contDiffOn_univ.2 hg).comp hf subset_preimage_univ
#align cont_diff.comp_cont_diff_on ContDiff.comp_contDiffOn
-/

#print ContDiff.comp /-
/-- The composition of `C^n` functions is `C^n`. -/
theorem ContDiff.comp {g : F → G} {f : E → F} (hg : ContDiff 𝕜 n g) (hf : ContDiff 𝕜 n f) :
    ContDiff 𝕜 n (g ∘ f) :=
  contDiffOn_univ.1 <| ContDiffOn.comp (contDiffOn_univ.2 hg) (contDiffOn_univ.2 hf) (subset_univ _)
#align cont_diff.comp ContDiff.comp
-/

#print ContDiffWithinAt.comp /-
/-- The composition of `C^n` functions at points in domains is `C^n`. -/
theorem ContDiffWithinAt.comp {s : Set E} {t : Set F} {g : F → G} {f : E → F} (x : E)
    (hg : ContDiffWithinAt 𝕜 n g t (f x)) (hf : ContDiffWithinAt 𝕜 n f s x) (st : s ⊆ f ⁻¹' t) :
    ContDiffWithinAt 𝕜 n (g ∘ f) s x := by
  intro m hm
  rcases hg.cont_diff_on hm with ⟨u, u_nhd, ut, hu⟩
  rcases hf.cont_diff_on hm with ⟨v, v_nhd, vs, hv⟩
  have xmem : x ∈ f ⁻¹' u ∩ v :=
    ⟨(mem_of_mem_nhdsWithin (mem_insert (f x) _) u_nhd : _),
      mem_of_mem_nhdsWithin (mem_insert x s) v_nhd⟩
  have : f ⁻¹' u ∈ 𝓝[insert x s] x :=
    by
    apply hf.continuous_within_at.insert_self.preimage_mem_nhds_within'
    apply nhdsWithin_mono _ _ u_nhd
    rw [image_insert_eq]
    exact insert_subset_insert (image_subset_iff.mpr st)
  have Z :=
    (hu.comp (hv.mono (inter_subset_right (f ⁻¹' u) v)) (inter_subset_left _ _)).ContDiffWithinAt
      xmem m le_rfl
  have : 𝓝[f ⁻¹' u ∩ v] x = 𝓝[insert x s] x :=
    by
    have A : f ⁻¹' u ∩ v = insert x s ∩ (f ⁻¹' u ∩ v) :=
      by
      apply subset.antisymm _ (inter_subset_right _ _)
      rintro y ⟨hy1, hy2⟩
      simp [hy1, hy2, vs hy2]
    rw [A, ← nhdsWithin_restrict'']
    exact Filter.inter_mem this v_nhd
  rwa [insert_eq_of_mem xmem, this] at Z 
#align cont_diff_within_at.comp ContDiffWithinAt.comp
-/

#print ContDiffWithinAt.comp_of_mem /-
/-- The composition of `C^n` functions at points in domains is `C^n`,
  with a weaker condition on `s` and `t`. -/
theorem ContDiffWithinAt.comp_of_mem {s : Set E} {t : Set F} {g : F → G} {f : E → F} (x : E)
    (hg : ContDiffWithinAt 𝕜 n g t (f x)) (hf : ContDiffWithinAt 𝕜 n f s x)
    (hs : t ∈ 𝓝[f '' s] f x) : ContDiffWithinAt 𝕜 n (g ∘ f) s x :=
  (hg.mono_of_mem hs).comp x hf (subset_preimage_image f s)
#align cont_diff_within_at.comp_of_mem ContDiffWithinAt.comp_of_mem
-/

#print ContDiffWithinAt.comp' /-
/-- The composition of `C^n` functions at points in domains is `C^n`. -/
theorem ContDiffWithinAt.comp' {s : Set E} {t : Set F} {g : F → G} {f : E → F} (x : E)
    (hg : ContDiffWithinAt 𝕜 n g t (f x)) (hf : ContDiffWithinAt 𝕜 n f s x) :
    ContDiffWithinAt 𝕜 n (g ∘ f) (s ∩ f ⁻¹' t) x :=
  hg.comp x (hf.mono (inter_subset_left _ _)) (inter_subset_right _ _)
#align cont_diff_within_at.comp' ContDiffWithinAt.comp'
-/

#print ContDiffAt.comp_contDiffWithinAt /-
theorem ContDiffAt.comp_contDiffWithinAt {n} (x : E) (hg : ContDiffAt 𝕜 n g (f x))
    (hf : ContDiffWithinAt 𝕜 n f s x) : ContDiffWithinAt 𝕜 n (g ∘ f) s x :=
  hg.comp x hf (mapsTo_univ _ _)
#align cont_diff_at.comp_cont_diff_within_at ContDiffAt.comp_contDiffWithinAt
-/

#print ContDiffAt.comp /-
/-- The composition of `C^n` functions at points is `C^n`. -/
theorem ContDiffAt.comp (x : E) (hg : ContDiffAt 𝕜 n g (f x)) (hf : ContDiffAt 𝕜 n f x) :
    ContDiffAt 𝕜 n (g ∘ f) x :=
  hg.comp x hf subset_preimage_univ
#align cont_diff_at.comp ContDiffAt.comp
-/

#print ContDiff.comp_contDiffWithinAt /-
theorem ContDiff.comp_contDiffWithinAt {g : F → G} {f : E → F} (h : ContDiff 𝕜 n g)
    (hf : ContDiffWithinAt 𝕜 n f t x) : ContDiffWithinAt 𝕜 n (g ∘ f) t x :=
  haveI : ContDiffWithinAt 𝕜 n g univ (f x) := h.cont_diff_at.cont_diff_within_at
  this.comp x hf (subset_univ _)
#align cont_diff.comp_cont_diff_within_at ContDiff.comp_contDiffWithinAt
-/

#print ContDiff.comp_contDiffAt /-
theorem ContDiff.comp_contDiffAt {g : F → G} {f : E → F} (x : E) (hg : ContDiff 𝕜 n g)
    (hf : ContDiffAt 𝕜 n f x) : ContDiffAt 𝕜 n (g ∘ f) x :=
  hg.comp_contDiffWithinAt hf
#align cont_diff.comp_cont_diff_at ContDiff.comp_contDiffAt
-/

/-!
### Smoothness of projections
-/


#print contDiff_fst /-
/-- The first projection in a product is `C^∞`. -/
theorem contDiff_fst : ContDiff 𝕜 n (Prod.fst : E × F → E) :=
  IsBoundedLinearMap.contDiff IsBoundedLinearMap.fst
#align cont_diff_fst contDiff_fst
-/

#print ContDiff.fst /-
/-- Postcomposing `f` with `prod.fst` is `C^n` -/
theorem ContDiff.fst {f : E → F × G} (hf : ContDiff 𝕜 n f) : ContDiff 𝕜 n fun x => (f x).1 :=
  contDiff_fst.comp hf
#align cont_diff.fst ContDiff.fst
-/

#print ContDiff.fst' /-
/-- Precomposing `f` with `prod.fst` is `C^n` -/
theorem ContDiff.fst' {f : E → G} (hf : ContDiff 𝕜 n f) : ContDiff 𝕜 n fun x : E × F => f x.1 :=
  hf.comp contDiff_fst
#align cont_diff.fst' ContDiff.fst'
-/

#print contDiffOn_fst /-
/-- The first projection on a domain in a product is `C^∞`. -/
theorem contDiffOn_fst {s : Set (E × F)} : ContDiffOn 𝕜 n (Prod.fst : E × F → E) s :=
  ContDiff.contDiffOn contDiff_fst
#align cont_diff_on_fst contDiffOn_fst
-/

#print ContDiffOn.fst /-
theorem ContDiffOn.fst {f : E → F × G} {s : Set E} (hf : ContDiffOn 𝕜 n f s) :
    ContDiffOn 𝕜 n (fun x => (f x).1) s :=
  contDiff_fst.comp_contDiffOn hf
#align cont_diff_on.fst ContDiffOn.fst
-/

#print contDiffAt_fst /-
/-- The first projection at a point in a product is `C^∞`. -/
theorem contDiffAt_fst {p : E × F} : ContDiffAt 𝕜 n (Prod.fst : E × F → E) p :=
  contDiff_fst.ContDiffAt
#align cont_diff_at_fst contDiffAt_fst
-/

#print ContDiffAt.fst /-
/-- Postcomposing `f` with `prod.fst` is `C^n` at `(x, y)` -/
theorem ContDiffAt.fst {f : E → F × G} {x : E} (hf : ContDiffAt 𝕜 n f x) :
    ContDiffAt 𝕜 n (fun x => (f x).1) x :=
  contDiffAt_fst.comp x hf
#align cont_diff_at.fst ContDiffAt.fst
-/

#print ContDiffAt.fst' /-
/-- Precomposing `f` with `prod.fst` is `C^n` at `(x, y)` -/
theorem ContDiffAt.fst' {f : E → G} {x : E} {y : F} (hf : ContDiffAt 𝕜 n f x) :
    ContDiffAt 𝕜 n (fun x : E × F => f x.1) (x, y) :=
  ContDiffAt.comp (x, y) hf contDiffAt_fst
#align cont_diff_at.fst' ContDiffAt.fst'
-/

#print ContDiffAt.fst'' /-
/-- Precomposing `f` with `prod.fst` is `C^n` at `x : E × F` -/
theorem ContDiffAt.fst'' {f : E → G} {x : E × F} (hf : ContDiffAt 𝕜 n f x.1) :
    ContDiffAt 𝕜 n (fun x : E × F => f x.1) x :=
  hf.comp x contDiffAt_fst
#align cont_diff_at.fst'' ContDiffAt.fst''
-/

#print contDiffWithinAt_fst /-
/-- The first projection within a domain at a point in a product is `C^∞`. -/
theorem contDiffWithinAt_fst {s : Set (E × F)} {p : E × F} :
    ContDiffWithinAt 𝕜 n (Prod.fst : E × F → E) s p :=
  contDiff_fst.ContDiffWithinAt
#align cont_diff_within_at_fst contDiffWithinAt_fst
-/

#print contDiff_snd /-
/-- The second projection in a product is `C^∞`. -/
theorem contDiff_snd : ContDiff 𝕜 n (Prod.snd : E × F → F) :=
  IsBoundedLinearMap.contDiff IsBoundedLinearMap.snd
#align cont_diff_snd contDiff_snd
-/

#print ContDiff.snd /-
/-- Postcomposing `f` with `prod.snd` is `C^n` -/
theorem ContDiff.snd {f : E → F × G} (hf : ContDiff 𝕜 n f) : ContDiff 𝕜 n fun x => (f x).2 :=
  contDiff_snd.comp hf
#align cont_diff.snd ContDiff.snd
-/

#print ContDiff.snd' /-
/-- Precomposing `f` with `prod.snd` is `C^n` -/
theorem ContDiff.snd' {f : F → G} (hf : ContDiff 𝕜 n f) : ContDiff 𝕜 n fun x : E × F => f x.2 :=
  hf.comp contDiff_snd
#align cont_diff.snd' ContDiff.snd'
-/

#print contDiffOn_snd /-
/-- The second projection on a domain in a product is `C^∞`. -/
theorem contDiffOn_snd {s : Set (E × F)} : ContDiffOn 𝕜 n (Prod.snd : E × F → F) s :=
  ContDiff.contDiffOn contDiff_snd
#align cont_diff_on_snd contDiffOn_snd
-/

#print ContDiffOn.snd /-
theorem ContDiffOn.snd {f : E → F × G} {s : Set E} (hf : ContDiffOn 𝕜 n f s) :
    ContDiffOn 𝕜 n (fun x => (f x).2) s :=
  contDiff_snd.comp_contDiffOn hf
#align cont_diff_on.snd ContDiffOn.snd
-/

#print contDiffAt_snd /-
/-- The second projection at a point in a product is `C^∞`. -/
theorem contDiffAt_snd {p : E × F} : ContDiffAt 𝕜 n (Prod.snd : E × F → F) p :=
  contDiff_snd.ContDiffAt
#align cont_diff_at_snd contDiffAt_snd
-/

#print ContDiffAt.snd /-
/-- Postcomposing `f` with `prod.snd` is `C^n` at `x` -/
theorem ContDiffAt.snd {f : E → F × G} {x : E} (hf : ContDiffAt 𝕜 n f x) :
    ContDiffAt 𝕜 n (fun x => (f x).2) x :=
  contDiffAt_snd.comp x hf
#align cont_diff_at.snd ContDiffAt.snd
-/

#print ContDiffAt.snd' /-
/-- Precomposing `f` with `prod.snd` is `C^n` at `(x, y)` -/
theorem ContDiffAt.snd' {f : F → G} {x : E} {y : F} (hf : ContDiffAt 𝕜 n f y) :
    ContDiffAt 𝕜 n (fun x : E × F => f x.2) (x, y) :=
  ContDiffAt.comp (x, y) hf contDiffAt_snd
#align cont_diff_at.snd' ContDiffAt.snd'
-/

#print ContDiffAt.snd'' /-
/-- Precomposing `f` with `prod.snd` is `C^n` at `x : E × F` -/
theorem ContDiffAt.snd'' {f : F → G} {x : E × F} (hf : ContDiffAt 𝕜 n f x.2) :
    ContDiffAt 𝕜 n (fun x : E × F => f x.2) x :=
  hf.comp x contDiffAt_snd
#align cont_diff_at.snd'' ContDiffAt.snd''
-/

#print contDiffWithinAt_snd /-
/-- The second projection within a domain at a point in a product is `C^∞`. -/
theorem contDiffWithinAt_snd {s : Set (E × F)} {p : E × F} :
    ContDiffWithinAt 𝕜 n (Prod.snd : E × F → F) s p :=
  contDiff_snd.ContDiffWithinAt
#align cont_diff_within_at_snd contDiffWithinAt_snd
-/

section NAry

variable {E₁ E₂ E₃ E₄ : Type _}

variable [NormedAddCommGroup E₁] [NormedAddCommGroup E₂] [NormedAddCommGroup E₃]
  [NormedAddCommGroup E₄] [NormedSpace 𝕜 E₁] [NormedSpace 𝕜 E₂] [NormedSpace 𝕜 E₃]
  [NormedSpace 𝕜 E₄]

#print ContDiff.comp₂ /-
theorem ContDiff.comp₂ {g : E₁ × E₂ → G} {f₁ : F → E₁} {f₂ : F → E₂} (hg : ContDiff 𝕜 n g)
    (hf₁ : ContDiff 𝕜 n f₁) (hf₂ : ContDiff 𝕜 n f₂) : ContDiff 𝕜 n fun x => g (f₁ x, f₂ x) :=
  hg.comp <| hf₁.Prod hf₂
#align cont_diff.comp₂ ContDiff.comp₂
-/

#print ContDiff.comp₃ /-
theorem ContDiff.comp₃ {g : E₁ × E₂ × E₃ → G} {f₁ : F → E₁} {f₂ : F → E₂} {f₃ : F → E₃}
    (hg : ContDiff 𝕜 n g) (hf₁ : ContDiff 𝕜 n f₁) (hf₂ : ContDiff 𝕜 n f₂) (hf₃ : ContDiff 𝕜 n f₃) :
    ContDiff 𝕜 n fun x => g (f₁ x, f₂ x, f₃ x) :=
  hg.comp₂ hf₁ <| hf₂.Prod hf₃
#align cont_diff.comp₃ ContDiff.comp₃
-/

#print ContDiff.comp_contDiff_on₂ /-
theorem ContDiff.comp_contDiff_on₂ {g : E₁ × E₂ → G} {f₁ : F → E₁} {f₂ : F → E₂} {s : Set F}
    (hg : ContDiff 𝕜 n g) (hf₁ : ContDiffOn 𝕜 n f₁ s) (hf₂ : ContDiffOn 𝕜 n f₂ s) :
    ContDiffOn 𝕜 n (fun x => g (f₁ x, f₂ x)) s :=
  hg.comp_contDiffOn <| hf₁.Prod hf₂
#align cont_diff.comp_cont_diff_on₂ ContDiff.comp_contDiff_on₂
-/

#print ContDiff.comp_contDiff_on₃ /-
theorem ContDiff.comp_contDiff_on₃ {g : E₁ × E₂ × E₃ → G} {f₁ : F → E₁} {f₂ : F → E₂} {f₃ : F → E₃}
    {s : Set F} (hg : ContDiff 𝕜 n g) (hf₁ : ContDiffOn 𝕜 n f₁ s) (hf₂ : ContDiffOn 𝕜 n f₂ s)
    (hf₃ : ContDiffOn 𝕜 n f₃ s) : ContDiffOn 𝕜 n (fun x => g (f₁ x, f₂ x, f₃ x)) s :=
  hg.comp_contDiff_on₂ hf₁ <| hf₂.Prod hf₃
#align cont_diff.comp_cont_diff_on₃ ContDiff.comp_contDiff_on₃
-/

end NAry

section SpecificBilinearMaps

#print ContDiff.clm_comp /-
theorem ContDiff.clm_comp {g : X → F →L[𝕜] G} {f : X → E →L[𝕜] F} (hg : ContDiff 𝕜 n g)
    (hf : ContDiff 𝕜 n f) : ContDiff 𝕜 n fun x => (g x).comp (f x) :=
  isBoundedBilinearMap_comp.ContDiff.comp₂ hg hf
#align cont_diff.clm_comp ContDiff.clm_comp
-/

#print ContDiffOn.clm_comp /-
theorem ContDiffOn.clm_comp {g : X → F →L[𝕜] G} {f : X → E →L[𝕜] F} {s : Set X}
    (hg : ContDiffOn 𝕜 n g s) (hf : ContDiffOn 𝕜 n f s) :
    ContDiffOn 𝕜 n (fun x => (g x).comp (f x)) s :=
  isBoundedBilinearMap_comp.ContDiff.comp_contDiff_on₂ hg hf
#align cont_diff_on.clm_comp ContDiffOn.clm_comp
-/

#print ContDiff.clm_apply /-
theorem ContDiff.clm_apply {f : E → F →L[𝕜] G} {g : E → F} {n : ℕ∞} (hf : ContDiff 𝕜 n f)
    (hg : ContDiff 𝕜 n g) : ContDiff 𝕜 n fun x => (f x) (g x) :=
  isBoundedBilinearMap_apply.ContDiff.comp₂ hf hg
#align cont_diff.clm_apply ContDiff.clm_apply
-/

#print ContDiffOn.clm_apply /-
theorem ContDiffOn.clm_apply {f : E → F →L[𝕜] G} {g : E → F} {n : ℕ∞} (hf : ContDiffOn 𝕜 n f s)
    (hg : ContDiffOn 𝕜 n g s) : ContDiffOn 𝕜 n (fun x => (f x) (g x)) s :=
  isBoundedBilinearMap_apply.ContDiff.comp_contDiff_on₂ hf hg
#align cont_diff_on.clm_apply ContDiffOn.clm_apply
-/

#print ContDiff.smulRight /-
theorem ContDiff.smulRight {f : E → F →L[𝕜] 𝕜} {g : E → G} {n : ℕ∞} (hf : ContDiff 𝕜 n f)
    (hg : ContDiff 𝕜 n g) : ContDiff 𝕜 n fun x => (f x).smul_right (g x) :=
  (-- giving the following implicit type arguments speeds up elaboration significantly
          @isBoundedBilinearMap_smulRight
          𝕜 _ F _ _ G _ _).ContDiff.comp₂
    hf hg
#align cont_diff.smul_right ContDiff.smulRight
-/

end SpecificBilinearMaps

#print contDiff_prodAssoc /-
/-- The natural equivalence `(E × F) × G ≃ E × (F × G)` is smooth.

Warning: if you think you need this lemma, it is likely that you can simplify your proof by
reformulating the lemma that you're applying next using the tips in
Note [continuity lemma statement]
-/
theorem contDiff_prodAssoc : ContDiff 𝕜 ⊤ <| Equiv.prodAssoc E F G :=
  (LinearIsometryEquiv.prodAssoc 𝕜 E F G).ContDiff
#align cont_diff_prod_assoc contDiff_prodAssoc
-/

#print contDiff_prodAssoc_symm /-
/-- The natural equivalence `E × (F × G) ≃ (E × F) × G` is smooth.

Warning: see remarks attached to `cont_diff_prod_assoc`
-/
theorem contDiff_prodAssoc_symm : ContDiff 𝕜 ⊤ <| (Equiv.prodAssoc E F G).symm :=
  (LinearIsometryEquiv.prodAssoc 𝕜 E F G).symm.ContDiff
#align cont_diff_prod_assoc_symm contDiff_prodAssoc_symm
-/

/-! ### Bundled derivatives are smooth -/


/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ContDiffWithinAt.hasFDerivWithinAt_nhds /-
/-- One direction of `cont_diff_within_at_succ_iff_has_fderiv_within_at`, but where all derivatives
	are taken within the same set. Version for partial derivatives / functions with parameters.
	If `f x` is a `C^n+1` family of functions and `g x` is a `C^n` family of points, then the
  derivative of `f x` at `g x` depends in a `C^n` way on `x`. We give a general version of this fact
  relative to sets which may not have unique derivatives, in the following form.
	If `f : E × F → G` is `C^n+1` at `(x₀, g(x₀))` in `(s ∪ {x₀}) × t ⊆ E × F` and `g : E → F` is
	`C^n` at `x₀` within some set `s ⊆ E`, then there is a function `f' : E → F →L[𝕜] G`
	that is `C^n` at `x₀` within `s` such that for all `x` sufficiently close to `x₀` within
	`s ∪ {x₀}` the function `y ↦ f x y` has derivative `f' x` at `g x` within `t ⊆ F`.
	For convenience, we return an explicit set of `x`'s where this holds that is a subset of
	`s ∪ {x₀}`.
	We need one additional condition, namely that `t` is a neighborhood of `g(x₀)` within `g '' s`.
	-/
theorem ContDiffWithinAt.hasFDerivWithinAt_nhds {f : E → F → G} {g : E → F} {t : Set F} {n : ℕ}
    {x₀ : E} (hf : ContDiffWithinAt 𝕜 (n + 1) (uncurry f) (insert x₀ s ×ˢ t) (x₀, g x₀))
    (hg : ContDiffWithinAt 𝕜 n g s x₀) (hgt : t ∈ 𝓝[g '' s] g x₀) :
    ∃ v ∈ 𝓝[insert x₀ s] x₀,
      v ⊆ insert x₀ s ∧
        ∃ f' : E → F →L[𝕜] G,
          (∀ x ∈ v, HasFDerivWithinAt (f x) (f' x) t (g x)) ∧
            ContDiffWithinAt 𝕜 n (fun x => f' x) s x₀ :=
  by
  have hst : insert x₀ s ×ˢ t ∈ 𝓝[(fun x => (x, g x)) '' s] (x₀, g x₀) :=
    by
    refine' nhdsWithin_mono _ _ (nhdsWithin_prod self_mem_nhdsWithin hgt)
    simp_rw [image_subset_iff, mk_preimage_prod, preimage_id', subset_inter_iff, subset_insert,
      true_and_iff, subset_preimage_image]
  obtain ⟨v, hv, hvs, f', hvf', hf'⟩ := cont_diff_within_at_succ_iff_has_fderiv_within_at'.mp hf
  refine'
    ⟨(fun z => (z, g z)) ⁻¹' v ∩ insert x₀ s, _, inter_subset_right _ _, fun z =>
      (f' (z, g z)).comp (ContinuousLinearMap.inr 𝕜 E F), _, _⟩
  · refine' inter_mem _ self_mem_nhdsWithin
    have := mem_of_mem_nhdsWithin (mem_insert _ _) hv
    refine' mem_nhds_within_insert.mpr ⟨this, _⟩
    refine' (continuous_within_at_id.prod hg.continuous_within_at).preimage_mem_nhdsWithin' _
    rw [← nhdsWithin_le_iff] at hst hv ⊢
    refine' (hst.trans <| nhdsWithin_mono _ <| subset_insert _ _).trans hv
  · intro z hz
    have := hvf' (z, g z) hz.1
    refine' this.comp _ (hasFDerivAt_prod_mk_right _ _).HasFDerivWithinAt _
    exact maps_to'.mpr (image_prod_mk_subset_prod_right hz.2)
  ·
    exact
      (hf'.continuous_linear_map_comp <|
            (ContinuousLinearMap.compL 𝕜 F (E × F) G).flip
              (ContinuousLinearMap.inr 𝕜 E F)).comp_of_mem
        x₀ (cont_diff_within_at_id.prod hg) hst
#align cont_diff_within_at.has_fderiv_within_at_nhds ContDiffWithinAt.hasFDerivWithinAt_nhds
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ContDiffWithinAt.fderivWithin'' /-
/-- The most general lemma stating that `x ↦ fderiv_within 𝕜 (f x) t (g x)` is `C^n`
at a point within a set.
To show that `x ↦ D_yf(x,y)g(x)` (taken within `t`) is `C^m` at `x₀` within `s`, we require that
* `f` is `C^n` at `(x₀, g(x₀))` within `(s ∪ {x₀}) × t` for `n ≥ m+1`.
* `g` is `C^m` at `x₀` within `s`;
* Derivatives are unique at `g(x)` within `t` for `x` sufficiently close to `x₀` within `s ∪ {x₀}`;
* `t` is a neighborhood of `g(x₀)` within `g '' s`; -/
theorem ContDiffWithinAt.fderivWithin'' {f : E → F → G} {g : E → F} {t : Set F} {n : ℕ∞}
    (hf : ContDiffWithinAt 𝕜 n (Function.uncurry f) (insert x₀ s ×ˢ t) (x₀, g x₀))
    (hg : ContDiffWithinAt 𝕜 m g s x₀)
    (ht : ∀ᶠ x in 𝓝[insert x₀ s] x₀, UniqueDiffWithinAt 𝕜 t (g x)) (hmn : m + 1 ≤ n)
    (hgt : t ∈ 𝓝[g '' s] g x₀) :
    ContDiffWithinAt 𝕜 m (fun x => fderivWithin 𝕜 (f x) t (g x)) s x₀ :=
  by
  have :
    ∀ k : ℕ, (k : ℕ∞) ≤ m → ContDiffWithinAt 𝕜 k (fun x => fderivWithin 𝕜 (f x) t (g x)) s x₀ :=
    by
    intro k hkm
    obtain ⟨v, hv, -, f', hvf', hf'⟩ :=
      (hf.of_le <| (add_le_add_right hkm 1).trans hmn).hasFDerivWithinAt_nhds (hg.of_le hkm) hgt
    refine' hf'.congr_of_eventually_eq_insert _
    filter_upwards [hv, ht]
    exact fun y hy h2y => (hvf' y hy).fderivWithin h2y
  induction m using WithTop.recTopCoe
  · obtain rfl := eq_top_iff.mpr hmn
    rw [contDiffWithinAt_top]
    exact fun m => this m le_top
  exact this m le_rfl
#align cont_diff_within_at.fderiv_within'' ContDiffWithinAt.fderivWithin''
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ContDiffWithinAt.fderivWithin' /-
/-- A special case of `cont_diff_within_at.fderiv_within''` where we require that `s ⊆ g⁻¹(t)`. -/
theorem ContDiffWithinAt.fderivWithin' {f : E → F → G} {g : E → F} {t : Set F} {n : ℕ∞}
    (hf : ContDiffWithinAt 𝕜 n (Function.uncurry f) (insert x₀ s ×ˢ t) (x₀, g x₀))
    (hg : ContDiffWithinAt 𝕜 m g s x₀)
    (ht : ∀ᶠ x in 𝓝[insert x₀ s] x₀, UniqueDiffWithinAt 𝕜 t (g x)) (hmn : m + 1 ≤ n)
    (hst : s ⊆ g ⁻¹' t) : ContDiffWithinAt 𝕜 m (fun x => fderivWithin 𝕜 (f x) t (g x)) s x₀ :=
  hf.fderivWithin'' hg ht hmn <| mem_of_superset self_mem_nhdsWithin <| image_subset_iff.mpr hst
#align cont_diff_within_at.fderiv_within' ContDiffWithinAt.fderivWithin'
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ContDiffWithinAt.fderivWithin /-
/-- A special case of `cont_diff_within_at.fderiv_within'` where we require that `x₀ ∈ s` and there
  are unique derivatives everywhere within `t`. -/
theorem ContDiffWithinAt.fderivWithin {f : E → F → G} {g : E → F} {t : Set F} {n : ℕ∞}
    (hf : ContDiffWithinAt 𝕜 n (Function.uncurry f) (s ×ˢ t) (x₀, g x₀))
    (hg : ContDiffWithinAt 𝕜 m g s x₀) (ht : UniqueDiffOn 𝕜 t) (hmn : m + 1 ≤ n) (hx₀ : x₀ ∈ s)
    (hst : s ⊆ g ⁻¹' t) : ContDiffWithinAt 𝕜 m (fun x => fderivWithin 𝕜 (f x) t (g x)) s x₀ :=
  by
  rw [← insert_eq_self.mpr hx₀] at hf 
  refine' hf.fderiv_within' hg _ hmn hst
  rw [insert_eq_self.mpr hx₀]
  exact eventually_of_mem self_mem_nhdsWithin fun x hx => ht _ (hst hx)
#align cont_diff_within_at.fderiv_within ContDiffWithinAt.fderivWithin
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ContDiffWithinAt.fderivWithin_apply /-
/-- `x ↦ fderiv_within 𝕜 (f x) t (g x) (k x)` is smooth at a point within a set. -/
theorem ContDiffWithinAt.fderivWithin_apply {f : E → F → G} {g k : E → F} {t : Set F} {n : ℕ∞}
    (hf : ContDiffWithinAt 𝕜 n (Function.uncurry f) (s ×ˢ t) (x₀, g x₀))
    (hg : ContDiffWithinAt 𝕜 m g s x₀) (hk : ContDiffWithinAt 𝕜 m k s x₀) (ht : UniqueDiffOn 𝕜 t)
    (hmn : m + 1 ≤ n) (hx₀ : x₀ ∈ s) (hst : s ⊆ g ⁻¹' t) :
    ContDiffWithinAt 𝕜 m (fun x => fderivWithin 𝕜 (f x) t (g x) (k x)) s x₀ :=
  (contDiff_fst.clm_apply contDiff_snd).ContDiffAt.comp_contDiffWithinAt x₀
    ((hf.fderivWithin hg ht hmn hx₀ hst).Prod hk)
#align cont_diff_within_at.fderiv_within_apply ContDiffWithinAt.fderivWithin_apply
-/

#print ContDiffWithinAt.fderivWithin_right /-
/-- `fderiv_within 𝕜 f s` is smooth at `x₀` within `s`. -/
theorem ContDiffWithinAt.fderivWithin_right (hf : ContDiffWithinAt 𝕜 n f s x₀)
    (hs : UniqueDiffOn 𝕜 s) (hmn : (m + 1 : ℕ∞) ≤ n) (hx₀s : x₀ ∈ s) :
    ContDiffWithinAt 𝕜 m (fderivWithin 𝕜 f s) s x₀ :=
  ContDiffWithinAt.fderivWithin
    (ContDiffWithinAt.comp (x₀, x₀) hf contDiffWithinAt_snd <| prod_subset_preimage_snd s s)
    contDiffWithinAt_id hs hmn hx₀s (by rw [preimage_id'])
#align cont_diff_within_at.fderiv_within_right ContDiffWithinAt.fderivWithin_right
-/

#print ContDiffAt.fderiv /-
/-- `x ↦ fderiv 𝕜 (f x) (g x)` is smooth at `x₀`. -/
theorem ContDiffAt.fderiv {f : E → F → G} {g : E → F} {n : ℕ∞}
    (hf : ContDiffAt 𝕜 n (Function.uncurry f) (x₀, g x₀)) (hg : ContDiffAt 𝕜 m g x₀)
    (hmn : m + 1 ≤ n) : ContDiffAt 𝕜 m (fun x => fderiv 𝕜 (f x) (g x)) x₀ :=
  by
  simp_rw [← fderivWithin_univ]
  refine'
    (ContDiffWithinAt.fderivWithin hf.cont_diff_within_at hg.cont_diff_within_at uniqueDiffOn_univ
          hmn (mem_univ x₀) _).ContDiffAt
      univ_mem
  rw [preimage_univ]
#align cont_diff_at.fderiv ContDiffAt.fderiv
-/

#print ContDiffAt.fderiv_right /-
/-- `fderiv 𝕜 f` is smooth at `x₀`. -/
theorem ContDiffAt.fderiv_right (hf : ContDiffAt 𝕜 n f x₀) (hmn : (m + 1 : ℕ∞) ≤ n) :
    ContDiffAt 𝕜 m (fderiv 𝕜 f) x₀ :=
  ContDiffAt.fderiv (ContDiffAt.comp (x₀, x₀) hf contDiffAt_snd) contDiffAt_id hmn
#align cont_diff_at.fderiv_right ContDiffAt.fderiv_right
-/

#print ContDiff.fderiv /-
/-- `x ↦ fderiv 𝕜 (f x) (g x)` is smooth. -/
theorem ContDiff.fderiv {f : E → F → G} {g : E → F} {n m : ℕ∞}
    (hf : ContDiff 𝕜 m <| Function.uncurry f) (hg : ContDiff 𝕜 n g) (hnm : n + 1 ≤ m) :
    ContDiff 𝕜 n fun x => fderiv 𝕜 (f x) (g x) :=
  contDiff_iff_contDiffAt.mpr fun x => hf.ContDiffAt.fderiv hg.ContDiffAt hnm
#align cont_diff.fderiv ContDiff.fderiv
-/

#print ContDiff.fderiv_right /-
/-- `fderiv 𝕜 f` is smooth. -/
theorem ContDiff.fderiv_right (hf : ContDiff 𝕜 n f) (hmn : (m + 1 : ℕ∞) ≤ n) :
    ContDiff 𝕜 m (fderiv 𝕜 f) :=
  contDiff_iff_contDiffAt.mpr fun x => hf.ContDiffAt.fderiv_right hmn
#align cont_diff.fderiv_right ContDiff.fderiv_right
-/

#print Continuous.fderiv /-
/-- `x ↦ fderiv 𝕜 (f x) (g x)` is continuous. -/
theorem Continuous.fderiv {f : E → F → G} {g : E → F} {n : ℕ∞}
    (hf : ContDiff 𝕜 n <| Function.uncurry f) (hg : Continuous g) (hn : 1 ≤ n) :
    Continuous fun x => fderiv 𝕜 (f x) (g x) :=
  (hf.fderiv (contDiff_zero.mpr hg) hn).Continuous
#align continuous.fderiv Continuous.fderiv
-/

#print ContDiff.fderiv_apply /-
/-- `x ↦ fderiv 𝕜 (f x) (g x) (k x)` is smooth. -/
theorem ContDiff.fderiv_apply {f : E → F → G} {g k : E → F} {n m : ℕ∞}
    (hf : ContDiff 𝕜 m <| Function.uncurry f) (hg : ContDiff 𝕜 n g) (hk : ContDiff 𝕜 n k)
    (hnm : n + 1 ≤ m) : ContDiff 𝕜 n fun x => fderiv 𝕜 (f x) (g x) (k x) :=
  (hf.fderiv hg hnm).clm_apply hk
#align cont_diff.fderiv_apply ContDiff.fderiv_apply
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print contDiffOn_fderivWithin_apply /-
/-- The bundled derivative of a `C^{n+1}` function is `C^n`. -/
theorem contDiffOn_fderivWithin_apply {m n : ℕ∞} {s : Set E} {f : E → F} (hf : ContDiffOn 𝕜 n f s)
    (hs : UniqueDiffOn 𝕜 s) (hmn : m + 1 ≤ n) :
    ContDiffOn 𝕜 m (fun p : E × E => (fderivWithin 𝕜 f s p.1 : E →L[𝕜] F) p.2) (s ×ˢ univ) :=
  ((hf.fderivWithin hs hmn).comp contDiffOn_fst (prod_subset_preimage_fst _ _)).clm_apply
    contDiffOn_snd
#align cont_diff_on_fderiv_within_apply contDiffOn_fderivWithin_apply
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ContDiffOn.continuousOn_fderivWithin_apply /-
/-- If a function is at least `C^1`, its bundled derivative (mapping `(x, v)` to `Df(x) v`) is
continuous. -/
theorem ContDiffOn.continuousOn_fderivWithin_apply (hf : ContDiffOn 𝕜 n f s) (hs : UniqueDiffOn 𝕜 s)
    (hn : 1 ≤ n) :
    ContinuousOn (fun p : E × E => (fderivWithin 𝕜 f s p.1 : E → F) p.2) (s ×ˢ univ) :=
  (contDiffOn_fderivWithin_apply hf hs <| by rwa [zero_add]).ContinuousOn
#align cont_diff_on.continuous_on_fderiv_within_apply ContDiffOn.continuousOn_fderivWithin_apply
-/

#print ContDiff.contDiff_fderiv_apply /-
/-- The bundled derivative of a `C^{n+1}` function is `C^n`. -/
theorem ContDiff.contDiff_fderiv_apply {f : E → F} (hf : ContDiff 𝕜 n f) (hmn : m + 1 ≤ n) :
    ContDiff 𝕜 m fun p : E × E => (fderiv 𝕜 f p.1 : E →L[𝕜] F) p.2 :=
  by
  rw [← contDiffOn_univ] at hf ⊢
  rw [← fderivWithin_univ, ← univ_prod_univ]
  exact contDiffOn_fderivWithin_apply hf uniqueDiffOn_univ hmn
#align cont_diff.cont_diff_fderiv_apply ContDiff.contDiff_fderiv_apply
-/

/-!
### Smoothness of functions `f : E → Π i, F' i`
-/


section Pi

variable {ι ι' : Type _} [Fintype ι] [Fintype ι'] {F' : ι → Type _} [∀ i, NormedAddCommGroup (F' i)]
  [∀ i, NormedSpace 𝕜 (F' i)] {φ : ∀ i, E → F' i} {p' : ∀ i, E → FormalMultilinearSeries 𝕜 E (F' i)}
  {Φ : E → ∀ i, F' i} {P' : E → FormalMultilinearSeries 𝕜 E (∀ i, F' i)}

#print hasFTaylorSeriesUpToOn_pi /-
theorem hasFTaylorSeriesUpToOn_pi :
    HasFTaylorSeriesUpToOn n (fun x i => φ i x)
        (fun x m => ContinuousMultilinearMap.pi fun i => p' i x m) s ↔
      ∀ i, HasFTaylorSeriesUpToOn n (φ i) (p' i) s :=
  by
  set pr := @ContinuousLinearMap.proj 𝕜 _ ι F' _ _ _
  letI : ∀ (m : ℕ) (i : ι), NormedSpace 𝕜 (E[×m]→L[𝕜] F' i) := fun m i => inferInstance
  set L : ∀ m : ℕ, (∀ i, E[×m]→L[𝕜] F' i) ≃ₗᵢ[𝕜] E[×m]→L[𝕜] ∀ i, F' i := fun m =>
    ContinuousMultilinearMap.piₗᵢ _ _
  refine' ⟨fun h i => _, fun h => ⟨fun x hx => _, _, _⟩⟩
  · convert h.continuous_linear_map_comp (pr i)
    ext; rfl
  · ext1 i
    exact (h i).zero_eq x hx
  · intro m hm x hx
    have := hasFDerivWithinAt_pi.2 fun i => (h i).fderivWithin m hm x hx
    convert (L m).HasFDerivAt.comp_hasFDerivWithinAt x this
  · intro m hm
    have := continuousOn_pi.2 fun i => (h i).cont m hm
    convert (L m).Continuous.comp_continuousOn this
#align has_ftaylor_series_up_to_on_pi hasFTaylorSeriesUpToOn_pi
-/

#print hasFTaylorSeriesUpToOn_pi' /-
@[simp]
theorem hasFTaylorSeriesUpToOn_pi' :
    HasFTaylorSeriesUpToOn n Φ P' s ↔
      ∀ i,
        HasFTaylorSeriesUpToOn n (fun x => Φ x i)
          (fun x m =>
            (@ContinuousLinearMap.proj 𝕜 _ ι F' _ _ _ i).compContinuousMultilinearMap (P' x m))
          s :=
  by convert hasFTaylorSeriesUpToOn_pi; ext; rfl
#align has_ftaylor_series_up_to_on_pi' hasFTaylorSeriesUpToOn_pi'
-/

#print contDiffWithinAt_pi /-
theorem contDiffWithinAt_pi :
    ContDiffWithinAt 𝕜 n Φ s x ↔ ∀ i, ContDiffWithinAt 𝕜 n (fun x => Φ x i) s x :=
  by
  set pr := @ContinuousLinearMap.proj 𝕜 _ ι F' _ _ _
  refine' ⟨fun h i => h.continuousLinearMap_comp (pr i), fun h m hm => _⟩
  choose u hux p hp using fun i => h i m hm
  exact
    ⟨⋂ i, u i, Filter.iInter_mem.2 hux, _,
      hasFTaylorSeriesUpToOn_pi.2 fun i => (hp i).mono <| Inter_subset _ _⟩
#align cont_diff_within_at_pi contDiffWithinAt_pi
-/

#print contDiffOn_pi /-
theorem contDiffOn_pi : ContDiffOn 𝕜 n Φ s ↔ ∀ i, ContDiffOn 𝕜 n (fun x => Φ x i) s :=
  ⟨fun h i x hx => contDiffWithinAt_pi.1 (h x hx) _, fun h x hx =>
    contDiffWithinAt_pi.2 fun i => h i x hx⟩
#align cont_diff_on_pi contDiffOn_pi
-/

#print contDiffAt_pi /-
theorem contDiffAt_pi : ContDiffAt 𝕜 n Φ x ↔ ∀ i, ContDiffAt 𝕜 n (fun x => Φ x i) x :=
  contDiffWithinAt_pi
#align cont_diff_at_pi contDiffAt_pi
-/

#print contDiff_pi /-
theorem contDiff_pi : ContDiff 𝕜 n Φ ↔ ∀ i, ContDiff 𝕜 n fun x => Φ x i := by
  simp only [← contDiffOn_univ, contDiffOn_pi]
#align cont_diff_pi contDiff_pi
-/

variable (𝕜 E)

#print contDiff_apply /-
theorem contDiff_apply (i : ι) : ContDiff 𝕜 n fun f : ι → E => f i :=
  contDiff_pi.mp contDiff_id i
#align cont_diff_apply contDiff_apply
-/

#print contDiff_apply_apply /-
theorem contDiff_apply_apply (i : ι) (j : ι') : ContDiff 𝕜 n fun f : ι → ι' → E => f i j :=
  contDiff_pi.mp (contDiff_apply 𝕜 (ι' → E) i) j
#align cont_diff_apply_apply contDiff_apply_apply
-/

variable {𝕜 E}

end Pi

/-! ### Sum of two functions -/


section Add

#print contDiff_add /-
-- The sum is smooth.
theorem contDiff_add : ContDiff 𝕜 n fun p : F × F => p.1 + p.2 :=
  (IsBoundedLinearMap.fst.add IsBoundedLinearMap.snd).ContDiff
#align cont_diff_add contDiff_add
-/

#print ContDiffWithinAt.add /-
/-- The sum of two `C^n` functions within a set at a point is `C^n` within this set
at this point. -/
theorem ContDiffWithinAt.add {s : Set E} {f g : E → F} (hf : ContDiffWithinAt 𝕜 n f s x)
    (hg : ContDiffWithinAt 𝕜 n g s x) : ContDiffWithinAt 𝕜 n (fun x => f x + g x) s x :=
  contDiff_add.ContDiffWithinAt.comp x (hf.Prod hg) subset_preimage_univ
#align cont_diff_within_at.add ContDiffWithinAt.add
-/

#print ContDiffAt.add /-
/-- The sum of two `C^n` functions at a point is `C^n` at this point. -/
theorem ContDiffAt.add {f g : E → F} (hf : ContDiffAt 𝕜 n f x) (hg : ContDiffAt 𝕜 n g x) :
    ContDiffAt 𝕜 n (fun x => f x + g x) x := by
  rw [← contDiffWithinAt_univ] at * <;> exact hf.add hg
#align cont_diff_at.add ContDiffAt.add
-/

#print ContDiff.add /-
/-- The sum of two `C^n`functions is `C^n`. -/
theorem ContDiff.add {f g : E → F} (hf : ContDiff 𝕜 n f) (hg : ContDiff 𝕜 n g) :
    ContDiff 𝕜 n fun x => f x + g x :=
  contDiff_add.comp (hf.Prod hg)
#align cont_diff.add ContDiff.add
-/

#print ContDiffOn.add /-
/-- The sum of two `C^n` functions on a domain is `C^n`. -/
theorem ContDiffOn.add {s : Set E} {f g : E → F} (hf : ContDiffOn 𝕜 n f s)
    (hg : ContDiffOn 𝕜 n g s) : ContDiffOn 𝕜 n (fun x => f x + g x) s := fun x hx =>
  (hf x hx).add (hg x hx)
#align cont_diff_on.add ContDiffOn.add
-/

variable {i : ℕ}

#print iteratedFDerivWithin_add_apply /-
/-- The iterated derivative of the sum of two functions is the sum of the iterated derivatives.
See also `iterated_fderiv_within_add_apply'`, which uses the spelling `(λ x, f x + g x)`
instead of `f + g`. -/
theorem iteratedFDerivWithin_add_apply {f g : E → F} (hf : ContDiffOn 𝕜 i f s)
    (hg : ContDiffOn 𝕜 i g s) (hu : UniqueDiffOn 𝕜 s) (hx : x ∈ s) :
    iteratedFDerivWithin 𝕜 i (f + g) s x =
      iteratedFDerivWithin 𝕜 i f s x + iteratedFDerivWithin 𝕜 i g s x :=
  by
  induction' i with i hi generalizing x
  · ext h; simp
  · ext h
    have hi' : (i : ℕ∞) < i + 1 := with_top.coe_lt_coe.mpr (Nat.lt_succ_self _)
    have hdf : DifferentiableOn 𝕜 (iteratedFDerivWithin 𝕜 i f s) s :=
      hf.differentiable_on_iterated_fderiv_within hi' hu
    have hdg : DifferentiableOn 𝕜 (iteratedFDerivWithin 𝕜 i g s) s :=
      hg.differentiable_on_iterated_fderiv_within hi' hu
    have hcdf : ContDiffOn 𝕜 i f s := hf.of_le hi'.le
    have hcdg : ContDiffOn 𝕜 i g s := hg.of_le hi'.le
    calc
      iteratedFDerivWithin 𝕜 (i + 1) (f + g) s x h =
          fderivWithin 𝕜 (iteratedFDerivWithin 𝕜 i (f + g) s) s x (h 0) (Fin.tail h) :=
        rfl
      _ =
          fderivWithin 𝕜 (iteratedFDerivWithin 𝕜 i f s + iteratedFDerivWithin 𝕜 i g s) s x (h 0)
            (Fin.tail h) :=
        by rw [fderivWithin_congr' (fun _ => hi hcdf hcdg) hx]; rfl
      _ =
          (fderivWithin 𝕜 (iteratedFDerivWithin 𝕜 i f s) s +
              fderivWithin 𝕜 (iteratedFDerivWithin 𝕜 i g s) s)
            x (h 0) (Fin.tail h) :=
        by rw [Pi.add_def, fderivWithin_add (hu x hx) (hdf x hx) (hdg x hx)]; rfl
      _ = (iteratedFDerivWithin 𝕜 (i + 1) f s + iteratedFDerivWithin 𝕜 (i + 1) g s) x h := rfl
#align iterated_fderiv_within_add_apply iteratedFDerivWithin_add_apply
-/

#print iteratedFDerivWithin_add_apply' /-
/-- The iterated derivative of the sum of two functions is the sum of the iterated derivatives.
This is the same as `iterated_fderiv_within_add_apply`, but using the spelling `(λ x, f x + g x)`
instead of `f + g`, which can be handy for some rewrites.
TODO: use one form consistently. -/
theorem iteratedFDerivWithin_add_apply' {f g : E → F} (hf : ContDiffOn 𝕜 i f s)
    (hg : ContDiffOn 𝕜 i g s) (hu : UniqueDiffOn 𝕜 s) (hx : x ∈ s) :
    iteratedFDerivWithin 𝕜 i (fun x => f x + g x) s x =
      iteratedFDerivWithin 𝕜 i f s x + iteratedFDerivWithin 𝕜 i g s x :=
  iteratedFDerivWithin_add_apply hf hg hu hx
#align iterated_fderiv_within_add_apply' iteratedFDerivWithin_add_apply'
-/

#print iteratedFDeriv_add_apply /-
theorem iteratedFDeriv_add_apply {i : ℕ} {f g : E → F} (hf : ContDiff 𝕜 i f) (hg : ContDiff 𝕜 i g) :
    iteratedFDeriv 𝕜 i (f + g) x = iteratedFDeriv 𝕜 i f x + iteratedFDeriv 𝕜 i g x :=
  by
  simp_rw [← contDiffOn_univ, ← iteratedFDerivWithin_univ] at hf hg ⊢
  exact iteratedFDerivWithin_add_apply hf hg uniqueDiffOn_univ (Set.mem_univ _)
#align iterated_fderiv_add_apply iteratedFDeriv_add_apply
-/

#print iteratedFDeriv_add_apply' /-
theorem iteratedFDeriv_add_apply' {i : ℕ} {f g : E → F} (hf : ContDiff 𝕜 i f)
    (hg : ContDiff 𝕜 i g) :
    iteratedFDeriv 𝕜 i (fun x => f x + g x) x = iteratedFDeriv 𝕜 i f x + iteratedFDeriv 𝕜 i g x :=
  iteratedFDeriv_add_apply hf hg
#align iterated_fderiv_add_apply' iteratedFDeriv_add_apply'
-/

end Add

/-! ### Negative -/


section Neg

#print contDiff_neg /-
-- The negative is smooth.
theorem contDiff_neg : ContDiff 𝕜 n fun p : F => -p :=
  IsBoundedLinearMap.id.neg.ContDiff
#align cont_diff_neg contDiff_neg
-/

#print ContDiffWithinAt.neg /-
/-- The negative of a `C^n` function within a domain at a point is `C^n` within this domain at
this point. -/
theorem ContDiffWithinAt.neg {s : Set E} {f : E → F} (hf : ContDiffWithinAt 𝕜 n f s x) :
    ContDiffWithinAt 𝕜 n (fun x => -f x) s x :=
  contDiff_neg.ContDiffWithinAt.comp x hf subset_preimage_univ
#align cont_diff_within_at.neg ContDiffWithinAt.neg
-/

#print ContDiffAt.neg /-
/-- The negative of a `C^n` function at a point is `C^n` at this point. -/
theorem ContDiffAt.neg {f : E → F} (hf : ContDiffAt 𝕜 n f x) : ContDiffAt 𝕜 n (fun x => -f x) x :=
  by rw [← contDiffWithinAt_univ] at * <;> exact hf.neg
#align cont_diff_at.neg ContDiffAt.neg
-/

#print ContDiff.neg /-
/-- The negative of a `C^n`function is `C^n`. -/
theorem ContDiff.neg {f : E → F} (hf : ContDiff 𝕜 n f) : ContDiff 𝕜 n fun x => -f x :=
  contDiff_neg.comp hf
#align cont_diff.neg ContDiff.neg
-/

#print ContDiffOn.neg /-
/-- The negative of a `C^n` function on a domain is `C^n`. -/
theorem ContDiffOn.neg {s : Set E} {f : E → F} (hf : ContDiffOn 𝕜 n f s) :
    ContDiffOn 𝕜 n (fun x => -f x) s := fun x hx => (hf x hx).neg
#align cont_diff_on.neg ContDiffOn.neg
-/

variable {i : ℕ}

#print iteratedFDerivWithin_neg_apply /-
theorem iteratedFDerivWithin_neg_apply {f : E → F} (hu : UniqueDiffOn 𝕜 s) (hx : x ∈ s) :
    iteratedFDerivWithin 𝕜 i (-f) s x = -iteratedFDerivWithin 𝕜 i f s x :=
  by
  induction' i with i hi generalizing x
  · ext h; simp
  · ext h
    have hi' : (i : ℕ∞) < i + 1 := with_top.coe_lt_coe.mpr (Nat.lt_succ_self _)
    calc
      iteratedFDerivWithin 𝕜 (i + 1) (-f) s x h =
          fderivWithin 𝕜 (iteratedFDerivWithin 𝕜 i (-f) s) s x (h 0) (Fin.tail h) :=
        rfl
      _ = fderivWithin 𝕜 (-iteratedFDerivWithin 𝕜 i f s) s x (h 0) (Fin.tail h) := by
        rw [fderivWithin_congr' (@hi) hx]; rfl
      _ = -(fderivWithin 𝕜 (iteratedFDerivWithin 𝕜 i f s) s) x (h 0) (Fin.tail h) := by
        rw [Pi.neg_def, fderivWithin_neg (hu x hx)]; rfl
      _ = -(iteratedFDerivWithin 𝕜 (i + 1) f s) x h := rfl
#align iterated_fderiv_within_neg_apply iteratedFDerivWithin_neg_apply
-/

#print iteratedFDeriv_neg_apply /-
theorem iteratedFDeriv_neg_apply {i : ℕ} {f : E → F} :
    iteratedFDeriv 𝕜 i (-f) x = -iteratedFDeriv 𝕜 i f x :=
  by
  simp_rw [← iteratedFDerivWithin_univ]
  exact iteratedFDerivWithin_neg_apply uniqueDiffOn_univ (Set.mem_univ _)
#align iterated_fderiv_neg_apply iteratedFDeriv_neg_apply
-/

end Neg

/-! ### Subtraction -/


#print ContDiffWithinAt.sub /-
/-- The difference of two `C^n` functions within a set at a point is `C^n` within this set
at this point. -/
theorem ContDiffWithinAt.sub {s : Set E} {f g : E → F} (hf : ContDiffWithinAt 𝕜 n f s x)
    (hg : ContDiffWithinAt 𝕜 n g s x) : ContDiffWithinAt 𝕜 n (fun x => f x - g x) s x := by
  simpa only [sub_eq_add_neg] using hf.add hg.neg
#align cont_diff_within_at.sub ContDiffWithinAt.sub
-/

#print ContDiffAt.sub /-
/-- The difference of two `C^n` functions at a point is `C^n` at this point. -/
theorem ContDiffAt.sub {f g : E → F} (hf : ContDiffAt 𝕜 n f x) (hg : ContDiffAt 𝕜 n g x) :
    ContDiffAt 𝕜 n (fun x => f x - g x) x := by simpa only [sub_eq_add_neg] using hf.add hg.neg
#align cont_diff_at.sub ContDiffAt.sub
-/

#print ContDiffOn.sub /-
/-- The difference of two `C^n` functions on a domain is `C^n`. -/
theorem ContDiffOn.sub {s : Set E} {f g : E → F} (hf : ContDiffOn 𝕜 n f s)
    (hg : ContDiffOn 𝕜 n g s) : ContDiffOn 𝕜 n (fun x => f x - g x) s := by
  simpa only [sub_eq_add_neg] using hf.add hg.neg
#align cont_diff_on.sub ContDiffOn.sub
-/

#print ContDiff.sub /-
/-- The difference of two `C^n` functions is `C^n`. -/
theorem ContDiff.sub {f g : E → F} (hf : ContDiff 𝕜 n f) (hg : ContDiff 𝕜 n g) :
    ContDiff 𝕜 n fun x => f x - g x := by simpa only [sub_eq_add_neg] using hf.add hg.neg
#align cont_diff.sub ContDiff.sub
-/

/-! ### Sum of finitely many functions -/


#print ContDiffWithinAt.sum /-
theorem ContDiffWithinAt.sum {ι : Type _} {f : ι → E → F} {s : Finset ι} {t : Set E} {x : E}
    (h : ∀ i ∈ s, ContDiffWithinAt 𝕜 n (fun x => f i x) t x) :
    ContDiffWithinAt 𝕜 n (fun x => ∑ i in s, f i x) t x := by
  classical
  induction' s using Finset.induction_on with i s is IH
  · simp [contDiffWithinAt_const]
  · simp only [is, Finset.sum_insert, not_false_iff]
    exact (h _ (Finset.mem_insert_self i s)).add (IH fun j hj => h _ (Finset.mem_insert_of_mem hj))
#align cont_diff_within_at.sum ContDiffWithinAt.sum
-/

#print ContDiffAt.sum /-
theorem ContDiffAt.sum {ι : Type _} {f : ι → E → F} {s : Finset ι} {x : E}
    (h : ∀ i ∈ s, ContDiffAt 𝕜 n (fun x => f i x) x) :
    ContDiffAt 𝕜 n (fun x => ∑ i in s, f i x) x := by
  rw [← contDiffWithinAt_univ] at * <;> exact ContDiffWithinAt.sum h
#align cont_diff_at.sum ContDiffAt.sum
-/

#print ContDiffOn.sum /-
theorem ContDiffOn.sum {ι : Type _} {f : ι → E → F} {s : Finset ι} {t : Set E}
    (h : ∀ i ∈ s, ContDiffOn 𝕜 n (fun x => f i x) t) :
    ContDiffOn 𝕜 n (fun x => ∑ i in s, f i x) t := fun x hx =>
  ContDiffWithinAt.sum fun i hi => h i hi x hx
#align cont_diff_on.sum ContDiffOn.sum
-/

#print ContDiff.sum /-
theorem ContDiff.sum {ι : Type _} {f : ι → E → F} {s : Finset ι}
    (h : ∀ i ∈ s, ContDiff 𝕜 n fun x => f i x) : ContDiff 𝕜 n fun x => ∑ i in s, f i x := by
  simp only [← contDiffOn_univ] at * <;> exact ContDiffOn.sum h
#align cont_diff.sum ContDiff.sum
-/

/-! ### Product of two functions -/


section MulProd

variable {𝔸 𝔸' ι 𝕜' : Type _} [NormedRing 𝔸] [NormedAlgebra 𝕜 𝔸] [NormedCommRing 𝔸']
  [NormedAlgebra 𝕜 𝔸'] [NormedField 𝕜'] [NormedAlgebra 𝕜 𝕜']

#print contDiff_mul /-
-- The product is smooth.
theorem contDiff_mul : ContDiff 𝕜 n fun p : 𝔸 × 𝔸 => p.1 * p.2 :=
  (ContinuousLinearMap.mul 𝕜 𝔸).IsBoundedBilinearMap.ContDiff
#align cont_diff_mul contDiff_mul
-/

#print ContDiffWithinAt.mul /-
/-- The product of two `C^n` functions within a set at a point is `C^n` within this set
at this point. -/
theorem ContDiffWithinAt.mul {s : Set E} {f g : E → 𝔸} (hf : ContDiffWithinAt 𝕜 n f s x)
    (hg : ContDiffWithinAt 𝕜 n g s x) : ContDiffWithinAt 𝕜 n (fun x => f x * g x) s x :=
  contDiff_mul.comp_contDiffWithinAt (hf.Prod hg)
#align cont_diff_within_at.mul ContDiffWithinAt.mul
-/

#print ContDiffAt.mul /-
/-- The product of two `C^n` functions at a point is `C^n` at this point. -/
theorem ContDiffAt.mul {f g : E → 𝔸} (hf : ContDiffAt 𝕜 n f x) (hg : ContDiffAt 𝕜 n g x) :
    ContDiffAt 𝕜 n (fun x => f x * g x) x :=
  hf.mul hg
#align cont_diff_at.mul ContDiffAt.mul
-/

#print ContDiffOn.mul /-
/-- The product of two `C^n` functions on a domain is `C^n`. -/
theorem ContDiffOn.mul {f g : E → 𝔸} (hf : ContDiffOn 𝕜 n f s) (hg : ContDiffOn 𝕜 n g s) :
    ContDiffOn 𝕜 n (fun x => f x * g x) s := fun x hx => (hf x hx).mul (hg x hx)
#align cont_diff_on.mul ContDiffOn.mul
-/

#print ContDiff.mul /-
/-- The product of two `C^n`functions is `C^n`. -/
theorem ContDiff.mul {f g : E → 𝔸} (hf : ContDiff 𝕜 n f) (hg : ContDiff 𝕜 n g) :
    ContDiff 𝕜 n fun x => f x * g x :=
  contDiff_mul.comp (hf.Prod hg)
#align cont_diff.mul ContDiff.mul
-/

#print contDiffWithinAt_prod' /-
theorem contDiffWithinAt_prod' {t : Finset ι} {f : ι → E → 𝔸'}
    (h : ∀ i ∈ t, ContDiffWithinAt 𝕜 n (f i) s x) : ContDiffWithinAt 𝕜 n (∏ i in t, f i) s x :=
  Finset.prod_induction f (fun f => ContDiffWithinAt 𝕜 n f s x) (fun _ _ => ContDiffWithinAt.mul)
    (@contDiffWithinAt_const _ _ _ _ _ _ _ _ _ _ _ 1) h
#align cont_diff_within_at_prod' contDiffWithinAt_prod'
-/

#print contDiffWithinAt_prod /-
theorem contDiffWithinAt_prod {t : Finset ι} {f : ι → E → 𝔸'}
    (h : ∀ i ∈ t, ContDiffWithinAt 𝕜 n (f i) s x) :
    ContDiffWithinAt 𝕜 n (fun y => ∏ i in t, f i y) s x := by
  simpa only [← Finset.prod_apply] using contDiffWithinAt_prod' h
#align cont_diff_within_at_prod contDiffWithinAt_prod
-/

#print contDiffAt_prod' /-
theorem contDiffAt_prod' {t : Finset ι} {f : ι → E → 𝔸'} (h : ∀ i ∈ t, ContDiffAt 𝕜 n (f i) x) :
    ContDiffAt 𝕜 n (∏ i in t, f i) x :=
  contDiffWithinAt_prod' h
#align cont_diff_at_prod' contDiffAt_prod'
-/

#print contDiffAt_prod /-
theorem contDiffAt_prod {t : Finset ι} {f : ι → E → 𝔸'} (h : ∀ i ∈ t, ContDiffAt 𝕜 n (f i) x) :
    ContDiffAt 𝕜 n (fun y => ∏ i in t, f i y) x :=
  contDiffWithinAt_prod h
#align cont_diff_at_prod contDiffAt_prod
-/

#print contDiffOn_prod' /-
theorem contDiffOn_prod' {t : Finset ι} {f : ι → E → 𝔸'} (h : ∀ i ∈ t, ContDiffOn 𝕜 n (f i) s) :
    ContDiffOn 𝕜 n (∏ i in t, f i) s := fun x hx => contDiffWithinAt_prod' fun i hi => h i hi x hx
#align cont_diff_on_prod' contDiffOn_prod'
-/

#print contDiffOn_prod /-
theorem contDiffOn_prod {t : Finset ι} {f : ι → E → 𝔸'} (h : ∀ i ∈ t, ContDiffOn 𝕜 n (f i) s) :
    ContDiffOn 𝕜 n (fun y => ∏ i in t, f i y) s := fun x hx =>
  contDiffWithinAt_prod fun i hi => h i hi x hx
#align cont_diff_on_prod contDiffOn_prod
-/

#print contDiff_prod' /-
theorem contDiff_prod' {t : Finset ι} {f : ι → E → 𝔸'} (h : ∀ i ∈ t, ContDiff 𝕜 n (f i)) :
    ContDiff 𝕜 n (∏ i in t, f i) :=
  contDiff_iff_contDiffAt.mpr fun x => contDiffAt_prod' fun i hi => (h i hi).ContDiffAt
#align cont_diff_prod' contDiff_prod'
-/

#print contDiff_prod /-
theorem contDiff_prod {t : Finset ι} {f : ι → E → 𝔸'} (h : ∀ i ∈ t, ContDiff 𝕜 n (f i)) :
    ContDiff 𝕜 n fun y => ∏ i in t, f i y :=
  contDiff_iff_contDiffAt.mpr fun x => contDiffAt_prod fun i hi => (h i hi).ContDiffAt
#align cont_diff_prod contDiff_prod
-/

#print ContDiff.pow /-
theorem ContDiff.pow {f : E → 𝔸} (hf : ContDiff 𝕜 n f) : ∀ m : ℕ, ContDiff 𝕜 n fun x => f x ^ m
  | 0 => by simpa using contDiff_const
  | m + 1 => by simpa [pow_succ] using hf.mul (ContDiff.pow m)
#align cont_diff.pow ContDiff.pow
-/

#print ContDiffWithinAt.pow /-
theorem ContDiffWithinAt.pow {f : E → 𝔸} (hf : ContDiffWithinAt 𝕜 n f s x) (m : ℕ) :
    ContDiffWithinAt 𝕜 n (fun y => f y ^ m) s x :=
  (contDiff_id.pow m).comp_contDiffWithinAt hf
#align cont_diff_within_at.pow ContDiffWithinAt.pow
-/

#print ContDiffAt.pow /-
theorem ContDiffAt.pow {f : E → 𝔸} (hf : ContDiffAt 𝕜 n f x) (m : ℕ) :
    ContDiffAt 𝕜 n (fun y => f y ^ m) x :=
  hf.pow m
#align cont_diff_at.pow ContDiffAt.pow
-/

#print ContDiffOn.pow /-
theorem ContDiffOn.pow {f : E → 𝔸} (hf : ContDiffOn 𝕜 n f s) (m : ℕ) :
    ContDiffOn 𝕜 n (fun y => f y ^ m) s := fun y hy => (hf y hy).pow m
#align cont_diff_on.pow ContDiffOn.pow
-/

#print ContDiffWithinAt.div_const /-
theorem ContDiffWithinAt.div_const {f : E → 𝕜'} {n} (hf : ContDiffWithinAt 𝕜 n f s x) (c : 𝕜') :
    ContDiffWithinAt 𝕜 n (fun x => f x / c) s x := by
  simpa only [div_eq_mul_inv] using hf.mul contDiffWithinAt_const
#align cont_diff_within_at.div_const ContDiffWithinAt.div_const
-/

#print ContDiffAt.div_const /-
theorem ContDiffAt.div_const {f : E → 𝕜'} {n} (hf : ContDiffAt 𝕜 n f x) (c : 𝕜') :
    ContDiffAt 𝕜 n (fun x => f x / c) x :=
  hf.div_const c
#align cont_diff_at.div_const ContDiffAt.div_const
-/

#print ContDiffOn.div_const /-
theorem ContDiffOn.div_const {f : E → 𝕜'} {n} (hf : ContDiffOn 𝕜 n f s) (c : 𝕜') :
    ContDiffOn 𝕜 n (fun x => f x / c) s := fun x hx => (hf x hx).div_const c
#align cont_diff_on.div_const ContDiffOn.div_const
-/

#print ContDiff.div_const /-
theorem ContDiff.div_const {f : E → 𝕜'} {n} (hf : ContDiff 𝕜 n f) (c : 𝕜') :
    ContDiff 𝕜 n fun x => f x / c := by simpa only [div_eq_mul_inv] using hf.mul contDiff_const
#align cont_diff.div_const ContDiff.div_const
-/

end MulProd

/-! ### Scalar multiplication -/


section Smul

#print contDiff_smul /-
-- The scalar multiplication is smooth.
theorem contDiff_smul : ContDiff 𝕜 n fun p : 𝕜 × F => p.1 • p.2 :=
  isBoundedBilinearMap_smul.ContDiff
#align cont_diff_smul contDiff_smul
-/

#print ContDiffWithinAt.smul /-
/-- The scalar multiplication of two `C^n` functions within a set at a point is `C^n` within this
set at this point. -/
theorem ContDiffWithinAt.smul {s : Set E} {f : E → 𝕜} {g : E → F} (hf : ContDiffWithinAt 𝕜 n f s x)
    (hg : ContDiffWithinAt 𝕜 n g s x) : ContDiffWithinAt 𝕜 n (fun x => f x • g x) s x :=
  contDiff_smul.ContDiffWithinAt.comp x (hf.Prod hg) subset_preimage_univ
#align cont_diff_within_at.smul ContDiffWithinAt.smul
-/

#print ContDiffAt.smul /-
/-- The scalar multiplication of two `C^n` functions at a point is `C^n` at this point. -/
theorem ContDiffAt.smul {f : E → 𝕜} {g : E → F} (hf : ContDiffAt 𝕜 n f x)
    (hg : ContDiffAt 𝕜 n g x) : ContDiffAt 𝕜 n (fun x => f x • g x) x := by
  rw [← contDiffWithinAt_univ] at * <;> exact hf.smul hg
#align cont_diff_at.smul ContDiffAt.smul
-/

#print ContDiff.smul /-
/-- The scalar multiplication of two `C^n` functions is `C^n`. -/
theorem ContDiff.smul {f : E → 𝕜} {g : E → F} (hf : ContDiff 𝕜 n f) (hg : ContDiff 𝕜 n g) :
    ContDiff 𝕜 n fun x => f x • g x :=
  contDiff_smul.comp (hf.Prod hg)
#align cont_diff.smul ContDiff.smul
-/

#print ContDiffOn.smul /-
/-- The scalar multiplication of two `C^n` functions on a domain is `C^n`. -/
theorem ContDiffOn.smul {s : Set E} {f : E → 𝕜} {g : E → F} (hf : ContDiffOn 𝕜 n f s)
    (hg : ContDiffOn 𝕜 n g s) : ContDiffOn 𝕜 n (fun x => f x • g x) s := fun x hx =>
  (hf x hx).smul (hg x hx)
#align cont_diff_on.smul ContDiffOn.smul
-/

end Smul

/-! ### Constant scalar multiplication -/


section ConstSmul

variable {R : Type _} [Semiring R] [Module R F] [SMulCommClass 𝕜 R F]

variable [ContinuousConstSMul R F]

#print contDiff_const_smul /-
-- The scalar multiplication with a constant is smooth.
theorem contDiff_const_smul (c : R) : ContDiff 𝕜 n fun p : F => c • p :=
  (c • ContinuousLinearMap.id 𝕜 F).ContDiff
#align cont_diff_const_smul contDiff_const_smul
-/

#print ContDiffWithinAt.const_smul /-
/-- The scalar multiplication of a constant and a `C^n` function within a set at a point is `C^n`
within this set at this point. -/
theorem ContDiffWithinAt.const_smul {s : Set E} {f : E → F} {x : E} (c : R)
    (hf : ContDiffWithinAt 𝕜 n f s x) : ContDiffWithinAt 𝕜 n (fun y => c • f y) s x :=
  (contDiff_const_smul c).ContDiffAt.comp_contDiffWithinAt x hf
#align cont_diff_within_at.const_smul ContDiffWithinAt.const_smul
-/

#print ContDiffAt.const_smul /-
/-- The scalar multiplication of a constant and a `C^n` function at a point is `C^n` at this
point. -/
theorem ContDiffAt.const_smul {f : E → F} {x : E} (c : R) (hf : ContDiffAt 𝕜 n f x) :
    ContDiffAt 𝕜 n (fun y => c • f y) x := by
  rw [← contDiffWithinAt_univ] at * <;> exact hf.const_smul c
#align cont_diff_at.const_smul ContDiffAt.const_smul
-/

#print ContDiff.const_smul /-
/-- The scalar multiplication of a constant and a `C^n` function is `C^n`. -/
theorem ContDiff.const_smul {f : E → F} (c : R) (hf : ContDiff 𝕜 n f) :
    ContDiff 𝕜 n fun y => c • f y :=
  (contDiff_const_smul c).comp hf
#align cont_diff.const_smul ContDiff.const_smul
-/

#print ContDiffOn.const_smul /-
/-- The scalar multiplication of a constant and a `C^n` on a domain is `C^n`. -/
theorem ContDiffOn.const_smul {s : Set E} {f : E → F} (c : R) (hf : ContDiffOn 𝕜 n f s) :
    ContDiffOn 𝕜 n (fun y => c • f y) s := fun x hx => (hf x hx).const_smul c
#align cont_diff_on.const_smul ContDiffOn.const_smul
-/

variable {i : ℕ} {a : R}

#print iteratedFDerivWithin_const_smul_apply /-
theorem iteratedFDerivWithin_const_smul_apply (hf : ContDiffOn 𝕜 i f s) (hu : UniqueDiffOn 𝕜 s)
    (hx : x ∈ s) : iteratedFDerivWithin 𝕜 i (a • f) s x = a • iteratedFDerivWithin 𝕜 i f s x :=
  by
  induction' i with i hi generalizing x
  · ext; simp
  · ext h
    have hi' : (i : ℕ∞) < i + 1 := with_top.coe_lt_coe.mpr (Nat.lt_succ_self _)
    have hdf : DifferentiableOn 𝕜 (iteratedFDerivWithin 𝕜 i f s) s :=
      hf.differentiable_on_iterated_fderiv_within hi' hu
    have hcdf : ContDiffOn 𝕜 i f s := hf.of_le hi'.le
    calc
      iteratedFDerivWithin 𝕜 (i + 1) (a • f) s x h =
          fderivWithin 𝕜 (iteratedFDerivWithin 𝕜 i (a • f) s) s x (h 0) (Fin.tail h) :=
        rfl
      _ = fderivWithin 𝕜 (a • iteratedFDerivWithin 𝕜 i f s) s x (h 0) (Fin.tail h) := by
        rw [fderivWithin_congr' (fun _ => hi hcdf) hx]; rfl
      _ = (a • fderivWithin 𝕜 (iteratedFDerivWithin 𝕜 i f s)) s x (h 0) (Fin.tail h) := by
        rw [Pi.smul_def, fderivWithin_const_smul (hu x hx) (hdf x hx)]; rfl
      _ = a • iteratedFDerivWithin 𝕜 (i + 1) f s x h := rfl
#align iterated_fderiv_within_const_smul_apply iteratedFDerivWithin_const_smul_apply
-/

#print iteratedFDeriv_const_smul_apply /-
theorem iteratedFDeriv_const_smul_apply {x : E} (hf : ContDiff 𝕜 i f) :
    iteratedFDeriv 𝕜 i (a • f) x = a • iteratedFDeriv 𝕜 i f x :=
  by
  simp_rw [← contDiffOn_univ, ← iteratedFDerivWithin_univ] at *
  refine' iteratedFDerivWithin_const_smul_apply hf uniqueDiffOn_univ (Set.mem_univ _)
#align iterated_fderiv_const_smul_apply iteratedFDeriv_const_smul_apply
-/

end ConstSmul

/-! ### Cartesian product of two functions -/


section Prod_map

variable {E' : Type _} [NormedAddCommGroup E'] [NormedSpace 𝕜 E']

variable {F' : Type _} [NormedAddCommGroup F'] [NormedSpace 𝕜 F']

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ContDiffWithinAt.prod_map' /-
/-- The product map of two `C^n` functions within a set at a point is `C^n`
within the product set at the product point. -/
theorem ContDiffWithinAt.prod_map' {s : Set E} {t : Set E'} {f : E → F} {g : E' → F'} {p : E × E'}
    (hf : ContDiffWithinAt 𝕜 n f s p.1) (hg : ContDiffWithinAt 𝕜 n g t p.2) :
    ContDiffWithinAt 𝕜 n (Prod.map f g) (s ×ˢ t) p :=
  (hf.comp p contDiffWithinAt_fst (prod_subset_preimage_fst _ _)).Prod
    (hg.comp p contDiffWithinAt_snd (prod_subset_preimage_snd _ _))
#align cont_diff_within_at.prod_map' ContDiffWithinAt.prod_map'
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ContDiffWithinAt.prod_map /-
theorem ContDiffWithinAt.prod_map {s : Set E} {t : Set E'} {f : E → F} {g : E' → F'} {x : E}
    {y : E'} (hf : ContDiffWithinAt 𝕜 n f s x) (hg : ContDiffWithinAt 𝕜 n g t y) :
    ContDiffWithinAt 𝕜 n (Prod.map f g) (s ×ˢ t) (x, y) :=
  ContDiffWithinAt.prod_map' hf hg
#align cont_diff_within_at.prod_map ContDiffWithinAt.prod_map
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ContDiffOn.prod_map /-
/-- The product map of two `C^n` functions on a set is `C^n` on the product set. -/
theorem ContDiffOn.prod_map {E' : Type _} [NormedAddCommGroup E'] [NormedSpace 𝕜 E'] {F' : Type _}
    [NormedAddCommGroup F'] [NormedSpace 𝕜 F'] {s : Set E} {t : Set E'} {f : E → F} {g : E' → F'}
    (hf : ContDiffOn 𝕜 n f s) (hg : ContDiffOn 𝕜 n g t) : ContDiffOn 𝕜 n (Prod.map f g) (s ×ˢ t) :=
  (hf.comp contDiffOn_fst (prod_subset_preimage_fst _ _)).Prod
    (hg.comp contDiffOn_snd (prod_subset_preimage_snd _ _))
#align cont_diff_on.prod_map ContDiffOn.prod_map
-/

#print ContDiffAt.prod_map /-
/-- The product map of two `C^n` functions within a set at a point is `C^n`
within the product set at the product point. -/
theorem ContDiffAt.prod_map {f : E → F} {g : E' → F'} {x : E} {y : E'} (hf : ContDiffAt 𝕜 n f x)
    (hg : ContDiffAt 𝕜 n g y) : ContDiffAt 𝕜 n (Prod.map f g) (x, y) :=
  by
  rw [ContDiffAt] at *
  convert hf.prod_map hg
  simp only [univ_prod_univ]
#align cont_diff_at.prod_map ContDiffAt.prod_map
-/

#print ContDiffAt.prod_map' /-
/-- The product map of two `C^n` functions within a set at a point is `C^n`
within the product set at the product point. -/
theorem ContDiffAt.prod_map' {f : E → F} {g : E' → F'} {p : E × E'} (hf : ContDiffAt 𝕜 n f p.1)
    (hg : ContDiffAt 𝕜 n g p.2) : ContDiffAt 𝕜 n (Prod.map f g) p :=
  by
  rcases p with ⟨⟩
  exact ContDiffAt.prod_map hf hg
#align cont_diff_at.prod_map' ContDiffAt.prod_map'
-/

#print ContDiff.prod_map /-
/-- The product map of two `C^n` functions is `C^n`. -/
theorem ContDiff.prod_map {f : E → F} {g : E' → F'} (hf : ContDiff 𝕜 n f) (hg : ContDiff 𝕜 n g) :
    ContDiff 𝕜 n (Prod.map f g) :=
  by
  rw [contDiff_iff_contDiffAt] at *
  exact fun ⟨x, y⟩ => (hf x).Prod_map (hg y)
#align cont_diff.prod_map ContDiff.prod_map
-/

#print contDiff_prod_mk_left /-
theorem contDiff_prod_mk_left (f₀ : F) : ContDiff 𝕜 n fun e : E => (e, f₀) :=
  contDiff_id.Prod contDiff_const
#align cont_diff_prod_mk_left contDiff_prod_mk_left
-/

#print contDiff_prod_mk_right /-
theorem contDiff_prod_mk_right (e₀ : E) : ContDiff 𝕜 n fun f : F => (e₀, f) :=
  contDiff_const.Prod contDiff_id
#align cont_diff_prod_mk_right contDiff_prod_mk_right
-/

end Prod_map

/-! ### Inversion in a complete normed algebra -/


section AlgebraInverse

variable (𝕜) {R : Type _} [NormedRing R] [NormedAlgebra 𝕜 R]

open NormedRing ContinuousLinearMap Ring

#print contDiffAt_ring_inverse /-
/-- In a complete normed algebra, the operation of inversion is `C^n`, for all `n`, at each
invertible element.  The proof is by induction, bootstrapping using an identity expressing the
derivative of inversion as a bilinear map of inversion itself. -/
theorem contDiffAt_ring_inverse [CompleteSpace R] (x : Rˣ) : ContDiffAt 𝕜 n Ring.inverse (x : R) :=
  by
  induction' n using ENat.nat_induction with n IH Itop
  · intro m hm
    refine' ⟨{y : R | IsUnit y}, _, _⟩
    · simp [nhdsWithin_univ]
      exact x.nhds
    · use ftaylorSeriesWithin 𝕜 inverse univ
      rw [le_antisymm hm bot_le, hasFTaylorSeriesUpToOn_zero_iff]
      constructor
      · rintro _ ⟨x', rfl⟩
        exact (inverse_continuous_at x').ContinuousWithinAt
      · simp [ftaylorSeriesWithin]
  · apply cont_diff_at_succ_iff_has_fderiv_at.mpr
    refine' ⟨fun x : R => -mul_left_right 𝕜 R (inverse x) (inverse x), _, _⟩
    · refine' ⟨{y : R | IsUnit y}, x.nhds, _⟩
      rintro _ ⟨y, rfl⟩
      rw [inverse_unit]
      exact hasFDerivAt_ring_inverse y
    ·
      convert
        (mul_left_right_is_bounded_bilinear 𝕜 R).ContDiff.neg.comp_contDiffAt (x : R) (IH.prod IH)
  · exact cont_diff_at_top.mpr Itop
#align cont_diff_at_ring_inverse contDiffAt_ring_inverse
-/

variable (𝕜) {𝕜' : Type _} [NormedField 𝕜'] [NormedAlgebra 𝕜 𝕜'] [CompleteSpace 𝕜']

#print contDiffAt_inv /-
theorem contDiffAt_inv {x : 𝕜'} (hx : x ≠ 0) {n} : ContDiffAt 𝕜 n Inv.inv x := by
  simpa only [Ring.inverse_eq_inv'] using contDiffAt_ring_inverse 𝕜 (Units.mk0 x hx)
#align cont_diff_at_inv contDiffAt_inv
-/

#print contDiffOn_inv /-
theorem contDiffOn_inv {n} : ContDiffOn 𝕜 n (Inv.inv : 𝕜' → 𝕜') ({0}ᶜ) := fun x hx =>
  (contDiffAt_inv 𝕜 hx).ContDiffWithinAt
#align cont_diff_on_inv contDiffOn_inv
-/

variable {𝕜}

#print ContDiffWithinAt.inv /-
-- TODO: the next few lemmas don't need `𝕜` or `𝕜'` to be complete
-- A good way to show this is to generalize `cont_diff_at_ring_inverse` to the setting
-- of a function `f` such that `∀ᶠ x in 𝓝 a, x * f x = 1`.
theorem ContDiffWithinAt.inv {f : E → 𝕜'} {n} (hf : ContDiffWithinAt 𝕜 n f s x) (hx : f x ≠ 0) :
    ContDiffWithinAt 𝕜 n (fun x => (f x)⁻¹) s x :=
  (contDiffAt_inv 𝕜 hx).comp_contDiffWithinAt x hf
#align cont_diff_within_at.inv ContDiffWithinAt.inv
-/

#print ContDiffOn.inv /-
theorem ContDiffOn.inv {f : E → 𝕜'} {n} (hf : ContDiffOn 𝕜 n f s) (h : ∀ x ∈ s, f x ≠ 0) :
    ContDiffOn 𝕜 n (fun x => (f x)⁻¹) s := fun x hx => (hf.ContDiffWithinAt hx).inv (h x hx)
#align cont_diff_on.inv ContDiffOn.inv
-/

#print ContDiffAt.inv /-
theorem ContDiffAt.inv {f : E → 𝕜'} {n} (hf : ContDiffAt 𝕜 n f x) (hx : f x ≠ 0) :
    ContDiffAt 𝕜 n (fun x => (f x)⁻¹) x :=
  hf.inv hx
#align cont_diff_at.inv ContDiffAt.inv
-/

#print ContDiff.inv /-
theorem ContDiff.inv {f : E → 𝕜'} {n} (hf : ContDiff 𝕜 n f) (h : ∀ x, f x ≠ 0) :
    ContDiff 𝕜 n fun x => (f x)⁻¹ := by rw [contDiff_iff_contDiffAt];
  exact fun x => hf.cont_diff_at.inv (h x)
#align cont_diff.inv ContDiff.inv
-/

#print ContDiffWithinAt.div /-
-- TODO: generalize to `f g : E → 𝕜'`
theorem ContDiffWithinAt.div [CompleteSpace 𝕜] {f g : E → 𝕜} {n} (hf : ContDiffWithinAt 𝕜 n f s x)
    (hg : ContDiffWithinAt 𝕜 n g s x) (hx : g x ≠ 0) :
    ContDiffWithinAt 𝕜 n (fun x => f x / g x) s x := by
  simpa only [div_eq_mul_inv] using hf.mul (hg.inv hx)
#align cont_diff_within_at.div ContDiffWithinAt.div
-/

#print ContDiffOn.div /-
theorem ContDiffOn.div [CompleteSpace 𝕜] {f g : E → 𝕜} {n} (hf : ContDiffOn 𝕜 n f s)
    (hg : ContDiffOn 𝕜 n g s) (h₀ : ∀ x ∈ s, g x ≠ 0) : ContDiffOn 𝕜 n (f / g) s := fun x hx =>
  (hf x hx).div (hg x hx) (h₀ x hx)
#align cont_diff_on.div ContDiffOn.div
-/

#print ContDiffAt.div /-
theorem ContDiffAt.div [CompleteSpace 𝕜] {f g : E → 𝕜} {n} (hf : ContDiffAt 𝕜 n f x)
    (hg : ContDiffAt 𝕜 n g x) (hx : g x ≠ 0) : ContDiffAt 𝕜 n (fun x => f x / g x) x :=
  hf.div hg hx
#align cont_diff_at.div ContDiffAt.div
-/

#print ContDiff.div /-
theorem ContDiff.div [CompleteSpace 𝕜] {f g : E → 𝕜} {n} (hf : ContDiff 𝕜 n f) (hg : ContDiff 𝕜 n g)
    (h0 : ∀ x, g x ≠ 0) : ContDiff 𝕜 n fun x => f x / g x :=
  by
  simp only [contDiff_iff_contDiffAt] at *
  exact fun x => (hf x).div (hg x) (h0 x)
#align cont_diff.div ContDiff.div
-/

end AlgebraInverse

/-! ### Inversion of continuous linear maps between Banach spaces -/


section MapInverse

open ContinuousLinearMap

#print contDiffAt_map_inverse /-
/-- At a continuous linear equivalence `e : E ≃L[𝕜] F` between Banach spaces, the operation of
inversion is `C^n`, for all `n`. -/
theorem contDiffAt_map_inverse [CompleteSpace E] (e : E ≃L[𝕜] F) :
    ContDiffAt 𝕜 n inverse (e : E →L[𝕜] F) :=
  by
  nontriviality E
  -- first, we use the lemma `to_ring_inverse` to rewrite in terms of `ring.inverse` in the ring
  -- `E →L[𝕜] E`
  let O₁ : (E →L[𝕜] E) → F →L[𝕜] E := fun f => f.comp (e.symm : F →L[𝕜] E)
  let O₂ : (E →L[𝕜] F) → E →L[𝕜] E := fun f => (e.symm : F →L[𝕜] E).comp f
  have : ContinuousLinearMap.inverse = O₁ ∘ Ring.inverse ∘ O₂ := funext (to_ring_inverse e)
  rw [this]
  -- `O₁` and `O₂` are `cont_diff`,
  -- so we reduce to proving that `ring.inverse` is `cont_diff`
  have h₁ : ContDiff 𝕜 n O₁ := cont_diff_id.clm_comp contDiff_const
  have h₂ : ContDiff 𝕜 n O₂ := cont_diff_const.clm_comp contDiff_id
  refine' h₁.cont_diff_at.comp _ (ContDiffAt.comp _ _ h₂.cont_diff_at)
  convert contDiffAt_ring_inverse 𝕜 (1 : (E →L[𝕜] E)ˣ)
  simp [O₂, one_def]
#align cont_diff_at_map_inverse contDiffAt_map_inverse
-/

end MapInverse

section FunctionInverse

open ContinuousLinearMap

#print LocalHomeomorph.contDiffAt_symm /-
/-- If `f` is a local homeomorphism and the point `a` is in its target,
and if `f` is `n` times continuously differentiable at `f.symm a`,
and if the derivative at `f.symm a` is a continuous linear equivalence,
then `f.symm` is `n` times continuously differentiable at the point `a`.

This is one of the easy parts of the inverse function theorem: it assumes that we already have
an inverse function. -/
theorem LocalHomeomorph.contDiffAt_symm [CompleteSpace E] (f : LocalHomeomorph E F)
    {f₀' : E ≃L[𝕜] F} {a : F} (ha : a ∈ f.target)
    (hf₀' : HasFDerivAt f (f₀' : E →L[𝕜] F) (f.symm a)) (hf : ContDiffAt 𝕜 n f (f.symm a)) :
    ContDiffAt 𝕜 n f.symm a :=
  by
  -- We prove this by induction on `n`
  induction' n using ENat.nat_induction with n IH Itop
  · rw [contDiffAt_zero]
    exact ⟨f.target, IsOpen.mem_nhds f.open_target ha, f.continuous_inv_fun⟩
  · obtain ⟨f', ⟨u, hu, hff'⟩, hf'⟩ := cont_diff_at_succ_iff_has_fderiv_at.mp hf
    apply cont_diff_at_succ_iff_has_fderiv_at.mpr
    -- For showing `n.succ` times continuous differentiability (the main inductive step), it
    -- suffices to produce the derivative and show that it is `n` times continuously differentiable
    have eq_f₀' : f' (f.symm a) = f₀' := (hff' (f.symm a) (mem_of_mem_nhds hu)).unique hf₀'
    -- This follows by a bootstrapping formula expressing the derivative as a function of `f` itself
    refine' ⟨inverse ∘ f' ∘ f.symm, _, _⟩
    · -- We first check that the derivative of `f` is that formula
      have h_nhds : {y : E | ∃ e : E ≃L[𝕜] F, ↑e = f' y} ∈ 𝓝 (f.symm a) :=
        by
        have hf₀' := f₀'.nhds
        rw [← eq_f₀'] at hf₀' 
        exact hf'.continuous_at.preimage_mem_nhds hf₀'
      obtain ⟨t, htu, ht, htf⟩ := mem_nhds_iff.mp (Filter.inter_mem hu h_nhds)
      use f.target ∩ f.symm ⁻¹' t
      refine' ⟨IsOpen.mem_nhds _ _, _⟩
      · exact f.preimage_open_of_open_symm ht
      · exact mem_inter ha (mem_preimage.mpr htf)
      intro x hx
      obtain ⟨hxu, e, he⟩ := htu hx.2
      have h_deriv : HasFDerivAt f (↑e) (f.symm x) :=
        by
        rw [he]
        exact hff' (f.symm x) hxu
      convert f.has_fderiv_at_symm hx.1 h_deriv
      simp [← he]
    · -- Then we check that the formula, being a composition of `cont_diff` pieces, is
      -- itself `cont_diff`
      have h_deriv₁ : ContDiffAt 𝕜 n inverse (f' (f.symm a)) :=
        by
        rw [eq_f₀']
        exact contDiffAt_map_inverse _
      have h_deriv₂ : ContDiffAt 𝕜 n f.symm a :=
        by
        refine' IH (hf.of_le _)
        norm_cast
        exact Nat.le_succ n
      exact (h_deriv₁.comp _ hf').comp _ h_deriv₂
  · refine' cont_diff_at_top.mpr _
    intro n
    exact Itop n (cont_diff_at_top.mp hf n)
#align local_homeomorph.cont_diff_at_symm LocalHomeomorph.contDiffAt_symm
-/

#print Homeomorph.contDiff_symm /-
/-- If `f` is an `n` times continuously differentiable homeomorphism,
and if the derivative of `f` at each point is a continuous linear equivalence,
then `f.symm` is `n` times continuously differentiable.

This is one of the easy parts of the inverse function theorem: it assumes that we already have
an inverse function. -/
theorem Homeomorph.contDiff_symm [CompleteSpace E] (f : E ≃ₜ F) {f₀' : E → E ≃L[𝕜] F}
    (hf₀' : ∀ a, HasFDerivAt f (f₀' a : E →L[𝕜] F) a) (hf : ContDiff 𝕜 n (f : E → F)) :
    ContDiff 𝕜 n (f.symm : F → E) :=
  contDiff_iff_contDiffAt.2 fun x =>
    f.toLocalHomeomorph.contDiffAt_symm (mem_univ x) (hf₀' _) hf.ContDiffAt
#align homeomorph.cont_diff_symm Homeomorph.contDiff_symm
-/

#print LocalHomeomorph.contDiffAt_symm_deriv /-
/-- Let `f` be a local homeomorphism of a nontrivially normed field, let `a` be a point in its
target. if `f` is `n` times continuously differentiable at `f.symm a`, and if the derivative at
`f.symm a` is nonzero, then `f.symm` is `n` times continuously differentiable at the point `a`.

This is one of the easy parts of the inverse function theorem: it assumes that we already have
an inverse function. -/
theorem LocalHomeomorph.contDiffAt_symm_deriv [CompleteSpace 𝕜] (f : LocalHomeomorph 𝕜 𝕜)
    {f₀' a : 𝕜} (h₀ : f₀' ≠ 0) (ha : a ∈ f.target) (hf₀' : HasDerivAt f f₀' (f.symm a))
    (hf : ContDiffAt 𝕜 n f (f.symm a)) : ContDiffAt 𝕜 n f.symm a :=
  f.contDiffAt_symm ha (hf₀'.hasFDerivAt_equiv h₀) hf
#align local_homeomorph.cont_diff_at_symm_deriv LocalHomeomorph.contDiffAt_symm_deriv
-/

#print Homeomorph.contDiff_symm_deriv /-
/-- Let `f` be an `n` times continuously differentiable homeomorphism of a nontrivially normed
field.  Suppose that the derivative of `f` is never equal to zero. Then `f.symm` is `n` times
continuously differentiable.

This is one of the easy parts of the inverse function theorem: it assumes that we already have
an inverse function. -/
theorem Homeomorph.contDiff_symm_deriv [CompleteSpace 𝕜] (f : 𝕜 ≃ₜ 𝕜) {f' : 𝕜 → 𝕜}
    (h₀ : ∀ x, f' x ≠ 0) (hf' : ∀ x, HasDerivAt f (f' x) x) (hf : ContDiff 𝕜 n (f : 𝕜 → 𝕜)) :
    ContDiff 𝕜 n (f.symm : 𝕜 → 𝕜) :=
  contDiff_iff_contDiffAt.2 fun x =>
    f.toLocalHomeomorph.contDiffAt_symm_deriv (h₀ _) (mem_univ x) (hf' _) hf.ContDiffAt
#align homeomorph.cont_diff_symm_deriv Homeomorph.contDiff_symm_deriv
-/

end FunctionInverse

/-! ### Finite dimensional results -/


section FiniteDimensional

open Function FiniteDimensional

variable [CompleteSpace 𝕜]

#print contDiffOn_clm_apply /-
/-- A family of continuous linear maps is `C^n` on `s` if all its applications are. -/
theorem contDiffOn_clm_apply {n : ℕ∞} {f : E → F →L[𝕜] G} {s : Set E} [FiniteDimensional 𝕜 F] :
    ContDiffOn 𝕜 n f s ↔ ∀ y, ContDiffOn 𝕜 n (fun x => f x y) s :=
  by
  refine' ⟨fun h y => h.clm_apply contDiffOn_const, fun h => _⟩
  let d := finrank 𝕜 F
  have hd : d = finrank 𝕜 (Fin d → 𝕜) := (finrank_fin_fun 𝕜).symm
  let e₁ := ContinuousLinearEquiv.ofFinrankEq hd
  let e₂ := (e₁.arrow_congr (1 : G ≃L[𝕜] G)).trans (ContinuousLinearEquiv.piRing (Fin d))
  rw [← comp.left_id f, ← e₂.symm_comp_self]
  exact e₂.symm.cont_diff.comp_cont_diff_on (cont_diff_on_pi.mpr fun i => h _)
#align cont_diff_on_clm_apply contDiffOn_clm_apply
-/

#print contDiff_clm_apply_iff /-
theorem contDiff_clm_apply_iff {n : ℕ∞} {f : E → F →L[𝕜] G} [FiniteDimensional 𝕜 F] :
    ContDiff 𝕜 n f ↔ ∀ y, ContDiff 𝕜 n fun x => f x y := by
  simp_rw [← contDiffOn_univ, contDiffOn_clm_apply]
#align cont_diff_clm_apply_iff contDiff_clm_apply_iff
-/

#print contDiff_succ_iff_fderiv_apply /-
/-- This is a useful lemma to prove that a certain operation preserves functions being `C^n`.
When you do induction on `n`, this gives a useful characterization of a function being `C^(n+1)`,
assuming you have already computed the derivative. The advantage of this version over
`cont_diff_succ_iff_fderiv` is that both occurences of `cont_diff` are for functions with the same
domain and codomain (`E` and `F`). This is not the case for `cont_diff_succ_iff_fderiv`, which
often requires an inconvenient need to generalize `F`, which results in universe issues
(see the discussion in the section of `cont_diff.comp`).

This lemma avoids these universe issues, but only applies for finite dimensional `E`. -/
theorem contDiff_succ_iff_fderiv_apply [FiniteDimensional 𝕜 E] {n : ℕ} {f : E → F} :
    ContDiff 𝕜 (n + 1 : ℕ) f ↔ Differentiable 𝕜 f ∧ ∀ y, ContDiff 𝕜 n fun x => fderiv 𝕜 f x y := by
  rw [contDiff_succ_iff_fderiv, contDiff_clm_apply_iff]
#align cont_diff_succ_iff_fderiv_apply contDiff_succ_iff_fderiv_apply
-/

#print contDiffOn_succ_of_fderiv_apply /-
theorem contDiffOn_succ_of_fderiv_apply [FiniteDimensional 𝕜 E] {n : ℕ} {f : E → F} {s : Set E}
    (hf : DifferentiableOn 𝕜 f s) (h : ∀ y, ContDiffOn 𝕜 n (fun x => fderivWithin 𝕜 f s x y) s) :
    ContDiffOn 𝕜 (n + 1 : ℕ) f s :=
  contDiffOn_succ_of_fderivWithin hf <| contDiffOn_clm_apply.mpr h
#align cont_diff_on_succ_of_fderiv_apply contDiffOn_succ_of_fderiv_apply
-/

#print contDiffOn_succ_iff_fderiv_apply /-
theorem contDiffOn_succ_iff_fderiv_apply [FiniteDimensional 𝕜 E] {n : ℕ} {f : E → F} {s : Set E}
    (hs : UniqueDiffOn 𝕜 s) :
    ContDiffOn 𝕜 (n + 1 : ℕ) f s ↔
      DifferentiableOn 𝕜 f s ∧ ∀ y, ContDiffOn 𝕜 n (fun x => fderivWithin 𝕜 f s x y) s :=
  by rw [contDiffOn_succ_iff_fderivWithin hs, contDiffOn_clm_apply]
#align cont_diff_on_succ_iff_fderiv_apply contDiffOn_succ_iff_fderiv_apply
-/

end FiniteDimensional

section Real

/-!
### Results over `ℝ` or `ℂ`
  The results in this section rely on the Mean Value Theorem, and therefore hold only over `ℝ` (and
  its extension fields such as `ℂ`).
-/


variable {𝕂 : Type _} [IsROrC 𝕂] {E' : Type _} [NormedAddCommGroup E'] [NormedSpace 𝕂 E']
  {F' : Type _} [NormedAddCommGroup F'] [NormedSpace 𝕂 F']

#print HasFTaylorSeriesUpToOn.hasStrictFDerivAt /-
/-- If a function has a Taylor series at order at least 1, then at points in the interior of the
    domain of definition, the term of order 1 of this series is a strict derivative of `f`. -/
theorem HasFTaylorSeriesUpToOn.hasStrictFDerivAt {s : Set E'} {f : E' → F'} {x : E'}
    {p : E' → FormalMultilinearSeries 𝕂 E' F'} (hf : HasFTaylorSeriesUpToOn n f p s) (hn : 1 ≤ n)
    (hs : s ∈ 𝓝 x) : HasStrictFDerivAt f ((continuousMultilinearCurryFin1 𝕂 E' F') (p x 1)) x :=
  hasStrictFDerivAt_of_hasFDerivAt_of_continuousAt (hf.eventually_hasFDerivAt hn hs) <|
    (continuousMultilinearCurryFin1 𝕂 E' F').ContinuousAt.comp <| (hf.cont 1 hn).ContinuousAt hs
#align has_ftaylor_series_up_to_on.has_strict_fderiv_at HasFTaylorSeriesUpToOn.hasStrictFDerivAt
-/

#print ContDiffAt.hasStrictFDerivAt' /-
/-- If a function is `C^n` with `1 ≤ n` around a point, and its derivative at that point is given to
us as `f'`, then `f'` is also a strict derivative. -/
theorem ContDiffAt.hasStrictFDerivAt' {f : E' → F'} {f' : E' →L[𝕂] F'} {x : E'}
    (hf : ContDiffAt 𝕂 n f x) (hf' : HasFDerivAt f f' x) (hn : 1 ≤ n) : HasStrictFDerivAt f f' x :=
  by
  rcases hf 1 hn with ⟨u, H, p, hp⟩
  simp only [nhdsWithin_univ, mem_univ, insert_eq_of_mem] at H 
  have := hp.has_strict_fderiv_at le_rfl H
  rwa [hf'.unique this.has_fderiv_at]
#align cont_diff_at.has_strict_fderiv_at' ContDiffAt.hasStrictFDerivAt'
-/

#print ContDiffAt.hasStrictDerivAt' /-
/-- If a function is `C^n` with `1 ≤ n` around a point, and its derivative at that point is given to
us as `f'`, then `f'` is also a strict derivative. -/
theorem ContDiffAt.hasStrictDerivAt' {f : 𝕂 → F'} {f' : F'} {x : 𝕂} (hf : ContDiffAt 𝕂 n f x)
    (hf' : HasDerivAt f f' x) (hn : 1 ≤ n) : HasStrictDerivAt f f' x :=
  hf.hasStrictFDerivAt' hf' hn
#align cont_diff_at.has_strict_deriv_at' ContDiffAt.hasStrictDerivAt'
-/

#print ContDiffAt.hasStrictFDerivAt /-
/-- If a function is `C^n` with `1 ≤ n` around a point, then the derivative of `f` at this point
is also a strict derivative. -/
theorem ContDiffAt.hasStrictFDerivAt {f : E' → F'} {x : E'} (hf : ContDiffAt 𝕂 n f x) (hn : 1 ≤ n) :
    HasStrictFDerivAt f (fderiv 𝕂 f x) x :=
  hf.hasStrictFDerivAt' (hf.DifferentiableAt hn).HasFDerivAt hn
#align cont_diff_at.has_strict_fderiv_at ContDiffAt.hasStrictFDerivAt
-/

#print ContDiffAt.hasStrictDerivAt /-
/-- If a function is `C^n` with `1 ≤ n` around a point, then the derivative of `f` at this point
is also a strict derivative. -/
theorem ContDiffAt.hasStrictDerivAt {f : 𝕂 → F'} {x : 𝕂} (hf : ContDiffAt 𝕂 n f x) (hn : 1 ≤ n) :
    HasStrictDerivAt f (deriv f x) x :=
  (hf.HasStrictFDerivAt hn).HasStrictDerivAt
#align cont_diff_at.has_strict_deriv_at ContDiffAt.hasStrictDerivAt
-/

#print ContDiff.hasStrictFDerivAt /-
/-- If a function is `C^n` with `1 ≤ n`, then the derivative of `f` is also a strict derivative. -/
theorem ContDiff.hasStrictFDerivAt {f : E' → F'} {x : E'} (hf : ContDiff 𝕂 n f) (hn : 1 ≤ n) :
    HasStrictFDerivAt f (fderiv 𝕂 f x) x :=
  hf.ContDiffAt.HasStrictFDerivAt hn
#align cont_diff.has_strict_fderiv_at ContDiff.hasStrictFDerivAt
-/

#print ContDiff.hasStrictDerivAt /-
/-- If a function is `C^n` with `1 ≤ n`, then the derivative of `f` is also a strict derivative. -/
theorem ContDiff.hasStrictDerivAt {f : 𝕂 → F'} {x : 𝕂} (hf : ContDiff 𝕂 n f) (hn : 1 ≤ n) :
    HasStrictDerivAt f (deriv f x) x :=
  hf.ContDiffAt.HasStrictDerivAt hn
#align cont_diff.has_strict_deriv_at ContDiff.hasStrictDerivAt
-/

#print HasFTaylorSeriesUpToOn.exists_lipschitzOnWith_of_nnnorm_lt /-
/-- If `f` has a formal Taylor series `p` up to order `1` on `{x} ∪ s`, where `s` is a convex set,
and `‖p x 1‖₊ < K`, then `f` is `K`-Lipschitz in a neighborhood of `x` within `s`. -/
theorem HasFTaylorSeriesUpToOn.exists_lipschitzOnWith_of_nnnorm_lt {E F : Type _}
    [NormedAddCommGroup E] [NormedSpace ℝ E] [NormedAddCommGroup F] [NormedSpace ℝ F] {f : E → F}
    {p : E → FormalMultilinearSeries ℝ E F} {s : Set E} {x : E}
    (hf : HasFTaylorSeriesUpToOn 1 f p (insert x s)) (hs : Convex ℝ s) (K : ℝ≥0)
    (hK : ‖p x 1‖₊ < K) : ∃ t ∈ 𝓝[s] x, LipschitzOnWith K f t :=
  by
  set f' := fun y => continuousMultilinearCurryFin1 ℝ E F (p y 1)
  have hder : ∀ y ∈ s, HasFDerivWithinAt f (f' y) s y := fun y hy =>
    (hf.has_fderiv_within_at le_rfl (subset_insert x s hy)).mono (subset_insert x s)
  have hcont : ContinuousWithinAt f' s x :=
    (continuousMultilinearCurryFin1 ℝ E F).ContinuousAt.comp_continuousWithinAt
      ((hf.cont _ le_rfl _ (mem_insert _ _)).mono (subset_insert x s))
  replace hK : ‖f' x‖₊ < K; · simpa only [LinearIsometryEquiv.nnnorm_map]
  exact
    hs.exists_nhds_within_lipschitz_on_with_of_has_fderiv_within_at_of_nnnorm_lt
      (eventually_nhdsWithin_iff.2 <| eventually_of_forall hder) hcont K hK
#align has_ftaylor_series_up_to_on.exists_lipschitz_on_with_of_nnnorm_lt HasFTaylorSeriesUpToOn.exists_lipschitzOnWith_of_nnnorm_lt
-/

#print HasFTaylorSeriesUpToOn.exists_lipschitzOnWith /-
/-- If `f` has a formal Taylor series `p` up to order `1` on `{x} ∪ s`, where `s` is a convex set,
then `f` is Lipschitz in a neighborhood of `x` within `s`. -/
theorem HasFTaylorSeriesUpToOn.exists_lipschitzOnWith {E F : Type _} [NormedAddCommGroup E]
    [NormedSpace ℝ E] [NormedAddCommGroup F] [NormedSpace ℝ F] {f : E → F}
    {p : E → FormalMultilinearSeries ℝ E F} {s : Set E} {x : E}
    (hf : HasFTaylorSeriesUpToOn 1 f p (insert x s)) (hs : Convex ℝ s) :
    ∃ K, ∃ t ∈ 𝓝[s] x, LipschitzOnWith K f t :=
  (exists_gt _).imp <| hf.exists_lipschitzOnWith_of_nnnorm_lt hs
#align has_ftaylor_series_up_to_on.exists_lipschitz_on_with HasFTaylorSeriesUpToOn.exists_lipschitzOnWith
-/

#print ContDiffWithinAt.exists_lipschitzOnWith /-
/-- If `f` is `C^1` within a conves set `s` at `x`, then it is Lipschitz on a neighborhood of `x`
within `s`. -/
theorem ContDiffWithinAt.exists_lipschitzOnWith {E F : Type _} [NormedAddCommGroup E]
    [NormedSpace ℝ E] [NormedAddCommGroup F] [NormedSpace ℝ F] {f : E → F} {s : Set E} {x : E}
    (hf : ContDiffWithinAt ℝ 1 f s x) (hs : Convex ℝ s) :
    ∃ K : ℝ≥0, ∃ t ∈ 𝓝[s] x, LipschitzOnWith K f t :=
  by
  rcases hf 1 le_rfl with ⟨t, hst, p, hp⟩
  rcases metric.mem_nhds_within_iff.mp hst with ⟨ε, ε0, hε⟩
  replace hp : HasFTaylorSeriesUpToOn 1 f p (Metric.ball x ε ∩ insert x s) := hp.mono hε
  clear hst hε t
  rw [← insert_eq_of_mem (Metric.mem_ball_self ε0), ← insert_inter_distrib] at hp 
  rcases hp.exists_lipschitz_on_with ((convex_ball _ _).inter hs) with ⟨K, t, hst, hft⟩
  rw [inter_comm, ← nhdsWithin_restrict' _ (Metric.ball_mem_nhds _ ε0)] at hst 
  exact ⟨K, t, hst, hft⟩
#align cont_diff_within_at.exists_lipschitz_on_with ContDiffWithinAt.exists_lipschitzOnWith
-/

#print ContDiffAt.exists_lipschitzOnWith_of_nnnorm_lt /-
/-- If `f` is `C^1` at `x` and `K > ‖fderiv 𝕂 f x‖`, then `f` is `K`-Lipschitz in a neighborhood of
`x`. -/
theorem ContDiffAt.exists_lipschitzOnWith_of_nnnorm_lt {f : E' → F'} {x : E'}
    (hf : ContDiffAt 𝕂 1 f x) (K : ℝ≥0) (hK : ‖fderiv 𝕂 f x‖₊ < K) :
    ∃ t ∈ 𝓝 x, LipschitzOnWith K f t :=
  (hf.HasStrictFDerivAt le_rfl).exists_lipschitzOnWith_of_nnnorm_lt K hK
#align cont_diff_at.exists_lipschitz_on_with_of_nnnorm_lt ContDiffAt.exists_lipschitzOnWith_of_nnnorm_lt
-/

#print ContDiffAt.exists_lipschitzOnWith /-
/-- If `f` is `C^1` at `x`, then `f` is Lipschitz in a neighborhood of `x`. -/
theorem ContDiffAt.exists_lipschitzOnWith {f : E' → F'} {x : E'} (hf : ContDiffAt 𝕂 1 f x) :
    ∃ K, ∃ t ∈ 𝓝 x, LipschitzOnWith K f t :=
  (hf.HasStrictFDerivAt le_rfl).exists_lipschitzOnWith
#align cont_diff_at.exists_lipschitz_on_with ContDiffAt.exists_lipschitzOnWith
-/

end Real

section deriv

/-!
### One dimension

All results up to now have been expressed in terms of the general Fréchet derivative `fderiv`. For
maps defined on the field, the one-dimensional derivative `deriv` is often easier to use. In this
paragraph, we reformulate some higher smoothness results in terms of `deriv`.
-/


variable {f₂ : 𝕜 → F} {s₂ : Set 𝕜}

open ContinuousLinearMap (smul_right)

#print contDiffOn_succ_iff_derivWithin /-
/-- A function is `C^(n + 1)` on a domain with unique derivatives if and only if it is
differentiable there, and its derivative (formulated with `deriv_within`) is `C^n`. -/
theorem contDiffOn_succ_iff_derivWithin {n : ℕ} (hs : UniqueDiffOn 𝕜 s₂) :
    ContDiffOn 𝕜 (n + 1 : ℕ) f₂ s₂ ↔
      DifferentiableOn 𝕜 f₂ s₂ ∧ ContDiffOn 𝕜 n (derivWithin f₂ s₂) s₂ :=
  by
  rw [contDiffOn_succ_iff_fderivWithin hs]
  congr 2
  apply le_antisymm
  · intro h
    have : derivWithin f₂ s₂ = (fun u : 𝕜 →L[𝕜] F => u 1) ∘ fderivWithin 𝕜 f₂ s₂ := by ext x; rfl
    simp only [this]
    apply ContDiff.comp_contDiffOn _ h
    exact (is_bounded_bilinear_map_apply.is_bounded_linear_map_left _).ContDiff
  · intro h
    have : fderivWithin 𝕜 f₂ s₂ = smul_right (1 : 𝕜 →L[𝕜] 𝕜) ∘ derivWithin f₂ s₂ := by ext x;
      simp [derivWithin]
    simp only [this]
    apply ContDiff.comp_contDiffOn _ h
    have : IsBoundedBilinearMap 𝕜 fun _ : (𝕜 →L[𝕜] 𝕜) × F => _ := isBoundedBilinearMap_smulRight
    exact (this.is_bounded_linear_map_right _).ContDiff
#align cont_diff_on_succ_iff_deriv_within contDiffOn_succ_iff_derivWithin
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:73:14: unsupported tactic `congrm #[[expr «expr ∧ »(_, _)]] -/
#print contDiffOn_succ_iff_deriv_of_open /-
/-- A function is `C^(n + 1)` on an open domain if and only if it is
differentiable there, and its derivative (formulated with `deriv`) is `C^n`. -/
theorem contDiffOn_succ_iff_deriv_of_open {n : ℕ} (hs : IsOpen s₂) :
    ContDiffOn 𝕜 (n + 1 : ℕ) f₂ s₂ ↔ DifferentiableOn 𝕜 f₂ s₂ ∧ ContDiffOn 𝕜 n (deriv f₂) s₂ :=
  by
  rw [contDiffOn_succ_iff_derivWithin hs.unique_diff_on]
  trace
    "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:73:14: unsupported tactic `congrm #[[expr «expr ∧ »(_, _)]]"
  exact contDiffOn_congr fun _ => derivWithin_of_open hs
#align cont_diff_on_succ_iff_deriv_of_open contDiffOn_succ_iff_deriv_of_open
-/

#print contDiffOn_top_iff_derivWithin /-
/-- A function is `C^∞` on a domain with unique derivatives if and only if it is differentiable
there, and its derivative (formulated with `deriv_within`) is `C^∞`. -/
theorem contDiffOn_top_iff_derivWithin (hs : UniqueDiffOn 𝕜 s₂) :
    ContDiffOn 𝕜 ∞ f₂ s₂ ↔ DifferentiableOn 𝕜 f₂ s₂ ∧ ContDiffOn 𝕜 ∞ (derivWithin f₂ s₂) s₂ :=
  by
  constructor
  · intro h
    refine' ⟨h.differentiable_on le_top, _⟩
    apply contDiffOn_top.2 fun n => ((contDiffOn_succ_iff_derivWithin hs).1 _).2
    exact h.of_le le_top
  · intro h
    refine' contDiffOn_top.2 fun n => _
    have A : (n : ℕ∞) ≤ ∞ := le_top
    apply ((contDiffOn_succ_iff_derivWithin hs).2 ⟨h.1, h.2.of_le A⟩).of_le
    exact WithTop.coe_le_coe.2 (Nat.le_succ n)
#align cont_diff_on_top_iff_deriv_within contDiffOn_top_iff_derivWithin
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:73:14: unsupported tactic `congrm #[[expr «expr ∧ »(_, _)]] -/
#print contDiffOn_top_iff_deriv_of_open /-
/-- A function is `C^∞` on an open domain if and only if it is differentiable
there, and its derivative (formulated with `deriv`) is `C^∞`. -/
theorem contDiffOn_top_iff_deriv_of_open (hs : IsOpen s₂) :
    ContDiffOn 𝕜 ∞ f₂ s₂ ↔ DifferentiableOn 𝕜 f₂ s₂ ∧ ContDiffOn 𝕜 ∞ (deriv f₂) s₂ :=
  by
  rw [contDiffOn_top_iff_derivWithin hs.unique_diff_on]
  trace
    "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:73:14: unsupported tactic `congrm #[[expr «expr ∧ »(_, _)]]"
  exact contDiffOn_congr fun _ => derivWithin_of_open hs
#align cont_diff_on_top_iff_deriv_of_open contDiffOn_top_iff_deriv_of_open
-/

#print ContDiffOn.derivWithin /-
theorem ContDiffOn.derivWithin (hf : ContDiffOn 𝕜 n f₂ s₂) (hs : UniqueDiffOn 𝕜 s₂)
    (hmn : m + 1 ≤ n) : ContDiffOn 𝕜 m (derivWithin f₂ s₂) s₂ :=
  by
  cases m
  · change ∞ + 1 ≤ n at hmn 
    have : n = ∞ := by simpa using hmn
    rw [this] at hf 
    exact ((contDiffOn_top_iff_derivWithin hs).1 hf).2
  · change (m.succ : ℕ∞) ≤ n at hmn 
    exact ((contDiffOn_succ_iff_derivWithin hs).1 (hf.of_le hmn)).2
#align cont_diff_on.deriv_within ContDiffOn.derivWithin
-/

#print ContDiffOn.deriv_of_open /-
theorem ContDiffOn.deriv_of_open (hf : ContDiffOn 𝕜 n f₂ s₂) (hs : IsOpen s₂) (hmn : m + 1 ≤ n) :
    ContDiffOn 𝕜 m (deriv f₂) s₂ :=
  (hf.derivWithin hs.UniqueDiffOn hmn).congr fun x hx => (derivWithin_of_open hs hx).symm
#align cont_diff_on.deriv_of_open ContDiffOn.deriv_of_open
-/

#print ContDiffOn.continuousOn_derivWithin /-
theorem ContDiffOn.continuousOn_derivWithin (h : ContDiffOn 𝕜 n f₂ s₂) (hs : UniqueDiffOn 𝕜 s₂)
    (hn : 1 ≤ n) : ContinuousOn (derivWithin f₂ s₂) s₂ :=
  ((contDiffOn_succ_iff_derivWithin hs).1 (h.of_le hn)).2.ContinuousOn
#align cont_diff_on.continuous_on_deriv_within ContDiffOn.continuousOn_derivWithin
-/

#print ContDiffOn.continuousOn_deriv_of_open /-
theorem ContDiffOn.continuousOn_deriv_of_open (h : ContDiffOn 𝕜 n f₂ s₂) (hs : IsOpen s₂)
    (hn : 1 ≤ n) : ContinuousOn (deriv f₂) s₂ :=
  ((contDiffOn_succ_iff_deriv_of_open hs).1 (h.of_le hn)).2.ContinuousOn
#align cont_diff_on.continuous_on_deriv_of_open ContDiffOn.continuousOn_deriv_of_open
-/

#print contDiff_succ_iff_deriv /-
/-- A function is `C^(n + 1)` if and only if it is differentiable,
  and its derivative (formulated in terms of `deriv`) is `C^n`. -/
theorem contDiff_succ_iff_deriv {n : ℕ} :
    ContDiff 𝕜 (n + 1 : ℕ) f₂ ↔ Differentiable 𝕜 f₂ ∧ ContDiff 𝕜 n (deriv f₂) := by
  simp only [← contDiffOn_univ, contDiffOn_succ_iff_deriv_of_open, isOpen_univ,
    differentiableOn_univ]
#align cont_diff_succ_iff_deriv contDiff_succ_iff_deriv
-/

#print contDiff_one_iff_deriv /-
theorem contDiff_one_iff_deriv : ContDiff 𝕜 1 f₂ ↔ Differentiable 𝕜 f₂ ∧ Continuous (deriv f₂) :=
  contDiff_succ_iff_deriv.trans <| Iff.rfl.And contDiff_zero
#align cont_diff_one_iff_deriv contDiff_one_iff_deriv
-/

#print contDiff_top_iff_deriv /-
/-- A function is `C^∞` if and only if it is differentiable,
and its derivative (formulated in terms of `deriv`) is `C^∞`. -/
theorem contDiff_top_iff_deriv : ContDiff 𝕜 ∞ f₂ ↔ Differentiable 𝕜 f₂ ∧ ContDiff 𝕜 ∞ (deriv f₂) :=
  by
  simp only [← contDiffOn_univ, ← differentiableOn_univ, ← derivWithin_univ]
  rw [contDiffOn_top_iff_derivWithin uniqueDiffOn_univ]
#align cont_diff_top_iff_deriv contDiff_top_iff_deriv
-/

#print ContDiff.continuous_deriv /-
theorem ContDiff.continuous_deriv (h : ContDiff 𝕜 n f₂) (hn : 1 ≤ n) : Continuous (deriv f₂) :=
  (contDiff_succ_iff_deriv.mp (h.of_le hn)).2.Continuous
#align cont_diff.continuous_deriv ContDiff.continuous_deriv
-/

#print ContDiff.iterate_deriv /-
theorem ContDiff.iterate_deriv :
    ∀ (n : ℕ) {f₂ : 𝕜 → F} (hf : ContDiff 𝕜 ∞ f₂), ContDiff 𝕜 ∞ ((deriv^[n]) f₂)
  | 0, f₂, hf => hf
  | n + 1, f₂, hf => ContDiff.iterate_deriv n (contDiff_top_iff_deriv.mp hf).2
#align cont_diff.iterate_deriv ContDiff.iterate_deriv
-/

#print ContDiff.iterate_deriv' /-
theorem ContDiff.iterate_deriv' (n : ℕ) :
    ∀ (k : ℕ) {f₂ : 𝕜 → F} (hf : ContDiff 𝕜 (n + k : ℕ) f₂), ContDiff 𝕜 n ((deriv^[k]) f₂)
  | 0, f₂, hf => hf
  | n + 1, f₂, hf => ContDiff.iterate_deriv' n (contDiff_succ_iff_deriv.mp hf).2
#align cont_diff.iterate_deriv' ContDiff.iterate_deriv'
-/

end deriv

section RestrictScalars

/-!
### Restricting from `ℂ` to `ℝ`, or generally from `𝕜'` to `𝕜`

If a function is `n` times continuously differentiable over `ℂ`, then it is `n` times continuously
differentiable over `ℝ`. In this paragraph, we give variants of this statement, in the general
situation where `ℂ` and `ℝ` are replaced respectively by `𝕜'` and `𝕜` where `𝕜'` is a normed algebra
over `𝕜`.
-/


variable (𝕜) {𝕜' : Type _} [NontriviallyNormedField 𝕜'] [NormedAlgebra 𝕜 𝕜']

variable [NormedSpace 𝕜' E] [IsScalarTower 𝕜 𝕜' E]

variable [NormedSpace 𝕜' F] [IsScalarTower 𝕜 𝕜' F]

variable {p' : E → FormalMultilinearSeries 𝕜' E F}

#print HasFTaylorSeriesUpToOn.restrictScalars /-
theorem HasFTaylorSeriesUpToOn.restrictScalars (h : HasFTaylorSeriesUpToOn n f p' s) :
    HasFTaylorSeriesUpToOn n f (fun x => (p' x).restrictScalars 𝕜) s :=
  { zero_eq := fun x hx => h.zero_eq x hx
    fderivWithin := by
      intro m hm x hx
      convert
        (ContinuousMultilinearMap.restrictScalarsLinear 𝕜).HasFDerivAt.comp_hasFDerivWithinAt _
          ((h.fderiv_within m hm x hx).restrictScalars 𝕜)
    cont := fun m hm =>
      ContinuousMultilinearMap.continuous_restrictScalars.comp_continuousOn (h.cont m hm) }
#align has_ftaylor_series_up_to_on.restrict_scalars HasFTaylorSeriesUpToOn.restrictScalars
-/

#print ContDiffWithinAt.restrict_scalars /-
theorem ContDiffWithinAt.restrict_scalars (h : ContDiffWithinAt 𝕜' n f s x) :
    ContDiffWithinAt 𝕜 n f s x := by
  intro m hm
  rcases h m hm with ⟨u, u_mem, p', hp'⟩
  exact ⟨u, u_mem, _, hp'.restrict_scalars _⟩
#align cont_diff_within_at.restrict_scalars ContDiffWithinAt.restrict_scalars
-/

#print ContDiffOn.restrict_scalars /-
theorem ContDiffOn.restrict_scalars (h : ContDiffOn 𝕜' n f s) : ContDiffOn 𝕜 n f s := fun x hx =>
  (h x hx).restrictScalars _
#align cont_diff_on.restrict_scalars ContDiffOn.restrict_scalars
-/

#print ContDiffAt.restrict_scalars /-
theorem ContDiffAt.restrict_scalars (h : ContDiffAt 𝕜' n f x) : ContDiffAt 𝕜 n f x :=
  contDiffWithinAt_univ.1 <| h.ContDiffWithinAt.restrictScalars _
#align cont_diff_at.restrict_scalars ContDiffAt.restrict_scalars
-/

#print ContDiff.restrict_scalars /-
theorem ContDiff.restrict_scalars (h : ContDiff 𝕜' n f) : ContDiff 𝕜 n f :=
  contDiff_iff_contDiffAt.2 fun x => h.ContDiffAt.restrictScalars _
#align cont_diff.restrict_scalars ContDiff.restrict_scalars
-/

end RestrictScalars

/-!## Quantitative bounds -/


#print ContinuousLinearMap.norm_iteratedFDerivWithin_le_of_bilinear_aux /-
/-- Bounding the norm of the iterated derivative of `B (f x) (g x)` within a set in terms of the
iterated derivatives of `f` and `g` when `B` is bilinear. This lemma is an auxiliary version
assuming all spaces live in the same universe, to enable an induction. Use instead
`continuous_linear_map.norm_iterated_fderiv_within_le_of_bilinear` that removes this assumption. -/
theorem ContinuousLinearMap.norm_iteratedFDerivWithin_le_of_bilinear_aux {Du Eu Fu Gu : Type u}
    [NormedAddCommGroup Du] [NormedSpace 𝕜 Du] [NormedAddCommGroup Eu] [NormedSpace 𝕜 Eu]
    [NormedAddCommGroup Fu] [NormedSpace 𝕜 Fu] [NormedAddCommGroup Gu] [NormedSpace 𝕜 Gu]
    (B : Eu →L[𝕜] Fu →L[𝕜] Gu) {f : Du → Eu} {g : Du → Fu} {n : ℕ} {s : Set Du} {x : Du}
    (hf : ContDiffOn 𝕜 n f s) (hg : ContDiffOn 𝕜 n g s) (hs : UniqueDiffOn 𝕜 s) (hx : x ∈ s) :
    ‖iteratedFDerivWithin 𝕜 n (fun y => B (f y) (g y)) s x‖ ≤
      ‖B‖ *
        ∑ i in Finset.range (n + 1),
          (n.choose i : ℝ) * ‖iteratedFDerivWithin 𝕜 i f s x‖ *
            ‖iteratedFDerivWithin 𝕜 (n - i) g s x‖ :=
  by
  /- We argue by induction on `n`. The bound is trivial for `n = 0`. For `n + 1`, we write
    the `(n+1)`-th derivative as the `n`-th derivative of the derivative `B f g' + B f' g`, and apply
    the inductive assumption to each of those two terms. For this induction to make sense,
    the spaces of linear maps that appear in the induction should be in the same universe as the
    original spaces, which explains why we assume in the lemma that all spaces live in the same
    universe. -/
  induction' n with n IH generalizing Eu Fu Gu
  · simp only [← mul_assoc, norm_iteratedFDerivWithin_zero, Finset.range_one, Finset.sum_singleton,
      Nat.choose_self, algebraMap.coe_one, one_mul]
    apply ((B (f x)).le_op_norm (g x)).trans
    apply mul_le_mul_of_nonneg_right _ (norm_nonneg _)
    exact B.le_op_norm (f x)
  · have In : (n : ℕ∞) + 1 ≤ n.succ := by simp only [Nat.cast_succ, le_refl]
    have I1 :
      ‖iteratedFDerivWithin 𝕜 n (fun y : Du => B.precompR Du (f y) (fderivWithin 𝕜 g s y)) s x‖ ≤
        ‖B‖ *
          ∑ i : ℕ in Finset.range (n + 1),
            n.choose i * ‖iteratedFDerivWithin 𝕜 i f s x‖ *
              ‖iteratedFDerivWithin 𝕜 (n + 1 - i) g s x‖ :=
      calc
        ‖iteratedFDerivWithin 𝕜 n (fun y : Du => B.precompR Du (f y) (fderivWithin 𝕜 g s y)) s x‖ ≤
            ‖B.precompR Du‖ *
              ∑ i : ℕ in Finset.range (n + 1),
                n.choose i * ‖iteratedFDerivWithin 𝕜 i f s x‖ *
                  ‖iteratedFDerivWithin 𝕜 (n - i) (fderivWithin 𝕜 g s) s x‖ :=
          IH _ (hf.of_le (Nat.cast_le.2 (Nat.le_succ n))) (hg.fderiv_within hs In)
        _ ≤
            ‖B‖ *
              ∑ i : ℕ in Finset.range (n + 1),
                n.choose i * ‖iteratedFDerivWithin 𝕜 i f s x‖ *
                  ‖iteratedFDerivWithin 𝕜 (n - i) (fderivWithin 𝕜 g s) s x‖ :=
          (mul_le_mul_of_nonneg_right (B.norm_precompR_le Du)
            (Finset.sum_nonneg' fun i => by positivity))
        _ = _ := by
          congr 1
          apply Finset.sum_congr rfl fun i hi => _
          rw [Nat.succ_sub (Nat.lt_succ_iff.1 (Finset.mem_range.1 hi)),
            iteratedFDerivWithin_succ_eq_comp_right hs hx, LinearIsometryEquiv.norm_map]
    have I2 :
      ‖iteratedFDerivWithin 𝕜 n (fun y : Du => B.precompL Du (fderivWithin 𝕜 f s y) (g y)) s x‖ ≤
        ‖B‖ *
          ∑ i : ℕ in Finset.range (n + 1),
            n.choose i * ‖iteratedFDerivWithin 𝕜 (i + 1) f s x‖ *
              ‖iteratedFDerivWithin 𝕜 (n - i) g s x‖ :=
      calc
        ‖iteratedFDerivWithin 𝕜 n (fun y : Du => B.precompL Du (fderivWithin 𝕜 f s y) (g y)) s x‖ ≤
            ‖B.precompL Du‖ *
              ∑ i : ℕ in Finset.range (n + 1),
                n.choose i * ‖iteratedFDerivWithin 𝕜 i (fderivWithin 𝕜 f s) s x‖ *
                  ‖iteratedFDerivWithin 𝕜 (n - i) g s x‖ :=
          IH _ (hf.fderiv_within hs In) (hg.of_le (Nat.cast_le.2 (Nat.le_succ n)))
        _ ≤
            ‖B‖ *
              ∑ i : ℕ in Finset.range (n + 1),
                n.choose i * ‖iteratedFDerivWithin 𝕜 i (fderivWithin 𝕜 f s) s x‖ *
                  ‖iteratedFDerivWithin 𝕜 (n - i) g s x‖ :=
          (mul_le_mul_of_nonneg_right (B.norm_precompL_le Du)
            (Finset.sum_nonneg' fun i => by positivity))
        _ = _ := by
          congr 1
          apply Finset.sum_congr rfl fun i hi => _
          rw [iteratedFDerivWithin_succ_eq_comp_right hs hx, LinearIsometryEquiv.norm_map]
    have J :
      iteratedFDerivWithin 𝕜 n (fun y : Du => fderivWithin 𝕜 (fun y : Du => B (f y) (g y)) s y) s
          x =
        iteratedFDerivWithin 𝕜 n
          (fun y =>
            B.precompR Du (f y) (fderivWithin 𝕜 g s y) + B.precompL Du (fderivWithin 𝕜 f s y) (g y))
          s x :=
      by
      apply iteratedFDerivWithin_congr (fun y hy => _) hx
      have L : (1 : ℕ∞) ≤ n.succ := by
        simpa only [ENat.coe_one, Nat.one_le_cast] using Nat.succ_pos n
      exact
        B.fderiv_within_of_bilinear (hf.differentiable_on L y hy) (hg.differentiable_on L y hy)
          (hs y hy)
    rw [iteratedFDerivWithin_succ_eq_comp_right hs hx, LinearIsometryEquiv.norm_map, J]
    have A : ContDiffOn 𝕜 n (fun y => B.precompR Du (f y) (fderivWithin 𝕜 g s y)) s :=
      (B.precompR Du).IsBoundedBilinearMap.ContDiff.comp_contDiff_on₂
        (hf.of_le (Nat.cast_le.2 (Nat.le_succ n))) (hg.fderiv_within hs In)
    have A' : ContDiffOn 𝕜 n (fun y => B.precompL Du (fderivWithin 𝕜 f s y) (g y)) s :=
      (B.precompL Du).IsBoundedBilinearMap.ContDiff.comp_contDiff_on₂ (hf.fderiv_within hs In)
        (hg.of_le (Nat.cast_le.2 (Nat.le_succ n)))
    rw [iteratedFDerivWithin_add_apply' A A' hs hx]
    apply (norm_add_le _ _).trans ((add_le_add I1 I2).trans (le_of_eq _))
    simp_rw [← mul_add, mul_assoc]
    congr 1
    exact
      (Finset.sum_choose_succ_mul
          (fun i j => ‖iteratedFDerivWithin 𝕜 i f s x‖ * ‖iteratedFDerivWithin 𝕜 j g s x‖) n).symm
#align continuous_linear_map.norm_iterated_fderiv_within_le_of_bilinear_aux ContinuousLinearMap.norm_iteratedFDerivWithin_le_of_bilinear_aux
-/

#print ContinuousLinearMap.norm_iteratedFDerivWithin_le_of_bilinear /-
/-- Bounding the norm of the iterated derivative of `B (f x) (g x)` within a set in terms of the
iterated derivatives of `f` and `g` when `B` is bilinear:
`‖D^n (x ↦ B (f x) (g x))‖ ≤ ‖B‖ ∑_{k ≤ n} n.choose k ‖D^k f‖ ‖D^{n-k} g‖` -/
theorem ContinuousLinearMap.norm_iteratedFDerivWithin_le_of_bilinear (B : E →L[𝕜] F →L[𝕜] G)
    {f : D → E} {g : D → F} {N : ℕ∞} {s : Set D} {x : D} (hf : ContDiffOn 𝕜 N f s)
    (hg : ContDiffOn 𝕜 N g s) (hs : UniqueDiffOn 𝕜 s) (hx : x ∈ s) {n : ℕ} (hn : (n : ℕ∞) ≤ N) :
    ‖iteratedFDerivWithin 𝕜 n (fun y => B (f y) (g y)) s x‖ ≤
      ‖B‖ *
        ∑ i in Finset.range (n + 1),
          (n.choose i : ℝ) * ‖iteratedFDerivWithin 𝕜 i f s x‖ *
            ‖iteratedFDerivWithin 𝕜 (n - i) g s x‖ :=
  by
  /- We reduce the bound to the case where all spaces live in the same universe (in which we
    already have proved the result), by using linear isometries between the spaces and their `ulift`
    to a common universe. These linear isometries preserve the norm of the iterated derivative. -/
  let Du : Type max uD uE uF uG := ULift.{max uE uF uG, uD} D
  let Eu : Type max uD uE uF uG := ULift.{max uD uF uG, uE} E
  let Fu : Type max uD uE uF uG := ULift.{max uD uE uG, uF} F
  let Gu : Type max uD uE uF uG := ULift.{max uD uE uF, uG} G
  have isoD : Du ≃ₗᵢ[𝕜] D := LinearIsometryEquiv.ulift 𝕜 D
  have isoE : Eu ≃ₗᵢ[𝕜] E := LinearIsometryEquiv.ulift 𝕜 E
  have isoF : Fu ≃ₗᵢ[𝕜] F := LinearIsometryEquiv.ulift 𝕜 F
  have isoG : Gu ≃ₗᵢ[𝕜] G := LinearIsometryEquiv.ulift 𝕜 G
  -- lift `f` and `g` to versions `fu` and `gu` on the lifted spaces.
  let fu : Du → Eu := isoE.symm ∘ f ∘ isoD
  let gu : Du → Fu := isoF.symm ∘ g ∘ isoD
  -- lift the bilinear map `B` to a bilinear map `Bu` on the lifted spaces.
  let Bu₀ : Eu →L[𝕜] Fu →L[𝕜] G
  exact ((B.comp (isoE : Eu →L[𝕜] E)).flip.comp (isoF : Fu →L[𝕜] F)).flip
  let Bu : Eu →L[𝕜] Fu →L[𝕜] Gu;
  exact
    ContinuousLinearMap.compL 𝕜 Eu (Fu →L[𝕜] G) (Fu →L[𝕜] Gu)
      (ContinuousLinearMap.compL 𝕜 Fu G Gu (isoG.symm : G →L[𝕜] Gu)) Bu₀
  have Bu_eq : (fun y => Bu (fu y) (gu y)) = isoG.symm ∘ (fun y => B (f y) (g y)) ∘ isoD :=
    by
    ext1 y
    simp only [Bu, ContinuousLinearMap.compL_apply, Function.comp_apply,
      ContinuousLinearMap.coe_comp', LinearIsometryEquiv.coe_coe'', ContinuousLinearMap.flip_apply,
      LinearIsometryEquiv.apply_symm_apply]
  -- All norms are preserved by the lifting process.
  have Bu_le : ‖Bu‖ ≤ ‖B‖ :=
    by
    refine' ContinuousLinearMap.op_norm_le_bound _ (norm_nonneg _) fun y => _
    refine' ContinuousLinearMap.op_norm_le_bound _ (by positivity) fun x => _
    simp only [Bu, ContinuousLinearMap.compL_apply, ContinuousLinearMap.coe_comp',
      Function.comp_apply, LinearIsometryEquiv.coe_coe'', ContinuousLinearMap.flip_apply,
      LinearIsometryEquiv.norm_map]
    calc
      ‖B (isoE y) (isoF x)‖ ≤ ‖B (isoE y)‖ * ‖isoF x‖ := ContinuousLinearMap.le_op_norm _ _
      _ ≤ ‖B‖ * ‖isoE y‖ * ‖isoF x‖ :=
        (mul_le_mul_of_nonneg_right (ContinuousLinearMap.le_op_norm _ _) (norm_nonneg _))
      _ = ‖B‖ * ‖y‖ * ‖x‖ := by simp only [LinearIsometryEquiv.norm_map]
  let su := isoD ⁻¹' s
  have hsu : UniqueDiffOn 𝕜 su := isoD.to_continuous_linear_equiv.unique_diff_on_preimage_iff.2 hs
  let xu := isoD.symm x
  have hxu : xu ∈ su := by
    simpa only [Set.mem_preimage, LinearIsometryEquiv.apply_symm_apply] using hx
  have xu_x : isoD xu = x := by simp only [LinearIsometryEquiv.apply_symm_apply]
  have hfu : ContDiffOn 𝕜 n fu su :=
    isoE.symm.cont_diff.comp_cont_diff_on
      ((hf.of_le hn).compContinuousLinearMap (isoD : Du →L[𝕜] D))
  have hgu : ContDiffOn 𝕜 n gu su :=
    isoF.symm.cont_diff.comp_cont_diff_on
      ((hg.of_le hn).compContinuousLinearMap (isoD : Du →L[𝕜] D))
  have Nfu : ∀ i, ‖iteratedFDerivWithin 𝕜 i fu su xu‖ = ‖iteratedFDerivWithin 𝕜 i f s x‖ :=
    by
    intro i
    rw [LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_left _ _ hsu hxu]
    rw [LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_right _ _ hs, xu_x]
    rwa [← xu_x] at hx 
  have Ngu : ∀ i, ‖iteratedFDerivWithin 𝕜 i gu su xu‖ = ‖iteratedFDerivWithin 𝕜 i g s x‖ :=
    by
    intro i
    rw [LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_left _ _ hsu hxu]
    rw [LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_right _ _ hs, xu_x]
    rwa [← xu_x] at hx 
  have NBu :
    ‖iteratedFDerivWithin 𝕜 n (fun y => Bu (fu y) (gu y)) su xu‖ =
      ‖iteratedFDerivWithin 𝕜 n (fun y => B (f y) (g y)) s x‖ :=
    by
    rw [Bu_eq]
    rw [LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_left _ _ hsu hxu]
    rw [LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_right _ _ hs, xu_x]
    rwa [← xu_x] at hx 
  -- state the bound for the lifted objects, and deduce the original bound from it.
  have :
    ‖iteratedFDerivWithin 𝕜 n (fun y => Bu (fu y) (gu y)) su xu‖ ≤
      ‖Bu‖ *
        ∑ i in Finset.range (n + 1),
          (n.choose i : ℝ) * ‖iteratedFDerivWithin 𝕜 i fu su xu‖ *
            ‖iteratedFDerivWithin 𝕜 (n - i) gu su xu‖ :=
    Bu.norm_iterated_fderiv_within_le_of_bilinear_aux hfu hgu hsu hxu
  simp only [Nfu, Ngu, NBu] at this 
  apply this.trans (mul_le_mul_of_nonneg_right Bu_le _)
  exact Finset.sum_nonneg' fun i => by positivity
#align continuous_linear_map.norm_iterated_fderiv_within_le_of_bilinear ContinuousLinearMap.norm_iteratedFDerivWithin_le_of_bilinear
-/

#print ContinuousLinearMap.norm_iteratedFDeriv_le_of_bilinear /-
/-- Bounding the norm of the iterated derivative of `B (f x) (g x)` in terms of the
iterated derivatives of `f` and `g` when `B` is bilinear:
`‖D^n (x ↦ B (f x) (g x))‖ ≤ ‖B‖ ∑_{k ≤ n} n.choose k ‖D^k f‖ ‖D^{n-k} g‖` -/
theorem ContinuousLinearMap.norm_iteratedFDeriv_le_of_bilinear (B : E →L[𝕜] F →L[𝕜] G) {f : D → E}
    {g : D → F} {N : ℕ∞} (hf : ContDiff 𝕜 N f) (hg : ContDiff 𝕜 N g) (x : D) {n : ℕ}
    (hn : (n : ℕ∞) ≤ N) :
    ‖iteratedFDeriv 𝕜 n (fun y => B (f y) (g y)) x‖ ≤
      ‖B‖ *
        ∑ i in Finset.range (n + 1),
          (n.choose i : ℝ) * ‖iteratedFDeriv 𝕜 i f x‖ * ‖iteratedFDeriv 𝕜 (n - i) g x‖ :=
  by
  simp_rw [← iteratedFDerivWithin_univ]
  exact
    B.norm_iterated_fderiv_within_le_of_bilinear hf.cont_diff_on hg.cont_diff_on uniqueDiffOn_univ
      (mem_univ x) hn
#align continuous_linear_map.norm_iterated_fderiv_le_of_bilinear ContinuousLinearMap.norm_iteratedFDeriv_le_of_bilinear
-/

#print ContinuousLinearMap.norm_iteratedFDerivWithin_le_of_bilinear_of_le_one /-
/-- Bounding the norm of the iterated derivative of `B (f x) (g x)` within a set in terms of the
iterated derivatives of `f` and `g` when `B` is bilinear of norm at most `1`:
`‖D^n (x ↦ B (f x) (g x))‖ ≤ ∑_{k ≤ n} n.choose k ‖D^k f‖ ‖D^{n-k} g‖` -/
theorem ContinuousLinearMap.norm_iteratedFDerivWithin_le_of_bilinear_of_le_one
    (B : E →L[𝕜] F →L[𝕜] G) {f : D → E} {g : D → F} {N : ℕ∞} {s : Set D} {x : D}
    (hf : ContDiffOn 𝕜 N f s) (hg : ContDiffOn 𝕜 N g s) (hs : UniqueDiffOn 𝕜 s) (hx : x ∈ s) {n : ℕ}
    (hn : (n : ℕ∞) ≤ N) (hB : ‖B‖ ≤ 1) :
    ‖iteratedFDerivWithin 𝕜 n (fun y => B (f y) (g y)) s x‖ ≤
      ∑ i in Finset.range (n + 1),
        (n.choose i : ℝ) * ‖iteratedFDerivWithin 𝕜 i f s x‖ *
          ‖iteratedFDerivWithin 𝕜 (n - i) g s x‖ :=
  by
  apply (B.norm_iterated_fderiv_within_le_of_bilinear hf hg hs hx hn).trans
  apply mul_le_of_le_one_left (Finset.sum_nonneg' fun i => _) hB
  positivity
#align continuous_linear_map.norm_iterated_fderiv_within_le_of_bilinear_of_le_one ContinuousLinearMap.norm_iteratedFDerivWithin_le_of_bilinear_of_le_one
-/

#print ContinuousLinearMap.norm_iteratedFDeriv_le_of_bilinear_of_le_one /-
/-- Bounding the norm of the iterated derivative of `B (f x) (g x)` in terms of the
iterated derivatives of `f` and `g` when `B` is bilinear of norm at most `1`:
`‖D^n (x ↦ B (f x) (g x))‖ ≤ ∑_{k ≤ n} n.choose k ‖D^k f‖ ‖D^{n-k} g‖` -/
theorem ContinuousLinearMap.norm_iteratedFDeriv_le_of_bilinear_of_le_one (B : E →L[𝕜] F →L[𝕜] G)
    {f : D → E} {g : D → F} {N : ℕ∞} (hf : ContDiff 𝕜 N f) (hg : ContDiff 𝕜 N g) (x : D) {n : ℕ}
    (hn : (n : ℕ∞) ≤ N) (hB : ‖B‖ ≤ 1) :
    ‖iteratedFDeriv 𝕜 n (fun y => B (f y) (g y)) x‖ ≤
      ∑ i in Finset.range (n + 1),
        (n.choose i : ℝ) * ‖iteratedFDeriv 𝕜 i f x‖ * ‖iteratedFDeriv 𝕜 (n - i) g x‖ :=
  by
  simp_rw [← iteratedFDerivWithin_univ]
  exact
    B.norm_iterated_fderiv_within_le_of_bilinear_of_le_one hf.cont_diff_on hg.cont_diff_on
      uniqueDiffOn_univ (mem_univ x) hn hB
#align continuous_linear_map.norm_iterated_fderiv_le_of_bilinear_of_le_one ContinuousLinearMap.norm_iteratedFDeriv_le_of_bilinear_of_le_one
-/

section

variable {𝕜' : Type _} [NormedField 𝕜'] [NormedAlgebra 𝕜 𝕜'] [NormedSpace 𝕜' F]
  [IsScalarTower 𝕜 𝕜' F]

#print norm_iteratedFDerivWithin_smul_le /-
theorem norm_iteratedFDerivWithin_smul_le {f : E → 𝕜'} {g : E → F} {N : ℕ∞}
    (hf : ContDiffOn 𝕜 N f s) (hg : ContDiffOn 𝕜 N g s) (hs : UniqueDiffOn 𝕜 s) {x : E} (hx : x ∈ s)
    {n : ℕ} (hn : (n : ℕ∞) ≤ N) :
    ‖iteratedFDerivWithin 𝕜 n (fun y => f y • g y) s x‖ ≤
      ∑ i in Finset.range (n + 1),
        (n.choose i : ℝ) * ‖iteratedFDerivWithin 𝕜 i f s x‖ *
          ‖iteratedFDerivWithin 𝕜 (n - i) g s x‖ :=
  (ContinuousLinearMap.lsmul 𝕜 𝕜' :
        𝕜' →L[𝕜] F →L[𝕜] F).norm_iteratedFDerivWithin_le_of_bilinear_of_le_one
    hf hg hs hx hn ContinuousLinearMap.op_norm_lsmul_le
#align norm_iterated_fderiv_within_smul_le norm_iteratedFDerivWithin_smul_le
-/

#print norm_iteratedFDeriv_smul_le /-
theorem norm_iteratedFDeriv_smul_le {f : E → 𝕜'} {g : E → F} {N : ℕ∞} (hf : ContDiff 𝕜 N f)
    (hg : ContDiff 𝕜 N g) (x : E) {n : ℕ} (hn : (n : ℕ∞) ≤ N) :
    ‖iteratedFDeriv 𝕜 n (fun y => f y • g y) x‖ ≤
      ∑ i in Finset.range (n + 1),
        (n.choose i : ℝ) * ‖iteratedFDeriv 𝕜 i f x‖ * ‖iteratedFDeriv 𝕜 (n - i) g x‖ :=
  (ContinuousLinearMap.lsmul 𝕜 𝕜' : 𝕜' →L[𝕜] F →L[𝕜] F).norm_iteratedFDeriv_le_of_bilinear_of_le_one
    hf hg x hn ContinuousLinearMap.op_norm_lsmul_le
#align norm_iterated_fderiv_smul_le norm_iteratedFDeriv_smul_le
-/

end

section

variable {A : Type _} [NormedRing A] [NormedAlgebra 𝕜 A]

#print norm_iteratedFDerivWithin_mul_le /-
theorem norm_iteratedFDerivWithin_mul_le {f : E → A} {g : E → A} {N : ℕ∞} (hf : ContDiffOn 𝕜 N f s)
    (hg : ContDiffOn 𝕜 N g s) (hs : UniqueDiffOn 𝕜 s) {x : E} (hx : x ∈ s) {n : ℕ}
    (hn : (n : ℕ∞) ≤ N) :
    ‖iteratedFDerivWithin 𝕜 n (fun y => f y * g y) s x‖ ≤
      ∑ i in Finset.range (n + 1),
        (n.choose i : ℝ) * ‖iteratedFDerivWithin 𝕜 i f s x‖ *
          ‖iteratedFDerivWithin 𝕜 (n - i) g s x‖ :=
  (ContinuousLinearMap.mul 𝕜 A :
        A →L[𝕜] A →L[𝕜] A).norm_iteratedFDerivWithin_le_of_bilinear_of_le_one
    hf hg hs hx hn (ContinuousLinearMap.op_norm_mul_le _ _)
#align norm_iterated_fderiv_within_mul_le norm_iteratedFDerivWithin_mul_le
-/

#print norm_iteratedFDeriv_mul_le /-
theorem norm_iteratedFDeriv_mul_le {f : E → A} {g : E → A} {N : ℕ∞} (hf : ContDiff 𝕜 N f)
    (hg : ContDiff 𝕜 N g) (x : E) {n : ℕ} (hn : (n : ℕ∞) ≤ N) :
    ‖iteratedFDeriv 𝕜 n (fun y => f y * g y) x‖ ≤
      ∑ i in Finset.range (n + 1),
        (n.choose i : ℝ) * ‖iteratedFDeriv 𝕜 i f x‖ * ‖iteratedFDeriv 𝕜 (n - i) g x‖ :=
  by
  simp_rw [← iteratedFDerivWithin_univ]
  exact
    norm_iteratedFDerivWithin_mul_le hf.cont_diff_on hg.cont_diff_on uniqueDiffOn_univ (mem_univ x)
      hn
#align norm_iterated_fderiv_mul_le norm_iteratedFDeriv_mul_le
-/

end

#print norm_iteratedFDerivWithin_comp_le_aux /-
/-- If the derivatives within a set of `g` at `f x` are bounded by `C`, and the `i`-th derivative
within a set of `f` at `x` is bounded by `D^i` for all `1 ≤ i ≤ n`, then the `n`-th derivative
of `g ∘ f` is bounded by `n! * C * D^n`.
This lemma proves this estimate assuming additionally that two of the spaces live in the same
universe, to make an induction possible. Use instead `norm_iterated_fderiv_within_comp_le` that
removes this assumption. -/
theorem norm_iteratedFDerivWithin_comp_le_aux {Fu Gu : Type u} [NormedAddCommGroup Fu]
    [NormedSpace 𝕜 Fu] [NormedAddCommGroup Gu] [NormedSpace 𝕜 Gu] {g : Fu → Gu} {f : E → Fu} {n : ℕ}
    {s : Set E} {t : Set Fu} {x : E} (hg : ContDiffOn 𝕜 n g t) (hf : ContDiffOn 𝕜 n f s)
    (ht : UniqueDiffOn 𝕜 t) (hs : UniqueDiffOn 𝕜 s) (hst : MapsTo f s t) (hx : x ∈ s) {C : ℝ}
    {D : ℝ} (hC : ∀ i, i ≤ n → ‖iteratedFDerivWithin 𝕜 i g t (f x)‖ ≤ C)
    (hD : ∀ i, 1 ≤ i → i ≤ n → ‖iteratedFDerivWithin 𝕜 i f s x‖ ≤ D ^ i) :
    ‖iteratedFDerivWithin 𝕜 n (g ∘ f) s x‖ ≤ n ! * C * D ^ n :=
  by
  /- We argue by induction on `n`, using that `D^(n+1) (g ∘ f) = D^n (g ' ∘ f ⬝ f')`. The successive
    derivatives of `g' ∘ f` are controlled thanks to the inductive assumption, and those of `f'` are
    controlled by assumption.
    As composition of linear maps is a bilinear map, one may use
    `continuous_linear_map.norm_iterated_fderiv_le_of_bilinear_of_le_one` to get from these a bound
    on `D^n (g ' ∘ f ⬝ f')`. -/
  induction' n using Nat.case_strong_induction_on with n IH generalizing Gu
  ·
    simpa only [norm_iteratedFDerivWithin_zero, Nat.factorial_zero, algebraMap.coe_one, one_mul,
      pow_zero, mul_one] using hC 0 le_rfl
  have M : (n : ℕ∞) < n.succ := Nat.cast_lt.2 n.lt_succ_self
  have Cnonneg : 0 ≤ C := (norm_nonneg _).trans (hC 0 bot_le)
  have Dnonneg : 0 ≤ D :=
    by
    have : 1 ≤ n + 1 := by simp only [le_add_iff_nonneg_left, zero_le']
    simpa only [pow_one] using (norm_nonneg _).trans (hD 1 le_rfl this)
  -- use the inductive assumption to bound the derivatives of `g' ∘ f`.
  have I :
    ∀ i ∈ Finset.range (n + 1),
      ‖iteratedFDerivWithin 𝕜 i (fderivWithin 𝕜 g t ∘ f) s x‖ ≤ i ! * C * D ^ i :=
    by
    intro i hi
    simp only [Finset.mem_range_succ_iff] at hi 
    apply IH i hi
    apply hf.of_le (Nat.cast_le.2 (hi.trans n.le_succ))
    · intro j hj h'j
      exact hD j hj (h'j.trans (hi.trans n.le_succ))
    · apply hg.fderiv_within ht
      simp only [Nat.cast_succ]
      exact add_le_add_right (Nat.cast_le.2 hi) _
    · intro j hj
      have :
        ‖iteratedFDerivWithin 𝕜 j (fderivWithin 𝕜 g t) t (f x)‖ =
          ‖iteratedFDerivWithin 𝕜 (j + 1) g t (f x)‖ :=
        by rw [iteratedFDerivWithin_succ_eq_comp_right ht (hst hx), LinearIsometryEquiv.norm_map]
      rw [this]
      exact hC (j + 1) (add_le_add (hj.trans hi) le_rfl)
  -- reformulate `hD` as a bound for the derivatives of `f'`.
  have J : ∀ i, ‖iteratedFDerivWithin 𝕜 (n - i) (fderivWithin 𝕜 f s) s x‖ ≤ D ^ (n - i + 1) :=
    by
    intro i
    have :
      ‖iteratedFDerivWithin 𝕜 (n - i) (fderivWithin 𝕜 f s) s x‖ =
        ‖iteratedFDerivWithin 𝕜 (n - i + 1) f s x‖ :=
      by rw [iteratedFDerivWithin_succ_eq_comp_right hs hx, LinearIsometryEquiv.norm_map]
    rw [this]
    apply hD
    · simp only [le_add_iff_nonneg_left, zero_le']
    · apply Nat.succ_le_succ tsub_le_self
  -- Now put these together: first, notice that we have to bound `D^n (g' ∘ f ⬝ f')`.
  calc
    ‖iteratedFDerivWithin 𝕜 (n + 1) (g ∘ f) s x‖ =
        ‖iteratedFDerivWithin 𝕜 n (fun y : E => fderivWithin 𝕜 (g ∘ f) s y) s x‖ :=
      by rw [iteratedFDerivWithin_succ_eq_comp_right hs hx, LinearIsometryEquiv.norm_map]
    _ =
        ‖iteratedFDerivWithin 𝕜 n
            (fun y : E =>
              ContinuousLinearMap.compL 𝕜 E Fu Gu (fderivWithin 𝕜 g t (f y)) (fderivWithin 𝕜 f s y))
            s x‖ :=
      by
      have L : (1 : ℕ∞) ≤ n.succ := by simpa only [ENat.coe_one, Nat.one_le_cast] using n.succ_pos
      congr 1
      refine' iteratedFDerivWithin_congr (fun y hy => _) hx _
      apply fderivWithin.comp _ _ _ hst (hs y hy)
      · exact hg.differentiable_on L _ (hst hy)
      · exact hf.differentiable_on L _ hy
    -- bound it using the fact that the composition of linear maps is a bilinear operation,
        -- for which we have bounds for the`n`-th derivative.
        _ ≤
        ∑ i in Finset.range (n + 1),
          (n.choose i : ℝ) * ‖iteratedFDerivWithin 𝕜 i (fderivWithin 𝕜 g t ∘ f) s x‖ *
            ‖iteratedFDerivWithin 𝕜 (n - i) (fderivWithin 𝕜 f s) s x‖ :=
      by
      have A : ContDiffOn 𝕜 n (fderivWithin 𝕜 g t ∘ f) s :=
        by
        apply ContDiffOn.comp _ (hf.of_le M.le) hst
        apply hg.fderiv_within ht
        simp only [Nat.cast_succ, le_refl]
      have B : ContDiffOn 𝕜 n (fderivWithin 𝕜 f s) s :=
        by
        apply hf.fderiv_within hs
        simp only [Nat.cast_succ, le_refl]
      exact
        (ContinuousLinearMap.compL 𝕜 E Fu Gu).norm_iteratedFDerivWithin_le_of_bilinear_of_le_one A B
          hs hx le_rfl (ContinuousLinearMap.norm_compL_le 𝕜 E Fu Gu)
    -- bound each of the terms using the estimates on previous derivatives (that use the inductive
        -- assumption for `g' ∘ f`).
        _ ≤
        ∑ i in Finset.range (n + 1), (n.choose i : ℝ) * (i ! * C * D ^ i) * D ^ (n - i + 1) :=
      by
      apply Finset.sum_le_sum fun i hi => _
      simp only [mul_assoc (n.choose i : ℝ)]
      refine' mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg _)
      apply mul_le_mul (I i hi) (J i) (norm_nonneg _)
      positivity
    -- We are left with trivial algebraic manipulations to see that this is smaller than
        -- the claimed bound.
        _ =
        ∑ i in Finset.range (n + 1),
          (n ! : ℝ) * (i !⁻¹ * i !) * C * (D ^ i * D ^ (n - i + 1)) * (n - i)!⁻¹ :=
      by
      apply Finset.sum_congr rfl fun i hi => _
      simp only [Nat.cast_choose ℝ (Finset.mem_range_succ_iff.1 hi), div_eq_inv_mul, mul_inv]
      ring
    _ = ∑ i in Finset.range (n + 1), (n ! : ℝ) * 1 * C * D ^ (n + 1) * (n - i)!⁻¹ :=
      by
      apply Finset.sum_congr rfl fun i hi => _
      congr 2
      · congr
        apply inv_mul_cancel
        simpa only [Ne.def, Nat.cast_eq_zero] using i.factorial_ne_zero
      · rw [← pow_add]
        congr 1
        rw [Nat.add_succ, Nat.succ_inj']
        exact Nat.add_sub_of_le (Finset.mem_range_succ_iff.1 hi)
    _ ≤ ∑ i in Finset.range (n + 1), (n ! : ℝ) * 1 * C * D ^ (n + 1) * 1 :=
      by
      apply Finset.sum_le_sum fun i hi => _
      refine' mul_le_mul_of_nonneg_left _ (by positivity)
      apply inv_le_one
      simpa only [Nat.one_le_cast] using (n - i).factorial_pos
    _ = (n + 1)! * C * D ^ (n + 1) := by
      simp only [mul_assoc, mul_one, Finset.sum_const, Finset.card_range, nsmul_eq_mul,
        Nat.factorial_succ, Nat.cast_mul]
#align norm_iterated_fderiv_within_comp_le_aux norm_iteratedFDerivWithin_comp_le_aux
-/

#print norm_iteratedFDerivWithin_comp_le /-
/-- If the derivatives within a set of `g` at `f x` are bounded by `C`, and the `i`-th derivative
within a set of `f` at `x` is bounded by `D^i` for all `1 ≤ i ≤ n`, then the `n`-th derivative
of `g ∘ f` is bounded by `n! * C * D^n`. -/
theorem norm_iteratedFDerivWithin_comp_le {g : F → G} {f : E → F} {n : ℕ} {s : Set E} {t : Set F}
    {x : E} {N : ℕ∞} (hg : ContDiffOn 𝕜 N g t) (hf : ContDiffOn 𝕜 N f s) (hn : (n : ℕ∞) ≤ N)
    (ht : UniqueDiffOn 𝕜 t) (hs : UniqueDiffOn 𝕜 s) (hst : MapsTo f s t) (hx : x ∈ s) {C : ℝ}
    {D : ℝ} (hC : ∀ i, i ≤ n → ‖iteratedFDerivWithin 𝕜 i g t (f x)‖ ≤ C)
    (hD : ∀ i, 1 ≤ i → i ≤ n → ‖iteratedFDerivWithin 𝕜 i f s x‖ ≤ D ^ i) :
    ‖iteratedFDerivWithin 𝕜 n (g ∘ f) s x‖ ≤ n ! * C * D ^ n :=
  by
  /- We reduce the bound to the case where all spaces live in the same universe (in which we
    already have proved the result), by using linear isometries between the spaces and their `ulift`
    to a common universe. These linear isometries preserve the norm of the iterated derivative. -/
  let Fu : Type max uF uG := ULift.{uG, uF} F
  let Gu : Type max uF uG := ULift.{uF, uG} G
  have isoF : Fu ≃ₗᵢ[𝕜] F := LinearIsometryEquiv.ulift 𝕜 F
  have isoG : Gu ≃ₗᵢ[𝕜] G := LinearIsometryEquiv.ulift 𝕜 G
  -- lift `f` and `g` to versions `fu` and `gu` on the lifted spaces.
  let fu : E → Fu := isoF.symm ∘ f
  let gu : Fu → Gu := isoG.symm ∘ g ∘ isoF
  let tu := isoF ⁻¹' t
  have htu : UniqueDiffOn 𝕜 tu := isoF.to_continuous_linear_equiv.unique_diff_on_preimage_iff.2 ht
  have hstu : maps_to fu s tu := by
    intro y hy
    simpa only [mem_preimage, LinearIsometryEquiv.apply_symm_apply] using hst hy
  have Ffu : isoF (fu x) = f x := by simp only [LinearIsometryEquiv.apply_symm_apply]
  -- All norms are preserved by the lifting process.
  have hfu : ContDiffOn 𝕜 n fu s := isoF.symm.cont_diff.comp_cont_diff_on (hf.of_le hn)
  have hgu : ContDiffOn 𝕜 n gu tu :=
    isoG.symm.cont_diff.comp_cont_diff_on
      ((hg.of_le hn).compContinuousLinearMap (isoF : Fu →L[𝕜] F))
  have Nfu : ∀ i, ‖iteratedFDerivWithin 𝕜 i fu s x‖ = ‖iteratedFDerivWithin 𝕜 i f s x‖ :=
    by
    intro i
    rw [LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_left _ _ hs hx]
  simp_rw [← Nfu] at hD 
  have Ngu : ∀ i, ‖iteratedFDerivWithin 𝕜 i gu tu (fu x)‖ = ‖iteratedFDerivWithin 𝕜 i g t (f x)‖ :=
    by
    intro i
    rw [LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_left _ _ htu (hstu hx)]
    rw [LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_right _ _ ht, Ffu]
    rw [Ffu]
    exact hst hx
  simp_rw [← Ngu] at hC 
  have Nfgu : ‖iteratedFDerivWithin 𝕜 n (g ∘ f) s x‖ = ‖iteratedFDerivWithin 𝕜 n (gu ∘ fu) s x‖ :=
    by
    have : gu ∘ fu = isoG.symm ∘ g ∘ f := by
      ext x
      simp only [comp_app, LinearIsometryEquiv.map_eq_iff, LinearIsometryEquiv.apply_symm_apply]
    rw [this, LinearIsometryEquiv.norm_iteratedFDerivWithin_comp_left _ _ hs hx]
  -- deduce the required bound from the one for `gu ∘ fu`.
  rw [Nfgu]
  exact norm_iteratedFDerivWithin_comp_le_aux hgu hfu htu hs hstu hx hC hD
#align norm_iterated_fderiv_within_comp_le norm_iteratedFDerivWithin_comp_le
-/

#print norm_iteratedFDeriv_comp_le /-
/-- If the derivatives of `g` at `f x` are bounded by `C`, and the `i`-th derivative
of `f` at `x` is bounded by `D^i` for all `1 ≤ i ≤ n`, then the `n`-th derivative
of `g ∘ f` is bounded by `n! * C * D^n`. -/
theorem norm_iteratedFDeriv_comp_le {g : F → G} {f : E → F} {n : ℕ} {N : ℕ∞} (hg : ContDiff 𝕜 N g)
    (hf : ContDiff 𝕜 N f) (hn : (n : ℕ∞) ≤ N) (x : E) {C : ℝ} {D : ℝ}
    (hC : ∀ i, i ≤ n → ‖iteratedFDeriv 𝕜 i g (f x)‖ ≤ C)
    (hD : ∀ i, 1 ≤ i → i ≤ n → ‖iteratedFDeriv 𝕜 i f x‖ ≤ D ^ i) :
    ‖iteratedFDeriv 𝕜 n (g ∘ f) x‖ ≤ n ! * C * D ^ n :=
  by
  simp_rw [← iteratedFDerivWithin_univ] at hC hD ⊢
  exact
    norm_iteratedFDerivWithin_comp_le hg.cont_diff_on hf.cont_diff_on hn uniqueDiffOn_univ
      uniqueDiffOn_univ (maps_to_univ _ _) (mem_univ x) hC hD
#align norm_iterated_fderiv_comp_le norm_iteratedFDeriv_comp_le
-/

section Apply

#print norm_iteratedFDerivWithin_clm_apply /-
theorem norm_iteratedFDerivWithin_clm_apply {f : E → F →L[𝕜] G} {g : E → F} {s : Set E} {x : E}
    {N : ℕ∞} {n : ℕ} (hf : ContDiffOn 𝕜 N f s) (hg : ContDiffOn 𝕜 N g s) (hs : UniqueDiffOn 𝕜 s)
    (hx : x ∈ s) (hn : ↑n ≤ N) :
    ‖iteratedFDerivWithin 𝕜 n (fun y => (f y) (g y)) s x‖ ≤
      (Finset.range (n + 1)).Sum fun i =>
        ↑(n.choose i) * ‖iteratedFDerivWithin 𝕜 i f s x‖ * ‖iteratedFDerivWithin 𝕜 (n - i) g s x‖ :=
  by
  let B : (F →L[𝕜] G) →L[𝕜] F →L[𝕜] G := ContinuousLinearMap.flip (ContinuousLinearMap.apply 𝕜 G)
  have hB : ‖B‖ ≤ 1 :=
    by
    simp only [ContinuousLinearMap.op_norm_flip, ContinuousLinearMap.apply]
    refine' ContinuousLinearMap.op_norm_le_bound _ zero_le_one fun f => _
    simp only [ContinuousLinearMap.coe_id', id.def, one_mul]
  exact B.norm_iterated_fderiv_within_le_of_bilinear_of_le_one hf hg hs hx hn hB
#align norm_iterated_fderiv_within_clm_apply norm_iteratedFDerivWithin_clm_apply
-/

#print norm_iteratedFDeriv_clm_apply /-
theorem norm_iteratedFDeriv_clm_apply {f : E → F →L[𝕜] G} {g : E → F} {N : ℕ∞} {n : ℕ}
    (hf : ContDiff 𝕜 N f) (hg : ContDiff 𝕜 N g) (x : E) (hn : ↑n ≤ N) :
    ‖iteratedFDeriv 𝕜 n (fun y : E => (f y) (g y)) x‖ ≤
      (Finset.range (n + 1)).Sum fun i : ℕ =>
        ↑(n.choose i) * ‖iteratedFDeriv 𝕜 i f x‖ * ‖iteratedFDeriv 𝕜 (n - i) g x‖ :=
  by
  simp only [← iteratedFDerivWithin_univ]
  exact
    norm_iteratedFDerivWithin_clm_apply hf.cont_diff_on hg.cont_diff_on uniqueDiffOn_univ
      (Set.mem_univ x) hn
#align norm_iterated_fderiv_clm_apply norm_iteratedFDeriv_clm_apply
-/

#print norm_iteratedFDerivWithin_clm_apply_const /-
theorem norm_iteratedFDerivWithin_clm_apply_const {f : E → F →L[𝕜] G} {c : F} {s : Set E} {x : E}
    {N : ℕ∞} {n : ℕ} (hf : ContDiffOn 𝕜 N f s) (hs : UniqueDiffOn 𝕜 s) (hx : x ∈ s) (hn : ↑n ≤ N) :
    ‖iteratedFDerivWithin 𝕜 n (fun y : E => (f y) c) s x‖ ≤
      ‖c‖ * ‖iteratedFDerivWithin 𝕜 n f s x‖ :=
  by
  let g : (F →L[𝕜] G) →L[𝕜] G := ContinuousLinearMap.apply 𝕜 G c
  have h := g.norm_comp_continuous_multilinear_map_le (iteratedFDerivWithin 𝕜 n f s x)
  rw [← g.iterated_fderiv_within_comp_left hf hs hx hn] at h 
  refine' h.trans (mul_le_mul_of_nonneg_right _ (norm_nonneg _))
  refine' g.op_norm_le_bound (norm_nonneg _) fun f => _
  rw [ContinuousLinearMap.apply_apply, mul_comm]
  exact f.le_op_norm c
#align norm_iterated_fderiv_within_clm_apply_const norm_iteratedFDerivWithin_clm_apply_const
-/

#print norm_iteratedFDeriv_clm_apply_const /-
theorem norm_iteratedFDeriv_clm_apply_const {f : E → F →L[𝕜] G} {c : F} {x : E} {N : ℕ∞} {n : ℕ}
    (hf : ContDiff 𝕜 N f) (hn : ↑n ≤ N) :
    ‖iteratedFDeriv 𝕜 n (fun y : E => (f y) c) x‖ ≤ ‖c‖ * ‖iteratedFDeriv 𝕜 n f x‖ :=
  by
  simp only [← iteratedFDerivWithin_univ]
  refine'
    norm_iteratedFDerivWithin_clm_apply_const hf.cont_diff_on uniqueDiffOn_univ (Set.mem_univ x) hn
#align norm_iterated_fderiv_clm_apply_const norm_iteratedFDeriv_clm_apply_const
-/

end Apply

