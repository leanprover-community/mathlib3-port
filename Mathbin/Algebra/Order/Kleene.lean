/-
Copyright (c) 2022 Siddhartha Prasad, Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Siddhartha Prasad, Yaël Dillies

! This file was ported from Lean 3 source module algebra.order.kleene
! leanprover-community/mathlib commit ac34df03f74e6f797efd6991df2e3b7f7d8d33e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Ring.Canonical
import Mathbin.Algebra.Ring.Pi
import Mathbin.Algebra.Ring.Prod
import Mathbin.Order.Hom.CompleteLattice

/-!
# Kleene Algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines idempotent semirings and Kleene algebras, which are used extensively in the theory
of computation.

An idempotent semiring is a semiring whose addition is idempotent. An idempotent semiring is
naturally a semilattice by setting `a ≤ b` if `a + b = b`.

A Kleene algebra is an idempotent semiring equipped with an additional unary operator `∗`, the
Kleene star.

## Main declarations

* `idem_semiring`: Idempotent semiring
* `idem_comm_semiring`: Idempotent commutative semiring
* `kleene_algebra`: Kleene algebra

## Notation

`a∗` is notation for `kstar a` in locale `computability`.

## References

* [D. Kozen, *A completeness theorem for Kleene algebras and the algebra of regular events*]
  [kozen1994]
* https://planetmath.org/idempotentsemiring
* https://encyclopediaofmath.org/wiki/Idempotent_semi-ring
* https://planetmath.org/kleene_algebra

## TODO

Instances for `add_opposite`, `mul_opposite`, `ulift`, `subsemiring`, `subring`, `subalgebra`.

## Tags

kleene algebra, idempotent semiring
-/


open Function

universe u

variable {α β ι : Type _} {π : ι → Type _}

#print IdemSemiring /-
/-- An idempotent semiring is a semiring with the additional property that addition is idempotent.
-/
@[protect_proj]
class IdemSemiring (α : Type u) extends Semiring α, SemilatticeSup α where
  sup := (· + ·)
  add_eq_sup : ∀ a b : α, a + b = a ⊔ b := by intros ; rfl
  bot : α := 0
  bot_le : ∀ a, bot ≤ a
#align idem_semiring IdemSemiring
-/

#print IdemCommSemiring /-
/-- An idempotent commutative semiring is a commutative semiring with the additional property that
addition is idempotent. -/
@[protect_proj]
class IdemCommSemiring (α : Type u) extends CommSemiring α, IdemSemiring α
#align idem_comm_semiring IdemCommSemiring
-/

#print KStar /-
/-- Notation typeclass for the Kleene star `∗`. -/
@[protect_proj]
class KStar (α : Type _) where
  kstar : α → α
#align has_kstar KStar
-/

-- mathport name: «expr ∗»
scoped[Computability] postfix:1024 "∗" => KStar.kstar

#print KleeneAlgebra /-
/-- A Kleene Algebra is an idempotent semiring with an additional unary operator `kstar` (for Kleene
star) that satisfies the following properties:
* `1 + a * a∗ ≤ a∗`
* `1 + a∗ * a ≤ a∗`
* If `a * c + b ≤ c`, then `a∗ * b ≤ c`
* If `c * a + b ≤ c`, then `b * a∗ ≤ c`
-/
@[protect_proj]
class KleeneAlgebra (α : Type _) extends IdemSemiring α, KStar α where
  one_le_kstar : ∀ a : α, 1 ≤ a∗
  mul_kstar_le_kstar : ∀ a : α, a * a∗ ≤ a∗
  kstar_mul_le_kstar : ∀ a : α, a∗ * a ≤ a∗
  mul_kstar_le_self : ∀ a b : α, b * a ≤ b → b * a∗ ≤ b
  kstar_mul_le_self : ∀ a b : α, a * b ≤ b → a∗ * b ≤ b
#align kleene_algebra KleeneAlgebra
-/

-- See note [lower instance priority]
instance (priority := 100) IdemSemiring.toOrderBot [IdemSemiring α] : OrderBot α :=
  { ‹IdemSemiring α› with }
#align idem_semiring.to_order_bot IdemSemiring.toOrderBot

-- See note [reducible non-instances]
/-- Construct an idempotent semiring from an idempotent addition. -/
@[reducible]
def IdemSemiring.ofSemiring [Semiring α] (h : ∀ a : α, a + a = a) : IdemSemiring α :=
  { ‹Semiring α› with
    le := fun a b => a + b = b
    le_refl := h
    le_trans := fun a b c (hab : _ = _) (hbc : _ = _) => by change _ = _;
      rw [← hbc, ← add_assoc, hab]
    le_antisymm := fun a b (hab : _ = _) (hba : _ = _) => by rwa [← hba, add_comm]
    sup := (· + ·)
    le_sup_left := fun a b => by change _ = _; rw [← add_assoc, h]
    le_sup_right := fun a b => by change _ = _; rw [add_comm, add_assoc, h]
    sup_le := fun a b c hab (hbc : _ = _) => by change _ = _; rwa [add_assoc, hbc]
    bot := 0
    bot_le := zero_add }
#align idem_semiring.of_semiring IdemSemiring.ofSemiring

section IdemSemiring

variable [IdemSemiring α] {a b c : α}

@[simp]
theorem add_eq_sup (a b : α) : a + b = a ⊔ b :=
  IdemSemiring.add_eq_sup _ _
#align add_eq_sup add_eq_sup

theorem add_idem (a : α) : a + a = a := by simp
#align add_idem add_idem

#print nsmul_eq_self /-
theorem nsmul_eq_self : ∀ {n : ℕ} (hn : n ≠ 0) (a : α), n • a = a
  | 0, h => (h rfl).elim
  | 1, h => one_nsmul
  | n + 2, h => fun a => by rw [succ_nsmul, nsmul_eq_self n.succ_ne_zero, add_idem]
#align nsmul_eq_self nsmul_eq_self
-/

theorem add_eq_left_iff_le : a + b = a ↔ b ≤ a := by simp
#align add_eq_left_iff_le add_eq_left_iff_le

theorem add_eq_right_iff_le : a + b = b ↔ a ≤ b := by simp
#align add_eq_right_iff_le add_eq_right_iff_le

alias add_eq_left_iff_le ↔ _ LE.le.add_eq_left
#align has_le.le.add_eq_left LE.le.add_eq_left

alias add_eq_right_iff_le ↔ _ LE.le.add_eq_right
#align has_le.le.add_eq_right LE.le.add_eq_right

theorem add_le_iff : a + b ≤ c ↔ a ≤ c ∧ b ≤ c := by simp
#align add_le_iff add_le_iff

theorem add_le (ha : a ≤ c) (hb : b ≤ c) : a + b ≤ c :=
  add_le_iff.2 ⟨ha, hb⟩
#align add_le add_le

#print IdemSemiring.toCanonicallyOrderedAddMonoid /-
-- See note [lower instance priority]
instance (priority := 100) IdemSemiring.toCanonicallyOrderedAddMonoid :
    CanonicallyOrderedAddMonoid α :=
  {
    ‹IdemSemiring
        α› with
    add_le_add_left := fun a b hbc c => by simp_rw [add_eq_sup]; exact sup_le_sup_left hbc _
    exists_add_of_le := fun a b h => ⟨b, h.add_eq_right.symm⟩
    le_self_add := fun a b => add_eq_right_iff_le.1 <| by rw [← add_assoc, add_idem] }
#align idem_semiring.to_canonically_ordered_add_monoid IdemSemiring.toCanonicallyOrderedAddMonoid
-/

-- See note [lower instance priority]
instance (priority := 100) IdemSemiring.toCovariantClass_mul_le :
    CovariantClass α α (· * ·) (· ≤ ·) :=
  ⟨fun a b c hbc => add_eq_left_iff_le.1 <| by rw [← mul_add, hbc.add_eq_left]⟩
#align idem_semiring.to_covariant_class_mul_le IdemSemiring.toCovariantClass_mul_le

-- See note [lower instance priority]
instance (priority := 100) IdemSemiring.toCovariantClass_swap_mul_le :
    CovariantClass α α (swap (· * ·)) (· ≤ ·) :=
  ⟨fun a b c hbc => add_eq_left_iff_le.1 <| by rw [← add_mul, hbc.add_eq_left]⟩
#align idem_semiring.to_covariant_class_swap_mul_le IdemSemiring.toCovariantClass_swap_mul_le

end IdemSemiring

section KleeneAlgebra

variable [KleeneAlgebra α] {a b c : α}

@[simp]
theorem one_le_kstar : 1 ≤ a∗ :=
  KleeneAlgebra.one_le_kstar _
#align one_le_kstar one_le_kstar

theorem mul_kstar_le_kstar : a * a∗ ≤ a∗ :=
  KleeneAlgebra.mul_kstar_le_kstar _
#align mul_kstar_le_kstar mul_kstar_le_kstar

theorem kstar_mul_le_kstar : a∗ * a ≤ a∗ :=
  KleeneAlgebra.kstar_mul_le_kstar _
#align kstar_mul_le_kstar kstar_mul_le_kstar

theorem mul_kstar_le_self : b * a ≤ b → b * a∗ ≤ b :=
  KleeneAlgebra.mul_kstar_le_self _ _
#align mul_kstar_le_self mul_kstar_le_self

theorem kstar_mul_le_self : a * b ≤ b → a∗ * b ≤ b :=
  KleeneAlgebra.kstar_mul_le_self _ _
#align kstar_mul_le_self kstar_mul_le_self

theorem mul_kstar_le (hb : b ≤ c) (ha : c * a ≤ c) : b * a∗ ≤ c :=
  (mul_le_mul_right' hb _).trans <| mul_kstar_le_self ha
#align mul_kstar_le mul_kstar_le

theorem kstar_mul_le (hb : b ≤ c) (ha : a * c ≤ c) : a∗ * b ≤ c :=
  (mul_le_mul_left' hb _).trans <| kstar_mul_le_self ha
#align kstar_mul_le kstar_mul_le

theorem kstar_le_of_mul_le_left (hb : 1 ≤ b) : b * a ≤ b → a∗ ≤ b := by simpa using mul_kstar_le hb
#align kstar_le_of_mul_le_left kstar_le_of_mul_le_left

theorem kstar_le_of_mul_le_right (hb : 1 ≤ b) : a * b ≤ b → a∗ ≤ b := by simpa using kstar_mul_le hb
#align kstar_le_of_mul_le_right kstar_le_of_mul_le_right

@[simp]
theorem le_kstar : a ≤ a∗ :=
  le_trans (le_mul_of_one_le_left' one_le_kstar) kstar_mul_le_kstar
#align le_kstar le_kstar

@[mono]
theorem kstar_mono : Monotone (KStar.kstar : α → α) := fun a b h =>
  kstar_le_of_mul_le_left one_le_kstar <| kstar_mul_le (h.trans le_kstar) <| mul_kstar_le_kstar
#align kstar_mono kstar_mono

@[simp]
theorem kstar_eq_one : a∗ = 1 ↔ a ≤ 1 :=
  ⟨le_kstar.trans_eq, fun h =>
    one_le_kstar.antisymm' <| kstar_le_of_mul_le_left le_rfl <| by rwa [one_mul]⟩
#align kstar_eq_one kstar_eq_one

@[simp]
theorem kstar_zero : (0 : α)∗ = 1 :=
  kstar_eq_one.2 zero_le_one
#align kstar_zero kstar_zero

@[simp]
theorem kstar_one : (1 : α)∗ = 1 :=
  kstar_eq_one.2 le_rfl
#align kstar_one kstar_one

@[simp]
theorem kstar_mul_kstar (a : α) : a∗ * a∗ = a∗ :=
  (mul_kstar_le le_rfl <| kstar_mul_le_kstar).antisymm <| le_mul_of_one_le_left' one_le_kstar
#align kstar_mul_kstar kstar_mul_kstar

@[simp]
theorem kstar_eq_self : a∗ = a ↔ a * a = a ∧ 1 ≤ a :=
  ⟨fun h => ⟨by rw [← h, kstar_mul_kstar], one_le_kstar.trans_eq h⟩, fun h =>
    (kstar_le_of_mul_le_left h.2 h.1.le).antisymm le_kstar⟩
#align kstar_eq_self kstar_eq_self

@[simp]
theorem kstar_idem (a : α) : a∗∗ = a∗ :=
  kstar_eq_self.2 ⟨kstar_mul_kstar _, one_le_kstar⟩
#align kstar_idem kstar_idem

@[simp]
theorem pow_le_kstar : ∀ {n : ℕ}, a ^ n ≤ a∗
  | 0 => (pow_zero _).trans_le one_le_kstar
  | n + 1 => by rw [pow_succ]; exact (mul_le_mul_left' pow_le_kstar _).trans mul_kstar_le_kstar
#align pow_le_kstar pow_le_kstar

end KleeneAlgebra

namespace Prod

instance [IdemSemiring α] [IdemSemiring β] : IdemSemiring (α × β) :=
  { Prod.semiring, Prod.semilatticeSup _ _, Prod.orderBot _ _ with
    add_eq_sup := fun a b => ext (add_eq_sup _ _) (add_eq_sup _ _) }

instance [IdemCommSemiring α] [IdemCommSemiring β] : IdemCommSemiring (α × β) :=
  { Prod.commSemiring, Prod.idemSemiring with }

variable [KleeneAlgebra α] [KleeneAlgebra β]

instance : KleeneAlgebra (α × β) :=
  { Prod.idemSemiring with
    kstar := fun a => (a.1∗, a.2∗)
    one_le_kstar := fun a => ⟨one_le_kstar, one_le_kstar⟩
    mul_kstar_le_kstar := fun a => ⟨mul_kstar_le_kstar, mul_kstar_le_kstar⟩
    kstar_mul_le_kstar := fun a => ⟨kstar_mul_le_kstar, kstar_mul_le_kstar⟩
    mul_kstar_le_self := fun a b => And.imp mul_kstar_le_self mul_kstar_le_self
    kstar_mul_le_self := fun a b => And.imp kstar_mul_le_self kstar_mul_le_self }

theorem kstar_def (a : α × β) : a∗ = (a.1∗, a.2∗) :=
  rfl
#align prod.kstar_def Prod.kstar_def

@[simp]
theorem fst_kstar (a : α × β) : a∗.1 = a.1∗ :=
  rfl
#align prod.fst_kstar Prod.fst_kstar

@[simp]
theorem snd_kstar (a : α × β) : a∗.2 = a.2∗ :=
  rfl
#align prod.snd_kstar Prod.snd_kstar

end Prod

namespace Pi

instance [∀ i, IdemSemiring (π i)] : IdemSemiring (∀ i, π i) :=
  { Pi.semiring, Pi.semilatticeSup, Pi.orderBot with
    add_eq_sup := fun a b => funext fun i => add_eq_sup _ _ }

instance [∀ i, IdemCommSemiring (π i)] : IdemCommSemiring (∀ i, π i) :=
  { Pi.commSemiring, Pi.idemSemiring with }

variable [∀ i, KleeneAlgebra (π i)]

instance : KleeneAlgebra (∀ i, π i) :=
  { Pi.idemSemiring with
    kstar := fun a i => (a i)∗
    one_le_kstar := fun a i => one_le_kstar
    mul_kstar_le_kstar := fun a i => mul_kstar_le_kstar
    kstar_mul_le_kstar := fun a i => kstar_mul_le_kstar
    mul_kstar_le_self := fun a b h i => mul_kstar_le_self <| h _
    kstar_mul_le_self := fun a b h i => kstar_mul_le_self <| h _ }

theorem kstar_def (a : ∀ i, π i) : a∗ = fun i => (a i)∗ :=
  rfl
#align pi.kstar_def Pi.kstar_def

@[simp]
theorem kstar_apply (a : ∀ i, π i) (i : ι) : a∗ i = (a i)∗ :=
  rfl
#align pi.kstar_apply Pi.kstar_apply

end Pi

namespace Function.Injective

-- See note [reducible non-instances]
/-- Pullback an `idem_semiring` instance along an injective function. -/
@[reducible]
protected def idemSemiring [IdemSemiring α] [Zero β] [One β] [Add β] [Mul β] [Pow β ℕ] [SMul ℕ β]
    [NatCast β] [Sup β] [Bot β] (f : β → α) (hf : Injective f) (zero : f 0 = 0) (one : f 1 = 1)
    (add : ∀ x y, f (x + y) = f x + f y) (mul : ∀ x y, f (x * y) = f x * f y)
    (nsmul : ∀ (x) (n : ℕ), f (n • x) = n • f x) (npow : ∀ (x) (n : ℕ), f (x ^ n) = f x ^ n)
    (nat_cast : ∀ n : ℕ, f n = n) (sup : ∀ a b, f (a ⊔ b) = f a ⊔ f b) (bot : f ⊥ = ⊥) :
    IdemSemiring β :=
  { hf.Semiring f zero one add mul nsmul npow nat_cast, hf.SemilatticeSup _ sup,
    ‹Bot β› with
    add_eq_sup := fun a b => hf <| by erw [sup, add, add_eq_sup]
    bot := ⊥
    bot_le := fun a => bot.trans_le <| @bot_le _ _ _ <| f a }
#align function.injective.idem_semiring Function.Injective.idemSemiring

-- See note [reducible non-instances]
/-- Pullback an `idem_comm_semiring` instance along an injective function. -/
@[reducible]
protected def idemCommSemiring [IdemCommSemiring α] [Zero β] [One β] [Add β] [Mul β] [Pow β ℕ]
    [SMul ℕ β] [NatCast β] [Sup β] [Bot β] (f : β → α) (hf : Injective f) (zero : f 0 = 0)
    (one : f 1 = 1) (add : ∀ x y, f (x + y) = f x + f y) (mul : ∀ x y, f (x * y) = f x * f y)
    (nsmul : ∀ (x) (n : ℕ), f (n • x) = n • f x) (npow : ∀ (x) (n : ℕ), f (x ^ n) = f x ^ n)
    (nat_cast : ∀ n : ℕ, f n = n) (sup : ∀ a b, f (a ⊔ b) = f a ⊔ f b) (bot : f ⊥ = ⊥) :
    IdemCommSemiring β :=
  { hf.CommSemiring f zero one add mul nsmul npow nat_cast,
    hf.IdemSemiring f zero one add mul nsmul npow nat_cast sup bot with }
#align function.injective.idem_comm_semiring Function.Injective.idemCommSemiring

-- See note [reducible non-instances]
/-- Pullback an `idem_comm_semiring` instance along an injective function. -/
@[reducible]
protected def kleeneAlgebra [KleeneAlgebra α] [Zero β] [One β] [Add β] [Mul β] [Pow β ℕ] [SMul ℕ β]
    [NatCast β] [Sup β] [Bot β] [KStar β] (f : β → α) (hf : Injective f) (zero : f 0 = 0)
    (one : f 1 = 1) (add : ∀ x y, f (x + y) = f x + f y) (mul : ∀ x y, f (x * y) = f x * f y)
    (nsmul : ∀ (x) (n : ℕ), f (n • x) = n • f x) (npow : ∀ (x) (n : ℕ), f (x ^ n) = f x ^ n)
    (nat_cast : ∀ n : ℕ, f n = n) (sup : ∀ a b, f (a ⊔ b) = f a ⊔ f b) (bot : f ⊥ = ⊥)
    (kstar : ∀ a, f a∗ = (f a)∗) : KleeneAlgebra β :=
  { hf.IdemSemiring f zero one add mul nsmul npow nat_cast sup bot,
    ‹KStar
        β› with
    one_le_kstar := fun a => one.trans_le <| by erw [kstar]; exact one_le_kstar
    mul_kstar_le_kstar := fun a => by change f _ ≤ _; erw [mul, kstar]; exact mul_kstar_le_kstar
    kstar_mul_le_kstar := fun a => by change f _ ≤ _; erw [mul, kstar]; exact kstar_mul_le_kstar
    mul_kstar_le_self := fun a b (h : f _ ≤ _) => by change f _ ≤ _; erw [mul, kstar];
      erw [mul] at h; exact mul_kstar_le_self h
    kstar_mul_le_self := fun a b (h : f _ ≤ _) => by change f _ ≤ _; erw [mul, kstar];
      erw [mul] at h; exact kstar_mul_le_self h }
#align function.injective.kleene_algebra Function.Injective.kleeneAlgebra

end Function.Injective

