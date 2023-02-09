/-
Copyright (c) 2021 Adam Topaz. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta, Adam Topaz

! This file was ported from Lean 3 source module category_theory.limits.kan_extension
! leanprover-community/mathlib commit 0ebfdb71919ac6ca5d7fbc61a082fa2519556818
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.Shapes.Terminal
import Mathbin.CategoryTheory.Punit
import Mathbin.CategoryTheory.StructuredArrow

/-!

# Kan extensions

This file defines the right and left Kan extensions of a functor.
They exist under the assumption that the target category has enough limits
resp. colimits.

The main definitions are `Ran ι` and `Lan ι`, where `ι : S ⥤ L` is a functor.
Namely, `Ran ι` is the right Kan extension, while `Lan ι` is the left Kan extension,
both as functors `(S ⥤ D) ⥤ (L ⥤ D)`.

To access the right resp. left adjunction associated to these, use `Ran.adjunction`
resp. `Lan.adjunction`.

# Projects

A lot of boilerplate could be generalized by defining and working with pseudofunctors.

-/


noncomputable section

namespace CategoryTheory

open Limits

universe v v₁ v₂ v₃ u₁ u₂ u₃

variable {S : Type u₁} {L : Type u₂} {D : Type u₃}

variable [Category.{v₁} S] [Category.{v₂} L] [Category.{v₃} D]

variable (ι : S ⥤ L)

namespace Ran

attribute [local simp] structured_arrow.proj

/-- The diagram indexed by `Ran.index ι x` used to define `Ran`. -/
abbrev diagram (F : S ⥤ D) (x : L) : StructuredArrow x ι ⥤ D :=
  StructuredArrow.proj x ι ⋙ F
#align category_theory.Ran.diagram CategoryTheory.Ran.diagram

variable {ι}

/-- A cone over `Ran.diagram ι F x` used to define `Ran`. -/
@[simp]
def cone {F : S ⥤ D} {G : L ⥤ D} (x : L) (f : ι ⋙ G ⟶ F) : Cone (diagram ι F x)
    where
  x := G.obj x
  π :=
    { app := fun i => G.map i.hom ≫ f.app i.right
      naturality' := by
        rintro ⟨⟨il⟩, ir, i⟩ ⟨⟨jl⟩, jr, j⟩ ⟨⟨⟨fl⟩⟩, fr, ff⟩
        dsimp at *
        simp only [Category.id_comp, Category.assoc] at *
        rw [ff]
        have := f.naturality
        tidy }
#align category_theory.Ran.cone CategoryTheory.Ran.cone

variable (ι)

/-- An auxiliary definition used to define `Ran`. -/
@[simps]
def loc (F : S ⥤ D) [∀ x, HasLimit (diagram ι F x)] : L ⥤ D
    where
  obj x := limit (diagram ι F x)
  map x y f := limit.pre (diagram _ _ _) (StructuredArrow.map f : StructuredArrow _ ι ⥤ _)
  map_id' := by
    intro l
    ext j
    simp only [Category.id_comp, limit.pre_π]
    congr 1
    simp
  map_comp' := by
    intro x y z f g
    ext j
    erw [limit.pre_pre, limit.pre_π, limit.pre_π]
    congr 1
    tidy
#align category_theory.Ran.loc CategoryTheory.Ran.loc

/-- An auxiliary definition used to define `Ran` and `Ran.adjunction`. -/
@[simps]
def equiv (F : S ⥤ D) [∀ x, HasLimit (diagram ι F x)] (G : L ⥤ D) :
    (G ⟶ loc ι F) ≃ (((whiskeringLeft _ _ _).obj ι).obj G ⟶ F)
    where
  toFun f :=
    { app := fun x => f.app _ ≫ limit.π (diagram ι F (ι.obj x)) (StructuredArrow.mk (𝟙 _))
      naturality' := by
        intro x y ff
        dsimp only [whiskeringLeft]
        simp only [Functor.comp_map, NatTrans.naturality_assoc, loc_map, Category.assoc]
        congr 1
        erw [limit.pre_π]
        change _ = _ ≫ (diagram ι F (ι.obj x)).map (StructuredArrow.homMk _ _)
        rw [limit.w]
        tidy }
  invFun f :=
    { app := fun x => limit.lift (diagram ι F x) (cone _ f)
      naturality' := by
        intro x y ff
        ext j
        erw [limit.lift_pre, limit.lift_π, Category.assoc, limit.lift_π (cone _ f) j]
        tidy }
  left_inv := by
    intro x
    ext (k j)
    dsimp only [cone]
    rw [limit.lift_π]
    simp only [NatTrans.naturality_assoc, loc_map]
    erw [limit.pre_π]
    congr
    rcases j with ⟨⟨⟩, _, _⟩
    tidy
  right_inv := by tidy
#align category_theory.Ran.equiv CategoryTheory.Ran.equiv

end Ran

/-- The right Kan extension of a functor. -/
@[simps]
def ran [∀ X, HasLimitsOfShape (StructuredArrow X ι) D] : (S ⥤ D) ⥤ L ⥤ D :=
  Adjunction.rightAdjointOfEquiv (fun F G => (Ran.equiv ι G F).symm) (by tidy)
#align category_theory.Ran CategoryTheory.ran

namespace Ran

variable (D)

/-- The adjunction associated to `Ran`. -/
def adjunction [∀ X, HasLimitsOfShape (StructuredArrow X ι) D] :
    (whiskeringLeft _ _ D).obj ι ⊣ ran ι :=
  Adjunction.adjunctionOfEquivRight _ _
#align category_theory.Ran.adjunction CategoryTheory.ran.adjunction

theorem reflective [Full ι] [Faithful ι] [∀ X, HasLimitsOfShape (StructuredArrow X ι) D] :
    IsIso (adjunction D ι).counit :=
  by
  apply NatIso.isIso_of_isIso_app _
  intro F
  apply NatIso.isIso_of_isIso_app _
  intro X
  dsimp [adjunction]
  simp only [Category.id_comp]
  exact
    IsIso.of_iso
      ((limit.isLimit _).conePointUniqueUpToIso
        (limitOfDiagramInitial StructuredArrow.mkIdInitial _))
#align category_theory.Ran.reflective CategoryTheory.ran.reflective

end Ran

namespace Lan

attribute [local simp] costructured_arrow.proj

/-- The diagram indexed by `Ran.index ι x` used to define `Ran`. -/
abbrev diagram (F : S ⥤ D) (x : L) : CostructuredArrow ι x ⥤ D :=
  CostructuredArrow.proj ι x ⋙ F
#align category_theory.Lan.diagram CategoryTheory.Lan.diagram

variable {ι}

/-- A cocone over `Lan.diagram ι F x` used to define `Lan`. -/
@[simp]
def cocone {F : S ⥤ D} {G : L ⥤ D} (x : L) (f : F ⟶ ι ⋙ G) : Cocone (diagram ι F x)
    where
  x := G.obj x
  ι :=
    { app := fun i => f.app i.left ≫ G.map i.hom
      naturality' := by
        rintro ⟨ir, ⟨il⟩, i⟩ ⟨jl, ⟨jr⟩, j⟩ ⟨fl, ⟨⟨fl⟩⟩, ff⟩
        dsimp at *
        simp only [Functor.comp_map, Category.comp_id, NatTrans.naturality_assoc]
        rw [← G.map_comp, ff]
        tidy }
#align category_theory.Lan.cocone CategoryTheory.Lan.cocone

variable (ι)

/-- An auxiliary definition used to define `Lan`. -/
@[simps]
def loc (F : S ⥤ D) [I : ∀ x, HasColimit (diagram ι F x)] : L ⥤ D
    where
  obj x := colimit (diagram ι F x)
  map x y f := colimit.pre (diagram _ _ _) (CostructuredArrow.map f : CostructuredArrow ι _ ⥤ _)
  map_id' := by
    intro l
    ext j
    erw [colimit.ι_pre, Category.comp_id]
    congr 1
    simp
  map_comp' := by
    intro x y z f g
    ext j
    let ff : CostructuredArrow ι _ ⥤ _ := CostructuredArrow.map f
    let gg : CostructuredArrow ι _ ⥤ _ := CostructuredArrow.map g
    let dd := diagram ι F z
    -- I don't know why lean can't deduce the following three instances...
    haveI : HasColimit (ff ⋙ gg ⋙ dd) := I _
    haveI : HasColimit ((ff ⋙ gg) ⋙ dd) := I _
    haveI : HasColimit (gg ⋙ dd) := I _
    change _ = colimit.ι ((ff ⋙ gg) ⋙ dd) j ≫ _ ≫ _
    erw [colimit.pre_pre dd gg ff, colimit.ι_pre, colimit.ι_pre]
    congr 1
    simp
#align category_theory.Lan.loc CategoryTheory.Lan.loc

/-- An auxiliary definition used to define `Lan` and `Lan.adjunction`. -/
@[simps]
def equiv (F : S ⥤ D) [I : ∀ x, HasColimit (diagram ι F x)] (G : L ⥤ D) :
    (loc ι F ⟶ G) ≃ (F ⟶ ((whiskeringLeft _ _ _).obj ι).obj G)
    where
  toFun f :=
    { app := fun x => by
        apply colimit.ι (diagram ι F (ι.obj x)) (CostructuredArrow.mk (𝟙 _)) ≫ f.app _
      -- sigh
      naturality' := by
        intro x y ff
        dsimp only [whiskeringLeft]
        simp only [Functor.comp_map, Category.assoc]
        rw [← f.naturality (ι.map ff), ← Category.assoc, ← Category.assoc]
        let fff : CostructuredArrow ι _ ⥤ _ := CostructuredArrow.map (ι.map ff)
        -- same issue :-(
        haveI : HasColimit (fff ⋙ diagram ι F (ι.obj y)) := I _
        erw [colimit.ι_pre (diagram ι F (ι.obj y)) fff (CostructuredArrow.mk (𝟙 _))]
        let xx : CostructuredArrow ι (ι.obj y) := CostructuredArrow.mk (ι.map ff)
        let yy : CostructuredArrow ι (ι.obj y) := CostructuredArrow.mk (𝟙 _)
        let fff : xx ⟶ yy :=
          CostructuredArrow.homMk ff
            (by
              simp only [CostructuredArrow.mk_hom_eq_self]
              erw [Category.comp_id])
        erw [colimit.w (diagram ι F (ι.obj y)) fff]
        congr
        simp }
  invFun f :=
    { app := fun x => colimit.desc (diagram ι F x) (cocone _ f)
      naturality' := by
        intro x y ff
        ext j
        erw [colimit.pre_desc, ← Category.assoc, colimit.ι_desc, colimit.ι_desc]
        tidy }
  left_inv := by
    intro x
    ext (k j)
    rw [colimit.ι_desc]
    dsimp only [cocone]
    rw [Category.assoc, ← x.naturality j.hom, ← Category.assoc]
    congr 1
    change colimit.ι _ _ ≫ colimit.pre (diagram ι F k) (CostructuredArrow.map _) = _
    rw [colimit.ι_pre]
    congr
    rcases j with ⟨_, ⟨⟩, _⟩
    tidy
  right_inv := by tidy
#align category_theory.Lan.equiv CategoryTheory.Lan.equiv

end Lan

/-- The left Kan extension of a functor. -/
@[simps]
def lan [∀ X, HasColimitsOfShape (CostructuredArrow ι X) D] : (S ⥤ D) ⥤ L ⥤ D :=
  Adjunction.leftAdjointOfEquiv (fun F G => Lan.equiv ι F G) (by tidy)
#align category_theory.Lan CategoryTheory.lan

namespace Lan

variable (D)

/-- The adjunction associated to `Lan`. -/
def adjunction [∀ X, HasColimitsOfShape (CostructuredArrow ι X) D] :
    lan ι ⊣ (whiskeringLeft _ _ D).obj ι :=
  Adjunction.adjunctionOfEquivLeft _ _
#align category_theory.Lan.adjunction CategoryTheory.lan.adjunction

theorem coreflective [Full ι] [Faithful ι] [∀ X, HasColimitsOfShape (CostructuredArrow ι X) D] :
    IsIso (adjunction D ι).unit :=
  by
  apply NatIso.isIso_of_isIso_app _
  intro F
  apply NatIso.isIso_of_isIso_app _
  intro X
  dsimp [adjunction]
  simp only [Category.comp_id]
  exact
    IsIso.of_iso
      ((colimit.isColimit _).coconePointUniqueUpToIso
          (colimitOfDiagramTerminal CostructuredArrow.mkIdTerminal _)).symm
#align category_theory.Lan.coreflective CategoryTheory.lan.coreflective

end Lan

end CategoryTheory

