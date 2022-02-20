/-
Copyright (c) 2019 Scott Morrison, Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison, Bhavik Mehta
-/
import Mathbin.CategoryTheory.FunctorCategory
import Mathbin.CategoryTheory.Isomorphism

/-!
# Thin categories

A thin category (also known as a sparse category) is a category with at most one morphism between
each pair of objects.

Examples include posets, but also some indexing categories (diagrams) for special shapes of
(co)limits.

To construct a category instance one only needs to specify the `category_struct` part,
as the axioms hold for free.

If `C` is thin, then the category of functors to `C` is also thin.
Further, to show two objects are isomorphic in a thin category, it suffices only to give a morphism
in each direction.
-/


universe v₁ v₂ u₁ u₂

namespace CategoryTheory

variable {C : Type u₁}

section

variable [CategoryStruct.{v₁} C] [∀ X Y : C, Subsingleton (X ⟶ Y)]

/-- Construct a category instance from a category_struct, using the fact that
    hom spaces are subsingletons to prove the axioms. -/
def thinCategory : Category C :=
  {  }

end

-- We don't assume anything about where the category instance on `C` came from.
-- In particular this allows `C` to be a preorder, with the category instance inherited from the
-- preorder structure.
variable [Category.{v₁} C] {D : Type u₂} [Category.{v₂} D]

variable [∀ X Y : C, Subsingleton (X ⟶ Y)]

/-- If `C` is a thin category, then `D ⥤ C` is a thin category. -/
instance functor_thin (F₁ F₂ : D ⥤ C) : Subsingleton (F₁ ⟶ F₂) :=
  ⟨fun α β => NatTrans.ext α β (funext fun _ => Subsingleton.elimₓ _ _)⟩

/-- To show `X ≅ Y` in a thin category, it suffices to just give any morphism in each direction. -/
def isoOfBothWays {X Y : C} (f : X ⟶ Y) (g : Y ⟶ X) : X ≅ Y where
  Hom := f
  inv := g

instance subsingleton_iso {X Y : C} : Subsingleton (X ≅ Y) :=
  ⟨by
    intro i₁ i₂
    ext1
    apply Subsingleton.elimₓ⟩

end CategoryTheory

