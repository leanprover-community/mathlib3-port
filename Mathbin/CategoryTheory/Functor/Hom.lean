/-
Copyright (c) 2018 Reid Barton. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Reid Barton, Scott Morrison

! This file was ported from Lean 3 source module category_theory.functor.hom
! leanprover-community/mathlib commit b3f25363ae62cb169e72cd6b8b1ac97bacf21ca7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Products.Basic
import Mathbin.CategoryTheory.Types

/-!
The hom functor, sending `(X, Y)` to the type `X ⟶ Y`.
-/


universe v u

open Opposite

open CategoryTheory

namespace CategoryTheory.Functor

variable (C : Type u) [Category.{v} C]

/-- `functor.hom` is the hom-pairing, sending `(X, Y)` to `X ⟶ Y`, contravariant in `X` and
covariant in `Y`. -/
@[simps]
def hom : Cᵒᵖ × C ⥤ Type v where 
  obj p := unop p.1 ⟶ p.2
  map X Y f h := f.1.unop ≫ h ≫ f.2
#align category_theory.functor.hom CategoryTheory.Functor.hom

end CategoryTheory.Functor

