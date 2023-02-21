/-
Copyright (c) 2021 Justus Springer. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Justus Springer

! This file was ported from Lean 3 source module algebra.category.Ring.filtered_colimits
! leanprover-community/mathlib commit c43486ecf2a5a17479a32ce09e4818924145e90e
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Category.Ring.Basic
import Mathbin.Algebra.Category.Group.FilteredColimits

/-!
# The forgetful functor from (commutative) (semi-) rings preserves filtered colimits.

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

open Classical

open CategoryTheory

open CategoryTheory.Limits

open CategoryTheory.IsFiltered renaming max → max'

-- avoid name collision with `_root_.max`.
open AddMon.FilteredColimits (colimit_zero_eq colimit_add_mk_eq)

open Mon.FilteredColimits (colimit_one_eq colimit_mul_mk_eq)

namespace SemiRing.FilteredColimits

section

-- We use parameters here, mainly so we can have the abbreviations `R` and `R.mk` below, without
-- passing around `F` all the time.
parameter {J : Type v}[SmallCategory J](F : J ⥤ SemiRing.{max v u})

-- This instance is needed below in `colimit_semiring`, during the verification of the
-- semiring axioms.
instance semiringObj (j : J) :
    Semiring (((F ⋙ forget₂ SemiRing Mon.{max v u}) ⋙ forget Mon).obj j) :=
  show Semiring (F.obj j) by infer_instance
#align SemiRing.filtered_colimits.semiring_obj SemiRing.FilteredColimits.semiringObj

variable [IsFiltered J]

/-- The colimit of `F ⋙ forget₂ SemiRing Mon` in the category `Mon`.
In the following, we will show that this has the structure of a semiring.
-/
abbrev r : Mon :=
  Mon.FilteredColimits.colimit (F ⋙ forget₂ SemiRing Mon.{max v u})
#align SemiRing.filtered_colimits.R SemiRing.FilteredColimits.r

instance colimitSemiring : Semiring R :=
  { R.Monoid,
    AddCommMon.FilteredColimits.colimitAddCommMonoid
      (F ⋙
        forget₂ SemiRing
          AddCommMon.{max v
              u}) with
    mul_zero := fun x => by
      apply Quot.inductionOn x; clear x; intro x
      cases' x with j x
      erw [colimit_zero_eq _ j, colimit_mul_mk_eq _ ⟨j, _⟩ ⟨j, _⟩ j (𝟙 j) (𝟙 j)]
      rw [CategoryTheory.Functor.map_id, id_apply, id_apply, mul_zero x]
      rfl
    zero_mul := fun x => by
      apply Quot.inductionOn x; clear x; intro x
      cases' x with j x
      erw [colimit_zero_eq _ j, colimit_mul_mk_eq _ ⟨j, _⟩ ⟨j, _⟩ j (𝟙 j) (𝟙 j)]
      rw [CategoryTheory.Functor.map_id, id_apply, id_apply, zero_mul x]
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
#align SemiRing.filtered_colimits.colimit_semiring SemiRing.FilteredColimits.colimitSemiring

/-- The bundled semiring giving the filtered colimit of a diagram. -/
def colimit : SemiRing :=
  SemiRing.of R
#align SemiRing.filtered_colimits.colimit SemiRing.FilteredColimits.colimit

/-- The cocone over the proposed colimit semiring. -/
def colimitCocone : cocone F where
  x := colimit
  ι :=
    { app := fun j =>
        { (Mon.FilteredColimits.colimitCocone (F ⋙ forget₂ SemiRing Mon.{max v u})).ι.app j,
          (AddCommMon.FilteredColimits.colimitCocone
                  (F ⋙ forget₂ SemiRing AddCommMon.{max v u})).ι.app
            j with }
      naturality' := fun j j' f =>
        RingHom.coe_inj ((Types.colimitCocone (F ⋙ forget SemiRing)).ι.naturality f) }
#align SemiRing.filtered_colimits.colimit_cocone SemiRing.FilteredColimits.colimitCocone

/-- The proposed colimit cocone is a colimit in `SemiRing`. -/
def colimitCoconeIsColimit : IsColimit colimit_cocone
    where
  desc t :=
    {
      (Mon.FilteredColimits.colimitCoconeIsColimit (F ⋙ forget₂ SemiRing Mon.{max v u})).desc
        ((forget₂ SemiRing Mon.{max v u}).mapCocone t),
      (AddCommMon.FilteredColimits.colimit_cocone_is_colimit
            (F ⋙ forget₂ SemiRing AddCommMon.{max v u})).desc
        ((forget₂ SemiRing AddCommMon.{max v u}).mapCocone t) with }
  fac' t j :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget SemiRing)).fac ((forget SemiRing).mapCocone t) j
  uniq' t m h :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget SemiRing)).uniq ((forget SemiRing).mapCocone t) m
        fun j => funext fun x => RingHom.congr_fun (h j) x
#align SemiRing.filtered_colimits.colimit_cocone_is_colimit SemiRing.FilteredColimits.colimitCoconeIsColimit

instance forget₂MonPreservesFilteredColimits : PreservesFilteredColimits (forget₂ SemiRing Mon.{u})
    where PreservesFilteredColimits J _ _ :=
    {
      PreservesColimit := fun F =>
        preserves_colimit_of_preserves_colimit_cocone (colimitCoconeIsColimit.{u, u} F)
          (Mon.FilteredColimits.colimitCoconeIsColimit (F ⋙ forget₂ SemiRing Mon.{u})) }
#align SemiRing.filtered_colimits.forget₂_Mon_preserves_filtered_colimits SemiRing.FilteredColimits.forget₂MonPreservesFilteredColimits

instance forgetPreservesFilteredColimits : PreservesFilteredColimits (forget SemiRing.{u}) :=
  Limits.compPreservesFilteredColimits (forget₂ SemiRing Mon) (forget Mon.{u})
#align SemiRing.filtered_colimits.forget_preserves_filtered_colimits SemiRing.FilteredColimits.forgetPreservesFilteredColimits

end

end SemiRing.FilteredColimits

namespace CommSemiRing.FilteredColimits

section

-- We use parameters here, mainly so we can have the abbreviation `R` below, without
-- passing around `F` all the time.
parameter {J : Type v}[SmallCategory J][IsFiltered J](F : J ⥤ CommSemiRing.{max v u})

/-- The colimit of `F ⋙ forget₂ CommSemiRing SemiRing` in the category `SemiRing`.
In the following, we will show that this has the structure of a _commutative_ semiring.
-/
abbrev r : SemiRing :=
  SemiRing.FilteredColimits.colimit (F ⋙ forget₂ CommSemiRing SemiRing.{max v u})
#align CommSemiRing.filtered_colimits.R CommSemiRing.FilteredColimits.r

instance colimitCommSemiring : CommSemiring R :=
  { R.Semiring,
    CommMon.FilteredColimits.colimitCommMonoid (F ⋙ forget₂ CommSemiRing CommMon.{max v u}) with }
#align CommSemiRing.filtered_colimits.colimit_comm_semiring CommSemiRing.FilteredColimits.colimitCommSemiring

/-- The bundled commutative semiring giving the filtered colimit of a diagram. -/
def colimit : CommSemiRing :=
  CommSemiRing.of R
#align CommSemiRing.filtered_colimits.colimit CommSemiRing.FilteredColimits.colimit

/-- The cocone over the proposed colimit commutative semiring. -/
def colimitCocone : cocone F where
  x := colimit
  ι :=
    {
      (SemiRing.FilteredColimits.colimitCocone
          (F ⋙ forget₂ CommSemiRing SemiRing.{max v u})).ι with }
#align CommSemiRing.filtered_colimits.colimit_cocone CommSemiRing.FilteredColimits.colimitCocone

/-- The proposed colimit cocone is a colimit in `CommSemiRing`. -/
def colimitCoconeIsColimit : IsColimit colimit_cocone
    where
  desc t :=
    (SemiRing.FilteredColimits.colimitCoconeIsColimit
          (F ⋙ forget₂ CommSemiRing SemiRing.{max v u})).desc
      ((forget₂ CommSemiRing SemiRing).mapCocone t)
  fac' t j :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget CommSemiRing)).fac
        ((forget CommSemiRing).mapCocone t) j
  uniq' t m h :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget CommSemiRing)).uniq
        ((forget CommSemiRing).mapCocone t) m fun j => funext fun x => RingHom.congr_fun (h j) x
#align CommSemiRing.filtered_colimits.colimit_cocone_is_colimit CommSemiRing.FilteredColimits.colimitCoconeIsColimit

instance forget₂SemiRingPreservesFilteredColimits :
    PreservesFilteredColimits (forget₂ CommSemiRing SemiRing.{u})
    where PreservesFilteredColimits J _ _ :=
    {
      PreservesColimit := fun F =>
        preserves_colimit_of_preserves_colimit_cocone (colimitCoconeIsColimit.{u, u} F)
          (SemiRing.FilteredColimits.colimitCoconeIsColimit
            (F ⋙ forget₂ CommSemiRing SemiRing.{u})) }
#align CommSemiRing.filtered_colimits.forget₂_SemiRing_preserves_filtered_colimits CommSemiRing.FilteredColimits.forget₂SemiRingPreservesFilteredColimits

instance forgetPreservesFilteredColimits : PreservesFilteredColimits (forget CommSemiRing.{u}) :=
  Limits.compPreservesFilteredColimits (forget₂ CommSemiRing SemiRing) (forget SemiRing.{u})
#align CommSemiRing.filtered_colimits.forget_preserves_filtered_colimits CommSemiRing.FilteredColimits.forgetPreservesFilteredColimits

end

end CommSemiRing.FilteredColimits

namespace RingCat.FilteredColimits

section

-- We use parameters here, mainly so we can have the abbreviation `R` below, without
-- passing around `F` all the time.
parameter {J : Type v}[SmallCategory J][IsFiltered J](F : J ⥤ RingCat.{max v u})

/-- The colimit of `F ⋙ forget₂ Ring SemiRing` in the category `SemiRing`.
In the following, we will show that this has the structure of a ring.
-/
abbrev r : SemiRing :=
  SemiRing.FilteredColimits.colimit (F ⋙ forget₂ RingCat SemiRing.{max v u})
#align Ring.filtered_colimits.R RingCat.FilteredColimits.r

instance colimitRing : Ring R :=
  { R.Semiring,
    AddCommGroupCat.FilteredColimits.colimitAddCommGroup
      (F ⋙ forget₂ RingCat AddCommGroupCat.{max v u}) with }
#align Ring.filtered_colimits.colimit_ring RingCat.FilteredColimits.colimitRing

/-- The bundled ring giving the filtered colimit of a diagram. -/
def colimit : RingCat :=
  RingCat.of R
#align Ring.filtered_colimits.colimit RingCat.FilteredColimits.colimit

/-- The cocone over the proposed colimit ring. -/
def colimitCocone : cocone F where
  x := colimit
  ι := { (SemiRing.FilteredColimits.colimitCocone (F ⋙ forget₂ RingCat SemiRing.{max v u})).ι with }
#align Ring.filtered_colimits.colimit_cocone RingCat.FilteredColimits.colimitCocone

/-- The proposed colimit cocone is a colimit in `Ring`. -/
def colimitCoconeIsColimit : IsColimit colimit_cocone
    where
  desc t :=
    (SemiRing.FilteredColimits.colimitCoconeIsColimit (F ⋙ forget₂ RingCat SemiRing.{max v u})).desc
      ((forget₂ RingCat SemiRing).mapCocone t)
  fac' t j :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget RingCat)).fac ((forget RingCat).mapCocone t) j
  uniq' t m h :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget RingCat)).uniq ((forget RingCat).mapCocone t) m
        fun j => funext fun x => RingHom.congr_fun (h j) x
#align Ring.filtered_colimits.colimit_cocone_is_colimit RingCat.FilteredColimits.colimitCoconeIsColimit

instance forget₂SemiRingPreservesFilteredColimits :
    PreservesFilteredColimits (forget₂ RingCat SemiRing.{u})
    where PreservesFilteredColimits J _ _ :=
    {
      PreservesColimit := fun F =>
        preserves_colimit_of_preserves_colimit_cocone (colimitCoconeIsColimit.{u, u} F)
          (SemiRing.FilteredColimits.colimitCoconeIsColimit (F ⋙ forget₂ RingCat SemiRing.{u})) }
#align Ring.filtered_colimits.forget₂_SemiRing_preserves_filtered_colimits RingCat.FilteredColimits.forget₂SemiRingPreservesFilteredColimits

instance forgetPreservesFilteredColimits : PreservesFilteredColimits (forget RingCat.{u}) :=
  Limits.compPreservesFilteredColimits (forget₂ RingCat SemiRing) (forget SemiRing.{u})
#align Ring.filtered_colimits.forget_preserves_filtered_colimits RingCat.FilteredColimits.forgetPreservesFilteredColimits

end

end RingCat.FilteredColimits

namespace CommRingCat.FilteredColimits

section

-- We use parameters here, mainly so we can have the abbreviation `R` below, without
-- passing around `F` all the time.
parameter {J : Type v}[SmallCategory J][IsFiltered J](F : J ⥤ CommRingCat.{max v u})

/-- The colimit of `F ⋙ forget₂ CommRing Ring` in the category `Ring`.
In the following, we will show that this has the structure of a _commutative_ ring.
-/
abbrev r : RingCat :=
  RingCat.FilteredColimits.colimit (F ⋙ forget₂ CommRingCat RingCat.{max v u})
#align CommRing.filtered_colimits.R CommRingCat.FilteredColimits.r

instance colimitCommRing : CommRing R :=
  { R.Ring,
    CommSemiRing.FilteredColimits.colimitCommSemiring
      (F ⋙ forget₂ CommRingCat CommSemiRing.{max v u}) with }
#align CommRing.filtered_colimits.colimit_comm_ring CommRingCat.FilteredColimits.colimitCommRing

/-- The bundled commutative ring giving the filtered colimit of a diagram. -/
def colimit : CommRingCat :=
  CommRingCat.of R
#align CommRing.filtered_colimits.colimit CommRingCat.FilteredColimits.colimit

/-- The cocone over the proposed colimit commutative ring. -/
def colimitCocone : cocone F where
  x := colimit
  ι :=
    { (RingCat.FilteredColimits.colimitCocone (F ⋙ forget₂ CommRingCat RingCat.{max v u})).ι with }
#align CommRing.filtered_colimits.colimit_cocone CommRingCat.FilteredColimits.colimitCocone

/-- The proposed colimit cocone is a colimit in `CommRing`. -/
def colimitCoconeIsColimit : IsColimit colimit_cocone
    where
  desc t :=
    (RingCat.FilteredColimits.colimitCoconeIsColimit
          (F ⋙ forget₂ CommRingCat RingCat.{max v u})).desc
      ((forget₂ CommRingCat RingCat).mapCocone t)
  fac' t j :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget CommRingCat)).fac ((forget CommRingCat).mapCocone t)
        j
  uniq' t m h :=
    RingHom.coe_inj <|
      (Types.colimitCoconeIsColimit (F ⋙ forget CommRingCat)).uniq
        ((forget CommRingCat).mapCocone t) m fun j => funext fun x => RingHom.congr_fun (h j) x
#align CommRing.filtered_colimits.colimit_cocone_is_colimit CommRingCat.FilteredColimits.colimitCoconeIsColimit

instance forget₂RingPreservesFilteredColimits :
    PreservesFilteredColimits (forget₂ CommRingCat RingCat.{u})
    where PreservesFilteredColimits J _ _ :=
    {
      PreservesColimit := fun F =>
        preserves_colimit_of_preserves_colimit_cocone (colimitCoconeIsColimit.{u, u} F)
          (RingCat.FilteredColimits.colimitCoconeIsColimit (F ⋙ forget₂ CommRingCat RingCat.{u})) }
#align CommRing.filtered_colimits.forget₂_Ring_preserves_filtered_colimits CommRingCat.FilteredColimits.forget₂RingPreservesFilteredColimits

instance forgetPreservesFilteredColimits : PreservesFilteredColimits (forget CommRingCat.{u}) :=
  Limits.compPreservesFilteredColimits (forget₂ CommRingCat RingCat) (forget RingCat.{u})
#align CommRing.filtered_colimits.forget_preserves_filtered_colimits CommRingCat.FilteredColimits.forgetPreservesFilteredColimits

end

end CommRingCat.FilteredColimits

