/-
Copyright (c) 2022 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module category_theory.limits.constructions.zero_objects
! leanprover-community/mathlib commit 1e05171a5e8cf18d98d9cf7b207540acb044acae
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.Shapes.Pullbacks
import Mathbin.CategoryTheory.Limits.Shapes.ZeroMorphisms
import Mathbin.CategoryTheory.Limits.Constructions.BinaryProducts

/-!
# Limits involving zero objects

Binary products and coproducts with a zero object always exist,
and pullbacks/pushouts over a zero object are products/coproducts.
-/


noncomputable section

open CategoryTheory

variable {C : Type _} [Category C]

namespace CategoryTheory.Limits

variable [HasZeroObject C] [HasZeroMorphisms C]

open ZeroObject

/-- The limit cone for the product with a zero object. -/
def binaryFanZeroLeft (X : C) : BinaryFan (0 : C) X :=
  BinaryFan.mk 0 (𝟙 X)
#align category_theory.limits.binary_fan_zero_left CategoryTheory.Limits.binaryFanZeroLeft

/-- The limit cone for the product with a zero object is limiting. -/
def binaryFanZeroLeftIsLimit (X : C) : IsLimit (binaryFanZeroLeft X) :=
  BinaryFan.isLimitMk (fun s => BinaryFan.snd s) (by tidy) (by tidy) (by tidy)
#align
  category_theory.limits.binary_fan_zero_left_is_limit CategoryTheory.Limits.binaryFanZeroLeftIsLimit

instance has_binary_product_zero_left (X : C) : HasBinaryProduct (0 : C) X :=
  HasLimit.mk ⟨_, binaryFanZeroLeftIsLimit X⟩
#align
  category_theory.limits.has_binary_product_zero_left CategoryTheory.Limits.has_binary_product_zero_left

/-- A zero object is a left unit for categorical product. -/
def zeroProdIso (X : C) : (0 : C) ⨯ X ≅ X :=
  limit.isoLimitCone ⟨_, binaryFanZeroLeftIsLimit X⟩
#align category_theory.limits.zero_prod_iso CategoryTheory.Limits.zeroProdIso

@[simp]
theorem zero_prod_iso_hom (X : C) : (zeroProdIso X).Hom = Prod.snd :=
  rfl
#align category_theory.limits.zero_prod_iso_hom CategoryTheory.Limits.zero_prod_iso_hom

@[simp]
theorem zero_prod_iso_inv_snd (X : C) : (zeroProdIso X).inv ≫ Prod.snd = 𝟙 X :=
  by
  dsimp [zero_prod_iso, binary_fan_zero_left]
  simp
#align category_theory.limits.zero_prod_iso_inv_snd CategoryTheory.Limits.zero_prod_iso_inv_snd

/-- The limit cone for the product with a zero object. -/
def binaryFanZeroRight (X : C) : BinaryFan X (0 : C) :=
  BinaryFan.mk (𝟙 X) 0
#align category_theory.limits.binary_fan_zero_right CategoryTheory.Limits.binaryFanZeroRight

/-- The limit cone for the product with a zero object is limiting. -/
def binaryFanZeroRightIsLimit (X : C) : IsLimit (binaryFanZeroRight X) :=
  BinaryFan.isLimitMk (fun s => BinaryFan.fst s) (by tidy) (by tidy) (by tidy)
#align
  category_theory.limits.binary_fan_zero_right_is_limit CategoryTheory.Limits.binaryFanZeroRightIsLimit

instance has_binary_product_zero_right (X : C) : HasBinaryProduct X (0 : C) :=
  HasLimit.mk ⟨_, binaryFanZeroRightIsLimit X⟩
#align
  category_theory.limits.has_binary_product_zero_right CategoryTheory.Limits.has_binary_product_zero_right

/-- A zero object is a right unit for categorical product. -/
def prodZeroIso (X : C) : X ⨯ (0 : C) ≅ X :=
  limit.isoLimitCone ⟨_, binaryFanZeroRightIsLimit X⟩
#align category_theory.limits.prod_zero_iso CategoryTheory.Limits.prodZeroIso

@[simp]
theorem prod_zero_iso_hom (X : C) : (prodZeroIso X).Hom = Prod.fst :=
  rfl
#align category_theory.limits.prod_zero_iso_hom CategoryTheory.Limits.prod_zero_iso_hom

@[simp]
theorem prod_zero_iso_iso_inv_snd (X : C) : (prodZeroIso X).inv ≫ Prod.fst = 𝟙 X :=
  by
  dsimp [prod_zero_iso, binary_fan_zero_right]
  simp
#align
  category_theory.limits.prod_zero_iso_iso_inv_snd CategoryTheory.Limits.prod_zero_iso_iso_inv_snd

/-- The colimit cocone for the coproduct with a zero object. -/
def binaryCofanZeroLeft (X : C) : BinaryCofan (0 : C) X :=
  BinaryCofan.mk 0 (𝟙 X)
#align category_theory.limits.binary_cofan_zero_left CategoryTheory.Limits.binaryCofanZeroLeft

/-- The colimit cocone for the coproduct with a zero object is colimiting. -/
def binaryCofanZeroLeftIsColimit (X : C) : IsColimit (binaryCofanZeroLeft X) :=
  BinaryCofan.isColimitMk (fun s => BinaryCofan.inr s) (by tidy) (by tidy) (by tidy)
#align
  category_theory.limits.binary_cofan_zero_left_is_colimit CategoryTheory.Limits.binaryCofanZeroLeftIsColimit

instance has_binary_coproduct_zero_left (X : C) : HasBinaryCoproduct (0 : C) X :=
  HasColimit.mk ⟨_, binaryCofanZeroLeftIsColimit X⟩
#align
  category_theory.limits.has_binary_coproduct_zero_left CategoryTheory.Limits.has_binary_coproduct_zero_left

/-- A zero object is a left unit for categorical coproduct. -/
def zeroCoprodIso (X : C) : (0 : C) ⨿ X ≅ X :=
  colimit.isoColimitCocone ⟨_, binaryCofanZeroLeftIsColimit X⟩
#align category_theory.limits.zero_coprod_iso CategoryTheory.Limits.zeroCoprodIso

@[simp]
theorem inr_zero_coprod_iso_hom (X : C) : coprod.inr ≫ (zeroCoprodIso X).Hom = 𝟙 X :=
  by
  dsimp [zero_coprod_iso, binary_cofan_zero_left]
  simp
#align category_theory.limits.inr_zero_coprod_iso_hom CategoryTheory.Limits.inr_zero_coprod_iso_hom

@[simp]
theorem zero_coprod_iso_inv (X : C) : (zeroCoprodIso X).inv = coprod.inr :=
  rfl
#align category_theory.limits.zero_coprod_iso_inv CategoryTheory.Limits.zero_coprod_iso_inv

/-- The colimit cocone for the coproduct with a zero object. -/
def binaryCofanZeroRight (X : C) : BinaryCofan X (0 : C) :=
  BinaryCofan.mk (𝟙 X) 0
#align category_theory.limits.binary_cofan_zero_right CategoryTheory.Limits.binaryCofanZeroRight

/-- The colimit cocone for the coproduct with a zero object is colimiting. -/
def binaryCofanZeroRightIsColimit (X : C) : IsColimit (binaryCofanZeroRight X) :=
  BinaryCofan.isColimitMk (fun s => BinaryCofan.inl s) (by tidy) (by tidy) (by tidy)
#align
  category_theory.limits.binary_cofan_zero_right_is_colimit CategoryTheory.Limits.binaryCofanZeroRightIsColimit

instance has_binary_coproduct_zero_right (X : C) : HasBinaryCoproduct X (0 : C) :=
  HasColimit.mk ⟨_, binaryCofanZeroRightIsColimit X⟩
#align
  category_theory.limits.has_binary_coproduct_zero_right CategoryTheory.Limits.has_binary_coproduct_zero_right

/-- A zero object is a right unit for categorical coproduct. -/
def coprodZeroIso (X : C) : X ⨿ (0 : C) ≅ X :=
  colimit.isoColimitCocone ⟨_, binaryCofanZeroRightIsColimit X⟩
#align category_theory.limits.coprod_zero_iso CategoryTheory.Limits.coprodZeroIso

@[simp]
theorem inr_coprod_zeroiso_hom (X : C) : coprod.inl ≫ (coprodZeroIso X).Hom = 𝟙 X :=
  by
  dsimp [coprod_zero_iso, binary_cofan_zero_right]
  simp
#align category_theory.limits.inr_coprod_zeroiso_hom CategoryTheory.Limits.inr_coprod_zeroiso_hom

@[simp]
theorem coprod_zero_iso_inv (X : C) : (coprodZeroIso X).inv = coprod.inl :=
  rfl
#align category_theory.limits.coprod_zero_iso_inv CategoryTheory.Limits.coprod_zero_iso_inv

instance has_pullback_over_zero (X Y : C) [HasBinaryProduct X Y] :
    HasPullback (0 : X ⟶ 0) (0 : Y ⟶ 0) :=
  HasLimit.mk
    ⟨_, isPullbackOfIsTerminalIsProduct _ _ _ _ HasZeroObject.zeroIsTerminal (prodIsProd X Y)⟩
#align category_theory.limits.has_pullback_over_zero CategoryTheory.Limits.has_pullback_over_zero

/-- The pullback over the zeron object is the product. -/
def pullbackZeroZeroIso (X Y : C) [HasBinaryProduct X Y] :
    pullback (0 : X ⟶ 0) (0 : Y ⟶ 0) ≅ X ⨯ Y :=
  limit.isoLimitCone
    ⟨_, isPullbackOfIsTerminalIsProduct _ _ _ _ HasZeroObject.zeroIsTerminal (prodIsProd X Y)⟩
#align category_theory.limits.pullback_zero_zero_iso CategoryTheory.Limits.pullbackZeroZeroIso

@[simp]
theorem pullback_zero_zero_iso_inv_fst (X Y : C) [HasBinaryProduct X Y] :
    (pullbackZeroZeroIso X Y).inv ≫ pullback.fst = Prod.fst :=
  by
  dsimp [pullback_zero_zero_iso]
  simp
#align
  category_theory.limits.pullback_zero_zero_iso_inv_fst CategoryTheory.Limits.pullback_zero_zero_iso_inv_fst

@[simp]
theorem pullback_zero_zero_iso_inv_snd (X Y : C) [HasBinaryProduct X Y] :
    (pullbackZeroZeroIso X Y).inv ≫ pullback.snd = Prod.snd :=
  by
  dsimp [pullback_zero_zero_iso]
  simp
#align
  category_theory.limits.pullback_zero_zero_iso_inv_snd CategoryTheory.Limits.pullback_zero_zero_iso_inv_snd

@[simp]
theorem pullback_zero_zero_iso_hom_fst (X Y : C) [HasBinaryProduct X Y] :
    (pullbackZeroZeroIso X Y).Hom ≫ Prod.fst = pullback.fst := by simp [← iso.eq_inv_comp]
#align
  category_theory.limits.pullback_zero_zero_iso_hom_fst CategoryTheory.Limits.pullback_zero_zero_iso_hom_fst

@[simp]
theorem pullback_zero_zero_iso_hom_snd (X Y : C) [HasBinaryProduct X Y] :
    (pullbackZeroZeroIso X Y).Hom ≫ Prod.snd = pullback.snd := by simp [← iso.eq_inv_comp]
#align
  category_theory.limits.pullback_zero_zero_iso_hom_snd CategoryTheory.Limits.pullback_zero_zero_iso_hom_snd

instance has_pushout_over_zero (X Y : C) [HasBinaryCoproduct X Y] :
    HasPushout (0 : 0 ⟶ X) (0 : 0 ⟶ Y) :=
  HasColimit.mk
    ⟨_, isPushoutOfIsInitialIsCoproduct _ _ _ _ HasZeroObject.zeroIsInitial (coprodIsCoprod X Y)⟩
#align category_theory.limits.has_pushout_over_zero CategoryTheory.Limits.has_pushout_over_zero

/-- The pushout over the zero object is the coproduct. -/
def pushoutZeroZeroIso (X Y : C) [HasBinaryCoproduct X Y] :
    pushout (0 : 0 ⟶ X) (0 : 0 ⟶ Y) ≅ X ⨿ Y :=
  colimit.isoColimitCocone
    ⟨_, isPushoutOfIsInitialIsCoproduct _ _ _ _ HasZeroObject.zeroIsInitial (coprodIsCoprod X Y)⟩
#align category_theory.limits.pushout_zero_zero_iso CategoryTheory.Limits.pushoutZeroZeroIso

@[simp]
theorem inl_pushout_zero_zero_iso_hom (X Y : C) [HasBinaryCoproduct X Y] :
    pushout.inl ≫ (pushoutZeroZeroIso X Y).Hom = coprod.inl :=
  by
  dsimp [pushout_zero_zero_iso]
  simp
#align
  category_theory.limits.inl_pushout_zero_zero_iso_hom CategoryTheory.Limits.inl_pushout_zero_zero_iso_hom

@[simp]
theorem inr_pushout_zero_zero_iso_hom (X Y : C) [HasBinaryCoproduct X Y] :
    pushout.inr ≫ (pushoutZeroZeroIso X Y).Hom = coprod.inr :=
  by
  dsimp [pushout_zero_zero_iso]
  simp
#align
  category_theory.limits.inr_pushout_zero_zero_iso_hom CategoryTheory.Limits.inr_pushout_zero_zero_iso_hom

@[simp]
theorem inl_pushout_zero_zero_iso_inv (X Y : C) [HasBinaryCoproduct X Y] :
    coprod.inl ≫ (pushoutZeroZeroIso X Y).inv = pushout.inl := by simp [iso.comp_inv_eq]
#align
  category_theory.limits.inl_pushout_zero_zero_iso_inv CategoryTheory.Limits.inl_pushout_zero_zero_iso_inv

@[simp]
theorem inr_pushout_zero_zero_iso_inv (X Y : C) [HasBinaryCoproduct X Y] :
    coprod.inr ≫ (pushoutZeroZeroIso X Y).inv = pushout.inr := by simp [iso.comp_inv_eq]
#align
  category_theory.limits.inr_pushout_zero_zero_iso_inv CategoryTheory.Limits.inr_pushout_zero_zero_iso_inv

end CategoryTheory.Limits

