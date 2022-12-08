/-
Copyright (c) 2021 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies
-/
import Mathbin.Data.Set.Image

/-!
# Monovariance of functions

Two functions *vary together* if a strict change in the first implies a change in the second.

This is in some sense a way to say that two functions `f : ι → α`, `g : ι → β` are "monotone
together", without actually having an order on `ι`.

This condition comes up in the rearrangement inequality. See `algebra.order.rearrangement`.

## Main declarations

* `monovary f g`: `f` monovaries with `g`. If `g i < g j`, then `f i ≤ f j`.
* `antivary f g`: `f` antivaries with `g`. If `g i < g j`, then `f j ≤ f i`.
* `monovary_on f g s`: `f` monovaries with `g` on `s`.
* `monovary_on f g s`: `f` antivaries with `g` on `s`.
-/


open Function Set

variable {ι ι' α β γ : Type _}

section Preorder

variable [Preorder α] [Preorder β] [Preorder γ] {f : ι → α} {f' : α → γ} {g : ι → β} {g' : β → γ}
  {s t : Set ι}

/-- `f` monovaries with `g` if `g i < g j` implies `f i ≤ f j`. -/
def Monovary (f : ι → α) (g : ι → β) : Prop :=
  ∀ ⦃i j⦄, g i < g j → f i ≤ f j
#align monovary Monovary

/-- `f` antivaries with `g` if `g i < g j` implies `f j ≤ f i`. -/
def Antivary (f : ι → α) (g : ι → β) : Prop :=
  ∀ ⦃i j⦄, g i < g j → f j ≤ f i
#align antivary Antivary

/-- `f` monovaries with `g` on `s` if `g i < g j` implies `f i ≤ f j` for all `i, j ∈ s`. -/
def MonovaryOn (f : ι → α) (g : ι → β) (s : Set ι) : Prop :=
  ∀ ⦃i⦄ (hi : i ∈ s) ⦃j⦄ (hj : j ∈ s), g i < g j → f i ≤ f j
#align monovary_on MonovaryOn

/-- `f` antivaries with `g` on `s` if `g i < g j` implies `f j ≤ f i` for all `i, j ∈ s`. -/
def AntivaryOn (f : ι → α) (g : ι → β) (s : Set ι) : Prop :=
  ∀ ⦃i⦄ (hi : i ∈ s) ⦃j⦄ (hj : j ∈ s), g i < g j → f j ≤ f i
#align antivary_on AntivaryOn

protected theorem Monovary.monovary_on (h : Monovary f g) (s : Set ι) : MonovaryOn f g s :=
  fun i _ j _ hij => h hij
#align monovary.monovary_on Monovary.monovary_on

protected theorem Antivary.antivary_on (h : Antivary f g) (s : Set ι) : AntivaryOn f g s :=
  fun i _ j _ hij => h hij
#align antivary.antivary_on Antivary.antivary_on

@[simp]
theorem MonovaryOn.empty : MonovaryOn f g ∅ := fun i => False.elim
#align monovary_on.empty MonovaryOn.empty

@[simp]
theorem AntivaryOn.empty : AntivaryOn f g ∅ := fun i => False.elim
#align antivary_on.empty AntivaryOn.empty

@[simp]
theorem monovary_on_univ : MonovaryOn f g univ ↔ Monovary f g :=
  ⟨fun h i j => h trivial trivial, fun h i _ j _ hij => h hij⟩
#align monovary_on_univ monovary_on_univ

@[simp]
theorem antivary_on_univ : AntivaryOn f g univ ↔ Antivary f g :=
  ⟨fun h i j => h trivial trivial, fun h i _ j _ hij => h hij⟩
#align antivary_on_univ antivary_on_univ

protected theorem MonovaryOn.subset (hst : s ⊆ t) (h : MonovaryOn f g t) : MonovaryOn f g s :=
  fun i hi j hj => h (hst hi) (hst hj)
#align monovary_on.subset MonovaryOn.subset

protected theorem AntivaryOn.subset (hst : s ⊆ t) (h : AntivaryOn f g t) : AntivaryOn f g s :=
  fun i hi j hj => h (hst hi) (hst hj)
#align antivary_on.subset AntivaryOn.subset

theorem monovary_const_left (g : ι → β) (a : α) : Monovary (const ι a) g := fun i j _ => le_rfl
#align monovary_const_left monovary_const_left

theorem antivary_const_left (g : ι → β) (a : α) : Antivary (const ι a) g := fun i j _ => le_rfl
#align antivary_const_left antivary_const_left

theorem monovary_const_right (f : ι → α) (b : β) : Monovary f (const ι b) := fun i j h =>
  (h.Ne rfl).elim
#align monovary_const_right monovary_const_right

theorem antivary_const_right (f : ι → α) (b : β) : Antivary f (const ι b) := fun i j h =>
  (h.Ne rfl).elim
#align antivary_const_right antivary_const_right

theorem monovary_self (f : ι → α) : Monovary f f := fun i j => le_of_lt
#align monovary_self monovary_self

theorem monovary_on_self (f : ι → α) (s : Set ι) : MonovaryOn f f s := fun i _ j _ => le_of_lt
#align monovary_on_self monovary_on_self

protected theorem Subsingleton.monovary [Subsingleton ι] (f : ι → α) (g : ι → β) : Monovary f g :=
  fun i j h => (ne_of_apply_ne _ h.Ne <| Subsingleton.elim _ _).elim
#align subsingleton.monovary Subsingleton.monovary

protected theorem Subsingleton.antivary [Subsingleton ι] (f : ι → α) (g : ι → β) : Antivary f g :=
  fun i j h => (ne_of_apply_ne _ h.Ne <| Subsingleton.elim _ _).elim
#align subsingleton.antivary Subsingleton.antivary

protected theorem Subsingleton.monovary_on [Subsingleton ι] (f : ι → α) (g : ι → β) (s : Set ι) :
    MonovaryOn f g s := fun i _ j _ h => (ne_of_apply_ne _ h.Ne <| Subsingleton.elim _ _).elim
#align subsingleton.monovary_on Subsingleton.monovary_on

protected theorem Subsingleton.antivary_on [Subsingleton ι] (f : ι → α) (g : ι → β) (s : Set ι) :
    AntivaryOn f g s := fun i _ j _ h => (ne_of_apply_ne _ h.Ne <| Subsingleton.elim _ _).elim
#align subsingleton.antivary_on Subsingleton.antivary_on

theorem monovary_on_const_left (g : ι → β) (a : α) (s : Set ι) : MonovaryOn (const ι a) g s :=
  fun i _ j _ _ => le_rfl
#align monovary_on_const_left monovary_on_const_left

theorem antivary_on_const_left (g : ι → β) (a : α) (s : Set ι) : AntivaryOn (const ι a) g s :=
  fun i _ j _ _ => le_rfl
#align antivary_on_const_left antivary_on_const_left

theorem monovary_on_const_right (f : ι → α) (b : β) (s : Set ι) : MonovaryOn f (const ι b) s :=
  fun i _ j _ h => (h.Ne rfl).elim
#align monovary_on_const_right monovary_on_const_right

theorem antivary_on_const_right (f : ι → α) (b : β) (s : Set ι) : AntivaryOn f (const ι b) s :=
  fun i _ j _ h => (h.Ne rfl).elim
#align antivary_on_const_right antivary_on_const_right

theorem Monovary.comp_right (h : Monovary f g) (k : ι' → ι) : Monovary (f ∘ k) (g ∘ k) :=
  fun i j hij => h hij
#align monovary.comp_right Monovary.comp_right

theorem Antivary.comp_right (h : Antivary f g) (k : ι' → ι) : Antivary (f ∘ k) (g ∘ k) :=
  fun i j hij => h hij
#align antivary.comp_right Antivary.comp_right

theorem MonovaryOn.comp_right (h : MonovaryOn f g s) (k : ι' → ι) :
    MonovaryOn (f ∘ k) (g ∘ k) (k ⁻¹' s) := fun i hi j hj => h hi hj
#align monovary_on.comp_right MonovaryOn.comp_right

theorem AntivaryOn.comp_right (h : AntivaryOn f g s) (k : ι' → ι) :
    AntivaryOn (f ∘ k) (g ∘ k) (k ⁻¹' s) := fun i hi j hj => h hi hj
#align antivary_on.comp_right AntivaryOn.comp_right

theorem Monovary.comp_monotone_left (h : Monovary f g) (hf : Monotone f') : Monovary (f' ∘ f) g :=
  fun i j hij => hf <| h hij
#align monovary.comp_monotone_left Monovary.comp_monotone_left

theorem Monovary.comp_antitone_left (h : Monovary f g) (hf : Antitone f') : Antivary (f' ∘ f) g :=
  fun i j hij => hf <| h hij
#align monovary.comp_antitone_left Monovary.comp_antitone_left

theorem Antivary.comp_monotone_left (h : Antivary f g) (hf : Monotone f') : Antivary (f' ∘ f) g :=
  fun i j hij => hf <| h hij
#align antivary.comp_monotone_left Antivary.comp_monotone_left

theorem Antivary.comp_antitone_left (h : Antivary f g) (hf : Antitone f') : Monovary (f' ∘ f) g :=
  fun i j hij => hf <| h hij
#align antivary.comp_antitone_left Antivary.comp_antitone_left

theorem MonovaryOn.comp_monotone_on_left (h : MonovaryOn f g s) (hf : Monotone f') :
    MonovaryOn (f' ∘ f) g s := fun i hi j hj hij => hf <| h hi hj hij
#align monovary_on.comp_monotone_on_left MonovaryOn.comp_monotone_on_left

theorem MonovaryOn.comp_antitone_on_left (h : MonovaryOn f g s) (hf : Antitone f') :
    AntivaryOn (f' ∘ f) g s := fun i hi j hj hij => hf <| h hi hj hij
#align monovary_on.comp_antitone_on_left MonovaryOn.comp_antitone_on_left

theorem AntivaryOn.comp_monotone_on_left (h : AntivaryOn f g s) (hf : Monotone f') :
    AntivaryOn (f' ∘ f) g s := fun i hi j hj hij => hf <| h hi hj hij
#align antivary_on.comp_monotone_on_left AntivaryOn.comp_monotone_on_left

theorem AntivaryOn.comp_antitone_on_left (h : AntivaryOn f g s) (hf : Antitone f') :
    MonovaryOn (f' ∘ f) g s := fun i hi j hj hij => hf <| h hi hj hij
#align antivary_on.comp_antitone_on_left AntivaryOn.comp_antitone_on_left

section OrderDual

open OrderDual

theorem Monovary.dual : Monovary f g → Monovary (to_dual ∘ f) (to_dual ∘ g) :=
  swap
#align monovary.dual Monovary.dual

theorem Antivary.dual : Antivary f g → Antivary (to_dual ∘ f) (to_dual ∘ g) :=
  swap
#align antivary.dual Antivary.dual

theorem Monovary.dual_left : Monovary f g → Antivary (to_dual ∘ f) g :=
  id
#align monovary.dual_left Monovary.dual_left

theorem Antivary.dual_left : Antivary f g → Monovary (to_dual ∘ f) g :=
  id
#align antivary.dual_left Antivary.dual_left

theorem Monovary.dual_right : Monovary f g → Antivary f (to_dual ∘ g) :=
  swap
#align monovary.dual_right Monovary.dual_right

theorem Antivary.dual_right : Antivary f g → Monovary f (to_dual ∘ g) :=
  swap
#align antivary.dual_right Antivary.dual_right

theorem MonovaryOn.dual : MonovaryOn f g s → MonovaryOn (to_dual ∘ f) (to_dual ∘ g) s :=
  swap₂
#align monovary_on.dual MonovaryOn.dual

theorem AntivaryOn.dual : AntivaryOn f g s → AntivaryOn (to_dual ∘ f) (to_dual ∘ g) s :=
  swap₂
#align antivary_on.dual AntivaryOn.dual

theorem MonovaryOn.dual_left : MonovaryOn f g s → AntivaryOn (to_dual ∘ f) g s :=
  id
#align monovary_on.dual_left MonovaryOn.dual_left

theorem AntivaryOn.dual_left : AntivaryOn f g s → MonovaryOn (to_dual ∘ f) g s :=
  id
#align antivary_on.dual_left AntivaryOn.dual_left

theorem MonovaryOn.dual_right : MonovaryOn f g s → AntivaryOn f (to_dual ∘ g) s :=
  swap₂
#align monovary_on.dual_right MonovaryOn.dual_right

theorem AntivaryOn.dual_right : AntivaryOn f g s → MonovaryOn f (to_dual ∘ g) s :=
  swap₂
#align antivary_on.dual_right AntivaryOn.dual_right

@[simp]
theorem monovary_to_dual_left : Monovary (to_dual ∘ f) g ↔ Antivary f g :=
  Iff.rfl
#align monovary_to_dual_left monovary_to_dual_left

@[simp]
theorem monovary_to_dual_right : Monovary f (to_dual ∘ g) ↔ Antivary f g :=
  forall_swap
#align monovary_to_dual_right monovary_to_dual_right

@[simp]
theorem antivary_to_dual_left : Antivary (to_dual ∘ f) g ↔ Monovary f g :=
  Iff.rfl
#align antivary_to_dual_left antivary_to_dual_left

@[simp]
theorem antivary_to_dual_right : Antivary f (to_dual ∘ g) ↔ Monovary f g :=
  forall_swap
#align antivary_to_dual_right antivary_to_dual_right

@[simp]
theorem monovary_on_to_dual_left : MonovaryOn (to_dual ∘ f) g s ↔ AntivaryOn f g s :=
  Iff.rfl
#align monovary_on_to_dual_left monovary_on_to_dual_left

@[simp]
theorem monovary_on_to_dual_right : MonovaryOn f (to_dual ∘ g) s ↔ AntivaryOn f g s :=
  forall₂_swap
#align monovary_on_to_dual_right monovary_on_to_dual_right

@[simp]
theorem antivary_on_to_dual_left : AntivaryOn (to_dual ∘ f) g s ↔ MonovaryOn f g s :=
  Iff.rfl
#align antivary_on_to_dual_left antivary_on_to_dual_left

@[simp]
theorem antivary_on_to_dual_right : AntivaryOn f (to_dual ∘ g) s ↔ MonovaryOn f g s :=
  forall₂_swap
#align antivary_on_to_dual_right antivary_on_to_dual_right

end OrderDual

section PartialOrder

variable [PartialOrder ι]

@[simp]
theorem monovary_id_iff : Monovary f id ↔ Monotone f :=
  monotone_iff_forall_lt.symm
#align monovary_id_iff monovary_id_iff

@[simp]
theorem antivary_id_iff : Antivary f id ↔ Antitone f :=
  antitone_iff_forall_lt.symm
#align antivary_id_iff antivary_id_iff

@[simp]
theorem monovary_on_id_iff : MonovaryOn f id s ↔ MonotoneOn f s :=
  monotoneOn_iff_forall_lt.symm
#align monovary_on_id_iff monovary_on_id_iff

@[simp]
theorem antivary_on_id_iff : AntivaryOn f id s ↔ AntitoneOn f s :=
  antitoneOn_iff_forall_lt.symm
#align antivary_on_id_iff antivary_on_id_iff

end PartialOrder

variable [LinearOrder ι]

protected theorem Monotone.monovary (hf : Monotone f) (hg : Monotone g) : Monovary f g :=
  fun i j hij => hf (hg.reflect_lt hij).le
#align monotone.monovary Monotone.monovary

protected theorem Monotone.antivary (hf : Monotone f) (hg : Antitone g) : Antivary f g :=
  (hf.Monovary hg.dual_right).dual_right
#align monotone.antivary Monotone.antivary

protected theorem Antitone.monovary (hf : Antitone f) (hg : Antitone g) : Monovary f g :=
  (hf.dual_right.Antivary hg).dual_left
#align antitone.monovary Antitone.monovary

protected theorem Antitone.antivary (hf : Antitone f) (hg : Monotone g) : Antivary f g :=
  (hf.Monovary hg.dual_right).dual_right
#align antitone.antivary Antitone.antivary

protected theorem MonotoneOn.monovary_on (hf : MonotoneOn f s) (hg : MonotoneOn g s) :
    MonovaryOn f g s := fun i hi j hj hij => hf hi hj (hg.reflect_lt hi hj hij).le
#align monotone_on.monovary_on MonotoneOn.monovary_on

protected theorem MonotoneOn.antivary_on (hf : MonotoneOn f s) (hg : AntitoneOn g s) :
    AntivaryOn f g s :=
  (hf.MonovaryOn hg.dual_right).dual_right
#align monotone_on.antivary_on MonotoneOn.antivary_on

protected theorem AntitoneOn.monovary_on (hf : AntitoneOn f s) (hg : AntitoneOn g s) :
    MonovaryOn f g s :=
  (hf.dual_right.AntivaryOn hg).dual_left
#align antitone_on.monovary_on AntitoneOn.monovary_on

protected theorem AntitoneOn.antivary_on (hf : AntitoneOn f s) (hg : MonotoneOn g s) :
    AntivaryOn f g s :=
  (hf.MonovaryOn hg.dual_right).dual_right
#align antitone_on.antivary_on AntitoneOn.antivary_on

end Preorder

section LinearOrder

variable [Preorder α] [LinearOrder β] [Preorder γ] {f : ι → α} {f' : α → γ} {g : ι → β} {g' : β → γ}
  {s : Set ι}

theorem MonovaryOn.comp_monotone_on_right (h : MonovaryOn f g s) (hg : MonotoneOn g' (g '' s)) :
    MonovaryOn f (g' ∘ g) s := fun i hi j hj hij =>
  h hi hj <| hg.reflect_lt (mem_image_of_mem _ hi) (mem_image_of_mem _ hj) hij
#align monovary_on.comp_monotone_on_right MonovaryOn.comp_monotone_on_right

theorem MonovaryOn.comp_antitone_on_right (h : MonovaryOn f g s) (hg : AntitoneOn g' (g '' s)) :
    AntivaryOn f (g' ∘ g) s := fun i hi j hj hij =>
  h hj hi <| hg.reflect_lt (mem_image_of_mem _ hi) (mem_image_of_mem _ hj) hij
#align monovary_on.comp_antitone_on_right MonovaryOn.comp_antitone_on_right

theorem AntivaryOn.comp_monotone_on_right (h : AntivaryOn f g s) (hg : MonotoneOn g' (g '' s)) :
    AntivaryOn f (g' ∘ g) s := fun i hi j hj hij =>
  h hi hj <| hg.reflect_lt (mem_image_of_mem _ hi) (mem_image_of_mem _ hj) hij
#align antivary_on.comp_monotone_on_right AntivaryOn.comp_monotone_on_right

theorem AntivaryOn.comp_antitone_on_right (h : AntivaryOn f g s) (hg : AntitoneOn g' (g '' s)) :
    MonovaryOn f (g' ∘ g) s := fun i hi j hj hij =>
  h hj hi <| hg.reflect_lt (mem_image_of_mem _ hi) (mem_image_of_mem _ hj) hij
#align antivary_on.comp_antitone_on_right AntivaryOn.comp_antitone_on_right

protected theorem Monovary.symm (h : Monovary f g) : Monovary g f := fun i j hf =>
  le_of_not_lt fun hg => hf.not_le <| h hg
#align monovary.symm Monovary.symm

protected theorem Antivary.symm (h : Antivary f g) : Antivary g f := fun i j hf =>
  le_of_not_lt fun hg => hf.not_le <| h hg
#align antivary.symm Antivary.symm

protected theorem MonovaryOn.symm (h : MonovaryOn f g s) : MonovaryOn g f s := fun i hi j hj hf =>
  le_of_not_lt fun hg => hf.not_le <| h hj hi hg
#align monovary_on.symm MonovaryOn.symm

protected theorem AntivaryOn.symm (h : AntivaryOn f g s) : AntivaryOn g f s := fun i hi j hj hf =>
  le_of_not_lt fun hg => hf.not_le <| h hi hj hg
#align antivary_on.symm AntivaryOn.symm

end LinearOrder

section LinearOrder

variable [LinearOrder α] [LinearOrder β] {f : ι → α} {g : ι → β} {s : Set ι}

protected theorem monovary_comm : Monovary f g ↔ Monovary g f :=
  ⟨Monovary.symm, Monovary.symm⟩
#align monovary_comm monovary_comm

protected theorem antivary_comm : Antivary f g ↔ Antivary g f :=
  ⟨Antivary.symm, Antivary.symm⟩
#align antivary_comm antivary_comm

protected theorem monovary_on_comm : MonovaryOn f g s ↔ MonovaryOn g f s :=
  ⟨MonovaryOn.symm, MonovaryOn.symm⟩
#align monovary_on_comm monovary_on_comm

protected theorem antivary_on_comm : AntivaryOn f g s ↔ AntivaryOn g f s :=
  ⟨AntivaryOn.symm, AntivaryOn.symm⟩
#align antivary_on_comm antivary_on_comm

end LinearOrder

