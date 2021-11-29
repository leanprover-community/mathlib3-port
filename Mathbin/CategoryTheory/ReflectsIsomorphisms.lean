import Mathbin.CategoryTheory.FullyFaithful

/-!
# Functors which reflect isomorphisms

A functor `F` reflects isomorphisms if whenever `F.map f` is an isomorphism, `f` was too.

It is formalized as a `Prop` valued typeclass `reflects_isomorphisms F`.

Any fully faithful functor reflects isomorphisms.
-/


open CategoryTheory

namespace CategoryTheory

universe v₁ v₂ u₁ u₂

variable{C : Type u₁}[category.{v₁} C]

section ReflectsIso

variable{D : Type u₂}[category.{v₂} D]

/--
Define what it means for a functor `F : C ⥤ D` to reflect isomorphisms: for any
morphism `f : A ⟶ B`, if `F.map f` is an isomorphism then `f` is as well.
Note that we do not assume or require that `F` is faithful.
-/
class reflects_isomorphisms(F : C ⥤ D) : Prop where 
  reflects : ∀ {A B : C} (f : A ⟶ B) [is_iso (F.map f)], is_iso f

/-- If `F` reflects isos and `F.map f` is an iso, then `f` is an iso. -/
theorem is_iso_of_reflects_iso {A B : C} (f : A ⟶ B) (F : C ⥤ D) [is_iso (F.map f)] [reflects_isomorphisms F] :
  is_iso f :=
  reflects_isomorphisms.reflects F f

instance (priority := 100)of_full_and_faithful (F : C ⥤ D) [full F] [faithful F] : reflects_isomorphisms F :=
  { reflects :=
      fun X Y f i =>
        by 
          exact
            ⟨⟨F.preimage (inv (F.map f)),
                ⟨F.map_injective
                    (by 
                      simp ),
                  F.map_injective
                    (by 
                      simp )⟩⟩⟩ }

end ReflectsIso

end CategoryTheory

