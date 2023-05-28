/-
Copyright (c) 2019 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Sébastien Gouëzel, Yury Kudryashov

! This file was ported from Lean 3 source module analysis.calculus.fderiv.comp
! leanprover-community/mathlib commit 38df578a6450a8c5142b3727e3ae894c2300cae0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.Fderiv.Basic

/-!
# The derivative of a composition (chain rule)

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

For detailed documentation of the Fréchet derivative,
see the module docstring of `analysis/calculus/fderiv/basic.lean`.

This file contains the usual formulas (and existence assertions) for the derivative of
composition of functions (the chain rule).
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

section Composition

/-!
### Derivative of the composition of two functions

For composition lemmas, we put x explicit to help the elaborator, as otherwise Lean tends to
get confused since there are too many possibilities for composition -/


variable (x)

/- warning: has_fderiv_at_filter.comp -> HasFDerivAtFilter.comp is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align has_fderiv_at_filter.comp HasFDerivAtFilter.compₓ'. -/
theorem HasFDerivAtFilter.comp {g : F → G} {g' : F →L[𝕜] G} {L' : Filter F}
    (hg : HasFDerivAtFilter g g' (f x) L') (hf : HasFDerivAtFilter f f' x L) (hL : Tendsto f L L') :
    HasFDerivAtFilter (g ∘ f) (g'.comp f') x L :=
  by
  let eq₁ := (g'.isBigO_comp _ _).trans_isLittleO hf
  let eq₂ := (hg.comp_tendsto hL).trans_isBigO hf.isBigO_sub
  refine' eq₂.triangle (eq₁.congr_left fun x' => _); simp
#align has_fderiv_at_filter.comp HasFDerivAtFilter.comp

/- A readable version of the previous theorem,
   a general form of the chain rule. -/
example {g : F → G} {g' : F →L[𝕜] G} (hg : HasFDerivAtFilter g g' (f x) (L.map f))
    (hf : HasFDerivAtFilter f f' x L) : HasFDerivAtFilter (g ∘ f) (g'.comp f') x L :=
  by
  unfold HasFDerivAtFilter at hg
  have :=
    calc
      (fun x' => g (f x') - g (f x) - g' (f x' - f x)) =o[L] fun x' => f x' - f x :=
        hg.comp_tendsto le_rfl
      _ =O[L] fun x' => x' - x := hf.is_O_sub
      
  refine' this.triangle _
  calc
    (fun x' : E => g' (f x' - f x) - g'.comp f' (x' - x)) =ᶠ[L] fun x' =>
        g' (f x' - f x - f' (x' - x)) :=
      eventually_of_forall fun x' => by simp
    _ =O[L] fun x' => f x' - f x - f' (x' - x) := (g'.is_O_comp _ _)
    _ =o[L] fun x' => x' - x := hf
    

/- warning: has_fderiv_within_at.comp -> HasFDerivWithinAt.comp is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align has_fderiv_within_at.comp HasFDerivWithinAt.compₓ'. -/
theorem HasFDerivWithinAt.comp {g : F → G} {g' : F →L[𝕜] G} {t : Set F}
    (hg : HasFDerivWithinAt g g' t (f x)) (hf : HasFDerivWithinAt f f' s x) (hst : MapsTo f s t) :
    HasFDerivWithinAt (g ∘ f) (g'.comp f') s x :=
  hg.comp x hf <| hf.ContinuousWithinAt.tendsto_nhdsWithin hst
#align has_fderiv_within_at.comp HasFDerivWithinAt.comp

/- warning: has_fderiv_at.comp_has_fderiv_within_at -> HasFDerivAt.comp_hasFDerivWithinAt is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align has_fderiv_at.comp_has_fderiv_within_at HasFDerivAt.comp_hasFDerivWithinAtₓ'. -/
theorem HasFDerivAt.comp_hasFDerivWithinAt {g : F → G} {g' : F →L[𝕜] G}
    (hg : HasFDerivAt g g' (f x)) (hf : HasFDerivWithinAt f f' s x) :
    HasFDerivWithinAt (g ∘ f) (g'.comp f') s x :=
  hg.comp x hf hf.ContinuousWithinAt
#align has_fderiv_at.comp_has_fderiv_within_at HasFDerivAt.comp_hasFDerivWithinAt

/- warning: has_fderiv_within_at.comp_of_mem -> HasFDerivWithinAt.comp_of_mem is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align has_fderiv_within_at.comp_of_mem HasFDerivWithinAt.comp_of_memₓ'. -/
theorem HasFDerivWithinAt.comp_of_mem {g : F → G} {g' : F →L[𝕜] G} {t : Set F}
    (hg : HasFDerivWithinAt g g' t (f x)) (hf : HasFDerivWithinAt f f' s x)
    (hst : Tendsto f (𝓝[s] x) (𝓝[t] f x)) : HasFDerivWithinAt (g ∘ f) (g'.comp f') s x :=
  HasFDerivAtFilter.comp x hg hf hst
#align has_fderiv_within_at.comp_of_mem HasFDerivWithinAt.comp_of_mem

/- warning: has_fderiv_at.comp -> HasFDerivAt.comp is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align has_fderiv_at.comp HasFDerivAt.compₓ'. -/
/-- The chain rule. -/
theorem HasFDerivAt.comp {g : F → G} {g' : F →L[𝕜] G} (hg : HasFDerivAt g g' (f x))
    (hf : HasFDerivAt f f' x) : HasFDerivAt (g ∘ f) (g'.comp f') x :=
  hg.comp x hf hf.ContinuousAt
#align has_fderiv_at.comp HasFDerivAt.comp

/- warning: differentiable_within_at.comp -> DifferentiableWithinAt.comp is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u1, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u4}} [_inst_6 : NormedAddCommGroup.{u4} G] [_inst_7 : NormedSpace.{u1, u4} 𝕜 G (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u4} G _inst_6)] {f : E -> F} (x : E) {s : Set.{u2} E} {g : F -> G} {t : Set.{u3} F}, (DifferentiableWithinAt.{u1, u3, u4} 𝕜 _inst_1 F _inst_4 _inst_5 G _inst_6 _inst_7 g t (f x)) -> (DifferentiableWithinAt.{u1, u2, u3} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 f s x) -> (Set.MapsTo.{u2, u3} E F f s t) -> (DifferentiableWithinAt.{u1, u2, u4} 𝕜 _inst_1 E _inst_2 _inst_3 G _inst_6 _inst_7 (Function.comp.{succ u2, succ u3, succ u4} E F G g f) s x)
but is expected to have type
  forall {𝕜 : Type.{u3}} [_inst_1 : NontriviallyNormedField.{u3} 𝕜] {E : Type.{u1}} [_inst_2 : NormedAddCommGroup.{u1} E] [_inst_3 : NormedSpace.{u3, u1} 𝕜 E (NontriviallyNormedField.toNormedField.{u3} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2)] {F : Type.{u4}} [_inst_4 : NormedAddCommGroup.{u4} F] [_inst_5 : NormedSpace.{u3, u4} 𝕜 F (NontriviallyNormedField.toNormedField.{u3} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u4} F _inst_4)] {G : Type.{u2}} [_inst_6 : NormedAddCommGroup.{u2} G] [_inst_7 : NormedSpace.{u3, u2} 𝕜 G (NontriviallyNormedField.toNormedField.{u3} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} G _inst_6)] {f : E -> F} (x : E) {s : Set.{u1} E} {g : F -> G} {t : Set.{u4} F}, (DifferentiableWithinAt.{u3, u4, u2} 𝕜 _inst_1 F _inst_4 _inst_5 G _inst_6 _inst_7 g t (f x)) -> (DifferentiableWithinAt.{u3, u1, u4} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 f s x) -> (Set.MapsTo.{u1, u4} E F f s t) -> (DifferentiableWithinAt.{u3, u1, u2} 𝕜 _inst_1 E _inst_2 _inst_3 G _inst_6 _inst_7 (Function.comp.{succ u1, succ u4, succ u2} E F G g f) s x)
Case conversion may be inaccurate. Consider using '#align differentiable_within_at.comp DifferentiableWithinAt.compₓ'. -/
theorem DifferentiableWithinAt.comp {g : F → G} {t : Set F}
    (hg : DifferentiableWithinAt 𝕜 g t (f x)) (hf : DifferentiableWithinAt 𝕜 f s x)
    (h : MapsTo f s t) : DifferentiableWithinAt 𝕜 (g ∘ f) s x :=
  (hg.HasFDerivWithinAt.comp x hf.HasFDerivWithinAt h).DifferentiableWithinAt
#align differentiable_within_at.comp DifferentiableWithinAt.comp

/- warning: differentiable_within_at.comp' -> DifferentiableWithinAt.comp' is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u1, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u4}} [_inst_6 : NormedAddCommGroup.{u4} G] [_inst_7 : NormedSpace.{u1, u4} 𝕜 G (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u4} G _inst_6)] {f : E -> F} (x : E) {s : Set.{u2} E} {g : F -> G} {t : Set.{u3} F}, (DifferentiableWithinAt.{u1, u3, u4} 𝕜 _inst_1 F _inst_4 _inst_5 G _inst_6 _inst_7 g t (f x)) -> (DifferentiableWithinAt.{u1, u2, u3} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 f s x) -> (DifferentiableWithinAt.{u1, u2, u4} 𝕜 _inst_1 E _inst_2 _inst_3 G _inst_6 _inst_7 (Function.comp.{succ u2, succ u3, succ u4} E F G g f) (Inter.inter.{u2} (Set.{u2} E) (Set.hasInter.{u2} E) s (Set.preimage.{u2, u3} E F f t)) x)
but is expected to have type
  forall {𝕜 : Type.{u3}} [_inst_1 : NontriviallyNormedField.{u3} 𝕜] {E : Type.{u1}} [_inst_2 : NormedAddCommGroup.{u1} E] [_inst_3 : NormedSpace.{u3, u1} 𝕜 E (NontriviallyNormedField.toNormedField.{u3} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2)] {F : Type.{u4}} [_inst_4 : NormedAddCommGroup.{u4} F] [_inst_5 : NormedSpace.{u3, u4} 𝕜 F (NontriviallyNormedField.toNormedField.{u3} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u4} F _inst_4)] {G : Type.{u2}} [_inst_6 : NormedAddCommGroup.{u2} G] [_inst_7 : NormedSpace.{u3, u2} 𝕜 G (NontriviallyNormedField.toNormedField.{u3} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} G _inst_6)] {f : E -> F} (x : E) {s : Set.{u1} E} {g : F -> G} {t : Set.{u4} F}, (DifferentiableWithinAt.{u3, u4, u2} 𝕜 _inst_1 F _inst_4 _inst_5 G _inst_6 _inst_7 g t (f x)) -> (DifferentiableWithinAt.{u3, u1, u4} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 f s x) -> (DifferentiableWithinAt.{u3, u1, u2} 𝕜 _inst_1 E _inst_2 _inst_3 G _inst_6 _inst_7 (Function.comp.{succ u1, succ u4, succ u2} E F G g f) (Inter.inter.{u1} (Set.{u1} E) (Set.instInterSet.{u1} E) s (Set.preimage.{u1, u4} E F f t)) x)
Case conversion may be inaccurate. Consider using '#align differentiable_within_at.comp' DifferentiableWithinAt.comp'ₓ'. -/
theorem DifferentiableWithinAt.comp' {g : F → G} {t : Set F}
    (hg : DifferentiableWithinAt 𝕜 g t (f x)) (hf : DifferentiableWithinAt 𝕜 f s x) :
    DifferentiableWithinAt 𝕜 (g ∘ f) (s ∩ f ⁻¹' t) x :=
  hg.comp x (hf.mono (inter_subset_left _ _)) (inter_subset_right _ _)
#align differentiable_within_at.comp' DifferentiableWithinAt.comp'

/- warning: differentiable_at.comp -> DifferentiableAt.comp is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u1, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u4}} [_inst_6 : NormedAddCommGroup.{u4} G] [_inst_7 : NormedSpace.{u1, u4} 𝕜 G (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u4} G _inst_6)] {f : E -> F} (x : E) {g : F -> G}, (DifferentiableAt.{u1, u3, u4} 𝕜 _inst_1 F _inst_4 _inst_5 G _inst_6 _inst_7 g (f x)) -> (DifferentiableAt.{u1, u2, u3} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 f x) -> (DifferentiableAt.{u1, u2, u4} 𝕜 _inst_1 E _inst_2 _inst_3 G _inst_6 _inst_7 (Function.comp.{succ u2, succ u3, succ u4} E F G g f) x)
but is expected to have type
  forall {𝕜 : Type.{u4}} [_inst_1 : NontriviallyNormedField.{u4} 𝕜] {E : Type.{u1}} [_inst_2 : NormedAddCommGroup.{u1} E] [_inst_3 : NormedSpace.{u4, u1} 𝕜 E (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u4, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u2}} [_inst_6 : NormedAddCommGroup.{u2} G] [_inst_7 : NormedSpace.{u4, u2} 𝕜 G (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} G _inst_6)] {f : E -> F} (x : E) {g : F -> G}, (DifferentiableAt.{u4, u3, u2} 𝕜 _inst_1 F _inst_4 _inst_5 G _inst_6 _inst_7 g (f x)) -> (DifferentiableAt.{u4, u1, u3} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 f x) -> (DifferentiableAt.{u4, u1, u2} 𝕜 _inst_1 E _inst_2 _inst_3 G _inst_6 _inst_7 (Function.comp.{succ u1, succ u3, succ u2} E F G g f) x)
Case conversion may be inaccurate. Consider using '#align differentiable_at.comp DifferentiableAt.compₓ'. -/
theorem DifferentiableAt.comp {g : F → G} (hg : DifferentiableAt 𝕜 g (f x))
    (hf : DifferentiableAt 𝕜 f x) : DifferentiableAt 𝕜 (g ∘ f) x :=
  (hg.HasFDerivAt.comp x hf.HasFDerivAt).DifferentiableAt
#align differentiable_at.comp DifferentiableAt.comp

/- warning: differentiable_at.comp_differentiable_within_at -> DifferentiableAt.comp_differentiableWithinAt is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u1, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u4}} [_inst_6 : NormedAddCommGroup.{u4} G] [_inst_7 : NormedSpace.{u1, u4} 𝕜 G (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u4} G _inst_6)] {f : E -> F} (x : E) {s : Set.{u2} E} {g : F -> G}, (DifferentiableAt.{u1, u3, u4} 𝕜 _inst_1 F _inst_4 _inst_5 G _inst_6 _inst_7 g (f x)) -> (DifferentiableWithinAt.{u1, u2, u3} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 f s x) -> (DifferentiableWithinAt.{u1, u2, u4} 𝕜 _inst_1 E _inst_2 _inst_3 G _inst_6 _inst_7 (Function.comp.{succ u2, succ u3, succ u4} E F G g f) s x)
but is expected to have type
  forall {𝕜 : Type.{u4}} [_inst_1 : NontriviallyNormedField.{u4} 𝕜] {E : Type.{u1}} [_inst_2 : NormedAddCommGroup.{u1} E] [_inst_3 : NormedSpace.{u4, u1} 𝕜 E (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u4, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u2}} [_inst_6 : NormedAddCommGroup.{u2} G] [_inst_7 : NormedSpace.{u4, u2} 𝕜 G (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} G _inst_6)] {f : E -> F} (x : E) {s : Set.{u1} E} {g : F -> G}, (DifferentiableAt.{u4, u3, u2} 𝕜 _inst_1 F _inst_4 _inst_5 G _inst_6 _inst_7 g (f x)) -> (DifferentiableWithinAt.{u4, u1, u3} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 f s x) -> (DifferentiableWithinAt.{u4, u1, u2} 𝕜 _inst_1 E _inst_2 _inst_3 G _inst_6 _inst_7 (Function.comp.{succ u1, succ u3, succ u2} E F G g f) s x)
Case conversion may be inaccurate. Consider using '#align differentiable_at.comp_differentiable_within_at DifferentiableAt.comp_differentiableWithinAtₓ'. -/
theorem DifferentiableAt.comp_differentiableWithinAt {g : F → G} (hg : DifferentiableAt 𝕜 g (f x))
    (hf : DifferentiableWithinAt 𝕜 f s x) : DifferentiableWithinAt 𝕜 (g ∘ f) s x :=
  hg.DifferentiableWithinAt.comp x hf (mapsTo_univ _ _)
#align differentiable_at.comp_differentiable_within_at DifferentiableAt.comp_differentiableWithinAt

/- warning: fderiv_within.comp -> fderivWithin.comp is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align fderiv_within.comp fderivWithin.compₓ'. -/
theorem fderivWithin.comp {g : F → G} {t : Set F} (hg : DifferentiableWithinAt 𝕜 g t (f x))
    (hf : DifferentiableWithinAt 𝕜 f s x) (h : MapsTo f s t) (hxs : UniqueDiffWithinAt 𝕜 s x) :
    fderivWithin 𝕜 (g ∘ f) s x = (fderivWithin 𝕜 g t (f x)).comp (fderivWithin 𝕜 f s x) :=
  (hg.HasFDerivWithinAt.comp x hf.HasFDerivWithinAt h).fderivWithin hxs
#align fderiv_within.comp fderivWithin.comp

/- warning: fderiv_within_fderiv_within -> fderivWithin_fderivWithin is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align fderiv_within_fderiv_within fderivWithin_fderivWithinₓ'. -/
/-- A version of `fderiv_within.comp` that is useful to rewrite the composition of two derivatives
  into a single derivative. This version always applies, but creates a new side-goal `f x = y`. -/
theorem fderivWithin_fderivWithin {g : F → G} {f : E → F} {x : E} {y : F} {s : Set E} {t : Set F}
    (hg : DifferentiableWithinAt 𝕜 g t y) (hf : DifferentiableWithinAt 𝕜 f s x) (h : MapsTo f s t)
    (hxs : UniqueDiffWithinAt 𝕜 s x) (hy : f x = y) (v : E) :
    fderivWithin 𝕜 g t y (fderivWithin 𝕜 f s x v) = fderivWithin 𝕜 (g ∘ f) s x v := by subst y;
  rw [fderivWithin.comp x hg hf h hxs]; rfl
#align fderiv_within_fderiv_within fderivWithin_fderivWithin

/- warning: fderiv_within.comp₃ -> fderivWithin.comp₃ is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align fderiv_within.comp₃ fderivWithin.comp₃ₓ'. -/
/-- Ternary version of `fderiv_within.comp`, with equality assumptions of basepoints added, in
  order to apply more easily as a rewrite from right-to-left. -/
theorem fderivWithin.comp₃ {g' : G → G'} {g : F → G} {t : Set F} {u : Set G} {y : F} {y' : G}
    (hg' : DifferentiableWithinAt 𝕜 g' u y') (hg : DifferentiableWithinAt 𝕜 g t y)
    (hf : DifferentiableWithinAt 𝕜 f s x) (h2g : MapsTo g t u) (h2f : MapsTo f s t) (h3g : g y = y')
    (h3f : f x = y) (hxs : UniqueDiffWithinAt 𝕜 s x) :
    fderivWithin 𝕜 (g' ∘ g ∘ f) s x =
      (fderivWithin 𝕜 g' u y').comp ((fderivWithin 𝕜 g t y).comp (fderivWithin 𝕜 f s x)) :=
  by
  substs h3g h3f
  exact
    (hg'.has_fderiv_within_at.comp x (hg.has_fderiv_within_at.comp x hf.has_fderiv_within_at h2f) <|
          h2g.comp h2f).fderivWithin
      hxs
#align fderiv_within.comp₃ fderivWithin.comp₃

/- warning: fderiv.comp -> fderiv.comp is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align fderiv.comp fderiv.compₓ'. -/
theorem fderiv.comp {g : F → G} (hg : DifferentiableAt 𝕜 g (f x)) (hf : DifferentiableAt 𝕜 f x) :
    fderiv 𝕜 (g ∘ f) x = (fderiv 𝕜 g (f x)).comp (fderiv 𝕜 f x) :=
  (hg.HasFDerivAt.comp x hf.HasFDerivAt).fderiv
#align fderiv.comp fderiv.comp

/- warning: fderiv.comp_fderiv_within -> fderiv.comp_fderivWithin is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align fderiv.comp_fderiv_within fderiv.comp_fderivWithinₓ'. -/
theorem fderiv.comp_fderivWithin {g : F → G} (hg : DifferentiableAt 𝕜 g (f x))
    (hf : DifferentiableWithinAt 𝕜 f s x) (hxs : UniqueDiffWithinAt 𝕜 s x) :
    fderivWithin 𝕜 (g ∘ f) s x = (fderiv 𝕜 g (f x)).comp (fderivWithin 𝕜 f s x) :=
  (hg.HasFDerivAt.comp_hasFDerivWithinAt x hf.HasFDerivWithinAt).fderivWithin hxs
#align fderiv.comp_fderiv_within fderiv.comp_fderivWithin

/- warning: differentiable_on.comp -> DifferentiableOn.comp is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u1, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u4}} [_inst_6 : NormedAddCommGroup.{u4} G] [_inst_7 : NormedSpace.{u1, u4} 𝕜 G (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u4} G _inst_6)] {f : E -> F} {s : Set.{u2} E} {g : F -> G} {t : Set.{u3} F}, (DifferentiableOn.{u1, u3, u4} 𝕜 _inst_1 F _inst_4 _inst_5 G _inst_6 _inst_7 g t) -> (DifferentiableOn.{u1, u2, u3} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 f s) -> (Set.MapsTo.{u2, u3} E F f s t) -> (DifferentiableOn.{u1, u2, u4} 𝕜 _inst_1 E _inst_2 _inst_3 G _inst_6 _inst_7 (Function.comp.{succ u2, succ u3, succ u4} E F G g f) s)
but is expected to have type
  forall {𝕜 : Type.{u3}} [_inst_1 : NontriviallyNormedField.{u3} 𝕜] {E : Type.{u1}} [_inst_2 : NormedAddCommGroup.{u1} E] [_inst_3 : NormedSpace.{u3, u1} 𝕜 E (NontriviallyNormedField.toNormedField.{u3} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2)] {F : Type.{u4}} [_inst_4 : NormedAddCommGroup.{u4} F] [_inst_5 : NormedSpace.{u3, u4} 𝕜 F (NontriviallyNormedField.toNormedField.{u3} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u4} F _inst_4)] {G : Type.{u2}} [_inst_6 : NormedAddCommGroup.{u2} G] [_inst_7 : NormedSpace.{u3, u2} 𝕜 G (NontriviallyNormedField.toNormedField.{u3} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} G _inst_6)] {f : E -> F} {s : Set.{u1} E} {g : F -> G} {t : Set.{u4} F}, (DifferentiableOn.{u3, u4, u2} 𝕜 _inst_1 F _inst_4 _inst_5 G _inst_6 _inst_7 g t) -> (DifferentiableOn.{u3, u1, u4} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 f s) -> (Set.MapsTo.{u1, u4} E F f s t) -> (DifferentiableOn.{u3, u1, u2} 𝕜 _inst_1 E _inst_2 _inst_3 G _inst_6 _inst_7 (Function.comp.{succ u1, succ u4, succ u2} E F G g f) s)
Case conversion may be inaccurate. Consider using '#align differentiable_on.comp DifferentiableOn.compₓ'. -/
theorem DifferentiableOn.comp {g : F → G} {t : Set F} (hg : DifferentiableOn 𝕜 g t)
    (hf : DifferentiableOn 𝕜 f s) (st : MapsTo f s t) : DifferentiableOn 𝕜 (g ∘ f) s := fun x hx =>
  DifferentiableWithinAt.comp x (hg (f x) (st hx)) (hf x hx) st
#align differentiable_on.comp DifferentiableOn.comp

/- warning: differentiable.comp -> Differentiable.comp is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u1, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u4}} [_inst_6 : NormedAddCommGroup.{u4} G] [_inst_7 : NormedSpace.{u1, u4} 𝕜 G (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u4} G _inst_6)] {f : E -> F} {g : F -> G}, (Differentiable.{u1, u3, u4} 𝕜 _inst_1 F _inst_4 _inst_5 G _inst_6 _inst_7 g) -> (Differentiable.{u1, u2, u3} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 f) -> (Differentiable.{u1, u2, u4} 𝕜 _inst_1 E _inst_2 _inst_3 G _inst_6 _inst_7 (Function.comp.{succ u2, succ u3, succ u4} E F G g f))
but is expected to have type
  forall {𝕜 : Type.{u4}} [_inst_1 : NontriviallyNormedField.{u4} 𝕜] {E : Type.{u1}} [_inst_2 : NormedAddCommGroup.{u1} E] [_inst_3 : NormedSpace.{u4, u1} 𝕜 E (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u4, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u2}} [_inst_6 : NormedAddCommGroup.{u2} G] [_inst_7 : NormedSpace.{u4, u2} 𝕜 G (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} G _inst_6)] {f : E -> F} {g : F -> G}, (Differentiable.{u4, u3, u2} 𝕜 _inst_1 F _inst_4 _inst_5 G _inst_6 _inst_7 g) -> (Differentiable.{u4, u1, u3} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 f) -> (Differentiable.{u4, u1, u2} 𝕜 _inst_1 E _inst_2 _inst_3 G _inst_6 _inst_7 (Function.comp.{succ u1, succ u3, succ u2} E F G g f))
Case conversion may be inaccurate. Consider using '#align differentiable.comp Differentiable.compₓ'. -/
theorem Differentiable.comp {g : F → G} (hg : Differentiable 𝕜 g) (hf : Differentiable 𝕜 f) :
    Differentiable 𝕜 (g ∘ f) := fun x => DifferentiableAt.comp x (hg (f x)) (hf x)
#align differentiable.comp Differentiable.comp

/- warning: differentiable.comp_differentiable_on -> Differentiable.comp_differentiableOn is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u1, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u4}} [_inst_6 : NormedAddCommGroup.{u4} G] [_inst_7 : NormedSpace.{u1, u4} 𝕜 G (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u4} G _inst_6)] {f : E -> F} {s : Set.{u2} E} {g : F -> G}, (Differentiable.{u1, u3, u4} 𝕜 _inst_1 F _inst_4 _inst_5 G _inst_6 _inst_7 g) -> (DifferentiableOn.{u1, u2, u3} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 f s) -> (DifferentiableOn.{u1, u2, u4} 𝕜 _inst_1 E _inst_2 _inst_3 G _inst_6 _inst_7 (Function.comp.{succ u2, succ u3, succ u4} E F G g f) s)
but is expected to have type
  forall {𝕜 : Type.{u4}} [_inst_1 : NontriviallyNormedField.{u4} 𝕜] {E : Type.{u1}} [_inst_2 : NormedAddCommGroup.{u1} E] [_inst_3 : NormedSpace.{u4, u1} 𝕜 E (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2)] {F : Type.{u3}} [_inst_4 : NormedAddCommGroup.{u3} F] [_inst_5 : NormedSpace.{u4, u3} 𝕜 F (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u3} F _inst_4)] {G : Type.{u2}} [_inst_6 : NormedAddCommGroup.{u2} G] [_inst_7 : NormedSpace.{u4, u2} 𝕜 G (NontriviallyNormedField.toNormedField.{u4} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} G _inst_6)] {f : E -> F} {s : Set.{u1} E} {g : F -> G}, (Differentiable.{u4, u3, u2} 𝕜 _inst_1 F _inst_4 _inst_5 G _inst_6 _inst_7 g) -> (DifferentiableOn.{u4, u1, u3} 𝕜 _inst_1 E _inst_2 _inst_3 F _inst_4 _inst_5 f s) -> (DifferentiableOn.{u4, u1, u2} 𝕜 _inst_1 E _inst_2 _inst_3 G _inst_6 _inst_7 (Function.comp.{succ u1, succ u3, succ u2} E F G g f) s)
Case conversion may be inaccurate. Consider using '#align differentiable.comp_differentiable_on Differentiable.comp_differentiableOnₓ'. -/
theorem Differentiable.comp_differentiableOn {g : F → G} (hg : Differentiable 𝕜 g)
    (hf : DifferentiableOn 𝕜 f s) : DifferentiableOn 𝕜 (g ∘ f) s :=
  hg.DifferentiableOn.comp hf (mapsTo_univ _ _)
#align differentiable.comp_differentiable_on Differentiable.comp_differentiableOn

/- warning: has_strict_fderiv_at.comp -> HasStrictFDerivAt.comp is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align has_strict_fderiv_at.comp HasStrictFDerivAt.compₓ'. -/
/-- The chain rule for derivatives in the sense of strict differentiability. -/
protected theorem HasStrictFDerivAt.comp {g : F → G} {g' : F →L[𝕜] G}
    (hg : HasStrictFDerivAt g g' (f x)) (hf : HasStrictFDerivAt f f' x) :
    HasStrictFDerivAt (fun x => g (f x)) (g'.comp f') x :=
  ((hg.comp_tendsto (hf.ContinuousAt.prod_map' hf.ContinuousAt)).trans_isBigO
        hf.isBigO_sub).triangle <|
    by simpa only [g'.map_sub, f'.coe_comp'] using (g'.is_O_comp _ _).trans_isLittleO hf
#align has_strict_fderiv_at.comp HasStrictFDerivAt.comp

/- warning: differentiable.iterate -> Differentiable.iterate is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {f : E -> E}, (Differentiable.{u1, u2, u2} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 f) -> (forall (n : Nat), Differentiable.{u1, u2, u2} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 (Nat.iterate.{succ u2} E f n))
but is expected to have type
  forall {𝕜 : Type.{u2}} [_inst_1 : NontriviallyNormedField.{u2} 𝕜] {E : Type.{u1}} [_inst_2 : NormedAddCommGroup.{u1} E] [_inst_3 : NormedSpace.{u2, u1} 𝕜 E (NontriviallyNormedField.toNormedField.{u2} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2)] {f : E -> E}, (Differentiable.{u2, u1, u1} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 f) -> (forall (n : Nat), Differentiable.{u2, u1, u1} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 (Nat.iterate.{succ u1} E f n))
Case conversion may be inaccurate. Consider using '#align differentiable.iterate Differentiable.iterateₓ'. -/
protected theorem Differentiable.iterate {f : E → E} (hf : Differentiable 𝕜 f) (n : ℕ) :
    Differentiable 𝕜 (f^[n]) :=
  Nat.recOn n differentiable_id fun n ihn => ihn.comp hf
#align differentiable.iterate Differentiable.iterate

/- warning: differentiable_on.iterate -> DifferentiableOn.iterate is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {s : Set.{u2} E} {f : E -> E}, (DifferentiableOn.{u1, u2, u2} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 f s) -> (Set.MapsTo.{u2, u2} E E f s s) -> (forall (n : Nat), DifferentiableOn.{u1, u2, u2} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 (Nat.iterate.{succ u2} E f n) s)
but is expected to have type
  forall {𝕜 : Type.{u2}} [_inst_1 : NontriviallyNormedField.{u2} 𝕜] {E : Type.{u1}} [_inst_2 : NormedAddCommGroup.{u1} E] [_inst_3 : NormedSpace.{u2, u1} 𝕜 E (NontriviallyNormedField.toNormedField.{u2} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2)] {s : Set.{u1} E} {f : E -> E}, (DifferentiableOn.{u2, u1, u1} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 f s) -> (Set.MapsTo.{u1, u1} E E f s s) -> (forall (n : Nat), DifferentiableOn.{u2, u1, u1} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 (Nat.iterate.{succ u1} E f n) s)
Case conversion may be inaccurate. Consider using '#align differentiable_on.iterate DifferentiableOn.iterateₓ'. -/
protected theorem DifferentiableOn.iterate {f : E → E} (hf : DifferentiableOn 𝕜 f s)
    (hs : MapsTo f s s) (n : ℕ) : DifferentiableOn 𝕜 (f^[n]) s :=
  Nat.recOn n differentiableOn_id fun n ihn => ihn.comp hf hs
#align differentiable_on.iterate DifferentiableOn.iterate

variable {x}

/- warning: has_fderiv_at_filter.iterate -> HasFDerivAtFilter.iterate is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align has_fderiv_at_filter.iterate HasFDerivAtFilter.iterateₓ'. -/
protected theorem HasFDerivAtFilter.iterate {f : E → E} {f' : E →L[𝕜] E}
    (hf : HasFDerivAtFilter f f' x L) (hL : Tendsto f L L) (hx : f x = x) (n : ℕ) :
    HasFDerivAtFilter (f^[n]) (f' ^ n) x L :=
  by
  induction' n with n ihn
  · exact hasFDerivAtFilter_id x L
  · rw [Function.iterate_succ, pow_succ']
    rw [← hx] at ihn
    exact ihn.comp x hf hL
#align has_fderiv_at_filter.iterate HasFDerivAtFilter.iterate

/- warning: has_fderiv_at.iterate -> HasFDerivAt.iterate is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align has_fderiv_at.iterate HasFDerivAt.iterateₓ'. -/
protected theorem HasFDerivAt.iterate {f : E → E} {f' : E →L[𝕜] E} (hf : HasFDerivAt f f' x)
    (hx : f x = x) (n : ℕ) : HasFDerivAt (f^[n]) (f' ^ n) x :=
  by
  refine' hf.iterate _ hx n
  convert hf.continuous_at
  exact hx.symm
#align has_fderiv_at.iterate HasFDerivAt.iterate

/- warning: has_fderiv_within_at.iterate -> HasFDerivWithinAt.iterate is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align has_fderiv_within_at.iterate HasFDerivWithinAt.iterateₓ'. -/
protected theorem HasFDerivWithinAt.iterate {f : E → E} {f' : E →L[𝕜] E}
    (hf : HasFDerivWithinAt f f' s x) (hx : f x = x) (hs : MapsTo f s s) (n : ℕ) :
    HasFDerivWithinAt (f^[n]) (f' ^ n) s x :=
  by
  refine' hf.iterate _ hx n
  convert tendsto_inf.2 ⟨hf.continuous_within_at, _⟩
  exacts[hx.symm, (tendsto_principal_principal.2 hs).mono_left inf_le_right]
#align has_fderiv_within_at.iterate HasFDerivWithinAt.iterate

/- warning: has_strict_fderiv_at.iterate -> HasStrictFDerivAt.iterate is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align has_strict_fderiv_at.iterate HasStrictFDerivAt.iterateₓ'. -/
protected theorem HasStrictFDerivAt.iterate {f : E → E} {f' : E →L[𝕜] E}
    (hf : HasStrictFDerivAt f f' x) (hx : f x = x) (n : ℕ) : HasStrictFDerivAt (f^[n]) (f' ^ n) x :=
  by
  induction' n with n ihn
  · exact hasStrictFDerivAt_id x
  · rw [Function.iterate_succ, pow_succ']
    rw [← hx] at ihn
    exact ihn.comp x hf
#align has_strict_fderiv_at.iterate HasStrictFDerivAt.iterate

/- warning: differentiable_at.iterate -> DifferentiableAt.iterate is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {x : E} {f : E -> E}, (DifferentiableAt.{u1, u2, u2} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 f x) -> (Eq.{succ u2} E (f x) x) -> (forall (n : Nat), DifferentiableAt.{u1, u2, u2} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 (Nat.iterate.{succ u2} E f n) x)
but is expected to have type
  forall {𝕜 : Type.{u2}} [_inst_1 : NontriviallyNormedField.{u2} 𝕜] {E : Type.{u1}} [_inst_2 : NormedAddCommGroup.{u1} E] [_inst_3 : NormedSpace.{u2, u1} 𝕜 E (NontriviallyNormedField.toNormedField.{u2} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2)] {x : E} {f : E -> E}, (DifferentiableAt.{u2, u1, u1} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 f x) -> (Eq.{succ u1} E (f x) x) -> (forall (n : Nat), DifferentiableAt.{u2, u1, u1} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 (Nat.iterate.{succ u1} E f n) x)
Case conversion may be inaccurate. Consider using '#align differentiable_at.iterate DifferentiableAt.iterateₓ'. -/
protected theorem DifferentiableAt.iterate {f : E → E} (hf : DifferentiableAt 𝕜 f x) (hx : f x = x)
    (n : ℕ) : DifferentiableAt 𝕜 (f^[n]) x :=
  (hf.HasFDerivAt.iterate hx n).DifferentiableAt
#align differentiable_at.iterate DifferentiableAt.iterate

/- warning: differentiable_within_at.iterate -> DifferentiableWithinAt.iterate is a dubious translation:
lean 3 declaration is
  forall {𝕜 : Type.{u1}} [_inst_1 : NontriviallyNormedField.{u1} 𝕜] {E : Type.{u2}} [_inst_2 : NormedAddCommGroup.{u2} E] [_inst_3 : NormedSpace.{u1, u2} 𝕜 E (NontriviallyNormedField.toNormedField.{u1} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u2} E _inst_2)] {x : E} {s : Set.{u2} E} {f : E -> E}, (DifferentiableWithinAt.{u1, u2, u2} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 f s x) -> (Eq.{succ u2} E (f x) x) -> (Set.MapsTo.{u2, u2} E E f s s) -> (forall (n : Nat), DifferentiableWithinAt.{u1, u2, u2} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 (Nat.iterate.{succ u2} E f n) s x)
but is expected to have type
  forall {𝕜 : Type.{u2}} [_inst_1 : NontriviallyNormedField.{u2} 𝕜] {E : Type.{u1}} [_inst_2 : NormedAddCommGroup.{u1} E] [_inst_3 : NormedSpace.{u2, u1} 𝕜 E (NontriviallyNormedField.toNormedField.{u2} 𝕜 _inst_1) (NormedAddCommGroup.toSeminormedAddCommGroup.{u1} E _inst_2)] {x : E} {s : Set.{u1} E} {f : E -> E}, (DifferentiableWithinAt.{u2, u1, u1} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 f s x) -> (Eq.{succ u1} E (f x) x) -> (Set.MapsTo.{u1, u1} E E f s s) -> (forall (n : Nat), DifferentiableWithinAt.{u2, u1, u1} 𝕜 _inst_1 E _inst_2 _inst_3 E _inst_2 _inst_3 (Nat.iterate.{succ u1} E f n) s x)
Case conversion may be inaccurate. Consider using '#align differentiable_within_at.iterate DifferentiableWithinAt.iterateₓ'. -/
protected theorem DifferentiableWithinAt.iterate {f : E → E} (hf : DifferentiableWithinAt 𝕜 f s x)
    (hx : f x = x) (hs : MapsTo f s s) (n : ℕ) : DifferentiableWithinAt 𝕜 (f^[n]) s x :=
  (hf.HasFDerivWithinAt.iterate hx hs n).DifferentiableWithinAt
#align differentiable_within_at.iterate DifferentiableWithinAt.iterate

end Composition

end

