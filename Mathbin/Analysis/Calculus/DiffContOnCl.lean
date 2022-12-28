/-
Copyright (c) 2022 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module analysis.calculus.diff_cont_on_cl
! leanprover-community/mathlib commit 46a64b5b4268c594af770c44d9e502afc6a515cb
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.Deriv

/-!
# Functions differentiable on a domain and continuous on its closure

Many theorems in complex analysis assume that a function is complex differentiable on a domain and
is continuous on its closure. In this file we define a predicate `diff_cont_on_cl` that expresses
this property and prove basic facts about this predicate.
-/


open Set Filter Metric

open TopologicalSpace

variable (𝕜 : Type _) {E F G : Type _} [NontriviallyNormedField 𝕜] [NormedAddCommGroup E]
  [NormedAddCommGroup F] [NormedSpace 𝕜 E] [NormedSpace 𝕜 F] [NormedAddCommGroup G]
  [NormedSpace 𝕜 G] {f g : E → F} {s t : Set E} {x : E}

/-- A predicate saying that a function is differentiable on a set and is continuous on its
closure. This is a common assumption in complex analysis. -/
@[protect_proj]
structure DiffContOnCl (f : E → F) (s : Set E) : Prop where
  DifferentiableOn : DifferentiableOn 𝕜 f s
  ContinuousOn : ContinuousOn f (closure s)
#align diff_cont_on_cl DiffContOnCl

variable {𝕜}

theorem DifferentiableOn.diffContOnCl (h : DifferentiableOn 𝕜 f (closure s)) : DiffContOnCl 𝕜 f s :=
  ⟨h.mono subset_closure, h.ContinuousOn⟩
#align differentiable_on.diff_cont_on_cl DifferentiableOn.diffContOnCl

theorem Differentiable.diffContOnCl (h : Differentiable 𝕜 f) : DiffContOnCl 𝕜 f s :=
  ⟨h.DifferentiableOn, h.Continuous.ContinuousOn⟩
#align differentiable.diff_cont_on_cl Differentiable.diffContOnCl

theorem IsClosed.diff_cont_on_cl_iff (hs : IsClosed s) :
    DiffContOnCl 𝕜 f s ↔ DifferentiableOn 𝕜 f s :=
  ⟨fun h => h.DifferentiableOn, fun h => ⟨h, hs.closure_eq.symm ▸ h.ContinuousOn⟩⟩
#align is_closed.diff_cont_on_cl_iff IsClosed.diff_cont_on_cl_iff

theorem diff_cont_on_cl_univ : DiffContOnCl 𝕜 f univ ↔ Differentiable 𝕜 f :=
  is_closed_univ.diff_cont_on_cl_iff.trans differentiable_on_univ
#align diff_cont_on_cl_univ diff_cont_on_cl_univ

theorem diffContOnClConst {c : F} : DiffContOnCl 𝕜 (fun x : E => c) s :=
  ⟨differentiableOnConst c, continuous_on_const⟩
#align diff_cont_on_cl_const diffContOnClConst

namespace DiffContOnCl

theorem comp {g : G → E} {t : Set G} (hf : DiffContOnCl 𝕜 f s) (hg : DiffContOnCl 𝕜 g t)
    (h : MapsTo g t s) : DiffContOnCl 𝕜 (f ∘ g) t :=
  ⟨hf.1.comp hg.1 h, hf.2.comp hg.2 <| h.closure_of_continuous_on hg.2⟩
#align diff_cont_on_cl.comp DiffContOnCl.comp

theorem continuous_on_ball [NormedSpace ℝ E] {x : E} {r : ℝ} (h : DiffContOnCl 𝕜 f (ball x r)) :
    ContinuousOn f (closedBall x r) :=
  by
  rcases eq_or_ne r 0 with (rfl | hr)
  · rw [closed_ball_zero]
    exact continuous_on_singleton f x
  · rw [← closure_ball x hr]
    exact h.continuous_on
#align diff_cont_on_cl.continuous_on_ball DiffContOnCl.continuous_on_ball

theorem mkBall {x : E} {r : ℝ} (hd : DifferentiableOn 𝕜 f (ball x r))
    (hc : ContinuousOn f (closedBall x r)) : DiffContOnCl 𝕜 f (ball x r) :=
  ⟨hd, hc.mono <| closure_ball_subset_closed_ball⟩
#align diff_cont_on_cl.mk_ball DiffContOnCl.mkBall

protected theorem differentiableAt (h : DiffContOnCl 𝕜 f s) (hs : IsOpen s) (hx : x ∈ s) :
    DifferentiableAt 𝕜 f x :=
  h.DifferentiableOn.DifferentiableAt <| hs.mem_nhds hx
#align diff_cont_on_cl.differentiable_at DiffContOnCl.differentiableAt

theorem differentiableAt' (h : DiffContOnCl 𝕜 f s) (hx : s ∈ 𝓝 x) : DifferentiableAt 𝕜 f x :=
  h.DifferentiableOn.DifferentiableAt hx
#align diff_cont_on_cl.differentiable_at' DiffContOnCl.differentiableAt'

protected theorem mono (h : DiffContOnCl 𝕜 f s) (ht : t ⊆ s) : DiffContOnCl 𝕜 f t :=
  ⟨h.DifferentiableOn.mono ht, h.ContinuousOn.mono (closure_mono ht)⟩
#align diff_cont_on_cl.mono DiffContOnCl.mono

theorem add (hf : DiffContOnCl 𝕜 f s) (hg : DiffContOnCl 𝕜 g s) : DiffContOnCl 𝕜 (f + g) s :=
  ⟨hf.1.add hg.1, hf.2.add hg.2⟩
#align diff_cont_on_cl.add DiffContOnCl.add

theorem addConst (hf : DiffContOnCl 𝕜 f s) (c : F) : DiffContOnCl 𝕜 (fun x => f x + c) s :=
  hf.add diffContOnClConst
#align diff_cont_on_cl.add_const DiffContOnCl.addConst

theorem constAdd (hf : DiffContOnCl 𝕜 f s) (c : F) : DiffContOnCl 𝕜 (fun x => c + f x) s :=
  diffContOnClConst.add hf
#align diff_cont_on_cl.const_add DiffContOnCl.constAdd

theorem neg (hf : DiffContOnCl 𝕜 f s) : DiffContOnCl 𝕜 (-f) s :=
  ⟨hf.1.neg, hf.2.neg⟩
#align diff_cont_on_cl.neg DiffContOnCl.neg

theorem sub (hf : DiffContOnCl 𝕜 f s) (hg : DiffContOnCl 𝕜 g s) : DiffContOnCl 𝕜 (f - g) s :=
  ⟨hf.1.sub hg.1, hf.2.sub hg.2⟩
#align diff_cont_on_cl.sub DiffContOnCl.sub

theorem subConst (hf : DiffContOnCl 𝕜 f s) (c : F) : DiffContOnCl 𝕜 (fun x => f x - c) s :=
  hf.sub diffContOnClConst
#align diff_cont_on_cl.sub_const DiffContOnCl.subConst

theorem constSub (hf : DiffContOnCl 𝕜 f s) (c : F) : DiffContOnCl 𝕜 (fun x => c - f x) s :=
  diffContOnClConst.sub hf
#align diff_cont_on_cl.const_sub DiffContOnCl.constSub

theorem constSmul {R : Type _} [Semiring R] [Module R F] [SMulCommClass 𝕜 R F]
    [HasContinuousConstSmul R F] (hf : DiffContOnCl 𝕜 f s) (c : R) : DiffContOnCl 𝕜 (c • f) s :=
  ⟨hf.1.const_smul c, hf.2.const_smul c⟩
#align diff_cont_on_cl.const_smul DiffContOnCl.constSmul

theorem smul {𝕜' : Type _} [NontriviallyNormedField 𝕜'] [NormedAlgebra 𝕜 𝕜'] [NormedSpace 𝕜' F]
    [IsScalarTower 𝕜 𝕜' F] {c : E → 𝕜'} {f : E → F} {s : Set E} (hc : DiffContOnCl 𝕜 c s)
    (hf : DiffContOnCl 𝕜 f s) : DiffContOnCl 𝕜 (fun x => c x • f x) s :=
  ⟨hc.1.smul hf.1, hc.2.smul hf.2⟩
#align diff_cont_on_cl.smul DiffContOnCl.smul

theorem smulConst {𝕜' : Type _} [NontriviallyNormedField 𝕜'] [NormedAlgebra 𝕜 𝕜'] [NormedSpace 𝕜' F]
    [IsScalarTower 𝕜 𝕜' F] {c : E → 𝕜'} {s : Set E} (hc : DiffContOnCl 𝕜 c s) (y : F) :
    DiffContOnCl 𝕜 (fun x => c x • y) s :=
  hc.smul diffContOnClConst
#align diff_cont_on_cl.smul_const DiffContOnCl.smulConst

theorem inv {f : E → 𝕜} (hf : DiffContOnCl 𝕜 f s) (h₀ : ∀ x ∈ closure s, f x ≠ 0) :
    DiffContOnCl 𝕜 f⁻¹ s :=
  ⟨(differentiableOnInv.comp hf.1) fun x hx => h₀ _ (subset_closure hx), hf.2.inv₀ h₀⟩
#align diff_cont_on_cl.inv DiffContOnCl.inv

end DiffContOnCl

theorem Differentiable.compDiffContOnCl {g : G → E} {t : Set G} (hf : Differentiable 𝕜 f)
    (hg : DiffContOnCl 𝕜 g t) : DiffContOnCl 𝕜 (f ∘ g) t :=
  hf.DiffContOnCl.comp hg (mapsTo_image _ _)
#align differentiable.comp_diff_cont_on_cl Differentiable.compDiffContOnCl

theorem DifferentiableOn.diffContOnClBall {U : Set E} {c : E} {R : ℝ} (hf : DifferentiableOn 𝕜 f U)
    (hc : closedBall c R ⊆ U) : DiffContOnCl 𝕜 f (ball c R) :=
  DiffContOnCl.mkBall (hf.mono (ball_subset_closed_ball.trans hc)) (hf.ContinuousOn.mono hc)
#align differentiable_on.diff_cont_on_cl_ball DifferentiableOn.diffContOnClBall

