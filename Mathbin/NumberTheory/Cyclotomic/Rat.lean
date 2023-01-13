/-
Copyright (c) 2022 Riccardo Brasca. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Riccardo Brasca

! This file was ported from Lean 3 source module number_theory.cyclotomic.rat
! leanprover-community/mathlib commit 9003f28797c0664a49e4179487267c494477d853
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.NumberTheory.Cyclotomic.Discriminant
import Mathbin.RingTheory.Polynomial.Eisenstein

/-!
# Ring of integers of `p ^ n`-th cyclotomic fields
We gather results about cyclotomic extensions of `ℚ`. In particular, we compute the ring of
integers of a `p ^ n`-th cyclotomic extension of `ℚ`.

## Main results
* `is_cyclotomic_extension.rat.is_integral_closure_adjoin_singleton_of_prime_pow`: if `K` is a
  `p ^ k`-th cyclotomic extension of `ℚ`, then `(adjoin ℤ {ζ})` is the integral closure of
  `ℤ` in `K`.
* `is_cyclotomic_extension.rat.cyclotomic_ring_is_integral_closure_of_prime_pow`: the integral
  closure of `ℤ` inside `cyclotomic_field (p ^ k) ℚ` is `cyclotomic_ring (p ^ k) ℤ ℚ`.
-/


universe u

open Algebra IsCyclotomicExtension Polynomial NumberField

open Cyclotomic NumberField Nat

variable {p : ℕ+} {k : ℕ} {K : Type u} [Field K] [CharZero K] {ζ : K} [hp : Fact (p : ℕ).Prime]

include hp

namespace IsCyclotomicExtension.Rat

/-- The discriminant of the power basis given by `ζ - 1`. -/
theorem discr_prime_pow_ne_two' [IsCyclotomicExtension {p ^ (k + 1)} ℚ K]
    (hζ : IsPrimitiveRoot ζ ↑(p ^ (k + 1))) (hk : p ^ (k + 1) ≠ 2) :
    discr ℚ (hζ.subOnePowerBasis ℚ).Basis =
      (-1) ^ ((p ^ (k + 1) : ℕ).totient / 2) * p ^ ((p : ℕ) ^ k * ((p - 1) * (k + 1) - 1)) :=
  by
  rw [← discr_prime_pow_ne_two hζ (cyclotomic.irreducible_rat (p ^ (k + 1)).Pos) hk]
  exact hζ.discr_zeta_eq_discr_zeta_sub_one.symm
#align
  is_cyclotomic_extension.rat.discr_prime_pow_ne_two' IsCyclotomicExtension.Rat.discr_prime_pow_ne_two'

theorem discr_odd_prime' [IsCyclotomicExtension {p} ℚ K] (hζ : IsPrimitiveRoot ζ p) (hodd : p ≠ 2) :
    discr ℚ (hζ.subOnePowerBasis ℚ).Basis = (-1) ^ (((p : ℕ) - 1) / 2) * p ^ ((p : ℕ) - 2) :=
  by
  rw [← discr_odd_prime hζ (cyclotomic.irreducible_rat hp.out.pos) hodd]
  exact hζ.discr_zeta_eq_discr_zeta_sub_one.symm
#align is_cyclotomic_extension.rat.discr_odd_prime' IsCyclotomicExtension.Rat.discr_odd_prime'

/-- The discriminant of the power basis given by `ζ - 1`. Beware that in the cases `p ^ k = 1` and
`p ^ k = 2` the formula uses `1 / 2 = 0` and `0 - 1 = 0`. It is useful only to have a uniform
result. See also `is_cyclotomic_extension.rat.discr_prime_pow_eq_unit_mul_pow'`. -/
theorem discr_prime_pow' [IsCyclotomicExtension {p ^ k} ℚ K] (hζ : IsPrimitiveRoot ζ ↑(p ^ k)) :
    discr ℚ (hζ.subOnePowerBasis ℚ).Basis =
      (-1) ^ ((p ^ k : ℕ).totient / 2) * p ^ ((p : ℕ) ^ (k - 1) * ((p - 1) * k - 1)) :=
  by
  rw [← discr_prime_pow hζ (cyclotomic.irreducible_rat (p ^ k).Pos)]
  exact hζ.discr_zeta_eq_discr_zeta_sub_one.symm
#align is_cyclotomic_extension.rat.discr_prime_pow' IsCyclotomicExtension.Rat.discr_prime_pow'

/-- If `p` is a prime and `is_cyclotomic_extension {p ^ k} K L`, then there are `u : ℤˣ` and
`n : ℕ` such that the discriminant of the power basis given by `ζ - 1` is `u * p ^ n`. Often this is
enough and less cumbersome to use than `is_cyclotomic_extension.rat.discr_prime_pow'`. -/
theorem discr_prime_pow_eq_unit_mul_pow' [IsCyclotomicExtension {p ^ k} ℚ K]
    (hζ : IsPrimitiveRoot ζ ↑(p ^ k)) :
    ∃ (u : ℤˣ)(n : ℕ), discr ℚ (hζ.subOnePowerBasis ℚ).Basis = u * p ^ n :=
  by
  rw [hζ.discr_zeta_eq_discr_zeta_sub_one.symm]
  exact discr_prime_pow_eq_unit_mul_pow hζ (cyclotomic.irreducible_rat (p ^ k).Pos)
#align
  is_cyclotomic_extension.rat.discr_prime_pow_eq_unit_mul_pow' IsCyclotomicExtension.Rat.discr_prime_pow_eq_unit_mul_pow'

/-- If `K` is a `p ^ k`-th cyclotomic extension of `ℚ`, then `(adjoin ℤ {ζ})` is the
integral closure of `ℤ` in `K`. -/
theorem is_integral_closure_adjoin_singleton_of_prime_pow
    [hcycl : IsCyclotomicExtension {p ^ k} ℚ K] (hζ : IsPrimitiveRoot ζ ↑(p ^ k)) :
    IsIntegralClosure (adjoin ℤ ({ζ} : Set K)) ℤ K :=
  by
  refine' ⟨Subtype.val_injective, fun x => ⟨fun h => ⟨⟨x, _⟩, rfl⟩, _⟩⟩
  swap
  · rintro ⟨y, rfl⟩
    exact
      IsIntegral.algebra_map
        (le_integral_closure_iff_is_integral.1
          (adjoin_le_integral_closure (hζ.is_integral (p ^ k).Pos)) _)
  let B := hζ.sub_one_power_basis ℚ
  have hint : IsIntegral ℤ B.gen := is_integral_sub (hζ.is_integral (p ^ k).Pos) is_integral_one
  have H := discr_mul_is_integral_mem_adjoin ℚ hint h
  obtain ⟨u, n, hun⟩ := discr_prime_pow_eq_unit_mul_pow' hζ
  rw [hun] at H
  replace H := Subalgebra.smul_mem _ H u.inv
  rw [← smul_assoc, ← smul_mul_assoc, Units.inv_eq_val_inv, coe_coe, zsmul_eq_mul, ← Int.cast_mul,
    Units.inv_mul, Int.cast_one, one_mul,
    show (p : ℚ) ^ n • x = ((p : ℕ) : ℤ) ^ n • x by simp [smul_def]] at H
  cases k
  · haveI : IsCyclotomicExtension {1} ℚ K := by simpa using hcycl
    have : x ∈ (⊥ : Subalgebra ℚ K) := by
      rw [singleton_one ℚ K]
      exact mem_top
    obtain ⟨y, rfl⟩ := mem_bot.1 this
    replace h := (is_integral_algebra_map_iff (algebraMap ℚ K).Injective).1 h
    obtain ⟨z, hz⟩ := IsIntegrallyClosed.is_integral_iff.1 h
    rw [← hz, ← IsScalarTower.algebra_map_apply]
    exact Subalgebra.algebra_map_mem _ _
  · have hmin : (minpoly ℤ B.gen).IsEisensteinAt (Submodule.span ℤ {((p : ℕ) : ℤ)}) :=
      by
      have h₁ := minpoly.gcd_domain_eq_field_fractions' ℚ hint
      have h₂ := hζ.minpoly_sub_one_eq_cyclotomic_comp (cyclotomic.irreducible_rat (p ^ _).Pos)
      rw [IsPrimitiveRoot.sub_one_power_basis_gen] at h₁
      rw [h₁, ← map_cyclotomic_int, show Int.castRingHom ℚ = algebraMap ℤ ℚ by rfl,
        show X + 1 = map (algebraMap ℤ ℚ) (X + 1) by simp, ← map_comp] at h₂
      haveI : CharZero ℚ := StrictOrderedSemiring.to_charZero
      rw [IsPrimitiveRoot.sub_one_power_basis_gen,
        map_injective (algebraMap ℤ ℚ) (algebraMap ℤ ℚ).injective_int h₂]
      exact cyclotomicPrimePowCompXAddOneIsEisensteinAt _ _
    refine'
      adjoin_le _
        (mem_adjoin_of_smul_prime_pow_smul_of_minpoly_is_eiseinstein_at
          (Nat.prime_iff_prime_int.1 hp.out) hint h H hmin)
    simp only [Set.singleton_subset_iff, SetLike.mem_coe]
    exact Subalgebra.sub_mem _ (self_mem_adjoin_singleton ℤ _) (Subalgebra.one_mem _)
#align
  is_cyclotomic_extension.rat.is_integral_closure_adjoin_singleton_of_prime_pow IsCyclotomicExtension.Rat.is_integral_closure_adjoin_singleton_of_prime_pow

theorem is_integral_closure_adjoin_singleton_of_prime [hcycl : IsCyclotomicExtension {p} ℚ K]
    (hζ : IsPrimitiveRoot ζ ↑p) : IsIntegralClosure (adjoin ℤ ({ζ} : Set K)) ℤ K :=
  by
  rw [← pow_one p] at hζ hcycl
  exact is_integral_closure_adjoin_singleton_of_prime_pow hζ
#align
  is_cyclotomic_extension.rat.is_integral_closure_adjoin_singleton_of_prime IsCyclotomicExtension.Rat.is_integral_closure_adjoin_singleton_of_prime

attribute [-instance] CyclotomicField.algebra

/-- The integral closure of `ℤ` inside `cyclotomic_field (p ^ k) ℚ` is
`cyclotomic_ring (p ^ k) ℤ ℚ`. -/
theorem cyclotomic_ring_is_integral_closure_of_prime_pow :
    IsIntegralClosure (CyclotomicRing (p ^ k) ℤ ℚ) ℤ (CyclotomicField (p ^ k) ℚ) :=
  by
  haveI : CharZero ℚ := StrictOrderedSemiring.to_charZero
  have : IsCyclotomicExtension {p ^ k} ℚ (CyclotomicField (p ^ k) ℚ) :=
    by
    convert CyclotomicField.is_cyclotomic_extension (p ^ k) _
    · exact Subsingleton.elim _ _
    · exact NeZero.charZero
  have hζ := zeta_spec (p ^ k) ℚ (CyclotomicField (p ^ k) ℚ)
  refine' ⟨IsFractionRing.injective _ _, fun x => ⟨fun h => ⟨⟨x, _⟩, rfl⟩, _⟩⟩
  · have := (is_integral_closure_adjoin_singleton_of_prime_pow hζ).is_integral_iff
    obtain ⟨y, rfl⟩ := this.1 h
    convert adjoin_mono _ y.2
    · simp only [eq_iff_true_of_subsingleton]
    · simp only [eq_iff_true_of_subsingleton]
    · simp only [PNat.pow_coe, Set.singleton_subset_iff, Set.mem_setOf_eq]
      exact hζ.pow_eq_one
  · have : IsCyclotomicExtension {p ^ k} ℤ (CyclotomicRing (p ^ k) ℤ ℚ) :=
      by
      convert CyclotomicRing.is_cyclotomic_extension _ ℤ ℚ
      · exact Subsingleton.elim _ _
      · exact NeZero.charZero
    rintro ⟨y, rfl⟩
    exact IsIntegral.algebra_map ((IsCyclotomicExtension.integral {p ^ k} ℤ _) _)
#align
  is_cyclotomic_extension.rat.cyclotomic_ring_is_integral_closure_of_prime_pow IsCyclotomicExtension.Rat.cyclotomic_ring_is_integral_closure_of_prime_pow

theorem cyclotomic_ring_is_integral_closure_of_prime :
    IsIntegralClosure (CyclotomicRing p ℤ ℚ) ℤ (CyclotomicField p ℚ) :=
  by
  rw [← pow_one p]
  exact cyclotomic_ring_is_integral_closure_of_prime_pow
#align
  is_cyclotomic_extension.rat.cyclotomic_ring_is_integral_closure_of_prime IsCyclotomicExtension.Rat.cyclotomic_ring_is_integral_closure_of_prime

end IsCyclotomicExtension.Rat

section PowerBasis

open IsCyclotomicExtension.Rat

namespace IsPrimitiveRoot

/-- The algebra isomorphism `adjoin ℤ {ζ} ≃ₐ[ℤ] (𝓞 K)`, where `ζ` is a primitive `p ^ k`-th root of
unity and `K` is a `p ^ k`-th cyclotomic extension of `ℚ`. -/
@[simps]
noncomputable def IsPrimitiveRoot.adjoinEquivRingOfIntegers
    [hcycl : IsCyclotomicExtension {p ^ k} ℚ K] (hζ : IsPrimitiveRoot ζ ↑(p ^ k)) :
    adjoin ℤ ({ζ} : Set K) ≃ₐ[ℤ] 𝓞 K :=
  let _ := is_integral_closure_adjoin_singleton_of_prime_pow hζ
  IsIntegralClosure.equiv ℤ (adjoin ℤ ({ζ} : Set K)) K (𝓞 K)
#align is_primitive_root.adjoin_equiv_ring_of_integers IsPrimitiveRoot.adjoinEquivRingOfIntegers

/-- The ring of integers of a `p ^ k`-th cyclotomic extension of `ℚ` is a cyclotomic extension. -/
instance IsCyclotomicExtension.ring_of_integers [IsCyclotomicExtension {p ^ k} ℚ K] :
    IsCyclotomicExtension {p ^ k} ℤ (𝓞 K) :=
  let _ := (zeta_spec (p ^ k) ℚ K).adjoin_is_cyclotomic_extension ℤ
  IsCyclotomicExtension.equiv _ ℤ _ (zeta_spec (p ^ k) ℚ K).adjoinEquivRingOfIntegers
#align is_cyclotomic_extension.ring_of_integers IsCyclotomicExtension.ring_of_integers

/-- The integral `power_basis` of `𝓞 K` given by a primitive root of unity, where `K` is a `p ^ k`
cyclotomic extension of `ℚ`. -/
noncomputable def integralPowerBasis [hcycl : IsCyclotomicExtension {p ^ k} ℚ K]
    (hζ : IsPrimitiveRoot ζ ↑(p ^ k)) : PowerBasis ℤ (𝓞 K) :=
  (adjoin.powerBasis' (hζ.IsIntegral (p ^ k).Pos)).map hζ.adjoinEquivRingOfIntegers
#align is_primitive_root.integral_power_basis IsPrimitiveRoot.integralPowerBasis

@[simp]
theorem integral_power_basis_gen [hcycl : IsCyclotomicExtension {p ^ k} ℚ K]
    (hζ : IsPrimitiveRoot ζ ↑(p ^ k)) :
    hζ.integralPowerBasis.gen = ⟨ζ, hζ.IsIntegral (p ^ k).Pos⟩ :=
  Subtype.ext <| show algebraMap _ K hζ.integralPowerBasis.gen = _ by simpa [integral_power_basis]
#align is_primitive_root.integral_power_basis_gen IsPrimitiveRoot.integral_power_basis_gen

@[simp]
theorem integral_power_basis_dim [hcycl : IsCyclotomicExtension {p ^ k} ℚ K]
    (hζ : IsPrimitiveRoot ζ ↑(p ^ k)) : hζ.integralPowerBasis.dim = φ (p ^ k) := by
  simp [integral_power_basis, ← cyclotomic_eq_minpoly hζ, nat_degree_cyclotomic]
#align is_primitive_root.integral_power_basis_dim IsPrimitiveRoot.integral_power_basis_dim

/-- The algebra isomorphism `adjoin ℤ {ζ} ≃ₐ[ℤ] (𝓞 K)`, where `ζ` is a primitive `p`-th root of
unity and `K` is a `p`-th cyclotomic extension of `ℚ`. -/
@[simps]
noncomputable def IsPrimitiveRoot.adjoinEquivRingOfIntegers' [hcycl : IsCyclotomicExtension {p} ℚ K]
    (hζ : IsPrimitiveRoot ζ p) : adjoin ℤ ({ζ} : Set K) ≃ₐ[ℤ] 𝓞 K :=
  @adjoinEquivRingOfIntegers p 1 K _ _ _ _
    (by
      convert hcycl
      rw [pow_one])
    (by rwa [pow_one])
#align is_primitive_root.adjoin_equiv_ring_of_integers' IsPrimitiveRoot.adjoinEquivRingOfIntegers'

/-- The ring of integers of a `p`-th cyclotomic extension of `ℚ` is a cyclotomic extension. -/
instance IsCyclotomicExtension.ring_of_integers' [IsCyclotomicExtension {p} ℚ K] :
    IsCyclotomicExtension {p} ℤ (𝓞 K) :=
  let _ := (zeta_spec p ℚ K).adjoin_is_cyclotomic_extension ℤ
  IsCyclotomicExtension.equiv _ ℤ _ (zeta_spec p ℚ K).adjoinEquivRingOfIntegers'
#align is_cyclotomic_extension.ring_of_integers' IsCyclotomicExtension.ring_of_integers'

/-- The integral `power_basis` of `𝓞 K` given by a primitive root of unity, where `K` is a `p`-th
cyclotomic extension of `ℚ`. -/
noncomputable def integralPowerBasis' [hcycl : IsCyclotomicExtension {p} ℚ K]
    (hζ : IsPrimitiveRoot ζ p) : PowerBasis ℤ (𝓞 K) :=
  @integralPowerBasis p 1 K _ _ _ _
    (by
      convert hcycl
      rw [pow_one])
    (by rwa [pow_one])
#align is_primitive_root.integral_power_basis' IsPrimitiveRoot.integralPowerBasis'

@[simp]
theorem integral_power_basis'_gen [hcycl : IsCyclotomicExtension {p} ℚ K]
    (hζ : IsPrimitiveRoot ζ p) : hζ.integralPowerBasis'.gen = ⟨ζ, hζ.IsIntegral p.Pos⟩ :=
  @integral_power_basis_gen p 1 K _ _ _ _
    (by
      convert hcycl
      rw [pow_one])
    (by rwa [pow_one])
#align is_primitive_root.integral_power_basis'_gen IsPrimitiveRoot.integral_power_basis'_gen

@[simp]
theorem power_basis_int'_dim [hcycl : IsCyclotomicExtension {p} ℚ K] (hζ : IsPrimitiveRoot ζ p) :
    hζ.integralPowerBasis'.dim = φ p := by
  erw [@integral_power_basis_dim p 1 K _ _ _ _
      (by
        convert hcycl
        rw [pow_one])
      (by rwa [pow_one]),
    pow_one]
#align is_primitive_root.power_basis_int'_dim IsPrimitiveRoot.power_basis_int'_dim

/-- The integral `power_basis` of `𝓞 K` given by `ζ - 1`, where `K` is a `p ^ k` cyclotomic
extension of `ℚ`. -/
noncomputable def subOneIntegralPowerBasis [IsCyclotomicExtension {p ^ k} ℚ K]
    (hζ : IsPrimitiveRoot ζ ↑(p ^ k)) : PowerBasis ℤ (𝓞 K) :=
  PowerBasis.ofGenMemAdjoin' hζ.integralPowerBasis
    (is_integral_of_mem_ring_of_integers <|
      Subalgebra.sub_mem _ (hζ.IsIntegral (p ^ k).Pos) (Subalgebra.one_mem _))
    (by
      simp only [integral_power_basis_gen]
      convert
        Subalgebra.add_mem _ (self_mem_adjoin_singleton ℤ (⟨ζ - 1, _⟩ : 𝓞 K)) (Subalgebra.one_mem _)
      simp)
#align is_primitive_root.sub_one_integral_power_basis IsPrimitiveRoot.subOneIntegralPowerBasis

@[simp]
theorem sub_one_integral_power_basis_gen [IsCyclotomicExtension {p ^ k} ℚ K]
    (hζ : IsPrimitiveRoot ζ ↑(p ^ k)) :
    hζ.subOneIntegralPowerBasis.gen =
      ⟨ζ - 1, Subalgebra.sub_mem _ (hζ.IsIntegral (p ^ k).Pos) (Subalgebra.one_mem _)⟩ :=
  by simp [sub_one_integral_power_basis]
#align
  is_primitive_root.sub_one_integral_power_basis_gen IsPrimitiveRoot.sub_one_integral_power_basis_gen

/-- The integral `power_basis` of `𝓞 K` given by `ζ - 1`, where `K` is a `p`-th cyclotomic
extension of `ℚ`. -/
noncomputable def subOneIntegralPowerBasis' [hcycl : IsCyclotomicExtension {p} ℚ K]
    (hζ : IsPrimitiveRoot ζ p) : PowerBasis ℤ (𝓞 K) :=
  @subOneIntegralPowerBasis p 1 K _ _ _ _
    (by
      convert hcycl
      rw [pow_one])
    (by rwa [pow_one])
#align is_primitive_root.sub_one_integral_power_basis' IsPrimitiveRoot.subOneIntegralPowerBasis'

@[simp]
theorem sub_one_integral_power_basis'_gen [hcycl : IsCyclotomicExtension {p} ℚ K]
    (hζ : IsPrimitiveRoot ζ p) :
    hζ.subOneIntegralPowerBasis'.gen =
      ⟨ζ - 1, Subalgebra.sub_mem _ (hζ.IsIntegral p.Pos) (Subalgebra.one_mem _)⟩ :=
  @sub_one_integral_power_basis_gen p 1 K _ _ _ _
    (by
      convert hcycl
      rw [pow_one])
    (by rwa [pow_one])
#align
  is_primitive_root.sub_one_integral_power_basis'_gen IsPrimitiveRoot.sub_one_integral_power_basis'_gen

end IsPrimitiveRoot

end PowerBasis

