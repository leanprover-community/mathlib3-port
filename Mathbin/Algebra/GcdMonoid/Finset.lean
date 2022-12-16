/-
Copyright (c) 2020 Aaron Anderson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson

! This file was ported from Lean 3 source module algebra.gcd_monoid.finset
! leanprover-community/mathlib commit d012cd09a9b256d870751284dd6a29882b0be105
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finset.Fold
import Mathbin.Algebra.GcdMonoid.Multiset

/-!
# GCD and LCM operations on finsets

## Main definitions

- `finset.gcd` - the greatest common denominator of a `finset` of elements of a `gcd_monoid`
- `finset.lcm` - the least common multiple of a `finset` of elements of a `gcd_monoid`

## Implementation notes

Many of the proofs use the lemmas `gcd.def` and `lcm.def`, which relate `finset.gcd`
and `finset.lcm` to `multiset.gcd` and `multiset.lcm`.

TODO: simplify with a tactic and `data.finset.lattice`

## Tags

finset, gcd
-/


variable {α β γ : Type _}

namespace Finset

open Multiset

variable [CancelCommMonoidWithZero α] [NormalizedGcdMonoid α]

/-! ### lcm -/


section Lcm

/-- Least common multiple of a finite set -/
def lcm (s : Finset β) (f : β → α) : α :=
  s.fold GcdMonoid.lcm 1 f
#align finset.lcm Finset.lcm

variable {s s₁ s₂ : Finset β} {f : β → α}

theorem lcm_def : s.lcm f = (s.1.map f).lcm :=
  rfl
#align finset.lcm_def Finset.lcm_def

@[simp]
theorem lcm_empty : (∅ : Finset β).lcm f = 1 :=
  fold_empty
#align finset.lcm_empty Finset.lcm_empty

@[simp]
theorem lcm_dvd_iff {a : α} : s.lcm f ∣ a ↔ ∀ b ∈ s, f b ∣ a := by
  apply Iff.trans Multiset.lcm_dvd
  simp only [Multiset.mem_map, and_imp, exists_imp]
  exact ⟨fun k b hb => k _ _ hb rfl, fun k a' b hb h => h ▸ k _ hb⟩
#align finset.lcm_dvd_iff Finset.lcm_dvd_iff

theorem lcm_dvd {a : α} : (∀ b ∈ s, f b ∣ a) → s.lcm f ∣ a :=
  lcm_dvd_iff.2
#align finset.lcm_dvd Finset.lcm_dvd

theorem dvd_lcm {b : β} (hb : b ∈ s) : f b ∣ s.lcm f :=
  lcm_dvd_iff.1 dvd_rfl _ hb
#align finset.dvd_lcm Finset.dvd_lcm

@[simp]
theorem lcm_insert [DecidableEq β] {b : β} :
    (insert b s : Finset β).lcm f = GcdMonoid.lcm (f b) (s.lcm f) := by
  by_cases h : b ∈ s
  ·
    rw [insert_eq_of_mem h,
      (lcm_eq_right_iff (f b) (s.lcm f) (Multiset.normalize_lcm (s.1.map f))).2 (dvd_lcm h)]
  apply fold_insert h
#align finset.lcm_insert Finset.lcm_insert

@[simp]
theorem lcm_singleton {b : β} : ({b} : Finset β).lcm f = normalize (f b) :=
  Multiset.lcm_singleton
#align finset.lcm_singleton Finset.lcm_singleton

@[simp]
theorem normalize_lcm : normalize (s.lcm f) = s.lcm f := by simp [lcm_def]
#align finset.normalize_lcm Finset.normalize_lcm

theorem lcm_union [DecidableEq β] : (s₁ ∪ s₂).lcm f = GcdMonoid.lcm (s₁.lcm f) (s₂.lcm f) :=
  (Finset.induction_on s₁ (by rw [empty_union, lcm_empty, lcm_one_left, normalize_lcm]))
    fun a s has ih => by rw [insert_union, lcm_insert, lcm_insert, ih, lcm_assoc]
#align finset.lcm_union Finset.lcm_union

theorem lcm_congr {f g : β → α} (hs : s₁ = s₂) (hfg : ∀ a ∈ s₂, f a = g a) : s₁.lcm f = s₂.lcm g :=
  by 
  subst hs
  exact Finset.fold_congr hfg
#align finset.lcm_congr Finset.lcm_congr

theorem lcm_mono_fun {g : β → α} (h : ∀ b ∈ s, f b ∣ g b) : s.lcm f ∣ s.lcm g :=
  lcm_dvd fun b hb => (h b hb).trans (dvd_lcm hb)
#align finset.lcm_mono_fun Finset.lcm_mono_fun

theorem lcm_mono (h : s₁ ⊆ s₂) : s₁.lcm f ∣ s₂.lcm f :=
  lcm_dvd fun b hb => dvd_lcm (h hb)
#align finset.lcm_mono Finset.lcm_mono

theorem lcm_image [DecidableEq β] {g : γ → β} (s : Finset γ) : (s.image g).lcm f = s.lcm (f ∘ g) :=
  by classical induction' s using Finset.induction with c s hc ih <;> simp [*]
#align finset.lcm_image Finset.lcm_image

theorem lcm_eq_lcm_image [DecidableEq α] : s.lcm f = (s.image f).lcm id :=
  Eq.symm <| lcm_image _
#align finset.lcm_eq_lcm_image Finset.lcm_eq_lcm_image

theorem lcm_eq_zero_iff [Nontrivial α] : s.lcm f = 0 ↔ 0 ∈ f '' s := by
  simp only [Multiset.mem_map, lcm_def, Multiset.lcm_eq_zero_iff, Set.mem_image, mem_coe, ←
    Finset.mem_def]
#align finset.lcm_eq_zero_iff Finset.lcm_eq_zero_iff

end Lcm

/-! ### gcd -/


section Gcd

/-- Greatest common divisor of a finite set -/
def gcd (s : Finset β) (f : β → α) : α :=
  s.fold GcdMonoid.gcd 0 f
#align finset.gcd Finset.gcd

variable {s s₁ s₂ : Finset β} {f : β → α}

theorem gcd_def : s.gcd f = (s.1.map f).gcd :=
  rfl
#align finset.gcd_def Finset.gcd_def

@[simp]
theorem gcd_empty : (∅ : Finset β).gcd f = 0 :=
  fold_empty
#align finset.gcd_empty Finset.gcd_empty

theorem dvd_gcd_iff {a : α} : a ∣ s.gcd f ↔ ∀ b ∈ s, a ∣ f b := by
  apply Iff.trans Multiset.dvd_gcd
  simp only [Multiset.mem_map, and_imp, exists_imp]
  exact ⟨fun k b hb => k _ _ hb rfl, fun k a' b hb h => h ▸ k _ hb⟩
#align finset.dvd_gcd_iff Finset.dvd_gcd_iff

theorem gcd_dvd {b : β} (hb : b ∈ s) : s.gcd f ∣ f b :=
  dvd_gcd_iff.1 dvd_rfl _ hb
#align finset.gcd_dvd Finset.gcd_dvd

theorem dvd_gcd {a : α} : (∀ b ∈ s, a ∣ f b) → a ∣ s.gcd f :=
  dvd_gcd_iff.2
#align finset.dvd_gcd Finset.dvd_gcd

@[simp]
theorem gcd_insert [DecidableEq β] {b : β} :
    (insert b s : Finset β).gcd f = GcdMonoid.gcd (f b) (s.gcd f) := by
  by_cases h : b ∈ s
  ·
    rw [insert_eq_of_mem h,
      (gcd_eq_right_iff (f b) (s.gcd f) (Multiset.normalize_gcd (s.1.map f))).2 (gcd_dvd h)]
  apply fold_insert h
#align finset.gcd_insert Finset.gcd_insert

@[simp]
theorem gcd_singleton {b : β} : ({b} : Finset β).gcd f = normalize (f b) :=
  Multiset.gcd_singleton
#align finset.gcd_singleton Finset.gcd_singleton

@[simp]
theorem normalize_gcd : normalize (s.gcd f) = s.gcd f := by simp [gcd_def]
#align finset.normalize_gcd Finset.normalize_gcd

theorem gcd_union [DecidableEq β] : (s₁ ∪ s₂).gcd f = GcdMonoid.gcd (s₁.gcd f) (s₂.gcd f) :=
  (Finset.induction_on s₁ (by rw [empty_union, gcd_empty, gcd_zero_left, normalize_gcd]))
    fun a s has ih => by rw [insert_union, gcd_insert, gcd_insert, ih, gcd_assoc]
#align finset.gcd_union Finset.gcd_union

theorem gcd_congr {f g : β → α} (hs : s₁ = s₂) (hfg : ∀ a ∈ s₂, f a = g a) : s₁.gcd f = s₂.gcd g :=
  by 
  subst hs
  exact Finset.fold_congr hfg
#align finset.gcd_congr Finset.gcd_congr

theorem gcd_mono_fun {g : β → α} (h : ∀ b ∈ s, f b ∣ g b) : s.gcd f ∣ s.gcd g :=
  dvd_gcd fun b hb => (gcd_dvd hb).trans (h b hb)
#align finset.gcd_mono_fun Finset.gcd_mono_fun

theorem gcd_mono (h : s₁ ⊆ s₂) : s₂.gcd f ∣ s₁.gcd f :=
  dvd_gcd fun b hb => gcd_dvd (h hb)
#align finset.gcd_mono Finset.gcd_mono

theorem gcd_image [DecidableEq β] {g : γ → β} (s : Finset γ) : (s.image g).gcd f = s.gcd (f ∘ g) :=
  by classical induction' s using Finset.induction with c s hc ih <;> simp [*]
#align finset.gcd_image Finset.gcd_image

theorem gcd_eq_gcd_image [DecidableEq α] : s.gcd f = (s.image f).gcd id :=
  Eq.symm <| gcd_image _
#align finset.gcd_eq_gcd_image Finset.gcd_eq_gcd_image

theorem gcd_eq_zero_iff : s.gcd f = 0 ↔ ∀ x : β, x ∈ s → f x = 0 := by
  rw [gcd_def, Multiset.gcd_eq_zero_iff]
  constructor <;> intro h
  · intro b bs
    apply h (f b)
    simp only [Multiset.mem_map, mem_def.1 bs]
    use b
    simp [mem_def.1 bs]
  · intro a as
    rw [Multiset.mem_map] at as
    rcases as with ⟨b, ⟨bs, rfl⟩⟩
    apply h b (mem_def.1 bs)
#align finset.gcd_eq_zero_iff Finset.gcd_eq_zero_iff

theorem gcd_eq_gcd_filter_ne_zero [DecidablePred fun x : β => f x = 0] :
    s.gcd f = (s.filter fun x => f x ≠ 0).gcd f := by
  classical 
    trans ((s.filter fun x => f x = 0) ∪ s.filter fun x => f x ≠ 0).gcd f
    · rw [filter_union_filter_neg_eq]
    rw [gcd_union]
    trans GcdMonoid.gcd (0 : α) _
    · refine' congr (congr rfl _) rfl
      apply s.induction_on
      · simp
      intro a s has h
      rw [filter_insert]
      split_ifs with h1 <;> simp [h, h1]
    simp [gcd_zero_left, normalize_gcd]
#align finset.gcd_eq_gcd_filter_ne_zero Finset.gcd_eq_gcd_filter_ne_zero

theorem gcd_mul_left {a : α} : (s.gcd fun x => a * f x) = normalize a * s.gcd f := by
  classical 
    apply s.induction_on
    · simp
    intro b t hbt h
    rw [gcd_insert, gcd_insert, h, ← gcd_mul_left]
    apply ((normalize_associated a).mulRight _).gcd_eq_right
#align finset.gcd_mul_left Finset.gcd_mul_left

theorem gcd_mul_right {a : α} : (s.gcd fun x => f x * a) = s.gcd f * normalize a := by
  classical 
    apply s.induction_on
    · simp
    intro b t hbt h
    rw [gcd_insert, gcd_insert, h, ← gcd_mul_right]
    apply ((normalize_associated a).mulLeft _).gcd_eq_right
#align finset.gcd_mul_right Finset.gcd_mul_right

theorem extract_gcd' (f g : β → α) (hs : ∃ x, x ∈ s ∧ f x ≠ 0) (hg : ∀ b ∈ s, f b = s.gcd f * g b) :
    s.gcd g = 1 :=
  ((@mul_right_eq_self₀ _ _ (s.gcd f) _).1 <| by
        conv_lhs => rw [← normalize_gcd, ← gcd_mul_left, ← gcd_congr rfl hg]).resolve_right <|
    by 
    contrapose! hs
    exact gcd_eq_zero_iff.1 hs
#align finset.extract_gcd' Finset.extract_gcd'

theorem extract_gcd (f : β → α) (hs : s.Nonempty) :
    ∃ g : β → α, (∀ b ∈ s, f b = s.gcd f * g b) ∧ s.gcd g = 1 := by
  classical 
    by_cases h : ∀ x ∈ s, f x = (0 : α)
    · refine' ⟨fun b => 1, fun b hb => by rw [h b hb, gcd_eq_zero_iff.2 h, mul_one], _⟩
      rw [gcd_eq_gcd_image, image_const hs, gcd_singleton, id, normalize_one]
    · choose g' hg using @gcd_dvd _ _ _ _ s f
      have := fun b hb => _
      push_neg  at h
      refine' ⟨fun b => if hb : b ∈ s then g' hb else 0, this, extract_gcd' f _ h this⟩
      rw [dif_pos hb, hg hb]
#align finset.extract_gcd Finset.extract_gcd

end Gcd

end Finset

namespace Finset

section IsDomain

variable [CommRing α] [IsDomain α] [NormalizedGcdMonoid α]

theorem gcd_eq_of_dvd_sub {s : Finset β} {f g : β → α} {a : α}
    (h : ∀ x : β, x ∈ s → a ∣ f x - g x) : GcdMonoid.gcd a (s.gcd f) = GcdMonoid.gcd a (s.gcd g) :=
  by
  classical 
    revert h
    apply s.induction_on
    · simp
    intro b s bs hi h
    rw [gcd_insert, gcd_insert, gcd_comm (f b), ← gcd_assoc,
      hi fun x hx => h _ (mem_insert_of_mem hx), gcd_comm a, gcd_assoc,
      gcd_comm a (GcdMonoid.gcd _ _), gcd_comm (g b), gcd_assoc _ _ a, gcd_comm _ a]
    exact congr_arg _ (gcd_eq_of_dvd_sub_right (h _ (mem_insert_self _ _)))
#align finset.gcd_eq_of_dvd_sub Finset.gcd_eq_of_dvd_sub

end IsDomain

end Finset

