/-
Copyright (c) 2022 Joël Riou. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joël Riou

! This file was ported from Lean 3 source module category_theory.idempotents.simplicial_object
! leanprover-community/mathlib commit 48085f140e684306f9e7da907cd5932056d1aded
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.AlgebraicTopology.SimplicialObject
import Mathbin.CategoryTheory.Idempotents.FunctorCategories

/-!

# Idempotent completeness of categories of simplicial objects

In this file, we provide an instance expressing that `simplicial_object C`
and `cosimplicial_object C` are idempotent complete categories when the
category `C` is.

-/


namespace CategoryTheory

namespace Idempotents

variable {C : Type _} [Category C] [IsIdempotentComplete C]

instance : IsIdempotentComplete (SimplicialObject C) :=
  Idempotents.functor_category_isIdempotentComplete _ _

instance : IsIdempotentComplete (CosimplicialObject C) :=
  Idempotents.functor_category_isIdempotentComplete _ _

end Idempotents

end CategoryTheory

