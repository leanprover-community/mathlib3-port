/-
Copyright (c) 2014 Floris van Doorn (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn, Leonardo de Moura, Jeremy Avigad, Mario Carneiro
-/
import Mathbin.Algebra.GroupPower.Order

/-! # `nat.pow`

Results on the power operation on natural numbers.
-/


namespace Nat

/-! ### `pow` -/


/- warning: nat.pow_le_pow_of_le_left -> Nat.pow_le_pow_of_le_left is a dubious translation:
lean 3 declaration is
  forall {x : Nat} {y : Nat}, (LE.le.{0} Nat Nat.hasLe x y) -> (forall (i : Nat), LE.le.{0} Nat Nat.hasLe (HPow.hPow.{0, 0, 0} Nat Nat Nat (instHPow.{0, 0} Nat Nat (Monoid.hasPow.{0} Nat Nat.monoid)) x i) (HPow.hPow.{0, 0, 0} Nat Nat Nat (instHPow.{0, 0} Nat Nat (Monoid.hasPow.{0} Nat Nat.monoid)) y i))
but is expected to have type
  forall {n : Nat} {m : Nat}, (LE.le.{0} Nat instLENat n m) -> (forall (i : Nat), LE.le.{0} Nat instLENat (HPow.hPow.{0, 0, 0} Nat Nat Nat (instHPow.{0, 0} Nat Nat instPowNat) n i) (HPow.hPow.{0, 0, 0} Nat Nat Nat (instHPow.{0, 0} Nat Nat instPowNat) m i))
Case conversion may be inaccurate. Consider using '#align nat.pow_le_pow_of_le_left Nat.pow_le_pow_of_le_leftₓ'. -/
-- This is redundant with `pow_le_pow_of_le_left'`,
-- We leave a version in the `nat` namespace as well.
-- (The global `pow_le_pow_of_le_left` needs an extra hypothesis `0 ≤ x`.)
protected theorem pow_le_pow_of_le_left {x y : ℕ} (H : x ≤ y) : ∀ i : ℕ, x ^ i ≤ y ^ i :=
  pow_le_pow_of_le_left' H
#align nat.pow_le_pow_of_le_left Nat.pow_le_pow_of_le_left

/- warning: nat.pow_le_pow_of_le_right -> Nat.pow_le_pow_of_le_right is a dubious translation:
lean 3 declaration is
  forall {x : Nat}, (LT.lt.{0} Nat Nat.hasLt (OfNat.ofNat.{0} Nat 0 (OfNat.mk.{0} Nat 0 (Zero.zero.{0} Nat Nat.hasZero))) x) -> (forall {i : Nat} {j : Nat}, (LE.le.{0} Nat Nat.hasLe i j) -> (LE.le.{0} Nat Nat.hasLe (HPow.hPow.{0, 0, 0} Nat Nat Nat (instHPow.{0, 0} Nat Nat (Monoid.hasPow.{0} Nat Nat.monoid)) x i) (HPow.hPow.{0, 0, 0} Nat Nat Nat (instHPow.{0, 0} Nat Nat (Monoid.hasPow.{0} Nat Nat.monoid)) x j)))
but is expected to have type
  forall {n : Nat}, (GT.gt.{0} Nat instLTNat n (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0))) -> (forall {i : Nat} {j : Nat}, (LE.le.{0} Nat instLENat i j) -> (LE.le.{0} Nat instLENat (HPow.hPow.{0, 0, 0} Nat Nat Nat (instHPow.{0, 0} Nat Nat instPowNat) n i) (HPow.hPow.{0, 0, 0} Nat Nat Nat (instHPow.{0, 0} Nat Nat instPowNat) n j)))
Case conversion may be inaccurate. Consider using '#align nat.pow_le_pow_of_le_right Nat.pow_le_pow_of_le_rightₓ'. -/
theorem pow_le_pow_of_le_right {x : ℕ} (H : 0 < x) {i j : ℕ} (h : i ≤ j) : x ^ i ≤ x ^ j :=
  pow_le_pow' H h
#align nat.pow_le_pow_of_le_right Nat.pow_le_pow_of_le_right

theorem pow_lt_pow_of_lt_left {x y : ℕ} (H : x < y) {i} (h : 0 < i) : x ^ i < y ^ i :=
  pow_lt_pow_of_lt_left H (zero_le _) h
#align nat.pow_lt_pow_of_lt_left Nat.pow_lt_pow_of_lt_left

theorem pow_lt_pow_of_lt_right {x : ℕ} (H : 1 < x) {i j : ℕ} (h : i < j) : x ^ i < x ^ j :=
  pow_lt_pow H h
#align nat.pow_lt_pow_of_lt_right Nat.pow_lt_pow_of_lt_right

theorem pow_lt_pow_succ {p : ℕ} (h : 1 < p) (n : ℕ) : p ^ n < p ^ (n + 1) :=
  pow_lt_pow_of_lt_right h n.lt_succ_self
#align nat.pow_lt_pow_succ Nat.pow_lt_pow_succ

theorem lt_pow_self {p : ℕ} (h : 1 < p) : ∀ n : ℕ, n < p ^ n
  | 0 => by simp [zero_lt_one]
  | n + 1 =>
    calc
      n + 1 < p ^ n + 1 := Nat.add_lt_add_right (lt_pow_self _) _
      _ ≤ p ^ (n + 1) := pow_lt_pow_succ h _
      
#align nat.lt_pow_self Nat.lt_pow_self

theorem lt_two_pow (n : ℕ) : n < 2 ^ n :=
  lt_pow_self (by decide) n
#align nat.lt_two_pow Nat.lt_two_pow

theorem one_le_pow (n m : ℕ) (h : 0 < m) : 1 ≤ m ^ n := by
  rw [← one_pow n]
  exact Nat.pow_le_pow_of_le_left h n
#align nat.one_le_pow Nat.one_le_pow

theorem one_le_pow' (n m : ℕ) : 1 ≤ (m + 1) ^ n :=
  one_le_pow n (m + 1) (succ_pos m)
#align nat.one_le_pow' Nat.one_le_pow'

theorem one_le_two_pow (n : ℕ) : 1 ≤ 2 ^ n :=
  one_le_pow n 2 (by decide)
#align nat.one_le_two_pow Nat.one_le_two_pow

theorem one_lt_pow (n m : ℕ) (h₀ : 0 < n) (h₁ : 1 < m) : 1 < m ^ n := by
  rw [← one_pow n]
  exact pow_lt_pow_of_lt_left h₁ h₀
#align nat.one_lt_pow Nat.one_lt_pow

theorem one_lt_pow' (n m : ℕ) : 1 < (m + 2) ^ (n + 1) :=
  one_lt_pow (n + 1) (m + 2) (succ_pos n) (Nat.lt_of_sub_eq_succ rfl)
#align nat.one_lt_pow' Nat.one_lt_pow'

@[simp]
theorem one_lt_pow_iff {k n : ℕ} (h : 0 ≠ k) : 1 < n ^ k ↔ 1 < n := by
  cases n
  · cases k <;> simp [zero_pow_eq]
    
  cases n
  · rw [one_pow]
    
  refine' ⟨fun _ => one_lt_succ_succ n, fun _ => _⟩
  induction' k with k hk
  · exact absurd rfl h
    
  cases k
  · simp
    
  exact one_lt_mul (one_lt_succ_succ _).le (hk (succ_ne_zero k).symm)
#align nat.one_lt_pow_iff Nat.one_lt_pow_iff

theorem one_lt_two_pow (n : ℕ) (h₀ : 0 < n) : 1 < 2 ^ n :=
  one_lt_pow n 2 h₀ (by decide)
#align nat.one_lt_two_pow Nat.one_lt_two_pow

theorem one_lt_two_pow' (n : ℕ) : 1 < 2 ^ (n + 1) :=
  one_lt_pow (n + 1) 2 (succ_pos n) (by decide)
#align nat.one_lt_two_pow' Nat.one_lt_two_pow'

theorem pow_right_strict_mono {x : ℕ} (k : 2 ≤ x) : StrictMono fun n : ℕ => x ^ n := fun _ _ =>
  pow_lt_pow_of_lt_right k
#align nat.pow_right_strict_mono Nat.pow_right_strict_mono

theorem pow_le_iff_le_right {x m n : ℕ} (k : 2 ≤ x) : x ^ m ≤ x ^ n ↔ m ≤ n :=
  StrictMono.le_iff_le (pow_right_strict_mono k)
#align nat.pow_le_iff_le_right Nat.pow_le_iff_le_right

theorem pow_lt_iff_lt_right {x m n : ℕ} (k : 2 ≤ x) : x ^ m < x ^ n ↔ m < n :=
  StrictMono.lt_iff_lt (pow_right_strict_mono k)
#align nat.pow_lt_iff_lt_right Nat.pow_lt_iff_lt_right

theorem pow_right_injective {x : ℕ} (k : 2 ≤ x) : Function.Injective fun n : ℕ => x ^ n :=
  StrictMono.injective (pow_right_strict_mono k)
#align nat.pow_right_injective Nat.pow_right_injective

theorem pow_left_strict_mono {m : ℕ} (k : 1 ≤ m) : StrictMono fun x : ℕ => x ^ m := fun _ _ h =>
  pow_lt_pow_of_lt_left h k
#align nat.pow_left_strict_mono Nat.pow_left_strict_mono

theorem mul_lt_mul_pow_succ {n a q : ℕ} (a0 : 0 < a) (q1 : 1 < q) : n * q < a * q ^ (n + 1) := by
  rw [pow_succ', ← mul_assoc, mul_lt_mul_right (zero_lt_one.trans q1)]
  exact lt_mul_of_one_le_of_lt (nat.succ_le_iff.mpr a0) (Nat.lt_pow_self q1 n)
#align nat.mul_lt_mul_pow_succ Nat.mul_lt_mul_pow_succ

end Nat

theorem StrictMono.nat_pow {n : ℕ} (hn : 1 ≤ n) {f : ℕ → ℕ} (hf : StrictMono f) :
    StrictMono fun m => f m ^ n :=
  (Nat.pow_left_strict_mono hn).comp hf
#align strict_mono.nat_pow StrictMono.nat_pow

namespace Nat

theorem pow_le_iff_le_left {m x y : ℕ} (k : 1 ≤ m) : x ^ m ≤ y ^ m ↔ x ≤ y :=
  StrictMono.le_iff_le (pow_left_strict_mono k)
#align nat.pow_le_iff_le_left Nat.pow_le_iff_le_left

theorem pow_lt_iff_lt_left {m x y : ℕ} (k : 1 ≤ m) : x ^ m < y ^ m ↔ x < y :=
  StrictMono.lt_iff_lt (pow_left_strict_mono k)
#align nat.pow_lt_iff_lt_left Nat.pow_lt_iff_lt_left

theorem pow_left_injective {m : ℕ} (k : 1 ≤ m) : Function.Injective fun x : ℕ => x ^ m :=
  StrictMono.injective (pow_left_strict_mono k)
#align nat.pow_left_injective Nat.pow_left_injective

theorem sq_sub_sq (a b : ℕ) : a ^ 2 - b ^ 2 = (a + b) * (a - b) := by
  rw [sq, sq]
  exact Nat.mul_self_sub_mul_self_eq a b
#align nat.sq_sub_sq Nat.sq_sub_sq

alias sq_sub_sq ← pow_two_sub_pow_two

/-! ### `pow` and `mod` / `dvd` -/


theorem pow_mod (a b n : ℕ) : a ^ b % n = (a % n) ^ b % n := by
  induction' b with b ih
  rfl; simp [pow_succ, Nat.mul_mod, ih]
#align nat.pow_mod Nat.pow_mod

theorem mod_pow_succ {b : ℕ} (w m : ℕ) : m % b ^ succ w = b * (m / b % b ^ w) + m % b := by
  by_cases b_h : b = 0
  · simp [b_h, pow_succ]
    
  have b_pos := Nat.pos_of_ne_zero b_h
  apply Nat.strong_induction_on m
  clear m
  intro p IH
  cases' lt_or_ge p (b ^ succ w) with h₁ h₁
  -- base case: p < b^succ w
  · have h₂ : p / b < b ^ w := by
      rw [div_lt_iff_lt_mul b_pos]
      simpa [pow_succ'] using h₁
    rw [mod_eq_of_lt h₁, mod_eq_of_lt h₂]
    simp [div_add_mod]
    
  -- step: p ≥ b^succ w
  · -- Generate condition for induction hypothesis
    have h₂ : p - b ^ succ w < p := tsub_lt_self ((pow_pos b_pos _).trans_le h₁) (pow_pos b_pos _)
    -- Apply induction
    rw [mod_eq_sub_mod h₁, IH _ h₂]
    -- Normalize goal and h1
    simp only [pow_succ]
    simp only [GE.ge, pow_succ] at h₁
    -- Pull subtraction outside mod and div
    rw [sub_mul_mod _ _ _ h₁, sub_mul_div _ _ _ h₁]
    -- Cancel subtraction inside mod b^w
    have p_b_ge : b ^ w ≤ p / b := by
      rw [le_div_iff_mul_le b_pos, mul_comm]
      exact h₁
    rw [Eq.symm (mod_eq_sub_mod p_b_ge)]
    
#align nat.mod_pow_succ Nat.mod_pow_succ

theorem pow_dvd_pow_iff_pow_le_pow {k l : ℕ} : ∀ {x : ℕ} (w : 0 < x), x ^ k ∣ x ^ l ↔ x ^ k ≤ x ^ l
  | x + 1, w => by
    constructor
    · intro a
      exact le_of_dvd (pow_pos (succ_pos x) l) a
      
    · intro a
      cases' x with x
      · simp only [one_pow]
        
      · have le := (pow_le_iff_le_right (Nat.le_add_left _ _)).mp a
        use (x + 2) ^ (l - k)
        rw [← pow_add, add_comm k, tsub_add_cancel_of_le le]
        
      
#align nat.pow_dvd_pow_iff_pow_le_pow Nat.pow_dvd_pow_iff_pow_le_pow

/-- If `1 < x`, then `x^k` divides `x^l` if and only if `k` is at most `l`. -/
theorem pow_dvd_pow_iff_le_right {x k l : ℕ} (w : 1 < x) : x ^ k ∣ x ^ l ↔ k ≤ l := by
  rw [pow_dvd_pow_iff_pow_le_pow (lt_of_succ_lt w), pow_le_iff_le_right w]
#align nat.pow_dvd_pow_iff_le_right Nat.pow_dvd_pow_iff_le_right

theorem pow_dvd_pow_iff_le_right' {b k l : ℕ} : (b + 2) ^ k ∣ (b + 2) ^ l ↔ k ≤ l :=
  pow_dvd_pow_iff_le_right (Nat.lt_of_sub_eq_succ rfl)
#align nat.pow_dvd_pow_iff_le_right' Nat.pow_dvd_pow_iff_le_right'

theorem not_pos_pow_dvd : ∀ {p k : ℕ} (hp : 1 < p) (hk : 1 < k), ¬p ^ k ∣ p
  | succ p, succ k, hp, hk, h =>
    have : succ p * succ p ^ k ∣ succ p * 1 := by simpa [pow_succ] using h
    have : succ p ^ k ∣ 1 := dvd_of_mul_dvd_mul_left (succ_pos _) this
    have he : succ p ^ k = 1 := eq_one_of_dvd_one this
    have : k < succ p ^ k := lt_pow_self hp k
    have : k < 1 := by rwa [he] at this
    have : k = 0 := Nat.eq_zero_of_le_zero <| le_of_lt_succ this
    have : 1 < 1 := by rwa [this] at hk
    absurd this (by decide)
#align nat.not_pos_pow_dvd Nat.not_pos_pow_dvd

theorem pow_dvd_of_le_of_pow_dvd {p m n k : ℕ} (hmn : m ≤ n) (hdiv : p ^ n ∣ k) : p ^ m ∣ k :=
  (pow_dvd_pow _ hmn).trans hdiv
#align nat.pow_dvd_of_le_of_pow_dvd Nat.pow_dvd_of_le_of_pow_dvd

theorem dvd_of_pow_dvd {p k m : ℕ} (hk : 1 ≤ k) (hpk : p ^ k ∣ m) : p ∣ m := by
  rw [← pow_one p] <;> exact pow_dvd_of_le_of_pow_dvd hk hpk
#align nat.dvd_of_pow_dvd Nat.dvd_of_pow_dvd

theorem pow_div {x m n : ℕ} (h : n ≤ m) (hx : 0 < x) : x ^ m / x ^ n = x ^ (m - n) := by
  rw [Nat.div_eq_iff_eq_mul_left (pow_pos hx n) (pow_dvd_pow _ h), pow_sub_mul_pow _ h]
#align nat.pow_div Nat.pow_div

theorem lt_of_pow_dvd_right {p i n : ℕ} (hn : n ≠ 0) (hp : 2 ≤ p) (h : p ^ i ∣ n) : i < n := by
  rw [← pow_lt_iff_lt_right hp]
  exact lt_of_le_of_lt (le_of_dvd hn.bot_lt h) (lt_pow_self (succ_le_iff.mp hp) n)
#align nat.lt_of_pow_dvd_right Nat.lt_of_pow_dvd_right

/-! ### `shiftl` and `shiftr` -/


theorem shiftl_eq_mul_pow (m) : ∀ n, shiftl m n = m * 2 ^ n
  | 0 => (Nat.mul_one _).symm
  | k + 1 =>
    show bit0 (shiftl m k) = m * (2 * 2 ^ k) by
      rw [bit0_val, shiftl_eq_mul_pow, mul_left_comm, mul_comm 2]
#align nat.shiftl_eq_mul_pow Nat.shiftl_eq_mul_pow

theorem shiftl'_tt_eq_mul_pow (m) : ∀ n, shiftl' true m n + 1 = (m + 1) * 2 ^ n
  | 0 => by simp [shiftl, shiftl', pow_zero, Nat.one_mul]
  | k + 1 => by
    change bit1 (shiftl' tt m k) + 1 = (m + 1) * (2 * 2 ^ k)
    rw [bit1_val]
    change 2 * (shiftl' tt m k + 1) = _
    rw [shiftl'_tt_eq_mul_pow, mul_left_comm, mul_comm 2]
#align nat.shiftl'_tt_eq_mul_pow Nat.shiftl'_tt_eq_mul_pow

theorem one_shiftl (n) : shiftl 1 n = 2 ^ n :=
  (shiftl_eq_mul_pow _ _).trans (Nat.one_mul _)
#align nat.one_shiftl Nat.one_shiftl

@[simp]
theorem zero_shiftl (n) : shiftl 0 n = 0 :=
  (shiftl_eq_mul_pow _ _).trans (Nat.zero_mul _)
#align nat.zero_shiftl Nat.zero_shiftl

theorem shiftr_eq_div_pow (m) : ∀ n, shiftr m n = m / 2 ^ n
  | 0 => (Nat.div_one _).symm
  | k + 1 =>
    (congr_arg div2 (shiftr_eq_div_pow k)).trans <| by
      rw [div2_val, Nat.div_div_eq_div_mul, mul_comm] <;> rfl
#align nat.shiftr_eq_div_pow Nat.shiftr_eq_div_pow

@[simp]
theorem zero_shiftr (n) : shiftr 0 n = 0 :=
  (shiftr_eq_div_pow _ _).trans (Nat.zero_div _)
#align nat.zero_shiftr Nat.zero_shiftr

theorem shiftl'_ne_zero_left (b) {m} (h : m ≠ 0) (n) : shiftl' b m n ≠ 0 := by
  induction n <;> simp [shiftl', bit_ne_zero, *]
#align nat.shiftl'_ne_zero_left Nat.shiftl'_ne_zero_left

theorem shiftl'_tt_ne_zero (m) : ∀ {n} (h : n ≠ 0), shiftl' true m n ≠ 0
  | 0, h => absurd rfl h
  | succ n, _ => Nat.bit1_ne_zero _
#align nat.shiftl'_tt_ne_zero Nat.shiftl'_tt_ne_zero

/-! ### `size` -/


@[simp]
theorem size_zero : size 0 = 0 := by simp [size]
#align nat.size_zero Nat.size_zero

@[simp]
theorem size_bit {b n} (h : bit b n ≠ 0) : size (bit b n) = succ (size n) := by
  rw [size]
  conv =>
  lhs
  rw [binary_rec]
  simp [h]
  rw [div2_bit]
#align nat.size_bit Nat.size_bit

@[simp]
theorem size_bit0 {n} (h : n ≠ 0) : size (bit0 n) = succ (size n) :=
  @size_bit false n (Nat.bit0_ne_zero h)
#align nat.size_bit0 Nat.size_bit0

@[simp]
theorem size_bit1 (n) : size (bit1 n) = succ (size n) :=
  @size_bit true n (Nat.bit1_ne_zero n)
#align nat.size_bit1 Nat.size_bit1

@[simp]
theorem size_one : size 1 = 1 :=
  show size (bit1 0) = 1 by rw [size_bit1, size_zero]
#align nat.size_one Nat.size_one

@[simp]
theorem size_shiftl' {b m n} (h : shiftl' b m n ≠ 0) : size (shiftl' b m n) = size m + n := by
  induction' n with n IH <;> simp [shiftl'] at h⊢
  rw [size_bit h, Nat.add_succ]
  by_cases s0 : shiftl' b m n = 0 <;> [skip, rw [IH s0]]
  rw [s0] at h⊢
  cases b;
  · exact absurd rfl h
    
  have : shiftl' tt m n + 1 = 1 := congr_arg (· + 1) s0
  rw [shiftl'_tt_eq_mul_pow] at this
  obtain rfl := succ.inj (eq_one_of_dvd_one ⟨_, this.symm⟩)
  rw [one_mul] at this
  obtain rfl : n = 0 :=
    Nat.eq_zero_of_le_zero
      (le_of_not_gt fun hn => ne_of_gt (pow_lt_pow_of_lt_right (by decide) hn) this)
  rfl
#align nat.size_shiftl' Nat.size_shiftl'

@[simp]
theorem size_shiftl {m} (h : m ≠ 0) (n) : size (shiftl m n) = size m + n :=
  size_shiftl' (shiftl'_ne_zero_left _ h _)
#align nat.size_shiftl Nat.size_shiftl

theorem lt_size_self (n : ℕ) : n < 2 ^ size n := by
  rw [← one_shiftl]
  have : ∀ {n}, n = 0 → n < shiftl 1 (size n) := by simp
  apply binary_rec _ _ n
  · apply this rfl
    
  intro b n IH
  by_cases bit b n = 0
  · apply this h
    
  rw [size_bit h, shiftl_succ]
  exact bit_lt_bit0 _ IH
#align nat.lt_size_self Nat.lt_size_self

theorem size_le {m n : ℕ} : size m ≤ n ↔ m < 2 ^ n :=
  ⟨fun h => lt_of_lt_of_le (lt_size_self _) (pow_le_pow_of_le_right (by decide) h), by
    rw [← one_shiftl]; revert n
    apply binary_rec _ _ m
    · intro n h
      simp
      
    · intro b m IH n h
      by_cases e : bit b m = 0
      · simp [e]
        
      rw [size_bit e]
      cases' n with n
      · exact e.elim (Nat.eq_zero_of_le_zero (le_of_lt_succ h))
        
      · apply succ_le_succ (IH _)
        apply lt_imp_lt_of_le_imp_le (fun h' => bit0_le_bit _ h') h
        
      ⟩
#align nat.size_le Nat.size_le

theorem lt_size {m n : ℕ} : m < size n ↔ 2 ^ m ≤ n := by
  rw [← not_lt, Decidable.iff_not_comm, not_lt, size_le]
#align nat.lt_size Nat.lt_size

theorem size_pos {n : ℕ} : 0 < size n ↔ 0 < n := by rw [lt_size] <;> rfl
#align nat.size_pos Nat.size_pos

theorem size_eq_zero {n : ℕ} : size n = 0 ↔ n = 0 := by
  have := @size_pos n <;> simp [pos_iff_ne_zero] at this <;> exact Decidable.not_iff_not.1 this
#align nat.size_eq_zero Nat.size_eq_zero

theorem size_pow {n : ℕ} : size (2 ^ n) = n + 1 :=
  le_antisymm (size_le.2 <| pow_lt_pow_of_lt_right (by decide) (lt_succ_self _))
    (lt_size.2 <| le_rfl)
#align nat.size_pow Nat.size_pow

theorem size_le_size {m n : ℕ} (h : m ≤ n) : size m ≤ size n :=
  size_le.2 <| lt_of_le_of_lt h (lt_size_self _)
#align nat.size_le_size Nat.size_le_size

end Nat

