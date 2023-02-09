/-
Copyright (c) 2021 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel

! This file was ported from Lean 3 source module algebra.category.Group.subobject
! leanprover-community/mathlib commit d101e93197bb5f6ea89bd7ba386b7f7dff1f3903
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Category.Group.ZModuleEquivalence
import Mathbin.Algebra.Category.Module.Subobject

/-!
# The category of abelian groups is well-powered
-/


open CategoryTheory

universe u

namespace AddCommGroupCat

instance wellPowered_addCommGroupCat : WellPowered AddCommGroupCat.{u} :=
  wellPowered_of_equiv (forget₂ (ModuleCat.{u} ℤ) AddCommGroupCat.{u}).asEquivalence
#align AddCommGroup.well_powered_AddCommGroup AddCommGroupCat.wellPowered_addCommGroupCat

end AddCommGroupCat

