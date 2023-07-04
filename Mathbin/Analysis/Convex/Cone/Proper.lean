/-
Copyright (c) 2022 Apurva Nakade All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Apurva Nakade

! This file was ported from Lean 3 source module analysis.convex.cone.proper
! leanprover-community/mathlib commit 728ef9dbb281241906f25cbeb30f90d83e0bb451
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Convex.Cone.Dual
import Mathbin.Analysis.InnerProductSpace.Adjoint

/-!
# Proper cones

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define a proper cone as a nonempty, closed, convex cone. Proper cones are used in defining conic
programs which generalize linear programs. A linear program is a conic program for the positive
cone. We then prove Farkas' lemma for conic programs following the proof in the reference below.
Farkas' lemma is equivalent to strong duality. So, once have the definitions of conic programs and
linear programs, the results from this file can be used to prove duality theorems.

## TODO

The next steps are:
- Add convex_cone_class that extends set_like and replace the below instance
- Define the positive cone as a proper cone.
- Define primal and dual cone programs and prove weak duality.
- Prove regular and strong duality for cone programs using Farkas' lemma (see reference).
- Define linear programs and prove LP duality as a special case of cone duality.
- Find a better reference (textbook instead of lecture notes).
- Show submodules are (proper) cones.

## References

- [B. Gartner and J. Matousek, Cone Programming][gartnerMatousek]

-/


open ContinuousLinearMap Filter Set

namespace ConvexCone

variable {𝕜 : Type _} [OrderedSemiring 𝕜]

variable {E : Type _} [AddCommMonoid E] [TopologicalSpace E] [ContinuousAdd E] [SMul 𝕜 E]
  [ContinuousConstSMul 𝕜 E]

#print ConvexCone.closure /-
/-- The closure of a convex cone inside a topological space as a convex cone. This
construction is mainly used for defining maps between proper cones. -/
protected def closure (K : ConvexCone 𝕜 E) : ConvexCone 𝕜 E
    where
  carrier := closure ↑K
  smul_mem' c hc _ h₁ :=
    map_mem_closure (continuous_id'.const_smul c) h₁ fun _ h₂ => K.smul_mem hc h₂
  add_mem' _ h₁ _ h₂ := map_mem_closure₂ continuous_add h₁ h₂ K.add_mem
#align convex_cone.closure ConvexCone.closure
-/

#print ConvexCone.coe_closure /-
@[simp, norm_cast]
theorem coe_closure (K : ConvexCone 𝕜 E) : (K.closure : Set E) = closure K :=
  rfl
#align convex_cone.coe_closure ConvexCone.coe_closure
-/

#print ConvexCone.mem_closure /-
@[simp]
protected theorem mem_closure {K : ConvexCone 𝕜 E} {a : E} :
    a ∈ K.closure ↔ a ∈ closure (K : Set E) :=
  Iff.rfl
#align convex_cone.mem_closure ConvexCone.mem_closure
-/

#print ConvexCone.closure_eq /-
@[simp]
theorem closure_eq {K L : ConvexCone 𝕜 E} : K.closure = L ↔ closure (K : Set E) = L :=
  SetLike.ext'_iff
#align convex_cone.closure_eq ConvexCone.closure_eq
-/

end ConvexCone

#print ProperCone /-
/-- A proper cone is a convex cone `K` that is nonempty and closed. Proper cones have the nice
property that the dual of the dual of a proper cone is itself. This makes them useful for defining
cone programs and proving duality theorems. -/
structure ProperCone (𝕜 : Type _) (E : Type _) [OrderedSemiring 𝕜] [AddCommMonoid E]
    [TopologicalSpace E] [SMul 𝕜 E] extends ConvexCone 𝕜 E where
  nonempty' : (carrier : Set E).Nonempty
  is_closed' : IsClosed (carrier : Set E)
#align proper_cone ProperCone
-/

namespace ProperCone

section SMul

variable {𝕜 : Type _} [OrderedSemiring 𝕜]

variable {E : Type _} [AddCommMonoid E] [TopologicalSpace E] [SMul 𝕜 E]

instance : Coe (ProperCone 𝕜 E) (ConvexCone 𝕜 E) :=
  ⟨fun K => K.1⟩

@[simp]
theorem toConvexCone_eq_coe (K : ProperCone 𝕜 E) : K.toConvexCone = K :=
  rfl
#align proper_cone.to_convex_cone_eq_coe ProperCone.toConvexCone_eq_coe

#print ProperCone.ext' /-
theorem ext' : Function.Injective (coe : ProperCone 𝕜 E → ConvexCone 𝕜 E) := fun S T h => by
  cases S <;> cases T <;> congr
#align proper_cone.ext' ProperCone.ext'
-/

-- TODO: add convex_cone_class that extends set_like and replace the below instance
instance : SetLike (ProperCone 𝕜 E) E
    where
  coe K := K.carrier
  coe_injective' _ _ h := ProperCone.ext' (SetLike.coe_injective h)

#print ProperCone.ext /-
@[ext]
theorem ext {S T : ProperCone 𝕜 E} (h : ∀ x, x ∈ S ↔ x ∈ T) : S = T :=
  SetLike.ext h
#align proper_cone.ext ProperCone.ext
-/

#print ProperCone.mem_coe /-
@[simp]
theorem mem_coe {x : E} {K : ProperCone 𝕜 E} : x ∈ (K : ConvexCone 𝕜 E) ↔ x ∈ K :=
  Iff.rfl
#align proper_cone.mem_coe ProperCone.mem_coe
-/

#print ProperCone.nonempty /-
protected theorem nonempty (K : ProperCone 𝕜 E) : (K : Set E).Nonempty :=
  K.nonempty'
#align proper_cone.nonempty ProperCone.nonempty
-/

#print ProperCone.isClosed /-
protected theorem isClosed (K : ProperCone 𝕜 E) : IsClosed (K : Set E) :=
  K.is_closed'
#align proper_cone.is_closed ProperCone.isClosed
-/

end SMul

section Module

variable {𝕜 : Type _} [OrderedSemiring 𝕜]

variable {E : Type _} [AddCommMonoid E] [TopologicalSpace E] [T1Space E] [Module 𝕜 E]

instance : Zero (ProperCone 𝕜 E) :=
  ⟨{  toConvexCone := 0
      nonempty' := ⟨0, rfl⟩
      is_closed' := isClosed_singleton }⟩

instance : Inhabited (ProperCone 𝕜 E) :=
  ⟨0⟩

#print ProperCone.mem_zero /-
@[simp]
theorem mem_zero (x : E) : x ∈ (0 : ProperCone 𝕜 E) ↔ x = 0 :=
  Iff.rfl
#align proper_cone.mem_zero ProperCone.mem_zero
-/

#print ProperCone.coe_zero /-
@[simp, norm_cast]
theorem coe_zero : ↑(0 : ProperCone 𝕜 E) = (0 : ConvexCone 𝕜 E) :=
  rfl
#align proper_cone.coe_zero ProperCone.coe_zero
-/

#print ProperCone.pointed_zero /-
theorem pointed_zero : (0 : ProperCone 𝕜 E).Pointed := by simp [ConvexCone.pointed_zero]
#align proper_cone.pointed_zero ProperCone.pointed_zero
-/

end Module

section InnerProductSpace

variable {E : Type _} [NormedAddCommGroup E] [InnerProductSpace ℝ E]

variable {F : Type _} [NormedAddCommGroup F] [InnerProductSpace ℝ F]

variable {G : Type _} [NormedAddCommGroup G] [InnerProductSpace ℝ G]

#print ProperCone.pointed /-
protected theorem pointed (K : ProperCone ℝ E) : (K : ConvexCone ℝ E).Pointed :=
  (K : ConvexCone ℝ E).pointed_of_nonempty_of_isClosed K.Nonempty K.IsClosed
#align proper_cone.pointed ProperCone.pointed
-/

#print ProperCone.map /-
/-- The closure of image of a proper cone under a continuous `ℝ`-linear map is a proper cone. We
use continuous maps here so that the comap of f is also a map between proper cones. -/
noncomputable def map (f : E →L[ℝ] F) (K : ProperCone ℝ E) : ProperCone ℝ F
    where
  toConvexCone := ConvexCone.closure (ConvexCone.map (f : E →ₗ[ℝ] F) ↑K)
  nonempty' :=
    ⟨0, subset_closure <| SetLike.mem_coe.2 <| ConvexCone.mem_map.2 ⟨0, K.Pointed, map_zero _⟩⟩
  is_closed' := isClosed_closure
#align proper_cone.map ProperCone.map
-/

#print ProperCone.coe_map /-
@[simp, norm_cast]
theorem coe_map (f : E →L[ℝ] F) (K : ProperCone ℝ E) :
    ↑(K.map f) = (ConvexCone.map (f : E →ₗ[ℝ] F) ↑K).closure :=
  rfl
#align proper_cone.coe_map ProperCone.coe_map
-/

#print ProperCone.mem_map /-
@[simp]
theorem mem_map {f : E →L[ℝ] F} {K : ProperCone ℝ E} {y : F} :
    y ∈ K.map f ↔ y ∈ (ConvexCone.map (f : E →ₗ[ℝ] F) ↑K).closure :=
  Iff.rfl
#align proper_cone.mem_map ProperCone.mem_map
-/

#print ProperCone.map_id /-
@[simp]
theorem map_id (K : ProperCone ℝ E) : K.map (ContinuousLinearMap.id ℝ E) = K :=
  ProperCone.ext' <| by simpa using IsClosed.closure_eq K.is_closed
#align proper_cone.map_id ProperCone.map_id
-/

#print ProperCone.dual /-
/-- The inner dual cone of a proper cone is a proper cone. -/
def dual (K : ProperCone ℝ E) : ProperCone ℝ E
    where
  toConvexCone := (K : Set E).innerDualCone
  nonempty' := ⟨0, pointed_innerDualCone _⟩
  is_closed' := isClosed_innerDualCone _
#align proper_cone.dual ProperCone.dual
-/

#print ProperCone.coe_dual /-
@[simp, norm_cast]
theorem coe_dual (K : ProperCone ℝ E) : ↑(dual K) = (K : Set E).innerDualCone :=
  rfl
#align proper_cone.coe_dual ProperCone.coe_dual
-/

#print ProperCone.mem_dual /-
@[simp]
theorem mem_dual {K : ProperCone ℝ E} {y : E} : y ∈ dual K ↔ ∀ ⦃x⦄, x ∈ K → 0 ≤ ⟪x, y⟫_ℝ := by
  rw [← mem_coe, coe_dual, mem_innerDualCone _ _]; rfl
#align proper_cone.mem_dual ProperCone.mem_dual
-/

#print ProperCone.comap /-
/-- The preimage of a proper cone under a continuous `ℝ`-linear map is a proper cone. -/
noncomputable def comap (f : E →L[ℝ] F) (S : ProperCone ℝ F) : ProperCone ℝ E
    where
  toConvexCone := ConvexCone.comap (f : E →ₗ[ℝ] F) S
  nonempty' :=
    ⟨0, by
      simp only [ConvexCone.comap, mem_preimage, map_zero, SetLike.mem_coe, mem_coe]
      apply ProperCone.pointed⟩
  is_closed' := by
    simp only [ConvexCone.comap, ContinuousLinearMap.coe_coe]
    apply IsClosed.preimage f.2 S.is_closed
#align proper_cone.comap ProperCone.comap
-/

#print ProperCone.coe_comap /-
@[simp]
theorem coe_comap (f : E →L[ℝ] F) (S : ProperCone ℝ F) : (S.comap f : Set E) = f ⁻¹' S :=
  rfl
#align proper_cone.coe_comap ProperCone.coe_comap
-/

#print ProperCone.comap_id /-
@[simp]
theorem comap_id (S : ConvexCone ℝ E) : S.comap LinearMap.id = S :=
  SetLike.coe_injective preimage_id
#align proper_cone.comap_id ProperCone.comap_id
-/

#print ProperCone.comap_comap /-
theorem comap_comap (g : F →L[ℝ] G) (f : E →L[ℝ] F) (S : ProperCone ℝ G) :
    (S.comap g).comap f = S.comap (g.comp f) :=
  SetLike.coe_injective <| preimage_comp.symm
#align proper_cone.comap_comap ProperCone.comap_comap
-/

#print ProperCone.mem_comap /-
@[simp]
theorem mem_comap {f : E →L[ℝ] F} {S : ProperCone ℝ F} {x : E} : x ∈ S.comap f ↔ f x ∈ S :=
  Iff.rfl
#align proper_cone.mem_comap ProperCone.mem_comap
-/

end InnerProductSpace

section CompleteSpace

variable {E : Type _} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

variable {F : Type _} [NormedAddCommGroup F] [InnerProductSpace ℝ F] [CompleteSpace F]

#print ProperCone.dual_dual /-
/-- The dual of the dual of a proper cone is itself. -/
@[simp]
theorem dual_dual (K : ProperCone ℝ E) : K.dual.dual = K :=
  ProperCone.ext' <|
    (K : ConvexCone ℝ E).innerDualCone_of_innerDualCone_eq_self K.Nonempty K.IsClosed
#align proper_cone.dual_dual ProperCone.dual_dual
-/

#print ProperCone.hyperplane_separation /-
/-- This is a relative version of
`convex_cone.hyperplane_separation_of_nonempty_of_is_closed_of_nmem`, which we recover by setting
`f` to be the identity map. This is a geometric interpretation of the Farkas' lemma
stated using proper cones. -/
theorem hyperplane_separation (K : ProperCone ℝ E) {f : E →L[ℝ] F} {b : F} :
    b ∈ K.map f ↔ ∀ y : F, adjoint f y ∈ K.dual → 0 ≤ ⟪y, b⟫_ℝ :=
  Iff.intro
    (by
      -- suppose `b ∈ K.map f`
      simp only [ProperCone.mem_map, ProperCone.mem_dual, adjoint_inner_right,
        ConvexCone.mem_closure, mem_closure_iff_seq_limit]
      -- there is a sequence `seq : ℕ → F` in the image of `f` that converges to `b`
      rintro ⟨seq, hmem, htends⟩ y hinner
      suffices h : ∀ n, 0 ≤ ⟪y, seq n⟫_ℝ;
      exact
        ge_of_tendsto'
          (Continuous.seqContinuous (Continuous.inner (@continuous_const _ _ _ _ y) continuous_id)
            htends)
          h
      intro n
      obtain ⟨_, h, hseq⟩ := hmem n
      simpa only [← hseq, real_inner_comm] using hinner h)
    (by
      -- proof by contradiction
      -- suppose `b ∉ K.map f`
      intro h
      contrapose! h
      -- as `b ∉ K.map f`, there is a hyperplane `y` separating `b` from `K.map f`
      obtain ⟨y, hxy, hyb⟩ :=
        ConvexCone.hyperplane_separation_of_nonempty_of_isClosed_of_nmem _ (K.map f).Nonempty
          (K.map f).IsClosed h
      -- the rest of the proof is a straightforward algebraic manipulation
      refine' ⟨y, _, hyb⟩
      simp_rw [ProperCone.mem_dual, adjoint_inner_right]
      intro x hxK
      apply hxy (f x)
      rw [to_convex_cone_eq_coe, ProperCone.coe_map]
      apply subset_closure
      rw [SetLike.mem_coe, ConvexCone.mem_map]
      use ⟨x, hxK, rfl⟩)
#align proper_cone.hyperplane_separation ProperCone.hyperplane_separation
-/

#print ProperCone.hyperplane_separation_of_nmem /-
theorem hyperplane_separation_of_nmem (K : ProperCone ℝ E) {f : E →L[ℝ] F} {b : F}
    (disj : b ∉ K.map f) : ∃ y : F, adjoint f y ∈ K.dual ∧ ⟪y, b⟫_ℝ < 0 := by contrapose! disj;
  rwa [K.hyperplane_separation]
#align proper_cone.hyperplane_separation_of_nmem ProperCone.hyperplane_separation_of_nmem
-/

end CompleteSpace

end ProperCone

