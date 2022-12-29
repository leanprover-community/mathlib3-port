/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module data.set.intervals.monotone
! leanprover-community/mathlib commit 422e70f7ce183d2900c586a8cda8381e788a0c62
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Intervals.Disjoint
import Mathbin.Order.SuccPred.Basic

/-!
# Monotonicity on intervals

In this file we prove that `set.Ici` etc are monotone/antitone functions. We also prove some lemmas
about functions monotone on intervals in `succ_order`s.
-/


open Set

section IxxCat

variable {α β : Type _} [Preorder α] [Preorder β] {f g : α → β} {s : Set α}

theorem antitone_Ici : Antitone (Ici : α → Set α) := fun _ _ => Ici_subset_Ici.2
#align antitone_Ici antitone_Ici

theorem monotone_Iic : Monotone (Iic : α → Set α) := fun _ _ => Iic_subset_Iic.2
#align monotone_Iic monotone_Iic

theorem antitone_Ioi : Antitone (Ioi : α → Set α) := fun _ _ => Ioi_subset_Ioi
#align antitone_Ioi antitone_Ioi

theorem monotone_Iio : Monotone (Iio : α → Set α) := fun _ _ => Iio_subset_Iio
#align monotone_Iio monotone_Iio

protected theorem Monotone.Ici (hf : Monotone f) : Antitone fun x => Ici (f x) :=
  antitone_Ici.comp_monotone hf
#align monotone.Ici Monotone.Ici

protected theorem MonotoneOn.Ici (hf : MonotoneOn f s) : AntitoneOn (fun x => Ici (f x)) s :=
  antitone_Ici.comp_monotone_on hf
#align monotone_on.Ici MonotoneOn.Ici

protected theorem Antitone.Ici (hf : Antitone f) : Monotone fun x => Ici (f x) :=
  antitone_Ici.comp hf
#align antitone.Ici Antitone.Ici

protected theorem AntitoneOn.Ici (hf : AntitoneOn f s) : MonotoneOn (fun x => Ici (f x)) s :=
  antitone_Ici.comp_antitone_on hf
#align antitone_on.Ici AntitoneOn.Ici

protected theorem Monotone.Iic (hf : Monotone f) : Monotone fun x => Iic (f x) :=
  monotone_Iic.comp hf
#align monotone.Iic Monotone.Iic

protected theorem MonotoneOn.Iic (hf : MonotoneOn f s) : MonotoneOn (fun x => Iic (f x)) s :=
  monotone_Iic.comp_monotone_on hf
#align monotone_on.Iic MonotoneOn.Iic

protected theorem Antitone.Iic (hf : Antitone f) : Antitone fun x => Iic (f x) :=
  monotone_Iic.comp_antitone hf
#align antitone.Iic Antitone.Iic

protected theorem AntitoneOn.Iic (hf : AntitoneOn f s) : AntitoneOn (fun x => Iic (f x)) s :=
  monotone_Iic.comp_antitone_on hf
#align antitone_on.Iic AntitoneOn.Iic

protected theorem Monotone.Ioi (hf : Monotone f) : Antitone fun x => Ioi (f x) :=
  antitone_Ioi.comp_monotone hf
#align monotone.Ioi Monotone.Ioi

protected theorem MonotoneOn.Ioi (hf : MonotoneOn f s) : AntitoneOn (fun x => Ioi (f x)) s :=
  antitone_Ioi.comp_monotone_on hf
#align monotone_on.Ioi MonotoneOn.Ioi

protected theorem Antitone.Ioi (hf : Antitone f) : Monotone fun x => Ioi (f x) :=
  antitone_Ioi.comp hf
#align antitone.Ioi Antitone.Ioi

protected theorem AntitoneOn.Ioi (hf : AntitoneOn f s) : MonotoneOn (fun x => Ioi (f x)) s :=
  antitone_Ioi.comp_antitone_on hf
#align antitone_on.Ioi AntitoneOn.Ioi

protected theorem Monotone.Iio (hf : Monotone f) : Monotone fun x => Iio (f x) :=
  monotone_Iio.comp hf
#align monotone.Iio Monotone.Iio

protected theorem MonotoneOn.Iio (hf : MonotoneOn f s) : MonotoneOn (fun x => Iio (f x)) s :=
  monotone_Iio.comp_monotone_on hf
#align monotone_on.Iio MonotoneOn.Iio

protected theorem Antitone.Iio (hf : Antitone f) : Antitone fun x => Iio (f x) :=
  monotone_Iio.comp_antitone hf
#align antitone.Iio Antitone.Iio

protected theorem AntitoneOn.Iio (hf : AntitoneOn f s) : AntitoneOn (fun x => Iio (f x)) s :=
  monotone_Iio.comp_antitone_on hf
#align antitone_on.Iio AntitoneOn.Iio

protected theorem Monotone.Icc (hf : Monotone f) (hg : Antitone g) :
    Antitone fun x => Icc (f x) (g x) :=
  hf.IciCat.inter hg.IicCat
#align monotone.Icc Monotone.Icc

protected theorem MonotoneOn.Icc (hf : MonotoneOn f s) (hg : AntitoneOn g s) :
    AntitoneOn (fun x => Icc (f x) (g x)) s :=
  hf.IciCat.inter hg.IicCat
#align monotone_on.Icc MonotoneOn.Icc

protected theorem Antitone.Icc (hf : Antitone f) (hg : Monotone g) :
    Monotone fun x => Icc (f x) (g x) :=
  hf.IciCat.inter hg.IicCat
#align antitone.Icc Antitone.Icc

protected theorem AntitoneOn.Icc (hf : AntitoneOn f s) (hg : MonotoneOn g s) :
    MonotoneOn (fun x => Icc (f x) (g x)) s :=
  hf.IciCat.inter hg.IicCat
#align antitone_on.Icc AntitoneOn.Icc

protected theorem Monotone.Ico (hf : Monotone f) (hg : Antitone g) :
    Antitone fun x => Ico (f x) (g x) :=
  hf.IciCat.inter hg.IioCat
#align monotone.Ico Monotone.Ico

protected theorem MonotoneOn.Ico (hf : MonotoneOn f s) (hg : AntitoneOn g s) :
    AntitoneOn (fun x => Ico (f x) (g x)) s :=
  hf.IciCat.inter hg.IioCat
#align monotone_on.Ico MonotoneOn.Ico

protected theorem Antitone.Ico (hf : Antitone f) (hg : Monotone g) :
    Monotone fun x => Ico (f x) (g x) :=
  hf.IciCat.inter hg.IioCat
#align antitone.Ico Antitone.Ico

protected theorem AntitoneOn.Ico (hf : AntitoneOn f s) (hg : MonotoneOn g s) :
    MonotoneOn (fun x => Ico (f x) (g x)) s :=
  hf.IciCat.inter hg.IioCat
#align antitone_on.Ico AntitoneOn.Ico

protected theorem Monotone.Ioc (hf : Monotone f) (hg : Antitone g) :
    Antitone fun x => Ioc (f x) (g x) :=
  hf.IoiCat.inter hg.IicCat
#align monotone.Ioc Monotone.Ioc

protected theorem MonotoneOn.Ioc (hf : MonotoneOn f s) (hg : AntitoneOn g s) :
    AntitoneOn (fun x => Ioc (f x) (g x)) s :=
  hf.IoiCat.inter hg.IicCat
#align monotone_on.Ioc MonotoneOn.Ioc

protected theorem Antitone.Ioc (hf : Antitone f) (hg : Monotone g) :
    Monotone fun x => Ioc (f x) (g x) :=
  hf.IoiCat.inter hg.IicCat
#align antitone.Ioc Antitone.Ioc

protected theorem AntitoneOn.Ioc (hf : AntitoneOn f s) (hg : MonotoneOn g s) :
    MonotoneOn (fun x => Ioc (f x) (g x)) s :=
  hf.IoiCat.inter hg.IicCat
#align antitone_on.Ioc AntitoneOn.Ioc

protected theorem Monotone.Ioo (hf : Monotone f) (hg : Antitone g) :
    Antitone fun x => Ioo (f x) (g x) :=
  hf.IoiCat.inter hg.IioCat
#align monotone.Ioo Monotone.Ioo

protected theorem MonotoneOn.Ioo (hf : MonotoneOn f s) (hg : AntitoneOn g s) :
    AntitoneOn (fun x => Ioo (f x) (g x)) s :=
  hf.IoiCat.inter hg.IioCat
#align monotone_on.Ioo MonotoneOn.Ioo

protected theorem Antitone.Ioo (hf : Antitone f) (hg : Monotone g) :
    Monotone fun x => Ioo (f x) (g x) :=
  hf.IoiCat.inter hg.IioCat
#align antitone.Ioo Antitone.Ioo

protected theorem AntitoneOn.Ioo (hf : AntitoneOn f s) (hg : MonotoneOn g s) :
    MonotoneOn (fun x => Ioo (f x) (g x)) s :=
  hf.IoiCat.inter hg.IioCat
#align antitone_on.Ioo AntitoneOn.Ioo

end IxxCat

section UnionCat

variable {α β : Type _} [SemilatticeSup α] [LinearOrder β] {f g : α → β} {a b : β}

theorem Union_Ioo_of_mono_of_is_glb_of_is_lub (hf : Antitone f) (hg : Monotone g)
    (ha : IsGLB (range f) a) (hb : IsLUB (range g) b) : (⋃ x, Ioo (f x) (g x)) = Ioo a b :=
  calc
    (⋃ x, Ioo (f x) (g x)) = (⋃ x, Ioi (f x)) ∩ ⋃ x, Iio (g x) :=
      unionᵢ_inter_of_monotone hf.IoiCat hg.IioCat
    _ = Ioi a ∩ Iio b := congr_arg₂ (· ∩ ·) ha.Union_Ioi_eq hb.Union_Iio_eq
    
#align Union_Ioo_of_mono_of_is_glb_of_is_lub Union_Ioo_of_mono_of_is_glb_of_is_lub

end UnionCat

section SuccOrder

open Order

variable {α β : Type _} [PartialOrder α]

theorem StrictMonoOn.Iic_id_le [SuccOrder α] [IsSuccArchimedean α] [OrderBot α] {n : α} {φ : α → α}
    (hφ : StrictMonoOn φ (Set.Iic n)) : ∀ m ≤ n, m ≤ φ m :=
  by
  revert hφ
  refine'
    Succ.rec_bot (fun n => StrictMonoOn φ (Set.Iic n) → ∀ m ≤ n, m ≤ φ m)
      (fun _ _ hm => hm.trans bot_le) _ _
  rintro k ih hφ m hm
  by_cases hk : IsMax k
  · rw [succ_eq_iff_is_max.2 hk] at hm
    exact ih (hφ.mono <| Iic_subset_Iic.2 (le_succ _)) _ hm
  obtain rfl | h := le_succ_iff_eq_or_le.1 hm
  · specialize ih (StrictMonoOn.mono hφ fun x hx => le_trans hx (le_succ _)) k le_rfl
    refine' le_trans (succ_mono ih) (succ_le_of_lt (hφ (le_succ _) le_rfl _))
    rw [lt_succ_iff_eq_or_lt_of_not_is_max hk]
    exact Or.inl rfl
  · exact ih (StrictMonoOn.mono hφ fun x hx => le_trans hx (le_succ _)) _ h
#align strict_mono_on.Iic_id_le StrictMonoOn.Iic_id_le

theorem StrictMonoOn.Iic_le_id [PredOrder α] [IsPredArchimedean α] [OrderTop α] {n : α} {φ : α → α}
    (hφ : StrictMonoOn φ (Set.Ici n)) : ∀ m, n ≤ m → φ m ≤ m :=
  @StrictMonoOn.Iic_id_le αᵒᵈ _ _ _ _ _ _ fun i hi j hj hij => hφ hj hi hij
#align strict_mono_on.Iic_le_id StrictMonoOn.Iic_le_id

variable [Preorder β] {ψ : α → β}

/-- A function `ψ` on a `succ_order` is strictly monotone before some `n` if for all `m` such that
`m < n`, we have `ψ m < ψ (succ m)`. -/
theorem strict_mono_on_Iic_of_lt_succ [SuccOrder α] [IsSuccArchimedean α] {n : α}
    (hψ : ∀ m, m < n → ψ m < ψ (succ m)) : StrictMonoOn ψ (Set.Iic n) :=
  by
  intro x hx y hy hxy
  obtain ⟨i, rfl⟩ := hxy.le.exists_succ_iterate
  induction' i with k ih
  · simpa using hxy
  cases k
  · exact hψ _ (lt_of_lt_of_le hxy hy)
  rw [Set.mem_Iic] at *
  simp only [Function.iterate_succ', Function.comp_apply] at ih hxy hy⊢
  by_cases hmax : IsMax ((succ^[k]) x)
  · rw [succ_eq_iff_is_max.2 hmax] at hxy⊢
    exact ih (le_trans (le_succ _) hy) hxy
  by_cases hmax' : IsMax (succ ((succ^[k]) x))
  · rw [succ_eq_iff_is_max.2 hmax'] at hxy⊢
    exact ih (le_trans (le_succ _) hy) hxy
  refine'
    lt_trans
      (ih (le_trans (le_succ _) hy)
        (lt_of_le_of_lt (le_succ_iterate k _) (lt_succ_iff_not_is_max.2 hmax)))
      _
  rw [← Function.comp_apply succ, ← Function.iterate_succ']
  refine' hψ _ (lt_of_lt_of_le _ hy)
  rwa [Function.iterate_succ', Function.comp_apply, lt_succ_iff_not_is_max]
#align strict_mono_on_Iic_of_lt_succ strict_mono_on_Iic_of_lt_succ

theorem strict_anti_on_Iic_of_succ_lt [SuccOrder α] [IsSuccArchimedean α] {n : α}
    (hψ : ∀ m, m < n → ψ (succ m) < ψ m) : StrictAntiOn ψ (Set.Iic n) := fun i hi j hj hij =>
  @strict_mono_on_Iic_of_lt_succ α βᵒᵈ _ _ ψ _ _ n hψ i hi j hj hij
#align strict_anti_on_Iic_of_succ_lt strict_anti_on_Iic_of_succ_lt

theorem strict_mono_on_Iic_of_pred_lt [PredOrder α] [IsPredArchimedean α] {n : α}
    (hψ : ∀ m, n < m → ψ (pred m) < ψ m) : StrictMonoOn ψ (Set.Ici n) := fun i hi j hj hij =>
  @strict_mono_on_Iic_of_lt_succ αᵒᵈ βᵒᵈ _ _ ψ _ _ n hψ j hj i hi hij
#align strict_mono_on_Iic_of_pred_lt strict_mono_on_Iic_of_pred_lt

theorem strict_anti_on_Iic_of_lt_pred [PredOrder α] [IsPredArchimedean α] {n : α}
    (hψ : ∀ m, n < m → ψ m < ψ (pred m)) : StrictAntiOn ψ (Set.Ici n) := fun i hi j hj hij =>
  @strict_anti_on_Iic_of_succ_lt αᵒᵈ βᵒᵈ _ _ ψ _ _ n hψ j hj i hi hij
#align strict_anti_on_Iic_of_lt_pred strict_anti_on_Iic_of_lt_pred

end SuccOrder

