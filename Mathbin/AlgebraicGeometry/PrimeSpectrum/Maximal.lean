/-
Copyright (c) 2022 David Kurniadi Angdinata. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: David Kurniadi Angdinata
-/
import Mathbin.AlgebraicGeometry.PrimeSpectrum.Basic
import Mathbin.RingTheory.Localization.AsSubring

/-!
# Maximal spectrum of a commutative ring

The maximal spectrum of a commutative ring is the type of all maximal ideals.
It is naturally a subset of the prime spectrum endowed with the subspace topology.

## Main definitions

* `maximal_spectrum R`: The maximal spectrum of a commutative ring `R`,
  i.e., the set of all maximal ideals of `R`.

## Implementation notes

The Zariski topology on the maximal spectrum is defined as the subspace topology induced by the
natural inclusion into the prime spectrum to avoid API duplication for zero loci.
-/


noncomputable section

open Classical

universe u v

variable (R : Type u) [CommRing R]

/-- The maximal spectrum of a commutative ring `R` is the type of all maximal ideals of `R`. -/
@[ext.1]
structure MaximalSpectrum where
  asIdeal : Ideal R
  IsMaximal : as_ideal.IsMaximal
#align maximal_spectrum MaximalSpectrum

attribute [instance] MaximalSpectrum.is_maximal

variable {R}

namespace MaximalSpectrum

instance [Nontrivial R] : Nonempty <| MaximalSpectrum R :=
  ⟨⟨(Ideal.exists_maximal R).some, (Ideal.exists_maximal R).some_spec⟩⟩

/-- The natural inclusion from the maximal spectrum to the prime spectrum. -/
def toPrimeSpectrum (x : MaximalSpectrum R) : PrimeSpectrum R :=
  ⟨x.asIdeal, x.IsMaximal.IsPrime⟩
#align maximal_spectrum.to_prime_spectrum MaximalSpectrum.toPrimeSpectrum

theorem to_prime_spectrum_injective : (@toPrimeSpectrum R _).Injective := fun ⟨_, _⟩ ⟨_, _⟩ h => by
  simpa only [MaximalSpectrum.mk.inj_eq] using Subtype.mk.inj h
#align maximal_spectrum.to_prime_spectrum_injective MaximalSpectrum.to_prime_spectrum_injective

open PrimeSpectrum Set

theorem to_prime_spectrum_range : Set.range (@toPrimeSpectrum R _) = { x | IsClosed ({x} : Set <| PrimeSpectrum R) } :=
  by
  simp only [is_closed_singleton_iff_is_maximal]
  ext ⟨x, _⟩
  exact ⟨fun ⟨y, hy⟩ => hy ▸ y.IsMaximal, fun hx => ⟨⟨x, hx⟩, rfl⟩⟩
#align maximal_spectrum.to_prime_spectrum_range MaximalSpectrum.to_prime_spectrum_range

/-- The Zariski topology on the maximal spectrum of a commutative ring is defined as the subspace
topology induced by the natural inclusion into the prime spectrum. -/
instance zariskiTopology : TopologicalSpace <| MaximalSpectrum R :=
  PrimeSpectrum.zariskiTopology.induced toPrimeSpectrum
#align maximal_spectrum.zariski_topology MaximalSpectrum.zariskiTopology

instance : T1Space <| MaximalSpectrum R :=
  ⟨fun x =>
    is_closed_induced_iff.mpr
      ⟨{toPrimeSpectrum x}, (is_closed_singleton_iff_is_maximal _).mpr x.IsMaximal, by
        simpa only [← image_singleton] using preimage_image_eq {x} to_prime_spectrum_injective⟩⟩

theorem to_prime_spectrum_continuous : Continuous <| @toPrimeSpectrum R _ :=
  continuous_induced_dom
#align maximal_spectrum.to_prime_spectrum_continuous MaximalSpectrum.to_prime_spectrum_continuous

variable (R) [IsDomain R] (K : Type v) [Field K] [Algebra R K] [IsFractionRing R K]

/-- An integral domain is equal to the intersection of its localizations at all its maximal ideals
viewed as subalgebras of its field of fractions. -/
theorem infi_localization_eq_bot :
    (⨅ v : MaximalSpectrum R, Localization.subalgebra.ofField K _ v.asIdeal.prime_compl_le_non_zero_divisors) = ⊥ := by
  ext x
  rw [Algebra.mem_bot, Algebra.mem_infi]
  constructor
  · apply imp_of_not_imp_not
    intro hrange hlocal
    let denom : Ideal R := (Submodule.span R {1} : Submodule R K).colon (Submodule.span R {x})
    have hdenom : (1 : R) ∉ denom := by
      intro hdenom
      rcases submodule.mem_span_singleton.mp
          (submodule.mem_colon.mp hdenom x <| Submodule.mem_span_singleton_self x) with
        ⟨y, hy⟩
      exact hrange ⟨y, by rw [← mul_one <| algebraMap R K y, ← Algebra.smul_def, hy, one_smul]⟩
    rcases denom.exists_le_maximal fun h => (h ▸ hdenom) Submodule.mem_top with ⟨max, hmax, hle⟩
    rcases hlocal ⟨max, hmax⟩ with ⟨n, d, hd, rfl⟩
    apply hd (hle <| submodule.mem_colon.mpr fun _ hy => _)
    rcases submodule.mem_span_singleton.mp hy with ⟨y, rfl⟩
    exact
      submodule.mem_span_singleton.mpr
        ⟨y * n, by
          rw [Algebra.smul_def, mul_one, map_mul, smul_comm, Algebra.smul_def, Algebra.smul_def,
            mul_comm <| algebraMap R K d,
            inv_mul_cancel_right₀ <|
              (map_ne_zero_iff _ <| NoZeroSmulDivisors.algebra_map_injective R K).mpr fun h => (h ▸ hd) max.zero_mem]⟩
    
  · rintro ⟨y, rfl⟩ ⟨v, hv⟩
    exact ⟨y, 1, v.ne_top_iff_one.mp hv.ne_top, by rw [map_one, inv_one, mul_one]⟩
    
#align maximal_spectrum.infi_localization_eq_bot MaximalSpectrum.infi_localization_eq_bot

end MaximalSpectrum

namespace PrimeSpectrum

variable (R) [IsDomain R] (K : Type v) [Field K] [Algebra R K] [IsFractionRing R K]

/-- An integral domain is equal to the intersection of its localizations at all its prime ideals
viewed as subalgebras of its field of fractions. -/
theorem infi_localization_eq_bot :
    (⨅ v : PrimeSpectrum R, Localization.subalgebra.ofField K _ <| v.asIdeal.prime_compl_le_non_zero_divisors) = ⊥ := by
  ext x
  rw [Algebra.mem_infi]
  constructor
  · rw [← MaximalSpectrum.infi_localization_eq_bot, Algebra.mem_infi]
    exact fun hx ⟨v, hv⟩ => hx ⟨v, hv.IsPrime⟩
    
  · rw [Algebra.mem_bot]
    rintro ⟨y, rfl⟩ ⟨v, hv⟩
    exact ⟨y, 1, v.ne_top_iff_one.mp hv.ne_top, by rw [map_one, inv_one, mul_one]⟩
    
#align prime_spectrum.infi_localization_eq_bot PrimeSpectrum.infi_localization_eq_bot

end PrimeSpectrum

