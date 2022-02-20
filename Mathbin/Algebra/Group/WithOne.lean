/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Johan Commelin
-/
import Mathbin.Algebra.Ring.Basic
import Mathbin.Data.Equiv.Basic

/-!
# Adjoining a zero/one to semigroups and related algebraic structures

This file contains different results about adjoining an element to an algebraic structure which then
behaves like a zero or a one. An example is adjoining a one to a semigroup to obtain a monoid. That
this provides an example of an adjunction is proved in `algebra.category.Mon.adjunctions`.

Another result says that adjoining to a group an element `zero` gives a `group_with_zero`. For more
information about these structures (which are not that standard in informal mathematics, see
`algebra.group_with_zero.basic`)
-/


universe u v w

variable {α : Type u}

/-- Add an extra element `1` to a type -/
@[to_additive "Add an extra element `0` to a type"]
def WithOne α :=
  Option α

namespace WithOne

@[to_additive]
instance : Monadₓ WithOne :=
  Option.monad

@[to_additive]
instance : One (WithOne α) :=
  ⟨none⟩

@[to_additive]
instance [Mul α] : Mul (WithOne α) :=
  ⟨Option.liftOrGet (· * ·)⟩

@[to_additive]
instance [Inv α] : Inv (WithOne α) :=
  ⟨fun a => Option.map Inv.inv a⟩

@[to_additive]
instance : Inhabited (WithOne α) :=
  ⟨1⟩

@[to_additive]
instance [Nonempty α] : Nontrivial (WithOne α) :=
  Option.nontrivial

@[to_additive]
instance : CoeTₓ α (WithOne α) :=
  ⟨some⟩

@[to_additive]
theorem some_eq_coe {a : α} : (some a : WithOne α) = ↑a :=
  rfl

@[simp, to_additive]
theorem coe_ne_one {a : α} : (a : WithOne α) ≠ (1 : WithOne α) :=
  Option.some_ne_none a

@[simp, to_additive]
theorem one_ne_coe {a : α} : (1 : WithOne α) ≠ a :=
  coe_ne_one.symm

@[to_additive]
theorem ne_one_iff_exists {x : WithOne α} : x ≠ 1 ↔ ∃ a : α, ↑a = x :=
  Option.ne_none_iff_exists

@[to_additive]
instance : CanLift (WithOne α) α where
  coe := coe
  cond := fun a => a ≠ 1
  prf := fun a => ne_one_iff_exists.1

@[simp, norm_cast, to_additive]
theorem coe_inj {a b : α} : (a : WithOne α) = b ↔ a = b :=
  Option.some_inj

@[elab_as_eliminator, to_additive]
protected theorem cases_on {P : WithOne α → Prop} : ∀ x : WithOne α, P 1 → (∀ a : α, P a) → P x :=
  Option.casesOn

-- the `show` statements in the proofs are important, because otherwise the generated lemmas
-- `with_one.mul_one_class._proof_{1,2}` have an ill-typed statement after `with_one` is made
-- irreducible.
@[to_additive]
instance [Mul α] : MulOneClassₓ (WithOne α) where
  mul := (· * ·)
  one := 1
  one_mul := show ∀ x : WithOne α, 1 * x = x from (Option.lift_or_get_is_left_id _).1
  mul_one := show ∀ x : WithOne α, x * 1 = x from (Option.lift_or_get_is_right_id _).1

@[to_additive]
instance [Semigroupₓ α] : Monoidₓ (WithOne α) :=
  { WithOne.mulOneClass with mul_assoc := (Option.lift_or_get_assoc _).1 }

example [Semigroupₓ α] : @Monoidₓ.toMulOneClass _ (@WithOne.monoid α _) = @WithOne.mulOneClass α _ :=
  rfl

@[to_additive]
instance [CommSemigroupₓ α] : CommMonoidₓ (WithOne α) :=
  { WithOne.monoid with mul_comm := (Option.lift_or_get_comm _).1 }

section

/-- `coe` as a bundled morphism -/
-- workaround: we make `with_one`/`with_zero` irreducible for this definition, otherwise `simps`
-- will unfold it in the statement of the lemma it generates.
@[to_additive "`coe` as a bundled morphism", simps apply]
def coeMulHom [Mul α] : MulHom α (WithOne α) where
  toFun := coe
  map_mul' := fun x y => rfl

end

section lift

variable [Mul α] {β : Type v} [MulOneClassₓ β]

/-- Lift a semigroup homomorphism `f` to a bundled monoid homorphism. -/
@[to_additive "Lift an add_semigroup homomorphism `f` to a bundled add_monoid homorphism."]
def lift : MulHom α β ≃ (WithOne α →* β) where
  toFun := fun f =>
    { toFun := fun x => Option.casesOn x 1 f, map_one' := rfl,
      map_mul' := fun x y =>
        (WithOne.cases_on x
            (by
              rw [one_mulₓ]
              exact (one_mulₓ _).symm))
          fun x =>
          (WithOne.cases_on y
              (by
                rw [mul_oneₓ]
                exact (mul_oneₓ _).symm))
            fun y => f.map_mul x y }
  invFun := fun F => F.toMulHom.comp coeMulHom
  left_inv := fun f => MulHom.ext fun x => rfl
  right_inv := fun F => MonoidHom.ext fun x => (WithOne.cases_on x F.map_one.symm) fun x => rfl

variable (f : MulHom α β)

@[simp, to_additive]
theorem lift_coe (x : α) : lift f x = f x :=
  rfl

@[simp, to_additive]
theorem lift_one : lift f 1 = 1 :=
  rfl

@[to_additive]
theorem lift_unique (f : WithOne α →* β) : f = lift (f.toMulHom.comp coeMulHom) :=
  (lift.apply_symm_apply f).symm

end lift

section Map

variable {β : Type v} [Mul α] [Mul β]

/-- Given a multiplicative map from `α → β` returns a monoid homomorphism
  from `with_one α` to `with_one β` -/
@[to_additive
      "Given an additive map from `α → β` returns an add_monoid homomorphism\n  from `with_zero α` to `with_zero β`"]
def map (f : MulHom α β) : WithOne α →* WithOne β :=
  lift (coeMulHom.comp f)

@[simp, to_additive]
theorem map_id : map (MulHom.id α) = MonoidHom.id (WithOne α) := by
  ext
  cases x <;> rfl

@[simp, to_additive]
theorem map_comp {γ : Type w} [Mul γ] (f : MulHom α β) (g : MulHom β γ) : map (g.comp f) = (map g).comp (map f) := by
  ext
  cases x <;> rfl

end Map

@[simp, norm_cast, to_additive]
theorem coe_mul [Mul α] (a b : α) : ((a * b : α) : WithOne α) = a * b :=
  rfl

@[simp, norm_cast, to_additive]
theorem coe_inv [Inv α] (a : α) : ((a⁻¹ : α) : WithOne α) = a⁻¹ :=
  rfl

end WithOne

namespace WithZero

instance [one : One α] : One (WithZero α) :=
  { one with }

@[simp, norm_cast]
theorem coe_one [One α] : ((1 : α) : WithZero α) = 1 :=
  rfl

instance [Mul α] : MulZeroClassₓ (WithZero α) :=
  { WithZero.hasZero with mul := fun o₁ o₂ => o₁.bind fun a => Option.map (fun b => a * b) o₂, zero_mul := fun a => rfl,
    mul_zero := fun a => by
      cases a <;> rfl }

@[simp, norm_cast]
theorem coe_mul {α : Type u} [Mul α] {a b : α} : ((a * b : α) : WithZero α) = a * b :=
  rfl

@[simp]
theorem zero_mul {α : Type u} [Mul α] (a : WithZero α) : 0 * a = 0 :=
  rfl

@[simp]
theorem mul_zero {α : Type u} [Mul α] (a : WithZero α) : a * 0 = 0 := by
  cases a <;> rfl

instance [Semigroupₓ α] : SemigroupWithZeroₓ (WithZero α) :=
  { WithZero.mulZeroClass with
    mul_assoc := fun a b c =>
      match a, b, c with
      | none, _, _ => rfl
      | some a, none, _ => rfl
      | some a, some b, none => rfl
      | some a, some b, some c => congr_argₓ some (mul_assoc _ _ _) }

instance [CommSemigroupₓ α] : CommSemigroupₓ (WithZero α) :=
  { WithZero.semigroupWithZero with
    mul_comm := fun a b =>
      match a, b with
      | none, _ => (mul_zero _).symm
      | some a, none => rfl
      | some a, some b => congr_argₓ some (mul_comm _ _) }

instance [MulOneClassₓ α] : MulZeroOneClassₓ (WithZero α) :=
  { WithZero.mulZeroClass, WithZero.hasOne with
    one_mul := fun a =>
      match a with
      | none => rfl
      | some a => congr_argₓ some <| one_mulₓ _,
    mul_one := fun a =>
      match a with
      | none => rfl
      | some a => congr_argₓ some <| mul_oneₓ _ }

instance [One α] [Pow α ℕ] : Pow (WithZero α) ℕ :=
  ⟨fun x n =>
    match x, n with
    | none, 0 => 1
    | none, n + 1 => 0
    | some x, n => ↑(x ^ n)⟩

@[simp, norm_cast]
theorem coe_pow [One α] [Pow α ℕ] {a : α} (n : ℕ) : ↑(a ^ n : α) = (↑a ^ n : WithZero α) :=
  rfl

instance [Monoidₓ α] : MonoidWithZeroₓ (WithZero α) :=
  { WithZero.mulZeroOneClass, WithZero.semigroupWithZero with npow := fun n x => x ^ n,
    npow_zero' := fun x =>
      match x with
      | none => rfl
      | some x => congr_argₓ some <| pow_zeroₓ _,
    npow_succ' := fun n x =>
      match x with
      | none => rfl
      | some x => congr_argₓ some <| pow_succₓ _ _ }

instance [CommMonoidₓ α] : CommMonoidWithZero (WithZero α) :=
  { WithZero.monoidWithZero, WithZero.commSemigroup with }

/-- Given an inverse operation on `α` there is an inverse operation
  on `with_zero α` sending `0` to `0`-/
instance [Inv α] : Inv (WithZero α) :=
  ⟨fun a => Option.map Inv.inv a⟩

@[simp, norm_cast]
theorem coe_inv [Inv α] (a : α) : ((a⁻¹ : α) : WithZero α) = a⁻¹ :=
  rfl

@[simp]
theorem inv_zero [Inv α] : (0 : WithZero α)⁻¹ = 0 :=
  rfl

instance [Div α] : Div (WithZero α) :=
  ⟨fun o₁ o₂ => o₁.bind fun a => Option.map (fun b => a / b) o₂⟩

@[norm_cast]
theorem coe_div [Div α] (a b : α) : ↑(a / b : α) = (a / b : WithZero α) :=
  rfl

instance [One α] [Pow α ℤ] : Pow (WithZero α) ℤ :=
  ⟨fun x n =>
    match x, n with
    | none, Int.ofNat 0 => 1
    | none, Int.ofNat (Nat.succ n) => 0
    | none, Int.negSucc n => 0
    | some x, n => ↑(x ^ n)⟩

@[simp, norm_cast]
theorem coe_zpow [DivInvMonoidₓ α] {a : α} (n : ℤ) : ↑(a ^ n : α) = (↑a ^ n : WithZero α) :=
  rfl

instance [DivInvMonoidₓ α] : DivInvMonoidₓ (WithZero α) :=
  { WithZero.hasDiv, WithZero.hasInv, WithZero.monoidWithZero with
    div_eq_mul_inv := fun a b =>
      match a, b with
      | none, _ => rfl
      | some a, none => rfl
      | some a, some b => congr_argₓ some (div_eq_mul_inv _ _),
    zpow := fun n x => x ^ n,
    zpow_zero' := fun x =>
      match x with
      | none => rfl
      | some x => congr_argₓ some <| zpow_zero _,
    zpow_succ' := fun n x =>
      match x with
      | none => rfl
      | some x => congr_argₓ some <| DivInvMonoidₓ.zpow_succ' _ _,
    zpow_neg' := fun n x =>
      match x with
      | none => rfl
      | some x => congr_argₓ some <| DivInvMonoidₓ.zpow_neg' _ _ }

section Groupₓ

variable [Groupₓ α]

@[simp]
theorem inv_one : (1 : WithZero α)⁻¹ = 1 :=
  show ((1⁻¹ : α) : WithZero α) = 1 by
    simp

/-- if `G` is a group then `with_zero G` is a group with zero. -/
instance : GroupWithZeroₓ (WithZero α) :=
  { WithZero.monoidWithZero, WithZero.divInvMonoid, WithZero.nontrivial with inv_zero := inv_zero,
    mul_inv_cancel := fun a ha => by
      lift a to α using ha
      norm_cast
      apply mul_right_invₓ }

end Groupₓ

instance [CommGroupₓ α] : CommGroupWithZero (WithZero α) :=
  { WithZero.groupWithZero, WithZero.commMonoidWithZero with }

instance [Semiringₓ α] : Semiringₓ (WithZero α) :=
  { WithZero.addCommMonoid, WithZero.mulZeroClass, WithZero.monoidWithZero with
    left_distrib := fun a b c => by
      cases' a with a
      · rfl
        
      cases' b with b <;>
        cases' c with c <;>
          try
            rfl
      exact congr_argₓ some (left_distrib _ _ _),
    right_distrib := fun a b c => by
      cases' c with c
      · change (a + b) * 0 = a * 0 + b * 0
        simp
        
      cases' a with a <;>
        cases' b with b <;>
          try
            rfl
      exact congr_argₓ some (right_distrib _ _ _) }

end WithZero

