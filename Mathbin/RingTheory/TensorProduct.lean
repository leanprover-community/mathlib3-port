import Mathbin.LinearAlgebra.TensorProduct 
import Mathbin.Algebra.Algebra.Tower

/-!
# The tensor product of R-algebras

Let `R` be a (semi)ring and `A` an `R`-algebra.
In this file we:

- Define the `A`-module structure on `A ⊗ M`, for an `R`-module `M`.
- Define the `R`-algebra structure on `A ⊗ B`, for another `R`-algebra `B`.
  and provide the structure isomorphisms
  * `R ⊗[R] A ≃ₐ[R] A`
  * `A ⊗[R] R ≃ₐ[R] A`
  * `A ⊗[R] B ≃ₐ[R] B ⊗[R] A`
  * `((A ⊗[R] B) ⊗[R] C) ≃ₐ[R] (A ⊗[R] (B ⊗[R] C))`

## Main declaration

- `linear_map.base_change A f` is the `A`-linear map `A ⊗ f`, for an `R`-linear map `f`.

## Implementation notes

The heterobasic definitions below such as:
 * `tensor_product.algebra_tensor_module.curry`
 * `tensor_product.algebra_tensor_module.uncurry`
 * `tensor_product.algebra_tensor_module.lcurry`
 * `tensor_product.algebra_tensor_module.lift`
 * `tensor_product.algebra_tensor_module.lift.equiv`
 * `tensor_product.algebra_tensor_module.mk`
 * `tensor_product.algebra_tensor_module.assoc`

are just more general versions of the definitions already in `linear_algebra/tensor_product`. We
could thus consider replacing the less general definitions with these ones. If we do this, we
probably should still implement the less general ones as abbreviations to the more general ones with
fewer type arguments.
-/


universe u v₁ v₂ v₃ v₄

open_locale TensorProduct

open TensorProduct

namespace TensorProduct

variable{R A M N P : Type _}

/-!
### The `A`-module structure on `A ⊗[R] M`
-/


open LinearMap

open algebra(lsmul)

namespace AlgebraTensorModule

section Semiringₓ

variable[CommSemiringₓ R][Semiringₓ A][Algebra R A]

variable[AddCommMonoidₓ M][Module R M][Module A M][IsScalarTower R A M]

variable[AddCommMonoidₓ N][Module R N]

variable[AddCommMonoidₓ P][Module R P][Module A P][IsScalarTower R A P]

theorem smul_eq_lsmul_rtensor (a : A) (x : M ⊗[R] N) : a • x = (lsmul R M a).rtensor N x :=
  rfl

/-- Heterobasic version of `tensor_product.curry`:

Given a linear map `M ⊗[R] N →[A] P`, compose it with the canonical
bilinear map `M →[A] N →[R] M ⊗[R] N` to form a bilinear map `M →[A] N →[R] P`. -/
@[simps]
def curry (f : M ⊗[R] N →ₗ[A] P) : M →ₗ[A] N →ₗ[R] P :=
  { curry (f.restrict_scalars R) with map_smul' := fun c x => LinearMap.ext$ fun y => f.map_smul c (x ⊗ₜ y) }

theorem restrict_scalars_curry (f : M ⊗[R] N →ₗ[A] P) : restrict_scalars R (curry f) = curry (f.restrict_scalars R) :=
  rfl

/-- Just as `tensor_product.ext` is marked `ext` instead of `tensor_product.ext'`, this is
a better `ext` lemma than `tensor_product.algebra_tensor_module.ext` below.

See note [partially-applied ext lemmas]. -/
@[ext]
theorem curry_injective : Function.Injective (curry : (M ⊗ N →ₗ[A] P) → M →ₗ[A] N →ₗ[R] P) :=
  fun x y h => LinearMap.restrict_scalars_injective R$ curry_injective$ (congr_argₓ (LinearMap.restrictScalars R) h : _)

theorem ext {g h : M ⊗[R] N →ₗ[A] P} (H : ∀ x y, g (x ⊗ₜ y) = h (x ⊗ₜ y)) : g = h :=
  curry_injective$ LinearMap.ext₂ H

end Semiringₓ

section CommSemiringₓ

variable[CommSemiringₓ R][CommSemiringₓ A][Algebra R A]

variable[AddCommMonoidₓ M][Module R M][Module A M][IsScalarTower R A M]

variable[AddCommMonoidₓ N][Module R N]

variable[AddCommMonoidₓ P][Module R P][Module A P][IsScalarTower R A P]

/-- Heterobasic version of `tensor_product.lift`:

Constructing a linear map `M ⊗[R] N →[A] P` given a bilinear map `M →[A] N →[R] P` with the
property that its composition with the canonical bilinear map `M →[A] N →[R] M ⊗[R] N` is
the given bilinear map `M →[A] N →[R] P`. -/
@[simps]
def lift (f : M →ₗ[A] N →ₗ[R] P) : M ⊗[R] N →ₗ[A] P :=
  { lift (f.restrict_scalars R) with
    map_smul' :=
      fun c =>
        show
          ∀ (x : M ⊗[R] N),
            (lift (f.restrict_scalars R)).comp (lsmul R _ c) x = (lsmul R _ c).comp (lift (f.restrict_scalars R)) x from
          ext_iff.1$
            TensorProduct.ext'$
              fun x y =>
                by 
                  simp only [comp_apply, Algebra.lsmul_coe, smul_tmul', lift.tmul, coe_restrict_scalars_eq_coe,
                    f.map_smul, smul_apply] }

@[simp]
theorem lift_tmul (f : M →ₗ[A] N →ₗ[R] P) (x : M) (y : N) : lift f (x ⊗ₜ y) = f x y :=
  lift.tmul' x y

variable(R A M N P)

/-- Heterobasic version of `tensor_product.uncurry`:

Linearly constructing a linear map `M ⊗[R] N →[A] P` given a bilinear map `M →[A] N →[R] P`
with the property that its composition with the canonical bilinear map `M →[A] N →[R] M ⊗[R] N` is
the given bilinear map `M →[A] N →[R] P`. -/
@[simps]
def uncurry : (M →ₗ[A] N →ₗ[R] P) →ₗ[A] M ⊗[R] N →ₗ[A] P :=
  { toFun := lift,
    map_add' :=
      fun f g =>
        ext$
          fun x y =>
            by 
              simp only [lift_tmul, add_apply],
    map_smul' :=
      fun c f =>
        ext$
          fun x y =>
            by 
              simp only [lift_tmul, smul_apply, RingHom.id_apply] }

/-- Heterobasic version of `tensor_product.lcurry`:

Given a linear map `M ⊗[R] N →[A] P`, compose it with the canonical
bilinear map `M →[A] N →[R] M ⊗[R] N` to form a bilinear map `M →[A] N →[R] P`. -/
@[simps]
def lcurry : (M ⊗[R] N →ₗ[A] P) →ₗ[A] M →ₗ[A] N →ₗ[R] P :=
  { toFun := curry, map_add' := fun f g => rfl, map_smul' := fun c f => rfl }

/-- Heterobasic version of `tensor_product.lift.equiv`:

A linear equivalence constructing a linear map `M ⊗[R] N →[A] P` given a
bilinear map `M →[A] N →[R] P` with the property that its composition with the
canonical bilinear map `M →[A] N →[R] M ⊗[R] N` is the given bilinear map `M →[A] N →[R] P`. -/
def lift.equiv : (M →ₗ[A] N →ₗ[R] P) ≃ₗ[A] M ⊗[R] N →ₗ[A] P :=
  LinearEquiv.ofLinear (uncurry R A M N P) (lcurry R A M N P) (LinearMap.ext$ fun f => ext$ fun x y => lift_tmul _ x y)
    (LinearMap.ext$ fun f => LinearMap.ext$ fun x => LinearMap.ext$ fun y => lift_tmul f x y)

variable(R A M N P)

/-- Heterobasic version of `tensor_product.mk`:

The canonical bilinear map `M →[A] N →[R] M ⊗[R] N`. -/
@[simps]
def mk : M →ₗ[A] N →ₗ[R] M ⊗[R] N :=
  { mk R M N with map_smul' := fun c x => rfl }

attribute [local ext] TensorProduct.ext

/-- Heterobasic version of `tensor_product.assoc`:

Linear equivalence between `(M ⊗[A] N) ⊗[R] P` and `M ⊗[A] (N ⊗[R] P)`. -/
def assoc : (M ⊗[A] P) ⊗[R] N ≃ₗ[A] M ⊗[A] P ⊗[R] N :=
  LinearEquiv.ofLinear (lift$ TensorProduct.uncurry A _ _ _$ comp (lcurry R A _ _ _)$ TensorProduct.mk A M (P ⊗[R] N))
    (TensorProduct.uncurry A _ _ _$
      comp (uncurry R A _ _ _)$
        by 
          apply TensorProduct.curry <;> exact mk R A _ _)
    (by 
      ext 
      rfl)
    (by 
      ext 
      rfl)

end CommSemiringₓ

end AlgebraTensorModule

end TensorProduct

namespace LinearMap

open TensorProduct

/-!
### The base-change of a linear map of `R`-modules to a linear map of `A`-modules
-/


section Semiringₓ

variable{R A B M N : Type _}[CommSemiringₓ R]

variable[Semiringₓ A][Algebra R A][Semiringₓ B][Algebra R B]

variable[AddCommMonoidₓ M][Module R M][AddCommMonoidₓ N][Module R N]

variable(r : R)(f g : M →ₗ[R] N)

variable(A)

/-- `base_change A f` for `f : M →ₗ[R] N` is the `A`-linear map `A ⊗[R] M →ₗ[A] A ⊗[R] N`. -/
def base_change (f : M →ₗ[R] N) : A ⊗[R] M →ₗ[A] A ⊗[R] N :=
  { toFun := f.ltensor A, map_add' := (f.ltensor A).map_add,
    map_smul' :=
      fun a x =>
        show (f.ltensor A) (rtensor M (Algebra.lmul R A a) x) = (rtensor N ((Algebra.lmul R A) a)) ((ltensor A f) x)by 
          rw [←comp_apply, ←comp_apply]
          simp only [ltensor_comp_rtensor, rtensor_comp_ltensor] }

variable{A}

@[simp]
theorem base_change_tmul (a : A) (x : M) : f.base_change A (a ⊗ₜ x) = a ⊗ₜ f x :=
  rfl

theorem base_change_eq_ltensor : (f.base_change A : A ⊗ M → A ⊗ N) = f.ltensor A :=
  rfl

@[simp]
theorem base_change_add : (f+g).baseChange A = f.base_change A+g.base_change A :=
  by 
    ext 
    simp [base_change_eq_ltensor]

@[simp]
theorem base_change_zero : base_change A (0 : M →ₗ[R] N) = 0 :=
  by 
    ext 
    simp [base_change_eq_ltensor]

@[simp]
theorem base_change_smul : (r • f).baseChange A = r • f.base_change A :=
  by 
    ext 
    simp [base_change_tmul]

variable(R A M N)

/-- `base_change` as a linear map. -/
@[simps]
def base_change_hom : (M →ₗ[R] N) →ₗ[R] A ⊗[R] M →ₗ[A] A ⊗[R] N :=
  { toFun := base_change A, map_add' := base_change_add, map_smul' := base_change_smul }

end Semiringₓ

section Ringₓ

variable{R A B M N : Type _}[CommRingₓ R]

variable[Ringₓ A][Algebra R A][Ringₓ B][Algebra R B]

variable[AddCommGroupₓ M][Module R M][AddCommGroupₓ N][Module R N]

variable(f g : M →ₗ[R] N)

@[simp]
theorem base_change_sub : (f - g).baseChange A = f.base_change A - g.base_change A :=
  by 
    ext 
    simp [base_change_eq_ltensor]

@[simp]
theorem base_change_neg : (-f).baseChange A = -f.base_change A :=
  by 
    ext 
    simp [base_change_eq_ltensor]

end Ringₓ

end LinearMap

namespace Algebra

namespace TensorProduct

section Semiringₓ

variable{R : Type u}[CommSemiringₓ R]

variable{A : Type v₁}[Semiringₓ A][Algebra R A]

variable{B : Type v₂}[Semiringₓ B][Algebra R B]

/-!
### The `R`-algebra structure on `A ⊗[R] B`
-/


/--
(Implementation detail)
The multiplication map on `A ⊗[R] B`,
for a fixed pure tensor in the first argument,
as an `R`-linear map.
-/
def mul_aux (a₁ : A) (b₁ : B) : A ⊗[R] B →ₗ[R] A ⊗[R] B :=
  TensorProduct.map (lmul_left R a₁) (lmul_left R b₁)

@[simp]
theorem mul_aux_apply (a₁ a₂ : A) (b₁ b₂ : B) : (mul_aux a₁ b₁) (a₂ ⊗ₜ[R] b₂) = (a₁*a₂) ⊗ₜ[R] b₁*b₂ :=
  rfl

/--
(Implementation detail)
The multiplication map on `A ⊗[R] B`,
as an `R`-bilinear map.
-/
def mul : A ⊗[R] B →ₗ[R] A ⊗[R] B →ₗ[R] A ⊗[R] B :=
  TensorProduct.lift$
    LinearMap.mk₂ R mul_aux
      (fun x₁ x₂ y =>
        TensorProduct.ext'$
          fun x' y' =>
            by 
              simp only [mul_aux_apply, LinearMap.add_apply, add_mulₓ, add_tmul])
      (fun c x y =>
        TensorProduct.ext'$
          fun x' y' =>
            by 
              simp only [mul_aux_apply, LinearMap.smul_apply, smul_tmul', smul_mul_assoc])
      (fun x y₁ y₂ =>
        TensorProduct.ext'$
          fun x' y' =>
            by 
              simp only [mul_aux_apply, LinearMap.add_apply, add_mulₓ, tmul_add])
      fun c x y =>
        TensorProduct.ext'$
          fun x' y' =>
            by 
              simp only [mul_aux_apply, LinearMap.smul_apply, smul_tmul, smul_tmul', smul_mul_assoc]

@[simp]
theorem mul_apply (a₁ a₂ : A) (b₁ b₂ : B) : mul (a₁ ⊗ₜ[R] b₁) (a₂ ⊗ₜ[R] b₂) = (a₁*a₂) ⊗ₜ[R] b₁*b₂ :=
  rfl

theorem mul_assoc' (mul : A ⊗[R] B →ₗ[R] A ⊗[R] B →ₗ[R] A ⊗[R] B)
  (h :
    ∀ (a₁ a₂ a₃ : A) (b₁ b₂ b₃ : B),
      mul (mul (a₁ ⊗ₜ[R] b₁) (a₂ ⊗ₜ[R] b₂)) (a₃ ⊗ₜ[R] b₃) = mul (a₁ ⊗ₜ[R] b₁) (mul (a₂ ⊗ₜ[R] b₂) (a₃ ⊗ₜ[R] b₃))) :
  ∀ (x y z : A ⊗[R] B), mul (mul x y) z = mul x (mul y z) :=
  by 
    intros 
    apply TensorProduct.induction_on x
    ·
      simp only [LinearMap.map_zero, LinearMap.zero_apply]
    apply TensorProduct.induction_on y
    ·
      simp only [LinearMap.map_zero, forall_const, LinearMap.zero_apply]
    apply TensorProduct.induction_on z
    ·
      simp only [LinearMap.map_zero, forall_const]
    ·
      intros 
      simp only [h]
    ·
      intros 
      simp only [LinearMap.map_add]
    ·
      intros 
      simp only [LinearMap.map_add, LinearMap.add_apply]
    ·
      intros 
      simp only [LinearMap.map_add, LinearMap.add_apply]

theorem mul_assocₓ (x y z : A ⊗[R] B) : mul (mul x y) z = mul x (mul y z) :=
  mul_assoc' mul
    (by 
      intros 
      simp only [mul_apply, mul_assocₓ])
    x y z

-- error in RingTheory.TensorProduct: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem one_mul (x : «expr ⊗[ ] »(A, R, B)) : «expr = »(mul «expr ⊗ₜ »(1, 1) x, x) :=
begin
  apply [expr tensor_product.induction_on x]; simp [] [] [] [] [] [] { contextual := tt }
end

-- error in RingTheory.TensorProduct: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem mul_one (x : «expr ⊗[ ] »(A, R, B)) : «expr = »(mul x «expr ⊗ₜ »(1, 1), x) :=
begin
  apply [expr tensor_product.induction_on x]; simp [] [] [] [] [] [] { contextual := tt }
end

instance  : Semiringₓ (A ⊗[R] B) :=
  { (by 
      infer_instance :
    AddCommMonoidₓ (A ⊗[R] B)) with
    zero := 0, add := ·+·, one := 1 ⊗ₜ 1, mul := fun a b => mul a b, one_mul := one_mulₓ, mul_one := mul_oneₓ,
    mul_assoc := mul_assocₓ,
    zero_mul :=
      by 
        simp ,
    mul_zero :=
      by 
        simp ,
    left_distrib :=
      by 
        simp ,
    right_distrib :=
      by 
        simp  }

theorem one_def : (1 : A ⊗[R] B) = (1 : A) ⊗ₜ (1 : B) :=
  rfl

@[simp]
theorem tmul_mul_tmul (a₁ a₂ : A) (b₁ b₂ : B) : ((a₁ ⊗ₜ[R] b₁)*a₂ ⊗ₜ[R] b₂) = (a₁*a₂) ⊗ₜ[R] b₁*b₂ :=
  rfl

@[simp]
theorem tmul_pow (a : A) (b : B) (k : ℕ) : a ⊗ₜ[R] b ^ k = (a ^ k) ⊗ₜ[R] (b ^ k) :=
  by 
    induction' k with k ih
    ·
      simp [one_def]
    ·
      simp [pow_succₓ, ih]

/--
The algebra map `R →+* (A ⊗[R] B)` giving `A ⊗[R] B` the structure of an `R`-algebra.
-/
def tensor_algebra_map : R →+* A ⊗[R] B :=
  { toFun := fun r => algebraMap R A r ⊗ₜ[R] 1,
    map_one' :=
      by 
        simp 
        rfl,
    map_mul' :=
      by 
        simp ,
    map_zero' :=
      by 
        simp [zero_tmul],
    map_add' :=
      by 
        simp [add_tmul] }

instance  : Algebra R (A ⊗[R] B) :=
  { tensor_algebra_map,
    (by 
      infer_instance :
    Module R (A ⊗[R] B)) with
    commutes' :=
      fun r x =>
        by 
          apply TensorProduct.induction_on x
          ·
            simp 
          ·
            intro a b 
            simp [tensor_algebra_map, Algebra.commutes]
          ·
            intro y y' h h' 
            simp  at h h' 
            simp [mul_addₓ, add_mulₓ, h, h'],
    smul_def' :=
      fun r x =>
        by 
          apply TensorProduct.induction_on x
          ·
            simp [smul_zero]
          ·
            intro a b 
            rw [tensor_algebra_map, ←tmul_smul, ←smul_tmul, Algebra.smul_def r a]
            simp 
          ·
            intros 
            dsimp 
            simp [smul_add, mul_addₓ] }

@[simp]
theorem algebra_map_apply (r : R) : (algebraMap R (A ⊗[R] B)) r = (algebraMap R A) r ⊗ₜ[R] 1 :=
  rfl

variable{C : Type v₃}[Semiringₓ C][Algebra R C]

@[ext]
theorem ext {g h : A ⊗[R] B →ₐ[R] C} (H : ∀ a b, g (a ⊗ₜ b) = h (a ⊗ₜ b)) : g = h :=
  by 
    apply @AlgHom.to_linear_map_injective R (A ⊗[R] B) C _ _ _ _ _ _ _ _ 
    ext 
    simp [H]

/-- The algebra morphism `A →ₐ[R] A ⊗[R] B` sending `a` to `a ⊗ₜ 1`. -/
def include_left : A →ₐ[R] A ⊗[R] B :=
  { toFun := fun a => a ⊗ₜ 1,
    map_zero' :=
      by 
        simp ,
    map_add' :=
      by 
        simp [add_tmul],
    map_one' := rfl,
    map_mul' :=
      by 
        simp ,
    commutes' :=
      by 
        simp  }

@[simp]
theorem include_left_apply (a : A) : (include_left : A →ₐ[R] A ⊗[R] B) a = a ⊗ₜ 1 :=
  rfl

/-- The algebra morphism `B →ₐ[R] A ⊗[R] B` sending `b` to `1 ⊗ₜ b`. -/
def include_right : B →ₐ[R] A ⊗[R] B :=
  { toFun := fun b => 1 ⊗ₜ b,
    map_zero' :=
      by 
        simp ,
    map_add' :=
      by 
        simp [tmul_add],
    map_one' := rfl,
    map_mul' :=
      by 
        simp ,
    commutes' :=
      fun r =>
        by 
          simp only [algebra_map_apply]
          trans r • (1 : A) ⊗ₜ[R] (1 : B)
          ·
            rw [←tmul_smul, Algebra.smul_def]
            simp 
          ·
            simp [Algebra.smul_def] }

@[simp]
theorem include_right_apply (b : B) : (include_right : B →ₐ[R] A ⊗[R] B) b = 1 ⊗ₜ b :=
  rfl

end Semiringₓ

section Ringₓ

variable{R : Type u}[CommRingₓ R]

variable{A : Type v₁}[Ringₓ A][Algebra R A]

variable{B : Type v₂}[Ringₓ B][Algebra R B]

instance  : Ringₓ (A ⊗[R] B) :=
  { (by 
      infer_instance :
    AddCommGroupₓ (A ⊗[R] B)),
    (by 
      infer_instance :
    Semiringₓ (A ⊗[R] B)) with
     }

end Ringₓ

section CommRingₓ

variable{R : Type u}[CommRingₓ R]

variable{A : Type v₁}[CommRingₓ A][Algebra R A]

variable{B : Type v₂}[CommRingₓ B][Algebra R B]

instance  : CommRingₓ (A ⊗[R] B) :=
  { (by 
      infer_instance :
    Ringₓ (A ⊗[R] B)) with
    mul_comm :=
      fun x y =>
        by 
          apply TensorProduct.induction_on x
          ·
            simp 
          ·
            intro a₁ b₁ 
            apply TensorProduct.induction_on y
            ·
              simp 
            ·
              intro a₂ b₂ 
              simp [mul_commₓ]
            ·
              intro a₂ b₂ ha hb 
              simp [mul_addₓ, add_mulₓ, ha, hb]
          ·
            intro x₁ x₂ h₁ h₂ 
            simp [mul_addₓ, add_mulₓ, h₁, h₂] }

end CommRingₓ

/--
Verify that typeclass search finds the ring structure on `A ⊗[ℤ] B`
when `A` and `B` are merely rings, by treating both as `ℤ`-algebras.
-/
example  {A : Type v₁} [Ringₓ A] {B : Type v₂} [Ringₓ B] : Ringₓ (A ⊗[ℤ] B) :=
  by 
    infer_instance

/--
Verify that typeclass search finds the comm_ring structure on `A ⊗[ℤ] B`
when `A` and `B` are merely comm_rings, by treating both as `ℤ`-algebras.
-/
example  {A : Type v₁} [CommRingₓ A] {B : Type v₂} [CommRingₓ B] : CommRingₓ (A ⊗[ℤ] B) :=
  by 
    infer_instance

/-!
We now build the structure maps for the symmetric monoidal category of `R`-algebras.
-/


section Monoidal

section 

variable{R : Type u}[CommSemiringₓ R]

variable{A : Type v₁}[Semiringₓ A][Algebra R A]

variable{B : Type v₂}[Semiringₓ B][Algebra R B]

variable{C : Type v₃}[Semiringₓ C][Algebra R C]

variable{D : Type v₄}[Semiringₓ D][Algebra R D]

/--
Build an algebra morphism from a linear map out of a tensor product,
and evidence of multiplicativity on pure tensors.
-/
def alg_hom_of_linear_map_tensor_product (f : A ⊗[R] B →ₗ[R] C)
  (w₁ : ∀ (a₁ a₂ : A) (b₁ b₂ : B), f ((a₁*a₂) ⊗ₜ b₁*b₂) = f (a₁ ⊗ₜ b₁)*f (a₂ ⊗ₜ b₂))
  (w₂ : ∀ r, f ((algebraMap R A) r ⊗ₜ[R] 1) = (algebraMap R C) r) : A ⊗[R] B →ₐ[R] C :=
  { f with
    map_one' :=
      by 
        simpa using w₂ 1,
    map_zero' :=
      by 
        simp ,
    map_mul' :=
      fun x y =>
        by 
          apply TensorProduct.induction_on x
          ·
            simp 
          ·
            intro a₁ b₁ 
            apply TensorProduct.induction_on y
            ·
              simp 
            ·
              intro a₂ b₂ 
              simp [w₁]
            ·
              intro x₁ x₂ h₁ h₂ 
              simp  at h₁ 
              simp  at h₂ 
              simp [mul_addₓ, add_mulₓ, h₁, h₂]
          ·
            intro x₁ x₂ h₁ h₂ 
            simp  at h₁ 
            simp  at h₂ 
            simp [mul_addₓ, add_mulₓ, h₁, h₂],
    commutes' :=
      fun r =>
        by 
          simp [w₂] }

@[simp]
theorem alg_hom_of_linear_map_tensor_product_apply f w₁ w₂ x :
  (alg_hom_of_linear_map_tensor_product f w₁ w₂ : A ⊗[R] B →ₐ[R] C) x = f x :=
  rfl

/--
Build an algebra equivalence from a linear equivalence out of a tensor product,
and evidence of multiplicativity on pure tensors.
-/
def alg_equiv_of_linear_equiv_tensor_product (f : A ⊗[R] B ≃ₗ[R] C)
  (w₁ : ∀ (a₁ a₂ : A) (b₁ b₂ : B), f ((a₁*a₂) ⊗ₜ b₁*b₂) = f (a₁ ⊗ₜ b₁)*f (a₂ ⊗ₜ b₂))
  (w₂ : ∀ r, f ((algebraMap R A) r ⊗ₜ[R] 1) = (algebraMap R C) r) : A ⊗[R] B ≃ₐ[R] C :=
  { alg_hom_of_linear_map_tensor_product (f : A ⊗[R] B →ₗ[R] C) w₁ w₂, f with  }

@[simp]
theorem alg_equiv_of_linear_equiv_tensor_product_apply f w₁ w₂ x :
  (alg_equiv_of_linear_equiv_tensor_product f w₁ w₂ : A ⊗[R] B ≃ₐ[R] C) x = f x :=
  rfl

/--
Build an algebra equivalence from a linear equivalence out of a triple tensor product,
and evidence of multiplicativity on pure tensors.
-/
def alg_equiv_of_linear_equiv_triple_tensor_product (f : (A ⊗[R] B) ⊗[R] C ≃ₗ[R] D)
  (w₁ : ∀ (a₁ a₂ : A) (b₁ b₂ : B) (c₁ c₂ : C), f (((a₁*a₂) ⊗ₜ b₁*b₂) ⊗ₜ c₁*c₂) = f (a₁ ⊗ₜ b₁ ⊗ₜ c₁)*f (a₂ ⊗ₜ b₂ ⊗ₜ c₂))
  (w₂ : ∀ r, f (((algebraMap R A) r ⊗ₜ[R] (1 : B)) ⊗ₜ[R] (1 : C)) = (algebraMap R D) r) : (A ⊗[R] B) ⊗[R] C ≃ₐ[R] D :=
  { f with toFun := f,
    map_mul' :=
      fun x y =>
        by 
          apply TensorProduct.induction_on x
          ·
            simp 
          ·
            intro ab₁ c₁ 
            apply TensorProduct.induction_on y
            ·
              simp 
            ·
              intro ab₂ c₂ 
              apply TensorProduct.induction_on ab₁
              ·
                simp 
              ·
                intro a₁ b₁ 
                apply TensorProduct.induction_on ab₂
                ·
                  simp 
                ·
                  simp [w₁]
                ·
                  intro x₁ x₂ h₁ h₂ 
                  simp  at h₁ h₂ 
                  simp [mul_addₓ, add_tmul, h₁, h₂]
              ·
                intro x₁ x₂ h₁ h₂ 
                simp  at h₁ h₂ 
                simp [add_mulₓ, add_tmul, h₁, h₂]
            ·
              intro x₁ x₂ h₁ h₂ 
              simp [mul_addₓ, add_mulₓ, h₁, h₂]
          ·
            intro x₁ x₂ h₁ h₂ 
            simp [mul_addₓ, add_mulₓ, h₁, h₂],
    commutes' :=
      fun r =>
        by 
          simp [w₂] }

@[simp]
theorem alg_equiv_of_linear_equiv_triple_tensor_product_apply f w₁ w₂ x :
  (alg_equiv_of_linear_equiv_triple_tensor_product f w₁ w₂ : (A ⊗[R] B) ⊗[R] C ≃ₐ[R] D) x = f x :=
  rfl

end 

variable{R : Type u}[CommSemiringₓ R]

variable{A : Type v₁}[Semiringₓ A][Algebra R A]

variable{B : Type v₂}[Semiringₓ B][Algebra R B]

variable{C : Type v₃}[Semiringₓ C][Algebra R C]

variable{D : Type v₄}[Semiringₓ D][Algebra R D]

section 

variable(R A)

/--
The base ring is a left identity for the tensor product of algebra, up to algebra isomorphism.
-/
protected def lid : R ⊗[R] A ≃ₐ[R] A :=
  alg_equiv_of_linear_equiv_tensor_product (TensorProduct.lid R A)
    (by 
      simp [mul_smul])
    (by 
      simp [Algebra.smul_def])

@[simp]
theorem lid_tmul (r : R) (a : A) : (TensorProduct.lid R A : R ⊗ A → A) (r ⊗ₜ a) = r • a :=
  by 
    simp [TensorProduct.lid]

/--
The base ring is a right identity for the tensor product of algebra, up to algebra isomorphism.
-/
protected def rid : A ⊗[R] R ≃ₐ[R] A :=
  alg_equiv_of_linear_equiv_tensor_product (TensorProduct.rid R A)
    (by 
      simp [mul_smul])
    (by 
      simp [Algebra.smul_def])

@[simp]
theorem rid_tmul (r : R) (a : A) : (TensorProduct.rid R A : A ⊗ R → A) (a ⊗ₜ r) = r • a :=
  by 
    simp [TensorProduct.rid]

section 

variable(R A B)

/--
The tensor product of R-algebras is commutative, up to algebra isomorphism.
-/
protected def comm : A ⊗[R] B ≃ₐ[R] B ⊗[R] A :=
  alg_equiv_of_linear_equiv_tensor_product (TensorProduct.comm R A B)
    (by 
      simp )
    fun r =>
      by 
        trans r • (1 : B) ⊗ₜ[R] (1 : A)
        ·
          rw [←tmul_smul, Algebra.smul_def]
          simp 
        ·
          simp [Algebra.smul_def]

@[simp]
theorem comm_tmul (a : A) (b : B) : (TensorProduct.comm R A B : A ⊗[R] B → B ⊗[R] A) (a ⊗ₜ b) = b ⊗ₜ a :=
  by 
    simp [TensorProduct.comm]

end 

section 

variable{R A B C}

theorem assoc_aux_1 (a₁ a₂ : A) (b₁ b₂ : B) (c₁ c₂ : C) :
  (TensorProduct.assoc R A B C) (((a₁*a₂) ⊗ₜ[R] b₁*b₂) ⊗ₜ[R] c₁*c₂) =
    (TensorProduct.assoc R A B C) ((a₁ ⊗ₜ[R] b₁) ⊗ₜ[R] c₁)*(TensorProduct.assoc R A B C) ((a₂ ⊗ₜ[R] b₂) ⊗ₜ[R] c₂) :=
  rfl

theorem assoc_aux_2 (r : R) :
  (TensorProduct.assoc R A B C) (((algebraMap R A) r ⊗ₜ[R] 1) ⊗ₜ[R] 1) = (algebraMap R (A ⊗ (B ⊗ C))) r :=
  rfl

end 

variable{R A B C D}

/-- The tensor product of a pair of algebra morphisms. -/
def map (f : A →ₐ[R] B) (g : C →ₐ[R] D) : A ⊗[R] C →ₐ[R] B ⊗[R] D :=
  alg_hom_of_linear_map_tensor_product (TensorProduct.map f.to_linear_map g.to_linear_map)
    (by 
      simp )
    (by 
      simp [AlgHom.commutes])

@[simp]
theorem map_tmul (f : A →ₐ[R] B) (g : C →ₐ[R] D) (a : A) (c : C) : map f g (a ⊗ₜ c) = f a ⊗ₜ g c :=
  rfl

@[simp]
theorem map_comp_include_left (f : A →ₐ[R] B) (g : C →ₐ[R] D) : (map f g).comp include_left = include_left.comp f :=
  AlgHom.ext$
    by 
      simp 

@[simp]
theorem map_comp_include_right (f : A →ₐ[R] B) (g : C →ₐ[R] D) : (map f g).comp include_right = include_right.comp g :=
  AlgHom.ext$
    by 
      simp 

/--
Construct an isomorphism between tensor products of R-algebras
from isomorphisms between the tensor factors.
-/
def congr (f : A ≃ₐ[R] B) (g : C ≃ₐ[R] D) : A ⊗[R] C ≃ₐ[R] B ⊗[R] D :=
  AlgEquiv.ofAlgHom (map f g) (map f.symm g.symm)
    (ext$
      fun b d =>
        by 
          simp )
    (ext$
      fun a c =>
        by 
          simp )

@[simp]
theorem congr_apply (f : A ≃ₐ[R] B) (g : C ≃ₐ[R] D) x : congr f g x = (map (f : A →ₐ[R] B) (g : C →ₐ[R] D)) x :=
  rfl

@[simp]
theorem congr_symm_apply (f : A ≃ₐ[R] B) (g : C ≃ₐ[R] D) x :
  (congr f g).symm x = (map (f.symm : B →ₐ[R] A) (g.symm : D →ₐ[R] C)) x :=
  rfl

end 

end Monoidal

section 

variable{R A B S : Type _}[CommSemiringₓ R][Semiringₓ A][Semiringₓ B][CommSemiringₓ S]

variable[Algebra R A][Algebra R B][Algebra R S]

variable(f : A →ₐ[R] S)(g : B →ₐ[R] S)

variable(R)

/-- `algebra.lmul'` is an alg_hom on commutative rings. -/
def lmul' : S ⊗[R] S →ₐ[R] S :=
  alg_hom_of_linear_map_tensor_product (Algebra.lmul' R)
    (fun a₁ a₂ b₁ b₂ =>
      by 
        simp only [Algebra.lmul'_apply, mul_mul_mul_commₓ])
    fun r =>
      by 
        simp only [Algebra.lmul'_apply, _root_.mul_one]

variable{R}

theorem lmul'_to_linear_map : (lmul' R : _ →ₐ[R] S).toLinearMap = Algebra.lmul' R :=
  rfl

@[simp]
theorem lmul'_apply_tmul (a b : S) : lmul' R (a ⊗ₜ[R] b) = a*b :=
  lmul'_apply

@[simp]
theorem lmul'_comp_include_left : (lmul' R : _ →ₐ[R] S).comp include_left = AlgHom.id R S :=
  AlgHom.ext$ fun _ => (lmul'_apply_tmul _ _).trans (_root_.mul_one _)

@[simp]
theorem lmul'_comp_include_right : (lmul' R : _ →ₐ[R] S).comp include_right = AlgHom.id R S :=
  AlgHom.ext$ fun _ => (lmul'_apply_tmul _ _).trans (_root_.one_mul _)

/--
If `S` is commutative, for a pair of morphisms `f : A →ₐ[R] S`, `g : B →ₐ[R] S`,
We obtain a map `A ⊗[R] B →ₐ[R] S` that commutes with `f`, `g` via `a ⊗ b ↦ f(a) * g(b)`.
-/
def product_map : A ⊗[R] B →ₐ[R] S :=
  (lmul' R).comp (TensorProduct.map f g)

@[simp]
theorem product_map_apply_tmul (a : A) (b : B) : product_map f g (a ⊗ₜ b) = f a*g b :=
  by 
    unfold product_map lmul' 
    simp 

theorem product_map_left_apply (a : A) : product_map f g (include_left a) = f a :=
  by 
    simp 

@[simp]
theorem product_map_left : (product_map f g).comp include_left = f :=
  AlgHom.ext$
    by 
      simp 

theorem product_map_right_apply (b : B) : product_map f g (include_right b) = g b :=
  by 
    simp 

@[simp]
theorem product_map_right : (product_map f g).comp include_right = g :=
  AlgHom.ext$
    by 
      simp 

end 

end TensorProduct

end Algebra

