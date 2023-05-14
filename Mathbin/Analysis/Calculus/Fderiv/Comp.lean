/-
Copyright (c) 2019 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Sébastien Gouëzel, Yury Kudryashov

! This file was ported from Lean 3 source module analysis.calculus.fderiv.comp
! leanprover-community/mathlib commit e3fb84046afd187b710170887195d50bada934ee
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.Fderiv.Basic

/-!
# The derivative of a composition (chain rule)

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

theorem HasFderivAtFilter.comp {g : F → G} {g' : F →L[𝕜] G} {L' : Filter F}
    (hg : HasFderivAtFilter g g' (f x) L') (hf : HasFderivAtFilter f f' x L) (hL : Tendsto f L L') :
    HasFderivAtFilter (g ∘ f) (g'.comp f') x L :=
  by
  let eq₁ := (g'.isBigO_comp _ _).trans_isLittleO hf
  let eq₂ := (hg.comp_tendsto hL).trans_isBigO hf.isBigO_sub
  refine' eq₂.triangle (eq₁.congr_left fun x' => _)
  simp
#align has_fderiv_at_filter.comp HasFderivAtFilter.comp

/- A readable version of the previous theorem,
   a general form of the chain rule. -/
example {g : F → G} {g' : F →L[𝕜] G} (hg : HasFderivAtFilter g g' (f x) (L.map f))
    (hf : HasFderivAtFilter f f' x L) : HasFderivAtFilter (g ∘ f) (g'.comp f') x L :=
  by
  unfold HasFderivAtFilter at hg
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
    

theorem HasFderivWithinAt.comp {g : F → G} {g' : F →L[𝕜] G} {t : Set F}
    (hg : HasFderivWithinAt g g' t (f x)) (hf : HasFderivWithinAt f f' s x) (hst : MapsTo f s t) :
    HasFderivWithinAt (g ∘ f) (g'.comp f') s x :=
  hg.comp x hf <| hf.ContinuousWithinAt.tendsto_nhdsWithin hst
#align has_fderiv_within_at.comp HasFderivWithinAt.comp

theorem HasFderivAt.comp_hasFderivWithinAt {g : F → G} {g' : F →L[𝕜] G}
    (hg : HasFderivAt g g' (f x)) (hf : HasFderivWithinAt f f' s x) :
    HasFderivWithinAt (g ∘ f) (g'.comp f') s x :=
  hg.comp x hf hf.ContinuousWithinAt
#align has_fderiv_at.comp_has_fderiv_within_at HasFderivAt.comp_hasFderivWithinAt

theorem HasFderivWithinAt.comp_of_mem {g : F → G} {g' : F →L[𝕜] G} {t : Set F}
    (hg : HasFderivWithinAt g g' t (f x)) (hf : HasFderivWithinAt f f' s x)
    (hst : Tendsto f (𝓝[s] x) (𝓝[t] f x)) : HasFderivWithinAt (g ∘ f) (g'.comp f') s x :=
  HasFderivAtFilter.comp x hg hf hst
#align has_fderiv_within_at.comp_of_mem HasFderivWithinAt.comp_of_mem

/-- The chain rule. -/
theorem HasFderivAt.comp {g : F → G} {g' : F →L[𝕜] G} (hg : HasFderivAt g g' (f x))
    (hf : HasFderivAt f f' x) : HasFderivAt (g ∘ f) (g'.comp f') x :=
  hg.comp x hf hf.ContinuousAt
#align has_fderiv_at.comp HasFderivAt.comp

theorem DifferentiableWithinAt.comp {g : F → G} {t : Set F}
    (hg : DifferentiableWithinAt 𝕜 g t (f x)) (hf : DifferentiableWithinAt 𝕜 f s x)
    (h : MapsTo f s t) : DifferentiableWithinAt 𝕜 (g ∘ f) s x :=
  (hg.HasFderivWithinAt.comp x hf.HasFderivWithinAt h).DifferentiableWithinAt
#align differentiable_within_at.comp DifferentiableWithinAt.comp

theorem DifferentiableWithinAt.comp' {g : F → G} {t : Set F}
    (hg : DifferentiableWithinAt 𝕜 g t (f x)) (hf : DifferentiableWithinAt 𝕜 f s x) :
    DifferentiableWithinAt 𝕜 (g ∘ f) (s ∩ f ⁻¹' t) x :=
  hg.comp x (hf.mono (inter_subset_left _ _)) (inter_subset_right _ _)
#align differentiable_within_at.comp' DifferentiableWithinAt.comp'

theorem DifferentiableAt.comp {g : F → G} (hg : DifferentiableAt 𝕜 g (f x))
    (hf : DifferentiableAt 𝕜 f x) : DifferentiableAt 𝕜 (g ∘ f) x :=
  (hg.HasFderivAt.comp x hf.HasFderivAt).DifferentiableAt
#align differentiable_at.comp DifferentiableAt.comp

theorem DifferentiableAt.comp_differentiableWithinAt {g : F → G} (hg : DifferentiableAt 𝕜 g (f x))
    (hf : DifferentiableWithinAt 𝕜 f s x) : DifferentiableWithinAt 𝕜 (g ∘ f) s x :=
  hg.DifferentiableWithinAt.comp x hf (mapsTo_univ _ _)
#align differentiable_at.comp_differentiable_within_at DifferentiableAt.comp_differentiableWithinAt

theorem fderivWithin.comp {g : F → G} {t : Set F} (hg : DifferentiableWithinAt 𝕜 g t (f x))
    (hf : DifferentiableWithinAt 𝕜 f s x) (h : MapsTo f s t) (hxs : UniqueDiffWithinAt 𝕜 s x) :
    fderivWithin 𝕜 (g ∘ f) s x = (fderivWithin 𝕜 g t (f x)).comp (fderivWithin 𝕜 f s x) :=
  (hg.HasFderivWithinAt.comp x hf.HasFderivWithinAt h).fderivWithin hxs
#align fderiv_within.comp fderivWithin.comp

/-- A version of `fderiv_within.comp` that is useful to rewrite the composition of two derivatives
  into a single derivative. This version always applies, but creates a new side-goal `f x = y`. -/
theorem fderivWithin_fderivWithin {g : F → G} {f : E → F} {x : E} {y : F} {s : Set E} {t : Set F}
    (hg : DifferentiableWithinAt 𝕜 g t y) (hf : DifferentiableWithinAt 𝕜 f s x) (h : MapsTo f s t)
    (hxs : UniqueDiffWithinAt 𝕜 s x) (hy : f x = y) (v : E) :
    fderivWithin 𝕜 g t y (fderivWithin 𝕜 f s x v) = fderivWithin 𝕜 (g ∘ f) s x v :=
  by
  subst y
  rw [fderivWithin.comp x hg hf h hxs]
  rfl
#align fderiv_within_fderiv_within fderivWithin_fderivWithin

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

theorem fderiv.comp {g : F → G} (hg : DifferentiableAt 𝕜 g (f x)) (hf : DifferentiableAt 𝕜 f x) :
    fderiv 𝕜 (g ∘ f) x = (fderiv 𝕜 g (f x)).comp (fderiv 𝕜 f x) :=
  (hg.HasFderivAt.comp x hf.HasFderivAt).fderiv
#align fderiv.comp fderiv.comp

theorem fderiv.comp_fderivWithin {g : F → G} (hg : DifferentiableAt 𝕜 g (f x))
    (hf : DifferentiableWithinAt 𝕜 f s x) (hxs : UniqueDiffWithinAt 𝕜 s x) :
    fderivWithin 𝕜 (g ∘ f) s x = (fderiv 𝕜 g (f x)).comp (fderivWithin 𝕜 f s x) :=
  (hg.HasFderivAt.comp_hasFderivWithinAt x hf.HasFderivWithinAt).fderivWithin hxs
#align fderiv.comp_fderiv_within fderiv.comp_fderivWithin

theorem DifferentiableOn.comp {g : F → G} {t : Set F} (hg : DifferentiableOn 𝕜 g t)
    (hf : DifferentiableOn 𝕜 f s) (st : MapsTo f s t) : DifferentiableOn 𝕜 (g ∘ f) s := fun x hx =>
  DifferentiableWithinAt.comp x (hg (f x) (st hx)) (hf x hx) st
#align differentiable_on.comp DifferentiableOn.comp

theorem Differentiable.comp {g : F → G} (hg : Differentiable 𝕜 g) (hf : Differentiable 𝕜 f) :
    Differentiable 𝕜 (g ∘ f) := fun x => DifferentiableAt.comp x (hg (f x)) (hf x)
#align differentiable.comp Differentiable.comp

theorem Differentiable.comp_differentiableOn {g : F → G} (hg : Differentiable 𝕜 g)
    (hf : DifferentiableOn 𝕜 f s) : DifferentiableOn 𝕜 (g ∘ f) s :=
  hg.DifferentiableOn.comp hf (mapsTo_univ _ _)
#align differentiable.comp_differentiable_on Differentiable.comp_differentiableOn

/-- The chain rule for derivatives in the sense of strict differentiability. -/
protected theorem HasStrictFderivAt.comp {g : F → G} {g' : F →L[𝕜] G}
    (hg : HasStrictFderivAt g g' (f x)) (hf : HasStrictFderivAt f f' x) :
    HasStrictFderivAt (fun x => g (f x)) (g'.comp f') x :=
  ((hg.comp_tendsto (hf.ContinuousAt.prod_map' hf.ContinuousAt)).trans_isBigO
        hf.isBigO_sub).triangle <|
    by simpa only [g'.map_sub, f'.coe_comp'] using (g'.is_O_comp _ _).trans_isLittleO hf
#align has_strict_fderiv_at.comp HasStrictFderivAt.comp

protected theorem Differentiable.iterate {f : E → E} (hf : Differentiable 𝕜 f) (n : ℕ) :
    Differentiable 𝕜 (f^[n]) :=
  Nat.recOn n differentiable_id fun n ihn => ihn.comp hf
#align differentiable.iterate Differentiable.iterate

protected theorem DifferentiableOn.iterate {f : E → E} (hf : DifferentiableOn 𝕜 f s)
    (hs : MapsTo f s s) (n : ℕ) : DifferentiableOn 𝕜 (f^[n]) s :=
  Nat.recOn n differentiableOn_id fun n ihn => ihn.comp hf hs
#align differentiable_on.iterate DifferentiableOn.iterate

variable {x}

protected theorem HasFderivAtFilter.iterate {f : E → E} {f' : E →L[𝕜] E}
    (hf : HasFderivAtFilter f f' x L) (hL : Tendsto f L L) (hx : f x = x) (n : ℕ) :
    HasFderivAtFilter (f^[n]) (f' ^ n) x L :=
  by
  induction' n with n ihn
  · exact hasFderivAtFilter_id x L
  · rw [Function.iterate_succ, pow_succ']
    rw [← hx] at ihn
    exact ihn.comp x hf hL
#align has_fderiv_at_filter.iterate HasFderivAtFilter.iterate

protected theorem HasFderivAt.iterate {f : E → E} {f' : E →L[𝕜] E} (hf : HasFderivAt f f' x)
    (hx : f x = x) (n : ℕ) : HasFderivAt (f^[n]) (f' ^ n) x :=
  by
  refine' hf.iterate _ hx n
  convert hf.continuous_at
  exact hx.symm
#align has_fderiv_at.iterate HasFderivAt.iterate

protected theorem HasFderivWithinAt.iterate {f : E → E} {f' : E →L[𝕜] E}
    (hf : HasFderivWithinAt f f' s x) (hx : f x = x) (hs : MapsTo f s s) (n : ℕ) :
    HasFderivWithinAt (f^[n]) (f' ^ n) s x :=
  by
  refine' hf.iterate _ hx n
  convert tendsto_inf.2 ⟨hf.continuous_within_at, _⟩
  exacts[hx.symm, (tendsto_principal_principal.2 hs).mono_left inf_le_right]
#align has_fderiv_within_at.iterate HasFderivWithinAt.iterate

protected theorem HasStrictFderivAt.iterate {f : E → E} {f' : E →L[𝕜] E}
    (hf : HasStrictFderivAt f f' x) (hx : f x = x) (n : ℕ) : HasStrictFderivAt (f^[n]) (f' ^ n) x :=
  by
  induction' n with n ihn
  · exact hasStrictFderivAt_id x
  · rw [Function.iterate_succ, pow_succ']
    rw [← hx] at ihn
    exact ihn.comp x hf
#align has_strict_fderiv_at.iterate HasStrictFderivAt.iterate

protected theorem DifferentiableAt.iterate {f : E → E} (hf : DifferentiableAt 𝕜 f x) (hx : f x = x)
    (n : ℕ) : DifferentiableAt 𝕜 (f^[n]) x :=
  (hf.HasFderivAt.iterate hx n).DifferentiableAt
#align differentiable_at.iterate DifferentiableAt.iterate

protected theorem DifferentiableWithinAt.iterate {f : E → E} (hf : DifferentiableWithinAt 𝕜 f s x)
    (hx : f x = x) (hs : MapsTo f s s) (n : ℕ) : DifferentiableWithinAt 𝕜 (f^[n]) s x :=
  (hf.HasFderivWithinAt.iterate hx hs n).DifferentiableWithinAt
#align differentiable_within_at.iterate DifferentiableWithinAt.iterate

end Composition

end

