/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Abhimanyu Pallavi Sudhir, Jean Lo, Calle Sönne, Benjamin Davidson

! This file was ported from Lean 3 source module analysis.special_functions.trigonometric.arctan
! leanprover-community/mathlib commit 422e70f7ce183d2900c586a8cda8381e788a0c62
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecialFunctions.Trigonometric.Complex

/-!
# The `arctan` function.

Inequalities, derivatives,
and `real.tan` as a `local_homeomorph` between `(-(π / 2), π / 2)` and the whole line.
-/


noncomputable section

namespace Real

open Set Filter

open TopologicalSpace Real

theorem tan_add {x y : ℝ}
    (h :
      ((∀ k : ℤ, x ≠ (2 * k + 1) * π / 2) ∧ ∀ l : ℤ, y ≠ (2 * l + 1) * π / 2) ∨
        (∃ k : ℤ, x = (2 * k + 1) * π / 2) ∧ ∃ l : ℤ, y = (2 * l + 1) * π / 2) :
    tan (x + y) = (tan x + tan y) / (1 - tan x * tan y) := by
  simpa only [← Complex.of_real_inj, Complex.of_real_sub, Complex.of_real_add, Complex.of_real_div,
    Complex.of_real_mul, Complex.of_real_tan] using
    @Complex.tan_add (x : ℂ) (y : ℂ) (by convert h <;> norm_cast)
#align real.tan_add Real.tan_add

theorem tan_add' {x y : ℝ}
    (h : (∀ k : ℤ, x ≠ (2 * k + 1) * π / 2) ∧ ∀ l : ℤ, y ≠ (2 * l + 1) * π / 2) :
    tan (x + y) = (tan x + tan y) / (1 - tan x * tan y) :=
  tan_add (Or.inl h)
#align real.tan_add' Real.tan_add'

theorem tan_two_mul {x : ℝ} : tan (2 * x) = 2 * tan x / (1 - tan x ^ 2) := by
  simpa only [← Complex.of_real_inj, Complex.of_real_sub, Complex.of_real_div, Complex.of_real_pow,
    Complex.of_real_mul, Complex.of_real_tan, Complex.of_real_bit0, Complex.of_real_one] using
    Complex.tan_two_mul
#align real.tan_two_mul Real.tan_two_mul

theorem tan_ne_zero_iff {θ : ℝ} : tan θ ≠ 0 ↔ ∀ k : ℤ, θ ≠ k * π / 2 := by
  rw [← Complex.of_real_ne_zero, Complex.of_real_tan, Complex.tan_ne_zero_iff] <;> norm_cast
#align real.tan_ne_zero_iff Real.tan_ne_zero_iff

theorem tan_eq_zero_iff {θ : ℝ} : tan θ = 0 ↔ ∃ k : ℤ, θ = k * π / 2 := by
  rw [← not_iff_not, not_exists, ← Ne, tan_ne_zero_iff]
#align real.tan_eq_zero_iff Real.tan_eq_zero_iff

theorem tan_int_mul_pi_div_two (n : ℤ) : tan (n * π / 2) = 0 :=
  tan_eq_zero_iff.mpr (by use n)
#align real.tan_int_mul_pi_div_two Real.tan_int_mul_pi_div_two

theorem continuous_on_tan : ContinuousOn tan { x | cos x ≠ 0 } :=
  by
  suffices ContinuousOn (fun x => sin x / cos x) { x | cos x ≠ 0 }
    by
    have h_eq : (fun x => sin x / cos x) = tan :=
      by
      ext1 x
      rw [tan_eq_sin_div_cos]
    rwa [h_eq] at this
  exact continuous_on_sin.div continuous_on_cos fun x => id
#align real.continuous_on_tan Real.continuous_on_tan

@[continuity]
theorem continuous_tan : Continuous fun x : { x | cos x ≠ 0 } => tan x :=
  continuous_on_iff_continuous_restrict.1 continuous_on_tan
#align real.continuous_tan Real.continuous_tan

theorem continuous_on_tan_Ioo : ContinuousOn tan (Ioo (-(π / 2)) (π / 2)) :=
  by
  refine' ContinuousOn.mono continuous_on_tan fun x => _
  simp only [and_imp, mem_Ioo, mem_set_of_eq, Ne.def]
  rw [cos_eq_zero_iff]
  rintro hx_gt hx_lt ⟨r, hxr_eq⟩
  cases le_or_lt 0 r
  · rw [lt_iff_not_ge] at hx_lt
    refine' hx_lt _
    rw [hxr_eq, ← one_mul (π / 2), mul_div_assoc, ge_iff_le, mul_le_mul_right (half_pos pi_pos)]
    simp [h]
  · rw [lt_iff_not_ge] at hx_gt
    refine' hx_gt _
    rw [hxr_eq, ← one_mul (π / 2), mul_div_assoc, ge_iff_le, neg_mul_eq_neg_mul,
      mul_le_mul_right (half_pos pi_pos)]
    have hr_le : r ≤ -1 := by rwa [Int.lt_iff_add_one_le, ← le_neg_iff_add_nonpos_right] at h
    rw [← le_sub_iff_add_le, mul_comm, ← le_div_iff]
    · norm_num
      rw [← Int.cast_one, ← Int.cast_neg]
      norm_cast
      exact hr_le
    · exact zero_lt_two
#align real.continuous_on_tan_Ioo Real.continuous_on_tan_Ioo

theorem surj_on_tan : SurjOn tan (Ioo (-(π / 2)) (π / 2)) univ :=
  have := neg_lt_self pi_div_two_pos
  continuous_on_tan_Ioo.surj_on_of_tendsto (nonempty_Ioo.2 this)
    (by simp [tendsto_tan_neg_pi_div_two, this]) (by simp [tendsto_tan_pi_div_two, this])
#align real.surj_on_tan Real.surj_on_tan

theorem tan_surjective : Function.Surjective tan := fun x => surj_on_tan.subset_range trivial
#align real.tan_surjective Real.tan_surjective

theorem image_tan_Ioo : tan '' Ioo (-(π / 2)) (π / 2) = univ :=
  univ_subset_iff.1 surj_on_tan
#align real.image_tan_Ioo Real.image_tan_Ioo

/-- `real.tan` as an `order_iso` between `(-(π / 2), π / 2)` and `ℝ`. -/
def tanOrderIso : Ioo (-(π / 2)) (π / 2) ≃o ℝ :=
  (strict_mono_on_tan.OrderIso _ _).trans <|
    (OrderIso.setCongr _ _ image_tan_Ioo).trans OrderIso.Set.univ
#align real.tan_order_iso Real.tanOrderIso

/-- Inverse of the `tan` function, returns values in the range `-π / 2 < arctan x` and
`arctan x < π / 2` -/
@[pp_nodot]
noncomputable def arctan (x : ℝ) : ℝ :=
  tanOrderIso.symm x
#align real.arctan Real.arctan

@[simp]
theorem tan_arctan (x : ℝ) : tan (arctan x) = x :=
  tanOrderIso.apply_symm_apply x
#align real.tan_arctan Real.tan_arctan

theorem arctan_mem_Ioo (x : ℝ) : arctan x ∈ Ioo (-(π / 2)) (π / 2) :=
  Subtype.coe_prop _
#align real.arctan_mem_Ioo Real.arctan_mem_Ioo

@[simp]
theorem range_arctan : range arctan = Ioo (-(π / 2)) (π / 2) :=
  ((EquivLike.surjective _).range_comp _).trans Subtype.range_coe
#align real.range_arctan Real.range_arctan

theorem arctan_tan {x : ℝ} (hx₁ : -(π / 2) < x) (hx₂ : x < π / 2) : arctan (tan x) = x :=
  Subtype.ext_iff.1 <| tanOrderIso.symm_apply_apply ⟨x, hx₁, hx₂⟩
#align real.arctan_tan Real.arctan_tan

theorem cos_arctan_pos (x : ℝ) : 0 < cos (arctan x) :=
  cos_pos_of_mem_Ioo <| arctan_mem_Ioo x
#align real.cos_arctan_pos Real.cos_arctan_pos

theorem cos_sq_arctan (x : ℝ) : cos (arctan x) ^ 2 = 1 / (1 + x ^ 2) := by
  rw [one_div, ← inv_one_add_tan_sq (cos_arctan_pos x).ne', tan_arctan]
#align real.cos_sq_arctan Real.cos_sq_arctan

theorem sin_arctan (x : ℝ) : sin (arctan x) = x / sqrt (1 + x ^ 2) := by
  rw [← tan_div_sqrt_one_add_tan_sq (cos_arctan_pos x), tan_arctan]
#align real.sin_arctan Real.sin_arctan

theorem cos_arctan (x : ℝ) : cos (arctan x) = 1 / sqrt (1 + x ^ 2) := by
  rw [one_div, ← inv_sqrt_one_add_tan_sq (cos_arctan_pos x), tan_arctan]
#align real.cos_arctan Real.cos_arctan

theorem arctan_lt_pi_div_two (x : ℝ) : arctan x < π / 2 :=
  (arctan_mem_Ioo x).2
#align real.arctan_lt_pi_div_two Real.arctan_lt_pi_div_two

theorem neg_pi_div_two_lt_arctan (x : ℝ) : -(π / 2) < arctan x :=
  (arctan_mem_Ioo x).1
#align real.neg_pi_div_two_lt_arctan Real.neg_pi_div_two_lt_arctan

theorem arctan_eq_arcsin (x : ℝ) : arctan x = arcsin (x / sqrt (1 + x ^ 2)) :=
  Eq.symm <| arcsin_eq_of_sin_eq (sin_arctan x) (mem_Icc_of_Ioo <| arctan_mem_Ioo x)
#align real.arctan_eq_arcsin Real.arctan_eq_arcsin

theorem arcsin_eq_arctan {x : ℝ} (h : x ∈ Ioo (-(1 : ℝ)) 1) :
    arcsin x = arctan (x / sqrt (1 - x ^ 2)) := by
  rw [arctan_eq_arcsin, div_pow, sq_sqrt, one_add_div, div_div, ← sqrt_mul, mul_div_cancel',
      sub_add_cancel, sqrt_one, div_one] <;>
    nlinarith [h.1, h.2]
#align real.arcsin_eq_arctan Real.arcsin_eq_arctan

@[simp]
theorem arctan_zero : arctan 0 = 0 := by simp [arctan_eq_arcsin]
#align real.arctan_zero Real.arctan_zero

theorem arctan_eq_of_tan_eq {x y : ℝ} (h : tan x = y) (hx : x ∈ Ioo (-(π / 2)) (π / 2)) :
    arctan y = x :=
  inj_on_tan (arctan_mem_Ioo _) hx (by rw [tan_arctan, h])
#align real.arctan_eq_of_tan_eq Real.arctan_eq_of_tan_eq

@[simp]
theorem arctan_one : arctan 1 = π / 4 :=
  arctan_eq_of_tan_eq tan_pi_div_four <| by constructor <;> linarith [pi_pos]
#align real.arctan_one Real.arctan_one

@[simp]
theorem arctan_neg (x : ℝ) : arctan (-x) = -arctan x := by simp [arctan_eq_arcsin, neg_div]
#align real.arctan_neg Real.arctan_neg

theorem arctan_eq_arccos {x : ℝ} (h : 0 ≤ x) : arctan x = arccos (sqrt (1 + x ^ 2))⁻¹ :=
  by
  rw [arctan_eq_arcsin, arccos_eq_arcsin]; swap; · exact inv_nonneg.2 (sqrt_nonneg _)
  congr 1
  rw [← sqrt_inv, sq_sqrt, ← one_div, one_sub_div, add_sub_cancel', sqrt_div, sqrt_sq h]
  all_goals positivity
#align real.arctan_eq_arccos Real.arctan_eq_arccos

-- The junk values for `arccos` and `sqrt` make this true even for `1 < x`.
theorem arccos_eq_arctan {x : ℝ} (h : 0 < x) : arccos x = arctan (sqrt (1 - x ^ 2) / x) :=
  by
  rw [arccos, eq_comm]
  refine' arctan_eq_of_tan_eq _ ⟨_, _⟩
  · rw [tan_pi_div_two_sub, tan_arcsin, inv_div]
  · linarith only [arcsin_le_pi_div_two x, pi_pos]
  · linarith only [arcsin_pos.2 h]
#align real.arccos_eq_arctan Real.arccos_eq_arctan

@[continuity]
theorem continuous_arctan : Continuous arctan :=
  continuous_subtype_coe.comp tanOrderIso.toHomeomorph.continuous_inv_fun
#align real.continuous_arctan Real.continuous_arctan

theorem continuous_at_arctan {x : ℝ} : ContinuousAt arctan x :=
  continuous_arctan.ContinuousAt
#align real.continuous_at_arctan Real.continuous_at_arctan

/-- `real.tan` as a `local_homeomorph` between `(-(π / 2), π / 2)` and the whole line. -/
def tanLocalHomeomorph : LocalHomeomorph ℝ ℝ
    where
  toFun := tan
  invFun := arctan
  source := Ioo (-(π / 2)) (π / 2)
  target := univ
  map_source' := mapsTo_univ _ _
  map_target' y hy := arctan_mem_Ioo y
  left_inv' x hx := arctan_tan hx.1 hx.2
  right_inv' y hy := tan_arctan y
  open_source := is_open_Ioo
  open_target := is_open_univ
  continuous_to_fun := continuous_on_tan_Ioo
  continuous_inv_fun := continuous_arctan.ContinuousOn
#align real.tan_local_homeomorph Real.tanLocalHomeomorph

@[simp]
theorem coe_tan_local_homeomorph : ⇑tan_local_homeomorph = tan :=
  rfl
#align real.coe_tan_local_homeomorph Real.coe_tan_local_homeomorph

@[simp]
theorem coe_tan_local_homeomorph_symm : ⇑tanLocalHomeomorph.symm = arctan :=
  rfl
#align real.coe_tan_local_homeomorph_symm Real.coe_tan_local_homeomorph_symm

end Real

