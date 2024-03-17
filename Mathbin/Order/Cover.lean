/-
Copyright (c) 2021 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Violeta Hernández Palacios, Grayson Burton, Floris van Doorn
-/
import Data.Set.Intervals.OrdConnected
import Order.Antisymmetrization

#align_import order.cover from "leanprover-community/mathlib"@"c3291da49cfa65f0d43b094750541c0731edc932"

/-!
# The covering relation

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the covering relation in an order. `b` is said to cover `a` if `a < b` and there
is no element in between. We say that `b` weakly covers `a` if `a ≤ b` and there is no element
between `a` and `b`. In a partial order this is equivalent to `a ⋖ b ∨ a = b`, in a preorder this
is equivalent to `a ⋖ b ∨ (a ≤ b ∧ b ≤ a)`

## Notation

* `a ⋖ b` means that `b` covers `a`.
* `a ⩿ b` means that `b` weakly covers `a`.
-/


open Set OrderDual

variable {α β : Type _}

section WeaklyCovers

section Preorder

variable [Preorder α] [Preorder β] {a b c : α}

#print WCovBy /-
/-- `wcovby a b` means that `a = b` or `b` covers `a`.
This means that `a ≤ b` and there is no element in between.
-/
def WCovBy (a b : α) : Prop :=
  a ≤ b ∧ ∀ ⦃c⦄, a < c → ¬c < b
#align wcovby WCovBy
-/

infixl:50 " ⩿ " => WCovBy

#print WCovBy.le /-
theorem WCovBy.le (h : a ⩿ b) : a ≤ b :=
  h.1
#align wcovby.le WCovBy.le
-/

#print WCovBy.refl /-
theorem WCovBy.refl (a : α) : a ⩿ a :=
  ⟨le_rfl, fun c hc => hc.not_lt⟩
#align wcovby.refl WCovBy.refl
-/

#print WCovBy.rfl /-
theorem WCovBy.rfl : a ⩿ a :=
  WCovBy.refl a
#align wcovby.rfl WCovBy.rfl
-/

#print Eq.wcovBy /-
protected theorem Eq.wcovBy (h : a = b) : a ⩿ b :=
  h ▸ WCovBy.rfl
#align eq.wcovby Eq.wcovBy
-/

#print wcovBy_of_le_of_le /-
theorem wcovBy_of_le_of_le (h1 : a ≤ b) (h2 : b ≤ a) : a ⩿ b :=
  ⟨h1, fun c hac hcb => (hac.trans hcb).not_le h2⟩
#align wcovby_of_le_of_le wcovBy_of_le_of_le
-/

alias LE.le.wCovBy_of_le := wcovBy_of_le_of_le
#align has_le.le.wcovby_of_le LE.le.wCovBy_of_le

#print AntisymmRel.wcovBy /-
theorem AntisymmRel.wcovBy (h : AntisymmRel (· ≤ ·) a b) : a ⩿ b :=
  wcovBy_of_le_of_le h.1 h.2
#align antisymm_rel.wcovby AntisymmRel.wcovBy
-/

#print WCovBy.wcovBy_iff_le /-
theorem WCovBy.wcovBy_iff_le (hab : a ⩿ b) : b ⩿ a ↔ b ≤ a :=
  ⟨fun h => h.le, fun h => h.wCovBy_of_le hab.le⟩
#align wcovby.wcovby_iff_le WCovBy.wcovBy_iff_le
-/

#print wcovBy_of_eq_or_eq /-
theorem wcovBy_of_eq_or_eq (hab : a ≤ b) (h : ∀ c, a ≤ c → c ≤ b → c = a ∨ c = b) : a ⩿ b :=
  ⟨hab, fun c ha hb => (h c ha.le hb.le).elim ha.ne' hb.Ne⟩
#align wcovby_of_eq_or_eq wcovBy_of_eq_or_eq
-/

#print AntisymmRel.trans_wcovBy /-
theorem AntisymmRel.trans_wcovBy (hab : AntisymmRel (· ≤ ·) a b) (hbc : b ⩿ c) : a ⩿ c :=
  ⟨hab.1.trans hbc.le, fun d had hdc => hbc.2 (hab.2.trans_lt had) hdc⟩
#align antisymm_rel.trans_wcovby AntisymmRel.trans_wcovBy
-/

#print wcovBy_congr_left /-
theorem wcovBy_congr_left (hab : AntisymmRel (· ≤ ·) a b) : a ⩿ c ↔ b ⩿ c :=
  ⟨hab.symm.trans_wcovBy, hab.trans_wcovBy⟩
#align wcovby_congr_left wcovBy_congr_left
-/

#print WCovBy.trans_antisymm_rel /-
theorem WCovBy.trans_antisymm_rel (hab : a ⩿ b) (hbc : AntisymmRel (· ≤ ·) b c) : a ⩿ c :=
  ⟨hab.le.trans hbc.1, fun d had hdc => hab.2 had <| hdc.trans_le hbc.2⟩
#align wcovby.trans_antisymm_rel WCovBy.trans_antisymm_rel
-/

#print wcovBy_congr_right /-
theorem wcovBy_congr_right (hab : AntisymmRel (· ≤ ·) a b) : c ⩿ a ↔ c ⩿ b :=
  ⟨fun h => h.trans_antisymm_rel hab, fun h => h.trans_antisymm_rel hab.symm⟩
#align wcovby_congr_right wcovBy_congr_right
-/

#print not_wcovBy_iff /-
/-- If `a ≤ b`, then `b` does not cover `a` iff there's an element in between. -/
theorem not_wcovBy_iff (h : a ≤ b) : ¬a ⩿ b ↔ ∃ c, a < c ∧ c < b := by
  simp_rw [WCovBy, h, true_and_iff, Classical.not_forall, exists_prop, Classical.not_not]
#align not_wcovby_iff not_wcovBy_iff
-/

#print WCovBy.isRefl /-
instance WCovBy.isRefl : IsRefl α (· ⩿ ·) :=
  ⟨WCovBy.refl⟩
#align wcovby.is_refl WCovBy.isRefl
-/

#print WCovBy.Ioo_eq /-
theorem WCovBy.Ioo_eq (h : a ⩿ b) : Ioo a b = ∅ :=
  eq_empty_iff_forall_not_mem.2 fun x hx => h.2 hx.1 hx.2
#align wcovby.Ioo_eq WCovBy.Ioo_eq
-/

#print wcovBy_iff_Ioo_eq /-
theorem wcovBy_iff_Ioo_eq : a ⩿ b ↔ a ≤ b ∧ Ioo a b = ∅ :=
  and_congr_right' <| by simp [eq_empty_iff_forall_not_mem]
#align wcovby_iff_Ioo_eq wcovBy_iff_Ioo_eq
-/

#print WCovBy.of_image /-
theorem WCovBy.of_image (f : α ↪o β) (h : f a ⩿ f b) : a ⩿ b :=
  ⟨f.le_iff_le.mp h.le, fun c hac hcb => h.2 (f.lt_iff_lt.mpr hac) (f.lt_iff_lt.mpr hcb)⟩
#align wcovby.of_image WCovBy.of_image
-/

#print WCovBy.image /-
theorem WCovBy.image (f : α ↪o β) (hab : a ⩿ b) (h : (range f).OrdConnected) : f a ⩿ f b :=
  by
  refine' ⟨f.monotone hab.le, fun c ha hb => _⟩
  obtain ⟨c, rfl⟩ := h.out (mem_range_self _) (mem_range_self _) ⟨ha.le, hb.le⟩
  rw [f.lt_iff_lt] at ha hb
  exact hab.2 ha hb
#align wcovby.image WCovBy.image
-/

#print Set.OrdConnected.apply_wcovBy_apply_iff /-
theorem Set.OrdConnected.apply_wcovBy_apply_iff (f : α ↪o β) (h : (range f).OrdConnected) :
    f a ⩿ f b ↔ a ⩿ b :=
  ⟨fun h2 => h2.of_image f, fun hab => hab.image f h⟩
#align set.ord_connected.apply_wcovby_apply_iff Set.OrdConnected.apply_wcovBy_apply_iff
-/

#print apply_wcovBy_apply_iff /-
@[simp]
theorem apply_wcovBy_apply_iff {E : Type _} [OrderIsoClass E α β] (e : E) : e a ⩿ e b ↔ a ⩿ b :=
  (ordConnected_range (e : α ≃o β)).apply_wcovBy_apply_iff ((e : α ≃o β) : α ↪o β)
#align apply_wcovby_apply_iff apply_wcovBy_apply_iff
-/

#print toDual_wcovBy_toDual_iff /-
@[simp]
theorem toDual_wcovBy_toDual_iff : toDual b ⩿ toDual a ↔ a ⩿ b :=
  and_congr_right' <| forall_congr' fun c => forall_swap
#align to_dual_wcovby_to_dual_iff toDual_wcovBy_toDual_iff
-/

#print ofDual_wcovBy_ofDual_iff /-
@[simp]
theorem ofDual_wcovBy_ofDual_iff {a b : αᵒᵈ} : ofDual a ⩿ ofDual b ↔ b ⩿ a :=
  and_congr_right' <| forall_congr' fun c => forall_swap
#align of_dual_wcovby_of_dual_iff ofDual_wcovBy_ofDual_iff
-/

alias ⟨_, WCovBy.toDual⟩ := toDual_wcovBy_toDual_iff
#align wcovby.to_dual WCovBy.toDual

alias ⟨_, WCovBy.ofDual⟩ := ofDual_wcovBy_ofDual_iff
#align wcovby.of_dual WCovBy.ofDual

end Preorder

section PartialOrder

variable [PartialOrder α] {a b c : α}

#print WCovBy.eq_or_eq /-
theorem WCovBy.eq_or_eq (h : a ⩿ b) (h2 : a ≤ c) (h3 : c ≤ b) : c = a ∨ c = b :=
  by
  rcases h2.eq_or_lt with (h2 | h2); · exact Or.inl h2.symm
  rcases h3.eq_or_lt with (h3 | h3); · exact Or.inr h3
  exact (h.2 h2 h3).elim
#align wcovby.eq_or_eq WCovBy.eq_or_eq
-/

#print wcovBy_iff_le_and_eq_or_eq /-
/-- An `iff` version of `wcovby.eq_or_eq` and `wcovby_of_eq_or_eq`. -/
theorem wcovBy_iff_le_and_eq_or_eq : a ⩿ b ↔ a ≤ b ∧ ∀ c, a ≤ c → c ≤ b → c = a ∨ c = b :=
  ⟨fun h => ⟨h.le, fun c => h.eq_or_eq⟩, And.ndrec wcovBy_of_eq_or_eq⟩
#align wcovby_iff_le_and_eq_or_eq wcovBy_iff_le_and_eq_or_eq
-/

#print WCovBy.le_and_le_iff /-
theorem WCovBy.le_and_le_iff (h : a ⩿ b) : a ≤ c ∧ c ≤ b ↔ c = a ∨ c = b := by
  refine' ⟨fun h2 => h.eq_or_eq h2.1 h2.2, _⟩; rintro (rfl | rfl);
  exacts [⟨le_rfl, h.le⟩, ⟨h.le, le_rfl⟩]
#align wcovby.le_and_le_iff WCovBy.le_and_le_iff
-/

#print WCovBy.Icc_eq /-
theorem WCovBy.Icc_eq (h : a ⩿ b) : Icc a b = {a, b} := by ext c; exact h.le_and_le_iff
#align wcovby.Icc_eq WCovBy.Icc_eq
-/

#print WCovBy.Ico_subset /-
theorem WCovBy.Ico_subset (h : a ⩿ b) : Ico a b ⊆ {a} := by
  rw [← Icc_diff_right, h.Icc_eq, diff_singleton_subset_iff, pair_comm]
#align wcovby.Ico_subset WCovBy.Ico_subset
-/

#print WCovBy.Ioc_subset /-
theorem WCovBy.Ioc_subset (h : a ⩿ b) : Ioc a b ⊆ {b} := by
  rw [← Icc_diff_left, h.Icc_eq, diff_singleton_subset_iff]
#align wcovby.Ioc_subset WCovBy.Ioc_subset
-/

end PartialOrder

section SemilatticeSup

variable [SemilatticeSup α] {a b c : α}

#print WCovBy.sup_eq /-
theorem WCovBy.sup_eq (hac : a ⩿ c) (hbc : b ⩿ c) (hab : a ≠ b) : a ⊔ b = c :=
  (sup_le hac.le hbc.le).eq_of_not_lt fun h =>
    hab.lt_sup_or_lt_sup.elim (fun h' => hac.2 h' h) fun h' => hbc.2 h' h
#align wcovby.sup_eq WCovBy.sup_eq
-/

end SemilatticeSup

section SemilatticeInf

variable [SemilatticeInf α] {a b c : α}

#print WCovBy.inf_eq /-
theorem WCovBy.inf_eq (hca : c ⩿ a) (hcb : c ⩿ b) (hab : a ≠ b) : a ⊓ b = c :=
  (le_inf hca.le hcb.le).eq_of_not_gt fun h => hab.inf_lt_or_inf_lt.elim (hca.2 h) (hcb.2 h)
#align wcovby.inf_eq WCovBy.inf_eq
-/

end SemilatticeInf

end WeaklyCovers

section LT

variable [LT α] {a b : α}

#print CovBy /-
/-- `covby a b` means that `b` covers `a`: `a < b` and there is no element in between. -/
def CovBy (a b : α) : Prop :=
  a < b ∧ ∀ ⦃c⦄, a < c → ¬c < b
#align covby CovBy
-/

infixl:50 " ⋖ " => CovBy

#print CovBy.lt /-
theorem CovBy.lt (h : a ⋖ b) : a < b :=
  h.1
#align covby.lt CovBy.lt
-/

#print not_covBy_iff /-
/-- If `a < b`, then `b` does not cover `a` iff there's an element in between. -/
theorem not_covBy_iff (h : a < b) : ¬a ⋖ b ↔ ∃ c, a < c ∧ c < b := by
  simp_rw [CovBy, h, true_and_iff, Classical.not_forall, exists_prop, Classical.not_not]
#align not_covby_iff not_covBy_iff
-/

alias ⟨exists_lt_lt_of_not_covBy, _⟩ := not_covBy_iff
#align exists_lt_lt_of_not_covby exists_lt_lt_of_not_covBy

alias LT.lt.exists_lt_lt := exists_lt_lt_of_not_covBy
#align has_lt.lt.exists_lt_lt LT.lt.exists_lt_lt

#print not_covBy /-
/-- In a dense order, nothing covers anything. -/
theorem not_covBy [DenselyOrdered α] : ¬a ⋖ b := fun h =>
  let ⟨c, hc⟩ := exists_between h.1
  h.2 hc.1 hc.2
#align not_covby not_covBy
-/

#print densely_ordered_iff_forall_not_covBy /-
theorem densely_ordered_iff_forall_not_covBy : DenselyOrdered α ↔ ∀ a b : α, ¬a ⋖ b :=
  ⟨fun h a b => @not_covBy _ _ _ _ h, fun h =>
    ⟨fun a b hab => exists_lt_lt_of_not_covBy hab <| h _ _⟩⟩
#align densely_ordered_iff_forall_not_covby densely_ordered_iff_forall_not_covBy
-/

#print toDual_covBy_toDual_iff /-
@[simp]
theorem toDual_covBy_toDual_iff : toDual b ⋖ toDual a ↔ a ⋖ b :=
  and_congr_right' <| forall_congr' fun c => forall_swap
#align to_dual_covby_to_dual_iff toDual_covBy_toDual_iff
-/

#print ofDual_covBy_ofDual_iff /-
@[simp]
theorem ofDual_covBy_ofDual_iff {a b : αᵒᵈ} : ofDual a ⋖ ofDual b ↔ b ⋖ a :=
  and_congr_right' <| forall_congr' fun c => forall_swap
#align of_dual_covby_of_dual_iff ofDual_covBy_ofDual_iff
-/

alias ⟨_, CovBy.toDual⟩ := toDual_covBy_toDual_iff
#align covby.to_dual CovBy.toDual

alias ⟨_, CovBy.ofDual⟩ := ofDual_covBy_ofDual_iff
#align covby.of_dual CovBy.ofDual

end LT

section Preorder

variable [Preorder α] [Preorder β] {a b c : α}

#print CovBy.le /-
theorem CovBy.le (h : a ⋖ b) : a ≤ b :=
  h.1.le
#align covby.le CovBy.le
-/

#print CovBy.ne /-
protected theorem CovBy.ne (h : a ⋖ b) : a ≠ b :=
  h.lt.Ne
#align covby.ne CovBy.ne
-/

#print CovBy.ne' /-
theorem CovBy.ne' (h : a ⋖ b) : b ≠ a :=
  h.lt.ne'
#align covby.ne' CovBy.ne'
-/

#print CovBy.wcovBy /-
protected theorem CovBy.wcovBy (h : a ⋖ b) : a ⩿ b :=
  ⟨h.le, h.2⟩
#align covby.wcovby CovBy.wcovBy
-/

#print WCovBy.covBy_of_not_le /-
theorem WCovBy.covBy_of_not_le (h : a ⩿ b) (h2 : ¬b ≤ a) : a ⋖ b :=
  ⟨h.le.lt_of_not_le h2, h.2⟩
#align wcovby.covby_of_not_le WCovBy.covBy_of_not_le
-/

#print WCovBy.covBy_of_lt /-
theorem WCovBy.covBy_of_lt (h : a ⩿ b) (h2 : a < b) : a ⋖ b :=
  ⟨h2, h.2⟩
#align wcovby.covby_of_lt WCovBy.covBy_of_lt
-/

#print not_covBy_of_lt_of_lt /-
theorem not_covBy_of_lt_of_lt (h₁ : a < b) (h₂ : b < c) : ¬a ⋖ c :=
  (not_covBy_iff (h₁.trans h₂)).2 ⟨b, h₁, h₂⟩
#align not_covby_of_lt_of_lt not_covBy_of_lt_of_lt
-/

#print covBy_iff_wcovBy_and_lt /-
theorem covBy_iff_wcovBy_and_lt : a ⋖ b ↔ a ⩿ b ∧ a < b :=
  ⟨fun h => ⟨h.WCovBy, h.lt⟩, fun h => h.1.covBy_of_lt h.2⟩
#align covby_iff_wcovby_and_lt covBy_iff_wcovBy_and_lt
-/

#print covBy_iff_wcovBy_and_not_le /-
theorem covBy_iff_wcovBy_and_not_le : a ⋖ b ↔ a ⩿ b ∧ ¬b ≤ a :=
  ⟨fun h => ⟨h.WCovBy, h.lt.not_le⟩, fun h => h.1.covBy_of_not_le h.2⟩
#align covby_iff_wcovby_and_not_le covBy_iff_wcovBy_and_not_le
-/

#print wcovBy_iff_covBy_or_le_and_le /-
theorem wcovBy_iff_covBy_or_le_and_le : a ⩿ b ↔ a ⋖ b ∨ a ≤ b ∧ b ≤ a :=
  ⟨fun h =>
    Classical.or_iff_not_imp_right.mpr fun h' => h.covBy_of_not_le fun hba => h' ⟨h.le, hba⟩,
    fun h' => h'.elim (fun h => h.WCovBy) fun h => h.1.wCovBy_of_le h.2⟩
#align wcovby_iff_covby_or_le_and_le wcovBy_iff_covBy_or_le_and_le
-/

#print AntisymmRel.trans_covBy /-
theorem AntisymmRel.trans_covBy (hab : AntisymmRel (· ≤ ·) a b) (hbc : b ⋖ c) : a ⋖ c :=
  ⟨hab.1.trans_lt hbc.lt, fun d had hdc => hbc.2 (hab.2.trans_lt had) hdc⟩
#align antisymm_rel.trans_covby AntisymmRel.trans_covBy
-/

#print covBy_congr_left /-
theorem covBy_congr_left (hab : AntisymmRel (· ≤ ·) a b) : a ⋖ c ↔ b ⋖ c :=
  ⟨hab.symm.trans_covBy, hab.trans_covBy⟩
#align covby_congr_left covBy_congr_left
-/

#print CovBy.trans_antisymmRel /-
theorem CovBy.trans_antisymmRel (hab : a ⋖ b) (hbc : AntisymmRel (· ≤ ·) b c) : a ⋖ c :=
  ⟨hab.lt.trans_le hbc.1, fun d had hdb => hab.2 had <| hdb.trans_le hbc.2⟩
#align covby.trans_antisymm_rel CovBy.trans_antisymmRel
-/

#print covBy_congr_right /-
theorem covBy_congr_right (hab : AntisymmRel (· ≤ ·) a b) : c ⋖ a ↔ c ⋖ b :=
  ⟨fun h => h.trans_antisymm_rel hab, fun h => h.trans_antisymm_rel hab.symm⟩
#align covby_congr_right covBy_congr_right
-/

instance : IsNonstrictStrictOrder α (· ⩿ ·) (· ⋖ ·) :=
  ⟨fun a b =>
    covBy_iff_wcovBy_and_not_le.trans <| and_congr_right fun h => h.wcovBy_iff_le.Not.symm⟩

#print CovBy.isIrrefl /-
instance CovBy.isIrrefl : IsIrrefl α (· ⋖ ·) :=
  ⟨fun a ha => ha.Ne rfl⟩
#align covby.is_irrefl CovBy.isIrrefl
-/

#print CovBy.Ioo_eq /-
theorem CovBy.Ioo_eq (h : a ⋖ b) : Ioo a b = ∅ :=
  h.WCovBy.Ioo_eq
#align covby.Ioo_eq CovBy.Ioo_eq
-/

#print covBy_iff_Ioo_eq /-
theorem covBy_iff_Ioo_eq : a ⋖ b ↔ a < b ∧ Ioo a b = ∅ :=
  and_congr_right' <| by simp [eq_empty_iff_forall_not_mem]
#align covby_iff_Ioo_eq covBy_iff_Ioo_eq
-/

#print CovBy.of_image /-
theorem CovBy.of_image (f : α ↪o β) (h : f a ⋖ f b) : a ⋖ b :=
  ⟨f.lt_iff_lt.mp h.lt, fun c hac hcb => h.2 (f.lt_iff_lt.mpr hac) (f.lt_iff_lt.mpr hcb)⟩
#align covby.of_image CovBy.of_image
-/

#print CovBy.image /-
theorem CovBy.image (f : α ↪o β) (hab : a ⋖ b) (h : (range f).OrdConnected) : f a ⋖ f b :=
  (hab.WCovBy.image f h).covBy_of_lt <| f.StrictMono hab.lt
#align covby.image CovBy.image
-/

#print Set.OrdConnected.apply_covBy_apply_iff /-
theorem Set.OrdConnected.apply_covBy_apply_iff (f : α ↪o β) (h : (range f).OrdConnected) :
    f a ⋖ f b ↔ a ⋖ b :=
  ⟨CovBy.of_image f, fun hab => hab.image f h⟩
#align set.ord_connected.apply_covby_apply_iff Set.OrdConnected.apply_covBy_apply_iff
-/

#print apply_covBy_apply_iff /-
@[simp]
theorem apply_covBy_apply_iff {E : Type _} [OrderIsoClass E α β] (e : E) : e a ⋖ e b ↔ a ⋖ b :=
  (ordConnected_range (e : α ≃o β)).apply_covBy_apply_iff ((e : α ≃o β) : α ↪o β)
#align apply_covby_apply_iff apply_covBy_apply_iff
-/

#print covBy_of_eq_or_eq /-
theorem covBy_of_eq_or_eq (hab : a < b) (h : ∀ c, a ≤ c → c ≤ b → c = a ∨ c = b) : a ⋖ b :=
  ⟨hab, fun c ha hb => (h c ha.le hb.le).elim ha.ne' hb.Ne⟩
#align covby_of_eq_or_eq covBy_of_eq_or_eq
-/

end Preorder

section PartialOrder

variable [PartialOrder α] {a b c : α}

#print WCovBy.covBy_of_ne /-
theorem WCovBy.covBy_of_ne (h : a ⩿ b) (h2 : a ≠ b) : a ⋖ b :=
  ⟨h.le.lt_of_ne h2, h.2⟩
#align wcovby.covby_of_ne WCovBy.covBy_of_ne
-/

#print covBy_iff_wcovBy_and_ne /-
theorem covBy_iff_wcovBy_and_ne : a ⋖ b ↔ a ⩿ b ∧ a ≠ b :=
  ⟨fun h => ⟨h.WCovBy, h.Ne⟩, fun h => h.1.covBy_of_ne h.2⟩
#align covby_iff_wcovby_and_ne covBy_iff_wcovBy_and_ne
-/

#print wcovBy_iff_covBy_or_eq /-
theorem wcovBy_iff_covBy_or_eq : a ⩿ b ↔ a ⋖ b ∨ a = b := by
  rw [le_antisymm_iff, wcovBy_iff_covBy_or_le_and_le]
#align wcovby_iff_covby_or_eq wcovBy_iff_covBy_or_eq
-/

#print wcovBy_iff_eq_or_covBy /-
theorem wcovBy_iff_eq_or_covBy : a ⩿ b ↔ a = b ∨ a ⋖ b :=
  wcovBy_iff_covBy_or_eq.trans or_comm
#align wcovby_iff_eq_or_covby wcovBy_iff_eq_or_covBy
-/

alias ⟨WCovBy.covBy_or_eq, _⟩ := wcovBy_iff_covBy_or_eq
#align wcovby.covby_or_eq WCovBy.covBy_or_eq

alias ⟨WCovBy.eq_or_covBy, _⟩ := wcovBy_iff_eq_or_covBy
#align wcovby.eq_or_covby WCovBy.eq_or_covBy

#print CovBy.eq_or_eq /-
theorem CovBy.eq_or_eq (h : a ⋖ b) (h2 : a ≤ c) (h3 : c ≤ b) : c = a ∨ c = b :=
  h.WCovBy.eq_or_eq h2 h3
#align covby.eq_or_eq CovBy.eq_or_eq
-/

#print covBy_iff_lt_and_eq_or_eq /-
/-- An `iff` version of `covby.eq_or_eq` and `covby_of_eq_or_eq`. -/
theorem covBy_iff_lt_and_eq_or_eq : a ⋖ b ↔ a < b ∧ ∀ c, a ≤ c → c ≤ b → c = a ∨ c = b :=
  ⟨fun h => ⟨h.lt, fun c => h.eq_or_eq⟩, And.ndrec covBy_of_eq_or_eq⟩
#align covby_iff_lt_and_eq_or_eq covBy_iff_lt_and_eq_or_eq
-/

#print CovBy.Ico_eq /-
theorem CovBy.Ico_eq (h : a ⋖ b) : Ico a b = {a} := by
  rw [← Ioo_union_left h.lt, h.Ioo_eq, empty_union]
#align covby.Ico_eq CovBy.Ico_eq
-/

#print CovBy.Ioc_eq /-
theorem CovBy.Ioc_eq (h : a ⋖ b) : Ioc a b = {b} := by
  rw [← Ioo_union_right h.lt, h.Ioo_eq, empty_union]
#align covby.Ioc_eq CovBy.Ioc_eq
-/

#print CovBy.Icc_eq /-
theorem CovBy.Icc_eq (h : a ⋖ b) : Icc a b = {a, b} :=
  h.WCovBy.Icc_eq
#align covby.Icc_eq CovBy.Icc_eq
-/

end PartialOrder

section LinearOrder

variable [LinearOrder α] {a b c : α}

#print CovBy.Ioi_eq /-
theorem CovBy.Ioi_eq (h : a ⋖ b) : Ioi a = Ici b := by
  rw [← Ioo_union_Ici_eq_Ioi h.lt, h.Ioo_eq, empty_union]
#align covby.Ioi_eq CovBy.Ioi_eq
-/

#print CovBy.Iio_eq /-
theorem CovBy.Iio_eq (h : a ⋖ b) : Iio b = Iic a := by
  rw [← Iic_union_Ioo_eq_Iio h.lt, h.Ioo_eq, union_empty]
#align covby.Iio_eq CovBy.Iio_eq
-/

#print WCovBy.le_of_lt /-
theorem WCovBy.le_of_lt (hab : a ⩿ b) (hcb : c < b) : c ≤ a :=
  not_lt.1 fun hac => hab.2 hac hcb
#align wcovby.le_of_lt WCovBy.le_of_lt
-/

#print WCovBy.ge_of_gt /-
theorem WCovBy.ge_of_gt (hab : a ⩿ b) (hac : a < c) : b ≤ c :=
  not_lt.1 <| hab.2 hac
#align wcovby.ge_of_gt WCovBy.ge_of_gt
-/

#print CovBy.le_of_lt /-
theorem CovBy.le_of_lt (hab : a ⋖ b) : c < b → c ≤ a :=
  hab.WCovBy.le_of_lt
#align covby.le_of_lt CovBy.le_of_lt
-/

#print CovBy.ge_of_gt /-
theorem CovBy.ge_of_gt (hab : a ⋖ b) : a < c → b ≤ c :=
  hab.WCovBy.ge_of_gt
#align covby.ge_of_gt CovBy.ge_of_gt
-/

#print CovBy.unique_left /-
theorem CovBy.unique_left (ha : a ⋖ c) (hb : b ⋖ c) : a = b :=
  (hb.le_of_lt ha.lt).antisymm <| ha.le_of_lt hb.lt
#align covby.unique_left CovBy.unique_left
-/

#print CovBy.unique_right /-
theorem CovBy.unique_right (hb : a ⋖ b) (hc : a ⋖ c) : b = c :=
  (hb.ge_of_gt hc.lt).antisymm <| hc.ge_of_gt hb.lt
#align covby.unique_right CovBy.unique_right
-/

#print CovBy.eq_of_between /-
/-- If `a`, `b`, `c` are consecutive and `a < x < c` then `x = b`. -/
theorem CovBy.eq_of_between {x : α} (hab : a ⋖ b) (hbc : b ⋖ c) (hax : a < x) (hxc : x < c) :
    x = b :=
  le_antisymm (le_of_not_lt fun h => hbc.2 h hxc) (le_of_not_lt <| hab.2 hax)
#align covby.eq_of_between CovBy.eq_of_between
-/

end LinearOrder

namespace Set

#print Set.wcovBy_insert /-
theorem wcovBy_insert (x : α) (s : Set α) : s ⩿ insert x s :=
  by
  refine' wcovBy_of_eq_or_eq (subset_insert x s) fun t hst h2t => _
  by_cases h : x ∈ t
  · exact Or.inr (subset_antisymm h2t <| insert_subset.mpr ⟨h, hst⟩)
  · refine' Or.inl (subset_antisymm _ hst)
    rwa [← diff_singleton_eq_self h, diff_singleton_subset_iff]
#align set.wcovby_insert Set.wcovBy_insert
-/

#print Set.covBy_insert /-
theorem covBy_insert {x : α} {s : Set α} (hx : x ∉ s) : s ⋖ insert x s :=
  (wcovBy_insert x s).covBy_of_lt <| ssubset_insert hx
#align set.covby_insert Set.covBy_insert
-/

end Set

namespace Prod

variable [PartialOrder α] [PartialOrder β] {a a₁ a₂ : α} {b b₁ b₂ : β} {x y : α × β}

#print Prod.swap_wcovBy_swap /-
@[simp]
theorem swap_wcovBy_swap : x.symm ⩿ y.symm ↔ x ⩿ y :=
  apply_wcovBy_apply_iff (OrderIso.prodComm : α × β ≃o β × α)
#align prod.swap_wcovby_swap Prod.swap_wcovBy_swap
-/

#print Prod.swap_covBy_swap /-
@[simp]
theorem swap_covBy_swap : x.symm ⋖ y.symm ↔ x ⋖ y :=
  apply_covBy_apply_iff (OrderIso.prodComm : α × β ≃o β × α)
#align prod.swap_covby_swap Prod.swap_covBy_swap
-/

#print Prod.fst_eq_or_snd_eq_of_wcovBy /-
theorem fst_eq_or_snd_eq_of_wcovBy : x ⩿ y → x.1 = y.1 ∨ x.2 = y.2 :=
  by
  refine' fun h => of_not_not fun hab => _
  push_neg at hab
  exact
    h.2 (mk_lt_mk.2 <| Or.inl ⟨hab.1.lt_of_le h.1.1, le_rfl⟩)
      (mk_lt_mk.2 <| Or.inr ⟨le_rfl, hab.2.lt_of_le h.1.2⟩)
#align prod.fst_eq_or_snd_eq_of_wcovby Prod.fst_eq_or_snd_eq_of_wcovBy
-/

#print WCovBy.fst /-
theorem WCovBy.fst (h : x ⩿ y) : x.1 ⩿ y.1 :=
  ⟨h.1.1, fun c h₁ h₂ => h.2 (mk_lt_mk_iff_left.2 h₁) ⟨⟨h₂.le, h.1.2⟩, fun hc => h₂.not_le hc.1⟩⟩
#align wcovby.fst WCovBy.fst
-/

#print WCovBy.snd /-
theorem WCovBy.snd (h : x ⩿ y) : x.2 ⩿ y.2 :=
  ⟨h.1.2, fun c h₁ h₂ => h.2 (mk_lt_mk_iff_right.2 h₁) ⟨⟨h.1.1, h₂.le⟩, fun hc => h₂.not_le hc.2⟩⟩
#align wcovby.snd WCovBy.snd
-/

#print Prod.mk_wcovBy_mk_iff_left /-
theorem mk_wcovBy_mk_iff_left : (a₁, b) ⩿ (a₂, b) ↔ a₁ ⩿ a₂ :=
  by
  refine' ⟨WCovBy.fst, And.imp mk_le_mk_iff_left.2 fun h c h₁ h₂ => _⟩
  have : c.2 = b := h₂.le.2.antisymm h₁.le.2
  rw [← @Prod.mk.eta _ _ c, this, mk_lt_mk_iff_left] at h₁ h₂
  exact h h₁ h₂
#align prod.mk_wcovby_mk_iff_left Prod.mk_wcovBy_mk_iff_left
-/

#print Prod.mk_wcovBy_mk_iff_right /-
theorem mk_wcovBy_mk_iff_right : (a, b₁) ⩿ (a, b₂) ↔ b₁ ⩿ b₂ :=
  swap_wcovBy_swap.trans mk_wcovBy_mk_iff_left
#align prod.mk_wcovby_mk_iff_right Prod.mk_wcovBy_mk_iff_right
-/

#print Prod.mk_covBy_mk_iff_left /-
theorem mk_covBy_mk_iff_left : (a₁, b) ⋖ (a₂, b) ↔ a₁ ⋖ a₂ := by
  simp_rw [covBy_iff_wcovBy_and_lt, mk_wcovby_mk_iff_left, mk_lt_mk_iff_left]
#align prod.mk_covby_mk_iff_left Prod.mk_covBy_mk_iff_left
-/

#print Prod.mk_covBy_mk_iff_right /-
theorem mk_covBy_mk_iff_right : (a, b₁) ⋖ (a, b₂) ↔ b₁ ⋖ b₂ := by
  simp_rw [covBy_iff_wcovBy_and_lt, mk_wcovby_mk_iff_right, mk_lt_mk_iff_right]
#align prod.mk_covby_mk_iff_right Prod.mk_covBy_mk_iff_right
-/

#print Prod.mk_wcovBy_mk_iff /-
theorem mk_wcovBy_mk_iff : (a₁, b₁) ⩿ (a₂, b₂) ↔ a₁ ⩿ a₂ ∧ b₁ = b₂ ∨ b₁ ⩿ b₂ ∧ a₁ = a₂ :=
  by
  refine' ⟨fun h => _, _⟩
  · obtain rfl | rfl : a₁ = a₂ ∨ b₁ = b₂ := fst_eq_or_snd_eq_of_wcovby h
    · exact Or.inr ⟨mk_wcovby_mk_iff_right.1 h, rfl⟩
    · exact Or.inl ⟨mk_wcovby_mk_iff_left.1 h, rfl⟩
  · rintro (⟨h, rfl⟩ | ⟨h, rfl⟩)
    · exact mk_wcovby_mk_iff_left.2 h
    · exact mk_wcovby_mk_iff_right.2 h
#align prod.mk_wcovby_mk_iff Prod.mk_wcovBy_mk_iff
-/

#print Prod.mk_covBy_mk_iff /-
theorem mk_covBy_mk_iff : (a₁, b₁) ⋖ (a₂, b₂) ↔ a₁ ⋖ a₂ ∧ b₁ = b₂ ∨ b₁ ⋖ b₂ ∧ a₁ = a₂ :=
  by
  refine' ⟨fun h => _, _⟩
  · obtain rfl | rfl : a₁ = a₂ ∨ b₁ = b₂ := fst_eq_or_snd_eq_of_wcovby h.wcovby
    · exact Or.inr ⟨mk_covby_mk_iff_right.1 h, rfl⟩
    · exact Or.inl ⟨mk_covby_mk_iff_left.1 h, rfl⟩
  · rintro (⟨h, rfl⟩ | ⟨h, rfl⟩)
    · exact mk_covby_mk_iff_left.2 h
    · exact mk_covby_mk_iff_right.2 h
#align prod.mk_covby_mk_iff Prod.mk_covBy_mk_iff
-/

#print Prod.wcovBy_iff /-
theorem wcovBy_iff : x ⩿ y ↔ x.1 ⩿ y.1 ∧ x.2 = y.2 ∨ x.2 ⩿ y.2 ∧ x.1 = y.1 := by cases x; cases y;
  exact mk_wcovby_mk_iff
#align prod.wcovby_iff Prod.wcovBy_iff
-/

#print Prod.covBy_iff /-
theorem covBy_iff : x ⋖ y ↔ x.1 ⋖ y.1 ∧ x.2 = y.2 ∨ x.2 ⋖ y.2 ∧ x.1 = y.1 := by cases x; cases y;
  exact mk_covby_mk_iff
#align prod.covby_iff Prod.covBy_iff
-/

end Prod

