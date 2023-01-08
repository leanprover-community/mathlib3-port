/-
Copyright (c) 2022 Jujian Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jujian Zhang, Scott Morrison

! This file was ported from Lean 3 source module category_theory.abelian.injective_resolution
! leanprover-community/mathlib commit e001509c11c4d0f549d91d89da95b4a0b43c714f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Homology.QuasiIso
import Mathbin.CategoryTheory.Preadditive.InjectiveResolution
import Mathbin.CategoryTheory.Abelian.Homology
import Mathbin.Algebra.Homology.HomotopyCategory

/-!
# Main result

When the underlying category is abelian:
* `category_theory.InjectiveResolution.desc`: Given `I : InjectiveResolution X` and
  `J : InjectiveResolution Y`, any morphism `X ⟶ Y` admits a descent to a chain map
  `J.cocomplex ⟶ I.cocomplex`. It is a descent in the sense that `I.ι` intertwines the descent and
  the original morphism, see `category_theory.InjectiveResolution.desc_commutes`.
* `category_theory.InjectiveResolution.desc_homotopy`: Any two such descents are homotopic.
* `category_theory.InjectiveResolution.homotopy_equiv`: Any two injective resolutions of the same
  object are homotopy equivalent.
* `category_theory.injective_resolutions`: If every object admits an injective resolution, we can
  construct a functor `injective_resolutions C : C ⥤ homotopy_category C`.

* `category_theory.exact_f_d`: `f` and `injective.d f` are exact.
* `category_theory.InjectiveResolution.of`: Hence, starting from a monomorphism `X ⟶ J`, where `J`
  is injective, we can apply `injective.d` repeatedly to obtain an injective resolution of `X`.
-/


noncomputable section

open CategoryTheory

open CategoryTheory.Limits

universe v u

namespace CategoryTheory

variable {C : Type u} [Category.{v} C]

open Injective

namespace InjectiveResolutionCat

section

variable [HasZeroMorphisms C] [HasZeroObject C] [HasEqualizers C] [HasImages C]

/-- Auxiliary construction for `desc`. -/
def descFZero {Y Z : C} (f : Z ⟶ Y) (I : InjectiveResolutionCat Y) (J : InjectiveResolutionCat Z) :
    J.cocomplex.x 0 ⟶ I.cocomplex.x 0 :=
  factorThru (f ≫ I.ι.f 0) (J.ι.f 0)
#align
  category_theory.InjectiveResolution.desc_f_zero CategoryTheory.InjectiveResolutionCat.descFZero

end

section Abelian

variable [Abelian C]

/-- Auxiliary construction for `desc`. -/
def descFOne {Y Z : C} (f : Z ⟶ Y) (I : InjectiveResolutionCat Y) (J : InjectiveResolutionCat Z) :
    J.cocomplex.x 1 ⟶ I.cocomplex.x 1 :=
  Exact.desc (descFZero f I J ≫ I.cocomplex.d 0 1) (J.ι.f 0) (J.cocomplex.d 0 1)
    (Abelian.Exact.op _ _ J.exact₀) (by simp [← category.assoc, desc_f_zero])
#align category_theory.InjectiveResolution.desc_f_one CategoryTheory.InjectiveResolutionCat.descFOne

@[simp]
theorem desc_f_one_zero_comm {Y Z : C} (f : Z ⟶ Y) (I : InjectiveResolutionCat Y)
    (J : InjectiveResolutionCat Z) :
    J.cocomplex.d 0 1 ≫ descFOne f I J = descFZero f I J ≫ I.cocomplex.d 0 1 := by
  simp [desc_f_zero, desc_f_one]
#align
  category_theory.InjectiveResolution.desc_f_one_zero_comm CategoryTheory.InjectiveResolutionCat.desc_f_one_zero_comm

/-- Auxiliary construction for `desc`. -/
def descFSucc {Y Z : C} (I : InjectiveResolutionCat Y) (J : InjectiveResolutionCat Z) (n : ℕ)
    (g : J.cocomplex.x n ⟶ I.cocomplex.x n) (g' : J.cocomplex.x (n + 1) ⟶ I.cocomplex.x (n + 1))
    (w : J.cocomplex.d n (n + 1) ≫ g' = g ≫ I.cocomplex.d n (n + 1)) :
    Σ'g'' : J.cocomplex.x (n + 2) ⟶ I.cocomplex.x (n + 2),
      J.cocomplex.d (n + 1) (n + 2) ≫ g'' = g' ≫ I.cocomplex.d (n + 1) (n + 2) :=
  ⟨@Exact.desc C _ _ _ _ _ _ _ _ _ (g' ≫ I.cocomplex.d (n + 1) (n + 2)) (J.cocomplex.d n (n + 1))
      (J.cocomplex.d (n + 1) (n + 2)) (Abelian.Exact.op _ _ (J.exact _))
      (by simp [← category.assoc, w]),
    by simp⟩
#align
  category_theory.InjectiveResolution.desc_f_succ CategoryTheory.InjectiveResolutionCat.descFSucc

/-- A morphism in `C` descends to a chain map between injective resolutions. -/
def desc {Y Z : C} (f : Z ⟶ Y) (I : InjectiveResolutionCat Y) (J : InjectiveResolutionCat Z) :
    J.cocomplex ⟶ I.cocomplex :=
  CochainComplex.mkHom _ _ (descFZero f _ _) (descFOne f _ _) (desc_f_one_zero_comm f I J).symm
    fun n ⟨g, g', w⟩ => ⟨(descFSucc I J n g g' w.symm).1, (descFSucc I J n g g' w.symm).2.symm⟩
#align category_theory.InjectiveResolution.desc CategoryTheory.InjectiveResolutionCat.desc

/-- The resolution maps intertwine the descent of a morphism and that morphism. -/
@[simp, reassoc.1]
theorem desc_commutes {Y Z : C} (f : Z ⟶ Y) (I : InjectiveResolutionCat Y)
    (J : InjectiveResolutionCat Z) : J.ι ≫ desc f I J = (CochainComplex.single₀ C).map f ≫ I.ι :=
  by
  ext n
  rcases n with (_ | _ | n) <;>
    · dsimp [desc, desc_f_one, desc_f_zero]
      simp
#align
  category_theory.InjectiveResolution.desc_commutes CategoryTheory.InjectiveResolutionCat.desc_commutes

-- Now that we've checked this property of the descent,
-- we can seal away the actual definition.
/-- An auxiliary definition for `desc_homotopy_zero`. -/
def descHomotopyZeroZero {Y Z : C} {I : InjectiveResolutionCat Y} {J : InjectiveResolutionCat Z}
    (f : I.cocomplex ⟶ J.cocomplex) (comm : I.ι ≫ f = 0) : I.cocomplex.x 1 ⟶ J.cocomplex.x 0 :=
  Exact.desc (f.f 0) (I.ι.f 0) (I.cocomplex.d 0 1) (Abelian.Exact.op _ _ I.exact₀)
    (congr_fun (congr_arg HomologicalComplex.Hom.f comm) 0)
#align
  category_theory.InjectiveResolution.desc_homotopy_zero_zero CategoryTheory.InjectiveResolutionCat.descHomotopyZeroZero

/-- An auxiliary definition for `desc_homotopy_zero`. -/
def descHomotopyZeroOne {Y Z : C} {I : InjectiveResolutionCat Y} {J : InjectiveResolutionCat Z}
    (f : I.cocomplex ⟶ J.cocomplex) (comm : I.ι ≫ f = (0 : _ ⟶ J.cocomplex)) :
    I.cocomplex.x 2 ⟶ J.cocomplex.x 1 :=
  Exact.desc (f.f 1 - descHomotopyZeroZero f comm ≫ J.cocomplex.d 0 1) (I.cocomplex.d 0 1)
    (I.cocomplex.d 1 2) (Abelian.Exact.op _ _ (I.exact _))
    (by simp [desc_homotopy_zero_zero, ← category.assoc])
#align
  category_theory.InjectiveResolution.desc_homotopy_zero_one CategoryTheory.InjectiveResolutionCat.descHomotopyZeroOne

/-- An auxiliary definition for `desc_homotopy_zero`. -/
def descHomotopyZeroSucc {Y Z : C} {I : InjectiveResolutionCat Y} {J : InjectiveResolutionCat Z}
    (f : I.cocomplex ⟶ J.cocomplex) (n : ℕ) (g : I.cocomplex.x (n + 1) ⟶ J.cocomplex.x n)
    (g' : I.cocomplex.x (n + 2) ⟶ J.cocomplex.x (n + 1))
    (w : f.f (n + 1) = I.cocomplex.d (n + 1) (n + 2) ≫ g' + g ≫ J.cocomplex.d n (n + 1)) :
    I.cocomplex.x (n + 3) ⟶ J.cocomplex.x (n + 2) :=
  Exact.desc (f.f (n + 2) - g' ≫ J.cocomplex.d _ _) (I.cocomplex.d (n + 1) (n + 2))
    (I.cocomplex.d (n + 2) (n + 3)) (Abelian.Exact.op _ _ (I.exact _))
    (by
      simp [preadditive.comp_sub, ← category.assoc, preadditive.sub_comp,
        show I.cocomplex.d (n + 1) (n + 2) ≫ g' = f.f (n + 1) - g ≫ J.cocomplex.d n (n + 1)
          by
          rw [w]
          simp only [add_sub_cancel]])
#align
  category_theory.InjectiveResolution.desc_homotopy_zero_succ CategoryTheory.InjectiveResolutionCat.descHomotopyZeroSucc

/-- Any descent of the zero morphism is homotopic to zero. -/
def descHomotopyZero {Y Z : C} {I : InjectiveResolutionCat Y} {J : InjectiveResolutionCat Z}
    (f : I.cocomplex ⟶ J.cocomplex) (comm : I.ι ≫ f = 0) : Homotopy f 0 :=
  Homotopy.mkCoinductive _ (descHomotopyZeroZero f comm) (by simp [desc_homotopy_zero_zero])
    (descHomotopyZeroOne f comm) (by simp [desc_homotopy_zero_one]) fun n ⟨g, g', w⟩ =>
    ⟨descHomotopyZeroSucc f n g g' (by simp only [w, add_comm]), by
      simp [desc_homotopy_zero_succ, w]⟩
#align
  category_theory.InjectiveResolution.desc_homotopy_zero CategoryTheory.InjectiveResolutionCat.descHomotopyZero

/-- Two descents of the same morphism are homotopic. -/
def descHomotopy {Y Z : C} (f : Y ⟶ Z) {I : InjectiveResolutionCat Y} {J : InjectiveResolutionCat Z}
    (g h : I.cocomplex ⟶ J.cocomplex) (g_comm : I.ι ≫ g = (CochainComplex.single₀ C).map f ≫ J.ι)
    (h_comm : I.ι ≫ h = (CochainComplex.single₀ C).map f ≫ J.ι) : Homotopy g h :=
  Homotopy.equivSubZero.invFun (descHomotopyZero _ (by simp [g_comm, h_comm]))
#align
  category_theory.InjectiveResolution.desc_homotopy CategoryTheory.InjectiveResolutionCat.descHomotopy

/-- The descent of the identity morphism is homotopic to the identity cochain map. -/
def descIdHomotopy (X : C) (I : InjectiveResolutionCat X) :
    Homotopy (desc (𝟙 X) I I) (𝟙 I.cocomplex) := by apply desc_homotopy (𝟙 X) <;> simp
#align
  category_theory.InjectiveResolution.desc_id_homotopy CategoryTheory.InjectiveResolutionCat.descIdHomotopy

/-- The descent of a composition is homotopic to the composition of the descents. -/
def descCompHomotopy {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z) (I : InjectiveResolutionCat X)
    (J : InjectiveResolutionCat Y) (K : InjectiveResolutionCat Z) :
    Homotopy (desc (f ≫ g) K I) (desc f J I ≫ desc g K J) := by apply desc_homotopy (f ≫ g) <;> simp
#align
  category_theory.InjectiveResolution.desc_comp_homotopy CategoryTheory.InjectiveResolutionCat.descCompHomotopy

-- We don't care about the actual definitions of these homotopies.
/-- Any two injective resolutions are homotopy equivalent. -/
def homotopyEquiv {X : C} (I J : InjectiveResolutionCat X) : HomotopyEquiv I.cocomplex J.cocomplex
    where
  Hom := desc (𝟙 X) J I
  inv := desc (𝟙 X) I J
  homotopyHomInvId :=
    (descCompHomotopy (𝟙 X) (𝟙 X) I J I).symm.trans <| by
      simpa [category.id_comp] using desc_id_homotopy _ _
  homotopyInvHomId :=
    (descCompHomotopy (𝟙 X) (𝟙 X) J I J).symm.trans <| by
      simpa [category.id_comp] using desc_id_homotopy _ _
#align
  category_theory.InjectiveResolution.homotopy_equiv CategoryTheory.InjectiveResolutionCat.homotopyEquiv

@[simp, reassoc.1]
theorem homotopy_equiv_hom_ι {X : C} (I J : InjectiveResolutionCat X) :
    I.ι ≫ (homotopyEquiv I J).Hom = J.ι := by simp [HomotopyEquiv]
#align
  category_theory.InjectiveResolution.homotopy_equiv_hom_ι CategoryTheory.InjectiveResolutionCat.homotopy_equiv_hom_ι

@[simp, reassoc.1]
theorem homotopy_equiv_inv_ι {X : C} (I J : InjectiveResolutionCat X) :
    J.ι ≫ (homotopyEquiv I J).inv = I.ι := by simp [HomotopyEquiv]
#align
  category_theory.InjectiveResolution.homotopy_equiv_inv_ι CategoryTheory.InjectiveResolutionCat.homotopy_equiv_inv_ι

end Abelian

end InjectiveResolutionCat

section

variable [Abelian C]

/-- An arbitrarily chosen injective resolution of an object. -/
abbrev injectiveResolution (Z : C) [HasInjectiveResolution Z] : CochainComplex C ℕ :=
  (HasInjectiveResolution.out Z).some.cocomplex
#align category_theory.injective_resolution CategoryTheory.injectiveResolution

/-- The cochain map from cochain complex consisting of `Z` supported in degree `0`
back to the arbitrarily chosen injective resolution `injective_resolution Z`. -/
abbrev injectiveResolution.ι (Z : C) [HasInjectiveResolution Z] :
    (CochainComplex.single₀ C).obj Z ⟶ injectiveResolution Z :=
  (HasInjectiveResolution.out Z).some.ι
#align category_theory.injective_resolution.ι CategoryTheory.injectiveResolution.ι

/-- The descent of a morphism to a cochain map between the arbitrarily chosen injective resolutions.
-/
abbrev injectiveResolution.desc {X Y : C} (f : X ⟶ Y) [HasInjectiveResolution X]
    [HasInjectiveResolution Y] : injectiveResolution X ⟶ injectiveResolution Y :=
  InjectiveResolutionCat.desc f _ _
#align category_theory.injective_resolution.desc CategoryTheory.injectiveResolution.desc

variable (C) [HasInjectiveResolutions C]

/-- Taking injective resolutions is functorial,
if considered with target the homotopy category
(`ℕ`-indexed cochain complexes and chain maps up to homotopy).
-/
def injectiveResolutions : C ⥤ HomotopyCategory C (ComplexShape.up ℕ)
    where
  obj X := (HomotopyCategory.quotient _ _).obj (injectiveResolution X)
  map X Y f := (HomotopyCategory.quotient _ _).map (injectiveResolution.desc f)
  map_id' X := by
    rw [← (HomotopyCategory.quotient _ _).map_id]
    apply HomotopyCategory.eq_of_homotopy
    apply InjectiveResolution.desc_id_homotopy
  map_comp' X Y Z f g := by
    rw [← (HomotopyCategory.quotient _ _).map_comp]
    apply HomotopyCategory.eq_of_homotopy
    apply InjectiveResolution.desc_comp_homotopy
#align category_theory.injective_resolutions CategoryTheory.injectiveResolutions

end

section

variable [Abelian C] [EnoughInjectives C]

theorem exact_f_d {X Y : C} (f : X ⟶ Y) : Exact f (d f) :=
  (Abelian.exact_iff _ _).2 <|
    ⟨by simp, zero_of_comp_mono (ι _) <| by rw [category.assoc, kernel.condition]⟩
#align category_theory.exact_f_d CategoryTheory.exact_f_d

end

namespace InjectiveResolutionCat

/-!
Our goal is to define `InjectiveResolution.of Z : InjectiveResolution Z`.
The `0`-th object in this resolution will just be `injective.under Z`,
i.e. an arbitrarily chosen injective object with a map from `Z`.
After that, we build the `n+1`-st object as `injective.syzygies`
applied to the previously constructed morphism,
and the map from the `n`-th object as `injective.d`.
-/


variable [Abelian C] [EnoughInjectives C]

/-- Auxiliary definition for `InjectiveResolution.of`. -/
@[simps]
def ofCocomplex (Z : C) : CochainComplex C ℕ :=
  CochainComplex.mk' (Injective.under Z) (Injective.syzygies (Injective.ι Z))
    (Injective.d (Injective.ι Z)) fun ⟨X, Y, f⟩ =>
    ⟨Injective.syzygies f, Injective.d f, (exact_f_d f).w⟩
#align
  category_theory.InjectiveResolution.of_cocomplex CategoryTheory.InjectiveResolutionCat.ofCocomplex

/-- In any abelian category with enough injectives,
`InjectiveResolution.of Z` constructs an injective resolution of the object `Z`.
-/
irreducible_def of (Z : C) : InjectiveResolutionCat Z :=
  { cocomplex := ofCocomplex Z
    ι :=
      CochainComplex.mkHom _ _ (Injective.ι Z) 0
        (by
          simp only [of_cocomplex_d, eq_self_iff_true, eq_to_hom_refl, category.comp_id,
            dite_eq_ite, if_true, comp_zero]
          exact (exact_f_d (injective.ι Z)).w)
        fun n _ => ⟨0, by ext⟩
    Injective := by rintro (_ | _ | _ | n) <;> · apply injective.injective_under
    exact₀ := by simpa using exact_f_d (injective.ι Z)
    exact := by
      rintro (_ | n) <;>
        · simp
          apply exact_f_d
    Mono := Injective.ι_mono Z }
#align category_theory.InjectiveResolution.of CategoryTheory.InjectiveResolutionCat.of

instance (priority := 100) (Z : C) : HasInjectiveResolution Z where out := ⟨of Z⟩

instance (priority := 100) : HasInjectiveResolutions C where out _ := inferInstance

end InjectiveResolutionCat

end CategoryTheory

namespace HomologicalComplex.Hom

variable {C : Type u} [Category.{v} C] [Abelian C]

/-- If `X` is a cochain complex of injective objects and we have a quasi-isomorphism
`f : Y[0] ⟶ X`, then `X` is an injective resolution of `Y.` -/
def HomologicalComplex.Hom.fromSingle₀InjectiveResolution (X : CochainComplex C ℕ) (Y : C)
    (f : (CochainComplex.single₀ C).obj Y ⟶ X) [QuasiIso f] (H : ∀ n, Injective (X.x n)) :
    InjectiveResolutionCat Y where
  cocomplex := X
  ι := f
  Injective := H
  exact₀ := f.from_single₀_exact_f_d_at_zero
  exact := f.from_single₀_exact_at_succ
  Mono := f.from_single₀_mono_at_zero
#align
  homological_complex.hom.homological_complex.hom.from_single₀_InjectiveResolution HomologicalComplex.Hom.HomologicalComplex.Hom.fromSingle₀InjectiveResolution

end HomologicalComplex.Hom

