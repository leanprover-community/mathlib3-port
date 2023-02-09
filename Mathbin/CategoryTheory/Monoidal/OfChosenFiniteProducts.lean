/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison, Simon Hudon

! This file was ported from Lean 3 source module category_theory.monoidal.of_chosen_finite_products
! leanprover-community/mathlib commit 0ebfdb71919ac6ca5d7fbc61a082fa2519556818
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Monoidal.Braided
import Mathbin.CategoryTheory.Limits.Shapes.BinaryProducts
import Mathbin.CategoryTheory.Pempty

/-!
# The monoidal structure on a category with chosen finite products.

This is a variant of the development in `category_theory.monoidal.of_has_finite_products`,
which uses specified choices of the terminal object and binary product,
enabling the construction of a cartesian category with specific definitions of the tensor unit
and tensor product.

(Because the construction in `category_theory.monoidal.of_has_finite_products` uses `has_limit`
classes, the actual definitions there are opaque behind `classical.choice`.)

We use this in `category_theory.monoidal.types` to construct the monoidal category of types
so that the tensor product is the usual cartesian product of types.

For now we only do the construction from products, and not from coproducts,
which seems less often useful.
-/


universe v u

noncomputable section

namespace CategoryTheory

variable (C : Type u) [Category.{v} C] {X Y : C}

namespace Limits

section

variable {C}

/-- Swap the two sides of a `binary_fan`. -/
def BinaryFan.swap {P Q : C} (t : BinaryFan P Q) : BinaryFan Q P :=
  BinaryFan.mk t.snd t.fst
#align category_theory.limits.binary_fan.swap CategoryTheory.Limits.BinaryFan.swap

@[simp]
theorem BinaryFan.swap_fst {P Q : C} (t : BinaryFan P Q) : t.swap.fst = t.snd :=
  rfl
#align category_theory.limits.binary_fan.swap_fst CategoryTheory.Limits.BinaryFan.swap_fst

@[simp]
theorem BinaryFan.swap_snd {P Q : C} (t : BinaryFan P Q) : t.swap.snd = t.fst :=
  rfl
#align category_theory.limits.binary_fan.swap_snd CategoryTheory.Limits.BinaryFan.swap_snd

/-- If a cone `t` over `P Q` is a limit cone, then `t.swap` is a limit cone over `Q P`.
-/
@[simps]
def IsLimit.swapBinaryFan {P Q : C} {t : BinaryFan P Q} (I : IsLimit t) : IsLimit t.swap
    where
  lift s := I.lift (BinaryFan.swap s)
  fac' s := by rintro ⟨⟨⟩⟩ <;> simp
  uniq' s m w := by
    have h := I.uniq (BinaryFan.swap s) m
    rw [h]
    rintro ⟨j⟩
    specialize w ⟨j.swap⟩
    cases j <;> exact w
#align category_theory.limits.is_limit.swap_binary_fan CategoryTheory.Limits.IsLimit.swapBinaryFan

/-- Construct `has_binary_product Q P` from `has_binary_product P Q`.
This can't be an instance, as it would cause a loop in typeclass search.
-/
theorem HasBinaryProduct.swap (P Q : C) [HasBinaryProduct P Q] : HasBinaryProduct Q P :=
  HasLimit.mk ⟨BinaryFan.swap (Limit.cone (pair P Q)), (limit.isLimit (pair P Q)).swapBinaryFan⟩
#align category_theory.limits.has_binary_product.swap CategoryTheory.Limits.HasBinaryProduct.swap

/-- Given a limit cone over `X` and `Y`, and another limit cone over `Y` and `X`, we can construct
an isomorphism between the cone points. Relative to some fixed choice of limits cones for every
pair, these isomorphisms constitute a braiding.
-/
def BinaryFan.braiding {X Y : C} {s : BinaryFan X Y} (P : IsLimit s) {t : BinaryFan Y X}
    (Q : IsLimit t) : s.x ≅ t.x :=
  IsLimit.conePointUniqueUpToIso Discrete Q.swapBinaryFan
#align category_theory.limits.binary_fan.braiding CategoryTheory.Limits.BinaryFan.braiding

/-- Given binary fans `sXY` over `X Y`, and `sYZ` over `Y Z`, and `s` over `sXY.X Z`,
if `sYZ` is a limit cone we can construct a binary fan over `X sYZ.X`.

This is an ingredient of building the associator for a cartesian category.
-/
def BinaryFan.assoc {X Y Z : Discrete} {sXY : BinaryFan X Discrete} {sYZ : BinaryFan Y Z}
    (Q : IsLimit sYZ) (s : BinaryFan sXY.x Z) : BinaryFan X sYZ.x :=
  BinaryFan.mk (s.fst ≫ sXY.fst) (Q.lift (BinaryFan.mk (s.fst ≫ sXY.snd) s.snd))
#align category_theory.limits.binary_fan.assoc CategoryTheory.Limits.BinaryFan.assoc

@[simp]
theorem BinaryFan.assoc_fst {X Y Z : C} {sXY : BinaryFan X Y} {sYZ : BinaryFan Y Z}
    (Q : IsLimit sYZ) (s : BinaryFan sXY.x Z) : (s.assoc Q).fst = s.fst ≫ sXY.fst :=
  rfl
#align category_theory.limits.binary_fan.assoc_fst CategoryTheory.Limits.BinaryFan.assoc_fst

@[simp]
theorem BinaryFan.assoc_snd {X Y Z : C} {sXY : BinaryFan X Y} {sYZ : BinaryFan Y Z}
    (Q : IsLimit sYZ) (s : BinaryFan sXY.x Z) :
    (s.assoc Q).snd = Q.lift (BinaryFan.mk (s.fst ≫ sXY.snd) s.snd) :=
  rfl
#align category_theory.limits.binary_fan.assoc_snd CategoryTheory.Limits.BinaryFan.assoc_snd

/-- Given binary fans `sXY` over `X Y`, and `sYZ` over `Y Z`, and `s` over `X sYZ.X`,
if `sYZ` is a limit cone we can construct a binary fan over `sXY.X Z`.

This is an ingredient of building the associator for a cartesian category.
-/
def BinaryFan.assocInv {X Y Z : C} {sXY : BinaryFan X Y} (P : IsLimit sXY) {sYZ : BinaryFan Y Z}
    (s : BinaryFan X sYZ.x) : BinaryFan sXY.x Z :=
  BinaryFan.mk (P.lift (BinaryFan.mk s.fst (s.snd ≫ sYZ.fst))) (s.snd ≫ sYZ.snd)
#align category_theory.limits.binary_fan.assoc_inv CategoryTheory.Limits.BinaryFan.assocInv

@[simp]
theorem BinaryFan.assocInv_fst {X Y Z : C} {sXY : BinaryFan X Y} (P : IsLimit sXY)
    {sYZ : BinaryFan Y Z} (s : BinaryFan X sYZ.x) :
    (s.assocInv P).fst = P.lift (BinaryFan.mk s.fst (s.snd ≫ sYZ.fst)) :=
  rfl
#align category_theory.limits.binary_fan.assoc_inv_fst CategoryTheory.Limits.BinaryFan.assocInv_fst

@[simp]
theorem BinaryFan.assocInv_snd {X Y Z : C} {sXY : BinaryFan X Y} (P : IsLimit sXY)
    {sYZ : BinaryFan Y Z} (s : BinaryFan X sYZ.x) : (s.assocInv P).snd = s.snd ≫ sYZ.snd :=
  rfl
#align category_theory.limits.binary_fan.assoc_inv_snd CategoryTheory.Limits.BinaryFan.assocInv_snd

/-- If all the binary fans involved a limit cones, `binary_fan.assoc` produces another limit cone.
-/
@[simps]
def IsLimit.assoc {X Y Z : C} {sXY : BinaryFan X Y} (P : IsLimit sXY) {sYZ : BinaryFan Y Z}
    (Q : IsLimit sYZ) {s : BinaryFan sXY.x Z} (R : IsLimit s) : IsLimit (s.assoc Q)
    where
  lift t := R.lift (BinaryFan.assocInv P t)
  fac' t := by
    rintro ⟨⟨⟩⟩ <;> simp
    apply Q.hom_ext
    rintro ⟨⟨⟩⟩ <;> simp
  uniq' t m w := by
    have h := R.uniq (BinaryFan.assocInv P t) m
    rw [h]
    rintro ⟨⟨⟩⟩ <;> simp
    apply P.hom_ext
    rintro ⟨⟨⟩⟩ <;> simp
    · exact w ⟨WalkingPair.left⟩
    · specialize w ⟨WalkingPair.right⟩
      simp at w
      rw [← w]
      simp
    · specialize w ⟨WalkingPair.right⟩
      simp at w
      rw [← w]
      simp
#align category_theory.limits.is_limit.assoc CategoryTheory.Limits.IsLimit.assoc

/-- Given two pairs of limit cones corresponding to the parenthesisations of `X × Y × Z`,
we obtain an isomorphism between the cone points.
-/
@[reducible]
def BinaryFan.associator {X Y Z : C} {sXY : BinaryFan X Y} (P : IsLimit sXY) {sYZ : BinaryFan Y Z}
    (Q : IsLimit sYZ) {s : BinaryFan sXY.x Z} (R : IsLimit s) {t : BinaryFan X sYZ.x}
    (S : IsLimit t) : s.x ≅ t.x :=
  IsLimit.conePointUniqueUpToIso (IsLimit.assoc P Q R) S
#align category_theory.limits.binary_fan.associator CategoryTheory.Limits.BinaryFan.associator

/-- Given a fixed family of limit data for every pair `X Y`, we obtain an associator.
-/
@[reducible]
def BinaryFan.associatorOfLimitCone (L : ∀ X Y : C, LimitCone (pair X Y)) (X Y Z : C) :
    (L (L X Y).cone.x Z).cone.x ≅ (L X (L Y Z).cone.x).cone.x :=
  BinaryFan.associator (L X Y).isLimit (L Y Z).isLimit (L (L X Y).cone.x Z).isLimit
    (L X (L Y Z).cone.x).isLimit
#align category_theory.limits.binary_fan.associator_of_limit_cone CategoryTheory.Limits.BinaryFan.associatorOfLimitCone

attribute [local tidy] tactic.discrete_cases

/-- Construct a left unitor from specified limit cones.
-/
@[simps]
def BinaryFan.leftUnitor {X : C} {s : Cone (Functor.empty.{v} C)} (P : IsLimit s)
    {t : BinaryFan s.x X} (Q : IsLimit t) : t.x ≅ X
    where
  Hom := t.snd
  inv :=
    Q.lift
      (BinaryFan.mk
        (P.lift
          { x
            π := { app := Discrete.rec (PEmpty.rec _) } })
        (𝟙 X))
  hom_inv_id' := by
    apply Q.hom_ext
    rintro ⟨⟨⟩⟩
    · apply P.hom_ext
      rintro ⟨⟨⟩⟩
    · simp
#align category_theory.limits.binary_fan.left_unitor CategoryTheory.Limits.BinaryFan.leftUnitor

/-- Construct a right unitor from specified limit cones.
-/
@[simps]
def BinaryFan.rightUnitor {X : C} {s : Cone (Functor.empty.{v} C)} (P : IsLimit s)
    {t : BinaryFan X s.x} (Q : IsLimit t) : t.x ≅ X
    where
  Hom := t.fst
  inv :=
    Q.lift
      (BinaryFan.mk (𝟙 X)
        (P.lift
          { x
            π := { app := Discrete.rec (PEmpty.rec _) } }))
  hom_inv_id' := by
    apply Q.hom_ext
    rintro ⟨⟨⟩⟩
    · simp
    · apply P.hom_ext
      rintro ⟨⟨⟩⟩
#align category_theory.limits.binary_fan.right_unitor CategoryTheory.Limits.BinaryFan.rightUnitor

end

end Limits

open CategoryTheory.Limits

section

attribute [local tidy] tactic.case_bash

variable {C}

variable (𝒯 : LimitCone (Functor.empty.{v} C))

variable (ℬ : ∀ X Y : C, LimitCone (pair X Y))

namespace MonoidalOfChosenFiniteProducts

/-- Implementation of the tensor product for `monoidal_of_chosen_finite_products`. -/
@[reducible]
def tensorObj (X Y : C) : C :=
  (ℬ X Y).cone.x
#align category_theory.monoidal_of_chosen_finite_products.tensor_obj CategoryTheory.MonoidalOfChosenFiniteProducts.tensorObj

/-- Implementation of the tensor product of morphisms for `monoidal_of_chosen_finite_products`. -/
@[reducible]
def tensorHom {W X Y Z : C} (f : W ⟶ X) (g : Y ⟶ Z) : tensorObj ℬ W Y ⟶ tensorObj ℬ X Z :=
  (BinaryFan.IsLimit.lift' (ℬ X Z).isLimit ((ℬ W Y).cone.π.app ⟨WalkingPair.left⟩ ≫ f)
      (((ℬ W Y).cone.π.app ⟨WalkingPair.right⟩ : (ℬ W Y).cone.x ⟶ Y) ≫ g)).val
#align category_theory.monoidal_of_chosen_finite_products.tensor_hom CategoryTheory.MonoidalOfChosenFiniteProducts.tensorHom

theorem tensor_id (X₁ X₂ : C) : tensorHom ℬ (𝟙 X₁) (𝟙 X₂) = 𝟙 (tensorObj ℬ X₁ X₂) := by
  apply IsLimit.hom_ext (ℬ _ _).isLimit;
  rintro ⟨⟨⟩⟩ <;>
    · dsimp [tensorHom]
      simp
#align category_theory.monoidal_of_chosen_finite_products.tensor_id CategoryTheory.MonoidalOfChosenFiniteProducts.tensor_id

theorem tensor_comp {X₁ Y₁ Z₁ X₂ Y₂ Z₂ : C} (f₁ : X₁ ⟶ Y₁) (f₂ : X₂ ⟶ Y₂) (g₁ : Y₁ ⟶ Z₁)
    (g₂ : Y₂ ⟶ Z₂) : tensorHom ℬ (f₁ ≫ g₁) (f₂ ≫ g₂) = tensorHom ℬ f₁ f₂ ≫ tensorHom ℬ g₁ g₂ := by
  apply IsLimit.hom_ext (ℬ _ _).isLimit;
  rintro ⟨⟨⟩⟩ <;>
    · dsimp [tensorHom]
      simp
#align category_theory.monoidal_of_chosen_finite_products.tensor_comp CategoryTheory.MonoidalOfChosenFiniteProducts.tensor_comp

theorem pentagon (W X Y Z : C) :
    tensorHom ℬ (BinaryFan.associatorOfLimitCone ℬ W X Y).hom (𝟙 Z) ≫
        (BinaryFan.associatorOfLimitCone ℬ W (tensorObj ℬ X Y) Z).hom ≫
          tensorHom ℬ (𝟙 W) (BinaryFan.associatorOfLimitCone ℬ X Y Z).hom =
      (BinaryFan.associatorOfLimitCone ℬ (tensorObj ℬ W X) Y Z).hom ≫
        (BinaryFan.associatorOfLimitCone ℬ W X (tensorObj ℬ Y Z)).hom :=
  by
  dsimp [tensorHom]
  apply IsLimit.hom_ext (ℬ _ _).isLimit; rintro ⟨⟨⟩⟩
  · simp
  · apply IsLimit.hom_ext (ℬ _ _).isLimit
    rintro ⟨⟨⟩⟩
    · simp
    apply IsLimit.hom_ext (ℬ _ _).isLimit
    rintro ⟨⟨⟩⟩
    · simp
    · simp
#align category_theory.monoidal_of_chosen_finite_products.pentagon CategoryTheory.MonoidalOfChosenFiniteProducts.pentagon

theorem triangle (X Y : C) :
    (BinaryFan.associatorOfLimitCone ℬ X 𝒯.cone.x Y).hom ≫
        tensorHom ℬ (𝟙 X) (BinaryFan.leftUnitor 𝒯.isLimit (ℬ 𝒯.cone.x Y).isLimit).hom =
      tensorHom ℬ (BinaryFan.rightUnitor 𝒯.isLimit (ℬ X 𝒯.cone.x).isLimit).hom (𝟙 Y) :=
  by
  dsimp [tensorHom]
  apply IsLimit.hom_ext (ℬ _ _).isLimit; rintro ⟨⟨⟩⟩ <;> simp
#align category_theory.monoidal_of_chosen_finite_products.triangle CategoryTheory.MonoidalOfChosenFiniteProducts.triangle

theorem leftUnitor_naturality {X₁ X₂ : C} (f : X₁ ⟶ X₂) :
    tensorHom ℬ (𝟙 𝒯.cone.x) f ≫ (BinaryFan.leftUnitor 𝒯.isLimit (ℬ 𝒯.cone.x X₂).isLimit).hom =
      (BinaryFan.leftUnitor 𝒯.isLimit (ℬ 𝒯.cone.x X₁).isLimit).hom ≫ f :=
  by
  dsimp [tensorHom]
  simp
#align category_theory.monoidal_of_chosen_finite_products.left_unitor_naturality CategoryTheory.MonoidalOfChosenFiniteProducts.leftUnitor_naturality

theorem rightUnitor_naturality {X₁ X₂ : C} (f : X₁ ⟶ X₂) :
    tensorHom ℬ f (𝟙 𝒯.cone.x) ≫ (BinaryFan.rightUnitor 𝒯.isLimit (ℬ X₂ 𝒯.cone.x).isLimit).hom =
      (BinaryFan.rightUnitor 𝒯.isLimit (ℬ X₁ 𝒯.cone.x).isLimit).hom ≫ f :=
  by
  dsimp [tensorHom]
  simp
#align category_theory.monoidal_of_chosen_finite_products.right_unitor_naturality CategoryTheory.MonoidalOfChosenFiniteProducts.rightUnitor_naturality

theorem associator_naturality {X₁ X₂ X₃ Y₁ Y₂ Y₃ : C} (f₁ : X₁ ⟶ Y₁) (f₂ : X₂ ⟶ Y₂) (f₃ : X₃ ⟶ Y₃) :
    tensorHom ℬ (tensorHom ℬ f₁ f₂) f₃ ≫ (BinaryFan.associatorOfLimitCone ℬ Y₁ Y₂ Y₃).hom =
      (BinaryFan.associatorOfLimitCone ℬ X₁ X₂ X₃).hom ≫ tensorHom ℬ f₁ (tensorHom ℬ f₂ f₃) :=
  by
  dsimp [tensorHom]
  apply IsLimit.hom_ext (ℬ _ _).isLimit; rintro ⟨⟨⟩⟩
  · simp
  · apply IsLimit.hom_ext (ℬ _ _).isLimit
    rintro ⟨⟨⟩⟩
    · simp
    · simp
#align category_theory.monoidal_of_chosen_finite_products.associator_naturality CategoryTheory.MonoidalOfChosenFiniteProducts.associator_naturality

end MonoidalOfChosenFiniteProducts

open MonoidalOfChosenFiniteProducts

/-- A category with a terminal object and binary products has a natural monoidal structure. -/
def monoidalOfChosenFiniteProducts : MonoidalCategory C
    where
  tensorUnit := 𝒯.cone.x
  tensorObj X Y := tensorObj ℬ X Y
  tensorHom _ _ _ _ f g := tensorHom ℬ f g
  tensor_id' := tensor_id ℬ
  tensor_comp' _ _ _ _ _ _ f₁ f₂ g₁ g₂ := tensor_comp ℬ f₁ f₂ g₁ g₂
  associator X Y Z := BinaryFan.associatorOfLimitCone ℬ X Y Z
  leftUnitor X := BinaryFan.leftUnitor 𝒯.IsLimit (ℬ 𝒯.cone.x X).isLimit
  rightUnitor X := BinaryFan.rightUnitor 𝒯.IsLimit (ℬ X 𝒯.cone.x).isLimit
  pentagon' := pentagon ℬ
  triangle' := triangle 𝒯 ℬ
  leftUnitor_naturality' _ _ f := leftUnitor_naturality 𝒯 ℬ f
  rightUnitor_naturality' _ _ f := rightUnitor_naturality 𝒯 ℬ f
  associator_naturality' _ _ _ _ _ _ f₁ f₂ f₃ := associator_naturality ℬ f₁ f₂ f₃
#align category_theory.monoidal_of_chosen_finite_products CategoryTheory.monoidalOfChosenFiniteProducts

namespace MonoidalOfChosenFiniteProducts

open MonoidalCategory

/-- A type synonym for `C` carrying a monoidal category structure corresponding to
a fixed choice of limit data for the empty functor, and for `pair X Y` for every `X Y : C`.

This is an implementation detail for `symmetric_of_chosen_finite_products`.
-/
@[nolint unused_arguments has_nonempty_instance]
def MonoidalOfChosenFiniteProductsSynonym (𝒯 : LimitCone (Functor.empty.{v} C))
    (ℬ : ∀ X Y : C, LimitCone (pair X Y)) :=
  C deriving Category
#align category_theory.monoidal_of_chosen_finite_products.monoidal_of_chosen_finite_products_synonym CategoryTheory.monoidalOfChosenFiniteProducts.MonoidalOfChosenFiniteProductsSynonym

instance : MonoidalCategory (MonoidalOfChosenFiniteProductsSynonym 𝒯 ℬ) :=
  monoidalOfChosenFiniteProducts 𝒯 ℬ

theorem braiding_naturality {X X' Y Y' : C} (f : X ⟶ Y) (g : X' ⟶ Y') :
    tensorHom ℬ f g ≫ (Limits.BinaryFan.braiding (ℬ Y Y').isLimit (ℬ Y' Y).isLimit).hom =
      (Limits.BinaryFan.braiding (ℬ X X').isLimit (ℬ X' X).isLimit).hom ≫ tensorHom ℬ g f :=
  by
  dsimp [tensorHom, Limits.BinaryFan.braiding]
  apply (ℬ _ _).isLimit.hom_ext;
  rintro ⟨⟨⟩⟩ <;>
    · dsimp [Limits.IsLimit.conePointUniqueUpToIso]
      simp
#align category_theory.monoidal_of_chosen_finite_products.braiding_naturality CategoryTheory.monoidalOfChosenFiniteProducts.braiding_naturality

theorem hexagon_forward (X Y Z : C) :
    (BinaryFan.associatorOfLimitCone ℬ X Y Z).hom ≫
        (Limits.BinaryFan.braiding (ℬ X (tensorObj ℬ Y Z)).isLimit
              (ℬ (tensorObj ℬ Y Z) X).isLimit).hom ≫
          (BinaryFan.associatorOfLimitCone ℬ Y Z X).hom =
      tensorHom ℬ (Limits.BinaryFan.braiding (ℬ X Y).isLimit (ℬ Y X).isLimit).hom (𝟙 Z) ≫
        (BinaryFan.associatorOfLimitCone ℬ Y X Z).hom ≫
          tensorHom ℬ (𝟙 Y) (Limits.BinaryFan.braiding (ℬ X Z).isLimit (ℬ Z X).isLimit).hom :=
  by
  dsimp [tensorHom, Limits.BinaryFan.braiding]
  apply (ℬ _ _).isLimit.hom_ext; rintro ⟨⟨⟩⟩
  · dsimp [Limits.IsLimit.conePointUniqueUpToIso]
    simp
  · apply (ℬ _ _).isLimit.hom_ext
    rintro ⟨⟨⟩⟩ <;>
      · dsimp [Limits.IsLimit.conePointUniqueUpToIso]
        simp
#align category_theory.monoidal_of_chosen_finite_products.hexagon_forward CategoryTheory.monoidalOfChosenFiniteProducts.hexagon_forward

theorem hexagon_reverse (X Y Z : C) :
    (BinaryFan.associatorOfLimitCone ℬ X Y Z).inv ≫
        (Limits.BinaryFan.braiding (ℬ (tensorObj ℬ X Y) Z).isLimit
              (ℬ Z (tensorObj ℬ X Y)).isLimit).hom ≫
          (BinaryFan.associatorOfLimitCone ℬ Z X Y).inv =
      tensorHom ℬ (𝟙 X) (Limits.BinaryFan.braiding (ℬ Y Z).isLimit (ℬ Z Y).isLimit).hom ≫
        (BinaryFan.associatorOfLimitCone ℬ X Z Y).inv ≫
          tensorHom ℬ (Limits.BinaryFan.braiding (ℬ X Z).isLimit (ℬ Z X).isLimit).hom (𝟙 Y) :=
  by
  dsimp [tensorHom, Limits.BinaryFan.braiding]
  apply (ℬ _ _).isLimit.hom_ext; rintro ⟨⟨⟩⟩
  · apply (ℬ _ _).isLimit.hom_ext
    rintro ⟨⟨⟩⟩ <;>
      · dsimp [BinaryFan.associatorOfLimitCone, BinaryFan.associator,
          Limits.IsLimit.conePointUniqueUpToIso]
        simp
  · dsimp [BinaryFan.associatorOfLimitCone, BinaryFan.associator,
      Limits.IsLimit.conePointUniqueUpToIso]
    simp
#align category_theory.monoidal_of_chosen_finite_products.hexagon_reverse CategoryTheory.monoidalOfChosenFiniteProducts.hexagon_reverse

theorem symmetry (X Y : C) :
    (Limits.BinaryFan.braiding (ℬ X Y).isLimit (ℬ Y X).isLimit).hom ≫
        (Limits.BinaryFan.braiding (ℬ Y X).isLimit (ℬ X Y).isLimit).hom =
      𝟙 (tensorObj ℬ X Y) :=
  by
  dsimp [tensorHom, Limits.BinaryFan.braiding]
  apply (ℬ _ _).isLimit.hom_ext;
  rintro ⟨⟨⟩⟩ <;>
    · dsimp [Limits.IsLimit.conePointUniqueUpToIso]
      simp
#align category_theory.monoidal_of_chosen_finite_products.symmetry CategoryTheory.monoidalOfChosenFiniteProducts.symmetry

end MonoidalOfChosenFiniteProducts

open MonoidalOfChosenFiniteProducts

/-- The monoidal structure coming from finite products is symmetric.
-/
def symmetricOfChosenFiniteProducts : SymmetricCategory (MonoidalOfChosenFiniteProductsSynonym 𝒯 ℬ)
    where
  braiding X Y := Limits.BinaryFan.braiding (ℬ _ _).isLimit (ℬ _ _).isLimit
  braiding_naturality' X X' Y Y' f g := braiding_naturality ℬ f g
  hexagon_forward' X Y Z := hexagon_forward ℬ X Y Z
  hexagon_reverse' X Y Z := hexagon_reverse ℬ X Y Z
  symmetry' X Y := symmetry ℬ X Y
#align category_theory.symmetric_of_chosen_finite_products CategoryTheory.symmetricOfChosenFiniteProducts

end

end CategoryTheory

