/-
Copyright (c) 2021 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module category_theory.preadditive.single_obj
! leanprover-community/mathlib commit 09597669f02422ed388036273d8848119699c22f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Preadditive.Basic
import Mathbin.CategoryTheory.SingleObj

/-!
# `single_obj α` is preadditive when `α` is a ring.

-/


namespace CategoryTheory

variable {α : Type _} [Ring α]

instance : Preadditive (SingleObj α)
    where
  add_comp' _ _ _ f f' g := mul_add g f f'
  comp_add' _ _ _ f g g' := add_mul g g' f

-- TODO define `PreAddCat` (with additive functors as morphisms), and `Ring ⥤ PreAddCat`.
end CategoryTheory

