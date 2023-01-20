/-
Copyright (c) 2022 Pierre-Alexandre Bazin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Pierre-Alexandre Bazin

! This file was ported from Lean 3 source module ring_theory.coprime.ideal
! leanprover-community/mathlib commit 1126441d6bccf98c81214a0780c73d499f6721fe
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Dfinsupp
import Mathbin.RingTheory.Ideal.Operations

/-!
# An additional lemma about coprime ideals

This lemma generalises `exists_sum_eq_one_iff_pairwise_coprime` to the case of non-principal ideals.
It is on a separate file due to import requirements.
-/


namespace Ideal

variable {ι R : Type _} [CommSemiring R]

/-- A finite family of ideals is pairwise coprime (that is, any two of them generate the whole ring)
iff when taking all the possible intersections of all but one of these ideals, the resulting family
of ideals still generate the whole ring.

For example with three ideals : `I ⊔ J = I ⊔ K = J ⊔ K = ⊤ ↔ (I ⊓ J) ⊔ (I ⊓ K) ⊔ (J ⊓ K) = ⊤`.

When ideals are all of the form `I i = R ∙ s i`, this is equivalent to the
`exists_sum_eq_one_iff_pairwise_coprime` lemma.-/
theorem supᵢ_infᵢ_eq_top_iff_pairwise {t : Finset ι} (h : t.Nonempty) (I : ι → Ideal R) :
    (⨆ i ∈ t, ⨅ (j) (hj : j ∈ t) (ij : j ≠ i), I j) = ⊤ ↔
      (t : Set ι).Pairwise fun i j => I i ⊔ I j = ⊤ :=
  by
  haveI : DecidableEq ι := Classical.decEq ι
  rw [eq_top_iff_one, Submodule.mem_supᵢ_finset_iff_exists_sum]
  refine' h.cons_induction _ _ <;> clear t h
  · simp only [Finset.sum_singleton, Finset.coe_singleton, Set.pairwise_singleton, iff_true_iff]
    refine' fun a => ⟨fun i => if h : i = a then ⟨1, _⟩ else 0, _⟩
    · rw [h]
      simp only [Finset.mem_singleton, Ne.def, infᵢ_infᵢ_eq_left, eq_self_iff_true, not_true,
        infᵢ_false]
    · simp only [dif_pos, dif_ctx_congr, Submodule.coe_mk, eq_self_iff_true]
  intro a t hat h ih
  rw [Finset.coe_cons,
    Set.pairwise_insert_of_symmetric fun i j (h : I i ⊔ I j = ⊤) => sup_comm.trans h]
  constructor
  · rintro ⟨μ, hμ⟩
    rw [Finset.sum_cons] at hμ
    refine' ⟨ih.mp ⟨Pi.single h.some ⟨μ a, _⟩ + fun i => ⟨μ i, _⟩, _⟩, fun b hb ab => _⟩
    · have := Submodule.coe_mem (μ a)
      rw [mem_infi] at this⊢
      --for some reason `simp only [mem_infi]` times out
      intro i
      specialize this i
      rw [mem_infi, mem_infi] at this⊢
      intro hi _
      apply this (Finset.subset_cons _ hi)
      rintro rfl
      exact hat hi
    · have := Submodule.coe_mem (μ i)
      simp only [mem_infi] at this⊢
      intro j hj ij
      exact this _ (Finset.subset_cons _ hj) ij
    · rw [← @if_pos _ _ h.some_spec R (μ a) 0, ← Finset.sum_pi_single', ← Finset.sum_add_distrib] at
        hμ
      convert hμ
      ext i
      rw [Pi.add_apply, Submodule.coe_add, Submodule.coe_mk]
      by_cases hi : i = h.some
      · rw [hi, Pi.single_eq_same, Pi.single_eq_same, Submodule.coe_mk]
      · rw [Pi.single_eq_of_ne hi, Pi.single_eq_of_ne hi, Submodule.coe_zero]
    · rw [eq_top_iff_one, Submodule.mem_sup]
      rw [add_comm] at hμ
      refine' ⟨_, _, _, _, hμ⟩
      · refine' sum_mem _ fun x hx => _
        have := Submodule.coe_mem (μ x)
        simp only [mem_infi] at this
        apply this _ (Finset.mem_cons_self _ _)
        rintro rfl
        exact hat hx
      · have := Submodule.coe_mem (μ a)
        simp only [mem_infi] at this
        exact this _ (Finset.subset_cons _ hb) ab.symm
  · rintro ⟨hs, Hb⟩
    obtain ⟨μ, hμ⟩ := ih.mpr hs
    obtain ⟨u, hu, v, hv, huv⟩ :=
      submodule.mem_sup.mp
        ((eq_top_iff_one _).mp <|
          sup_infi_eq_top fun b hb =>
            Hb b hb <| by
              rintro rfl
              exact hat hb)
    refine' ⟨fun i => if hi : i = a then ⟨v, _⟩ else ⟨u * μ i, _⟩, _⟩
    · simp only [mem_infi] at hv⊢
      intro j hj ij
      rw [Finset.mem_cons, ← hi] at hj
      exact hv _ (hj.resolve_left ij)
    · have := Submodule.coe_mem (μ i)
      simp only [mem_infi] at this⊢
      intro j hj ij
      rcases finset.mem_cons.mp hj with (rfl | hj)
      · exact mul_mem_right _ _ hu
      · exact mul_mem_left _ _ (this _ hj ij)
    · rw [Finset.sum_cons, dif_pos rfl, add_comm]
      rw [← mul_one u] at huv
      rw [← huv, ← hμ, Finset.mul_sum]
      congr 1
      apply Finset.sum_congr rfl
      intro j hj
      rw [dif_neg]
      rfl
      rintro rfl
      exact hat hj
#align ideal.supr_infi_eq_top_iff_pairwise Ideal.supᵢ_infᵢ_eq_top_iff_pairwise

end Ideal

