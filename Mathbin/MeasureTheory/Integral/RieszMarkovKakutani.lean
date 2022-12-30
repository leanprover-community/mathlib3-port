/-
Copyright (c) 2022 Jesse Reimann. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jesse Reimann, Kalle Kytölä

! This file was ported from Lean 3 source module measure_theory.integral.riesz_markov_kakutani
! leanprover-community/mathlib commit 986c4d5761f938b2e1c43c01f001b6d9d88c2055
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.ContinuousFunction.Bounded
import Mathbin.Topology.Sets.Compacts

/-!
#  Riesz–Markov–Kakutani representation theorem

This file will prove different versions of the Riesz-Markov-Kakutani representation theorem.
The theorem is first proven for compact spaces, from which the statements about linear functionals
on bounded continuous functions or compactly supported functions on locally compact spaces follow.

To make use of the existing API, the measure is constructed from a content `λ` on the
compact subsets of the space X, rather than the usual construction of open sets in the literature.

## References

* [Walter Rudin, Real and Complex Analysis.][Rud87]

-/


noncomputable section

open BoundedContinuousFunction Nnreal Ennreal

open Set Function TopologicalSpace

variable {X : Type _} [TopologicalSpace X]

variable (Λ : (X →ᵇ ℝ≥0) →ₗ[ℝ≥0] ℝ≥0)

/-! ### Construction of the content: -/


/-- Given a positive linear functional Λ on X, for `K ⊆ X` compact define
`λ(K) = inf {Λf | 1≤f on K}`. When X is a compact Hausdorff space, this will be shown to be a
content, and will be shown to agree with the Riesz measure on the compact subsets `K ⊆ X`. -/
def rieszContentAux : Compacts X → ℝ≥0 := fun K =>
  infₛ (Λ '' { f : X →ᵇ ℝ≥0 | ∀ x ∈ K, (1 : ℝ≥0) ≤ f x })
#align riesz_content_aux rieszContentAux

section RieszMonotone

/-- For any compact subset `K ⊆ X`, there exist some bounded continuous nonnegative
functions f on X such that `f ≥ 1` on K. -/
theorem riesz_content_aux_image_nonempty (K : Compacts X) :
    (Λ '' { f : X →ᵇ ℝ≥0 | ∀ x ∈ K, (1 : ℝ≥0) ≤ f x }).Nonempty :=
  by
  rw [nonempty_image_iff]
  use (1 : X →ᵇ ℝ≥0)
  intro x x_in_K
  simp only [BoundedContinuousFunction.coe_one, Pi.one_apply]
#align riesz_content_aux_image_nonempty riesz_content_aux_image_nonempty

/-- Riesz content λ (associated with a positive linear functional Λ) is
monotone: if `K₁ ⊆ K₂` are compact subsets in X, then `λ(K₁) ≤ λ(K₂)`. -/
theorem riesz_content_aux_mono {K₁ K₂ : Compacts X} (h : K₁ ≤ K₂) :
    rieszContentAux Λ K₁ ≤ rieszContentAux Λ K₂ :=
  cInf_le_cInf (OrderBot.bddBelow _) (riesz_content_aux_image_nonempty Λ K₂)
    (image_subset Λ (setOf_subset_setOf.mpr fun f f_hyp x x_in_K₁ => f_hyp x (h x_in_K₁)))
#align riesz_content_aux_mono riesz_content_aux_mono

end RieszMonotone

section RieszSubadditive

/-- Any bounded continuous nonnegative f such that `f ≥ 1` on K gives an upper bound on the
content of K; namely `λ(K) ≤ Λ f`. -/
theorem riesz_content_aux_le {K : Compacts X} {f : X →ᵇ ℝ≥0} (h : ∀ x ∈ K, (1 : ℝ≥0) ≤ f x) :
    rieszContentAux Λ K ≤ Λ f :=
  cInf_le (OrderBot.bddBelow _) ⟨f, ⟨h, rfl⟩⟩
#align riesz_content_aux_le riesz_content_aux_le

/-- The Riesz content can be approximated arbitrarily well by evaluating the positive linear
functional on test functions: for any `ε > 0`, there exists a bounded continuous nonnegative
function f on X such that `f ≥ 1` on K and such that `λ(K) ≤ Λ f < λ(K) + ε`. -/
theorem exists_lt_riesz_content_aux_add_pos (K : Compacts X) {ε : ℝ≥0} (εpos : 0 < ε) :
    ∃ f : X →ᵇ ℝ≥0, (∀ x ∈ K, (1 : ℝ≥0) ≤ f x) ∧ Λ f < rieszContentAux Λ K + ε :=
  by
  --choose a test function `f` s.t. `Λf = α < λ(K) + ε`
  obtain ⟨α, ⟨⟨f, f_hyp⟩, α_hyp⟩⟩ :=
    exists_lt_of_cInf_lt (riesz_content_aux_image_nonempty Λ K)
      (lt_add_of_pos_right (rieszContentAux Λ K) εpos)
  refine' ⟨f, f_hyp.left, _⟩
  rw [f_hyp.right]
  exact α_hyp
#align exists_lt_riesz_content_aux_add_pos exists_lt_riesz_content_aux_add_pos

/-- The Riesz content λ associated to a given positive linear functional Λ is
finitely subadditive: `λ(K₁ ∪ K₂) ≤ λ(K₁) + λ(K₂)` for any compact subsets `K₁, K₂ ⊆ X`. -/
theorem riesz_content_aux_sup_le (K1 K2 : Compacts X) :
    rieszContentAux Λ (K1 ⊔ K2) ≤ rieszContentAux Λ K1 + rieszContentAux Λ K2 :=
  by
  apply Nnreal.le_of_forall_pos_le_add
  intro ε εpos
  --get test functions s.t. `λ(Ki) ≤ Λfi ≤ λ(Ki) + ε/2, i=1,2`
  obtain ⟨f1, f_test_function_K1⟩ := exists_lt_riesz_content_aux_add_pos Λ K1 (Nnreal.half_pos εpos)
  obtain ⟨f2, f_test_function_K2⟩ := exists_lt_riesz_content_aux_add_pos Λ K2 (Nnreal.half_pos εpos)
  --let `f := f1 + f2` test function for the content of `K`
  have f_test_function_union : ∀ x ∈ K1 ⊔ K2, (1 : ℝ≥0) ≤ (f1 + f2) x :=
    by
    rintro x (x_in_K1 | x_in_K2)
    · exact le_add_right (f_test_function_K1.left x x_in_K1)
    · exact le_add_left (f_test_function_K2.left x x_in_K2)
  --use that `Λf` is an upper bound for `λ(K1⊔K2)`
  apply (riesz_content_aux_le Λ f_test_function_union).trans (le_of_lt _)
  rw [map_add]
  --use that `Λfi` are lower bounds for `λ(Ki) + ε/2`
  apply lt_of_lt_of_le (add_lt_add f_test_function_K1.right f_test_function_K2.right) (le_of_eq _)
  rw [add_assoc, add_comm (ε / 2), add_assoc, Nnreal.add_halves ε, add_assoc]
#align riesz_content_aux_sup_le riesz_content_aux_sup_le

end RieszSubadditive

