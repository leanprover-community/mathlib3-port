/-
Copyright (c) 2022 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module category_theory.bicategory.End
! leanprover-community/mathlib commit bd9851ca476957ea4549eb19b40e7b5ade9428cc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Bicategory.Basic
import Mathbin.CategoryTheory.Monoidal.Category

/-!
# Endomorphisms of an object in a bicategory, as a monoidal category.
-/


namespace CategoryTheory

variable {C : Type _} [Bicategory C]

/-- The endomorphisms of an object in a bicategory can be considered as a monoidal category. -/
def EndMonoidal (X : C) :=
  X ⟶ X deriving Category
#align category_theory.End_monoidal CategoryTheory.EndMonoidal

instance (X : C) : Inhabited (EndMonoidal X) :=
  ⟨𝟙 X⟩

open Bicategory

open MonoidalCategory

open Bicategory

instance (X : C) : MonoidalCategory (EndMonoidal X)
    where
  tensorObj f g := f ≫ g
  tensorHom f g h i η θ := η ▷ h ≫ g ◁ θ
  tensorUnit := 𝟙 _
  associator f g h := α_ f g h
  leftUnitor f := λ_ f
  rightUnitor f := ρ_ f
  tensor_comp' := by
    intros
    rw [bicategory.whisker_left_comp, bicategory.comp_whisker_right, category.assoc, category.assoc,
      bicategory.whisker_exchange_assoc]

end CategoryTheory

