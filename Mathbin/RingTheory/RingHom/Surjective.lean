/-
Copyright (c) 2022 Andrew Yang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Andrew Yang
-/
import Mathbin.RingTheory.LocalProperties

/-!

# The meta properties of surjective ring homomorphisms.

-/


namespace RingHom

open TensorProduct

open TensorProduct Algebra.TensorProduct

-- mathport name: exprsurjective
local notation "surjective" => fun {X Y : Type _} [CommRing X] [CommRing Y] => fun f : X →+* Y =>
  Function.Surjective f

theorem surjective_stable_under_composition : StableUnderComposition surjective := by
  introv R hf hg
  exact hg.comp hf
#align ring_hom.surjective_stable_under_composition RingHom.surjective_stable_under_composition

theorem surjective_respects_iso : RespectsIso surjective := by
  apply surjective_stable_under_composition.respects_iso
  intros
  exact e.surjective
#align ring_hom.surjective_respects_iso RingHom.surjective_respects_iso

theorem surjective_stable_under_base_change : StableUnderBaseChange surjective := by
  refine' stable_under_base_change.mk _ surjective_respects_iso _
  classical 
    introv h x
    skip
    induction' x using TensorProduct.induction_on with x y x y ex ey
    · exact ⟨0, map_zero _⟩
    · obtain ⟨y, rfl⟩ := h y
      use y • x
      dsimp
      rw [TensorProduct.smul_tmul, Algebra.algebra_map_eq_smul_one]
    · obtain ⟨⟨x, rfl⟩, ⟨y, rfl⟩⟩ := ex, ey
      exact ⟨x + y, map_add _ x y⟩
#align ring_hom.surjective_stable_under_base_change RingHom.surjective_stable_under_base_change

open BigOperators

theorem surjective_of_localization_span : OfLocalizationSpan surjective := by
  introv R hs H
  skip
  letI := f.to_algebra
  show Function.Surjective (Algebra.ofId R S)
  rw [← Algebra.range_top_iff_surjective, eq_top_iff]
  rintro x -
  obtain ⟨l, hl⟩ :=
    (Finsupp.mem_span_iff_total R s 1).mp
      (show _ ∈ Ideal.span s by 
        rw [hs]
        trivial)
  fapply
    Subalgebra.mem_of_finset_sum_eq_one_of_pow_smul_mem _ l.support (fun x : s => f x) fun x : s =>
      f (l x)
  · dsimp only
    simp_rw [← _root_.map_mul, ← map_sum, ← f.map_one]
    exact f.congr_arg hl
  · exact fun _ => Set.mem_range_self _
  · exact fun _ => Set.mem_range_self _
  · intro r
    obtain ⟨y, hy⟩ := H r (IsLocalization.mk' _ x (1 : Submonoid.powers (f r)))
    obtain ⟨z, ⟨_, n, rfl⟩, rfl⟩ := IsLocalization.mk'_surjective (Submonoid.powers (r : R)) y
    erw [IsLocalization.map_mk', IsLocalization.eq] at hy
    obtain ⟨⟨_, m, rfl⟩, hm⟩ := hy
    dsimp at hm
    simp_rw [_root_.mul_assoc, _root_.one_mul, ← map_pow, ← f.map_mul, ← pow_add, mul_comm x] at hm
    rw [map_pow] at hm
    refine' ⟨n + m, _, hm⟩
#align ring_hom.surjective_of_localization_span RingHom.surjective_of_localization_span

end RingHom

