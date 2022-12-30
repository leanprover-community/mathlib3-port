/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Mario Carneiro, Johan Commelin, Amelia Livingston, Anne Baanen

! This file was ported from Lean 3 source module ring_theory.localization.submodule
! leanprover-community/mathlib commit 09597669f02422ed388036273d8848119699c22f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.Localization.FractionRing
import Mathbin.RingTheory.Localization.Ideal
import Mathbin.RingTheory.PrincipalIdealDomain

/-!
# Submodules in localizations of commutative rings

## Implementation notes

See `src/ring_theory/localization/basic.lean` for a design overview.

## Tags
localization, ring localization, commutative ring localization, characteristic predicate,
commutative ring, field of fractions
-/


variable {R : Type _} [CommRing R] (M : Submonoid R) (S : Type _) [CommRing S]

variable [Algebra R S] {P : Type _} [CommRing P]

namespace IsLocalization

-- This was previously a `has_coe` instance, but if `S = R` then this will loop.
-- It could be a `has_coe_t` instance, but we keep it explicit here to avoid slowing down
-- the rest of the library.
/-- Map from ideals of `R` to submodules of `S` induced by `f`. -/
def coeSubmodule (I : Ideal R) : Submodule R S :=
  Submodule.map (Algebra.linearMap R S) I
#align is_localization.coe_submodule IsLocalization.coeSubmodule

theorem mem_coe_submodule (I : Ideal R) {x : S} :
    x ∈ coeSubmodule S I ↔ ∃ y : R, y ∈ I ∧ algebraMap R S y = x :=
  Iff.rfl
#align is_localization.mem_coe_submodule IsLocalization.mem_coe_submodule

theorem coe_submodule_mono {I J : Ideal R} (h : I ≤ J) : coeSubmodule S I ≤ coeSubmodule S J :=
  Submodule.map_mono h
#align is_localization.coe_submodule_mono IsLocalization.coe_submodule_mono

@[simp]
theorem coe_submodule_bot : coeSubmodule S (⊥ : Ideal R) = ⊥ := by
  rw [coe_submodule, Submodule.map_bot]
#align is_localization.coe_submodule_bot IsLocalization.coe_submodule_bot

@[simp]
theorem coe_submodule_top : coeSubmodule S (⊤ : Ideal R) = 1 := by
  rw [coe_submodule, Submodule.map_top, Submodule.one_eq_range]
#align is_localization.coe_submodule_top IsLocalization.coe_submodule_top

@[simp]
theorem coe_submodule_sup (I J : Ideal R) :
    coeSubmodule S (I ⊔ J) = coeSubmodule S I ⊔ coeSubmodule S J :=
  Submodule.map_sup _ _ _
#align is_localization.coe_submodule_sup IsLocalization.coe_submodule_sup

@[simp]
theorem coe_submodule_mul (I J : Ideal R) :
    coeSubmodule S (I * J) = coeSubmodule S I * coeSubmodule S J :=
  Submodule.map_mul _ _ (Algebra.ofId R S)
#align is_localization.coe_submodule_mul IsLocalization.coe_submodule_mul

theorem coe_submodule_fg (hS : Function.Injective (algebraMap R S)) (I : Ideal R) :
    Submodule.Fg (coeSubmodule S I) ↔ Submodule.Fg I :=
  ⟨Submodule.fgOfFgMap _ (LinearMap.ker_eq_bot.mpr hS), Submodule.Fg.map _⟩
#align is_localization.coe_submodule_fg IsLocalization.coe_submodule_fg

@[simp]
theorem coe_submodule_span (s : Set R) :
    coeSubmodule S (Ideal.span s) = Submodule.span R (algebraMap R S '' s) :=
  by
  rw [IsLocalization.coeSubmodule, Ideal.span, Submodule.map_span]
  rfl
#align is_localization.coe_submodule_span IsLocalization.coe_submodule_span

@[simp]
theorem coe_submodule_span_singleton (x : R) :
    coeSubmodule S (Ideal.span {x}) = Submodule.span R {(algebraMap R S) x} := by
  rw [coe_submodule_span, Set.image_singleton]
#align is_localization.coe_submodule_span_singleton IsLocalization.coe_submodule_span_singleton

variable {g : R →+* P}

variable {T : Submonoid P} (hy : M ≤ T.comap g) {Q : Type _} [CommRing Q]

variable [Algebra P Q] [IsLocalization T Q]

variable [IsLocalization M S]

section

include M

theorem is_noetherian_ring (h : IsNoetherianRing R) : IsNoetherianRing S :=
  by
  rw [is_noetherian_ring_iff, is_noetherian_iff_well_founded] at h⊢
  exact OrderEmbedding.wellFounded (IsLocalization.orderEmbedding M S).dual h
#align is_localization.is_noetherian_ring IsLocalization.is_noetherian_ring

end

variable {S Q M}

@[mono]
theorem coe_submodule_le_coe_submodule (h : M ≤ nonZeroDivisors R) {I J : Ideal R} :
    coeSubmodule S I ≤ coeSubmodule S J ↔ I ≤ J :=
  Submodule.map_le_map_iff_of_injective (IsLocalization.injective _ h) _ _
#align is_localization.coe_submodule_le_coe_submodule IsLocalization.coe_submodule_le_coe_submodule

@[mono]
theorem coe_submodule_strict_mono (h : M ≤ nonZeroDivisors R) :
    StrictMono (coeSubmodule S : Ideal R → Submodule R S) :=
  strictMono_of_le_iff_le fun _ _ => (coe_submodule_le_coe_submodule h).symm
#align is_localization.coe_submodule_strict_mono IsLocalization.coe_submodule_strict_mono

variable (S) {Q M}

theorem coe_submodule_injective (h : M ≤ nonZeroDivisors R) :
    Function.Injective (coeSubmodule S : Ideal R → Submodule R S) :=
  injective_of_le_imp_le _ fun _ _ => (coe_submodule_le_coe_submodule h).mp
#align is_localization.coe_submodule_injective IsLocalization.coe_submodule_injective

theorem coe_submodule_is_principal {I : Ideal R} (h : M ≤ nonZeroDivisors R) :
    (coeSubmodule S I).IsPrincipal ↔ I.IsPrincipal :=
  by
  constructor <;> rintro ⟨⟨x, hx⟩⟩
  · have x_mem : x ∈ coe_submodule S I := hx.symm ▸ Submodule.mem_span_singleton_self x
    obtain ⟨x, x_mem, rfl⟩ := (mem_coe_submodule _ _).mp x_mem
    refine' ⟨⟨x, coe_submodule_injective S h _⟩⟩
    rw [Ideal.submodule_span_eq, hx, coe_submodule_span_singleton]
  · refine' ⟨⟨algebraMap R S x, _⟩⟩
    rw [hx, Ideal.submodule_span_eq, coe_submodule_span_singleton]
#align is_localization.coe_submodule_is_principal IsLocalization.coe_submodule_is_principal

variable {S} (M)

theorem mem_span_iff {N : Type _} [AddCommGroup N] [Module R N] [Module S N] [IsScalarTower R S N]
    {x : N} {a : Set N} :
    x ∈ Submodule.span S a ↔ ∃ y ∈ Submodule.span R a, ∃ z : M, x = mk' S 1 z • y :=
  by
  constructor; intro h
  · refine' Submodule.span_induction h _ _ _ _
    · rintro x hx
      exact ⟨x, Submodule.subset_span hx, 1, by rw [mk'_one, _root_.map_one, one_smul]⟩
    · exact ⟨0, Submodule.zero_mem _, 1, by rw [mk'_one, _root_.map_one, one_smul]⟩
    · rintro _ _ ⟨y, hy, z, rfl⟩ ⟨y', hy', z', rfl⟩
      refine'
        ⟨(z' : R) • y + (z : R) • y',
          Submodule.add_mem _ (Submodule.smul_mem _ _ hy) (Submodule.smul_mem _ _ hy'), z * z', _⟩
      rw [smul_add, ← IsScalarTower.algebra_map_smul S (z : R), ←
        IsScalarTower.algebra_map_smul S (z' : R), smul_smul, smul_smul]
      congr 1
      · rw [← mul_one (1 : R), mk'_mul, mul_assoc, mk'_spec, _root_.map_one, mul_one, mul_one]
      · rw [← mul_one (1 : R), mk'_mul, mul_right_comm, mk'_spec, _root_.map_one, mul_one, one_mul]
      all_goals infer_instance
    · rintro a _ ⟨y, hy, z, rfl⟩
      obtain ⟨y', z', rfl⟩ := mk'_surjective M a
      refine' ⟨y' • y, Submodule.smul_mem _ _ hy, z' * z, _⟩
      rw [← IsScalarTower.algebra_map_smul S y', smul_smul, ← mk'_mul, smul_smul,
        mul_comm (mk' S _ _), mul_mk'_eq_mk'_of_mul]
      all_goals infer_instance
  · rintro ⟨y, hy, z, rfl⟩
    exact Submodule.smul_mem _ _ (Submodule.span_subset_span R S _ hy)
#align is_localization.mem_span_iff IsLocalization.mem_span_iff

theorem mem_span_map {x : S} {a : Set R} :
    x ∈ Ideal.span (algebraMap R S '' a) ↔ ∃ y ∈ Ideal.span a, ∃ z : M, x = mk' S y z :=
  by
  refine' (mem_span_iff M).trans _
  constructor
  · rw [← coe_submodule_span]
    rintro ⟨_, ⟨y, hy, rfl⟩, z, hz⟩
    refine' ⟨y, hy, z, _⟩
    rw [hz, Algebra.linear_map_apply, smul_eq_mul, mul_comm, mul_mk'_eq_mk'_of_mul, mul_one]
  · rintro ⟨y, hy, z, hz⟩
    refine' ⟨algebraMap R S y, Submodule.map_mem_span_algebra_map_image _ _ hy, z, _⟩
    rw [hz, smul_eq_mul, mul_comm, mul_mk'_eq_mk'_of_mul, mul_one]
#align is_localization.mem_span_map IsLocalization.mem_span_map

end IsLocalization

namespace IsFractionRing

open IsLocalization

variable {R} {A K : Type _} [CommRing A]

section CommRing

variable [CommRing K] [Algebra R K] [IsFractionRing R K] [Algebra A K] [IsFractionRing A K]

@[simp, mono]
theorem coe_submodule_le_coe_submodule {I J : Ideal R} :
    coeSubmodule K I ≤ coeSubmodule K J ↔ I ≤ J :=
  IsLocalization.coe_submodule_le_coe_submodule le_rfl
#align is_fraction_ring.coe_submodule_le_coe_submodule IsFractionRing.coe_submodule_le_coe_submodule

@[mono]
theorem coe_submodule_strict_mono : StrictMono (coeSubmodule K : Ideal R → Submodule R K) :=
  strictMono_of_le_iff_le fun _ _ => coe_submodule_le_coe_submodule.symm
#align is_fraction_ring.coe_submodule_strict_mono IsFractionRing.coe_submodule_strict_mono

variable (R K)

theorem coe_submodule_injective : Function.Injective (coeSubmodule K : Ideal R → Submodule R K) :=
  injective_of_le_imp_le _ fun _ _ => coe_submodule_le_coe_submodule.mp
#align is_fraction_ring.coe_submodule_injective IsFractionRing.coe_submodule_injective

@[simp]
theorem coe_submodule_is_principal {I : Ideal R} : (coeSubmodule K I).IsPrincipal ↔ I.IsPrincipal :=
  IsLocalization.coe_submodule_is_principal _ le_rfl
#align is_fraction_ring.coe_submodule_is_principal IsFractionRing.coe_submodule_is_principal

end CommRing

end IsFractionRing

