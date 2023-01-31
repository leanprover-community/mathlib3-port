/-
Copyright (c) 2022 Joseph Myers. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Myers

! This file was ported from Lean 3 source module algebra.order.to_interval_mod
! leanprover-community/mathlib commit bcfa726826abd57587355b4b5b7e78ad6527b7e4
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Module.Basic
import Mathbin.Algebra.Order.Archimedean
import Mathbin.Algebra.Periodic
import Mathbin.Data.Int.SuccPred
import Mathbin.GroupTheory.QuotientGroup

/-!
# Reducing to an interval modulo its length

This file defines operations that reduce a number (in an `archimedean`
`linear_ordered_add_comm_group`) to a number in a given interval, modulo the length of that
interval.

## Main definitions

* `to_Ico_div a hb x` (where `hb : 0 < b`): The unique integer such that this multiple of `b`,
  subtracted from `x`, is in `Ico a (a + b)`.
* `to_Ico_mod a hb x` (where `hb : 0 < b`): Reduce `x` to the interval `Ico a (a + b)`.
* `to_Ioc_div a hb x` (where `hb : 0 < b`): The unique integer such that this multiple of `b`,
  subtracted from `x`, is in `Ioc a (a + b)`.
* `to_Ioc_mod a hb x` (where `hb : 0 < b`): Reduce `x` to the interval `Ioc a (a + b)`.

-/


noncomputable section

section LinearOrderedAddCommGroup

variable {α : Type _} [LinearOrderedAddCommGroup α] [hα : Archimedean α]

include hα

/--
The unique integer such that this multiple of `b`, subtracted from `x`, is in `Ico a (a + b)`. -/
def toIcoDiv (a : α) {b : α} (hb : 0 < b) (x : α) : ℤ :=
  (existsUnique_sub_zsmul_mem_Ico hb x a).some
#align to_Ico_div toIcoDiv

theorem sub_toIcoDiv_zsmul_mem_Ico (a : α) {b : α} (hb : 0 < b) (x : α) :
    x - toIcoDiv a hb x • b ∈ Set.Ico a (a + b) :=
  (existsUnique_sub_zsmul_mem_Ico hb x a).some_spec.1
#align sub_to_Ico_div_zsmul_mem_Ico sub_toIcoDiv_zsmul_mem_Ico

theorem eq_toIcoDiv_of_sub_zsmul_mem_Ico {a b x : α} (hb : 0 < b) {y : ℤ}
    (hy : x - y • b ∈ Set.Ico a (a + b)) : y = toIcoDiv a hb x :=
  (existsUnique_sub_zsmul_mem_Ico hb x a).some_spec.2 y hy
#align eq_to_Ico_div_of_sub_zsmul_mem_Ico eq_toIcoDiv_of_sub_zsmul_mem_Ico

/--
The unique integer such that this multiple of `b`, subtracted from `x`, is in `Ioc a (a + b)`. -/
def toIocDiv (a : α) {b : α} (hb : 0 < b) (x : α) : ℤ :=
  (existsUnique_sub_zsmul_mem_Ioc hb x a).some
#align to_Ioc_div toIocDiv

theorem sub_toIocDiv_zsmul_mem_Ioc (a : α) {b : α} (hb : 0 < b) (x : α) :
    x - toIocDiv a hb x • b ∈ Set.Ioc a (a + b) :=
  (existsUnique_sub_zsmul_mem_Ioc hb x a).some_spec.1
#align sub_to_Ioc_div_zsmul_mem_Ioc sub_toIocDiv_zsmul_mem_Ioc

theorem eq_toIocDiv_of_sub_zsmul_mem_Ioc {a b x : α} (hb : 0 < b) {y : ℤ}
    (hy : x - y • b ∈ Set.Ioc a (a + b)) : y = toIocDiv a hb x :=
  (existsUnique_sub_zsmul_mem_Ioc hb x a).some_spec.2 y hy
#align eq_to_Ioc_div_of_sub_zsmul_mem_Ioc eq_toIocDiv_of_sub_zsmul_mem_Ioc

/-- Reduce `x` to the interval `Ico a (a + b)`. -/
def toIcoMod (a : α) {b : α} (hb : 0 < b) (x : α) : α :=
  x - toIcoDiv a hb x • b
#align to_Ico_mod toIcoMod

/-- Reduce `x` to the interval `Ioc a (a + b)`. -/
def toIocMod (a : α) {b : α} (hb : 0 < b) (x : α) : α :=
  x - toIocDiv a hb x • b
#align to_Ioc_mod toIocMod

theorem toIcoMod_mem_Ico (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoMod a hb x ∈ Set.Ico a (a + b) :=
  sub_toIcoDiv_zsmul_mem_Ico a hb x
#align to_Ico_mod_mem_Ico toIcoMod_mem_Ico

theorem toIcoMod_mem_Ico' {b : α} (hb : 0 < b) (x : α) : toIcoMod 0 hb x ∈ Set.Ico 0 b :=
  by
  convert toIcoMod_mem_Ico 0 hb x
  exact (zero_add b).symm
#align to_Ico_mod_mem_Ico' toIcoMod_mem_Ico'

theorem toIocMod_mem_Ioc (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocMod a hb x ∈ Set.Ioc a (a + b) :=
  sub_toIocDiv_zsmul_mem_Ioc a hb x
#align to_Ioc_mod_mem_Ioc toIocMod_mem_Ioc

theorem left_le_toIcoMod (a : α) {b : α} (hb : 0 < b) (x : α) : a ≤ toIcoMod a hb x :=
  (Set.mem_Ico.1 (toIcoMod_mem_Ico a hb x)).1
#align left_le_to_Ico_mod left_le_toIcoMod

theorem left_lt_toIocMod (a : α) {b : α} (hb : 0 < b) (x : α) : a < toIocMod a hb x :=
  (Set.mem_Ioc.1 (toIocMod_mem_Ioc a hb x)).1
#align left_lt_to_Ioc_mod left_lt_toIocMod

theorem toIcoMod_lt_right (a : α) {b : α} (hb : 0 < b) (x : α) : toIcoMod a hb x < a + b :=
  (Set.mem_Ico.1 (toIcoMod_mem_Ico a hb x)).2
#align to_Ico_mod_lt_right toIcoMod_lt_right

theorem toIocMod_le_right (a : α) {b : α} (hb : 0 < b) (x : α) : toIocMod a hb x ≤ a + b :=
  (Set.mem_Ioc.1 (toIocMod_mem_Ioc a hb x)).2
#align to_Ioc_mod_le_right toIocMod_le_right

@[simp]
theorem self_sub_toIcoDiv_zsmul (a : α) {b : α} (hb : 0 < b) (x : α) :
    x - toIcoDiv a hb x • b = toIcoMod a hb x :=
  rfl
#align self_sub_to_Ico_div_zsmul self_sub_toIcoDiv_zsmul

@[simp]
theorem self_sub_toIocDiv_zsmul (a : α) {b : α} (hb : 0 < b) (x : α) :
    x - toIocDiv a hb x • b = toIocMod a hb x :=
  rfl
#align self_sub_to_Ioc_div_zsmul self_sub_toIocDiv_zsmul

@[simp]
theorem toIcoDiv_zsmul_sub_self (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoDiv a hb x • b - x = -toIcoMod a hb x := by rw [toIcoMod, neg_sub]
#align to_Ico_div_zsmul_sub_self toIcoDiv_zsmul_sub_self

@[simp]
theorem toIocDiv_zsmul_sub_self (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocDiv a hb x • b - x = -toIocMod a hb x := by rw [toIocMod, neg_sub]
#align to_Ioc_div_zsmul_sub_self toIocDiv_zsmul_sub_self

@[simp]
theorem toIcoMod_sub_self (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoMod a hb x - x = -toIcoDiv a hb x • b := by rw [toIcoMod, sub_sub_cancel_left, neg_smul]
#align to_Ico_mod_sub_self toIcoMod_sub_self

@[simp]
theorem toIocMod_sub_self (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocMod a hb x - x = -toIocDiv a hb x • b := by rw [toIocMod, sub_sub_cancel_left, neg_smul]
#align to_Ioc_mod_sub_self toIocMod_sub_self

@[simp]
theorem self_sub_toIcoMod (a : α) {b : α} (hb : 0 < b) (x : α) :
    x - toIcoMod a hb x = toIcoDiv a hb x • b := by rw [toIcoMod, sub_sub_cancel]
#align self_sub_to_Ico_mod self_sub_toIcoMod

@[simp]
theorem self_sub_toIocMod (a : α) {b : α} (hb : 0 < b) (x : α) :
    x - toIocMod a hb x = toIocDiv a hb x • b := by rw [toIocMod, sub_sub_cancel]
#align self_sub_to_Ioc_mod self_sub_toIocMod

@[simp]
theorem toIcoMod_add_toIcoDiv_zsmul (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoMod a hb x + toIcoDiv a hb x • b = x := by rw [toIcoMod, sub_add_cancel]
#align to_Ico_mod_add_to_Ico_div_zsmul toIcoMod_add_toIcoDiv_zsmul

@[simp]
theorem toIocMod_add_toIocDiv_zsmul (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocMod a hb x + toIocDiv a hb x • b = x := by rw [toIocMod, sub_add_cancel]
#align to_Ioc_mod_add_to_Ioc_div_zsmul toIocMod_add_toIocDiv_zsmul

@[simp]
theorem toIcoDiv_zsmul_sub_toIcoMod (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoDiv a hb x • b + toIcoMod a hb x = x := by rw [add_comm, toIcoMod_add_toIcoDiv_zsmul]
#align to_Ico_div_zsmul_sub_to_Ico_mod toIcoDiv_zsmul_sub_toIcoMod

@[simp]
theorem toIocDiv_zsmul_sub_toIocMod (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocDiv a hb x • b + toIocMod a hb x = x := by rw [add_comm, toIocMod_add_toIocDiv_zsmul]
#align to_Ioc_div_zsmul_sub_to_Ioc_mod toIocDiv_zsmul_sub_toIocMod

theorem toIcoMod_eq_iff {a b x y : α} (hb : 0 < b) :
    toIcoMod a hb x = y ↔ y ∈ Set.Ico a (a + b) ∧ ∃ z : ℤ, x = y + z • b :=
  by
  refine'
    ⟨fun h =>
      ⟨h ▸ toIcoMod_mem_Ico a hb x, toIcoDiv a hb x, h ▸ (toIcoMod_add_toIcoDiv_zsmul _ _ _).symm⟩,
      fun h => _⟩
  rcases h with ⟨hy, z, hz⟩
  rw [← sub_eq_iff_eq_add] at hz
  subst hz
  rw [eq_toIcoDiv_of_sub_zsmul_mem_Ico hb hy]
  rfl
#align to_Ico_mod_eq_iff toIcoMod_eq_iff

theorem toIocMod_eq_iff {a b x y : α} (hb : 0 < b) :
    toIocMod a hb x = y ↔ y ∈ Set.Ioc a (a + b) ∧ ∃ z : ℤ, x = y + z • b :=
  by
  refine'
    ⟨fun h =>
      ⟨h ▸ toIocMod_mem_Ioc a hb x, toIocDiv a hb x, h ▸ (toIocMod_add_toIocDiv_zsmul _ hb _).symm⟩,
      fun h => _⟩
  rcases h with ⟨hy, z, hz⟩
  rw [← sub_eq_iff_eq_add] at hz
  subst hz
  rw [eq_toIocDiv_of_sub_zsmul_mem_Ioc hb hy]
  rfl
#align to_Ioc_mod_eq_iff toIocMod_eq_iff

@[simp]
theorem toIcoDiv_apply_left (a : α) {b : α} (hb : 0 < b) : toIcoDiv a hb a = 0 :=
  by
  refine' (eq_toIcoDiv_of_sub_zsmul_mem_Ico hb _).symm
  simp [hb]
#align to_Ico_div_apply_left toIcoDiv_apply_left

@[simp]
theorem toIocDiv_apply_left (a : α) {b : α} (hb : 0 < b) : toIocDiv a hb a = -1 :=
  by
  refine' (eq_toIocDiv_of_sub_zsmul_mem_Ioc hb _).symm
  simp [hb]
#align to_Ioc_div_apply_left toIocDiv_apply_left

@[simp]
theorem toIcoMod_apply_left (a : α) {b : α} (hb : 0 < b) : toIcoMod a hb a = a :=
  by
  rw [toIcoMod_eq_iff hb, Set.left_mem_Ico]
  refine' ⟨lt_add_of_pos_right _ hb, 0, _⟩
  simp
#align to_Ico_mod_apply_left toIcoMod_apply_left

@[simp]
theorem toIocMod_apply_left (a : α) {b : α} (hb : 0 < b) : toIocMod a hb a = a + b :=
  by
  rw [toIocMod_eq_iff hb, Set.right_mem_Ioc]
  refine' ⟨lt_add_of_pos_right _ hb, -1, _⟩
  simp
#align to_Ioc_mod_apply_left toIocMod_apply_left

theorem toIcoDiv_apply_right (a : α) {b : α} (hb : 0 < b) : toIcoDiv a hb (a + b) = 1 :=
  by
  refine' (eq_toIcoDiv_of_sub_zsmul_mem_Ico hb _).symm
  simp [hb]
#align to_Ico_div_apply_right toIcoDiv_apply_right

theorem toIocDiv_apply_right (a : α) {b : α} (hb : 0 < b) : toIocDiv a hb (a + b) = 0 :=
  by
  refine' (eq_toIocDiv_of_sub_zsmul_mem_Ioc hb _).symm
  simp [hb]
#align to_Ioc_div_apply_right toIocDiv_apply_right

theorem toIcoMod_apply_right (a : α) {b : α} (hb : 0 < b) : toIcoMod a hb (a + b) = a :=
  by
  rw [toIcoMod_eq_iff hb, Set.left_mem_Ico]
  refine' ⟨lt_add_of_pos_right _ hb, 1, _⟩
  simp
#align to_Ico_mod_apply_right toIcoMod_apply_right

theorem toIocMod_apply_right (a : α) {b : α} (hb : 0 < b) : toIocMod a hb (a + b) = a + b :=
  by
  rw [toIocMod_eq_iff hb, Set.right_mem_Ioc]
  refine' ⟨lt_add_of_pos_right _ hb, 0, _⟩
  simp
#align to_Ioc_mod_apply_right toIocMod_apply_right

@[simp]
theorem toIcoDiv_add_zsmul (a : α) {b : α} (hb : 0 < b) (x : α) (m : ℤ) :
    toIcoDiv a hb (x + m • b) = toIcoDiv a hb x + m :=
  by
  refine' (eq_toIcoDiv_of_sub_zsmul_mem_Ico hb _).symm
  convert sub_toIcoDiv_zsmul_mem_Ico a hb x using 1
  simp [add_smul]
#align to_Ico_div_add_zsmul toIcoDiv_add_zsmul

@[simp]
theorem toIocDiv_add_zsmul (a : α) {b : α} (hb : 0 < b) (x : α) (m : ℤ) :
    toIocDiv a hb (x + m • b) = toIocDiv a hb x + m :=
  by
  refine' (eq_toIocDiv_of_sub_zsmul_mem_Ioc hb _).symm
  convert sub_toIocDiv_zsmul_mem_Ioc a hb x using 1
  simp [add_smul]
#align to_Ioc_div_add_zsmul toIocDiv_add_zsmul

@[simp]
theorem toIcoDiv_zsmul_add (a : α) {b : α} (hb : 0 < b) (x : α) (m : ℤ) :
    toIcoDiv a hb (m • b + x) = m + toIcoDiv a hb x := by
  rw [add_comm, toIcoDiv_add_zsmul, add_comm]
#align to_Ico_div_zsmul_add toIcoDiv_zsmul_add

@[simp]
theorem toIocDiv_zsmul_add (a : α) {b : α} (hb : 0 < b) (x : α) (m : ℤ) :
    toIocDiv a hb (m • b + x) = toIocDiv a hb x + m := by
  rw [add_comm, toIocDiv_add_zsmul, add_comm]
#align to_Ioc_div_zsmul_add toIocDiv_zsmul_add

@[simp]
theorem toIcoDiv_sub_zsmul (a : α) {b : α} (hb : 0 < b) (x : α) (m : ℤ) :
    toIcoDiv a hb (x - m • b) = toIcoDiv a hb x - m := by
  rw [sub_eq_add_neg, ← neg_smul, toIcoDiv_add_zsmul, sub_eq_add_neg]
#align to_Ico_div_sub_zsmul toIcoDiv_sub_zsmul

@[simp]
theorem toIocDiv_sub_zsmul (a : α) {b : α} (hb : 0 < b) (x : α) (m : ℤ) :
    toIocDiv a hb (x - m • b) = toIocDiv a hb x - m := by
  rw [sub_eq_add_neg, ← neg_smul, toIocDiv_add_zsmul, sub_eq_add_neg]
#align to_Ioc_div_sub_zsmul toIocDiv_sub_zsmul

@[simp]
theorem toIcoDiv_add_right (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoDiv a hb (x + b) = toIcoDiv a hb x + 1 :=
  by
  convert toIcoDiv_add_zsmul a hb x 1
  exact (one_zsmul _).symm
#align to_Ico_div_add_right toIcoDiv_add_right

@[simp]
theorem toIocDiv_add_right (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocDiv a hb (x + b) = toIocDiv a hb x + 1 :=
  by
  convert toIocDiv_add_zsmul a hb x 1
  exact (one_zsmul _).symm
#align to_Ioc_div_add_right toIocDiv_add_right

@[simp]
theorem toIcoDiv_add_left (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoDiv a hb (b + x) = toIcoDiv a hb x + 1 := by rw [add_comm, toIcoDiv_add_right]
#align to_Ico_div_add_left toIcoDiv_add_left

@[simp]
theorem toIocDiv_add_left (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocDiv a hb (b + x) = toIocDiv a hb x + 1 := by rw [add_comm, toIocDiv_add_right]
#align to_Ioc_div_add_left toIocDiv_add_left

@[simp]
theorem toIcoDiv_sub (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoDiv a hb (x - b) = toIcoDiv a hb x - 1 :=
  by
  convert toIcoDiv_sub_zsmul a hb x 1
  exact (one_zsmul _).symm
#align to_Ico_div_sub toIcoDiv_sub

@[simp]
theorem toIocDiv_sub (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocDiv a hb (x - b) = toIocDiv a hb x - 1 :=
  by
  convert toIocDiv_sub_zsmul a hb x 1
  exact (one_zsmul _).symm
#align to_Ioc_div_sub toIocDiv_sub

theorem toIcoDiv_sub' (a : α) {b : α} (hb : 0 < b) (x y : α) :
    toIcoDiv a hb (x - y) = toIcoDiv (a + y) hb x :=
  by
  rw [eq_comm]
  apply eq_toIcoDiv_of_sub_zsmul_mem_Ico
  rw [← sub_right_comm, Set.sub_mem_Ico_iff_left, add_right_comm]
  exact sub_toIcoDiv_zsmul_mem_Ico (a + y) hb x
#align to_Ico_div_sub' toIcoDiv_sub'

theorem toIocDiv_sub' (a : α) {b : α} (hb : 0 < b) (x y : α) :
    toIocDiv a hb (x - y) = toIocDiv (a + y) hb x :=
  by
  rw [eq_comm]
  apply eq_toIocDiv_of_sub_zsmul_mem_Ioc
  rw [← sub_right_comm, Set.sub_mem_Ioc_iff_left, add_right_comm]
  exact sub_toIocDiv_zsmul_mem_Ioc (a + y) hb x
#align to_Ioc_div_sub' toIocDiv_sub'

theorem toIcoDiv_add_right' (a : α) {b : α} (hb : 0 < b) (x y : α) :
    toIcoDiv a hb (x + y) = toIcoDiv (a - y) hb x := by
  rw [← sub_neg_eq_add, toIcoDiv_sub', sub_eq_add_neg]
#align to_Ico_div_add_right' toIcoDiv_add_right'

theorem toIocDiv_add_right' (a : α) {b : α} (hb : 0 < b) (x y : α) :
    toIocDiv a hb (x + y) = toIocDiv (a - y) hb x := by
  rw [← sub_neg_eq_add, toIocDiv_sub', sub_eq_add_neg]
#align to_Ioc_div_add_right' toIocDiv_add_right'

theorem toIcoDiv_neg (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoDiv a hb (-x) = -(toIocDiv (-a) hb x + 1) :=
  by
  suffices toIcoDiv a hb (-x) = -toIocDiv (-(a + b)) hb x by
    rwa [neg_add, ← sub_eq_add_neg, ← toIocDiv_add_right', toIocDiv_add_right] at this
  rw [eq_neg_iff_eq_neg, eq_comm]
  apply eq_toIocDiv_of_sub_zsmul_mem_Ioc
  obtain ⟨hc, ho⟩ := sub_toIcoDiv_zsmul_mem_Ico a hb (-x)
  rw [← neg_lt_neg_iff, neg_sub' (-x), neg_neg, ← neg_smul] at ho
  rw [← neg_le_neg_iff, neg_sub' (-x), neg_neg, ← neg_smul] at hc
  refine' ⟨ho, hc.trans_eq _⟩
  rw [neg_add, neg_add_cancel_right]
#align to_Ico_div_neg toIcoDiv_neg

theorem toIocDiv_neg (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocDiv a hb (-x) = -(toIcoDiv (-a) hb x + 1) := by
  rw [← neg_neg x, toIcoDiv_neg, neg_neg, neg_neg, neg_add', neg_neg, add_sub_cancel]
#align to_Ioc_div_neg toIocDiv_neg

@[simp]
theorem toIcoMod_add_zsmul (a : α) {b : α} (hb : 0 < b) (x : α) (m : ℤ) :
    toIcoMod a hb (x + m • b) = toIcoMod a hb x :=
  by
  rw [toIcoMod, toIcoDiv_add_zsmul, toIcoMod, add_smul]
  abel
#align to_Ico_mod_add_zsmul toIcoMod_add_zsmul

@[simp]
theorem toIocMod_add_zsmul (a : α) {b : α} (hb : 0 < b) (x : α) (m : ℤ) :
    toIocMod a hb (x + m • b) = toIocMod a hb x :=
  by
  rw [toIocMod, toIocDiv_add_zsmul, toIocMod, add_smul]
  abel
#align to_Ioc_mod_add_zsmul toIocMod_add_zsmul

@[simp]
theorem toIcoMod_zsmul_add (a : α) {b : α} (hb : 0 < b) (x : α) (m : ℤ) :
    toIcoMod a hb (m • b + x) = toIcoMod a hb x := by rw [add_comm, toIcoMod_add_zsmul]
#align to_Ico_mod_zsmul_add toIcoMod_zsmul_add

@[simp]
theorem toIocMod_zsmul_add (a : α) {b : α} (hb : 0 < b) (x : α) (m : ℤ) :
    toIocMod a hb (m • b + x) = toIocMod a hb x := by rw [add_comm, toIocMod_add_zsmul]
#align to_Ioc_mod_zsmul_add toIocMod_zsmul_add

@[simp]
theorem toIcoMod_sub_zsmul (a : α) {b : α} (hb : 0 < b) (x : α) (m : ℤ) :
    toIcoMod a hb (x - m • b) = toIcoMod a hb x := by
  rw [sub_eq_add_neg, ← neg_smul, toIcoMod_add_zsmul]
#align to_Ico_mod_sub_zsmul toIcoMod_sub_zsmul

@[simp]
theorem toIocMod_sub_zsmul (a : α) {b : α} (hb : 0 < b) (x : α) (m : ℤ) :
    toIocMod a hb (x - m • b) = toIocMod a hb x := by
  rw [sub_eq_add_neg, ← neg_smul, toIocMod_add_zsmul]
#align to_Ioc_mod_sub_zsmul toIocMod_sub_zsmul

@[simp]
theorem toIcoMod_add_right (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoMod a hb (x + b) = toIcoMod a hb x :=
  by
  convert toIcoMod_add_zsmul a hb x 1
  exact (one_zsmul _).symm
#align to_Ico_mod_add_right toIcoMod_add_right

@[simp]
theorem toIocMod_add_right (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocMod a hb (x + b) = toIocMod a hb x :=
  by
  convert toIocMod_add_zsmul a hb x 1
  exact (one_zsmul _).symm
#align to_Ioc_mod_add_right toIocMod_add_right

@[simp]
theorem toIcoMod_add_left (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoMod a hb (b + x) = toIcoMod a hb x := by rw [add_comm, toIcoMod_add_right]
#align to_Ico_mod_add_left toIcoMod_add_left

@[simp]
theorem toIocMod_add_left (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocMod a hb (b + x) = toIocMod a hb x := by rw [add_comm, toIocMod_add_right]
#align to_Ioc_mod_add_left toIocMod_add_left

@[simp]
theorem toIcoMod_sub (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoMod a hb (x - b) = toIcoMod a hb x :=
  by
  convert toIcoMod_sub_zsmul a hb x 1
  exact (one_zsmul _).symm
#align to_Ico_mod_sub toIcoMod_sub

@[simp]
theorem toIocMod_sub (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocMod a hb (x - b) = toIocMod a hb x :=
  by
  convert toIocMod_sub_zsmul a hb x 1
  exact (one_zsmul _).symm
#align to_Ioc_mod_sub toIocMod_sub

theorem toIcoMod_sub' (a : α) {b : α} (hb : 0 < b) (x y : α) :
    toIcoMod a hb (x - y) = toIcoMod (a + y) hb x - y := by
  simp_rw [toIcoMod, toIcoDiv_sub', sub_right_comm]
#align to_Ico_mod_sub' toIcoMod_sub'

theorem toIocMod_sub' (a : α) {b : α} (hb : 0 < b) (x y : α) :
    toIocMod a hb (x - y) = toIocMod (a + y) hb x - y := by
  simp_rw [toIocMod, toIocDiv_sub', sub_right_comm]
#align to_Ioc_mod_sub' toIocMod_sub'

theorem toIcoMod_add_right' (a : α) {b : α} (hb : 0 < b) (x y : α) :
    toIcoMod a hb (x + y) = toIcoMod (a - y) hb x + y := by
  simp_rw [toIcoMod, toIcoDiv_add_right', sub_add_eq_add_sub]
#align to_Ico_mod_add_right' toIcoMod_add_right'

theorem toIocMod_add_right' (a : α) {b : α} (hb : 0 < b) (x y : α) :
    toIocMod a hb (x + y) = toIocMod (a - y) hb x + y := by
  simp_rw [toIocMod, toIocDiv_add_right', sub_add_eq_add_sub]
#align to_Ioc_mod_add_right' toIocMod_add_right'

theorem toIcoMod_neg (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoMod a hb (-x) = b - toIocMod (-a) hb x :=
  by
  simp_rw [toIcoMod, toIocMod, toIcoDiv_neg, neg_smul, add_smul]
  abel
#align to_Ico_mod_neg toIcoMod_neg

theorem toIocMod_neg (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocMod a hb (-x) = b - toIcoMod (-a) hb x :=
  by
  simp_rw [toIocMod, toIcoMod, toIocDiv_neg, neg_smul, add_smul]
  abel
#align to_Ioc_mod_neg toIocMod_neg

theorem toIcoMod_eq_toIcoMod (a : α) {b x y : α} (hb : 0 < b) :
    toIcoMod a hb x = toIcoMod a hb y ↔ ∃ z : ℤ, y - x = z • b :=
  by
  refine' ⟨fun h => ⟨toIcoDiv a hb y - toIcoDiv a hb x, _⟩, fun h => _⟩
  · conv_lhs => rw [← toIcoMod_add_toIcoDiv_zsmul a hb x, ← toIcoMod_add_toIcoDiv_zsmul a hb y]
    rw [h, sub_smul]
    abel
  · rcases h with ⟨z, hz⟩
    rw [sub_eq_iff_eq_add] at hz
    rw [hz, toIcoMod_zsmul_add]
#align to_Ico_mod_eq_to_Ico_mod toIcoMod_eq_toIcoMod

theorem toIocMod_eq_toIocMod (a : α) {b x y : α} (hb : 0 < b) :
    toIocMod a hb x = toIocMod a hb y ↔ ∃ z : ℤ, y - x = z • b :=
  by
  refine' ⟨fun h => ⟨toIocDiv a hb y - toIocDiv a hb x, _⟩, fun h => _⟩
  · conv_lhs => rw [← toIocMod_add_toIocDiv_zsmul a hb x, ← toIocMod_add_toIocDiv_zsmul a hb y]
    rw [h, sub_smul]
    abel
  · rcases h with ⟨z, hz⟩
    rw [sub_eq_iff_eq_add] at hz
    rw [hz, toIocMod_zsmul_add]
#align to_Ioc_mod_eq_to_Ioc_mod toIocMod_eq_toIocMod

/-! ### Links between the `Ico` and `Ioc` variants applied to the same element -/


section IcoIoc

variable (a : α) {b : α} (hb : 0 < b) (x : α)

omit hα

/-- `mem_Ioo_mod a b x` means that `x` lies in the open interval `(a, a + b)` modulo `b`.
Equivalently (as shown below), `x` is not congruent to `a` modulo `b`, or `to_Ico_mod a hb` agrees
with `to_Ioc_mod a hb` at `x`, or `to_Ico_div a hb` agrees with `to_Ioc_div a hb` at `x`. -/
def MemIooMod (b x : α) : Prop :=
  ∃ z : ℤ, x - z • b ∈ Set.Ioo a (a + b)
#align mem_Ioo_mod MemIooMod

include hα

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `tFAE_memIooMod [])
      (Command.declSig
       []
       (Term.typeSpec
        ":"
        (Term.app
         `TFAE
         [(«term[_]»
           "["
           [(Term.app `MemIooMod [`a `b `x])
            ","
            («term_=_» (Term.app `toIcoMod [`a `hb `x]) "=" (Term.app `toIocMod [`a `hb `x]))
            ","
            («term_≠_»
             («term_+_» (Term.app `toIcoMod [`a `hb `x]) "+" `b)
             "≠"
             (Term.app `toIocMod [`a `hb `x]))
            ","
            («term_≠_» (Term.app `toIcoMod [`a `hb `x]) "≠" `a)]
           "]")])))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.tfaeHave "tfae_have" [] (num "1") "→" (num "2"))
           []
           (tactic__
            (cdotTk (patternIgnore (token.«· » "·")))
            [(Tactic.exact
              "exact"
              (Term.fun
               "fun"
               (Term.basicFun
                [(Term.anonymousCtor "⟨" [`i "," `hi] "⟩")]
                []
                "=>"
                (Term.app
                 (Term.proj
                  (Term.app
                   (Term.proj (Term.app `toIcoMod_eq_iff [`hb]) "." (fieldIdx "2"))
                   [(Term.anonymousCtor
                     "⟨"
                     [(Term.app `Set.Ioo_subset_Ico_self [`hi])
                      ","
                      `i
                      ","
                      (Term.proj (Term.app `sub_add_cancel [`x (Term.hole "_")]) "." `symm)]
                     "⟩")])
                  "."
                  `trans)
                 [(Term.proj
                   (Term.app
                    (Term.proj (Term.app `toIocMod_eq_iff [`hb]) "." (fieldIdx "2"))
                    [(Term.anonymousCtor
                      "⟨"
                      [(Term.app `Set.Ioo_subset_Ioc_self [`hi])
                       ","
                       `i
                       ","
                       (Term.proj (Term.app `sub_add_cancel [`x (Term.hole "_")]) "." `symm)]
                      "⟩")])
                   "."
                   `symm)]))))])
           []
           (Tactic.tfaeHave "tfae_have" [] (num "2") "→" (num "3"))
           []
           (tactic__
            (cdotTk (patternIgnore (token.«· » "·")))
            [(Tactic.intro "intro" [`h])
             []
             (Tactic.rwSeq
              "rw"
              []
              (Tactic.rwRuleSeq
               "["
               [(Tactic.rwRule [] `h)
                ","
                (Tactic.rwRule [] `Ne)
                ","
                (Tactic.rwRule [] `add_right_eq_self)]
               "]")
              [])
             []
             (Tactic.exact "exact" `hb.ne')])
           []
           (Tactic.tfaeHave "tfae_have" [] (num "3") "→" (num "4"))
           []
           (tactic__
            (cdotTk (patternIgnore (token.«· » "·")))
            [(Tactic.refine'
              "refine'"
              (Term.app `mt [(Term.fun "fun" (Term.basicFun [`h] [] "=>" (Term.hole "_")))]))
             []
             (Tactic.rwSeq
              "rw"
              []
              (Tactic.rwRuleSeq
               "["
               [(Tactic.rwRule [] `h)
                ","
                (Tactic.rwRule [] `eq_comm)
                ","
                (Tactic.rwRule [] `toIocMod_eq_iff)
                ","
                (Tactic.rwRule [] `Set.right_mem_Ioc)]
               "]")
              [])
             []
             (Tactic.refine'
              "refine'"
              (Term.anonymousCtor
               "⟨"
               [(Term.app `lt_add_of_pos_right [`a `hb])
                ","
                («term_-_» (Term.app `toIcoDiv [`a `hb `x]) "-" (num "1"))
                ","
                (Term.hole "_")]
               "⟩"))
             []
             (Tactic.rwSeq
              "rw"
              []
              (Tactic.rwRuleSeq
               "["
               [(Tactic.rwRule [] `sub_one_zsmul)
                ","
                (Tactic.rwRule [] `add_add_add_comm)
                ","
                (Tactic.rwRule [] `add_right_neg)
                ","
                (Tactic.rwRule [] `add_zero)]
               "]")
              [])
             []
             (Mathlib.Tactic.Conv.convLHS
              "conv_lhs"
              []
              []
              "=>"
              (Tactic.Conv.convSeq
               (Tactic.Conv.convSeq1Indented
                [(Tactic.Conv.convRw__
                  "rw"
                  []
                  (Tactic.rwRuleSeq
                   "["
                   [(Tactic.rwRule
                     [(patternIgnore (token.«← » "←"))]
                     (Term.app `toIcoMod_add_toIcoDiv_zsmul [`a `hb `x]))
                    ","
                    (Tactic.rwRule [] `h)]
                   "]"))])))])
           []
           (Tactic.tfaeHave "tfae_have" [] (num "4") "→" (num "1"))
           []
           (tactic__
            (cdotTk (patternIgnore (token.«· » "·")))
            [(Tactic.tacticHave_
              "have"
              (Term.haveDecl
               (Term.haveIdDecl [`h' []] [] ":=" (Term.app `toIcoMod_mem_Ico [`a `hb `x]))))
             []
             (Tactic.exact
              "exact"
              (Term.fun
               "fun"
               (Term.basicFun
                [`h]
                []
                "=>"
                (Term.anonymousCtor
                 "⟨"
                 [(Term.hole "_")
                  ","
                  (Term.app (Term.proj (Term.proj `h' "." (fieldIdx "1")) "." `lt_of_ne') [`h])
                  ","
                  (Term.proj `h' "." (fieldIdx "2"))]
                 "⟩"))))])
           []
           (Tactic.tfaeFinish "tfae_finish")])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.tfaeHave "tfae_have" [] (num "1") "→" (num "2"))
          []
          (tactic__
           (cdotTk (patternIgnore (token.«· » "·")))
           [(Tactic.exact
             "exact"
             (Term.fun
              "fun"
              (Term.basicFun
               [(Term.anonymousCtor "⟨" [`i "," `hi] "⟩")]
               []
               "=>"
               (Term.app
                (Term.proj
                 (Term.app
                  (Term.proj (Term.app `toIcoMod_eq_iff [`hb]) "." (fieldIdx "2"))
                  [(Term.anonymousCtor
                    "⟨"
                    [(Term.app `Set.Ioo_subset_Ico_self [`hi])
                     ","
                     `i
                     ","
                     (Term.proj (Term.app `sub_add_cancel [`x (Term.hole "_")]) "." `symm)]
                    "⟩")])
                 "."
                 `trans)
                [(Term.proj
                  (Term.app
                   (Term.proj (Term.app `toIocMod_eq_iff [`hb]) "." (fieldIdx "2"))
                   [(Term.anonymousCtor
                     "⟨"
                     [(Term.app `Set.Ioo_subset_Ioc_self [`hi])
                      ","
                      `i
                      ","
                      (Term.proj (Term.app `sub_add_cancel [`x (Term.hole "_")]) "." `symm)]
                     "⟩")])
                  "."
                  `symm)]))))])
          []
          (Tactic.tfaeHave "tfae_have" [] (num "2") "→" (num "3"))
          []
          (tactic__
           (cdotTk (patternIgnore (token.«· » "·")))
           [(Tactic.intro "intro" [`h])
            []
            (Tactic.rwSeq
             "rw"
             []
             (Tactic.rwRuleSeq
              "["
              [(Tactic.rwRule [] `h)
               ","
               (Tactic.rwRule [] `Ne)
               ","
               (Tactic.rwRule [] `add_right_eq_self)]
              "]")
             [])
            []
            (Tactic.exact "exact" `hb.ne')])
          []
          (Tactic.tfaeHave "tfae_have" [] (num "3") "→" (num "4"))
          []
          (tactic__
           (cdotTk (patternIgnore (token.«· » "·")))
           [(Tactic.refine'
             "refine'"
             (Term.app `mt [(Term.fun "fun" (Term.basicFun [`h] [] "=>" (Term.hole "_")))]))
            []
            (Tactic.rwSeq
             "rw"
             []
             (Tactic.rwRuleSeq
              "["
              [(Tactic.rwRule [] `h)
               ","
               (Tactic.rwRule [] `eq_comm)
               ","
               (Tactic.rwRule [] `toIocMod_eq_iff)
               ","
               (Tactic.rwRule [] `Set.right_mem_Ioc)]
              "]")
             [])
            []
            (Tactic.refine'
             "refine'"
             (Term.anonymousCtor
              "⟨"
              [(Term.app `lt_add_of_pos_right [`a `hb])
               ","
               («term_-_» (Term.app `toIcoDiv [`a `hb `x]) "-" (num "1"))
               ","
               (Term.hole "_")]
              "⟩"))
            []
            (Tactic.rwSeq
             "rw"
             []
             (Tactic.rwRuleSeq
              "["
              [(Tactic.rwRule [] `sub_one_zsmul)
               ","
               (Tactic.rwRule [] `add_add_add_comm)
               ","
               (Tactic.rwRule [] `add_right_neg)
               ","
               (Tactic.rwRule [] `add_zero)]
              "]")
             [])
            []
            (Mathlib.Tactic.Conv.convLHS
             "conv_lhs"
             []
             []
             "=>"
             (Tactic.Conv.convSeq
              (Tactic.Conv.convSeq1Indented
               [(Tactic.Conv.convRw__
                 "rw"
                 []
                 (Tactic.rwRuleSeq
                  "["
                  [(Tactic.rwRule
                    [(patternIgnore (token.«← » "←"))]
                    (Term.app `toIcoMod_add_toIcoDiv_zsmul [`a `hb `x]))
                   ","
                   (Tactic.rwRule [] `h)]
                  "]"))])))])
          []
          (Tactic.tfaeHave "tfae_have" [] (num "4") "→" (num "1"))
          []
          (tactic__
           (cdotTk (patternIgnore (token.«· » "·")))
           [(Tactic.tacticHave_
             "have"
             (Term.haveDecl
              (Term.haveIdDecl [`h' []] [] ":=" (Term.app `toIcoMod_mem_Ico [`a `hb `x]))))
            []
            (Tactic.exact
             "exact"
             (Term.fun
              "fun"
              (Term.basicFun
               [`h]
               []
               "=>"
               (Term.anonymousCtor
                "⟨"
                [(Term.hole "_")
                 ","
                 (Term.app (Term.proj (Term.proj `h' "." (fieldIdx "1")) "." `lt_of_ne') [`h])
                 ","
                 (Term.proj `h' "." (fieldIdx "2"))]
                "⟩"))))])
          []
          (Tactic.tfaeFinish "tfae_finish")])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tfaeFinish "tfae_finish")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (tactic__
       (cdotTk (patternIgnore (token.«· » "·")))
       [(Tactic.tacticHave_
         "have"
         (Term.haveDecl
          (Term.haveIdDecl [`h' []] [] ":=" (Term.app `toIcoMod_mem_Ico [`a `hb `x]))))
        []
        (Tactic.exact
         "exact"
         (Term.fun
          "fun"
          (Term.basicFun
           [`h]
           []
           "=>"
           (Term.anonymousCtor
            "⟨"
            [(Term.hole "_")
             ","
             (Term.app (Term.proj (Term.proj `h' "." (fieldIdx "1")) "." `lt_of_ne') [`h])
             ","
             (Term.proj `h' "." (fieldIdx "2"))]
            "⟩"))))])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.exact
       "exact"
       (Term.fun
        "fun"
        (Term.basicFun
         [`h]
         []
         "=>"
         (Term.anonymousCtor
          "⟨"
          [(Term.hole "_")
           ","
           (Term.app (Term.proj (Term.proj `h' "." (fieldIdx "1")) "." `lt_of_ne') [`h])
           ","
           (Term.proj `h' "." (fieldIdx "2"))]
          "⟩"))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`h]
        []
        "=>"
        (Term.anonymousCtor
         "⟨"
         [(Term.hole "_")
          ","
          (Term.app (Term.proj (Term.proj `h' "." (fieldIdx "1")) "." `lt_of_ne') [`h])
          ","
          (Term.proj `h' "." (fieldIdx "2"))]
         "⟩")))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor
       "⟨"
       [(Term.hole "_")
        ","
        (Term.app (Term.proj (Term.proj `h' "." (fieldIdx "1")) "." `lt_of_ne') [`h])
        ","
        (Term.proj `h' "." (fieldIdx "2"))]
       "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.proj `h' "." (fieldIdx "2"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `h'
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app (Term.proj (Term.proj `h' "." (fieldIdx "1")) "." `lt_of_ne') [`h])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj (Term.proj `h' "." (fieldIdx "1")) "." `lt_of_ne')
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.proj `h' "." (fieldIdx "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `h'
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `h
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tacticHave_
       "have"
       (Term.haveDecl (Term.haveIdDecl [`h' []] [] ":=" (Term.app `toIcoMod_mem_Ico [`a `hb `x]))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `toIcoMod_mem_Ico [`a `hb `x])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `x
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `hb
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `a
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `toIcoMod_mem_Ico
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.tfaeHave "tfae_have" [] (num "4") "→" (num "1"))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«→»', expected 'token.« → »'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«→»', expected 'token.« ↔ »'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«→»', expected 'token.« ← »'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.declValEqns'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.declValSimple', expected 'Lean.Parser.Command.whereStructInst'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  tFAE_memIooMod
  :
    TFAE
      [
        MemIooMod a b x
          ,
          toIcoMod a hb x = toIocMod a hb x
          ,
          toIcoMod a hb x + b ≠ toIocMod a hb x
          ,
          toIcoMod a hb x ≠ a
        ]
  :=
    by
      tfae_have 1 → 2
        ·
          exact
            fun
              ⟨ i , hi ⟩
                =>
                toIcoMod_eq_iff hb . 2
                      ⟨ Set.Ioo_subset_Ico_self hi , i , sub_add_cancel x _ . symm ⟩
                    .
                    trans
                  toIocMod_eq_iff hb . 2
                      ⟨ Set.Ioo_subset_Ioc_self hi , i , sub_add_cancel x _ . symm ⟩
                    .
                    symm
        tfae_have 2 → 3
        · intro h rw [ h , Ne , add_right_eq_self ] exact hb.ne'
        tfae_have 3 → 4
        ·
          refine' mt fun h => _
            rw [ h , eq_comm , toIocMod_eq_iff , Set.right_mem_Ioc ]
            refine' ⟨ lt_add_of_pos_right a hb , toIcoDiv a hb x - 1 , _ ⟩
            rw [ sub_one_zsmul , add_add_add_comm , add_right_neg , add_zero ]
            conv_lhs => rw [ ← toIcoMod_add_toIcoDiv_zsmul a hb x , h ]
        tfae_have 4 → 1
        · have h' := toIcoMod_mem_Ico a hb x exact fun h => ⟨ _ , h' . 1 . lt_of_ne' h , h' . 2 ⟩
        tfae_finish
#align tfae_mem_Ioo_mod tFAE_memIooMod

variable {a x}

theorem memIooMod_iff_toIcoMod_eq_toIocMod : MemIooMod a b x ↔ toIcoMod a hb x = toIocMod a hb x :=
  (tFAE_memIooMod a hb x).out 0 1
#align mem_Ioo_mod_iff_to_Ico_mod_eq_to_Ioc_mod memIooMod_iff_toIcoMod_eq_toIocMod

theorem memIooMod_iff_toIcoMod_add_period_ne_toIocMod :
    MemIooMod a b x ↔ toIcoMod a hb x + b ≠ toIocMod a hb x :=
  (tFAE_memIooMod a hb x).out 0 2
#align mem_Ioo_mod_iff_to_Ico_mod_add_period_ne_to_Ioc_mod memIooMod_iff_toIcoMod_add_period_ne_toIocMod

theorem memIooMod_iff_toIcoMod_ne_left : MemIooMod a b x ↔ toIcoMod a hb x ≠ a :=
  (tFAE_memIooMod a hb x).out 0 3
#align mem_Ioo_mod_iff_to_Ico_mod_ne_left memIooMod_iff_toIcoMod_ne_left

theorem not_memIooMod_iff_toIcoMod_add_period_eq_toIocMod :
    ¬MemIooMod a b x ↔ toIcoMod a hb x + b = toIocMod a hb x :=
  (memIooMod_iff_toIcoMod_add_period_ne_toIocMod hb).not_left
#align not_mem_Ioo_mod_iff_to_Ico_mod_add_period_eq_to_Ioc_mod not_memIooMod_iff_toIcoMod_add_period_eq_toIocMod

theorem not_memIooMod_iff_toIcoMod_eq_left : ¬MemIooMod a b x ↔ toIcoMod a hb x = a :=
  (memIooMod_iff_toIcoMod_ne_left hb).not_left
#align not_mem_Ioo_mod_iff_to_Ico_mod_eq_left not_memIooMod_iff_toIcoMod_eq_left

theorem memIooMod_iff_toIocMod_ne_right : MemIooMod a b x ↔ toIocMod a hb x ≠ a + b :=
  by
  rw [memIooMod_iff_toIcoMod_eq_toIocMod, toIcoMod_eq_iff hb]
  obtain ⟨h₁, h₂⟩ := toIocMod_mem_Ioc a hb x
  exact
    ⟨fun h => h.1.2.Ne, fun h =>
      ⟨⟨h₁.le, h₂.lt_of_ne h⟩, _, (toIocMod_add_toIocDiv_zsmul _ _ _).symm⟩⟩
#align mem_Ioo_mod_iff_to_Ioc_mod_ne_right memIooMod_iff_toIocMod_ne_right

theorem not_memIooMod_iff_to_Ioc_eq_right : ¬MemIooMod a b x ↔ toIocMod a hb x = a + b :=
  (memIooMod_iff_toIocMod_ne_right hb).not_left
#align not_mem_Ioo_mod_iff_to_Ioc_eq_right not_memIooMod_iff_to_Ioc_eq_right

theorem memIooMod_iff_toIcoDiv_eq_toIocDiv : MemIooMod a b x ↔ toIcoDiv a hb x = toIocDiv a hb x :=
  by
  rw [memIooMod_iff_toIcoMod_eq_toIocMod hb, toIcoMod, toIocMod, sub_right_inj,
    (zsmul_strictMono_left hb).Injective.eq_iff]
#align mem_Ioo_mod_iff_to_Ico_div_eq_to_Ioc_div memIooMod_iff_toIcoDiv_eq_toIocDiv

theorem memIooMod_iff_toIcoDiv_ne_toIocDiv_add_one :
    MemIooMod a b x ↔ toIcoDiv a hb x ≠ toIocDiv a hb x + 1 := by
  rw [memIooMod_iff_toIcoMod_add_period_ne_toIocMod hb, Ne, Ne, toIcoMod, toIocMod, ←
    eq_sub_iff_add_eq, sub_sub, sub_right_inj, ← add_one_zsmul,
    (zsmul_strictMono_left hb).Injective.eq_iff]
#align mem_Ioo_mod_iff_to_Ico_div_ne_to_Ioc_div_add_one memIooMod_iff_toIcoDiv_ne_toIocDiv_add_one

theorem not_memIooMod_iff_toIcoDiv_eq_toIocDiv_add_one :
    ¬MemIooMod a b x ↔ toIcoDiv a hb x = toIocDiv a hb x + 1 :=
  (memIooMod_iff_toIcoDiv_ne_toIocDiv_add_one hb).not_left
#align not_mem_Ioo_mod_iff_to_Ico_div_eq_to_Ioc_div_add_one not_memIooMod_iff_toIcoDiv_eq_toIocDiv_add_one

include hb

theorem memIooMod_iff_ne_add_zsmul : MemIooMod a b x ↔ ∀ z : ℤ, x ≠ a + z • b :=
  by
  rw [memIooMod_iff_toIcoMod_ne_left hb, ← not_iff_not]
  push_neg; constructor <;> intro h
  · rw [← h]
    exact ⟨_, (toIcoMod_add_toIcoDiv_zsmul _ _ _).symm⟩
  · rw [toIcoMod_eq_iff, Set.left_mem_Ico]
    exact ⟨lt_add_of_pos_right a hb, h⟩
#align mem_Ioo_mod_iff_ne_add_zsmul memIooMod_iff_ne_add_zsmul

theorem not_memIooMod_iff_eq_add_zsmul : ¬MemIooMod a b x ↔ ∃ z : ℤ, x = a + z • b := by
  simpa only [not_forall, not_ne_iff] using (memIooMod_iff_ne_add_zsmul hb).Not
#align not_mem_Ioo_mod_iff_eq_add_zsmul not_memIooMod_iff_eq_add_zsmul

theorem not_memIooMod_iff_eq_mod_zmultiples :
    ¬MemIooMod a b x ↔ (x : α ⧸ AddSubgroup.zmultiples b) = a := by
  simp_rw [not_memIooMod_iff_eq_add_zsmul hb, quotientAddGroup.eq_iff_sub_mem,
    AddSubgroup.mem_zmultiples_iff, eq_sub_iff_add_eq', eq_comm]
#align not_mem_Ioo_mod_iff_eq_mod_zmultiples not_memIooMod_iff_eq_mod_zmultiples

theorem memIooMod_iff_ne_mod_zmultiples :
    MemIooMod a b x ↔ (x : α ⧸ AddSubgroup.zmultiples b) ≠ a :=
  (not_memIooMod_iff_eq_mod_zmultiples hb).not_right
#align mem_Ioo_mod_iff_ne_mod_zmultiples memIooMod_iff_ne_mod_zmultiples

theorem Ico_eq_locus_Ioc_eq_unionᵢ_Ioo :
    { x | toIcoMod a hb x = toIocMod a hb x } = ⋃ z : ℤ, Set.Ioo (a + z • b) (a + b + z • b) :=
  by
  ext1; simp_rw [Set.mem_setOf, Set.mem_unionᵢ, ← Set.sub_mem_Ioo_iff_left]
  exact (memIooMod_iff_toIcoMod_eq_toIocMod hb).symm
#align Ico_eq_locus_Ioc_eq_Union_Ioo Ico_eq_locus_Ioc_eq_unionᵢ_Ioo

theorem toIocDiv_wcovby_toIcoDiv (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocDiv a hb x ⩿ toIcoDiv a hb x :=
  by
  suffices toIocDiv a hb x = toIcoDiv a hb x ∨ toIocDiv a hb x + 1 = toIcoDiv a hb x by
    rwa [wcovby_iff_eq_or_covby, ← Order.succ_eq_iff_covby]
  rw [eq_comm, ← memIooMod_iff_toIcoDiv_eq_toIocDiv, eq_comm, ←
    not_memIooMod_iff_toIcoDiv_eq_toIocDiv_add_one]
  exact em _
#align to_Ioc_div_wcovby_to_Ico_div toIocDiv_wcovby_toIcoDiv

theorem toIcoMod_le_toIocMod (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoMod a hb x ≤ toIocMod a hb x :=
  by
  rw [toIcoMod, toIocMod, sub_le_sub_iff_left]
  exact zsmul_mono_left hb.le (toIocDiv_wcovby_toIcoDiv _ _ _).le
#align to_Ico_mod_le_to_Ioc_mod toIcoMod_le_toIocMod

theorem toIocMod_le_toIcoMod_add (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocMod a hb x ≤ toIcoMod a hb x + b :=
  by
  rw [toIcoMod, toIocMod, sub_add, sub_le_sub_iff_left, sub_le_iff_le_add, ← add_one_zsmul,
    (zsmul_strictMono_left hb).le_iff_le]
  apply (toIocDiv_wcovby_toIcoDiv _ _ _).le_succ
#align to_Ioc_mod_le_to_Ico_mod_add toIocMod_le_toIcoMod_add

end IcoIoc

theorem toIcoMod_eq_self {a b x : α} (hb : 0 < b) : toIcoMod a hb x = x ↔ x ∈ Set.Ico a (a + b) :=
  by
  rw [toIcoMod_eq_iff, and_iff_left]
  refine' ⟨0, _⟩
  simp
#align to_Ico_mod_eq_self toIcoMod_eq_self

theorem toIocMod_eq_self {a b x : α} (hb : 0 < b) : toIocMod a hb x = x ↔ x ∈ Set.Ioc a (a + b) :=
  by
  rw [toIocMod_eq_iff, and_iff_left]
  refine' ⟨0, _⟩
  simp
#align to_Ioc_mod_eq_self toIocMod_eq_self

@[simp]
theorem toIcoMod_toIcoMod (a₁ a₂ : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoMod a₁ hb (toIcoMod a₂ hb x) = toIcoMod a₁ hb x :=
  by
  rw [toIcoMod_eq_toIcoMod]
  exact ⟨toIcoDiv a₂ hb x, self_sub_toIcoMod a₂ hb x⟩
#align to_Ico_mod_to_Ico_mod toIcoMod_toIcoMod

@[simp]
theorem toIcoMod_toIocMod (a₁ a₂ : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoMod a₁ hb (toIocMod a₂ hb x) = toIcoMod a₁ hb x :=
  by
  rw [toIcoMod_eq_toIcoMod]
  exact ⟨toIocDiv a₂ hb x, self_sub_toIocMod a₂ hb x⟩
#align to_Ico_mod_to_Ioc_mod toIcoMod_toIocMod

@[simp]
theorem toIocMod_toIocMod (a₁ a₂ : α) {b : α} (hb : 0 < b) (x : α) :
    toIocMod a₁ hb (toIocMod a₂ hb x) = toIocMod a₁ hb x :=
  by
  rw [toIocMod_eq_toIocMod]
  exact ⟨toIocDiv a₂ hb x, self_sub_toIocMod a₂ hb x⟩
#align to_Ioc_mod_to_Ioc_mod toIocMod_toIocMod

@[simp]
theorem toIocMod_toIcoMod (a₁ a₂ : α) {b : α} (hb : 0 < b) (x : α) :
    toIocMod a₁ hb (toIcoMod a₂ hb x) = toIocMod a₁ hb x :=
  by
  rw [toIocMod_eq_toIocMod]
  exact ⟨toIcoDiv a₂ hb x, self_sub_toIcoMod a₂ hb x⟩
#align to_Ioc_mod_to_Ico_mod toIocMod_toIcoMod

theorem toIcoMod_periodic (a : α) {b : α} (hb : 0 < b) : Function.Periodic (toIcoMod a hb) b :=
  toIcoMod_add_right a hb
#align to_Ico_mod_periodic toIcoMod_periodic

theorem toIocMod_periodic (a : α) {b : α} (hb : 0 < b) : Function.Periodic (toIocMod a hb) b :=
  toIocMod_add_right a hb
#align to_Ioc_mod_periodic toIocMod_periodic

/-- `to_Ico_mod` as an equiv from the quotient. -/
@[simps symm_apply]
def quotientAddGroup.equivIcoMod (a : α) {b : α} (hb : 0 < b) :
    α ⧸ AddSubgroup.zmultiples b ≃ Set.Ico a (a + b)
    where
  toFun x :=
    ⟨(toIcoMod_periodic a hb).lift x, QuotientAddGroup.induction_on' x <| toIcoMod_mem_Ico a hb⟩
  invFun := coe
  right_inv x := Subtype.ext <| (toIcoMod_eq_self hb).mpr x.Prop
  left_inv x := by
    induction x using QuotientAddGroup.induction_on'
    dsimp
    rw [quotientAddGroup.eq_iff_sub_mem, toIcoMod_sub_self]
    apply AddSubgroup.zsmul_mem_zmultiples
#align quotient_add_group.equiv_Ico_mod quotientAddGroup.equivIcoMod

@[simp]
theorem quotientAddGroup.equivIcoMod_coe (a : α) {b : α} (hb : 0 < b) (x : α) :
    quotientAddGroup.equivIcoMod a hb ↑x = ⟨toIcoMod a hb x, toIcoMod_mem_Ico a hb _⟩ :=
  rfl
#align quotient_add_group.equiv_Ico_mod_coe quotientAddGroup.equivIcoMod_coe

/-- `to_Ioc_mod` as an equiv  from the quotient. -/
@[simps symm_apply]
def quotientAddGroup.equivIocMod (a : α) {b : α} (hb : 0 < b) :
    α ⧸ AddSubgroup.zmultiples b ≃ Set.Ioc a (a + b)
    where
  toFun x :=
    ⟨(toIocMod_periodic a hb).lift x, QuotientAddGroup.induction_on' x <| toIocMod_mem_Ioc a hb⟩
  invFun := coe
  right_inv x := Subtype.ext <| (toIocMod_eq_self hb).mpr x.Prop
  left_inv x := by
    induction x using QuotientAddGroup.induction_on'
    dsimp
    rw [quotientAddGroup.eq_iff_sub_mem, toIocMod_sub_self]
    apply AddSubgroup.zsmul_mem_zmultiples
#align quotient_add_group.equiv_Ioc_mod quotientAddGroup.equivIocMod

@[simp]
theorem quotientAddGroup.equivIocMod_coe (a : α) {b : α} (hb : 0 < b) (x : α) :
    quotientAddGroup.equivIocMod a hb ↑x = ⟨toIocMod a hb x, toIocMod_mem_Ioc a hb _⟩ :=
  rfl
#align quotient_add_group.equiv_Ioc_mod_coe quotientAddGroup.equivIocMod_coe

end LinearOrderedAddCommGroup

section LinearOrderedField

variable {α : Type _} [LinearOrderedField α] [FloorRing α]

theorem toIcoDiv_eq_floor (a : α) {b : α} (hb : 0 < b) (x : α) : toIcoDiv a hb x = ⌊(x - a) / b⌋ :=
  by
  refine' (eq_toIcoDiv_of_sub_zsmul_mem_Ico hb _).symm
  rw [Set.mem_Ico, zsmul_eq_mul, ← sub_nonneg, add_comm, sub_right_comm, ← sub_lt_iff_lt_add,
    sub_right_comm _ _ a]
  exact ⟨Int.sub_floor_div_mul_nonneg _ hb, Int.sub_floor_div_mul_lt _ hb⟩
#align to_Ico_div_eq_floor toIcoDiv_eq_floor

theorem toIocDiv_eq_neg_floor (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocDiv a hb x = -⌊(a + b - x) / b⌋ :=
  by
  refine' (eq_toIocDiv_of_sub_zsmul_mem_Ioc hb _).symm
  rw [Set.mem_Ioc, zsmul_eq_mul, Int.cast_neg, neg_mul, sub_neg_eq_add, ← sub_nonneg,
    sub_add_eq_sub_sub]
  refine' ⟨_, Int.sub_floor_div_mul_nonneg _ hb⟩
  rw [← add_lt_add_iff_right b, add_assoc, add_comm x, ← sub_lt_iff_lt_add, add_comm (_ * _), ←
    sub_lt_iff_lt_add]
  exact Int.sub_floor_div_mul_lt _ hb
#align to_Ioc_div_eq_neg_floor toIocDiv_eq_neg_floor

theorem toIcoDiv_zero_one (x : α) : toIcoDiv (0 : α) zero_lt_one x = ⌊x⌋ := by
  simp [toIcoDiv_eq_floor]
#align to_Ico_div_zero_one toIcoDiv_zero_one

theorem toIcoMod_eq_add_fract_mul (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIcoMod a hb x = a + Int.fract ((x - a) / b) * b :=
  by
  rw [toIcoMod, toIcoDiv_eq_floor, Int.fract]
  field_simp [hb.ne.symm]
  ring
#align to_Ico_mod_eq_add_fract_mul toIcoMod_eq_add_fract_mul

theorem toIcoMod_eq_fract_mul {b : α} (hb : 0 < b) (x : α) :
    toIcoMod 0 hb x = Int.fract (x / b) * b := by simp [toIcoMod_eq_add_fract_mul]
#align to_Ico_mod_eq_fract_mul toIcoMod_eq_fract_mul

theorem toIocMod_eq_sub_fract_mul (a : α) {b : α} (hb : 0 < b) (x : α) :
    toIocMod a hb x = a + b - Int.fract ((a + b - x) / b) * b :=
  by
  rw [toIocMod, toIocDiv_eq_neg_floor, Int.fract]
  field_simp [hb.ne.symm]
  ring
#align to_Ioc_mod_eq_sub_fract_mul toIocMod_eq_sub_fract_mul

theorem toIcoMod_zero_one (x : α) : toIcoMod (0 : α) zero_lt_one x = Int.fract x := by
  simp [toIcoMod_eq_add_fract_mul]
#align to_Ico_mod_zero_one toIcoMod_zero_one

end LinearOrderedField

