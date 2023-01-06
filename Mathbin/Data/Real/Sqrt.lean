/-
Copyright (c) 2020 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Floris van Doorn, Yury Kudryashov

! This file was ported from Lean 3 source module data.real.sqrt
! leanprover-community/mathlib commit 26f081a2fb920140ed5bc5cc5344e84bcc7cb2b2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Algebra.Order.MonotoneContinuity
import Mathbin.Topology.Instances.Nnreal
import Mathbin.Tactic.Positivity

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
theorems like `sqrt x ≤ y ↔ x ≤ y * y` for free.

Then we define `real.sqrt x` to be `nnreal.sqrt (real.to_nnreal x)`. We also define a Cauchy
sequence `real.sqrt_aux (f : cau_seq ℚ abs)` which converges to `sqrt (mk f)` but do not prove (yet)
that this sequence actually converges to `sqrt (mk f)`.

## Tags

square root
-/


open Set Filter

open Filter Nnreal TopologicalSpace

namespace Nnreal

variable {x y : ℝ≥0}

/-- Square root of a nonnegative real number. -/
@[pp_nodot]
noncomputable def sqrt : ℝ≥0 ≃o ℝ≥0 :=
  OrderIso.symm <| powOrderIso 2 two_ne_zero
#align nnreal.sqrt Nnreal.sqrt

theorem sqrt_le_sqrt_iff : sqrt x ≤ sqrt y ↔ x ≤ y :=
  sqrt.le_iff_le
#align nnreal.sqrt_le_sqrt_iff Nnreal.sqrt_le_sqrt_iff

theorem sqrt_lt_sqrt_iff : sqrt x < sqrt y ↔ x < y :=
  sqrt.lt_iff_lt
#align nnreal.sqrt_lt_sqrt_iff Nnreal.sqrt_lt_sqrt_iff

theorem sqrt_eq_iff_sq_eq : sqrt x = y ↔ y ^ 2 = x :=
  sqrt.toEquiv.apply_eq_iff_eq_symm_apply.trans eq_comm
#align nnreal.sqrt_eq_iff_sq_eq Nnreal.sqrt_eq_iff_sq_eq

theorem sqrt_le_iff : sqrt x ≤ y ↔ x ≤ y ^ 2 :=
  sqrt.to_galois_connection _ _
#align nnreal.sqrt_le_iff Nnreal.sqrt_le_iff

theorem le_sqrt_iff : x ≤ sqrt y ↔ x ^ 2 ≤ y :=
  (sqrt.symm.to_galois_connection _ _).symm
#align nnreal.le_sqrt_iff Nnreal.le_sqrt_iff

@[simp]
theorem sqrt_eq_zero : sqrt x = 0 ↔ x = 0 :=
  sqrt_eq_iff_sq_eq.trans <| by rw [eq_comm, sq, zero_mul]
#align nnreal.sqrt_eq_zero Nnreal.sqrt_eq_zero

@[simp]
theorem sqrt_zero : sqrt 0 = 0 :=
  sqrt_eq_zero.2 rfl
#align nnreal.sqrt_zero Nnreal.sqrt_zero

@[simp]
theorem sqrt_one : sqrt 1 = 1 :=
  sqrt_eq_iff_sq_eq.2 <| one_pow _
#align nnreal.sqrt_one Nnreal.sqrt_one

@[simp]
theorem sq_sqrt (x : ℝ≥0) : sqrt x ^ 2 = x :=
  sqrt.symm_apply_apply x
#align nnreal.sq_sqrt Nnreal.sq_sqrt

@[simp]
theorem mul_self_sqrt (x : ℝ≥0) : sqrt x * sqrt x = x := by rw [← sq, sq_sqrt]
#align nnreal.mul_self_sqrt Nnreal.mul_self_sqrt

@[simp]
theorem sqrt_sq (x : ℝ≥0) : sqrt (x ^ 2) = x :=
  sqrt.apply_symm_apply x
#align nnreal.sqrt_sq Nnreal.sqrt_sq

@[simp]
theorem sqrt_mul_self (x : ℝ≥0) : sqrt (x * x) = x := by rw [← sq, sqrt_sq x]
#align nnreal.sqrt_mul_self Nnreal.sqrt_mul_self

theorem sqrt_mul (x y : ℝ≥0) : sqrt (x * y) = sqrt x * sqrt y := by
  rw [sqrt_eq_iff_sq_eq, mul_pow, sq_sqrt, sq_sqrt]
#align nnreal.sqrt_mul Nnreal.sqrt_mul

/-- `nnreal.sqrt` as a `monoid_with_zero_hom`. -/
noncomputable def sqrtHom : ℝ≥0 →*₀ ℝ≥0 :=
  ⟨sqrt, sqrt_zero, sqrt_one, sqrt_mul⟩
#align nnreal.sqrt_hom Nnreal.sqrtHom

theorem sqrt_inv (x : ℝ≥0) : sqrt x⁻¹ = (sqrt x)⁻¹ :=
  map_inv₀ sqrtHom x
#align nnreal.sqrt_inv Nnreal.sqrt_inv

theorem sqrt_div (x y : ℝ≥0) : sqrt (x / y) = sqrt x / sqrt y :=
  map_div₀ sqrtHom x y
#align nnreal.sqrt_div Nnreal.sqrt_div

theorem continuous_sqrt : Continuous sqrt :=
  sqrt.Continuous
#align nnreal.continuous_sqrt Nnreal.continuous_sqrt

end Nnreal

namespace Real

/-- An auxiliary sequence of rational numbers that converges to `real.sqrt (mk f)`.
Currently this sequence is not used in `mathlib`.  -/
def sqrtAux (f : CauSeq ℚ abs) : ℕ → ℚ
  | 0 => mkRat (f 0).num.toNat.sqrt (f 0).denom.sqrt
  | n + 1 =>
    let s := sqrt_aux n
    max 0 <| (s + f (n + 1) / s) / 2
#align real.sqrt_aux Real.sqrtAux

theorem sqrt_aux_nonneg (f : CauSeq ℚ abs) : ∀ i : ℕ, 0 ≤ sqrtAux f i
  | 0 => by
    rw [sqrt_aux, Rat.mkRat_eq, Rat.divInt_eq_div] <;> apply div_nonneg <;>
      exact Int.cast_nonneg.2 (Int.ofNat_nonneg _)
  | n + 1 => le_max_left _ _
#align real.sqrt_aux_nonneg Real.sqrt_aux_nonneg

/- TODO(Mario): finish the proof
theorem sqrt_aux_converges (f : cau_seq ℚ abs) : ∃ h x, 0 ≤ x ∧ x * x = max 0 (mk f) ∧
  mk ⟨sqrt_aux f, h⟩ = x :=
begin
  rcases sqrt_exists (le_max_left 0 (mk f)) with ⟨x, x0, hx⟩,
  suffices : ∃ h, mk ⟨sqrt_aux f, h⟩ = x,
  { exact this.imp (λ h e, ⟨x, x0, hx, e⟩) },
  apply of_near,

  rsuffices ⟨δ, δ0, hδ⟩ : ∃ δ > 0, ∀ i, abs (↑(sqrt_aux f i) - x) < δ / 2 ^ i,
  { intros }
end -/
/-- The square root of a real number. This returns 0 for negative inputs. -/
@[pp_nodot]
noncomputable def sqrt (x : ℝ) : ℝ :=
  Nnreal.sqrt (Real.toNnreal x)
#align real.sqrt Real.sqrt

/-quotient.lift_on x
  (λ f, mk ⟨sqrt_aux f, (sqrt_aux_converges f).fst⟩)
  (λ f g e, begin
    rcases sqrt_aux_converges f with ⟨hf, x, x0, xf, xs⟩,
    rcases sqrt_aux_converges g with ⟨hg, y, y0, yg, ys⟩,
    refine xs.trans (eq.trans _ ys.symm),
    rw [← @mul_self_inj_of_nonneg ℝ _ x y x0 y0, xf, yg],
    congr' 1, exact quotient.sound e
  end)-/
variable {x y : ℝ}

@[simp, norm_cast]
theorem coe_sqrt {x : ℝ≥0} : (Nnreal.sqrt x : ℝ) = Real.sqrt x := by
  rw [Real.sqrt, Real.to_nnreal_coe]
#align real.coe_sqrt Real.coe_sqrt

@[continuity]
theorem continuous_sqrt : Continuous sqrt :=
  Nnreal.continuous_coe.comp <| Nnreal.sqrt.Continuous.comp continuous_real_to_nnreal
#align real.continuous_sqrt Real.continuous_sqrt

theorem sqrt_eq_zero_of_nonpos (h : x ≤ 0) : sqrt x = 0 := by
  simp [sqrt, Real.to_nnreal_eq_zero.2 h]
#align real.sqrt_eq_zero_of_nonpos Real.sqrt_eq_zero_of_nonpos

theorem sqrt_nonneg (x : ℝ) : 0 ≤ sqrt x :=
  Nnreal.coe_nonneg _
#align real.sqrt_nonneg Real.sqrt_nonneg

@[simp]
theorem mul_self_sqrt (h : 0 ≤ x) : sqrt x * sqrt x = x := by
  rw [sqrt, ← Nnreal.coe_mul, Nnreal.mul_self_sqrt, Real.coe_to_nnreal _ h]
#align real.mul_self_sqrt Real.mul_self_sqrt

@[simp]
theorem sqrt_mul_self (h : 0 ≤ x) : sqrt (x * x) = x :=
  (mul_self_inj_of_nonneg (sqrt_nonneg _) h).1 (mul_self_sqrt (mul_self_nonneg _))
#align real.sqrt_mul_self Real.sqrt_mul_self

theorem sqrt_eq_cases : sqrt x = y ↔ y * y = x ∧ 0 ≤ y ∨ x < 0 ∧ y = 0 :=
  by
  constructor
  · rintro rfl
    cases' le_or_lt 0 x with hle hlt
    · exact Or.inl ⟨mul_self_sqrt hle, sqrt_nonneg x⟩
    · exact Or.inr ⟨hlt, sqrt_eq_zero_of_nonpos hlt.le⟩
  · rintro (⟨rfl, hy⟩ | ⟨hx, rfl⟩)
    exacts[sqrt_mul_self hy, sqrt_eq_zero_of_nonpos hx.le]
#align real.sqrt_eq_cases Real.sqrt_eq_cases

theorem sqrt_eq_iff_mul_self_eq (hx : 0 ≤ x) (hy : 0 ≤ y) : sqrt x = y ↔ y * y = x :=
  ⟨fun h => by rw [← h, mul_self_sqrt hx], fun h => by rw [← h, sqrt_mul_self hy]⟩
#align real.sqrt_eq_iff_mul_self_eq Real.sqrt_eq_iff_mul_self_eq

theorem sqrt_eq_iff_mul_self_eq_of_pos (h : 0 < y) : sqrt x = y ↔ y * y = x := by
  simp [sqrt_eq_cases, h.ne', h.le]
#align real.sqrt_eq_iff_mul_self_eq_of_pos Real.sqrt_eq_iff_mul_self_eq_of_pos

@[simp]
theorem sqrt_eq_one : sqrt x = 1 ↔ x = 1 :=
  calc
    sqrt x = 1 ↔ 1 * 1 = x := sqrt_eq_iff_mul_self_eq_of_pos zero_lt_one
    _ ↔ x = 1 := by rw [eq_comm, mul_one]
    
#align real.sqrt_eq_one Real.sqrt_eq_one

@[simp]
theorem sq_sqrt (h : 0 ≤ x) : sqrt x ^ 2 = x := by rw [sq, mul_self_sqrt h]
#align real.sq_sqrt Real.sq_sqrt

@[simp]
theorem sqrt_sq (h : 0 ≤ x) : sqrt (x ^ 2) = x := by rw [sq, sqrt_mul_self h]
#align real.sqrt_sq Real.sqrt_sq

theorem sqrt_eq_iff_sq_eq (hx : 0 ≤ x) (hy : 0 ≤ y) : sqrt x = y ↔ y ^ 2 = x := by
  rw [sq, sqrt_eq_iff_mul_self_eq hx hy]
#align real.sqrt_eq_iff_sq_eq Real.sqrt_eq_iff_sq_eq

theorem sqrt_mul_self_eq_abs (x : ℝ) : sqrt (x * x) = |x| := by
  rw [← abs_mul_abs_self x, sqrt_mul_self (abs_nonneg _)]
#align real.sqrt_mul_self_eq_abs Real.sqrt_mul_self_eq_abs

theorem sqrt_sq_eq_abs (x : ℝ) : sqrt (x ^ 2) = |x| := by rw [sq, sqrt_mul_self_eq_abs]
#align real.sqrt_sq_eq_abs Real.sqrt_sq_eq_abs

@[simp]
theorem sqrt_zero : sqrt 0 = 0 := by simp [sqrt]
#align real.sqrt_zero Real.sqrt_zero

@[simp]
theorem sqrt_one : sqrt 1 = 1 := by simp [sqrt]
#align real.sqrt_one Real.sqrt_one

@[simp]
theorem sqrt_le_sqrt_iff (hy : 0 ≤ y) : sqrt x ≤ sqrt y ↔ x ≤ y := by
  rw [sqrt, sqrt, Nnreal.coe_le_coe, Nnreal.sqrt_le_sqrt_iff, Real.to_nnreal_le_to_nnreal_iff hy]
#align real.sqrt_le_sqrt_iff Real.sqrt_le_sqrt_iff

@[simp]
theorem sqrt_lt_sqrt_iff (hx : 0 ≤ x) : sqrt x < sqrt y ↔ x < y :=
  lt_iff_lt_of_le_iff_le (sqrt_le_sqrt_iff hx)
#align real.sqrt_lt_sqrt_iff Real.sqrt_lt_sqrt_iff

theorem sqrt_lt_sqrt_iff_of_pos (hy : 0 < y) : sqrt x < sqrt y ↔ x < y := by
  rw [sqrt, sqrt, Nnreal.coe_lt_coe, Nnreal.sqrt_lt_sqrt_iff, to_nnreal_lt_to_nnreal_iff hy]
#align real.sqrt_lt_sqrt_iff_of_pos Real.sqrt_lt_sqrt_iff_of_pos

theorem sqrt_le_sqrt (h : x ≤ y) : sqrt x ≤ sqrt y :=
  by
  rw [sqrt, sqrt, Nnreal.coe_le_coe, Nnreal.sqrt_le_sqrt_iff]
  exact to_nnreal_le_to_nnreal h
#align real.sqrt_le_sqrt Real.sqrt_le_sqrt

theorem sqrt_lt_sqrt (hx : 0 ≤ x) (h : x < y) : sqrt x < sqrt y :=
  (sqrt_lt_sqrt_iff hx).2 h
#align real.sqrt_lt_sqrt Real.sqrt_lt_sqrt

theorem sqrt_le_left (hy : 0 ≤ y) : sqrt x ≤ y ↔ x ≤ y ^ 2 := by
  rw [sqrt, ← Real.le_to_nnreal_iff_coe_le hy, Nnreal.sqrt_le_iff, sq, ← Real.to_nnreal_mul hy,
    Real.to_nnreal_le_to_nnreal_iff (mul_self_nonneg y), sq]
#align real.sqrt_le_left Real.sqrt_le_left

theorem sqrt_le_iff : sqrt x ≤ y ↔ 0 ≤ y ∧ x ≤ y ^ 2 :=
  by
  rw [← and_iff_right_of_imp fun h => (sqrt_nonneg x).trans h, and_congr_right_iff]
  exact sqrt_le_left
#align real.sqrt_le_iff Real.sqrt_le_iff

theorem sqrt_lt (hx : 0 ≤ x) (hy : 0 ≤ y) : sqrt x < y ↔ x < y ^ 2 := by
  rw [← sqrt_lt_sqrt_iff hx, sqrt_sq hy]
#align real.sqrt_lt Real.sqrt_lt

theorem sqrt_lt' (hy : 0 < y) : sqrt x < y ↔ x < y ^ 2 := by
  rw [← sqrt_lt_sqrt_iff_of_pos (pow_pos hy _), sqrt_sq hy.le]
#align real.sqrt_lt' Real.sqrt_lt'

/- note: if you want to conclude `x ≤ sqrt y`, then use `le_sqrt_of_sq_le`.
   if you have `x > 0`, consider using `le_sqrt'` -/
theorem le_sqrt (hx : 0 ≤ x) (hy : 0 ≤ y) : x ≤ sqrt y ↔ x ^ 2 ≤ y :=
  le_iff_le_iff_lt_iff_lt.2 <| sqrt_lt hy hx
#align real.le_sqrt Real.le_sqrt

theorem le_sqrt' (hx : 0 < x) : x ≤ sqrt y ↔ x ^ 2 ≤ y :=
  le_iff_le_iff_lt_iff_lt.2 <| sqrt_lt' hx
#align real.le_sqrt' Real.le_sqrt'

theorem abs_le_sqrt (h : x ^ 2 ≤ y) : |x| ≤ sqrt y := by
  rw [← sqrt_sq_eq_abs] <;> exact sqrt_le_sqrt h
#align real.abs_le_sqrt Real.abs_le_sqrt

theorem sq_le (h : 0 ≤ y) : x ^ 2 ≤ y ↔ -sqrt y ≤ x ∧ x ≤ sqrt y :=
  by
  constructor
  · simpa only [abs_le] using abs_le_sqrt
  · rw [← abs_le, ← sq_abs]
    exact (le_sqrt (abs_nonneg x) h).mp
#align real.sq_le Real.sq_le

theorem neg_sqrt_le_of_sq_le (h : x ^ 2 ≤ y) : -sqrt y ≤ x :=
  ((sq_le ((sq_nonneg x).trans h)).mp h).1
#align real.neg_sqrt_le_of_sq_le Real.neg_sqrt_le_of_sq_le

theorem le_sqrt_of_sq_le (h : x ^ 2 ≤ y) : x ≤ sqrt y :=
  ((sq_le ((sq_nonneg x).trans h)).mp h).2
#align real.le_sqrt_of_sq_le Real.le_sqrt_of_sq_le

@[simp]
theorem sqrt_inj (hx : 0 ≤ x) (hy : 0 ≤ y) : sqrt x = sqrt y ↔ x = y := by
  simp [le_antisymm_iff, hx, hy]
#align real.sqrt_inj Real.sqrt_inj

@[simp]
theorem sqrt_eq_zero (h : 0 ≤ x) : sqrt x = 0 ↔ x = 0 := by simpa using sqrt_inj h le_rfl
#align real.sqrt_eq_zero Real.sqrt_eq_zero

theorem sqrt_eq_zero' : sqrt x = 0 ↔ x ≤ 0 := by
  rw [sqrt, Nnreal.coe_eq_zero, Nnreal.sqrt_eq_zero, Real.to_nnreal_eq_zero]
#align real.sqrt_eq_zero' Real.sqrt_eq_zero'

theorem sqrt_ne_zero (h : 0 ≤ x) : sqrt x ≠ 0 ↔ x ≠ 0 := by rw [not_iff_not, sqrt_eq_zero h]
#align real.sqrt_ne_zero Real.sqrt_ne_zero

theorem sqrt_ne_zero' : sqrt x ≠ 0 ↔ 0 < x := by rw [← not_le, not_iff_not, sqrt_eq_zero']
#align real.sqrt_ne_zero' Real.sqrt_ne_zero'

@[simp]
theorem sqrt_pos : 0 < sqrt x ↔ 0 < x :=
  lt_iff_lt_of_le_iff_le (Iff.trans (by simp [le_antisymm_iff, sqrt_nonneg]) sqrt_eq_zero')
#align real.sqrt_pos Real.sqrt_pos

alias sqrt_pos ↔ _ sqrt_pos_of_pos

section

open Tactic Tactic.Positivity

/-- Extension for the `positivity` tactic: a square root is nonnegative, and is strictly positive if
its input is. -/
@[positivity]
unsafe def _root_.tactic.positivity_sqrt : expr → tactic strictness
  | q(Real.sqrt $(a)) => do
    (-- if can prove `0 < a`, report positivity
        do
          let positive pa ← core a
          positive <$> mk_app `` sqrt_pos_of_pos [pa]) <|>
        nonnegative <$> mk_app `` sqrt_nonneg [a]
  |-- else report nonnegativity
    _ =>
    failed
#align tactic.positivity_sqrt tactic.positivity_sqrt

end

@[simp]
theorem sqrt_mul (hx : 0 ≤ x) (y : ℝ) : sqrt (x * y) = sqrt x * sqrt y := by
  simp_rw [sqrt, ← Nnreal.coe_mul, Nnreal.coe_eq, Real.to_nnreal_mul hx, Nnreal.sqrt_mul]
#align real.sqrt_mul Real.sqrt_mul

@[simp]
theorem sqrt_mul' (x) {y : ℝ} (hy : 0 ≤ y) : sqrt (x * y) = sqrt x * sqrt y := by
  rw [mul_comm, sqrt_mul hy, mul_comm]
#align real.sqrt_mul' Real.sqrt_mul'

@[simp]
theorem sqrt_inv (x : ℝ) : sqrt x⁻¹ = (sqrt x)⁻¹ := by
  rw [sqrt, Real.to_nnreal_inv, Nnreal.sqrt_inv, Nnreal.coe_inv, sqrt]
#align real.sqrt_inv Real.sqrt_inv

@[simp]
theorem sqrt_div (hx : 0 ≤ x) (y : ℝ) : sqrt (x / y) = sqrt x / sqrt y := by
  rw [division_def, sqrt_mul hx, sqrt_inv, division_def]
#align real.sqrt_div Real.sqrt_div

@[simp]
theorem div_sqrt : x / sqrt x = sqrt x :=
  by
  cases le_or_lt x 0
  · rw [sqrt_eq_zero'.mpr h, div_zero]
  · rw [div_eq_iff (sqrt_ne_zero'.mpr h), mul_self_sqrt h.le]
#align real.div_sqrt Real.div_sqrt

theorem sqrt_div_self' : sqrt x / x = 1 / sqrt x := by rw [← div_sqrt, one_div_div, div_sqrt]
#align real.sqrt_div_self' Real.sqrt_div_self'

theorem sqrt_div_self : sqrt x / x = (sqrt x)⁻¹ := by rw [sqrt_div_self', one_div]
#align real.sqrt_div_self Real.sqrt_div_self

theorem lt_sqrt (hx : 0 ≤ x) : x < sqrt y ↔ x ^ 2 < y := by
  rw [← sqrt_lt_sqrt_iff (sq_nonneg _), sqrt_sq hx]
#align real.lt_sqrt Real.lt_sqrt

theorem sq_lt : x ^ 2 < y ↔ -sqrt y < x ∧ x < sqrt y := by
  rw [← abs_lt, ← sq_abs, lt_sqrt (abs_nonneg _)]
#align real.sq_lt Real.sq_lt

theorem neg_sqrt_lt_of_sq_lt (h : x ^ 2 < y) : -sqrt y < x :=
  (sq_lt.mp h).1
#align real.neg_sqrt_lt_of_sq_lt Real.neg_sqrt_lt_of_sq_lt

theorem lt_sqrt_of_sq_lt (h : x ^ 2 < y) : x < sqrt y :=
  (sq_lt.mp h).2
#align real.lt_sqrt_of_sq_lt Real.lt_sqrt_of_sq_lt

theorem lt_sq_of_sqrt_lt {x y : ℝ} (h : sqrt x < y) : x < y ^ 2 :=
  by
  have hy := x.sqrt_nonneg.trans_lt h
  rwa [← sqrt_lt_sqrt_iff_of_pos (sq_pos_of_pos hy), sqrt_sq hy.le]
#align real.lt_sq_of_sqrt_lt Real.lt_sq_of_sqrt_lt

/-- The natural square root is at most the real square root -/
theorem nat_sqrt_le_real_sqrt {a : ℕ} : ↑(Nat.sqrt a) ≤ Real.sqrt ↑a :=
  by
  rw [Real.le_sqrt (Nat.cast_nonneg _) (Nat.cast_nonneg _)]
  norm_cast
  exact Nat.sqrt_le' a
#align real.nat_sqrt_le_real_sqrt Real.nat_sqrt_le_real_sqrt

/-- The real square root is at most the natural square root plus one -/
theorem real_sqrt_le_nat_sqrt_succ {a : ℕ} : Real.sqrt ↑a ≤ Nat.sqrt a + 1 :=
  by
  rw [Real.sqrt_le_iff]
  constructor
  · norm_cast
    simp
  · norm_cast
    exact le_of_lt (Nat.lt_succ_sqrt' a)
#align real.real_sqrt_le_nat_sqrt_succ Real.real_sqrt_le_nat_sqrt_succ

instance : StarOrderedRing ℝ :=
  { Real.orderedAddCommGroup with
    nonneg_iff := fun r =>
      by
      refine'
        ⟨fun hr => ⟨sqrt r, show r = sqrt r * sqrt r by rw [← sqrt_mul hr, sqrt_mul_self hr]⟩, _⟩
      rintro ⟨s, rfl⟩
      exact mul_self_nonneg s }

end Real

open Real

variable {α : Type _}

theorem Filter.Tendsto.sqrt {f : α → ℝ} {l : Filter α} {x : ℝ} (h : Tendsto f l (𝓝 x)) :
    Tendsto (fun x => sqrt (f x)) l (𝓝 (sqrt x)) :=
  (continuous_sqrt.Tendsto _).comp h
#align filter.tendsto.sqrt Filter.Tendsto.sqrt

variable [TopologicalSpace α] {f : α → ℝ} {s : Set α} {x : α}

theorem ContinuousWithinAt.sqrt (h : ContinuousWithinAt f s x) :
    ContinuousWithinAt (fun x => sqrt (f x)) s x :=
  h.sqrt
#align continuous_within_at.sqrt ContinuousWithinAt.sqrt

theorem ContinuousAt.sqrt (h : ContinuousAt f x) : ContinuousAt (fun x => sqrt (f x)) x :=
  h.sqrt
#align continuous_at.sqrt ContinuousAt.sqrt

theorem ContinuousOn.sqrt (h : ContinuousOn f s) : ContinuousOn (fun x => sqrt (f x)) s :=
  fun x hx => (h x hx).sqrt
#align continuous_on.sqrt ContinuousOn.sqrt

@[continuity]
theorem Continuous.sqrt (h : Continuous f) : Continuous fun x => sqrt (f x) :=
  continuous_sqrt.comp h
#align continuous.sqrt Continuous.sqrt

