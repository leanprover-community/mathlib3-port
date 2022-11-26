/-
Copyright (c) 2014 Floris van Doorn (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn, Leonardo de Moura, Jeremy Avigad, Mario Carneiro
-/
import Mathbin.Algebra.Order.Ring.Canonical
import Mathbin.Data.Nat.Basic

/-!
# The natural numbers as a linearly ordered commutative semiring

We also have a variety of lemmas which have been deferred from `data.nat.basic` because it is
easier to prove them with this ordered semiring instance available.

You may find that some theorems can be moved back to `data.nat.basic` by modifying their proofs.
-/


universe u v

/-! ### instances -/


instance Nat.orderBot : OrderBot ℕ where
  bot := 0
  bot_le := Nat.zero_le
#align nat.order_bot Nat.orderBot

instance : LinearOrderedCommSemiring ℕ :=
  { Nat.commSemiring, Nat.linearOrder with lt := Nat.lt, add_le_add_left := @Nat.add_le_add_left,
    le_of_add_le_add_left := @Nat.le_of_add_le_add_left, zero_le_one := Nat.le_of_lt (Nat.zero_lt_succ 0),
    mul_lt_mul_of_pos_left := @Nat.mul_lt_mul_of_pos_left, mul_lt_mul_of_pos_right := @Nat.mul_lt_mul_of_pos_right,
    DecidableEq := Nat.decidableEq, exists_pair_ne := ⟨0, 1, ne_of_lt Nat.zero_lt_one⟩ }

instance : LinearOrderedCommMonoidWithZero ℕ :=
  { Nat.linearOrderedCommSemiring, (inferInstance : CommMonoidWithZero ℕ) with
    mul_le_mul_left := fun a b h c => Nat.mul_le_mul_left c h }

/-! Extra instances to short-circuit type class resolution and ensure computability -/


-- Not using `infer_instance` avoids `classical.choice` in the following two
instance : LinearOrderedSemiring ℕ :=
  inferInstance

instance : StrictOrderedSemiring ℕ :=
  inferInstance

instance : StrictOrderedCommSemiring ℕ :=
  inferInstance

instance : OrderedSemiring ℕ :=
  StrictOrderedSemiring.toOrderedSemiring'

instance : OrderedCommSemiring ℕ :=
  StrictOrderedCommSemiring.toOrderedCommSemiring'

instance : LinearOrderedCancelAddCommMonoid ℕ :=
  inferInstance

instance : CanonicallyOrderedCommSemiring ℕ :=
  { Nat.nontrivial, Nat.orderBot, (inferInstance : OrderedAddCommMonoid ℕ), (inferInstance : LinearOrderedSemiring ℕ),
    (inferInstance : CommSemiring ℕ) with exists_add_of_le := fun a b h => (Nat.le.dest h).imp fun _ => Eq.symm,
    le_self_add := Nat.le_add_right, eq_zero_or_eq_zero_of_mul_eq_zero := fun a b => Nat.eq_zero_of_mul_eq_zero }

instance : CanonicallyLinearOrderedAddMonoid ℕ :=
  { (inferInstance : CanonicallyOrderedAddMonoid ℕ), Nat.linearOrder with }

variable {m n k : ℕ}

namespace Nat

/-! ### Equalities and inequalities involving zero and one -/


theorem one_le_iff_ne_zero {n : ℕ} : 1 ≤ n ↔ n ≠ 0 :=
  (show 1 ≤ n ↔ 0 < n from Iff.rfl).trans pos_iff_ne_zero
#align nat.one_le_iff_ne_zero Nat.one_le_iff_ne_zero

theorem one_lt_iff_ne_zero_and_ne_one : ∀ {n : ℕ}, 1 < n ↔ n ≠ 0 ∧ n ≠ 1
  | 0 => by decide
  | 1 => by decide
  | n + 2 => by decide
#align nat.one_lt_iff_ne_zero_and_ne_one Nat.one_lt_iff_ne_zero_and_ne_one

protected theorem mul_ne_zero {n m : ℕ} (n0 : n ≠ 0) (m0 : m ≠ 0) : n * m ≠ 0
  | nm => (eq_zero_of_mul_eq_zero nm).elim n0 m0
#align nat.mul_ne_zero Nat.mul_ne_zero

#print Nat.mul_eq_zero /-
@[simp]
protected theorem mul_eq_zero {a b : ℕ} : a * b = 0 ↔ a = 0 ∨ b = 0 :=
  Iff.intro eq_zero_of_mul_eq_zero (by simp (config := { contextual := true }) [or_imp])
#align nat.mul_eq_zero Nat.mul_eq_zero
-/

@[simp]
protected theorem zero_eq_mul {a b : ℕ} : 0 = a * b ↔ a = 0 ∨ b = 0 := by rw [eq_comm, Nat.mul_eq_zero]
#align nat.zero_eq_mul Nat.zero_eq_mul

theorem eq_zero_of_double_le {a : ℕ} (h : 2 * a ≤ a) : a = 0 :=
  add_right_eq_self.mp <| le_antisymm ((two_mul a).symm.trans_le h) le_add_self
#align nat.eq_zero_of_double_le Nat.eq_zero_of_double_le

theorem eq_zero_of_mul_le {a b : ℕ} (hb : 2 ≤ b) (h : b * a ≤ a) : a = 0 :=
  eq_zero_of_double_le <| le_trans (Nat.mul_le_mul_right _ hb) h
#align nat.eq_zero_of_mul_le Nat.eq_zero_of_mul_le

theorem zero_max {m : ℕ} : max 0 m = m :=
  max_eq_right (zero_le _)
#align nat.zero_max Nat.zero_max

@[simp]
theorem min_eq_zero_iff {m n : ℕ} : min m n = 0 ↔ m = 0 ∨ n = 0 := by
  constructor
  · intro h
    cases' le_total n m with H H
    · simpa [H] using Or.inr h
      
    · simpa [H] using Or.inl h
      
    
  · rintro (rfl | rfl) <;> simp
    
#align nat.min_eq_zero_iff Nat.min_eq_zero_iff

@[simp]
theorem max_eq_zero_iff {m n : ℕ} : max m n = 0 ↔ m = 0 ∧ n = 0 := by
  constructor
  · intro h
    cases' le_total n m with H H
    · simp only [H, max_eq_left] at h
      exact ⟨h, le_antisymm (H.trans h.le) (zero_le _)⟩
      
    · simp only [H, max_eq_right] at h
      exact ⟨le_antisymm (H.trans h.le) (zero_le _), h⟩
      
    
  · rintro ⟨rfl, rfl⟩
    simp
    
#align nat.max_eq_zero_iff Nat.max_eq_zero_iff

theorem add_eq_max_iff {n m : ℕ} : n + m = max n m ↔ n = 0 ∨ m = 0 := by
  rw [← min_eq_zero_iff]
  cases' le_total n m with H H <;> simp [H]
#align nat.add_eq_max_iff Nat.add_eq_max_iff

theorem add_eq_min_iff {n m : ℕ} : n + m = min n m ↔ n = 0 ∧ m = 0 := by
  rw [← max_eq_zero_iff]
  cases' le_total n m with H H <;> simp [H]
#align nat.add_eq_min_iff Nat.add_eq_min_iff

theorem one_le_of_lt {n m : ℕ} (h : n < m) : 1 ≤ m :=
  lt_of_le_of_lt (Nat.zero_le _) h
#align nat.one_le_of_lt Nat.one_le_of_lt

theorem eq_one_of_mul_eq_one_right {m n : ℕ} (H : m * n = 1) : m = 1 :=
  eq_one_of_dvd_one ⟨n, H.symm⟩
#align nat.eq_one_of_mul_eq_one_right Nat.eq_one_of_mul_eq_one_right

theorem eq_one_of_mul_eq_one_left {m n : ℕ} (H : m * n = 1) : n = 1 :=
  eq_one_of_mul_eq_one_right (by rwa [mul_comm])
#align nat.eq_one_of_mul_eq_one_left Nat.eq_one_of_mul_eq_one_left

/-! ### `succ` -/


theorem two_le_iff : ∀ n, 2 ≤ n ↔ n ≠ 0 ∧ n ≠ 1
  | 0 => by simp
  | 1 => by simp
  | n + 2 => by simp
#align nat.two_le_iff Nat.two_le_iff

@[simp]
theorem lt_one_iff {n : ℕ} : n < 1 ↔ n = 0 :=
  lt_succ_iff.trans nonpos_iff_eq_zero
#align nat.lt_one_iff Nat.lt_one_iff

/-! ### `add` -/


theorem add_pos_left {m : ℕ} (h : 0 < m) (n : ℕ) : 0 < m + n :=
  calc
    m + n > 0 + n := Nat.add_lt_add_right h n
    _ = n := Nat.zero_add n
    _ ≥ 0 := zero_le n
    
#align nat.add_pos_left Nat.add_pos_left

theorem add_pos_right (m : ℕ) {n : ℕ} (h : 0 < n) : 0 < m + n := by
  rw [add_comm]
  exact add_pos_left h m
#align nat.add_pos_right Nat.add_pos_right

theorem add_pos_iff_pos_or_pos (m n : ℕ) : 0 < m + n ↔ 0 < m ∨ 0 < n :=
  Iff.intro
    (by
      intro h
      cases' m with m
      · simp [zero_add] at h
        exact Or.inr h
        
      exact Or.inl (succ_pos _))
    (by
      intro h
      cases' h with mpos npos
      · apply add_pos_left mpos
        
      apply add_pos_right _ npos)
#align nat.add_pos_iff_pos_or_pos Nat.add_pos_iff_pos_or_pos

theorem add_eq_one_iff : m + n = 1 ↔ m = 0 ∧ n = 1 ∨ m = 1 ∧ n = 0 := by
  cases n <;> simp [succ_eq_add_one, ← add_assoc, succ_inj']
#align nat.add_eq_one_iff Nat.add_eq_one_iff

theorem add_eq_two_iff : m + n = 2 ↔ m = 0 ∧ n = 2 ∨ m = 1 ∧ n = 1 ∨ m = 2 ∧ n = 0 := by
  cases n <;> simp [(succ_ne_zero 1).symm, succ_eq_add_one, ← add_assoc, succ_inj', add_eq_one_iff]
#align nat.add_eq_two_iff Nat.add_eq_two_iff

theorem add_eq_three_iff : m + n = 3 ↔ m = 0 ∧ n = 3 ∨ m = 1 ∧ n = 2 ∨ m = 2 ∧ n = 1 ∨ m = 3 ∧ n = 0 := by
  cases n <;> simp [(succ_ne_zero 1).symm, succ_eq_add_one, ← add_assoc, succ_inj', add_eq_two_iff]
#align nat.add_eq_three_iff Nat.add_eq_three_iff

theorem le_add_one_iff {i j : ℕ} : i ≤ j + 1 ↔ i ≤ j ∨ i = j + 1 :=
  ⟨fun h =>
    match Nat.eq_or_lt_of_le h with
    | Or.inl h => Or.inr h
    | Or.inr h => Or.inl <| Nat.le_of_succ_le_succ h,
    Or.ndrec (fun h => le_trans h <| Nat.le_add_right _ _) le_of_eq⟩
#align nat.le_add_one_iff Nat.le_add_one_iff

theorem le_and_le_add_one_iff {x a : ℕ} : a ≤ x ∧ x ≤ a + 1 ↔ x = a ∨ x = a + 1 := by
  rw [le_add_one_iff, and_or_left, ← le_antisymm_iff, eq_comm, and_iff_right_of_imp]
  rintro rfl
  exact a.le_succ
#align nat.le_and_le_add_one_iff Nat.le_and_le_add_one_iff

theorem add_succ_lt_add {a b c d : ℕ} (hab : a < b) (hcd : c < d) : a + c + 1 < b + d := by
  rw [add_assoc]
  exact add_lt_add_of_lt_of_le hab (Nat.succ_le_iff.2 hcd)
#align nat.add_succ_lt_add Nat.add_succ_lt_add

/-! ### `pred` -/


theorem pred_le_iff {n m : ℕ} : pred n ≤ m ↔ n ≤ succ m :=
  ⟨le_succ_of_pred_le, by
    cases n
    · exact fun h => zero_le m
      
    exact le_of_succ_le_succ⟩
#align nat.pred_le_iff Nat.pred_le_iff

/-! ### `sub`

Most lemmas come from the `has_ordered_sub` instance on `ℕ`. -/


instance : HasOrderedSub ℕ := by
  constructor
  intro m n k
  induction' n with n ih generalizing k
  · simp
    
  · simp only [sub_succ, add_succ, succ_add, ih, pred_le_iff]
    

theorem lt_pred_iff {n m : ℕ} : n < pred m ↔ succ n < m :=
  show n < m - 1 ↔ n + 1 < m from lt_tsub_iff_right
#align nat.lt_pred_iff Nat.lt_pred_iff

theorem lt_of_lt_pred {a b : ℕ} (h : a < b - 1) : a < b :=
  lt_of_succ_lt (lt_pred_iff.1 h)
#align nat.lt_of_lt_pred Nat.lt_of_lt_pred

theorem le_or_le_of_add_eq_add_pred {a b c d : ℕ} (h : c + d = a + b - 1) : a ≤ c ∨ b ≤ d := by
  cases' le_or_lt a c with h' h' <;> [left, right]
  · exact h'
    
  · replace h' := add_lt_add_right h' d
    rw [h] at h'
    cases' b.eq_zero_or_pos with hb hb
    · rw [hb]
      exact zero_le d
      
    rw [a.add_sub_assoc hb, add_lt_add_iff_left] at h'
    exact Nat.le_of_pred_lt h'
    
#align nat.le_or_le_of_add_eq_add_pred Nat.le_or_le_of_add_eq_add_pred

/-- A version of `nat.sub_succ` in the form `_ - 1` instead of `nat.pred _`. -/
theorem sub_succ' (a b : ℕ) : a - b.succ = a - b - 1 :=
  rfl
#align nat.sub_succ' Nat.sub_succ'

/-! ### `mul` -/


theorem mul_eq_one_iff : ∀ {a b : ℕ}, a * b = 1 ↔ a = 1 ∧ b = 1
  | 0, 0 => by decide
  | 0, 1 => by decide
  | 1, 0 => by decide
  | a + 2, 0 => by simp
  | 0, b + 2 => by simp
  | a + 1, b + 1 =>
    ⟨fun h => by
      simp only [add_mul, mul_add, mul_add, one_mul, mul_one, (add_assoc _ _ _).symm, Nat.succ_inj', add_eq_zero_iff] at
          h <;>
        simp [h.1.2, h.2],
      fun h => by simp only [h, mul_one]⟩
#align nat.mul_eq_one_iff Nat.mul_eq_one_iff

theorem succ_mul_pos (m : ℕ) (hn : 0 < n) : 0 < succ m * n :=
  mul_pos (succ_pos m) hn
#align nat.succ_mul_pos Nat.succ_mul_pos

theorem mul_self_le_mul_self {n m : ℕ} (h : n ≤ m) : n * n ≤ m * m :=
  mul_le_mul h h (zero_le _) (zero_le _)
#align nat.mul_self_le_mul_self Nat.mul_self_le_mul_self

theorem mul_self_lt_mul_self : ∀ {n m : ℕ}, n < m → n * n < m * m
  | 0, m, h => mul_pos h h
  | succ n, m, h => mul_lt_mul h (le_of_lt h) (succ_pos _) (zero_le _)
#align nat.mul_self_lt_mul_self Nat.mul_self_lt_mul_self

theorem mul_self_le_mul_self_iff {n m : ℕ} : n ≤ m ↔ n * n ≤ m * m :=
  ⟨mul_self_le_mul_self, le_imp_le_of_lt_imp_lt mul_self_lt_mul_self⟩
#align nat.mul_self_le_mul_self_iff Nat.mul_self_le_mul_self_iff

theorem mul_self_lt_mul_self_iff {n m : ℕ} : n < m ↔ n * n < m * m :=
  le_iff_le_iff_lt_iff_lt.1 mul_self_le_mul_self_iff
#align nat.mul_self_lt_mul_self_iff Nat.mul_self_lt_mul_self_iff

theorem le_mul_self : ∀ n : ℕ, n ≤ n * n
  | 0 => le_rfl
  | n + 1 => by simp
#align nat.le_mul_self Nat.le_mul_self

theorem le_mul_of_pos_left {m n : ℕ} (h : 0 < n) : m ≤ n * m := by
  conv =>
  lhs
  rw [← one_mul m]
  exact mul_le_mul_of_nonneg_right h.nat_succ_le (by decide)
#align nat.le_mul_of_pos_left Nat.le_mul_of_pos_left

theorem le_mul_of_pos_right {m n : ℕ} (h : 0 < n) : m ≤ m * n := by
  conv =>
  lhs
  rw [← mul_one m]
  exact mul_le_mul_of_nonneg_left h.nat_succ_le (by decide)
#align nat.le_mul_of_pos_right Nat.le_mul_of_pos_right

theorem mul_self_inj {n m : ℕ} : n * n = m * m ↔ n = m :=
  le_antisymm_iff.trans (le_antisymm_iff.trans (and_congr mul_self_le_mul_self_iff mul_self_le_mul_self_iff)).symm
#align nat.mul_self_inj Nat.mul_self_inj

theorem le_add_pred_of_pos (n : ℕ) {i : ℕ} (hi : i ≠ 0) : n ≤ i + (n - 1) := by
  refine' le_trans _ add_tsub_le_assoc
  simp [add_comm, Nat.add_sub_assoc, one_le_iff_ne_zero.2 hi]
#align nat.le_add_pred_of_pos Nat.le_add_pred_of_pos

/-!
### Recursion and induction principles

This section is here due to dependencies -- the lemmas here require some of the lemmas
proved above, and some of the results in later sections depend on the definitions in this section.
-/


/-- Given a predicate on two naturals `P : ℕ → ℕ → Prop`, `P a b` is true for all `a < b` if
`P (a + 1) (a + 1)` is true for all `a`, `P 0 (b + 1)` is true for all `b` and for all
`a < b`, `P (a + 1) b` is true and `P a (b + 1)` is true implies `P (a + 1) (b + 1)` is true. -/
@[elab_as_elim]
theorem diag_induction (P : ℕ → ℕ → Prop) (ha : ∀ a, P (a + 1) (a + 1)) (hb : ∀ b, P 0 (b + 1))
    (hd : ∀ a b, a < b → P (a + 1) b → P a (b + 1) → P (a + 1) (b + 1)) : ∀ a b, a < b → P a b
  | 0, b + 1, h => hb _
  | a + 1, b + 1, h => by
    apply hd _ _ ((add_lt_add_iff_right _).1 h)
    · have : a + 1 = b ∨ a + 1 < b := by rwa [← le_iff_eq_or_lt, ← Nat.lt_succ_iff]
      rcases this with (rfl | _)
      · exact ha _
        
      apply diag_induction (a + 1) b this
      
    apply diag_induction a (b + 1)
    apply lt_of_le_of_lt (Nat.le_succ _) h termination_by' ⟨_, measure_wf fun p => p.1 + p.2.1⟩
#align nat.diag_induction Nat.diag_induction

/-- A subset of `ℕ` containing `b : ℕ` and closed under `nat.succ` contains every `n ≥ b`. -/
theorem set_induction_bounded {b : ℕ} {S : Set ℕ} (hb : b ∈ S) (h_ind : ∀ k : ℕ, k ∈ S → k + 1 ∈ S) {n : ℕ}
    (hbn : b ≤ n) : n ∈ S :=
  @leRecOn (fun n => n ∈ S) b n hbn h_ind hb
#align nat.set_induction_bounded Nat.set_induction_bounded

/-- A subset of `ℕ` containing zero and closed under `nat.succ` contains all of `ℕ`. -/
theorem set_induction {S : Set ℕ} (hb : 0 ∈ S) (h_ind : ∀ k : ℕ, k ∈ S → k + 1 ∈ S) (n : ℕ) : n ∈ S :=
  set_induction_bounded hb h_ind (zero_le n)
#align nat.set_induction Nat.set_induction

/-! ### `div` -/


protected theorem div_le_of_le_mul' {m n : ℕ} {k} (h : m ≤ k * n) : m / k ≤ n :=
  (Nat.eq_zero_or_pos k).elim (fun k0 => by rw [k0, Nat.div_zero] <;> apply zero_le) fun k0 =>
    (mul_le_mul_left k0).1 <|
      calc
        k * (m / k) ≤ m % k + k * (m / k) := Nat.le_add_left _ _
        _ = m := mod_add_div _ _
        _ ≤ k * n := h
        
#align nat.div_le_of_le_mul' Nat.div_le_of_le_mul'

protected theorem div_le_self' (m n : ℕ) : m / n ≤ m :=
  (Nat.eq_zero_or_pos n).elim (fun n0 => by rw [n0, Nat.div_zero] <;> apply zero_le) fun n0 =>
    Nat.div_le_of_le_mul' <|
      calc
        m = 1 * m := (one_mul _).symm
        _ ≤ n * m := Nat.mul_le_mul_right _ n0
        
#align nat.div_le_self' Nat.div_le_self'

protected theorem div_lt_of_lt_mul {m n k : ℕ} (h : m < n * k) : m / n < k :=
  lt_of_mul_lt_mul_left
    (calc
      n * (m / n) ≤ m % n + n * (m / n) := Nat.le_add_left _ _
      _ = m := mod_add_div _ _
      _ < n * k := h
      )
    (Nat.zero_le n)
#align nat.div_lt_of_lt_mul Nat.div_lt_of_lt_mul

theorem eq_zero_of_le_div {a b : ℕ} (hb : 2 ≤ b) (h : a ≤ a / b) : a = 0 :=
  eq_zero_of_mul_le hb <| by rw [mul_comm] <;> exact (Nat.le_div_iff_mul_le' (lt_of_lt_of_le (by decide) hb)).1 h
#align nat.eq_zero_of_le_div Nat.eq_zero_of_le_div

theorem div_mul_div_le_div (a b c : ℕ) : a / c * b / a ≤ b / c :=
  if ha0 : a = 0 then by simp [ha0]
  else
    calc
      a / c * b / a ≤ b * a / c / a := Nat.div_le_div_right (by rw [mul_comm] <;> exact mul_div_le_mul_div_assoc _ _ _)
      _ = b / c := by rw [Nat.div_div_eq_div_mul, mul_comm b, mul_comm c, Nat.mul_div_mul _ _ (Nat.pos_of_ne_zero ha0)]
      
#align nat.div_mul_div_le_div Nat.div_mul_div_le_div

theorem eq_zero_of_le_half {a : ℕ} (h : a ≤ a / 2) : a = 0 :=
  eq_zero_of_le_div le_rfl h
#align nat.eq_zero_of_le_half Nat.eq_zero_of_le_half

theorem mul_div_mul_comm_of_dvd_dvd {a b c d : ℕ} (hac : c ∣ a) (hbd : d ∣ b) : a * b / (c * d) = a / c * (b / d) := by
  rcases c.eq_zero_or_pos with (rfl | hc0)
  · simp
    
  rcases d.eq_zero_or_pos with (rfl | hd0)
  · simp
    
  obtain ⟨k1, rfl⟩ := hac
  obtain ⟨k2, rfl⟩ := hbd
  rw [mul_mul_mul_comm, Nat.mul_div_cancel_left _ hc0, Nat.mul_div_cancel_left _ hd0,
    Nat.mul_div_cancel_left _ (mul_pos hc0 hd0)]
#align nat.mul_div_mul_comm_of_dvd_dvd Nat.mul_div_mul_comm_of_dvd_dvd

/-! ### `mod`, `dvd` -/


theorem two_mul_odd_div_two {n : ℕ} (hn : n % 2 = 1) : 2 * (n / 2) = n - 1 := by conv =>
  rhs
  rw [← Nat.mod_add_div n 2, hn, add_tsub_cancel_left]
#align nat.two_mul_odd_div_two Nat.two_mul_odd_div_two

theorem div_dvd_of_dvd {a b : ℕ} (h : b ∣ a) : a / b ∣ a :=
  ⟨b, (Nat.div_mul_cancel h).symm⟩
#align nat.div_dvd_of_dvd Nat.div_dvd_of_dvd

protected theorem div_div_self {a b : ℕ} (h : b ∣ a) (ha : a ≠ 0) : a / (a / b) = b := by
  rcases h with ⟨a, rfl⟩
  rw [mul_ne_zero_iff] at ha
  rw [Nat.mul_div_right _ (Nat.pos_of_ne_zero ha.1), Nat.mul_div_left _ (Nat.pos_of_ne_zero ha.2)]
#align nat.div_div_self Nat.div_div_self

theorem mod_mul_right_div_self (a b c : ℕ) : a % (b * c) / b = a / b % c := by
  rcases Nat.eq_zero_or_pos b with (rfl | hb)
  · simp
    
  rcases Nat.eq_zero_or_pos c with (rfl | hc)
  · simp
    
  conv_rhs => rw [← mod_add_div a (b * c)]
  rw [mul_assoc, Nat.add_mul_div_left _ _ hb, add_mul_mod_self_left,
    mod_eq_of_lt (Nat.div_lt_of_lt_mul (mod_lt _ (mul_pos hb hc)))]
#align nat.mod_mul_right_div_self Nat.mod_mul_right_div_self

theorem mod_mul_left_div_self (a b c : ℕ) : a % (c * b) / b = a / b % c := by rw [mul_comm c, mod_mul_right_div_self]
#align nat.mod_mul_left_div_self Nat.mod_mul_left_div_self

theorem not_dvd_of_pos_of_lt {a b : ℕ} (h1 : 0 < b) (h2 : b < a) : ¬a ∣ b := by
  rintro ⟨c, rfl⟩
  rcases Nat.eq_zero_or_pos c with (rfl | hc)
  · exact lt_irrefl 0 h1
    
  · exact not_lt.2 (le_mul_of_pos_right hc) h2
    
#align nat.not_dvd_of_pos_of_lt Nat.not_dvd_of_pos_of_lt

/-- If `a` and `b` are equal mod `c`, `a - b` is zero mod `c`. -/
theorem sub_mod_eq_zero_of_mod_eq {a b c : ℕ} (h : a % c = b % c) : (a - b) % c = 0 := by
  rw [← Nat.mod_add_div a c, ← Nat.mod_add_div b c, ← h, tsub_add_eq_tsub_tsub, add_tsub_cancel_left, ← mul_tsub,
    Nat.mul_mod_right]
#align nat.sub_mod_eq_zero_of_mod_eq Nat.sub_mod_eq_zero_of_mod_eq

@[simp]
theorem one_mod (n : ℕ) : 1 % (n + 2) = 1 :=
  Nat.mod_eq_of_lt (add_lt_add_right n.succ_pos 1)
#align nat.one_mod Nat.one_mod

theorem dvd_sub_mod (k : ℕ) : n ∣ k - k % n :=
  ⟨k / n, tsub_eq_of_eq_add_rev (Nat.mod_add_div k n).symm⟩
#align nat.dvd_sub_mod Nat.dvd_sub_mod

theorem add_mod_eq_ite {a b n : ℕ} : (a + b) % n = if n ≤ a % n + b % n then a % n + b % n - n else a % n + b % n := by
  cases n
  · simp
    
  rw [Nat.add_mod]
  split_ifs with h
  · rw [Nat.mod_eq_sub_mod h, Nat.mod_eq_of_lt]
    exact (tsub_lt_iff_right h).mpr (Nat.add_lt_add (a.mod_lt n.zero_lt_succ) (b.mod_lt n.zero_lt_succ))
    
  · exact Nat.mod_eq_of_lt (lt_of_not_ge h)
    
#align nat.add_mod_eq_ite Nat.add_mod_eq_ite

theorem div_mul_div_comm {a b c d : ℕ} (hab : b ∣ a) (hcd : d ∣ c) : a / b * (c / d) = a * c / (b * d) :=
  have exi1 : ∃ x, a = b * x := hab
  have exi2 : ∃ y, c = d * y := hcd
  if hb : b = 0 then by simp [hb]
  else
    have : 0 < b := Nat.pos_of_ne_zero hb
    if hd : d = 0 then by simp [hd]
    else by
      have : 0 < d := Nat.pos_of_ne_zero hd
      cases' exi1 with x hx
      cases' exi2 with y hy
      rw [hx, hy, Nat.mul_div_cancel_left, Nat.mul_div_cancel_left]
      symm
      apply Nat.div_eq_of_eq_mul_left
      apply mul_pos
      repeat' assumption
      cc
#align nat.div_mul_div_comm Nat.div_mul_div_comm

theorem div_eq_self {a b : ℕ} : a / b = a ↔ a = 0 ∨ b = 1 := by
  constructor
  · intro
    cases b
    · simp_all
      
    · cases b
      · right
        rfl
        
      · left
        have : a / (b + 2) ≤ a / 2 := div_le_div_left (by simp) (by decide)
        refine' eq_zero_of_le_half _
        simp_all
        
      
    
  · rintro (rfl | rfl) <;> simp
    
#align nat.div_eq_self Nat.div_eq_self

/- ./././Mathport/Syntax/Translate/Tactic/Lean3.lean:132:4: warning: unsupported: rw with cfg: { occs := occurrences.pos[occurrences.pos] «expr[ ,]»([2]) } -/
theorem div_eq_sub_mod_div {m n : ℕ} : m / n = (m - m % n) / n := by
  by_cases n0 : n = 0
  · rw [n0, Nat.div_zero, Nat.div_zero]
    
  · rw [← mod_add_div m n]
    rw [add_tsub_cancel_left, mul_div_right _ (Nat.pos_of_ne_zero n0)]
    
#align nat.div_eq_sub_mod_div Nat.div_eq_sub_mod_div

/-- `n` is not divisible by `a` if it is between `a * k` and `a * (k + 1)` for some `k`. -/
theorem not_dvd_of_between_consec_multiples {n a k : ℕ} (h1 : a * k < n) (h2 : n < a * (k + 1)) : ¬a ∣ n := by
  rintro ⟨d, rfl⟩
  exact Monotone.ne_of_lt_of_lt_nat (Covariant.monotone_of_const a) k h1 h2 d rfl
#align nat.not_dvd_of_between_consec_multiples Nat.not_dvd_of_between_consec_multiples

/-! ### `find` -/


section Find

variable {p q : ℕ → Prop} [DecidablePred p] [DecidablePred q]

@[simp]
theorem find_pos (h : ∃ n : ℕ, p n) : 0 < Nat.find h ↔ ¬p 0 := by rw [pos_iff_ne_zero, Ne, Nat.find_eq_zero]
#align nat.find_pos Nat.find_pos

theorem find_add {hₘ : ∃ m, p (m + n)} {hₙ : ∃ n, p n} (hn : n ≤ Nat.find hₙ) : Nat.find hₘ + n = Nat.find hₙ := by
  refine' ((le_find_iff _ _).2 fun m hm hpm => hm.not_le _).antisymm _
  · have hnm : n ≤ m := hn.trans (find_le hpm)
    refine' add_le_of_le_tsub_right_of_le hnm (find_le _)
    rwa [tsub_add_cancel_of_le hnm]
    
  · rw [← tsub_le_iff_right]
    refine' (le_find_iff _ _).2 fun m hm hpm => hm.not_le _
    rw [tsub_le_iff_right]
    exact find_le hpm
    
#align nat.find_add Nat.find_add

end Find

/-! ### `find_greatest` -/


section FindGreatest

variable {P Q : ℕ → Prop} [DecidablePred P] {b : ℕ}

theorem find_greatest_eq_iff : Nat.findGreatest P b = m ↔ m ≤ b ∧ (m ≠ 0 → P m) ∧ ∀ ⦃n⦄, m < n → n ≤ b → ¬P n := by
  induction' b with b ihb generalizing m
  · rw [eq_comm, Iff.comm]
    simp only [nonpos_iff_eq_zero, Ne.def, and_iff_left_iff_imp, find_greatest_zero]
    rintro rfl
    exact ⟨fun h => (h rfl).elim, fun n hlt heq => (hlt.Ne HEq.symm).elim⟩
    
  · by_cases hb : P (b + 1)
    · rw [find_greatest_eq hb]
      constructor
      · rintro rfl
        exact ⟨le_rfl, fun _ => hb, fun n hlt hle => (hlt.not_le hle).elim⟩
        
      · rintro ⟨hle, h0, hm⟩
        rcases Decidable.eq_or_lt_of_le hle with (rfl | hlt)
        exacts[rfl, (hm hlt le_rfl hb).elim]
        
      
    · rw [find_greatest_of_not hb, ihb]
      constructor
      · rintro ⟨hle, hP, hm⟩
        refine' ⟨hle.trans b.le_succ, hP, fun n hlt hle => _⟩
        rcases Decidable.eq_or_lt_of_le hle with (rfl | hlt')
        exacts[hb, hm hlt <| lt_succ_iff.1 hlt']
        
      · rintro ⟨hle, hP, hm⟩
        refine' ⟨lt_succ_iff.1 (hle.lt_of_ne _), hP, fun n hlt hle => hm hlt (hle.trans b.le_succ)⟩
        rintro rfl
        exact hb (hP b.succ_ne_zero)
        
      
    
#align nat.find_greatest_eq_iff Nat.find_greatest_eq_iff

theorem find_greatest_eq_zero_iff : Nat.findGreatest P b = 0 ↔ ∀ ⦃n⦄, 0 < n → n ≤ b → ¬P n := by
  simp [find_greatest_eq_iff]
#align nat.find_greatest_eq_zero_iff Nat.find_greatest_eq_zero_iff

theorem find_greatest_spec (hmb : m ≤ b) (hm : P m) : P (Nat.findGreatest P b) := by
  by_cases h : Nat.findGreatest P b = 0
  · cases m
    · rwa [h]
      
    exact ((find_greatest_eq_zero_iff.1 h) m.zero_lt_succ hmb hm).elim
    
  · exact (find_greatest_eq_iff.1 rfl).2.1 h
    
#align nat.find_greatest_spec Nat.find_greatest_spec

theorem find_greatest_le (n : ℕ) : Nat.findGreatest P n ≤ n :=
  (find_greatest_eq_iff.1 rfl).1
#align nat.find_greatest_le Nat.find_greatest_le

theorem le_find_greatest (hmb : m ≤ b) (hm : P m) : m ≤ Nat.findGreatest P b :=
  le_of_not_lt fun hlt => (find_greatest_eq_iff.1 rfl).2.2 hlt hmb hm
#align nat.le_find_greatest Nat.le_find_greatest

theorem find_greatest_mono_right (P : ℕ → Prop) [DecidablePred P] : Monotone (Nat.findGreatest P) := by
  refine' monotone_nat_of_le_succ fun n => _
  rw [find_greatest_succ]
  split_ifs
  · exact (find_greatest_le n).trans (le_succ _)
    
  · rfl
    
#align nat.find_greatest_mono_right Nat.find_greatest_mono_right

theorem find_greatest_mono_left [DecidablePred Q] (hPQ : P ≤ Q) : Nat.findGreatest P ≤ Nat.findGreatest Q := by
  intro n
  induction' n with n hn
  · rfl
    
  by_cases P (n + 1)
  · rw [find_greatest_eq h, find_greatest_eq (hPQ _ h)]
    
  · rw [find_greatest_of_not h]
    exact hn.trans (Nat.find_greatest_mono_right _ <| le_succ _)
    
#align nat.find_greatest_mono_left Nat.find_greatest_mono_left

theorem find_greatest_mono {a b : ℕ} [DecidablePred Q] (hPQ : P ≤ Q) (hab : a ≤ b) :
    Nat.findGreatest P a ≤ Nat.findGreatest Q b :=
  (Nat.find_greatest_mono_right _ hab).trans <| find_greatest_mono_left hPQ _
#align nat.find_greatest_mono Nat.find_greatest_mono

theorem find_greatest_is_greatest (hk : Nat.findGreatest P b < k) (hkb : k ≤ b) : ¬P k :=
  (find_greatest_eq_iff.1 rfl).2.2 hk hkb
#align nat.find_greatest_is_greatest Nat.find_greatest_is_greatest

theorem find_greatest_of_ne_zero (h : Nat.findGreatest P b = m) (h0 : m ≠ 0) : P m :=
  (find_greatest_eq_iff.1 h).2.1 h0
#align nat.find_greatest_of_ne_zero Nat.find_greatest_of_ne_zero

end FindGreatest

/-! ### `bit0` and `bit1` -/


protected theorem bit0_le {n m : ℕ} (h : n ≤ m) : bit0 n ≤ bit0 m :=
  add_le_add h h
#align nat.bit0_le Nat.bit0_le

protected theorem bit1_le {n m : ℕ} (h : n ≤ m) : bit1 n ≤ bit1 m :=
  succ_le_succ (add_le_add h h)
#align nat.bit1_le Nat.bit1_le

theorem bit_le : ∀ (b : Bool) {n m : ℕ}, n ≤ m → bit b n ≤ bit b m
  | tt, n, m, h => Nat.bit1_le h
  | ff, n, m, h => Nat.bit0_le h
#align nat.bit_le Nat.bit_le

theorem bit0_le_bit : ∀ (b) {m n : ℕ}, m ≤ n → bit0 m ≤ bit b n
  | tt, m, n, h => le_of_lt <| Nat.bit0_lt_bit1 h
  | ff, m, n, h => Nat.bit0_le h
#align nat.bit0_le_bit Nat.bit0_le_bit

theorem bit_le_bit1 : ∀ (b) {m n : ℕ}, m ≤ n → bit b m ≤ bit1 n
  | ff, m, n, h => le_of_lt <| Nat.bit0_lt_bit1 h
  | tt, m, n, h => Nat.bit1_le h
#align nat.bit_le_bit1 Nat.bit_le_bit1

theorem bit_lt_bit0 : ∀ (b) {n m : ℕ}, n < m → bit b n < bit0 m
  | tt, n, m, h => Nat.bit1_lt_bit0 h
  | ff, n, m, h => Nat.bit0_lt h
#align nat.bit_lt_bit0 Nat.bit_lt_bit0

theorem bit_lt_bit (a b) {n m : ℕ} (h : n < m) : bit a n < bit b m :=
  lt_of_lt_of_le (bit_lt_bit0 _ h) (bit0_le_bit _ le_rfl)
#align nat.bit_lt_bit Nat.bit_lt_bit

@[simp]
theorem bit0_le_bit1_iff : bit0 k ≤ bit1 n ↔ k ≤ n :=
  ⟨fun h => by rwa [← Nat.lt_succ_iff, n.bit1_eq_succ_bit0, ← n.bit0_succ_eq, bit0_lt_bit0, Nat.lt_succ_iff] at h,
    fun h => le_of_lt (Nat.bit0_lt_bit1 h)⟩
#align nat.bit0_le_bit1_iff Nat.bit0_le_bit1_iff

@[simp]
theorem bit0_lt_bit1_iff : bit0 k < bit1 n ↔ k ≤ n :=
  ⟨fun h => bit0_le_bit1_iff.1 (le_of_lt h), Nat.bit0_lt_bit1⟩
#align nat.bit0_lt_bit1_iff Nat.bit0_lt_bit1_iff

@[simp]
theorem bit1_le_bit0_iff : bit1 k ≤ bit0 n ↔ k < n :=
  ⟨fun h => by rwa [k.bit1_eq_succ_bit0, succ_le_iff, bit0_lt_bit0] at h, fun h => le_of_lt (Nat.bit1_lt_bit0 h)⟩
#align nat.bit1_le_bit0_iff Nat.bit1_le_bit0_iff

@[simp]
theorem bit1_lt_bit0_iff : bit1 k < bit0 n ↔ k < n :=
  ⟨fun h => bit1_le_bit0_iff.1 (le_of_lt h), Nat.bit1_lt_bit0⟩
#align nat.bit1_lt_bit0_iff Nat.bit1_lt_bit0_iff

@[simp]
theorem one_le_bit0_iff : 1 ≤ bit0 n ↔ 0 < n := by
  convert bit1_le_bit0_iff
  rfl
#align nat.one_le_bit0_iff Nat.one_le_bit0_iff

@[simp]
theorem one_lt_bit0_iff : 1 < bit0 n ↔ 1 ≤ n := by
  convert bit1_lt_bit0_iff
  rfl
#align nat.one_lt_bit0_iff Nat.one_lt_bit0_iff

@[simp]
theorem bit_le_bit_iff : ∀ {b : Bool}, bit b k ≤ bit b n ↔ k ≤ n
  | ff => bit0_le_bit0
  | tt => bit1_le_bit1
#align nat.bit_le_bit_iff Nat.bit_le_bit_iff

@[simp]
theorem bit_lt_bit_iff : ∀ {b : Bool}, bit b k < bit b n ↔ k < n
  | ff => bit0_lt_bit0
  | tt => bit1_lt_bit1
#align nat.bit_lt_bit_iff Nat.bit_lt_bit_iff

@[simp]
theorem bit_le_bit1_iff : ∀ {b : Bool}, bit b k ≤ bit1 n ↔ k ≤ n
  | ff => bit0_le_bit1_iff
  | tt => bit1_le_bit1
#align nat.bit_le_bit1_iff Nat.bit_le_bit1_iff

/-! ### decidability of predicates -/


instance decidableLoHi (lo hi : ℕ) (P : ℕ → Prop) [H : DecidablePred P] : Decidable (∀ x, lo ≤ x → x < hi → P x) :=
  decidable_of_iff (∀ x < hi - lo, P (lo + x))
    ⟨fun al x hl hh => by
      have := al (x - lo) ((tsub_lt_tsub_iff_right hl).mpr hh)
      rwa [add_tsub_cancel_of_le hl] at this, fun al x h => al _ (Nat.le_add_right _ _) (lt_tsub_iff_left.mp h)⟩
#align nat.decidable_lo_hi Nat.decidableLoHi

instance decidableLoHiLe (lo hi : ℕ) (P : ℕ → Prop) [H : DecidablePred P] : Decidable (∀ x, lo ≤ x → x ≤ hi → P x) :=
  decidable_of_iff (∀ x, lo ≤ x → x < hi + 1 → P x) <| ball_congr fun x hl => imp_congr lt_succ_iff Iff.rfl
#align nat.decidable_lo_hi_le Nat.decidableLoHiLe

end Nat

