/-
Copyright (c) 2021 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import CategoryTheory.EqToHom
import CategoryTheory.Quotient
import Combinatorics.Quiver.Path

#align_import category_theory.path_category from "leanprover-community/mathlib"@"f47581155c818e6361af4e4fda60d27d020c226b"

/-!
# The category paths on a quiver.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
When `C` is a quiver, `paths C` is the category of paths.

## When the quiver is itself a category
We provide `path_composition : paths C ⥤ C`.

We check that the quotient of the path category of a category by the canonical relation
(paths are related if they compose to the same path) is equivalent to the original category.
-/


universe v₁ v₂ u₁ u₂

namespace CategoryTheory

section

#print CategoryTheory.Paths /-
/-- A type synonym for the category of paths in a quiver.
-/
def Paths (V : Type u₁) : Type u₁ :=
  V
#align category_theory.paths CategoryTheory.Paths
-/

instance (V : Type u₁) [Inhabited V] : Inhabited (Paths V) :=
  ⟨(default : V)⟩

variable (V : Type u₁) [Quiver.{v₁ + 1} V]

namespace Paths

#print CategoryTheory.Paths.categoryPaths /-
instance categoryPaths : Category.{max u₁ v₁} (Paths V)
    where
  Hom := fun X Y : V => Quiver.Path X Y
  id X := Quiver.Path.nil
  comp X Y Z f g := Quiver.Path.comp f g
#align category_theory.paths.category_paths CategoryTheory.Paths.categoryPaths
-/

variable {V}

#print CategoryTheory.Paths.of /-
/-- The inclusion of a quiver `V` into its path category, as a prefunctor.
-/
@[simps]
def of : V ⥤q Paths V where
  obj X := X
  map X Y f := f.toPath
#align category_theory.paths.of CategoryTheory.Paths.of
-/

attribute [local ext] Functor.ext

#print CategoryTheory.Paths.lift /-
/-- Any prefunctor from `V` lifts to a functor from `paths V` -/
def lift {C} [Category C] (φ : V ⥤q C) : Paths V ⥤ C
    where
  obj := φ.obj
  map X Y f :=
    @Quiver.Path.rec V _ X (fun Y f => φ.obj X ⟶ φ.obj Y) (𝟙 <| φ.obj X)
      (fun Y Z p f ihp => ihp ≫ φ.map f) Y f
  map_id' X := by rfl
  map_comp' X Y Z f g := by
    induction' g with _ _ g' p ih _ _ _
    · rw [category.comp_id]; rfl
    · have : f ≫ g'.cons p = (f ≫ g').cons p := by apply Quiver.Path.comp_cons
      rw [this]; simp only; rw [ih, category.assoc]
#align category_theory.paths.lift CategoryTheory.Paths.lift
-/

#print CategoryTheory.Paths.lift_nil /-
@[simp]
theorem lift_nil {C} [Category C] (φ : V ⥤q C) (X : V) :
    (lift φ).map Quiver.Path.nil = 𝟙 (φ.obj X) :=
  rfl
#align category_theory.paths.lift_nil CategoryTheory.Paths.lift_nil
-/

#print CategoryTheory.Paths.lift_cons /-
@[simp]
theorem lift_cons {C} [Category C] (φ : V ⥤q C) {X Y Z : V} (p : Quiver.Path X Y) (f : Y ⟶ Z) :
    (lift φ).map (p.cons f) = (lift φ).map p ≫ φ.map f :=
  rfl
#align category_theory.paths.lift_cons CategoryTheory.Paths.lift_cons
-/

#print CategoryTheory.Paths.lift_toPath /-
@[simp]
theorem lift_toPath {C} [Category C] (φ : V ⥤q C) {X Y : V} (f : X ⟶ Y) :
    (lift φ).map f.toPath = φ.map f := by dsimp [Quiver.Hom.toPath, lift]; simp
#align category_theory.paths.lift_to_path CategoryTheory.Paths.lift_toPath
-/

#print CategoryTheory.Paths.lift_spec /-
theorem lift_spec {C} [Category C] (φ : V ⥤q C) : of ⋙q (lift φ).toPrefunctor = φ :=
  by
  apply Prefunctor.ext; rotate_left
  · rintro X; rfl
  · rintro X Y f; rcases φ with ⟨φo, φm⟩
    dsimp [lift, Quiver.Hom.toPath]
    simp only [category.id_comp]
#align category_theory.paths.lift_spec CategoryTheory.Paths.lift_spec
-/

#print CategoryTheory.Paths.lift_unique /-
theorem lift_unique {C} [Category C] (φ : V ⥤q C) (Φ : Paths V ⥤ C)
    (hΦ : of ⋙q Φ.toPrefunctor = φ) : Φ = lift φ :=
  by
  subst_vars
  apply Functor.ext; rotate_left
  · rintro X; rfl
  · rintro X Y f
    dsimp [lift]
    induction' f with _ _ p f' ih
    · simp only [category.comp_id]; apply Functor.map_id
    · simp only [category.comp_id, category.id_comp] at ih ⊢
      have : Φ.map (p.cons f') = Φ.map p ≫ Φ.map f'.to_path := by
        convert functor.map_comp Φ p f'.to_path
      rw [this, ih]
#align category_theory.paths.lift_unique CategoryTheory.Paths.lift_unique
-/

#print CategoryTheory.Paths.ext_functor /-
/-- Two functors out of a path category are equal when they agree on singleton paths. -/
@[ext]
theorem ext_functor {C} [Category C] {F G : Paths V ⥤ C} (h_obj : F.obj = G.obj)
    (h :
      ∀ (a b : V) (e : a ⟶ b),
        F.map e.toPath =
          eqToHom (congr_fun h_obj a) ≫ G.map e.toPath ≫ eqToHom (congr_fun h_obj.symm b)) :
    F = G := by
  ext X Y f
  · induction' f with Y' Z' g e ih
    · erw [F.map_id, G.map_id, category.id_comp, eq_to_hom_trans, eq_to_hom_refl]
    · erw [F.map_comp g e.to_path, G.map_comp g e.to_path, ih, h]
      simp only [category.id_comp, eq_to_hom_refl, eq_to_hom_trans_assoc, category.assoc]
  · intro X; rw [h_obj]
#align category_theory.paths.ext_functor CategoryTheory.Paths.ext_functor
-/

end Paths

variable (W : Type u₂) [Quiver.{v₂ + 1} W]

#print CategoryTheory.Prefunctor.mapPath_comp' /-
-- A restatement of `prefunctor.map_path_comp` using `f ≫ g` instead of `f.comp g`.
@[simp]
theorem Prefunctor.mapPath_comp' (F : V ⥤q W) {X Y Z : Paths V} (f : X ⟶ Y) (g : Y ⟶ Z) :
    F.mapPath (f ≫ g) = (F.mapPath f).comp (F.mapPath g) :=
  Prefunctor.mapPath_comp _ _ _
#align category_theory.prefunctor.map_path_comp' CategoryTheory.Prefunctor.mapPath_comp'
-/

end

section

variable {C : Type u₁} [Category.{v₁} C]

open Quiver

#print CategoryTheory.composePath /-
/-- A path in a category can be composed to a single morphism. -/
@[simp]
def composePath {X : C} : ∀ {Y : C} (p : Path X Y), X ⟶ Y
  | _, path.nil => 𝟙 X
  | _, path.cons p e => compose_path p ≫ e
#align category_theory.compose_path CategoryTheory.composePath
-/

#print CategoryTheory.composePath_toPath /-
@[simp]
theorem composePath_toPath {X Y : C} (f : X ⟶ Y) : composePath f.toPath = f :=
  Category.id_comp _
#align category_theory.compose_path_to_path CategoryTheory.composePath_toPath
-/

#print CategoryTheory.composePath_comp /-
@[simp]
theorem composePath_comp {X Y Z : C} (f : Path X Y) (g : Path Y Z) :
    composePath (f.comp g) = composePath f ≫ composePath g :=
  by
  induction' g with Y' Z' g e ih
  · simp
  · simp [ih]
#align category_theory.compose_path_comp CategoryTheory.composePath_comp
-/

#print CategoryTheory.composePath_id /-
@[simp]
theorem composePath_id {X : Paths C} : composePath (𝟙 X) = 𝟙 X :=
  rfl
#align category_theory.compose_path_id CategoryTheory.composePath_id
-/

#print CategoryTheory.composePath_comp' /-
@[simp]
theorem composePath_comp' {X Y Z : Paths C} (f : X ⟶ Y) (g : Y ⟶ Z) :
    composePath (f ≫ g) = composePath f ≫ composePath g :=
  composePath_comp f g
#align category_theory.compose_path_comp' CategoryTheory.composePath_comp'
-/

variable (C)

#print CategoryTheory.pathComposition /-
/-- Composition of paths as functor from the path category of a category to the category. -/
@[simps]
def pathComposition : Paths C ⥤ C where
  obj X := X
  map X Y f := composePath f
#align category_theory.path_composition CategoryTheory.pathComposition
-/

#print CategoryTheory.pathsHomRel /-
-- TODO: This, and what follows, should be generalized to
-- the `hom_rel` for the kernel of any functor.
-- Indeed, this should be part of an equivalence between congruence relations on a category `C`
-- and full, essentially surjective functors out of `C`.
/-- The canonical relation on the path category of a category:
two paths are related if they compose to the same morphism. -/
@[simp]
def pathsHomRel : HomRel (Paths C) := fun X Y p q =>
  (pathComposition C).map p = (pathComposition C).map q
#align category_theory.paths_hom_rel CategoryTheory.pathsHomRel
-/

#print CategoryTheory.toQuotientPaths /-
/-- The functor from a category to the canonical quotient of its path category. -/
@[simps]
def toQuotientPaths : C ⥤ Quotient (pathsHomRel C)
    where
  obj X := Quotient.mk X
  map X Y f := Quot.mk _ f.toPath
  map_id' X := Quot.sound (Quotient.CompClosure.of _ _ _ (by simp))
  map_comp' X Y Z f g := Quot.sound (Quotient.CompClosure.of _ _ _ (by simp))
#align category_theory.to_quotient_paths CategoryTheory.toQuotientPaths
-/

#print CategoryTheory.quotientPathsTo /-
/-- The functor from the canonical quotient of a path category of a category
to the original category. -/
@[simps]
def quotientPathsTo : Quotient (pathsHomRel C) ⥤ C :=
  Quotient.lift _ (pathComposition C) fun X Y p q w => w
#align category_theory.quotient_paths_to CategoryTheory.quotientPathsTo
-/

#print CategoryTheory.quotientPathsEquiv /-
/-- The canonical quotient of the path category of a category
is equivalent to the original category. -/
def quotientPathsEquiv : Quotient (pathsHomRel C) ≌ C
    where
  Functor := quotientPathsTo C
  inverse := toQuotientPaths C
  unitIso :=
    NatIso.ofComponents (fun X => by cases X; rfl)
      (by
        intros
        cases X; cases Y
        induction f
        dsimp
        simp only [category.comp_id, category.id_comp]
        apply Quot.sound
        apply quotient.comp_closure.of
        simp [paths_hom_rel])
  counitIso := NatIso.ofComponents (fun X => Iso.refl _) (by tidy)
  functor_unitIso_comp' := by intros; cases X; dsimp; simp; rfl
#align category_theory.quotient_paths_equiv CategoryTheory.quotientPathsEquiv
-/

end

end CategoryTheory

