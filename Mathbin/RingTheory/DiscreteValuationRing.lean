/-
Copyright (c) 2020 Kevin Buzzard. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kevin Buzzard

! This file was ported from Lean 3 source module ring_theory.discrete_valuation_ring
! leanprover-community/mathlib commit d012cd09a9b256d870751284dd6a29882b0be105
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.PrincipalIdealDomain
import Mathbin.RingTheory.Ideal.LocalRing
import Mathbin.RingTheory.Multiplicity
import Mathbin.RingTheory.Valuation.Basic
import Mathbin.LinearAlgebra.AdicCompletion

/-!
# Discrete valuation rings

This file defines discrete valuation rings (DVRs) and develops a basic interface
for them.

## Important definitions

There are various definitions of a DVR in the literature; we define a DVR to be a local PID
which is not a field (the first definition in Wikipedia) and prove that this is equivalent
to being a PID with a unique non-zero prime ideal (the definition in Serre's
book "Local Fields").

Let R be an integral domain, assumed to be a principal ideal ring and a local ring.

* `discrete_valuation_ring R` : a predicate expressing that R is a DVR

### Definitions

* `add_val R : add_valuation R part_enat` : the additive valuation on a DVR.

## Implementation notes

It's a theorem that an element of a DVR is a uniformizer if and only if it's irreducible.
We do not hence define `uniformizer` at all, because we can use `irreducible` instead.

## Tags

discrete valuation ring
-/


open Classical

universe u

open Ideal LocalRing

/-- An integral domain is a *discrete valuation ring* (DVR) if it's a local PID which
  is not a field. -/
class DiscreteValuationRing (R : Type u) [CommRing R] [IsDomain R] extends IsPrincipalIdealRing R,
  LocalRing R : Prop where
  not_a_field' : maximalIdeal R ≠ ⊥
#align discrete_valuation_ring DiscreteValuationRing

namespace DiscreteValuationRing

variable (R : Type u) [CommRing R] [IsDomain R] [DiscreteValuationRing R]

theorem not_a_field : maximalIdeal R ≠ ⊥ :=
  not_a_field'
#align discrete_valuation_ring.not_a_field DiscreteValuationRing.not_a_field

/-- A discrete valuation ring `R` is not a field. -/
theorem not_is_field : ¬IsField R :=
  Ring.not_is_field_iff_exists_prime.mpr ⟨_, not_a_field R, IsMaximal.is_prime' (maximalIdeal R)⟩
#align discrete_valuation_ring.not_is_field DiscreteValuationRing.not_is_field

variable {R}

open PrincipalIdealRing

theorem irreducible_of_span_eq_maximal_ideal {R : Type _} [CommRing R] [LocalRing R] [IsDomain R]
    (ϖ : R) (hϖ : ϖ ≠ 0) (h : maximalIdeal R = Ideal.span {ϖ}) : Irreducible ϖ := by
  have h2 : ¬IsUnit ϖ := show ϖ ∈ maximal_ideal R from h.symm ▸ Submodule.mem_span_singleton_self ϖ
  refine' ⟨h2, _⟩
  intro a b hab
  by_contra' h
  obtain ⟨ha : a ∈ maximal_ideal R, hb : b ∈ maximal_ideal R⟩ := h
  rw [h, mem_span_singleton'] at ha hb
  rcases ha with ⟨a, rfl⟩
  rcases hb with ⟨b, rfl⟩
  rw [show a * ϖ * (b * ϖ) = ϖ * (ϖ * (a * b)) by ring] at hab
  apply hϖ
  apply eq_zero_of_mul_eq_self_right _ hab.symm
  exact fun hh => h2 (isUnit_of_dvd_one ϖ ⟨_, hh.symm⟩)
#align
  discrete_valuation_ring.irreducible_of_span_eq_maximal_ideal DiscreteValuationRing.irreducible_of_span_eq_maximal_ideal

/-- An element of a DVR is irreducible iff it is a uniformizer, that is, generates the
  maximal ideal of R -/
theorem irreducible_iff_uniformizer (ϖ : R) : Irreducible ϖ ↔ maximalIdeal R = Ideal.span {ϖ} :=
  ⟨fun hϖ => (eq_maximal_ideal (is_maximal_of_irreducible hϖ)).symm, fun h =>
    irreducible_of_span_eq_maximal_ideal ϖ
      (fun e => not_a_field R <| by rwa [h, span_singleton_eq_bot]) h⟩
#align
  discrete_valuation_ring.irreducible_iff_uniformizer DiscreteValuationRing.irreducible_iff_uniformizer

theorem Irreducible.maximal_ideal_eq {ϖ : R} (h : Irreducible ϖ) :
    maximalIdeal R = Ideal.span {ϖ} :=
  (irreducible_iff_uniformizer _).mp h
#align irreducible.maximal_ideal_eq Irreducible.maximal_ideal_eq

variable (R)

/-- Uniformisers exist in a DVR -/
theorem exists_irreducible : ∃ ϖ : R, Irreducible ϖ := by
  simp_rw [irreducible_iff_uniformizer]
  exact (IsPrincipalIdealRing.principal <| maximal_ideal R).principal
#align discrete_valuation_ring.exists_irreducible DiscreteValuationRing.exists_irreducible

/-- Uniformisers exist in a DVR -/
theorem exists_prime : ∃ ϖ : R, Prime ϖ :=
  (exists_irreducible R).imp fun _ => PrincipalIdealRing.irreducible_iff_prime.1
#align discrete_valuation_ring.exists_prime DiscreteValuationRing.exists_prime

/-- an integral domain is a DVR iff it's a PID with a unique non-zero prime ideal -/
theorem iff_pid_with_one_nonzero_prime (R : Type u) [CommRing R] [IsDomain R] :
    DiscreteValuationRing R ↔ IsPrincipalIdealRing R ∧ ∃! P : Ideal R, P ≠ ⊥ ∧ IsPrime P := by
  constructor
  · intro RDVR
    rcases id RDVR with ⟨Rlocal⟩
    constructor
    assumption
    skip
    use LocalRing.maximalIdeal R
    constructor
    constructor
    · assumption
    · infer_instance
    · rintro Q ⟨hQ1, hQ2⟩
      obtain ⟨q, rfl⟩ := (IsPrincipalIdealRing.principal Q).1
      have hq : q ≠ 0 := by 
        rintro rfl
        apply hQ1
        simp
      erw [span_singleton_prime hq] at hQ2
      replace hQ2 := hQ2.irreducible
      rw [irreducible_iff_uniformizer] at hQ2
      exact hQ2.symm
  · rintro ⟨RPID, Punique⟩
    haveI : LocalRing R := LocalRing.of_unique_nonzero_prime Punique
    refine' { not_a_field' := _ }
    rcases Punique with ⟨P, ⟨hP1, hP2⟩, hP3⟩
    have hPM : P ≤ maximal_ideal R := le_maximal_ideal hP2.1
    intro h
    rw [h, le_bot_iff] at hPM
    exact hP1 hPM
#align
  discrete_valuation_ring.iff_pid_with_one_nonzero_prime DiscreteValuationRing.iff_pid_with_one_nonzero_prime

theorem associated_of_irreducible {a b : R} (ha : Irreducible a) (hb : Irreducible b) :
    Associated a b := by 
  rw [irreducible_iff_uniformizer] at ha hb
  rw [← span_singleton_eq_span_singleton, ← ha, hb]
#align
  discrete_valuation_ring.associated_of_irreducible DiscreteValuationRing.associated_of_irreducible

end DiscreteValuationRing

namespace DiscreteValuationRing

variable (R : Type _)

/-- Alternative characterisation of discrete valuation rings. -/
def HasUnitMulPowIrreducibleFactorization [CommRing R] : Prop :=
  ∃ p : R, Irreducible p ∧ ∀ {x : R}, x ≠ 0 → ∃ n : ℕ, Associated (p ^ n) x
#align
  discrete_valuation_ring.has_unit_mul_pow_irreducible_factorization DiscreteValuationRing.HasUnitMulPowIrreducibleFactorization

namespace HasUnitMulPowIrreducibleFactorization

variable {R} [CommRing R] (hR : HasUnitMulPowIrreducibleFactorization R)

include hR

theorem unique_irreducible ⦃p q : R⦄ (hp : Irreducible p) (hq : Irreducible q) : Associated p q :=
  by 
  rcases hR with ⟨ϖ, hϖ, hR⟩
  suffices ∀ {p : R} (hp : Irreducible p), Associated p ϖ by
    apply Associated.trans (this hp) (this hq).symm
  clear hp hq p q
  intro p hp
  obtain ⟨n, hn⟩ := hR hp.ne_zero
  have : Irreducible (ϖ ^ n) := hn.symm.irreducible hp
  rcases lt_trichotomy n 1 with (H | rfl | H)
  · obtain rfl : n = 0 := by 
      clear hn this
      revert H n
      exact by decide
    simpa only [not_irreducible_one, pow_zero] using this
  · simpa only [pow_one] using hn.symm
  · obtain ⟨n, rfl⟩ : ∃ k, n = 1 + k + 1 := Nat.exists_eq_add_of_lt H
    rw [pow_succ] at this
    rcases this.is_unit_or_is_unit rfl with (H0 | H0)
    · exact (hϖ.not_unit H0).elim
    · rw [add_comm, pow_succ] at H0
      exact (hϖ.not_unit (isUnit_of_mul_isUnit_left H0)).elim
#align
  discrete_valuation_ring.has_unit_mul_pow_irreducible_factorization.unique_irreducible DiscreteValuationRing.HasUnitMulPowIrreducibleFactorization.unique_irreducible

variable [IsDomain R]

/-- An integral domain in which there is an irreducible element `p`
such that every nonzero element is associated to a power of `p` is a unique factorization domain.
See `discrete_valuation_ring.of_has_unit_mul_pow_irreducible_factorization`. -/
theorem to_unique_factorization_monoid : UniqueFactorizationMonoid R :=
  let p := Classical.choose hR
  let spec := Classical.choose_spec hR
  UniqueFactorizationMonoid.of_exists_prime_factors fun x hx => by
    use Multiset.repeat p (Classical.choose (spec.2 hx))
    constructor
    · intro q hq
      have hpq := Multiset.eq_of_mem_repeat hq
      rw [hpq]
      refine' ⟨spec.1.NeZero, spec.1.not_unit, _⟩
      intro a b h
      by_cases ha : a = 0
      · rw [ha]
        simp only [true_or_iff, dvd_zero]
      obtain ⟨m, u, rfl⟩ := spec.2 ha
      rw [mul_assoc, mul_left_comm, IsUnit.dvd_mul_left _ _ _ (Units.isUnit _)] at h
      rw [IsUnit.dvd_mul_right (Units.isUnit _)]
      by_cases hm : m = 0
      · simp only [hm, one_mul, pow_zero] at h⊢
        right
        exact h
      left
      obtain ⟨m, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hm
      rw [pow_succ]
      apply dvd_mul_of_dvd_left dvd_rfl _
    · rw [Multiset.prod_repeat]
      exact Classical.choose_spec (spec.2 hx)
#align
  discrete_valuation_ring.has_unit_mul_pow_irreducible_factorization.to_unique_factorization_monoid DiscreteValuationRing.HasUnitMulPowIrreducibleFactorization.to_unique_factorization_monoid

omit hR

theorem of_ufd_of_unique_irreducible [UniqueFactorizationMonoid R] (h₁ : ∃ p : R, Irreducible p)
    (h₂ : ∀ ⦃p q : R⦄, Irreducible p → Irreducible q → Associated p q) :
    HasUnitMulPowIrreducibleFactorization R := by
  obtain ⟨p, hp⟩ := h₁
  refine' ⟨p, hp, _⟩
  intro x hx
  cases' WfDvdMonoid.exists_factors x hx with fx hfx
  refine' ⟨fx.card, _⟩
  have H := hfx.2
  rw [← Associates.mk_eq_mk_iff_associated] at H⊢
  rw [← H, ← Associates.prod_mk, Associates.mk_pow, ← Multiset.prod_repeat]
  congr 1
  symm
  rw [Multiset.eq_repeat]
  simp only [true_and_iff, and_imp, Multiset.card_map, eq_self_iff_true, Multiset.mem_map,
    exists_imp]
  rintro _ q hq rfl
  rw [Associates.mk_eq_mk_iff_associated]
  apply h₂ (hfx.1 _ hq) hp
#align
  discrete_valuation_ring.has_unit_mul_pow_irreducible_factorization.of_ufd_of_unique_irreducible DiscreteValuationRing.HasUnitMulPowIrreducibleFactorization.of_ufd_of_unique_irreducible

end HasUnitMulPowIrreducibleFactorization

theorem aux_pid_of_ufd_of_unique_irreducible (R : Type u) [CommRing R] [IsDomain R]
    [UniqueFactorizationMonoid R] (h₁ : ∃ p : R, Irreducible p)
    (h₂ : ∀ ⦃p q : R⦄, Irreducible p → Irreducible q → Associated p q) : IsPrincipalIdealRing R :=
  by 
  constructor
  intro I
  by_cases I0 : I = ⊥
  · rw [I0]
    use 0
    simp only [Set.singleton_zero, Submodule.span_zero]
  obtain ⟨x, hxI, hx0⟩ : ∃ x ∈ I, x ≠ (0 : R) := I.ne_bot_iff.mp I0
  obtain ⟨p, hp, H⟩ := has_unit_mul_pow_irreducible_factorization.of_ufd_of_unique_irreducible h₁ h₂
  have ex : ∃ n : ℕ, p ^ n ∈ I := by 
    obtain ⟨n, u, rfl⟩ := H hx0
    refine' ⟨n, _⟩
    simpa only [Units.mul_inv_cancel_right] using I.mul_mem_right (↑u⁻¹) hxI
  constructor
  use p ^ Nat.find ex
  show I = Ideal.span _
  apply le_antisymm
  · intro r hr
    by_cases hr0 : r = 0
    · simp only [hr0, Submodule.zero_mem]
    obtain ⟨n, u, rfl⟩ := H hr0
    simp only [mem_span_singleton, Units.isUnit, IsUnit.dvd_mul_right]
    apply pow_dvd_pow
    apply Nat.find_min'
    simpa only [Units.mul_inv_cancel_right] using I.mul_mem_right (↑u⁻¹) hr
  · erw [Submodule.span_singleton_le_iff_mem]
    exact Nat.find_spec ex
#align
  discrete_valuation_ring.aux_pid_of_ufd_of_unique_irreducible DiscreteValuationRing.aux_pid_of_ufd_of_unique_irreducible

/-- A unique factorization domain with at least one irreducible element
in which all irreducible elements are associated
is a discrete valuation ring.
-/
theorem of_ufd_of_unique_irreducible {R : Type u} [CommRing R] [IsDomain R]
    [UniqueFactorizationMonoid R] (h₁ : ∃ p : R, Irreducible p)
    (h₂ : ∀ ⦃p q : R⦄, Irreducible p → Irreducible q → Associated p q) : DiscreteValuationRing R :=
  by 
  rw [iff_pid_with_one_nonzero_prime]
  haveI PID : IsPrincipalIdealRing R := aux_pid_of_ufd_of_unique_irreducible R h₁ h₂
  obtain ⟨p, hp⟩ := h₁
  refine' ⟨PID, ⟨Ideal.span {p}, ⟨_, _⟩, _⟩⟩
  · rw [Submodule.ne_bot_iff]
    refine' ⟨p, ideal.mem_span_singleton.mpr (dvd_refl p), hp.ne_zero⟩
  · rwa [Ideal.span_singleton_prime hp.ne_zero, ← UniqueFactorizationMonoid.irreducible_iff_prime]
  · intro I
    rw [← Submodule.IsPrincipal.span_singleton_generator I]
    rintro ⟨I0, hI⟩
    apply span_singleton_eq_span_singleton.mpr
    apply h₂ _ hp
    erw [Ne.def, span_singleton_eq_bot] at I0
    rwa [UniqueFactorizationMonoid.irreducible_iff_prime, ← Ideal.span_singleton_prime I0]
    infer_instance
#align
  discrete_valuation_ring.of_ufd_of_unique_irreducible DiscreteValuationRing.of_ufd_of_unique_irreducible

/-- An integral domain in which there is an irreducible element `p`
such that every nonzero element is associated to a power of `p`
is a discrete valuation ring.
-/
theorem of_has_unit_mul_pow_irreducible_factorization {R : Type u} [CommRing R] [IsDomain R]
    (hR : HasUnitMulPowIrreducibleFactorization R) : DiscreteValuationRing R := by
  letI : UniqueFactorizationMonoid R := hR.to_unique_factorization_monoid
  apply of_ufd_of_unique_irreducible _ hR.unique_irreducible
  obtain ⟨p, hp, H⟩ := hR
  exact ⟨p, hp⟩
#align
  discrete_valuation_ring.of_has_unit_mul_pow_irreducible_factorization DiscreteValuationRing.of_has_unit_mul_pow_irreducible_factorization

section

variable [CommRing R] [IsDomain R] [DiscreteValuationRing R]

variable {R}

theorem associated_pow_irreducible {x : R} (hx : x ≠ 0) {ϖ : R} (hirr : Irreducible ϖ) :
    ∃ n : ℕ, Associated x (ϖ ^ n) := by
  have : WfDvdMonoid R := IsNoetherianRing.wf_dvd_monoid
  cases' WfDvdMonoid.exists_factors x hx with fx hfx
  use fx.card
  have H := hfx.2
  rw [← Associates.mk_eq_mk_iff_associated] at H⊢
  rw [← H, ← Associates.prod_mk, Associates.mk_pow, ← Multiset.prod_repeat]
  congr 1
  rw [Multiset.eq_repeat]
  simp only [true_and_iff, and_imp, Multiset.card_map, eq_self_iff_true, Multiset.mem_map,
    exists_imp]
  rintro _ _ _ rfl
  rw [Associates.mk_eq_mk_iff_associated]
  refine' associated_of_irreducible _ _ hirr
  apply hfx.1
  assumption
#align
  discrete_valuation_ring.associated_pow_irreducible DiscreteValuationRing.associated_pow_irreducible

theorem eq_unit_mul_pow_irreducible {x : R} (hx : x ≠ 0) {ϖ : R} (hirr : Irreducible ϖ) :
    ∃ (n : ℕ)(u : Rˣ), x = u * ϖ ^ n := by
  obtain ⟨n, hn⟩ := associated_pow_irreducible hx hirr
  obtain ⟨u, rfl⟩ := hn.symm
  use n, u
  apply mul_comm
#align
  discrete_valuation_ring.eq_unit_mul_pow_irreducible DiscreteValuationRing.eq_unit_mul_pow_irreducible

open Submodule.IsPrincipal

theorem ideal_eq_span_pow_irreducible {s : Ideal R} (hs : s ≠ ⊥) {ϖ : R} (hirr : Irreducible ϖ) :
    ∃ n : ℕ, s = Ideal.span {ϖ ^ n} := by
  have gen_ne_zero : generator s ≠ 0 := by
    rw [Ne.def, ← eq_bot_iff_generator_eq_zero]
    assumption
  rcases associated_pow_irreducible gen_ne_zero hirr with ⟨n, u, hnu⟩
  use n
  have : span _ = _ := span_singleton_generator s
  rw [← this, ← hnu, span_singleton_eq_span_singleton]
  use u
#align
  discrete_valuation_ring.ideal_eq_span_pow_irreducible DiscreteValuationRing.ideal_eq_span_pow_irreducible

theorem unit_mul_pow_congr_pow {p q : R} (hp : Irreducible p) (hq : Irreducible q) (u v : Rˣ)
    (m n : ℕ) (h : ↑u * p ^ m = v * q ^ n) : m = n := by
  have key : Associated (Multiset.repeat p m).Prod (Multiset.repeat q n).Prod := by
    rw [Multiset.prod_repeat, Multiset.prod_repeat, Associated]
    refine' ⟨u * v⁻¹, _⟩
    simp only [Units.val_mul]
    rw [mul_left_comm, ← mul_assoc, h, mul_right_comm, Units.mul_inv, one_mul]
  have := Multiset.card_eq_card_of_rel (UniqueFactorizationMonoid.factors_unique _ _ key)
  · simpa only [Multiset.card_repeat]
  all_goals 
    intro x hx
    obtain rfl := Multiset.eq_of_mem_repeat hx
    assumption
#align discrete_valuation_ring.unit_mul_pow_congr_pow DiscreteValuationRing.unit_mul_pow_congr_pow

theorem unit_mul_pow_congr_unit {ϖ : R} (hirr : Irreducible ϖ) (u v : Rˣ) (m n : ℕ)
    (h : ↑u * ϖ ^ m = v * ϖ ^ n) : u = v := by
  obtain rfl : m = n := unit_mul_pow_congr_pow hirr hirr u v m n h
  rw [← sub_eq_zero] at h
  rw [← sub_mul, mul_eq_zero] at h
  cases h
  · rw [sub_eq_zero] at h
    exact_mod_cast h
  · apply (hirr.ne_zero (pow_eq_zero h)).elim
#align discrete_valuation_ring.unit_mul_pow_congr_unit DiscreteValuationRing.unit_mul_pow_congr_unit

/-!
## The additive valuation on a DVR
-/


open multiplicity

/-- The `part_enat`-valued additive valuation on a DVR -/
noncomputable def addVal (R : Type u) [CommRing R] [IsDomain R] [DiscreteValuationRing R] :
    AddValuation R PartEnat :=
  AddValuation (Classical.choose_spec (exists_prime R))
#align discrete_valuation_ring.add_val DiscreteValuationRing.addVal

theorem add_val_def (r : R) (u : Rˣ) {ϖ : R} (hϖ : Irreducible ϖ) (n : ℕ) (hr : r = u * ϖ ^ n) :
    addVal R r = n := by
  rw [add_val, add_valuation_apply, hr,
    eq_of_associated_left
      (associated_of_irreducible R hϖ (Classical.choose_spec (exists_prime R)).Irreducible),
    eq_of_associated_right (Associated.symm ⟨u, mul_comm _ _⟩),
    multiplicity_pow_self_of_prime (PrincipalIdealRing.irreducible_iff_prime.1 hϖ)]
#align discrete_valuation_ring.add_val_def DiscreteValuationRing.add_val_def

theorem add_val_def' (u : Rˣ) {ϖ : R} (hϖ : Irreducible ϖ) (n : ℕ) :
    addVal R ((u : R) * ϖ ^ n) = n :=
  add_val_def _ u hϖ n rfl
#align discrete_valuation_ring.add_val_def' DiscreteValuationRing.add_val_def'

@[simp]
theorem add_val_zero : addVal R 0 = ⊤ :=
  (addVal R).map_zero
#align discrete_valuation_ring.add_val_zero DiscreteValuationRing.add_val_zero

@[simp]
theorem add_val_one : addVal R 1 = 0 :=
  (addVal R).map_one
#align discrete_valuation_ring.add_val_one DiscreteValuationRing.add_val_one

@[simp]
theorem add_val_uniformizer {ϖ : R} (hϖ : Irreducible ϖ) : addVal R ϖ = 1 := by
  simpa only [one_mul, eq_self_iff_true, Units.val_one, pow_one, forall_true_left,
    Nat.cast_one] using add_val_def ϖ 1 hϖ 1
#align discrete_valuation_ring.add_val_uniformizer DiscreteValuationRing.add_val_uniformizer

@[simp]
theorem add_val_mul {a b : R} : addVal R (a * b) = addVal R a + addVal R b :=
  (addVal R).map_mul _ _
#align discrete_valuation_ring.add_val_mul DiscreteValuationRing.add_val_mul

theorem add_val_pow (a : R) (n : ℕ) : addVal R (a ^ n) = n • addVal R a :=
  (addVal R).map_pow _ _
#align discrete_valuation_ring.add_val_pow DiscreteValuationRing.add_val_pow

theorem Irreducible.add_val_pow {ϖ : R} (h : Irreducible ϖ) (n : ℕ) : addVal R (ϖ ^ n) = n := by
  rw [add_val_pow, add_val_uniformizer h, nsmul_one]
#align irreducible.add_val_pow Irreducible.add_val_pow

theorem add_val_eq_top_iff {a : R} : addVal R a = ⊤ ↔ a = 0 := by
  have hi := (Classical.choose_spec (exists_prime R)).Irreducible
  constructor
  · contrapose
    intro h
    obtain ⟨n, ha⟩ := associated_pow_irreducible h hi
    obtain ⟨u, rfl⟩ := ha.symm
    rw [mul_comm, add_val_def' u hi n]
    exact PartEnat.coe_ne_top _
  · rintro rfl
    exact add_val_zero
#align discrete_valuation_ring.add_val_eq_top_iff DiscreteValuationRing.add_val_eq_top_iff

theorem add_val_le_iff_dvd {a b : R} : addVal R a ≤ addVal R b ↔ a ∣ b := by
  have hp := Classical.choose_spec (exists_prime R)
  constructor <;> intro h
  · by_cases ha0 : a = 0
    · rw [ha0, add_val_zero, top_le_iff, add_val_eq_top_iff] at h
      rw [h]
      apply dvd_zero
    obtain ⟨n, ha⟩ := associated_pow_irreducible ha0 hp.irreducible
    rw [add_val, add_valuation_apply, add_valuation_apply, multiplicity_le_multiplicity_iff] at h
    exact ha.dvd.trans (h n ha.symm.dvd)
  · rw [add_val, add_valuation_apply, add_valuation_apply]
    exact multiplicity_le_multiplicity_of_dvd_right h
#align discrete_valuation_ring.add_val_le_iff_dvd DiscreteValuationRing.add_val_le_iff_dvd

theorem add_val_add {a b : R} : min (addVal R a) (addVal R b) ≤ addVal R (a + b) :=
  (addVal R).map_add _ _
#align discrete_valuation_ring.add_val_add DiscreteValuationRing.add_val_add

end

instance (R : Type _) [CommRing R] [IsDomain R] [DiscreteValuationRing R] :
    IsHausdorff (maximalIdeal R)
      R where haus' x hx := by 
    obtain ⟨ϖ, hϖ⟩ := exists_irreducible R
    simp only [← Ideal.one_eq_top, smul_eq_mul, mul_one, Smodeq.zero, hϖ.maximal_ideal_eq,
      Ideal.span_singleton_pow, Ideal.mem_span_singleton, ← add_val_le_iff_dvd, hϖ.add_val_pow] at
      hx
    rwa [← add_val_eq_top_iff, PartEnat.eq_top_iff_forall_le]

end DiscreteValuationRing

