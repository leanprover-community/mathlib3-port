import Mathbin.CategoryTheory.Functor

/-!
# Natural transformations

Defines natural transformations between functors.

A natural transformation `α : nat_trans F G` consists of morphisms `α.app X : F.obj X ⟶ G.obj X`,
and the naturality squares `α.naturality f : F.map f ≫ α.app Y = α.app X ≫ G.map f`,
where `f : X ⟶ Y`.

Note that we make `nat_trans.naturality` a simp lemma, with the preferred simp normal form
pushing components of natural transformations to the left.

See also `category_theory.functor_category`, where we provide the category structure on
functors and natural transformations.

Introduces notations
* `τ.app X` for the components of natural transformations,
* `F ⟶ G` for the type of natural transformations between functors `F` and `G`
  (this and the next require `category_theory.functor_category`),
* `σ ≫ τ` for vertical compositions, and
* `σ ◫ τ` for horizontal compositions.

-/


namespace CategoryTheory

universe v₁ v₂ v₃ v₄ u₁ u₂ u₃ u₄

variable{C : Type u₁}[category.{v₁} C]{D : Type u₂}[category.{v₂} D]

/--
`nat_trans F G` represents a natural transformation between functors `F` and `G`.

The field `app` provides the components of the natural transformation.

Naturality is expressed by `α.naturality_lemma`.
-/
@[ext]
structure nat_trans(F G : C ⥤ D) : Type max u₁ v₂ where 
  app : ∀ (X : C), F.obj X ⟶ G.obj X 
  naturality' : ∀ ⦃X Y : C⦄ (f : X ⟶ Y), F.map f ≫ app Y = app X ≫ G.map f :=  by 
  runTac 
    obviously

restate_axiom nat_trans.naturality'

attribute [simp, reassoc] nat_trans.naturality

theorem congr_app {F G : C ⥤ D} {α β : nat_trans F G} (h : α = β) (X : C) : α.app X = β.app X :=
  congr_funₓ (congr_argₓ nat_trans.app h) X

namespace NatTrans

/-- `nat_trans.id F` is the identity natural transformation on a functor `F`. -/
protected def id (F : C ⥤ D) : nat_trans F F :=
  { app := fun X => 𝟙 (F.obj X) }

@[simp]
theorem id_app' (F : C ⥤ D) (X : C) : (nat_trans.id F).app X = 𝟙 (F.obj X) :=
  rfl

instance  (F : C ⥤ D) : Inhabited (nat_trans F F) :=
  ⟨nat_trans.id F⟩

open Category

open CategoryTheory.Functor

section 

variable{F G H I : C ⥤ D}

/-- `vcomp α β` is the vertical compositions of natural transformations. -/
def vcomp (α : nat_trans F G) (β : nat_trans G H) : nat_trans F H :=
  { app := fun X => α.app X ≫ β.app X }

theorem vcomp_app (α : nat_trans F G) (β : nat_trans G H) (X : C) : (vcomp α β).app X = α.app X ≫ β.app X :=
  rfl

end 

/--
The diagram
    F(f)      F(g)      F(h)
F X ----> F Y ----> F U ----> F U
 |         |         |         |
 | α(X)    | α(Y)    | α(U)    | α(V)
 v         v         v         v
G X ----> G Y ----> G U ----> G V
    G(f)      G(g)      G(h)
commutes.
-/
example  {F G : C ⥤ D} (α : nat_trans F G) {X Y U V : C} (f : X ⟶ Y) (g : Y ⟶ U) (h : U ⟶ V) :
  α.app X ≫ G.map f ≫ G.map g ≫ G.map h = F.map f ≫ F.map g ≫ F.map h ≫ α.app V :=
  by 
    simp 

end NatTrans

end CategoryTheory

