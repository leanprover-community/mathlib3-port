import Mathbin.Data.Real.Sqrt 
import Mathbin.Tactic.IntervalCases 
import Mathbin.RingTheory.Algebraic 
import Mathbin.Data.Rat.Sqrt 
import Mathbin.Data.Polynomial.Eval 
import Mathbin.RingTheory.Int.Basic

/-!
# Irrational real numbers

In this file we define a predicate `irrational` on `ℝ`, prove that the `n`-th root of an integer
number is irrational if it is not integer, and that `sqrt q` is irrational if and only if
`rat.sqrt q * rat.sqrt q ≠ q ∧ 0 ≤ q`.

We also provide dot-style constructors like `irrational.add_rat`, `irrational.rat_sub` etc.
-/


open Rat Real multiplicity

/-- A real number is irrational if it is not equal to any rational number. -/
def Irrational (x : ℝ) :=
  x ∉ Set.Range (coeₓ : ℚ → ℝ)

theorem irrational_iff_ne_rational (x : ℝ) : Irrational x ↔ ∀ (a b : ℤ), x ≠ a / b :=
  by 
    simp only [Irrational, Rat.forall, cast_mk, not_exists, Set.mem_range, cast_coe_int, cast_div, eq_comm]

/-- A transcendental real number is irrational. -/
theorem Transcendental.irrational {r : ℝ} (tr : Transcendental ℚ r) : Irrational r :=
  by 
    rintro ⟨a, rfl⟩
    exact tr (is_algebraic_algebra_map a)

/-!
### Irrationality of roots of integer and rational numbers
-/


-- error in Data.Real.Irrational: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If `x^n`, `n > 0`, is integer and is not the `n`-th power of an integer, then
`x` is irrational. -/
theorem irrational_nrt_of_notint_nrt
{x : exprℝ()}
(n : exprℕ())
(m : exprℤ())
(hxr : «expr = »(«expr ^ »(x, n), m))
(hv : «expr¬ »(«expr∃ , »((y : exprℤ()), «expr = »(x, y))))
(hnpos : «expr < »(0, n)) : irrational x :=
begin
  rintros ["⟨", "⟨", ident N, ",", ident D, ",", ident P, ",", ident C, "⟩", ",", ident rfl, "⟩"],
  rw ["[", "<-", expr cast_pow, "]"] ["at", ident hxr],
  have [ident c1] [":", expr «expr ≠ »(((D : exprℤ()) : exprℝ()), 0)] [],
  { rw ["[", expr int.cast_ne_zero, ",", expr int.coe_nat_ne_zero, "]"] [],
    exact [expr ne_of_gt P] },
  have [ident c2] [":", expr «expr ≠ »(«expr ^ »(((D : exprℤ()) : exprℝ()), n), 0)] [":=", expr pow_ne_zero _ c1],
  rw ["[", expr num_denom', ",", expr cast_pow, ",", expr cast_mk, ",", expr div_pow, ",", expr div_eq_iff_mul_eq c2, ",", "<-", expr int.cast_pow, ",", "<-", expr int.cast_pow, ",", "<-", expr int.cast_mul, ",", expr int.cast_inj, "]"] ["at", ident hxr],
  have [ident hdivn] [":", expr «expr ∣ »(«expr ^ »(«expr↑ »(D), n), «expr ^ »(N, n))] [":=", expr dvd.intro_left m hxr],
  rw ["[", "<-", expr int.dvd_nat_abs, ",", "<-", expr int.coe_nat_pow, ",", expr int.coe_nat_dvd, ",", expr int.nat_abs_pow, ",", expr nat.pow_dvd_pow_iff hnpos, "]"] ["at", ident hdivn],
  have [ident hD] [":", expr «expr = »(D, 1)] [":=", expr by rw ["[", "<-", expr nat.gcd_eq_right hdivn, ",", expr C.gcd_eq_one, "]"] []],
  subst [expr D],
  refine [expr hv ⟨N, _⟩],
  rw ["[", expr num_denom', ",", expr int.coe_nat_one, ",", expr mk_eq_div, ",", expr int.cast_one, ",", expr div_one, ",", expr cast_coe_int, "]"] []
end

-- error in Data.Real.Irrational: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If `x^n = m` is an integer and `n` does not divide the `multiplicity p m`, then `x`
is irrational. -/
theorem irrational_nrt_of_n_not_dvd_multiplicity
{x : exprℝ()}
(n : exprℕ())
{m : exprℤ()}
(hm : «expr ≠ »(m, 0))
(p : exprℕ())
[hp : fact p.prime]
(hxr : «expr = »(«expr ^ »(x, n), m))
(hv : «expr ≠ »(«expr % »((multiplicity (p : exprℤ()) m).get (finite_int_iff.2 ⟨hp.1.ne_one, hm⟩), n), 0)) : irrational x :=
begin
  rcases [expr nat.eq_zero_or_pos n, "with", ident rfl, "|", ident hnpos],
  { rw ["[", expr eq_comm, ",", expr pow_zero, ",", "<-", expr int.cast_one, ",", expr int.cast_inj, "]"] ["at", ident hxr],
    simpa [] [] [] ["[", expr hxr, ",", expr multiplicity.one_right (mt is_unit_iff_dvd_one.1 (mt int.coe_nat_dvd.1 hp.1.not_dvd_one)), ",", expr nat.zero_mod, "]"] [] ["using", expr hv] },
  refine [expr irrational_nrt_of_notint_nrt _ _ hxr _ hnpos],
  rintro ["⟨", ident y, ",", ident rfl, "⟩"],
  rw ["[", "<-", expr int.cast_pow, ",", expr int.cast_inj, "]"] ["at", ident hxr],
  subst [expr m],
  have [] [":", expr «expr ≠ »(y, 0)] [],
  { rintro [ident rfl],
    rw [expr zero_pow hnpos] ["at", ident hm],
    exact [expr hm rfl] },
  erw ["[", expr multiplicity.pow' (nat.prime_iff_prime_int.1 hp.1) (finite_int_iff.2 ⟨hp.1.ne_one, this⟩), ",", expr nat.mul_mod_right, "]"] ["at", ident hv],
  exact [expr hv rfl]
end

theorem irrational_sqrt_of_multiplicity_odd (m : ℤ) (hm : 0 < m) (p : ℕ) [hp : Fact p.prime]
  (Hpv : (multiplicity (p : ℤ) m).get (finite_int_iff.2 ⟨hp.1.ne_one, (ne_of_ltₓ hm).symm⟩) % 2 = 1) :
  Irrational (sqrt m) :=
  @irrational_nrt_of_n_not_dvd_multiplicity _ 2 _ (Ne.symm (ne_of_ltₓ hm)) p hp
    (sq_sqrt (Int.cast_nonneg.2$ le_of_ltₓ hm))
    (by 
      rw [Hpv] <;> exact one_ne_zero)

theorem Nat.Prime.irrational_sqrt {p : ℕ} (hp : Nat.Prime p) : Irrational (sqrt p) :=
  @irrational_sqrt_of_multiplicity_odd p (Int.coe_nat_pos.2 hp.pos) p ⟨hp⟩$
    by 
      simp [multiplicity_self (mt is_unit_iff_dvd_one.1 (mt Int.coe_nat_dvd.1 hp.not_dvd_one) : _)] <;> rfl

/-- **Irrationality of the Square Root of 2** -/
theorem irrational_sqrt_two : Irrational (sqrt 2) :=
  by 
    simpa using nat.prime_two.irrational_sqrt

theorem irrational_sqrt_rat_iff (q : ℚ) : Irrational (sqrt q) ↔ (Rat.sqrt q*Rat.sqrt q) ≠ q ∧ 0 ≤ q :=
  if H1 : (Rat.sqrt q*Rat.sqrt q) = q then
    iff_of_false
      (not_not_intro
        ⟨Rat.sqrt q,
          by 
            rw [←H1, cast_mul, sqrt_mul_self (cast_nonneg.2$ Rat.sqrt_nonneg q), sqrt_eq,
              abs_of_nonneg (Rat.sqrt_nonneg q)]⟩)
      fun h => h.1 H1
  else
    if H2 : 0 ≤ q then
      iff_of_true
        (fun ⟨r, hr⟩ =>
          H1$
            (exists_mul_self _).1
              ⟨r,
                by 
                  rwa [eq_comm, sqrt_eq_iff_mul_self_eq (cast_nonneg.2 H2), ←cast_mul, Rat.cast_inj] at hr <;>
                    rw [←hr] <;> exact Real.sqrt_nonneg _⟩)
        ⟨H1, H2⟩
    else
      iff_of_false
        (not_not_intro
          ⟨0,
            by 
              rw [cast_zero] <;> exact (sqrt_eq_zero_of_nonpos (Rat.cast_nonpos.2$ le_of_not_leₓ H2)).symm⟩)
        fun h => H2 h.2

instance  (q : ℚ) : Decidable (Irrational (sqrt q)) :=
  decidableOfIff' _ (irrational_sqrt_rat_iff q)

/-!
### Dot-style operations on `irrational`

#### Coercion of a rational/integer/natural number is not irrational
-/


namespace Irrational

variable{x : ℝ}

/-!
#### Irrational number is not equal to a rational/integer/natural number
-/


theorem ne_rat (h : Irrational x) (q : ℚ) : x ≠ q :=
  fun hq => h ⟨q, hq.symm⟩

theorem ne_int (h : Irrational x) (m : ℤ) : x ≠ m :=
  by 
    rw [←Rat.cast_coe_int]
    exact h.ne_rat _

theorem ne_nat (h : Irrational x) (m : ℕ) : x ≠ m :=
  h.ne_int m

theorem ne_zero (h : Irrational x) : x ≠ 0 :=
  h.ne_nat 0

theorem ne_one (h : Irrational x) : x ≠ 1 :=
  by 
    simpa only [Nat.cast_one] using h.ne_nat 1

end Irrational

@[simp]
theorem Rat.not_irrational (q : ℚ) : ¬Irrational q :=
  fun h => h ⟨q, rfl⟩

@[simp]
theorem Int.not_irrational (m : ℤ) : ¬Irrational m :=
  fun h => h.ne_int m rfl

@[simp]
theorem Nat.not_irrational (m : ℕ) : ¬Irrational m :=
  fun h => h.ne_nat m rfl

namespace Irrational

variable(q : ℚ){x y : ℝ}

/-!
#### Addition of rational/integer/natural numbers
-/


/-- If `x + y` is irrational, then at least one of `x` and `y` is irrational. -/
theorem add_cases : Irrational (x+y) → Irrational x ∨ Irrational y :=
  by 
    delta' Irrational 
    contrapose! 
    rintro ⟨⟨rx, rfl⟩, ⟨ry, rfl⟩⟩
    exact ⟨rx+ry, cast_add rx ry⟩

theorem of_rat_add (h : Irrational (q+x)) : Irrational x :=
  h.add_cases.resolve_left q.not_irrational

theorem rat_add (h : Irrational x) : Irrational (q+x) :=
  of_rat_add (-q)$
    by 
      rwa [cast_neg, neg_add_cancel_leftₓ]

theorem of_add_rat : Irrational (x+q) → Irrational x :=
  add_commₓ («expr↑ » q) x ▸ of_rat_add q

theorem add_rat (h : Irrational x) : Irrational (x+q) :=
  add_commₓ («expr↑ » q) x ▸ h.rat_add q

theorem of_int_add (m : ℤ) (h : Irrational (m+x)) : Irrational x :=
  by 
    rw [←cast_coe_int] at h 
    exact h.of_rat_add m

theorem of_add_int (m : ℤ) (h : Irrational (x+m)) : Irrational x :=
  of_int_add m$ add_commₓ x m ▸ h

theorem int_add (h : Irrational x) (m : ℤ) : Irrational (m+x) :=
  by 
    rw [←cast_coe_int]
    exact h.rat_add m

theorem add_int (h : Irrational x) (m : ℤ) : Irrational (x+m) :=
  add_commₓ («expr↑ » m) x ▸ h.int_add m

theorem of_nat_add (m : ℕ) (h : Irrational (m+x)) : Irrational x :=
  h.of_int_add m

theorem of_add_nat (m : ℕ) (h : Irrational (x+m)) : Irrational x :=
  h.of_add_int m

theorem nat_add (h : Irrational x) (m : ℕ) : Irrational (m+x) :=
  h.int_add m

theorem add_nat (h : Irrational x) (m : ℕ) : Irrational (x+m) :=
  h.add_int m

/-!
#### Negation
-/


theorem of_neg (h : Irrational (-x)) : Irrational x :=
  fun ⟨q, hx⟩ =>
    h
      ⟨-q,
        by 
          rw [cast_neg, hx]⟩

protected theorem neg (h : Irrational x) : Irrational (-x) :=
  of_neg$
    by 
      rwa [neg_negₓ]

/-!
#### Subtraction of rational/integer/natural numbers
-/


theorem sub_rat (h : Irrational x) : Irrational (x - q) :=
  by 
    simpa only [sub_eq_add_neg, cast_neg] using h.add_rat (-q)

theorem rat_sub (h : Irrational x) : Irrational (q - x) :=
  by 
    simpa only [sub_eq_add_neg] using h.neg.rat_add q

theorem of_sub_rat (h : Irrational (x - q)) : Irrational x :=
  of_add_rat (-q)$
    by 
      simpa only [cast_neg, sub_eq_add_neg] using h

theorem of_rat_sub (h : Irrational (q - x)) : Irrational x :=
  of_neg
    (of_rat_add q
      (by 
        simpa only [sub_eq_add_neg] using h))

theorem sub_int (h : Irrational x) (m : ℤ) : Irrational (x - m) :=
  by 
    simpa only [Rat.cast_coe_int] using h.sub_rat m

theorem int_sub (h : Irrational x) (m : ℤ) : Irrational (m - x) :=
  by 
    simpa only [Rat.cast_coe_int] using h.rat_sub m

theorem of_sub_int (m : ℤ) (h : Irrational (x - m)) : Irrational x :=
  of_sub_rat m$
    by 
      rwa [Rat.cast_coe_int]

theorem of_int_sub (m : ℤ) (h : Irrational (m - x)) : Irrational x :=
  of_rat_sub m$
    by 
      rwa [Rat.cast_coe_int]

theorem sub_nat (h : Irrational x) (m : ℕ) : Irrational (x - m) :=
  h.sub_int m

theorem nat_sub (h : Irrational x) (m : ℕ) : Irrational (m - x) :=
  h.int_sub m

theorem of_sub_nat (m : ℕ) (h : Irrational (x - m)) : Irrational x :=
  h.of_sub_int m

theorem of_nat_sub (m : ℕ) (h : Irrational (m - x)) : Irrational x :=
  h.of_int_sub m

/-!
#### Multiplication by rational numbers
-/


theorem mul_cases : Irrational (x*y) → Irrational x ∨ Irrational y :=
  by 
    delta' Irrational 
    contrapose! 
    rintro ⟨⟨rx, rfl⟩, ⟨ry, rfl⟩⟩
    exact ⟨rx*ry, cast_mul rx ry⟩

theorem of_mul_rat (h : Irrational (x*q)) : Irrational x :=
  h.mul_cases.resolve_right q.not_irrational

theorem mul_rat (h : Irrational x) {q : ℚ} (hq : q ≠ 0) : Irrational (x*q) :=
  of_mul_rat (q⁻¹)$
    by 
      rwa [mul_assocₓ, ←cast_mul, mul_inv_cancel hq, cast_one, mul_oneₓ]

theorem of_rat_mul : Irrational (q*x) → Irrational x :=
  mul_commₓ x q ▸ of_mul_rat q

theorem rat_mul (h : Irrational x) {q : ℚ} (hq : q ≠ 0) : Irrational (q*x) :=
  mul_commₓ x q ▸ h.mul_rat hq

theorem of_mul_int (m : ℤ) (h : Irrational (x*m)) : Irrational x :=
  of_mul_rat m$
    by 
      rwa [cast_coe_int]

theorem of_int_mul (m : ℤ) (h : Irrational (m*x)) : Irrational x :=
  of_rat_mul m$
    by 
      rwa [cast_coe_int]

theorem mul_int (h : Irrational x) {m : ℤ} (hm : m ≠ 0) : Irrational (x*m) :=
  by 
    rw [←cast_coe_int]
    refine' h.mul_rat _ 
    rwa [Int.cast_ne_zero]

theorem int_mul (h : Irrational x) {m : ℤ} (hm : m ≠ 0) : Irrational (m*x) :=
  mul_commₓ x m ▸ h.mul_int hm

theorem of_mul_nat (m : ℕ) (h : Irrational (x*m)) : Irrational x :=
  h.of_mul_int m

theorem of_nat_mul (m : ℕ) (h : Irrational (m*x)) : Irrational x :=
  h.of_int_mul m

theorem mul_nat (h : Irrational x) {m : ℕ} (hm : m ≠ 0) : Irrational (x*m) :=
  h.mul_int$ Int.coe_nat_ne_zero.2 hm

theorem nat_mul (h : Irrational x) {m : ℕ} (hm : m ≠ 0) : Irrational (m*x) :=
  h.int_mul$ Int.coe_nat_ne_zero.2 hm

/-!
#### Inverse
-/


theorem of_inv (h : Irrational (x⁻¹)) : Irrational x :=
  fun ⟨q, hq⟩ => h$ hq ▸ ⟨q⁻¹, q.cast_inv⟩

protected theorem inv (h : Irrational x) : Irrational (x⁻¹) :=
  of_inv$
    by 
      rwa [inv_inv₀]

/-!
#### Division
-/


theorem div_cases (h : Irrational (x / y)) : Irrational x ∨ Irrational y :=
  h.mul_cases.imp id of_inv

theorem of_rat_div (h : Irrational (q / x)) : Irrational x :=
  (h.of_rat_mul q).of_inv

theorem of_div_rat (h : Irrational (x / q)) : Irrational x :=
  h.div_cases.resolve_right q.not_irrational

theorem rat_div (h : Irrational x) {q : ℚ} (hq : q ≠ 0) : Irrational (q / x) :=
  h.inv.rat_mul hq

theorem div_rat (h : Irrational x) {q : ℚ} (hq : q ≠ 0) : Irrational (x / q) :=
  by 
    rw [div_eq_mul_inv, ←cast_inv]
    exact h.mul_rat (inv_ne_zero hq)

theorem of_int_div (m : ℤ) (h : Irrational (m / x)) : Irrational x :=
  h.div_cases.resolve_left m.not_irrational

theorem of_div_int (m : ℤ) (h : Irrational (x / m)) : Irrational x :=
  h.div_cases.resolve_right m.not_irrational

theorem int_div (h : Irrational x) {m : ℤ} (hm : m ≠ 0) : Irrational (m / x) :=
  h.inv.int_mul hm

theorem div_int (h : Irrational x) {m : ℤ} (hm : m ≠ 0) : Irrational (x / m) :=
  by 
    rw [←cast_coe_int]
    refine' h.div_rat _ 
    rwa [Int.cast_ne_zero]

theorem of_nat_div (m : ℕ) (h : Irrational (m / x)) : Irrational x :=
  h.of_int_div m

theorem of_div_nat (m : ℕ) (h : Irrational (x / m)) : Irrational x :=
  h.of_div_int m

theorem nat_div (h : Irrational x) {m : ℕ} (hm : m ≠ 0) : Irrational (m / x) :=
  h.inv.nat_mul hm

theorem div_nat (h : Irrational x) {m : ℕ} (hm : m ≠ 0) : Irrational (x / m) :=
  h.div_int$
    by 
      rwa [Int.coe_nat_ne_zero]

theorem of_one_div (h : Irrational (1 / x)) : Irrational x :=
  of_rat_div 1$
    by 
      rwa [cast_one]

/-!
#### Natural and integerl power
-/


theorem of_mul_self (h : Irrational (x*x)) : Irrational x :=
  h.mul_cases.elim id id

theorem of_pow : ∀ (n : ℕ), Irrational (x^n) → Irrational x
| 0 =>
  fun h =>
    by 
      rw [pow_zeroₓ] at h 
      exact (h ⟨1, cast_one⟩).elim
| n+1 =>
  fun h =>
    by 
      rw [pow_succₓ] at h 
      exact h.mul_cases.elim id (of_pow n)

theorem of_zpow : ∀ (m : ℤ), Irrational (x^m) → Irrational x
| (n : ℕ) => of_pow n
| -[1+ n] =>
  fun h =>
    by 
      rw [zpow_neg_succ_of_nat] at h 
      exact h.of_inv.of_pow _

end Irrational

section Polynomial

open Polynomial

variable(x : ℝ)(p : Polynomial ℤ)

-- error in Data.Real.Irrational: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem one_lt_nat_degree_of_irrational_root
(hx : irrational x)
(p_nonzero : «expr ≠ »(p, 0))
(x_is_root : «expr = »(aeval x p, 0)) : «expr < »(1, p.nat_degree) :=
begin
  by_contra [ident rid],
  rcases [expr exists_eq_X_add_C_of_nat_degree_le_one (not_lt.1 rid), "with", "⟨", ident a, ",", ident b, ",", ident rfl, "⟩"],
  clear [ident rid],
  have [] [":", expr «expr = »(«expr * »((a : exprℝ()), x), «expr- »(b))] [],
  by simpa [] [] [] ["[", expr eq_neg_iff_add_eq_zero, "]"] [] ["using", expr x_is_root],
  rcases [expr em «expr = »(a, 0), "with", "(", ident rfl, "|", ident ha, ")"],
  { obtain [ident rfl, ":", expr «expr = »(b, 0)],
    by simpa [] [] [] [] [] [],
    simpa [] [] [] [] [] ["using", expr p_nonzero] },
  { rw ["[", expr mul_comm, ",", "<-", expr eq_div_iff_mul_eq, ",", expr eq_comm, "]"] ["at", ident this],
    refine [expr hx ⟨«expr / »(«expr- »(b), a), _⟩],
    assumption_mod_cast,
    assumption_mod_cast }
end

end Polynomial

section 

variable{q : ℚ}{m : ℤ}{n : ℕ}{x : ℝ}

open Irrational

/-!
### Simplification lemmas about operations
-/


@[simp]
theorem irrational_rat_add_iff : Irrational (q+x) ↔ Irrational x :=
  ⟨of_rat_add q, rat_add q⟩

@[simp]
theorem irrational_int_add_iff : Irrational (m+x) ↔ Irrational x :=
  ⟨of_int_add m, fun h => h.int_add m⟩

@[simp]
theorem irrational_nat_add_iff : Irrational (n+x) ↔ Irrational x :=
  ⟨of_nat_add n, fun h => h.nat_add n⟩

@[simp]
theorem irrational_add_rat_iff : Irrational (x+q) ↔ Irrational x :=
  ⟨of_add_rat q, add_rat q⟩

@[simp]
theorem irrational_add_int_iff : Irrational (x+m) ↔ Irrational x :=
  ⟨of_add_int m, fun h => h.add_int m⟩

@[simp]
theorem irrational_add_nat_iff : Irrational (x+n) ↔ Irrational x :=
  ⟨of_add_nat n, fun h => h.add_nat n⟩

@[simp]
theorem irrational_rat_sub_iff : Irrational (q - x) ↔ Irrational x :=
  ⟨of_rat_sub q, rat_sub q⟩

@[simp]
theorem irrational_int_sub_iff : Irrational (m - x) ↔ Irrational x :=
  ⟨of_int_sub m, fun h => h.int_sub m⟩

@[simp]
theorem irrational_nat_sub_iff : Irrational (n - x) ↔ Irrational x :=
  ⟨of_nat_sub n, fun h => h.nat_sub n⟩

@[simp]
theorem irrational_sub_rat_iff : Irrational (x - q) ↔ Irrational x :=
  ⟨of_sub_rat q, sub_rat q⟩

@[simp]
theorem irrational_sub_int_iff : Irrational (x - m) ↔ Irrational x :=
  ⟨of_sub_int m, fun h => h.sub_int m⟩

@[simp]
theorem irrational_sub_nat_iff : Irrational (x - n) ↔ Irrational x :=
  ⟨of_sub_nat n, fun h => h.sub_nat n⟩

@[simp]
theorem irrational_neg_iff : Irrational (-x) ↔ Irrational x :=
  ⟨of_neg, Irrational.neg⟩

@[simp]
theorem irrational_inv_iff : Irrational (x⁻¹) ↔ Irrational x :=
  ⟨of_inv, Irrational.inv⟩

@[simp]
theorem irrational_rat_mul_iff : Irrational (q*x) ↔ q ≠ 0 ∧ Irrational x :=
  ⟨fun h => ⟨Rat.cast_ne_zero.1$ left_ne_zero_of_mul h.ne_zero, h.of_rat_mul q⟩, fun h => h.2.rat_mul h.1⟩

@[simp]
theorem irrational_mul_rat_iff : Irrational (x*q) ↔ q ≠ 0 ∧ Irrational x :=
  by 
    rw [mul_commₓ, irrational_rat_mul_iff]

@[simp]
theorem irrational_int_mul_iff : Irrational (m*x) ↔ m ≠ 0 ∧ Irrational x :=
  by 
    rw [←cast_coe_int, irrational_rat_mul_iff, Int.cast_ne_zero]

@[simp]
theorem irrational_mul_int_iff : Irrational (x*m) ↔ m ≠ 0 ∧ Irrational x :=
  by 
    rw [←cast_coe_int, irrational_mul_rat_iff, Int.cast_ne_zero]

@[simp]
theorem irrational_nat_mul_iff : Irrational (n*x) ↔ n ≠ 0 ∧ Irrational x :=
  by 
    rw [←cast_coe_nat, irrational_rat_mul_iff, Nat.cast_ne_zero]

@[simp]
theorem irrational_mul_nat_iff : Irrational (x*n) ↔ n ≠ 0 ∧ Irrational x :=
  by 
    rw [←cast_coe_nat, irrational_mul_rat_iff, Nat.cast_ne_zero]

@[simp]
theorem irrational_rat_div_iff : Irrational (q / x) ↔ q ≠ 0 ∧ Irrational x :=
  by 
    simp [div_eq_mul_inv]

@[simp]
theorem irrational_div_rat_iff : Irrational (x / q) ↔ q ≠ 0 ∧ Irrational x :=
  by 
    rw [div_eq_mul_inv, ←cast_inv, irrational_mul_rat_iff, Ne.def, inv_eq_zero]

@[simp]
theorem irrational_int_div_iff : Irrational (m / x) ↔ m ≠ 0 ∧ Irrational x :=
  by 
    simp [div_eq_mul_inv]

@[simp]
theorem irrational_div_int_iff : Irrational (x / m) ↔ m ≠ 0 ∧ Irrational x :=
  by 
    rw [←cast_coe_int, irrational_div_rat_iff, Int.cast_ne_zero]

@[simp]
theorem irrational_nat_div_iff : Irrational (n / x) ↔ n ≠ 0 ∧ Irrational x :=
  by 
    simp [div_eq_mul_inv]

@[simp]
theorem irrational_div_nat_iff : Irrational (x / n) ↔ n ≠ 0 ∧ Irrational x :=
  by 
    rw [←cast_coe_nat, irrational_div_rat_iff, Nat.cast_ne_zero]

/-- There is an irrational number `r` between any two reals `x < r < y`. -/
theorem exists_irrational_btwn {x y : ℝ} (h : x < y) : ∃ r, Irrational r ∧ x < r ∧ r < y :=
  let ⟨q, ⟨hq1, hq2⟩⟩ := exists_rat_btwn ((sub_lt_sub_iff_right (Real.sqrt 2)).mpr h)
  ⟨q+Real.sqrt 2, irrational_sqrt_two.rat_add _, sub_lt_iff_lt_add.mp hq1, lt_sub_iff_add_lt.mp hq2⟩

end 

