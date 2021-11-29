import Mathbin.Analysis.SpecialFunctions.Exp 
import Mathbin.Data.Set.Intervals.Infinite

/-!
# Trigonometric functions

## Main definitions

This file contains the definition of `π`.

See also `analysis.special_functions.trigonometric.inverse` and
`analysis.special_functions.trigonometric.arctan` for the inverse trigonometric functions.

See also `analysis.special_functions.complex.arg` and
`analysis.special_functions.complex.log` for the complex argument function
and the complex logarithm.

## Main statements

Many basic inequalities on the real trigonometric functions are established.

The continuity of the usual trigonometric functions is proved.

Several facts about the real trigonometric functions have the proofs deferred to
`analysis.special_functions.trigonometric.complex`,
as they are most easily proved by appealing to the corresponding fact for
complex trigonometric functions.

See also `analysis.special_functions.trigonometric.chebyshev` for the multiple angle formulas
in terms of Chebyshev polynomials.

## Tags

sin, cos, tan, angle
-/


noncomputable theory

open_locale Classical TopologicalSpace Filter

open Set Filter

namespace Complex

@[continuity]
theorem continuous_sin : Continuous sin :=
  by 
    change Continuous fun z => ((exp ((-z)*I) - exp (z*I))*I) / 2
    continuity

theorem continuous_on_sin {s : Set ℂ} : ContinuousOn sin s :=
  continuous_sin.ContinuousOn

@[continuity]
theorem continuous_cos : Continuous cos :=
  by 
    change Continuous fun z => (exp (z*I)+exp ((-z)*I)) / 2
    continuity

theorem continuous_on_cos {s : Set ℂ} : ContinuousOn cos s :=
  continuous_cos.ContinuousOn

@[continuity]
theorem continuous_sinh : Continuous sinh :=
  by 
    change Continuous fun z => (exp z - exp (-z)) / 2
    continuity

@[continuity]
theorem continuous_cosh : Continuous cosh :=
  by 
    change Continuous fun z => (exp z+exp (-z)) / 2
    continuity

end Complex

namespace Real

variable{x y z : ℝ}

@[continuity]
theorem continuous_sin : Continuous sin :=
  Complex.continuous_re.comp (Complex.continuous_sin.comp Complex.continuous_of_real)

theorem continuous_on_sin {s} : ContinuousOn sin s :=
  continuous_sin.ContinuousOn

@[continuity]
theorem continuous_cos : Continuous cos :=
  Complex.continuous_re.comp (Complex.continuous_cos.comp Complex.continuous_of_real)

theorem continuous_on_cos {s} : ContinuousOn cos s :=
  continuous_cos.ContinuousOn

@[continuity]
theorem continuous_sinh : Continuous sinh :=
  Complex.continuous_re.comp (Complex.continuous_sinh.comp Complex.continuous_of_real)

@[continuity]
theorem continuous_cosh : Continuous cosh :=
  Complex.continuous_re.comp (Complex.continuous_cosh.comp Complex.continuous_of_real)

end Real

namespace Real

theorem exists_cos_eq_zero : 0 ∈ cos '' Icc (1 : ℝ) 2 :=
  intermediate_value_Icc'
    (by 
      normNum)
    continuous_on_cos ⟨le_of_ltₓ cos_two_neg, le_of_ltₓ cos_one_pos⟩

/-- The number π = 3.14159265... Defined here using choice as twice a zero of cos in [1,2], from
which one can derive all its properties. For explicit bounds on π, see `data.real.pi.bounds`. -/
protected noncomputable def pi : ℝ :=
  2*Classical.some exists_cos_eq_zero

localized [Real] notation "π" => Real.pi

@[simp]
theorem cos_pi_div_two : cos (π / 2) = 0 :=
  by 
    rw [Real.pi, mul_div_cancel_left _ (@two_ne_zero' ℝ _ _ _)] <;> exact (Classical.some_spec exists_cos_eq_zero).2

theorem one_le_pi_div_two : (1 : ℝ) ≤ π / 2 :=
  by 
    rw [Real.pi, mul_div_cancel_left _ (@two_ne_zero' ℝ _ _ _)] <;> exact (Classical.some_spec exists_cos_eq_zero).1.1

theorem pi_div_two_le_two : π / 2 ≤ 2 :=
  by 
    rw [Real.pi, mul_div_cancel_left _ (@two_ne_zero' ℝ _ _ _)] <;> exact (Classical.some_spec exists_cos_eq_zero).1.2

theorem two_le_pi : (2 : ℝ) ≤ π :=
  (div_le_div_right
        (show (0 : ℝ) < 2by 
          normNum)).1
    (by 
      rw [div_self (@two_ne_zero' ℝ _ _ _)] <;> exact one_le_pi_div_two)

theorem pi_le_four : π ≤ 4 :=
  (div_le_div_right
        (show (0 : ℝ) < 2by 
          normNum)).1
    (calc π / 2 ≤ 2 := pi_div_two_le_two 
      _ = 4 / 2 :=
      by 
        normNum
      )

theorem pi_pos : 0 < π :=
  lt_of_lt_of_leₓ
    (by 
      normNum)
    two_le_pi

theorem pi_ne_zero : π ≠ 0 :=
  ne_of_gtₓ pi_pos

theorem pi_div_two_pos : 0 < π / 2 :=
  half_pos pi_pos

theorem two_pi_pos : 0 < 2*π :=
  by 
    linarith [pi_pos]

end Real

namespace Nnreal

open Real

open_locale Real Nnreal

/-- `π` considered as a nonnegative real. -/
noncomputable def pi :  ℝ≥0  :=
  ⟨π, Real.pi_pos.le⟩

@[simp]
theorem coe_real_pi : (pi : ℝ) = π :=
  rfl

theorem pi_pos : 0 < pi :=
  by 
    exactModCast Real.pi_pos

theorem pi_ne_zero : pi ≠ 0 :=
  pi_pos.ne'

end Nnreal

namespace Real

open_locale Real

@[simp]
theorem sin_pi : sin π = 0 :=
  by 
    rw [←mul_div_cancel_left π (@two_ne_zero ℝ _ _), two_mul, add_div, sin_add, cos_pi_div_two] <;> simp 

@[simp]
theorem cos_pi : cos π = -1 :=
  by 
    rw [←mul_div_cancel_left π (@two_ne_zero ℝ _ _), mul_div_assoc, cos_two_mul, cos_pi_div_two] <;>
      simp [bit0, pow_addₓ]

@[simp]
theorem sin_two_pi : sin (2*π) = 0 :=
  by 
    simp [two_mul, sin_add]

@[simp]
theorem cos_two_pi : cos (2*π) = 1 :=
  by 
    simp [two_mul, cos_add]

theorem sin_antiperiodic : Function.Antiperiodic sin π :=
  by 
    simp [sin_add]

theorem sin_periodic : Function.Periodic sin (2*π) :=
  sin_antiperiodic.Periodic

@[simp]
theorem sin_add_pi (x : ℝ) : sin (x+π) = -sin x :=
  sin_antiperiodic x

@[simp]
theorem sin_add_two_pi (x : ℝ) : sin (x+2*π) = sin x :=
  sin_periodic x

@[simp]
theorem sin_sub_pi (x : ℝ) : sin (x - π) = -sin x :=
  sin_antiperiodic.sub_eq x

@[simp]
theorem sin_sub_two_pi (x : ℝ) : sin (x - 2*π) = sin x :=
  sin_periodic.sub_eq x

@[simp]
theorem sin_pi_sub (x : ℝ) : sin (π - x) = sin x :=
  neg_negₓ (sin x) ▸ sin_neg x ▸ sin_antiperiodic.sub_eq'

@[simp]
theorem sin_two_pi_sub (x : ℝ) : sin ((2*π) - x) = -sin x :=
  sin_neg x ▸ sin_periodic.sub_eq'

@[simp]
theorem sin_nat_mul_pi (n : ℕ) : sin (n*π) = 0 :=
  sin_antiperiodic.nat_mul_eq_of_eq_zero sin_zero n

@[simp]
theorem sin_int_mul_pi (n : ℤ) : sin (n*π) = 0 :=
  sin_antiperiodic.int_mul_eq_of_eq_zero sin_zero n

@[simp]
theorem sin_add_nat_mul_two_pi (x : ℝ) (n : ℕ) : sin (x+n*2*π) = sin x :=
  sin_periodic.nat_mul n x

@[simp]
theorem sin_add_int_mul_two_pi (x : ℝ) (n : ℤ) : sin (x+n*2*π) = sin x :=
  sin_periodic.int_mul n x

@[simp]
theorem sin_sub_nat_mul_two_pi (x : ℝ) (n : ℕ) : sin (x - n*2*π) = sin x :=
  sin_periodic.sub_nat_mul_eq n

@[simp]
theorem sin_sub_int_mul_two_pi (x : ℝ) (n : ℤ) : sin (x - n*2*π) = sin x :=
  sin_periodic.sub_int_mul_eq n

@[simp]
theorem sin_nat_mul_two_pi_sub (x : ℝ) (n : ℕ) : sin ((n*2*π) - x) = -sin x :=
  sin_neg x ▸ sin_periodic.nat_mul_sub_eq n

@[simp]
theorem sin_int_mul_two_pi_sub (x : ℝ) (n : ℤ) : sin ((n*2*π) - x) = -sin x :=
  sin_neg x ▸ sin_periodic.int_mul_sub_eq n

theorem cos_antiperiodic : Function.Antiperiodic cos π :=
  by 
    simp [cos_add]

theorem cos_periodic : Function.Periodic cos (2*π) :=
  cos_antiperiodic.Periodic

@[simp]
theorem cos_add_pi (x : ℝ) : cos (x+π) = -cos x :=
  cos_antiperiodic x

@[simp]
theorem cos_add_two_pi (x : ℝ) : cos (x+2*π) = cos x :=
  cos_periodic x

@[simp]
theorem cos_sub_pi (x : ℝ) : cos (x - π) = -cos x :=
  cos_antiperiodic.sub_eq x

@[simp]
theorem cos_sub_two_pi (x : ℝ) : cos (x - 2*π) = cos x :=
  cos_periodic.sub_eq x

@[simp]
theorem cos_pi_sub (x : ℝ) : cos (π - x) = -cos x :=
  cos_neg x ▸ cos_antiperiodic.sub_eq'

@[simp]
theorem cos_two_pi_sub (x : ℝ) : cos ((2*π) - x) = cos x :=
  cos_neg x ▸ cos_periodic.sub_eq'

@[simp]
theorem cos_nat_mul_two_pi (n : ℕ) : cos (n*2*π) = 1 :=
  (cos_periodic.nat_mul_eq n).trans cos_zero

@[simp]
theorem cos_int_mul_two_pi (n : ℤ) : cos (n*2*π) = 1 :=
  (cos_periodic.int_mul_eq n).trans cos_zero

@[simp]
theorem cos_add_nat_mul_two_pi (x : ℝ) (n : ℕ) : cos (x+n*2*π) = cos x :=
  cos_periodic.nat_mul n x

@[simp]
theorem cos_add_int_mul_two_pi (x : ℝ) (n : ℤ) : cos (x+n*2*π) = cos x :=
  cos_periodic.int_mul n x

@[simp]
theorem cos_sub_nat_mul_two_pi (x : ℝ) (n : ℕ) : cos (x - n*2*π) = cos x :=
  cos_periodic.sub_nat_mul_eq n

@[simp]
theorem cos_sub_int_mul_two_pi (x : ℝ) (n : ℤ) : cos (x - n*2*π) = cos x :=
  cos_periodic.sub_int_mul_eq n

@[simp]
theorem cos_nat_mul_two_pi_sub (x : ℝ) (n : ℕ) : cos ((n*2*π) - x) = cos x :=
  cos_neg x ▸ cos_periodic.nat_mul_sub_eq n

@[simp]
theorem cos_int_mul_two_pi_sub (x : ℝ) (n : ℤ) : cos ((n*2*π) - x) = cos x :=
  cos_neg x ▸ cos_periodic.int_mul_sub_eq n

@[simp]
theorem cos_nat_mul_two_pi_add_pi (n : ℕ) : cos ((n*2*π)+π) = -1 :=
  by 
    simpa only [cos_zero] using (cos_periodic.nat_mul n).add_antiperiod_eq cos_antiperiodic

@[simp]
theorem cos_int_mul_two_pi_add_pi (n : ℤ) : cos ((n*2*π)+π) = -1 :=
  by 
    simpa only [cos_zero] using (cos_periodic.int_mul n).add_antiperiod_eq cos_antiperiodic

@[simp]
theorem cos_nat_mul_two_pi_sub_pi (n : ℕ) : cos ((n*2*π) - π) = -1 :=
  by 
    simpa only [cos_zero] using (cos_periodic.nat_mul n).sub_antiperiod_eq cos_antiperiodic

@[simp]
theorem cos_int_mul_two_pi_sub_pi (n : ℤ) : cos ((n*2*π) - π) = -1 :=
  by 
    simpa only [cos_zero] using (cos_periodic.int_mul n).sub_antiperiod_eq cos_antiperiodic

theorem sin_pos_of_pos_of_lt_pi {x : ℝ} (h0x : 0 < x) (hxp : x < π) : 0 < sin x :=
  if hx2 : x ≤ 2 then sin_pos_of_pos_of_le_two h0x hx2 else
    have  : ((2 : ℝ)+2) = 4 := rfl 
    have  : π - x ≤ 2 := sub_le_iff_le_add.2 (le_transₓ pi_le_four (this ▸ add_le_add_left (le_of_not_geₓ hx2) _))
    sin_pi_sub x ▸ sin_pos_of_pos_of_le_two (sub_pos.2 hxp) this

theorem sin_pos_of_mem_Ioo {x : ℝ} (hx : x ∈ Ioo 0 π) : 0 < sin x :=
  sin_pos_of_pos_of_lt_pi hx.1 hx.2

theorem sin_nonneg_of_mem_Icc {x : ℝ} (hx : x ∈ Icc 0 π) : 0 ≤ sin x :=
  by 
    rw [←closure_Ioo pi_pos] at hx 
    exact closure_lt_subset_le continuous_const continuous_sin (closure_mono (fun y => sin_pos_of_mem_Ioo) hx)

theorem sin_nonneg_of_nonneg_of_le_pi {x : ℝ} (h0x : 0 ≤ x) (hxp : x ≤ π) : 0 ≤ sin x :=
  sin_nonneg_of_mem_Icc ⟨h0x, hxp⟩

theorem sin_neg_of_neg_of_neg_pi_lt {x : ℝ} (hx0 : x < 0) (hpx : -π < x) : sin x < 0 :=
  neg_pos.1$ sin_neg x ▸ sin_pos_of_pos_of_lt_pi (neg_pos.2 hx0) (neg_lt.1 hpx)

theorem sin_nonpos_of_nonnpos_of_neg_pi_le {x : ℝ} (hx0 : x ≤ 0) (hpx : -π ≤ x) : sin x ≤ 0 :=
  neg_nonneg.1$ sin_neg x ▸ sin_nonneg_of_nonneg_of_le_pi (neg_nonneg.2 hx0) (neg_le.1 hpx)

@[simp]
theorem sin_pi_div_two : sin (π / 2) = 1 :=
  have  : sin (π / 2) = 1 ∨ sin (π / 2) = -1 :=
    by 
      simpa [sq, mul_self_eq_one_iff] using sin_sq_add_cos_sq (π / 2)
  this.resolve_right
    fun h =>
      show ¬(0 : ℝ) < -1by 
          normNum$
        h ▸ sin_pos_of_pos_of_lt_pi pi_div_two_pos (half_lt_self pi_pos)

theorem sin_add_pi_div_two (x : ℝ) : sin (x+π / 2) = cos x :=
  by 
    simp [sin_add]

theorem sin_sub_pi_div_two (x : ℝ) : sin (x - π / 2) = -cos x :=
  by 
    simp [sub_eq_add_neg, sin_add]

theorem sin_pi_div_two_sub (x : ℝ) : sin (π / 2 - x) = cos x :=
  by 
    simp [sub_eq_add_neg, sin_add]

theorem cos_add_pi_div_two (x : ℝ) : cos (x+π / 2) = -sin x :=
  by 
    simp [cos_add]

theorem cos_sub_pi_div_two (x : ℝ) : cos (x - π / 2) = sin x :=
  by 
    simp [sub_eq_add_neg, cos_add]

theorem cos_pi_div_two_sub (x : ℝ) : cos (π / 2 - x) = sin x :=
  by 
    rw [←cos_neg, neg_sub, cos_sub_pi_div_two]

theorem cos_pos_of_mem_Ioo {x : ℝ} (hx : x ∈ Ioo (-(π / 2)) (π / 2)) : 0 < cos x :=
  sin_add_pi_div_two x ▸
    sin_pos_of_mem_Ioo
      ⟨by 
          linarith [hx.1],
        by 
          linarith [hx.2]⟩

theorem cos_nonneg_of_mem_Icc {x : ℝ} (hx : x ∈ Icc (-(π / 2)) (π / 2)) : 0 ≤ cos x :=
  sin_add_pi_div_two x ▸
    sin_nonneg_of_mem_Icc
      ⟨by 
          linarith [hx.1],
        by 
          linarith [hx.2]⟩

theorem cos_nonneg_of_neg_pi_div_two_le_of_le {x : ℝ} (hl : -(π / 2) ≤ x) (hu : x ≤ π / 2) : 0 ≤ cos x :=
  cos_nonneg_of_mem_Icc ⟨hl, hu⟩

theorem cos_neg_of_pi_div_two_lt_of_lt {x : ℝ} (hx₁ : π / 2 < x) (hx₂ : x < π+π / 2) : cos x < 0 :=
  neg_pos.1$
    cos_pi_sub x ▸
      cos_pos_of_mem_Ioo
        ⟨by 
            linarith,
          by 
            linarith⟩

theorem cos_nonpos_of_pi_div_two_le_of_le {x : ℝ} (hx₁ : π / 2 ≤ x) (hx₂ : x ≤ π+π / 2) : cos x ≤ 0 :=
  neg_nonneg.1$
    cos_pi_sub x ▸
      cos_nonneg_of_mem_Icc
        ⟨by 
            linarith,
          by 
            linarith⟩

theorem sin_eq_sqrt_one_sub_cos_sq {x : ℝ} (hl : 0 ≤ x) (hu : x ≤ π) : sin x = sqrt (1 - (cos x^2)) :=
  by 
    rw [←abs_sin_eq_sqrt_one_sub_cos_sq, abs_of_nonneg (sin_nonneg_of_nonneg_of_le_pi hl hu)]

theorem cos_eq_sqrt_one_sub_sin_sq {x : ℝ} (hl : -(π / 2) ≤ x) (hu : x ≤ π / 2) : cos x = sqrt (1 - (sin x^2)) :=
  by 
    rw [←abs_cos_eq_sqrt_one_sub_sin_sq, abs_of_nonneg (cos_nonneg_of_mem_Icc ⟨hl, hu⟩)]

theorem sin_eq_zero_iff_of_lt_of_lt {x : ℝ} (hx₁ : -π < x) (hx₂ : x < π) : sin x = 0 ↔ x = 0 :=
  ⟨fun h =>
      le_antisymmₓ
        (le_of_not_gtₓ
          fun h0 =>
            lt_irreflₓ (0 : ℝ)$
              calc 0 < sin x := sin_pos_of_pos_of_lt_pi h0 hx₂ 
                _ = 0 := h
                )
        (le_of_not_gtₓ
          fun h0 =>
            lt_irreflₓ (0 : ℝ)$
              calc 0 = sin x := h.symm 
                _ < 0 := sin_neg_of_neg_of_neg_pi_lt h0 hx₁
                ),
    fun h =>
      by 
        simp [h]⟩

theorem sin_eq_zero_iff {x : ℝ} : sin x = 0 ↔ ∃ n : ℤ, ((n : ℝ)*π) = x :=
  ⟨fun h =>
      ⟨⌊x / π⌋,
        le_antisymmₓ (sub_nonneg.1 (sub_floor_div_mul_nonneg _ pi_pos))
          (sub_nonpos.1$
            le_of_not_gtₓ$
              fun h₃ =>
                (sin_pos_of_pos_of_lt_pi h₃ (sub_floor_div_mul_lt _ pi_pos)).Ne
                  (by 
                    simp [sub_eq_add_neg, sin_add, h, sin_int_mul_pi]))⟩,
    fun ⟨n, hn⟩ => hn ▸ sin_int_mul_pi _⟩

theorem sin_ne_zero_iff {x : ℝ} : sin x ≠ 0 ↔ ∀ (n : ℤ), ((n : ℝ)*π) ≠ x :=
  by 
    rw [←not_exists, not_iff_not, sin_eq_zero_iff]

theorem sin_eq_zero_iff_cos_eq {x : ℝ} : sin x = 0 ↔ cos x = 1 ∨ cos x = -1 :=
  by 
    rw [←mul_self_eq_one_iff, ←sin_sq_add_cos_sq x, sq, sq, ←sub_eq_iff_eq_add, sub_self] <;>
      exact
        ⟨fun h =>
            by 
              rw [h, mul_zero],
          eq_zero_of_mul_self_eq_zero ∘ Eq.symm⟩

theorem cos_eq_one_iff (x : ℝ) : cos x = 1 ↔ ∃ n : ℤ, ((n : ℝ)*2*π) = x :=
  ⟨fun h =>
      let ⟨n, hn⟩ := sin_eq_zero_iff.1 (sin_eq_zero_iff_cos_eq.2 (Or.inl h))
      ⟨n / 2,
        (Int.mod_two_eq_zero_or_one n).elim
          (fun hn0 =>
            by 
              rwa [←mul_assocₓ, ←@Int.cast_two ℝ, ←Int.cast_mul,
                Int.div_mul_cancel ((Int.dvd_iff_mod_eq_zero _ _).2 hn0)])
          fun hn1 =>
            by 
              rw [←Int.mod_add_div n 2, hn1, Int.cast_add, Int.cast_one, add_mulₓ, one_mulₓ, add_commₓ,
                  mul_commₓ (2 : ℤ), Int.cast_mul, mul_assocₓ, Int.cast_two] at hn <;>
                rw [←hn, cos_int_mul_two_pi_add_pi] at h <;>
                  exact
                    absurd h
                      (by 
                        normNum)⟩,
    fun ⟨n, hn⟩ => hn ▸ cos_int_mul_two_pi _⟩

theorem cos_eq_one_iff_of_lt_of_lt {x : ℝ} (hx₁ : (-2*π) < x) (hx₂ : x < 2*π) : cos x = 1 ↔ x = 0 :=
  ⟨fun h =>
      by 
        rcases(cos_eq_one_iff _).1 h with ⟨n, rfl⟩
        rw [mul_lt_iff_lt_one_left two_pi_pos] at hx₂ 
        rw [neg_lt, neg_mul_eq_neg_mul, mul_lt_iff_lt_one_left two_pi_pos] at hx₁ 
        normCast  at hx₁ hx₂ 
        obtain rfl : n = 0 :=
          le_antisymmₓ
            (by 
              linarith)
            (by 
              linarith)
        simp ,
    fun h =>
      by 
        simp [h]⟩

-- error in Analysis.SpecialFunctions.Trigonometric.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem cos_lt_cos_of_nonneg_of_le_pi_div_two
{x y : exprℝ()}
(hx₁ : «expr ≤ »(0, x))
(hy₂ : «expr ≤ »(y, «expr / »(exprπ(), 2)))
(hxy : «expr < »(x, y)) : «expr < »(cos y, cos x) :=
begin
  rw ["[", "<-", expr sub_lt_zero, ",", expr cos_sub_cos, "]"] [],
  have [] [":", expr «expr < »(0, sin «expr / »(«expr + »(y, x), 2))] [],
  { refine [expr sin_pos_of_pos_of_lt_pi _ _]; linarith [] [] [] },
  have [] [":", expr «expr < »(0, sin «expr / »(«expr - »(y, x), 2))] [],
  { refine [expr sin_pos_of_pos_of_lt_pi _ _]; linarith [] [] [] },
  nlinarith [] [] []
end

theorem cos_lt_cos_of_nonneg_of_le_pi {x y : ℝ} (hx₁ : 0 ≤ x) (hy₂ : y ≤ π) (hxy : x < y) : cos y < cos x :=
  match (le_totalₓ x (π / 2) : x ≤ π / 2 ∨ π / 2 ≤ x), le_totalₓ y (π / 2) with 
  | Or.inl hx, Or.inl hy => cos_lt_cos_of_nonneg_of_le_pi_div_two hx₁ hy hxy
  | Or.inl hx, Or.inr hy =>
    (lt_or_eq_of_leₓ hx).elim
      (fun hx =>
        calc cos y ≤ 0 :=
          cos_nonpos_of_pi_div_two_le_of_le hy
            (by 
              linarith [pi_pos])
          _ < cos x :=
          cos_pos_of_mem_Ioo
            ⟨by 
                linarith,
              hx⟩
          )
      fun hx =>
        calc cos y < 0 :=
          cos_neg_of_pi_div_two_lt_of_lt
            (by 
              linarith)
            (by 
              linarith [pi_pos])
          _ = cos x :=
          by 
            rw [hx, cos_pi_div_two]
          
  | Or.inr hx, Or.inl hy =>
    by 
      linarith
  | Or.inr hx, Or.inr hy =>
    neg_lt_neg_iff.1
      (by 
        rw [←cos_pi_sub, ←cos_pi_sub] <;> apply cos_lt_cos_of_nonneg_of_le_pi_div_two <;> linarith)

theorem strict_anti_on_cos : StrictAntiOn cos (Icc 0 π) :=
  fun x hx y hy hxy => cos_lt_cos_of_nonneg_of_le_pi hx.1 hy.2 hxy

theorem cos_le_cos_of_nonneg_of_le_pi {x y : ℝ} (hx₁ : 0 ≤ x) (hy₂ : y ≤ π) (hxy : x ≤ y) : cos y ≤ cos x :=
  (strict_anti_on_cos.le_iff_le ⟨hx₁.trans hxy, hy₂⟩ ⟨hx₁, hxy.trans hy₂⟩).2 hxy

theorem sin_lt_sin_of_lt_of_le_pi_div_two {x y : ℝ} (hx₁ : -(π / 2) ≤ x) (hy₂ : y ≤ π / 2) (hxy : x < y) :
  sin x < sin y :=
  by 
    rw [←cos_sub_pi_div_two, ←cos_sub_pi_div_two, ←cos_neg (x - _), ←cos_neg (y - _)] <;>
      apply cos_lt_cos_of_nonneg_of_le_pi <;> linarith

theorem strict_mono_on_sin : StrictMonoOn sin (Icc (-(π / 2)) (π / 2)) :=
  fun x hx y hy hxy => sin_lt_sin_of_lt_of_le_pi_div_two hx.1 hy.2 hxy

theorem sin_le_sin_of_le_of_le_pi_div_two {x y : ℝ} (hx₁ : -(π / 2) ≤ x) (hy₂ : y ≤ π / 2) (hxy : x ≤ y) :
  sin x ≤ sin y :=
  (strict_mono_on_sin.le_iff_le ⟨hx₁, hxy.trans hy₂⟩ ⟨hx₁.trans hxy, hy₂⟩).2 hxy

theorem inj_on_sin : inj_on sin (Icc (-(π / 2)) (π / 2)) :=
  strict_mono_on_sin.InjOn

theorem inj_on_cos : inj_on cos (Icc 0 π) :=
  strict_anti_on_cos.InjOn

theorem surj_on_sin : surj_on sin (Icc (-(π / 2)) (π / 2)) (Icc (-1) 1) :=
  by 
    simpa only [sin_neg, sin_pi_div_two] using
      intermediate_value_Icc (neg_le_self pi_div_two_pos.le) continuous_sin.continuous_on

theorem surj_on_cos : surj_on cos (Icc 0 π) (Icc (-1) 1) :=
  by 
    simpa only [cos_zero, cos_pi] using intermediate_value_Icc' pi_pos.le continuous_cos.continuous_on

theorem sin_mem_Icc (x : ℝ) : sin x ∈ Icc (-1 : ℝ) 1 :=
  ⟨neg_one_le_sin x, sin_le_one x⟩

theorem cos_mem_Icc (x : ℝ) : cos x ∈ Icc (-1 : ℝ) 1 :=
  ⟨neg_one_le_cos x, cos_le_one x⟩

theorem maps_to_sin (s : Set ℝ) : maps_to sin s (Icc (-1 : ℝ) 1) :=
  fun x _ => sin_mem_Icc x

theorem maps_to_cos (s : Set ℝ) : maps_to cos s (Icc (-1 : ℝ) 1) :=
  fun x _ => cos_mem_Icc x

theorem bij_on_sin : bij_on sin (Icc (-(π / 2)) (π / 2)) (Icc (-1) 1) :=
  ⟨maps_to_sin _, inj_on_sin, surj_on_sin⟩

theorem bij_on_cos : bij_on cos (Icc 0 π) (Icc (-1) 1) :=
  ⟨maps_to_cos _, inj_on_cos, surj_on_cos⟩

@[simp]
theorem range_cos : range cos = (Icc (-1) 1 : Set ℝ) :=
  subset.antisymm (range_subset_iff.2 cos_mem_Icc) surj_on_cos.subset_range

@[simp]
theorem range_sin : range sin = (Icc (-1) 1 : Set ℝ) :=
  subset.antisymm (range_subset_iff.2 sin_mem_Icc) surj_on_sin.subset_range

theorem range_cos_infinite : (range Real.cos).Infinite :=
  by 
    rw [Real.range_cos]
    exact
      Icc.infinite
        (by 
          normNum)

theorem range_sin_infinite : (range Real.sin).Infinite :=
  by 
    rw [Real.range_sin]
    exact
      Icc.infinite
        (by 
          normNum)

-- error in Analysis.SpecialFunctions.Trigonometric.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem sin_lt {x : exprℝ()} (h : «expr < »(0, x)) : «expr < »(sin x, x) :=
begin
  cases [expr le_or_gt x 1] ["with", ident h', ident h'],
  { have [ident hx] [":", expr «expr = »(«expr| |»(x), x)] [":=", expr abs_of_nonneg (le_of_lt h)],
    have [] [":", expr «expr ≤ »(«expr| |»(x), 1)] [],
    rwa ["[", expr hx, "]"] [],
    have [] [] [":=", expr sin_bound this],
    rw ["[", expr abs_le, "]"] ["at", ident this],
    have [] [] [":=", expr this.2],
    rw ["[", expr sub_le_iff_le_add', ",", expr hx, "]"] ["at", ident this],
    apply [expr lt_of_le_of_lt this],
    rw ["[", expr sub_add, "]"] [],
    apply [expr lt_of_lt_of_le _ (le_of_eq (sub_zero x))],
    apply [expr sub_lt_sub_left],
    rw ["[", expr sub_pos, ",", expr div_eq_mul_inv «expr ^ »(x, 3), "]"] [],
    apply [expr mul_lt_mul'],
    { rw ["[", expr pow_succ x 3, "]"] [],
      refine [expr le_trans _ (le_of_eq (one_mul _))],
      rw [expr mul_le_mul_right] [],
      exact [expr h'],
      apply [expr pow_pos h] },
    norm_num [] [],
    norm_num [] [],
    apply [expr pow_pos h] },
  exact [expr lt_of_le_of_lt (sin_le_one x) h']
end

-- error in Analysis.SpecialFunctions.Trigonometric.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem sin_gt_sub_cube
{x : exprℝ()}
(h : «expr < »(0, x))
(h' : «expr ≤ »(x, 1)) : «expr < »(«expr - »(x, «expr / »(«expr ^ »(x, 3), 4)), sin x) :=
begin
  have [ident hx] [":", expr «expr = »(«expr| |»(x), x)] [":=", expr abs_of_nonneg (le_of_lt h)],
  have [] [":", expr «expr ≤ »(«expr| |»(x), 1)] [],
  rwa ["[", expr hx, "]"] [],
  have [] [] [":=", expr sin_bound this],
  rw ["[", expr abs_le, "]"] ["at", ident this],
  have [] [] [":=", expr this.1],
  rw ["[", expr le_sub_iff_add_le, ",", expr hx, "]"] ["at", ident this],
  refine [expr lt_of_lt_of_le _ this],
  rw ["[", expr add_comm, ",", expr sub_add, ",", expr sub_neg_eq_add, "]"] [],
  apply [expr sub_lt_sub_left],
  apply [expr add_lt_of_lt_sub_left],
  rw [expr show «expr = »(«expr - »(«expr / »(«expr ^ »(x, 3), 4), «expr / »(«expr ^ »(x, 3), 6)), «expr * »(«expr ^ »(x, 3), «expr ⁻¹»(12))), by simp [] [] [] ["[", expr div_eq_mul_inv, ",", "<-", expr mul_sub, "]"] [] []; norm_num [] []] [],
  apply [expr mul_lt_mul'],
  { rw ["[", expr pow_succ x 3, "]"] [],
    refine [expr le_trans _ (le_of_eq (one_mul _))],
    rw [expr mul_le_mul_right] [],
    exact [expr h'],
    apply [expr pow_pos h] },
  norm_num [] [],
  norm_num [] [],
  apply [expr pow_pos h]
end

section CosDivSq

variable(x : ℝ)

/-- the series `sqrt_two_add_series x n` is `sqrt(2 + sqrt(2 + ... ))` with `n` square roots,
  starting with `x`. We define it here because `cos (pi / 2 ^ (n+1)) = sqrt_two_add_series 0 n / 2`
-/
@[simp, pp_nodot]
noncomputable def sqrt_two_add_series (x : ℝ) : ℕ → ℝ
| 0 => x
| n+1 => sqrt (2+sqrt_two_add_series n)

theorem sqrt_two_add_series_zero : sqrt_two_add_series x 0 = x :=
  by 
    simp 

theorem sqrt_two_add_series_one : sqrt_two_add_series 0 1 = sqrt 2 :=
  by 
    simp 

theorem sqrt_two_add_series_two : sqrt_two_add_series 0 2 = sqrt (2+sqrt 2) :=
  by 
    simp 

theorem sqrt_two_add_series_zero_nonneg : ∀ (n : ℕ), 0 ≤ sqrt_two_add_series 0 n
| 0 => le_reflₓ 0
| n+1 => sqrt_nonneg _

theorem sqrt_two_add_series_nonneg {x : ℝ} (h : 0 ≤ x) : ∀ (n : ℕ), 0 ≤ sqrt_two_add_series x n
| 0 => h
| n+1 => sqrt_nonneg _

theorem sqrt_two_add_series_lt_two : ∀ (n : ℕ), sqrt_two_add_series 0 n < 2
| 0 =>
  by 
    normNum
| n+1 =>
  by 
    refine' lt_of_lt_of_leₓ _ (sqrt_sq zero_lt_two.le).le 
    rw [sqrt_two_add_series, sqrt_lt_sqrt_iff, ←lt_sub_iff_add_lt']
    ·
      refine' (sqrt_two_add_series_lt_two n).trans_le _ 
      normNum
    ·
      exact add_nonneg zero_le_two (sqrt_two_add_series_zero_nonneg n)

theorem sqrt_two_add_series_succ (x : ℝ) : ∀ (n : ℕ), sqrt_two_add_series x (n+1) = sqrt_two_add_series (sqrt (2+x)) n
| 0 => rfl
| n+1 =>
  by 
    rw [sqrt_two_add_series, sqrt_two_add_series_succ, sqrt_two_add_series]

theorem sqrt_two_add_series_monotone_left {x y : ℝ} (h : x ≤ y) :
  ∀ (n : ℕ), sqrt_two_add_series x n ≤ sqrt_two_add_series y n
| 0 => h
| n+1 =>
  by 
    rw [sqrt_two_add_series, sqrt_two_add_series]
    exact sqrt_le_sqrt (add_le_add_left (sqrt_two_add_series_monotone_left _) _)

-- error in Analysis.SpecialFunctions.Trigonometric.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem cos_pi_over_two_pow : ∀
n : exprℕ(), «expr = »(cos «expr / »(exprπ(), «expr ^ »(2, «expr + »(n, 1))), «expr / »(sqrt_two_add_series 0 n, 2))
| 0 := by simp [] [] [] [] [] []
| «expr + »(n, 1) := begin
  have [] [":", expr «expr ≠ »((2 : exprℝ()), 0)] [":=", expr two_ne_zero],
  symmetry,
  rw ["[", expr div_eq_iff_mul_eq this, "]"] [],
  symmetry,
  rw ["[", expr sqrt_two_add_series, ",", expr sqrt_eq_iff_sq_eq, ",", expr mul_pow, ",", expr cos_sq, ",", "<-", expr mul_div_assoc, ",", expr nat.add_succ, ",", expr pow_succ, ",", expr mul_div_mul_left _ _ this, ",", expr cos_pi_over_two_pow, ",", expr add_mul, "]"] [],
  congr,
  { norm_num [] [] },
  rw ["[", expr mul_comm, ",", expr sq, ",", expr mul_assoc, ",", "<-", expr mul_div_assoc, ",", expr mul_div_cancel_left, ",", "<-", expr mul_div_assoc, ",", expr mul_div_cancel_left, "]"] []; try { exact [expr this] },
  apply [expr add_nonneg],
  norm_num [] [],
  apply [expr sqrt_two_add_series_zero_nonneg],
  norm_num [] [],
  apply [expr le_of_lt],
  apply [expr cos_pos_of_mem_Ioo ⟨_, _⟩],
  { transitivity [expr (0 : exprℝ())],
    rw [expr neg_lt_zero] [],
    apply [expr pi_div_two_pos],
    apply [expr div_pos pi_pos],
    apply [expr pow_pos],
    norm_num [] [] },
  apply [expr div_lt_div' (le_refl exprπ()) _ pi_pos _],
  refine [expr lt_of_le_of_lt (le_of_eq (pow_one _).symm) _],
  apply [expr pow_lt_pow],
  norm_num [] [],
  apply [expr nat.succ_lt_succ],
  apply [expr nat.succ_pos],
  all_goals { norm_num [] [] }
end

theorem sin_sq_pi_over_two_pow (n : ℕ) : (sin (π / (2^n+1))^2) = 1 - (sqrt_two_add_series 0 n / 2^2) :=
  by 
    rw [sin_sq, cos_pi_over_two_pow]

theorem sin_sq_pi_over_two_pow_succ (n : ℕ) : (sin (π / (2^n+2))^2) = 1 / 2 - sqrt_two_add_series 0 n / 4 :=
  by 
    rw [sin_sq_pi_over_two_pow, sqrt_two_add_series, div_pow, sq_sqrt, add_div, ←sub_sub]
    congr 
    normNum 
    normNum 
    apply add_nonneg 
    normNum 
    apply sqrt_two_add_series_zero_nonneg

@[simp]
theorem sin_pi_over_two_pow_succ (n : ℕ) : sin (π / (2^n+2)) = sqrt (2 - sqrt_two_add_series 0 n) / 2 :=
  by 
    symm 
    rw [div_eq_iff_mul_eq]
    symm 
    rw [sqrt_eq_iff_sq_eq, mul_powₓ, sin_sq_pi_over_two_pow_succ, sub_mul]
    ·
      congr 
      normNum 
      rw [mul_commₓ]
      convert mul_div_cancel' _ _ 
      normNum 
      normNum
    ·
      rw [sub_nonneg]
      apply le_of_ltₓ 
      apply sqrt_two_add_series_lt_two 
    apply le_of_ltₓ 
    apply mul_pos 
    apply sin_pos_of_pos_of_lt_pi
    ·
      apply div_pos pi_pos 
      apply pow_pos 
      normNum 
    refine' lt_of_lt_of_leₓ _ (le_of_eqₓ (div_one _))
    rw [div_lt_div_left]
    refine' lt_of_le_of_ltₓ (le_of_eqₓ (pow_zeroₓ 2).symm) _ 
    apply pow_lt_pow 
    normNum 
    apply Nat.succ_posₓ 
    apply pi_pos 
    apply pow_pos 
    all_goals 
      normNum

@[simp]
theorem cos_pi_div_four : cos (π / 4) = sqrt 2 / 2 :=
  by 
    trans cos (π / (2^2))
    congr 
    normNum 
    simp 

@[simp]
theorem sin_pi_div_four : sin (π / 4) = sqrt 2 / 2 :=
  by 
    trans sin (π / (2^2))
    congr 
    normNum 
    simp 

@[simp]
theorem cos_pi_div_eight : cos (π / 8) = sqrt (2+sqrt 2) / 2 :=
  by 
    trans cos (π / (2^3))
    congr 
    normNum 
    simp 

@[simp]
theorem sin_pi_div_eight : sin (π / 8) = sqrt (2 - sqrt 2) / 2 :=
  by 
    trans sin (π / (2^3))
    congr 
    normNum 
    simp 

@[simp]
theorem cos_pi_div_sixteen : cos (π / 16) = sqrt (2+sqrt (2+sqrt 2)) / 2 :=
  by 
    trans cos (π / (2^4))
    congr 
    normNum 
    simp 

@[simp]
theorem sin_pi_div_sixteen : sin (π / 16) = sqrt (2 - sqrt (2+sqrt 2)) / 2 :=
  by 
    trans sin (π / (2^4))
    congr 
    normNum 
    simp 

@[simp]
theorem cos_pi_div_thirty_two : cos (π / 32) = sqrt (2+sqrt (2+sqrt (2+sqrt 2))) / 2 :=
  by 
    trans cos (π / (2^5))
    congr 
    normNum 
    simp 

@[simp]
theorem sin_pi_div_thirty_two : sin (π / 32) = sqrt (2 - sqrt (2+sqrt (2+sqrt 2))) / 2 :=
  by 
    trans sin (π / (2^5))
    congr 
    normNum 
    simp 

-- error in Analysis.SpecialFunctions.Trigonometric.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The cosine of `π / 3` is `1 / 2`. -/
@[simp]
theorem cos_pi_div_three : «expr = »(cos «expr / »(exprπ(), 3), «expr / »(1, 2)) :=
begin
  have [ident h₁] [":", expr «expr = »(«expr * »(«expr ^ »(«expr - »(«expr * »(2, cos «expr / »(exprπ(), 3)), 1), 2), «expr + »(«expr * »(2, cos «expr / »(exprπ(), 3)), 2)), 0)] [],
  { have [] [":", expr «expr = »(cos «expr * »(3, «expr / »(exprπ(), 3)), cos exprπ())] [":=", expr by { congr' [1] [],
       ring [] }],
    linarith [] [] ["[", expr cos_pi, ",", expr cos_three_mul «expr / »(exprπ(), 3), "]"] },
  cases [expr mul_eq_zero.mp h₁] ["with", ident h, ident h],
  { linarith [] [] ["[", expr pow_eq_zero h, "]"] },
  { have [] [":", expr «expr < »(cos exprπ(), cos «expr / »(exprπ(), 3))] [],
    { refine [expr cos_lt_cos_of_nonneg_of_le_pi _ rfl.ge _]; linarith [] [] ["[", expr pi_pos, "]"] },
    linarith [] [] ["[", expr cos_pi, "]"] }
end

-- error in Analysis.SpecialFunctions.Trigonometric.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The square of the cosine of `π / 6` is `3 / 4` (this is sometimes more convenient than the
result for cosine itself). -/
theorem sq_cos_pi_div_six : «expr = »(«expr ^ »(cos «expr / »(exprπ(), 6), 2), «expr / »(3, 4)) :=
begin
  have [ident h1] [":", expr «expr = »(«expr ^ »(cos «expr / »(exprπ(), 6), 2), «expr + »(«expr / »(1, 2), «expr / »(«expr / »(1, 2), 2)))] [],
  { convert [] [expr cos_sq «expr / »(exprπ(), 6)] [],
    have [ident h2] [":", expr «expr = »(«expr * »(2, «expr / »(exprπ(), 6)), «expr / »(exprπ(), 3))] [":=", expr by cancel_denoms []],
    rw ["[", expr h2, ",", expr cos_pi_div_three, "]"] [] },
  rw ["<-", expr sub_eq_zero] ["at", ident h1, "⊢"],
  convert [] [expr h1] ["using", 1],
  ring []
end

-- error in Analysis.SpecialFunctions.Trigonometric.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The cosine of `π / 6` is `√3 / 2`. -/
@[simp]
theorem cos_pi_div_six : «expr = »(cos «expr / »(exprπ(), 6), «expr / »(sqrt 3, 2)) :=
begin
  suffices [] [":", expr «expr = »(sqrt 3, «expr * »(cos «expr / »(exprπ(), 6), 2))],
  { field_simp [] ["[", expr (by norm_num [] [] : «expr ≠ »(0, 2)), "]"] [] [],
    exact [expr this.symm] },
  rw [expr sqrt_eq_iff_sq_eq] [],
  { have [ident h1] [] [":=", expr (mul_right_inj' (by norm_num [] [] : «expr ≠ »((4 : exprℝ()), 0))).mpr sq_cos_pi_div_six],
    rw ["<-", expr sub_eq_zero] ["at", ident h1, "⊢"],
    convert [] [expr h1] ["using", 1],
    ring [] },
  { norm_num [] [] },
  { have [] [":", expr «expr < »(0, cos «expr / »(exprπ(), 6))] [":=", expr by { apply [expr cos_pos_of_mem_Ioo]; split; linarith [] [] ["[", expr pi_pos, "]"] }],
    linarith [] [] [] }
end

/-- The sine of `π / 6` is `1 / 2`. -/
@[simp]
theorem sin_pi_div_six : sin (π / 6) = 1 / 2 :=
  by 
    rw [←cos_pi_div_two_sub, ←cos_pi_div_three]
    congr 
    ring

/-- The square of the sine of `π / 3` is `3 / 4` (this is sometimes more convenient than the
result for cosine itself). -/
theorem sq_sin_pi_div_three : (sin (π / 3)^2) = 3 / 4 :=
  by 
    rw [←cos_pi_div_two_sub, ←sq_cos_pi_div_six]
    congr 
    ring

/-- The sine of `π / 3` is `√3 / 2`. -/
@[simp]
theorem sin_pi_div_three : sin (π / 3) = sqrt 3 / 2 :=
  by 
    rw [←cos_pi_div_two_sub, ←cos_pi_div_six]
    congr 
    ring

end CosDivSq

/-- `real.sin` as an `order_iso` between `[-(π / 2), π / 2]` and `[-1, 1]`. -/
def sin_order_iso : Icc (-(π / 2)) (π / 2) ≃o Icc (-1 : ℝ) 1 :=
  (strict_mono_on_sin.OrderIso _ _).trans$ OrderIso.setCongr _ _ bij_on_sin.image_eq

@[simp]
theorem coe_sin_order_iso_apply (x : Icc (-(π / 2)) (π / 2)) : (sin_order_iso x : ℝ) = sin x :=
  rfl

theorem sin_order_iso_apply (x : Icc (-(π / 2)) (π / 2)) : sin_order_iso x = ⟨sin x, sin_mem_Icc x⟩ :=
  rfl

-- error in Analysis.SpecialFunctions.Trigonometric.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp] theorem tan_pi_div_four : «expr = »(tan «expr / »(exprπ(), 4), 1) :=
begin
  rw ["[", expr tan_eq_sin_div_cos, ",", expr cos_pi_div_four, ",", expr sin_pi_div_four, "]"] [],
  have [ident h] [":", expr «expr > »(«expr / »(sqrt 2, 2), 0)] [":=", expr by cancel_denoms []],
  exact [expr div_self (ne_of_gt h)]
end

@[simp]
theorem tan_pi_div_two : tan (π / 2) = 0 :=
  by 
    simp [tan_eq_sin_div_cos]

theorem tan_pos_of_pos_of_lt_pi_div_two {x : ℝ} (h0x : 0 < x) (hxp : x < π / 2) : 0 < tan x :=
  by 
    rw [tan_eq_sin_div_cos] <;>
      exact
        div_pos
          (sin_pos_of_pos_of_lt_pi h0x
            (by 
              linarith))
          (cos_pos_of_mem_Ioo
            ⟨by 
                linarith,
              hxp⟩)

theorem tan_nonneg_of_nonneg_of_le_pi_div_two {x : ℝ} (h0x : 0 ≤ x) (hxp : x ≤ π / 2) : 0 ≤ tan x :=
  match lt_or_eq_of_leₓ h0x, lt_or_eq_of_leₓ hxp with 
  | Or.inl hx0, Or.inl hxp => le_of_ltₓ (tan_pos_of_pos_of_lt_pi_div_two hx0 hxp)
  | Or.inl hx0, Or.inr hxp =>
    by 
      simp [hxp, tan_eq_sin_div_cos]
  | Or.inr hx0, _ =>
    by 
      simp [hx0.symm]

theorem tan_neg_of_neg_of_pi_div_two_lt {x : ℝ} (hx0 : x < 0) (hpx : -(π / 2) < x) : tan x < 0 :=
  neg_pos.1
    (tan_neg x ▸
      tan_pos_of_pos_of_lt_pi_div_two
        (by 
          linarith)
        (by 
          linarith [pi_pos]))

theorem tan_nonpos_of_nonpos_of_neg_pi_div_two_le {x : ℝ} (hx0 : x ≤ 0) (hpx : -(π / 2) ≤ x) : tan x ≤ 0 :=
  neg_nonneg.1
    (tan_neg x ▸
      tan_nonneg_of_nonneg_of_le_pi_div_two
        (by 
          linarith)
        (by 
          linarith))

theorem tan_lt_tan_of_nonneg_of_lt_pi_div_two {x y : ℝ} (hx₁ : 0 ≤ x) (hy₂ : y < π / 2) (hxy : x < y) : tan x < tan y :=
  by 
    rw [tan_eq_sin_div_cos, tan_eq_sin_div_cos]
    exact
      div_lt_div
        (sin_lt_sin_of_lt_of_le_pi_div_two
          (by 
            linarith)
          (le_of_ltₓ hy₂) hxy)
        (cos_le_cos_of_nonneg_of_le_pi hx₁
          (by 
            linarith)
          (le_of_ltₓ hxy))
        (sin_nonneg_of_nonneg_of_le_pi
          (by 
            linarith)
          (by 
            linarith))
        (cos_pos_of_mem_Ioo
          ⟨by 
              linarith,
            hy₂⟩)

theorem tan_lt_tan_of_lt_of_lt_pi_div_two {x y : ℝ} (hx₁ : -(π / 2) < x) (hy₂ : y < π / 2) (hxy : x < y) :
  tan x < tan y :=
  match le_totalₓ x 0, le_totalₓ y 0 with 
  | Or.inl hx0, Or.inl hy0 =>
    neg_lt_neg_iff.1$
      by 
        rw [←tan_neg, ←tan_neg] <;>
          exact tan_lt_tan_of_nonneg_of_lt_pi_div_two (neg_nonneg.2 hy0) (neg_lt.2 hx₁) (neg_lt_neg hxy)
  | Or.inl hx0, Or.inr hy0 =>
    (lt_or_eq_of_leₓ hy0).elim
      (fun hy0 =>
        calc tan x ≤ 0 := tan_nonpos_of_nonpos_of_neg_pi_div_two_le hx0 (le_of_ltₓ hx₁)
          _ < tan y := tan_pos_of_pos_of_lt_pi_div_two hy0 hy₂
          )
      fun hy0 =>
        by 
          rw [←hy0, tan_zero] <;> exact tan_neg_of_neg_of_pi_div_two_lt (hy0.symm ▸ hxy) hx₁
  | Or.inr hx0, Or.inl hy0 =>
    by 
      linarith
  | Or.inr hx0, Or.inr hy0 => tan_lt_tan_of_nonneg_of_lt_pi_div_two hx0 hy₂ hxy

theorem strict_mono_on_tan : StrictMonoOn tan (Ioo (-(π / 2)) (π / 2)) :=
  fun x hx y hy => tan_lt_tan_of_lt_of_lt_pi_div_two hx.1 hy.2

theorem inj_on_tan : inj_on tan (Ioo (-(π / 2)) (π / 2)) :=
  strict_mono_on_tan.InjOn

theorem tan_inj_of_lt_of_lt_pi_div_two {x y : ℝ} (hx₁ : -(π / 2) < x) (hx₂ : x < π / 2) (hy₁ : -(π / 2) < y)
  (hy₂ : y < π / 2) (hxy : tan x = tan y) : x = y :=
  inj_on_tan ⟨hx₁, hx₂⟩ ⟨hy₁, hy₂⟩ hxy

theorem tan_periodic : Function.Periodic tan π :=
  by 
    simpa only [Function.Periodic, tan_eq_sin_div_cos] using sin_antiperiodic.div cos_antiperiodic

theorem tan_add_pi (x : ℝ) : tan (x+π) = tan x :=
  tan_periodic x

theorem tan_sub_pi (x : ℝ) : tan (x - π) = tan x :=
  tan_periodic.sub_eq x

theorem tan_pi_sub (x : ℝ) : tan (π - x) = -tan x :=
  tan_neg x ▸ tan_periodic.sub_eq'

theorem tan_nat_mul_pi (n : ℕ) : tan (n*π) = 0 :=
  tan_zero ▸ tan_periodic.nat_mul_eq n

theorem tan_int_mul_pi (n : ℤ) : tan (n*π) = 0 :=
  tan_zero ▸ tan_periodic.int_mul_eq n

theorem tan_add_nat_mul_pi (x : ℝ) (n : ℕ) : tan (x+n*π) = tan x :=
  tan_periodic.nat_mul n x

theorem tan_add_int_mul_pi (x : ℝ) (n : ℤ) : tan (x+n*π) = tan x :=
  tan_periodic.int_mul n x

theorem tan_sub_nat_mul_pi (x : ℝ) (n : ℕ) : tan (x - n*π) = tan x :=
  tan_periodic.sub_nat_mul_eq n

theorem tan_sub_int_mul_pi (x : ℝ) (n : ℤ) : tan (x - n*π) = tan x :=
  tan_periodic.sub_int_mul_eq n

theorem tan_nat_mul_pi_sub (x : ℝ) (n : ℕ) : tan ((n*π) - x) = -tan x :=
  tan_neg x ▸ tan_periodic.nat_mul_sub_eq n

theorem tan_int_mul_pi_sub (x : ℝ) (n : ℤ) : tan ((n*π) - x) = -tan x :=
  tan_neg x ▸ tan_periodic.int_mul_sub_eq n

theorem tendsto_sin_pi_div_two : tendsto sin (𝓝[Iio (π / 2)] (π / 2)) (𝓝 1) :=
  by 
    convert continuous_sin.continuous_within_at 
    simp 

theorem tendsto_cos_pi_div_two : tendsto cos (𝓝[Iio (π / 2)] (π / 2)) (𝓝[Ioi 0] 0) :=
  by 
    apply tendsto_nhds_within_of_tendsto_nhds_of_eventually_within
    ·
      convert continuous_cos.continuous_within_at 
      simp 
    ·
      filterUpwards [Ioo_mem_nhds_within_Iio (right_mem_Ioc.mpr (NormNum.lt_neg_pos _ _ pi_div_two_pos pi_div_two_pos))]
        fun x hx => cos_pos_of_mem_Ioo hx

theorem tendsto_tan_pi_div_two : tendsto tan (𝓝[Iio (π / 2)] (π / 2)) at_top :=
  by 
    convert tendsto_cos_pi_div_two.inv_tendsto_zero.at_top_mul zero_lt_one tendsto_sin_pi_div_two 
    simp only [Pi.inv_apply, ←div_eq_inv_mul, ←tan_eq_sin_div_cos]

theorem tendsto_sin_neg_pi_div_two : tendsto sin (𝓝[Ioi (-(π / 2))] -(π / 2)) (𝓝 (-1)) :=
  by 
    convert continuous_sin.continuous_within_at 
    simp 

theorem tendsto_cos_neg_pi_div_two : tendsto cos (𝓝[Ioi (-(π / 2))] -(π / 2)) (𝓝[Ioi 0] 0) :=
  by 
    apply tendsto_nhds_within_of_tendsto_nhds_of_eventually_within
    ·
      convert continuous_cos.continuous_within_at 
      simp 
    ·
      filterUpwards [Ioo_mem_nhds_within_Ioi (left_mem_Ico.mpr (NormNum.lt_neg_pos _ _ pi_div_two_pos pi_div_two_pos))]
        fun x hx => cos_pos_of_mem_Ioo hx

theorem tendsto_tan_neg_pi_div_two : tendsto tan (𝓝[Ioi (-(π / 2))] -(π / 2)) at_bot :=
  by 
    convert
      tendsto_cos_neg_pi_div_two.inv_tendsto_zero.at_top_mul_neg
        (by 
          normNum)
        tendsto_sin_neg_pi_div_two 
    simp only [Pi.inv_apply, ←div_eq_inv_mul, ←tan_eq_sin_div_cos]

end Real

namespace Complex

open_locale Real

theorem sin_eq_zero_iff_cos_eq {z : ℂ} : sin z = 0 ↔ cos z = 1 ∨ cos z = -1 :=
  by 
    rw [←mul_self_eq_one_iff, ←sin_sq_add_cos_sq, sq, sq, ←sub_eq_iff_eq_add, sub_self] <;>
      exact
        ⟨fun h =>
            by 
              rw [h, mul_zero],
          eq_zero_of_mul_self_eq_zero ∘ Eq.symm⟩

@[simp]
theorem cos_pi_div_two : cos (π / 2) = 0 :=
  calc cos (π / 2) = Real.cos (π / 2) :=
    by 
      rw [of_real_cos] <;> simp 
    _ = 0 :=
    by 
      simp 
    

@[simp]
theorem sin_pi_div_two : sin (π / 2) = 1 :=
  calc sin (π / 2) = Real.sin (π / 2) :=
    by 
      rw [of_real_sin] <;> simp 
    _ = 1 :=
    by 
      simp 
    

@[simp]
theorem sin_pi : sin π = 0 :=
  by 
    rw [←of_real_sin, Real.sin_pi] <;> simp 

@[simp]
theorem cos_pi : cos π = -1 :=
  by 
    rw [←of_real_cos, Real.cos_pi] <;> simp 

@[simp]
theorem sin_two_pi : sin (2*π) = 0 :=
  by 
    simp [two_mul, sin_add]

@[simp]
theorem cos_two_pi : cos (2*π) = 1 :=
  by 
    simp [two_mul, cos_add]

theorem sin_antiperiodic : Function.Antiperiodic sin π :=
  by 
    simp [sin_add]

theorem sin_periodic : Function.Periodic sin (2*π) :=
  sin_antiperiodic.Periodic

theorem sin_add_pi (x : ℂ) : sin (x+π) = -sin x :=
  sin_antiperiodic x

theorem sin_add_two_pi (x : ℂ) : sin (x+2*π) = sin x :=
  sin_periodic x

theorem sin_sub_pi (x : ℂ) : sin (x - π) = -sin x :=
  sin_antiperiodic.sub_eq x

theorem sin_sub_two_pi (x : ℂ) : sin (x - 2*π) = sin x :=
  sin_periodic.sub_eq x

theorem sin_pi_sub (x : ℂ) : sin (π - x) = sin x :=
  neg_negₓ (sin x) ▸ sin_neg x ▸ sin_antiperiodic.sub_eq'

theorem sin_two_pi_sub (x : ℂ) : sin ((2*π) - x) = -sin x :=
  sin_neg x ▸ sin_periodic.sub_eq'

theorem sin_nat_mul_pi (n : ℕ) : sin (n*π) = 0 :=
  sin_antiperiodic.nat_mul_eq_of_eq_zero sin_zero n

theorem sin_int_mul_pi (n : ℤ) : sin (n*π) = 0 :=
  sin_antiperiodic.int_mul_eq_of_eq_zero sin_zero n

theorem sin_add_nat_mul_two_pi (x : ℂ) (n : ℕ) : sin (x+n*2*π) = sin x :=
  sin_periodic.nat_mul n x

theorem sin_add_int_mul_two_pi (x : ℂ) (n : ℤ) : sin (x+n*2*π) = sin x :=
  sin_periodic.int_mul n x

theorem sin_sub_nat_mul_two_pi (x : ℂ) (n : ℕ) : sin (x - n*2*π) = sin x :=
  sin_periodic.sub_nat_mul_eq n

theorem sin_sub_int_mul_two_pi (x : ℂ) (n : ℤ) : sin (x - n*2*π) = sin x :=
  sin_periodic.sub_int_mul_eq n

theorem sin_nat_mul_two_pi_sub (x : ℂ) (n : ℕ) : sin ((n*2*π) - x) = -sin x :=
  sin_neg x ▸ sin_periodic.nat_mul_sub_eq n

theorem sin_int_mul_two_pi_sub (x : ℂ) (n : ℤ) : sin ((n*2*π) - x) = -sin x :=
  sin_neg x ▸ sin_periodic.int_mul_sub_eq n

theorem cos_antiperiodic : Function.Antiperiodic cos π :=
  by 
    simp [cos_add]

theorem cos_periodic : Function.Periodic cos (2*π) :=
  cos_antiperiodic.Periodic

theorem cos_add_pi (x : ℂ) : cos (x+π) = -cos x :=
  cos_antiperiodic x

theorem cos_add_two_pi (x : ℂ) : cos (x+2*π) = cos x :=
  cos_periodic x

theorem cos_sub_pi (x : ℂ) : cos (x - π) = -cos x :=
  cos_antiperiodic.sub_eq x

theorem cos_sub_two_pi (x : ℂ) : cos (x - 2*π) = cos x :=
  cos_periodic.sub_eq x

theorem cos_pi_sub (x : ℂ) : cos (π - x) = -cos x :=
  cos_neg x ▸ cos_antiperiodic.sub_eq'

theorem cos_two_pi_sub (x : ℂ) : cos ((2*π) - x) = cos x :=
  cos_neg x ▸ cos_periodic.sub_eq'

theorem cos_nat_mul_two_pi (n : ℕ) : cos (n*2*π) = 1 :=
  (cos_periodic.nat_mul_eq n).trans cos_zero

theorem cos_int_mul_two_pi (n : ℤ) : cos (n*2*π) = 1 :=
  (cos_periodic.int_mul_eq n).trans cos_zero

theorem cos_add_nat_mul_two_pi (x : ℂ) (n : ℕ) : cos (x+n*2*π) = cos x :=
  cos_periodic.nat_mul n x

theorem cos_add_int_mul_two_pi (x : ℂ) (n : ℤ) : cos (x+n*2*π) = cos x :=
  cos_periodic.int_mul n x

theorem cos_sub_nat_mul_two_pi (x : ℂ) (n : ℕ) : cos (x - n*2*π) = cos x :=
  cos_periodic.sub_nat_mul_eq n

theorem cos_sub_int_mul_two_pi (x : ℂ) (n : ℤ) : cos (x - n*2*π) = cos x :=
  cos_periodic.sub_int_mul_eq n

theorem cos_nat_mul_two_pi_sub (x : ℂ) (n : ℕ) : cos ((n*2*π) - x) = cos x :=
  cos_neg x ▸ cos_periodic.nat_mul_sub_eq n

theorem cos_int_mul_two_pi_sub (x : ℂ) (n : ℤ) : cos ((n*2*π) - x) = cos x :=
  cos_neg x ▸ cos_periodic.int_mul_sub_eq n

theorem cos_nat_mul_two_pi_add_pi (n : ℕ) : cos ((n*2*π)+π) = -1 :=
  by 
    simpa only [cos_zero] using (cos_periodic.nat_mul n).add_antiperiod_eq cos_antiperiodic

theorem cos_int_mul_two_pi_add_pi (n : ℤ) : cos ((n*2*π)+π) = -1 :=
  by 
    simpa only [cos_zero] using (cos_periodic.int_mul n).add_antiperiod_eq cos_antiperiodic

theorem cos_nat_mul_two_pi_sub_pi (n : ℕ) : cos ((n*2*π) - π) = -1 :=
  by 
    simpa only [cos_zero] using (cos_periodic.nat_mul n).sub_antiperiod_eq cos_antiperiodic

theorem cos_int_mul_two_pi_sub_pi (n : ℤ) : cos ((n*2*π) - π) = -1 :=
  by 
    simpa only [cos_zero] using (cos_periodic.int_mul n).sub_antiperiod_eq cos_antiperiodic

theorem sin_add_pi_div_two (x : ℂ) : sin (x+π / 2) = cos x :=
  by 
    simp [sin_add]

theorem sin_sub_pi_div_two (x : ℂ) : sin (x - π / 2) = -cos x :=
  by 
    simp [sub_eq_add_neg, sin_add]

theorem sin_pi_div_two_sub (x : ℂ) : sin (π / 2 - x) = cos x :=
  by 
    simp [sub_eq_add_neg, sin_add]

theorem cos_add_pi_div_two (x : ℂ) : cos (x+π / 2) = -sin x :=
  by 
    simp [cos_add]

theorem cos_sub_pi_div_two (x : ℂ) : cos (x - π / 2) = sin x :=
  by 
    simp [sub_eq_add_neg, cos_add]

theorem cos_pi_div_two_sub (x : ℂ) : cos (π / 2 - x) = sin x :=
  by 
    rw [←cos_neg, neg_sub, cos_sub_pi_div_two]

theorem tan_periodic : Function.Periodic tan π :=
  by 
    simpa only [tan_eq_sin_div_cos] using sin_antiperiodic.div cos_antiperiodic

theorem tan_add_pi (x : ℂ) : tan (x+π) = tan x :=
  tan_periodic x

theorem tan_sub_pi (x : ℂ) : tan (x - π) = tan x :=
  tan_periodic.sub_eq x

theorem tan_pi_sub (x : ℂ) : tan (π - x) = -tan x :=
  tan_neg x ▸ tan_periodic.sub_eq'

theorem tan_nat_mul_pi (n : ℕ) : tan (n*π) = 0 :=
  tan_zero ▸ tan_periodic.nat_mul_eq n

theorem tan_int_mul_pi (n : ℤ) : tan (n*π) = 0 :=
  tan_zero ▸ tan_periodic.int_mul_eq n

theorem tan_add_nat_mul_pi (x : ℂ) (n : ℕ) : tan (x+n*π) = tan x :=
  tan_periodic.nat_mul n x

theorem tan_add_int_mul_pi (x : ℂ) (n : ℤ) : tan (x+n*π) = tan x :=
  tan_periodic.int_mul n x

theorem tan_sub_nat_mul_pi (x : ℂ) (n : ℕ) : tan (x - n*π) = tan x :=
  tan_periodic.sub_nat_mul_eq n

theorem tan_sub_int_mul_pi (x : ℂ) (n : ℤ) : tan (x - n*π) = tan x :=
  tan_periodic.sub_int_mul_eq n

theorem tan_nat_mul_pi_sub (x : ℂ) (n : ℕ) : tan ((n*π) - x) = -tan x :=
  tan_neg x ▸ tan_periodic.nat_mul_sub_eq n

theorem tan_int_mul_pi_sub (x : ℂ) (n : ℤ) : tan ((n*π) - x) = -tan x :=
  tan_neg x ▸ tan_periodic.int_mul_sub_eq n

theorem exp_antiperiodic : Function.Antiperiodic exp (π*I) :=
  by 
    simp [exp_add, exp_mul_I]

theorem exp_periodic : Function.Periodic exp ((2*π)*I) :=
  (mul_assocₓ (2 : ℂ) π I).symm ▸ exp_antiperiodic.Periodic

theorem exp_mul_I_antiperiodic : Function.Antiperiodic (fun x => exp (x*I)) π :=
  by 
    simpa only [mul_inv_cancel_right₀ I_ne_zero] using exp_antiperiodic.mul_const I_ne_zero

theorem exp_mul_I_periodic : Function.Periodic (fun x => exp (x*I)) (2*π) :=
  exp_mul_I_antiperiodic.Periodic

@[simp]
theorem exp_pi_mul_I : exp (π*I) = -1 :=
  exp_zero ▸ exp_antiperiodic.Eq

@[simp]
theorem exp_two_pi_mul_I : exp ((2*π)*I) = 1 :=
  exp_periodic.Eq.trans exp_zero

@[simp]
theorem exp_nat_mul_two_pi_mul_I (n : ℕ) : exp (n*(2*π)*I) = 1 :=
  (exp_periodic.nat_mul_eq n).trans exp_zero

@[simp]
theorem exp_int_mul_two_pi_mul_I (n : ℤ) : exp (n*(2*π)*I) = 1 :=
  (exp_periodic.int_mul_eq n).trans exp_zero

@[simp]
theorem exp_add_pi_mul_I (z : ℂ) : exp (z+π*I) = -exp z :=
  exp_antiperiodic z

@[simp]
theorem exp_sub_pi_mul_I (z : ℂ) : exp (z - π*I) = -exp z :=
  exp_antiperiodic.sub_eq z

end Complex

