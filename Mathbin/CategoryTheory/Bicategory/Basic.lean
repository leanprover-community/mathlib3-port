/-
Copyright (c) 2021 Yuma Mizuno. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yuma Mizuno
-/
import CategoryTheory.Isomorphism
import Tactic.Slice

#align_import category_theory.bicategory.basic from "leanprover-community/mathlib"@"3e32bc908f617039c74c06ea9a897e30c30803c2"

/-!
# Bicategories

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define typeclass for bicategories.

A bicategory `B` consists of
* objects `a : B`,
* 1-morphisms `f : a ⟶ b` between objects `a b : B`, and
* 2-morphisms `η : f ⟶ g` beween 1-morphisms `f g : a ⟶ b` between objects `a b : B`.

We use `u`, `v`, and `w` as the universe variables for objects, 1-morphisms, and 2-morphisms,
respectively.

A typeclass for bicategories extends `category_theory.category_struct` typeclass. This means that
we have
* a composition `f ≫ g : a ⟶ c` for each 1-morphisms `f : a ⟶ b` and `g : b ⟶ c`, and
* a identity `𝟙 a : a ⟶ a` for each object `a : B`.

For each object `a b : B`, the collection of 1-morphisms `a ⟶ b` has a category structure. The
2-morphisms in the bicategory are implemented as the morphisms in this family of categories.

The composition of 1-morphisms is in fact a object part of a functor
`(a ⟶ b) ⥤ (b ⟶ c) ⥤ (a ⟶ c)`. The definition of bicategories in this file does not
require this functor directly. Instead, it requires the whiskering functions. For a 1-morphism
`f : a ⟶ b` and a 2-morphism `η : g ⟶ h` between 1-morphisms `g h : b ⟶ c`, there is a
2-morphism `whisker_left f η : f ≫ g ⟶ f ≫ h`. Similarly, for a 2-morphism `η : f ⟶ g`
between 1-morphisms `f g : a ⟶ b` and a 1-morphism `f : b ⟶ c`, there is a 2-morphism
`whisker_right η h : f ≫ h ⟶ g ≫ h`. These satisfy the exchange law
`whisker_left f θ ≫ whisker_right η i = whisker_right η h ≫ whisker_left g θ`,
which is required as an axiom in the definition here.
-/


namespace CategoryTheory

universe w v u

open Category Iso

#print CategoryTheory.Bicategory /-
/- ./././Mathport/Syntax/Translate/Command.lean:413:24: unsupported: (notation) in structure -/
/- ./././Mathport/Syntax/Translate/Command.lean:413:24: unsupported: (notation) in structure -/
/- ./././Mathport/Syntax/Translate/Command.lean:413:24: unsupported: (notation) in structure -/
/- ./././Mathport/Syntax/Translate/Command.lean:413:24: unsupported: (notation) in structure -/
/- ./././Mathport/Syntax/Translate/Command.lean:413:24: unsupported: (notation) in structure -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ◁ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ◁ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ◁ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ◁ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ◁ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«exprλ_» -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«exprλ_» -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ◁ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `exprα_ -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ◁ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ◁ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `exprα_ -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ▷ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ▷ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ▷ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ▷ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ▷ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `exprρ_ -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `exprρ_ -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ▷ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `exprα_ -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ▷ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ▷ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `exprα_ -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ▷ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ◁ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `exprα_ -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ◁ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ▷ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `exprα_ -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ◁ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ▷ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ▷ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ◁ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ▷ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `exprα_ -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `exprα_ -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ◁ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `exprα_ -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `exprα_ -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `exprα_ -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `exprα_ -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ◁ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«exprλ_» -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `«expr ▷ » -/
/- ./././Mathport/Syntax/Translate/Expr.lean:207:4: warning: unsupported notation `exprρ_ -/
-- intended to be used with explicit universe parameters
/-- In a bicategory, we can compose the 1-morphisms `f : a ⟶ b` and `g : b ⟶ c` to obtain
a 1-morphism `f ≫ g : a ⟶ c`. This composition does not need to be strictly associative,
but there is a specified associator, `α_ f g h : (f ≫ g) ≫ h ≅ f ≫ (g ≫ h)`.
There is an identity 1-morphism `𝟙 a : a ⟶ a`, with specified left and right unitor
isomorphisms `λ_ f : 𝟙 a ≫ f ≅ f` and `ρ_ f : f ≫ 𝟙 a ≅ f`.
These associators and unitors satisfy the pentagon and triangle equations.

See https://ncatlab.org/nlab/show/bicategory.
-/
@[nolint check_univs]
class Bicategory (B : Type u) extends CategoryStruct.{v} B where
  -- category structure on the collection of 1-morphisms:
  homCategory : ∀ a b : B, Category.{w} (a ⟶ b) := by infer_instance
  -- left whiskering:
  whiskerLeft {a b c : B} (f : a ⟶ b) {g h : b ⟶ c} (η : g ⟶ h) : f ≫ g ⟶ f ≫ h
  -- right whiskering:
  whiskerRight {a b c : B} {f g : a ⟶ b} (η : f ⟶ g) (h : b ⟶ c) : f ≫ h ⟶ g ≫ h
  -- associator:
  associator {a b c d : B} (f : a ⟶ b) (g : b ⟶ c) (h : c ⟶ d) : (f ≫ g) ≫ h ≅ f ≫ g ≫ h
  -- left unitor:
  leftUnitor {a b : B} (f : a ⟶ b) : 𝟙 a ≫ f ≅ f
  -- right unitor:
  rightUnitor {a b : B} (f : a ⟶ b) : f ≫ 𝟙 b ≅ f
  -- axioms for left whiskering:
  whiskerLeft_id : ∀ {a b c} (f : a ⟶ b) (g : b ⟶ c), «expr ◁ » f (𝟙 g) = 𝟙 (f ≫ g) := by obviously
  whiskerLeft_comp :
    ∀ {a b c} (f : a ⟶ b) {g h i : b ⟶ c} (η : g ⟶ h) (θ : h ⟶ i),
      «expr ◁ » f (η ≫ θ) = «expr ◁ » f η ≫ «expr ◁ » f θ := by
    obviously
  id_whiskerLeft :
    ∀ {a b} {f g : a ⟶ b} (η : f ⟶ g),
      «expr ◁ » (𝟙 a) η = ((«exprλ_») f).Hom ≫ η ≫ ((«exprλ_») g).inv := by
    obviously
  comp_whiskerLeft :
    ∀ {a b c d} (f : a ⟶ b) (g : b ⟶ c) {h h' : c ⟶ d} (η : h ⟶ h'),
      «expr ◁ » (f ≫ g) η =
        ((exprα_) f g h).Hom ≫ «expr ◁ » f («expr ◁ » g η) ≫ ((exprα_) f g h').inv := by
    obviously
  -- axioms for right whiskering:
  id_whiskerRight : ∀ {a b c} (f : a ⟶ b) (g : b ⟶ c), «expr ▷ » (𝟙 f) g = 𝟙 (f ≫ g) := by obviously
  comp_whiskerRight :
    ∀ {a b c} {f g h : a ⟶ b} (η : f ⟶ g) (θ : g ⟶ h) (i : b ⟶ c),
      «expr ▷ » (η ≫ θ) i = «expr ▷ » η i ≫ «expr ▷ » θ i := by
    obviously
  whiskerRight_id :
    ∀ {a b} {f g : a ⟶ b} (η : f ⟶ g),
      «expr ▷ » η (𝟙 b) = ((exprρ_) f).Hom ≫ η ≫ ((exprρ_) g).inv := by
    obviously
  whiskerRight_comp :
    ∀ {a b c d} {f f' : a ⟶ b} (η : f ⟶ f') (g : b ⟶ c) (h : c ⟶ d),
      «expr ▷ » η (g ≫ h) =
        ((exprα_) f g h).inv ≫ «expr ▷ » («expr ▷ » η g) h ≫ ((exprα_) f' g h).Hom := by
    obviously
  -- associativity of whiskerings:
  whisker_assoc :
    ∀ {a b c d} (f : a ⟶ b) {g g' : b ⟶ c} (η : g ⟶ g') (h : c ⟶ d),
      «expr ▷ » («expr ◁ » f η) h =
        ((exprα_) f g h).Hom ≫ «expr ◁ » f («expr ▷ » η h) ≫ ((exprα_) f g' h).inv := by
    obviously
  -- exchange law of left and right whiskerings:
  whisker_exchange :
    ∀ {a b c} {f g : a ⟶ b} {h i : b ⟶ c} (η : f ⟶ g) (θ : h ⟶ i),
      «expr ◁ » f θ ≫ «expr ▷ » η i = «expr ▷ » η h ≫ «expr ◁ » g θ := by
    obviously
  -- pentagon identity:
  pentagon :
    ∀ {a b c d e} (f : a ⟶ b) (g : b ⟶ c) (h : c ⟶ d) (i : d ⟶ e),
      «expr ▷ » ((exprα_) f g h).Hom i ≫
          ((exprα_) f (g ≫ h) i).Hom ≫ «expr ◁ » f ((exprα_) g h i).Hom =
        ((exprα_) (f ≫ g) h i).Hom ≫ ((exprα_) f g (h ≫ i)).Hom := by
    obviously
  -- triangle identity:
  triangle :
    ∀ {a b c} (f : a ⟶ b) (g : b ⟶ c),
      ((exprα_) f (𝟙 b) g).Hom ≫ «expr ◁ » f ((«exprλ_») g).Hom = «expr ▷ » ((exprρ_) f).Hom g := by
    obviously
#align category_theory.bicategory CategoryTheory.Bicategory
-/

-- The precedence of the whiskerings is higher than that of the composition `≫`.
scoped[Bicategory] infixr:81 " ◁ " => Bicategory.whiskerLeft

scoped[Bicategory] infixl:81 " ▷ " => Bicategory.whiskerRight

scoped[Bicategory] notation "α_" => Bicategory.associator

scoped[Bicategory] notation "λ_" => Bicategory.leftUnitor

scoped[Bicategory] notation "ρ_" => Bicategory.rightUnitor

namespace Bicategory

/-!
### Simp-normal form for 2-morphisms

Rewriting involving associators and unitors could be very complicated. We try to ease this
complexity by putting carefully chosen simp lemmas that rewrite any 2-morphisms into simp-normal
form defined below. Rewriting into simp-normal form is also useful when applying (forthcoming)
`coherence` tactic.

The simp-normal form of 2-morphisms is defined to be an expression that has the minimal number of
parentheses. More precisely,
1. it is a composition of 2-morphisms like `η₁ ≫ η₂ ≫ η₃ ≫ η₄ ≫ η₅` such that each `ηᵢ` is
  either a structural 2-morphisms (2-morphisms made up only of identities, associators, unitors)
  or non-structural 2-morphisms, and
2. each non-structural 2-morphism in the composition is of the form `f₁ ◁ f₂ ◁ f₃ ◁ η ▷ f₄ ▷ f₅`,
  where each `fᵢ` is a 1-morphism that is not the identity or a composite and `η` is a
  non-structural 2-morphisms that is also not the identity or a composite.

Note that `f₁ ◁ f₂ ◁ f₃ ◁ η ▷ f₄ ▷ f₅` is actually `f₁ ◁ (f₂ ◁ (f₃ ◁ ((η ▷ f₄) ▷ f₅)))`.
-/


attribute [simp] pentagon triangle

attribute [reassoc] whisker_left_comp id_whisker_left comp_whisker_left comp_whisker_right
  whisker_right_id whisker_right_comp whisker_assoc whisker_exchange pentagon triangle

/-
The following simp attributes are put in order to rewrite any 2-morphisms into normal forms. There
are associators and unitors in the RHS in the several simp lemmas here (e.g. `id_whisker_left`),
which at first glance look more complicated than the LHS, but they will be eventually reduced by the
pentagon or the triangle identities, and more generally, (forthcoming) `coherence` tactic.
-/
attribute [simp] whisker_left_id whisker_left_comp id_whisker_left comp_whisker_left
  id_whisker_right comp_whisker_right whisker_right_id whisker_right_comp whisker_assoc

attribute [instance] hom_category

variable {B : Type u} [Bicategory.{w, v} B] {a b c d e : B}

#print CategoryTheory.Bicategory.whiskerLeft_hom_inv /-
@[simp, reassoc]
theorem whiskerLeft_hom_inv (f : a ⟶ b) {g h : b ⟶ c} (η : g ≅ h) :
    f ◁ η.Hom ≫ f ◁ η.inv = 𝟙 (f ≫ g) := by rw [← whisker_left_comp, hom_inv_id, whisker_left_id]
#align category_theory.bicategory.hom_inv_whisker_left CategoryTheory.Bicategory.whiskerLeft_hom_inv
-/

#print CategoryTheory.Bicategory.hom_inv_whiskerRight /-
@[simp, reassoc]
theorem hom_inv_whiskerRight {f g : a ⟶ b} (η : f ≅ g) (h : b ⟶ c) :
    η.Hom ▷ h ≫ η.inv ▷ h = 𝟙 (f ≫ h) := by rw [← comp_whisker_right, hom_inv_id, id_whisker_right]
#align category_theory.bicategory.hom_inv_whisker_right CategoryTheory.Bicategory.hom_inv_whiskerRight
-/

#print CategoryTheory.Bicategory.whiskerLeft_inv_hom /-
@[simp, reassoc]
theorem whiskerLeft_inv_hom (f : a ⟶ b) {g h : b ⟶ c} (η : g ≅ h) :
    f ◁ η.inv ≫ f ◁ η.Hom = 𝟙 (f ≫ h) := by rw [← whisker_left_comp, inv_hom_id, whisker_left_id]
#align category_theory.bicategory.inv_hom_whisker_left CategoryTheory.Bicategory.whiskerLeft_inv_hom
-/

#print CategoryTheory.Bicategory.inv_hom_whiskerRight /-
@[simp, reassoc]
theorem inv_hom_whiskerRight {f g : a ⟶ b} (η : f ≅ g) (h : b ⟶ c) :
    η.inv ▷ h ≫ η.Hom ▷ h = 𝟙 (g ≫ h) := by rw [← comp_whisker_right, inv_hom_id, id_whisker_right]
#align category_theory.bicategory.inv_hom_whisker_right CategoryTheory.Bicategory.inv_hom_whiskerRight
-/

#print CategoryTheory.Bicategory.whiskerLeftIso /-
/-- The left whiskering of a 2-isomorphism is a 2-isomorphism. -/
@[simps]
def whiskerLeftIso (f : a ⟶ b) {g h : b ⟶ c} (η : g ≅ h) : f ≫ g ≅ f ≫ h
    where
  Hom := f ◁ η.Hom
  inv := f ◁ η.inv
#align category_theory.bicategory.whisker_left_iso CategoryTheory.Bicategory.whiskerLeftIso
-/

#print CategoryTheory.Bicategory.whiskerLeft_isIso /-
instance whiskerLeft_isIso (f : a ⟶ b) {g h : b ⟶ c} (η : g ⟶ h) [IsIso η] : IsIso (f ◁ η) :=
  IsIso.of_iso (whiskerLeftIso f (asIso η))
#align category_theory.bicategory.whisker_left_is_iso CategoryTheory.Bicategory.whiskerLeft_isIso
-/

#print CategoryTheory.Bicategory.inv_whiskerLeft /-
@[simp]
theorem inv_whiskerLeft (f : a ⟶ b) {g h : b ⟶ c} (η : g ⟶ h) [IsIso η] : inv (f ◁ η) = f ◁ inv η :=
  by ext; simp only [← whisker_left_comp, whisker_left_id, is_iso.hom_inv_id]
#align category_theory.bicategory.inv_whisker_left CategoryTheory.Bicategory.inv_whiskerLeft
-/

#print CategoryTheory.Bicategory.whiskerRightIso /-
/-- The right whiskering of a 2-isomorphism is a 2-isomorphism. -/
@[simps]
def whiskerRightIso {f g : a ⟶ b} (η : f ≅ g) (h : b ⟶ c) : f ≫ h ≅ g ≫ h
    where
  Hom := η.Hom ▷ h
  inv := η.inv ▷ h
#align category_theory.bicategory.whisker_right_iso CategoryTheory.Bicategory.whiskerRightIso
-/

#print CategoryTheory.Bicategory.whiskerRight_isIso /-
instance whiskerRight_isIso {f g : a ⟶ b} (η : f ⟶ g) (h : b ⟶ c) [IsIso η] : IsIso (η ▷ h) :=
  IsIso.of_iso (whiskerRightIso (asIso η) h)
#align category_theory.bicategory.whisker_right_is_iso CategoryTheory.Bicategory.whiskerRight_isIso
-/

#print CategoryTheory.Bicategory.inv_whiskerRight /-
@[simp]
theorem inv_whiskerRight {f g : a ⟶ b} (η : f ⟶ g) (h : b ⟶ c) [IsIso η] :
    inv (η ▷ h) = inv η ▷ h := by ext;
  simp only [← comp_whisker_right, id_whisker_right, is_iso.hom_inv_id]
#align category_theory.bicategory.inv_whisker_right CategoryTheory.Bicategory.inv_whiskerRight
-/

#print CategoryTheory.Bicategory.pentagon_inv /-
@[simp, reassoc]
theorem pentagon_inv (f : a ⟶ b) (g : b ⟶ c) (h : c ⟶ d) (i : d ⟶ e) :
    f ◁ (α_ g h i).inv ≫ (α_ f (g ≫ h) i).inv ≫ (α_ f g h).inv ▷ i =
      (α_ f g (h ≫ i)).inv ≫ (α_ (f ≫ g) h i).inv :=
  eq_of_inv_eq_inv (by simp)
#align category_theory.bicategory.pentagon_inv CategoryTheory.Bicategory.pentagon_inv
-/

#print CategoryTheory.Bicategory.pentagon_inv_inv_hom_hom_inv /-
@[simp, reassoc]
theorem pentagon_inv_inv_hom_hom_inv (f : a ⟶ b) (g : b ⟶ c) (h : c ⟶ d) (i : d ⟶ e) :
    (α_ f (g ≫ h) i).inv ≫ (α_ f g h).inv ▷ i ≫ (α_ (f ≫ g) h i).Hom =
      f ◁ (α_ g h i).Hom ≫ (α_ f g (h ≫ i)).inv :=
  by rw [← cancel_epi (f ◁ (α_ g h i).inv), ← cancel_mono (α_ (f ≫ g) h i).inv]; simp
#align category_theory.bicategory.pentagon_inv_inv_hom_hom_inv CategoryTheory.Bicategory.pentagon_inv_inv_hom_hom_inv
-/

#print CategoryTheory.Bicategory.pentagon_inv_hom_hom_hom_inv /-
@[simp, reassoc]
theorem pentagon_inv_hom_hom_hom_inv (f : a ⟶ b) (g : b ⟶ c) (h : c ⟶ d) (i : d ⟶ e) :
    (α_ (f ≫ g) h i).inv ≫ (α_ f g h).Hom ▷ i ≫ (α_ f (g ≫ h) i).Hom =
      (α_ f g (h ≫ i)).Hom ≫ f ◁ (α_ g h i).inv :=
  eq_of_inv_eq_inv (by simp)
#align category_theory.bicategory.pentagon_inv_hom_hom_hom_inv CategoryTheory.Bicategory.pentagon_inv_hom_hom_hom_inv
-/

#print CategoryTheory.Bicategory.pentagon_hom_inv_inv_inv_inv /-
@[simp, reassoc]
theorem pentagon_hom_inv_inv_inv_inv (f : a ⟶ b) (g : b ⟶ c) (h : c ⟶ d) (i : d ⟶ e) :
    f ◁ (α_ g h i).Hom ≫ (α_ f g (h ≫ i)).inv ≫ (α_ (f ≫ g) h i).inv =
      (α_ f (g ≫ h) i).inv ≫ (α_ f g h).inv ▷ i :=
  by simp [← cancel_epi (f ◁ (α_ g h i).inv)]
#align category_theory.bicategory.pentagon_hom_inv_inv_inv_inv CategoryTheory.Bicategory.pentagon_hom_inv_inv_inv_inv
-/

#print CategoryTheory.Bicategory.pentagon_hom_hom_inv_hom_hom /-
@[simp, reassoc]
theorem pentagon_hom_hom_inv_hom_hom (f : a ⟶ b) (g : b ⟶ c) (h : c ⟶ d) (i : d ⟶ e) :
    (α_ (f ≫ g) h i).Hom ≫ (α_ f g (h ≫ i)).Hom ≫ f ◁ (α_ g h i).inv =
      (α_ f g h).Hom ▷ i ≫ (α_ f (g ≫ h) i).Hom :=
  eq_of_inv_eq_inv (by simp)
#align category_theory.bicategory.pentagon_hom_hom_inv_hom_hom CategoryTheory.Bicategory.pentagon_hom_hom_inv_hom_hom
-/

#print CategoryTheory.Bicategory.pentagon_hom_inv_inv_inv_hom /-
@[simp, reassoc]
theorem pentagon_hom_inv_inv_inv_hom (f : a ⟶ b) (g : b ⟶ c) (h : c ⟶ d) (i : d ⟶ e) :
    (α_ f g (h ≫ i)).Hom ≫ f ◁ (α_ g h i).inv ≫ (α_ f (g ≫ h) i).inv =
      (α_ (f ≫ g) h i).inv ≫ (α_ f g h).Hom ▷ i :=
  by rw [← cancel_epi (α_ f g (h ≫ i)).inv, ← cancel_mono ((α_ f g h).inv ▷ i)]; simp
#align category_theory.bicategory.pentagon_hom_inv_inv_inv_hom CategoryTheory.Bicategory.pentagon_hom_inv_inv_inv_hom
-/

#print CategoryTheory.Bicategory.pentagon_hom_hom_inv_inv_hom /-
@[simp, reassoc]
theorem pentagon_hom_hom_inv_inv_hom (f : a ⟶ b) (g : b ⟶ c) (h : c ⟶ d) (i : d ⟶ e) :
    (α_ f (g ≫ h) i).Hom ≫ f ◁ (α_ g h i).Hom ≫ (α_ f g (h ≫ i)).inv =
      (α_ f g h).inv ▷ i ≫ (α_ (f ≫ g) h i).Hom :=
  eq_of_inv_eq_inv (by simp)
#align category_theory.bicategory.pentagon_hom_hom_inv_inv_hom CategoryTheory.Bicategory.pentagon_hom_hom_inv_inv_hom
-/

#print CategoryTheory.Bicategory.pentagon_inv_hom_hom_hom_hom /-
@[simp, reassoc]
theorem pentagon_inv_hom_hom_hom_hom (f : a ⟶ b) (g : b ⟶ c) (h : c ⟶ d) (i : d ⟶ e) :
    (α_ f g h).inv ▷ i ≫ (α_ (f ≫ g) h i).Hom ≫ (α_ f g (h ≫ i)).Hom =
      (α_ f (g ≫ h) i).Hom ≫ f ◁ (α_ g h i).Hom :=
  by simp [← cancel_epi ((α_ f g h).Hom ▷ i)]
#align category_theory.bicategory.pentagon_inv_hom_hom_hom_hom CategoryTheory.Bicategory.pentagon_inv_hom_hom_hom_hom
-/

#print CategoryTheory.Bicategory.pentagon_inv_inv_hom_inv_inv /-
@[simp, reassoc]
theorem pentagon_inv_inv_hom_inv_inv (f : a ⟶ b) (g : b ⟶ c) (h : c ⟶ d) (i : d ⟶ e) :
    (α_ f g (h ≫ i)).inv ≫ (α_ (f ≫ g) h i).inv ≫ (α_ f g h).Hom ▷ i =
      f ◁ (α_ g h i).inv ≫ (α_ f (g ≫ h) i).inv :=
  eq_of_inv_eq_inv (by simp)
#align category_theory.bicategory.pentagon_inv_inv_hom_inv_inv CategoryTheory.Bicategory.pentagon_inv_inv_hom_inv_inv
-/

#print CategoryTheory.Bicategory.triangle_assoc_comp_left /-
theorem triangle_assoc_comp_left (f : a ⟶ b) (g : b ⟶ c) :
    (α_ f (𝟙 b) g).Hom ≫ f ◁ (λ_ g).Hom = (ρ_ f).Hom ▷ g :=
  triangle f g
#align category_theory.bicategory.triangle_assoc_comp_left CategoryTheory.Bicategory.triangle_assoc_comp_left
-/

#print CategoryTheory.Bicategory.triangle_assoc_comp_right /-
@[simp, reassoc]
theorem triangle_assoc_comp_right (f : a ⟶ b) (g : b ⟶ c) :
    (α_ f (𝟙 b) g).inv ≫ (ρ_ f).Hom ▷ g = f ◁ (λ_ g).Hom := by rw [← triangle, inv_hom_id_assoc]
#align category_theory.bicategory.triangle_assoc_comp_right CategoryTheory.Bicategory.triangle_assoc_comp_right
-/

#print CategoryTheory.Bicategory.triangle_assoc_comp_right_inv /-
@[simp, reassoc]
theorem triangle_assoc_comp_right_inv (f : a ⟶ b) (g : b ⟶ c) :
    (ρ_ f).inv ▷ g ≫ (α_ f (𝟙 b) g).Hom = f ◁ (λ_ g).inv := by simp [← cancel_mono (f ◁ (λ_ g).Hom)]
#align category_theory.bicategory.triangle_assoc_comp_right_inv CategoryTheory.Bicategory.triangle_assoc_comp_right_inv
-/

#print CategoryTheory.Bicategory.triangle_assoc_comp_left_inv /-
@[simp, reassoc]
theorem triangle_assoc_comp_left_inv (f : a ⟶ b) (g : b ⟶ c) :
    f ◁ (λ_ g).inv ≫ (α_ f (𝟙 b) g).inv = (ρ_ f).inv ▷ g := by simp [← cancel_mono ((ρ_ f).Hom ▷ g)]
#align category_theory.bicategory.triangle_assoc_comp_left_inv CategoryTheory.Bicategory.triangle_assoc_comp_left_inv
-/

#print CategoryTheory.Bicategory.associator_naturality_left /-
@[reassoc]
theorem associator_naturality_left {f f' : a ⟶ b} (η : f ⟶ f') (g : b ⟶ c) (h : c ⟶ d) :
    η ▷ g ▷ h ≫ (α_ f' g h).Hom = (α_ f g h).Hom ≫ η ▷ (g ≫ h) := by simp
#align category_theory.bicategory.associator_naturality_left CategoryTheory.Bicategory.associator_naturality_left
-/

#print CategoryTheory.Bicategory.associator_inv_naturality_left /-
@[reassoc]
theorem associator_inv_naturality_left {f f' : a ⟶ b} (η : f ⟶ f') (g : b ⟶ c) (h : c ⟶ d) :
    η ▷ (g ≫ h) ≫ (α_ f' g h).inv = (α_ f g h).inv ≫ η ▷ g ▷ h := by simp
#align category_theory.bicategory.associator_inv_naturality_left CategoryTheory.Bicategory.associator_inv_naturality_left
-/

#print CategoryTheory.Bicategory.whiskerRight_comp_symm /-
@[reassoc]
theorem whiskerRight_comp_symm {f f' : a ⟶ b} (η : f ⟶ f') (g : b ⟶ c) (h : c ⟶ d) :
    η ▷ g ▷ h = (α_ f g h).Hom ≫ η ▷ (g ≫ h) ≫ (α_ f' g h).inv := by simp
#align category_theory.bicategory.whisker_right_comp_symm CategoryTheory.Bicategory.whiskerRight_comp_symm
-/

#print CategoryTheory.Bicategory.associator_naturality_middle /-
@[reassoc]
theorem associator_naturality_middle (f : a ⟶ b) {g g' : b ⟶ c} (η : g ⟶ g') (h : c ⟶ d) :
    (f ◁ η) ▷ h ≫ (α_ f g' h).Hom = (α_ f g h).Hom ≫ f ◁ η ▷ h := by simp
#align category_theory.bicategory.associator_naturality_middle CategoryTheory.Bicategory.associator_naturality_middle
-/

#print CategoryTheory.Bicategory.associator_inv_naturality_middle /-
@[reassoc]
theorem associator_inv_naturality_middle (f : a ⟶ b) {g g' : b ⟶ c} (η : g ⟶ g') (h : c ⟶ d) :
    f ◁ η ▷ h ≫ (α_ f g' h).inv = (α_ f g h).inv ≫ (f ◁ η) ▷ h := by simp
#align category_theory.bicategory.associator_inv_naturality_middle CategoryTheory.Bicategory.associator_inv_naturality_middle
-/

#print CategoryTheory.Bicategory.whisker_assoc_symm /-
@[reassoc]
theorem whisker_assoc_symm (f : a ⟶ b) {g g' : b ⟶ c} (η : g ⟶ g') (h : c ⟶ d) :
    f ◁ η ▷ h = (α_ f g h).inv ≫ (f ◁ η) ▷ h ≫ (α_ f g' h).Hom := by simp
#align category_theory.bicategory.whisker_assoc_symm CategoryTheory.Bicategory.whisker_assoc_symm
-/

#print CategoryTheory.Bicategory.associator_naturality_right /-
@[reassoc]
theorem associator_naturality_right (f : a ⟶ b) (g : b ⟶ c) {h h' : c ⟶ d} (η : h ⟶ h') :
    (f ≫ g) ◁ η ≫ (α_ f g h').Hom = (α_ f g h).Hom ≫ f ◁ g ◁ η := by simp
#align category_theory.bicategory.associator_naturality_right CategoryTheory.Bicategory.associator_naturality_right
-/

#print CategoryTheory.Bicategory.associator_inv_naturality_right /-
@[reassoc]
theorem associator_inv_naturality_right (f : a ⟶ b) (g : b ⟶ c) {h h' : c ⟶ d} (η : h ⟶ h') :
    f ◁ g ◁ η ≫ (α_ f g h').inv = (α_ f g h).inv ≫ (f ≫ g) ◁ η := by simp
#align category_theory.bicategory.associator_inv_naturality_right CategoryTheory.Bicategory.associator_inv_naturality_right
-/

#print CategoryTheory.Bicategory.comp_whiskerLeft_symm /-
@[reassoc]
theorem comp_whiskerLeft_symm (f : a ⟶ b) (g : b ⟶ c) {h h' : c ⟶ d} (η : h ⟶ h') :
    f ◁ g ◁ η = (α_ f g h).inv ≫ (f ≫ g) ◁ η ≫ (α_ f g h').Hom := by simp
#align category_theory.bicategory.comp_whisker_left_symm CategoryTheory.Bicategory.comp_whiskerLeft_symm
-/

#print CategoryTheory.Bicategory.leftUnitor_naturality /-
@[reassoc]
theorem leftUnitor_naturality {f g : a ⟶ b} (η : f ⟶ g) : 𝟙 a ◁ η ≫ (λ_ g).Hom = (λ_ f).Hom ≫ η :=
  by simp
#align category_theory.bicategory.left_unitor_naturality CategoryTheory.Bicategory.leftUnitor_naturality
-/

#print CategoryTheory.Bicategory.leftUnitor_inv_naturality /-
@[reassoc]
theorem leftUnitor_inv_naturality {f g : a ⟶ b} (η : f ⟶ g) :
    η ≫ (λ_ g).inv = (λ_ f).inv ≫ 𝟙 a ◁ η := by simp
#align category_theory.bicategory.left_unitor_inv_naturality CategoryTheory.Bicategory.leftUnitor_inv_naturality
-/

#print CategoryTheory.Bicategory.id_whiskerLeft_symm /-
theorem id_whiskerLeft_symm {f g : a ⟶ b} (η : f ⟶ g) : η = (λ_ f).inv ≫ 𝟙 a ◁ η ≫ (λ_ g).Hom := by
  simp
#align category_theory.bicategory.id_whisker_left_symm CategoryTheory.Bicategory.id_whiskerLeft_symm
-/

#print CategoryTheory.Bicategory.rightUnitor_naturality /-
@[reassoc]
theorem rightUnitor_naturality {f g : a ⟶ b} (η : f ⟶ g) : η ▷ 𝟙 b ≫ (ρ_ g).Hom = (ρ_ f).Hom ≫ η :=
  by simp
#align category_theory.bicategory.right_unitor_naturality CategoryTheory.Bicategory.rightUnitor_naturality
-/

#print CategoryTheory.Bicategory.rightUnitor_inv_naturality /-
@[reassoc]
theorem rightUnitor_inv_naturality {f g : a ⟶ b} (η : f ⟶ g) :
    η ≫ (ρ_ g).inv = (ρ_ f).inv ≫ η ▷ 𝟙 b := by simp
#align category_theory.bicategory.right_unitor_inv_naturality CategoryTheory.Bicategory.rightUnitor_inv_naturality
-/

#print CategoryTheory.Bicategory.whiskerRight_id_symm /-
theorem whiskerRight_id_symm {f g : a ⟶ b} (η : f ⟶ g) : η = (ρ_ f).inv ≫ η ▷ 𝟙 b ≫ (ρ_ g).Hom := by
  simp
#align category_theory.bicategory.whisker_right_id_symm CategoryTheory.Bicategory.whiskerRight_id_symm
-/

#print CategoryTheory.Bicategory.whiskerLeft_iff /-
theorem whiskerLeft_iff {f g : a ⟶ b} (η θ : f ⟶ g) : 𝟙 a ◁ η = 𝟙 a ◁ θ ↔ η = θ := by simp
#align category_theory.bicategory.whisker_left_iff CategoryTheory.Bicategory.whiskerLeft_iff
-/

#print CategoryTheory.Bicategory.whiskerRight_iff /-
theorem whiskerRight_iff {f g : a ⟶ b} (η θ : f ⟶ g) : η ▷ 𝟙 b = θ ▷ 𝟙 b ↔ η = θ := by simp
#align category_theory.bicategory.whisker_right_iff CategoryTheory.Bicategory.whiskerRight_iff
-/

#print CategoryTheory.Bicategory.leftUnitor_whiskerRight /-
/-- We state it as a simp lemma, which is regarded as an involved version of
`id_whisker_right f g : 𝟙 f ▷ g = 𝟙 (f ≫ g)`.
-/
@[reassoc, simp]
theorem leftUnitor_whiskerRight (f : a ⟶ b) (g : b ⟶ c) :
    (λ_ f).Hom ▷ g = (α_ (𝟙 a) f g).Hom ≫ (λ_ (f ≫ g)).Hom := by
  rw [← whisker_left_iff, whisker_left_comp, ← cancel_epi (α_ _ _ _).Hom, ←
      cancel_epi ((α_ _ _ _).Hom ▷ _), pentagon_assoc, triangle, ← associator_naturality_middle, ←
      comp_whisker_right_assoc, triangle, associator_naturality_left] <;>
    infer_instance
#align category_theory.bicategory.left_unitor_whisker_right CategoryTheory.Bicategory.leftUnitor_whiskerRight
-/

#print CategoryTheory.Bicategory.leftUnitor_inv_whiskerRight /-
@[reassoc, simp]
theorem leftUnitor_inv_whiskerRight (f : a ⟶ b) (g : b ⟶ c) :
    (λ_ f).inv ▷ g = (λ_ (f ≫ g)).inv ≫ (α_ (𝟙 a) f g).inv :=
  eq_of_inv_eq_inv (by simp)
#align category_theory.bicategory.left_unitor_inv_whisker_right CategoryTheory.Bicategory.leftUnitor_inv_whiskerRight
-/

#print CategoryTheory.Bicategory.whiskerLeft_rightUnitor /-
@[reassoc, simp]
theorem whiskerLeft_rightUnitor (f : a ⟶ b) (g : b ⟶ c) :
    f ◁ (ρ_ g).Hom = (α_ f g (𝟙 c)).inv ≫ (ρ_ (f ≫ g)).Hom := by
  rw [← whisker_right_iff, comp_whisker_right, ← cancel_epi (α_ _ _ _).inv, ←
      cancel_epi (f ◁ (α_ _ _ _).inv), pentagon_inv_assoc, triangle_assoc_comp_right, ←
      associator_inv_naturality_middle, ← whisker_left_comp_assoc, triangle_assoc_comp_right,
      associator_inv_naturality_right] <;>
    infer_instance
#align category_theory.bicategory.whisker_left_right_unitor CategoryTheory.Bicategory.whiskerLeft_rightUnitor
-/

#print CategoryTheory.Bicategory.whiskerLeft_rightUnitor_inv /-
@[reassoc, simp]
theorem whiskerLeft_rightUnitor_inv (f : a ⟶ b) (g : b ⟶ c) :
    f ◁ (ρ_ g).inv = (ρ_ (f ≫ g)).inv ≫ (α_ f g (𝟙 c)).Hom :=
  eq_of_inv_eq_inv (by simp)
#align category_theory.bicategory.whisker_left_right_unitor_inv CategoryTheory.Bicategory.whiskerLeft_rightUnitor_inv
-/

#print CategoryTheory.Bicategory.leftUnitor_comp /-
/-
It is not so obvious whether `left_unitor_whisker_right` or `left_unitor_comp` should be a simp
lemma. Our choice is the former. One reason is that the latter yields the following loop:
[id_whisker_left]   : 𝟙 a ◁ (ρ_ f).hom ==> (λ_ (f ≫ 𝟙 b)).hom ≫ (ρ_ f).hom ≫ (λ_ f).inv
[left_unitor_comp]  : (λ_ (f ≫ 𝟙 b)).hom ==> (α_ (𝟙 a) f (𝟙 b)).inv ≫ (λ_ f).hom ▷ 𝟙 b
[whisker_right_id]  : (λ_ f).hom ▷ 𝟙 b ==> (ρ_ (𝟙 a ≫ f)).hom ≫ (λ_ f).hom ≫ (ρ_ f).inv
[right_unitor_comp] : (ρ_ (𝟙 a ≫ f)).hom ==> (α_ (𝟙 a) f (𝟙 b)).hom ≫ 𝟙 a ◁ (ρ_ f).hom
-/
@[reassoc]
theorem leftUnitor_comp (f : a ⟶ b) (g : b ⟶ c) :
    (λ_ (f ≫ g)).Hom = (α_ (𝟙 a) f g).inv ≫ (λ_ f).Hom ▷ g := by simp
#align category_theory.bicategory.left_unitor_comp CategoryTheory.Bicategory.leftUnitor_comp
-/

#print CategoryTheory.Bicategory.leftUnitor_comp_inv /-
@[reassoc]
theorem leftUnitor_comp_inv (f : a ⟶ b) (g : b ⟶ c) :
    (λ_ (f ≫ g)).inv = (λ_ f).inv ▷ g ≫ (α_ (𝟙 a) f g).Hom := by simp
#align category_theory.bicategory.left_unitor_comp_inv CategoryTheory.Bicategory.leftUnitor_comp_inv
-/

#print CategoryTheory.Bicategory.rightUnitor_comp /-
@[reassoc]
theorem rightUnitor_comp (f : a ⟶ b) (g : b ⟶ c) :
    (ρ_ (f ≫ g)).Hom = (α_ f g (𝟙 c)).Hom ≫ f ◁ (ρ_ g).Hom := by simp
#align category_theory.bicategory.right_unitor_comp CategoryTheory.Bicategory.rightUnitor_comp
-/

#print CategoryTheory.Bicategory.rightUnitor_comp_inv /-
@[reassoc]
theorem rightUnitor_comp_inv (f : a ⟶ b) (g : b ⟶ c) :
    (ρ_ (f ≫ g)).inv = f ◁ (ρ_ g).inv ≫ (α_ f g (𝟙 c)).inv := by simp
#align category_theory.bicategory.right_unitor_comp_inv CategoryTheory.Bicategory.rightUnitor_comp_inv
-/

#print CategoryTheory.Bicategory.unitors_equal /-
@[simp]
theorem unitors_equal : (λ_ (𝟙 a)).Hom = (ρ_ (𝟙 a)).Hom := by
  rw [← whisker_left_iff, ← cancel_epi (α_ _ _ _).Hom, ← cancel_mono (ρ_ _).Hom, triangle, ←
      right_unitor_comp, right_unitor_naturality] <;>
    infer_instance
#align category_theory.bicategory.unitors_equal CategoryTheory.Bicategory.unitors_equal
-/

#print CategoryTheory.Bicategory.unitors_inv_equal /-
@[simp]
theorem unitors_inv_equal : (λ_ (𝟙 a)).inv = (ρ_ (𝟙 a)).inv := by simp [iso.inv_eq_inv]
#align category_theory.bicategory.unitors_inv_equal CategoryTheory.Bicategory.unitors_inv_equal
-/

end Bicategory

end CategoryTheory

