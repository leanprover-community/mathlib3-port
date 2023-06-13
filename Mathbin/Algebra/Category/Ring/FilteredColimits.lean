/-
Copyright (c) 2021 Justus Springer. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Justus Springer

! This file was ported from Lean 3 source module algebra.category.Ring.filtered_colimits
! leanprover-community/mathlib commit 0b7c740e25651db0ba63648fbae9f9d6f941e31b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Category.Ring.Basic
import Mathbin.Algebra.Category.Group.FilteredColimits

/-!
# The forgetful functor from (commutative) (semi-) rings preserves filtered colimits.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Forgetful functors from algebraic categories usually don't preserve colimits. However, they tend
to preserve _filtered_ colimits.

In this file, we start with a small filtered category `J` and a functor `F : J ⥤ SemiRing`.
We show that the colimit of `F ⋙ forget₂ SemiRing Mon` (in `Mon`) carries the structure of a
semiring, thereby showing that the forgetful functor `forget₂ SemiRing Mon` preserves filtered
colimits. In particular, this implies that `forget SemiRing` preserves filtered colimits.
Similarly for `CommSemiRing`, `Ring` and `CommRing`.

-/


universe v u

noncomputable section

open scoped Classical

open CategoryTheory

open CategoryTheory.Limits

open CategoryTheory.IsFiltered renaming max → max'

-- avoid name collision with `_root_.max`.
open AddMonCat.FilteredColimits (colimit_zero_eq colimit_add_mk_eq)

open MonCat.FilteredColimits (colimit_one_eq colimit_mul_mk_eq)

namespace SemiRingCat.FilteredColimits

section

-- We use parameters here, mainly so we can have the abbreviations `R` and `R.mk` below, without
-- passing around `F` all the time.
parameter {J : Type v} [SmallCategory J] (F : J ⥤ SemiRingCat.{max v u})

-- This instance is needed below in `colimit_semiring`, during the verification of the
-- semiring axioms.
instance semiringObj (j : J) :
    Semiring (((F ⋙ forget₂ SemiRingCat MonCat.{max v u}) ⋙ forget MonCat).obj j) :=
  show Semiring (F.obj j) by infer_instance
#align SemiRing.filtered_colimits.semiring_obj SemiRingCat.FilteredColimits.semiringObj

variable [IsFiltered J]

#print SemiRingCat.FilteredColimits.R /-
/-- The colimit of `F ⋙ forget₂ SemiRing Mon` in the category `Mon`.
In the following, we will show that this has the structure of a semiring.
-/
abbrev R : MonCat :=
  MonCat.FilteredColimits.colimit (F ⋙ forget₂ SemiRingCat MonCat.{max v u})
#align SemiRing.filtered_colimits.R SemiRingCat.FilteredColimits.R
-/

#print SemiRingCat.FilteredColimits.colimitSemiring /-
instance colimitSemiring : Semiring R :=
  { R.Monoid,
    AddCommMonCat.FilteredColimits.colimitAddCommMonoid
      (F ⋙
        forget₂ SemiRingCat
          AddCommMonCat.{max v
              u}) with
    mul_zero := fun x => by
      apply Quot.inductionOn x; clear x; intro x
      cases' x with j x
      erw [colimit_zero_eq _ j, colimit_mul_mk_eq _ ⟨j, _⟩ ⟨j, _⟩ j (𝟙 j) (𝟙 j)]
      rw [CategoryTheory.Functor.map_id, id_apply, id_apply, MulZeroClass.mul_zero x]
      rfl
    zero_mul := fun x => by
      apply Quot.inductionOn x; clear x; intro x
      cases' x with j x
      erw [colimit_zero_eq _ j, colimit_mul_mk_eq _ ⟨j, _⟩ ⟨j, _⟩ j (𝟙 j) (𝟙 j)]
      rw [CategoryTheory.Functor.map_id, id_apply, id_apply, MulZeroClass.zero_mul x]
      rfl
    left_distrib := fun x y z => by
      apply Quot.induction_on₃ x y z; clear x y z; intro x y z
      cases' x with j₁ x; cases' y with j₂ y; cases' z with j₃ z
      let k := max₃ j₁ j₂ j₃
      let f := first_to_max₃ j₁ j₂ j₃
      let g := second_to_max₃ j₁ j₂ j₃
      let h := third_to_max₃ j₁ j₂ j₃
      erw [colimit_add_mk_eq _ ⟨j₂, _⟩ ⟨j₃, _⟩ k g h, colimit_mul_mk_eq _ ⟨j₁, _⟩ ⟨k, _⟩ k f (𝟙 k),
        colimit_mul_mk_eq _ ⟨j₁, _⟩ ⟨j₂, _⟩ k f g, colimit_mul_mk_eq _ ⟨j₁, _⟩ ⟨j₃, _⟩ k f h,
        colimit_add_mk_eq _ ⟨k, _⟩ ⟨k, _⟩ k (𝟙 k) (𝟙 k)]
      simp only [CategoryTheory.Functor.map_id, id_apply]
      erw [left_distrib (F.map f x) (F.map g y) (F.map h z)]
      rfl
    right_distrib := fun x y z => by
      apply Quot.induction_on₃ x y z; clear x y z; intro x y z
      cases' x with j₁ x; cases' y with j₂ y; cases' z with j₃ z
      let k := max₃ j₁ j₂ j₃
      let f := first_to_max₃ j₁ j₂ j₃
      let g := second_to_max₃ j₁ j₂ j₃
      let h := third_to_max₃ j₁ j₂ j₃
      erw [colimit_add_mk_eq _ ⟨j₁, _⟩ ⟨j₂, _⟩ k f g, colimit_mul_mk_eq _ ⟨k, _⟩ ⟨j₃, _⟩ k (𝟙 k) h,
        colimit_mul_mk_eq _ ⟨j₁, _⟩ ⟨j₃, _⟩ k f h, colimit_mul_mk_eq _ ⟨j₂, _⟩ ⟨j₃, _⟩ k g h,
        colimit_add_mk_eq _ ⟨k, _⟩ ⟨k, _⟩ k (𝟙 k) (𝟙 k)]
      simp only [CategoryTheory.Functor.map_id, id_apply]
      erw [right_distrib (F.map f x) (F.map g y) (F.map h z)]
      rfl }
#align SemiRing.filtered_colimits.colimit_semiring SemiRingCat.FilteredColimits.colimitSemiring
-/

#print SemiRingCat.FilteredColimits.colimit /-
/-- The bundled semiring giving the filtered colimit of a diagram. -/
def colimit : SemiRingCat :=
  SemiRingCat.of R
#align SemiRing.filtered_colimits.colimit SemiRingCat.FilteredColimits.colimit
-/

#print SemiRingCat.FilteredColimits.colimitCocone /-
/-- The cocone over the proposed colimit semiring. -/
def colimitCocone : cocone F where
  pt := colimit
  ι :=
    { app := fun j =>
        {
          (MonCat.FilteredColimits.colimitCocone (F ⋙ forget₂ SemiRingCat MonCat.{max v u})).ι.app
            j,
          (AddCommMonCat.FilteredColimits.colimitCocone
                  (F ⋙ forget₂ SemiRingCat AddCommMonCat.{max v u})).ι.app
            j with }
      naturality' := fun j j' f =>
        RingHom.coe_inj ((Types.colimitCocone (F ⋙ forget SemiRingCat)).ι.naturality f) }
#align SemiRing.filtered_colimits.colimit_cocone SemiRingCat.FilteredColimits.colimitCocone
-/

#print SemiRingCat.FilteredColimits.colimitCoconeIsColimit /-
/-- The proposed colimit cocone is a colimit in `SemiRing`. -/
def colimitCoconeIsColimit : IsColimit colimit_cocone
    where
  desc t :=
    {
      (MonCat.FilteredColimits.colimitCoconeIsColimit
            (F ⋙ forget₂ SemiRingCat MonCat.{max v u})).desc
        ((forget₂ SemiRingCat MonCat.{max v u}).mapCocone t),
      (AddCommMonCat.FilteredColimits.colimitCoconeIsColimit
            (F ⋙ forget₂ SemiRingCat AddCommMonCat.{max v u})).desc
        ((forget₂ SemiRingCat AddCommMonCat.{max v u}).mapCocone t) with }
  fac t j :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget SemiRingCat)).fac ((forget SemiRingCat).mapCocone t)
        j
  uniq t m h :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget SemiRingCat)).uniq
        ((forget SemiRingCat).mapCocone t) m fun j => funext fun x => RingHom.congr_fun (h j) x
#align SemiRing.filtered_colimits.colimit_cocone_is_colimit SemiRingCat.FilteredColimits.colimitCoconeIsColimit
-/

#print SemiRingCat.FilteredColimits.forget₂MonPreservesFilteredColimits /-
instance forget₂MonPreservesFilteredColimits :
    PreservesFilteredColimits (forget₂ SemiRingCat MonCat.{u})
    where PreservesFilteredColimits J _ _ :=
    {
      PreservesColimit := fun F =>
        preserves_colimit_of_preserves_colimit_cocone (colimitCoconeIsColimit.{u, u} F)
          (MonCat.FilteredColimits.colimitCoconeIsColimit (F ⋙ forget₂ SemiRingCat MonCat.{u})) }
#align SemiRing.filtered_colimits.forget₂_Mon_preserves_filtered_colimits SemiRingCat.FilteredColimits.forget₂MonPreservesFilteredColimits
-/

#print SemiRingCat.FilteredColimits.forgetPreservesFilteredColimits /-
instance forgetPreservesFilteredColimits : PreservesFilteredColimits (forget SemiRingCat.{u}) :=
  Limits.compPreservesFilteredColimits (forget₂ SemiRingCat MonCat) (forget MonCat.{u})
#align SemiRing.filtered_colimits.forget_preserves_filtered_colimits SemiRingCat.FilteredColimits.forgetPreservesFilteredColimits
-/

end

end SemiRingCat.FilteredColimits

namespace CommSemiRingCat.FilteredColimits

section

-- We use parameters here, mainly so we can have the abbreviation `R` below, without
-- passing around `F` all the time.
parameter {J : Type v} [SmallCategory J] [IsFiltered J] (F : J ⥤ CommSemiRingCat.{max v u})

#print CommSemiRingCat.FilteredColimits.R /-
/-- The colimit of `F ⋙ forget₂ CommSemiRing SemiRing` in the category `SemiRing`.
In the following, we will show that this has the structure of a _commutative_ semiring.
-/
abbrev R : SemiRingCat :=
  SemiRingCat.FilteredColimits.colimit (F ⋙ forget₂ CommSemiRingCat SemiRingCat.{max v u})
#align CommSemiRing.filtered_colimits.R CommSemiRingCat.FilteredColimits.R
-/

#print CommSemiRingCat.FilteredColimits.colimitCommSemiring /-
instance colimitCommSemiring : CommSemiring R :=
  { R.Semiring,
    CommMonCat.FilteredColimits.colimitCommMonoid
      (F ⋙ forget₂ CommSemiRingCat CommMonCat.{max v u}) with }
#align CommSemiRing.filtered_colimits.colimit_comm_semiring CommSemiRingCat.FilteredColimits.colimitCommSemiring
-/

#print CommSemiRingCat.FilteredColimits.colimit /-
/-- The bundled commutative semiring giving the filtered colimit of a diagram. -/
def colimit : CommSemiRingCat :=
  CommSemiRingCat.of R
#align CommSemiRing.filtered_colimits.colimit CommSemiRingCat.FilteredColimits.colimit
-/

#print CommSemiRingCat.FilteredColimits.colimitCocone /-
/-- The cocone over the proposed colimit commutative semiring. -/
def colimitCocone : cocone F where
  pt := colimit
  ι :=
    {
      (SemiRingCat.FilteredColimits.colimitCocone
          (F ⋙ forget₂ CommSemiRingCat SemiRingCat.{max v u})).ι with }
#align CommSemiRing.filtered_colimits.colimit_cocone CommSemiRingCat.FilteredColimits.colimitCocone
-/

#print CommSemiRingCat.FilteredColimits.colimitCoconeIsColimit /-
/-- The proposed colimit cocone is a colimit in `CommSemiRing`. -/
def colimitCoconeIsColimit : IsColimit colimit_cocone
    where
  desc t :=
    (SemiRingCat.FilteredColimits.colimitCoconeIsColimit
          (F ⋙ forget₂ CommSemiRingCat SemiRingCat.{max v u})).desc
      ((forget₂ CommSemiRingCat SemiRingCat).mapCocone t)
  fac t j :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget CommSemiRingCat)).fac
        ((forget CommSemiRingCat).mapCocone t) j
  uniq t m h :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget CommSemiRingCat)).uniq
        ((forget CommSemiRingCat).mapCocone t) m fun j => funext fun x => RingHom.congr_fun (h j) x
#align CommSemiRing.filtered_colimits.colimit_cocone_is_colimit CommSemiRingCat.FilteredColimits.colimitCoconeIsColimit
-/

#print CommSemiRingCat.FilteredColimits.forget₂SemiRingPreservesFilteredColimits /-
instance forget₂SemiRingPreservesFilteredColimits :
    PreservesFilteredColimits (forget₂ CommSemiRingCat SemiRingCat.{u})
    where PreservesFilteredColimits J _ _ :=
    {
      PreservesColimit := fun F =>
        preserves_colimit_of_preserves_colimit_cocone (colimitCoconeIsColimit.{u, u} F)
          (SemiRingCat.FilteredColimits.colimitCoconeIsColimit
            (F ⋙ forget₂ CommSemiRingCat SemiRingCat.{u})) }
#align CommSemiRing.filtered_colimits.forget₂_SemiRing_preserves_filtered_colimits CommSemiRingCat.FilteredColimits.forget₂SemiRingPreservesFilteredColimits
-/

#print CommSemiRingCat.FilteredColimits.forgetPreservesFilteredColimits /-
instance forgetPreservesFilteredColimits : PreservesFilteredColimits (forget CommSemiRingCat.{u}) :=
  Limits.compPreservesFilteredColimits (forget₂ CommSemiRingCat SemiRingCat)
    (forget SemiRingCat.{u})
#align CommSemiRing.filtered_colimits.forget_preserves_filtered_colimits CommSemiRingCat.FilteredColimits.forgetPreservesFilteredColimits
-/

end

end CommSemiRingCat.FilteredColimits

namespace RingCat.FilteredColimits

section

-- We use parameters here, mainly so we can have the abbreviation `R` below, without
-- passing around `F` all the time.
parameter {J : Type v} [SmallCategory J] [IsFiltered J] (F : J ⥤ RingCat.{max v u})

#print RingCat.FilteredColimits.R /-
/-- The colimit of `F ⋙ forget₂ Ring SemiRing` in the category `SemiRing`.
In the following, we will show that this has the structure of a ring.
-/
abbrev R : SemiRingCat :=
  SemiRingCat.FilteredColimits.colimit (F ⋙ forget₂ RingCat SemiRingCat.{max v u})
#align Ring.filtered_colimits.R RingCat.FilteredColimits.R
-/

#print RingCat.FilteredColimits.colimitRing /-
instance colimitRing : Ring R :=
  { R.Semiring,
    AddCommGroupCat.FilteredColimits.colimitAddCommGroup
      (F ⋙ forget₂ RingCat AddCommGroupCat.{max v u}) with }
#align Ring.filtered_colimits.colimit_ring RingCat.FilteredColimits.colimitRing
-/

#print RingCat.FilteredColimits.colimit /-
/-- The bundled ring giving the filtered colimit of a diagram. -/
def colimit : RingCat :=
  RingCat.of R
#align Ring.filtered_colimits.colimit RingCat.FilteredColimits.colimit
-/

#print RingCat.FilteredColimits.colimitCocone /-
/-- The cocone over the proposed colimit ring. -/
def colimitCocone : cocone F where
  pt := colimit
  ι :=
    {
      (SemiRingCat.FilteredColimits.colimitCocone
          (F ⋙ forget₂ RingCat SemiRingCat.{max v u})).ι with }
#align Ring.filtered_colimits.colimit_cocone RingCat.FilteredColimits.colimitCocone
-/

#print RingCat.FilteredColimits.colimitCoconeIsColimit /-
/-- The proposed colimit cocone is a colimit in `Ring`. -/
def colimitCoconeIsColimit : IsColimit colimit_cocone
    where
  desc t :=
    (SemiRingCat.FilteredColimits.colimitCoconeIsColimit
          (F ⋙ forget₂ RingCat SemiRingCat.{max v u})).desc
      ((forget₂ RingCat SemiRingCat).mapCocone t)
  fac t j :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget RingCat)).fac ((forget RingCat).mapCocone t) j
  uniq t m h :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget RingCat)).uniq ((forget RingCat).mapCocone t) m
        fun j => funext fun x => RingHom.congr_fun (h j) x
#align Ring.filtered_colimits.colimit_cocone_is_colimit RingCat.FilteredColimits.colimitCoconeIsColimit
-/

#print RingCat.FilteredColimits.forget₂SemiRingPreservesFilteredColimits /-
instance forget₂SemiRingPreservesFilteredColimits :
    PreservesFilteredColimits (forget₂ RingCat SemiRingCat.{u})
    where PreservesFilteredColimits J _ _ :=
    {
      PreservesColimit := fun F =>
        preserves_colimit_of_preserves_colimit_cocone (colimitCoconeIsColimit.{u, u} F)
          (SemiRingCat.FilteredColimits.colimitCoconeIsColimit
            (F ⋙ forget₂ RingCat SemiRingCat.{u})) }
#align Ring.filtered_colimits.forget₂_SemiRing_preserves_filtered_colimits RingCat.FilteredColimits.forget₂SemiRingPreservesFilteredColimits
-/

#print RingCat.FilteredColimits.forgetPreservesFilteredColimits /-
instance forgetPreservesFilteredColimits : PreservesFilteredColimits (forget RingCat.{u}) :=
  Limits.compPreservesFilteredColimits (forget₂ RingCat SemiRingCat) (forget SemiRingCat.{u})
#align Ring.filtered_colimits.forget_preserves_filtered_colimits RingCat.FilteredColimits.forgetPreservesFilteredColimits
-/

end

end RingCat.FilteredColimits

namespace CommRingCat.FilteredColimits

section

-- We use parameters here, mainly so we can have the abbreviation `R` below, without
-- passing around `F` all the time.
parameter {J : Type v} [SmallCategory J] [IsFiltered J] (F : J ⥤ CommRingCat.{max v u})

#print CommRingCat.FilteredColimits.R /-
/-- The colimit of `F ⋙ forget₂ CommRing Ring` in the category `Ring`.
In the following, we will show that this has the structure of a _commutative_ ring.
-/
abbrev R : RingCat :=
  RingCat.FilteredColimits.colimit (F ⋙ forget₂ CommRingCat RingCat.{max v u})
#align CommRing.filtered_colimits.R CommRingCat.FilteredColimits.R
-/

#print CommRingCat.FilteredColimits.colimitCommRing /-
instance colimitCommRing : CommRing R :=
  { R.Ring,
    CommSemiRingCat.FilteredColimits.colimitCommSemiring
      (F ⋙ forget₂ CommRingCat CommSemiRingCat.{max v u}) with }
#align CommRing.filtered_colimits.colimit_comm_ring CommRingCat.FilteredColimits.colimitCommRing
-/

#print CommRingCat.FilteredColimits.colimit /-
/-- The bundled commutative ring giving the filtered colimit of a diagram. -/
def colimit : CommRingCat :=
  CommRingCat.of R
#align CommRing.filtered_colimits.colimit CommRingCat.FilteredColimits.colimit
-/

#print CommRingCat.FilteredColimits.colimitCocone /-
/-- The cocone over the proposed colimit commutative ring. -/
def colimitCocone : cocone F where
  pt := colimit
  ι :=
    { (RingCat.FilteredColimits.colimitCocone (F ⋙ forget₂ CommRingCat RingCat.{max v u})).ι with }
#align CommRing.filtered_colimits.colimit_cocone CommRingCat.FilteredColimits.colimitCocone
-/

#print CommRingCat.FilteredColimits.colimitCoconeIsColimit /-
/-- The proposed colimit cocone is a colimit in `CommRing`. -/
def colimitCoconeIsColimit : IsColimit colimit_cocone
    where
  desc t :=
    (RingCat.FilteredColimits.colimitCoconeIsColimit
          (F ⋙ forget₂ CommRingCat RingCat.{max v u})).desc
      ((forget₂ CommRingCat RingCat).mapCocone t)
  fac t j :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget CommRingCat)).fac ((forget CommRingCat).mapCocone t)
        j
  uniq t m h :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget CommRingCat)).uniq
        ((forget CommRingCat).mapCocone t) m fun j => funext fun x => RingHom.congr_fun (h j) x
#align CommRing.filtered_colimits.colimit_cocone_is_colimit CommRingCat.FilteredColimits.colimitCoconeIsColimit
-/

#print CommRingCat.FilteredColimits.forget₂RingPreservesFilteredColimits /-
instance forget₂RingPreservesFilteredColimits :
    PreservesFilteredColimits (forget₂ CommRingCat RingCat.{u})
    where PreservesFilteredColimits J _ _ :=
    {
      PreservesColimit := fun F =>
        preserves_colimit_of_preserves_colimit_cocone (colimitCoconeIsColimit.{u, u} F)
          (RingCat.FilteredColimits.colimitCoconeIsColimit (F ⋙ forget₂ CommRingCat RingCat.{u})) }
#align CommRing.filtered_colimits.forget₂_Ring_preserves_filtered_colimits CommRingCat.FilteredColimits.forget₂RingPreservesFilteredColimits
-/

#print CommRingCat.FilteredColimits.forgetPreservesFilteredColimits /-
instance forgetPreservesFilteredColimits : PreservesFilteredColimits (forget CommRingCat.{u}) :=
  Limits.compPreservesFilteredColimits (forget₂ CommRingCat RingCat) (forget RingCat.{u})
#align CommRing.filtered_colimits.forget_preserves_filtered_colimits CommRingCat.FilteredColimits.forgetPreservesFilteredColimits
-/

end

end CommRingCat.FilteredColimits

