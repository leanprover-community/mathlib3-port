/-
Copyright (c) 2014 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module data.nat.cast.prod
! leanprover-community/mathlib commit aba57d4d3dae35460225919dcd82fe91355162f9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Cast.Basic
import Mathbin.Algebra.Group.Prod

/-!
# The product of two `add_monoid_with_one`s.
-/


variable {α β : Type _}

namespace Prod

variable [AddMonoidWithOne α] [AddMonoidWithOne β]

instance : AddMonoidWithOne (α × β) :=
  { Prod.addMonoid, Prod.hasOne with 
    natCast := fun n => (n, n)
    nat_cast_zero := congr_arg₂ Prod.mk Nat.cast_zero Nat.cast_zero
    nat_cast_succ := fun n => congr_arg₂ Prod.mk (Nat.cast_succ _) (Nat.cast_succ _) }

@[simp]
theorem fst_nat_cast (n : ℕ) : (n : α × β).fst = n := by induction n <;> simp [*]
#align prod.fst_nat_cast Prod.fst_nat_cast

@[simp]
theorem snd_nat_cast (n : ℕ) : (n : α × β).snd = n := by induction n <;> simp [*]
#align prod.snd_nat_cast Prod.snd_nat_cast

end Prod

