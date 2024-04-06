/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon, Scott Morrison
-/
import CategoryTheory.NatIso
import CategoryTheory.EqToHom
import Data.Sum.Basic

#align_import category_theory.pi.basic from "leanprover-community/mathlib"@"e97cf15cd1aec9bd5c193b2ffac5a6dc9118912b"

/-!
# Categories of indexed families of objects.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define the pointwise category structure on indexed families of objects in a category
(and also the dependent generalization).

-/


namespace CategoryTheory

universe w₀ w₁ w₂ v₁ v₂ u₁ u₂

variable {I : Type w₀} (C : I → Type u₁) [∀ i, Category.{v₁} (C i)]

#print CategoryTheory.pi /-
/-- `pi C` gives the cartesian product of an indexed family of categories.
-/
instance pi : Category.{max w₀ v₁} (∀ i, C i)
    where
  Hom X Y := ∀ i, X i ⟶ Y i
  id X i := 𝟙 (X i)
  comp X Y Z f g i := f i ≫ g i
#align category_theory.pi CategoryTheory.pi
-/

#print CategoryTheory.pi' /-
/-- This provides some assistance to typeclass search in a common situation,
which otherwise fails. (Without this `category_theory.pi.has_limit_of_has_limit_comp_eval` fails.)
-/
abbrev pi' {I : Type v₁} (C : I → Type u₁) [∀ i, Category.{v₁} (C i)] : Category.{v₁} (∀ i, C i) :=
  CategoryTheory.pi C
#align category_theory.pi' CategoryTheory.pi'
-/

attribute [instance] pi'

namespace Pi

#print CategoryTheory.Pi.id_apply /-
@[simp]
theorem id_apply (X : ∀ i, C i) (i) : (𝟙 X : ∀ i, X i ⟶ X i) i = 𝟙 (X i) :=
  rfl
#align category_theory.pi.id_apply CategoryTheory.Pi.id_apply
-/

#print CategoryTheory.Pi.comp_apply /-
@[simp]
theorem comp_apply {X Y Z : ∀ i, C i} (f : X ⟶ Y) (g : Y ⟶ Z) (i) :
    (f ≫ g : ∀ i, X i ⟶ Z i) i = f i ≫ g i :=
  rfl
#align category_theory.pi.comp_apply CategoryTheory.Pi.comp_apply
-/

#print CategoryTheory.Pi.eval /-
/--
The evaluation functor at `i : I`, sending an `I`-indexed family of objects to the object over `i`.
-/
@[simps]
def eval (i : I) : (∀ i, C i) ⥤ C i where
  obj f := f i
  map f g α := α i
#align category_theory.pi.eval CategoryTheory.Pi.eval
-/

section

variable {J : Type w₁}

#print CategoryTheory.Pi.comap /-
/-- Pull back an `I`-indexed family of objects to an `J`-indexed family, along a function `J → I`.
-/
@[simps]
def comap (h : J → I) : (∀ i, C i) ⥤ ∀ j, C (h j)
    where
  obj f i := f (h i)
  map f g α i := α (h i)
#align category_theory.pi.comap CategoryTheory.Pi.comap
-/

variable (I)

#print CategoryTheory.Pi.comapId /-
/-- The natural isomorphism between
pulling back a grading along the identity function,
and the identity functor. -/
@[simps]
def comapId : comap C (id : I → I) ≅ 𝟭 (∀ i, C i)
    where
  Hom := { app := fun X => 𝟙 X }
  inv := { app := fun X => 𝟙 X }
#align category_theory.pi.comap_id CategoryTheory.Pi.comapId
-/

variable {I}

variable {K : Type w₂}

#print CategoryTheory.Pi.comapComp /-
/-- The natural isomorphism comparing between
pulling back along two successive functions, and
pulling back along their composition
-/
@[simps]
def comapComp (f : K → J) (g : J → I) : comap C g ⋙ comap (C ∘ g) f ≅ comap C (g ∘ f)
    where
  Hom := { app := fun X b => 𝟙 (X (g (f b))) }
  inv := { app := fun X b => 𝟙 (X (g (f b))) }
#align category_theory.pi.comap_comp CategoryTheory.Pi.comapComp
-/

#print CategoryTheory.Pi.comapEvalIsoEval /-
/-- The natural isomorphism between pulling back then evaluating, and just evaluating. -/
@[simps]
def comapEvalIsoEval (h : J → I) (j : J) : comap C h ⋙ eval (C ∘ h) j ≅ eval C (h j) :=
  NatIso.ofComponents (fun f => Iso.refl _) (by tidy)
#align category_theory.pi.comap_eval_iso_eval CategoryTheory.Pi.comapEvalIsoEval
-/

end

section

variable {J : Type w₀} {D : J → Type u₁} [∀ j, Category.{v₁} (D j)]

instance sumElimCategory : ∀ s : Sum I J, Category.{v₁} (Sum.elim C D s)
  | Sum.inl i => by dsimp; infer_instance
  | Sum.inr j => by dsimp; infer_instance
#align category_theory.pi.sum_elim_category CategoryTheory.Pi.sumElimCategoryₓ

#print CategoryTheory.Pi.sum /-
/-- The bifunctor combining an `I`-indexed family of objects with a `J`-indexed family of objects
to obtain an `I ⊕ J`-indexed family of objects.
-/
@[simps]
def sum : (∀ i, C i) ⥤ (∀ j, D j) ⥤ ∀ s : Sum I J, Sum.elim C D s
    where
  obj f :=
    { obj := fun g s => Sum.rec f g s
      map := fun g g' α s => Sum.rec (fun i => 𝟙 (f i)) α s }
  map f f' α := { app := fun g s => Sum.rec α (fun j => 𝟙 (g j)) s }
#align category_theory.pi.sum CategoryTheory.Pi.sum
-/

end

variable {C}

#print CategoryTheory.Pi.isoApp /-
/-- An isomorphism between `I`-indexed objects gives an isomorphism between each
pair of corresponding components. -/
@[simps]
def isoApp {X Y : ∀ i, C i} (f : X ≅ Y) (i : I) : X i ≅ Y i :=
  ⟨f.Hom i, f.inv i, by dsimp; rw [← comp_apply, iso.hom_inv_id, id_apply], by dsimp;
    rw [← comp_apply, iso.inv_hom_id, id_apply]⟩
#align category_theory.pi.iso_app CategoryTheory.Pi.isoApp
-/

#print CategoryTheory.Pi.isoApp_refl /-
@[simp]
theorem isoApp_refl (X : ∀ i, C i) (i : I) : isoApp (Iso.refl X) i = Iso.refl (X i) :=
  rfl
#align category_theory.pi.iso_app_refl CategoryTheory.Pi.isoApp_refl
-/

#print CategoryTheory.Pi.isoApp_symm /-
@[simp]
theorem isoApp_symm {X Y : ∀ i, C i} (f : X ≅ Y) (i : I) : isoApp f.symm i = (isoApp f i).symm :=
  rfl
#align category_theory.pi.iso_app_symm CategoryTheory.Pi.isoApp_symm
-/

#print CategoryTheory.Pi.isoApp_trans /-
@[simp]
theorem isoApp_trans {X Y Z : ∀ i, C i} (f : X ≅ Y) (g : Y ≅ Z) (i : I) :
    isoApp (f ≪≫ g) i = isoApp f i ≪≫ isoApp g i :=
  rfl
#align category_theory.pi.iso_app_trans CategoryTheory.Pi.isoApp_trans
-/

end Pi

namespace Functor

variable {C}

variable {D : I → Type u₁} [∀ i, Category.{v₁} (D i)] {A : Type u₁} [Category.{u₁} A]

#print CategoryTheory.Functor.pi /-
/-- Assemble an `I`-indexed family of functors into a functor between the pi types.
-/
@[simps]
def pi (F : ∀ i, C i ⥤ D i) : (∀ i, C i) ⥤ ∀ i, D i
    where
  obj f i := (F i).obj (f i)
  map f g α i := (F i).map (α i)
#align category_theory.functor.pi CategoryTheory.Functor.pi
-/

#print CategoryTheory.Functor.pi' /-
/-- Similar to `pi`, but all functors come from the same category `A`
-/
@[simps]
def pi' (f : ∀ i, A ⥤ C i) : A ⥤ ∀ i, C i
    where
  obj a i := (f i).obj a
  map a₁ a₂ h i := (f i).map h
#align category_theory.functor.pi' CategoryTheory.Functor.pi'
-/

section EqToHom

#print CategoryTheory.Functor.eqToHom_proj /-
@[simp]
theorem eqToHom_proj {x x' : ∀ i, C i} (h : x = x') (i : I) :
    (eqToHom h : x ⟶ x') i = eqToHom (Function.funext_iff.mp h i) := by subst h; rfl
#align category_theory.functor.eq_to_hom_proj CategoryTheory.Functor.eqToHom_proj
-/

end EqToHom

#print CategoryTheory.Functor.pi'_eval /-
-- One could add some natural isomorphisms showing
-- how `functor.pi` commutes with `pi.eval` and `pi.comap`.
@[simp]
theorem pi'_eval (f : ∀ i, A ⥤ C i) (i : I) : pi' f ⋙ Pi.eval C i = f i :=
  by
  apply Functor.ext <;> intros
  · simp; · rfl
#align category_theory.functor.pi'_eval CategoryTheory.Functor.pi'_eval
-/

#print CategoryTheory.Functor.pi_ext /-
/-- Two functors to a product category are equal iff they agree on every coordinate. -/
theorem pi_ext (f f' : A ⥤ ∀ i, C i) (h : ∀ i, f ⋙ Pi.eval C i = f' ⋙ Pi.eval C i) : f = f' :=
  by
  apply Functor.ext; swap
  · intro X; ext i; specialize h i
    have := congr_obj h X; simpa
  · intro x y p; ext i; specialize h i
    have := congr_hom h p; simpa
#align category_theory.functor.pi_ext CategoryTheory.Functor.pi_ext
-/

end Functor

namespace NatTrans

variable {C}

variable {D : I → Type u₁} [∀ i, Category.{v₁} (D i)]

variable {F G : ∀ i, C i ⥤ D i}

#print CategoryTheory.NatTrans.pi /-
/-- Assemble an `I`-indexed family of natural transformations into a single natural transformation.
-/
@[simps]
def pi (α : ∀ i, F i ⟶ G i) : Functor.pi F ⟶ Functor.pi G where app f i := (α i).app (f i)
#align category_theory.nat_trans.pi CategoryTheory.NatTrans.pi
-/

end NatTrans

end CategoryTheory

