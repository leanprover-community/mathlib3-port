import Mathbin.CategoryTheory.EqToHom 
import Mathbin.Data.Ulift

/-!
# Discrete categories

We define `discrete α := α` for any type `α`, and use this type alias
to provide a `small_category` instance whose only morphisms are the identities.

There is an annoying technical difficulty that it has turned out to be inconvenient
to allow categories with morphisms living in `Prop`,
so instead of defining `X ⟶ Y` in `discrete α` as `X = Y`,
one might define it as `plift (X = Y)`.
In fact, to allow `discrete α` to be a `small_category`
(i.e. with morphisms in the same universe as the objects),
we actually define the hom type `X ⟶ Y` as `ulift (plift (X = Y))`.

`discrete.functor` promotes a function `f : I → C` (for any category `C`) to a functor
`discrete.functor f : discrete I ⥤ C`.

Similarly, `discrete.nat_trans` and `discrete.nat_iso` promote `I`-indexed families of morphisms,
or `I`-indexed families of isomorphisms to natural transformations or natural isomorphism.

We show equivalences of types are the same as (categorical) equivalences of the corresponding
discrete categories.
-/


namespace CategoryTheory

universe v₁ v₂ u₁ u₂

/--
A type synonym for promoting any type to a category,
with the only morphisms being equalities.
-/
def discrete (α : Type u₁) :=
  α

/--
The "discrete" category on a type, whose morphisms are equalities.

Because we do not allow morphisms in `Prop` (only in `Type`),
somewhat annoyingly we have to define `X ⟶ Y` as `ulift (plift (X = Y))`.

See https://stacks.math.columbia.edu/tag/001A
-/
instance discrete_category (α : Type u₁) : small_category (discrete α) :=
  { Hom := fun X Y => Ulift (Plift (X = Y)), id := fun X => Ulift.up (Plift.up rfl),
    comp :=
      fun X Y Z g f =>
        by 
          rcases f with ⟨⟨rfl⟩⟩
          exact g }

namespace Discrete

variable{α : Type u₁}

instance  [Inhabited α] : Inhabited (discrete α) :=
  by 
    dsimp [discrete]
    infer_instance

instance  [Subsingleton α] : Subsingleton (discrete α) :=
  by 
    dsimp [discrete]
    infer_instance

/-- Extract the equation from a morphism in a discrete category. -/
theorem eq_of_hom {X Y : discrete α} (i : X ⟶ Y) : X = Y :=
  i.down.down

@[simp]
theorem id_def (X : discrete α) : Ulift.up (Plift.up (Eq.refl X)) = 𝟙 X :=
  rfl

variable{C : Type u₂}[category.{v₂} C]

instance  {I : Type u₁} {i j : discrete I} (f : i ⟶ j) : is_iso f :=
  ⟨⟨eq_to_hom (eq_of_hom f).symm,
      by 
        tidy⟩⟩

/--
Any function `I → C` gives a functor `discrete I ⥤ C`.
-/
def Functor {I : Type u₁} (F : I → C) : discrete I ⥤ C :=
  { obj := F,
    map :=
      fun X Y f =>
        by 
          cases f 
          cases f 
          cases f 
          exact 𝟙 (F X) }

@[simp]
theorem functor_obj {I : Type u₁} (F : I → C) (i : I) : (discrete.functor F).obj i = F i :=
  rfl

theorem functor_map {I : Type u₁} (F : I → C) {i : discrete I} (f : i ⟶ i) : (discrete.functor F).map f = 𝟙 (F i) :=
  by 
    cases f 
    cases f 
    cases f 
    rfl

/--
For functors out of a discrete category,
a natural transformation is just a collection of maps,
as the naturality squares are trivial.
-/
def nat_trans {I : Type u₁} {F G : discrete I ⥤ C} (f : ∀ (i : discrete I), F.obj i ⟶ G.obj i) : F ⟶ G :=
  { app := f }

@[simp]
theorem nat_trans_app {I : Type u₁} {F G : discrete I ⥤ C} (f : ∀ (i : discrete I), F.obj i ⟶ G.obj i) i :
  (discrete.nat_trans f).app i = f i :=
  rfl

/--
For functors out of a discrete category,
a natural isomorphism is just a collection of isomorphisms,
as the naturality squares are trivial.
-/
def nat_iso {I : Type u₁} {F G : discrete I ⥤ C} (f : ∀ (i : discrete I), F.obj i ≅ G.obj i) : F ≅ G :=
  nat_iso.of_components f
    (by 
      tidy)

@[simp]
theorem nat_iso_hom_app {I : Type u₁} {F G : discrete I ⥤ C} (f : ∀ (i : discrete I), F.obj i ≅ G.obj i) (i : I) :
  (discrete.nat_iso f).Hom.app i = (f i).Hom :=
  rfl

@[simp]
theorem nat_iso_inv_app {I : Type u₁} {F G : discrete I ⥤ C} (f : ∀ (i : discrete I), F.obj i ≅ G.obj i) (i : I) :
  (discrete.nat_iso f).inv.app i = (f i).inv :=
  rfl

@[simp]
theorem nat_iso_app {I : Type u₁} {F G : discrete I ⥤ C} (f : ∀ (i : discrete I), F.obj i ≅ G.obj i) (i : I) :
  (discrete.nat_iso f).app i = f i :=
  by 
    tidy

/-- Every functor `F` from a discrete category is naturally isomorphic (actually, equal) to
  `discrete.functor (F.obj)`. -/
def nat_iso_functor {I : Type u₁} {F : discrete I ⥤ C} : F ≅ discrete.functor F.obj :=
  nat_iso$ fun i => iso.refl _

/--
We can promote a type-level `equiv` to
an equivalence between the corresponding `discrete` categories.
-/
@[simps]
def Equivalenceₓ {I J : Type u₁} (e : I ≃ J) : discrete I ≌ discrete J :=
  { Functor := discrete.functor (e : I → J), inverse := discrete.functor (e.symm : J → I),
    unitIso :=
      discrete.nat_iso
        fun i =>
          eq_to_iso
            (by 
              simp ),
    counitIso :=
      discrete.nat_iso
        fun j =>
          eq_to_iso
            (by 
              simp ) }

/-- We can convert an equivalence of `discrete` categories to a type-level `equiv`. -/
@[simps]
def equiv_of_equivalence {α β : Type u₁} (h : discrete α ≌ discrete β) : α ≃ β :=
  { toFun := h.functor.obj, invFun := h.inverse.obj, left_inv := fun a => eq_of_hom (h.unit_iso.app a).2,
    right_inv := fun a => eq_of_hom (h.counit_iso.app a).1 }

end Discrete

namespace Discrete

variable{J : Type v₁}

open Opposite

/-- A discrete category is equivalent to its opposite category. -/
protected def Opposite (α : Type u₁) : «expr ᵒᵖ» (discrete α) ≌ discrete α :=
  let F : discrete α ⥤ «expr ᵒᵖ» (discrete α) := discrete.functor fun x => op x 
  by 
    refine'
      equivalence.mk (functor.left_op F) F _
        (discrete.nat_iso$
          fun X =>
            by 
              simp [F])
    refine'
      nat_iso.of_components
        (fun X =>
          by 
            simp [F])
        _ 
    tidy

variable{C : Type u₂}[category.{v₂} C]

-- error in CategoryTheory.DiscreteCategory: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem functor_map_id
(F : «expr ⥤ »(discrete J, C))
{j : discrete J}
(f : «expr ⟶ »(j, j)) : «expr = »(F.map f, «expr𝟙»() (F.obj j)) :=
begin
  have [ident h] [":", expr «expr = »(f, «expr𝟙»() j)] [],
  { cases [expr f] [],
    cases [expr f] [],
    ext [] [] [] },
  rw [expr h] [],
  simp [] [] [] [] [] []
end

end Discrete

end CategoryTheory

