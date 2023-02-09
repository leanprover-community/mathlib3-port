/-
Copyright (c) 2021 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anne Baanen, Ashvni Narayanan

! This file was ported from Lean 3 source module number_theory.function_field
! leanprover-community/mathlib commit d101e93197bb5f6ea89bd7ba386b7f7dff1f3903
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Group.TypeTags
import Mathbin.FieldTheory.Ratfunc
import Mathbin.RingTheory.DedekindDomain.IntegralClosure
import Mathbin.RingTheory.IntegrallyClosed
import Mathbin.Topology.Algebra.ValuedField

/-!
# Function fields

This file defines a function field and the ring of integers corresponding to it.

## Main definitions
 - `function_field Fq F` states that `F` is a function field over the (finite) field `Fq`,
   i.e. it is a finite extension of the field of rational functions in one variable over `Fq`.
 - `function_field.ring_of_integers` defines the ring of integers corresponding to a function field
    as the integral closure of `Fq[X]` in the function field.
 - `function_field.infty_valuation` : The place at infinity on `Fq(t)` is the nonarchimedean
    valuation on `Fq(t)` with uniformizer `1/t`.
 -  `function_field.Fqt_infty` : The completion `Fq((t⁻¹))`  of `Fq(t)` with respect to the
    valuation at infinity.

## Implementation notes
The definitions that involve a field of fractions choose a canonical field of fractions,
but are independent of that choice. We also omit assumptions like `finite Fq` or
`is_scalar_tower Fq[X] (fraction_ring Fq[X]) F` in definitions,
adding them back in lemmas when they are needed.

## References
* [D. Marcus, *Number Fields*][marcus1977number]
* [J.W.S. Cassels, A. Frölich, *Algebraic Number Theory*][cassels1967algebraic]
* [P. Samuel, *Algebraic Theory of Numbers*][samuel1970algebraic]

## Tags
function field, ring of integers
-/


noncomputable section

open nonZeroDivisors Polynomial DiscreteValuation

variable (Fq F : Type) [Field Fq] [Field F]

/-- `F` is a function field over the finite field `Fq` if it is a finite
extension of the field of rational functions in one variable over `Fq`.

Note that `F` can be a function field over multiple, non-isomorphic, `Fq`.
-/
abbrev FunctionField [Algebra (Ratfunc Fq) F] : Prop :=
  FiniteDimensional (Ratfunc Fq) F
#align function_field FunctionField

/-- `F` is a function field over `Fq` iff it is a finite extension of `Fq(t)`. -/
protected theorem functionField_iff (Fqt : Type _) [Field Fqt] [Algebra Fq[X] Fqt]
    [IsFractionRing Fq[X] Fqt] [Algebra (Ratfunc Fq) F] [Algebra Fqt F] [Algebra Fq[X] F]
    [IsScalarTower Fq[X] Fqt F] [IsScalarTower Fq[X] (Ratfunc Fq) F] :
    FunctionField Fq F ↔ FiniteDimensional Fqt F :=
  by
  let e := IsLocalization.algEquiv Fq[X]⁰ (Ratfunc Fq) Fqt
  have : ∀ (c) (x : F), e c • x = c • x := by
    intro c x
    rw [Algebra.smul_def, Algebra.smul_def]
    congr
    refine' congr_fun _ c
    refine' IsLocalization.ext (nonZeroDivisors Fq[X]) _ _ _ _ _ _ _ <;> intros <;>
      simp only [AlgEquiv.map_one, RingHom.map_one, AlgEquiv.map_mul, RingHom.map_mul,
        AlgEquiv.commutes, ← IsScalarTower.algebraMap_apply]
  constructor <;> intro h <;> skip
  · let b := FiniteDimensional.finBasis (Ratfunc Fq) F
    exact FiniteDimensional.of_fintype_basis (b.map_coeffs e this)
  · let b := FiniteDimensional.finBasis Fqt F
    refine' FiniteDimensional.of_fintype_basis (b.map_coeffs e.symm _)
    intro c x
    convert (this (e.symm c) x).symm
    simp only [e.apply_symm_apply]
#align function_field_iff functionField_iff

theorem algebraMap_injective [Algebra Fq[X] F] [Algebra (Ratfunc Fq) F]
    [IsScalarTower Fq[X] (Ratfunc Fq) F] : Function.Injective ⇑(algebraMap Fq[X] F) :=
  by
  rw [IsScalarTower.algebraMap_eq Fq[X] (Ratfunc Fq) F]
  exact
    Function.Injective.comp (algebraMap (Ratfunc Fq) F).Injective
      (IsFractionRing.injective Fq[X] (Ratfunc Fq))
#align algebra_map_injective algebraMap_injective

namespace FunctionField

/-- The function field analogue of `number_field.ring_of_integers`:
`function_field.ring_of_integers Fq Fqt F` is the integral closure of `Fq[t]` in `F`.

We don't actually assume `F` is a function field over `Fq` in the definition,
only when proving its properties.
-/
def ringOfIntegers [Algebra Fq[X] F] :=
  integralClosure Fq[X] F
#align function_field.ring_of_integers FunctionField.ringOfIntegers

namespace RingOfIntegers

variable [Algebra Fq[X] F]

instance : IsDomain (ringOfIntegers Fq F) :=
  (ringOfIntegers Fq F).IsDomain

instance : IsIntegralClosure (ringOfIntegers Fq F) Fq[X] F :=
  integralClosure.isIntegralClosure _ _

variable [Algebra (Ratfunc Fq) F] [IsScalarTower Fq[X] (Ratfunc Fq) F]

theorem algebraMap_injective : Function.Injective ⇑(algebraMap Fq[X] (ringOfIntegers Fq F)) :=
  by
  have hinj : Function.Injective ⇑(algebraMap Fq[X] F) :=
    by
    rw [IsScalarTower.algebraMap_eq Fq[X] (Ratfunc Fq) F]
    exact
      Function.Injective.comp (algebraMap (Ratfunc Fq) F).Injective
        (IsFractionRing.injective Fq[X] (Ratfunc Fq))
  rw [injective_iff_map_eq_zero (algebraMap Fq[X] ↥(ring_of_integers Fq F))]
  intro p hp
  rw [← Subtype.coe_inj, Subalgebra.coe_zero] at hp
  rw [injective_iff_map_eq_zero (algebraMap Fq[X] F)] at hinj
  exact hinj p hp
#align function_field.ring_of_integers.algebra_map_injective FunctionField.ringOfIntegers.algebraMap_injective

theorem not_isField : ¬IsField (ringOfIntegers Fq F) := by
  simpa [←
    (IsIntegralClosure.isIntegral_algebra Fq[X] F).isField_iff_isField
      (algebraMap_injective Fq F)] using
    Polynomial.not_isField Fq
#align function_field.ring_of_integers.not_is_field FunctionField.ringOfIntegers.not_isField

variable [FunctionField Fq F]

instance : IsFractionRing (ringOfIntegers Fq F) F :=
  integralClosure.isFractionRing_of_finite_extension (Ratfunc Fq) F

instance : IsIntegrallyClosed (ringOfIntegers Fq F) :=
  integralClosure.isIntegrallyClosedOfFiniteExtension (Ratfunc Fq)

instance [IsSeparable (Ratfunc Fq) F] : IsNoetherian Fq[X] (ringOfIntegers Fq F) :=
  IsIntegralClosure.isNoetherian _ (Ratfunc Fq) F _

instance [IsSeparable (Ratfunc Fq) F] : IsDedekindDomain (ringOfIntegers Fq F) :=
  IsIntegralClosure.isDedekindDomain Fq[X] (Ratfunc Fq) F _

end RingOfIntegers

/-! ### The place at infinity on Fq(t) -/


section InftyValuation

variable [DecidableEq (Ratfunc Fq)]

/-- The valuation at infinity is the nonarchimedean valuation on `Fq(t)` with uniformizer `1/t`.
Explicitly, if `f/g ∈ Fq(t)` is a nonzero quotient of polynomials, its valuation at infinity is
`multiplicative.of_add(degree(f) - degree(g))`. -/
def inftyValuationDef (r : Ratfunc Fq) : ℤₘ₀ :=
  if r = 0 then 0 else Multiplicative.ofAdd r.intDegree
#align function_field.infty_valuation_def FunctionField.inftyValuationDef

theorem InftyValuation.map_zero' : inftyValuationDef Fq 0 = 0 :=
  if_pos rfl
#align function_field.infty_valuation.map_zero' FunctionField.InftyValuation.map_zero'

theorem InftyValuation.map_one' : inftyValuationDef Fq 1 = 1 :=
  (if_neg one_ne_zero).trans <| by rw [Ratfunc.intDegree_one, ofAdd_zero, WithZero.coe_one]
#align function_field.infty_valuation.map_one' FunctionField.InftyValuation.map_one'

theorem InftyValuation.map_mul' (x y : Ratfunc Fq) :
    inftyValuationDef Fq (x * y) = inftyValuationDef Fq x * inftyValuationDef Fq y :=
  by
  rw [infty_valuation_def, infty_valuation_def, infty_valuation_def]
  by_cases hx : x = 0
  · rw [hx, zero_mul, if_pos (Eq.refl _), zero_mul]
  · by_cases hy : y = 0
    · rw [hy, mul_zero, if_pos (Eq.refl _), mul_zero]
    ·
      rw [if_neg hx, if_neg hy, if_neg (mul_ne_zero hx hy), ← WithZero.coe_mul, WithZero.coe_inj, ←
        ofAdd_add, Ratfunc.intDegree_mul hx hy]
#align function_field.infty_valuation.map_mul' FunctionField.InftyValuation.map_mul'

theorem InftyValuation.map_add_le_max' (x y : Ratfunc Fq) :
    inftyValuationDef Fq (x + y) ≤ max (inftyValuationDef Fq x) (inftyValuationDef Fq y) :=
  by
  by_cases hx : x = 0
  · rw [hx, zero_add]
    conv_rhs => rw [infty_valuation_def, if_pos (Eq.refl _)]
    rw [max_eq_right (WithZero.zero_le (infty_valuation_def Fq y))]
    exact le_refl _
  · by_cases hy : y = 0
    · rw [hy, add_zero]
      conv_rhs => rw [max_comm, infty_valuation_def, if_pos (Eq.refl _)]
      rw [max_eq_right (WithZero.zero_le (infty_valuation_def Fq x))]
      exact le_refl _
    · by_cases hxy : x + y = 0
      · rw [infty_valuation_def, if_pos hxy]
        exact zero_le'
      · rw [infty_valuation_def, infty_valuation_def, infty_valuation_def, if_neg hx, if_neg hy,
          if_neg hxy]
        rw [le_max_iff, WithZero.coe_le_coe, Multiplicative.ofAdd_le, WithZero.coe_le_coe,
          Multiplicative.ofAdd_le, ← le_max_iff]
        exact Ratfunc.intDegree_add_le hy hxy
#align function_field.infty_valuation.map_add_le_max' FunctionField.InftyValuation.map_add_le_max'

@[simp]
theorem infty_valuation_of_nonzero {x : Ratfunc Fq} (hx : x ≠ 0) :
    inftyValuationDef Fq x = Multiplicative.ofAdd x.intDegree := by
  rw [infty_valuation_def, if_neg hx]
#align function_field.infty_valuation_of_nonzero FunctionField.infty_valuation_of_nonzero

/-- The valuation at infinity on `Fq(t)`. -/
def inftyValuation : Valuation (Ratfunc Fq) ℤₘ₀
    where
  toFun := inftyValuationDef Fq
  map_zero' := InftyValuation.map_zero' Fq
  map_one' := InftyValuation.map_one' Fq
  map_mul' := InftyValuation.map_mul' Fq
  map_add_le_max' := InftyValuation.map_add_le_max' Fq
#align function_field.infty_valuation FunctionField.inftyValuation

@[simp]
theorem inftyValuation_apply {x : Ratfunc Fq} : inftyValuation Fq x = inftyValuationDef Fq x :=
  rfl
#align function_field.infty_valuation_apply FunctionField.inftyValuation_apply

@[simp]
theorem inftyValuation.c {k : Fq} (hk : k ≠ 0) :
    inftyValuationDef Fq (Ratfunc.c k) = Multiplicative.ofAdd (0 : ℤ) :=
  by
  have hCk : Ratfunc.c k ≠ 0 := (map_ne_zero _).mpr hk
  rw [infty_valuation_def, if_neg hCk, Ratfunc.intDegree_c]
#align function_field.infty_valuation.C FunctionField.inftyValuation.c

@[simp]
theorem inftyValuation.x : inftyValuationDef Fq Ratfunc.x = Multiplicative.ofAdd (1 : ℤ) := by
  rw [infty_valuation_def, if_neg Ratfunc.x_ne_zero, Ratfunc.intDegree_x]
#align function_field.infty_valuation.X FunctionField.inftyValuation.x

@[simp]
theorem inftyValuation.polynomial {p : Fq[X]} (hp : p ≠ 0) :
    inftyValuationDef Fq (algebraMap Fq[X] (Ratfunc Fq) p) =
      Multiplicative.ofAdd (p.natDegree : ℤ) :=
  by
  have hp' : algebraMap Fq[X] (Ratfunc Fq) p ≠ 0 :=
    by
    rw [Ne.def, Ratfunc.algebraMap_eq_zero_iff]
    exact hp
  rw [infty_valuation_def, if_neg hp', Ratfunc.intDegree_polynomial]
#align function_field.infty_valuation.polynomial FunctionField.inftyValuation.polynomial

/-- The valued field `Fq(t)` with the valuation at infinity. -/
def inftyValuedFqt : Valued (Ratfunc Fq) ℤₘ₀ :=
  Valued.mk' <| inftyValuation Fq
#align function_field.infty_valued_Fqt FunctionField.inftyValuedFqt

theorem inftyValuedFqt.def {x : Ratfunc Fq} :
    @Valued.v (Ratfunc Fq) _ _ _ (inftyValuedFqt Fq) x = inftyValuationDef Fq x :=
  rfl
#align function_field.infty_valued_Fqt.def FunctionField.inftyValuedFqt.def

/-- The completion `Fq((t⁻¹))`  of `Fq(t)` with respect to the valuation at infinity. -/
def FqtInfty :=
  @UniformSpace.Completion (Ratfunc Fq) <| (inftyValuedFqt Fq).toUniformSpace
#align function_field.Fqt_infty FunctionField.FqtInfty

instance : Field (FqtInfty Fq) :=
  letI := infty_valued_Fqt Fq
  UniformSpace.Completion.field

instance : Inhabited (FqtInfty Fq) :=
  ⟨(0 : FqtInfty Fq)⟩

/-- The valuation at infinity on `k(t)` extends to a valuation on `Fqt_infty`. -/
instance valuedFqtInfty : Valued (FqtInfty Fq) ℤₘ₀ :=
  @Valued.valuedCompletion _ _ _ _ (inftyValuedFqt Fq)
#align function_field.valued_Fqt_infty FunctionField.valuedFqtInfty

theorem valuedFqtInfty.def {x : FqtInfty Fq} :
    Valued.v x = @Valued.extension (Ratfunc Fq) _ _ _ (inftyValuedFqt Fq) x :=
  rfl
#align function_field.valued_Fqt_infty.def FunctionField.valuedFqtInfty.def

end InftyValuation

end FunctionField

