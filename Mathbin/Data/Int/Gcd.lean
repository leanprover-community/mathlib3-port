import Mathbin.Data.Nat.Prime

/-!
# Extended GCD and divisibility over ℤ

## Main definitions

* Given `x y : ℕ`, `xgcd x y` computes the pair of integers `(a, b)` such that
  `gcd x y = x * a + y * b`. `gcd_a x y` and `gcd_b x y` are defined to be `a` and `b`,
  respectively.

## Main statements

* `gcd_eq_gcd_ab`: Bézout's lemma, given `x y : ℕ`, `gcd x y = x * gcd_a x y + y * gcd_b x y`.

## Tags

Bézout's lemma, Bezout's lemma
-/


/-! ### Extended Euclidean algorithm -/


namespace Nat

/-- Helper function for the extended GCD algorithm (`nat.xgcd`). -/
def xgcd_aux : ℕ → ℤ → ℤ → ℕ → ℤ → ℤ → ℕ × ℤ × ℤ
| 0, s, t, r', s', t' => (r', s', t')
| r@(succ _), s, t, r', s', t' =>
  have  : r' % r < r := mod_lt _$ succ_pos _ 
  let q := r' / r 
  xgcd_aux (r' % r) (s' - q*s) (t' - q*t) r s t

@[simp]
theorem xgcd_zero_left {s t r' s' t'} : xgcd_aux 0 s t r' s' t' = (r', s', t') :=
  by 
    simp [xgcd_aux]

theorem xgcd_aux_rec {r s t r' s' t'} (h : 0 < r) :
  xgcd_aux r s t r' s' t' = xgcd_aux (r' % r) (s' - (r' / r)*s) (t' - (r' / r)*t) r s t :=
  by 
    cases r <;> [exact absurd h (lt_irreflₓ _),
      ·
        simp only [xgcd_aux]
        rfl]

/-- Use the extended GCD algorithm to generate the `a` and `b` values
  satisfying `gcd x y = x * a + y * b`. -/
def xgcd (x y : ℕ) : ℤ × ℤ :=
  (xgcd_aux x 1 0 y 0 1).2

/-- The extended GCD `a` value in the equation `gcd x y = x * a + y * b`. -/
def gcd_a (x y : ℕ) : ℤ :=
  (xgcd x y).1

/-- The extended GCD `b` value in the equation `gcd x y = x * a + y * b`. -/
def gcd_b (x y : ℕ) : ℤ :=
  (xgcd x y).2

@[simp]
theorem gcd_a_zero_left {s : ℕ} : gcd_a 0 s = 0 :=
  by 
    unfold gcd_a 
    rw [xgcd, xgcd_zero_left]

@[simp]
theorem gcd_b_zero_left {s : ℕ} : gcd_b 0 s = 1 :=
  by 
    unfold gcd_b 
    rw [xgcd, xgcd_zero_left]

@[simp]
theorem gcd_a_zero_right {s : ℕ} (h : s ≠ 0) : gcd_a s 0 = 1 :=
  by 
    unfold gcd_a xgcd 
    induction s
    ·
      exact absurd rfl h
    ·
      simp [xgcd_aux]

@[simp]
theorem gcd_b_zero_right {s : ℕ} (h : s ≠ 0) : gcd_b s 0 = 0 :=
  by 
    unfold gcd_b xgcd 
    induction s
    ·
      exact absurd rfl h
    ·
      simp [xgcd_aux]

@[simp]
theorem xgcd_aux_fst x y : ∀ s t s' t', (xgcd_aux x s t y s' t').1 = gcd x y :=
  gcd.induction x y
    (by 
      simp )
    fun x y h IH s t s' t' =>
      by 
        simp [xgcd_aux_rec, h, IH] <;> rw [←gcd_rec]

theorem xgcd_aux_val x y : xgcd_aux x 1 0 y 0 1 = (gcd x y, xgcd x y) :=
  by 
    rw [xgcd, ←xgcd_aux_fst x y 1 0 0 1] <;> cases xgcd_aux x 1 0 y 0 1 <;> rfl

theorem xgcd_val x y : xgcd x y = (gcd_a x y, gcd_b x y) :=
  by 
    unfold gcd_a gcd_b <;> cases xgcd x y <;> rfl

section 

parameter (x y : ℕ)

private def P : ℕ × ℤ × ℤ → Prop
| (r, s, t) => (r : ℤ) = (x*s)+y*t

theorem xgcd_aux_P {r r'} : ∀ {s t s' t'}, P (r, s, t) → P (r', s', t') → P (xgcd_aux r s t r' s' t') :=
  gcd.induction r r'
      (by 
        simp )$
    fun a b h IH s t s' t' p p' =>
      by 
        rw [xgcd_aux_rec h]
        refine' IH _ p 
        dsimp [P]  at *
        rw [Int.mod_def]
        generalize (b / a : ℤ) = k 
        rw [p, p']
        simp [mul_addₓ, mul_commₓ, mul_left_commₓ, add_commₓ, add_left_commₓ, sub_eq_neg_add, mul_assocₓ]

-- error in Data.Int.Gcd: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- **Bézout's lemma**: given `x y : ℕ`, `gcd x y = x * a + y * b`, where `a = gcd_a x y` and
`b = gcd_b x y` are computed by the extended Euclidean algorithm.
-/
theorem gcd_eq_gcd_ab : «expr = »((gcd x y : exprℤ()), «expr + »(«expr * »(x, gcd_a x y), «expr * »(y, gcd_b x y))) :=
by have [] [] [":=", expr @xgcd_aux_P x y x y 1 0 0 1 (by simp [] [] [] ["[", expr P, "]"] [] []) (by simp [] [] [] ["[", expr P, "]"] [] [])]; rwa ["[", expr xgcd_aux_val, ",", expr xgcd_val, "]"] ["at", ident this]

end 

-- error in Data.Int.Gcd: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem exists_mul_mod_eq_gcd
{k n : exprℕ()}
(hk : «expr < »(gcd n k, k)) : «expr∃ , »((m), «expr = »(«expr % »(«expr * »(n, m), k), gcd n k)) :=
begin
  have [ident hk'] [] [":=", expr int.coe_nat_ne_zero.mpr (ne_of_gt (lt_of_le_of_lt (zero_le (gcd n k)) hk))],
  have [ident key] [] [":=", expr congr_arg (λ m, int.nat_mod m k) (gcd_eq_gcd_ab n k)],
  simp_rw [expr int.nat_mod] ["at", ident key],
  rw ["[", expr int.add_mul_mod_self_left, ",", "<-", expr int.coe_nat_mod, ",", expr int.to_nat_coe_nat, ",", expr mod_eq_of_lt hk, "]"] ["at", ident key],
  refine [expr ⟨«expr % »(n.gcd_a k, k).to_nat, eq.trans (int.coe_nat_inj _) key.symm⟩],
  rw ["[", expr int.coe_nat_mod, ",", expr int.coe_nat_mul, ",", expr int.to_nat_of_nonneg (int.mod_nonneg _ hk'), ",", expr int.to_nat_of_nonneg (int.mod_nonneg _ hk'), ",", expr int.mul_mod, ",", expr int.mod_mod, ",", "<-", expr int.mul_mod, "]"] []
end

theorem exists_mul_mod_eq_one_of_coprime {k n : ℕ} (hkn : coprime n k) (hk : 1 < k) : ∃ m, (n*m) % k = 1 :=
  Exists.cases_on (exists_mul_mod_eq_gcd (lt_of_le_of_ltₓ (le_of_eqₓ hkn) hk)) fun m hm => ⟨m, hm.trans hkn⟩

end Nat

/-! ### Divisibility over ℤ -/


namespace Int

protected theorem coe_nat_gcd (m n : ℕ) : Int.gcdₓ («expr↑ » m) («expr↑ » n) = Nat.gcdₓ m n :=
  rfl

/-- The extended GCD `a` value in the equation `gcd x y = x * a + y * b`. -/
def gcd_a : ℤ → ℤ → ℤ
| of_nat m, n => m.gcd_a n.nat_abs
| -[1+ m], n => -m.succ.gcd_a n.nat_abs

/-- The extended GCD `b` value in the equation `gcd x y = x * a + y * b`. -/
def gcd_b : ℤ → ℤ → ℤ
| m, of_nat n => m.nat_abs.gcd_b n
| m, -[1+ n] => -m.nat_abs.gcd_b n.succ

/-- **Bézout's lemma** -/
theorem gcd_eq_gcd_ab : ∀ (x y : ℤ), (gcd x y : ℤ) = (x*gcd_a x y)+y*gcd_b x y
| (m : ℕ), (n : ℕ) => Nat.gcd_eq_gcd_ab _ _
| (m : ℕ), -[1+ n] =>
  show (_ : ℤ) = _+(-n+1)*-_ by 
    rw [neg_mul_neg] <;> apply Nat.gcd_eq_gcd_ab
| -[1+ m], (n : ℕ) =>
  show (_ : ℤ) = ((-m+1)*-_)+_ by 
    rw [neg_mul_neg] <;> apply Nat.gcd_eq_gcd_ab
| -[1+ m], -[1+ n] =>
  show (_ : ℤ) = ((-m+1)*-_)+(-n+1)*-_ by 
    rw [neg_mul_neg, neg_mul_neg]
    apply Nat.gcd_eq_gcd_ab

theorem nat_abs_div (a b : ℤ) (H : b ∣ a) : nat_abs (a / b) = nat_abs a / nat_abs b :=
  by 
    cases Nat.eq_zero_or_posₓ (nat_abs b)
    ·
      rw [eq_zero_of_nat_abs_eq_zero h]
      simp [Int.div_zero]
    calc nat_abs (a / b) = nat_abs (a / b)*1 :=
      by 
        rw [mul_oneₓ]_ = nat_abs (a / b)*nat_abs b / nat_abs b :=
      by 
        rw [Nat.div_selfₓ h]_ = (nat_abs (a / b)*nat_abs b) / nat_abs b :=
      by 
        rw [Nat.mul_div_assocₓ _ dvd_rfl]_ = nat_abs ((a / b)*b) / nat_abs b :=
      by 
        rw [nat_abs_mul (a / b) b]_ = nat_abs a / nat_abs b :=
      by 
        rw [Int.div_mul_cancel H]

-- error in Data.Int.Gcd: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem nat_abs_dvd_abs_iff {i j : exprℤ()} : «expr ↔ »(«expr ∣ »(i.nat_abs, j.nat_abs), «expr ∣ »(i, j)) :=
⟨assume
 H : «expr ∣ »(i.nat_abs, j.nat_abs), dvd_nat_abs.mp (nat_abs_dvd.mp (coe_nat_dvd.mpr H)), assume
 H : «expr ∣ »(i, j), coe_nat_dvd.mp (dvd_nat_abs.mpr (nat_abs_dvd.mpr H))⟩

theorem succ_dvd_or_succ_dvd_of_succ_sum_dvd_mul {p : ℕ} (p_prime : Nat.Prime p) {m n : ℤ} {k l : ℕ}
  (hpm : «expr↑ » (p ^ k) ∣ m) (hpn : «expr↑ » (p ^ l) ∣ n) (hpmn : «expr↑ » (p ^ (k+l)+1) ∣ m*n) :
  «expr↑ » (p ^ k+1) ∣ m ∨ «expr↑ » (p ^ l+1) ∣ n :=
  have hpm' : p ^ k ∣ m.nat_abs := Int.coe_nat_dvd.1$ Int.dvd_nat_abs.2 hpm 
  have hpn' : p ^ l ∣ n.nat_abs := Int.coe_nat_dvd.1$ Int.dvd_nat_abs.2 hpn 
  have hpmn' : (p ^ (k+l)+1) ∣ m.nat_abs*n.nat_abs :=
    by 
      rw [←Int.nat_abs_mul] <;> apply Int.coe_nat_dvd.1$ Int.dvd_nat_abs.2 hpmn 
  let hsd := Nat.succ_dvd_or_succ_dvd_of_succ_sum_dvd_mul p_prime hpm' hpn' hpmn' 
  hsd.elim
    (fun hsd1 =>
      Or.inl
        (by 
          apply Int.dvd_nat_abs.1
          apply Int.coe_nat_dvd.2 hsd1))
    fun hsd2 =>
      Or.inr
        (by 
          apply Int.dvd_nat_abs.1
          apply Int.coe_nat_dvd.2 hsd2)

theorem dvd_of_mul_dvd_mul_left {i j k : ℤ} (k_non_zero : k ≠ 0) (H : (k*i) ∣ k*j) : i ∣ j :=
  Dvd.elim H
    fun l H1 =>
      by 
        rw [mul_assocₓ] at H1 <;> exact ⟨_, mul_left_cancel₀ k_non_zero H1⟩

theorem dvd_of_mul_dvd_mul_right {i j k : ℤ} (k_non_zero : k ≠ 0) (H : (i*k) ∣ j*k) : i ∣ j :=
  by 
    rw [mul_commₓ i k, mul_commₓ j k] at H <;> exact dvd_of_mul_dvd_mul_left k_non_zero H

theorem prime.dvd_nat_abs_of_coe_dvd_sq {p : ℕ} (hp : p.prime) (k : ℤ) (h : «expr↑ » p ∣ k ^ 2) : p ∣ k.nat_abs :=
  by 
    apply @Nat.Prime.dvd_of_dvd_pow _ _ 2 hp 
    rwa [sq, ←nat_abs_mul, ←coe_nat_dvd_left, ←sq]

/-- ℤ specific version of least common multiple. -/
def lcm (i j : ℤ) : ℕ :=
  Nat.lcmₓ (nat_abs i) (nat_abs j)

theorem lcm_def (i j : ℤ) : lcm i j = Nat.lcmₓ (nat_abs i) (nat_abs j) :=
  rfl

protected theorem coe_nat_lcm (m n : ℕ) : Int.lcm («expr↑ » m) («expr↑ » n) = Nat.lcmₓ m n :=
  rfl

theorem gcd_dvd_left (i j : ℤ) : (gcd i j : ℤ) ∣ i :=
  dvd_nat_abs.mp$ coe_nat_dvd.mpr$ Nat.gcd_dvd_leftₓ _ _

theorem gcd_dvd_right (i j : ℤ) : (gcd i j : ℤ) ∣ j :=
  dvd_nat_abs.mp$ coe_nat_dvd.mpr$ Nat.gcd_dvd_rightₓ _ _

theorem dvd_gcd {i j k : ℤ} (h1 : k ∣ i) (h2 : k ∣ j) : k ∣ gcd i j :=
  nat_abs_dvd.1$ coe_nat_dvd.2$ Nat.dvd_gcdₓ (nat_abs_dvd_abs_iff.2 h1) (nat_abs_dvd_abs_iff.2 h2)

theorem gcd_mul_lcm (i j : ℤ) : (gcd i j*lcm i j) = nat_abs (i*j) :=
  by 
    rw [Int.gcdₓ, Int.lcm, Nat.gcd_mul_lcmₓ, nat_abs_mul]

theorem gcd_comm (i j : ℤ) : gcd i j = gcd j i :=
  Nat.gcd_commₓ _ _

theorem gcd_assoc (i j k : ℤ) : gcd (gcd i j) k = gcd i (gcd j k) :=
  Nat.gcd_assocₓ _ _ _

@[simp]
theorem gcd_self (i : ℤ) : gcd i i = nat_abs i :=
  by 
    simp [gcd]

@[simp]
theorem gcd_zero_left (i : ℤ) : gcd 0 i = nat_abs i :=
  by 
    simp [gcd]

@[simp]
theorem gcd_zero_right (i : ℤ) : gcd i 0 = nat_abs i :=
  by 
    simp [gcd]

@[simp]
theorem gcd_one_left (i : ℤ) : gcd 1 i = 1 :=
  Nat.gcd_one_leftₓ _

@[simp]
theorem gcd_one_right (i : ℤ) : gcd i 1 = 1 :=
  Nat.gcd_one_rightₓ _

theorem gcd_mul_left (i j k : ℤ) : gcd (i*j) (i*k) = nat_abs i*gcd j k :=
  by 
    rw [Int.gcdₓ, Int.gcdₓ, nat_abs_mul, nat_abs_mul]
    apply Nat.gcd_mul_leftₓ

theorem gcd_mul_right (i j k : ℤ) : gcd (i*j) (k*j) = gcd i k*nat_abs j :=
  by 
    rw [Int.gcdₓ, Int.gcdₓ, nat_abs_mul, nat_abs_mul]
    apply Nat.gcd_mul_rightₓ

theorem gcd_pos_of_non_zero_left {i : ℤ} (j : ℤ) (i_non_zero : i ≠ 0) : 0 < gcd i j :=
  Nat.gcd_pos_of_pos_leftₓ (nat_abs j) (nat_abs_pos_of_ne_zero i_non_zero)

theorem gcd_pos_of_non_zero_right (i : ℤ) {j : ℤ} (j_non_zero : j ≠ 0) : 0 < gcd i j :=
  Nat.gcd_pos_of_pos_rightₓ (nat_abs i) (nat_abs_pos_of_ne_zero j_non_zero)

theorem gcd_eq_zero_iff {i j : ℤ} : gcd i j = 0 ↔ i = 0 ∧ j = 0 :=
  by 
    rw [Int.gcdₓ]
    split 
    ·
      intro h 
      exact
        ⟨nat_abs_eq_zero.mp (Nat.eq_zero_of_gcd_eq_zero_leftₓ h),
          nat_abs_eq_zero.mp (Nat.eq_zero_of_gcd_eq_zero_rightₓ h)⟩
    ·
      intro h 
      rw [nat_abs_eq_zero.mpr h.left, nat_abs_eq_zero.mpr h.right]
      apply Nat.gcd_zero_leftₓ

theorem gcd_div {i j k : ℤ} (H1 : k ∣ i) (H2 : k ∣ j) : gcd (i / k) (j / k) = gcd i j / nat_abs k :=
  by 
    rw [gcd, nat_abs_div i k H1, nat_abs_div j k H2] <;>
      exact Nat.gcd_divₓ (nat_abs_dvd_abs_iff.mpr H1) (nat_abs_dvd_abs_iff.mpr H2)

theorem gcd_div_gcd_div_gcd {i j : ℤ} (H : 0 < gcd i j) : gcd (i / gcd i j) (j / gcd i j) = 1 :=
  by 
    rw [gcd_div (gcd_dvd_left i j) (gcd_dvd_right i j)]
    rw [nat_abs_of_nat, Nat.div_selfₓ H]

theorem gcd_dvd_gcd_of_dvd_left {i k : ℤ} (j : ℤ) (H : i ∣ k) : gcd i j ∣ gcd k j :=
  Int.coe_nat_dvd.1$ dvd_gcd ((gcd_dvd_left i j).trans H) (gcd_dvd_right i j)

theorem gcd_dvd_gcd_of_dvd_right {i k : ℤ} (j : ℤ) (H : i ∣ k) : gcd j i ∣ gcd j k :=
  Int.coe_nat_dvd.1$ dvd_gcd (gcd_dvd_left j i) ((gcd_dvd_right j i).trans H)

theorem gcd_dvd_gcd_mul_left (i j k : ℤ) : gcd i j ∣ gcd (k*i) j :=
  gcd_dvd_gcd_of_dvd_left _ (dvd_mul_left _ _)

theorem gcd_dvd_gcd_mul_right (i j k : ℤ) : gcd i j ∣ gcd (i*k) j :=
  gcd_dvd_gcd_of_dvd_left _ (dvd_mul_right _ _)

theorem gcd_dvd_gcd_mul_left_right (i j k : ℤ) : gcd i j ∣ gcd i (k*j) :=
  gcd_dvd_gcd_of_dvd_right _ (dvd_mul_left _ _)

theorem gcd_dvd_gcd_mul_right_right (i j k : ℤ) : gcd i j ∣ gcd i (j*k) :=
  gcd_dvd_gcd_of_dvd_right _ (dvd_mul_right _ _)

theorem gcd_eq_left {i j : ℤ} (H : i ∣ j) : gcd i j = nat_abs i :=
  Nat.dvd_antisymm
    (by 
      unfold gcd <;> exact Nat.gcd_dvd_leftₓ _ _)
    (by 
      unfold gcd <;> exact Nat.dvd_gcdₓ dvd_rfl (nat_abs_dvd_abs_iff.mpr H))

theorem gcd_eq_right {i j : ℤ} (H : j ∣ i) : gcd i j = nat_abs j :=
  by 
    rw [gcd_comm, gcd_eq_left H]

theorem ne_zero_of_gcd {x y : ℤ} (hc : gcd x y ≠ 0) : x ≠ 0 ∨ y ≠ 0 :=
  by 
    contrapose! hc 
    rw [hc.left, hc.right, gcd_zero_right, nat_abs_zero]

theorem exists_gcd_one {m n : ℤ} (H : 0 < gcd m n) : ∃ m' n' : ℤ, gcd m' n' = 1 ∧ (m = m'*gcd m n) ∧ n = n'*gcd m n :=
  ⟨_, _, gcd_div_gcd_div_gcd H, (Int.div_mul_cancel (gcd_dvd_left m n)).symm,
    (Int.div_mul_cancel (gcd_dvd_right m n)).symm⟩

theorem exists_gcd_one' {m n : ℤ} (H : 0 < gcd m n) :
  ∃ (g : ℕ)(m' n' : ℤ), 0 < g ∧ gcd m' n' = 1 ∧ (m = m'*g) ∧ n = n'*g :=
  let ⟨m', n', h⟩ := exists_gcd_one H
  ⟨_, m', n', H, h⟩

theorem pow_dvd_pow_iff {m n : ℤ} {k : ℕ} (k0 : 0 < k) : m ^ k ∣ n ^ k ↔ m ∣ n :=
  by 
    refine' ⟨fun h => _, fun h => pow_dvd_pow_of_dvd h _⟩
    apply int.nat_abs_dvd_abs_iff.mp 
    apply (Nat.pow_dvd_pow_iff k0).mp 
    rw [←Int.nat_abs_pow, ←Int.nat_abs_pow]
    exact int.nat_abs_dvd_abs_iff.mpr h

/-! ### lcm -/


theorem lcm_comm (i j : ℤ) : lcm i j = lcm j i :=
  by 
    rw [Int.lcm, Int.lcm]
    exact Nat.lcm_commₓ _ _

theorem lcm_assoc (i j k : ℤ) : lcm (lcm i j) k = lcm i (lcm j k) :=
  by 
    rw [Int.lcm, Int.lcm, Int.lcm, Int.lcm, nat_abs_of_nat, nat_abs_of_nat]
    apply Nat.lcm_assocₓ

@[simp]
theorem lcm_zero_left (i : ℤ) : lcm 0 i = 0 :=
  by 
    rw [Int.lcm]
    apply Nat.lcm_zero_leftₓ

@[simp]
theorem lcm_zero_right (i : ℤ) : lcm i 0 = 0 :=
  by 
    rw [Int.lcm]
    apply Nat.lcm_zero_rightₓ

@[simp]
theorem lcm_one_left (i : ℤ) : lcm 1 i = nat_abs i :=
  by 
    rw [Int.lcm]
    apply Nat.lcm_one_leftₓ

@[simp]
theorem lcm_one_right (i : ℤ) : lcm i 1 = nat_abs i :=
  by 
    rw [Int.lcm]
    apply Nat.lcm_one_rightₓ

@[simp]
theorem lcm_self (i : ℤ) : lcm i i = nat_abs i :=
  by 
    rw [Int.lcm]
    apply Nat.lcm_selfₓ

theorem dvd_lcm_left (i j : ℤ) : i ∣ lcm i j :=
  by 
    rw [Int.lcm]
    apply coe_nat_dvd_right.mpr 
    apply Nat.dvd_lcm_leftₓ

theorem dvd_lcm_right (i j : ℤ) : j ∣ lcm i j :=
  by 
    rw [Int.lcm]
    apply coe_nat_dvd_right.mpr 
    apply Nat.dvd_lcm_rightₓ

theorem lcm_dvd {i j k : ℤ} : i ∣ k → j ∣ k → (lcm i j : ℤ) ∣ k :=
  by 
    rw [Int.lcm]
    intro hi hj 
    exact coe_nat_dvd_left.mpr (Nat.lcm_dvdₓ (nat_abs_dvd_abs_iff.mpr hi) (nat_abs_dvd_abs_iff.mpr hj))

end Int

theorem pow_gcd_eq_one {M : Type _} [Monoidₓ M] (x : M) {m n : ℕ} (hm : x ^ m = 1) (hn : x ^ n = 1) : x ^ m.gcd n = 1 :=
  by 
    cases m
    ·
      simp only [hn, Nat.gcd_zero_leftₓ]
    obtain ⟨x, rfl⟩ : IsUnit x
    ·
      apply is_unit_of_pow_eq_one _ _ hm m.succ_pos 
    simp only [←Units.coe_pow] at *
    rw [←Units.coe_one, ←zpow_coe_nat, ←Units.ext_iff] at *
    simp only [Nat.gcd_eq_gcd_ab, zpow_add, zpow_mul, hm, hn, one_zpow, one_mulₓ]

theorem gcd_nsmul_eq_zero {M : Type _} [AddMonoidₓ M] (x : M) {m n : ℕ} (hm : m • x = 0) (hn : n • x = 0) :
  m.gcd n • x = 0 :=
  by 
    apply multiplicative.of_add.injective 
    rw [of_add_nsmul, of_add_zero, pow_gcd_eq_one] <;> rwa [←of_add_nsmul, ←of_add_zero, Equiv.apply_eq_iff_eq]

attribute [toAdditive gcd_nsmul_eq_zero] pow_gcd_eq_one

/-! ### GCD prover -/


open NormNum

namespace Tactic

namespace NormNum

theorem int_gcd_helper' {d : ℕ} {x y a b : ℤ} (h₁ : (d : ℤ) ∣ x) (h₂ : (d : ℤ) ∣ y) (h₃ : ((x*a)+y*b) = d) :
  Int.gcdₓ x y = d :=
  by 
    refine' Nat.dvd_antisymm _ (Int.coe_nat_dvd.1 (Int.dvd_gcd h₁ h₂))
    rw [←Int.coe_nat_dvd, ←h₃]
    apply dvd_add
    ·
      exact (Int.gcd_dvd_left _ _).mul_right _
    ·
      exact (Int.gcd_dvd_right _ _).mul_right _

theorem nat_gcd_helper_dvd_left (x y a : ℕ) (h : (x*a) = y) : Nat.gcdₓ x y = x :=
  Nat.gcd_eq_leftₓ ⟨a, h.symm⟩

theorem nat_gcd_helper_dvd_right (x y a : ℕ) (h : (y*a) = x) : Nat.gcdₓ x y = y :=
  Nat.gcd_eq_rightₓ ⟨a, h.symm⟩

theorem nat_gcd_helper_2 (d x y a b u v tx ty : ℕ) (hu : (d*u) = x) (hv : (d*v) = y) (hx : (x*a) = tx) (hy : (y*b) = ty)
  (h : (ty+d) = tx) : Nat.gcdₓ x y = d :=
  by 
    rw [←Int.coe_nat_gcd]
    apply @int_gcd_helper' _ _ _ a (-b) (Int.coe_nat_dvd.2 ⟨_, hu.symm⟩) (Int.coe_nat_dvd.2 ⟨_, hv.symm⟩)
    rw [mul_neg_eq_neg_mul_symm, ←sub_eq_add_neg, sub_eq_iff_eq_add']
    normCast 
    rw [hx, hy, h]

theorem nat_gcd_helper_1 (d x y a b u v tx ty : ℕ) (hu : (d*u) = x) (hv : (d*v) = y) (hx : (x*a) = tx) (hy : (y*b) = ty)
  (h : (tx+d) = ty) : Nat.gcdₓ x y = d :=
  (Nat.gcd_commₓ _ _).trans$ nat_gcd_helper_2 _ _ _ _ _ _ _ _ _ hv hu hy hx h

theorem nat_lcm_helper (x y d m n : ℕ) (hd : Nat.gcdₓ x y = d) (d0 : 0 < d) (xy : (x*y) = n) (dm : (d*m) = n) :
  Nat.lcmₓ x y = m :=
  (Nat.mul_right_inj d0).1$
    by 
      rw [dm, ←xy, ←hd, Nat.gcd_mul_lcmₓ]

theorem nat_coprime_helper_zero_left (x : ℕ) (h : 1 < x) : ¬Nat.Coprime 0 x :=
  mt (Nat.coprime_zero_leftₓ _).1$ ne_of_gtₓ h

theorem nat_coprime_helper_zero_right (x : ℕ) (h : 1 < x) : ¬Nat.Coprime x 0 :=
  mt (Nat.coprime_zero_rightₓ _).1$ ne_of_gtₓ h

theorem nat_coprime_helper_1 (x y a b tx ty : ℕ) (hx : (x*a) = tx) (hy : (y*b) = ty) (h : (tx+1) = ty) :
  Nat.Coprime x y :=
  nat_gcd_helper_1 _ _ _ _ _ _ _ _ _ (one_mulₓ _) (one_mulₓ _) hx hy h

theorem nat_coprime_helper_2 (x y a b tx ty : ℕ) (hx : (x*a) = tx) (hy : (y*b) = ty) (h : (ty+1) = tx) :
  Nat.Coprime x y :=
  nat_gcd_helper_2 _ _ _ _ _ _ _ _ _ (one_mulₓ _) (one_mulₓ _) hx hy h

theorem nat_not_coprime_helper (d x y u v : ℕ) (hu : (d*u) = x) (hv : (d*v) = y) (h : 1 < d) : ¬Nat.Coprime x y :=
  Nat.not_coprime_of_dvd_of_dvdₓ h ⟨_, hu.symm⟩ ⟨_, hv.symm⟩

theorem int_gcd_helper (x y : ℤ) (nx ny d : ℕ) (hx : (nx : ℤ) = x) (hy : (ny : ℤ) = y) (h : Nat.gcdₓ nx ny = d) :
  Int.gcdₓ x y = d :=
  by 
    rwa [←hx, ←hy, Int.coe_nat_gcd]

theorem int_gcd_helper_neg_left (x y : ℤ) (d : ℕ) (h : Int.gcdₓ x y = d) : Int.gcdₓ (-x) y = d :=
  by 
    rw [Int.gcdₓ] at h⊢ <;> rwa [Int.nat_abs_neg]

theorem int_gcd_helper_neg_right (x y : ℤ) (d : ℕ) (h : Int.gcdₓ x y = d) : Int.gcdₓ x (-y) = d :=
  by 
    rw [Int.gcdₓ] at h⊢ <;> rwa [Int.nat_abs_neg]

theorem int_lcm_helper (x y : ℤ) (nx ny d : ℕ) (hx : (nx : ℤ) = x) (hy : (ny : ℤ) = y) (h : Nat.lcmₓ nx ny = d) :
  Int.lcm x y = d :=
  by 
    rwa [←hx, ←hy, Int.coe_nat_lcm]

theorem int_lcm_helper_neg_left (x y : ℤ) (d : ℕ) (h : Int.lcm x y = d) : Int.lcm (-x) y = d :=
  by 
    rw [Int.lcm] at h⊢ <;> rwa [Int.nat_abs_neg]

theorem int_lcm_helper_neg_right (x y : ℤ) (d : ℕ) (h : Int.lcm x y = d) : Int.lcm x (-y) = d :=
  by 
    rw [Int.lcm] at h⊢ <;> rwa [Int.nat_abs_neg]

/-- Evaluates the `nat.gcd` function. -/
unsafe def prove_gcd_nat (c : instance_cache) (ex ey : expr) : tactic (instance_cache × expr × expr) :=
  do 
    let x ← ex.to_nat 
    let y ← ey.to_nat 
    match x, y with 
      | 0, _ => pure (c, ey, (quote.1 Nat.gcd_zero_leftₓ).mk_app [ey])
      | _, 0 => pure (c, ex, (quote.1 Nat.gcd_zero_rightₓ).mk_app [ex])
      | 1, _ => pure (c, quote.1 (1 : ℕ), (quote.1 Nat.gcd_one_leftₓ).mk_app [ey])
      | _, 1 => pure (c, quote.1 (1 : ℕ), (quote.1 Nat.gcd_one_rightₓ).mk_app [ex])
      | _, _ =>
        do 
          let (d, a, b) := Nat.xgcdAux x 1 0 y 0 1
          if d = x then
              do 
                let (c, ea) ← c.of_nat (y / x)
                let (c, _, p) ← prove_mul_nat c ex ea 
                pure (c, ex, (quote.1 nat_gcd_helper_dvd_left).mk_app [ex, ey, ea, p])
            else
              if d = y then
                do 
                  let (c, ea) ← c.of_nat (x / y)
                  let (c, _, p) ← prove_mul_nat c ey ea 
                  pure (c, ey, (quote.1 nat_gcd_helper_dvd_right).mk_app [ex, ey, ea, p])
              else
                do 
                  let (c, ed) ← c.of_nat d 
                  let (c, ea) ← c.of_nat a.nat_abs 
                  let (c, eb) ← c.of_nat b.nat_abs 
                  let (c, eu) ← c.of_nat (x / d)
                  let (c, ev) ← c.of_nat (y / d)
                  let (c, _, pu) ← prove_mul_nat c ed eu 
                  let (c, _, pv) ← prove_mul_nat c ed ev 
                  let (c, etx, px) ← prove_mul_nat c ex ea 
                  let (c, ety, py) ← prove_mul_nat c ey eb 
                  let (c, p) ← if a ≥ 0 then prove_add_nat c ety ed etx else prove_add_nat c etx ed ety 
                  let pf : expr := if a ≥ 0 then quote.1 nat_gcd_helper_2 else quote.1 nat_gcd_helper_1 
                  pure (c, ed, pf.mk_app [ed, ex, ey, ea, eb, eu, ev, etx, ety, pu, pv, px, py, p])

/-- Evaluates the `nat.lcm` function. -/
unsafe def prove_lcm_nat (c : instance_cache) (ex ey : expr) : tactic (instance_cache × expr × expr) :=
  do 
    let x ← ex.to_nat 
    let y ← ey.to_nat 
    match x, y with 
      | 0, _ => pure (c, quote.1 (0 : ℕ), (quote.1 Nat.lcm_zero_leftₓ).mk_app [ey])
      | _, 0 => pure (c, quote.1 (0 : ℕ), (quote.1 Nat.lcm_zero_rightₓ).mk_app [ex])
      | 1, _ => pure (c, ey, (quote.1 Nat.lcm_one_leftₓ).mk_app [ey])
      | _, 1 => pure (c, ex, (quote.1 Nat.lcm_one_rightₓ).mk_app [ex])
      | _, _ =>
        do 
          let (c, ed, pd) ← prove_gcd_nat c ex ey 
          let (c, p0) ← prove_pos c ed 
          let (c, en, xy) ← prove_mul_nat c ex ey 
          let d ← ed.to_nat 
          let (c, em) ← c.of_nat ((x*y) / d)
          let (c, _, dm) ← prove_mul_nat c ed em 
          pure (c, em, (quote.1 nat_lcm_helper).mk_app [ex, ey, ed, em, en, pd, p0, xy, dm])

/-- Evaluates the `int.gcd` function. -/
unsafe def prove_gcd_int (zc nc : instance_cache) : expr → expr → tactic (instance_cache × instance_cache × expr × expr)
| x, y =>
  match match_neg x with 
  | some x =>
    do 
      let (zc, nc, d, p) ← prove_gcd_int x y 
      pure (zc, nc, d, (quote.1 int_gcd_helper_neg_left).mk_app [x, y, d, p])
  | none =>
    match match_neg y with 
    | some y =>
      do 
        let (zc, nc, d, p) ← prove_gcd_int x y 
        pure (zc, nc, d, (quote.1 int_gcd_helper_neg_right).mk_app [x, y, d, p])
    | none =>
      do 
        let (zc, nc, nx, px) ← prove_nat_uncast zc nc x 
        let (zc, nc, ny, py) ← prove_nat_uncast zc nc y 
        let (nc, d, p) ← prove_gcd_nat nc nx ny 
        pure (zc, nc, d, (quote.1 int_gcd_helper).mk_app [x, y, nx, ny, d, px, py, p])

/-- Evaluates the `int.lcm` function. -/
unsafe def prove_lcm_int (zc nc : instance_cache) : expr → expr → tactic (instance_cache × instance_cache × expr × expr)
| x, y =>
  match match_neg x with 
  | some x =>
    do 
      let (zc, nc, d, p) ← prove_lcm_int x y 
      pure (zc, nc, d, (quote.1 int_lcm_helper_neg_left).mk_app [x, y, d, p])
  | none =>
    match match_neg y with 
    | some y =>
      do 
        let (zc, nc, d, p) ← prove_lcm_int x y 
        pure (zc, nc, d, (quote.1 int_lcm_helper_neg_right).mk_app [x, y, d, p])
    | none =>
      do 
        let (zc, nc, nx, px) ← prove_nat_uncast zc nc x 
        let (zc, nc, ny, py) ← prove_nat_uncast zc nc y 
        let (nc, d, p) ← prove_lcm_nat nc nx ny 
        pure (zc, nc, d, (quote.1 int_lcm_helper).mk_app [x, y, nx, ny, d, px, py, p])

/-- Evaluates the `nat.coprime` function. -/
unsafe def prove_coprime_nat (c : instance_cache) (ex ey : expr) : tactic (instance_cache × Sum expr expr) :=
  do 
    let x ← ex.to_nat 
    let y ← ey.to_nat 
    match x, y with 
      | 1, _ => pure (c, Sum.inl$ (quote.1 Nat.coprime_one_leftₓ).mk_app [ey])
      | _, 1 => pure (c, Sum.inl$ (quote.1 Nat.coprime_one_rightₓ).mk_app [ex])
      | 0, 0 => pure (c, Sum.inr (quote.1 Nat.not_coprime_zero_zero))
      | 0, _ =>
        do 
          let c ← mk_instance_cache (quote.1 ℕ)
          let (c, p) ← prove_lt_nat c (quote.1 1) ey 
          pure (c, Sum.inr$ (quote.1 nat_coprime_helper_zero_left).mk_app [ey, p])
      | _, 0 =>
        do 
          let c ← mk_instance_cache (quote.1 ℕ)
          let (c, p) ← prove_lt_nat c (quote.1 1) ex 
          pure (c, Sum.inr$ (quote.1 nat_coprime_helper_zero_right).mk_app [ex, p])
      | _, _ =>
        do 
          let c ← mk_instance_cache (quote.1 ℕ)
          let (d, a, b) := Nat.xgcdAux x 1 0 y 0 1
          if d = 1 then
              do 
                let (c, ea) ← c.of_nat a.nat_abs 
                let (c, eb) ← c.of_nat b.nat_abs 
                let (c, etx, px) ← prove_mul_nat c ex ea 
                let (c, ety, py) ← prove_mul_nat c ey eb 
                let (c, p) ← if a ≥ 0 then prove_add_nat c ety (quote.1 1) etx else prove_add_nat c etx (quote.1 1) ety 
                let pf : expr := if a ≥ 0 then quote.1 nat_coprime_helper_2 else quote.1 nat_coprime_helper_1 
                pure (c, Sum.inl$ pf.mk_app [ex, ey, ea, eb, etx, ety, px, py, p])
            else
              do 
                let (c, ed) ← c.of_nat d 
                let (c, eu) ← c.of_nat (x / d)
                let (c, ev) ← c.of_nat (y / d)
                let (c, _, pu) ← prove_mul_nat c ed eu 
                let (c, _, pv) ← prove_mul_nat c ed ev 
                let (c, p) ← prove_lt_nat c (quote.1 1) ed 
                pure (c, Sum.inr$ (quote.1 nat_not_coprime_helper).mk_app [ed, ex, ey, eu, ev, pu, pv, p])

/-- Evaluates the `gcd`, `lcm`, and `coprime` functions. -/
@[normNum]
unsafe def eval_gcd : expr → tactic (expr × expr)
| quote.1 (Nat.gcdₓ (%%ₓex) (%%ₓey)) =>
  do 
    let c ← mk_instance_cache (quote.1 ℕ)
    Prod.snd <$> prove_gcd_nat c ex ey
| quote.1 (Nat.lcmₓ (%%ₓex) (%%ₓey)) =>
  do 
    let c ← mk_instance_cache (quote.1 ℕ)
    Prod.snd <$> prove_lcm_nat c ex ey
| quote.1 (Nat.Coprime (%%ₓex) (%%ₓey)) =>
  do 
    let c ← mk_instance_cache (quote.1 ℕ)
    prove_coprime_nat c ex ey >>= Sum.elim true_intro false_intro ∘ Prod.snd
| quote.1 (Int.gcdₓ (%%ₓex) (%%ₓey)) =>
  do 
    let zc ← mk_instance_cache (quote.1 ℤ)
    let nc ← mk_instance_cache (quote.1 ℕ)
    (Prod.snd ∘ Prod.snd) <$> prove_gcd_int zc nc ex ey
| quote.1 (Int.lcm (%%ₓex) (%%ₓey)) =>
  do 
    let zc ← mk_instance_cache (quote.1 ℤ)
    let nc ← mk_instance_cache (quote.1 ℕ)
    (Prod.snd ∘ Prod.snd) <$> prove_lcm_int zc nc ex ey
| _ => failed

end NormNum

end Tactic

