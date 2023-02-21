/-
Copyright (c) 2022 Jujian Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jujian Zhang

! This file was ported from Lean 3 source module group_theory.divisible
! leanprover-community/mathlib commit bd9851ca476957ea4549eb19b40e7b5ade9428cc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.Subgroup.Pointwise
import Mathbin.GroupTheory.QuotientGroup
import Mathbin.Algebra.Group.Pi

/-!
# Divisible Group and rootable group

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file, we define a divisible add monoid and a rootable monoid with some basic properties.

## Main definition

* `divisible_by A α`: An additive monoid `A` is said to be divisible by `α` iff for all `n ≠ 0 ∈ α`
  and `y ∈ A`, there is an `x ∈ A` such that `n • x = y`. In this file, we adopt a constructive
  approach, i.e. we ask for an explicit `div : A → α → A` function such that `div a 0 = 0` and
  `n • div a n = a` for all `n ≠ 0 ∈ α`.
* `rootable_by A α`: A monoid `A` is said to be rootable by `α` iff for all `n ≠ 0 ∈ α` and `y ∈ A`,
  there is an `x ∈ A` such that `x^n = y`. In this file, we adopt a constructive approach, i.e. we
  ask for an explicit `root : A → α → A` function such that `root a 0 = 1` and `(root a n)ⁿ = a` for
  all `n ≠ 0 ∈ α`.

## Main results

For additive monoids and groups:

* `divisible_by_of_smul_right_surj` : the constructive definition of divisiblity is implied by
  the condition that `n • x = a` has solutions for all `n ≠ 0` and `a ∈ A`.
* `smul_right_surj_of_divisible_by` : the constructive definition of divisiblity implies
  the condition that `n • x = a` has solutions for all `n ≠ 0` and `a ∈ A`.
* `prod.divisible_by` : `A × B` is divisible for any two divisible additive monoids.
* `pi.divisible_by` : any product of divisble additive monoids is divisible.
* `add_group.divisible_by_int_of_divisible_by_nat` : for additive groups, int divisiblity is implied
  by nat divisiblity.
* `add_group.divisible_by_nat_of_divisible_by_int` : for additive groups, nat divisiblity is implied
  by int divisiblity.
* `add_comm_group.divisible_by_int_of_smul_top_eq_top`: the constructive definition of divisiblity
  is implied by the condition that `n • A = A` for all `n ≠ 0`.
* `add_comm_group.smul_top_eq_top_of_divisible_by_int`: the constructive definition of divisiblity
  implies the condition that `n • A = A` for all `n ≠ 0`.
* `divisible_by_int_of_char_zero` : any field of characteristic zero is divisible.
* `quotient_add_group.divisible_by` : quotient group of divisible group is divisible.
* `function.surjective.divisible_by` : if `A` is divisible and `A →+ B` is surjective, then `B`
  is divisible.

and their multiplicative counterparts:

* `rootable_by_of_pow_left_surj` : the constructive definition of rootablity is implied by the
  condition that `xⁿ = y` has solutions for all `n ≠ 0` and `a ∈ A`.
* `pow_left_surj_of_rootable_by` : the constructive definition of rootablity implies the
  condition that `xⁿ = y` has solutions for all `n ≠ 0` and `a ∈ A`.
* `prod.rootable_by` : any product of two rootable monoids is rootable.
* `pi.rootable_by` : any product of rootable monoids is rootable.
* `group.rootable_by_int_of_rootable_by_nat` : in groups, int rootablity is implied by nat
  rootablity.
* `group.rootable_by_nat_of_rootable_by_int` : in groups, nat rootablity is implied by int
  rootablity.
* `quotient_group.rootable_by` : quotient group of rootable group is rootable.
* `function.surjective.rootable_by` : if `A` is rootable and `A →* B` is surjective, then `B` is
  rootable.

TODO: Show that divisibility implies injectivity in the category of `AddCommGroup`.
-/


open Pointwise

section AddMonoid

variable (A α : Type _) [AddMonoid A] [SMul α A] [Zero α]

#print DivisibleBy /-
/--
An `add_monoid A` is `α`-divisible iff `n • x = a` has a solution for all `n ≠ 0 ∈ α` and `a ∈ A`.
Here we adopt a constructive approach where we ask an explicit `div : A → α → A` function such that
* `div a 0 = 0` for all `a ∈ A`
* `n • div a n = a` for all `n ≠ 0 ∈ α` and `a ∈ A`.
-/
class DivisibleBy where
  div : A → α → A
  div_zero : ∀ a, div a 0 = 0
  div_cancel : ∀ {n : α} (a : A), n ≠ 0 → n • div a n = a
#align divisible_by DivisibleBy
-/

end AddMonoid

section Monoid

variable (A α : Type _) [Monoid A] [Pow A α] [Zero α]

#print RootableBy /-
/-- A `monoid A` is `α`-rootable iff `xⁿ = a` has a solution for all `n ≠ 0 ∈ α` and `a ∈ A`.
Here we adopt a constructive approach where we ask an explicit `root : A → α → A` function such that
* `root a 0 = 1` for all `a ∈ A`
* `(root a n)ⁿ = a` for all `n ≠ 0 ∈ α` and `a ∈ A`.
-/
@[to_additive]
class RootableBy where
  root : A → α → A
  root_zero : ∀ a, root a 0 = 1
  root_cancel : ∀ {n : α} (a : A), n ≠ 0 → root a n ^ n = a
#align rootable_by RootableBy
#align divisible_by DivisibleBy
-/

/- warning: pow_left_surj_of_rootable_by -> pow_left_surj_of_rootableBy is a dubious translation:
lean 3 declaration is
  forall (A : Type.{u1}) (α : Type.{u2}) [_inst_1 : Monoid.{u1} A] [_inst_2 : Pow.{u1, u2} A α] [_inst_3 : Zero.{u2} α] [_inst_4 : RootableBy.{u1, u2} A α _inst_1 _inst_2 _inst_3] {n : α}, (Ne.{succ u2} α n (OfNat.ofNat.{u2} α 0 (OfNat.mk.{u2} α 0 (Zero.zero.{u2} α _inst_3)))) -> (Function.Surjective.{succ u1, succ u1} A A (fun (a : A) => HPow.hPow.{u1, u2, u1} A α A (instHPow.{u1, u2} A α _inst_2) a n))
but is expected to have type
  forall (A : Type.{u2}) (α : Type.{u1}) [_inst_1 : Monoid.{u2} A] [_inst_2 : Pow.{u2, u1} A α] [_inst_3 : Zero.{u1} α] [_inst_4 : RootableBy.{u2, u1} A α _inst_1 _inst_2 _inst_3] {n : α}, (Ne.{succ u1} α n (OfNat.ofNat.{u1} α 0 (Zero.toOfNat0.{u1} α _inst_3))) -> (Function.Surjective.{succ u2, succ u2} A A (fun (a : A) => HPow.hPow.{u2, u1, u2} A α A (instHPow.{u2, u1} A α _inst_2) a n))
Case conversion may be inaccurate. Consider using '#align pow_left_surj_of_rootable_by pow_left_surj_of_rootableByₓ'. -/
@[to_additive smul_right_surj_of_divisibleBy]
theorem pow_left_surj_of_rootableBy [RootableBy A α] {n : α} (hn : n ≠ 0) :
    Function.Surjective (fun a => pow a n : A → A) := fun x =>
  ⟨RootableBy.root x n, RootableBy.root_cancel _ hn⟩
#align pow_left_surj_of_rootable_by pow_left_surj_of_rootableBy
#align smul_right_surj_of_divisible_by smul_right_surj_of_divisibleBy

#print rootableByOfPowLeftSurj /-
/--
A `monoid A` is `α`-rootable iff the `pow _ n` function is surjective, i.e. the constructive version
implies the textbook approach.
-/
@[to_additive divisibleByOfSMulRightSurj
      "An `add_monoid A` is `α`-divisible iff `n • _` is a surjective function, i.e. the constructive\nversion implies the textbook approach."]
noncomputable def rootableByOfPowLeftSurj
    (H : ∀ {n : α}, n ≠ 0 → Function.Surjective (fun a => a ^ n : A → A)) : RootableBy A α
    where
  root a n := @dite _ (n = 0) (Classical.dec _) (fun _ => (1 : A)) fun hn => (H hn a).some
  root_zero _ := by classical exact dif_pos rfl
  root_cancel n a hn := by
    classical
      rw [dif_neg hn]
      exact (H hn a).choose_spec
#align rootable_by_of_pow_left_surj rootableByOfPowLeftSurj
#align divisible_by_of_smul_right_surj divisibleByOfSMulRightSurj
-/

section Pi

variable {ι β : Type _} (B : ι → Type _) [∀ i : ι, Pow (B i) β]

variable [Zero β] [∀ i : ι, Monoid (B i)] [∀ i, RootableBy (B i) β]

#print Pi.rootableBy /-
@[to_additive]
instance Pi.rootableBy : RootableBy (∀ i, B i) β
    where
  root x n i := RootableBy.root (x i) n
  root_zero x := funext fun i => RootableBy.root_zero _
  root_cancel n x hn := funext fun i => RootableBy.root_cancel _ hn
#align pi.rootable_by Pi.rootableBy
#align pi.divisible_by Pi.divisibleBy
-/

end Pi

section Prod

variable {β B B' : Type _} [Pow B β] [Pow B' β]

variable [Zero β] [Monoid B] [Monoid B'] [RootableBy B β] [RootableBy B' β]

/- warning: prod.rootable_by -> Prod.rootableBy is a dubious translation:
lean 3 declaration is
  forall {β : Type.{u1}} {B : Type.{u2}} {B' : Type.{u3}} [_inst_4 : Pow.{u2, u1} B β] [_inst_5 : Pow.{u3, u1} B' β] [_inst_6 : Zero.{u1} β] [_inst_7 : Monoid.{u2} B] [_inst_8 : Monoid.{u3} B'] [_inst_9 : RootableBy.{u2, u1} B β _inst_7 _inst_4 _inst_6] [_inst_10 : RootableBy.{u3, u1} B' β _inst_8 _inst_5 _inst_6], RootableBy.{max u2 u3, u1} (Prod.{u2, u3} B B') β (Prod.monoid.{u2, u3} B B' _inst_7 _inst_8) (Prod.pow.{u1, u2, u3} β B B' _inst_4 _inst_5) _inst_6
but is expected to have type
  forall {β : Type.{u1}} {B : Type.{u2}} {B' : Type.{u3}} [_inst_4 : Pow.{u2, u1} B β] [_inst_5 : Pow.{u3, u1} B' β] [_inst_6 : Zero.{u1} β] [_inst_7 : Monoid.{u2} B] [_inst_8 : Monoid.{u3} B'] [_inst_9 : RootableBy.{u2, u1} B β _inst_7 _inst_4 _inst_6] [_inst_10 : RootableBy.{u3, u1} B' β _inst_8 _inst_5 _inst_6], RootableBy.{max u3 u2, u1} (Prod.{u2, u3} B B') β (Prod.instMonoidProd.{u2, u3} B B' _inst_7 _inst_8) (Prod.pow.{u1, u2, u3} β B B' _inst_4 _inst_5) _inst_6
Case conversion may be inaccurate. Consider using '#align prod.rootable_by Prod.rootableByₓ'. -/
@[to_additive]
instance Prod.rootableBy : RootableBy (B × B') β
    where
  root p n := (RootableBy.root p.1 n, RootableBy.root p.2 n)
  root_zero p := Prod.ext (RootableBy.root_zero _) (RootableBy.root_zero _)
  root_cancel n p hn := Prod.ext (RootableBy.root_cancel _ hn) (RootableBy.root_cancel _ hn)
#align prod.rootable_by Prod.rootableBy
#align prod.divisible_by Prod.divisibleBy

end Prod

end Monoid

namespace AddCommGroup

variable (A : Type _) [AddCommGroup A]

/- warning: add_comm_group.smul_top_eq_top_of_divisible_by_int -> AddCommGroup.smul_top_eq_top_of_divisibleBy_int is a dubious translation:
lean 3 declaration is
  forall (A : Type.{u1}) [_inst_1 : AddCommGroup.{u1} A] [_inst_2 : DivisibleBy.{u1, 0} A Int (SubNegMonoid.toAddMonoid.{u1} A (AddGroup.toSubNegMonoid.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1))) (SubNegMonoid.SMulInt.{u1} A (AddGroup.toSubNegMonoid.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1))) Int.hasZero] {n : Int}, (Ne.{1} Int n (OfNat.ofNat.{0} Int 0 (OfNat.mk.{0} Int 0 (Zero.zero.{0} Int Int.hasZero)))) -> (Eq.{succ u1} (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (SMul.smul.{0, u1} Int (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (MulAction.toHasSmul.{0, u1} Int (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (MonoidWithZero.toMonoid.{0} Int (Semiring.toMonoidWithZero.{0} Int Int.semiring)) (AddSubgroup.pointwiseMulAction.{0, u1} Int A (AddCommGroup.toAddGroup.{u1} A _inst_1) (MonoidWithZero.toMonoid.{0} Int (Semiring.toMonoidWithZero.{0} Int Int.semiring)) (Module.toDistribMulAction.{0, u1} Int A Int.semiring (AddCommGroup.toAddCommMonoid.{u1} A _inst_1) (AddCommGroup.intModule.{u1} A _inst_1)))) n (Top.top.{u1} (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (AddSubgroup.hasTop.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)))) (Top.top.{u1} (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (AddSubgroup.hasTop.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1))))
but is expected to have type
  forall (A : Type.{u1}) [_inst_1 : AddCommGroup.{u1} A] [_inst_2 : DivisibleBy.{u1, 0} A Int (SubNegMonoid.toAddMonoid.{u1} A (AddGroup.toSubNegMonoid.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1))) (SubNegMonoid.SMulInt.{u1} A (AddGroup.toSubNegMonoid.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1))) (CommMonoidWithZero.toZero.{0} Int (CancelCommMonoidWithZero.toCommMonoidWithZero.{0} Int (IsDomain.toCancelCommMonoidWithZero.{0} Int Int.instCommSemiringInt (LinearOrderedRing.isDomain.{0} Int (LinearOrderedCommRing.toLinearOrderedRing.{0} Int Int.linearOrderedCommRing)))))] {n : Int}, (Ne.{1} Int n (OfNat.ofNat.{0} Int 0 (instOfNatInt 0))) -> (Eq.{succ u1} (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (HSMul.hSMul.{0, u1, u1} Int (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (instHSMul.{0, u1} Int (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (MulAction.toSMul.{0, u1} Int (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) Int.instMonoidInt (AddSubgroup.pointwiseMulAction.{0, u1} Int A (AddCommGroup.toAddGroup.{u1} A _inst_1) Int.instMonoidInt (Module.toDistribMulAction.{0, u1} Int A (Ring.toSemiring.{0} Int (CommRing.toRing.{0} Int Int.instCommRingInt)) (AddCommGroup.toAddCommMonoid.{u1} A _inst_1) (AddCommGroup.intModule.{u1} A _inst_1))))) n (Top.top.{u1} (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (AddSubgroup.instTopAddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)))) (Top.top.{u1} (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (AddSubgroup.instTopAddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1))))
Case conversion may be inaccurate. Consider using '#align add_comm_group.smul_top_eq_top_of_divisible_by_int AddCommGroup.smul_top_eq_top_of_divisibleBy_intₓ'. -/
theorem smul_top_eq_top_of_divisibleBy_int [DivisibleBy A ℤ] {n : ℤ} (hn : n ≠ 0) :
    n • (⊤ : AddSubgroup A) = ⊤ :=
  AddSubgroup.map_top_of_surjective _ fun a => ⟨DivisibleBy.div a n, DivisibleBy.div_cancel _ hn⟩
#align add_comm_group.smul_top_eq_top_of_divisible_by_int AddCommGroup.smul_top_eq_top_of_divisibleBy_int

/- warning: add_comm_group.divisible_by_int_of_smul_top_eq_top -> AddCommGroup.divisibleByIntOfSmulTopEqTop is a dubious translation:
lean 3 declaration is
  forall (A : Type.{u1}) [_inst_1 : AddCommGroup.{u1} A], (forall {n : Int}, (Ne.{1} Int n (OfNat.ofNat.{0} Int 0 (OfNat.mk.{0} Int 0 (Zero.zero.{0} Int Int.hasZero)))) -> (Eq.{succ u1} (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (SMul.smul.{0, u1} Int (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (MulAction.toHasSmul.{0, u1} Int (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (MonoidWithZero.toMonoid.{0} Int (Semiring.toMonoidWithZero.{0} Int Int.semiring)) (AddSubgroup.pointwiseMulAction.{0, u1} Int A (AddCommGroup.toAddGroup.{u1} A _inst_1) (MonoidWithZero.toMonoid.{0} Int (Semiring.toMonoidWithZero.{0} Int Int.semiring)) (Module.toDistribMulAction.{0, u1} Int A Int.semiring (AddCommGroup.toAddCommMonoid.{u1} A _inst_1) (AddCommGroup.intModule.{u1} A _inst_1)))) n (Top.top.{u1} (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (AddSubgroup.hasTop.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)))) (Top.top.{u1} (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (AddSubgroup.hasTop.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1))))) -> (DivisibleBy.{u1, 0} A Int (SubNegMonoid.toAddMonoid.{u1} A (AddGroup.toSubNegMonoid.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1))) (SubNegMonoid.SMulInt.{u1} A (AddGroup.toSubNegMonoid.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1))) Int.hasZero)
but is expected to have type
  forall (A : Type.{u1}) [_inst_1 : AddCommGroup.{u1} A], (forall {n : Int}, (Ne.{1} Int n (OfNat.ofNat.{0} Int 0 (instOfNatInt 0))) -> (Eq.{succ u1} (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (HSMul.hSMul.{0, u1, u1} Int (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (instHSMul.{0, u1} Int (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (MulAction.toSMul.{0, u1} Int (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) Int.instMonoidInt (AddSubgroup.pointwiseMulAction.{0, u1} Int A (AddCommGroup.toAddGroup.{u1} A _inst_1) Int.instMonoidInt (Module.toDistribMulAction.{0, u1} Int A (Ring.toSemiring.{0} Int (CommRing.toRing.{0} Int Int.instCommRingInt)) (AddCommGroup.toAddCommMonoid.{u1} A _inst_1) (AddCommGroup.intModule.{u1} A _inst_1))))) n (Top.top.{u1} (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (AddSubgroup.instTopAddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)))) (Top.top.{u1} (AddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1)) (AddSubgroup.instTopAddSubgroup.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1))))) -> (DivisibleBy.{u1, 0} A Int (SubNegMonoid.toAddMonoid.{u1} A (AddGroup.toSubNegMonoid.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1))) (SubNegMonoid.SMulInt.{u1} A (AddGroup.toSubNegMonoid.{u1} A (AddCommGroup.toAddGroup.{u1} A _inst_1))) (CommMonoidWithZero.toZero.{0} Int (CancelCommMonoidWithZero.toCommMonoidWithZero.{0} Int (IsDomain.toCancelCommMonoidWithZero.{0} Int Int.instCommSemiringInt (LinearOrderedRing.isDomain.{0} Int (LinearOrderedCommRing.toLinearOrderedRing.{0} Int Int.linearOrderedCommRing))))))
Case conversion may be inaccurate. Consider using '#align add_comm_group.divisible_by_int_of_smul_top_eq_top AddCommGroup.divisibleByIntOfSmulTopEqTopₓ'. -/
/-- If for all `n ≠ 0 ∈ ℤ`, `n • A = A`, then `A` is divisible.
-/
noncomputable def divisibleByIntOfSmulTopEqTop
    (H : ∀ {n : ℤ} (hn : n ≠ 0), n • (⊤ : AddSubgroup A) = ⊤) : DivisibleBy A ℤ
    where
  div a n :=
    if hn : n = 0 then 0 else show a ∈ n • (⊤ : AddSubgroup A) by rw [H hn] <;> trivial.some
  div_zero a := dif_pos rfl
  div_cancel n a hn := by
    rw [dif_neg hn]
    generalize_proofs h1
    exact h1.some_spec.2
#align add_comm_group.divisible_by_int_of_smul_top_eq_top AddCommGroup.divisibleByIntOfSmulTopEqTop

end AddCommGroup

#print divisibleByIntOfCharZero /-
instance (priority := 100) divisibleByIntOfCharZero {𝕜} [DivisionRing 𝕜] [CharZero 𝕜] :
    DivisibleBy 𝕜 ℤ where
  div q n := q / n
  div_zero q := by norm_num
  div_cancel n q hn := by
    rw [zsmul_eq_mul, (Int.cast_commute n _).Eq, div_mul_cancel q (int.cast_ne_zero.mpr hn)]
#align divisible_by_int_of_char_zero divisibleByIntOfCharZero
-/

namespace Group

variable (A : Type _) [Group A]

#print Group.rootableByIntOfRootableByNat /-
/-- A group is `ℤ`-rootable if it is `ℕ`-rootable.
-/
@[to_additive AddGroup.divisibleByIntOfDivisibleByNat
      "An additive group is `ℤ`-divisible if it is `ℕ`-divisible."]
def rootableByIntOfRootableByNat [RootableBy A ℕ] : RootableBy A ℤ
    where
  root a z :=
    match z with
    | (n : ℕ) => RootableBy.root a n
    | -[n+1] => (RootableBy.root a (n + 1))⁻¹
  root_zero a := RootableBy.root_zero a
  root_cancel n a hn := by
    induction n
    · change RootableBy.root a _ ^ _ = a
      norm_num
      rw [RootableBy.root_cancel]
      rw [Int.ofNat_eq_coe] at hn
      exact_mod_cast hn
    · change (RootableBy.root a _)⁻¹ ^ _ = a
      norm_num
      rw [RootableBy.root_cancel]
      norm_num
#align group.rootable_by_int_of_rootable_by_nat Group.rootableByIntOfRootableByNat
#align add_group.divisible_by_int_of_divisible_by_nat AddGroup.divisibleByIntOfDivisibleByNat
-/

#print Group.rootableByNatOfRootableByInt /-
/-- A group is `ℕ`-rootable if it is `ℤ`-rootable
-/
@[to_additive AddGroup.divisibleByNatOfDivisibleByInt
      "An additive group is `ℕ`-divisible if it `ℤ`-divisible."]
def rootableByNatOfRootableByInt [RootableBy A ℤ] : RootableBy A ℕ
    where
  root a n := RootableBy.root a (n : ℤ)
  root_zero a := RootableBy.root_zero a
  root_cancel n a hn :=
    by
    have := RootableBy.root_cancel a (show (n : ℤ) ≠ 0 by exact_mod_cast hn)
    norm_num at this
    exact this
#align group.rootable_by_nat_of_rootable_by_int Group.rootableByNatOfRootableByInt
#align add_group.divisible_by_nat_of_divisible_by_int AddGroup.divisibleByNatOfDivisibleByInt
-/

end Group

section Hom

variable {α A B : Type _}

variable [Zero α] [Monoid A] [Monoid B] [Pow A α] [Pow B α] [RootableBy A α]

variable (f : A → B)

/--
If `f : A → B` is a surjective homomorphism and `A` is `α`-rootable, then `B` is also `α`-rootable.
-/
@[to_additive
      "If `f : A → B` is a surjective homomorphism and\n`A` is `α`-divisible, then `B` is also `α`-divisible."]
noncomputable def Function.Surjective.rootableBy (hf : Function.Surjective f)
    (hpow : ∀ (a : A) (n : α), f (a ^ n) = f a ^ n) : RootableBy B α :=
  rootableByOfPowLeftSurj _ _ fun n hn x =>
    let ⟨y, hy⟩ := hf x
    ⟨f <| RootableBy.root y n,
      (by rw [← hpow (RootableBy.root y n) n, RootableBy.root_cancel _ hn, hy] : _ ^ _ = x)⟩
#align function.surjective.rootable_by Function.Surjective.rootableByₓ
#align function.surjective.divisible_by Function.Surjective.divisibleByₓ

/- warning: rootable_by.surjective_pow -> RootableBy.surjective_pow is a dubious translation:
lean 3 declaration is
  forall (A : Type.{u1}) (α : Type.{u2}) [_inst_7 : Monoid.{u1} A] [_inst_8 : Pow.{u1, u2} A α] [_inst_9 : Zero.{u2} α] [_inst_10 : RootableBy.{u1, u2} A α _inst_7 _inst_8 _inst_9] {n : α}, (Ne.{succ u2} α n (OfNat.ofNat.{u2} α 0 (OfNat.mk.{u2} α 0 (Zero.zero.{u2} α _inst_9)))) -> (Function.Surjective.{succ u1, succ u1} A A (fun (a : A) => HPow.hPow.{u1, u2, u1} A α A (instHPow.{u1, u2} A α _inst_8) a n))
but is expected to have type
  forall (A : Type.{u2}) (α : Type.{u1}) [_inst_7 : Monoid.{u2} A] [_inst_8 : Pow.{u2, u1} A α] [_inst_9 : Zero.{u1} α] [_inst_10 : RootableBy.{u2, u1} A α _inst_7 _inst_8 _inst_9] {n : α}, (Ne.{succ u1} α n (OfNat.ofNat.{u1} α 0 (Zero.toOfNat0.{u1} α _inst_9))) -> (Function.Surjective.{succ u2, succ u2} A A (fun (a : A) => HPow.hPow.{u2, u1, u2} A α A (instHPow.{u2, u1} A α _inst_8) a n))
Case conversion may be inaccurate. Consider using '#align rootable_by.surjective_pow RootableBy.surjective_powₓ'. -/
@[to_additive DivisibleBy.surjective_smul]
theorem RootableBy.surjective_pow (A α : Type _) [Monoid A] [Pow A α] [Zero α] [RootableBy A α]
    {n : α} (hn : n ≠ 0) : Function.Surjective fun a : A => a ^ n := fun a =>
  ⟨RootableBy.root a n, RootableBy.root_cancel a hn⟩
#align rootable_by.surjective_pow RootableBy.surjective_pow
#align divisible_by.surjective_smul DivisibleBy.surjective_smul

end Hom

section Quotient

variable (α : Type _) {A : Type _} [CommGroup A] (B : Subgroup A)

#print QuotientGroup.rootableBy /-
/-- Any quotient group of a rootable group is rootable. -/
@[to_additive QuotientAddGroup.divisibleBy "Any quotient group of a divisible group is divisible"]
noncomputable instance QuotientGroup.rootableBy [RootableBy A ℕ] : RootableBy (A ⧸ B) ℕ :=
  QuotientGroup.mk_surjective.RootableBy _ fun _ _ => rfl
#align quotient_group.rootable_by QuotientGroup.rootableBy
#align quotient_add_group.divisible_by QuotientAddGroup.divisibleBy
-/

end Quotient

