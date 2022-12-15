/-
Copyright (c) 2020 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov, Patrick Massot

! This file was ported from Lean 3 source module data.set.intervals.monoid
! leanprover-community/mathlib commit aba57d4d3dae35460225919dcd82fe91355162f9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Intervals.Basic
import Mathbin.Data.Set.Function
import Mathbin.Algebra.Order.Monoid.Cancel.Defs
import Mathbin.Algebra.Order.Monoid.Canonical.Defs
import Mathbin.Algebra.Group.Basic

/-!
# Images of intervals under `(+ d)`

The lemmas in this file state that addition maps intervals bijectively. The typeclass
`has_exists_add_of_le` is defined specifically to make them work when combined with
`ordered_cancel_add_comm_monoid`; the lemmas below therefore apply to all
`ordered_add_comm_group`, but also to `ℕ` and `ℝ≥0`, which are not groups.
-/


namespace Set

variable {M : Type _} [OrderedCancelAddCommMonoid M] [ExistsAddOfLE M] (a b c d : M)

theorem Ici_add_bij : BijOn (· + d) (ici a) (ici (a + d)) := by
  refine'
    ⟨fun x h => add_le_add_right (mem_Ici.mp h) _, (add_left_injective d).InjOn _, fun _ h => _⟩
  obtain ⟨c, rfl⟩ := exists_add_of_le (mem_Ici.mp h)
  rw [mem_Ici, add_right_comm, add_le_add_iff_right] at h
  exact ⟨a + c, h, by rw [add_right_comm]⟩
#align set.Ici_add_bij Set.Ici_add_bij

theorem Ioi_add_bij : BijOn (· + d) (ioi a) (ioi (a + d)) := by
  refine'
    ⟨fun x h => add_lt_add_right (mem_Ioi.mp h) _, fun _ _ _ _ h => add_right_cancel h, fun _ h =>
      _⟩
  obtain ⟨c, rfl⟩ := exists_add_of_le (mem_Ioi.mp h).le
  rw [mem_Ioi, add_right_comm, add_lt_add_iff_right] at h
  exact ⟨a + c, h, by rw [add_right_comm]⟩
#align set.Ioi_add_bij Set.Ioi_add_bij

theorem Icc_add_bij : BijOn (· + d) (icc a b) (icc (a + d) (b + d)) := by
  rw [← Ici_inter_Iic, ← Ici_inter_Iic]
  exact
    (Ici_add_bij a d).inter_maps_to (fun x hx => add_le_add_right hx _) fun x hx =>
      le_of_add_le_add_right hx.2
#align set.Icc_add_bij Set.Icc_add_bij

theorem Ioo_add_bij : BijOn (· + d) (ioo a b) (ioo (a + d) (b + d)) := by
  rw [← Ioi_inter_Iio, ← Ioi_inter_Iio]
  exact
    (Ioi_add_bij a d).inter_maps_to (fun x hx => add_lt_add_right hx _) fun x hx =>
      lt_of_add_lt_add_right hx.2
#align set.Ioo_add_bij Set.Ioo_add_bij

theorem Ioc_add_bij : BijOn (· + d) (ioc a b) (ioc (a + d) (b + d)) := by
  rw [← Ioi_inter_Iic, ← Ioi_inter_Iic]
  exact
    (Ioi_add_bij a d).inter_maps_to (fun x hx => add_le_add_right hx _) fun x hx =>
      le_of_add_le_add_right hx.2
#align set.Ioc_add_bij Set.Ioc_add_bij

theorem Ico_add_bij : BijOn (· + d) (ico a b) (ico (a + d) (b + d)) := by
  rw [← Ici_inter_Iio, ← Ici_inter_Iio]
  exact
    (Ici_add_bij a d).inter_maps_to (fun x hx => add_lt_add_right hx _) fun x hx =>
      lt_of_add_lt_add_right hx.2
#align set.Ico_add_bij Set.Ico_add_bij

/-!
### Images under `x ↦ x + a`
-/


@[simp]
theorem image_add_const_Ici : (fun x => x + a) '' ici b = ici (b + a) :=
  (Ici_add_bij _ _).image_eq
#align set.image_add_const_Ici Set.image_add_const_Ici

@[simp]
theorem image_add_const_Ioi : (fun x => x + a) '' ioi b = ioi (b + a) :=
  (Ioi_add_bij _ _).image_eq
#align set.image_add_const_Ioi Set.image_add_const_Ioi

@[simp]
theorem image_add_const_Icc : (fun x => x + a) '' icc b c = icc (b + a) (c + a) :=
  (Icc_add_bij _ _ _).image_eq
#align set.image_add_const_Icc Set.image_add_const_Icc

@[simp]
theorem image_add_const_Ico : (fun x => x + a) '' ico b c = ico (b + a) (c + a) :=
  (Ico_add_bij _ _ _).image_eq
#align set.image_add_const_Ico Set.image_add_const_Ico

@[simp]
theorem image_add_const_Ioc : (fun x => x + a) '' ioc b c = ioc (b + a) (c + a) :=
  (Ioc_add_bij _ _ _).image_eq
#align set.image_add_const_Ioc Set.image_add_const_Ioc

@[simp]
theorem image_add_const_Ioo : (fun x => x + a) '' ioo b c = ioo (b + a) (c + a) :=
  (Ioo_add_bij _ _ _).image_eq
#align set.image_add_const_Ioo Set.image_add_const_Ioo

/-!
### Images under `x ↦ a + x`
-/


@[simp]
theorem image_const_add_Ici : (fun x => a + x) '' ici b = ici (a + b) := by
  simp only [add_comm a, image_add_const_Ici]
#align set.image_const_add_Ici Set.image_const_add_Ici

@[simp]
theorem image_const_add_Ioi : (fun x => a + x) '' ioi b = ioi (a + b) := by
  simp only [add_comm a, image_add_const_Ioi]
#align set.image_const_add_Ioi Set.image_const_add_Ioi

@[simp]
theorem image_const_add_Icc : (fun x => a + x) '' icc b c = icc (a + b) (a + c) := by
  simp only [add_comm a, image_add_const_Icc]
#align set.image_const_add_Icc Set.image_const_add_Icc

@[simp]
theorem image_const_add_Ico : (fun x => a + x) '' ico b c = ico (a + b) (a + c) := by
  simp only [add_comm a, image_add_const_Ico]
#align set.image_const_add_Ico Set.image_const_add_Ico

@[simp]
theorem image_const_add_Ioc : (fun x => a + x) '' ioc b c = ioc (a + b) (a + c) := by
  simp only [add_comm a, image_add_const_Ioc]
#align set.image_const_add_Ioc Set.image_const_add_Ioc

@[simp]
theorem image_const_add_Ioo : (fun x => a + x) '' ioo b c = ioo (a + b) (a + c) := by
  simp only [add_comm a, image_add_const_Ioo]
#align set.image_const_add_Ioo Set.image_const_add_Ioo

end Set

