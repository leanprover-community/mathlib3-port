/-
Copyright (c) 2017 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Massot, Scott Morrison, Mario Carneiro, Andrew Yang

! This file was ported from Lean 3 source module topology.category.Top.limits.konig
! leanprover-community/mathlib commit 178a32653e369dce2da68dc6b2694e385d484ef1
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Category.Top.Limits.Basic

/-!
# Topological Kőnig's lemma

A topological version of Kőnig's lemma is that the inverse limit of nonempty compact Hausdorff
spaces is nonempty.  (Note: this can be generalized further to inverse limits of nonempty compact
T0 spaces, where all the maps are closed maps; see [Stone1979] --- however there is an erratum
for Theorem 4 that the element in the inverse limit can have cofinally many components that are
not closed points.)

We give this in a more general form, which is that cofiltered limits
of nonempty compact Hausdorff spaces are nonempty
(`nonempty_limit_cone_of_compact_t2_cofiltered_system`).

This also applies to inverse limits, where `{J : Type u} [preorder J] [is_directed J (≤)]` and
`F : Jᵒᵖ ⥤ Top`.

The theorem is specialized to nonempty finite types (which are compact Hausdorff with the
discrete topology) in lemmas `nonempty_sections_of_finite_cofiltered_system` and
`nonempty_sections_of_finite_inverse_system` in the file `category_theory.cofiltered_system`.

(See <https://stacks.math.columbia.edu/tag/086J> for the Set version.)
-/


open CategoryTheory

open CategoryTheory.Limits

universe u v w

noncomputable section

namespace TopCat

section TopologicalKonig

variable {J : Type u} [SmallCategory J]

variable (F : J ⥤ TopCat.{u})

private abbrev finite_diagram_arrow {J : Type u} [SmallCategory J] (G : Finset J) :=
  Σ'(X Y : J)(mX : X ∈ G)(mY : Y ∈ G), X ⟶ Y
#align Top.finite_diagram_arrow Top.finite_diagram_arrow

private abbrev finite_diagram (J : Type u) [SmallCategory J] :=
  ΣG : Finset J, Finset (FiniteDiagramArrow G)
#align Top.finite_diagram Top.finite_diagram

/- warning: Top.partial_sections -> TopCat.partialSections is a dubious translation:
lean 3 declaration is
  forall {J : Type.{u}} [_inst_2 : CategoryTheory.SmallCategory.{u} J] (F : CategoryTheory.Functor.{u, u, u, succ u} J _inst_2 TopCat.{u} TopCat.largeCategory.{u}) {G : Finset.{u} J}, (Finset.{u} (_Private.2248226883.FiniteDiagramArrow.{u} J _inst_2 G)) -> (Set.{u} (forall (j : J), coeSort.{succ (succ u), succ (succ u)} TopCat.{u} Type.{u} TopCat.hasCoeToSort.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_2 TopCat.{u} TopCat.largeCategory.{u} F j)))
but is expected to have type
  forall {J : Type.{u}} [_inst_2 : CategoryTheory.SmallCategory.{u} J] (F : CategoryTheory.Functor.{u, u_1, u, succ u_1} J _inst_2 TopCat.{u_1} instTopCatLargeCategory.{u_1}) {G : Finset.{u} J}, (Finset.{u} (_private.Mathlib.Topology.Category.Top.Limits.Konig.0.TopCat.FiniteDiagramArrow.{u} J _inst_2 G)) -> (Set.{max u u_1} (forall (j : J), CategoryTheory.Bundled.α.{u_1, u_1} TopologicalSpace.{u_1} (Prefunctor.obj.{succ u, succ u_1, u, succ u_1} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_2)) TopCat.{u_1} (CategoryTheory.CategoryStruct.toQuiver.{u_1, succ u_1} TopCat.{u_1} (CategoryTheory.Category.toCategoryStruct.{u_1, succ u_1} TopCat.{u_1} instTopCatLargeCategory.{u_1})) (CategoryTheory.Functor.toPrefunctor.{u, u_1, u, succ u_1} J _inst_2 TopCat.{u_1} instTopCatLargeCategory.{u_1} F) j)))
Case conversion may be inaccurate. Consider using '#align Top.partial_sections TopCat.partialSectionsₓ'. -/
/-- Partial sections of a cofiltered limit are sections when restricted to
a finite subset of objects and morphisms of `J`.
-/
def partialSections {J : Type u} [SmallCategory J] (F : J ⥤ TopCat.{u}) {G : Finset J}
    (H : Finset (FiniteDiagramArrow G)) : Set (∀ j, F.obj j) :=
  { u | ∀ {f : FiniteDiagramArrow G} (hf : f ∈ H), F.map f.2.2.2.2 (u f.1) = u f.2.1 }
#align Top.partial_sections TopCat.partialSections

/- warning: Top.partial_sections.nonempty -> TopCat.partialSections.nonempty is a dubious translation:
lean 3 declaration is
  forall {J : Type.{u}} [_inst_1 : CategoryTheory.SmallCategory.{u} J] (F : CategoryTheory.Functor.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u}) [_inst_2 : CategoryTheory.IsCofilteredOrEmpty.{u, u} J _inst_1] [h : forall (j : J), Nonempty.{succ u} (coeSort.{succ (succ u), succ (succ u)} TopCat.{u} Type.{u} TopCat.hasCoeToSort.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F j))] {G : Finset.{u} J} (H : Finset.{u} (_Private.2248226883.FiniteDiagramArrow.{u} J _inst_1 G)), Set.Nonempty.{u} (forall (j : J), coeSort.{succ (succ u), succ (succ u)} TopCat.{u} Type.{u} TopCat.hasCoeToSort.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F j)) (TopCat.partialSections.{u} J _inst_1 F G H)
but is expected to have type
  forall {J : Type.{u}} [_inst_1 : CategoryTheory.SmallCategory.{u} J] (F : CategoryTheory.Functor.{u, u_1, u, succ u_1} J _inst_1 TopCat.{u_1} instTopCatLargeCategory.{u_1}) [_inst_2 : CategoryTheory.IsCofilteredOrEmpty.{u, u} J _inst_1] [h : forall (j : J), Nonempty.{succ u_1} (CategoryTheory.Bundled.α.{u_1, u_1} TopologicalSpace.{u_1} (Prefunctor.obj.{succ u, succ u_1, u, succ u_1} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_1)) TopCat.{u_1} (CategoryTheory.CategoryStruct.toQuiver.{u_1, succ u_1} TopCat.{u_1} (CategoryTheory.Category.toCategoryStruct.{u_1, succ u_1} TopCat.{u_1} instTopCatLargeCategory.{u_1})) (CategoryTheory.Functor.toPrefunctor.{u, u_1, u, succ u_1} J _inst_1 TopCat.{u_1} instTopCatLargeCategory.{u_1} F) j))] {G : Finset.{u} J} (H : Finset.{u} (_private.Mathlib.Topology.Category.Top.Limits.Konig.0.TopCat.FiniteDiagramArrow.{u} J _inst_1 G)), Set.Nonempty.{max u u_1} (forall (j : J), CategoryTheory.Bundled.α.{u_1, u_1} TopologicalSpace.{u_1} (Prefunctor.obj.{succ u, succ u_1, u, succ u_1} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_1)) TopCat.{u_1} (CategoryTheory.CategoryStruct.toQuiver.{u_1, succ u_1} TopCat.{u_1} (CategoryTheory.Category.toCategoryStruct.{u_1, succ u_1} TopCat.{u_1} instTopCatLargeCategory.{u_1})) (CategoryTheory.Functor.toPrefunctor.{u, u_1, u, succ u_1} J _inst_1 TopCat.{u_1} instTopCatLargeCategory.{u_1} F) j)) (TopCat.partialSections.{u, u_1} J _inst_1 F G H)
Case conversion may be inaccurate. Consider using '#align Top.partial_sections.nonempty TopCat.partialSections.nonemptyₓ'. -/
theorem partialSections.nonempty [IsCofilteredOrEmpty J] [h : ∀ j : J, Nonempty (F.obj j)]
    {G : Finset J} (H : Finset (FiniteDiagramArrow G)) : (partialSections F H).Nonempty := by
  classical
    cases isEmpty_or_nonempty J
    · exact ⟨isEmptyElim, fun j => IsEmpty.elim' inferInstance j.1⟩
    haveI : is_cofiltered J := ⟨⟩
    use fun j : J =>
      if hj : j ∈ G then F.map (is_cofiltered.inf_to G H hj) (h (is_cofiltered.inf G H)).some
      else (h _).some
    rintro ⟨X, Y, hX, hY, f⟩ hf
    dsimp only
    rwa [dif_pos hX, dif_pos hY, ← comp_app, ← F.map_comp, @is_cofiltered.inf_to_commutes _ _ _ G H]
#align Top.partial_sections.nonempty TopCat.partialSections.nonempty

/- warning: Top.partial_sections.directed -> TopCat.partialSections.directed is a dubious translation:
lean 3 declaration is
  forall {J : Type.{u}} [_inst_1 : CategoryTheory.SmallCategory.{u} J] (F : CategoryTheory.Functor.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u}), Directed.{u, succ u} (Set.{u} (forall (j : J), coeSort.{succ (succ u), succ (succ u)} TopCat.{u} Type.{u} TopCat.hasCoeToSort.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F j))) (_Private.858651669.FiniteDiagram.{u} J _inst_1) (Superset.{u} (Set.{u} (forall (j : J), coeSort.{succ (succ u), succ (succ u)} TopCat.{u} Type.{u} TopCat.hasCoeToSort.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F j))) (Set.hasSubset.{u} (forall (j : J), coeSort.{succ (succ u), succ (succ u)} TopCat.{u} Type.{u} TopCat.hasCoeToSort.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F j)))) (fun (G : _Private.858651669.FiniteDiagram.{u} J _inst_1) => TopCat.partialSections.{u} J _inst_1 F (Sigma.fst.{u, u} (Finset.{u} J) (fun (G : Finset.{u} J) => Finset.{u} (_Private.2248226883.FiniteDiagramArrow.{u} J _inst_1 G)) G) (Sigma.snd.{u, u} (Finset.{u} J) (fun (G : Finset.{u} J) => Finset.{u} (_Private.2248226883.FiniteDiagramArrow.{u} J _inst_1 G)) G))
but is expected to have type
  forall {J : Type.{u}} [_inst_1 : CategoryTheory.SmallCategory.{u} J] (F : CategoryTheory.Functor.{u, u_1, u, succ u_1} J _inst_1 TopCat.{u_1} instTopCatLargeCategory.{u_1}), Directed.{max u u_1, succ u} (Set.{max u u_1} (forall (j : J), CategoryTheory.Bundled.α.{u_1, u_1} TopologicalSpace.{u_1} (Prefunctor.obj.{succ u, succ u_1, u, succ u_1} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_1)) TopCat.{u_1} (CategoryTheory.CategoryStruct.toQuiver.{u_1, succ u_1} TopCat.{u_1} (CategoryTheory.Category.toCategoryStruct.{u_1, succ u_1} TopCat.{u_1} instTopCatLargeCategory.{u_1})) (CategoryTheory.Functor.toPrefunctor.{u, u_1, u, succ u_1} J _inst_1 TopCat.{u_1} instTopCatLargeCategory.{u_1} F) j))) (_private.Mathlib.Topology.Category.Top.Limits.Konig.0.TopCat.FiniteDiagram.{u} J _inst_1) (Superset.{max u u_1} (Set.{max u u_1} (forall (j : J), CategoryTheory.Bundled.α.{u_1, u_1} TopologicalSpace.{u_1} (Prefunctor.obj.{succ u, succ u_1, u, succ u_1} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_1)) TopCat.{u_1} (CategoryTheory.CategoryStruct.toQuiver.{u_1, succ u_1} TopCat.{u_1} (CategoryTheory.Category.toCategoryStruct.{u_1, succ u_1} TopCat.{u_1} instTopCatLargeCategory.{u_1})) (CategoryTheory.Functor.toPrefunctor.{u, u_1, u, succ u_1} J _inst_1 TopCat.{u_1} instTopCatLargeCategory.{u_1} F) j))) (Set.instHasSubsetSet.{max u u_1} (forall (j : J), CategoryTheory.Bundled.α.{u_1, u_1} TopologicalSpace.{u_1} (Prefunctor.obj.{succ u, succ u_1, u, succ u_1} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_1)) TopCat.{u_1} (CategoryTheory.CategoryStruct.toQuiver.{u_1, succ u_1} TopCat.{u_1} (CategoryTheory.Category.toCategoryStruct.{u_1, succ u_1} TopCat.{u_1} instTopCatLargeCategory.{u_1})) (CategoryTheory.Functor.toPrefunctor.{u, u_1, u, succ u_1} J _inst_1 TopCat.{u_1} instTopCatLargeCategory.{u_1} F) j)))) (fun (G : _private.Mathlib.Topology.Category.Top.Limits.Konig.0.TopCat.FiniteDiagram.{u} J _inst_1) => TopCat.partialSections.{u, u_1} J _inst_1 F (Sigma.fst.{u, u} (Finset.{u} J) (fun (G : Finset.{u} J) => Finset.{u} (_private.Mathlib.Topology.Category.Top.Limits.Konig.0.TopCat.FiniteDiagramArrow.{u} J _inst_1 G)) G) (Sigma.snd.{u, u} (Finset.{u} J) (fun (G : Finset.{u} J) => Finset.{u} (_private.Mathlib.Topology.Category.Top.Limits.Konig.0.TopCat.FiniteDiagramArrow.{u} J _inst_1 G)) G))
Case conversion may be inaccurate. Consider using '#align Top.partial_sections.directed TopCat.partialSections.directedₓ'. -/
theorem partialSections.directed :
    Directed Superset fun G : FiniteDiagram J => partialSections F G.2 := by
  classical
    intro A B
    let ιA : finite_diagram_arrow A.1 → finite_diagram_arrow (A.1 ⊔ B.1) := fun f =>
      ⟨f.1, f.2.1, Finset.mem_union_left _ f.2.2.1, Finset.mem_union_left _ f.2.2.2.1, f.2.2.2.2⟩
    let ιB : finite_diagram_arrow B.1 → finite_diagram_arrow (A.1 ⊔ B.1) := fun f =>
      ⟨f.1, f.2.1, Finset.mem_union_right _ f.2.2.1, Finset.mem_union_right _ f.2.2.2.1, f.2.2.2.2⟩
    refine' ⟨⟨A.1 ⊔ B.1, A.2.image ιA ⊔ B.2.image ιB⟩, _, _⟩
    · rintro u hu f hf
      have : ιA f ∈ A.2.image ιA ⊔ B.2.image ιB :=
        by
        apply Finset.mem_union_left
        rw [Finset.mem_image]
        refine' ⟨f, hf, rfl⟩
      exact hu this
    · rintro u hu f hf
      have : ιB f ∈ A.2.image ιA ⊔ B.2.image ιB :=
        by
        apply Finset.mem_union_right
        rw [Finset.mem_image]
        refine' ⟨f, hf, rfl⟩
      exact hu this
#align Top.partial_sections.directed TopCat.partialSections.directed

/- warning: Top.partial_sections.closed -> TopCat.partialSections.closed is a dubious translation:
lean 3 declaration is
  forall {J : Type.{u}} [_inst_1 : CategoryTheory.SmallCategory.{u} J] (F : CategoryTheory.Functor.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u}) [_inst_2 : forall (j : J), T2Space.{u} (coeSort.{succ (succ u), succ (succ u)} TopCat.{u} Type.{u} TopCat.hasCoeToSort.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F j)) (TopCat.topologicalSpace.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F j))] {G : Finset.{u} J} (H : Finset.{u} (_Private.2248226883.FiniteDiagramArrow.{u} J _inst_1 G)), IsClosed.{u} (forall (j : J), coeSort.{succ (succ u), succ (succ u)} TopCat.{u} Type.{u} TopCat.hasCoeToSort.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F j)) (Pi.topologicalSpace.{u, u} J (fun (j : J) => coeSort.{succ (succ u), succ (succ u)} TopCat.{u} Type.{u} TopCat.hasCoeToSort.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F j)) (fun (a : J) => TopCat.topologicalSpace.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F a))) (TopCat.partialSections.{u} J _inst_1 F G H)
but is expected to have type
  forall {J : Type.{u}} [_inst_1 : CategoryTheory.SmallCategory.{u} J] (F : CategoryTheory.Functor.{u, u_1, u, succ u_1} J _inst_1 TopCat.{u_1} instTopCatLargeCategory.{u_1}) [_inst_2 : forall (j : J), T2Space.{u_1} (CategoryTheory.Bundled.α.{u_1, u_1} TopologicalSpace.{u_1} (Prefunctor.obj.{succ u, succ u_1, u, succ u_1} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_1)) TopCat.{u_1} (CategoryTheory.CategoryStruct.toQuiver.{u_1, succ u_1} TopCat.{u_1} (CategoryTheory.Category.toCategoryStruct.{u_1, succ u_1} TopCat.{u_1} instTopCatLargeCategory.{u_1})) (CategoryTheory.Functor.toPrefunctor.{u, u_1, u, succ u_1} J _inst_1 TopCat.{u_1} instTopCatLargeCategory.{u_1} F) j)) (TopCat.topologicalSpace_coe.{u_1} (Prefunctor.obj.{succ u, succ u_1, u, succ u_1} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_1)) TopCat.{u_1} (CategoryTheory.CategoryStruct.toQuiver.{u_1, succ u_1} TopCat.{u_1} (CategoryTheory.Category.toCategoryStruct.{u_1, succ u_1} TopCat.{u_1} instTopCatLargeCategory.{u_1})) (CategoryTheory.Functor.toPrefunctor.{u, u_1, u, succ u_1} J _inst_1 TopCat.{u_1} instTopCatLargeCategory.{u_1} F) j))] {G : Finset.{u} J} (H : Finset.{u} (_private.Mathlib.Topology.Category.Top.Limits.Konig.0.TopCat.FiniteDiagramArrow.{u} J _inst_1 G)), IsClosed.{max u u_1} (forall (j : J), CategoryTheory.Bundled.α.{u_1, u_1} TopologicalSpace.{u_1} (Prefunctor.obj.{succ u, succ u_1, u, succ u_1} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_1)) TopCat.{u_1} (CategoryTheory.CategoryStruct.toQuiver.{u_1, succ u_1} TopCat.{u_1} (CategoryTheory.Category.toCategoryStruct.{u_1, succ u_1} TopCat.{u_1} instTopCatLargeCategory.{u_1})) (CategoryTheory.Functor.toPrefunctor.{u, u_1, u, succ u_1} J _inst_1 TopCat.{u_1} instTopCatLargeCategory.{u_1} F) j)) (Pi.topologicalSpace.{u, u_1} J (fun (j : J) => CategoryTheory.Bundled.α.{u_1, u_1} TopologicalSpace.{u_1} (Prefunctor.obj.{succ u, succ u_1, u, succ u_1} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_1)) TopCat.{u_1} (CategoryTheory.CategoryStruct.toQuiver.{u_1, succ u_1} TopCat.{u_1} (CategoryTheory.Category.toCategoryStruct.{u_1, succ u_1} TopCat.{u_1} instTopCatLargeCategory.{u_1})) (CategoryTheory.Functor.toPrefunctor.{u, u_1, u, succ u_1} J _inst_1 TopCat.{u_1} instTopCatLargeCategory.{u_1} F) j)) (fun (a : J) => TopCat.topologicalSpace_coe.{u_1} (Prefunctor.obj.{succ u, succ u_1, u, succ u_1} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_1)) TopCat.{u_1} (CategoryTheory.CategoryStruct.toQuiver.{u_1, succ u_1} TopCat.{u_1} (CategoryTheory.Category.toCategoryStruct.{u_1, succ u_1} TopCat.{u_1} instTopCatLargeCategory.{u_1})) (CategoryTheory.Functor.toPrefunctor.{u, u_1, u, succ u_1} J _inst_1 TopCat.{u_1} instTopCatLargeCategory.{u_1} F) a))) (TopCat.partialSections.{u, u_1} J _inst_1 F G H)
Case conversion may be inaccurate. Consider using '#align Top.partial_sections.closed TopCat.partialSections.closedₓ'. -/
theorem partialSections.closed [∀ j : J, T2Space (F.obj j)] {G : Finset J}
    (H : Finset (FiniteDiagramArrow G)) : IsClosed (partialSections F H) :=
  by
  have :
    partial_sections F H =
      ⋂ (f : finite_diagram_arrow G) (hf : f ∈ H), { u | F.map f.2.2.2.2 (u f.1) = u f.2.1 } :=
    by
    ext1
    simp only [Set.mem_iInter, Set.mem_setOf_eq]
    rfl
  rw [this]
  apply isClosed_biInter
  intro f hf
  apply isClosed_eq
  continuity
#align Top.partial_sections.closed TopCat.partialSections.closed

/- warning: Top.nonempty_limit_cone_of_compact_t2_cofiltered_system -> TopCat.nonempty_limitCone_of_compact_t2_cofiltered_system is a dubious translation:
lean 3 declaration is
  forall {J : Type.{u}} [_inst_1 : CategoryTheory.SmallCategory.{u} J] (F : CategoryTheory.Functor.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u}) [_inst_2 : CategoryTheory.IsCofilteredOrEmpty.{u, u} J _inst_1] [_inst_3 : forall (j : J), Nonempty.{succ u} (coeSort.{succ (succ u), succ (succ u)} TopCat.{u} Type.{u} TopCat.hasCoeToSort.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F j))] [_inst_4 : forall (j : J), CompactSpace.{u} (coeSort.{succ (succ u), succ (succ u)} TopCat.{u} Type.{u} TopCat.hasCoeToSort.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F j)) (TopCat.topologicalSpace.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F j))] [_inst_5 : forall (j : J), T2Space.{u} (coeSort.{succ (succ u), succ (succ u)} TopCat.{u} Type.{u} TopCat.hasCoeToSort.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F j)) (TopCat.topologicalSpace.{u} (CategoryTheory.Functor.obj.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F j))], Nonempty.{succ u} (coeSort.{succ (succ u), succ (succ u)} TopCat.{u} Type.{u} TopCat.hasCoeToSort.{u} (CategoryTheory.Limits.Cone.pt.{u, u, u, succ u} J _inst_1 TopCat.{u} TopCat.largeCategory.{u} F (TopCat.limitCone.{u, u} J _inst_1 F)))
but is expected to have type
  forall {J : Type.{u}} [_inst_1 : CategoryTheory.SmallCategory.{u} J] (F : CategoryTheory.Functor.{u, max u u_1, u, succ (max u u_1)} J _inst_1 TopCat.{max u u_1} instTopCatLargeCategory.{max u u_1}) [_inst_2 : CategoryTheory.IsCofilteredOrEmpty.{u, u} J _inst_1] [_inst_3 : forall (j : J), Nonempty.{succ (max u u_1)} (CategoryTheory.Bundled.α.{max u u_1, max u u_1} TopologicalSpace.{max u u_1} (Prefunctor.obj.{succ u, succ (max u u_1), u, succ (max u u_1)} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_1)) TopCat.{max u u_1} (CategoryTheory.CategoryStruct.toQuiver.{max u u_1, succ (max u u_1)} TopCat.{max u u_1} (CategoryTheory.Category.toCategoryStruct.{max u u_1, succ (max u u_1)} TopCat.{max u u_1} instTopCatLargeCategory.{max u u_1})) (CategoryTheory.Functor.toPrefunctor.{u, max u u_1, u, succ (max u u_1)} J _inst_1 TopCat.{max u u_1} instTopCatLargeCategory.{max u u_1} F) j))] [_inst_4 : forall (j : J), CompactSpace.{max u u_1} (CategoryTheory.Bundled.α.{max u u_1, max u u_1} TopologicalSpace.{max u u_1} (Prefunctor.obj.{succ u, succ (max u u_1), u, succ (max u u_1)} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_1)) TopCat.{max u u_1} (CategoryTheory.CategoryStruct.toQuiver.{max u u_1, succ (max u u_1)} TopCat.{max u u_1} (CategoryTheory.Category.toCategoryStruct.{max u u_1, succ (max u u_1)} TopCat.{max u u_1} instTopCatLargeCategory.{max u u_1})) (CategoryTheory.Functor.toPrefunctor.{u, max u u_1, u, succ (max u u_1)} J _inst_1 TopCat.{max u u_1} instTopCatLargeCategory.{max u u_1} F) j)) (TopCat.topologicalSpace_coe.{max u u_1} (Prefunctor.obj.{succ u, succ (max u u_1), u, succ (max u u_1)} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_1)) TopCat.{max u u_1} (CategoryTheory.CategoryStruct.toQuiver.{max u u_1, succ (max u u_1)} TopCat.{max u u_1} (CategoryTheory.Category.toCategoryStruct.{max u u_1, succ (max u u_1)} TopCat.{max u u_1} instTopCatLargeCategory.{max u u_1})) (CategoryTheory.Functor.toPrefunctor.{u, max u u_1, u, succ (max u u_1)} J _inst_1 TopCat.{max u u_1} instTopCatLargeCategory.{max u u_1} F) j))] [_inst_5 : forall (j : J), T2Space.{max u u_1} (CategoryTheory.Bundled.α.{max u u_1, max u u_1} TopologicalSpace.{max u u_1} (Prefunctor.obj.{succ u, succ (max u u_1), u, succ (max u u_1)} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_1)) TopCat.{max u u_1} (CategoryTheory.CategoryStruct.toQuiver.{max u u_1, succ (max u u_1)} TopCat.{max u u_1} (CategoryTheory.Category.toCategoryStruct.{max u u_1, succ (max u u_1)} TopCat.{max u u_1} instTopCatLargeCategory.{max u u_1})) (CategoryTheory.Functor.toPrefunctor.{u, max u u_1, u, succ (max u u_1)} J _inst_1 TopCat.{max u u_1} instTopCatLargeCategory.{max u u_1} F) j)) (TopCat.topologicalSpace_coe.{max u u_1} (Prefunctor.obj.{succ u, succ (max u u_1), u, succ (max u u_1)} J (CategoryTheory.CategoryStruct.toQuiver.{u, u} J (CategoryTheory.Category.toCategoryStruct.{u, u} J _inst_1)) TopCat.{max u u_1} (CategoryTheory.CategoryStruct.toQuiver.{max u u_1, succ (max u u_1)} TopCat.{max u u_1} (CategoryTheory.Category.toCategoryStruct.{max u u_1, succ (max u u_1)} TopCat.{max u u_1} instTopCatLargeCategory.{max u u_1})) (CategoryTheory.Functor.toPrefunctor.{u, max u u_1, u, succ (max u u_1)} J _inst_1 TopCat.{max u u_1} instTopCatLargeCategory.{max u u_1} F) j))], Nonempty.{max (succ u) (succ u_1)} (CategoryTheory.Bundled.α.{max u u_1, max u u_1} TopologicalSpace.{max u u_1} (CategoryTheory.Limits.Cone.pt.{u, max u u_1, u, max (succ u) (succ u_1)} J _inst_1 TopCatMax.{u, u_1} instTopCatLargeCategory.{max u_1 u} F (TopCat.limitCone.{u, u_1} J _inst_1 F)))
Case conversion may be inaccurate. Consider using '#align Top.nonempty_limit_cone_of_compact_t2_cofiltered_system TopCat.nonempty_limitCone_of_compact_t2_cofiltered_systemₓ'. -/
/-- Cofiltered limits of nonempty compact Hausdorff spaces are nonempty topological spaces.
-/
theorem nonempty_limitCone_of_compact_t2_cofiltered_system [IsCofilteredOrEmpty J]
    [∀ j : J, Nonempty (F.obj j)] [∀ j : J, CompactSpace (F.obj j)] [∀ j : J, T2Space (F.obj j)] :
    Nonempty (TopCat.limitCone.{u} F).pt := by
  classical
    obtain ⟨u, hu⟩ :=
      IsCompact.nonempty_iInter_of_directed_nonempty_compact_closed (fun G => partial_sections F _)
        (partial_sections.directed F) (fun G => partial_sections.nonempty F _)
        (fun G => IsClosed.isCompact (partial_sections.closed F _)) fun G =>
        partial_sections.closed F _
    use u
    intro X Y f
    let G : finite_diagram J :=
      ⟨{X, Y},
        {⟨X, Y, by simp only [true_or_iff, eq_self_iff_true, Finset.mem_insert], by
            simp only [eq_self_iff_true, or_true_iff, Finset.mem_insert, Finset.mem_singleton], f⟩}⟩
    exact hu _ ⟨G, rfl⟩ (Finset.mem_singleton_self _)
#align Top.nonempty_limit_cone_of_compact_t2_cofiltered_system TopCat.nonempty_limitCone_of_compact_t2_cofiltered_system

end TopologicalKonig

end TopCat

