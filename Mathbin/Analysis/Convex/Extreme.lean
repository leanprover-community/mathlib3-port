/-
Copyright (c) 2021 Yaël Dillies, Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Bhavik Mehta

! This file was ported from Lean 3 source module analysis.convex.extreme
! leanprover-community/mathlib commit 48085f140e684306f9e7da907cd5932056d1aded
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Convex.Hull

/-!
# Extreme sets

This file defines extreme sets and extreme points for sets in a module.

An extreme set of `A` is a subset of `A` that is as far as it can get in any outward direction: If
point `x` is in it and point `y ∈ A`, then the line passing through `x` and `y` leaves `A` at `x`.
This is an analytic notion of "being on the side of". It is weaker than being exposed (see
`is_exposed.is_extreme`).

## Main declarations

* `is_extreme 𝕜 A B`: States that `B` is an extreme set of `A` (in the literature, `A` is often
  implicit).
* `set.extreme_points 𝕜 A`: Set of extreme points of `A` (corresponding to extreme singletons).
* `convex.mem_extreme_points_iff_convex_diff`: A useful equivalent condition to being an extreme
  point: `x` is an extreme point iff `A \ {x}` is convex.

## Implementation notes

The exact definition of extremeness has been carefully chosen so as to make as many lemmas
unconditional (in particular, the Krein-Milman theorem doesn't need the set to be convex!).
In practice, `A` is often assumed to be a convex set.

## References

See chapter 8 of [Barry Simon, *Convexity*][simon2011]

## TODO

Define intrinsic frontier and prove lemmas related to extreme sets and points.

More not-yet-PRed stuff is available on the branch `sperner_again`.
-/


open Classical Affine

open Set

variable (𝕜 : Type _) {E : Type _}

section SMul

variable [OrderedSemiring 𝕜] [AddCommMonoid E] [SMul 𝕜 E]

/-- A set `B` is an extreme subset of `A` if `B ⊆ A` and all points of `B` only belong to open
segments whose ends are in `B`. -/
def IsExtreme (A B : Set E) : Prop :=
  B ⊆ A ∧ ∀ ⦃x₁⦄, x₁ ∈ A → ∀ ⦃x₂⦄, x₂ ∈ A → ∀ ⦃x⦄, x ∈ B → x ∈ openSegment 𝕜 x₁ x₂ → x₁ ∈ B ∧ x₂ ∈ B
#align is_extreme IsExtreme

/-- A point `x` is an extreme point of a set `A` if `x` belongs to no open segment with ends in
`A`, except for the obvious `open_segment x x`. -/
def Set.extremePoints (A : Set E) : Set E :=
  { x ∈ A | ∀ ⦃x₁⦄, x₁ ∈ A → ∀ ⦃x₂⦄, x₂ ∈ A → x ∈ openSegment 𝕜 x₁ x₂ → x₁ = x ∧ x₂ = x }
#align set.extreme_points Set.extremePoints

@[refl]
protected theorem IsExtreme.refl (A : Set E) : IsExtreme 𝕜 A A :=
  ⟨Subset.rfl, fun x₁ hx₁A x₂ hx₂A x hxA hx => ⟨hx₁A, hx₂A⟩⟩
#align is_extreme.refl IsExtreme.refl

variable {𝕜} {A B C : Set E} {x : E}

protected theorem IsExtreme.rfl : IsExtreme 𝕜 A A :=
  IsExtreme.refl 𝕜 A
#align is_extreme.rfl IsExtreme.rfl

@[trans]
protected theorem IsExtreme.trans (hAB : IsExtreme 𝕜 A B) (hBC : IsExtreme 𝕜 B C) :
    IsExtreme 𝕜 A C :=
  by
  refine' ⟨subset.trans hBC.1 hAB.1, fun x₁ hx₁A x₂ hx₂A x hxC hx => _⟩
  obtain ⟨hx₁B, hx₂B⟩ := hAB.2 hx₁A hx₂A (hBC.1 hxC) hx
  exact hBC.2 hx₁B hx₂B hxC hx
#align is_extreme.trans IsExtreme.trans

protected theorem IsExtreme.antisymm : AntiSymmetric (IsExtreme 𝕜 : Set E → Set E → Prop) :=
  fun A B hAB hBA => Subset.antisymm hBA.1 hAB.1
#align is_extreme.antisymm IsExtreme.antisymm

instance : IsPartialOrder (Set E) (IsExtreme 𝕜)
    where
  refl := IsExtreme.refl 𝕜
  trans A B C := IsExtreme.trans
  antisymm := IsExtreme.antisymm

theorem IsExtreme.inter (hAB : IsExtreme 𝕜 A B) (hAC : IsExtreme 𝕜 A C) : IsExtreme 𝕜 A (B ∩ C) :=
  by
  use subset.trans (inter_subset_left _ _) hAB.1
  rintro x₁ hx₁A x₂ hx₂A x ⟨hxB, hxC⟩ hx
  obtain ⟨hx₁B, hx₂B⟩ := hAB.2 hx₁A hx₂A hxB hx
  obtain ⟨hx₁C, hx₂C⟩ := hAC.2 hx₁A hx₂A hxC hx
  exact ⟨⟨hx₁B, hx₁C⟩, hx₂B, hx₂C⟩
#align is_extreme.inter IsExtreme.inter

protected theorem IsExtreme.mono (hAC : IsExtreme 𝕜 A C) (hBA : B ⊆ A) (hCB : C ⊆ B) :
    IsExtreme 𝕜 B C :=
  ⟨hCB, fun x₁ hx₁B x₂ hx₂B x hxC hx => hAC.2 (hBA hx₁B) (hBA hx₂B) hxC hx⟩
#align is_extreme.mono IsExtreme.mono

theorem isExtreme_interᵢ {ι : Type _} [Nonempty ι] {F : ι → Set E}
    (hAF : ∀ i : ι, IsExtreme 𝕜 A (F i)) : IsExtreme 𝕜 A (⋂ i : ι, F i) :=
  by
  obtain i := Classical.arbitrary ι
  refine' ⟨Inter_subset_of_subset i (hAF i).1, fun x₁ hx₁A x₂ hx₂A x hxF hx => _⟩
  simp_rw [mem_Inter] at hxF⊢
  have h := fun i => (hAF i).2 hx₁A hx₂A (hxF i) hx
  exact ⟨fun i => (h i).1, fun i => (h i).2⟩
#align is_extreme_Inter isExtreme_interᵢ

theorem isExtreme_bInter {F : Set (Set E)} (hF : F.Nonempty) (hAF : ∀ B ∈ F, IsExtreme 𝕜 A B) :
    IsExtreme 𝕜 A (⋂ B ∈ F, B) := by
  obtain ⟨B, hB⟩ := hF
  refine' ⟨(bInter_subset_of_mem hB).trans (hAF B hB).1, fun x₁ hx₁A x₂ hx₂A x hxF hx => _⟩
  simp_rw [mem_Inter₂] at hxF⊢
  have h := fun B hB => (hAF B hB).2 hx₁A hx₂A (hxF B hB) hx
  exact ⟨fun B hB => (h B hB).1, fun B hB => (h B hB).2⟩
#align is_extreme_bInter isExtreme_bInter

theorem isExtreme_interₛ {F : Set (Set E)} (hF : F.Nonempty) (hAF : ∀ B ∈ F, IsExtreme 𝕜 A B) :
    IsExtreme 𝕜 A (⋂₀ F) := by
  obtain ⟨B, hB⟩ := hF
  refine' ⟨(sInter_subset_of_mem hB).trans (hAF B hB).1, fun x₁ hx₁A x₂ hx₂A x hxF hx => _⟩
  simp_rw [mem_sInter] at hxF⊢
  have h := fun B hB => (hAF B hB).2 hx₁A hx₂A (hxF B hB) hx
  exact ⟨fun B hB => (h B hB).1, fun B hB => (h B hB).2⟩
#align is_extreme_sInter isExtreme_interₛ

/- ./././Mathport/Syntax/Translate/Basic.lean:628:2: warning: expanding binder collection (x₁ x₂ «expr ∈ » A) -/
theorem extremePoints_def :
    x ∈ A.extremePoints 𝕜 ↔
      x ∈ A ∧ ∀ (x₁) (_ : x₁ ∈ A) (x₂) (_ : x₂ ∈ A), x ∈ openSegment 𝕜 x₁ x₂ → x₁ = x ∧ x₂ = x :=
  Iff.rfl
#align extreme_points_def extremePoints_def

/-- x is an extreme point to A iff {x} is an extreme set of A. -/
theorem mem_extremePoints_iff_extreme_singleton : x ∈ A.extremePoints 𝕜 ↔ IsExtreme 𝕜 A {x} :=
  by
  refine' ⟨_, fun hx => ⟨singleton_subset_iff.1 hx.1, fun x₁ hx₁ x₂ hx₂ => hx.2 hx₁ hx₂ rfl⟩⟩
  rintro ⟨hxA, hAx⟩
  use singleton_subset_iff.2 hxA
  rintro x₁ hx₁A x₂ hx₂A y (rfl : y = x)
  exact hAx hx₁A hx₂A
#align mem_extreme_points_iff_extreme_singleton mem_extremePoints_iff_extreme_singleton

theorem extremePoints_subset : A.extremePoints 𝕜 ⊆ A := fun x hx => hx.1
#align extreme_points_subset extremePoints_subset

@[simp]
theorem extremePoints_empty : (∅ : Set E).extremePoints 𝕜 = ∅ :=
  subset_empty_iff.1 extremePoints_subset
#align extreme_points_empty extremePoints_empty

@[simp]
theorem extremePoints_singleton : ({x} : Set E).extremePoints 𝕜 = {x} :=
  extremePoints_subset.antisymm <|
    singleton_subset_iff.2 ⟨mem_singleton x, fun x₁ hx₁ x₂ hx₂ _ => ⟨hx₁, hx₂⟩⟩
#align extreme_points_singleton extremePoints_singleton

theorem inter_extremePoints_subset_extremePoints_of_subset (hBA : B ⊆ A) :
    B ∩ A.extremePoints 𝕜 ⊆ B.extremePoints 𝕜 := fun x ⟨hxB, hxA⟩ =>
  ⟨hxB, fun x₁ hx₁ x₂ hx₂ hx => hxA.2 (hBA hx₁) (hBA hx₂) hx⟩
#align inter_extreme_points_subset_extreme_points_of_subset inter_extremePoints_subset_extremePoints_of_subset

theorem IsExtreme.extremePoints_subset_extremePoints (hAB : IsExtreme 𝕜 A B) :
    B.extremePoints 𝕜 ⊆ A.extremePoints 𝕜 := fun x hx =>
  mem_extremePoints_iff_extreme_singleton.2
    (hAB.trans (mem_extremePoints_iff_extreme_singleton.1 hx))
#align is_extreme.extreme_points_subset_extreme_points IsExtreme.extremePoints_subset_extremePoints

theorem IsExtreme.extremePoints_eq (hAB : IsExtreme 𝕜 A B) :
    B.extremePoints 𝕜 = B ∩ A.extremePoints 𝕜 :=
  Subset.antisymm (fun x hx => ⟨hx.1, hAB.extremePoints_subset_extremePoints hx⟩)
    (inter_extremePoints_subset_extremePoints_of_subset hAB.1)
#align is_extreme.extreme_points_eq IsExtreme.extremePoints_eq

end SMul

section OrderedSemiring

variable {𝕜} [OrderedSemiring 𝕜] [AddCommGroup E] [Module 𝕜 E] {A B : Set E} {x : E}

theorem IsExtreme.convex_diff (hA : Convex 𝕜 A) (hAB : IsExtreme 𝕜 A B) : Convex 𝕜 (A \ B) :=
  convex_iff_openSegment_subset.2 fun x₁ ⟨hx₁A, hx₁B⟩ x₂ ⟨hx₂A, hx₂B⟩ x hx =>
    ⟨hA.openSegment_subset hx₁A hx₂A hx, fun hxB => hx₁B (hAB.2 hx₁A hx₂A hxB hx).1⟩
#align is_extreme.convex_diff IsExtreme.convex_diff

end OrderedSemiring

section LinearOrderedRing

variable {𝕜} [LinearOrderedRing 𝕜] [AddCommGroup E] [Module 𝕜 E]

variable [DenselyOrdered 𝕜] [NoZeroSMulDivisors 𝕜 E] {A B : Set E} {x : E}

/- ./././Mathport/Syntax/Translate/Basic.lean:628:2: warning: expanding binder collection (x₁ x₂ «expr ∈ » A) -/
/-- A useful restatement using `segment`: `x` is an extreme point iff the only (closed) segments
that contain it are those with `x` as one of their endpoints. -/
theorem mem_extremePoints_iff_forall_segment :
    x ∈ A.extremePoints 𝕜 ↔
      x ∈ A ∧ ∀ (x₁) (_ : x₁ ∈ A) (x₂) (_ : x₂ ∈ A), x ∈ segment 𝕜 x₁ x₂ → x₁ = x ∨ x₂ = x :=
  by
  refine' and_congr_right fun hxA => forall₄_congr fun x₁ h₁ x₂ h₂ => _
  constructor
  · rw [← insert_endpoints_openSegment]
    rintro H (rfl | rfl | hx)
    exacts[Or.inl rfl, Or.inr rfl, Or.inl <| (H hx).1]
  · intro H hx
    rcases H (openSegment_subset_segment _ _ _ hx) with (rfl | rfl)
    exacts[⟨rfl, (left_mem_openSegment_iff.1 hx).symm⟩, ⟨right_mem_openSegment_iff.1 hx, rfl⟩]
#align mem_extreme_points_iff_forall_segment mem_extremePoints_iff_forall_segment

theorem Convex.mem_extremePoints_iff_convex_diff (hA : Convex 𝕜 A) :
    x ∈ A.extremePoints 𝕜 ↔ x ∈ A ∧ Convex 𝕜 (A \ {x}) :=
  by
  use fun hx => ⟨hx.1, (mem_extremePoints_iff_extreme_singleton.1 hx).convex_diff hA⟩
  rintro ⟨hxA, hAx⟩
  refine' mem_extremePoints_iff_forall_segment.2 ⟨hxA, fun x₁ hx₁ x₂ hx₂ hx => _⟩
  rw [convex_iff_segment_subset] at hAx
  by_contra' h
  exact
    (hAx ⟨hx₁, fun hx₁ => h.1 (mem_singleton_iff.2 hx₁)⟩
          ⟨hx₂, fun hx₂ => h.2 (mem_singleton_iff.2 hx₂)⟩ hx).2
      rfl
#align convex.mem_extreme_points_iff_convex_diff Convex.mem_extremePoints_iff_convex_diff

theorem Convex.mem_extremePoints_iff_mem_diff_convexHull_diff (hA : Convex 𝕜 A) :
    x ∈ A.extremePoints 𝕜 ↔ x ∈ A \ convexHull 𝕜 (A \ {x}) := by
  rw [hA.mem_extreme_points_iff_convex_diff, hA.convex_remove_iff_not_mem_convex_hull_remove,
    mem_diff]
#align convex.mem_extreme_points_iff_mem_diff_convex_hull_diff Convex.mem_extremePoints_iff_mem_diff_convexHull_diff

theorem extremePoints_convexHull_subset : (convexHull 𝕜 A).extremePoints 𝕜 ⊆ A :=
  by
  rintro x hx
  rw [(convex_convexHull 𝕜 _).mem_extremePoints_iff_convex_diff] at hx
  by_contra
  exact
    (convexHull_min (subset_diff.2 ⟨subset_convexHull 𝕜 _, disjoint_singleton_right.2 h⟩) hx.2
          hx.1).2
      rfl
  infer_instance
#align extreme_points_convex_hull_subset extremePoints_convexHull_subset

end LinearOrderedRing

