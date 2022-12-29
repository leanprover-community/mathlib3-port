/-
Copyright (c) 2022 Jireh Loreaux. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jireh Loreaux

! This file was ported from Lean 3 source module algebra.star.pointwise
! leanprover-community/mathlib commit 422e70f7ce183d2900c586a8cda8381e788a0c62
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Star.Basic
import Mathbin.Data.Set.Finite
import Mathbin.Data.Set.Pointwise.Basic

/-!
# Pointwise star operation on sets

This file defines the star operation pointwise on sets and provides the basic API.
Besides basic facts about about how the star operation acts on sets (e.g., `(s ∩ t)⋆ = s⋆ ∩ t⋆`),
if `s t : set α`, then under suitable assumption on `α`, it is shown

* `(s + t)⋆ = s⋆ + t⋆`
* `(s * t)⋆ = t⋆ + s⋆`
* `(s⁻¹)⋆ = (s⋆)⁻¹`
-/


namespace Set

open Pointwise

-- mathport name: «expr ⋆»
local postfix:max "⋆" => star

variable {α : Type _} {s t : Set α} {a : α}

/-- The set `(star s : set α)` is defined as `{x | star x ∈ s}` in locale `pointwise`.
In the usual case where `star` is involutive, it is equal to `{star s | x ∈ s}`, see
`set.image_star`. -/
protected def hasStar [HasStar α] : HasStar (Set α) :=
  ⟨preimage HasStar.star⟩
#align set.has_star Set.hasStar

scoped[Pointwise] attribute [instance] Set.hasStar

@[simp]
theorem star_empty [HasStar α] : (∅ : Set α)⋆ = ∅ :=
  rfl
#align set.star_empty Set.star_empty

@[simp]
theorem star_univ [HasStar α] : (univ : Set α)⋆ = univ :=
  rfl
#align set.star_univ Set.star_univ

@[simp]
theorem nonempty_star [HasInvolutiveStar α] {s : Set α} : s⋆.Nonempty ↔ s.Nonempty :=
  star_involutive.Surjective.nonempty_preimage
#align set.nonempty_star Set.nonempty_star

theorem Nonempty.star [HasInvolutiveStar α] {s : Set α} (h : s.Nonempty) : s⋆.Nonempty :=
  nonempty_star.2 h
#align set.nonempty.star Set.Nonempty.star

@[simp]
theorem mem_star [HasStar α] : a ∈ s⋆ ↔ a⋆ ∈ s :=
  Iff.rfl
#align set.mem_star Set.mem_star

theorem star_mem_star [HasInvolutiveStar α] : a⋆ ∈ s⋆ ↔ a ∈ s := by simp only [mem_star, star_star]
#align set.star_mem_star Set.star_mem_star

@[simp]
theorem star_preimage [HasStar α] : HasStar.star ⁻¹' s = s⋆ :=
  rfl
#align set.star_preimage Set.star_preimage

@[simp]
theorem image_star [HasInvolutiveStar α] : HasStar.star '' s = s⋆ :=
  by
  simp only [← star_preimage]
  rw [image_eq_preimage_of_inverse] <;> intro <;> simp only [star_star]
#align set.image_star Set.image_star

@[simp]
theorem inter_star [HasStar α] : (s ∩ t)⋆ = s⋆ ∩ t⋆ :=
  preimage_inter
#align set.inter_star Set.inter_star

@[simp]
theorem union_star [HasStar α] : (s ∪ t)⋆ = s⋆ ∪ t⋆ :=
  preimage_union
#align set.union_star Set.union_star

@[simp]
theorem Inter_star {ι : Sort _} [HasStar α] (s : ι → Set α) : (⋂ i, s i)⋆ = ⋂ i, (s i)⋆ :=
  preimage_Inter
#align set.Inter_star Set.Inter_star

@[simp]
theorem Union_star {ι : Sort _} [HasStar α] (s : ι → Set α) : (⋃ i, s i)⋆ = ⋃ i, (s i)⋆ :=
  preimage_Union
#align set.Union_star Set.Union_star

@[simp]
theorem compl_star [HasStar α] : (sᶜ)⋆ = s⋆ᶜ :=
  preimage_compl
#align set.compl_star Set.compl_star

@[simp]
instance [HasInvolutiveStar α] : HasInvolutiveStar (Set α)
    where
  star := HasStar.star
  star_involutive s := by simp only [← star_preimage, preimage_preimage, star_star, preimage_id']

@[simp]
theorem star_subset_star [HasInvolutiveStar α] {s t : Set α} : s⋆ ⊆ t⋆ ↔ s ⊆ t :=
  Equiv.star.Surjective.preimage_subset_preimage_iff
#align set.star_subset_star Set.star_subset_star

theorem star_subset [HasInvolutiveStar α] {s t : Set α} : s⋆ ⊆ t ↔ s ⊆ t⋆ := by
  rw [← star_subset_star, star_star]
#align set.star_subset Set.star_subset

theorem Finite.star [HasInvolutiveStar α] {s : Set α} (hs : s.Finite) : s⋆.Finite :=
  hs.Preimage <| star_injective.InjOn _
#align set.finite.star Set.Finite.star

theorem star_singleton {β : Type _} [HasInvolutiveStar β] (x : β) : ({x} : Set β)⋆ = {x⋆} :=
  by
  ext1 y
  rw [mem_star, mem_singleton_iff, mem_singleton_iff, star_eq_iff_star_eq, eq_comm]
#align set.star_singleton Set.star_singleton

protected theorem star_mul [Monoid α] [StarSemigroup α] (s t : Set α) : (s * t)⋆ = t⋆ * s⋆ := by
  simp_rw [← image_star, ← image2_mul, image_image2, image2_image_left, image2_image_right,
    star_mul, image2_swap _ s t]
#align set.star_mul Set.star_mul

protected theorem star_add [AddMonoid α] [StarAddMonoid α] (s t : Set α) : (s + t)⋆ = s⋆ + t⋆ := by
  simp_rw [← image_star, ← image2_add, image_image2, image2_image_left, image2_image_right,
    star_add]
#align set.star_add Set.star_add

@[simp]
instance [HasStar α] [HasTrivialStar α] : HasTrivialStar (Set α)
    where star_trivial s := by
    rw [← star_preimage]
    ext1
    simp [star_trivial]

protected theorem star_inv [Group α] [StarSemigroup α] (s : Set α) : s⁻¹⋆ = s⋆⁻¹ :=
  by
  ext
  simp only [mem_star, mem_inv, star_inv]
#align set.star_inv Set.star_inv

protected theorem star_inv' [DivisionRing α] [StarRing α] (s : Set α) : s⁻¹⋆ = s⋆⁻¹ :=
  by
  ext
  simp only [mem_star, mem_inv, star_inv']
#align set.star_inv' Set.star_inv'

end Set

