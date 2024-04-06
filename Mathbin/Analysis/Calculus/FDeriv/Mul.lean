/-
Copyright (c) 2019 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Sébastien Gouëzel, Yury Kudryashov
-/
import Analysis.Calculus.FDeriv.Bilinear

#align_import analysis.calculus.fderiv.mul from "leanprover-community/mathlib"@"d608fc5d4e69d4cc21885913fb573a88b0deb521"

/-!
# Multiplicative operations on derivatives

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

For detailed documentation of the Fréchet derivative,
see the module docstring of `analysis/calculus/fderiv/basic.lean`.

This file contains the usual formulas (and existence assertions) for the derivative of

* multiplication of a function by a scalar function
* multiplication of two scalar functions
* inverse function (assuming that it exists; the inverse function theorem is in `../inverse.lean`)
-/


open Filter Asymptotics ContinuousLinearMap Set Metric

open scoped Topology Classical NNReal Filter Asymptotics ENNReal

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

section ClmCompApply

/-! ### Derivative of the pointwise composition/application of continuous linear maps -/


variable {H : Type _} [NormedAddCommGroup H] [NormedSpace 𝕜 H] {c : E → G →L[𝕜] H}
  {c' : E →L[𝕜] G →L[𝕜] H} {d : E → F →L[𝕜] G} {d' : E →L[𝕜] F →L[𝕜] G} {u : E → G} {u' : E →L[𝕜] G}

#print HasStrictFDerivAt.clm_comp /-
theorem HasStrictFDerivAt.clm_comp (hc : HasStrictFDerivAt c c' x) (hd : HasStrictFDerivAt d d' x) :
    HasStrictFDerivAt (fun y => (c y).comp (d y))
      ((compL 𝕜 F G H (c x)).comp d' + ((compL 𝕜 F G H).flip (d x)).comp c') x :=
  (isBoundedBilinearMap_comp.HasStrictFDerivAt (c x, d x)).comp x <| hc.Prod hd
#align has_strict_fderiv_at.clm_comp HasStrictFDerivAt.clm_comp
-/

#print HasFDerivWithinAt.clm_comp /-
theorem HasFDerivWithinAt.clm_comp (hc : HasFDerivWithinAt c c' s x)
    (hd : HasFDerivWithinAt d d' s x) :
    HasFDerivWithinAt (fun y => (c y).comp (d y))
      ((compL 𝕜 F G H (c x)).comp d' + ((compL 𝕜 F G H).flip (d x)).comp c') s x :=
  (isBoundedBilinearMap_comp.HasFDerivAt (c x, d x)).comp_hasFDerivWithinAt x <| hc.Prod hd
#align has_fderiv_within_at.clm_comp HasFDerivWithinAt.clm_comp
-/

#print HasFDerivAt.clm_comp /-
theorem HasFDerivAt.clm_comp (hc : HasFDerivAt c c' x) (hd : HasFDerivAt d d' x) :
    HasFDerivAt (fun y => (c y).comp (d y))
      ((compL 𝕜 F G H (c x)).comp d' + ((compL 𝕜 F G H).flip (d x)).comp c') x :=
  (isBoundedBilinearMap_comp.HasFDerivAt (c x, d x)).comp x <| hc.Prod hd
#align has_fderiv_at.clm_comp HasFDerivAt.clm_comp
-/

#print DifferentiableWithinAt.clm_comp /-
theorem DifferentiableWithinAt.clm_comp (hc : DifferentiableWithinAt 𝕜 c s x)
    (hd : DifferentiableWithinAt 𝕜 d s x) :
    DifferentiableWithinAt 𝕜 (fun y => (c y).comp (d y)) s x :=
  (hc.HasFDerivWithinAt.clm_comp hd.HasFDerivWithinAt).DifferentiableWithinAt
#align differentiable_within_at.clm_comp DifferentiableWithinAt.clm_comp
-/

#print DifferentiableAt.clm_comp /-
theorem DifferentiableAt.clm_comp (hc : DifferentiableAt 𝕜 c x) (hd : DifferentiableAt 𝕜 d x) :
    DifferentiableAt 𝕜 (fun y => (c y).comp (d y)) x :=
  (hc.HasFDerivAt.clm_comp hd.HasFDerivAt).DifferentiableAt
#align differentiable_at.clm_comp DifferentiableAt.clm_comp
-/

#print DifferentiableOn.clm_comp /-
theorem DifferentiableOn.clm_comp (hc : DifferentiableOn 𝕜 c s) (hd : DifferentiableOn 𝕜 d s) :
    DifferentiableOn 𝕜 (fun y => (c y).comp (d y)) s := fun x hx => (hc x hx).clm_comp (hd x hx)
#align differentiable_on.clm_comp DifferentiableOn.clm_comp
-/

#print Differentiable.clm_comp /-
theorem Differentiable.clm_comp (hc : Differentiable 𝕜 c) (hd : Differentiable 𝕜 d) :
    Differentiable 𝕜 fun y => (c y).comp (d y) := fun x => (hc x).clm_comp (hd x)
#align differentiable.clm_comp Differentiable.clm_comp
-/

#print fderivWithin_clm_comp /-
theorem fderivWithin_clm_comp (hxs : UniqueDiffWithinAt 𝕜 s x) (hc : DifferentiableWithinAt 𝕜 c s x)
    (hd : DifferentiableWithinAt 𝕜 d s x) :
    fderivWithin 𝕜 (fun y => (c y).comp (d y)) s x =
      (compL 𝕜 F G H (c x)).comp (fderivWithin 𝕜 d s x) +
        ((compL 𝕜 F G H).flip (d x)).comp (fderivWithin 𝕜 c s x) :=
  (hc.HasFDerivWithinAt.clm_comp hd.HasFDerivWithinAt).fderivWithin hxs
#align fderiv_within_clm_comp fderivWithin_clm_comp
-/

#print fderiv_clm_comp /-
theorem fderiv_clm_comp (hc : DifferentiableAt 𝕜 c x) (hd : DifferentiableAt 𝕜 d x) :
    fderiv 𝕜 (fun y => (c y).comp (d y)) x =
      (compL 𝕜 F G H (c x)).comp (fderiv 𝕜 d x) +
        ((compL 𝕜 F G H).flip (d x)).comp (fderiv 𝕜 c x) :=
  (hc.HasFDerivAt.clm_comp hd.HasFDerivAt).fderiv
#align fderiv_clm_comp fderiv_clm_comp
-/

#print HasStrictFDerivAt.clm_apply /-
theorem HasStrictFDerivAt.clm_apply (hc : HasStrictFDerivAt c c' x)
    (hu : HasStrictFDerivAt u u' x) :
    HasStrictFDerivAt (fun y => (c y) (u y)) ((c x).comp u' + c'.flip (u x)) x :=
  (isBoundedBilinearMap_apply.HasStrictFDerivAt (c x, u x)).comp x (hc.Prod hu)
#align has_strict_fderiv_at.clm_apply HasStrictFDerivAt.clm_apply
-/

#print HasFDerivWithinAt.clm_apply /-
theorem HasFDerivWithinAt.clm_apply (hc : HasFDerivWithinAt c c' s x)
    (hu : HasFDerivWithinAt u u' s x) :
    HasFDerivWithinAt (fun y => (c y) (u y)) ((c x).comp u' + c'.flip (u x)) s x :=
  (isBoundedBilinearMap_apply.HasFDerivAt (c x, u x)).comp_hasFDerivWithinAt x (hc.Prod hu)
#align has_fderiv_within_at.clm_apply HasFDerivWithinAt.clm_apply
-/

#print HasFDerivAt.clm_apply /-
theorem HasFDerivAt.clm_apply (hc : HasFDerivAt c c' x) (hu : HasFDerivAt u u' x) :
    HasFDerivAt (fun y => (c y) (u y)) ((c x).comp u' + c'.flip (u x)) x :=
  (isBoundedBilinearMap_apply.HasFDerivAt (c x, u x)).comp x (hc.Prod hu)
#align has_fderiv_at.clm_apply HasFDerivAt.clm_apply
-/

#print DifferentiableWithinAt.clm_apply /-
theorem DifferentiableWithinAt.clm_apply (hc : DifferentiableWithinAt 𝕜 c s x)
    (hu : DifferentiableWithinAt 𝕜 u s x) : DifferentiableWithinAt 𝕜 (fun y => (c y) (u y)) s x :=
  (hc.HasFDerivWithinAt.clm_apply hu.HasFDerivWithinAt).DifferentiableWithinAt
#align differentiable_within_at.clm_apply DifferentiableWithinAt.clm_apply
-/

#print DifferentiableAt.clm_apply /-
theorem DifferentiableAt.clm_apply (hc : DifferentiableAt 𝕜 c x) (hu : DifferentiableAt 𝕜 u x) :
    DifferentiableAt 𝕜 (fun y => (c y) (u y)) x :=
  (hc.HasFDerivAt.clm_apply hu.HasFDerivAt).DifferentiableAt
#align differentiable_at.clm_apply DifferentiableAt.clm_apply
-/

#print DifferentiableOn.clm_apply /-
theorem DifferentiableOn.clm_apply (hc : DifferentiableOn 𝕜 c s) (hu : DifferentiableOn 𝕜 u s) :
    DifferentiableOn 𝕜 (fun y => (c y) (u y)) s := fun x hx => (hc x hx).clm_apply (hu x hx)
#align differentiable_on.clm_apply DifferentiableOn.clm_apply
-/

#print Differentiable.clm_apply /-
theorem Differentiable.clm_apply (hc : Differentiable 𝕜 c) (hu : Differentiable 𝕜 u) :
    Differentiable 𝕜 fun y => (c y) (u y) := fun x => (hc x).clm_apply (hu x)
#align differentiable.clm_apply Differentiable.clm_apply
-/

#print fderivWithin_clm_apply /-
theorem fderivWithin_clm_apply (hxs : UniqueDiffWithinAt 𝕜 s x)
    (hc : DifferentiableWithinAt 𝕜 c s x) (hu : DifferentiableWithinAt 𝕜 u s x) :
    fderivWithin 𝕜 (fun y => (c y) (u y)) s x =
      (c x).comp (fderivWithin 𝕜 u s x) + (fderivWithin 𝕜 c s x).flip (u x) :=
  (hc.HasFDerivWithinAt.clm_apply hu.HasFDerivWithinAt).fderivWithin hxs
#align fderiv_within_clm_apply fderivWithin_clm_apply
-/

#print fderiv_clm_apply /-
theorem fderiv_clm_apply (hc : DifferentiableAt 𝕜 c x) (hu : DifferentiableAt 𝕜 u x) :
    fderiv 𝕜 (fun y => (c y) (u y)) x = (c x).comp (fderiv 𝕜 u x) + (fderiv 𝕜 c x).flip (u x) :=
  (hc.HasFDerivAt.clm_apply hu.HasFDerivAt).fderiv
#align fderiv_clm_apply fderiv_clm_apply
-/

end ClmCompApply

section Smul

/-! ### Derivative of the product of a scalar-valued function and a vector-valued function

If `c` is a differentiable scalar-valued function and `f` is a differentiable vector-valued
function, then `λ x, c x • f x` is differentiable as well. Lemmas in this section works for
function `c` taking values in the base field, as well as in a normed algebra over the base
field: e.g., they work for `c : E → ℂ` and `f : E → F` provided that `F` is a complex
normed vector space.
-/


variable {𝕜' : Type _} [NontriviallyNormedField 𝕜'] [NormedAlgebra 𝕜 𝕜'] [NormedSpace 𝕜' F]
  [IsScalarTower 𝕜 𝕜' F]

variable {c : E → 𝕜'} {c' : E →L[𝕜] 𝕜'}

#print HasStrictFDerivAt.smul /-
theorem HasStrictFDerivAt.smul (hc : HasStrictFDerivAt c c' x) (hf : HasStrictFDerivAt f f' x) :
    HasStrictFDerivAt (fun y => c y • f y) (c x • f' + c'.smul_right (f x)) x :=
  (isBoundedBilinearMap_smul.HasStrictFDerivAt (c x, f x)).comp x <| hc.Prod hf
#align has_strict_fderiv_at.smul HasStrictFDerivAt.smul
-/

#print HasFDerivWithinAt.smul /-
theorem HasFDerivWithinAt.smul (hc : HasFDerivWithinAt c c' s x) (hf : HasFDerivWithinAt f f' s x) :
    HasFDerivWithinAt (fun y => c y • f y) (c x • f' + c'.smul_right (f x)) s x :=
  (isBoundedBilinearMap_smul.HasFDerivAt (c x, f x)).comp_hasFDerivWithinAt x <| hc.Prod hf
#align has_fderiv_within_at.smul HasFDerivWithinAt.smul
-/

#print HasFDerivAt.smul /-
theorem HasFDerivAt.smul (hc : HasFDerivAt c c' x) (hf : HasFDerivAt f f' x) :
    HasFDerivAt (fun y => c y • f y) (c x • f' + c'.smul_right (f x)) x :=
  (isBoundedBilinearMap_smul.HasFDerivAt (c x, f x)).comp x <| hc.Prod hf
#align has_fderiv_at.smul HasFDerivAt.smul
-/

#print DifferentiableWithinAt.smul /-
theorem DifferentiableWithinAt.smul (hc : DifferentiableWithinAt 𝕜 c s x)
    (hf : DifferentiableWithinAt 𝕜 f s x) : DifferentiableWithinAt 𝕜 (fun y => c y • f y) s x :=
  (hc.HasFDerivWithinAt.smul hf.HasFDerivWithinAt).DifferentiableWithinAt
#align differentiable_within_at.smul DifferentiableWithinAt.smul
-/

#print DifferentiableAt.smul /-
@[simp]
theorem DifferentiableAt.smul (hc : DifferentiableAt 𝕜 c x) (hf : DifferentiableAt 𝕜 f x) :
    DifferentiableAt 𝕜 (fun y => c y • f y) x :=
  (hc.HasFDerivAt.smul hf.HasFDerivAt).DifferentiableAt
#align differentiable_at.smul DifferentiableAt.smul
-/

#print DifferentiableOn.smul /-
theorem DifferentiableOn.smul (hc : DifferentiableOn 𝕜 c s) (hf : DifferentiableOn 𝕜 f s) :
    DifferentiableOn 𝕜 (fun y => c y • f y) s := fun x hx => (hc x hx).smul (hf x hx)
#align differentiable_on.smul DifferentiableOn.smul
-/

#print Differentiable.smul /-
@[simp]
theorem Differentiable.smul (hc : Differentiable 𝕜 c) (hf : Differentiable 𝕜 f) :
    Differentiable 𝕜 fun y => c y • f y := fun x => (hc x).smul (hf x)
#align differentiable.smul Differentiable.smul
-/

#print fderivWithin_smul /-
theorem fderivWithin_smul (hxs : UniqueDiffWithinAt 𝕜 s x) (hc : DifferentiableWithinAt 𝕜 c s x)
    (hf : DifferentiableWithinAt 𝕜 f s x) :
    fderivWithin 𝕜 (fun y => c y • f y) s x =
      c x • fderivWithin 𝕜 f s x + (fderivWithin 𝕜 c s x).smul_right (f x) :=
  (hc.HasFDerivWithinAt.smul hf.HasFDerivWithinAt).fderivWithin hxs
#align fderiv_within_smul fderivWithin_smul
-/

#print fderiv_smul /-
theorem fderiv_smul (hc : DifferentiableAt 𝕜 c x) (hf : DifferentiableAt 𝕜 f x) :
    fderiv 𝕜 (fun y => c y • f y) x = c x • fderiv 𝕜 f x + (fderiv 𝕜 c x).smul_right (f x) :=
  (hc.HasFDerivAt.smul hf.HasFDerivAt).fderiv
#align fderiv_smul fderiv_smul
-/

#print HasStrictFDerivAt.smul_const /-
theorem HasStrictFDerivAt.smul_const (hc : HasStrictFDerivAt c c' x) (f : F) :
    HasStrictFDerivAt (fun y => c y • f) (c'.smul_right f) x := by
  simpa only [smul_zero, zero_add] using hc.smul (hasStrictFDerivAt_const f x)
#align has_strict_fderiv_at.smul_const HasStrictFDerivAt.smul_const
-/

#print HasFDerivWithinAt.smul_const /-
theorem HasFDerivWithinAt.smul_const (hc : HasFDerivWithinAt c c' s x) (f : F) :
    HasFDerivWithinAt (fun y => c y • f) (c'.smul_right f) s x := by
  simpa only [smul_zero, zero_add] using hc.smul (hasFDerivWithinAt_const f x s)
#align has_fderiv_within_at.smul_const HasFDerivWithinAt.smul_const
-/

#print HasFDerivAt.smul_const /-
theorem HasFDerivAt.smul_const (hc : HasFDerivAt c c' x) (f : F) :
    HasFDerivAt (fun y => c y • f) (c'.smul_right f) x := by
  simpa only [smul_zero, zero_add] using hc.smul (hasFDerivAt_const f x)
#align has_fderiv_at.smul_const HasFDerivAt.smul_const
-/

#print DifferentiableWithinAt.smul_const /-
theorem DifferentiableWithinAt.smul_const (hc : DifferentiableWithinAt 𝕜 c s x) (f : F) :
    DifferentiableWithinAt 𝕜 (fun y => c y • f) s x :=
  (hc.HasFDerivWithinAt.smul_const f).DifferentiableWithinAt
#align differentiable_within_at.smul_const DifferentiableWithinAt.smul_const
-/

#print DifferentiableAt.smul_const /-
theorem DifferentiableAt.smul_const (hc : DifferentiableAt 𝕜 c x) (f : F) :
    DifferentiableAt 𝕜 (fun y => c y • f) x :=
  (hc.HasFDerivAt.smul_const f).DifferentiableAt
#align differentiable_at.smul_const DifferentiableAt.smul_const
-/

#print DifferentiableOn.smul_const /-
theorem DifferentiableOn.smul_const (hc : DifferentiableOn 𝕜 c s) (f : F) :
    DifferentiableOn 𝕜 (fun y => c y • f) s := fun x hx => (hc x hx).smul_const f
#align differentiable_on.smul_const DifferentiableOn.smul_const
-/

#print Differentiable.smul_const /-
theorem Differentiable.smul_const (hc : Differentiable 𝕜 c) (f : F) :
    Differentiable 𝕜 fun y => c y • f := fun x => (hc x).smul_const f
#align differentiable.smul_const Differentiable.smul_const
-/

#print fderivWithin_smul_const /-
theorem fderivWithin_smul_const (hxs : UniqueDiffWithinAt 𝕜 s x)
    (hc : DifferentiableWithinAt 𝕜 c s x) (f : F) :
    fderivWithin 𝕜 (fun y => c y • f) s x = (fderivWithin 𝕜 c s x).smul_right f :=
  (hc.HasFDerivWithinAt.smul_const f).fderivWithin hxs
#align fderiv_within_smul_const fderivWithin_smul_const
-/

#print fderiv_smul_const /-
theorem fderiv_smul_const (hc : DifferentiableAt 𝕜 c x) (f : F) :
    fderiv 𝕜 (fun y => c y • f) x = (fderiv 𝕜 c x).smul_right f :=
  (hc.HasFDerivAt.smul_const f).fderiv
#align fderiv_smul_const fderiv_smul_const
-/

end Smul

section Mul

/-! ### Derivative of the product of two functions -/


variable {𝔸 𝔸' : Type _} [NormedRing 𝔸] [NormedCommRing 𝔸'] [NormedAlgebra 𝕜 𝔸] [NormedAlgebra 𝕜 𝔸']
  {a b : E → 𝔸} {a' b' : E →L[𝕜] 𝔸} {c d : E → 𝔸'} {c' d' : E →L[𝕜] 𝔸'}

#print HasStrictFDerivAt.mul' /-
theorem HasStrictFDerivAt.mul' {x : E} (ha : HasStrictFDerivAt a a' x)
    (hb : HasStrictFDerivAt b b' x) :
    HasStrictFDerivAt (fun y => a y * b y) (a x • b' + a'.smul_right (b x)) x :=
  ((ContinuousLinearMap.mul 𝕜 𝔸).IsBoundedBilinearMap.HasStrictFDerivAt (a x, b x)).comp x
    (ha.Prod hb)
#align has_strict_fderiv_at.mul' HasStrictFDerivAt.mul'
-/

#print HasStrictFDerivAt.mul /-
theorem HasStrictFDerivAt.mul (hc : HasStrictFDerivAt c c' x) (hd : HasStrictFDerivAt d d' x) :
    HasStrictFDerivAt (fun y => c y * d y) (c x • d' + d x • c') x := by convert hc.mul' hd; ext z;
  apply mul_comm
#align has_strict_fderiv_at.mul HasStrictFDerivAt.mul
-/

#print HasFDerivWithinAt.mul' /-
theorem HasFDerivWithinAt.mul' (ha : HasFDerivWithinAt a a' s x) (hb : HasFDerivWithinAt b b' s x) :
    HasFDerivWithinAt (fun y => a y * b y) (a x • b' + a'.smul_right (b x)) s x :=
  ((ContinuousLinearMap.mul 𝕜 𝔸).IsBoundedBilinearMap.HasFDerivAt (a x, b x)).comp_hasFDerivWithinAt
    x (ha.Prod hb)
#align has_fderiv_within_at.mul' HasFDerivWithinAt.mul'
-/

#print HasFDerivWithinAt.mul /-
theorem HasFDerivWithinAt.mul (hc : HasFDerivWithinAt c c' s x) (hd : HasFDerivWithinAt d d' s x) :
    HasFDerivWithinAt (fun y => c y * d y) (c x • d' + d x • c') s x := by convert hc.mul' hd;
  ext z; apply mul_comm
#align has_fderiv_within_at.mul HasFDerivWithinAt.mul
-/

#print HasFDerivAt.mul' /-
theorem HasFDerivAt.mul' (ha : HasFDerivAt a a' x) (hb : HasFDerivAt b b' x) :
    HasFDerivAt (fun y => a y * b y) (a x • b' + a'.smul_right (b x)) x :=
  ((ContinuousLinearMap.mul 𝕜 𝔸).IsBoundedBilinearMap.HasFDerivAt (a x, b x)).comp x (ha.Prod hb)
#align has_fderiv_at.mul' HasFDerivAt.mul'
-/

#print HasFDerivAt.mul /-
theorem HasFDerivAt.mul (hc : HasFDerivAt c c' x) (hd : HasFDerivAt d d' x) :
    HasFDerivAt (fun y => c y * d y) (c x • d' + d x • c') x := by convert hc.mul' hd; ext z;
  apply mul_comm
#align has_fderiv_at.mul HasFDerivAt.mul
-/

#print DifferentiableWithinAt.mul /-
theorem DifferentiableWithinAt.mul (ha : DifferentiableWithinAt 𝕜 a s x)
    (hb : DifferentiableWithinAt 𝕜 b s x) : DifferentiableWithinAt 𝕜 (fun y => a y * b y) s x :=
  (ha.HasFDerivWithinAt.mul' hb.HasFDerivWithinAt).DifferentiableWithinAt
#align differentiable_within_at.mul DifferentiableWithinAt.mul
-/

#print DifferentiableAt.mul /-
@[simp]
theorem DifferentiableAt.mul (ha : DifferentiableAt 𝕜 a x) (hb : DifferentiableAt 𝕜 b x) :
    DifferentiableAt 𝕜 (fun y => a y * b y) x :=
  (ha.HasFDerivAt.mul' hb.HasFDerivAt).DifferentiableAt
#align differentiable_at.mul DifferentiableAt.mul
-/

#print DifferentiableOn.mul /-
theorem DifferentiableOn.mul (ha : DifferentiableOn 𝕜 a s) (hb : DifferentiableOn 𝕜 b s) :
    DifferentiableOn 𝕜 (fun y => a y * b y) s := fun x hx => (ha x hx).mul (hb x hx)
#align differentiable_on.mul DifferentiableOn.mul
-/

#print Differentiable.mul /-
@[simp]
theorem Differentiable.mul (ha : Differentiable 𝕜 a) (hb : Differentiable 𝕜 b) :
    Differentiable 𝕜 fun y => a y * b y := fun x => (ha x).mul (hb x)
#align differentiable.mul Differentiable.mul
-/

#print DifferentiableWithinAt.pow /-
theorem DifferentiableWithinAt.pow (ha : DifferentiableWithinAt 𝕜 a s x) :
    ∀ n : ℕ, DifferentiableWithinAt 𝕜 (fun x => a x ^ n) s x
  | 0 => by simp only [pow_zero, differentiableWithinAt_const]
  | n + 1 => by simp only [pow_succ', DifferentiableWithinAt.pow n, ha.mul]
#align differentiable_within_at.pow DifferentiableWithinAt.pow
-/

#print DifferentiableAt.pow /-
@[simp]
theorem DifferentiableAt.pow (ha : DifferentiableAt 𝕜 a x) (n : ℕ) :
    DifferentiableAt 𝕜 (fun x => a x ^ n) x :=
  differentiableWithinAt_univ.mp <| ha.DifferentiableWithinAt.pow n
#align differentiable_at.pow DifferentiableAt.pow
-/

#print DifferentiableOn.pow /-
theorem DifferentiableOn.pow (ha : DifferentiableOn 𝕜 a s) (n : ℕ) :
    DifferentiableOn 𝕜 (fun x => a x ^ n) s := fun x h => (ha x h).pow n
#align differentiable_on.pow DifferentiableOn.pow
-/

#print Differentiable.pow /-
@[simp]
theorem Differentiable.pow (ha : Differentiable 𝕜 a) (n : ℕ) : Differentiable 𝕜 fun x => a x ^ n :=
  fun x => (ha x).pow n
#align differentiable.pow Differentiable.pow
-/

#print fderivWithin_mul' /-
theorem fderivWithin_mul' (hxs : UniqueDiffWithinAt 𝕜 s x) (ha : DifferentiableWithinAt 𝕜 a s x)
    (hb : DifferentiableWithinAt 𝕜 b s x) :
    fderivWithin 𝕜 (fun y => a y * b y) s x =
      a x • fderivWithin 𝕜 b s x + (fderivWithin 𝕜 a s x).smul_right (b x) :=
  (ha.HasFDerivWithinAt.mul' hb.HasFDerivWithinAt).fderivWithin hxs
#align fderiv_within_mul' fderivWithin_mul'
-/

#print fderivWithin_mul /-
theorem fderivWithin_mul (hxs : UniqueDiffWithinAt 𝕜 s x) (hc : DifferentiableWithinAt 𝕜 c s x)
    (hd : DifferentiableWithinAt 𝕜 d s x) :
    fderivWithin 𝕜 (fun y => c y * d y) s x =
      c x • fderivWithin 𝕜 d s x + d x • fderivWithin 𝕜 c s x :=
  (hc.HasFDerivWithinAt.mul hd.HasFDerivWithinAt).fderivWithin hxs
#align fderiv_within_mul fderivWithin_mul
-/

#print fderiv_mul' /-
theorem fderiv_mul' (ha : DifferentiableAt 𝕜 a x) (hb : DifferentiableAt 𝕜 b x) :
    fderiv 𝕜 (fun y => a y * b y) x = a x • fderiv 𝕜 b x + (fderiv 𝕜 a x).smul_right (b x) :=
  (ha.HasFDerivAt.mul' hb.HasFDerivAt).fderiv
#align fderiv_mul' fderiv_mul'
-/

#print fderiv_mul /-
theorem fderiv_mul (hc : DifferentiableAt 𝕜 c x) (hd : DifferentiableAt 𝕜 d x) :
    fderiv 𝕜 (fun y => c y * d y) x = c x • fderiv 𝕜 d x + d x • fderiv 𝕜 c x :=
  (hc.HasFDerivAt.mul hd.HasFDerivAt).fderiv
#align fderiv_mul fderiv_mul
-/

#print HasStrictFDerivAt.mul_const' /-
theorem HasStrictFDerivAt.mul_const' (ha : HasStrictFDerivAt a a' x) (b : 𝔸) :
    HasStrictFDerivAt (fun y => a y * b) (a'.smul_right b) x :=
  ((ContinuousLinearMap.mul 𝕜 𝔸).flip b).HasStrictFDerivAt.comp x ha
#align has_strict_fderiv_at.mul_const' HasStrictFDerivAt.mul_const'
-/

#print HasStrictFDerivAt.mul_const /-
theorem HasStrictFDerivAt.mul_const (hc : HasStrictFDerivAt c c' x) (d : 𝔸') :
    HasStrictFDerivAt (fun y => c y * d) (d • c') x := by convert hc.mul_const' d; ext z;
  apply mul_comm
#align has_strict_fderiv_at.mul_const HasStrictFDerivAt.mul_const
-/

#print HasFDerivWithinAt.mul_const' /-
theorem HasFDerivWithinAt.mul_const' (ha : HasFDerivWithinAt a a' s x) (b : 𝔸) :
    HasFDerivWithinAt (fun y => a y * b) (a'.smul_right b) s x :=
  ((ContinuousLinearMap.mul 𝕜 𝔸).flip b).HasFDerivAt.comp_hasFDerivWithinAt x ha
#align has_fderiv_within_at.mul_const' HasFDerivWithinAt.mul_const'
-/

#print HasFDerivWithinAt.mul_const /-
theorem HasFDerivWithinAt.mul_const (hc : HasFDerivWithinAt c c' s x) (d : 𝔸') :
    HasFDerivWithinAt (fun y => c y * d) (d • c') s x := by convert hc.mul_const' d; ext z;
  apply mul_comm
#align has_fderiv_within_at.mul_const HasFDerivWithinAt.mul_const
-/

#print HasFDerivAt.mul_const' /-
theorem HasFDerivAt.mul_const' (ha : HasFDerivAt a a' x) (b : 𝔸) :
    HasFDerivAt (fun y => a y * b) (a'.smul_right b) x :=
  ((ContinuousLinearMap.mul 𝕜 𝔸).flip b).HasFDerivAt.comp x ha
#align has_fderiv_at.mul_const' HasFDerivAt.mul_const'
-/

#print HasFDerivAt.mul_const /-
theorem HasFDerivAt.mul_const (hc : HasFDerivAt c c' x) (d : 𝔸') :
    HasFDerivAt (fun y => c y * d) (d • c') x := by convert hc.mul_const' d; ext z; apply mul_comm
#align has_fderiv_at.mul_const HasFDerivAt.mul_const
-/

#print DifferentiableWithinAt.mul_const /-
theorem DifferentiableWithinAt.mul_const (ha : DifferentiableWithinAt 𝕜 a s x) (b : 𝔸) :
    DifferentiableWithinAt 𝕜 (fun y => a y * b) s x :=
  (ha.HasFDerivWithinAt.mul_const' b).DifferentiableWithinAt
#align differentiable_within_at.mul_const DifferentiableWithinAt.mul_const
-/

#print DifferentiableAt.mul_const /-
theorem DifferentiableAt.mul_const (ha : DifferentiableAt 𝕜 a x) (b : 𝔸) :
    DifferentiableAt 𝕜 (fun y => a y * b) x :=
  (ha.HasFDerivAt.mul_const' b).DifferentiableAt
#align differentiable_at.mul_const DifferentiableAt.mul_const
-/

#print DifferentiableOn.mul_const /-
theorem DifferentiableOn.mul_const (ha : DifferentiableOn 𝕜 a s) (b : 𝔸) :
    DifferentiableOn 𝕜 (fun y => a y * b) s := fun x hx => (ha x hx).mul_const b
#align differentiable_on.mul_const DifferentiableOn.mul_const
-/

#print Differentiable.mul_const /-
theorem Differentiable.mul_const (ha : Differentiable 𝕜 a) (b : 𝔸) :
    Differentiable 𝕜 fun y => a y * b := fun x => (ha x).mul_const b
#align differentiable.mul_const Differentiable.mul_const
-/

#print fderivWithin_mul_const' /-
theorem fderivWithin_mul_const' (hxs : UniqueDiffWithinAt 𝕜 s x)
    (ha : DifferentiableWithinAt 𝕜 a s x) (b : 𝔸) :
    fderivWithin 𝕜 (fun y => a y * b) s x = (fderivWithin 𝕜 a s x).smul_right b :=
  (ha.HasFDerivWithinAt.mul_const' b).fderivWithin hxs
#align fderiv_within_mul_const' fderivWithin_mul_const'
-/

#print fderivWithin_mul_const /-
theorem fderivWithin_mul_const (hxs : UniqueDiffWithinAt 𝕜 s x)
    (hc : DifferentiableWithinAt 𝕜 c s x) (d : 𝔸') :
    fderivWithin 𝕜 (fun y => c y * d) s x = d • fderivWithin 𝕜 c s x :=
  (hc.HasFDerivWithinAt.mul_const d).fderivWithin hxs
#align fderiv_within_mul_const fderivWithin_mul_const
-/

#print fderiv_mul_const' /-
theorem fderiv_mul_const' (ha : DifferentiableAt 𝕜 a x) (b : 𝔸) :
    fderiv 𝕜 (fun y => a y * b) x = (fderiv 𝕜 a x).smul_right b :=
  (ha.HasFDerivAt.mul_const' b).fderiv
#align fderiv_mul_const' fderiv_mul_const'
-/

#print fderiv_mul_const /-
theorem fderiv_mul_const (hc : DifferentiableAt 𝕜 c x) (d : 𝔸') :
    fderiv 𝕜 (fun y => c y * d) x = d • fderiv 𝕜 c x :=
  (hc.HasFDerivAt.mul_const d).fderiv
#align fderiv_mul_const fderiv_mul_const
-/

#print HasStrictFDerivAt.const_mul /-
theorem HasStrictFDerivAt.const_mul (ha : HasStrictFDerivAt a a' x) (b : 𝔸) :
    HasStrictFDerivAt (fun y => b * a y) (b • a') x :=
  ((ContinuousLinearMap.mul 𝕜 𝔸) b).HasStrictFDerivAt.comp x ha
#align has_strict_fderiv_at.const_mul HasStrictFDerivAt.const_mul
-/

#print HasFDerivWithinAt.const_mul /-
theorem HasFDerivWithinAt.const_mul (ha : HasFDerivWithinAt a a' s x) (b : 𝔸) :
    HasFDerivWithinAt (fun y => b * a y) (b • a') s x :=
  ((ContinuousLinearMap.mul 𝕜 𝔸) b).HasFDerivAt.comp_hasFDerivWithinAt x ha
#align has_fderiv_within_at.const_mul HasFDerivWithinAt.const_mul
-/

#print HasFDerivAt.const_mul /-
theorem HasFDerivAt.const_mul (ha : HasFDerivAt a a' x) (b : 𝔸) :
    HasFDerivAt (fun y => b * a y) (b • a') x :=
  ((ContinuousLinearMap.mul 𝕜 𝔸) b).HasFDerivAt.comp x ha
#align has_fderiv_at.const_mul HasFDerivAt.const_mul
-/

#print DifferentiableWithinAt.const_mul /-
theorem DifferentiableWithinAt.const_mul (ha : DifferentiableWithinAt 𝕜 a s x) (b : 𝔸) :
    DifferentiableWithinAt 𝕜 (fun y => b * a y) s x :=
  (ha.HasFDerivWithinAt.const_mul b).DifferentiableWithinAt
#align differentiable_within_at.const_mul DifferentiableWithinAt.const_mul
-/

#print DifferentiableAt.const_mul /-
theorem DifferentiableAt.const_mul (ha : DifferentiableAt 𝕜 a x) (b : 𝔸) :
    DifferentiableAt 𝕜 (fun y => b * a y) x :=
  (ha.HasFDerivAt.const_mul b).DifferentiableAt
#align differentiable_at.const_mul DifferentiableAt.const_mul
-/

#print DifferentiableOn.const_mul /-
theorem DifferentiableOn.const_mul (ha : DifferentiableOn 𝕜 a s) (b : 𝔸) :
    DifferentiableOn 𝕜 (fun y => b * a y) s := fun x hx => (ha x hx).const_mul b
#align differentiable_on.const_mul DifferentiableOn.const_mul
-/

#print Differentiable.const_mul /-
theorem Differentiable.const_mul (ha : Differentiable 𝕜 a) (b : 𝔸) :
    Differentiable 𝕜 fun y => b * a y := fun x => (ha x).const_mul b
#align differentiable.const_mul Differentiable.const_mul
-/

#print fderivWithin_const_mul /-
theorem fderivWithin_const_mul (hxs : UniqueDiffWithinAt 𝕜 s x)
    (ha : DifferentiableWithinAt 𝕜 a s x) (b : 𝔸) :
    fderivWithin 𝕜 (fun y => b * a y) s x = b • fderivWithin 𝕜 a s x :=
  (ha.HasFDerivWithinAt.const_mul b).fderivWithin hxs
#align fderiv_within_const_mul fderivWithin_const_mul
-/

#print fderiv_const_mul /-
theorem fderiv_const_mul (ha : DifferentiableAt 𝕜 a x) (b : 𝔸) :
    fderiv 𝕜 (fun y => b * a y) x = b • fderiv 𝕜 a x :=
  (ha.HasFDerivAt.const_mul b).fderiv
#align fderiv_const_mul fderiv_const_mul
-/

end Mul

section AlgebraInverse

variable {R : Type _} [NormedRing R] [NormedAlgebra 𝕜 R] [CompleteSpace R]

open NormedRing ContinuousLinearMap Ring

#print hasFDerivAt_ring_inverse /-
/-- At an invertible element `x` of a normed algebra `R`, the Fréchet derivative of the inversion
operation is the linear map `λ t, - x⁻¹ * t * x⁻¹`. -/
theorem hasFDerivAt_ring_inverse (x : Rˣ) :
    HasFDerivAt Ring.inverse (-mulLeftRight 𝕜 R ↑x⁻¹ ↑x⁻¹) x :=
  by
  have h_is_o : (fun t : R => inverse (↑x + t) - ↑x⁻¹ + ↑x⁻¹ * t * ↑x⁻¹) =o[𝓝 0] fun t : R => t :=
    by
    refine' (inverse_add_norm_diff_second_order x).trans_isLittleO (is_o_norm_norm.mp _)
    simp only [norm_pow, norm_norm]
    have h12 : 1 < 2 := by norm_num
    convert (Asymptotics.isLittleO_pow_pow h12).comp_tendsto tendsto_norm_zero
    ext; simp
  have h_lim : tendsto (fun y : R => y - x) (𝓝 x) (𝓝 0) :=
    by
    refine' tendsto_zero_iff_norm_tendsto_zero.mpr _
    exact tendsto_iff_norm_tendsto_zero.mp tendsto_id
  simp only [HasFDerivAt, HasFDerivAtFilter]
  convert h_is_o.comp_tendsto h_lim
  ext y
  simp only [coe_comp', Function.comp_apply, mul_left_right_apply, neg_apply, inverse_unit x,
    Units.inv_mul, add_sub_cancel, mul_sub, sub_mul, one_mul, sub_neg_eq_add]
#align has_fderiv_at_ring_inverse hasFDerivAt_ring_inverse
-/

#print differentiableAt_inverse /-
theorem differentiableAt_inverse {x : R} (hx : IsUnit x) :
    DifferentiableAt 𝕜 (@Ring.inverse R _) x :=
  let ⟨u, hu⟩ := hx
  hu ▸ (hasFDerivAt_ring_inverse u).DifferentiableAt
#align differentiable_at_inverse differentiableAt_inverse
-/

#print differentiableWithinAt_inverse /-
theorem differentiableWithinAt_inverse {x : R} (hx : IsUnit x) (s : Set R) :
    DifferentiableWithinAt 𝕜 (@Ring.inverse R _) s x :=
  (differentiableAt_inverse hx).DifferentiableWithinAt
#align differentiable_within_at_inverse differentiableWithinAt_inverse
-/

#print differentiableOn_inverse /-
theorem differentiableOn_inverse : DifferentiableOn 𝕜 (@Ring.inverse R _) {x | IsUnit x} :=
  fun x hx => differentiableWithinAt_inverse hx _
#align differentiable_on_inverse differentiableOn_inverse
-/

#print fderiv_inverse /-
theorem fderiv_inverse (x : Rˣ) : fderiv 𝕜 (@Ring.inverse R _) x = -mulLeftRight 𝕜 R ↑x⁻¹ ↑x⁻¹ :=
  (hasFDerivAt_ring_inverse x).fderiv
#align fderiv_inverse fderiv_inverse
-/

variable {h : E → R} {z : E} {S : Set E}

#print DifferentiableWithinAt.inverse /-
theorem DifferentiableWithinAt.inverse (hf : DifferentiableWithinAt 𝕜 h S z) (hz : IsUnit (h z)) :
    DifferentiableWithinAt 𝕜 (fun x => Ring.inverse (h x)) S z :=
  (differentiableAt_inverse hz).comp_differentiableWithinAt z hf
#align differentiable_within_at.inverse DifferentiableWithinAt.inverse
-/

#print DifferentiableAt.inverse /-
@[simp]
theorem DifferentiableAt.inverse (hf : DifferentiableAt 𝕜 h z) (hz : IsUnit (h z)) :
    DifferentiableAt 𝕜 (fun x => Ring.inverse (h x)) z :=
  (differentiableAt_inverse hz).comp z hf
#align differentiable_at.inverse DifferentiableAt.inverse
-/

#print DifferentiableOn.inverse /-
theorem DifferentiableOn.inverse (hf : DifferentiableOn 𝕜 h S) (hz : ∀ x ∈ S, IsUnit (h x)) :
    DifferentiableOn 𝕜 (fun x => Ring.inverse (h x)) S := fun x h => (hf x h).inverse (hz x h)
#align differentiable_on.inverse DifferentiableOn.inverse
-/

#print Differentiable.inverse /-
@[simp]
theorem Differentiable.inverse (hf : Differentiable 𝕜 h) (hz : ∀ x, IsUnit (h x)) :
    Differentiable 𝕜 fun x => Ring.inverse (h x) := fun x => (hf x).inverse (hz x)
#align differentiable.inverse Differentiable.inverse
-/

end AlgebraInverse

/-! ### Derivative of the inverse in a division ring

Note these lemmas are primed as they need `complete_space R`, whereas the other lemmas in
`deriv/inv.lean` do not, but instead need `nontrivially_normed_field R`.
-/


section DivisionRingInverse

variable {R : Type _} [NormedDivisionRing R] [NormedAlgebra 𝕜 R] [CompleteSpace R]

open NormedRing ContinuousLinearMap Ring

#print hasFDerivAt_inv' /-
/-- At an invertible element `x` of a normed division algebra `R`, the Fréchet derivative of the
inversion operation is the linear map `λ t, - x⁻¹ * t * x⁻¹`. -/
theorem hasFDerivAt_inv' {x : R} (hx : x ≠ 0) : HasFDerivAt Inv.inv (-mulLeftRight 𝕜 R x⁻¹ x⁻¹) x :=
  by simpa using hasFDerivAt_ring_inverse (Units.mk0 _ hx)
#align has_fderiv_at_inv' hasFDerivAt_inv'
-/

#print differentiableAt_inv' /-
theorem differentiableAt_inv' {x : R} (hx : x ≠ 0) : DifferentiableAt 𝕜 Inv.inv x :=
  (hasFDerivAt_inv' hx).DifferentiableAt
#align differentiable_at_inv' differentiableAt_inv'
-/

#print differentiableWithinAt_inv' /-
theorem differentiableWithinAt_inv' {x : R} (hx : x ≠ 0) (s : Set R) :
    DifferentiableWithinAt 𝕜 (fun x => x⁻¹) s x :=
  (differentiableAt_inv' hx).DifferentiableWithinAt
#align differentiable_within_at_inv' differentiableWithinAt_inv'
-/

#print differentiableOn_inv' /-
theorem differentiableOn_inv' : DifferentiableOn 𝕜 (fun x : R => x⁻¹) {x | x ≠ 0} := fun x hx =>
  differentiableWithinAt_inv' hx _
#align differentiable_on_inv' differentiableOn_inv'
-/

#print fderiv_inv' /-
/-- Non-commutative version of `fderiv_inv` -/
theorem fderiv_inv' {x : R} (hx : x ≠ 0) : fderiv 𝕜 Inv.inv x = -mulLeftRight 𝕜 R x⁻¹ x⁻¹ :=
  (hasFDerivAt_inv' hx).fderiv
#align fderiv_inv' fderiv_inv'
-/

#print fderivWithin_inv' /-
/-- Non-commutative version of `fderiv_within_inv` -/
theorem fderivWithin_inv' {s : Set R} {x : R} (hx : x ≠ 0) (hxs : UniqueDiffWithinAt 𝕜 s x) :
    fderivWithin 𝕜 (fun x => x⁻¹) s x = -mulLeftRight 𝕜 R x⁻¹ x⁻¹ :=
  by
  rw [DifferentiableAt.fderivWithin (differentiableAt_inv' hx) hxs]
  exact fderiv_inv' hx
#align fderiv_within_inv' fderivWithin_inv'
-/

variable {h : E → R} {z : E} {S : Set E}

#print DifferentiableWithinAt.inv' /-
theorem DifferentiableWithinAt.inv' (hf : DifferentiableWithinAt 𝕜 h S z) (hz : h z ≠ 0) :
    DifferentiableWithinAt 𝕜 (fun x => (h x)⁻¹) S z :=
  (differentiableAt_inv' hz).comp_differentiableWithinAt z hf
#align differentiable_within_at.inv' DifferentiableWithinAt.inv'
-/

#print DifferentiableAt.inv' /-
@[simp]
theorem DifferentiableAt.inv' (hf : DifferentiableAt 𝕜 h z) (hz : h z ≠ 0) :
    DifferentiableAt 𝕜 (fun x => (h x)⁻¹) z :=
  (differentiableAt_inv' hz).comp z hf
#align differentiable_at.inv' DifferentiableAt.inv'
-/

#print DifferentiableOn.inv' /-
theorem DifferentiableOn.inv' (hf : DifferentiableOn 𝕜 h S) (hz : ∀ x ∈ S, h x ≠ 0) :
    DifferentiableOn 𝕜 (fun x => (h x)⁻¹) S := fun x h => (hf x h).inv' (hz x h)
#align differentiable_on.inv' DifferentiableOn.inv'
-/

#print Differentiable.inv' /-
@[simp]
theorem Differentiable.inv' (hf : Differentiable 𝕜 h) (hz : ∀ x, h x ≠ 0) :
    Differentiable 𝕜 fun x => (h x)⁻¹ := fun x => (hf x).inv' (hz x)
#align differentiable.inv' Differentiable.inv'
-/

end DivisionRingInverse

end

