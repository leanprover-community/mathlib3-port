import Mathbin.Data.Nat.Pow 
import Mathbin.Order.MinMax

/-!
# Basic operations on the integers

This file contains:
* instances on `ℤ`. The stronger one is `int.linear_ordered_comm_ring`.
* some basic lemmas about integers

## Recursors

* `int.rec`: Sign disjunction. Something is true/defined on `ℤ` if it's true/defined for nonnegative
  and for negative values.
* `int.bit_cases_on`: Parity disjunction. Something is true/defined on `ℤ` if it's true/defined for
  even and for odd values.
* `int.induction_on`: Simple growing induction on positive numbers, plus simple decreasing induction
  on negative numbers. Note that this recursor is currently only `Prop`-valued.
* `int.induction_on'`: Simple growing induction for numbers greater than `b`, plus simple decreasing
  induction on numbers less than `b`.
-/


open Nat

namespace Int

instance : Inhabited ℤ :=
  ⟨Int.zero⟩

instance : Nontrivial ℤ :=
  ⟨⟨0, 1, Int.zero_ne_one⟩⟩

instance : CommRingₓ Int :=
  { add := Int.add, add_assoc := Int.add_assoc, zero := Int.zero, zero_add := Int.zero_add, add_zero := Int.add_zero,
    neg := Int.neg, add_left_neg := Int.add_left_neg, add_comm := Int.add_comm, mul := Int.mul,
    mul_assoc := Int.mul_assoc, one := Int.one, one_mul := Int.one_mul, mul_one := Int.mul_one, sub := Int.sub,
    left_distrib := Int.distrib_left, right_distrib := Int.distrib_right, mul_comm := Int.mul_comm, zsmul := ·*·,
    zsmul_zero' := Int.zero_mul,
    zsmul_succ' :=
      fun n x =>
        by 
          rw [succ_eq_one_add, of_nat_add, Int.distrib_right, of_nat_one, Int.one_mul],
    zsmul_neg' := fun n x => neg_mul_eq_neg_mul_symm (n.succ : ℤ) x }

/-! ### Extra instances to short-circuit type class resolution

These also prevent non-computable instances like `int.normed_comm_ring` being used to construct
these instances non-computably.
-/


instance : AddCommMonoidₓ Int :=
  by 
    infer_instance

instance : AddMonoidₓ Int :=
  by 
    infer_instance

instance : Monoidₓ Int :=
  by 
    infer_instance

instance : CommMonoidₓ Int :=
  by 
    infer_instance

instance : CommSemigroupₓ Int :=
  by 
    infer_instance

instance : Semigroupₓ Int :=
  by 
    infer_instance

instance : AddCommGroupₓ Int :=
  by 
    infer_instance

instance : AddGroupₓ Int :=
  by 
    infer_instance

instance : AddCommSemigroupₓ Int :=
  by 
    infer_instance

instance : AddSemigroupₓ Int :=
  by 
    infer_instance

instance : CommSemiringₓ Int :=
  by 
    infer_instance

instance : Semiringₓ Int :=
  by 
    infer_instance

instance : Ringₓ Int :=
  by 
    infer_instance

instance : Distrib Int :=
  by 
    infer_instance

instance : LinearOrderedCommRing Int :=
  { Int.commRing, Int.linearOrder, Int.nontrivial with add_le_add_left := @Int.add_le_add_left, mul_pos := @Int.mul_pos,
    zero_le_one := le_of_ltₓ Int.zero_lt_one }

instance : LinearOrderedAddCommGroup Int :=
  by 
    infer_instance

@[simp]
theorem add_neg_one (i : ℤ) : (i+-1) = i - 1 :=
  rfl

theorem abs_eq_nat_abs : ∀ a : ℤ, |a| = nat_abs a
| (n : ℕ) => abs_of_nonneg$ coe_zero_le _
| -[1+ n] => abs_of_nonpos$ le_of_ltₓ$ neg_succ_lt_zero _

theorem nat_abs_abs (a : ℤ) : nat_abs |a| = nat_abs a :=
  by 
    rw [abs_eq_nat_abs] <;> rfl

theorem sign_mul_abs (a : ℤ) : (sign a*|a|) = a :=
  by 
    rw [abs_eq_nat_abs, sign_mul_nat_abs]

@[simp]
theorem default_eq_zero : default ℤ = 0 :=
  rfl

unsafe instance : has_to_format ℤ :=
  ⟨fun z => toString z⟩

unsafe instance : has_reflect ℤ :=
  by 
    runTac 
      tactic.mk_has_reflect_instance

attribute [simp] Int.coe_nat_add Int.coe_nat_mul Int.coe_nat_zero Int.coe_nat_one Int.coe_nat_succ

attribute [simp] Int.of_nat_eq_coe Int.bodd

@[simp]
theorem add_def {a b : ℤ} : Int.add a b = a+b :=
  rfl

@[simp]
theorem mul_def {a b : ℤ} : Int.mul a b = a*b :=
  rfl

@[simp]
theorem neg_succ_not_nonneg (n : ℕ) : 0 ≤ -[1+ n] ↔ False :=
  by 
    simp only [not_leₓ, iff_falseₓ]
    exact Int.neg_succ_lt_zero n

@[simp]
theorem neg_succ_not_pos (n : ℕ) : 0 < -[1+ n] ↔ False :=
  by 
    simp only [not_ltₓ, iff_falseₓ]

@[simp]
theorem neg_succ_sub_one (n : ℕ) : -[1+ n] - 1 = -[1+ n+1] :=
  rfl

@[simp]
theorem coe_nat_mul_neg_succ (m n : ℕ) : ((m : ℤ)*-[1+ n]) = -m*succ n :=
  rfl

@[simp]
theorem neg_succ_mul_coe_nat (m n : ℕ) : (-[1+ m]*n) = -succ m*n :=
  rfl

@[simp]
theorem neg_succ_mul_neg_succ (m n : ℕ) : (-[1+ m]*-[1+ n]) = succ m*succ n :=
  rfl

@[simp, normCast]
theorem coe_nat_le {m n : ℕ} : («expr↑ » m : ℤ) ≤ «expr↑ » n ↔ m ≤ n :=
  coe_nat_le_coe_nat_iff m n

@[simp, normCast]
theorem coe_nat_lt {m n : ℕ} : («expr↑ » m : ℤ) < «expr↑ » n ↔ m < n :=
  coe_nat_lt_coe_nat_iff m n

@[simp, normCast]
theorem coe_nat_inj' {m n : ℕ} : («expr↑ » m : ℤ) = «expr↑ » n ↔ m = n :=
  Int.coe_nat_eq_coe_nat_iff m n

@[simp]
theorem coe_nat_pos {n : ℕ} : (0 : ℤ) < n ↔ 0 < n :=
  by 
    rw [←Int.coe_nat_zero, coe_nat_lt]

@[simp]
theorem coe_nat_eq_zero {n : ℕ} : (n : ℤ) = 0 ↔ n = 0 :=
  by 
    rw [←Int.coe_nat_zero, coe_nat_inj']

theorem coe_nat_ne_zero {n : ℕ} : (n : ℤ) ≠ 0 ↔ n ≠ 0 :=
  not_congr coe_nat_eq_zero

@[simp]
theorem coe_nat_nonneg (n : ℕ) : 0 ≤ (n : ℤ) :=
  coe_nat_le.2 (Nat.zero_leₓ _)

theorem le_coe_nat_sub (m n : ℕ) : (m - n : ℤ) ≤ «expr↑ » (m - n : ℕ) :=
  by 
    byCases' h : m ≥ n
    ·
      exact le_of_eqₓ (Int.coe_nat_subₓ h).symm
    ·
      simp [le_of_not_geₓ h]

theorem coe_nat_ne_zero_iff_pos {n : ℕ} : (n : ℤ) ≠ 0 ↔ 0 < n :=
  ⟨fun h => Nat.pos_of_ne_zeroₓ (coe_nat_ne_zero.1 h), fun h => (ne_of_ltₓ (coe_nat_lt.2 h)).symm⟩

theorem coe_nat_succ_pos (n : ℕ) : 0 < (n.succ : ℤ) :=
  Int.coe_nat_pos.2 (succ_pos n)

@[simp, normCast]
theorem coe_nat_abs (n : ℕ) : |(n : ℤ)| = n :=
  abs_of_nonneg (coe_nat_nonneg n)

/-! ### succ and pred -/


/-- Immediate successor of an integer: `succ n = n + 1` -/
def succ (a : ℤ) :=
  a+1

/-- Immediate predecessor of an integer: `pred n = n - 1` -/
def pred (a : ℤ) :=
  a - 1

theorem nat_succ_eq_int_succ (n : ℕ) : (Nat.succ n : ℤ) = Int.succ n :=
  rfl

theorem pred_succ (a : ℤ) : pred (succ a) = a :=
  add_sub_cancel _ _

theorem succ_pred (a : ℤ) : succ (pred a) = a :=
  sub_add_cancel _ _

theorem neg_succ (a : ℤ) : -succ a = pred (-a) :=
  neg_add _ _

theorem succ_neg_succ (a : ℤ) : succ (-succ a) = -a :=
  by 
    rw [neg_succ, succ_pred]

theorem neg_pred (a : ℤ) : -pred a = succ (-a) :=
  by 
    rw [eq_neg_of_eq_neg (neg_succ (-a)).symm, neg_negₓ]

theorem pred_neg_pred (a : ℤ) : pred (-pred a) = -a :=
  by 
    rw [neg_pred, pred_succ]

theorem pred_nat_succ (n : ℕ) : pred (Nat.succ n) = n :=
  pred_succ n

theorem neg_nat_succ (n : ℕ) : -(Nat.succ n : ℤ) = pred (-n) :=
  neg_succ n

theorem succ_neg_nat_succ (n : ℕ) : succ (-Nat.succ n) = -n :=
  succ_neg_succ n

theorem lt_succ_self (a : ℤ) : a < succ a :=
  lt_add_of_pos_right _ zero_lt_one

theorem pred_self_lt (a : ℤ) : pred a < a :=
  sub_lt_self _ zero_lt_one

theorem add_one_le_iff {a b : ℤ} : (a+1) ≤ b ↔ a < b :=
  Iff.rfl

theorem lt_add_one_iff {a b : ℤ} : (a < b+1) ↔ a ≤ b :=
  add_le_add_iff_right _

@[simp]
theorem succ_coe_nat_pos (n : ℕ) : 0 < (n : ℤ)+1 :=
  lt_add_one_iff.mpr
    (by 
      simp )

@[normCast]
theorem coe_pred_of_pos {n : ℕ} (h : 0 < n) : ((n - 1 : ℕ) : ℤ) = (n : ℤ) - 1 :=
  by 
    cases n 
    cases h 
    simp 

theorem le_add_one {a b : ℤ} (h : a ≤ b) : a ≤ b+1 :=
  le_of_ltₓ (Int.lt_add_one_iff.mpr h)

theorem sub_one_lt_iff {a b : ℤ} : a - 1 < b ↔ a ≤ b :=
  sub_lt_iff_lt_add.trans lt_add_one_iff

theorem le_sub_one_iff {a b : ℤ} : a ≤ b - 1 ↔ a < b :=
  le_sub_iff_add_le

@[simp]
theorem eq_zero_iff_abs_lt_one {a : ℤ} : |a| < 1 ↔ a = 0 :=
  ⟨fun a0 =>
      let ⟨hn, hp⟩ := abs_lt.mp a0
      (le_of_lt_add_one
            (by 
              exact hp)).antisymm
        hn,
    fun a0 => (abs_eq_zero.mpr a0).le.trans_lt zero_lt_one⟩

-- error in Data.Int.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[elab_as_eliminator]
protected
theorem induction_on
{p : exprℤ() → exprProp()}
(i : exprℤ())
(hz : p 0)
(hp : ∀ i : exprℕ(), p i → p «expr + »(i, 1))
(hn : ∀ i : exprℕ(), p «expr- »(i) → p «expr - »(«expr- »(i), 1)) : p i :=
begin
  induction [expr i] [] [] [],
  { induction [expr i] [] [] [],
    { exact [expr hz] },
    { exact [expr hp _ i_ih] } },
  { have [] [":", expr ∀ n : exprℕ(), p «expr- »(n)] [],
    { intro [ident n],
      induction [expr n] [] [] [],
      { simp [] [] [] ["[", expr hz, "]"] [] [] },
      { convert [] [expr hn _ n_ih] ["using", 1],
        simp [] [] [] ["[", expr sub_eq_neg_add, "]"] [] [] } },
    exact [expr this «expr + »(i, 1)] }
end

/-- Inductively define a function on `ℤ` by defining it at `b`, for the `succ` of a number greater
  than `b`, and the `pred` of a number less than `b`. -/
protected def induction_on' {C : ℤ → Sort _} (z : ℤ) (b : ℤ) :
  C b → (∀ k, b ≤ k → C k → C (k+1)) → (∀ k _ : k ≤ b, C k → C (k - 1)) → C z :=
  fun H0 Hs Hp =>
    by 
      rw [←sub_add_cancel z b]
      induction' z - b with n n
      ·
        induction' n with n ih
        ·
          rwa [of_nat_zero, zero_addₓ]
        rw [of_nat_succ, add_assocₓ, add_commₓ 1 b, ←add_assocₓ]
        exact Hs _ (le_add_of_nonneg_left (of_nat_nonneg _)) ih
      ·
        induction' n with n ih
        ·
          rw [neg_succ_of_nat_eq, ←of_nat_eq_coe, of_nat_zero, zero_addₓ, neg_add_eq_sub]
          exact Hp _ (le_reflₓ _) H0
        ·
          rw [neg_succ_of_nat_coe', Nat.succ_eq_add_one, ←neg_succ_of_nat_coe, sub_add_eq_add_sub]
          exact Hp _ (le_of_ltₓ (add_lt_of_neg_of_le (neg_succ_lt_zero _) (le_reflₓ _))) ih

/-! ### nat abs -/


attribute [simp] nat_abs nat_abs_of_nat nat_abs_zero nat_abs_one

-- error in Data.Int.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem nat_abs_add_le (a b : exprℤ()) : «expr ≤ »(nat_abs «expr + »(a, b), «expr + »(nat_abs a, nat_abs b)) :=
begin
  have [] [":", expr ∀ a b : exprℕ(), «expr ≤ »(nat_abs (sub_nat_nat a (nat.succ b)), nat.succ «expr + »(a, b))] [],
  { refine [expr λ
     a
     b : exprℕ(), sub_nat_nat_elim a b.succ (λ
      m
      n
      i, «expr = »(n, b.succ) → «expr ≤ »(nat_abs i, «expr + »(m, b).succ)) _ _ rfl]; intros [ident i, ident n, ident e],
    { subst [expr e],
      rw ["[", expr add_comm _ i, ",", expr add_assoc, "]"] [],
      exact [expr nat.le_add_right i «expr + »(b.succ, b).succ] },
    { apply [expr succ_le_succ],
      rw ["[", "<-", expr succ.inj e, ",", "<-", expr add_assoc, ",", expr add_comm, "]"] [],
      apply [expr nat.le_add_right] } },
  cases [expr a] []; cases [expr b] ["with", ident b, ident b]; simp [] [] [] ["[", expr nat_abs, ",", expr nat.succ_add, "]"] [] []; try { refl }; [skip, rw [expr add_comm a b] []]; apply [expr this]
end

theorem nat_abs_sub_le (a b : ℤ) : nat_abs (a - b) ≤ nat_abs a+nat_abs b :=
  by 
    rw [sub_eq_add_neg, ←Int.nat_abs_neg b]
    apply nat_abs_add_le

theorem nat_abs_neg_of_nat (n : ℕ) : nat_abs (neg_of_nat n) = n :=
  by 
    cases n <;> rfl

theorem nat_abs_mul (a b : ℤ) : nat_abs (a*b) = nat_abs a*nat_abs b :=
  by 
    cases a <;> cases b <;> simp only [←Int.mul_def, Int.mul, nat_abs_neg_of_nat, eq_self_iff_true, Int.natAbs]

theorem nat_abs_mul_nat_abs_eq {a b : ℤ} {c : ℕ} (h : (a*b) = (c : ℤ)) : (a.nat_abs*b.nat_abs) = c :=
  by 
    rw [←nat_abs_mul, h, nat_abs_of_nat]

@[simp]
theorem nat_abs_mul_self' (a : ℤ) : (nat_abs a*nat_abs a : ℤ) = a*a :=
  by 
    rw [←Int.coe_nat_mul, nat_abs_mul_self]

theorem neg_succ_of_nat_eq' (m : ℕ) : -[1+ m] = -m - 1 :=
  by 
    simp [neg_succ_of_nat_eq, sub_eq_neg_add]

theorem nat_abs_ne_zero_of_ne_zero {z : ℤ} (hz : z ≠ 0) : z.nat_abs ≠ 0 :=
  fun h => hz$ Int.eq_zero_of_nat_abs_eq_zero h

@[simp]
theorem nat_abs_eq_zero {a : ℤ} : a.nat_abs = 0 ↔ a = 0 :=
  ⟨Int.eq_zero_of_nat_abs_eq_zero, fun h => h.symm ▸ rfl⟩

theorem nat_abs_ne_zero {a : ℤ} : a.nat_abs ≠ 0 ↔ a ≠ 0 :=
  not_congr Int.nat_abs_eq_zero

theorem nat_abs_lt_nat_abs_of_nonneg_of_lt {a b : ℤ} (w₁ : 0 ≤ a) (w₂ : a < b) : a.nat_abs < b.nat_abs :=
  by 
    lift b to ℕ using le_transₓ w₁ (le_of_ltₓ w₂)
    lift a to ℕ using w₁ 
    simpa using w₂

theorem nat_abs_eq_nat_abs_iff {a b : ℤ} : a.nat_abs = b.nat_abs ↔ a = b ∨ a = -b :=
  by 
    split  <;> intro h
    ·
      cases' Int.nat_abs_eq a with h₁ h₁ <;> cases' Int.nat_abs_eq b with h₂ h₂ <;> rw [h₁, h₂] <;> simp [h]
    ·
      cases h <;> rw [h]
      rw [Int.nat_abs_neg]

theorem nat_abs_eq_iff {a : ℤ} {n : ℕ} : a.nat_abs = n ↔ a = n ∨ a = -n :=
  by 
    rw [←Int.nat_abs_eq_nat_abs_iff, Int.nat_abs_of_nat]

theorem nat_abs_eq_iff_mul_self_eq {a b : ℤ} : a.nat_abs = b.nat_abs ↔ (a*a) = b*b :=
  by 
    rw [←abs_eq_iff_mul_self_eq, abs_eq_nat_abs, abs_eq_nat_abs]
    exact int.coe_nat_inj'.symm

theorem nat_abs_lt_iff_mul_self_lt {a b : ℤ} : a.nat_abs < b.nat_abs ↔ (a*a) < b*b :=
  by 
    rw [←abs_lt_iff_mul_self_lt, abs_eq_nat_abs, abs_eq_nat_abs]
    exact int.coe_nat_lt.symm

theorem nat_abs_le_iff_mul_self_le {a b : ℤ} : a.nat_abs ≤ b.nat_abs ↔ (a*a) ≤ b*b :=
  by 
    rw [←abs_le_iff_mul_self_le, abs_eq_nat_abs, abs_eq_nat_abs]
    exact int.coe_nat_le.symm

theorem nat_abs_eq_iff_sq_eq {a b : ℤ} : a.nat_abs = b.nat_abs ↔ a ^ 2 = b ^ 2 :=
  by 
    rw [sq, sq]
    exact nat_abs_eq_iff_mul_self_eq

theorem nat_abs_lt_iff_sq_lt {a b : ℤ} : a.nat_abs < b.nat_abs ↔ a ^ 2 < b ^ 2 :=
  by 
    rw [sq, sq]
    exact nat_abs_lt_iff_mul_self_lt

theorem nat_abs_le_iff_sq_le {a b : ℤ} : a.nat_abs ≤ b.nat_abs ↔ a ^ 2 ≤ b ^ 2 :=
  by 
    rw [sq, sq]
    exact nat_abs_le_iff_mul_self_le

@[simp]
theorem nat_abs_dvd_iff_dvd (a b : ℤ) : a.nat_abs ∣ b.nat_abs ↔ a ∣ b :=
  by 
    refine' ⟨_, fun ⟨k, hk⟩ => ⟨k.nat_abs, hk.symm ▸ nat_abs_mul a k⟩⟩
    rintro ⟨k, hk⟩
    rw [←nat_abs_of_nat k, ←nat_abs_mul, nat_abs_eq_nat_abs_iff, neg_mul_eq_mul_neg] at hk 
    cases hk <;> exact ⟨_, hk⟩

/-! ### `/`  -/


@[simp]
theorem of_nat_div (m n : ℕ) : of_nat (m / n) = of_nat m / of_nat n :=
  rfl

@[simp, normCast]
theorem coe_nat_div (m n : ℕ) : ((m / n : ℕ) : ℤ) = m / n :=
  rfl

theorem neg_succ_of_nat_div (m : ℕ) {b : ℤ} (H : 0 < b) : -[1+ m] / b = -(m / b)+1 :=
  match b, eq_succ_of_zero_lt H with 
  | _, ⟨n, rfl⟩ => rfl

@[local simp]
protected theorem zero_div : ∀ b : ℤ, 0 / b = 0
| 0 =>
  show of_nat _ = _ by 
    simp 
| (n+1 : ℕ) =>
  show of_nat _ = _ by 
    simp 
| -[1+ n] =>
  show -of_nat _ = _ by 
    simp 

@[local simp]
protected theorem div_zero : ∀ a : ℤ, a / 0 = 0
| 0 =>
  show of_nat _ = _ by 
    simp 
| (n+1 : ℕ) =>
  show of_nat _ = _ by 
    simp 
| -[1+ n] => rfl

@[simp]
protected theorem div_neg : ∀ a b : ℤ, a / -b = -(a / b)
| (m : ℕ), 0 =>
  show of_nat (m / 0) = -(m / 0 : ℕ)by 
    rw [Nat.div_zeroₓ] <;> rfl
| (m : ℕ), (n+1 : ℕ) => rfl
| 0, -[1+ n] =>
  by 
    simp 
| (m+1 : ℕ), -[1+ n] => (neg_negₓ _).symm
| -[1+ m], 0 => rfl
| -[1+ m], (n+1 : ℕ) => rfl
| -[1+ m], -[1+ n] => rfl

theorem div_of_neg_of_pos {a b : ℤ} (Ha : a < 0) (Hb : 0 < b) : a / b = -((-a - 1) / b)+1 :=
  match a, b, eq_neg_succ_of_lt_zero Ha, eq_succ_of_zero_lt Hb with 
  | _, _, ⟨m, rfl⟩, ⟨n, rfl⟩ =>
    by 
      change (- -[1+ m] : ℤ) with (m+1 : ℤ) <;> rw [add_sub_cancel] <;> rfl

protected theorem div_nonneg {a b : ℤ} (Ha : 0 ≤ a) (Hb : 0 ≤ b) : 0 ≤ a / b :=
  match a, b, eq_coe_of_zero_le Ha, eq_coe_of_zero_le Hb with 
  | _, _, ⟨m, rfl⟩, ⟨n, rfl⟩ => coe_zero_le _

protected theorem div_nonpos {a b : ℤ} (Ha : 0 ≤ a) (Hb : b ≤ 0) : a / b ≤ 0 :=
  nonpos_of_neg_nonneg$
    by 
      rw [←Int.div_neg] <;> exact Int.div_nonneg Ha (neg_nonneg_of_nonpos Hb)

theorem div_neg' {a b : ℤ} (Ha : a < 0) (Hb : 0 < b) : a / b < 0 :=
  match a, b, eq_neg_succ_of_lt_zero Ha, eq_succ_of_zero_lt Hb with 
  | _, _, ⟨m, rfl⟩, ⟨n, rfl⟩ => neg_succ_lt_zero _

@[simp]
protected theorem div_one : ∀ a : ℤ, a / 1 = a
| 0 =>
  show of_nat _ = _ by 
    simp 
| (n+1 : ℕ) => congr_argₓ of_nat (Nat.div_oneₓ _)
| -[1+ n] => congr_argₓ neg_succ_of_nat (Nat.div_oneₓ _)

theorem div_eq_zero_of_lt {a b : ℤ} (H1 : 0 ≤ a) (H2 : a < b) : a / b = 0 :=
  match a, b, eq_coe_of_zero_le H1, eq_succ_of_zero_lt (lt_of_le_of_ltₓ H1 H2), H2 with 
  | _, _, ⟨m, rfl⟩, ⟨n, rfl⟩, H2 => congr_argₓ of_nat$ Nat.div_eq_of_ltₓ$ lt_of_coe_nat_lt_coe_nat H2

theorem div_eq_zero_of_lt_abs {a b : ℤ} (H1 : 0 ≤ a) (H2 : a < |b|) : a / b = 0 :=
  match b, |b|, abs_eq_nat_abs b, H2 with 
  | (n : ℕ), _, rfl, H2 => div_eq_zero_of_lt H1 H2
  | -[1+ n], _, rfl, H2 =>
    neg_injective$
      by 
        rw [←Int.div_neg] <;> exact div_eq_zero_of_lt H1 H2

protected theorem add_mul_div_right (a b : ℤ) {c : ℤ} (H : c ≠ 0) : (a+b*c) / c = (a / c)+b :=
  have  : ∀ {k n : ℕ} {a : ℤ}, (a+n*k.succ) / k.succ = (a / k.succ)+n :=
    fun k n a =>
      match a with 
      | (m : ℕ) => congr_argₓ of_nat$ Nat.add_mul_div_rightₓ _ _ k.succ_pos
      | -[1+ m] =>
        show ((n*k.succ : ℕ) - m.succ : ℤ) / k.succ = n - ((m / k.succ)+1 : ℕ)by 
          cases' lt_or_geₓ m (n*k.succ) with h h
          ·
            rw [←Int.coe_nat_subₓ h, ←Int.coe_nat_subₓ ((Nat.div_lt_iff_lt_mulₓ _ _ k.succ_pos).2 h)]
            apply congr_argₓ of_nat 
            rw [mul_commₓ, Nat.mul_sub_divₓ]
            rwa [mul_commₓ]
          ·
            change («expr↑ » (n*Nat.succ k) - m+1 : ℤ) / «expr↑ » (Nat.succ k) = «expr↑ » n - (m / Nat.succ k : ℕ)+1
            rw [←sub_sub, ←sub_sub, ←neg_sub (m : ℤ), ←neg_sub _ (n : ℤ), ←Int.coe_nat_subₓ h,
              ←Int.coe_nat_subₓ ((Nat.le_div_iff_mul_leₓ _ _ k.succ_pos).2 h), ←neg_succ_of_nat_coe',
              ←neg_succ_of_nat_coe']
            ·
              apply congr_argₓ neg_succ_of_nat 
              rw [mul_commₓ, Nat.sub_mul_divₓ]
              rwa [mul_commₓ]
  have  : ∀ {a b c : ℤ}, 0 < c → (a+b*c) / c = (a / c)+b :=
    fun a b c H =>
      match c, eq_succ_of_zero_lt H, b with 
      | _, ⟨k, rfl⟩, (n : ℕ) => this
      | _, ⟨k, rfl⟩, -[1+ n] =>
        show (a - n.succ*k.succ) / k.succ = a / k.succ - n.succ from
          eq_sub_of_add_eq$
            by 
              rw [←this, sub_add_cancel]
  match lt_trichotomyₓ c 0 with 
  | Or.inl hlt =>
    neg_inj.1$
      by 
        rw [←Int.div_neg, neg_add, ←Int.div_neg, ←neg_mul_neg] <;> apply this (neg_pos_of_neg hlt)
  | Or.inr (Or.inl HEq) => absurd HEq H
  | Or.inr (Or.inr hgt) => this hgt

protected theorem add_mul_div_left (a : ℤ) {b : ℤ} (c : ℤ) (H : b ≠ 0) : (a+b*c) / b = (a / b)+c :=
  by 
    rw [mul_commₓ, Int.add_mul_div_right _ _ H]

protected theorem add_div_of_dvd_right {a b c : ℤ} (H : c ∣ b) : (a+b) / c = (a / c)+b / c :=
  by 
    byCases' h1 : c = 0
    ·
      simp [h1]
    cases' H with k hk 
    rw [hk]
    change c ≠ 0 at h1 
    rw [mul_commₓ c k, Int.add_mul_div_right _ _ h1, ←zero_addₓ (k*c), Int.add_mul_div_right _ _ h1, Int.zero_div,
      zero_addₓ]

protected theorem add_div_of_dvd_left {a b c : ℤ} (H : c ∣ a) : (a+b) / c = (a / c)+b / c :=
  by 
    rw [add_commₓ, Int.add_div_of_dvd_right H, add_commₓ]

-- error in Data.Int.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
protected
theorem mul_div_cancel
(a : exprℤ())
{b : exprℤ()}
(H : «expr ≠ »(b, 0)) : «expr = »(«expr / »(«expr * »(a, b), b), a) :=
by have [] [] [":=", expr int.add_mul_div_right 0 a H]; rwa ["[", expr zero_add, ",", expr int.zero_div, ",", expr zero_add, "]"] ["at", ident this]

@[simp]
protected theorem mul_div_cancel_left {a : ℤ} (b : ℤ) (H : a ≠ 0) : (a*b) / a = b :=
  by 
    rw [mul_commₓ, Int.mul_div_cancel _ H]

-- error in Data.Int.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp] protected theorem div_self {a : exprℤ()} (H : «expr ≠ »(a, 0)) : «expr = »(«expr / »(a, a), 1) :=
by have [] [] [":=", expr int.mul_div_cancel 1 H]; rwa [expr one_mul] ["at", ident this]

/-! ### mod -/


theorem of_nat_mod (m n : Nat) : (m % n : ℤ) = of_nat (m % n) :=
  rfl

@[simp, normCast]
theorem coe_nat_mod (m n : ℕ) : («expr↑ » (m % n) : ℤ) = «expr↑ » m % «expr↑ » n :=
  rfl

theorem neg_succ_of_nat_mod (m : ℕ) {b : ℤ} (bpos : 0 < b) : -[1+ m] % b = b - 1 - m % b :=
  by 
    rw [sub_sub, add_commₓ] <;>
      exact
        match b, eq_succ_of_zero_lt bpos with 
        | _, ⟨n, rfl⟩ => rfl

@[simp]
theorem mod_neg : ∀ a b : ℤ, a % -b = a % b
| (m : ℕ), n => @congr_argₓ ℕ ℤ _ _ (fun i => «expr↑ » (m % i)) (nat_abs_neg _)
| -[1+ m], n => @congr_argₓ ℕ ℤ _ _ (fun i => sub_nat_nat i (Nat.succ (m % i))) (nat_abs_neg _)

@[simp]
theorem mod_abs (a b : ℤ) : a % |b| = a % b :=
  abs_by_cases (fun i => a % i = a % b) rfl (mod_neg _ _)

@[local simp]
theorem zero_mod (b : ℤ) : 0 % b = 0 :=
  rfl

@[local simp]
theorem mod_zero : ∀ a : ℤ, a % 0 = a
| (m : ℕ) => congr_argₓ of_nat$ Nat.mod_zeroₓ _
| -[1+ m] => congr_argₓ neg_succ_of_nat$ Nat.mod_zeroₓ _

@[local simp]
theorem mod_one : ∀ a : ℤ, a % 1 = 0
| (m : ℕ) => congr_argₓ of_nat$ Nat.mod_oneₓ _
| -[1+ m] =>
  show (1 - (m % 1).succ : ℤ) = 0 by 
    rw [Nat.mod_oneₓ] <;> rfl

theorem mod_eq_of_lt {a b : ℤ} (H1 : 0 ≤ a) (H2 : a < b) : a % b = a :=
  match a, b, eq_coe_of_zero_le H1, eq_coe_of_zero_le (le_transₓ H1 (le_of_ltₓ H2)), H2 with 
  | _, _, ⟨m, rfl⟩, ⟨n, rfl⟩, H2 => congr_argₓ of_nat$ Nat.mod_eq_of_ltₓ (lt_of_coe_nat_lt_coe_nat H2)

theorem mod_nonneg : ∀ a : ℤ {b : ℤ}, b ≠ 0 → 0 ≤ a % b
| (m : ℕ), n, H => coe_zero_le _
| -[1+ m], n, H => sub_nonneg_of_le$ coe_nat_le_coe_nat_of_le$ Nat.mod_ltₓ _ (nat_abs_pos_of_ne_zero H)

theorem mod_lt_of_pos (a : ℤ) {b : ℤ} (H : 0 < b) : a % b < b :=
  match a, b, eq_succ_of_zero_lt H with 
  | (m : ℕ), _, ⟨n, rfl⟩ => coe_nat_lt_coe_nat_of_lt (Nat.mod_ltₓ _ (Nat.succ_posₓ _))
  | -[1+ m], _, ⟨n, rfl⟩ => sub_lt_self _ (coe_nat_lt_coe_nat_of_lt$ Nat.succ_posₓ _)

theorem mod_lt (a : ℤ) {b : ℤ} (H : b ≠ 0) : a % b < |b| :=
  by 
    rw [←mod_abs] <;> exact mod_lt_of_pos _ (abs_pos.2 H)

theorem mod_add_div_aux (m n : ℕ) : ((n - (m % n)+1) - (n*m / n)+n : ℤ) = -[1+ m] :=
  by 
    rw [←sub_sub, neg_succ_of_nat_coe, sub_sub (n : ℤ)]
    apply eq_neg_of_eq_neg 
    rw [neg_sub, sub_sub_self, add_right_commₓ]
    exact @congr_argₓ ℕ ℤ _ _ (fun i => (i+1 : ℤ)) (Nat.mod_add_divₓ _ _).symm

theorem mod_add_div : ∀ a b : ℤ, ((a % b)+b*a / b) = a
| (m : ℕ), 0 => congr_argₓ of_nat (Nat.mod_add_divₓ _ _)
| (m : ℕ), (n+1 : ℕ) => congr_argₓ of_nat (Nat.mod_add_divₓ _ _)
| 0, -[1+ n] =>
  by 
    simp 
| (m+1 : ℕ), -[1+ n] =>
  show (_+(-n+1)*-((m+1) / n+1 : ℕ) : ℤ) = _ by 
    rw [neg_mul_neg] <;> exact congr_argₓ of_nat (Nat.mod_add_divₓ _ _)
| -[1+ m], 0 =>
  by 
    rw [mod_zero, Int.div_zero] <;> rfl
| -[1+ m], (n+1 : ℕ) => mod_add_div_aux m n.succ
| -[1+ m], -[1+ n] => mod_add_div_aux m n.succ

theorem div_add_mod (a b : ℤ) : ((b*a / b)+a % b) = a :=
  (add_commₓ _ _).trans (mod_add_div _ _)

theorem mod_add_div' (m k : ℤ) : ((m % k)+(m / k)*k) = m :=
  by 
    rw [mul_commₓ]
    exact mod_add_div _ _

theorem div_add_mod' (m k : ℤ) : (((m / k)*k)+m % k) = m :=
  by 
    rw [mul_commₓ]
    exact div_add_mod _ _

theorem mod_def (a b : ℤ) : a % b = a - b*a / b :=
  eq_sub_of_add_eq (mod_add_div _ _)

@[simp]
theorem add_mul_mod_self {a b c : ℤ} : (a+b*c) % c = a % c :=
  if cz : c = 0 then
    by 
      rw [cz, mul_zero, add_zeroₓ]
  else
    by 
      rw [mod_def, mod_def, Int.add_mul_div_right _ _ cz, mul_addₓ, mul_commₓ, add_sub_add_right_eq_sub]

@[simp]
theorem add_mul_mod_self_left (a b c : ℤ) : (a+b*c) % b = a % b :=
  by 
    rw [mul_commₓ, add_mul_mod_self]

-- error in Data.Int.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp] theorem add_mod_self {a b : exprℤ()} : «expr = »(«expr % »(«expr + »(a, b), b), «expr % »(a, b)) :=
by have [] [] [":=", expr add_mul_mod_self_left a b 1]; rwa [expr mul_one] ["at", ident this]

@[simp]
theorem add_mod_self_left {a b : ℤ} : (a+b) % a = b % a :=
  by 
    rw [add_commₓ, add_mod_self]

-- error in Data.Int.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
@[simp]
theorem mod_add_mod
(m n k : exprℤ()) : «expr = »(«expr % »(«expr + »(«expr % »(m, n), k), n), «expr % »(«expr + »(m, k), n)) :=
by have [] [] [":=", expr (add_mul_mod_self_left «expr + »(«expr % »(m, n), k) n «expr / »(m, n)).symm]; rwa ["[", expr add_right_comm, ",", expr mod_add_div, "]"] ["at", ident this]

@[simp]
theorem add_mod_mod (m n k : ℤ) : (m+n % k) % k = (m+n) % k :=
  by 
    rw [add_commₓ, mod_add_mod, add_commₓ]

theorem add_mod (a b n : ℤ) : (a+b) % n = ((a % n)+b % n) % n :=
  by 
    rw [add_mod_mod, mod_add_mod]

theorem add_mod_eq_add_mod_right {m n k : ℤ} (i : ℤ) (H : m % n = k % n) : (m+i) % n = (k+i) % n :=
  by 
    rw [←mod_add_mod, ←mod_add_mod k, H]

theorem add_mod_eq_add_mod_left {m n k : ℤ} (i : ℤ) (H : m % n = k % n) : (i+m) % n = (i+k) % n :=
  by 
    rw [add_commₓ, add_mod_eq_add_mod_right _ H, add_commₓ]

-- error in Data.Int.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem mod_add_cancel_right
{m n k : exprℤ()}
(i) : «expr ↔ »(«expr = »(«expr % »(«expr + »(m, i), n), «expr % »(«expr + »(k, i), n)), «expr = »(«expr % »(m, n), «expr % »(k, n))) :=
⟨λ
 H, by have [] [] [":=", expr add_mod_eq_add_mod_right «expr- »(i) H]; rwa ["[", expr add_neg_cancel_right, ",", expr add_neg_cancel_right, "]"] ["at", ident this], add_mod_eq_add_mod_right _⟩

theorem mod_add_cancel_left {m n k i : ℤ} : (i+m) % n = (i+k) % n ↔ m % n = k % n :=
  by 
    rw [add_commₓ, add_commₓ i, mod_add_cancel_right]

theorem mod_sub_cancel_right {m n k : ℤ} i : (m - i) % n = (k - i) % n ↔ m % n = k % n :=
  mod_add_cancel_right _

theorem mod_eq_mod_iff_mod_sub_eq_zero {m n k : ℤ} : m % n = k % n ↔ (m - k) % n = 0 :=
  (mod_sub_cancel_right k).symm.trans$
    by 
      simp 

@[simp]
theorem mul_mod_left (a b : ℤ) : (a*b) % b = 0 :=
  by 
    rw [←zero_addₓ (a*b), add_mul_mod_self, zero_mod]

@[simp]
theorem mul_mod_right (a b : ℤ) : (a*b) % a = 0 :=
  by 
    rw [mul_commₓ, mul_mod_left]

theorem mul_mod (a b n : ℤ) : (a*b) % n = ((a % n)*b % n) % n :=
  by 
    convLHS =>
      rw [←mod_add_div a n, ←mod_add_div' b n, right_distrib, left_distrib, left_distrib, mul_assocₓ, mul_assocₓ,
        ←left_distrib n _ _, add_mul_mod_self_left, ←mul_assocₓ, add_mul_mod_self]

@[simp]
theorem neg_mod_two (i : ℤ) : -i % 2 = i % 2 :=
  by 
    apply int.mod_eq_mod_iff_mod_sub_eq_zero.mpr 
    convert Int.mul_mod_right 2 (-i)
    simp only [two_mul, sub_eq_add_neg]

-- error in Data.Int.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
local attribute [simp] theorem mod_self {a : exprℤ()} : «expr = »(«expr % »(a, a), 0) :=
by have [] [] [":=", expr mul_mod_left 1 a]; rwa [expr one_mul] ["at", ident this]

@[simp]
theorem mod_mod_of_dvd (n : ℤ) {m k : ℤ} (h : m ∣ k) : n % k % m = n % m :=
  by 
    conv  => toRHS rw [←mod_add_div n k]
    rcases h with ⟨t, rfl⟩
    rw [mul_assocₓ, add_mul_mod_self_left]

@[simp]
theorem mod_mod (a b : ℤ) : a % b % b = a % b :=
  by 
    conv  => toRHS rw [←mod_add_div a b, add_mul_mod_self_left]

theorem sub_mod (a b n : ℤ) : (a - b) % n = (a % n - b % n) % n :=
  by 
    apply (mod_add_cancel_right b).mp 
    rw [sub_add_cancel, ←add_mod_mod, sub_add_cancel, mod_mod]

/-! ### properties of `/` and `%` -/


@[simp]
theorem mul_div_mul_of_pos {a : ℤ} (b c : ℤ) (H : 0 < a) : ((a*b) / a*c) = b / c :=
  suffices ∀ m k : ℕ b : ℤ, ((m.succ*b) / m.succ*k : ℤ) = b / k from
    match a, eq_succ_of_zero_lt H, c, eq_coe_or_neg c with 
    | _, ⟨m, rfl⟩, _, ⟨k, Or.inl rfl⟩ => this _ _ _
    | _, ⟨m, rfl⟩, _, ⟨k, Or.inr rfl⟩ =>
      by 
        rw [←neg_mul_eq_mul_neg, Int.div_neg, Int.div_neg] <;> apply congr_argₓ Neg.neg <;> apply this 
  fun m k b =>
    match b, k with 
    | (n : ℕ), k => congr_argₓ of_nat (Nat.mul_div_mulₓ _ _ m.succ_pos)
    | -[1+ n], 0 =>
      by 
        rw [Int.coe_nat_zero, mul_zero, Int.div_zero, Int.div_zero]
    | -[1+ n], k+1 =>
      congr_argₓ neg_succ_of_nat$
        show (((m.succ*n)+m) / m.succ*k.succ) = n / k.succ by 
          apply Nat.div_eq_of_lt_leₓ
          ·
            refine' le_transₓ _ (Nat.le_add_rightₓ _ _)
            rw [←Nat.mul_div_mulₓ _ _ m.succ_pos]
            apply Nat.div_mul_le_selfₓ
          ·
            change (m.succ*n.succ) ≤ _ 
            rw [mul_left_commₓ]
            apply Nat.mul_le_mul_leftₓ 
            apply (Nat.div_lt_iff_lt_mulₓ _ _ k.succ_pos).1
            apply Nat.lt_succ_selfₓ

@[simp]
theorem mul_div_mul_of_pos_left (a : ℤ) {b : ℤ} (H : 0 < b) (c : ℤ) : ((a*b) / c*b) = a / c :=
  by 
    rw [mul_commₓ, mul_commₓ c, mul_div_mul_of_pos _ _ H]

@[simp]
theorem mul_mod_mul_of_pos {a : ℤ} (H : 0 < a) (b c : ℤ) : ((a*b) % a*c) = a*b % c :=
  by 
    rw [mod_def, mod_def, mul_div_mul_of_pos _ _ H, mul_sub_left_distrib, mul_assocₓ]

theorem lt_div_add_one_mul_self (a : ℤ) {b : ℤ} (H : 0 < b) : a < ((a / b)+1)*b :=
  by 
    rw [add_mulₓ, one_mulₓ, mul_commₓ, ←sub_lt_iff_lt_add', ←mod_def]
    exact mod_lt_of_pos _ H

theorem abs_div_le_abs : ∀ a b : ℤ, |a / b| ≤ |a| :=
  suffices ∀ a : ℤ n : ℕ, |a / n| ≤ |a| from
    fun a b =>
      match b, eq_coe_or_neg b with 
      | _, ⟨n, Or.inl rfl⟩ => this _ _
      | _, ⟨n, Or.inr rfl⟩ =>
        by 
          rw [Int.div_neg, abs_neg] <;> apply this 
  fun a n =>
    by 
      rw [abs_eq_nat_abs, abs_eq_nat_abs] <;>
        exact
          coe_nat_le_coe_nat_of_le
            (match a, n with 
            | (m : ℕ), n => Nat.div_le_selfₓ _ _
            | -[1+ m], 0 => Nat.zero_leₓ _
            | -[1+ m], n+1 => Nat.succ_le_succₓ (Nat.div_le_selfₓ _ _))

-- error in Data.Int.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem div_le_self {a : exprℤ()} (b : exprℤ()) (Ha : «expr ≤ »(0, a)) : «expr ≤ »(«expr / »(a, b), a) :=
by have [] [] [":=", expr le_trans (le_abs_self _) (abs_div_le_abs a b)]; rwa ["[", expr abs_of_nonneg Ha, "]"] ["at", ident this]

-- error in Data.Int.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem mul_div_cancel_of_mod_eq_zero
{a b : exprℤ()}
(H : «expr = »(«expr % »(a, b), 0)) : «expr = »(«expr * »(b, «expr / »(a, b)), a) :=
by have [] [] [":=", expr mod_add_div a b]; rwa ["[", expr H, ",", expr zero_add, "]"] ["at", ident this]

theorem div_mul_cancel_of_mod_eq_zero {a b : ℤ} (H : a % b = 0) : ((a / b)*b) = a :=
  by 
    rw [mul_commₓ, mul_div_cancel_of_mod_eq_zero H]

theorem mod_two_eq_zero_or_one (n : ℤ) : n % 2 = 0 ∨ n % 2 = 1 :=
  have h : n % 2 < 2 :=
    abs_of_nonneg
        (show 0 ≤ (2 : ℤ) from
          by 
            decide) ▸
      Int.mod_lt _
        (by 
          decide)
  have h₁ : 0 ≤ n % 2 :=
    Int.mod_nonneg _
      (by 
        decide)
  match n % 2, h, h₁ with 
  | (0 : ℕ) => fun _ _ => Or.inl rfl
  | (1 : ℕ) => fun _ _ => Or.inr rfl
  | (k+2 : ℕ) =>
    fun h _ =>
      absurd h
        (by 
          decide)
  | -[1+ a] =>
    fun _ h₁ =>
      absurd h₁
        (by 
          decide)

/-! ### dvd -/


@[normCast]
theorem coe_nat_dvd {m n : ℕ} : («expr↑ » m : ℤ) ∣ «expr↑ » n ↔ m ∣ n :=
  ⟨fun ⟨a, ae⟩ =>
      m.eq_zero_or_pos.elim
        (fun m0 =>
          by 
            simp [m0] at ae <;> simp [ae, m0])
        fun m0l =>
          by 
            cases'
              eq_coe_of_zero_le
                (@nonneg_of_mul_nonneg_left ℤ _ m a
                  (by 
                    simp [ae.symm])
                  (by 
                    simpa using m0l)) with
              k e 
            subst a 
            exact ⟨k, Int.coe_nat_inj ae⟩,
    fun ⟨k, e⟩ =>
      Dvd.intro k$
        by 
          rw [e, Int.coe_nat_mul]⟩

theorem coe_nat_dvd_left {n : ℕ} {z : ℤ} : («expr↑ » n : ℤ) ∣ z ↔ n ∣ z.nat_abs :=
  by 
    rcases nat_abs_eq z with (eq | eq) <;> rw [Eq] <;> simp [coe_nat_dvd]

theorem coe_nat_dvd_right {n : ℕ} {z : ℤ} : z ∣ («expr↑ » n : ℤ) ↔ z.nat_abs ∣ n :=
  by 
    rcases nat_abs_eq z with (eq | eq) <;> rw [Eq] <;> simp [coe_nat_dvd]

theorem dvd_antisymm {a b : ℤ} (H1 : 0 ≤ a) (H2 : 0 ≤ b) : a ∣ b → b ∣ a → a = b :=
  by 
    rw [←abs_of_nonneg H1, ←abs_of_nonneg H2, abs_eq_nat_abs, abs_eq_nat_abs]
    rw [coe_nat_dvd, coe_nat_dvd, coe_nat_inj']
    apply Nat.dvd_antisymm

theorem dvd_of_mod_eq_zero {a b : ℤ} (H : b % a = 0) : a ∣ b :=
  ⟨b / a, (mul_div_cancel_of_mod_eq_zero H).symm⟩

theorem mod_eq_zero_of_dvd : ∀ {a b : ℤ}, a ∣ b → b % a = 0
| a, _, ⟨c, rfl⟩ => mul_mod_right _ _

theorem dvd_iff_mod_eq_zero (a b : ℤ) : a ∣ b ↔ b % a = 0 :=
  ⟨mod_eq_zero_of_dvd, dvd_of_mod_eq_zero⟩

-- error in Data.Int.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If `a % b = c` then `b` divides `a - c`. -/
theorem dvd_sub_of_mod_eq {a b c : exprℤ()} (h : «expr = »(«expr % »(a, b), c)) : «expr ∣ »(b, «expr - »(a, c)) :=
begin
  have [ident hx] [":", expr «expr = »(«expr % »(«expr % »(a, b), b), «expr % »(c, b))] [],
  { rw [expr h] [] },
  rw ["[", expr mod_mod, ",", "<-", expr mod_sub_cancel_right c, ",", expr sub_self, ",", expr zero_mod, "]"] ["at", ident hx],
  exact [expr dvd_of_mod_eq_zero hx]
end

theorem nat_abs_dvd {a b : ℤ} : (a.nat_abs : ℤ) ∣ b ↔ a ∣ b :=
  (nat_abs_eq a).elim
    (fun e =>
      by 
        rw [←e])
    fun e =>
      by 
        rw [←neg_dvd, ←e]

theorem dvd_nat_abs {a b : ℤ} : a ∣ b.nat_abs ↔ a ∣ b :=
  (nat_abs_eq b).elim
    (fun e =>
      by 
        rw [←e])
    fun e =>
      by 
        rw [←dvd_neg, ←e]

instance decidable_dvd : @DecidableRel ℤ (· ∣ ·) :=
  fun a n =>
    decidableOfDecidableOfIff
      (by 
        infer_instance)
      (dvd_iff_mod_eq_zero _ _).symm

protected theorem div_mul_cancel {a b : ℤ} (H : b ∣ a) : ((a / b)*b) = a :=
  div_mul_cancel_of_mod_eq_zero (mod_eq_zero_of_dvd H)

protected theorem mul_div_cancel' {a b : ℤ} (H : a ∣ b) : (a*b / a) = b :=
  by 
    rw [mul_commₓ, Int.div_mul_cancel H]

protected theorem mul_div_assoc (a : ℤ) : ∀ {b c : ℤ}, c ∣ b → (a*b) / c = a*b / c
| _, c, ⟨d, rfl⟩ =>
  if cz : c = 0 then
    by 
      simp [cz]
  else
    by 
      rw [mul_left_commₓ, Int.mul_div_cancel_left _ cz, Int.mul_div_cancel_left _ cz]

protected theorem mul_div_assoc' (b : ℤ) {a c : ℤ} (h : c ∣ a) : (a*b) / c = (a / c)*b :=
  by 
    rw [mul_commₓ, Int.mul_div_assoc _ h, mul_commₓ]

theorem div_dvd_div : ∀ {a b c : ℤ} H1 : a ∣ b H2 : b ∣ c, b / a ∣ c / a
| a, _, _, ⟨b, rfl⟩, ⟨c, rfl⟩ =>
  if az : a = 0 then
    by 
      simp [az]
  else
    by 
      rw [Int.mul_div_cancel_left _ az, mul_assocₓ, Int.mul_div_cancel_left _ az] <;> apply dvd_mul_right

protected theorem eq_mul_of_div_eq_right {a b c : ℤ} (H1 : b ∣ a) (H2 : a / b = c) : a = b*c :=
  by 
    rw [←H2, Int.mul_div_cancel' H1]

protected theorem div_eq_of_eq_mul_right {a b c : ℤ} (H1 : b ≠ 0) (H2 : a = b*c) : a / b = c :=
  by 
    rw [H2, Int.mul_div_cancel_left _ H1]

protected theorem eq_div_of_mul_eq_right {a b c : ℤ} (H1 : a ≠ 0) (H2 : (a*b) = c) : b = c / a :=
  Eq.symm$ Int.div_eq_of_eq_mul_right H1 H2.symm

protected theorem div_eq_iff_eq_mul_right {a b c : ℤ} (H : b ≠ 0) (H' : b ∣ a) : a / b = c ↔ a = b*c :=
  ⟨Int.eq_mul_of_div_eq_right H', Int.div_eq_of_eq_mul_right H⟩

protected theorem div_eq_iff_eq_mul_left {a b c : ℤ} (H : b ≠ 0) (H' : b ∣ a) : a / b = c ↔ a = c*b :=
  by 
    rw [mul_commₓ] <;> exact Int.div_eq_iff_eq_mul_right H H'

protected theorem eq_mul_of_div_eq_left {a b c : ℤ} (H1 : b ∣ a) (H2 : a / b = c) : a = c*b :=
  by 
    rw [mul_commₓ, Int.eq_mul_of_div_eq_right H1 H2]

protected theorem div_eq_of_eq_mul_left {a b c : ℤ} (H1 : b ≠ 0) (H2 : a = c*b) : a / b = c :=
  Int.div_eq_of_eq_mul_right H1
    (by 
      rw [mul_commₓ, H2])

protected theorem eq_zero_of_div_eq_zero {d n : ℤ} (h : d ∣ n) (H : n / d = 0) : n = 0 :=
  by 
    rw [←Int.mul_div_cancel' h, H, mul_zero]

theorem neg_div_of_dvd : ∀ {a b : ℤ} H : b ∣ a, -a / b = -(a / b)
| _, b, ⟨c, rfl⟩ =>
  if bz : b = 0 then
    by 
      simp [bz]
  else
    by 
      rw [neg_mul_eq_mul_neg, Int.mul_div_cancel_left _ bz, Int.mul_div_cancel_left _ bz]

theorem sub_div_of_dvd (a : ℤ) {b c : ℤ} (hcb : c ∣ b) : (a - b) / c = a / c - b / c :=
  by 
    rw [sub_eq_add_neg, sub_eq_add_neg, Int.add_div_of_dvd_right ((dvd_neg c b).mpr hcb)]
    congr 
    exact neg_div_of_dvd hcb

theorem sub_div_of_dvd_sub {a b c : ℤ} (hcab : c ∣ a - b) : (a - b) / c = a / c - b / c :=
  by 
    rw [eq_sub_iff_add_eq, ←Int.add_div_of_dvd_left hcab, sub_add_cancel]

theorem div_sign : ∀ a b, a / sign b = a*sign b
| a, (n+1 : ℕ) =>
  by 
    unfold sign <;> simp 
| a, 0 =>
  by 
    simp [sign]
| a, -[1+ n] =>
  by 
    simp [sign]

@[simp]
theorem sign_mul : ∀ a b, sign (a*b) = sign a*sign b
| a, 0 =>
  by 
    simp 
| 0, b =>
  by 
    simp 
| (m+1 : ℕ), (n+1 : ℕ) => rfl
| (m+1 : ℕ), -[1+ n] => rfl
| -[1+ m], (n+1 : ℕ) => rfl
| -[1+ m], -[1+ n] => rfl

protected theorem sign_eq_div_abs (a : ℤ) : sign a = a / |a| :=
  if az : a = 0 then
    by 
      simp [az]
  else (Int.div_eq_of_eq_mul_left (mt abs_eq_zero.1 az) (sign_mul_abs _).symm).symm

theorem mul_sign : ∀ i : ℤ, (i*sign i) = nat_abs i
| (n+1 : ℕ) => mul_oneₓ _
| 0 => mul_zero _
| -[1+ n] => mul_neg_one _

@[simp]
theorem sign_pow_bit1 (k : ℕ) : ∀ n : ℤ, n.sign ^ bit1 k = n.sign
| (n+1 : ℕ) => one_pow (bit1 k)
| 0 => zero_pow (Nat.zero_lt_bit1 k)
| -[1+ n] => (neg_pow_bit1 1 k).trans (congr_argₓ (fun x => -x) (one_pow (bit1 k)))

theorem le_of_dvd {a b : ℤ} (bpos : 0 < b) (H : a ∣ b) : a ≤ b :=
  match a, b, eq_succ_of_zero_lt bpos, H with 
  | (m : ℕ), _, ⟨n, rfl⟩, H => coe_nat_le_coe_nat_of_le$ Nat.le_of_dvdₓ n.succ_pos$ coe_nat_dvd.1 H
  | -[1+ m], _, ⟨n, rfl⟩, _ => le_transₓ (le_of_ltₓ$ neg_succ_lt_zero _) (coe_zero_le _)

theorem eq_one_of_dvd_one {a : ℤ} (H : 0 ≤ a) (H' : a ∣ 1) : a = 1 :=
  match a, eq_coe_of_zero_le H, H' with 
  | _, ⟨n, rfl⟩, H' => congr_argₓ coeₓ$ Nat.eq_one_of_dvd_one$ coe_nat_dvd.1 H'

theorem eq_one_of_mul_eq_one_right {a b : ℤ} (H : 0 ≤ a) (H' : (a*b) = 1) : a = 1 :=
  eq_one_of_dvd_one H ⟨b, H'.symm⟩

theorem eq_one_of_mul_eq_one_left {a b : ℤ} (H : 0 ≤ b) (H' : (a*b) = 1) : b = 1 :=
  eq_one_of_mul_eq_one_right H
    (by 
      rw [mul_commₓ, H'])

theorem of_nat_dvd_of_dvd_nat_abs {a : ℕ} : ∀ {z : ℤ} haz : a ∣ z.nat_abs, «expr↑ » a ∣ z
| Int.ofNat _, haz => Int.coe_nat_dvd.2 haz
| -[1+ k], haz =>
  by 
    change «expr↑ » a ∣ -(k+1 : ℤ)
    apply dvd_neg_of_dvd 
    apply Int.coe_nat_dvd.2 
    exact haz

theorem dvd_nat_abs_of_of_nat_dvd {a : ℕ} : ∀ {z : ℤ} haz : «expr↑ » a ∣ z, a ∣ z.nat_abs
| Int.ofNat _, haz => Int.coe_nat_dvd.1 (Int.dvd_nat_abs.2 haz)
| -[1+ k], haz =>
  have haz' : («expr↑ » a : ℤ) ∣ («expr↑ » (k+1) : ℤ) := dvd_of_dvd_neg haz 
  Int.coe_nat_dvd.1 haz'

theorem pow_dvd_of_le_of_pow_dvd {p m n : ℕ} {k : ℤ} (hmn : m ≤ n) (hdiv : «expr↑ » (p ^ n) ∣ k) :
  «expr↑ » (p ^ m) ∣ k :=
  by 
    induction k
    ·
      apply Int.coe_nat_dvd.2
      apply pow_dvd_of_le_of_pow_dvd hmn 
      apply Int.coe_nat_dvd.1 hdiv 
    change -[1+ k] with -(«expr↑ » (k+1) : ℤ)
    apply dvd_neg_of_dvd 
    apply Int.coe_nat_dvd.2
    apply pow_dvd_of_le_of_pow_dvd hmn 
    apply Int.coe_nat_dvd.1
    apply dvd_of_dvd_neg 
    exact hdiv

theorem dvd_of_pow_dvd {p k : ℕ} {m : ℤ} (hk : 1 ≤ k) (hpk : «expr↑ » (p ^ k) ∣ m) : «expr↑ » p ∣ m :=
  by 
    rw [←pow_oneₓ p] <;> exact pow_dvd_of_le_of_pow_dvd hk hpk

-- error in Data.Int.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
/-- If `n > 0` then `m` is not divisible by `n` iff it is between `n * k` and `n * (k + 1)`
  for some `k`. -/
theorem exists_lt_and_lt_iff_not_dvd
(m : exprℤ())
{n : exprℤ()}
(hn : «expr < »(0, n)) : «expr ↔ »(«expr∃ , »((k), «expr ∧ »(«expr < »(«expr * »(n, k), m), «expr < »(m, «expr * »(n, «expr + »(k, 1))))), «expr¬ »(«expr ∣ »(n, m))) :=
begin
  split,
  { rintro ["⟨", ident k, ",", ident h1k, ",", ident h2k, "⟩", "⟨", ident l, ",", ident rfl, "⟩"],
    rw ["[", expr mul_lt_mul_left hn, "]"] ["at", ident h1k, ident h2k],
    rw ["[", expr lt_add_one_iff, ",", "<-", expr not_lt, "]"] ["at", ident h2k],
    exact [expr h2k h1k] },
  { intro [ident h],
    rw ["[", expr dvd_iff_mod_eq_zero, ",", "<-", expr ne.def, "]"] ["at", ident h],
    have [] [] [":=", expr (mod_nonneg m hn.ne.symm).lt_of_ne h.symm],
    simp [] [] ["only"] ["[", "<-", expr mod_add_div m n, "]"] [] [] { single_pass := tt },
    refine [expr ⟨«expr / »(m, n), lt_add_of_pos_left _ this, _⟩],
    rw ["[", expr add_comm _ (1 : exprℤ()), ",", expr left_distrib, ",", expr mul_one, "]"] [],
    exact [expr add_lt_add_right (mod_lt_of_pos _ hn) _] }
end

/-! ### `/` and ordering -/


protected theorem div_mul_le (a : ℤ) {b : ℤ} (H : b ≠ 0) : ((a / b)*b) ≤ a :=
  le_of_sub_nonneg$
    by 
      rw [mul_commₓ, ←mod_def] <;> apply mod_nonneg _ H

protected theorem div_le_of_le_mul {a b c : ℤ} (H : 0 < c) (H' : a ≤ b*c) : a / c ≤ b :=
  le_of_mul_le_mul_right (le_transₓ (Int.div_mul_le _ (ne_of_gtₓ H)) H') H

protected theorem mul_lt_of_lt_div {a b c : ℤ} (H : 0 < c) (H3 : a < b / c) : (a*c) < b :=
  lt_of_not_geₓ$ mt (Int.div_le_of_le_mul H) (not_le_of_gtₓ H3)

protected theorem mul_le_of_le_div {a b c : ℤ} (H1 : 0 < c) (H2 : a ≤ b / c) : (a*c) ≤ b :=
  le_transₓ (Decidable.mul_le_mul_of_nonneg_right H2 (le_of_ltₓ H1)) (Int.div_mul_le _ (ne_of_gtₓ H1))

protected theorem le_div_of_mul_le {a b c : ℤ} (H1 : 0 < c) (H2 : (a*c) ≤ b) : a ≤ b / c :=
  le_of_lt_add_one$ lt_of_mul_lt_mul_right (lt_of_le_of_ltₓ H2 (lt_div_add_one_mul_self _ H1)) (le_of_ltₓ H1)

protected theorem le_div_iff_mul_le {a b c : ℤ} (H : 0 < c) : a ≤ b / c ↔ (a*c) ≤ b :=
  ⟨Int.mul_le_of_le_div H, Int.le_div_of_mul_le H⟩

protected theorem div_le_div {a b c : ℤ} (H : 0 < c) (H' : a ≤ b) : a / c ≤ b / c :=
  Int.le_div_of_mul_le H (le_transₓ (Int.div_mul_le _ (ne_of_gtₓ H)) H')

protected theorem div_lt_of_lt_mul {a b c : ℤ} (H : 0 < c) (H' : a < b*c) : a / c < b :=
  lt_of_not_geₓ$ mt (Int.mul_le_of_le_div H) (not_le_of_gtₓ H')

protected theorem lt_mul_of_div_lt {a b c : ℤ} (H1 : 0 < c) (H2 : a / c < b) : a < b*c :=
  lt_of_not_geₓ$ mt (Int.le_div_of_mul_le H1) (not_le_of_gtₓ H2)

protected theorem div_lt_iff_lt_mul {a b c : ℤ} (H : 0 < c) : a / c < b ↔ a < b*c :=
  ⟨Int.lt_mul_of_div_lt H, Int.div_lt_of_lt_mul H⟩

protected theorem le_mul_of_div_le {a b c : ℤ} (H1 : 0 ≤ b) (H2 : b ∣ a) (H3 : a / b ≤ c) : a ≤ c*b :=
  by 
    rw [←Int.div_mul_cancel H2] <;> exact Decidable.mul_le_mul_of_nonneg_right H3 H1

protected theorem lt_div_of_mul_lt {a b c : ℤ} (H1 : 0 ≤ b) (H2 : b ∣ c) (H3 : (a*b) < c) : a < c / b :=
  lt_of_not_geₓ$ mt (Int.le_mul_of_div_le H1 H2) (not_le_of_gtₓ H3)

protected theorem lt_div_iff_mul_lt {a b : ℤ} (c : ℤ) (H : 0 < c) (H' : c ∣ b) : a < b / c ↔ (a*c) < b :=
  ⟨Int.mul_lt_of_lt_div H, Int.lt_div_of_mul_lt (le_of_ltₓ H) H'⟩

theorem div_pos_of_pos_of_dvd {a b : ℤ} (H1 : 0 < a) (H2 : 0 ≤ b) (H3 : b ∣ a) : 0 < a / b :=
  Int.lt_div_of_mul_lt H2 H3
    (by 
      rwa [zero_mul])

theorem div_eq_div_of_mul_eq_mul {a b c d : ℤ} (H2 : d ∣ c) (H3 : b ≠ 0) (H4 : d ≠ 0) (H5 : (a*d) = b*c) :
  a / b = c / d :=
  Int.div_eq_of_eq_mul_right H3$
    by 
      rw [←Int.mul_div_assoc _ H2] <;> exact (Int.div_eq_of_eq_mul_left H4 H5.symm).symm

theorem eq_mul_div_of_mul_eq_mul_of_dvd_left {a b c d : ℤ} (hb : b ≠ 0) (hbc : b ∣ c) (h : (b*a) = c*d) :
  a = (c / b)*d :=
  by 
    cases' hbc with k hk 
    subst hk 
    rw [Int.mul_div_cancel_left _ hb]
    rw [mul_assocₓ] at h 
    apply mul_left_cancel₀ hb h

/-- If an integer with larger absolute value divides an integer, it is
zero. -/
theorem eq_zero_of_dvd_of_nat_abs_lt_nat_abs {a b : ℤ} (w : a ∣ b) (h : nat_abs b < nat_abs a) : b = 0 :=
  by 
    rw [←nat_abs_dvd, ←dvd_nat_abs, coe_nat_dvd] at w 
    rw [←nat_abs_eq_zero]
    exact eq_zero_of_dvd_of_lt w h

theorem eq_zero_of_dvd_of_nonneg_of_lt {a b : ℤ} (w₁ : 0 ≤ a) (w₂ : a < b) (h : b ∣ a) : a = 0 :=
  eq_zero_of_dvd_of_nat_abs_lt_nat_abs h (nat_abs_lt_nat_abs_of_nonneg_of_lt w₁ w₂)

/-- If two integers are congruent to a sufficiently large modulus,
they are equal. -/
theorem eq_of_mod_eq_of_nat_abs_sub_lt_nat_abs {a b c : ℤ} (h1 : a % b = c) (h2 : nat_abs (a - c) < nat_abs b) :
  a = c :=
  eq_of_sub_eq_zero (eq_zero_of_dvd_of_nat_abs_lt_nat_abs (dvd_sub_of_mod_eq h1) h2)

-- error in Data.Int.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem of_nat_add_neg_succ_of_nat_of_lt
{m n : exprℕ()}
(h : «expr < »(m, n.succ)) : «expr = »(«expr + »(of_nat m, «expr-[1+ ]»(n)), «expr-[1+ ]»(«expr - »(n, m))) :=
begin
  change [expr «expr = »(sub_nat_nat _ _, _)] [] [],
  have [ident h'] [":", expr «expr = »(«expr - »(n.succ, m), «expr - »(n, m).succ)] [],
  apply [expr succ_sub],
  apply [expr le_of_lt_succ h],
  simp [] [] [] ["[", "*", ",", expr sub_nat_nat, "]"] [] []
end

-- error in Data.Int.Basic: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem of_nat_add_neg_succ_of_nat_of_ge
{m n : exprℕ()}
(h : «expr ≤ »(n.succ, m)) : «expr = »(«expr + »(of_nat m, «expr-[1+ ]»(n)), of_nat «expr - »(m, n.succ)) :=
begin
  change [expr «expr = »(sub_nat_nat _ _, _)] [] [],
  have [ident h'] [":", expr «expr = »(«expr - »(n.succ, m), 0)] [],
  apply [expr tsub_eq_zero_iff_le.mpr h],
  simp [] [] [] ["[", "*", ",", expr sub_nat_nat, "]"] [] []
end

@[simp]
theorem neg_add_neg (m n : ℕ) : (-[1+ m]+-[1+ n]) = -[1+ Nat.succ (m+n)] :=
  rfl

/-! ### to_nat -/


theorem to_nat_eq_max : ∀ a : ℤ, (to_nat a : ℤ) = max a 0
| (n : ℕ) => (max_eq_leftₓ (coe_zero_le n)).symm
| -[1+ n] => (max_eq_rightₓ (le_of_ltₓ (neg_succ_lt_zero n))).symm

@[simp]
theorem to_nat_zero : (0 : ℤ).toNat = 0 :=
  rfl

@[simp]
theorem to_nat_one : (1 : ℤ).toNat = 1 :=
  rfl

@[simp]
theorem to_nat_of_nonneg {a : ℤ} (h : 0 ≤ a) : (to_nat a : ℤ) = a :=
  by 
    rw [to_nat_eq_max, max_eq_leftₓ h]

@[simp]
theorem to_nat_sub_of_le {a b : ℤ} (h : b ≤ a) : (to_nat (a - b) : ℤ) = a - b :=
  Int.to_nat_of_nonneg (sub_nonneg_of_le h)

@[simp]
theorem to_nat_coe_nat (n : ℕ) : to_nat («expr↑ » n) = n :=
  rfl

@[simp]
theorem to_nat_coe_nat_add_one {n : ℕ} : ((n : ℤ)+1).toNat = n+1 :=
  rfl

theorem le_to_nat (a : ℤ) : a ≤ to_nat a :=
  by 
    rw [to_nat_eq_max] <;> apply le_max_leftₓ

@[simp]
theorem to_nat_le {a : ℤ} {n : ℕ} : to_nat a ≤ n ↔ a ≤ n :=
  by 
    rw [(coe_nat_le_coe_nat_iff _ _).symm, to_nat_eq_max, max_le_iff] <;> exact and_iff_left (coe_zero_le _)

@[simp]
theorem lt_to_nat {n : ℕ} {a : ℤ} : n < to_nat a ↔ (n : ℤ) < a :=
  le_iff_le_iff_lt_iff_lt.1 to_nat_le

@[simp]
theorem le_to_nat_iff {n : ℕ} {z : ℤ} (h : 0 ≤ z) : n ≤ z.to_nat ↔ (n : ℤ) ≤ z :=
  by 
    rw [←Int.coe_nat_le_coe_nat_iff, Int.to_nat_of_nonneg h]

theorem to_nat_le_to_nat {a b : ℤ} (h : a ≤ b) : to_nat a ≤ to_nat b :=
  by 
    rw [to_nat_le] <;> exact le_transₓ h (le_to_nat b)

theorem to_nat_lt_to_nat {a b : ℤ} (hb : 0 < b) : to_nat a < to_nat b ↔ a < b :=
  ⟨fun h =>
      by 
        cases a 
        exact lt_to_nat.1 h 
        exact lt_transₓ (neg_succ_of_nat_lt_zero a) hb,
    fun h =>
      by 
        rw [lt_to_nat]
        cases a 
        exact h 
        exact hb⟩

theorem lt_of_to_nat_lt {a b : ℤ} (h : to_nat a < to_nat b) : a < b :=
  (to_nat_lt_to_nat$ lt_to_nat.1$ lt_of_le_of_ltₓ (Nat.zero_leₓ _) h).1 h

theorem to_nat_add {a b : ℤ} (ha : 0 ≤ a) (hb : 0 ≤ b) : (a+b).toNat = a.to_nat+b.to_nat :=
  by 
    lift a to ℕ using ha 
    lift b to ℕ using hb 
    normCast

theorem to_nat_add_nat {a : ℤ} (ha : 0 ≤ a) (n : ℕ) : (a+n).toNat = a.to_nat+n :=
  by 
    lift a to ℕ using ha 
    normCast

@[simp]
theorem pred_to_nat : ∀ i : ℤ, (i - 1).toNat = i.to_nat - 1
| (0 : ℕ) => rfl
| (n+1 : ℕ) =>
  by 
    simp 
| -[1+ n] => rfl

@[simp]
theorem to_nat_pred_coe_of_pos {i : ℤ} (h : 0 < i) : ((i.to_nat - 1 : ℕ) : ℤ) = i - 1 :=
  by 
    simp' [h, le_of_ltₓ h] with push_cast

@[simp]
theorem to_nat_sub_to_nat_neg : ∀ n : ℤ, «expr↑ » n.to_nat - «expr↑ » (-n).toNat = n
| (0 : ℕ) => rfl
| (n+1 : ℕ) => show «expr↑ » (n+1) - (0 : ℤ) = n+1 from sub_zero _
| -[1+ n] => show 0 - (n+1 : ℤ) = _ from zero_sub _

@[simp]
theorem to_nat_add_to_nat_neg_eq_nat_abs : ∀ n : ℤ, (n.to_nat+(-n).toNat) = n.nat_abs
| (0 : ℕ) => rfl
| (n+1 : ℕ) => show ((n+1)+0) = n+1 from add_zeroₓ _
| -[1+ n] => show (0+n+1) = n+1 from zero_addₓ _

/-- If `n : ℕ`, then `int.to_nat' n = some n`, if `n : ℤ` is negative, then `int.to_nat' n = none`.
-/
def to_nat' : ℤ → Option ℕ
| (n : ℕ) => some n
| -[1+ n] => none

theorem mem_to_nat' : ∀ a : ℤ n : ℕ, n ∈ to_nat' a ↔ a = n
| (m : ℕ), n => Option.some_inj.trans coe_nat_inj'.symm
| -[1+ m], n =>
  by 
    split  <;> intro h <;> cases h

theorem to_nat_of_nonpos : ∀ {z : ℤ}, z ≤ 0 → z.to_nat = 0
| (0 : ℕ) => fun _ => rfl
| (n+1 : ℕ) =>
  fun h =>
    (h.not_lt
        (by 
          exactModCast Nat.succ_posₓ n)).elim
| -[1+ n] => fun _ => rfl

/-! ### units -/


@[simp]
theorem units_nat_abs (u : Units ℤ) : nat_abs u = 1 :=
  Units.ext_iff.1$
    Nat.units_eq_one
      ⟨nat_abs u, nat_abs («expr↑ » (u⁻¹)),
        by 
          rw [←nat_abs_mul, Units.mul_inv] <;> rfl,
        by 
          rw [←nat_abs_mul, Units.inv_mul] <;> rfl⟩

theorem units_eq_one_or (u : Units ℤ) : u = 1 ∨ u = -1 :=
  by 
    simpa only [Units.ext_iff, units_nat_abs] using nat_abs_eq u

theorem is_unit_eq_one_or {a : ℤ} : IsUnit a → a = 1 ∨ a = -1
| ⟨x, hx⟩ => hx ▸ (units_eq_one_or _).imp (congr_argₓ coeₓ) (congr_argₓ coeₓ)

theorem is_unit_iff {a : ℤ} : IsUnit a ↔ a = 1 ∨ a = -1 :=
  by 
    refine' ⟨fun h => is_unit_eq_one_or h, fun h => _⟩
    rcases h with (rfl | rfl)
    ·
      exact is_unit_one
    ·
      exact is_unit_one.neg

theorem is_unit_iff_nat_abs_eq {n : ℤ} : IsUnit n ↔ n.nat_abs = 1 :=
  by 
    simp [nat_abs_eq_iff, is_unit_iff]

theorem units_inv_eq_self (u : Units ℤ) : u⁻¹ = u :=
  (units_eq_one_or u).elim (fun h => h.symm ▸ rfl) fun h => h.symm ▸ rfl

@[simp]
theorem units_mul_self (u : Units ℤ) : (u*u) = 1 :=
  (units_eq_one_or u).elim (fun h => h.symm ▸ rfl) fun h => h.symm ▸ rfl

@[simp]
theorem units_coe_mul_self (u : Units ℤ) : (u*u : ℤ) = 1 :=
  by 
    rw [←Units.coe_mul, units_mul_self, Units.coe_one]

@[simp]
theorem neg_one_pow_ne_zero {n : ℕ} : (-1 : ℤ) ^ n ≠ 0 :=
  pow_ne_zero _ (abs_pos.mp trivialₓ)

/-! ### bitwise ops -/


@[simp]
theorem bodd_zero : bodd 0 = ff :=
  rfl

@[simp]
theorem bodd_one : bodd 1 = tt :=
  rfl

theorem bodd_two : bodd 2 = ff :=
  rfl

@[simp, normCast]
theorem bodd_coe (n : ℕ) : Int.bodd n = Nat.bodd n :=
  rfl

@[simp]
theorem bodd_sub_nat_nat (m n : ℕ) : bodd (sub_nat_nat m n) = bxor m.bodd n.bodd :=
  by 
    apply sub_nat_nat_elim m n fun m n i => bodd i = bxor m.bodd n.bodd <;> intros  <;> simp  <;> cases i.bodd <;> simp 

@[simp]
theorem bodd_neg_of_nat (n : ℕ) : bodd (neg_of_nat n) = n.bodd :=
  by 
    cases n <;> simp  <;> rfl

@[simp]
theorem bodd_neg (n : ℤ) : bodd (-n) = bodd n :=
  by 
    cases n <;> simp [Neg.neg, Int.coe_nat_eq, Int.neg, bodd, -of_nat_eq_coe]

@[simp]
theorem bodd_add (m n : ℤ) : bodd (m+n) = bxor (bodd m) (bodd n) :=
  by 
    cases' m with m m <;> cases' n with n n <;> unfold Add.add <;> simp [Int.add, -of_nat_eq_coe, Bool.bxor_comm]

@[simp]
theorem bodd_mul (m n : ℤ) : bodd (m*n) = (bodd m && bodd n) :=
  by 
    cases' m with m m <;> cases' n with n n <;> simp [←Int.mul_def, Int.mul, -of_nat_eq_coe, Bool.bxor_comm]

theorem bodd_add_div2 : ∀ n, (cond (bodd n) 1 0+2*div2 n) = n
| (n : ℕ) =>
  by 
    rw
        [show (cond (bodd n) 1 0 : ℤ) = (cond (bodd n) 1 0 : ℕ)by 
          cases bodd n <;> rfl] <;>
      exact congr_argₓ of_nat n.bodd_add_div2
| -[1+ n] =>
  by 
    refine' Eq.trans _ (congr_argₓ neg_succ_of_nat n.bodd_add_div2)
    dsimp [bodd]
    cases Nat.bodd n <;> dsimp [cond, bnot, div2, Int.mul]
    ·
      change -[1+ 2*Nat.div2 n] = _ 
      rw [zero_addₓ]
    ·
      rw [zero_addₓ, add_commₓ]
      rfl

theorem div2_val : ∀ n, div2 n = n / 2
| (n : ℕ) => congr_argₓ of_nat n.div2_val
| -[1+ n] => congr_argₓ neg_succ_of_nat n.div2_val

theorem bit0_val (n : ℤ) : bit0 n = 2*n :=
  (two_mul _).symm

theorem bit1_val (n : ℤ) : bit1 n = (2*n)+1 :=
  congr_argₓ (·+(1 : ℤ)) (bit0_val _)

theorem bit_val b n : bit b n = (2*n)+cond b 1 0 :=
  by 
    cases b 
    apply (bit0_val n).trans (add_zeroₓ _).symm 
    apply bit1_val

theorem bit_decomp (n : ℤ) : bit (bodd n) (div2 n) = n :=
  (bit_val _ _).trans$ (add_commₓ _ _).trans$ bodd_add_div2 _

/-- Defines a function from `ℤ` conditionally, if it is defined for odd and even integers separately
  using `bit`. -/
def bit_cases_on.{u} {C : ℤ → Sort u} n (h : ∀ b n, C (bit b n)) : C n :=
  by 
    rw [←bit_decomp n] <;> apply h

@[simp]
theorem bit_zero : bit ff 0 = 0 :=
  rfl

@[simp]
theorem bit_coe_nat b (n : ℕ) : bit b n = Nat.bit b n :=
  by 
    rw [bit_val, Nat.bit_val] <;> cases b <;> rfl

@[simp]
theorem bit_neg_succ b (n : ℕ) : bit b -[1+ n] = -[1+ Nat.bit (bnot b) n] :=
  by 
    rw [bit_val, Nat.bit_val] <;> cases b <;> rfl

@[simp]
theorem bodd_bit b n : bodd (bit b n) = b :=
  by 
    rw [bit_val] <;> simp  <;> cases b <;> cases bodd n <;> rfl

@[simp]
theorem bodd_bit0 (n : ℤ) : bodd (bit0 n) = ff :=
  bodd_bit ff n

@[simp]
theorem bodd_bit1 (n : ℤ) : bodd (bit1 n) = tt :=
  bodd_bit tt n

@[simp]
theorem div2_bit b n : div2 (bit b n) = n :=
  by 
    rw [bit_val, div2_val, add_commₓ, Int.add_mul_div_left, (_ : (_ / 2 : ℤ) = 0), zero_addₓ]
    cases b
    ·
      simp 
    ·
      show of_nat _ = _ 
      rw [Nat.div_eq_zero] <;> simp 
    ·
      cc

theorem bit0_ne_bit1 (m n : ℤ) : bit0 m ≠ bit1 n :=
  mt (congr_argₓ bodd)$
    by 
      simp 

theorem bit1_ne_bit0 (m n : ℤ) : bit1 m ≠ bit0 n :=
  (bit0_ne_bit1 _ _).symm

theorem bit1_ne_zero (m : ℤ) : bit1 m ≠ 0 :=
  by 
    simpa only [bit0_zero] using bit1_ne_bit0 m 0

@[simp]
theorem test_bit_zero b : ∀ n, test_bit (bit b n) 0 = b
| (n : ℕ) =>
  by 
    rw [bit_coe_nat] <;> apply Nat.test_bit_zero
| -[1+ n] =>
  by 
    rw [bit_neg_succ] <;> dsimp [test_bit] <;> rw [Nat.test_bit_zero] <;> clear test_bit_zero <;> cases b <;> rfl

@[simp]
theorem test_bit_succ m b : ∀ n, test_bit (bit b n) (Nat.succ m) = test_bit n m
| (n : ℕ) =>
  by 
    rw [bit_coe_nat] <;> apply Nat.test_bit_succ
| -[1+ n] =>
  by 
    rw [bit_neg_succ] <;> dsimp [test_bit] <;> rw [Nat.test_bit_succ]

private unsafe def bitwise_tac : tactic Unit :=
  sorry

theorem bitwise_or : bitwise bor = lor :=
  by 
    runTac 
      bitwise_tac

theorem bitwise_and : bitwise band = land :=
  by 
    runTac 
      bitwise_tac

theorem bitwise_diff : (bitwise fun a b => a && bnot b) = ldiff :=
  by 
    runTac 
      bitwise_tac

theorem bitwise_xor : bitwise bxor = lxor :=
  by 
    runTac 
      bitwise_tac

@[simp]
theorem bitwise_bit (f : Bool → Bool → Bool) a m b n : bitwise f (bit a m) (bit b n) = bit (f a b) (bitwise f m n) :=
  by 
    cases' m with m m <;>
      cases' n with n n <;>
        repeat' 
            first |
              rw [←Int.coe_nat_eq]|
              rw [bit_coe_nat]|
              rw [bit_neg_succ] <;>
          unfold bitwise nat_bitwise bnot <;> [induction' h : f ff ff with , induction' h : f ff tt with ,
            induction' h : f tt ff with , induction' h : f tt tt with ]
    all_goals 
      unfold cond 
      rw [Nat.bitwise_bit]
      repeat' 
        first |
          rw [bit_coe_nat]|
          rw [bit_neg_succ]|
          rw [bnot_bnot]
    all_goals 
      unfold bnot <;> rw [h] <;> rfl

@[simp]
theorem lor_bit a m b n : lor (bit a m) (bit b n) = bit (a || b) (lor m n) :=
  by 
    rw [←bitwise_or, bitwise_bit]

@[simp]
theorem land_bit a m b n : land (bit a m) (bit b n) = bit (a && b) (land m n) :=
  by 
    rw [←bitwise_and, bitwise_bit]

@[simp]
theorem ldiff_bit a m b n : ldiff (bit a m) (bit b n) = bit (a && bnot b) (ldiff m n) :=
  by 
    rw [←bitwise_diff, bitwise_bit]

@[simp]
theorem lxor_bit a m b n : lxor (bit a m) (bit b n) = bit (bxor a b) (lxor m n) :=
  by 
    rw [←bitwise_xor, bitwise_bit]

@[simp]
theorem lnot_bit b : ∀ n, lnot (bit b n) = bit (bnot b) (lnot n)
| (n : ℕ) =>
  by 
    simp [lnot]
| -[1+ n] =>
  by 
    simp [lnot]

@[simp]
theorem test_bit_bitwise (f : Bool → Bool → Bool) m n k :
  test_bit (bitwise f m n) k = f (test_bit m k) (test_bit n k) :=
  by 
    induction' k with k IH generalizing m n <;>
      apply bit_cases_on m <;> intro a m' <;> apply bit_cases_on n <;> intro b n' <;> rw [bitwise_bit]
    ·
      simp [test_bit_zero]
    ·
      simp [test_bit_succ, IH]

@[simp]
theorem test_bit_lor m n k : test_bit (lor m n) k = (test_bit m k || test_bit n k) :=
  by 
    rw [←bitwise_or, test_bit_bitwise]

@[simp]
theorem test_bit_land m n k : test_bit (land m n) k = (test_bit m k && test_bit n k) :=
  by 
    rw [←bitwise_and, test_bit_bitwise]

@[simp]
theorem test_bit_ldiff m n k : test_bit (ldiff m n) k = (test_bit m k && bnot (test_bit n k)) :=
  by 
    rw [←bitwise_diff, test_bit_bitwise]

@[simp]
theorem test_bit_lxor m n k : test_bit (lxor m n) k = bxor (test_bit m k) (test_bit n k) :=
  by 
    rw [←bitwise_xor, test_bit_bitwise]

@[simp]
theorem test_bit_lnot : ∀ n k, test_bit (lnot n) k = bnot (test_bit n k)
| (n : ℕ), k =>
  by 
    simp [lnot, test_bit]
| -[1+ n], k =>
  by 
    simp [lnot, test_bit]

theorem shiftl_add : ∀ m : ℤ n : ℕ k : ℤ, shiftl m (n+k) = shiftl (shiftl m n) k
| (m : ℕ), n, (k : ℕ) => congr_argₓ of_nat (Nat.shiftl_add _ _ _)
| -[1+ m], n, (k : ℕ) => congr_argₓ neg_succ_of_nat (Nat.shiftl'_add _ _ _ _)
| (m : ℕ), n, -[1+ k] =>
  sub_nat_nat_elim n k.succ (fun n k i => shiftl («expr↑ » m) i = Nat.shiftr (Nat.shiftl m n) k)
    (fun i n =>
      congr_argₓ coeₓ$
        by 
          rw [←Nat.shiftl_sub, add_tsub_cancel_left] <;> apply Nat.le_add_rightₓ)
    fun i n =>
      congr_argₓ coeₓ$
        by 
          rw [add_assocₓ, Nat.shiftr_add, ←Nat.shiftl_sub, tsub_self] <;> rfl
| -[1+ m], n, -[1+ k] =>
  sub_nat_nat_elim n k.succ (fun n k i => shiftl -[1+ m] i = -[1+ Nat.shiftr (Nat.shiftl' tt m n) k])
    (fun i n =>
      congr_argₓ neg_succ_of_nat$
        by 
          rw [←Nat.shiftl'_sub, add_tsub_cancel_left] <;> apply Nat.le_add_rightₓ)
    fun i n =>
      congr_argₓ neg_succ_of_nat$
        by 
          rw [add_assocₓ, Nat.shiftr_add, ←Nat.shiftl'_sub, tsub_self] <;> rfl

theorem shiftl_sub (m : ℤ) (n : ℕ) (k : ℤ) : shiftl m (n - k) = shiftr (shiftl m n) k :=
  shiftl_add _ _ _

@[simp]
theorem shiftl_neg (m n : ℤ) : shiftl m (-n) = shiftr m n :=
  rfl

@[simp]
theorem shiftr_neg (m n : ℤ) : shiftr m (-n) = shiftl m n :=
  by 
    rw [←shiftl_neg, neg_negₓ]

@[simp]
theorem shiftl_coe_nat (m n : ℕ) : shiftl m n = Nat.shiftl m n :=
  rfl

@[simp]
theorem shiftr_coe_nat (m n : ℕ) : shiftr m n = Nat.shiftr m n :=
  by 
    cases n <;> rfl

@[simp]
theorem shiftl_neg_succ (m n : ℕ) : shiftl -[1+ m] n = -[1+ Nat.shiftl' tt m n] :=
  rfl

@[simp]
theorem shiftr_neg_succ (m n : ℕ) : shiftr -[1+ m] n = -[1+ Nat.shiftr m n] :=
  by 
    cases n <;> rfl

theorem shiftr_add : ∀ m : ℤ n k : ℕ, shiftr m (n+k) = shiftr (shiftr m n) k
| (m : ℕ), n, k =>
  by 
    rw [shiftr_coe_nat, shiftr_coe_nat, ←Int.coe_nat_add, shiftr_coe_nat, Nat.shiftr_add]
| -[1+ m], n, k =>
  by 
    rw [shiftr_neg_succ, shiftr_neg_succ, ←Int.coe_nat_add, shiftr_neg_succ, Nat.shiftr_add]

theorem shiftl_eq_mul_pow : ∀ m : ℤ n : ℕ, shiftl m n = m*«expr↑ » (2 ^ n)
| (m : ℕ), n => congr_argₓ coeₓ (Nat.shiftl_eq_mul_pow _ _)
| -[1+ m], n => @congr_argₓ ℕ ℤ _ _ (fun i => -i) (Nat.shiftl'_tt_eq_mul_pow _ _)

theorem shiftr_eq_div_pow : ∀ m : ℤ n : ℕ, shiftr m n = m / «expr↑ » (2 ^ n)
| (m : ℕ), n =>
  by 
    rw [shiftr_coe_nat] <;> exact congr_argₓ coeₓ (Nat.shiftr_eq_div_pow _ _)
| -[1+ m], n =>
  by 
    rw [shiftr_neg_succ, neg_succ_of_nat_div, Nat.shiftr_eq_div_pow]
    rfl 
    exact
      coe_nat_lt_coe_nat_of_lt
        (pow_pos
          (by 
            decide)
          _)

theorem one_shiftl (n : ℕ) : shiftl 1 n = (2 ^ n : ℕ) :=
  congr_argₓ coeₓ (Nat.one_shiftl _)

@[simp]
theorem zero_shiftl : ∀ n : ℤ, shiftl 0 n = 0
| (n : ℕ) => congr_argₓ coeₓ (Nat.zero_shiftl _)
| -[1+ n] => congr_argₓ coeₓ (Nat.zero_shiftr _)

@[simp]
theorem zero_shiftr n : shiftr 0 n = 0 :=
  zero_shiftl _

end Int

