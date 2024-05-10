/-
Copyright (c) 2022 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import CategoryTheory.Monoidal.Rigid.Basic

#align_import category_theory.monoidal.rigid.of_equivalence from "leanprover-community/mathlib"@"36938f775671ff28bea1c0310f1608e4afbb22e0"

/-!
# Transport rigid structures over a monoidal equivalence.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


noncomputable section

namespace CategoryTheory

variable {C D : Type _} [Category C] [Category D] [MonoidalCategory C] [MonoidalCategory D]

variable (F : MonoidalFunctor C D)

/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.exactPairingOfFaithful /-
/-- Given candidate data for an exact pairing,
which is sent by a faithful monoidal functor to an exact pairing,
the equations holds automatically. -/
def exactPairingOfFaithful [CategoryTheory.Functor.Faithful F.toFunctor] {X Y : C}
    (eval : Y ⊗ X ⟶ 𝟙_ C) (coeval : 𝟙_ C ⟶ X ⊗ Y) [ExactPairing (F.obj X) (F.obj Y)]
    (map_eval : F.map eval = inv (F.μ _ _) ≫ ε_ _ _ ≫ F.ε)
    (map_coeval : F.map coeval = inv F.ε ≫ η_ _ _ ≫ F.μ _ _) : ExactPairing X Y
    where
  evaluation := eval
  coevaluation := coeval
  evaluation_coevaluation' :=
    F.toFunctor.map_injective (by simp [map_eval, map_coeval, monoidal_functor.map_tensor])
  coevaluation_evaluation' :=
    F.toFunctor.map_injective (by simp [map_eval, map_coeval, monoidal_functor.map_tensor])
#align category_theory.exact_pairing_of_faithful CategoryTheory.exactPairingOfFaithful
-/

#print CategoryTheory.exactPairingOfFullyFaithful /-
/-- Given a pair of objects which are sent by a fully faithful functor to a pair of objects
with an exact pairing, we get an exact pairing.
-/
def exactPairingOfFullyFaithful [CategoryTheory.Functor.Full F.toFunctor]
    [CategoryTheory.Functor.Faithful F.toFunctor] (X Y : C) [ExactPairing (F.obj X) (F.obj Y)] :
    ExactPairing X Y :=
  exactPairingOfFaithful F (F.toFunctor.preimage (inv (F.μ _ _) ≫ ε_ _ _ ≫ F.ε))
    (F.toFunctor.preimage (inv F.ε ≫ η_ _ _ ≫ F.μ _ _)) (by simp) (by simp)
#align category_theory.exact_pairing_of_fully_faithful CategoryTheory.exactPairingOfFullyFaithful
-/

/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.hasLeftDualOfEquivalence /-
/-- Pull back a left dual along an equivalence. -/
def hasLeftDualOfEquivalence [CategoryTheory.Functor.IsEquivalence F.toFunctor] (X : C)
    [HasLeftDual (F.obj X)] : HasLeftDual X
    where
  leftDual := F.toFunctor.inv.obj (ᘁF.obj X)
  exact := by
    apply exact_pairing_of_fully_faithful F _ _
    apply exact_pairing_congr_left (F.to_functor.as_equivalence.counit_iso.app _)
    dsimp
    infer_instance
#align category_theory.has_left_dual_of_equivalence CategoryTheory.hasLeftDualOfEquivalence
-/

/- ././././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print CategoryTheory.hasRightDualOfEquivalence /-
/-- Pull back a right dual along an equivalence. -/
def hasRightDualOfEquivalence [CategoryTheory.Functor.IsEquivalence F.toFunctor] (X : C)
    [HasRightDual (F.obj X)] : HasRightDual X
    where
  rightDual := F.toFunctor.inv.obj (F.obj Xᘁ)
  exact := by
    apply exact_pairing_of_fully_faithful F _ _
    apply exact_pairing_congr_right (F.to_functor.as_equivalence.counit_iso.app _)
    dsimp
    infer_instance
#align category_theory.has_right_dual_of_equivalence CategoryTheory.hasRightDualOfEquivalence
-/

#print CategoryTheory.leftRigidCategoryOfEquivalence /-
/-- Pull back a left rigid structure along an equivalence. -/
def leftRigidCategoryOfEquivalence [CategoryTheory.Functor.IsEquivalence F.toFunctor]
    [LeftRigidCategory D] : LeftRigidCategory C where leftDual X := hasLeftDualOfEquivalence F X
#align category_theory.left_rigid_category_of_equivalence CategoryTheory.leftRigidCategoryOfEquivalence
-/

#print CategoryTheory.rightRigidCategoryOfEquivalence /-
/-- Pull back a right rigid structure along an equivalence. -/
def rightRigidCategoryOfEquivalence [CategoryTheory.Functor.IsEquivalence F.toFunctor]
    [RightRigidCategory D] : RightRigidCategory C where rightDual X := hasRightDualOfEquivalence F X
#align category_theory.right_rigid_category_of_equivalence CategoryTheory.rightRigidCategoryOfEquivalence
-/

#print CategoryTheory.rigidCategoryOfEquivalence /-
/-- Pull back a rigid structure along an equivalence. -/
def rigidCategoryOfEquivalence [CategoryTheory.Functor.IsEquivalence F.toFunctor]
    [RigidCategory D] : RigidCategory C
    where
  leftDual X := hasLeftDualOfEquivalence F X
  rightDual X := hasRightDualOfEquivalence F X
#align category_theory.rigid_category_of_equivalence CategoryTheory.rigidCategoryOfEquivalence
-/

end CategoryTheory

