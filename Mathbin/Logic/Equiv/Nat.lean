/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module logic.equiv.nat
! leanprover-community/mathlib commit 0743cc5d9d86bcd1bba10f480e948a257d65056f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Pairing

/-!
# Equivalences involving `ℕ`

This file defines some additional constructive equivalences using `encodable` and the pairing
function on `ℕ`.
-/


open Nat Function

namespace Equiv

variable {α : Type _}

/-- An equivalence between `bool × ℕ` and `ℕ`, by mapping `(tt, x)` to `2 * x + 1` and `(ff, x)` to
`2 * x`.
-/
@[simps]
def boolProdNatEquivNat : Bool × ℕ ≃
      ℕ where 
  toFun := uncurry bit
  invFun := boddDiv2
  left_inv := fun ⟨b, n⟩ => by simp only [bodd_bit, div2_bit, uncurry_apply_pair, bodd_div2_eq]
  right_inv n := by simp only [bit_decomp, bodd_div2_eq, uncurry_apply_pair]
#align equiv.bool_prod_nat_equiv_nat Equiv.boolProdNatEquivNat

/-- An equivalence between `ℕ ⊕ ℕ` and `ℕ`, by mapping `(sum.inl x)` to `2 * x` and `(sum.inr x)` to
`2 * x + 1`.
-/
@[simps symmApply]
def natSumNatEquivNat : Sum ℕ ℕ ≃ ℕ :=
  (boolProdEquivSum ℕ).symm.trans boolProdNatEquivNat
#align equiv.nat_sum_nat_equiv_nat Equiv.natSumNatEquivNat

@[simp]
theorem nat_sum_nat_equiv_nat_apply : ⇑nat_sum_nat_equiv_nat = Sum.elim bit0 bit1 := by
  ext (x | x) <;> rfl
#align equiv.nat_sum_nat_equiv_nat_apply Equiv.nat_sum_nat_equiv_nat_apply

/-- An equivalence between `ℤ` and `ℕ`, through `ℤ ≃ ℕ ⊕ ℕ` and `ℕ ⊕ ℕ ≃ ℕ`.
-/
def intEquivNat : ℤ ≃ ℕ :=
  intEquivNatSumNat.trans natSumNatEquivNat
#align equiv.int_equiv_nat Equiv.intEquivNat

/-- An equivalence between `α × α` and `α`, given that there is an equivalence between `α` and `ℕ`.
-/
def prodEquivOfEquivNat (e : α ≃ ℕ) : α × α ≃ α :=
  calc
    α × α ≃ ℕ × ℕ := prodCongr e e
    _ ≃ ℕ := mkpairEquiv
    _ ≃ α := e.symm
    
#align equiv.prod_equiv_of_equiv_nat Equiv.prodEquivOfEquivNat

end Equiv

