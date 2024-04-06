/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta, Scott Morrison
-/
import CategoryTheory.Subobject.FactorThru
import CategoryTheory.Subobject.WellPowered

#align_import category_theory.subobject.lattice from "leanprover-community/mathlib"@"ce38d86c0b2d427ce208c3cee3159cb421d2b3c4"

/-!
# The lattice of subobjects

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We provide the `semilattice_inf` with `order_top (subobject X)` instance when `[has_pullback C]`,
and the `semilattice_sup (subobject X)` instance when `[has_images C] [has_binary_coproducts C]`.
-/


universe v₁ v₂ u₁ u₂

noncomputable section

open CategoryTheory CategoryTheory.Category CategoryTheory.Limits

variable {C : Type u₁} [Category.{v₁} C] {X Y Z : C}

variable {D : Type u₂} [Category.{v₂} D]

namespace CategoryTheory

namespace MonoOver

section Top

instance {X : C} : Top (MonoOver X) where top := mk' (𝟙 _)

instance {X : C} : Inhabited (MonoOver X) :=
  ⟨⊤⟩

#print CategoryTheory.MonoOver.leTop /-
/-- The morphism to the top object in `mono_over X`. -/
def leTop (f : MonoOver X) : f ⟶ ⊤ :=
  homMk f.arrow (comp_id _)
#align category_theory.mono_over.le_top CategoryTheory.MonoOver.leTop
-/

#print CategoryTheory.MonoOver.top_left /-
@[simp]
theorem top_left (X : C) : ((⊤ : MonoOver X) : C) = X :=
  rfl
#align category_theory.mono_over.top_left CategoryTheory.MonoOver.top_left
-/

#print CategoryTheory.MonoOver.top_arrow /-
@[simp]
theorem top_arrow (X : C) : (⊤ : MonoOver X).arrow = 𝟙 X :=
  rfl
#align category_theory.mono_over.top_arrow CategoryTheory.MonoOver.top_arrow
-/

#print CategoryTheory.MonoOver.mapTop /-
/-- `map f` sends `⊤ : mono_over X` to `⟨X, f⟩ : mono_over Y`. -/
def mapTop (f : X ⟶ Y) [Mono f] : (map f).obj ⊤ ≅ mk' f :=
  iso_of_both_ways (homMk (𝟙 _) rfl) (homMk (𝟙 _) (by simp [id_comp f]))
#align category_theory.mono_over.map_top CategoryTheory.MonoOver.mapTop
-/

section

variable [HasPullbacks C]

#print CategoryTheory.MonoOver.pullbackTop /-
/-- The pullback of the top object in `mono_over Y`
is (isomorphic to) the top object in `mono_over X`. -/
def pullbackTop (f : X ⟶ Y) : (pullback f).obj ⊤ ≅ ⊤ :=
  iso_of_both_ways (leTop _) (homMk (pullback.lift f (𝟙 _) (by tidy)) (pullback.lift_snd _ _ _))
#align category_theory.mono_over.pullback_top CategoryTheory.MonoOver.pullbackTop
-/

#print CategoryTheory.MonoOver.topLEPullbackSelf /-
/-- There is a morphism from `⊤ : mono_over A` to the pullback of a monomorphism along itself;
as the category is thin this is an isomorphism. -/
def topLEPullbackSelf {A B : C} (f : A ⟶ B) [Mono f] :
    (⊤ : MonoOver A) ⟶ (pullback f).obj (mk' f) :=
  homMk _ (pullback.lift_snd _ _ rfl)
#align category_theory.mono_over.top_le_pullback_self CategoryTheory.MonoOver.topLEPullbackSelf
-/

#print CategoryTheory.MonoOver.pullbackSelf /-
/-- The pullback of a monomorphism along itself is isomorphic to the top object. -/
def pullbackSelf {A B : C} (f : A ⟶ B) [Mono f] : (pullback f).obj (mk' f) ≅ ⊤ :=
  iso_of_both_ways (leTop _) (topLEPullbackSelf _)
#align category_theory.mono_over.pullback_self CategoryTheory.MonoOver.pullbackSelf
-/

end

end Top

section Bot

variable [HasInitial C] [InitialMonoClass C]

instance {X : C} : Bot (MonoOver X) where bot := mk' (initial.to X)

#print CategoryTheory.MonoOver.bot_left /-
@[simp]
theorem bot_left (X : C) : ((⊥ : MonoOver X) : C) = ⊥_ C :=
  rfl
#align category_theory.mono_over.bot_left CategoryTheory.MonoOver.bot_left
-/

#print CategoryTheory.MonoOver.bot_arrow /-
@[simp]
theorem bot_arrow {X : C} : (⊥ : MonoOver X).arrow = initial.to X :=
  rfl
#align category_theory.mono_over.bot_arrow CategoryTheory.MonoOver.bot_arrow
-/

#print CategoryTheory.MonoOver.botLE /-
/-- The (unique) morphism from `⊥ : mono_over X` to any other `f : mono_over X`. -/
def botLE {X : C} (f : MonoOver X) : ⊥ ⟶ f :=
  homMk (initial.to _) (by simp)
#align category_theory.mono_over.bot_le CategoryTheory.MonoOver.botLE
-/

#print CategoryTheory.MonoOver.mapBot /-
/-- `map f` sends `⊥ : mono_over X` to `⊥ : mono_over Y`. -/
def mapBot (f : X ⟶ Y) [Mono f] : (map f).obj ⊥ ≅ ⊥ :=
  iso_of_both_ways (homMk (initial.to _) (by simp)) (homMk (𝟙 _) (by simp))
#align category_theory.mono_over.map_bot CategoryTheory.MonoOver.mapBot
-/

end Bot

section ZeroOrderBot

variable [HasZeroObject C]

open scoped ZeroObject

#print CategoryTheory.MonoOver.botCoeIsoZero /-
/-- The object underlying `⊥ : subobject B` is (up to isomorphism) the zero object. -/
def botCoeIsoZero {B : C} : ((⊥ : MonoOver B) : C) ≅ 0 :=
  initialIsInitial.uniqueUpToIso HasZeroObject.zeroIsInitial
#align category_theory.mono_over.bot_coe_iso_zero CategoryTheory.MonoOver.botCoeIsoZero
-/

#print CategoryTheory.MonoOver.bot_arrow_eq_zero /-
@[simp]
theorem bot_arrow_eq_zero [HasZeroMorphisms C] {B : C} : (⊥ : MonoOver B).arrow = 0 :=
  zero_of_source_iso_zero _ botCoeIsoZero
#align category_theory.mono_over.bot_arrow_eq_zero CategoryTheory.MonoOver.bot_arrow_eq_zero
-/

end ZeroOrderBot

section Inf

variable [HasPullbacks C]

#print CategoryTheory.MonoOver.inf /-
/-- When `[has_pullbacks C]`, `mono_over A` has "intersections", functorial in both arguments.

As `mono_over A` is only a preorder, this doesn't satisfy the axioms of `semilattice_inf`,
but we reuse all the names from `semilattice_inf` because they will be used to construct
`semilattice_inf (subobject A)` shortly.
-/
@[simps]
def inf {A : C} : MonoOver A ⥤ MonoOver A ⥤ MonoOver A
    where
  obj f := pullback f.arrow ⋙ map f.arrow
  map f₁ f₂ k :=
    {
      app := fun g => by
        apply hom_mk _ _
        apply pullback.lift pullback.fst (pullback.snd ≫ k.left) _
        rw [pullback.condition, assoc, w k]
        dsimp
        rw [pullback.lift_snd_assoc, assoc, w k] }
#align category_theory.mono_over.inf CategoryTheory.MonoOver.inf
-/

#print CategoryTheory.MonoOver.infLELeft /-
/-- A morphism from the "infimum" of two objects in `mono_over A` to the first object. -/
def infLELeft {A : C} (f g : MonoOver A) : (inf.obj f).obj g ⟶ f :=
  homMk _ rfl
#align category_theory.mono_over.inf_le_left CategoryTheory.MonoOver.infLELeft
-/

#print CategoryTheory.MonoOver.infLERight /-
/-- A morphism from the "infimum" of two objects in `mono_over A` to the second object. -/
def infLERight {A : C} (f g : MonoOver A) : (inf.obj f).obj g ⟶ g :=
  homMk _ pullback.condition
#align category_theory.mono_over.inf_le_right CategoryTheory.MonoOver.infLERight
-/

#print CategoryTheory.MonoOver.leInf /-
/-- A morphism version of the `le_inf` axiom. -/
def leInf {A : C} (f g h : MonoOver A) : (h ⟶ f) → (h ⟶ g) → (h ⟶ (inf.obj f).obj g) :=
  by
  intro k₁ k₂
  refine' hom_mk (pullback.lift k₂.left k₁.left _) _
  rw [w k₁, w k₂]
  erw [pullback.lift_snd_assoc, w k₁]
#align category_theory.mono_over.le_inf CategoryTheory.MonoOver.leInf
-/

end Inf

section Sup

variable [HasImages C] [HasBinaryCoproducts C]

#print CategoryTheory.MonoOver.sup /-
/-- When `[has_images C] [has_binary_coproducts C]`, `mono_over A` has a `sup` construction,
which is functorial in both arguments,
and which on `subobject A` will induce a `semilattice_sup`. -/
def sup {A : C} : MonoOver A ⥤ MonoOver A ⥤ MonoOver A :=
  curryObj ((forget A).Prod (forget A) ⋙ uncurry.obj Over.coprod ⋙ image)
#align category_theory.mono_over.sup CategoryTheory.MonoOver.sup
-/

#print CategoryTheory.MonoOver.leSupLeft /-
/-- A morphism version of `le_sup_left`. -/
def leSupLeft {A : C} (f g : MonoOver A) : f ⟶ (sup.obj f).obj g :=
  by
  refine' hom_mk (coprod.inl ≫ factor_thru_image _) _
  erw [category.assoc, image.fac, coprod.inl_desc]
  rfl
#align category_theory.mono_over.le_sup_left CategoryTheory.MonoOver.leSupLeft
-/

#print CategoryTheory.MonoOver.leSupRight /-
/-- A morphism version of `le_sup_right`. -/
def leSupRight {A : C} (f g : MonoOver A) : g ⟶ (sup.obj f).obj g :=
  by
  refine' hom_mk (coprod.inr ≫ factor_thru_image _) _
  erw [category.assoc, image.fac, coprod.inr_desc]
  rfl
#align category_theory.mono_over.le_sup_right CategoryTheory.MonoOver.leSupRight
-/

#print CategoryTheory.MonoOver.supLe /-
/-- A morphism version of `sup_le`. -/
def supLe {A : C} (f g h : MonoOver A) : (f ⟶ h) → (g ⟶ h) → ((sup.obj f).obj g ⟶ h) :=
  by
  intro k₁ k₂
  refine' hom_mk _ _
  apply image.lift ⟨_, h.arrow, coprod.desc k₁.left k₂.left, _⟩
  · dsimp
    ext1
    · simp [w k₁]
    · simp [w k₂]
  · apply image.lift_fac
#align category_theory.mono_over.sup_le CategoryTheory.MonoOver.supLe
-/

end Sup

end MonoOver

namespace Subobject

section OrderTop

#print CategoryTheory.Subobject.orderTop /-
instance orderTop {X : C} : OrderTop (Subobject X)
    where
  top := Quotient.mk'' ⊤
  le_top := by
    refine' Quotient.ind' fun f => _
    exact ⟨mono_over.le_top f⟩
#align category_theory.subobject.order_top CategoryTheory.Subobject.orderTop
-/

instance {X : C} : Inhabited (Subobject X) :=
  ⟨⊤⟩

#print CategoryTheory.Subobject.top_eq_id /-
theorem top_eq_id (B : C) : (⊤ : Subobject B) = Subobject.mk (𝟙 B) :=
  rfl
#align category_theory.subobject.top_eq_id CategoryTheory.Subobject.top_eq_id
-/

#print CategoryTheory.Subobject.underlyingIso_top_hom /-
theorem underlyingIso_top_hom {B : C} : (underlyingIso (𝟙 B)).Hom = (⊤ : Subobject B).arrow := by
  convert underlying_iso_hom_comp_eq_mk (𝟙 B); simp only [comp_id]
#align category_theory.subobject.underlying_iso_top_hom CategoryTheory.Subobject.underlyingIso_top_hom
-/

#print CategoryTheory.Subobject.top_arrow_isIso /-
instance top_arrow_isIso {B : C} : IsIso (⊤ : Subobject B).arrow := by
  rw [← underlying_iso_top_hom]; infer_instance
#align category_theory.subobject.top_arrow_is_iso CategoryTheory.Subobject.top_arrow_isIso
-/

#print CategoryTheory.Subobject.underlyingIso_inv_top_arrow /-
@[simp, reassoc]
theorem underlyingIso_inv_top_arrow {B : C} :
    (underlyingIso _).inv ≫ (⊤ : Subobject B).arrow = 𝟙 B :=
  underlyingIso_arrow _
#align category_theory.subobject.underlying_iso_inv_top_arrow CategoryTheory.Subobject.underlyingIso_inv_top_arrow
-/

#print CategoryTheory.Subobject.map_top /-
@[simp]
theorem map_top (f : X ⟶ Y) [Mono f] : (map f).obj ⊤ = Subobject.mk f :=
  Quotient.sound' ⟨MonoOver.mapTop f⟩
#align category_theory.subobject.map_top CategoryTheory.Subobject.map_top
-/

#print CategoryTheory.Subobject.top_factors /-
theorem top_factors {A B : C} (f : A ⟶ B) : (⊤ : Subobject B).Factors f :=
  ⟨f, comp_id _⟩
#align category_theory.subobject.top_factors CategoryTheory.Subobject.top_factors
-/

#print CategoryTheory.Subobject.isIso_iff_mk_eq_top /-
theorem isIso_iff_mk_eq_top {X Y : C} (f : X ⟶ Y) [Mono f] : IsIso f ↔ mk f = ⊤ :=
  ⟨fun _ => mk_eq_mk_of_comm _ _ (as_iso f) (category.comp_id _), fun h => by
    rw [← of_mk_le_mk_comp h.le, category.comp_id]; exact is_iso.of_iso (iso_of_mk_eq_mk _ _ h)⟩
#align category_theory.subobject.is_iso_iff_mk_eq_top CategoryTheory.Subobject.isIso_iff_mk_eq_top
-/

#print CategoryTheory.Subobject.isIso_arrow_iff_eq_top /-
theorem isIso_arrow_iff_eq_top {Y : C} (P : Subobject Y) : IsIso P.arrow ↔ P = ⊤ := by
  rw [is_iso_iff_mk_eq_top, mk_arrow]
#align category_theory.subobject.is_iso_arrow_iff_eq_top CategoryTheory.Subobject.isIso_arrow_iff_eq_top
-/

#print CategoryTheory.Subobject.isIso_top_arrow /-
instance isIso_top_arrow {Y : C} : IsIso (⊤ : Subobject Y).arrow := by rw [is_iso_arrow_iff_eq_top]
#align category_theory.subobject.is_iso_top_arrow CategoryTheory.Subobject.isIso_top_arrow
-/

#print CategoryTheory.Subobject.mk_eq_top_of_isIso /-
theorem mk_eq_top_of_isIso {X Y : C} (f : X ⟶ Y) [IsIso f] : mk f = ⊤ :=
  (isIso_iff_mk_eq_top f).mp inferInstance
#align category_theory.subobject.mk_eq_top_of_is_iso CategoryTheory.Subobject.mk_eq_top_of_isIso
-/

#print CategoryTheory.Subobject.eq_top_of_isIso_arrow /-
theorem eq_top_of_isIso_arrow {Y : C} (P : Subobject Y) [IsIso P.arrow] : P = ⊤ :=
  (isIso_arrow_iff_eq_top P).mp inferInstance
#align category_theory.subobject.eq_top_of_is_iso_arrow CategoryTheory.Subobject.eq_top_of_isIso_arrow
-/

section

variable [HasPullbacks C]

#print CategoryTheory.Subobject.pullback_top /-
theorem pullback_top (f : X ⟶ Y) : (pullback f).obj ⊤ = ⊤ :=
  Quotient.sound' ⟨MonoOver.pullbackTop f⟩
#align category_theory.subobject.pullback_top CategoryTheory.Subobject.pullback_top
-/

#print CategoryTheory.Subobject.pullback_self /-
theorem pullback_self {A B : C} (f : A ⟶ B) [Mono f] : (pullback f).obj (mk f) = ⊤ :=
  Quotient.sound' ⟨MonoOver.pullbackSelf f⟩
#align category_theory.subobject.pullback_self CategoryTheory.Subobject.pullback_self
-/

end

end OrderTop

section OrderBot

variable [HasInitial C] [InitialMonoClass C]

#print CategoryTheory.Subobject.orderBot /-
instance orderBot {X : C} : OrderBot (Subobject X)
    where
  bot := Quotient.mk'' ⊥
  bot_le := by
    refine' Quotient.ind' fun f => _
    exact ⟨mono_over.bot_le f⟩
#align category_theory.subobject.order_bot CategoryTheory.Subobject.orderBot
-/

#print CategoryTheory.Subobject.bot_eq_initial_to /-
theorem bot_eq_initial_to {B : C} : (⊥ : Subobject B) = Subobject.mk (initial.to B) :=
  rfl
#align category_theory.subobject.bot_eq_initial_to CategoryTheory.Subobject.bot_eq_initial_to
-/

#print CategoryTheory.Subobject.botCoeIsoInitial /-
/-- The object underlying `⊥ : subobject B` is (up to isomorphism) the initial object. -/
def botCoeIsoInitial {B : C} : ((⊥ : Subobject B) : C) ≅ ⊥_ C :=
  underlyingIso _
#align category_theory.subobject.bot_coe_iso_initial CategoryTheory.Subobject.botCoeIsoInitial
-/

#print CategoryTheory.Subobject.map_bot /-
theorem map_bot (f : X ⟶ Y) [Mono f] : (map f).obj ⊥ = ⊥ :=
  Quotient.sound' ⟨MonoOver.mapBot f⟩
#align category_theory.subobject.map_bot CategoryTheory.Subobject.map_bot
-/

end OrderBot

section ZeroOrderBot

variable [HasZeroObject C]

open scoped ZeroObject

#print CategoryTheory.Subobject.botCoeIsoZero /-
/-- The object underlying `⊥ : subobject B` is (up to isomorphism) the zero object. -/
def botCoeIsoZero {B : C} : ((⊥ : Subobject B) : C) ≅ 0 :=
  botCoeIsoInitial ≪≫ initialIsInitial.uniqueUpToIso HasZeroObject.zeroIsInitial
#align category_theory.subobject.bot_coe_iso_zero CategoryTheory.Subobject.botCoeIsoZero
-/

variable [HasZeroMorphisms C]

#print CategoryTheory.Subobject.bot_eq_zero /-
theorem bot_eq_zero {B : C} : (⊥ : Subobject B) = Subobject.mk (0 : 0 ⟶ B) :=
  mk_eq_mk_of_comm _ _ (initialIsInitial.uniqueUpToIso HasZeroObject.zeroIsInitial) (by simp)
#align category_theory.subobject.bot_eq_zero CategoryTheory.Subobject.bot_eq_zero
-/

#print CategoryTheory.Subobject.bot_arrow /-
@[simp]
theorem bot_arrow {B : C} : (⊥ : Subobject B).arrow = 0 :=
  zero_of_source_iso_zero _ botCoeIsoZero
#align category_theory.subobject.bot_arrow CategoryTheory.Subobject.bot_arrow
-/

#print CategoryTheory.Subobject.bot_factors_iff_zero /-
theorem bot_factors_iff_zero {A B : C} (f : A ⟶ B) : (⊥ : Subobject B).Factors f ↔ f = 0 :=
  ⟨by rintro ⟨h, rfl⟩; simp, by rintro rfl; exact ⟨0, by simp⟩⟩
#align category_theory.subobject.bot_factors_iff_zero CategoryTheory.Subobject.bot_factors_iff_zero
-/

#print CategoryTheory.Subobject.mk_eq_bot_iff_zero /-
theorem mk_eq_bot_iff_zero {f : X ⟶ Y} [Mono f] : Subobject.mk f = ⊥ ↔ f = 0 :=
  ⟨fun h => by simpa [h, bot_factors_iff_zero] using mk_factors_self f, fun h =>
    mk_eq_mk_of_comm _ _ ((isoZeroOfMonoEqZero h).trans HasZeroObject.zeroIsoInitial) (by simp [h])⟩
#align category_theory.subobject.mk_eq_bot_iff_zero CategoryTheory.Subobject.mk_eq_bot_iff_zero
-/

end ZeroOrderBot

section Functor

variable (C)

#print CategoryTheory.Subobject.functor /-
/-- Sending `X : C` to `subobject X` is a contravariant functor `Cᵒᵖ ⥤ Type`. -/
@[simps]
def functor [HasPullbacks C] : Cᵒᵖ ⥤ Type max u₁ v₁
    where
  obj X := Subobject X.unop
  map X Y f := (pullback f.unop).obj
  map_id' X := funext pullback_id
  map_comp' X Y Z f g := funext (pullback_comp _ _)
#align category_theory.subobject.functor CategoryTheory.Subobject.functor
-/

end Functor

section SemilatticeInfTop

variable [HasPullbacks C]

#print CategoryTheory.Subobject.inf /-
/-- The functorial infimum on `mono_over A` descends to an infimum on `subobject A`. -/
def inf {A : C} : Subobject A ⥤ Subobject A ⥤ Subobject A :=
  ThinSkeleton.map₂ MonoOver.inf
#align category_theory.subobject.inf CategoryTheory.Subobject.inf
-/

#print CategoryTheory.Subobject.inf_le_left /-
theorem inf_le_left {A : C} (f g : Subobject A) : (inf.obj f).obj g ≤ f :=
  Quotient.inductionOn₂' f g fun a b => ⟨MonoOver.infLELeft _ _⟩
#align category_theory.subobject.inf_le_left CategoryTheory.Subobject.inf_le_left
-/

#print CategoryTheory.Subobject.inf_le_right /-
theorem inf_le_right {A : C} (f g : Subobject A) : (inf.obj f).obj g ≤ g :=
  Quotient.inductionOn₂' f g fun a b => ⟨MonoOver.infLERight _ _⟩
#align category_theory.subobject.inf_le_right CategoryTheory.Subobject.inf_le_right
-/

#print CategoryTheory.Subobject.le_inf /-
theorem le_inf {A : C} (h f g : Subobject A) : h ≤ f → h ≤ g → h ≤ (inf.obj f).obj g :=
  Quotient.inductionOn₃' h f g
    (by
      rintro f g h ⟨k⟩ ⟨l⟩
      exact ⟨mono_over.le_inf _ _ _ k l⟩)
#align category_theory.subobject.le_inf CategoryTheory.Subobject.le_inf
-/

instance {B : C} : SemilatticeInf (Subobject B) :=
  { Subobject.partialOrder _ with
    inf := fun m n => (inf.obj m).obj n
    inf_le_left := inf_le_left
    inf_le_right := inf_le_right
    le_inf := le_inf }

#print CategoryTheory.Subobject.factors_left_of_inf_factors /-
theorem factors_left_of_inf_factors {A B : C} {X Y : Subobject B} {f : A ⟶ B}
    (h : (X ⊓ Y).Factors f) : X.Factors f :=
  factors_of_le _ (inf_le_left _ _) h
#align category_theory.subobject.factors_left_of_inf_factors CategoryTheory.Subobject.factors_left_of_inf_factors
-/

#print CategoryTheory.Subobject.factors_right_of_inf_factors /-
theorem factors_right_of_inf_factors {A B : C} {X Y : Subobject B} {f : A ⟶ B}
    (h : (X ⊓ Y).Factors f) : Y.Factors f :=
  factors_of_le _ (inf_le_right _ _) h
#align category_theory.subobject.factors_right_of_inf_factors CategoryTheory.Subobject.factors_right_of_inf_factors
-/

#print CategoryTheory.Subobject.inf_factors /-
@[simp]
theorem inf_factors {A B : C} {X Y : Subobject B} (f : A ⟶ B) :
    (X ⊓ Y).Factors f ↔ X.Factors f ∧ Y.Factors f :=
  ⟨fun h => ⟨factors_left_of_inf_factors h, factors_right_of_inf_factors h⟩,
    by
    revert X Y
    refine' Quotient.ind₂' _
    rintro X Y ⟨⟨g₁, rfl⟩, ⟨g₂, hg₂⟩⟩
    exact ⟨_, pullback.lift_snd_assoc _ _ hg₂ _⟩⟩
#align category_theory.subobject.inf_factors CategoryTheory.Subobject.inf_factors
-/

#print CategoryTheory.Subobject.inf_arrow_factors_left /-
theorem inf_arrow_factors_left {B : C} (X Y : Subobject B) : X.Factors (X ⊓ Y).arrow :=
  (factors_iff _ _).mpr ⟨ofLE (X ⊓ Y) X (inf_le_left X Y), by simp⟩
#align category_theory.subobject.inf_arrow_factors_left CategoryTheory.Subobject.inf_arrow_factors_left
-/

#print CategoryTheory.Subobject.inf_arrow_factors_right /-
theorem inf_arrow_factors_right {B : C} (X Y : Subobject B) : Y.Factors (X ⊓ Y).arrow :=
  (factors_iff _ _).mpr ⟨ofLE (X ⊓ Y) Y (inf_le_right X Y), by simp⟩
#align category_theory.subobject.inf_arrow_factors_right CategoryTheory.Subobject.inf_arrow_factors_right
-/

#print CategoryTheory.Subobject.finset_inf_factors /-
@[simp]
theorem finset_inf_factors {I : Type _} {A B : C} {s : Finset I} {P : I → Subobject B} (f : A ⟶ B) :
    (s.inf P).Factors f ↔ ∀ i ∈ s, (P i).Factors f := by
  classical
  apply Finset.induction_on s
  · simp [top_factors]
  · intro i s nm ih; simp [ih]
#align category_theory.subobject.finset_inf_factors CategoryTheory.Subobject.finset_inf_factors
-/

#print CategoryTheory.Subobject.finset_inf_arrow_factors /-
-- `i` is explicit here because often we'd like to defer a proof of `m`
theorem finset_inf_arrow_factors {I : Type _} {B : C} (s : Finset I) (P : I → Subobject B) (i : I)
    (m : i ∈ s) : (P i).Factors (s.inf P).arrow :=
  by
  revert i m
  classical
  apply Finset.induction_on s
  · rintro _ ⟨⟩
  · intro i s nm ih j m
    rw [Finset.inf_insert]
    simp only [Finset.mem_insert] at m; rcases m with (rfl | m)
    · rw [← factor_thru_arrow _ _ (inf_arrow_factors_left _ _)]
      exact factors_comp_arrow _
    · rw [← factor_thru_arrow _ _ (inf_arrow_factors_right _ _)]
      apply factors_of_factors_right
      exact ih _ m
#align category_theory.subobject.finset_inf_arrow_factors CategoryTheory.Subobject.finset_inf_arrow_factors
-/

#print CategoryTheory.Subobject.inf_eq_map_pullback' /-
theorem inf_eq_map_pullback' {A : C} (f₁ : MonoOver A) (f₂ : Subobject A) :
    (Subobject.inf.obj (Quotient.mk'' f₁)).obj f₂ =
      (Subobject.map f₁.arrow).obj ((Subobject.pullback f₁.arrow).obj f₂) :=
  by
  apply Quotient.inductionOn' f₂
  intro f₂
  rfl
#align category_theory.subobject.inf_eq_map_pullback' CategoryTheory.Subobject.inf_eq_map_pullback'
-/

#print CategoryTheory.Subobject.inf_eq_map_pullback /-
theorem inf_eq_map_pullback {A : C} (f₁ : MonoOver A) (f₂ : Subobject A) :
    (Quotient.mk'' f₁ ⊓ f₂ : Subobject A) = (map f₁.arrow).obj ((pullback f₁.arrow).obj f₂) :=
  inf_eq_map_pullback' f₁ f₂
#align category_theory.subobject.inf_eq_map_pullback CategoryTheory.Subobject.inf_eq_map_pullback
-/

#print CategoryTheory.Subobject.prod_eq_inf /-
theorem prod_eq_inf {A : C} {f₁ f₂ : Subobject A} [HasBinaryProduct f₁ f₂] : (f₁ ⨯ f₂) = f₁ ⊓ f₂ :=
  le_antisymm (le_inf Limits.prod.fst.le Limits.prod.snd.le)
    (prod.lift inf_le_left.Hom inf_le_right.Hom).le
#align category_theory.subobject.prod_eq_inf CategoryTheory.Subobject.prod_eq_inf
-/

#print CategoryTheory.Subobject.inf_def /-
theorem inf_def {B : C} (m m' : Subobject B) : m ⊓ m' = (inf.obj m).obj m' :=
  rfl
#align category_theory.subobject.inf_def CategoryTheory.Subobject.inf_def
-/

#print CategoryTheory.Subobject.inf_pullback /-
/-- `⊓` commutes with pullback. -/
theorem inf_pullback {X Y : C} (g : X ⟶ Y) (f₁ f₂) :
    (pullback g).obj (f₁ ⊓ f₂) = (pullback g).obj f₁ ⊓ (pullback g).obj f₂ :=
  by
  revert f₁
  apply Quotient.ind'
  intro f₁
  erw [inf_def, inf_def, inf_eq_map_pullback', inf_eq_map_pullback', ← pullback_comp, ←
    map_pullback pullback.condition (pullback_is_pullback f₁.arrow g), ← pullback_comp,
    pullback.condition]
  rfl
#align category_theory.subobject.inf_pullback CategoryTheory.Subobject.inf_pullback
-/

#print CategoryTheory.Subobject.inf_map /-
/-- `⊓` commutes with map. -/
theorem inf_map {X Y : C} (g : Y ⟶ X) [Mono g] (f₁ f₂) :
    (map g).obj (f₁ ⊓ f₂) = (map g).obj f₁ ⊓ (map g).obj f₂ :=
  by
  revert f₁
  apply Quotient.ind'
  intro f₁
  erw [inf_def, inf_def, inf_eq_map_pullback', inf_eq_map_pullback', ← map_comp]
  dsimp
  rw [pullback_comp, pullback_map_self]
#align category_theory.subobject.inf_map CategoryTheory.Subobject.inf_map
-/

end SemilatticeInfTop

section SemilatticeSup

variable [HasImages C] [HasBinaryCoproducts C]

#print CategoryTheory.Subobject.sup /-
/-- The functorial supremum on `mono_over A` descends to an supremum on `subobject A`. -/
def sup {A : C} : Subobject A ⥤ Subobject A ⥤ Subobject A :=
  ThinSkeleton.map₂ MonoOver.sup
#align category_theory.subobject.sup CategoryTheory.Subobject.sup
-/

instance {B : C} : SemilatticeSup (Subobject B) :=
  { Subobject.partialOrder B with
    sup := fun m n => (sup.obj m).obj n
    le_sup_left := fun m n => Quotient.inductionOn₂' m n fun a b => ⟨MonoOver.leSupLeft _ _⟩
    le_sup_right := fun m n => Quotient.inductionOn₂' m n fun a b => ⟨MonoOver.leSupRight _ _⟩
    sup_le := fun m n k =>
      Quotient.inductionOn₃' m n k fun a b c ⟨i⟩ ⟨j⟩ => ⟨MonoOver.supLe _ _ _ i j⟩ }

#print CategoryTheory.Subobject.sup_factors_of_factors_left /-
theorem sup_factors_of_factors_left {A B : C} {X Y : Subobject B} {f : A ⟶ B} (P : X.Factors f) :
    (X ⊔ Y).Factors f :=
  factors_of_le f le_sup_left P
#align category_theory.subobject.sup_factors_of_factors_left CategoryTheory.Subobject.sup_factors_of_factors_left
-/

#print CategoryTheory.Subobject.sup_factors_of_factors_right /-
theorem sup_factors_of_factors_right {A B : C} {X Y : Subobject B} {f : A ⟶ B} (P : Y.Factors f) :
    (X ⊔ Y).Factors f :=
  factors_of_le f le_sup_right P
#align category_theory.subobject.sup_factors_of_factors_right CategoryTheory.Subobject.sup_factors_of_factors_right
-/

variable [HasInitial C] [InitialMonoClass C]

#print CategoryTheory.Subobject.finset_sup_factors /-
theorem finset_sup_factors {I : Type _} {A B : C} {s : Finset I} {P : I → Subobject B} {f : A ⟶ B}
    (h : ∃ i ∈ s, (P i).Factors f) : (s.sup P).Factors f := by
  classical
  revert h
  apply Finset.induction_on s
  · rintro ⟨_, ⟨⟨⟩, _⟩⟩
  · rintro i s nm ih ⟨j, ⟨m, h⟩⟩
    simp only [Finset.sup_insert]
    simp at m; rcases m with (rfl | m)
    · exact sup_factors_of_factors_left h
    · exact sup_factors_of_factors_right (ih ⟨j, ⟨m, h⟩⟩)
#align category_theory.subobject.finset_sup_factors CategoryTheory.Subobject.finset_sup_factors
-/

end SemilatticeSup

section Lattice

instance [HasInitial C] [InitialMonoClass C] {B : C} : BoundedOrder (Subobject B) :=
  { Subobject.orderTop, Subobject.orderBot with }

variable [HasPullbacks C] [HasImages C] [HasBinaryCoproducts C]

instance {B : C} : Lattice (Subobject B) :=
  { Subobject.semilatticeInf, Subobject.semilatticeSup with }

end Lattice

section Inf

variable [WellPowered C]

#print CategoryTheory.Subobject.wideCospan /-
/-- The "wide cospan" diagram, with a small indexing type, constructed from a set of subobjects.
(This is just the diagram of all the subobjects pasted together, but using `well_powered C`
to make the diagram small.)
-/
def wideCospan {A : C} (s : Set (Subobject A)) : WidePullbackShape (equivShrink _ '' s) ⥤ C :=
  WidePullbackShape.wideCospan A
    (fun j : equivShrink _ '' s => ((equivShrink (Subobject A)).symm j : C)) fun j =>
    ((equivShrink (Subobject A)).symm j).arrow
#align category_theory.subobject.wide_cospan CategoryTheory.Subobject.wideCospan
-/

#print CategoryTheory.Subobject.wideCospan_map_term /-
@[simp]
theorem wideCospan_map_term {A : C} (s : Set (Subobject A)) (j) :
    (wideCospan s).map (WidePullbackShape.Hom.term j) =
      ((equivShrink (Subobject A)).symm j).arrow :=
  rfl
#align category_theory.subobject.wide_cospan_map_term CategoryTheory.Subobject.wideCospan_map_term
-/

#print CategoryTheory.Subobject.leInfCone /-
/-- Auxiliary construction of a cone for `le_Inf`. -/
def leInfCone {A : C} (s : Set (Subobject A)) (f : Subobject A) (k : ∀ g ∈ s, f ≤ g) :
    Cone (wideCospan s) :=
  WidePullbackShape.mkCone f.arrow
    (fun j => underlying.map (homOfLE (k _ (by rcases j with ⟨-, ⟨g, ⟨m, rfl⟩⟩⟩; simpa using m))))
    (by tidy)
#align category_theory.subobject.le_Inf_cone CategoryTheory.Subobject.leInfCone
-/

#print CategoryTheory.Subobject.leInfCone_π_app_none /-
@[simp]
theorem leInfCone_π_app_none {A : C} (s : Set (Subobject A)) (f : Subobject A)
    (k : ∀ g ∈ s, f ≤ g) : (leInfCone s f k).π.app none = f.arrow :=
  rfl
#align category_theory.subobject.le_Inf_cone_π_app_none CategoryTheory.Subobject.leInfCone_π_app_none
-/

variable [HasWidePullbacks.{v₁} C]

#print CategoryTheory.Subobject.widePullback /-
/-- The limit of `wide_cospan s`. (This will be the supremum of the set of subobjects.)
-/
def widePullback {A : C} (s : Set (Subobject A)) : C :=
  Limits.limit (wideCospan s)
#align category_theory.subobject.wide_pullback CategoryTheory.Subobject.widePullback
-/

#print CategoryTheory.Subobject.widePullbackι /-
/-- The inclusion map from `wide_pullback s` to `A`
-/
def widePullbackι {A : C} (s : Set (Subobject A)) : widePullback s ⟶ A :=
  Limits.limit.π (wideCospan s) none
#align category_theory.subobject.wide_pullback_ι CategoryTheory.Subobject.widePullbackι
-/

#print CategoryTheory.Subobject.widePullbackι_mono /-
instance widePullbackι_mono {A : C} (s : Set (Subobject A)) : Mono (widePullbackι s) :=
  ⟨fun W u v h =>
    limit.hom_ext fun j => by
      cases j
      · exact h
      · apply (cancel_mono ((equivShrink (subobject A)).symm j).arrow).1
        rw [assoc, assoc]
        erw [limit.w (wide_cospan s) (wide_pullback_shape.hom.term j)]
        exact h⟩
#align category_theory.subobject.wide_pullback_ι_mono CategoryTheory.Subobject.widePullbackι_mono
-/

#print CategoryTheory.Subobject.sInf /-
/-- When `[well_powered C]` and `[has_wide_pullbacks C]`, `subobject A` has arbitrary infimums.
-/
def sInf {A : C} (s : Set (Subobject A)) : Subobject A :=
  Subobject.mk (widePullbackι s)
#align category_theory.subobject.Inf CategoryTheory.Subobject.sInf
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:642:2: warning: expanding binder collection (f «expr ∈ » s) -/
#print CategoryTheory.Subobject.sInf_le /-
theorem sInf_le {A : C} (s : Set (Subobject A)) (f) (_ : f ∈ s) : sInf s ≤ f :=
  by
  fapply le_of_comm
  · refine'
      (underlying_iso _).Hom ≫
        limits.limit.π (wide_cospan s)
            (some ⟨equivShrink _ f, Set.mem_image_of_mem (equivShrink (subobject A)) H⟩) ≫
          _
    apply eq_to_hom
    apply congr_arg fun X : subobject A => (X : C)
    exact Equiv.symm_apply_apply _ _
  · dsimp [Inf]
    simp only [category.comp_id, category.assoc, ← underlying_iso_hom_comp_eq_mk,
      subobject.arrow_congr, congr_arg_mpr_hom_left, iso.cancel_iso_hom_left]
    convert limit.w (wide_cospan s) (wide_pullback_shape.hom.term _)
#align category_theory.subobject.Inf_le CategoryTheory.Subobject.sInf_le
-/

/- warning: category_theory.subobject.le_Inf clashes with category_theory.subobject.le_inf -> CategoryTheory.Subobject.le_inf
Case conversion may be inaccurate. Consider using '#align category_theory.subobject.le_Inf CategoryTheory.Subobject.le_infₓ'. -/
#print CategoryTheory.Subobject.le_inf /-
theorem le_inf {A : C} (s : Set (Subobject A)) (f : Subobject A) (k : ∀ g ∈ s, f ≤ g) :
    f ≤ sInf s := by
  fapply le_of_comm
  · exact limits.limit.lift _ (le_Inf_cone s f k) ≫ (underlying_iso _).inv
  · dsimp [Inf, wide_pullback_ι]
    simp
#align category_theory.subobject.le_Inf CategoryTheory.Subobject.le_inf
-/

instance {B : C} : CompleteSemilatticeInf (Subobject B) :=
  { Subobject.partialOrder B with
    sInf := sInf
    inf_le := sInf_le
    le_inf := le_inf }

end Inf

section Sup

variable [WellPowered C] [HasCoproducts.{v₁} C]

#print CategoryTheory.Subobject.smallCoproductDesc /-
/-- The univesal morphism out of the coproduct of a set of subobjects,
after using `[well_powered C]` to reindex by a small type.
-/
def smallCoproductDesc {A : C} (s : Set (Subobject A)) : _ ⟶ A :=
  Limits.Sigma.desc fun j : equivShrink _ '' s => ((equivShrink (Subobject A)).symm j).arrow
#align category_theory.subobject.small_coproduct_desc CategoryTheory.Subobject.smallCoproductDesc
-/

variable [HasImages C]

/- warning: category_theory.subobject.Sup clashes with category_theory.subobject.sup -> CategoryTheory.Subobject.sup
Case conversion may be inaccurate. Consider using '#align category_theory.subobject.Sup CategoryTheory.Subobject.supₓ'. -/
#print CategoryTheory.Subobject.sup /-
/-- When `[well_powered C] [has_images C] [has_coproducts C]`,
`subobject A` has arbitrary supremums. -/
def sup {A : C} (s : Set (Subobject A)) : Subobject A :=
  Subobject.mk (image.ι (smallCoproductDesc s))
#align category_theory.subobject.Sup CategoryTheory.Subobject.sup
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:642:2: warning: expanding binder collection (f «expr ∈ » s) -/
#print CategoryTheory.Subobject.le_sSup /-
theorem le_sSup {A : C} (s : Set (Subobject A)) (f) (_ : f ∈ s) : f ≤ sup s :=
  by
  fapply le_of_comm
  · dsimp [Sup]
    refine' _ ≫ factor_thru_image _ ≫ (underlying_iso _).inv
    refine' _ ≫ sigma.ι _ ⟨equivShrink _ f, by simpa [Set.mem_image] using H⟩
    exact eq_to_hom (congr_arg (fun X : subobject A => (X : C)) (Equiv.symm_apply_apply _ _).symm)
  · dsimp [Sup, small_coproduct_desc]
    simp; dsimp; simp
#align category_theory.subobject.le_Sup CategoryTheory.Subobject.le_sSup
-/

#print CategoryTheory.Subobject.symm_apply_mem_iff_mem_image /-
theorem symm_apply_mem_iff_mem_image {α β : Type _} (e : α ≃ β) (s : Set α) (x : β) :
    e.symm x ∈ s ↔ x ∈ e '' s :=
  ⟨fun h => ⟨e.symm x, h, by simp⟩, by rintro ⟨a, m, rfl⟩; simpa using m⟩
#align category_theory.subobject.symm_apply_mem_iff_mem_image CategoryTheory.Subobject.symm_apply_mem_iff_mem_image
-/

#print CategoryTheory.Subobject.sSup_le /-
theorem sSup_le {A : C} (s : Set (Subobject A)) (f : Subobject A) (k : ∀ g ∈ s, g ≤ f) :
    sup s ≤ f := by
  fapply le_of_comm
  · dsimp [Sup]
    refine' (underlying_iso _).Hom ≫ image.lift ⟨_, f.arrow, _, _⟩
    · refine' sigma.desc _
      rintro ⟨g, m⟩
      refine' underlying.map (hom_of_le (k _ _))
      simpa [symm_apply_mem_iff_mem_image] using m
    · ext j; rcases j with ⟨j, m⟩; dsimp [small_coproduct_desc]; simp; dsimp; simp
  · dsimp [Sup]
    simp
#align category_theory.subobject.Sup_le CategoryTheory.Subobject.sSup_le
-/

instance {B : C} : CompleteSemilatticeSup (Subobject B) :=
  { Subobject.partialOrder B with
    sSup := sup
    le_sup := le_sSup
    sup_le := sSup_le }

end Sup

section CompleteLattice

variable [WellPowered C] [HasWidePullbacks.{v₁} C] [HasImages C] [HasCoproducts.{v₁} C]
  [InitialMonoClass C]

attribute [local instance] has_smallest_coproducts_of_has_coproducts

instance {B : C} : CompleteLattice (Subobject B) :=
  { Subobject.semilatticeInf, Subobject.semilatticeSup, Subobject.boundedOrder,
    Subobject.completeSemilatticeInf, Subobject.completeSemilatticeSup with }

end CompleteLattice

section ZeroObject

variable [HasZeroMorphisms C] [HasZeroObject C]

open scoped ZeroObject

#print CategoryTheory.Subobject.nontrivial_of_not_isZero /-
/-- A nonzero object has nontrivial subobject lattice. -/
theorem nontrivial_of_not_isZero {X : C} (h : ¬IsZero X) : Nontrivial (Subobject X) :=
  ⟨⟨mk (0 : 0 ⟶ X), mk (𝟙 X), fun w => h (IsZero.of_iso (isZero_zero C) (isoOfMkEqMk _ _ w).symm)⟩⟩
#align category_theory.subobject.nontrivial_of_not_is_zero CategoryTheory.Subobject.nontrivial_of_not_isZero
-/

end ZeroObject

section SubobjectSubobject

#print CategoryTheory.Subobject.subobjectOrderIso /-
/-- The subobject lattice of a subobject `Y` is order isomorphic to the interval `set.Iic Y`. -/
def subobjectOrderIso {X : C} (Y : Subobject X) : Subobject (Y : C) ≃o Set.Iic Y
    where
  toFun Z :=
    ⟨Subobject.mk (Z.arrow ≫ Y.arrow),
      Set.mem_Iic.mpr (le_of_comm ((underlyingIso _).Hom ≫ Z.arrow) (by simp))⟩
  invFun Z := Subobject.mk (ofLE _ _ Z.2)
  left_inv Z := mk_eq_of_comm _ (underlyingIso _) (by ext; simp)
  right_inv Z :=
    Subtype.ext (mk_eq_of_comm _ (underlyingIso _) (by dsimp; simp [← iso.eq_inv_comp]))
  map_rel_iff' W Z :=
    ⟨fun h =>
      le_of_comm ((underlyingIso _).inv ≫ ofLE _ _ (Subtype.mk_le_mk.mp h) ≫ (underlyingIso _).Hom)
        (by ext; simp),
      fun h =>
      Subtype.mk_le_mk.mpr
        (le_of_comm ((underlyingIso _).Hom ≫ ofLE _ _ h ≫ (underlyingIso _).inv) (by simp))⟩
#align category_theory.subobject.subobject_order_iso CategoryTheory.Subobject.subobjectOrderIso
-/

end SubobjectSubobject

end Subobject

end CategoryTheory

