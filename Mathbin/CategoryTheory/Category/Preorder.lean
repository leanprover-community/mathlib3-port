/-
Copyright (c) 2017 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Stephen Morgan, Scott Morrison, Johannes Hölzl, Reid Barton
-/
import Mathbin.CategoryTheory.Equivalence
import Mathbin.Order.Hom.Basic

/-!

# Preorders as categories

We install a category instance on any preorder. This is not to be confused with the category _of_
preorders, defined in `order/category/Preorder`.

We show that monotone functions between preorders correspond to functors of the associated
categories.

## Main definitions

* `hom_of_le` and `le_of_hom` provide translations between inequalities in the preorder, and
  morphisms in the associated category.
* `monotone.functor` is the functor associated to a monotone function.

-/


universe u v

namespace Preorder

open CategoryTheory

-- see Note [lower instance priority]
/-- The category structure coming from a preorder. There is a morphism `X ⟶ Y` if and only if `X ≤ Y`.

Because we don't allow morphisms to live in `Prop`,
we have to define `X ⟶ Y` as `ulift (plift (X ≤ Y))`.
See `category_theory.hom_of_le` and `category_theory.le_of_hom`.

See <https://stacks.math.columbia.edu/tag/00D3>.
-/
instance (priority := 100) smallCategory (α : Type u) [Preorder α] : SmallCategory α where
  Hom U V := ULift (PLift (U ≤ V))
  id X := ⟨⟨le_refl X⟩⟩
  comp X Y Z f g := ⟨⟨le_trans _ _ _ f.down.down g.down.down⟩⟩

end Preorder

namespace CategoryTheory

open Opposite

variable {X : Type u} [Preorder X]

/-- Express an inequality as a morphism in the corresponding preorder category.
-/
def homOfLe {x y : X} (h : x ≤ y) : x ⟶ y :=
  ULift.up (PLift.up h)

alias hom_of_le ← _root_.has_le.le.hom

@[simp]
theorem hom_of_le_refl {x : X} : (le_refl x).Hom = 𝟙 x :=
  rfl

@[simp]
theorem hom_of_le_comp {x y z : X} (h : x ≤ y) (k : y ≤ z) : h.Hom ≫ k.Hom = (h.trans k).Hom :=
  rfl

/-- Extract the underlying inequality from a morphism in a preorder category.
-/
theorem le_of_hom {x y : X} (h : x ⟶ y) : x ≤ y :=
  h.down.down

alias le_of_hom ← _root_.quiver.hom.le

@[simp]
theorem le_of_hom_hom_of_le {x y : X} (h : x ≤ y) : h.Hom.le = h :=
  rfl

@[simp]
theorem hom_of_le_le_of_hom {x y : X} (h : x ⟶ y) : h.le.Hom = h := by
  cases h
  cases h
  rfl

/-- Construct a morphism in the opposite of a preorder category from an inequality. -/
def opHomOfLe {x y : Xᵒᵖ} (h : unop x ≤ unop y) : y ⟶ x :=
  h.Hom.op

theorem le_of_op_hom {x y : Xᵒᵖ} (h : x ⟶ y) : unop y ≤ unop x :=
  h.unop.le

instance uniqueToTop [OrderTop X] {x : X} : Unique (x ⟶ ⊤) := by tidy

instance uniqueFromBot [OrderBot X] {x : X} : Unique (⊥ ⟶ x) := by tidy

end CategoryTheory

section

variable {X : Type u} {Y : Type v} [Preorder X] [Preorder Y]

/-- A monotone function between preorders induces a functor between the associated categories.
-/
def Monotone.functor {f : X → Y} (h : Monotone f) : X ⥤ Y where
  obj := f
  map x₁ x₂ g := (h g.le).Hom

@[simp]
theorem Monotone.functor_obj {f : X → Y} (h : Monotone f) : h.Functor.obj = f :=
  rfl

end

namespace CategoryTheory

section Preorder

variable {X : Type u} {Y : Type v} [Preorder X] [Preorder Y]

/-- A functor between preorder categories is monotone.
-/
@[mono]
theorem Functor.monotone (f : X ⥤ Y) : Monotone f.obj := fun x y hxy => (f.map hxy.Hom).le

end Preorder

section PartialOrder

variable {X : Type u} {Y : Type v} [PartialOrder X] [PartialOrder Y]

theorem Iso.to_eq {x y : X} (f : x ≅ y) : x = y :=
  le_antisymm f.Hom.le f.inv.le

/-- A categorical equivalence between partial orders is just an order isomorphism.
-/
def Equivalence.toOrderIso (e : X ≌ Y) : X ≃o Y where
  toFun := e.Functor.obj
  invFun := e.inverse.obj
  left_inv a := (e.unitIso.app a).to_eq.symm
  right_inv b := (e.counitIso.app b).to_eq
  map_rel_iff' a a' :=
    ⟨fun h => ((Equivalence.unit e).app a ≫ e.inverse.map h.Hom ≫ (Equivalence.unitInv e).app a').le, fun h : a ≤ a' =>
      (e.Functor.map h.Hom).le⟩

-- `@[simps]` on `equivalence.to_order_iso` produces lemmas that fail the `simp_nf` linter,
-- so we provide them by hand:
@[simp]
theorem Equivalence.to_order_iso_apply (e : X ≌ Y) (x : X) : e.toOrderIso x = e.Functor.obj x :=
  rfl

@[simp]
theorem Equivalence.to_order_iso_symm_apply (e : X ≌ Y) (y : Y) : e.toOrderIso.symm y = e.inverse.obj y :=
  rfl

end PartialOrder

end CategoryTheory

