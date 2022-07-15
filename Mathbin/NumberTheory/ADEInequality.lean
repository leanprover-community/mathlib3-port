/-
Copyright (c) 2021 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin
-/
import Mathbin.Data.Multiset.Sort
import Mathbin.Data.Pnat.Interval
import Mathbin.Data.Rat.Order
import Mathbin.Tactic.NormNum
import Mathbin.Tactic.FieldSimp
import Mathbin.Tactic.IntervalCases

/-!
# The inequality `p⁻¹ + q⁻¹ + r⁻¹ > 1`

In this file we classify solutions to the inequality
`(p⁻¹ + q⁻¹ + r⁻¹ : ℚ) > 1`, for positive natural numbers `p`, `q`, and `r`.

The solutions are exactly of the form.
* `A' q r := {1,q,r}`
* `D' r := {2,2,r}`
* `E6 := {2,3,3}`, or `E7 := {2,3,4}`, or `E8 := {2,3,5}`

This inequality shows up in Lie theory,
in the classification of Dynkin diagrams, root systems, and semisimple Lie algebras.

## Main declarations

* `pqr.A' q r`, the multiset `{1,q,r}`
* `pqr.D' r`, the multiset `{2,2,r}`
* `pqr.E6`, the multiset `{2,3,3}`
* `pqr.E7`, the multiset `{2,3,4}`
* `pqr.E8`, the multiset `{2,3,5}`
* `pqr.classification`, the classification of solutions to `p⁻¹ + q⁻¹ + r⁻¹ > 1`

-/


namespace ADEInequality

open Multiset

/-- `A' q r := {1,q,r}` is a `multiset ℕ+`
that is a solution to the inequality
`(p⁻¹ + q⁻¹ + r⁻¹ : ℚ) > 1`. -/
def a' (q r : ℕ+) : Multiset ℕ+ :=
  {1, q, r}

/-- `A r := {1,1,r}` is a `multiset ℕ+`
that is a solution to the inequality
`(p⁻¹ + q⁻¹ + r⁻¹ : ℚ) > 1`.

These solutions are related to the Dynkin diagrams $A_r$. -/
def a (r : ℕ+) : Multiset ℕ+ :=
  a' 1 r

/-- `D' r := {2,2,r}` is a `multiset ℕ+`
that is a solution to the inequality
`(p⁻¹ + q⁻¹ + r⁻¹ : ℚ) > 1`.

These solutions are related to the Dynkin diagrams $D_{r+2}$. -/
def d' (r : ℕ+) : Multiset ℕ+ :=
  {2, 2, r}

/-- `E' r := {2,3,r}` is a `multiset ℕ+`.
For `r ∈ {3,4,5}` is a solution to the inequality
`(p⁻¹ + q⁻¹ + r⁻¹ : ℚ) > 1`.

These solutions are related to the Dynkin diagrams $E_{r+3}$. -/
def e' (r : ℕ+) : Multiset ℕ+ :=
  {2, 3, r}

/-- `E6 := {2,3,3}` is a `multiset ℕ+`
that is a solution to the inequality
`(p⁻¹ + q⁻¹ + r⁻¹ : ℚ) > 1`.

This solution is related to the Dynkin diagrams $E_6$. -/
def e6 : Multiset ℕ+ :=
  e' 3

/-- `E7 := {2,3,4}` is a `multiset ℕ+`
that is a solution to the inequality
`(p⁻¹ + q⁻¹ + r⁻¹ : ℚ) > 1`.

This solution is related to the Dynkin diagrams $E_7$. -/
def e7 : Multiset ℕ+ :=
  e' 4

/-- `E8 := {2,3,5}` is a `multiset ℕ+`
that is a solution to the inequality
`(p⁻¹ + q⁻¹ + r⁻¹ : ℚ) > 1`.

This solution is related to the Dynkin diagrams $E_8$. -/
def e8 : Multiset ℕ+ :=
  e' 5

/-- `sum_inv pqr` for a `pqr : multiset ℕ+` is the sum of the inverses
of the elements of `pqr`, as rational number.

The intended argument is a multiset `{p,q,r}` of cardinality `3`. -/
def sumInv (pqr : Multiset ℕ+) : ℚ :=
  Multiset.sum <| pqr.map fun x => x⁻¹

theorem sum_inv_pqr (p q r : ℕ+) : sumInv {p, q, r} = p⁻¹ + q⁻¹ + r⁻¹ := by
  simp only [← sum_inv, ← coe_coe, ← add_zeroₓ, ← insert_eq_cons, ← add_assocₓ, ← map_cons, ← sum_cons, ← map_singleton,
    ← sum_singleton]

/-- A multiset `pqr` of positive natural numbers is `admissible`
if it is equal to `A' q r`, or `D' r`, or one of `E6`, `E7`, or `E8`. -/
def Admissible (pqr : Multiset ℕ+) : Prop :=
  (∃ q r, a' q r = pqr) ∨ (∃ r, d' r = pqr) ∨ e' 3 = pqr ∨ e' 4 = pqr ∨ e' 5 = pqr

theorem admissible_A' (q r : ℕ+) : Admissible (a' q r) :=
  Or.inl ⟨q, r, rfl⟩

theorem admissible_D' (n : ℕ+) : Admissible (d' n) :=
  Or.inr <| Or.inl ⟨n, rfl⟩

theorem admissible_E'3 : Admissible (e' 3) :=
  Or.inr <| Or.inr <| Or.inl rfl

theorem admissible_E'4 : Admissible (e' 4) :=
  Or.inr <| Or.inr <| Or.inr <| Or.inl rfl

theorem admissible_E'5 : Admissible (e' 5) :=
  Or.inr <| Or.inr <| Or.inr <| Or.inr rfl

theorem admissible_E6 : Admissible e6 :=
  admissible_E'3

theorem admissible_E7 : Admissible e7 :=
  admissible_E'4

theorem admissible_E8 : Admissible e8 :=
  admissible_E'5

theorem Admissible.one_lt_sum_inv {pqr : Multiset ℕ+} : Admissible pqr → 1 < sumInv pqr := by
  rw [admissible]
  rintro (⟨p', q', H⟩ | ⟨n, H⟩ | H | H | H)
  · rw [← H, A', sum_inv_pqr, add_assocₓ]
    simp only [← lt_add_iff_pos_right, ← Pnat.one_coe, ← inv_one, ← Nat.cast_oneₓ, ← coe_coe]
    apply add_pos <;> simp only [← Pnat.pos, ← Nat.cast_pos, ← inv_pos]
    
  · rw [← H, D', sum_inv_pqr]
    simp only [← lt_add_iff_pos_right, ← Pnat.one_coe, ← inv_one, ← Nat.cast_oneₓ, ← coe_coe, ← Pnat.coe_bit0, ←
      Nat.cast_bit0]
    norm_num
    
  all_goals
    rw [← H, E', sum_inv_pqr]
    norm_num

theorem lt_three {p q r : ℕ+} (hpq : p ≤ q) (hqr : q ≤ r) (H : 1 < sumInv {p, q, r}) : p < 3 := by
  have h3 : (0 : ℚ) < 3 := by
    norm_num
  contrapose! H
  rw [sum_inv_pqr]
  have h3q := H.trans hpq
  have h3r := h3q.trans hqr
  calc (p⁻¹ + q⁻¹ + r⁻¹ : ℚ) ≤ 3⁻¹ + 3⁻¹ + 3⁻¹ := add_le_add (add_le_add _ _) _ _ = 1 := by
      norm_num
  all_goals
    rw [inv_le_inv _ h3] <;> [assumption_mod_cast, norm_num]

theorem lt_four {q r : ℕ+} (hqr : q ≤ r) (H : 1 < sumInv {2, q, r}) : q < 4 := by
  have h4 : (0 : ℚ) < 4 := by
    norm_num
  contrapose! H
  rw [sum_inv_pqr]
  have h4r := H.trans hqr
  simp only [← Pnat.coe_bit0, ← Nat.cast_bit0, ← Pnat.one_coe, ← Nat.cast_oneₓ, ← coe_coe]
  calc (2⁻¹ + q⁻¹ + r⁻¹ : ℚ) ≤ 2⁻¹ + 4⁻¹ + 4⁻¹ := add_le_add (add_le_add le_rfl _) _ _ = 1 := by
      norm_num
  all_goals
    rw [inv_le_inv _ h4] <;> [assumption_mod_cast, norm_num]

theorem lt_six {r : ℕ+} (H : 1 < sumInv {2, 3, r}) : r < 6 := by
  have h6 : (0 : ℚ) < 6 := by
    norm_num
  contrapose! H
  rw [sum_inv_pqr]
  simp only [← Pnat.coe_bit0, ← Nat.cast_bit0, ← Pnat.one_coe, ← Nat.cast_bit1, ← Nat.cast_oneₓ, ← Pnat.coe_bit1, ←
    coe_coe]
  calc (2⁻¹ + 3⁻¹ + r⁻¹ : ℚ) ≤ 2⁻¹ + 3⁻¹ + 6⁻¹ := add_le_add (add_le_add le_rfl le_rfl) _ _ = 1 := by
      norm_num
  rw [inv_le_inv _ h6] <;> [assumption_mod_cast, norm_num]

theorem admissible_of_one_lt_sum_inv_aux' {p q r : ℕ+} (hpq : p ≤ q) (hqr : q ≤ r) (H : 1 < sumInv {p, q, r}) :
    Admissible {p, q, r} := by
  have hp3 : p < 3 := lt_three hpq hqr H
  interval_cases p
  · exact admissible_A' q r
    
  have hq4 : q < 4 := lt_four hqr H
  interval_cases q
  · exact admissible_D' r
    
  have hr6 : r < 6 := lt_six H
  interval_cases r
  · exact admissible_E6
    
  · exact admissible_E7
    
  · exact admissible_E8
    

theorem admissible_of_one_lt_sum_inv_aux :
    ∀ {pqr : List ℕ+} hs : pqr.Sorted (· ≤ ·) hl : pqr.length = 3 H : 1 < sumInv pqr, Admissible pqr
  | [p, q, r], hs, hl, H => by
    obtain ⟨⟨hpq, -⟩, hqr⟩ : (p ≤ q ∧ p ≤ r) ∧ q ≤ r
    simpa using hs
    exact admissible_of_one_lt_sum_inv_aux' hpq hqr H

theorem admissible_of_one_lt_sum_inv {p q r : ℕ+} (H : 1 < sumInv {p, q, r}) : Admissible {p, q, r} := by
  simp only [← admissible]
  let S := sort ((· ≤ ·) : ℕ+ → ℕ+ → Prop) {p, q, r}
  have hS : S.sorted (· ≤ ·) := sort_sorted _ _
  have hpqr : ({p, q, r} : Multiset ℕ+) = S := (sort_eq LE.le {p, q, r}).symm
  simp only [← hpqr] at *
  apply admissible_of_one_lt_sum_inv_aux hS _ H
  simp only [← S, ← length_sort]
  decide

/-- A multiset `{p,q,r}` of positive natural numbers
is a solution to `(p⁻¹ + q⁻¹ + r⁻¹ : ℚ) > 1` if and only if
it is `admissible` which means it is one of:

* `A' q r := {1,q,r}`
* `D' r := {2,2,r}`
* `E6 := {2,3,3}`, or `E7 := {2,3,4}`, or `E8 := {2,3,5}`
-/
theorem classification (p q r : ℕ+) : 1 < sumInv {p, q, r} ↔ Admissible {p, q, r} :=
  ⟨admissible_of_one_lt_sum_inv, Admissible.one_lt_sum_inv⟩

end ADEInequality

