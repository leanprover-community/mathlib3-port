/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison, Jakob von Raumer

! This file was ported from Lean 3 source module category_theory.limits.shapes.biproducts
! leanprover-community/mathlib commit 26f081a2fb920140ed5bc5cc5344e84bcc7cb2b2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.Shapes.FiniteProducts
import Mathbin.CategoryTheory.Limits.Shapes.BinaryProducts
import Mathbin.CategoryTheory.Limits.Shapes.Kernels

/-!
# Biproducts and binary biproducts

We introduce the notion of (finite) biproducts and binary biproducts.

These are slightly unusual relative to the other shapes in the library,
as they are simultaneously limits and colimits.
(Zero objects are similar; they are "biterminal".)

For results about biproducts in preadditive categories see
`category_theory.preadditive.biproducts`.

In a category with zero morphisms, we model the (binary) biproduct of `P Q : C`
using a `binary_bicone`, which has a cone point `X`,
and morphisms `fst : X ⟶ P`, `snd : X ⟶ Q`, `inl : P ⟶ X` and `inr : X ⟶ Q`,
such that `inl ≫ fst = 𝟙 P`, `inl ≫ snd = 0`, `inr ≫ fst = 0`, and `inr ≫ snd = 𝟙 Q`.
Such a `binary_bicone` is a biproduct if the cone is a limit cone, and the cocone is a colimit
cocone.

For biproducts indexed by a `fintype J`, a `bicone` again consists of a cone point `X`
and morphisms `π j : X ⟶ F j` and `ι j : F j ⟶ X` for each `j`,
such that `ι j ≫ π j'` is the identity when `j = j'` and zero otherwise.

## Notation
As `⊕` is already taken for the sum of types, we introduce the notation `X ⊞ Y` for
a binary biproduct. We introduce `⨁ f` for the indexed biproduct.

## Implementation
Prior to #14046, `has_finite_biproducts` required a `decidable_eq` instance on the indexing type.
As this had no pay-off (everything about limits is non-constructive in mathlib), and occasional cost
(constructing decidability instances appropriate for constructions involving the indexing type),
we made everything classical.
-/


noncomputable section

universe w w' v u

open CategoryTheory

open CategoryTheory.Functor

open Classical

namespace CategoryTheory

namespace Limits

variable {J : Type w}

variable {C : Type u} [Category.{v} C] [HasZeroMorphisms C]

/-- A `c : bicone F` is:
* an object `c.X` and
* morphisms `π j : X ⟶ F j` and `ι j : F j ⟶ X` for each `j`,
* such that `ι j ≫ π j'` is the identity when `j = j'` and zero otherwise.
-/
@[nolint has_nonempty_instance]
structure Bicone (F : J → C) where
  x : C
  π : ∀ j, X ⟶ F j
  ι : ∀ j, F j ⟶ X
  ι_π : ∀ j j', ι j ≫ π j' = if h : j = j' then eqToHom (congr_arg F h) else 0 := by obviously
#align category_theory.limits.bicone CategoryTheory.Limits.Bicone

@[simp, reassoc.1]
theorem bicone_ι_π_self {F : J → C} (B : Bicone F) (j : J) : B.ι j ≫ B.π j = 𝟙 (F j) := by
  simpa using B.ι_π j j
#align category_theory.limits.bicone_ι_π_self CategoryTheory.Limits.bicone_ι_π_self

@[simp, reassoc.1]
theorem bicone_ι_π_ne {F : J → C} (B : Bicone F) {j j' : J} (h : j ≠ j') : B.ι j ≫ B.π j' = 0 := by
  simpa [h] using B.ι_π j j'
#align category_theory.limits.bicone_ι_π_ne CategoryTheory.Limits.bicone_ι_π_ne

variable {F : J → C}

namespace Bicone

attribute [local tidy] tactic.discrete_cases

/-- Extract the cone from a bicone. -/
def toCone (B : Bicone F) : Cone (Discrete.functor F)
    where
  x := B.x
  π := { app := fun j => B.π j.as }
#align category_theory.limits.bicone.to_cone CategoryTheory.Limits.Bicone.toCone

@[simp]
theorem to_cone_X (B : Bicone F) : B.toCone.x = B.x :=
  rfl
#align category_theory.limits.bicone.to_cone_X CategoryTheory.Limits.Bicone.to_cone_X

@[simp]
theorem to_cone_π_app (B : Bicone F) (j : Discrete J) : B.toCone.π.app j = B.π j.as :=
  rfl
#align category_theory.limits.bicone.to_cone_π_app CategoryTheory.Limits.Bicone.to_cone_π_app

theorem to_cone_π_app_mk (B : Bicone F) (j : J) : B.toCone.π.app ⟨j⟩ = B.π j :=
  rfl
#align category_theory.limits.bicone.to_cone_π_app_mk CategoryTheory.Limits.Bicone.to_cone_π_app_mk

/-- Extract the cocone from a bicone. -/
def toCocone (B : Bicone F) : Cocone (Discrete.functor F)
    where
  x := B.x
  ι := { app := fun j => B.ι j.as }
#align category_theory.limits.bicone.to_cocone CategoryTheory.Limits.Bicone.toCocone

@[simp]
theorem to_cocone_X (B : Bicone F) : B.toCocone.x = B.x :=
  rfl
#align category_theory.limits.bicone.to_cocone_X CategoryTheory.Limits.Bicone.to_cocone_X

@[simp]
theorem to_cocone_ι_app (B : Bicone F) (j : Discrete J) : B.toCocone.ι.app j = B.ι j.as :=
  rfl
#align category_theory.limits.bicone.to_cocone_ι_app CategoryTheory.Limits.Bicone.to_cocone_ι_app

theorem to_cocone_ι_app_mk (B : Bicone F) (j : J) : B.toCocone.ι.app ⟨j⟩ = B.ι j :=
  rfl
#align
  category_theory.limits.bicone.to_cocone_ι_app_mk CategoryTheory.Limits.Bicone.to_cocone_ι_app_mk

/-- We can turn any limit cone over a discrete collection of objects into a bicone. -/
@[simps]
def ofLimitCone {f : J → C} {t : Cone (Discrete.functor f)} (ht : IsLimit t) : Bicone f
    where
  x := t.x
  π j := t.π.app ⟨j⟩
  ι j := ht.lift (Fan.mk _ fun j' => if h : j = j' then eqToHom (congr_arg f h) else 0)
  ι_π j j' := by simp
#align category_theory.limits.bicone.of_limit_cone CategoryTheory.Limits.Bicone.ofLimitCone

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:76:14: unsupported tactic `discrete_cases #[] -/
theorem ι_of_is_limit {f : J → C} {t : Bicone f} (ht : IsLimit t.toCone) (j : J) :
    t.ι j = ht.lift (Fan.mk _ fun j' => if h : j = j' then eqToHom (congr_arg f h) else 0) :=
  ht.hom_ext fun j' => by
    rw [ht.fac]
    trace
      "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:76:14: unsupported tactic `discrete_cases #[]"
    simp [t.ι_π]
#align category_theory.limits.bicone.ι_of_is_limit CategoryTheory.Limits.Bicone.ι_of_is_limit

/-- We can turn any colimit cocone over a discrete collection of objects into a bicone. -/
@[simps]
def ofColimitCocone {f : J → C} {t : Cocone (Discrete.functor f)} (ht : IsColimit t) : Bicone f
    where
  x := t.x
  π j := ht.desc (Cofan.mk _ fun j' => if h : j' = j then eqToHom (congr_arg f h) else 0)
  ι j := t.ι.app ⟨j⟩
  ι_π j j' := by simp
#align category_theory.limits.bicone.of_colimit_cocone CategoryTheory.Limits.Bicone.ofColimitCocone

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:76:14: unsupported tactic `discrete_cases #[] -/
theorem π_of_is_colimit {f : J → C} {t : Bicone f} (ht : IsColimit t.toCocone) (j : J) :
    t.π j = ht.desc (Cofan.mk _ fun j' => if h : j' = j then eqToHom (congr_arg f h) else 0) :=
  ht.hom_ext fun j' => by
    rw [ht.fac]
    trace
      "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:76:14: unsupported tactic `discrete_cases #[]"
    simp [t.ι_π]
#align category_theory.limits.bicone.π_of_is_colimit CategoryTheory.Limits.Bicone.π_of_is_colimit

/-- Structure witnessing that a bicone is both a limit cone and a colimit cocone. -/
@[nolint has_nonempty_instance]
structure IsBilimit {F : J → C} (B : Bicone F) where
  IsLimit : IsLimit B.toCone
  IsColimit : IsColimit B.toCocone
#align category_theory.limits.bicone.is_bilimit CategoryTheory.Limits.Bicone.IsBilimit

attribute [local ext] bicone.is_bilimit

instance subsingleton_is_bilimit {f : J → C} {c : Bicone f} : Subsingleton c.IsBilimit :=
  ⟨fun h h' => Bicone.IsBilimit.ext _ _ (Subsingleton.elim _ _) (Subsingleton.elim _ _)⟩
#align
  category_theory.limits.bicone.subsingleton_is_bilimit CategoryTheory.Limits.Bicone.subsingleton_is_bilimit

section Whisker

variable {K : Type w'}

/-- Whisker a bicone with an equivalence between the indexing types. -/
@[simps]
def whisker {f : J → C} (c : Bicone f) (g : K ≃ J) : Bicone (f ∘ g)
    where
  x := c.x
  π k := c.π (g k)
  ι k := c.ι (g k)
  ι_π k k' := by
    simp only [c.ι_π]
    split_ifs with h h' h' <;> simp [Equiv.apply_eq_iff_eq g] at h h' <;> tauto
#align category_theory.limits.bicone.whisker CategoryTheory.Limits.Bicone.whisker

attribute [local tidy] tactic.discrete_cases

/-- Taking the cone of a whiskered bicone results in a cone isomorphic to one gained
by whiskering the cone and postcomposing with a suitable isomorphism. -/
def whiskerToCone {f : J → C} (c : Bicone f) (g : K ≃ J) :
    (c.whisker g).toCone ≅
      (Cones.postcompose (Discrete.functorComp f g).inv).obj
        (c.toCone.whisker (Discrete.functor (discrete.mk ∘ g))) :=
  Cones.ext (Iso.refl _) (by tidy)
#align category_theory.limits.bicone.whisker_to_cone CategoryTheory.Limits.Bicone.whiskerToCone

/-- Taking the cocone of a whiskered bicone results in a cone isomorphic to one gained
by whiskering the cocone and precomposing with a suitable isomorphism. -/
def whiskerToCocone {f : J → C} (c : Bicone f) (g : K ≃ J) :
    (c.whisker g).toCocone ≅
      (Cocones.precompose (Discrete.functorComp f g).hom).obj
        (c.toCocone.whisker (Discrete.functor (discrete.mk ∘ g))) :=
  Cocones.ext (Iso.refl _) (by tidy)
#align category_theory.limits.bicone.whisker_to_cocone CategoryTheory.Limits.Bicone.whiskerToCocone

/-- Whiskering a bicone with an equivalence between types preserves being a bilimit bicone. -/
def whiskerIsBilimitIff {f : J → C} (c : Bicone f) (g : K ≃ J) :
    (c.whisker g).IsBilimit ≃ c.IsBilimit :=
  by
  refine' equivOfSubsingletonOfSubsingleton (fun hc => ⟨_, _⟩) fun hc => ⟨_, _⟩
  · let this := is_limit.of_iso_limit hc.is_limit (bicone.whisker_to_cone c g)
    let this := (is_limit.postcompose_hom_equiv (discrete.functor_comp f g).symm _) this
    exact is_limit.of_whisker_equivalence (discrete.equivalence g) this
  · let this := is_colimit.of_iso_colimit hc.is_colimit (bicone.whisker_to_cocone c g)
    let this := (is_colimit.precompose_hom_equiv (discrete.functor_comp f g) _) this
    exact is_colimit.of_whisker_equivalence (discrete.equivalence g) this
  · apply is_limit.of_iso_limit _ (bicone.whisker_to_cone c g).symm
    apply (is_limit.postcompose_hom_equiv (discrete.functor_comp f g).symm _).symm _
    exact is_limit.whisker_equivalence hc.is_limit (discrete.equivalence g)
  · apply is_colimit.of_iso_colimit _ (bicone.whisker_to_cocone c g).symm
    apply (is_colimit.precompose_hom_equiv (discrete.functor_comp f g) _).symm _
    exact is_colimit.whisker_equivalence hc.is_colimit (discrete.equivalence g)
#align
  category_theory.limits.bicone.whisker_is_bilimit_iff CategoryTheory.Limits.Bicone.whiskerIsBilimitIff

end Whisker

end Bicone

/-- A bicone over `F : J → C`, which is both a limit cone and a colimit cocone.
-/
@[nolint has_nonempty_instance]
structure LimitBicone (F : J → C) where
  Bicone : Bicone F
  IsBilimit : bicone.IsBilimit
#align category_theory.limits.limit_bicone CategoryTheory.Limits.LimitBicone

/-- `has_biproduct F` expresses the mere existence of a bicone which is
simultaneously a limit and a colimit of the diagram `F`.
-/
class HasBiproduct (F : J → C) : Prop where mk' ::
  exists_biproduct : Nonempty (LimitBicone F)
#align category_theory.limits.has_biproduct CategoryTheory.Limits.HasBiproduct

theorem HasBiproduct.mk {F : J → C} (d : LimitBicone F) : HasBiproduct F :=
  ⟨Nonempty.intro d⟩
#align category_theory.limits.has_biproduct.mk CategoryTheory.Limits.HasBiproduct.mk

/-- Use the axiom of choice to extract explicit `biproduct_data F` from `has_biproduct F`. -/
def getBiproductData (F : J → C) [HasBiproduct F] : LimitBicone F :=
  Classical.choice HasBiproduct.exists_biproduct
#align category_theory.limits.get_biproduct_data CategoryTheory.Limits.getBiproductData

/-- A bicone for `F` which is both a limit cone and a colimit cocone. -/
def Biproduct.bicone (F : J → C) [HasBiproduct F] : Bicone F :=
  (getBiproductData F).Bicone
#align category_theory.limits.biproduct.bicone CategoryTheory.Limits.Biproduct.bicone

/-- `biproduct.bicone F` is a bilimit bicone. -/
def Biproduct.isBilimit (F : J → C) [HasBiproduct F] : (Biproduct.bicone F).IsBilimit :=
  (getBiproductData F).IsBilimit
#align category_theory.limits.biproduct.is_bilimit CategoryTheory.Limits.Biproduct.isBilimit

/-- `biproduct.bicone F` is a limit cone. -/
def Biproduct.isLimit (F : J → C) [HasBiproduct F] : IsLimit (Biproduct.bicone F).toCone :=
  (getBiproductData F).IsBilimit.IsLimit
#align category_theory.limits.biproduct.is_limit CategoryTheory.Limits.Biproduct.isLimit

/-- `biproduct.bicone F` is a colimit cocone. -/
def Biproduct.isColimit (F : J → C) [HasBiproduct F] : IsColimit (Biproduct.bicone F).toCocone :=
  (getBiproductData F).IsBilimit.IsColimit
#align category_theory.limits.biproduct.is_colimit CategoryTheory.Limits.Biproduct.isColimit

instance (priority := 100) has_product_of_has_biproduct [HasBiproduct F] : HasProduct F :=
  HasLimit.mk
    { Cone := (Biproduct.bicone F).toCone
      IsLimit := Biproduct.isLimit F }
#align
  category_theory.limits.has_product_of_has_biproduct CategoryTheory.Limits.has_product_of_has_biproduct

instance (priority := 100) has_coproduct_of_has_biproduct [HasBiproduct F] : HasCoproduct F :=
  HasColimit.mk
    { Cocone := (Biproduct.bicone F).toCocone
      IsColimit := Biproduct.isColimit F }
#align
  category_theory.limits.has_coproduct_of_has_biproduct CategoryTheory.Limits.has_coproduct_of_has_biproduct

variable (J C)

/-- `C` has biproducts of shape `J` if we have
a limit and a colimit, with the same cone points,
of every function `F : J → C`.
-/
class HasBiproductsOfShape : Prop where
  HasBiproduct : ∀ F : J → C, HasBiproduct F
#align category_theory.limits.has_biproducts_of_shape CategoryTheory.Limits.HasBiproductsOfShape

attribute [instance] has_biproducts_of_shape.has_biproduct

/- ./././Mathport/Syntax/Translate/Command.lean:379:30: infer kinds are unsupported in Lean 4: #[`out] [] -/
/-- `has_finite_biproducts C` represents a choice of biproduct for every family of objects in `C`
indexed by a finite type. -/
class HasFiniteBiproducts : Prop where
  out : ∀ n, HasBiproductsOfShape (Fin n) C
#align category_theory.limits.has_finite_biproducts CategoryTheory.Limits.HasFiniteBiproducts

variable {J}

theorem hasBiproductsOfShapeOfEquiv {K : Type w'} [HasBiproductsOfShape K C] (e : J ≃ K) :
    HasBiproductsOfShape J C :=
  ⟨fun F =>
    let ⟨⟨h⟩⟩ := HasBiproductsOfShape.hasBiproduct (F ∘ e.symm)
    let ⟨c, hc⟩ := h
    has_biproduct.mk <| by
      simpa only [(· ∘ ·), e.symm_apply_apply] using
        limit_bicone.mk (c.whisker e) ((c.whisker_is_bilimit_iff _).2 hc)⟩
#align
  category_theory.limits.has_biproducts_of_shape_of_equiv CategoryTheory.Limits.hasBiproductsOfShapeOfEquiv

instance (priority := 100) hasBiproductsOfShapeFinite [HasFiniteBiproducts C] [Finite J] :
    HasBiproductsOfShape J C :=
  by
  rcases Finite.exists_equiv_fin J with ⟨n, ⟨e⟩⟩
  haveI := has_finite_biproducts.out C n
  exact has_biproducts_of_shape_of_equiv C e
#align
  category_theory.limits.has_biproducts_of_shape_finite CategoryTheory.Limits.hasBiproductsOfShapeFinite

instance (priority := 100) hasFiniteProductsOfHasFiniteBiproducts [HasFiniteBiproducts C] :
    HasFiniteProducts C where out n := ⟨fun F => hasLimitOfIso Discrete.natIsoFunctor.symm⟩
#align
  category_theory.limits.has_finite_products_of_has_finite_biproducts CategoryTheory.Limits.hasFiniteProductsOfHasFiniteBiproducts

instance (priority := 100) hasFiniteCoproductsOfHasFiniteBiproducts [HasFiniteBiproducts C] :
    HasFiniteCoproducts C where out n := ⟨fun F => hasColimitOfIso Discrete.natIsoFunctor⟩
#align
  category_theory.limits.has_finite_coproducts_of_has_finite_biproducts CategoryTheory.Limits.hasFiniteCoproductsOfHasFiniteBiproducts

variable {J C}

/-- The isomorphism between the specified limit and the specified colimit for
a functor with a bilimit.
-/
def biproductIso (F : J → C) [HasBiproduct F] : Limits.piObj F ≅ Limits.sigmaObj F :=
  (IsLimit.conePointUniqueUpToIso (limit.isLimit _) (Biproduct.isLimit F)).trans <|
    IsColimit.coconePointUniqueUpToIso (Biproduct.isColimit F) (colimit.isColimit _)
#align category_theory.limits.biproduct_iso CategoryTheory.Limits.biproductIso

end Limits

namespace Limits

variable {J : Type w}

variable {C : Type u} [Category.{v} C] [HasZeroMorphisms C]

/-- `biproduct f` computes the biproduct of a family of elements `f`. (It is defined as an
   abbreviation for `limit (discrete.functor f)`, so for most facts about `biproduct f`, you will
   just use general facts about limits and colimits.) -/
abbrev biproduct (f : J → C) [HasBiproduct f] : C :=
  (Biproduct.bicone f).x
#align category_theory.limits.biproduct CategoryTheory.Limits.biproduct

-- mathport name: «expr⨁ »
notation "⨁ " f:20 => biproduct f

/-- The projection onto a summand of a biproduct. -/
abbrev biproduct.π (f : J → C) [HasBiproduct f] (b : J) : ⨁ f ⟶ f b :=
  (Biproduct.bicone f).π b
#align category_theory.limits.biproduct.π CategoryTheory.Limits.biproduct.π

@[simp]
theorem biproduct.bicone_π (f : J → C) [HasBiproduct f] (b : J) :
    (Biproduct.bicone f).π b = biproduct.π f b :=
  rfl
#align category_theory.limits.biproduct.bicone_π CategoryTheory.Limits.biproduct.bicone_π

/-- The inclusion into a summand of a biproduct. -/
abbrev biproduct.ι (f : J → C) [HasBiproduct f] (b : J) : f b ⟶ ⨁ f :=
  (Biproduct.bicone f).ι b
#align category_theory.limits.biproduct.ι CategoryTheory.Limits.biproduct.ι

@[simp]
theorem biproduct.bicone_ι (f : J → C) [HasBiproduct f] (b : J) :
    (Biproduct.bicone f).ι b = biproduct.ι f b :=
  rfl
#align category_theory.limits.biproduct.bicone_ι CategoryTheory.Limits.biproduct.bicone_ι

/-- Note that as this lemma has a `if` in the statement, we include a `decidable_eq` argument.
This means you may not be able to `simp` using this lemma unless you `open_locale classical`. -/
@[reassoc.1]
theorem biproduct.ι_π [DecidableEq J] (f : J → C) [HasBiproduct f] (j j' : J) :
    biproduct.ι f j ≫ biproduct.π f j' = if h : j = j' then eqToHom (congr_arg f h) else 0 := by
  convert (biproduct.bicone f).ι_π j j'
#align category_theory.limits.biproduct.ι_π CategoryTheory.Limits.biproduct.ι_π

@[simp, reassoc.1]
theorem biproduct.ι_π_self (f : J → C) [HasBiproduct f] (j : J) :
    biproduct.ι f j ≫ biproduct.π f j = 𝟙 _ := by simp [biproduct.ι_π]
#align category_theory.limits.biproduct.ι_π_self CategoryTheory.Limits.biproduct.ι_π_self

@[simp, reassoc.1]
theorem biproduct.ι_π_ne (f : J → C) [HasBiproduct f] {j j' : J} (h : j ≠ j') :
    biproduct.ι f j ≫ biproduct.π f j' = 0 := by simp [biproduct.ι_π, h]
#align category_theory.limits.biproduct.ι_π_ne CategoryTheory.Limits.biproduct.ι_π_ne

/-- Given a collection of maps into the summands, we obtain a map into the biproduct. -/
abbrev biproduct.lift {f : J → C} [HasBiproduct f] {P : C} (p : ∀ b, P ⟶ f b) : P ⟶ ⨁ f :=
  (Biproduct.isLimit f).lift (Fan.mk P p)
#align category_theory.limits.biproduct.lift CategoryTheory.Limits.biproduct.lift

/-- Given a collection of maps out of the summands, we obtain a map out of the biproduct. -/
abbrev biproduct.desc {f : J → C} [HasBiproduct f] {P : C} (p : ∀ b, f b ⟶ P) : ⨁ f ⟶ P :=
  (Biproduct.isColimit f).desc (Cofan.mk P p)
#align category_theory.limits.biproduct.desc CategoryTheory.Limits.biproduct.desc

@[simp, reassoc.1]
theorem biproduct.lift_π {f : J → C} [HasBiproduct f] {P : C} (p : ∀ b, P ⟶ f b) (j : J) :
    biproduct.lift p ≫ biproduct.π f j = p j :=
  (Biproduct.isLimit f).fac _ ⟨j⟩
#align category_theory.limits.biproduct.lift_π CategoryTheory.Limits.biproduct.lift_π

@[simp, reassoc.1]
theorem biproduct.ι_desc {f : J → C} [HasBiproduct f] {P : C} (p : ∀ b, f b ⟶ P) (j : J) :
    biproduct.ι f j ≫ biproduct.desc p = p j :=
  (Biproduct.isColimit f).fac _ ⟨j⟩
#align category_theory.limits.biproduct.ι_desc CategoryTheory.Limits.biproduct.ι_desc

/-- Given a collection of maps between corresponding summands of a pair of biproducts
indexed by the same type, we obtain a map between the biproducts. -/
abbrev biproduct.map {f g : J → C} [HasBiproduct f] [HasBiproduct g] (p : ∀ b, f b ⟶ g b) :
    ⨁ f ⟶ ⨁ g :=
  IsLimit.map (Biproduct.bicone f).toCone (Biproduct.isLimit g) (Discrete.natTrans fun j => p j.as)
#align category_theory.limits.biproduct.map CategoryTheory.Limits.biproduct.map

/-- An alternative to `biproduct.map` constructed via colimits.
This construction only exists in order to show it is equal to `biproduct.map`. -/
abbrev biproduct.map' {f g : J → C} [HasBiproduct f] [HasBiproduct g] (p : ∀ b, f b ⟶ g b) :
    ⨁ f ⟶ ⨁ g :=
  IsColimit.map (Biproduct.isColimit f) (Biproduct.bicone g).toCocone
    (Discrete.natTrans fun j => p j.as)
#align category_theory.limits.biproduct.map' CategoryTheory.Limits.biproduct.map'

@[ext]
theorem biproduct.hom_ext {f : J → C} [HasBiproduct f] {Z : C} (g h : Z ⟶ ⨁ f)
    (w : ∀ j, g ≫ biproduct.π f j = h ≫ biproduct.π f j) : g = h :=
  (Biproduct.isLimit f).hom_ext fun j => w j.as
#align category_theory.limits.biproduct.hom_ext CategoryTheory.Limits.biproduct.hom_ext

@[ext]
theorem biproduct.hom_ext' {f : J → C} [HasBiproduct f] {Z : C} (g h : ⨁ f ⟶ Z)
    (w : ∀ j, biproduct.ι f j ≫ g = biproduct.ι f j ≫ h) : g = h :=
  (Biproduct.isColimit f).hom_ext fun j => w j.as
#align category_theory.limits.biproduct.hom_ext' CategoryTheory.Limits.biproduct.hom_ext'

/-- The canonical isomorphism between the chosen biproduct and the chosen product. -/
def biproduct.isoProduct (f : J → C) [HasBiproduct f] : ⨁ f ≅ ∏ f :=
  IsLimit.conePointUniqueUpToIso (Biproduct.isLimit f) (limit.isLimit _)
#align category_theory.limits.biproduct.iso_product CategoryTheory.Limits.biproduct.isoProduct

@[simp]
theorem biproduct.iso_product_hom {f : J → C} [HasBiproduct f] :
    (biproduct.isoProduct f).hom = Pi.lift (biproduct.π f) :=
  limit.hom_ext fun j => by simp [biproduct.iso_product]
#align
  category_theory.limits.biproduct.iso_product_hom CategoryTheory.Limits.biproduct.iso_product_hom

@[simp]
theorem biproduct.iso_product_inv {f : J → C} [HasBiproduct f] :
    (biproduct.isoProduct f).inv = biproduct.lift (Pi.π f) :=
  (biproduct.hom_ext _ _) fun j => by simp [iso.inv_comp_eq]
#align
  category_theory.limits.biproduct.iso_product_inv CategoryTheory.Limits.biproduct.iso_product_inv

/-- The canonical isomorphism between the chosen biproduct and the chosen coproduct. -/
def biproduct.isoCoproduct (f : J → C) [HasBiproduct f] : ⨁ f ≅ ∐ f :=
  IsColimit.coconePointUniqueUpToIso (Biproduct.isColimit f) (colimit.isColimit _)
#align category_theory.limits.biproduct.iso_coproduct CategoryTheory.Limits.biproduct.isoCoproduct

@[simp]
theorem biproduct.iso_coproduct_inv {f : J → C} [HasBiproduct f] :
    (biproduct.isoCoproduct f).inv = Sigma.desc (biproduct.ι f) :=
  colimit.hom_ext fun j => by simp [biproduct.iso_coproduct]
#align
  category_theory.limits.biproduct.iso_coproduct_inv CategoryTheory.Limits.biproduct.iso_coproduct_inv

@[simp]
theorem biproduct.iso_coproduct_hom {f : J → C} [HasBiproduct f] :
    (biproduct.isoCoproduct f).hom = biproduct.desc (Sigma.ι f) :=
  (biproduct.hom_ext' _ _) fun j => by simp [← iso.eq_comp_inv]
#align
  category_theory.limits.biproduct.iso_coproduct_hom CategoryTheory.Limits.biproduct.iso_coproduct_hom

theorem biproduct.map_eq_map' {f g : J → C} [HasBiproduct f] [HasBiproduct g] (p : ∀ b, f b ⟶ g b) :
    biproduct.map p = biproduct.map' p := by
  ext (j j')
  simp only [discrete.nat_trans_app, limits.is_colimit.ι_map, limits.is_limit.map_π, category.assoc,
    ← bicone.to_cone_π_app_mk, ← biproduct.bicone_π, ← bicone.to_cocone_ι_app_mk, ←
    biproduct.bicone_ι]
  simp only [biproduct.bicone_ι, biproduct.bicone_π, bicone.to_cocone_ι_app, bicone.to_cone_π_app]
  dsimp
  rw [biproduct.ι_π_assoc, biproduct.ι_π]
  split_ifs
  · subst h
    rw [eq_to_hom_refl, category.id_comp]
    erw [category.comp_id]
  · simp
#align category_theory.limits.biproduct.map_eq_map' CategoryTheory.Limits.biproduct.map_eq_map'

@[simp, reassoc.1]
theorem biproduct.map_π {f g : J → C} [HasBiproduct f] [HasBiproduct g] (p : ∀ j, f j ⟶ g j)
    (j : J) : biproduct.map p ≫ biproduct.π g j = biproduct.π f j ≫ p j :=
  Limits.IsLimit.map_π _ _ _ (Discrete.mk j)
#align category_theory.limits.biproduct.map_π CategoryTheory.Limits.biproduct.map_π

@[simp, reassoc.1]
theorem biproduct.ι_map {f g : J → C} [HasBiproduct f] [HasBiproduct g] (p : ∀ j, f j ⟶ g j)
    (j : J) : biproduct.ι f j ≫ biproduct.map p = p j ≫ biproduct.ι g j :=
  by
  rw [biproduct.map_eq_map']
  convert limits.is_colimit.ι_map _ _ _ (discrete.mk j) <;> rfl
#align category_theory.limits.biproduct.ι_map CategoryTheory.Limits.biproduct.ι_map

@[simp, reassoc.1]
theorem biproduct.map_desc {f g : J → C} [HasBiproduct f] [HasBiproduct g] (p : ∀ j, f j ⟶ g j)
    {P : C} (k : ∀ j, g j ⟶ P) :
    biproduct.map p ≫ biproduct.desc k = biproduct.desc fun j => p j ≫ k j :=
  by
  ext
  simp
#align category_theory.limits.biproduct.map_desc CategoryTheory.Limits.biproduct.map_desc

@[simp, reassoc.1]
theorem biproduct.lift_map {f g : J → C} [HasBiproduct f] [HasBiproduct g] {P : C}
    (k : ∀ j, P ⟶ f j) (p : ∀ j, f j ⟶ g j) :
    biproduct.lift k ≫ biproduct.map p = biproduct.lift fun j => k j ≫ p j :=
  by
  ext
  simp
#align category_theory.limits.biproduct.lift_map CategoryTheory.Limits.biproduct.lift_map

/-- Given a collection of isomorphisms between corresponding summands of a pair of biproducts
indexed by the same type, we obtain an isomorphism between the biproducts. -/
@[simps]
def biproduct.mapIso {f g : J → C} [HasBiproduct f] [HasBiproduct g] (p : ∀ b, f b ≅ g b) :
    ⨁ f ≅ ⨁ g where
  hom := biproduct.map fun b => (p b).hom
  inv := biproduct.map fun b => (p b).inv
#align category_theory.limits.biproduct.map_iso CategoryTheory.Limits.biproduct.mapIso

section πKernel

section

variable (f : J → C) [HasBiproduct f]

variable (p : J → Prop) [HasBiproduct (Subtype.restrict p f)]

/-- The canonical morphism from the biproduct over a restricted index type to the biproduct of
the full index type. -/
def biproduct.fromSubtype : ⨁ Subtype.restrict p f ⟶ ⨁ f :=
  biproduct.desc fun j => biproduct.ι _ _
#align category_theory.limits.biproduct.from_subtype CategoryTheory.Limits.biproduct.fromSubtype

/-- The canonical morphism from a biproduct to the biproduct over a restriction of its index
type. -/
def biproduct.toSubtype : ⨁ f ⟶ ⨁ Subtype.restrict p f :=
  biproduct.lift fun j => biproduct.π _ _
#align category_theory.limits.biproduct.to_subtype CategoryTheory.Limits.biproduct.toSubtype

@[simp, reassoc.1]
theorem biproduct.from_subtype_π [DecidablePred p] (j : J) :
    biproduct.fromSubtype f p ≫ biproduct.π f j =
      if h : p j then biproduct.π (Subtype.restrict p f) ⟨j, h⟩ else 0 :=
  by
  ext i
  rw [biproduct.from_subtype, biproduct.ι_desc_assoc, biproduct.ι_π]
  by_cases h : p j
  · rw [dif_pos h, biproduct.ι_π]
    split_ifs with h₁ h₂ h₂
    exacts[rfl, False.elim (h₂ (Subtype.ext h₁)), False.elim (h₁ (congr_arg Subtype.val h₂)), rfl]
  · rw [dif_neg h, dif_neg (show (i : J) ≠ j from fun h₂ => h (h₂ ▸ i.2)), comp_zero]
#align
  category_theory.limits.biproduct.from_subtype_π CategoryTheory.Limits.biproduct.from_subtype_π

theorem biproduct.from_subtype_eq_lift [DecidablePred p] :
    biproduct.fromSubtype f p =
      biproduct.lift fun j => if h : p j then biproduct.π (Subtype.restrict p f) ⟨j, h⟩ else 0 :=
  biproduct.hom_ext _ _ (by simp)
#align
  category_theory.limits.biproduct.from_subtype_eq_lift CategoryTheory.Limits.biproduct.from_subtype_eq_lift

@[simp, reassoc.1]
theorem biproduct.from_subtype_π_subtype (j : Subtype p) :
    biproduct.fromSubtype f p ≫ biproduct.π f j = biproduct.π (Subtype.restrict p f) j :=
  by
  ext i
  rw [biproduct.from_subtype, biproduct.ι_desc_assoc, biproduct.ι_π, biproduct.ι_π]
  split_ifs with h₁ h₂ h₂
  exacts[rfl, False.elim (h₂ (Subtype.ext h₁)), False.elim (h₁ (congr_arg Subtype.val h₂)), rfl]
#align
  category_theory.limits.biproduct.from_subtype_π_subtype CategoryTheory.Limits.biproduct.from_subtype_π_subtype

@[simp, reassoc.1]
theorem biproduct.to_subtype_π (j : Subtype p) :
    biproduct.toSubtype f p ≫ biproduct.π (Subtype.restrict p f) j = biproduct.π f j :=
  biproduct.lift_π _ _
#align category_theory.limits.biproduct.to_subtype_π CategoryTheory.Limits.biproduct.to_subtype_π

@[simp, reassoc.1]
theorem biproduct.ι_to_subtype [DecidablePred p] (j : J) :
    biproduct.ι f j ≫ biproduct.toSubtype f p =
      if h : p j then biproduct.ι (Subtype.restrict p f) ⟨j, h⟩ else 0 :=
  by
  ext i
  rw [biproduct.to_subtype, category.assoc, biproduct.lift_π, biproduct.ι_π]
  by_cases h : p j
  · rw [dif_pos h, biproduct.ι_π]
    split_ifs with h₁ h₂ h₂
    exacts[rfl, False.elim (h₂ (Subtype.ext h₁)), False.elim (h₁ (congr_arg Subtype.val h₂)), rfl]
  · rw [dif_neg h, dif_neg (show j ≠ i from fun h₂ => h (h₂.symm ▸ i.2)), zero_comp]
#align category_theory.limits.biproduct.ι_to_subtype CategoryTheory.Limits.biproduct.ι_to_subtype

theorem biproduct.to_subtype_eq_desc [DecidablePred p] :
    biproduct.toSubtype f p =
      biproduct.desc fun j => if h : p j then biproduct.ι (Subtype.restrict p f) ⟨j, h⟩ else 0 :=
  biproduct.hom_ext' _ _ (by simp)
#align
  category_theory.limits.biproduct.to_subtype_eq_desc CategoryTheory.Limits.biproduct.to_subtype_eq_desc

@[simp, reassoc.1]
theorem biproduct.ι_to_subtype_subtype (j : Subtype p) :
    biproduct.ι f j ≫ biproduct.toSubtype f p = biproduct.ι (Subtype.restrict p f) j :=
  by
  ext i
  rw [biproduct.to_subtype, category.assoc, biproduct.lift_π, biproduct.ι_π, biproduct.ι_π]
  split_ifs with h₁ h₂ h₂
  exacts[rfl, False.elim (h₂ (Subtype.ext h₁)), False.elim (h₁ (congr_arg Subtype.val h₂)), rfl]
#align
  category_theory.limits.biproduct.ι_to_subtype_subtype CategoryTheory.Limits.biproduct.ι_to_subtype_subtype

@[simp, reassoc.1]
theorem biproduct.ι_from_subtype (j : Subtype p) :
    biproduct.ι (Subtype.restrict p f) j ≫ biproduct.fromSubtype f p = biproduct.ι f j :=
  biproduct.ι_desc _ _
#align
  category_theory.limits.biproduct.ι_from_subtype CategoryTheory.Limits.biproduct.ι_from_subtype

@[simp, reassoc.1]
theorem biproduct.from_subtype_to_subtype :
    biproduct.fromSubtype f p ≫ biproduct.toSubtype f p = 𝟙 (⨁ Subtype.restrict p f) :=
  by
  refine' biproduct.hom_ext _ _ fun j => _
  rw [category.assoc, biproduct.to_subtype_π, biproduct.from_subtype_π_subtype, category.id_comp]
#align
  category_theory.limits.biproduct.from_subtype_to_subtype CategoryTheory.Limits.biproduct.from_subtype_to_subtype

@[simp, reassoc.1]
theorem biproduct.to_subtype_from_subtype [DecidablePred p] :
    biproduct.toSubtype f p ≫ biproduct.fromSubtype f p =
      biproduct.map fun j => if p j then 𝟙 (f j) else 0 :=
  by
  ext1 i
  by_cases h : p i
  · simp [h]
    congr
  · simp [h]
#align
  category_theory.limits.biproduct.to_subtype_from_subtype CategoryTheory.Limits.biproduct.to_subtype_from_subtype

end

section

variable (f : J → C) (i : J) [HasBiproduct f] [HasBiproduct (Subtype.restrict (fun j => j ≠ i) f)]

/-- The kernel of `biproduct.π f i` is the inclusion from the biproduct which omits `i`
from the index set `J` into the biproduct over `J`. -/
def biproduct.isLimitFromSubtype :
    IsLimit
      (KernelFork.ofι (biproduct.fromSubtype f fun j => j ≠ i) (by simp) :
        KernelFork (biproduct.π f i)) :=
  (Fork.IsLimit.mk' _) fun s =>
    ⟨s.ι ≫ biproduct.toSubtype _ _, by
      ext j
      rw [kernel_fork.ι_of_ι, category.assoc, category.assoc,
        biproduct.to_subtype_from_subtype_assoc, biproduct.map_π]
      rcases em (i = j) with (rfl | h)
      · rw [if_neg (not_not.2 rfl), comp_zero, comp_zero, kernel_fork.condition]
      · rw [if_pos (Ne.symm h), category.comp_id],
      by
      intro m hm
      rw [← hm, kernel_fork.ι_of_ι, category.assoc, biproduct.from_subtype_to_subtype]
      exact (category.comp_id _).symm⟩
#align
  category_theory.limits.biproduct.is_limit_from_subtype CategoryTheory.Limits.biproduct.isLimitFromSubtype

instance : HasKernel (biproduct.π f i) :=
  HasLimit.mk ⟨_, biproduct.isLimitFromSubtype f i⟩

/-- The kernel of `biproduct.π f i` is `⨁ subtype.restrict {i}ᶜ f`. -/
@[simps]
def kernelBiproductπIso : kernel (biproduct.π f i) ≅ ⨁ Subtype.restrict (fun j => j ≠ i) f :=
  limit.isoLimitCone ⟨_, biproduct.isLimitFromSubtype f i⟩
#align category_theory.limits.kernel_biproduct_π_iso CategoryTheory.Limits.kernelBiproductπIso

/-- The cokernel of `biproduct.ι f i` is the projection from the biproduct over the index set `J`
onto the biproduct omitting `i`. -/
def biproduct.isColimitToSubtype :
    IsColimit
      (CokernelCofork.ofπ (biproduct.toSubtype f fun j => j ≠ i) (by simp) :
        CokernelCofork (biproduct.ι f i)) :=
  (Cofork.IsColimit.mk' _) fun s =>
    ⟨biproduct.fromSubtype _ _ ≫ s.π, by
      ext j
      rw [cokernel_cofork.π_of_π, biproduct.to_subtype_from_subtype_assoc, biproduct.ι_map_assoc]
      rcases em (i = j) with (rfl | h)
      · rw [if_neg (not_not.2 rfl), zero_comp, cokernel_cofork.condition]
      · rw [if_pos (Ne.symm h), category.id_comp],
      by
      intro m hm
      rw [← hm, cokernel_cofork.π_of_π, ← category.assoc, biproduct.from_subtype_to_subtype]
      exact (category.id_comp _).symm⟩
#align
  category_theory.limits.biproduct.is_colimit_to_subtype CategoryTheory.Limits.biproduct.isColimitToSubtype

instance : HasCokernel (biproduct.ι f i) :=
  HasColimit.mk ⟨_, biproduct.isColimitToSubtype f i⟩

/-- The cokernel of `biproduct.ι f i` is `⨁ subtype.restrict {i}ᶜ f`. -/
@[simps]
def cokernelBiproductιIso : cokernel (biproduct.ι f i) ≅ ⨁ Subtype.restrict (fun j => j ≠ i) f :=
  colimit.isoColimitCocone ⟨_, biproduct.isColimitToSubtype f i⟩
#align category_theory.limits.cokernel_biproduct_ι_iso CategoryTheory.Limits.cokernelBiproductιIso

end

section

open Classical

-- Per #15067, we only allow indexing in `Type 0` here.
variable {K : Type} [Fintype K] [HasFiniteBiproducts C] (f : K → C)

/-- The limit cone exhibiting `⨁ subtype.restrict pᶜ f` as the kernel of
`biproduct.to_subtype f p` -/
@[simps]
def kernelForkBiproductToSubtype (p : Set K) : LimitCone (parallelPair (biproduct.toSubtype f p) 0)
    where
  Cone :=
    KernelFork.ofι (biproduct.fromSubtype f (pᶜ))
      (by
        ext (j k)
        simp only [biproduct.ι_from_subtype_assoc, biproduct.ι_to_subtype, comp_zero, zero_comp]
        erw [dif_neg j.2]
        simp only [zero_comp])
  IsLimit :=
    KernelFork.IsLimit.ofι _ _ (fun W g h => g ≫ biproduct.toSubtype f (pᶜ))
      (by
        intro W' g' w
        ext j
        simp only [category.assoc, biproduct.to_subtype_from_subtype, Pi.compl_apply,
          biproduct.map_π]
        split_ifs
        · simp
        · replace w := w =≫ biproduct.π _ ⟨j, not_not.mp h⟩
          simpa using w.symm)
      (by tidy)
#align
  category_theory.limits.kernel_fork_biproduct_to_subtype CategoryTheory.Limits.kernelForkBiproductToSubtype

instance (p : Set K) : HasKernel (biproduct.toSubtype f p) :=
  HasLimit.mk (kernelForkBiproductToSubtype f p)

/-- The kernel of `biproduct.to_subtype f p` is `⨁ subtype.restrict pᶜ f`. -/
@[simps]
def kernelBiproductToSubtypeIso (p : Set K) :
    kernel (biproduct.toSubtype f p) ≅ ⨁ Subtype.restrict (pᶜ) f :=
  limit.isoLimitCone (kernelForkBiproductToSubtype f p)
#align
  category_theory.limits.kernel_biproduct_to_subtype_iso CategoryTheory.Limits.kernelBiproductToSubtypeIso

/-- The colimit cocone exhibiting `⨁ subtype.restrict pᶜ f` as the cokernel of
`biproduct.from_subtype f p` -/
@[simps]
def cokernelCoforkBiproductFromSubtype (p : Set K) :
    ColimitCocone (parallelPair (biproduct.fromSubtype f p) 0)
    where
  Cocone :=
    CokernelCofork.ofπ (biproduct.toSubtype f (pᶜ))
      (by
        ext (j k)
        simp only [Pi.compl_apply, biproduct.ι_from_subtype_assoc, biproduct.ι_to_subtype,
          comp_zero, zero_comp]
        rw [dif_neg]
        simp only [zero_comp]
        exact not_not.mpr j.2)
  IsColimit :=
    CokernelCofork.IsColimit.ofπ _ _ (fun W g h => biproduct.fromSubtype f (pᶜ) ≫ g)
      (by
        intro W' g' w
        ext j
        simp only [biproduct.to_subtype_from_subtype_assoc, Pi.compl_apply, biproduct.ι_map_assoc]
        split_ifs
        · simp
        · replace w := biproduct.ι _ (⟨j, not_not.mp h⟩ : p) ≫= w
          simpa using w.symm)
      (by tidy)
#align
  category_theory.limits.cokernel_cofork_biproduct_from_subtype CategoryTheory.Limits.cokernelCoforkBiproductFromSubtype

instance (p : Set K) : HasCokernel (biproduct.fromSubtype f p) :=
  HasColimit.mk (cokernelCoforkBiproductFromSubtype f p)

/-- The cokernel of `biproduct.from_subtype f p` is `⨁ subtype.restrict pᶜ f`. -/
@[simps]
def cokernelBiproductFromSubtypeIso (p : Set K) :
    cokernel (biproduct.fromSubtype f p) ≅ ⨁ Subtype.restrict (pᶜ) f :=
  colimit.isoColimitCocone (cokernelCoforkBiproductFromSubtype f p)
#align
  category_theory.limits.cokernel_biproduct_from_subtype_iso CategoryTheory.Limits.cokernelBiproductFromSubtypeIso

end

end πKernel

end Limits

namespace Limits

section FiniteBiproducts

variable {J : Type} [Fintype J] {K : Type} [Fintype K] {C : Type u} [Category.{v} C]
  [HasZeroMorphisms C] [HasFiniteBiproducts C] {f : J → C} {g : K → C}

/-- Convert a (dependently typed) matrix to a morphism of biproducts.
-/
def biproduct.matrix (m : ∀ j k, f j ⟶ g k) : ⨁ f ⟶ ⨁ g :=
  biproduct.desc fun j => biproduct.lift fun k => m j k
#align category_theory.limits.biproduct.matrix CategoryTheory.Limits.biproduct.matrix

@[simp, reassoc.1]
theorem biproduct.matrix_π (m : ∀ j k, f j ⟶ g k) (k : K) :
    biproduct.matrix m ≫ biproduct.π g k = biproduct.desc fun j => m j k :=
  by
  ext
  simp [biproduct.matrix]
#align category_theory.limits.biproduct.matrix_π CategoryTheory.Limits.biproduct.matrix_π

@[simp, reassoc.1]
theorem biproduct.ι_matrix (m : ∀ j k, f j ⟶ g k) (j : J) :
    biproduct.ι f j ≫ biproduct.matrix m = biproduct.lift fun k => m j k :=
  by
  ext
  simp [biproduct.matrix]
#align category_theory.limits.biproduct.ι_matrix CategoryTheory.Limits.biproduct.ι_matrix

/-- Extract the matrix components from a morphism of biproducts.
-/
def biproduct.components (m : ⨁ f ⟶ ⨁ g) (j : J) (k : K) : f j ⟶ g k :=
  biproduct.ι f j ≫ m ≫ biproduct.π g k
#align category_theory.limits.biproduct.components CategoryTheory.Limits.biproduct.components

@[simp]
theorem biproduct.matrix_components (m : ∀ j k, f j ⟶ g k) (j : J) (k : K) :
    biproduct.components (biproduct.matrix m) j k = m j k := by simp [biproduct.components]
#align
  category_theory.limits.biproduct.matrix_components CategoryTheory.Limits.biproduct.matrix_components

@[simp]
theorem biproduct.components_matrix (m : ⨁ f ⟶ ⨁ g) :
    (biproduct.matrix fun j k => biproduct.components m j k) = m :=
  by
  ext
  simp [biproduct.components]
#align
  category_theory.limits.biproduct.components_matrix CategoryTheory.Limits.biproduct.components_matrix

/-- Morphisms between direct sums are matrices. -/
@[simps]
def biproduct.matrixEquiv : (⨁ f ⟶ ⨁ g) ≃ ∀ j k, f j ⟶ g k
    where
  toFun := biproduct.components
  invFun := biproduct.matrix
  left_inv := biproduct.components_matrix
  right_inv m := by
    ext
    apply biproduct.matrix_components
#align category_theory.limits.biproduct.matrix_equiv CategoryTheory.Limits.biproduct.matrixEquiv

end FiniteBiproducts

variable {J : Type w} {C : Type u} [Category.{v} C] [HasZeroMorphisms C]

instance biproduct.ι_mono (f : J → C) [HasBiproduct f] (b : J) : IsSplitMono (biproduct.ι f b) :=
  IsSplitMono.mk' { retraction := biproduct.desc <| Pi.single b _ }
#align category_theory.limits.biproduct.ι_mono CategoryTheory.Limits.biproduct.ι_mono

instance biproduct.π_epi (f : J → C) [HasBiproduct f] (b : J) : IsSplitEpi (biproduct.π f b) :=
  IsSplitEpi.mk' { section_ := biproduct.lift <| Pi.single b _ }
#align category_theory.limits.biproduct.π_epi CategoryTheory.Limits.biproduct.π_epi

/-- Auxiliary lemma for `biproduct.unique_up_to_iso`. -/
theorem biproduct.cone_point_unique_up_to_iso_hom (f : J → C) [HasBiproduct f] {b : Bicone f}
    (hb : b.IsBilimit) :
    (hb.IsLimit.conePointUniqueUpToIso (Biproduct.isLimit _)).hom = biproduct.lift b.π :=
  rfl
#align
  category_theory.limits.biproduct.cone_point_unique_up_to_iso_hom CategoryTheory.Limits.biproduct.cone_point_unique_up_to_iso_hom

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:76:14: unsupported tactic `discrete_cases #[] -/
/-- Auxiliary lemma for `biproduct.unique_up_to_iso`. -/
theorem biproduct.cone_point_unique_up_to_iso_inv (f : J → C) [HasBiproduct f] {b : Bicone f}
    (hb : b.IsBilimit) :
    (hb.IsLimit.conePointUniqueUpToIso (Biproduct.isLimit _)).inv = biproduct.desc b.ι :=
  by
  refine' biproduct.hom_ext' _ _ fun j => hb.is_limit.hom_ext fun j' => _
  trace
    "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:76:14: unsupported tactic `discrete_cases #[]"
  rw [category.assoc, is_limit.cone_point_unique_up_to_iso_inv_comp, bicone.to_cone_π_app,
    biproduct.bicone_π, biproduct.ι_desc, biproduct.ι_π, b.to_cone_π_app, b.ι_π]
#align
  category_theory.limits.biproduct.cone_point_unique_up_to_iso_inv CategoryTheory.Limits.biproduct.cone_point_unique_up_to_iso_inv

/-- Biproducts are unique up to isomorphism. This already follows because bilimits are limits,
    but in the case of biproducts we can give an isomorphism with particularly nice definitional
    properties, namely that `biproduct.lift b.π` and `biproduct.desc b.ι` are inverses of each
    other. -/
@[simps]
def biproduct.uniqueUpToIso (f : J → C) [HasBiproduct f] {b : Bicone f} (hb : b.IsBilimit) :
    b.x ≅ ⨁ f where
  hom := biproduct.lift b.π
  inv := biproduct.desc b.ι
  hom_inv_id' := by
    rw [← biproduct.cone_point_unique_up_to_iso_hom f hb, ←
      biproduct.cone_point_unique_up_to_iso_inv f hb, iso.hom_inv_id]
  inv_hom_id' := by
    rw [← biproduct.cone_point_unique_up_to_iso_hom f hb, ←
      biproduct.cone_point_unique_up_to_iso_inv f hb, iso.inv_hom_id]
#align
  category_theory.limits.biproduct.unique_up_to_iso CategoryTheory.Limits.biproduct.uniqueUpToIso

variable (C)

-- see Note [lower instance priority]
/-- A category with finite biproducts has a zero object. -/
instance (priority := 100) has_zero_object_of_has_finite_biproducts [HasFiniteBiproducts C] :
    HasZeroObject C :=
  by
  refine' ⟨⟨biproduct Empty.elim, fun X => ⟨⟨⟨0⟩, _⟩⟩, fun X => ⟨⟨⟨0⟩, _⟩⟩⟩⟩
  tidy
#align
  category_theory.limits.has_zero_object_of_has_finite_biproducts CategoryTheory.Limits.has_zero_object_of_has_finite_biproducts

section

variable {C} [Unique J] (f : J → C)

/-- The limit bicone for the biproduct over an index type with exactly one term. -/
@[simps]
def limitBiconeOfUnique : LimitBicone f
    where
  Bicone :=
    { x := f default
      π := fun j => eqToHom (by congr )
      ι := fun j => eqToHom (by congr ) }
  IsBilimit :=
    { IsLimit := (limitConeOfUnique f).IsLimit
      IsColimit := (colimitCoconeOfUnique f).IsColimit }
#align category_theory.limits.limit_bicone_of_unique CategoryTheory.Limits.limitBiconeOfUnique

instance (priority := 100) hasBiproductUnique : HasBiproduct f :=
  HasBiproduct.mk (limitBiconeOfUnique f)
#align category_theory.limits.has_biproduct_unique CategoryTheory.Limits.hasBiproductUnique

/-- A biproduct over a index type with exactly one term is just the object over that term. -/
@[simps]
def biproductUniqueIso : ⨁ f ≅ f default :=
  (biproduct.uniqueUpToIso _ (limitBiconeOfUnique f).IsBilimit).symm
#align category_theory.limits.biproduct_unique_iso CategoryTheory.Limits.biproductUniqueIso

end

variable {C}

/-- A binary bicone for a pair of objects `P Q : C` consists of the cone point `X`,
maps from `X` to both `P` and `Q`, and maps from both `P` and `Q` to `X`,
so that `inl ≫ fst = 𝟙 P`, `inl ≫ snd = 0`, `inr ≫ fst = 0`, and `inr ≫ snd = 𝟙 Q`
-/
@[nolint has_nonempty_instance]
structure BinaryBicone (P Q : C) where
  x : C
  fst : X ⟶ P
  snd : X ⟶ Q
  inl : P ⟶ X
  inr : Q ⟶ X
  inl_fst' : inl ≫ fst = 𝟙 P := by obviously
  inl_snd' : inl ≫ snd = 0 := by obviously
  inr_fst' : inr ≫ fst = 0 := by obviously
  inr_snd' : inr ≫ snd = 𝟙 Q := by obviously
#align category_theory.limits.binary_bicone CategoryTheory.Limits.BinaryBicone

restate_axiom binary_bicone.inl_fst'

restate_axiom binary_bicone.inl_snd'

restate_axiom binary_bicone.inr_fst'

restate_axiom binary_bicone.inr_snd'

attribute [simp, reassoc.1]
  binary_bicone.inl_fst binary_bicone.inl_snd binary_bicone.inr_fst binary_bicone.inr_snd

namespace BinaryBicone

variable {P Q : C}

/-- Extract the cone from a binary bicone. -/
def toCone (c : BinaryBicone P Q) : Cone (pair P Q) :=
  BinaryFan.mk c.fst c.snd
#align category_theory.limits.binary_bicone.to_cone CategoryTheory.Limits.BinaryBicone.toCone

@[simp]
theorem to_cone_X (c : BinaryBicone P Q) : c.toCone.x = c.x :=
  rfl
#align category_theory.limits.binary_bicone.to_cone_X CategoryTheory.Limits.BinaryBicone.to_cone_X

@[simp]
theorem to_cone_π_app_left (c : BinaryBicone P Q) : c.toCone.π.app ⟨WalkingPair.left⟩ = c.fst :=
  rfl
#align
  category_theory.limits.binary_bicone.to_cone_π_app_left CategoryTheory.Limits.BinaryBicone.to_cone_π_app_left

@[simp]
theorem to_cone_π_app_right (c : BinaryBicone P Q) : c.toCone.π.app ⟨WalkingPair.right⟩ = c.snd :=
  rfl
#align
  category_theory.limits.binary_bicone.to_cone_π_app_right CategoryTheory.Limits.BinaryBicone.to_cone_π_app_right

@[simp]
theorem binary_fan_fst_to_cone (c : BinaryBicone P Q) : BinaryFan.fst c.toCone = c.fst :=
  rfl
#align
  category_theory.limits.binary_bicone.binary_fan_fst_to_cone CategoryTheory.Limits.BinaryBicone.binary_fan_fst_to_cone

@[simp]
theorem binary_fan_snd_to_cone (c : BinaryBicone P Q) : BinaryFan.snd c.toCone = c.snd :=
  rfl
#align
  category_theory.limits.binary_bicone.binary_fan_snd_to_cone CategoryTheory.Limits.BinaryBicone.binary_fan_snd_to_cone

/-- Extract the cocone from a binary bicone. -/
def toCocone (c : BinaryBicone P Q) : Cocone (pair P Q) :=
  BinaryCofan.mk c.inl c.inr
#align category_theory.limits.binary_bicone.to_cocone CategoryTheory.Limits.BinaryBicone.toCocone

@[simp]
theorem to_cocone_X (c : BinaryBicone P Q) : c.toCocone.x = c.x :=
  rfl
#align
  category_theory.limits.binary_bicone.to_cocone_X CategoryTheory.Limits.BinaryBicone.to_cocone_X

@[simp]
theorem to_cocone_ι_app_left (c : BinaryBicone P Q) : c.toCocone.ι.app ⟨WalkingPair.left⟩ = c.inl :=
  rfl
#align
  category_theory.limits.binary_bicone.to_cocone_ι_app_left CategoryTheory.Limits.BinaryBicone.to_cocone_ι_app_left

@[simp]
theorem to_cocone_ι_app_right (c : BinaryBicone P Q) :
    c.toCocone.ι.app ⟨WalkingPair.right⟩ = c.inr :=
  rfl
#align
  category_theory.limits.binary_bicone.to_cocone_ι_app_right CategoryTheory.Limits.BinaryBicone.to_cocone_ι_app_right

@[simp]
theorem binary_cofan_inl_to_cocone (c : BinaryBicone P Q) : BinaryCofan.inl c.toCocone = c.inl :=
  rfl
#align
  category_theory.limits.binary_bicone.binary_cofan_inl_to_cocone CategoryTheory.Limits.BinaryBicone.binary_cofan_inl_to_cocone

@[simp]
theorem binary_cofan_inr_to_cocone (c : BinaryBicone P Q) : BinaryCofan.inr c.toCocone = c.inr :=
  rfl
#align
  category_theory.limits.binary_bicone.binary_cofan_inr_to_cocone CategoryTheory.Limits.BinaryBicone.binary_cofan_inr_to_cocone

instance (c : BinaryBicone P Q) : IsSplitMono c.inl :=
  IsSplitMono.mk'
    { retraction := c.fst
      id' := c.inl_fst }

instance (c : BinaryBicone P Q) : IsSplitMono c.inr :=
  IsSplitMono.mk'
    { retraction := c.snd
      id' := c.inr_snd }

instance (c : BinaryBicone P Q) : IsSplitEpi c.fst :=
  IsSplitEpi.mk'
    { section_ := c.inl
      id' := c.inl_fst }

instance (c : BinaryBicone P Q) : IsSplitEpi c.snd :=
  IsSplitEpi.mk'
    { section_ := c.inr
      id' := c.inr_snd }

/-- Convert a `binary_bicone` into a `bicone` over a pair. -/
@[simps]
def toBicone {X Y : C} (b : BinaryBicone X Y) : Bicone (pairFunction X Y)
    where
  x := b.x
  π j := WalkingPair.casesOn j b.fst b.snd
  ι j := WalkingPair.casesOn j b.inl b.inr
  ι_π j j' := by
    rcases j with ⟨⟩ <;> rcases j' with ⟨⟩
    tidy
#align category_theory.limits.binary_bicone.to_bicone CategoryTheory.Limits.BinaryBicone.toBicone

/-- A binary bicone is a limit cone if and only if the corresponding bicone is a limit cone. -/
def toBiconeIsLimit {X Y : C} (b : BinaryBicone X Y) :
    IsLimit b.toBicone.toCone ≃ IsLimit b.toCone :=
  is_limit.equiv_iso_limit <|
    Cones.ext (Iso.refl _) fun j => by
      cases j
      tidy
#align
  category_theory.limits.binary_bicone.to_bicone_is_limit CategoryTheory.Limits.BinaryBicone.toBiconeIsLimit

/-- A binary bicone is a colimit cocone if and only if the corresponding bicone is a colimit
    cocone. -/
def toBiconeIsColimit {X Y : C} (b : BinaryBicone X Y) :
    IsColimit b.toBicone.toCocone ≃ IsColimit b.toCocone :=
  is_colimit.equiv_iso_colimit <|
    Cocones.ext (Iso.refl _) fun j => by
      cases j
      tidy
#align
  category_theory.limits.binary_bicone.to_bicone_is_colimit CategoryTheory.Limits.BinaryBicone.toBiconeIsColimit

end BinaryBicone

namespace Bicone

/-- Convert a `bicone` over a function on `walking_pair` to a binary_bicone. -/
@[simps]
def toBinaryBicone {X Y : C} (b : Bicone (pairFunction X Y)) : BinaryBicone X Y
    where
  x := b.x
  fst := b.π WalkingPair.left
  snd := b.π WalkingPair.right
  inl := b.ι WalkingPair.left
  inr := b.ι WalkingPair.right
  inl_fst' := by
    simp [bicone.ι_π]
    rfl
  inr_fst' := by simp [bicone.ι_π]
  inl_snd' := by simp [bicone.ι_π]
  inr_snd' := by
    simp [bicone.ι_π]
    rfl
#align category_theory.limits.bicone.to_binary_bicone CategoryTheory.Limits.Bicone.toBinaryBicone

/-- A bicone over a pair is a limit cone if and only if the corresponding binary bicone is a limit
    cone.  -/
def toBinaryBiconeIsLimit {X Y : C} (b : Bicone (pairFunction X Y)) :
    IsLimit b.toBinaryBicone.toCone ≃ IsLimit b.toCone :=
  is_limit.equiv_iso_limit <| Cones.ext (Iso.refl _) fun j => by rcases j with ⟨⟨⟩⟩ <;> tidy
#align
  category_theory.limits.bicone.to_binary_bicone_is_limit CategoryTheory.Limits.Bicone.toBinaryBiconeIsLimit

/-- A bicone over a pair is a colimit cocone if and only if the corresponding binary bicone is a
    colimit cocone. -/
def toBinaryBiconeIsColimit {X Y : C} (b : Bicone (pairFunction X Y)) :
    IsColimit b.toBinaryBicone.toCocone ≃ IsColimit b.toCocone :=
  is_colimit.equiv_iso_colimit <| Cocones.ext (Iso.refl _) fun j => by rcases j with ⟨⟨⟩⟩ <;> tidy
#align
  category_theory.limits.bicone.to_binary_bicone_is_colimit CategoryTheory.Limits.Bicone.toBinaryBiconeIsColimit

end Bicone

/-- Structure witnessing that a binary bicone is a limit cone and a limit cocone. -/
@[nolint has_nonempty_instance]
structure BinaryBicone.IsBilimit {P Q : C} (b : BinaryBicone P Q) where
  IsLimit : IsLimit b.toCone
  IsColimit : IsColimit b.toCocone
#align category_theory.limits.binary_bicone.is_bilimit CategoryTheory.Limits.BinaryBicone.IsBilimit

/-- A binary bicone is a bilimit bicone if and only if the corresponding bicone is a bilimit. -/
def BinaryBicone.toBiconeIsBilimit {X Y : C} (b : BinaryBicone X Y) :
    b.toBicone.IsBilimit ≃ b.IsBilimit
    where
  toFun h := ⟨b.toBiconeIsLimit h.IsLimit, b.toBiconeIsColimit h.IsColimit⟩
  invFun h := ⟨b.toBiconeIsLimit.symm h.IsLimit, b.toBiconeIsColimit.symm h.IsColimit⟩
  left_inv := fun ⟨h, h'⟩ => by
    dsimp only
    simp
  right_inv := fun ⟨h, h'⟩ => by
    dsimp only
    simp
#align
  category_theory.limits.binary_bicone.to_bicone_is_bilimit CategoryTheory.Limits.BinaryBicone.toBiconeIsBilimit

/-- A bicone over a pair is a bilimit bicone if and only if the corresponding binary bicone is a
    bilimit. -/
def Bicone.toBinaryBiconeIsBilimit {X Y : C} (b : Bicone (pairFunction X Y)) :
    b.toBinaryBicone.IsBilimit ≃ b.IsBilimit
    where
  toFun h := ⟨b.toBinaryBiconeIsLimit h.IsLimit, b.toBinaryBiconeIsColimit h.IsColimit⟩
  invFun h := ⟨b.toBinaryBiconeIsLimit.symm h.IsLimit, b.toBinaryBiconeIsColimit.symm h.IsColimit⟩
  left_inv := fun ⟨h, h'⟩ => by
    dsimp only
    simp
  right_inv := fun ⟨h, h'⟩ => by
    dsimp only
    simp
#align
  category_theory.limits.bicone.to_binary_bicone_is_bilimit CategoryTheory.Limits.Bicone.toBinaryBiconeIsBilimit

/-- A bicone over `P Q : C`, which is both a limit cone and a colimit cocone.
-/
@[nolint has_nonempty_instance]
structure BinaryBiproductData (P Q : C) where
  Bicone : BinaryBicone P Q
  IsBilimit : bicone.IsBilimit
#align category_theory.limits.binary_biproduct_data CategoryTheory.Limits.BinaryBiproductData

/-- `has_binary_biproduct P Q` expresses the mere existence of a bicone which is
simultaneously a limit and a colimit of the diagram `pair P Q`.
-/
class HasBinaryBiproduct (P Q : C) : Prop where mk' ::
  exists_binary_biproduct : Nonempty (BinaryBiproductData P Q)
#align category_theory.limits.has_binary_biproduct CategoryTheory.Limits.HasBinaryBiproduct

theorem HasBinaryBiproduct.mk {P Q : C} (d : BinaryBiproductData P Q) : HasBinaryBiproduct P Q :=
  ⟨Nonempty.intro d⟩
#align category_theory.limits.has_binary_biproduct.mk CategoryTheory.Limits.HasBinaryBiproduct.mk

/--
Use the axiom of choice to extract explicit `binary_biproduct_data F` from `has_binary_biproduct F`.
-/
def getBinaryBiproductData (P Q : C) [HasBinaryBiproduct P Q] : BinaryBiproductData P Q :=
  Classical.choice HasBinaryBiproduct.exists_binary_biproduct
#align category_theory.limits.get_binary_biproduct_data CategoryTheory.Limits.getBinaryBiproductData

/-- A bicone for `P Q ` which is both a limit cone and a colimit cocone. -/
def BinaryBiproduct.bicone (P Q : C) [HasBinaryBiproduct P Q] : BinaryBicone P Q :=
  (getBinaryBiproductData P Q).Bicone
#align category_theory.limits.binary_biproduct.bicone CategoryTheory.Limits.BinaryBiproduct.bicone

/-- `binary_biproduct.bicone P Q` is a limit bicone. -/
def BinaryBiproduct.isBilimit (P Q : C) [HasBinaryBiproduct P Q] :
    (BinaryBiproduct.bicone P Q).IsBilimit :=
  (getBinaryBiproductData P Q).IsBilimit
#align
  category_theory.limits.binary_biproduct.is_bilimit CategoryTheory.Limits.BinaryBiproduct.isBilimit

/-- `binary_biproduct.bicone P Q` is a limit cone. -/
def BinaryBiproduct.isLimit (P Q : C) [HasBinaryBiproduct P Q] :
    IsLimit (BinaryBiproduct.bicone P Q).toCone :=
  (getBinaryBiproductData P Q).IsBilimit.IsLimit
#align
  category_theory.limits.binary_biproduct.is_limit CategoryTheory.Limits.BinaryBiproduct.isLimit

/-- `binary_biproduct.bicone P Q` is a colimit cocone. -/
def BinaryBiproduct.isColimit (P Q : C) [HasBinaryBiproduct P Q] :
    IsColimit (BinaryBiproduct.bicone P Q).toCocone :=
  (getBinaryBiproductData P Q).IsBilimit.IsColimit
#align
  category_theory.limits.binary_biproduct.is_colimit CategoryTheory.Limits.BinaryBiproduct.isColimit

section

variable (C)

/-- `has_binary_biproducts C` represents the existence of a bicone which is
simultaneously a limit and a colimit of the diagram `pair P Q`, for every `P Q : C`.
-/
class HasBinaryBiproducts : Prop where
  HasBinaryBiproduct : ∀ P Q : C, HasBinaryBiproduct P Q
#align category_theory.limits.has_binary_biproducts CategoryTheory.Limits.HasBinaryBiproducts

attribute [instance] has_binary_biproducts.has_binary_biproduct

/-- A category with finite biproducts has binary biproducts.

This is not an instance as typically in concrete categories there will be
an alternative construction with nicer definitional properties.
-/
theorem hasBinaryBiproductsOfFiniteBiproducts [HasFiniteBiproducts C] : HasBinaryBiproducts C :=
  {
    HasBinaryBiproduct := fun P Q =>
      HasBinaryBiproduct.mk
        { Bicone := (Biproduct.bicone (pairFunction P Q)).toBinaryBicone
          IsBilimit := (Bicone.toBinaryBiconeIsBilimit _).symm (Biproduct.isBilimit _) } }
#align
  category_theory.limits.has_binary_biproducts_of_finite_biproducts CategoryTheory.Limits.hasBinaryBiproductsOfFiniteBiproducts

end

variable {P Q : C}

instance HasBinaryBiproduct.hasLimitPair [HasBinaryBiproduct P Q] : HasLimit (pair P Q) :=
  HasLimit.mk ⟨_, BinaryBiproduct.isLimit P Q⟩
#align
  category_theory.limits.has_binary_biproduct.has_limit_pair CategoryTheory.Limits.HasBinaryBiproduct.hasLimitPair

instance HasBinaryBiproduct.hasColimitPair [HasBinaryBiproduct P Q] : HasColimit (pair P Q) :=
  HasColimit.mk ⟨_, BinaryBiproduct.isColimit P Q⟩
#align
  category_theory.limits.has_binary_biproduct.has_colimit_pair CategoryTheory.Limits.HasBinaryBiproduct.hasColimitPair

instance (priority := 100) has_binary_products_of_has_binary_biproducts [HasBinaryBiproducts C] :
    HasBinaryProducts C where HasLimit F := hasLimitOfIso (diagramIsoPair F).symm
#align
  category_theory.limits.has_binary_products_of_has_binary_biproducts CategoryTheory.Limits.has_binary_products_of_has_binary_biproducts

instance (priority := 100) has_binary_coproducts_of_has_binary_biproducts [HasBinaryBiproducts C] :
    HasBinaryCoproducts C where HasColimit F := hasColimitOfIso (diagramIsoPair F)
#align
  category_theory.limits.has_binary_coproducts_of_has_binary_biproducts CategoryTheory.Limits.has_binary_coproducts_of_has_binary_biproducts

/-- The isomorphism between the specified binary product and the specified binary coproduct for
a pair for a binary biproduct.
-/
def biprodIso (X Y : C) [HasBinaryBiproduct X Y] : Limits.prod X Y ≅ Limits.coprod X Y :=
  (IsLimit.conePointUniqueUpToIso (limit.isLimit _) (BinaryBiproduct.isLimit X Y)).trans <|
    IsColimit.coconePointUniqueUpToIso (BinaryBiproduct.isColimit X Y) (colimit.isColimit _)
#align category_theory.limits.biprod_iso CategoryTheory.Limits.biprodIso

/-- An arbitrary choice of biproduct of a pair of objects. -/
abbrev biprod (X Y : C) [HasBinaryBiproduct X Y] :=
  (BinaryBiproduct.bicone X Y).x
#align category_theory.limits.biprod CategoryTheory.Limits.biprod

-- mathport name: «expr ⊞ »
notation:20 X " ⊞ " Y:20 => biprod X Y

/-- The projection onto the first summand of a binary biproduct. -/
abbrev biprod.fst {X Y : C} [HasBinaryBiproduct X Y] : X ⊞ Y ⟶ X :=
  (BinaryBiproduct.bicone X Y).fst
#align category_theory.limits.biprod.fst CategoryTheory.Limits.biprod.fst

/-- The projection onto the second summand of a binary biproduct. -/
abbrev biprod.snd {X Y : C} [HasBinaryBiproduct X Y] : X ⊞ Y ⟶ Y :=
  (BinaryBiproduct.bicone X Y).snd
#align category_theory.limits.biprod.snd CategoryTheory.Limits.biprod.snd

/-- The inclusion into the first summand of a binary biproduct. -/
abbrev biprod.inl {X Y : C} [HasBinaryBiproduct X Y] : X ⟶ X ⊞ Y :=
  (BinaryBiproduct.bicone X Y).inl
#align category_theory.limits.biprod.inl CategoryTheory.Limits.biprod.inl

/-- The inclusion into the second summand of a binary biproduct. -/
abbrev biprod.inr {X Y : C} [HasBinaryBiproduct X Y] : Y ⟶ X ⊞ Y :=
  (BinaryBiproduct.bicone X Y).inr
#align category_theory.limits.biprod.inr CategoryTheory.Limits.biprod.inr

section

variable {X Y : C} [HasBinaryBiproduct X Y]

@[simp]
theorem BinaryBiproduct.bicone_fst : (BinaryBiproduct.bicone X Y).fst = biprod.fst :=
  rfl
#align
  category_theory.limits.binary_biproduct.bicone_fst CategoryTheory.Limits.BinaryBiproduct.bicone_fst

@[simp]
theorem BinaryBiproduct.bicone_snd : (BinaryBiproduct.bicone X Y).snd = biprod.snd :=
  rfl
#align
  category_theory.limits.binary_biproduct.bicone_snd CategoryTheory.Limits.BinaryBiproduct.bicone_snd

@[simp]
theorem BinaryBiproduct.bicone_inl : (BinaryBiproduct.bicone X Y).inl = biprod.inl :=
  rfl
#align
  category_theory.limits.binary_biproduct.bicone_inl CategoryTheory.Limits.BinaryBiproduct.bicone_inl

@[simp]
theorem BinaryBiproduct.bicone_inr : (BinaryBiproduct.bicone X Y).inr = biprod.inr :=
  rfl
#align
  category_theory.limits.binary_biproduct.bicone_inr CategoryTheory.Limits.BinaryBiproduct.bicone_inr

end

@[simp, reassoc.1]
theorem biprod.inl_fst {X Y : C} [HasBinaryBiproduct X Y] :
    (biprod.inl : X ⟶ X ⊞ Y) ≫ (biprod.fst : X ⊞ Y ⟶ X) = 𝟙 X :=
  (BinaryBiproduct.bicone X Y).inl_fst
#align category_theory.limits.biprod.inl_fst CategoryTheory.Limits.biprod.inl_fst

@[simp, reassoc.1]
theorem biprod.inl_snd {X Y : C} [HasBinaryBiproduct X Y] :
    (biprod.inl : X ⟶ X ⊞ Y) ≫ (biprod.snd : X ⊞ Y ⟶ Y) = 0 :=
  (BinaryBiproduct.bicone X Y).inl_snd
#align category_theory.limits.biprod.inl_snd CategoryTheory.Limits.biprod.inl_snd

@[simp, reassoc.1]
theorem biprod.inr_fst {X Y : C} [HasBinaryBiproduct X Y] :
    (biprod.inr : Y ⟶ X ⊞ Y) ≫ (biprod.fst : X ⊞ Y ⟶ X) = 0 :=
  (BinaryBiproduct.bicone X Y).inr_fst
#align category_theory.limits.biprod.inr_fst CategoryTheory.Limits.biprod.inr_fst

@[simp, reassoc.1]
theorem biprod.inr_snd {X Y : C} [HasBinaryBiproduct X Y] :
    (biprod.inr : Y ⟶ X ⊞ Y) ≫ (biprod.snd : X ⊞ Y ⟶ Y) = 𝟙 Y :=
  (BinaryBiproduct.bicone X Y).inr_snd
#align category_theory.limits.biprod.inr_snd CategoryTheory.Limits.biprod.inr_snd

/-- Given a pair of maps into the summands of a binary biproduct,
we obtain a map into the binary biproduct. -/
abbrev biprod.lift {W X Y : C} [HasBinaryBiproduct X Y] (f : W ⟶ X) (g : W ⟶ Y) : W ⟶ X ⊞ Y :=
  (BinaryBiproduct.isLimit X Y).lift (BinaryFan.mk f g)
#align category_theory.limits.biprod.lift CategoryTheory.Limits.biprod.lift

/-- Given a pair of maps out of the summands of a binary biproduct,
we obtain a map out of the binary biproduct. -/
abbrev biprod.desc {W X Y : C} [HasBinaryBiproduct X Y] (f : X ⟶ W) (g : Y ⟶ W) : X ⊞ Y ⟶ W :=
  (BinaryBiproduct.isColimit X Y).desc (BinaryCofan.mk f g)
#align category_theory.limits.biprod.desc CategoryTheory.Limits.biprod.desc

@[simp, reassoc.1]
theorem biprod.lift_fst {W X Y : C} [HasBinaryBiproduct X Y] (f : W ⟶ X) (g : W ⟶ Y) :
    biprod.lift f g ≫ biprod.fst = f :=
  (BinaryBiproduct.isLimit X Y).fac _ ⟨WalkingPair.left⟩
#align category_theory.limits.biprod.lift_fst CategoryTheory.Limits.biprod.lift_fst

@[simp, reassoc.1]
theorem biprod.lift_snd {W X Y : C} [HasBinaryBiproduct X Y] (f : W ⟶ X) (g : W ⟶ Y) :
    biprod.lift f g ≫ biprod.snd = g :=
  (BinaryBiproduct.isLimit X Y).fac _ ⟨WalkingPair.right⟩
#align category_theory.limits.biprod.lift_snd CategoryTheory.Limits.biprod.lift_snd

@[simp, reassoc.1]
theorem biprod.inl_desc {W X Y : C} [HasBinaryBiproduct X Y] (f : X ⟶ W) (g : Y ⟶ W) :
    biprod.inl ≫ biprod.desc f g = f :=
  (BinaryBiproduct.isColimit X Y).fac _ ⟨WalkingPair.left⟩
#align category_theory.limits.biprod.inl_desc CategoryTheory.Limits.biprod.inl_desc

@[simp, reassoc.1]
theorem biprod.inr_desc {W X Y : C} [HasBinaryBiproduct X Y] (f : X ⟶ W) (g : Y ⟶ W) :
    biprod.inr ≫ biprod.desc f g = g :=
  (BinaryBiproduct.isColimit X Y).fac _ ⟨WalkingPair.right⟩
#align category_theory.limits.biprod.inr_desc CategoryTheory.Limits.biprod.inr_desc

instance biprod.mono_lift_of_mono_left {W X Y : C} [HasBinaryBiproduct X Y] (f : W ⟶ X) (g : W ⟶ Y)
    [Mono f] : Mono (biprod.lift f g) :=
  mono_of_mono_fac <| biprod.lift_fst _ _
#align
  category_theory.limits.biprod.mono_lift_of_mono_left CategoryTheory.Limits.biprod.mono_lift_of_mono_left

instance biprod.mono_lift_of_mono_right {W X Y : C} [HasBinaryBiproduct X Y] (f : W ⟶ X) (g : W ⟶ Y)
    [Mono g] : Mono (biprod.lift f g) :=
  mono_of_mono_fac <| biprod.lift_snd _ _
#align
  category_theory.limits.biprod.mono_lift_of_mono_right CategoryTheory.Limits.biprod.mono_lift_of_mono_right

instance biprod.epi_desc_of_epi_left {W X Y : C} [HasBinaryBiproduct X Y] (f : X ⟶ W) (g : Y ⟶ W)
    [Epi f] : Epi (biprod.desc f g) :=
  epi_of_epi_fac <| biprod.inl_desc _ _
#align
  category_theory.limits.biprod.epi_desc_of_epi_left CategoryTheory.Limits.biprod.epi_desc_of_epi_left

instance biprod.epi_desc_of_epi_right {W X Y : C} [HasBinaryBiproduct X Y] (f : X ⟶ W) (g : Y ⟶ W)
    [Epi g] : Epi (biprod.desc f g) :=
  epi_of_epi_fac <| biprod.inr_desc _ _
#align
  category_theory.limits.biprod.epi_desc_of_epi_right CategoryTheory.Limits.biprod.epi_desc_of_epi_right

/-- Given a pair of maps between the summands of a pair of binary biproducts,
we obtain a map between the binary biproducts. -/
abbrev biprod.map {W X Y Z : C} [HasBinaryBiproduct W X] [HasBinaryBiproduct Y Z] (f : W ⟶ Y)
    (g : X ⟶ Z) : W ⊞ X ⟶ Y ⊞ Z :=
  IsLimit.map (BinaryBiproduct.bicone W X).toCone (BinaryBiproduct.isLimit Y Z)
    (@mapPair _ _ (pair W X) (pair Y Z) f g)
#align category_theory.limits.biprod.map CategoryTheory.Limits.biprod.map

/-- An alternative to `biprod.map` constructed via colimits.
This construction only exists in order to show it is equal to `biprod.map`. -/
abbrev biprod.map' {W X Y Z : C} [HasBinaryBiproduct W X] [HasBinaryBiproduct Y Z] (f : W ⟶ Y)
    (g : X ⟶ Z) : W ⊞ X ⟶ Y ⊞ Z :=
  IsColimit.map (BinaryBiproduct.isColimit W X) (BinaryBiproduct.bicone Y Z).toCocone
    (@mapPair _ _ (pair W X) (pair Y Z) f g)
#align category_theory.limits.biprod.map' CategoryTheory.Limits.biprod.map'

@[ext]
theorem biprod.hom_ext {X Y Z : C} [HasBinaryBiproduct X Y] (f g : Z ⟶ X ⊞ Y)
    (h₀ : f ≫ biprod.fst = g ≫ biprod.fst) (h₁ : f ≫ biprod.snd = g ≫ biprod.snd) : f = g :=
  BinaryFan.IsLimit.hom_ext (BinaryBiproduct.isLimit X Y) h₀ h₁
#align category_theory.limits.biprod.hom_ext CategoryTheory.Limits.biprod.hom_ext

@[ext]
theorem biprod.hom_ext' {X Y Z : C} [HasBinaryBiproduct X Y] (f g : X ⊞ Y ⟶ Z)
    (h₀ : biprod.inl ≫ f = biprod.inl ≫ g) (h₁ : biprod.inr ≫ f = biprod.inr ≫ g) : f = g :=
  BinaryCofan.IsColimit.hom_ext (BinaryBiproduct.isColimit X Y) h₀ h₁
#align category_theory.limits.biprod.hom_ext' CategoryTheory.Limits.biprod.hom_ext'

/-- The canonical isomorphism between the chosen biproduct and the chosen product. -/
def biprod.isoProd (X Y : C) [HasBinaryBiproduct X Y] : X ⊞ Y ≅ X ⨯ Y :=
  IsLimit.conePointUniqueUpToIso (BinaryBiproduct.isLimit X Y) (limit.isLimit _)
#align category_theory.limits.biprod.iso_prod CategoryTheory.Limits.biprod.isoProd

@[simp]
theorem biprod.iso_prod_hom {X Y : C} [HasBinaryBiproduct X Y] :
    (biprod.isoProd X Y).hom = prod.lift biprod.fst biprod.snd := by ext <;> simp [biprod.iso_prod]
#align category_theory.limits.biprod.iso_prod_hom CategoryTheory.Limits.biprod.iso_prod_hom

@[simp]
theorem biprod.iso_prod_inv {X Y : C} [HasBinaryBiproduct X Y] :
    (biprod.isoProd X Y).inv = biprod.lift prod.fst prod.snd := by
  apply biprod.hom_ext <;> simp [iso.inv_comp_eq]
#align category_theory.limits.biprod.iso_prod_inv CategoryTheory.Limits.biprod.iso_prod_inv

/-- The canonical isomorphism between the chosen biproduct and the chosen coproduct. -/
def biprod.isoCoprod (X Y : C) [HasBinaryBiproduct X Y] : X ⊞ Y ≅ X ⨿ Y :=
  IsColimit.coconePointUniqueUpToIso (BinaryBiproduct.isColimit X Y) (colimit.isColimit _)
#align category_theory.limits.biprod.iso_coprod CategoryTheory.Limits.biprod.isoCoprod

@[simp]
theorem biprod.iso_coprod_inv {X Y : C} [HasBinaryBiproduct X Y] :
    (biprod.isoCoprod X Y).inv = coprod.desc biprod.inl biprod.inr := by
  ext <;> simp [biprod.iso_coprod] <;> rfl
#align category_theory.limits.biprod.iso_coprod_inv CategoryTheory.Limits.biprod.iso_coprod_inv

@[simp]
theorem biprod_iso_coprod_hom {X Y : C} [HasBinaryBiproduct X Y] :
    (biprod.isoCoprod X Y).hom = biprod.desc coprod.inl coprod.inr := by
  apply biprod.hom_ext' <;> simp [← iso.eq_comp_inv]
#align category_theory.limits.biprod_iso_coprod_hom CategoryTheory.Limits.biprod_iso_coprod_hom

theorem biprod.map_eq_map' {W X Y Z : C} [HasBinaryBiproduct W X] [HasBinaryBiproduct Y Z]
    (f : W ⟶ Y) (g : X ⟶ Z) : biprod.map f g = biprod.map' f g :=
  by
  ext
  · simp only [map_pair_left, is_colimit.ι_map, is_limit.map_π, biprod.inl_fst_assoc,
      category.assoc, ← binary_bicone.to_cone_π_app_left, ← binary_biproduct.bicone_fst, ←
      binary_bicone.to_cocone_ι_app_left, ← binary_biproduct.bicone_inl]
    simp
  · simp only [map_pair_left, is_colimit.ι_map, is_limit.map_π, zero_comp, biprod.inl_snd_assoc,
      category.assoc, ← binary_bicone.to_cone_π_app_right, ← binary_biproduct.bicone_snd, ←
      binary_bicone.to_cocone_ι_app_left, ← binary_biproduct.bicone_inl]
    simp
  · simp only [map_pair_right, biprod.inr_fst_assoc, is_colimit.ι_map, is_limit.map_π, zero_comp,
      category.assoc, ← binary_bicone.to_cone_π_app_left, ← binary_biproduct.bicone_fst, ←
      binary_bicone.to_cocone_ι_app_right, ← binary_biproduct.bicone_inr]
    simp
  · simp only [map_pair_right, is_colimit.ι_map, is_limit.map_π, biprod.inr_snd_assoc,
      category.assoc, ← binary_bicone.to_cone_π_app_right, ← binary_biproduct.bicone_snd, ←
      binary_bicone.to_cocone_ι_app_right, ← binary_biproduct.bicone_inr]
    simp
#align category_theory.limits.biprod.map_eq_map' CategoryTheory.Limits.biprod.map_eq_map'

instance biprod.inl_mono {X Y : C} [HasBinaryBiproduct X Y] :
    IsSplitMono (biprod.inl : X ⟶ X ⊞ Y) :=
  IsSplitMono.mk' { retraction := biprod.fst }
#align category_theory.limits.biprod.inl_mono CategoryTheory.Limits.biprod.inl_mono

instance biprod.inr_mono {X Y : C} [HasBinaryBiproduct X Y] :
    IsSplitMono (biprod.inr : Y ⟶ X ⊞ Y) :=
  IsSplitMono.mk' { retraction := biprod.snd }
#align category_theory.limits.biprod.inr_mono CategoryTheory.Limits.biprod.inr_mono

instance biprod.fst_epi {X Y : C} [HasBinaryBiproduct X Y] : IsSplitEpi (biprod.fst : X ⊞ Y ⟶ X) :=
  IsSplitEpi.mk' { section_ := biprod.inl }
#align category_theory.limits.biprod.fst_epi CategoryTheory.Limits.biprod.fst_epi

instance biprod.snd_epi {X Y : C} [HasBinaryBiproduct X Y] : IsSplitEpi (biprod.snd : X ⊞ Y ⟶ Y) :=
  IsSplitEpi.mk' { section_ := biprod.inr }
#align category_theory.limits.biprod.snd_epi CategoryTheory.Limits.biprod.snd_epi

@[simp, reassoc.1]
theorem biprod.map_fst {W X Y Z : C} [HasBinaryBiproduct W X] [HasBinaryBiproduct Y Z] (f : W ⟶ Y)
    (g : X ⟶ Z) : biprod.map f g ≫ biprod.fst = biprod.fst ≫ f :=
  IsLimit.map_π _ _ _ (⟨WalkingPair.left⟩ : Discrete WalkingPair)
#align category_theory.limits.biprod.map_fst CategoryTheory.Limits.biprod.map_fst

@[simp, reassoc.1]
theorem biprod.map_snd {W X Y Z : C} [HasBinaryBiproduct W X] [HasBinaryBiproduct Y Z] (f : W ⟶ Y)
    (g : X ⟶ Z) : biprod.map f g ≫ biprod.snd = biprod.snd ≫ g :=
  IsLimit.map_π _ _ _ (⟨WalkingPair.right⟩ : Discrete WalkingPair)
#align category_theory.limits.biprod.map_snd CategoryTheory.Limits.biprod.map_snd

-- Because `biprod.map` is defined in terms of `lim` rather than `colim`,
-- we need to provide additional `simp` lemmas.
@[simp, reassoc.1]
theorem biprod.inl_map {W X Y Z : C} [HasBinaryBiproduct W X] [HasBinaryBiproduct Y Z] (f : W ⟶ Y)
    (g : X ⟶ Z) : biprod.inl ≫ biprod.map f g = f ≫ biprod.inl :=
  by
  rw [biprod.map_eq_map']
  exact is_colimit.ι_map (binary_biproduct.is_colimit W X) _ _ ⟨walking_pair.left⟩
#align category_theory.limits.biprod.inl_map CategoryTheory.Limits.biprod.inl_map

@[simp, reassoc.1]
theorem biprod.inr_map {W X Y Z : C} [HasBinaryBiproduct W X] [HasBinaryBiproduct Y Z] (f : W ⟶ Y)
    (g : X ⟶ Z) : biprod.inr ≫ biprod.map f g = g ≫ biprod.inr :=
  by
  rw [biprod.map_eq_map']
  exact is_colimit.ι_map (binary_biproduct.is_colimit W X) _ _ ⟨walking_pair.right⟩
#align category_theory.limits.biprod.inr_map CategoryTheory.Limits.biprod.inr_map

/-- Given a pair of isomorphisms between the summands of a pair of binary biproducts,
we obtain an isomorphism between the binary biproducts. -/
@[simps]
def biprod.mapIso {W X Y Z : C} [HasBinaryBiproduct W X] [HasBinaryBiproduct Y Z] (f : W ≅ Y)
    (g : X ≅ Z) : W ⊞ X ≅ Y ⊞ Z where
  hom := biprod.map f.hom g.hom
  inv := biprod.map f.inv g.inv
#align category_theory.limits.biprod.map_iso CategoryTheory.Limits.biprod.mapIso

/-- Auxiliary lemma for `biprod.unique_up_to_iso`. -/
theorem biprod.cone_point_unique_up_to_iso_hom (X Y : C) [HasBinaryBiproduct X Y]
    {b : BinaryBicone X Y} (hb : b.IsBilimit) :
    (hb.IsLimit.conePointUniqueUpToIso (BinaryBiproduct.isLimit _ _)).hom =
      biprod.lift b.fst b.snd :=
  rfl
#align
  category_theory.limits.biprod.cone_point_unique_up_to_iso_hom CategoryTheory.Limits.biprod.cone_point_unique_up_to_iso_hom

/-- Auxiliary lemma for `biprod.unique_up_to_iso`. -/
theorem biprod.cone_point_unique_up_to_iso_inv (X Y : C) [HasBinaryBiproduct X Y]
    {b : BinaryBicone X Y} (hb : b.IsBilimit) :
    (hb.IsLimit.conePointUniqueUpToIso (BinaryBiproduct.isLimit _ _)).inv =
      biprod.desc b.inl b.inr :=
  by
  refine' biprod.hom_ext' _ _ (hb.is_limit.hom_ext fun j => _) (hb.is_limit.hom_ext fun j => _)
  all_goals
    simp only [category.assoc, is_limit.cone_point_unique_up_to_iso_inv_comp]
    rcases j with ⟨⟨⟩⟩
  all_goals simp
#align
  category_theory.limits.biprod.cone_point_unique_up_to_iso_inv CategoryTheory.Limits.biprod.cone_point_unique_up_to_iso_inv

/-- Binary biproducts are unique up to isomorphism. This already follows because bilimits are
    limits, but in the case of biproducts we can give an isomorphism with particularly nice
    definitional properties, namely that `biprod.lift b.fst b.snd` and `biprod.desc b.inl b.inr`
    are inverses of each other. -/
@[simps]
def biprod.uniqueUpToIso (X Y : C) [HasBinaryBiproduct X Y] {b : BinaryBicone X Y}
    (hb : b.IsBilimit) : b.x ≅ X ⊞ Y
    where
  hom := biprod.lift b.fst b.snd
  inv := biprod.desc b.inl b.inr
  hom_inv_id' := by
    rw [← biprod.cone_point_unique_up_to_iso_hom X Y hb, ←
      biprod.cone_point_unique_up_to_iso_inv X Y hb, iso.hom_inv_id]
  inv_hom_id' := by
    rw [← biprod.cone_point_unique_up_to_iso_hom X Y hb, ←
      biprod.cone_point_unique_up_to_iso_inv X Y hb, iso.inv_hom_id]
#align category_theory.limits.biprod.unique_up_to_iso CategoryTheory.Limits.biprod.uniqueUpToIso

-- There are three further variations,
-- about `is_iso biprod.inr`, `is_iso biprod.fst` and `is_iso biprod.snd`,
-- but any one suffices to prove `indecomposable_of_simple`
-- and they are likely not separately useful.
theorem biprod.is_iso_inl_iff_id_eq_fst_comp_inl (X Y : C) [HasBinaryBiproduct X Y] :
    IsIso (biprod.inl : X ⟶ X ⊞ Y) ↔ 𝟙 (X ⊞ Y) = biprod.fst ≫ biprod.inl :=
  by
  constructor
  · intro h
    have := (cancel_epi (inv biprod.inl : X ⊞ Y ⟶ X)).2 biprod.inl_fst
    rw [is_iso.inv_hom_id_assoc, category.comp_id] at this
    rw [this, is_iso.inv_hom_id]
  · intro h
    exact ⟨⟨biprod.fst, biprod.inl_fst, h.symm⟩⟩
#align
  category_theory.limits.biprod.is_iso_inl_iff_id_eq_fst_comp_inl CategoryTheory.Limits.biprod.is_iso_inl_iff_id_eq_fst_comp_inl

section BiprodKernel

section BinaryBicone

variable {X Y : C} (c : BinaryBicone X Y)

/-- A kernel fork for the kernel of `binary_bicone.fst`. It consists of the morphism
`binary_bicone.inr`. -/
def BinaryBicone.fstKernelFork : KernelFork c.fst :=
  KernelFork.ofι c.inr c.inr_fst
#align
  category_theory.limits.binary_bicone.fst_kernel_fork CategoryTheory.Limits.BinaryBicone.fstKernelFork

@[simp]
theorem BinaryBicone.fst_kernel_fork_ι : (BinaryBicone.fstKernelFork c).ι = c.inr :=
  rfl
#align
  category_theory.limits.binary_bicone.fst_kernel_fork_ι CategoryTheory.Limits.BinaryBicone.fst_kernel_fork_ι

/-- A kernel fork for the kernel of `binary_bicone.snd`. It consists of the morphism
`binary_bicone.inl`. -/
def BinaryBicone.sndKernelFork : KernelFork c.snd :=
  KernelFork.ofι c.inl c.inl_snd
#align
  category_theory.limits.binary_bicone.snd_kernel_fork CategoryTheory.Limits.BinaryBicone.sndKernelFork

@[simp]
theorem BinaryBicone.snd_kernel_fork_ι : (BinaryBicone.sndKernelFork c).ι = c.inl :=
  rfl
#align
  category_theory.limits.binary_bicone.snd_kernel_fork_ι CategoryTheory.Limits.BinaryBicone.snd_kernel_fork_ι

/-- A cokernel cofork for the cokernel of `binary_bicone.inl`. It consists of the morphism
`binary_bicone.snd`. -/
def BinaryBicone.inlCokernelCofork : CokernelCofork c.inl :=
  CokernelCofork.ofπ c.snd c.inl_snd
#align
  category_theory.limits.binary_bicone.inl_cokernel_cofork CategoryTheory.Limits.BinaryBicone.inlCokernelCofork

@[simp]
theorem BinaryBicone.inl_cokernel_cofork_π : (BinaryBicone.inlCokernelCofork c).π = c.snd :=
  rfl
#align
  category_theory.limits.binary_bicone.inl_cokernel_cofork_π CategoryTheory.Limits.BinaryBicone.inl_cokernel_cofork_π

/-- A cokernel cofork for the cokernel of `binary_bicone.inr`. It consists of the morphism
`binary_bicone.fst`. -/
def BinaryBicone.inrCokernelCofork : CokernelCofork c.inr :=
  CokernelCofork.ofπ c.fst c.inr_fst
#align
  category_theory.limits.binary_bicone.inr_cokernel_cofork CategoryTheory.Limits.BinaryBicone.inrCokernelCofork

@[simp]
theorem BinaryBicone.inr_cokernel_cofork_π : (BinaryBicone.inrCokernelCofork c).π = c.fst :=
  rfl
#align
  category_theory.limits.binary_bicone.inr_cokernel_cofork_π CategoryTheory.Limits.BinaryBicone.inr_cokernel_cofork_π

variable {c}

/-- The fork defined in `binary_bicone.fst_kernel_fork` is indeed a kernel. -/
def BinaryBicone.isLimitFstKernelFork (i : IsLimit c.toCone) : IsLimit c.fstKernelFork :=
  (Fork.IsLimit.mk' _) fun s =>
    ⟨s.ι ≫ c.snd, by apply binary_fan.is_limit.hom_ext i <;> simp, fun m hm => by simp [← hm]⟩
#align
  category_theory.limits.binary_bicone.is_limit_fst_kernel_fork CategoryTheory.Limits.BinaryBicone.isLimitFstKernelFork

/-- The fork defined in `binary_bicone.snd_kernel_fork` is indeed a kernel. -/
def BinaryBicone.isLimitSndKernelFork (i : IsLimit c.toCone) : IsLimit c.sndKernelFork :=
  (Fork.IsLimit.mk' _) fun s =>
    ⟨s.ι ≫ c.fst, by apply binary_fan.is_limit.hom_ext i <;> simp, fun m hm => by simp [← hm]⟩
#align
  category_theory.limits.binary_bicone.is_limit_snd_kernel_fork CategoryTheory.Limits.BinaryBicone.isLimitSndKernelFork

/-- The cofork defined in `binary_bicone.inl_cokernel_cofork` is indeed a cokernel. -/
def BinaryBicone.isColimitInlCokernelCofork (i : IsColimit c.toCocone) :
    IsColimit c.inlCokernelCofork :=
  (Cofork.IsColimit.mk' _) fun s =>
    ⟨c.inr ≫ s.π, by apply binary_cofan.is_colimit.hom_ext i <;> simp, fun m hm => by simp [← hm]⟩
#align
  category_theory.limits.binary_bicone.is_colimit_inl_cokernel_cofork CategoryTheory.Limits.BinaryBicone.isColimitInlCokernelCofork

/-- The cofork defined in `binary_bicone.inr_cokernel_cofork` is indeed a cokernel. -/
def BinaryBicone.isColimitInrCokernelCofork (i : IsColimit c.toCocone) :
    IsColimit c.inrCokernelCofork :=
  (Cofork.IsColimit.mk' _) fun s =>
    ⟨c.inl ≫ s.π, by apply binary_cofan.is_colimit.hom_ext i <;> simp, fun m hm => by simp [← hm]⟩
#align
  category_theory.limits.binary_bicone.is_colimit_inr_cokernel_cofork CategoryTheory.Limits.BinaryBicone.isColimitInrCokernelCofork

end BinaryBicone

section HasBinaryBiproduct

variable (X Y : C) [HasBinaryBiproduct X Y]

/-- A kernel fork for the kernel of `biprod.fst`. It consists of the
morphism `biprod.inr`. -/
def biprod.fstKernelFork : KernelFork (biprod.fst : X ⊞ Y ⟶ X) :=
  BinaryBicone.fstKernelFork _
#align category_theory.limits.biprod.fst_kernel_fork CategoryTheory.Limits.biprod.fstKernelFork

@[simp]
theorem biprod.fst_kernel_fork_ι : Fork.ι (biprod.fstKernelFork X Y) = biprod.inr :=
  rfl
#align
  category_theory.limits.biprod.fst_kernel_fork_ι CategoryTheory.Limits.biprod.fst_kernel_fork_ι

/-- The fork `biprod.fst_kernel_fork` is indeed a limit.  -/
def biprod.isKernelFstKernelFork : IsLimit (biprod.fstKernelFork X Y) :=
  BinaryBicone.isLimitFstKernelFork (BinaryBiproduct.isLimit _ _)
#align
  category_theory.limits.biprod.is_kernel_fst_kernel_fork CategoryTheory.Limits.biprod.isKernelFstKernelFork

/-- A kernel fork for the kernel of `biprod.snd`. It consists of the
morphism `biprod.inl`. -/
def biprod.sndKernelFork : KernelFork (biprod.snd : X ⊞ Y ⟶ Y) :=
  BinaryBicone.sndKernelFork _
#align category_theory.limits.biprod.snd_kernel_fork CategoryTheory.Limits.biprod.sndKernelFork

@[simp]
theorem biprod.snd_kernel_fork_ι : Fork.ι (biprod.sndKernelFork X Y) = biprod.inl :=
  rfl
#align
  category_theory.limits.biprod.snd_kernel_fork_ι CategoryTheory.Limits.biprod.snd_kernel_fork_ι

/-- The fork `biprod.snd_kernel_fork` is indeed a limit.  -/
def biprod.isKernelSndKernelFork : IsLimit (biprod.sndKernelFork X Y) :=
  BinaryBicone.isLimitSndKernelFork (BinaryBiproduct.isLimit _ _)
#align
  category_theory.limits.biprod.is_kernel_snd_kernel_fork CategoryTheory.Limits.biprod.isKernelSndKernelFork

/-- A cokernel cofork for the cokernel of `biprod.inl`. It consists of the
morphism `biprod.snd`. -/
def biprod.inlCokernelCofork : CokernelCofork (biprod.inl : X ⟶ X ⊞ Y) :=
  BinaryBicone.inlCokernelCofork _
#align
  category_theory.limits.biprod.inl_cokernel_cofork CategoryTheory.Limits.biprod.inlCokernelCofork

@[simp]
theorem biprod.inl_cokernel_cofork_π : Cofork.π (biprod.inlCokernelCofork X Y) = biprod.snd :=
  rfl
#align
  category_theory.limits.biprod.inl_cokernel_cofork_π CategoryTheory.Limits.biprod.inl_cokernel_cofork_π

/-- The cofork `biprod.inl_cokernel_fork` is indeed a colimit.  -/
def biprod.isCokernelInlCokernelFork : IsColimit (biprod.inlCokernelCofork X Y) :=
  BinaryBicone.isColimitInlCokernelCofork (BinaryBiproduct.isColimit _ _)
#align
  category_theory.limits.biprod.is_cokernel_inl_cokernel_fork CategoryTheory.Limits.biprod.isCokernelInlCokernelFork

/-- A cokernel cofork for the cokernel of `biprod.inr`. It consists of the
morphism `biprod.fst`. -/
def biprod.inrCokernelCofork : CokernelCofork (biprod.inr : Y ⟶ X ⊞ Y) :=
  BinaryBicone.inrCokernelCofork _
#align
  category_theory.limits.biprod.inr_cokernel_cofork CategoryTheory.Limits.biprod.inrCokernelCofork

@[simp]
theorem biprod.inr_cokernel_cofork_π : Cofork.π (biprod.inrCokernelCofork X Y) = biprod.fst :=
  rfl
#align
  category_theory.limits.biprod.inr_cokernel_cofork_π CategoryTheory.Limits.biprod.inr_cokernel_cofork_π

/-- The cofork `biprod.inr_cokernel_fork` is indeed a colimit.  -/
def biprod.isCokernelInrCokernelFork : IsColimit (biprod.inrCokernelCofork X Y) :=
  BinaryBicone.isColimitInrCokernelCofork (BinaryBiproduct.isColimit _ _)
#align
  category_theory.limits.biprod.is_cokernel_inr_cokernel_fork CategoryTheory.Limits.biprod.isCokernelInrCokernelFork

end HasBinaryBiproduct

variable {X Y : C} [HasBinaryBiproduct X Y]

instance : HasKernel (biprod.fst : X ⊞ Y ⟶ X) :=
  HasLimit.mk ⟨_, biprod.isKernelFstKernelFork X Y⟩

/-- The kernel of `biprod.fst : X ⊞ Y ⟶ X` is `Y`. -/
@[simps]
def kernelBiprodFstIso : kernel (biprod.fst : X ⊞ Y ⟶ X) ≅ Y :=
  limit.isoLimitCone ⟨_, biprod.isKernelFstKernelFork X Y⟩
#align category_theory.limits.kernel_biprod_fst_iso CategoryTheory.Limits.kernelBiprodFstIso

instance : HasKernel (biprod.snd : X ⊞ Y ⟶ Y) :=
  HasLimit.mk ⟨_, biprod.isKernelSndKernelFork X Y⟩

/-- The kernel of `biprod.snd : X ⊞ Y ⟶ Y` is `X`. -/
@[simps]
def kernelBiprodSndIso : kernel (biprod.snd : X ⊞ Y ⟶ Y) ≅ X :=
  limit.isoLimitCone ⟨_, biprod.isKernelSndKernelFork X Y⟩
#align category_theory.limits.kernel_biprod_snd_iso CategoryTheory.Limits.kernelBiprodSndIso

instance : HasCokernel (biprod.inl : X ⟶ X ⊞ Y) :=
  HasColimit.mk ⟨_, biprod.isCokernelInlCokernelFork X Y⟩

/-- The cokernel of `biprod.inl : X ⟶ X ⊞ Y` is `Y`. -/
@[simps]
def cokernelBiprodInlIso : cokernel (biprod.inl : X ⟶ X ⊞ Y) ≅ Y :=
  colimit.isoColimitCocone ⟨_, biprod.isCokernelInlCokernelFork X Y⟩
#align category_theory.limits.cokernel_biprod_inl_iso CategoryTheory.Limits.cokernelBiprodInlIso

instance : HasCokernel (biprod.inr : Y ⟶ X ⊞ Y) :=
  HasColimit.mk ⟨_, biprod.isCokernelInrCokernelFork X Y⟩

/-- The cokernel of `biprod.inr : Y ⟶ X ⊞ Y` is `X`. -/
@[simps]
def cokernelBiprodInrIso : cokernel (biprod.inr : Y ⟶ X ⊞ Y) ≅ X :=
  colimit.isoColimitCocone ⟨_, biprod.isCokernelInrCokernelFork X Y⟩
#align category_theory.limits.cokernel_biprod_inr_iso CategoryTheory.Limits.cokernelBiprodInrIso

end BiprodKernel

section IsZero

/-- If `Y` is a zero object, `X ≅ X ⊞ Y` for any `X`. -/
@[simps]
def isoBiprodZero {X Y : C} [HasBinaryBiproduct X Y] (hY : IsZero Y) : X ≅ X ⊞ Y
    where
  hom := biprod.inl
  inv := biprod.fst
  inv_hom_id' :=
    by
    apply CategoryTheory.Limits.biprod.hom_ext <;>
      simp only [category.assoc, biprod.inl_fst, category.comp_id, category.id_comp, biprod.inl_snd,
        comp_zero]
    apply hY.eq_of_tgt
#align category_theory.limits.iso_biprod_zero CategoryTheory.Limits.isoBiprodZero

/-- If `X` is a zero object, `Y ≅ X ⊞ Y` for any `Y`. -/
@[simps]
def isoZeroBiprod {X Y : C} [HasBinaryBiproduct X Y] (hY : IsZero X) : Y ≅ X ⊞ Y
    where
  hom := biprod.inr
  inv := biprod.snd
  inv_hom_id' :=
    by
    apply CategoryTheory.Limits.biprod.hom_ext <;>
      simp only [category.assoc, biprod.inr_snd, category.comp_id, category.id_comp, biprod.inr_fst,
        comp_zero]
    apply hY.eq_of_tgt
#align category_theory.limits.iso_zero_biprod CategoryTheory.Limits.isoZeroBiprod

end IsZero

section

variable [HasBinaryBiproducts C]

/-- The braiding isomorphism which swaps a binary biproduct. -/
@[simps]
def biprod.braiding (P Q : C) : P ⊞ Q ≅ Q ⊞ P
    where
  hom := biprod.lift biprod.snd biprod.fst
  inv := biprod.lift biprod.snd biprod.fst
#align category_theory.limits.biprod.braiding CategoryTheory.Limits.biprod.braiding

/-- An alternative formula for the braiding isomorphism which swaps a binary biproduct,
using the fact that the biproduct is a coproduct.
-/
@[simps]
def biprod.braiding' (P Q : C) : P ⊞ Q ≅ Q ⊞ P
    where
  hom := biprod.desc biprod.inr biprod.inl
  inv := biprod.desc biprod.inr biprod.inl
#align category_theory.limits.biprod.braiding' CategoryTheory.Limits.biprod.braiding'

theorem biprod.braiding'_eq_braiding {P Q : C} : biprod.braiding' P Q = biprod.braiding P Q := by
  tidy
#align
  category_theory.limits.biprod.braiding'_eq_braiding CategoryTheory.Limits.biprod.braiding'_eq_braiding

/-- The braiding isomorphism can be passed through a map by swapping the order. -/
@[reassoc.1]
theorem biprod.braid_natural {W X Y Z : C} (f : X ⟶ Y) (g : Z ⟶ W) :
    biprod.map f g ≫ (biprod.braiding _ _).hom = (biprod.braiding _ _).hom ≫ biprod.map g f := by
  tidy
#align category_theory.limits.biprod.braid_natural CategoryTheory.Limits.biprod.braid_natural

@[reassoc.1]
theorem biprod.braiding_map_braiding {W X Y Z : C} (f : W ⟶ Y) (g : X ⟶ Z) :
    (biprod.braiding X W).hom ≫ biprod.map f g ≫ (biprod.braiding Y Z).hom = biprod.map g f := by
  tidy
#align
  category_theory.limits.biprod.braiding_map_braiding CategoryTheory.Limits.biprod.braiding_map_braiding

@[simp, reassoc.1]
theorem biprod.symmetry' (P Q : C) :
    biprod.lift biprod.snd biprod.fst ≫ biprod.lift biprod.snd biprod.fst = 𝟙 (P ⊞ Q) := by tidy
#align category_theory.limits.biprod.symmetry' CategoryTheory.Limits.biprod.symmetry'

/-- The braiding isomorphism is symmetric. -/
@[reassoc.1]
theorem biprod.symmetry (P Q : C) : (biprod.braiding P Q).hom ≫ (biprod.braiding Q P).hom = 𝟙 _ :=
  by simp
#align category_theory.limits.biprod.symmetry CategoryTheory.Limits.biprod.symmetry

end

end Limits

open CategoryTheory.Limits

-- TODO:
-- If someone is interested, they could provide the constructions:
--   has_binary_biproducts ↔ has_finite_biproducts
variable {C : Type u} [Category.{v} C] [HasZeroMorphisms C] [HasBinaryBiproducts C]

/-- An object is indecomposable if it cannot be written as the biproduct of two nonzero objects. -/
def Indecomposable (X : C) : Prop :=
  ¬IsZero X ∧ ∀ Y Z, (X ≅ Y ⊞ Z) → IsZero Y ∨ IsZero Z
#align category_theory.indecomposable CategoryTheory.Indecomposable

/-- If
```
(f 0)
(0 g)
```
is invertible, then `f` is invertible.
-/
theorem is_iso_left_of_is_iso_biprod_map {W X Y Z : C} (f : W ⟶ Y) (g : X ⟶ Z)
    [IsIso (biprod.map f g)] : IsIso f :=
  ⟨⟨biprod.inl ≫ inv (biprod.map f g) ≫ biprod.fst,
      ⟨by
        have t :=
          congr_arg (fun p : W ⊞ X ⟶ W ⊞ X => biprod.inl ≫ p ≫ biprod.fst)
            (is_iso.hom_inv_id (biprod.map f g))
        simp only [category.id_comp, category.assoc, biprod.inl_map_assoc] at t
        simp [t],
        by
        have t :=
          congr_arg (fun p : Y ⊞ Z ⟶ Y ⊞ Z => biprod.inl ≫ p ≫ biprod.fst)
            (is_iso.inv_hom_id (biprod.map f g))
        simp only [category.id_comp, category.assoc, biprod.map_fst] at t
        simp only [category.assoc]
        simp [t]⟩⟩⟩
#align
  category_theory.is_iso_left_of_is_iso_biprod_map CategoryTheory.is_iso_left_of_is_iso_biprod_map

/-- If
```
(f 0)
(0 g)
```
is invertible, then `g` is invertible.
-/
theorem is_iso_right_of_is_iso_biprod_map {W X Y Z : C} (f : W ⟶ Y) (g : X ⟶ Z)
    [IsIso (biprod.map f g)] : IsIso g :=
  letI : is_iso (biprod.map g f) :=
    by
    rw [← biprod.braiding_map_braiding]
    infer_instance
  is_iso_left_of_is_iso_biprod_map g f
#align
  category_theory.is_iso_right_of_is_iso_biprod_map CategoryTheory.is_iso_right_of_is_iso_biprod_map

end CategoryTheory

