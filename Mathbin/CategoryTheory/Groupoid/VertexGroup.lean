/-
Copyright (c) 2022 Rémi Bottinelli. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rémi Bottinelli

! This file was ported from Lean 3 source module category_theory.groupoid.vertex_group
! leanprover-community/mathlib commit 97eab48559068f3d6313da387714ef25768fb730
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Groupoid
import Mathbin.CategoryTheory.PathCategory
import Mathbin.Algebra.Group.Defs
import Mathbin.Algebra.Hom.Group
import Mathbin.Algebra.Hom.Equiv.Basic
import Mathbin.Combinatorics.Quiver.Path

/-!
# Vertex group

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the vertex group (*aka* isotropy group) of a groupoid at a vertex.

## Implementation notes

* The instance is defined "manually", instead of relying on `category_theory.Aut.group` or
  using `category_theory.inv`.
* The multiplication order therefore matches the categorical one : `x * y = x ≫ y`.
* The inverse is directly defined in terms of the groupoidal inverse : `x ⁻¹ = groupoid.inv x`.

## Tags

isotropy, vertex group, groupoid
-/


namespace CategoryTheory

namespace Groupoid

universe u v

variable {C : Type u} [Groupoid C]

#print CategoryTheory.Groupoid.vertexGroup /-
/-- The vertex group at `c`. -/
@[simps]
instance vertexGroup (c : C) : Group (c ⟶ c)
    where
  mul := fun x y : c ⟶ c => x ≫ y
  mul_assoc := Category.assoc
  one := 𝟙 c
  one_mul := Category.id_comp
  mul_one := Category.comp_id
  inv := Groupoid.inv
  mul_left_inv := inv_comp
#align category_theory.groupoid.vertex_group CategoryTheory.Groupoid.vertexGroup
-/

/- warning: category_theory.groupoid.vertex_group.inv_eq_inv -> CategoryTheory.Groupoid.vertexGroup.inv_eq_inv is a dubious translation:
lean 3 declaration is
  forall {C : Type.{u1}} [_inst_1 : CategoryTheory.Groupoid.{u2, u1} C] (c : C) (γ : Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c), Eq.{succ u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (Inv.inv.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (DivInvMonoid.toHasInv.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (Group.toDivInvMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (CategoryTheory.Groupoid.vertexGroup.{u1, u2} C _inst_1 c))) γ) (CategoryTheory.inv.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1) c c γ (CategoryTheory.IsIso.of_groupoid.{u2, u1} C _inst_1 c c γ))
but is expected to have type
  forall {C : Type.{u2}} [_inst_1 : CategoryTheory.Groupoid.{u1, u2} C] (c : C) (γ : Quiver.Hom.{succ u1, u2} C (CategoryTheory.CategoryStruct.toQuiver.{u1, u2} C (CategoryTheory.Category.toCategoryStruct.{u1, u2} C (CategoryTheory.Groupoid.toCategory.{u1, u2} C _inst_1))) c c), Eq.{succ u1} (Quiver.Hom.{succ u1, u2} C (CategoryTheory.CategoryStruct.toQuiver.{u1, u2} C (CategoryTheory.Category.toCategoryStruct.{u1, u2} C (CategoryTheory.Groupoid.toCategory.{u1, u2} C _inst_1))) c c) (Inv.inv.{u1} (Quiver.Hom.{succ u1, u2} C (CategoryTheory.CategoryStruct.toQuiver.{u1, u2} C (CategoryTheory.Category.toCategoryStruct.{u1, u2} C (CategoryTheory.Groupoid.toCategory.{u1, u2} C _inst_1))) c c) (InvOneClass.toInv.{u1} (Quiver.Hom.{succ u1, u2} C (CategoryTheory.CategoryStruct.toQuiver.{u1, u2} C (CategoryTheory.Category.toCategoryStruct.{u1, u2} C (CategoryTheory.Groupoid.toCategory.{u1, u2} C _inst_1))) c c) (DivInvOneMonoid.toInvOneClass.{u1} (Quiver.Hom.{succ u1, u2} C (CategoryTheory.CategoryStruct.toQuiver.{u1, u2} C (CategoryTheory.Category.toCategoryStruct.{u1, u2} C (CategoryTheory.Groupoid.toCategory.{u1, u2} C _inst_1))) c c) (DivisionMonoid.toDivInvOneMonoid.{u1} (Quiver.Hom.{succ u1, u2} C (CategoryTheory.CategoryStruct.toQuiver.{u1, u2} C (CategoryTheory.Category.toCategoryStruct.{u1, u2} C (CategoryTheory.Groupoid.toCategory.{u1, u2} C _inst_1))) c c) (Group.toDivisionMonoid.{u1} (Quiver.Hom.{succ u1, u2} C (CategoryTheory.CategoryStruct.toQuiver.{u1, u2} C (CategoryTheory.Category.toCategoryStruct.{u1, u2} C (CategoryTheory.Groupoid.toCategory.{u1, u2} C _inst_1))) c c) (CategoryTheory.Groupoid.vertexGroup.{u2, u1} C _inst_1 c))))) γ) (CategoryTheory.inv.{u1, u2} C (CategoryTheory.Groupoid.toCategory.{u1, u2} C _inst_1) c c γ (CategoryTheory.IsIso.of_groupoid.{u1, u2} C _inst_1 c c γ))
Case conversion may be inaccurate. Consider using '#align category_theory.groupoid.vertex_group.inv_eq_inv CategoryTheory.Groupoid.vertexGroup.inv_eq_invₓ'. -/
/-- The inverse in the group is equal to the inverse given by `category_theory.inv`. -/
theorem vertexGroup.inv_eq_inv (c : C) (γ : c ⟶ c) : γ⁻¹ = CategoryTheory.inv γ :=
  Groupoid.inv_eq_inv γ
#align category_theory.groupoid.vertex_group.inv_eq_inv CategoryTheory.Groupoid.vertexGroup.inv_eq_inv

/- warning: category_theory.groupoid.vertex_group_isom_of_map -> CategoryTheory.Groupoid.vertexGroupIsomOfMap is a dubious translation:
lean 3 declaration is
  forall {C : Type.{u1}} [_inst_1 : CategoryTheory.Groupoid.{u2, u1} C] {c : C} {d : C}, (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c d) -> (MulEquiv.{u2, u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (MulOneClass.toHasMul.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (Monoid.toMulOneClass.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (DivInvMonoid.toMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (Group.toDivInvMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (CategoryTheory.Groupoid.vertexGroup.{u1, u2} C _inst_1 c))))) (MulOneClass.toHasMul.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (Monoid.toMulOneClass.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (DivInvMonoid.toMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (Group.toDivInvMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (CategoryTheory.Groupoid.vertexGroup.{u1, u2} C _inst_1 d))))))
but is expected to have type
  forall {C : Type.{u1}} [_inst_1 : CategoryTheory.Groupoid.{u2, u1} C] {c : C} {d : C}, (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c d) -> (MulEquiv.{u2, u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (MulOneClass.toMul.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (Monoid.toMulOneClass.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (DivInvMonoid.toMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (Group.toDivInvMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (CategoryTheory.Groupoid.vertexGroup.{u1, u2} C _inst_1 c))))) (MulOneClass.toMul.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (Monoid.toMulOneClass.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (DivInvMonoid.toMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (Group.toDivInvMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (CategoryTheory.Groupoid.vertexGroup.{u1, u2} C _inst_1 d))))))
Case conversion may be inaccurate. Consider using '#align category_theory.groupoid.vertex_group_isom_of_map CategoryTheory.Groupoid.vertexGroupIsomOfMapₓ'. -/
/-- An arrow in the groupoid defines, by conjugation, an isomorphism of groups between
its endpoints.
-/
@[simps]
def vertexGroupIsomOfMap {c d : C} (f : c ⟶ d) : (c ⟶ c) ≃* (d ⟶ d)
    where
  toFun γ := inv f ≫ γ ≫ f
  invFun δ := f ≫ δ ≫ inv f
  left_inv γ := by
    simp_rw [category.assoc, comp_inv, category.comp_id, ← category.assoc, comp_inv,
      category.id_comp]
  right_inv δ := by
    simp_rw [category.assoc, inv_comp, ← category.assoc, inv_comp, category.id_comp,
      category.comp_id]
  map_mul' γ₁ γ₂ := by
    simp only [vertex_group_mul, inv_eq_inv, category.assoc, is_iso.hom_inv_id_assoc]
#align category_theory.groupoid.vertex_group_isom_of_map CategoryTheory.Groupoid.vertexGroupIsomOfMap

/- warning: category_theory.groupoid.vertex_group_isom_of_path -> CategoryTheory.Groupoid.vertexGroupIsomOfPath is a dubious translation:
lean 3 declaration is
  forall {C : Type.{u1}} [_inst_1 : CategoryTheory.Groupoid.{u2, u1} C] {c : C} {d : C}, (Quiver.Path.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c d) -> (MulEquiv.{u2, u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (MulOneClass.toHasMul.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (Monoid.toMulOneClass.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (DivInvMonoid.toMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (Group.toDivInvMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (CategoryTheory.Groupoid.vertexGroup.{u1, u2} C _inst_1 c))))) (MulOneClass.toHasMul.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (Monoid.toMulOneClass.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (DivInvMonoid.toMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (Group.toDivInvMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (CategoryTheory.Groupoid.vertexGroup.{u1, u2} C _inst_1 d))))))
but is expected to have type
  forall {C : Type.{u1}} [_inst_1 : CategoryTheory.Groupoid.{u2, u1} C] {c : C} {d : C}, (Quiver.Path.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c d) -> (MulEquiv.{u2, u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (MulOneClass.toMul.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (Monoid.toMulOneClass.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (DivInvMonoid.toMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (Group.toDivInvMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) c c) (CategoryTheory.Groupoid.vertexGroup.{u1, u2} C _inst_1 c))))) (MulOneClass.toMul.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (Monoid.toMulOneClass.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (DivInvMonoid.toMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (Group.toDivInvMonoid.{u2} (Quiver.Hom.{succ u2, u1} C (CategoryTheory.CategoryStruct.toQuiver.{u2, u1} C (CategoryTheory.Category.toCategoryStruct.{u2, u1} C (CategoryTheory.Groupoid.toCategory.{u2, u1} C _inst_1))) d d) (CategoryTheory.Groupoid.vertexGroup.{u1, u2} C _inst_1 d))))))
Case conversion may be inaccurate. Consider using '#align category_theory.groupoid.vertex_group_isom_of_path CategoryTheory.Groupoid.vertexGroupIsomOfPathₓ'. -/
/-- A path in the groupoid defines an isomorphism between its endpoints.
-/
def vertexGroupIsomOfPath {c d : C} (p : Quiver.Path c d) : (c ⟶ c) ≃* (d ⟶ d) :=
  vertexGroupIsomOfMap (composePath p)
#align category_theory.groupoid.vertex_group_isom_of_path CategoryTheory.Groupoid.vertexGroupIsomOfPath

/- warning: category_theory.functor.map_vertex_group -> CategoryTheory.Groupoid.CategoryTheory.Functor.mapVertexGroup is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align category_theory.functor.map_vertex_group CategoryTheory.Groupoid.CategoryTheory.Functor.mapVertexGroupₓ'. -/
/-- A functor defines a morphism of vertex group. -/
@[simps]
def CategoryTheory.Groupoid.CategoryTheory.Functor.mapVertexGroup {D : Type v} [Groupoid D]
    (φ : C ⥤ D) (c : C) : (c ⟶ c) →* (φ.obj c ⟶ φ.obj c)
    where
  toFun := φ.map
  map_one' := φ.map_id c
  map_mul' := φ.map_comp
#align category_theory.functor.map_vertex_group CategoryTheory.Groupoid.CategoryTheory.Functor.mapVertexGroup

end Groupoid

end CategoryTheory

