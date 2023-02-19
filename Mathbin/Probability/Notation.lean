/-
Copyright (c) 2021 Rémy Degenne. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rémy Degenne

! This file was ported from Lean 3 source module probability.notation
! leanprover-community/mathlib commit e97cf15cd1aec9bd5c193b2ffac5a6dc9118912b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Probability.ProbabilityMassFunction.Basic
import Mathbin.MeasureTheory.Function.ConditionalExpectation.Basic

/-! # Notations for probability theory

This file defines the following notations, for functions `X,Y`, measures `P, Q` defined on a
measurable space `m0`, and another measurable space structure `m` with `hm : m ≤ m0`,
- `P[X] = ∫ a, X a ∂P`
- `𝔼[X] = ∫ a, X a`
- `𝔼[X|m]`: conditional expectation of `X` with respect to the measure `volume` and the
  measurable space `m`. The similar `P[X|m]` for a measure `P` is defined in
  measure_theory.function.conditional_expectation.
- `X =ₐₛ Y`: `X =ᵐ[volume] Y`
- `X ≤ₐₛ Y`: `X ≤ᵐ[volume] Y`
- `∂P/∂Q = P.rn_deriv Q`
We note that the notation `∂P/∂Q` applies to three different cases, namely,
`measure_theory.measure.rn_deriv`, `measure_theory.signed_measure.rn_deriv` and
`measure_theory.complex_measure.rn_deriv`.

- `ℙ` is a notation for `volume` on a measured space.
-/


open MeasureTheory

-- mathport name: condexp.volume
-- We define notations `𝔼[f|m]` for the conditional expectation of `f` with respect to `m`.
scoped[ProbabilityTheory]
  notation "𝔼[" X "|" m "]" => MeasureTheory.condexp m MeasureTheory.MeasureSpace.volume X

-- mathport name: condexp.probability
scoped[ProbabilityTheory] notation P "[" X "]" => ∫ x, X x ∂P

-- mathport name: expected_value
scoped[ProbabilityTheory] notation "𝔼[" X "]" => ∫ a, X a

-- mathport name: eq_ae_volume
scoped[ProbabilityTheory] notation:50 X " =ₐₛ " Y:50 => X =ᵐ[MeasureTheory.MeasureSpace.volume] Y

-- mathport name: le_ae_volume
scoped[ProbabilityTheory] notation:50 X " ≤ₐₛ " Y:50 => X ≤ᵐ[MeasureTheory.MeasureSpace.volume] Y

-- mathport name: rn_deriv
scoped[ProbabilityTheory] notation "∂" P "/∂" Q:50 => P.rn_deriv Q

-- mathport name: measure_space.volume
scoped[ProbabilityTheory] notation "ℙ" => MeasureTheory.MeasureSpace.volume

