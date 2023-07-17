/-
Copyright (c) 2021 Matt Kempster. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Matt Kempster

! This file was ported from Lean 3 source module wiedijk_100_theorems.herons_formula
! leanprover-community/mathlib commit 08b081ea92d80e3a41f899eea36ef6d56e0f1db0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Geometry.Euclidean.Triangle

/-!
# Freek № 57: Heron's Formula

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file proves Theorem 57 from the [100 Theorems List](https://www.cs.ru.nl/~freek/100/),
also known as Heron's formula, which gives the area of a triangle based only on its three sides'
lengths.

## References

* https://en.wikipedia.org/wiki/Herons_formula

-/


open Real EuclideanGeometry

open scoped Real EuclideanGeometry

namespace Theorems100

local notation "√" => Real.sqrt

variable {V : Type _} {P : Type _} [NormedAddCommGroup V] [InnerProductSpace ℝ V] [MetricSpace P]
  [NormedAddTorsor V P]

/-- **Heron's formula**: The area of a triangle with side lengths `a`, `b`, and `c` is
  `√(s * (s - a) * (s - b) * (s - c))` where `s = (a + b + c) / 2` is the semiperimeter.
  We show this by equating this formula to `a * b * sin γ`, where `γ` is the angle opposite
  the side `c`.
 -/
theorem heron {p1 p2 p3 : P} (h1 : p1 ≠ p2) (h2 : p3 ≠ p2) :
    let a := dist p1 p2
    let b := dist p3 p2
    let c := dist p1 p3
    let s := (a + b + c) / 2
    1 / 2 * a * b * sin (∠ p1 p2 p3) = √ (s * (s - a) * (s - b) * (s - c)) :=
  by
  intro a b c s
  let γ := ∠ p1 p2 p3
  obtain := (dist_pos.mpr h1).ne', (dist_pos.mpr h2).ne'
  have cos_rule : cos γ = (a * a + b * b - c * c) / (2 * a * b) := by
    field_simp [mul_comm, a,
      dist_sq_eq_dist_sq_add_dist_sq_sub_two_mul_dist_mul_dist_mul_cos_angle p1 p2 p3]
  let numerator := (2 * a * b) ^ 2 - (a * a + b * b - c * c) ^ 2
  let denominator := (2 * a * b) ^ 2
  have split_to_frac : 1 - cos γ ^ 2 = numerator / denominator := by field_simp [cos_rule]
  have numerator_nonneg : 0 ≤ numerator :=
    by
    have frac_nonneg : 0 ≤ numerator / denominator := by linarith [split_to_frac, cos_sq_le_one γ]
    cases div_nonneg_iff.mp frac_nonneg
    · exact h.left
    · simpa [h1, h2] using le_antisymm h.right (sq_nonneg _)
  have ab2_nonneg : 0 ≤ 2 * a * b := by norm_num [mul_nonneg, dist_nonneg]
  calc
    1 / 2 * a * b * sin γ = 1 / 2 * a * b * (√ numerator / √ denominator) := by
      rw [sin_eq_sqrt_one_sub_cos_sq, split_to_frac, sqrt_div numerator_nonneg] <;>
        simp [angle_nonneg, angle_le_pi]
    _ = 1 / 4 * √ ((2 * a * b) ^ 2 - (a * a + b * b - c * c) ^ 2) := by field_simp [ab2_nonneg];
      ring
    _ = 1 / 4 * √ (s * (s - a) * (s - b) * (s - c) * 4 ^ 2) := by simp only [s]; ring_nf
    _ = √ (s * (s - a) * (s - b) * (s - c)) := by
      rw [sqrt_mul', sqrt_sq, div_mul_eq_mul_div, one_mul, mul_div_cancel] <;> norm_num
#align theorems_100.heron Theorems100.heron

end Theorems100

