/-
Copyright (c) 2017 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module data.fintype.array
! leanprover-community/mathlib commit d101e93197bb5f6ea89bd7ba386b7f7dff1f3903
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fintype.Pi
import Mathbin.Logic.Equiv.Array

/-!
# `array n α` is a fintype when `α` is.
-/


variable {α : Type _}

instance DArray.fintype {n : ℕ} {α : Fin n → Type _} [∀ n, Fintype (α n)] : Fintype (DArray n α) :=
  Fintype.ofEquiv _ (Equiv.dArrayEquivFin _).symm
#align d_array.fintype DArray.fintype

instance Array'.fintype {n : ℕ} {α : Type _} [Fintype α] : Fintype (Array' n α) :=
  DArray.fintype
#align array.fintype Array'.fintype

