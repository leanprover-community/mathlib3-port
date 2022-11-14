/-
Copyright (c) 2022 Joseph Myers. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Myers
-/
import Mathbin.Analysis.Convex.Side
import Mathbin.Geometry.Euclidean.Angle.Oriented.Basic
import Mathbin.Geometry.Euclidean.Angle.Unoriented.Affine

/-!
# Oriented angles.

This file defines oriented angles in Euclidean affine spaces.

## Main definitions

* `euclidean_geometry.oangle`, with notation `∡`, is the oriented angle determined by three
  points.

-/


noncomputable section

open FiniteDimensional Complex

open EuclideanGeometry Real RealInnerProductSpace ComplexConjugate

namespace EuclideanGeometry

variable {V : Type _} {P : Type _} [InnerProductSpace ℝ V] [MetricSpace P]

variable [NormedAddTorsor V P] [hd2 : Fact (finrank ℝ V = 2)] [Module.Oriented ℝ V (Fin 2)]

include hd2

-- mathport name: expro
local notation "o" => Module.Oriented.positiveOrientation

/-- The oriented angle at `p₂` between the line segments to `p₁` and `p₃`, modulo `2 * π`. If
either of those points equals `p₂`, this is 0. See `euclidean_geometry.angle` for the
corresponding unoriented angle definition. -/
def oangle (p₁ p₂ p₃ : P) : Real.Angle :=
  o.oangle (p₁ -ᵥ p₂) (p₃ -ᵥ p₂)
#align euclidean_geometry.oangle EuclideanGeometry.oangle

-- mathport name: oangle
localized [EuclideanGeometry] notation "∡" => EuclideanGeometry.oangle

/-- Oriented angles are continuous when neither end point equals the middle point. -/
theorem continuous_at_oangle {x : P × P × P} (hx12 : x.1 ≠ x.2.1) (hx32 : x.2.2 ≠ x.2.1) :
    ContinuousAt (fun y : P × P × P => ∡ y.1 y.2.1 y.2.2) x := by
  let f : P × P × P → V × V := fun y => (y.1 -ᵥ y.2.1, y.2.2 -ᵥ y.2.1)
  have hf1 : (f x).1 ≠ 0 := by simp [hx12]
  have hf2 : (f x).2 ≠ 0 := by simp [hx32]
  exact
    (o.continuous_at_oangle hf1 hf2).comp
      ((continuous_fst.vsub continuous_snd.fst).prod_mk (continuous_snd.snd.vsub continuous_snd.fst)).ContinuousAt
#align euclidean_geometry.continuous_at_oangle EuclideanGeometry.continuous_at_oangle

/-- The angle ∡AAB at a point. -/
@[simp]
theorem oangle_self_left (p₁ p₂ : P) : ∡ p₁ p₁ p₂ = 0 := by simp [oangle]
#align euclidean_geometry.oangle_self_left EuclideanGeometry.oangle_self_left

/-- The angle ∡ABB at a point. -/
@[simp]
theorem oangle_self_right (p₁ p₂ : P) : ∡ p₁ p₂ p₂ = 0 := by simp [oangle]
#align euclidean_geometry.oangle_self_right EuclideanGeometry.oangle_self_right

/-- The angle ∡ABA at a point. -/
@[simp]
theorem oangle_self_left_right (p₁ p₂ : P) : ∡ p₁ p₂ p₁ = 0 :=
  o.oangle_self _
#align euclidean_geometry.oangle_self_left_right EuclideanGeometry.oangle_self_left_right

/-- Reversing the order of the points passed to `oangle` negates the angle. -/
theorem oangle_rev (p₁ p₂ p₃ : P) : ∡ p₃ p₂ p₁ = -∡ p₁ p₂ p₃ :=
  o.oangle_rev _ _
#align euclidean_geometry.oangle_rev EuclideanGeometry.oangle_rev

/-- Adding an angle to that with the order of the points reversed results in 0. -/
@[simp]
theorem oangle_add_oangle_rev (p₁ p₂ p₃ : P) : ∡ p₁ p₂ p₃ + ∡ p₃ p₂ p₁ = 0 :=
  o.oangle_add_oangle_rev _ _
#align euclidean_geometry.oangle_add_oangle_rev EuclideanGeometry.oangle_add_oangle_rev

/-- An oriented angle is zero if and only if the angle with the order of the points reversed is
zero. -/
theorem oangle_eq_zero_iff_oangle_rev_eq_zero {p₁ p₂ p₃ : P} : ∡ p₁ p₂ p₃ = 0 ↔ ∡ p₃ p₂ p₁ = 0 :=
  o.oangle_eq_zero_iff_oangle_rev_eq_zero
#align euclidean_geometry.oangle_eq_zero_iff_oangle_rev_eq_zero EuclideanGeometry.oangle_eq_zero_iff_oangle_rev_eq_zero

/-- An oriented angle is `π` if and only if the angle with the order of the points reversed is
`π`. -/
theorem oangle_eq_pi_iff_oangle_rev_eq_pi {p₁ p₂ p₃ : P} : ∡ p₁ p₂ p₃ = π ↔ ∡ p₃ p₂ p₁ = π :=
  o.oangle_eq_pi_iff_oangle_rev_eq_pi
#align euclidean_geometry.oangle_eq_pi_iff_oangle_rev_eq_pi EuclideanGeometry.oangle_eq_pi_iff_oangle_rev_eq_pi

/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:31:4: unsupported: too many args: fin_cases ... #[[]] -/
/-- An oriented angle is not zero or `π` if and only if the three points are affinely
independent. -/
theorem oangle_ne_zero_and_ne_pi_iff_affine_independent {p₁ p₂ p₃ : P} :
    ∡ p₁ p₂ p₃ ≠ 0 ∧ ∡ p₁ p₂ p₃ ≠ π ↔ AffineIndependent ℝ ![p₁, p₂, p₃] := by
  rw [oangle, o.oangle_ne_zero_and_ne_pi_iff_linear_independent,
    affine_independent_iff_linear_independent_vsub ℝ _ (1 : Fin 3), ←
    linear_independent_equiv (finSuccAboveEquiv (1 : Fin 3)).toEquiv]
  convert Iff.rfl
  ext i
  fin_cases i <;> rfl
#align
  euclidean_geometry.oangle_ne_zero_and_ne_pi_iff_affine_independent EuclideanGeometry.oangle_ne_zero_and_ne_pi_iff_affine_independent

/-- An oriented angle is zero or `π` if and only if the three points are collinear. -/
theorem oangle_eq_zero_or_eq_pi_iff_collinear {p₁ p₂ p₃ : P} :
    ∡ p₁ p₂ p₃ = 0 ∨ ∡ p₁ p₂ p₃ = π ↔ Collinear ℝ ({p₁, p₂, p₃} : Set P) := by
  rw [← not_iff_not, not_or, oangle_ne_zero_and_ne_pi_iff_affine_independent, affine_independent_iff_not_collinear]
  simp [-Set.union_singleton]
#align euclidean_geometry.oangle_eq_zero_or_eq_pi_iff_collinear EuclideanGeometry.oangle_eq_zero_or_eq_pi_iff_collinear

/-- Given three points not equal to `p`, the angle between the first and the second at `p` plus
the angle between the second and the third equals the angle between the first and the third. -/
@[simp]
theorem oangle_add {p p₁ p₂ p₃ : P} (hp₁ : p₁ ≠ p) (hp₂ : p₂ ≠ p) (hp₃ : p₃ ≠ p) : ∡ p₁ p p₂ + ∡ p₂ p p₃ = ∡ p₁ p p₃ :=
  o.oangle_add (vsub_ne_zero.2 hp₁) (vsub_ne_zero.2 hp₂) (vsub_ne_zero.2 hp₃)
#align euclidean_geometry.oangle_add EuclideanGeometry.oangle_add

/-- Given three points not equal to `p`, the angle between the second and the third at `p` plus
the angle between the first and the second equals the angle between the first and the third. -/
@[simp]
theorem oangle_add_swap {p p₁ p₂ p₃ : P} (hp₁ : p₁ ≠ p) (hp₂ : p₂ ≠ p) (hp₃ : p₃ ≠ p) :
    ∡ p₂ p p₃ + ∡ p₁ p p₂ = ∡ p₁ p p₃ :=
  o.oangle_add_swap (vsub_ne_zero.2 hp₁) (vsub_ne_zero.2 hp₂) (vsub_ne_zero.2 hp₃)
#align euclidean_geometry.oangle_add_swap EuclideanGeometry.oangle_add_swap

/-- Given three points not equal to `p`, the angle between the first and the third at `p` minus
the angle between the first and the second equals the angle between the second and the third. -/
@[simp]
theorem oangle_sub_left {p p₁ p₂ p₃ : P} (hp₁ : p₁ ≠ p) (hp₂ : p₂ ≠ p) (hp₃ : p₃ ≠ p) :
    ∡ p₁ p p₃ - ∡ p₁ p p₂ = ∡ p₂ p p₃ :=
  o.oangle_sub_left (vsub_ne_zero.2 hp₁) (vsub_ne_zero.2 hp₂) (vsub_ne_zero.2 hp₃)
#align euclidean_geometry.oangle_sub_left EuclideanGeometry.oangle_sub_left

/-- Given three points not equal to `p`, the angle between the first and the third at `p` minus
the angle between the second and the third equals the angle between the first and the second. -/
@[simp]
theorem oangle_sub_right {p p₁ p₂ p₃ : P} (hp₁ : p₁ ≠ p) (hp₂ : p₂ ≠ p) (hp₃ : p₃ ≠ p) :
    ∡ p₁ p p₃ - ∡ p₂ p p₃ = ∡ p₁ p p₂ :=
  o.oangle_sub_right (vsub_ne_zero.2 hp₁) (vsub_ne_zero.2 hp₂) (vsub_ne_zero.2 hp₃)
#align euclidean_geometry.oangle_sub_right EuclideanGeometry.oangle_sub_right

/-- Given three points not equal to `p`, adding the angles between them at `p` in cyclic order
results in 0. -/
@[simp]
theorem oangle_add_cyc3 {p p₁ p₂ p₃ : P} (hp₁ : p₁ ≠ p) (hp₂ : p₂ ≠ p) (hp₃ : p₃ ≠ p) :
    ∡ p₁ p p₂ + ∡ p₂ p p₃ + ∡ p₃ p p₁ = 0 :=
  o.oangle_add_cyc3 (vsub_ne_zero.2 hp₁) (vsub_ne_zero.2 hp₂) (vsub_ne_zero.2 hp₃)
#align euclidean_geometry.oangle_add_cyc3 EuclideanGeometry.oangle_add_cyc3

/-- Pons asinorum, oriented angle-at-point form. -/
theorem oangle_eq_oangle_of_dist_eq {p₁ p₂ p₃ : P} (h : dist p₁ p₂ = dist p₁ p₃) : ∡ p₁ p₂ p₃ = ∡ p₂ p₃ p₁ := by
  simp_rw [dist_eq_norm_vsub] at h
  rw [oangle, oangle, ← vsub_sub_vsub_cancel_left p₃ p₂ p₁, ← vsub_sub_vsub_cancel_left p₂ p₃ p₁,
    o.oangle_sub_eq_oangle_sub_rev_of_norm_eq h]
#align euclidean_geometry.oangle_eq_oangle_of_dist_eq EuclideanGeometry.oangle_eq_oangle_of_dist_eq

/-- The angle at the apex of an isosceles triangle is `π` minus twice a base angle, oriented
angle-at-point form. -/
theorem oangle_eq_pi_sub_two_zsmul_oangle_of_dist_eq {p₁ p₂ p₃ : P} (hn : p₂ ≠ p₃) (h : dist p₁ p₂ = dist p₁ p₃) :
    ∡ p₃ p₁ p₂ = π - (2 : ℤ) • ∡ p₁ p₂ p₃ := by
  simp_rw [dist_eq_norm_vsub] at h
  rw [oangle, oangle]
  convert o.oangle_eq_pi_sub_two_zsmul_oangle_sub_of_norm_eq _ h using 1
  · rw [← neg_vsub_eq_vsub_rev p₁ p₃, ← neg_vsub_eq_vsub_rev p₁ p₂, o.oangle_neg_neg]
    
  · rw [← o.oangle_sub_eq_oangle_sub_rev_of_norm_eq h]
    simp
    
  · simpa using hn
    
#align
  euclidean_geometry.oangle_eq_pi_sub_two_zsmul_oangle_of_dist_eq EuclideanGeometry.oangle_eq_pi_sub_two_zsmul_oangle_of_dist_eq

/-- The cosine of the oriented angle at `p` between two points not equal to `p` equals that of the
unoriented angle. -/
theorem cos_oangle_eq_cos_angle {p p₁ p₂ : P} (hp₁ : p₁ ≠ p) (hp₂ : p₂ ≠ p) :
    Real.Angle.cos (∡ p₁ p p₂) = Real.cos (∠ p₁ p p₂) :=
  o.cos_oangle_eq_cos_angle (vsub_ne_zero.2 hp₁) (vsub_ne_zero.2 hp₂)
#align euclidean_geometry.cos_oangle_eq_cos_angle EuclideanGeometry.cos_oangle_eq_cos_angle

/-- The oriented angle at `p` between two points not equal to `p` is plus or minus the unoriented
angle. -/
theorem oangle_eq_angle_or_eq_neg_angle {p p₁ p₂ : P} (hp₁ : p₁ ≠ p) (hp₂ : p₂ ≠ p) :
    ∡ p₁ p p₂ = ∠ p₁ p p₂ ∨ ∡ p₁ p p₂ = -∠ p₁ p p₂ :=
  o.oangle_eq_angle_or_eq_neg_angle (vsub_ne_zero.2 hp₁) (vsub_ne_zero.2 hp₂)
#align euclidean_geometry.oangle_eq_angle_or_eq_neg_angle EuclideanGeometry.oangle_eq_angle_or_eq_neg_angle

/-- The unoriented angle at `p` between two points not equal to `p` is the absolute value of the
oriented angle. -/
theorem angle_eq_abs_oangle_to_real {p p₁ p₂ : P} (hp₁ : p₁ ≠ p) (hp₂ : p₂ ≠ p) : ∠ p₁ p p₂ = |(∡ p₁ p p₂).toReal| :=
  o.angle_eq_abs_oangle_to_real (vsub_ne_zero.2 hp₁) (vsub_ne_zero.2 hp₂)
#align euclidean_geometry.angle_eq_abs_oangle_to_real EuclideanGeometry.angle_eq_abs_oangle_to_real

/-- If the sign of the oriented angle at `p` between two points is zero, either one of the points
equals `p` or the unoriented angle is 0 or π. -/
theorem eq_zero_or_angle_eq_zero_or_pi_of_sign_oangle_eq_zero {p p₁ p₂ : P} (h : (∡ p₁ p p₂).sign = 0) :
    p₁ = p ∨ p₂ = p ∨ ∠ p₁ p p₂ = 0 ∨ ∠ p₁ p p₂ = π := by
  convert o.eq_zero_or_angle_eq_zero_or_pi_of_sign_oangle_eq_zero h <;> simp
#align
  euclidean_geometry.eq_zero_or_angle_eq_zero_or_pi_of_sign_oangle_eq_zero EuclideanGeometry.eq_zero_or_angle_eq_zero_or_pi_of_sign_oangle_eq_zero

/-- If two unoriented angles are equal, and the signs of the corresponding oriented angles are
equal, then the oriented angles are equal (even in degenerate cases). -/
theorem oangle_eq_of_angle_eq_of_sign_eq {p₁ p₂ p₃ p₄ p₅ p₆ : P} (h : ∠ p₁ p₂ p₃ = ∠ p₄ p₅ p₆)
    (hs : (∡ p₁ p₂ p₃).sign = (∡ p₄ p₅ p₆).sign) : ∡ p₁ p₂ p₃ = ∡ p₄ p₅ p₆ :=
  o.oangle_eq_of_angle_eq_of_sign_eq h hs
#align euclidean_geometry.oangle_eq_of_angle_eq_of_sign_eq EuclideanGeometry.oangle_eq_of_angle_eq_of_sign_eq

/-- If the signs of two nondegenerate oriented angles between points are equal, the oriented
angles are equal if and only if the unoriented angles are equal. -/
theorem angle_eq_iff_oangle_eq_of_sign_eq {p₁ p₂ p₃ p₄ p₅ p₆ : P} (hp₁ : p₁ ≠ p₂) (hp₃ : p₃ ≠ p₂) (hp₄ : p₄ ≠ p₅)
    (hp₆ : p₆ ≠ p₅) (hs : (∡ p₁ p₂ p₃).sign = (∡ p₄ p₅ p₆).sign) : ∠ p₁ p₂ p₃ = ∠ p₄ p₅ p₆ ↔ ∡ p₁ p₂ p₃ = ∡ p₄ p₅ p₆ :=
  o.angle_eq_iff_oangle_eq_of_sign_eq (vsub_ne_zero.2 hp₁) (vsub_ne_zero.2 hp₃) (vsub_ne_zero.2 hp₄)
    (vsub_ne_zero.2 hp₆) hs
#align euclidean_geometry.angle_eq_iff_oangle_eq_of_sign_eq EuclideanGeometry.angle_eq_iff_oangle_eq_of_sign_eq

/-- The oriented angle between three points equals the unoriented angle if the sign is
positive. -/
theorem oangle_eq_angle_of_sign_eq_one {p₁ p₂ p₃ : P} (h : (∡ p₁ p₂ p₃).sign = 1) : ∡ p₁ p₂ p₃ = ∠ p₁ p₂ p₃ :=
  o.oangle_eq_angle_of_sign_eq_one h
#align euclidean_geometry.oangle_eq_angle_of_sign_eq_one EuclideanGeometry.oangle_eq_angle_of_sign_eq_one

/-- The oriented angle between three points equals minus the unoriented angle if the sign is
negative. -/
theorem oangle_eq_neg_angle_of_sign_eq_neg_one {p₁ p₂ p₃ : P} (h : (∡ p₁ p₂ p₃).sign = -1) : ∡ p₁ p₂ p₃ = -∠ p₁ p₂ p₃ :=
  o.oangle_eq_neg_angle_of_sign_eq_neg_one h
#align
  euclidean_geometry.oangle_eq_neg_angle_of_sign_eq_neg_one EuclideanGeometry.oangle_eq_neg_angle_of_sign_eq_neg_one

/-- The unoriented angle at `p` between two points not equal to `p` is zero if and only if the
unoriented angle is zero. -/
theorem oangle_eq_zero_iff_angle_eq_zero {p p₁ p₂ : P} (hp₁ : p₁ ≠ p) (hp₂ : p₂ ≠ p) : ∡ p₁ p p₂ = 0 ↔ ∠ p₁ p p₂ = 0 :=
  o.oangle_eq_zero_iff_angle_eq_zero (vsub_ne_zero.2 hp₁) (vsub_ne_zero.2 hp₂)
#align euclidean_geometry.oangle_eq_zero_iff_angle_eq_zero EuclideanGeometry.oangle_eq_zero_iff_angle_eq_zero

/-- The oriented angle between three points is `π` if and only if the unoriented angle is `π`. -/
theorem oangle_eq_pi_iff_angle_eq_pi {p₁ p₂ p₃ : P} : ∡ p₁ p₂ p₃ = π ↔ ∠ p₁ p₂ p₃ = π :=
  o.oangle_eq_pi_iff_angle_eq_pi
#align euclidean_geometry.oangle_eq_pi_iff_angle_eq_pi EuclideanGeometry.oangle_eq_pi_iff_angle_eq_pi

/-- Swapping the first and second points in an oriented angle negates the sign of that angle. -/
theorem oangle_swap₁₂_sign (p₁ p₂ p₃ : P) : -(∡ p₁ p₂ p₃).sign = (∡ p₂ p₁ p₃).sign := by
  rw [eq_comm, oangle, oangle, ← o.oangle_neg_neg, neg_vsub_eq_vsub_rev, neg_vsub_eq_vsub_rev, ←
    vsub_sub_vsub_cancel_left p₁ p₃ p₂, ← neg_vsub_eq_vsub_rev p₃ p₂, sub_eq_add_neg, neg_vsub_eq_vsub_rev p₂ p₁,
    add_comm, ← @neg_one_smul ℝ]
  nth_rw 1 [← one_smul ℝ (p₁ -ᵥ p₂)]
  rw [o.oangle_sign_smul_add_smul_right]
  simp
#align euclidean_geometry.oangle_swap₁₂_sign EuclideanGeometry.oangle_swap₁₂_sign

/-- Swapping the first and third points in an oriented angle negates the sign of that angle. -/
theorem oangle_swap₁₃_sign (p₁ p₂ p₃ : P) : -(∡ p₁ p₂ p₃).sign = (∡ p₃ p₂ p₁).sign := by
  rw [oangle_rev, Real.Angle.sign_neg, neg_neg]
#align euclidean_geometry.oangle_swap₁₃_sign EuclideanGeometry.oangle_swap₁₃_sign

/-- Swapping the second and third points in an oriented angle negates the sign of that angle. -/
theorem oangle_swap₂₃_sign (p₁ p₂ p₃ : P) : -(∡ p₁ p₂ p₃).sign = (∡ p₁ p₃ p₂).sign := by
  rw [oangle_swap₁₃_sign, ← oangle_swap₁₂_sign, oangle_swap₁₃_sign]
#align euclidean_geometry.oangle_swap₂₃_sign EuclideanGeometry.oangle_swap₂₃_sign

/-- Rotating the points in an oriented angle does not change the sign of that angle. -/
theorem oangle_rotate_sign (p₁ p₂ p₃ : P) : (∡ p₂ p₃ p₁).sign = (∡ p₁ p₂ p₃).sign := by
  rw [← oangle_swap₁₂_sign, oangle_swap₁₃_sign]
#align euclidean_geometry.oangle_rotate_sign EuclideanGeometry.oangle_rotate_sign

/-- The oriented angle between three points is π if and only if the second point is strictly
between the other two. -/
theorem oangle_eq_pi_iff_sbtw {p₁ p₂ p₃ : P} : ∡ p₁ p₂ p₃ = π ↔ Sbtw ℝ p₁ p₂ p₃ := by
  rw [oangle_eq_pi_iff_angle_eq_pi, angle_eq_pi_iff_sbtw]
#align euclidean_geometry.oangle_eq_pi_iff_sbtw EuclideanGeometry.oangle_eq_pi_iff_sbtw

/-- If the second of three points is strictly between the other two, the oriented angle at that
point is π. -/
theorem _root_.sbtw.oangle₁₂₃_eq_pi {p₁ p₂ p₃ : P} (h : Sbtw ℝ p₁ p₂ p₃) : ∡ p₁ p₂ p₃ = π :=
  oangle_eq_pi_iff_sbtw.2 h
#align euclidean_geometry._root_.sbtw.oangle₁₂₃_eq_pi euclidean_geometry._root_.sbtw.oangle₁₂₃_eq_pi

/-- If the second of three points is strictly between the other two, the oriented angle at that
point (reversed) is π. -/
theorem _root_.sbtw.oangle₃₂₁_eq_pi {p₁ p₂ p₃ : P} (h : Sbtw ℝ p₁ p₂ p₃) : ∡ p₃ p₂ p₁ = π := by
  rw [oangle_eq_pi_iff_oangle_rev_eq_pi, ← h.oangle₁₂₃_eq_pi]
#align euclidean_geometry._root_.sbtw.oangle₃₂₁_eq_pi euclidean_geometry._root_.sbtw.oangle₃₂₁_eq_pi

/-- If the second of three points is weakly between the other two, the oriented angle at the
first point is zero. -/
theorem _root_.wbtw.oangle₂₁₃_eq_zero {p₁ p₂ p₃ : P} (h : Wbtw ℝ p₁ p₂ p₃) : ∡ p₂ p₁ p₃ = 0 := by
  by_cases hp₂p₁:p₂ = p₁
  · simp [hp₂p₁]
    
  by_cases hp₃p₁:p₃ = p₁
  · simp [hp₃p₁]
    
  rw [oangle_eq_zero_iff_angle_eq_zero hp₂p₁ hp₃p₁]
  exact h.angle₂₁₃_eq_zero_of_ne hp₂p₁
#align euclidean_geometry._root_.wbtw.oangle₂₁₃_eq_zero euclidean_geometry._root_.wbtw.oangle₂₁₃_eq_zero

/-- If the second of three points is strictly between the other two, the oriented angle at the
first point is zero. -/
theorem _root_.sbtw.oangle₂₁₃_eq_zero {p₁ p₂ p₃ : P} (h : Sbtw ℝ p₁ p₂ p₃) : ∡ p₂ p₁ p₃ = 0 :=
  h.Wbtw.oangle₂₁₃_eq_zero
#align euclidean_geometry._root_.sbtw.oangle₂₁₃_eq_zero euclidean_geometry._root_.sbtw.oangle₂₁₃_eq_zero

/-- If the second of three points is weakly between the other two, the oriented angle at the
first point (reversed) is zero. -/
theorem _root_.wbtw.oangle₃₁₂_eq_zero {p₁ p₂ p₃ : P} (h : Wbtw ℝ p₁ p₂ p₃) : ∡ p₃ p₁ p₂ = 0 := by
  rw [oangle_eq_zero_iff_oangle_rev_eq_zero, h.oangle₂₁₃_eq_zero]
#align euclidean_geometry._root_.wbtw.oangle₃₁₂_eq_zero euclidean_geometry._root_.wbtw.oangle₃₁₂_eq_zero

/-- If the second of three points is strictly between the other two, the oriented angle at the
first point (reversed) is zero. -/
theorem _root_.sbtw.oangle₃₁₂_eq_zero {p₁ p₂ p₃ : P} (h : Sbtw ℝ p₁ p₂ p₃) : ∡ p₃ p₁ p₂ = 0 :=
  h.Wbtw.oangle₃₁₂_eq_zero
#align euclidean_geometry._root_.sbtw.oangle₃₁₂_eq_zero euclidean_geometry._root_.sbtw.oangle₃₁₂_eq_zero

/-- If the second of three points is weakly between the other two, the oriented angle at the
third point is zero. -/
theorem _root_.wbtw.oangle₂₃₁_eq_zero {p₁ p₂ p₃ : P} (h : Wbtw ℝ p₁ p₂ p₃) : ∡ p₂ p₃ p₁ = 0 :=
  h.symm.oangle₂₁₃_eq_zero
#align euclidean_geometry._root_.wbtw.oangle₂₃₁_eq_zero euclidean_geometry._root_.wbtw.oangle₂₃₁_eq_zero

/-- If the second of three points is strictly between the other two, the oriented angle at the
third point is zero. -/
theorem _root_.sbtw.oangle₂₃₁_eq_zero {p₁ p₂ p₃ : P} (h : Sbtw ℝ p₁ p₂ p₃) : ∡ p₂ p₃ p₁ = 0 :=
  h.Wbtw.oangle₂₃₁_eq_zero
#align euclidean_geometry._root_.sbtw.oangle₂₃₁_eq_zero euclidean_geometry._root_.sbtw.oangle₂₃₁_eq_zero

/-- If the second of three points is weakly between the other two, the oriented angle at the
third point (reversed) is zero. -/
theorem _root_.wbtw.oangle₁₃₂_eq_zero {p₁ p₂ p₃ : P} (h : Wbtw ℝ p₁ p₂ p₃) : ∡ p₁ p₃ p₂ = 0 :=
  h.symm.oangle₃₁₂_eq_zero
#align euclidean_geometry._root_.wbtw.oangle₁₃₂_eq_zero euclidean_geometry._root_.wbtw.oangle₁₃₂_eq_zero

/-- If the second of three points is strictly between the other two, the oriented angle at the
third point (reversed) is zero. -/
theorem _root_.sbtw.oangle₁₃₂_eq_zero {p₁ p₂ p₃ : P} (h : Sbtw ℝ p₁ p₂ p₃) : ∡ p₁ p₃ p₂ = 0 :=
  h.Wbtw.oangle₁₃₂_eq_zero
#align euclidean_geometry._root_.sbtw.oangle₁₃₂_eq_zero euclidean_geometry._root_.sbtw.oangle₁₃₂_eq_zero

/-- The oriented angle between three points is zero if and only if one of the first and third
points is weakly between the other two. -/
theorem oangle_eq_zero_iff_wbtw {p₁ p₂ p₃ : P} : ∡ p₁ p₂ p₃ = 0 ↔ Wbtw ℝ p₂ p₁ p₃ ∨ Wbtw ℝ p₂ p₃ p₁ := by
  by_cases hp₁p₂:p₁ = p₂
  · simp [hp₁p₂]
    
  by_cases hp₃p₂:p₃ = p₂
  · simp [hp₃p₂]
    
  rw [oangle_eq_zero_iff_angle_eq_zero hp₁p₂ hp₃p₂, angle_eq_zero_iff_ne_and_wbtw]
  simp [hp₁p₂, hp₃p₂]
#align euclidean_geometry.oangle_eq_zero_iff_wbtw EuclideanGeometry.oangle_eq_zero_iff_wbtw

/-- An oriented angle is unchanged by replacing the first point by one weakly further away on the
same ray. -/
theorem _root_.wbtw.oangle_eq_left {p₁ p₁' p₂ p₃ : P} (h : Wbtw ℝ p₂ p₁ p₁') (hp₁p₂ : p₁ ≠ p₂) :
    ∡ p₁ p₂ p₃ = ∡ p₁' p₂ p₃ := by
  by_cases hp₃p₂:p₃ = p₂
  · simp [hp₃p₂]
    
  by_cases hp₁'p₂:p₁' = p₂
  · rw [hp₁'p₂, wbtw_self_iff] at h
    exact False.elim (hp₁p₂ h)
    
  rw [← oangle_add hp₁'p₂ hp₁p₂ hp₃p₂, h.oangle₃₁₂_eq_zero, zero_add]
#align euclidean_geometry._root_.wbtw.oangle_eq_left euclidean_geometry._root_.wbtw.oangle_eq_left

/-- An oriented angle is unchanged by replacing the first point by one strictly further away on
the same ray. -/
theorem _root_.sbtw.oangle_eq_left {p₁ p₁' p₂ p₃ : P} (h : Sbtw ℝ p₂ p₁ p₁') : ∡ p₁ p₂ p₃ = ∡ p₁' p₂ p₃ :=
  h.Wbtw.oangle_eq_left h.ne_left
#align euclidean_geometry._root_.sbtw.oangle_eq_left euclidean_geometry._root_.sbtw.oangle_eq_left

/-- An oriented angle is unchanged by replacing the third point by one weakly further away on the
same ray. -/
theorem _root_.wbtw.oangle_eq_right {p₁ p₂ p₃ p₃' : P} (h : Wbtw ℝ p₂ p₃ p₃') (hp₃p₂ : p₃ ≠ p₂) :
    ∡ p₁ p₂ p₃ = ∡ p₁ p₂ p₃' := by rw [oangle_rev, h.oangle_eq_left hp₃p₂, ← oangle_rev]
#align euclidean_geometry._root_.wbtw.oangle_eq_right euclidean_geometry._root_.wbtw.oangle_eq_right

/-- An oriented angle is unchanged by replacing the third point by one strictly further away on
the same ray. -/
theorem _root_.sbtw.oangle_eq_right {p₁ p₂ p₃ p₃' : P} (h : Sbtw ℝ p₂ p₃ p₃') : ∡ p₁ p₂ p₃ = ∡ p₁ p₂ p₃' :=
  h.Wbtw.oangle_eq_right h.ne_left
#align euclidean_geometry._root_.sbtw.oangle_eq_right euclidean_geometry._root_.sbtw.oangle_eq_right

/-- An oriented angle is unchanged by replacing the first point with the midpoint of the segment
between it and the second point. -/
@[simp]
theorem oangle_midpoint_left (p₁ p₂ p₃ : P) : ∡ (midpoint ℝ p₁ p₂) p₂ p₃ = ∡ p₁ p₂ p₃ := by
  by_cases h:p₁ = p₂
  · simp [h]
    
  exact (sbtw_midpoint_of_ne ℝ h).symm.oangle_eq_left
#align euclidean_geometry.oangle_midpoint_left EuclideanGeometry.oangle_midpoint_left

/-- An oriented angle is unchanged by replacing the first point with the midpoint of the segment
between the second point and that point. -/
@[simp]
theorem oangle_midpoint_rev_left (p₁ p₂ p₃ : P) : ∡ (midpoint ℝ p₂ p₁) p₂ p₃ = ∡ p₁ p₂ p₃ := by
  rw [midpoint_comm, oangle_midpoint_left]
#align euclidean_geometry.oangle_midpoint_rev_left EuclideanGeometry.oangle_midpoint_rev_left

/-- An oriented angle is unchanged by replacing the third point with the midpoint of the segment
between it and the second point. -/
@[simp]
theorem oangle_midpoint_right (p₁ p₂ p₃ : P) : ∡ p₁ p₂ (midpoint ℝ p₃ p₂) = ∡ p₁ p₂ p₃ := by
  by_cases h:p₃ = p₂
  · simp [h]
    
  exact (sbtw_midpoint_of_ne ℝ h).symm.oangle_eq_right
#align euclidean_geometry.oangle_midpoint_right EuclideanGeometry.oangle_midpoint_right

/-- An oriented angle is unchanged by replacing the third point with the midpoint of the segment
between the second point and that point. -/
@[simp]
theorem oangle_midpoint_rev_right (p₁ p₂ p₃ : P) : ∡ p₁ p₂ (midpoint ℝ p₂ p₃) = ∡ p₁ p₂ p₃ := by
  rw [midpoint_comm, oangle_midpoint_right]
#align euclidean_geometry.oangle_midpoint_rev_right EuclideanGeometry.oangle_midpoint_rev_right

/-- Replacing the first point by one on the same line but the opposite ray adds π to the oriented
angle. -/
theorem _root_.sbtw.oangle_eq_add_pi_left {p₁ p₁' p₂ p₃ : P} (h : Sbtw ℝ p₁ p₂ p₁') (hp₃p₂ : p₃ ≠ p₂) :
    ∡ p₁ p₂ p₃ = ∡ p₁' p₂ p₃ + π := by rw [← h.oangle₁₂₃_eq_pi, oangle_add_swap h.left_ne h.right_ne hp₃p₂]
#align euclidean_geometry._root_.sbtw.oangle_eq_add_pi_left euclidean_geometry._root_.sbtw.oangle_eq_add_pi_left

/-- Replacing the third point by one on the same line but the opposite ray adds π to the oriented
angle. -/
theorem _root_.sbtw.oangle_eq_add_pi_right {p₁ p₂ p₃ p₃' : P} (h : Sbtw ℝ p₃ p₂ p₃') (hp₁p₂ : p₁ ≠ p₂) :
    ∡ p₁ p₂ p₃ = ∡ p₁ p₂ p₃' + π := by rw [← h.oangle₃₂₁_eq_pi, oangle_add hp₁p₂ h.right_ne h.left_ne]
#align euclidean_geometry._root_.sbtw.oangle_eq_add_pi_right euclidean_geometry._root_.sbtw.oangle_eq_add_pi_right

/-- Replacing both the first and third points by ones on the same lines but the opposite rays
does not change the oriented angle (vertically opposite angles). -/
theorem _root_.sbtw.oangle_eq_left_right {p₁ p₁' p₂ p₃ p₃' : P} (h₁ : Sbtw ℝ p₁ p₂ p₁') (h₃ : Sbtw ℝ p₃ p₂ p₃') :
    ∡ p₁ p₂ p₃ = ∡ p₁' p₂ p₃' := by
  rw [h₁.oangle_eq_add_pi_left h₃.left_ne, h₃.oangle_eq_add_pi_right h₁.right_ne, add_assoc,
    Real.Angle.coe_pi_add_coe_pi, add_zero]
#align euclidean_geometry._root_.sbtw.oangle_eq_left_right euclidean_geometry._root_.sbtw.oangle_eq_left_right

/-- Replacing the first point by one on the same line does not change twice the oriented angle. -/
theorem _root_.collinear.two_zsmul_oangle_eq_left {p₁ p₁' p₂ p₃ : P} (h : Collinear ℝ ({p₁, p₂, p₁'} : Set P))
    (hp₁p₂ : p₁ ≠ p₂) (hp₁'p₂ : p₁' ≠ p₂) : (2 : ℤ) • ∡ p₁ p₂ p₃ = (2 : ℤ) • ∡ p₁' p₂ p₃ := by
  by_cases hp₃p₂:p₃ = p₂
  · simp [hp₃p₂]
    
  rcases h.wbtw_or_wbtw_or_wbtw with (hw | hw | hw)
  · have hw' : Sbtw ℝ p₁ p₂ p₁' := ⟨hw, hp₁p₂.symm, hp₁'p₂.symm⟩
    rw [hw'.oangle_eq_add_pi_left hp₃p₂, smul_add, Real.Angle.two_zsmul_coe_pi, add_zero]
    
  · rw [hw.oangle_eq_left hp₁'p₂]
    
  · rw [hw.symm.oangle_eq_left hp₁p₂]
    
#align
  euclidean_geometry._root_.collinear.two_zsmul_oangle_eq_left euclidean_geometry._root_.collinear.two_zsmul_oangle_eq_left

/-- Replacing the third point by one on the same line does not change twice the oriented angle. -/
theorem _root_.collinear.two_zsmul_oangle_eq_right {p₁ p₂ p₃ p₃' : P} (h : Collinear ℝ ({p₃, p₂, p₃'} : Set P))
    (hp₃p₂ : p₃ ≠ p₂) (hp₃'p₂ : p₃' ≠ p₂) : (2 : ℤ) • ∡ p₁ p₂ p₃ = (2 : ℤ) • ∡ p₁ p₂ p₃' := by
  rw [oangle_rev, smul_neg, h.two_zsmul_oangle_eq_left hp₃p₂ hp₃'p₂, ← smul_neg, ← oangle_rev]
#align
  euclidean_geometry._root_.collinear.two_zsmul_oangle_eq_right euclidean_geometry._root_.collinear.two_zsmul_oangle_eq_right

open AffineSubspace

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- Given two pairs of distinct points on the same line, such that the vectors between those
pairs of points are on the same ray (oriented in the same direction on that line), and a fifth
point, the angles at the fifth point between each of those two pairs of points have the same
sign. -/
theorem _root_.collinear.oangle_sign_of_same_ray_vsub {p₁ p₂ p₃ p₄ : P} (p₅ : P) (hp₁p₂ : p₁ ≠ p₂) (hp₃p₄ : p₃ ≠ p₄)
    (hc : Collinear ℝ ({p₁, p₂, p₃, p₄} : Set P)) (hr : SameRay ℝ (p₂ -ᵥ p₁) (p₄ -ᵥ p₃)) :
    (∡ p₁ p₅ p₂).sign = (∡ p₃ p₅ p₄).sign := by
  by_cases hc₅₁₂:Collinear ℝ ({p₅, p₁, p₂} : Set P)
  · have hc₅₁₂₃₄ : Collinear ℝ ({p₅, p₁, p₂, p₃, p₄} : Set P) :=
      (hc.collinear_insert_iff_of_ne (Set.mem_insert _ _) (Set.mem_insert_of_mem _ (Set.mem_insert _ _)) hp₁p₂).2 hc₅₁₂
    have hc₅₃₄ : Collinear ℝ ({p₅, p₃, p₄} : Set P) :=
      (hc.collinear_insert_iff_of_ne (Set.mem_insert_of_mem _ (Set.mem_insert_of_mem _ (Set.mem_insert _ _)))
            (Set.mem_insert_of_mem _ (Set.mem_insert_of_mem _ (Set.mem_insert_of_mem _ (Set.mem_singleton _)))) hp₃p₄).1
        hc₅₁₂₃₄
    rw [Set.insert_comm] at hc₅₁₂ hc₅₃₄
    have hs₁₅₂ := oangle_eq_zero_or_eq_pi_iff_collinear.2 hc₅₁₂
    have hs₃₅₄ := oangle_eq_zero_or_eq_pi_iff_collinear.2 hc₅₃₄
    rw [← Real.Angle.sign_eq_zero_iff] at hs₁₅₂ hs₃₅₄
    rw [hs₁₅₂, hs₃₅₄]
    
  · let s : Set (P × P × P) :=
      (fun x : line[ℝ, p₁, p₂] × V => (x.1, p₅, x.2 +ᵥ x.1)) '' Set.univ ×ˢ { v | SameRay ℝ (p₂ -ᵥ p₁) v ∧ v ≠ 0 }
    have hco : IsConnected s :=
      haveI : ConnectedSpace line[ℝ, p₁, p₂] := AddTorsor.connected_space _ _
      (is_connected_univ.prod (is_connected_set_of_same_ray_and_ne_zero (vsub_ne_zero.2 hp₁p₂.symm))).image _
        (continuous_fst.subtype_coe.prod_mk
            (continuous_const.prod_mk (continuous_snd.vadd continuous_fst.subtype_coe))).ContinuousOn
    have hf : ContinuousOn (fun p : P × P × P => ∡ p.1 p.2.1 p.2.2) s := by
      refine' ContinuousAt.continuous_on fun p hp => continuous_at_oangle _ _
      all_goals
      simp_rw [s, Set.mem_image, Set.mem_prod, Set.mem_univ, true_and_iff, Prod.ext_iff] at hp
      obtain ⟨q₁, q₅, q₂⟩ := p
      dsimp only at hp⊢
      obtain ⟨⟨⟨q, hq⟩, v⟩, hv, rfl, rfl, rfl⟩ := hp
      dsimp only [Subtype.coe_mk, Set.mem_set_of] at hv⊢
      obtain ⟨hvr, -⟩ := hv
      rintro rfl
      refine' hc₅₁₂ ((collinear_insert_iff_of_mem_affine_span _).2 (collinearPair _ _ _))
      · exact hq
        
      · refine' vadd_mem_of_mem_direction _ hq
        rw [← exists_nonneg_left_iff_same_ray (vsub_ne_zero.2 hp₁p₂.symm)] at hvr
        obtain ⟨r, -, rfl⟩ := hvr
        rw [direction_affine_span]
        exact smul_vsub_rev_mem_vector_span_pair _ _ _
        
    have hsp : ∀ p : P × P × P, p ∈ s → ∡ p.1 p.2.1 p.2.2 ≠ 0 ∧ ∡ p.1 p.2.1 p.2.2 ≠ π := by
      intro p hp
      simp_rw [s, Set.mem_image, Set.mem_prod, Set.mem_set_of, Set.mem_univ, true_and_iff, Prod.ext_iff] at hp
      obtain ⟨q₁, q₅, q₂⟩ := p
      dsimp only at hp⊢
      obtain ⟨⟨⟨q, hq⟩, v⟩, hv, rfl, rfl, rfl⟩ := hp
      dsimp only [Subtype.coe_mk, Set.mem_set_of] at hv⊢
      obtain ⟨hvr, hv0⟩ := hv
      rw [← exists_nonneg_left_iff_same_ray (vsub_ne_zero.2 hp₁p₂.symm)] at hvr
      obtain ⟨r, -, rfl⟩ := hvr
      change q ∈ line[ℝ, p₁, p₂] at hq
      rw [oangle_ne_zero_and_ne_pi_iff_affine_independent]
      refine'
        affine_independent_of_ne_of_mem_of_not_mem_of_mem _ hq
          (fun h => hc₅₁₂ ((collinear_insert_iff_of_mem_affine_span h).2 (collinearPair _ _ _))) _
      · rwa [← @vsub_ne_zero V, vsub_vadd_eq_vsub_sub, vsub_self, zero_sub, neg_ne_zero]
        
      · refine' vadd_mem_of_mem_direction _ hq
        rw [direction_affine_span]
        exact smul_vsub_rev_mem_vector_span_pair _ _ _
        
    have hp₁p₂s : (p₁, p₅, p₂) ∈ s := by
      simp_rw [s, Set.mem_image, Set.mem_prod, Set.mem_set_of, Set.mem_univ, true_and_iff, Prod.ext_iff]
      refine' ⟨⟨⟨p₁, left_mem_affine_span_pair _ _ _⟩, p₂ -ᵥ p₁⟩, ⟨SameRay.rfl, vsub_ne_zero.2 hp₁p₂.symm⟩, _⟩
      simp
    have hp₃p₄s : (p₃, p₅, p₄) ∈ s := by
      simp_rw [s, Set.mem_image, Set.mem_prod, Set.mem_set_of, Set.mem_univ, true_and_iff, Prod.ext_iff]
      refine'
        ⟨⟨⟨p₃,
              hc.mem_affine_span_of_mem_of_ne (Set.mem_insert _ _) (Set.mem_insert_of_mem _ (Set.mem_insert _ _))
                (Set.mem_insert_of_mem _ (Set.mem_insert_of_mem _ (Set.mem_insert _ _))) hp₁p₂⟩,
            p₄ -ᵥ p₃⟩,
          ⟨hr, vsub_ne_zero.2 hp₃p₄.symm⟩, _⟩
      simp
    convert Real.Angle.sign_eq_of_continuous_on hco hf hsp hp₃p₄s hp₁p₂s
    
#align
  euclidean_geometry._root_.collinear.oangle_sign_of_same_ray_vsub euclidean_geometry._root_.collinear.oangle_sign_of_same_ray_vsub

/-- Given three points in strict order on the same line, and a fourth point, the angles at the
fourth point between the first and second or second and third points have the same sign. -/
theorem _root_.sbtw.oangle_sign_eq {p₁ p₂ p₃ : P} (p₄ : P) (h : Sbtw ℝ p₁ p₂ p₃) :
    (∡ p₁ p₄ p₂).sign = (∡ p₂ p₄ p₃).sign :=
  haveI hc : Collinear ℝ ({p₁, p₂, p₂, p₃} : Set P) := by simpa using h.wbtw.collinear
  hc.oangle_sign_of_same_ray_vsub _ h.left_ne h.ne_right h.wbtw.same_ray_vsub
#align euclidean_geometry._root_.sbtw.oangle_sign_eq euclidean_geometry._root_.sbtw.oangle_sign_eq

/-- Given three points in weak order on the same line, with the first not equal to the second,
and a fourth point, the angles at the fourth point between the first and second or first and
third points have the same sign. -/
theorem _root_.wbtw.oangle_sign_eq_of_ne_left {p₁ p₂ p₃ : P} (p₄ : P) (h : Wbtw ℝ p₁ p₂ p₃) (hne : p₁ ≠ p₂) :
    (∡ p₁ p₄ p₂).sign = (∡ p₁ p₄ p₃).sign :=
  haveI hc : Collinear ℝ ({p₁, p₂, p₁, p₃} : Set P) := by simpa [Set.insert_comm p₂] using h.collinear
  hc.oangle_sign_of_same_ray_vsub _ hne (h.left_ne_right_of_ne_left hne.symm) h.same_ray_vsub_left
#align euclidean_geometry._root_.wbtw.oangle_sign_eq_of_ne_left euclidean_geometry._root_.wbtw.oangle_sign_eq_of_ne_left

/-- Given three points in strict order on the same line, and a fourth point, the angles at the
fourth point between the first and second or first and third points have the same sign. -/
theorem _root_.sbtw.oangle_sign_eq_left {p₁ p₂ p₃ : P} (p₄ : P) (h : Sbtw ℝ p₁ p₂ p₃) :
    (∡ p₁ p₄ p₂).sign = (∡ p₁ p₄ p₃).sign :=
  h.Wbtw.oangle_sign_eq_of_ne_left _ h.left_ne
#align euclidean_geometry._root_.sbtw.oangle_sign_eq_left euclidean_geometry._root_.sbtw.oangle_sign_eq_left

/-- Given three points in weak order on the same line, with the second not equal to the third,
and a fourth point, the angles at the fourth point between the second and third or first and
third points have the same sign. -/
theorem _root_.wbtw.oangle_sign_eq_of_ne_right {p₁ p₂ p₃ : P} (p₄ : P) (h : Wbtw ℝ p₁ p₂ p₃) (hne : p₂ ≠ p₃) :
    (∡ p₂ p₄ p₃).sign = (∡ p₁ p₄ p₃).sign := by
  simp_rw [oangle_rev p₃, Real.Angle.sign_neg, h.symm.oangle_sign_eq_of_ne_left _ hne.symm]
#align
  euclidean_geometry._root_.wbtw.oangle_sign_eq_of_ne_right euclidean_geometry._root_.wbtw.oangle_sign_eq_of_ne_right

/-- Given three points in strict order on the same line, and a fourth point, the angles at the
fourth point between the second and third or first and third points have the same sign. -/
theorem _root_.sbtw.oangle_sign_eq_right {p₁ p₂ p₃ : P} (p₄ : P) (h : Sbtw ℝ p₁ p₂ p₃) :
    (∡ p₂ p₄ p₃).sign = (∡ p₁ p₄ p₃).sign :=
  h.Wbtw.oangle_sign_eq_of_ne_right _ h.ne_right
#align euclidean_geometry._root_.sbtw.oangle_sign_eq_right euclidean_geometry._root_.sbtw.oangle_sign_eq_right

/-- Given two points in an affine subspace, the angles between those two points at two other
points on the same side of that subspace have the same sign. -/
theorem _root_.affine_subspace.s_same_side.oangle_sign_eq {s : AffineSubspace ℝ P} {p₁ p₂ p₃ p₄ : P} (hp₁ : p₁ ∈ s)
    (hp₂ : p₂ ∈ s) (hp₃p₄ : s.SSameSide p₃ p₄) : (∡ p₁ p₄ p₂).sign = (∡ p₁ p₃ p₂).sign := by
  by_cases h:p₁ = p₂
  · simp [h]
    
  let sp : Set (P × P × P) := (fun p : P => (p₁, p, p₂)) '' { p | s.s_same_side p₃ p }
  have hc : IsConnected sp :=
    (is_connected_set_of_s_same_side hp₃p₄.2.1 hp₃p₄.nonempty).image _
      (continuous_const.prod_mk (Continuous.Prod.mk_left _)).ContinuousOn
  have hf : ContinuousOn (fun p : P × P × P => ∡ p.1 p.2.1 p.2.2) sp := by
    refine' ContinuousAt.continuous_on fun p hp => continuous_at_oangle _ _
    all_goals
    simp_rw [sp, Set.mem_image, Set.mem_set_of] at hp
    obtain ⟨p', hp', rfl⟩ := hp
    dsimp only
    rintro rfl
    · exact hp'.2.2 hp₁
      
    · exact hp'.2.2 hp₂
      
  have hsp : ∀ p : P × P × P, p ∈ sp → ∡ p.1 p.2.1 p.2.2 ≠ 0 ∧ ∡ p.1 p.2.1 p.2.2 ≠ π := by
    intro p hp
    simp_rw [sp, Set.mem_image, Set.mem_set_of] at hp
    obtain ⟨p', hp', rfl⟩ := hp
    dsimp only
    rw [oangle_ne_zero_and_ne_pi_iff_affine_independent]
    exact affine_independent_of_ne_of_mem_of_not_mem_of_mem h hp₁ hp'.2.2 hp₂
  have hp₃ : (p₁, p₃, p₂) ∈ sp := Set.mem_image_of_mem _ (s_same_side_self_iff.2 ⟨hp₃p₄.nonempty, hp₃p₄.2.1⟩)
  have hp₄ : (p₁, p₄, p₂) ∈ sp := Set.mem_image_of_mem _ hp₃p₄
  convert Real.Angle.sign_eq_of_continuous_on hc hf hsp hp₃ hp₄
#align
  euclidean_geometry._root_.affine_subspace.s_same_side.oangle_sign_eq euclidean_geometry._root_.affine_subspace.s_same_side.oangle_sign_eq

/-- Given two points in an affine subspace, the angles between those two points at two other
points on opposite sides of that subspace have opposite signs. -/
theorem _root_.affine_subspace.s_opp_side.oangle_sign_eq_neg {s : AffineSubspace ℝ P} {p₁ p₂ p₃ p₄ : P} (hp₁ : p₁ ∈ s)
    (hp₂ : p₂ ∈ s) (hp₃p₄ : s.SOppSide p₃ p₄) : (∡ p₁ p₄ p₂).sign = -(∡ p₁ p₃ p₂).sign := by
  have hp₁p₃ : p₁ ≠ p₃ := by
    rintro rfl
    exact hp₃p₄.left_not_mem hp₁
  rw [← (hp₃p₄.symm.trans (s_opp_side_point_reflection hp₁ hp₃p₄.left_not_mem)).oangle_sign_eq hp₁ hp₂, ←
    oangle_rotate_sign p₁, ← oangle_rotate_sign p₁, oangle_swap₁₃_sign,
    (sbtw_point_reflection_of_ne ℝ hp₁p₃).symm.oangle_sign_eq _]
#align
  euclidean_geometry._root_.affine_subspace.s_opp_side.oangle_sign_eq_neg euclidean_geometry._root_.affine_subspace.s_opp_side.oangle_sign_eq_neg

end EuclideanGeometry

