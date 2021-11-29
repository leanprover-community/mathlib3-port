import Mathbin.Topology.Instances.Nnreal 
import Mathbin.Topology.Algebra.Ordered.MonotoneContinuity

/-!
# Square root of a real number

In this file we define

* `nnreal.sqrt` to be the square root of a nonnegative real number.
* `real.sqrt` to be the square root of a real number, defined to be zero on negative numbers.

Then we prove some basic properties of these functions.

## Implementation notes

We define `nnreal.sqrt` as the noncomputable inverse to the function `x ↦ x * x`. We use general
theory of inverses of strictly monotone functions to prove that `nnreal.sqrt x` exists. As a side
effect, `nnreal.sqrt` is a bundled `order_iso`, so for `nnreal` numbers we get continuity as well as
theorems like `sqrt x ≤ y ↔ x * x ≤ y` for free.

Then we define `real.sqrt x` to be `nnreal.sqrt (real.to_nnreal x)`. We also define a Cauchy
sequence `real.sqrt_aux (f : cau_seq ℚ abs)` which converges to `sqrt (mk f)` but do not prove (yet)
that this sequence actually converges to `sqrt (mk f)`.

## Tags

square root
-/


open Set Filter

open_locale Filter Nnreal TopologicalSpace

namespace Nnreal

variable{x y :  ℝ≥0 }

/-- Square root of a nonnegative real number. -/
@[pp_nodot]
noncomputable def sqrt :  ℝ≥0  ≃o  ℝ≥0  :=
  OrderIso.symm$
    (StrictMono.orderIsoOfSurjective (fun x => x*x) fun x y h => mul_self_lt_mul_self x.2 h)$
      (continuous_id.mul continuous_id).Surjective tendsto_mul_self_at_top$
        by 
          simp [order_bot.at_bot_eq]

theorem sqrt_le_sqrt_iff : sqrt x ≤ sqrt y ↔ x ≤ y :=
  sqrt.le_iff_le

theorem sqrt_lt_sqrt_iff : sqrt x < sqrt y ↔ x < y :=
  sqrt.lt_iff_lt

theorem sqrt_eq_iff_sq_eq : sqrt x = y ↔ (y*y) = x :=
  sqrt.toEquiv.apply_eq_iff_eq_symm_apply.trans eq_comm

theorem sqrt_le_iff : sqrt x ≤ y ↔ x ≤ y*y :=
  sqrt.to_galois_connection _ _

theorem le_sqrt_iff : x ≤ sqrt y ↔ (x*x) ≤ y :=
  (sqrt.symm.to_galois_connection _ _).symm

@[simp]
theorem sqrt_eq_zero : sqrt x = 0 ↔ x = 0 :=
  sqrt_eq_iff_sq_eq.trans$
    by 
      rw [eq_comm, zero_mul]

@[simp]
theorem sqrt_zero : sqrt 0 = 0 :=
  sqrt_eq_zero.2 rfl

@[simp]
theorem sqrt_one : sqrt 1 = 1 :=
  sqrt_eq_iff_sq_eq.2$ mul_oneₓ 1

@[simp]
theorem mul_self_sqrt (x :  ℝ≥0 ) : (sqrt x*sqrt x) = x :=
  sqrt.symm_apply_apply x

@[simp]
theorem sqrt_mul_self (x :  ℝ≥0 ) : sqrt (x*x) = x :=
  sqrt.apply_symm_apply x

@[simp]
theorem sq_sqrt (x :  ℝ≥0 ) : sqrt x ^ 2 = x :=
  by 
    rw [sq, mul_self_sqrt x]

@[simp]
theorem sqrt_sq (x :  ℝ≥0 ) : sqrt (x ^ 2) = x :=
  by 
    rw [sq, sqrt_mul_self x]

theorem sqrt_mul (x y :  ℝ≥0 ) : sqrt (x*y) = sqrt x*sqrt y :=
  by 
    rw [sqrt_eq_iff_sq_eq, mul_mul_mul_commₓ, mul_self_sqrt, mul_self_sqrt]

/-- `nnreal.sqrt` as a `monoid_with_zero_hom`. -/
noncomputable def sqrt_hom : MonoidWithZeroHom ℝ≥0  ℝ≥0  :=
  ⟨sqrt, sqrt_zero, sqrt_one, sqrt_mul⟩

theorem sqrt_inv (x :  ℝ≥0 ) : sqrt (x⁻¹) = sqrt x⁻¹ :=
  sqrt_hom.map_inv x

theorem sqrt_div (x y :  ℝ≥0 ) : sqrt (x / y) = sqrt x / sqrt y :=
  sqrt_hom.map_div x y

theorem continuous_sqrt : Continuous sqrt :=
  sqrt.Continuous

end Nnreal

namespace Real

/-- An auxiliary sequence of rational numbers that converges to `real.sqrt (mk f)`.
Currently this sequence is not used in `mathlib`.  -/
def sqrt_aux (f : CauSeq ℚ abs) : ℕ → ℚ
| 0 => Rat.mkNat (f 0).num.toNat.sqrt (f 0).denom.sqrt
| n+1 =>
  let s := sqrt_aux n 
  max 0$ (s+f (n+1) / s) / 2

theorem sqrt_aux_nonneg (f : CauSeq ℚ abs) : ∀ (i : ℕ), 0 ≤ sqrt_aux f i
| 0 =>
  by 
    rw [sqrt_aux, Rat.mk_nat_eq, Rat.mk_eq_div] <;> apply div_nonneg <;> exact Int.cast_nonneg.2 (Int.of_nat_nonneg _)
| n+1 => le_max_leftₓ _ _

/-- The square root of a real number. This returns 0 for negative inputs. -/
@[pp_nodot]
noncomputable def sqrt (x : ℝ) : ℝ :=
  Nnreal.sqrt (Real.toNnreal x)

variable{x y : ℝ}

@[simp, normCast]
theorem coe_sqrt {x :  ℝ≥0 } : (Nnreal.sqrt x : ℝ) = Real.sqrt x :=
  by 
    rw [Real.sqrt, Real.to_nnreal_coe]

@[continuity]
theorem continuous_sqrt : Continuous sqrt :=
  Nnreal.continuous_coe.comp$ Nnreal.sqrt.Continuous.comp Nnreal.continuous_of_real

theorem sqrt_eq_zero_of_nonpos (h : x ≤ 0) : sqrt x = 0 :=
  by 
    simp [sqrt, Real.to_nnreal_eq_zero.2 h]

theorem sqrt_nonneg (x : ℝ) : 0 ≤ sqrt x :=
  Nnreal.coe_nonneg _

@[simp]
theorem mul_self_sqrt (h : 0 ≤ x) : (sqrt x*sqrt x) = x :=
  by 
    rw [sqrt, ←Nnreal.coe_mul, Nnreal.mul_self_sqrt, Real.coe_to_nnreal _ h]

@[simp]
theorem sqrt_mul_self (h : 0 ≤ x) : sqrt (x*x) = x :=
  (mul_self_inj_of_nonneg (sqrt_nonneg _) h).1 (mul_self_sqrt (mul_self_nonneg _))

theorem sqrt_eq_iff_mul_self_eq (hx : 0 ≤ x) (hy : 0 ≤ y) : sqrt x = y ↔ (y*y) = x :=
  ⟨fun h =>
      by 
        rw [←h, mul_self_sqrt hx],
    fun h =>
      by 
        rw [←h, sqrt_mul_self hy]⟩

@[simp]
theorem sq_sqrt (h : 0 ≤ x) : sqrt x ^ 2 = x :=
  by 
    rw [sq, mul_self_sqrt h]

@[simp]
theorem sqrt_sq (h : 0 ≤ x) : sqrt (x ^ 2) = x :=
  by 
    rw [sq, sqrt_mul_self h]

theorem sqrt_eq_iff_sq_eq (hx : 0 ≤ x) (hy : 0 ≤ y) : sqrt x = y ↔ y ^ 2 = x :=
  by 
    rw [sq, sqrt_eq_iff_mul_self_eq hx hy]

theorem sqrt_mul_self_eq_abs (x : ℝ) : sqrt (x*x) = |x| :=
  by 
    rw [←abs_mul_abs_self x, sqrt_mul_self (abs_nonneg _)]

theorem sqrt_sq_eq_abs (x : ℝ) : sqrt (x ^ 2) = |x| :=
  by 
    rw [sq, sqrt_mul_self_eq_abs]

@[simp]
theorem sqrt_zero : sqrt 0 = 0 :=
  by 
    simp [sqrt]

@[simp]
theorem sqrt_one : sqrt 1 = 1 :=
  by 
    simp [sqrt]

@[simp]
theorem sqrt_le_sqrt_iff (hy : 0 ≤ y) : sqrt x ≤ sqrt y ↔ x ≤ y :=
  by 
    rw [sqrt, sqrt, Nnreal.coe_le_coe, Nnreal.sqrt_le_sqrt_iff, Real.to_nnreal_le_to_nnreal_iff hy]

@[simp]
theorem sqrt_lt_sqrt_iff (hx : 0 ≤ x) : sqrt x < sqrt y ↔ x < y :=
  lt_iff_lt_of_le_iff_le (sqrt_le_sqrt_iff hx)

theorem sqrt_lt_sqrt_iff_of_pos (hy : 0 < y) : sqrt x < sqrt y ↔ x < y :=
  by 
    rw [sqrt, sqrt, Nnreal.coe_lt_coe, Nnreal.sqrt_lt_sqrt_iff, to_nnreal_lt_to_nnreal_iff hy]

theorem sqrt_le_sqrt (h : x ≤ y) : sqrt x ≤ sqrt y :=
  by 
    rw [sqrt, sqrt, Nnreal.coe_le_coe, Nnreal.sqrt_le_sqrt_iff]
    exact to_nnreal_le_to_nnreal h

theorem sqrt_lt_sqrt (hx : 0 ≤ x) (h : x < y) : sqrt x < sqrt y :=
  (sqrt_lt_sqrt_iff hx).2 h

theorem sqrt_le_left (hy : 0 ≤ y) : sqrt x ≤ y ↔ x ≤ y ^ 2 :=
  by 
    rw [sqrt, ←Real.le_to_nnreal_iff_coe_le hy, Nnreal.sqrt_le_iff, ←Real.to_nnreal_mul hy,
      Real.to_nnreal_le_to_nnreal_iff (mul_self_nonneg y), sq]

theorem sqrt_le_iff : sqrt x ≤ y ↔ 0 ≤ y ∧ x ≤ y ^ 2 :=
  by 
    rw [←and_iff_right_of_imp fun h => (sqrt_nonneg x).trans h, And.congr_right_iff]
    exact sqrt_le_left

theorem le_sqrt (hx : 0 ≤ x) (hy : 0 ≤ y) : x ≤ sqrt y ↔ x ^ 2 ≤ y :=
  by 
    rw [mul_self_le_mul_self_iff hx (sqrt_nonneg _), sq, mul_self_sqrt hy]

theorem le_sqrt' (hx : 0 < x) : x ≤ sqrt y ↔ x ^ 2 ≤ y :=
  by 
    rw [sqrt, ←Nnreal.coe_mk x hx.le, Nnreal.coe_le_coe, Nnreal.le_sqrt_iff, Real.le_to_nnreal_iff_coe_le', sq,
      Nnreal.coe_mul]
    exact mul_pos hx hx

theorem abs_le_sqrt (h : x ^ 2 ≤ y) : |x| ≤ sqrt y :=
  by 
    rw [←sqrt_sq_eq_abs] <;> exact sqrt_le_sqrt h

theorem sq_le (h : 0 ≤ y) : x ^ 2 ≤ y ↔ -sqrt y ≤ x ∧ x ≤ sqrt y :=
  by 
    split 
    ·
      simpa only [abs_le] using abs_le_sqrt
    ·
      rw [←abs_le, ←sq_abs]
      exact (le_sqrt (abs_nonneg x) h).mp

theorem neg_sqrt_le_of_sq_le (h : x ^ 2 ≤ y) : -sqrt y ≤ x :=
  ((sq_le ((sq_nonneg x).trans h)).mp h).1

theorem le_sqrt_of_sq_le (h : x ^ 2 ≤ y) : x ≤ sqrt y :=
  ((sq_le ((sq_nonneg x).trans h)).mp h).2

@[simp]
theorem sqrt_inj (hx : 0 ≤ x) (hy : 0 ≤ y) : sqrt x = sqrt y ↔ x = y :=
  by 
    simp [le_antisymm_iffₓ, hx, hy]

@[simp]
theorem sqrt_eq_zero (h : 0 ≤ x) : sqrt x = 0 ↔ x = 0 :=
  by 
    simpa using sqrt_inj h (le_reflₓ _)

theorem sqrt_eq_zero' : sqrt x = 0 ↔ x ≤ 0 :=
  by 
    rw [sqrt, Nnreal.coe_eq_zero, Nnreal.sqrt_eq_zero, Real.to_nnreal_eq_zero]

theorem sqrt_ne_zero (h : 0 ≤ x) : sqrt x ≠ 0 ↔ x ≠ 0 :=
  by 
    rw [not_iff_not, sqrt_eq_zero h]

theorem sqrt_ne_zero' : sqrt x ≠ 0 ↔ 0 < x :=
  by 
    rw [←not_leₓ, not_iff_not, sqrt_eq_zero']

@[simp]
theorem sqrt_pos : 0 < sqrt x ↔ 0 < x :=
  lt_iff_lt_of_le_iff_le
    (Iff.trans
      (by 
        simp [le_antisymm_iffₓ, sqrt_nonneg])
      sqrt_eq_zero')

@[simp]
theorem sqrt_mul (hx : 0 ≤ x) (y : ℝ) : sqrt (x*y) = sqrt x*sqrt y :=
  by 
    simpRw [sqrt, ←Nnreal.coe_mul, Nnreal.coe_eq, Real.to_nnreal_mul hx, Nnreal.sqrt_mul]

@[simp]
theorem sqrt_mul' x {y : ℝ} (hy : 0 ≤ y) : sqrt (x*y) = sqrt x*sqrt y :=
  by 
    rw [mul_commₓ, sqrt_mul hy, mul_commₓ]

@[simp]
theorem sqrt_inv (x : ℝ) : sqrt (x⁻¹) = sqrt x⁻¹ :=
  by 
    rw [sqrt, Real.to_nnreal_inv, Nnreal.sqrt_inv, Nnreal.coe_inv, sqrt]

@[simp]
theorem sqrt_div (hx : 0 ≤ x) (y : ℝ) : sqrt (x / y) = sqrt x / sqrt y :=
  by 
    rw [division_def, sqrt_mul hx, sqrt_inv, division_def]

@[simp]
theorem div_sqrt : x / sqrt x = sqrt x :=
  by 
    cases le_or_ltₓ x 0
    ·
      rw [sqrt_eq_zero'.mpr h, div_zero]
    ·
      rw [div_eq_iff (sqrt_ne_zero'.mpr h), mul_self_sqrt h.le]

theorem sqrt_div_self' : sqrt x / x = 1 / sqrt x :=
  by 
    rw [←div_sqrt, one_div_div, div_sqrt]

theorem sqrt_div_self : sqrt x / x = sqrt x⁻¹ :=
  by 
    rw [sqrt_div_self', one_div]

theorem lt_sqrt (hx : 0 ≤ x) (hy : 0 ≤ y) : x < sqrt y ↔ x ^ 2 < y :=
  by 
    rw [mul_self_lt_mul_self_iff hx (sqrt_nonneg y), sq, mul_self_sqrt hy]

theorem sq_lt : x ^ 2 < y ↔ -sqrt y < x ∧ x < sqrt y :=
  by 
    split 
    ·
      simpa only [←sqrt_lt_sqrt_iff (sq_nonneg x), sqrt_sq_eq_abs] using abs_lt.mp
    ·
      rw [←abs_lt, ←sq_abs]
      exact fun h => (lt_sqrt (abs_nonneg x) (sqrt_pos.mp (lt_of_le_of_ltₓ (abs_nonneg x) h)).le).mp h

theorem neg_sqrt_lt_of_sq_lt (h : x ^ 2 < y) : -sqrt y < x :=
  (sq_lt.mp h).1

theorem lt_sqrt_of_sq_lt (h : x ^ 2 < y) : x < sqrt y :=
  (sq_lt.mp h).2

end Real

open Real

variable{α : Type _}

theorem Filter.Tendsto.sqrt {f : α → ℝ} {l : Filter α} {x : ℝ} (h : tendsto f l (𝓝 x)) :
  tendsto (fun x => sqrt (f x)) l (𝓝 (sqrt x)) :=
  (continuous_sqrt.Tendsto _).comp h

variable[TopologicalSpace α]{f : α → ℝ}{s : Set α}{x : α}

theorem ContinuousWithinAt.sqrt (h : ContinuousWithinAt f s x) : ContinuousWithinAt (fun x => sqrt (f x)) s x :=
  h.sqrt

theorem ContinuousAt.sqrt (h : ContinuousAt f x) : ContinuousAt (fun x => sqrt (f x)) x :=
  h.sqrt

theorem ContinuousOn.sqrt (h : ContinuousOn f s) : ContinuousOn (fun x => sqrt (f x)) s :=
  fun x hx => (h x hx).sqrt

@[continuity]
theorem Continuous.sqrt (h : Continuous f) : Continuous fun x => sqrt (f x) :=
  continuous_sqrt.comp h

