/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module algebra.hom.non_unital_alg
! leanprover-community/mathlib commit 6cb77a8eaff0ddd100e87b1591c6d3ad319514ff
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Algebra.Hom

/-!
# Morphisms of non-unital algebras

This file defines morphisms between two types, each of which carries:
 * an addition,
 * an additive zero,
 * a multiplication,
 * a scalar action.

The multiplications are not assumed to be associative or unital, or even to be compatible with the
scalar actions. In a typical application, the operations will satisfy compatibility conditions
making them into algebras (albeit possibly non-associative and/or non-unital) but such conditions
are not required to make this definition.

This notion of morphism should be useful for any category of non-unital algebras. The motivating
application at the time it was introduced was to be able to state the adjunction property for
magma algebras. These are non-unital, non-associative algebras obtained by applying the
group-algebra construction except where we take a type carrying just `has_mul` instead of `group`.

For a plausible future application, one could take the non-unital algebra of compactly-supported
functions on a non-compact topological space. A proper map between a pair of such spaces
(contravariantly) induces a morphism between their algebras of compactly-supported functions which
will be a `non_unital_alg_hom`.

TODO: add `non_unital_alg_equiv` when needed.

## Main definitions

  * `non_unital_alg_hom`
  * `alg_hom.to_non_unital_alg_hom`

## Tags

non-unital, algebra, morphism
-/


universe u v w w₁ w₂ w₃

variable (R : Type u) (A : Type v) (B : Type w) (C : Type w₁)

/-- A morphism respecting addition, multiplication, and scalar multiplication. When these arise from
algebra structures, this is the same as a not-necessarily-unital morphism of algebras. -/
structure NonUnitalAlgHom [Monoid R] [NonUnitalNonAssocSemiring A] [DistribMulAction R A]
  [NonUnitalNonAssocSemiring B] [DistribMulAction R B] extends A →+[R] B, A →ₙ* B
#align non_unital_alg_hom NonUnitalAlgHom

-- mathport name: «expr →ₙₐ »
infixr:25 " →ₙₐ " => NonUnitalAlgHom _

-- mathport name: «expr →ₙₐ[ ] »
notation:25 A " →ₙₐ[" R "] " B => NonUnitalAlgHom R A B

attribute [nolint doc_blame] NonUnitalAlgHom.toDistribMulActionHom

attribute [nolint doc_blame] NonUnitalAlgHom.toMulHom

/-- `non_unital_alg_hom_class F R A B` asserts `F` is a type of bundled algebra homomorphisms
from `A` to `B`.  -/
class NonUnitalAlgHomClass (F : Type _) (R : outParam (Type _)) (A : outParam (Type _))
  (B : outParam (Type _)) [Monoid R] [NonUnitalNonAssocSemiring A] [NonUnitalNonAssocSemiring B]
  [DistribMulAction R A] [DistribMulAction R B] extends DistribMulActionHomClass F R A B,
  MulHomClass F A B
#align non_unital_alg_hom_class NonUnitalAlgHomClass

-- `R` becomes a metavariable but that's fine because it's an `out_param`
attribute [nolint dangerous_instance] NonUnitalAlgHomClass.toMulHomClass

namespace NonUnitalAlgHomClass

-- `R` becomes a metavariable but that's fine because it's an `out_param`
-- See note [lower instance priority]
@[nolint dangerous_instance]
instance (priority := 100) NonUnitalAlgHomClass.toNonUnitalRingHomClass {F R A B : Type _}
    [Monoid R] [NonUnitalNonAssocSemiring A] [DistribMulAction R A] [NonUnitalNonAssocSemiring B]
    [DistribMulAction R B] [NonUnitalAlgHomClass F R A B] : NonUnitalRingHomClass F A B :=
  { ‹NonUnitalAlgHomClass F R A B› with coe := coeFn }
#align
  non_unital_alg_hom_class.non_unital_alg_hom_class.to_non_unital_ring_hom_class NonUnitalAlgHomClass.NonUnitalAlgHomClass.toNonUnitalRingHomClass

variable [Semiring R] [NonUnitalNonAssocSemiring A] [Module R A] [NonUnitalNonAssocSemiring B]
  [Module R B]

-- see Note [lower instance priority]
instance (priority := 100) {F : Type _} [NonUnitalAlgHomClass F R A B] : LinearMapClass F R A B :=
  { ‹NonUnitalAlgHomClass F R A B› with map_smulₛₗ := DistribMulActionHomClass.map_smul }

instance {F R A B : Type _} [Monoid R] [NonUnitalNonAssocSemiring A] [DistribMulAction R A]
    [NonUnitalNonAssocSemiring B] [DistribMulAction R B] [NonUnitalAlgHomClass F R A B] :
    CoeTC F (A →ₙₐ[R] B)
    where coe f :=
    { (f : A →ₙ+* B) with
      toFun := f
      map_smul' := map_smul f }

end NonUnitalAlgHomClass

namespace NonUnitalAlgHom

variable {R A B C} [Monoid R]

variable [NonUnitalNonAssocSemiring A] [DistribMulAction R A]

variable [NonUnitalNonAssocSemiring B] [DistribMulAction R B]

variable [NonUnitalNonAssocSemiring C] [DistribMulAction R C]

/-- see Note [function coercion] -/
instance : CoeFun (A →ₙₐ[R] B) fun _ => A → B :=
  ⟨toFun⟩

@[simp]
theorem to_fun_eq_coe (f : A →ₙₐ[R] B) : f.toFun = ⇑f :=
  rfl
#align non_unital_alg_hom.to_fun_eq_coe NonUnitalAlgHom.to_fun_eq_coe

initialize_simps_projections NonUnitalAlgHom (toFun → apply)

@[simp, protected]
theorem coe_coe {F : Type _} [NonUnitalAlgHomClass F R A B] (f : F) : ⇑(f : A →ₙₐ[R] B) = f :=
  rfl
#align non_unital_alg_hom.coe_coe NonUnitalAlgHom.coe_coe

theorem coe_injective : @Function.Injective (A →ₙₐ[R] B) (A → B) coeFn := by
  rintro ⟨f, _⟩ ⟨g, _⟩ ⟨h⟩ <;> congr
#align non_unital_alg_hom.coe_injective NonUnitalAlgHom.coe_injective

instance : NonUnitalAlgHomClass (A →ₙₐ[R] B) R A B
    where
  coe := toFun
  coe_injective' := coe_injective
  map_smul f := f.map_smul'
  map_add f := f.map_add'
  map_zero f := f.map_zero'
  map_mul f := f.map_mul'

@[ext]
theorem ext {f g : A →ₙₐ[R] B} (h : ∀ x, f x = g x) : f = g :=
  coe_injective <| funext h
#align non_unital_alg_hom.ext NonUnitalAlgHom.ext

theorem ext_iff {f g : A →ₙₐ[R] B} : f = g ↔ ∀ x, f x = g x :=
  ⟨by
    rintro rfl x
    rfl, ext⟩
#align non_unital_alg_hom.ext_iff NonUnitalAlgHom.ext_iff

theorem congr_fun {f g : A →ₙₐ[R] B} (h : f = g) (x : A) : f x = g x :=
  h ▸ rfl
#align non_unital_alg_hom.congr_fun NonUnitalAlgHom.congr_fun

@[simp]
theorem coe_mk (f : A → B) (h₁ h₂ h₃ h₄) : ((⟨f, h₁, h₂, h₃, h₄⟩ : A →ₙₐ[R] B) : A → B) = f :=
  rfl
#align non_unital_alg_hom.coe_mk NonUnitalAlgHom.coe_mk

@[simp]
theorem mk_coe (f : A →ₙₐ[R] B) (h₁ h₂ h₃ h₄) : (⟨f, h₁, h₂, h₃, h₄⟩ : A →ₙₐ[R] B) = f :=
  by
  ext
  rfl
#align non_unital_alg_hom.mk_coe NonUnitalAlgHom.mk_coe

instance : Coe (A →ₙₐ[R] B) (A →+[R] B) :=
  ⟨toDistribMulActionHom⟩

instance : Coe (A →ₙₐ[R] B) (A →ₙ* B) :=
  ⟨toMulHom⟩

@[simp]
theorem to_distrib_mul_action_hom_eq_coe (f : A →ₙₐ[R] B) : f.toDistribMulActionHom = ↑f :=
  rfl
#align
  non_unital_alg_hom.to_distrib_mul_action_hom_eq_coe NonUnitalAlgHom.to_distrib_mul_action_hom_eq_coe

@[simp]
theorem to_mul_hom_eq_coe (f : A →ₙₐ[R] B) : f.toMulHom = ↑f :=
  rfl
#align non_unital_alg_hom.to_mul_hom_eq_coe NonUnitalAlgHom.to_mul_hom_eq_coe

@[simp, norm_cast]
theorem coe_to_distrib_mul_action_hom (f : A →ₙₐ[R] B) : ((f : A →+[R] B) : A → B) = f :=
  rfl
#align
  non_unital_alg_hom.coe_to_distrib_mul_action_hom NonUnitalAlgHom.coe_to_distrib_mul_action_hom

@[simp, norm_cast]
theorem coe_to_mul_hom (f : A →ₙₐ[R] B) : ((f : A →ₙ* B) : A → B) = f :=
  rfl
#align non_unital_alg_hom.coe_to_mul_hom NonUnitalAlgHom.coe_to_mul_hom

theorem to_distrib_mul_action_hom_injective {f g : A →ₙₐ[R] B}
    (h : (f : A →+[R] B) = (g : A →+[R] B)) : f = g :=
  by
  ext a
  exact DistribMulActionHom.congr_fun h a
#align
  non_unital_alg_hom.to_distrib_mul_action_hom_injective NonUnitalAlgHom.to_distrib_mul_action_hom_injective

theorem to_mul_hom_injective {f g : A →ₙₐ[R] B} (h : (f : A →ₙ* B) = (g : A →ₙ* B)) : f = g :=
  by
  ext a
  exact MulHom.congr_fun h a
#align non_unital_alg_hom.to_mul_hom_injective NonUnitalAlgHom.to_mul_hom_injective

@[norm_cast]
theorem coe_distrib_mul_action_hom_mk (f : A →ₙₐ[R] B) (h₁ h₂ h₃ h₄) :
    ((⟨f, h₁, h₂, h₃, h₄⟩ : A →ₙₐ[R] B) : A →+[R] B) = ⟨f, h₁, h₂, h₃⟩ :=
  by
  ext
  rfl
#align
  non_unital_alg_hom.coe_distrib_mul_action_hom_mk NonUnitalAlgHom.coe_distrib_mul_action_hom_mk

@[norm_cast]
theorem coe_mul_hom_mk (f : A →ₙₐ[R] B) (h₁ h₂ h₃ h₄) :
    ((⟨f, h₁, h₂, h₃, h₄⟩ : A →ₙₐ[R] B) : A →ₙ* B) = ⟨f, h₄⟩ :=
  by
  ext
  rfl
#align non_unital_alg_hom.coe_mul_hom_mk NonUnitalAlgHom.coe_mul_hom_mk

@[simp]
protected theorem map_smul (f : A →ₙₐ[R] B) (c : R) (x : A) : f (c • x) = c • f x :=
  map_smul _ _ _
#align non_unital_alg_hom.map_smul NonUnitalAlgHom.map_smul

@[simp]
protected theorem map_add (f : A →ₙₐ[R] B) (x y : A) : f (x + y) = f x + f y :=
  map_add _ _ _
#align non_unital_alg_hom.map_add NonUnitalAlgHom.map_add

@[simp]
protected theorem map_mul (f : A →ₙₐ[R] B) (x y : A) : f (x * y) = f x * f y :=
  map_mul _ _ _
#align non_unital_alg_hom.map_mul NonUnitalAlgHom.map_mul

@[simp]
protected theorem map_zero (f : A →ₙₐ[R] B) : f 0 = 0 :=
  map_zero _
#align non_unital_alg_hom.map_zero NonUnitalAlgHom.map_zero

instance : Zero (A →ₙₐ[R] B) :=
  ⟨{ (0 : A →+[R] B) with map_mul' := by simp }⟩

instance : One (A →ₙₐ[R] A) :=
  ⟨{ (1 : A →+[R] A) with map_mul' := by simp }⟩

@[simp]
theorem coe_zero : ((0 : A →ₙₐ[R] B) : A → B) = 0 :=
  rfl
#align non_unital_alg_hom.coe_zero NonUnitalAlgHom.coe_zero

@[simp]
theorem coe_one : ((1 : A →ₙₐ[R] A) : A → A) = id :=
  rfl
#align non_unital_alg_hom.coe_one NonUnitalAlgHom.coe_one

theorem zero_apply (a : A) : (0 : A →ₙₐ[R] B) a = 0 :=
  rfl
#align non_unital_alg_hom.zero_apply NonUnitalAlgHom.zero_apply

theorem one_apply (a : A) : (1 : A →ₙₐ[R] A) a = a :=
  rfl
#align non_unital_alg_hom.one_apply NonUnitalAlgHom.one_apply

instance : Inhabited (A →ₙₐ[R] B) :=
  ⟨0⟩

/-- The composition of morphisms is a morphism. -/
def comp (f : B →ₙₐ[R] C) (g : A →ₙₐ[R] B) : A →ₙₐ[R] C :=
  { (f : B →ₙ* C).comp (g : A →ₙ* B), (f : B →+[R] C).comp (g : A →+[R] B) with }
#align non_unital_alg_hom.comp NonUnitalAlgHom.comp

@[simp, norm_cast]
theorem coe_comp (f : B →ₙₐ[R] C) (g : A →ₙₐ[R] B) :
    (f.comp g : A → C) = (f : B → C) ∘ (g : A → B) :=
  rfl
#align non_unital_alg_hom.coe_comp NonUnitalAlgHom.coe_comp

theorem comp_apply (f : B →ₙₐ[R] C) (g : A →ₙₐ[R] B) (x : A) : f.comp g x = f (g x) :=
  rfl
#align non_unital_alg_hom.comp_apply NonUnitalAlgHom.comp_apply

/-- The inverse of a bijective morphism is a morphism. -/
def inverse (f : A →ₙₐ[R] B) (g : B → A) (h₁ : Function.LeftInverse g f)
    (h₂ : Function.RightInverse g f) : B →ₙₐ[R] A :=
  { (f : A →ₙ* B).inverse g h₁ h₂, (f : A →+[R] B).inverse g h₁ h₂ with }
#align non_unital_alg_hom.inverse NonUnitalAlgHom.inverse

@[simp]
theorem coe_inverse (f : A →ₙₐ[R] B) (g : B → A) (h₁ : Function.LeftInverse g f)
    (h₂ : Function.RightInverse g f) : (inverse f g h₁ h₂ : B → A) = g :=
  rfl
#align non_unital_alg_hom.coe_inverse NonUnitalAlgHom.coe_inverse

/-! ### Operations on the product type

Note that much of this is copied from [`linear_algebra/prod`](../../linear_algebra/prod). -/


section Prod

variable (R A B)

/-- The first projection of a product is a non-unital alg_hom. -/
@[simps]
def fst : A × B →ₙₐ[R] A where
  toFun := Prod.fst
  map_zero' := rfl
  map_add' x y := rfl
  map_smul' x y := rfl
  map_mul' x y := rfl
#align non_unital_alg_hom.fst NonUnitalAlgHom.fst

/-- The second projection of a product is a non-unital alg_hom. -/
@[simps]
def snd : A × B →ₙₐ[R] B where
  toFun := Prod.snd
  map_zero' := rfl
  map_add' x y := rfl
  map_smul' x y := rfl
  map_mul' x y := rfl
#align non_unital_alg_hom.snd NonUnitalAlgHom.snd

variable {R A B}

/-- The prod of two morphisms is a morphism. -/
@[simps]
def prod (f : A →ₙₐ[R] B) (g : A →ₙₐ[R] C) : A →ₙₐ[R] B × C
    where
  toFun := Pi.prod f g
  map_zero' := by simp only [Pi.prod, Prod.zero_eq_mk, map_zero]
  map_add' x y := by simp only [Pi.prod, Prod.mk_add_mk, map_add]
  map_mul' x y := by simp only [Pi.prod, Prod.mk_mul_mk, map_mul]
  map_smul' c x := by simp only [Pi.prod, Prod.smul_mk, map_smul, RingHom.id_apply]
#align non_unital_alg_hom.prod NonUnitalAlgHom.prod

theorem coe_prod (f : A →ₙₐ[R] B) (g : A →ₙₐ[R] C) : ⇑(f.Prod g) = Pi.prod f g :=
  rfl
#align non_unital_alg_hom.coe_prod NonUnitalAlgHom.coe_prod

@[simp]
theorem fst_prod (f : A →ₙₐ[R] B) (g : A →ₙₐ[R] C) : (fst R B C).comp (prod f g) = f := by
  ext <;> rfl
#align non_unital_alg_hom.fst_prod NonUnitalAlgHom.fst_prod

@[simp]
theorem snd_prod (f : A →ₙₐ[R] B) (g : A →ₙₐ[R] C) : (snd R B C).comp (prod f g) = g := by
  ext <;> rfl
#align non_unital_alg_hom.snd_prod NonUnitalAlgHom.snd_prod

@[simp]
theorem prod_fst_snd : prod (fst R A B) (snd R A B) = 1 :=
  coe_injective Pi.prod_fst_snd
#align non_unital_alg_hom.prod_fst_snd NonUnitalAlgHom.prod_fst_snd

/-- Taking the product of two maps with the same domain is equivalent to taking the product of
their codomains. -/
@[simps]
def prodEquiv : (A →ₙₐ[R] B) × (A →ₙₐ[R] C) ≃ (A →ₙₐ[R] B × C)
    where
  toFun f := f.1.Prod f.2
  invFun f := ((fst _ _ _).comp f, (snd _ _ _).comp f)
  left_inv f := by ext <;> rfl
  right_inv f := by ext <;> rfl
#align non_unital_alg_hom.prod_equiv NonUnitalAlgHom.prodEquiv

variable (R A B)

/-- The left injection into a product is a non-unital algebra homomorphism. -/
def inl : A →ₙₐ[R] A × B :=
  prod 1 0
#align non_unital_alg_hom.inl NonUnitalAlgHom.inl

/-- The right injection into a product is a non-unital algebra homomorphism. -/
def inr : B →ₙₐ[R] A × B :=
  prod 0 1
#align non_unital_alg_hom.inr NonUnitalAlgHom.inr

variable {R A B}

@[simp]
theorem coe_inl : (inl R A B : A → A × B) = fun x => (x, 0) :=
  rfl
#align non_unital_alg_hom.coe_inl NonUnitalAlgHom.coe_inl

theorem inl_apply (x : A) : inl R A B x = (x, 0) :=
  rfl
#align non_unital_alg_hom.inl_apply NonUnitalAlgHom.inl_apply

@[simp]
theorem coe_inr : (inr R A B : B → A × B) = Prod.mk 0 :=
  rfl
#align non_unital_alg_hom.coe_inr NonUnitalAlgHom.coe_inr

theorem inr_apply (x : B) : inr R A B x = (0, x) :=
  rfl
#align non_unital_alg_hom.inr_apply NonUnitalAlgHom.inr_apply

end Prod

end NonUnitalAlgHom

/-! ### Interaction with `alg_hom` -/


namespace AlgHom

variable {R A B} [CommSemiring R] [Semiring A] [Semiring B] [Algebra R A] [Algebra R B]

-- see Note [lower instance priority]
instance (priority := 100) {F : Type _} [AlgHomClass F R A B] : NonUnitalAlgHomClass F R A B :=
  { ‹AlgHomClass F R A B› with map_smul := map_smul }

/-- A unital morphism of algebras is a `non_unital_alg_hom`. -/
def toNonUnitalAlgHom (f : A →ₐ[R] B) : A →ₙₐ[R] B :=
  { f with map_smul' := map_smul f }
#align alg_hom.to_non_unital_alg_hom AlgHom.toNonUnitalAlgHom

instance NonUnitalAlgHom.hasCoe : Coe (A →ₐ[R] B) (A →ₙₐ[R] B) :=
  ⟨toNonUnitalAlgHom⟩
#align alg_hom.non_unital_alg_hom.has_coe AlgHom.NonUnitalAlgHom.hasCoe

@[simp]
theorem to_non_unital_alg_hom_eq_coe (f : A →ₐ[R] B) : f.toNonUnitalAlgHom = f :=
  rfl
#align alg_hom.to_non_unital_alg_hom_eq_coe AlgHom.to_non_unital_alg_hom_eq_coe

@[simp, norm_cast]
theorem coe_to_non_unital_alg_hom (f : A →ₐ[R] B) : ((f : A →ₙₐ[R] B) : A → B) = f :=
  rfl
#align alg_hom.coe_to_non_unital_alg_hom AlgHom.coe_to_non_unital_alg_hom

end AlgHom

