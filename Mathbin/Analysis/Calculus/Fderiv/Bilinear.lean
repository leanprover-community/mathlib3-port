/-
Copyright (c) 2019 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Sébastien Gouëzel, Yury Kudryashov

! This file was ported from Lean 3 source module analysis.calculus.fderiv.bilinear
! leanprover-community/mathlib commit 0b7c740e25651db0ba63648fbae9f9d6f941e31b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.Fderiv.Prod

/-!
# The derivative of bounded bilinear maps

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

For detailed documentation of the Fréchet derivative,
see the module docstring of `analysis/calculus/fderiv/basic.lean`.

This file contains the usual formulas (and existence assertions) for the derivative of
bounded bilinear maps.
-/


open Filter Asymptotics ContinuousLinearMap Set Metric

open Topology Classical NNReal Filter Asymptotics ENNReal

noncomputable section

section

variable {𝕜 : Type _} [NontriviallyNormedField 𝕜]

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace 𝕜 E]

variable {F : Type _} [NormedAddCommGroup F] [NormedSpace 𝕜 F]

variable {G : Type _} [NormedAddCommGroup G] [NormedSpace 𝕜 G]

variable {G' : Type _} [NormedAddCommGroup G'] [NormedSpace 𝕜 G']

variable {f f₀ f₁ g : E → F}

variable {f' f₀' f₁' g' : E →L[𝕜] F}

variable (e : E →L[𝕜] F)

variable {x : E}

variable {s t : Set E}

variable {L L₁ L₂ : Filter E}

section BilinearMap

/-! ### Derivative of a bounded bilinear map -/


variable {b : E × F → G} {u : Set (E × F)}

open NormedField

/- warning: is_bounded_bilinear_map.has_strict_fderiv_at -> IsBoundedBilinearMap.hasStrictFDerivAt is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u1, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u4}} [_inst_6 : NormedAddCommGroup.{u4} G] [_inst_7 : NormedSpace.{u1, u4} 𝕜 G (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u4} G _inst_6)] {b : (Prod.{u2, u3} E F) -> G} (h : IsBoundedBilinearMap.{u1, u2, u3, u4} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 G _inst_6 _inst_7 b) (p : Prod.{u2, u3} E F), HasStrictFDerivAt.{u1, max u2 u3, u4} 𝕜 _inst_1 (Prod.{u2, u3} E F) (Prod.normedAddCommGroup.{u2, u3} E F _inst_2 _inst_4) (Prod.normedSpace.{u1, u2, u3} 𝕜 (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) E (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3 F (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4) _inst_5) G _inst_6 _inst_7 b (IsBoundedBilinearMap.deriv.{u1, u2, u3, u4} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 G _inst_6 _inst_7 b h p) p
but is expected to have type
  forall {𝕜 : Type.{u4}} [_inst_1 : NontriviallyNormedField.{u4} 𝕜] {E : Type.{u3}} [_inst_2 : NormedAddCommGroup.{u3} E] [_inst_3 : NormedSpace.{u4, u3} 𝕜 E (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} E _inst_2)] {F : Type.{u2}} [_inst_4 : NormedAddCommGroup.{u2} F] [_inst_5 : NormedSpace.{u4, u2} 𝕜 F (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} F _inst_4)] {G : Type.{u1}} [_inst_6 : NormedAddCommGroup.{u1} G] [_inst_7 : NormedSpace.{u4, u1} 𝕜 G (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} G _inst_6)] {b : (Prod.{u3, u2} E F) -> G} (h : IsBoundedBilinearMap.{u4, u3, u2, u1} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 G _inst_6 _inst_7 b) (p : Prod.{u3, u2} E F), HasStrictFDerivAt.{u4, max u3 u2, u1} 𝕜 _inst_1 (Prod.{u3, u2} E F) (Prod.normedAddCommGroup.{u3, u2} E F _inst_2 _inst_4) (Prod.normedSpace.{u4, u3, u2} 𝕜 (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) E (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} E _inst_2) _inst_3 F (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} F _inst_4) _inst_5) G _inst_6 _inst_7 b (IsBoundedBilinearMap.deriv.{u4, u3, u2, u1} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 G _inst_6 _inst_7 b h p) p
Case conversion may be inaccurate. Consider using '#align is_bounded_bilinear_map.has_strict_fderiv_at IsBoundedBilinearMap.hasStrictFDerivAtₓ'. -/
theorem IsBoundedBilinearMap.hasStrictFDerivAt (h : IsBoundedBilinearMap 𝕜 b) (p : E × F) :
    HasStrictFDerivAt b (h.deriv p) p :=
  by
  rw [HasStrictFDerivAt]
  set T := (E × F) × E × F
  have : (fun q : T => b (q.1 - q.2)) =o[𝓝 (p, p)] fun q : T => ‖q.1 - q.2‖ * 1 :=
    by
    refine' (h.is_O'.comp_tendsto le_top).trans_isLittleO _
    simp only [(· ∘ ·)]
    refine'
      (is_O_refl (fun q : T => ‖q.1 - q.2‖) _).mul_isLittleO
        (is_o.norm_left <| (is_o_one_iff _).2 _)
    rw [← sub_self p]
    exact continuous_at_fst.sub continuousAt_snd
  simp only [mul_one, is_o_norm_right] at this
  refine' (is_o.congr_of_sub _).1 this; clear this
  convert_to(fun q : T => h.deriv (p - q.2) (q.1 - q.2)) =o[𝓝 (p, p)] fun q : T => q.1 - q.2
  · ext ⟨⟨x₁, y₁⟩, ⟨x₂, y₂⟩⟩; rcases p with ⟨x, y⟩
    simp only [IsBoundedBilinearMap.deriv_apply, Prod.mk_sub_mk, h.map_sub_left, h.map_sub_right]
    abel
  have : (fun q : T => p - q.2) =o[𝓝 (p, p)] fun q => (1 : ℝ) :=
    (is_o_one_iff _).2 (sub_self p ▸ tendsto_const_nhds.sub continuousAt_snd)
  apply is_bounded_bilinear_map_apply.is_O_comp.trans_is_o
  refine' is_o.trans_is_O _ (is_O_const_mul_self 1 _ _).of_norm_right
  refine' is_o.mul_is_O _ (is_O_refl _ _)
  exact
    (((h.is_bounded_linear_map_deriv.is_O_id ⊤).comp_tendsto le_top : _).trans_isLittleO
        this).norm_left
#align is_bounded_bilinear_map.has_strict_fderiv_at IsBoundedBilinearMap.hasStrictFDerivAt

/- warning: is_bounded_bilinear_map.has_fderiv_at -> IsBoundedBilinearMap.hasFDerivAt is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u1, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u4}} [_inst_6 : NormedAddCommGroup.{u4} G] [_inst_7 : NormedSpace.{u1, u4} 𝕜 G (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u4} G _inst_6)] {b : (Prod.{u2, u3} E F) -> G} (h : IsBoundedBilinearMap.{u1, u2, u3, u4} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 G _inst_6 _inst_7 b) (p : Prod.{u2, u3} E F), HasFDerivAt.{u1, max u2 u3, u4} 𝕜 _inst_1 (Prod.{u2, u3} E F) (Prod.normedAddCommGroup.{u2, u3} E F _inst_2 _inst_4) (Prod.normedSpace.{u1, u2, u3} 𝕜 (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) E (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3 F (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4) _inst_5) G _inst_6 _inst_7 b (IsBoundedBilinearMap.deriv.{u1, u2, u3, u4} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 G _inst_6 _inst_7 b h p) p
but is expected to have type
  forall {𝕜 : Type.{u4}} [_inst_1 : NontriviallyNormedField.{u4} 𝕜] {E : Type.{u3}} [_inst_2 : NormedAddCommGroup.{u3} E] [_inst_3 : NormedSpace.{u4, u3} 𝕜 E (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} E _inst_2)] {F : Type.{u2}} [_inst_4 : NormedAddCommGroup.{u2} F] [_inst_5 : NormedSpace.{u4, u2} 𝕜 F (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} F _inst_4)] {G : Type.{u1}} [_inst_6 : NormedAddCommGroup.{u1} G] [_inst_7 : NormedSpace.{u4, u1} 𝕜 G (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} G _inst_6)] {b : (Prod.{u3, u2} E F) -> G} (h : IsBoundedBilinearMap.{u4, u3, u2, u1} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 G _inst_6 _inst_7 b) (p : Prod.{u3, u2} E F), HasFDerivAt.{u4, max u3 u2, u1} 𝕜 _inst_1 (Prod.{u3, u2} E F) (Prod.normedAddCommGroup.{u3, u2} E F _inst_2 _inst_4) (Prod.normedSpace.{u4, u3, u2} 𝕜 (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) E (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} E _inst_2) _inst_3 F (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} F _inst_4) _inst_5) G _inst_6 _inst_7 b (IsBoundedBilinearMap.deriv.{u4, u3, u2, u1} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 G _inst_6 _inst_7 b h p) p
Case conversion may be inaccurate. Consider using '#align is_bounded_bilinear_map.has_fderiv_at IsBoundedBilinearMap.hasFDerivAtₓ'. -/
theorem IsBoundedBilinearMap.hasFDerivAt (h : IsBoundedBilinearMap 𝕜 b) (p : E × F) :
    HasFDerivAt b (h.deriv p) p :=
  (h.HasStrictFDerivAt p).HasFDerivAt
#align is_bounded_bilinear_map.has_fderiv_at IsBoundedBilinearMap.hasFDerivAt

/- warning: is_bounded_bilinear_map.has_fderiv_within_at -> IsBoundedBilinearMap.hasFDerivWithinAt is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align is_bounded_bilinear_map.has_fderiv_within_at IsBoundedBilinearMap.hasFDerivWithinAtₓ'. -/
theorem IsBoundedBilinearMap.hasFDerivWithinAt (h : IsBoundedBilinearMap 𝕜 b) (p : E × F) :
    HasFDerivWithinAt b (h.deriv p) u p :=
  (h.HasFDerivAt p).HasFDerivWithinAt
#align is_bounded_bilinear_map.has_fderiv_within_at IsBoundedBilinearMap.hasFDerivWithinAt

/- warning: is_bounded_bilinear_map.differentiable_at -> IsBoundedBilinearMap.differentiableAt is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u1, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u4}} [_inst_6 : NormedAddCommGroup.{u4} G] [_inst_7 : NormedSpace.{u1, u4} 𝕜 G (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u4} G _inst_6)] {b : (Prod.{u2, u3} E F) -> G}, (IsBoundedBilinearMap.{u1, u2, u3, u4} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 G _inst_6 _inst_7 b) -> (forall (p : Prod.{u2, u3} E F), DifferentiableAt.{u1, max u2 u3, u4} 𝕜 _inst_1 (Prod.{u2, u3} E F) (Prod.normedAddCommGroup.{u2, u3} E F _inst_2 _inst_4) (Prod.normedSpace.{u1, u2, u3} 𝕜 (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) E (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3 F (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4) _inst_5) G _inst_6 _inst_7 b p)
but is expected to have type
  forall {𝕜 : Type.{u4}} [_inst_1 : NontriviallyNormedField.{u4} 𝕜] {E : Type.{u3}} [_inst_2 : NormedAddCommGroup.{u3} E] [_inst_3 : NormedSpace.{u4, u3} 𝕜 E (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} E _inst_2)] {F : Type.{u2}} [_inst_4 : NormedAddCommGroup.{u2} F] [_inst_5 : NormedSpace.{u4, u2} 𝕜 F (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} F _inst_4)] {G : Type.{u1}} [_inst_6 : NormedAddCommGroup.{u1} G] [_inst_7 : NormedSpace.{u4, u1} 𝕜 G (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} G _inst_6)] {b : (Prod.{u3, u2} E F) -> G}, (IsBoundedBilinearMap.{u4, u3, u2, u1} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 G _inst_6 _inst_7 b) -> (forall (p : Prod.{u3, u2} E F), DifferentiableAt.{u4, max u3 u2, u1} 𝕜 _inst_1 (Prod.{u3, u2} E F) (Prod.normedAddCommGroup.{u3, u2} E F _inst_2 _inst_4) (Prod.normedSpace.{u4, u3, u2} 𝕜 (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) E (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} E _inst_2) _inst_3 F (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} F _inst_4) _inst_5) G _inst_6 _inst_7 b p)
Case conversion may be inaccurate. Consider using '#align is_bounded_bilinear_map.differentiable_at IsBoundedBilinearMap.differentiableAtₓ'. -/
theorem IsBoundedBilinearMap.differentiableAt (h : IsBoundedBilinearMap 𝕜 b) (p : E × F) :
    DifferentiableAt 𝕜 b p :=
  (h.HasFDerivAt p).DifferentiableAt
#align is_bounded_bilinear_map.differentiable_at IsBoundedBilinearMap.differentiableAt

/- warning: is_bounded_bilinear_map.differentiable_within_at -> IsBoundedBilinearMap.differentiableWithinAt is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align is_bounded_bilinear_map.differentiable_within_at IsBoundedBilinearMap.differentiableWithinAtₓ'. -/
theorem IsBoundedBilinearMap.differentiableWithinAt (h : IsBoundedBilinearMap 𝕜 b) (p : E × F) :
    DifferentiableWithinAt 𝕜 b u p :=
  (h.DifferentiableAt p).DifferentiableWithinAt
#align is_bounded_bilinear_map.differentiable_within_at IsBoundedBilinearMap.differentiableWithinAt

/- warning: is_bounded_bilinear_map.fderiv -> IsBoundedBilinearMap.fderiv is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align is_bounded_bilinear_map.fderiv IsBoundedBilinearMap.fderivₓ'. -/
theorem IsBoundedBilinearMap.fderiv (h : IsBoundedBilinearMap 𝕜 b) (p : E × F) :
    fderiv 𝕜 b p = h.deriv p :=
  HasFDerivAt.fderiv (h.HasFDerivAt p)
#align is_bounded_bilinear_map.fderiv IsBoundedBilinearMap.fderiv

/- warning: is_bounded_bilinear_map.fderiv_within -> IsBoundedBilinearMap.fderivWithin is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align is_bounded_bilinear_map.fderiv_within IsBoundedBilinearMap.fderivWithinₓ'. -/
theorem IsBoundedBilinearMap.fderivWithin (h : IsBoundedBilinearMap 𝕜 b) (p : E × F)
    (hxs : UniqueDiffWithinAt 𝕜 u p) : fderivWithin 𝕜 b u p = h.deriv p :=
  by
  rw [DifferentiableAt.fderivWithin (h.differentiable_at p) hxs]
  exact h.fderiv p
#align is_bounded_bilinear_map.fderiv_within IsBoundedBilinearMap.fderivWithin

/- warning: is_bounded_bilinear_map.differentiable -> IsBoundedBilinearMap.differentiable is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u1, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u4}} [_inst_6 : NormedAddCommGroup.{u4} G] [_inst_7 : NormedSpace.{u1, u4} 𝕜 G (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u4} G _inst_6)] {b : (Prod.{u2, u3} E F) -> G}, (IsBoundedBilinearMap.{u1, u2, u3, u4} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 G _inst_6 _inst_7 b) -> (Differentiable.{u1, max u2 u3, u4} 𝕜 _inst_1 (Prod.{u2, u3} E F) (Prod.normedAddCommGroup.{u2, u3} E F _inst_2 _inst_4) (Prod.normedSpace.{u1, u2, u3} 𝕜 (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) E (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3 F (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4) _inst_5) G _inst_6 _inst_7 b)
but is expected to have type
  forall {𝕜 : Type.{u4}} [_inst_1 : NontriviallyNormedField.{u4} 𝕜] {E : Type.{u3}} [_inst_2 : NormedAddCommGroup.{u3} E] [_inst_3 : NormedSpace.{u4, u3} 𝕜 E (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} E _inst_2)] {F : Type.{u2}} [_inst_4 : NormedAddCommGroup.{u2} F] [_inst_5 : NormedSpace.{u4, u2} 𝕜 F (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} F _inst_4)] {G : Type.{u1}} [_inst_6 : NormedAddCommGroup.{u1} G] [_inst_7 : NormedSpace.{u4, u1} 𝕜 G (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} G _inst_6)] {b : (Prod.{u3, u2} E F) -> G}, (IsBoundedBilinearMap.{u4, u3, u2, u1} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 G _inst_6 _inst_7 b) -> (Differentiable.{u4, max u3 u2, u1} 𝕜 _inst_1 (Prod.{u3, u2} E F) (Prod.normedAddCommGroup.{u3, u2} E F _inst_2 _inst_4) (Prod.normedSpace.{u4, u3, u2} 𝕜 (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) E (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} E _inst_2) _inst_3 F (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} F _inst_4) _inst_5) G _inst_6 _inst_7 b)
Case conversion may be inaccurate. Consider using '#align is_bounded_bilinear_map.differentiable IsBoundedBilinearMap.differentiableₓ'. -/
theorem IsBoundedBilinearMap.differentiable (h : IsBoundedBilinearMap 𝕜 b) : Differentiable 𝕜 b :=
  fun x => h.DifferentiableAt x
#align is_bounded_bilinear_map.differentiable IsBoundedBilinearMap.differentiable

/- warning: is_bounded_bilinear_map.differentiable_on -> IsBoundedBilinearMap.differentiableOn is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u1, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u4}} [_inst_6 : NormedAddCommGroup.{u4} G] [_inst_7 : NormedSpace.{u1, u4} 𝕜 G (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u4} G _inst_6)] {b : (Prod.{u2, u3} E F) -> G} {u : Set.{max u2 u3} (Prod.{u2, u3} E F)}, (IsBoundedBilinearMap.{u1, u2, u3, u4} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 G _inst_6 _inst_7 b) -> (DifferentiableOn.{u1, max u2 u3, u4} 𝕜 _inst_1 (Prod.{u2, u3} E F) (Prod.normedAddCommGroup.{u2, u3} E F _inst_2 _inst_4) (Prod.normedSpace.{u1, u2, u3} 𝕜 (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) E (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2) _inst_3 F (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4) _inst_5) G _inst_6 _inst_7 b u)
but is expected to have type
  forall {𝕜 : Type.{u4}} [_inst_1 : NontriviallyNormedField.{u4} 𝕜] {E : Type.{u3}} [_inst_2 : NormedAddCommGroup.{u3} E] [_inst_3 : NormedSpace.{u4, u3} 𝕜 E (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} E _inst_2)] {F : Type.{u2}} [_inst_4 : NormedAddCommGroup.{u2} F] [_inst_5 : NormedSpace.{u4, u2} 𝕜 F (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} F _inst_4)] {G : Type.{u1}} [_inst_6 : NormedAddCommGroup.{u1} G] [_inst_7 : NormedSpace.{u4, u1} 𝕜 G (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} G _inst_6)] {b : (Prod.{u3, u2} E F) -> G} {u : Set.{max u2 u3} (Prod.{u3, u2} E F)}, (IsBoundedBilinearMap.{u4, u3, u2, u1} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 G _inst_6 _inst_7 b) -> (DifferentiableOn.{u4, max u3 u2, u1} 𝕜 _inst_1 (Prod.{u3, u2} E F) (Prod.normedAddCommGroup.{u3, u2} E F _inst_2 _inst_4) (Prod.normedSpace.{u4, u3, u2} 𝕜 (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) E (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} E _inst_2) _inst_3 F (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} F _inst_4) _inst_5) G _inst_6 _inst_7 b u)
Case conversion may be inaccurate. Consider using '#align is_bounded_bilinear_map.differentiable_on IsBoundedBilinearMap.differentiableOnₓ'. -/
theorem IsBoundedBilinearMap.differentiableOn (h : IsBoundedBilinearMap 𝕜 b) :
    DifferentiableOn 𝕜 b u :=
  h.Differentiable.DifferentiableOn
#align is_bounded_bilinear_map.differentiable_on IsBoundedBilinearMap.differentiableOn

variable (B : E →L[𝕜] F →L[𝕜] G)

/- warning: continuous_linear_map.has_fderiv_within_at_of_bilinear -> ContinuousLinearMap.hasFDerivWithinAt_of_bilinear is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align continuous_linear_map.has_fderiv_within_at_of_bilinear ContinuousLinearMap.hasFDerivWithinAt_of_bilinearₓ'. -/
theorem ContinuousLinearMap.hasFDerivWithinAt_of_bilinear {f : G' → E} {g : G' → F}
    {f' : G' →L[𝕜] E} {g' : G' →L[𝕜] F} {x : G'} {s : Set G'} (hf : HasFDerivWithinAt f f' s x)
    (hg : HasFDerivWithinAt g g' s x) :
    HasFDerivWithinAt (fun y => B (f y) (g y)) (B.precompR G' (f x) g' + B.precompL G' f' (g x)) s
      x :=
  (B.IsBoundedBilinearMap.HasFDerivAt (f x, g x)).comp_hasFDerivWithinAt x (hf.Prod hg)
#align continuous_linear_map.has_fderiv_within_at_of_bilinear ContinuousLinearMap.hasFDerivWithinAt_of_bilinear

/- warning: continuous_linear_map.has_fderiv_at_of_bilinear -> ContinuousLinearMap.hasFDerivAt_of_bilinear is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align continuous_linear_map.has_fderiv_at_of_bilinear ContinuousLinearMap.hasFDerivAt_of_bilinearₓ'. -/
theorem ContinuousLinearMap.hasFDerivAt_of_bilinear {f : G' → E} {g : G' → F} {f' : G' →L[𝕜] E}
    {g' : G' →L[𝕜] F} {x : G'} (hf : HasFDerivAt f f' x) (hg : HasFDerivAt g g' x) :
    HasFDerivAt (fun y => B (f y) (g y)) (B.precompR G' (f x) g' + B.precompL G' f' (g x)) x :=
  (B.IsBoundedBilinearMap.HasFDerivAt (f x, g x)).comp x (hf.Prod hg)
#align continuous_linear_map.has_fderiv_at_of_bilinear ContinuousLinearMap.hasFDerivAt_of_bilinear

/- warning: continuous_linear_map.fderiv_within_of_bilinear -> ContinuousLinearMap.fderivWithin_of_bilinear is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align continuous_linear_map.fderiv_within_of_bilinear ContinuousLinearMap.fderivWithin_of_bilinearₓ'. -/
theorem ContinuousLinearMap.fderivWithin_of_bilinear {f : G' → E} {g : G' → F} {x : G'} {s : Set G'}
    (hf : DifferentiableWithinAt 𝕜 f s x) (hg : DifferentiableWithinAt 𝕜 g s x)
    (hs : UniqueDiffWithinAt 𝕜 s x) :
    fderivWithin 𝕜 (fun y => B (f y) (g y)) s x =
      B.precompR G' (f x) (fderivWithin 𝕜 g s x) + B.precompL G' (fderivWithin 𝕜 f s x) (g x) :=
  (B.hasFDerivWithinAt_of_bilinear hf.HasFDerivWithinAt hg.HasFDerivWithinAt).fderivWithin hs
#align continuous_linear_map.fderiv_within_of_bilinear ContinuousLinearMap.fderivWithin_of_bilinear

/- warning: continuous_linear_map.fderiv_of_bilinear -> ContinuousLinearMap.fderiv_of_bilinear is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align continuous_linear_map.fderiv_of_bilinear ContinuousLinearMap.fderiv_of_bilinearₓ'. -/
theorem ContinuousLinearMap.fderiv_of_bilinear {f : G' → E} {g : G' → F} {x : G'}
    (hf : DifferentiableAt 𝕜 f x) (hg : DifferentiableAt 𝕜 g x) :
    fderiv 𝕜 (fun y => B (f y) (g y)) x =
      B.precompR G' (f x) (fderiv 𝕜 g x) + B.precompL G' (fderiv 𝕜 f x) (g x) :=
  (B.hasFDerivAt_of_bilinear hf.HasFDerivAt hg.HasFDerivAt).fderiv
#align continuous_linear_map.fderiv_of_bilinear ContinuousLinearMap.fderiv_of_bilinear

end BilinearMap

end

