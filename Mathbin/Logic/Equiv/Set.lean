/-
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura, Mario Carneiro

! This file was ported from Lean 3 source module logic.equiv.set
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Function
import Mathbin.Logic.Equiv.Defs

/-!
# Equivalences and sets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we provide lemmas linking equivalences to sets.

Some notable definitions are:

* `equiv.of_injective`: an injective function is (noncomputably) equivalent to its range.
* `equiv.set_congr`: two equal sets are equivalent as types.
* `equiv.set.union`: a disjoint union of sets is equivalent to their `sum`.

This file is separate from `equiv/basic` such that we do not require the full lattice structure
on sets before defining what an equivalence is.
-/


open Function Set

universe u v w z

variable {α : Sort u} {β : Sort v} {γ : Sort w}

namespace Equiv

/- warning: equiv.range_eq_univ -> Equiv.range_eq_univ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β), Eq.{succ u2} (Set.{u2} β) (Set.range.{u2, succ u1} β α (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e)) (Set.univ.{u2} β)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β), Eq.{succ u1} (Set.{u1} β) (Set.range.{u1, succ u2} β α (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e)) (Set.univ.{u1} β)
Case conversion may be inaccurate. Consider using '#align equiv.range_eq_univ Equiv.range_eq_univₓ'. -/
@[simp]
theorem range_eq_univ {α : Type _} {β : Type _} (e : α ≃ β) : range e = univ :=
  eq_univ_of_forall e.Surjective
#align equiv.range_eq_univ Equiv.range_eq_univ

/- warning: equiv.image_eq_preimage -> Equiv.image_eq_preimage is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) (s : Set.{u1} α), Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) s) (Set.preimage.{u2, u1} β α (coeFn.{max 1 (max (succ u2) (succ u1)) (succ u1) (succ u2), max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} β α) (fun (_x : Equiv.{succ u2, succ u1} β α) => β -> α) (Equiv.hasCoeToFun.{succ u2, succ u1} β α) (Equiv.symm.{succ u1, succ u2} α β e)) s)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) (s : Set.{u2} α), Eq.{succ u1} (Set.{u1} β) (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) s) (Set.preimage.{u1, u2} β α (FunLike.coe.{max (succ u2) (succ u1), succ u1, succ u2} (Equiv.{succ u1, succ u2} β α) β (fun (_x : β) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : β) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u2} β α) (Equiv.symm.{succ u2, succ u1} α β e)) s)
Case conversion may be inaccurate. Consider using '#align equiv.image_eq_preimage Equiv.image_eq_preimageₓ'. -/
protected theorem image_eq_preimage {α β} (e : α ≃ β) (s : Set α) : e '' s = e.symm ⁻¹' s :=
  Set.ext fun x => mem_image_iff_of_inverse e.left_inv e.right_inv
#align equiv.image_eq_preimage Equiv.image_eq_preimage

/- warning: set.mem_image_equiv -> Set.mem_image_equiv is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {S : Set.{u1} α} {f : Equiv.{succ u1, succ u2} α β} {x : β}, Iff (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) f) S)) (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) (coeFn.{max 1 (max (succ u2) (succ u1)) (succ u1) (succ u2), max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} β α) (fun (_x : Equiv.{succ u2, succ u1} β α) => β -> α) (Equiv.hasCoeToFun.{succ u2, succ u1} β α) (Equiv.symm.{succ u1, succ u2} α β f) x) S)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} {S : Set.{u2} α} {f : Equiv.{succ u2, succ u1} α β} {x : β}, Iff (Membership.mem.{u1, u1} β (Set.{u1} β) (Set.instMembershipSet.{u1} β) x (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) f) S)) (Membership.mem.{u2, u2} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : β) => α) x) (Set.{u2} α) (Set.instMembershipSet.{u2} α) (FunLike.coe.{max (succ u2) (succ u1), succ u1, succ u2} (Equiv.{succ u1, succ u2} β α) β (fun (_x : β) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : β) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u2} β α) (Equiv.symm.{succ u2, succ u1} α β f) x) S)
Case conversion may be inaccurate. Consider using '#align set.mem_image_equiv Set.mem_image_equivₓ'. -/
theorem Set.mem_image_equiv {α β} {S : Set α} {f : α ≃ β} {x : β} : x ∈ f '' S ↔ f.symm x ∈ S :=
  Set.ext_iff.mp (f.image_eq_preimage S) x
#align set.mem_image_equiv Set.mem_image_equiv

/- warning: set.image_equiv_eq_preimage_symm -> Set.image_equiv_eq_preimage_symm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (S : Set.{u1} α) (f : Equiv.{succ u1, succ u2} α β), Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) f) S) (Set.preimage.{u2, u1} β α (coeFn.{max 1 (max (succ u2) (succ u1)) (succ u1) (succ u2), max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} β α) (fun (_x : Equiv.{succ u2, succ u1} β α) => β -> α) (Equiv.hasCoeToFun.{succ u2, succ u1} β α) (Equiv.symm.{succ u1, succ u2} α β f)) S)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (S : Set.{u2} α) (f : Equiv.{succ u2, succ u1} α β), Eq.{succ u1} (Set.{u1} β) (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) f) S) (Set.preimage.{u1, u2} β α (FunLike.coe.{max (succ u2) (succ u1), succ u1, succ u2} (Equiv.{succ u1, succ u2} β α) β (fun (_x : β) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : β) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u2} β α) (Equiv.symm.{succ u2, succ u1} α β f)) S)
Case conversion may be inaccurate. Consider using '#align set.image_equiv_eq_preimage_symm Set.image_equiv_eq_preimage_symmₓ'. -/
/-- Alias for `equiv.image_eq_preimage` -/
theorem Set.image_equiv_eq_preimage_symm {α β} (S : Set α) (f : α ≃ β) : f '' S = f.symm ⁻¹' S :=
  f.image_eq_preimage S
#align set.image_equiv_eq_preimage_symm Set.image_equiv_eq_preimage_symm

/- warning: set.preimage_equiv_eq_image_symm -> Set.preimage_equiv_eq_image_symm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (S : Set.{u1} α) (f : Equiv.{succ u2, succ u1} β α), Eq.{succ u2} (Set.{u2} β) (Set.preimage.{u2, u1} β α (coeFn.{max 1 (max (succ u2) (succ u1)) (succ u1) (succ u2), max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} β α) (fun (_x : Equiv.{succ u2, succ u1} β α) => β -> α) (Equiv.hasCoeToFun.{succ u2, succ u1} β α) f) S) (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) (Equiv.symm.{succ u2, succ u1} β α f)) S)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (S : Set.{u2} α) (f : Equiv.{succ u1, succ u2} β α), Eq.{succ u1} (Set.{u1} β) (Set.preimage.{u1, u2} β α (FunLike.coe.{max (succ u2) (succ u1), succ u1, succ u2} (Equiv.{succ u1, succ u2} β α) β (fun (_x : β) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : β) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u2} β α) f) S) (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) (Equiv.symm.{succ u1, succ u2} β α f)) S)
Case conversion may be inaccurate. Consider using '#align set.preimage_equiv_eq_image_symm Set.preimage_equiv_eq_image_symmₓ'. -/
/-- Alias for `equiv.image_eq_preimage` -/
theorem Set.preimage_equiv_eq_image_symm {α β} (S : Set α) (f : β ≃ α) : f ⁻¹' S = f.symm '' S :=
  (f.symm.image_eq_preimage S).symm
#align set.preimage_equiv_eq_image_symm Set.preimage_equiv_eq_image_symm

/- warning: equiv.subset_image -> Equiv.subset_image is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) (s : Set.{u1} α) (t : Set.{u2} β), Iff (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) (Set.image.{u2, u1} β α (coeFn.{max 1 (max (succ u2) (succ u1)) (succ u1) (succ u2), max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} β α) (fun (_x : Equiv.{succ u2, succ u1} β α) => β -> α) (Equiv.hasCoeToFun.{succ u2, succ u1} β α) (Equiv.symm.{succ u1, succ u2} α β e)) t) s) (HasSubset.Subset.{u2} (Set.{u2} β) (Set.hasSubset.{u2} β) t (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) s))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) (s : Set.{u2} α) (t : Set.{u1} β), Iff (HasSubset.Subset.{u2} (Set.{u2} α) (Set.instHasSubsetSet.{u2} α) (Set.image.{u1, u2} β α (FunLike.coe.{max (succ u2) (succ u1), succ u1, succ u2} (Equiv.{succ u1, succ u2} β α) β (fun (_x : β) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : β) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u2} β α) (Equiv.symm.{succ u2, succ u1} α β e)) t) s) (HasSubset.Subset.{u1} (Set.{u1} β) (Set.instHasSubsetSet.{u1} β) t (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) s))
Case conversion may be inaccurate. Consider using '#align equiv.subset_image Equiv.subset_imageₓ'. -/
@[simp]
protected theorem subset_image {α β} (e : α ≃ β) (s : Set α) (t : Set β) :
    e.symm '' t ⊆ s ↔ t ⊆ e '' s := by rw [image_subset_iff, e.image_eq_preimage]
#align equiv.subset_image Equiv.subset_image

/- warning: equiv.subset_image' -> Equiv.subset_image' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) (s : Set.{u1} α) (t : Set.{u2} β), Iff (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) s (Set.image.{u2, u1} β α (coeFn.{max 1 (max (succ u2) (succ u1)) (succ u1) (succ u2), max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} β α) (fun (_x : Equiv.{succ u2, succ u1} β α) => β -> α) (Equiv.hasCoeToFun.{succ u2, succ u1} β α) (Equiv.symm.{succ u1, succ u2} α β e)) t)) (HasSubset.Subset.{u2} (Set.{u2} β) (Set.hasSubset.{u2} β) (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) s) t)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) (s : Set.{u2} α) (t : Set.{u1} β), Iff (HasSubset.Subset.{u2} (Set.{u2} α) (Set.instHasSubsetSet.{u2} α) s (Set.image.{u1, u2} β α (FunLike.coe.{max (succ u2) (succ u1), succ u1, succ u2} (Equiv.{succ u1, succ u2} β α) β (fun (_x : β) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : β) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u2} β α) (Equiv.symm.{succ u2, succ u1} α β e)) t)) (HasSubset.Subset.{u1} (Set.{u1} β) (Set.instHasSubsetSet.{u1} β) (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) s) t)
Case conversion may be inaccurate. Consider using '#align equiv.subset_image' Equiv.subset_image'ₓ'. -/
@[simp]
protected theorem subset_image' {α β} (e : α ≃ β) (s : Set α) (t : Set β) :
    s ⊆ e.symm '' t ↔ e '' s ⊆ t :=
  calc
    s ⊆ e.symm '' t ↔ e.symm.symm '' s ⊆ t := by rw [e.symm.subset_image]
    _ ↔ e '' s ⊆ t := by rw [e.symm_symm]
    
#align equiv.subset_image' Equiv.subset_image'

/- warning: equiv.symm_image_image -> Equiv.symm_image_image is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) (s : Set.{u1} α), Eq.{succ u1} (Set.{u1} α) (Set.image.{u2, u1} β α (coeFn.{max 1 (max (succ u2) (succ u1)) (succ u1) (succ u2), max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} β α) (fun (_x : Equiv.{succ u2, succ u1} β α) => β -> α) (Equiv.hasCoeToFun.{succ u2, succ u1} β α) (Equiv.symm.{succ u1, succ u2} α β e)) (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) s)) s
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) (s : Set.{u2} α), Eq.{succ u2} (Set.{u2} α) (Set.image.{u1, u2} β α (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (Equiv.{succ u1, succ u2} β α) β (fun (_x : β) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : β) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u2} β α) (Equiv.symm.{succ u2, succ u1} α β e)) (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) s)) s
Case conversion may be inaccurate. Consider using '#align equiv.symm_image_image Equiv.symm_image_imageₓ'. -/
@[simp]
theorem symm_image_image {α β} (e : α ≃ β) (s : Set α) : e.symm '' (e '' s) = s :=
  e.leftInverse_symm.image_image s
#align equiv.symm_image_image Equiv.symm_image_image

/- warning: equiv.eq_image_iff_symm_image_eq -> Equiv.eq_image_iff_symm_image_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) (s : Set.{u1} α) (t : Set.{u2} β), Iff (Eq.{succ u2} (Set.{u2} β) t (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) s)) (Eq.{succ u1} (Set.{u1} α) (Set.image.{u2, u1} β α (coeFn.{max 1 (max (succ u2) (succ u1)) (succ u1) (succ u2), max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} β α) (fun (_x : Equiv.{succ u2, succ u1} β α) => β -> α) (Equiv.hasCoeToFun.{succ u2, succ u1} β α) (Equiv.symm.{succ u1, succ u2} α β e)) t) s)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) (s : Set.{u2} α) (t : Set.{u1} β), Iff (Eq.{succ u1} (Set.{u1} β) t (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) s)) (Eq.{succ u2} (Set.{u2} α) (Set.image.{u1, u2} β α (FunLike.coe.{max (succ u2) (succ u1), succ u1, succ u2} (Equiv.{succ u1, succ u2} β α) β (fun (_x : β) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : β) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u2} β α) (Equiv.symm.{succ u2, succ u1} α β e)) t) s)
Case conversion may be inaccurate. Consider using '#align equiv.eq_image_iff_symm_image_eq Equiv.eq_image_iff_symm_image_eqₓ'. -/
theorem eq_image_iff_symm_image_eq {α β} (e : α ≃ β) (s : Set α) (t : Set β) :
    t = e '' s ↔ e.symm '' t = s :=
  (e.symm.Injective.image_injective.eq_iff' (e.symm_image_image s)).symm
#align equiv.eq_image_iff_symm_image_eq Equiv.eq_image_iff_symm_image_eq

/- warning: equiv.image_symm_image -> Equiv.image_symm_image is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) (s : Set.{u2} β), Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) (Set.image.{u2, u1} β α (coeFn.{max 1 (max (succ u2) (succ u1)) (succ u1) (succ u2), max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} β α) (fun (_x : Equiv.{succ u2, succ u1} β α) => β -> α) (Equiv.hasCoeToFun.{succ u2, succ u1} β α) (Equiv.symm.{succ u1, succ u2} α β e)) s)) s
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) (s : Set.{u1} β), Eq.{succ u1} (Set.{u1} β) (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) (Set.image.{u1, u2} β α (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (Equiv.{succ u1, succ u2} β α) β (fun (_x : β) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : β) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u2} β α) (Equiv.symm.{succ u2, succ u1} α β e)) s)) s
Case conversion may be inaccurate. Consider using '#align equiv.image_symm_image Equiv.image_symm_imageₓ'. -/
@[simp]
theorem image_symm_image {α β} (e : α ≃ β) (s : Set β) : e '' (e.symm '' s) = s :=
  e.symm.symm_image_image s
#align equiv.image_symm_image Equiv.image_symm_image

/- warning: equiv.image_preimage -> Equiv.image_preimage is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) (s : Set.{u2} β), Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) (Set.preimage.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) s)) s
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) (s : Set.{u1} β), Eq.{succ u1} (Set.{u1} β) (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) (Set.preimage.{u2, u1} α β (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) s)) s
Case conversion may be inaccurate. Consider using '#align equiv.image_preimage Equiv.image_preimageₓ'. -/
@[simp]
theorem image_preimage {α β} (e : α ≃ β) (s : Set β) : e '' (e ⁻¹' s) = s :=
  e.Surjective.image_preimage s
#align equiv.image_preimage Equiv.image_preimage

/- warning: equiv.preimage_image -> Equiv.preimage_image is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) (s : Set.{u1} α), Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) s)) s
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) (s : Set.{u2} α), Eq.{succ u2} (Set.{u2} α) (Set.preimage.{u2, u1} α β (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) s)) s
Case conversion may be inaccurate. Consider using '#align equiv.preimage_image Equiv.preimage_imageₓ'. -/
@[simp]
theorem preimage_image {α β} (e : α ≃ β) (s : Set α) : e ⁻¹' (e '' s) = s :=
  e.Injective.preimage_image s
#align equiv.preimage_image Equiv.preimage_image

/- warning: equiv.image_compl -> Equiv.image_compl is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (f : Equiv.{succ u1, succ u2} α β) (s : Set.{u1} α), Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) f) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)) (HasCompl.compl.{u2} (Set.{u2} β) (BooleanAlgebra.toHasCompl.{u2} (Set.{u2} β) (Set.booleanAlgebra.{u2} β)) (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) f) s))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (f : Equiv.{succ u2, succ u1} α β) (s : Set.{u2} α), Eq.{succ u1} (Set.{u1} β) (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) f) (HasCompl.compl.{u2} (Set.{u2} α) (BooleanAlgebra.toHasCompl.{u2} (Set.{u2} α) (Set.instBooleanAlgebraSet.{u2} α)) s)) (HasCompl.compl.{u1} (Set.{u1} β) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} β) (Set.instBooleanAlgebraSet.{u1} β)) (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) f) s))
Case conversion may be inaccurate. Consider using '#align equiv.image_compl Equiv.image_complₓ'. -/
protected theorem image_compl {α β} (f : Equiv α β) (s : Set α) : f '' sᶜ = (f '' s)ᶜ :=
  image_compl_eq f.Bijective
#align equiv.image_compl Equiv.image_compl

/- warning: equiv.symm_preimage_preimage -> Equiv.symm_preimage_preimage is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) (s : Set.{u2} β), Eq.{succ u2} (Set.{u2} β) (Set.preimage.{u2, u1} β α (coeFn.{max 1 (max (succ u2) (succ u1)) (succ u1) (succ u2), max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} β α) (fun (_x : Equiv.{succ u2, succ u1} β α) => β -> α) (Equiv.hasCoeToFun.{succ u2, succ u1} β α) (Equiv.symm.{succ u1, succ u2} α β e)) (Set.preimage.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) s)) s
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) (s : Set.{u1} β), Eq.{succ u1} (Set.{u1} β) (Set.preimage.{u1, u2} β α (FunLike.coe.{max (succ u2) (succ u1), succ u1, succ u2} (Equiv.{succ u1, succ u2} β α) β (fun (_x : β) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : β) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u2} β α) (Equiv.symm.{succ u2, succ u1} α β e)) (Set.preimage.{u2, u1} α β (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) s)) s
Case conversion may be inaccurate. Consider using '#align equiv.symm_preimage_preimage Equiv.symm_preimage_preimageₓ'. -/
@[simp]
theorem symm_preimage_preimage {α β} (e : α ≃ β) (s : Set β) : e.symm ⁻¹' (e ⁻¹' s) = s :=
  e.rightInverse_symm.preimage_preimage s
#align equiv.symm_preimage_preimage Equiv.symm_preimage_preimage

/- warning: equiv.preimage_symm_preimage -> Equiv.preimage_symm_preimage is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) (s : Set.{u1} α), Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) (Set.preimage.{u2, u1} β α (coeFn.{max 1 (max (succ u2) (succ u1)) (succ u1) (succ u2), max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} β α) (fun (_x : Equiv.{succ u2, succ u1} β α) => β -> α) (Equiv.hasCoeToFun.{succ u2, succ u1} β α) (Equiv.symm.{succ u1, succ u2} α β e)) s)) s
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) (s : Set.{u2} α), Eq.{succ u2} (Set.{u2} α) (Set.preimage.{u2, u1} α β (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) (Set.preimage.{u1, u2} β α (FunLike.coe.{max (succ u2) (succ u1), succ u1, succ u2} (Equiv.{succ u1, succ u2} β α) β (fun (_x : β) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : β) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u2} β α) (Equiv.symm.{succ u2, succ u1} α β e)) s)) s
Case conversion may be inaccurate. Consider using '#align equiv.preimage_symm_preimage Equiv.preimage_symm_preimageₓ'. -/
@[simp]
theorem preimage_symm_preimage {α β} (e : α ≃ β) (s : Set α) : e ⁻¹' (e.symm ⁻¹' s) = s :=
  e.leftInverse_symm.preimage_preimage s
#align equiv.preimage_symm_preimage Equiv.preimage_symm_preimage

/- warning: equiv.preimage_subset -> Equiv.preimage_subset is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) (s : Set.{u2} β) (t : Set.{u2} β), Iff (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) (Set.preimage.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) s) (Set.preimage.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) t)) (HasSubset.Subset.{u2} (Set.{u2} β) (Set.hasSubset.{u2} β) s t)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) (s : Set.{u1} β) (t : Set.{u1} β), Iff (HasSubset.Subset.{u2} (Set.{u2} α) (Set.instHasSubsetSet.{u2} α) (Set.preimage.{u2, u1} α β (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) s) (Set.preimage.{u2, u1} α β (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) t)) (HasSubset.Subset.{u1} (Set.{u1} β) (Set.instHasSubsetSet.{u1} β) s t)
Case conversion may be inaccurate. Consider using '#align equiv.preimage_subset Equiv.preimage_subsetₓ'. -/
@[simp]
theorem preimage_subset {α β} (e : α ≃ β) (s t : Set β) : e ⁻¹' s ⊆ e ⁻¹' t ↔ s ⊆ t :=
  e.Surjective.preimage_subset_preimage_iff
#align equiv.preimage_subset Equiv.preimage_subset

/- warning: equiv.image_subset -> Equiv.image_subset is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) (s : Set.{u1} α) (t : Set.{u1} α), Iff (HasSubset.Subset.{u2} (Set.{u2} β) (Set.hasSubset.{u2} β) (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) s) (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) t)) (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) s t)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) (s : Set.{u2} α) (t : Set.{u2} α), Iff (HasSubset.Subset.{u1} (Set.{u1} β) (Set.instHasSubsetSet.{u1} β) (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) s) (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) t)) (HasSubset.Subset.{u2} (Set.{u2} α) (Set.instHasSubsetSet.{u2} α) s t)
Case conversion may be inaccurate. Consider using '#align equiv.image_subset Equiv.image_subsetₓ'. -/
@[simp]
theorem image_subset {α β} (e : α ≃ β) (s t : Set α) : e '' s ⊆ e '' t ↔ s ⊆ t :=
  image_subset_image_iff e.Injective
#align equiv.image_subset Equiv.image_subset

/- warning: equiv.image_eq_iff_eq -> Equiv.image_eq_iff_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) (s : Set.{u1} α) (t : Set.{u1} α), Iff (Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) s) (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) t)) (Eq.{succ u1} (Set.{u1} α) s t)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) (s : Set.{u2} α) (t : Set.{u2} α), Iff (Eq.{succ u1} (Set.{u1} β) (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) s) (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) t)) (Eq.{succ u2} (Set.{u2} α) s t)
Case conversion may be inaccurate. Consider using '#align equiv.image_eq_iff_eq Equiv.image_eq_iff_eqₓ'. -/
@[simp]
theorem image_eq_iff_eq {α β} (e : α ≃ β) (s t : Set α) : e '' s = e '' t ↔ s = t :=
  image_eq_image e.Injective
#align equiv.image_eq_iff_eq Equiv.image_eq_iff_eq

/- warning: equiv.preimage_eq_iff_eq_image -> Equiv.preimage_eq_iff_eq_image is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) (s : Set.{u2} β) (t : Set.{u1} α), Iff (Eq.{succ u1} (Set.{u1} α) (Set.preimage.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) s) t) (Eq.{succ u2} (Set.{u2} β) s (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) t))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) (s : Set.{u1} β) (t : Set.{u2} α), Iff (Eq.{succ u2} (Set.{u2} α) (Set.preimage.{u2, u1} α β (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) s) t) (Eq.{succ u1} (Set.{u1} β) s (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) t))
Case conversion may be inaccurate. Consider using '#align equiv.preimage_eq_iff_eq_image Equiv.preimage_eq_iff_eq_imageₓ'. -/
theorem preimage_eq_iff_eq_image {α β} (e : α ≃ β) (s t) : e ⁻¹' s = t ↔ s = e '' t :=
  preimage_eq_iff_eq_image e.Bijective
#align equiv.preimage_eq_iff_eq_image Equiv.preimage_eq_iff_eq_image

/- warning: equiv.eq_preimage_iff_image_eq -> Equiv.eq_preimage_iff_image_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) (s : Set.{u1} α) (t : Set.{u2} β), Iff (Eq.{succ u1} (Set.{u1} α) s (Set.preimage.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) t)) (Eq.{succ u2} (Set.{u2} β) (Set.image.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) s) t)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) (s : Set.{u2} α) (t : Set.{u1} β), Iff (Eq.{succ u2} (Set.{u2} α) s (Set.preimage.{u2, u1} α β (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) t)) (Eq.{succ u1} (Set.{u1} β) (Set.image.{u2, u1} α β (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) s) t)
Case conversion may be inaccurate. Consider using '#align equiv.eq_preimage_iff_image_eq Equiv.eq_preimage_iff_image_eqₓ'. -/
theorem eq_preimage_iff_image_eq {α β} (e : α ≃ β) (s t) : s = e ⁻¹' t ↔ e '' s = t :=
  eq_preimage_iff_image_eq e.Bijective
#align equiv.eq_preimage_iff_image_eq Equiv.eq_preimage_iff_image_eq

/- warning: equiv.prod_assoc_preimage -> Equiv.prod_assoc_preimage is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} {s : Set.{u1} α} {t : Set.{u2} β} {u : Set.{u3} γ}, Eq.{succ (max (max u1 u2) u3)} (Set.{max (max u1 u2) u3} (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ)) (Set.preimage.{max (max u1 u2) u3, max u1 u2 u3} (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ) (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ)) (coeFn.{max 1 (max (max (succ (max u1 u2)) (succ u3)) (succ u1) (succ (max u2 u3))) (max (succ u1) (succ (max u2 u3))) (succ (max u1 u2)) (succ u3), max (max (succ (max u1 u2)) (succ u3)) (succ u1) (succ (max u2 u3))} (Equiv.{max (succ (max u1 u2)) (succ u3), max (succ u1) (succ (max u2 u3))} (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ) (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ))) (fun (_x : Equiv.{max (succ (max u1 u2)) (succ u3), max (succ u1) (succ (max u2 u3))} (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ) (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ))) => (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ) -> (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ))) (Equiv.hasCoeToFun.{max (succ (max u1 u2)) (succ u3), max (succ u1) (succ (max u2 u3))} (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ) (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ))) (Equiv.prodAssoc.{u1, u2, u3} α β γ)) (Set.prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ) s (Set.prod.{u2, u3} β γ t u))) (Set.prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ (Set.prod.{u1, u2} α β s t) u)
but is expected to have type
  forall {α : Type.{u3}} {β : Type.{u2}} {γ : Type.{u1}} {s : Set.{u3} α} {t : Set.{u2} β} {u : Set.{u1} γ}, Eq.{max (max (succ u3) (succ u2)) (succ u1)} (Set.{max (max u3 u2) u1} (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ)) (Set.preimage.{max (max u3 u2) u1, max (max u3 u2) u1} (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) (FunLike.coe.{max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1)} (Equiv.{max (succ u1) (succ (max u2 u3)), max (succ (max u1 u2)) (succ u3)} (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ))) (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) (fun (_x : Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) => Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) _x) (Equiv.instFunLikeEquiv.{max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1)} (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ))) (Equiv.prodAssoc.{u3, u2, u1} α β γ)) (Set.prod.{u3, max u2 u1} α (Prod.{u2, u1} β γ) s (Set.prod.{u2, u1} β γ t u))) (Set.prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ (Set.prod.{u3, u2} α β s t) u)
Case conversion may be inaccurate. Consider using '#align equiv.prod_assoc_preimage Equiv.prod_assoc_preimageₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simp]
theorem prod_assoc_preimage {α β γ} {s : Set α} {t : Set β} {u : Set γ} :
    Equiv.prodAssoc α β γ ⁻¹' s ×ˢ t ×ˢ u = (s ×ˢ t) ×ˢ u :=
  by
  ext
  simp [and_assoc']
#align equiv.prod_assoc_preimage Equiv.prod_assoc_preimage

/- warning: equiv.prod_assoc_symm_preimage -> Equiv.prod_assoc_symm_preimage is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} {s : Set.{u1} α} {t : Set.{u2} β} {u : Set.{u3} γ}, Eq.{succ (max u1 u2 u3)} (Set.{max u1 u2 u3} (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ))) (Set.preimage.{max u1 u2 u3, max (max u1 u2) u3} (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ)) (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ) (coeFn.{max 1 (max (max (succ u1) (succ (max u2 u3))) (succ (max u1 u2)) (succ u3)) (max (succ (max u1 u2)) (succ u3)) (succ u1) (succ (max u2 u3)), max (max (succ u1) (succ (max u2 u3))) (succ (max u1 u2)) (succ u3)} (Equiv.{max (succ u1) (succ (max u2 u3)), max (succ (max u1 u2)) (succ u3)} (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ)) (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ)) (fun (_x : Equiv.{max (succ u1) (succ (max u2 u3)), max (succ (max u1 u2)) (succ u3)} (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ)) (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ)) => (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ)) -> (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ)) (Equiv.hasCoeToFun.{max (succ u1) (succ (max u2 u3)), max (succ (max u1 u2)) (succ u3)} (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ)) (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ)) (Equiv.symm.{max (succ (max u1 u2)) (succ u3), max (succ u1) (succ (max u2 u3))} (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ) (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ)) (Equiv.prodAssoc.{u1, u2, u3} α β γ))) (Set.prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ (Set.prod.{u1, u2} α β s t) u)) (Set.prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ) s (Set.prod.{u2, u3} β γ t u))
but is expected to have type
  forall {α : Type.{u3}} {β : Type.{u2}} {γ : Type.{u1}} {s : Set.{u3} α} {t : Set.{u2} β} {u : Set.{u1} γ}, Eq.{max (max (succ u3) (succ u2)) (succ u1)} (Set.{max (max u3 u2) u1} (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ))) (Set.preimage.{max (max u3 u2) u1, max (max u3 u2) u1} (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) (FunLike.coe.{max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1)} (Equiv.{max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1)} (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ)) (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) (fun (_x : Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) => Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) _x) (Equiv.instFunLikeEquiv.{max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1)} (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ)) (Equiv.symm.{max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1)} (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) (Equiv.prodAssoc.{u3, u2, u1} α β γ))) (Set.prod.{max u3 u2, u1} (Prod.{u3, u2} α β) γ (Set.prod.{u3, u2} α β s t) u)) (Set.prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ) s (Set.prod.{u2, u1} β γ t u))
Case conversion may be inaccurate. Consider using '#align equiv.prod_assoc_symm_preimage Equiv.prod_assoc_symm_preimageₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simp]
theorem prod_assoc_symm_preimage {α β γ} {s : Set α} {t : Set β} {u : Set γ} :
    (Equiv.prodAssoc α β γ).symm ⁻¹' (s ×ˢ t) ×ˢ u = s ×ˢ t ×ˢ u :=
  by
  ext
  simp [and_assoc']
#align equiv.prod_assoc_symm_preimage Equiv.prod_assoc_symm_preimage

/- warning: equiv.prod_assoc_image -> Equiv.prod_assoc_image is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} {s : Set.{u1} α} {t : Set.{u2} β} {u : Set.{u3} γ}, Eq.{succ (max u1 u2 u3)} (Set.{max u1 u2 u3} (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ))) (Set.image.{max (max u1 u2) u3, max u1 u2 u3} (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ) (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ)) (coeFn.{max 1 (max (max (succ (max u1 u2)) (succ u3)) (succ u1) (succ (max u2 u3))) (max (succ u1) (succ (max u2 u3))) (succ (max u1 u2)) (succ u3), max (max (succ (max u1 u2)) (succ u3)) (succ u1) (succ (max u2 u3))} (Equiv.{max (succ (max u1 u2)) (succ u3), max (succ u1) (succ (max u2 u3))} (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ) (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ))) (fun (_x : Equiv.{max (succ (max u1 u2)) (succ u3), max (succ u1) (succ (max u2 u3))} (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ) (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ))) => (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ) -> (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ))) (Equiv.hasCoeToFun.{max (succ (max u1 u2)) (succ u3), max (succ u1) (succ (max u2 u3))} (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ) (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ))) (Equiv.prodAssoc.{u1, u2, u3} α β γ)) (Set.prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ (Set.prod.{u1, u2} α β s t) u)) (Set.prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ) s (Set.prod.{u2, u3} β γ t u))
but is expected to have type
  forall {α : Type.{u3}} {β : Type.{u2}} {γ : Type.{u1}} {s : Set.{u3} α} {t : Set.{u2} β} {u : Set.{u1} γ}, Eq.{max (max (succ u3) (succ u2)) (succ u1)} (Set.{max (max u3 u2) u1} (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ))) (Set.image.{max (max u3 u2) u1, max (max u3 u2) u1} (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) (FunLike.coe.{max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1)} (Equiv.{max (succ u1) (succ (max u2 u3)), max (succ (max u1 u2)) (succ u3)} (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ))) (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) (fun (_x : Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) => Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) _x) (Equiv.instFunLikeEquiv.{max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1)} (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ))) (Equiv.prodAssoc.{u3, u2, u1} α β γ)) (Set.prod.{max u3 u2, u1} (Prod.{u3, u2} α β) γ (Set.prod.{u3, u2} α β s t) u)) (Set.prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ) s (Set.prod.{u2, u1} β γ t u))
Case conversion may be inaccurate. Consider using '#align equiv.prod_assoc_image Equiv.prod_assoc_imageₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
-- `@[simp]` doesn't like these lemmas, as it uses `set.image_congr'` to turn `equiv.prod_assoc`
-- into a lambda expression and then unfold it.
theorem prod_assoc_image {α β γ} {s : Set α} {t : Set β} {u : Set γ} :
    Equiv.prodAssoc α β γ '' (s ×ˢ t) ×ˢ u = s ×ˢ t ×ˢ u := by
  simpa only [Equiv.image_eq_preimage] using prod_assoc_symm_preimage
#align equiv.prod_assoc_image Equiv.prod_assoc_image

/- warning: equiv.prod_assoc_symm_image -> Equiv.prod_assoc_symm_image is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} {s : Set.{u1} α} {t : Set.{u2} β} {u : Set.{u3} γ}, Eq.{succ (max (max u1 u2) u3)} (Set.{max (max u1 u2) u3} (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ)) (Set.image.{max u1 u2 u3, max (max u1 u2) u3} (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ)) (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ) (coeFn.{max 1 (max (max (succ u1) (succ (max u2 u3))) (succ (max u1 u2)) (succ u3)) (max (succ (max u1 u2)) (succ u3)) (succ u1) (succ (max u2 u3)), max (max (succ u1) (succ (max u2 u3))) (succ (max u1 u2)) (succ u3)} (Equiv.{max (succ u1) (succ (max u2 u3)), max (succ (max u1 u2)) (succ u3)} (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ)) (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ)) (fun (_x : Equiv.{max (succ u1) (succ (max u2 u3)), max (succ (max u1 u2)) (succ u3)} (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ)) (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ)) => (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ)) -> (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ)) (Equiv.hasCoeToFun.{max (succ u1) (succ (max u2 u3)), max (succ (max u1 u2)) (succ u3)} (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ)) (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ)) (Equiv.symm.{max (succ (max u1 u2)) (succ u3), max (succ u1) (succ (max u2 u3))} (Prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ) (Prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ)) (Equiv.prodAssoc.{u1, u2, u3} α β γ))) (Set.prod.{u1, max u2 u3} α (Prod.{u2, u3} β γ) s (Set.prod.{u2, u3} β γ t u))) (Set.prod.{max u1 u2, u3} (Prod.{u1, u2} α β) γ (Set.prod.{u1, u2} α β s t) u)
but is expected to have type
  forall {α : Type.{u3}} {β : Type.{u2}} {γ : Type.{u1}} {s : Set.{u3} α} {t : Set.{u2} β} {u : Set.{u1} γ}, Eq.{max (max (succ u3) (succ u2)) (succ u1)} (Set.{max (max u3 u2) u1} (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ)) (Set.image.{max (max u3 u2) u1, max (max u3 u2) u1} (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) (FunLike.coe.{max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1)} (Equiv.{max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1)} (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ)) (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) (fun (_x : Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) => Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) _x) (Equiv.instFunLikeEquiv.{max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1)} (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ)) (Equiv.symm.{max (max (succ u3) (succ u2)) (succ u1), max (max (succ u3) (succ u2)) (succ u1)} (Prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ) (Prod.{u3, max u1 u2} α (Prod.{u2, u1} β γ)) (Equiv.prodAssoc.{u3, u2, u1} α β γ))) (Set.prod.{u3, max u2 u1} α (Prod.{u2, u1} β γ) s (Set.prod.{u2, u1} β γ t u))) (Set.prod.{max u2 u3, u1} (Prod.{u3, u2} α β) γ (Set.prod.{u3, u2} α β s t) u)
Case conversion may be inaccurate. Consider using '#align equiv.prod_assoc_symm_image Equiv.prod_assoc_symm_imageₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem prod_assoc_symm_image {α β γ} {s : Set α} {t : Set β} {u : Set γ} :
    (Equiv.prodAssoc α β γ).symm '' s ×ˢ t ×ˢ u = (s ×ˢ t) ×ˢ u := by
  simpa only [Equiv.image_eq_preimage] using prod_assoc_preimage
#align equiv.prod_assoc_symm_image Equiv.prod_assoc_symm_image

#print Equiv.setProdEquivSigma /-
/-- A set `s` in `α × β` is equivalent to the sigma-type `Σ x, {y | (x, y) ∈ s}`. -/
def setProdEquivSigma {α β : Type _} (s : Set (α × β)) : s ≃ Σx : α, { y | (x, y) ∈ s }
    where
  toFun x := ⟨x.1.1, x.1.2, by simp⟩
  invFun x := ⟨(x.1, x.2.1), x.2.2⟩
  left_inv := fun ⟨⟨x, y⟩, h⟩ => rfl
  right_inv := fun ⟨x, y, h⟩ => rfl
#align equiv.set_prod_equiv_sigma Equiv.setProdEquivSigma
-/

#print Equiv.setCongr /-
/-- The subtypes corresponding to equal sets are equivalent. -/
@[simps apply]
def setCongr {α : Type _} {s t : Set α} (h : s = t) : s ≃ t :=
  subtypeEquivProp h
#align equiv.set_congr Equiv.setCongr
-/

#print Equiv.image /-
-- We could construct this using `equiv.set.image e s e.injective`,
-- but this definition provides an explicit inverse.
/-- A set is equivalent to its image under an equivalence.
-/
@[simps]
def image {α β : Type _} (e : α ≃ β) (s : Set α) : s ≃ e '' s
    where
  toFun x := ⟨e x.1, by simp⟩
  invFun y :=
    ⟨e.symm y.1, by
      rcases y with ⟨-, ⟨a, ⟨m, rfl⟩⟩⟩
      simpa using m⟩
  left_inv x := by simp
  right_inv y := by simp
#align equiv.image Equiv.image
-/

namespace Set

#print Equiv.Set.univ /-
/-- `univ α` is equivalent to `α`. -/
@[simps apply symm_apply]
protected def univ (α) : @univ α ≃ α :=
  ⟨coe, fun a => ⟨a, trivial⟩, fun ⟨a, _⟩ => rfl, fun a => rfl⟩
#align equiv.set.univ Equiv.Set.univ
-/

#print Equiv.Set.empty /-
/-- An empty set is equivalent to the `empty` type. -/
protected def empty (α) : (∅ : Set α) ≃ Empty :=
  equivEmpty _
#align equiv.set.empty Equiv.Set.empty
-/

#print Equiv.Set.pempty /-
/-- An empty set is equivalent to a `pempty` type. -/
protected def pempty (α) : (∅ : Set α) ≃ PEmpty :=
  equivPEmpty _
#align equiv.set.pempty Equiv.Set.pempty
-/

/- warning: equiv.set.union' -> Equiv.Set.union' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} (p : α -> Prop) [_inst_1 : DecidablePred.{succ u1} α p], (forall (x : α), (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) -> (p x)) -> (forall (x : α), (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x t) -> (Not (p x))) -> (Equiv.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)))
but is expected to have type
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} (p : α -> Prop) [_inst_1 : DecidablePred.{succ u1} α p], (forall (x : α), (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) -> (p x)) -> (forall (x : α), (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x t) -> (Not (p x))) -> (Equiv.{succ u1, succ u1} (Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)))
Case conversion may be inaccurate. Consider using '#align equiv.set.union' Equiv.Set.union'ₓ'. -/
/-- If sets `s` and `t` are separated by a decidable predicate, then `s ∪ t` is equivalent to
`s ⊕ t`. -/
protected def union' {α} {s t : Set α} (p : α → Prop) [DecidablePred p] (hs : ∀ x ∈ s, p x)
    (ht : ∀ x ∈ t, ¬p x) : (s ∪ t : Set α) ≃ Sum s t
    where
  toFun x :=
    if hp : p x then Sum.inl ⟨_, x.2.resolve_right fun xt => ht _ xt hp⟩
    else Sum.inr ⟨_, x.2.resolve_left fun xs => hp (hs _ xs)⟩
  invFun o :=
    match o with
    | Sum.inl x => ⟨x, Or.inl x.2⟩
    | Sum.inr x => ⟨x, Or.inr x.2⟩
  left_inv := fun ⟨x, h'⟩ => by by_cases p x <;> simp [union'._match_1, h] <;> congr
  right_inv o := by
    rcases o with (⟨x, h⟩ | ⟨x, h⟩) <;> dsimp [union'._match_1] <;> [simp [hs _ h], simp [ht _ h]]
#align equiv.set.union' Equiv.Set.union'

/- warning: equiv.set.union -> Equiv.Set.union is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s)], (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) (Inter.inter.{u1} (Set.{u1} α) (Set.hasInter.{u1} α) s t) (EmptyCollection.emptyCollection.{u1} (Set.{u1} α) (Set.hasEmptyc.{u1} α))) -> (Equiv.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)))
but is expected to have type
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s)], (HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) (Inter.inter.{u1} (Set.{u1} α) (Set.instInterSet.{u1} α) s t) (EmptyCollection.emptyCollection.{u1} (Set.{u1} α) (Set.instEmptyCollectionSet.{u1} α))) -> (Equiv.{succ u1, succ u1} (Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)))
Case conversion may be inaccurate. Consider using '#align equiv.set.union Equiv.Set.unionₓ'. -/
/-- If sets `s` and `t` are disjoint, then `s ∪ t` is equivalent to `s ⊕ t`. -/
protected def union {α} {s t : Set α} [DecidablePred fun x => x ∈ s] (H : s ∩ t ⊆ ∅) :
    (s ∪ t : Set α) ≃ Sum s t :=
  Set.union' (fun x => x ∈ s) (fun _ => id) fun x xt xs => H ⟨xs, xt⟩
#align equiv.set.union Equiv.Set.union

/- warning: equiv.set.union_apply_left -> Equiv.Set.union_apply_left is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s)] (H : HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) (Inter.inter.{u1} (Set.{u1} α) (Set.hasInter.{u1} α) s t) (EmptyCollection.emptyCollection.{u1} (Set.{u1} α) (Set.hasEmptyc.{u1} α))) {a : coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)} (ha : Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)))))) a) s), Eq.{succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) (coeFn.{succ u1, succ u1} (Equiv.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t))) (fun (_x : Equiv.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t))) => (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) -> (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t))) (Equiv.hasCoeToFun.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t))) (Equiv.Set.union.{u1} α s t (fun (a : α) => _inst_1 a) H) a) (Sum.inl.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)))))) a) ha))
but is expected to have type
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s)] (H : HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) (Inter.inter.{u1} (Set.{u1} α) (Set.instInterSet.{u1} α) s t) (EmptyCollection.emptyCollection.{u1} (Set.{u1} α) (Set.instEmptyCollectionSet.{u1} α))) {a : Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)} (ha : Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) a) s), Eq.{succ u1} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) a) (FunLike.coe.{succ u1, succ u1, succ u1} (Equiv.{succ u1, succ u1} (Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t))) (Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (fun (_x : Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u1} (Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t))) (Equiv.Set.union.{u1} α s t (fun (a : α) => _inst_1 a) H) a) (Sum.inl.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) a) ha))
Case conversion may be inaccurate. Consider using '#align equiv.set.union_apply_left Equiv.Set.union_apply_leftₓ'. -/
theorem union_apply_left {α} {s t : Set α} [DecidablePred fun x => x ∈ s] (H : s ∩ t ⊆ ∅)
    {a : (s ∪ t : Set α)} (ha : ↑a ∈ s) : Equiv.Set.union H a = Sum.inl ⟨a, ha⟩ :=
  dif_pos ha
#align equiv.set.union_apply_left Equiv.Set.union_apply_left

/- warning: equiv.set.union_apply_right -> Equiv.Set.union_apply_right is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s)] (H : HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) (Inter.inter.{u1} (Set.{u1} α) (Set.hasInter.{u1} α) s t) (EmptyCollection.emptyCollection.{u1} (Set.{u1} α) (Set.hasEmptyc.{u1} α))) {a : coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)} (ha : Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)))))) a) t), Eq.{succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) (coeFn.{succ u1, succ u1} (Equiv.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t))) (fun (_x : Equiv.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t))) => (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) -> (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t))) (Equiv.hasCoeToFun.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t))) (Equiv.Set.union.{u1} α s t (fun (a : α) => _inst_1 a) H) a) (Sum.inr.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x t) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)))))) a) ha))
but is expected to have type
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s)] (H : HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) (Inter.inter.{u1} (Set.{u1} α) (Set.instInterSet.{u1} α) s t) (EmptyCollection.emptyCollection.{u1} (Set.{u1} α) (Set.instEmptyCollectionSet.{u1} α))) {a : Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)} (ha : Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) a) t), Eq.{succ u1} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) a) (FunLike.coe.{succ u1, succ u1, succ u1} (Equiv.{succ u1, succ u1} (Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t))) (Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (fun (_x : Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u1} (Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t))) (Equiv.Set.union.{u1} α s t (fun (a : α) => _inst_1 a) H) a) (Sum.inr.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x t) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) a) ha))
Case conversion may be inaccurate. Consider using '#align equiv.set.union_apply_right Equiv.Set.union_apply_rightₓ'. -/
theorem union_apply_right {α} {s t : Set α} [DecidablePred fun x => x ∈ s] (H : s ∩ t ⊆ ∅)
    {a : (s ∪ t : Set α)} (ha : ↑a ∈ t) : Equiv.Set.union H a = Sum.inr ⟨a, ha⟩ :=
  dif_neg fun h => H ⟨h, ha⟩
#align equiv.set.union_apply_right Equiv.Set.union_apply_right

/- warning: equiv.set.union_symm_apply_left -> Equiv.Set.union_symm_apply_left is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s)] (H : HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) (Inter.inter.{u1} (Set.{u1} α) (Set.hasInter.{u1} α) s t) (EmptyCollection.emptyCollection.{u1} (Set.{u1} α) (Set.hasEmptyc.{u1} α))) (a : coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s), Eq.{succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) (coeFn.{succ u1, succ u1} (Equiv.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t))) (fun (_x : Equiv.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t))) => (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) -> (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t))) (Equiv.hasCoeToFun.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t))) (Equiv.symm.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) (Equiv.Set.union.{u1} α s t (fun (a : α) => _inst_1 a) H)) (Sum.inl.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) a)) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s))))) a) (Set.subset_union_left.{u1} α s t ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s))))) a) (Subtype.property.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) a)))
but is expected to have type
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s)] (H : HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) (Inter.inter.{u1} (Set.{u1} α) (Set.instInterSet.{u1} α) s t) (EmptyCollection.emptyCollection.{u1} (Set.{u1} α) (Set.instEmptyCollectionSet.{u1} α))) (a : Set.Elem.{u1} α s), Eq.{succ u1} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) => Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (Sum.inl.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t) a)) (FunLike.coe.{succ u1, succ u1, succ u1} (Equiv.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) (Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t))) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) (fun (_x : Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) => Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) (Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t))) (Equiv.symm.{succ u1, succ u1} (Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) (Equiv.Set.union.{u1} α s t (fun (a : α) => _inst_1 a) H)) (Sum.inl.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t) a)) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) a) (Set.subset_union_left.{u1} α s t (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) a) (Subtype.property.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) a)))
Case conversion may be inaccurate. Consider using '#align equiv.set.union_symm_apply_left Equiv.Set.union_symm_apply_leftₓ'. -/
@[simp]
theorem union_symm_apply_left {α} {s t : Set α} [DecidablePred fun x => x ∈ s] (H : s ∩ t ⊆ ∅)
    (a : s) : (Equiv.Set.union H).symm (Sum.inl a) = ⟨a, subset_union_left _ _ a.2⟩ :=
  rfl
#align equiv.set.union_symm_apply_left Equiv.Set.union_symm_apply_left

/- warning: equiv.set.union_symm_apply_right -> Equiv.Set.union_symm_apply_right is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s)] (H : HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) (Inter.inter.{u1} (Set.{u1} α) (Set.hasInter.{u1} α) s t) (EmptyCollection.emptyCollection.{u1} (Set.{u1} α) (Set.hasEmptyc.{u1} α))) (a : coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t), Eq.{succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) (coeFn.{succ u1, succ u1} (Equiv.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t))) (fun (_x : Equiv.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t))) => (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) -> (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t))) (Equiv.hasCoeToFun.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t))) (Equiv.symm.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) (Equiv.Set.union.{u1} α s t (fun (a : α) => _inst_1 a) H)) (Sum.inr.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) a)) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x t))))) a) (Set.subset_union_right.{u1} α s t ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x t))))) a) (Subtype.property.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x t) a)))
but is expected to have type
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s)] (H : HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) (Inter.inter.{u1} (Set.{u1} α) (Set.instInterSet.{u1} α) s t) (EmptyCollection.emptyCollection.{u1} (Set.{u1} α) (Set.instEmptyCollectionSet.{u1} α))) (a : Set.Elem.{u1} α t), Eq.{succ u1} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) => Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (Sum.inr.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t) a)) (FunLike.coe.{succ u1, succ u1, succ u1} (Equiv.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) (Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t))) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) (fun (_x : Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) => Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) (Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t))) (Equiv.symm.{succ u1, succ u1} (Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t)) (Equiv.Set.union.{u1} α s t (fun (a : α) => _inst_1 a) H)) (Sum.inr.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t) a)) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x t) a) (Set.subset_union_right.{u1} α s t (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x t) a) (Subtype.property.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x t) a)))
Case conversion may be inaccurate. Consider using '#align equiv.set.union_symm_apply_right Equiv.Set.union_symm_apply_rightₓ'. -/
@[simp]
theorem union_symm_apply_right {α} {s t : Set α} [DecidablePred fun x => x ∈ s] (H : s ∩ t ⊆ ∅)
    (a : t) : (Equiv.Set.union H).symm (Sum.inr a) = ⟨a, subset_union_right _ _ a.2⟩ :=
  rfl
#align equiv.set.union_symm_apply_right Equiv.Set.union_symm_apply_right

#print Equiv.Set.singleton /-
/-- A singleton set is equivalent to a `punit` type. -/
protected def singleton {α} (a : α) : ({a} : Set α) ≃ PUnit.{u} :=
  ⟨fun _ => PUnit.unit, fun _ => ⟨a, mem_singleton _⟩, fun ⟨x, h⟩ =>
    by
    simp at h
    subst x, fun ⟨⟩ => rfl⟩
#align equiv.set.singleton Equiv.Set.singleton
-/

#print Equiv.Set.ofEq /-
/-- Equal sets are equivalent.

TODO: this is the same as `equiv.set_congr`! -/
@[simps apply symm_apply]
protected def ofEq {α : Type u} {s t : Set α} (h : s = t) : s ≃ t :=
  Equiv.setCongr h
#align equiv.set.of_eq Equiv.Set.ofEq
-/

#print Equiv.Set.insert /-
/-- If `a ∉ s`, then `insert a s` is equivalent to `s ⊕ punit`. -/
protected def insert {α} {s : Set.{u} α} [DecidablePred (· ∈ s)] {a : α} (H : a ∉ s) :
    (insert a s : Set α) ≃ Sum s PUnit.{u + 1} :=
  calc
    (insert a s : Set α) ≃ ↥(s ∪ {a}) := Equiv.Set.ofEq (by simp)
    _ ≃ Sum s ({a} : Set α) := (Equiv.Set.union fun x ⟨hx, hx'⟩ => by simp_all)
    _ ≃ Sum s PUnit.{u + 1} := sumCongr (Equiv.refl _) (Equiv.Set.singleton _)
    
#align equiv.set.insert Equiv.Set.insert
-/

#print Equiv.Set.insert_symm_apply_inl /-
@[simp]
theorem insert_symm_apply_inl {α} {s : Set.{u} α} [DecidablePred (· ∈ s)] {a : α} (H : a ∉ s)
    (b : s) : (Equiv.Set.insert H).symm (Sum.inl b) = ⟨b, Or.inr b.2⟩ :=
  rfl
#align equiv.set.insert_symm_apply_inl Equiv.Set.insert_symm_apply_inl
-/

#print Equiv.Set.insert_symm_apply_inr /-
@[simp]
theorem insert_symm_apply_inr {α} {s : Set.{u} α} [DecidablePred (· ∈ s)] {a : α} (H : a ∉ s)
    (b : PUnit.{u + 1}) : (Equiv.Set.insert H).symm (Sum.inr b) = ⟨a, Or.inl rfl⟩ :=
  rfl
#align equiv.set.insert_symm_apply_inr Equiv.Set.insert_symm_apply_inr
-/

#print Equiv.Set.insert_apply_left /-
@[simp]
theorem insert_apply_left {α} {s : Set.{u} α} [DecidablePred (· ∈ s)] {a : α} (H : a ∉ s) :
    Equiv.Set.insert H ⟨a, Or.inl rfl⟩ = Sum.inr PUnit.unit :=
  (Equiv.Set.insert H).apply_eq_iff_eq_symm_apply.2 rfl
#align equiv.set.insert_apply_left Equiv.Set.insert_apply_left
-/

#print Equiv.Set.insert_apply_right /-
@[simp]
theorem insert_apply_right {α} {s : Set.{u} α} [DecidablePred (· ∈ s)] {a : α} (H : a ∉ s) (b : s) :
    Equiv.Set.insert H ⟨b, Or.inr b.2⟩ = Sum.inl b :=
  (Equiv.Set.insert H).apply_eq_iff_eq_symm_apply.2 rfl
#align equiv.set.insert_apply_right Equiv.Set.insert_apply_right
-/

/- warning: equiv.set.sum_compl -> Equiv.Set.sumCompl is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} (s : Set.{u1} α) [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x s)], Equiv.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s))) α
but is expected to have type
  forall {α : Type.{u1}} (s : Set.{u1} α) [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x s)], Equiv.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) α
Case conversion may be inaccurate. Consider using '#align equiv.set.sum_compl Equiv.Set.sumComplₓ'. -/
/-- If `s : set α` is a set with decidable membership, then `s ⊕ sᶜ` is equivalent to `α`. -/
protected def sumCompl {α} (s : Set α) [DecidablePred (· ∈ s)] : Sum s (sᶜ : Set α) ≃ α :=
  calc
    Sum s (sᶜ : Set α) ≃ ↥(s ∪ sᶜ) := (Equiv.Set.union (by simp [Set.ext_iff])).symm
    _ ≃ @univ α := (Equiv.Set.ofEq (by simp))
    _ ≃ α := Equiv.Set.univ _
    
#align equiv.set.sum_compl Equiv.Set.sumCompl

#print Equiv.Set.sumCompl_apply_inl /-
@[simp]
theorem sumCompl_apply_inl {α : Type u} (s : Set α) [DecidablePred (· ∈ s)] (x : s) :
    Equiv.Set.sumCompl s (Sum.inl x) = x :=
  rfl
#align equiv.set.sum_compl_apply_inl Equiv.Set.sumCompl_apply_inl
-/

/- warning: equiv.set.sum_compl_apply_inr -> Equiv.Set.sumCompl_apply_inr is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} (s : Set.{u1} α) [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x s)] (x : coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)), Eq.{succ u1} α (coeFn.{succ u1, succ u1} (Equiv.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s))) α) (fun (_x : Equiv.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s))) α) => (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s))) -> α) (Equiv.hasCoeToFun.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s))) α) (Equiv.Set.sumCompl.{u1} α s (fun (a : α) => _inst_1 a)) (Sum.inr.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)) x)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))))) x)
but is expected to have type
  forall {α : Type.{u1}} (s : Set.{u1} α) [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x s)] (x : Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)), Eq.{succ u1} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) => α) (Sum.inr.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)) x)) (FunLike.coe.{succ u1, succ u1, succ u1} (Equiv.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) α) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) (fun (_x : Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) α) (Equiv.Set.sumCompl.{u1} α s (fun (a : α) => _inst_1 a)) (Sum.inr.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)) x)) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)) x)
Case conversion may be inaccurate. Consider using '#align equiv.set.sum_compl_apply_inr Equiv.Set.sumCompl_apply_inrₓ'. -/
@[simp]
theorem sumCompl_apply_inr {α : Type u} (s : Set α) [DecidablePred (· ∈ s)] (x : sᶜ) :
    Equiv.Set.sumCompl s (Sum.inr x) = x :=
  rfl
#align equiv.set.sum_compl_apply_inr Equiv.Set.sumCompl_apply_inr

/- warning: equiv.set.sum_compl_symm_apply_of_mem -> Equiv.Set.sumCompl_symm_apply_of_mem is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {s : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x s)] {x : α} (hx : Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s), Eq.{succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s))) (coeFn.{succ u1, succ u1} (Equiv.{succ u1, succ u1} α (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) (fun (_x : Equiv.{succ u1, succ u1} α (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) => α -> (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) (Equiv.hasCoeToFun.{succ u1, succ u1} α (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) (Equiv.symm.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s))) α (Equiv.Set.sumCompl.{u1} α s (fun (a : α) => _inst_1 a))) x) (Sum.inl.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) x hx))
but is expected to have type
  forall {α : Type.{u1}} {s : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x s)] {x : α} (hx : Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s), Eq.{succ u1} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) x) (FunLike.coe.{succ u1, succ u1, succ u1} (Equiv.{succ u1, succ u1} α (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)))) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u1} α (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)))) (Equiv.symm.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) α (Equiv.Set.sumCompl.{u1} α s (fun (a : α) => _inst_1 a))) x) (Sum.inl.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) x hx))
Case conversion may be inaccurate. Consider using '#align equiv.set.sum_compl_symm_apply_of_mem Equiv.Set.sumCompl_symm_apply_of_memₓ'. -/
theorem sumCompl_symm_apply_of_mem {α : Type u} {s : Set α} [DecidablePred (· ∈ s)] {x : α}
    (hx : x ∈ s) : (Equiv.Set.sumCompl s).symm x = Sum.inl ⟨x, hx⟩ :=
  by
  have : ↑(⟨x, Or.inl hx⟩ : (s ∪ sᶜ : Set α)) ∈ s := hx
  rw [Equiv.Set.sumCompl]
  simpa using set.union_apply_left _ this
#align equiv.set.sum_compl_symm_apply_of_mem Equiv.Set.sumCompl_symm_apply_of_mem

/- warning: equiv.set.sum_compl_symm_apply_of_not_mem -> Equiv.Set.sumCompl_symm_apply_of_not_mem is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {s : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x s)] {x : α} (hx : Not (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s)), Eq.{succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s))) (coeFn.{succ u1, succ u1} (Equiv.{succ u1, succ u1} α (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) (fun (_x : Equiv.{succ u1, succ u1} α (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) => α -> (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) (Equiv.hasCoeToFun.{succ u1, succ u1} α (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) (Equiv.symm.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s))) α (Equiv.Set.sumCompl.{u1} α s (fun (a : α) => _inst_1 a))) x) (Sum.inr.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)) x hx))
but is expected to have type
  forall {α : Type.{u1}} {s : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x s)] {x : α} (hx : Not (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s)), Eq.{succ u1} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) x) (FunLike.coe.{succ u1, succ u1, succ u1} (Equiv.{succ u1, succ u1} α (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)))) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u1} α (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)))) (Equiv.symm.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) α (Equiv.Set.sumCompl.{u1} α s (fun (a : α) => _inst_1 a))) x) (Sum.inr.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)) x hx))
Case conversion may be inaccurate. Consider using '#align equiv.set.sum_compl_symm_apply_of_not_mem Equiv.Set.sumCompl_symm_apply_of_not_memₓ'. -/
theorem sumCompl_symm_apply_of_not_mem {α : Type u} {s : Set α} [DecidablePred (· ∈ s)] {x : α}
    (hx : x ∉ s) : (Equiv.Set.sumCompl s).symm x = Sum.inr ⟨x, hx⟩ :=
  by
  have : ↑(⟨x, Or.inr hx⟩ : (s ∪ sᶜ : Set α)) ∈ sᶜ := hx
  rw [Equiv.Set.sumCompl]
  simpa using set.union_apply_right _ this
#align equiv.set.sum_compl_symm_apply_of_not_mem Equiv.Set.sumCompl_symm_apply_of_not_mem

/- warning: equiv.set.sum_compl_symm_apply -> Equiv.Set.sumCompl_symm_apply is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {s : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x s)] {x : coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s}, Eq.{succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s))) (coeFn.{succ u1, succ u1} (Equiv.{succ u1, succ u1} α (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) (fun (_x : Equiv.{succ u1, succ u1} α (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) => α -> (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) (Equiv.hasCoeToFun.{succ u1, succ u1} α (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) (Equiv.symm.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s))) α (Equiv.Set.sumCompl.{u1} α s (fun (a : α) => _inst_1 a))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s))))) x)) (Sum.inl.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)) x)
but is expected to have type
  forall {α : Type.{u1}} {s : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x s)] {x : Set.Elem.{u1} α s}, Eq.{succ u1} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) x)) (FunLike.coe.{succ u1, succ u1, succ u1} (Equiv.{succ u1, succ u1} α (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)))) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u1} α (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)))) (Equiv.symm.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) α (Equiv.Set.sumCompl.{u1} α s (fun (a : α) => _inst_1 a))) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) x)) (Sum.inl.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)) x)
Case conversion may be inaccurate. Consider using '#align equiv.set.sum_compl_symm_apply Equiv.Set.sumCompl_symm_applyₓ'. -/
@[simp]
theorem sumCompl_symm_apply {α : Type _} {s : Set α} [DecidablePred (· ∈ s)] {x : s} :
    (Equiv.Set.sumCompl s).symm x = Sum.inl x := by
  cases' x with x hx <;> exact set.sum_compl_symm_apply_of_mem hx
#align equiv.set.sum_compl_symm_apply Equiv.Set.sumCompl_symm_apply

/- warning: equiv.set.sum_compl_symm_apply_compl -> Equiv.Set.sumCompl_symm_apply_compl is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {s : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x s)] {x : coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)}, Eq.{succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s))) (coeFn.{succ u1, succ u1} (Equiv.{succ u1, succ u1} α (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) (fun (_x : Equiv.{succ u1, succ u1} α (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) => α -> (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) (Equiv.hasCoeToFun.{succ u1, succ u1} α (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))) (Equiv.symm.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s))) α (Equiv.Set.sumCompl.{u1} α s (fun (a : α) => _inst_1 a))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)))))) x)) (Sum.inr.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) s)) x)
but is expected to have type
  forall {α : Type.{u1}} {s : Set.{u1} α} [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x s)] {x : Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)}, Eq.{succ u1} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)) x)) (FunLike.coe.{succ u1, succ u1, succ u1} (Equiv.{succ u1, succ u1} α (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)))) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u1} α (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)))) (Equiv.symm.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s))) α (Equiv.Set.sumCompl.{u1} α s (fun (a : α) => _inst_1 a))) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)) x)) (Sum.inr.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (HasCompl.compl.{u1} (Set.{u1} α) (BooleanAlgebra.toHasCompl.{u1} (Set.{u1} α) (Set.instBooleanAlgebraSet.{u1} α)) s)) x)
Case conversion may be inaccurate. Consider using '#align equiv.set.sum_compl_symm_apply_compl Equiv.Set.sumCompl_symm_apply_complₓ'. -/
@[simp]
theorem sumCompl_symm_apply_compl {α : Type _} {s : Set α} [DecidablePred (· ∈ s)] {x : sᶜ} :
    (Equiv.Set.sumCompl s).symm x = Sum.inr x := by
  cases' x with x hx <;> exact set.sum_compl_symm_apply_of_not_mem hx
#align equiv.set.sum_compl_symm_apply_compl Equiv.Set.sumCompl_symm_apply_compl

/- warning: equiv.set.sum_diff_subset -> Equiv.Set.sumDiffSubset is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α}, (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) s t) -> (forall [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x s)], Equiv.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s))) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t))
but is expected to have type
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α}, (HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) s t) -> (forall [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x s)], Equiv.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s))) (Set.Elem.{u1} α t))
Case conversion may be inaccurate. Consider using '#align equiv.set.sum_diff_subset Equiv.Set.sumDiffSubsetₓ'. -/
/-- `sum_diff_subset s t` is the natural equivalence between
`s ⊕ (t \ s)` and `t`, where `s` and `t` are two sets. -/
protected def sumDiffSubset {α} {s t : Set α} (h : s ⊆ t) [DecidablePred (· ∈ s)] :
    Sum s (t \ s : Set α) ≃ t :=
  calc
    Sum s (t \ s : Set α) ≃ (s ∪ t \ s : Set α) :=
      (Equiv.Set.union (by simp [inter_diff_self])).symm
    _ ≃ t := Equiv.Set.ofEq (by simp [union_diff_self, union_eq_self_of_subset_left h])
    
#align equiv.set.sum_diff_subset Equiv.Set.sumDiffSubset

#print Equiv.Set.sumDiffSubset_apply_inl /-
@[simp]
theorem sumDiffSubset_apply_inl {α} {s t : Set α} (h : s ⊆ t) [DecidablePred (· ∈ s)] (x : s) :
    Equiv.Set.sumDiffSubset h (Sum.inl x) = inclusion h x :=
  rfl
#align equiv.set.sum_diff_subset_apply_inl Equiv.Set.sumDiffSubset_apply_inl
-/

/- warning: equiv.set.sum_diff_subset_apply_inr -> Equiv.Set.sumDiffSubset_apply_inr is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} (h : HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) s t) [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x s)] (x : coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s)), Eq.{succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) (coeFn.{succ u1, succ u1} (Equiv.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s))) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) (fun (_x : Equiv.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s))) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) => (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s))) -> (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) (Equiv.hasCoeToFun.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s))) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t)) (Equiv.Set.sumDiffSubset.{u1} α s t h (fun (a : α) => _inst_1 a)) (Sum.inr.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s)) x)) (Set.inclusion.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s) t (Set.diff_subset.{u1} α t s) x)
but is expected to have type
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} (h : HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) s t) [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x s)] (x : Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s)), Eq.{succ u1} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s))) => Set.Elem.{u1} α t) (Sum.inr.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s)) x)) (FunLike.coe.{succ u1, succ u1, succ u1} (Equiv.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s))) (Set.Elem.{u1} α t)) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s))) (fun (_x : Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s))) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s))) => Set.Elem.{u1} α t) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s))) (Set.Elem.{u1} α t)) (Equiv.Set.sumDiffSubset.{u1} α s t h (fun (a : α) => _inst_1 a)) (Sum.inr.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s)) x)) (Set.inclusion.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s) t (Set.diff_subset.{u1} α t s) x)
Case conversion may be inaccurate. Consider using '#align equiv.set.sum_diff_subset_apply_inr Equiv.Set.sumDiffSubset_apply_inrₓ'. -/
@[simp]
theorem sumDiffSubset_apply_inr {α} {s t : Set α} (h : s ⊆ t) [DecidablePred (· ∈ s)] (x : t \ s) :
    Equiv.Set.sumDiffSubset h (Sum.inr x) = inclusion (diff_subset t s) x :=
  rfl
#align equiv.set.sum_diff_subset_apply_inr Equiv.Set.sumDiffSubset_apply_inr

/- warning: equiv.set.sum_diff_subset_symm_apply_of_mem -> Equiv.Set.sumDiffSubset_symm_apply_of_mem is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} (h : HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) s t) [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x s)] {x : coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t} (hx : Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) (Subtype.val.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x t) x) s), Eq.{succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s))) (coeFn.{succ u1, succ u1} (Equiv.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s)))) (fun (_x : Equiv.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s)))) => (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) -> (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s)))) (Equiv.hasCoeToFun.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s)))) (Equiv.symm.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s))) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) (Equiv.Set.sumDiffSubset.{u1} α s t h (fun (a : α) => _inst_1 a))) x) (Sum.inl.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s)) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x t))))) x) hx))
but is expected to have type
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} (h : HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) s t) [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x s)] {x : Set.Elem.{u1} α t} (hx : Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x t) x) s), Eq.{succ u1} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} α t) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s))) x) (FunLike.coe.{succ u1, succ u1, succ u1} (Equiv.{succ u1, succ u1} (Set.Elem.{u1} α t) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s)))) (Set.Elem.{u1} α t) (fun (_x : Set.Elem.{u1} α t) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} α t) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s))) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u1} (Set.Elem.{u1} α t) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s)))) (Equiv.symm.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s))) (Set.Elem.{u1} α t) (Equiv.Set.sumDiffSubset.{u1} α s t h (fun (a : α) => _inst_1 a))) x) (Sum.inl.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s)) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x t) x) hx))
Case conversion may be inaccurate. Consider using '#align equiv.set.sum_diff_subset_symm_apply_of_mem Equiv.Set.sumDiffSubset_symm_apply_of_memₓ'. -/
theorem sumDiffSubset_symm_apply_of_mem {α} {s t : Set α} (h : s ⊆ t) [DecidablePred (· ∈ s)]
    {x : t} (hx : x.1 ∈ s) : (Equiv.Set.sumDiffSubset h).symm x = Sum.inl ⟨x, hx⟩ :=
  by
  apply (Equiv.Set.sumDiffSubset h).Injective
  simp only [apply_symm_apply, sum_diff_subset_apply_inl]
  exact Subtype.eq rfl
#align equiv.set.sum_diff_subset_symm_apply_of_mem Equiv.Set.sumDiffSubset_symm_apply_of_mem

/- warning: equiv.set.sum_diff_subset_symm_apply_of_not_mem -> Equiv.Set.sumDiffSubset_symm_apply_of_not_mem is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} (h : HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) s t) [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x s)] {x : coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t} (hx : Not (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) (Subtype.val.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x t) x) s)), Eq.{succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s))) (coeFn.{succ u1, succ u1} (Equiv.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s)))) (fun (_x : Equiv.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s)))) => (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) -> (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s)))) (Equiv.hasCoeToFun.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s)))) (Equiv.symm.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s))) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) (Equiv.Set.sumDiffSubset.{u1} α s t h (fun (a : α) => _inst_1 a))) x) (Sum.inr.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s)) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x (SDiff.sdiff.{u1} (Set.{u1} α) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} α) (Set.booleanAlgebra.{u1} α)) t s)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x t))))) x) (And.intro (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x t))))) x) t) (Not (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x t))))) x) s)) (Subtype.property.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x t) x) hx)))
but is expected to have type
  forall {α : Type.{u1}} {s : Set.{u1} α} {t : Set.{u1} α} (h : HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) s t) [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x s)] {x : Set.Elem.{u1} α t} (hx : Not (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x t) x) s)), Eq.{succ u1} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} α t) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s))) x) (FunLike.coe.{succ u1, succ u1, succ u1} (Equiv.{succ u1, succ u1} (Set.Elem.{u1} α t) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s)))) (Set.Elem.{u1} α t) (fun (_x : Set.Elem.{u1} α t) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} α t) => Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s))) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u1} (Set.Elem.{u1} α t) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s)))) (Equiv.symm.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s))) (Set.Elem.{u1} α t) (Equiv.Set.sumDiffSubset.{u1} α s t h (fun (a : α) => _inst_1 a))) x) (Sum.inr.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s)) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (SDiff.sdiff.{u1} (Set.{u1} α) (Set.instSDiffSet.{u1} α) t s)) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x t) x) (And.intro (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x t) x) t) (Not (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) (Subtype.val.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x t) x) s)) (Subtype.property.{succ u1} α (fun (x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x t) x) hx)))
Case conversion may be inaccurate. Consider using '#align equiv.set.sum_diff_subset_symm_apply_of_not_mem Equiv.Set.sumDiffSubset_symm_apply_of_not_memₓ'. -/
theorem sumDiffSubset_symm_apply_of_not_mem {α} {s t : Set α} (h : s ⊆ t) [DecidablePred (· ∈ s)]
    {x : t} (hx : x.1 ∉ s) : (Equiv.Set.sumDiffSubset h).symm x = Sum.inr ⟨x, ⟨x.2, hx⟩⟩ :=
  by
  apply (Equiv.Set.sumDiffSubset h).Injective
  simp only [apply_symm_apply, sum_diff_subset_apply_inr]
  exact Subtype.eq rfl
#align equiv.set.sum_diff_subset_symm_apply_of_not_mem Equiv.Set.sumDiffSubset_symm_apply_of_not_mem

/- warning: equiv.set.union_sum_inter -> Equiv.Set.unionSumInter is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} (s : Set.{u1} α) (t : Set.{u1} α) [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) _x s)], Equiv.{succ u1, succ u1} (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Inter.inter.{u1} (Set.{u1} α) (Set.hasInter.{u1} α) s t))) (Sum.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) t))
but is expected to have type
  forall {α : Type.{u1}} (s : Set.{u1} α) (t : Set.{u1} α) [_inst_1 : DecidablePred.{succ u1} α (fun (_x : α) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) _x s)], Equiv.{succ u1, succ u1} (Sum.{u1, u1} (Set.Elem.{u1} α (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (Set.Elem.{u1} α (Inter.inter.{u1} (Set.{u1} α) (Set.instInterSet.{u1} α) s t))) (Sum.{u1, u1} (Set.Elem.{u1} α s) (Set.Elem.{u1} α t))
Case conversion may be inaccurate. Consider using '#align equiv.set.union_sum_inter Equiv.Set.unionSumInterₓ'. -/
/-- If `s` is a set with decidable membership, then the sum of `s ∪ t` and `s ∩ t` is equivalent
to `s ⊕ t`. -/
protected def unionSumInter {α : Type u} (s t : Set α) [DecidablePred (· ∈ s)] :
    Sum (s ∪ t : Set α) (s ∩ t : Set α) ≃ Sum s t :=
  calc
    Sum (s ∪ t : Set α) (s ∩ t : Set α) ≃ Sum (s ∪ t \ s : Set α) (s ∩ t : Set α) := by
      rw [union_diff_self]
    _ ≃ Sum (Sum s (t \ s : Set α)) (s ∩ t : Set α) :=
      (sumCongr (Set.union <| subset_empty_iff.2 (inter_diff_self _ _)) (Equiv.refl _))
    _ ≃ Sum s (Sum (t \ s : Set α) (s ∩ t : Set α)) := (sumAssoc _ _ _)
    _ ≃ Sum s (t \ s ∪ s ∩ t : Set α) :=
      (sumCongr (Equiv.refl _)
        (by
          refine' (set.union' (· ∉ s) _ _).symm
          exacts[fun x hx => hx.2, fun x hx => not_not_intro hx.1]))
    _ ≃ Sum s t := by
      rw [(_ : t \ s ∪ s ∩ t = t)]
      rw [union_comm, inter_comm, inter_union_diff]
    
#align equiv.set.union_sum_inter Equiv.Set.unionSumInter

#print Equiv.Set.compl /-
/-- Given an equivalence `e₀` between sets `s : set α` and `t : set β`, the set of equivalences
`e : α ≃ β` such that `e ↑x = ↑(e₀ x)` for each `x : s` is equivalent to the set of equivalences
between `sᶜ` and `tᶜ`. -/
protected def compl {α : Type u} {β : Type v} {s : Set α} {t : Set β} [DecidablePred (· ∈ s)]
    [DecidablePred (· ∈ t)] (e₀ : s ≃ t) :
    { e : α ≃ β // ∀ x : s, e x = e₀ x } ≃ ((sᶜ : Set α) ≃ (tᶜ : Set β))
    where
  toFun e :=
    subtypeEquiv e fun a =>
      not_congr <|
        Iff.symm <|
          MapsTo.mem_iff (mapsTo_iff_exists_map_subtype.2 ⟨e₀, e.2⟩)
            (SurjOn.mapsTo_compl
              (surjOn_iff_exists_map_subtype.2 ⟨t, e₀, Subset.refl t, e₀.Surjective, e.2⟩)
              e.1.Injective)
  invFun e₁ :=
    Subtype.mk
      (calc
        α ≃ Sum s (sᶜ : Set α) := (Set.sumCompl s).symm
        _ ≃ Sum t (tᶜ : Set β) := (e₀.sumCongr e₁)
        _ ≃ β := Set.sumCompl t
        )
      fun x => by
      simp only [Sum.map_inl, trans_apply, sum_congr_apply, set.sum_compl_apply_inl,
        set.sum_compl_symm_apply]
  left_inv e := by
    ext x
    by_cases hx : x ∈ s
    ·
      simp only [set.sum_compl_symm_apply_of_mem hx, ← e.prop ⟨x, hx⟩, Sum.map_inl, sum_congr_apply,
        trans_apply, Subtype.coe_mk, set.sum_compl_apply_inl]
    ·
      simp only [set.sum_compl_symm_apply_of_not_mem hx, Sum.map_inr, subtype_equiv_apply,
        set.sum_compl_apply_inr, trans_apply, sum_congr_apply, Subtype.coe_mk]
  right_inv e :=
    Equiv.ext fun x => by
      simp only [Sum.map_inr, subtype_equiv_apply, set.sum_compl_apply_inr, Function.comp_apply,
        sum_congr_apply, Equiv.coe_trans, Subtype.coe_eta, Subtype.coe_mk,
        set.sum_compl_symm_apply_compl]
#align equiv.set.compl Equiv.Set.compl
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Equiv.Set.prod /-
/-- The set product of two sets is equivalent to the type product of their coercions to types. -/
protected def prod {α β} (s : Set α) (t : Set β) : ↥(s ×ˢ t) ≃ s × t :=
  @subtypeProdEquivProd α β s t
#align equiv.set.prod Equiv.Set.prod
-/

#print Equiv.Set.univPi /-
/-- The set `set.pi set.univ s` is equivalent to `Π a, s a`. -/
@[simps]
protected def univPi {α : Type _} {β : α → Type _} (s : ∀ a, Set (β a)) : pi univ s ≃ ∀ a, s a
    where
  toFun f a := ⟨(f : ∀ a, β a) a, f.2 a (mem_univ a)⟩
  invFun f := ⟨fun a => f a, fun a ha => (f a).2⟩
  left_inv := fun ⟨f, hf⟩ => by
    ext a
    rfl
  right_inv f := by
    ext a
    rfl
#align equiv.set.univ_pi Equiv.Set.univPi
-/

#print Equiv.Set.imageOfInjOn /-
/-- If a function `f` is injective on a set `s`, then `s` is equivalent to `f '' s`. -/
protected noncomputable def imageOfInjOn {α β} (f : α → β) (s : Set α) (H : InjOn f s) :
    s ≃ f '' s :=
  ⟨fun p => ⟨f p, mem_image_of_mem f p.2⟩, fun p =>
    ⟨Classical.choose p.2, (Classical.choose_spec p.2).1⟩, fun ⟨x, h⟩ =>
    Subtype.eq
      (H (Classical.choose_spec (mem_image_of_mem f h)).1 h
        (Classical.choose_spec (mem_image_of_mem f h)).2),
    fun ⟨y, h⟩ => Subtype.eq (Classical.choose_spec h).2⟩
#align equiv.set.image_of_inj_on Equiv.Set.imageOfInjOn
-/

#print Equiv.Set.image /-
/-- If `f` is an injective function, then `s` is equivalent to `f '' s`. -/
@[simps apply]
protected noncomputable def image {α β} (f : α → β) (s : Set α) (H : Injective f) : s ≃ f '' s :=
  Equiv.Set.imageOfInjOn f s (H.InjOn s)
#align equiv.set.image Equiv.Set.image
-/

/- warning: equiv.set.image_symm_apply -> Equiv.Set.image_symm_apply is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (f : α -> β) (s : Set.{u1} α) (H : Function.Injective.{succ u1, succ u2} α β f) (x : α) (h : Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s), Eq.{succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeFn.{max 1 (max (succ u2) (succ u1)) (succ u1) (succ u2), max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s)) (fun (_x : Equiv.{succ u2, succ u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s)) => (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) -> (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s)) (Equiv.hasCoeToFun.{succ u2, succ u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s)) (Equiv.symm.{succ u1, succ u2} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) (Equiv.Set.image.{u1, u2} α β f s H)) (Subtype.mk.{succ u2} β (fun (x : β) => Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x (Set.image.{u1, u2} α β f s)) (f x) (Exists.intro.{succ u1} α (fun (x_1 : α) => And (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x_1 s) (Eq.{succ u2} β (f x_1) (f x))) x (And.intro (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) (Eq.{succ u2} β (f x) (f x)) h (rfl.{succ u2} β (f x)))))) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) x h)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (f : α -> β) (s : Set.{u2} α) (H : Function.Injective.{succ u2, succ u1} α β f) (x : α) (h : Membership.mem.{u2, u2} α (Set.{u2} α) (Set.instMembershipSet.{u2} α) x s), Eq.{succ u2} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} β (Set.image.{u2, u1} α β f s)) => Set.Elem.{u2} α s) (Subtype.mk.{succ u1} β (fun (x : β) => Membership.mem.{u1, u1} β (Set.{u1} β) (Set.instMembershipSet.{u1} β) x (Set.image.{u2, u1} α β f s)) (f x) (Exists.intro.{succ u2} α (fun (a : α) => And (Membership.mem.{u2, u2} α (Set.{u2} α) (Set.instMembershipSet.{u2} α) a s) (Eq.{succ u1} β (f a) (f x))) x (And.intro (Membership.mem.{u2, u2} α (Set.{u2} α) (Set.instMembershipSet.{u2} α) x s) (Eq.{succ u1} β (f x) (f x)) h (rfl.{succ u1} β (f x)))))) (FunLike.coe.{max (succ u2) (succ u1), succ u1, succ u2} (Equiv.{succ u1, succ u2} (Set.Elem.{u1} β (Set.image.{u2, u1} α β f s)) (Set.Elem.{u2} α s)) (Set.Elem.{u1} β (Set.image.{u2, u1} α β f s)) (fun (_x : Set.Elem.{u1} β (Set.image.{u2, u1} α β f s)) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} β (Set.image.{u2, u1} α β f s)) => Set.Elem.{u2} α s) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u2} (Set.Elem.{u1} β (Set.image.{u2, u1} α β f s)) (Set.Elem.{u2} α s)) (Equiv.symm.{succ u2, succ u1} (Set.Elem.{u2} α s) (Set.Elem.{u1} β (Set.image.{u2, u1} α β f s)) (Equiv.Set.image.{u2, u1} α β f s H)) (Subtype.mk.{succ u1} β (fun (x : β) => Membership.mem.{u1, u1} β (Set.{u1} β) (Set.instMembershipSet.{u1} β) x (Set.image.{u2, u1} α β f s)) (f x) (Exists.intro.{succ u2} α (fun (x_1 : α) => And (Membership.mem.{u2, u2} α (Set.{u2} α) (Set.instMembershipSet.{u2} α) x_1 s) (Eq.{succ u1} β (f x_1) (f x))) x (And.intro (Membership.mem.{u2, u2} α (Set.{u2} α) (Set.instMembershipSet.{u2} α) x s) (Eq.{succ u1} β (f x) (f x)) h (rfl.{succ u1} β (f x)))))) (Subtype.mk.{succ u2} α (fun (x : α) => Membership.mem.{u2, u2} α (Set.{u2} α) (Set.instMembershipSet.{u2} α) x s) x h)
Case conversion may be inaccurate. Consider using '#align equiv.set.image_symm_apply Equiv.Set.image_symm_applyₓ'. -/
@[simp]
protected theorem image_symm_apply {α β} (f : α → β) (s : Set α) (H : Injective f) (x : α)
    (h : x ∈ s) : (Set.image f s H).symm ⟨f x, ⟨x, ⟨h, rfl⟩⟩⟩ = ⟨x, h⟩ :=
  by
  apply (Set.image f s H).Injective
  simp [(Set.image f s H).apply_symm_apply]
#align equiv.set.image_symm_apply Equiv.Set.image_symm_apply

/- warning: equiv.set.image_symm_preimage -> Equiv.Set.image_symm_preimage is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {f : α -> β} (hf : Function.Injective.{succ u1, succ u2} α β f) (u : Set.{u1} α) (s : Set.{u1} α), Eq.{succ u2} (Set.{u2} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s))) (Set.preimage.{u2, u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) α (fun (x : coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) => (fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s))))) (coeFn.{max 1 (max (succ u2) (succ u1)) (succ u1) (succ u2), max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s)) (fun (_x : Equiv.{succ u2, succ u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s)) => (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) -> (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s)) (Equiv.hasCoeToFun.{succ u2, succ u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s)) (Equiv.symm.{succ u1, succ u2} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) (Equiv.Set.image.{u1, u2} α β f s hf)) x)) u) (Set.preimage.{u2, u2} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) β ((fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) β (HasLiftT.mk.{succ u2, succ u2} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) β (CoeTCₓ.coe.{succ u2, succ u2} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) β (coeBase.{succ u2, succ u2} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.image.{u1, u2} α β f s)) β (coeSubtype.{succ u2} β (fun (x : β) => Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x (Set.image.{u1, u2} α β f s))))))) (Set.image.{u1, u2} α β f u))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} {f : α -> β} (hf : Function.Injective.{succ u2, succ u1} α β f) (u : Set.{u2} α) (s : Set.{u2} α), Eq.{succ u1} (Set.{u1} (Set.Elem.{u1} β (Set.image.{u2, u1} α β f s))) (Set.preimage.{u1, u2} (Set.Elem.{u1} β (Set.image.{u2, u1} α β f s)) α (fun (x : Set.Elem.{u1} β (Set.image.{u2, u1} α β f s)) => Subtype.val.{succ u2} α (fun (x : α) => Membership.mem.{u2, u2} α (Set.{u2} α) (Set.instMembershipSet.{u2} α) x s) (FunLike.coe.{max (succ u2) (succ u1), succ u1, succ u2} (Equiv.{succ u1, succ u2} (Set.Elem.{u1} β (Set.image.{u2, u1} α β f s)) (Set.Elem.{u2} α s)) (Set.Elem.{u1} β (Set.image.{u2, u1} α β f s)) (fun (_x : Set.Elem.{u1} β (Set.image.{u2, u1} α β f s)) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} β (Set.image.{u2, u1} α β f s)) => Set.Elem.{u2} α s) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u2} (Set.Elem.{u1} β (Set.image.{u2, u1} α β f s)) (Set.Elem.{u2} α s)) (Equiv.symm.{succ u2, succ u1} (Set.Elem.{u2} α s) (Set.Elem.{u1} β (Set.image.{u2, u1} α β f s)) (Equiv.Set.image.{u2, u1} α β f s hf)) x)) u) (Set.preimage.{u1, u1} (Subtype.{succ u1} β (fun (x : β) => Membership.mem.{u1, u1} β (Set.{u1} β) (Set.instMembershipSet.{u1} β) x (Set.image.{u2, u1} α β f s))) β (Subtype.val.{succ u1} β (fun (x : β) => Membership.mem.{u1, u1} β (Set.{u1} β) (Set.instMembershipSet.{u1} β) x (Set.image.{u2, u1} α β f s))) (Set.image.{u2, u1} α β f u))
Case conversion may be inaccurate. Consider using '#align equiv.set.image_symm_preimage Equiv.Set.image_symm_preimageₓ'. -/
theorem image_symm_preimage {α β} {f : α → β} (hf : Injective f) (u s : Set α) :
    (fun x => (Set.image f s hf).symm x : f '' s → α) ⁻¹' u = coe ⁻¹' (f '' u) :=
  by
  ext ⟨b, a, has, rfl⟩
  have : ∀ h : ∃ a', a' ∈ s ∧ a' = a, Classical.choose h = a := fun h => (Classical.choose_spec h).2
  simp [Equiv.Set.image, Equiv.Set.imageOfInjOn, hf.eq_iff, this]
#align equiv.set.image_symm_preimage Equiv.Set.image_symm_preimage

#print Equiv.Set.congr /-
/-- If `α` is equivalent to `β`, then `set α` is equivalent to `set β`. -/
@[simps]
protected def congr {α β : Type _} (e : α ≃ β) : Set α ≃ Set β :=
  ⟨fun s => e '' s, fun t => e.symm '' t, symm_image_image e, symm_image_image e.symm⟩
#align equiv.set.congr Equiv.Set.congr
-/

#print Equiv.Set.sep /-
/-- The set `{x ∈ s | t x}` is equivalent to the set of `x : s` such that `t x`. -/
protected def sep {α : Type u} (s : Set α) (t : α → Prop) :
    ({ x ∈ s | t x } : Set α) ≃ { x : s | t x } :=
  (Equiv.subtypeSubtypeEquivSubtypeInter s t).symm
#align equiv.set.sep Equiv.Set.sep
-/

#print Equiv.Set.powerset /-
/-- The set `𝒫 S := {x | x ⊆ S}` is equivalent to the type `set S`. -/
protected def powerset {α} (S : Set α) : 𝒫 S ≃ Set S
    where
  toFun := fun x : 𝒫 S => coe ⁻¹' (x : Set α)
  invFun := fun x : Set S => ⟨coe '' x, by rintro _ ⟨a : S, _, rfl⟩ <;> exact a.2⟩
  left_inv x := by ext y <;> exact ⟨fun ⟨⟨_, _⟩, h, rfl⟩ => h, fun h => ⟨⟨_, x.2 h⟩, h, rfl⟩⟩
  right_inv x := by ext <;> simp
#align equiv.set.powerset Equiv.Set.powerset
-/

#print Equiv.Set.rangeSplittingImageEquiv /-
/-- If `s` is a set in `range f`,
then its image under `range_splitting f` is in bijection (via `f`) with `s`.
-/
@[simps]
noncomputable def rangeSplittingImageEquiv {α β : Type _} (f : α → β) (s : Set (range f)) :
    rangeSplitting f '' s ≃ s
    where
  toFun x :=
    ⟨⟨f x, by simp⟩, by
      rcases x with ⟨x, ⟨y, ⟨m, rfl⟩⟩⟩
      simpa [apply_range_splitting f] using m⟩
  invFun x := ⟨rangeSplitting f x, ⟨x, ⟨x.2, rfl⟩⟩⟩
  left_inv x := by
    rcases x with ⟨x, ⟨y, ⟨m, rfl⟩⟩⟩
    simp [apply_range_splitting f]
  right_inv x := by simp [apply_range_splitting f]
#align equiv.set.range_splitting_image_equiv Equiv.Set.rangeSplittingImageEquiv
-/

end Set

#print Equiv.ofLeftInverse /-
/-- If `f : α → β` has a left-inverse when `α` is nonempty, then `α` is computably equivalent to the
range of `f`.

While awkward, the `nonempty α` hypothesis on `f_inv` and `hf` allows this to be used when `α` is
empty too. This hypothesis is absent on analogous definitions on stronger `equiv`s like
`linear_equiv.of_left_inverse` and `ring_equiv.of_left_inverse` as their typeclass assumptions
are already sufficient to ensure non-emptiness. -/
@[simps]
def ofLeftInverse {α β : Sort _} (f : α → β) (f_inv : Nonempty α → β → α)
    (hf : ∀ h : Nonempty α, LeftInverse (f_inv h) f) : α ≃ range f
    where
  toFun a := ⟨f a, a, rfl⟩
  invFun b := f_inv (nonempty_of_exists b.2) b
  left_inv a := hf ⟨a⟩ a
  right_inv := fun ⟨b, a, ha⟩ =>
    Subtype.eq <| show f (f_inv ⟨a⟩ b) = b from Eq.trans (congr_arg f <| ha ▸ hf _ a) ha
#align equiv.of_left_inverse Equiv.ofLeftInverse
-/

#print Equiv.ofLeftInverse' /-
/-- If `f : α → β` has a left-inverse, then `α` is computably equivalent to the range of `f`.

Note that if `α` is empty, no such `f_inv` exists and so this definition can't be used, unlike
the stronger but less convenient `of_left_inverse`. -/
abbrev ofLeftInverse' {α β : Sort _} (f : α → β) (f_inv : β → α) (hf : LeftInverse f_inv f) :
    α ≃ range f :=
  ofLeftInverse f (fun _ => f_inv) fun _ => hf
#align equiv.of_left_inverse' Equiv.ofLeftInverse'
-/

#print Equiv.ofInjective /-
/-- If `f : α → β` is an injective function, then domain `α` is equivalent to the range of `f`. -/
@[simps apply]
noncomputable def ofInjective {α β} (f : α → β) (hf : Injective f) : α ≃ range f :=
  Equiv.ofLeftInverse f (fun h => Function.invFun f) fun h => Function.leftInverse_invFun hf
#align equiv.of_injective Equiv.ofInjective
-/

/- warning: equiv.apply_of_injective_symm -> Equiv.apply_ofInjective_symm is a dubious translation:
lean 3 declaration is
  forall {α : Sort.{u1}} {β : Type.{u2}} {f : α -> β} (hf : Function.Injective.{u1, succ u2} α β f) (b : coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)), Eq.{succ u2} β (f (coeFn.{max 1 (imax (succ u2) u1) u1 (succ u2), imax (succ u2) u1} (Equiv.{succ u2, u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) α) (fun (_x : Equiv.{succ u2, u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) α) => (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) -> α) (Equiv.hasCoeToFun.{succ u2, u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) α) (Equiv.symm.{u1, succ u2} α (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) (Equiv.ofInjective.{u1, u2} α β f hf)) b)) ((fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) β (HasLiftT.mk.{succ u2, succ u2} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) β (CoeTCₓ.coe.{succ u2, succ u2} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) β (coeBase.{succ u2, succ u2} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) β (coeSubtype.{succ u2} β (fun (x : β) => Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x (Set.range.{u2, u1} β α f)))))) b)
but is expected to have type
  forall {α : Sort.{u2}} {β : Type.{u1}} {f : α -> β} (hf : Function.Injective.{u2, succ u1} α β f) (b : Set.Elem.{u1} β (Set.range.{u1, u2} β α f)), Eq.{succ u1} β (f (FunLike.coe.{max u2 (succ u1), succ u1, u2} (Equiv.{succ u1, u2} (Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) α) (Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) (fun (_x : Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, u2} (Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) α) (Equiv.symm.{u2, succ u1} α (Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) (Equiv.ofInjective.{u2, u1} α β f hf)) b)) (Subtype.val.{succ u1} β (fun (x : β) => Membership.mem.{u1, u1} β (Set.{u1} β) (Set.instMembershipSet.{u1} β) x (Set.range.{u1, u2} β α f)) b)
Case conversion may be inaccurate. Consider using '#align equiv.apply_of_injective_symm Equiv.apply_ofInjective_symmₓ'. -/
theorem apply_ofInjective_symm {α β} {f : α → β} (hf : Injective f) (b : range f) :
    f ((ofInjective f hf).symm b) = b :=
  Subtype.ext_iff.1 <| (ofInjective f hf).apply_symm_apply b
#align equiv.apply_of_injective_symm Equiv.apply_ofInjective_symm

/- warning: equiv.of_injective_symm_apply -> Equiv.ofInjective_symm_apply is a dubious translation:
lean 3 declaration is
  forall {α : Sort.{u1}} {β : Type.{u2}} {f : α -> β} (hf : Function.Injective.{u1, succ u2} α β f) (a : α), Eq.{u1} α (coeFn.{max 1 (imax (succ u2) u1) u1 (succ u2), imax (succ u2) u1} (Equiv.{succ u2, u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) α) (fun (_x : Equiv.{succ u2, u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) α) => (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) -> α) (Equiv.hasCoeToFun.{succ u2, u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) α) (Equiv.symm.{u1, succ u2} α (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) (Equiv.ofInjective.{u1, u2} α β f hf)) (Subtype.mk.{succ u2} β (fun (x : β) => Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x (Set.range.{u2, u1} β α f)) (f a) (Exists.intro.{u1} α (fun (y : α) => Eq.{succ u2} β (f y) (f a)) a (rfl.{succ u2} β (f a))))) a
but is expected to have type
  forall {α : Sort.{u2}} {β : Type.{u1}} {f : α -> β} (hf : Function.Injective.{u2, succ u1} α β f) (a : α), Eq.{u2} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) => α) (Subtype.mk.{succ u1} β (fun (x : β) => Membership.mem.{u1, u1} β (Set.{u1} β) (Set.instMembershipSet.{u1} β) x (Set.range.{u1, u2} β α f)) (f a) (Exists.intro.{u2} α (fun (y : α) => Eq.{succ u1} β (f y) (f a)) a (rfl.{succ u1} β (f a))))) (FunLike.coe.{max u2 (succ u1), succ u1, u2} (Equiv.{succ u1, u2} (Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) α) (Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) (fun (_x : Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, u2} (Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) α) (Equiv.symm.{u2, succ u1} α (Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) (Equiv.ofInjective.{u2, u1} α β f hf)) (Subtype.mk.{succ u1} β (fun (x : β) => Membership.mem.{u1, u1} β (Set.{u1} β) (Set.instMembershipSet.{u1} β) x (Set.range.{u1, u2} β α f)) (f a) (Exists.intro.{u2} α (fun (y : α) => Eq.{succ u1} β (f y) (f a)) a (rfl.{succ u1} β (f a))))) a
Case conversion may be inaccurate. Consider using '#align equiv.of_injective_symm_apply Equiv.ofInjective_symm_applyₓ'. -/
@[simp]
theorem ofInjective_symm_apply {α β} {f : α → β} (hf : Injective f) (a : α) :
    (ofInjective f hf).symm ⟨f a, ⟨a, rfl⟩⟩ = a :=
  by
  apply (of_injective f hf).Injective
  simp [apply_of_injective_symm hf]
#align equiv.of_injective_symm_apply Equiv.ofInjective_symm_apply

/- warning: equiv.coe_of_injective_symm -> Equiv.coe_ofInjective_symm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {f : α -> β} (hf : Function.Injective.{succ u1, succ u2} α β f), Eq.{max (succ u2) (succ u1)} ((fun (_x : Equiv.{succ u2, succ u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, succ u1} β α f)) α) => (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, succ u1} β α f)) -> α) (Equiv.symm.{succ u1, succ u2} α (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, succ u1} β α f)) (Equiv.ofInjective.{succ u1, u2} α β f hf))) (coeFn.{max 1 (max (succ u2) (succ u1)) (succ u1) (succ u2), max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, succ u1} β α f)) α) (fun (_x : Equiv.{succ u2, succ u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, succ u1} β α f)) α) => (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, succ u1} β α f)) -> α) (Equiv.hasCoeToFun.{succ u2, succ u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, succ u1} β α f)) α) (Equiv.symm.{succ u1, succ u2} α (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, succ u1} β α f)) (Equiv.ofInjective.{succ u1, u2} α β f hf))) (Set.rangeSplitting.{u1, u2} α β f)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} {f : α -> β} (hf : Function.Injective.{succ u2, succ u1} α β f), Eq.{max (succ u1) (succ u2)} (forall (a : Set.Elem.{u1} β (Set.range.{u1, succ u2} β α f)), (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} β (Set.range.{u1, succ u2} β α f)) => α) a) (FunLike.coe.{max (succ u2) (succ u1), succ u1, succ u2} (Equiv.{succ u1, succ u2} (Set.Elem.{u1} β (Set.range.{u1, succ u2} β α f)) α) (Set.Elem.{u1} β (Set.range.{u1, succ u2} β α f)) (fun (_x : Set.Elem.{u1} β (Set.range.{u1, succ u2} β α f)) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} β (Set.range.{u1, succ u2} β α f)) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, succ u2} (Set.Elem.{u1} β (Set.range.{u1, succ u2} β α f)) α) (Equiv.symm.{succ u2, succ u1} α (Set.Elem.{u1} β (Set.range.{u1, succ u2} β α f)) (Equiv.ofInjective.{succ u2, u1} α β f hf))) (Set.rangeSplitting.{u2, u1} α β f)
Case conversion may be inaccurate. Consider using '#align equiv.coe_of_injective_symm Equiv.coe_ofInjective_symmₓ'. -/
theorem coe_ofInjective_symm {α β} {f : α → β} (hf : Injective f) :
    ((ofInjective f hf).symm : range f → α) = rangeSplitting f :=
  by
  ext ⟨y, x, rfl⟩
  apply hf
  simp [apply_range_splitting f]
#align equiv.coe_of_injective_symm Equiv.coe_ofInjective_symm

/- warning: equiv.self_comp_of_injective_symm -> Equiv.self_comp_ofInjective_symm is a dubious translation:
lean 3 declaration is
  forall {α : Sort.{u1}} {β : Type.{u2}} {f : α -> β} (hf : Function.Injective.{u1, succ u2} α β f), Eq.{succ u2} ((coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) -> β) (Function.comp.{succ u2, u1, succ u2} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) α β f (coeFn.{max 1 (imax (succ u2) u1) u1 (succ u2), imax (succ u2) u1} (Equiv.{succ u2, u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) α) (fun (_x : Equiv.{succ u2, u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) α) => (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) -> α) (Equiv.hasCoeToFun.{succ u2, u1} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) α) (Equiv.symm.{u1, succ u2} α (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) (Equiv.ofInjective.{u1, u2} α β f hf)))) ((fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) β (HasLiftT.mk.{succ u2, succ u2} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) β (CoeTCₓ.coe.{succ u2, succ u2} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) β (coeBase.{succ u2, succ u2} (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, u1} β α f)) β (coeSubtype.{succ u2} β (fun (x : β) => Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) x (Set.range.{u2, u1} β α f)))))))
but is expected to have type
  forall {α : Sort.{u2}} {β : Type.{u1}} {f : α -> β} (hf : Function.Injective.{u2, succ u1} α β f), Eq.{succ u1} ((Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) -> β) (Function.comp.{succ u1, u2, succ u1} (Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) α β f (FunLike.coe.{max u2 (succ u1), succ u1, u2} (Equiv.{succ u1, u2} (Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) α) (Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) (fun (_x : Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) => α) _x) (Equiv.instFunLikeEquiv.{succ u1, u2} (Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) α) (Equiv.symm.{u2, succ u1} α (Set.Elem.{u1} β (Set.range.{u1, u2} β α f)) (Equiv.ofInjective.{u2, u1} α β f hf)))) (Subtype.val.{succ u1} β (fun (x : β) => Membership.mem.{u1, u1} β (Set.{u1} β) (Set.instMembershipSet.{u1} β) x (Set.range.{u1, u2} β α f)))
Case conversion may be inaccurate. Consider using '#align equiv.self_comp_of_injective_symm Equiv.self_comp_ofInjective_symmₓ'. -/
@[simp]
theorem self_comp_ofInjective_symm {α β} {f : α → β} (hf : Injective f) :
    f ∘ (ofInjective f hf).symm = coe :=
  funext fun x => apply_ofInjective_symm hf x
#align equiv.self_comp_of_injective_symm Equiv.self_comp_ofInjective_symm

/- warning: equiv.of_left_inverse_eq_of_injective -> Equiv.ofLeftInverse_eq_ofInjective is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (f : α -> β) (f_inv : (Nonempty.{succ u1} α) -> β -> α) (hf : forall (h : Nonempty.{succ u1} α), Function.LeftInverse.{succ u1, succ u2} α β (f_inv h) f), Eq.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1)} (Equiv.{succ u1, succ u2} α (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, succ u1} β α f))) (Equiv.ofLeftInverse.{succ u1, u2} α β f f_inv hf) (Equiv.ofInjective.{succ u1, u2} α β f (Or.elim (Nonempty.{succ u1} α) (Not (Nonempty.{succ u1} α)) (Function.Injective.{succ u1, succ u2} α β f) (em (Nonempty.{succ u1} α)) (fun (h : Nonempty.{succ u1} α) => Function.LeftInverse.injective.{succ u1, succ u2} α β (f_inv h) f (hf h)) (fun (h : Not (Nonempty.{succ u1} α)) (_x : α) (_x_1 : α) (_x_2 : Eq.{succ u2} β (f _x) (f _x_1)) => Eq.mpr.{0} (Eq.{succ u1} α _x _x_1) True (id_tag Tactic.IdTag.simp (Eq.{1} Prop (Eq.{succ u1} α _x _x_1) True) (propext (Eq.{succ u1} α _x _x_1) True (eq_iff_true_of_subsingleton.{succ u1} α (subsingleton_of_not_nonempty.{succ u1} α h) _x _x_1))) trivial)))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (f : α -> β) (f_inv : (Nonempty.{succ u2} α) -> β -> α) (hf : forall (h : Nonempty.{succ u2} α), Function.LeftInverse.{succ u2, succ u1} α β (f_inv h) f), Eq.{max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} α (Set.Elem.{u1} β (Set.range.{u1, succ u2} β α f))) (Equiv.ofLeftInverse.{succ u2, u1} α β f f_inv hf) (Equiv.ofInjective.{succ u2, u1} α β f (Or.elim (IsEmpty.{succ u2} α) (Nonempty.{succ u2} α) (Function.Injective.{succ u2, succ u1} α β f) (isEmpty_or_nonempty.{succ u2} α) (fun (h : IsEmpty.{succ u2} α) (x._@.Mathlib.Logic.Equiv.Set._hyg.5602 : α) (x._@.Mathlib.Logic.Equiv.Set._hyg.5604 : α) (x._@.Mathlib.Logic.Equiv.Set._hyg.5606 : Eq.{succ u1} β (f x._@.Mathlib.Logic.Equiv.Set._hyg.5602) (f x._@.Mathlib.Logic.Equiv.Set._hyg.5604)) => Subsingleton.elim.{succ u2} α (IsEmpty.instSubsingleton.{succ u2} α h) x._@.Mathlib.Logic.Equiv.Set._hyg.5602 x._@.Mathlib.Logic.Equiv.Set._hyg.5604) (fun (h : Nonempty.{succ u2} α) => Function.LeftInverse.injective.{succ u2, succ u1} α β (f_inv h) f (hf h))))
Case conversion may be inaccurate. Consider using '#align equiv.of_left_inverse_eq_of_injective Equiv.ofLeftInverse_eq_ofInjectiveₓ'. -/
theorem ofLeftInverse_eq_ofInjective {α β : Type _} (f : α → β) (f_inv : Nonempty α → β → α)
    (hf : ∀ h : Nonempty α, LeftInverse (f_inv h) f) :
    ofLeftInverse f f_inv hf =
      ofInjective f
        ((em (Nonempty α)).elim (fun h => (hf h).Injective) fun h _ _ _ =>
          by
          haveI : Subsingleton α := subsingleton_of_not_nonempty h
          simp) :=
  by
  ext
  simp
#align equiv.of_left_inverse_eq_of_injective Equiv.ofLeftInverse_eq_ofInjective

/- warning: equiv.of_left_inverse'_eq_of_injective -> Equiv.ofLeftInverse'_eq_ofInjective is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (f : α -> β) (f_inv : β -> α) (hf : Function.LeftInverse.{succ u1, succ u2} α β f_inv f), Eq.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1)} (Equiv.{succ u1, succ u2} α (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.range.{u2, succ u1} β α f))) (Equiv.ofLeftInverse'.{succ u1, u2} α β f f_inv hf) (Equiv.ofInjective.{succ u1, u2} α β f (Function.LeftInverse.injective.{succ u1, succ u2} α β f_inv f hf))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (f : α -> β) (f_inv : β -> α) (hf : Function.LeftInverse.{succ u2, succ u1} α β f_inv f), Eq.{max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} α (Set.Elem.{u1} β (Set.range.{u1, succ u2} β α f))) (Equiv.ofLeftInverse'.{succ u2, u1} α β f f_inv hf) (Equiv.ofInjective.{succ u2, u1} α β f (Function.LeftInverse.injective.{succ u2, succ u1} α β f_inv f hf))
Case conversion may be inaccurate. Consider using '#align equiv.of_left_inverse'_eq_of_injective Equiv.ofLeftInverse'_eq_ofInjectiveₓ'. -/
theorem ofLeftInverse'_eq_ofInjective {α β : Type _} (f : α → β) (f_inv : β → α)
    (hf : LeftInverse f_inv f) : ofLeftInverse' f f_inv hf = ofInjective f hf.Injective :=
  by
  ext
  simp
#align equiv.of_left_inverse'_eq_of_injective Equiv.ofLeftInverse'_eq_ofInjective

/- warning: equiv.set_forall_iff -> Equiv.set_forall_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (e : Equiv.{succ u1, succ u2} α β) {p : (Set.{u1} α) -> Prop}, Iff (forall (a : Set.{u1} α), p a) (forall (a : Set.{u2} β), p (Set.preimage.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) e) a))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} (e : Equiv.{succ u2, succ u1} α β) {p : (Set.{u2} α) -> Prop}, Iff (forall (a : Set.{u2} α), p a) (forall (a : Set.{u1} β), p (Set.preimage.{u2, u1} α β (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u2, succ u1} α β) e) a))
Case conversion may be inaccurate. Consider using '#align equiv.set_forall_iff Equiv.set_forall_iffₓ'. -/
protected theorem set_forall_iff {α β} (e : α ≃ β) {p : Set α → Prop} :
    (∀ a, p a) ↔ ∀ a, p (e ⁻¹' a) :=
  e.Injective.preimage_surjective.forall
#align equiv.set_forall_iff Equiv.set_forall_iff

/- warning: equiv.preimage_pi_equiv_pi_subtype_prod_symm_pi -> Equiv.preimage_piEquivPiSubtypeProd_symm_pi is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : α -> Type.{u2}} (p : α -> Prop) [_inst_1 : DecidablePred.{succ u1} α p] (s : forall (i : α), Set.{u2} (β i)), Eq.{succ (max u1 u2)} (Set.{max u1 u2} (Prod.{max u1 u2, max u1 u2} (forall (i : Subtype.{succ u1} α (fun (x : α) => p x)), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => p x)) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeSubtype.{succ u1} α (fun (x : α) => p x))))) i)) (forall (i : Subtype.{succ u1} α (fun (x : α) => Not (p x))), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeSubtype.{succ u1} α (fun (x : α) => Not (p x)))))) i)))) (Set.preimage.{max u1 u2, max u1 u2} (Prod.{max u1 u2, max u1 u2} (forall (i : Subtype.{succ u1} α (fun (x : α) => p x)), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => p x)) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeSubtype.{succ u1} α (fun (x : α) => p x))))) i)) (forall (i : Subtype.{succ u1} α (fun (x : α) => Not (p x))), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeSubtype.{succ u1} α (fun (x : α) => Not (p x)))))) i))) (forall (i : α), β i) (coeFn.{max 1 (max (succ (max u1 u2)) (succ u1) (succ u2)) (max (succ u1) (succ u2)) (succ (max u1 u2)), max (succ (max u1 u2)) (succ u1) (succ u2)} (Equiv.{succ (max u1 u2), max (succ u1) (succ u2)} (Prod.{max u1 u2, max u1 u2} (forall (i : Subtype.{succ u1} α (fun (x : α) => p x)), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => p x)) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeSubtype.{succ u1} α (fun (x : α) => p x))))) i)) (forall (i : Subtype.{succ u1} α (fun (x : α) => Not (p x))), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeSubtype.{succ u1} α (fun (x : α) => Not (p x)))))) i))) (forall (i : α), β i)) (fun (_x : Equiv.{succ (max u1 u2), max (succ u1) (succ u2)} (Prod.{max u1 u2, max u1 u2} (forall (i : Subtype.{succ u1} α (fun (x : α) => p x)), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => p x)) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeSubtype.{succ u1} α (fun (x : α) => p x))))) i)) (forall (i : Subtype.{succ u1} α (fun (x : α) => Not (p x))), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeSubtype.{succ u1} α (fun (x : α) => Not (p x)))))) i))) (forall (i : α), β i)) => (Prod.{max u1 u2, max u1 u2} (forall (i : Subtype.{succ u1} α (fun (x : α) => p x)), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => p x)) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeSubtype.{succ u1} α (fun (x : α) => p x))))) i)) (forall (i : Subtype.{succ u1} α (fun (x : α) => Not (p x))), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeSubtype.{succ u1} α (fun (x : α) => Not (p x)))))) i))) -> (forall (i : α), β i)) (Equiv.hasCoeToFun.{succ (max u1 u2), max (succ u1) (succ u2)} (Prod.{max u1 u2, max u1 u2} (forall (i : Subtype.{succ u1} α (fun (x : α) => p x)), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => p x)) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeSubtype.{succ u1} α (fun (x : α) => p x))))) i)) (forall (i : Subtype.{succ u1} α (fun (x : α) => Not (p x))), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeSubtype.{succ u1} α (fun (x : α) => Not (p x)))))) i))) (forall (i : α), β i)) (Equiv.symm.{max (succ u1) (succ u2), succ (max u1 u2)} (forall (i : α), β i) (Prod.{max u1 u2, max u1 u2} (forall (i : Subtype.{succ u1} α (fun (x : α) => p x)), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => p x)) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeSubtype.{succ u1} α (fun (x : α) => p x))))) i)) (forall (i : Subtype.{succ u1} α (fun (x : α) => Not (p x))), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeSubtype.{succ u1} α (fun (x : α) => Not (p x)))))) i))) (Equiv.piEquivPiSubtypeProd.{u1, u2} α p β (fun (a : α) => _inst_1 a)))) (Set.pi.{u1, u2} α (fun (i : α) => β i) (Set.univ.{u1} α) s)) (Set.prod.{max u1 u2, max u1 u2} (forall (i : Subtype.{succ u1} α (fun (x : α) => p x)), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => p x)) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeSubtype.{succ u1} α (fun (x : α) => p x))))) i)) (forall (i : Subtype.{succ u1} α (fun (x : α) => Not (p x))), β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeSubtype.{succ u1} α (fun (x : α) => Not (p x)))))) i)) (Set.pi.{u1, u2} (Subtype.{succ u1} α (fun (x : α) => p x)) (fun (i : Subtype.{succ u1} α (fun (x : α) => p x)) => β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => p x)) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => p x)) α (coeSubtype.{succ u1} α (fun (x : α) => p x))))) i)) (Set.univ.{u1} (Subtype.{succ u1} α (fun (x : α) => p x))) (fun (i : Subtype.{succ u1} α (fun (i : α) => p i)) => s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (i : α) => p i)) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (i : α) => p i)) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (i : α) => p i)) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (i : α) => p i)) α (coeSubtype.{succ u1} α (fun (i : α) => p i))))) i))) (Set.pi.{u1, u2} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) (fun (i : Subtype.{succ u1} α (fun (x : α) => Not (p x))) => β ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x))) α (coeSubtype.{succ u1} α (fun (x : α) => Not (p x)))))) i)) (Set.univ.{u1} (Subtype.{succ u1} α (fun (x : α) => Not (p x)))) (fun (i : Subtype.{succ u1} α (fun (i : α) => Not (p i))) => s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (i : α) => Not (p i))) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (i : α) => Not (p i))) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (i : α) => Not (p i))) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (i : α) => Not (p i))) α (coeSubtype.{succ u1} α (fun (i : α) => Not (p i)))))) i))))
but is expected to have type
  forall {α : Type.{u2}} {β : α -> Type.{u1}} (p : α -> Prop) [_inst_1 : DecidablePred.{succ u2} α p] (s : forall (i : α), Set.{u1} (β i)), Eq.{max (succ u2) (succ u1)} (Set.{max u2 u1} (Prod.{max u2 u1, max u2 u1} (forall (i : Subtype.{succ u2} α (fun (x : α) => p x)), β (Subtype.val.{succ u2} α (fun (x : α) => p x) i)) (forall (i : Subtype.{succ u2} α (fun (x : α) => Not (p x))), β (Subtype.val.{succ u2} α (fun (x : α) => Not (p x)) i)))) (Set.preimage.{max u2 u1, max u2 u1} (Prod.{max u2 u1, max u2 u1} (forall (i : Subtype.{succ u2} α (fun (x : α) => p x)), β (Subtype.val.{succ u2} α (fun (x : α) => p x) i)) (forall (i : Subtype.{succ u2} α (fun (x : α) => Not (p x))), β (Subtype.val.{succ u2} α (fun (x : α) => Not (p x)) i))) (forall (i : α), β i) (FunLike.coe.{max (succ u2) (succ u1), max (succ u2) (succ u1), max (succ u2) (succ u1)} (Equiv.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (Prod.{max u2 u1, max u2 u1} (forall (i : Subtype.{succ u2} α (fun (x : α) => p x)), β (Subtype.val.{succ u2} α (fun (x : α) => p x) i)) (forall (i : Subtype.{succ u2} α (fun (x : α) => Not (p x))), β (Subtype.val.{succ u2} α (fun (x : α) => Not (p x)) i))) (forall (i : α), β i)) (Prod.{max u2 u1, max u2 u1} (forall (i : Subtype.{succ u2} α (fun (x : α) => p x)), β (Subtype.val.{succ u2} α (fun (x : α) => p x) i)) (forall (i : Subtype.{succ u2} α (fun (x : α) => Not (p x))), β (Subtype.val.{succ u2} α (fun (x : α) => Not (p x)) i))) (fun (_x : Prod.{max u2 u1, max u2 u1} (forall (i : Subtype.{succ u2} α (fun (x : α) => p x)), β (Subtype.val.{succ u2} α (fun (x : α) => p x) i)) (forall (i : Subtype.{succ u2} α (fun (x : α) => Not (p x))), β (Subtype.val.{succ u2} α (fun (x : α) => Not (p x)) i))) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Prod.{max u2 u1, max u2 u1} (forall (i : Subtype.{succ u2} α (fun (x : α) => p x)), β (Subtype.val.{succ u2} α (fun (x : α) => p x) i)) (forall (i : Subtype.{succ u2} α (fun (x : α) => Not (p x))), β (Subtype.val.{succ u2} α (fun (x : α) => Not (p x)) i))) => forall (i : α), β i) _x) (Equiv.instFunLikeEquiv.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (Prod.{max u2 u1, max u2 u1} (forall (i : Subtype.{succ u2} α (fun (x : α) => p x)), β (Subtype.val.{succ u2} α (fun (x : α) => p x) i)) (forall (i : Subtype.{succ u2} α (fun (x : α) => Not (p x))), β (Subtype.val.{succ u2} α (fun (x : α) => Not (p x)) i))) (forall (i : α), β i)) (Equiv.symm.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (forall (i : α), β i) (Prod.{max u2 u1, max u2 u1} (forall (i : Subtype.{succ u2} α (fun (x : α) => p x)), β (Subtype.val.{succ u2} α (fun (x : α) => p x) i)) (forall (i : Subtype.{succ u2} α (fun (x : α) => Not (p x))), β (Subtype.val.{succ u2} α (fun (x : α) => Not (p x)) i))) (Equiv.piEquivPiSubtypeProd.{u2, u1} α p β (fun (a : α) => _inst_1 a)))) (Set.pi.{u2, u1} α (fun (i : α) => β i) (Set.univ.{u2} α) s)) (Set.prod.{max u1 u2, max u1 u2} (forall (i : Subtype.{succ u2} α (fun (x : α) => p x)), β (Subtype.val.{succ u2} α (fun (i : α) => p i) i)) (forall (i : Subtype.{succ u2} α (fun (x : α) => Not (p x))), β (Subtype.val.{succ u2} α (fun (i : α) => Not (p i)) i)) (Set.pi.{u2, u1} (Subtype.{succ u2} α (fun (x : α) => p x)) (fun (i : Subtype.{succ u2} α (fun (x : α) => p x)) => β (Subtype.val.{succ u2} α (fun (i : α) => p i) i)) (Set.univ.{u2} (Subtype.{succ u2} α (fun (x : α) => p x))) (fun (i : Subtype.{succ u2} α (fun (i : α) => p i)) => s (Subtype.val.{succ u2} α (fun (i : α) => p i) i))) (Set.pi.{u2, u1} (Subtype.{succ u2} α (fun (x : α) => Not (p x))) (fun (i : Subtype.{succ u2} α (fun (x : α) => Not (p x))) => β (Subtype.val.{succ u2} α (fun (i : α) => Not (p i)) i)) (Set.univ.{u2} (Subtype.{succ u2} α (fun (x : α) => Not (p x)))) (fun (i : Subtype.{succ u2} α (fun (i : α) => Not (p i))) => s (Subtype.val.{succ u2} α (fun (i : α) => Not (p i)) i))))
Case conversion may be inaccurate. Consider using '#align equiv.preimage_pi_equiv_pi_subtype_prod_symm_pi Equiv.preimage_piEquivPiSubtypeProd_symm_piₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem preimage_piEquivPiSubtypeProd_symm_pi {α : Type _} {β : α → Type _} (p : α → Prop)
    [DecidablePred p] (s : ∀ i, Set (β i)) :
    (piEquivPiSubtypeProd p β).symm ⁻¹' pi univ s =
      (pi univ fun i : { i // p i } => s i) ×ˢ pi univ fun i : { i // ¬p i } => s i :=
  by
  ext ⟨f, g⟩
  simp only [mem_preimage, mem_univ_pi, prod_mk_mem_set_prod_eq, Subtype.forall, ← forall_and]
  refine' forall_congr' fun i => _
  dsimp only [Subtype.coe_mk]
  by_cases hi : p i <;> simp [hi]
#align equiv.preimage_pi_equiv_pi_subtype_prod_symm_pi Equiv.preimage_piEquivPiSubtypeProd_symm_pi

#print Equiv.sigmaPreimageEquiv /-
-- See also `equiv.sigma_fiber_equiv`.
/-- `sigma_fiber_equiv f` for `f : α → β` is the natural equivalence between
the type of all preimages of points under `f` and the total space `α`. -/
@[simps]
def sigmaPreimageEquiv {α β} (f : α → β) : (Σb, f ⁻¹' {b}) ≃ α :=
  sigmaFiberEquiv f
#align equiv.sigma_preimage_equiv Equiv.sigmaPreimageEquiv
-/

#print Equiv.ofPreimageEquiv /-
-- See also `equiv.of_fiber_equiv`.
/-- A family of equivalences between preimages of points gives an equivalence between domains. -/
@[simps]
def ofPreimageEquiv {α β γ} {f : α → γ} {g : β → γ} (e : ∀ c, f ⁻¹' {c} ≃ g ⁻¹' {c}) : α ≃ β :=
  Equiv.ofFiberEquiv e
#align equiv.of_preimage_equiv Equiv.ofPreimageEquiv
-/

/- warning: equiv.of_preimage_equiv_map -> Equiv.ofPreimageEquiv_map is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {γ : Type.{u3}} {f : α -> γ} {g : β -> γ} (e : forall (c : γ), Equiv.{succ u1, succ u2} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) (Set.preimage.{u1, u3} α γ f (Singleton.singleton.{u3, u3} γ (Set.{u3} γ) (Set.hasSingleton.{u3} γ) c))) (coeSort.{succ u2, succ (succ u2)} (Set.{u2} β) Type.{u2} (Set.hasCoeToSort.{u2} β) (Set.preimage.{u2, u3} β γ g (Singleton.singleton.{u3, u3} γ (Set.{u3} γ) (Set.hasSingleton.{u3} γ) c)))) (a : α), Eq.{succ u3} γ (g (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) (Equiv.ofPreimageEquiv.{u1, u2, u3} α β γ f g e) a)) (f a)
but is expected to have type
  forall {α : Type.{u3}} {β : Type.{u2}} {γ : Type.{u1}} {f : α -> γ} {g : β -> γ} (e : forall (c : γ), Equiv.{succ u3, succ u2} (Set.Elem.{u3} α (Set.preimage.{u3, u1} α γ f (Singleton.singleton.{u1, u1} γ (Set.{u1} γ) (Set.instSingletonSet.{u1} γ) c))) (Set.Elem.{u2} β (Set.preimage.{u2, u1} β γ g (Singleton.singleton.{u1, u1} γ (Set.{u1} γ) (Set.instSingletonSet.{u1} γ) c)))) (a : α), Eq.{succ u1} γ (g (FunLike.coe.{max (succ u3) (succ u2), succ u3, succ u2} (Equiv.{succ u3, succ u2} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : α) => β) _x) (Equiv.instFunLikeEquiv.{succ u3, succ u2} α β) (Equiv.ofPreimageEquiv.{u3, u2, u1} α β γ f g e) a)) (f a)
Case conversion may be inaccurate. Consider using '#align equiv.of_preimage_equiv_map Equiv.ofPreimageEquiv_mapₓ'. -/
theorem ofPreimageEquiv_map {α β γ} {f : α → γ} {g : β → γ} (e : ∀ c, f ⁻¹' {c} ≃ g ⁻¹' {c})
    (a : α) : g (ofPreimageEquiv e a) = f a :=
  Equiv.ofFiberEquiv_map e a
#align equiv.of_preimage_equiv_map Equiv.ofPreimageEquiv_map

end Equiv

#print Set.BijOn.equiv /-
/-- If a function is a bijection between two sets `s` and `t`, then it induces an
equivalence between the types `↥s` and `↥t`. -/
noncomputable def Set.BijOn.equiv {α : Type _} {β : Type _} {s : Set α} {t : Set β} (f : α → β)
    (h : BijOn f s t) : s ≃ t :=
  Equiv.ofBijective _ h.Bijective
#align set.bij_on.equiv Set.BijOn.equiv
-/

/- warning: dite_comp_equiv_update -> dite_comp_equiv_update is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Sort.{u2}} {γ : Sort.{u3}} {s : Set.{u1} α} (e : Equiv.{u2, succ u1} β (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s)) (v : β -> γ) (w : α -> γ) (j : β) (x : γ) [_inst_1 : DecidableEq.{u2} β] [_inst_2 : DecidableEq.{succ u1} α] [_inst_3 : forall (j : α), Decidable (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) j s)], Eq.{imax (succ u1) u3} (α -> γ) (fun (i : α) => dite.{u3} γ (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) i s) (_inst_3 i) (fun (h : Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) i s) => Function.update.{u2, u3} β (fun (ᾰ : β) => γ) (fun (a : β) (b : β) => _inst_1 a b) v j x (coeFn.{max 1 (imax (succ u1) u2) u2 (succ u1), imax (succ u1) u2} (Equiv.{succ u1, u2} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) β) (fun (_x : Equiv.{succ u1, u2} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) β) => (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) -> β) (Equiv.hasCoeToFun.{succ u1, u2} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) β) (Equiv.symm.{u2, succ u1} β (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) e) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) i h))) (fun (h : Not (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) i s)) => w i)) (Function.update.{succ u1, u3} α (fun (i : α) => γ) (fun (a : α) (b : α) => _inst_2 a b) (fun (i : α) => dite.{u3} γ (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) i s) (_inst_3 i) (fun (h : Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) i s) => v (coeFn.{max 1 (imax (succ u1) u2) u2 (succ u1), imax (succ u1) u2} (Equiv.{succ u1, u2} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) β) (fun (_x : Equiv.{succ u1, u2} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) β) => (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) -> β) (Equiv.hasCoeToFun.{succ u1, u2} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) β) (Equiv.symm.{u2, succ u1} β (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) e) (Subtype.mk.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) i h))) (fun (h : Not (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) i s)) => w i)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s) α (coeSubtype.{succ u1} α (fun (x : α) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s))))) (coeFn.{max 1 (max u2 (succ u1)) (imax (succ u1) u2), max u2 (succ u1)} (Equiv.{u2, succ u1} β (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s)) (fun (_x : Equiv.{u2, succ u1} β (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s)) => β -> (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s)) (Equiv.hasCoeToFun.{u2, succ u1} β (coeSort.{succ u1, succ (succ u1)} (Set.{u1} α) Type.{u1} (Set.hasCoeToSort.{u1} α) s)) e j)) x)
but is expected to have type
  forall {α : Type.{u3}} {β : Sort.{u2}} {γ : Sort.{u1}} {s : Set.{u3} α} (e : Equiv.{u2, succ u3} β (Set.Elem.{u3} α s)) (v : β -> γ) (w : α -> γ) (j : β) (x : γ) [_inst_1 : DecidableEq.{u2} β] [_inst_2 : DecidableEq.{succ u3} α] [_inst_3 : forall (j : α), Decidable (Membership.mem.{u3, u3} α (Set.{u3} α) (Set.instMembershipSet.{u3} α) j s)], Eq.{imax (succ u3) u1} (α -> γ) (fun (i : α) => dite.{u1} γ (Membership.mem.{u3, u3} α (Set.{u3} α) (Set.instMembershipSet.{u3} α) i s) (_inst_3 i) (fun (h : Membership.mem.{u3, u3} α (Set.{u3} α) (Set.instMembershipSet.{u3} α) i s) => Function.update.{u2, u1} β (fun (ᾰ : β) => γ) (fun (a : β) (b : β) => _inst_1 a b) v j x (FunLike.coe.{max (succ u3) u2, succ u3, u2} (Equiv.{succ u3, u2} (Set.Elem.{u3} α s) β) (Set.Elem.{u3} α s) (fun (_x : Set.Elem.{u3} α s) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u3} α s) => β) _x) (Equiv.instFunLikeEquiv.{succ u3, u2} (Set.Elem.{u3} α s) β) (Equiv.symm.{u2, succ u3} β (Set.Elem.{u3} α s) e) (Subtype.mk.{succ u3} α (fun (x : α) => Membership.mem.{u3, u3} α (Set.{u3} α) (Set.instMembershipSet.{u3} α) x s) i h))) (fun (h : Not (Membership.mem.{u3, u3} α (Set.{u3} α) (Set.instMembershipSet.{u3} α) i s)) => w i)) (Function.update.{succ u3, u1} α (fun (i : α) => γ) (fun (a : α) (b : α) => _inst_2 a b) (fun (i : α) => dite.{u1} γ (Membership.mem.{u3, u3} α (Set.{u3} α) (Set.instMembershipSet.{u3} α) i s) (_inst_3 i) (fun (h : Membership.mem.{u3, u3} α (Set.{u3} α) (Set.instMembershipSet.{u3} α) i s) => v (FunLike.coe.{max (succ u3) u2, succ u3, u2} (Equiv.{succ u3, u2} (Set.Elem.{u3} α s) β) (Set.Elem.{u3} α s) (fun (_x : Set.Elem.{u3} α s) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Set.Elem.{u3} α s) => β) _x) (Equiv.instFunLikeEquiv.{succ u3, u2} (Set.Elem.{u3} α s) β) (Equiv.symm.{u2, succ u3} β (Set.Elem.{u3} α s) e) (Subtype.mk.{succ u3} α (fun (x : α) => Membership.mem.{u3, u3} α (Set.{u3} α) (Set.instMembershipSet.{u3} α) x s) i h))) (fun (h : Not (Membership.mem.{u3, u3} α (Set.{u3} α) (Set.instMembershipSet.{u3} α) i s)) => w i)) (Subtype.val.{succ u3} α (fun (x : α) => Membership.mem.{u3, u3} α (Set.{u3} α) (Set.instMembershipSet.{u3} α) x s) (FunLike.coe.{max (succ u3) u2, u2, succ u3} (Equiv.{u2, succ u3} β (Set.Elem.{u3} α s)) β (fun (_x : β) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : β) => Set.Elem.{u3} α s) _x) (Equiv.instFunLikeEquiv.{u2, succ u3} β (Set.Elem.{u3} α s)) e j)) x)
Case conversion may be inaccurate. Consider using '#align dite_comp_equiv_update dite_comp_equiv_updateₓ'. -/
/-- The composition of an updated function with an equiv on a subset can be expressed as an
updated function. -/
theorem dite_comp_equiv_update {α : Type _} {β : Sort _} {γ : Sort _} {s : Set α} (e : β ≃ s)
    (v : β → γ) (w : α → γ) (j : β) (x : γ) [DecidableEq β] [DecidableEq α]
    [∀ j, Decidable (j ∈ s)] :
    (fun i : α => if h : i ∈ s then (Function.update v j x) (e.symm ⟨i, h⟩) else w i) =
      Function.update (fun i : α => if h : i ∈ s then v (e.symm ⟨i, h⟩) else w i) (e j) x :=
  by
  ext i
  by_cases h : i ∈ s
  · rw [dif_pos h, Function.update_apply_equiv_apply, Equiv.symm_symm, Function.comp,
      Function.update_apply, Function.update_apply, dif_pos h]
    have h_coe : (⟨i, h⟩ : s) = e j ↔ i = e j := subtype.ext_iff.trans (by rw [Subtype.coe_mk])
    simp_rw [h_coe]
  · have : i ≠ e j := by
      contrapose! h
      have : (e j : α) ∈ s := (e j).2
      rwa [← h] at this
    simp [h, this]
#align dite_comp_equiv_update dite_comp_equiv_update

