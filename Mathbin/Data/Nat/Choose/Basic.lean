import Mathbin.Data.Nat.Factorial.Basic

/-!
# Binomial coefficients

This file defines binomial coefficients and proves simple lemmas (i.e. those not
requiring more imports).

## Main definition and results

* `nat.choose`: binomial coefficients, defined inductively
* `nat.choose_eq_factorial_div_factorial`: a proof that `choose n k = n! / (k! * (n - k)!)`
* `nat.choose_symm`: symmetry of binomial coefficients
* `nat.choose_le_succ_of_lt_half_left`: `choose n k` is increasing for small values of `k`
* `nat.choose_le_middle`: `choose n r` is maximised when `r` is `n/2`
* `nat.desc_factorial_eq_factorial_mul_choose`: Relates binomial coefficients to the descending
  factorial. This is used to prove `nat.choose_le_pow` and variants. We provide similar statements
  for the ascending factorial.

-/


open_locale Nat

namespace Nat

/-- `choose n k` is the number of `k`-element subsets in an `n`-element set. Also known as binomial
coefficients. -/
def choose : ℕ → ℕ → ℕ
| _, 0 => 1
| 0, k+1 => 0
| n+1, k+1 => choose n k+choose n (k+1)

@[simp]
theorem choose_zero_right (n : ℕ) : choose n 0 = 1 :=
  by 
    cases n <;> rfl

@[simp]
theorem choose_zero_succ (k : ℕ) : choose 0 (succ k) = 0 :=
  rfl

theorem choose_succ_succ (n k : ℕ) : choose (succ n) (succ k) = choose n k+choose n (succ k) :=
  rfl

theorem choose_eq_zero_of_lt : ∀ {n k}, n < k → choose n k = 0
| _, 0, hk =>
  absurd hk
    (by 
      decide)
| 0, k+1, hk => choose_zero_succ _
| n+1, k+1, hk =>
  have hnk : n < k := lt_of_succ_lt_succ hk 
  have hnk1 : n < k+1 := lt_of_succ_lt hk 
  by 
    rw [choose_succ_succ, choose_eq_zero_of_lt hnk, choose_eq_zero_of_lt hnk1]

@[simp]
theorem choose_self (n : ℕ) : choose n n = 1 :=
  by 
    induction n <;> simp [choose, choose_eq_zero_of_lt (lt_succ_self _)]

@[simp]
theorem choose_succ_self (n : ℕ) : choose n (succ n) = 0 :=
  choose_eq_zero_of_lt (lt_succ_self _)

@[simp]
theorem choose_one_right (n : ℕ) : choose n 1 = n :=
  by 
    induction n <;> simp [choose, add_commₓ]

theorem triangle_succ (n : ℕ) : ((n+1)*(n+1) - 1) / 2 = ((n*n - 1) / 2)+n :=
  by 
    rw [←add_mul_div_left, mul_commₓ 2 n, ←mul_addₓ, add_tsub_cancel_right, mul_commₓ]
    cases n <;> rfl 
    apply zero_lt_succ

/-- `choose n 2` is the `n`-th triangle number. -/
theorem choose_two_right (n : ℕ) : choose n 2 = (n*n - 1) / 2 :=
  by 
    induction' n with n ih 
    simp 
    ·
      rw [triangle_succ n]
      simp [choose, ih]
      rw [add_commₓ]

theorem choose_pos : ∀ {n k}, k ≤ n → 0 < choose n k
| 0, _, hk =>
  by 
    rw [Nat.eq_zero_of_le_zeroₓ hk] <;>
      exact
        by 
          decide
| n+1, 0, hk =>
  by 
    simp  <;>
      exact
        by 
          decide
| n+1, k+1, hk =>
  by 
    rw [choose_succ_succ] <;> exact add_pos_of_pos_of_nonneg (choose_pos (le_of_succ_le_succ hk)) (Nat.zero_leₓ _)

theorem succ_mul_choose_eq : ∀ n k, (succ n*choose n k) = choose (succ n) (succ k)*succ k
| 0, 0 =>
  by 
    decide
| 0, k+1 =>
  by 
    simp [choose]
| n+1, 0 =>
  by 
    simp 
| n+1, k+1 =>
  by 
    rw [choose_succ_succ (succ n) (succ k), add_mulₓ, ←succ_mul_choose_eq, mul_succ, ←succ_mul_choose_eq,
      add_right_commₓ, ←mul_addₓ, ←choose_succ_succ, ←succ_mul]

-- error in Data.Nat.Choose.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem choose_mul_factorial_mul_factorial : ∀
{n
 k}, «expr ≤ »(k, n) → «expr = »(«expr * »(«expr * »(choose n k, «expr !»(k)), «expr !»(«expr - »(n, k))), «expr !»(n))
| 0, _, hk := by simp [] [] [] ["[", expr nat.eq_zero_of_le_zero hk, "]"] [] []
| «expr + »(n, 1), 0, hk := by simp [] [] [] [] [] []
| «expr + »(n, 1), succ k, hk := begin
  cases [expr lt_or_eq_of_le hk] ["with", ident hk₁, ident hk₁],
  { have [ident h] [":", expr «expr = »(«expr * »(«expr * »(choose n k, «expr !»(k.succ)), «expr !»(«expr - »(n, k))), «expr * »(«expr + »(k, 1), «expr !»(n)))] [":=", expr by rw ["<-", expr choose_mul_factorial_mul_factorial (le_of_succ_le_succ hk)] []; simp [] [] [] ["[", expr factorial_succ, ",", expr mul_comm, ",", expr mul_left_comm, "]"] [] []],
    have [ident h₁] [":", expr «expr = »(«expr !»(«expr - »(n, k)), «expr * »(«expr - »(n, k), «expr !»(«expr - »(n, k.succ))))] [":=", expr by rw ["[", "<-", expr succ_sub_succ, ",", expr succ_sub (le_of_lt_succ hk₁), ",", expr factorial_succ, "]"] []],
    have [ident h₂] [":", expr «expr = »(«expr * »(«expr * »(choose n (succ k), «expr !»(k.succ)), «expr * »(«expr - »(n, k), «expr !»(«expr - »(n, k.succ)))), «expr * »(«expr - »(n, k), «expr !»(n)))] [":=", expr by rw ["<-", expr choose_mul_factorial_mul_factorial (le_of_lt_succ hk₁)] []; simp [] [] [] ["[", expr factorial_succ, ",", expr mul_comm, ",", expr mul_left_comm, ",", expr mul_assoc, "]"] [] []],
    have [ident h₃] [":", expr «expr ≤ »(«expr * »(k, «expr !»(n)), «expr * »(n, «expr !»(n)))] [":=", expr nat.mul_le_mul_right _ (le_of_succ_le_succ hk)],
    rw ["[", expr choose_succ_succ, ",", expr add_mul, ",", expr add_mul, ",", expr succ_sub_succ, ",", expr h, ",", expr h₁, ",", expr h₂, ",", expr add_mul, ",", expr tsub_mul, ",", expr factorial_succ, ",", "<-", expr add_tsub_assoc_of_le h₃, ",", expr add_assoc, ",", "<-", expr add_mul, ",", expr add_tsub_cancel_left, ",", expr add_comm, "]"] [] },
  { simp [] [] [] ["[", expr hk₁, ",", expr mul_comm, ",", expr choose, ",", expr tsub_self, "]"] [] [] }
end

-- error in Data.Nat.Choose.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem choose_mul
{n k s : exprℕ()}
(hkn : «expr ≤ »(k, n))
(hsk : «expr ≤ »(s, k)) : «expr = »(«expr * »(n.choose k, k.choose s), «expr * »(n.choose s, «expr - »(n, s).choose «expr - »(k, s))) :=
begin
  have [ident h] [":", expr «expr < »(0, «expr * »(«expr * »(«expr !»(«expr - »(n, k)), «expr !»(«expr - »(k, s))), «expr !»(s)))] [":=", expr mul_pos (mul_pos (factorial_pos _) (factorial_pos _)) (factorial_pos _)],
  refine [expr eq_of_mul_eq_mul_right h _],
  calc
    «expr = »(«expr * »(«expr * »(n.choose k, k.choose s), «expr * »(«expr * »(«expr !»(«expr - »(n, k)), «expr !»(«expr - »(k, s))), «expr !»(s))), «expr * »(«expr * »(n.choose k, «expr * »(«expr * »(k.choose s, «expr !»(s)), «expr !»(«expr - »(k, s)))), «expr !»(«expr - »(n, k)))) : by rw ["[", expr mul_assoc, ",", expr mul_assoc, ",", expr mul_assoc, ",", expr mul_assoc _ «expr !»(s), ",", expr mul_assoc, ",", expr mul_comm «expr !»(«expr - »(n, k)), ",", expr mul_comm «expr !»(s), "]"] []
    «expr = »(..., «expr !»(n)) : by rw ["[", expr choose_mul_factorial_mul_factorial hsk, ",", expr choose_mul_factorial_mul_factorial hkn, "]"] []
    «expr = »(..., «expr * »(«expr * »(n.choose s, «expr !»(s)), «expr * »(«expr * »(«expr - »(n, s).choose «expr - »(k, s), «expr !»(«expr - »(k, s))), «expr !»(«expr - »(«expr - »(n, s), «expr - »(k, s)))))) : by rw ["[", expr choose_mul_factorial_mul_factorial (tsub_le_tsub_right hkn _), ",", expr choose_mul_factorial_mul_factorial (hsk.trans hkn), "]"] []
    «expr = »(..., «expr * »(«expr * »(n.choose s, «expr - »(n, s).choose «expr - »(k, s)), «expr * »(«expr * »(«expr !»(«expr - »(n, k)), «expr !»(«expr - »(k, s))), «expr !»(s)))) : by rw ["[", expr tsub_tsub_tsub_cancel_right hsk, ",", expr mul_assoc, ",", expr mul_left_comm «expr !»(s), ",", expr mul_assoc, ",", expr mul_comm «expr !»(«expr - »(k, s)), ",", expr mul_comm «expr !»(s), ",", expr mul_right_comm, ",", "<-", expr mul_assoc, "]"] []
end

theorem choose_eq_factorial_div_factorial {n k : ℕ} (hk : k ≤ n) : choose n k = n ! / k !*(n - k)! :=
  by 
    rw [←choose_mul_factorial_mul_factorial hk, mul_assocₓ]
    exact (mul_div_left _ (mul_pos (factorial_pos _) (factorial_pos _))).symm

theorem add_choose (i j : ℕ) : (i+j).choose j = (i+j)! / i !*j ! :=
  by 
    rw [choose_eq_factorial_div_factorial (Nat.le_add_leftₓ j i), add_tsub_cancel_right, mul_commₓ]

theorem add_choose_mul_factorial_mul_factorial (i j : ℕ) : (((i+j).choose j*i !)*j !) = (i+j)! :=
  by 
    rw [←choose_mul_factorial_mul_factorial (Nat.le_add_leftₓ _ _), add_tsub_cancel_right, mul_right_commₓ]

theorem factorial_mul_factorial_dvd_factorial {n k : ℕ} (hk : k ≤ n) : (k !*(n - k)!) ∣ n ! :=
  by 
    rw [←choose_mul_factorial_mul_factorial hk, mul_assocₓ] <;> exact dvd_mul_left _ _

theorem factorial_mul_factorial_dvd_factorial_add (i j : ℕ) : (i !*j !) ∣ (i+j)! :=
  by 
    convert factorial_mul_factorial_dvd_factorial (le.intro rfl)
    rw [add_tsub_cancel_left]

@[simp]
theorem choose_symm {n k : ℕ} (hk : k ≤ n) : choose n (n - k) = choose n k :=
  by 
    rw [choose_eq_factorial_div_factorial hk, choose_eq_factorial_div_factorial (Nat.sub_leₓ _ _),
      tsub_tsub_cancel_of_le hk, mul_commₓ]

theorem choose_symm_of_eq_add {n a b : ℕ} (h : n = a+b) : Nat.choose n a = Nat.choose n b :=
  by 
    convert Nat.choose_symm (Nat.le_add_leftₓ _ _)
    rw [add_tsub_cancel_right]

theorem choose_symm_add {a b : ℕ} : choose (a+b) a = choose (a+b) b :=
  choose_symm_of_eq_add rfl

theorem choose_symm_half (m : ℕ) : choose ((2*m)+1) (m+1) = choose ((2*m)+1) m :=
  by 
    apply choose_symm_of_eq_add 
    rw [add_commₓ m 1, add_assocₓ 1 m m, add_commₓ (2*m) 1, two_mul m]

-- error in Data.Nat.Choose.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem choose_succ_right_eq
(n
 k : exprℕ()) : «expr = »(«expr * »(choose n «expr + »(k, 1), «expr + »(k, 1)), «expr * »(choose n k, «expr - »(n, k))) :=
begin
  have [ident e] [":", expr «expr = »(«expr * »(«expr + »(n, 1), choose n k), «expr + »(«expr * »(choose n k, «expr + »(k, 1)), «expr * »(choose n «expr + »(k, 1), «expr + »(k, 1))))] [],
  rw ["[", "<-", expr right_distrib, ",", "<-", expr choose_succ_succ, ",", expr succ_mul_choose_eq, "]"] [],
  rw ["[", "<-", expr tsub_eq_of_eq_add_rev e, ",", expr mul_comm, ",", "<-", expr mul_tsub, ",", expr add_tsub_add_eq_tsub_right, "]"] []
end

@[simp]
theorem choose_succ_self_right : ∀ (n : ℕ), (n+1).choose n = n+1
| 0 => rfl
| n+1 =>
  by 
    rw [choose_succ_succ, choose_succ_self_right, choose_self]

theorem choose_mul_succ_eq (n k : ℕ) : (n.choose k*n+1) = (n+1).choose k*(n+1) - k :=
  by 
    induction' k with k ih
    ·
      simp 
    obtain hk | hk := le_or_ltₓ (k+1) (n+1)
    ·
      rw [choose_succ_succ, add_mulₓ, succ_sub_succ, ←choose_succ_right_eq, ←succ_sub_succ, mul_tsub,
        add_tsub_cancel_of_le (Nat.mul_le_mul_leftₓ _ hk)]
    rw [choose_eq_zero_of_lt hk, choose_eq_zero_of_lt (n.lt_succ_self.trans hk), zero_mul, zero_mul]

theorem asc_factorial_eq_factorial_mul_choose (n k : ℕ) : n.asc_factorial k = k !*(n+k).choose k :=
  by 
    rw [mul_commₓ]
    apply mul_right_cancel₀ (factorial_ne_zero ((n+k) - k))
    rw [choose_mul_factorial_mul_factorial, add_tsub_cancel_right, ←factorial_mul_asc_factorial, mul_commₓ]
    exact Nat.le_add_leftₓ k n

theorem factorial_dvd_asc_factorial (n k : ℕ) : k ! ∣ n.asc_factorial k :=
  ⟨(n+k).choose k, asc_factorial_eq_factorial_mul_choose _ _⟩

theorem choose_eq_asc_factorial_div_factorial (n k : ℕ) : (n+k).choose k = n.asc_factorial k / k ! :=
  by 
    apply mul_left_cancel₀ (factorial_ne_zero k)
    rw [←asc_factorial_eq_factorial_mul_choose]
    exact (Nat.mul_div_cancel'ₓ$ factorial_dvd_asc_factorial _ _).symm

theorem desc_factorial_eq_factorial_mul_choose (n k : ℕ) : n.desc_factorial k = k !*n.choose k :=
  by 
    obtain h | h := Nat.lt_or_geₓ n k
    ·
      rw [desc_factorial_eq_zero_iff_lt.2 h, choose_eq_zero_of_lt h, mul_zero]
    rw [mul_commₓ]
    apply mul_right_cancel₀ (factorial_ne_zero (n - k))
    rw [choose_mul_factorial_mul_factorial h, ←factorial_mul_desc_factorial h, mul_commₓ]

theorem factorial_dvd_desc_factorial (n k : ℕ) : k ! ∣ n.desc_factorial k :=
  ⟨n.choose k, desc_factorial_eq_factorial_mul_choose _ _⟩

theorem choose_eq_desc_factorial_div_factorial (n k : ℕ) : n.choose k = n.desc_factorial k / k ! :=
  by 
    apply mul_left_cancel₀ (factorial_ne_zero k)
    rw [←desc_factorial_eq_factorial_mul_choose]
    exact (Nat.mul_div_cancel'ₓ$ factorial_dvd_desc_factorial _ _).symm

/-! ### Inequalities -/


/-- Show that `nat.choose` is increasing for small values of the right argument. -/
theorem choose_le_succ_of_lt_half_left {r n : ℕ} (h : r < n / 2) : choose n r ≤ choose n (r+1) :=
  by 
    refine' le_of_mul_le_mul_right _ (lt_tsub_iff_left.mpr (lt_of_lt_of_leₓ h (n.div_le_self 2)))
    rw [←choose_succ_right_eq]
    apply Nat.mul_le_mul_leftₓ 
    rw [←Nat.lt_iff_add_one_le, lt_tsub_iff_left, ←mul_two]
    exact lt_of_lt_of_leₓ (mul_lt_mul_of_pos_right h zero_lt_two) (n.div_mul_le_self 2)

/-- Show that for small values of the right argument, the middle value is largest. -/
private theorem choose_le_middle_of_le_half_left {n r : ℕ} (hr : r ≤ n / 2) : choose n r ≤ choose n (n / 2) :=
  decreasing_induction
    (fun _ k a =>
      (eq_or_lt_of_le a).elim (fun t => t.symm ▸ le_reflₓ _) fun h => (choose_le_succ_of_lt_half_left h).trans (k h))
    hr (fun _ => le_rfl) hr

/-- `choose n r` is maximised when `r` is `n/2`. -/
theorem choose_le_middle (r n : ℕ) : choose n r ≤ choose n (n / 2) :=
  by 
    cases' le_or_gtₓ r n with b b
    ·
      cases' le_or_ltₓ r (n / 2) with a h
      ·
        apply choose_le_middle_of_le_half_left a
      ·
        rw [←choose_symm b]
        apply choose_le_middle_of_le_half_left 
        rw [div_lt_iff_lt_mul' zero_lt_two] at h 
        rw [le_div_iff_mul_le' zero_lt_two, tsub_mul, tsub_le_iff_tsub_le, mul_two, add_tsub_cancel_right]
        exact le_of_ltₓ h
    ·
      rw [choose_eq_zero_of_lt b]
      apply zero_le

/-! #### Inequalities about increasing the first argument -/


theorem choose_le_succ (a c : ℕ) : choose a c ≤ choose a.succ c :=
  by 
    cases c <;> simp [Nat.choose_succ_succ]

theorem choose_le_add (a b c : ℕ) : choose a c ≤ choose (a+b) c :=
  by 
    induction' b with b_n b_ih
    ·
      simp 
    exact le_transₓ b_ih (choose_le_succ (a+b_n) c)

theorem choose_le_choose {a b : ℕ} (c : ℕ) (h : a ≤ b) : choose a c ≤ choose b c :=
  add_tsub_cancel_of_le h ▸ choose_le_add a (b - a) c

theorem choose_mono (b : ℕ) : Monotone fun a => choose a b :=
  fun _ _ => choose_le_choose b

end Nat

