/-
Copyright (c) 2014 Robert Lewis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Robert Lewis, Leonardo de Moura, Mario Carneiro, Floris van Doorn
-/
import Algebra.Group.Even
import Algebra.CharZero.Lemmas
import Algebra.GroupWithZero.Power
import Algebra.Order.Field.Basic

#align_import algebra.order.field.power from "leanprover-community/mathlib"@"acb3d204d4ee883eb686f45d486a2a6811a01329"

/-!
# Lemmas about powers in ordered fields.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


variable {α : Type _}

open Function

section LinearOrderedSemifield

variable [LinearOrderedSemifield α] {a b c d e : α} {m n : ℤ}

/-! ### Integer powers -/


#print zpow_le_of_le /-
theorem zpow_le_of_le (ha : 1 ≤ a) (h : m ≤ n) : a ^ m ≤ a ^ n :=
  by
  have ha₀ : 0 < a := one_pos.trans_le ha
  lift n - m to ℕ using sub_nonneg.2 h with k hk
  calc
    a ^ m = a ^ m * 1 := (mul_one _).symm
    _ ≤ a ^ m * a ^ k :=
      (mul_le_mul_of_nonneg_left (one_le_pow_of_one_le ha _) (zpow_nonneg ha₀.le _))
    _ = a ^ n := by rw [← zpow_natCast, ← zpow_add₀ ha₀.ne', hk, add_sub_cancel]
#align zpow_le_of_le zpow_le_of_le
-/

#print zpow_le_one_of_nonpos /-
theorem zpow_le_one_of_nonpos (ha : 1 ≤ a) (hn : n ≤ 0) : a ^ n ≤ 1 :=
  (zpow_le_of_le ha hn).trans_eq <| zpow_zero _
#align zpow_le_one_of_nonpos zpow_le_one_of_nonpos
-/

#print one_le_zpow_of_nonneg /-
theorem one_le_zpow_of_nonneg (ha : 1 ≤ a) (hn : 0 ≤ n) : 1 ≤ a ^ n :=
  (zpow_zero _).symm.trans_le <| zpow_le_of_le ha hn
#align one_le_zpow_of_nonneg one_le_zpow_of_nonneg
-/

#print Nat.zpow_pos_of_pos /-
protected theorem Nat.zpow_pos_of_pos {a : ℕ} (h : 0 < a) (n : ℤ) : 0 < (a : α) ^ n := by
  apply zpow_pos_of_pos; exact_mod_cast h
#align nat.zpow_pos_of_pos Nat.zpow_pos_of_pos
-/

#print Nat.zpow_ne_zero_of_pos /-
theorem Nat.zpow_ne_zero_of_pos {a : ℕ} (h : 0 < a) (n : ℤ) : (a : α) ^ n ≠ 0 :=
  (Nat.zpow_pos_of_pos h n).ne'
#align nat.zpow_ne_zero_of_pos Nat.zpow_ne_zero_of_pos
-/

#print one_lt_zpow /-
theorem one_lt_zpow (ha : 1 < a) : ∀ n : ℤ, 0 < n → 1 < a ^ n
  | (n : ℕ), h => (zpow_natCast _ _).symm.subst (one_lt_pow ha <| Int.natCast_ne_zero.mp h.ne')
  | -[n+1], h => ((Int.negSucc_not_pos _).mp h).elim
#align one_lt_zpow one_lt_zpow
-/

#print zpow_strictMono /-
theorem zpow_strictMono (hx : 1 < a) : StrictMono ((· ^ ·) a : ℤ → α) :=
  strictMono_int_of_lt_succ fun n =>
    have xpos : 0 < a := zero_lt_one.trans hx
    calc
      a ^ n < a ^ n * a := lt_mul_of_one_lt_right (zpow_pos_of_pos xpos _) hx
      _ = a ^ (n + 1) := (zpow_add_one₀ xpos.ne' _).symm
#align zpow_strict_mono zpow_strictMono
-/

#print zpow_strictAnti /-
theorem zpow_strictAnti (h₀ : 0 < a) (h₁ : a < 1) : StrictAnti ((· ^ ·) a : ℤ → α) :=
  strictAnti_int_of_succ_lt fun n =>
    calc
      a ^ (n + 1) = a ^ n * a := zpow_add_one₀ h₀.ne' _
      _ < a ^ n * 1 := ((mul_lt_mul_left <| zpow_pos_of_pos h₀ _).2 h₁)
      _ = a ^ n := mul_one _
#align zpow_strict_anti zpow_strictAnti
-/

#print zpow_lt_iff_lt /-
@[simp]
theorem zpow_lt_iff_lt (hx : 1 < a) : a ^ m < a ^ n ↔ m < n :=
  (zpow_strictMono hx).lt_iff_lt
#align zpow_lt_iff_lt zpow_lt_iff_lt
-/

#print zpow_le_iff_le /-
@[simp]
theorem zpow_le_iff_le (hx : 1 < a) : a ^ m ≤ a ^ n ↔ m ≤ n :=
  (zpow_strictMono hx).le_iff_le
#align zpow_le_iff_le zpow_le_iff_le
-/

#print div_pow_le /-
@[simp]
theorem div_pow_le (ha : 0 ≤ a) (hb : 1 ≤ b) (k : ℕ) : a / b ^ k ≤ a :=
  div_le_self ha <| one_le_pow_of_one_le hb _
#align div_pow_le div_pow_le
-/

#print zpow_injective /-
theorem zpow_injective (h₀ : 0 < a) (h₁ : a ≠ 1) : Injective ((· ^ ·) a : ℤ → α) :=
  by
  rcases h₁.lt_or_lt with (H | H)
  · exact (zpow_strictAnti h₀ H).Injective
  · exact (zpow_strictMono H).Injective
#align zpow_injective zpow_injective
-/

#print zpow_inj /-
@[simp]
theorem zpow_inj (h₀ : 0 < a) (h₁ : a ≠ 1) : a ^ m = a ^ n ↔ m = n :=
  (zpow_injective h₀ h₁).eq_iff
#align zpow_inj zpow_inj
-/

#print zpow_le_max_of_min_le /-
theorem zpow_le_max_of_min_le {x : α} (hx : 1 ≤ x) {a b c : ℤ} (h : min a b ≤ c) :
    x ^ (-c) ≤ max (x ^ (-a)) (x ^ (-b)) :=
  haveI : Antitone fun n : ℤ => x ^ (-n) := fun m n h => zpow_le_of_le hx (neg_le_neg h)
  (this h).trans_eq this.map_min
#align zpow_le_max_of_min_le zpow_le_max_of_min_le
-/

#print zpow_le_max_iff_min_le /-
theorem zpow_le_max_iff_min_le {x : α} (hx : 1 < x) {a b c : ℤ} :
    x ^ (-c) ≤ max (x ^ (-a)) (x ^ (-b)) ↔ min a b ≤ c := by
  simp_rw [le_max_iff, min_le_iff, zpow_le_iff_le hx, neg_le_neg_iff]
#align zpow_le_max_iff_min_le zpow_le_max_iff_min_le
-/

end LinearOrderedSemifield

section LinearOrderedField

variable [LinearOrderedField α] {a b c d : α} {n : ℤ}

/-! ### Lemmas about powers to numerals. -/


theorem zpow_bit0_nonneg (a : α) (n : ℤ) : 0 ≤ a ^ bit0 n :=
  (hMul_self_nonneg _).trans_eq <| (zpow_bit0 _ _).symm
#align zpow_bit0_nonneg zpow_bit0_nonneg

#print zpow_two_nonneg /-
theorem zpow_two_nonneg (a : α) : 0 ≤ a ^ (2 : ℤ) :=
  zpow_bit0_nonneg _ _
#align zpow_two_nonneg zpow_two_nonneg
-/

#print zpow_neg_two_nonneg /-
theorem zpow_neg_two_nonneg (a : α) : 0 ≤ a ^ (-2 : ℤ) :=
  zpow_bit0_nonneg _ (-1)
#align zpow_neg_two_nonneg zpow_neg_two_nonneg
-/

theorem zpow_bit0_pos (h : a ≠ 0) (n : ℤ) : 0 < a ^ bit0 n :=
  (zpow_bit0_nonneg a n).lt_of_ne (zpow_ne_zero _ h).symm
#align zpow_bit0_pos zpow_bit0_pos

#print zpow_two_pos_of_ne_zero /-
theorem zpow_two_pos_of_ne_zero (h : a ≠ 0) : 0 < a ^ (2 : ℤ) :=
  zpow_bit0_pos h _
#align zpow_two_pos_of_ne_zero zpow_two_pos_of_ne_zero
-/

@[simp]
theorem zpow_bit0_pos_iff (hn : n ≠ 0) : 0 < a ^ bit0 n ↔ a ≠ 0 :=
  ⟨by rintro h rfl; refine' (zero_zpow _ _).not_gt h; rwa [bit0_ne_zero], fun h =>
    zpow_bit0_pos h _⟩
#align zpow_bit0_pos_iff zpow_bit0_pos_iff

@[simp]
theorem zpow_bit1_neg_iff : a ^ bit1 n < 0 ↔ a < 0 :=
  ⟨fun h => not_le.1 fun h' => not_le.2 h <| zpow_nonneg h' _, fun h => by
    rw [bit1, zpow_add_one₀ h.ne] <;> exact mul_neg_of_pos_of_neg (zpow_bit0_pos h.ne _) h⟩
#align zpow_bit1_neg_iff zpow_bit1_neg_iff

@[simp]
theorem zpow_bit1_nonneg_iff : 0 ≤ a ^ bit1 n ↔ 0 ≤ a :=
  le_iff_le_iff_lt_iff_lt.2 zpow_bit1_neg_iff
#align zpow_bit1_nonneg_iff zpow_bit1_nonneg_iff

@[simp]
theorem zpow_bit1_nonpos_iff : a ^ bit1 n ≤ 0 ↔ a ≤ 0 := by
  rw [le_iff_lt_or_eq, le_iff_lt_or_eq, zpow_bit1_neg_iff, zpow_eq_zero_iff (Int.bit1_ne_zero n)]
#align zpow_bit1_nonpos_iff zpow_bit1_nonpos_iff

@[simp]
theorem zpow_bit1_pos_iff : 0 < a ^ bit1 n ↔ 0 < a :=
  lt_iff_lt_of_le_iff_le zpow_bit1_nonpos_iff
#align zpow_bit1_pos_iff zpow_bit1_pos_iff

#print Even.zpow_nonneg /-
protected theorem Even.zpow_nonneg (hn : Even n) (a : α) : 0 ≤ a ^ n := by
  obtain ⟨k, rfl⟩ := hn <;> exact zpow_bit0_nonneg _ _
#align even.zpow_nonneg Even.zpow_nonneg
-/

#print Even.zpow_pos_iff /-
theorem Even.zpow_pos_iff (hn : Even n) (h : n ≠ 0) : 0 < a ^ n ↔ a ≠ 0 := by
  obtain ⟨k, rfl⟩ := hn <;> exact zpow_bit0_pos_iff (by rintro rfl <;> simpa using h)
#align even.zpow_pos_iff Even.zpow_pos_iff
-/

#print Odd.zpow_neg_iff /-
theorem Odd.zpow_neg_iff (hn : Odd n) : a ^ n < 0 ↔ a < 0 := by
  cases' hn with k hk <;> simpa only [hk, two_mul] using zpow_bit1_neg_iff
#align odd.zpow_neg_iff Odd.zpow_neg_iff
-/

#print Odd.zpow_nonneg_iff /-
protected theorem Odd.zpow_nonneg_iff (hn : Odd n) : 0 ≤ a ^ n ↔ 0 ≤ a := by
  cases' hn with k hk <;> simpa only [hk, two_mul] using zpow_bit1_nonneg_iff
#align odd.zpow_nonneg_iff Odd.zpow_nonneg_iff
-/

#print Odd.zpow_nonpos_iff /-
theorem Odd.zpow_nonpos_iff (hn : Odd n) : a ^ n ≤ 0 ↔ a ≤ 0 := by
  cases' hn with k hk <;> simpa only [hk, two_mul] using zpow_bit1_nonpos_iff
#align odd.zpow_nonpos_iff Odd.zpow_nonpos_iff
-/

#print Odd.zpow_pos_iff /-
theorem Odd.zpow_pos_iff (hn : Odd n) : 0 < a ^ n ↔ 0 < a := by
  cases' hn with k hk <;> simpa only [hk, two_mul] using zpow_bit1_pos_iff
#align odd.zpow_pos_iff Odd.zpow_pos_iff
-/

alias ⟨_, Even.zpow_pos⟩ := Even.zpow_pos_iff
#align even.zpow_pos Even.zpow_pos

alias ⟨_, Odd.zpow_neg⟩ := Odd.zpow_neg_iff
#align odd.zpow_neg Odd.zpow_neg

alias ⟨_, Odd.zpow_nonpos⟩ := Odd.zpow_nonpos_iff
#align odd.zpow_nonpos Odd.zpow_nonpos

#print Even.zpow_abs /-
theorem Even.zpow_abs {p : ℤ} (hp : Even p) (a : α) : |a| ^ p = a ^ p := by
  cases' abs_choice a with h h <;> simp only [h, hp.neg_zpow _]
#align even.zpow_abs Even.zpow_abs
-/

@[simp]
theorem zpow_bit0_abs (a : α) (p : ℤ) : |a| ^ bit0 p = a ^ bit0 p :=
  (even_bit0 _).zpow_abs _
#align zpow_bit0_abs zpow_bit0_abs

/-! ### Miscellaneous lemmmas -/


#print Nat.cast_le_pow_sub_div_sub /-
/-- Bernoulli's inequality reformulated to estimate `(n : α)`. -/
theorem Nat.cast_le_pow_sub_div_sub (H : 1 < a) (n : ℕ) : (n : α) ≤ (a ^ n - 1) / (a - 1) :=
  (le_div_iff (sub_pos.2 H)).2 <|
    le_sub_left_of_add_le <| one_add_mul_sub_le_pow ((neg_le_self zero_le_one).trans H.le) _
#align nat.cast_le_pow_sub_div_sub Nat.cast_le_pow_sub_div_sub
-/

#print Nat.cast_le_pow_div_sub /-
/-- For any `a > 1` and a natural `n` we have `n ≤ a ^ n / (a - 1)`. See also
`nat.cast_le_pow_sub_div_sub` for a stronger inequality with `a ^ n - 1` in the numerator. -/
theorem Nat.cast_le_pow_div_sub (H : 1 < a) (n : ℕ) : (n : α) ≤ a ^ n / (a - 1) :=
  (n.cast_le_pow_sub_div_sub H).trans <|
    div_le_div_of_le (sub_nonneg.2 H.le) (sub_le_self _ zero_le_one)
#align nat.cast_le_pow_div_sub Nat.cast_le_pow_div_sub
-/

end LinearOrderedField

