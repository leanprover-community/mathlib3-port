/-
Copyright (c) 2021 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin
-/
import Topology.Category.Profinite.Basic
import Topology.StoneCech
import CategoryTheory.Preadditive.Projective

#align_import topology.category.Profinite.projective from "leanprover-community/mathlib"@"ef55335933293309ff8c0b1d20ffffeecbe5c39f"

/-!
# Profinite sets have enough projectives

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we show that `Profinite` has enough projectives.

## Main results

Let `X` be a profinite set.

* `Profinite.projective_ultrafilter`: the space `ultrafilter X` is a projective object
* `Profinite.projective_presentation`: the natural map `ultrafilter X → X`
  is a projective presentation

-/


noncomputable section

universe u v w

open CategoryTheory Function

namespace Profinite

#print Profinite.projective_ultrafilter /-
instance projective_ultrafilter (X : Type u) : Projective (of <| Ultrafilter X)
    where Factors Y Z f g hg := by
    rw [epi_iff_surjective] at hg
    obtain ⟨g', hg'⟩ := hg.has_right_inverse
    let t : X → Y := g' ∘ f ∘ (pure : X → Ultrafilter X)
    let h : Ultrafilter X → Y := Ultrafilter.extend t
    have hh : Continuous h := continuous_ultrafilter_extend _
    use⟨h, hh⟩
    apply faithful.map_injective (forget Profinite)
    simp only [forget_map_eq_coe, ContinuousMap.coe_mk, coe_comp]
    refine' dense_range_pure.equalizer (g.continuous.comp hh) f.continuous _
    rw [comp.assoc, ultrafilter_extend_extends, ← comp.assoc, hg'.comp_eq_id, comp.left_id]
#align Profinite.projective_ultrafilter Profinite.projective_ultrafilter
-/

#print Profinite.projectivePresentation /-
/-- For any profinite `X`, the natural map `ultrafilter X → X` is a projective presentation. -/
def projectivePresentation (X : Profinite.{u}) : ProjectivePresentation X
    where
  P := of <| Ultrafilter X
  f := ⟨_, continuous_ultrafilter_extend id⟩
  Projective := Profinite.projective_ultrafilter X
  Epi :=
    ConcreteCategory.epi_of_surjective _ fun x =>
      ⟨(pure x : Ultrafilter X), congr_fun (ultrafilter_extend_extends (𝟙 X)) x⟩
#align Profinite.projective_presentation Profinite.projectivePresentation
-/

instance : EnoughProjectives Profinite.{u} where presentation X := ⟨projectivePresentation X⟩

end Profinite

