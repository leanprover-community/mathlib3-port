/-
Copyright (c) 2022 Anatole Dedecker. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Moritz Doll, Frédéric Dupuis, Heather Macbeth

! This file was ported from Lean 3 source module analysis.inner_product_space.symmetric
! leanprover-community/mathlib commit 0b7c740e25651db0ba63648fbae9f9d6f941e31b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.InnerProductSpace.Basic
import Mathbin.Analysis.NormedSpace.Banach
import Mathbin.LinearAlgebra.SesquilinearForm

/-!
# Symmetric linear maps in an inner product space

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines and proves basic theorems about symmetric **not necessarily bounded** operators
on an inner product space, i.e linear maps `T : E → E` such that `∀ x y, ⟪T x, y⟫ = ⟪x, T y⟫`.

In comparison to `is_self_adjoint`, this definition works for non-continuous linear maps, and
doesn't rely on the definition of the adjoint, which allows it to be stated in non-complete space.

## Main definitions

* `linear_map.is_symmetric`: a (not necessarily bounded) operator on an inner product space is
symmetric, if for all `x`, `y`, we have `⟪T x, y⟫ = ⟪x, T y⟫`

## Main statements

* `is_symmetric.continuous`: if a symmetric operator is defined on a complete space, then
  it is automatically continuous.

## Tags

self-adjoint, symmetric
-/


open IsROrC

open ComplexConjugate

variable {𝕜 E E' F G : Type _} [IsROrC 𝕜]

variable [NormedAddCommGroup E] [InnerProductSpace 𝕜 E]

variable [NormedAddCommGroup F] [InnerProductSpace 𝕜 F]

variable [NormedAddCommGroup G] [InnerProductSpace 𝕜 G]

variable [NormedAddCommGroup E'] [InnerProductSpace ℝ E']

-- mathport name: «expr⟪ , ⟫»
local notation "⟪" x ", " y "⟫" => @inner 𝕜 _ _ x y

namespace LinearMap

/-! ### Symmetric operators -/


#print LinearMap.IsSymmetric /-
/-- A (not necessarily bounded) operator on an inner product space is symmetric, if for all
`x`, `y`, we have `⟪T x, y⟫ = ⟪x, T y⟫`. -/
def IsSymmetric (T : E →ₗ[𝕜] E) : Prop :=
  ∀ x y, ⟪T x, y⟫ = ⟪x, T y⟫
#align linear_map.is_symmetric LinearMap.IsSymmetric
-/

section Real

variable ()

/- warning: linear_map.is_symmetric_iff_sesq_form -> LinearMap.isSymmetric_iff_sesqForm is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} {E : Type.{u2}} [_inst_1 : IsROrC.{u1} 𝕜] [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : InnerProductSpace.{u1, u2} 𝕜 E _inst_1 _inst_2] (T : LinearMap.{u1, u1, u2, u2} 𝕜 𝕜 (Ring.toSemiring.{u1} 𝕜 (NormedRing.toRing.{u1} 𝕜 (NormedCommRing.toNormedRing.{u1} 𝕜 (NormedField.toNormedCommRing.{u1} 𝕜 (DenselyNormedField.toNormedField.{u1} 𝕜 (IsROrC.toDenselyNormedField.{u1} 𝕜 _inst_1)))))) (Ring.toSemiring.{u1} 𝕜 (NormedRing.toRing.{u1} 𝕜 (NormedCommRing.toNormedRing.{u1} 𝕜 (NormedField.toNormedCommRing.{u1} 𝕜 (DenselyNormedField.toNormedField.{u1} 𝕜 (IsROrC.toDenselyNormedField.{u1} 𝕜 _inst_1)))))) (RingHom.id.{u1} 𝕜 (Semiring.toNonAssocSemiring.{u1} 𝕜 (Ring.toSemiring.{u1} 𝕜 (NormedRing.toRing.{u1} 𝕜 (NormedCommRing.toNormedRing.{u1} 𝕜 (NormedField.toNormedCommRing.{u1} 𝕜 (DenselyNormedField.toNormedField.{u1} 𝕜 (IsROrC.toDenselyNormedField.{u1} 𝕜 _inst_1)))))))) E E (AddCommGroup.toAddCommMonoid.{u2} E (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2)) (AddCommGroup.toAddCommMonoid.{u2} E (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2)) (NormedSpace.toModule.{u1, u2} 𝕜 E (DenselyNormedField.toNormedField.{u1} 𝕜 (IsROrC.toDenselyNormedField.{u1} 𝕜 _inst_1)) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) (InnerProductSpace.toNormedSpace.{u1, u2} 𝕜 E _inst_1 _inst_2 _inst_3)) (NormedSpace.toModule.{u1, u2} 𝕜 E (DenselyNormedField.toNormedField.{u1} 𝕜 (IsROrC.toDenselyNormedField.{u1} 𝕜 _inst_1)) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) (InnerProductSpace.toNormedSpace.{u1, u2} 𝕜 E _inst_1 _inst_2 _inst_3))), Iff (LinearMap.IsSymmetric.{u1, u2} 𝕜 E _inst_1 _inst_2 _inst_3 T) (LinearMap.IsSelfAdjoint.{u1, u2} 𝕜 E (Semifield.toCommSemiring.{u1} 𝕜 (Field.toSemifield.{u1} 𝕜 (NormedField.toField.{u1} 𝕜 (DenselyNormedField.toNormedField.{u1} 𝕜 (IsROrC.toDenselyNormedField.{u1} 𝕜 _inst_1))))) (AddCommGroup.toAddCommMonoid.{u2} E (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2)) (NormedSpace.toModule.{u1, u2} 𝕜 E (DenselyNormedField.toNormedField.{u1} 𝕜 (IsROrC.toDenselyNormedField.{u1} 𝕜 _inst_1)) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) (InnerProductSpace.toNormedSpace.{u1, u2} 𝕜 E _inst_1 _inst_2 _inst_3)) (starRingEnd.{u1} 𝕜 (Semifield.toCommSemiring.{u1} 𝕜 (Field.toSemifield.{u1} 𝕜 (NormedField.toField.{u1} 𝕜 (DenselyNormedField.toNormedField.{u1} 𝕜 (IsROrC.toDenselyNormedField.{u1} 𝕜 _inst_1))))) (IsROrC.toStarRing.{u1} 𝕜 _inst_1)) (sesqFormOfInner.{u1, u2} 𝕜 E _inst_1 _inst_2 _inst_3) T)
but is expected to have type
  forall {𝕜 : Type.{u2}} {E : Type.{u1}} [_inst_1 : IsROrC.{u2} 𝕜] [_inst_2 : NormedAddCommGroup.{u1} E] [_inst_3 : InnerProductSpace.{u2, u1} 𝕜 E _inst_1 _inst_2] (T : LinearMap.{u2, u2, u1, u1} 𝕜 𝕜 (DivisionSemiring.toSemiring.{u2} 𝕜 (Semifield.toDivisionSemiring.{u2} 𝕜 (Field.toSemifield.{u2} 𝕜 (NormedField.toField.{u2} 𝕜 (DenselyNormedField.toNormedField.{u2} 𝕜 (IsROrC.toDenselyNormedField.{u2} 𝕜 _inst_1)))))) (DivisionSemiring.toSemiring.{u2} 𝕜 (Semifield.toDivisionSemiring.{u2} 𝕜 (Field.toSemifield.{u2} 𝕜 (NormedField.toField.{u2} 𝕜 (DenselyNormedField.toNormedField.{u2} 𝕜 (IsROrC.toDenselyNormedField.{u2} 𝕜 _inst_1)))))) (RingHom.id.{u2} 𝕜 (Semiring.toNonAssocSemiring.{u2} 𝕜 (DivisionSemiring.toSemiring.{u2} 𝕜 (Semifield.toDivisionSemiring.{u2} 𝕜 (Field.toSemifield.{u2} 𝕜 (NormedField.toField.{u2} 𝕜 (DenselyNormedField.toNormedField.{u2} 𝕜 (IsROrC.toDenselyNormedField.{u2} 𝕜 _inst_1)))))))) E E (AddCommGroup.toAddCommMonoid.{u1} E (NormedAddCommGroup.toAddCommGroup.{u1} E _inst_2)) (AddCommGroup.toAddCommMonoid.{u1} E (NormedAddCommGroup.toAddCommGroup.{u1} E _inst_2)) (NormedSpace.toModule.{u2, u1} 𝕜 E (DenselyNormedField.toNormedField.{u2} 𝕜 (IsROrC.toDenselyNormedField.{u2} 𝕜 _inst_1)) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2) (InnerProductSpace.toNormedSpace.{u2, u1} 𝕜 E _inst_1 _inst_2 _inst_3)) (NormedSpace.toModule.{u2, u1} 𝕜 E (DenselyNormedField.toNormedField.{u2} 𝕜 (IsROrC.toDenselyNormedField.{u2} 𝕜 _inst_1)) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2) (InnerProductSpace.toNormedSpace.{u2, u1} 𝕜 E _inst_1 _inst_2 _inst_3))), Iff (LinearMap.IsSymmetric.{u2, u1} 𝕜 E _inst_1 _inst_2 _inst_3 T) (LinearMap.IsSelfAdjoint.{u2, u1} 𝕜 E (Semifield.toCommSemiring.{u2} 𝕜 (Field.toSemifield.{u2} 𝕜 (NormedField.toField.{u2} 𝕜 (DenselyNormedField.toNormedField.{u2} 𝕜 (IsROrC.toDenselyNormedField.{u2} 𝕜 _inst_1))))) (AddCommGroup.toAddCommMonoid.{u1} E (NormedAddCommGroup.toAddCommGroup.{u1} E _inst_2)) (NormedSpace.toModule.{u2, u1} 𝕜 E (DenselyNormedField.toNormedField.{u2} 𝕜 (IsROrC.toDenselyNormedField.{u2} 𝕜 _inst_1)) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2) (InnerProductSpace.toNormedSpace.{u2, u1} 𝕜 E _inst_1 _inst_2 _inst_3)) (starRingEnd.{u2} 𝕜 (Semifield.toCommSemiring.{u2} 𝕜 (Field.toSemifield.{u2} 𝕜 (NormedField.toField.{u2} 𝕜 (DenselyNormedField.toNormedField.{u2} 𝕜 (IsROrC.toDenselyNormedField.{u2} 𝕜 _inst_1))))) (IsROrC.toStarRing.{u2} 𝕜 _inst_1)) (sesqFormOfInner.{u2, u1} 𝕜 E _inst_1 _inst_2 _inst_3) T)
Case conversion may be inaccurate. Consider using '#align linear_map.is_symmetric_iff_sesq_form LinearMap.isSymmetric_iff_sesqFormₓ'. -/
/-- An operator `T` on an inner product space is symmetric if and only if it is
`linear_map.is_self_adjoint` with respect to the sesquilinear form given by the inner product. -/
theorem isSymmetric_iff_sesqForm (T : E →ₗ[𝕜] E) :
    T.IsSymmetric ↔ @LinearMap.IsSelfAdjoint 𝕜 E _ _ _ (starRingEnd 𝕜) sesqFormOfInner T :=
  ⟨fun h x y => (h y x).symm, fun h x y => (h y x).symm⟩
#align linear_map.is_symmetric_iff_sesq_form LinearMap.isSymmetric_iff_sesqForm

end Real

/- warning: linear_map.is_symmetric.conj_inner_sym -> LinearMap.IsSymmetric.conj_inner_sym is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align linear_map.is_symmetric.conj_inner_sym LinearMap.IsSymmetric.conj_inner_symₓ'. -/
theorem IsSymmetric.conj_inner_sym {T : E →ₗ[𝕜] E} (hT : IsSymmetric T) (x y : E) :
    conj ⟪T x, y⟫ = ⟪T y, x⟫ := by rw [hT x y, inner_conj_symm]
#align linear_map.is_symmetric.conj_inner_sym LinearMap.IsSymmetric.conj_inner_sym

/- warning: linear_map.is_symmetric.apply_clm -> LinearMap.IsSymmetric.apply_clm is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align linear_map.is_symmetric.apply_clm LinearMap.IsSymmetric.apply_clmₓ'. -/
@[simp]
theorem IsSymmetric.apply_clm {T : E →L[𝕜] E} (hT : IsSymmetric (T : E →ₗ[𝕜] E)) (x y : E) :
    ⟪T x, y⟫ = ⟪x, T y⟫ :=
  hT x y
#align linear_map.is_symmetric.apply_clm LinearMap.IsSymmetric.apply_clm

/- warning: linear_map.is_symmetric_zero -> LinearMap.isSymmetric_zero is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align linear_map.is_symmetric_zero LinearMap.isSymmetric_zeroₓ'. -/
theorem isSymmetric_zero : (0 : E →ₗ[𝕜] E).IsSymmetric := fun x y =>
  (inner_zero_right x : ⟪x, 0⟫ = 0).symm ▸ (inner_zero_left y : ⟪0, y⟫ = 0)
#align linear_map.is_symmetric_zero LinearMap.isSymmetric_zero

/- warning: linear_map.is_symmetric_id -> LinearMap.isSymmetric_id is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} {E : Type.{u2}} [_inst_1 : IsROrC.{u1} 𝕜] [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : InnerProductSpace.{u1, u2} 𝕜 E _inst_1 _inst_2], LinearMap.IsSymmetric.{u1, u2} 𝕜 E _inst_1 _inst_2 _inst_3 (LinearMap.id.{u1, u2} 𝕜 E (Ring.toSemiring.{u1} 𝕜 (NormedRing.toRing.{u1} 𝕜 (NormedCommRing.toNormedRing.{u1} 𝕜 (NormedField.toNormedCommRing.{u1} 𝕜 (DenselyNormedField.toNormedField.{u1} 𝕜 (IsROrC.toDenselyNormedField.{u1} 𝕜 _inst_1)))))) (AddCommGroup.toAddCommMonoid.{u2} E (NormedAddCommGroup.toAddCommGroup.{u2} E _inst_2)) (NormedSpace.toModule.{u1, u2} 𝕜 E (DenselyNormedField.toNormedField.{u1} 𝕜 (IsROrC.toDenselyNormedField.{u1} 𝕜 _inst_1)) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) (InnerProductSpace.toNormedSpace.{u1, u2} 𝕜 E _inst_1 _inst_2 _inst_3)))
but is expected to have type
  forall {𝕜 : Type.{u2}} {E : Type.{u1}} [_inst_1 : IsROrC.{u2} 𝕜] [_inst_2 : NormedAddCommGroup.{u1} E] [_inst_3 : InnerProductSpace.{u2, u1} 𝕜 E _inst_1 _inst_2], LinearMap.IsSymmetric.{u2, u1} 𝕜 E _inst_1 _inst_2 _inst_3 (LinearMap.id.{u2, u1} 𝕜 E (DivisionSemiring.toSemiring.{u2} 𝕜 (Semifield.toDivisionSemiring.{u2} 𝕜 (Field.toSemifield.{u2} 𝕜 (NormedField.toField.{u2} 𝕜 (DenselyNormedField.toNormedField.{u2} 𝕜 (IsROrC.toDenselyNormedField.{u2} 𝕜 _inst_1)))))) (AddCommGroup.toAddCommMonoid.{u1} E (NormedAddCommGroup.toAddCommGroup.{u1} E _inst_2)) (NormedSpace.toModule.{u2, u1} 𝕜 E (DenselyNormedField.toNormedField.{u2} 𝕜 (IsROrC.toDenselyNormedField.{u2} 𝕜 _inst_1)) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2) (InnerProductSpace.toNormedSpace.{u2, u1} 𝕜 E _inst_1 _inst_2 _inst_3)))
Case conversion may be inaccurate. Consider using '#align linear_map.is_symmetric_id LinearMap.isSymmetric_idₓ'. -/
theorem isSymmetric_id : (LinearMap.id : E →ₗ[𝕜] E).IsSymmetric := fun x y => rfl
#align linear_map.is_symmetric_id LinearMap.isSymmetric_id

/- warning: linear_map.is_symmetric.add -> LinearMap.IsSymmetric.add is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align linear_map.is_symmetric.add LinearMap.IsSymmetric.addₓ'. -/
theorem IsSymmetric.add {T S : E →ₗ[𝕜] E} (hT : T.IsSymmetric) (hS : S.IsSymmetric) :
    (T + S).IsSymmetric := by
  intro x y
  rw [LinearMap.add_apply, inner_add_left, hT x y, hS x y, ← inner_add_right]
  rfl
#align linear_map.is_symmetric.add LinearMap.IsSymmetric.add

/- warning: linear_map.is_symmetric.continuous -> LinearMap.IsSymmetric.continuous is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align linear_map.is_symmetric.continuous LinearMap.IsSymmetric.continuousₓ'. -/
/-- The **Hellinger--Toeplitz theorem**: if a symmetric operator is defined on a complete space,
  then it is automatically continuous. -/
theorem IsSymmetric.continuous [CompleteSpace E] {T : E →ₗ[𝕜] E} (hT : IsSymmetric T) :
    Continuous T :=
  by
  -- We prove it by using the closed graph theorem
  refine' T.continuous_of_seq_closed_graph fun u x y hu hTu => _
  rw [← sub_eq_zero, ← @inner_self_eq_zero 𝕜]
  have hlhs : ∀ k : ℕ, ⟪T (u k) - T x, y - T x⟫ = ⟪u k - x, T (y - T x)⟫ :=
    by
    intro k
    rw [← T.map_sub, hT]
  refine' tendsto_nhds_unique ((hTu.sub_const _).inner tendsto_const_nhds) _
  simp_rw [hlhs]
  rw [← inner_zero_left (T (y - T x))]
  refine' Filter.Tendsto.inner _ tendsto_const_nhds
  rw [← sub_self x]
  exact hu.sub_const _
#align linear_map.is_symmetric.continuous LinearMap.IsSymmetric.continuous

/- warning: linear_map.is_symmetric.coe_re_apply_inner_self_apply -> LinearMap.IsSymmetric.coe_reApplyInnerSelf_apply is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align linear_map.is_symmetric.coe_re_apply_inner_self_apply LinearMap.IsSymmetric.coe_reApplyInnerSelf_applyₓ'. -/
/-- For a symmetric operator `T`, the function `λ x, ⟪T x, x⟫` is real-valued. -/
@[simp]
theorem IsSymmetric.coe_reApplyInnerSelf_apply {T : E →L[𝕜] E} (hT : IsSymmetric (T : E →ₗ[𝕜] E))
    (x : E) : (T.reApplyInnerSelf x : 𝕜) = ⟪T x, x⟫ :=
  by
  rsuffices ⟨r, hr⟩ : ∃ r : ℝ, ⟪T x, x⟫ = r
  · simp [hr, T.re_apply_inner_self_apply]
  rw [← conj_eq_iff_real]
  exact hT.conj_inner_sym x x
#align linear_map.is_symmetric.coe_re_apply_inner_self_apply LinearMap.IsSymmetric.coe_reApplyInnerSelf_apply

/- warning: linear_map.is_symmetric.restrict_invariant -> LinearMap.IsSymmetric.restrict_invariant is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align linear_map.is_symmetric.restrict_invariant LinearMap.IsSymmetric.restrict_invariantₓ'. -/
/-- If a symmetric operator preserves a submodule, its restriction to that submodule is
symmetric. -/
theorem IsSymmetric.restrict_invariant {T : E →ₗ[𝕜] E} (hT : IsSymmetric T) {V : Submodule 𝕜 E}
    (hV : ∀ v ∈ V, T v ∈ V) : IsSymmetric (T.restrict hV) := fun v w => hT v w
#align linear_map.is_symmetric.restrict_invariant LinearMap.IsSymmetric.restrict_invariant

/- warning: linear_map.is_symmetric.restrict_scalars -> LinearMap.IsSymmetric.restrictScalars is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align linear_map.is_symmetric.restrict_scalars LinearMap.IsSymmetric.restrictScalarsₓ'. -/
theorem IsSymmetric.restrictScalars {T : E →ₗ[𝕜] E} (hT : T.IsSymmetric) :
    @LinearMap.IsSymmetric ℝ E _ _ (InnerProductSpace.isROrCToReal 𝕜 E)
      (@LinearMap.restrictScalars ℝ 𝕜 _ _ _ _ _ _ (InnerProductSpace.isROrCToReal 𝕜 E).toModule
        (InnerProductSpace.isROrCToReal 𝕜 E).toModule _ _ _ T) :=
  fun x y => by simp [hT x y, real_inner_eq_re_inner, LinearMap.coe_restrictScalars]
#align linear_map.is_symmetric.restrict_scalars LinearMap.IsSymmetric.restrictScalars

section Complex

variable {V : Type _} [NormedAddCommGroup V] [InnerProductSpace ℂ V]

/- warning: linear_map.is_symmetric_iff_inner_map_self_real -> LinearMap.isSymmetric_iff_inner_map_self_real is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align linear_map.is_symmetric_iff_inner_map_self_real LinearMap.isSymmetric_iff_inner_map_self_realₓ'. -/
/-- A linear operator on a complex inner product space is symmetric precisely when
`⟪T v, v⟫_ℂ` is real for all v.-/
theorem isSymmetric_iff_inner_map_self_real (T : V →ₗ[ℂ] V) :
    IsSymmetric T ↔ ∀ v : V, conj ⟪T v, v⟫_ℂ = ⟪T v, v⟫_ℂ :=
  by
  constructor
  · intro hT v
    apply is_symmetric.conj_inner_sym hT
  · intro h x y
    nth_rw 2 [← inner_conj_symm]
    nth_rw 2 [inner_map_polarization]
    simp only [starRingEnd_apply, star_div', star_sub, star_add, star_mul]
    simp only [← starRingEnd_apply]
    rw [h (x + y), h (x - y), h (x + Complex.I • y), h (x - Complex.I • y)]
    simp only [Complex.conj_I]
    rw [inner_map_polarization']
    norm_num
    ring
#align linear_map.is_symmetric_iff_inner_map_self_real LinearMap.isSymmetric_iff_inner_map_self_real

end Complex

/- warning: linear_map.is_symmetric.inner_map_polarization -> LinearMap.IsSymmetric.inner_map_polarization is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align linear_map.is_symmetric.inner_map_polarization LinearMap.IsSymmetric.inner_map_polarizationₓ'. -/
/-- Polarization identity for symmetric linear maps.
See `inner_map_polarization` for the complex version without the symmetric assumption. -/
theorem IsSymmetric.inner_map_polarization {T : E →ₗ[𝕜] E} (hT : T.IsSymmetric) (x y : E) :
    ⟪T x, y⟫ =
      (⟪T (x + y), x + y⟫ - ⟪T (x - y), x - y⟫ - i * ⟪T (x + (i : 𝕜) • y), x + (i : 𝕜) • y⟫ +
          i * ⟪T (x - (i : 𝕜) • y), x - (i : 𝕜) • y⟫) /
        4 :=
  by
  rcases@I_mul_I_ax 𝕜 _ with (h | h)
  · simp_rw [h, MulZeroClass.zero_mul, sub_zero, add_zero, map_add, map_sub, inner_add_left,
      inner_add_right, inner_sub_left, inner_sub_right, hT x, ← inner_conj_symm x (T y)]
    suffices (re ⟪T y, x⟫ : 𝕜) = ⟪T y, x⟫
      by
      rw [conj_eq_iff_re.mpr this]
      ring
    · rw [← re_add_im ⟪T y, x⟫]
      simp_rw [h, MulZeroClass.mul_zero, add_zero]
      norm_cast
  · simp_rw [map_add, map_sub, inner_add_left, inner_add_right, inner_sub_left, inner_sub_right,
      LinearMap.map_smul, inner_smul_left, inner_smul_right, IsROrC.conj_I, mul_add, mul_sub,
      sub_sub, ← mul_assoc, mul_neg, h, neg_neg, one_mul, neg_one_mul]
    ring
#align linear_map.is_symmetric.inner_map_polarization LinearMap.IsSymmetric.inner_map_polarization

/- warning: linear_map.is_symmetric.inner_map_self_eq_zero -> LinearMap.IsSymmetric.inner_map_self_eq_zero is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align linear_map.is_symmetric.inner_map_self_eq_zero LinearMap.IsSymmetric.inner_map_self_eq_zeroₓ'. -/
/-- A symmetric linear map `T` is zero if and only if `⟪T x, x⟫_ℝ = 0` for all `x`.
See `inner_map_self_eq_zero` for the complex version without the symmetric assumption. -/
theorem IsSymmetric.inner_map_self_eq_zero {T : E →ₗ[𝕜] E} (hT : T.IsSymmetric) :
    (∀ x, ⟪T x, x⟫ = 0) ↔ T = 0 :=
  by
  simp_rw [LinearMap.ext_iff, zero_apply]
  refine' ⟨fun h x => _, fun h => by simp_rw [h, inner_zero_left, forall_const]⟩
  rw [← @inner_self_eq_zero 𝕜, hT.inner_map_polarization]
  simp_rw [h _]
  ring
#align linear_map.is_symmetric.inner_map_self_eq_zero LinearMap.IsSymmetric.inner_map_self_eq_zero

end LinearMap

