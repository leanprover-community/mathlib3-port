/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin

! This file was ported from Lean 3 source module algebraic_geometry.locally_ringed_space
! leanprover-community/mathlib commit 509de852e1de55e1efa8eacfa11df0823f26f226
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.AlgebraicGeometry.RingedSpace
import Mathbin.AlgebraicGeometry.Stalks
import Mathbin.Logic.Equiv.TransferInstance

/-!
# The category of locally ringed spaces

We define (bundled) locally ringed spaces (as `SheafedSpace CommRing` along with the fact that the
stalks are local rings), and morphisms between these (morphisms in `SheafedSpace` with
`is_local_ring_hom` on the stalk maps).
-/


universe v u

open CategoryTheory

open TopCat

open TopologicalSpace

open Opposite

open CategoryTheory.Category CategoryTheory.Functor

namespace AlgebraicGeometry

/-- A `LocallyRingedSpace` is a topological space equipped with a sheaf of commutative rings
such that all the stalks are local rings.

A morphism of locally ringed spaces is a morphism of ringed spaces
such that the morphisms induced on stalks are local ring homomorphisms. -/
@[nolint has_nonempty_instance]
structure LocallyRingedSpaceCat extends SheafedSpaceCat CommRingCat where
  LocalRing : ∀ x, LocalRing (presheaf.stalk x)
#align algebraic_geometry.LocallyRingedSpace AlgebraicGeometry.LocallyRingedSpaceCat

attribute [instance] LocallyRingedSpace.local_ring

namespace LocallyRingedSpaceCat

variable (X : LocallyRingedSpaceCat)

/-- An alias for `to_SheafedSpace`, where the result type is a `RingedSpace`.
This allows us to use dot-notation for the `RingedSpace` namespace.
 -/
def toRingedSpace : RingedSpaceCat :=
  X.toSheafedSpace
#align
  algebraic_geometry.LocallyRingedSpace.to_RingedSpace AlgebraicGeometry.LocallyRingedSpaceCat.toRingedSpace

/-- The underlying topological space of a locally ringed space. -/
def toTop : TopCat :=
  X.1.carrier
#align algebraic_geometry.LocallyRingedSpace.to_Top AlgebraicGeometry.LocallyRingedSpaceCat.toTop

instance : CoeSort LocallyRingedSpaceCat (Type u) :=
  ⟨fun X : LocallyRingedSpaceCat => (X.toTop : Type u)⟩

instance (x : X) : LocalRing (X.toPresheafedSpace.stalk x) :=
  X.LocalRing x

-- PROJECT: how about a typeclass "has_structure_sheaf" to mediate the 𝒪 notation, rather
-- than defining it over and over for PresheafedSpace, LRS, Scheme, etc.
/-- The structure sheaf of a locally ringed space. -/
def 𝒪 : Sheaf CommRingCat X.toTop :=
  X.toSheafedSpace.Sheaf
#align algebraic_geometry.LocallyRingedSpace.𝒪 AlgebraicGeometry.LocallyRingedSpaceCat.𝒪

/-- A morphism of locally ringed spaces is a morphism of ringed spaces
 such that the morphims induced on stalks are local ring homomorphisms. -/
@[ext]
structure Hom (X Y : LocallyRingedSpaceCat.{u}) : Type u where
  val : X.toSheafedSpace ⟶ Y.toSheafedSpace
  Prop : ∀ x, IsLocalRingHom (PresheafedSpaceCat.stalkMap val x)
#align algebraic_geometry.LocallyRingedSpace.hom AlgebraicGeometry.LocallyRingedSpaceCat.Hom

instance : Quiver LocallyRingedSpaceCat :=
  ⟨Hom⟩

-- TODO perhaps we should make a bundled `LocalRing` and return one here?
-- TODO define `sheaf.stalk` so we can write `X.𝒪.stalk` here?
/-- The stalk of a locally ringed space, just as a `CommRing`.
-/
noncomputable def stalk (X : LocallyRingedSpaceCat) (x : X) : CommRingCat :=
  X.Presheaf.stalk x
#align algebraic_geometry.LocallyRingedSpace.stalk AlgebraicGeometry.LocallyRingedSpaceCat.stalk

/-- A morphism of locally ringed spaces `f : X ⟶ Y` induces
a local ring homomorphism from `Y.stalk (f x)` to `X.stalk x` for any `x : X`.
-/
noncomputable def stalkMap {X Y : LocallyRingedSpaceCat} (f : X ⟶ Y) (x : X) :
    Y.stalk (f.1.1 x) ⟶ X.stalk x :=
  PresheafedSpaceCat.stalkMap f.1 x
#align
  algebraic_geometry.LocallyRingedSpace.stalk_map AlgebraicGeometry.LocallyRingedSpaceCat.stalkMap

instance {X Y : LocallyRingedSpaceCat} (f : X ⟶ Y) (x : X) : IsLocalRingHom (stalkMap f x) :=
  f.2 x

instance {X Y : LocallyRingedSpaceCat} (f : X ⟶ Y) (x : X) :
    IsLocalRingHom (PresheafedSpaceCat.stalkMap f.1 x) :=
  f.2 x

/-- The identity morphism on a locally ringed space. -/
@[simps]
def id (X : LocallyRingedSpaceCat) : Hom X X :=
  ⟨𝟙 _, fun x => by
    erw [PresheafedSpace.stalk_map.id]
    apply is_local_ring_hom_id⟩
#align algebraic_geometry.LocallyRingedSpace.id AlgebraicGeometry.LocallyRingedSpaceCat.id

instance (X : LocallyRingedSpaceCat) : Inhabited (Hom X X) :=
  ⟨id X⟩

/-- Composition of morphisms of locally ringed spaces. -/
def comp {X Y Z : LocallyRingedSpaceCat} (f : Hom X Y) (g : Hom Y Z) : Hom X Z :=
  ⟨f.val ≫ g.val, fun x => by
    erw [PresheafedSpace.stalk_map.comp]
    exact @is_local_ring_hom_comp _ _ _ _ _ _ _ _ (f.2 _) (g.2 _)⟩
#align algebraic_geometry.LocallyRingedSpace.comp AlgebraicGeometry.LocallyRingedSpaceCat.comp

/-- The category of locally ringed spaces. -/
instance : Category LocallyRingedSpaceCat
    where
  Hom := Hom
  id := id
  comp X Y Z f g := comp f g
  comp_id' := by
    intros
    ext1
    simp [comp]
  id_comp' := by
    intros
    ext1
    simp [comp]
  assoc' := by
    intros
    ext1
    simp [comp]

/-- The forgetful functor from `LocallyRingedSpace` to `SheafedSpace CommRing`. -/
@[simps]
def forgetToSheafedSpace : LocallyRingedSpace ⥤ SheafedSpaceCat CommRingCat
    where
  obj X := X.toSheafedSpace
  map X Y f := f.1
#align
  algebraic_geometry.LocallyRingedSpace.forget_to_SheafedSpace AlgebraicGeometry.LocallyRingedSpaceCat.forgetToSheafedSpace

instance : Faithful forgetToSheafedSpace where

/-- The forgetful functor from `LocallyRingedSpace` to `Top`. -/
@[simps]
def forgetToTop : LocallyRingedSpace ⥤ TopCat :=
  forget_to_SheafedSpace ⋙ SheafedSpaceCat.forget _
#align
  algebraic_geometry.LocallyRingedSpace.forget_to_Top AlgebraicGeometry.LocallyRingedSpaceCat.forgetToTop

@[simp]
theorem comp_val {X Y Z : LocallyRingedSpaceCat} (f : X ⟶ Y) (g : Y ⟶ Z) :
    (f ≫ g).val = f.val ≫ g.val :=
  rfl
#align
  algebraic_geometry.LocallyRingedSpace.comp_val AlgebraicGeometry.LocallyRingedSpaceCat.comp_val

@[simp]
theorem comp_val_c {X Y Z : LocallyRingedSpaceCat.{u}} (f : X ⟶ Y) (g : Y ⟶ Z) :
    (f ≫ g).val.c = g.val.c ≫ (Presheaf.pushforward _ g.val.base).map f.val.c :=
  rfl
#align
  algebraic_geometry.LocallyRingedSpace.comp_val_c AlgebraicGeometry.LocallyRingedSpaceCat.comp_val_c

theorem comp_val_c_app {X Y Z : LocallyRingedSpaceCat} (f : X ⟶ Y) (g : Y ⟶ Z) (U : (Opens Z)ᵒᵖ) :
    (f ≫ g).val.c.app U = g.val.c.app U ≫ f.val.c.app (op <| (Opens.map g.val.base).obj U.unop) :=
  rfl
#align
  algebraic_geometry.LocallyRingedSpace.comp_val_c_app AlgebraicGeometry.LocallyRingedSpaceCat.comp_val_c_app

/-- Given two locally ringed spaces `X` and `Y`, an isomorphism between `X` and `Y` as _sheafed_
spaces can be lifted to a morphism `X ⟶ Y` as locally ringed spaces.

See also `iso_of_SheafedSpace_iso`.
-/
@[simps]
def homOfSheafedSpaceHomOfIsIso {X Y : LocallyRingedSpaceCat}
    (f : X.toSheafedSpace ⟶ Y.toSheafedSpace) [IsIso f] : X ⟶ Y :=
  Hom.mk f fun x =>
    -- Here we need to see that the stalk maps are really local ring homomorphisms.
    -- This can be solved by type class inference, because stalk maps of isomorphisms are isomorphisms
    -- and isomorphisms are local ring homomorphisms.
    show
      IsLocalRingHom (PresheafedSpaceCat.stalkMap (SheafedSpaceCat.forgetToPresheafedSpace.map f) x)
      by infer_instance
#align
  algebraic_geometry.LocallyRingedSpace.hom_of_SheafedSpace_hom_of_is_iso AlgebraicGeometry.LocallyRingedSpaceCat.homOfSheafedSpaceHomOfIsIso

/-- Given two locally ringed spaces `X` and `Y`, an isomorphism between `X` and `Y` as _sheafed_
spaces can be lifted to an isomorphism `X ⟶ Y` as locally ringed spaces.

This is related to the property that the functor `forget_to_SheafedSpace` reflects isomorphisms.
In fact, it is slightly stronger as we do not require `f` to come from a morphism between
_locally_ ringed spaces.
-/
def isoOfSheafedSpaceIso {X Y : LocallyRingedSpaceCat} (f : X.toSheafedSpace ≅ Y.toSheafedSpace) :
    X ≅ Y where
  Hom := homOfSheafedSpaceHomOfIsIso f.Hom
  inv := homOfSheafedSpaceHomOfIsIso f.inv
  hom_inv_id' := Hom.ext _ _ f.hom_inv_id
  inv_hom_id' := Hom.ext _ _ f.inv_hom_id
#align
  algebraic_geometry.LocallyRingedSpace.iso_of_SheafedSpace_iso AlgebraicGeometry.LocallyRingedSpaceCat.isoOfSheafedSpaceIso

instance : ReflectsIsomorphisms forgetToSheafedSpace
    where reflects X Y f i :=
    {
      out :=
        ⟨hom_of_SheafedSpace_hom_of_is_iso (CategoryTheory.inv (forget_to_SheafedSpace.map f)),
          hom.ext _ _ (is_iso.hom_inv_id _), hom.ext _ _ (is_iso.inv_hom_id _)⟩ }

instance is_SheafedSpace_iso {X Y : LocallyRingedSpaceCat} (f : X ⟶ Y) [IsIso f] : IsIso f.1 :=
  LocallyRingedSpaceCat.forgetToSheafedSpace.map_is_iso f
#align
  algebraic_geometry.LocallyRingedSpace.is_SheafedSpace_iso AlgebraicGeometry.LocallyRingedSpaceCat.is_SheafedSpace_iso

/-- The restriction of a locally ringed space along an open embedding.
-/
@[simps]
def restrict {U : TopCat} (X : LocallyRingedSpaceCat) {f : U ⟶ X.toTop} (h : OpenEmbedding f) :
    LocallyRingedSpaceCat
    where
  LocalRing := by
    intro x
    dsimp at *
    -- We show that the stalk of the restriction is isomorphic to the original stalk,
    apply @RingEquiv.local_ring _ _ _ (X.local_ring (f x))
    exact (X.to_PresheafedSpace.restrict_stalk_iso h x).symm.commRingIsoToRingEquiv
  toSheafedSpace := X.toSheafedSpace.restrict h
#align
  algebraic_geometry.LocallyRingedSpace.restrict AlgebraicGeometry.LocallyRingedSpaceCat.restrict

/-- The canonical map from the restriction to the supspace. -/
def ofRestrict {U : TopCat} (X : LocallyRingedSpaceCat) {f : U ⟶ X.toTop} (h : OpenEmbedding f) :
    X.restrict h ⟶ X :=
  ⟨X.toPresheafedSpace.of_restrict h, fun x => inferInstance⟩
#align
  algebraic_geometry.LocallyRingedSpace.of_restrict AlgebraicGeometry.LocallyRingedSpaceCat.ofRestrict

/-- The restriction of a locally ringed space `X` to the top subspace is isomorphic to `X` itself.
-/
def restrictTopIso (X : LocallyRingedSpaceCat) : X.restrict (Opens.open_embedding ⊤) ≅ X :=
  @isoOfSheafedSpaceIso (X.restrict (Opens.open_embedding ⊤)) X X.toSheafedSpace.restrictTopIso
#align
  algebraic_geometry.LocallyRingedSpace.restrict_top_iso AlgebraicGeometry.LocallyRingedSpaceCat.restrictTopIso

/-- The global sections, notated Gamma.
-/
def Γ : LocallyRingedSpaceᵒᵖ ⥤ CommRingCat :=
  forgetToSheafedSpace.op ⋙ SheafedSpace.Γ
#align algebraic_geometry.LocallyRingedSpace.Γ AlgebraicGeometry.LocallyRingedSpaceCat.Γ

theorem Γ_def : Γ = forgetToSheafedSpace.op ⋙ SheafedSpace.Γ :=
  rfl
#align algebraic_geometry.LocallyRingedSpace.Γ_def AlgebraicGeometry.LocallyRingedSpaceCat.Γ_def

@[simp]
theorem Γ_obj (X : LocallyRingedSpaceᵒᵖ) : Γ.obj X = (unop X).Presheaf.obj (op ⊤) :=
  rfl
#align algebraic_geometry.LocallyRingedSpace.Γ_obj AlgebraicGeometry.LocallyRingedSpaceCat.Γ_obj

theorem Γ_obj_op (X : LocallyRingedSpaceCat) : Γ.obj (op X) = X.Presheaf.obj (op ⊤) :=
  rfl
#align
  algebraic_geometry.LocallyRingedSpace.Γ_obj_op AlgebraicGeometry.LocallyRingedSpaceCat.Γ_obj_op

@[simp]
theorem Γ_map {X Y : LocallyRingedSpaceᵒᵖ} (f : X ⟶ Y) : Γ.map f = f.unop.1.c.app (op ⊤) :=
  rfl
#align algebraic_geometry.LocallyRingedSpace.Γ_map AlgebraicGeometry.LocallyRingedSpaceCat.Γ_map

theorem Γ_map_op {X Y : LocallyRingedSpaceCat} (f : X ⟶ Y) : Γ.map f.op = f.1.c.app (op ⊤) :=
  rfl
#align
  algebraic_geometry.LocallyRingedSpace.Γ_map_op AlgebraicGeometry.LocallyRingedSpaceCat.Γ_map_op

theorem preimage_basic_open {X Y : LocallyRingedSpaceCat} (f : X ⟶ Y) {U : Opens Y}
    (s : Y.Presheaf.obj (op U)) :
    (Opens.map f.1.base).obj (Y.toRingedSpace.basicOpen s) =
      @RingedSpaceCat.basicOpen X.toRingedSpace ((Opens.map f.1.base).obj U) (f.1.c.app _ s) :=
  by
  ext
  constructor
  · rintro ⟨⟨y, hyU⟩, hy : IsUnit _, rfl : y = _⟩
    erw [RingedSpace.mem_basic_open _ _ ⟨x, show x ∈ (opens.map f.1.base).obj U from hyU⟩]
    rw [← PresheafedSpace.stalk_map_germ_apply]
    exact (PresheafedSpace.stalk_map f.1 _).is_unit_map hy
  · rintro ⟨y, hy : IsUnit _, rfl⟩
    erw [RingedSpace.mem_basic_open _ _ ⟨f.1.base y.1, y.2⟩]
    rw [← PresheafedSpace.stalk_map_germ_apply] at hy
    exact (is_unit_map_iff (PresheafedSpace.stalk_map f.1 _) _).mp hy
#align
  algebraic_geometry.LocallyRingedSpace.preimage_basic_open AlgebraicGeometry.LocallyRingedSpaceCat.preimage_basic_open

-- This actually holds for all ringed spaces with nontrivial stalks.
@[simp]
theorem basic_open_zero (X : LocallyRingedSpaceCat) (U : Opens X.carrier) :
    X.toRingedSpace.basicOpen (0 : X.Presheaf.obj <| op U) = ⊥ :=
  by
  ext
  simp only [Set.mem_empty_iff_false, TopologicalSpace.Opens.mem_coe, opens.coe_bot, iff_false_iff,
    RingedSpace.basic_open, isUnit_zero_iff, Set.mem_setOf_eq, map_zero]
  rintro ⟨⟨y, _⟩, h, e⟩
  exact zero_ne_one' (X.presheaf.stalk y) h
#align
  algebraic_geometry.LocallyRingedSpace.basic_open_zero AlgebraicGeometry.LocallyRingedSpaceCat.basic_open_zero

instance component_nontrivial (X : LocallyRingedSpaceCat) (U : Opens X.carrier) [hU : Nonempty U] :
    Nontrivial (X.Presheaf.obj <| op U) :=
  (X.toPresheafedSpace.Presheaf.germ hU.some).domain_nontrivial
#align
  algebraic_geometry.LocallyRingedSpace.component_nontrivial AlgebraicGeometry.LocallyRingedSpaceCat.component_nontrivial

end LocallyRingedSpaceCat

end AlgebraicGeometry

