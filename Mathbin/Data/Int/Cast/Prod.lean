/-
Copyright (c) 2017 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module data.int.cast.prod
! leanprover-community/mathlib commit aba57d4d3dae35460225919dcd82fe91355162f9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Int.Cast.Lemmas
import Mathbin.Data.Nat.Cast.Prod

/-!
# The product of two `add_group_with_one`s.
-/


namespace Prod

variable {α β : Type _} [AddGroupWithOne α] [AddGroupWithOne β]

instance : AddGroupWithOne (α × β) :=
  { Prod.addMonoidWithOne, Prod.addGroup with
    intCast := fun n => (n, n)
    int_cast_of_nat := fun _ => by simp <;> rfl
    int_cast_neg_succ_of_nat := fun _ => by simp <;> rfl }

@[simp]
theorem fst_int_cast (n : ℤ) : (n : α × β).fst = n :=
  rfl
#align prod.fst_int_cast Prod.fst_int_cast

@[simp]
theorem snd_int_cast (n : ℤ) : (n : α × β).snd = n :=
  rfl
#align prod.snd_int_cast Prod.snd_int_cast

end Prod

