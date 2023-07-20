/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import Mathbin.Data.Fintype.Card
import Mathbin.CategoryTheory.DiscreteCategory
import Mathbin.CategoryTheory.Opposites
import Mathbin.CategoryTheory.Category.Ulift

#align_import category_theory.fin_category from "leanprover-community/mathlib"@"2efd2423f8d25fa57cf7a179f5d8652ab4d0df44"

/-!
# Finite categories

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A category is finite in this sense if it has finitely many objects, and finitely many morphisms.

## Implementation
Prior to #14046, `fin_category` required a `decidable_eq` instance on the object and morphism types.
This does not seem to have had any practical payoff (i.e. making some definition constructive)
so we have removed these requirements to avoid
having to supply instances or delay with non-defeq conflicts between instances.
-/


universe w v u

open scoped Classical

noncomputable section

namespace CategoryTheory

#print CategoryTheory.discreteFintype /-
instance discreteFintype {α : Type _} [Fintype α] : Fintype (Discrete α) :=
  Fintype.ofEquiv α discreteEquiv.symm
#align category_theory.discrete_fintype CategoryTheory.discreteFintype
-/

#print CategoryTheory.discreteHomFintype /-
instance discreteHomFintype {α : Type _} (X Y : Discrete α) : Fintype (X ⟶ Y) := by
  apply ULift.fintype
#align category_theory.discrete_hom_fintype CategoryTheory.discreteHomFintype
-/

#print CategoryTheory.FinCategory /-
/-- A category with a `fintype` of objects, and a `fintype` for each morphism space. -/
class FinCategory (J : Type v) [SmallCategory J] where
  fintypeObj : Fintype J := by infer_instance
  fintypeHom : ∀ j j' : J, Fintype (j ⟶ j') := by infer_instance
#align category_theory.fin_category CategoryTheory.FinCategory
-/

attribute [instance] fin_category.fintype_obj fin_category.fintype_hom

#print CategoryTheory.finCategoryDiscreteOfFintype /-
instance finCategoryDiscreteOfFintype (J : Type v) [Fintype J] : FinCategory (Discrete J) where
#align category_theory.fin_category_discrete_of_fintype CategoryTheory.finCategoryDiscreteOfFintype
-/

namespace FinCategory

variable (α : Type _) [Fintype α] [SmallCategory α] [FinCategory α]

#print CategoryTheory.FinCategory.ObjAsType /-
/-- A fin_category `α` is equivalent to a category with objects in `Type`. -/
@[nolint unused_arguments]
abbrev ObjAsType : Type :=
  InducedCategory α (Fintype.equivFin α).symm
#align category_theory.fin_category.obj_as_type CategoryTheory.FinCategory.ObjAsType
-/

#print CategoryTheory.FinCategory.objAsTypeEquiv /-
/-- The constructed category is indeed equivalent to `α`. -/
noncomputable def objAsTypeEquiv : ObjAsType α ≌ α :=
  (inducedFunctor (Fintype.equivFin α).symm).asEquivalence
#align category_theory.fin_category.obj_as_type_equiv CategoryTheory.FinCategory.objAsTypeEquiv
-/

#print CategoryTheory.FinCategory.AsType /-
/-- A fin_category `α` is equivalent to a fin_category with in `Type`. -/
@[nolint unused_arguments]
abbrev AsType : Type :=
  Fin (Fintype.card α)
#align category_theory.fin_category.as_type CategoryTheory.FinCategory.AsType
-/

#print CategoryTheory.FinCategory.categoryAsType /-
@[simps (config := lemmasOnly) id comp]
noncomputable instance categoryAsType : SmallCategory (AsType α)
    where
  hom i j := Fin (Fintype.card (@Quiver.Hom (ObjAsType α) _ i j))
  id i := Fintype.equivFin _ (𝟙 i)
  comp i j k f g := Fintype.equivFin _ ((Fintype.equivFin _).symm f ≫ (Fintype.equivFin _).symm g)
#align category_theory.fin_category.category_as_type CategoryTheory.FinCategory.categoryAsType
-/

attribute [local simp] category_as_type_id category_as_type_comp

#print CategoryTheory.FinCategory.asTypeToObjAsType /-
/-- The "identity" functor from `as_type α` to `obj_as_type α`. -/
@[simps]
noncomputable def asTypeToObjAsType : AsType α ⥤ ObjAsType α
    where
  obj := id
  map i j := (Fintype.equivFin _).symm
#align category_theory.fin_category.as_type_to_obj_as_type CategoryTheory.FinCategory.asTypeToObjAsType
-/

#print CategoryTheory.FinCategory.objAsTypeToAsType /-
/-- The "identity" functor from `obj_as_type α` to `as_type α`. -/
@[simps]
noncomputable def objAsTypeToAsType : ObjAsType α ⥤ AsType α
    where
  obj := id
  map i j := Fintype.equivFin _
#align category_theory.fin_category.obj_as_type_to_as_type CategoryTheory.FinCategory.objAsTypeToAsType
-/

#print CategoryTheory.FinCategory.asTypeEquivObjAsType /-
/-- The constructed category (`as_type α`) is equivalent to `obj_as_type α`. -/
noncomputable def asTypeEquivObjAsType : AsType α ≌ ObjAsType α :=
  Equivalence.mk (asTypeToObjAsType α) (objAsTypeToAsType α)
    (NatIso.ofComponents Iso.refl fun _ _ _ => by dsimp; simp)
    (NatIso.ofComponents Iso.refl fun _ _ _ => by dsimp; simp)
#align category_theory.fin_category.as_type_equiv_obj_as_type CategoryTheory.FinCategory.asTypeEquivObjAsType
-/

#print CategoryTheory.FinCategory.asTypeFinCategory /-
noncomputable instance asTypeFinCategory : FinCategory (AsType α) where
#align category_theory.fin_category.as_type_fin_category CategoryTheory.FinCategory.asTypeFinCategory
-/

#print CategoryTheory.FinCategory.equivAsType /-
/-- The constructed category (`as_type α`) is indeed equivalent to `α`. -/
noncomputable def equivAsType : AsType α ≌ α :=
  (asTypeEquivObjAsType α).trans (objAsTypeEquiv α)
#align category_theory.fin_category.equiv_as_type CategoryTheory.FinCategory.equivAsType
-/

end FinCategory

open Opposite

#print CategoryTheory.finCategoryOpposite /-
/-- The opposite of a finite category is finite.
-/
instance finCategoryOpposite {J : Type v} [SmallCategory J] [FinCategory J] : FinCategory Jᵒᵖ
    where
  fintypeObj := Fintype.ofEquiv _ equivToOpposite
  fintypeHom j j' := Fintype.ofEquiv _ (opEquiv j j').symm
#align category_theory.fin_category_opposite CategoryTheory.finCategoryOpposite
-/

#print CategoryTheory.finCategoryUlift /-
/-- Applying `ulift` to morphisms and objects of a category preserves finiteness. -/
instance finCategoryUlift {J : Type v} [SmallCategory J] [FinCategory J] :
    FinCategory.{max w v} (ULiftHom.{w, max w v} (ULift.{w, v} J))
    where fintypeObj := ULift.fintype J
#align category_theory.fin_category_ulift CategoryTheory.finCategoryUlift
-/

end CategoryTheory

