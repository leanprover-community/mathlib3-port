/-
Copyright (c) 2020 Joseph Myers. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Myers
-/
import Mathbin.Geometry.Euclidean.Angle.Unoriented.Affine

/-!
# Right-angled triangles

This file proves basic geometrical results about distances and angles in (possibly degenerate)
right-angled triangles in real inner product spaces and Euclidean affine spaces.

## Implementation notes

Results in this file are generally given in a form with only those non-degeneracy conditions
needed for the particular result, rather than requiring affine independence of the points of a
triangle unnecessarily.

## References

* https://en.wikipedia.org/wiki/Pythagorean_theorem

-/


noncomputable section

open BigOperators

open EuclideanGeometry

open Real

open RealInnerProductSpace

namespace InnerProductGeometry

variable {V : Type _} [InnerProductSpace ℝ V]

/-- Pythagorean theorem, if-and-only-if vector angle form. -/
theorem norm_add_sq_eq_norm_sq_add_norm_sq_iff_angle_eq_pi_div_two (x y : V) :
    ∥x + y∥ * ∥x + y∥ = ∥x∥ * ∥x∥ + ∥y∥ * ∥y∥ ↔ angle x y = π / 2 := by
  rw [norm_add_sq_eq_norm_sq_add_norm_sq_iff_real_inner_eq_zero]
  exact inner_eq_zero_iff_angle_eq_pi_div_two x y

/-- Pythagorean theorem, vector angle form. -/
theorem norm_add_sq_eq_norm_sq_add_norm_sq' (x y : V) (h : angle x y = π / 2) :
    ∥x + y∥ * ∥x + y∥ = ∥x∥ * ∥x∥ + ∥y∥ * ∥y∥ :=
  (norm_add_sq_eq_norm_sq_add_norm_sq_iff_angle_eq_pi_div_two x y).2 h

/-- Pythagorean theorem, subtracting vectors, if-and-only-if vector angle form. -/
theorem norm_sub_sq_eq_norm_sq_add_norm_sq_iff_angle_eq_pi_div_two (x y : V) :
    ∥x - y∥ * ∥x - y∥ = ∥x∥ * ∥x∥ + ∥y∥ * ∥y∥ ↔ angle x y = π / 2 := by
  rw [norm_sub_sq_eq_norm_sq_add_norm_sq_iff_real_inner_eq_zero]
  exact inner_eq_zero_iff_angle_eq_pi_div_two x y

/-- Pythagorean theorem, subtracting vectors, vector angle form. -/
theorem norm_sub_sq_eq_norm_sq_add_norm_sq' (x y : V) (h : angle x y = π / 2) :
    ∥x - y∥ * ∥x - y∥ = ∥x∥ * ∥x∥ + ∥y∥ * ∥y∥ :=
  (norm_sub_sq_eq_norm_sq_add_norm_sq_iff_angle_eq_pi_div_two x y).2 h

end InnerProductGeometry

namespace EuclideanGeometry

open InnerProductGeometry

variable {V : Type _} {P : Type _} [InnerProductSpace ℝ V] [MetricSpace P] [NormedAddTorsor V P]

include V

/-- **Pythagorean theorem**, if-and-only-if angle-at-point form. -/
theorem dist_sq_eq_dist_sq_add_dist_sq_iff_angle_eq_pi_div_two (p1 p2 p3 : P) :
    dist p1 p3 * dist p1 p3 = dist p1 p2 * dist p1 p2 + dist p3 p2 * dist p3 p2 ↔ ∠ p1 p2 p3 = π / 2 := by
  erw [dist_comm p3 p2, dist_eq_norm_vsub V p1 p3, dist_eq_norm_vsub V p1 p2, dist_eq_norm_vsub V p2 p3, ←
    norm_sub_sq_eq_norm_sq_add_norm_sq_iff_angle_eq_pi_div_two, vsub_sub_vsub_cancel_right p1, ←
    neg_vsub_eq_vsub_rev p2 p3, norm_neg]

end EuclideanGeometry

