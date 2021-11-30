import Mathbin.Algebra.GroupPower.Order 
import Mathbin.Algebra.SmulWithZero

/-!

# Tropical algebraic structures

This file defines algebraic structures of the (min-)tropical numbers, up to the tropical semiring.
Some basic lemmas about conversion from the base type `R` to `tropical R` are provided, as
well as the expected implementations of tropical addition and tropical multiplication.

## Main declarations

* `tropical R`: The type synonym of the tropical interpretation of `R`.
    If `[linear_order R]`, then addition on `R` is via `min`.
* `semiring (tropical R)`: A `linear_ordered_add_comm_monoid_with_top R`
    induces a `semiring (tropical R)`. If one solely has `[linear_ordered_add_comm_monoid R]`,
    then the "tropicalization of `R`" would be `tropical (with_top R)`.

## Implementation notes

The tropical structure relies on `has_top` and `min`. For the max-tropical numbers, use
`order_dual R`.

Inspiration was drawn from the implementation of `additive`/`multiplicative`/`opposite`,
where a type synonym is created with some barebones API, and quickly made irreducible.

Algebraic structures are provided with as few typeclass assumptions as possible, even though
most references rely on `semiring (tropical R)` for building up the whole theory.

## References followed

* https://arxiv.org/pdf/math/0408099.pdf
* https://www.mathenjeans.fr/sites/default/files/sujets/tropical_geometry_-_casagrande.pdf

-/


universe u v

variable (R : Type u)

/-- The tropicalization of a type `R`. -/
def Tropical : Type u :=
  R

variable {R}

namespace Tropical

/-- Reinterpret `x : R` as an element of `tropical R`.
See `tropical.trop_equiv` for the equivalence.
-/
@[pp_nodot]
def trop : R → Tropical R :=
  id

/-- Reinterpret `x : tropical R` as an element of `R`.
See `tropical.trop_equiv` for the equivalence. -/
@[pp_nodot]
def untrop : Tropical R → R :=
  id

theorem trop_injective : Function.Injective (trop : R → Tropical R) :=
  fun _ _ => id

theorem untrop_injective : Function.Injective (untrop : Tropical R → R) :=
  fun _ _ => id

@[simp]
theorem trop_inj_iff (x y : R) : trop x = trop y ↔ x = y :=
  Iff.rfl

@[simp]
theorem untrop_inj_iff (x y : Tropical R) : untrop x = untrop y ↔ x = y :=
  Iff.rfl

@[simp]
theorem trop_untrop (x : Tropical R) : trop (untrop x) = x :=
  rfl

@[simp]
theorem untrop_trop (x : R) : untrop (trop x) = x :=
  rfl

theorem left_inverse_trop : Function.LeftInverse (trop : R → Tropical R) untrop :=
  trop_untrop

theorem right_inverse_trop : Function.RightInverse (trop : R → Tropical R) untrop :=
  trop_untrop

/-- Reinterpret `x : R` as an element of `tropical R`.
See `tropical.trop_order_iso` for the order-preserving equivalence. -/
def trop_equiv : R ≃ Tropical R :=
  { toFun := trop, invFun := untrop, left_inv := untrop_trop, right_inv := trop_untrop }

@[simp]
theorem trop_equiv_coe_fn : (trop_equiv : R → Tropical R) = trop :=
  rfl

@[simp]
theorem trop_equiv_symm_coe_fn : (trop_equiv.symm : Tropical R → R) = untrop :=
  rfl

theorem trop_eq_iff_eq_untrop {x : R} {y} : trop x = y ↔ x = untrop y :=
  trop_equiv.apply_eq_iff_eq_symm_apply

theorem untrop_eq_iff_eq_trop {x} {y : R} : untrop x = y ↔ x = trop y :=
  trop_equiv.symm.apply_eq_iff_eq_symm_apply

theorem injective_trop : Function.Injective (trop : R → Tropical R) :=
  trop_equiv.Injective

theorem injective_untrop : Function.Injective (untrop : Tropical R → R) :=
  trop_equiv.symm.Injective

theorem surjective_trop : Function.Surjective (trop : R → Tropical R) :=
  trop_equiv.Surjective

theorem surjective_untrop : Function.Surjective (untrop : Tropical R → R) :=
  trop_equiv.symm.Surjective

instance [Inhabited R] : Inhabited (Tropical R) :=
  ⟨trop (default _)⟩

/-- Recursing on a `x' : tropical R` is the same as recursing on an `x : R` reinterpreted
as a term of `tropical R` via `trop x`. -/
@[simp]
def trop_rec {F : ∀ X : Tropical R, Sort v} (h : ∀ X, F (trop X)) : ∀ X, F X :=
  fun X => h (untrop X)

section Order

instance [Preorderₓ R] : Preorderₓ (Tropical R) :=
  { le := fun x y => untrop x ≤ untrop y, le_refl := fun _ => le_reflₓ _, le_trans := fun _ _ _ h h' => le_transₓ h h' }

@[simp]
theorem untrop_le_iff [Preorderₓ R] {x y : Tropical R} : untrop x ≤ untrop y ↔ x ≤ y :=
  Iff.rfl

/-- Reinterpret `x : R` as an element of `tropical R`, preserving the order. -/
def trop_order_iso [Preorderₓ R] : R ≃o Tropical R :=
  { trop_equiv with map_rel_iff' := fun _ _ => untrop_le_iff }

@[simp]
theorem trop_order_iso_coe_fn [Preorderₓ R] : (trop_order_iso : R → Tropical R) = trop :=
  rfl

@[simp]
theorem trop_order_iso_symm_coe_fn [Preorderₓ R] : (trop_order_iso.symm : Tropical R → R) = untrop :=
  rfl

instance [PartialOrderₓ R] : PartialOrderₓ (Tropical R) :=
  { Tropical.preorder with le_antisymm := fun _ _ h h' => untrop_injective (le_antisymmₓ h h') }

instance [HasTop R] : HasZero (Tropical R) :=
  ⟨trop ⊤⟩

instance [HasTop R] : HasTop (Tropical R) :=
  ⟨0⟩

@[simp]
theorem untrop_zero [HasTop R] : untrop (0 : Tropical R) = ⊤ :=
  rfl

@[simp]
theorem trop_top [HasTop R] : trop (⊤ : R) = 0 :=
  rfl

@[simp]
theorem trop_coe_ne_zero (x : R) : trop (x : WithTop R) ≠ 0 :=
  fun.

@[simp]
theorem zero_ne_trop_coe (x : R) : (0 : Tropical (WithTop R)) ≠ trop x :=
  fun.

@[simp]
theorem le_zero [Preorderₓ R] [OrderTop R] (x : Tropical R) : x ≤ 0 :=
  le_top

instance [PartialOrderₓ R] : OrderTop (Tropical (WithTop R)) :=
  { Tropical.hasTop with le_top := fun a a' h => Option.noConfusion h }

variable [LinearOrderₓ R]

/-- Tropical addition is the minimum of two underlying elements of `R`. -/
protected def add (x y : Tropical R) : Tropical R :=
  trop (min (untrop x) (untrop y))

instance : AddCommSemigroupₓ (Tropical R) :=
  { add := Tropical.add, add_assoc := fun _ _ _ => untrop_injective (min_assocₓ _ _ _),
    add_comm := fun _ _ => untrop_injective (min_commₓ _ _) }

instance : LinearOrderₓ (Tropical R) :=
  { Tropical.partialOrder with le_total := fun a b => le_totalₓ (untrop a) (untrop b),
    decidableLe := fun x y => if h : untrop x ≤ untrop y then is_true h else is_false h }

@[simp]
theorem untrop_add (x y : Tropical R) : untrop (x+y) = min (untrop x) (untrop y) :=
  rfl

theorem trop_add_def (x y : Tropical R) : (x+y) = trop (min (untrop x) (untrop y)) :=
  rfl

@[simp]
theorem add_eq_left ⦃x y : Tropical R⦄ (h : x ≤ y) : (x+y) = x :=
  untrop_injective
    (by 
      simpa using h)

@[simp]
theorem add_eq_right ⦃x y : Tropical R⦄ (h : y ≤ x) : (x+y) = y :=
  untrop_injective
    (by 
      simpa using h)

@[simp]
theorem add_self (x : Tropical R) : (x+x) = x :=
  untrop_injective (min_eq_rightₓ le_rfl)

@[simp]
theorem bit0 (x : Tropical R) : bit0 x = x :=
  add_self x

theorem add_eq_iff {x y z : Tropical R} : (x+y) = z ↔ x = z ∧ x ≤ y ∨ y = z ∧ y ≤ x :=
  by 
    simp [trop_add_def, trop_eq_iff_eq_untrop, min_eq_iff]

@[simp]
theorem add_eq_zero_iff {a b : Tropical (WithTop R)} : (a+b) = 0 ↔ a = 0 ∧ b = 0 :=
  by 
    rw [add_eq_iff]
    split 
    ·
      rintro (⟨rfl, h⟩ | ⟨rfl, h⟩)
      ·
        exact ⟨rfl, le_antisymmₓ (le_zero _) h⟩
      ·
        exact ⟨le_antisymmₓ (le_zero _) h, rfl⟩
    ·
      rintro ⟨rfl, rfl⟩
      simp 

end Order

section Monoidₓ

/-- Tropical multiplication is the addition in the underlying `R`. -/
protected def mul [Add R] (x y : Tropical R) : Tropical R :=
  trop (untrop x+untrop y)

instance [Add R] : Mul (Tropical R) :=
  ⟨Tropical.mul⟩

@[simp]
theorem untrop_mul [Add R] (x y : Tropical R) : untrop (x*y) = untrop x+untrop y :=
  rfl

theorem trop_mul_def [Add R] (x y : Tropical R) : (x*y) = trop (untrop x+untrop y) :=
  rfl

instance [HasZero R] : HasOne (Tropical R) :=
  ⟨trop 0⟩

instance [HasZero R] : Nontrivial (Tropical (WithTop R)) :=
  ⟨⟨0, 1, trop_injective.Ne WithTop.top_ne_coe⟩⟩

instance [Neg R] : HasInv (Tropical R) :=
  ⟨fun x => trop (-untrop x)⟩

@[simp]
theorem untrop_inv [Neg R] (x : Tropical R) : untrop (x⁻¹) = -untrop x :=
  rfl

instance [Sub R] : Div (Tropical R) :=
  ⟨fun x y => trop (untrop x - untrop y)⟩

@[simp]
theorem untrop_div [Sub R] (x y : Tropical R) : untrop (x / y) = untrop x - untrop y :=
  rfl

instance [AddSemigroupₓ R] : Semigroupₓ (Tropical R) :=
  { mul := Tropical.mul, mul_assoc := fun _ _ _ => untrop_injective (add_assocₓ _ _ _) }

instance [AddCommSemigroupₓ R] : CommSemigroupₓ (Tropical R) :=
  { Tropical.semigroup with mul_comm := fun _ _ => untrop_injective (add_commₓ _ _) }

instance [AddMonoidₓ R] : Monoidₓ (Tropical R) :=
  { Tropical.semigroup with one := trop 0, one_mul := fun _ => untrop_injective (zero_addₓ _),
    mul_one := fun _ => untrop_injective (add_zeroₓ _) }

@[simp]
theorem untrop_one [AddMonoidₓ R] : untrop (1 : Tropical R) = 0 :=
  rfl

@[simp]
theorem untrop_pow [AddMonoidₓ R] (x : Tropical R) (n : ℕ) : untrop (x ^ n) = n • untrop x :=
  by 
    induction' n with n IH
    ·
      simp 
    ·
      rw [pow_succₓ, untrop_mul, IH, succ_nsmul]

@[simp]
theorem trop_nsmul [AddMonoidₓ R] (x : R) (n : ℕ) : trop (n • x) = trop x ^ n :=
  by 
    simp [trop_eq_iff_eq_untrop]

instance [AddCommMonoidₓ R] : CommMonoidₓ (Tropical R) :=
  { Tropical.monoid, Tropical.commSemigroup with  }

instance [AddGroupₓ R] : Groupₓ (Tropical R) :=
  { Tropical.monoid with inv := fun x => trop (-untrop x), mul_left_inv := fun _ => untrop_injective (add_left_negₓ _) }

instance [AddCommGroupₓ R] : CommGroupₓ (Tropical R) :=
  { Tropical.group with mul_comm := fun _ _ => untrop_injective (add_commₓ _ _) }

end Monoidₓ

section Distrib

instance covariant_mul [Preorderₓ R] [Add R] [CovariantClass R R (·+·) (· ≤ ·)] :
  CovariantClass (Tropical R) (Tropical R) (·*·) (· ≤ ·) :=
  ⟨fun x y z h => add_le_add_left h _⟩

instance covariant_swap_mul [Preorderₓ R] [Add R] [CovariantClass R R (Function.swap (·+·)) (· ≤ ·)] :
  CovariantClass (Tropical R) (Tropical R) (Function.swap (·*·)) (· ≤ ·) :=
  ⟨fun x y z h => add_le_add_right h _⟩

instance [LinearOrderₓ R] [Add R] [CovariantClass R R (·+·) (· ≤ ·)]
  [CovariantClass R R (Function.swap (·+·)) (· ≤ ·)] : Distrib (Tropical R) :=
  { mul := Tropical.mul, add := Tropical.add,
    left_distrib := fun _ _ _ => untrop_injective (min_add_add_left _ _ _).symm,
    right_distrib := fun _ _ _ => untrop_injective (min_add_add_right _ _ _).symm }

@[simp]
theorem add_pow [LinearOrderₓ R] [AddMonoidₓ R] [CovariantClass R R (·+·) (· ≤ ·)]
  [CovariantClass R R (Function.swap (·+·)) (· ≤ ·)] (x y : Tropical R) (n : ℕ) : (x+y) ^ n = (x ^ n)+y ^ n :=
  by 
    cases' le_totalₓ x y with h h
    ·
      rw [add_eq_left h, add_eq_left (pow_le_pow_of_le_left' h _)]
    ·
      rw [add_eq_right h, add_eq_right (pow_le_pow_of_le_left' h _)]

end Distrib

section Semiringₓ

variable [LinearOrderedAddCommMonoidWithTop R]

instance : CommSemiringₓ (Tropical R) :=
  { Tropical.hasZero, Tropical.distrib, Tropical.addCommSemigroup, Tropical.commMonoid with
    zero_add := fun _ => untrop_injective (min_top_left _), add_zero := fun _ => untrop_injective (min_top_right _),
    zero_mul := fun _ => untrop_injective (top_add _), mul_zero := fun _ => untrop_injective (add_top _) }

@[simp]
theorem succ_nsmul (x : Tropical R) (n : ℕ) : (n+1) • x = x :=
  by 
    induction' n with n IH
    ·
      simp 
    ·
      rw [add_nsmul, IH, one_nsmul, add_self]

@[simp]
theorem mul_eq_zero_iff {R : Type _} [LinearOrderedAddCommMonoid R] {a b : Tropical (WithTop R)} :
  (a*b) = 0 ↔ a = 0 ∨ b = 0 :=
  by 
    simp [←untrop_inj_iff, WithTop.add_eq_top]

instance {R : Type _} [LinearOrderedAddCommMonoid R] : NoZeroDivisors (Tropical (WithTop R)) :=
  ⟨fun _ _ => mul_eq_zero_iff.mp⟩

end Semiringₓ

end Tropical

