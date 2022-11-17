/-
Copyright (c) 2018 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Jens Wagemaker, Aaron Anderson
-/
import Mathbin.Data.Nat.Prime
import Mathbin.RingTheory.Coprime.Basic
import Mathbin.RingTheory.PrincipalIdealDomain

/-!
# Divisibility over ℕ and ℤ

This file collects results for the integers and natural numbers that use abstract algebra in
their proofs or cases of ℕ and ℤ being examples of structures in abstract algebra.

## Main statements

* `nat.factors_eq`: the multiset of elements of `nat.factors` is equal to the factors
   given by the `unique_factorization_monoid` instance
* ℤ is a `normalization_monoid`
* ℤ is a `gcd_monoid`

## Tags

prime, irreducible, natural numbers, integers, normalization monoid, gcd monoid,
greatest common divisor, prime factorization, prime factors, unique factorization,
unique factors
-/


namespace Nat

instance : WfDvdMonoid ℕ :=
  ⟨by
    refine'
      RelHomClass.well_founded (⟨fun x : ℕ => if x = 0 then (⊤ : ℕ∞) else x, _⟩ : DvdNotUnit →r (· < ·))
        (WithTop.well_founded_lt Nat.lt_wf)
    intro a b h
    cases a
    · exfalso
      revert h
      simp [DvdNotUnit]
      
    cases b
    · simpa [succ_ne_zero] using WithTop.coe_lt_top (a + 1)
      
    cases' dvd_and_not_dvd_iff.2 h with h1 h2
    simp only [succ_ne_zero, WithTop.coe_lt_coe, if_false]
    apply lt_of_le_of_ne (Nat.le_of_dvd (Nat.succ_pos _) h1) fun con => h2 _
    rw [Con]⟩

instance : UniqueFactorizationMonoid ℕ :=
  ⟨fun _ => Nat.irreducible_iff_prime⟩

end Nat

/-- `ℕ` is a gcd_monoid. -/
instance : GcdMonoid ℕ where
  gcd := Nat.gcd
  lcm := Nat.lcm
  gcd_dvd_left := Nat.gcd_dvd_left
  gcd_dvd_right := Nat.gcd_dvd_right
  dvd_gcd a b c := Nat.dvd_gcd
  gcd_mul_lcm a b := by rw [Nat.gcd_mul_lcm]
  lcm_zero_left := Nat.lcm_zero_left
  lcm_zero_right := Nat.lcm_zero_right

instance : NormalizedGcdMonoid ℕ :=
  { (inferInstance : GcdMonoid ℕ), (inferInstance : NormalizationMonoid ℕ) with
    normalize_gcd := fun a b => normalize_eq _, normalize_lcm := fun a b => normalize_eq _ }

theorem gcd_eq_nat_gcd (m n : ℕ) : gcd m n = Nat.gcd m n :=
  rfl
#align gcd_eq_nat_gcd gcd_eq_nat_gcd

theorem lcm_eq_nat_lcm (m n : ℕ) : lcm m n = Nat.lcm m n :=
  rfl
#align lcm_eq_nat_lcm lcm_eq_nat_lcm

namespace Int

section NormalizationMonoid

instance : NormalizationMonoid ℤ where
  normUnit := fun a : ℤ => if 0 ≤ a then 1 else -1
  norm_unit_zero := if_pos le_rfl
  norm_unit_mul a b hna hnb := by
    cases' hna.lt_or_lt with ha ha <;>
      cases' hnb.lt_or_lt with hb hb <;> simp [mul_nonneg_iff, ha.le, ha.not_le, hb.le, hb.not_le]
  norm_unit_coe_units u :=
    (units_eq_one_or u).elim (fun eq => Eq.symm ▸ if_pos zero_le_one) fun eq =>
      Eq.symm ▸ if_neg (not_le_of_gt $ show (-1 : ℤ) < 0 by decide)

theorem normalize_of_nonneg {z : ℤ} (h : 0 ≤ z) : normalize z = z :=
  show z * ↑(ite _ _ _) = z by rw [if_pos h, Units.coe_one, mul_one]
#align int.normalize_of_nonneg Int.normalize_of_nonneg

theorem normalize_of_neg {z : ℤ} (h : z < 0) : normalize z = -z :=
  show z * ↑(ite _ _ _) = -z by rw [if_neg (not_le_of_gt h), Units.coe_neg, Units.coe_one, mul_neg_one]
#align int.normalize_of_neg Int.normalize_of_neg

theorem normalize_coe_nat (n : ℕ) : normalize (n : ℤ) = n :=
  normalize_of_nonneg (coe_nat_le_coe_nat_of_le $ Nat.zero_le n)
#align int.normalize_coe_nat Int.normalize_coe_nat

theorem coe_nat_abs_eq_normalize (z : ℤ) : (z.natAbs : ℤ) = normalize z := by
  by_cases 0 ≤ z
  · simp [nat_abs_of_nonneg h, normalize_of_nonneg h]
    
  · simp [of_nat_nat_abs_of_nonpos (le_of_not_ge h), normalize_of_neg (lt_of_not_ge h)]
    
#align int.coe_nat_abs_eq_normalize Int.coe_nat_abs_eq_normalize

theorem nonneg_of_normalize_eq_self {z : ℤ} (hz : normalize z = z) : 0 ≤ z :=
  calc
    0 ≤ (z.natAbs : ℤ) := ofNat_zero_le _
    _ = normalize z := coe_nat_abs_eq_normalize _
    _ = z := hz
    
#align int.nonneg_of_normalize_eq_self Int.nonneg_of_normalize_eq_self

theorem nonneg_iff_normalize_eq_self (z : ℤ) : normalize z = z ↔ 0 ≤ z :=
  ⟨nonneg_of_normalize_eq_self, normalize_of_nonneg⟩
#align int.nonneg_iff_normalize_eq_self Int.nonneg_iff_normalize_eq_self

theorem eq_of_associated_of_nonneg {a b : ℤ} (h : Associated a b) (ha : 0 ≤ a) (hb : 0 ≤ b) : a = b :=
  dvd_antisymm_of_normalize_eq (normalize_of_nonneg ha) (normalize_of_nonneg hb) h.Dvd h.symm.Dvd
#align int.eq_of_associated_of_nonneg Int.eq_of_associated_of_nonneg

end NormalizationMonoid

section GcdMonoid

instance : GcdMonoid ℤ where
  gcd a b := Int.gcd a b
  lcm a b := Int.lcm a b
  gcd_dvd_left a b := Int.gcd_dvd_left _ _
  gcd_dvd_right a b := Int.gcd_dvd_right _ _
  dvd_gcd a b c := dvd_gcd
  gcd_mul_lcm a b := by
    rw [← Int.ofNat_mul, gcd_mul_lcm, coe_nat_abs_eq_normalize]
    exact normalize_associated (a * b)
  lcm_zero_left a := coe_nat_eq_zero.2 $ Nat.lcm_zero_left _
  lcm_zero_right a := coe_nat_eq_zero.2 $ Nat.lcm_zero_right _

instance : NormalizedGcdMonoid ℤ :=
  { Int.normalizationMonoid, (inferInstance : GcdMonoid ℤ) with normalize_gcd := fun a b => normalize_coe_nat _,
    normalize_lcm := fun a b => normalize_coe_nat _ }

theorem coe_gcd (i j : ℤ) : ↑(Int.gcd i j) = GcdMonoid.gcd i j :=
  rfl
#align int.coe_gcd Int.coe_gcd

theorem coe_lcm (i j : ℤ) : ↑(Int.lcm i j) = GcdMonoid.lcm i j :=
  rfl
#align int.coe_lcm Int.coe_lcm

theorem nat_abs_gcd (i j : ℤ) : natAbs (GcdMonoid.gcd i j) = Int.gcd i j :=
  rfl
#align int.nat_abs_gcd Int.nat_abs_gcd

theorem nat_abs_lcm (i j : ℤ) : natAbs (GcdMonoid.lcm i j) = Int.lcm i j :=
  rfl
#align int.nat_abs_lcm Int.nat_abs_lcm

end GcdMonoid

theorem exists_unit_of_abs (a : ℤ) : ∃ (u : ℤ) (h : IsUnit u), (Int.natAbs a : ℤ) = u * a := by
  cases' nat_abs_eq a with h
  · use 1, is_unit_one
    rw [← h, one_mul]
    
  · use -1, is_unit_one.neg
    rw [← neg_eq_iff_neg_eq.mp (Eq.symm h)]
    simp only [neg_mul, one_mul]
    
#align int.exists_unit_of_abs Int.exists_unit_of_abs

theorem gcd_eq_nat_abs {a b : ℤ} : Int.gcd a b = Nat.gcd a.natAbs b.natAbs :=
  rfl
#align int.gcd_eq_nat_abs Int.gcd_eq_nat_abs

theorem gcd_eq_one_iff_coprime {a b : ℤ} : Int.gcd a b = 1 ↔ IsCoprime a b := by
  constructor
  · intro hg
    obtain ⟨ua, hua, ha⟩ := exists_unit_of_abs a
    obtain ⟨ub, hub, hb⟩ := exists_unit_of_abs b
    use Nat.gcdA (Int.natAbs a) (Int.natAbs b) * ua, Nat.gcdB (Int.natAbs a) (Int.natAbs b) * ub
    rw [mul_assoc, ← ha, mul_assoc, ← hb, mul_comm, mul_comm _ (Int.natAbs b : ℤ), ← Nat.gcd_eq_gcd_ab, ←
      gcd_eq_nat_abs, hg, Int.ofNat_one]
    
  · rintro ⟨r, s, h⟩
    by_contra hg
    obtain ⟨p, ⟨hp, ha, hb⟩⟩ := nat.prime.not_coprime_iff_dvd.mp hg
    apply Nat.Prime.not_dvd_one hp
    rw [← coe_nat_dvd, Int.ofNat_one, ← h]
    exact dvd_add ((coe_nat_dvd_left.mpr ha).mul_left _) ((coe_nat_dvd_left.mpr hb).mul_left _)
    
#align int.gcd_eq_one_iff_coprime Int.gcd_eq_one_iff_coprime

theorem coprime_iff_nat_coprime {a b : ℤ} : IsCoprime a b ↔ Nat.Coprime a.natAbs b.natAbs := by
  rw [← gcd_eq_one_iff_coprime, Nat.coprime_iff_gcd_eq_one, gcd_eq_nat_abs]
#align int.coprime_iff_nat_coprime Int.coprime_iff_nat_coprime

/-- If `gcd a (m * n) ≠ 1`, then `gcd a m ≠ 1` or `gcd a n ≠ 1`. -/
theorem gcd_ne_one_iff_gcd_mul_right_ne_one {a : ℤ} {m n : ℕ} : a.gcd (m * n) ≠ 1 ↔ a.gcd m ≠ 1 ∨ a.gcd n ≠ 1 := by
  simp only [gcd_eq_one_iff_coprime, ← not_and_or, not_iff_not, IsCoprime.mul_right_iff]
#align int.gcd_ne_one_iff_gcd_mul_right_ne_one Int.gcd_ne_one_iff_gcd_mul_right_ne_one

/-- If `gcd a (m * n) = 1`, then `gcd a m = 1`. -/
theorem gcd_eq_one_of_gcd_mul_right_eq_one_left {a : ℤ} {m n : ℕ} (h : a.gcd (m * n) = 1) : a.gcd m = 1 :=
  Nat.dvd_one.mp $ trans_rel_left _ (gcd_dvd_gcd_mul_right_right a m n) h
#align int.gcd_eq_one_of_gcd_mul_right_eq_one_left Int.gcd_eq_one_of_gcd_mul_right_eq_one_left

/-- If `gcd a (m * n) = 1`, then `gcd a n = 1`. -/
theorem gcd_eq_one_of_gcd_mul_right_eq_one_right {a : ℤ} {m n : ℕ} (h : a.gcd (m * n) = 1) : a.gcd n = 1 :=
  Nat.dvd_one.mp $ trans_rel_left _ (gcd_dvd_gcd_mul_left_right a n m) h
#align int.gcd_eq_one_of_gcd_mul_right_eq_one_right Int.gcd_eq_one_of_gcd_mul_right_eq_one_right

theorem sq_of_gcd_eq_one {a b c : ℤ} (h : Int.gcd a b = 1) (heq : a * b = c ^ 2) : ∃ a0 : ℤ, a = a0 ^ 2 ∨ a = -a0 ^ 2 :=
  by
  have h' : IsUnit (GcdMonoid.gcd a b) := by
    rw [← coe_gcd, h, Int.ofNat_one]
    exact is_unit_one
  obtain ⟨d, ⟨u, hu⟩⟩ := exists_associated_pow_of_mul_eq_pow h' HEq
  use d
  rw [← hu]
  cases' Int.units_eq_one_or u with hu' hu' <;>
    · rw [hu']
      simp
      
#align int.sq_of_gcd_eq_one Int.sq_of_gcd_eq_one

theorem sq_of_coprime {a b c : ℤ} (h : IsCoprime a b) (heq : a * b = c ^ 2) : ∃ a0 : ℤ, a = a0 ^ 2 ∨ a = -a0 ^ 2 :=
  sq_of_gcd_eq_one (gcd_eq_one_iff_coprime.mpr h) HEq
#align int.sq_of_coprime Int.sq_of_coprime

theorem nat_abs_euclidean_domain_gcd (a b : ℤ) : Int.natAbs (EuclideanDomain.gcd a b) = Int.gcd a b := by
  apply Nat.dvd_antisymm <;> rw [← Int.coe_nat_dvd]
  · rw [Int.nat_abs_dvd]
    exact Int.dvd_gcd (EuclideanDomain.gcd_dvd_left _ _) (EuclideanDomain.gcd_dvd_right _ _)
    
  · rw [Int.dvd_nat_abs]
    exact EuclideanDomain.dvd_gcd (Int.gcd_dvd_left _ _) (Int.gcd_dvd_right _ _)
    
#align int.nat_abs_euclidean_domain_gcd Int.nat_abs_euclidean_domain_gcd

end Int

/-- Maps an associate class of integers consisting of `-n, n` to `n : ℕ` -/
def associatesIntEquivNat : Associates ℤ ≃ ℕ := by
  refine' ⟨fun z => z.out.nat_abs, fun n => Associates.mk n, _, _⟩
  · refine' fun a =>
      Quotient.inductionOn' a $ fun a => Associates.mk_eq_mk_iff_associated.2 $ Associated.symm $ ⟨norm_unit a, _⟩
    show normalize a = Int.natAbs (normalize a)
    rw [Int.coe_nat_abs_eq_normalize, normalize_idem]
    
  · intro n
    dsimp
    rw [← normalize_apply, ← Int.coe_nat_abs_eq_normalize, Int.natAbs_ofNat, Int.natAbs_ofNat]
    
#align associates_int_equiv_nat associatesIntEquivNat

theorem Int.Prime.dvd_mul {m n : ℤ} {p : ℕ} (hp : Nat.Prime p) (h : (p : ℤ) ∣ m * n) : p ∣ m.natAbs ∨ p ∣ n.natAbs := by
  apply (Nat.Prime.dvd_mul hp).mp
  rw [← Int.natAbs_mul]
  exact int.coe_nat_dvd_left.mp h
#align int.prime.dvd_mul Int.Prime.dvd_mul

theorem Int.Prime.dvd_mul' {m n : ℤ} {p : ℕ} (hp : Nat.Prime p) (h : (p : ℤ) ∣ m * n) : (p : ℤ) ∣ m ∨ (p : ℤ) ∣ n := by
  rw [Int.coe_nat_dvd_left, Int.coe_nat_dvd_left]
  exact Int.Prime.dvd_mul hp h
#align int.prime.dvd_mul' Int.Prime.dvd_mul'

theorem Int.Prime.dvd_pow {n : ℤ} {k p : ℕ} (hp : Nat.Prime p) (h : (p : ℤ) ∣ n ^ k) : p ∣ n.natAbs := by
  apply @Nat.Prime.dvd_of_dvd_pow _ _ k hp
  rw [← Int.nat_abs_pow]
  exact int.coe_nat_dvd_left.mp h
#align int.prime.dvd_pow Int.Prime.dvd_pow

theorem Int.Prime.dvd_pow' {n : ℤ} {k p : ℕ} (hp : Nat.Prime p) (h : (p : ℤ) ∣ n ^ k) : (p : ℤ) ∣ n := by
  rw [Int.coe_nat_dvd_left]
  exact Int.Prime.dvd_pow hp h
#align int.prime.dvd_pow' Int.Prime.dvd_pow'

theorem prime_two_or_dvd_of_dvd_two_mul_pow_self_two {m : ℤ} {p : ℕ} (hp : Nat.Prime p) (h : (p : ℤ) ∣ 2 * m ^ 2) :
    p = 2 ∨ p ∣ Int.natAbs m := by
  cases' Int.Prime.dvd_mul hp h with hp2 hpp
  · apply Or.intro_left
    exact le_antisymm (Nat.le_of_dvd zero_lt_two hp2) (Nat.Prime.two_le hp)
    
  · apply Or.intro_right
    rw [sq, Int.natAbs_mul] at hpp
    exact (or_self_iff _).mp ((Nat.Prime.dvd_mul hp).mp hpp)
    
#align prime_two_or_dvd_of_dvd_two_mul_pow_self_two prime_two_or_dvd_of_dvd_two_mul_pow_self_two

theorem Int.exists_prime_and_dvd {n : ℤ} (hn : n.natAbs ≠ 1) : ∃ p, Prime p ∧ p ∣ n := by
  obtain ⟨p, pp, pd⟩ := Nat.exists_prime_and_dvd hn
  exact ⟨p, nat.prime_iff_prime_int.mp pp, int.coe_nat_dvd_left.mpr pd⟩
#align int.exists_prime_and_dvd Int.exists_prime_and_dvd

open UniqueFactorizationMonoid

theorem Nat.factors_eq {n : ℕ} : normalizedFactors n = n.factors := by
  cases n
  · simp
    
  rw [← Multiset.rel_eq, ← associated_eq_eq]
  apply factors_unique irreducible_of_normalized_factor _
  · rw [Multiset.coe_prod, Nat.prod_factors n.succ_ne_zero]
    apply normalized_factors_prod (Nat.succ_ne_zero _)
    
  · infer_instance
    
  · intro x hx
    rw [Nat.irreducible_iff_prime, ← Nat.prime_iff]
    exact Nat.prime_of_mem_factors hx
    
#align nat.factors_eq Nat.factors_eq

theorem Nat.factors_multiset_prod_of_irreducible {s : Multiset ℕ} (h : ∀ x : ℕ, x ∈ s → Irreducible x) :
    normalizedFactors s.Prod = s := by
  rw [← Multiset.rel_eq, ← associated_eq_eq]
  apply UniqueFactorizationMonoid.factors_unique irreducible_of_normalized_factor h (normalized_factors_prod _)
  rw [Ne.def, Multiset.prod_eq_zero_iff]
  intro con
  exact not_irreducible_zero (h 0 Con)
#align nat.factors_multiset_prod_of_irreducible Nat.factors_multiset_prod_of_irreducible

namespace multiplicity

theorem finite_int_iff_nat_abs_finite {a b : ℤ} : Finite a b ↔ Finite a.natAbs b.natAbs := by
  simp only [finite_def, ← Int.nat_abs_dvd_iff_dvd, Int.nat_abs_pow]
#align multiplicity.finite_int_iff_nat_abs_finite multiplicity.finite_int_iff_nat_abs_finite

theorem finite_int_iff {a b : ℤ} : Finite a b ↔ a.natAbs ≠ 1 ∧ b ≠ 0 := by
  rw [finite_int_iff_nat_abs_finite, finite_nat_iff, pos_iff_ne_zero, Int.natAbs_ne_zero]
#align multiplicity.finite_int_iff multiplicity.finite_int_iff

instance decidableNat : DecidableRel fun a b : ℕ => (multiplicity a b).Dom := fun a b =>
  decidable_of_iff _ finite_nat_iff.symm
#align multiplicity.decidable_nat multiplicity.decidableNat

instance decidableInt : DecidableRel fun a b : ℤ => (multiplicity a b).Dom := fun a b =>
  decidable_of_iff _ finite_int_iff.symm
#align multiplicity.decidable_int multiplicity.decidableInt

end multiplicity

theorem induction_on_primes {P : ℕ → Prop} (h₀ : P 0) (h₁ : P 1) (h : ∀ p a : ℕ, p.Prime → P a → P (p * a)) (n : ℕ) :
    P n := by
  apply UniqueFactorizationMonoid.inductionOnPrime
  exact h₀
  · intro n h
    rw [Nat.is_unit_iff.1 h]
    exact h₁
    
  · intro a p _ hp ha
    exact h p a hp.nat_prime ha
    
#align induction_on_primes induction_on_primes

theorem Int.associated_nat_abs (k : ℤ) : Associated k k.natAbs :=
  associated_of_dvd_dvd (Int.coe_nat_dvd_right.mpr dvd_rfl) (Int.nat_abs_dvd.mpr dvd_rfl)
#align int.associated_nat_abs Int.associated_nat_abs

theorem Int.prime_iff_nat_abs_prime {k : ℤ} : Prime k ↔ Nat.Prime k.natAbs :=
  (Int.associated_nat_abs k).prime_iff.trans Nat.prime_iff_prime_int.symm
#align int.prime_iff_nat_abs_prime Int.prime_iff_nat_abs_prime

theorem Int.associated_iff_nat_abs {a b : ℤ} : Associated a b ↔ a.natAbs = b.natAbs := by
  rw [← dvd_dvd_iff_associated, ← Int.nat_abs_dvd_iff_dvd, ← Int.nat_abs_dvd_iff_dvd, dvd_dvd_iff_associated]
  exact associated_iff_eq
#align int.associated_iff_nat_abs Int.associated_iff_nat_abs

theorem Int.associated_iff {a b : ℤ} : Associated a b ↔ a = b ∨ a = -b := by
  rw [Int.associated_iff_nat_abs]
  exact Int.natAbs_eq_natAbs_iff
#align int.associated_iff Int.associated_iff

namespace Int

theorem zmultiples_nat_abs (a : ℤ) : AddSubgroup.zmultiples (a.natAbs : ℤ) = AddSubgroup.zmultiples a :=
  le_antisymm (AddSubgroup.zmultiples_subset (mem_zmultiples_iff.mpr (dvd_nat_abs.mpr (dvd_refl a))))
    (AddSubgroup.zmultiples_subset (mem_zmultiples_iff.mpr (nat_abs_dvd.mpr (dvd_refl a))))
#align int.zmultiples_nat_abs Int.zmultiples_nat_abs

theorem span_nat_abs (a : ℤ) : Ideal.span ({a.natAbs} : Set ℤ) = Ideal.span {a} := by
  rw [Ideal.span_singleton_eq_span_singleton]
  exact (associated_nat_abs _).symm
#align int.span_nat_abs Int.span_nat_abs

theorem eq_pow_of_mul_eq_pow_bit1_left {a b c : ℤ} (hab : IsCoprime a b) {k : ℕ} (h : a * b = c ^ bit1 k) :
    ∃ d, a = d ^ bit1 k := by
  obtain ⟨d, hd⟩ := exists_associated_pow_of_mul_eq_pow' hab h
  replace hd := hd.symm
  rw [associated_iff_nat_abs, nat_abs_eq_nat_abs_iff, ← neg_pow_bit1] at hd
  obtain rfl | rfl := hd <;> exact ⟨_, rfl⟩
#align int.eq_pow_of_mul_eq_pow_bit1_left Int.eq_pow_of_mul_eq_pow_bit1_left

theorem eq_pow_of_mul_eq_pow_bit1_right {a b c : ℤ} (hab : IsCoprime a b) {k : ℕ} (h : a * b = c ^ bit1 k) :
    ∃ d, b = d ^ bit1 k :=
  eq_pow_of_mul_eq_pow_bit1_left hab.symm (by rwa [mul_comm] at h)
#align int.eq_pow_of_mul_eq_pow_bit1_right Int.eq_pow_of_mul_eq_pow_bit1_right

theorem eq_pow_of_mul_eq_pow_bit1 {a b c : ℤ} (hab : IsCoprime a b) {k : ℕ} (h : a * b = c ^ bit1 k) :
    (∃ d, a = d ^ bit1 k) ∧ ∃ e, b = e ^ bit1 k :=
  ⟨eq_pow_of_mul_eq_pow_bit1_left hab h, eq_pow_of_mul_eq_pow_bit1_right hab h⟩
#align int.eq_pow_of_mul_eq_pow_bit1 Int.eq_pow_of_mul_eq_pow_bit1

end Int

