/-
Copyright (c) 2020 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anne Baanen, Kexing Ying, Eric Wieser

! This file was ported from Lean 3 source module linear_algebra.quadratic_form.basic
! leanprover-community/mathlib commit d012cd09a9b256d870751284dd6a29882b0be105
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Invertible
import Mathbin.LinearAlgebra.Matrix.Determinant
import Mathbin.LinearAlgebra.Matrix.BilinearForm
import Mathbin.LinearAlgebra.Matrix.Symmetric

/-!
# Quadratic forms

This file defines quadratic forms over a `R`-module `M`.
A quadratic form on a ring `R` is a map `Q : M → R` such that:
* `quadratic_form.map_smul`: `Q (a • x) = a * a * Q x`
* `quadratic_form.polar_add_left`, `quadratic_form.polar_add_right`,
  `quadratic_form.polar_smul_left`, `quadratic_form.polar_smul_right`:
  the map `quadratic_form.polar Q := λ x y, Q (x + y) - Q x - Q y` is bilinear.

This notion generalizes to semirings using the approach in [izhakian2016][] which requires that
there be a (possibly non-unique) companion bilinear form `B` such that
`∀ x y, Q (x + y) = Q x + Q y + B x y`. Over a ring, this `B` is precisely `quadratic_form.polar Q`.

To build a `quadratic_form` from the `polar` axioms, use `quadratic_form.of_polar`.

Quadratic forms come with a scalar multiplication, `(a • Q) x = Q (a • x) = a * a * Q x`,
and composition with linear maps `f`, `Q.comp f x = Q (f x)`.

## Main definitions

 * `quadratic_form.of_polar`: a more familiar constructor that works on rings
 * `quadratic_form.associated`: associated bilinear form
 * `quadratic_form.pos_def`: positive definite quadratic forms
 * `quadratic_form.anisotropic`: anisotropic quadratic forms
 * `quadratic_form.discr`: discriminant of a quadratic form

## Main statements

 * `quadratic_form.associated_left_inverse`,
 * `quadratic_form.associated_right_inverse`: in a commutative ring where 2 has
  an inverse, there is a correspondence between quadratic forms and symmetric
  bilinear forms
 * `bilin_form.exists_orthogonal_basis`: There exists an orthogonal basis with
  respect to any nondegenerate, symmetric bilinear form `B`.

## Notation

In this file, the variable `R` is used when a `ring` structure is sufficient and
`R₁` is used when specifically a `comm_ring` is required. This allows us to keep
`[module R M]` and `[module R₁ M]` assumptions in the variables without
confusion between `*` from `ring` and `*` from `comm_ring`.

The variable `S` is used when `R` itself has a `•` action.

## References

 * https://en.wikipedia.org/wiki/Quadratic_form
 * https://en.wikipedia.org/wiki/Discriminant#Quadratic_forms

## Tags

quadratic form, homogeneous polynomial, quadratic polynomial
-/


universe u v w

variable {S : Type _}

variable {R R₁ : Type _} {M : Type _}

open BigOperators

section Polar

variable [Ring R] [CommRing R₁] [AddCommGroup M]

namespace QuadraticForm

/-- Up to a factor 2, `Q.polar` is the associated bilinear form for a quadratic form `Q`.

Source of this name: https://en.wikipedia.org/wiki/Quadratic_form#Generalization
-/
def polar (f : M → R) (x y : M) :=
  f (x + y) - f x - f y
#align quadratic_form.polar QuadraticForm.polar

theorem polar_add (f g : M → R) (x y : M) : polar (f + g) x y = polar f x y + polar g x y := by
  simp only [polar, Pi.add_apply]
  abel
#align quadratic_form.polar_add QuadraticForm.polar_add

theorem polar_neg (f : M → R) (x y : M) : polar (-f) x y = -polar f x y := by
  simp only [polar, Pi.neg_apply, sub_eq_add_neg, neg_add]
#align quadratic_form.polar_neg QuadraticForm.polar_neg

theorem polar_smul [Monoid S] [DistribMulAction S R] (f : M → R) (s : S) (x y : M) :
    polar (s • f) x y = s • polar f x y := by simp only [polar, Pi.smul_apply, smul_sub]
#align quadratic_form.polar_smul QuadraticForm.polar_smul

theorem polar_comm (f : M → R) (x y : M) : polar f x y = polar f y x := by
  rw [polar, polar, add_comm, sub_sub, sub_sub, add_comm (f x) (f y)]
#align quadratic_form.polar_comm QuadraticForm.polar_comm

/-- Auxiliary lemma to express bilinearity of `quadratic_form.polar` without subtraction. -/
theorem polar_add_left_iff {f : M → R} {x x' y : M} :
    polar f (x + x') y = polar f x y + polar f x' y ↔
      f (x + x' + y) + (f x + f x' + f y) = f (x + x') + f (x' + y) + f (y + x) :=
  by 
  simp only [← add_assoc]
  simp only [polar, sub_eq_iff_eq_add, eq_sub_iff_add_eq, sub_add_eq_add_sub, add_sub]
  simp only [add_right_comm _ (f y) _, add_right_comm _ (f x') (f x)]
  rw [add_comm y x, add_right_comm _ _ (f (x + y)), add_comm _ (f (x + y)),
    add_right_comm (f (x + y)), add_left_inj]
#align quadratic_form.polar_add_left_iff QuadraticForm.polar_add_left_iff

theorem polar_comp {F : Type _} [Ring S] [AddMonoidHomClass F R S] (f : M → R) (g : F) (x y : M) :
    polar (g ∘ f) x y = g (polar f x y) := by
  simp only [polar, Pi.smul_apply, Function.comp_apply, map_sub]
#align quadratic_form.polar_comp QuadraticForm.polar_comp

end QuadraticForm

end Polar

/-- A quadratic form over a module.

For a more familiar constructor when `R` is a ring, see `quadratic_form.of_polar`. -/
structure QuadraticForm (R : Type u) (M : Type v) [Semiring R] [AddCommMonoid M] [Module R M] where
  toFun : M → R
  to_fun_smul : ∀ (a : R) (x : M), to_fun (a • x) = a * a * to_fun x
  exists_companion' : ∃ B : BilinForm R M, ∀ x y, to_fun (x + y) = to_fun x + to_fun y + B x y
#align quadratic_form QuadraticForm

namespace QuadraticForm

section FunLike

variable [Semiring R] [AddCommMonoid M] [Module R M]

variable {Q Q' : QuadraticForm R M}

instance funLike :
    FunLike (QuadraticForm R M) M fun _ =>
      R where 
  coe := toFun
  coe_injective' x y h := by cases x <;> cases y <;> congr
#align quadratic_form.fun_like QuadraticForm.funLike

/-- Helper instance for when there's too many metavariables to apply
`fun_like.has_coe_to_fun` directly. -/
instance : CoeFun (QuadraticForm R M) fun _ => M → R :=
  ⟨toFun⟩

variable (Q)

/-- The `simp` normal form for a quadratic form is `coe_fn`, not `to_fun`. -/
@[simp]
theorem to_fun_eq_coe : Q.toFun = ⇑Q :=
  rfl
#align quadratic_form.to_fun_eq_coe QuadraticForm.to_fun_eq_coe

-- this must come after the coe_to_fun definition
initialize_simps_projections QuadraticForm (toFun → apply)

variable {Q}

@[ext]
theorem ext (H : ∀ x : M, Q x = Q' x) : Q = Q' :=
  FunLike.ext _ _ H
#align quadratic_form.ext QuadraticForm.ext

theorem congr_fun (h : Q = Q') (x : M) : Q x = Q' x :=
  FunLike.congr_fun h _
#align quadratic_form.congr_fun QuadraticForm.congr_fun

theorem ext_iff : Q = Q' ↔ ∀ x, Q x = Q' x :=
  FunLike.ext_iff
#align quadratic_form.ext_iff QuadraticForm.ext_iff

/-- Copy of a `quadratic_form` with a new `to_fun` equal to the old one. Useful to fix definitional
equalities. -/
protected def copy (Q : QuadraticForm R M) (Q' : M → R) (h : Q' = ⇑Q) :
    QuadraticForm R M where 
  toFun := Q'
  to_fun_smul := h.symm ▸ Q.to_fun_smul
  exists_companion' := h.symm ▸ Q.exists_companion'
#align quadratic_form.copy QuadraticForm.copy

@[simp]
theorem coe_copy (Q : QuadraticForm R M) (Q' : M → R) (h : Q' = ⇑Q) : ⇑(Q.copy Q' h) = Q' :=
  rfl
#align quadratic_form.coe_copy QuadraticForm.coe_copy

theorem copy_eq (Q : QuadraticForm R M) (Q' : M → R) (h : Q' = ⇑Q) : Q.copy Q' h = Q :=
  FunLike.ext' h
#align quadratic_form.copy_eq QuadraticForm.copy_eq

end FunLike

section Semiring

variable [Semiring R] [AddCommMonoid M] [Module R M]

variable (Q : QuadraticForm R M)

theorem map_smul (a : R) (x : M) : Q (a • x) = a * a * Q x :=
  Q.to_fun_smul a x
#align quadratic_form.map_smul QuadraticForm.map_smul

theorem exists_companion : ∃ B : BilinForm R M, ∀ x y, Q (x + y) = Q x + Q y + B x y :=
  Q.exists_companion'
#align quadratic_form.exists_companion QuadraticForm.exists_companion

theorem map_add_add_add_map (x y z : M) :
    Q (x + y + z) + (Q x + Q y + Q z) = Q (x + y) + Q (y + z) + Q (z + x) := by
  obtain ⟨B, h⟩ := Q.exists_companion
  rw [add_comm z x]
  simp [h]
  abel
#align quadratic_form.map_add_add_add_map QuadraticForm.map_add_add_add_map

theorem map_add_self (x : M) : Q (x + x) = 4 * Q x := by
  rw [← one_smul R x, ← add_smul, map_smul]
  norm_num
#align quadratic_form.map_add_self QuadraticForm.map_add_self

@[simp]
theorem map_zero : Q 0 = 0 := by rw [← @zero_smul R _ _ _ _ (0 : M), map_smul, zero_mul, zero_mul]
#align quadratic_form.map_zero QuadraticForm.map_zero

instance zeroHomClass : ZeroHomClass (QuadraticForm R M) M R :=
  { QuadraticForm.funLike with map_zero := map_zero }
#align quadratic_form.zero_hom_class QuadraticForm.zeroHomClass

theorem map_smul_of_tower [CommSemiring S] [Algebra S R] [Module S M] [IsScalarTower S R M] (a : S)
    (x : M) : Q (a • x) = (a * a) • Q x := by
  rw [← IsScalarTower.algebra_map_smul R a x, map_smul, ← RingHom.map_mul, Algebra.smul_def]
#align quadratic_form.map_smul_of_tower QuadraticForm.map_smul_of_tower

end Semiring

section Ring

variable [Ring R] [CommRing R₁] [AddCommGroup M]

variable [Module R M] (Q : QuadraticForm R M)

@[simp]
theorem map_neg (x : M) : Q (-x) = Q x := by
  rw [← @neg_one_smul R _ _ _ _ x, map_smul, neg_one_mul, neg_neg, one_mul]
#align quadratic_form.map_neg QuadraticForm.map_neg

theorem map_sub (x y : M) : Q (x - y) = Q (y - x) := by rw [← neg_sub, map_neg]
#align quadratic_form.map_sub QuadraticForm.map_sub

@[simp]
theorem polar_zero_left (y : M) : polar Q 0 y = 0 := by
  simp only [polar, zero_add, QuadraticForm.map_zero, sub_zero, sub_self]
#align quadratic_form.polar_zero_left QuadraticForm.polar_zero_left

@[simp]
theorem polar_add_left (x x' y : M) : polar Q (x + x') y = polar Q x y + polar Q x' y :=
  polar_add_left_iff.mpr <| Q.map_add_add_add_map x x' y
#align quadratic_form.polar_add_left QuadraticForm.polar_add_left

@[simp]
theorem polar_smul_left (a : R) (x y : M) : polar Q (a • x) y = a * polar Q x y := by
  obtain ⟨B, h⟩ := Q.exists_companion
  simp_rw [polar, h, Q.map_smul, BilinForm.smul_left, sub_sub, add_sub_cancel']
#align quadratic_form.polar_smul_left QuadraticForm.polar_smul_left

@[simp]
theorem polar_neg_left (x y : M) : polar Q (-x) y = -polar Q x y := by
  rw [← neg_one_smul R x, polar_smul_left, neg_one_mul]
#align quadratic_form.polar_neg_left QuadraticForm.polar_neg_left

@[simp]
theorem polar_sub_left (x x' y : M) : polar Q (x - x') y = polar Q x y - polar Q x' y := by
  rw [sub_eq_add_neg, sub_eq_add_neg, polar_add_left, polar_neg_left]
#align quadratic_form.polar_sub_left QuadraticForm.polar_sub_left

@[simp]
theorem polar_zero_right (y : M) : polar Q y 0 = 0 := by
  simp only [add_zero, polar, QuadraticForm.map_zero, sub_self]
#align quadratic_form.polar_zero_right QuadraticForm.polar_zero_right

@[simp]
theorem polar_add_right (x y y' : M) : polar Q x (y + y') = polar Q x y + polar Q x y' := by
  rw [polar_comm Q x, polar_comm Q x, polar_comm Q x, polar_add_left]
#align quadratic_form.polar_add_right QuadraticForm.polar_add_right

@[simp]
theorem polar_smul_right (a : R) (x y : M) : polar Q x (a • y) = a * polar Q x y := by
  rw [polar_comm Q x, polar_comm Q x, polar_smul_left]
#align quadratic_form.polar_smul_right QuadraticForm.polar_smul_right

@[simp]
theorem polar_neg_right (x y : M) : polar Q x (-y) = -polar Q x y := by
  rw [← neg_one_smul R y, polar_smul_right, neg_one_mul]
#align quadratic_form.polar_neg_right QuadraticForm.polar_neg_right

@[simp]
theorem polar_sub_right (x y y' : M) : polar Q x (y - y') = polar Q x y - polar Q x y' := by
  rw [sub_eq_add_neg, sub_eq_add_neg, polar_add_right, polar_neg_right]
#align quadratic_form.polar_sub_right QuadraticForm.polar_sub_right

@[simp]
theorem polar_self (x : M) : polar Q x x = 2 * Q x := by
  rw [polar, map_add_self, sub_sub, sub_eq_iff_eq_add, ← two_mul, ← two_mul, ← mul_assoc]
  norm_num
#align quadratic_form.polar_self QuadraticForm.polar_self

/-- `quadratic_form.polar` as a bilinear form -/
@[simps]
def polarBilin : BilinForm R M where 
  bilin := polar Q
  bilin_add_left := polar_add_left Q
  bilin_smul_left := polar_smul_left Q
  bilin_add_right x y z := by simp_rw [polar_comm _ x, polar_add_left Q]
  bilin_smul_right r x y := by simp_rw [polar_comm _ x, polar_smul_left Q]
#align quadratic_form.polar_bilin QuadraticForm.polarBilin

variable [CommSemiring S] [Algebra S R] [Module S M] [IsScalarTower S R M]

@[simp]
theorem polar_smul_left_of_tower (a : S) (x y : M) : polar Q (a • x) y = a • polar Q x y := by
  rw [← IsScalarTower.algebra_map_smul R a x, polar_smul_left, Algebra.smul_def]
#align quadratic_form.polar_smul_left_of_tower QuadraticForm.polar_smul_left_of_tower

@[simp]
theorem polar_smul_right_of_tower (a : S) (x y : M) : polar Q x (a • y) = a • polar Q x y := by
  rw [← IsScalarTower.algebra_map_smul R a y, polar_smul_right, Algebra.smul_def]
#align quadratic_form.polar_smul_right_of_tower QuadraticForm.polar_smul_right_of_tower

/-- An alternative constructor to `quadratic_form.mk`, for rings where `polar` can be used. -/
@[simps]
def ofPolar (to_fun : M → R) (to_fun_smul : ∀ (a : R) (x : M), to_fun (a • x) = a * a * to_fun x)
    (polar_add_left : ∀ x x' y : M, polar to_fun (x + x') y = polar to_fun x y + polar to_fun x' y)
    (polar_smul_left : ∀ (a : R) (x y : M), polar to_fun (a • x) y = a • polar to_fun x y) :
    QuadraticForm R M :=
  { toFun
    to_fun_smul
    exists_companion' :=
      ⟨{  bilin := polar to_fun
          bilin_add_left := polar_add_left
          bilin_smul_left := polar_smul_left
          bilin_add_right := fun x y z => by simp_rw [polar_comm _ x, polar_add_left]
          bilin_smul_right := fun r x y => by
            simp_rw [polar_comm _ x, polar_smul_left, smul_eq_mul] },
        fun x y => by rw [BilinForm.coe_fn_mk, polar, sub_sub, add_sub_cancel'_right]⟩ }
#align quadratic_form.of_polar QuadraticForm.ofPolar

/-- In a ring the companion bilinear form is unique and equal to `quadratic_form.polar`. -/
theorem some_exists_companion : Q.exists_companion.some = polarBilin Q :=
  BilinForm.ext fun x y => by
    rw [polar_bilin_apply, polar, Q.exists_companion.some_spec, sub_sub, add_sub_cancel']
#align quadratic_form.some_exists_companion QuadraticForm.some_exists_companion

end Ring

section SemiringOperators

variable [Semiring R] [AddCommMonoid M] [Module R M]

section HasSmul

variable [Monoid S] [DistribMulAction S R] [SMulCommClass S R R]

/-- `quadratic_form R M` inherits the scalar action from any algebra over `R`.

When `R` is commutative, this provides an `R`-action via `algebra.id`. -/
instance : HasSmul S (QuadraticForm R M) :=
  ⟨fun a Q =>
    { toFun := a • Q
      to_fun_smul := fun b x => by rw [Pi.smul_apply, map_smul, Pi.smul_apply, mul_smul_comm]
      exists_companion' :=
        let ⟨B, h⟩ := Q.exists_companion
        ⟨a • B, by simp [h]⟩ }⟩

@[simp]
theorem coe_fn_smul (a : S) (Q : QuadraticForm R M) : ⇑(a • Q) = a • Q :=
  rfl
#align quadratic_form.coe_fn_smul QuadraticForm.coe_fn_smul

@[simp]
theorem smul_apply (a : S) (Q : QuadraticForm R M) (x : M) : (a • Q) x = a • Q x :=
  rfl
#align quadratic_form.smul_apply QuadraticForm.smul_apply

end HasSmul

instance : Zero (QuadraticForm R M) :=
  ⟨{  toFun := fun x => 0
      to_fun_smul := fun a x => by simp only [mul_zero]
      exists_companion' := ⟨0, fun x y => by simp only [add_zero, BilinForm.zero_apply]⟩ }⟩

@[simp]
theorem coe_fn_zero : ⇑(0 : QuadraticForm R M) = 0 :=
  rfl
#align quadratic_form.coe_fn_zero QuadraticForm.coe_fn_zero

@[simp]
theorem zero_apply (x : M) : (0 : QuadraticForm R M) x = 0 :=
  rfl
#align quadratic_form.zero_apply QuadraticForm.zero_apply

instance : Inhabited (QuadraticForm R M) :=
  ⟨0⟩

instance : Add (QuadraticForm R M) :=
  ⟨fun Q Q' =>
    { toFun := Q + Q'
      to_fun_smul := fun a x => by simp only [Pi.add_apply, map_smul, mul_add]
      exists_companion' :=
        let ⟨B, h⟩ := Q.exists_companion
        let ⟨B', h'⟩ := Q'.exists_companion
        ⟨B + B', fun x y => by
          simp_rw [Pi.add_apply, h, h', BilinForm.add_apply, add_add_add_comm]⟩ }⟩

@[simp]
theorem coe_fn_add (Q Q' : QuadraticForm R M) : ⇑(Q + Q') = Q + Q' :=
  rfl
#align quadratic_form.coe_fn_add QuadraticForm.coe_fn_add

@[simp]
theorem add_apply (Q Q' : QuadraticForm R M) (x : M) : (Q + Q') x = Q x + Q' x :=
  rfl
#align quadratic_form.add_apply QuadraticForm.add_apply

instance : AddCommMonoid (QuadraticForm R M) :=
  FunLike.coe_injective.AddCommMonoid _ coe_fn_zero coe_fn_add fun _ _ => coe_fn_smul _ _

/-- `@coe_fn (quadratic_form R M)` as an `add_monoid_hom`.

This API mirrors `add_monoid_hom.coe_fn`. -/
@[simps apply]
def coeFnAddMonoidHom : QuadraticForm R M →+
      M → R where 
  toFun := coeFn
  map_zero' := coe_fn_zero
  map_add' := coe_fn_add
#align quadratic_form.coe_fn_add_monoid_hom QuadraticForm.coeFnAddMonoidHom

/-- Evaluation on a particular element of the module `M` is an additive map over quadratic forms. -/
@[simps apply]
def evalAddMonoidHom (m : M) : QuadraticForm R M →+ R :=
  (Pi.evalAddMonoidHom _ m).comp coeFnAddMonoidHom
#align quadratic_form.eval_add_monoid_hom QuadraticForm.evalAddMonoidHom

section Sum

@[simp]
theorem coe_fn_sum {ι : Type _} (Q : ι → QuadraticForm R M) (s : Finset ι) :
    ⇑(∑ i in s, Q i) = ∑ i in s, Q i :=
  (coeFnAddMonoidHom : _ →+ M → R).map_sum Q s
#align quadratic_form.coe_fn_sum QuadraticForm.coe_fn_sum

@[simp]
theorem sum_apply {ι : Type _} (Q : ι → QuadraticForm R M) (s : Finset ι) (x : M) :
    (∑ i in s, Q i) x = ∑ i in s, Q i x :=
  (evalAddMonoidHom x : _ →+ R).map_sum Q s
#align quadratic_form.sum_apply QuadraticForm.sum_apply

end Sum

instance [Monoid S] [DistribMulAction S R] [SMulCommClass S R R] :
    DistribMulAction S
      (QuadraticForm R
        M) where 
  mul_smul a b Q := ext fun x => by simp only [smul_apply, mul_smul]
  one_smul Q := ext fun x => by simp only [QuadraticForm.smul_apply, one_smul]
  smul_add a Q Q' := by 
    ext
    simp only [add_apply, smul_apply, smul_add]
  smul_zero a := by 
    ext
    simp only [zero_apply, smul_apply, smul_zero]

instance [Semiring S] [Module S R] [SMulCommClass S R R] :
    Module S
      (QuadraticForm R
        M) where 
  zero_smul Q := by 
    ext
    simp only [zero_apply, smul_apply, zero_smul]
  add_smul a b Q := by 
    ext
    simp only [add_apply, smul_apply, add_smul]

end SemiringOperators

section RingOperators

variable [Ring R] [AddCommGroup M] [Module R M]

instance : Neg (QuadraticForm R M) :=
  ⟨fun Q =>
    { toFun := -Q
      to_fun_smul := fun a x => by simp only [Pi.neg_apply, map_smul, mul_neg]
      exists_companion' :=
        let ⟨B, h⟩ := Q.exists_companion
        ⟨-B, fun x y => by simp_rw [Pi.neg_apply, h, BilinForm.neg_apply, neg_add]⟩ }⟩

@[simp]
theorem coe_fn_neg (Q : QuadraticForm R M) : ⇑(-Q) = -Q :=
  rfl
#align quadratic_form.coe_fn_neg QuadraticForm.coe_fn_neg

@[simp]
theorem neg_apply (Q : QuadraticForm R M) (x : M) : (-Q) x = -Q x :=
  rfl
#align quadratic_form.neg_apply QuadraticForm.neg_apply

instance : Sub (QuadraticForm R M) :=
  ⟨fun Q Q' => (Q + -Q').copy (Q - Q') (sub_eq_add_neg _ _)⟩

@[simp]
theorem coe_fn_sub (Q Q' : QuadraticForm R M) : ⇑(Q - Q') = Q - Q' :=
  rfl
#align quadratic_form.coe_fn_sub QuadraticForm.coe_fn_sub

@[simp]
theorem sub_apply (Q Q' : QuadraticForm R M) (x : M) : (Q - Q') x = Q x - Q' x :=
  rfl
#align quadratic_form.sub_apply QuadraticForm.sub_apply

instance : AddCommGroup (QuadraticForm R M) :=
  FunLike.coe_injective.AddCommGroup _ coe_fn_zero coe_fn_add coe_fn_neg coe_fn_sub
    (fun _ _ => coe_fn_smul _ _) fun _ _ => coe_fn_smul _ _

end RingOperators

section Comp

variable [Semiring R] [AddCommMonoid M] [Module R M]

variable {N : Type v} [AddCommMonoid N] [Module R N]

/-- Compose the quadratic form with a linear function. -/
def comp (Q : QuadraticForm R N) (f : M →ₗ[R] N) :
    QuadraticForm R M where 
  toFun x := Q (f x)
  to_fun_smul a x := by simp only [map_smul, f.map_smul]
  exists_companion' :=
    let ⟨B, h⟩ := Q.exists_companion
    ⟨B.comp f f, fun x y => by simp_rw [f.map_add, h, BilinForm.comp_apply]⟩
#align quadratic_form.comp QuadraticForm.comp

@[simp]
theorem comp_apply (Q : QuadraticForm R N) (f : M →ₗ[R] N) (x : M) : (Q.comp f) x = Q (f x) :=
  rfl
#align quadratic_form.comp_apply QuadraticForm.comp_apply

/-- Compose a quadratic form with a linear function on the left. -/
@[simps (config := { simpRhs := true })]
def LinearMap.compQuadraticForm {S : Type _} [CommSemiring S] [Algebra S R] [Module S M]
    [IsScalarTower S R M] (f : R →ₗ[S] S) (Q : QuadraticForm R M) :
    QuadraticForm S M where 
  toFun x := f (Q x)
  to_fun_smul b x := by rw [Q.map_smul_of_tower b x, f.map_smul, smul_eq_mul]
  exists_companion' :=
    let ⟨B, h⟩ := Q.exists_companion
    ⟨f.compBilinForm B, fun x y => by simp_rw [h, f.map_add, LinearMap.comp_bilin_form_apply]⟩
#align linear_map.comp_quadratic_form LinearMap.compQuadraticForm

end Comp

section CommRing

variable [CommSemiring R] [AddCommMonoid M] [Module R M]

/-- The product of linear forms is a quadratic form. -/
def linMulLin (f g : M →ₗ[R] R) :
    QuadraticForm R M where 
  toFun := f * g
  to_fun_smul a x := by
    simp only [smul_eq_mul, RingHom.id_apply, Pi.mul_apply, LinearMap.map_smulₛₗ]
    ring
  exists_companion' :=
    ⟨BilinForm.linMulLin f g + BilinForm.linMulLin g f, fun x y => by
      simp
      ring⟩
#align quadratic_form.lin_mul_lin QuadraticForm.linMulLin

@[simp]
theorem lin_mul_lin_apply (f g : M →ₗ[R] R) (x) : linMulLin f g x = f x * g x :=
  rfl
#align quadratic_form.lin_mul_lin_apply QuadraticForm.lin_mul_lin_apply

@[simp]
theorem add_lin_mul_lin (f g h : M →ₗ[R] R) : linMulLin (f + g) h = linMulLin f h + linMulLin g h :=
  ext fun x => add_mul _ _ _
#align quadratic_form.add_lin_mul_lin QuadraticForm.add_lin_mul_lin

@[simp]
theorem lin_mul_lin_add (f g h : M →ₗ[R] R) : linMulLin f (g + h) = linMulLin f g + linMulLin f h :=
  ext fun x => mul_add _ _ _
#align quadratic_form.lin_mul_lin_add QuadraticForm.lin_mul_lin_add

variable {N : Type v} [AddCommMonoid N] [Module R N]

@[simp]
theorem lin_mul_lin_comp (f g : M →ₗ[R] R) (h : N →ₗ[R] M) :
    (linMulLin f g).comp h = linMulLin (f.comp h) (g.comp h) :=
  rfl
#align quadratic_form.lin_mul_lin_comp QuadraticForm.lin_mul_lin_comp

variable {n : Type _}

/-- `sq` is the quadratic form mapping the vector `x : R₁` to `x * x` -/
@[simps]
def sq : QuadraticForm R R :=
  linMulLin LinearMap.id LinearMap.id
#align quadratic_form.sq QuadraticForm.sq

/-- `proj i j` is the quadratic form mapping the vector `x : n → R₁` to `x i * x j` -/
def proj (i j : n) : QuadraticForm R (n → R) :=
  linMulLin (@LinearMap.proj _ _ _ (fun _ => R) _ _ i) (@LinearMap.proj _ _ _ (fun _ => R) _ _ j)
#align quadratic_form.proj QuadraticForm.proj

@[simp]
theorem proj_apply (i j : n) (x : n → R) : proj i j x = x i * x j :=
  rfl
#align quadratic_form.proj_apply QuadraticForm.proj_apply

end CommRing

end QuadraticForm

/-!
### Associated bilinear forms

Over a commutative ring with an inverse of 2, the theory of quadratic forms is
basically identical to that of symmetric bilinear forms. The map from quadratic
forms to bilinear forms giving this identification is called the `associated`
quadratic form.
-/


namespace BilinForm

open QuadraticForm

section Semiring

variable [Semiring R] [AddCommMonoid M] [Module R M]

variable {B : BilinForm R M}

/-- A bilinear form gives a quadratic form by applying the argument twice. -/
def toQuadraticForm (B : BilinForm R M) :
    QuadraticForm R M where 
  toFun x := B x x
  to_fun_smul a x := by simp only [mul_assoc, smul_right, smul_left]
  exists_companion' := ⟨B + BilinForm.flipHom ℕ B, fun x y => by simp [add_add_add_comm, add_comm]⟩
#align bilin_form.to_quadratic_form BilinForm.toQuadraticForm

@[simp]
theorem to_quadratic_form_apply (B : BilinForm R M) (x : M) : B.toQuadraticForm x = B x x :=
  rfl
#align bilin_form.to_quadratic_form_apply BilinForm.to_quadratic_form_apply

section

variable (R M)

@[simp]
theorem to_quadratic_form_zero : (0 : BilinForm R M).toQuadraticForm = 0 :=
  rfl
#align bilin_form.to_quadratic_form_zero BilinForm.to_quadratic_form_zero

end

@[simp]
theorem to_quadratic_form_add (B₁ B₂ : BilinForm R M) :
    (B₁ + B₂).toQuadraticForm = B₁.toQuadraticForm + B₂.toQuadraticForm :=
  rfl
#align bilin_form.to_quadratic_form_add BilinForm.to_quadratic_form_add

@[simp]
theorem to_quadratic_form_smul [Monoid S] [DistribMulAction S R] [SMulCommClass S R R] (a : S)
    (B : BilinForm R M) : (a • B).toQuadraticForm = a • B.toQuadraticForm :=
  rfl
#align bilin_form.to_quadratic_form_smul BilinForm.to_quadratic_form_smul

section

variable (R M)

/-- `bilin_form.to_quadratic_form` as an additive homomorphism -/
@[simps]
def toQuadraticFormAddMonoidHom :
    BilinForm R M →+ QuadraticForm R
        M where 
  toFun := toQuadraticForm
  map_zero' := to_quadratic_form_zero _ _
  map_add' := to_quadratic_form_add
#align bilin_form.to_quadratic_form_add_monoid_hom BilinForm.toQuadraticFormAddMonoidHom

end

@[simp]
theorem to_quadratic_form_list_sum (B : List (BilinForm R M)) :
    B.Sum.toQuadraticForm = (B.map toQuadraticForm).Sum :=
  map_list_sum (toQuadraticFormAddMonoidHom R M) B
#align bilin_form.to_quadratic_form_list_sum BilinForm.to_quadratic_form_list_sum

@[simp]
theorem to_quadratic_form_multiset_sum (B : Multiset (BilinForm R M)) :
    B.Sum.toQuadraticForm = (B.map toQuadraticForm).Sum :=
  map_multiset_sum (toQuadraticFormAddMonoidHom R M) B
#align bilin_form.to_quadratic_form_multiset_sum BilinForm.to_quadratic_form_multiset_sum

@[simp]
theorem to_quadratic_form_sum {ι : Type _} (s : Finset ι) (B : ι → BilinForm R M) :
    (∑ i in s, B i).toQuadraticForm = ∑ i in s, (B i).toQuadraticForm :=
  map_sum (toQuadraticFormAddMonoidHom R M) B s
#align bilin_form.to_quadratic_form_sum BilinForm.to_quadratic_form_sum

end Semiring

section Ring

variable [Ring R] [AddCommGroup M] [Module R M]

variable {B : BilinForm R M}

theorem polar_to_quadratic_form (x y : M) : polar (fun x => B x x) x y = B x y + B y x := by
  simp only [add_assoc, add_sub_cancel', add_right, polar, add_left_inj, add_neg_cancel_left,
    add_left, sub_eq_add_neg _ (B y y), add_comm (B y x) _]
#align bilin_form.polar_to_quadratic_form BilinForm.polar_to_quadratic_form

@[simp]
theorem to_quadratic_form_neg (B : BilinForm R M) : (-B).toQuadraticForm = -B.toQuadraticForm :=
  rfl
#align bilin_form.to_quadratic_form_neg BilinForm.to_quadratic_form_neg

@[simp]
theorem to_quadratic_form_sub (B₁ B₂ : BilinForm R M) :
    (B₁ - B₂).toQuadraticForm = B₁.toQuadraticForm - B₂.toQuadraticForm :=
  rfl
#align bilin_form.to_quadratic_form_sub BilinForm.to_quadratic_form_sub

end Ring

end BilinForm

namespace QuadraticForm

open BilinForm

section AssociatedHom

variable [Ring R] [CommRing R₁] [AddCommGroup M] [Module R M] [Module R₁ M]

variable (S) [CommSemiring S] [Algebra S R]

variable [Invertible (2 : R)] {B₁ : BilinForm R M}

/-- `associated_hom` is the map that sends a quadratic form on a module `M` over `R` to its
associated symmetric bilinear form.  As provided here, this has the structure of an `S`-linear map
where `S` is a commutative subring of `R`.

Over a commutative ring, use `associated`, which gives an `R`-linear map.  Over a general ring with
no nontrivial distinguished commutative subring, use `associated'`, which gives an additive
homomorphism (or more precisely a `ℤ`-linear map.) -/
def associatedHom :
    QuadraticForm R M →ₗ[S]
      BilinForm R
        M where 
  toFun Q :=
    ((· • ·) : Submonoid.center R → BilinForm R M → BilinForm R M)
      ⟨⅟ 2, fun x => (Commute.one_right x).bit0_right.inv_of_right⟩ Q.polarBilin
  map_add' Q Q' := by 
    ext
    simp only [BilinForm.add_apply, BilinForm.smul_apply, coe_fn_mk, polar_bilin_apply, polar_add,
      coe_fn_add, smul_add]
  map_smul' s Q := by 
    ext
    simp only [RingHom.id_apply, polar_smul, smul_comm s, polar_bilin_apply, coe_fn_mk, coe_fn_smul,
      BilinForm.smul_apply]
#align quadratic_form.associated_hom QuadraticForm.associatedHom

variable (Q : QuadraticForm R M) (S)

@[simp]
theorem associated_apply (x y : M) : associatedHom S Q x y = ⅟ 2 * (Q (x + y) - Q x - Q y) :=
  rfl
#align quadratic_form.associated_apply QuadraticForm.associated_apply

theorem associated_is_symm : (associatedHom S Q).IsSymm := fun x y => by
  simp only [associated_apply, add_comm, add_left_comm, sub_eq_add_neg]
#align quadratic_form.associated_is_symm QuadraticForm.associated_is_symm

@[simp]
theorem associated_comp {N : Type v} [AddCommGroup N] [Module R N] (f : N →ₗ[R] M) :
    associatedHom S (Q.comp f) = (associatedHom S Q).comp f f := by
  ext
  simp only [QuadraticForm.comp_apply, BilinForm.comp_apply, associated_apply, LinearMap.map_add]
#align quadratic_form.associated_comp QuadraticForm.associated_comp

theorem associated_to_quadratic_form (B : BilinForm R M) (x y : M) :
    associatedHom S B.toQuadraticForm x y = ⅟ 2 * (B x y + B y x) := by
  simp only [associated_apply, ← polar_to_quadratic_form, polar, to_quadratic_form_apply]
#align quadratic_form.associated_to_quadratic_form QuadraticForm.associated_to_quadratic_form

theorem associated_left_inverse (h : B₁.IsSymm) : associatedHom S B₁.toQuadraticForm = B₁ :=
  BilinForm.ext fun x y => by
    rw [associated_to_quadratic_form, is_symm.eq h x y, ← two_mul, ← mul_assoc, invOf_mul_self,
      one_mul]
#align quadratic_form.associated_left_inverse QuadraticForm.associated_left_inverse

theorem to_quadratic_form_associated : (associatedHom S Q).toQuadraticForm = Q :=
  QuadraticForm.ext fun x =>
    calc
      (associatedHom S Q).toQuadraticForm x = ⅟ 2 * (Q x + Q x) := by
        simp only [add_assoc, add_sub_cancel', one_mul, to_quadratic_form_apply, add_mul,
          associated_apply, map_add_self, bit0]
      _ = Q x := by rw [← two_mul (Q x), ← mul_assoc, invOf_mul_self, one_mul]
      
#align quadratic_form.to_quadratic_form_associated QuadraticForm.to_quadratic_form_associated

-- note: usually `right_inverse` lemmas are named the other way around, but this is consistent
-- with historical naming in this file.
theorem associated_right_inverse :
    Function.RightInverse (associatedHom S) (BilinForm.toQuadraticForm : _ → QuadraticForm R M) :=
  fun Q => to_quadratic_form_associated S Q
#align quadratic_form.associated_right_inverse QuadraticForm.associated_right_inverse

theorem associated_eq_self_apply (x : M) : associatedHom S Q x x = Q x := by
  rw [associated_apply, map_add_self]
  suffices ⅟ 2 * (2 * Q x) = Q x by 
    convert this
    simp only [bit0, add_mul, one_mul]
    abel
  simp only [← mul_assoc, one_mul, invOf_mul_self]
#align quadratic_form.associated_eq_self_apply QuadraticForm.associated_eq_self_apply

/-- `associated'` is the `ℤ`-linear map that sends a quadratic form on a module `M` over `R` to its
associated symmetric bilinear form. -/
abbrev associated' : QuadraticForm R M →ₗ[ℤ] BilinForm R M :=
  associatedHom ℤ
#align quadratic_form.associated' QuadraticForm.associated'

/-- Symmetric bilinear forms can be lifted to quadratic forms -/
instance canLift :
    CanLift (BilinForm R M) (QuadraticForm R M) (associatedHom ℕ)
      BilinForm.IsSymm where prf B hB := ⟨B.toQuadraticForm, associated_left_inverse _ hB⟩
#align quadratic_form.can_lift QuadraticForm.canLift

/-- There exists a non-null vector with respect to any quadratic form `Q` whose associated
bilinear form is non-zero, i.e. there exists `x` such that `Q x ≠ 0`. -/
theorem exists_quadratic_form_ne_zero {Q : QuadraticForm R M} (hB₁ : Q.associated' ≠ 0) :
    ∃ x, Q x ≠ 0 := by 
  rw [← not_forall]
  intro h
  apply hB₁
  rw [(QuadraticForm.ext h : Q = 0), LinearMap.map_zero]
#align quadratic_form.exists_quadratic_form_ne_zero QuadraticForm.exists_quadratic_form_ne_zero

end AssociatedHom

section Associated

variable [CommRing R₁] [AddCommGroup M] [Module R₁ M]

variable [Invertible (2 : R₁)]

-- Note:  When possible, rather than writing lemmas about `associated`, write a lemma applying to
-- the more general `associated_hom` and place it in the previous section.
/-- `associated` is the linear map that sends a quadratic form over a commutative ring to its
associated symmetric bilinear form. -/
abbrev associated : QuadraticForm R₁ M →ₗ[R₁] BilinForm R₁ M :=
  associatedHom R₁
#align quadratic_form.associated QuadraticForm.associated

@[simp]
theorem associated_lin_mul_lin (f g : M →ₗ[R₁] R₁) :
    (linMulLin f g).Associated = ⅟ (2 : R₁) • (BilinForm.linMulLin f g + BilinForm.linMulLin g f) :=
  by 
  ext
  simp only [smul_add, Algebra.id.smul_eq_mul, BilinForm.lin_mul_lin_apply,
    QuadraticForm.lin_mul_lin_apply, BilinForm.smul_apply, associated_apply, BilinForm.add_apply,
    LinearMap.map_add]
  ring
#align quadratic_form.associated_lin_mul_lin QuadraticForm.associated_lin_mul_lin

end Associated

section Anisotropic

section Semiring

variable [Semiring R] [AddCommMonoid M] [Module R M]

/-- An anisotropic quadratic form is zero only on zero vectors. -/
def Anisotropic (Q : QuadraticForm R M) : Prop :=
  ∀ x, Q x = 0 → x = 0
#align quadratic_form.anisotropic QuadraticForm.Anisotropic

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (x «expr ≠ » 0) -/
theorem not_anisotropic_iff_exists (Q : QuadraticForm R M) :
    ¬Anisotropic Q ↔ ∃ (x : _)(_ : x ≠ 0), Q x = 0 := by
  simp only [anisotropic, not_forall, exists_prop, and_comm']
#align quadratic_form.not_anisotropic_iff_exists QuadraticForm.not_anisotropic_iff_exists

theorem Anisotropic.eq_zero_iff {Q : QuadraticForm R M} (h : Anisotropic Q) {x : M} :
    Q x = 0 ↔ x = 0 :=
  ⟨h x, fun h => h.symm ▸ map_zero Q⟩
#align quadratic_form.anisotropic.eq_zero_iff QuadraticForm.Anisotropic.eq_zero_iff

end Semiring

section Ring

variable [Ring R] [AddCommGroup M] [Module R M]

/-- The associated bilinear form of an anisotropic quadratic form is nondegenerate. -/
theorem nondegenerate_of_anisotropic [Invertible (2 : R)] (Q : QuadraticForm R M)
    (hB : Q.Anisotropic) : Q.associated'.Nondegenerate := by
  intro x hx
  refine' hB _ _
  rw [← hx x]
  exact (associated_eq_self_apply _ _ x).symm
#align quadratic_form.nondegenerate_of_anisotropic QuadraticForm.nondegenerate_of_anisotropic

end Ring

end Anisotropic

section PosDef

variable {R₂ : Type u} [OrderedRing R₂] [AddCommMonoid M] [Module R₂ M]

variable {Q₂ : QuadraticForm R₂ M}

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (x «expr ≠ » 0) -/
/-- A positive definite quadratic form is positive on nonzero vectors. -/
def PosDef (Q₂ : QuadraticForm R₂ M) : Prop :=
  ∀ (x) (_ : x ≠ 0), 0 < Q₂ x
#align quadratic_form.pos_def QuadraticForm.PosDef

theorem PosDef.smul {R} [LinearOrderedCommRing R] [Module R M] {Q : QuadraticForm R M}
    (h : PosDef Q) {a : R} (a_pos : 0 < a) : PosDef (a • Q) := fun x hx => mul_pos a_pos (h x hx)
#align quadratic_form.pos_def.smul QuadraticForm.PosDef.smul

variable {n : Type _}

theorem PosDef.nonneg {Q : QuadraticForm R₂ M} (hQ : PosDef Q) (x : M) : 0 ≤ Q x :=
  (eq_or_ne x 0).elim (fun h => h.symm ▸ (map_zero Q).symm.le) fun h => (hQ _ h).le
#align quadratic_form.pos_def.nonneg QuadraticForm.PosDef.nonneg

theorem PosDef.anisotropic {Q : QuadraticForm R₂ M} (hQ : Q.PosDef) : Q.Anisotropic := fun x hQx =>
  by_contradiction fun hx =>
    lt_irrefl (0 : R₂) <| by 
      have := hQ _ hx
      rw [hQx] at this
      exact this
#align quadratic_form.pos_def.anisotropic QuadraticForm.PosDef.anisotropic

theorem pos_def_of_nonneg {Q : QuadraticForm R₂ M} (h : ∀ x, 0 ≤ Q x) (h0 : Q.Anisotropic) :
    PosDef Q := fun x hx => lt_of_le_of_ne (h x) (Ne.symm fun hQx => hx <| h0 _ hQx)
#align quadratic_form.pos_def_of_nonneg QuadraticForm.pos_def_of_nonneg

theorem pos_def_iff_nonneg {Q : QuadraticForm R₂ M} : PosDef Q ↔ (∀ x, 0 ≤ Q x) ∧ Q.Anisotropic :=
  ⟨fun h => ⟨h.Nonneg, h.Anisotropic⟩, fun ⟨n, a⟩ => pos_def_of_nonneg n a⟩
#align quadratic_form.pos_def_iff_nonneg QuadraticForm.pos_def_iff_nonneg

theorem PosDef.add (Q Q' : QuadraticForm R₂ M) (hQ : PosDef Q) (hQ' : PosDef Q') :
    PosDef (Q + Q') := fun x hx => add_pos (hQ x hx) (hQ' x hx)
#align quadratic_form.pos_def.add QuadraticForm.PosDef.add

theorem lin_mul_lin_self_pos_def {R} [LinearOrderedCommRing R] [Module R M] (f : M →ₗ[R] R)
    (hf : LinearMap.ker f = ⊥) : PosDef (linMulLin f f) := fun x hx =>
  mul_self_pos.2 fun h => hx <| LinearMap.ker_eq_bot'.mp hf _ h
#align quadratic_form.lin_mul_lin_self_pos_def QuadraticForm.lin_mul_lin_self_pos_def

end PosDef

end QuadraticForm

section

/-!
### Quadratic forms and matrices

Connect quadratic forms and matrices, in order to explicitly compute with them.
The convention is twos out, so there might be a factor 2⁻¹ in the entries of the
matrix.
The determinant of the matrix is the discriminant of the quadratic form.
-/


variable {n : Type w} [Fintype n] [DecidableEq n]

variable [CommRing R₁] [AddCommMonoid M] [Module R₁ M]

/-- `M.to_quadratic_form` is the map `λ x, col x ⬝ M ⬝ row x` as a quadratic form. -/
def Matrix.toQuadraticForm' (M : Matrix n n R₁) : QuadraticForm R₁ (n → R₁) :=
  M.toBilin'.toQuadraticForm
#align matrix.to_quadratic_form' Matrix.toQuadraticForm'

variable [Invertible (2 : R₁)]

/-- A matrix representation of the quadratic form. -/
def QuadraticForm.toMatrix' (Q : QuadraticForm R₁ (n → R₁)) : Matrix n n R₁ :=
  Q.Associated.toMatrix'
#align quadratic_form.to_matrix' QuadraticForm.toMatrix'

open QuadraticForm

theorem QuadraticForm.to_matrix'_smul (a : R₁) (Q : QuadraticForm R₁ (n → R₁)) :
    (a • Q).toMatrix' = a • Q.toMatrix' := by
  simp only [to_matrix', LinearEquiv.map_smul, LinearMap.map_smul]
#align quadratic_form.to_matrix'_smul QuadraticForm.to_matrix'_smul

theorem QuadraticForm.is_symm_to_matrix' (Q : QuadraticForm R₁ (n → R₁)) : Q.toMatrix'.IsSymm := by
  ext (i j)
  rw [to_matrix', BilinForm.to_matrix'_apply, BilinForm.to_matrix'_apply, associated_is_symm]
#align quadratic_form.is_symm_to_matrix' QuadraticForm.is_symm_to_matrix'

end

namespace QuadraticForm

variable {n : Type w} [Fintype n]

variable [CommRing R₁] [DecidableEq n] [Invertible (2 : R₁)]

variable {m : Type w} [DecidableEq m] [Fintype m]

open Matrix

@[simp]
theorem to_matrix'_comp (Q : QuadraticForm R₁ (m → R₁)) (f : (n → R₁) →ₗ[R₁] m → R₁) :
    (Q.comp f).toMatrix' = f.toMatrix'ᵀ ⬝ Q.toMatrix' ⬝ f.toMatrix' := by
  ext
  simp only [QuadraticForm.associated_comp, BilinForm.to_matrix'_comp, to_matrix']
#align quadratic_form.to_matrix'_comp QuadraticForm.to_matrix'_comp

section Discriminant

variable {Q : QuadraticForm R₁ (n → R₁)}

/-- The discriminant of a quadratic form generalizes the discriminant of a quadratic polynomial. -/
def discr (Q : QuadraticForm R₁ (n → R₁)) : R₁ :=
  Q.toMatrix'.det
#align quadratic_form.discr QuadraticForm.discr

theorem discr_smul (a : R₁) : (a • Q).discr = a ^ Fintype.card n * Q.discr := by
  simp only [discr, to_matrix'_smul, Matrix.det_smul]
#align quadratic_form.discr_smul QuadraticForm.discr_smul

theorem discr_comp (f : (n → R₁) →ₗ[R₁] n → R₁) :
    (Q.comp f).discr = f.toMatrix'.det * f.toMatrix'.det * Q.discr := by
  simp only [Matrix.det_transpose, mul_left_comm, QuadraticForm.to_matrix'_comp, mul_comm,
    Matrix.det_mul, discr]
#align quadratic_form.discr_comp QuadraticForm.discr_comp

end Discriminant

end QuadraticForm

namespace QuadraticForm

end QuadraticForm

namespace BilinForm

section Semiring

variable [Semiring R] [AddCommMonoid M] [Module R M]

/-- A bilinear form is nondegenerate if the quadratic form it is associated with is anisotropic. -/
theorem nondegenerate_of_anisotropic {B : BilinForm R M} (hB : B.toQuadraticForm.Anisotropic) :
    B.Nondegenerate := fun x hx => hB _ (hx x)
#align bilin_form.nondegenerate_of_anisotropic BilinForm.nondegenerate_of_anisotropic

end Semiring

variable [Ring R] [AddCommGroup M] [Module R M]

/-- There exists a non-null vector with respect to any symmetric, nonzero bilinear form `B`
on a module `M` over a ring `R` with invertible `2`, i.e. there exists some
`x : M` such that `B x x ≠ 0`. -/
theorem exists_bilin_form_self_ne_zero [htwo : Invertible (2 : R)] {B : BilinForm R M} (hB₁ : B ≠ 0)
    (hB₂ : B.IsSymm) : ∃ x, ¬B.IsOrtho x x := by
  lift B to QuadraticForm R M using hB₂ with Q
  obtain ⟨x, hx⟩ := QuadraticForm.exists_quadratic_form_ne_zero hB₁
  exact ⟨x, fun h => hx (Q.associated_eq_self_apply ℕ x ▸ h)⟩
#align bilin_form.exists_bilin_form_self_ne_zero BilinForm.exists_bilin_form_self_ne_zero

open FiniteDimensional

variable {V : Type u} {K : Type v} [Field K] [AddCommGroup V] [Module K V]

variable [FiniteDimensional K V]

/-- Given a symmetric bilinear form `B` on some vector space `V` over a field `K`
in which `2` is invertible, there exists an orthogonal basis with respect to `B`. -/
theorem exists_orthogonal_basis [hK : Invertible (2 : K)] {B : BilinForm K V} (hB₂ : B.IsSymm) :
    ∃ v : Basis (Fin (finrank K V)) K V, B.IsOrtho v := by
  induction' hd : finrank K V with d ih generalizing V
  · exact ⟨basisOfFinrankZero hd, fun _ _ _ => zero_left _⟩
  haveI := finrank_pos_iff.1 (hd.symm ▸ Nat.succ_pos d : 0 < finrank K V)
  -- either the bilinear form is trivial or we can pick a non-null `x`
  obtain rfl | hB₁ := eq_or_ne B 0
  · let b := FiniteDimensional.finBasis K V
    rw [hd] at b
    refine' ⟨b, fun i j hij => rfl⟩
  obtain ⟨x, hx⟩ := exists_bilin_form_self_ne_zero hB₁ hB₂
  rw [← Submodule.finrank_add_eq_of_is_compl (is_compl_span_singleton_orthogonal hx).symm,
    finrank_span_singleton (ne_zero_of_not_is_ortho_self x hx)] at hd
  let B' := B.restrict (B.orthogonal <| K ∙ x)
  obtain ⟨v', hv₁⟩ := ih (B.restrict_symm hB₂ _ : B'.is_symm) (Nat.succ.inj hd)
  -- concatenate `x` with the basis obtained by induction
  let b :=
    Basis.mkFinCons x v'
      (by 
        rintro c y hy hc
        rw [add_eq_zero_iff_neg_eq] at hc
        rw [← hc, Submodule.neg_mem_iff] at hy
        have := (is_compl_span_singleton_orthogonal hx).Disjoint
        rw [Submodule.disjoint_def] at this
        have := this (c • x) (Submodule.smul_mem _ _ <| Submodule.mem_span_singleton_self _) hy
        exact (smul_eq_zero.1 this).resolve_right fun h => hx <| h.symm ▸ zero_left _)
      (by 
        intro y
        refine' ⟨-B x y / B x x, fun z hz => _⟩
        obtain ⟨c, rfl⟩ := Submodule.mem_span_singleton.1 hz
        rw [is_ortho, smul_left, add_right, smul_right, div_mul_cancel _ hx, add_neg_self,
          mul_zero])
  refine' ⟨b, _⟩
  · rw [Basis.coe_mk_fin_cons]
    intro j i
    refine' Fin.cases _ (fun i => _) i <;> refine' Fin.cases _ (fun j => _) j <;> intro hij <;>
      simp only [Function.onFun, Fin.cons_zero, Fin.cons_succ, Function.comp_apply]
    · exact (hij rfl).elim
    · rw [is_ortho, hB₂]
      exact (v' j).Prop _ (Submodule.mem_span_singleton_self x)
    · exact (v' i).Prop _ (Submodule.mem_span_singleton_self x)
    · exact hv₁ (ne_of_apply_ne _ hij)
#align bilin_form.exists_orthogonal_basis BilinForm.exists_orthogonal_basis

end BilinForm

namespace QuadraticForm

open Finset BilinForm

variable {M₁ : Type _} [Semiring R] [CommSemiring R₁] [AddCommMonoid M] [AddCommMonoid M₁]

variable [Module R M] [Module R M₁]

variable {ι : Type _} [Fintype ι] {v : Basis ι R M}

/-- Given a quadratic form `Q` and a basis, `basis_repr` is the basis representation of `Q`. -/
noncomputable def basisRepr (Q : QuadraticForm R M) (v : Basis ι R M) : QuadraticForm R (ι → R) :=
  Q.comp v.equivFun.symm
#align quadratic_form.basis_repr QuadraticForm.basisRepr

@[simp]
theorem basis_repr_apply (Q : QuadraticForm R M) (w : ι → R) :
    Q.basis_repr v w = Q (∑ i : ι, w i • v i) := by
  rw [← v.equiv_fun_symm_apply]
  rfl
#align quadratic_form.basis_repr_apply QuadraticForm.basis_repr_apply

section

variable (R₁)

/-- The weighted sum of squares with respect to some weight as a quadratic form.

The weights are applied using `•`; typically this definition is used either with `S = R₁` or
`[algebra S R₁]`, although this is stated more generally. -/
def weightedSumSquares [Monoid S] [DistribMulAction S R₁] [SMulCommClass S R₁ R₁] (w : ι → S) :
    QuadraticForm R₁ (ι → R₁) :=
  ∑ i : ι, w i • proj i i
#align quadratic_form.weighted_sum_squares QuadraticForm.weightedSumSquares

end

@[simp]
theorem weighted_sum_squares_apply [Monoid S] [DistribMulAction S R₁] [SMulCommClass S R₁ R₁]
    (w : ι → S) (v : ι → R₁) : weightedSumSquares R₁ w v = ∑ i : ι, w i • (v i * v i) :=
  QuadraticForm.sum_apply _ _ _
#align quadratic_form.weighted_sum_squares_apply QuadraticForm.weighted_sum_squares_apply

/-- On an orthogonal basis, the basis representation of `Q` is just a sum of squares. -/
theorem basis_repr_eq_of_is_Ortho {R₁ M} [CommRing R₁] [AddCommGroup M] [Module R₁ M]
    [Invertible (2 : R₁)] (Q : QuadraticForm R₁ M) (v : Basis ι R₁ M)
    (hv₂ : (associated Q).IsOrtho v) : Q.basis_repr v = weightedSumSquares _ fun i => Q (v i) := by
  ext w
  rw [basis_repr_apply, ← @associated_eq_self_apply R₁, sum_left, weighted_sum_squares_apply]
  refine' sum_congr rfl fun j hj => _
  rw [← @associated_eq_self_apply R₁, sum_right, sum_eq_single_of_mem j hj]
  · rw [smul_left, smul_right, smul_eq_mul]
    ring
  · intro i _ hij
    rw [smul_left, smul_right, show associated_hom R₁ Q (v j) (v i) = 0 from hv₂ hij.symm, mul_zero,
      mul_zero]
#align quadratic_form.basis_repr_eq_of_is_Ortho QuadraticForm.basis_repr_eq_of_is_Ortho

end QuadraticForm

