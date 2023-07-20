/-
Copyright (c) 2021 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import Mathbin.Algebra.Homology.HomologicalComplex

#align_import algebra.homology.flip from "leanprover-community/mathlib"@"8eb9c42d4d34c77f6ee84ea766ae4070233a973c"

/-!
# Flip a complex of complexes

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

For now we don't have double complexes as a distinct thing,
but we can model them as complexes of complexes.

Here we show how to flip a complex of complexes over the diagonal,
exchanging the horizontal and vertical directions.

-/


universe v u

open CategoryTheory CategoryTheory.Limits

namespace HomologicalComplex

variable {V : Type u} [Category.{v} V] [HasZeroMorphisms V]

variable {ι : Type _} {c : ComplexShape ι} {ι' : Type _} {c' : ComplexShape ι'}

#print HomologicalComplex.flipObj /-
/-- Flip a complex of complexes over the diagonal,
exchanging the horizontal and vertical directions.
-/
@[simps]
def flipObj (C : HomologicalComplex (HomologicalComplex V c) c') :
    HomologicalComplex (HomologicalComplex V c') c
    where
  pt i :=
    { pt := fun j => (C.pt j).pt i
      d := fun j j' => (C.d j j').f i
      shape' := fun j j' w => by rw [C.shape j j' w]; simp
      d_comp_d' := fun j₁ j₂ j₃ _ _ => congr_hom (C.d_comp_d j₁ j₂ j₃) i }
  d i i' :=
    { f := fun j => (C.pt j).d i i'
      comm' := fun j j' h => ((C.d j j').comm i i').symm }
  shape' i i' w := by ext j; exact (C.X j).shape i i' w
#align homological_complex.flip_obj HomologicalComplex.flipObj
-/

variable (V c c')

#print HomologicalComplex.flip /-
/-- Flipping a complex of complexes over the diagonal, as a functor. -/
@[simps]
def flip :
    HomologicalComplex (HomologicalComplex V c) c' ⥤ HomologicalComplex (HomologicalComplex V c') c
    where
  obj C := flipObj C
  map C D f :=
    {
      f := fun i =>
        { f := fun j => (f.f j).f i
          comm' := fun j j' h => congr_hom (f.comm j j') i } }
#align homological_complex.flip HomologicalComplex.flip
-/

#print HomologicalComplex.flipEquivalenceUnitIso /-
/-- Auxiliary definition for `homological_complex.flip_equivalence` .-/
@[simps]
def flipEquivalenceUnitIso :
    𝟭 (HomologicalComplex (HomologicalComplex V c) c') ≅ flip V c c' ⋙ flip V c' c :=
  NatIso.ofComponents
    (fun C =>
      { Hom :=
          { f := fun i => { f := fun j => 𝟙 ((C.pt i).pt j) }
            comm' := fun i j h => by ext; dsimp; simp only [category.id_comp, category.comp_id] }
        inv :=
          { f := fun i => { f := fun j => 𝟙 ((C.pt i).pt j) }
            comm' := fun i j h => by ext; dsimp; simp only [category.id_comp, category.comp_id] } })
    fun X Y f => by ext; dsimp; simp only [category.id_comp, category.comp_id]
#align homological_complex.flip_equivalence_unit_iso HomologicalComplex.flipEquivalenceUnitIso
-/

#print HomologicalComplex.flipEquivalenceCounitIso /-
/-- Auxiliary definition for `homological_complex.flip_equivalence` .-/
@[simps]
def flipEquivalenceCounitIso :
    flip V c' c ⋙ flip V c c' ≅ 𝟭 (HomologicalComplex (HomologicalComplex V c') c) :=
  NatIso.ofComponents
    (fun C =>
      { Hom :=
          { f := fun i => { f := fun j => 𝟙 ((C.pt i).pt j) }
            comm' := fun i j h => by ext; dsimp; simp only [category.id_comp, category.comp_id] }
        inv :=
          { f := fun i => { f := fun j => 𝟙 ((C.pt i).pt j) }
            comm' := fun i j h => by ext; dsimp; simp only [category.id_comp, category.comp_id] } })
    fun X Y f => by ext; dsimp; simp only [category.id_comp, category.comp_id]
#align homological_complex.flip_equivalence_counit_iso HomologicalComplex.flipEquivalenceCounitIso
-/

#print HomologicalComplex.flipEquivalence /-
/-- Flipping a complex of complexes over the diagonal, as an equivalence of categories. -/
@[simps]
def flipEquivalence :
    HomologicalComplex (HomologicalComplex V c) c' ≌ HomologicalComplex (HomologicalComplex V c') c
    where
  Functor := flip V c c'
  inverse := flip V c' c
  unitIso := flipEquivalenceUnitIso V c c'
  counitIso := flipEquivalenceCounitIso V c c'
#align homological_complex.flip_equivalence HomologicalComplex.flipEquivalence
-/

end HomologicalComplex

