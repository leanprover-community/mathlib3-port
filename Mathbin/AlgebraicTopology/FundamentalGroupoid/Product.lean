/-
Copyright (c) 2022 Praneeth Kolichala. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Praneeth Kolichala
-/
import Mathbin.CategoryTheory.Groupoid
import Mathbin.AlgebraicTopology.FundamentalGroupoid.Basic
import Mathbin.Topology.Category.Top.Limits.Products
import Mathbin.Topology.Homotopy.Product

#align_import algebraic_topology.fundamental_groupoid.product from "leanprover-community/mathlib"@"1a51edf13debfcbe223fa06b1cb353b9ed9751cc"

/-!
# Fundamental groupoid preserves products

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
In this file, we give the following definitions/theorems:

  - `fundamental_groupoid_functor.pi_iso` An isomorphism between Π i, (π Xᵢ) and π (Πi, Xᵢ), whose
    inverse is precisely the product of the maps π (Π i, Xᵢ) → π (Xᵢ), each induced by
    the projection in `Top` Π i, Xᵢ → Xᵢ.

  - `fundamental_groupoid_functor.prod_iso` An isomorphism between πX × πY and π (X × Y), whose
    inverse is precisely the product of the maps π (X × Y) → πX and π (X × Y) → Y, each induced by
    the projections X × Y → X and X × Y → Y

  - `fundamental_groupoid_functor.preserves_product` A proof that the fundamental groupoid functor
    preserves all products.
-/


noncomputable section

namespace FundamentalGroupoidFunctor

open scoped FundamentalGroupoid

universe u

section Pi

variable {I : Type u} (X : I → TopCat.{u})

#print FundamentalGroupoidFunctor.proj /-
/-- The projection map Π i, X i → X i induces a map π(Π i, X i) ⟶ π(X i).
-/
def proj (i : I) : πₓ (TopCat.of (∀ i, X i)) ⥤ πₓ (X i) :=
  πₘ ⟨_, continuous_apply i⟩
#align fundamental_groupoid_functor.proj FundamentalGroupoidFunctor.proj
-/

#print FundamentalGroupoidFunctor.proj_map /-
/-- The projection map is precisely path.homotopic.proj interpreted as a functor -/
@[simp]
theorem proj_map (i : I) (x₀ x₁ : πₓ (TopCat.of (∀ i, X i))) (p : x₀ ⟶ x₁) :
    (proj X i).map p = @Path.Homotopic.proj _ _ _ _ _ i p :=
  rfl
#align fundamental_groupoid_functor.proj_map FundamentalGroupoidFunctor.proj_map
-/

#print FundamentalGroupoidFunctor.piToPiTop /-
/-- The map taking the pi product of a family of fundamental groupoids to the fundamental
groupoid of the pi product. This is actually an isomorphism (see `pi_iso`)
-/
@[simps]
def piToPiTop : (∀ i, πₓ (X i)) ⥤ πₓ (TopCat.of (∀ i, X i))
    where
  obj g := g
  map v₁ v₂ p := Path.Homotopic.pi p
  map_id' := by
    intro x
    change (Path.Homotopic.pi fun i => 𝟙 (x i)) = _
    simp only [FundamentalGroupoid.id_eq_path_refl, Path.Homotopic.pi_lift]
    rfl
  map_comp' x y z f g := (Path.Homotopic.comp_pi_eq_pi_comp f g).symm
#align fundamental_groupoid_functor.pi_to_pi_Top FundamentalGroupoidFunctor.piToPiTop
-/

#print FundamentalGroupoidFunctor.piIso /-
/-- Shows `pi_to_pi_Top` is an isomorphism, whose inverse is precisely the pi product
of the induced projections. This shows that `fundamental_groupoid_functor` preserves products.
-/
@[simps]
def piIso : CategoryTheory.Grpd.of (∀ i : I, πₓ (X i)) ≅ πₓ (TopCat.of (∀ i, X i))
    where
  Hom := piToPiTop X
  inv := CategoryTheory.Functor.pi' (proj X)
  hom_inv_id' := by
    change pi_to_pi_Top X ⋙ CategoryTheory.Functor.pi' (proj X) = 𝟭 _
    apply CategoryTheory.Functor.ext <;> intros
    · ext; simp; · rfl
  inv_hom_id' := by
    change CategoryTheory.Functor.pi' (proj X) ⋙ pi_to_pi_Top X = 𝟭 _
    apply CategoryTheory.Functor.ext <;> intros
    · suffices Path.Homotopic.pi ((CategoryTheory.Functor.pi' (proj X)).map f) = f by simpa
      change (CategoryTheory.Functor.pi' (proj X)).map f with fun i =>
        (CategoryTheory.Functor.pi' (proj X)).map f i
      simp
    · rfl
#align fundamental_groupoid_functor.pi_iso FundamentalGroupoidFunctor.piIso
-/

section Preserves

open CategoryTheory

#print FundamentalGroupoidFunctor.coneDiscreteComp /-
/-- Equivalence between the categories of cones over the objects `π Xᵢ` written in two ways -/
def coneDiscreteComp :
    Limits.Cone (Discrete.functor X ⋙ π) ≌ Limits.Cone (Discrete.functor fun i => πₓ (X i)) :=
  Limits.Cones.postcomposeEquivalence (Discrete.compNatIsoDiscrete X π)
#align fundamental_groupoid_functor.cone_discrete_comp FundamentalGroupoidFunctor.coneDiscreteComp
-/

#print FundamentalGroupoidFunctor.coneDiscreteComp_obj_mapCone /-
theorem coneDiscreteComp_obj_mapCone :
    (coneDiscreteComp X).Functor.obj (π.mapCone (TopCat.piFan.{u} X)) =
      Limits.Fan.mk (πₓ (TopCat.of (∀ i, X i))) (proj X) :=
  rfl
#align fundamental_groupoid_functor.cone_discrete_comp_obj_map_cone FundamentalGroupoidFunctor.coneDiscreteComp_obj_mapCone
-/

#print FundamentalGroupoidFunctor.piTopToPiCone /-
/-- This is `pi_iso.inv` as a cone morphism (in fact, isomorphism) -/
def piTopToPiCone :
    Limits.Fan.mk (πₓ (TopCat.of (∀ i, X i))) (proj X) ⟶ Grpd.piLimitFan fun i : I => πₓ (X i)
    where Hom := CategoryTheory.Functor.pi' (proj X)
#align fundamental_groupoid_functor.pi_Top_to_pi_cone FundamentalGroupoidFunctor.piTopToPiCone
-/

instance : IsIso (piTopToPiCone X) :=
  haveI : is_iso (pi_Top_to_pi_cone X).Hom := (inferInstance : is_iso (pi_iso X).inv)
  limits.cones.cone_iso_of_hom_iso (pi_Top_to_pi_cone X)

#print FundamentalGroupoidFunctor.preservesProduct /-
/-- The fundamental groupoid functor preserves products -/
def preservesProduct : Limits.PreservesLimit (Discrete.functor X) π :=
  by
  apply limits.preserves_limit_of_preserves_limit_cone (TopCat.piFanIsLimit.{u} X)
  apply (limits.is_limit.of_cone_equiv (cone_discrete_comp X)).toFun
  simp only [cone_discrete_comp_obj_map_cone]
  apply limits.is_limit.of_iso_limit _ (as_iso (pi_Top_to_pi_cone X)).symm
  exact Groupoid.pi_limit_fan_is_limit _
#align fundamental_groupoid_functor.preserves_product FundamentalGroupoidFunctor.preservesProduct
-/

end Preserves

end Pi

section Prod

variable (A B : TopCat.{u})

#print FundamentalGroupoidFunctor.projLeft /-
/-- The induced map of the left projection map X × Y → X -/
def projLeft : πₓ (TopCat.of (A × B)) ⥤ πₓ A :=
  πₘ ⟨_, continuous_fst⟩
#align fundamental_groupoid_functor.proj_left FundamentalGroupoidFunctor.projLeft
-/

#print FundamentalGroupoidFunctor.projRight /-
/-- The induced map of the right projection map X × Y → Y -/
def projRight : πₓ (TopCat.of (A × B)) ⥤ πₓ B :=
  πₘ ⟨_, continuous_snd⟩
#align fundamental_groupoid_functor.proj_right FundamentalGroupoidFunctor.projRight
-/

#print FundamentalGroupoidFunctor.projLeft_map /-
@[simp]
theorem projLeft_map (x₀ x₁ : πₓ (TopCat.of (A × B))) (p : x₀ ⟶ x₁) :
    (projLeft A B).map p = Path.Homotopic.projLeft p :=
  rfl
#align fundamental_groupoid_functor.proj_left_map FundamentalGroupoidFunctor.projLeft_map
-/

#print FundamentalGroupoidFunctor.projRight_map /-
@[simp]
theorem projRight_map (x₀ x₁ : πₓ (TopCat.of (A × B))) (p : x₀ ⟶ x₁) :
    (projRight A B).map p = Path.Homotopic.projRight p :=
  rfl
#align fundamental_groupoid_functor.proj_right_map FundamentalGroupoidFunctor.projRight_map
-/

#print FundamentalGroupoidFunctor.prodToProdTop /-
/--
The map taking the product of two fundamental groupoids to the fundamental groupoid of the product
of the two topological spaces. This is in fact an isomorphism (see `prod_iso`).
-/
@[simps obj]
def prodToProdTop : πₓ A × πₓ B ⥤ πₓ (TopCat.of (A × B))
    where
  obj g := g
  map x y p :=
    match x, y, p with
    | (x₀, x₁), (y₀, y₁), (p₀, p₁) => Path.Homotopic.prod p₀ p₁
  map_id' := by
    rintro ⟨x₀, x₁⟩
    simp only [CategoryTheory.prod_id, FundamentalGroupoid.id_eq_path_refl]
    unfold_aux; rw [Path.Homotopic.prod_lift]; rfl
  map_comp' x y z f g :=
    match x, y, z, f, g with
    | (x₀, x₁), (y₀, y₁), (z₀, z₁), (f₀, f₁), (g₀, g₁) =>
      (Path.Homotopic.comp_prod_eq_prod_comp f₀ f₁ g₀ g₁).symm
#align fundamental_groupoid_functor.prod_to_prod_Top FundamentalGroupoidFunctor.prodToProdTop
-/

#print FundamentalGroupoidFunctor.prodToProdTop_map /-
theorem prodToProdTop_map {x₀ x₁ : πₓ A} {y₀ y₁ : πₓ B} (p₀ : x₀ ⟶ x₁) (p₁ : y₀ ⟶ y₁) :
    @CategoryTheory.Functor.map _ _ _ _ (prodToProdTop A B) (x₀, y₀) (x₁, y₁) (p₀, p₁) =
      Path.Homotopic.prod p₀ p₁ :=
  rfl
#align fundamental_groupoid_functor.prod_to_prod_Top_map FundamentalGroupoidFunctor.prodToProdTop_map
-/

#print FundamentalGroupoidFunctor.prodIso /-
/-- Shows `prod_to_prod_Top` is an isomorphism, whose inverse is precisely the product
of the induced left and right projections.
-/
@[simps]
def prodIso : CategoryTheory.Grpd.of (πₓ A × πₓ B) ≅ πₓ (TopCat.of (A × B))
    where
  Hom := prodToProdTop A B
  inv := (projLeft A B).prod' (projRight A B)
  hom_inv_id' :=
    by
    change prod_to_prod_Top A B ⋙ (proj_left A B).prod' (proj_right A B) = 𝟭 _
    apply CategoryTheory.Functor.hext; · intros; ext <;> simp <;> rfl
    rintro ⟨x₀, x₁⟩ ⟨y₀, y₁⟩ ⟨f₀, f₁⟩
    have := And.intro (Path.Homotopic.projLeft_prod f₀ f₁) (Path.Homotopic.projRight_prod f₀ f₁)
    simpa
  inv_hom_id' :=
    by
    change (proj_left A B).prod' (proj_right A B) ⋙ prod_to_prod_Top A B = 𝟭 _
    apply CategoryTheory.Functor.hext; · intros; ext <;> simp <;> rfl
    rintro ⟨x₀, x₁⟩ ⟨y₀, y₁⟩ f
    have := Path.Homotopic.prod_projLeft_projRight f
    simpa
#align fundamental_groupoid_functor.prod_iso FundamentalGroupoidFunctor.prodIso
-/

end Prod

end FundamentalGroupoidFunctor

