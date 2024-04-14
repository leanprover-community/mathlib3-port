/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison, Bhavik Mehta
-/
import CategoryTheory.Adjunction.Reflective
import CategoryTheory.Monad.Algebra

#align_import category_theory.monad.adjunction from "leanprover-community/mathlib"@"86d1873c01a723aba6788f0b9051ae3d23b4c1c3"

/-!
# Adjunctions and monads

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We develop the basic relationship between adjunctions and monads.

Given an adjunction `h : L ⊣ R`, we have `h.to_monad : monad C` and `h.to_comonad : comonad D`.
We then have
`monad.comparison (h : L ⊣ R) : D ⥤ h.to_monad.algebra`
sending `Y : D` to the Eilenberg-Moore algebra for `L ⋙ R` with underlying object `R.obj X`,
and dually `comonad.comparison`.

We say `R : D ⥤ C` is `monadic_right_adjoint`, if it is a right adjoint and its `monad.comparison`
is an equivalence of categories. (Similarly for `monadic_left_adjoint`.)

Finally we prove that reflective functors are `monadic_right_adjoint`.
-/


namespace CategoryTheory

open Category

universe v₁ v₂ u₁ u₂

-- morphism levels before object levels. See note [category_theory universes].
variable {C : Type u₁} [Category.{v₁} C] {D : Type u₂} [Category.{v₂} D]

variable {L : C ⥤ D} {R : D ⥤ C}

namespace Adjunction

#print CategoryTheory.Adjunction.toMonad /-
/-- For a pair of functors `L : C ⥤ D`, `R : D ⥤ C`, an adjunction `h : L ⊣ R` induces a monad on
the category `C`.
-/
@[simps]
def toMonad (h : L ⊣ R) : Monad C where
  toFunctor := L ⋙ R
  η' := h.Unit
  μ' := whiskerRight (whiskerLeft L h.counit) R
  assoc' X := by dsimp; rw [← R.map_comp]; simp
  right_unit' X := by dsimp; rw [← R.map_comp]; simp
#align category_theory.adjunction.to_monad CategoryTheory.Adjunction.toMonad
-/

#print CategoryTheory.Adjunction.toComonad /-
/-- For a pair of functors `L : C ⥤ D`, `R : D ⥤ C`, an adjunction `h : L ⊣ R` induces a comonad on
the category `D`.
-/
@[simps]
def toComonad (h : L ⊣ R) : Comonad D
    where
  toFunctor := R ⋙ L
  ε' := h.counit
  δ' := whiskerRight (whiskerLeft R h.Unit) L
  coassoc' X := by dsimp; rw [← L.map_comp]; simp
  right_counit' X := by dsimp; rw [← L.map_comp]; simp
#align category_theory.adjunction.to_comonad CategoryTheory.Adjunction.toComonad
-/

#print CategoryTheory.Adjunction.adjToMonadIso /-
/-- The monad induced by the Eilenberg-Moore adjunction is the original monad.  -/
@[simps]
def adjToMonadIso (T : Monad C) : T.adj.toMonad ≅ T :=
  MonadIso.mk (NatIso.ofComponents (fun X => Iso.refl _) (by tidy)) (fun X => by dsimp; simp)
    fun X => by dsimp; simp
#align category_theory.adjunction.adj_to_monad_iso CategoryTheory.Adjunction.adjToMonadIso
-/

#print CategoryTheory.Adjunction.adjToComonadIso /-
/-- The comonad induced by the Eilenberg-Moore adjunction is the original comonad. -/
@[simps]
def adjToComonadIso (G : Comonad C) : G.adj.toComonad ≅ G :=
  ComonadIso.mk (NatIso.ofComponents (fun X => Iso.refl _) (by tidy)) (fun X => by dsimp; simp)
    fun X => by dsimp; simp
#align category_theory.adjunction.adj_to_comonad_iso CategoryTheory.Adjunction.adjToComonadIso
-/

end Adjunction

#print CategoryTheory.Monad.comparison /-
/-- Gven any adjunction `L ⊣ R`, there is a comparison functor `category_theory.monad.comparison R`
sending objects `Y : D` to Eilenberg-Moore algebras for `L ⋙ R` with underlying object `R.obj X`.

We later show that this is full when `R` is full, faithful when `R` is faithful,
and essentially surjective when `R` is reflective.
-/
@[simps]
def Monad.comparison (h : L ⊣ R) : D ⥤ h.toMonad.Algebra
    where
  obj X :=
    { A := R.obj X
      a := R.map (h.counit.app X)
      assoc' := by dsimp; rw [← R.map_comp, ← adjunction.counit_naturality, R.map_comp]; rfl }
  map X Y f :=
    { f := R.map f
      h' := by dsimp; rw [← R.map_comp, adjunction.counit_naturality, R.map_comp] }
#align category_theory.monad.comparison CategoryTheory.Monad.comparison
-/

#print CategoryTheory.Monad.comparisonForget /-
/-- The underlying object of `(monad.comparison R).obj X` is just `R.obj X`.
-/
@[simps]
def Monad.comparisonForget (h : L ⊣ R) : Monad.comparison h ⋙ h.toMonad.forget ≅ R
    where
  Hom := { app := fun X => 𝟙 _ }
  inv := { app := fun X => 𝟙 _ }
#align category_theory.monad.comparison_forget CategoryTheory.Monad.comparisonForget
-/

#print CategoryTheory.Monad.left_comparison /-
theorem Monad.left_comparison (h : L ⊣ R) : L ⋙ Monad.comparison h = h.toMonad.free :=
  rfl
#align category_theory.monad.left_comparison CategoryTheory.Monad.left_comparison
-/

instance [CategoryTheory.Functor.Faithful R] (h : L ⊣ R) :
    CategoryTheory.Functor.Faithful (Monad.comparison h)
    where map_injective' X Y f g w := R.map_injective (congr_arg Monad.Algebra.Hom.f w : _)

instance (T : Monad C) : CategoryTheory.Functor.Full (Monad.comparison T.adj)
    where preimage X Y f := ⟨f.f, by simpa using f.h⟩

instance (T : Monad C) : CategoryTheory.Functor.EssSurj (Monad.comparison T.adj)
    where mem_essImage X :=
    ⟨{  A := X.A
        a := X.a
        unit' := by simpa using X.unit
        assoc' := by simpa using X.assoc }, ⟨Monad.Algebra.isoMk (Iso.refl _) (by simp)⟩⟩

#print CategoryTheory.Comonad.comparison /-
/--
Gven any adjunction `L ⊣ R`, there is a comparison functor `category_theory.comonad.comparison L`
sending objects `X : C` to Eilenberg-Moore coalgebras for `L ⋙ R` with underlying object
`L.obj X`.
-/
@[simps]
def Comonad.comparison (h : L ⊣ R) : C ⥤ h.toComonad.Coalgebra
    where
  obj X :=
    { A := L.obj X
      a := L.map (h.Unit.app X)
      coassoc' := by dsimp; rw [← L.map_comp, ← adjunction.unit_naturality, L.map_comp]; rfl }
  map X Y f :=
    { f := L.map f
      h' := by dsimp; rw [← L.map_comp]; simp }
#align category_theory.comonad.comparison CategoryTheory.Comonad.comparison
-/

#print CategoryTheory.Comonad.comparisonForget /-
/-- The underlying object of `(comonad.comparison L).obj X` is just `L.obj X`.
-/
@[simps]
def Comonad.comparisonForget {L : C ⥤ D} {R : D ⥤ C} (h : L ⊣ R) :
    Comonad.comparison h ⋙ h.toComonad.forget ≅ L
    where
  Hom := { app := fun X => 𝟙 _ }
  inv := { app := fun X => 𝟙 _ }
#align category_theory.comonad.comparison_forget CategoryTheory.Comonad.comparisonForget
-/

#print CategoryTheory.Comonad.left_comparison /-
theorem Comonad.left_comparison (h : L ⊣ R) : R ⋙ Comonad.comparison h = h.toComonad.cofree :=
  rfl
#align category_theory.comonad.left_comparison CategoryTheory.Comonad.left_comparison
-/

#print CategoryTheory.Comonad.comparison_faithful_of_faithful /-
instance Comonad.comparison_faithful_of_faithful [CategoryTheory.Functor.Faithful L] (h : L ⊣ R) :
    CategoryTheory.Functor.Faithful (Comonad.comparison h)
    where map_injective' X Y f g w := L.map_injective (congr_arg Comonad.Coalgebra.Hom.f w : _)
#align category_theory.comonad.comparison_faithful_of_faithful CategoryTheory.Comonad.comparison_faithful_of_faithful
-/

instance (G : Comonad C) : CategoryTheory.Functor.Full (Comonad.comparison G.adj)
    where preimage X Y f := ⟨f.f, by simpa using f.h⟩

instance (G : Comonad C) : CategoryTheory.Functor.EssSurj (Comonad.comparison G.adj)
    where mem_essImage X :=
    ⟨{  A := X.A
        a := X.a
        counit' := by simpa using X.counit
        coassoc' := by simpa using X.coassoc }, ⟨Comonad.Coalgebra.isoMk (Iso.refl _) (by simp)⟩⟩

#print CategoryTheory.MonadicRightAdjoint /-
/-- A right adjoint functor `R : D ⥤ C` is *monadic* if the comparison functor `monad.comparison R`
from `D` to the category of Eilenberg-Moore algebras for the adjunction is an equivalence.
-/
class MonadicRightAdjoint (R : D ⥤ C) extends IsRightAdjoint R where
  eqv : CategoryTheory.Functor.IsEquivalence (Monad.comparison (Adjunction.ofRightAdjoint R))
#align category_theory.monadic_right_adjoint CategoryTheory.MonadicRightAdjoint
-/

#print CategoryTheory.ComonadicLeftAdjoint /-
/--
A left adjoint functor `L : C ⥤ D` is *comonadic* if the comparison functor `comonad.comparison L`
from `C` to the category of Eilenberg-Moore algebras for the adjunction is an equivalence.
-/
class ComonadicLeftAdjoint (L : C ⥤ D) extends IsLeftAdjoint L where
  eqv : CategoryTheory.Functor.IsEquivalence (Comonad.comparison (Adjunction.ofLeftAdjoint L))
#align category_theory.comonadic_left_adjoint CategoryTheory.ComonadicLeftAdjoint
-/

noncomputable instance (T : Monad C) : MonadicRightAdjoint T.forget :=
  ⟨(CategoryTheory.Functor.IsEquivalence.ofFullyFaithfullyEssSurj _ :
      CategoryTheory.Functor.IsEquivalence (Monad.comparison T.adj))⟩

noncomputable instance (G : Comonad C) : ComonadicLeftAdjoint G.forget :=
  ⟨(CategoryTheory.Functor.IsEquivalence.ofFullyFaithfullyEssSurj _ :
      CategoryTheory.Functor.IsEquivalence (Comonad.comparison G.adj))⟩

#print CategoryTheory.μ_iso_of_reflective /-
-- TODO: This holds more generally for idempotent adjunctions, not just reflective adjunctions.
instance μ_iso_of_reflective [Reflective R] : IsIso (Adjunction.ofRightAdjoint R).toMonad.μ := by
  dsimp; infer_instance
#align category_theory.μ_iso_of_reflective CategoryTheory.μ_iso_of_reflective
-/

attribute [instance] monadic_right_adjoint.eqv

attribute [instance] comonadic_left_adjoint.eqv

namespace Reflective

instance [Reflective R] (X : (Adjunction.ofRightAdjoint R).toMonad.Algebra) :
    IsIso ((Adjunction.ofRightAdjoint R).Unit.app X.A) :=
  ⟨⟨X.a,
      ⟨X.Unit, by
        dsimp only [functor.id_obj]
        rw [← (adjunction.of_right_adjoint R).unit_naturality]
        dsimp only [functor.comp_obj, adjunction.to_monad_coe]
        rw [unit_obj_eq_map_unit, ← functor.map_comp, ← functor.map_comp]
        erw [X.unit]
        simp⟩⟩⟩

#print CategoryTheory.Reflective.comparison_essSurj /-
instance comparison_essSurj [Reflective R] :
    CategoryTheory.Functor.EssSurj (Monad.comparison (Adjunction.ofRightAdjoint R)) :=
  by
  refine' ⟨fun X => ⟨(left_adjoint R).obj X.A, ⟨_⟩⟩⟩
  symm
  refine' monad.algebra.iso_mk _ _
  · exact as_iso ((adjunction.of_right_adjoint R).Unit.app X.A)
  dsimp only [functor.comp_map, monad.comparison_obj_a, as_iso_hom, functor.comp_obj,
    monad.comparison_obj_A, monad_to_functor_eq_coe, adjunction.to_monad_coe]
  rw [← cancel_epi ((adjunction.of_right_adjoint R).Unit.app X.A), adjunction.unit_naturality_assoc,
    adjunction.right_triangle_components, comp_id]
  apply (X.unit_assoc _).symm
#align category_theory.reflective.comparison_ess_surj CategoryTheory.Reflective.comparison_essSurj
-/

#print CategoryTheory.Reflective.comparisonFull /-
instance comparisonFull [CategoryTheory.Functor.Full R] [IsRightAdjoint R] :
    CategoryTheory.Functor.Full (Monad.comparison (Adjunction.ofRightAdjoint R))
    where preimage X Y f := R.preimage f.f
#align category_theory.reflective.comparison_full CategoryTheory.Reflective.comparisonFull
-/

end Reflective

#print CategoryTheory.monadicOfReflective /-
-- It is possible to do this computably since the construction gives the data of the inverse, not
-- just the existence of an inverse on each object.
-- see Note [lower instance priority]
/-- Any reflective inclusion has a monadic right adjoint.
    cf Prop 5.3.3 of [Riehl][riehl2017] -/
noncomputable instance (priority := 100) monadicOfReflective [Reflective R] : MonadicRightAdjoint R
    where eqv := CategoryTheory.Functor.IsEquivalence.ofFullyFaithfullyEssSurj _
#align category_theory.monadic_of_reflective CategoryTheory.monadicOfReflective
-/

end CategoryTheory

