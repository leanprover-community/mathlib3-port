/-
Copyright (c) 2020 Riccardo Brasca. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Riccardo Brasca
-/
import Mathbin.Data.Polynomial.AlgebraMap
import Mathbin.Data.Polynomial.Monic

/-!
# Polynomials that lift

Given semirings `R` and `S` with a morphism `f : R →+* S`, we define a subsemiring `lifts` of
`polynomial S` by the image of `ring_hom.of (map f)`.
Then, we prove that a polynomial that lifts can always be lifted to a polynomial of the same degree
and that a monic polynomial that lifts can be lifted to a monic polynomial (of the same degree).

## Main definition

* `lifts (f : R →+* S)` : the subsemiring of polynomials that lift.

## Main results

* `lifts_and_degree_eq` : A polynomial lifts if and only if it can be lifted to a polynomial
of the same degree.
* `lifts_and_degree_eq_and_monic` : A monic polynomial lifts if and only if it can be lifted to a
monic polynomial of the same degree.
* `lifts_iff_alg` : if `R` is commutative, a polynomial lifts if and only if it is in the image of
`map_alg`, where `map_alg : R[X] →ₐ[R] S[X]` is the only `R`-algebra map
that sends `X` to `X`.

## Implementation details

In general `R` and `S` are semiring, so `lifts` is a semiring. In the case of rings, see
`lifts_iff_lifts_ring`.

Since we do not assume `R` to be commutative, we cannot say in general that the set of polynomials
that lift is a subalgebra. (By `lift_iff` this is true if `R` is commutative.)

-/


open Classical BigOperators Polynomial

noncomputable section

namespace Polynomial

universe u v w

section Semiringₓ

variable {R : Type u} [Semiringₓ R] {S : Type v} [Semiringₓ S] {f : R →+* S}

/-- We define the subsemiring of polynomials that lifts as the image of `ring_hom.of (map f)`. -/
def lifts (f : R →+* S) : Subsemiring S[X] :=
  RingHom.srange (mapRingHom f)

theorem mem_lifts (p : S[X]) : p ∈ lifts f ↔ ∃ q : R[X], map f q = p := by
  simp only [← coe_map_ring_hom, ← lifts, ← RingHom.mem_srange]

theorem lifts_iff_set_range (p : S[X]) : p ∈ lifts f ↔ p ∈ Set.Range (map f) := by
  simp only [← coe_map_ring_hom, ← lifts, ← Set.mem_range, ← RingHom.mem_srange]

theorem lifts_iff_ring_hom_srange (p : S[X]) : p ∈ lifts f ↔ p ∈ (mapRingHom f).srange := by
  simp only [← coe_map_ring_hom, ← lifts, ← Set.mem_range, ← RingHom.mem_srange]

theorem lifts_iff_coeff_lifts (p : S[X]) : p ∈ lifts f ↔ ∀ n : ℕ, p.coeff n ∈ Set.Range f := by
  rw [lifts_iff_ring_hom_srange, mem_map_srange f]
  rfl

/-- If `(r : R)`, then `C (f r)` lifts. -/
theorem C_mem_lifts (f : R →+* S) (r : R) : c (f r) ∈ lifts f :=
  ⟨c r, by
    simp only [← coe_map_ring_hom, ← map_C, ← Set.mem_univ, ← Subsemiring.coe_top, ← eq_self_iff_true, ← and_selfₓ]⟩

/-- If `(s : S)` is in the image of `f`, then `C s` lifts. -/
theorem C'_mem_lifts {f : R →+* S} {s : S} (h : s ∈ Set.Range f) : c s ∈ lifts f := by
  obtain ⟨r, rfl⟩ := Set.mem_range.1 h
  use C r
  simp only [← coe_map_ring_hom, ← map_C, ← Set.mem_univ, ← Subsemiring.coe_top, ← eq_self_iff_true, ← and_selfₓ]

/-- The polynomial `X` lifts. -/
theorem X_mem_lifts (f : R →+* S) : (x : S[X]) ∈ lifts f :=
  ⟨x, by
    simp only [← coe_map_ring_hom, ← Set.mem_univ, ← Subsemiring.coe_top, ← eq_self_iff_true, ← map_X, ← and_selfₓ]⟩

/-- The polynomial `X ^ n` lifts. -/
theorem X_pow_mem_lifts (f : R →+* S) (n : ℕ) : (X ^ n : S[X]) ∈ lifts f :=
  ⟨X ^ n, by
    simp only [← coe_map_ring_hom, ← map_pow, ← Set.mem_univ, ← Subsemiring.coe_top, ← eq_self_iff_true, ← map_X, ←
      and_selfₓ]⟩

/-- If `p` lifts and `(r : R)` then `r * p` lifts. -/
theorem base_mul_mem_lifts {p : S[X]} (r : R) (hp : p ∈ lifts f) : c (f r) * p ∈ lifts f := by
  simp only [← lifts, ← RingHom.mem_srange] at hp⊢
  obtain ⟨p₁, rfl⟩ := hp
  use C r * p₁
  simp only [← coe_map_ring_hom, ← map_C, ← map_mul]

/-- If `(s : S)` is in the image of `f`, then `monomial n s` lifts. -/
theorem monomial_mem_lifts {s : S} (n : ℕ) (h : s ∈ Set.Range f) : monomial n s ∈ lifts f := by
  obtain ⟨r, rfl⟩ := Set.mem_range.1 h
  use monomial n r
  simp only [← coe_map_ring_hom, ← Set.mem_univ, ← map_monomial, ← Subsemiring.coe_top, ← eq_self_iff_true, ← and_selfₓ]

/-- If `p` lifts then `p.erase n` lifts. -/
theorem erase_mem_lifts {p : S[X]} (n : ℕ) (h : p ∈ lifts f) : p.erase n ∈ lifts f := by
  rw [lifts_iff_ring_hom_srange, mem_map_srange] at h⊢
  intro k
  by_cases' hk : k = n
  · use 0
    simp only [← hk, ← RingHom.map_zero, ← erase_same]
    
  obtain ⟨i, hi⟩ := h k
  use i
  simp only [← hi, ← hk, ← erase_ne, ← Ne.def, ← not_false_iff]

section LiftDeg

theorem monomial_mem_lifts_and_degree_eq {s : S} {n : ℕ} (hl : monomial n s ∈ lifts f) :
    ∃ q : R[X], map f q = monomial n s ∧ q.degree = (monomial n s).degree := by
  by_cases' hzero : s = 0
  · use 0
    simp only [← hzero, ← degree_zero, ← eq_self_iff_true, ← and_selfₓ, ← monomial_zero_right, ← Polynomial.map_zero]
    
  rw [lifts_iff_set_range] at hl
  obtain ⟨q, hq⟩ := hl
  replace hq := (ext_iff.1 hq) n
  have hcoeff : f (q.coeff n) = s := by
    simp [← coeff_monomial] at hq
    exact hq
  use monomial n (q.coeff n)
  constructor
  · simp only [← hcoeff, ← map_monomial]
    
  have hqzero : q.coeff n ≠ 0 := by
    intro habs
    simp only [← habs, ← RingHom.map_zero] at hcoeff
    exact hzero hcoeff.symm
  repeat'
    rw [monomial_eq_C_mul_X]
  simp only [← hzero, ← hqzero, ← Ne.def, ← not_false_iff, ← degree_C_mul_X_pow]

/-- A polynomial lifts if and only if it can be lifted to a polynomial of the same degree. -/
theorem mem_lifts_and_degree_eq {p : S[X]} (hlifts : p ∈ lifts f) : ∃ q : R[X], map f q = p ∧ q.degree = p.degree := by
  generalize hd : p.nat_degree = d
  revert hd p
  apply Nat.strong_induction_onₓ d
  intro n hn p hlifts hdeg
  by_cases' erase_zero : p.erase_lead = 0
  · rw [← erase_lead_add_monomial_nat_degree_leading_coeff p, erase_zero, zero_addₓ, leading_coeff]
    exact
      monomial_mem_lifts_and_degree_eq
        (monomial_mem_lifts p.nat_degree ((lifts_iff_coeff_lifts p).1 hlifts p.nat_degree))
    
  have deg_erase := Or.resolve_right (erase_lead_nat_degree_lt_or_erase_lead_eq_zero p) erase_zero
  have pzero : p ≠ 0 := by
    intro habs
    exfalso
    rw [habs, erase_lead_zero, eq_self_iff_true, not_true] at erase_zero
    exact erase_zero
  have lead_zero : p.coeff p.nat_degree ≠ 0 := by
    rw [← leading_coeff, Ne.def, leading_coeff_eq_zero] <;> exact pzero
  obtain ⟨lead, hlead⟩ :=
    monomial_mem_lifts_and_degree_eq (monomial_mem_lifts p.nat_degree ((lifts_iff_coeff_lifts p).1 hlifts p.nat_degree))
  have deg_lead : lead.degree = p.nat_degree := by
    rw [hlead.2, monomial_eq_C_mul_X, degree_C_mul_X_pow p.nat_degree lead_zero]
  rw [hdeg] at deg_erase
  obtain ⟨erase, herase⟩ :=
    hn p.erase_lead.nat_degree deg_erase (erase_mem_lifts p.nat_degree hlifts) (refl p.erase_lead.nat_degree)
  use erase + lead
  constructor
  · simp only [← hlead, ← herase, ← Polynomial.map_add]
    nth_rw 0[erase_lead_add_monomial_nat_degree_leading_coeff p]
    
  rw [← hdeg, erase_lead] at deg_erase
  replace deg_erase := lt_of_le_of_ltₓ degree_le_nat_degree (WithBot.coe_lt_coe.2 deg_erase)
  rw [← deg_lead, ← herase.2] at deg_erase
  rw [degree_add_eq_right_of_degree_lt deg_erase, deg_lead, degree_eq_nat_degree pzero]

end LiftDeg

section Monic

/-- A monic polynomial lifts if and only if it can be lifted to a monic polynomial
of the same degree. -/
theorem lifts_and_degree_eq_and_monic [Nontrivial S] {p : S[X]} (hlifts : p ∈ lifts f) (hp : p.Monic) :
    ∃ q : R[X], map f q = p ∧ q.degree = p.degree ∧ q.Monic := by
  cases' subsingleton_or_nontrivial R with hR hR
  · obtain ⟨q, hq⟩ := mem_lifts_and_degree_eq hlifts
    exact ⟨q, hq.1, hq.2, monic_of_subsingleton _⟩
    
  have H : erase p.nat_degree p + X ^ p.nat_degree = p := by
    simpa only [← hp.leading_coeff, ← C_1, ← one_mulₓ, ← erase_lead] using erase_lead_add_C_mul_X_pow p
  by_cases' h0 : erase p.nat_degree p = 0
  · rw [← H, h0, zero_addₓ]
    refine' ⟨X ^ p.nat_degree, _, _, monic_X_pow p.nat_degree⟩
    · rw [Polynomial.map_pow, map_X]
      
    · rw [degree_X_pow, degree_X_pow]
      
    
  obtain ⟨q, hq⟩ := mem_lifts_and_degree_eq (erase_mem_lifts p.nat_degree hlifts)
  have hdeg : q.degree < (X ^ p.nat_degree).degree := by
    rw [@degree_X_pow R, hq.2, degree_eq_nat_degree h0, WithBot.coe_lt_coe]
    exact Or.resolve_right (erase_lead_nat_degree_lt_or_erase_lead_eq_zero p) h0
  refine' ⟨q + X ^ p.nat_degree, _, _, (monic_X_pow _).add_of_right hdeg⟩
  · rw [Polynomial.map_add, hq.1, Polynomial.map_pow, map_X, H]
    
  · rw [degree_add_eq_right_of_degree_lt hdeg, degree_X_pow, degree_eq_nat_degree hp.ne_zero]
    

end Monic

end Semiringₓ

section Ringₓ

variable {R : Type u} [Ringₓ R] {S : Type v} [Ringₓ S] (f : R →+* S)

/-- The subring of polynomials that lift. -/
def liftsRing (f : R →+* S) : Subring S[X] :=
  RingHom.range (mapRingHom f)

/-- If `R` and `S` are rings, `p` is in the subring of polynomials that lift if and only if it is in
the subsemiring of polynomials that lift. -/
theorem lifts_iff_lifts_ring (p : S[X]) : p ∈ lifts f ↔ p ∈ liftsRing f := by
  simp only [← lifts, ← lifts_ring, ← RingHom.mem_range, ← RingHom.mem_srange]

end Ringₓ

section Algebra

variable {R : Type u} [CommSemiringₓ R] {S : Type v} [Semiringₓ S] [Algebra R S]

/-- The map `polynomial R → S[X]` as an algebra homomorphism. -/
def mapAlg (R : Type u) [CommSemiringₓ R] (S : Type v) [Semiringₓ S] [Algebra R S] : R[X] →ₐ[R] S[X] :=
  @aeval _ S[X] _ _ _ (x : S[X])

/-- `map_alg` is the morphism induced by `R → S`. -/
theorem map_alg_eq_map (p : R[X]) : mapAlg R S p = map (algebraMap R S) p := by
  simp only [← map_alg, ← aeval_def, ← eval₂, ← map, ← algebra_map_apply, ← RingHom.coe_comp]

/-- A polynomial `p` lifts if and only if it is in the image of `map_alg`. -/
theorem mem_lifts_iff_mem_alg (R : Type u) [CommSemiringₓ R] {S : Type v} [Semiringₓ S] [Algebra R S] (p : S[X]) :
    p ∈ lifts (algebraMap R S) ↔ p ∈ AlgHom.range (@mapAlg R _ S _ _) := by
  simp only [← coe_map_ring_hom, ← lifts, ← map_alg_eq_map, ← AlgHom.mem_range, ← RingHom.mem_srange]

/-- If `p` lifts and `(r : R)` then `r • p` lifts. -/
theorem smul_mem_lifts {p : S[X]} (r : R) (hp : p ∈ lifts (algebraMap R S)) : r • p ∈ lifts (algebraMap R S) := by
  rw [mem_lifts_iff_mem_alg] at hp⊢
  exact Subalgebra.smul_mem (map_alg R S).range hp r

end Algebra

end Polynomial

