/-
Copyright (c) 2021 Frédéric Dupuis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Frédéric Dupuis
-/
import Mathbin.Analysis.Normed.Group.Hom
import Mathbin.Analysis.NormedSpace.Basic
import Mathbin.Analysis.NormedSpace.LinearIsometry
import Mathbin.Algebra.Star.SelfAdjoint
import Mathbin.Algebra.Star.Unitary

/-!
# Normed star rings and algebras

A normed star group is a normed group with a compatible `star` which is isometric.

A C⋆-ring is a normed star group that is also a ring and that verifies the stronger
condition `∥x⋆ * x∥ = ∥x∥^2` for all `x`.  If a C⋆-ring is also a star algebra, then it is a
C⋆-algebra.

To get a C⋆-algebra `E` over field `𝕜`, use
`[normed_field 𝕜] [star_ring 𝕜] [normed_ring E] [star_ring E] [cstar_ring E]
 [normed_algebra 𝕜 E] [star_module 𝕜 E]`.

## TODO

- Show that `∥x⋆ * x∥ = ∥x∥^2` is equivalent to `∥x⋆ * x∥ = ∥x⋆∥ * ∥x∥`, which is used as the
  definition of C*-algebras in some sources (e.g. Wikipedia).

-/


open TopologicalSpace

-- mathport name: «expr ⋆»
local postfix:max "⋆" => star

/-- A normed star group is a normed group with a compatible `star` which is isometric. -/
class NormedStarGroup (E : Type _) [SeminormedAddCommGroup E] [StarAddMonoid E] : Prop where
  norm_star : ∀ x : E, ∥x⋆∥ = ∥x∥

export NormedStarGroup (norm_star)

attribute [simp] norm_star

variable {𝕜 E α : Type _}

section NormedStarGroup

variable [SeminormedAddCommGroup E] [StarAddMonoid E] [NormedStarGroup E]

@[simp]
theorem nnnorm_star (x : E) : ∥star x∥₊ = ∥x∥₊ :=
  Subtype.ext <| norm_star _

/-- The `star` map in a normed star group is a normed group homomorphism. -/
def starNormedAddGroupHom : NormedAddGroupHom E E :=
  { starAddEquiv with bound' := ⟨1, fun v => le_trans (norm_star _).le (one_mul _).symm.le⟩ }

/-- The `star` map in a normed star group is an isometry -/
theorem starIsometry : Isometry (star : E → E) :=
  show Isometry starAddEquiv from AddMonoidHomClass.isometryOfNorm starAddEquiv (show ∀ x, ∥x⋆∥ = ∥x∥ from norm_star)

instance (priority := 100) NormedStarGroup.to_has_continuous_star : HasContinuousStar E :=
  ⟨starIsometry.Continuous⟩

end NormedStarGroup

instance RingHomIsometric.starRingEnd [NormedCommRing E] [StarRing E] [NormedStarGroup E] :
    RingHomIsometric (starRingEnd E) :=
  ⟨norm_star⟩

/-- A C*-ring is a normed star ring that satifies the stronger condition `∥x⋆ * x∥ = ∥x∥^2`
for every `x`. -/
class CstarRing (E : Type _) [NonUnitalNormedRing E] [StarRing E] : Prop where
  norm_star_mul_self : ∀ {x : E}, ∥x⋆ * x∥ = ∥x∥ * ∥x∥

instance : CstarRing ℝ where norm_star_mul_self x := by simp only [star, id.def, norm_mul]

namespace CstarRing

section NonUnital

variable [NonUnitalNormedRing E] [StarRing E] [CstarRing E]

-- see Note [lower instance priority]
/-- In a C*-ring, star preserves the norm. -/
instance (priority := 100) toNormedStarGroup : NormedStarGroup E :=
  ⟨by
    intro x
    by_cases htriv:x = 0
    · simp only [htriv, star_zero]
      
    · have hnt : 0 < ∥x∥ := norm_pos_iff.mpr htriv
      have hnt_star : 0 < ∥x⋆∥ := norm_pos_iff.mpr ((AddEquiv.map_ne_zero_iff starAddEquiv).mpr htriv)
      have h₁ :=
        calc
          ∥x∥ * ∥x∥ = ∥x⋆ * x∥ := norm_star_mul_self.symm
          _ ≤ ∥x⋆∥ * ∥x∥ := norm_mul_le _ _
          
      have h₂ :=
        calc
          ∥x⋆∥ * ∥x⋆∥ = ∥x * x⋆∥ := by rw [← norm_star_mul_self, star_star]
          _ ≤ ∥x∥ * ∥x⋆∥ := norm_mul_le _ _
          
      exact le_antisymm (le_of_mul_le_mul_right h₂ hnt_star) (le_of_mul_le_mul_right h₁ hnt)
      ⟩

theorem norm_self_mul_star {x : E} : ∥x * x⋆∥ = ∥x∥ * ∥x∥ := by
  nth_rw 0 [← star_star x]
  simp only [norm_star_mul_self, norm_star]

theorem norm_star_mul_self' {x : E} : ∥x⋆ * x∥ = ∥x⋆∥ * ∥x∥ := by rw [norm_star_mul_self, norm_star]

theorem nnnorm_star_mul_self {x : E} : ∥x⋆ * x∥₊ = ∥x∥₊ * ∥x∥₊ :=
  Subtype.ext norm_star_mul_self

@[simp]
theorem star_mul_self_eq_zero_iff (x : E) : star x * x = 0 ↔ x = 0 := by
  rw [← norm_eq_zero, norm_star_mul_self]
  exact mul_self_eq_zero.trans norm_eq_zero

theorem star_mul_self_ne_zero_iff (x : E) : star x * x ≠ 0 ↔ x ≠ 0 := by simp only [Ne.def, star_mul_self_eq_zero_iff]

@[simp]
theorem mul_star_self_eq_zero_iff (x : E) : x * star x = 0 ↔ x = 0 := by
  simpa only [star_eq_zero, star_star] using @star_mul_self_eq_zero_iff _ _ _ _ (star x)

theorem mul_star_self_ne_zero_iff (x : E) : x * star x ≠ 0 ↔ x ≠ 0 := by simp only [Ne.def, mul_star_self_eq_zero_iff]

end NonUnital

section ProdPi

variable {ι R₁ R₂ : Type _} {R : ι → Type _}

variable [NonUnitalNormedRing R₁] [StarRing R₁] [CstarRing R₁]

variable [NonUnitalNormedRing R₂] [StarRing R₂] [CstarRing R₂]

variable [∀ i, NonUnitalNormedRing (R i)] [∀ i, StarRing (R i)]

/-- This instance exists to short circuit type class resolution because of problems with
inference involving Π-types. -/
instance _root_.pi.star_ring' : StarRing (∀ i, R i) :=
  inferInstance

variable [Fintype ι] [∀ i, CstarRing (R i)]

instance _root_.prod.cstar_ring :
    CstarRing (R₁ × R₂) where norm_star_mul_self x := by
    unfold norm
    simp only [Prod.fst_mul, Prod.fst_star, Prod.snd_mul, Prod.snd_star, norm_star_mul_self, ← sq]
    refine' le_antisymm _ _
    · refine' max_le _ _ <;> rw [sq_le_sq, abs_of_nonneg (norm_nonneg _)]
      exact (le_max_left _ _).trans (le_abs_self _)
      exact (le_max_right _ _).trans (le_abs_self _)
      
    · rw [le_sup_iff]
      rcases le_total ∥x.fst∥ ∥x.snd∥ with (h | h) <;> simp [h]
      

instance _root_.pi.cstar_ring :
    CstarRing (∀ i, R i) where norm_star_mul_self x := by
    simp only [norm, Pi.mul_apply, Pi.star_apply, nnnorm_star_mul_self, ← sq]
    norm_cast
    exact
      (Finset.comp_sup_eq_sup_comp_of_is_total (fun x : Nnreal => x ^ 2)
          (fun x y h => by simpa only [sq] using mul_le_mul' h h) (by simp)).symm

instance _root_.pi.cstar_ring' : CstarRing (ι → R₁) :=
  Pi.cstarRing

end ProdPi

section Unital

variable [NormedRing E] [StarRing E] [CstarRing E]

@[simp]
theorem norm_one [Nontrivial E] : ∥(1 : E)∥ = 1 := by
  have : 0 < ∥(1 : E)∥ := norm_pos_iff.mpr one_ne_zero
  rw [← mul_left_inj' this.ne', ← norm_star_mul_self, mul_one, star_one, one_mul]

-- see Note [lower instance priority]
instance (priority := 100) [Nontrivial E] : NormOneClass E :=
  ⟨norm_one⟩

theorem norm_coe_unitary [Nontrivial E] (U : unitary E) : ∥(U : E)∥ = 1 := by
  rw [← sq_eq_sq (norm_nonneg _) zero_le_one, one_pow 2, sq, ← CstarRing.norm_star_mul_self, unitary.coe_star_mul_self,
    CstarRing.norm_one]

@[simp]
theorem norm_of_mem_unitary [Nontrivial E] {U : E} (hU : U ∈ unitary E) : ∥U∥ = 1 :=
  norm_coe_unitary ⟨U, hU⟩

@[simp]
theorem norm_coe_unitary_mul (U : unitary E) (A : E) : ∥(U : E) * A∥ = ∥A∥ := by
  nontriviality E
  refine' le_antisymm _ _
  · calc
      _ ≤ ∥(U : E)∥ * ∥A∥ := norm_mul_le _ _
      _ = ∥A∥ := by rw [norm_coe_unitary, one_mul]
      
    
  · calc
      _ = ∥(U : E)⋆ * U * A∥ := by rw [unitary.coe_star_mul_self U, one_mul]
      _ ≤ ∥(U : E)⋆∥ * ∥(U : E) * A∥ := by
        rw [mul_assoc]
        exact norm_mul_le _ _
      _ = ∥(U : E) * A∥ := by rw [norm_star, norm_coe_unitary, one_mul]
      
    

@[simp]
theorem norm_unitary_smul (U : unitary E) (A : E) : ∥U • A∥ = ∥A∥ :=
  norm_coe_unitary_mul U A

theorem norm_mem_unitary_mul {U : E} (A : E) (hU : U ∈ unitary E) : ∥U * A∥ = ∥A∥ :=
  norm_coe_unitary_mul ⟨U, hU⟩ A

@[simp]
theorem norm_mul_coe_unitary (A : E) (U : unitary E) : ∥A * U∥ = ∥A∥ :=
  calc
    _ = ∥((U : E)⋆ * A⋆)⋆∥ := by simp only [star_star, star_mul]
    _ = ∥(U : E)⋆ * A⋆∥ := by rw [norm_star]
    _ = ∥A⋆∥ := norm_mem_unitary_mul (star A) (unitary.star_mem U.Prop)
    _ = ∥A∥ := norm_star _
    

theorem norm_mul_mem_unitary (A : E) {U : E} (hU : U ∈ unitary E) : ∥A * U∥ = ∥A∥ :=
  norm_mul_coe_unitary A ⟨U, hU⟩

end Unital

end CstarRing

theorem IsSelfAdjoint.nnnorm_pow_two_pow [NormedRing E] [StarRing E] [CstarRing E] {x : E} (hx : IsSelfAdjoint x)
    (n : ℕ) : ∥x ^ 2 ^ n∥₊ = ∥x∥₊ ^ 2 ^ n := by
  induction' n with k hk
  · simp only [pow_zero, pow_one]
    
  · rw [pow_succ, pow_mul', sq]
    nth_rw 0 [← self_adjoint.mem_iff.mp hx]
    rw [← star_pow, CstarRing.nnnorm_star_mul_self, ← sq, hk, pow_mul']
    

theorem selfAdjoint.nnnorm_pow_two_pow [NormedRing E] [StarRing E] [CstarRing E] (x : selfAdjoint E) (n : ℕ) :
    ∥x ^ 2 ^ n∥₊ = ∥x∥₊ ^ 2 ^ n :=
  x.Prop.nnnorm_pow_two_pow _

section starₗᵢ

variable [CommSemiring 𝕜] [StarRing 𝕜]

variable [SeminormedAddCommGroup E] [StarAddMonoid E] [NormedStarGroup E]

variable [Module 𝕜 E] [StarModule 𝕜 E]

variable (𝕜)

/-- `star` bundled as a linear isometric equivalence -/
def starₗᵢ : E ≃ₗᵢ⋆[𝕜] E :=
  { starAddEquiv with map_smul' := star_smul, norm_map' := norm_star }

variable {𝕜}

@[simp]
theorem coe_starₗᵢ : (starₗᵢ 𝕜 : E → E) = star :=
  rfl

theorem starₗᵢ_apply {x : E} : starₗᵢ 𝕜 x = star x :=
  rfl

end starₗᵢ

