/-
Copyright (c) 2022 Andrew Yang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Andrew Yang
-/
import AlgebraicGeometry.Morphisms.Basic
import Topology.LocalAtTarget

#align_import algebraic_geometry.morphisms.universally_closed from "leanprover-community/mathlib"@"728ef9dbb281241906f25cbeb30f90d83e0bb451"

/-!
# Universally closed morphism

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A morphism of schemes `f : X ⟶ Y` is universally closed if `X ×[Y] Y' ⟶ Y'` is a closed map
for all base change `Y' ⟶ Y`.

We show that being universally closed is local at the target, and is stable under compositions and
base changes.

-/


noncomputable section

open CategoryTheory CategoryTheory.Limits Opposite TopologicalSpace

universe v u

namespace AlgebraicGeometry

variable {X Y : Scheme.{u}} (f : X ⟶ Y)

open CategoryTheory.MorphismProperty

open AlgebraicGeometry.MorphismProperty (topologically)

#print AlgebraicGeometry.UniversallyClosed /-
/-- A morphism of schemes `f : X ⟶ Y` is universally closed if the base change `X ×[Y] Y' ⟶ Y'`
along any morphism `Y' ⟶ Y` is (topologically) a closed map.
-/
@[mk_iff]
class UniversallyClosed (f : X ⟶ Y) : Prop where
  out : universally (AlgebraicGeometry.topologically @IsClosedMap) f
#align algebraic_geometry.universally_closed AlgebraicGeometry.UniversallyClosed
-/

#print AlgebraicGeometry.universallyClosed_eq /-
theorem universallyClosed_eq :
    @UniversallyClosed = universally (AlgebraicGeometry.topologically @IsClosedMap) := by ext X Y f;
  rw [universally_closed_iff]
#align algebraic_geometry.universally_closed_eq AlgebraicGeometry.universallyClosed_eq
-/

#print AlgebraicGeometry.universallyClosed_respectsIso /-
theorem universallyClosed_respectsIso : RespectsIso @UniversallyClosed :=
  universallyClosed_eq.symm ▸ universally_respectsIso (AlgebraicGeometry.topologically @IsClosedMap)
#align algebraic_geometry.universally_closed_respects_iso AlgebraicGeometry.universallyClosed_respectsIso
-/

#print AlgebraicGeometry.universallyClosed_stableUnderBaseChange /-
theorem universallyClosed_stableUnderBaseChange : StableUnderBaseChange @UniversallyClosed :=
  universallyClosed_eq.symm ▸
    universally_stableUnderBaseChange (AlgebraicGeometry.topologically @IsClosedMap)
#align algebraic_geometry.universally_closed_stable_under_base_change AlgebraicGeometry.universallyClosed_stableUnderBaseChange
-/

#print AlgebraicGeometry.universallyClosed_isStableUnderComposition /-
theorem universallyClosed_isStableUnderComposition : IsStableUnderComposition @UniversallyClosed :=
  by
  rw [universally_closed_eq]
  exact stable_under_composition.universally fun X Y Z f g hf hg => IsClosedMap.comp hg hf
#align algebraic_geometry.universally_closed_stable_under_composition AlgebraicGeometry.universallyClosed_isStableUnderComposition
-/

#print AlgebraicGeometry.universallyClosedTypeComp /-
instance universallyClosedTypeComp {X Y Z : Scheme} (f : X ⟶ Y) (g : Y ⟶ Z)
    [hf : UniversallyClosed f] [hg : UniversallyClosed g] : UniversallyClosed (f ≫ g) :=
  universallyClosed_isStableUnderComposition f g hf hg
#align algebraic_geometry.universally_closed_type_comp AlgebraicGeometry.universallyClosedTypeComp
-/

#print AlgebraicGeometry.universallyClosed_fst /-
instance universallyClosed_fst {X Y Z : Scheme} (f : X ⟶ Z) (g : Y ⟶ Z) [hg : UniversallyClosed g] :
    UniversallyClosed (pullback.fst : pullback f g ⟶ _) :=
  universallyClosed_stableUnderBaseChange.fst f g hg
#align algebraic_geometry.universally_closed_fst AlgebraicGeometry.universallyClosed_fst
-/

#print AlgebraicGeometry.universallyClosed_snd /-
instance universallyClosed_snd {X Y Z : Scheme} (f : X ⟶ Z) (g : Y ⟶ Z) [hf : UniversallyClosed f] :
    UniversallyClosed (pullback.snd : pullback f g ⟶ _) :=
  universallyClosed_stableUnderBaseChange.snd f g hf
#align algebraic_geometry.universally_closed_snd AlgebraicGeometry.universallyClosed_snd
-/

theorem morphismRestrict_base {X Y : Scheme} (f : X ⟶ Y) (U : Opens Y.carrier) :
    ⇑(f ∣_ U).1.base = U.1.restrictPreimage f.1 :=
  funext fun x => Subtype.ext <| morphismRestrict_base_coe f U x
#align algebraic_geometry.morphism_restrict_base AlgebraicGeometry.morphismRestrict_base

#print AlgebraicGeometry.universallyClosed_isLocalAtTarget /-
theorem universallyClosed_isLocalAtTarget : IsLocalAtTarget @UniversallyClosed :=
  by
  rw [universally_closed_eq]
  apply universally_is_local_at_target_of_morphism_restrict
  ·
    exact
      stable_under_composition.respects_iso (fun X Y Z f g hf hg => IsClosedMap.comp hg hf)
        fun X Y f => (TopCat.homeoOfIso (Scheme.forget_to_Top.map_iso f)).IsClosedMap
  · intro X Y f ι U hU H
    simp_rw [topologically, morphism_restrict_base] at H
    exact (isClosedMap_iff_isClosedMap_of_iSup_eq_top hU).mpr H
#align algebraic_geometry.universally_closed_is_local_at_target AlgebraicGeometry.universallyClosed_isLocalAtTarget
-/

theorem UniversallyClosed.openCover_iff {X Y : Scheme.{u}} (f : X ⟶ Y)
    (𝒰 : Scheme.OpenCover.{u} Y) :
    UniversallyClosed f ↔ ∀ i, UniversallyClosed (pullback.snd : pullback f (𝒰.map i) ⟶ _) :=
  universallyClosed_isLocalAtTarget.openCover_iff f 𝒰
#align algebraic_geometry.universally_closed.open_cover_iff AlgebraicGeometry.UniversallyClosed.openCover_iff

end AlgebraicGeometry

