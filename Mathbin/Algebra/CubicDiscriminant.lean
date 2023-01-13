/-
Copyright (c) 2022 David Kurniadi Angdinata. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: David Kurniadi Angdinata

! This file was ported from Lean 3 source module algebra.cubic_discriminant
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Polynomial.Splits

/-!
# Cubics and discriminants

This file defines cubic polynomials over a semiring and their discriminants over a splitting field.

## Main definitions

 * `cubic`: the structure representing a cubic polynomial.
 * `cubic.disc`: the discriminant of a cubic polynomial.

## Main statements

 * `cubic.disc_ne_zero_iff_roots_nodup`: the cubic discriminant is not equal to zero if and only if
    the cubic has no duplicate roots.

## References

 * https://en.wikipedia.org/wiki/Cubic_equation
 * https://en.wikipedia.org/wiki/Discriminant

## Tags

cubic, discriminant, polynomial, root
-/


noncomputable section

/-- The structure representing a cubic polynomial. -/
@[ext]
structure Cubic (R : Type _) where
  (a b c d : R)
#align cubic Cubic

namespace Cubic

open Cubic Polynomial

open Polynomial

variable {R S F K : Type _}

instance [Inhabited R] : Inhabited (Cubic R) :=
  ⟨⟨default, default, default, default⟩⟩

instance [Zero R] : Zero (Cubic R) :=
  ⟨⟨0, 0, 0, 0⟩⟩

section Basic

variable {P Q : Cubic R} {a b c d a' b' c' d' : R} [Semiring R]

/-- Convert a cubic polynomial to a polynomial. -/
def toPoly (P : Cubic R) : R[X] :=
  c P.a * X ^ 3 + c P.b * X ^ 2 + c P.c * X + c P.d
#align cubic.to_poly Cubic.toPoly

theorem C_mul_prod_X_sub_C_eq [CommRing S] {w x y z : S} :
    c w * (X - c x) * (X - c y) * (X - c z) =
      toPoly ⟨w, w * -(x + y + z), w * (x * y + x * z + y * z), w * -(x * y * z)⟩ :=
  by
  simp only [to_poly, C_neg, C_add, C_mul]
  ring1
#align cubic.C_mul_prod_X_sub_C_eq Cubic.C_mul_prod_X_sub_C_eq

theorem prod_X_sub_C_eq [CommRing S] {x y z : S} :
    (X - c x) * (X - c y) * (X - c z) =
      toPoly ⟨1, -(x + y + z), x * y + x * z + y * z, -(x * y * z)⟩ :=
  by rw [← one_mul <| X - C x, ← C_1, C_mul_prod_X_sub_C_eq, one_mul, one_mul, one_mul]
#align cubic.prod_X_sub_C_eq Cubic.prod_X_sub_C_eq

/-! ### Coefficients -/


section Coeff

private theorem coeffs :
    (∀ n > 3, P.toPoly.coeff n = 0) ∧
      P.toPoly.coeff 3 = P.a ∧
        P.toPoly.coeff 2 = P.b ∧ P.toPoly.coeff 1 = P.c ∧ P.toPoly.coeff 0 = P.d :=
  by
  simp only [to_poly, coeff_add, coeff_C, coeff_C_mul_X, coeff_C_mul_X_pow]
  norm_num
  intro n hn
  repeat' rw [if_neg]
  any_goals linarith only [hn]
  repeat' rw [zero_add]
#align cubic.coeffs cubic.coeffs

@[simp]
theorem coeff_eq_zero {n : ℕ} (hn : 3 < n) : P.toPoly.coeff n = 0 :=
  coeffs.1 n hn
#align cubic.coeff_eq_zero Cubic.coeff_eq_zero

@[simp]
theorem coeff_eq_a : P.toPoly.coeff 3 = P.a :=
  coeffs.2.1
#align cubic.coeff_eq_a Cubic.coeff_eq_a

@[simp]
theorem coeff_eq_b : P.toPoly.coeff 2 = P.b :=
  coeffs.2.2.1
#align cubic.coeff_eq_b Cubic.coeff_eq_b

@[simp]
theorem coeff_eq_c : P.toPoly.coeff 1 = P.c :=
  coeffs.2.2.2.1
#align cubic.coeff_eq_c Cubic.coeff_eq_c

@[simp]
theorem coeff_eq_d : P.toPoly.coeff 0 = P.d :=
  coeffs.2.2.2.2
#align cubic.coeff_eq_d Cubic.coeff_eq_d

theorem a_of_eq (h : P.toPoly = Q.toPoly) : P.a = Q.a := by rw [← coeff_eq_a, h, coeff_eq_a]
#align cubic.a_of_eq Cubic.a_of_eq

theorem b_of_eq (h : P.toPoly = Q.toPoly) : P.b = Q.b := by rw [← coeff_eq_b, h, coeff_eq_b]
#align cubic.b_of_eq Cubic.b_of_eq

theorem c_of_eq (h : P.toPoly = Q.toPoly) : P.c = Q.c := by rw [← coeff_eq_c, h, coeff_eq_c]
#align cubic.c_of_eq Cubic.c_of_eq

theorem d_of_eq (h : P.toPoly = Q.toPoly) : P.d = Q.d := by rw [← coeff_eq_d, h, coeff_eq_d]
#align cubic.d_of_eq Cubic.d_of_eq

theorem to_poly_injective (P Q : Cubic R) : P.toPoly = Q.toPoly ↔ P = Q :=
  ⟨fun h => ext P Q (a_of_eq h) (b_of_eq h) (c_of_eq h) (d_of_eq h), congr_arg toPoly⟩
#align cubic.to_poly_injective Cubic.to_poly_injective

theorem of_a_eq_zero (ha : P.a = 0) : P.toPoly = c P.b * X ^ 2 + c P.c * X + c P.d := by
  rw [to_poly, ha, C_0, zero_mul, zero_add]
#align cubic.of_a_eq_zero Cubic.of_a_eq_zero

theorem of_a_eq_zero' : toPoly ⟨0, b, c, d⟩ = c b * X ^ 2 + c c * X + c d :=
  of_a_eq_zero rfl
#align cubic.of_a_eq_zero' Cubic.of_a_eq_zero'

theorem of_b_eq_zero (ha : P.a = 0) (hb : P.b = 0) : P.toPoly = c P.c * X + c P.d := by
  rw [of_a_eq_zero ha, hb, C_0, zero_mul, zero_add]
#align cubic.of_b_eq_zero Cubic.of_b_eq_zero

theorem of_b_eq_zero' : toPoly ⟨0, 0, c, d⟩ = c c * X + c d :=
  of_b_eq_zero rfl rfl
#align cubic.of_b_eq_zero' Cubic.of_b_eq_zero'

theorem of_c_eq_zero (ha : P.a = 0) (hb : P.b = 0) (hc : P.c = 0) : P.toPoly = c P.d := by
  rw [of_b_eq_zero ha hb, hc, C_0, zero_mul, zero_add]
#align cubic.of_c_eq_zero Cubic.of_c_eq_zero

theorem of_c_eq_zero' : toPoly ⟨0, 0, 0, d⟩ = c d :=
  of_c_eq_zero rfl rfl rfl
#align cubic.of_c_eq_zero' Cubic.of_c_eq_zero'

theorem of_d_eq_zero (ha : P.a = 0) (hb : P.b = 0) (hc : P.c = 0) (hd : P.d = 0) : P.toPoly = 0 :=
  by rw [of_c_eq_zero ha hb hc, hd, C_0]
#align cubic.of_d_eq_zero Cubic.of_d_eq_zero

theorem of_d_eq_zero' : (⟨0, 0, 0, 0⟩ : Cubic R).toPoly = 0 :=
  of_d_eq_zero rfl rfl rfl rfl
#align cubic.of_d_eq_zero' Cubic.of_d_eq_zero'

theorem zero : (0 : Cubic R).toPoly = 0 :=
  of_d_eq_zero'
#align cubic.zero Cubic.zero

theorem to_poly_eq_zero_iff (P : Cubic R) : P.toPoly = 0 ↔ P = 0 := by
  rw [← zero, to_poly_injective]
#align cubic.to_poly_eq_zero_iff Cubic.to_poly_eq_zero_iff

private theorem ne_zero (h0 : P.a ≠ 0 ∨ P.b ≠ 0 ∨ P.c ≠ 0 ∨ P.d ≠ 0) : P.toPoly ≠ 0 :=
  by
  contrapose! h0
  rw [(to_poly_eq_zero_iff P).mp h0]
  exact ⟨rfl, rfl, rfl, rfl⟩
#align cubic.ne_zero cubic.ne_zero

theorem ne_zero_of_a_ne_zero (ha : P.a ≠ 0) : P.toPoly ≠ 0 :=
  (or_imp.mp NeZero).1 ha
#align cubic.ne_zero_of_a_ne_zero Cubic.ne_zero_of_a_ne_zero

theorem ne_zero_of_b_ne_zero (hb : P.b ≠ 0) : P.toPoly ≠ 0 :=
  (or_imp.mp (or_imp.mp NeZero).2).1 hb
#align cubic.ne_zero_of_b_ne_zero Cubic.ne_zero_of_b_ne_zero

theorem ne_zero_of_c_ne_zero (hc : P.c ≠ 0) : P.toPoly ≠ 0 :=
  (or_imp.mp (or_imp.mp (or_imp.mp NeZero).2).2).1 hc
#align cubic.ne_zero_of_c_ne_zero Cubic.ne_zero_of_c_ne_zero

theorem ne_zero_of_d_ne_zero (hd : P.d ≠ 0) : P.toPoly ≠ 0 :=
  (or_imp.mp (or_imp.mp (or_imp.mp NeZero).2).2).2 hd
#align cubic.ne_zero_of_d_ne_zero Cubic.ne_zero_of_d_ne_zero

@[simp]
theorem leading_coeff_of_a_ne_zero (ha : P.a ≠ 0) : P.toPoly.leadingCoeff = P.a :=
  leading_coeff_cubic ha
#align cubic.leading_coeff_of_a_ne_zero Cubic.leading_coeff_of_a_ne_zero

@[simp]
theorem leading_coeff_of_a_ne_zero' (ha : a ≠ 0) : (toPoly ⟨a, b, c, d⟩).leadingCoeff = a :=
  leading_coeff_of_a_ne_zero ha
#align cubic.leading_coeff_of_a_ne_zero' Cubic.leading_coeff_of_a_ne_zero'

@[simp]
theorem leading_coeff_of_b_ne_zero (ha : P.a = 0) (hb : P.b ≠ 0) : P.toPoly.leadingCoeff = P.b := by
  rw [of_a_eq_zero ha, leading_coeff_quadratic hb]
#align cubic.leading_coeff_of_b_ne_zero Cubic.leading_coeff_of_b_ne_zero

@[simp]
theorem leading_coeff_of_b_ne_zero' (hb : b ≠ 0) : (toPoly ⟨0, b, c, d⟩).leadingCoeff = b :=
  leading_coeff_of_b_ne_zero rfl hb
#align cubic.leading_coeff_of_b_ne_zero' Cubic.leading_coeff_of_b_ne_zero'

@[simp]
theorem leading_coeff_of_c_ne_zero (ha : P.a = 0) (hb : P.b = 0) (hc : P.c ≠ 0) :
    P.toPoly.leadingCoeff = P.c := by rw [of_b_eq_zero ha hb, leading_coeff_linear hc]
#align cubic.leading_coeff_of_c_ne_zero Cubic.leading_coeff_of_c_ne_zero

@[simp]
theorem leading_coeff_of_c_ne_zero' (hc : c ≠ 0) : (toPoly ⟨0, 0, c, d⟩).leadingCoeff = c :=
  leading_coeff_of_c_ne_zero rfl rfl hc
#align cubic.leading_coeff_of_c_ne_zero' Cubic.leading_coeff_of_c_ne_zero'

@[simp]
theorem leading_coeff_of_c_eq_zero (ha : P.a = 0) (hb : P.b = 0) (hc : P.c = 0) :
    P.toPoly.leadingCoeff = P.d := by rw [of_c_eq_zero ha hb hc, leading_coeff_C]
#align cubic.leading_coeff_of_c_eq_zero Cubic.leading_coeff_of_c_eq_zero

@[simp]
theorem leading_coeff_of_c_eq_zero' : (toPoly ⟨0, 0, 0, d⟩).leadingCoeff = d :=
  leading_coeff_of_c_eq_zero rfl rfl rfl
#align cubic.leading_coeff_of_c_eq_zero' Cubic.leading_coeff_of_c_eq_zero'

theorem monic_of_a_eq_one (ha : P.a = 1) : P.toPoly.Monic :=
  by
  nontriviality
  rw [monic,
    leading_coeff_of_a_ne_zero <| by
      rw [ha]
      exact one_ne_zero,
    ha]
#align cubic.monic_of_a_eq_one Cubic.monic_of_a_eq_one

theorem monic_of_a_eq_one' : (toPoly ⟨1, b, c, d⟩).Monic :=
  monic_of_a_eq_one rfl
#align cubic.monic_of_a_eq_one' Cubic.monic_of_a_eq_one'

theorem monic_of_b_eq_one (ha : P.a = 0) (hb : P.b = 1) : P.toPoly.Monic :=
  by
  nontriviality
  rw [monic,
    leading_coeff_of_b_ne_zero ha <| by
      rw [hb]
      exact one_ne_zero,
    hb]
#align cubic.monic_of_b_eq_one Cubic.monic_of_b_eq_one

theorem monic_of_b_eq_one' : (toPoly ⟨0, 1, c, d⟩).Monic :=
  monic_of_b_eq_one rfl rfl
#align cubic.monic_of_b_eq_one' Cubic.monic_of_b_eq_one'

theorem monic_of_c_eq_one (ha : P.a = 0) (hb : P.b = 0) (hc : P.c = 1) : P.toPoly.Monic :=
  by
  nontriviality
  rw [monic,
    leading_coeff_of_c_ne_zero ha hb <| by
      rw [hc]
      exact one_ne_zero,
    hc]
#align cubic.monic_of_c_eq_one Cubic.monic_of_c_eq_one

theorem monic_of_c_eq_one' : (toPoly ⟨0, 0, 1, d⟩).Monic :=
  monic_of_c_eq_one rfl rfl rfl
#align cubic.monic_of_c_eq_one' Cubic.monic_of_c_eq_one'

theorem monic_of_d_eq_one (ha : P.a = 0) (hb : P.b = 0) (hc : P.c = 0) (hd : P.d = 1) :
    P.toPoly.Monic := by rw [monic, leading_coeff_of_c_eq_zero ha hb hc, hd]
#align cubic.monic_of_d_eq_one Cubic.monic_of_d_eq_one

theorem monic_of_d_eq_one' : (toPoly ⟨0, 0, 0, 1⟩).Monic :=
  monic_of_d_eq_one rfl rfl rfl rfl
#align cubic.monic_of_d_eq_one' Cubic.monic_of_d_eq_one'

end Coeff

/-! ### Degrees -/


section Degree

/-- The equivalence between cubic polynomials and polynomials of degree at most three. -/
@[simps]
def equiv : Cubic R ≃ { p : R[X] // p.degree ≤ 3 }
    where
  toFun P := ⟨P.toPoly, degree_cubic_le⟩
  invFun f := ⟨coeff f 3, coeff f 2, coeff f 1, coeff f 0⟩
  left_inv P := by ext <;> simp only [Subtype.coe_mk, coeffs]
  right_inv f := by
    ext (_ | _ | _ | _ | n) <;> simp only [Subtype.coe_mk, coeffs]
    have h3 : 3 < n + 4 := by linarith only
    rw [coeff_eq_zero h3,
      (degree_le_iff_coeff_zero (f : R[X]) 3).mp f.2 _ <| with_bot.coe_lt_coe.mpr h3]
#align cubic.equiv Cubic.equiv

@[simp]
theorem degree_of_a_ne_zero (ha : P.a ≠ 0) : P.toPoly.degree = 3 :=
  degree_cubic ha
#align cubic.degree_of_a_ne_zero Cubic.degree_of_a_ne_zero

@[simp]
theorem degree_of_a_ne_zero' (ha : a ≠ 0) : (toPoly ⟨a, b, c, d⟩).degree = 3 :=
  degree_of_a_ne_zero ha
#align cubic.degree_of_a_ne_zero' Cubic.degree_of_a_ne_zero'

theorem degree_of_a_eq_zero (ha : P.a = 0) : P.toPoly.degree ≤ 2 := by
  simpa only [of_a_eq_zero ha] using degree_quadratic_le
#align cubic.degree_of_a_eq_zero Cubic.degree_of_a_eq_zero

theorem degree_of_a_eq_zero' : (toPoly ⟨0, b, c, d⟩).degree ≤ 2 :=
  degree_of_a_eq_zero rfl
#align cubic.degree_of_a_eq_zero' Cubic.degree_of_a_eq_zero'

@[simp]
theorem degree_of_b_ne_zero (ha : P.a = 0) (hb : P.b ≠ 0) : P.toPoly.degree = 2 := by
  rw [of_a_eq_zero ha, degree_quadratic hb]
#align cubic.degree_of_b_ne_zero Cubic.degree_of_b_ne_zero

@[simp]
theorem degree_of_b_ne_zero' (hb : b ≠ 0) : (toPoly ⟨0, b, c, d⟩).degree = 2 :=
  degree_of_b_ne_zero rfl hb
#align cubic.degree_of_b_ne_zero' Cubic.degree_of_b_ne_zero'

theorem degree_of_b_eq_zero (ha : P.a = 0) (hb : P.b = 0) : P.toPoly.degree ≤ 1 := by
  simpa only [of_b_eq_zero ha hb] using degree_linear_le
#align cubic.degree_of_b_eq_zero Cubic.degree_of_b_eq_zero

theorem degree_of_b_eq_zero' : (toPoly ⟨0, 0, c, d⟩).degree ≤ 1 :=
  degree_of_b_eq_zero rfl rfl
#align cubic.degree_of_b_eq_zero' Cubic.degree_of_b_eq_zero'

@[simp]
theorem degree_of_c_ne_zero (ha : P.a = 0) (hb : P.b = 0) (hc : P.c ≠ 0) : P.toPoly.degree = 1 := by
  rw [of_b_eq_zero ha hb, degree_linear hc]
#align cubic.degree_of_c_ne_zero Cubic.degree_of_c_ne_zero

@[simp]
theorem degree_of_c_ne_zero' (hc : c ≠ 0) : (toPoly ⟨0, 0, c, d⟩).degree = 1 :=
  degree_of_c_ne_zero rfl rfl hc
#align cubic.degree_of_c_ne_zero' Cubic.degree_of_c_ne_zero'

theorem degree_of_c_eq_zero (ha : P.a = 0) (hb : P.b = 0) (hc : P.c = 0) : P.toPoly.degree ≤ 0 := by
  simpa only [of_c_eq_zero ha hb hc] using degree_C_le
#align cubic.degree_of_c_eq_zero Cubic.degree_of_c_eq_zero

theorem degree_of_c_eq_zero' : (toPoly ⟨0, 0, 0, d⟩).degree ≤ 0 :=
  degree_of_c_eq_zero rfl rfl rfl
#align cubic.degree_of_c_eq_zero' Cubic.degree_of_c_eq_zero'

@[simp]
theorem degree_of_d_ne_zero (ha : P.a = 0) (hb : P.b = 0) (hc : P.c = 0) (hd : P.d ≠ 0) :
    P.toPoly.degree = 0 := by rw [of_c_eq_zero ha hb hc, degree_C hd]
#align cubic.degree_of_d_ne_zero Cubic.degree_of_d_ne_zero

@[simp]
theorem degree_of_d_ne_zero' (hd : d ≠ 0) : (toPoly ⟨0, 0, 0, d⟩).degree = 0 :=
  degree_of_d_ne_zero rfl rfl rfl hd
#align cubic.degree_of_d_ne_zero' Cubic.degree_of_d_ne_zero'

@[simp]
theorem degree_of_d_eq_zero (ha : P.a = 0) (hb : P.b = 0) (hc : P.c = 0) (hd : P.d = 0) :
    P.toPoly.degree = ⊥ := by rw [of_d_eq_zero ha hb hc hd, degree_zero]
#align cubic.degree_of_d_eq_zero Cubic.degree_of_d_eq_zero

@[simp]
theorem degree_of_d_eq_zero' : (⟨0, 0, 0, 0⟩ : Cubic R).toPoly.degree = ⊥ :=
  degree_of_d_eq_zero rfl rfl rfl rfl
#align cubic.degree_of_d_eq_zero' Cubic.degree_of_d_eq_zero'

@[simp]
theorem degree_of_zero : (0 : Cubic R).toPoly.degree = ⊥ :=
  degree_of_d_eq_zero'
#align cubic.degree_of_zero Cubic.degree_of_zero

@[simp]
theorem nat_degree_of_a_ne_zero (ha : P.a ≠ 0) : P.toPoly.natDegree = 3 :=
  nat_degree_cubic ha
#align cubic.nat_degree_of_a_ne_zero Cubic.nat_degree_of_a_ne_zero

@[simp]
theorem nat_degree_of_a_ne_zero' (ha : a ≠ 0) : (toPoly ⟨a, b, c, d⟩).natDegree = 3 :=
  nat_degree_of_a_ne_zero ha
#align cubic.nat_degree_of_a_ne_zero' Cubic.nat_degree_of_a_ne_zero'

theorem nat_degree_of_a_eq_zero (ha : P.a = 0) : P.toPoly.natDegree ≤ 2 := by
  simpa only [of_a_eq_zero ha] using nat_degree_quadratic_le
#align cubic.nat_degree_of_a_eq_zero Cubic.nat_degree_of_a_eq_zero

theorem nat_degree_of_a_eq_zero' : (toPoly ⟨0, b, c, d⟩).natDegree ≤ 2 :=
  nat_degree_of_a_eq_zero rfl
#align cubic.nat_degree_of_a_eq_zero' Cubic.nat_degree_of_a_eq_zero'

@[simp]
theorem nat_degree_of_b_ne_zero (ha : P.a = 0) (hb : P.b ≠ 0) : P.toPoly.natDegree = 2 := by
  rw [of_a_eq_zero ha, nat_degree_quadratic hb]
#align cubic.nat_degree_of_b_ne_zero Cubic.nat_degree_of_b_ne_zero

@[simp]
theorem nat_degree_of_b_ne_zero' (hb : b ≠ 0) : (toPoly ⟨0, b, c, d⟩).natDegree = 2 :=
  nat_degree_of_b_ne_zero rfl hb
#align cubic.nat_degree_of_b_ne_zero' Cubic.nat_degree_of_b_ne_zero'

theorem nat_degree_of_b_eq_zero (ha : P.a = 0) (hb : P.b = 0) : P.toPoly.natDegree ≤ 1 := by
  simpa only [of_b_eq_zero ha hb] using nat_degree_linear_le
#align cubic.nat_degree_of_b_eq_zero Cubic.nat_degree_of_b_eq_zero

theorem nat_degree_of_b_eq_zero' : (toPoly ⟨0, 0, c, d⟩).natDegree ≤ 1 :=
  nat_degree_of_b_eq_zero rfl rfl
#align cubic.nat_degree_of_b_eq_zero' Cubic.nat_degree_of_b_eq_zero'

@[simp]
theorem nat_degree_of_c_ne_zero (ha : P.a = 0) (hb : P.b = 0) (hc : P.c ≠ 0) :
    P.toPoly.natDegree = 1 := by rw [of_b_eq_zero ha hb, nat_degree_linear hc]
#align cubic.nat_degree_of_c_ne_zero Cubic.nat_degree_of_c_ne_zero

@[simp]
theorem nat_degree_of_c_ne_zero' (hc : c ≠ 0) : (toPoly ⟨0, 0, c, d⟩).natDegree = 1 :=
  nat_degree_of_c_ne_zero rfl rfl hc
#align cubic.nat_degree_of_c_ne_zero' Cubic.nat_degree_of_c_ne_zero'

@[simp]
theorem nat_degree_of_c_eq_zero (ha : P.a = 0) (hb : P.b = 0) (hc : P.c = 0) :
    P.toPoly.natDegree = 0 := by rw [of_c_eq_zero ha hb hc, nat_degree_C]
#align cubic.nat_degree_of_c_eq_zero Cubic.nat_degree_of_c_eq_zero

@[simp]
theorem nat_degree_of_c_eq_zero' : (toPoly ⟨0, 0, 0, d⟩).natDegree = 0 :=
  nat_degree_of_c_eq_zero rfl rfl rfl
#align cubic.nat_degree_of_c_eq_zero' Cubic.nat_degree_of_c_eq_zero'

@[simp]
theorem nat_degree_of_zero : (0 : Cubic R).toPoly.natDegree = 0 :=
  nat_degree_of_c_eq_zero'
#align cubic.nat_degree_of_zero Cubic.nat_degree_of_zero

end Degree

/-! ### Map across a homomorphism -/


section Map

variable [Semiring S] {φ : R →+* S}

/-- Map a cubic polynomial across a semiring homomorphism. -/
def map (φ : R →+* S) (P : Cubic R) : Cubic S :=
  ⟨φ P.a, φ P.b, φ P.c, φ P.d⟩
#align cubic.map Cubic.map

theorem map_to_poly : (map φ P).toPoly = Polynomial.map φ P.toPoly := by
  simp only [map, to_poly, map_C, map_X, Polynomial.map_add, Polynomial.map_mul, Polynomial.map_pow]
#align cubic.map_to_poly Cubic.map_to_poly

end Map

end Basic

section Roots

open Multiset

/-! ### Roots over an extension -/


section Extension

variable {P : Cubic R} [CommRing R] [CommRing S] {φ : R →+* S}

/-- The roots of a cubic polynomial. -/
def roots [IsDomain R] (P : Cubic R) : Multiset R :=
  P.toPoly.roots
#align cubic.roots Cubic.roots

theorem map_roots [IsDomain S] : (map φ P).roots = (Polynomial.map φ P.toPoly).roots := by
  rw [roots, map_to_poly]
#align cubic.map_roots Cubic.map_roots

theorem mem_roots_iff [IsDomain R] (h0 : P.toPoly ≠ 0) (x : R) :
    x ∈ P.roots ↔ P.a * x ^ 3 + P.b * x ^ 2 + P.c * x + P.d = 0 :=
  by
  rw [roots, mem_roots h0, is_root, to_poly]
  simp only [eval_C, eval_X, eval_add, eval_mul, eval_pow]
#align cubic.mem_roots_iff Cubic.mem_roots_iff

theorem card_roots_le [IsDomain R] [DecidableEq R] : P.roots.toFinset.card ≤ 3 :=
  by
  apply (to_finset_card_le P.to_poly.roots).trans
  by_cases hP : P.to_poly = 0
  ·
    exact
      (card_roots' P.to_poly).trans
        (by
          rw [hP, nat_degree_zero]
          exact zero_le 3)
  · exact WithBot.coe_le_coe.1 ((card_roots hP).trans degree_cubic_le)
#align cubic.card_roots_le Cubic.card_roots_le

end Extension

variable {P : Cubic F} [Field F] [Field K] {φ : F →+* K} {x y z : K}

/-! ### Roots over a splitting field -/


section Split

theorem splits_iff_card_roots (ha : P.a ≠ 0) : Splits φ P.toPoly ↔ (map φ P).roots.card = 3 :=
  by
  replace ha : (map φ P).a ≠ 0 := (_root_.map_ne_zero φ).mpr ha
  nth_rw_lhs 1 [← RingHom.id_comp φ]
  rw [roots, ← splits_map_iff, ← map_to_poly, splits_iff_card_roots, ←
    ((degree_eq_iff_nat_degree_eq <| ne_zero_of_a_ne_zero ha).mp <| degree_of_a_ne_zero ha : _ = 3)]
#align cubic.splits_iff_card_roots Cubic.splits_iff_card_roots

theorem splits_iff_roots_eq_three (ha : P.a ≠ 0) :
    Splits φ P.toPoly ↔ ∃ x y z : K, (map φ P).roots = {x, y, z} := by
  rw [splits_iff_card_roots ha, card_eq_three]
#align cubic.splits_iff_roots_eq_three Cubic.splits_iff_roots_eq_three

theorem eq_prod_three_roots (ha : P.a ≠ 0) (h3 : (map φ P).roots = {x, y, z}) :
    (map φ P).toPoly = c (φ P.a) * (X - c x) * (X - c y) * (X - c z) :=
  by
  rw [map_to_poly,
    eq_prod_roots_of_splits <|
      (splits_iff_roots_eq_three ha).mpr <| Exists.intro x <| Exists.intro y <| Exists.intro z h3,
    leading_coeff_of_a_ne_zero ha, ← map_roots, h3]
  change C (φ P.a) * ((X - C x) ::ₘ (X - C y) ::ₘ {X - C z}).Prod = _
  rw [prod_cons, prod_cons, prod_singleton, mul_assoc, mul_assoc]
#align cubic.eq_prod_three_roots Cubic.eq_prod_three_roots

theorem eq_sum_three_roots (ha : P.a ≠ 0) (h3 : (map φ P).roots = {x, y, z}) :
    map φ P =
      ⟨φ P.a, φ P.a * -(x + y + z), φ P.a * (x * y + x * z + y * z), φ P.a * -(x * y * z)⟩ :=
  by
  apply_fun to_poly
  any_goals exact fun P Q => (to_poly_injective P Q).mp
  rw [eq_prod_three_roots ha h3, C_mul_prod_X_sub_C_eq]
#align cubic.eq_sum_three_roots Cubic.eq_sum_three_roots

theorem b_eq_three_roots (ha : P.a ≠ 0) (h3 : (map φ P).roots = {x, y, z}) :
    φ P.b = φ P.a * -(x + y + z) := by injection eq_sum_three_roots ha h3
#align cubic.b_eq_three_roots Cubic.b_eq_three_roots

theorem c_eq_three_roots (ha : P.a ≠ 0) (h3 : (map φ P).roots = {x, y, z}) :
    φ P.c = φ P.a * (x * y + x * z + y * z) := by injection eq_sum_three_roots ha h3
#align cubic.c_eq_three_roots Cubic.c_eq_three_roots

theorem d_eq_three_roots (ha : P.a ≠ 0) (h3 : (map φ P).roots = {x, y, z}) :
    φ P.d = φ P.a * -(x * y * z) := by injection eq_sum_three_roots ha h3
#align cubic.d_eq_three_roots Cubic.d_eq_three_roots

end Split

/-! ### Discriminant over a splitting field -/


section Discriminant

/-- The discriminant of a cubic polynomial. -/
def disc {R : Type _} [Ring R] (P : Cubic R) : R :=
  P.b ^ 2 * P.c ^ 2 - 4 * P.a * P.c ^ 3 - 4 * P.b ^ 3 * P.d - 27 * P.a ^ 2 * P.d ^ 2 +
    18 * P.a * P.b * P.c * P.d
#align cubic.disc Cubic.disc

theorem disc_eq_prod_three_roots (ha : P.a ≠ 0) (h3 : (map φ P).roots = {x, y, z}) :
    φ P.disc = (φ P.a * φ P.a * (x - y) * (x - z) * (y - z)) ^ 2 :=
  by
  simp only [disc, RingHom.map_add, RingHom.map_sub, RingHom.map_mul, map_pow]
  simp only [RingHom.map_one, map_bit0, map_bit1]
  rw [b_eq_three_roots ha h3, c_eq_three_roots ha h3, d_eq_three_roots ha h3]
  ring1
#align cubic.disc_eq_prod_three_roots Cubic.disc_eq_prod_three_roots

theorem disc_ne_zero_iff_roots_ne (ha : P.a ≠ 0) (h3 : (map φ P).roots = {x, y, z}) :
    P.disc ≠ 0 ↔ x ≠ y ∧ x ≠ z ∧ y ≠ z :=
  by
  rw [← _root_.map_ne_zero φ, disc_eq_prod_three_roots ha h3, pow_two]
  simp_rw [mul_ne_zero_iff, sub_ne_zero, _root_.map_ne_zero, and_self_iff, and_iff_right ha,
    and_assoc']
#align cubic.disc_ne_zero_iff_roots_ne Cubic.disc_ne_zero_iff_roots_ne

theorem disc_ne_zero_iff_roots_nodup (ha : P.a ≠ 0) (h3 : (map φ P).roots = {x, y, z}) :
    P.disc ≠ 0 ↔ (map φ P).roots.Nodup :=
  by
  rw [disc_ne_zero_iff_roots_ne ha h3, h3]
  change _ ↔ (x ::ₘ y ::ₘ {z}).Nodup
  rw [nodup_cons, nodup_cons, mem_cons, mem_singleton, mem_singleton]
  simp only [nodup_singleton]
  tauto
#align cubic.disc_ne_zero_iff_roots_nodup Cubic.disc_ne_zero_iff_roots_nodup

theorem card_roots_of_disc_ne_zero [DecidableEq K] (ha : P.a ≠ 0) (h3 : (map φ P).roots = {x, y, z})
    (hd : P.disc ≠ 0) : (map φ P).roots.toFinset.card = 3 :=
  by
  rw [to_finset_card_of_nodup <| (disc_ne_zero_iff_roots_nodup ha h3).mp hd, ←
    splits_iff_card_roots ha, splits_iff_roots_eq_three ha]
  exact ⟨x, ⟨y, ⟨z, h3⟩⟩⟩
#align cubic.card_roots_of_disc_ne_zero Cubic.card_roots_of_disc_ne_zero

end Discriminant

end Roots

end Cubic

