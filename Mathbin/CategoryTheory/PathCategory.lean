/-
Copyright (c) 2021 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import Mathbin.CategoryTheory.EqToHom
import Mathbin.CategoryTheory.Quotient
import Mathbin.Combinatorics.Quiver.Path

/-!
# The category paths on a quiver.
When `C` is a quiver, `paths C` is the category of paths.

## When the quiver is itself a category
We provide `path_composition : paths C ⥤ C`.

We check that the quotient of the path category of a category by the canonical relation
(paths are related if they compose to the same path) is equivalent to the original category.
-/


universe v₁ v₂ u₁ u₂

namespace CategoryTheory

section

/-- A type synonym for the category of paths in a quiver.
-/
def Paths (V : Type u₁) : Type u₁ :=
  V

instance (V : Type u₁) [Inhabited V] : Inhabited (Paths V) :=
  ⟨(default : V)⟩

variable (V : Type u₁) [Quiver.{v₁ + 1} V]

namespace Paths

instance categoryPaths : Category.{max u₁ v₁} (Paths V) where
  Hom := fun X Y : V => Quiver.Path X Y
  id := fun X => Quiver.Path.nil
  comp := fun X Y Z f g => Quiver.Path.comp f g

variable {V}

/-- The inclusion of a quiver `V` into its path category, as a prefunctor.
-/
@[simps]
def of : Prefunctor V (Paths V) where
  obj := fun X => X
  map := fun X Y f => f.toPath

attribute [local ext] Functor.ext

/-- Any prefunctor from `V` lifts to a functor from `paths V` -/
def lift {C} [Category C] (φ : Prefunctor V C) : Paths V ⥤ C where
  obj := φ.obj
  map := fun X Y f =>
    @Quiver.Path.rec V _ X (fun Y f => φ.obj X ⟶ φ.obj Y) (𝟙 <| φ.obj X) (fun Y Z p f ihp => ihp ≫ φ.map f) Y f
  map_id' := fun X => by rfl
  map_comp' := fun X Y Z f g => by
    induction' g with _ _ g' p ih _ _ _
    · rw [category.comp_id]
      rfl
      
    · have : f ≫ g'.cons p = (f ≫ g').cons p := by apply Quiver.Path.comp_cons
      rw [this]
      simp only
      rw [ih, category.assoc]
      

@[simp]
theorem lift_nil {C} [Category C] (φ : Prefunctor V C) (X : V) : (lift φ).map Quiver.Path.nil = 𝟙 (φ.obj X) :=
  rfl

@[simp]
theorem lift_cons {C} [Category C] (φ : Prefunctor V C) {X Y Z : V} (p : Quiver.Path X Y) (f : Y ⟶ Z) :
    (lift φ).map (p.cons f) = (lift φ).map p ≫ φ.map f :=
  rfl

@[simp]
theorem lift_to_path {C} [Category C] (φ : Prefunctor V C) {X Y : V} (f : X ⟶ Y) : (lift φ).map f.toPath = φ.map f := by
  dsimp [Quiver.Hom.toPath, lift]
  simp

theorem lift_spec {C} [Category C] (φ : Prefunctor V C) : of.comp (lift φ).toPrefunctor = φ := by
  apply Prefunctor.ext
  rotate_left
  · rintro X
    rfl
    
  · rintro X Y f
    rcases φ with ⟨φo, φm⟩
    dsimp [lift, Quiver.Hom.toPath]
    simp only [category.id_comp]
    

theorem lift_spec_unique {C} [Category C] (φ : Prefunctor V C) (Φ : Paths V ⥤ C) (hΦ : of.comp Φ.toPrefunctor = φ) :
    Φ = lift φ := by
  subst_vars
  apply Functor.ext
  rotate_left
  · rintro X
    rfl
    
  · rintro X Y f
    dsimp [lift]
    induction' f with _ _ p f' ih
    · simp only [category.comp_id]
      apply Functor.map_id
      
    · simp only [category.comp_id, category.id_comp] at ih⊢
      have : Φ.map (p.cons f') = Φ.map p ≫ Φ.map f'.to_path := by convert functor.map_comp Φ p f'.to_path
      rw [this, ih]
      
    

/-- Two functors out of a path category are equal when they agree on singleton paths. -/
@[ext]
theorem ext_functor {C} [Category C] {F G : Paths V ⥤ C} (h_obj : F.obj = G.obj)
    (h :
      ∀ (a b : V) (e : a ⟶ b),
        F.map e.toPath = eqToHom (congr_fun h_obj a) ≫ G.map e.toPath ≫ eqToHom (congr_fun h_obj.symm b)) :
    F = G := by
  ext X Y f
  · induction' f with Y' Z' g e ih
    · erw [F.map_id, G.map_id, category.id_comp, eq_to_hom_trans, eq_to_hom_refl]
      
    · erw [F.map_comp g e.to_path, G.map_comp g e.to_path, ih, h]
      simp only [category.id_comp, eq_to_hom_refl, eq_to_hom_trans_assoc, category.assoc]
      
    
  · intro X
    rw [h_obj]
    

end Paths

variable (W : Type u₂) [Quiver.{v₂ + 1} W]

-- A restatement of `prefunctor.map_path_comp` using `f ≫ g` instead of `f.comp g`.
@[simp]
theorem Prefunctor.map_path_comp' (F : Prefunctor V W) {X Y Z : Paths V} (f : X ⟶ Y) (g : Y ⟶ Z) :
    F.mapPath (f ≫ g) = (F.mapPath f).comp (F.mapPath g) :=
  Prefunctor.map_path_comp _ _ _

end

section

variable {C : Type u₁} [Category.{v₁} C]

open Quiver

/-- A path in a category can be composed to a single morphism. -/
@[simp]
def composePathₓ {X : C} : ∀ {Y : C} (p : Path X Y), X ⟶ Y
  | _, path.nil => 𝟙 X
  | _, path.cons p e => compose_path p ≫ e

@[simp]
theorem compose_path_to_path {X Y : C} (f : X ⟶ Y) : composePathₓ f.toPath = f :=
  Category.id_comp _

@[simp]
theorem compose_path_comp {X Y Z : C} (f : Path X Y) (g : Path Y Z) :
    composePathₓ (f.comp g) = composePathₓ f ≫ composePathₓ g := by
  induction' g with Y' Z' g e ih
  · simp
    
  · simp [ih]
    

@[simp]
theorem compose_path_id {X : Paths C} : composePathₓ (𝟙 X) = 𝟙 X :=
  rfl

@[simp]
theorem compose_path_comp' {X Y Z : Paths C} (f : X ⟶ Y) (g : Y ⟶ Z) :
    composePathₓ (f ≫ g) = composePathₓ f ≫ composePathₓ g :=
  compose_path_comp f g

variable (C)

/-- Composition of paths as functor from the path category of a category to the category. -/
@[simps]
def pathComposition : Paths C ⥤ C where
  obj := fun X => X
  map := fun X Y f => composePathₓ f

-- TODO: This, and what follows, should be generalized to
-- the `hom_rel` for the kernel of any functor.
-- Indeed, this should be part of an equivalence between congruence relations on a category `C`
-- and full, essentially surjective functors out of `C`.
/-- The canonical relation on the path category of a category:
two paths are related if they compose to the same morphism. -/
@[simp]
def PathsHomRel : HomRel (Paths C) := fun X Y p q => (pathComposition C).map p = (pathComposition C).map q

/-- The functor from a category to the canonical quotient of its path category. -/
@[simps]
def toQuotientPaths : C ⥤ Quotient (PathsHomRel C) where
  obj := fun X => Quotient.mk X
  map := fun X Y f => Quot.mk _ f.toPath
  map_id' := fun X => Quot.sound (Quotient.CompClosure.of _ _ _ (by simp))
  map_comp' := fun X Y Z f g => Quot.sound (Quotient.CompClosure.of _ _ _ (by simp))

/-- The functor from the canonical quotient of a path category of a category
to the original category. -/
@[simps]
def quotientPathsTo : Quotient (PathsHomRel C) ⥤ C :=
  Quotient.lift _ (pathComposition C) fun X Y p q w => w

/-- The canonical quotient of the path category of a category
is equivalent to the original category. -/
def quotientPathsEquiv : Quotient (PathsHomRel C) ≌ C where
  Functor := quotientPathsTo C
  inverse := toQuotientPaths C
  unitIso :=
    NatIso.ofComponents
      (fun X => by
        cases X
        rfl)
      (by
        intros
        cases X
        cases Y
        induction f
        dsimp
        simp only [category.comp_id, category.id_comp]
        apply Quot.sound
        apply quotient.comp_closure.of
        simp [paths_hom_rel])
  counitIso := NatIso.ofComponents (fun X => Iso.refl _) (by tidy)
  functor_unit_iso_comp' := by
    intros
    cases X
    dsimp
    simp
    rfl

end

end CategoryTheory

