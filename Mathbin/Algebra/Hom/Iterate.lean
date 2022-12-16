/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module algebra.hom.iterate
! leanprover-community/mathlib commit d012cd09a9b256d870751284dd6a29882b0be105
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Logic.Function.Iterate
import Mathbin.GroupTheory.Perm.Basic
import Mathbin.GroupTheory.GroupAction.Opposite

/-!
# Iterates of monoid and ring homomorphisms

Iterate of a monoid/ring homomorphism is a monoid/ring homomorphism but it has a wrong type, so Lean
can't apply lemmas like `monoid_hom.map_one` to `f^[n] 1`. Though it is possible to define
a monoid structure on the endomorphisms, quite often we do not want to convert from
`M →* M` to `monoid.End M` and from `f^[n]` to `f^n` just to apply a simple lemma.

So, we restate standard `*_hom.map_*` lemmas under names `*_hom.iterate_map_*`.

We also prove formulas for iterates of add/mul left/right.

## Tags

homomorphism, iterate
-/


open Function

variable {M : Type _} {N : Type _} {G : Type _} {H : Type _}

/-- An auxiliary lemma that can be used to prove `⇑(f ^ n) = (⇑f^[n])`. -/
theorem hom_coe_pow {F : Type _} [Monoid F] (c : F → M → M) (h1 : c 1 = id)
    (hmul : ∀ f g, c (f * g) = c f ∘ c g) (f : F) : ∀ n, c (f ^ n) = c f^[n]
  | 0 => by 
    rw [pow_zero, h1]
    rfl
  | n + 1 => by rw [pow_succ, iterate_succ', hmul, hom_coe_pow]
#align hom_coe_pow hom_coe_pow

namespace MonoidHom

section

variable [MulOneClass M] [MulOneClass N]

@[simp, to_additive]
theorem iterate_map_one (f : M →* M) (n : ℕ) : (f^[n]) 1 = 1 :=
  iterate_fixed f.map_one n
#align monoid_hom.iterate_map_one MonoidHom.iterate_map_one

@[simp, to_additive]
theorem iterate_map_mul (f : M →* M) (n : ℕ) (x y) : (f^[n]) (x * y) = (f^[n]) x * (f^[n]) y :=
  Semiconj₂.iterate f.map_mul n x y
#align monoid_hom.iterate_map_mul MonoidHom.iterate_map_mul

end

variable [Monoid M] [Monoid N] [Group G] [Group H]

@[simp, to_additive]
theorem iterate_map_inv (f : G →* G) (n : ℕ) (x) : (f^[n]) x⁻¹ = ((f^[n]) x)⁻¹ :=
  Commute.iterate_left f.map_inv n x
#align monoid_hom.iterate_map_inv MonoidHom.iterate_map_inv

@[simp, to_additive]
theorem iterate_map_div (f : G →* G) (n : ℕ) (x y) : (f^[n]) (x / y) = (f^[n]) x / (f^[n]) y :=
  Semiconj₂.iterate f.map_div n x y
#align monoid_hom.iterate_map_div MonoidHom.iterate_map_div

theorem iterate_map_pow (f : M →* M) (n : ℕ) (a) (m : ℕ) : (f^[n]) (a ^ m) = (f^[n]) a ^ m :=
  Commute.iterate_left (fun x => f.map_pow x m) n a
#align monoid_hom.iterate_map_pow MonoidHom.iterate_map_pow

theorem iterate_map_zpow (f : G →* G) (n : ℕ) (a) (m : ℤ) : (f^[n]) (a ^ m) = (f^[n]) a ^ m :=
  Commute.iterate_left (fun x => f.map_zpow x m) n a
#align monoid_hom.iterate_map_zpow MonoidHom.iterate_map_zpow

theorem coe_pow {M} [CommMonoid M] (f : Monoid.End M) (n : ℕ) : ⇑(f ^ n) = f^[n] :=
  hom_coe_pow _ rfl (fun f g => rfl) _ _
#align monoid_hom.coe_pow MonoidHom.coe_pow

end MonoidHom

theorem Monoid.End.coe_pow {M} [Monoid M] (f : Monoid.End M) (n : ℕ) : ⇑(f ^ n) = f^[n] :=
  hom_coe_pow _ rfl (fun f g => rfl) _ _
#align monoid.End.coe_pow Monoid.End.coe_pow

-- we define these manually so that we can pick a better argument order
namespace AddMonoidHom

variable [AddMonoid M] [AddGroup G]

theorem iterate_map_smul (f : M →+ M) (n m : ℕ) (x : M) : (f^[n]) (m • x) = m • (f^[n]) x :=
  f.toMultiplicative.iterate_map_pow n x m
#align add_monoid_hom.iterate_map_smul AddMonoidHom.iterate_map_smul

attribute [to_additive, to_additive_reorder 5] MonoidHom.iterate_map_pow

theorem iterate_map_zsmul (f : G →+ G) (n : ℕ) (m : ℤ) (x : G) : (f^[n]) (m • x) = m • (f^[n]) x :=
  f.toMultiplicative.iterate_map_zpow n x m
#align add_monoid_hom.iterate_map_zsmul AddMonoidHom.iterate_map_zsmul

attribute [to_additive, to_additive_reorder 5] MonoidHom.iterate_map_zpow

end AddMonoidHom

theorem AddMonoid.End.coe_pow {A} [AddMonoid A] (f : AddMonoid.End A) (n : ℕ) : ⇑(f ^ n) = f^[n] :=
  hom_coe_pow _ rfl (fun f g => rfl) _ _
#align add_monoid.End.coe_pow AddMonoid.End.coe_pow

namespace RingHom

section Semiring

variable {R : Type _} [Semiring R] (f : R →+* R) (n : ℕ) (x y : R)

theorem coe_pow (n : ℕ) : ⇑(f ^ n) = f^[n] :=
  hom_coe_pow _ rfl (fun f g => rfl) f n
#align ring_hom.coe_pow RingHom.coe_pow

theorem iterate_map_one : (f^[n]) 1 = 1 :=
  f.toMonoidHom.iterate_map_one n
#align ring_hom.iterate_map_one RingHom.iterate_map_one

theorem iterate_map_zero : (f^[n]) 0 = 0 :=
  f.toAddMonoidHom.iterate_map_zero n
#align ring_hom.iterate_map_zero RingHom.iterate_map_zero

theorem iterate_map_add : (f^[n]) (x + y) = (f^[n]) x + (f^[n]) y :=
  f.toAddMonoidHom.iterate_map_add n x y
#align ring_hom.iterate_map_add RingHom.iterate_map_add

theorem iterate_map_mul : (f^[n]) (x * y) = (f^[n]) x * (f^[n]) y :=
  f.toMonoidHom.iterate_map_mul n x y
#align ring_hom.iterate_map_mul RingHom.iterate_map_mul

theorem iterate_map_pow (a) (n m : ℕ) : (f^[n]) (a ^ m) = (f^[n]) a ^ m :=
  f.toMonoidHom.iterate_map_pow n a m
#align ring_hom.iterate_map_pow RingHom.iterate_map_pow

theorem iterate_map_smul (n m : ℕ) (x : R) : (f^[n]) (m • x) = m • (f^[n]) x :=
  f.toAddMonoidHom.iterate_map_smul n m x
#align ring_hom.iterate_map_smul RingHom.iterate_map_smul

end Semiring

variable {R : Type _} [Ring R] (f : R →+* R) (n : ℕ) (x y : R)

theorem iterate_map_sub : (f^[n]) (x - y) = (f^[n]) x - (f^[n]) y :=
  f.toAddMonoidHom.iterate_map_sub n x y
#align ring_hom.iterate_map_sub RingHom.iterate_map_sub

theorem iterate_map_neg : (f^[n]) (-x) = -(f^[n]) x :=
  f.toAddMonoidHom.iterate_map_neg n x
#align ring_hom.iterate_map_neg RingHom.iterate_map_neg

theorem iterate_map_zsmul (n : ℕ) (m : ℤ) (x : R) : (f^[n]) (m • x) = m • (f^[n]) x :=
  f.toAddMonoidHom.iterate_map_zsmul n m x
#align ring_hom.iterate_map_zsmul RingHom.iterate_map_zsmul

end RingHom

theorem Equiv.Perm.coe_pow {α : Type _} (f : Equiv.Perm α) (n : ℕ) : ⇑(f ^ n) = f^[n] :=
  hom_coe_pow _ rfl (fun _ _ => rfl) _ _
#align equiv.perm.coe_pow Equiv.Perm.coe_pow

--what should be the namespace for this section?
section Monoid

variable [Monoid G] (a : G) (n : ℕ)

@[simp, to_additive]
theorem smul_iterate [MulAction G H] : ((· • ·) a : H → H)^[n] = (· • ·) (a ^ n) :=
  funext fun b =>
    Nat.recOn n (by rw [iterate_zero, id.def, pow_zero, one_smul]) fun n ih => by
      rw [iterate_succ', comp_app, ih, pow_succ, mul_smul]
#align smul_iterate smul_iterate

@[simp, to_additive]
theorem mul_left_iterate : (· * ·) a^[n] = (· * ·) (a ^ n) :=
  smul_iterate a n
#align mul_left_iterate mul_left_iterate

@[simp, to_additive]
theorem mul_right_iterate : (· * a)^[n] = (· * a ^ n) :=
  smul_iterate (MulOpposite.op a) n
#align mul_right_iterate mul_right_iterate

@[to_additive]
theorem mul_right_iterate_apply_one : ((· * a)^[n]) 1 = a ^ n := by simp [mul_right_iterate]
#align mul_right_iterate_apply_one mul_right_iterate_apply_one

@[simp, to_additive]
theorem pow_iterate (n : ℕ) (j : ℕ) : (fun x : G => x ^ n)^[j] = fun x => x ^ n ^ j :=
  letI : MulAction ℕ G :=
    { smul := fun n g => g ^ n
      one_smul := pow_one
      mul_smul := fun m n g => pow_mul' g m n }
  smul_iterate n j
#align pow_iterate pow_iterate

end Monoid

section Group

variable [Group G]

@[simp, to_additive]
theorem zpow_iterate (n : ℤ) (j : ℕ) : (fun x : G => x ^ n)^[j] = fun x => x ^ n ^ j :=
  letI : MulAction ℤ G :=
    { smul := fun n g => g ^ n
      one_smul := zpow_one
      mul_smul := fun m n g => zpow_mul' g m n }
  smul_iterate n j
#align zpow_iterate zpow_iterate

end Group

section Semigroup

variable [Semigroup G] {a b c : G}

@[to_additive]
theorem SemiconjBy.function_semiconj_mul_left (h : SemiconjBy a b c) :
    Function.Semiconj ((· * ·) a) ((· * ·) b) ((· * ·) c) := fun j => by
  rw [← mul_assoc, h.eq, mul_assoc]
#align semiconj_by.function_semiconj_mul_left SemiconjBy.function_semiconj_mul_left

@[to_additive]
theorem Commute.function_commute_mul_left (h : Commute a b) :
    Function.Commute ((· * ·) a) ((· * ·) b) :=
  SemiconjBy.function_semiconj_mul_left h
#align commute.function_commute_mul_left Commute.function_commute_mul_left

@[to_additive]
theorem SemiconjBy.function_semiconj_mul_right_swap (h : SemiconjBy a b c) :
    Function.Semiconj (· * a) (· * c) (· * b) := fun j => by simp_rw [mul_assoc, ← h.eq]
#align semiconj_by.function_semiconj_mul_right_swap SemiconjBy.function_semiconj_mul_right_swap

@[to_additive]
theorem Commute.function_commute_mul_right (h : Commute a b) : Function.Commute (· * a) (· * b) :=
  SemiconjBy.function_semiconj_mul_right_swap h
#align commute.function_commute_mul_right Commute.function_commute_mul_right

end Semigroup

