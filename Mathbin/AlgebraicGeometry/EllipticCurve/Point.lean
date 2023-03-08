/-
Copyright (c) 2022 David Kurniadi Angdinata. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: David Kurniadi Angdinata

! This file was ported from Lean 3 source module algebraic_geometry.elliptic_curve.point
! leanprover-community/mathlib commit 03994e05d8bfc59a41d2ec99523d6553d21848ac
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.AlgebraicGeometry.EllipticCurve.Weierstrass
import Mathbin.FieldTheory.Galois
import Mathbin.RingTheory.ClassGroup

/-!
# The group of nonsingular rational points on a Weierstrass curve over a field

This file defines the type of nonsingular rational points on a Weierstrass curve over a field and
(TODO) proves that it forms an abelian group under a geometric secant-and-tangent process.

## Mathematical background

Let `W` be a Weierstrass curve over a field `F`. A rational point on `W` is simply a point
$[A:B:C]$ defined over `F` in the projective plane satisfying the homogeneous cubic equation
$B^2C + a_1ABC + a_3BC^2 = A^3 + a_2A^2C + a_4AC^2 + a_6C^3$. Any such point either lies in the
affine chart $C \ne 0$ and satisfies the Weierstrass equation obtained by setting $X := A/C$ and
$Y := B/C$, or is the unique point at infinity $0 := [0:1:0]$ when $C = 0$. With this new
description, a nonsingular rational point on `W` is either $0$ or an affine point $(x, y)$ where
the partial derivatives $W_X(X, Y)$ and $W_Y(X, Y)$ do not vanish simultaneously. For a field
extension `K` of `F`, a `K`-rational point is simply a rational point on `W` base changed to `K`.

The set of nonsingular rational points forms an abelian group under a secant-and-tangent process.
 * The identity rational point is `0`.
 * Given a nonsingular rational point `P`, its negation `-P` is defined to be the unique third
    point of intersection between `W` and the line through `0` and `P`.
    Explicitly, if `P` is $(x, y)$, then `-P` is $(x, -y - a_1x - a_3)$.
 * Given two points `P` and `Q`, their addition `P + Q` is defined to be the negation of the unique
    third point of intersection between `W` and the line `L` through `P` and `Q`.
    Explicitly, let `P` be $(x_1, y_1)$ and let `Q` be $(x_2, y_2)$.
      * If $x_1 = x_2$ and $y_1 = -y_2 - a_1x_2 - a_3$, then `L` is vertical and `P + Q` is `0`.
      * If $x_1 = x_2$ and $y_1 \ne -y_2 - a_1x_2 - a_3$, then `L` is the tangent of `W` at `P = Q`,
        and has slope $\ell := (3x_1^2 + 2a_2x_1 + a_4 - a_1y_1) / (2y_1 + a_1x_1 + a_3)$.
      * Otherwise $x_1 \ne x_2$, then `L` is the secant of `W` through `P` and `Q`, and has slope
        $\ell := (y_1 - y_2) / (x_1 - x_2)$.
    In the latter two cases, the $X$-coordinate of `P + Q` is then the unique third solution of the
    equation obtained by substituting the line $Y = \ell(X - x_1) + y_1$ into the Weierstrass
    equation, and can be written down explicitly as $x := \ell^2 + a_1\ell - a_2 - x_1 - x_2$ by
    inspecting the $X^2$ terms. The $Y$-coordinate of `P + Q`, after applying the final negation
    that maps $Y$ to $-Y - a_1X - a_3$, is precisely $y := -(\ell(x - x_1) + y_1) - a_1x - a_3$.
The group law on this set is then uniquely determined by these constructions.

## Main definitions

 * `weierstrass_curve.point`: the type of nonsingular rational points on a Weierstrass curve `W`.
 * `weierstrass_curve.point.add`: the addition of two nonsingular rational points on `W`.

## Main statements

 * TODO: the addition of two nonsingular rational points on `W` forms a group.

## Notations

 * `W⟮K⟯`: the group of nonsingular rational points on a Weierstrass curve `W` base changed to `K`.

## References

[J Silverman, *The Arithmetic of Elliptic Curves*][silverman2009]

## Tags

elliptic curve, rational point, group law
-/


/- ./././Mathport/Syntax/Translate/Expr.lean:330:4: warning: unsupported (TODO): `[tacs] -/
-- temporary import to enable point notation
-- temporary import to enable point notation
private unsafe def map_simp : tactic Unit :=
  sorry
#align map_simp map_simp

/- ./././Mathport/Syntax/Translate/Expr.lean:330:4: warning: unsupported (TODO): `[tacs] -/
private unsafe def eval_simp : tactic Unit :=
  sorry
#align eval_simp eval_simp

/- ./././Mathport/Syntax/Translate/Expr.lean:330:4: warning: unsupported (TODO): `[tacs] -/
private unsafe def C_simp : tactic Unit :=
  sorry
#align C_simp C_simp

/- ./././Mathport/Syntax/Translate/Expr.lean:330:4: warning: unsupported (TODO): `[tacs] -/
private unsafe def derivative_simp : tactic Unit :=
  sorry
#align derivative_simp derivative_simp

universe u v w

namespace WeierstrassCurve

open Polynomial

open Polynomial PolynomialPolynomial

section Basic

/-! ### Polynomials associated to nonsingular rational points on a Weierstrass curve -/


variable {R : Type u} [CommRing R] (W : WeierstrassCurve R) (A : Type v) [CommRing A] [Algebra R A]
  (B : Type w) [CommRing B] [Algebra R B] [Algebra A B] [IsScalarTower R A B] (x₁ x₂ y₁ y₂ L : R)

/-- The polynomial $-Y - a_1X - a_3$ associated to negation. -/
noncomputable def negPolynomial : R[X][Y] :=
  -Y - C (C W.a₁ * X + C W.a₃)
#align weierstrass_curve.neg_polynomial WeierstrassCurve.negPolynomial

/-- The $Y$-coordinate of the negation of an affine point in `W`.

This depends on `W`, and has argument order: $x_1$, $y_1$. -/
@[simp]
def negY : R :=
  -y₁ - W.a₁ * x₁ - W.a₃
#align weierstrass_curve.neg_Y WeierstrassCurve.negY

theorem negY_negY : W.negY x₁ (W.negY x₁ y₁) = y₁ :=
  by
  simp only [neg_Y]
  ring1
#align weierstrass_curve.neg_Y_neg_Y WeierstrassCurve.negY_negY

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.2556673791.map_simp -/
theorem baseChange_negY :
    (W.base_change A).negY (algebraMap R A x₁) (algebraMap R A y₁) =
      algebraMap R A (W.negY x₁ y₁) :=
  by
  simp only [neg_Y]
  run_tac
    map_simp
  rfl
#align weierstrass_curve.base_change_neg_Y WeierstrassCurve.baseChange_negY

theorem baseChange_negY_of_baseChange (x₁ y₁ : A) :
    (W.base_change B).negY (algebraMap A B x₁) (algebraMap A B y₁) =
      algebraMap A B ((W.base_change A).negY x₁ y₁) :=
  by rw [← base_change_neg_Y, base_change_base_change]
#align weierstrass_curve.base_change_neg_Y_of_base_change WeierstrassCurve.baseChange_negY_of_baseChange

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.1038319287.eval_simp -/
@[simp]
theorem eval_negPolynomial : (W.negPolynomial.eval <| C y₁).eval x₁ = W.negY x₁ y₁ :=
  by
  rw [neg_Y, sub_sub, neg_polynomial]
  run_tac
    eval_simp
#align weierstrass_curve.eval_neg_polynomial WeierstrassCurve.eval_negPolynomial

/-- The polynomial $L(X - x_1) + y_1$ associated to the line $Y = L(X - x_1) + y_1$,
with a slope of $L$ that passes through an affine point $(x_1, y_1)$.

This does not depend on `W`, and has argument order: $x_1$, $y_1$, $L$. -/
noncomputable def linePolynomial : R[X] :=
  C L * (X - C x₁) + C y₁
#align weierstrass_curve.line_polynomial WeierstrassCurve.linePolynomial

/-- The polynomial obtained by substituting the line $Y = L(X - x_1) + y_1$, with a slope of $L$
that passes through an affine point $(x_1, y_1)$, into the polynomial $W(X, Y)$ associated to `W`.
If such a line intersects `W` at another point $(x_2, y_2)$, then the roots of this polynomial are
precisely $x_1$, $x_2$, and the $X$-coordinate of the addition of $(x_1, y_1)$ and $(x_2, y_2)$.

This depends on `W`, and has argument order: $x_1$, $y_1$, $L$. -/
noncomputable def addPolynomial : R[X] :=
  W.Polynomial.eval <| linePolynomial x₁ y₁ L
#align weierstrass_curve.add_polynomial WeierstrassCurve.addPolynomial

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.1038319287.eval_simp -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.170323567.C_simp -/
theorem addPolynomial_eq :
    W.addPolynomial x₁ y₁ L =
      -Cubic.toPoly
          ⟨1, -L ^ 2 - W.a₁ * L + W.a₂,
            2 * x₁ * L ^ 2 + (W.a₁ * x₁ - 2 * y₁ - W.a₃) * L + (-W.a₁ * y₁ + W.a₄),
            -x₁ ^ 2 * L ^ 2 + (2 * x₁ * y₁ + W.a₃ * x₁) * L - (y₁ ^ 2 + W.a₃ * y₁ - W.a₆)⟩ :=
  by
  rw [add_polynomial, line_polynomial, WeierstrassCurve.polynomial, Cubic.toPoly]
  run_tac
    eval_simp
  run_tac
    C_simp
  ring1
#align weierstrass_curve.add_polynomial_eq WeierstrassCurve.addPolynomial_eq

/-- The $X$-coordinate of the addition of two affine points $(x_1, y_1)$ and $(x_2, y_2)$ in `W`,
where the line through them is not vertical and has a slope of $L$.

This depends on `W`, and has argument order: $x_1$, $x_2$, $L$. -/
@[simp]
def addX : R :=
  L ^ 2 + W.a₁ * L - W.a₂ - x₁ - x₂
#align weierstrass_curve.add_X WeierstrassCurve.addX

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.2556673791.map_simp -/
theorem baseChange_addX :
    (W.base_change A).addX (algebraMap R A x₁) (algebraMap R A x₂) (algebraMap R A L) =
      algebraMap R A (W.addX x₁ x₂ L) :=
  by
  simp only [add_X]
  run_tac
    map_simp
  rfl
#align weierstrass_curve.base_change_add_X WeierstrassCurve.baseChange_addX

theorem baseChange_addX_of_baseChange (x₁ x₂ L : A) :
    (W.base_change B).addX (algebraMap A B x₁) (algebraMap A B x₂) (algebraMap A B L) =
      algebraMap A B ((W.base_change A).addX x₁ x₂ L) :=
  by rw [← base_change_add_X, base_change_base_change]
#align weierstrass_curve.base_change_add_X_of_base_change WeierstrassCurve.baseChange_addX_of_baseChange

/-- The $Y$-coordinate, before applying the final negation, of the addition of two affine points
$(x_1, y_1)$ and $(x_2, y_2)$, where the line through them is not vertical and has a slope of $L$.

This depends on `W`, and has argument order: $x_1$, $x_2$, $y_1$, $L$. -/
@[simp]
def addY' : R :=
  L * (W.addX x₁ x₂ L - x₁) + y₁
#align weierstrass_curve.add_Y' WeierstrassCurve.addY'

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.2556673791.map_simp -/
theorem baseChange_addY' :
    (W.base_change A).addY' (algebraMap R A x₁) (algebraMap R A x₂) (algebraMap R A y₁)
        (algebraMap R A L) =
      algebraMap R A (W.addY' x₁ x₂ y₁ L) :=
  by
  simp only [add_Y', base_change_add_X]
  run_tac
    map_simp
#align weierstrass_curve.base_change_add_Y' WeierstrassCurve.baseChange_addY'

theorem baseChange_addY'_of_baseChange (x₁ x₂ y₁ L : A) :
    (W.base_change B).addY' (algebraMap A B x₁) (algebraMap A B x₂) (algebraMap A B y₁)
        (algebraMap A B L) =
      algebraMap A B ((W.base_change A).addY' x₁ x₂ y₁ L) :=
  by rw [← base_change_add_Y', base_change_base_change]
#align weierstrass_curve.base_change_add_Y'_of_base_change WeierstrassCurve.baseChange_addY'_of_baseChange

/-- The $Y$-coordinate of the addition of two affine points $(x_1, y_1)$ and $(x_2, y_2)$ in `W`,
where the line through them is not vertical and has a slope of $L$.

This depends on `W`, and has argument order: $x_1$, $x_2$, $y_1$, $L$. -/
@[simp]
def addY : R :=
  W.negY (W.addX x₁ x₂ L) (W.addY' x₁ x₂ y₁ L)
#align weierstrass_curve.add_Y WeierstrassCurve.addY

theorem baseChange_addY :
    (W.base_change A).addY (algebraMap R A x₁) (algebraMap R A x₂) (algebraMap R A y₁)
        (algebraMap R A L) =
      algebraMap R A (W.addY x₁ x₂ y₁ L) :=
  by simp only [add_Y, base_change_add_Y', base_change_add_X, base_change_neg_Y]
#align weierstrass_curve.base_change_add_Y WeierstrassCurve.baseChange_addY

theorem baseChange_addY_of_baseChange (x₁ x₂ y₁ L : A) :
    (W.base_change B).addY (algebraMap A B x₁) (algebraMap A B x₂) (algebraMap A B y₁)
        (algebraMap A B L) =
      algebraMap A B ((W.base_change A).addY x₁ x₂ y₁ L) :=
  by rw [← base_change_add_Y, base_change_base_change]
#align weierstrass_curve.base_change_add_Y_of_base_change WeierstrassCurve.baseChange_addY_of_baseChange

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.1038319287.eval_simp -/
theorem equation_add_iff :
    W.Equation (W.addX x₁ x₂ L) (W.addY' x₁ x₂ y₁ L) ↔
      (W.addPolynomial x₁ y₁ L).eval (W.addX x₁ x₂ L) = 0 :=
  by
  rw [equation, add_Y', add_polynomial, line_polynomial, WeierstrassCurve.polynomial]
  run_tac
    eval_simp
#align weierstrass_curve.equation_add_iff WeierstrassCurve.equation_add_iff

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.1038319287.eval_simp -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.1038319287.eval_simp -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.150691367.derivative_simp -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.1038319287.eval_simp -/
theorem nonsingular_add_of_eval_derivative_ne_zero
    (hx' : W.Equation (W.addX x₁ x₂ L) (W.addY' x₁ x₂ y₁ L))
    (hx : (derivative <| W.addPolynomial x₁ y₁ L).eval (W.addX x₁ x₂ L) ≠ 0) :
    W.Nonsingular (W.addX x₁ x₂ L) (W.addY' x₁ x₂ y₁ L) :=
  by
  rw [nonsingular, and_iff_right hx', add_Y', polynomial_X, polynomial_Y]
  run_tac
    eval_simp
  contrapose! hx
  rw [add_polynomial, line_polynomial, WeierstrassCurve.polynomial]
  run_tac
    eval_simp
  run_tac
    derivative_simp
  simp only [zero_add, add_zero, sub_zero, zero_mul, mul_one]
  run_tac
    eval_simp
  linear_combination (norm := (norm_num1; ring1)) hx.left + L * hx.right
#align weierstrass_curve.nonsingular_add_of_eval_derivative_ne_zero WeierstrassCurve.nonsingular_add_of_eval_derivative_ne_zero

/-! ### The type of nonsingular rational points on a Weierstrass curve -/


/-- A nonsingular rational point on a Weierstrass curve `W` over `R`. This is either the point at
infinity `weierstrass_curve.point.zero` or an affine point `weierstrass_curve.point.some` $(x, y)$
satisfying the equation $y^2 + a_1xy + a_3y = x^3 + a_2x^2 + a_4x + a_6$ of `W`. For an algebraic
extension `S` of `R`, the type of nonsingular `S`-rational points on `W` is denoted `W⟮S⟯`. -/
inductive Point
  | zero
  | some {x y : R} (h : W.Nonsingular x y)
#align weierstrass_curve.point WeierstrassCurve.Point

-- mathport name: «expr ⟮ ⟯»
scoped notation W "⟮" S "⟯" => (W.base_change S).Point

namespace Point

instance : Inhabited W.Point :=
  ⟨zero⟩

instance : Zero W.Point :=
  ⟨zero⟩

@[simp]
theorem zero_def : (zero : W.Point) = 0 :=
  rfl
#align weierstrass_curve.point.zero_def WeierstrassCurve.Point.zero_def

end Point

variable {W x₁ y₁}

theorem equation_neg_iff : W.Equation x₁ (W.negY x₁ y₁) ↔ W.Equation x₁ y₁ :=
  by
  rw [equation_iff, equation_iff, neg_Y]
  congr 2
  ring1
#align weierstrass_curve.equation_neg_iff WeierstrassCurve.equation_neg_iff

theorem equation_neg_of (h : W.Equation x₁ <| W.negY x₁ y₁) : W.Equation x₁ y₁ :=
  equation_neg_iff.mp h
#align weierstrass_curve.equation_neg_of WeierstrassCurve.equation_neg_of

/-- The negation of an affine point in `W` lies in `W`. -/
theorem equation_neg (h : W.Equation x₁ y₁) : W.Equation x₁ <| W.negY x₁ y₁ :=
  equation_neg_iff.mpr h
#align weierstrass_curve.equation_neg WeierstrassCurve.equation_neg

theorem nonsingular_neg_iff : W.Nonsingular x₁ (W.negY x₁ y₁) ↔ W.Nonsingular x₁ y₁ :=
  by
  rw [nonsingular_iff, equation_neg_iff, ← neg_Y, neg_Y_neg_Y, ← @ne_comm _ y₁, nonsingular_iff]
  exact
    and_congr_right'
      ((iff_congr not_and_distrib.symm not_and_distrib.symm).mpr <|
        not_congr <| and_congr_left fun h => by rw [← h])
#align weierstrass_curve.nonsingular_neg_iff WeierstrassCurve.nonsingular_neg_iff

theorem nonsingular_neg_of (h : W.Nonsingular x₁ <| W.negY x₁ y₁) : W.Nonsingular x₁ y₁ :=
  nonsingular_neg_iff.mp h
#align weierstrass_curve.nonsingular_neg_of WeierstrassCurve.nonsingular_neg_of

/-- The negation of a nonsingular affine point in `W` is nonsingular. -/
theorem nonsingular_neg (h : W.Nonsingular x₁ y₁) : W.Nonsingular x₁ <| W.negY x₁ y₁ :=
  nonsingular_neg_iff.mpr h
#align weierstrass_curve.nonsingular_neg WeierstrassCurve.nonsingular_neg

namespace Point

/-- The negation of a nonsingular rational point.

Given a nonsingular rational point `P`, use `-P` instead of `neg P`. -/
def neg : W.Point → W.Point
  | 0 => 0
  | some h => some <| nonsingular_neg h
#align weierstrass_curve.point.neg WeierstrassCurve.Point.neg

instance : Neg W.Point :=
  ⟨neg⟩

@[simp]
theorem neg_def (P : W.Point) : P.neg = -P :=
  rfl
#align weierstrass_curve.point.neg_def WeierstrassCurve.Point.neg_def

@[simp]
theorem neg_zero : (-0 : W.Point) = 0 :=
  rfl
#align weierstrass_curve.point.neg_zero WeierstrassCurve.Point.neg_zero

@[simp]
theorem neg_some (h : W.Nonsingular x₁ y₁) : -some h = some (nonsingular_neg h) :=
  rfl
#align weierstrass_curve.point.neg_some WeierstrassCurve.Point.neg_some

instance : InvolutiveNeg W.Point :=
  ⟨neg, by
    rintro (_ | _)
    · rfl
    · simp
      ring1⟩

end Point

end Basic

section Addition

/-! ### Slopes of lines through nonsingular rational points on a Weierstrass curve -/


open Classical

variable {F : Type u} [Field F] (W : WeierstrassCurve F) (K : Type v) [Field K] [Algebra F K]
  (x₁ x₂ y₁ y₂ : F)

/-- The slope of the line through two affine points $(x_1, y_1)$ and $(x_2, y_2)$ in `W`.
If $x_1 \ne x_2$, then this line is the secant of `W` through $(x_1, y_1)$ and $(x_2, y_2)$,
and has slope $(y_1 - y_2) / (x_1 - x_2)$. Otherwise, if $y_1 \ne -y_1 - a_1x_1 - a_3$,
then this line is the tangent of `W` at $(x_1, y_1) = (x_2, y_2)$, and has slope
$(3x_1^2 + 2a_2x_1 + a_4 - a_1y_1) / (2y_1 + a_1x_1 + a_3)$. Otherwise, this line is vertical,
and has undefined slope, in which case this function returns the value 0.

This depends on `W`, and has argument order: $x_1$, $x_2$, $y_1$, $y_2$. -/
noncomputable def slope : F :=
  if hx : x₁ = x₂ then
    if hy : y₁ = W.negY x₂ y₂ then 0
    else (3 * x₁ ^ 2 + 2 * W.a₂ * x₁ + W.a₄ - W.a₁ * y₁) / (y₁ - W.negY x₁ y₁)
  else (y₁ - y₂) / (x₁ - x₂)
#align weierstrass_curve.slope WeierstrassCurve.slope

variable {W x₁ x₂ y₁ y₂} (h₁ : W.Nonsingular x₁ y₁) (h₂ : W.Nonsingular x₂ y₂)
  (h₁' : W.Equation x₁ y₁) (h₂' : W.Equation x₂ y₂)

@[simp]
theorem slope_of_Y_eq (hx : x₁ = x₂) (hy : y₁ = W.negY x₂ y₂) : W.slope x₁ x₂ y₁ y₂ = 0 := by
  rw [slope, dif_pos hx, dif_pos hy]
#align weierstrass_curve.slope_of_Y_eq WeierstrassCurve.slope_of_Y_eq

@[simp]
theorem slope_of_Y_ne (hx : x₁ = x₂) (hy : y₁ ≠ W.negY x₂ y₂) :
    W.slope x₁ x₂ y₁ y₂ = (3 * x₁ ^ 2 + 2 * W.a₂ * x₁ + W.a₄ - W.a₁ * y₁) / (y₁ - W.negY x₁ y₁) :=
  by rw [slope, dif_pos hx, dif_neg hy]
#align weierstrass_curve.slope_of_Y_ne WeierstrassCurve.slope_of_Y_ne

@[simp]
theorem slope_of_X_ne (hx : x₁ ≠ x₂) : W.slope x₁ x₂ y₁ y₂ = (y₁ - y₂) / (x₁ - x₂) := by
  rw [slope, dif_neg hx]
#align weierstrass_curve.slope_of_X_ne WeierstrassCurve.slope_of_X_ne

theorem slope_of_Y_ne_eq_eval (hx : x₁ = x₂) (hy : y₁ ≠ W.negY x₂ y₂) :
    W.slope x₁ x₂ y₁ y₂ =
      -(W.polynomialX.eval <| C y₁).eval x₁ / (W.polynomialY.eval <| C y₁).eval x₁ :=
  by
  rw [slope_of_Y_ne hx hy, eval_polynomial_X, neg_sub]
  congr 1
  rw [neg_Y, eval_polynomial_Y]
  ring1
#align weierstrass_curve.slope_of_Y_ne_eq_eval WeierstrassCurve.slope_of_Y_ne_eq_eval

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.2556673791.map_simp -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.2556673791.map_simp -/
theorem baseChange_slope :
    (W.base_change K).slope (algebraMap F K x₁) (algebraMap F K x₂) (algebraMap F K y₁)
        (algebraMap F K y₂) =
      algebraMap F K (W.slope x₁ x₂ y₁ y₂) :=
  by
  by_cases hx : x₁ = x₂
  · by_cases hy : y₁ = W.neg_Y x₂ y₂
    · rw [slope_of_Y_eq hx hy, slope_of_Y_eq <| congr_arg _ hx, map_zero]
      · rw [hy, base_change_neg_Y]
    · rw [slope_of_Y_ne hx hy, slope_of_Y_ne <| congr_arg _ hx]
      · run_tac
          map_simp
        simpa only [base_change_neg_Y]
      · rw [base_change_neg_Y]
        contrapose! hy
        exact NoZeroSMulDivisors.algebraMap_injective F K hy
  · rw [slope_of_X_ne hx, slope_of_X_ne]
    ·
      run_tac
        map_simp
    · contrapose! hx
      exact NoZeroSMulDivisors.algebraMap_injective F K hx
#align weierstrass_curve.base_change_slope WeierstrassCurve.baseChange_slope

theorem baseChange_slope_of_baseChange {R : Type u} [CommRing R] (W : WeierstrassCurve R)
    (F : Type v) [Field F] [Algebra R F] (K : Type w) [Field K] [Algebra R K] [Algebra F K]
    [IsScalarTower R F K] (x₁ x₂ y₁ y₂ : F) :
    (W.base_change K).slope (algebraMap F K x₁) (algebraMap F K x₂) (algebraMap F K y₁)
        (algebraMap F K y₂) =
      algebraMap F K ((W.base_change F).slope x₁ x₂ y₁ y₂) :=
  by rw [← base_change_slope, base_change_base_change]
#align weierstrass_curve.base_change_slope_of_base_change WeierstrassCurve.baseChange_slope_of_baseChange

include h₁' h₂'

theorem Y_eq_of_X_eq (hx : x₁ = x₂) : y₁ = y₂ ∨ y₁ = W.negY x₂ y₂ :=
  by
  rw [equation_iff] at h₁' h₂'
  rw [← sub_eq_zero, ← @sub_eq_zero _ _ y₁, ← mul_eq_zero, neg_Y]
  linear_combination (norm := (rw [hx]; ring1)) h₁' - h₂'
#align weierstrass_curve.Y_eq_of_X_eq WeierstrassCurve.Y_eq_of_X_eq

theorem Y_eq_of_Y_ne (hx : x₁ = x₂) (hy : y₁ ≠ W.negY x₂ y₂) : y₁ = y₂ :=
  Or.resolve_right (Y_eq_of_X_eq h₁' h₂' hx) hy
#align weierstrass_curve.Y_eq_of_Y_ne WeierstrassCurve.Y_eq_of_Y_ne

theorem addPolynomial_slope (hxy : x₁ = x₂ → y₁ ≠ W.negY x₂ y₂) :
    W.addPolynomial x₁ y₁ (W.slope x₁ x₂ y₁ y₂) =
      -((X - C x₁) * (X - C x₂) * (X - C (W.addX x₁ x₂ <| W.slope x₁ x₂ y₁ y₂))) :=
  by
  rw [add_polynomial_eq, neg_inj, Cubic.prod_x_sub_c_eq, Cubic.toPoly_injective]
  by_cases hx : x₁ = x₂
  · rcases hx, Y_eq_of_Y_ne h₁' h₂' hx (hxy hx) with ⟨rfl, rfl⟩
    rw [equation_iff] at h₁' h₂'
    rw [slope_of_Y_ne rfl <| hxy rfl]
    rw [neg_Y, ← sub_ne_zero] at hxy
    ext
    · rfl
    · simp only [add_X]
      ring1
    · field_simp [hxy rfl]
      ring1
    · linear_combination (norm := (field_simp [hxy rfl] ; ring1)) -h₁'
  · rw [equation_iff] at h₁' h₂'
    rw [slope_of_X_ne hx]
    rw [← sub_eq_zero] at hx
    ext
    · rfl
    · simp only [add_X]
      ring1
    · apply mul_right_injective₀ hx
      linear_combination (norm := (field_simp [hx] ; ring1)) h₂' - h₁'
    · apply mul_right_injective₀ hx
      linear_combination (norm := (field_simp [hx] ; ring1)) x₂ * h₁' - x₁ * h₂'
#align weierstrass_curve.add_polynomial_slope WeierstrassCurve.addPolynomial_slope

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.150691367.derivative_simp -/
theorem derivative_addPolynomial_slope (hxy : x₁ = x₂ → y₁ ≠ W.negY x₂ y₂) :
    derivative (W.addPolynomial x₁ y₁ <| W.slope x₁ x₂ y₁ y₂) =
      -((X - C x₁) * (X - C x₂) + (X - C x₁) * (X - C (W.addX x₁ x₂ <| W.slope x₁ x₂ y₁ y₂)) +
          (X - C x₂) * (X - C (W.addX x₁ x₂ <| W.slope x₁ x₂ y₁ y₂))) :=
  by
  rw [add_polynomial_slope h₁' h₂' hxy]
  run_tac
    derivative_simp
  ring1
#align weierstrass_curve.derivative_add_polynomial_slope WeierstrassCurve.derivative_addPolynomial_slope

/-! ### The addition law on nonsingular rational points on a Weierstrass curve -/


/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.1038319287.eval_simp -/
/-- The addition of two affine points in `W` on a sloped line,
before applying the final negation that maps $Y$ to $-Y - a_1X - a_3$, lies in `W`. -/
theorem equation_add' (hxy : x₁ = x₂ → y₁ ≠ W.negY x₂ y₂) :
    W.Equation (W.addX x₁ x₂ <| W.slope x₁ x₂ y₁ y₂) (W.addY' x₁ x₂ y₁ <| W.slope x₁ x₂ y₁ y₂) :=
  by
  rw [equation_add_iff, add_polynomial_slope h₁' h₂' hxy]
  run_tac
    eval_simp
  rw [neg_eq_zero, sub_self, mul_zero]
#align weierstrass_curve.equation_add' WeierstrassCurve.equation_add'

/-- The addition of two affine points in `W` on a sloped line lies in `W`. -/
theorem equation_add (hxy : x₁ = x₂ → y₁ ≠ W.negY x₂ y₂) :
    W.Equation (W.addX x₁ x₂ <| W.slope x₁ x₂ y₁ y₂) (W.addY x₁ x₂ y₁ <| W.slope x₁ x₂ y₁ y₂) :=
  equation_neg <| equation_add' h₁' h₂' hxy
#align weierstrass_curve.equation_add WeierstrassCurve.equation_add

omit h₁' h₂'

include h₁ h₂

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic _private.1038319287.eval_simp -/
/-- The addition of two nonsingular affine points in `W` on a sloped line,
before applying the final negation that maps $Y$ to $-Y - a_1X - a_3$, is nonsingular. -/
theorem nonsingular_add' (hxy : x₁ = x₂ → y₁ ≠ W.negY x₂ y₂) :
    W.Nonsingular (W.addX x₁ x₂ <| W.slope x₁ x₂ y₁ y₂) (W.addY' x₁ x₂ y₁ <| W.slope x₁ x₂ y₁ y₂) :=
  by
  by_cases hx₁ : W.add_X x₁ x₂ (W.slope x₁ x₂ y₁ y₂) = x₁
  · rwa [add_Y', hx₁, sub_self, mul_zero, zero_add]
  · by_cases hx₂ : W.add_X x₁ x₂ (W.slope x₁ x₂ y₁ y₂) = x₂
    · by_cases hx : x₁ = x₂
      · subst hx
        contradiction
      ·
        rwa [add_Y', ← neg_sub, mul_neg, hx₂, slope_of_X_ne hx,
          div_mul_cancel _ <| sub_ne_zero_of_ne hx, neg_sub, sub_add_cancel]
    · apply W.nonsingular_add_of_eval_derivative_ne_zero _ _ _ _ (equation_add' h₁.1 h₂.1 hxy)
      rw [derivative_add_polynomial_slope h₁.left h₂.left hxy]
      run_tac
        eval_simp
      simpa only [neg_ne_zero, sub_self, mul_zero, add_zero] using
        mul_ne_zero (sub_ne_zero_of_ne hx₁) (sub_ne_zero_of_ne hx₂)
#align weierstrass_curve.nonsingular_add' WeierstrassCurve.nonsingular_add'

/-- The addition of two nonsingular affine points in `W` on a sloped line is nonsingular. -/
theorem nonsingular_add (hxy : x₁ = x₂ → y₁ ≠ W.negY x₂ y₂) :
    W.Nonsingular (W.addX x₁ x₂ <| W.slope x₁ x₂ y₁ y₂) (W.addY x₁ x₂ y₁ <| W.slope x₁ x₂ y₁ y₂) :=
  nonsingular_neg <| nonsingular_add' h₁ h₂ hxy
#align weierstrass_curve.nonsingular_add WeierstrassCurve.nonsingular_add

omit h₁ h₂

namespace Point

variable {h₁ h₂}

/-- The addition of two nonsingular rational points.

Given two nonsingular rational points `P` and `Q`, use `P + Q` instead of `add P Q`. -/
noncomputable def add : W.Point → W.Point → W.Point
  | 0, P => P
  | P, 0 => P
  | @some _ _ _ x₁ y₁ h₁, @some _ _ _ x₂ y₂ h₂ =>
    if hx : x₁ = x₂ then
      if hy : y₁ = W.negY x₂ y₂ then 0 else some <| nonsingular_add h₁ h₂ fun _ => hy
    else some <| nonsingular_add h₁ h₂ fun h => (hx h).elim
#align weierstrass_curve.point.add WeierstrassCurve.Point.add

noncomputable instance : Add W.Point :=
  ⟨add⟩

@[simp]
theorem add_def (P Q : W.Point) : P.add Q = P + Q :=
  rfl
#align weierstrass_curve.point.add_def WeierstrassCurve.Point.add_def

noncomputable instance : AddZeroClass W.Point :=
  ⟨0, (· + ·), by rintro (_ | _) <;> rfl, by rintro (_ | _) <;> rfl⟩

@[simp]
theorem some_add_some_of_Y_eq (hx : x₁ = x₂) (hy : y₁ = W.negY x₂ y₂) : some h₁ + some h₂ = 0 := by
  rw [← add_def, add, dif_pos hx, dif_pos hy]
#align weierstrass_curve.point.some_add_some_of_Y_eq WeierstrassCurve.Point.some_add_some_of_Y_eq

@[simp]
theorem some_add_self_of_Y_eq (hy : y₁ = W.negY x₁ y₁) : some h₁ + some h₁ = 0 :=
  some_add_some_of_Y_eq rfl hy
#align weierstrass_curve.point.some_add_self_of_Y_eq WeierstrassCurve.Point.some_add_self_of_Y_eq

@[simp]
theorem some_add_some_of_Y_ne (hx : x₁ = x₂) (hy : y₁ ≠ W.negY x₂ y₂) :
    some h₁ + some h₂ = some (nonsingular_add h₁ h₂ fun _ => hy) := by
  rw [← add_def, add, dif_pos hx, dif_neg hy]
#align weierstrass_curve.point.some_add_some_of_Y_ne WeierstrassCurve.Point.some_add_some_of_Y_ne

theorem some_add_some_of_Y_ne' (hx : x₁ = x₂) (hy : y₁ ≠ W.negY x₂ y₂) :
    some h₁ + some h₂ = -some (nonsingular_add' h₁ h₂ fun _ => hy) :=
  some_add_some_of_Y_ne hx hy
#align weierstrass_curve.point.some_add_some_of_Y_ne' WeierstrassCurve.Point.some_add_some_of_Y_ne'

@[simp]
theorem some_add_self_of_Y_ne (hy : y₁ ≠ W.negY x₁ y₁) :
    some h₁ + some h₁ = some (nonsingular_add h₁ h₁ fun _ => hy) :=
  some_add_some_of_Y_ne rfl hy
#align weierstrass_curve.point.some_add_self_of_Y_ne WeierstrassCurve.Point.some_add_self_of_Y_ne

theorem some_add_self_of_Y_ne' (hy : y₁ ≠ W.negY x₁ y₁) :
    some h₁ + some h₁ = -some (nonsingular_add' h₁ h₁ fun _ => hy) :=
  some_add_some_of_Y_ne rfl hy
#align weierstrass_curve.point.some_add_self_of_Y_ne' WeierstrassCurve.Point.some_add_self_of_Y_ne'

@[simp]
theorem some_add_some_of_X_ne (hx : x₁ ≠ x₂) :
    some h₁ + some h₂ = some (nonsingular_add h₁ h₂ fun h => (hx h).elim) := by
  rw [← add_def, add, dif_neg hx]
#align weierstrass_curve.point.some_add_some_of_X_ne WeierstrassCurve.Point.some_add_some_of_X_ne

theorem some_add_some_of_X_ne' (hx : x₁ ≠ x₂) :
    some h₁ + some h₂ = -some (nonsingular_add' h₁ h₂ fun h => (hx h).elim) :=
  some_add_some_of_X_ne hx
#align weierstrass_curve.point.some_add_some_of_X_ne' WeierstrassCurve.Point.some_add_some_of_X_ne'

end Point

end Addition

section Group

/-! ### The axioms for nonsingular rational points on a Weierstrass curve -/


variable {F : Type u} [Field F] {W : WeierstrassCurve F}

namespace Point

@[simp]
theorem add_eq_zero (P Q : W.Point) : P + Q = 0 ↔ P = -Q :=
  by
  rcases P, Q with ⟨_ | @⟨x₁, y₁, _⟩, _ | @⟨x₂, y₂, _⟩⟩
  any_goals rfl
  · rw [zero_def, zero_add, eq_neg_iff_eq_neg, neg_zero]
  · simp only [neg_some]
    constructor
    · intro h
      by_cases hx : x₁ = x₂
      · by_cases hy : y₁ = W.neg_Y x₂ y₂
        · exact ⟨hx, hy⟩
        · rw [some_add_some_of_Y_ne hx hy] at h
          contradiction
      · rw [some_add_some_of_X_ne hx] at h
        contradiction
    · exact fun ⟨hx, hy⟩ => some_add_some_of_Y_eq hx hy
#align weierstrass_curve.point.add_eq_zero WeierstrassCurve.Point.add_eq_zero

@[simp]
theorem add_left_neg (P : W.Point) : -P + P = 0 := by rw [add_eq_zero]
#align weierstrass_curve.point.add_left_neg WeierstrassCurve.Point.add_left_neg

@[simp]
theorem neg_add_eq_zero (P Q : W.Point) : -P + Q = 0 ↔ P = Q := by rw [add_eq_zero, neg_inj]
#align weierstrass_curve.point.neg_add_eq_zero WeierstrassCurve.Point.neg_add_eq_zero

end Point

end Group

section BaseChange

/-! ### Nonsingular rational points on a base changed Weierstrass curve -/


variable {R : Type u} [CommRing R] (W : WeierstrassCurve R) (F : Type v) [Field F] [Algebra R F]
  (K : Type w) [Field K] [Algebra R K] [Algebra F K] [IsScalarTower R F K]

namespace Point

open WeierstrassCurve

/- warning: weierstrass_curve.point.of_base_change_fun -> WeierstrassCurve.Point.ofBaseChangeFun is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : CommRing.{u1} R] (W : WeierstrassCurve.{u1} R) (F : Type.{u2}) [_inst_2 : Field.{u2} F] [_inst_3 : Algebra.{u1, u2} R F (CommRing.toCommSemiring.{u1} R _inst_1) (Ring.toSemiring.{u2} F (DivisionRing.toRing.{u2} F (Field.toDivisionRing.{u2} F _inst_2)))] (K : Type.{u3}) [_inst_4 : Field.{u3} K] [_inst_5 : Algebra.{u1, u3} R K (CommRing.toCommSemiring.{u1} R _inst_1) (Ring.toSemiring.{u3} K (DivisionRing.toRing.{u3} K (Field.toDivisionRing.{u3} K _inst_4)))] [_inst_6 : Algebra.{u2, u3} F K (Semifield.toCommSemiring.{u2} F (Field.toSemifield.{u2} F _inst_2)) (Ring.toSemiring.{u3} K (DivisionRing.toRing.{u3} K (Field.toDivisionRing.{u3} K _inst_4)))] [_inst_7 : IsScalarTower.{u1, u2, u3} R F K (SMulZeroClass.toHasSmul.{u1, u2} R F (AddZeroClass.toHasZero.{u2} F (AddMonoid.toAddZeroClass.{u2} F (AddCommMonoid.toAddMonoid.{u2} F (NonUnitalNonAssocSemiring.toAddCommMonoid.{u2} F (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} F (Semiring.toNonAssocSemiring.{u2} F (Ring.toSemiring.{u2} F (DivisionRing.toRing.{u2} F (Field.toDivisionRing.{u2} F _inst_2))))))))) (SMulWithZero.toSmulZeroClass.{u1, u2} R F (MulZeroClass.toHasZero.{u1} R (MulZeroOneClass.toMulZeroClass.{u1} R (MonoidWithZero.toMulZeroOneClass.{u1} R (Semiring.toMonoidWithZero.{u1} R (CommSemiring.toSemiring.{u1} R (CommRing.toCommSemiring.{u1} R _inst_1)))))) (AddZeroClass.toHasZero.{u2} F (AddMonoid.toAddZeroClass.{u2} F (AddCommMonoid.toAddMonoid.{u2} F (NonUnitalNonAssocSemiring.toAddCommMonoid.{u2} F (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} F (Semiring.toNonAssocSemiring.{u2} F (Ring.toSemiring.{u2} F (DivisionRing.toRing.{u2} F (Field.toDivisionRing.{u2} F _inst_2))))))))) (MulActionWithZero.toSMulWithZero.{u1, u2} R F (Semiring.toMonoidWithZero.{u1} R (CommSemiring.toSemiring.{u1} R (CommRing.toCommSemiring.{u1} R _inst_1))) (AddZeroClass.toHasZero.{u2} F (AddMonoid.toAddZeroClass.{u2} F (AddCommMonoid.toAddMonoid.{u2} F (NonUnitalNonAssocSemiring.toAddCommMonoid.{u2} F (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} F (Semiring.toNonAssocSemiring.{u2} F (Ring.toSemiring.{u2} F (DivisionRing.toRing.{u2} F (Field.toDivisionRing.{u2} F _inst_2))))))))) (Module.toMulActionWithZero.{u1, u2} R F (CommSemiring.toSemiring.{u1} R (CommRing.toCommSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u2} F (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} F (Semiring.toNonAssocSemiring.{u2} F (Ring.toSemiring.{u2} F (DivisionRing.toRing.{u2} F (Field.toDivisionRing.{u2} F _inst_2)))))) (Algebra.toModule.{u1, u2} R F (CommRing.toCommSemiring.{u1} R _inst_1) (Ring.toSemiring.{u2} F (DivisionRing.toRing.{u2} F (Field.toDivisionRing.{u2} F _inst_2))) _inst_3))))) (SMulZeroClass.toHasSmul.{u2, u3} F K (AddZeroClass.toHasZero.{u3} K (AddMonoid.toAddZeroClass.{u3} K (AddCommMonoid.toAddMonoid.{u3} K (NonUnitalNonAssocSemiring.toAddCommMonoid.{u3} K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u3} K (Semiring.toNonAssocSemiring.{u3} K (Ring.toSemiring.{u3} K (DivisionRing.toRing.{u3} K (Field.toDivisionRing.{u3} K _inst_4))))))))) (SMulWithZero.toSmulZeroClass.{u2, u3} F K (MulZeroClass.toHasZero.{u2} F (MulZeroOneClass.toMulZeroClass.{u2} F (MonoidWithZero.toMulZeroOneClass.{u2} F (Semiring.toMonoidWithZero.{u2} F (CommSemiring.toSemiring.{u2} F (Semifield.toCommSemiring.{u2} F (Field.toSemifield.{u2} F _inst_2))))))) (AddZeroClass.toHasZero.{u3} K (AddMonoid.toAddZeroClass.{u3} K (AddCommMonoid.toAddMonoid.{u3} K (NonUnitalNonAssocSemiring.toAddCommMonoid.{u3} K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u3} K (Semiring.toNonAssocSemiring.{u3} K (Ring.toSemiring.{u3} K (DivisionRing.toRing.{u3} K (Field.toDivisionRing.{u3} K _inst_4))))))))) (MulActionWithZero.toSMulWithZero.{u2, u3} F K (Semiring.toMonoidWithZero.{u2} F (CommSemiring.toSemiring.{u2} F (Semifield.toCommSemiring.{u2} F (Field.toSemifield.{u2} F _inst_2)))) (AddZeroClass.toHasZero.{u3} K (AddMonoid.toAddZeroClass.{u3} K (AddCommMonoid.toAddMonoid.{u3} K (NonUnitalNonAssocSemiring.toAddCommMonoid.{u3} K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u3} K (Semiring.toNonAssocSemiring.{u3} K (Ring.toSemiring.{u3} K (DivisionRing.toRing.{u3} K (Field.toDivisionRing.{u3} K _inst_4))))))))) (Module.toMulActionWithZero.{u2, u3} F K (CommSemiring.toSemiring.{u2} F (Semifield.toCommSemiring.{u2} F (Field.toSemifield.{u2} F _inst_2))) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u3} K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u3} K (Semiring.toNonAssocSemiring.{u3} K (Ring.toSemiring.{u3} K (DivisionRing.toRing.{u3} K (Field.toDivisionRing.{u3} K _inst_4)))))) (Algebra.toModule.{u2, u3} F K (Semifield.toCommSemiring.{u2} F (Field.toSemifield.{u2} F _inst_2)) (Ring.toSemiring.{u3} K (DivisionRing.toRing.{u3} K (Field.toDivisionRing.{u3} K _inst_4))) _inst_6))))) (SMulZeroClass.toHasSmul.{u1, u3} R K (AddZeroClass.toHasZero.{u3} K (AddMonoid.toAddZeroClass.{u3} K (AddCommMonoid.toAddMonoid.{u3} K (NonUnitalNonAssocSemiring.toAddCommMonoid.{u3} K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u3} K (Semiring.toNonAssocSemiring.{u3} K (Ring.toSemiring.{u3} K (DivisionRing.toRing.{u3} K (Field.toDivisionRing.{u3} K _inst_4))))))))) (SMulWithZero.toSmulZeroClass.{u1, u3} R K (MulZeroClass.toHasZero.{u1} R (MulZeroOneClass.toMulZeroClass.{u1} R (MonoidWithZero.toMulZeroOneClass.{u1} R (Semiring.toMonoidWithZero.{u1} R (CommSemiring.toSemiring.{u1} R (CommRing.toCommSemiring.{u1} R _inst_1)))))) (AddZeroClass.toHasZero.{u3} K (AddMonoid.toAddZeroClass.{u3} K (AddCommMonoid.toAddMonoid.{u3} K (NonUnitalNonAssocSemiring.toAddCommMonoid.{u3} K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u3} K (Semiring.toNonAssocSemiring.{u3} K (Ring.toSemiring.{u3} K (DivisionRing.toRing.{u3} K (Field.toDivisionRing.{u3} K _inst_4))))))))) (MulActionWithZero.toSMulWithZero.{u1, u3} R K (Semiring.toMonoidWithZero.{u1} R (CommSemiring.toSemiring.{u1} R (CommRing.toCommSemiring.{u1} R _inst_1))) (AddZeroClass.toHasZero.{u3} K (AddMonoid.toAddZeroClass.{u3} K (AddCommMonoid.toAddMonoid.{u3} K (NonUnitalNonAssocSemiring.toAddCommMonoid.{u3} K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u3} K (Semiring.toNonAssocSemiring.{u3} K (Ring.toSemiring.{u3} K (DivisionRing.toRing.{u3} K (Field.toDivisionRing.{u3} K _inst_4))))))))) (Module.toMulActionWithZero.{u1, u3} R K (CommSemiring.toSemiring.{u1} R (CommRing.toCommSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toAddCommMonoid.{u3} K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u3} K (Semiring.toNonAssocSemiring.{u3} K (Ring.toSemiring.{u3} K (DivisionRing.toRing.{u3} K (Field.toDivisionRing.{u3} K _inst_4)))))) (Algebra.toModule.{u1, u3} R K (CommRing.toCommSemiring.{u1} R _inst_1) (Ring.toSemiring.{u3} K (DivisionRing.toRing.{u3} K (Field.toDivisionRing.{u3} K _inst_4))) _inst_5)))))], (WeierstrassCurve.Point.{u2} F (EuclideanDomain.toCommRing.{u2} F (Field.toEuclideanDomain.{u2} F _inst_2)) (WeierstrassCurve.baseChange.{u1, u2} R _inst_1 W F (EuclideanDomain.toCommRing.{u2} F (Field.toEuclideanDomain.{u2} F _inst_2)) _inst_3)) -> (WeierstrassCurve.Point.{u3} K (EuclideanDomain.toCommRing.{u3} K (Field.toEuclideanDomain.{u3} K _inst_4)) (WeierstrassCurve.baseChange.{u1, u3} R _inst_1 W K (EuclideanDomain.toCommRing.{u3} K (Field.toEuclideanDomain.{u3} K _inst_4)) _inst_5))
but is expected to have type
  PUnit.{max (max (succ (succ u1)) (succ (succ u2))) (succ (succ u3))}
Case conversion may be inaccurate. Consider using '#align weierstrass_curve.point.of_base_change_fun WeierstrassCurve.Point.ofBaseChangeFunₓ'. -/
/-- The function from `W⟮F⟯` to `W⟮K⟯` induced by a base change from `F` to `K`. -/
def ofBaseChangeFun : W⟮F⟯ → W⟮K⟯
  | 0 => 0
  | some h => some <| (nonsingular_iff_baseChange_of_baseChange W F K _ _).mp h
#align weierstrass_curve.point.of_base_change_fun WeierstrassCurve.Point.ofBaseChangeFun

/-- The group homomorphism from `W⟮F⟯` to `W⟮K⟯` induced by a base change from `F` to `K`. -/
@[simps]
def ofBaseChange : W⟮F⟯ →+ W⟮K⟯
    where
  toFun := ofBaseChangeFun W F K
  map_zero' := rfl
  map_add' := by
    rintro (_ | @⟨x₁, y₁, _⟩) (_ | @⟨x₂, y₂, _⟩)
    any_goals rfl
    by_cases hx : x₁ = x₂
    · by_cases hy : y₁ = (W.base_change F).negY x₂ y₂
      · simp only [some_add_some_of_Y_eq hx hy, of_base_change_fun]
        rw [some_add_some_of_Y_eq <| congr_arg _ hx]
        · rw [hy, base_change_neg_Y_of_base_change]
      · simp only [some_add_some_of_Y_ne hx hy, of_base_change_fun]
        rw [some_add_some_of_Y_ne <| congr_arg _ hx]
        · simp only [base_change_add_X_of_base_change, base_change_add_Y_of_base_change,
            base_change_slope_of_base_change]
          exact ⟨rfl, rfl⟩
        · rw [base_change_neg_Y_of_base_change]
          contrapose! hy
          exact NoZeroSMulDivisors.algebraMap_injective F K hy
    · simp only [some_add_some_of_X_ne hx, of_base_change_fun]
      rw [some_add_some_of_X_ne]
      · simp only [base_change_add_X_of_base_change, base_change_add_Y_of_base_change,
          base_change_slope_of_base_change]
        exact ⟨rfl, rfl⟩
      · contrapose! hx
        exact NoZeroSMulDivisors.algebraMap_injective F K hx
#align weierstrass_curve.point.of_base_change WeierstrassCurve.Point.ofBaseChange

theorem ofBaseChange_injective : Function.Injective <| ofBaseChange W F K :=
  by
  rintro (_ | _) (_ | _) h
  · rfl
  any_goals contradiction
  simp only
  exact
    ⟨NoZeroSMulDivisors.algebraMap_injective F K (some.inj h).left,
      NoZeroSMulDivisors.algebraMap_injective F K (some.inj h).right⟩
#align weierstrass_curve.point.of_base_change_injective WeierstrassCurve.Point.ofBaseChange_injective

end Point

end BaseChange

end WeierstrassCurve

namespace EllipticCurve

/-! ### Rational points on an elliptic curve -/


namespace Point

variable {R : Type} [Nontrivial R] [CommRing R] (E : EllipticCurve R)

/-- An affine point on an elliptic curve `E` over `R`. -/
def mk {x y : R} (h : E.Equation x y) : E.Point :=
  WeierstrassCurve.Point.some <| E.Nonsingular h
#align elliptic_curve.point.mk EllipticCurve.Point.mk

end Point

end EllipticCurve

