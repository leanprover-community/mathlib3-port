/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module linear_algebra.affine_space.midpoint
! leanprover-community/mathlib commit d101e93197bb5f6ea89bd7ba386b7f7dff1f3903
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.CharP.Invertible
import Mathbin.LinearAlgebra.AffineSpace.AffineEquiv

/-!
# Midpoint of a segment

## Main definitions

* `midpoint R x y`: midpoint of the segment `[x, y]`. We define it for `x` and `y`
  in a module over a ring `R` with invertible `2`.
* `add_monoid_hom.of_map_midpoint`: construct an `add_monoid_hom` given a map `f` such that
  `f` sends zero to zero and midpoints to midpoints.

## Main theorems

* `midpoint_eq_iff`: `z` is the midpoint of `[x, y]` if and only if `x + y = z + z`,
* `midpoint_unique`: `midpoint R x y` does not depend on `R`;
* `midpoint x y` is linear both in `x` and `y`;
* `point_reflection_midpoint_left`, `point_reflection_midpoint_right`:
  `equiv.point_reflection (midpoint R x y)` swaps `x` and `y`.

We do not mark most lemmas as `@[simp]` because it is hard to tell which side is simpler.

## Tags

midpoint, add_monoid_hom
-/


open AffineMap AffineEquiv

section

variable (R : Type _) {V V' P P' : Type _} [Ring R] [Invertible (2 : R)] [AddCommGroup V]
  [Module R V] [AddTorsor V P] [AddCommGroup V'] [Module R V'] [AddTorsor V' P']

include V

/-- `midpoint x y` is the midpoint of the segment `[x, y]`. -/
def midpoint (x y : P) : P :=
  lineMap x y (⅟ 2 : R)
#align midpoint midpoint

variable {R} {x y z : P}

include V'

@[simp]
theorem AffineMap.map_midpoint (f : P →ᵃ[R] P') (a b : P) :
    f (midpoint R a b) = midpoint R (f a) (f b) :=
  f.apply_lineMap a b _
#align affine_map.map_midpoint AffineMap.map_midpoint

@[simp]
theorem AffineEquiv.map_midpoint (f : P ≃ᵃ[R] P') (a b : P) :
    f (midpoint R a b) = midpoint R (f a) (f b) :=
  f.apply_lineMap a b _
#align affine_equiv.map_midpoint AffineEquiv.map_midpoint

omit V'

@[simp]
theorem AffineEquiv.pointReflection_midpoint_left (x y : P) :
    pointReflection R (midpoint R x y) x = y := by
  rw [midpoint, point_reflection_apply, line_map_apply, vadd_vsub, vadd_vadd, ← add_smul, ← two_mul,
    mul_invOf_self, one_smul, vsub_vadd]
#align affine_equiv.point_reflection_midpoint_left AffineEquiv.pointReflection_midpoint_left

theorem midpoint_comm (x y : P) : midpoint R x y = midpoint R y x := by
  rw [midpoint, ← line_map_apply_one_sub, one_sub_invOf_two, midpoint]
#align midpoint_comm midpoint_comm

@[simp]
theorem AffineEquiv.pointReflection_midpoint_right (x y : P) :
    pointReflection R (midpoint R x y) y = x := by
  rw [midpoint_comm, AffineEquiv.pointReflection_midpoint_left]
#align affine_equiv.point_reflection_midpoint_right AffineEquiv.pointReflection_midpoint_right

theorem midpoint_vsub_midpoint (p₁ p₂ p₃ p₄ : P) :
    midpoint R p₁ p₂ -ᵥ midpoint R p₃ p₄ = midpoint R (p₁ -ᵥ p₃) (p₂ -ᵥ p₄) :=
  lineMap_vsub_lineMap _ _ _ _ _
#align midpoint_vsub_midpoint midpoint_vsub_midpoint

theorem midpoint_vadd_midpoint (v v' : V) (p p' : P) :
    midpoint R v v' +ᵥ midpoint R p p' = midpoint R (v +ᵥ p) (v' +ᵥ p') :=
  lineMap_vadd_lineMap _ _ _ _ _
#align midpoint_vadd_midpoint midpoint_vadd_midpoint

theorem midpoint_eq_iff {x y z : P} : midpoint R x y = z ↔ pointReflection R z x = y :=
  eq_comm.trans
    ((injective_pointReflection_left_of_module R x).eq_iff'
        (AffineEquiv.pointReflection_midpoint_left x y)).symm
#align midpoint_eq_iff midpoint_eq_iff

@[simp]
theorem midpoint_vsub_left (p₁ p₂ : P) : midpoint R p₁ p₂ -ᵥ p₁ = (⅟ 2 : R) • (p₂ -ᵥ p₁) :=
  lineMap_vsub_left _ _ _
#align midpoint_vsub_left midpoint_vsub_left

@[simp]
theorem midpoint_vsub_right (p₁ p₂ : P) : midpoint R p₁ p₂ -ᵥ p₂ = (⅟ 2 : R) • (p₁ -ᵥ p₂) := by
  rw [midpoint_comm, midpoint_vsub_left]
#align midpoint_vsub_right midpoint_vsub_right

@[simp]
theorem left_vsub_midpoint (p₁ p₂ : P) : p₁ -ᵥ midpoint R p₁ p₂ = (⅟ 2 : R) • (p₁ -ᵥ p₂) :=
  left_vsub_lineMap _ _ _
#align left_vsub_midpoint left_vsub_midpoint

@[simp]
theorem right_vsub_midpoint (p₁ p₂ : P) : p₂ -ᵥ midpoint R p₁ p₂ = (⅟ 2 : R) • (p₂ -ᵥ p₁) := by
  rw [midpoint_comm, left_vsub_midpoint]
#align right_vsub_midpoint right_vsub_midpoint

theorem midpoint_vsub (p₁ p₂ p : P) :
    midpoint R p₁ p₂ -ᵥ p = (⅟ 2 : R) • (p₁ -ᵥ p) + (⅟ 2 : R) • (p₂ -ᵥ p) := by
  rw [← vsub_sub_vsub_cancel_right p₁ p p₂, smul_sub, sub_eq_add_neg, ← smul_neg,
    neg_vsub_eq_vsub_rev, add_assoc, inv_of_two_smul_add_inv_of_two_smul, ← vadd_vsub_assoc,
    midpoint_comm, midpoint, line_map_apply]
#align midpoint_vsub midpoint_vsub

theorem vsub_midpoint (p₁ p₂ p : P) :
    p -ᵥ midpoint R p₁ p₂ = (⅟ 2 : R) • (p -ᵥ p₁) + (⅟ 2 : R) • (p -ᵥ p₂) := by
  rw [← neg_vsub_eq_vsub_rev, midpoint_vsub, neg_add, ← smul_neg, ← smul_neg, neg_vsub_eq_vsub_rev,
    neg_vsub_eq_vsub_rev]
#align vsub_midpoint vsub_midpoint

@[simp]
theorem midpoint_sub_left (v₁ v₂ : V) : midpoint R v₁ v₂ - v₁ = (⅟ 2 : R) • (v₂ - v₁) :=
  midpoint_vsub_left v₁ v₂
#align midpoint_sub_left midpoint_sub_left

@[simp]
theorem midpoint_sub_right (v₁ v₂ : V) : midpoint R v₁ v₂ - v₂ = (⅟ 2 : R) • (v₁ - v₂) :=
  midpoint_vsub_right v₁ v₂
#align midpoint_sub_right midpoint_sub_right

@[simp]
theorem left_sub_midpoint (v₁ v₂ : V) : v₁ - midpoint R v₁ v₂ = (⅟ 2 : R) • (v₁ - v₂) :=
  left_vsub_midpoint v₁ v₂
#align left_sub_midpoint left_sub_midpoint

@[simp]
theorem right_sub_midpoint (v₁ v₂ : V) : v₂ - midpoint R v₁ v₂ = (⅟ 2 : R) • (v₂ - v₁) :=
  right_vsub_midpoint v₁ v₂
#align right_sub_midpoint right_sub_midpoint

variable (R)

@[simp]
theorem midpoint_eq_left_iff {x y : P} : midpoint R x y = x ↔ x = y := by
  rw [midpoint_eq_iff, point_reflection_self]
#align midpoint_eq_left_iff midpoint_eq_left_iff

@[simp]
theorem left_eq_midpoint_iff {x y : P} : x = midpoint R x y ↔ x = y := by
  rw [eq_comm, midpoint_eq_left_iff]
#align left_eq_midpoint_iff left_eq_midpoint_iff

@[simp]
theorem midpoint_eq_right_iff {x y : P} : midpoint R x y = y ↔ x = y := by
  rw [midpoint_comm, midpoint_eq_left_iff, eq_comm]
#align midpoint_eq_right_iff midpoint_eq_right_iff

@[simp]
theorem right_eq_midpoint_iff {x y : P} : y = midpoint R x y ↔ x = y := by
  rw [eq_comm, midpoint_eq_right_iff]
#align right_eq_midpoint_iff right_eq_midpoint_iff

theorem midpoint_eq_midpoint_iff_vsub_eq_vsub {x x' y y' : P} :
    midpoint R x y = midpoint R x' y' ↔ x -ᵥ x' = y' -ᵥ y := by
  rw [← @vsub_eq_zero_iff_eq V, midpoint_vsub_midpoint, midpoint_eq_iff, point_reflection_apply,
    vsub_eq_sub, zero_sub, vadd_eq_add, add_zero, neg_eq_iff_neg_eq, neg_vsub_eq_vsub_rev, eq_comm]
#align midpoint_eq_midpoint_iff_vsub_eq_vsub midpoint_eq_midpoint_iff_vsub_eq_vsub

theorem midpoint_eq_iff' {x y z : P} : midpoint R x y = z ↔ Equiv.pointReflection z x = y :=
  midpoint_eq_iff
#align midpoint_eq_iff' midpoint_eq_iff'

/-- `midpoint` does not depend on the ring `R`. -/
theorem midpoint_unique (R' : Type _) [Ring R'] [Invertible (2 : R')] [Module R' V] (x y : P) :
    midpoint R x y = midpoint R' x y :=
  (midpoint_eq_iff' R).2 <| (midpoint_eq_iff' R').1 rfl
#align midpoint_unique midpoint_unique

@[simp]
theorem midpoint_self (x : P) : midpoint R x x = x :=
  lineMap_same_apply _ _
#align midpoint_self midpoint_self

@[simp]
theorem midpoint_add_self (x y : V) : midpoint R x y + midpoint R x y = x + y :=
  calc
    midpoint R x y +ᵥ midpoint R x y = midpoint R x y +ᵥ midpoint R y x := by rw [midpoint_comm]
    _ = x + y := by rw [midpoint_vadd_midpoint, vadd_eq_add, vadd_eq_add, add_comm, midpoint_self]
    
#align midpoint_add_self midpoint_add_self

theorem midpoint_zero_add (x y : V) : midpoint R 0 (x + y) = midpoint R x y :=
  (midpoint_eq_midpoint_iff_vsub_eq_vsub R).2 <| by simp [sub_add_eq_sub_sub_swap]
#align midpoint_zero_add midpoint_zero_add

theorem midpoint_eq_smul_add (x y : V) : midpoint R x y = (⅟ 2 : R) • (x + y) := by
  rw [midpoint_eq_iff, point_reflection_apply, vsub_eq_sub, vadd_eq_add, sub_add_eq_add_sub, ←
    two_smul R, smul_smul, mul_invOf_self, one_smul, add_sub_cancel']
#align midpoint_eq_smul_add midpoint_eq_smul_add

@[simp]
theorem midpoint_self_neg (x : V) : midpoint R x (-x) = 0 := by
  rw [midpoint_eq_smul_add, add_neg_self, smul_zero]
#align midpoint_self_neg midpoint_self_neg

@[simp]
theorem midpoint_neg_self (x : V) : midpoint R (-x) x = 0 := by simpa using midpoint_self_neg R (-x)
#align midpoint_neg_self midpoint_neg_self

@[simp]
theorem midpoint_sub_add (x y : V) : midpoint R (x - y) (x + y) = x := by
  rw [sub_eq_add_neg, ← vadd_eq_add, ← vadd_eq_add, ← midpoint_vadd_midpoint] <;> simp
#align midpoint_sub_add midpoint_sub_add

@[simp]
theorem midpoint_add_sub (x y : V) : midpoint R (x + y) (x - y) = x := by
  rw [midpoint_comm] <;> simp
#align midpoint_add_sub midpoint_add_sub

end

theorem lineMap_inv_two {R : Type _} {V P : Type _} [DivisionRing R] [CharZero R] [AddCommGroup V]
    [Module R V] [AddTorsor V P] (a b : P) : lineMap a b (2⁻¹ : R) = midpoint R a b :=
  rfl
#align line_map_inv_two lineMap_inv_two

theorem lineMap_one_half {R : Type _} {V P : Type _} [DivisionRing R] [CharZero R] [AddCommGroup V]
    [Module R V] [AddTorsor V P] (a b : P) : lineMap a b (1 / 2 : R) = midpoint R a b := by
  rw [one_div, lineMap_inv_two]
#align line_map_one_half lineMap_one_half

theorem homothety_invOf_two {R : Type _} {V P : Type _} [CommRing R] [Invertible (2 : R)]
    [AddCommGroup V] [Module R V] [AddTorsor V P] (a b : P) :
    homothety a (⅟ 2 : R) b = midpoint R a b :=
  rfl
#align homothety_inv_of_two homothety_invOf_two

theorem homothety_inv_two {k : Type _} {V P : Type _} [Field k] [CharZero k] [AddCommGroup V]
    [Module k V] [AddTorsor V P] (a b : P) : homothety a (2⁻¹ : k) b = midpoint k a b :=
  rfl
#align homothety_inv_two homothety_inv_two

theorem homothety_one_half {k : Type _} {V P : Type _} [Field k] [CharZero k] [AddCommGroup V]
    [Module k V] [AddTorsor V P] (a b : P) : homothety a (1 / 2 : k) b = midpoint k a b := by
  rw [one_div, homothety_inv_two]
#align homothety_one_half homothety_one_half

@[simp]
theorem pi_midpoint_apply {k ι : Type _} {V : ∀ i : ι, Type _} {P : ∀ i : ι, Type _} [Field k]
    [Invertible (2 : k)] [∀ i, AddCommGroup (V i)] [∀ i, Module k (V i)]
    [∀ i, AddTorsor (V i) (P i)] (f g : ∀ i, P i) (i : ι) :
    midpoint k f g i = midpoint k (f i) (g i) :=
  rfl
#align pi_midpoint_apply pi_midpoint_apply

namespace AddMonoidHom

variable (R R' : Type _) {E F : Type _} [Ring R] [Invertible (2 : R)] [AddCommGroup E] [Module R E]
  [Ring R'] [Invertible (2 : R')] [AddCommGroup F] [Module R' F]

/-- A map `f : E → F` sending zero to zero and midpoints to midpoints is an `add_monoid_hom`. -/
def ofMapMidpoint (f : E → F) (h0 : f 0 = 0)
    (hm : ∀ x y, f (midpoint R x y) = midpoint R' (f x) (f y)) : E →+ F
    where
  toFun := f
  map_zero' := h0
  map_add' x y :=
    calc
      f (x + y) = f 0 + f (x + y) := by rw [h0, zero_add]
      _ = midpoint R' (f 0) (f (x + y)) + midpoint R' (f 0) (f (x + y)) :=
        (midpoint_add_self _ _ _).symm
      _ = f (midpoint R x y) + f (midpoint R x y) := by rw [← hm, midpoint_zero_add]
      _ = f x + f y := by rw [hm, midpoint_add_self]
      
#align add_monoid_hom.of_map_midpoint AddMonoidHom.ofMapMidpoint

@[simp]
theorem coe_ofMapMidpoint (f : E → F) (h0 : f 0 = 0)
    (hm : ∀ x y, f (midpoint R x y) = midpoint R' (f x) (f y)) :
    ⇑(ofMapMidpoint R R' f h0 hm) = f :=
  rfl
#align add_monoid_hom.coe_of_map_midpoint AddMonoidHom.coe_ofMapMidpoint

end AddMonoidHom

