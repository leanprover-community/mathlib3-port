/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison, Justus Springer

! This file was ported from Lean 3 source module category_theory.limits.lattice
! leanprover-community/mathlib commit 69c6a5a12d8a2b159f20933e60115a4f2de62b58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.CompleteLattice
import Mathbin.Data.Fintype.Lattice
import Mathbin.CategoryTheory.Limits.Shapes.Pullbacks
import Mathbin.CategoryTheory.Category.Preorder
import Mathbin.CategoryTheory.Limits.Shapes.Products
import Mathbin.CategoryTheory.Limits.Shapes.FiniteLimits

/-!
# Limits in lattice categories are given by infimums and supremums.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


universe w u

open CategoryTheory

open CategoryTheory.Limits

namespace CategoryTheory.Limits.CompleteLattice

section Semilattice

variable {α : Type u}

variable {J : Type w} [SmallCategory J] [FinCategory J]

#print CategoryTheory.Limits.CompleteLattice.finiteLimitCone /-
/-- The limit cone over any functor from a finite diagram into a `semilattice_inf` with `order_top`.
-/
def finiteLimitCone [SemilatticeInf α] [OrderTop α] (F : J ⥤ α) : LimitCone F
    where
  Cone :=
    { pt := Finset.univ.inf F.obj
      π := { app := fun j => homOfLE (Finset.inf_le (Fintype.complete _)) } }
  IsLimit := { lift := fun s => homOfLE (Finset.le_inf fun j _ => (s.π.app j).down.down) }
#align category_theory.limits.complete_lattice.finite_limit_cone CategoryTheory.Limits.CompleteLattice.finiteLimitCone
-/

#print CategoryTheory.Limits.CompleteLattice.finiteColimitCocone /-
/--
The colimit cocone over any functor from a finite diagram into a `semilattice_sup` with `order_bot`.
-/
def finiteColimitCocone [SemilatticeSup α] [OrderBot α] (F : J ⥤ α) : ColimitCocone F
    where
  Cocone :=
    { pt := Finset.univ.sup F.obj
      ι := { app := fun i => homOfLE (Finset.le_sup (Fintype.complete _)) } }
  IsColimit := { desc := fun s => homOfLE (Finset.sup_le fun j _ => (s.ι.app j).down.down) }
#align category_theory.limits.complete_lattice.finite_colimit_cocone CategoryTheory.Limits.CompleteLattice.finiteColimitCocone
-/

#print CategoryTheory.Limits.CompleteLattice.hasFiniteLimits_of_semilatticeInf_orderTop /-
-- see Note [lower instance priority]
instance (priority := 100) hasFiniteLimits_of_semilatticeInf_orderTop [SemilatticeInf α]
    [OrderTop α] : HasFiniteLimits α :=
  ⟨fun J 𝒥₁ 𝒥₂ => { HasLimit := fun F => has_limit.mk (finite_limit_cone F) }⟩
#align category_theory.limits.complete_lattice.has_finite_limits_of_semilattice_inf_order_top CategoryTheory.Limits.CompleteLattice.hasFiniteLimits_of_semilatticeInf_orderTop
-/

#print CategoryTheory.Limits.CompleteLattice.hasFiniteColimits_of_semilatticeSup_orderBot /-
-- see Note [lower instance priority]
instance (priority := 100) hasFiniteColimits_of_semilatticeSup_orderBot [SemilatticeSup α]
    [OrderBot α] : HasFiniteColimits α :=
  ⟨fun J 𝒥₁ 𝒥₂ => { HasColimit := fun F => has_colimit.mk (finite_colimit_cocone F) }⟩
#align category_theory.limits.complete_lattice.has_finite_colimits_of_semilattice_sup_order_bot CategoryTheory.Limits.CompleteLattice.hasFiniteColimits_of_semilatticeSup_orderBot
-/

/- warning: category_theory.limits.complete_lattice.finite_limit_eq_finset_univ_inf -> CategoryTheory.Limits.CompleteLattice.finite_limit_eq_finset_univ_inf is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u2}} {J : Type.{u1}} [_inst_1 : CategoryTheory.SmallCategory.{u1} J] [_inst_2 : CategoryTheory.FinCategory.{u1} J _inst_1] [_inst_3 : SemilatticeInf.{u2} α] [_inst_4 : OrderTop.{u2} α (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α _inst_3)))] (F : CategoryTheory.Functor.{u1, u2, u1, u2} J _inst_1 α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α _inst_3)))), Eq.{succ u2} α (CategoryTheory.Limits.limit.{u1, u1, u2, u2} J _inst_1 α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α _inst_3))) F (CategoryTheory.Limits.hasLimitOfHasLimitsOfShape.{u1, u1, u2, u2} α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α _inst_3))) J _inst_1 (CategoryTheory.Limits.hasLimitsOfShape_of_hasFiniteLimits.{u1, u2, u2} α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α _inst_3))) J _inst_1 _inst_2 (CategoryTheory.Limits.CompleteLattice.hasFiniteLimits_of_semilatticeInf_orderTop.{u2} α _inst_3 _inst_4)) F)) (Finset.inf.{u2, u1} α J _inst_3 _inst_4 (Finset.univ.{u1} J (CategoryTheory.FinCategory.fintypeObj.{u1} J _inst_1 _inst_2)) (CategoryTheory.Functor.obj.{u1, u2, u1, u2} J _inst_1 α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α _inst_3))) F))
but is expected to have type
  forall {α : Type.{u2}} {J : Type.{u1}} [_inst_1 : CategoryTheory.SmallCategory.{u1} J] [_inst_2 : CategoryTheory.FinCategory.{u1} J _inst_1] [_inst_3 : SemilatticeInf.{u2} α] [_inst_4 : OrderTop.{u2} α (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α _inst_3)))] (F : CategoryTheory.Functor.{u1, u2, u1, u2} J _inst_1 α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α _inst_3)))), Eq.{succ u2} α (CategoryTheory.Limits.limit.{u1, u1, u2, u2} J _inst_1 α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α _inst_3))) F (CategoryTheory.Limits.hasLimitOfHasLimitsOfShape.{u1, u1, u2, u2} α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α _inst_3))) J _inst_1 (CategoryTheory.Limits.hasLimitsOfShape_of_hasFiniteLimits.{u1, u2, u2} α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α _inst_3))) J _inst_1 _inst_2 (CategoryTheory.Limits.CompleteLattice.hasFiniteLimits_of_semilatticeInf_orderTop.{u2} α _inst_3 _inst_4)) F)) (Finset.inf.{u2, u1} α J _inst_3 _inst_4 (Finset.univ.{u1} J (CategoryTheory.FinCategory.fintypeObj.{u1} J _inst_1 _inst_2)) (Prefunctor.obj.{succ u1, succ u2, u1, u2} J (CategoryTheory.CategoryStruct.toQuiver.{u1, u1} J (CategoryTheory.Category.toCategoryStruct.{u1, u1} J _inst_1)) α (CategoryTheory.CategoryStruct.toQuiver.{u2, u2} α (CategoryTheory.Category.toCategoryStruct.{u2, u2} α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α _inst_3))))) (CategoryTheory.Functor.toPrefunctor.{u1, u2, u1, u2} J _inst_1 α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α _inst_3))) F)))
Case conversion may be inaccurate. Consider using '#align category_theory.limits.complete_lattice.finite_limit_eq_finset_univ_inf CategoryTheory.Limits.CompleteLattice.finite_limit_eq_finset_univ_infₓ'. -/
/-- The limit of a functor from a finite diagram into a `semilattice_inf` with `order_top` is the
infimum of the objects in the image.
-/
theorem finite_limit_eq_finset_univ_inf [SemilatticeInf α] [OrderTop α] (F : J ⥤ α) :
    limit F = Finset.univ.inf F.obj :=
  (IsLimit.conePointUniqueUpToIso (limit.isLimit F) (finiteLimitCone F).IsLimit).to_eq
#align category_theory.limits.complete_lattice.finite_limit_eq_finset_univ_inf CategoryTheory.Limits.CompleteLattice.finite_limit_eq_finset_univ_inf

/- warning: category_theory.limits.complete_lattice.finite_colimit_eq_finset_univ_sup -> CategoryTheory.Limits.CompleteLattice.finite_colimit_eq_finset_univ_sup is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u2}} {J : Type.{u1}} [_inst_1 : CategoryTheory.SmallCategory.{u1} J] [_inst_2 : CategoryTheory.FinCategory.{u1} J _inst_1] [_inst_3 : SemilatticeSup.{u2} α] [_inst_4 : OrderBot.{u2} α (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeSup.toPartialOrder.{u2} α _inst_3)))] (F : CategoryTheory.Functor.{u1, u2, u1, u2} J _inst_1 α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeSup.toPartialOrder.{u2} α _inst_3)))), Eq.{succ u2} α (CategoryTheory.Limits.colimit.{u1, u1, u2, u2} J _inst_1 α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeSup.toPartialOrder.{u2} α _inst_3))) F (CategoryTheory.Limits.hasColimitOfHasColimitsOfShape.{u1, u1, u2, u2} α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeSup.toPartialOrder.{u2} α _inst_3))) J _inst_1 (CategoryTheory.Limits.hasColimitsOfShape_of_hasFiniteColimits.{u1, u2, u2} α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeSup.toPartialOrder.{u2} α _inst_3))) J _inst_1 _inst_2 (CategoryTheory.Limits.CompleteLattice.hasFiniteColimits_of_semilatticeSup_orderBot.{u2} α _inst_3 _inst_4)) F)) (Finset.sup.{u2, u1} α J _inst_3 _inst_4 (Finset.univ.{u1} J (CategoryTheory.FinCategory.fintypeObj.{u1} J _inst_1 _inst_2)) (CategoryTheory.Functor.obj.{u1, u2, u1, u2} J _inst_1 α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeSup.toPartialOrder.{u2} α _inst_3))) F))
but is expected to have type
  forall {α : Type.{u2}} {J : Type.{u1}} [_inst_1 : CategoryTheory.SmallCategory.{u1} J] [_inst_2 : CategoryTheory.FinCategory.{u1} J _inst_1] [_inst_3 : SemilatticeSup.{u2} α] [_inst_4 : OrderBot.{u2} α (Preorder.toLE.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeSup.toPartialOrder.{u2} α _inst_3)))] (F : CategoryTheory.Functor.{u1, u2, u1, u2} J _inst_1 α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeSup.toPartialOrder.{u2} α _inst_3)))), Eq.{succ u2} α (CategoryTheory.Limits.colimit.{u1, u1, u2, u2} J _inst_1 α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeSup.toPartialOrder.{u2} α _inst_3))) F (CategoryTheory.Limits.hasColimitOfHasColimitsOfShape.{u1, u1, u2, u2} α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeSup.toPartialOrder.{u2} α _inst_3))) J _inst_1 (CategoryTheory.Limits.hasColimitsOfShape_of_hasFiniteColimits.{u1, u2, u2} α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeSup.toPartialOrder.{u2} α _inst_3))) J _inst_1 _inst_2 (CategoryTheory.Limits.CompleteLattice.hasFiniteColimits_of_semilatticeSup_orderBot.{u2} α _inst_3 _inst_4)) F)) (Finset.sup.{u2, u1} α J _inst_3 _inst_4 (Finset.univ.{u1} J (CategoryTheory.FinCategory.fintypeObj.{u1} J _inst_1 _inst_2)) (Prefunctor.obj.{succ u1, succ u2, u1, u2} J (CategoryTheory.CategoryStruct.toQuiver.{u1, u1} J (CategoryTheory.Category.toCategoryStruct.{u1, u1} J _inst_1)) α (CategoryTheory.CategoryStruct.toQuiver.{u2, u2} α (CategoryTheory.Category.toCategoryStruct.{u2, u2} α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeSup.toPartialOrder.{u2} α _inst_3))))) (CategoryTheory.Functor.toPrefunctor.{u1, u2, u1, u2} J _inst_1 α (Preorder.smallCategory.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeSup.toPartialOrder.{u2} α _inst_3))) F)))
Case conversion may be inaccurate. Consider using '#align category_theory.limits.complete_lattice.finite_colimit_eq_finset_univ_sup CategoryTheory.Limits.CompleteLattice.finite_colimit_eq_finset_univ_supₓ'. -/
/-- The colimit of a functor from a finite diagram into a `semilattice_sup` with `order_bot`
is the supremum of the objects in the image.
-/
theorem finite_colimit_eq_finset_univ_sup [SemilatticeSup α] [OrderBot α] (F : J ⥤ α) :
    colimit F = Finset.univ.sup F.obj :=
  (IsColimit.coconePointUniqueUpToIso (colimit.isColimit F) (finiteColimitCocone F).IsColimit).to_eq
#align category_theory.limits.complete_lattice.finite_colimit_eq_finset_univ_sup CategoryTheory.Limits.CompleteLattice.finite_colimit_eq_finset_univ_sup

#print CategoryTheory.Limits.CompleteLattice.finite_product_eq_finset_inf /-
/--
A finite product in the category of a `semilattice_inf` with `order_top` is the same as the infimum.
-/
theorem finite_product_eq_finset_inf [SemilatticeInf α] [OrderTop α] {ι : Type u} [Fintype ι]
    (f : ι → α) : (∏ f) = (Fintype.elems ι).inf f :=
  by
  trans
  exact
    (is_limit.cone_point_unique_up_to_iso (limit.is_limit _)
        (finite_limit_cone (discrete.functor f)).IsLimit).to_eq
  change finset.univ.inf (f ∘ discrete_equiv.to_embedding) = (Fintype.elems ι).inf f
  simp only [← Finset.inf_map, Finset.univ_map_equiv_to_embedding]
  rfl
#align category_theory.limits.complete_lattice.finite_product_eq_finset_inf CategoryTheory.Limits.CompleteLattice.finite_product_eq_finset_inf
-/

#print CategoryTheory.Limits.CompleteLattice.finite_coproduct_eq_finset_sup /-
/-- A finite coproduct in the category of a `semilattice_sup` with `order_bot` is the same as the
supremum.
-/
theorem finite_coproduct_eq_finset_sup [SemilatticeSup α] [OrderBot α] {ι : Type u} [Fintype ι]
    (f : ι → α) : (∐ f) = (Fintype.elems ι).sup f :=
  by
  trans
  exact
    (is_colimit.cocone_point_unique_up_to_iso (colimit.is_colimit _)
        (finite_colimit_cocone (discrete.functor f)).IsColimit).to_eq
  change finset.univ.sup (f ∘ discrete_equiv.to_embedding) = (Fintype.elems ι).sup f
  simp only [← Finset.sup_map, Finset.univ_map_equiv_to_embedding]
  rfl
#align category_theory.limits.complete_lattice.finite_coproduct_eq_finset_sup CategoryTheory.Limits.CompleteLattice.finite_coproduct_eq_finset_sup
-/

-- see Note [lower instance priority]
instance (priority := 100) [SemilatticeInf α] [OrderTop α] : HasBinaryProducts α :=
  by
  have : ∀ x y : α, has_limit (pair x y) :=
    by
    letI := hasFiniteLimits_of_hasFiniteLimits_of_size.{u} α
    infer_instance
  apply has_binary_products_of_has_limit_pair

/- warning: category_theory.limits.complete_lattice.prod_eq_inf -> CategoryTheory.Limits.CompleteLattice.prod_eq_inf is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_3 : SemilatticeInf.{u1} α] [_inst_4 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3)))] (x : α) (y : α), Eq.{succ u1} α (CategoryTheory.Limits.prod.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))) x y (CategoryTheory.Limits.hasLimitOfHasLimitsOfShape.{0, 0, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))) (CategoryTheory.Discrete.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.discreteCategory.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.Limits.CompleteLattice.CategoryTheory.Limits.hasBinaryProducts.{u1} α _inst_3 _inst_4) (CategoryTheory.Limits.pair.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))) x y))) (Inf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α _inst_3) x y)
but is expected to have type
  forall {α : Type.{u1}} [_inst_3 : SemilatticeInf.{u1} α] [_inst_4 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3)))] (x : α) (y : α), Eq.{succ u1} α (CategoryTheory.Limits.prod.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))) x y (CategoryTheory.Limits.hasLimitOfHasLimitsOfShape.{0, 0, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))) (CategoryTheory.Discrete.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.discreteCategory.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.Limits.CompleteLattice.instHasBinaryProductsSmallCategoryToPreorderToPartialOrder.{u1} α _inst_3 _inst_4) (CategoryTheory.Limits.pair.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))) x y))) (Inf.inf.{u1} α (SemilatticeInf.toInf.{u1} α _inst_3) x y)
Case conversion may be inaccurate. Consider using '#align category_theory.limits.complete_lattice.prod_eq_inf CategoryTheory.Limits.CompleteLattice.prod_eq_infₓ'. -/
/-- The binary product in the category of a `semilattice_inf` with `order_top` is the same as the
infimum.
-/
@[simp]
theorem prod_eq_inf [SemilatticeInf α] [OrderTop α] (x y : α) : Limits.prod x y = x ⊓ y :=
  calc
    Limits.prod x y = limit (pair x y) := rfl
    _ = Finset.univ.inf (pair x y).obj := by rw [finite_limit_eq_finset_univ_inf (pair.{u} x y)]
    _ = x ⊓ (y ⊓ ⊤) := rfl
    -- Note: finset.inf is realized as a fold, hence the definitional equality
        _ =
        x ⊓ y :=
      by rw [inf_top_eq]
    
#align category_theory.limits.complete_lattice.prod_eq_inf CategoryTheory.Limits.CompleteLattice.prod_eq_inf

-- see Note [lower instance priority]
instance (priority := 100) [SemilatticeSup α] [OrderBot α] : HasBinaryCoproducts α :=
  by
  have : ∀ x y : α, has_colimit (pair x y) :=
    by
    letI := hasFiniteColimits_of_hasFiniteColimits_of_size.{u} α
    infer_instance
  apply has_binary_coproducts_of_has_colimit_pair

/- warning: category_theory.limits.complete_lattice.coprod_eq_sup -> CategoryTheory.Limits.CompleteLattice.coprod_eq_sup is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_3 : SemilatticeSup.{u1} α] [_inst_4 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3)))] (x : α) (y : α), Eq.{succ u1} α (CategoryTheory.Limits.coprod.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))) x y (CategoryTheory.Limits.hasColimitOfHasColimitsOfShape.{0, 0, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))) (CategoryTheory.Discrete.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.discreteCategory.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.Limits.CompleteLattice.CategoryTheory.Limits.hasBinaryCoproducts.{u1} α _inst_3 _inst_4) (CategoryTheory.Limits.pair.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))) x y))) (Sup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α _inst_3) x y)
but is expected to have type
  forall {α : Type.{u1}} [_inst_3 : SemilatticeSup.{u1} α] [_inst_4 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3)))] (x : α) (y : α), Eq.{succ u1} α (CategoryTheory.Limits.coprod.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))) x y (CategoryTheory.Limits.hasColimitOfHasColimitsOfShape.{0, 0, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))) (CategoryTheory.Discrete.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.discreteCategory.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.Limits.CompleteLattice.instHasBinaryCoproductsSmallCategoryToPreorderToPartialOrder.{u1} α _inst_3 _inst_4) (CategoryTheory.Limits.pair.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))) x y))) (Sup.sup.{u1} α (SemilatticeSup.toSup.{u1} α _inst_3) x y)
Case conversion may be inaccurate. Consider using '#align category_theory.limits.complete_lattice.coprod_eq_sup CategoryTheory.Limits.CompleteLattice.coprod_eq_supₓ'. -/
/-- The binary coproduct in the category of a `semilattice_sup` with `order_bot` is the same as the
supremum.
-/
@[simp]
theorem coprod_eq_sup [SemilatticeSup α] [OrderBot α] (x y : α) : Limits.coprod x y = x ⊔ y :=
  calc
    Limits.coprod x y = colimit (pair x y) := rfl
    _ = Finset.univ.sup (pair x y).obj := by rw [finite_colimit_eq_finset_univ_sup (pair x y)]
    _ = x ⊔ (y ⊔ ⊥) := rfl
    -- Note: finset.sup is realized as a fold, hence the definitional equality
        _ =
        x ⊔ y :=
      by rw [sup_bot_eq]
    
#align category_theory.limits.complete_lattice.coprod_eq_sup CategoryTheory.Limits.CompleteLattice.coprod_eq_sup

/- warning: category_theory.limits.complete_lattice.pullback_eq_inf -> CategoryTheory.Limits.CompleteLattice.pullback_eq_inf is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_3 : SemilatticeInf.{u1} α] [_inst_4 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3)))] {x : α} {y : α} {z : α} (f : Quiver.Hom.{succ u1, u1} α (CategoryTheory.CategoryStruct.toQuiver.{u1, u1} α (CategoryTheory.Category.toCategoryStruct.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))))) x z) (g : Quiver.Hom.{succ u1, u1} α (CategoryTheory.CategoryStruct.toQuiver.{u1, u1} α (CategoryTheory.Category.toCategoryStruct.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))))) y z), Eq.{succ u1} α (CategoryTheory.Limits.pullback.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))) x y z f g (CategoryTheory.Limits.hasLimitOfHasLimitsOfShape.{0, 0, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))) CategoryTheory.Limits.WalkingCospan (CategoryTheory.Limits.WidePullbackShape.category.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.Limits.hasLimitsOfShape_of_hasFiniteLimits.{0, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))) CategoryTheory.Limits.WalkingCospan (CategoryTheory.Limits.WidePullbackShape.category.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.Limits.finCategoryWidePullback.{0} CategoryTheory.Limits.WalkingPair CategoryTheory.Limits.fintypeWalkingPair) (CategoryTheory.Limits.CompleteLattice.hasFiniteLimits_of_semilatticeInf_orderTop.{u1} α _inst_3 _inst_4)) (CategoryTheory.Limits.cospan.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))) x y z f g))) (Inf.inf.{u1} α (SemilatticeInf.toHasInf.{u1} α _inst_3) x y)
but is expected to have type
  forall {α : Type.{u1}} [_inst_3 : SemilatticeInf.{u1} α] [_inst_4 : OrderTop.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3)))] {x : α} {y : α} {z : α} (f : Quiver.Hom.{succ u1, u1} α (CategoryTheory.CategoryStruct.toQuiver.{u1, u1} α (CategoryTheory.Category.toCategoryStruct.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))))) x z) (g : Quiver.Hom.{succ u1, u1} α (CategoryTheory.CategoryStruct.toQuiver.{u1, u1} α (CategoryTheory.Category.toCategoryStruct.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))))) y z), Eq.{succ u1} α (CategoryTheory.Limits.pullback.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))) x y z f g (CategoryTheory.Limits.hasLimitOfHasLimitsOfShape.{0, 0, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))) CategoryTheory.Limits.WalkingCospan (CategoryTheory.Limits.WidePullbackShape.category.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.Limits.hasLimitsOfShape_of_hasFiniteLimits.{0, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))) CategoryTheory.Limits.WalkingCospan (CategoryTheory.Limits.WidePullbackShape.category.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.Limits.finCategoryWidePullback.{0} CategoryTheory.Limits.WalkingPair CategoryTheory.Limits.fintypeWalkingPair) (CategoryTheory.Limits.CompleteLattice.hasFiniteLimits_of_semilatticeInf_orderTop.{u1} α _inst_3 _inst_4)) (CategoryTheory.Limits.cospan.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_3))) x y z f g))) (Inf.inf.{u1} α (SemilatticeInf.toInf.{u1} α _inst_3) x y)
Case conversion may be inaccurate. Consider using '#align category_theory.limits.complete_lattice.pullback_eq_inf CategoryTheory.Limits.CompleteLattice.pullback_eq_infₓ'. -/
/-- The pullback in the category of a `semilattice_inf` with `order_top` is the same as the infimum
over the objects.
-/
@[simp]
theorem pullback_eq_inf [SemilatticeInf α] [OrderTop α] {x y z : α} (f : x ⟶ z) (g : y ⟶ z) :
    pullback f g = x ⊓ y :=
  calc
    pullback f g = limit (cospan f g) := rfl
    _ = Finset.univ.inf (cospan f g).obj := by rw [finite_limit_eq_finset_univ_inf]
    _ = z ⊓ (x ⊓ (y ⊓ ⊤)) := rfl
    _ = z ⊓ (x ⊓ y) := by rw [inf_top_eq]
    _ = x ⊓ y := inf_eq_right.mpr (inf_le_of_left_le f.le)
    
#align category_theory.limits.complete_lattice.pullback_eq_inf CategoryTheory.Limits.CompleteLattice.pullback_eq_inf

/- warning: category_theory.limits.complete_lattice.pushout_eq_sup -> CategoryTheory.Limits.CompleteLattice.pushout_eq_sup is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_3 : SemilatticeSup.{u1} α] [_inst_4 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3)))] (x : α) (y : α) (z : α) (f : Quiver.Hom.{succ u1, u1} α (CategoryTheory.CategoryStruct.toQuiver.{u1, u1} α (CategoryTheory.Category.toCategoryStruct.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))))) z x) (g : Quiver.Hom.{succ u1, u1} α (CategoryTheory.CategoryStruct.toQuiver.{u1, u1} α (CategoryTheory.Category.toCategoryStruct.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))))) z y), Eq.{succ u1} α (CategoryTheory.Limits.pushout.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))) z x y f g (CategoryTheory.Limits.hasColimitOfHasColimitsOfShape.{0, 0, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))) CategoryTheory.Limits.WalkingSpan (CategoryTheory.Limits.WidePushoutShape.category.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.Limits.hasColimitsOfShape_of_hasFiniteColimits.{0, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))) CategoryTheory.Limits.WalkingSpan (CategoryTheory.Limits.WidePushoutShape.category.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.Limits.finCategoryWidePushout.{0} CategoryTheory.Limits.WalkingPair CategoryTheory.Limits.fintypeWalkingPair) (CategoryTheory.Limits.CompleteLattice.hasFiniteColimits_of_semilatticeSup_orderBot.{u1} α _inst_3 _inst_4)) (CategoryTheory.Limits.span.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))) z x y f g))) (Sup.sup.{u1} α (SemilatticeSup.toHasSup.{u1} α _inst_3) x y)
but is expected to have type
  forall {α : Type.{u1}} [_inst_3 : SemilatticeSup.{u1} α] [_inst_4 : OrderBot.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3)))] (x : α) (y : α) (z : α) (f : Quiver.Hom.{succ u1, u1} α (CategoryTheory.CategoryStruct.toQuiver.{u1, u1} α (CategoryTheory.Category.toCategoryStruct.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))))) z x) (g : Quiver.Hom.{succ u1, u1} α (CategoryTheory.CategoryStruct.toQuiver.{u1, u1} α (CategoryTheory.Category.toCategoryStruct.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))))) z y), Eq.{succ u1} α (CategoryTheory.Limits.pushout.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))) z x y f g (CategoryTheory.Limits.hasColimitOfHasColimitsOfShape.{0, 0, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))) CategoryTheory.Limits.WalkingSpan (CategoryTheory.Limits.WidePushoutShape.category.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.Limits.hasColimitsOfShape_of_hasFiniteColimits.{0, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))) CategoryTheory.Limits.WalkingSpan (CategoryTheory.Limits.WidePushoutShape.category.{0} CategoryTheory.Limits.WalkingPair) (CategoryTheory.Limits.finCategoryWidePushout.{0} CategoryTheory.Limits.WalkingPair CategoryTheory.Limits.fintypeWalkingPair) (CategoryTheory.Limits.CompleteLattice.hasFiniteColimits_of_semilatticeSup_orderBot.{u1} α _inst_3 _inst_4)) (CategoryTheory.Limits.span.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_3))) z x y f g))) (Sup.sup.{u1} α (SemilatticeSup.toSup.{u1} α _inst_3) x y)
Case conversion may be inaccurate. Consider using '#align category_theory.limits.complete_lattice.pushout_eq_sup CategoryTheory.Limits.CompleteLattice.pushout_eq_supₓ'. -/
/-- The pushout in the category of a `semilattice_sup` with `order_bot` is the same as the supremum
over the objects.
-/
@[simp]
theorem pushout_eq_sup [SemilatticeSup α] [OrderBot α] (x y z : α) (f : z ⟶ x) (g : z ⟶ y) :
    pushout f g = x ⊔ y :=
  calc
    pushout f g = colimit (span f g) := rfl
    _ = Finset.univ.sup (span f g).obj := by rw [finite_colimit_eq_finset_univ_sup]
    _ = z ⊔ (x ⊔ (y ⊔ ⊥)) := rfl
    _ = z ⊔ (x ⊔ y) := by rw [sup_bot_eq]
    _ = x ⊔ y := sup_eq_right.mpr (le_sup_of_le_left f.le)
    
#align category_theory.limits.complete_lattice.pushout_eq_sup CategoryTheory.Limits.CompleteLattice.pushout_eq_sup

end Semilattice

variable {α : Type u} [CompleteLattice α]

variable {J : Type u} [SmallCategory J]

#print CategoryTheory.Limits.CompleteLattice.limitCone /-
/-- The limit cone over any functor into a complete lattice.
-/
def limitCone (F : J ⥤ α) : LimitCone F
    where
  Cone :=
    { pt := infᵢ F.obj
      π := { app := fun j => homOfLE (CompleteLattice.inf_le _ _ (Set.mem_range_self _)) } }
  IsLimit :=
    {
      lift := fun s =>
        homOfLE (CompleteLattice.le_inf _ _ (by rintro _ ⟨j, rfl⟩; exact (s.π.app j).le)) }
#align category_theory.limits.complete_lattice.limit_cone CategoryTheory.Limits.CompleteLattice.limitCone
-/

#print CategoryTheory.Limits.CompleteLattice.colimitCocone /-
/-- The colimit cocone over any functor into a complete lattice.
-/
def colimitCocone (F : J ⥤ α) : ColimitCocone F
    where
  Cocone :=
    { pt := supᵢ F.obj
      ι := { app := fun j => homOfLE (CompleteLattice.le_sup _ _ (Set.mem_range_self _)) } }
  IsColimit :=
    {
      desc := fun s =>
        homOfLE (CompleteLattice.sup_le _ _ (by rintro _ ⟨j, rfl⟩; exact (s.ι.app j).le)) }
#align category_theory.limits.complete_lattice.colimit_cocone CategoryTheory.Limits.CompleteLattice.colimitCocone
-/

#print CategoryTheory.Limits.CompleteLattice.hasLimits_of_completeLattice /-
-- It would be nice to only use the `Inf` half of the complete lattice, but
-- this seems not to have been described separately.
-- see Note [lower instance priority]
instance (priority := 100) hasLimits_of_completeLattice : HasLimits α
    where HasLimitsOfShape J 𝒥 := { HasLimit := fun F => has_limit.mk (limit_cone F) }
#align category_theory.limits.complete_lattice.has_limits_of_complete_lattice CategoryTheory.Limits.CompleteLattice.hasLimits_of_completeLattice
-/

#print CategoryTheory.Limits.CompleteLattice.hasColimits_of_completeLattice /-
-- see Note [lower instance priority]
instance (priority := 100) hasColimits_of_completeLattice : HasColimits α
    where HasColimitsOfShape J 𝒥 := { HasColimit := fun F => has_colimit.mk (colimit_cocone F) }
#align category_theory.limits.complete_lattice.has_colimits_of_complete_lattice CategoryTheory.Limits.CompleteLattice.hasColimits_of_completeLattice
-/

/- warning: category_theory.limits.complete_lattice.limit_eq_infi -> CategoryTheory.Limits.CompleteLattice.limit_eq_infᵢ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : CompleteLattice.{u1} α] {J : Type.{u1}} [_inst_2 : CategoryTheory.SmallCategory.{u1} J] (F : CategoryTheory.Functor.{u1, u1, u1, u1} J _inst_2 α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1))))), Eq.{succ u1} α (CategoryTheory.Limits.limit.{u1, u1, u1, u1} J _inst_2 α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) F (CategoryTheory.Limits.hasLimitOfHasLimitsOfShape.{u1, u1, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) J _inst_2 (CategoryTheory.Limits.hasLimitsOfShapeOfHasLimits.{u1, u1, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) J _inst_2 (CategoryTheory.Limits.CompleteLattice.hasLimits_of_completeLattice.{u1} α _inst_1)) F)) (infᵢ.{u1, succ u1} α (CompleteSemilatticeInf.toHasInf.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)) J (CategoryTheory.Functor.obj.{u1, u1, u1, u1} J _inst_2 α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) F))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : CompleteLattice.{u1} α] {J : Type.{u1}} [_inst_2 : CategoryTheory.SmallCategory.{u1} J] (F : CategoryTheory.Functor.{u1, u1, u1, u1} J _inst_2 α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1))))), Eq.{succ u1} α (CategoryTheory.Limits.limit.{u1, u1, u1, u1} J _inst_2 α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) F (CategoryTheory.Limits.hasLimitOfHasLimitsOfShape.{u1, u1, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) J _inst_2 (CategoryTheory.Limits.hasLimitsOfShapeOfHasLimits.{u1, u1, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) J _inst_2 (CategoryTheory.Limits.CompleteLattice.hasLimits_of_completeLattice.{u1} α _inst_1)) F)) (infᵢ.{u1, succ u1} α (CompleteLattice.toInfSet.{u1} α _inst_1) J (Prefunctor.obj.{succ u1, succ u1, u1, u1} J (CategoryTheory.CategoryStruct.toQuiver.{u1, u1} J (CategoryTheory.Category.toCategoryStruct.{u1, u1} J _inst_2)) α (CategoryTheory.CategoryStruct.toQuiver.{u1, u1} α (CategoryTheory.Category.toCategoryStruct.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))))) (CategoryTheory.Functor.toPrefunctor.{u1, u1, u1, u1} J _inst_2 α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) F)))
Case conversion may be inaccurate. Consider using '#align category_theory.limits.complete_lattice.limit_eq_infi CategoryTheory.Limits.CompleteLattice.limit_eq_infᵢₓ'. -/
/-- The limit of a functor into a complete lattice is the infimum of the objects in the image.
-/
theorem limit_eq_infᵢ (F : J ⥤ α) : limit F = infᵢ F.obj :=
  (IsLimit.conePointUniqueUpToIso (limit.isLimit F) (limitCone F).IsLimit).to_eq
#align category_theory.limits.complete_lattice.limit_eq_infi CategoryTheory.Limits.CompleteLattice.limit_eq_infᵢ

/- warning: category_theory.limits.complete_lattice.colimit_eq_supr -> CategoryTheory.Limits.CompleteLattice.colimit_eq_supᵢ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : CompleteLattice.{u1} α] {J : Type.{u1}} [_inst_2 : CategoryTheory.SmallCategory.{u1} J] (F : CategoryTheory.Functor.{u1, u1, u1, u1} J _inst_2 α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1))))), Eq.{succ u1} α (CategoryTheory.Limits.colimit.{u1, u1, u1, u1} J _inst_2 α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) F (CategoryTheory.Limits.hasColimitOfHasColimitsOfShape.{u1, u1, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) J _inst_2 (CategoryTheory.Limits.hasColimitsOfShapeOfHasColimitsOfSize.{u1, u1, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) J _inst_2 (CategoryTheory.Limits.CompleteLattice.hasColimits_of_completeLattice.{u1} α _inst_1)) F)) (supᵢ.{u1, succ u1} α (CompleteSemilatticeSup.toHasSup.{u1} α (CompleteLattice.toCompleteSemilatticeSup.{u1} α _inst_1)) J (CategoryTheory.Functor.obj.{u1, u1, u1, u1} J _inst_2 α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) F))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : CompleteLattice.{u1} α] {J : Type.{u1}} [_inst_2 : CategoryTheory.SmallCategory.{u1} J] (F : CategoryTheory.Functor.{u1, u1, u1, u1} J _inst_2 α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1))))), Eq.{succ u1} α (CategoryTheory.Limits.colimit.{u1, u1, u1, u1} J _inst_2 α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) F (CategoryTheory.Limits.hasColimitOfHasColimitsOfShape.{u1, u1, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) J _inst_2 (CategoryTheory.Limits.hasColimitsOfShapeOfHasColimitsOfSize.{u1, u1, u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) J _inst_2 (CategoryTheory.Limits.CompleteLattice.hasColimits_of_completeLattice.{u1} α _inst_1)) F)) (supᵢ.{u1, succ u1} α (CompleteLattice.toSupSet.{u1} α _inst_1) J (Prefunctor.obj.{succ u1, succ u1, u1, u1} J (CategoryTheory.CategoryStruct.toQuiver.{u1, u1} J (CategoryTheory.Category.toCategoryStruct.{u1, u1} J _inst_2)) α (CategoryTheory.CategoryStruct.toQuiver.{u1, u1} α (CategoryTheory.Category.toCategoryStruct.{u1, u1} α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))))) (CategoryTheory.Functor.toPrefunctor.{u1, u1, u1, u1} J _inst_2 α (Preorder.smallCategory.{u1} α (PartialOrder.toPreorder.{u1} α (CompleteSemilatticeInf.toPartialOrder.{u1} α (CompleteLattice.toCompleteSemilatticeInf.{u1} α _inst_1)))) F)))
Case conversion may be inaccurate. Consider using '#align category_theory.limits.complete_lattice.colimit_eq_supr CategoryTheory.Limits.CompleteLattice.colimit_eq_supᵢₓ'. -/
/-- The colimit of a functor into a complete lattice is the supremum of the objects in the image.
-/
theorem colimit_eq_supᵢ (F : J ⥤ α) : colimit F = supᵢ F.obj :=
  (IsColimit.coconePointUniqueUpToIso (colimit.isColimit F) (colimitCocone F).IsColimit).to_eq
#align category_theory.limits.complete_lattice.colimit_eq_supr CategoryTheory.Limits.CompleteLattice.colimit_eq_supᵢ

end CategoryTheory.Limits.CompleteLattice

