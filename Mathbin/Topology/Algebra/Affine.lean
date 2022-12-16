/-
Copyright (c) 2020 Frédéric Dupuis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Frédéric Dupuis

! This file was ported from Lean 3 source module topology.algebra.affine
! leanprover-community/mathlib commit d012cd09a9b256d870751284dd6a29882b0be105
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.AffineSpace.AffineMap
import Mathbin.Topology.Algebra.Group.Basic
import Mathbin.Topology.Algebra.MulAction

/-!
# Topological properties of affine spaces and maps

For now, this contains only a few facts regarding the continuity of affine maps in the special
case when the point space and vector space are the same.

TODO: Deal with the case where the point spaces are different from the vector spaces. Note that
we do have some results in this direction under the assumption that the topologies are induced by
(semi)norms.
-/


namespace AffineMap

variable {R E F : Type _}

variable [AddCommGroup E] [TopologicalSpace E]

variable [AddCommGroup F] [TopologicalSpace F] [TopologicalAddGroup F]

section Ring

variable [Ring R] [Module R E] [Module R F]

/-- An affine map is continuous iff its underlying linear map is continuous. See also
`affine_map.continuous_linear_iff`. -/
theorem continuous_iff {f : E →ᵃ[R] F} : Continuous f ↔ Continuous f.linear := by
  constructor
  · intro hc
    rw [decomp' f]
    have := hc.sub continuous_const
    exact this
  · intro hc
    rw [decomp f]
    have := hc.add continuous_const
    exact this
#align affine_map.continuous_iff AffineMap.continuous_iff

/-- The line map is continuous. -/
@[continuity]
theorem line_map_continuous [TopologicalSpace R] [HasContinuousSmul R F] {p v : F} :
    Continuous ⇑(lineMap p v : R →ᵃ[R] F) :=
  continuous_iff.mpr <|
    (continuous_id.smul continuous_const).add <| @continuous_const _ _ _ _ (0 : F)
#align affine_map.line_map_continuous AffineMap.line_map_continuous

end Ring

section CommRing

variable [CommRing R] [Module R F] [HasContinuousConstSmul R F]

@[continuity]
theorem homothety_continuous (x : F) (t : R) : Continuous <| homothety x t := by
  suffices ⇑(homothety x t) = fun y => t • (y - x) + x by
    rw [this]
    continuity
  ext y
  simp [homothety_apply]
#align affine_map.homothety_continuous AffineMap.homothety_continuous

end CommRing

section Field

variable [Field R] [Module R F] [HasContinuousConstSmul R F]

theorem homothety_is_open_map (x : F) (t : R) (ht : t ≠ 0) : IsOpenMap <| homothety x t := by
  apply IsOpenMap.of_inverse (homothety_continuous x t⁻¹) <;> intro e <;>
    simp [← AffineMap.comp_apply, ← homothety_mul, ht]
#align affine_map.homothety_is_open_map AffineMap.homothety_is_open_map

end Field

end AffineMap

