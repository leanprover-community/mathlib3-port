/-
Copyright (c) 2022 Jujian Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jujian Zhang
-/
import Mathbin.Algebra.Category.GroupCat.Basic
import Mathbin.Algebra.Hom.Equiv.TypeTags

/-!
# Equivalence between `Group` and `AddGroup`

This file contains two equivalences:
* `Group_AddGroup_equivalence` : the equivalence between `Group` and `AddGroup` by sending
  `X : Group` to `additive X` and `Y : AddGroup` to `multiplicative Y`.
* `CommGroup_AddCommGroup_equivalence` : the equivalence between `CommGroup` and `AddCommGroup` by
  sending `X : CommGroup` to `additive X` and `Y : AddCommGroup` to `multiplicative Y`.
-/


open CategoryTheory

namespace GroupCat

/-- The functor `Group ⥤ AddGroup` by sending `X ↦ additive X` and `f ↦ f`.
-/
@[simps]
def toAddGroup : GroupCat ⥤ AddGroupCat where
  obj X := AddGroupCat.of (Additive X)
  map X Y := MonoidHom.toAdditive

end GroupCat

namespace CommGroupCat

/-- The functor `CommGroup ⥤ AddCommGroup` by sending `X ↦ additive X` and `f ↦ f`.
-/
@[simps]
def toAddCommGroup : CommGroupCat ⥤ AddCommGroupCat where
  obj X := AddCommGroupCat.of (Additive X)
  map X Y := MonoidHom.toAdditive

end CommGroupCat

namespace AddGroupCat

/-- The functor `AddGroup ⥤ Group` by sending `X ↦ multiplicative Y` and `f ↦ f`.
-/
@[simps]
def toGroup : AddGroupCat ⥤ GroupCat where
  obj X := GroupCat.of (Multiplicative X)
  map X Y := AddMonoidHom.toMultiplicative

end AddGroupCat

namespace AddCommGroupCat

/-- The functor `AddCommGroup ⥤ CommGroup` by sending `X ↦ multiplicative Y` and `f ↦ f`.
-/
@[simps]
def toCommGroup : AddCommGroupCat ⥤ CommGroupCat where
  obj X := CommGroupCat.of (Multiplicative X)
  map X Y := AddMonoidHom.toMultiplicative

end AddCommGroupCat

/-- The equivalence of categories between `Group` and `AddGroup`
-/
@[simps]
def groupAddGroupEquivalence : GroupCat ≌ AddGroupCat :=
  Equivalence.mk GroupCat.toAddGroup AddGroupCat.toGroup
    (NatIso.ofComponents (fun X => MulEquiv.toGroupIso (MulEquiv.multiplicativeAdditive X)) fun X Y f => rfl)
    (NatIso.ofComponents (fun X => AddEquiv.toAddGroupIso (AddEquiv.additiveMultiplicative X)) fun X Y f => rfl)

/-- The equivalence of categories between `CommGroup` and `AddCommGroup`.
-/
@[simps]
def commGroupAddCommGroupEquivalence : CommGroupCat ≌ AddCommGroupCat :=
  Equivalence.mk CommGroupCat.toAddCommGroup AddCommGroupCat.toCommGroup
    (NatIso.ofComponents (fun X => MulEquiv.toCommGroupIso (MulEquiv.multiplicativeAdditive X)) fun X Y f => rfl)
    (NatIso.ofComponents (fun X => AddEquiv.toAddCommGroupIso (AddEquiv.additiveMultiplicative X)) fun X Y f => rfl)

