/-
Copyright (c) 2021 Justus Springer. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Justus Springer

! This file was ported from Lean 3 source module topology.sheaves.sheaf_condition.sites
! leanprover-community/mathlib commit 0743cc5d9d86bcd1bba10f480e948a257d65056f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Sites.Spaces
import Mathbin.Topology.Sheaves.Sheaf
import Mathbin.CategoryTheory.Sites.DenseSubsite

/-!

# Coverings and sieves; from sheaves on sites and sheaves on spaces

In this file, we connect coverings in a topological space to sieves in the associated Grothendieck
topology, in preparation of connecting the sheaf condition on sites to the various sheaf conditions
on spaces.

We also specialize results about sheaves on sites to sheaves on spaces; we show that the inclusion
functor from a topological basis to `topological_space.opens` is cover_dense, that open maps
induce cover_preserving functors, and that open embeddings induce compatible_preserving functors.

-/


noncomputable section

universe w v u

open CategoryTheory TopologicalSpace

namespace TopCat.Presheaf

variable {X : TopCat.{w}}

/-- Given a presieve `R` on `U`, we obtain a covering family of open sets in `X`, by taking as index
type the type of dependent pairs `(V, f)`, where `f : V ⟶ U` is in `R`.
-/
def coveringOfPresieve (U : Opens X) (R : Presieve U) : (ΣV, { f : V ⟶ U // R f }) → Opens X :=
  fun f => f.1
#align Top.presheaf.covering_of_presieve TopCat.Presheaf.coveringOfPresieve

@[simp]
theorem covering_of_presieve_apply (U : Opens X) (R : Presieve U) (f : ΣV, { f : V ⟶ U // R f }) :
    coveringOfPresieve U R f = f.1 :=
  rfl
#align Top.presheaf.covering_of_presieve_apply TopCat.Presheaf.covering_of_presieve_apply

namespace CoveringOfPresieve

variable (U : Opens X) (R : Presieve U)

/--
If `R` is a presieve in the grothendieck topology on `opens X`, the covering family associated to
`R` really is _covering_, i.e. the union of all open sets equals `U`.
-/
theorem supr_eq_of_mem_grothendieck (hR : Sieve.generate R ∈ Opens.grothendieckTopology X U) :
    supᵢ (coveringOfPresieve U R) = U := by
  apply le_antisymm
  · refine' supᵢ_le _
    intro f
    exact f.2.1.le
  intro x hxU
  rw [opens.mem_coe, opens.mem_supr]
  obtain ⟨V, iVU, ⟨W, iVW, iWU, hiWU, -⟩, hxV⟩ := hR x hxU
  exact ⟨⟨W, ⟨iWU, hiWU⟩⟩, iVW.le hxV⟩
#align
  Top.presheaf.covering_of_presieve.supr_eq_of_mem_grothendieck TopCat.Presheaf.coveringOfPresieve.supr_eq_of_mem_grothendieck

end CoveringOfPresieve

/-- Given a family of opens `U : ι → opens X` and any open `Y : opens X`, we obtain a presieve
on `Y` by declaring that a morphism `f : V ⟶ Y` is a member of the presieve if and only if
there exists an index `i : ι` such that `V = U i`.
-/
def presieveOfCoveringAux {ι : Type v} (U : ι → Opens X) (Y : Opens X) : Presieve Y := fun V f =>
  ∃ i, V = U i
#align Top.presheaf.presieve_of_covering_aux TopCat.Presheaf.presieveOfCoveringAux

/-- Take `Y` to be `supr U` and obtain a presieve over `supr U`. -/
def presieveOfCovering {ι : Type v} (U : ι → Opens X) : Presieve (supᵢ U) :=
  presieveOfCoveringAux U (supᵢ U)
#align Top.presheaf.presieve_of_covering TopCat.Presheaf.presieveOfCovering

/-- Given a presieve `R` on `Y`, if we take its associated family of opens via
    `covering_of_presieve` (which may not cover `Y` if `R` is not covering), and take
    the presieve on `Y` associated to the family of opens via `presieve_of_covering_aux`,
    then we get back the original presieve `R`. -/
@[simp]
theorem covering_presieve_eq_self {Y : Opens X} (R : Presieve Y) :
    presieveOfCoveringAux (coveringOfPresieve Y R) Y = R := by
  ext (Z f)
  exact ⟨fun ⟨⟨_, _, h⟩, rfl⟩ => by convert h, fun h => ⟨⟨Z, f, h⟩, rfl⟩⟩
#align Top.presheaf.covering_presieve_eq_self TopCat.Presheaf.covering_presieve_eq_self

namespace PresieveOfCovering

variable {ι : Type v} (U : ι → Opens X)

/-- The sieve generated by `presieve_of_covering U` is a member of the grothendieck topology.
-/
theorem mem_grothendieck_topology :
    Sieve.generate (presieveOfCovering U) ∈ Opens.grothendieckTopology X (supᵢ U) := by
  intro x hx
  obtain ⟨i, hxi⟩ := opens.mem_supr.mp hx
  exact ⟨U i, opens.le_supr U i, ⟨U i, 𝟙 _, opens.le_supr U i, ⟨i, rfl⟩, category.id_comp _⟩, hxi⟩
#align
  Top.presheaf.presieve_of_covering.mem_grothendieck_topology TopCat.Presheaf.presieveOfCovering.mem_grothendieck_topology

/-- An index `i : ι` can be turned into a dependent pair `(V, f)`, where `V` is an open set and
`f : V ⟶ supr U` is a member of `presieve_of_covering U f`.
-/
def homOfIndex (i : ι) : ΣV, { f : V ⟶ supᵢ U // presieveOfCovering U f } :=
  ⟨U i, Opens.leSupr U i, i, rfl⟩
#align Top.presheaf.presieve_of_covering.hom_of_index TopCat.Presheaf.presieveOfCovering.homOfIndex

/-- By using the axiom of choice, a dependent pair `(V, f)` where `f : V ⟶ supr U` is a member of
`presieve_of_covering U f` can be turned into an index `i : ι`, such that `V = U i`.
-/
def indexOfHom (f : ΣV, { f : V ⟶ supᵢ U // presieveOfCovering U f }) : ι :=
  f.2.2.some
#align Top.presheaf.presieve_of_covering.index_of_hom TopCat.Presheaf.presieveOfCovering.indexOfHom

theorem index_of_hom_spec (f : ΣV, { f : V ⟶ supᵢ U // presieveOfCovering U f }) :
    f.1 = U (indexOfHom U f) :=
  f.2.2.some_spec
#align
  Top.presheaf.presieve_of_covering.index_of_hom_spec TopCat.Presheaf.presieveOfCovering.index_of_hom_spec

end PresieveOfCovering

end TopCat.Presheaf

namespace TopCat.Opens

variable {X : TopCat} {ι : Type _}

theorem cover_dense_iff_is_basis [Category ι] (B : ι ⥤ Opens X) :
    CoverDense (Opens.grothendieckTopology X) B ↔ Opens.IsBasis (Set.range B.obj) := by
  rw [opens.is_basis_iff_nbhd]
  constructor; intro hd U x hx; rcases hd.1 U x hx with ⟨V, f, ⟨i, f₁, f₂, hc⟩, hV⟩
  exact ⟨B.obj i, ⟨i, rfl⟩, f₁.le hV, f₂.le⟩
  intro hb; constructor; intro U x hx; rcases hb hx with ⟨_, ⟨i, rfl⟩, hx, hi⟩
  exact ⟨B.obj i, ⟨⟨hi⟩⟩, ⟨⟨i, 𝟙 _, ⟨⟨hi⟩⟩, rfl⟩⟩, hx⟩
#align Top.opens.cover_dense_iff_is_basis TopCat.Opens.cover_dense_iff_is_basis

theorem cover_dense_induced_functor {B : ι → Opens X} (h : Opens.IsBasis (Set.range B)) :
    CoverDense (Opens.grothendieckTopology X) (inducedFunctor B) :=
  (cover_dense_iff_is_basis _).2 h
#align Top.opens.cover_dense_induced_functor TopCat.Opens.cover_dense_induced_functor

end TopCat.Opens

section OpenEmbedding

open TopCat.Presheaf Opposite

variable {C : Type u} [Category.{v} C]

variable {X Y : TopCat.{w}} {f : X ⟶ Y} {F : Y.Presheaf C}

theorem OpenEmbedding.compatiblePreserving (hf : OpenEmbedding f) :
    CompatiblePreserving (Opens.grothendieckTopology Y) hf.IsOpenMap.Functor := by
  haveI : mono f := (TopCat.mono_iff_injective f).mpr hf.inj
  apply compatible_preserving_of_downwards_closed
  intro U V i
  refine'
    ⟨(opens.map f).obj V, eq_to_iso <| opens.ext <| Set.image_preimage_eq_of_subset fun x h => _⟩
  obtain ⟨_, _, rfl⟩ := i.le h
  exact ⟨_, rfl⟩
#align open_embedding.compatible_preserving OpenEmbedding.compatiblePreserving

theorem IsOpenMap.cover_preserving (hf : IsOpenMap f) :
    CoverPreserving (Opens.grothendieckTopology X) (Opens.grothendieckTopology Y) hf.Functor := by
  constructor
  rintro U S hU _ ⟨x, hx, rfl⟩
  obtain ⟨V, i, hV, hxV⟩ := hU x hx
  exact ⟨_, hf.functor.map i, ⟨_, i, 𝟙 _, hV, rfl⟩, Set.mem_image_of_mem f hxV⟩
#align is_open_map.cover_preserving IsOpenMap.cover_preserving

theorem TopCat.Presheaf.is_sheaf_of_open_embedding (h : OpenEmbedding f) (hF : F.IsSheaf) :
    IsSheaf (h.IsOpenMap.Functor.op ⋙ F) :=
  pullback_is_sheaf_of_cover_preserving h.CompatiblePreserving h.IsOpenMap.CoverPreserving ⟨_, hF⟩
#align Top.presheaf.is_sheaf_of_open_embedding TopCat.Presheaf.is_sheaf_of_open_embedding

end OpenEmbedding

namespace TopCat.Sheaf

open TopCat Opposite

variable {C : Type u} [Category.{v} C]

variable {X : TopCat.{w}} {ι : Type _} {B : ι → Opens X}

variable (F : X.Presheaf C) (F' : Sheaf C X) (h : Opens.IsBasis (Set.range B))

/-- The empty component of a sheaf is terminal -/
def isTerminalOfEmpty (F : Sheaf C X) : Limits.IsTerminal (F.val.obj (op ∅)) :=
  F.isTerminalOfBotCover ∅ (by tidy)
#align Top.sheaf.is_terminal_of_empty TopCat.Sheaf.isTerminalOfEmpty

/-- A variant of `is_terminal_of_empty` that is easier to `apply`. -/
def isTerminalOfEqEmpty (F : X.Sheaf C) {U : Opens X} (h : U = ∅) :
    Limits.IsTerminal (F.val.obj (op U)) := by convert F.is_terminal_of_empty
#align Top.sheaf.is_terminal_of_eq_empty TopCat.Sheaf.isTerminalOfEqEmpty

/-- If a family `B` of open sets forms a basis of the topology on `X`, and if `F'`
    is a sheaf on `X`, then a homomorphism between a presheaf `F` on `X` and `F'`
    is equivalent to a homomorphism between their restrictions to the indexing type
    `ι` of `B`, with the induced category structure on `ι`. -/
def restrictHomEquivHom : ((inducedFunctor B).op ⋙ F ⟶ (inducedFunctor B).op ⋙ F'.1) ≃ (F ⟶ F'.1) :=
  @CoverDense.restrictHomEquivHom _ _ _ _ _ _ _ _ (Opens.cover_dense_induced_functor h) _ F F'
#align Top.sheaf.restrict_hom_equiv_hom TopCat.Sheaf.restrictHomEquivHom

@[simp]
theorem extend_hom_app (α : (inducedFunctor B).op ⋙ F ⟶ (inducedFunctor B).op ⋙ F'.1) (i : ι) :
    (restrictHomEquivHom F F' h α).app (op (B i)) = α.app (op i) := by
  nth_rw 2 [← (restrict_hom_equiv_hom F F' h).left_inv α]
  rfl
#align Top.sheaf.extend_hom_app TopCat.Sheaf.extend_hom_app

include h

theorem hom_ext {α β : F ⟶ F'.1} (he : ∀ i, α.app (op (B i)) = β.app (op (B i))) : α = β := by
  apply (restrict_hom_equiv_hom F F' h).symm.Injective
  ext i
  exact he i.unop
#align Top.sheaf.hom_ext TopCat.Sheaf.hom_ext

end TopCat.Sheaf

