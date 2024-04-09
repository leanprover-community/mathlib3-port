/-
Copyright (c) 2014 Floris van Doorn (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn, Leonardo de Moura, Jeremy Avigad, Mario Carneiro
-/
import Order.Basic
import Algebra.GroupWithZero.Basic
import Algebra.Ring.Defs

#align_import data.nat.basic from "leanprover-community/mathlib"@"bd835ef554f37ef9b804f0903089211f89cb370b"

/-!
# Basic operations on the natural numbers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains:
- instances on the natural numbers
- some basic lemmas about natural numbers
- extra recursors:
  * `le_rec_on`, `le_induction`: recursion and induction principles starting at non-zero numbers
  * `decreasing_induction`: recursion growing downwards
  * `le_rec_on'`, `decreasing_induction'`: versions with slightly weaker assumptions
  * `strong_rec'`: recursion based on strong inequalities
- decidability instances on predicates about the natural numbers

Many theorems that used to live in this file have been moved to `data.nat.order`,
so that this file requires fewer imports.
For each section here there is a corresponding section in that file with additional results.
It may be possible to move some of these results here, by tweaking their proofs.


-/


universe u v

/-! ### instances -/


instance : Nontrivial ℕ :=
  ⟨⟨0, 1, Nat.zero_ne_one⟩⟩

instance : CommSemiring ℕ where
  add := Nat.add
  add_assoc := Nat.add_assoc
  zero := Nat.zero
  zero_add := Nat.zero_add
  add_zero := Nat.add_zero
  add_comm := Nat.add_comm
  mul := Nat.mul
  mul_assoc := Nat.mul_assoc
  one := Nat.succ Nat.zero
  one_mul := Nat.one_mul
  mul_one := Nat.mul_one
  left_distrib := Nat.left_distrib
  right_distrib := Nat.right_distrib
  zero_mul := Nat.zero_mul
  mul_zero := Nat.mul_zero
  mul_comm := Nat.mul_comm
  natCast n := n
  natCast_zero := rfl
  natCast_succ n := rfl
  nsmul m n := m * n
  nsmul_zero := Nat.zero_mul
  nsmul_succ n x := by rw [Nat.succ_eq_add_one, Nat.add_comm, Nat.right_distrib, Nat.one_mul]

/-! Extra instances to short-circuit type class resolution and ensure computability -/


instance : AddCommMonoid ℕ :=
  inferInstance

instance : AddMonoid ℕ :=
  inferInstance

instance : Monoid ℕ :=
  inferInstance

instance : CommMonoid ℕ :=
  inferInstance

instance : CommSemigroup ℕ :=
  inferInstance

instance : Semigroup ℕ :=
  inferInstance

instance : AddCommSemigroup ℕ :=
  inferInstance

instance : AddSemigroup ℕ :=
  inferInstance

instance : Distrib ℕ :=
  inferInstance

instance : Semiring ℕ :=
  inferInstance

#print Nat.nsmul_eq_mul /-
protected theorem Nat.nsmul_eq_mul (m n : ℕ) : m • n = m * n :=
  rfl
#align nat.nsmul_eq_mul Nat.nsmul_eq_mul
-/

#print Nat.cancelCommMonoidWithZero /-
instance Nat.cancelCommMonoidWithZero : CancelCommMonoidWithZero ℕ :=
  { Nat.commSemiring with
    hMul_left_cancel_of_ne_zero := fun _ _ _ h1 h2 =>
      Nat.eq_of_mul_eq_mul_left (Nat.pos_of_ne_zero h1) h2 }
#align nat.cancel_comm_monoid_with_zero Nat.cancelCommMonoidWithZero
-/

attribute [simp] Nat.not_lt_zero Nat.succ_ne_zero Nat.succ_ne_self Nat.zero_ne_one Nat.one_ne_zero
  Nat.zero_ne_bit1 Nat.bit1_ne_zero Nat.bit0_ne_one Nat.one_ne_bit0 Nat.bit0_ne_bit1
  Nat.bit1_ne_bit0

variable {m n k : ℕ}

namespace Nat

/-!
### Recursion and `forall`/`exists`
-/


#print Nat.and_forall_succ /-
@[simp]
theorem and_forall_succ {p : ℕ → Prop} : (p 0 ∧ ∀ n, p (n + 1)) ↔ ∀ n, p n :=
  ⟨fun h n => Nat.casesOn n h.1 h.2, fun h => ⟨h _, fun n => h _⟩⟩
#align nat.and_forall_succ Nat.and_forall_succ
-/

#print Nat.or_exists_succ /-
@[simp]
theorem or_exists_succ {p : ℕ → Prop} : (p 0 ∨ ∃ n, p (n + 1)) ↔ ∃ n, p n :=
  ⟨fun h => h.elim (fun h0 => ⟨0, h0⟩) fun ⟨n, hn⟩ => ⟨n + 1, hn⟩, by rintro ⟨_ | n, hn⟩;
    exacts [Or.inl hn, Or.inr ⟨n, hn⟩]⟩
#align nat.or_exists_succ Nat.or_exists_succ
-/

/-! ### `succ` -/


#print LT.lt.nat_succ_le /-
theorem LT.lt.nat_succ_le {n m : ℕ} (h : n < m) : succ n ≤ m :=
  succ_le_of_lt h
#align has_lt.lt.nat_succ_le LT.lt.nat_succ_le
-/

#print Nat.succ_eq_one_add /-
theorem succ_eq_one_add (n : ℕ) : n.succ = 1 + n := by rw [Nat.succ_eq_add_one, Nat.add_comm]
#align nat.succ_eq_one_add Nat.succ_eq_one_add
-/

#print Nat.eq_of_lt_succ_of_not_lt /-
theorem eq_of_lt_succ_of_not_lt {a b : ℕ} (h1 : a < b + 1) (h2 : ¬a < b) : a = b :=
  have h3 : a ≤ b := le_of_lt_succ h1
  Or.elim (eq_or_lt_of_not_lt h2) (fun h => h) fun h => absurd h (not_lt_of_ge h3)
#align nat.eq_of_lt_succ_of_not_lt Nat.eq_of_lt_succ_of_not_lt
-/

#print Nat.eq_of_le_of_lt_succ /-
theorem eq_of_le_of_lt_succ {n m : ℕ} (h₁ : n ≤ m) (h₂ : m < n + 1) : m = n :=
  Nat.le_antisymm (le_of_succ_le_succ h₂) h₁
#align nat.eq_of_le_of_lt_succ Nat.eq_of_le_of_lt_succ
-/

#print Nat.one_add /-
theorem one_add (n : ℕ) : 1 + n = succ n := by simp [add_comm]
#align nat.one_add Nat.one_add
-/

#print Nat.succ_pos' /-
@[simp]
theorem succ_pos' {n : ℕ} : 0 < succ n :=
  succ_pos n
#align nat.succ_pos' Nat.succ_pos'
-/

#print Nat.succ_inj /-
theorem succ_inj {n m : ℕ} : succ n = succ m ↔ n = m :=
  ⟨succ.inj, congr_arg _⟩
#align nat.succ_inj' Nat.succ_inj
-/

#print Nat.succ_injective /-
theorem succ_injective : Function.Injective Nat.succ := fun x y => succ.inj
#align nat.succ_injective Nat.succ_injective
-/

#print Nat.succ_ne_succ /-
theorem succ_ne_succ {n m : ℕ} : succ n ≠ succ m ↔ n ≠ m :=
  succ_injective.ne_iff
#align nat.succ_ne_succ Nat.succ_ne_succ
-/

#print Nat.succ_succ_ne_one /-
@[simp]
theorem succ_succ_ne_one (n : ℕ) : n.succ.succ ≠ 1 :=
  succ_ne_succ.mpr n.succ_ne_zero
#align nat.succ_succ_ne_one Nat.succ_succ_ne_one
-/

#print Nat.one_lt_succ_succ /-
@[simp]
theorem one_lt_succ_succ (n : ℕ) : 1 < n.succ.succ :=
  succ_lt_succ <| succ_pos n
#align nat.one_lt_succ_succ Nat.one_lt_succ_succ
-/

#print Nat.succ_le_succ_iff /-
theorem succ_le_succ_iff {m n : ℕ} : succ m ≤ succ n ↔ m ≤ n :=
  ⟨le_of_succ_le_succ, succ_le_succ⟩
#align nat.succ_le_succ_iff Nat.succ_le_succ_iff
-/

#print Nat.succ_max_succ /-
theorem succ_max_succ {m n : ℕ} : max (succ m) (succ n) = succ (max m n) :=
  by
  by_cases h1 : m ≤ n
  rw [max_eq_right h1, max_eq_right (succ_le_succ h1)]
  · rw [not_le] at h1; have h2 := le_of_lt h1
    rw [max_eq_left h2, max_eq_left (succ_le_succ h2)]
#align nat.max_succ_succ Nat.succ_max_succ
-/

#print Nat.not_succ_lt_self /-
theorem not_succ_lt_self {n : ℕ} : ¬succ n < n :=
  not_lt_of_ge (Nat.le_succ _)
#align nat.not_succ_lt_self Nat.not_succ_lt_self
-/

#print Nat.lt_succ_iff /-
theorem lt_succ_iff {m n : ℕ} : m < succ n ↔ m ≤ n :=
  ⟨le_of_lt_succ, lt_succ_of_le⟩
#align nat.lt_succ_iff Nat.lt_succ_iff
-/

#print Nat.succ_le_iff /-
theorem succ_le_iff {m n : ℕ} : succ m ≤ n ↔ m < n :=
  ⟨lt_of_succ_le, succ_le_of_lt⟩
#align nat.succ_le_iff Nat.succ_le_iff
-/

#print Nat.lt_iff_add_one_le /-
theorem lt_iff_add_one_le {m n : ℕ} : m < n ↔ m + 1 ≤ n := by rw [succ_le_iff]
#align nat.lt_iff_add_one_le Nat.lt_iff_add_one_le
-/

#print Nat.lt_add_one_iff /-
-- Just a restatement of `nat.lt_succ_iff` using `+1`.
theorem lt_add_one_iff {a b : ℕ} : a < b + 1 ↔ a ≤ b :=
  lt_succ_iff
#align nat.lt_add_one_iff Nat.lt_add_one_iff
-/

#print Nat.lt_one_add_iff /-
-- A flipped version of `lt_add_one_iff`.
theorem lt_one_add_iff {a b : ℕ} : a < 1 + b ↔ a ≤ b := by simp only [add_comm, lt_succ_iff]
#align nat.lt_one_add_iff Nat.lt_one_add_iff
-/

#print Nat.add_one_le_iff /-
-- This is true reflexively, by the definition of `≤` on ℕ,
-- but it's still useful to have, to convince Lean to change the syntactic type.
theorem add_one_le_iff {a b : ℕ} : a + 1 ≤ b ↔ a < b :=
  Iff.refl _
#align nat.add_one_le_iff Nat.add_one_le_iff
-/

#print Nat.one_add_le_iff /-
theorem one_add_le_iff {a b : ℕ} : 1 + a ≤ b ↔ a < b := by simp only [add_comm, add_one_le_iff]
#align nat.one_add_le_iff Nat.one_add_le_iff
-/

#print Nat.of_le_succ /-
theorem of_le_succ {n m : ℕ} (H : n ≤ m.succ) : n ≤ m ∨ n = m.succ :=
  H.lt_or_eq_dec.imp le_of_lt_succ id
#align nat.of_le_succ Nat.of_le_succ
-/

#print Nat.succ_lt_succ_iff /-
theorem succ_lt_succ_iff {m n : ℕ} : succ m < succ n ↔ m < n :=
  ⟨lt_of_succ_lt_succ, succ_lt_succ⟩
#align nat.succ_lt_succ_iff Nat.succ_lt_succ_iff
-/

#print Nat.div_le_iff_le_mul_add_pred /-
theorem div_le_iff_le_mul_add_pred {m n k : ℕ} (n0 : 0 < n) : m / n ≤ k ↔ m ≤ n * k + (n - 1) :=
  by
  rw [← lt_succ_iff, div_lt_iff_lt_mul n0, succ_mul, mul_comm]
  cases n; · cases n0
  exact lt_succ_iff
#align nat.div_le_iff_le_mul_add_pred Nat.div_le_iff_le_mul_add_pred
-/

#print Nat.two_lt_of_ne /-
theorem two_lt_of_ne : ∀ {n}, n ≠ 0 → n ≠ 1 → n ≠ 2 → 2 < n
  | 0, h, _, _ => (h rfl).elim
  | 1, _, h, _ => (h rfl).elim
  | 2, _, _, h => (h rfl).elim
  | n + 3, _, _, _ => by decide
#align nat.two_lt_of_ne Nat.two_lt_of_ne
-/

#print Nat.forall_lt_succ /-
theorem forall_lt_succ {P : ℕ → Prop} {n : ℕ} : (∀ m < n + 1, P m) ↔ (∀ m < n, P m) ∧ P n := by
  simp only [lt_succ_iff, Decidable.le_iff_eq_or_lt, forall_eq_or_imp, and_comm]
#align nat.forall_lt_succ Nat.forall_lt_succ
-/

#print Nat.exists_lt_succ /-
theorem exists_lt_succ {P : ℕ → Prop} {n : ℕ} : (∃ m < n + 1, P m) ↔ (∃ m < n, P m) ∨ P n := by
  rw [← not_iff_not]; push_neg; exact forall_lt_succ
#align nat.exists_lt_succ Nat.exists_lt_succ
-/

/-! ### `add` -/


#print Nat.add_def /-
-- Sometimes a bare `nat.add` or similar appears as a consequence of unfolding
-- during pattern matching. These lemmas package them back up as typeclass
-- mediated operations.
@[simp]
theorem add_def {a b : ℕ} : Nat.add a b = a + b :=
  rfl
#align nat.add_def Nat.add_def
-/

#print Nat.mul_def /-
@[simp]
theorem mul_def {a b : ℕ} : Nat.mul a b = a * b :=
  rfl
#align nat.mul_def Nat.mul_def
-/

#print Nat.exists_eq_add_of_le /-
theorem exists_eq_add_of_le (h : m ≤ n) : ∃ k : ℕ, n = m + k :=
  ⟨n - m, (Nat.add_sub_of_le h).symm⟩
#align nat.exists_eq_add_of_le Nat.exists_eq_add_of_le
-/

#print Nat.exists_eq_add_of_le' /-
theorem exists_eq_add_of_le' (h : m ≤ n) : ∃ k : ℕ, n = k + m :=
  ⟨n - m, (Nat.sub_add_cancel h).symm⟩
#align nat.exists_eq_add_of_le' Nat.exists_eq_add_of_le'
-/

#print Nat.exists_eq_add_of_lt /-
theorem exists_eq_add_of_lt (h : m < n) : ∃ k : ℕ, n = m + k + 1 :=
  ⟨n - (m + 1), by rw [add_right_comm, Nat.add_sub_of_le h]⟩
#align nat.exists_eq_add_of_lt Nat.exists_eq_add_of_lt
-/

/-! ### `pred` -/


#print Nat.add_succ_sub_one /-
@[simp]
theorem add_succ_sub_one (n m : ℕ) : n + succ m - 1 = n + m := by rw [add_succ, succ_sub_one]
#align nat.add_succ_sub_one Nat.add_succ_sub_one
-/

#print Nat.succ_add_sub_one /-
@[simp]
theorem succ_add_sub_one (n m : ℕ) : succ n + m - 1 = n + m := by rw [succ_add, succ_sub_one]
#align nat.succ_add_sub_one Nat.succ_add_sub_one
-/

#print Nat.pred_eq_sub_one /-
theorem pred_eq_sub_one (n : ℕ) : pred n = n - 1 :=
  rfl
#align nat.pred_eq_sub_one Nat.pred_eq_sub_one
-/

#print Nat.pred_eq_of_eq_succ /-
theorem pred_eq_of_eq_succ {m n : ℕ} (H : m = n.succ) : m.pred = n := by simp [H]
#align nat.pred_eq_of_eq_succ Nat.pred_eq_of_eq_succ
-/

#print Nat.pred_eq_succ_iff /-
@[simp]
theorem pred_eq_succ_iff {n m : ℕ} : pred n = succ m ↔ n = m + 2 := by
  cases n <;> constructor <;> rintro ⟨⟩ <;> rfl
#align nat.pred_eq_succ_iff Nat.pred_eq_succ_iff
-/

#print Nat.pred_sub /-
theorem pred_sub (n m : ℕ) : pred n - m = pred (n - m) := by
  rw [← Nat.sub_one, Nat.sub_sub, one_add, sub_succ]
#align nat.pred_sub Nat.pred_sub
-/

#print Nat.le_pred_of_lt /-
theorem le_pred_of_lt {n m : ℕ} (h : m < n) : m ≤ n - 1 :=
  Nat.sub_le_sub_right h 1
#align nat.le_pred_of_lt Nat.le_pred_of_lt
-/

#print Nat.le_of_pred_lt /-
theorem le_of_pred_lt {m n : ℕ} : pred m < n → m ≤ n :=
  match m with
  | 0 => le_of_lt
  | m + 1 => id
#align nat.le_of_pred_lt Nat.le_of_pred_lt
-/

#print Nat.pred_one_add /-
/-- This ensures that `simp` succeeds on `pred (n + 1) = n`. -/
@[simp]
theorem pred_one_add (n : ℕ) : pred (1 + n) = n := by rw [add_comm, add_one, pred_succ]
#align nat.pred_one_add Nat.pred_one_add
-/

/-! ### `mul` -/


#print Nat.two_mul_ne_two_mul_add_one /-
theorem two_mul_ne_two_mul_add_one {n m} : 2 * n ≠ 2 * m + 1 :=
  mt (congr_arg (· % 2))
    (by rw [add_comm, add_mul_mod_self_left, mul_mod_right, mod_eq_of_lt] <;> simp)
#align nat.two_mul_ne_two_mul_add_one Nat.two_mul_ne_two_mul_add_one
-/

#print Nat.mul_ne_mul_left /-
theorem mul_ne_mul_left {a b c : ℕ} (ha : 0 < a) : b * a ≠ c * a ↔ b ≠ c :=
  (mul_left_injective₀ ha.ne').ne_iff
#align nat.mul_ne_mul_left Nat.mul_ne_mul_left
-/

#print Nat.mul_ne_mul_right /-
theorem mul_ne_mul_right {a b c : ℕ} (ha : 0 < a) : a * b ≠ a * c ↔ b ≠ c :=
  (mul_right_injective₀ ha.ne').ne_iff
#align nat.mul_ne_mul_right Nat.mul_ne_mul_right
-/

#print Nat.mul_right_eq_self_iff /-
theorem mul_right_eq_self_iff {a b : ℕ} (ha : 0 < a) : a * b = a ↔ b = 1 :=
  suffices a * b = a * 1 ↔ b = 1 by rwa [mul_one] at this
  mul_right_inj' ha.ne'
#align nat.mul_right_eq_self_iff Nat.mul_right_eq_self_iff
-/

#print Nat.mul_left_eq_self_iff /-
theorem mul_left_eq_self_iff {a b : ℕ} (hb : 0 < b) : a * b = b ↔ a = 1 := by
  rw [mul_comm, Nat.mul_right_eq_self_iff hb]
#align nat.mul_left_eq_self_iff Nat.mul_left_eq_self_iff
-/

#print Nat.lt_succ_iff_lt_or_eq /-
theorem lt_succ_iff_lt_or_eq {n i : ℕ} : n < i.succ ↔ n < i ∨ n = i :=
  lt_succ_iff.trans Decidable.le_iff_lt_or_eq
#align nat.lt_succ_iff_lt_or_eq Nat.lt_succ_iff_lt_or_eq
-/

/-!
### Recursion and induction principles

This section is here due to dependencies -- the lemmas here require some of the lemmas
proved above, and some of the results in later sections depend on the definitions in this section.
-/


#print Nat.rec_zero /-
@[simp]
theorem rec_zero {C : ℕ → Sort u} (h0 : C 0) (h : ∀ n, C n → C (n + 1)) :
    (Nat.rec h0 h : ∀ n, C n) 0 = h0 :=
  rfl
#align nat.rec_zero Nat.rec_zero
-/

#print Nat.rec_add_one /-
@[simp]
theorem rec_add_one {C : ℕ → Sort u} (h0 : C 0) (h : ∀ n, C n → C (n + 1)) (n : ℕ) :
    (Nat.rec h0 h : ∀ n, C n) (n + 1) = h n ((Nat.rec h0 h : ∀ n, C n) n) :=
  rfl
#align nat.rec_add_one Nat.rec_add_one
-/

#print Nat.leRecOn /-
/-- Recursion starting at a non-zero number: given a map `C k → C (k+1)` for each `k`,
there is a map from `C n` to each `C m`, `n ≤ m`. For a version where the assumption is only made
when `k ≥ n`, see `le_rec_on'`. -/
@[elab_as_elim]
def leRecOn {C : ℕ → Sort u} {n : ℕ} : ∀ {m : ℕ}, n ≤ m → (∀ {k}, C k → C (k + 1)) → C n → C m
  | 0, H, next, x => Eq.recOn (Nat.eq_zero_of_le_zero H) x
  | m + 1, H, next, x =>
    Or.by_cases (of_le_succ H) (fun h : n ≤ m => next <| le_rec_on h (@next) x) fun h : n = m + 1 =>
      Eq.recOn h x
#align nat.le_rec_on Nat.leRecOn
-/

#print Nat.leRecOn_self /-
theorem leRecOn_self {C : ℕ → Sort u} {n} {h : n ≤ n} {next} (x : C n) :
    (leRecOn h next x : C n) = x := by
  cases n <;> unfold le_rec_on Or.by_cases <;> rw [dif_neg n.not_succ_le_self]
#align nat.le_rec_on_self Nat.leRecOn_self
-/

#print Nat.leRecOn_succ /-
theorem leRecOn_succ {C : ℕ → Sort u} {n m} (h1 : n ≤ m) {h2 : n ≤ m + 1} {next} (x : C n) :
    (leRecOn h2 (@next) x : C (m + 1)) = next (leRecOn h1 (@next) x : C m) := by
  conv =>
    lhs
    rw [le_rec_on, Or.by_cases, dif_pos h1]
#align nat.le_rec_on_succ Nat.leRecOn_succ
-/

#print Nat.leRecOn_succ' /-
theorem leRecOn_succ' {C : ℕ → Sort u} {n} {h : n ≤ n + 1} {next} (x : C n) :
    (leRecOn h next x : C (n + 1)) = next x := by rw [le_rec_on_succ (le_refl n), le_rec_on_self]
#align nat.le_rec_on_succ' Nat.leRecOn_succ'
-/

#print Nat.leRecOn_trans /-
theorem leRecOn_trans {C : ℕ → Sort u} {n m k} (hnm : n ≤ m) (hmk : m ≤ k) {next} (x : C n) :
    (leRecOn (le_trans hnm hmk) (@next) x : C k) = leRecOn hmk (@next) (leRecOn hnm (@next) x) :=
  by
  induction' hmk with k hmk ih; · rw [le_rec_on_self]
  rw [le_rec_on_succ (le_trans hnm hmk), ih, le_rec_on_succ]
#align nat.le_rec_on_trans Nat.leRecOn_trans
-/

#print Nat.leRecOn_succ_left /-
theorem leRecOn_succ_left {C : ℕ → Sort u} {n m} (h1 : n ≤ m) (h2 : n + 1 ≤ m)
    {next : ∀ ⦃k⦄, C k → C (k + 1)} (x : C n) :
    (leRecOn h2 next (next x) : C m) = (leRecOn h1 next x : C m) := by
  rw [Subsingleton.elim h1 (le_trans (le_succ n) h2), le_rec_on_trans (le_succ n) h2,
    le_rec_on_succ']
#align nat.le_rec_on_succ_left Nat.leRecOn_succ_left
-/

#print Nat.leRecOn_injective /-
theorem leRecOn_injective {C : ℕ → Sort u} {n m} (hnm : n ≤ m) (next : ∀ n, C n → C (n + 1))
    (Hnext : ∀ n, Function.Injective (next n)) : Function.Injective (leRecOn hnm next) :=
  by
  induction' hnm with m hnm ih; · intro x y H; rwa [le_rec_on_self, le_rec_on_self] at H
  intro x y H; rw [le_rec_on_succ hnm, le_rec_on_succ hnm] at H; exact ih (Hnext _ H)
#align nat.le_rec_on_injective Nat.leRecOn_injective
-/

#print Nat.leRecOn_surjective /-
theorem leRecOn_surjective {C : ℕ → Sort u} {n m} (hnm : n ≤ m) (next : ∀ n, C n → C (n + 1))
    (Hnext : ∀ n, Function.Surjective (next n)) : Function.Surjective (leRecOn hnm next) :=
  by
  induction' hnm with m hnm ih; · intro x; use x; rw [le_rec_on_self]
  intro x; rcases Hnext _ x with ⟨w, rfl⟩; rcases ih w with ⟨x, rfl⟩; use x; rw [le_rec_on_succ]
#align nat.le_rec_on_surjective Nat.leRecOn_surjective
-/

#print Nat.strongRec' /-
/-- Recursion principle based on `<`. -/
@[elab_as_elim]
protected def strongRec' {p : ℕ → Sort u} (H : ∀ n, (∀ m, m < n → p m) → p n) : ∀ n : ℕ, p n
  | n => H n fun m hm => strong_rec' m
#align nat.strong_rec' Nat.strongRec'
-/

#print Nat.strongRecOn' /-
/-- Recursion principle based on `<` applied to some natural number. -/
@[elab_as_elim]
def strongRecOn' {P : ℕ → Sort _} (n : ℕ) (h : ∀ n, (∀ m, m < n → P m) → P n) : P n :=
  Nat.strongRec' h n
#align nat.strong_rec_on' Nat.strongRecOn'
-/

#print Nat.strongRecOn'_beta /-
theorem strongRecOn'_beta {P : ℕ → Sort _} {h} {n : ℕ} :
    (strongRecOn' n h : P n) = h n fun m hmn => (strongRecOn' m h : P m) := by
  simp only [strong_rec_on']; rw [Nat.strongRec']
#align nat.strong_rec_on_beta' Nat.strongRecOn'_beta
-/

#print Nat.le_induction /-
/-- Induction principle starting at a non-zero number. For maps to a `Sort*` see `le_rec_on`. -/
@[elab_as_elim]
theorem le_induction {P : Nat → Prop} {m} (h0 : P m) (h1 : ∀ n, m ≤ n → P n → P (n + 1)) :
    ∀ n, m ≤ n → P n := by apply Nat.le.ndrec h0 <;> exact h1
#align nat.le_induction Nat.le_induction
-/

#print Nat.decreasingInduction /-
/-- Decreasing induction: if `P (k+1)` implies `P k`, then `P n` implies `P m` for all `m ≤ n`.
Also works for functions to `Sort*`. For a version assuming only the assumption for `k < n`, see
`decreasing_induction'`. -/
@[elab_as_elim]
def decreasingInduction {P : ℕ → Sort _} (h : ∀ n, P (n + 1) → P n) {m n : ℕ} (mn : m ≤ n)
    (hP : P n) : P m :=
  leRecOn mn (fun k ih hsk => ih <| h k hsk) (fun h => h) hP
#align nat.decreasing_induction Nat.decreasingInduction
-/

#print Nat.decreasingInduction_self /-
@[simp]
theorem decreasingInduction_self {P : ℕ → Sort _} (h : ∀ n, P (n + 1) → P n) {n : ℕ} (nn : n ≤ n)
    (hP : P n) : (decreasingInduction h nn hP : P n) = hP := by dsimp only [decreasing_induction];
  rw [le_rec_on_self]
#align nat.decreasing_induction_self Nat.decreasingInduction_self
-/

#print Nat.decreasingInduction_succ /-
theorem decreasingInduction_succ {P : ℕ → Sort _} (h : ∀ n, P (n + 1) → P n) {m n : ℕ} (mn : m ≤ n)
    (msn : m ≤ n + 1) (hP : P (n + 1)) :
    (decreasingInduction h msn hP : P m) = decreasingInduction h mn (h n hP) := by
  dsimp only [decreasing_induction]; rw [le_rec_on_succ]
#align nat.decreasing_induction_succ Nat.decreasingInduction_succ
-/

#print Nat.decreasingInduction_succ' /-
@[simp]
theorem decreasingInduction_succ' {P : ℕ → Sort _} (h : ∀ n, P (n + 1) → P n) {m : ℕ}
    (msm : m ≤ m + 1) (hP : P (m + 1)) : (decreasingInduction h msm hP : P m) = h m hP := by
  dsimp only [decreasing_induction]; rw [le_rec_on_succ']
#align nat.decreasing_induction_succ' Nat.decreasingInduction_succ'
-/

#print Nat.decreasingInduction_trans /-
theorem decreasingInduction_trans {P : ℕ → Sort _} (h : ∀ n, P (n + 1) → P n) {m n k : ℕ}
    (mn : m ≤ n) (nk : n ≤ k) (hP : P k) :
    (decreasingInduction h (le_trans mn nk) hP : P m) =
      decreasingInduction h mn (decreasingInduction h nk hP) :=
  by
  induction' nk with k nk ih; rw [decreasing_induction_self]
  rw [decreasing_induction_succ h (le_trans mn nk), ih, decreasing_induction_succ]
#align nat.decreasing_induction_trans Nat.decreasingInduction_trans
-/

#print Nat.decreasingInduction_succ_left /-
theorem decreasingInduction_succ_left {P : ℕ → Sort _} (h : ∀ n, P (n + 1) → P n) {m n : ℕ}
    (smn : m + 1 ≤ n) (mn : m ≤ n) (hP : P n) :
    (decreasingInduction h mn hP : P m) = h m (decreasingInduction h smn hP) := by
  rw [Subsingleton.elim mn (le_trans (le_succ m) smn), decreasing_induction_trans,
    decreasing_induction_succ']
#align nat.decreasing_induction_succ_left Nat.decreasingInduction_succ_left
-/

#print Nat.strongSubRecursion /-
/-- Given `P : ℕ → ℕ → Sort*`, if for all `a b : ℕ` we can extend `P` from the rectangle
strictly below `(a,b)` to `P a b`, then we have `P n m` for all `n m : ℕ`.
Note that for non-`Prop` output it is preferable to use the equation compiler directly if possible,
since this produces equation lemmas. -/
@[elab_as_elim]
def strongSubRecursion {P : ℕ → ℕ → Sort _} (H : ∀ a b, (∀ x y, x < a → y < b → P x y) → P a b) :
    ∀ n m : ℕ, P n m
  | n, m => H n m fun x y hx hy => strong_sub_recursion x y
#align nat.strong_sub_recursion Nat.strongSubRecursion
-/

#print Nat.pincerRecursion /-
/-- Given `P : ℕ → ℕ → Sort*`, if we have `P i 0` and `P 0 i` for all `i : ℕ`,
and for any `x y : ℕ` we can extend `P` from `(x,y+1)` and `(x+1,y)` to `(x+1,y+1)`
then we have `P n m` for all `n m : ℕ`.
Note that for non-`Prop` output it is preferable to use the equation compiler directly if possible,
since this produces equation lemmas. -/
@[elab_as_elim]
def pincerRecursion {P : ℕ → ℕ → Sort _} (Ha0 : ∀ a : ℕ, P a 0) (H0b : ∀ b : ℕ, P 0 b)
    (H : ∀ x y : ℕ, P x y.succ → P x.succ y → P x.succ y.succ) : ∀ n m : ℕ, P n m
  | a, 0 => Ha0 a
  | 0, b => H0b b
  | Nat.succ a, Nat.succ b => H _ _ (pincer_recursion _ _) (pincer_recursion _ _)
#align nat.pincer_recursion Nat.pincerRecursion
-/

#print Nat.leRecOn' /-
/-- Recursion starting at a non-zero number: given a map `C k → C (k+1)` for each `k ≥ n`,
there is a map from `C n` to each `C m`, `n ≤ m`. -/
@[elab_as_elim]
def leRecOn' {C : ℕ → Sort _} {n : ℕ} :
    ∀ {m : ℕ}, n ≤ m → (∀ ⦃k⦄, n ≤ k → C k → C (k + 1)) → C n → C m
  | 0, H, next, x => Eq.recOn (Nat.eq_zero_of_le_zero H) x
  | m + 1, H, next, x =>
    Or.by_cases (of_le_succ H) (fun h : n ≤ m => next h <| le_rec_on' h next x) fun h : n = m + 1 =>
      Eq.recOn h x
#align nat.le_rec_on' Nat.leRecOn'
-/

#print Nat.decreasingInduction' /-
/-- Decreasing induction: if `P (k+1)` implies `P k` for all `m ≤ k < n`, then `P n` implies `P m`.
Also works for functions to `Sort*`. Weakens the assumptions of `decreasing_induction`. -/
@[elab_as_elim]
def decreasingInduction' {P : ℕ → Sort _} {m n : ℕ} (h : ∀ k < n, m ≤ k → P (k + 1) → P k)
    (mn : m ≤ n) (hP : P n) : P m :=
  by
  -- induction mn using nat.le_rec_on' generalizing h hP -- this doesn't work unfortunately
    refine' le_rec_on' mn _ _ h hP <;>
    clear h hP mn n
  · intro n mn ih h hP
    apply ih
    · exact fun k hk => h k hk.step
    · exact h n (lt_succ_self n) mn hP
  · intro h hP; exact hP
#align nat.decreasing_induction' Nat.decreasingInduction'
-/

/-! ### `div` -/


attribute [simp] Nat.div_self

#print Nat.div_lt_self' /-
/-- A version of `nat.div_lt_self` using successors, rather than additional hypotheses. -/
theorem div_lt_self' (n b : ℕ) : (n + 1) / (b + 2) < n + 1 :=
  Nat.div_lt_self (Nat.succ_pos n) (Nat.succ_lt_succ (Nat.succ_pos _))
#align nat.div_lt_self' Nat.div_lt_self'
-/

#print Nat.le_div_iff_mul_le' /-
theorem le_div_iff_mul_le' {x y : ℕ} {k : ℕ} (k0 : 0 < k) : x ≤ y / k ↔ x * k ≤ y :=
  le_div_iff_mul_le k0
#align nat.le_div_iff_mul_le' Nat.le_div_iff_mul_le'
-/

#print Nat.div_lt_iff_lt_mul' /-
theorem div_lt_iff_lt_mul' {x y : ℕ} {k : ℕ} (k0 : 0 < k) : x / k < y ↔ x < y * k :=
  lt_iff_lt_of_le_iff_le <| le_div_iff_mul_le' k0
#align nat.div_lt_iff_lt_mul' Nat.div_lt_iff_lt_mul'
-/

#print Nat.one_le_div_iff /-
theorem one_le_div_iff {a b : ℕ} (hb : 0 < b) : 1 ≤ a / b ↔ b ≤ a := by
  rw [le_div_iff_mul_le hb, one_mul]
#align nat.one_le_div_iff Nat.one_le_div_iff
-/

#print Nat.div_lt_one_iff /-
theorem div_lt_one_iff {a b : ℕ} (hb : 0 < b) : a / b < 1 ↔ a < b :=
  lt_iff_lt_of_le_iff_le <| one_le_div_iff hb
#align nat.div_lt_one_iff Nat.div_lt_one_iff
-/

#print Nat.div_le_div_right /-
protected theorem div_le_div_right {n m : ℕ} (h : n ≤ m) {k : ℕ} : n / k ≤ m / k :=
  (Nat.eq_zero_or_pos k).elim (fun k0 => by simp [k0]) fun hk =>
    (le_div_iff_mul_le' hk).2 <| le_trans (Nat.div_mul_le_self _ _) h
#align nat.div_le_div_right Nat.div_le_div_right
-/

#print Nat.lt_of_div_lt_div /-
theorem lt_of_div_lt_div {m n k : ℕ} : m / k < n / k → m < n :=
  lt_imp_lt_of_le_imp_le fun h => Nat.div_le_div_right h
#align nat.lt_of_div_lt_div Nat.lt_of_div_lt_div
-/

#print Nat.div_pos /-
protected theorem div_pos {a b : ℕ} (hba : b ≤ a) (hb : 0 < b) : 0 < a / b :=
  Nat.pos_of_ne_zero fun h =>
    lt_irrefl a
      (calc
        a = a % b := by simpa [h] using (mod_add_div a b).symm
        _ < b := (Nat.mod_lt a hb)
        _ ≤ a := hba)
#align nat.div_pos Nat.div_pos
-/

#print Nat.lt_mul_of_div_lt /-
theorem lt_mul_of_div_lt {a b c : ℕ} (h : a / c < b) (w : 0 < c) : a < b * c :=
  lt_of_not_ge <| not_le_of_gt h ∘ (Nat.le_div_iff_mul_le w).2
#align nat.lt_mul_of_div_lt Nat.lt_mul_of_div_lt
-/

#print Nat.mul_div_le_mul_div_assoc /-
theorem mul_div_le_mul_div_assoc (a b c : ℕ) : a * (b / c) ≤ a * b / c :=
  if hc0 : c = 0 then by simp [hc0]
  else
    (Nat.le_div_iff_mul_le (Nat.pos_of_ne_zero hc0)).2
      (by rw [mul_assoc] <;> exact Nat.mul_le_mul_left _ (Nat.div_mul_le_self _ _))
#align nat.mul_div_le_mul_div_assoc Nat.mul_div_le_mul_div_assoc
-/

#print Nat.eq_mul_of_div_eq_right /-
protected theorem eq_mul_of_div_eq_right {a b c : ℕ} (H1 : b ∣ a) (H2 : a / b = c) : a = b * c := by
  rw [← H2, Nat.mul_div_cancel' H1]
#align nat.eq_mul_of_div_eq_right Nat.eq_mul_of_div_eq_right
-/

#print Nat.div_eq_iff_eq_mul_right /-
protected theorem div_eq_iff_eq_mul_right {a b c : ℕ} (H : 0 < b) (H' : b ∣ a) :
    a / b = c ↔ a = b * c :=
  ⟨Nat.eq_mul_of_div_eq_right H', Nat.div_eq_of_eq_mul_right H⟩
#align nat.div_eq_iff_eq_mul_right Nat.div_eq_iff_eq_mul_right
-/

#print Nat.div_eq_iff_eq_mul_left /-
protected theorem div_eq_iff_eq_mul_left {a b c : ℕ} (H : 0 < b) (H' : b ∣ a) :
    a / b = c ↔ a = c * b := by rw [mul_comm] <;> exact Nat.div_eq_iff_eq_mul_right H H'
#align nat.div_eq_iff_eq_mul_left Nat.div_eq_iff_eq_mul_left
-/

#print Nat.eq_mul_of_div_eq_left /-
protected theorem eq_mul_of_div_eq_left {a b c : ℕ} (H1 : b ∣ a) (H2 : a / b = c) : a = c * b := by
  rw [mul_comm, Nat.eq_mul_of_div_eq_right H1 H2]
#align nat.eq_mul_of_div_eq_left Nat.eq_mul_of_div_eq_left
-/

#print Nat.mul_div_cancel_left' /-
protected theorem mul_div_cancel_left' {a b : ℕ} (Hd : a ∣ b) : a * (b / a) = b := by
  rw [mul_comm, Nat.div_mul_cancel Hd]
#align nat.mul_div_cancel_left' Nat.mul_div_cancel_left'
-/

/- warning: nat.mul_div_mul_left clashes with nat.mul_div_mul -> Nat.mul_div_mul_left
Case conversion may be inaccurate. Consider using '#align nat.mul_div_mul_left Nat.mul_div_mul_leftₓ'. -/
#print Nat.mul_div_mul_left /-
--TODO: Update `nat.mul_div_mul` in the core?
/-- Alias of `nat.mul_div_mul` -/
protected theorem mul_div_mul_left (a b : ℕ) {c : ℕ} (hc : 0 < c) : c * a / (c * b) = a / b :=
  Nat.mul_div_mul_left a b hc
#align nat.mul_div_mul_left Nat.mul_div_mul_left
-/

#print Nat.mul_div_mul_right /-
protected theorem mul_div_mul_right (a b : ℕ) {c : ℕ} (hc : 0 < c) : a * c / (b * c) = a / b := by
  rw [mul_comm, mul_comm b, a.mul_div_mul_left b hc]
#align nat.mul_div_mul_right Nat.mul_div_mul_right
-/

#print Nat.lt_div_mul_add /-
theorem lt_div_mul_add {a b : ℕ} (hb : 0 < b) : a < a / b * b + b :=
  by
  rw [← Nat.succ_mul, ← Nat.div_lt_iff_lt_mul hb]
  exact Nat.lt_succ_self _
#align nat.lt_div_mul_add Nat.lt_div_mul_add
-/

#print Nat.div_left_inj /-
@[simp]
protected theorem div_left_inj {a b d : ℕ} (hda : d ∣ a) (hdb : d ∣ b) : a / d = b / d ↔ a = b :=
  by
  refine' ⟨fun h => _, congr_arg _⟩
  rw [← Nat.mul_div_cancel' hda, ← Nat.mul_div_cancel' hdb, h]
#align nat.div_left_inj Nat.div_left_inj
-/

/-! ### `mod`, `dvd` -/


#print Nat.mod_eq_iff_lt /-
theorem mod_eq_iff_lt {a b : ℕ} (h : b ≠ 0) : a % b = a ↔ a < b :=
  by
  cases b; contradiction
  exact ⟨fun h => h.ge.trans_lt (mod_lt _ (succ_pos _)), mod_eq_of_lt⟩
#align nat.mod_eq_iff_lt Nat.mod_eq_iff_lt
-/

#print Nat.mod_succ_eq_iff_lt /-
@[simp]
theorem mod_succ_eq_iff_lt {a b : ℕ} : a % b.succ = a ↔ a < b.succ :=
  mod_eq_iff_lt (succ_ne_zero _)
#align nat.mod_succ_eq_iff_lt Nat.mod_succ_eq_iff_lt
-/

#print Nat.div_add_mod /-
theorem div_add_mod (m k : ℕ) : k * (m / k) + m % k = m :=
  (Nat.add_comm _ _).trans (mod_add_div _ _)
#align nat.div_add_mod Nat.div_add_mod
-/

#print Nat.mod_add_div' /-
theorem mod_add_div' (m k : ℕ) : m % k + m / k * k = m := by rw [mul_comm]; exact mod_add_div _ _
#align nat.mod_add_div' Nat.mod_add_div'
-/

#print Nat.div_add_mod' /-
theorem div_add_mod' (m k : ℕ) : m / k * k + m % k = m := by rw [mul_comm]; exact div_add_mod _ _
#align nat.div_add_mod' Nat.div_add_mod'
-/

#print Nat.div_mod_unique /-
/-- See also `nat.div_mod_equiv` for a similar statement as an `equiv`. -/
protected theorem div_mod_unique {n k m d : ℕ} (h : 0 < k) :
    n / k = d ∧ n % k = m ↔ m + k * d = n ∧ m < k :=
  ⟨fun ⟨e₁, e₂⟩ => e₁ ▸ e₂ ▸ ⟨mod_add_div _ _, mod_lt _ h⟩, fun ⟨h₁, h₂⟩ =>
    h₁ ▸ by
      rw [add_mul_div_left _ _ h, add_mul_mod_self_left] <;> simp [div_eq_of_lt, mod_eq_of_lt, h₂]⟩
#align nat.div_mod_unique Nat.div_mod_unique
-/

#print Nat.dvd_add_left /-
protected theorem dvd_add_left {k m n : ℕ} (h : k ∣ n) : k ∣ m + n ↔ k ∣ m :=
  (Nat.dvd_add_iff_left h).symm
#align nat.dvd_add_left Nat.dvd_add_left
-/

#print Nat.dvd_add_right /-
protected theorem dvd_add_right {k m n : ℕ} (h : k ∣ m) : k ∣ m + n ↔ k ∣ n :=
  (Nat.dvd_add_iff_right h).symm
#align nat.dvd_add_right Nat.dvd_add_right
-/

#print Nat.mul_dvd_mul_iff_left /-
protected theorem mul_dvd_mul_iff_left {a b c : ℕ} (ha : 0 < a) : a * b ∣ a * c ↔ b ∣ c :=
  exists_congr fun d => by rw [mul_assoc, mul_right_inj' ha.ne']
#align nat.mul_dvd_mul_iff_left Nat.mul_dvd_mul_iff_left
-/

#print Nat.mul_dvd_mul_iff_right /-
protected theorem mul_dvd_mul_iff_right {a b c : ℕ} (hc : 0 < c) : a * c ∣ b * c ↔ a ∣ b :=
  exists_congr fun d => by rw [mul_right_comm, mul_left_inj' hc.ne']
#align nat.mul_dvd_mul_iff_right Nat.mul_dvd_mul_iff_right
-/

#print Nat.mod_mod_of_dvd /-
@[simp]
theorem mod_mod_of_dvd (n : Nat) {m k : Nat} (h : m ∣ k) : n % k % m = n % m :=
  by
  conv =>
    rhs
    rw [← mod_add_div n k]
  rcases h with ⟨t, rfl⟩; rw [mul_assoc, add_mul_mod_self_left]
#align nat.mod_mod_of_dvd Nat.mod_mod_of_dvd
-/

#print Nat.mod_mod /-
@[simp]
theorem mod_mod (a n : ℕ) : a % n % n = a % n :=
  (Nat.eq_zero_or_pos n).elim (fun n0 => by simp [n0]) fun npos => mod_eq_of_lt (mod_lt _ npos)
#align nat.mod_mod Nat.mod_mod
-/

#print Nat.mod_add_mod /-
@[simp]
theorem mod_add_mod (m n k : ℕ) : (m % n + k) % n = (m + k) % n := by
  have := (add_mul_mod_self_left (m % n + k) n (m / n)).symm <;>
    rwa [add_right_comm, mod_add_div] at this
#align nat.mod_add_mod Nat.mod_add_mod
-/

#print Nat.add_mod_mod /-
@[simp]
theorem add_mod_mod (m n k : ℕ) : (m + n % k) % k = (m + n) % k := by
  rw [add_comm, mod_add_mod, add_comm]
#align nat.add_mod_mod Nat.add_mod_mod
-/

#print Nat.add_mod /-
theorem add_mod (a b n : ℕ) : (a + b) % n = (a % n + b % n) % n := by rw [add_mod_mod, mod_add_mod]
#align nat.add_mod Nat.add_mod
-/

#print Nat.add_mod_eq_add_mod_right /-
theorem add_mod_eq_add_mod_right {m n k : ℕ} (i : ℕ) (H : m % n = k % n) :
    (m + i) % n = (k + i) % n := by rw [← mod_add_mod, ← mod_add_mod k, H]
#align nat.add_mod_eq_add_mod_right Nat.add_mod_eq_add_mod_right
-/

#print Nat.add_mod_eq_add_mod_left /-
theorem add_mod_eq_add_mod_left {m n k : ℕ} (i : ℕ) (H : m % n = k % n) :
    (i + m) % n = (i + k) % n := by rw [add_comm, add_mod_eq_add_mod_right _ H, add_comm]
#align nat.add_mod_eq_add_mod_left Nat.add_mod_eq_add_mod_left
-/

#print Nat.mul_mod /-
theorem mul_mod (a b n : ℕ) : a * b % n = a % n * (b % n) % n := by
  conv_lhs =>
    rw [← mod_add_div a n, ← mod_add_div' b n, right_distrib, left_distrib, left_distrib, mul_assoc,
      mul_assoc, ← left_distrib n _ _, add_mul_mod_self_left, ← mul_assoc, add_mul_mod_self_right]
#align nat.mul_mod Nat.mul_mod
-/

#print Nat.mul_dvd_of_dvd_div /-
theorem mul_dvd_of_dvd_div {a b c : ℕ} (hab : c ∣ b) (h : a ∣ b / c) : c * a ∣ b :=
  have h1 : ∃ d, b / c = a * d := h
  have h2 : ∃ e, b = c * e := hab
  let ⟨d, hd⟩ := h1
  let ⟨e, he⟩ := h2
  have h3 : b = a * d * c := Nat.eq_mul_of_div_eq_left hab hd
  show ∃ d, b = c * a * d from ⟨d, by cc⟩
#align nat.mul_dvd_of_dvd_div Nat.mul_dvd_of_dvd_div
-/

#print Nat.eq_of_dvd_of_div_eq_one /-
theorem eq_of_dvd_of_div_eq_one {a b : ℕ} (w : a ∣ b) (h : b / a = 1) : a = b := by
  rw [← Nat.div_mul_cancel w, h, one_mul]
#align nat.eq_of_dvd_of_div_eq_one Nat.eq_of_dvd_of_div_eq_one
-/

#print Nat.eq_zero_of_dvd_of_div_eq_zero /-
theorem eq_zero_of_dvd_of_div_eq_zero {a b : ℕ} (w : a ∣ b) (h : b / a = 0) : b = 0 := by
  rw [← Nat.div_mul_cancel w, h, MulZeroClass.zero_mul]
#align nat.eq_zero_of_dvd_of_div_eq_zero Nat.eq_zero_of_dvd_of_div_eq_zero
-/

#print Nat.div_le_div_left /-
theorem div_le_div_left {a b c : ℕ} (h₁ : c ≤ b) (h₂ : 0 < c) : a / b ≤ a / c :=
  (Nat.le_div_iff_mul_le h₂).2 <| le_trans (Nat.mul_le_mul_left _ h₁) (div_mul_le_self _ _)
#align nat.div_le_div_left Nat.div_le_div_left
-/

#print Nat.lt_iff_le_pred /-
theorem lt_iff_le_pred : ∀ {m n : ℕ}, 0 < n → (m < n ↔ m ≤ n - 1)
  | m, n + 1, _ => lt_succ_iff
#align nat.lt_iff_le_pred Nat.lt_iff_le_pred
-/

#print Nat.mul_div_le /-
theorem mul_div_le (m n : ℕ) : n * (m / n) ≤ m :=
  by
  cases' Nat.eq_zero_or_pos n with n0 h
  · rw [n0, MulZeroClass.zero_mul]; exact m.zero_le
  · rw [mul_comm, ← Nat.le_div_iff_mul_le' h]
#align nat.mul_div_le Nat.mul_div_le
-/

#print Nat.lt_mul_div_succ /-
theorem lt_mul_div_succ (m : ℕ) {n : ℕ} (n0 : 0 < n) : m < n * (m / n + 1) :=
  by
  rw [mul_comm, ← Nat.div_lt_iff_lt_mul' n0]
  exact lt_succ_self _
#align nat.lt_mul_div_succ Nat.lt_mul_div_succ
-/

#print Nat.mul_add_mod' /-
theorem mul_add_mod' (a b c : ℕ) : (a * b + c) % b = c % b := by simp [Nat.add_mod]
#align nat.mul_add_mod Nat.mul_add_mod'
-/

#print Nat.mul_add_mod_of_lt /-
theorem mul_add_mod_of_lt {a b c : ℕ} (h : c < b) : (a * b + c) % b = c := by
  rw [Nat.mul_add_mod', Nat.mod_eq_of_lt h]
#align nat.mul_add_mod_of_lt Nat.mul_add_mod_of_lt
-/

#print Nat.pred_eq_self_iff /-
theorem pred_eq_self_iff {n : ℕ} : n.pred = n ↔ n = 0 := by
  cases n <;> simp [(Nat.succ_ne_self _).symm]
#align nat.pred_eq_self_iff Nat.pred_eq_self_iff
-/

/-! ### `find` -/


section Find

variable {p q : ℕ → Prop} [DecidablePred p] [DecidablePred q]

#print Nat.find_eq_iff /-
theorem find_eq_iff (h : ∃ n : ℕ, p n) : Nat.find h = m ↔ p m ∧ ∀ n < m, ¬p n :=
  by
  constructor
  · rintro rfl; exact ⟨Nat.find_spec h, fun _ => Nat.find_min h⟩
  · rintro ⟨hm, hlt⟩
    exact le_antisymm (Nat.find_min' h hm) (not_lt.1 <| imp_not_comm.1 (hlt _) <| Nat.find_spec h)
#align nat.find_eq_iff Nat.find_eq_iff
-/

#print Nat.find_lt_iff /-
@[simp]
theorem find_lt_iff (h : ∃ n : ℕ, p n) (n : ℕ) : Nat.find h < n ↔ ∃ m < n, p m :=
  ⟨fun h2 => ⟨Nat.find h, h2, Nat.find_spec h⟩, fun ⟨m, hmn, hm⟩ =>
    (Nat.find_min' h hm).trans_lt hmn⟩
#align nat.find_lt_iff Nat.find_lt_iff
-/

#print Nat.find_le_iff /-
@[simp]
theorem find_le_iff (h : ∃ n : ℕ, p n) (n : ℕ) : Nat.find h ≤ n ↔ ∃ m ≤ n, p m := by
  simp only [exists_prop, ← lt_succ_iff, find_lt_iff]
#align nat.find_le_iff Nat.find_le_iff
-/

#print Nat.le_find_iff /-
@[simp]
theorem le_find_iff (h : ∃ n : ℕ, p n) (n : ℕ) : n ≤ Nat.find h ↔ ∀ m < n, ¬p m := by
  simp_rw [← not_lt, find_lt_iff, not_exists]
#align nat.le_find_iff Nat.le_find_iff
-/

#print Nat.lt_find_iff /-
@[simp]
theorem lt_find_iff (h : ∃ n : ℕ, p n) (n : ℕ) : n < Nat.find h ↔ ∀ m ≤ n, ¬p m := by
  simp only [← succ_le_iff, le_find_iff, succ_le_succ_iff]
#align nat.lt_find_iff Nat.lt_find_iff
-/

#print Nat.find_eq_zero /-
@[simp]
theorem find_eq_zero (h : ∃ n : ℕ, p n) : Nat.find h = 0 ↔ p 0 := by simp [find_eq_iff]
#align nat.find_eq_zero Nat.find_eq_zero
-/

#print Nat.find_mono /-
theorem find_mono (h : ∀ n, q n → p n) {hp : ∃ n, p n} {hq : ∃ n, q n} :
    Nat.find hp ≤ Nat.find hq :=
  Nat.find_min' _ (h _ (Nat.find_spec hq))
#align nat.find_mono Nat.find_mono
-/

#print Nat.find_le /-
theorem find_le {h : ∃ n, p n} (hn : p n) : Nat.find h ≤ n :=
  (Nat.find_le_iff _ _).2 ⟨n, le_rfl, hn⟩
#align nat.find_le Nat.find_le
-/

#print Nat.find_comp_succ /-
theorem find_comp_succ (h₁ : ∃ n, p n) (h₂ : ∃ n, p (n + 1)) (h0 : ¬p 0) :
    Nat.find h₁ = Nat.find h₂ + 1 :=
  by
  refine' (find_eq_iff _).2 ⟨Nat.find_spec h₂, fun n hn => _⟩
  cases' n with n
  exacts [h0, @Nat.find_min (fun n => p (n + 1)) _ h₂ _ (succ_lt_succ_iff.1 hn)]
#align nat.find_comp_succ Nat.find_comp_succ
-/

end Find

/-! ### `find_greatest` -/


section FindGreatest

#print Nat.findGreatest /-
/-- `find_greatest P b` is the largest `i ≤ bound` such that `P i` holds, or `0` if no such `i`
exists -/
protected def findGreatest (P : ℕ → Prop) [DecidablePred P] : ℕ → ℕ
  | 0 => 0
  | n + 1 => if P (n + 1) then n + 1 else find_greatest n
#align nat.find_greatest Nat.findGreatest
-/

variable {P Q : ℕ → Prop} [DecidablePred P] {b : ℕ}

#print Nat.findGreatest_zero /-
@[simp]
theorem findGreatest_zero : Nat.findGreatest P 0 = 0 :=
  rfl
#align nat.find_greatest_zero Nat.findGreatest_zero
-/

#print Nat.findGreatest_succ /-
theorem findGreatest_succ (n : ℕ) :
    Nat.findGreatest P (n + 1) = if P (n + 1) then n + 1 else Nat.findGreatest P n :=
  rfl
#align nat.find_greatest_succ Nat.findGreatest_succ
-/

#print Nat.findGreatest_eq /-
@[simp]
theorem findGreatest_eq : ∀ {b}, P b → Nat.findGreatest P b = b
  | 0, h => rfl
  | n + 1, h => by simp [Nat.findGreatest, h]
#align nat.find_greatest_eq Nat.findGreatest_eq
-/

#print Nat.findGreatest_of_not /-
@[simp]
theorem findGreatest_of_not (h : ¬P (b + 1)) : Nat.findGreatest P (b + 1) = Nat.findGreatest P b :=
  by simp [Nat.findGreatest, h]
#align nat.find_greatest_of_not Nat.findGreatest_of_not
-/

end FindGreatest

/-! ### decidability of predicates -/


#print Nat.decidableBallLT /-
instance decidableBallLT (n : Nat) (P : ∀ k < n, Prop) :
    ∀ [H : ∀ n h, Decidable (P n h)], Decidable (∀ n h, P n h) :=
  by
  induction' n with n IH <;> intro <;> skip
  · exact is_true fun n => by decide
  cases' IH fun k h => P k (lt_succ_of_lt h) with h
  · refine' is_false (mt _ h); intro hn k h; apply hn
  by_cases p : P n (lt_succ_self n)
  ·
    exact
      is_true fun k h' =>
        (le_of_lt_succ h').lt_or_eq_dec.elim (h _) fun e =>
          match k, e, h' with
          | _, rfl, h => p
  · exact is_false (mt (fun hn => hn _ _) p)
#align nat.decidable_ball_lt Nat.decidableBallLT
-/

#print Nat.decidableForallFin /-
instance decidableForallFin {n : ℕ} (P : Fin n → Prop) [H : DecidablePred P] :
    Decidable (∀ i, P i) :=
  decidable_of_iff (∀ k h, P ⟨k, h⟩) ⟨fun a ⟨k, h⟩ => a k h, fun a k h => a ⟨k, h⟩⟩
#align nat.decidable_forall_fin Nat.decidableForallFin
-/

#print Nat.decidableBallLE /-
instance decidableBallLE (n : ℕ) (P : ∀ k ≤ n, Prop) [H : ∀ n h, Decidable (P n h)] :
    Decidable (∀ n h, P n h) :=
  decidable_of_iff (∀ (k) (h : k < succ n), P k (le_of_lt_succ h))
    ⟨fun a k h => a k (lt_succ_of_le h), fun a k h => a k _⟩
#align nat.decidable_ball_le Nat.decidableBallLE
-/

#print Nat.decidableExistsLT /-
instance decidableExistsLT {P : ℕ → Prop} [h : DecidablePred P] :
    DecidablePred fun n => ∃ m : ℕ, m < n ∧ P m
  | 0 => isFalse (by simp)
  | n + 1 =>
    decidable_of_decidable_of_iff (@Or.decidable _ _ (decidable_exists_lt n) (h n))
      (by simp only [lt_succ_iff_lt_or_eq, or_and_right, exists_or, exists_eq_left])
#align nat.decidable_exists_lt Nat.decidableExistsLT
-/

#print Nat.decidableExistsLE /-
instance decidableExistsLE {P : ℕ → Prop} [h : DecidablePred P] :
    DecidablePred fun n => ∃ m : ℕ, m ≤ n ∧ P m := fun n =>
  decidable_of_iff (∃ m, m < n + 1 ∧ P m) (exists_congr fun x => and_congr_left' lt_succ_iff)
#align nat.decidable_exists_le Nat.decidableExistsLE
-/

end Nat

