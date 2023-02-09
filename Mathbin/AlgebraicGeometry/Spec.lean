/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison, Justus Springer

! This file was ported from Lean 3 source module algebraic_geometry.Spec
! leanprover-community/mathlib commit 0ebfdb71919ac6ca5d7fbc61a082fa2519556818
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.AlgebraicGeometry.LocallyRingedSpace
import Mathbin.AlgebraicGeometry.StructureSheaf
import Mathbin.Logic.Equiv.TransferInstance
import Mathbin.RingTheory.Localization.LocalizationLocalization
import Mathbin.Topology.Sheaves.SheafCondition.Sites
import Mathbin.Topology.Sheaves.Functors
import Mathbin.Algebra.Module.LocalizedModule

/-!
# $Spec$ as a functor to locally ringed spaces.

We define the functor $Spec$ from commutative rings to locally ringed spaces.

## Implementation notes

We define $Spec$ in three consecutive steps, each with more structure than the last:

1. `Spec.to_Top`, valued in the category of topological spaces,
2. `Spec.to_SheafedSpace`, valued in the category of sheafed spaces and
3. `Spec.to_LocallyRingedSpace`, valued in the category of locally ringed spaces.

Additionally, we provide `Spec.to_PresheafedSpace` as a composition of `Spec.to_SheafedSpace` with
a forgetful functor.

## Related results

The adjunction `Γ ⊣ Spec` is constructed in `algebraic_geometry/Gamma_Spec_adjunction.lean`.

-/


noncomputable section

universe u v

namespace AlgebraicGeometry

open Opposite

open CategoryTheory

open StructureSheaf

open Spec (structureSheaf)

/-- The spectrum of a commutative ring, as a topological space.
-/
def Spec.topObj (R : CommRingCat) : TopCat :=
  TopCat.of (PrimeSpectrum R)
#align algebraic_geometry.Spec.Top_obj AlgebraicGeometry.Spec.topObj

/-- The induced map of a ring homomorphism on the ring spectra, as a morphism of topological spaces.
-/
def Spec.topMap {R S : CommRingCat} (f : R ⟶ S) : Spec.topObj S ⟶ Spec.topObj R :=
  PrimeSpectrum.comap f
#align algebraic_geometry.Spec.Top_map AlgebraicGeometry.Spec.topMap

@[simp]
theorem Spec.topMap_id (R : CommRingCat) : Spec.topMap (𝟙 R) = 𝟙 (Spec.topObj R) :=
  PrimeSpectrum.comap_id
#align algebraic_geometry.Spec.Top_map_id AlgebraicGeometry.Spec.topMap_id

theorem Spec.topMap_comp {R S T : CommRingCat} (f : R ⟶ S) (g : S ⟶ T) :
    Spec.topMap (f ≫ g) = Spec.topMap g ≫ Spec.topMap f :=
  PrimeSpectrum.comap_comp _ _
#align algebraic_geometry.Spec.Top_map_comp AlgebraicGeometry.Spec.topMap_comp

/-- The spectrum, as a contravariant functor from commutative rings to topological spaces.
-/
@[simps]
def Spec.toTop : CommRingCatᵒᵖ ⥤ TopCat
    where
  obj R := Spec.topObj (unop R)
  map R S f := Spec.topMap f.unop
  map_id' R := by rw [unop_id, Spec.topMap_id]
  map_comp' R S T f g := by rw [unop_comp, Spec.topMap_comp]
#align algebraic_geometry.Spec.to_Top AlgebraicGeometry.Spec.toTop

/-- The spectrum of a commutative ring, as a `SheafedSpace`.
-/
@[simps]
def Spec.sheafedSpaceObj (R : CommRingCat) : SheafedSpace CommRingCat
    where
  carrier := Spec.topObj R
  Presheaf := (structureSheaf R).1
  IsSheaf := (structureSheaf R).2
#align algebraic_geometry.Spec.SheafedSpace_obj AlgebraicGeometry.Spec.sheafedSpaceObj

/-- The induced map of a ring homomorphism on the ring spectra, as a morphism of sheafed spaces.
-/
@[simps]
def Spec.sheafedSpaceMap {R S : CommRingCat.{u}} (f : R ⟶ S) :
    Spec.sheafedSpaceObj S ⟶ Spec.sheafedSpaceObj R
    where
  base := Spec.topMap f
  c :=
    { app := fun U =>
        comap f (unop U) ((TopologicalSpace.Opens.map (Spec.topMap f)).obj (unop U)) fun p => id
      naturality' := fun U V i => RingHom.ext fun s => Subtype.eq <| funext fun p => rfl }
#align algebraic_geometry.Spec.SheafedSpace_map AlgebraicGeometry.Spec.sheafedSpaceMap

@[simp]
theorem Spec.sheafedSpaceMap_id {R : CommRingCat} :
    Spec.sheafedSpaceMap (𝟙 R) = 𝟙 (Spec.sheafedSpaceObj R) :=
  PresheafedSpace.ext _ _ (Spec.topMap_id R) <|
    NatTrans.ext _ _ <|
      funext fun U => by
        dsimp
        erw [PresheafedSpace.id_c_app, comap_id]; swap
        · rw [Spec.topMap_id, TopologicalSpace.Opens.map_id_obj_unop]
        simpa [eqToHom_map]
#align algebraic_geometry.Spec.SheafedSpace_map_id AlgebraicGeometry.Spec.sheafedSpaceMap_id

theorem Spec.sheafedSpaceMap_comp {R S T : CommRingCat} (f : R ⟶ S) (g : S ⟶ T) :
    Spec.sheafedSpaceMap (f ≫ g) = Spec.sheafedSpaceMap g ≫ Spec.sheafedSpaceMap f :=
  PresheafedSpace.ext _ _ (Spec.topMap_comp f g) <|
    NatTrans.ext _ _ <|
      funext fun U => by
        dsimp
        rw [CategoryTheory.Functor.map_id]
        rw [Category.comp_id]
        erw [comap_comp f g]
        rfl
#align algebraic_geometry.Spec.SheafedSpace_map_comp AlgebraicGeometry.Spec.sheafedSpaceMap_comp

/-- Spec, as a contravariant functor from commutative rings to sheafed spaces.
-/
@[simps]
def Spec.toSheafedSpace : CommRingCatᵒᵖ ⥤ SheafedSpace CommRingCat
    where
  obj R := Spec.sheafedSpaceObj (unop R)
  map R S f := Spec.sheafedSpaceMap f.unop
  map_id' R := by rw [unop_id, Spec.sheafedSpaceMap_id]
  map_comp' R S T f g := by rw [unop_comp, Spec.sheafedSpaceMap_comp]
#align algebraic_geometry.Spec.to_SheafedSpace AlgebraicGeometry.Spec.toSheafedSpace

/-- Spec, as a contravariant functor from commutative rings to presheafed spaces.
-/
def Spec.toPresheafedSpace : CommRingCatᵒᵖ ⥤ PresheafedSpace.{u} CommRingCat.{u} :=
  Spec.toSheafedSpace ⋙ SheafedSpace.forgetToPresheafedSpace
#align algebraic_geometry.Spec.to_PresheafedSpace AlgebraicGeometry.Spec.toPresheafedSpace

@[simp]
theorem Spec.toPresheafedSpace_obj (R : CommRingCatᵒᵖ) :
    Spec.toPresheafedSpace.obj R = (Spec.sheafedSpaceObj (unop R)).toPresheafedSpace :=
  rfl
#align algebraic_geometry.Spec.to_PresheafedSpace_obj AlgebraicGeometry.Spec.toPresheafedSpace_obj

theorem Spec.toPresheafedSpace_obj_op (R : CommRingCat) :
    Spec.toPresheafedSpace.obj (op R) = (Spec.sheafedSpaceObj R).toPresheafedSpace :=
  rfl
#align algebraic_geometry.Spec.to_PresheafedSpace_obj_op AlgebraicGeometry.Spec.toPresheafedSpace_obj_op

@[simp]
theorem Spec.toPresheafedSpace_map (R S : CommRingCatᵒᵖ) (f : R ⟶ S) :
    Spec.toPresheafedSpace.map f = Spec.sheafedSpaceMap f.unop :=
  rfl
#align algebraic_geometry.Spec.to_PresheafedSpace_map AlgebraicGeometry.Spec.toPresheafedSpace_map

theorem Spec.toPresheafedSpace_map_op (R S : CommRingCat) (f : R ⟶ S) :
    Spec.toPresheafedSpace.map f.op = Spec.sheafedSpaceMap f :=
  rfl
#align algebraic_geometry.Spec.to_PresheafedSpace_map_op AlgebraicGeometry.Spec.toPresheafedSpace_map_op

theorem Spec.basicOpen_hom_ext {X : RingedSpace} {R : CommRingCat}
    {α β : X ⟶ Spec.sheafedSpaceObj R} (w : α.base = β.base)
    (h :
      ∀ r : R,
        let U := PrimeSpectrum.basicOpen r
        (toOpen R U ≫ α.c.app (op U)) ≫ X.presheaf.map (eqToHom (by rw [w])) =
          toOpen R U ≫ β.c.app (op U)) :
    α = β := by
  ext1
  · apply
      ((TopCat.Sheaf.pushforward β.base).obj X.sheaf).hom_ext _ PrimeSpectrum.isBasis_basic_opens
    intro r
    apply (StructureSheaf.to_basicOpen_epi R r).1
    simpa using h r
  exact w
#align algebraic_geometry.Spec.basic_open_hom_ext AlgebraicGeometry.Spec.basicOpen_hom_ext

/-- The spectrum of a commutative ring, as a `LocallyRingedSpace`.
-/
@[simps]
def Spec.locallyRingedSpaceObj (R : CommRingCat) : LocallyRingedSpace :=
  { Spec.sheafedSpaceObj R with
    LocalRing := fun x =>
      @RingEquiv.localRing _ (show LocalRing (Localization.AtPrime _) by infer_instance) _
        (Iso.commRingIsoToRingEquiv <| stalkIso R x).symm }
#align algebraic_geometry.Spec.LocallyRingedSpace_obj AlgebraicGeometry.Spec.locallyRingedSpaceObj

@[elementwise]
theorem stalkMap_toStalk {R S : CommRingCat} (f : R ⟶ S) (p : PrimeSpectrum S) :
    toStalk R (PrimeSpectrum.comap f p) ≫ PresheafedSpace.stalkMap (Spec.sheafedSpaceMap f) p =
      f ≫ toStalk S p :=
  by
  erw [← toOpen_germ S ⊤ ⟨p, trivial⟩, ← toOpen_germ R ⊤ ⟨PrimeSpectrum.comap f p, trivial⟩,
    Category.assoc, PresheafedSpace.stalkMap_germ (Spec.sheafedSpaceMap f) ⊤ ⟨p, trivial⟩,
    Spec.sheafedSpaceMap_c_app, toOpen_comp_comap_assoc]
  rfl
#align algebraic_geometry.stalk_map_to_stalk AlgebraicGeometry.stalkMap_toStalk

/-- Under the isomorphisms `stalk_iso`, the map `stalk_map (Spec.SheafedSpace_map f) p` corresponds
to the induced local ring homomorphism `localization.local_ring_hom`.
-/
@[elementwise]
theorem localRingHom_comp_stalkIso {R S : CommRingCat} (f : R ⟶ S) (p : PrimeSpectrum S) :
    (stalkIso R (PrimeSpectrum.comap f p)).hom ≫
        @CategoryStruct.comp _ _
          (CommRingCat.of (Localization.AtPrime (PrimeSpectrum.comap f p).asIdeal))
          (CommRingCat.of (Localization.AtPrime p.asIdeal)) _
          (Localization.localRingHom (PrimeSpectrum.comap f p).asIdeal p.asIdeal f rfl)
          (stalkIso S p).inv =
      PresheafedSpace.stalkMap (Spec.sheafedSpaceMap f) p :=
  (stalkIso R (PrimeSpectrum.comap f p)).eq_inv_comp.mp <|
    (stalkIso S p).comp_inv_eq.mpr <|
      Localization.localRingHom_unique _ _ _ _ fun x => by
        rw [stalkIso_hom, stalkIso_inv, comp_apply, comp_apply, localizationToStalk_of,
          stalkMap_toStalk_apply, stalkToFiberRingHom_toStalk]
#align algebraic_geometry.local_ring_hom_comp_stalk_iso AlgebraicGeometry.localRingHom_comp_stalkIso

/--
The induced map of a ring homomorphism on the prime spectra, as a morphism of locally ringed spaces.
-/
@[simps]
def Spec.locallyRingedSpaceMap {R S : CommRingCat} (f : R ⟶ S) :
    Spec.locallyRingedSpaceObj S ⟶ Spec.locallyRingedSpaceObj R :=
  LocallyRingedSpace.Hom.mk (Spec.sheafedSpaceMap f) fun p =>
    IsLocalRingHom.mk fun a ha =>
      by
      -- Here, we are showing that the map on prime spectra induced by `f` is really a morphism of
      -- *locally* ringed spaces, i.e. that the induced map on the stalks is a local ring homomorphism.
      rw [← localRingHom_comp_stalkIso_apply] at ha
      replace ha := (stalkIso S p).hom.isUnit_map ha
      rw [Iso.inv_hom_id_apply] at ha
      replace ha := IsLocalRingHom.map_nonunit _ ha
      convert RingHom.isUnit_map (stalkIso R (PrimeSpectrum.comap f p)).inv ha
      rw [Iso.hom_inv_id_apply]
#align algebraic_geometry.Spec.LocallyRingedSpace_map AlgebraicGeometry.Spec.locallyRingedSpaceMap

@[simp]
theorem Spec.locallyRingedSpaceMap_id (R : CommRingCat) :
    Spec.locallyRingedSpaceMap (𝟙 R) = 𝟙 (Spec.locallyRingedSpaceObj R) :=
  LocallyRingedSpace.Hom.ext _ _ <|
    by
    rw [Spec.locallyRingedSpaceMap_val, Spec.sheafedSpaceMap_id]
    rfl
#align algebraic_geometry.Spec.LocallyRingedSpace_map_id AlgebraicGeometry.Spec.locallyRingedSpaceMap_id

theorem Spec.locallyRingedSpaceMap_comp {R S T : CommRingCat} (f : R ⟶ S) (g : S ⟶ T) :
    Spec.locallyRingedSpaceMap (f ≫ g) =
      Spec.locallyRingedSpaceMap g ≫ Spec.locallyRingedSpaceMap f :=
  LocallyRingedSpace.Hom.ext _ _ <|
    by
    rw [Spec.locallyRingedSpaceMap_val, Spec.sheafedSpaceMap_comp]
    rfl
#align algebraic_geometry.Spec.LocallyRingedSpace_map_comp AlgebraicGeometry.Spec.locallyRingedSpaceMap_comp

/-- Spec, as a contravariant functor from commutative rings to locally ringed spaces.
-/
@[simps]
def Spec.toLocallyRingedSpace : CommRingCatᵒᵖ ⥤ LocallyRingedSpace
    where
  obj R := Spec.locallyRingedSpaceObj (unop R)
  map R S f := Spec.locallyRingedSpaceMap f.unop
  map_id' R := by rw [unop_id, Spec.locallyRingedSpaceMap_id]
  map_comp' R S T f g := by rw [unop_comp, Spec.locallyRingedSpaceMap_comp]
#align algebraic_geometry.Spec.to_LocallyRingedSpace AlgebraicGeometry.Spec.toLocallyRingedSpace

section SpecΓ

open AlgebraicGeometry.LocallyRingedSpace

/-- The counit morphism `R ⟶ Γ(Spec R)` given by `algebraic_geometry.structure_sheaf.to_open`.  -/
@[simps (config := { rhsMd := Tactic.Transparency.semireducible })]
def toSpecΓ (R : CommRingCat) : R ⟶ Γ.obj (op (Spec.toLocallyRingedSpace.obj (op R))) :=
  StructureSheaf.toOpen R ⊤
#align algebraic_geometry.to_Spec_Γ AlgebraicGeometry.toSpecΓ

instance isIso_toSpecΓ (R : CommRingCat) : IsIso (toSpecΓ R) :=
  by
  cases R
  apply StructureSheaf.isIso_to_global
#align algebraic_geometry.is_iso_to_Spec_Γ AlgebraicGeometry.isIso_toSpecΓ

@[reassoc.1]
theorem Spec_Γ_naturality {R S : CommRingCat} (f : R ⟶ S) :
    f ≫ toSpecΓ S = toSpecΓ R ≫ Γ.map (Spec.toLocallyRingedSpace.map f.op).op :=
  by
  ext
  symm
  apply Localization.localRingHom_to_map
#align algebraic_geometry.Spec_Γ_naturality AlgebraicGeometry.Spec_Γ_naturality

/-- The counit (`Spec_Γ_identity.inv.op`) of the adjunction `Γ ⊣ Spec` is an isomorphism. -/
@[simps hom_app inv_app]
def specΓIdentity : Spec.toLocallyRingedSpace.rightOp ⋙ Γ ≅ 𝟭 _ :=
  Iso.symm <| NatIso.ofComponents (fun R => asIso (toSpecΓ R) : _) fun _ _ => Spec_Γ_naturality
#align algebraic_geometry.Spec_Γ_identity AlgebraicGeometry.specΓIdentity

end SpecΓ

/-- The stalk map of `Spec M⁻¹R ⟶ Spec R` is an iso for each `p : Spec M⁻¹R`. -/
theorem Spec_map_localization_isIso (R : CommRingCat) (M : Submonoid R)
    (x : PrimeSpectrum (Localization M)) :
    IsIso
      (PresheafedSpace.stalkMap
        (Spec.toPresheafedSpace.map (CommRingCat.ofHom (algebraMap R (Localization M))).op) x) :=
  by
  erw [← localRingHom_comp_stalkIso]
  apply (config := { instances := false }) IsIso.comp_isIso
  infer_instance
  apply (config := { instances := false }) IsIso.comp_isIso
  -- I do not know why this is defeq to the goal, but I'm happy to accept that it is.
  exact
    show
      IsIso
        (IsLocalization.localizationLocalizationAtPrimeIsoLocalization M
                x.as_ideal).toRingEquiv.toCommRingIso.hom
      by infer_instance
  infer_instance
#align algebraic_geometry.Spec_map_localization_is_iso AlgebraicGeometry.Spec_map_localization_isIso

namespace StructureSheaf

variable {R S : CommRingCat.{u}} (f : R ⟶ S) (p : PrimeSpectrum R)

/-- For an algebra `f : R →+* S`, this is the ring homomorphism `S →+* (f∗ 𝒪ₛ)ₚ` for a `p : Spec R`.
This is shown to be the localization at `p` in `is_localized_module_to_pushforward_stalk_alg_hom`.
-/
def toPushforwardStalk : S ⟶ (Spec.topMap f _* (structureSheaf S).1).stalk p :=
  StructureSheaf.toOpen S ⊤ ≫
    @TopCat.Presheaf.germ _ _ _ _ (Spec.topMap f _* (structureSheaf S).1) ⊤ ⟨p, trivial⟩
#align algebraic_geometry.structure_sheaf.to_pushforward_stalk AlgebraicGeometry.StructureSheaf.toPushforwardStalk

@[reassoc.1]
theorem toPushforwardStalk_comp :
    f ≫ StructureSheaf.toPushforwardStalk f p =
      StructureSheaf.toStalk R p ≫
        (TopCat.Presheaf.stalkFunctor _ _).map (Spec.sheafedSpaceMap f).c :=
  by
  rw [StructureSheaf.toStalk]
  erw [Category.assoc]
  rw [TopCat.Presheaf.stalkFunctor_map_germ]
  exact Spec_Γ_naturality_assoc f _
#align algebraic_geometry.structure_sheaf.to_pushforward_stalk_comp AlgebraicGeometry.StructureSheaf.toPushforwardStalk_comp

instance : Algebra R ((Spec.topMap f _* (structureSheaf S).1).stalk p) :=
  (f ≫ StructureSheaf.toPushforwardStalk f p).toAlgebra

theorem algebraMap_pushforward_stalk :
    algebraMap R ((Spec.topMap f _* (structureSheaf S).1).stalk p) =
      f ≫ StructureSheaf.toPushforwardStalk f p :=
  rfl
#align algebraic_geometry.structure_sheaf.algebra_map_pushforward_stalk AlgebraicGeometry.StructureSheaf.algebraMap_pushforward_stalk

variable (R S) [Algebra R S]

/--
This is the `alg_hom` version of `to_pushforward_stalk`, which is the map `S ⟶ (f∗ 𝒪ₛ)ₚ` for some
algebra `R ⟶ S` and some `p : Spec R`.
-/
@[simps]
def toPushforwardStalkAlgHom :
    S →ₐ[R] (Spec.topMap (algebraMap R S) _* (structureSheaf S).1).stalk p :=
  { StructureSheaf.toPushforwardStalk (algebraMap R S) p with commutes' := fun _ => rfl }
#align algebraic_geometry.structure_sheaf.to_pushforward_stalk_alg_hom AlgebraicGeometry.StructureSheaf.toPushforwardStalkAlgHom

theorem is_localized_module_toPushforwardStalkAlgHom_aux (y) :
    ∃ x : S × p.asIdeal.primeCompl, x.2 • y = toPushforwardStalkAlgHom R S p x.1 :=
  by
  obtain ⟨U, hp, s, e⟩ := TopCat.Presheaf.germ_exist _ _ y
  obtain ⟨_, ⟨r, rfl⟩, hpr, hrU⟩ :=
    PrimeSpectrum.isTopologicalBasis_basic_opens.exists_subset_of_mem_open (show p ∈ U.1 from hp)
      U.2
  change PrimeSpectrum.basicOpen r ≤ U at hrU
  replace e :=
    ((Spec.topMap (algebraMap R S) _* (structureSheaf S).1).germ_res_apply (homOfLe hrU) ⟨p, hpr⟩
          _).trans
      e
  set s' := (Spec.topMap (algebraMap R S) _* (structureSheaf S).1).map (homOfLe hrU).op s with h
  rw [← h] at e
  clear_value s'; clear! U
  obtain ⟨⟨s, ⟨_, n, rfl⟩⟩, hsn⟩ :=
    @is_localization.surj _ _ _ _ _ _
      (StructureSheaf.IsLocalization.to_basicOpen S <| algebraMap R S r) s'
  refine' ⟨⟨s, ⟨r, hpr⟩ ^ n⟩, _⟩
  rw [Submonoid.smul_def, Algebra.smul_def, algebraMap_pushforward_stalk, toPushforwardStalk,
    comp_apply, comp_apply]
  iterate 2
    erw [←
      (Spec.topMap (algebraMap R S) _* (structureSheaf S).1).germ_res_apply (homOfLe le_top)
        ⟨p, hpr⟩]
  rw [← e, ← map_mul, mul_comm]
  dsimp only [Subtype.coe_mk] at hsn
  rw [← map_pow (algebraMap R S)] at hsn
  congr 1
#align algebraic_geometry.structure_sheaf.is_localized_module_to_pushforward_stalk_alg_hom_aux AlgebraicGeometry.StructureSheaf.is_localized_module_toPushforwardStalkAlgHom_aux

instance isLocalizedModuleToPushforwardStalkAlgHom :
    IsLocalizedModule p.asIdeal.primeCompl (toPushforwardStalkAlgHom R S p).toLinearMap :=
  by
  apply IsLocalizedModule.mkOfAlgebra
  · intro x hx
    rw [algebraMap_pushforward_stalk, toPushforwardStalk_comp, comp_apply]
    exact (IsLocalization.map_units ((structureSheaf R).presheaf.stalk p) ⟨x, hx⟩).map _
  · apply is_localized_module_toPushforwardStalkAlgHom_aux
  · intro x hx
    rw [toPushforwardStalkAlgHom_apply, RingHom.toFun_eq_coe, ←
      (toPushforwardStalk (algebraMap R S) p).map_zero, toPushforwardStalk, comp_apply, comp_apply,
      map_zero] at hx
    obtain ⟨U, hpU, i₁, i₂, e⟩ := TopCat.Presheaf.germ_eq _ _ _ _ _ _ hx
    obtain ⟨_, ⟨r, rfl⟩, hpr, hrU⟩ :=
      PrimeSpectrum.isTopologicalBasis_basic_opens.exists_subset_of_mem_open (show p ∈ U.1 from hpU)
        U.2
    change PrimeSpectrum.basicOpen r ≤ U at hrU
    apply_fun (Spec.topMap (algebraMap R S) _* (structureSheaf S).1).map (homOfLe hrU).op  at e
    simp only [TopCat.Presheaf.pushforwardObj_map, Functor.op_map, map_zero, ← comp_apply,
      toOpen_res] at e
    have : toOpen S (PrimeSpectrum.basicOpen <| algebraMap R S r) x = 0 :=
      by
      refine' Eq.trans _ e
      rfl
    have :=
      (@is_localization.mk'_one _ _ _ _ _ _
            (StructureSheaf.IsLocalization.to_basicOpen S <| algebraMap R S r) x).trans
        this
    obtain ⟨⟨_, n, rfl⟩, e⟩ := (IsLocalization.mk'_eq_zero_iff _ _).mp this
    refine' ⟨⟨r, hpr⟩ ^ n, _⟩
    rw [Submonoid.smul_def, Algebra.smul_def, [anonymous], Subtype.coe_mk, map_pow]
    exact e
#align algebraic_geometry.structure_sheaf.is_localized_module_to_pushforward_stalk_alg_hom AlgebraicGeometry.StructureSheaf.isLocalizedModuleToPushforwardStalkAlgHom

end StructureSheaf

end AlgebraicGeometry

