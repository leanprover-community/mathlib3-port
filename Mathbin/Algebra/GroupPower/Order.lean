/-
Copyright (c) 2015 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Robert Y. Lewis
-/
import Algebra.Order.Ring.Abs
import Algebra.Order.WithZero
import Algebra.GroupPower.Ring
import Data.Set.Intervals.Basic

#align_import algebra.group_power.order from "leanprover-community/mathlib"@"00f91228655eecdcd3ac97a7fd8dbcb139fe990a"

/-!
# Lemmas about the interaction of power operations with order

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Note that some lemmas are in `algebra/group_power/lemmas.lean` as they import files which
depend on this file.
-/


open Function

variable {β A G M R : Type _}

section Monoid

variable [Monoid M]

section Preorder

variable [Preorder M]

section Left

variable [CovariantClass M M (· * ·) (· ≤ ·)] {x : M}

#print pow_le_pow_left' /-
@[to_additive nsmul_le_nsmul_right, mono]
theorem pow_le_pow_left' [CovariantClass M M (swap (· * ·)) (· ≤ ·)] {a b : M} (hab : a ≤ b) :
    ∀ i : ℕ, a ^ i ≤ b ^ i
  | 0 => by simp
  | k + 1 => by
    rw [pow_succ, pow_succ]
    exact mul_le_mul' hab (pow_le_pow_left' k)
#align pow_le_pow_of_le_left' pow_le_pow_left'
#align nsmul_le_nsmul_of_le_right nsmul_le_nsmul_right
-/

attribute [mono] nsmul_le_nsmul_right

#print one_le_pow_of_one_le' /-
@[to_additive nsmul_nonneg]
theorem one_le_pow_of_one_le' {a : M} (H : 1 ≤ a) : ∀ n : ℕ, 1 ≤ a ^ n
  | 0 => by simp
  | k + 1 => by rw [pow_succ]; exact one_le_mul H (one_le_pow_of_one_le' k)
#align one_le_pow_of_one_le' one_le_pow_of_one_le'
#align nsmul_nonneg nsmul_nonneg
-/

#print pow_le_one' /-
@[to_additive nsmul_nonpos]
theorem pow_le_one' {a : M} (H : a ≤ 1) (n : ℕ) : a ^ n ≤ 1 :=
  @one_le_pow_of_one_le' Mᵒᵈ _ _ _ _ H n
#align pow_le_one' pow_le_one'
#align nsmul_nonpos nsmul_nonpos
-/

#print pow_le_pow_right' /-
@[to_additive nsmul_le_nsmul_left]
theorem pow_le_pow_right' {a : M} {n m : ℕ} (ha : 1 ≤ a) (h : n ≤ m) : a ^ n ≤ a ^ m :=
  let ⟨k, hk⟩ := Nat.le.dest h
  calc
    a ^ n ≤ a ^ n * a ^ k := le_mul_of_one_le_right' (one_le_pow_of_one_le' ha _)
    _ = a ^ m := by rw [← hk, pow_add]
#align pow_le_pow' pow_le_pow_right'
#align nsmul_le_nsmul nsmul_le_nsmul_left
-/

#print pow_le_pow_right_of_le_one' /-
@[to_additive nsmul_le_nsmul_left_of_nonpos]
theorem pow_le_pow_right_of_le_one' {a : M} {n m : ℕ} (ha : a ≤ 1) (h : n ≤ m) : a ^ m ≤ a ^ n :=
  @pow_le_pow_right' Mᵒᵈ _ _ _ _ _ _ ha h
#align pow_le_pow_of_le_one' pow_le_pow_right_of_le_one'
#align nsmul_le_nsmul_of_nonpos nsmul_le_nsmul_left_of_nonpos
-/

#print one_lt_pow' /-
@[to_additive nsmul_pos]
theorem one_lt_pow' {a : M} (ha : 1 < a) {k : ℕ} (hk : k ≠ 0) : 1 < a ^ k :=
  by
  rcases Nat.exists_eq_succ_of_ne_zero hk with ⟨l, rfl⟩
  clear hk
  induction' l with l IH
  · simpa using ha
  · rw [pow_succ]
    exact one_lt_mul'' ha IH
#align one_lt_pow' one_lt_pow'
#align nsmul_pos nsmul_pos
-/

#print pow_lt_one' /-
@[to_additive nsmul_neg]
theorem pow_lt_one' {a : M} (ha : a < 1) {k : ℕ} (hk : k ≠ 0) : a ^ k < 1 :=
  @one_lt_pow' Mᵒᵈ _ _ _ _ ha k hk
#align pow_lt_one' pow_lt_one'
#align nsmul_neg nsmul_neg
-/

@[to_additive nsmul_lt_nsmul]
theorem pow_lt_pow' [CovariantClass M M (· * ·) (· < ·)] {a : M} {n m : ℕ} (ha : 1 < a)
    (h : n < m) : a ^ n < a ^ m :=
  by
  rcases Nat.le.dest h with ⟨k, rfl⟩; clear h
  rw [pow_add, pow_succ', mul_assoc, ← pow_succ]
  exact lt_mul_of_one_lt_right' _ (one_lt_pow' ha k.succ_ne_zero)
#align pow_lt_pow' pow_lt_pow'
#align nsmul_lt_nsmul nsmul_lt_nsmul

#print pow_right_strictMono' /-
@[to_additive nsmul_left_strictMono]
theorem pow_right_strictMono' [CovariantClass M M (· * ·) (· < ·)] {a : M} (ha : 1 < a) :
    StrictMono ((· ^ ·) a : ℕ → M) := fun m n => pow_lt_pow' ha
#align pow_strict_mono_left pow_right_strictMono'
#align nsmul_strict_mono_right nsmul_left_strictMono
-/

#print Left.one_le_pow_of_le /-
@[to_additive Left.pow_nonneg]
theorem Left.one_le_pow_of_le (hx : 1 ≤ x) : ∀ {n : ℕ}, 1 ≤ x ^ n
  | 0 => (pow_zero x).ge
  | n + 1 => by rw [pow_succ]; exact Left.one_le_mul hx Left.one_le_pow_of_le
#align left.one_le_pow_of_le Left.one_le_pow_of_le
#align left.pow_nonneg Left.pow_nonneg
-/

#print Left.pow_le_one_of_le /-
@[to_additive Left.pow_nonpos]
theorem Left.pow_le_one_of_le (hx : x ≤ 1) : ∀ {n : ℕ}, x ^ n ≤ 1
  | 0 => (pow_zero _).le
  | n + 1 => by rw [pow_succ]; exact Left.mul_le_one hx Left.pow_le_one_of_le
#align left.pow_le_one_of_le Left.pow_le_one_of_le
#align left.pow_nonpos Left.pow_nonpos
-/

end Left

section Right

variable [CovariantClass M M (swap (· * ·)) (· ≤ ·)] {x : M}

#print Right.one_le_pow_of_le /-
@[to_additive Right.pow_nonneg]
theorem Right.one_le_pow_of_le (hx : 1 ≤ x) : ∀ {n : ℕ}, 1 ≤ x ^ n
  | 0 => (pow_zero _).ge
  | n + 1 => by rw [pow_succ]; exact Right.one_le_mul hx Right.one_le_pow_of_le
#align right.one_le_pow_of_le Right.one_le_pow_of_le
#align right.pow_nonneg Right.pow_nonneg
-/

#print Right.pow_le_one_of_le /-
@[to_additive Right.pow_nonpos]
theorem Right.pow_le_one_of_le (hx : x ≤ 1) : ∀ {n : ℕ}, x ^ n ≤ 1
  | 0 => (pow_zero _).le
  | n + 1 => by rw [pow_succ]; exact Right.mul_le_one hx Right.pow_le_one_of_le
#align right.pow_le_one_of_le Right.pow_le_one_of_le
#align right.pow_nonpos Right.pow_nonpos
-/

end Right

section CovariantLtSwap

variable [Preorder β] [CovariantClass M M (· * ·) (· < ·)]
  [CovariantClass M M (swap (· * ·)) (· < ·)] {f : β → M}

@[to_additive StrictMono.nsmul_left]
theorem StrictMono.pow_right' (hf : StrictMono f) : ∀ {n : ℕ}, n ≠ 0 → StrictMono fun a => f a ^ n
  | 0, hn => (hn rfl).elim
  | 1, hn => by simpa
  | Nat.succ <| Nat.succ n, hn => by simp_rw [pow_succ _ (n + 1)];
    exact hf.mul' (StrictMono.pow_right' n.succ_ne_zero)
#align strict_mono.pow_right' StrictMono.pow_right'
#align strict_mono.nsmul_left StrictMono.nsmul_left

#print pow_left_strictMono /-
/-- See also `pow_strict_mono_right` -/
@[nolint to_additive_doc, to_additive nsmul_right_strictMono]
theorem pow_left_strictMono {n : ℕ} (hn : n ≠ 0) : StrictMono fun a : M => a ^ n :=
  strictMono_id.pow_right' hn
#align pow_strict_mono_right' pow_left_strictMono
#align nsmul_strict_mono_left nsmul_right_strictMono
-/

end CovariantLtSwap

section CovariantLeSwap

variable [Preorder β] [CovariantClass M M (· * ·) (· ≤ ·)]
  [CovariantClass M M (swap (· * ·)) (· ≤ ·)]

#print Monotone.pow_right /-
@[to_additive Monotone.nsmul_left]
theorem Monotone.pow_right {f : β → M} (hf : Monotone f) : ∀ n : ℕ, Monotone fun a => f a ^ n
  | 0 => by simpa using monotone_const
  | n + 1 => by simp_rw [pow_succ]; exact hf.mul' (Monotone.pow_right _)
#align monotone.pow_right Monotone.pow_right
#align monotone.const_nsmul Monotone.const_nsmul
-/

#print pow_mono_right /-
@[to_additive nsmul_mono_left]
theorem pow_mono_right (n : ℕ) : Monotone fun a : M => a ^ n :=
  monotone_id.pow_right _
#align pow_mono_right pow_mono_right
#align nsmul_mono_left nsmul_mono_left
-/

end CovariantLeSwap

#print Left.pow_lt_one_of_lt /-
@[to_additive Left.pow_neg]
theorem Left.pow_lt_one_of_lt [CovariantClass M M (· * ·) (· < ·)] {n : ℕ} {x : M} (hn : 0 < n)
    (h : x < 1) : x ^ n < 1 :=
  Nat.le_induction ((pow_one _).trans_lt h) (fun n _ ih => by rw [pow_succ]; exact mul_lt_one h ih)
    _ (Nat.succ_le_iff.2 hn)
#align left.pow_lt_one_of_lt Left.pow_lt_one_of_lt
#align left.pow_neg Left.pow_neg
-/

#print Right.pow_lt_one_of_lt /-
@[to_additive Right.pow_neg]
theorem Right.pow_lt_one_of_lt [CovariantClass M M (swap (· * ·)) (· < ·)] {n : ℕ} {x : M}
    (hn : 0 < n) (h : x < 1) : x ^ n < 1 :=
  Nat.le_induction ((pow_one _).trans_lt h)
    (fun n _ ih => by rw [pow_succ]; exact Right.mul_lt_one h ih) _ (Nat.succ_le_iff.2 hn)
#align right.pow_lt_one_of_lt Right.pow_lt_one_of_lt
#align right.pow_neg Right.pow_neg
-/

end Preorder

section LinearOrder

variable [LinearOrder M]

section CovariantLe

variable [CovariantClass M M (· * ·) (· ≤ ·)]

#print one_le_pow_iff /-
@[to_additive nsmul_nonneg_iff]
theorem one_le_pow_iff {x : M} {n : ℕ} (hn : n ≠ 0) : 1 ≤ x ^ n ↔ 1 ≤ x :=
  ⟨le_imp_le_of_lt_imp_lt fun h => pow_lt_one' h hn, fun h => one_le_pow_of_one_le' h n⟩
#align one_le_pow_iff one_le_pow_iff
#align nsmul_nonneg_iff nsmul_nonneg_iff
-/

#print pow_le_one_iff /-
@[to_additive]
theorem pow_le_one_iff {x : M} {n : ℕ} (hn : n ≠ 0) : x ^ n ≤ 1 ↔ x ≤ 1 :=
  @one_le_pow_iff Mᵒᵈ _ _ _ _ _ hn
#align pow_le_one_iff pow_le_one_iff
#align nsmul_nonpos_iff nsmul_nonpos_iff
-/

#print one_lt_pow_iff /-
@[to_additive nsmul_pos_iff]
theorem one_lt_pow_iff {x : M} {n : ℕ} (hn : n ≠ 0) : 1 < x ^ n ↔ 1 < x :=
  lt_iff_lt_of_le_iff_le (pow_le_one_iff hn)
#align one_lt_pow_iff one_lt_pow_iff
#align nsmul_pos_iff nsmul_pos_iff
-/

#print pow_lt_one_iff /-
@[to_additive]
theorem pow_lt_one_iff {x : M} {n : ℕ} (hn : n ≠ 0) : x ^ n < 1 ↔ x < 1 :=
  lt_iff_lt_of_le_iff_le (one_le_pow_iff hn)
#align pow_lt_one_iff pow_lt_one_iff
#align nsmul_neg_iff nsmul_neg_iff
-/

#print pow_eq_one_iff /-
@[to_additive]
theorem pow_eq_one_iff {x : M} {n : ℕ} (hn : n ≠ 0) : x ^ n = 1 ↔ x = 1 := by
  simp only [le_antisymm_iff, pow_le_one_iff hn, one_le_pow_iff hn]
#align pow_eq_one_iff pow_eq_one_iff
#align nsmul_eq_zero_iff nsmul_eq_zero_iff
-/

variable [CovariantClass M M (· * ·) (· < ·)] {a : M} {m n : ℕ}

#print pow_le_pow_iff_right' /-
@[to_additive nsmul_le_nsmul_iff_left]
theorem pow_le_pow_iff_right' (ha : 1 < a) : a ^ m ≤ a ^ n ↔ m ≤ n :=
  (pow_right_strictMono' ha).le_iff_le
#align pow_le_pow_iff' pow_le_pow_iff_right'
#align nsmul_le_nsmul_iff nsmul_le_nsmul_iff_left
-/

#print pow_lt_pow_iff_right' /-
@[to_additive nsmul_lt_nsmul_iff_left]
theorem pow_lt_pow_iff_right' (ha : 1 < a) : a ^ m < a ^ n ↔ m < n :=
  (pow_right_strictMono' ha).lt_iff_lt
#align pow_lt_pow_iff' pow_lt_pow_iff_right'
#align nsmul_lt_nsmul_iff nsmul_lt_nsmul_iff_left
-/

end CovariantLe

section CovariantLeSwap

variable [CovariantClass M M (· * ·) (· ≤ ·)] [CovariantClass M M (swap (· * ·)) (· ≤ ·)]

#print lt_of_pow_lt_pow_left' /-
@[to_additive lt_of_nsmul_lt_nsmul_right]
theorem lt_of_pow_lt_pow_left' {a b : M} (n : ℕ) : a ^ n < b ^ n → a < b :=
  (pow_mono_right _).reflect_lt
#align lt_of_pow_lt_pow' lt_of_pow_lt_pow_left'
#align lt_of_nsmul_lt_nsmul lt_of_nsmul_lt_nsmul_right
-/

@[to_additive]
theorem min_lt_max_of_mul_lt_mul {a b c d : M} (h : a * b < c * d) : min a b < max c d :=
  lt_of_pow_lt_pow_left' 2 <| by simp_rw [pow_two];
    exact
      (mul_le_mul' inf_le_left inf_le_right).trans_lt
        (h.trans_le <| mul_le_mul' le_sup_left le_sup_right)
#align min_lt_max_of_mul_lt_mul min_lt_max_of_mul_lt_mulₓ
#align min_lt_max_of_add_lt_add min_lt_max_of_add_lt_addₓ

#print min_lt_of_mul_lt_sq /-
@[to_additive min_lt_of_add_lt_two_nsmul]
theorem min_lt_of_mul_lt_sq {a b c : M} (h : a * b < c ^ 2) : min a b < c := by
  simpa using min_lt_max_of_mul_lt_mul (h.trans_eq <| pow_two _)
#align min_lt_of_mul_lt_sq min_lt_of_mul_lt_sq
#align min_lt_of_add_lt_two_nsmul min_lt_of_add_lt_two_nsmul
-/

#print lt_max_of_sq_lt_mul /-
@[to_additive lt_max_of_two_nsmul_lt_add]
theorem lt_max_of_sq_lt_mul {a b c : M} (h : a ^ 2 < b * c) : a < max b c := by
  simpa using min_lt_max_of_mul_lt_mul ((pow_two _).symm.trans_lt h)
#align lt_max_of_sq_lt_mul lt_max_of_sq_lt_mul
#align lt_max_of_two_nsmul_lt_add lt_max_of_two_nsmul_lt_add
-/

end CovariantLeSwap

section CovariantLtSwap

variable [CovariantClass M M (· * ·) (· < ·)] [CovariantClass M M (swap (· * ·)) (· < ·)]

#print le_of_pow_le_pow_left' /-
@[to_additive le_of_nsmul_le_nsmul_right']
theorem le_of_pow_le_pow_left' {a b : M} {n : ℕ} (hn : n ≠ 0) : a ^ n ≤ b ^ n → a ≤ b :=
  (pow_left_strictMono hn).le_iff_le.1
#align le_of_pow_le_pow' le_of_pow_le_pow_left'
#align le_of_nsmul_le_nsmul le_of_nsmul_le_nsmul_right'
-/

#print min_le_of_mul_le_sq /-
@[to_additive min_le_of_add_le_two_nsmul]
theorem min_le_of_mul_le_sq {a b c : M} (h : a * b ≤ c ^ 2) : min a b ≤ c := by
  simpa using min_le_max_of_mul_le_mul (h.trans_eq <| pow_two _)
#align min_le_of_mul_le_sq min_le_of_mul_le_sq
#align min_le_of_add_le_two_nsmul min_le_of_add_le_two_nsmul
-/

#print le_max_of_sq_le_mul /-
@[to_additive le_max_of_two_nsmul_le_add]
theorem le_max_of_sq_le_mul {a b c : M} (h : a ^ 2 ≤ b * c) : a ≤ max b c := by
  simpa using min_le_max_of_mul_le_mul ((pow_two _).symm.trans_le h)
#align le_max_of_sq_le_mul le_max_of_sq_le_mul
#align le_max_of_two_nsmul_le_add le_max_of_two_nsmul_le_add
-/

end CovariantLtSwap

#print Left.pow_lt_one_iff /-
@[to_additive Left.nsmul_neg_iff]
theorem Left.pow_lt_one_iff [CovariantClass M M (· * ·) (· < ·)] {n : ℕ} {x : M} (hn : 0 < n) :
    x ^ n < 1 ↔ x < 1 :=
  haveI := Mul.to_covariantClass_left M
  pow_lt_one_iff hn.ne'
#align left.pow_lt_one_iff Left.pow_lt_one_iff
#align left.nsmul_neg_iff Left.nsmul_neg_iff
-/

#print Right.pow_lt_one_iff /-
@[to_additive Right.nsmul_neg_iff]
theorem Right.pow_lt_one_iff [CovariantClass M M (swap (· * ·)) (· < ·)] {n : ℕ} {x : M}
    (hn : 0 < n) : x ^ n < 1 ↔ x < 1 :=
  ⟨fun H =>
    not_le.mp fun k =>
      H.not_le <|
        haveI := Mul.to_covariantClass_right M
        Right.one_le_pow_of_le k,
    Right.pow_lt_one_of_lt hn⟩
#align right.pow_lt_one_iff Right.pow_lt_one_iff
#align right.nsmul_neg_iff Right.nsmul_neg_iff
-/

end LinearOrder

end Monoid

section DivInvMonoid

variable [DivInvMonoid G] [Preorder G] [CovariantClass G G (· * ·) (· ≤ ·)]

#print one_le_zpow /-
@[to_additive zsmul_nonneg]
theorem one_le_zpow {x : G} (H : 1 ≤ x) {n : ℤ} (hn : 0 ≤ n) : 1 ≤ x ^ n :=
  by
  lift n to ℕ using hn
  rw [zpow_ofNat]
  apply one_le_pow_of_one_le' H
#align one_le_zpow one_le_zpow
#align zsmul_nonneg zsmul_nonneg
-/

end DivInvMonoid

namespace CanonicallyOrderedCommSemiring

variable [CanonicallyOrderedCommSemiring R]

#print CanonicallyOrderedCommSemiring.pow_pos /-
theorem pow_pos {a : R} (H : 0 < a) (n : ℕ) : 0 < a ^ n :=
  pos_iff_ne_zero.2 <| pow_ne_zero _ H.ne'
#align canonically_ordered_comm_semiring.pow_pos CanonicallyOrderedCommSemiring.pow_pos
-/

end CanonicallyOrderedCommSemiring

section OrderedSemiring

variable [OrderedSemiring R] {a x y : R} {n m : ℕ}

#print zero_pow_le_one /-
theorem zero_pow_le_one : ∀ n : ℕ, (0 : R) ^ n ≤ 1
  | 0 => (pow_zero _).le
  | n + 1 => by rw [zero_pow n.succ_pos]; exact zero_le_one
#align zero_pow_le_one zero_pow_le_one
-/

#print pow_add_pow_le /-
theorem pow_add_pow_le (hx : 0 ≤ x) (hy : 0 ≤ y) (hn : n ≠ 0) : x ^ n + y ^ n ≤ (x + y) ^ n :=
  by
  rcases Nat.exists_eq_succ_of_ne_zero hn with ⟨k, rfl⟩
  induction' k with k ih; · simp only [pow_one]
  let n := k.succ
  have h1 := add_nonneg (mul_nonneg hx (pow_nonneg hy n)) (mul_nonneg hy (pow_nonneg hx n))
  have h2 := add_nonneg hx hy
  calc
    x ^ n.succ + y ^ n.succ ≤ x * x ^ n + y * y ^ n + (x * y ^ n + y * x ^ n) := by
      rw [pow_succ _ n, pow_succ _ n]; exact le_add_of_nonneg_right h1
    _ = (x + y) * (x ^ n + y ^ n) := by
      rw [add_mul, mul_add, mul_add, add_comm (y * x ^ n), ← add_assoc, ← add_assoc,
        add_assoc (x * x ^ n) (x * y ^ n), add_comm (x * y ^ n) (y * y ^ n), ← add_assoc]
    _ ≤ (x + y) ^ n.succ := by rw [pow_succ _ n];
      exact mul_le_mul_of_nonneg_left (ih (Nat.succ_ne_zero k)) h2
#align pow_add_pow_le pow_add_pow_le
-/

#print pow_le_one /-
theorem pow_le_one : ∀ (n : ℕ) (h₀ : 0 ≤ a) (h₁ : a ≤ 1), a ^ n ≤ 1
  | 0, h₀, h₁ => (pow_zero a).le
  | n + 1, h₀, h₁ => (pow_succ' a n).le.trans (mul_le_one (pow_le_one n h₀ h₁) h₀ h₁)
#align pow_le_one pow_le_one
-/

#print pow_lt_one /-
theorem pow_lt_one (h₀ : 0 ≤ a) (h₁ : a < 1) : ∀ {n : ℕ} (hn : n ≠ 0), a ^ n < 1
  | 0, h => (h rfl).elim
  | n + 1, h => by rw [pow_succ];
    exact mul_lt_one_of_nonneg_of_lt_one_left h₀ h₁ (pow_le_one _ h₀ h₁.le)
#align pow_lt_one pow_lt_one
-/

#print one_le_pow_of_one_le /-
theorem one_le_pow_of_one_le (H : 1 ≤ a) : ∀ n : ℕ, 1 ≤ a ^ n
  | 0 => by rw [pow_zero]
  | n + 1 => by rw [pow_succ];
    simpa only [mul_one] using
      mul_le_mul H (one_le_pow_of_one_le n) zero_le_one (le_trans zero_le_one H)
#align one_le_pow_of_one_le one_le_pow_of_one_le
-/

#print pow_right_mono /-
theorem pow_right_mono (h : 1 ≤ a) : Monotone fun n : ℕ => a ^ n :=
  monotone_nat_of_le_succ fun n => by rw [pow_succ];
    exact le_mul_of_one_le_left (pow_nonneg (zero_le_one.trans h) _) h
#align pow_mono pow_right_mono
-/

#print pow_le_pow_right /-
theorem pow_le_pow_right (ha : 1 ≤ a) (h : n ≤ m) : a ^ n ≤ a ^ m :=
  pow_right_mono ha h
#align pow_le_pow pow_le_pow_right
-/

/- warning: le_self_pow clashes with self_le_pow -> le_self_pow
Case conversion may be inaccurate. Consider using '#align le_self_pow le_self_powₓ'. -/
#print le_self_pow /-
theorem le_self_pow (ha : 1 ≤ a) (h : m ≠ 0) : a ≤ a ^ m :=
  (pow_one a).symm.trans_le (pow_le_pow_right ha <| pos_iff_ne_zero.mpr h)
#align le_self_pow le_self_pow
-/

#print pow_le_pow_left /-
@[mono]
theorem pow_le_pow_left {a b : R} (ha : 0 ≤ a) (hab : a ≤ b) : ∀ i : ℕ, a ^ i ≤ b ^ i
  | 0 => by simp
  | k + 1 => by
    rw [pow_succ, pow_succ]
    exact mul_le_mul hab (pow_le_pow_left _) (pow_nonneg ha _) (le_trans ha hab)
#align pow_le_pow_of_le_left pow_le_pow_left
-/

#print one_lt_pow /-
theorem one_lt_pow (ha : 1 < a) : ∀ {n : ℕ} (hn : n ≠ 0), 1 < a ^ n
  | 0, h => (h rfl).elim
  | n + 1, h => by rw [pow_succ]; exact one_lt_mul_of_lt_of_le ha (one_le_pow_of_one_le ha.le _)
#align one_lt_pow one_lt_pow
-/

end OrderedSemiring

section StrictOrderedSemiring

variable [StrictOrderedSemiring R] {a x y : R} {n m : ℕ}

#print pow_lt_pow_left /-
theorem pow_lt_pow_left (h : x < y) (hx : 0 ≤ x) : ∀ {n : ℕ}, 0 < n → x ^ n < y ^ n
  | 0, hn => hn.False.elim
  | n + 1, _ => by
    simpa only [pow_succ'] using
      mul_lt_mul_of_le_of_le' (pow_le_pow_left hx h.le _) h (pow_pos (hx.trans_lt h) _) hx
#align pow_lt_pow_of_lt_left pow_lt_pow_left
-/

#print pow_left_strictMonoOn /-
theorem pow_left_strictMonoOn (hn : 0 < n) : StrictMonoOn (fun x : R => x ^ n) (Set.Ici 0) :=
  fun x hx y hy h => pow_lt_pow_left h hx hn
#align strict_mono_on_pow pow_left_strictMonoOn
-/

#print pow_right_strictMono /-
theorem pow_right_strictMono (h : 1 < a) : StrictMono fun n : ℕ => a ^ n :=
  have : 0 < a := zero_le_one.trans_lt h
  strictMono_nat_of_lt_succ fun n => by
    simpa only [one_mul, pow_succ] using mul_lt_mul h (le_refl (a ^ n)) (pow_pos this _) this.le
#align pow_strict_mono_right pow_right_strictMono
-/

theorem pow_lt_pow (h : 1 < a) (h2 : n < m) : a ^ n < a ^ m :=
  pow_right_strictMono h h2
#align pow_lt_pow pow_lt_pow

theorem pow_lt_pow_iff (h : 1 < a) : a ^ n < a ^ m ↔ n < m :=
  (pow_right_strictMono h).lt_iff_lt
#align pow_lt_pow_iff pow_lt_pow_iff

#print pow_le_pow_iff_right /-
theorem pow_le_pow_iff_right (h : 1 < a) : a ^ n ≤ a ^ m ↔ n ≤ m :=
  (pow_right_strictMono h).le_iff_le
#align pow_le_pow_iff pow_le_pow_iff_right
-/

#print pow_right_strictAnti /-
theorem pow_right_strictAnti (h₀ : 0 < a) (h₁ : a < 1) : StrictAnti fun n : ℕ => a ^ n :=
  strictAnti_nat_of_succ_lt fun n => by
    simpa only [pow_succ, one_mul] using mul_lt_mul h₁ le_rfl (pow_pos h₀ n) zero_le_one
#align strict_anti_pow pow_right_strictAnti
-/

#print pow_lt_pow_iff_right_of_lt_one /-
theorem pow_lt_pow_iff_right_of_lt_one (h₀ : 0 < a) (h₁ : a < 1) : a ^ m < a ^ n ↔ n < m :=
  (pow_right_strictAnti h₀ h₁).lt_iff_lt
#align pow_lt_pow_iff_of_lt_one pow_lt_pow_iff_right_of_lt_one
-/

#print pow_lt_pow_right_of_lt_one /-
theorem pow_lt_pow_right_of_lt_one (h : 0 < a) (ha : a < 1) {i j : ℕ} (hij : i < j) :
    a ^ j < a ^ i :=
  (pow_lt_pow_iff_right_of_lt_one h ha).2 hij
#align pow_lt_pow_of_lt_one pow_lt_pow_right_of_lt_one
-/

#print pow_lt_self_of_lt_one /-
theorem pow_lt_self_of_lt_one (h₀ : 0 < a) (h₁ : a < 1) (hn : 1 < n) : a ^ n < a :=
  calc
    a ^ n < a ^ 1 := pow_lt_pow_right_of_lt_one h₀ h₁ hn
    _ = a := pow_one _
#align pow_lt_self_of_lt_one pow_lt_self_of_lt_one
-/

#print sq_pos_of_pos /-
theorem sq_pos_of_pos (ha : 0 < a) : 0 < a ^ 2 := by rw [sq]; exact mul_pos ha ha
#align sq_pos_of_pos sq_pos_of_pos
-/

end StrictOrderedSemiring

section StrictOrderedRing

variable [StrictOrderedRing R] {a : R}

#print pow_bit0_pos_of_neg /-
theorem pow_bit0_pos_of_neg (ha : a < 0) (n : ℕ) : 0 < a ^ bit0 n :=
  by
  rw [pow_bit0']
  exact pow_pos (mul_pos_of_neg_of_neg ha ha) _
#align pow_bit0_pos_of_neg pow_bit0_pos_of_neg
-/

#print pow_bit1_neg /-
theorem pow_bit1_neg (ha : a < 0) (n : ℕ) : a ^ bit1 n < 0 :=
  by
  rw [bit1, pow_succ]
  exact mul_neg_of_neg_of_pos ha (pow_bit0_pos_of_neg ha n)
#align pow_bit1_neg pow_bit1_neg
-/

#print sq_pos_of_neg /-
theorem sq_pos_of_neg (ha : a < 0) : 0 < a ^ 2 :=
  pow_bit0_pos_of_neg ha _
#align sq_pos_of_neg sq_pos_of_neg
-/

end StrictOrderedRing

section LinearOrderedSemiring

variable [LinearOrderedSemiring R] {a b : R}

#print pow_le_one_iff_of_nonneg /-
theorem pow_le_one_iff_of_nonneg {a : R} (ha : 0 ≤ a) {n : ℕ} (hn : n ≠ 0) : a ^ n ≤ 1 ↔ a ≤ 1 :=
  by
  refine' ⟨_, pow_le_one n ha⟩
  rw [← not_lt, ← not_lt]
  exact mt fun h => one_lt_pow h hn
#align pow_le_one_iff_of_nonneg pow_le_one_iff_of_nonneg
-/

#print one_le_pow_iff_of_nonneg /-
theorem one_le_pow_iff_of_nonneg {a : R} (ha : 0 ≤ a) {n : ℕ} (hn : n ≠ 0) : 1 ≤ a ^ n ↔ 1 ≤ a :=
  by
  refine' ⟨_, fun h => one_le_pow_of_one_le h n⟩
  rw [← not_lt, ← not_lt]
  exact mt fun h => pow_lt_one ha h hn
#align one_le_pow_iff_of_nonneg one_le_pow_iff_of_nonneg
-/

#print one_lt_pow_iff_of_nonneg /-
theorem one_lt_pow_iff_of_nonneg {a : R} (ha : 0 ≤ a) {n : ℕ} (hn : n ≠ 0) : 1 < a ^ n ↔ 1 < a :=
  lt_iff_lt_of_le_iff_le (pow_le_one_iff_of_nonneg ha hn)
#align one_lt_pow_iff_of_nonneg one_lt_pow_iff_of_nonneg
-/

#print pow_lt_one_iff_of_nonneg /-
theorem pow_lt_one_iff_of_nonneg {a : R} (ha : 0 ≤ a) {n : ℕ} (hn : n ≠ 0) : a ^ n < 1 ↔ a < 1 :=
  lt_iff_lt_of_le_iff_le (one_le_pow_iff_of_nonneg ha hn)
#align pow_lt_one_iff_of_nonneg pow_lt_one_iff_of_nonneg
-/

#print sq_le_one_iff /-
theorem sq_le_one_iff {a : R} (ha : 0 ≤ a) : a ^ 2 ≤ 1 ↔ a ≤ 1 :=
  pow_le_one_iff_of_nonneg ha (Nat.succ_ne_zero _)
#align sq_le_one_iff sq_le_one_iff
-/

#print sq_lt_one_iff /-
theorem sq_lt_one_iff {a : R} (ha : 0 ≤ a) : a ^ 2 < 1 ↔ a < 1 :=
  pow_lt_one_iff_of_nonneg ha (Nat.succ_ne_zero _)
#align sq_lt_one_iff sq_lt_one_iff
-/

#print one_le_sq_iff /-
theorem one_le_sq_iff {a : R} (ha : 0 ≤ a) : 1 ≤ a ^ 2 ↔ 1 ≤ a :=
  one_le_pow_iff_of_nonneg ha (Nat.succ_ne_zero _)
#align one_le_sq_iff one_le_sq_iff
-/

#print one_lt_sq_iff /-
theorem one_lt_sq_iff {a : R} (ha : 0 ≤ a) : 1 < a ^ 2 ↔ 1 < a :=
  one_lt_pow_iff_of_nonneg ha (Nat.succ_ne_zero _)
#align one_lt_sq_iff one_lt_sq_iff
-/

#print pow_left_inj /-
@[simp]
theorem pow_left_inj {x y : R} {n : ℕ} (Hxpos : 0 ≤ x) (Hypos : 0 ≤ y) (Hnpos : 0 < n) :
    x ^ n = y ^ n ↔ x = y :=
  (@pow_left_strictMonoOn R _ _ Hnpos).eq_iff_eq Hxpos Hypos
#align pow_left_inj pow_left_inj
-/

#print lt_of_pow_lt_pow_left /-
theorem lt_of_pow_lt_pow_left {a b : R} (n : ℕ) (hb : 0 ≤ b) (h : a ^ n < b ^ n) : a < b :=
  lt_of_not_ge fun hn => not_lt_of_ge (pow_le_pow_left hb hn _) h
#align lt_of_pow_lt_pow lt_of_pow_lt_pow_left
-/

#print le_of_pow_le_pow_left /-
theorem le_of_pow_le_pow_left {a b : R} (n : ℕ) (hb : 0 ≤ b) (hn : 0 < n) (h : a ^ n ≤ b ^ n) :
    a ≤ b :=
  le_of_not_lt fun h1 => not_le_of_lt (pow_lt_pow_left h1 hb hn) h
#align le_of_pow_le_pow le_of_pow_le_pow_left
-/

#print sq_eq_sq /-
@[simp]
theorem sq_eq_sq {a b : R} (ha : 0 ≤ a) (hb : 0 ≤ b) : a ^ 2 = b ^ 2 ↔ a = b :=
  pow_left_inj ha hb (by decide)
#align sq_eq_sq sq_eq_sq
-/

#print lt_of_mul_self_lt_mul_self /-
theorem lt_of_mul_self_lt_mul_self (hb : 0 ≤ b) : a * a < b * b → a < b := by simp_rw [← sq];
  exact lt_of_pow_lt_pow_left _ hb
#align lt_of_mul_self_lt_mul_self lt_of_mul_self_lt_mul_self
-/

end LinearOrderedSemiring

section LinearOrderedRing

variable [LinearOrderedRing R]

#print pow_abs /-
theorem pow_abs (a : R) (n : ℕ) : |a| ^ n = |a ^ n| :=
  ((absHom.toMonoidHom : R →* R).map_pow a n).symm
#align pow_abs pow_abs
-/

#print abs_neg_one_pow /-
theorem abs_neg_one_pow (n : ℕ) : |(-1 : R) ^ n| = 1 := by rw [← pow_abs, abs_neg, abs_one, one_pow]
#align abs_neg_one_pow abs_neg_one_pow
-/

#print abs_pow_eq_one /-
theorem abs_pow_eq_one (a : R) {n : ℕ} (h : 0 < n) : |a ^ n| = 1 ↔ |a| = 1 :=
  by
  convert pow_left_inj (abs_nonneg a) zero_le_one h
  exacts [(pow_abs _ _).symm, (one_pow _).symm]
#align abs_pow_eq_one abs_pow_eq_one
-/

#print pow_bit0_nonneg /-
theorem pow_bit0_nonneg (a : R) (n : ℕ) : 0 ≤ a ^ bit0 n := by rw [pow_bit0];
  exact mul_self_nonneg _
#align pow_bit0_nonneg pow_bit0_nonneg
-/

#print sq_nonneg /-
theorem sq_nonneg (a : R) : 0 ≤ a ^ 2 :=
  pow_bit0_nonneg a 1
#align sq_nonneg sq_nonneg
-/

alias pow_two_nonneg := sq_nonneg
#align pow_two_nonneg pow_two_nonneg

#print pow_bit0_pos /-
theorem pow_bit0_pos {a : R} (h : a ≠ 0) (n : ℕ) : 0 < a ^ bit0 n :=
  (pow_bit0_nonneg a n).lt_of_ne (pow_ne_zero _ h).symm
#align pow_bit0_pos pow_bit0_pos
-/

#print sq_pos_of_ne_zero /-
theorem sq_pos_of_ne_zero (a : R) (h : a ≠ 0) : 0 < a ^ 2 :=
  pow_bit0_pos h 1
#align sq_pos_of_ne_zero sq_pos_of_ne_zero
-/

alias pow_two_pos_of_ne_zero := sq_pos_of_ne_zero
#align pow_two_pos_of_ne_zero pow_two_pos_of_ne_zero

#print pow_bit0_pos_iff /-
theorem pow_bit0_pos_iff (a : R) {n : ℕ} (hn : n ≠ 0) : 0 < a ^ bit0 n ↔ a ≠ 0 :=
  by
  refine' ⟨fun h => _, fun h => pow_bit0_pos h n⟩
  rintro rfl
  rw [zero_pow (Nat.zero_lt_bit0 hn)] at h 
  exact lt_irrefl _ h
#align pow_bit0_pos_iff pow_bit0_pos_iff
-/

#print sq_pos_iff /-
theorem sq_pos_iff (a : R) : 0 < a ^ 2 ↔ a ≠ 0 :=
  pow_bit0_pos_iff a one_ne_zero
#align sq_pos_iff sq_pos_iff
-/

variable {x y : R}

#print sq_abs /-
theorem sq_abs (x : R) : |x| ^ 2 = x ^ 2 := by simpa only [sq] using abs_mul_abs_self x
#align sq_abs sq_abs
-/

#print abs_sq /-
theorem abs_sq (x : R) : |x ^ 2| = x ^ 2 := by simpa only [sq] using abs_mul_self x
#align abs_sq abs_sq
-/

#print sq_lt_sq /-
theorem sq_lt_sq : x ^ 2 < y ^ 2 ↔ |x| < |y| := by
  simpa only [sq_abs] using
    (@pow_left_strictMonoOn R _ _ two_pos).lt_iff_lt (abs_nonneg x) (abs_nonneg y)
#align sq_lt_sq sq_lt_sq
-/

#print sq_lt_sq' /-
theorem sq_lt_sq' (h1 : -y < x) (h2 : x < y) : x ^ 2 < y ^ 2 :=
  sq_lt_sq.2 (lt_of_lt_of_le (abs_lt.2 ⟨h1, h2⟩) (le_abs_self _))
#align sq_lt_sq' sq_lt_sq'
-/

#print sq_le_sq /-
theorem sq_le_sq : x ^ 2 ≤ y ^ 2 ↔ |x| ≤ |y| := by
  simpa only [sq_abs] using
    (@pow_left_strictMonoOn R _ _ two_pos).le_iff_le (abs_nonneg x) (abs_nonneg y)
#align sq_le_sq sq_le_sq
-/

#print sq_le_sq' /-
theorem sq_le_sq' (h1 : -y ≤ x) (h2 : x ≤ y) : x ^ 2 ≤ y ^ 2 :=
  sq_le_sq.2 (le_trans (abs_le.mpr ⟨h1, h2⟩) (le_abs_self _))
#align sq_le_sq' sq_le_sq'
-/

#print abs_lt_of_sq_lt_sq /-
theorem abs_lt_of_sq_lt_sq (h : x ^ 2 < y ^ 2) (hy : 0 ≤ y) : |x| < y := by
  rwa [← abs_of_nonneg hy, ← sq_lt_sq]
#align abs_lt_of_sq_lt_sq abs_lt_of_sq_lt_sq
-/

#print abs_lt_of_sq_lt_sq' /-
theorem abs_lt_of_sq_lt_sq' (h : x ^ 2 < y ^ 2) (hy : 0 ≤ y) : -y < x ∧ x < y :=
  abs_lt.mp <| abs_lt_of_sq_lt_sq h hy
#align abs_lt_of_sq_lt_sq' abs_lt_of_sq_lt_sq'
-/

#print abs_le_of_sq_le_sq /-
theorem abs_le_of_sq_le_sq (h : x ^ 2 ≤ y ^ 2) (hy : 0 ≤ y) : |x| ≤ y := by
  rwa [← abs_of_nonneg hy, ← sq_le_sq]
#align abs_le_of_sq_le_sq abs_le_of_sq_le_sq
-/

#print abs_le_of_sq_le_sq' /-
theorem abs_le_of_sq_le_sq' (h : x ^ 2 ≤ y ^ 2) (hy : 0 ≤ y) : -y ≤ x ∧ x ≤ y :=
  abs_le.mp <| abs_le_of_sq_le_sq h hy
#align abs_le_of_sq_le_sq' abs_le_of_sq_le_sq'
-/

#print sq_eq_sq_iff_abs_eq_abs /-
theorem sq_eq_sq_iff_abs_eq_abs (x y : R) : x ^ 2 = y ^ 2 ↔ |x| = |y| := by
  simp only [le_antisymm_iff, sq_le_sq]
#align sq_eq_sq_iff_abs_eq_abs sq_eq_sq_iff_abs_eq_abs
-/

#print sq_le_one_iff_abs_le_one /-
@[simp]
theorem sq_le_one_iff_abs_le_one (x : R) : x ^ 2 ≤ 1 ↔ |x| ≤ 1 := by
  simpa only [one_pow, abs_one] using @sq_le_sq _ _ x 1
#align sq_le_one_iff_abs_le_one sq_le_one_iff_abs_le_one
-/

#print sq_lt_one_iff_abs_lt_one /-
@[simp]
theorem sq_lt_one_iff_abs_lt_one (x : R) : x ^ 2 < 1 ↔ |x| < 1 := by
  simpa only [one_pow, abs_one] using @sq_lt_sq _ _ x 1
#align sq_lt_one_iff_abs_lt_one sq_lt_one_iff_abs_lt_one
-/

#print one_le_sq_iff_one_le_abs /-
@[simp]
theorem one_le_sq_iff_one_le_abs (x : R) : 1 ≤ x ^ 2 ↔ 1 ≤ |x| := by
  simpa only [one_pow, abs_one] using @sq_le_sq _ _ 1 x
#align one_le_sq_iff_one_le_abs one_le_sq_iff_one_le_abs
-/

#print one_lt_sq_iff_one_lt_abs /-
@[simp]
theorem one_lt_sq_iff_one_lt_abs (x : R) : 1 < x ^ 2 ↔ 1 < |x| := by
  simpa only [one_pow, abs_one] using @sq_lt_sq _ _ 1 x
#align one_lt_sq_iff_one_lt_abs one_lt_sq_iff_one_lt_abs
-/

#print pow_four_le_pow_two_of_pow_two_le /-
theorem pow_four_le_pow_two_of_pow_two_le {x y : R} (h : x ^ 2 ≤ y) : x ^ 4 ≤ y ^ 2 :=
  (pow_mul x 2 2).symm ▸ pow_le_pow_left (sq_nonneg x) h 2
#align pow_four_le_pow_two_of_pow_two_le pow_four_le_pow_two_of_pow_two_le
-/

end LinearOrderedRing

section LinearOrderedCommRing

variable [LinearOrderedCommRing R]

#print two_mul_le_add_sq /-
/-- Arithmetic mean-geometric mean (AM-GM) inequality for linearly ordered commutative rings. -/
theorem two_mul_le_add_sq (a b : R) : 2 * a * b ≤ a ^ 2 + b ^ 2 :=
  sub_nonneg.mp ((sub_add_eq_add_sub _ _ _).subst ((sub_sq a b).subst (sq_nonneg _)))
#align two_mul_le_add_sq two_mul_le_add_sq
-/

alias two_mul_le_add_pow_two := two_mul_le_add_sq
#align two_mul_le_add_pow_two two_mul_le_add_pow_two

end LinearOrderedCommRing

section LinearOrderedCommMonoidWithZero

variable [LinearOrderedCommMonoidWithZero M] [NoZeroDivisors M] {a : M} {n : ℕ}

#print pow_pos_iff /-
theorem pow_pos_iff (hn : 0 < n) : 0 < a ^ n ↔ 0 < a := by simp_rw [zero_lt_iff, pow_ne_zero_iff hn]
#align pow_pos_iff pow_pos_iff
-/

end LinearOrderedCommMonoidWithZero

section LinearOrderedCommGroupWithZero

variable [LinearOrderedCommGroupWithZero M] {a : M} {m n : ℕ}

#print pow_lt_pow_succ /-
theorem pow_lt_pow_succ (ha : 1 < a) : a ^ n < a ^ n.succ :=
  by
  rw [← one_mul (a ^ n), pow_succ]
  exact mul_lt_right₀ _ ha (pow_ne_zero _ (zero_lt_one.trans ha).ne')
#align pow_lt_pow_succ pow_lt_pow_succ
-/

#print pow_lt_pow_right₀ /-
theorem pow_lt_pow_right₀ (ha : 1 < a) (hmn : m < n) : a ^ m < a ^ n := by
  induction' hmn with n hmn ih; exacts [pow_lt_pow_succ ha, lt_trans ih (pow_lt_pow_succ ha)]
#align pow_lt_pow₀ pow_lt_pow_right₀
-/

end LinearOrderedCommGroupWithZero

namespace MonoidHom

variable [Ring R] [Monoid M] [LinearOrder M] [CovariantClass M M (· * ·) (· ≤ ·)] (f : R →* M)

#print MonoidHom.map_neg_one /-
theorem map_neg_one : f (-1) = 1 :=
  (pow_eq_one_iff (Nat.succ_ne_zero 1)).1 <| by rw [← map_pow, neg_one_sq, map_one]
#align monoid_hom.map_neg_one MonoidHom.map_neg_one
-/

#print MonoidHom.map_neg /-
@[simp]
theorem map_neg (x : R) : f (-x) = f x := by rw [← neg_one_mul, map_mul, map_neg_one, one_mul]
#align monoid_hom.map_neg MonoidHom.map_neg
-/

#print MonoidHom.map_sub_swap /-
theorem map_sub_swap (x y : R) : f (x - y) = f (y - x) := by rw [← map_neg, neg_sub]
#align monoid_hom.map_sub_swap MonoidHom.map_sub_swap
-/

end MonoidHom

