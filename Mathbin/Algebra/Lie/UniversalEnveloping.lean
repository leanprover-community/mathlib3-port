/-
Copyright (c) 2020 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash
-/
import Mathbin.Algebra.Lie.OfAssociative
import Mathbin.Algebra.RingQuot
import Mathbin.LinearAlgebra.TensorAlgebra.Basic

/-!
# Universal enveloping algebra

Given a commutative ring `R` and a Lie algebra `L` over `R`, we construct the universal
enveloping algebra of `L`, together with its universal property.

## Main definitions

  * `universal_enveloping_algebra`: the universal enveloping algebra, endowed with an
    `R`-algebra structure.
  * `universal_enveloping_algebra.ι`: the Lie algebra morphism from `L` to its universal
    enveloping algebra.
  * `universal_enveloping_algebra.lift`: given an associative algebra `A`, together with a Lie
    algebra morphism `f : L →ₗ⁅R⁆ A`, `lift R L f : universal_enveloping_algebra R L →ₐ[R] A` is the
    unique morphism of algebras through which `f` factors.
  * `universal_enveloping_algebra.ι_comp_lift`: states that the lift of a morphism is indeed part
    of a factorisation.
  * `universal_enveloping_algebra.lift_unique`: states that lifts of morphisms are indeed unique.
  * `universal_enveloping_algebra.hom_ext`: a restatement of `lift_unique` as an extensionality
    lemma.

## Tags

lie algebra, universal enveloping algebra, tensor algebra
-/


universe u₁ u₂ u₃

variable (R : Type u₁) (L : Type u₂)

variable [CommRingₓ R] [LieRing L] [LieAlgebra R L]

-- mathport name: «exprιₜ»
local notation "ιₜ" => TensorAlgebra.ι R

namespace UniversalEnvelopingAlgebra

/-- The quotient by the ideal generated by this relation is the universal enveloping algebra.

Note that we have avoided using the more natural expression:
| lie_compat (x y : L) : rel (ιₜ ⁅x, y⁆) ⁅ιₜ x, ιₜ y⁆
so that our construction needs only the semiring structure of the tensor algebra. -/
inductive Rel : TensorAlgebra R L → TensorAlgebra R L → Prop
  | lie_compat (x y : L) : rel (ιₜ ⁅x,y⁆ + ιₜ y * ιₜ x) (ιₜ x * ιₜ y)

end UniversalEnvelopingAlgebra

-- ././Mathport/Syntax/Translate/Basic.lean:978:9: unsupported derive handler algebra R
/-- The universal enveloping algebra of a Lie algebra. -/
def UniversalEnvelopingAlgebra :=
  RingQuot (UniversalEnvelopingAlgebra.Rel R L)deriving Inhabited, Ringₓ, [anonymous]

namespace UniversalEnvelopingAlgebra

/-- The quotient map from the tensor algebra to the universal enveloping algebra as a morphism of
associative algebras. -/
def mkAlgHom : TensorAlgebra R L →ₐ[R] UniversalEnvelopingAlgebra R L :=
  RingQuot.mkAlgHom R (Rel R L)

variable {L}

/-- The natural Lie algebra morphism from a Lie algebra to its universal enveloping algebra. -/
def ι : L →ₗ⁅R⁆ UniversalEnvelopingAlgebra R L :=
  { (mkAlgHom R L).toLinearMap.comp ιₜ with
    map_lie' := fun x y => by
      suffices mk_alg_hom R L (ιₜ ⁅x,y⁆ + ιₜ y * ιₜ x) = mk_alg_hom R L (ιₜ x * ιₜ y) by
        rw [AlgHom.map_mul] at this
        simp [LieRing.of_associative_ring_bracket, ← this]
      exact RingQuot.mk_alg_hom_rel _ (rel.lie_compat x y) }

variable {A : Type u₃} [Ringₓ A] [Algebra R A] (f : L →ₗ⁅R⁆ A)

/-- The universal property of the universal enveloping algebra: Lie algebra morphisms into
associative algebras lift to associative algebra morphisms from the universal enveloping algebra. -/
def lift : (L →ₗ⁅R⁆ A) ≃ (UniversalEnvelopingAlgebra R L →ₐ[R] A) where
  toFun := fun f =>
    RingQuot.liftAlgHom R
      ⟨TensorAlgebra.lift R (f : L →ₗ[R] A), by
        intro a b h
        induction' h with x y
        simp [LieRing.of_associative_ring_bracket]⟩
  invFun := fun F => (F : UniversalEnvelopingAlgebra R L →ₗ⁅R⁆ A).comp (ι R)
  left_inv := fun f => by
    ext
    simp [ι, mk_alg_hom]
  right_inv := fun F => by
    ext
    simp [ι, mk_alg_hom]

@[simp]
theorem lift_symm_apply (F : UniversalEnvelopingAlgebra R L →ₐ[R] A) :
    (lift R).symm F = (F : UniversalEnvelopingAlgebra R L →ₗ⁅R⁆ A).comp (ι R) :=
  rfl

@[simp]
theorem ι_comp_lift : lift R f ∘ ι R = f :=
  funext <| LieHom.ext_iff.mp <| (lift R).symm_apply_apply f

@[simp]
theorem lift_ι_apply (x : L) : lift R f (ι R x) = f x := by
  rw [← Function.comp_applyₓ (lift R f) (ι R) x, ι_comp_lift]

theorem lift_unique (g : UniversalEnvelopingAlgebra R L →ₐ[R] A) : g ∘ ι R = f ↔ g = lift R f := by
  refine' Iff.trans _ (lift R).symm_apply_eq
  constructor <;>
    · intro h
      ext
      simp [← h]
      

/-- See note [partially-applied ext lemmas]. -/
@[ext]
theorem hom_ext {g₁ g₂ : UniversalEnvelopingAlgebra R L →ₐ[R] A}
    (h :
      (g₁ : UniversalEnvelopingAlgebra R L →ₗ⁅R⁆ A).comp (ι R) =
        (g₂ : UniversalEnvelopingAlgebra R L →ₗ⁅R⁆ A).comp (ι R)) :
    g₁ = g₂ :=
  have h' : (lift R).symm g₁ = (lift R).symm g₂ := by
    ext
    simp [h]
  (lift R).symm.Injective h'

end UniversalEnvelopingAlgebra

