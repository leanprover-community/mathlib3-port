/-
Copyright (c) Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module analysis.complex.basic
! leanprover-community/mathlib commit 2705404e701abc6b3127da906f40bae062a169c9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Complex.Module
import Mathbin.Data.IsROrC.Basic
import Mathbin.Topology.Algebra.Module.InfiniteSum
import Mathbin.Topology.Instances.RealVectorSpace

/-!
# Normed space structure on `ℂ`.

This file gathers basic facts on complex numbers of an analytic nature.

## Main results

This file registers `ℂ` as a normed field, expresses basic properties of the norm, and gives
tools on the real vector space structure of `ℂ`. Notably, in the namespace `complex`,
it defines functions:

* `re_clm`
* `im_clm`
* `of_real_clm`
* `conj_cle`

They are bundled versions of the real part, the imaginary part, the embedding of `ℝ` in `ℂ`, and
the complex conjugate as continuous `ℝ`-linear maps. The last two are also bundled as linear
isometries in `of_real_li` and `conj_lie`.

We also register the fact that `ℂ` is an `is_R_or_C` field.
-/


assert_not_exists absorbs

noncomputable section

namespace Complex

open ComplexConjugate Topology

instance : HasNorm ℂ :=
  ⟨abs⟩

@[simp]
theorem norm_eq_abs (z : ℂ) : ‖z‖ = abs z :=
  rfl
#align complex.norm_eq_abs Complex.norm_eq_abs

instance : NormedAddCommGroup ℂ :=
  AddGroupNorm.toNormedAddCommGroup
    { abs with
      map_zero' := map_zero abs
      neg' := abs.map_neg
      eq_zero_of_map_eq_zero' := fun _ => abs.eq_zero.1 }

instance : NormedField ℂ :=
  { Complex.field,
    Complex.normedAddCommGroup with
    norm := abs
    dist_eq := fun _ _ => rfl
    norm_mul' := map_mul abs }

instance : DenselyNormedField ℂ
    where lt_norm_lt r₁ r₂ h₀ hr :=
    let ⟨x, h⟩ := NormedField.exists_lt_norm_lt ℝ h₀ hr
    have this : ‖(‖x‖ : ℂ)‖ = ‖‖x‖‖ := by simp only [norm_eq_abs, abs_of_real, Real.norm_eq_abs]
    ⟨‖x‖, by rwa [this, norm_norm]⟩

instance {R : Type _} [NormedField R] [NormedAlgebra R ℝ] : NormedAlgebra R ℂ
    where
  norm_smul_le r x :=
    by
    rw [norm_eq_abs, norm_eq_abs, ← algebraMap_smul ℝ r x, Algebra.smul_def, map_mul, ←
      norm_algebra_map' ℝ r, coe_algebra_map, abs_of_real]
    rfl
  toAlgebra := Complex.algebra

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace ℂ E]

-- see Note [lower instance priority]
/-- The module structure from `module.complex_to_real` is a normed space. -/
instance (priority := 900) NormedSpace.complexToReal : NormedSpace ℝ E :=
  NormedSpace.restrictScalars ℝ ℂ E
#align normed_space.complex_to_real NormedSpace.complexToReal

theorem dist_eq (z w : ℂ) : dist z w = abs (z - w) :=
  rfl
#align complex.dist_eq Complex.dist_eq

theorem dist_eq_re_im (z w : ℂ) : dist z w = Real.sqrt ((z.re - w.re) ^ 2 + (z.im - w.im) ^ 2) :=
  by
  rw [sq, sq]
  rfl
#align complex.dist_eq_re_im Complex.dist_eq_re_im

@[simp]
theorem dist_mk (x₁ y₁ x₂ y₂ : ℝ) :
    dist (mk x₁ y₁) (mk x₂ y₂) = Real.sqrt ((x₁ - x₂) ^ 2 + (y₁ - y₂) ^ 2) :=
  dist_eq_re_im _ _
#align complex.dist_mk Complex.dist_mk

theorem dist_of_re_eq {z w : ℂ} (h : z.re = w.re) : dist z w = dist z.im w.im := by
  rw [dist_eq_re_im, h, sub_self, zero_pow two_pos, zero_add, Real.sqrt_sq_eq_abs, Real.dist_eq]
#align complex.dist_of_re_eq Complex.dist_of_re_eq

theorem nndist_of_re_eq {z w : ℂ} (h : z.re = w.re) : nndist z w = nndist z.im w.im :=
  Nnreal.eq <| dist_of_re_eq h
#align complex.nndist_of_re_eq Complex.nndist_of_re_eq

theorem edist_of_re_eq {z w : ℂ} (h : z.re = w.re) : edist z w = edist z.im w.im := by
  rw [edist_nndist, edist_nndist, nndist_of_re_eq h]
#align complex.edist_of_re_eq Complex.edist_of_re_eq

theorem dist_of_im_eq {z w : ℂ} (h : z.im = w.im) : dist z w = dist z.re w.re := by
  rw [dist_eq_re_im, h, sub_self, zero_pow two_pos, add_zero, Real.sqrt_sq_eq_abs, Real.dist_eq]
#align complex.dist_of_im_eq Complex.dist_of_im_eq

theorem nndist_of_im_eq {z w : ℂ} (h : z.im = w.im) : nndist z w = nndist z.re w.re :=
  Nnreal.eq <| dist_of_im_eq h
#align complex.nndist_of_im_eq Complex.nndist_of_im_eq

theorem edist_of_im_eq {z w : ℂ} (h : z.im = w.im) : edist z w = edist z.re w.re := by
  rw [edist_nndist, edist_nndist, nndist_of_im_eq h]
#align complex.edist_of_im_eq Complex.edist_of_im_eq

theorem dist_conj_self (z : ℂ) : dist (conj z) z = 2 * |z.im| := by
  rw [dist_of_re_eq (conj_re z), conj_im, dist_comm, Real.dist_eq, sub_neg_eq_add, ← two_mul,
    _root_.abs_mul, abs_of_pos (zero_lt_two' ℝ)]
#align complex.dist_conj_self Complex.dist_conj_self

theorem nndist_conj_self (z : ℂ) : nndist (conj z) z = 2 * Real.nnabs z.im :=
  Nnreal.eq <| by rw [← dist_nndist, Nnreal.coe_mul, Nnreal.coe_two, Real.coe_nnabs, dist_conj_self]
#align complex.nndist_conj_self Complex.nndist_conj_self

theorem dist_self_conj (z : ℂ) : dist z (conj z) = 2 * |z.im| := by rw [dist_comm, dist_conj_self]
#align complex.dist_self_conj Complex.dist_self_conj

theorem nndist_self_conj (z : ℂ) : nndist z (conj z) = 2 * Real.nnabs z.im := by
  rw [nndist_comm, nndist_conj_self]
#align complex.nndist_self_conj Complex.nndist_self_conj

@[simp]
theorem comap_abs_nhds_zero : Filter.comap abs (𝓝 0) = 𝓝 0 :=
  comap_norm_nhds_zero
#align complex.comap_abs_nhds_zero Complex.comap_abs_nhds_zero

theorem norm_real (r : ℝ) : ‖(r : ℂ)‖ = ‖r‖ :=
  abs_of_real _
#align complex.norm_real Complex.norm_real

@[simp]
theorem norm_rat (r : ℚ) : ‖(r : ℂ)‖ = |(r : ℝ)| :=
  by
  rw [← of_real_rat_cast]
  exact norm_real _
#align complex.norm_rat Complex.norm_rat

@[simp]
theorem norm_nat (n : ℕ) : ‖(n : ℂ)‖ = n :=
  abs_of_nat _
#align complex.norm_nat Complex.norm_nat

@[simp]
theorem norm_int {n : ℤ} : ‖(n : ℂ)‖ = |n| := by
  simp (config := { singlePass := true }) [← Rat.cast_coe_int]
#align complex.norm_int Complex.norm_int

theorem norm_int_of_nonneg {n : ℤ} (hn : 0 ≤ n) : ‖(n : ℂ)‖ = n := by simp [hn]
#align complex.norm_int_of_nonneg Complex.norm_int_of_nonneg

@[continuity]
theorem continuous_abs : Continuous abs :=
  continuous_norm
#align complex.continuous_abs Complex.continuous_abs

@[continuity]
theorem continuous_normSq : Continuous normSq := by
  simpa [← norm_sq_eq_abs] using continuous_abs.pow 2
#align complex.continuous_norm_sq Complex.continuous_normSq

@[simp, norm_cast]
theorem nnnorm_real (r : ℝ) : ‖(r : ℂ)‖₊ = ‖r‖₊ :=
  Subtype.ext <| norm_real r
#align complex.nnnorm_real Complex.nnnorm_real

@[simp, norm_cast]
theorem nnnorm_nat (n : ℕ) : ‖(n : ℂ)‖₊ = n :=
  Subtype.ext <| by simp
#align complex.nnnorm_nat Complex.nnnorm_nat

@[simp, norm_cast]
theorem nnnorm_int (n : ℤ) : ‖(n : ℂ)‖₊ = ‖n‖₊ :=
  Subtype.ext <| by simp only [coe_nnnorm, norm_int, Int.norm_eq_abs]
#align complex.nnnorm_int Complex.nnnorm_int

theorem nnnorm_eq_one_of_pow_eq_one {ζ : ℂ} {n : ℕ} (h : ζ ^ n = 1) (hn : n ≠ 0) : ‖ζ‖₊ = 1 :=
  by
  refine' (@pow_left_inj Nnreal _ _ _ _ zero_le' zero_le' hn.bot_lt).mp _
  rw [← nnnorm_pow, h, nnnorm_one, one_pow]
#align complex.nnnorm_eq_one_of_pow_eq_one Complex.nnnorm_eq_one_of_pow_eq_one

theorem norm_eq_one_of_pow_eq_one {ζ : ℂ} {n : ℕ} (h : ζ ^ n = 1) (hn : n ≠ 0) : ‖ζ‖ = 1 :=
  congr_arg coe (nnnorm_eq_one_of_pow_eq_one h hn)
#align complex.norm_eq_one_of_pow_eq_one Complex.norm_eq_one_of_pow_eq_one

theorem equivRealProd_apply_le (z : ℂ) : ‖equivRealProd z‖ ≤ abs z := by
  simp [Prod.norm_def, abs_re_le_abs, abs_im_le_abs]
#align complex.equiv_real_prod_apply_le Complex.equivRealProd_apply_le

theorem equivRealProd_apply_le' (z : ℂ) : ‖equivRealProd z‖ ≤ 1 * abs z := by
  simpa using equiv_real_prod_apply_le z
#align complex.equiv_real_prod_apply_le' Complex.equivRealProd_apply_le'

theorem lipschitz_equivRealProd : LipschitzWith 1 equivRealProd := by
  simpa using AddMonoidHomClass.lipschitz_of_bound equiv_real_prod_lm 1 equiv_real_prod_apply_le'
#align complex.lipschitz_equiv_real_prod Complex.lipschitz_equivRealProd

theorem antilipschitz_equivRealProd : AntilipschitzWith (Nnreal.sqrt 2) equivRealProd := by
  simpa using AddMonoidHomClass.antilipschitz_of_bound equiv_real_prod_lm abs_le_sqrt_two_mul_max
#align complex.antilipschitz_equiv_real_prod Complex.antilipschitz_equivRealProd

theorem uniformEmbedding_equivRealProd : UniformEmbedding equivRealProd :=
  antilipschitz_equivRealProd.UniformEmbedding lipschitz_equivRealProd.UniformContinuous
#align complex.uniform_embedding_equiv_real_prod Complex.uniformEmbedding_equivRealProd

instance : CompleteSpace ℂ :=
  (completeSpace_congr uniformEmbedding_equivRealProd).mpr inferInstance

/-- The natural `continuous_linear_equiv` from `ℂ` to `ℝ × ℝ`. -/
@[simps (config := { simpRhs := true }) apply symm_apply_re symm_apply_im]
def equivRealProdClm : ℂ ≃L[ℝ] ℝ × ℝ :=
  equivRealProdLm.toContinuousLinearEquivOfBounds 1 (Real.sqrt 2) equivRealProd_apply_le' fun p =>
    abs_le_sqrt_two_mul_max (equivRealProd.symm p)
#align complex.equiv_real_prod_clm Complex.equivRealProdClm

instance : ProperSpace ℂ :=
  (id lipschitz_equivRealProd : LipschitzWith 1 equivRealProdClm.toHomeomorph).ProperSpace

/-- The `abs` function on `ℂ` is proper. -/
theorem tendsto_abs_cocompact_atTop : Filter.Tendsto abs (Filter.cocompact ℂ) Filter.atTop :=
  tendsto_norm_cocompact_atTop
#align complex.tendsto_abs_cocompact_at_top Complex.tendsto_abs_cocompact_atTop

/-- The `norm_sq` function on `ℂ` is proper. -/
theorem tendsto_normSq_cocompact_atTop : Filter.Tendsto normSq (Filter.cocompact ℂ) Filter.atTop :=
  by
  simpa [mul_self_abs] using
    tendsto_abs_cocompact_at_top.at_top_mul_at_top tendsto_abs_cocompact_at_top
#align complex.tendsto_norm_sq_cocompact_at_top Complex.tendsto_normSq_cocompact_atTop

open ContinuousLinearMap

/-- Continuous linear map version of the real part function, from `ℂ` to `ℝ`. -/
def reClm : ℂ →L[ℝ] ℝ :=
  reLm.mkContinuous 1 fun x => by simp [abs_re_le_abs]
#align complex.re_clm Complex.reClm

@[continuity]
theorem continuous_re : Continuous re :=
  reClm.Continuous
#align complex.continuous_re Complex.continuous_re

@[simp]
theorem reClm_coe : (coe reClm : ℂ →ₗ[ℝ] ℝ) = reLm :=
  rfl
#align complex.re_clm_coe Complex.reClm_coe

@[simp]
theorem reClm_apply (z : ℂ) : (reClm : ℂ → ℝ) z = z.re :=
  rfl
#align complex.re_clm_apply Complex.reClm_apply

/-- Continuous linear map version of the real part function, from `ℂ` to `ℝ`. -/
def imClm : ℂ →L[ℝ] ℝ :=
  imLm.mkContinuous 1 fun x => by simp [abs_im_le_abs]
#align complex.im_clm Complex.imClm

@[continuity]
theorem continuous_im : Continuous im :=
  imClm.Continuous
#align complex.continuous_im Complex.continuous_im

@[simp]
theorem imClm_coe : (coe imClm : ℂ →ₗ[ℝ] ℝ) = imLm :=
  rfl
#align complex.im_clm_coe Complex.imClm_coe

@[simp]
theorem imClm_apply (z : ℂ) : (imClm : ℂ → ℝ) z = z.im :=
  rfl
#align complex.im_clm_apply Complex.imClm_apply

theorem restrictScalars_one_smul_right' (x : E) :
    ContinuousLinearMap.restrictScalars ℝ ((1 : ℂ →L[ℂ] ℂ).smul_right x : ℂ →L[ℂ] E) =
      reClm.smul_right x + i • imClm.smul_right x :=
  by
  ext ⟨a, b⟩
  simp [mk_eq_add_mul_I, add_smul, mul_smul, smul_comm I]
#align complex.restrict_scalars_one_smul_right' Complex.restrictScalars_one_smul_right'

theorem restrictScalars_one_smulRight (x : ℂ) :
    ContinuousLinearMap.restrictScalars ℝ ((1 : ℂ →L[ℂ] ℂ).smul_right x : ℂ →L[ℂ] ℂ) = x • 1 :=
  by
  ext1 z
  dsimp
  apply mul_comm
#align complex.restrict_scalars_one_smul_right Complex.restrictScalars_one_smulRight

/-- The complex-conjugation function from `ℂ` to itself is an isometric linear equivalence. -/
def conjLie : ℂ ≃ₗᵢ[ℝ] ℂ :=
  ⟨conjAe.toLinearEquiv, abs_conj⟩
#align complex.conj_lie Complex.conjLie

@[simp]
theorem conjLie_apply (z : ℂ) : conjLie z = conj z :=
  rfl
#align complex.conj_lie_apply Complex.conjLie_apply

@[simp]
theorem conjLie_symm : conjLie.symm = conjLie :=
  rfl
#align complex.conj_lie_symm Complex.conjLie_symm

theorem isometry_conj : Isometry (conj : ℂ → ℂ) :=
  conjLie.Isometry
#align complex.isometry_conj Complex.isometry_conj

@[simp]
theorem dist_conj_conj (z w : ℂ) : dist (conj z) (conj w) = dist z w :=
  isometry_conj.dist_eq z w
#align complex.dist_conj_conj Complex.dist_conj_conj

@[simp]
theorem nndist_conj_conj (z w : ℂ) : nndist (conj z) (conj w) = nndist z w :=
  isometry_conj.nndist_eq z w
#align complex.nndist_conj_conj Complex.nndist_conj_conj

theorem dist_conj_comm (z w : ℂ) : dist (conj z) w = dist z (conj w) := by
  rw [← dist_conj_conj, conj_conj]
#align complex.dist_conj_comm Complex.dist_conj_comm

theorem nndist_conj_comm (z w : ℂ) : nndist (conj z) w = nndist z (conj w) :=
  Subtype.ext <| dist_conj_comm _ _
#align complex.nndist_conj_comm Complex.nndist_conj_comm

instance : HasContinuousStar ℂ :=
  ⟨conjLie.Continuous⟩

@[continuity]
theorem continuous_conj : Continuous (conj : ℂ → ℂ) :=
  continuous_star
#align complex.continuous_conj Complex.continuous_conj

/-- The only continuous ring homomorphisms from `ℂ` to `ℂ` are the identity and the complex
conjugation. -/
theorem ringHom_eq_id_or_conj_of_continuous {f : ℂ →+* ℂ} (hf : Continuous f) :
    f = RingHom.id ℂ ∨ f = conj :=
  by
  refine'
    (real_alg_hom_eq_id_or_conj <| AlgHom.mk' f <| map_real_smul f hf).imp (fun h => _) fun h => _
  all_goals convert congr_arg AlgHom.toRingHom h; ext1; rfl
#align complex.ring_hom_eq_id_or_conj_of_continuous Complex.ringHom_eq_id_or_conj_of_continuous

/-- Continuous linear equiv version of the conj function, from `ℂ` to `ℂ`. -/
def conjCle : ℂ ≃L[ℝ] ℂ :=
  conjLie
#align complex.conj_cle Complex.conjCle

@[simp]
theorem conjCle_coe : conjCle.toLinearEquiv = conjAe.toLinearEquiv :=
  rfl
#align complex.conj_cle_coe Complex.conjCle_coe

@[simp]
theorem conjCle_apply (z : ℂ) : conjCle z = conj z :=
  rfl
#align complex.conj_cle_apply Complex.conjCle_apply

/-- Linear isometry version of the canonical embedding of `ℝ` in `ℂ`. -/
def ofRealLi : ℝ →ₗᵢ[ℝ] ℂ :=
  ⟨ofRealAm.toLinearMap, norm_real⟩
#align complex.of_real_li Complex.ofRealLi

theorem isometry_of_real : Isometry (coe : ℝ → ℂ) :=
  ofRealLi.Isometry
#align complex.isometry_of_real Complex.isometry_of_real

@[continuity]
theorem continuous_of_real : Continuous (coe : ℝ → ℂ) :=
  ofRealLi.Continuous
#align complex.continuous_of_real Complex.continuous_of_real

/-- The only continuous ring homomorphism from `ℝ` to `ℂ` is the identity. -/
theorem ringHom_eq_ofReal_of_continuous {f : ℝ →+* ℂ} (h : Continuous f) : f = Complex.ofReal :=
  by
  convert
    congr_arg AlgHom.toRingHom
      (Subsingleton.elim (AlgHom.mk' f <| map_real_smul f h) <| Algebra.ofId ℝ ℂ)
  ext1; rfl
#align complex.ring_hom_eq_of_real_of_continuous Complex.ringHom_eq_ofReal_of_continuous

/-- Continuous linear map version of the canonical embedding of `ℝ` in `ℂ`. -/
def ofRealClm : ℝ →L[ℝ] ℂ :=
  ofRealLi.toContinuousLinearMap
#align complex.of_real_clm Complex.ofRealClm

@[simp]
theorem ofRealClm_coe : (ofRealClm : ℝ →ₗ[ℝ] ℂ) = ofRealAm.toLinearMap :=
  rfl
#align complex.of_real_clm_coe Complex.ofRealClm_coe

@[simp]
theorem ofRealClm_apply (x : ℝ) : ofRealClm x = x :=
  rfl
#align complex.of_real_clm_apply Complex.ofRealClm_apply

noncomputable instance : IsROrC ℂ
    where
  re := ⟨Complex.re, Complex.zero_re, Complex.add_re⟩
  im := ⟨Complex.im, Complex.zero_im, Complex.add_im⟩
  i := Complex.i
  i_re_ax := by simp only [AddMonoidHom.coe_mk, Complex.i_re]
  i_mul_i_ax := by simp only [Complex.i_mul_i, eq_self_iff_true, or_true_iff]
  re_add_im_ax z := by
    simp only [AddMonoidHom.coe_mk, Complex.re_add_im, Complex.coe_algebraMap,
      Complex.ofReal_eq_coe]
  of_real_re_ax r := by
    simp only [AddMonoidHom.coe_mk, Complex.of_real_re, Complex.coe_algebraMap,
      Complex.ofReal_eq_coe]
  of_real_im_ax r := by
    simp only [AddMonoidHom.coe_mk, Complex.of_real_im, Complex.coe_algebraMap,
      Complex.ofReal_eq_coe]
  mul_re_ax z w := by simp only [Complex.mul_re, AddMonoidHom.coe_mk]
  mul_im_ax z w := by simp only [AddMonoidHom.coe_mk, Complex.mul_im]
  conj_re_ax z := rfl
  conj_im_ax z := rfl
  conj_i_ax := by simp only [Complex.conj_i, RingHom.coe_mk]
  norm_sq_eq_def_ax z := by
    simp only [← Complex.normSq_eq_abs, ← Complex.normSq_apply, AddMonoidHom.coe_mk,
      Complex.norm_eq_abs]
  mul_im_i_ax z := by simp only [mul_one, AddMonoidHom.coe_mk, Complex.i_im]
  inv_def_ax z := by
    simp only [Complex.inv_def, Complex.normSq_eq_abs, Complex.coe_algebraMap,
      Complex.ofReal_eq_coe, Complex.norm_eq_abs]
  div_i_ax := Complex.div_i

theorem IsROrC.re_eq_complex_re : ⇑(IsROrC.re : ℂ →+ ℝ) = Complex.re :=
  rfl
#align is_R_or_C.re_eq_complex_re IsROrC.re_eq_complex_re

theorem IsROrC.im_eq_complex_im : ⇑(IsROrC.im : ℂ →+ ℝ) = Complex.im :=
  rfl
#align is_R_or_C.im_eq_complex_im IsROrC.im_eq_complex_im

section ComplexOrder

open ComplexOrder

theorem eq_coe_norm_of_nonneg {z : ℂ} (hz : 0 ≤ z) : z = ↑‖z‖ := by
  rw [eq_re_of_real_le hz, IsROrC.norm_of_real, Real.norm_of_nonneg (Complex.le_def.2 hz).1]
#align complex.eq_coe_norm_of_nonneg Complex.eq_coe_norm_of_nonneg

end ComplexOrder

theorem hasSum_iff {α} (f : α → ℂ) (c : ℂ) :
    HasSum f c ↔ HasSum (fun x => (f x).re) c.re ∧ HasSum (fun x => (f x).im) c.im :=
  by
  -- For some reason, `continuous_linear_map.has_sum` is orders of magnitude faster than
  -- `has_sum.mapL` here:
  refine' ⟨fun h => ⟨re_clm.has_sum h, im_clm.has_sum h⟩, _⟩
  rintro ⟨h₁, h₂⟩
  convert (h₁.prod_mk h₂).mapL equiv_real_prod_clm.symm.to_continuous_linear_map
  · ext x <;> rfl
  · cases c
    rfl
#align complex.has_sum_iff Complex.hasSum_iff

end Complex

namespace IsROrC

-- mathport name: exprreC
local notation "reC" => @IsROrC.re ℂ _

-- mathport name: exprimC
local notation "imC" => @IsROrC.im ℂ _

-- mathport name: exprIC
local notation "IC" => @IsROrC.i ℂ _

-- mathport name: exprabsC
local notation "absC" => @IsROrC.abs ℂ _

-- mathport name: exprnorm_sqC
local notation "norm_sqC" => @IsROrC.normSq ℂ _

@[simp]
theorem re_to_complex {x : ℂ} : reC x = x.re :=
  rfl
#align is_R_or_C.re_to_complex IsROrC.re_to_complex

@[simp]
theorem im_to_complex {x : ℂ} : imC x = x.im :=
  rfl
#align is_R_or_C.im_to_complex IsROrC.im_to_complex

@[simp]
theorem i_to_complex : IC = Complex.i :=
  rfl
#align is_R_or_C.I_to_complex IsROrC.i_to_complex

@[simp]
theorem normSq_to_complex {x : ℂ} : norm_sqC x = Complex.normSq x := by
  simp [IsROrC.normSq, Complex.normSq]
#align is_R_or_C.norm_sq_to_complex IsROrC.normSq_to_complex

@[simp]
theorem abs_to_complex {x : ℂ} : absC x = Complex.abs x := by simp [IsROrC.abs, Complex.abs]
#align is_R_or_C.abs_to_complex IsROrC.abs_to_complex

end IsROrC

