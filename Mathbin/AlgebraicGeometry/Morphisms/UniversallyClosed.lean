/-
Copyright (c) 2022 Andrew Yang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Andrew Yang
-/
import Mathbin.AlgebraicGeometry.Morphisms.Basic
import Mathbin.Topology.LocalAtTarget

/-!
# Universally closed morphism

A morphism of schemes `f : X ⟶ Y` is universally closed if `X ×[Y] Y' ⟶ Y'` is a closed map
for all base change `Y' ⟶ Y`.

We show that being universally closed is local at the target, and is stable under compositions and
base changes.

-/


noncomputable section

open CategoryTheory CategoryTheory.Limits Opposite TopologicalSpace

universe v u

namespace AlgebraicGeometry

variable {X Y : SchemeCat.{u}} (f : X ⟶ Y)

open CategoryTheory.MorphismProperty

open AlgebraicGeometry.MorphismProperty (Topologically)

/-- A morphism of schemes `f : X ⟶ Y` is universally closed if the base change `X ×[Y] Y' ⟶ Y'`
along any morphism `Y' ⟶ Y` is (topologically) a closed map.
-/
@[mk_iff]
class UniversallyClosed (f : X ⟶ Y) : Prop where
  out : Universally (Topologically @IsClosedMap) f

theorem universally_closed_eq : @UniversallyClosed = Universally (Topologically @IsClosedMap) := by
  ext X Y f
  rw [universally_closed_iff]

theorem universally_closed_respects_iso : RespectsIso @UniversallyClosed :=
  universally_closed_eq.symm ▸ universally_respects_iso (Topologically @IsClosedMap)

theorem universally_closed_stable_under_base_change : StableUnderBaseChange @UniversallyClosed :=
  universally_closed_eq.symm ▸ universally_stable_under_base_change (Topologically @IsClosedMap)

theorem universally_closed_stable_under_composition : StableUnderComposition @UniversallyClosed := by
  rw [universally_closed_eq]
  exact stable_under_composition.universally fun X Y Z f g hf hg => IsClosedMap.comp hg hf

instance universally_closed_type_comp {X Y Z : SchemeCat} (f : X ⟶ Y) (g : Y ⟶ Z) [hf : UniversallyClosed f]
    [hg : UniversallyClosed g] : UniversallyClosed (f ≫ g) :=
  universally_closed_stable_under_composition f g hf hg

instance universally_closed_fst {X Y Z : SchemeCat} (f : X ⟶ Z) (g : Y ⟶ Z) [hg : UniversallyClosed g] :
    UniversallyClosed (pullback.fst : pullback f g ⟶ _) :=
  universally_closed_stable_under_base_change.fst f g hg

instance universally_closed_snd {X Y Z : SchemeCat} (f : X ⟶ Z) (g : Y ⟶ Z) [hf : UniversallyClosed f] :
    UniversallyClosed (pullback.snd : pullback f g ⟶ _) :=
  universally_closed_stable_under_base_change.snd f g hf

theorem morphism_restrict_base {X Y : SchemeCat} (f : X ⟶ Y) (U : Opens Y.Carrier) :
    ⇑(f ∣_ U).1.base = U.1.restrictPreimage f.1 :=
  funext fun x => Subtype.ext <| morphism_restrict_base_coe f U x

theorem universallyClosedIsLocalAtTarget : PropertyIsLocalAtTarget @UniversallyClosed := by
  rw [universally_closed_eq]
  apply universally_is_local_at_target_of_morphism_restrict
  · exact
      stable_under_composition.respects_iso (fun X Y Z f g hf hg => IsClosedMap.comp hg hf) fun X Y f =>
        (TopCat.homeoOfIso (Scheme.forget_to_Top.map_iso f)).IsClosedMap
    
  · intro X Y f ι U hU H
    simp_rw [topologically, morphism_restrict_base] at H
    exact (is_closed_map_iff_is_closed_map_of_supr_eq_top hU).mpr H
    

theorem UniversallyClosed.open_cover_iff {X Y : SchemeCat.{u}} (f : X ⟶ Y) (𝒰 : SchemeCat.OpenCover.{u} Y) :
    UniversallyClosed f ↔ ∀ i, UniversallyClosed (pullback.snd : pullback f (𝒰.map i) ⟶ _) :=
  universallyClosedIsLocalAtTarget.open_cover_iff f 𝒰

end AlgebraicGeometry

