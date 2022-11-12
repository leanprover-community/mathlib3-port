/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison
-/
import Mathbin.CategoryTheory.Limits.ColimitLimit
import Mathbin.CategoryTheory.Limits.Preserves.FunctorCategory
import Mathbin.CategoryTheory.Limits.Preserves.Finite
import Mathbin.CategoryTheory.Limits.Shapes.FiniteLimits
import Mathbin.CategoryTheory.Limits.Preserves.Filtered
import Mathbin.CategoryTheory.ConcreteCategory.Basic

/-!
# Filtered colimits commute with finite limits.

We show that for a functor `F : J × K ⥤ Type v`, when `J` is finite and `K` is filtered,
the universal morphism `colimit_limit_to_limit_colimit F` comparing the
colimit (over `K`) of the limits (over `J`) with the limit of the colimits is an isomorphism.

(In fact, to prove that it is injective only requires that `J` has finitely many objects.)

## References
* Borceux, Handbook of categorical algebra 1, Theorem 2.13.4
* [Stacks: Filtered colimits](https://stacks.math.columbia.edu/tag/002W)
-/


universe v u

open CategoryTheory

open CategoryTheory.Category

open CategoryTheory.Limits.Types

open CategoryTheory.Limits.Types.FilteredColimit

namespace CategoryTheory.Limits

variable {J K : Type v} [SmallCategory J] [SmallCategory K]

variable (F : J × K ⥤ Type v)

open CategoryTheory.prod

variable [IsFiltered K]

section

/-!
Injectivity doesn't need that we have finitely many morphisms in `J`,
only that there are finitely many objects.
-/


variable [Finite J]

/-- This follows this proof from
* Borceux, Handbook of categorical algebra 1, Theorem 2.13.4
-/
theorem colimit_limit_to_limit_colimit_injective : Function.Injective (colimitLimitToLimitColimit F) := by
  classical cases nonempty_fintype J
    -- These elements of the colimit have representatives somewhere:
    obtain ⟨kx, x, rfl⟩ := jointly_surjective'.{v, v} x
    dsimp at x y
    -- and they are equations in a filtered colimit,
    -- so for each `j` we have some place `k j` to the right of both `kx` and `ky`
    simp [colimit_eq_iff.{v, v}] at h
    let f : ∀ j, kx ⟶ k j := fun j => (h j).some_spec.some
    -- where the images of the components of the representatives become equal:
    have w :
      ∀ j,
        F.map ((𝟙 j, f j) : (j, kx) ⟶ (j, k j)) (limit.π ((curry.obj (swap K J ⋙ F)).obj kx) j x) =
          F.map ((𝟙 j, g j) : (j, ky) ⟶ (j, k j)) (limit.π ((curry.obj (swap K J ⋙ F)).obj ky) j y) :=
      fun j => (h j).some_spec.some_spec.some_spec
    have kxO : kx ∈ O := finset.mem_union.mpr (Or.inr (by simp))
    have kjO : ∀ j, k j ∈ O := fun j => finset.mem_union.mpr (Or.inl (by simp))
    obtain ⟨S, T, W⟩ := is_filtered.sup_exists O H
    have gH : ∀ j, (⟨ky, k j, kyO, kjO j, g j⟩ : Σ'(X Y : K)(mX : X ∈ O)(mY : Y ∈ O), X ⟶ Y) ∈ H := fun j =>
      finset.mem_union.mpr
        (Or.inr
          (by
            simp only [true_and_iff, Finset.mem_univ, eq_self_iff_true, exists_prop_of_true, Finset.mem_image,
              heq_iff_eq]
            refine' ⟨j, rfl, _⟩
            simp only [heq_iff_eq]
            exact ⟨rfl, rfl, rfl⟩))
    -- We can check if two elements of a limit (in `Type`) are equal by comparing them componentwise.
    ext
    rw [← W _ _ (fH j)]
    simp [w]
#align
  category_theory.limits.colimit_limit_to_limit_colimit_injective CategoryTheory.Limits.colimit_limit_to_limit_colimit_injective

end

variable [FinCategory J]

/-- This follows this proof from
* Borceux, Handbook of categorical algebra 1, Theorem 2.13.4
although with different names.
-/
theorem colimit_limit_to_limit_colimit_surjective : Function.Surjective (colimitLimitToLimitColimit F) := by
  classical-- We begin with some element `x` in the limit (over J) over the colimits (over K),
    intro x
    -- `k : J ⟶ K` records where the representative of the element in the `j`-th element of `x` lives
    let k : J → K := fun j => (z j).some
    -- and we record that these representatives, when mapped back into the relevant colimits,
    -- are actually the components of `x`.
    have e : ∀ j, colimit.ι ((curry.obj F).obj j) (k j) (y j) = limit.π (curry.obj F ⋙ limits.colim) j x := fun j =>
      (z j).some_spec.some_spec
    -- A little tidying up of things we no longer need.
    clear z
    -- and name the morphisms as `g j : k j ⟶ k'`.
    have g : ∀ j, k j ⟶ k' := fun j => is_filtered.to_sup (finset.univ.image k) ∅ (by simp)
    -- Recalling that the components of `x`, which are indexed by `j : J`, are "coherent",
    -- in other words preserved by morphisms in the `J` direction,
    -- we see that for any morphism `f : j ⟶ j'` in `J`,
    -- the images of `y j` and `y j'`, when mapped to `F.obj (j', k')` respectively by
    -- `(f, g j)` and `(𝟙 j', g j')`, both represent the same element in the colimit.
    have w :
      ∀ {j j' : J} (f : j ⟶ j'),
        colimit.ι ((curry.obj F).obj j') k' (F.map ((𝟙 j', g j') : (j', k j') ⟶ (j', k')) (y j')) =
          colimit.ι ((curry.obj F).obj j') k' (F.map ((f, g j) : (j, k j) ⟶ (j', k')) (y j))
    -- Because `K` is filtered, we can restate this as saying that
    -- for each such `f`, there is some place to the right of `k'`
    -- where these images of `y j` and `y j'` become equal.
    simp_rw [colimit_eq_iff.{v, v}] at w
    let gf : ∀ {j j'} (f : j ⟶ j'), k' ⟶ kf f := fun _ _ f => (w f).some_spec.some
    have wf :
      ∀ {j j'} (f : j ⟶ j'),
        F.map ((𝟙 j', g j' ≫ gf f) : (j', k j') ⟶ (j', kf f)) (y j') =
          F.map ((f, g j ≫ hf f) : (j, k j) ⟶ (j', kf f)) (y j) :=
      fun j j' f => by
      have q : ((curry.obj F).obj j').map (gf f) (F.map _ (y j')) = ((curry.obj F).obj j').map (hf f) (F.map _ (y j)) :=
        (w f).some_spec.some_spec.some_spec
      dsimp at q
      simp_rw [← functor_to_types.map_comp_apply] at q
      convert q <;> simp only [comp_id]
    -- and clean up some things that are no longer needed.
    clear w
    have kfO : ∀ {j j'} (f : j ⟶ j'), kf f ∈ O := fun j j' f =>
      finset.mem_union.mpr
        (Or.inl
          (by
            rw [Finset.mem_bUnion]
            refine' ⟨j, Finset.mem_univ j, _⟩
            rw [Finset.mem_bUnion]
            refine' ⟨j', Finset.mem_univ j', _⟩
            rw [Finset.mem_image]
            refine' ⟨f, Finset.mem_univ _, _⟩
            rfl))
    let H : Finset (Σ'(X Y : K)(mX : X ∈ O)(mY : Y ∈ O), X ⟶ Y) :=
      finset.univ.bUnion fun j : J =>
        finset.univ.bUnion fun j' : J =>
          finset.univ.bUnion fun f : j ⟶ j' => {⟨k', kf f, k'O, kfO f, gf f⟩, ⟨k', kf f, k'O, kfO f, hf f⟩}
    -- We then restate this slightly more conveniently, as a family of morphism `i f : kf f ⟶ k''`,
    -- satisfying `gf f ≫ i f = hf f' ≫ i f'`.
    let i : ∀ {j j'} (f : j ⟶ j'), kf f ⟶ k'' := fun j j' f => i' (kfO f)
    clear_value i
    -- We're finally ready to construct the pre-image, and verify it really maps to `x`.
    fconstructor
    -- Finally we check that this maps to `x`.
    · -- We can do this componentwise:
      apply limit_ext'
      intro j
      -- and as each component is an equation in a colimit, we can verify it by
      -- pointing out the morphism which carries one representative to the other:
      simp only [← e, colimit_eq_iff.{v, v}, curry_obj_obj_map, limit.π_mk', bifunctor.map_id_comp, id.def,
        types_comp_apply, limits.ι_colimit_limit_to_limit_colimit_π_apply]
      refine' ⟨k'', 𝟙 k'', g j ≫ gf (𝟙 j) ≫ i (𝟙 j), _⟩
      simp only [bifunctor.map_id_comp, types_comp_apply, bifunctor.map_id, types_id_apply]
      
#align
  category_theory.limits.colimit_limit_to_limit_colimit_surjective CategoryTheory.Limits.colimit_limit_to_limit_colimit_surjective

instance colimit_limit_to_limit_colimit_is_iso : IsIso (colimitLimitToLimitColimit F) :=
  (is_iso_iff_bijective _).mpr ⟨colimit_limit_to_limit_colimit_injective F, colimit_limit_to_limit_colimit_surjective F⟩
#align
  category_theory.limits.colimit_limit_to_limit_colimit_is_iso CategoryTheory.Limits.colimit_limit_to_limit_colimit_is_iso

instance colimit_limit_to_limit_colimit_cone_iso (F : J ⥤ K ⥤ Type v) : IsIso (colimitLimitToLimitColimitCone F) := by
  have : is_iso (colimit_limit_to_limit_colimit_cone F).Hom := by
    dsimp only [colimit_limit_to_limit_colimit_cone]
    infer_instance
  apply cones.cone_iso_of_hom_iso
#align
  category_theory.limits.colimit_limit_to_limit_colimit_cone_iso CategoryTheory.Limits.colimit_limit_to_limit_colimit_cone_iso

noncomputable instance filteredColimPreservesFiniteLimitsOfTypes : PreservesFiniteLimits (colim : (K ⥤ Type v) ⥤ _) :=
  by
  apply preservesFiniteLimitsOfPreservesFiniteLimitsOfSize.{v}
  intro J _ _
  skip
  constructor
  intro F
  constructor
  intro c hc
  apply is_limit.of_iso_limit (limit.is_limit _)
  symm
  trans colim.map_cone (limit.cone F)
  exact functor.map_iso _ (hc.unique_up_to_iso (limit.is_limit F))
  exact as_iso (colimitLimitToLimitColimitCone.{v, v + 1} F)
#align
  category_theory.limits.filtered_colim_preserves_finite_limits_of_types CategoryTheory.Limits.filteredColimPreservesFiniteLimitsOfTypes

variable {C : Type u} [Category.{v} C] [ConcreteCategory.{v} C]

section

variable [HasLimitsOfShape J C] [HasColimitsOfShape K C]

variable [ReflectsLimitsOfShape J (forget C)] [PreservesColimitsOfShape K (forget C)]

variable [PreservesLimitsOfShape J (forget C)]

noncomputable instance filteredColimPreservesFiniteLimits : PreservesLimitsOfShape J (colim : (K ⥤ C) ⥤ _) :=
  haveI : preserves_limits_of_shape J ((colim : (K ⥤ C) ⥤ _) ⋙ forget C) :=
    preserves_limits_of_shape_of_nat_iso (preserves_colimit_nat_iso _).symm
  preserves_limits_of_shape_of_reflects_of_preserves _ (forget C)
#align
  category_theory.limits.filtered_colim_preserves_finite_limits CategoryTheory.Limits.filteredColimPreservesFiniteLimits

end

attribute [local instance] reflects_limits_of_shape_of_reflects_isomorphisms

noncomputable instance [PreservesFiniteLimits (forget C)] [PreservesFilteredColimits (forget C)] [HasFiniteLimits C]
    [HasColimitsOfShape K C] [ReflectsIsomorphisms (forget C)] : PreservesFiniteLimits (colim : (K ⥤ C) ⥤ _) := by
  apply preservesFiniteLimitsOfPreservesFiniteLimitsOfSize.{v}
  intro J _ _
  skip
  infer_instance

section

variable [HasLimitsOfShape J C] [HasColimitsOfShape K C]

variable [ReflectsLimitsOfShape J (forget C)] [PreservesColimitsOfShape K (forget C)]

variable [PreservesLimitsOfShape J (forget C)]

/-- A curried version of the fact that filtered colimits commute with finite limits. -/
noncomputable def colimitLimitIso (F : J ⥤ K ⥤ C) : colimit (limit F) ≅ limit (colimit F.flip) :=
  (isLimitOfPreserves colim (limit.isLimit _)).conePointUniqueUpToIso (limit.isLimit _) ≪≫
    HasLimit.isoOfNatIso (colimitFlipIsoCompColim _).symm
#align category_theory.limits.colimit_limit_iso CategoryTheory.Limits.colimitLimitIso

@[simp, reassoc]
theorem ι_colimit_limit_iso_limit_π (F : J ⥤ K ⥤ C) (a) (b) :
    colimit.ι (limit F) a ≫ (colimitLimitIso F).Hom ≫ limit.π (colimit F.flip) b =
      (limit.π F b).app a ≫ (colimit.ι F.flip a).app b :=
  by
  dsimp [colimit_limit_iso]
  simp only [functor.map_cone_π_app, iso.symm_hom, limits.limit.cone_point_unique_up_to_iso_hom_comp_assoc,
    limits.limit.cone_π, limits.colimit.ι_map_assoc, limits.colimit_flip_iso_comp_colim_inv_app, assoc,
    limits.has_limit.iso_of_nat_iso_hom_π]
  congr 1
  simp only [← category.assoc, iso.comp_inv_eq, limits.colimit_obj_iso_colimit_comp_evaluation_ι_app_hom,
    limits.has_colimit.iso_of_nat_iso_ι_hom, nat_iso.of_components_hom_app]
  dsimp
  simp
#align category_theory.limits.ι_colimit_limit_iso_limit_π CategoryTheory.Limits.ι_colimit_limit_iso_limit_π

end

end CategoryTheory.Limits

