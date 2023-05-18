/-
Copyright (c) 2021 Mark Lavrentyev. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mark Lavrentyev

! This file was ported from Lean 3 source module algebraic_topology.fundamental_groupoid.fundamental_group
! leanprover-community/mathlib commit 70fd9563a21e7b963887c9360bd29b2393e6225a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Groupoid
import Mathbin.Topology.Category.Top.Basic
import Mathbin.Topology.PathConnected
import Mathbin.Topology.Homotopy.Path
import Mathbin.AlgebraicTopology.FundamentalGroupoid.Basic

/-!
# Fundamental group of a space

Given a topological space `X` and a basepoint `x`, the fundamental group is the automorphism group
of `x` i.e. the group with elements being loops based at `x` (quotiented by homotopy equivalence).
-/


universe u v

variable {X : Type u} {Y : Type v} [TopologicalSpace X] [TopologicalSpace Y]

variable {x₀ x₁ : X}

noncomputable section

open CategoryTheory

#print FundamentalGroup /-
/-- The fundamental group is the automorphism group (vertex group) of the basepoint
in the fundamental groupoid. -/
def FundamentalGroup (X : Type u) [TopologicalSpace X] (x : X) :=
  @Aut (FundamentalGroupoid X) _ x deriving Group, Inhabited
#align fundamental_group FundamentalGroup
-/

namespace FundamentalGroup

attribute [local instance] Path.Homotopic.setoid

attribute [local reducible] FundamentalGroupoid

/- warning: fundamental_group.fundamental_group_mul_equiv_of_path -> FundamentalGroup.fundamentalGroupMulEquivOfPath is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] {x₀ : X} {x₁ : X}, (Path.{u1} X _inst_1 x₀ x₁) -> (MulEquiv.{u1, u1} (FundamentalGroup.{u1} X _inst_1 x₀) (FundamentalGroup.{u1} X _inst_1 x₁) (MulOneClass.toHasMul.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (Monoid.toMulOneClass.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (DivInvMonoid.toMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (Group.toDivInvMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (FundamentalGroup.group.{u1} X _inst_1 x₀))))) (MulOneClass.toHasMul.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (Monoid.toMulOneClass.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (DivInvMonoid.toMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (Group.toDivInvMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (FundamentalGroup.group.{u1} X _inst_1 x₁))))))
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] {x₀ : X} {x₁ : X}, (Path.{u1} X _inst_1 x₀ x₁) -> (MulEquiv.{u1, u1} (FundamentalGroup.{u1} X _inst_1 x₀) (FundamentalGroup.{u1} X _inst_1 x₁) (MulOneClass.toMul.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (Monoid.toMulOneClass.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (DivInvMonoid.toMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (Group.toDivInvMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (instGroupFundamentalGroup.{u1} X _inst_1 x₀))))) (MulOneClass.toMul.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (Monoid.toMulOneClass.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (DivInvMonoid.toMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (Group.toDivInvMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (instGroupFundamentalGroup.{u1} X _inst_1 x₁))))))
Case conversion may be inaccurate. Consider using '#align fundamental_group.fundamental_group_mul_equiv_of_path FundamentalGroup.fundamentalGroupMulEquivOfPathₓ'. -/
/-- Get an isomorphism between the fundamental groups at two points given a path -/
def fundamentalGroupMulEquivOfPath (p : Path x₀ x₁) :
    FundamentalGroup X x₀ ≃* FundamentalGroup X x₁ :=
  Aut.autMulEquivOfIso (asIso ⟦p⟧)
#align fundamental_group.fundamental_group_mul_equiv_of_path FundamentalGroup.fundamentalGroupMulEquivOfPath

variable (x₀ x₁)

/- warning: fundamental_group.fundamental_group_mul_equiv_of_path_connected -> FundamentalGroup.fundamentalGroupMulEquivOfPathConnected is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] (x₀ : X) (x₁ : X) [_inst_3 : PathConnectedSpace.{u1} X _inst_1], MulEquiv.{u1, u1} (FundamentalGroup.{u1} X _inst_1 x₀) (FundamentalGroup.{u1} X _inst_1 x₁) (MulOneClass.toHasMul.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (Monoid.toMulOneClass.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (DivInvMonoid.toMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (Group.toDivInvMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (FundamentalGroup.group.{u1} X _inst_1 x₀))))) (MulOneClass.toHasMul.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (Monoid.toMulOneClass.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (DivInvMonoid.toMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (Group.toDivInvMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (FundamentalGroup.group.{u1} X _inst_1 x₁)))))
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] (x₀ : X) (x₁ : X) [_inst_3 : PathConnectedSpace.{u1} X _inst_1], MulEquiv.{u1, u1} (FundamentalGroup.{u1} X _inst_1 x₀) (FundamentalGroup.{u1} X _inst_1 x₁) (MulOneClass.toMul.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (Monoid.toMulOneClass.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (DivInvMonoid.toMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (Group.toDivInvMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₀) (instGroupFundamentalGroup.{u1} X _inst_1 x₀))))) (MulOneClass.toMul.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (Monoid.toMulOneClass.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (DivInvMonoid.toMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (Group.toDivInvMonoid.{u1} (FundamentalGroup.{u1} X _inst_1 x₁) (instGroupFundamentalGroup.{u1} X _inst_1 x₁)))))
Case conversion may be inaccurate. Consider using '#align fundamental_group.fundamental_group_mul_equiv_of_path_connected FundamentalGroup.fundamentalGroupMulEquivOfPathConnectedₓ'. -/
/-- The fundamental group of a path connected space is independent of the choice of basepoint. -/
def fundamentalGroupMulEquivOfPathConnected [PathConnectedSpace X] :
    FundamentalGroup X x₀ ≃* FundamentalGroup X x₁ :=
  fundamentalGroupMulEquivOfPath (PathConnectedSpace.somePath x₀ x₁)
#align fundamental_group.fundamental_group_mul_equiv_of_path_connected FundamentalGroup.fundamentalGroupMulEquivOfPathConnected

#print FundamentalGroup.toArrow /-
/-- An element of the fundamental group as an arrow in the fundamental groupoid. -/
abbrev toArrow {X : TopCat} {x : X} (p : FundamentalGroup X x) : x ⟶ x :=
  p.Hom
#align fundamental_group.to_arrow FundamentalGroup.toArrow
-/

#print FundamentalGroup.toPath /-
/-- An element of the fundamental group as a quotient of homotopic paths. -/
abbrev toPath {X : TopCat} {x : X} (p : FundamentalGroup X x) : Path.Homotopic.Quotient x x :=
  toArrow p
#align fundamental_group.to_path FundamentalGroup.toPath
-/

#print FundamentalGroup.fromArrow /-
/-- An element of the fundamental group, constructed from an arrow in the fundamental groupoid. -/
abbrev fromArrow {X : TopCat} {x : X} (p : x ⟶ x) : FundamentalGroup X x :=
  ⟨p, CategoryTheory.Groupoid.inv p⟩
#align fundamental_group.from_arrow FundamentalGroup.fromArrow
-/

#print FundamentalGroup.fromPath /-
/-- An element of the fundamental gorup, constructed from a quotient of homotopic paths. -/
abbrev fromPath {X : TopCat} {x : X} (p : Path.Homotopic.Quotient x x) : FundamentalGroup X x :=
  fromArrow p
#align fundamental_group.from_path FundamentalGroup.fromPath
-/

end FundamentalGroup

