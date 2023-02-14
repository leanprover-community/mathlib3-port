/-
Copyright (c) 2023 Mark Andrew Gerads. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mark Andrew Gerads, Junyan Xu, Eric Wieser

! This file was ported from Lean 3 source module data.nat.hyperoperation
! leanprover-community/mathlib commit 48085f140e684306f9e7da907cd5932056d1aded
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.Ring
import Mathbin.Data.Nat.Parity

/-!
# Hyperoperation sequence

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the Hyperoperation sequence.
`hyperoperation 0 m k = k + 1`
`hyperoperation 1 m k = m + k`
`hyperoperation 2 m k = m * k`
`hyperoperation 3 m k = m ^ k`
`hyperoperation (n + 3) m 0 = 1`
`hyperoperation (n + 1) m (k + 1) = hyperoperation n m (hyperoperation (n + 1) m k)`

## References

* <https://en.wikipedia.org/wiki/Hyperoperation>

## Tags

hyperoperation
-/


#print hyperoperation /-
/-- Implementation of the hyperoperation sequence
where `hyperoperation n m k` is the `n`th hyperoperation between `m` and `k`.
-/
def hyperoperation : ℕ → ℕ → ℕ → ℕ
  | 0, _, k => k + 1
  | 1, m, 0 => m
  | 2, _, 0 => 0
  | n + 3, _, 0 => 1
  | n + 1, m, k + 1 => hyperoperation n m (hyperoperation (n + 1) m k)
#align hyperoperation hyperoperation
-/

#print hyperoperation_zero /-
-- Basic hyperoperation lemmas
@[simp]
theorem hyperoperation_zero (m : ℕ) : hyperoperation 0 m = Nat.succ :=
  funext fun k => by rw [hyperoperation, Nat.succ_eq_add_one]
#align hyperoperation_zero hyperoperation_zero
-/

#print hyperoperation_ge_three_eq_one /-
theorem hyperoperation_ge_three_eq_one (n m : ℕ) : hyperoperation (n + 3) m 0 = 1 := by
  rw [hyperoperation]
#align hyperoperation_ge_three_eq_one hyperoperation_ge_three_eq_one
-/

#print hyperoperation_recursion /-
theorem hyperoperation_recursion (n m k : ℕ) :
    hyperoperation (n + 1) m (k + 1) = hyperoperation n m (hyperoperation (n + 1) m k) := by
  obtain _ | _ | _ := n <;> rw [hyperoperation]
#align hyperoperation_recursion hyperoperation_recursion
-/

#print hyperoperation_one /-
-- Interesting hyperoperation lemmas
@[simp]
theorem hyperoperation_one : hyperoperation 1 = (· + ·) :=
  by
  ext (m k)
  induction' k with bn bih
  · rw [Nat.add_zero m, hyperoperation]
  · rw [hyperoperation_recursion, bih, hyperoperation_zero]
    exact Nat.add_assoc m bn 1
#align hyperoperation_one hyperoperation_one
-/

#print hyperoperation_two /-
@[simp]
theorem hyperoperation_two : hyperoperation 2 = (· * ·) :=
  by
  ext (m k)
  induction' k with bn bih
  · rw [hyperoperation]
    exact (Nat.mul_zero m).symm
  · rw [hyperoperation_recursion, hyperoperation_one, bih]
    ring
#align hyperoperation_two hyperoperation_two
-/

#print hyperoperation_three /-
@[simp]
theorem hyperoperation_three : hyperoperation 3 = (· ^ ·) :=
  by
  ext (m k)
  induction' k with bn bih
  · rw [hyperoperation_ge_three_eq_one]
    exact (pow_zero m).symm
  · rw [hyperoperation_recursion, hyperoperation_two, bih]
    exact (pow_succ m bn).symm
#align hyperoperation_three hyperoperation_three
-/

#print hyperoperation_ge_two_eq_self /-
theorem hyperoperation_ge_two_eq_self (n m : ℕ) : hyperoperation (n + 2) m 1 = m :=
  by
  induction' n with nn nih
  · rw [hyperoperation_two]
    ring
  · rw [hyperoperation_recursion, hyperoperation_ge_three_eq_one, nih]
#align hyperoperation_ge_two_eq_self hyperoperation_ge_two_eq_self
-/

#print hyperoperation_two_two_eq_four /-
theorem hyperoperation_two_two_eq_four (n : ℕ) : hyperoperation (n + 1) 2 2 = 4 :=
  by
  induction' n with nn nih
  · rw [hyperoperation_one]
  · rw [hyperoperation_recursion, hyperoperation_ge_two_eq_self, nih]
#align hyperoperation_two_two_eq_four hyperoperation_two_two_eq_four
-/

#print hyperoperation_ge_three_one /-
theorem hyperoperation_ge_three_one (n : ℕ) : ∀ k : ℕ, hyperoperation (n + 3) 1 k = 1 :=
  by
  induction' n with nn nih
  · intro k
    rw [hyperoperation_three, one_pow]
  · intro k
    cases k
    · rw [hyperoperation_ge_three_eq_one]
    · rw [hyperoperation_recursion, nih]
#align hyperoperation_ge_three_one hyperoperation_ge_three_one
-/

/- warning: hyperoperation_ge_four_zero -> hyperoperation_ge_four_zero is a dubious translation:
lean 3 declaration is
  forall (n : Nat) (k : Nat), Eq.{1} Nat (hyperoperation (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 4 (OfNat.mk.{0} Nat 4 (bit0.{0} Nat Nat.hasAdd (bit0.{0} Nat Nat.hasAdd (One.one.{0} Nat Nat.hasOne)))))) (OfNat.ofNat.{0} Nat 0 (OfNat.mk.{0} Nat 0 (Zero.zero.{0} Nat Nat.hasZero))) k) (ite.{1} Nat (Even.{0} Nat Nat.hasAdd k) (Nat.Even.decidablePred k) (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))) (OfNat.ofNat.{0} Nat 0 (OfNat.mk.{0} Nat 0 (Zero.zero.{0} Nat Nat.hasZero))))
but is expected to have type
  forall (n : Nat) (k : Nat), Eq.{1} Nat (hyperoperation (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 4 (instOfNatNat 4))) (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)) k) (ite.{1} Nat (Even.{0} Nat instAddNat k) (Nat.instDecidablePredNatEvenInstAddNat k) (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)) (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)))
Case conversion may be inaccurate. Consider using '#align hyperoperation_ge_four_zero hyperoperation_ge_four_zeroₓ'. -/
theorem hyperoperation_ge_four_zero (n k : ℕ) :
    hyperoperation (n + 4) 0 k = if Even k then 1 else 0 :=
  by
  induction' k with kk kih
  · rw [hyperoperation_ge_three_eq_one]
    simp only [even_zero, if_true]
  · rw [hyperoperation_recursion]
    rw [kih]
    simp_rw [Nat.even_add_one]
    split_ifs
    · exact hyperoperation_ge_two_eq_self (n + 1) 0
    · exact hyperoperation_ge_three_eq_one n 0
#align hyperoperation_ge_four_zero hyperoperation_ge_four_zero

