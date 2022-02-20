/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro, Johannes Hölzl, Damiano Testa
-/
import Mathbin.Algebra.CovariantAndContravariant
import Mathbin.Order.Monotone

/-!
# Ordered monoids

This file develops the basics of ordered monoids.

## Implementation details

Unfortunately, the number of `'` appended to lemmas in this file
may differ between the multiplicative and the additive version of a lemma.
The reason is that we did not want to change existing names in the library.

## Remark

Almost no monoid is actually present in this file: most assumptions have been generalized to
`has_mul` or `mul_one_class`.

-/


-- TODO: If possible, uniformize lemma names, taking special care of `'`,
-- after the `ordered`-refactor is done.
open Function

variable {α β : Type _}

section Mul

variable [Mul α]

section LE

variable [LE α]

/- The prime on this lemma is present only on the multiplicative version.  The unprimed version
is taken by the analogous lemma for semiring, with an extra non-negativity assumption. -/
@[to_additive add_le_add_left]
theorem mul_le_mul_left' [CovariantClass α α (· * ·) (· ≤ ·)] {b c : α} (bc : b ≤ c) (a : α) : a * b ≤ a * c :=
  CovariantClass.elim _ bc

@[to_additive le_of_add_le_add_left]
theorem le_of_mul_le_mul_left' [ContravariantClass α α (· * ·) (· ≤ ·)] {a b c : α} (bc : a * b ≤ a * c) : b ≤ c :=
  ContravariantClass.elim _ bc

/- The prime on this lemma is present only on the multiplicative version.  The unprimed version
is taken by the analogous lemma for semiring, with an extra non-negativity assumption. -/
@[to_additive add_le_add_right]
theorem mul_le_mul_right' [CovariantClass α α (swap (· * ·)) (· ≤ ·)] {b c : α} (bc : b ≤ c) (a : α) : b * a ≤ c * a :=
  CovariantClass.elim a bc

@[to_additive le_of_add_le_add_right]
theorem le_of_mul_le_mul_right' [ContravariantClass α α (swap (· * ·)) (· ≤ ·)] {a b c : α} (bc : b * a ≤ c * a) :
    b ≤ c :=
  ContravariantClass.elim a bc

@[simp, to_additive]
theorem mul_le_mul_iff_left [CovariantClass α α (· * ·) (· ≤ ·)] [ContravariantClass α α (· * ·) (· ≤ ·)] (a : α)
    {b c : α} : a * b ≤ a * c ↔ b ≤ c :=
  rel_iff_cov α α (· * ·) (· ≤ ·) a

@[simp, to_additive]
theorem mul_le_mul_iff_right [CovariantClass α α (swap (· * ·)) (· ≤ ·)] [ContravariantClass α α (swap (· * ·)) (· ≤ ·)]
    (a : α) {b c : α} : b * a ≤ c * a ↔ b ≤ c :=
  rel_iff_cov α α (swap (· * ·)) (· ≤ ·) a

end LE

section LT

variable [LT α]

@[simp, to_additive]
theorem mul_lt_mul_iff_left [CovariantClass α α (· * ·) (· < ·)] [ContravariantClass α α (· * ·) (· < ·)] (a : α)
    {b c : α} : a * b < a * c ↔ b < c :=
  rel_iff_cov α α (· * ·) (· < ·) a

@[simp, to_additive]
theorem mul_lt_mul_iff_right [CovariantClass α α (swap (· * ·)) (· < ·)] [ContravariantClass α α (swap (· * ·)) (· < ·)]
    (a : α) {b c : α} : b * a < c * a ↔ b < c :=
  rel_iff_cov α α (swap (· * ·)) (· < ·) a

@[to_additive add_lt_add_left]
theorem mul_lt_mul_left' [CovariantClass α α (· * ·) (· < ·)] {b c : α} (bc : b < c) (a : α) : a * b < a * c :=
  CovariantClass.elim _ bc

@[to_additive lt_of_add_lt_add_left]
theorem lt_of_mul_lt_mul_left' [ContravariantClass α α (· * ·) (· < ·)] {a b c : α} (bc : a * b < a * c) : b < c :=
  ContravariantClass.elim _ bc

@[to_additive add_lt_add_right]
theorem mul_lt_mul_right' [CovariantClass α α (swap (· * ·)) (· < ·)] {b c : α} (bc : b < c) (a : α) : b * a < c * a :=
  CovariantClass.elim a bc

@[to_additive lt_of_add_lt_add_right]
theorem lt_of_mul_lt_mul_right' [ContravariantClass α α (swap (· * ·)) (· < ·)] {a b c : α} (bc : b * a < c * a) :
    b < c :=
  ContravariantClass.elim a bc

end LT

end Mul

-- using one
section MulOneClassₓ

variable [MulOneClassₓ α]

section LE

variable [LE α]

@[simp, to_additive le_add_iff_nonneg_right]
theorem le_mul_iff_one_le_right' [CovariantClass α α (· * ·) (· ≤ ·)] [ContravariantClass α α (· * ·) (· ≤ ·)] (a : α)
    {b : α} : a ≤ a * b ↔ 1 ≤ b :=
  Iff.trans
    (by
      rw [mul_oneₓ])
    (mul_le_mul_iff_left a)

@[simp, to_additive add_le_iff_nonpos_right]
theorem mul_le_iff_le_one_right' [CovariantClass α α (· * ·) (· ≤ ·)] [ContravariantClass α α (· * ·) (· ≤ ·)] (a : α)
    {b : α} : a * b ≤ a ↔ b ≤ 1 :=
  Iff.trans
    (by
      rw [mul_oneₓ])
    (mul_le_mul_iff_left a)

@[simp, to_additive le_add_iff_nonneg_left]
theorem le_mul_iff_one_le_left' [CovariantClass α α (swap (· * ·)) (· ≤ ·)]
    [ContravariantClass α α (swap (· * ·)) (· ≤ ·)] (a : α) {b : α} : a ≤ b * a ↔ 1 ≤ b :=
  Iff.trans
    (by
      rw [one_mulₓ])
    (mul_le_mul_iff_right a)

@[simp, to_additive add_le_iff_nonpos_left]
theorem mul_le_iff_le_one_left' [CovariantClass α α (swap (· * ·)) (· ≤ ·)]
    [ContravariantClass α α (swap (· * ·)) (· ≤ ·)] {a b : α} : a * b ≤ b ↔ a ≤ 1 :=
  Iff.trans
    (by
      rw [one_mulₓ])
    (mul_le_mul_iff_right b)

end LE

theorem exists_square_le {α : Type _} [MulOneClassₓ α] [LinearOrderₓ α] [CovariantClass α α (· * ·) (· < ·)] (a : α) :
    ∃ b : α, b * b ≤ a := by
  by_cases' h : a < 1
  · use a
    have : a * a < a * 1 := mul_lt_mul_left' h a
    rw [mul_oneₓ] at this
    exact le_of_ltₓ this
    
  · use 1
    push_neg  at h
    rwa [mul_oneₓ]
    

section LT

variable [LT α]

@[to_additive lt_add_of_pos_right]
theorem lt_mul_of_one_lt_right' [CovariantClass α α (· * ·) (· < ·)] (a : α) {b : α} (h : 1 < b) : a < a * b :=
  calc
    a = a * 1 := (mul_oneₓ _).symm
    _ < a * b := mul_lt_mul_left' h a
    

@[simp, to_additive lt_add_iff_pos_right]
theorem lt_mul_iff_one_lt_right' [CovariantClass α α (· * ·) (· < ·)] [ContravariantClass α α (· * ·) (· < ·)] (a : α)
    {b : α} : a < a * b ↔ 1 < b :=
  Iff.trans
    (by
      rw [mul_oneₓ])
    (mul_lt_mul_iff_left a)

@[simp, to_additive add_lt_iff_neg_left]
theorem mul_lt_iff_lt_one_left' [CovariantClass α α (· * ·) (· < ·)] [ContravariantClass α α (· * ·) (· < ·)]
    {a b : α} : a * b < a ↔ b < 1 :=
  Iff.trans
    (by
      rw [mul_oneₓ])
    (mul_lt_mul_iff_left a)

@[simp, to_additive lt_add_iff_pos_left]
theorem lt_mul_iff_one_lt_left' [CovariantClass α α (swap (· * ·)) (· < ·)]
    [ContravariantClass α α (swap (· * ·)) (· < ·)] (a : α) {b : α} : a < b * a ↔ 1 < b :=
  Iff.trans
    (by
      rw [one_mulₓ])
    (mul_lt_mul_iff_right a)

@[simp, to_additive add_lt_iff_neg_right]
theorem mul_lt_iff_lt_one_right' [CovariantClass α α (swap (· * ·)) (· < ·)]
    [ContravariantClass α α (swap (· * ·)) (· < ·)] {a : α} (b : α) : a * b < b ↔ a < 1 :=
  Iff.trans
    (by
      rw [one_mulₓ])
    (mul_lt_mul_iff_right b)

end LT

section Preorderₓ

variable [Preorderₓ α]

@[to_additive]
theorem mul_le_of_le_of_le_one [CovariantClass α α (· * ·) (· ≤ ·)] {a b c : α} (hbc : b ≤ c) (ha : a ≤ 1) :
    b * a ≤ c :=
  calc
    b * a ≤ b * 1 := mul_le_mul_left' ha b
    _ = b := mul_oneₓ b
    _ ≤ c := hbc
    

alias mul_le_of_le_of_le_one ← mul_le_one'

attribute [to_additive add_nonpos] mul_le_one'

@[to_additive]
theorem lt_mul_of_lt_of_one_le [CovariantClass α α (· * ·) (· ≤ ·)] {a b c : α} (hbc : b < c) (ha : 1 ≤ a) :
    b < c * a :=
  calc
    b < c := hbc
    _ = c * 1 := (mul_oneₓ c).symm
    _ ≤ c * a := mul_le_mul_left' ha c
    

@[to_additive]
theorem mul_lt_of_lt_of_le_one [CovariantClass α α (· * ·) (· ≤ ·)] {a b c : α} (hbc : b < c) (ha : a ≤ 1) :
    b * a < c :=
  calc
    b * a ≤ b * 1 := mul_le_mul_left' ha b
    _ = b := mul_oneₓ b
    _ < c := hbc
    

@[to_additive]
theorem lt_mul_of_le_of_one_lt [CovariantClass α α (· * ·) (· < ·)] {a b c : α} (hbc : b ≤ c) (ha : 1 < a) :
    b < c * a :=
  calc
    b ≤ c := hbc
    _ = c * 1 := (mul_oneₓ c).symm
    _ < c * a := mul_lt_mul_left' ha c
    

@[to_additive]
theorem mul_lt_of_le_one_of_lt [CovariantClass α α (swap (· * ·)) (· ≤ ·)] {a b c : α} (ha : a ≤ 1) (hb : b < c) :
    a * b < c :=
  calc
    a * b ≤ 1 * b := mul_le_mul_right' ha b
    _ = b := one_mulₓ b
    _ < c := hb
    

@[to_additive]
theorem mul_le_of_le_one_of_le [CovariantClass α α (swap (· * ·)) (· ≤ ·)] {a b c : α} (ha : a ≤ 1) (hbc : b ≤ c) :
    a * b ≤ c :=
  calc
    a * b ≤ 1 * b := mul_le_mul_right' ha b
    _ = b := one_mulₓ b
    _ ≤ c := hbc
    

@[to_additive]
theorem le_mul_of_one_le_of_le [CovariantClass α α (swap (· * ·)) (· ≤ ·)] {a b c : α} (ha : 1 ≤ a) (hbc : b ≤ c) :
    b ≤ a * c :=
  calc
    b ≤ c := hbc
    _ = 1 * c := (one_mulₓ c).symm
    _ ≤ a * c := mul_le_mul_right' ha c
    

/-- Assume monotonicity on the `left`. The lemma assuming `right` is `right.mul_lt_one`. -/
@[to_additive]
theorem Left.mul_lt_one [CovariantClass α α (· * ·) (· < ·)] {a b : α} (ha : a < 1) (hb : b < 1) : a * b < 1 :=
  calc
    a * b < a * 1 := mul_lt_mul_left' hb a
    _ = a := mul_oneₓ a
    _ < 1 := ha
    

/-- Assume monotonicity on the `right`. The lemma assuming `left` is `left.mul_lt_one`. -/
@[to_additive]
theorem Right.mul_lt_one [CovariantClass α α (swap (· * ·)) (· < ·)] {a b : α} (ha : a < 1) (hb : b < 1) : a * b < 1 :=
  calc
    a * b < 1 * b := mul_lt_mul_right' ha b
    _ = b := one_mulₓ b
    _ < 1 := hb
    

@[to_additive]
theorem mul_lt_of_le_of_lt_one [CovariantClass α α (· * ·) (· < ·)] [CovariantClass α α (swap (· * ·)) (· ≤ ·)]
    {a b c : α} (hbc : b ≤ c) (ha : a < 1) : b * a < c :=
  calc
    b * a ≤ c * a := mul_le_mul_right' hbc a
    _ < c * 1 := mul_lt_mul_left' ha c
    _ = c := mul_oneₓ c
    

@[to_additive]
theorem mul_lt_of_lt_one_of_le [CovariantClass α α (swap (· * ·)) (· < ·)] {a b c : α} (ha : a < 1) (hbc : b ≤ c) :
    a * b < c :=
  calc
    a * b < 1 * b := mul_lt_mul_right' ha b
    _ = b := one_mulₓ b
    _ ≤ c := hbc
    

@[to_additive]
theorem lt_mul_of_one_lt_of_le [CovariantClass α α (swap (· * ·)) (· < ·)] {a b c : α} (ha : 1 < a) (hbc : b ≤ c) :
    b < a * c :=
  calc
    b ≤ c := hbc
    _ = 1 * c := (one_mulₓ c).symm
    _ < a * c := mul_lt_mul_right' ha c
    

/-- Assumes left covariance. -/
@[to_additive]
theorem le_mul_of_le_of_le_one [CovariantClass α α (· * ·) (· ≤ ·)] {a b c : α} (ha : c ≤ a) (hb : 1 ≤ b) : c ≤ a * b :=
  calc
    c ≤ a := ha
    _ = a * 1 := (mul_oneₓ a).symm
    _ ≤ a * b := mul_le_mul_left' hb a
    

--  This lemma is present to mimick the name of an existing one.
@[to_additive add_nonneg]
theorem one_le_mul [CovariantClass α α (· * ·) (· ≤ ·)] {a b : α} (ha : 1 ≤ a) (hb : 1 ≤ b) : 1 ≤ a * b :=
  le_mul_of_le_of_le_one ha hb

/-- Assumes left covariance. -/
@[to_additive]
theorem lt_mul_of_lt_of_one_lt [CovariantClass α α (· * ·) (· < ·)] {a b c : α} (ha : c < a) (hb : 1 < b) : c < a * b :=
  calc
    c < a := ha
    _ = a * 1 := (mul_oneₓ _).symm
    _ < a * b := mul_lt_mul_left' hb a
    

/-- Assumes left covariance. -/
@[to_additive]
theorem Left.mul_lt_one_of_lt_of_lt_one [CovariantClass α α (· * ·) (· < ·)] {a b c : α} (ha : a < c) (hb : b < 1) :
    a * b < c :=
  calc
    a * b < a * 1 := mul_lt_mul_left' hb a
    _ = a := mul_oneₓ a
    _ < c := ha
    

/-- Assumes right covariance. -/
@[to_additive]
theorem Right.mul_lt_one_of_lt_of_lt_one [CovariantClass α α (swap (· * ·)) (· < ·)] {a b c : α} (ha : a < 1)
    (hb : b < c) : a * b < c :=
  calc
    a * b < 1 * b := mul_lt_mul_right' ha b
    _ = b := one_mulₓ b
    _ < c := hb
    

/-- Assumes right covariance. -/
@[to_additive Right.add_nonneg]
theorem Right.one_le_mul [CovariantClass α α (swap (· * ·)) (· ≤ ·)] {a b : α} (ha : 1 ≤ a) (hb : 1 ≤ b) : 1 ≤ a * b :=
  calc
    1 ≤ b := hb
    _ = 1 * b := (one_mulₓ b).symm
    _ ≤ a * b := mul_le_mul_right' ha b
    

/-- Assumes right covariance. -/
@[to_additive Right.add_pos]
theorem Right.one_lt_mul [CovariantClass α α (swap (· * ·)) (· < ·)] {b : α} (hb : 1 < b) {a : α} (ha : 1 < a) :
    1 < a * b :=
  calc
    1 < b := hb
    _ = 1 * b := (one_mulₓ _).symm
    _ < a * b := mul_lt_mul_right' ha b
    

end Preorderₓ

@[to_additive le_add_of_nonneg_right]
theorem le_mul_of_one_le_right' [LE α] [CovariantClass α α (· * ·) (· ≤ ·)] {a b : α} (h : 1 ≤ b) : a ≤ a * b :=
  calc
    a = a * 1 := (mul_oneₓ _).symm
    _ ≤ a * b := mul_le_mul_left' h a
    

@[to_additive add_le_of_nonpos_right]
theorem mul_le_of_le_one_right' [LE α] [CovariantClass α α (· * ·) (· ≤ ·)] {a b : α} (h : b ≤ 1) : a * b ≤ a :=
  calc
    a * b ≤ a * 1 := mul_le_mul_left' h a
    _ = a := mul_oneₓ a
    

end MulOneClassₓ

@[to_additive]
theorem mul_left_cancel'' [Semigroupₓ α] [PartialOrderₓ α] [ContravariantClass α α (· * ·) (· ≤ ·)] {a b c : α}
    (h : a * b = a * c) : b = c :=
  (le_of_mul_le_mul_left' h.le).antisymm (le_of_mul_le_mul_left' h.Ge)

@[to_additive]
theorem mul_right_cancel'' [Semigroupₓ α] [PartialOrderₓ α] [ContravariantClass α α (swap (· * ·)) (· ≤ ·)] {a b c : α}
    (h : a * b = c * b) : a = c :=
  le_antisymmₓ (le_of_mul_le_mul_right' h.le) (le_of_mul_le_mul_right' h.Ge)

/-- A semigroup with a partial order and satisfying `left_cancel_semigroup`
(i.e. `a * c < b * c → a < b`) is a `left_cancel semigroup`. -/
/- This is not instance, since we want to have an instance from `left_cancel_semigroup`s
to the appropriate `covariant_class`. -/
@[to_additive
      "An additive semigroup with a partial order and satisfying `left_cancel_add_semigroup`\n(i.e. `c + a < c + b → a < b`) is a `left_cancel add_semigroup`."]
def Contravariant.toLeftCancelSemigroup [Semigroupₓ α] [PartialOrderₓ α] [ContravariantClass α α (· * ·) (· ≤ ·)] :
    LeftCancelSemigroup α :=
  { ‹Semigroupₓ α› with mul_left_cancel := fun a b c => mul_left_cancel'' }

/-- A semigroup with a partial order and satisfying `right_cancel_semigroup`
(i.e. `a * c < b * c → a < b`) is a `right_cancel semigroup`. -/
/- This is not instance, since we want to have an instance from `right_cancel_semigroup`s
to the appropriate `covariant_class`. -/
@[to_additive
      "An additive semigroup with a partial order and satisfying `right_cancel_add_semigroup`\n(`a + c < b + c → a < b`) is a `right_cancel add_semigroup`."]
def Contravariant.toRightCancelSemigroup [Semigroupₓ α] [PartialOrderₓ α]
    [ContravariantClass α α (swap (· * ·)) (· ≤ ·)] : RightCancelSemigroup α :=
  { ‹Semigroupₓ α› with mul_right_cancel := fun a b c => mul_right_cancel'' }

variable {a b c d : α}

section Left

variable [Preorderₓ α]

section Mul

variable [Mul α]

@[to_additive]
theorem mul_lt_mul_of_lt_of_lt [CovariantClass α α (· * ·) (· < ·)] [CovariantClass α α (swap (· * ·)) (· < ·)]
    (h₁ : a < b) (h₂ : c < d) : a * c < b * d :=
  calc
    a * c < a * d := mul_lt_mul_left' h₂ a
    _ < b * d := mul_lt_mul_right' h₁ d
    

section ContravariantMulLtLeftLeRight

variable [CovariantClass α α (· * ·) (· < ·)] [CovariantClass α α (swap (· * ·)) (· ≤ ·)]

@[to_additive]
theorem mul_lt_mul_of_le_of_lt (h₁ : a ≤ b) (h₂ : c < d) : a * c < b * d :=
  (mul_le_mul_right' h₁ _).trans_lt (mul_lt_mul_left' h₂ b)

@[to_additive add_lt_add]
theorem mul_lt_mul''' (h₁ : a < b) (h₂ : c < d) : a * c < b * d :=
  mul_lt_mul_of_le_of_lt h₁.le h₂

end ContravariantMulLtLeftLeRight

@[to_additive]
theorem mul_eq_mul_iff_eq_and_eq {α : Type _} [Semigroupₓ α] [PartialOrderₓ α] [ContravariantClass α α (· * ·) (· ≤ ·)]
    [CovariantClass α α (swap (· * ·)) (· ≤ ·)] [CovariantClass α α (· * ·) (· < ·)]
    [ContravariantClass α α (swap (· * ·)) (· ≤ ·)] {a b c d : α} (hac : a ≤ c) (hbd : b ≤ d) :
    a * b = c * d ↔ a = c ∧ b = d := by
  refine' ⟨fun h => _, fun h => congr_arg2ₓ (· * ·) h.1 h.2⟩
  rcases hac.eq_or_lt with (rfl | hac)
  · exact ⟨rfl, mul_left_cancel'' h⟩
    
  rcases eq_or_lt_of_le hbd with (rfl | hbd)
  · exact ⟨mul_right_cancel'' h, rfl⟩
    
  exact ((mul_lt_mul''' hac hbd).Ne h).elim

variable [CovariantClass α α (· * ·) (· ≤ ·)]

@[to_additive]
theorem mul_lt_of_mul_lt_left (h : a * b < c) (hle : d ≤ b) : a * d < c :=
  (mul_le_mul_left' hle a).trans_lt h

@[to_additive]
theorem mul_le_of_mul_le_left (h : a * b ≤ c) (hle : d ≤ b) : a * d ≤ c :=
  @act_rel_of_rel_of_act_rel _ _ _ (· ≤ ·) _ ⟨fun _ _ _ => le_transₓ⟩ a _ _ _ hle h

@[to_additive]
theorem lt_mul_of_lt_mul_left (h : a < b * c) (hle : c ≤ d) : a < b * d :=
  h.trans_le (mul_le_mul_left' hle b)

@[to_additive]
theorem le_mul_of_le_mul_left (h : a ≤ b * c) (hle : c ≤ d) : a ≤ b * d :=
  @rel_act_of_rel_of_rel_act _ _ _ (· ≤ ·) _ ⟨fun _ _ _ => le_transₓ⟩ b _ _ _ hle h

@[to_additive]
theorem mul_lt_mul_of_lt_of_le [CovariantClass α α (swap (· * ·)) (· < ·)] (h₁ : a < b) (h₂ : c ≤ d) : a * c < b * d :=
  (mul_le_mul_left' h₂ _).trans_lt (mul_lt_mul_right' h₁ d)

end Mul

/-!  Here we start using properties of one, on the left. -/


section MulOneClassₓ

variable [MulOneClassₓ α] [CovariantClass α α (· * ·) (· ≤ ·)]

@[to_additive]
theorem lt_of_mul_lt_of_one_le_left (h : a * b < c) (hle : 1 ≤ b) : a < c :=
  (le_mul_of_one_le_right' hle).trans_lt h

@[to_additive]
theorem le_of_mul_le_of_one_le_left (h : a * b ≤ c) (hle : 1 ≤ b) : a ≤ c :=
  (le_mul_of_one_le_right' hle).trans h

@[to_additive]
theorem lt_of_lt_mul_of_le_one_left (h : a < b * c) (hle : c ≤ 1) : a < b :=
  h.trans_le (mul_le_of_le_one_right' hle)

@[to_additive]
theorem le_of_le_mul_of_le_one_left (h : a ≤ b * c) (hle : c ≤ 1) : a ≤ b :=
  h.trans (mul_le_of_le_one_right' hle)

@[to_additive]
theorem mul_lt_of_lt_of_lt_one (bc : b < c) (a1 : a < 1) : b * a < c :=
  calc
    b * a ≤ b * 1 := mul_le_mul_left' a1.le _
    _ = b := mul_oneₓ b
    _ < c := bc
    

end MulOneClassₓ

end Left

section Right

section Preorderₓ

variable [Preorderₓ α]

section Mul

variable [Mul α]

variable [CovariantClass α α (swap (· * ·)) (· ≤ ·)]

@[to_additive]
theorem mul_lt_of_mul_lt_right (h : a * b < c) (hle : d ≤ a) : d * b < c :=
  (mul_le_mul_right' hle b).trans_lt h

@[to_additive]
theorem mul_le_of_mul_le_right (h : a * b ≤ c) (hle : d ≤ a) : d * b ≤ c :=
  (mul_le_mul_right' hle b).trans h

@[to_additive]
theorem lt_mul_of_lt_mul_right (h : a < b * c) (hle : b ≤ d) : a < d * c :=
  h.trans_le (mul_le_mul_right' hle c)

@[to_additive]
theorem le_mul_of_le_mul_right (h : a ≤ b * c) (hle : b ≤ d) : a ≤ d * c :=
  h.trans (mul_le_mul_right' hle c)

variable [CovariantClass α α (· * ·) (· ≤ ·)]

@[to_additive add_le_add]
theorem mul_le_mul' (h₁ : a ≤ b) (h₂ : c ≤ d) : a * c ≤ b * d :=
  (mul_le_mul_left' h₂ _).trans (mul_le_mul_right' h₁ d)

@[to_additive]
theorem mul_le_mul_three {e f : α} (h₁ : a ≤ d) (h₂ : b ≤ e) (h₃ : c ≤ f) : a * b * c ≤ d * e * f :=
  mul_le_mul' (mul_le_mul' h₁ h₂) h₃

end Mul

/-!  Here we start using properties of one, on the right. -/


section MulOneClassₓ

variable [MulOneClassₓ α]

section LeRight

variable [CovariantClass α α (swap (· * ·)) (· ≤ ·)]

@[to_additive le_add_of_nonneg_left]
theorem le_mul_of_one_le_left' (h : 1 ≤ b) : a ≤ b * a :=
  calc
    a = 1 * a := (one_mulₓ a).symm
    _ ≤ b * a := mul_le_mul_right' h a
    

@[to_additive add_le_of_nonpos_left]
theorem mul_le_of_le_one_left' (h : b ≤ 1) : b * a ≤ a :=
  calc
    b * a ≤ 1 * a := mul_le_mul_right' h a
    _ = a := one_mulₓ a
    

@[to_additive]
theorem lt_of_mul_lt_of_one_le_right (h : a * b < c) (hle : 1 ≤ a) : b < c :=
  (le_mul_of_one_le_left' hle).trans_lt h

@[to_additive]
theorem le_of_mul_le_of_one_le_right (h : a * b ≤ c) (hle : 1 ≤ a) : b ≤ c :=
  (le_mul_of_one_le_left' hle).trans h

@[to_additive]
theorem lt_of_lt_mul_of_le_one_right (h : a < b * c) (hle : b ≤ 1) : a < c :=
  h.trans_le (mul_le_of_le_one_left' hle)

@[to_additive]
theorem le_of_le_mul_of_le_one_right (h : a ≤ b * c) (hle : b ≤ 1) : a ≤ c :=
  h.trans (mul_le_of_le_one_left' hle)

theorem mul_lt_of_lt_one_of_lt (a1 : a < 1) (bc : b < c) : a * b < c :=
  calc
    a * b ≤ 1 * b := mul_le_mul_right' a1.le _
    _ = b := one_mulₓ b
    _ < c := bc
    

end LeRight

section LtRight

@[to_additive lt_add_of_pos_left]
theorem lt_mul_of_one_lt_left' [CovariantClass α α (swap (· * ·)) (· < ·)] (a : α) {b : α} (h : 1 < b) : a < b * a :=
  calc
    a = 1 * a := (one_mulₓ _).symm
    _ < b * a := mul_lt_mul_right' h a
    

end LtRight

end MulOneClassₓ

end Preorderₓ

end Right

section Preorderₓ

variable [Preorderₓ α]

section MulOneClassₓ

variable [MulOneClassₓ α]

section CovariantLeft

variable [CovariantClass α α (· * ·) (· ≤ ·)]

@[to_additive add_pos_of_pos_of_nonneg]
theorem one_lt_mul_of_lt_of_le' (ha : 1 < a) (hb : 1 ≤ b) : 1 < a * b :=
  lt_of_lt_of_leₓ ha <| le_mul_of_one_le_right' hb

@[to_additive add_pos]
theorem one_lt_mul' (ha : 1 < a) (hb : 1 < b) : 1 < a * b :=
  one_lt_mul_of_lt_of_le' ha hb.le

@[to_additive]
theorem lt_mul_of_lt_of_one_le' (hbc : b < c) (ha : 1 ≤ a) : b < c * a :=
  hbc.trans_le <| le_mul_of_one_le_right' ha

@[to_additive]
theorem lt_mul_of_lt_of_one_lt' (hbc : b < c) (ha : 1 < a) : b < c * a :=
  lt_mul_of_lt_of_one_le' hbc ha.le

@[to_additive]
theorem le_mul_of_le_of_one_le (hbc : b ≤ c) (ha : 1 ≤ a) : b ≤ c * a :=
  calc
    b ≤ c := hbc
    _ = c * 1 := (mul_oneₓ c).symm
    _ ≤ c * a := mul_le_mul_left' ha c
    

@[to_additive add_nonneg]
theorem one_le_mul_right (ha : 1 ≤ a) (hb : 1 ≤ b) : 1 ≤ a * b :=
  calc
    1 ≤ a := ha
    _ = a * 1 := (mul_oneₓ a).symm
    _ ≤ a * b := mul_le_mul_left' hb a
    

end CovariantLeft

section CovariantRight

variable [CovariantClass α α (swap (· * ·)) (· ≤ ·)]

@[to_additive add_pos_of_nonneg_of_pos]
theorem one_lt_mul_of_le_of_lt' (ha : 1 ≤ a) (hb : 1 < b) : 1 < a * b :=
  lt_of_lt_of_leₓ hb <| le_mul_of_one_le_left' ha

@[to_additive]
theorem lt_mul_of_one_le_of_lt (ha : 1 ≤ a) (hbc : b < c) : b < a * c :=
  hbc.trans_le <| le_mul_of_one_le_left' ha

@[to_additive]
theorem lt_mul_of_one_lt_of_lt (ha : 1 < a) (hbc : b < c) : b < a * c :=
  lt_mul_of_one_le_of_lt ha.le hbc

end CovariantRight

end MulOneClassₓ

end Preorderₓ

section PartialOrderₓ

/-!  Properties assuming `partial_order`. -/


variable [MulOneClassₓ α] [PartialOrderₓ α] [CovariantClass α α (· * ·) (· ≤ ·)]
  [CovariantClass α α (swap (· * ·)) (· ≤ ·)]

@[to_additive]
theorem mul_eq_one_iff' (ha : 1 ≤ a) (hb : 1 ≤ b) : a * b = 1 ↔ a = 1 ∧ b = 1 :=
  Iff.intro
    (fun hab : a * b = 1 =>
      have : a ≤ 1 := hab ▸ le_mul_of_le_of_one_le le_rfl hb
      have : a = 1 := le_antisymmₓ this ha
      have : b ≤ 1 := hab ▸ le_mul_of_one_le_of_le ha le_rfl
      have : b = 1 := le_antisymmₓ this hb
      And.intro ‹a = 1› ‹b = 1›)
    fun ⟨ha', hb'⟩ => by
    rw [ha', hb', mul_oneₓ]

end PartialOrderₓ

section Mono

variable [Mul α] [Preorderₓ α] [Preorderₓ β] {f g : β → α}

@[to_additive Monotone.const_add]
theorem Monotone.const_mul' [CovariantClass α α (· * ·) (· ≤ ·)] (hf : Monotone f) (a : α) :
    Monotone fun x => a * f x := fun x y h => mul_le_mul_left' (hf h) a

@[to_additive Monotone.add_const]
theorem Monotone.mul_const' [CovariantClass α α (swap (· * ·)) (· ≤ ·)] (hf : Monotone f) (a : α) :
    Monotone fun x => f x * a := fun x y h => mul_le_mul_right' (hf h) a

/-- The product of two monotone functions is monotone. -/
@[to_additive Monotone.add "The sum of two monotone functions is monotone."]
theorem Monotone.mul' [CovariantClass α α (· * ·) (· ≤ ·)] [CovariantClass α α (swap (· * ·)) (· ≤ ·)] (hf : Monotone f)
    (hg : Monotone g) : Monotone fun x => f x * g x := fun x y h => mul_le_mul' (hf h) (hg h)

section Left

variable [CovariantClass α α (· * ·) (· < ·)]

@[to_additive StrictMono.const_add]
theorem StrictMono.const_mul' (hf : StrictMono f) (c : α) : StrictMono fun x => c * f x := fun a b ab =>
  mul_lt_mul_left' (hf ab) c

end Left

section Right

variable [CovariantClass α α (swap (· * ·)) (· < ·)]

@[to_additive StrictMono.add_const]
theorem StrictMono.mul_const' (hf : StrictMono f) (c : α) : StrictMono fun x => f x * c := fun a b ab =>
  mul_lt_mul_right' (hf ab) c

end Right

/-- The product of two strictly monotone functions is strictly monotone. -/
@[to_additive StrictMono.add "The sum of two strictly monotone functions is strictly monotone."]
theorem StrictMono.mul' [CovariantClass α α (· * ·) (· < ·)] [CovariantClass α α (swap (· * ·)) (· < ·)]
    (hf : StrictMono f) (hg : StrictMono g) : StrictMono fun x => f x * g x := fun a b ab =>
  mul_lt_mul_of_lt_of_lt (hf ab) (hg ab)

/-- The product of a monotone function and a strictly monotone function is strictly monotone. -/
@[to_additive Monotone.add_strict_mono
      "The sum of a monotone function and a strictly monotone function is strictly monotone."]
theorem Monotone.mul_strict_mono' [CovariantClass α α (· * ·) (· < ·)] [CovariantClass α α (swap (· * ·)) (· ≤ ·)]
    {f g : β → α} (hf : Monotone f) (hg : StrictMono g) : StrictMono fun x => f x * g x := fun x y h =>
  mul_lt_mul_of_le_of_lt (hf h.le) (hg h)

variable [CovariantClass α α (· * ·) (· ≤ ·)] [CovariantClass α α (swap (· * ·)) (· < ·)]

/-- The product of a strictly monotone function and a monotone function is strictly monotone. -/
@[to_additive StrictMono.add_monotone
      "The sum of a strictly monotone function and a monotone function is strictly monotone."]
theorem StrictMono.mul_monotone' (hf : StrictMono f) (hg : Monotone g) : StrictMono fun x => f x * g x := fun x y h =>
  mul_lt_mul_of_lt_of_le (hf h) (hg h.le)

end Mono

/-- An element `a : α` is `mul_le_cancellable` if `x ↦ a * x` is order-reflecting.
We will make a separate version of many lemmas that require `[contravariant_class α α (*) (≤)]` with
`mul_le_cancellable` assumptions instead. These lemmas can then be instantiated to specific types,
like `ennreal`, where we can replace the assumption `add_le_cancellable x` by `x ≠ ∞`.
-/
@[to_additive
      " An element `a : α` is `add_le_cancellable` if `x ↦ a + x` is order-reflecting.\nWe will make a separate version of many lemmas that require `[contravariant_class α α (+) (≤)]` with\n`mul_le_cancellable` assumptions instead. These lemmas can then be instantiated to specific types,\nlike `ennreal`, where we can replace the assumption `add_le_cancellable x` by `x ≠ ∞`. "]
def MulLeCancellable [Mul α] [LE α] (a : α) : Prop :=
  ∀ ⦃b c⦄, a * b ≤ a * c → b ≤ c

@[to_additive]
theorem Contravariant.mul_le_cancellable [Mul α] [LE α] [ContravariantClass α α (· * ·) (· ≤ ·)] {a : α} :
    MulLeCancellable a := fun b c => le_of_mul_le_mul_left'

namespace MulLeCancellable

@[to_additive]
protected theorem injective [Mul α] [PartialOrderₓ α] {a : α} (ha : MulLeCancellable a) : Injective ((· * ·) a) :=
  fun b c h => le_antisymmₓ (ha h.le) (ha h.Ge)

@[to_additive]
protected theorem inj [Mul α] [PartialOrderₓ α] {a b c : α} (ha : MulLeCancellable a) : a * b = a * c ↔ b = c :=
  ha.Injective.eq_iff

@[to_additive]
protected theorem injective_left [CommSemigroupₓ α] [PartialOrderₓ α] {a : α} (ha : MulLeCancellable a) :
    Injective (· * a) := fun b c h =>
  ha.Injective <| by
    rwa [mul_comm a, mul_comm a]

@[to_additive]
protected theorem inj_left [CommSemigroupₓ α] [PartialOrderₓ α] {a b c : α} (hc : MulLeCancellable c) :
    a * c = b * c ↔ a = b :=
  hc.injective_left.eq_iff

variable [LE α]

@[to_additive]
protected theorem mul_le_mul_iff_left [Mul α] [CovariantClass α α (· * ·) (· ≤ ·)] {a b c : α}
    (ha : MulLeCancellable a) : a * b ≤ a * c ↔ b ≤ c :=
  ⟨fun h => ha h, fun h => mul_le_mul_left' h a⟩

@[to_additive]
protected theorem mul_le_mul_iff_right [CommSemigroupₓ α] [CovariantClass α α (· * ·) (· ≤ ·)] {a b c : α}
    (ha : MulLeCancellable a) : b * a ≤ c * a ↔ b ≤ c := by
  rw [mul_comm b, mul_comm c, ha.mul_le_mul_iff_left]

@[to_additive]
protected theorem le_mul_iff_one_le_right [MulOneClassₓ α] [CovariantClass α α (· * ·) (· ≤ ·)] {a b : α}
    (ha : MulLeCancellable a) : a ≤ a * b ↔ 1 ≤ b :=
  Iff.trans
    (by
      rw [mul_oneₓ])
    ha.mul_le_mul_iff_left

@[to_additive]
protected theorem mul_le_iff_le_one_right [MulOneClassₓ α] [CovariantClass α α (· * ·) (· ≤ ·)] {a b : α}
    (ha : MulLeCancellable a) : a * b ≤ a ↔ b ≤ 1 :=
  Iff.trans
    (by
      rw [mul_oneₓ])
    ha.mul_le_mul_iff_left

@[to_additive]
protected theorem le_mul_iff_one_le_left [CommMonoidₓ α] [CovariantClass α α (· * ·) (· ≤ ·)] {a b : α}
    (ha : MulLeCancellable a) : a ≤ b * a ↔ 1 ≤ b := by
  rw [mul_comm, ha.le_mul_iff_one_le_right]

@[to_additive]
protected theorem mul_le_iff_le_one_left [CommMonoidₓ α] [CovariantClass α α (· * ·) (· ≤ ·)] {a b : α}
    (ha : MulLeCancellable a) : b * a ≤ a ↔ b ≤ 1 := by
  rw [mul_comm, ha.mul_le_iff_le_one_right]

end MulLeCancellable

