/-
Copyright (c) 2018 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Reid Barton, Mario Carneiro, Scott Morrison, Floris van Doorn

! This file was ported from Lean 3 source module category_theory.limits.is_limit
! leanprover-community/mathlib commit ee05e9ce1322178f0c12004eb93c00d2c8c00ed2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Adjunction.Basic
import Mathbin.CategoryTheory.Limits.Cones

/-!
# Limits and colimits

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We set up the general theory of limits and colimits in a category.
In this introduction we only describe the setup for limits;
it is repeated, with slightly different names, for colimits.

The main structures defined in this file is
* `is_limit c`, for `c : cone F`, `F : J ⥤ C`, expressing that `c` is a limit cone,

See also `category_theory.limits.has_limits` which further builds:
* `limit_cone F`, which consists of a choice of cone for `F` and the fact it is a limit cone, and
* `has_limit F`, asserting the mere existence of some limit cone for `F`.

## Implementation
At present we simply say everything twice, in order to handle both limits and colimits.
It would be highly desirable to have some automation support,
e.g. a `@[dualize]` attribute that behaves similarly to `@[to_additive]`.

## References
* [Stacks: Limits and colimits](https://stacks.math.columbia.edu/tag/002D)

-/


noncomputable section

open CategoryTheory CategoryTheory.Category CategoryTheory.Functor Opposite

namespace CategoryTheory.Limits

-- declare the `v`'s first; see `category_theory.category` for an explanation
universe v₁ v₂ v₃ v₄ u₁ u₂ u₃ u₄

variable {J : Type u₁} [Category.{v₁} J] {K : Type u₂} [Category.{v₂} K]

variable {C : Type u₃} [Category.{v₃} C]

variable {F : J ⥤ C}

#print CategoryTheory.Limits.IsLimit /-
/-- A cone `t` on `F` is a limit cone if each cone on `F` admits a unique
cone morphism to `t`.

See <https://stacks.math.columbia.edu/tag/002E>.
  -/
@[nolint has_nonempty_instance]
structure IsLimit (t : Cone F) where
  lift : ∀ s : Cone F, s.pt ⟶ t.pt
  fac : ∀ (s : Cone F) (j : J), lift s ≫ t.π.app j = s.π.app j := by obviously
  uniq : ∀ (s : Cone F) (m : s.pt ⟶ t.pt) (w : ∀ j : J, m ≫ t.π.app j = s.π.app j), m = lift s := by
    obviously
#align category_theory.limits.is_limit CategoryTheory.Limits.IsLimit
-/

restate_axiom is_limit.fac'

attribute [simp, reassoc] is_limit.fac

restate_axiom is_limit.uniq'

namespace IsLimit

#print CategoryTheory.Limits.IsLimit.subsingleton /-
instance subsingleton {t : Cone F} : Subsingleton (IsLimit t) :=
  ⟨by intro P Q <;> cases P <;> cases Q <;> congr <;> ext <;> solve_by_elim⟩
#align category_theory.limits.is_limit.subsingleton CategoryTheory.Limits.IsLimit.subsingleton
-/

#print CategoryTheory.Limits.IsLimit.map /-
/-- Given a natural transformation `α : F ⟶ G`, we give a morphism from the cone point
of any cone over `F` to the cone point of a limit cone over `G`. -/
def map {F G : J ⥤ C} (s : Cone F) {t : Cone G} (P : IsLimit t) (α : F ⟶ G) : s.pt ⟶ t.pt :=
  P.lift ((Cones.postcompose α).obj s)
#align category_theory.limits.is_limit.map CategoryTheory.Limits.IsLimit.map
-/

#print CategoryTheory.Limits.IsLimit.map_π /-
@[simp, reassoc]
theorem map_π {F G : J ⥤ C} (c : Cone F) {d : Cone G} (hd : IsLimit d) (α : F ⟶ G) (j : J) :
    hd.map c α ≫ d.π.app j = c.π.app j ≫ α.app j :=
  fac _ _ _
#align category_theory.limits.is_limit.map_π CategoryTheory.Limits.IsLimit.map_π
-/

#print CategoryTheory.Limits.IsLimit.lift_self /-
theorem lift_self {c : Cone F} (t : IsLimit c) : t.lift c = 𝟙 c.pt :=
  (t.uniq _ _ fun j => id_comp _).symm
#align category_theory.limits.is_limit.lift_self CategoryTheory.Limits.IsLimit.lift_self
-/

#print CategoryTheory.Limits.IsLimit.liftConeMorphism /-
-- Repackaging the definition in terms of cone morphisms.
/-- The universal morphism from any other cone to a limit cone. -/
@[simps]
def liftConeMorphism {t : Cone F} (h : IsLimit t) (s : Cone F) : s ⟶ t where Hom := h.lift s
#align category_theory.limits.is_limit.lift_cone_morphism CategoryTheory.Limits.IsLimit.liftConeMorphism
-/

#print CategoryTheory.Limits.IsLimit.uniq_cone_morphism /-
theorem uniq_cone_morphism {s t : Cone F} (h : IsLimit t) {f f' : s ⟶ t} : f = f' :=
  have : ∀ {g : s ⟶ t}, g = h.liftConeMorphism s := by intro g <;> ext <;> exact h.uniq _ _ g.w
  this.trans this.symm
#align category_theory.limits.is_limit.uniq_cone_morphism CategoryTheory.Limits.IsLimit.uniq_cone_morphism
-/

#print CategoryTheory.Limits.IsLimit.existsUnique /-
/-- Restating the definition of a limit cone in terms of the ∃! operator. -/
theorem existsUnique {t : Cone F} (h : IsLimit t) (s : Cone F) :
    ∃! l : s.pt ⟶ t.pt, ∀ j, l ≫ t.π.app j = s.π.app j :=
  ⟨h.lift s, h.fac s, h.uniq s⟩
#align category_theory.limits.is_limit.exists_unique CategoryTheory.Limits.IsLimit.existsUnique
-/

#print CategoryTheory.Limits.IsLimit.ofExistsUnique /-
/-- Noncomputably make a colimit cocone from the existence of unique factorizations. -/
def ofExistsUnique {t : Cone F}
    (ht : ∀ s : Cone F, ∃! l : s.pt ⟶ t.pt, ∀ j, l ≫ t.π.app j = s.π.app j) : IsLimit t := by
  choose s hs hs' using ht; exact ⟨s, hs, hs'⟩
#align category_theory.limits.is_limit.of_exists_unique CategoryTheory.Limits.IsLimit.ofExistsUnique
-/

#print CategoryTheory.Limits.IsLimit.mkConeMorphism /-
/-- Alternative constructor for `is_limit`,
providing a morphism of cones rather than a morphism between the cone points
and separately the factorisation condition.
-/
@[simps]
def mkConeMorphism {t : Cone F} (lift : ∀ s : Cone F, s ⟶ t)
    (uniq' : ∀ (s : Cone F) (m : s ⟶ t), m = lift s) : IsLimit t
    where
  lift s := (lift s).Hom
  uniq s m w :=
    have : ConeMorphism.mk m w = lift s := by apply uniq'
    congr_arg ConeMorphism.hom this
#align category_theory.limits.is_limit.mk_cone_morphism CategoryTheory.Limits.IsLimit.mkConeMorphism
-/

#print CategoryTheory.Limits.IsLimit.uniqueUpToIso /-
/-- Limit cones on `F` are unique up to isomorphism. -/
@[simps]
def uniqueUpToIso {s t : Cone F} (P : IsLimit s) (Q : IsLimit t) : s ≅ t
    where
  Hom := Q.liftConeMorphism s
  inv := P.liftConeMorphism t
  hom_inv_id' := P.uniq_cone_morphism
  inv_hom_id' := Q.uniq_cone_morphism
#align category_theory.limits.is_limit.unique_up_to_iso CategoryTheory.Limits.IsLimit.uniqueUpToIso
-/

#print CategoryTheory.Limits.IsLimit.hom_isIso /-
/-- Any cone morphism between limit cones is an isomorphism. -/
theorem hom_isIso {s t : Cone F} (P : IsLimit s) (Q : IsLimit t) (f : s ⟶ t) : IsIso f :=
  ⟨⟨P.liftConeMorphism t, ⟨P.uniq_cone_morphism, Q.uniq_cone_morphism⟩⟩⟩
#align category_theory.limits.is_limit.hom_is_iso CategoryTheory.Limits.IsLimit.hom_isIso
-/

#print CategoryTheory.Limits.IsLimit.conePointUniqueUpToIso /-
/-- Limits of `F` are unique up to isomorphism. -/
def conePointUniqueUpToIso {s t : Cone F} (P : IsLimit s) (Q : IsLimit t) : s.pt ≅ t.pt :=
  (Cones.forget F).mapIso (uniqueUpToIso P Q)
#align category_theory.limits.is_limit.cone_point_unique_up_to_iso CategoryTheory.Limits.IsLimit.conePointUniqueUpToIso
-/

#print CategoryTheory.Limits.IsLimit.conePointUniqueUpToIso_hom_comp /-
@[simp, reassoc]
theorem conePointUniqueUpToIso_hom_comp {s t : Cone F} (P : IsLimit s) (Q : IsLimit t) (j : J) :
    (conePointUniqueUpToIso P Q).Hom ≫ t.π.app j = s.π.app j :=
  (uniqueUpToIso P Q).Hom.w _
#align category_theory.limits.is_limit.cone_point_unique_up_to_iso_hom_comp CategoryTheory.Limits.IsLimit.conePointUniqueUpToIso_hom_comp
-/

#print CategoryTheory.Limits.IsLimit.conePointUniqueUpToIso_inv_comp /-
@[simp, reassoc]
theorem conePointUniqueUpToIso_inv_comp {s t : Cone F} (P : IsLimit s) (Q : IsLimit t) (j : J) :
    (conePointUniqueUpToIso P Q).inv ≫ s.π.app j = t.π.app j :=
  (uniqueUpToIso P Q).inv.w _
#align category_theory.limits.is_limit.cone_point_unique_up_to_iso_inv_comp CategoryTheory.Limits.IsLimit.conePointUniqueUpToIso_inv_comp
-/

#print CategoryTheory.Limits.IsLimit.lift_comp_conePointUniqueUpToIso_hom /-
@[simp, reassoc]
theorem lift_comp_conePointUniqueUpToIso_hom {r s t : Cone F} (P : IsLimit s) (Q : IsLimit t) :
    P.lift r ≫ (conePointUniqueUpToIso P Q).Hom = Q.lift r :=
  Q.uniq _ _ (by simp)
#align category_theory.limits.is_limit.lift_comp_cone_point_unique_up_to_iso_hom CategoryTheory.Limits.IsLimit.lift_comp_conePointUniqueUpToIso_hom
-/

#print CategoryTheory.Limits.IsLimit.lift_comp_conePointUniqueUpToIso_inv /-
@[simp, reassoc]
theorem lift_comp_conePointUniqueUpToIso_inv {r s t : Cone F} (P : IsLimit s) (Q : IsLimit t) :
    Q.lift r ≫ (conePointUniqueUpToIso P Q).inv = P.lift r :=
  P.uniq _ _ (by simp)
#align category_theory.limits.is_limit.lift_comp_cone_point_unique_up_to_iso_inv CategoryTheory.Limits.IsLimit.lift_comp_conePointUniqueUpToIso_inv
-/

#print CategoryTheory.Limits.IsLimit.ofIsoLimit /-
/-- Transport evidence that a cone is a limit cone across an isomorphism of cones. -/
def ofIsoLimit {r t : Cone F} (P : IsLimit r) (i : r ≅ t) : IsLimit t :=
  IsLimit.mkConeMorphism (fun s => P.liftConeMorphism s ≫ i.Hom) fun s m => by
    rw [← i.comp_inv_eq] <;> apply P.uniq_cone_morphism
#align category_theory.limits.is_limit.of_iso_limit CategoryTheory.Limits.IsLimit.ofIsoLimit
-/

#print CategoryTheory.Limits.IsLimit.ofIsoLimit_lift /-
@[simp]
theorem ofIsoLimit_lift {r t : Cone F} (P : IsLimit r) (i : r ≅ t) (s) :
    (P.ofIsoLimit i).lift s = P.lift s ≫ i.Hom.Hom :=
  rfl
#align category_theory.limits.is_limit.of_iso_limit_lift CategoryTheory.Limits.IsLimit.ofIsoLimit_lift
-/

#print CategoryTheory.Limits.IsLimit.equivIsoLimit /-
/-- Isomorphism of cones preserves whether or not they are limiting cones. -/
def equivIsoLimit {r t : Cone F} (i : r ≅ t) : IsLimit r ≃ IsLimit t
    where
  toFun h := h.ofIsoLimit i
  invFun h := h.ofIsoLimit i.symm
  left_inv := by tidy
  right_inv := by tidy
#align category_theory.limits.is_limit.equiv_iso_limit CategoryTheory.Limits.IsLimit.equivIsoLimit
-/

#print CategoryTheory.Limits.IsLimit.equivIsoLimit_apply /-
@[simp]
theorem equivIsoLimit_apply {r t : Cone F} (i : r ≅ t) (P : IsLimit r) :
    equivIsoLimit i P = P.ofIsoLimit i :=
  rfl
#align category_theory.limits.is_limit.equiv_iso_limit_apply CategoryTheory.Limits.IsLimit.equivIsoLimit_apply
-/

#print CategoryTheory.Limits.IsLimit.equivIsoLimit_symm_apply /-
@[simp]
theorem equivIsoLimit_symm_apply {r t : Cone F} (i : r ≅ t) (P : IsLimit t) :
    (equivIsoLimit i).symm P = P.ofIsoLimit i.symm :=
  rfl
#align category_theory.limits.is_limit.equiv_iso_limit_symm_apply CategoryTheory.Limits.IsLimit.equivIsoLimit_symm_apply
-/

#print CategoryTheory.Limits.IsLimit.ofPointIso /-
/-- If the canonical morphism from a cone point to a limiting cone point is an iso, then the
first cone was limiting also.
-/
def ofPointIso {r t : Cone F} (P : IsLimit r) [i : IsIso (P.lift t)] : IsLimit t :=
  ofIsoLimit P
    (by
      haveI : is_iso (P.lift_cone_morphism t).Hom := i
      haveI : is_iso (P.lift_cone_morphism t) := cones.cone_iso_of_hom_iso _
      symm
      apply as_iso (P.lift_cone_morphism t))
#align category_theory.limits.is_limit.of_point_iso CategoryTheory.Limits.IsLimit.ofPointIso
-/

variable {t : Cone F}

#print CategoryTheory.Limits.IsLimit.hom_lift /-
theorem hom_lift (h : IsLimit t) {W : C} (m : W ⟶ t.pt) :
    m =
      h.lift
        { pt := W
          π := { app := fun b => m ≫ t.π.app b } } :=
  h.uniq
    { pt := W
      π := { app := fun b => m ≫ t.π.app b } } m fun b => rfl
#align category_theory.limits.is_limit.hom_lift CategoryTheory.Limits.IsLimit.hom_lift
-/

#print CategoryTheory.Limits.IsLimit.hom_ext /-
/-- Two morphisms into a limit are equal if their compositions with
  each cone morphism are equal. -/
theorem hom_ext (h : IsLimit t) {W : C} {f f' : W ⟶ t.pt}
    (w : ∀ j, f ≫ t.π.app j = f' ≫ t.π.app j) : f = f' := by
  rw [h.hom_lift f, h.hom_lift f'] <;> congr <;> exact funext w
#align category_theory.limits.is_limit.hom_ext CategoryTheory.Limits.IsLimit.hom_ext
-/

#print CategoryTheory.Limits.IsLimit.ofRightAdjoint /-
/-- Given a right adjoint functor between categories of cones,
the image of a limit cone is a limit cone.
-/
def ofRightAdjoint {D : Type u₄} [Category.{v₄} D] {G : K ⥤ D} (h : Cone G ⥤ Cone F)
    [IsRightAdjoint h] {c : Cone G} (t : IsLimit c) : IsLimit (h.obj c) :=
  mkConeMorphism (fun s => (Adjunction.ofRightAdjoint h).homEquiv s c (t.liftConeMorphism _))
    fun s m => (Adjunction.eq_homEquiv_apply _ _ _).2 t.uniq_cone_morphism
#align category_theory.limits.is_limit.of_right_adjoint CategoryTheory.Limits.IsLimit.ofRightAdjoint
-/

#print CategoryTheory.Limits.IsLimit.ofConeEquiv /-
/-- Given two functors which have equivalent categories of cones, we can transport a limiting cone
across the equivalence.
-/
def ofConeEquiv {D : Type u₄} [Category.{v₄} D] {G : K ⥤ D} (h : Cone G ≌ Cone F) {c : Cone G} :
    IsLimit (h.Functor.obj c) ≃ IsLimit c
    where
  toFun P := ofIsoLimit (ofRightAdjoint h.inverse P) (h.unitIso.symm.app c)
  invFun := ofRightAdjoint h.Functor
  left_inv := by tidy
  right_inv := by tidy
#align category_theory.limits.is_limit.of_cone_equiv CategoryTheory.Limits.IsLimit.ofConeEquiv
-/

#print CategoryTheory.Limits.IsLimit.ofConeEquiv_apply_desc /-
@[simp]
theorem ofConeEquiv_apply_desc {D : Type u₄} [Category.{v₄} D] {G : K ⥤ D} (h : Cone G ≌ Cone F)
    {c : Cone G} (P : IsLimit (h.Functor.obj c)) (s) :
    (ofConeEquiv h P).lift s =
      ((h.unitIso.Hom.app s).Hom ≫ (h.Functor.inv.map (P.liftConeMorphism (h.Functor.obj s))).Hom) ≫
        (h.unitIso.inv.app c).Hom :=
  rfl
#align category_theory.limits.is_limit.of_cone_equiv_apply_desc CategoryTheory.Limits.IsLimit.ofConeEquiv_apply_desc
-/

#print CategoryTheory.Limits.IsLimit.ofConeEquiv_symm_apply_desc /-
@[simp]
theorem ofConeEquiv_symm_apply_desc {D : Type u₄} [Category.{v₄} D] {G : K ⥤ D}
    (h : Cone G ≌ Cone F) {c : Cone G} (P : IsLimit c) (s) :
    ((ofConeEquiv h).symm P).lift s =
      (h.counitIso.inv.app s).Hom ≫ (h.Functor.map (P.liftConeMorphism (h.inverse.obj s))).Hom :=
  rfl
#align category_theory.limits.is_limit.of_cone_equiv_symm_apply_desc CategoryTheory.Limits.IsLimit.ofConeEquiv_symm_apply_desc
-/

#print CategoryTheory.Limits.IsLimit.postcomposeHomEquiv /-
/--
A cone postcomposed with a natural isomorphism is a limit cone if and only if the original cone is.
-/
def postcomposeHomEquiv {F G : J ⥤ C} (α : F ≅ G) (c : Cone F) :
    IsLimit ((Cones.postcompose α.Hom).obj c) ≃ IsLimit c :=
  ofConeEquiv (Cones.postcomposeEquivalence α)
#align category_theory.limits.is_limit.postcompose_hom_equiv CategoryTheory.Limits.IsLimit.postcomposeHomEquiv
-/

#print CategoryTheory.Limits.IsLimit.postcomposeInvEquiv /-
/-- A cone postcomposed with the inverse of a natural isomorphism is a limit cone if and only if
the original cone is.
-/
def postcomposeInvEquiv {F G : J ⥤ C} (α : F ≅ G) (c : Cone G) :
    IsLimit ((Cones.postcompose α.inv).obj c) ≃ IsLimit c :=
  postcomposeHomEquiv α.symm c
#align category_theory.limits.is_limit.postcompose_inv_equiv CategoryTheory.Limits.IsLimit.postcomposeInvEquiv
-/

#print CategoryTheory.Limits.IsLimit.equivOfNatIsoOfIso /-
/-- Constructing an equivalence `is_limit c ≃ is_limit d` from a natural isomorphism
between the underlying functors, and then an isomorphism between `c` transported along this and `d`.
-/
def equivOfNatIsoOfIso {F G : J ⥤ C} (α : F ≅ G) (c : Cone F) (d : Cone G)
    (w : (Cones.postcompose α.Hom).obj c ≅ d) : IsLimit c ≃ IsLimit d :=
  (postcomposeHomEquiv α _).symm.trans (equivIsoLimit w)
#align category_theory.limits.is_limit.equiv_of_nat_iso_of_iso CategoryTheory.Limits.IsLimit.equivOfNatIsoOfIso
-/

#print CategoryTheory.Limits.IsLimit.conePointsIsoOfNatIso /-
/-- The cone points of two limit cones for naturally isomorphic functors
are themselves isomorphic.
-/
@[simps]
def conePointsIsoOfNatIso {F G : J ⥤ C} {s : Cone F} {t : Cone G} (P : IsLimit s) (Q : IsLimit t)
    (w : F ≅ G) : s.pt ≅ t.pt where
  Hom := Q.map s w.Hom
  inv := P.map t w.inv
  hom_inv_id' := P.hom_ext (by tidy)
  inv_hom_id' := Q.hom_ext (by tidy)
#align category_theory.limits.is_limit.cone_points_iso_of_nat_iso CategoryTheory.Limits.IsLimit.conePointsIsoOfNatIso
-/

#print CategoryTheory.Limits.IsLimit.conePointsIsoOfNatIso_hom_comp /-
@[reassoc]
theorem conePointsIsoOfNatIso_hom_comp {F G : J ⥤ C} {s : Cone F} {t : Cone G} (P : IsLimit s)
    (Q : IsLimit t) (w : F ≅ G) (j : J) :
    (conePointsIsoOfNatIso P Q w).Hom ≫ t.π.app j = s.π.app j ≫ w.Hom.app j := by simp
#align category_theory.limits.is_limit.cone_points_iso_of_nat_iso_hom_comp CategoryTheory.Limits.IsLimit.conePointsIsoOfNatIso_hom_comp
-/

#print CategoryTheory.Limits.IsLimit.conePointsIsoOfNatIso_inv_comp /-
@[reassoc]
theorem conePointsIsoOfNatIso_inv_comp {F G : J ⥤ C} {s : Cone F} {t : Cone G} (P : IsLimit s)
    (Q : IsLimit t) (w : F ≅ G) (j : J) :
    (conePointsIsoOfNatIso P Q w).inv ≫ s.π.app j = t.π.app j ≫ w.inv.app j := by simp
#align category_theory.limits.is_limit.cone_points_iso_of_nat_iso_inv_comp CategoryTheory.Limits.IsLimit.conePointsIsoOfNatIso_inv_comp
-/

#print CategoryTheory.Limits.IsLimit.lift_comp_conePointsIsoOfNatIso_hom /-
@[reassoc]
theorem lift_comp_conePointsIsoOfNatIso_hom {F G : J ⥤ C} {r s : Cone F} {t : Cone G}
    (P : IsLimit s) (Q : IsLimit t) (w : F ≅ G) :
    P.lift r ≫ (conePointsIsoOfNatIso P Q w).Hom = Q.map r w.Hom :=
  Q.hom_ext (by simp)
#align category_theory.limits.is_limit.lift_comp_cone_points_iso_of_nat_iso_hom CategoryTheory.Limits.IsLimit.lift_comp_conePointsIsoOfNatIso_hom
-/

#print CategoryTheory.Limits.IsLimit.lift_comp_conePointsIsoOfNatIso_inv /-
@[reassoc]
theorem lift_comp_conePointsIsoOfNatIso_inv {F G : J ⥤ C} {r s : Cone G} {t : Cone F}
    (P : IsLimit t) (Q : IsLimit s) (w : F ≅ G) :
    Q.lift r ≫ (conePointsIsoOfNatIso P Q w).inv = P.map r w.inv :=
  P.hom_ext (by simp)
#align category_theory.limits.is_limit.lift_comp_cone_points_iso_of_nat_iso_inv CategoryTheory.Limits.IsLimit.lift_comp_conePointsIsoOfNatIso_inv
-/

section Equivalence

open CategoryTheory.Equivalence

#print CategoryTheory.Limits.IsLimit.whiskerEquivalence /-
/-- If `s : cone F` is a limit cone, so is `s` whiskered by an equivalence `e`.
-/
def whiskerEquivalence {s : Cone F} (P : IsLimit s) (e : K ≌ J) : IsLimit (s.whisker e.Functor) :=
  ofRightAdjoint (Cones.whiskeringEquivalence e).Functor P
#align category_theory.limits.is_limit.whisker_equivalence CategoryTheory.Limits.IsLimit.whiskerEquivalence
-/

#print CategoryTheory.Limits.IsLimit.ofWhiskerEquivalence /-
/-- If `s : cone F` whiskered by an equivalence `e` is a limit cone, so is `s`.
-/
def ofWhiskerEquivalence {s : Cone F} (e : K ≌ J) (P : IsLimit (s.whisker e.Functor)) : IsLimit s :=
  equivIsoLimit ((Cones.whiskeringEquivalence e).unitIso.app s).symm
    (ofRightAdjoint (Cones.whiskeringEquivalence e).inverse P : _)
#align category_theory.limits.is_limit.of_whisker_equivalence CategoryTheory.Limits.IsLimit.ofWhiskerEquivalence
-/

#print CategoryTheory.Limits.IsLimit.whiskerEquivalenceEquiv /-
/-- Given an equivalence of diagrams `e`, `s` is a limit cone iff `s.whisker e.functor` is.
-/
def whiskerEquivalenceEquiv {s : Cone F} (e : K ≌ J) : IsLimit s ≃ IsLimit (s.whisker e.Functor) :=
  ⟨fun h => h.whiskerEquivalence e, ofWhiskerEquivalence e, by tidy, by tidy⟩
#align category_theory.limits.is_limit.whisker_equivalence_equiv CategoryTheory.Limits.IsLimit.whiskerEquivalenceEquiv
-/

#print CategoryTheory.Limits.IsLimit.conePointsIsoOfEquivalence /-
/-- We can prove two cone points `(s : cone F).X` and `(t.cone G).X` are isomorphic if
* both cones are limit cones
* their indexing categories are equivalent via some `e : J ≌ K`,
* the triangle of functors commutes up to a natural isomorphism: `e.functor ⋙ G ≅ F`.

This is the most general form of uniqueness of cone points,
allowing relabelling of both the indexing category (up to equivalence)
and the functor (up to natural isomorphism).
-/
@[simps]
def conePointsIsoOfEquivalence {F : J ⥤ C} {s : Cone F} {G : K ⥤ C} {t : Cone G} (P : IsLimit s)
    (Q : IsLimit t) (e : J ≌ K) (w : e.Functor ⋙ G ≅ F) : s.pt ≅ t.pt :=
  let w' : e.inverse ⋙ F ≅ G := (isoWhiskerLeft e.inverse w).symm ≪≫ invFunIdAssoc e G
  { Hom := Q.lift ((Cones.equivalenceOfReindexing e.symm w').Functor.obj s)
    inv := P.lift ((Cones.equivalenceOfReindexing e w).Functor.obj t)
    hom_inv_id' := by
      apply hom_ext P; intro j
      dsimp
      simp only [limits.cone.whisker_π, limits.cones.postcompose_obj_π, fac, whisker_left_app,
        assoc, id_comp, inv_fun_id_assoc_hom_app, fac_assoc, nat_trans.comp_app]
      rw [counit_app_functor, ← functor.comp_map, w.hom.naturality]
      simp
    inv_hom_id' := by apply hom_ext Q; tidy }
#align category_theory.limits.is_limit.cone_points_iso_of_equivalence CategoryTheory.Limits.IsLimit.conePointsIsoOfEquivalence
-/

end Equivalence

#print CategoryTheory.Limits.IsLimit.homIso /-
/-- The universal property of a limit cone: a map `W ⟶ X` is the same as
  a cone on `F` with vertex `W`. -/
def homIso (h : IsLimit t) (W : C) : ULift.{u₁} (W ⟶ t.pt : Type v₃) ≅ (const J).obj W ⟶ F
    where
  Hom f := (t.extend f.down).π
  inv π :=
    ⟨h.lift
        { pt := W
          π }⟩
  hom_inv_id' := by ext f <;> apply h.hom_ext <;> intro j <;> simp <;> dsimp <;> rfl
#align category_theory.limits.is_limit.hom_iso CategoryTheory.Limits.IsLimit.homIso
-/

#print CategoryTheory.Limits.IsLimit.homIso_hom /-
@[simp]
theorem homIso_hom (h : IsLimit t) {W : C} (f : ULift.{u₁} (W ⟶ t.pt)) :
    (IsLimit.homIso h W).Hom f = (t.extend f.down).π :=
  rfl
#align category_theory.limits.is_limit.hom_iso_hom CategoryTheory.Limits.IsLimit.homIso_hom
-/

#print CategoryTheory.Limits.IsLimit.natIso /-
/-- The limit of `F` represents the functor taking `W` to
  the set of cones on `F` with vertex `W`. -/
def natIso (h : IsLimit t) : yoneda.obj t.pt ⋙ uliftFunctor.{u₁} ≅ F.cones :=
  NatIso.ofComponents (fun W => IsLimit.homIso h (unop W)) (by tidy)
#align category_theory.limits.is_limit.nat_iso CategoryTheory.Limits.IsLimit.natIso
-/

#print CategoryTheory.Limits.IsLimit.homIso' /-
/-- Another, more explicit, formulation of the universal property of a limit cone.
See also `hom_iso`.
-/
def homIso' (h : IsLimit t) (W : C) :
    ULift.{u₁} (W ⟶ t.pt : Type v₃) ≅
      { p : ∀ j, W ⟶ F.obj j // ∀ {j j'} (f : j ⟶ j'), p j ≫ F.map f = p j' } :=
  h.homIso W ≪≫
    { Hom := fun π =>
        ⟨fun j => π.app j, fun j j' f => by convert ← (π.naturality f).symm <;> apply id_comp⟩
      inv := fun p =>
        { app := fun j => p.1 j
          naturality' := fun j j' f => by dsimp; rw [id_comp]; exact (p.2 f).symm } }
#align category_theory.limits.is_limit.hom_iso' CategoryTheory.Limits.IsLimit.homIso'
-/

#print CategoryTheory.Limits.IsLimit.ofFaithful /-
/-- If G : C → D is a faithful functor which sends t to a limit cone,
  then it suffices to check that the induced maps for the image of t
  can be lifted to maps of C. -/
def ofFaithful {t : Cone F} {D : Type u₄} [Category.{v₄} D] (G : C ⥤ D) [Faithful G]
    (ht : IsLimit (G.mapCone t)) (lift : ∀ s : Cone F, s.pt ⟶ t.pt)
    (h : ∀ s, G.map (lift s) = ht.lift (G.mapCone s)) : IsLimit t :=
  { lift
    fac := fun s j => by apply G.map_injective <;> rw [G.map_comp, h] <;> apply ht.fac
    uniq := fun s m w => by
      apply G.map_injective; rw [h]
      refine' ht.uniq (G.map_cone s) _ fun j => _
      convert ← congr_arg (fun f => G.map f) (w j)
      apply G.map_comp }
#align category_theory.limits.is_limit.of_faithful CategoryTheory.Limits.IsLimit.ofFaithful
-/

#print CategoryTheory.Limits.IsLimit.mapConeEquiv /-
/-- If `F` and `G` are naturally isomorphic, then `F.map_cone c` being a limit implies
`G.map_cone c` is also a limit.
-/
def mapConeEquiv {D : Type u₄} [Category.{v₄} D] {K : J ⥤ C} {F G : C ⥤ D} (h : F ≅ G) {c : Cone K}
    (t : IsLimit (F.mapCone c)) : IsLimit (G.mapCone c) :=
  by
  apply postcompose_inv_equiv (iso_whisker_left K h : _) (G.map_cone c) _
  apply t.of_iso_limit (postcompose_whisker_left_map_cone h.symm c).symm
#align category_theory.limits.is_limit.map_cone_equiv CategoryTheory.Limits.IsLimit.mapConeEquiv
-/

#print CategoryTheory.Limits.IsLimit.isoUniqueConeMorphism /-
/-- A cone is a limit cone exactly if
there is a unique cone morphism from any other cone.
-/
def isoUniqueConeMorphism {t : Cone F} : IsLimit t ≅ ∀ s, Unique (s ⟶ t)
    where
  Hom h s :=
    { default := h.liftConeMorphism s
      uniq := fun _ => h.uniq_cone_morphism }
  inv h :=
    { lift := fun s => (h s).default.Hom
      uniq := fun s f w => congr_arg ConeMorphism.hom ((h s).uniq ⟨f, w⟩) }
#align category_theory.limits.is_limit.iso_unique_cone_morphism CategoryTheory.Limits.IsLimit.isoUniqueConeMorphism
-/

namespace OfNatIso

variable {X : C} (h : yoneda.obj X ⋙ uliftFunctor.{u₁} ≅ F.cones)

#print CategoryTheory.Limits.IsLimit.OfNatIso.coneOfHom /-
/-- If `F.cones` is represented by `X`, each morphism `f : Y ⟶ X` gives a cone with cone point
`Y`. -/
def coneOfHom {Y : C} (f : Y ⟶ X) : Cone F where
  pt := Y
  π := h.Hom.app (op Y) ⟨f⟩
#align category_theory.limits.is_limit.of_nat_iso.cone_of_hom CategoryTheory.Limits.IsLimit.OfNatIso.coneOfHom
-/

#print CategoryTheory.Limits.IsLimit.OfNatIso.homOfCone /-
/-- If `F.cones` is represented by `X`, each cone `s` gives a morphism `s.X ⟶ X`. -/
def homOfCone (s : Cone F) : s.pt ⟶ X :=
  (h.inv.app (op s.pt) s.π).down
#align category_theory.limits.is_limit.of_nat_iso.hom_of_cone CategoryTheory.Limits.IsLimit.OfNatIso.homOfCone
-/

#print CategoryTheory.Limits.IsLimit.OfNatIso.coneOfHom_homOfCone /-
@[simp]
theorem coneOfHom_homOfCone (s : Cone F) : coneOfHom h (homOfCone h s) = s :=
  by
  dsimp [cone_of_hom, hom_of_cone]; cases s; congr; dsimp
  convert congr_fun (congr_fun (congr_arg nat_trans.app h.inv_hom_id) (op s_X)) s_π
  exact ULift.up_down _
#align category_theory.limits.is_limit.of_nat_iso.cone_of_hom_of_cone CategoryTheory.Limits.IsLimit.OfNatIso.coneOfHom_homOfCone
-/

#print CategoryTheory.Limits.IsLimit.OfNatIso.homOfCone_coneOfHom /-
@[simp]
theorem homOfCone_coneOfHom {Y : C} (f : Y ⟶ X) : homOfCone h (coneOfHom h f) = f :=
  congr_arg ULift.down (congr_fun (congr_fun (congr_arg NatTrans.app h.hom_inv_id) (op Y)) ⟨f⟩ : _)
#align category_theory.limits.is_limit.of_nat_iso.hom_of_cone_of_hom CategoryTheory.Limits.IsLimit.OfNatIso.homOfCone_coneOfHom
-/

#print CategoryTheory.Limits.IsLimit.OfNatIso.limitCone /-
/-- If `F.cones` is represented by `X`, the cone corresponding to the identity morphism on `X`
will be a limit cone. -/
def limitCone : Cone F :=
  coneOfHom h (𝟙 X)
#align category_theory.limits.is_limit.of_nat_iso.limit_cone CategoryTheory.Limits.IsLimit.OfNatIso.limitCone
-/

#print CategoryTheory.Limits.IsLimit.OfNatIso.coneOfHom_fac /-
/-- If `F.cones` is represented by `X`, the cone corresponding to a morphism `f : Y ⟶ X` is
the limit cone extended by `f`. -/
theorem coneOfHom_fac {Y : C} (f : Y ⟶ X) : coneOfHom h f = (limitCone h).extend f :=
  by
  dsimp [cone_of_hom, limit_cone, cone.extend]
  congr with j
  have t := congr_fun (h.hom.naturality f.op) ⟨𝟙 X⟩
  dsimp at t 
  simp only [comp_id] at t 
  rw [congr_fun (congr_arg nat_trans.app t) j]
  rfl
#align category_theory.limits.is_limit.of_nat_iso.cone_of_hom_fac CategoryTheory.Limits.IsLimit.OfNatIso.coneOfHom_fac
-/

#print CategoryTheory.Limits.IsLimit.OfNatIso.cone_fac /-
/-- If `F.cones` is represented by `X`, any cone is the extension of the limit cone by the
corresponding morphism. -/
theorem cone_fac (s : Cone F) : (limitCone h).extend (homOfCone h s) = s :=
  by
  rw [← cone_of_hom_of_cone h s]
  conv_lhs => simp only [hom_of_cone_of_hom]
  apply (cone_of_hom_fac _ _).symm
#align category_theory.limits.is_limit.of_nat_iso.cone_fac CategoryTheory.Limits.IsLimit.OfNatIso.cone_fac
-/

end OfNatIso

section

open OfNatIso

#print CategoryTheory.Limits.IsLimit.ofNatIso /-
/-- If `F.cones` is representable, then the cone corresponding to the identity morphism on
the representing object is a limit cone.
-/
def ofNatIso {X : C} (h : yoneda.obj X ⋙ uliftFunctor.{u₁} ≅ F.cones) : IsLimit (limitCone h)
    where
  lift s := homOfCone h s
  fac s j := by
    have h := cone_fac h s
    cases s
    injection h with h₁ h₂
    simp only [heq_iff_eq] at h₂ 
    conv_rhs => rw [← h₂]; rfl
  uniq s m w := by
    rw [← hom_of_cone_of_hom h m]
    congr
    rw [cone_of_hom_fac]
    dsimp [cone.extend]; cases s; congr with j; exact w j
#align category_theory.limits.is_limit.of_nat_iso CategoryTheory.Limits.IsLimit.ofNatIso
-/

end

end IsLimit

#print CategoryTheory.Limits.IsColimit /-
/-- A cocone `t` on `F` is a colimit cocone if each cocone on `F` admits a unique
cocone morphism from `t`.

See <https://stacks.math.columbia.edu/tag/002F>.
-/
@[nolint has_nonempty_instance]
structure IsColimit (t : Cocone F) where
  desc : ∀ s : Cocone F, t.pt ⟶ s.pt
  fac : ∀ (s : Cocone F) (j : J), t.ι.app j ≫ desc s = s.ι.app j := by obviously
  uniq :
    ∀ (s : Cocone F) (m : t.pt ⟶ s.pt) (w : ∀ j : J, t.ι.app j ≫ m = s.ι.app j), m = desc s := by
    obviously
#align category_theory.limits.is_colimit CategoryTheory.Limits.IsColimit
-/

restate_axiom is_colimit.fac'

attribute [simp, reassoc] is_colimit.fac

restate_axiom is_colimit.uniq'

namespace IsColimit

#print CategoryTheory.Limits.IsColimit.subsingleton /-
instance subsingleton {t : Cocone F} : Subsingleton (IsColimit t) :=
  ⟨by intro P Q <;> cases P <;> cases Q <;> congr <;> ext <;> solve_by_elim⟩
#align category_theory.limits.is_colimit.subsingleton CategoryTheory.Limits.IsColimit.subsingleton
-/

#print CategoryTheory.Limits.IsColimit.map /-
/-- Given a natural transformation `α : F ⟶ G`, we give a morphism from the cocone point
of a colimit cocone over `F` to the cocone point of any cocone over `G`. -/
def map {F G : J ⥤ C} {s : Cocone F} (P : IsColimit s) (t : Cocone G) (α : F ⟶ G) : s.pt ⟶ t.pt :=
  P.desc ((Cocones.precompose α).obj t)
#align category_theory.limits.is_colimit.map CategoryTheory.Limits.IsColimit.map
-/

#print CategoryTheory.Limits.IsColimit.ι_map /-
@[simp, reassoc]
theorem ι_map {F G : J ⥤ C} {c : Cocone F} (hc : IsColimit c) (d : Cocone G) (α : F ⟶ G) (j : J) :
    c.ι.app j ≫ IsColimit.map hc d α = α.app j ≫ d.ι.app j :=
  fac _ _ _
#align category_theory.limits.is_colimit.ι_map CategoryTheory.Limits.IsColimit.ι_map
-/

#print CategoryTheory.Limits.IsColimit.desc_self /-
@[simp]
theorem desc_self {t : Cocone F} (h : IsColimit t) : h.desc t = 𝟙 t.pt :=
  (h.uniq _ _ fun j => comp_id _).symm
#align category_theory.limits.is_colimit.desc_self CategoryTheory.Limits.IsColimit.desc_self
-/

#print CategoryTheory.Limits.IsColimit.descCoconeMorphism /-
-- Repackaging the definition in terms of cocone morphisms.
/-- The universal morphism from a colimit cocone to any other cocone. -/
@[simps]
def descCoconeMorphism {t : Cocone F} (h : IsColimit t) (s : Cocone F) : t ⟶ s where Hom := h.desc s
#align category_theory.limits.is_colimit.desc_cocone_morphism CategoryTheory.Limits.IsColimit.descCoconeMorphism
-/

#print CategoryTheory.Limits.IsColimit.uniq_cocone_morphism /-
theorem uniq_cocone_morphism {s t : Cocone F} (h : IsColimit t) {f f' : t ⟶ s} : f = f' :=
  have : ∀ {g : t ⟶ s}, g = h.descCoconeMorphism s := by intro g <;> ext <;> exact h.uniq _ _ g.w
  this.trans this.symm
#align category_theory.limits.is_colimit.uniq_cocone_morphism CategoryTheory.Limits.IsColimit.uniq_cocone_morphism
-/

#print CategoryTheory.Limits.IsColimit.existsUnique /-
/-- Restating the definition of a colimit cocone in terms of the ∃! operator. -/
theorem existsUnique {t : Cocone F} (h : IsColimit t) (s : Cocone F) :
    ∃! d : t.pt ⟶ s.pt, ∀ j, t.ι.app j ≫ d = s.ι.app j :=
  ⟨h.desc s, h.fac s, h.uniq s⟩
#align category_theory.limits.is_colimit.exists_unique CategoryTheory.Limits.IsColimit.existsUnique
-/

#print CategoryTheory.Limits.IsColimit.ofExistsUnique /-
/-- Noncomputably make a colimit cocone from the existence of unique factorizations. -/
def ofExistsUnique {t : Cocone F}
    (ht : ∀ s : Cocone F, ∃! d : t.pt ⟶ s.pt, ∀ j, t.ι.app j ≫ d = s.ι.app j) : IsColimit t := by
  choose s hs hs' using ht; exact ⟨s, hs, hs'⟩
#align category_theory.limits.is_colimit.of_exists_unique CategoryTheory.Limits.IsColimit.ofExistsUnique
-/

#print CategoryTheory.Limits.IsColimit.mkCoconeMorphism /-
/-- Alternative constructor for `is_colimit`,
providing a morphism of cocones rather than a morphism between the cocone points
and separately the factorisation condition.
-/
@[simps]
def mkCoconeMorphism {t : Cocone F} (desc : ∀ s : Cocone F, t ⟶ s)
    (uniq' : ∀ (s : Cocone F) (m : t ⟶ s), m = desc s) : IsColimit t
    where
  desc s := (desc s).Hom
  uniq s m w :=
    have : CoconeMorphism.mk m w = desc s := by apply uniq'
    congr_arg CoconeMorphism.hom this
#align category_theory.limits.is_colimit.mk_cocone_morphism CategoryTheory.Limits.IsColimit.mkCoconeMorphism
-/

#print CategoryTheory.Limits.IsColimit.uniqueUpToIso /-
/-- Colimit cocones on `F` are unique up to isomorphism. -/
@[simps]
def uniqueUpToIso {s t : Cocone F} (P : IsColimit s) (Q : IsColimit t) : s ≅ t
    where
  Hom := P.descCoconeMorphism t
  inv := Q.descCoconeMorphism s
  hom_inv_id' := P.uniq_cocone_morphism
  inv_hom_id' := Q.uniq_cocone_morphism
#align category_theory.limits.is_colimit.unique_up_to_iso CategoryTheory.Limits.IsColimit.uniqueUpToIso
-/

#print CategoryTheory.Limits.IsColimit.hom_isIso /-
/-- Any cocone morphism between colimit cocones is an isomorphism. -/
theorem hom_isIso {s t : Cocone F} (P : IsColimit s) (Q : IsColimit t) (f : s ⟶ t) : IsIso f :=
  ⟨⟨Q.descCoconeMorphism s, ⟨P.uniq_cocone_morphism, Q.uniq_cocone_morphism⟩⟩⟩
#align category_theory.limits.is_colimit.hom_is_iso CategoryTheory.Limits.IsColimit.hom_isIso
-/

#print CategoryTheory.Limits.IsColimit.coconePointUniqueUpToIso /-
/-- Colimits of `F` are unique up to isomorphism. -/
def coconePointUniqueUpToIso {s t : Cocone F} (P : IsColimit s) (Q : IsColimit t) : s.pt ≅ t.pt :=
  (Cocones.forget F).mapIso (uniqueUpToIso P Q)
#align category_theory.limits.is_colimit.cocone_point_unique_up_to_iso CategoryTheory.Limits.IsColimit.coconePointUniqueUpToIso
-/

#print CategoryTheory.Limits.IsColimit.comp_coconePointUniqueUpToIso_hom /-
@[simp, reassoc]
theorem comp_coconePointUniqueUpToIso_hom {s t : Cocone F} (P : IsColimit s) (Q : IsColimit t)
    (j : J) : s.ι.app j ≫ (coconePointUniqueUpToIso P Q).Hom = t.ι.app j :=
  (uniqueUpToIso P Q).Hom.w _
#align category_theory.limits.is_colimit.comp_cocone_point_unique_up_to_iso_hom CategoryTheory.Limits.IsColimit.comp_coconePointUniqueUpToIso_hom
-/

#print CategoryTheory.Limits.IsColimit.comp_coconePointUniqueUpToIso_inv /-
@[simp, reassoc]
theorem comp_coconePointUniqueUpToIso_inv {s t : Cocone F} (P : IsColimit s) (Q : IsColimit t)
    (j : J) : t.ι.app j ≫ (coconePointUniqueUpToIso P Q).inv = s.ι.app j :=
  (uniqueUpToIso P Q).inv.w _
#align category_theory.limits.is_colimit.comp_cocone_point_unique_up_to_iso_inv CategoryTheory.Limits.IsColimit.comp_coconePointUniqueUpToIso_inv
-/

#print CategoryTheory.Limits.IsColimit.coconePointUniqueUpToIso_hom_desc /-
@[simp, reassoc]
theorem coconePointUniqueUpToIso_hom_desc {r s t : Cocone F} (P : IsColimit s) (Q : IsColimit t) :
    (coconePointUniqueUpToIso P Q).Hom ≫ Q.desc r = P.desc r :=
  P.uniq _ _ (by simp)
#align category_theory.limits.is_colimit.cocone_point_unique_up_to_iso_hom_desc CategoryTheory.Limits.IsColimit.coconePointUniqueUpToIso_hom_desc
-/

#print CategoryTheory.Limits.IsColimit.coconePointUniqueUpToIso_inv_desc /-
@[simp, reassoc]
theorem coconePointUniqueUpToIso_inv_desc {r s t : Cocone F} (P : IsColimit s) (Q : IsColimit t) :
    (coconePointUniqueUpToIso P Q).inv ≫ P.desc r = Q.desc r :=
  Q.uniq _ _ (by simp)
#align category_theory.limits.is_colimit.cocone_point_unique_up_to_iso_inv_desc CategoryTheory.Limits.IsColimit.coconePointUniqueUpToIso_inv_desc
-/

#print CategoryTheory.Limits.IsColimit.ofIsoColimit /-
/-- Transport evidence that a cocone is a colimit cocone across an isomorphism of cocones. -/
def ofIsoColimit {r t : Cocone F} (P : IsColimit r) (i : r ≅ t) : IsColimit t :=
  IsColimit.mkCoconeMorphism (fun s => i.inv ≫ P.descCoconeMorphism s) fun s m => by
    rw [i.eq_inv_comp] <;> apply P.uniq_cocone_morphism
#align category_theory.limits.is_colimit.of_iso_colimit CategoryTheory.Limits.IsColimit.ofIsoColimit
-/

#print CategoryTheory.Limits.IsColimit.ofIsoColimit_desc /-
@[simp]
theorem ofIsoColimit_desc {r t : Cocone F} (P : IsColimit r) (i : r ≅ t) (s) :
    (P.ofIsoColimit i).desc s = i.inv.Hom ≫ P.desc s :=
  rfl
#align category_theory.limits.is_colimit.of_iso_colimit_desc CategoryTheory.Limits.IsColimit.ofIsoColimit_desc
-/

#print CategoryTheory.Limits.IsColimit.equivIsoColimit /-
/-- Isomorphism of cocones preserves whether or not they are colimiting cocones. -/
def equivIsoColimit {r t : Cocone F} (i : r ≅ t) : IsColimit r ≃ IsColimit t
    where
  toFun h := h.ofIsoColimit i
  invFun h := h.ofIsoColimit i.symm
  left_inv := by tidy
  right_inv := by tidy
#align category_theory.limits.is_colimit.equiv_iso_colimit CategoryTheory.Limits.IsColimit.equivIsoColimit
-/

#print CategoryTheory.Limits.IsColimit.equivIsoColimit_apply /-
@[simp]
theorem equivIsoColimit_apply {r t : Cocone F} (i : r ≅ t) (P : IsColimit r) :
    equivIsoColimit i P = P.ofIsoColimit i :=
  rfl
#align category_theory.limits.is_colimit.equiv_iso_colimit_apply CategoryTheory.Limits.IsColimit.equivIsoColimit_apply
-/

#print CategoryTheory.Limits.IsColimit.equivIsoColimit_symm_apply /-
@[simp]
theorem equivIsoColimit_symm_apply {r t : Cocone F} (i : r ≅ t) (P : IsColimit t) :
    (equivIsoColimit i).symm P = P.ofIsoColimit i.symm :=
  rfl
#align category_theory.limits.is_colimit.equiv_iso_colimit_symm_apply CategoryTheory.Limits.IsColimit.equivIsoColimit_symm_apply
-/

#print CategoryTheory.Limits.IsColimit.ofPointIso /-
/-- If the canonical morphism to a cocone point from a colimiting cocone point is an iso, then the
first cocone was colimiting also.
-/
def ofPointIso {r t : Cocone F} (P : IsColimit r) [i : IsIso (P.desc t)] : IsColimit t :=
  ofIsoColimit P
    (by
      haveI : is_iso (P.desc_cocone_morphism t).Hom := i
      haveI : is_iso (P.desc_cocone_morphism t) := cocones.cocone_iso_of_hom_iso _
      apply as_iso (P.desc_cocone_morphism t))
#align category_theory.limits.is_colimit.of_point_iso CategoryTheory.Limits.IsColimit.ofPointIso
-/

variable {t : Cocone F}

#print CategoryTheory.Limits.IsColimit.hom_desc /-
theorem hom_desc (h : IsColimit t) {W : C} (m : t.pt ⟶ W) :
    m =
      h.desc
        { pt := W
          ι :=
            { app := fun b => t.ι.app b ≫ m
              naturality' := by intros <;> erw [← assoc, t.ι.naturality, comp_id, comp_id] } } :=
  h.uniq
    { pt := W
      ι :=
        { app := fun b => t.ι.app b ≫ m
          naturality' := _ } }
    m fun b => rfl
#align category_theory.limits.is_colimit.hom_desc CategoryTheory.Limits.IsColimit.hom_desc
-/

#print CategoryTheory.Limits.IsColimit.hom_ext /-
/-- Two morphisms out of a colimit are equal if their compositions with
  each cocone morphism are equal. -/
theorem hom_ext (h : IsColimit t) {W : C} {f f' : t.pt ⟶ W}
    (w : ∀ j, t.ι.app j ≫ f = t.ι.app j ≫ f') : f = f' := by
  rw [h.hom_desc f, h.hom_desc f'] <;> congr <;> exact funext w
#align category_theory.limits.is_colimit.hom_ext CategoryTheory.Limits.IsColimit.hom_ext
-/

#print CategoryTheory.Limits.IsColimit.ofLeftAdjoint /-
/-- Given a left adjoint functor between categories of cocones,
the image of a colimit cocone is a colimit cocone.
-/
def ofLeftAdjoint {D : Type u₄} [Category.{v₄} D] {G : K ⥤ D} (h : Cocone G ⥤ Cocone F)
    [IsLeftAdjoint h] {c : Cocone G} (t : IsColimit c) : IsColimit (h.obj c) :=
  mkCoconeMorphism
    (fun s => ((Adjunction.ofLeftAdjoint h).homEquiv c s).symm (t.descCoconeMorphism _)) fun s m =>
    (Adjunction.homEquiv_apply_eq _ _ _).1 t.uniq_cocone_morphism
#align category_theory.limits.is_colimit.of_left_adjoint CategoryTheory.Limits.IsColimit.ofLeftAdjoint
-/

#print CategoryTheory.Limits.IsColimit.ofCoconeEquiv /-
/-- Given two functors which have equivalent categories of cocones,
we can transport a colimiting cocone across the equivalence.
-/
def ofCoconeEquiv {D : Type u₄} [Category.{v₄} D] {G : K ⥤ D} (h : Cocone G ≌ Cocone F)
    {c : Cocone G} : IsColimit (h.Functor.obj c) ≃ IsColimit c
    where
  toFun P := ofIsoColimit (ofLeftAdjoint h.inverse P) (h.unitIso.symm.app c)
  invFun := ofLeftAdjoint h.Functor
  left_inv := by tidy
  right_inv := by tidy
#align category_theory.limits.is_colimit.of_cocone_equiv CategoryTheory.Limits.IsColimit.ofCoconeEquiv
-/

#print CategoryTheory.Limits.IsColimit.ofCoconeEquiv_apply_desc /-
@[simp]
theorem ofCoconeEquiv_apply_desc {D : Type u₄} [Category.{v₄} D] {G : K ⥤ D}
    (h : Cocone G ≌ Cocone F) {c : Cocone G} (P : IsColimit (h.Functor.obj c)) (s) :
    (ofCoconeEquiv h P).desc s =
      (h.Unit.app c).Hom ≫
        (h.inverse.map (P.descCoconeMorphism (h.Functor.obj s))).Hom ≫ (h.unitInv.app s).Hom :=
  rfl
#align category_theory.limits.is_colimit.of_cocone_equiv_apply_desc CategoryTheory.Limits.IsColimit.ofCoconeEquiv_apply_desc
-/

#print CategoryTheory.Limits.IsColimit.ofCoconeEquiv_symm_apply_desc /-
@[simp]
theorem ofCoconeEquiv_symm_apply_desc {D : Type u₄} [Category.{v₄} D] {G : K ⥤ D}
    (h : Cocone G ≌ Cocone F) {c : Cocone G} (P : IsColimit c) (s) :
    ((ofCoconeEquiv h).symm P).desc s =
      (h.Functor.map (P.descCoconeMorphism (h.inverse.obj s))).Hom ≫ (h.counit.app s).Hom :=
  rfl
#align category_theory.limits.is_colimit.of_cocone_equiv_symm_apply_desc CategoryTheory.Limits.IsColimit.ofCoconeEquiv_symm_apply_desc
-/

#print CategoryTheory.Limits.IsColimit.precomposeHomEquiv /-
/-- A cocone precomposed with a natural isomorphism is a colimit cocone
if and only if the original cocone is.
-/
def precomposeHomEquiv {F G : J ⥤ C} (α : F ≅ G) (c : Cocone G) :
    IsColimit ((Cocones.precompose α.Hom).obj c) ≃ IsColimit c :=
  ofCoconeEquiv (Cocones.precomposeEquivalence α)
#align category_theory.limits.is_colimit.precompose_hom_equiv CategoryTheory.Limits.IsColimit.precomposeHomEquiv
-/

#print CategoryTheory.Limits.IsColimit.precomposeInvEquiv /-
/-- A cocone precomposed with the inverse of a natural isomorphism is a colimit cocone
if and only if the original cocone is.
-/
def precomposeInvEquiv {F G : J ⥤ C} (α : F ≅ G) (c : Cocone F) :
    IsColimit ((Cocones.precompose α.inv).obj c) ≃ IsColimit c :=
  precomposeHomEquiv α.symm c
#align category_theory.limits.is_colimit.precompose_inv_equiv CategoryTheory.Limits.IsColimit.precomposeInvEquiv
-/

#print CategoryTheory.Limits.IsColimit.equivOfNatIsoOfIso /-
/-- Constructing an equivalence `is_colimit c ≃ is_colimit d` from a natural isomorphism
between the underlying functors, and then an isomorphism between `c` transported along this and `d`.
-/
def equivOfNatIsoOfIso {F G : J ⥤ C} (α : F ≅ G) (c : Cocone F) (d : Cocone G)
    (w : (Cocones.precompose α.inv).obj c ≅ d) : IsColimit c ≃ IsColimit d :=
  (precomposeInvEquiv α _).symm.trans (equivIsoColimit w)
#align category_theory.limits.is_colimit.equiv_of_nat_iso_of_iso CategoryTheory.Limits.IsColimit.equivOfNatIsoOfIso
-/

#print CategoryTheory.Limits.IsColimit.coconePointsIsoOfNatIso /-
/-- The cocone points of two colimit cocones for naturally isomorphic functors
are themselves isomorphic.
-/
@[simps]
def coconePointsIsoOfNatIso {F G : J ⥤ C} {s : Cocone F} {t : Cocone G} (P : IsColimit s)
    (Q : IsColimit t) (w : F ≅ G) : s.pt ≅ t.pt
    where
  Hom := P.map t w.Hom
  inv := Q.map s w.inv
  hom_inv_id' := P.hom_ext (by tidy)
  inv_hom_id' := Q.hom_ext (by tidy)
#align category_theory.limits.is_colimit.cocone_points_iso_of_nat_iso CategoryTheory.Limits.IsColimit.coconePointsIsoOfNatIso
-/

#print CategoryTheory.Limits.IsColimit.comp_coconePointsIsoOfNatIso_hom /-
@[reassoc]
theorem comp_coconePointsIsoOfNatIso_hom {F G : J ⥤ C} {s : Cocone F} {t : Cocone G}
    (P : IsColimit s) (Q : IsColimit t) (w : F ≅ G) (j : J) :
    s.ι.app j ≫ (coconePointsIsoOfNatIso P Q w).Hom = w.Hom.app j ≫ t.ι.app j := by simp
#align category_theory.limits.is_colimit.comp_cocone_points_iso_of_nat_iso_hom CategoryTheory.Limits.IsColimit.comp_coconePointsIsoOfNatIso_hom
-/

#print CategoryTheory.Limits.IsColimit.comp_coconePointsIsoOfNatIso_inv /-
@[reassoc]
theorem comp_coconePointsIsoOfNatIso_inv {F G : J ⥤ C} {s : Cocone F} {t : Cocone G}
    (P : IsColimit s) (Q : IsColimit t) (w : F ≅ G) (j : J) :
    t.ι.app j ≫ (coconePointsIsoOfNatIso P Q w).inv = w.inv.app j ≫ s.ι.app j := by simp
#align category_theory.limits.is_colimit.comp_cocone_points_iso_of_nat_iso_inv CategoryTheory.Limits.IsColimit.comp_coconePointsIsoOfNatIso_inv
-/

#print CategoryTheory.Limits.IsColimit.coconePointsIsoOfNatIso_hom_desc /-
@[reassoc]
theorem coconePointsIsoOfNatIso_hom_desc {F G : J ⥤ C} {s : Cocone F} {r t : Cocone G}
    (P : IsColimit s) (Q : IsColimit t) (w : F ≅ G) :
    (coconePointsIsoOfNatIso P Q w).Hom ≫ Q.desc r = P.map _ w.Hom :=
  P.hom_ext (by simp)
#align category_theory.limits.is_colimit.cocone_points_iso_of_nat_iso_hom_desc CategoryTheory.Limits.IsColimit.coconePointsIsoOfNatIso_hom_desc
-/

#print CategoryTheory.Limits.IsColimit.coconePointsIsoOfNatIso_inv_desc /-
@[reassoc]
theorem coconePointsIsoOfNatIso_inv_desc {F G : J ⥤ C} {s : Cocone G} {r t : Cocone F}
    (P : IsColimit t) (Q : IsColimit s) (w : F ≅ G) :
    (coconePointsIsoOfNatIso P Q w).inv ≫ P.desc r = Q.map _ w.inv :=
  Q.hom_ext (by simp)
#align category_theory.limits.is_colimit.cocone_points_iso_of_nat_iso_inv_desc CategoryTheory.Limits.IsColimit.coconePointsIsoOfNatIso_inv_desc
-/

section Equivalence

open CategoryTheory.Equivalence

#print CategoryTheory.Limits.IsColimit.whiskerEquivalence /-
/-- If `s : cocone F` is a colimit cocone, so is `s` whiskered by an equivalence `e`.
-/
def whiskerEquivalence {s : Cocone F} (P : IsColimit s) (e : K ≌ J) :
    IsColimit (s.whisker e.Functor) :=
  ofLeftAdjoint (Cocones.whiskeringEquivalence e).Functor P
#align category_theory.limits.is_colimit.whisker_equivalence CategoryTheory.Limits.IsColimit.whiskerEquivalence
-/

#print CategoryTheory.Limits.IsColimit.ofWhiskerEquivalence /-
/-- If `s : cocone F` whiskered by an equivalence `e` is a colimit cocone, so is `s`.
-/
def ofWhiskerEquivalence {s : Cocone F} (e : K ≌ J) (P : IsColimit (s.whisker e.Functor)) :
    IsColimit s :=
  equivIsoColimit ((Cocones.whiskeringEquivalence e).unitIso.app s).symm
    (ofLeftAdjoint (Cocones.whiskeringEquivalence e).inverse P : _)
#align category_theory.limits.is_colimit.of_whisker_equivalence CategoryTheory.Limits.IsColimit.ofWhiskerEquivalence
-/

#print CategoryTheory.Limits.IsColimit.whiskerEquivalenceEquiv /-
/-- Given an equivalence of diagrams `e`, `s` is a colimit cocone iff `s.whisker e.functor` is.
-/
def whiskerEquivalenceEquiv {s : Cocone F} (e : K ≌ J) :
    IsColimit s ≃ IsColimit (s.whisker e.Functor) :=
  ⟨fun h => h.whiskerEquivalence e, ofWhiskerEquivalence e, by tidy, by tidy⟩
#align category_theory.limits.is_colimit.whisker_equivalence_equiv CategoryTheory.Limits.IsColimit.whiskerEquivalenceEquiv
-/

#print CategoryTheory.Limits.IsColimit.coconePointsIsoOfEquivalence /-
/-- We can prove two cocone points `(s : cocone F).X` and `(t.cocone G).X` are isomorphic if
* both cocones are colimit cocones
* their indexing categories are equivalent via some `e : J ≌ K`,
* the triangle of functors commutes up to a natural isomorphism: `e.functor ⋙ G ≅ F`.

This is the most general form of uniqueness of cocone points,
allowing relabelling of both the indexing category (up to equivalence)
and the functor (up to natural isomorphism).
-/
@[simps]
def coconePointsIsoOfEquivalence {F : J ⥤ C} {s : Cocone F} {G : K ⥤ C} {t : Cocone G}
    (P : IsColimit s) (Q : IsColimit t) (e : J ≌ K) (w : e.Functor ⋙ G ≅ F) : s.pt ≅ t.pt :=
  let w' : e.inverse ⋙ F ≅ G := (isoWhiskerLeft e.inverse w).symm ≪≫ invFunIdAssoc e G
  { Hom := P.desc ((Cocones.equivalenceOfReindexing e w).Functor.obj t)
    inv := Q.desc ((Cocones.equivalenceOfReindexing e.symm w').Functor.obj s)
    hom_inv_id' := by
      apply hom_ext P; intro j
      dsimp
      simp only [limits.cocone.whisker_ι, fac, inv_fun_id_assoc_inv_app, whisker_left_app, assoc,
        comp_id, limits.cocones.precompose_obj_ι, fac_assoc, nat_trans.comp_app]
      rw [counit_inv_app_functor, ← functor.comp_map, ← w.inv.naturality_assoc]
      dsimp
      simp
    inv_hom_id' := by apply hom_ext Q; tidy }
#align category_theory.limits.is_colimit.cocone_points_iso_of_equivalence CategoryTheory.Limits.IsColimit.coconePointsIsoOfEquivalence
-/

end Equivalence

#print CategoryTheory.Limits.IsColimit.homIso /-
/-- The universal property of a colimit cocone: a map `X ⟶ W` is the same as
  a cocone on `F` with vertex `W`. -/
def homIso (h : IsColimit t) (W : C) : ULift.{u₁} (t.pt ⟶ W : Type v₃) ≅ F ⟶ (const J).obj W
    where
  Hom f := (t.extend f.down).ι
  inv ι :=
    ⟨h.desc
        { pt := W
          ι }⟩
  hom_inv_id' := by ext f <;> apply h.hom_ext <;> intro j <;> simp <;> dsimp <;> rfl
#align category_theory.limits.is_colimit.hom_iso CategoryTheory.Limits.IsColimit.homIso
-/

#print CategoryTheory.Limits.IsColimit.homIso_hom /-
@[simp]
theorem homIso_hom (h : IsColimit t) {W : C} (f : ULift (t.pt ⟶ W)) :
    (IsColimit.homIso h W).Hom f = (t.extend f.down).ι :=
  rfl
#align category_theory.limits.is_colimit.hom_iso_hom CategoryTheory.Limits.IsColimit.homIso_hom
-/

#print CategoryTheory.Limits.IsColimit.natIso /-
/-- The colimit of `F` represents the functor taking `W` to
  the set of cocones on `F` with vertex `W`. -/
def natIso (h : IsColimit t) : coyoneda.obj (op t.pt) ⋙ uliftFunctor.{u₁} ≅ F.cocones :=
  NatIso.ofComponents (IsColimit.homIso h) (by intros <;> ext <;> dsimp <;> rw [← assoc] <;> rfl)
#align category_theory.limits.is_colimit.nat_iso CategoryTheory.Limits.IsColimit.natIso
-/

#print CategoryTheory.Limits.IsColimit.homIso' /-
/-- Another, more explicit, formulation of the universal property of a colimit cocone.
See also `hom_iso`.
-/
def homIso' (h : IsColimit t) (W : C) :
    ULift.{u₁} (t.pt ⟶ W : Type v₃) ≅
      { p : ∀ j, F.obj j ⟶ W // ∀ {j j' : J} (f : j ⟶ j'), F.map f ≫ p j' = p j } :=
  h.homIso W ≪≫
    { Hom := fun ι =>
        ⟨fun j => ι.app j, fun j j' f => by convert ← ι.naturality f <;> apply comp_id⟩
      inv := fun p =>
        { app := fun j => p.1 j
          naturality' := fun j j' f => by dsimp; rw [comp_id]; exact p.2 f } }
#align category_theory.limits.is_colimit.hom_iso' CategoryTheory.Limits.IsColimit.homIso'
-/

#print CategoryTheory.Limits.IsColimit.ofFaithful /-
/-- If G : C → D is a faithful functor which sends t to a colimit cocone,
  then it suffices to check that the induced maps for the image of t
  can be lifted to maps of C. -/
def ofFaithful {t : Cocone F} {D : Type u₄} [Category.{v₄} D] (G : C ⥤ D) [Faithful G]
    (ht : IsColimit (G.mapCocone t)) (desc : ∀ s : Cocone F, t.pt ⟶ s.pt)
    (h : ∀ s, G.map (desc s) = ht.desc (G.mapCocone s)) : IsColimit t :=
  { desc
    fac := fun s j => by apply G.map_injective <;> rw [G.map_comp, h] <;> apply ht.fac
    uniq := fun s m w => by
      apply G.map_injective; rw [h]
      refine' ht.uniq (G.map_cocone s) _ fun j => _
      convert ← congr_arg (fun f => G.map f) (w j)
      apply G.map_comp }
#align category_theory.limits.is_colimit.of_faithful CategoryTheory.Limits.IsColimit.ofFaithful
-/

#print CategoryTheory.Limits.IsColimit.mapCoconeEquiv /-
/-- If `F` and `G` are naturally isomorphic, then `F.map_cone c` being a colimit implies
`G.map_cone c` is also a colimit.
-/
def mapCoconeEquiv {D : Type u₄} [Category.{v₄} D] {K : J ⥤ C} {F G : C ⥤ D} (h : F ≅ G)
    {c : Cocone K} (t : IsColimit (F.mapCocone c)) : IsColimit (G.mapCocone c) :=
  by
  apply is_colimit.of_iso_colimit _ (precompose_whisker_left_map_cocone h c)
  apply (precompose_inv_equiv (iso_whisker_left K h : _) _).symm t
#align category_theory.limits.is_colimit.map_cocone_equiv CategoryTheory.Limits.IsColimit.mapCoconeEquiv
-/

#print CategoryTheory.Limits.IsColimit.isoUniqueCoconeMorphism /-
/-- A cocone is a colimit cocone exactly if
there is a unique cocone morphism from any other cocone.
-/
def isoUniqueCoconeMorphism {t : Cocone F} : IsColimit t ≅ ∀ s, Unique (t ⟶ s)
    where
  Hom h s :=
    { default := h.descCoconeMorphism s
      uniq := fun _ => h.uniq_cocone_morphism }
  inv h :=
    { desc := fun s => (h s).default.Hom
      uniq := fun s f w => congr_arg CoconeMorphism.hom ((h s).uniq ⟨f, w⟩) }
#align category_theory.limits.is_colimit.iso_unique_cocone_morphism CategoryTheory.Limits.IsColimit.isoUniqueCoconeMorphism
-/

namespace OfNatIso

variable {X : C} (h : coyoneda.obj (op X) ⋙ uliftFunctor.{u₁} ≅ F.cocones)

#print CategoryTheory.Limits.IsColimit.OfNatIso.coconeOfHom /-
/-- If `F.cocones` is corepresented by `X`, each morphism `f : X ⟶ Y` gives a cocone with cone
point `Y`. -/
def coconeOfHom {Y : C} (f : X ⟶ Y) : Cocone F
    where
  pt := Y
  ι := h.Hom.app Y ⟨f⟩
#align category_theory.limits.is_colimit.of_nat_iso.cocone_of_hom CategoryTheory.Limits.IsColimit.OfNatIso.coconeOfHom
-/

#print CategoryTheory.Limits.IsColimit.OfNatIso.homOfCocone /-
/-- If `F.cocones` is corepresented by `X`, each cocone `s` gives a morphism `X ⟶ s.X`. -/
def homOfCocone (s : Cocone F) : X ⟶ s.pt :=
  (h.inv.app s.pt s.ι).down
#align category_theory.limits.is_colimit.of_nat_iso.hom_of_cocone CategoryTheory.Limits.IsColimit.OfNatIso.homOfCocone
-/

#print CategoryTheory.Limits.IsColimit.OfNatIso.coconeOfHom_homOfCocone /-
@[simp]
theorem coconeOfHom_homOfCocone (s : Cocone F) : coconeOfHom h (homOfCocone h s) = s :=
  by
  dsimp [cocone_of_hom, hom_of_cocone]; cases s; congr; dsimp
  convert congr_fun (congr_fun (congr_arg nat_trans.app h.inv_hom_id) s_X) s_ι
  exact ULift.up_down _
#align category_theory.limits.is_colimit.of_nat_iso.cocone_of_hom_of_cocone CategoryTheory.Limits.IsColimit.OfNatIso.coconeOfHom_homOfCocone
-/

#print CategoryTheory.Limits.IsColimit.OfNatIso.homOfCocone_cooneOfHom /-
@[simp]
theorem homOfCocone_cooneOfHom {Y : C} (f : X ⟶ Y) : homOfCocone h (coconeOfHom h f) = f :=
  congr_arg ULift.down (congr_fun (congr_fun (congr_arg NatTrans.app h.hom_inv_id) Y) ⟨f⟩ : _)
#align category_theory.limits.is_colimit.of_nat_iso.hom_of_cocone_of_hom CategoryTheory.Limits.IsColimit.OfNatIso.homOfCocone_cooneOfHom
-/

#print CategoryTheory.Limits.IsColimit.OfNatIso.colimitCocone /-
/-- If `F.cocones` is corepresented by `X`, the cocone corresponding to the identity morphism on `X`
will be a colimit cocone. -/
def colimitCocone : Cocone F :=
  coconeOfHom h (𝟙 X)
#align category_theory.limits.is_colimit.of_nat_iso.colimit_cocone CategoryTheory.Limits.IsColimit.OfNatIso.colimitCocone
-/

#print CategoryTheory.Limits.IsColimit.OfNatIso.coconeOfHom_fac /-
/-- If `F.cocones` is corepresented by `X`, the cocone corresponding to a morphism `f : Y ⟶ X` is
the colimit cocone extended by `f`. -/
theorem coconeOfHom_fac {Y : C} (f : X ⟶ Y) : coconeOfHom h f = (colimitCocone h).extend f :=
  by
  dsimp [cocone_of_hom, colimit_cocone, cocone.extend]
  congr with j
  have t := congr_fun (h.hom.naturality f) ⟨𝟙 X⟩
  dsimp at t 
  simp only [id_comp] at t 
  rw [congr_fun (congr_arg nat_trans.app t) j]
  rfl
#align category_theory.limits.is_colimit.of_nat_iso.cocone_of_hom_fac CategoryTheory.Limits.IsColimit.OfNatIso.coconeOfHom_fac
-/

#print CategoryTheory.Limits.IsColimit.OfNatIso.cocone_fac /-
/-- If `F.cocones` is corepresented by `X`, any cocone is the extension of the colimit cocone by the
corresponding morphism. -/
theorem cocone_fac (s : Cocone F) : (colimitCocone h).extend (homOfCocone h s) = s :=
  by
  rw [← cocone_of_hom_of_cocone h s]
  conv_lhs => simp only [hom_of_cocone_of_hom]
  apply (cocone_of_hom_fac _ _).symm
#align category_theory.limits.is_colimit.of_nat_iso.cocone_fac CategoryTheory.Limits.IsColimit.OfNatIso.cocone_fac
-/

end OfNatIso

section

open OfNatIso

#print CategoryTheory.Limits.IsColimit.ofNatIso /-
/-- If `F.cocones` is corepresentable, then the cocone corresponding to the identity morphism on
the representing object is a colimit cocone.
-/
def ofNatIso {X : C} (h : coyoneda.obj (op X) ⋙ uliftFunctor.{u₁} ≅ F.cocones) :
    IsColimit (colimitCocone h) where
  desc s := homOfCocone h s
  fac s j := by
    have h := cocone_fac h s
    cases s
    injection h with h₁ h₂
    simp only [heq_iff_eq] at h₂ 
    conv_rhs => rw [← h₂]; rfl
  uniq s m w := by
    rw [← hom_of_cocone_of_hom h m]
    congr
    rw [cocone_of_hom_fac]
    dsimp [cocone.extend]; cases s; congr with j; exact w j
#align category_theory.limits.is_colimit.of_nat_iso CategoryTheory.Limits.IsColimit.ofNatIso
-/

end

end IsColimit

end CategoryTheory.Limits

