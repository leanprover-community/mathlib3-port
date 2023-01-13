/-
Copyright (c) 2020 Adam Topaz. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Adam Topaz

! This file was ported from Lean 3 source module linear_algebra.tensor_algebra.basic
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.FreeAlgebra
import Mathbin.Algebra.RingQuot
import Mathbin.Algebra.TrivSqZeroExt
import Mathbin.Algebra.Algebra.Operations
import Mathbin.LinearAlgebra.Multilinear.Basic

/-!
# Tensor Algebras

Given a commutative semiring `R`, and an `R`-module `M`, we construct the tensor algebra of `M`.
This is the free `R`-algebra generated (`R`-linearly) by the module `M`.

## Notation

1. `tensor_algebra R M` is the tensor algebra itself. It is endowed with an R-algebra structure.
2. `tensor_algebra.ι R` is the canonical R-linear map `M → tensor_algebra R M`.
3. Given a linear map `f : M → A` to an R-algebra `A`, `lift R f` is the lift of `f` to an
  `R`-algebra morphism `tensor_algebra R M → A`.

## Theorems

1. `ι_comp_lift` states that the composition `(lift R f) ∘ (ι R)` is identical to `f`.
2. `lift_unique` states that whenever an R-algebra morphism `g : tensor_algebra R M → A` is
  given whose composition with `ι R` is `f`, then one has `g = lift R f`.
3. `hom_ext` is a variant of `lift_unique` in the form of an extensionality theorem.
4. `lift_comp_ι` is a combination of `ι_comp_lift` and `lift_unique`. It states that the lift
  of the composition of an algebra morphism with `ι` is the algebra morphism itself.

## Implementation details

As noted above, the tensor algebra of `M` is constructed as the free `R`-algebra generated by `M`,
modulo the additional relations making the inclusion of `M` into an `R`-linear map.
-/


variable (R : Type _) [CommSemiring R]

variable (M : Type _) [AddCommMonoid M] [Module R M]

namespace TensorAlgebra

/-- An inductively defined relation on `pre R M` used to force the initial algebra structure on
the associated quotient.
-/
inductive Rel : FreeAlgebra R M → FreeAlgebra R M → Prop-- force `ι` to be linear

  | add {a b : M} : Rel (FreeAlgebra.ι R (a + b)) (FreeAlgebra.ι R a + FreeAlgebra.ι R b)
  |
  smul {r : R} {a : M} :
    Rel (FreeAlgebra.ι R (r • a)) (algebraMap R (FreeAlgebra R M) r * FreeAlgebra.ι R a)
#align tensor_algebra.rel TensorAlgebra.Rel

end TensorAlgebra

/- ./././Mathport/Syntax/Translate/Command.lean:42:9: unsupported derive handler algebra[algebra] R -/
/-- The tensor algebra of the module `M` over the commutative semiring `R`.
-/
def TensorAlgebra :=
  RingQuot (TensorAlgebra.Rel R M)deriving Inhabited, Semiring,
  «./././Mathport/Syntax/Translate/Command.lean:42:9: unsupported derive handler algebra[algebra] R»
#align tensor_algebra TensorAlgebra

namespace TensorAlgebra

instance {S : Type _} [CommRing S] [Module S M] : Ring (TensorAlgebra S M) :=
  RingQuot.ring (Rel S M)

variable {M}

/-- The canonical linear map `M →ₗ[R] tensor_algebra R M`.
-/
def ι : M →ₗ[R] TensorAlgebra R M
    where
  toFun m := RingQuot.mkAlgHom R _ (FreeAlgebra.ι R m)
  map_add' x y := by
    rw [← AlgHom.map_add]
    exact RingQuot.mk_alg_hom_rel R rel.add
  map_smul' r x := by
    rw [← AlgHom.map_smul]
    exact RingQuot.mk_alg_hom_rel R rel.smul
#align tensor_algebra.ι TensorAlgebra.ι

theorem ring_quot_mk_alg_hom_free_algebra_ι_eq_ι (m : M) :
    RingQuot.mkAlgHom R (Rel R M) (FreeAlgebra.ι R m) = ι R m :=
  rfl
#align
  tensor_algebra.ring_quot_mk_alg_hom_free_algebra_ι_eq_ι TensorAlgebra.ring_quot_mk_alg_hom_free_algebra_ι_eq_ι

/-- Given a linear map `f : M → A` where `A` is an `R`-algebra, `lift R f` is the unique lift
of `f` to a morphism of `R`-algebras `tensor_algebra R M → A`.
-/
@[simps symmApply]
def lift {A : Type _} [Semiring A] [Algebra R A] : (M →ₗ[R] A) ≃ (TensorAlgebra R M →ₐ[R] A)
    where
  toFun :=
    RingQuot.liftAlgHom R ∘ fun f =>
      ⟨FreeAlgebra.lift R ⇑f, fun x y (h : Rel R M x y) => by
        induction h <;> simp [Algebra.smul_def]⟩
  invFun F := F.toLinearMap.comp (ι R)
  left_inv f :=
    LinearMap.ext fun x =>
      (RingQuot.lift_alg_hom_mk_alg_hom_apply _ _ _ _).trans (FreeAlgebra.lift_ι_apply f x)
  right_inv F :=
    RingQuot.ring_quot_ext' _ _ _ <|
      FreeAlgebra.hom_ext <|
        funext fun x =>
          (RingQuot.lift_alg_hom_mk_alg_hom_apply _ _ _ _).trans (FreeAlgebra.lift_ι_apply _ _)
#align tensor_algebra.lift TensorAlgebra.lift

variable {R}

@[simp]
theorem ι_comp_lift {A : Type _} [Semiring A] [Algebra R A] (f : M →ₗ[R] A) :
    (lift R f).toLinearMap.comp (ι R) = f :=
  (lift R).symm_apply_apply f
#align tensor_algebra.ι_comp_lift TensorAlgebra.ι_comp_lift

@[simp]
theorem lift_ι_apply {A : Type _} [Semiring A] [Algebra R A] (f : M →ₗ[R] A) (x) :
    lift R f (ι R x) = f x := by
  dsimp [lift, ι]
  rfl
#align tensor_algebra.lift_ι_apply TensorAlgebra.lift_ι_apply

@[simp]
theorem lift_unique {A : Type _} [Semiring A] [Algebra R A] (f : M →ₗ[R] A)
    (g : TensorAlgebra R M →ₐ[R] A) : g.toLinearMap.comp (ι R) = f ↔ g = lift R f :=
  (lift R).symm_apply_eq
#align tensor_algebra.lift_unique TensorAlgebra.lift_unique

-- Marking `tensor_algebra` irreducible makes `ring` instances inaccessible on quotients.
-- https://leanprover.zulipchat.com/#narrow/stream/113488-general/topic/algebra.2Esemiring_to_ring.20breaks.20semimodule.20typeclass.20lookup/near/212580241
-- For now, we avoid this by not marking it irreducible.
@[simp]
theorem lift_comp_ι {A : Type _} [Semiring A] [Algebra R A] (g : TensorAlgebra R M →ₐ[R] A) :
    lift R (g.toLinearMap.comp (ι R)) = g :=
  by
  rw [← lift_symm_apply]
  exact (lift R).apply_symm_apply g
#align tensor_algebra.lift_comp_ι TensorAlgebra.lift_comp_ι

/-- See note [partially-applied ext lemmas]. -/
@[ext]
theorem hom_ext {A : Type _} [Semiring A] [Algebra R A] {f g : TensorAlgebra R M →ₐ[R] A}
    (w : f.toLinearMap.comp (ι R) = g.toLinearMap.comp (ι R)) : f = g :=
  by
  rw [← lift_symm_apply, ← lift_symm_apply] at w
  exact (lift R).symm.Injective w
#align tensor_algebra.hom_ext TensorAlgebra.hom_ext

-- This proof closely follows `free_algebra.induction`
/-- If `C` holds for the `algebra_map` of `r : R` into `tensor_algebra R M`, the `ι` of `x : M`,
and is preserved under addition and muliplication, then it holds for all of `tensor_algebra R M`.
-/
@[elab_as_elim]
theorem induction {C : TensorAlgebra R M → Prop}
    (h_grade0 : ∀ r, C (algebraMap R (TensorAlgebra R M) r)) (h_grade1 : ∀ x, C (ι R x))
    (h_mul : ∀ a b, C a → C b → C (a * b)) (h_add : ∀ a b, C a → C b → C (a + b))
    (a : TensorAlgebra R M) : C a :=
  by
  -- the arguments are enough to construct a subalgebra, and a mapping into it from M
  let s : Subalgebra R (TensorAlgebra R M) :=
    { carrier := C
      mul_mem' := h_mul
      add_mem' := h_add
      algebra_map_mem' := h_grade0 }
  let of : M →ₗ[R] s := (ι R).codRestrict s.to_submodule h_grade1
  -- the mapping through the subalgebra is the identity
  have of_id : AlgHom.id R (TensorAlgebra R M) = s.val.comp (lift R of) :=
    by
    ext
    simp [of]
  -- finding a proof is finding an element of the subalgebra
  convert Subtype.prop (lift R of a)
  exact AlgHom.congr_fun of_id a
#align tensor_algebra.induction TensorAlgebra.induction

/-- The left-inverse of `algebra_map`. -/
def algebraMapInv : TensorAlgebra R M →ₐ[R] R :=
  lift R (0 : M →ₗ[R] R)
#align tensor_algebra.algebra_map_inv TensorAlgebra.algebraMapInv

variable (M)

theorem algebra_map_left_inverse :
    Function.LeftInverse algebraMapInv (algebraMap R <| TensorAlgebra R M) := fun x => by
  simp [algebra_map_inv]
#align tensor_algebra.algebra_map_left_inverse TensorAlgebra.algebra_map_left_inverse

@[simp]
theorem algebra_map_inj (x y : R) :
    algebraMap R (TensorAlgebra R M) x = algebraMap R (TensorAlgebra R M) y ↔ x = y :=
  (algebra_map_left_inverse M).Injective.eq_iff
#align tensor_algebra.algebra_map_inj TensorAlgebra.algebra_map_inj

@[simp]
theorem algebra_map_eq_zero_iff (x : R) : algebraMap R (TensorAlgebra R M) x = 0 ↔ x = 0 :=
  map_eq_zero_iff (algebraMap _ _) (algebra_map_left_inverse _).Injective
#align tensor_algebra.algebra_map_eq_zero_iff TensorAlgebra.algebra_map_eq_zero_iff

@[simp]
theorem algebra_map_eq_one_iff (x : R) : algebraMap R (TensorAlgebra R M) x = 1 ↔ x = 1 :=
  map_eq_one_iff (algebraMap _ _) (algebra_map_left_inverse _).Injective
#align tensor_algebra.algebra_map_eq_one_iff TensorAlgebra.algebra_map_eq_one_iff

variable {M}

/-- The canonical map from `tensor_algebra R M` into `triv_sq_zero_ext R M` that sends
`tensor_algebra.ι` to `triv_sq_zero_ext.inr`. -/
def toTrivSqZeroExt : TensorAlgebra R M →ₐ[R] TrivSqZeroExt R M :=
  lift R (TrivSqZeroExt.inrHom R M)
#align tensor_algebra.to_triv_sq_zero_ext TensorAlgebra.toTrivSqZeroExt

@[simp]
theorem to_triv_sq_zero_ext_ι (x : M) : toTrivSqZeroExt (ι R x) = TrivSqZeroExt.inr x :=
  lift_ι_apply _ _
#align tensor_algebra.to_triv_sq_zero_ext_ι TensorAlgebra.to_triv_sq_zero_ext_ι

/-- The left-inverse of `ι`.

As an implementation detail, we implement this using `triv_sq_zero_ext` which has a suitable
algebra structure. -/
def ιInv : TensorAlgebra R M →ₗ[R] M :=
  (TrivSqZeroExt.sndHom R M).comp toTrivSqZeroExt.toLinearMap
#align tensor_algebra.ι_inv TensorAlgebra.ιInv

theorem ι_left_inverse : Function.LeftInverse ιInv (ι R : M → TensorAlgebra R M) := fun x => by
  simp [ι_inv]
#align tensor_algebra.ι_left_inverse TensorAlgebra.ι_left_inverse

variable (R)

@[simp]
theorem ι_inj (x y : M) : ι R x = ι R y ↔ x = y :=
  ι_left_inverse.Injective.eq_iff
#align tensor_algebra.ι_inj TensorAlgebra.ι_inj

@[simp]
theorem ι_eq_zero_iff (x : M) : ι R x = 0 ↔ x = 0 := by rw [← ι_inj R x 0, LinearMap.map_zero]
#align tensor_algebra.ι_eq_zero_iff TensorAlgebra.ι_eq_zero_iff

variable {R}

@[simp]
theorem ι_eq_algebra_map_iff (x : M) (r : R) : ι R x = algebraMap R _ r ↔ x = 0 ∧ r = 0 :=
  by
  refine' ⟨fun h => _, _⟩
  · have hf0 : to_triv_sq_zero_ext (ι R x) = (0, x) := lift_ι_apply _ _
    rw [h, AlgHom.commutes] at hf0
    have : r = 0 ∧ 0 = x := Prod.ext_iff.1 hf0
    exact this.symm.imp_left Eq.symm
  · rintro ⟨rfl, rfl⟩
    rw [LinearMap.map_zero, RingHom.map_zero]
#align tensor_algebra.ι_eq_algebra_map_iff TensorAlgebra.ι_eq_algebra_map_iff

@[simp]
theorem ι_ne_one [Nontrivial R] (x : M) : ι R x ≠ 1 :=
  by
  rw [← (algebraMap R (TensorAlgebra R M)).map_one, Ne.def, ι_eq_algebra_map_iff]
  exact one_ne_zero ∘ And.right
#align tensor_algebra.ι_ne_one TensorAlgebra.ι_ne_one

/-- The generators of the tensor algebra are disjoint from its scalars. -/
theorem ι_range_disjoint_one :
    Disjoint (LinearMap.range (ι R : M →ₗ[R] TensorAlgebra R M))
      (1 : Submodule R (TensorAlgebra R M)) :=
  by
  rw [Submodule.disjoint_def]
  rintro _ ⟨x, hx⟩ ⟨r, rfl : algebraMap _ _ _ = _⟩
  rw [ι_eq_algebra_map_iff x] at hx
  rw [hx.2, RingHom.map_zero]
#align tensor_algebra.ι_range_disjoint_one TensorAlgebra.ι_range_disjoint_one

variable (R M)

/-- Construct a product of `n` elements of the module within the tensor algebra.

See also `pi_tensor_product.tprod`. -/
def tprod (n : ℕ) : MultilinearMap R (fun i : Fin n => M) (TensorAlgebra R M) :=
  (MultilinearMap.mkPiAlgebraFin R n (TensorAlgebra R M)).compLinearMap fun _ => ι R
#align tensor_algebra.tprod TensorAlgebra.tprod

@[simp]
theorem tprod_apply {n : ℕ} (x : Fin n → M) : tprod R M n x = (List.ofFn fun i => ι R (x i)).Prod :=
  rfl
#align tensor_algebra.tprod_apply TensorAlgebra.tprod_apply

variable {R M}

end TensorAlgebra

namespace FreeAlgebra

variable {R M}

/-- The canonical image of the `free_algebra` in the `tensor_algebra`, which maps
`free_algebra.ι R x` to `tensor_algebra.ι R x`. -/
def toTensor : FreeAlgebra R M →ₐ[R] TensorAlgebra R M :=
  FreeAlgebra.lift R (TensorAlgebra.ι R)
#align free_algebra.to_tensor FreeAlgebra.toTensor

@[simp]
theorem to_tensor_ι (m : M) : (FreeAlgebra.ι R m).toTensor = TensorAlgebra.ι R m := by
  simp [to_tensor]
#align free_algebra.to_tensor_ι FreeAlgebra.to_tensor_ι

end FreeAlgebra

