/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.complex.unit_disc.basic
! leanprover-community/mathlib commit d012cd09a9b256d870751284dd6a29882b0be105
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Complex.Circle
import Mathbin.Analysis.NormedSpace.BallAction

/-!
# Poincaré disc

In this file we define `complex.unit_disc` to be the unit disc in the complex plane. We also
introduce some basic operations on this disc.
-/


open Set Function Metric

open BigOperators

noncomputable section

-- mathport name: exprconj'
local notation "conj'" => starRingEnd ℂ

namespace Complex

/- ./././Mathport/Syntax/Translate/Command.lean:42:9: unsupported derive handler λ α,
has_coe[has_coe] α exprℂ() -/
/-- Complex unit disc. -/
def UnitDisc : Type :=
  ball (0 : ℂ) 1deriving CommSemigroup, HasDistribNeg,
  «./././Mathport/Syntax/Translate/Command.lean:42:9: unsupported derive handler λ α,
  has_coe[has_coe] α exprℂ()», TopologicalSpace
#align complex.unit_disc Complex.UnitDisc

-- mathport name: expr𝔻
scoped[UnitDisc] notation "𝔻" => Complex.UnitDisc

namespace UnitDisc

theorem coe_injective : Injective (coe : 𝔻 → ℂ) :=
  Subtype.coe_injective
#align complex.unit_disc.coe_injective Complex.UnitDisc.coe_injective

theorem abs_lt_one (z : 𝔻) : abs (z : ℂ) < 1 :=
  mem_ball_zero_iff.1 z.2
#align complex.unit_disc.abs_lt_one Complex.UnitDisc.abs_lt_one

theorem abs_ne_one (z : 𝔻) : abs (z : ℂ) ≠ 1 :=
  z.abs_lt_one.Ne
#align complex.unit_disc.abs_ne_one Complex.UnitDisc.abs_ne_one

theorem norm_sq_lt_one (z : 𝔻) : normSq z < 1 :=
  @one_pow ℝ _ 2 ▸ (Real.sqrt_lt' one_pos).1 z.abs_lt_one
#align complex.unit_disc.norm_sq_lt_one Complex.UnitDisc.norm_sq_lt_one

theorem coe_ne_one (z : 𝔻) : (z : ℂ) ≠ 1 :=
  ne_of_apply_ne abs <| (map_one abs).symm ▸ z.abs_ne_one
#align complex.unit_disc.coe_ne_one Complex.UnitDisc.coe_ne_one

theorem coe_ne_neg_one (z : 𝔻) : (z : ℂ) ≠ -1 :=
  ne_of_apply_ne abs <| by 
    rw [abs.map_neg, map_one]
    exact z.abs_ne_one
#align complex.unit_disc.coe_ne_neg_one Complex.UnitDisc.coe_ne_neg_one

theorem one_add_coe_ne_zero (z : 𝔻) : (1 + z : ℂ) ≠ 0 :=
  mt neg_eq_iff_add_eq_zero.2 z.coe_ne_neg_one.symm
#align complex.unit_disc.one_add_coe_ne_zero Complex.UnitDisc.one_add_coe_ne_zero

@[simp, norm_cast]
theorem coe_mul (z w : 𝔻) : ↑(z * w) = (z * w : ℂ) :=
  rfl
#align complex.unit_disc.coe_mul Complex.UnitDisc.coe_mul

/-- A constructor that assumes `abs z < 1` instead of `dist z 0 < 1` and returns an element 
of `𝔻` instead of `↥metric.ball (0 : ℂ) 1`. -/
def mk (z : ℂ) (hz : abs z < 1) : 𝔻 :=
  ⟨z, mem_ball_zero_iff.2 hz⟩
#align complex.unit_disc.mk Complex.UnitDisc.mk

@[simp]
theorem coe_mk (z : ℂ) (hz : abs z < 1) : (mk z hz : ℂ) = z :=
  rfl
#align complex.unit_disc.coe_mk Complex.UnitDisc.coe_mk

@[simp]
theorem mk_coe (z : 𝔻) (hz : abs (z : ℂ) < 1 := z.abs_lt_one) : mk z hz = z :=
  Subtype.eta _ _
#align complex.unit_disc.mk_coe Complex.UnitDisc.mk_coe

@[simp]
theorem mk_neg (z : ℂ) (hz : abs (-z) < 1) : mk (-z) hz = -mk z (abs.map_neg z ▸ hz) :=
  rfl
#align complex.unit_disc.mk_neg Complex.UnitDisc.mk_neg

instance : SemigroupWithZero 𝔻 :=
  { UnitDisc.commSemigroup with
    zero := mk 0 <| (map_zero _).trans_lt one_pos
    zero_mul := fun z => coe_injective <| zero_mul _
    mul_zero := fun z => coe_injective <| mul_zero _ }

@[simp]
theorem coe_zero : ((0 : 𝔻) : ℂ) = 0 :=
  rfl
#align complex.unit_disc.coe_zero Complex.UnitDisc.coe_zero

@[simp]
theorem coe_eq_zero {z : 𝔻} : (z : ℂ) = 0 ↔ z = 0 :=
  coe_injective.eq_iff' coe_zero
#align complex.unit_disc.coe_eq_zero Complex.UnitDisc.coe_eq_zero

instance : Inhabited 𝔻 :=
  ⟨0⟩

instance circleAction : MulAction circle 𝔻 :=
  mulActionSphereBall
#align complex.unit_disc.circle_action Complex.UnitDisc.circleAction

instance is_scalar_tower_circle_circle : IsScalarTower circle circle 𝔻 :=
  is_scalar_tower_sphere_sphere_ball
#align
  complex.unit_disc.is_scalar_tower_circle_circle Complex.UnitDisc.is_scalar_tower_circle_circle

instance is_scalar_tower_circle : IsScalarTower circle 𝔻 𝔻 :=
  is_scalar_tower_sphere_ball_ball
#align complex.unit_disc.is_scalar_tower_circle Complex.UnitDisc.is_scalar_tower_circle

instance smul_comm_class_circle : SMulCommClass circle 𝔻 𝔻 :=
  smul_comm_class_sphere_ball_ball
#align complex.unit_disc.smul_comm_class_circle Complex.UnitDisc.smul_comm_class_circle

instance smul_comm_class_circle' : SMulCommClass 𝔻 circle 𝔻 :=
  SMulCommClass.symm _ _ _
#align complex.unit_disc.smul_comm_class_circle' Complex.UnitDisc.smul_comm_class_circle'

@[simp, norm_cast]
theorem coe_smul_circle (z : circle) (w : 𝔻) : ↑(z • w) = (z * w : ℂ) :=
  rfl
#align complex.unit_disc.coe_smul_circle Complex.UnitDisc.coe_smul_circle

instance closedBallAction : MulAction (closedBall (0 : ℂ) 1) 𝔻 :=
  mulActionClosedBallBall
#align complex.unit_disc.closed_ball_action Complex.UnitDisc.closedBallAction

instance is_scalar_tower_closed_ball_closed_ball :
    IsScalarTower (closedBall (0 : ℂ) 1) (closedBall (0 : ℂ) 1) 𝔻 :=
  is_scalar_tower_closed_ball_closed_ball_ball
#align
  complex.unit_disc.is_scalar_tower_closed_ball_closed_ball Complex.UnitDisc.is_scalar_tower_closed_ball_closed_ball

instance is_scalar_tower_closed_ball : IsScalarTower (closedBall (0 : ℂ) 1) 𝔻 𝔻 :=
  is_scalar_tower_closed_ball_ball_ball
#align complex.unit_disc.is_scalar_tower_closed_ball Complex.UnitDisc.is_scalar_tower_closed_ball

instance smul_comm_class_closed_ball : SMulCommClass (closedBall (0 : ℂ) 1) 𝔻 𝔻 :=
  ⟨fun a b c => Subtype.ext <| mul_left_comm _ _ _⟩
#align complex.unit_disc.smul_comm_class_closed_ball Complex.UnitDisc.smul_comm_class_closed_ball

instance smul_comm_class_closed_ball' : SMulCommClass 𝔻 (closedBall (0 : ℂ) 1) 𝔻 :=
  SMulCommClass.symm _ _ _
#align complex.unit_disc.smul_comm_class_closed_ball' Complex.UnitDisc.smul_comm_class_closed_ball'

instance smul_comm_class_circle_closed_ball : SMulCommClass circle (closedBall (0 : ℂ) 1) 𝔻 :=
  smul_comm_class_sphere_closed_ball_ball
#align
  complex.unit_disc.smul_comm_class_circle_closed_ball Complex.UnitDisc.smul_comm_class_circle_closed_ball

instance smul_comm_class_closed_ball_circle : SMulCommClass (closedBall (0 : ℂ) 1) circle 𝔻 :=
  SMulCommClass.symm _ _ _
#align
  complex.unit_disc.smul_comm_class_closed_ball_circle Complex.UnitDisc.smul_comm_class_closed_ball_circle

@[simp, norm_cast]
theorem coe_smul_closed_ball (z : closedBall (0 : ℂ) 1) (w : 𝔻) : ↑(z • w) = (z * w : ℂ) :=
  rfl
#align complex.unit_disc.coe_smul_closed_ball Complex.UnitDisc.coe_smul_closed_ball

/-- Real part of a point of the unit disc. -/
def re (z : 𝔻) : ℝ :=
  re z
#align complex.unit_disc.re Complex.UnitDisc.re

/-- Imaginary part of a point of the unit disc. -/
def im (z : 𝔻) : ℝ :=
  im z
#align complex.unit_disc.im Complex.UnitDisc.im

@[simp, norm_cast]
theorem re_coe (z : 𝔻) : (z : ℂ).re = z.re :=
  rfl
#align complex.unit_disc.re_coe Complex.UnitDisc.re_coe

@[simp, norm_cast]
theorem im_coe (z : 𝔻) : (z : ℂ).im = z.im :=
  rfl
#align complex.unit_disc.im_coe Complex.UnitDisc.im_coe

@[simp]
theorem re_neg (z : 𝔻) : (-z).re = -z.re :=
  rfl
#align complex.unit_disc.re_neg Complex.UnitDisc.re_neg

@[simp]
theorem im_neg (z : 𝔻) : (-z).im = -z.im :=
  rfl
#align complex.unit_disc.im_neg Complex.UnitDisc.im_neg

/-- Conjugate point of the unit disc. -/
def conj (z : 𝔻) : 𝔻 :=
  mk (conj' ↑z) <| (abs_conj z).symm ▸ z.abs_lt_one
#align complex.unit_disc.conj Complex.UnitDisc.conj

@[simp, norm_cast]
theorem coe_conj (z : 𝔻) : (z.conj : ℂ) = conj' ↑z :=
  rfl
#align complex.unit_disc.coe_conj Complex.UnitDisc.coe_conj

@[simp]
theorem conj_zero : conj 0 = 0 :=
  coe_injective (map_zero conj')
#align complex.unit_disc.conj_zero Complex.UnitDisc.conj_zero

@[simp]
theorem conj_conj (z : 𝔻) : conj (conj z) = z :=
  coe_injective <| Complex.conj_conj z
#align complex.unit_disc.conj_conj Complex.UnitDisc.conj_conj

@[simp]
theorem conj_neg (z : 𝔻) : (-z).conj = -z.conj :=
  rfl
#align complex.unit_disc.conj_neg Complex.UnitDisc.conj_neg

@[simp]
theorem re_conj (z : 𝔻) : z.conj.re = z.re :=
  rfl
#align complex.unit_disc.re_conj Complex.UnitDisc.re_conj

@[simp]
theorem im_conj (z : 𝔻) : z.conj.im = -z.im :=
  rfl
#align complex.unit_disc.im_conj Complex.UnitDisc.im_conj

@[simp]
theorem conj_mul (z w : 𝔻) : (z * w).conj = z.conj * w.conj :=
  Subtype.ext <| map_mul _ _ _
#align complex.unit_disc.conj_mul Complex.UnitDisc.conj_mul

end UnitDisc

end Complex

