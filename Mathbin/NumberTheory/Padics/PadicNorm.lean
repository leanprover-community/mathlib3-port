import Mathbin.Algebra.Order.AbsoluteValue 
import Mathbin.Algebra.FieldPower 
import Mathbin.RingTheory.Int.Basic 
import Mathbin.Tactic.Basic 
import Mathbin.Tactic.RingExp

/-!
# p-adic norm

This file defines the p-adic valuation and the p-adic norm on ℚ.

The p-adic valuation on ℚ is the difference of the multiplicities of `p` in the numerator and
denominator of `q`. This function obeys the standard properties of a valuation, with the appropriate
assumptions on p.

The valuation induces a norm on ℚ. This norm is a nonarchimedean absolute value.
It takes values in {0} ∪ {1/p^k | k ∈ ℤ}.

## Notations

This file uses the local notation `/.` for `rat.mk`.

## Implementation notes

Much, but not all, of this file assumes that `p` is prime. This assumption is inferred automatically
by taking `[fact (prime p)]` as a type class argument.

## References

* [F. Q. Gouêva, *p-adic numbers*][gouvea1997]
* [R. Y. Lewis, *A formal proof of Hensel's lemma over the p-adic integers*][lewis2019]
* <https://en.wikipedia.org/wiki/P-adic_number>

## Tags

p-adic, p adic, padic, norm, valuation
-/


universe u

open Nat

open_locale Rat

open multiplicity

/--
For `p ≠ 1`, the p-adic valuation of an integer `z ≠ 0` is the largest natural number `n` such that
p^n divides z.

`padic_val_rat` defines the valuation of a rational `q` to be the valuation of `q.num` minus the
valuation of `q.denom`.
If `q = 0` or `p = 1`, then `padic_val_rat p q` defaults to 0.
-/
def padicValRat (p : ℕ) (q : ℚ) : ℤ :=
  if h : q ≠ 0 ∧ p ≠ 1 then
    (multiplicity (p : ℤ) q.num).get (multiplicity.finite_int_iff.2 ⟨h.2, Rat.num_ne_zero_of_ne_zero h.1⟩) -
      (multiplicity (p : ℤ) q.denom).get
        (multiplicity.finite_int_iff.2
          ⟨h.2,
            by 
              exactModCast Rat.denom_ne_zero _⟩)
  else 0

/--
A simplification of the definition of `padic_val_rat p q` when `q ≠ 0` and `p` is prime.
-/
theorem padic_val_rat_def (p : ℕ) [hp : Fact p.prime] {q : ℚ} (hq : q ≠ 0) :
  padicValRat p q =
    (multiplicity (p : ℤ) q.num).get (finite_int_iff.2 ⟨hp.1.ne_one, Rat.num_ne_zero_of_ne_zero hq⟩) -
      (multiplicity (p : ℤ) q.denom).get
        (finite_int_iff.2
          ⟨hp.1.ne_one,
            by 
              exactModCast Rat.denom_ne_zero _⟩) :=
  dif_pos ⟨hq, hp.1.ne_one⟩

namespace padicValRat

open multiplicity

variable{p : ℕ}

/--
`padic_val_rat p q` is symmetric in `q`.
-/
@[simp]
protected theorem neg (q : ℚ) : padicValRat p (-q) = padicValRat p q :=
  by 
    unfold padicValRat 
    splitIfs
    ·
      simp [-add_commₓ] <;> rfl
    ·
      exfalso 
      simp_all 
    ·
      exfalso 
      simp_all 
    ·
      rfl

/--
`padic_val_rat p 1` is 0 for any `p`.
-/
@[simp]
protected theorem one : padicValRat p 1 = 0 :=
  by 
    unfold padicValRat <;> splitIfs <;> simp 

/--
For `p ≠ 0, p ≠ 1, `padic_val_rat p p` is 1.
-/
@[simp]
theorem padic_val_rat_self (hp : 1 < p) : padicValRat p p = 1 :=
  by 
    unfold padicValRat <;> splitIfs <;> simp_all [Nat.one_lt_iff_ne_zero_and_ne_one]

/--
The p-adic value of an integer `z ≠ 0` is the multiplicity of `p` in `z`.
-/
theorem padic_val_rat_of_int (z : ℤ) (hp : p ≠ 1) (hz : z ≠ 0) :
  padicValRat p (z : ℚ) = (multiplicity (p : ℤ) z).get (finite_int_iff.2 ⟨hp, hz⟩) :=
  by 
    rw [padicValRat, dif_pos] <;> simp  <;> rfl

end padicValRat

/--
A convenience function for the case of `padic_val_rat` when both inputs are natural numbers.
-/
def padicValNat (p : ℕ) (n : ℕ) : ℕ :=
  Int.toNat (padicValRat p n)

section padicValNat

/--
`padic_val_nat` is defined as an `int.to_nat` cast;
this lemma ensures that the cast is well-behaved.
-/
theorem zero_le_padic_val_rat_of_nat (p n : ℕ) : 0 ≤ padicValRat p n :=
  by 
    unfold padicValRat 
    splitIfs
    ·
      simp 
    ·
      trivial

/--
`padic_val_rat` coincides with `padic_val_nat`.
-/
@[simp, normCast]
theorem padic_val_rat_of_nat (p n : ℕ) : «expr↑ » (padicValNat p n) = padicValRat p n :=
  by 
    unfold padicValNat 
    rw [Int.to_nat_of_nonneg (zero_le_padic_val_rat_of_nat p n)]

-- error in NumberTheory.Padics.PadicNorm: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
A simplification of `padic_val_nat` when one input is prime, by analogy with `padic_val_rat_def`.
-/
theorem padic_val_nat_def
{p : exprℕ()}
[hp : fact p.prime]
{n : exprℕ()}
(hn : «expr ≠ »(n, 0)) : «expr = »(padic_val_nat p n, (multiplicity p n).get (multiplicity.finite_nat_iff.2 ⟨nat.prime.ne_one hp.1, bot_lt_iff_ne_bot.mpr hn⟩)) :=
begin
  have [ident n_nonzero] [":", expr «expr ≠ »((n : exprℚ()), 0)] [],
  by simpa [] [] ["only"] ["[", expr cast_eq_zero, ",", expr ne.def, "]"] [] [],
  simpa [] [] ["only"] ["[", expr int.coe_nat_multiplicity p n, ",", expr rat.coe_nat_denom n, ",", expr (padic_val_rat_of_nat p n).symm, ",", expr int.coe_nat_zero, ",", expr int.coe_nat_inj', ",", expr sub_zero, ",", expr get_one_right, ",", expr int.coe_nat_succ, ",", expr zero_add, ",", expr rat.coe_nat_num, "]"] [] ["using", expr padic_val_rat_def p n_nonzero]
end

-- error in NumberTheory.Padics.PadicNorm: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Meta.solveByElim'
theorem one_le_padic_val_nat_of_dvd
{n p : nat}
[prime : fact p.prime]
(nonzero : «expr ≠ »(n, 0))
(div : «expr ∣ »(p, n)) : «expr ≤ »(1, padic_val_nat p n) :=
begin
  rw [expr @padic_val_nat_def _ prime _ nonzero] [],
  let [ident one_le_mul] [":", expr «expr ≤ »(_, multiplicity p n)] [":=", expr @multiplicity.le_multiplicity_of_pow_dvd _ _ _ p n 1 (begin
      norm_num [] [],
      exact [expr div]
    end)],
  simp [] [] ["only"] ["[", expr nat.cast_one, "]"] [] ["at", ident one_le_mul],
  rcases [expr one_le_mul, "with", "⟨", "_", ",", ident q, "⟩"],
  dsimp [] [] [] ["at", ident q],
  solve_by_elim [] [] [] []
end

@[simp]
theorem padic_val_nat_zero (m : Nat) : padicValNat m 0 = 0 :=
  by 
    simpa

@[simp]
theorem padic_val_nat_one (m : Nat) : padicValNat m 1 = 0 :=
  by 
    simp [padicValNat]

end padicValNat

namespace padicValRat

open multiplicity

variable(p : ℕ)[p_prime : Fact p.prime]

include p_prime

/--
The multiplicity of `p : ℕ` in `a : ℤ` is finite exactly when `a ≠ 0`.
-/
theorem finite_int_prime_iff {p : ℕ} [p_prime : Fact p.prime] {a : ℤ} : finite (p : ℤ) a ↔ a ≠ 0 :=
  by 
    simp [finite_int_iff, Ne.symm (ne_of_ltₓ p_prime.1.one_lt)]

/--
A rewrite lemma for `padic_val_rat p q` when `q` is expressed in terms of `rat.mk`.
-/
protected theorem defn {q : ℚ} {n d : ℤ} (hqz : q ≠ 0) (qdf : q = n /. d) :
  padicValRat p q =
    (multiplicity (p : ℤ) n).get
        (finite_int_iff.2
          ⟨Ne.symm$ ne_of_ltₓ p_prime.1.one_lt,
            fun hn =>
              by 
                simp_all ⟩) -
      (multiplicity (p : ℤ) d).get
        (finite_int_iff.2
          ⟨Ne.symm$ ne_of_ltₓ p_prime.1.one_lt,
            fun hd =>
              by 
                simp_all ⟩) :=
  have hn : n ≠ 0 := Rat.mk_num_ne_zero_of_ne_zero hqz qdf 
  have hd : d ≠ 0 := Rat.mk_denom_ne_zero_of_ne_zero hqz qdf 
  let ⟨c, hc1, hc2⟩ := Rat.num_denom_mk hn hd qdf 
  by 
    rw [padicValRat, dif_pos] <;>
      simp [hc1, hc2, multiplicity.mul' (Nat.prime_iff_prime_int.1 p_prime.1), Ne.symm (ne_of_ltₓ p_prime.1.one_lt),
        hqz]

/--
A rewrite lemma for `padic_val_rat p (q * r)` with conditions `q ≠ 0`, `r ≠ 0`.
-/
protected theorem mul {q r : ℚ} (hq : q ≠ 0) (hr : r ≠ 0) : padicValRat p (q*r) = padicValRat p q+padicValRat p r :=
  have  : (q*r) = (q.num*r.num) /. «expr↑ » q.denom*«expr↑ » r.denom :=
    by 
      rwModCast [Rat.mul_num_denom]
  have hq' : q.num /. q.denom ≠ 0 :=
    by 
      rw [Rat.num_denom] <;> exact hq 
  have hr' : r.num /. r.denom ≠ 0 :=
    by 
      rw [Rat.num_denom] <;> exact hr 
  have hp' : _root_.prime (p : ℤ) := Nat.prime_iff_prime_int.1 p_prime.1
  by 
    rw [padicValRat.defn p (mul_ne_zero hq hr) this]
    convRHS => rw [←@Rat.num_denom q, padicValRat.defn p hq', ←@Rat.num_denom r, padicValRat.defn p hr']
    rw [multiplicity.mul' hp', multiplicity.mul' hp'] <;> simp [add_commₓ, add_left_commₓ, sub_eq_add_neg]

/--
A rewrite lemma for `padic_val_rat p (q^k)` with condition `q ≠ 0`.
-/
protected theorem pow {q : ℚ} (hq : q ≠ 0) {k : ℕ} : padicValRat p (q^k) = k*padicValRat p q :=
  by 
    induction k <;> simp [padicValRat.mul _ hq (pow_ne_zero _ hq), pow_succₓ, add_mulₓ, add_commₓ]

/--
A rewrite lemma for `padic_val_rat p (q⁻¹)` with condition `q ≠ 0`.
-/
protected theorem inv {q : ℚ} (hq : q ≠ 0) : padicValRat p (q⁻¹) = -padicValRat p q :=
  by 
    rw [eq_neg_iff_add_eq_zero, ←padicValRat.mul p (inv_ne_zero hq) hq, inv_mul_cancel hq, padicValRat.one]

/--
A rewrite lemma for `padic_val_rat p (q / r)` with conditions `q ≠ 0`, `r ≠ 0`.
-/
protected theorem div {q r : ℚ} (hq : q ≠ 0) (hr : r ≠ 0) : padicValRat p (q / r) = padicValRat p q - padicValRat p r :=
  by 
    rw [div_eq_mul_inv, padicValRat.mul p hq (inv_ne_zero hr), padicValRat.inv p hr, sub_eq_add_neg]

/--
A condition for `padic_val_rat p (n₁ / d₁) ≤ padic_val_rat p (n₂ / d₂),
in terms of divisibility by `p^n`.
-/
theorem padic_val_rat_le_padic_val_rat_iff {n₁ n₂ d₁ d₂ : ℤ} (hn₁ : n₁ ≠ 0) (hn₂ : n₂ ≠ 0) (hd₁ : d₁ ≠ 0)
  (hd₂ : d₂ ≠ 0) :
  padicValRat p (n₁ /. d₁) ≤ padicValRat p (n₂ /. d₂) ↔ ∀ (n : ℕ), ((«expr↑ » p^n) ∣ n₁*d₂) → («expr↑ » p^n) ∣ n₂*d₁ :=
  have hf1 : finite (p : ℤ) (n₁*d₂) := finite_int_prime_iff.2 (mul_ne_zero hn₁ hd₂)
  have hf2 : finite (p : ℤ) (n₂*d₁) := finite_int_prime_iff.2 (mul_ne_zero hn₂ hd₁)
  by 
    conv  =>
      toLHS
        rw [padicValRat.defn p (Rat.mk_ne_zero_of_ne_zero hn₁ hd₁) rfl,
        padicValRat.defn p (Rat.mk_ne_zero_of_ne_zero hn₂ hd₂) rfl, sub_le_iff_le_add', ←add_sub_assoc,
        le_sub_iff_add_le]normCast
        rw [←multiplicity.mul' (Nat.prime_iff_prime_int.1 p_prime.1) hf1, add_commₓ,
        ←multiplicity.mul' (Nat.prime_iff_prime_int.1 p_prime.1) hf2, Enat.get_le_get, multiplicity_le_multiplicity_iff]

/--
Sufficient conditions to show that the p-adic valuation of `q` is less than or equal to the
p-adic vlauation of `q + r`.
-/
theorem le_padic_val_rat_add_of_le {q r : ℚ} (hq : q ≠ 0) (hr : r ≠ 0) (hqr : (q+r) ≠ 0)
  (h : padicValRat p q ≤ padicValRat p r) : padicValRat p q ≤ padicValRat p (q+r) :=
  have hqn : q.num ≠ 0 := Rat.num_ne_zero_of_ne_zero hq 
  have hqd : (q.denom : ℤ) ≠ 0 :=
    by 
      exactModCast Rat.denom_ne_zero _ 
  have hrn : r.num ≠ 0 := Rat.num_ne_zero_of_ne_zero hr 
  have hrd : (r.denom : ℤ) ≠ 0 :=
    by 
      exactModCast Rat.denom_ne_zero _ 
  have hqreq : (q+r) = ((q.num*r.denom)+q.denom*r.num : ℤ) /. («expr↑ » q.denom*«expr↑ » r.denom : ℤ) :=
    Rat.add_num_denom _ _ 
  have hqrd : ((q.num*«expr↑ » r.denom)+«expr↑ » q.denom*r.num) ≠ 0 := Rat.mk_num_ne_zero_of_ne_zero hqr hqreq 
  by 
    convLHS => rw [←@Rat.num_denom q]
    rw [hqreq, padic_val_rat_le_padic_val_rat_iff p hqn hqrd hqd (mul_ne_zero hqd hrd),
      ←multiplicity_le_multiplicity_iff, mul_left_commₓ, multiplicity.mul (Nat.prime_iff_prime_int.1 p_prime.1),
      add_mulₓ]
    rw [←@Rat.num_denom q, ←@Rat.num_denom r, padic_val_rat_le_padic_val_rat_iff p hqn hrn hqd hrd,
      ←multiplicity_le_multiplicity_iff] at h 
    calc
      _ ≤
        min (multiplicity («expr↑ » p) ((q.num*«expr↑ » r.denom)*«expr↑ » q.denom))
          (multiplicity («expr↑ » p) ((«expr↑ » q.denom*r.num)*«expr↑ » q.denom)) :=
      le_minₓ
        (by 
          rw [@multiplicity.mul _ _ _ _ (_*_) _ (Nat.prime_iff_prime_int.1 p_prime.1), add_commₓ])
        (by 
          rw [mul_assocₓ, @multiplicity.mul _ _ _ _ (q.denom : ℤ) (_*_) (Nat.prime_iff_prime_int.1 p_prime.1)] <;>
            exact add_le_add_left h _)_ ≤ _ :=
      min_le_multiplicity_add

/--
The minimum of the valuations of `q` and `r` is less than or equal to the valuation of `q + r`.
-/
theorem min_le_padic_val_rat_add {q r : ℚ} (hq : q ≠ 0) (hr : r ≠ 0) (hqr : (q+r) ≠ 0) :
  min (padicValRat p q) (padicValRat p r) ≤ padicValRat p (q+r) :=
  (le_totalₓ (padicValRat p q) (padicValRat p r)).elim
    (fun h =>
      by 
        rw [min_eq_leftₓ h] <;> exact le_padic_val_rat_add_of_le _ hq hr hqr h)
    fun h =>
      by 
        rw [min_eq_rightₓ h, add_commₓ] <;>
          exact
            le_padic_val_rat_add_of_le _ hr hq
              (by 
                rwa [add_commₓ])
              h

open_locale BigOperators

-- error in NumberTheory.Padics.PadicNorm: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- A finite sum of rationals with positive p-adic valuation has positive p-adic valuation
  (if the sum is non-zero). -/
theorem sum_pos_of_pos
{n : exprℕ()}
{F : exprℕ() → exprℚ()}
(hF : ∀ i, «expr < »(i, n) → «expr < »(0, padic_val_rat p (F i)))
(hn0 : «expr ≠ »(«expr∑ in , »((i), finset.range n, F i), 0)) : «expr < »(0, padic_val_rat p «expr∑ in , »((i), finset.range n, F i)) :=
begin
  induction [expr n] [] ["with", ident d, ident hd] [],
  { exact [expr false.elim (hn0 rfl)] },
  { rw [expr finset.sum_range_succ] ["at", ident hn0, "⊢"],
    by_cases [expr h, ":", expr «expr = »(«expr∑ in , »((x : exprℕ()), finset.range d, F x), 0)],
    { rw ["[", expr h, ",", expr zero_add, "]"] [],
      exact [expr hF d (lt_add_one _)] },
    { refine [expr lt_of_lt_of_le _ (min_le_padic_val_rat_add p h (λ h1, _) hn0)],
      { refine [expr lt_min (hd (λ i hi, _) h) (hF d (lt_add_one _))],
        exact [expr hF _ (lt_trans hi (lt_add_one _))] },
      { have [ident h2] [] [":=", expr hF d (lt_add_one _)],
        rw [expr h1] ["at", ident h2],
        exact [expr lt_irrefl _ h2] } } }
end

end padicValRat

namespace padicValNat

/--
A rewrite lemma for `padic_val_nat p (q * r)` with conditions `q ≠ 0`, `r ≠ 0`.
-/
protected theorem mul (p : ℕ) [p_prime : Fact p.prime] {q r : ℕ} (hq : q ≠ 0) (hr : r ≠ 0) :
  padicValNat p (q*r) = padicValNat p q+padicValNat p r :=
  by 
    apply Int.coe_nat_inj 
    simp only [padic_val_rat_of_nat, Nat.cast_mul]
    rw [padicValRat.mul]
    normCast 
    exact cast_ne_zero.mpr hq 
    exact cast_ne_zero.mpr hr

-- error in NumberTheory.Padics.PadicNorm: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
Dividing out by a prime factor reduces the padic_val_nat by 1.
-/
protected
theorem div
{p : exprℕ()}
[p_prime : fact p.prime]
{b : exprℕ()}
(dvd : «expr ∣ »(p, b)) : «expr = »(padic_val_nat p «expr / »(b, p), «expr - »(padic_val_nat p b, 1)) :=
begin
  by_cases [expr b_split, ":", expr «expr = »(b, 0)],
  { simp [] [] [] ["[", expr b_split, "]"] [] [] },
  { have [ident split_frac] [":", expr «expr = »(padic_val_rat p «expr / »(b, p), «expr - »(padic_val_rat p b, padic_val_rat p p))] [":=", expr padic_val_rat.div p (nat.cast_ne_zero.mpr b_split) (nat.cast_ne_zero.mpr (nat.prime.ne_zero p_prime.1))],
    rw [expr padic_val_rat.padic_val_rat_self (nat.prime.one_lt p_prime.1)] ["at", ident split_frac],
    have [ident r] [":", expr «expr ≤ »(1, padic_val_nat p b)] [":=", expr one_le_padic_val_nat_of_dvd b_split dvd],
    exact_mod_cast [expr split_frac] }
end

/-- A version of `padic_val_rat.pow` for `padic_val_nat` -/
protected theorem pow (p q n : ℕ) [Fact p.prime] (hq : q ≠ 0) : padicValNat p (q^n) = n*padicValNat p q :=
  by 
    apply @Nat.cast_injective ℤ 
    pushCast 
    exact padicValRat.pow _ (cast_ne_zero.mpr hq)

end padicValNat

section padicValNat

/--
If a prime doesn't appear in `n`, `padic_val_nat p n` is `0`.
-/
theorem padic_val_nat_of_not_dvd {p : ℕ} [Fact p.prime] {n : ℕ} (not_dvd : ¬p ∣ n) : padicValNat p n = 0 :=
  by 
    byCases' hn : n = 0
    ·
      subst hn 
      simp  at not_dvd 
      trivial
    ·
      rw [padic_val_nat_def hn]
      exact
        (@multiplicity.unique' _ _ _ p n 0
            (by 
              simp )
            (by 
              simpa using not_dvd)).symm
          
      assumption

theorem dvd_of_one_le_padic_val_nat {n p : Nat} [prime : Fact p.prime] (hp : 1 ≤ padicValNat p n) : p ∣ n :=
  by 
    byContra h 
    rw [padic_val_nat_of_not_dvd h] at hp 
    exact lt_irreflₓ 0 (lt_of_lt_of_leₓ zero_lt_one hp)

theorem pow_padic_val_nat_dvd {p n : ℕ} [Fact (Nat.Prime p)] : (p^padicValNat p n) ∣ n :=
  by 
    cases' Nat.eq_zero_or_posₓ n with hn hn
    ·
      rw [hn]
      exact dvd_zero (p^padicValNat p 0)
    ·
      rw [multiplicity.pow_dvd_iff_le_multiplicity]
      apply le_of_eqₓ 
      rw [padic_val_nat_def (ne_of_gtₓ hn)]
      ·
        apply Enat.coe_get
      ·
        infer_instance

theorem pow_succ_padic_val_nat_not_dvd {p n : ℕ} [hp : Fact (Nat.Prime p)] (hn : 0 < n) : ¬(p^padicValNat p n+1) ∣ n :=
  by 
    ·
      rw [multiplicity.pow_dvd_iff_le_multiplicity]
      rw [padic_val_nat_def (ne_of_gtₓ hn)]
      ·
        rw [Nat.cast_add, Enat.coe_get]
        simp only [Nat.cast_one, not_leₓ]
        apply Enat.lt_add_one (ne_top_iff_finite.2 (finite_nat_iff.2 ⟨hp.elim.ne_one, hn⟩))
      ·
        infer_instance

theorem padic_val_nat_primes {p q : ℕ} [p_prime : Fact p.prime] [q_prime : Fact q.prime] (neq : p ≠ q) :
  padicValNat p q = 0 :=
  @padic_val_nat_of_not_dvd p p_prime q$ (not_congr (Iff.symm (prime_dvd_prime_iff_eq p_prime.1 q_prime.1))).mp neq

protected theorem padicValNat.div' {p : ℕ} [p_prime : Fact p.prime] :
  ∀ {m : ℕ} (cpm : coprime p m) {b : ℕ} (dvd : m ∣ b), padicValNat p (b / m) = padicValNat p b
| 0 =>
  fun cpm b dvd =>
    by 
      rw [zero_dvd_iff] at dvd 
      rw [dvd, Nat.zero_divₓ]
| n+1 =>
  fun cpm b dvd =>
    by 
      rcases dvd with ⟨c, rfl⟩
      rw [mul_div_right c (Nat.succ_posₓ _)]
      byCases' hc : c = 0
      ·
        rw [hc, mul_zero]
      ·
        rw [padicValNat.mul]
        ·
          suffices  : ¬p ∣ n+1
          ·
            rw [padic_val_nat_of_not_dvd this, zero_addₓ]
          contrapose! cpm 
          exact p_prime.1.dvd_iff_not_coprime.mp cpm
        ·
          exact Nat.succ_ne_zero _
        ·
          exact hc

-- error in NumberTheory.Padics.PadicNorm: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem padic_val_nat_eq_factors_count
(p : exprℕ())
[hp : fact p.prime] : ∀ n : exprℕ(), «expr = »(padic_val_nat p n, (factors n).count p)
| 0 := by simp [] [] [] [] [] []
| 1 := by simp [] [] [] [] [] []
| «expr + »(m, 2) := let n := «expr + »(m, 2) in
let q := min_fac n in
have hq : fact q.prime := ⟨min_fac_prime (show «expr ≠ »(«expr + »(m, 2), 1), by linarith [] [] [])⟩,
have wf : «expr < »(«expr / »(n, q), n) := nat.div_lt_self (nat.succ_pos _) hq.1.one_lt,
begin
  rw [expr factors_add_two] [],
  show [expr «expr = »(padic_val_nat p n, list.count p [«expr :: »/«expr :: »/«expr :: »](q, factors «expr / »(n, q)))],
  rw ["[", expr list.count_cons', ",", "<-", expr padic_val_nat_eq_factors_count, "]"] [],
  split_ifs [] ["with", ident h],
  have [ident p_dvd_n] [":", expr «expr ∣ »(p, n)] [],
  { have [] [":", expr «expr ∣ »(q, n)] [":=", expr nat.min_fac_dvd n],
    cc },
  { rw ["[", "<-", expr h, ",", expr padic_val_nat.div, "]"] [],
    { have [] [":", expr «expr ≤ »(1, padic_val_nat p n)] [":=", expr one_le_padic_val_nat_of_dvd (by linarith [] [] []) p_dvd_n],
      exact [expr (tsub_eq_iff_eq_add_of_le this).mp rfl] },
    { exact [expr p_dvd_n] } },
  { suffices [] [":", expr p.coprime q],
    { rw ["[", expr padic_val_nat.div' this (min_fac_dvd n), ",", expr add_zero, "]"] [] },
    rwa [expr nat.coprime_primes hp.1 hq.1] [] }
end

@[simp]
theorem padic_val_nat_self (p : ℕ) [Fact p.prime] : padicValNat p p = 1 :=
  by 
    simp [padic_val_nat_def (Fact.out p.prime).ne_zero]

@[simp]
theorem padic_val_nat_prime_pow (p n : ℕ) [Fact p.prime] : padicValNat p (p^n) = n :=
  by 
    rw [padicValNat.pow p _ _ (Fact.out p.prime).ne_zero, padic_val_nat_self p, mul_oneₓ]

open_locale BigOperators

-- error in NumberTheory.Padics.PadicNorm: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem prod_pow_prime_padic_val_nat
(n : nat)
(hn : «expr ≠ »(n, 0))
(m : nat)
(pr : «expr < »(n, m)) : «expr = »(«expr∏ in , »((p), finset.filter nat.prime (finset.range m), «expr ^ »(p, padic_val_nat p n)), n) :=
begin
  rw ["<-", expr pos_iff_ne_zero] ["at", ident hn],
  have [ident H] [":", expr «expr = »((factors n : multiset exprℕ()).prod, n)] [],
  { rw ["[", expr multiset.coe_prod, ",", expr prod_factors hn, "]"] [] },
  rw [expr finset.prod_multiset_count] ["at", ident H],
  conv_rhs [] [] { rw ["<-", expr H] },
  refine [expr finset.prod_bij_ne_one (λ p hp hp', p) _ _ _ _],
  { rintro [ident p, ident hp, ident hpn],
    rw ["[", expr finset.mem_filter, ",", expr finset.mem_range, "]"] ["at", ident hp],
    rw ["[", expr multiset.mem_to_finset, ",", expr multiset.mem_coe, ",", expr mem_factors_iff_dvd hn hp.2, "]"] [],
    contrapose ["!"] [ident hpn],
    haveI [ident Hp] [":", expr fact p.prime] [":=", expr ⟨hp.2⟩],
    rw ["[", expr padic_val_nat_of_not_dvd hpn, ",", expr pow_zero, "]"] [] },
  { intros [],
    assumption },
  { intros [ident p, ident hp, ident hpn],
    rw ["[", expr multiset.mem_to_finset, ",", expr multiset.mem_coe, "]"] ["at", ident hp],
    haveI [ident Hp] [":", expr fact p.prime] [":=", expr ⟨prime_of_mem_factors hp⟩],
    simp [] [] ["only"] ["[", expr exists_prop, ",", expr ne.def, ",", expr finset.mem_filter, ",", expr finset.mem_range, "]"] [] [],
    refine [expr ⟨p, ⟨_, Hp.1⟩, ⟨_, rfl⟩⟩],
    { rw [expr mem_factors_iff_dvd hn Hp.1] ["at", ident hp],
      exact [expr lt_of_le_of_lt (le_of_dvd hn hp) pr] },
    { rw [expr padic_val_nat_eq_factors_count] [],
      simpa [] [] [] ["[", expr ne.def, ",", expr multiset.coe_count, "]"] [] ["using", expr hpn] } },
  { intros [ident p, ident hp, ident hpn],
    rw ["[", expr finset.mem_filter, ",", expr finset.mem_range, "]"] ["at", ident hp],
    haveI [ident Hp] [":", expr fact p.prime] [":=", expr ⟨hp.2⟩],
    rw ["[", expr padic_val_nat_eq_factors_count, ",", expr multiset.coe_count, "]"] [] }
end

end padicValNat

/--
If `q ≠ 0`, the p-adic norm of a rational `q` is `p ^ (-(padic_val_rat p q))`.
If `q = 0`, the p-adic norm of `q` is 0.
-/
def padicNorm (p : ℕ) (q : ℚ) : ℚ :=
  if q = 0 then 0 else («expr↑ » p : ℚ)^-padicValRat p q

namespace padicNorm

section padicNorm

open padicValRat

variable(p : ℕ)

/--
Unfolds the definition of the p-adic norm of `q` when `q ≠ 0`.
-/
@[simp]
protected theorem eq_zpow_of_nonzero {q : ℚ} (hq : q ≠ 0) : padicNorm p q = (p^-padicValRat p q) :=
  by 
    simp [hq, padicNorm]

/--
The p-adic norm is nonnegative.
-/
protected theorem nonneg (q : ℚ) : 0 ≤ padicNorm p q :=
  if hq : q = 0 then
    by 
      simp [hq, padicNorm]
  else
    by 
      unfold padicNorm <;> splitIfs 
      apply zpow_nonneg 
      exactModCast Nat.zero_leₓ _

/--
The p-adic norm of 0 is 0.
-/
@[simp]
protected theorem zero : padicNorm p 0 = 0 :=
  by 
    simp [padicNorm]

/--
The p-adic norm of 1 is 1.
-/
@[simp]
protected theorem one : padicNorm p 1 = 1 :=
  by 
    simp [padicNorm]

/--
The p-adic norm of `p` is `1/p` if `p > 1`.

See also `padic_norm.padic_norm_p_of_prime` for a version that assumes `p` is prime.
-/
theorem padic_norm_p {p : ℕ} (hp : 1 < p) : padicNorm p p = 1 / p :=
  by 
    simp [padicNorm,
      show p ≠ 0 by 
        linarith,
      padicValRat.padic_val_rat_self hp]

/--
The p-adic norm of `p` is `1/p` if `p` is prime.

See also `padic_norm.padic_norm_p` for a version that assumes `1 < p`.
-/
@[simp]
theorem padic_norm_p_of_prime (p : ℕ) [Fact p.prime] : padicNorm p p = 1 / p :=
  padic_norm_p$ Nat.Prime.one_lt (Fact.out _)

-- error in NumberTheory.Padics.PadicNorm: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- The p-adic norm of `q` is `1` if `q` is prime and not equal to `p`. -/
theorem padic_norm_of_prime_of_ne
{p q : exprℕ()}
[p_prime : fact p.prime]
[q_prime : fact q.prime]
(neq : «expr ≠ »(p, q)) : «expr = »(padic_norm p q, 1) :=
begin
  have [ident p] [":", expr «expr = »(padic_val_rat p q, 0)] [],
  { exact_mod_cast [expr @padic_val_nat_primes p q p_prime q_prime neq] },
  simp [] [] [] ["[", expr padic_norm, ",", expr p, ",", expr q_prime.1.1, ",", expr q_prime.1.ne_zero, "]"] [] []
end

/--
The p-adic norm of `p` is less than 1 if `1 < p`.

See also `padic_norm.padic_norm_p_lt_one_of_prime` for a version assuming `prime p`.
-/
theorem padic_norm_p_lt_one {p : ℕ} (hp : 1 < p) : padicNorm p p < 1 :=
  by 
    rw [padic_norm_p hp, div_lt_iff, one_mulₓ]
    ·
      exactModCast hp
    ·
      exactModCast zero_lt_one.trans hp

/--
The p-adic norm of `p` is less than 1 if `p` is prime.

See also `padic_norm.padic_norm_p_lt_one` for a version assuming `1 < p`.
-/
theorem padic_norm_p_lt_one_of_prime (p : ℕ) [Fact p.prime] : padicNorm p p < 1 :=
  padic_norm_p_lt_one$ Nat.Prime.one_lt (Fact.out _)

/--
`padic_norm p q` takes discrete values `p ^ -z` for `z : ℤ`.
-/
protected theorem values_discrete {q : ℚ} (hq : q ≠ 0) : ∃ z : ℤ, padicNorm p q = (p^-z) :=
  ⟨padicValRat p q,
    by 
      simp [padicNorm, hq]⟩

/--
`padic_norm p` is symmetric.
-/
@[simp]
protected theorem neg (q : ℚ) : padicNorm p (-q) = padicNorm p q :=
  if hq : q = 0 then
    by 
      simp [hq]
  else
    by 
      simp [padicNorm, hq]

variable[hp : Fact p.prime]

include hp

/--
If `q ≠ 0`, then `padic_norm p q ≠ 0`.
-/
protected theorem nonzero {q : ℚ} (hq : q ≠ 0) : padicNorm p q ≠ 0 :=
  by 
    rw [padicNorm.eq_zpow_of_nonzero p hq]
    apply zpow_ne_zero_of_ne_zero 
    exactModCast ne_of_gtₓ hp.1.Pos

/--
If the p-adic norm of `q` is 0, then `q` is 0.
-/
theorem zero_of_padic_norm_eq_zero {q : ℚ} (h : padicNorm p q = 0) : q = 0 :=
  by 
    apply by_contradiction 
    intro hq 
    unfold padicNorm  at h 
    rw [if_neg hq] at h 
    apply absurd h 
    apply zpow_ne_zero_of_ne_zero 
    exactModCast hp.1.ne_zero

/--
The p-adic norm is multiplicative.
-/
@[simp]
protected theorem mul (q r : ℚ) : padicNorm p (q*r) = padicNorm p q*padicNorm p r :=
  if hq : q = 0 then
    by 
      simp [hq]
  else
    if hr : r = 0 then
      by 
        simp [hr]
    else
      have  : (q*r) ≠ 0 := mul_ne_zero hq hr 
      have  : («expr↑ » p : ℚ) ≠ 0 :=
        by 
          simp [hp.1.ne_zero]
      by 
        simp [padicNorm, padicValRat.mul, zpow_add₀ this, mul_commₓ]

/--
The p-adic norm respects division.
-/
@[simp]
protected theorem div (q r : ℚ) : padicNorm p (q / r) = padicNorm p q / padicNorm p r :=
  if hr : r = 0 then
    by 
      simp [hr]
  else
    eq_div_of_mul_eq (padicNorm.nonzero _ hr)
      (by 
        rw [←padicNorm.mul, div_mul_cancel _ hr])

/--
The p-adic norm of an integer is at most 1.
-/
protected theorem of_int (z : ℤ) : padicNorm p («expr↑ » z) ≤ 1 :=
  if hz : z = 0 then
    by 
      simp [hz, zero_le_one]
  else
    by 
      unfold padicNorm 
      rw [if_neg _]
      ·
        refine' zpow_le_one_of_nonpos _ _
        ·
          exactModCast le_of_ltₓ hp.1.one_lt
        ·
          rw [padic_val_rat_of_int _ hp.1.ne_one hz, neg_nonpos]
          normCast 
          simp 
      exactModCast hz

-- error in NumberTheory.Padics.PadicNorm: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
private
theorem nonarchimedean_aux
{q r : exprℚ()}
(h : «expr ≤ »(padic_val_rat p q, padic_val_rat p r)) : «expr ≤ »(padic_norm p «expr + »(q, r), max (padic_norm p q) (padic_norm p r)) :=
have hnqp : «expr ≥ »(padic_norm p q, 0), from padic_norm.nonneg _ _,
have hnrp : «expr ≥ »(padic_norm p r, 0), from padic_norm.nonneg _ _,
if hq : «expr = »(q, 0) then by simp [] [] [] ["[", expr hq, ",", expr max_eq_right hnrp, ",", expr le_max_right, "]"] [] [] else if hr : «expr = »(r, 0) then by simp [] [] [] ["[", expr hr, ",", expr max_eq_left hnqp, ",", expr le_max_left, "]"] [] [] else if hqr : «expr = »(«expr + »(q, r), 0) then le_trans (by simpa [] [] [] ["[", expr hqr, "]"] [] ["using", expr hnqp]) (le_max_left _ _) else begin
  unfold [ident padic_norm] [],
  split_ifs [] [],
  apply [expr le_max_iff.2],
  left,
  apply [expr zpow_le_of_le],
  { exact_mod_cast [expr le_of_lt hp.1.one_lt] },
  { apply [expr neg_le_neg],
    have [] [":", expr «expr = »(padic_val_rat p q, min (padic_val_rat p q) (padic_val_rat p r))] [],
    from [expr (min_eq_left h).symm],
    rw [expr this] [],
    apply [expr min_le_padic_val_rat_add]; assumption }
end

/--
The p-adic norm is nonarchimedean: the norm of `p + q` is at most the max of the norm of `p` and
the norm of `q`.
-/
protected theorem nonarchimedean {q r : ℚ} : padicNorm p (q+r) ≤ max (padicNorm p q) (padicNorm p r) :=
  by 
    wlog hle := le_totalₓ (padicValRat p q) (padicValRat p r) using q r 
    exact nonarchimedean_aux p hle

/--
The p-adic norm respects the triangle inequality: the norm of `p + q` is at most the norm of `p`
plus the norm of `q`.
-/
theorem triangle_ineq (q r : ℚ) : padicNorm p (q+r) ≤ padicNorm p q+padicNorm p r :=
  calc padicNorm p (q+r) ≤ max (padicNorm p q) (padicNorm p r) := padicNorm.nonarchimedean p 
    _ ≤ padicNorm p q+padicNorm p r := max_le_add_of_nonneg (padicNorm.nonneg p _) (padicNorm.nonneg p _)
    

/--
The p-adic norm of a difference is at most the max of each component. Restates the archimedean
property of the p-adic norm.
-/
protected theorem sub {q r : ℚ} : padicNorm p (q - r) ≤ max (padicNorm p q) (padicNorm p r) :=
  by 
    rw [sub_eq_add_neg, ←padicNorm.neg p r] <;> apply padicNorm.nonarchimedean

-- error in NumberTheory.Padics.PadicNorm: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/--
If the p-adic norms of `q` and `r` are different, then the norm of `q + r` is equal to the max of
the norms of `q` and `r`.
-/
theorem add_eq_max_of_ne
{q r : exprℚ()}
(hne : «expr ≠ »(padic_norm p q, padic_norm p r)) : «expr = »(padic_norm p «expr + »(q, r), max (padic_norm p q) (padic_norm p r)) :=
begin
  wlog [ident hle] [] [":=", expr le_total (padic_norm p r) (padic_norm p q)] ["using", "[", ident q, ident r, "]"],
  have [ident hlt] [":", expr «expr < »(padic_norm p r, padic_norm p q)] [],
  from [expr lt_of_le_of_ne hle hne.symm],
  have [] [":", expr «expr ≤ »(padic_norm p q, max (padic_norm p «expr + »(q, r)) (padic_norm p r))] [],
  from [expr calc
     «expr = »(padic_norm p q, padic_norm p «expr - »(«expr + »(q, r), r)) : by congr; ring []
     «expr ≤ »(..., max (padic_norm p «expr + »(q, r)) (padic_norm p «expr- »(r))) : padic_norm.nonarchimedean p
     «expr = »(..., max (padic_norm p «expr + »(q, r)) (padic_norm p r)) : by simp [] [] [] [] [] []],
  have [ident hnge] [":", expr «expr ≤ »(padic_norm p r, padic_norm p «expr + »(q, r))] [],
  { apply [expr le_of_not_gt],
    intro [ident hgt],
    rw [expr max_eq_right_of_lt hgt] ["at", ident this],
    apply [expr not_lt_of_ge this],
    assumption },
  have [] [":", expr «expr ≤ »(padic_norm p q, padic_norm p «expr + »(q, r))] [],
  by rwa ["[", expr max_eq_left hnge, "]"] ["at", ident this],
  apply [expr _root_.le_antisymm],
  { apply [expr padic_norm.nonarchimedean p] },
  { rw [expr max_eq_left_of_lt hlt] [],
    assumption }
end

/--
The p-adic norm is an absolute value: positive-definite and multiplicative, satisfying the triangle
inequality.
-/
instance  : IsAbsoluteValue (padicNorm p) :=
  { abv_nonneg := padicNorm.nonneg p,
    abv_eq_zero :=
      by 
        intros 
        constructor <;> intro 
        ·
          apply zero_of_padic_norm_eq_zero p 
          assumption
        ·
          simp ,
    abv_add := padicNorm.triangle_ineq p, abv_mul := padicNorm.mul p }

variable{p}

-- error in NumberTheory.Padics.PadicNorm: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem dvd_iff_norm_le
{n : exprℕ()}
{z : exprℤ()} : «expr ↔ »(«expr ∣ »(«expr↑ »(«expr ^ »(p, n)), z), «expr ≤ »(padic_norm p z, «expr ^ »(«expr↑ »(p), («expr- »(n) : exprℤ())))) :=
begin
  unfold [ident padic_norm] [],
  split_ifs [] ["with", ident hz],
  { norm_cast ["at", ident hz],
    have [] [":", expr «expr ≤ »(0, («expr ^ »(p, n) : exprℚ()))] [],
    { apply [expr pow_nonneg],
      exact_mod_cast [expr le_of_lt hp.1.pos] },
    simp [] [] [] ["[", expr hz, ",", expr this, "]"] [] [] },
  { rw ["[", expr zpow_le_iff_le, ",", expr neg_le_neg_iff, ",", expr padic_val_rat_of_int _ hp.1.ne_one _, "]"] [],
    { norm_cast [],
      rw ["[", "<-", expr enat.coe_le_coe, ",", expr enat.coe_get, ",", "<-", expr multiplicity.pow_dvd_iff_le_multiplicity, "]"] [],
      simp [] [] [] [] [] [] },
    { exact_mod_cast [expr hz] },
    { exact_mod_cast [expr hp.1.one_lt] } }
end

end padicNorm

end padicNorm

