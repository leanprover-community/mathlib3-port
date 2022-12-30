/-
Copyright (c) 2019 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module topology.fiber_bundle.is_homeomorphic_trivial_bundle
! leanprover-community/mathlib commit 09597669f02422ed388036273d8848119699c22f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Homeomorph

/-!
# Maps equivariantly-homeomorphic to projection in a product

This file contains the definition `is_homeomorphic_trivial_fiber_bundle F p`, a Prop saying that a
map `p : Z → B` between topological spaces is a "trivial fiber bundle" in the sense that there
exists a homeomorphism `h : Z ≃ₜ B × F` such that `proj x = (h x).1`.  This is an abstraction which
is occasionally convenient in showing that a map is open, a quotient map, etc.

This material was formerly linked to the main definition of fibre bundles, but after a series of
refactors, there is no longer a direct connection.
-/


variable {B : Type _} (F : Type _) {Z : Type _} [TopologicalSpace B] [TopologicalSpace F]
  [TopologicalSpace Z]

/-- A trivial fiber bundle with fiber `F` over a base `B` is a space `Z`
projecting on `B` for which there exists a homeomorphism to `B × F` that sends `proj`
to `prod.fst`. -/
def IsHomeomorphicTrivialFiberBundle (proj : Z → B) : Prop :=
  ∃ e : Z ≃ₜ B × F, ∀ x, (e x).1 = proj x
#align is_homeomorphic_trivial_fiber_bundle IsHomeomorphicTrivialFiberBundle

namespace IsHomeomorphicTrivialFiberBundle

variable {F} {proj : Z → B}

protected theorem proj_eq (h : IsHomeomorphicTrivialFiberBundle F proj) :
    ∃ e : Z ≃ₜ B × F, proj = Prod.fst ∘ e :=
  ⟨h.some, (funext h.some_spec).symm⟩
#align is_homeomorphic_trivial_fiber_bundle.proj_eq IsHomeomorphicTrivialFiberBundle.proj_eq

/-- The projection from a trivial fiber bundle to its base is surjective. -/
protected theorem surjective_proj [Nonempty F] (h : IsHomeomorphicTrivialFiberBundle F proj) :
    Function.Surjective proj := by
  obtain ⟨e, rfl⟩ := h.proj_eq
  exact prod.fst_surjective.comp e.surjective
#align
  is_homeomorphic_trivial_fiber_bundle.surjective_proj IsHomeomorphicTrivialFiberBundle.surjective_proj

/-- The projection from a trivial fiber bundle to its base is continuous. -/
protected theorem continuous_proj (h : IsHomeomorphicTrivialFiberBundle F proj) : Continuous proj :=
  by
  obtain ⟨e, rfl⟩ := h.proj_eq
  exact continuous_fst.comp e.continuous
#align
  is_homeomorphic_trivial_fiber_bundle.continuous_proj IsHomeomorphicTrivialFiberBundle.continuous_proj

/-- The projection from a trivial fiber bundle to its base is open. -/
protected theorem is_open_map_proj (h : IsHomeomorphicTrivialFiberBundle F proj) : IsOpenMap proj :=
  by
  obtain ⟨e, rfl⟩ := h.proj_eq
  exact is_open_map_fst.comp e.is_open_map
#align
  is_homeomorphic_trivial_fiber_bundle.is_open_map_proj IsHomeomorphicTrivialFiberBundle.is_open_map_proj

/-- The projection from a trivial fiber bundle to its base is open. -/
protected theorem quotient_map_proj [Nonempty F] (h : IsHomeomorphicTrivialFiberBundle F proj) :
    QuotientMap proj :=
  h.is_open_map_proj.to_quotient_map h.continuous_proj h.surjective_proj
#align
  is_homeomorphic_trivial_fiber_bundle.quotient_map_proj IsHomeomorphicTrivialFiberBundle.quotient_map_proj

end IsHomeomorphicTrivialFiberBundle

/-- The first projection in a product is a trivial fiber bundle. -/
theorem is_homeomorphic_trivial_fiber_bundle_fst :
    IsHomeomorphicTrivialFiberBundle F (Prod.fst : B × F → B) :=
  ⟨Homeomorph.refl _, fun x => rfl⟩
#align is_homeomorphic_trivial_fiber_bundle_fst is_homeomorphic_trivial_fiber_bundle_fst

/-- The second projection in a product is a trivial fiber bundle. -/
theorem is_homeomorphic_trivial_fiber_bundle_snd :
    IsHomeomorphicTrivialFiberBundle F (Prod.snd : F × B → B) :=
  ⟨Homeomorph.prodComm _ _, fun x => rfl⟩
#align is_homeomorphic_trivial_fiber_bundle_snd is_homeomorphic_trivial_fiber_bundle_snd

