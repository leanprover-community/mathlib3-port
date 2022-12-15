/-
Copyright (c) 2018 Mario Carneiro, Kevin Buzzard. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Kevin Buzzard

! This file was ported from Lean 3 source module ring_theory.ideal.idempotent_fg
! leanprover-community/mathlib commit aba57d4d3dae35460225919dcd82fe91355162f9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Ring.Idempotents
import Mathbin.RingTheory.Finiteness

/-!
## Lemmas on idempotent finitely generated ideals
-/


namespace Ideal

/-- A finitely generated idempotent ideal is generated by an idempotent element -/
theorem is_idempotent_elem_iff_of_fg {R : Type _} [CommRing R] (I : Ideal R) (h : I.Fg) :
    IsIdempotentElem I ↔ ∃ e : R, IsIdempotentElem e ∧ I = R ∙ e := by
  constructor
  · intro e
    obtain ⟨r, hr, hr'⟩ :=
      Submodule.exists_mem_and_smul_eq_self_of_fg_of_le_smul I I h
        (by 
          rw [smul_eq_mul]
          exact e.ge)
    simp_rw [smul_eq_mul] at hr'
    refine' ⟨r, hr' r hr, antisymm _ ((Submodule.span_singleton_le_iff_mem _ _).mpr hr)⟩
    intro x hx
    rw [← hr' x hx]
    exact ideal.mem_span_singleton'.mpr ⟨_, mul_comm _ _⟩
  · rintro ⟨e, he, rfl⟩
    simp [IsIdempotentElem, Ideal.span_singleton_mul_span_singleton, he.eq]
#align ideal.is_idempotent_elem_iff_of_fg Ideal.is_idempotent_elem_iff_of_fg

theorem is_idempotent_elem_iff_eq_bot_or_top {R : Type _} [CommRing R] [IsDomain R] (I : Ideal R)
    (h : I.Fg) : IsIdempotentElem I ↔ I = ⊥ ∨ I = ⊤ := by
  constructor
  · intro H
    obtain ⟨e, he, rfl⟩ := (I.is_idempotent_elem_iff_of_fg h).mp H
    simp only [Ideal.submodule_span_eq, Ideal.span_singleton_eq_bot]
    apply or_of_or_of_imp_of_imp (is_idempotent_elem.iff_eq_zero_or_one.mp he) id
    rintro rfl
    simp
  · rintro (rfl | rfl) <;> simp [IsIdempotentElem]
#align ideal.is_idempotent_elem_iff_eq_bot_or_top Ideal.is_idempotent_elem_iff_eq_bot_or_top

end Ideal

