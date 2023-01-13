/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.convex.contractible
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Convex.Star
import Mathbin.Topology.Homotopy.Contractible

/-!
# A convex set is contractible

In this file we prove that a (star) convex set in a real topological vector space is a contractible
topological space.
-/


variable {E : Type _} [AddCommGroup E] [Module ℝ E] [TopologicalSpace E] [HasContinuousAdd E]
  [HasContinuousSmul ℝ E] {s : Set E} {x : E}

/-- A non-empty star convex set is a contractible space. -/
protected theorem StarConvex.contractible_space (h : StarConvex ℝ x s) (hne : s.Nonempty) :
    ContractibleSpace s :=
  by
  refine'
    (contractible_iff_id_nullhomotopic _).2
      ⟨⟨x, h.mem hne⟩, ⟨⟨⟨fun p => ⟨p.1.1 • x + (1 - p.1.1) • p.2, _⟩, _⟩, fun x => _, fun x => _⟩⟩⟩
  · exact h p.2.2 p.1.2.1 (sub_nonneg.2 p.1.2.2) (add_sub_cancel'_right _ _)
  ·
    exact
      ((continuous_subtype_val.fst'.smul continuous_const).add
            ((continuous_const.sub continuous_subtype_val.fst').smul
              continuous_subtype_val.snd')).subtype_mk
        _
  · ext1
    simp
  · ext1
    simp
#align star_convex.contractible_space StarConvex.contractible_space

/-- A non-empty convex set is a contractible space. -/
protected theorem Convex.contractible_space (hs : Convex ℝ s) (hne : s.Nonempty) :
    ContractibleSpace s :=
  let ⟨x, hx⟩ := hne
  (hs.StarConvex hx).ContractibleSpace hne
#align convex.contractible_space Convex.contractible_space

instance (priority := 100) RealTopologicalVectorSpace.contractible_space : ContractibleSpace E :=
  (Homeomorph.Set.univ E).contractible_space_iff.mp <|
    convex_univ.ContractibleSpace Set.univ_nonempty
#align
  real_topological_vector_space.contractible_space RealTopologicalVectorSpace.contractible_space

