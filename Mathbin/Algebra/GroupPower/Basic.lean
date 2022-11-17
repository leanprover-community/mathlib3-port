/-
Copyright (c) 2015 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Robert Y. Lewis
-/
import Mathbin.Algebra.Divisibility.Basic
import Mathbin.Algebra.Group.Commute
import Mathbin.Algebra.Group.TypeTags

/-!
# Power operations on monoids and groups

The power operation on monoids and groups.
We separate this from group, because it depends on `ℕ`,
which in turn depends on other parts of algebra.

This module contains lemmas about `a ^ n` and `n • a`, where `n : ℕ` or `n : ℤ`.
Further lemmas can be found in `algebra.group_power.lemmas`.

The analogous results for groups with zero can be found in `algebra.group_with_zero.power`.

## Notation

- `a ^ n` is used as notation for `has_pow.pow a n`; in this file `n : ℕ` or `n : ℤ`.
- `n • a` is used as notation for `has_smul.smul n a`; in this file `n : ℕ` or `n : ℤ`.

## Implementation details

We adopt the convention that `0^0 = 1`.
-/


universe u v w x y z u₁ u₂

variable {α : Type _} {M : Type u} {N : Type v} {G : Type w} {H : Type x} {A : Type y} {B : Type z} {R : Type u₁}
  {S : Type u₂}

/-!
### Commutativity

First we prove some facts about `semiconj_by` and `commute`. They do not require any theory about
`pow` and/or `nsmul` and will be useful later in this file.
-/


section Pow

variable [Pow M ℕ]

@[simp]
theorem pow_ite (P : Prop) [Decidable P] (a : M) (b c : ℕ) : (a ^ if P then b else c) = if P then a ^ b else a ^ c := by
  split_ifs <;> rfl
#align pow_ite pow_ite

@[simp]
theorem ite_pow (P : Prop) [Decidable P] (a b : M) (c : ℕ) : (if P then a else b) ^ c = if P then a ^ c else b ^ c := by
  split_ifs <;> rfl
#align ite_pow ite_pow

end Pow

section Monoid

variable [Monoid M] [Monoid N] [AddMonoid A] [AddMonoid B]

#print pow_one /-
@[simp, to_additive one_nsmul]
theorem pow_one (a : M) : a ^ 1 = a := by rw [pow_succ, pow_zero, mul_one]
#align pow_one pow_one
-/

/-- Note that most of the lemmas about powers of two refer to it as `sq`. -/
@[to_additive two_nsmul, nolint to_additive_doc]
theorem pow_two (a : M) : a ^ 2 = a * a := by rw [pow_succ, pow_one]
#align pow_two pow_two

alias pow_two ← sq

theorem pow_three' (a : M) : a ^ 3 = a * a * a := by rw [pow_succ', pow_two]
#align pow_three' pow_three'

theorem pow_three (a : M) : a ^ 3 = a * (a * a) := by rw [pow_succ, pow_two]
#align pow_three pow_three

@[to_additive]
theorem pow_mul_comm' (a : M) (n : ℕ) : a ^ n * a = a * a ^ n :=
  Commute.pow_self a n
#align pow_mul_comm' pow_mul_comm'

/- warning: pow_add -> pow_add is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u}} [_inst_1 : Monoid.{u} M] (a : M) (m : Nat) (n : Nat), Eq.{succ u} M (HPow.hPow.{u 0 u} M Nat M (instHPow.{u 0} M Nat (Monoid.hasPow.{u} M _inst_1)) a (HAdd.hAdd.{0 0 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) m n)) (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M (Monoid.toMulOneClass.{u} M _inst_1))) (HPow.hPow.{u 0 u} M Nat M (instHPow.{u 0} M Nat (Monoid.hasPow.{u} M _inst_1)) a m) (HPow.hPow.{u 0 u} M Nat M (instHPow.{u 0} M Nat (Monoid.hasPow.{u} M _inst_1)) a n))
but is expected to have type
  forall {M : Type.{u_1}} [inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.427 : Monoid.{u_1} M] (a : M) (m : Nat) (n : Nat), Eq.{succ u_1} M (HPow.hPow.{u_1 0 u_1} M Nat M (instHPow.{u_1 0} M Nat (Monoid.Pow.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.427)) a (HAdd.hAdd.{0 0 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) m n)) (HMul.hMul.{u_1 u_1 u_1} M M M (instHMul.{u_1} M (MulOneClass.toMul.{u_1} M (Monoid.toMulOneClass.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.427))) (HPow.hPow.{u_1 0 u_1} M Nat M (instHPow.{u_1 0} M Nat (Monoid.Pow.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.427)) a m) (HPow.hPow.{u_1 0 u_1} M Nat M (instHPow.{u_1 0} M Nat (Monoid.Pow.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.427)) a n))
Case conversion may be inaccurate. Consider using '#align pow_add pow_addₓ'. -/
@[to_additive add_nsmul]
theorem pow_add (a : M) (m n : ℕ) : a ^ (m + n) = a ^ m * a ^ n := by
  induction' n with n ih <;> [rw [Nat.add_zero, pow_zero, mul_one],
    rw [pow_succ', ← mul_assoc, ← ih, ← pow_succ', Nat.add_assoc]]
#align pow_add pow_add

@[simp]
theorem pow_boole (P : Prop) [Decidable P] (a : M) : (a ^ if P then 1 else 0) = if P then a else 1 := by simp
#align pow_boole pow_boole

/- warning: one_pow -> one_pow is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u}} [_inst_1 : Monoid.{u} M] (n : Nat), Eq.{succ u} M (HPow.hPow.{u 0 u} M Nat M (instHPow.{u 0} M Nat (Monoid.hasPow.{u} M _inst_1)) (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M (Monoid.toMulOneClass.{u} M _inst_1))))) n) (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M (Monoid.toMulOneClass.{u} M _inst_1)))))
but is expected to have type
  forall {M : Type.{u_1}} [inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.316 : Monoid.{u_1} M] (n : Nat), Eq.{succ u_1} M (HPow.hPow.{u_1 0 u_1} M Nat M (instHPow.{u_1 0} M Nat (Monoid.Pow.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.316)) (OfNat.ofNat.{u_1} M 1 (One.toOfNat1.{u_1} M (Monoid.toOne.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.316))) n) (OfNat.ofNat.{u_1} M 1 (One.toOfNat1.{u_1} M (Monoid.toOne.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.316)))
Case conversion may be inaccurate. Consider using '#align one_pow one_powₓ'. -/
-- the attributes are intentionally out of order. `smul_zero` proves `nsmul_zero`.
@[to_additive nsmul_zero, simp]
theorem one_pow (n : ℕ) : (1 : M) ^ n = 1 := by
  induction' n with n ih <;> [exact pow_zero _, rw [pow_succ, ih, one_mul]]
#align one_pow one_pow

#print pow_mul /-
@[to_additive mul_nsmul']
theorem pow_mul (a : M) (m n : ℕ) : a ^ (m * n) = (a ^ m) ^ n := by
  induction' n with n ih
  · rw [Nat.mul_zero, pow_zero, pow_zero]
    
  · rw [Nat.mul_succ, pow_add, pow_succ', ih]
    
#align pow_mul pow_mul
-/

@[to_additive nsmul_left_comm]
theorem pow_right_comm (a : M) (m n : ℕ) : (a ^ m) ^ n = (a ^ n) ^ m := by rw [← pow_mul, Nat.mul_comm, pow_mul]
#align pow_right_comm pow_right_comm

@[to_additive mul_nsmul]
theorem pow_mul' (a : M) (m n : ℕ) : a ^ (m * n) = (a ^ n) ^ m := by rw [Nat.mul_comm, pow_mul]
#align pow_mul' pow_mul'

@[to_additive nsmul_add_sub_nsmul]
theorem pow_mul_pow_sub (a : M) {m n : ℕ} (h : m ≤ n) : a ^ m * a ^ (n - m) = a ^ n := by
  rw [← pow_add, Nat.add_comm, Nat.sub_add_cancel h]
#align pow_mul_pow_sub pow_mul_pow_sub

@[to_additive sub_nsmul_nsmul_add]
theorem pow_sub_mul_pow (a : M) {m n : ℕ} (h : m ≤ n) : a ^ (n - m) * a ^ m = a ^ n := by
  rw [← pow_add, Nat.sub_add_cancel h]
#align pow_sub_mul_pow pow_sub_mul_pow

/-- If `x ^ n = 1`, then `x ^ m` is the same as `x ^ (m % n)` -/
@[to_additive nsmul_eq_mod_nsmul "If `n • x = 0`, then `m • x` is the same as `(m % n) • x`"]
theorem pow_eq_pow_mod {M : Type _} [Monoid M] {x : M} (m : ℕ) {n : ℕ} (h : x ^ n = 1) : x ^ m = x ^ (m % n) := by
  have t := congr_arg (fun a => x ^ a) ((Nat.add_comm _ _).trans (Nat.mod_add_div _ _)).symm
  dsimp at t
  rw [t, pow_add, pow_mul, h, one_pow, one_mul]
#align pow_eq_pow_mod pow_eq_pow_mod

@[to_additive bit0_nsmul]
theorem pow_bit0 (a : M) (n : ℕ) : a ^ bit0 n = a ^ n * a ^ n :=
  pow_add _ _ _
#align pow_bit0 pow_bit0

@[to_additive bit1_nsmul]
theorem pow_bit1 (a : M) (n : ℕ) : a ^ bit1 n = a ^ n * a ^ n * a := by rw [bit1, pow_succ', pow_bit0]
#align pow_bit1 pow_bit1

@[to_additive]
theorem pow_mul_comm (a : M) (m n : ℕ) : a ^ m * a ^ n = a ^ n * a ^ m :=
  Commute.pow_pow_self a m n
#align pow_mul_comm pow_mul_comm

/- warning: commute.mul_pow -> Commute.mul_pow is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u}} [_inst_1 : Monoid.{u} M] {a : M} {b : M}, (Commute.{u} M (MulOneClass.toHasMul.{u} M (Monoid.toMulOneClass.{u} M _inst_1)) a b) -> (forall (n : Nat), Eq.{succ u} M (HPow.hPow.{u 0 u} M Nat M (instHPow.{u 0} M Nat (Monoid.hasPow.{u} M _inst_1)) (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M (Monoid.toMulOneClass.{u} M _inst_1))) a b) n) (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M (Monoid.toMulOneClass.{u} M _inst_1))) (HPow.hPow.{u 0 u} M Nat M (instHPow.{u 0} M Nat (Monoid.hasPow.{u} M _inst_1)) a n) (HPow.hPow.{u 0 u} M Nat M (instHPow.{u 0} M Nat (Monoid.hasPow.{u} M _inst_1)) b n)))
but is expected to have type
  forall {M : Type.{u_1}} [inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.627 : Monoid.{u_1} M] {a : M} {b : M}, (Commute.{u_1} M (MulOneClass.toMul.{u_1} M (Monoid.toMulOneClass.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.627)) a b) -> (forall (n : Nat), Eq.{succ u_1} M (HPow.hPow.{u_1 0 u_1} M Nat M (instHPow.{u_1 0} M Nat (Monoid.Pow.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.627)) (HMul.hMul.{u_1 u_1 u_1} M M M (instHMul.{u_1} M (MulOneClass.toMul.{u_1} M (Monoid.toMulOneClass.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.627))) a b) n) (HMul.hMul.{u_1 u_1 u_1} M M M (instHMul.{u_1} M (MulOneClass.toMul.{u_1} M (Monoid.toMulOneClass.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.627))) (HPow.hPow.{u_1 0 u_1} M Nat M (instHPow.{u_1 0} M Nat (Monoid.Pow.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.627)) a n) (HPow.hPow.{u_1 0 u_1} M Nat M (instHPow.{u_1 0} M Nat (Monoid.Pow.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.627)) b n)))
Case conversion may be inaccurate. Consider using '#align commute.mul_pow Commute.mul_powₓ'. -/
@[to_additive]
theorem Commute.mul_pow {a b : M} (h : Commute a b) (n : ℕ) : (a * b) ^ n = a ^ n * b ^ n :=
  Nat.recOn n (by simp only [pow_zero, one_mul]) $ fun n ihn => by
    simp only [pow_succ, ihn, ← mul_assoc, (h.pow_left n).right_comm]
#align commute.mul_pow Commute.mul_pow

@[to_additive bit0_nsmul']
theorem pow_bit0' (a : M) (n : ℕ) : a ^ bit0 n = (a * a) ^ n := by rw [pow_bit0, (Commute.refl a).mul_pow]
#align pow_bit0' pow_bit0'

@[to_additive bit1_nsmul']
theorem pow_bit1' (a : M) (n : ℕ) : a ^ bit1 n = (a * a) ^ n * a := by rw [bit1, pow_succ', pow_bit0']
#align pow_bit1' pow_bit1'

@[to_additive]
theorem pow_mul_pow_eq_one {a b : M} (n : ℕ) (h : a * b = 1) : a ^ n * b ^ n = 1 := by
  induction' n with n hn
  · simp
    
  · calc
      a ^ n.succ * b ^ n.succ = a ^ n * a * (b * b ^ n) := by rw [pow_succ', pow_succ]
      _ = a ^ n * (a * b) * b ^ n := by simp only [mul_assoc]
      _ = 1 := by simp [h, hn]
      
    
#align pow_mul_pow_eq_one pow_mul_pow_eq_one

theorem dvd_pow {x y : M} (hxy : x ∣ y) : ∀ {n : ℕ} (hn : n ≠ 0), x ∣ y ^ n
  | 0, hn => (hn rfl).elim
  | n + 1, hn => by
    rw [pow_succ]
    exact hxy.mul_right _
#align dvd_pow dvd_pow

alias dvd_pow ← Dvd.Dvd.pow

theorem dvd_pow_self (a : M) {n : ℕ} (hn : n ≠ 0) : a ∣ a ^ n :=
  dvd_rfl.pow hn
#align dvd_pow_self dvd_pow_self

end Monoid

/-!
### Commutative (additive) monoid
-/


section CommMonoid

variable [CommMonoid M] [AddCommMonoid A]

/- warning: mul_pow -> mul_pow is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u}} [_inst_1 : CommMonoid.{u} M] (a : M) (b : M) (n : Nat), Eq.{succ u} M (HPow.hPow.{u 0 u} M Nat M (instHPow.{u 0} M Nat (Monoid.hasPow.{u} M (CommMonoid.toMonoid.{u} M _inst_1))) (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M (Monoid.toMulOneClass.{u} M (CommMonoid.toMonoid.{u} M _inst_1)))) a b) n) (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M (Monoid.toMulOneClass.{u} M (CommMonoid.toMonoid.{u} M _inst_1)))) (HPow.hPow.{u 0 u} M Nat M (instHPow.{u 0} M Nat (Monoid.hasPow.{u} M (CommMonoid.toMonoid.{u} M _inst_1))) a n) (HPow.hPow.{u 0 u} M Nat M (instHPow.{u 0} M Nat (Monoid.hasPow.{u} M (CommMonoid.toMonoid.{u} M _inst_1))) b n))
but is expected to have type
  forall {M : Type.{u_1}} [inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.718 : CommMonoid.{u_1} M] (a : M) (b : M) (n : Nat), Eq.{succ u_1} M (HPow.hPow.{u_1 0 u_1} M Nat M (instHPow.{u_1 0} M Nat (Monoid.Pow.{u_1} M (CommMonoid.toMonoid.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.718))) (HMul.hMul.{u_1 u_1 u_1} M M M (instHMul.{u_1} M (MulOneClass.toMul.{u_1} M (Monoid.toMulOneClass.{u_1} M (CommMonoid.toMonoid.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.718)))) a b) n) (HMul.hMul.{u_1 u_1 u_1} M M M (instHMul.{u_1} M (MulOneClass.toMul.{u_1} M (Monoid.toMulOneClass.{u_1} M (CommMonoid.toMonoid.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.718)))) (HPow.hPow.{u_1 0 u_1} M Nat M (instHPow.{u_1 0} M Nat (Monoid.Pow.{u_1} M (CommMonoid.toMonoid.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.718))) a n) (HPow.hPow.{u_1 0 u_1} M Nat M (instHPow.{u_1 0} M Nat (Monoid.Pow.{u_1} M (CommMonoid.toMonoid.{u_1} M inst._@.Mathlib.Algebra.GroupPower.Basic._hyg.718))) b n))
Case conversion may be inaccurate. Consider using '#align mul_pow mul_powₓ'. -/
@[to_additive nsmul_add]
theorem mul_pow (a b : M) (n : ℕ) : (a * b) ^ n = a ^ n * b ^ n :=
  (Commute.all a b).mul_pow n
#align mul_pow mul_pow

/-- The `n`th power map on a commutative monoid for a natural `n`, considered as a morphism of
monoids. -/
@[to_additive
      "Multiplication by a natural `n` on a commutative additive\nmonoid, considered as a morphism of additive monoids.",
  simps]
def powMonoidHom (n : ℕ) : M →* M where
  toFun := (· ^ n)
  map_one' := one_pow _
  map_mul' a b := mul_pow a b n
#align pow_monoid_hom powMonoidHom

-- the below line causes the linter to complain :-/
-- attribute [simps] pow_monoid_hom nsmul_add_monoid_hom
end CommMonoid

section DivInvMonoid

variable [DivInvMonoid G]

open Int

@[simp, to_additive one_zsmul]
theorem zpow_one (a : G) : a ^ (1 : ℤ) = a := by
  convert pow_one a using 1
  exact zpow_coe_nat a 1
#align zpow_one zpow_one

@[to_additive two_zsmul]
theorem zpow_two (a : G) : a ^ (2 : ℤ) = a * a := by
  convert pow_two a using 1
  exact zpow_coe_nat a 2
#align zpow_two zpow_two

@[to_additive neg_one_zsmul]
theorem zpow_neg_one (x : G) : x ^ (-1 : ℤ) = x⁻¹ :=
  (zpow_neg_succ_of_nat x 0).trans $ congr_arg Inv.inv (pow_one x)
#align zpow_neg_one zpow_neg_one

@[to_additive]
theorem zpow_neg_coe_of_pos (a : G) : ∀ {n : ℕ}, 0 < n → a ^ (-(n : ℤ)) = (a ^ n)⁻¹
  | n + 1, _ => zpow_neg_succ_of_nat _ _
#align zpow_neg_coe_of_pos zpow_neg_coe_of_pos

end DivInvMonoid

section DivisionMonoid

variable [DivisionMonoid α] {a b : α}

@[simp, to_additive]
theorem inv_pow (a : α) : ∀ n : ℕ, a⁻¹ ^ n = (a ^ n)⁻¹
  | 0 => by rw [pow_zero, pow_zero, inv_one]
  | n + 1 => by rw [pow_succ', pow_succ, inv_pow, mul_inv_rev]
#align inv_pow inv_pow

-- the attributes are intentionally out of order. `smul_zero` proves `zsmul_zero`.
@[to_additive zsmul_zero, simp]
theorem one_zpow : ∀ n : ℤ, (1 : α) ^ n = 1
  | (n : ℕ) => by rw [zpow_coe_nat, one_pow]
  | -[1+ n] => by rw [zpow_neg_succ_of_nat, one_pow, inv_one]
#align one_zpow one_zpow

@[simp, to_additive neg_zsmul]
theorem zpow_neg (a : α) : ∀ n : ℤ, a ^ (-n) = (a ^ n)⁻¹
  | (n + 1 : ℕ) => DivInvMonoid.zpow_neg' _ _
  | 0 => by
    change a ^ (0 : ℤ) = (a ^ (0 : ℤ))⁻¹
    simp
  | -[1+ n] => by
    rw [zpow_neg_succ_of_nat, inv_inv, ← zpow_coe_nat]
    rfl
#align zpow_neg zpow_neg

@[to_additive neg_one_zsmul_add]
theorem mul_zpow_neg_one (a b : α) : (a * b) ^ (-1 : ℤ) = b ^ (-1 : ℤ) * a ^ (-1 : ℤ) := by
  simp_rw [zpow_neg_one, mul_inv_rev]
#align mul_zpow_neg_one mul_zpow_neg_one

@[to_additive zsmul_neg]
theorem inv_zpow (a : α) : ∀ n : ℤ, a⁻¹ ^ n = (a ^ n)⁻¹
  | (n : ℕ) => by rw [zpow_coe_nat, zpow_coe_nat, inv_pow]
  | -[1+ n] => by rw [zpow_neg_succ_of_nat, zpow_neg_succ_of_nat, inv_pow]
#align inv_zpow inv_zpow

@[simp, to_additive zsmul_neg']
theorem inv_zpow' (a : α) (n : ℤ) : a⁻¹ ^ n = a ^ (-n) := by rw [inv_zpow, zpow_neg]
#align inv_zpow' inv_zpow'

@[to_additive nsmul_zero_sub]
theorem one_div_pow (a : α) (n : ℕ) : (1 / a) ^ n = 1 / a ^ n := by simp_rw [one_div, inv_pow]
#align one_div_pow one_div_pow

@[to_additive zsmul_zero_sub]
theorem one_div_zpow (a : α) (n : ℤ) : (1 / a) ^ n = 1 / a ^ n := by simp_rw [one_div, inv_zpow]
#align one_div_zpow one_div_zpow

@[to_additive AddCommute.zsmul_add]
protected theorem Commute.mul_zpow (h : Commute a b) : ∀ i : ℤ, (a * b) ^ i = a ^ i * b ^ i
  | (n : ℕ) => by simp [h.mul_pow n]
  | -[1+ n] => by simp [h.mul_pow, (h.pow_pow _ _).Eq, mul_inv_rev]
#align commute.mul_zpow Commute.mul_zpow

end DivisionMonoid

section DivisionCommMonoid

variable [DivisionCommMonoid α]

@[to_additive zsmul_add]
theorem mul_zpow (a b : α) : ∀ n : ℤ, (a * b) ^ n = a ^ n * b ^ n :=
  (Commute.all a b).mul_zpow
#align mul_zpow mul_zpow

@[simp, to_additive nsmul_sub]
theorem div_pow (a b : α) (n : ℕ) : (a / b) ^ n = a ^ n / b ^ n := by simp only [div_eq_mul_inv, mul_pow, inv_pow]
#align div_pow div_pow

@[simp, to_additive zsmul_sub]
theorem div_zpow (a b : α) (n : ℤ) : (a / b) ^ n = a ^ n / b ^ n := by simp only [div_eq_mul_inv, mul_zpow, inv_zpow]
#align div_zpow div_zpow

/-- The `n`-th power map (for an integer `n`) on a commutative group, considered as a group
homomorphism. -/
@[to_additive
      "Multiplication by an integer `n` on a commutative additive group, considered as an\nadditive group homomorphism.",
  simps]
def zpowGroupHom (n : ℤ) : α →* α where
  toFun := (· ^ n)
  map_one' := one_zpow n
  map_mul' a b := mul_zpow a b n
#align zpow_group_hom zpowGroupHom

end DivisionCommMonoid

section Group

variable [Group G] [Group H] [AddGroup A] [AddGroup B]

@[to_additive sub_nsmul]
theorem pow_sub (a : G) {m n : ℕ} (h : n ≤ m) : a ^ (m - n) = a ^ m * (a ^ n)⁻¹ :=
  eq_mul_inv_of_mul_eq $ by rw [← pow_add, Nat.sub_add_cancel h]
#align pow_sub pow_sub

@[to_additive]
theorem pow_inv_comm (a : G) (m n : ℕ) : a⁻¹ ^ m * a ^ n = a ^ n * a⁻¹ ^ m :=
  (Commute.refl a).inv_left.pow_pow _ _
#align pow_inv_comm pow_inv_comm

@[to_additive sub_nsmul_neg]
theorem inv_pow_sub (a : G) {m n : ℕ} (h : n ≤ m) : a⁻¹ ^ (m - n) = (a ^ m)⁻¹ * a ^ n := by
  rw [pow_sub a⁻¹ h, inv_pow, inv_pow, inv_inv]
#align inv_pow_sub inv_pow_sub

end Group

theorem pow_dvd_pow [Monoid R] (a : R) {m n : ℕ} (h : m ≤ n) : a ^ m ∣ a ^ n :=
  ⟨a ^ (n - m), by rw [← pow_add, Nat.add_comm, Nat.sub_add_cancel h]⟩
#align pow_dvd_pow pow_dvd_pow

theorem of_add_nsmul [AddMonoid A] (x : A) (n : ℕ) : Multiplicative.ofAdd (n • x) = Multiplicative.ofAdd x ^ n :=
  rfl
#align of_add_nsmul of_add_nsmul

theorem of_add_zsmul [SubNegMonoid A] (x : A) (n : ℤ) : Multiplicative.ofAdd (n • x) = Multiplicative.ofAdd x ^ n :=
  rfl
#align of_add_zsmul of_add_zsmul

theorem of_mul_pow [Monoid A] (x : A) (n : ℕ) : Additive.ofMul (x ^ n) = n • Additive.ofMul x :=
  rfl
#align of_mul_pow of_mul_pow

theorem of_mul_zpow [DivInvMonoid G] (x : G) (n : ℤ) : Additive.ofMul (x ^ n) = n • Additive.ofMul x :=
  rfl
#align of_mul_zpow of_mul_zpow

@[simp, to_additive]
theorem SemiconjBy.zpow_right [Group G] {a x y : G} (h : SemiconjBy a x y) : ∀ m : ℤ, SemiconjBy a (x ^ m) (y ^ m)
  | (n : ℕ) => by simp [zpow_coe_nat, h.pow_right n]
  | -[1+ n] => by simp [(h.pow_right n.succ).inv_right]
#align semiconj_by.zpow_right SemiconjBy.zpow_right

namespace Commute

variable [Group G] {a b : G}

@[simp, to_additive]
theorem zpow_right (h : Commute a b) (m : ℤ) : Commute a (b ^ m) :=
  h.zpow_right m
#align commute.zpow_right Commute.zpow_right

@[simp, to_additive]
theorem zpow_left (h : Commute a b) (m : ℤ) : Commute (a ^ m) b :=
  (h.symm.zpow_right m).symm
#align commute.zpow_left Commute.zpow_left

@[to_additive]
theorem zpow_zpow (h : Commute a b) (m n : ℤ) : Commute (a ^ m) (b ^ n) :=
  (h.zpow_left m).zpow_right n
#align commute.zpow_zpow Commute.zpow_zpow

variable (a) (m n : ℤ)

@[simp, to_additive]
theorem self_zpow : Commute a (a ^ n) :=
  (Commute.refl a).zpow_right n
#align commute.self_zpow Commute.self_zpow

@[simp, to_additive]
theorem zpow_self : Commute (a ^ n) a :=
  (Commute.refl a).zpow_left n
#align commute.zpow_self Commute.zpow_self

@[simp, to_additive]
theorem zpow_zpow_self : Commute (a ^ m) (a ^ n) :=
  (Commute.refl a).zpow_zpow m n
#align commute.zpow_zpow_self Commute.zpow_zpow_self

end Commute

