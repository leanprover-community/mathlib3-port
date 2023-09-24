/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta, Scott Morrison
-/
import CategoryTheory.Subobject.Basic
import CategoryTheory.Preadditive.Basic

#align_import category_theory.subobject.factor_thru from "leanprover-community/mathlib"@"ce38d86c0b2d427ce208c3cee3159cb421d2b3c4"

/-!
# Factoring through subobjects

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The predicate `h : P.factors f`, for `P : subobject Y` and `f : X ⟶ Y`
asserts the existence of some `P.factor_thru f : X ⟶ (P : C)` making the obvious diagram commute.

-/


universe v₁ v₂ u₁ u₂

noncomputable section

open CategoryTheory CategoryTheory.Category CategoryTheory.Limits

variable {C : Type u₁} [Category.{v₁} C] {X Y Z : C}

variable {D : Type u₂} [Category.{v₂} D]

namespace CategoryTheory

namespace MonoOver

#print CategoryTheory.MonoOver.Factors /-
/-- When `f : X ⟶ Y` and `P : mono_over Y`,
`P.factors f` expresses that there exists a factorisation of `f` through `P`.
Given `h : P.factors f`, you can recover the morphism as `P.factor_thru f h`.
-/
def Factors {X Y : C} (P : MonoOver Y) (f : X ⟶ Y) : Prop :=
  ∃ g : X ⟶ (P : C), g ≫ P.arrow = f
#align category_theory.mono_over.factors CategoryTheory.MonoOver.Factors
-/

#print CategoryTheory.MonoOver.factors_congr /-
theorem factors_congr {X : C} {f g : MonoOver X} {Y : C} (h : Y ⟶ X) (e : f ≅ g) :
    f.Factors h ↔ g.Factors h :=
  ⟨fun ⟨u, hu⟩ => ⟨u ≫ ((MonoOver.forget _).map e.Hom).left, by simp [hu]⟩, fun ⟨u, hu⟩ =>
    ⟨u ≫ ((MonoOver.forget _).map e.inv).left, by simp [hu]⟩⟩
#align category_theory.mono_over.factors_congr CategoryTheory.MonoOver.factors_congr
-/

#print CategoryTheory.MonoOver.factorThru /-
/-- `P.factor_thru f h` provides a factorisation of `f : X ⟶ Y` through some `P : mono_over Y`,
given the evidence `h : P.factors f` that such a factorisation exists. -/
def factorThru {X Y : C} (P : MonoOver Y) (f : X ⟶ Y) (h : Factors P f) : X ⟶ (P : C) :=
  Classical.choose h
#align category_theory.mono_over.factor_thru CategoryTheory.MonoOver.factorThru
-/

end MonoOver

namespace Subobject

#print CategoryTheory.Subobject.Factors /-
/-- When `f : X ⟶ Y` and `P : subobject Y`,
`P.factors f` expresses that there exists a factorisation of `f` through `P`.
Given `h : P.factors f`, you can recover the morphism as `P.factor_thru f h`.
-/
def Factors {X Y : C} (P : Subobject Y) (f : X ⟶ Y) : Prop :=
  Quotient.liftOn' P (fun P => P.Factors f)
    (by
      rintro P Q ⟨h⟩
      apply propext
      constructor
      · rintro ⟨i, w⟩
        exact ⟨i ≫ h.hom.left, by erw [category.assoc, over.w h.hom, w]⟩
      · rintro ⟨i, w⟩
        exact ⟨i ≫ h.inv.left, by erw [category.assoc, over.w h.inv, w]⟩)
#align category_theory.subobject.factors CategoryTheory.Subobject.Factors
-/

#print CategoryTheory.Subobject.mk_factors_iff /-
@[simp]
theorem mk_factors_iff {X Y Z : C} (f : Y ⟶ X) [Mono f] (g : Z ⟶ X) :
    (Subobject.mk f).Factors g ↔ (MonoOver.mk' f).Factors g :=
  Iff.rfl
#align category_theory.subobject.mk_factors_iff CategoryTheory.Subobject.mk_factors_iff
-/

#print CategoryTheory.Subobject.mk_factors_self /-
theorem mk_factors_self (f : X ⟶ Y) [Mono f] : (mk f).Factors f :=
  ⟨𝟙 _, by simp⟩
#align category_theory.subobject.mk_factors_self CategoryTheory.Subobject.mk_factors_self
-/

#print CategoryTheory.Subobject.factors_iff /-
theorem factors_iff {X Y : C} (P : Subobject Y) (f : X ⟶ Y) :
    P.Factors f ↔ (representative.obj P).Factors f :=
  Quot.inductionOn P fun a => MonoOver.factors_congr _ (representativeIso _).symm
#align category_theory.subobject.factors_iff CategoryTheory.Subobject.factors_iff
-/

#print CategoryTheory.Subobject.factors_self /-
theorem factors_self {X : C} (P : Subobject X) : P.Factors P.arrow :=
  (factors_iff _ _).mpr ⟨𝟙 P, by simp⟩
#align category_theory.subobject.factors_self CategoryTheory.Subobject.factors_self
-/

#print CategoryTheory.Subobject.factors_comp_arrow /-
theorem factors_comp_arrow {X Y : C} {P : Subobject Y} (f : X ⟶ P) : P.Factors (f ≫ P.arrow) :=
  (factors_iff _ _).mpr ⟨f, rfl⟩
#align category_theory.subobject.factors_comp_arrow CategoryTheory.Subobject.factors_comp_arrow
-/

#print CategoryTheory.Subobject.factors_of_factors_right /-
theorem factors_of_factors_right {X Y Z : C} {P : Subobject Z} (f : X ⟶ Y) {g : Y ⟶ Z}
    (h : P.Factors g) : P.Factors (f ≫ g) := by
  revert P
  refine' Quotient.ind' _
  intro P
  rintro ⟨g, rfl⟩
  exact ⟨f ≫ g, by simp⟩
#align category_theory.subobject.factors_of_factors_right CategoryTheory.Subobject.factors_of_factors_right
-/

#print CategoryTheory.Subobject.factors_zero /-
theorem factors_zero [HasZeroMorphisms C] {X Y : C} {P : Subobject Y} : P.Factors (0 : X ⟶ Y) :=
  (factors_iff _ _).mpr ⟨0, by simp⟩
#align category_theory.subobject.factors_zero CategoryTheory.Subobject.factors_zero
-/

#print CategoryTheory.Subobject.factors_of_le /-
theorem factors_of_le {Y Z : C} {P Q : Subobject Y} (f : Z ⟶ Y) (h : P ≤ Q) :
    P.Factors f → Q.Factors f := by simp only [factors_iff];
  exact fun ⟨u, hu⟩ => ⟨u ≫ of_le _ _ h, by simp [← hu]⟩
#align category_theory.subobject.factors_of_le CategoryTheory.Subobject.factors_of_le
-/

#print CategoryTheory.Subobject.factorThru /-
/-- `P.factor_thru f h` provides a factorisation of `f : X ⟶ Y` through some `P : subobject Y`,
given the evidence `h : P.factors f` that such a factorisation exists. -/
def factorThru {X Y : C} (P : Subobject Y) (f : X ⟶ Y) (h : Factors P f) : X ⟶ P :=
  Classical.choose ((factors_iff _ _).mp h)
#align category_theory.subobject.factor_thru CategoryTheory.Subobject.factorThru
-/

#print CategoryTheory.Subobject.factorThru_arrow /-
@[simp, reassoc]
theorem factorThru_arrow {X Y : C} (P : Subobject Y) (f : X ⟶ Y) (h : Factors P f) :
    P.factorThru f h ≫ P.arrow = f :=
  Classical.choose_spec ((factors_iff _ _).mp h)
#align category_theory.subobject.factor_thru_arrow CategoryTheory.Subobject.factorThru_arrow
-/

#print CategoryTheory.Subobject.factorThru_self /-
@[simp]
theorem factorThru_self {X : C} (P : Subobject X) (h) : P.factorThru P.arrow h = 𝟙 P := by ext; simp
#align category_theory.subobject.factor_thru_self CategoryTheory.Subobject.factorThru_self
-/

#print CategoryTheory.Subobject.factorThru_mk_self /-
@[simp]
theorem factorThru_mk_self (f : X ⟶ Y) [Mono f] :
    (mk f).factorThru f (mk_factors_self f) = (underlyingIso f).inv := by ext; simp
#align category_theory.subobject.factor_thru_mk_self CategoryTheory.Subobject.factorThru_mk_self
-/

#print CategoryTheory.Subobject.factorThru_comp_arrow /-
@[simp]
theorem factorThru_comp_arrow {X Y : C} {P : Subobject Y} (f : X ⟶ P) (h) :
    P.factorThru (f ≫ P.arrow) h = f := by ext; simp
#align category_theory.subobject.factor_thru_comp_arrow CategoryTheory.Subobject.factorThru_comp_arrow
-/

#print CategoryTheory.Subobject.factorThru_eq_zero /-
@[simp]
theorem factorThru_eq_zero [HasZeroMorphisms C] {X Y : C} {P : Subobject Y} {f : X ⟶ Y}
    {h : Factors P f} : P.factorThru f h = 0 ↔ f = 0 :=
  by
  fconstructor
  · intro w
    replace w := w =≫ P.arrow
    simpa using w
  · rintro rfl
    ext; simp
#align category_theory.subobject.factor_thru_eq_zero CategoryTheory.Subobject.factorThru_eq_zero
-/

#print CategoryTheory.Subobject.factorThru_right /-
theorem factorThru_right {X Y Z : C} {P : Subobject Z} (f : X ⟶ Y) (g : Y ⟶ Z) (h : P.Factors g) :
    f ≫ P.factorThru g h = P.factorThru (f ≫ g) (factors_of_factors_right f h) :=
  by
  apply (cancel_mono P.arrow).mp
  simp
#align category_theory.subobject.factor_thru_right CategoryTheory.Subobject.factorThru_right
-/

#print CategoryTheory.Subobject.factorThru_zero /-
@[simp]
theorem factorThru_zero [HasZeroMorphisms C] {X Y : C} {P : Subobject Y}
    (h : P.Factors (0 : X ⟶ Y)) : P.factorThru 0 h = 0 := by simp
#align category_theory.subobject.factor_thru_zero CategoryTheory.Subobject.factorThru_zero
-/

#print CategoryTheory.Subobject.factorThru_ofLE /-
-- `h` is an explicit argument here so we can use
-- `rw factor_thru_le h`, obtaining a subgoal `P.factors f`.
-- (While the reverse direction looks plausible as a simp lemma, it seems to be unproductive.)
theorem factorThru_ofLE {Y Z : C} {P Q : Subobject Y} {f : Z ⟶ Y} (h : P ≤ Q) (w : P.Factors f) :
    Q.factorThru f (factors_of_le f h w) = P.factorThru f w ≫ ofLE P Q h := by ext; simp
#align category_theory.subobject.factor_thru_of_le CategoryTheory.Subobject.factorThru_ofLE
-/

section Preadditive

variable [Preadditive C]

#print CategoryTheory.Subobject.factors_add /-
theorem factors_add {X Y : C} {P : Subobject Y} (f g : X ⟶ Y) (wf : P.Factors f)
    (wg : P.Factors g) : P.Factors (f + g) :=
  (factors_iff _ _).mpr ⟨P.factorThru f wf + P.factorThru g wg, by simp⟩
#align category_theory.subobject.factors_add CategoryTheory.Subobject.factors_add
-/

#print CategoryTheory.Subobject.factorThru_add /-
-- This can't be a `simp` lemma as `wf` and `wg` may not exist.
-- However you can `rw` by it to assert that `f` and `g` factor through `P` separately.
theorem factorThru_add {X Y : C} {P : Subobject Y} (f g : X ⟶ Y) (w : P.Factors (f + g))
    (wf : P.Factors f) (wg : P.Factors g) :
    P.factorThru (f + g) w = P.factorThru f wf + P.factorThru g wg := by ext; simp
#align category_theory.subobject.factor_thru_add CategoryTheory.Subobject.factorThru_add
-/

#print CategoryTheory.Subobject.factors_left_of_factors_add /-
theorem factors_left_of_factors_add {X Y : C} {P : Subobject Y} (f g : X ⟶ Y)
    (w : P.Factors (f + g)) (wg : P.Factors g) : P.Factors f :=
  (factors_iff _ _).mpr ⟨P.factorThru (f + g) w - P.factorThru g wg, by simp⟩
#align category_theory.subobject.factors_left_of_factors_add CategoryTheory.Subobject.factors_left_of_factors_add
-/

#print CategoryTheory.Subobject.factorThru_add_sub_factorThru_right /-
@[simp]
theorem factorThru_add_sub_factorThru_right {X Y : C} {P : Subobject Y} (f g : X ⟶ Y)
    (w : P.Factors (f + g)) (wg : P.Factors g) :
    P.factorThru (f + g) w - P.factorThru g wg =
      P.factorThru f (factors_left_of_factors_add f g w wg) :=
  by ext; simp
#align category_theory.subobject.factor_thru_add_sub_factor_thru_right CategoryTheory.Subobject.factorThru_add_sub_factorThru_right
-/

#print CategoryTheory.Subobject.factors_right_of_factors_add /-
theorem factors_right_of_factors_add {X Y : C} {P : Subobject Y} (f g : X ⟶ Y)
    (w : P.Factors (f + g)) (wf : P.Factors f) : P.Factors g :=
  (factors_iff _ _).mpr ⟨P.factorThru (f + g) w - P.factorThru f wf, by simp⟩
#align category_theory.subobject.factors_right_of_factors_add CategoryTheory.Subobject.factors_right_of_factors_add
-/

#print CategoryTheory.Subobject.factorThru_add_sub_factorThru_left /-
@[simp]
theorem factorThru_add_sub_factorThru_left {X Y : C} {P : Subobject Y} (f g : X ⟶ Y)
    (w : P.Factors (f + g)) (wf : P.Factors f) :
    P.factorThru (f + g) w - P.factorThru f wf =
      P.factorThru g (factors_right_of_factors_add f g w wf) :=
  by ext; simp
#align category_theory.subobject.factor_thru_add_sub_factor_thru_left CategoryTheory.Subobject.factorThru_add_sub_factorThru_left
-/

end Preadditive

end Subobject

end CategoryTheory

