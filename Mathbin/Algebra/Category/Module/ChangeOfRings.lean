/-
Copyright (c) 2022 Jujian Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jujian Zhang
-/
import Mathbin.Algebra.Category.Module.Basic
import Mathbin.RingTheory.TensorProduct

/-!
# Change Of Rings

## Main definitions

* `category_theory.Module.restrict_scalars`: given rings `R, S` and a ring homomorphism `R ⟶ S`,
  then `restrict_scalars : Module S ⥤ Module R` is defined by `M ↦ M` where `M : S-module` is seen
  as `R-module` by `r • m := f r • m` and `S`-linear map `l : M ⟶ M'` is `R`-linear as well.

* `category_theory.Module.extend_scalars`: given **commutative** rings `R, S` and ring homomorphism
  `f : R ⟶ S`, then `extend_scalars : Module R ⥤ Module S` is defined by `M ↦ S ⨂ M` where the
  module structure is defined by `s • (s' ⊗ m) := (s * s') ⊗ m` and `R`-linear map `l : M ⟶ M'`
  is sent to `S`-linear map `s ⊗ m ↦ s ⊗ l m : S ⨂ M ⟶ S ⨂ M'`.

## List of notations
Let `R, S` be rings and `f : R →+* S`
* if `M` is an `R`-module, `s : S` and `m : M`, then `s ⊗ₜ[R, f] m` is the pure tensor
  `s ⊗ m : S ⊗[R, f] M`.
-/


namespace CategoryTheory.Module

universe v u₁ u₂

namespace RestrictScalars

variable {R : Type u₁} {S : Type u₂} [Ringₓ R] [Ringₓ S] (f : R →+* S)

variable (M : ModuleCat.{v} S)

/-- Any `S`-module M is also an `R`-module via a ring homomorphism `f : R ⟶ S` by defining
    `r • m := f r • m` (`module.comp_hom`). This is called restriction of scalars. -/
def obj' : ModuleCat R where
  Carrier := M
  isModule := Module.compHom M f

/-- Given an `S`-linear map `g : M → M'` between `S`-modules, `g` is also `R`-linear between `M` and
`M'` by means of restriction of scalars.
-/
def map' {M M' : ModuleCat.{v} S} (g : M ⟶ M') : obj' f M ⟶ obj' f M' :=
  { g with map_smul' := fun r => g.map_smul (f r) }

end RestrictScalars

/-- The restriction of scalars operation is functorial. For any `f : R →+* S` a ring homomorphism,
* an `S`-module `M` can be considered as `R`-module by `r • m = f r • m`
* an `S`-linear map is also `R`-linear
-/
def restrictScalars {R : Type u₁} {S : Type u₂} [Ringₓ R] [Ringₓ S] (f : R →+* S) :
    ModuleCat.{v} S ⥤ ModuleCat.{v} R where
  obj := RestrictScalars.obj' f
  map := fun _ _ => RestrictScalars.map' f
  map_id' := fun _ => LinearMap.ext fun m => rfl
  map_comp' := fun _ _ _ g h => LinearMap.ext fun m => rfl

@[simp]
theorem restrictScalars.map_apply {R : Type u₁} {S : Type u₂} [Ringₓ R] [Ringₓ S] (f : R →+* S) {M M' : ModuleCat.{v} S}
    (g : M ⟶ M') (x) : (restrictScalars f).map g x = g x :=
  rfl

@[simp]
theorem restrictScalars.smul_def {R : Type u₁} {S : Type u₂} [Ringₓ R] [Ringₓ S] (f : R →+* S) {M : ModuleCat.{v} S}
    (r : R) (m : (restrictScalars f).obj M) : r • m = (f r • m : M) :=
  rfl

theorem restrictScalars.smul_def' {R : Type u₁} {S : Type u₂} [Ringₓ R] [Ringₓ S] (f : R →+* S) {M : ModuleCat.{v} S}
    (r : R) (m : M) : (r • m : (restrictScalars f).obj M) = (f r • m : M) :=
  rfl

instance (priority := 100) smul_comm_class_mk {R : Type u₁} {S : Type u₂} [Ringₓ R] [CommRingₓ S] (f : R →+* S)
    (M : Type v) [AddCommGroupₓ M] [Module S M] :
    @SmulCommClass R S M (RestrictScalars.obj' f (ModuleCat.mk M)).isModule.toHasSmul
      _ where smul_comm := fun r s m => (by simp [← mul_smul, mul_comm] : f r • s • m = s • f r • m)

namespace ExtendScalars

open TensorProduct

variable {R : Type u₁} {S : Type u₂} [CommRingₓ R] [CommRingₓ S] (f : R →+* S)

section Unbundled

variable (M : Type v) [AddCommMonoidₓ M] [Module R M]

-- mathport name: «expr ⊗ₜ[ , ] »
-- This notation is necessary because we need to reason about `s ⊗ₜ m` where `s : S` and `m : M`;
-- without this notation, one need to work with `s : (restrict_scalars f).obj ⟨S⟩`.
localized [ChangeOfRings] notation s "⊗ₜ[" R "," f "]" m => @TensorProduct.tmul R _ _ _ _ _ (Module.compHom _ f) _ s m

end Unbundled

open ChangeOfRings

variable (M : ModuleCat.{v} R)

/-- Extension of scalars turn an `R`-module into `S`-module by M ↦ S ⨂ M
-/
def obj' : ModuleCat S :=
  ⟨TensorProduct R ((restrictScalars f).obj ⟨S⟩) M⟩

/-- Extension of scalars is a functor where an `R`-module `M` is sent to `S ⊗ M` and
`l : M1 ⟶ M2` is sent to `s ⊗ m ↦ s ⊗ l m`
-/
def map' {M1 M2 : ModuleCat.{v} R} (l : M1 ⟶ M2) : obj' f M1 ⟶ obj' f M2 :=
  by-- The "by apply" part makes this require 75% fewer heartbeats to process (#16371).
  apply @LinearMap.baseChange R S M1 M2 _ _ ((algebraMap S _).comp f).toAlgebra _ _ _ _ l

theorem map'_id {M : ModuleCat.{v} R} : map' f (𝟙 M) = 𝟙 _ :=
  LinearMap.ext fun x : obj' f M => by
    dsimp only [map', ModuleCat.id_apply]
    induction' x using TensorProduct.induction_on with _ _ m s ihx ihy
    · simp only [map_zero]
      
    · rw [LinearMap.base_change_tmul, ModuleCat.id_apply]
      
    · rw [map_add, ihx, ihy]
      

theorem map'_comp {M₁ M₂ M₃ : ModuleCat.{v} R} (l₁₂ : M₁ ⟶ M₂) (l₂₃ : M₂ ⟶ M₃) :
    map' f (l₁₂ ≫ l₂₃) = map' f l₁₂ ≫ map' f l₂₃ :=
  LinearMap.ext fun x : obj' f M₁ => by
    dsimp only [map']
    induction' x using TensorProduct.induction_on with _ _ x y ihx ihy
    · rfl
      
    · rfl
      
    · simp only [map_add, ihx, ihy]
      

end ExtendScalars

/-- Extension of scalars is a functor where an `R`-module `M` is sent to `S ⊗ M` and
`l : M1 ⟶ M2` is sent to `s ⊗ m ↦ s ⊗ l m`
-/
def extendScalars {R : Type u₁} {S : Type u₂} [CommRingₓ R] [CommRingₓ S] (f : R →+* S) :
    ModuleCat.{v} R ⥤ ModuleCat.{max v u₂} S where
  obj := fun M => ExtendScalars.obj' f M
  map := fun M1 M2 l => ExtendScalars.map' f l
  map_id' := fun _ => ExtendScalars.map'_id f
  map_comp' := fun _ _ _ => ExtendScalars.map'_comp f

namespace ExtendScalars

open ChangeOfRings

variable {R : Type u₁} {S : Type u₂} [CommRingₓ R] [CommRingₓ S] (f : R →+* S)

@[simp]
protected theorem smul_tmul {M : ModuleCat.{v} R} (s s' : S) (m : M) :
    s • (s'⊗ₜ[R,f]m : (extendScalars f).obj M) = (s * s')⊗ₜ[R,f]m :=
  rfl

@[simp]
theorem map_tmul {M M' : ModuleCat.{v} R} (g : M ⟶ M') (s : S) (m : M) :
    (extendScalars f).map g (s⊗ₜ[R,f]m) = s⊗ₜ[R,f]g m :=
  rfl

end ExtendScalars

end CategoryTheory.Module

