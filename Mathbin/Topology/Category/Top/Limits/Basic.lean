/-
Copyright (c) 2017 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Massot, Scott Morrison, Mario Carneiro, Andrew Yang

! This file was ported from Lean 3 source module topology.category.Top.limits.basic
! leanprover-community/mathlib commit f2b757fc5c341d88741b9c4630b1e8ba973c5726
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Category.Top.Basic
import Mathbin.CategoryTheory.Limits.ConcreteCategory

/-!
# The category of topological spaces has all limits and colimits

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Further, these limits and colimits are preserved by the forgetful functor --- that is, the
underlying types are just the limits in the category of types.
-/


open TopologicalSpace

open CategoryTheory

open CategoryTheory.Limits

open Opposite

universe u v w

noncomputable section

namespace TopCat

variable {J : Type v} [SmallCategory J]

local notation "forget" => forget TopCat

#print TopCat.limitCone /-
/-- A choice of limit cone for a functor `F : J ⥤ Top`.
Generally you should just use `limit.cone F`, unless you need the actual definition
(which is in terms of `types.limit_cone`).
-/
def limitCone (F : J ⥤ TopCat.{max v u}) : Cone F
    where
  pt := TopCat.of {u : ∀ j : J, F.obj j | ∀ {i j : J} (f : i ⟶ j), F.map f (u i) = u j}
  π :=
    {
      app := fun j =>
        { toFun := fun u => u.val j
          continuous_toFun :=
            show Continuous ((fun u : ∀ j : J, F.obj j => u j) ∘ Subtype.val) by continuity } }
#align Top.limit_cone TopCat.limitCone
-/

#print TopCat.limitConeInfi /-
/-- A choice of limit cone for a functor `F : J ⥤ Top` whose topology is defined as an
infimum of topologies infimum.
Generally you should just use `limit.cone F`, unless you need the actual definition
(which is in terms of `types.limit_cone`).
-/
def limitConeInfi (F : J ⥤ TopCat.{max v u}) : Cone F
    where
  pt :=
    ⟨(Types.limitCone (F ⋙ forget)).pt,
      ⨅ j, (F.obj j).str.induced ((Types.limitCone (F ⋙ forget)).π.app j)⟩
  π :=
    { app := fun j =>
        ⟨(Types.limitCone (F ⋙ forget)).π.app j, continuous_iff_le_induced.mpr (iInf_le _ _)⟩
      naturality' := fun j j' f =>
        ContinuousMap.coe_injective ((Types.limitCone (F ⋙ forget)).π.naturality f) }
#align Top.limit_cone_infi TopCat.limitConeInfi
-/

#print TopCat.limitConeIsLimit /-
/-- The chosen cone `Top.limit_cone F` for a functor `F : J ⥤ Top` is a limit cone.
Generally you should just use `limit.is_limit F`, unless you need the actual definition
(which is in terms of `types.limit_cone_is_limit`).
-/
def limitConeIsLimit (F : J ⥤ TopCat.{max v u}) : IsLimit (limitCone F)
    where
  lift S := { toFun := fun x => ⟨fun j => S.π.app _ x, fun i j f => by dsimp; erw [← S.w f]; rfl⟩ }
  uniq S m h := by ext : 3; simpa [← h]
#align Top.limit_cone_is_limit TopCat.limitConeIsLimit
-/

#print TopCat.limitConeInfiIsLimit /-
/-- The chosen cone `Top.limit_cone_infi F` for a functor `F : J ⥤ Top` is a limit cone.
Generally you should just use `limit.is_limit F`, unless you need the actual definition
(which is in terms of `types.limit_cone_is_limit`).
-/
def limitConeInfiIsLimit (F : J ⥤ TopCat.{max v u}) : IsLimit (limitConeInfi F) :=
  by
  refine' is_limit.of_faithful forget (types.limit_cone_is_limit _) (fun s => ⟨_, _⟩) fun s => rfl
  exact
    continuous_iff_coinduced_le.mpr
      (le_iInf fun j =>
        coinduced_le_iff_le_induced.mp <|
          (continuous_iff_coinduced_le.mp (s.π.app j).Continuous : _))
#align Top.limit_cone_infi_is_limit TopCat.limitConeInfiIsLimit
-/

#print TopCat.topCat_hasLimitsOfSize /-
instance topCat_hasLimitsOfSize : HasLimitsOfSize.{v} TopCat.{max v u}
    where HasLimitsOfShape J 𝒥 :=
    {
      HasLimit := fun F =>
        has_limit.mk
          { Cone := limit_cone F
            IsLimit := limit_cone_is_limit F } }
#align Top.Top_has_limits_of_size TopCat.topCat_hasLimitsOfSize
-/

#print TopCat.topCat_hasLimits /-
instance topCat_hasLimits : HasLimits TopCat.{u} :=
  TopCat.topCat_hasLimitsOfSize.{u, u}
#align Top.Top_has_limits TopCat.topCat_hasLimits
-/

#print TopCat.forgetPreservesLimitsOfSize /-
instance forgetPreservesLimitsOfSize :
    PreservesLimitsOfSize.{v, v} (forget : TopCat.{max v u} ⥤ Type max v u)
    where PreservesLimitsOfShape J 𝒥 :=
    {
      PreservesLimit := fun F =>
        preserves_limit_of_preserves_limit_cone (limit_cone_is_limit F)
          (types.limit_cone_is_limit (F ⋙ forget)) }
#align Top.forget_preserves_limits_of_size TopCat.forgetPreservesLimitsOfSize
-/

#print TopCat.forgetPreservesLimits /-
instance forgetPreservesLimits : PreservesLimits (forget : TopCat.{u} ⥤ Type u) :=
  TopCat.forgetPreservesLimitsOfSize.{u, u}
#align Top.forget_preserves_limits TopCat.forgetPreservesLimits
-/

#print TopCat.colimitCocone /-
/-- A choice of colimit cocone for a functor `F : J ⥤ Top`.
Generally you should just use `colimit.coone F`, unless you need the actual definition
(which is in terms of `types.colimit_cocone`).
-/
def colimitCocone (F : J ⥤ TopCat.{max v u}) : Cocone F
    where
  pt :=
    ⟨(Types.colimitCocone (F ⋙ forget)).pt,
      ⨆ j, (F.obj j).str.coinduced ((Types.colimitCocone (F ⋙ forget)).ι.app j)⟩
  ι :=
    { app := fun j =>
        ⟨(Types.colimitCocone (F ⋙ forget)).ι.app j, continuous_iff_coinduced_le.mpr (le_iSup _ j)⟩
      naturality' := fun j j' f =>
        ContinuousMap.coe_injective ((Types.colimitCocone (F ⋙ forget)).ι.naturality f) }
#align Top.colimit_cocone TopCat.colimitCocone
-/

#print TopCat.colimitCoconeIsColimit /-
/-- The chosen cocone `Top.colimit_cocone F` for a functor `F : J ⥤ Top` is a colimit cocone.
Generally you should just use `colimit.is_colimit F`, unless you need the actual definition
(which is in terms of `types.colimit_cocone_is_colimit`).
-/
def colimitCoconeIsColimit (F : J ⥤ TopCat.{max v u}) : IsColimit (colimitCocone F) :=
  by
  refine'
    is_colimit.of_faithful forget (types.colimit_cocone_is_colimit _) (fun s => ⟨_, _⟩) fun s => rfl
  exact
    continuous_iff_le_induced.mpr
      (iSup_le fun j =>
        coinduced_le_iff_le_induced.mp <|
          (continuous_iff_coinduced_le.mp (s.ι.app j).Continuous : _))
#align Top.colimit_cocone_is_colimit TopCat.colimitCoconeIsColimit
-/

#print TopCat.topCat_hasColimitsOfSize /-
instance topCat_hasColimitsOfSize : HasColimitsOfSize.{v} TopCat.{max v u}
    where HasColimitsOfShape J 𝒥 :=
    {
      HasColimit := fun F =>
        has_colimit.mk
          { Cocone := colimit_cocone F
            IsColimit := colimit_cocone_is_colimit F } }
#align Top.Top_has_colimits_of_size TopCat.topCat_hasColimitsOfSize
-/

#print TopCat.topCat_hasColimits /-
instance topCat_hasColimits : HasColimits TopCat.{u} :=
  TopCat.topCat_hasColimitsOfSize.{u, u}
#align Top.Top_has_colimits TopCat.topCat_hasColimits
-/

#print TopCat.forgetPreservesColimitsOfSize /-
instance forgetPreservesColimitsOfSize :
    PreservesColimitsOfSize.{v, v} (forget : TopCat.{max v u} ⥤ Type max v u)
    where PreservesColimitsOfShape J 𝒥 :=
    {
      PreservesColimit := fun F =>
        preserves_colimit_of_preserves_colimit_cocone (colimit_cocone_is_colimit F)
          (types.colimit_cocone_is_colimit (F ⋙ forget)) }
#align Top.forget_preserves_colimits_of_size TopCat.forgetPreservesColimitsOfSize
-/

#print TopCat.forgetPreservesColimits /-
instance forgetPreservesColimits : PreservesColimits (forget : TopCat.{u} ⥤ Type u) :=
  TopCat.forgetPreservesColimitsOfSize.{u, u}
#align Top.forget_preserves_colimits TopCat.forgetPreservesColimits
-/

#print TopCat.isTerminalPUnit /-
/-- The terminal object of `Top` is `punit`. -/
def isTerminalPUnit : IsTerminal (TopCat.of PUnit.{u + 1}) :=
  haveI : ∀ X, Unique (X ⟶ TopCat.of PUnit.{u + 1}) := fun X =>
    ⟨⟨⟨fun x => PUnit.unit, by continuity⟩⟩, fun f => by ext⟩
  limits.is_terminal.of_unique _
#align Top.is_terminal_punit TopCat.isTerminalPUnit
-/

#print TopCat.terminalIsoPUnit /-
/-- The terminal object of `Top` is `punit`. -/
def terminalIsoPUnit : ⊤_ TopCat.{u} ≅ TopCat.of PUnit :=
  terminalIsTerminal.uniqueUpToIso isTerminalPUnit
#align Top.terminal_iso_punit TopCat.terminalIsoPUnit
-/

#print TopCat.isInitialPEmpty /-
/-- The initial object of `Top` is `pempty`. -/
def isInitialPEmpty : IsInitial (TopCat.of PEmpty.{u + 1}) :=
  haveI : ∀ X, Unique (TopCat.of PEmpty.{u + 1} ⟶ X) := fun X =>
    ⟨⟨⟨fun x => x.elim, by continuity⟩⟩, fun f => by ext ⟨⟩⟩
  limits.is_initial.of_unique _
#align Top.is_initial_pempty TopCat.isInitialPEmpty
-/

#print TopCat.initialIsoPEmpty /-
/-- The initial object of `Top` is `pempty`. -/
def initialIsoPEmpty : ⊥_ TopCat.{u} ≅ TopCat.of PEmpty :=
  initialIsInitial.uniqueUpToIso isInitialPEmpty
#align Top.initial_iso_pempty TopCat.initialIsoPEmpty
-/

end TopCat

