/-
Copyright (c) 2022 Adam Topaz. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Adam Topaz, Junyan Xu, Jack McKoen
-/
import Mathbin.RingTheory.Valuation.ValuationRing
import Mathbin.RingTheory.Localization.AsSubring
import Mathbin.RingTheory.Subring.Pointwise
import Mathbin.AlgebraicGeometry.PrimeSpectrum.Basic

/-!

# Valuation subrings of a field

## Projects

The order structure on `valuation_subring K`.

-/


open Classical

noncomputable section

variable (K : Type _) [Field K]

/-- A valuation subring of a field `K` is a subring `A` such that for every `x : K`,
either `x ∈ A` or `x⁻¹ ∈ A`. -/
structure ValuationSubring extends Subring K where
  mem_or_inv_mem' : ∀ x : K, x ∈ carrier ∨ x⁻¹ ∈ carrier
#align valuation_subring ValuationSubring

namespace ValuationSubring

variable {K} (A : ValuationSubring K)

instance : SetLike (ValuationSubring K) K where
  coe A := A.toSubring
  coe_injective' := by
    rintro ⟨⟨⟩⟩ ⟨⟨⟩⟩ _
    congr

@[simp]
theorem mem_carrier (x : K) : x ∈ A.carrier ↔ x ∈ A :=
  Iff.refl _
#align valuation_subring.mem_carrier ValuationSubring.mem_carrier

@[simp]
theorem mem_to_subring (x : K) : x ∈ A.toSubring ↔ x ∈ A :=
  Iff.refl _
#align valuation_subring.mem_to_subring ValuationSubring.mem_to_subring

@[ext.1]
theorem ext (A B : ValuationSubring K) (h : ∀ x, x ∈ A ↔ x ∈ B) : A = B :=
  SetLike.ext h
#align valuation_subring.ext ValuationSubring.ext

theorem zero_mem : (0 : K) ∈ A :=
  A.toSubring.zero_mem
#align valuation_subring.zero_mem ValuationSubring.zero_mem

theorem one_mem : (1 : K) ∈ A :=
  A.toSubring.one_mem
#align valuation_subring.one_mem ValuationSubring.one_mem

theorem add_mem (x y : K) : x ∈ A → y ∈ A → x + y ∈ A :=
  A.toSubring.add_mem
#align valuation_subring.add_mem ValuationSubring.add_mem

theorem mul_mem (x y : K) : x ∈ A → y ∈ A → x * y ∈ A :=
  A.toSubring.mul_mem
#align valuation_subring.mul_mem ValuationSubring.mul_mem

theorem neg_mem (x : K) : x ∈ A → -x ∈ A :=
  A.toSubring.neg_mem
#align valuation_subring.neg_mem ValuationSubring.neg_mem

theorem mem_or_inv_mem (x : K) : x ∈ A ∨ x⁻¹ ∈ A :=
  A.mem_or_inv_mem' _
#align valuation_subring.mem_or_inv_mem ValuationSubring.mem_or_inv_mem

theorem to_subring_injective : Function.Injective (toSubring : ValuationSubring K → Subring K) := fun x y h => by
  cases x
  cases y
  congr
#align valuation_subring.to_subring_injective ValuationSubring.to_subring_injective

instance : CommRing A :=
  show CommRing A.toSubring by infer_instance

instance : IsDomain A :=
  show IsDomain A.toSubring by infer_instance

instance : HasTop (ValuationSubring K) :=
  HasTop.mk <| { (⊤ : Subring K) with mem_or_inv_mem' := fun x => Or.inl trivial }

theorem mem_top (x : K) : x ∈ (⊤ : ValuationSubring K) :=
  trivial
#align valuation_subring.mem_top ValuationSubring.mem_top

theorem le_top : A ≤ ⊤ := fun a ha => mem_top _
#align valuation_subring.le_top ValuationSubring.le_top

instance : OrderTop (ValuationSubring K) where
  top := ⊤
  le_top := le_top

instance : Inhabited (ValuationSubring K) :=
  ⟨⊤⟩

instance :
    ValuationRing A where cond a b := by
    by_cases (b : K) = 0
    · use 0
      left
      ext
      simp [h]
      
    by_cases (a : K) = 0
    · use 0
      right
      ext
      simp [h]
      
    cases' A.mem_or_inv_mem (a / b) with hh hh
    · use ⟨a / b, hh⟩
      right
      ext
      field_simp
      ring
      
    · rw [show (a / b : K)⁻¹ = b / a by field_simp] at hh
      use ⟨b / a, hh⟩
      left
      ext
      field_simp
      ring
      

instance : Algebra A K :=
  show Algebra A.toSubring K by infer_instance

@[simp]
theorem algebra_map_apply (a : A) : algebraMap A K a = a :=
  rfl
#align valuation_subring.algebra_map_apply ValuationSubring.algebra_map_apply

instance : IsFractionRing A K where
  map_units := fun ⟨y, hy⟩ => (Units.mk0 (y : K) fun c => nonZeroDivisors.ne_zero hy <| Subtype.ext c).IsUnit
  surj z := by
    by_cases z = 0
    · use (0, 1)
      simp [h]
      
    cases' A.mem_or_inv_mem z with hh hh
    · use (⟨z, hh⟩, 1)
      simp
      
    · refine' ⟨⟨1, ⟨⟨_, hh⟩, _⟩⟩, mul_inv_cancel h⟩
      exact mem_non_zero_divisors_iff_ne_zero.2 fun c => h (inv_eq_zero.mp (congr_arg coe c))
      
  eq_iff_exists a b :=
    ⟨fun h =>
      ⟨1, by
        ext
        simpa using h⟩,
      fun ⟨c, h⟩ => congr_arg coe ((mul_eq_mul_right_iff.1 h).resolve_right (nonZeroDivisors.ne_zero c.2))⟩

/-- The value group of the valuation associated to `A`. Note: it is actually a group with zero. -/
def ValueGroup :=
  ValuationRing.ValueGroup A K deriving LinearOrderedCommGroupWithZero
#align valuation_subring.value_group ValuationSubring.ValueGroup

/-- Any valuation subring of `K` induces a natural valuation on `K`. -/
def valuation : Valuation K A.ValueGroup :=
  ValuationRing.valuation A K
#align valuation_subring.valuation ValuationSubring.valuation

instance inhabitedValueGroup : Inhabited A.ValueGroup :=
  ⟨A.Valuation 0⟩
#align valuation_subring.inhabited_value_group ValuationSubring.inhabitedValueGroup

theorem valuation_le_one (a : A) : A.Valuation a ≤ 1 :=
  (ValuationRing.mem_integer_iff A K _).2 ⟨a, rfl⟩
#align valuation_subring.valuation_le_one ValuationSubring.valuation_le_one

theorem mem_of_valuation_le_one (x : K) (h : A.Valuation x ≤ 1) : x ∈ A :=
  let ⟨a, ha⟩ := (ValuationRing.mem_integer_iff A K x).1 h
  ha ▸ a.2
#align valuation_subring.mem_of_valuation_le_one ValuationSubring.mem_of_valuation_le_one

theorem valuation_le_one_iff (x : K) : A.Valuation x ≤ 1 ↔ x ∈ A :=
  ⟨mem_of_valuation_le_one _ _, fun ha => A.valuation_le_one ⟨x, ha⟩⟩
#align valuation_subring.valuation_le_one_iff ValuationSubring.valuation_le_one_iff

theorem valuation_eq_iff (x y : K) : A.Valuation x = A.Valuation y ↔ ∃ a : Aˣ, (a : K) * y = x :=
  Quotient.eq'
#align valuation_subring.valuation_eq_iff ValuationSubring.valuation_eq_iff

theorem valuation_le_iff (x y : K) : A.Valuation x ≤ A.Valuation y ↔ ∃ a : A, (a : K) * y = x :=
  Iff.rfl
#align valuation_subring.valuation_le_iff ValuationSubring.valuation_le_iff

theorem valuation_surjective : Function.Surjective A.Valuation :=
  surjective_quot_mk _
#align valuation_subring.valuation_surjective ValuationSubring.valuation_surjective

theorem valuation_unit (a : Aˣ) : A.Valuation a = 1 := by
  rw [← A.valuation.map_one, valuation_eq_iff]
  use a
  simp
#align valuation_subring.valuation_unit ValuationSubring.valuation_unit

theorem valuation_eq_one_iff (a : A) : IsUnit a ↔ A.Valuation a = 1 :=
  ⟨fun h => A.valuation_unit h.Unit, fun h => by
    have ha : (a : K) ≠ 0 := by
      intro c
      rw [c, A.valuation.map_zero] at h
      exact zero_ne_one h
    have ha' : (a : K)⁻¹ ∈ A := by rw [← valuation_le_one_iff, map_inv₀, h, inv_one]
    apply is_unit_of_mul_eq_one a ⟨a⁻¹, ha'⟩
    ext
    field_simp⟩
#align valuation_subring.valuation_eq_one_iff ValuationSubring.valuation_eq_one_iff

theorem valuation_lt_one_or_eq_one (a : A) : A.Valuation a < 1 ∨ A.Valuation a = 1 :=
  lt_or_eq_of_le (A.valuation_le_one a)
#align valuation_subring.valuation_lt_one_or_eq_one ValuationSubring.valuation_lt_one_or_eq_one

theorem valuation_lt_one_iff (a : A) : a ∈ LocalRing.maximalIdeal A ↔ A.Valuation a < 1 := by
  rw [LocalRing.mem_maximal_ideal]
  dsimp [nonunits]
  rw [valuation_eq_one_iff]
  exact (A.valuation_le_one a).lt_iff_ne.symm
#align valuation_subring.valuation_lt_one_iff ValuationSubring.valuation_lt_one_iff

/-- A subring `R` of `K` such that for all `x : K` either `x ∈ R` or `x⁻¹ ∈ R` is
  a valuation subring of `K`. -/
def ofSubring (R : Subring K) (hR : ∀ x : K, x ∈ R ∨ x⁻¹ ∈ R) : ValuationSubring K :=
  { R with mem_or_inv_mem' := hR }
#align valuation_subring.of_subring ValuationSubring.ofSubring

@[simp]
theorem mem_of_subring (R : Subring K) (hR : ∀ x : K, x ∈ R ∨ x⁻¹ ∈ R) (x : K) : x ∈ ofSubring R hR ↔ x ∈ R :=
  Iff.refl _
#align valuation_subring.mem_of_subring ValuationSubring.mem_of_subring

/-- An overring of a valuation ring is a valuation ring. -/
def ofLe (R : ValuationSubring K) (S : Subring K) (h : R.toSubring ≤ S) : ValuationSubring K :=
  { S with mem_or_inv_mem' := fun x => (R.mem_or_inv_mem x).imp (@h x) (@h _) }
#align valuation_subring.of_le ValuationSubring.ofLe

section Order

instance : SemilatticeSup (ValuationSubring K) :=
  { (inferInstance : PartialOrder (ValuationSubring K)) with
    sup := fun R S => ofLe R (R.toSubring ⊔ S.toSubring) <| le_sup_left,
    le_sup_left := fun R S x hx => (le_sup_left : R.toSubring ≤ R.toSubring ⊔ S.toSubring) hx,
    le_sup_right := fun R S x hx => (le_sup_right : S.toSubring ≤ R.toSubring ⊔ S.toSubring) hx,
    sup_le := fun R S T hR hT x hx => (sup_le hR hT : R.toSubring ⊔ S.toSubring ≤ T.toSubring) hx }

/-- The ring homomorphism induced by the partial order. -/
def inclusion (R S : ValuationSubring K) (h : R ≤ S) : R →+* S :=
  Subring.inclusion h
#align valuation_subring.inclusion ValuationSubring.inclusion

/-- The canonical ring homomorphism from a valuation ring to its field of fractions. -/
def subtype (R : ValuationSubring K) : R →+* K :=
  Subring.subtype R.toSubring
#align valuation_subring.subtype ValuationSubring.subtype

/-- The canonical map on value groups induced by a coarsening of valuation rings. -/
def mapOfLe (R S : ValuationSubring K) (h : R ≤ S) : R.ValueGroup →*₀ S.ValueGroup where
  toFun := (Quotient.map' id) fun x y ⟨u, hu⟩ => ⟨Units.map (R.inclusion S h).toMonoidHom u, hu⟩
  map_zero' := rfl
  map_one' := rfl
  map_mul' := by
    rintro ⟨⟩ ⟨⟩
    rfl
#align valuation_subring.map_of_le ValuationSubring.mapOfLe

@[mono]
theorem monotone_map_of_le (R S : ValuationSubring K) (h : R ≤ S) : Monotone (R.mapOfLe S h) := by
  rintro ⟨⟩ ⟨⟩ ⟨a, ha⟩
  exact ⟨R.inclusion S h a, ha⟩
#align valuation_subring.monotone_map_of_le ValuationSubring.monotone_map_of_le

@[simp]
theorem map_of_le_comp_valuation (R S : ValuationSubring K) (h : R ≤ S) : R.mapOfLe S h ∘ R.Valuation = S.Valuation :=
  by
  ext
  rfl
#align valuation_subring.map_of_le_comp_valuation ValuationSubring.map_of_le_comp_valuation

@[simp]
theorem map_of_le_valuation_apply (R S : ValuationSubring K) (h : R ≤ S) (x : K) :
    R.mapOfLe S h (R.Valuation x) = S.Valuation x :=
  rfl
#align valuation_subring.map_of_le_valuation_apply ValuationSubring.map_of_le_valuation_apply

/-- The ideal corresponding to a coarsening of a valuation ring. -/
def idealOfLe (R S : ValuationSubring K) (h : R ≤ S) : Ideal R :=
  (LocalRing.maximalIdeal S).comap (R.inclusion S h)
#align valuation_subring.ideal_of_le ValuationSubring.idealOfLe

instance prime_ideal_of_le (R S : ValuationSubring K) (h : R ≤ S) : (idealOfLe R S h).IsPrime :=
  (LocalRing.maximalIdeal S).comap_is_prime _
#align valuation_subring.prime_ideal_of_le ValuationSubring.prime_ideal_of_le

/-- The coarsening of a valuation ring associated to a prime ideal. -/
def ofPrime (A : ValuationSubring K) (P : Ideal A) [P.IsPrime] : ValuationSubring K :=
  (ofLe A (Localization.subalgebra.ofField K _ P.prime_compl_le_non_zero_divisors).toSubring) fun a ha =>
    Subalgebra.algebra_map_mem _ (⟨a, ha⟩ : A)
#align valuation_subring.of_prime ValuationSubring.ofPrime

instance ofPrimeAlgebra (A : ValuationSubring K) (P : Ideal A) [P.IsPrime] : Algebra A (A.ofPrime P) :=
  Subalgebra.algebra _
#align valuation_subring.of_prime_algebra ValuationSubring.ofPrimeAlgebra

instance of_prime_scalar_tower (A : ValuationSubring K) (P : Ideal A) [P.IsPrime] : IsScalarTower A (A.ofPrime P) K :=
  IsScalarTower.subalgebra' A K K _
#align valuation_subring.of_prime_scalar_tower ValuationSubring.of_prime_scalar_tower

instance of_prime_localization (A : ValuationSubring K) (P : Ideal A) [P.IsPrime] :
    IsLocalization.AtPrime (A.ofPrime P) P := by apply Localization.subalgebra.is_localization_of_field K
#align valuation_subring.of_prime_localization ValuationSubring.of_prime_localization

theorem le_of_prime (A : ValuationSubring K) (P : Ideal A) [P.IsPrime] : A ≤ ofPrime A P := fun a ha =>
  Subalgebra.algebra_map_mem _ (⟨a, ha⟩ : A)
#align valuation_subring.le_of_prime ValuationSubring.le_of_prime

theorem of_prime_valuation_eq_one_iff_mem_prime_compl (A : ValuationSubring K) (P : Ideal A) [P.IsPrime] (x : A) :
    (ofPrime A P).Valuation x = 1 ↔ x ∈ P.primeCompl := by
  rw [← IsLocalization.AtPrime.is_unit_to_map_iff (A.of_prime P) P x, valuation_eq_one_iff]
  rfl
#align
  valuation_subring.of_prime_valuation_eq_one_iff_mem_prime_compl ValuationSubring.of_prime_valuation_eq_one_iff_mem_prime_compl

@[simp]
theorem ideal_of_le_of_prime (A : ValuationSubring K) (P : Ideal A) [P.IsPrime] :
    idealOfLe A (ofPrime A P) (le_of_prime A P) = P := by
  ext
  apply IsLocalization.AtPrime.to_map_mem_maximal_iff
#align valuation_subring.ideal_of_le_of_prime ValuationSubring.ideal_of_le_of_prime

@[simp]
theorem of_prime_ideal_of_le (R S : ValuationSubring K) (h : R ≤ S) : ofPrime R (idealOfLe R S h) = S := by
  ext x
  constructor
  · rintro ⟨a, r, hr, rfl⟩
    apply mul_mem
    · exact h a.2
      
    · rw [← valuation_le_one_iff, map_inv₀, ← inv_one, inv_le_inv₀]
      · exact not_lt.1 ((not_iff_not.2 <| valuation_lt_one_iff S _).1 hr)
        
      · intro hh
        erw [Valuation.zero_iff, Subring.coe_eq_zero_iff] at hh
        apply hr
        rw [hh]
        apply Ideal.zero_mem (R.ideal_of_le S h)
        
      · exact one_ne_zero
        
      
    
  · intro hx
    by_cases hr : x ∈ R
    · exact R.le_of_prime _ hr
      
    have : x ≠ 0 := fun h =>
      hr
        (by
          rw [h]
          exact R.zero_mem)
    replace hr := (R.mem_or_inv_mem x).resolve_left hr
    · use 1, x⁻¹, hr
      constructor
      · change (⟨x⁻¹, h hr⟩ : S) ∉ nonunits S
        erw [mem_nonunits_iff, not_not]
        apply is_unit_of_mul_eq_one _ (⟨x, hx⟩ : S)
        ext
        field_simp
        
      · field_simp
        
      
    
#align valuation_subring.of_prime_ideal_of_le ValuationSubring.of_prime_ideal_of_le

theorem of_prime_le_of_le (P Q : Ideal A) [P.IsPrime] [Q.IsPrime] (h : P ≤ Q) : ofPrime A Q ≤ ofPrime A P :=
  fun x ⟨a, s, hs, he⟩ => ⟨a, s, fun c => hs (h c), he⟩
#align valuation_subring.of_prime_le_of_le ValuationSubring.of_prime_le_of_le

theorem ideal_of_le_le_of_le (R S : ValuationSubring K) (hR : A ≤ R) (hS : A ≤ S) (h : R ≤ S) :
    idealOfLe A S hS ≤ idealOfLe A R hR := fun x hx =>
  (valuation_lt_one_iff R _).2
    (by
      by_contra c
      push_neg  at c
      replace c := monotone_map_of_le R S h c
      rw [(map_of_le _ _ _).map_one, map_of_le_valuation_apply] at c
      apply not_le_of_lt ((valuation_lt_one_iff S _).1 hx) c)
#align valuation_subring.ideal_of_le_le_of_le ValuationSubring.ideal_of_le_le_of_le

/-- The equivalence between coarsenings of a valuation ring and its prime ideals.-/
@[simps]
def primeSpectrumEquiv : PrimeSpectrum A ≃ { S | A ≤ S } where
  toFun P := ⟨ofPrime A P.asIdeal, le_of_prime _ _⟩
  invFun S := ⟨idealOfLe _ S S.2, inferInstance⟩
  left_inv P := by
    ext1
    simpa
  right_inv S := by
    ext1
    simp
#align valuation_subring.prime_spectrum_equiv ValuationSubring.primeSpectrumEquiv

/-- An ordered variant of `prime_spectrum_equiv`. -/
@[simps]
def primeSpectrumOrderEquiv : (PrimeSpectrum A)ᵒᵈ ≃o { S | A ≤ S } :=
  { primeSpectrumEquiv A with
    map_rel_iff' := fun P Q =>
      ⟨fun h => by
        have := ideal_of_le_le_of_le A _ _ _ _ h
        iterate 2 erw [ideal_of_le_of_prime] at this
        exact this, fun h => by
        apply of_prime_le_of_le
        exact h⟩ }
#align valuation_subring.prime_spectrum_order_equiv ValuationSubring.primeSpectrumOrderEquiv

instance linearOrderOverring : LinearOrder { S | A ≤ S } :=
  { (inferInstance : PartialOrder _) with
    le_total :=
      let i : IsTotal (PrimeSpectrum A) (· ≤ ·) := (Subtype.relEmbedding _ _).IsTotal
      (prime_spectrum_order_equiv A).symm.toRelEmbedding.IsTotal.Total,
    decidableLe := inferInstance }
#align valuation_subring.linear_order_overring ValuationSubring.linearOrderOverring

end Order

end ValuationSubring

namespace Valuation

variable {K} {Γ Γ₁ Γ₂ : Type _} [LinearOrderedCommGroupWithZero Γ] [LinearOrderedCommGroupWithZero Γ₁]
  [LinearOrderedCommGroupWithZero Γ₂] (v : Valuation K Γ) (v₁ : Valuation K Γ₁) (v₂ : Valuation K Γ₂)

/-- The valuation subring associated to a valuation. -/
def valuationSubring : ValuationSubring K :=
  { v.integer with
    mem_or_inv_mem' := by
      intro x
      cases le_or_lt (v x) 1
      · left
        exact h
        
      · right
        change v x⁻¹ ≤ 1
        rw [map_inv₀ v, ← inv_one, inv_le_inv₀]
        · exact le_of_lt h
          
        · intro c
          simpa [c] using h
          
        · exact one_ne_zero
          
         }
#align valuation.valuation_subring Valuation.valuationSubring

@[simp]
theorem mem_valuation_subring_iff (x : K) : x ∈ v.ValuationSubring ↔ v x ≤ 1 :=
  Iff.refl _
#align valuation.mem_valuation_subring_iff Valuation.mem_valuation_subring_iff

theorem is_equiv_iff_valuation_subring : v₁.IsEquiv v₂ ↔ v₁.ValuationSubring = v₂.ValuationSubring := by
  constructor
  · intro h
    ext x
    specialize h x 1
    simpa using h
    
  · intro h
    apply is_equiv_of_val_le_one
    intro x
    have : x ∈ v₁.valuation_subring ↔ x ∈ v₂.valuation_subring := by rw [h]
    simpa using this
    
#align valuation.is_equiv_iff_valuation_subring Valuation.is_equiv_iff_valuation_subring

theorem isEquivValuationValuationSubring : v.IsEquiv v.ValuationSubring.Valuation := by
  rw [is_equiv_iff_val_le_one]
  intro x
  rw [ValuationSubring.valuation_le_one_iff]
  rfl
#align valuation.is_equiv_valuation_valuation_subring Valuation.isEquivValuationValuationSubring

end Valuation

namespace ValuationSubring

variable {K} (A : ValuationSubring K)

@[simp]
theorem valuation_subring_valuation : A.Valuation.ValuationSubring = A := by
  ext
  rw [← A.valuation_le_one_iff]
  rfl
#align valuation_subring.valuation_subring_valuation ValuationSubring.valuation_subring_valuation

section UnitGroup

/-- The unit group of a valuation subring, as a subgroup of `Kˣ`. -/
def unitGroup : Subgroup Kˣ :=
  (A.Valuation.toMonoidWithZeroHom.toMonoidHom.comp (Units.coeHom K)).ker
#align valuation_subring.unit_group ValuationSubring.unitGroup

@[simp]
theorem mem_unit_group_iff (x : Kˣ) : x ∈ A.unitGroup ↔ A.Valuation x = 1 :=
  Iff.rfl
#align valuation_subring.mem_unit_group_iff ValuationSubring.mem_unit_group_iff

/-- For a valuation subring `A`, `A.unit_group` agrees with the units of `A`. -/
def unitGroupMulEquiv : A.unitGroup ≃* Aˣ where
  toFun x :=
    { val := ⟨x, mem_of_valuation_le_one A _ x.Prop.le⟩, inv := ⟨↑x⁻¹, mem_of_valuation_le_one _ _ x⁻¹.Prop.le⟩,
      val_inv := Subtype.ext (Units.mul_inv x), inv_val := Subtype.ext (Units.inv_mul x) }
  invFun x := ⟨Units.map A.Subtype.toMonoidHom x, A.valuation_unit x⟩
  left_inv a := by
    ext
    rfl
  right_inv a := by
    ext
    rfl
  map_mul' a b := by
    ext
    rfl
#align valuation_subring.unit_group_mul_equiv ValuationSubring.unitGroupMulEquiv

@[simp]
theorem coe_unit_group_mul_equiv_apply (a : A.unitGroup) : (A.unitGroupMulEquiv a : K) = a :=
  rfl
#align valuation_subring.coe_unit_group_mul_equiv_apply ValuationSubring.coe_unit_group_mul_equiv_apply

@[simp]
theorem coe_unit_group_mul_equiv_symm_apply (a : Aˣ) : (A.unitGroupMulEquiv.symm a : K) = a :=
  rfl
#align valuation_subring.coe_unit_group_mul_equiv_symm_apply ValuationSubring.coe_unit_group_mul_equiv_symm_apply

theorem unit_group_le_unit_group {A B : ValuationSubring K} : A.unitGroup ≤ B.unitGroup ↔ A ≤ B := by
  constructor
  · intro h x hx
    rw [← A.valuation_le_one_iff x, le_iff_lt_or_eq] at hx
    by_cases h_1 : x = 0
    · simp only [h_1, zero_mem]
      
    by_cases h_2 : 1 + x = 0
    · simp only [← add_eq_zero_iff_neg_eq.1 h_2, neg_mem _ _ (one_mem _)]
      
    cases hx
    · have := h (show Units.mk0 _ h_2 ∈ A.unit_group from A.valuation.map_one_add_of_lt hx)
      simpa using
        B.add_mem _ _ (show 1 + x ∈ B from SetLike.coe_mem (B.unit_group_mul_equiv ⟨_, this⟩ : B))
          (B.neg_mem _ B.one_mem)
      
    · have := h (show Units.mk0 x h_1 ∈ A.unit_group from hx)
      refine' SetLike.coe_mem (B.unit_group_mul_equiv ⟨_, this⟩ : B)
      
    
  · rintro h x (hx : A.valuation x = 1)
    apply_fun A.map_of_le B h  at hx
    simpa using hx
    
#align valuation_subring.unit_group_le_unit_group ValuationSubring.unit_group_le_unit_group

theorem unit_group_injective : Function.Injective (unitGroup : ValuationSubring K → Subgroup _) := fun A B h => by
  simpa only [le_antisymm_iff, unit_group_le_unit_group] using h
#align valuation_subring.unit_group_injective ValuationSubring.unit_group_injective

theorem eq_iff_unit_group {A B : ValuationSubring K} : A = B ↔ A.unitGroup = B.unitGroup :=
  unit_group_injective.eq_iff.symm
#align valuation_subring.eq_iff_unit_group ValuationSubring.eq_iff_unit_group

/-- The map on valuation subrings to their unit groups is an order embedding. -/
def unitGroupOrderEmbedding : ValuationSubring K ↪o Subgroup Kˣ where
  toFun A := A.unitGroup
  inj' := unit_group_injective
  map_rel_iff' A B := unit_group_le_unit_group
#align valuation_subring.unit_group_order_embedding ValuationSubring.unitGroupOrderEmbedding

theorem unit_group_strict_mono : StrictMono (unitGroup : ValuationSubring K → Subgroup _) :=
  unitGroupOrderEmbedding.StrictMono
#align valuation_subring.unit_group_strict_mono ValuationSubring.unit_group_strict_mono

end UnitGroup

section nonunits

/-- The nonunits of a valuation subring of `K`, as a subsemigroup of `K`-/
def nonunits : Subsemigroup K where
  carrier := { x | A.Valuation x < 1 }
  mul_mem' a b ha hb := (mul_lt_mul₀ ha hb).trans_eq <| mul_one _
#align valuation_subring.nonunits ValuationSubring.nonunits

theorem mem_nonunits_iff {x : K} : x ∈ A.nonunits ↔ A.Valuation x < 1 :=
  Iff.rfl
#align valuation_subring.mem_nonunits_iff ValuationSubring.mem_nonunits_iff

theorem nonunits_le_nonunits {A B : ValuationSubring K} : B.nonunits ≤ A.nonunits ↔ A ≤ B := by
  constructor
  · intro h x hx
    by_cases h_1 : x = 0
    · simp only [h_1, zero_mem]
      
    rw [← valuation_le_one_iff, ← not_lt, Valuation.one_lt_val_iff _ h_1] at hx⊢
    by_contra h_2
    exact hx (h h_2)
    
  · intro h x hx
    by_contra h_1
    exact not_lt.2 (monotone_map_of_le _ _ h (not_lt.1 h_1)) hx
    
#align valuation_subring.nonunits_le_nonunits ValuationSubring.nonunits_le_nonunits

theorem nonunits_injective : Function.Injective (nonunits : ValuationSubring K → Subsemigroup _) := fun A B h => by
  simpa only [le_antisymm_iff, nonunits_le_nonunits] using h.symm
#align valuation_subring.nonunits_injective ValuationSubring.nonunits_injective

theorem nonunits_inj {A B : ValuationSubring K} : A.nonunits = B.nonunits ↔ A = B :=
  nonunits_injective.eq_iff
#align valuation_subring.nonunits_inj ValuationSubring.nonunits_inj

/-- The map on valuation subrings to their nonunits is a dual order embedding. -/
def nonunitsOrderEmbedding : ValuationSubring K ↪o (Subsemigroup K)ᵒᵈ where
  toFun A := A.nonunits
  inj' := nonunits_injective
  map_rel_iff' A B := nonunits_le_nonunits
#align valuation_subring.nonunits_order_embedding ValuationSubring.nonunitsOrderEmbedding

variable {A}

/-- The elements of `A.nonunits` are those of the maximal ideal of `A` after coercion to `K`.

See also `mem_nonunits_iff_exists_mem_maximal_ideal`, which gets rid of the coercion to `K`,
at the expense of a more complicated right hand side.
 -/
theorem coe_mem_nonunits_iff {a : A} : (a : K) ∈ A.nonunits ↔ a ∈ LocalRing.maximalIdeal A :=
  (valuation_lt_one_iff _ _).symm
#align valuation_subring.coe_mem_nonunits_iff ValuationSubring.coe_mem_nonunits_iff

theorem nonunits_le : A.nonunits ≤ A.toSubring.toSubmonoid.toSubsemigroup := fun a ha =>
  (A.valuation_le_one_iff _).mp (A.mem_nonunits_iff.mp ha).le
#align valuation_subring.nonunits_le ValuationSubring.nonunits_le

theorem nonunits_subset : (A.nonunits : Set K) ⊆ A :=
  nonunits_le
#align valuation_subring.nonunits_subset ValuationSubring.nonunits_subset

/-- The elements of `A.nonunits` are those of the maximal ideal of `A`.

See also `coe_mem_nonunits_iff`, which has a simpler right hand side but requires the element
to be in `A` already.
 -/
theorem mem_nonunits_iff_exists_mem_maximal_ideal {a : K} :
    a ∈ A.nonunits ↔ ∃ ha, (⟨a, ha⟩ : A) ∈ LocalRing.maximalIdeal A :=
  ⟨fun h => ⟨nonunits_subset h, coe_mem_nonunits_iff.mp h⟩, fun ⟨ha, h⟩ => coe_mem_nonunits_iff.mpr h⟩
#align
  valuation_subring.mem_nonunits_iff_exists_mem_maximal_ideal ValuationSubring.mem_nonunits_iff_exists_mem_maximal_ideal

/-- `A.nonunits` agrees with the maximal ideal of `A`, after taking its image in `K`. -/
theorem image_maximal_ideal : (coe : A → K) '' LocalRing.maximalIdeal A = A.nonunits := by
  ext a
  simp only [Set.mem_image, SetLike.mem_coe, mem_nonunits_iff_exists_mem_maximal_ideal]
  erw [Subtype.exists]
  simp_rw [Subtype.coe_mk, exists_and_right, exists_eq_right]
#align valuation_subring.image_maximal_ideal ValuationSubring.image_maximal_ideal

end nonunits

section PrincipalUnitGroup

/-- The principal unit group of a valuation subring, as a subgroup of `Kˣ`. -/
def principalUnitGroup : Subgroup Kˣ where
  carrier := { x | A.Valuation (x - 1) < 1 }
  mul_mem' := by
    intro a b ha hb
    refine' lt_of_le_of_lt _ (max_lt hb ha)
    rw [← one_mul (A.valuation (b - 1)), ← A.valuation.map_one_add_of_lt ha, add_sub_cancel'_right, ← Valuation.map_mul,
      mul_sub_one, ← sub_add_sub_cancel]
    exact A.valuation.map_add _ _
  one_mem' := by simpa using zero_lt_one₀
  inv_mem' := by
    dsimp
    intro a ha
    conv =>
    lhs
    rw [← mul_one (A.valuation _), ← A.valuation.map_one_add_of_lt ha]
    rwa [add_sub_cancel'_right, ← Valuation.map_mul, sub_mul, Units.inv_mul, ← neg_sub, one_mul, Valuation.map_neg]
#align valuation_subring.principal_unit_group ValuationSubring.principalUnitGroup

theorem principal_units_le_units : A.principalUnitGroup ≤ A.unitGroup := fun a h => by
  simpa only [add_sub_cancel'_right] using A.valuation.map_one_add_of_lt h
#align valuation_subring.principal_units_le_units ValuationSubring.principal_units_le_units

theorem mem_principal_unit_group_iff (x : Kˣ) : x ∈ A.principalUnitGroup ↔ A.Valuation ((x : K) - 1) < 1 :=
  Iff.rfl
#align valuation_subring.mem_principal_unit_group_iff ValuationSubring.mem_principal_unit_group_iff

theorem principal_unit_group_le_principal_unit_group {A B : ValuationSubring K} :
    B.principalUnitGroup ≤ A.principalUnitGroup ↔ A ≤ B := by
  constructor
  · intro h x hx
    by_cases h_1 : x = 0
    · simp only [h_1, zero_mem]
      
    by_cases h_2 : x⁻¹ + 1 = 0
    · rw [add_eq_zero_iff_eq_neg, inv_eq_iff_inv_eq, inv_neg, inv_one] at h_2
      simpa only [h_2] using B.neg_mem _ B.one_mem
      
    · rw [← valuation_le_one_iff, ← not_lt, Valuation.one_lt_val_iff _ h_1, ← add_sub_cancel x⁻¹, ← Units.coe_mk0 h_2, ←
        mem_principal_unit_group_iff] at hx⊢
      simpa only [hx] using @h (Units.mk0 (x⁻¹ + 1) h_2)
      
    
  · intro h x hx
    by_contra h_1
    exact not_lt.2 (monotone_map_of_le _ _ h (not_lt.1 h_1)) hx
    
#align
  valuation_subring.principal_unit_group_le_principal_unit_group ValuationSubring.principal_unit_group_le_principal_unit_group

theorem principal_unit_group_injective : Function.Injective (principalUnitGroup : ValuationSubring K → Subgroup _) :=
  fun A B h => by simpa [le_antisymm_iff, principal_unit_group_le_principal_unit_group] using h.symm
#align valuation_subring.principal_unit_group_injective ValuationSubring.principal_unit_group_injective

theorem eq_iff_principal_unit_group {A B : ValuationSubring K} : A = B ↔ A.principalUnitGroup = B.principalUnitGroup :=
  principal_unit_group_injective.eq_iff.symm
#align valuation_subring.eq_iff_principal_unit_group ValuationSubring.eq_iff_principal_unit_group

/-- The map on valuation subrings to their principal unit groups is an order embedding. -/
def principalUnitGroupOrderEmbedding : ValuationSubring K ↪o (Subgroup Kˣ)ᵒᵈ where
  toFun A := A.principalUnitGroup
  inj' := principal_unit_group_injective
  map_rel_iff' A B := principal_unit_group_le_principal_unit_group
#align valuation_subring.principal_unit_group_order_embedding ValuationSubring.principalUnitGroupOrderEmbedding

theorem coe_mem_principal_unit_group_iff {x : A.unitGroup} :
    (x : Kˣ) ∈ A.principalUnitGroup ↔ A.unitGroupMulEquiv x ∈ (Units.map (LocalRing.residue A).toMonoidHom).ker := by
  rw [MonoidHom.mem_ker, Units.ext_iff]
  dsimp
  let π := Ideal.Quotient.mk (LocalRing.maximalIdeal A)
  change _ ↔ π _ = _
  rw [← π.map_one, ← sub_eq_zero, ← π.map_sub, Ideal.Quotient.eq_zero_iff_mem, valuation_lt_one_iff]
  simpa
#align valuation_subring.coe_mem_principal_unit_group_iff ValuationSubring.coe_mem_principal_unit_group_iff

/-- The principal unit group agrees with the kernel of the canonical map from
the units of `A` to the units of the residue field of `A`. -/
def principalUnitGroupEquiv : A.principalUnitGroup ≃* (Units.map (LocalRing.residue A).toMonoidHom).ker where
  toFun x := ⟨A.unitGroupMulEquiv ⟨_, A.principal_units_le_units x.2⟩, A.coe_mem_principal_unit_group_iff.1 x.2⟩
  invFun x :=
    ⟨A.unitGroupMulEquiv.symm x, by
      rw [A.coe_mem_principal_unit_group_iff]
      simpa using SetLike.coe_mem x⟩
  left_inv x := by simp
  right_inv x := by simp
  map_mul' x y := by rfl
#align valuation_subring.principal_unit_group_equiv ValuationSubring.principalUnitGroupEquiv

@[simp]
theorem principal_unit_group_equiv_apply (a : A.principalUnitGroup) : (principalUnitGroupEquiv A a : K) = a :=
  rfl
#align valuation_subring.principal_unit_group_equiv_apply ValuationSubring.principal_unit_group_equiv_apply

@[simp]
theorem principal_unit_group_symm_apply (a : (Units.map (LocalRing.residue A).toMonoidHom).ker) :
    (A.principalUnitGroupEquiv.symm a : K) = a :=
  rfl
#align valuation_subring.principal_unit_group_symm_apply ValuationSubring.principal_unit_group_symm_apply

/-- The canonical map from the unit group of `A` to the units of the residue field of `A`. -/
def unitGroupToResidueFieldUnits : A.unitGroup →* (LocalRing.ResidueField A)ˣ :=
  MonoidHom.comp (Units.map <| (Ideal.Quotient.mk _).toMonoidHom) A.unitGroupMulEquiv.toMonoidHom
#align valuation_subring.unit_group_to_residue_field_units ValuationSubring.unitGroupToResidueFieldUnits

@[simp]
theorem coe_unit_group_to_residue_field_units_apply (x : A.unitGroup) :
    (A.unitGroupToResidueFieldUnits x : LocalRing.ResidueField A) = Ideal.Quotient.mk _ (A.unitGroupMulEquiv x : A) :=
  rfl
#align
  valuation_subring.coe_unit_group_to_residue_field_units_apply ValuationSubring.coe_unit_group_to_residue_field_units_apply

theorem ker_unit_group_to_residue_field_units :
    A.unitGroupToResidueFieldUnits.ker = A.principalUnitGroup.comap A.unitGroup.Subtype := by
  ext
  simpa only [Subgroup.mem_comap, Subgroup.coe_subtype, coe_mem_principal_unit_group_iff]
#align valuation_subring.ker_unit_group_to_residue_field_units ValuationSubring.ker_unit_group_to_residue_field_units

theorem surjective_unit_group_to_residue_field_units : Function.Surjective A.unitGroupToResidueFieldUnits :=
  (LocalRing.surjective_units_map_of_local_ring_hom _ Ideal.Quotient.mk_surjective
        LocalRing.is_local_ring_hom_residue).comp
    (MulEquiv.surjective _)
#align
  valuation_subring.surjective_unit_group_to_residue_field_units ValuationSubring.surjective_unit_group_to_residue_field_units

/-- The quotient of the unit group of `A` by the principal unit group of `A` agrees with
the units of the residue field of `A`. -/
def unitsModPrincipalUnitsEquivResidueFieldUnits :
    A.unitGroup ⧸ A.principalUnitGroup.comap A.unitGroup.Subtype ≃* (LocalRing.ResidueField A)ˣ :=
  (QuotientGroup.quotientMulEquivOfEq A.ker_unit_group_to_residue_field_units.symm).trans
    (QuotientGroup.quotientKerEquivOfSurjective _ A.surjective_unit_group_to_residue_field_units)
#align
  valuation_subring.units_mod_principal_units_equiv_residue_field_units ValuationSubring.unitsModPrincipalUnitsEquivResidueFieldUnits

@[simp]
theorem units_mod_principal_units_equiv_residue_field_units_comp_quotient_group_mk :
    A.unitsModPrincipalUnitsEquivResidueFieldUnits.toMonoidHom.comp (QuotientGroup.mk' _) =
      A.unitGroupToResidueFieldUnits :=
  rfl
#align
  valuation_subring.units_mod_principal_units_equiv_residue_field_units_comp_quotient_group_mk ValuationSubring.units_mod_principal_units_equiv_residue_field_units_comp_quotient_group_mk

@[simp]
theorem units_mod_principal_units_equiv_residue_field_units_comp_quotient_group_mk_apply (x : A.unitGroup) :
    A.unitsModPrincipalUnitsEquivResidueFieldUnits.toMonoidHom (QuotientGroup.mk x) =
      A.unitGroupToResidueFieldUnits x :=
  rfl
#align
  valuation_subring.units_mod_principal_units_equiv_residue_field_units_comp_quotient_group_mk_apply ValuationSubring.units_mod_principal_units_equiv_residue_field_units_comp_quotient_group_mk_apply

end PrincipalUnitGroup

/-! ### Pointwise actions

This transfers the action from `subring.pointwise_mul_action`, noting that it only applies when
the action is by a group. Notably this provides an instances when `G` is `K ≃+* K`.

These instances are in the `pointwise` locale.

The lemmas in this section are copied from `ring_theory/subring/pointwise.lean`; try to keep these
in sync.
-/


section PointwiseActions

open Pointwise

variable {G : Type _} [Group G] [MulSemiringAction G K]

/-- The action on a valuation subring corresponding to applying the action to every element.

This is available as an instance in the `pointwise` locale. -/
def pointwiseHasSmul :
    HasSmul G
      (ValuationSubring
        K) where smul g
    S :=-- TODO: if we add `valuation_subring.map` at a later date, we should use it here
    { g • S.toSubring with
      mem_or_inv_mem' := fun x =>
        (mem_or_inv_mem S (g⁻¹ • x)).imp Subring.mem_pointwise_smul_iff_inv_smul_mem.mpr fun h =>
          Subring.mem_pointwise_smul_iff_inv_smul_mem.mpr <| by rwa [smul_inv''] }
#align valuation_subring.pointwise_has_smul ValuationSubring.pointwiseHasSmul

scoped[Pointwise] attribute [instance] ValuationSubring.pointwiseHasSmul

open Pointwise

@[simp]
theorem coe_pointwise_smul (g : G) (S : ValuationSubring K) : ↑(g • S) = g • (S : Set K) :=
  rfl
#align valuation_subring.coe_pointwise_smul ValuationSubring.coe_pointwise_smul

@[simp]
theorem pointwise_smul_to_subring (g : G) (S : ValuationSubring K) : (g • S).toSubring = g • S.toSubring :=
  rfl
#align valuation_subring.pointwise_smul_to_subring ValuationSubring.pointwise_smul_to_subring

/-- The action on a valuation subring corresponding to applying the action to every element.

This is available as an instance in the `pointwise` locale.

This is a stronger version of `valuation_subring.pointwise_has_smul`. -/
def pointwiseMulAction : MulAction G (ValuationSubring K) :=
  to_subring_injective.MulAction toSubring pointwise_smul_to_subring
#align valuation_subring.pointwise_mul_action ValuationSubring.pointwiseMulAction

scoped[Pointwise] attribute [instance] ValuationSubring.pointwiseMulAction

open Pointwise

theorem smul_mem_pointwise_smul (g : G) (x : K) (S : ValuationSubring K) : x ∈ S → g • x ∈ g • S :=
  (Set.smul_mem_smul_set : _ → _ ∈ g • (S : Set K))
#align valuation_subring.smul_mem_pointwise_smul ValuationSubring.smul_mem_pointwise_smul

theorem mem_smul_pointwise_iff_exists (g : G) (x : K) (S : ValuationSubring K) :
    x ∈ g • S ↔ ∃ s : K, s ∈ S ∧ g • s = x :=
  (Set.mem_smul_set : x ∈ g • (S : Set K) ↔ _)
#align valuation_subring.mem_smul_pointwise_iff_exists ValuationSubring.mem_smul_pointwise_iff_exists

instance pointwise_central_scalar [MulSemiringAction Gᵐᵒᵖ K] [IsCentralScalar G K] :
    IsCentralScalar G (ValuationSubring K) :=
  ⟨fun g S => to_subring_injective <| op_smul_eq_smul g S.to_subring⟩
#align valuation_subring.pointwise_central_scalar ValuationSubring.pointwise_central_scalar

@[simp]
theorem smul_mem_pointwise_smul_iff {g : G} {S : ValuationSubring K} {x : K} : g • x ∈ g • S ↔ x ∈ S :=
  Set.smul_mem_smul_set_iff
#align valuation_subring.smul_mem_pointwise_smul_iff ValuationSubring.smul_mem_pointwise_smul_iff

theorem mem_pointwise_smul_iff_inv_smul_mem {g : G} {S : ValuationSubring K} {x : K} : x ∈ g • S ↔ g⁻¹ • x ∈ S :=
  Set.mem_smul_set_iff_inv_smul_mem
#align valuation_subring.mem_pointwise_smul_iff_inv_smul_mem ValuationSubring.mem_pointwise_smul_iff_inv_smul_mem

theorem mem_inv_pointwise_smul_iff {g : G} {S : ValuationSubring K} {x : K} : x ∈ g⁻¹ • S ↔ g • x ∈ S :=
  Set.mem_inv_smul_set_iff
#align valuation_subring.mem_inv_pointwise_smul_iff ValuationSubring.mem_inv_pointwise_smul_iff

@[simp]
theorem pointwise_smul_le_pointwise_smul_iff {g : G} {S T : ValuationSubring K} : g • S ≤ g • T ↔ S ≤ T :=
  Set.set_smul_subset_set_smul_iff
#align valuation_subring.pointwise_smul_le_pointwise_smul_iff ValuationSubring.pointwise_smul_le_pointwise_smul_iff

theorem pointwise_smul_subset_iff {g : G} {S T : ValuationSubring K} : g • S ≤ T ↔ S ≤ g⁻¹ • T :=
  Set.set_smul_subset_iff
#align valuation_subring.pointwise_smul_subset_iff ValuationSubring.pointwise_smul_subset_iff

theorem subset_pointwise_smul_iff {g : G} {S T : ValuationSubring K} : S ≤ g • T ↔ g⁻¹ • S ≤ T :=
  Set.subset_set_smul_iff
#align valuation_subring.subset_pointwise_smul_iff ValuationSubring.subset_pointwise_smul_iff

end PointwiseActions

end ValuationSubring

namespace Valuation

variable {Γ : Type _} [LinearOrderedCommGroupWithZero Γ] (v : Valuation K Γ) (x : Kˣ)

@[simp]
theorem mem_unit_group_iff : x ∈ v.ValuationSubring.unitGroup ↔ v x = 1 :=
  (Valuation.is_equiv_iff_val_eq_one _ _).mp (Valuation.isEquivValuationValuationSubring _).symm
#align valuation.mem_unit_group_iff Valuation.mem_unit_group_iff

end Valuation

