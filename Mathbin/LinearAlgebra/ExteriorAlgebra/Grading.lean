/-
Copyright (c) 2021 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser
-/
import Mathbin.LinearAlgebra.ExteriorAlgebra.Basic
import Mathbin.RingTheory.GradedAlgebra.Basic

/-!
# Results about the grading structure of the exterior algebra

Many of these results are copied with minimal modification from the tensor algebra.

The main result is `exterior_algebra.graded_algebra`, which says that the exterior algebra is a
ℕ-graded algebra.
-/


namespace ExteriorAlgebra

variable {R M : Type _} [CommSemiringₓ R] [AddCommMonoidₓ M] [Module R M]

variable (R M)

open DirectSum

/-- A version of `exterior_algebra.ι` that maps directly into the graded structure. This is
primarily an auxiliary construction used to provide `exterior_algebra.graded_algebra`. -/
def GradedAlgebra.ι : M →ₗ[R] ⨁ i : ℕ, ↥((ι R : M →ₗ[_] _).range ^ i) :=
  DirectSum.lof R ℕ (fun i => ↥((ι R : M →ₗ[_] _).range ^ i)) 1 ∘ₗ
    (ι R).codRestrict _ fun m => by
      simpa only [pow_oneₓ] using LinearMap.mem_range_self _ m

theorem GradedAlgebra.ι_apply (m : M) :
    GradedAlgebra.ι R M m =
      DirectSum.of (fun i => ↥((ι R : M →ₗ[_] _).range ^ i)) 1
        ⟨ι R m, by
          simpa only [pow_oneₓ] using LinearMap.mem_range_self _ m⟩ :=
  rfl

theorem GradedAlgebra.ι_sq_zero (m : M) : GradedAlgebra.ι R M m * GradedAlgebra.ι R M m = 0 := by
  rw [graded_algebra.ι_apply, DirectSum.of_mul_of]
  refine' dfinsupp.single_eq_zero.mpr (Subtype.ext <| ι_sq_zero _)

variable {R M}

/-- The exterior algebra is graded by the powers of the submodule `(exterior_algebra.ι R).range`. -/
instance gradedAlgebra :
    GradedAlgebra ((· ^ ·) (ι R : M →ₗ[R] ExteriorAlgebra R M).range : ℕ → Submodule R (ExteriorAlgebra R M)) :=
  GradedAlgebra.ofAlgHom _ (lift _ <| ⟨GradedAlgebra.ι R M, GradedAlgebra.ι_sq_zero R M⟩)
    (-- the proof from here onward is identical to the `tensor_algebra` case
    by
      ext m
      dsimp' only [LinearMap.comp_apply, AlgHom.to_linear_map_apply, AlgHom.comp_apply, AlgHom.id_apply]
      rw [lift_ι_apply, graded_algebra.ι_apply, DirectSum.submodule_coe_alg_hom_of, Subtype.coe_mk])
    fun i x => by
    cases' x with x hx
    dsimp' only [Subtype.coe_mk, DirectSum.lof_eq_of]
    refine' Submodule.pow_induction_on' _ (fun r => _) (fun x y i hx hy ihx ihy => _) (fun m hm i x hx ih => _) hx
    · rw [AlgHom.commutes, DirectSum.algebra_map_apply]
      rfl
      
    · rw [AlgHom.map_add, ihx, ihy, ← map_add]
      rfl
      
    · obtain ⟨_, rfl⟩ := hm
      rw [AlgHom.map_mul, ih, lift_ι_apply, graded_algebra.ι_apply, DirectSum.of_mul_of]
      exact DirectSum.of_eq_of_graded_monoid_eq (Sigma.subtype_ext (add_commₓ _ _) rfl)
      

end ExteriorAlgebra

