/-
Copyright (c) 2022 Michael Stoll. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Michael Stoll

! This file was ported from Lean 3 source module number_theory.legendre_symbol.jacobi_symbol
! leanprover-community/mathlib commit aba57d4d3dae35460225919dcd82fe91355162f9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.NumberTheory.LegendreSymbol.QuadraticReciprocity

/-!
# The Jacobi Symbol

We define the Jacobi symbol and prove its main properties.

## Main definitions

We define the Jacobi symbol, `jacobi_sym a b`, for integers `a` and natural numbers `b`
as the product over the prime factors `p` of `b` of the Legendre symbols `legendre_sym p a`.
This agrees with the mathematical definition when `b` is odd.

The prime factors are obtained via `nat.factors`. Since `nat.factors 0 = []`,
this implies in particular that `jacobi_sym a 0 = 1` for all `a`.

## Main statements

We prove the main properties of the Jacobi symbol, including the following.

* Multiplicativity in both arguments (`jacobi_sym.mul_left`, `jacobi_sym.mul_right`)

* The value of the symbol is `1` or `-1` when the arguments are coprime
  (`jacobi_sym.eq_one_or_neg_one`)

* The symbol vanishes if and only if `b ≠ 0` and the arguments are not coprime
  (`jacobi_sym.eq_zero_iff`)

* If the symbol has the value `-1`, then `a : zmod b` is not a square
  (`zmod.nonsquare_of_jacobi_sym_eq_neg_one`); the converse holds when `b = p` is a prime
  (`zmod.nonsquare_iff_jacobi_sym_eq_neg_one`); in particular, in this case `a` is a
  square mod `p` when the symbol has the value `1` (`zmod.is_square_of_jacobi_sym_eq_one`).

* Quadratic reciprocity (`jacobi_sym.quadratic_reciprocity`,
  `jacobi_sym.quadratic_reciprocity_one_mod_four`,
  `jacobi_sym.quadratic_reciprocity_three_mod_four`)

* The supplementary laws for `a = -1`, `a = 2`, `a = -2` (`jacobi_sym.at_neg_one`,
  `jacobi_sym.at_two`, `jacobi_sym.at_neg_two`)

* The symbol depends on `a` only via its residue class mod `b` (`jacobi_sym.mod_left`)
  and on `b` only via its residue class mod `4*a` (`jacobi_sym.mod_right`)

## Notations

We define the notation `J(a | b)` for `jacobi_sym a b`, localized to `number_theory_symbols`.

## Tags
Jacobi symbol, quadratic reciprocity
-/


section Jacobi

/-!
### Definition of the Jacobi symbol

We define the Jacobi symbol $\Bigl(\frac{a}{b}\Bigr)$ for integers `a` and natural numbers `b`
as the product of the Legendre symbols $\Bigl(\frac{a}{p}\Bigr)$, where `p` runs through the
prime divisors (with multiplicity) of `b`, as provided by `b.factors`. This agrees with the
Jacobi symbol when `b` is odd and gives less meaningful values when it is not (e.g., the symbol
is `1` when `b = 0`). This is called `jacobi_sym a b`.

We define localized notation (locale `number_theory_symbols`) `J(a | b)` for the Jacobi
symbol `jacobi_sym a b`.
-/


open Nat Zmod

-- Since we need the fact that the factors are prime, we use `list.pmap`.
/-- The Jacobi symbol of `a` and `b` -/
def jacobiSym (a : ℤ) (b : ℕ) : ℤ :=
  (b.factors.pmap (fun p pp => @legendreSym p ⟨pp⟩ a) fun p pf => prime_of_mem_factors pf).Prod
#align jacobi_sym jacobiSym

-- mathport name: «exprJ( | )»
-- Notation for the Jacobi symbol.
scoped[NumberTheorySymbols] notation "J(" a " | " b ")" => jacobiSym a b

/-!
### Properties of the Jacobi symbol
-/


namespace jacobiSym

/-- The symbol `J(a | 0)` has the value `1`. -/
@[simp]
theorem zero_right (a : ℤ) : J(a | 0) = 1 := by
  simp only [jacobiSym, factors_zero, List.prod_nil, List.pmap]
#align jacobi_sym.zero_right jacobiSym.zero_right

/-- The symbol `J(a | 1)` has the value `1`. -/
@[simp]
theorem one_right (a : ℤ) : J(a | 1) = 1 := by
  simp only [jacobiSym, factors_one, List.prod_nil, List.pmap]
#align jacobi_sym.one_right jacobiSym.one_right

/-- The Legendre symbol `legendre_sym p a` with an integer `a` and a prime number `p`
is the same as the Jacobi symbol `J(a | p)`. -/
theorem legendreSym.to_jacobi_sym (p : ℕ) [fp : Fact p.Prime] (a : ℤ) :
    legendreSym p a = J(a | p) := by
  simp only [jacobiSym, factors_prime fp.1, List.prod_cons, List.prod_nil, mul_one, List.pmap]
#align legendre_sym.to_jacobi_sym legendreSym.to_jacobi_sym

/-- The Jacobi symbol is multiplicative in its second argument. -/
theorem mul_right' (a : ℤ) {b₁ b₂ : ℕ} (hb₁ : b₁ ≠ 0) (hb₂ : b₂ ≠ 0) :
    J(a | b₁ * b₂) = J(a | b₁) * J(a | b₂) := by
  rw [jacobiSym, ((perm_factors_mul hb₁ hb₂).pmap _).prod_eq, List.pmap_append, List.prod_append]
  exacts[rfl, fun p hp => (list.mem_append.mp hp).elim prime_of_mem_factors prime_of_mem_factors]
#align jacobi_sym.mul_right' jacobiSym.mul_right'

/-- The Jacobi symbol is multiplicative in its second argument. -/
theorem mul_right (a : ℤ) (b₁ b₂ : ℕ) [NeZero b₁] [NeZero b₂] :
    J(a | b₁ * b₂) = J(a | b₁) * J(a | b₂) :=
  mul_right' a (NeZero.ne b₁) (NeZero.ne b₂)
#align jacobi_sym.mul_right jacobiSym.mul_right

/-- The Jacobi symbol takes only the values `0`, `1` and `-1`. -/
theorem trichotomy (a : ℤ) (b : ℕ) : J(a | b) = 0 ∨ J(a | b) = 1 ∨ J(a | b) = -1 :=
  ((@SignType.castHom ℤ _ _).toMonoidHom.mrange.copy {0, 1, -1} <| by
        rw [Set.pair_comm]
        exact (SignType.range_eq SignType.castHom).symm).list_prod_mem
    (by 
      intro _ ha'
      rcases list.mem_pmap.mp ha' with ⟨p, hp, rfl⟩
      haveI : Fact p.prime := ⟨prime_of_mem_factors hp⟩
      exact quadratic_char_is_quadratic (Zmod p) a)
#align jacobi_sym.trichotomy jacobiSym.trichotomy

/-- The symbol `J(1 | b)` has the value `1`. -/
@[simp]
theorem one_left (b : ℕ) : J(1 | b) = 1 :=
  List.prod_eq_one fun z hz => by 
    let ⟨p, hp, he⟩ := List.mem_pmap.1 hz
    rw [← he, legendreSym.at_one]
#align jacobi_sym.one_left jacobiSym.one_left

/-- The Jacobi symbol is multiplicative in its first argument. -/
theorem mul_left (a₁ a₂ : ℤ) (b : ℕ) : J(a₁ * a₂ | b) = J(a₁ | b) * J(a₂ | b) := by
  simp_rw [jacobiSym, List.pmap_eq_map_attach, legendreSym.mul]
  exact List.prod_map_mul
#align jacobi_sym.mul_left jacobiSym.mul_left

/-- The symbol `J(a | b)` vanishes iff `a` and `b` are not coprime (assuming `b ≠ 0`). -/
theorem eq_zero_iff_not_coprime {a : ℤ} {b : ℕ} [NeZero b] : J(a | b) = 0 ↔ a.gcd b ≠ 1 :=
  List.prod_eq_zero_iff.trans
    (by 
      rw [List.mem_pmap, Int.gcd_eq_nat_abs, Ne, prime.not_coprime_iff_dvd]
      simp_rw [legendreSym.eq_zero_iff, int_coe_zmod_eq_zero_iff_dvd, mem_factors (NeZero.ne b), ←
        Int.coe_nat_dvd_left, Int.coe_nat_dvd, exists_prop, and_assoc', and_comm'])
#align jacobi_sym.eq_zero_iff_not_coprime jacobiSym.eq_zero_iff_not_coprime

/-- The symbol `J(a | b)` is nonzero when `a` and `b` are coprime. -/
protected theorem ne_zero {a : ℤ} {b : ℕ} (h : a.gcd b = 1) : J(a | b) ≠ 0 := by
  cases' eq_zero_or_neZero b with hb
  · rw [hb, zero_right]
    exact one_ne_zero
  · contrapose! h
    exact eq_zero_iff_not_coprime.1 h
#align jacobi_sym.ne_zero jacobiSym.ne_zero

/-- The symbol `J(a | b)` vanishes if and only if `b ≠ 0` and `a` and `b` are not coprime. -/
theorem eq_zero_iff {a : ℤ} {b : ℕ} : J(a | b) = 0 ↔ b ≠ 0 ∧ a.gcd b ≠ 1 :=
  ⟨fun h => by 
    cases' eq_or_ne b 0 with hb hb
    · rw [hb, zero_right] at h
      cases h
    exact ⟨hb, mt jacobiSym.ne_zero <| not_not.2 h⟩, fun ⟨hb, h⟩ => by
    rw [← neZero_iff] at hb
    exact eq_zero_iff_not_coprime.2 h⟩
#align jacobi_sym.eq_zero_iff jacobiSym.eq_zero_iff

/-- The symbol `J(0 | b)` vanishes when `b > 1`. -/
theorem zero_left {b : ℕ} (hb : 1 < b) : J(0 | b) = 0 :=
  (@eq_zero_iff_not_coprime 0 b ⟨ne_zero_of_lt hb⟩).mpr <| by
    rw [Int.gcd_zero_left, Int.natAbs_ofNat]
    exact hb.ne'
#align jacobi_sym.zero_left jacobiSym.zero_left

/-- The symbol `J(a | b)` takes the value `1` or `-1` if `a` and `b` are coprime. -/
theorem eq_one_or_neg_one {a : ℤ} {b : ℕ} (h : a.gcd b = 1) : J(a | b) = 1 ∨ J(a | b) = -1 :=
  (trichotomy a b).resolve_left <| jacobiSym.ne_zero h
#align jacobi_sym.eq_one_or_neg_one jacobiSym.eq_one_or_neg_one

/-- We have that `J(a^e | b) = J(a | b)^e`. -/
theorem pow_left (a : ℤ) (e b : ℕ) : J(a ^ e | b) = J(a | b) ^ e :=
  (Nat.recOn e (by rw [pow_zero, pow_zero, one_left])) fun _ ih => by
    rw [pow_succ, pow_succ, mul_left, ih]
#align jacobi_sym.pow_left jacobiSym.pow_left

/-- We have that `J(a | b^e) = J(a | b)^e`. -/
theorem pow_right (a : ℤ) (b e : ℕ) : J(a | b ^ e) = J(a | b) ^ e := by
  induction' e with e ih
  · rw [pow_zero, pow_zero, one_right]
  · cases' eq_zero_or_neZero b with hb
    · rw [hb, zero_pow (succ_pos e), zero_right, one_pow]
    · rw [pow_succ, pow_succ, mul_right, ih]
#align jacobi_sym.pow_right jacobiSym.pow_right

/-- The square of `J(a | b)` is `1` when `a` and `b` are coprime. -/
theorem sq_one {a : ℤ} {b : ℕ} (h : a.gcd b = 1) : J(a | b) ^ 2 = 1 := by
  cases' eq_one_or_neg_one h with h₁ h₁ <;> rw [h₁] <;> rfl
#align jacobi_sym.sq_one jacobiSym.sq_one

/-- The symbol `J(a^2 | b)` is `1` when `a` and `b` are coprime. -/
theorem sq_one' {a : ℤ} {b : ℕ} (h : a.gcd b = 1) : J(a ^ 2 | b) = 1 := by rw [pow_left, sq_one h]
#align jacobi_sym.sq_one' jacobiSym.sq_one'

/-- The symbol `J(a | b)` depends only on `a` mod `b`. -/
theorem mod_left (a : ℤ) (b : ℕ) : J(a | b) = J(a % b | b) :=
  congr_arg List.prod <|
    List.pmap_congr _
      (by 
        rintro p hp _ _
        conv_rhs =>
          rw [legendreSym.mod, Int.emod_emod_of_dvd _ (Int.coe_nat_dvd.2 <| dvd_of_mem_factors hp),
            ← legendreSym.mod])
#align jacobi_sym.mod_left jacobiSym.mod_left

/-- The symbol `J(a | b)` depends only on `a` mod `b`. -/
theorem mod_left' {a₁ a₂ : ℤ} {b : ℕ} (h : a₁ % b = a₂ % b) : J(a₁ | b) = J(a₂ | b) := by
  rw [mod_left, h, ← mod_left]
#align jacobi_sym.mod_left' jacobiSym.mod_left'

end jacobiSym

namespace Zmod

open jacobiSym

/-- If `J(a | b)` is `-1`, then `a` is not a square modulo `b`. -/
theorem nonsquare_of_jacobi_sym_eq_neg_one {a : ℤ} {b : ℕ} (h : J(a | b) = -1) :
    ¬IsSquare (a : Zmod b) := fun ⟨r, ha⟩ => by
  rw [← r.coe_val_min_abs, ← Int.cast_mul, int_coe_eq_int_coe_iff', ← sq] at ha
  apply (by norm_num : ¬(0 : ℤ) ≤ -1)
  rw [← h, mod_left, ha, ← mod_left, pow_left]
  apply sq_nonneg
#align zmod.nonsquare_of_jacobi_sym_eq_neg_one Zmod.nonsquare_of_jacobi_sym_eq_neg_one

/-- If `p` is prime, then `J(a | p)` is `-1` iff `a` is not a square modulo `p`. -/
theorem nonsquare_iff_jacobi_sym_eq_neg_one {a : ℤ} {p : ℕ} [Fact p.Prime] :
    J(a | p) = -1 ↔ ¬IsSquare (a : Zmod p) := by
  rw [← legendreSym.to_jacobi_sym]
  exact legendreSym.eq_neg_one_iff p
#align zmod.nonsquare_iff_jacobi_sym_eq_neg_one Zmod.nonsquare_iff_jacobi_sym_eq_neg_one

/-- If `p` is prime and `J(a | p) = 1`, then `a` is q square mod `p`. -/
theorem is_square_of_jacobi_sym_eq_one {a : ℤ} {p : ℕ} [Fact p.Prime] (h : J(a | p) = 1) :
    IsSquare (a : Zmod p) :=
  not_not.mp <| by 
    rw [← nonsquare_iff_jacobi_sym_eq_neg_one, h]
    decide
#align zmod.is_square_of_jacobi_sym_eq_one Zmod.is_square_of_jacobi_sym_eq_one

end Zmod

/-!
### Values at `-1`, `2` and `-2`
-/


namespace jacobiSym

/-- If `χ` is a multiplicative function such that `J(a | p) = χ p` for all odd primes `p`,
then `J(a | b)` equals `χ b` for all odd natural numbers `b`. -/
theorem value_at (a : ℤ) {R : Type _} [CommSemiring R] (χ : R →* ℤ)
    (hp : ∀ (p : ℕ) (pp : p.Prime) (h2 : p ≠ 2), @legendreSym p ⟨pp⟩ a = χ p) {b : ℕ} (hb : Odd b) :
    J(a | b) = χ b := by
  conv_rhs => rw [← prod_factors hb.pos.ne', cast_list_prod, χ.map_list_prod]
  rw [jacobiSym, List.map_map, ← List.pmap_eq_map Nat.Prime _ _ fun _ => prime_of_mem_factors]
  congr 1; apply List.pmap_congr
  exact fun p h pp _ => hp p pp (hb.factors_ne_two h)
#align jacobi_sym.value_at jacobiSym.value_at

/-- If `b` is odd, then `J(-1 | b)` is given by `χ₄ b`. -/
theorem at_neg_one {b : ℕ} (hb : Odd b) : J(-1 | b) = χ₄ b :=
  value_at (-1) χ₄ (fun p pp => @legendreSym.at_neg_one p ⟨pp⟩) hb
#align jacobi_sym.at_neg_one jacobiSym.at_neg_one

/-- If `b` is odd, then `J(-a | b) = χ₄ b * J(a | b)`. -/
protected theorem neg (a : ℤ) {b : ℕ} (hb : Odd b) : J(-a | b) = χ₄ b * J(a | b) := by
  rw [neg_eq_neg_one_mul, mul_left, at_neg_one hb]
#align jacobi_sym.neg jacobiSym.neg

/-- If `b` is odd, then `J(2 | b)` is given by `χ₈ b`. -/
theorem at_two {b : ℕ} (hb : Odd b) : J(2 | b) = χ₈ b :=
  value_at 2 χ₈ (fun p pp => @legendreSym.at_two p ⟨pp⟩) hb
#align jacobi_sym.at_two jacobiSym.at_two

/-- If `b` is odd, then `J(-2 | b)` is given by `χ₈' b`. -/
theorem at_neg_two {b : ℕ} (hb : Odd b) : J(-2 | b) = χ₈' b :=
  value_at (-2) χ₈' (fun p pp => @legendreSym.at_neg_two p ⟨pp⟩) hb
#align jacobi_sym.at_neg_two jacobiSym.at_neg_two

end jacobiSym

/-!
### Quadratic Reciprocity
-/


/-- The bi-multiplicative map giving the sign in the Law of Quadratic Reciprocity -/
def qrSign (m n : ℕ) : ℤ :=
  J(χ₄ m | n)
#align qr_sign qrSign

namespace qrSign

/-- We can express `qr_sign m n` as a power of `-1` when `m` and `n` are odd. -/
theorem neg_one_pow {m n : ℕ} (hm : Odd m) (hn : Odd n) : qrSign m n = (-1) ^ (m / 2 * (n / 2)) :=
  by 
  rw [qrSign, pow_mul, ← χ₄_eq_neg_one_pow (odd_iff.mp hm)]
  cases' odd_mod_four_iff.mp (odd_iff.mp hm) with h h
  · rw [χ₄_nat_one_mod_four h, jacobiSym.one_left, one_pow]
  · rw [χ₄_nat_three_mod_four h, ← χ₄_eq_neg_one_pow (odd_iff.mp hn), jacobiSym.at_neg_one hn]
#align qr_sign.neg_one_pow qrSign.neg_one_pow

/-- When `m` and `n` are odd, then the square of `qr_sign m n` is `1`. -/
theorem sq_eq_one {m n : ℕ} (hm : Odd m) (hn : Odd n) : qrSign m n ^ 2 = 1 := by
  rw [neg_one_pow hm hn, ← pow_mul, mul_comm, pow_mul, neg_one_sq, one_pow]
#align qr_sign.sq_eq_one qrSign.sq_eq_one

/-- `qr_sign` is multiplicative in the first argument. -/
theorem mul_left (m₁ m₂ n : ℕ) : qrSign (m₁ * m₂) n = qrSign m₁ n * qrSign m₂ n := by
  simp_rw [qrSign, Nat.cast_mul, map_mul, jacobiSym.mul_left]
#align qr_sign.mul_left qrSign.mul_left

/-- `qr_sign` is multiplicative in the second argument. -/
theorem mul_right (m n₁ n₂ : ℕ) [NeZero n₁] [NeZero n₂] :
    qrSign m (n₁ * n₂) = qrSign m n₁ * qrSign m n₂ :=
  jacobiSym.mul_right (χ₄ m) n₁ n₂
#align qr_sign.mul_right qrSign.mul_right

/-- `qr_sign` is symmetric when both arguments are odd. -/
protected theorem symm {m n : ℕ} (hm : Odd m) (hn : Odd n) : qrSign m n = qrSign n m := by
  rw [neg_one_pow hm hn, neg_one_pow hn hm, mul_comm (m / 2)]
#align qr_sign.symm qrSign.symm

/-- We can move `qr_sign m n` from one side of an equality to the other when `m` and `n` are odd. -/
theorem eq_iff_eq {m n : ℕ} (hm : Odd m) (hn : Odd n) (x y : ℤ) :
    qrSign m n * x = y ↔ x = qrSign m n * y := by
  refine'
      ⟨fun h' =>
        let h := h'.symm
        _,
        fun h => _⟩ <;>
    rw [h, ← mul_assoc, ← pow_two, sq_eq_one hm hn, one_mul]
#align qr_sign.eq_iff_eq qrSign.eq_iff_eq

end qrSign

namespace jacobiSym

/-- The Law of Quadratic Reciprocity for the Jacobi symbol, version with `qr_sign` -/
theorem quadratic_reciprocity' {a b : ℕ} (ha : Odd a) (hb : Odd b) :
    J(a | b) = qrSign b a * J(b | a) :=
  by
  -- define the right hand side for fixed `a` as a `ℕ →* ℤ`
  let rhs : ℕ → ℕ →* ℤ := fun a =>
    { toFun := fun x => qrSign x a * J(x | a)
      map_one' := by 
        convert ← mul_one _
        symm
        all_goals apply one_left
      map_mul' := fun x y => by rw [qrSign.mul_left, Nat.cast_mul, mul_left, mul_mul_mul_comm] }
  have rhs_apply : ∀ a b : ℕ, rhs a b = qrSign b a * J(b | a) := fun a b => rfl
  refine' value_at a (rhs a) (fun p pp hp => Eq.symm _) hb
  have hpo := pp.eq_two_or_odd'.resolve_left hp
  rw [@legendreSym.to_jacobi_sym p ⟨pp⟩, rhs_apply, Nat.cast_id, qrSign.eq_iff_eq hpo ha,
    qrSign.symm hpo ha]
  refine' value_at p (rhs p) (fun q pq hq => _) ha
  have hqo := pq.eq_two_or_odd'.resolve_left hq
  rw [rhs_apply, Nat.cast_id, ← @legendreSym.to_jacobi_sym p ⟨pp⟩, qrSign.symm hqo hpo,
    qrSign.neg_one_pow hpo hqo, @legendreSym.quadratic_reciprocity' p q ⟨pp⟩ ⟨pq⟩ hp hq]
#align jacobi_sym.quadratic_reciprocity' jacobiSym.quadratic_reciprocity'

/-- The Law of Quadratic Reciprocity for the Jacobi symbol -/
theorem quadratic_reciprocity {a b : ℕ} (ha : Odd a) (hb : Odd b) :
    J(a | b) = (-1) ^ (a / 2 * (b / 2)) * J(b | a) := by
  rw [← qrSign.neg_one_pow ha hb, qrSign.symm ha hb, quadratic_reciprocity' ha hb]
#align jacobi_sym.quadratic_reciprocity jacobiSym.quadratic_reciprocity

/-- The Law of Quadratic Reciprocity for the Jacobi symbol: if `a` and `b` are natural numbers
with `a % 4 = 1` and `b` odd, then `J(a | b) = J(b | a)`. -/
theorem quadratic_reciprocity_one_mod_four {a b : ℕ} (ha : a % 4 = 1) (hb : Odd b) :
    J(a | b) = J(b | a) := by
  rw [quadratic_reciprocity (odd_iff.mpr (odd_of_mod_four_eq_one ha)) hb, pow_mul,
    neg_one_pow_div_two_of_one_mod_four ha, one_pow, one_mul]
#align jacobi_sym.quadratic_reciprocity_one_mod_four jacobiSym.quadratic_reciprocity_one_mod_four

/-- The Law of Quadratic Reciprocity for the Jacobi symbol: if `a` and `b` are natural numbers
with `a` odd and `b % 4 = 1`, then `J(a | b) = J(b | a)`. -/
theorem quadratic_reciprocity_one_mod_four' {a b : ℕ} (ha : Odd a) (hb : b % 4 = 1) :
    J(a | b) = J(b | a) :=
  (quadratic_reciprocity_one_mod_four hb ha).symm
#align jacobi_sym.quadratic_reciprocity_one_mod_four' jacobiSym.quadratic_reciprocity_one_mod_four'

/-- The Law of Quadratic Reciprocityfor the Jacobi symbol: if `a` and `b` are natural numbers
both congruent to `3` mod `4`, then `J(a | b) = -J(b | a)`. -/
theorem quadratic_reciprocity_three_mod_four {a b : ℕ} (ha : a % 4 = 3) (hb : b % 4 = 3) :
    J(a | b) = -J(b | a) := by
  let nop := @neg_one_pow_div_two_of_three_mod_four
  rw [quadratic_reciprocity, pow_mul, nop ha, nop hb, neg_one_mul] <;>
    rwa [odd_iff, odd_of_mod_four_eq_three]
#align
  jacobi_sym.quadratic_reciprocity_three_mod_four jacobiSym.quadratic_reciprocity_three_mod_four

/-- The Jacobi symbol `J(a | b)` depends only on `b` mod `4*a` (version for `a : ℕ`). -/
theorem mod_right' (a : ℕ) {b : ℕ} (hb : Odd b) : J(a | b) = J(a | b % (4 * a)) := by
  rcases eq_or_ne a 0 with (rfl | ha₀)
  · rw [mul_zero, mod_zero]
  have hb' : Odd (b % (4 * a)) := hb.mod_even (Even.mul_right (by norm_num) _)
  rcases exists_eq_pow_mul_and_not_dvd ha₀ 2 (by norm_num) with ⟨e, a', ha₁', ha₂⟩
  have ha₁ := odd_iff.mpr (two_dvd_ne_zero.mp ha₁')
  nth_rw 2 [ha₂]; nth_rw 1 [ha₂]
  rw [Nat.cast_mul, mul_left, mul_left, quadratic_reciprocity' ha₁ hb,
    quadratic_reciprocity' ha₁ hb', Nat.cast_pow, pow_left, pow_left, Nat.cast_two, at_two hb,
    at_two hb']
  congr 1; swap; congr 1
  · simp_rw [qrSign]
    rw [χ₄_nat_mod_four, χ₄_nat_mod_four (b % (4 * a)), mod_mod_of_dvd b (dvd_mul_right 4 a)]
  · rw [mod_left ↑(b % _), mod_left b, Int.coe_nat_mod, Int.emod_emod_of_dvd b]
    simp only [ha₂, Nat.cast_mul, ← mul_assoc]
    exact dvd_mul_left a' _
  cases e; · rfl
  · rw [χ₈_nat_mod_eight, χ₈_nat_mod_eight (b % (4 * a)), mod_mod_of_dvd b]
    use 2 ^ e * a'
    rw [ha₂, pow_succ]
    ring
#align jacobi_sym.mod_right' jacobiSym.mod_right'

/-- The Jacobi symbol `J(a | b)` depends only on `b` mod `4*a`. -/
theorem mod_right (a : ℤ) {b : ℕ} (hb : Odd b) : J(a | b) = J(a | b % (4 * a.natAbs)) := by
  cases' Int.natAbs_eq a with ha ha <;> nth_rw 2 [ha] <;> nth_rw 1 [ha]
  · exact mod_right' a.nat_abs hb
  · have hb' : Odd (b % (4 * a.nat_abs)) := hb.mod_even (Even.mul_right (by norm_num) _)
    rw [jacobiSym.neg _ hb, jacobiSym.neg _ hb', mod_right' _ hb, χ₄_nat_mod_four,
      χ₄_nat_mod_four (b % (4 * _)), mod_mod_of_dvd b (dvd_mul_right 4 _)]
#align jacobi_sym.mod_right jacobiSym.mod_right

end jacobiSym

end Jacobi

