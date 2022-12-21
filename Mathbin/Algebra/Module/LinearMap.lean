/-
Copyright (c) 2020 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Nathaniel Thomas, Jeremy Avigad, Johannes Hölzl, Mario Carneiro, Anne Baanen,
  Frédéric Dupuis, Heather Macbeth

! This file was ported from Lean 3 source module algebra.module.linear_map
! leanprover-community/mathlib commit 0743cc5d9d86bcd1bba10f480e948a257d65056f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Hom.GroupAction
import Mathbin.Algebra.Module.Pi
import Mathbin.Algebra.Star.Basic
import Mathbin.Data.Set.Pointwise.Smul
import Mathbin.Algebra.Ring.CompTypeclasses

/-!
# (Semi)linear maps

In this file we define

* `linear_map σ M M₂`, `M →ₛₗ[σ] M₂` : a semilinear map between two `module`s. Here,
  `σ` is a `ring_hom` from `R` to `R₂` and an `f : M →ₛₗ[σ] M₂` satisfies
  `f (c • x) = (σ c) • (f x)`. We recover plain linear maps by choosing `σ` to be `ring_hom.id R`.
  This is denoted by `M →ₗ[R] M₂`. We also add the notation `M →ₗ⋆[R] M₂` for star-linear maps.

* `is_linear_map R f` : predicate saying that `f : M → M₂` is a linear map. (Note that this
  was not generalized to semilinear maps.)

We then provide `linear_map` with the following instances:

* `linear_map.add_comm_monoid` and `linear_map.add_comm_group`: the elementwise addition structures
  corresponding to addition in the codomain
* `linear_map.distrib_mul_action` and `linear_map.module`: the elementwise scalar action structures
  corresponding to applying the action in the codomain.
* `module.End.semiring` and `module.End.ring`: the (semi)ring of endomorphisms formed by taking the
  additive structure above with composition as multiplication.

## Implementation notes

To ensure that composition works smoothly for semilinear maps, we use the typeclasses
`ring_hom_comp_triple`, `ring_hom_inv_pair` and `ring_hom_surjective` from
`algebra/ring/comp_typeclasses`.

## Notation

* Throughout the file, we denote regular linear maps by `fₗ`, `gₗ`, etc, and semilinear maps
  by `f`, `g`, etc.

## TODO

* Parts of this file have not yet been generalized to semilinear maps (i.e. `compatible_smul`)

## Tags

linear map
-/


open Function

open BigOperators

universe u u' v w x y z

variable {R : Type _} {R₁ : Type _} {R₂ : Type _} {R₃ : Type _}

variable {k : Type _} {S : Type _} {S₃ : Type _} {T : Type _}

variable {M : Type _} {M₁ : Type _} {M₂ : Type _} {M₃ : Type _}

variable {N₁ : Type _} {N₂ : Type _} {N₃ : Type _} {ι : Type _}

/-- A map `f` between modules over a semiring is linear if it satisfies the two properties
`f (x + y) = f x + f y` and `f (c • x) = c • f x`. The predicate `is_linear_map R f` asserts this
property. A bundled version is available with `linear_map`, and should be favored over
`is_linear_map` most of the time. -/
structure IsLinearMap (R : Type u) {M : Type v} {M₂ : Type w} [Semiring R] [AddCommMonoid M]
  [AddCommMonoid M₂] [Module R M] [Module R M₂] (f : M → M₂) : Prop where
  map_add : ∀ x y, f (x + y) = f x + f y
  map_smul : ∀ (c : R) (x), f (c • x) = c • f x
#align is_linear_map IsLinearMap

section

/-- A map `f` between an `R`-module and an `S`-module over a ring homomorphism `σ : R →+* S`
is semilinear if it satisfies the two properties `f (x + y) = f x + f y` and
`f (c • x) = (σ c) • f x`. Elements of `linear_map σ M M₂` (available under the notation
`M →ₛₗ[σ] M₂`) are bundled versions of such maps. For plain linear maps (i.e. for which
`σ = ring_hom.id R`), the notation `M →ₗ[R] M₂` is available. An unbundled version of plain linear
maps is available with the predicate `is_linear_map`, but it should be avoided most of the time. -/
structure LinearMap {R : Type _} {S : Type _} [Semiring R] [Semiring S] (σ : R →+* S) (M : Type _)
  (M₂ : Type _) [AddCommMonoid M] [AddCommMonoid M₂] [Module R M] [Module S M₂] extends
  AddHom M M₂ where
  map_smul' : ∀ (r : R) (x : M), to_fun (r • x) = σ r • to_fun x
#align linear_map LinearMap

/-- The `add_hom` underlying a `linear_map`. -/
add_decl_doc LinearMap.toAddHom

-- mathport name: «expr →ₛₗ[ ] »
notation:25 M " →ₛₗ[" σ:25 "] " M₂:0 => LinearMap σ M M₂

-- mathport name: «expr →ₗ[ ] »
notation:25 M " →ₗ[" R:25 "] " M₂:0 => LinearMap (RingHom.id R) M M₂

-- mathport name: «expr →ₗ⋆[ ] »
notation:25 M " →ₗ⋆[" R:25 "] " M₂:0 => LinearMap (starRingEnd R) M M₂

/-- `semilinear_map_class F σ M M₂` asserts `F` is a type of bundled `σ`-semilinear maps `M → M₂`.

See also `linear_map_class F R M M₂` for the case where `σ` is the identity map on `R`.

A map `f` between an `R`-module and an `S`-module over a ring homomorphism `σ : R →+* S`
is semilinear if it satisfies the two properties `f (x + y) = f x + f y` and
`f (c • x) = (σ c) • f x`. -/
class SemilinearMapClass (F : Type _) {R S : outParam (Type _)} [Semiring R] [Semiring S]
  (σ : outParam <| R →+* S) (M M₂ : outParam (Type _)) [AddCommMonoid M] [AddCommMonoid M₂]
  [Module R M] [Module S M₂] extends AddHomClass F M M₂ where
  map_smulₛₗ : ∀ (f : F) (r : R) (x : M), f (r • x) = σ r • f x
#align semilinear_map_class SemilinearMapClass

end

-- `σ` becomes a metavariable but that's fine because it's an `out_param`
attribute [nolint dangerous_instance] SemilinearMapClass.toAddHomClass

export SemilinearMapClass (map_smulₛₗ)

attribute [simp] map_smulₛₗ

/-- `linear_map_class F R M M₂` asserts `F` is a type of bundled `R`-linear maps `M → M₂`.

This is an abbreviation for `semilinear_map_class F (ring_hom.id R) M M₂`.
-/
abbrev LinearMapClass (F : Type _) (R M M₂ : outParam (Type _)) [Semiring R] [AddCommMonoid M]
    [AddCommMonoid M₂] [Module R M] [Module R M₂] :=
  SemilinearMapClass F (RingHom.id R) M M₂
#align linear_map_class LinearMapClass

namespace SemilinearMapClass

variable (F : Type _)

variable [Semiring R] [Semiring S]

variable [AddCommMonoid M] [AddCommMonoid M₁] [AddCommMonoid M₂] [AddCommMonoid M₃]

variable [AddCommMonoid N₁] [AddCommMonoid N₂] [AddCommMonoid N₃]

variable [Module R M] [Module R M₂] [Module S M₃]

variable {σ : R →+* S}

-- `σ` is an `out_param` so it's not dangerous
@[nolint dangerous_instance]
instance (priority := 100) [SemilinearMapClass F σ M M₃] : AddMonoidHomClass F M M₃ :=
  { SemilinearMapClass.toAddHomClass F σ M M₃ with
    coe := fun f => (f : M → M₃)
    map_zero := fun f =>
      show f 0 = 0 by 
        rw [← zero_smul R (0 : M), map_smulₛₗ]
        simp }

-- `R` is an `out_param` so it's not dangerous
@[nolint dangerous_instance]
instance (priority := 100) [LinearMapClass F R M M₂] : DistribMulActionHomClass F R M M₂ :=
  { SemilinearMapClass.addMonoidHomClass F with
    coe := fun f => (f : M → M₂)
    map_smul := fun f c x => by rw [map_smulₛₗ, RingHom.id_apply] }

variable {F} (f : F) [i : SemilinearMapClass F σ M M₃]

include i

theorem map_smul_inv {σ' : S →+* R} [RingHomInvPair σ σ'] (c : S) (x : M) :
    c • f x = f (σ' c • x) := by simp
#align semilinear_map_class.map_smul_inv SemilinearMapClass.map_smul_inv

end SemilinearMapClass

namespace LinearMap

section AddCommMonoid

variable [Semiring R] [Semiring S]

section

variable [AddCommMonoid M] [AddCommMonoid M₁] [AddCommMonoid M₂] [AddCommMonoid M₃]

variable [AddCommMonoid N₁] [AddCommMonoid N₂] [AddCommMonoid N₃]

variable [Module R M] [Module R M₂] [Module S M₃]

variable {σ : R →+* S}

instance : SemilinearMapClass (M →ₛₗ[σ] M₃) σ M
      M₃ where 
  coe := LinearMap.toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
  map_add := LinearMap.map_add'
  map_smulₛₗ := LinearMap.map_smul'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly.
-/
instance : CoeFun (M →ₛₗ[σ] M₃) fun _ => M → M₃ :=
  ⟨fun f => f⟩

/-- The `distrib_mul_action_hom` underlying a `linear_map`. -/
def toDistribMulActionHom (f : M →ₗ[R] M₂) : DistribMulActionHom R M M₂ :=
  { f with map_zero' := show f 0 = 0 from map_zero f }
#align linear_map.to_distrib_mul_action_hom LinearMap.toDistribMulActionHom

@[simp]
theorem to_fun_eq_coe {f : M →ₛₗ[σ] M₃} : f.toFun = (f : M → M₃) :=
  rfl
#align linear_map.to_fun_eq_coe LinearMap.to_fun_eq_coe

@[ext]
theorem ext {f g : M →ₛₗ[σ] M₃} (h : ∀ x, f x = g x) : f = g :=
  FunLike.ext f g h
#align linear_map.ext LinearMap.ext

/-- Copy of a `linear_map` with a new `to_fun` equal to the old one. Useful to fix definitional
equalities. -/
protected def copy (f : M →ₛₗ[σ] M₃) (f' : M → M₃) (h : f' = ⇑f) :
    M →ₛₗ[σ] M₃ where 
  toFun := f'
  map_add' := h.symm ▸ f.map_add'
  map_smul' := h.symm ▸ f.map_smul'
#align linear_map.copy LinearMap.copy

@[simp]
theorem coe_copy (f : M →ₛₗ[σ] M₃) (f' : M → M₃) (h : f' = ⇑f) : ⇑(f.copy f' h) = f' :=
  rfl
#align linear_map.coe_copy LinearMap.coe_copy

theorem copy_eq (f : M →ₛₗ[σ] M₃) (f' : M → M₃) (h : f' = ⇑f) : f.copy f' h = f :=
  FunLike.ext' h
#align linear_map.copy_eq LinearMap.copy_eq

/-- See Note [custom simps projection]. -/
protected def Simps.apply {R S : Type _} [Semiring R] [Semiring S] (σ : R →+* S) (M M₃ : Type _)
    [AddCommMonoid M] [AddCommMonoid M₃] [Module R M] [Module S M₃] (f : M →ₛₗ[σ] M₃) : M → M₃ :=
  f
#align linear_map.simps.apply LinearMap.Simps.apply

initialize_simps_projections LinearMap (toFun → apply)

@[simp]
theorem coe_mk {σ : R →+* S} (f : M → M₃) (h₁ h₂) :
    ((LinearMap.mk f h₁ h₂ : M →ₛₗ[σ] M₃) : M → M₃) = f :=
  rfl
#align linear_map.coe_mk LinearMap.coe_mk

/-- Identity map as a `linear_map` -/
def id : M →ₗ[R] M :=
  { DistribMulActionHom.id R with toFun := id }
#align linear_map.id LinearMap.id

theorem id_apply (x : M) : @id R M _ _ _ x = x :=
  rfl
#align linear_map.id_apply LinearMap.id_apply

@[simp, norm_cast]
theorem id_coe : ((LinearMap.id : M →ₗ[R] M) : M → M) = _root_.id :=
  rfl
#align linear_map.id_coe LinearMap.id_coe

end

section

variable [AddCommMonoid M] [AddCommMonoid M₁] [AddCommMonoid M₂] [AddCommMonoid M₃]

variable [AddCommMonoid N₁] [AddCommMonoid N₂] [AddCommMonoid N₃]

variable [Module R M] [Module R M₂] [Module S M₃]

variable (σ : R →+* S)

variable (fₗ gₗ : M →ₗ[R] M₂) (f g : M →ₛₗ[σ] M₃)

theorem is_linear : IsLinearMap R fₗ :=
  ⟨fₗ.map_add', fₗ.map_smul'⟩
#align linear_map.is_linear LinearMap.is_linear

variable {fₗ gₗ f g σ}

theorem coe_injective : @Injective (M →ₛₗ[σ] M₃) (M → M₃) coeFn :=
  FunLike.coe_injective
#align linear_map.coe_injective LinearMap.coe_injective

protected theorem congr_arg {x x' : M} : x = x' → f x = f x' :=
  FunLike.congr_arg f
#align linear_map.congr_arg LinearMap.congr_arg

/-- If two linear maps are equal, they are equal at each point. -/
protected theorem congr_fun (h : f = g) (x : M) : f x = g x :=
  FunLike.congr_fun h x
#align linear_map.congr_fun LinearMap.congr_fun

theorem ext_iff : f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align linear_map.ext_iff LinearMap.ext_iff

@[simp]
theorem mk_coe (f : M →ₛₗ[σ] M₃) (h₁ h₂) : (LinearMap.mk f h₁ h₂ : M →ₛₗ[σ] M₃) = f :=
  ext fun _ => rfl
#align linear_map.mk_coe LinearMap.mk_coe

variable (fₗ gₗ f g)

protected theorem map_add (x y : M) : f (x + y) = f x + f y :=
  map_add f x y
#align linear_map.map_add LinearMap.map_add

protected theorem map_zero : f 0 = 0 :=
  map_zero f
#align linear_map.map_zero LinearMap.map_zero

-- TODO: `simp` isn't picking up `map_smulₛₗ` for `linear_map`s without specifying `map_smulₛₗ f`
@[simp]
protected theorem map_smulₛₗ (c : R) (x : M) : f (c • x) = σ c • f x :=
  map_smulₛₗ f c x
#align linear_map.map_smulₛₗ LinearMap.map_smulₛₗ

protected theorem map_smul (c : R) (x : M) : fₗ (c • x) = c • fₗ x :=
  map_smul fₗ c x
#align linear_map.map_smul LinearMap.map_smul

protected theorem map_smul_inv {σ' : S →+* R} [RingHomInvPair σ σ'] (c : S) (x : M) :
    c • f x = f (σ' c • x) := by simp
#align linear_map.map_smul_inv LinearMap.map_smul_inv

-- TODO: generalize to `zero_hom_class`
@[simp]
theorem map_eq_zero_iff (h : Function.Injective f) {x : M} : f x = 0 ↔ x = 0 :=
  ⟨fun w => by 
    apply h
    simp [w], fun w => by 
    subst w
    simp⟩
#align linear_map.map_eq_zero_iff LinearMap.map_eq_zero_iff

section Pointwise

open Pointwise

variable (M M₃ σ) {F : Type _} (h : F)

@[simp]
theorem image_smul_setₛₗ [SemilinearMapClass F σ M M₃] (c : R) (s : Set M) :
    h '' (c • s) = σ c • h '' s := by 
  apply Set.Subset.antisymm
  · rintro x ⟨y, ⟨z, zs, rfl⟩, rfl⟩
    exact ⟨h z, Set.mem_image_of_mem _ zs, (map_smulₛₗ _ _ _).symm⟩
  · rintro x ⟨y, ⟨z, hz, rfl⟩, rfl⟩
    exact (Set.mem_image _ _ _).2 ⟨c • z, Set.smul_mem_smul_set hz, map_smulₛₗ _ _ _⟩
#align image_smul_setₛₗ image_smul_setₛₗ

theorem preimage_smul_setₛₗ [SemilinearMapClass F σ M M₃] {c : R} (hc : IsUnit c) (s : Set M₃) :
    h ⁻¹' (σ c • s) = c • h ⁻¹' s := by
  apply Set.Subset.antisymm
  · rintro x ⟨y, ys, hy⟩
    refine' ⟨(hc.unit.inv : R) • x, _, _⟩
    ·
      simp only [← hy, smul_smul, Set.mem_preimage, Units.inv_eq_val_inv, map_smulₛₗ h, ← map_mul,
        IsUnit.val_inv_mul, one_smul, map_one, ys]
    · simp only [smul_smul, IsUnit.mul_val_inv, one_smul, Units.inv_eq_val_inv]
  · rintro x ⟨y, hy, rfl⟩
    refine' ⟨h y, hy, by simp only [RingHom.id_apply, map_smulₛₗ h]⟩
#align preimage_smul_setₛₗ preimage_smul_setₛₗ

variable (R M₂)

theorem image_smul_set [LinearMapClass F R M M₂] (c : R) (s : Set M) : h '' (c • s) = c • h '' s :=
  image_smul_setₛₗ _ _ _ h c s
#align image_smul_set image_smul_set

theorem preimage_smul_set [LinearMapClass F R M M₂] {c : R} (hc : IsUnit c) (s : Set M₂) :
    h ⁻¹' (c • s) = c • h ⁻¹' s :=
  preimage_smul_setₛₗ _ _ _ h hc s
#align preimage_smul_set preimage_smul_set

end Pointwise

variable (M M₂)

/-- A typeclass for `has_smul` structures which can be moved through a `linear_map`.
This typeclass is generated automatically from a `is_scalar_tower` instance, but exists so that
we can also add an instance for `add_comm_group.int_module`, allowing `z •` to be moved even if
`R` does not support negation.
-/
class CompatibleSmul (R S : Type _) [Semiring S] [HasSmul R M] [Module S M] [HasSmul R M₂]
  [Module S M₂] where
  map_smul : ∀ (fₗ : M →ₗ[S] M₂) (c : R) (x : M), fₗ (c • x) = c • fₗ x
#align linear_map.compatible_smul LinearMap.CompatibleSmul

variable {M M₂}

instance (priority := 100) IsScalarTower.compatibleSmul {R S : Type _} [Semiring S] [HasSmul R S]
    [HasSmul R M] [Module S M] [IsScalarTower R S M] [HasSmul R M₂] [Module S M₂]
    [IsScalarTower R S M₂] : CompatibleSmul M M₂ R S :=
  ⟨fun fₗ c x => by rw [← smul_one_smul S c x, ← smul_one_smul S c (fₗ x), map_smul]⟩
#align linear_map.is_scalar_tower.compatible_smul LinearMap.IsScalarTower.compatibleSmul

@[simp]
theorem map_smul_of_tower {R S : Type _} [Semiring S] [HasSmul R M] [Module S M] [HasSmul R M₂]
    [Module S M₂] [CompatibleSmul M M₂ R S] (fₗ : M →ₗ[S] M₂) (c : R) (x : M) :
    fₗ (c • x) = c • fₗ x :=
  CompatibleSmul.map_smul fₗ c x
#align linear_map.map_smul_of_tower LinearMap.map_smul_of_tower

/-- convert a linear map to an additive map -/
def toAddMonoidHom : M →+ M₃ where 
  toFun := f
  map_zero' := f.map_zero
  map_add' := f.map_add
#align linear_map.to_add_monoid_hom LinearMap.toAddMonoidHom

@[simp]
theorem to_add_monoid_hom_coe : ⇑f.toAddMonoidHom = f :=
  rfl
#align linear_map.to_add_monoid_hom_coe LinearMap.to_add_monoid_hom_coe

section RestrictScalars

variable (R) [Module S M] [Module S M₂] [CompatibleSmul M M₂ R S]

/-- If `M` and `M₂` are both `R`-modules and `S`-modules and `R`-module structures
are defined by an action of `R` on `S` (formally, we have two scalar towers), then any `S`-linear
map from `M` to `M₂` is `R`-linear.

See also `linear_map.map_smul_of_tower`. -/
def restrictScalars (fₗ : M →ₗ[S] M₂) :
    M →ₗ[R] M₂ where 
  toFun := fₗ
  map_add' := fₗ.map_add
  map_smul' := fₗ.map_smul_of_tower
#align linear_map.restrict_scalars LinearMap.restrictScalars

@[simp]
theorem coe_restrict_scalars (fₗ : M →ₗ[S] M₂) : ⇑(restrictScalars R fₗ) = fₗ :=
  rfl
#align linear_map.coe_restrict_scalars LinearMap.coe_restrict_scalars

theorem restrict_scalars_apply (fₗ : M →ₗ[S] M₂) (x) : restrictScalars R fₗ x = fₗ x :=
  rfl
#align linear_map.restrict_scalars_apply LinearMap.restrict_scalars_apply

theorem restrict_scalars_injective :
    Function.Injective (restrictScalars R : (M →ₗ[S] M₂) → M →ₗ[R] M₂) := fun fₗ gₗ h =>
  ext (LinearMap.congr_fun h : _)
#align linear_map.restrict_scalars_injective LinearMap.restrict_scalars_injective

@[simp]
theorem restrict_scalars_inj (fₗ gₗ : M →ₗ[S] M₂) :
    fₗ.restrictScalars R = gₗ.restrictScalars R ↔ fₗ = gₗ :=
  (restrict_scalars_injective R).eq_iff
#align linear_map.restrict_scalars_inj LinearMap.restrict_scalars_inj

end RestrictScalars

variable {R}

@[simp]
theorem map_sum {ι} {t : Finset ι} {g : ι → M} : f (∑ i in t, g i) = ∑ i in t, f (g i) :=
  f.toAddMonoidHom.map_sum _ _
#align linear_map.map_sum LinearMap.map_sum

theorem to_add_monoid_hom_injective :
    Function.Injective (toAddMonoidHom : (M →ₛₗ[σ] M₃) → M →+ M₃) := fun f g h =>
  ext <| AddMonoidHom.congr_fun h
#align linear_map.to_add_monoid_hom_injective LinearMap.to_add_monoid_hom_injective

/-- If two `σ`-linear maps from `R` are equal on `1`, then they are equal. -/
@[ext]
theorem ext_ring {f g : R →ₛₗ[σ] M₃} (h : f 1 = g 1) : f = g :=
  ext fun x => by rw [← mul_one x, ← smul_eq_mul, f.map_smulₛₗ, g.map_smulₛₗ, h]
#align linear_map.ext_ring LinearMap.ext_ring

theorem ext_ring_iff {σ : R →+* R} {f g : R →ₛₗ[σ] M} : f = g ↔ f 1 = g 1 :=
  ⟨fun h => h ▸ rfl, ext_ring⟩
#align linear_map.ext_ring_iff LinearMap.ext_ring_iff

@[ext]
theorem ext_ring_op {σ : Rᵐᵒᵖ →+* S} {f g : R →ₛₗ[σ] M₃} (h : f 1 = g 1) : f = g :=
  ext fun x => by rw [← one_mul x, ← op_smul_eq_mul, f.map_smulₛₗ, g.map_smulₛₗ, h]
#align linear_map.ext_ring_op LinearMap.ext_ring_op

end

/-- Interpret a `ring_hom` `f` as an `f`-semilinear map. -/
@[simps]
def RingHom.toSemilinearMap (f : R →+* S) : R →ₛₗ[f] S :=
  { f with 
    toFun := f
    map_smul' := f.map_mul }
#align ring_hom.to_semilinear_map RingHom.toSemilinearMap

section

variable [Semiring R₁] [Semiring R₂] [Semiring R₃]

variable [AddCommMonoid M] [AddCommMonoid M₁] [AddCommMonoid M₂] [AddCommMonoid M₃]

variable {module_M₁ : Module R₁ M₁} {module_M₂ : Module R₂ M₂} {module_M₃ : Module R₃ M₃}

variable {σ₁₂ : R₁ →+* R₂} {σ₂₃ : R₂ →+* R₃} {σ₁₃ : R₁ →+* R₃}

variable [RingHomCompTriple σ₁₂ σ₂₃ σ₁₃]

variable (f : M₂ →ₛₗ[σ₂₃] M₃) (g : M₁ →ₛₗ[σ₁₂] M₂)

include module_M₁ module_M₂ module_M₃

/-- Composition of two linear maps is a linear map -/
def comp : M₁ →ₛₗ[σ₁₃] M₃ where 
  toFun := f ∘ g
  map_add' := by simp only [map_add, forall_const, eq_self_iff_true, comp_app]
  map_smul' r x := by rw [comp_app, map_smulₛₗ, map_smulₛₗ, RingHomCompTriple.comp_apply]
#align linear_map.comp LinearMap.comp

omit module_M₁ module_M₂ module_M₃

-- mathport name: «expr ∘ₗ »
infixr:80 " ∘ₗ " =>
  @LinearMap.comp _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ (RingHom.id _) (RingHom.id _) (RingHom.id _)
    RingHomCompTriple.ids

include σ₁₃

theorem comp_apply (x : M₁) : f.comp g x = f (g x) :=
  rfl
#align linear_map.comp_apply LinearMap.comp_apply

omit σ₁₃

include σ₁₃

@[simp, norm_cast]
theorem coe_comp : (f.comp g : M₁ → M₃) = f ∘ g :=
  rfl
#align linear_map.coe_comp LinearMap.coe_comp

omit σ₁₃

@[simp]
theorem comp_id : f.comp id = f :=
  LinearMap.ext fun x => rfl
#align linear_map.comp_id LinearMap.comp_id

@[simp]
theorem id_comp : id.comp f = f :=
  LinearMap.ext fun x => rfl
#align linear_map.id_comp LinearMap.id_comp

variable {f g} {f' : M₂ →ₛₗ[σ₂₃] M₃} {g' : M₁ →ₛₗ[σ₁₂] M₂}

include σ₁₃

theorem cancel_right (hg : Function.Surjective g) : f.comp g = f'.comp g ↔ f = f' :=
  ⟨fun h => ext <| hg.forall.2 (ext_iff.1 h), fun h => h ▸ rfl⟩
#align linear_map.cancel_right LinearMap.cancel_right

theorem cancel_left (hf : Function.Injective f) : f.comp g = f.comp g' ↔ g = g' :=
  ⟨fun h => ext fun x => hf <| by rw [← comp_apply, h, comp_apply], fun h => h ▸ rfl⟩
#align linear_map.cancel_left LinearMap.cancel_left

omit σ₁₃

end

variable [AddCommMonoid M] [AddCommMonoid M₁] [AddCommMonoid M₂] [AddCommMonoid M₃]

/-- If a function `g` is a left and right inverse of a linear map `f`, then `g` is linear itself. -/
def inverse [Module R M] [Module S M₂] {σ : R →+* S} {σ' : S →+* R} [RingHomInvPair σ σ']
    (f : M →ₛₗ[σ] M₂) (g : M₂ → M) (h₁ : LeftInverse g f) (h₂ : RightInverse g f) : M₂ →ₛₗ[σ'] M :=
  by
  dsimp [left_inverse, Function.RightInverse] at h₁ h₂ <;>
    exact
      { toFun := g
        map_add' := fun x y => by rw [← h₁ (g (x + y)), ← h₁ (g x + g y)] <;> simp [h₂]
        map_smul' := fun a b => by 
          rw [← h₁ (g (a • b)), ← h₁ (σ' a • g b)]
          simp [h₂] }
#align linear_map.inverse LinearMap.inverse

end AddCommMonoid

section AddCommGroup

variable [Semiring R] [Semiring S] [AddCommGroup M] [AddCommGroup M₂]

variable {module_M : Module R M} {module_M₂ : Module S M₂} {σ : R →+* S}

variable (f : M →ₛₗ[σ] M₂)

protected theorem map_neg (x : M) : f (-x) = -f x :=
  map_neg f x
#align linear_map.map_neg LinearMap.map_neg

protected theorem map_sub (x y : M) : f (x - y) = f x - f y :=
  map_sub f x y
#align linear_map.map_sub LinearMap.map_sub

instance CompatibleSmul.intModule {S : Type _} [Semiring S] [Module S M] [Module S M₂] :
    CompatibleSmul M M₂ ℤ S :=
  ⟨fun fₗ c x => by 
    induction c using Int.induction_on
    case hz => simp
    case hp n ih => simp [add_smul, ih]
    case hn n ih => simp [sub_smul, ih]⟩
#align linear_map.compatible_smul.int_module LinearMap.CompatibleSmul.intModule

instance CompatibleSmul.units {R S : Type _} [Monoid R] [MulAction R M] [MulAction R M₂]
    [Semiring S] [Module S M] [Module S M₂] [CompatibleSmul M M₂ R S] : CompatibleSmul M M₂ Rˣ S :=
  ⟨fun fₗ c x => (CompatibleSmul.map_smul fₗ (c : R) x : _)⟩
#align linear_map.compatible_smul.units LinearMap.CompatibleSmul.units

end AddCommGroup

end LinearMap

namespace Module

/-- `g : R →+* S` is `R`-linear when the module structure on `S` is `module.comp_hom S g` . -/
@[simps]
def compHom.toLinearMap {R S : Type _} [Semiring R] [Semiring S] (g : R →+* S) :
    haveI := comp_hom S g
    R →ₗ[R] S where 
  toFun := (g : R → S)
  map_add' := g.map_add
  map_smul' := g.map_mul
#align module.comp_hom.to_linear_map Module.compHom.toLinearMap

end Module

namespace DistribMulActionHom

variable [Semiring R] [AddCommMonoid M] [AddCommMonoid M₂] [Module R M] [Module R M₂]

/-- A `distrib_mul_action_hom` between two modules is a linear map. -/
def toLinearMap (fₗ : M →+[R] M₂) : M →ₗ[R] M₂ :=
  { fₗ with }
#align distrib_mul_action_hom.to_linear_map DistribMulActionHom.toLinearMap

instance : Coe (M →+[R] M₂) (M →ₗ[R] M₂) :=
  ⟨toLinearMap⟩

@[simp]
theorem to_linear_map_eq_coe (f : M →+[R] M₂) : f.toLinearMap = ↑f :=
  rfl
#align distrib_mul_action_hom.to_linear_map_eq_coe DistribMulActionHom.to_linear_map_eq_coe

@[simp, norm_cast]
theorem coe_to_linear_map (f : M →+[R] M₂) : ((f : M →ₗ[R] M₂) : M → M₂) = f :=
  rfl
#align distrib_mul_action_hom.coe_to_linear_map DistribMulActionHom.coe_to_linear_map

theorem to_linear_map_injective {f g : M →+[R] M₂} (h : (f : M →ₗ[R] M₂) = (g : M →ₗ[R] M₂)) :
    f = g := by 
  ext m
  exact LinearMap.congr_fun h m
#align distrib_mul_action_hom.to_linear_map_injective DistribMulActionHom.to_linear_map_injective

end DistribMulActionHom

namespace IsLinearMap

section AddCommMonoid

variable [Semiring R] [AddCommMonoid M] [AddCommMonoid M₂]

variable [Module R M] [Module R M₂]

include R

/-- Convert an `is_linear_map` predicate to a `linear_map` -/
def mk' (f : M → M₂) (H : IsLinearMap R f) :
    M →ₗ[R] M₂ where 
  toFun := f
  map_add' := H.1
  map_smul' := H.2
#align is_linear_map.mk' IsLinearMap.mk'

@[simp]
theorem mk'_apply {f : M → M₂} (H : IsLinearMap R f) (x : M) : mk' f H x = f x :=
  rfl
#align is_linear_map.mk'_apply IsLinearMap.mk'_apply

theorem is_linear_map_smul {R M : Type _} [CommSemiring R] [AddCommMonoid M] [Module R M] (c : R) :
    IsLinearMap R fun z : M => c • z := by
  refine' IsLinearMap.mk (smul_add c) _
  intro _ _
  simp only [smul_smul, mul_comm]
#align is_linear_map.is_linear_map_smul IsLinearMap.is_linear_map_smul

theorem is_linear_map_smul' {R M : Type _} [Semiring R] [AddCommMonoid M] [Module R M] (a : M) :
    IsLinearMap R fun c : R => c • a :=
  IsLinearMap.mk (fun x y => add_smul x y a) fun x y => mul_smul x y a
#align is_linear_map.is_linear_map_smul' IsLinearMap.is_linear_map_smul'

variable {f : M → M₂} (lin : IsLinearMap R f)

include M M₂ lin

theorem map_zero : f (0 : M) = (0 : M₂) :=
  (lin.mk' f).map_zero
#align is_linear_map.map_zero IsLinearMap.map_zero

end AddCommMonoid

section AddCommGroup

variable [Semiring R] [AddCommGroup M] [AddCommGroup M₂]

variable [Module R M] [Module R M₂]

include R

theorem is_linear_map_neg : IsLinearMap R fun z : M => -z :=
  IsLinearMap.mk neg_add fun x y => (smul_neg x y).symm
#align is_linear_map.is_linear_map_neg IsLinearMap.is_linear_map_neg

variable {f : M → M₂} (lin : IsLinearMap R f)

include M M₂ lin

theorem map_neg (x : M) : f (-x) = -f x :=
  (lin.mk' f).map_neg x
#align is_linear_map.map_neg IsLinearMap.map_neg

theorem map_sub (x y) : f (x - y) = f x - f y :=
  (lin.mk' f).map_sub x y
#align is_linear_map.map_sub IsLinearMap.map_sub

end AddCommGroup

end IsLinearMap

/-- Linear endomorphisms of a module, with associated ring structure
`module.End.semiring` and algebra structure `module.End.algebra`. -/
abbrev Module.EndCat (R : Type u) (M : Type v) [Semiring R] [AddCommMonoid M] [Module R M] :=
  M →ₗ[R] M
#align module.End Module.EndCat

/-- Reinterpret an additive homomorphism as a `ℕ`-linear map. -/
def AddMonoidHom.toNatLinearMap [AddCommMonoid M] [AddCommMonoid M₂] (f : M →+ M₂) :
    M →ₗ[ℕ] M₂ where 
  toFun := f
  map_add' := f.map_add
  map_smul' := map_nsmul f
#align add_monoid_hom.to_nat_linear_map AddMonoidHom.toNatLinearMap

theorem AddMonoidHom.to_nat_linear_map_injective [AddCommMonoid M] [AddCommMonoid M₂] :
    Function.Injective (@AddMonoidHom.toNatLinearMap M M₂ _ _) := by
  intro f g h
  ext
  exact LinearMap.congr_fun h x
#align add_monoid_hom.to_nat_linear_map_injective AddMonoidHom.to_nat_linear_map_injective

/-- Reinterpret an additive homomorphism as a `ℤ`-linear map. -/
def AddMonoidHom.toIntLinearMap [AddCommGroup M] [AddCommGroup M₂] (f : M →+ M₂) :
    M →ₗ[ℤ] M₂ where 
  toFun := f
  map_add' := f.map_add
  map_smul' := map_zsmul f
#align add_monoid_hom.to_int_linear_map AddMonoidHom.toIntLinearMap

theorem AddMonoidHom.to_int_linear_map_injective [AddCommGroup M] [AddCommGroup M₂] :
    Function.Injective (@AddMonoidHom.toIntLinearMap M M₂ _ _) := by
  intro f g h
  ext
  exact LinearMap.congr_fun h x
#align add_monoid_hom.to_int_linear_map_injective AddMonoidHom.to_int_linear_map_injective

@[simp]
theorem AddMonoidHom.coe_to_int_linear_map [AddCommGroup M] [AddCommGroup M₂] (f : M →+ M₂) :
    ⇑f.toIntLinearMap = f :=
  rfl
#align add_monoid_hom.coe_to_int_linear_map AddMonoidHom.coe_to_int_linear_map

/-- Reinterpret an additive homomorphism as a `ℚ`-linear map. -/
def AddMonoidHom.toRatLinearMap [AddCommGroup M] [Module ℚ M] [AddCommGroup M₂] [Module ℚ M₂]
    (f : M →+ M₂) : M →ₗ[ℚ] M₂ :=
  { f with map_smul' := map_rat_smul f }
#align add_monoid_hom.to_rat_linear_map AddMonoidHom.toRatLinearMap

theorem AddMonoidHom.to_rat_linear_map_injective [AddCommGroup M] [Module ℚ M] [AddCommGroup M₂]
    [Module ℚ M₂] : Function.Injective (@AddMonoidHom.toRatLinearMap M M₂ _ _ _ _) := by
  intro f g h
  ext
  exact LinearMap.congr_fun h x
#align add_monoid_hom.to_rat_linear_map_injective AddMonoidHom.to_rat_linear_map_injective

@[simp]
theorem AddMonoidHom.coe_to_rat_linear_map [AddCommGroup M] [Module ℚ M] [AddCommGroup M₂]
    [Module ℚ M₂] (f : M →+ M₂) : ⇑f.toRatLinearMap = f :=
  rfl
#align add_monoid_hom.coe_to_rat_linear_map AddMonoidHom.coe_to_rat_linear_map

namespace LinearMap

section HasSmul

variable [Semiring R] [Semiring R₂] [Semiring R₃]

variable [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃]

variable [Module R M] [Module R₂ M₂] [Module R₃ M₃]

variable {σ₁₂ : R →+* R₂} {σ₂₃ : R₂ →+* R₃} {σ₁₃ : R →+* R₃} [RingHomCompTriple σ₁₂ σ₂₃ σ₁₃]

variable [Monoid S] [DistribMulAction S M₂] [SMulCommClass R₂ S M₂]

variable [Monoid S₃] [DistribMulAction S₃ M₃] [SMulCommClass R₃ S₃ M₃]

variable [Monoid T] [DistribMulAction T M₂] [SMulCommClass R₂ T M₂]

instance : HasSmul S (M →ₛₗ[σ₁₂] M₂) :=
  ⟨fun a f =>
    { toFun := a • f
      map_add' := fun x y => by simp only [Pi.smul_apply, f.map_add, smul_add]
      map_smul' := fun c x => by simp [Pi.smul_apply, smul_comm (σ₁₂ c)] }⟩

@[simp]
theorem smul_apply (a : S) (f : M →ₛₗ[σ₁₂] M₂) (x : M) : (a • f) x = a • f x :=
  rfl
#align linear_map.smul_apply LinearMap.smul_apply

theorem coe_smul (a : S) (f : M →ₛₗ[σ₁₂] M₂) : ⇑(a • f) = a • f :=
  rfl
#align linear_map.coe_smul LinearMap.coe_smul

instance [SMulCommClass S T M₂] : SMulCommClass S T (M →ₛₗ[σ₁₂] M₂) :=
  ⟨fun a b f => ext fun x => smul_comm _ _ _⟩

-- example application of this instance: if S -> T -> R are homomorphisms of commutative rings and
-- M and M₂ are R-modules then the S-module and T-module structures on Hom_R(M,M₂) are compatible.
instance [HasSmul S T] [IsScalarTower S T M₂] :
    IsScalarTower S T (M →ₛₗ[σ₁₂] M₂) where smul_assoc _ _ _ := ext fun _ => smul_assoc _ _ _

instance [DistribMulAction Sᵐᵒᵖ M₂] [SMulCommClass R₂ Sᵐᵒᵖ M₂] [IsCentralScalar S M₂] :
    IsCentralScalar S (M →ₛₗ[σ₁₂] M₂) where op_smul_eq_smul a b := ext fun x => op_smul_eq_smul _ _

end HasSmul

/-! ### Arithmetic on the codomain -/


section Arithmetic

variable [Semiring R₁] [Semiring R₂] [Semiring R₃]

variable [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃]

variable [AddCommGroup N₁] [AddCommGroup N₂] [AddCommGroup N₃]

variable [Module R₁ M] [Module R₂ M₂] [Module R₃ M₃]

variable [Module R₁ N₁] [Module R₂ N₂] [Module R₃ N₃]

variable {σ₁₂ : R₁ →+* R₂} {σ₂₃ : R₂ →+* R₃} {σ₁₃ : R₁ →+* R₃} [RingHomCompTriple σ₁₂ σ₂₃ σ₁₃]

/-- The constant 0 map is linear. -/
instance : Zero (M →ₛₗ[σ₁₂] M₂) :=
  ⟨{  toFun := 0
      map_add' := by simp
      map_smul' := by simp }⟩

@[simp]
theorem zero_apply (x : M) : (0 : M →ₛₗ[σ₁₂] M₂) x = 0 :=
  rfl
#align linear_map.zero_apply LinearMap.zero_apply

@[simp]
theorem comp_zero (g : M₂ →ₛₗ[σ₂₃] M₃) : (g.comp (0 : M →ₛₗ[σ₁₂] M₂) : M →ₛₗ[σ₁₃] M₃) = 0 :=
  ext fun c => by rw [comp_apply, zero_apply, zero_apply, g.map_zero]
#align linear_map.comp_zero LinearMap.comp_zero

@[simp]
theorem zero_comp (f : M →ₛₗ[σ₁₂] M₂) : ((0 : M₂ →ₛₗ[σ₂₃] M₃).comp f : M →ₛₗ[σ₁₃] M₃) = 0 :=
  rfl
#align linear_map.zero_comp LinearMap.zero_comp

instance : Inhabited (M →ₛₗ[σ₁₂] M₂) :=
  ⟨0⟩

@[simp]
theorem default_def : (default : M →ₛₗ[σ₁₂] M₂) = 0 :=
  rfl
#align linear_map.default_def LinearMap.default_def

/-- The sum of two linear maps is linear. -/
instance : Add (M →ₛₗ[σ₁₂] M₂) :=
  ⟨fun f g =>
    { toFun := f + g
      map_add' := by simp [add_comm, add_left_comm]
      map_smul' := by simp [smul_add] }⟩

@[simp]
theorem add_apply (f g : M →ₛₗ[σ₁₂] M₂) (x : M) : (f + g) x = f x + g x :=
  rfl
#align linear_map.add_apply LinearMap.add_apply

theorem add_comp (f : M →ₛₗ[σ₁₂] M₂) (g h : M₂ →ₛₗ[σ₂₃] M₃) :
    ((h + g).comp f : M →ₛₗ[σ₁₃] M₃) = h.comp f + g.comp f :=
  rfl
#align linear_map.add_comp LinearMap.add_comp

theorem comp_add (f g : M →ₛₗ[σ₁₂] M₂) (h : M₂ →ₛₗ[σ₂₃] M₃) :
    (h.comp (f + g) : M →ₛₗ[σ₁₃] M₃) = h.comp f + h.comp g :=
  ext fun _ => h.map_add _ _
#align linear_map.comp_add LinearMap.comp_add

/-- The type of linear maps is an additive monoid. -/
instance : AddCommMonoid (M →ₛₗ[σ₁₂] M₂) :=
  FunLike.coe_injective.AddCommMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl

/-- The negation of a linear map is linear. -/
instance : Neg (M →ₛₗ[σ₁₂] N₂) :=
  ⟨fun f =>
    { toFun := -f
      map_add' := by simp [add_comm]
      map_smul' := by simp }⟩

@[simp]
theorem neg_apply (f : M →ₛₗ[σ₁₂] N₂) (x : M) : (-f) x = -f x :=
  rfl
#align linear_map.neg_apply LinearMap.neg_apply

include σ₁₃

@[simp]
theorem neg_comp (f : M →ₛₗ[σ₁₂] M₂) (g : M₂ →ₛₗ[σ₂₃] N₃) : (-g).comp f = -g.comp f :=
  rfl
#align linear_map.neg_comp LinearMap.neg_comp

@[simp]
theorem comp_neg (f : M →ₛₗ[σ₁₂] N₂) (g : N₂ →ₛₗ[σ₂₃] N₃) : g.comp (-f) = -g.comp f :=
  ext fun _ => g.map_neg _
#align linear_map.comp_neg LinearMap.comp_neg

omit σ₁₃

/-- The negation of a linear map is linear. -/
instance : Sub (M →ₛₗ[σ₁₂] N₂) :=
  ⟨fun f g =>
    { toFun := f - g
      map_add' := fun x y => by simp only [Pi.sub_apply, map_add, add_sub_add_comm]
      map_smul' := fun r x => by simp [Pi.sub_apply, map_smul, smul_sub] }⟩

@[simp]
theorem sub_apply (f g : M →ₛₗ[σ₁₂] N₂) (x : M) : (f - g) x = f x - g x :=
  rfl
#align linear_map.sub_apply LinearMap.sub_apply

include σ₁₃

theorem sub_comp (f : M →ₛₗ[σ₁₂] M₂) (g h : M₂ →ₛₗ[σ₂₃] N₃) :
    (g - h).comp f = g.comp f - h.comp f :=
  rfl
#align linear_map.sub_comp LinearMap.sub_comp

theorem comp_sub (f g : M →ₛₗ[σ₁₂] N₂) (h : N₂ →ₛₗ[σ₂₃] N₃) :
    h.comp (g - f) = h.comp g - h.comp f :=
  ext fun _ => h.map_sub _ _
#align linear_map.comp_sub LinearMap.comp_sub

omit σ₁₃

/-- The type of linear maps is an additive group. -/
instance : AddCommGroup (M →ₛₗ[σ₁₂] N₂) :=
  FunLike.coe_injective.AddCommGroup _ rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ _ => rfl

end Arithmetic

section Actions

variable [Semiring R] [Semiring R₂] [Semiring R₃]

variable [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃]

variable [Module R M] [Module R₂ M₂] [Module R₃ M₃]

variable {σ₁₂ : R →+* R₂} {σ₂₃ : R₂ →+* R₃} {σ₁₃ : R →+* R₃} [RingHomCompTriple σ₁₂ σ₂₃ σ₁₃]

section HasSmul

variable [Monoid S] [DistribMulAction S M₂] [SMulCommClass R₂ S M₂]

variable [Monoid S₃] [DistribMulAction S₃ M₃] [SMulCommClass R₃ S₃ M₃]

variable [Monoid T] [DistribMulAction T M₂] [SMulCommClass R₂ T M₂]

instance :
    DistribMulAction S
      (M →ₛₗ[σ₁₂] M₂) where 
  one_smul f := ext fun _ => one_smul _ _
  mul_smul c c' f := ext fun _ => mul_smul _ _ _
  smul_add c f g := ext fun x => smul_add _ _ _
  smul_zero c := ext fun x => smul_zero _

include σ₁₃

theorem smul_comp (a : S₃) (g : M₂ →ₛₗ[σ₂₃] M₃) (f : M →ₛₗ[σ₁₂] M₂) :
    (a • g).comp f = a • g.comp f :=
  rfl
#align linear_map.smul_comp LinearMap.smul_comp

omit σ₁₃

-- TODO: generalize this to semilinear maps
theorem comp_smul [Module R M₂] [Module R M₃] [SMulCommClass R S M₂] [DistribMulAction S M₃]
    [SMulCommClass R S M₃] [CompatibleSmul M₃ M₂ S R] (g : M₃ →ₗ[R] M₂) (a : S) (f : M →ₗ[R] M₃) :
    g.comp (a • f) = a • g.comp f :=
  ext fun x => g.map_smul_of_tower _ _
#align linear_map.comp_smul LinearMap.comp_smul

end HasSmul

section Module

variable [Semiring S] [Module S M₂] [SMulCommClass R₂ S M₂]

instance :
    Module S (M →ₛₗ[σ₁₂]
        M₂) where 
  add_smul a b f := ext fun x => add_smul _ _ _
  zero_smul f := ext fun x => zero_smul _ _

instance [NoZeroSmulDivisors S M₂] : NoZeroSmulDivisors S (M →ₛₗ[σ₁₂] M₂) :=
  coe_injective.NoZeroSmulDivisors _ rfl coe_smul

end Module

end Actions

/-!
### Monoid structure of endomorphisms

Lemmas about `pow` such as `linear_map.pow_apply` appear in later files.
-/


section Endomorphisms

variable [Semiring R] [AddCommMonoid M] [AddCommGroup N₁] [Module R M] [Module R N₁]

instance : One (Module.EndCat R M) :=
  ⟨LinearMap.id⟩

instance : Mul (Module.EndCat R M) :=
  ⟨LinearMap.comp⟩

theorem one_eq_id : (1 : Module.EndCat R M) = id :=
  rfl
#align linear_map.one_eq_id LinearMap.one_eq_id

theorem mul_eq_comp (f g : Module.EndCat R M) : f * g = f.comp g :=
  rfl
#align linear_map.mul_eq_comp LinearMap.mul_eq_comp

@[simp]
theorem one_apply (x : M) : (1 : Module.EndCat R M) x = x :=
  rfl
#align linear_map.one_apply LinearMap.one_apply

@[simp]
theorem mul_apply (f g : Module.EndCat R M) (x : M) : (f * g) x = f (g x) :=
  rfl
#align linear_map.mul_apply LinearMap.mul_apply

theorem coe_one : ⇑(1 : Module.EndCat R M) = _root_.id :=
  rfl
#align linear_map.coe_one LinearMap.coe_one

theorem coe_mul (f g : Module.EndCat R M) : ⇑(f * g) = f ∘ g :=
  rfl
#align linear_map.coe_mul LinearMap.coe_mul

instance Module.EndCat.monoid :
    Monoid (Module.EndCat R M) where 
  mul := (· * ·)
  one := (1 : M →ₗ[R] M)
  mul_assoc f g h := LinearMap.ext fun x => rfl
  mul_one := comp_id
  one_mul := id_comp
#align module.End.monoid Module.EndCat.monoid

instance Module.EndCat.semiring : Semiring (Module.EndCat R M) :=
  { AddMonoidWithOne.unary, Module.EndCat.monoid, LinearMap.addCommMonoid with
    mul := (· * ·)
    one := (1 : M →ₗ[R] M)
    zero := 0
    add := (· + ·)
    mul_zero := comp_zero
    zero_mul := zero_comp
    left_distrib := fun f g h => comp_add _ _ _
    right_distrib := fun f g h => add_comp _ _ _
    natCast := fun n => n • 1
    nat_cast_zero := AddMonoid.nsmul_zero _
    nat_cast_succ := fun n => (AddMonoid.nsmul_succ n 1).trans (add_comm _ _) }
#align module.End.semiring Module.EndCat.semiring

/-- See also `module.End.nat_cast_def`. -/
@[simp]
theorem Module.EndCat.nat_cast_apply (n : ℕ) (m : M) : (↑n : Module.EndCat R M) m = n • m :=
  rfl
#align module.End.nat_cast_apply Module.EndCat.nat_cast_apply

instance Module.EndCat.ring : Ring (Module.EndCat R N₁) :=
  { Module.EndCat.semiring, LinearMap.addCommGroup with
    intCast := fun z => z • 1
    int_cast_of_nat := of_nat_zsmul _
    int_cast_neg_succ_of_nat := negSucc_zsmul _ }
#align module.End.ring Module.EndCat.ring

/-- See also `module.End.int_cast_def`. -/
@[simp]
theorem Module.EndCat.int_cast_apply (z : ℤ) (m : N₁) : (↑z : Module.EndCat R N₁) m = z • m :=
  rfl
#align module.End.int_cast_apply Module.EndCat.int_cast_apply

section

variable [Monoid S] [DistribMulAction S M] [SMulCommClass R S M]

instance Module.EndCat.is_scalar_tower : IsScalarTower S (Module.EndCat R M) (Module.EndCat R M) :=
  ⟨smul_comp⟩
#align module.End.is_scalar_tower Module.EndCat.is_scalar_tower

instance Module.EndCat.smul_comm_class [HasSmul S R] [IsScalarTower S R M] :
    SMulCommClass S (Module.EndCat R M) (Module.EndCat R M) :=
  ⟨fun s _ _ => (comp_smul _ s _).symm⟩
#align module.End.smul_comm_class Module.EndCat.smul_comm_class

instance Module.EndCat.smul_comm_class' [HasSmul S R] [IsScalarTower S R M] :
    SMulCommClass (Module.EndCat R M) S (Module.EndCat R M) :=
  SMulCommClass.symm _ _ _
#align module.End.smul_comm_class' Module.EndCat.smul_comm_class'

end

/-! ### Action by a module endomorphism. -/


/-- The tautological action by `module.End R M` (aka `M →ₗ[R] M`) on `M`.

This generalizes `function.End.apply_mul_action`. -/
instance applyModule :
    Module (Module.EndCat R M) M where 
  smul := (· <| ·)
  smul_zero := LinearMap.map_zero
  smul_add := LinearMap.map_add
  add_smul := LinearMap.add_apply
  zero_smul := (LinearMap.zero_apply : ∀ m, (0 : M →ₗ[R] M) m = 0)
  one_smul _ := rfl
  mul_smul _ _ _ := rfl
#align linear_map.apply_module LinearMap.applyModule

@[simp]
protected theorem smul_def (f : Module.EndCat R M) (a : M) : f • a = f a :=
  rfl
#align linear_map.smul_def LinearMap.smul_def

/-- `linear_map.apply_module` is faithful. -/
instance apply_has_faithful_smul : FaithfulSMul (Module.EndCat R M) M :=
  ⟨fun _ _ => LinearMap.ext⟩
#align linear_map.apply_has_faithful_smul LinearMap.apply_has_faithful_smul

instance apply_smul_comm_class :
    SMulCommClass R (Module.EndCat R M) M where smul_comm r e m := (e.map_smul r m).symm
#align linear_map.apply_smul_comm_class LinearMap.apply_smul_comm_class

instance apply_smul_comm_class' :
    SMulCommClass (Module.EndCat R M) R M where smul_comm := LinearMap.map_smul
#align linear_map.apply_smul_comm_class' LinearMap.apply_smul_comm_class'

instance apply_is_scalar_tower {R M : Type _} [CommSemiring R] [AddCommMonoid M] [Module R M] :
    IsScalarTower R (Module.EndCat R M) M :=
  ⟨fun t f m => rfl⟩
#align linear_map.apply_is_scalar_tower LinearMap.apply_is_scalar_tower

end Endomorphisms

end LinearMap

/-! ### Actions as module endomorphisms -/


namespace DistribMulAction

variable (R M) [Semiring R] [AddCommMonoid M] [Module R M]

variable [Monoid S] [DistribMulAction S M] [SMulCommClass S R M]

/-- Each element of the monoid defines a linear map.

This is a stronger version of `distrib_mul_action.to_add_monoid_hom`. -/
@[simps]
def toLinearMap (s : S) : M →ₗ[R]
      M where 
  toFun := HasSmul.smul s
  map_add' := smul_add s
  map_smul' a b := smul_comm _ _ _
#align distrib_mul_action.to_linear_map DistribMulAction.toLinearMap

/-- Each element of the monoid defines a module endomorphism.

This is a stronger version of `distrib_mul_action.to_add_monoid_End`. -/
@[simps]
def toModuleEnd : S →* Module.EndCat R
        M where 
  toFun := toLinearMap R M
  map_one' := LinearMap.ext <| one_smul _
  map_mul' a b := LinearMap.ext <| mul_smul _ _
#align distrib_mul_action.to_module_End DistribMulAction.toModuleEnd

end DistribMulAction

namespace Module

variable (R M) [Semiring R] [AddCommMonoid M] [Module R M]

variable [Semiring S] [Module S M] [SMulCommClass S R M]

/-- Each element of the semiring defines a module endomorphism.

This is a stronger version of `distrib_mul_action.to_module_End`. -/
@[simps]
def toModuleEnd : S →+* Module.EndCat R M :=
  { DistribMulAction.toModuleEnd R M with
    toFun := DistribMulAction.toLinearMap R M
    map_zero' := LinearMap.ext <| zero_smul _
    map_add' := fun f g => LinearMap.ext <| add_smul _ _ }
#align module.to_module_End Module.toModuleEnd

/-- The canonical (semi)ring isomorphism from `Rᵐᵒᵖ` to `module.End R R` induced by the right
multiplication. -/
@[simps]
def moduleEndSelf : Rᵐᵒᵖ ≃+* Module.EndCat R R :=
  { Module.toModuleEnd R R with 
    toFun := DistribMulAction.toLinearMap R R
    invFun := fun f => MulOpposite.op (f 1)
    left_inv := mul_one
    right_inv := fun f => LinearMap.ext_ring <| one_mul _ }
#align module.module_End_self Module.moduleEndSelf

/-- The canonical (semi)ring isomorphism from `R` to `module.End Rᵐᵒᵖ R` induced by the left
multiplication. -/
@[simps]
def moduleEndSelfOp : R ≃+* Module.EndCat Rᵐᵒᵖ R :=
  { Module.toModuleEnd _ _ with 
    toFun := DistribMulAction.toLinearMap _ _
    invFun := fun f => f 1
    left_inv := mul_one
    right_inv := fun f => LinearMap.ext_ring_op <| mul_one _ }
#align module.module_End_self_op Module.moduleEndSelfOp

theorem EndCat.nat_cast_def (n : ℕ) [AddCommMonoid N₁] [Module R N₁] :
    (↑n : Module.EndCat R N₁) = Module.toModuleEnd R N₁ n :=
  rfl
#align module.End.nat_cast_def Module.EndCat.nat_cast_def

theorem EndCat.int_cast_def (z : ℤ) [AddCommGroup N₁] [Module R N₁] :
    (↑z : Module.EndCat R N₁) = Module.toModuleEnd R N₁ z :=
  rfl
#align module.End.int_cast_def Module.EndCat.int_cast_def

end Module

