import Mathbin.CategoryTheory.Adjunction.Basic 
import Mathbin.CategoryTheory.Monad.Basic

/-! # Kleisli category on a monad

This file defines the Kleisli category on a monad `(T, η_ T, μ_ T)`. It also defines the Kleisli
adjunction which gives rise to the monad `(T, η_ T, μ_ T)`.

## References
* [Riehl, *Category theory in context*, Definition 5.2.9][riehl2017]
-/


namespace CategoryTheory

universe v u

variable{C : Type u}[category.{v} C]

/--
The objects for the Kleisli category of the functor (usually monad) `T : C ⥤ C`, which are the same
thing as objects of the base category `C`.
-/
@[nolint unused_arguments]
def kleisli (T : Monadₓ C) :=
  C

namespace Kleisli

variable(T : Monadₓ C)

instance  [Inhabited C] (T : Monadₓ C) : Inhabited (kleisli T) :=
  ⟨(default _ : C)⟩

-- error in CategoryTheory.Monad.Kleisli: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
/-- The Kleisli category on a monad `T`.
    cf Definition 5.2.9 in [Riehl][riehl2017]. -/ instance kleisli.category : category (kleisli T) :=
{ hom := λ X Y : C, «expr ⟶ »(X, (T : «expr ⥤ »(C, C)).obj Y),
  id := λ X, T.η.app X,
  comp := λ X Y Z f g, «expr ≫ »(f, «expr ≫ »((T : «expr ⥤ »(C, C)).map g, T.μ.app Z)),
  id_comp' := λ X Y f, begin
    rw ["[", "<-", expr T.η.naturality_assoc f, ",", expr T.left_unit, "]"] [],
    apply [expr category.comp_id]
  end,
  assoc' := λ W X Y Z f g h, begin
    simp [] [] ["only"] ["[", expr functor.map_comp, ",", expr category.assoc, ",", expr monad.assoc, "]"] [] [],
    erw [expr T.μ.naturality_assoc] []
  end }

namespace Adjunction

/-- The left adjoint of the adjunction which induces the monad `(T, η_ T, μ_ T)`. -/
@[simps]
def to_kleisli : C ⥤ kleisli T :=
  { obj := fun X => (X : kleisli T), map := fun X Y f => (f ≫ T.η.app Y : _),
    map_comp' :=
      fun X Y Z f g =>
        by 
          unfoldProjs 
          simp [←T.η.naturality g] }

/-- The right adjoint of the adjunction which induces the monad `(T, η_ T, μ_ T)`. -/
@[simps]
def from_kleisli : kleisli T ⥤ C :=
  { obj := fun X => T.obj X, map := fun X Y f => T.map f ≫ T.μ.app Y, map_id' := fun X => T.right_unit _,
    map_comp' :=
      fun X Y Z f g =>
        by 
          unfoldProjs 
          simp only [functor.map_comp, category.assoc]
          erw [←T.μ.naturality_assoc g, T.assoc]
          rfl }

/-- The Kleisli adjunction which gives rise to the monad `(T, η_ T, μ_ T)`.
    cf Lemma 5.2.11 of [Riehl][riehl2017]. -/
def adj : to_kleisli T ⊣ from_kleisli T :=
  adjunction.mk_of_hom_equiv
    { homEquiv := fun X Y => Equiv.refl (X ⟶ T.obj Y),
      hom_equiv_naturality_left_symm' :=
        fun X Y Z f g =>
          by 
            unfoldProjs 
            dsimp 
            rw [category.assoc, ←T.η.naturality_assoc g, functor.id_map]
            dsimp 
            simp [monad.left_unit] }

/-- The composition of the adjunction gives the original functor. -/
def to_kleisli_comp_from_kleisli_iso_self : to_kleisli T ⋙ from_kleisli T ≅ T :=
  nat_iso.of_components (fun X => iso.refl _)
    fun X Y f =>
      by 
        dsimp 
        simp 

end Adjunction

end Kleisli

end CategoryTheory

