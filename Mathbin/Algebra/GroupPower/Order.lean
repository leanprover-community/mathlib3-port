import Mathbin.Algebra.Order.Ring 
import Mathbin.Algebra.GroupPower.Basic

/-!
# Lemmas about the interaction of power operations with order

Note that some lemmas are in `algebra/group_power/lemmas.lean` as they import files which
depend on this file.
-/


variable{A G M R : Type _}

section Preorderₓ

variable[Monoidₓ M][Preorderₓ M][CovariantClass M M (·*·) (· ≤ ·)]

@[toAdditive nsmul_le_nsmul_of_le_right, mono]
theorem pow_le_pow_of_le_left' [CovariantClass M M (Function.swap (·*·)) (· ≤ ·)] {a b : M} (hab : a ≤ b) :
  ∀ (i : ℕ), a ^ i ≤ b ^ i
| 0 =>
  by 
    simp 
| k+1 =>
  by 
    rw [pow_succₓ, pow_succₓ]
    exact mul_le_mul' hab (pow_le_pow_of_le_left' k)

attribute [mono] nsmul_le_nsmul_of_le_right

@[toAdditive nsmul_nonneg]
theorem one_le_pow_of_one_le' {a : M} (H : 1 ≤ a) : ∀ (n : ℕ), 1 ≤ a ^ n
| 0 =>
  by 
    simp 
| k+1 =>
  by 
    rw [pow_succₓ]
    exact one_le_mul H (one_le_pow_of_one_le' k)

@[toAdditive nsmul_nonpos]
theorem pow_le_one' {a : M} (H : a ≤ 1) (n : ℕ) : a ^ n ≤ 1 :=
  @one_le_pow_of_one_le' (OrderDual M) _ _ _ _ H n

@[toAdditive nsmul_le_nsmul]
theorem pow_le_pow' {a : M} {n m : ℕ} (ha : 1 ≤ a) (h : n ≤ m) : a ^ n ≤ a ^ m :=
  let ⟨k, hk⟩ := Nat.Le.dest h 
  calc a ^ n ≤ (a ^ n)*a ^ k := le_mul_of_one_le_right' (one_le_pow_of_one_le' ha _)
    _ = a ^ m :=
    by 
      rw [←hk, pow_addₓ]
    

@[toAdditive nsmul_le_nsmul_of_nonpos]
theorem pow_le_pow_of_le_one' {a : M} {n m : ℕ} (ha : a ≤ 1) (h : n ≤ m) : a ^ m ≤ a ^ n :=
  @pow_le_pow' (OrderDual M) _ _ _ _ _ _ ha h

@[toAdditive nsmul_pos]
theorem one_lt_pow' {a : M} (ha : 1 < a) {k : ℕ} (hk : k ≠ 0) : 1 < a ^ k :=
  by 
    rcases Nat.exists_eq_succ_of_ne_zero hk with ⟨l, rfl⟩
    clear hk 
    induction' l with l IH
    ·
      simpa using ha
    ·
      rw [pow_succₓ]
      exact one_lt_mul' ha IH

@[toAdditive nsmul_neg]
theorem pow_lt_one' {a : M} (ha : a < 1) {k : ℕ} (hk : k ≠ 0) : a ^ k < 1 :=
  @one_lt_pow' (OrderDual M) _ _ _ _ ha k hk

@[toAdditive nsmul_lt_nsmul]
theorem pow_lt_pow' [CovariantClass M M (·*·) (· < ·)] {a : M} {n m : ℕ} (ha : 1 < a) (h : n < m) : a ^ n < a ^ m :=
  by 
    rcases Nat.Le.dest h with ⟨k, rfl⟩
    clear h 
    rw [pow_addₓ, pow_succ'ₓ, mul_assocₓ, ←pow_succₓ]
    exact lt_mul_of_one_lt_right' _ (one_lt_pow' ha k.succ_ne_zero)

end Preorderₓ

section LinearOrderₓ

variable[Monoidₓ M][LinearOrderₓ M][CovariantClass M M (·*·) (· ≤ ·)]

@[toAdditive nsmul_nonneg_iff]
theorem one_le_pow_iff {x : M} {n : ℕ} (hn : n ≠ 0) : 1 ≤ x ^ n ↔ 1 ≤ x :=
  ⟨le_imp_le_of_lt_imp_ltₓ$ fun h => pow_lt_one' h hn, fun h => one_le_pow_of_one_le' h n⟩

@[toAdditive nsmul_nonpos_iff]
theorem pow_le_one_iff {x : M} {n : ℕ} (hn : n ≠ 0) : x ^ n ≤ 1 ↔ x ≤ 1 :=
  @one_le_pow_iff (OrderDual M) _ _ _ _ _ hn

@[toAdditive nsmul_pos_iff]
theorem one_lt_pow_iff {x : M} {n : ℕ} (hn : n ≠ 0) : 1 < x ^ n ↔ 1 < x :=
  lt_iff_lt_of_le_iff_le (pow_le_one_iff hn)

@[toAdditive nsmul_neg_iff]
theorem pow_lt_one_iff {x : M} {n : ℕ} (hn : n ≠ 0) : x ^ n < 1 ↔ x < 1 :=
  lt_iff_lt_of_le_iff_le (one_le_pow_iff hn)

@[toAdditive nsmul_eq_zero_iff]
theorem pow_eq_one_iff {x : M} {n : ℕ} (hn : n ≠ 0) : x ^ n = 1 ↔ x = 1 :=
  by 
    simp only [le_antisymm_iffₓ, pow_le_one_iff hn, one_le_pow_iff hn]

end LinearOrderₓ

section Groupₓ

variable[Groupₓ G][Preorderₓ G][CovariantClass G G (·*·) (· ≤ ·)]

@[toAdditive zsmul_nonneg]
theorem one_le_zpow {x : G} (H : 1 ≤ x) {n : ℤ} (hn : 0 ≤ n) : 1 ≤ x ^ n :=
  by 
    lift n to ℕ using hn 
    rw [zpow_coe_nat]
    apply one_le_pow_of_one_le' H

end Groupₓ

namespace CanonicallyOrderedCommSemiring

variable[CanonicallyOrderedCommSemiring R]

theorem pow_pos {a : R} (H : 0 < a) (n : ℕ) : 0 < a ^ n :=
  pos_iff_ne_zero.2$ pow_ne_zero _ H.ne'

end CanonicallyOrderedCommSemiring

section OrderedSemiring

variable[OrderedSemiring R]{a x y : R}{n m : ℕ}

@[simp]
theorem pow_pos (H : 0 < a) : ∀ (n : ℕ), 0 < a ^ n
| 0 =>
  by 
    nontriviality 
    rw [pow_zeroₓ]
    exact zero_lt_one
| n+1 =>
  by 
    rw [pow_succₓ]
    exact mul_pos H (pow_pos _)

@[simp]
theorem pow_nonneg (H : 0 ≤ a) : ∀ (n : ℕ), 0 ≤ a ^ n
| 0 =>
  by 
    rw [pow_zeroₓ]
    exact zero_le_one
| n+1 =>
  by 
    rw [pow_succₓ]
    exact mul_nonneg H (pow_nonneg _)

-- error in Algebra.GroupPower.Order: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: parenthesize: uncaught backtrack exception
theorem pow_add_pow_le
(hx : «expr ≤ »(0, x))
(hy : «expr ≤ »(0, y))
(hn : «expr ≠ »(n, 0)) : «expr ≤ »(«expr + »(«expr ^ »(x, n), «expr ^ »(y, n)), «expr ^ »(«expr + »(x, y), n)) :=
begin
  rcases [expr nat.exists_eq_succ_of_ne_zero hn, "with", "⟨", ident k, ",", ident rfl, "⟩"],
  induction [expr k] [] ["with", ident k, ident ih] [],
  { simp [] [] ["only"] ["[", expr pow_one, "]"] [] [] },
  let [ident n] [] [":=", expr k.succ],
  have [ident h1] [] [":=", expr add_nonneg (mul_nonneg hx (pow_nonneg hy n)) (mul_nonneg hy (pow_nonneg hx n))],
  have [ident h2] [] [":=", expr add_nonneg hx hy],
  calc
    «expr ≤ »(«expr + »(«expr ^ »(x, n.succ), «expr ^ »(y, n.succ)), «expr + »(«expr + »(«expr * »(x, «expr ^ »(x, n)), «expr * »(y, «expr ^ »(y, n))), «expr + »(«expr * »(x, «expr ^ »(y, n)), «expr * »(y, «expr ^ »(x, n))))) : by { rw ["[", expr pow_succ _ n, ",", expr pow_succ _ n, "]"] [],
      exact [expr le_add_of_nonneg_right h1] }
    «expr = »(..., «expr * »(«expr + »(x, y), «expr + »(«expr ^ »(x, n), «expr ^ »(y, n)))) : by rw ["[", expr add_mul, ",", expr mul_add, ",", expr mul_add, ",", expr add_comm «expr * »(y, «expr ^ »(x, n)), ",", "<-", expr add_assoc, ",", "<-", expr add_assoc, ",", expr add_assoc «expr * »(x, «expr ^ »(x, n)) «expr * »(x, «expr ^ »(y, n)), ",", expr add_comm «expr * »(x, «expr ^ »(y, n)) «expr * »(y, «expr ^ »(y, n)), ",", "<-", expr add_assoc, "]"] []
    «expr ≤ »(..., «expr ^ »(«expr + »(x, y), n.succ)) : by { rw ["[", expr pow_succ _ n, "]"] [],
      exact [expr mul_le_mul_of_nonneg_left (ih (nat.succ_ne_zero k)) h2] }
end

theorem pow_lt_pow_of_lt_left (Hxy : x < y) (Hxpos : 0 ≤ x) (Hnpos : 0 < n) : x ^ n < y ^ n :=
  by 
    cases lt_or_eq_of_leₓ Hxpos
    ·
      rw [←tsub_add_cancel_of_le (Nat.succ_le_of_ltₓ Hnpos)]
      induction n - 1
      ·
        simpa only [pow_oneₓ]
      rw [pow_addₓ, pow_addₓ, Nat.succ_eq_add_one, pow_oneₓ, pow_oneₓ]
      apply mul_lt_mul ih (le_of_ltₓ Hxy) h (le_of_ltₓ (pow_pos (lt_transₓ h Hxy) _))
    ·
      rw [←h, zero_pow Hnpos]
      apply
        pow_pos
          (by 
            rwa [←h] at Hxy :
          0 < y)

theorem pow_lt_one (h₀ : 0 ≤ a) (h₁ : a < 1) {n : ℕ} (hn : n ≠ 0) : a ^ n < 1 :=
  (one_pow n).subst (pow_lt_pow_of_lt_left h₁ h₀ (Nat.pos_of_ne_zeroₓ hn))

-- error in Algebra.GroupPower.Order: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem strict_mono_on_pow (hn : «expr < »(0, n)) : strict_mono_on (λ x : R, «expr ^ »(x, n)) (set.Ici 0) :=
λ x hx y hy h, pow_lt_pow_of_lt_left h hx hn

theorem one_le_pow_of_one_le (H : 1 ≤ a) : ∀ (n : ℕ), 1 ≤ a ^ n
| 0 =>
  by 
    rw [pow_zeroₓ]
| n+1 =>
  by 
    rw [pow_succₓ]
    simpa only [mul_oneₓ] using mul_le_mul H (one_le_pow_of_one_le n) zero_le_one (le_transₓ zero_le_one H)

-- error in Algebra.GroupPower.Order: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem pow_mono (h : «expr ≤ »(1, a)) : monotone (λ n : exprℕ(), «expr ^ »(a, n)) :=
«expr $ »(monotone_nat_of_le_succ, λ n, by { rw [expr pow_succ] [],
   exact [expr le_mul_of_one_le_left (pow_nonneg (zero_le_one.trans h) _) h] })

theorem pow_le_pow (ha : 1 ≤ a) (h : n ≤ m) : a ^ n ≤ a ^ m :=
  pow_mono ha h

-- error in Algebra.GroupPower.Order: ././Mathport/Syntax/Translate/Basic.lean:177:17: failed to parenthesize: no declaration of attribute [parenthesizer] found for 'Lean.Parser.Term.explicitBinder'
theorem strict_mono_pow (h : «expr < »(1, a)) : strict_mono (λ n : exprℕ(), «expr ^ »(a, n)) :=
have «expr < »(0, a) := zero_le_one.trans_lt h,
«expr $ »(strict_mono_nat_of_lt_succ, λ
 n, by simpa [] [] ["only"] ["[", expr one_mul, ",", expr pow_succ, "]"] [] ["using", expr mul_lt_mul h (le_refl «expr ^ »(a, n)) (pow_pos this _) this.le])

theorem pow_lt_pow (h : 1 < a) (h2 : n < m) : a ^ n < a ^ m :=
  strict_mono_pow h h2

theorem pow_lt_pow_iff (h : 1 < a) : a ^ n < a ^ m ↔ n < m :=
  (strict_mono_pow h).lt_iff_lt

@[mono]
theorem pow_le_pow_of_le_left {a b : R} (ha : 0 ≤ a) (hab : a ≤ b) : ∀ (i : ℕ), a ^ i ≤ b ^ i
| 0 =>
  by 
    simp 
| k+1 =>
  by 
    rw [pow_succₓ, pow_succₓ]
    exact mul_le_mul hab (pow_le_pow_of_le_left _) (pow_nonneg ha _) (le_transₓ ha hab)

theorem one_lt_pow (ha : 1 < a) : ∀ {n : ℕ}, n ≠ 0 → 1 < a ^ n
| 0, h => (h rfl).elim
| 1, h => (pow_oneₓ a).symm.subst ha
| n+2, h =>
  by 
    nontriviality R 
    rw [←one_mulₓ (1 : R), pow_succₓ]
    exact mul_lt_mul ha (one_lt_pow (Nat.succ_ne_zero _)).le zero_lt_one (zero_lt_one.trans ha).le

theorem pow_le_one : ∀ (n : ℕ) (h₀ : 0 ≤ a) (h₁ : a ≤ 1), a ^ n ≤ 1
| 0, h₀, h₁ => (pow_zeroₓ a).le
| n+1, h₀, h₁ => (pow_succ'ₓ a n).le.trans (mul_le_one (pow_le_one n h₀ h₁) h₀ h₁)

theorem sq_pos_of_pos (ha : 0 < a) : 0 < a ^ 2 :=
  by 
    rw [sq]
    exact mul_pos ha ha

end OrderedSemiring

section OrderedRing

variable[OrderedRing R]{a : R}

theorem sq_pos_of_neg (ha : a < 0) : 0 < a ^ 2 :=
  by 
    rw [sq]
    exact mul_pos_of_neg_of_neg ha ha

theorem pow_bit0_pos_of_neg (ha : a < 0) (n : ℕ) : 0 < a ^ bit0 n :=
  by 
    rw [pow_bit0']
    exact pow_pos (mul_pos_of_neg_of_neg ha ha) _

theorem pow_bit1_neg (ha : a < 0) (n : ℕ) : a ^ bit1 n < 0 :=
  by 
    rw [bit1, pow_succₓ]
    exact mul_neg_of_neg_of_pos ha (pow_bit0_pos_of_neg ha n)

end OrderedRing

section LinearOrderedSemiring

variable[LinearOrderedSemiring R]

theorem pow_le_one_iff_of_nonneg {a : R} (ha : 0 ≤ a) {n : ℕ} (hn : n ≠ 0) : a ^ n ≤ 1 ↔ a ≤ 1 :=
  by 
    refine' ⟨_, pow_le_one n ha⟩
    rw [←not_ltₓ, ←not_ltₓ]
    exact mt fun h => one_lt_pow h hn

theorem one_le_pow_iff_of_nonneg {a : R} (ha : 0 ≤ a) {n : ℕ} (hn : n ≠ 0) : 1 ≤ a ^ n ↔ 1 ≤ a :=
  by 
    refine' ⟨_, fun h => one_le_pow_of_one_le h n⟩
    rw [←not_ltₓ, ←not_ltₓ]
    exact mt fun h => pow_lt_one ha h hn

theorem one_lt_pow_iff_of_nonneg {a : R} (ha : 0 ≤ a) {n : ℕ} (hn : n ≠ 0) : 1 < a ^ n ↔ 1 < a :=
  lt_iff_lt_of_le_iff_le (pow_le_one_iff_of_nonneg ha hn)

theorem pow_lt_one_iff_of_nonneg {a : R} (ha : 0 ≤ a) {n : ℕ} (hn : n ≠ 0) : a ^ n < 1 ↔ a < 1 :=
  lt_iff_lt_of_le_iff_le (one_le_pow_iff_of_nonneg ha hn)

theorem sq_le_one_iff {a : R} (ha : 0 ≤ a) : a ^ 2 ≤ 1 ↔ a ≤ 1 :=
  pow_le_one_iff_of_nonneg ha (Nat.succ_ne_zero _)

theorem sq_lt_one_iff {a : R} (ha : 0 ≤ a) : a ^ 2 < 1 ↔ a < 1 :=
  pow_lt_one_iff_of_nonneg ha (Nat.succ_ne_zero _)

theorem one_le_sq_iff {a : R} (ha : 0 ≤ a) : 1 ≤ a ^ 2 ↔ 1 ≤ a :=
  one_le_pow_iff_of_nonneg ha (Nat.succ_ne_zero _)

theorem one_lt_sq_iff {a : R} (ha : 0 ≤ a) : 1 < a ^ 2 ↔ 1 < a :=
  one_lt_pow_iff_of_nonneg ha (Nat.succ_ne_zero _)

@[simp]
theorem pow_left_inj {x y : R} {n : ℕ} (Hxpos : 0 ≤ x) (Hypos : 0 ≤ y) (Hnpos : 0 < n) : x ^ n = y ^ n ↔ x = y :=
  (@strict_mono_on_pow R _ _ Hnpos).InjOn.eq_iff Hxpos Hypos

theorem lt_of_pow_lt_pow {a b : R} (n : ℕ) (hb : 0 ≤ b) (h : a ^ n < b ^ n) : a < b :=
  lt_of_not_geₓ$ fun hn => not_lt_of_geₓ (pow_le_pow_of_le_left hb hn _) h

theorem le_of_pow_le_pow {a b : R} (n : ℕ) (hb : 0 ≤ b) (hn : 0 < n) (h : a ^ n ≤ b ^ n) : a ≤ b :=
  le_of_not_ltₓ$ fun h1 => not_le_of_lt (pow_lt_pow_of_lt_left h1 hb hn) h

@[simp]
theorem sq_eq_sq {a b : R} (ha : 0 ≤ a) (hb : 0 ≤ b) : a ^ 2 = b ^ 2 ↔ a = b :=
  pow_left_inj ha hb
    (by 
      decide)

end LinearOrderedSemiring

section LinearOrderedRing

variable[LinearOrderedRing R]

theorem pow_abs (a : R) (n : ℕ) : |a| ^ n = |a ^ n| :=
  ((absHom.toMonoidHom : R →* R).map_pow a n).symm

theorem abs_neg_one_pow (n : ℕ) : |(-1 : R) ^ n| = 1 :=
  by 
    rw [←pow_abs, abs_neg, abs_one, one_pow]

theorem pow_bit0_nonneg (a : R) (n : ℕ) : 0 ≤ a ^ bit0 n :=
  by 
    rw [pow_bit0]
    exact mul_self_nonneg _

theorem sq_nonneg (a : R) : 0 ≤ a ^ 2 :=
  pow_bit0_nonneg a 1

alias sq_nonneg ← pow_two_nonneg

theorem pow_bit0_pos {a : R} (h : a ≠ 0) (n : ℕ) : 0 < a ^ bit0 n :=
  (pow_bit0_nonneg a n).lt_of_ne (pow_ne_zero _ h).symm

theorem sq_pos_of_ne_zero (a : R) (h : a ≠ 0) : 0 < a ^ 2 :=
  pow_bit0_pos h 1

alias sq_pos_of_ne_zero ← pow_two_pos_of_ne_zero

variable{x y : R}

theorem sq_abs (x : R) : |x| ^ 2 = x ^ 2 :=
  by 
    simpa only [sq] using abs_mul_abs_self x

theorem abs_sq (x : R) : |x ^ 2| = x ^ 2 :=
  by 
    simpa only [sq] using abs_mul_self x

theorem sq_lt_sq (h : |x| < y) : x ^ 2 < y ^ 2 :=
  by 
    simpa only [sq_abs] using pow_lt_pow_of_lt_left h (abs_nonneg x) (1 : ℕ).succ_pos

theorem sq_lt_sq' (h1 : -y < x) (h2 : x < y) : x ^ 2 < y ^ 2 :=
  sq_lt_sq (abs_lt.mpr ⟨h1, h2⟩)

theorem sq_le_sq (h : |x| ≤ |y|) : x ^ 2 ≤ y ^ 2 :=
  by 
    simpa only [sq_abs] using pow_le_pow_of_le_left (abs_nonneg x) h 2

theorem sq_le_sq' (h1 : -y ≤ x) (h2 : x ≤ y) : x ^ 2 ≤ y ^ 2 :=
  sq_le_sq (le_transₓ (abs_le.mpr ⟨h1, h2⟩) (le_abs_self _))

theorem abs_lt_abs_of_sq_lt_sq (h : x ^ 2 < y ^ 2) : |x| < |y| :=
  lt_of_pow_lt_pow 2 (abs_nonneg y)$
    by 
      rwa [←sq_abs x, ←sq_abs y] at h

theorem abs_lt_of_sq_lt_sq (h : x ^ 2 < y ^ 2) (hy : 0 ≤ y) : |x| < y :=
  by 
    rw [←abs_of_nonneg hy]
    exact abs_lt_abs_of_sq_lt_sq h

theorem abs_lt_of_sq_lt_sq' (h : x ^ 2 < y ^ 2) (hy : 0 ≤ y) : -y < x ∧ x < y :=
  abs_lt.mp$ abs_lt_of_sq_lt_sq h hy

theorem abs_le_abs_of_sq_le_sq (h : x ^ 2 ≤ y ^ 2) : |x| ≤ |y| :=
  le_of_pow_le_pow 2 (abs_nonneg y) (1 : ℕ).succ_pos$
    by 
      rwa [←sq_abs x, ←sq_abs y] at h

theorem abs_le_of_sq_le_sq (h : x ^ 2 ≤ y ^ 2) (hy : 0 ≤ y) : |x| ≤ y :=
  by 
    rw [←abs_of_nonneg hy]
    exact abs_le_abs_of_sq_le_sq h

theorem abs_le_of_sq_le_sq' (h : x ^ 2 ≤ y ^ 2) (hy : 0 ≤ y) : -y ≤ x ∧ x ≤ y :=
  abs_le.mp$ abs_le_of_sq_le_sq h hy

end LinearOrderedRing

section LinearOrderedCommRing

variable[LinearOrderedCommRing R]

/-- Arithmetic mean-geometric mean (AM-GM) inequality for linearly ordered commutative rings. -/
theorem two_mul_le_add_sq (a b : R) : ((2*a)*b) ≤ (a ^ 2)+b ^ 2 :=
  sub_nonneg.mp ((sub_add_eq_add_sub _ _ _).subst ((sub_sq a b).subst (sq_nonneg _)))

alias two_mul_le_add_sq ← two_mul_le_add_pow_two

end LinearOrderedCommRing

