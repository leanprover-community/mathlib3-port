/-
Copyright (c) 2018 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison, Mario Carneiro, Reid Barton, Andrew Yang

! This file was ported from Lean 3 source module topology.sheaves.presheaf
! leanprover-community/mathlib commit 33c67ae661dd8988516ff7f247b0be3018cdd952
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.KanExtension
import Mathbin.Topology.Category.Top.Opens
import Mathbin.CategoryTheory.Adjunction.Opposites

/-!
# Presheaves on a topological space

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define `presheaf C X` simply as `(opens X)ᵒᵖ ⥤ C`,
and inherit the category structure with natural transformations as morphisms.

We define
* `pushforward_obj {X Y : Top.{w}} (f : X ⟶ Y) (ℱ : X.presheaf C) : Y.presheaf C`
with notation `f _* ℱ`
and for `ℱ : X.presheaf C` provide the natural isomorphisms
* `pushforward.id : (𝟙 X) _* ℱ ≅ ℱ`
* `pushforward.comp : (f ≫ g) _* ℱ ≅ g _* (f _* ℱ)`
along with their `@[simp]` lemmas.

We also define the functors `pushforward` and `pullback` between the categories
`X.presheaf C` and `Y.presheaf C`, and provide their adjunction at
`pushforward_pullback_adjunction`.
-/


universe w v u

open CategoryTheory

open TopologicalSpace

open Opposite

variable (C : Type u) [Category.{v} C]

namespace TopCat

#print TopCat.Presheaf /-
/-- The category of `C`-valued presheaves on a (bundled) topological space `X`. -/
@[nolint has_nonempty_instance]
def Presheaf (X : TopCat.{w}) : Type max u v w :=
  (Opens X)ᵒᵖ ⥤ C deriving Category
#align Top.presheaf TopCat.Presheaf
-/

variable {C}

namespace Presheaf

attribute [local instance] concrete_category.has_coe_to_sort concrete_category.has_coe_to_fun

/-- Tag lemmas to use in `Top.presheaf.restrict_tac`.  -/
@[user_attribute]
unsafe def restrict_attr : user_attribute (tactic Unit → tactic Unit) Unit
    where
  Name := `sheaf_restrict
  descr := "tag lemmas to use in `Top.presheaf.restrict_tac`"
  cache_cfg :=
    { mk_cache := fun ns =>
        pure fun t => do
          let ctx ← tactic.local_context
          ctx (tactic.focus1 ∘ (tactic.apply' >=> fun _ => tactic.done) >=> fun _ => t) <|>
              ns
                (tactic.focus1 ∘
                    (tactic.resolve_name >=> tactic.to_expr >=> tactic.apply' >=> fun _ =>
                      tactic.done) >=>
                  fun _ => t)
      dependencies := [] }
#align Top.presheaf.restrict_attr Top.presheaf.restrict_attr

/- ./././Mathport/Syntax/Translate/Expr.lean:330:4: warning: unsupported (TODO): `[tacs] -/
/-- A tactic to discharge goals of type `U ≤ V` for `Top.presheaf.restrict_open` -/
unsafe def restrict_tac : ∀ n : ℕ, tactic Unit
  | 0 => tactic.fail "`restrict_tac` failed"
  | n + 1 => Monad.join (restrict_attr.get_cache <*> pure tactic.done) <|> sorry
#align Top.presheaf.restrict_tac Top.presheaf.restrict_tac

/-- A tactic to discharge goals of type `U ≤ V` for `Top.presheaf.restrict_open`.
Defaults to three iterations. -/
unsafe def restrict_tac' :=
  restrict_tac 3
#align Top.presheaf.restrict_tac' Top.presheaf.restrict_tac'

attribute [sheaf_restrict] bot_le le_top le_refl inf_le_left inf_le_right le_sup_left le_sup_right

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic Top.presheaf.restrict_tac' -/
example {X : TopCat} {v w x y z : Opens X} (h₀ : v ≤ x) (h₁ : x ≤ z ⊓ w) (h₂ : x ≤ y ⊓ z) : v ≤ y :=
  by
  run_tac
    restrict_tac'

/- warning: Top.presheaf.restrict -> TopCat.Presheaf.restrict is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.restrict TopCat.Presheaf.restrictₓ'. -/
/-- The restriction of a section along an inclusion of open sets.
For `x : F.obj (op V)`, we provide the notation `x |_ₕ i` (`h` stands for `hom`) for `i : U ⟶ V`,
and the notation `x |_ₗ U ⟪i⟫` (`l` stands for `le`) for `i : U ≤ V`.
-/
def restrict {X : TopCat} {C : Type _} [Category C] [ConcreteCategory C] {F : X.Presheaf C}
    {V : Opens X} (x : F.obj (op V)) {U : Opens X} (h : U ⟶ V) : F.obj (op U) :=
  F.map h.op x
#align Top.presheaf.restrict TopCat.Presheaf.restrict

-- mathport name: «expr |_ₕ »
scoped[AlgebraicGeometry] infixl:80 " |_ₕ " => TopCat.Presheaf.restrict

-- mathport name: «expr |_ₗ ⟪ ⟫»
scoped[AlgebraicGeometry]
  notation:80 x " |_ₗ " U " ⟪" e "⟫ " =>
    @TopCat.Presheaf.restrict _ _ _ _ _ _ x U (@homOfLE (Opens _) _ U _ e)

/- warning: Top.presheaf.restrict_open -> TopCat.Presheaf.restrictOpen is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.restrict_open TopCat.Presheaf.restrictOpenₓ'. -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic Top.presheaf.restrict_tac' -/
/-- The restriction of a section along an inclusion of open sets.
For `x : F.obj (op V)`, we provide the notation `x |_ U`, where the proof `U ≤ V` is inferred by
the tactic `Top.presheaf.restrict_tac'` -/
abbrev restrictOpen {X : TopCat} {C : Type _} [Category C] [ConcreteCategory C] {F : X.Presheaf C}
    {V : Opens X} (x : F.obj (op V)) (U : Opens X)
    (e : U ≤ V := by
      run_tac
        Top.presheaf.restrict_tac') :
    F.obj (op U) :=
  x |_ₗ U ⟪e⟫
#align Top.presheaf.restrict_open TopCat.Presheaf.restrictOpen

-- mathport name: «expr |_ »
scoped[AlgebraicGeometry] infixl:80 " |_ " => TopCat.Presheaf.restrictOpen

/- warning: Top.presheaf.restrict_restrict -> TopCat.Presheaf.restrict_restrict is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.restrict_restrict TopCat.Presheaf.restrict_restrictₓ'. -/
@[simp]
theorem restrict_restrict {X : TopCat} {C : Type _} [Category C] [ConcreteCategory C]
    {F : X.Presheaf C} {U V W : Opens X} (e₁ : U ≤ V) (e₂ : V ≤ W) (x : F.obj (op W)) :
    x |_ V |_ U = x |_ U := by
  delta restrict_open restrict
  rw [← comp_apply, ← functor.map_comp]
  rfl
#align Top.presheaf.restrict_restrict TopCat.Presheaf.restrict_restrict

/- warning: Top.presheaf.map_restrict -> TopCat.Presheaf.map_restrict is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.map_restrict TopCat.Presheaf.map_restrictₓ'. -/
@[simp]
theorem map_restrict {X : TopCat} {C : Type _} [Category C] [ConcreteCategory C]
    {F G : X.Presheaf C} (e : F ⟶ G) {U V : Opens X} (h : U ≤ V) (x : F.obj (op V)) :
    e.app _ (x |_ U) = e.app _ x |_ U :=
  by
  delta restrict_open restrict
  rw [← comp_apply, nat_trans.naturality, comp_apply]
#align Top.presheaf.map_restrict TopCat.Presheaf.map_restrict

#print TopCat.Presheaf.pushforwardObj /-
/-- Pushforward a presheaf on `X` along a continuous map `f : X ⟶ Y`, obtaining a presheaf
on `Y`. -/
def pushforwardObj {X Y : TopCat.{w}} (f : X ⟶ Y) (ℱ : X.Presheaf C) : Y.Presheaf C :=
  (Opens.map f).op ⋙ ℱ
#align Top.presheaf.pushforward_obj TopCat.Presheaf.pushforwardObj
-/

-- mathport name: «expr _* »
infixl:80 " _* " => pushforwardObj

/- warning: Top.presheaf.pushforward_obj_obj -> TopCat.Presheaf.pushforwardObj_obj is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward_obj_obj TopCat.Presheaf.pushforwardObj_objₓ'. -/
@[simp]
theorem pushforwardObj_obj {X Y : TopCat.{w}} (f : X ⟶ Y) (ℱ : X.Presheaf C) (U : (Opens Y)ᵒᵖ) :
    (f _* ℱ).obj U = ℱ.obj ((Opens.map f).op.obj U) :=
  rfl
#align Top.presheaf.pushforward_obj_obj TopCat.Presheaf.pushforwardObj_obj

/- warning: Top.presheaf.pushforward_obj_map -> TopCat.Presheaf.pushforwardObj_map is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward_obj_map TopCat.Presheaf.pushforwardObj_mapₓ'. -/
@[simp]
theorem pushforwardObj_map {X Y : TopCat.{w}} (f : X ⟶ Y) (ℱ : X.Presheaf C) {U V : (Opens Y)ᵒᵖ}
    (i : U ⟶ V) : (f _* ℱ).map i = ℱ.map ((Opens.map f).op.map i) :=
  rfl
#align Top.presheaf.pushforward_obj_map TopCat.Presheaf.pushforwardObj_map

/- warning: Top.presheaf.pushforward_eq -> TopCat.Presheaf.pushforwardEq is a dubious translation:
lean 3 declaration is
  forall {C : Type.{u3}} [_inst_1 : CategoryTheory.Category.{u2, u3} C] {X : TopCat.{u1}} {Y : TopCat.{u1}} {f : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1})) X Y} {g : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1})) X Y}, (Eq.{succ u1} (Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1})) X Y) f g) -> (forall (ℱ : TopCat.Presheaf.{u1, u2, u3} C _inst_1 X), CategoryTheory.Iso.{max u1 u2, max u3 u2 u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 Y) (CategoryTheory.Functor.category.{u1, u2, u1, u3} (Opposite.{succ u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y))) (CategoryTheory.Category.opposite.{u1, u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y)) (Preorder.smallCategory.{u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y)) (PartialOrder.toPreorder.{u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y)) (SetLike.partialOrder.{u1, u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y)) (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopologicalSpace.Opens.setLike.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y)))))) C _inst_1) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Y f ℱ) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Y g ℱ))
but is expected to have type
  forall {C : Type.{u3}} [_inst_1 : CategoryTheory.Category.{u2, u3} C] {X : TopCat.{u1}} {Y : TopCat.{u1}} {f : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1})) X Y} {g : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1})) X Y}, (Eq.{succ u1} (Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1})) X Y) f g) -> (forall (ℱ : TopCat.Presheaf.{u1, u2, u3} C _inst_1 X), CategoryTheory.Iso.{max u2 u1, max (max u3 u2) u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 Y) (TopCat.instCategoryPresheaf.{u1, u2, u3} C _inst_1 Y) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Y f ℱ) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Y g ℱ))
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward_eq TopCat.Presheaf.pushforwardEqₓ'. -/
/--
An equality of continuous maps induces a natural isomorphism between the pushforwards of a presheaf
along those maps.
-/
def pushforwardEq {X Y : TopCat.{w}} {f g : X ⟶ Y} (h : f = g) (ℱ : X.Presheaf C) :
    f _* ℱ ≅ g _* ℱ :=
  isoWhiskerRight (NatIso.op (Opens.mapIso f g h).symm) ℱ
#align Top.presheaf.pushforward_eq TopCat.Presheaf.pushforwardEq

#print TopCat.Presheaf.pushforward_eq' /-
theorem pushforward_eq' {X Y : TopCat.{w}} {f g : X ⟶ Y} (h : f = g) (ℱ : X.Presheaf C) :
    f _* ℱ = g _* ℱ := by rw [h]
#align Top.presheaf.pushforward_eq' TopCat.Presheaf.pushforward_eq'
-/

/- warning: Top.presheaf.pushforward_eq_hom_app -> TopCat.Presheaf.pushforwardEq_hom_app is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward_eq_hom_app TopCat.Presheaf.pushforwardEq_hom_appₓ'. -/
@[simp]
theorem pushforwardEq_hom_app {X Y : TopCat.{w}} {f g : X ⟶ Y} (h : f = g) (ℱ : X.Presheaf C) (U) :
    (pushforwardEq h ℱ).Hom.app U =
      ℱ.map (by dsimp [functor.op]; apply Quiver.Hom.op; apply eq_to_hom; rw [h]) :=
  by simp [pushforward_eq]
#align Top.presheaf.pushforward_eq_hom_app TopCat.Presheaf.pushforwardEq_hom_app

/- warning: Top.presheaf.pushforward_eq'_hom_app -> TopCat.Presheaf.pushforward_eq'_hom_app is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward_eq'_hom_app TopCat.Presheaf.pushforward_eq'_hom_appₓ'. -/
theorem pushforward_eq'_hom_app {X Y : TopCat.{w}} {f g : X ⟶ Y} (h : f = g) (ℱ : X.Presheaf C)
    (U) : NatTrans.app (eqToHom (pushforward_eq' h ℱ)) U = ℱ.map (eqToHom (by rw [h])) := by
  simpa [eq_to_hom_map]
#align Top.presheaf.pushforward_eq'_hom_app TopCat.Presheaf.pushforward_eq'_hom_app

/- warning: Top.presheaf.pushforward_eq_rfl -> TopCat.Presheaf.pushforwardEq_rfl is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward_eq_rfl TopCat.Presheaf.pushforwardEq_rflₓ'. -/
@[simp]
theorem pushforwardEq_rfl {X Y : TopCat.{w}} (f : X ⟶ Y) (ℱ : X.Presheaf C) (U) :
    (pushforwardEq (rfl : f = f) ℱ).Hom.app (op U) = 𝟙 _ :=
  by
  dsimp [pushforward_eq]
  simp
#align Top.presheaf.pushforward_eq_rfl TopCat.Presheaf.pushforwardEq_rfl

/- warning: Top.presheaf.pushforward_eq_eq -> TopCat.Presheaf.pushforwardEq_eq is a dubious translation:
lean 3 declaration is
  forall {C : Type.{u3}} [_inst_1 : CategoryTheory.Category.{u2, u3} C] {X : TopCat.{u1}} {Y : TopCat.{u1}} {f : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1})) X Y} {g : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1})) X Y} (h₁ : Eq.{succ u1} (Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1})) X Y) f g) (h₂ : Eq.{succ u1} (Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1})) X Y) f g) (ℱ : TopCat.Presheaf.{u1, u2, u3} C _inst_1 X), Eq.{succ (max u1 u2)} (CategoryTheory.Iso.{max u1 u2, max u3 u2 u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 Y) (CategoryTheory.Functor.category.{u1, u2, u1, u3} (Opposite.{succ u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y))) (CategoryTheory.Category.opposite.{u1, u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y)) (Preorder.smallCategory.{u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y)) (PartialOrder.toPreorder.{u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y)) (SetLike.partialOrder.{u1, u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y)) (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopologicalSpace.Opens.setLike.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y)))))) C _inst_1) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Y f ℱ) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Y g ℱ)) (TopCat.Presheaf.pushforwardEq.{u1, u2, u3} C _inst_1 X Y f g h₁ ℱ) (TopCat.Presheaf.pushforwardEq.{u1, u2, u3} C _inst_1 X Y f g h₂ ℱ)
but is expected to have type
  forall {C : Type.{u3}} [_inst_1 : CategoryTheory.Category.{u2, u3} C] {X : TopCat.{u1}} {Y : TopCat.{u1}} {f : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1})) X Y} {g : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1})) X Y} (h₁ : Eq.{succ u1} (Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1})) X Y) f g) (h₂ : Eq.{succ u1} (Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1})) X Y) f g) (ℱ : TopCat.Presheaf.{u1, u2, u3} C _inst_1 X), Eq.{max (succ u2) (succ u1)} (CategoryTheory.Iso.{max u2 u1, max (max u3 u2) u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 Y) (TopCat.instCategoryPresheaf.{u1, u2, u3} C _inst_1 Y) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Y f ℱ) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Y g ℱ)) (TopCat.Presheaf.pushforwardEq.{u1, u2, u3} C _inst_1 X Y f g h₁ ℱ) (TopCat.Presheaf.pushforwardEq.{u1, u2, u3} C _inst_1 X Y f g h₂ ℱ)
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward_eq_eq TopCat.Presheaf.pushforwardEq_eqₓ'. -/
theorem pushforwardEq_eq {X Y : TopCat.{w}} {f g : X ⟶ Y} (h₁ h₂ : f = g) (ℱ : X.Presheaf C) :
    ℱ.pushforwardEq h₁ = ℱ.pushforwardEq h₂ :=
  rfl
#align Top.presheaf.pushforward_eq_eq TopCat.Presheaf.pushforwardEq_eq

namespace Pushforward

variable {X : TopCat.{w}} (ℱ : X.Presheaf C)

/- warning: Top.presheaf.pushforward.id -> TopCat.Presheaf.Pushforward.id is a dubious translation:
lean 3 declaration is
  forall {C : Type.{u3}} [_inst_1 : CategoryTheory.Category.{u2, u3} C] {X : TopCat.{u1}} (ℱ : TopCat.Presheaf.{u1, u2, u3} C _inst_1 X), CategoryTheory.Iso.{max u1 u2, max u3 u2 u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (TopCat.Presheaf.category.{u2, u1, u3} C _inst_1 X) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X X (CategoryTheory.CategoryStruct.id.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1}) X) ℱ) ℱ
but is expected to have type
  forall {C : Type.{u3}} [_inst_1 : CategoryTheory.Category.{u2, u3} C] {X : TopCat.{u1}} (ℱ : TopCat.Presheaf.{u1, u2, u3} C _inst_1 X), CategoryTheory.Iso.{max u2 u1, max (max u3 u2) u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (TopCat.instCategoryPresheaf.{u1, u2, u3} C _inst_1 X) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X X (CategoryTheory.CategoryStruct.id.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1}) X) ℱ) ℱ
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward.id TopCat.Presheaf.Pushforward.idₓ'. -/
/-- The natural isomorphism between the pushforward of a presheaf along the identity continuous map
and the original presheaf. -/
def id : 𝟙 X _* ℱ ≅ ℱ :=
  isoWhiskerRight (NatIso.op (Opens.mapId X).symm) ℱ ≪≫ Functor.leftUnitor _
#align Top.presheaf.pushforward.id TopCat.Presheaf.Pushforward.id

#print TopCat.Presheaf.Pushforward.id_eq /-
theorem id_eq : 𝟙 X _* ℱ = ℱ := by
  unfold pushforward_obj
  rw [opens.map_id_eq]
  erw [functor.id_comp]
#align Top.presheaf.pushforward.id_eq TopCat.Presheaf.Pushforward.id_eq
-/

/- warning: Top.presheaf.pushforward.id_hom_app' -> TopCat.Presheaf.Pushforward.id_hom_app' is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward.id_hom_app' TopCat.Presheaf.Pushforward.id_hom_app'ₓ'. -/
@[simp]
theorem id_hom_app' (U) (p) : (id ℱ).Hom.app (op ⟨U, p⟩) = ℱ.map (𝟙 (op ⟨U, p⟩)) :=
  by
  dsimp [id]
  simp
#align Top.presheaf.pushforward.id_hom_app' TopCat.Presheaf.Pushforward.id_hom_app'

attribute [local tidy] tactic.op_induction'

/- warning: Top.presheaf.pushforward.id_hom_app -> TopCat.Presheaf.Pushforward.id_hom_app is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward.id_hom_app TopCat.Presheaf.Pushforward.id_hom_appₓ'. -/
@[simp]
theorem id_hom_app (U) : (id ℱ).Hom.app U = ℱ.map (eqToHom (Opens.op_map_id_obj U)) :=
  by
  -- was `tidy`
  induction U using Opposite.rec'
  cases U
  rw [id_hom_app']
  congr
#align Top.presheaf.pushforward.id_hom_app TopCat.Presheaf.Pushforward.id_hom_app

/- warning: Top.presheaf.pushforward.id_inv_app' -> TopCat.Presheaf.Pushforward.id_inv_app' is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward.id_inv_app' TopCat.Presheaf.Pushforward.id_inv_app'ₓ'. -/
@[simp]
theorem id_inv_app' (U) (p) : (id ℱ).inv.app (op ⟨U, p⟩) = ℱ.map (𝟙 (op ⟨U, p⟩)) :=
  by
  dsimp [id]
  simp
#align Top.presheaf.pushforward.id_inv_app' TopCat.Presheaf.Pushforward.id_inv_app'

/- warning: Top.presheaf.pushforward.comp -> TopCat.Presheaf.Pushforward.comp is a dubious translation:
lean 3 declaration is
  forall {C : Type.{u3}} [_inst_1 : CategoryTheory.Category.{u2, u3} C] {X : TopCat.{u1}} (ℱ : TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) {Y : TopCat.{u1}} {Z : TopCat.{u1}} (f : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1})) X Y) (g : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1})) Y Z), CategoryTheory.Iso.{max u1 u2, max u3 u2 u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 Z) (CategoryTheory.Functor.category.{u1, u2, u1, u3} (Opposite.{succ u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Z) (TopCat.topologicalSpace.{u1} Z))) (CategoryTheory.Category.opposite.{u1, u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Z) (TopCat.topologicalSpace.{u1} Z)) (Preorder.smallCategory.{u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Z) (TopCat.topologicalSpace.{u1} Z)) (PartialOrder.toPreorder.{u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Z) (TopCat.topologicalSpace.{u1} Z)) (SetLike.partialOrder.{u1, u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Z) (TopCat.topologicalSpace.{u1} Z)) (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Z) (TopologicalSpace.Opens.setLike.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Z) (TopCat.topologicalSpace.{u1} Z)))))) C _inst_1) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Z (CategoryTheory.CategoryStruct.comp.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1}) X Y Z f g) ℱ) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 Y Z g (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Y f ℱ))
but is expected to have type
  forall {C : Type.{u3}} [_inst_1 : CategoryTheory.Category.{u2, u3} C] {X : TopCat.{u1}} (ℱ : TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) {Y : TopCat.{u1}} {Z : TopCat.{u1}} (f : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1})) X Y) (g : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1})) Y Z), CategoryTheory.Iso.{max u2 u1, max (max u3 u2) u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 Z) (TopCat.instCategoryPresheaf.{u1, u2, u3} C _inst_1 Z) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Z (CategoryTheory.CategoryStruct.comp.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1}) X Y Z f g) ℱ) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 Y Z g (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Y f ℱ))
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward.comp TopCat.Presheaf.Pushforward.compₓ'. -/
/-- The natural isomorphism between
the pushforward of a presheaf along the composition of two continuous maps and
the corresponding pushforward of a pushforward. -/
def comp {Y Z : TopCat.{w}} (f : X ⟶ Y) (g : Y ⟶ Z) : (f ≫ g) _* ℱ ≅ g _* (f _* ℱ) :=
  isoWhiskerRight (NatIso.op (Opens.mapComp f g).symm) ℱ
#align Top.presheaf.pushforward.comp TopCat.Presheaf.Pushforward.comp

#print TopCat.Presheaf.Pushforward.comp_eq /-
theorem comp_eq {Y Z : TopCat.{w}} (f : X ⟶ Y) (g : Y ⟶ Z) : (f ≫ g) _* ℱ = g _* (f _* ℱ) :=
  rfl
#align Top.presheaf.pushforward.comp_eq TopCat.Presheaf.Pushforward.comp_eq
-/

/- warning: Top.presheaf.pushforward.comp_hom_app -> TopCat.Presheaf.Pushforward.comp_hom_app is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward.comp_hom_app TopCat.Presheaf.Pushforward.comp_hom_appₓ'. -/
@[simp]
theorem comp_hom_app {Y Z : TopCat.{w}} (f : X ⟶ Y) (g : Y ⟶ Z) (U) :
    (comp ℱ f g).Hom.app U = 𝟙 _ := by
  dsimp [comp]
  tidy
#align Top.presheaf.pushforward.comp_hom_app TopCat.Presheaf.Pushforward.comp_hom_app

/- warning: Top.presheaf.pushforward.comp_inv_app -> TopCat.Presheaf.Pushforward.comp_inv_app is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward.comp_inv_app TopCat.Presheaf.Pushforward.comp_inv_appₓ'. -/
@[simp]
theorem comp_inv_app {Y Z : TopCat.{w}} (f : X ⟶ Y) (g : Y ⟶ Z) (U) :
    (comp ℱ f g).inv.app U = 𝟙 _ := by
  dsimp [comp]
  tidy
#align Top.presheaf.pushforward.comp_inv_app TopCat.Presheaf.Pushforward.comp_inv_app

end Pushforward

/- warning: Top.presheaf.pushforward_map -> TopCat.Presheaf.pushforwardMap is a dubious translation:
lean 3 declaration is
  forall {C : Type.{u3}} [_inst_1 : CategoryTheory.Category.{u2, u3} C] {X : TopCat.{u1}} {Y : TopCat.{u1}} (f : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1})) X Y) {ℱ : TopCat.Presheaf.{u1, u2, u3} C _inst_1 X} {𝒢 : TopCat.Presheaf.{u1, u2, u3} C _inst_1 X}, (Quiver.Hom.{succ (max u1 u2), max u3 u2 u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (CategoryTheory.CategoryStruct.toQuiver.{max u1 u2, max u3 u2 u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (CategoryTheory.Category.toCategoryStruct.{max u1 u2, max u3 u2 u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (TopCat.Presheaf.category.{u2, u1, u3} C _inst_1 X))) ℱ 𝒢) -> (Quiver.Hom.{succ (max u1 u2), max u3 u2 u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 Y) (CategoryTheory.CategoryStruct.toQuiver.{max u1 u2, max u3 u2 u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 Y) (CategoryTheory.Category.toCategoryStruct.{max u1 u2, max u3 u2 u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 Y) (TopCat.Presheaf.category.{u2, u1, u3} C _inst_1 Y))) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Y f ℱ) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Y f 𝒢))
but is expected to have type
  forall {C : Type.{u3}} [_inst_1 : CategoryTheory.Category.{u2, u3} C] {X : TopCat.{u1}} {Y : TopCat.{u1}} (f : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1})) X Y) {ℱ : TopCat.Presheaf.{u1, u2, u3} C _inst_1 X} {𝒢 : TopCat.Presheaf.{u1, u2, u3} C _inst_1 X}, (Quiver.Hom.{max (succ u2) (succ u1), max (max u3 u2) u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (CategoryTheory.CategoryStruct.toQuiver.{max u2 u1, max (max u3 u2) u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (CategoryTheory.Category.toCategoryStruct.{max u2 u1, max (max u3 u2) u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (TopCat.instCategoryPresheaf.{u1, u2, u3} C _inst_1 X))) ℱ 𝒢) -> (Quiver.Hom.{max (succ u2) (succ u1), max (max u3 u2) u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 Y) (CategoryTheory.CategoryStruct.toQuiver.{max u2 u1, max (max u3 u2) u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 Y) (CategoryTheory.Category.toCategoryStruct.{max u2 u1, max (max u3 u2) u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 Y) (TopCat.instCategoryPresheaf.{u1, u2, u3} C _inst_1 Y))) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Y f ℱ) (TopCat.Presheaf.pushforwardObj.{u1, u2, u3} C _inst_1 X Y f 𝒢))
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward_map TopCat.Presheaf.pushforwardMapₓ'. -/
/-- A morphism of presheaves gives rise to a morphisms of the pushforwards of those presheaves.
-/
@[simps]
def pushforwardMap {X Y : TopCat.{w}} (f : X ⟶ Y) {ℱ 𝒢 : X.Presheaf C} (α : ℱ ⟶ 𝒢) : f _* ℱ ⟶ f _* 𝒢
    where
  app U := α.app _
  naturality' U V i := by
    erw [α.naturality]
    rfl
#align Top.presheaf.pushforward_map TopCat.Presheaf.pushforwardMap

open CategoryTheory.Limits

section Pullback

variable [HasColimits C]

noncomputable section

#print TopCat.Presheaf.pullbackObj /-
/-- Pullback a presheaf on `Y` along a continuous map `f : X ⟶ Y`, obtaining a presheaf on `X`.

This is defined in terms of left Kan extensions, which is just a fancy way of saying
"take the colimits over the open sets whose preimage contains U".
-/
@[simps]
def pullbackObj {X Y : TopCat.{v}} (f : X ⟶ Y) (ℱ : Y.Presheaf C) : X.Presheaf C :=
  (lan (Opens.map f).op).obj ℱ
#align Top.presheaf.pullback_obj TopCat.Presheaf.pullbackObj
-/

/- warning: Top.presheaf.pullback_map -> TopCat.Presheaf.pullbackMap is a dubious translation:
lean 3 declaration is
  forall {C : Type.{u2}} [_inst_1 : CategoryTheory.Category.{u1, u2} C] [_inst_2 : CategoryTheory.Limits.HasColimits.{u1, u2} C _inst_1] {X : TopCat.{u1}} {Y : TopCat.{u1}} (f : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1})) X Y) {ℱ : TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y} {𝒢 : TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y}, (Quiver.Hom.{succ u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (CategoryTheory.CategoryStruct.toQuiver.{u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (CategoryTheory.Category.toCategoryStruct.{u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.category.{u1, u1, u2} C _inst_1 Y))) ℱ 𝒢) -> (Quiver.Hom.{succ u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (CategoryTheory.CategoryStruct.toQuiver.{u1, max u1 u2} (CategoryTheory.Functor.{u1, u1, u1, u2} (Opposite.{succ u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X))) (CategoryTheory.Category.opposite.{u1, u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X)) (Preorder.smallCategory.{u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X)) (PartialOrder.toPreorder.{u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X)) (SetLike.partialOrder.{u1, u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X)) (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopologicalSpace.Opens.setLike.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X)))))) C _inst_1) (CategoryTheory.Category.toCategoryStruct.{u1, max u1 u2} (CategoryTheory.Functor.{u1, u1, u1, u2} (Opposite.{succ u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X))) (CategoryTheory.Category.opposite.{u1, u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X)) (Preorder.smallCategory.{u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X)) (PartialOrder.toPreorder.{u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X)) (SetLike.partialOrder.{u1, u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X)) (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopologicalSpace.Opens.setLike.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X)))))) C _inst_1) (CategoryTheory.Functor.category.{u1, u1, u1, u2} (Opposite.{succ u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X))) (CategoryTheory.Category.opposite.{u1, u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X)) (Preorder.smallCategory.{u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X)) (PartialOrder.toPreorder.{u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X)) (SetLike.partialOrder.{u1, u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X)) (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopologicalSpace.Opens.setLike.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} X) (TopCat.topologicalSpace.{u1} X)))))) C _inst_1))) (TopCat.Presheaf.pullbackObj.{u1, u2} C _inst_1 _inst_2 X Y f ℱ) (TopCat.Presheaf.pullbackObj.{u1, u2} C _inst_1 _inst_2 X Y f 𝒢))
but is expected to have type
  forall {C : Type.{u2}} [_inst_1 : CategoryTheory.Category.{u1, u2} C] [_inst_2 : CategoryTheory.Limits.HasColimits.{u1, u2} C _inst_1] {X : TopCat.{u1}} {Y : TopCat.{u1}} (f : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1})) X Y) {ℱ : TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y} {𝒢 : TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y}, (Quiver.Hom.{succ u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (CategoryTheory.CategoryStruct.toQuiver.{u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (CategoryTheory.Category.toCategoryStruct.{u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.instCategoryPresheaf.{u1, u1, u2} C _inst_1 Y))) ℱ 𝒢) -> (Quiver.Hom.{succ u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (CategoryTheory.CategoryStruct.toQuiver.{u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (CategoryTheory.Category.toCategoryStruct.{u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (TopCat.instCategoryPresheaf.{u1, u1, u2} C _inst_1 X))) (TopCat.Presheaf.pullbackObj.{u1, u2} C _inst_1 _inst_2 X Y f ℱ) (TopCat.Presheaf.pullbackObj.{u1, u2} C _inst_1 _inst_2 X Y f 𝒢))
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pullback_map TopCat.Presheaf.pullbackMapₓ'. -/
/-- Pulling back along continuous maps is functorial. -/
def pullbackMap {X Y : TopCat.{v}} (f : X ⟶ Y) {ℱ 𝒢 : Y.Presheaf C} (α : ℱ ⟶ 𝒢) :
    pullbackObj f ℱ ⟶ pullbackObj f 𝒢 :=
  (lan (Opens.map f).op).map α
#align Top.presheaf.pullback_map TopCat.Presheaf.pullbackMap

/- warning: Top.presheaf.pullback_obj_obj_of_image_open -> TopCat.Presheaf.pullbackObjObjOfImageOpen is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pullback_obj_obj_of_image_open TopCat.Presheaf.pullbackObjObjOfImageOpenₓ'. -/
/-- If `f '' U` is open, then `f⁻¹ℱ U ≅ ℱ (f '' U)`.  -/
@[simps]
def pullbackObjObjOfImageOpen {X Y : TopCat.{v}} (f : X ⟶ Y) (ℱ : Y.Presheaf C) (U : Opens X)
    (H : IsOpen (f '' U)) : (pullbackObj f ℱ).obj (op U) ≅ ℱ.obj (op ⟨_, H⟩) :=
  by
  let x : costructured_arrow (opens.map f).op (op U) :=
    by
    refine' @costructured_arrow.mk _ _ _ _ _ (op (opens.mk (f '' U) H)) _ _
    exact (@hom_of_le _ _ _ ((opens.map f).obj ⟨_, H⟩) (set.image_preimage.le_u_l _)).op
  have hx : is_terminal x :=
    {
      lift := fun s => by
        fapply costructured_arrow.hom_mk
        change op (unop _) ⟶ op (⟨_, H⟩ : opens _)
        refine' (hom_of_le _).op
        exact
          (Set.image_subset f s.X.hom.unop.le).trans (set.image_preimage.l_u_le ↑(unop s.X.left))
        simp }
  exact
    is_colimit.cocone_point_unique_up_to_iso (colimit.is_colimit _)
      (colimit_of_diagram_terminal hx _)
#align Top.presheaf.pullback_obj_obj_of_image_open TopCat.Presheaf.pullbackObjObjOfImageOpen

namespace Pullback

variable {X Y : TopCat.{v}} (ℱ : Y.Presheaf C)

/- warning: Top.presheaf.pullback.id -> TopCat.Presheaf.Pullback.id is a dubious translation:
lean 3 declaration is
  forall {C : Type.{u2}} [_inst_1 : CategoryTheory.Category.{u1, u2} C] [_inst_2 : CategoryTheory.Limits.HasColimits.{u1, u2} C _inst_1] {Y : TopCat.{u1}} (ℱ : TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y), CategoryTheory.Iso.{u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (CategoryTheory.Functor.category.{u1, u1, u1, u2} (Opposite.{succ u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y))) (CategoryTheory.Category.opposite.{u1, u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y)) (Preorder.smallCategory.{u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y)) (PartialOrder.toPreorder.{u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y)) (SetLike.partialOrder.{u1, u1} (TopologicalSpace.Opens.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y)) (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopologicalSpace.Opens.setLike.{u1} (coeSort.{succ (succ u1), succ (succ u1)} TopCat.{u1} Type.{u1} TopCat.hasCoeToSort.{u1} Y) (TopCat.topologicalSpace.{u1} Y)))))) C _inst_1) (TopCat.Presheaf.pullbackObj.{u1, u2} C _inst_1 _inst_2 Y Y (CategoryTheory.CategoryStruct.id.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1}) Y) ℱ) ℱ
but is expected to have type
  forall {C : Type.{u2}} [_inst_1 : CategoryTheory.Category.{u1, u2} C] [_inst_2 : CategoryTheory.Limits.HasColimits.{u1, u2} C _inst_1] {Y : TopCat.{u1}} (ℱ : TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y), CategoryTheory.Iso.{u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.instCategoryPresheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.pullbackObj.{u1, u2} C _inst_1 _inst_2 Y Y (CategoryTheory.CategoryStruct.id.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1}) Y) ℱ) ℱ
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pullback.id TopCat.Presheaf.Pullback.idₓ'. -/
/-- The pullback along the identity is isomorphic to the original presheaf. -/
def id : pullbackObj (𝟙 _) ℱ ≅ ℱ :=
  NatIso.ofComponents
    (fun U =>
      pullbackObjObjOfImageOpen (𝟙 _) ℱ (unop U) (by simpa using U.unop.2) ≪≫
        ℱ.mapIso (eqToIso (by simp)))
    fun U V i => by
    ext; simp
    erw [colimit.pre_desc_assoc]
    erw [colimit.ι_desc_assoc]
    erw [colimit.ι_desc_assoc]
    dsimp; simp only [← ℱ.map_comp]; congr
#align Top.presheaf.pullback.id TopCat.Presheaf.Pullback.id

/- warning: Top.presheaf.pullback.id_inv_app -> TopCat.Presheaf.Pullback.id_inv_app is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pullback.id_inv_app TopCat.Presheaf.Pullback.id_inv_appₓ'. -/
theorem id_inv_app (U : Opens Y) :
    (id ℱ).inv.app (op U) =
      colimit.ι (Lan.diagram (Opens.map (𝟙 Y)).op ℱ (op U))
        (@CostructuredArrow.mk _ _ _ _ _ (op U) _ (eqToHom (by simp))) :=
  by
  rw [← category.id_comp ((id ℱ).inv.app (op U)), ← nat_iso.app_inv, iso.comp_inv_eq]
  dsimp [id]
  rw [colimit.ι_desc_assoc]
  dsimp
  rw [← ℱ.map_comp, ← ℱ.map_id]; rfl
#align Top.presheaf.pullback.id_inv_app TopCat.Presheaf.Pullback.id_inv_app

end Pullback

end Pullback

variable (C)

/- warning: Top.presheaf.pushforward -> TopCat.Presheaf.pushforward is a dubious translation:
lean 3 declaration is
  forall (C : Type.{u3}) [_inst_1 : CategoryTheory.Category.{u2, u3} C] {X : TopCat.{u1}} {Y : TopCat.{u1}}, (Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1})) X Y) -> (CategoryTheory.Functor.{max u1 u2, max u1 u2, max u3 u2 u1, max u3 u2 u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (TopCat.Presheaf.category.{u2, u1, u3} C _inst_1 X) (TopCat.Presheaf.{u1, u2, u3} C _inst_1 Y) (TopCat.Presheaf.category.{u2, u1, u3} C _inst_1 Y))
but is expected to have type
  forall (C : Type.{u3}) [_inst_1 : CategoryTheory.Category.{u2, u3} C] {X : TopCat.{u1}} {Y : TopCat.{u1}}, (Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1})) X Y) -> (CategoryTheory.Functor.{max u2 u1, max u2 u1, max (max u3 u2) u1, max (max u3 u2) u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (TopCat.instCategoryPresheaf.{u1, u2, u3} C _inst_1 X) (TopCat.Presheaf.{u1, u2, u3} C _inst_1 Y) (TopCat.instCategoryPresheaf.{u1, u2, u3} C _inst_1 Y))
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward TopCat.Presheaf.pushforwardₓ'. -/
/-- The pushforward functor.
-/
def pushforward {X Y : TopCat.{w}} (f : X ⟶ Y) : X.Presheaf C ⥤ Y.Presheaf C
    where
  obj := pushforwardObj f
  map := @pushforwardMap _ _ X Y f
#align Top.presheaf.pushforward TopCat.Presheaf.pushforward

/- warning: Top.presheaf.pushforward_map_app' -> TopCat.Presheaf.pushforward_map_app' is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward_map_app' TopCat.Presheaf.pushforward_map_app'ₓ'. -/
@[simp]
theorem pushforward_map_app' {X Y : TopCat.{w}} (f : X ⟶ Y) {ℱ 𝒢 : X.Presheaf C} (α : ℱ ⟶ 𝒢)
    {U : (Opens Y)ᵒᵖ} : ((pushforward C f).map α).app U = α.app (op <| (Opens.map f).obj U.unop) :=
  rfl
#align Top.presheaf.pushforward_map_app' TopCat.Presheaf.pushforward_map_app'

/- warning: Top.presheaf.id_pushforward -> TopCat.Presheaf.id_pushforward is a dubious translation:
lean 3 declaration is
  forall (C : Type.{u3}) [_inst_1 : CategoryTheory.Category.{u2, u3} C] {X : TopCat.{u1}}, Eq.{succ (max (max u1 u2) u3 u2 u1)} (CategoryTheory.Functor.{max u1 u2, max u1 u2, max u3 u2 u1, max u3 u2 u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (TopCat.Presheaf.category.{u2, u1, u3} C _inst_1 X) (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (TopCat.Presheaf.category.{u2, u1, u3} C _inst_1 X)) (TopCat.Presheaf.pushforward.{u1, u2, u3} C _inst_1 X X (CategoryTheory.CategoryStruct.id.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1}) X)) (CategoryTheory.Functor.id.{max u1 u2, max u3 u2 u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (TopCat.Presheaf.category.{u2, u1, u3} C _inst_1 X))
but is expected to have type
  forall (C : Type.{u3}) [_inst_1 : CategoryTheory.Category.{u2, u3} C] {X : TopCat.{u1}}, Eq.{max (max (succ u3) (succ u2)) (succ u1)} (CategoryTheory.Functor.{max u2 u1, max u2 u1, max (max u3 u2) u1, max (max u3 u2) u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (TopCat.instCategoryPresheaf.{u1, u2, u3} C _inst_1 X) (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (TopCat.instCategoryPresheaf.{u1, u2, u3} C _inst_1 X)) (TopCat.Presheaf.pushforward.{u1, u2, u3} C _inst_1 X X (CategoryTheory.CategoryStruct.id.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1}) X)) (CategoryTheory.Functor.id.{max u2 u1, max (max u3 u2) u1} (TopCat.Presheaf.{u1, u2, u3} C _inst_1 X) (TopCat.instCategoryPresheaf.{u1, u2, u3} C _inst_1 X))
Case conversion may be inaccurate. Consider using '#align Top.presheaf.id_pushforward TopCat.Presheaf.id_pushforwardₓ'. -/
theorem id_pushforward {X : TopCat.{w}} : pushforward C (𝟙 X) = 𝟭 (X.Presheaf C) :=
  by
  apply CategoryTheory.Functor.ext
  · intros
    ext U
    have h := f.congr
    erw [h (opens.op_map_id_obj U)]
    simpa [eq_to_hom_map]
  · intros
    apply pushforward.id_eq
#align Top.presheaf.id_pushforward TopCat.Presheaf.id_pushforward

section Iso

/- warning: Top.presheaf.presheaf_equiv_of_iso -> TopCat.Presheaf.presheafEquivOfIso is a dubious translation:
lean 3 declaration is
  forall (C : Type.{u2}) [_inst_1 : CategoryTheory.Category.{u1, u2} C] {X : TopCat.{u3}} {Y : TopCat.{u3}}, (CategoryTheory.Iso.{u3, succ u3} TopCat.{u3} TopCat.largeCategory.{u3} X Y) -> (CategoryTheory.Equivalence.{max u3 u1, max u3 u1, max u2 u1 u3, max u2 u1 u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 X) (TopCat.Presheaf.category.{u1, u3, u2} C _inst_1 X) (TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y) (TopCat.Presheaf.category.{u1, u3, u2} C _inst_1 Y))
but is expected to have type
  forall (C : Type.{u2}) [_inst_1 : CategoryTheory.Category.{u1, u2} C] {X : TopCat.{u3}} {Y : TopCat.{u3}}, (CategoryTheory.Iso.{u3, succ u3} TopCat.{u3} instTopCatLargeCategory.{u3} X Y) -> (CategoryTheory.Equivalence.{max u1 u3, max u1 u3, max (max u2 u1) u3, max (max u2 u1) u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 X) (TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y) (TopCat.instCategoryPresheaf.{u3, u1, u2} C _inst_1 X) (TopCat.instCategoryPresheaf.{u3, u1, u2} C _inst_1 Y))
Case conversion may be inaccurate. Consider using '#align Top.presheaf.presheaf_equiv_of_iso TopCat.Presheaf.presheafEquivOfIsoₓ'. -/
/-- A homeomorphism of spaces gives an equivalence of categories of presheaves. -/
@[simps]
def presheafEquivOfIso {X Y : TopCat} (H : X ≅ Y) : X.Presheaf C ≌ Y.Presheaf C :=
  Equivalence.congrLeft (Opens.mapMapIso H).symm.op
#align Top.presheaf.presheaf_equiv_of_iso TopCat.Presheaf.presheafEquivOfIso

variable {C}

/- warning: Top.presheaf.to_pushforward_of_iso -> TopCat.Presheaf.toPushforwardOfIso is a dubious translation:
lean 3 declaration is
  forall {C : Type.{u2}} [_inst_1 : CategoryTheory.Category.{u1, u2} C] {X : TopCat.{u3}} {Y : TopCat.{u3}} (H : CategoryTheory.Iso.{u3, succ u3} TopCat.{u3} TopCat.largeCategory.{u3} X Y) {ℱ : TopCat.Presheaf.{u3, u1, u2} C _inst_1 X} {𝒢 : TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y}, (Quiver.Hom.{succ (max u3 u1), max u2 u1 u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y) (CategoryTheory.CategoryStruct.toQuiver.{max u3 u1, max u2 u1 u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y) (CategoryTheory.Category.toCategoryStruct.{max u3 u1, max u2 u1 u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y) (TopCat.Presheaf.category.{u1, u3, u2} C _inst_1 Y))) (TopCat.Presheaf.pushforwardObj.{u3, u1, u2} C _inst_1 X Y (CategoryTheory.Iso.hom.{u3, succ u3} TopCat.{u3} TopCat.largeCategory.{u3} X Y H) ℱ) 𝒢) -> (Quiver.Hom.{succ (max u3 u1), max u2 u1 u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 X) (CategoryTheory.CategoryStruct.toQuiver.{max u3 u1, max u2 u1 u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 X) (CategoryTheory.Category.toCategoryStruct.{max u3 u1, max u2 u1 u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 X) (TopCat.Presheaf.category.{u1, u3, u2} C _inst_1 X))) ℱ (TopCat.Presheaf.pushforwardObj.{u3, u1, u2} C _inst_1 Y X (CategoryTheory.Iso.inv.{u3, succ u3} TopCat.{u3} TopCat.largeCategory.{u3} X Y H) 𝒢))
but is expected to have type
  forall {C : Type.{u2}} [_inst_1 : CategoryTheory.Category.{u1, u2} C] {X : TopCat.{u3}} {Y : TopCat.{u3}} (H : CategoryTheory.Iso.{u3, succ u3} TopCat.{u3} instTopCatLargeCategory.{u3} X Y) {ℱ : TopCat.Presheaf.{u3, u1, u2} C _inst_1 X} {𝒢 : TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y}, (Quiver.Hom.{max (succ u1) (succ u3), max (max u2 u1) u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y) (CategoryTheory.CategoryStruct.toQuiver.{max u1 u3, max (max u2 u1) u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y) (CategoryTheory.Category.toCategoryStruct.{max u1 u3, max (max u2 u1) u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y) (TopCat.instCategoryPresheaf.{u3, u1, u2} C _inst_1 Y))) (TopCat.Presheaf.pushforwardObj.{u3, u1, u2} C _inst_1 X Y (CategoryTheory.Iso.hom.{u3, succ u3} TopCat.{u3} instTopCatLargeCategory.{u3} X Y H) ℱ) 𝒢) -> (Quiver.Hom.{max (succ u1) (succ u3), max (max u2 u1) u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 X) (CategoryTheory.CategoryStruct.toQuiver.{max u1 u3, max (max u2 u1) u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 X) (CategoryTheory.Category.toCategoryStruct.{max u1 u3, max (max u2 u1) u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 X) (TopCat.instCategoryPresheaf.{u3, u1, u2} C _inst_1 X))) ℱ (TopCat.Presheaf.pushforwardObj.{u3, u1, u2} C _inst_1 Y X (CategoryTheory.Iso.inv.{u3, succ u3} TopCat.{u3} instTopCatLargeCategory.{u3} X Y H) 𝒢))
Case conversion may be inaccurate. Consider using '#align Top.presheaf.to_pushforward_of_iso TopCat.Presheaf.toPushforwardOfIsoₓ'. -/
/-- If `H : X ≅ Y` is a homeomorphism,
then given an `H _* ℱ ⟶ 𝒢`, we may obtain an `ℱ ⟶ H ⁻¹ _* 𝒢`.
-/
def toPushforwardOfIso {X Y : TopCat} (H : X ≅ Y) {ℱ : X.Presheaf C} {𝒢 : Y.Presheaf C}
    (α : H.Hom _* ℱ ⟶ 𝒢) : ℱ ⟶ H.inv _* 𝒢 :=
  (presheafEquivOfIso _ H).toAdjunction.homEquiv ℱ 𝒢 α
#align Top.presheaf.to_pushforward_of_iso TopCat.Presheaf.toPushforwardOfIso

/- warning: Top.presheaf.to_pushforward_of_iso_app -> TopCat.Presheaf.toPushforwardOfIso_app is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.to_pushforward_of_iso_app TopCat.Presheaf.toPushforwardOfIso_appₓ'. -/
@[simp]
theorem toPushforwardOfIso_app {X Y : TopCat} (H₁ : X ≅ Y) {ℱ : X.Presheaf C} {𝒢 : Y.Presheaf C}
    (H₂ : H₁.Hom _* ℱ ⟶ 𝒢) (U : (Opens X)ᵒᵖ) :
    (toPushforwardOfIso H₁ H₂).app U =
      ℱ.map (eqToHom (by simp [opens.map, Set.preimage_preimage])) ≫
        H₂.app (op ((Opens.map H₁.inv).obj (unop U))) :=
  by
  delta to_pushforward_of_iso
  simp only [Equiv.toFun_as_coe, nat_trans.comp_app, equivalence.equivalence_mk'_unit,
    eq_to_hom_map, eq_to_hom_op, eq_to_hom_trans, presheaf_equiv_of_iso_unit_iso_hom_app_app,
    equivalence.to_adjunction, equivalence.equivalence_mk'_counit,
    presheaf_equiv_of_iso_inverse_map_app, adjunction.mk_of_unit_counit_hom_equiv_apply]
  congr
#align Top.presheaf.to_pushforward_of_iso_app TopCat.Presheaf.toPushforwardOfIso_app

/- warning: Top.presheaf.pushforward_to_of_iso -> TopCat.Presheaf.pushforwardToOfIso is a dubious translation:
lean 3 declaration is
  forall {C : Type.{u2}} [_inst_1 : CategoryTheory.Category.{u1, u2} C] {X : TopCat.{u3}} {Y : TopCat.{u3}} (H₁ : CategoryTheory.Iso.{u3, succ u3} TopCat.{u3} TopCat.largeCategory.{u3} X Y) {ℱ : TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y} {𝒢 : TopCat.Presheaf.{u3, u1, u2} C _inst_1 X}, (Quiver.Hom.{succ (max u3 u1), max u2 u1 u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y) (CategoryTheory.CategoryStruct.toQuiver.{max u3 u1, max u2 u1 u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y) (CategoryTheory.Category.toCategoryStruct.{max u3 u1, max u2 u1 u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y) (TopCat.Presheaf.category.{u1, u3, u2} C _inst_1 Y))) ℱ (TopCat.Presheaf.pushforwardObj.{u3, u1, u2} C _inst_1 X Y (CategoryTheory.Iso.hom.{u3, succ u3} TopCat.{u3} TopCat.largeCategory.{u3} X Y H₁) 𝒢)) -> (Quiver.Hom.{succ (max u3 u1), max u2 u1 u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 X) (CategoryTheory.CategoryStruct.toQuiver.{max u3 u1, max u2 u1 u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 X) (CategoryTheory.Category.toCategoryStruct.{max u3 u1, max u2 u1 u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 X) (TopCat.Presheaf.category.{u1, u3, u2} C _inst_1 X))) (TopCat.Presheaf.pushforwardObj.{u3, u1, u2} C _inst_1 Y X (CategoryTheory.Iso.inv.{u3, succ u3} TopCat.{u3} TopCat.largeCategory.{u3} X Y H₁) ℱ) 𝒢)
but is expected to have type
  forall {C : Type.{u2}} [_inst_1 : CategoryTheory.Category.{u1, u2} C] {X : TopCat.{u3}} {Y : TopCat.{u3}} (H₁ : CategoryTheory.Iso.{u3, succ u3} TopCat.{u3} instTopCatLargeCategory.{u3} X Y) {ℱ : TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y} {𝒢 : TopCat.Presheaf.{u3, u1, u2} C _inst_1 X}, (Quiver.Hom.{max (succ u1) (succ u3), max (max u2 u1) u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y) (CategoryTheory.CategoryStruct.toQuiver.{max u1 u3, max (max u2 u1) u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y) (CategoryTheory.Category.toCategoryStruct.{max u1 u3, max (max u2 u1) u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 Y) (TopCat.instCategoryPresheaf.{u3, u1, u2} C _inst_1 Y))) ℱ (TopCat.Presheaf.pushforwardObj.{u3, u1, u2} C _inst_1 X Y (CategoryTheory.Iso.hom.{u3, succ u3} TopCat.{u3} instTopCatLargeCategory.{u3} X Y H₁) 𝒢)) -> (Quiver.Hom.{max (succ u1) (succ u3), max (max u2 u1) u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 X) (CategoryTheory.CategoryStruct.toQuiver.{max u1 u3, max (max u2 u1) u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 X) (CategoryTheory.Category.toCategoryStruct.{max u1 u3, max (max u2 u1) u3} (TopCat.Presheaf.{u3, u1, u2} C _inst_1 X) (TopCat.instCategoryPresheaf.{u3, u1, u2} C _inst_1 X))) (TopCat.Presheaf.pushforwardObj.{u3, u1, u2} C _inst_1 Y X (CategoryTheory.Iso.inv.{u3, succ u3} TopCat.{u3} instTopCatLargeCategory.{u3} X Y H₁) ℱ) 𝒢)
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward_to_of_iso TopCat.Presheaf.pushforwardToOfIsoₓ'. -/
/-- If `H : X ≅ Y` is a homeomorphism,
then given an `H _* ℱ ⟶ 𝒢`, we may obtain an `ℱ ⟶ H ⁻¹ _* 𝒢`.
-/
def pushforwardToOfIso {X Y : TopCat} (H₁ : X ≅ Y) {ℱ : Y.Presheaf C} {𝒢 : X.Presheaf C}
    (H₂ : ℱ ⟶ H₁.Hom _* 𝒢) : H₁.inv _* ℱ ⟶ 𝒢 :=
  ((presheafEquivOfIso _ H₁.symm).toAdjunction.homEquiv ℱ 𝒢).symm H₂
#align Top.presheaf.pushforward_to_of_iso TopCat.Presheaf.pushforwardToOfIso

/- warning: Top.presheaf.pushforward_to_of_iso_app -> TopCat.Presheaf.pushforwardToOfIso_app is a dubious translation:
<too large>
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward_to_of_iso_app TopCat.Presheaf.pushforwardToOfIso_appₓ'. -/
@[simp]
theorem pushforwardToOfIso_app {X Y : TopCat} (H₁ : X ≅ Y) {ℱ : Y.Presheaf C} {𝒢 : X.Presheaf C}
    (H₂ : ℱ ⟶ H₁.Hom _* 𝒢) (U : (Opens X)ᵒᵖ) :
    (pushforwardToOfIso H₁ H₂).app U =
      H₂.app (op ((Opens.map H₁.inv).obj (unop U))) ≫
        𝒢.map (eqToHom (by simp [opens.map, Set.preimage_preimage])) :=
  by simpa [pushforward_to_of_iso, equivalence.to_adjunction]
#align Top.presheaf.pushforward_to_of_iso_app TopCat.Presheaf.pushforwardToOfIso_app

end Iso

variable (C) [HasColimits C]

/- warning: Top.presheaf.pullback -> TopCat.Presheaf.pullback is a dubious translation:
lean 3 declaration is
  forall (C : Type.{u2}) [_inst_1 : CategoryTheory.Category.{u1, u2} C] [_inst_2 : CategoryTheory.Limits.HasColimits.{u1, u2} C _inst_1] {X : TopCat.{u1}} {Y : TopCat.{u1}}, (Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1})) X Y) -> (CategoryTheory.Functor.{u1, u1, max u2 u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.category.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (TopCat.Presheaf.category.{u1, u1, u2} C _inst_1 X))
but is expected to have type
  forall (C : Type.{u2}) [_inst_1 : CategoryTheory.Category.{u1, u2} C] [_inst_2 : CategoryTheory.Limits.HasColimits.{u1, u2} C _inst_1] {X : TopCat.{u1}} {Y : TopCat.{u1}}, (Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1})) X Y) -> (CategoryTheory.Functor.{u1, u1, max u2 u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.instCategoryPresheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (TopCat.instCategoryPresheaf.{u1, u1, u2} C _inst_1 X))
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pullback TopCat.Presheaf.pullbackₓ'. -/
/-- Pullback a presheaf on `Y` along a continuous map `f : X ⟶ Y`, obtaining a presheaf
on `X`. -/
@[simps map_app]
def pullback {X Y : TopCat.{v}} (f : X ⟶ Y) : Y.Presheaf C ⥤ X.Presheaf C :=
  lan (Opens.map f).op
#align Top.presheaf.pullback TopCat.Presheaf.pullback

/- warning: Top.presheaf.pullback_obj_eq_pullback_obj -> TopCat.Presheaf.pullbackObj_eq_pullbackObj is a dubious translation:
lean 3 declaration is
  forall {C : Type.{u2}} [_inst_3 : CategoryTheory.Category.{u1, u2} C] [_inst_4 : CategoryTheory.Limits.HasColimits.{u1, u2} C _inst_3] {X : TopCat.{u1}} {Y : TopCat.{u1}} (f : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1})) X Y) (ℱ : TopCat.Presheaf.{u1, u1, u2} C _inst_3 Y), Eq.{succ (max u2 u1)} (TopCat.Presheaf.{u1, u1, u2} C _inst_3 X) (CategoryTheory.Functor.obj.{u1, u1, max u2 u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_3 Y) (TopCat.Presheaf.category.{u1, u1, u2} C _inst_3 Y) (TopCat.Presheaf.{u1, u1, u2} C _inst_3 X) (TopCat.Presheaf.category.{u1, u1, u2} C _inst_3 X) (TopCat.Presheaf.pullback.{u1, u2} C _inst_3 _inst_4 X Y f) ℱ) (TopCat.Presheaf.pullbackObj.{u1, u2} C _inst_3 _inst_4 X Y f ℱ)
but is expected to have type
  forall {C : Type.{u1}} [_inst_3 : CategoryTheory.Category.{u2, u1} C] [_inst_4 : CategoryTheory.Limits.HasColimits.{u2, u1} C _inst_3] {X : TopCat.{u2}} {Y : TopCat.{u2}} (f : Quiver.Hom.{succ u2, succ u2} TopCat.{u2} (CategoryTheory.CategoryStruct.toQuiver.{u2, succ u2} TopCat.{u2} (CategoryTheory.Category.toCategoryStruct.{u2, succ u2} TopCat.{u2} instTopCatLargeCategory.{u2})) X Y) (ℱ : TopCat.Presheaf.{u2, u2, u1} C _inst_3 Y), Eq.{max (succ u2) (succ u1)} (TopCat.Presheaf.{u2, u2, u1} C _inst_3 X) (Prefunctor.obj.{succ u2, succ u2, max u2 u1, max u2 u1} (TopCat.Presheaf.{u2, u2, u1} C _inst_3 Y) (CategoryTheory.CategoryStruct.toQuiver.{u2, max u2 u1} (TopCat.Presheaf.{u2, u2, u1} C _inst_3 Y) (CategoryTheory.Category.toCategoryStruct.{u2, max u2 u1} (TopCat.Presheaf.{u2, u2, u1} C _inst_3 Y) (TopCat.instCategoryPresheaf.{u2, u2, u1} C _inst_3 Y))) (TopCat.Presheaf.{u2, u2, u1} C _inst_3 X) (CategoryTheory.CategoryStruct.toQuiver.{u2, max u2 u1} (TopCat.Presheaf.{u2, u2, u1} C _inst_3 X) (CategoryTheory.Category.toCategoryStruct.{u2, max u2 u1} (TopCat.Presheaf.{u2, u2, u1} C _inst_3 X) (TopCat.instCategoryPresheaf.{u2, u2, u1} C _inst_3 X))) (CategoryTheory.Functor.toPrefunctor.{u2, u2, max u2 u1, max u2 u1} (TopCat.Presheaf.{u2, u2, u1} C _inst_3 Y) (TopCat.instCategoryPresheaf.{u2, u2, u1} C _inst_3 Y) (TopCat.Presheaf.{u2, u2, u1} C _inst_3 X) (TopCat.instCategoryPresheaf.{u2, u2, u1} C _inst_3 X) (TopCat.Presheaf.pullback.{u2, u1} C _inst_3 _inst_4 X Y f)) ℱ) (TopCat.Presheaf.pullbackObj.{u2, u1} C _inst_3 _inst_4 X Y f ℱ)
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pullback_obj_eq_pullback_obj TopCat.Presheaf.pullbackObj_eq_pullbackObjₓ'. -/
@[simp]
theorem pullbackObj_eq_pullbackObj {C} [Category C] [HasColimits C] {X Y : TopCat.{w}} (f : X ⟶ Y)
    (ℱ : Y.Presheaf C) : (pullback C f).obj ℱ = pullbackObj f ℱ :=
  rfl
#align Top.presheaf.pullback_obj_eq_pullback_obj TopCat.Presheaf.pullbackObj_eq_pullbackObj

/- warning: Top.presheaf.pushforward_pullback_adjunction -> TopCat.Presheaf.pushforwardPullbackAdjunction is a dubious translation:
lean 3 declaration is
  forall (C : Type.{u2}) [_inst_1 : CategoryTheory.Category.{u1, u2} C] [_inst_2 : CategoryTheory.Limits.HasColimits.{u1, u2} C _inst_1] {X : TopCat.{u1}} {Y : TopCat.{u1}} (f : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1})) X Y), CategoryTheory.Adjunction.{u1, u1, max u2 u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.category.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (TopCat.Presheaf.category.{u1, u1, u2} C _inst_1 X) (TopCat.Presheaf.pullback.{u1, u2} C _inst_1 _inst_2 X Y f) (TopCat.Presheaf.pushforward.{u1, u1, u2} C _inst_1 X Y f)
but is expected to have type
  forall (C : Type.{u2}) [_inst_1 : CategoryTheory.Category.{u1, u2} C] [_inst_2 : CategoryTheory.Limits.HasColimits.{u1, u2} C _inst_1] {X : TopCat.{u1}} {Y : TopCat.{u1}} (f : Quiver.Hom.{succ u1, succ u1} TopCat.{u1} (CategoryTheory.CategoryStruct.toQuiver.{u1, succ u1} TopCat.{u1} (CategoryTheory.Category.toCategoryStruct.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1})) X Y), CategoryTheory.Adjunction.{u1, u1, max u2 u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.instCategoryPresheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (TopCat.instCategoryPresheaf.{u1, u1, u2} C _inst_1 X) (TopCat.Presheaf.pullback.{u1, u2} C _inst_1 _inst_2 X Y f) (TopCat.Presheaf.pushforward.{u1, u1, u2} C _inst_1 X Y f)
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pushforward_pullback_adjunction TopCat.Presheaf.pushforwardPullbackAdjunctionₓ'. -/
/-- The pullback and pushforward along a continuous map are adjoint to each other. -/
@[simps unit_app_app counit_app_app]
def pushforwardPullbackAdjunction {X Y : TopCat.{v}} (f : X ⟶ Y) : pullback C f ⊣ pushforward C f :=
  Lan.adjunction _ _
#align Top.presheaf.pushforward_pullback_adjunction TopCat.Presheaf.pushforwardPullbackAdjunction

/- warning: Top.presheaf.pullback_hom_iso_pushforward_inv -> TopCat.Presheaf.pullbackHomIsoPushforwardInv is a dubious translation:
lean 3 declaration is
  forall (C : Type.{u2}) [_inst_1 : CategoryTheory.Category.{u1, u2} C] [_inst_2 : CategoryTheory.Limits.HasColimits.{u1, u2} C _inst_1] {X : TopCat.{u1}} {Y : TopCat.{u1}} (H : CategoryTheory.Iso.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1} X Y), CategoryTheory.Iso.{max u2 u1, max u2 u1} (CategoryTheory.Functor.{u1, u1, max u2 u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.category.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (TopCat.Presheaf.category.{u1, u1, u2} C _inst_1 X)) (CategoryTheory.Functor.category.{u1, u1, max u2 u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.category.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (TopCat.Presheaf.category.{u1, u1, u2} C _inst_1 X)) (TopCat.Presheaf.pullback.{u1, u2} C _inst_1 _inst_2 X Y (CategoryTheory.Iso.hom.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1} X Y H)) (TopCat.Presheaf.pushforward.{u1, u1, u2} C _inst_1 Y X (CategoryTheory.Iso.inv.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1} X Y H))
but is expected to have type
  forall (C : Type.{u2}) [_inst_1 : CategoryTheory.Category.{u1, u2} C] [_inst_2 : CategoryTheory.Limits.HasColimits.{u1, u2} C _inst_1] {X : TopCat.{u1}} {Y : TopCat.{u1}} (H : CategoryTheory.Iso.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1} X Y), CategoryTheory.Iso.{max u2 u1, max u2 u1} (CategoryTheory.Functor.{u1, u1, max u2 u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.instCategoryPresheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (TopCat.instCategoryPresheaf.{u1, u1, u2} C _inst_1 X)) (CategoryTheory.Functor.category.{u1, u1, max u2 u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.instCategoryPresheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (TopCat.instCategoryPresheaf.{u1, u1, u2} C _inst_1 X)) (TopCat.Presheaf.pullback.{u1, u2} C _inst_1 _inst_2 X Y (CategoryTheory.Iso.hom.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1} X Y H)) (TopCat.Presheaf.pushforward.{u1, u1, u2} C _inst_1 Y X (CategoryTheory.Iso.inv.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1} X Y H))
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pullback_hom_iso_pushforward_inv TopCat.Presheaf.pullbackHomIsoPushforwardInvₓ'. -/
/-- Pulling back along a homeomorphism is the same as pushing forward along its inverse. -/
def pullbackHomIsoPushforwardInv {X Y : TopCat.{v}} (H : X ≅ Y) :
    pullback C H.Hom ≅ pushforward C H.inv :=
  Adjunction.leftAdjointUniq (pushforwardPullbackAdjunction C H.Hom)
    (presheafEquivOfIso C H.symm).toAdjunction
#align Top.presheaf.pullback_hom_iso_pushforward_inv TopCat.Presheaf.pullbackHomIsoPushforwardInv

/- warning: Top.presheaf.pullback_inv_iso_pushforward_hom -> TopCat.Presheaf.pullbackInvIsoPushforwardHom is a dubious translation:
lean 3 declaration is
  forall (C : Type.{u2}) [_inst_1 : CategoryTheory.Category.{u1, u2} C] [_inst_2 : CategoryTheory.Limits.HasColimits.{u1, u2} C _inst_1] {X : TopCat.{u1}} {Y : TopCat.{u1}} (H : CategoryTheory.Iso.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1} X Y), CategoryTheory.Iso.{max u2 u1, max u2 u1} (CategoryTheory.Functor.{u1, u1, max u2 u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (TopCat.Presheaf.category.{u1, u1, u2} C _inst_1 X) (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.category.{u1, u1, u2} C _inst_1 Y)) (CategoryTheory.Functor.category.{u1, u1, max u2 u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (TopCat.Presheaf.category.{u1, u1, u2} C _inst_1 X) (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.Presheaf.category.{u1, u1, u2} C _inst_1 Y)) (TopCat.Presheaf.pullback.{u1, u2} C _inst_1 _inst_2 Y X (CategoryTheory.Iso.inv.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1} X Y H)) (TopCat.Presheaf.pushforward.{u1, u1, u2} C _inst_1 X Y (CategoryTheory.Iso.hom.{u1, succ u1} TopCat.{u1} TopCat.largeCategory.{u1} X Y H))
but is expected to have type
  forall (C : Type.{u2}) [_inst_1 : CategoryTheory.Category.{u1, u2} C] [_inst_2 : CategoryTheory.Limits.HasColimits.{u1, u2} C _inst_1] {X : TopCat.{u1}} {Y : TopCat.{u1}} (H : CategoryTheory.Iso.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1} X Y), CategoryTheory.Iso.{max u2 u1, max u2 u1} (CategoryTheory.Functor.{u1, u1, max u2 u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (TopCat.instCategoryPresheaf.{u1, u1, u2} C _inst_1 X) (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.instCategoryPresheaf.{u1, u1, u2} C _inst_1 Y)) (CategoryTheory.Functor.category.{u1, u1, max u2 u1, max u2 u1} (TopCat.Presheaf.{u1, u1, u2} C _inst_1 X) (TopCat.instCategoryPresheaf.{u1, u1, u2} C _inst_1 X) (TopCat.Presheaf.{u1, u1, u2} C _inst_1 Y) (TopCat.instCategoryPresheaf.{u1, u1, u2} C _inst_1 Y)) (TopCat.Presheaf.pullback.{u1, u2} C _inst_1 _inst_2 Y X (CategoryTheory.Iso.inv.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1} X Y H)) (TopCat.Presheaf.pushforward.{u1, u1, u2} C _inst_1 X Y (CategoryTheory.Iso.hom.{u1, succ u1} TopCat.{u1} instTopCatLargeCategory.{u1} X Y H))
Case conversion may be inaccurate. Consider using '#align Top.presheaf.pullback_inv_iso_pushforward_hom TopCat.Presheaf.pullbackInvIsoPushforwardHomₓ'. -/
/-- Pulling back along the inverse of a homeomorphism is the same as pushing forward along it. -/
def pullbackInvIsoPushforwardHom {X Y : TopCat.{v}} (H : X ≅ Y) :
    pullback C H.inv ≅ pushforward C H.Hom :=
  Adjunction.leftAdjointUniq (pushforwardPullbackAdjunction C H.inv)
    (presheafEquivOfIso C H).toAdjunction
#align Top.presheaf.pullback_inv_iso_pushforward_hom TopCat.Presheaf.pullbackInvIsoPushforwardHom

end Presheaf

end TopCat

