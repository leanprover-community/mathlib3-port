/-
Copyright (c) 2022. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison, Yuma Mizuno, Oleksandr Manzyuk

! This file was ported from Lean 3 source module category_theory.monoidal.coherence
! leanprover-community/mathlib commit 98e83c3d541c77cdb7da20d79611a780ff8e7d90
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Monoidal.Free.Coherence
import Mathbin.CategoryTheory.Bicategory.CoherenceTactic

/-!
# A `coherence` tactic for monoidal categories, and `⊗≫` (composition up to associators)

We provide a `coherence` tactic,
which proves equations where the two sides differ by replacing
strings of monoidal structural morphisms with other such strings.
(The replacements are always equalities by the monoidal coherence theorem.)

A simpler version of this tactic is `pure_coherence`,
which proves that any two morphisms (with the same source and target)
in a monoidal category which are built out of associators and unitors
are equal.

We also provide `f ⊗≫ g`, the `monoidal_comp` operation,
which automatically inserts associators and unitors as needed
to make the target of `f` match the source of `g`.
-/


noncomputable section

universe v u

open CategoryTheory

open CategoryTheory.FreeMonoidalCategory

variable {C : Type u} [Category.{v} C] [MonoidalCategory C]

namespace CategoryTheory.MonoidalCategory

/-- A typeclass carrying a choice of lift of an object from `C` to `free_monoidal_category C`. -/
class LiftObj (X : C) where
  lift : FreeMonoidalCategory C
#align category_theory.monoidal_category.lift_obj CategoryTheory.MonoidalCategory.LiftObj

instance liftObjUnit : LiftObj (𝟙_ C) where lift := Unit
#align category_theory.monoidal_category.lift_obj_unit CategoryTheory.MonoidalCategory.liftObjUnit

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance liftObjTensor (X Y : C) [LiftObj X] [LiftObj Y] : LiftObj (X ⊗ Y)
    where lift := LiftObj.lift X ⊗ LiftObj.lift Y
#align category_theory.monoidal_category.lift_obj_tensor CategoryTheory.MonoidalCategory.liftObjTensor

instance (priority := 100) liftObjOf (X : C) : LiftObj X where lift := of X
#align category_theory.monoidal_category.lift_obj_of CategoryTheory.MonoidalCategory.liftObjOf

/-- A typeclass carrying a choice of lift of a morphism from `C` to `free_monoidal_category C`. -/
class LiftHom {X Y : C} [LiftObj X] [LiftObj Y] (f : X ⟶ Y) where
  lift : LiftObj.lift X ⟶ LiftObj.lift Y
#align category_theory.monoidal_category.lift_hom CategoryTheory.MonoidalCategory.LiftHom

instance liftHomId (X : C) [LiftObj X] : LiftHom (𝟙 X) where lift := 𝟙 _
#align category_theory.monoidal_category.lift_hom_id CategoryTheory.MonoidalCategory.liftHomId

instance liftHomLeftUnitorHom (X : C) [LiftObj X] : LiftHom (λ_ X).Hom
    where lift := (λ_ (LiftObj.lift X)).Hom
#align category_theory.monoidal_category.lift_hom_left_unitor_hom CategoryTheory.MonoidalCategory.liftHomLeftUnitorHom

instance liftHomLeftUnitorInv (X : C) [LiftObj X] : LiftHom (λ_ X).inv
    where lift := (λ_ (LiftObj.lift X)).inv
#align category_theory.monoidal_category.lift_hom_left_unitor_inv CategoryTheory.MonoidalCategory.liftHomLeftUnitorInv

instance liftHomRightUnitorHom (X : C) [LiftObj X] : LiftHom (ρ_ X).Hom
    where lift := (ρ_ (LiftObj.lift X)).Hom
#align category_theory.monoidal_category.lift_hom_right_unitor_hom CategoryTheory.MonoidalCategory.liftHomRightUnitorHom

instance liftHomRightUnitorInv (X : C) [LiftObj X] : LiftHom (ρ_ X).inv
    where lift := (ρ_ (LiftObj.lift X)).inv
#align category_theory.monoidal_category.lift_hom_right_unitor_inv CategoryTheory.MonoidalCategory.liftHomRightUnitorInv

instance liftHomAssociatorHom (X Y Z : C) [LiftObj X] [LiftObj Y] [LiftObj Z] :
    LiftHom (α_ X Y Z).Hom where lift := (α_ (LiftObj.lift X) (LiftObj.lift Y) (LiftObj.lift Z)).Hom
#align category_theory.monoidal_category.lift_hom_associator_hom CategoryTheory.MonoidalCategory.liftHomAssociatorHom

instance liftHomAssociatorInv (X Y Z : C) [LiftObj X] [LiftObj Y] [LiftObj Z] :
    LiftHom (α_ X Y Z).inv where lift := (α_ (LiftObj.lift X) (LiftObj.lift Y) (LiftObj.lift Z)).inv
#align category_theory.monoidal_category.lift_hom_associator_inv CategoryTheory.MonoidalCategory.liftHomAssociatorInv

instance liftHomComp {X Y Z : C} [LiftObj X] [LiftObj Y] [LiftObj Z] (f : X ⟶ Y) (g : Y ⟶ Z)
    [LiftHom f] [LiftHom g] : LiftHom (f ≫ g) where lift := LiftHom.lift f ≫ LiftHom.lift g
#align category_theory.monoidal_category.lift_hom_comp CategoryTheory.MonoidalCategory.liftHomComp

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance liftHomTensor {W X Y Z : C} [LiftObj W] [LiftObj X] [LiftObj Y] [LiftObj Z] (f : W ⟶ X)
    (g : Y ⟶ Z) [LiftHom f] [LiftHom g] : LiftHom (f ⊗ g)
    where lift := LiftHom.lift f ⊗ LiftHom.lift g
#align category_theory.monoidal_category.lift_hom_tensor CategoryTheory.MonoidalCategory.liftHomTensor

/- ./././Mathport/Syntax/Translate/Command.lean:388:30: infer kinds are unsupported in Lean 4: #[`Hom] [] -/
-- We could likely turn this into a `Prop` valued existential if that proves useful.
/-- A typeclass carrying a choice of monoidal structural isomorphism between two objects.
Used by the `⊗≫` monoidal composition operator, and the `coherence` tactic.
-/
class MonoidalCoherence (X Y : C) [LiftObj X] [LiftObj Y] where
  Hom : X ⟶ Y
  [IsIso : IsIso hom]
#align category_theory.monoidal_category.monoidal_coherence CategoryTheory.MonoidalCategory.MonoidalCoherence

attribute [instance] monoidal_coherence.is_iso

namespace MonoidalCoherence

@[simps]
instance refl (X : C) [LiftObj X] : MonoidalCoherence X X :=
  ⟨𝟙 _⟩
#align category_theory.monoidal_category.monoidal_coherence.refl CategoryTheory.MonoidalCategory.MonoidalCoherence.refl

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simps]
instance tensor (X Y Z : C) [LiftObj X] [LiftObj Y] [LiftObj Z] [MonoidalCoherence Y Z] :
    MonoidalCoherence (X ⊗ Y) (X ⊗ Z) :=
  ⟨𝟙 X ⊗ MonoidalCoherence.hom Y Z⟩
#align category_theory.monoidal_category.monoidal_coherence.tensor CategoryTheory.MonoidalCategory.MonoidalCoherence.tensor

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simps]
instance tensorRight (X Y : C) [LiftObj X] [LiftObj Y] [MonoidalCoherence (𝟙_ C) Y] :
    MonoidalCoherence X (X ⊗ Y) :=
  ⟨(ρ_ X).inv ≫ (𝟙 X ⊗ MonoidalCoherence.hom (𝟙_ C) Y)⟩
#align category_theory.monoidal_category.monoidal_coherence.tensor_right CategoryTheory.MonoidalCategory.MonoidalCoherence.tensorRight

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simps]
instance tensorRight' (X Y : C) [LiftObj X] [LiftObj Y] [MonoidalCoherence Y (𝟙_ C)] :
    MonoidalCoherence (X ⊗ Y) X :=
  ⟨(𝟙 X ⊗ MonoidalCoherence.hom Y (𝟙_ C)) ≫ (ρ_ X).Hom⟩
#align category_theory.monoidal_category.monoidal_coherence.tensor_right' CategoryTheory.MonoidalCategory.MonoidalCoherence.tensorRight'

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simps]
instance left (X Y : C) [LiftObj X] [LiftObj Y] [MonoidalCoherence X Y] :
    MonoidalCoherence (𝟙_ C ⊗ X) Y :=
  ⟨(λ_ X).Hom ≫ MonoidalCoherence.hom X Y⟩
#align category_theory.monoidal_category.monoidal_coherence.left CategoryTheory.MonoidalCategory.MonoidalCoherence.left

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simps]
instance left' (X Y : C) [LiftObj X] [LiftObj Y] [MonoidalCoherence X Y] :
    MonoidalCoherence X (𝟙_ C ⊗ Y) :=
  ⟨MonoidalCoherence.hom X Y ≫ (λ_ Y).inv⟩
#align category_theory.monoidal_category.monoidal_coherence.left' CategoryTheory.MonoidalCategory.MonoidalCoherence.left'

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simps]
instance right (X Y : C) [LiftObj X] [LiftObj Y] [MonoidalCoherence X Y] :
    MonoidalCoherence (X ⊗ 𝟙_ C) Y :=
  ⟨(ρ_ X).Hom ≫ MonoidalCoherence.hom X Y⟩
#align category_theory.monoidal_category.monoidal_coherence.right CategoryTheory.MonoidalCategory.MonoidalCoherence.right

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simps]
instance right' (X Y : C) [LiftObj X] [LiftObj Y] [MonoidalCoherence X Y] :
    MonoidalCoherence X (Y ⊗ 𝟙_ C) :=
  ⟨MonoidalCoherence.hom X Y ≫ (ρ_ Y).inv⟩
#align category_theory.monoidal_category.monoidal_coherence.right' CategoryTheory.MonoidalCategory.MonoidalCoherence.right'

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simps]
instance assoc (X Y Z W : C) [LiftObj W] [LiftObj X] [LiftObj Y] [LiftObj Z]
    [MonoidalCoherence (X ⊗ Y ⊗ Z) W] : MonoidalCoherence ((X ⊗ Y) ⊗ Z) W :=
  ⟨(α_ X Y Z).Hom ≫ MonoidalCoherence.hom (X ⊗ Y ⊗ Z) W⟩
#align category_theory.monoidal_category.monoidal_coherence.assoc CategoryTheory.MonoidalCategory.MonoidalCoherence.assoc

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simps]
instance assoc' (W X Y Z : C) [LiftObj W] [LiftObj X] [LiftObj Y] [LiftObj Z]
    [MonoidalCoherence W (X ⊗ Y ⊗ Z)] : MonoidalCoherence W ((X ⊗ Y) ⊗ Z) :=
  ⟨MonoidalCoherence.hom W (X ⊗ Y ⊗ Z) ≫ (α_ X Y Z).inv⟩
#align category_theory.monoidal_category.monoidal_coherence.assoc' CategoryTheory.MonoidalCategory.MonoidalCoherence.assoc'

end MonoidalCoherence

/-- Construct an isomorphism between two objects in a monoidal category
out of unitors and associators. -/
def monoidalIso (X Y : C) [LiftObj X] [LiftObj Y] [MonoidalCoherence X Y] : X ≅ Y :=
  asIso (MonoidalCoherence.hom X Y)
#align category_theory.monoidal_category.monoidal_iso CategoryTheory.MonoidalCategory.monoidalIso

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
example (X : C) : X ≅ X ⊗ 𝟙_ C ⊗ 𝟙_ C :=
  monoidalIso _ _

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
example (X1 X2 X3 X4 X5 X6 X7 X8 X9 : C) :
    𝟙_ C ⊗ (X1 ⊗ X2 ⊗ (X3 ⊗ X4) ⊗ X5) ⊗ X6 ⊗ X7 ⊗ X8 ⊗ X9 ≅
      X1 ⊗ (X2 ⊗ X3) ⊗ X4 ⊗ (X5 ⊗ (𝟙_ C ⊗ X6) ⊗ X7) ⊗ X8 ⊗ X9 :=
  monoidalIso _ _

/-- Compose two morphisms in a monoidal category,
inserting unitors and associators between as necessary. -/
def monoidalComp {W X Y Z : C} [LiftObj X] [LiftObj Y] [MonoidalCoherence X Y] (f : W ⟶ X)
    (g : Y ⟶ Z) : W ⟶ Z :=
  f ≫ MonoidalCoherence.hom X Y ≫ g
#align category_theory.monoidal_category.monoidal_comp CategoryTheory.MonoidalCategory.monoidalComp

-- mathport name: «expr ⊗≫ »
infixr:80 " ⊗≫ " => monoidalComp

-- type as \ot \gg
/-- Compose two isomorphisms in a monoidal category,
inserting unitors and associators between as necessary. -/
def monoidalIsoComp {W X Y Z : C} [LiftObj X] [LiftObj Y] [MonoidalCoherence X Y] (f : W ≅ X)
    (g : Y ≅ Z) : W ≅ Z :=
  f ≪≫ asIso (MonoidalCoherence.hom X Y) ≪≫ g
#align category_theory.monoidal_category.monoidal_iso_comp CategoryTheory.MonoidalCategory.monoidalIsoComp

-- mathport name: «expr ≪⊗≫ »
infixr:80 " ≪⊗≫ " => monoidalIsoComp

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
-- type as \ot \gg
example {U V W X Y : C} (f : U ⟶ V ⊗ W ⊗ X) (g : (V ⊗ W) ⊗ X ⟶ Y) : U ⟶ Y :=
  f ⊗≫ g

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
-- To automatically insert unitors/associators at the beginning or end,
-- you can use `f ⊗≫ 𝟙 _`
example {W X Y Z : C} (f : W ⟶ (X ⊗ Y) ⊗ Z) : W ⟶ X ⊗ Y ⊗ Z :=
  f ⊗≫ 𝟙 _

@[simp]
theorem monoidalComp_refl {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z) : f ⊗≫ g = f ≫ g :=
  by
  dsimp [monoidal_comp]
  simp
#align category_theory.monoidal_category.monoidal_comp_refl CategoryTheory.MonoidalCategory.monoidalComp_refl

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
example {U V W X Y : C} (f : U ⟶ V ⊗ W ⊗ X) (g : (V ⊗ W) ⊗ X ⟶ Y) :
    f ⊗≫ g = f ≫ (α_ _ _ _).inv ≫ g := by simp [monoidal_comp]

end CategoryTheory.MonoidalCategory

open CategoryTheory.MonoidalCategory

namespace Tactic

open Tactic

/- ./././Mathport/Syntax/Translate/Tactic/Mathlib/Core.lean:38:34: unsupported: setup_tactic_parser -/
/-- Auxilliary definition of `monoidal_coherence`,
being careful with namespaces to avoid shadowing.
-/
unsafe def mk_project_map_expr (e : expr) : tactic expr :=
  to_expr
    ``(CategoryTheory.FreeMonoidalCategory.projectMap id _ _
        (CategoryTheory.MonoidalCategory.LiftHom.lift $(e)))
#align tactic.mk_project_map_expr tactic.mk_project_map_expr

/- ./././Mathport/Syntax/Translate/Expr.lean:333:4: warning: unsupported (TODO): `[tacs] -/
-- failed to format: unknown constant 'term.pseudo.antiquot'
/-- Coherence tactic for monoidal categories. -/ unsafe
  def
    monoidal_coherence
    : tactic Unit
    :=
      do
        let o ← get_options
          set_options <| o `class.instance_max_depth 128
          try sorry
          let q( $ ( lhs ) = $ ( rhs ) ) ← target
          let project_map_lhs ← mk_project_map_expr lhs
          let project_map_rhs ← mk_project_map_expr rhs
          to_expr ` `( $ ( project_map_lhs ) = $ ( project_map_rhs ) ) >>= tactic.change
          congr
#align tactic.monoidal_coherence tactic.monoidal_coherence

/-- `pure_coherence` uses the coherence theorem for monoidal categories to prove the goal.
It can prove any equality made up only of associators, unitors, and identities.
```lean
example {C : Type} [category C] [monoidal_category C] :
  (λ_ (𝟙_ C)).hom = (ρ_ (𝟙_ C)).hom :=
by pure_coherence
```

Users will typicall just use the `coherence` tactic, which can also cope with identities of the form
`a ≫ f ≫ b ≫ g ≫ c = a' ≫ f ≫ b' ≫ g ≫ c'`
where `a = a'`, `b = b'`, and `c = c'` can be proved using `pure_coherence`
-/
unsafe def pure_coherence : tactic Unit :=
  monoidal_coherence <|> bicategorical_coherence
#align tactic.pure_coherence tactic.pure_coherence

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic tactic.pure_coherence -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
example (X₁ X₂ : C) :
    ((λ_ (𝟙_ C)).inv ⊗ 𝟙 (X₁ ⊗ X₂)) ≫
        (α_ (𝟙_ C) (𝟙_ C) (X₁ ⊗ X₂)).Hom ≫ (𝟙 (𝟙_ C) ⊗ (α_ (𝟙_ C) X₁ X₂).inv) =
      𝟙 (𝟙_ C) ⊗ (λ_ X₁).inv ⊗ 𝟙 X₂ :=
  by
  run_tac
    pure_coherence

namespace Coherence

-- We have unused typeclass arguments here.
-- They are intentional, to ensure that `simp only [assoc_lift_hom]` only left associates
-- monoidal structural morphisms.
/-- Auxiliary simp lemma for the `coherence` tactic:
this moves brackets to the left in order to expose a maximal prefix
built out of unitors and associators.
-/
@[nolint unused_arguments]
theorem assoc_liftHom {W X Y Z : C} [LiftObj W] [LiftObj X] [LiftObj Y] (f : W ⟶ X) (g : X ⟶ Y)
    (h : Y ⟶ Z) [LiftHom f] [LiftHom g] : f ≫ g ≫ h = (f ≫ g) ≫ h :=
  (Category.assoc _ _ _).symm
#align tactic.coherence.assoc_lift_hom Tactic.Coherence.assoc_liftHom

/- ./././Mathport/Syntax/Translate/Expr.lean:333:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:333:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:333:4: warning: unsupported (TODO): `[tacs] -/
/-- Internal tactic used in `coherence`.

Rewrites an equation `f = g` as `f₀ ≫ f₁ = g₀ ≫ g₁`,
where `f₀` and `g₀` are maximal prefixes of `f` and `g` (possibly after reassociating)
which are "liftable" (i.e. expressible as compositions of unitors and associators).
-/
unsafe def liftable_prefixes : tactic Unit := do
  let o ← get_options
  set_options <| o `class.instance_max_depth 128
  (try sorry >> sorry) >> try sorry
#align tactic.coherence.liftable_prefixes tactic.coherence.liftable_prefixes

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic tactic.coherence.liftable_prefixes -/
example {W X Y Z : C} (f : Y ⟶ Z) (g) (w : False) : (λ_ _).Hom ≫ f = g :=
  by
  run_tac
    liftable_prefixes
  guard_target =ₐ (𝟙 _ ≫ (λ_ _).Hom) ≫ f = 𝟙 _ ≫ g
  cases w

theorem insert_id_lhs {C : Type _} [Category C] {X Y : C} (f g : X ⟶ Y) (w : f ≫ 𝟙 _ = g) : f = g :=
  by simpa using w
#align tactic.coherence.insert_id_lhs Tactic.Coherence.insert_id_lhs

theorem insert_id_rhs {C : Type _} [Category C] {X Y : C} (f g : X ⟶ Y) (w : f = g ≫ 𝟙 _) : f = g :=
  by simpa using w
#align tactic.coherence.insert_id_rhs Tactic.Coherence.insert_id_rhs

end Coherence

open Coherence

/- ./././Mathport/Syntax/Translate/Expr.lean:333:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:333:4: warning: unsupported (TODO): `[tacs] -/
/-- The main part of `coherence` tactic. -/
unsafe def coherence_loop : tactic Unit := do
  -- To prove an equality `f = g` in a monoidal category,
      -- first try the `pure_coherence` tactic on the entire equation:
      pure_coherence <|>
      do
      -- Otherwise, rearrange so we have a maximal prefix of each side
          -- that is built out of unitors and associators:
          liftable_prefixes <|>
          fail
            ("Something went wrong in the `coherence` tactic: " ++
              "is the target an equation in a monoidal category?")
      -- The goal should now look like `f₀ ≫ f₁ = g₀ ≫ g₁`,
        tactic.congr_core'
      -- and now we have two goals `f₀ = g₀` and `f₁ = g₁`.
            -- Discharge the first using `coherence`,
            focus1
            pure_coherence <|>
          fail "`coherence` tactic failed, subgoal not true in the free monoidal_category"
      -- Then check that either `g₀` is identically `g₁`,
          reflexivity <|>
          do
          (-- or that both are compositions,
              do
                let q(_ ≫ _ = _) ← target
                skip) <|>
              sorry
          (do
                let q(_ = _ ≫ _) ← target
                skip) <|>
              sorry
          let q(_ ≫ _ = _ ≫ _) ← target |
            fail "`coherence` tactic failed, non-structural morphisms don't match"
          tactic.congr_core'
          -- with identical first terms,
              reflexivity <|>
              fail "`coherence` tactic failed, non-structural morphisms don't match"
          -- and whose second terms can be identified by recursively called `coherence`.
            coherence_loop
#align tactic.coherence_loop tactic.coherence_loop

/- ./././Mathport/Syntax/Translate/Expr.lean:333:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:333:4: warning: unsupported (TODO): `[tacs] -/
/-- Use the coherence theorem for monoidal categories to solve equations in a monoidal equation,
where the two sides only differ by replacing strings of monoidal structural morphisms
(that is, associators, unitors, and identities)
with different strings of structural morphisms with the same source and target.

That is, `coherence` can handle goals of the form
`a ≫ f ≫ b ≫ g ≫ c = a' ≫ f ≫ b' ≫ g ≫ c'`
where `a = a'`, `b = b'`, and `c = c'` can be proved using `pure_coherence`.

(If you have very large equations on which `coherence` is unexpectedly failing,
you may need to increase the typeclass search depth,
using e.g. `set_option class.instance_max_depth 500`.)
-/
unsafe def coherence : tactic Unit := do
  try sorry
  try sorry
  -- TODO: put similar normalization simp lemmas for monoidal categories
      try
      bicategory.whisker_simps
  coherence_loop
#align tactic.coherence tactic.coherence

run_cmd
  add_interactive [`pure_coherence, `coherence]

add_tactic_doc
  { Name := "coherence"
    category := DocCategory.tactic
    declNames := [`tactic.interactive.coherence]
    tags := ["category theory"] }

example (f) : (λ_ (𝟙_ C)).Hom ≫ f ≫ (λ_ (𝟙_ C)).Hom = (ρ_ (𝟙_ C)).Hom ≫ f ≫ (ρ_ (𝟙_ C)).Hom := by
  coherence

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
example {U V W X Y : C} (f : U ⟶ V ⊗ W ⊗ X) (g : (V ⊗ W) ⊗ X ⟶ Y) :
    f ⊗≫ g = f ≫ (α_ _ _ _).inv ≫ g := by coherence

example {U : C} (f : U ⟶ 𝟙_ C) : f ≫ (ρ_ (𝟙_ C)).inv ≫ (λ_ (𝟙_ C)).Hom = f := by coherence

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
example (W X Y Z : C) (f) :
    ((α_ W X Y).Hom ⊗ 𝟙 Z) ≫
        (α_ W (X ⊗ Y) Z).Hom ≫
          (𝟙 W ⊗ (α_ X Y Z).Hom) ≫ f ≫ (α_ (W ⊗ X) Y Z).Hom ≫ (α_ W X (Y ⊗ Z)).Hom =
      (α_ (W ⊗ X) Y Z).Hom ≫
        (α_ W X (Y ⊗ Z)).Hom ≫
          f ≫ ((α_ W X Y).Hom ⊗ 𝟙 Z) ≫ (α_ W (X ⊗ Y) Z).Hom ≫ (𝟙 W ⊗ (α_ X Y Z).Hom) :=
  by coherence

end Tactic

