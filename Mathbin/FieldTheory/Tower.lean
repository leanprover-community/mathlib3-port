/-
Copyright (c) 2020 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module field_theory.tower
! leanprover-community/mathlib commit 1126441d6bccf98c81214a0780c73d499f6721fe
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Prime
import Mathbin.RingTheory.AlgebraTower
import Mathbin.LinearAlgebra.Matrix.FiniteDimensional
import Mathbin.LinearAlgebra.Matrix.ToLin

/-!
# Tower of field extensions

In this file we prove the tower law for arbitrary extensions and finite extensions.
Suppose `L` is a field extension of `K` and `K` is a field extension of `F`.
Then `[L:F] = [L:K] [K:F]` where `[E₁:E₂]` means the `E₂`-dimension of `E₁`.

In fact we generalize it to vector spaces, where `L` is not necessarily a field,
but just a vector space over `K`.

## Implementation notes

We prove two versions, since there are two notions of dimensions: `module.rank` which gives
the dimension of an arbitrary vector space as a cardinal, and `finite_dimensional.finrank` which
gives the dimension of a finitely-dimensional vector space as a natural number.

## Tags

tower law

-/


universe u v w u₁ v₁ w₁

open Classical BigOperators

section Field

open Cardinal

variable (F : Type u) (K : Type v) (A : Type w)

variable [Field F] [DivisionRing K] [AddCommGroup A]

variable [Algebra F K] [Module K A] [Module F A] [IsScalarTower F K A]

/-- Tower law: if `A` is a `K`-vector space and `K` is a field extension of `F` then
`dim_F(A) = dim_F(K) * dim_K(A)`. -/
theorem dim_mul_dim' :
    Cardinal.lift.{w} (Module.rank F K) * Cardinal.lift.{v} (Module.rank K A) =
      Cardinal.lift.{v} (Module.rank F A) :=
  by
  let b := Basis.ofVectorSpace F K
  let c := Basis.ofVectorSpace K A
  rw [← (Module.rank F K).lift_id, ← b.mk_eq_dim, ← (Module.rank K A).lift_id, ← c.mk_eq_dim, ←
    lift_umax.{w, v}, ← (b.smul c).mk_eq_dim, mk_prod, lift_mul, lift_lift, lift_lift, lift_lift,
    lift_lift, lift_umax]
#align dim_mul_dim' dim_mul_dim'

/-- Tower law: if `A` is a `K`-vector space and `K` is a field extension of `F` then
`dim_F(A) = dim_F(K) * dim_K(A)`. -/
theorem dim_mul_dim (F : Type u) (K A : Type v) [Field F] [Field K] [AddCommGroup A] [Algebra F K]
    [Module K A] [Module F A] [IsScalarTower F K A] :
    Module.rank F K * Module.rank K A = Module.rank F A := by
  convert dim_mul_dim' F K A <;> rw [lift_id]
#align dim_mul_dim dim_mul_dim

namespace FiniteDimensional

open IsNoetherian

theorem trans [FiniteDimensional F K] [FiniteDimensional K A] : FiniteDimensional F A :=
  let b := Basis.ofVectorSpace F K
  let c := Basis.ofVectorSpace K A
  of_fintype_basis <| b.smul c
#align finite_dimensional.trans FiniteDimensional.trans

/-- In a tower of field extensions `L / K / F`, if `L / F` is finite, so is `K / F`.

(In fact, it suffices that `L` is a nontrivial ring.)

Note this cannot be an instance as Lean cannot infer `L`.
-/
theorem left (K L : Type _) [Field K] [Algebra F K] [Ring L] [Nontrivial L] [Algebra F L]
    [Algebra K L] [IsScalarTower F K L] [FiniteDimensional F L] : FiniteDimensional F K :=
  FiniteDimensional.of_injective (IsScalarTower.toAlgHom F K L).toLinearMap (RingHom.injective _)
#align finite_dimensional.left FiniteDimensional.left

theorem right [hf : FiniteDimensional F A] : FiniteDimensional K A :=
  let ⟨⟨b, hb⟩⟩ := hf
  ⟨⟨b,
      Submodule.restrictScalars_injective F _ _ <|
        by
        rw [Submodule.restrictScalars_top, eq_top_iff, ← hb, Submodule.span_le]
        exact Submodule.subset_span⟩⟩
#align finite_dimensional.right FiniteDimensional.right

/-- Tower law: if `A` is a `K`-algebra and `K` is a field extension of `F` then
`dim_F(A) = dim_F(K) * dim_K(A)`. -/
theorem finrank_mul_finrank [FiniteDimensional F K] : finrank F K * finrank K A = finrank F A :=
  by
  by_cases hA : FiniteDimensional K A
  · skip
    let b := Basis.ofVectorSpace F K
    let c := Basis.ofVectorSpace K A
    rw [finrank_eq_card_basis b, finrank_eq_card_basis c, finrank_eq_card_basis (b.smul c),
      Fintype.card_prod]
  · rw [finrank_of_infinite_dimensional hA, mul_zero, finrank_of_infinite_dimensional]
    exact mt (@right F K A _ _ _ _ _ _ _) hA
#align finite_dimensional.finrank_mul_finrank FiniteDimensional.finrank_mul_finrank

theorem Subalgebra.isSimpleOrder_of_finrank_prime (A) [Ring A] [IsDomain A] [Algebra F A]
    (hp : (finrank F A).Prime) : IsSimpleOrder (Subalgebra F A) :=
  { to_nontrivial :=
      ⟨⟨⊥, ⊤, fun he =>
          Nat.not_prime_one ((Subalgebra.bot_eq_top_iff_finrank_eq_one.1 he).subst hp)⟩⟩
    eq_bot_or_eq_top := fun K =>
      by
      haveI := finite_dimensional_of_finrank hp.pos
      letI := divisionRingOfFiniteDimensional F K
      refine' (hp.eq_one_or_self_of_dvd _ ⟨_, (finrank_mul_finrank F K A).symm⟩).imp _ fun h => _
      · exact Subalgebra.eq_bot_of_finrank_one
      ·
        exact
          Algebra.toSubmodule_eq_top.1 (eq_top_of_finrank_eq <| K.finrank_to_submodule.trans h) }
#align finite_dimensional.subalgebra.is_simple_order_of_finrank_prime FiniteDimensional.Subalgebra.isSimpleOrder_of_finrank_prime

-- TODO: `intermediate_field` version
instance linearMap (F : Type u) (V : Type v) (W : Type w) [Field F] [AddCommGroup V] [Module F V]
    [AddCommGroup W] [Module F W] [FiniteDimensional F V] [FiniteDimensional F W] :
    FiniteDimensional F (V →ₗ[F] W) :=
  let b := Basis.ofVectorSpace F V
  let c := Basis.ofVectorSpace F W
  (Matrix.toLin b c).FiniteDimensional
#align finite_dimensional.linear_map FiniteDimensional.linearMap

theorem finrank_linearMap (F : Type u) (V : Type v) (W : Type w) [Field F] [AddCommGroup V]
    [Module F V] [AddCommGroup W] [Module F W] [FiniteDimensional F V] [FiniteDimensional F W] :
    finrank F (V →ₗ[F] W) = finrank F V * finrank F W :=
  by
  let b := Basis.ofVectorSpace F V
  let c := Basis.ofVectorSpace F W
  rw [LinearEquiv.finrank_eq (LinearMap.toMatrix b c), Matrix.finrank_matrix,
    finrank_eq_card_basis b, finrank_eq_card_basis c, mul_comm]
#align finite_dimensional.finrank_linear_map FiniteDimensional.finrank_linearMap

-- TODO: generalize by removing [finite_dimensional F K]
-- V = ⊕F,
-- (V →ₗ[F] K) = ((⊕F) →ₗ[F] K) = (⊕ (F →ₗ[F] K)) = ⊕K
instance linear_map' (F : Type u) (K : Type v) (V : Type w) [Field F] [Field K] [Algebra F K]
    [FiniteDimensional F K] [AddCommGroup V] [Module F V] [FiniteDimensional F V] :
    FiniteDimensional K (V →ₗ[F] K) :=
  right F _ _
#align finite_dimensional.linear_map' FiniteDimensional.linear_map'

theorem finrank_linear_map' (F : Type u) (K : Type v) (V : Type w) [Field F] [Field K] [Algebra F K]
    [FiniteDimensional F K] [AddCommGroup V] [Module F V] [FiniteDimensional F V] :
    finrank K (V →ₗ[F] K) = finrank F V :=
  mul_right_injective₀ finrank_pos.ne' <|
    calc
      finrank F K * finrank K (V →ₗ[F] K) = finrank F (V →ₗ[F] K) := finrank_mul_finrank _ _ _
      _ = finrank F V * finrank F K := finrank_linearMap F V K
      _ = finrank F K * finrank F V := mul_comm _ _
      
#align finite_dimensional.finrank_linear_map' FiniteDimensional.finrank_linear_map'

end FiniteDimensional

end Field

