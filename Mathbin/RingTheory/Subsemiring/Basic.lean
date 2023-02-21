/-
Copyright (c) 2020 Yury Kudryashov All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module ring_theory.subsemiring.basic
! leanprover-community/mathlib commit bd9851ca476957ea4549eb19b40e7b5ade9428cc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Module.Basic
import Mathbin.Algebra.Ring.Equiv
import Mathbin.Algebra.Ring.Prod
import Mathbin.Algebra.Order.Ring.InjSurj
import Mathbin.Algebra.GroupRingAction.Subobjects
import Mathbin.Data.Set.Finite
import Mathbin.GroupTheory.Submonoid.Centralizer
import Mathbin.GroupTheory.Submonoid.Membership

/-!
# Bundled subsemirings

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define bundled subsemirings and some standard constructions: `complete_lattice` structure,
`subtype` and `inclusion` ring homomorphisms, subsemiring `map`, `comap` and range (`srange`) of
a `ring_hom` etc.
-/


open BigOperators

universe u v w

section AddSubmonoidWithOneClass

#print AddSubmonoidWithOneClass /-
/-- `add_submonoid_with_one_class S R` says `S` is a type of subsets `s ≤ R` that contain `0`, `1`,
and are closed under `(+)` -/
class AddSubmonoidWithOneClass (S : Type _) (R : Type _) [AddMonoidWithOne R] [SetLike S R] extends
  AddSubmonoidClass S R, OneMemClass S R : Prop
#align add_submonoid_with_one_class AddSubmonoidWithOneClass
-/

variable {S R : Type _} [AddMonoidWithOne R] [SetLike S R] (s : S)

/- warning: nat_cast_mem -> natCast_mem is a dubious translation:
lean 3 declaration is
  forall {S : Type.{u1}} {R : Type.{u2}} [_inst_1 : AddMonoidWithOne.{u2} R] [_inst_2 : SetLike.{u1, u2} S R] (s : S) [_inst_3 : AddSubmonoidWithOneClass.{u1, u2} S R _inst_1 _inst_2] (n : Nat), Membership.Mem.{u2, u1} R S (SetLike.hasMem.{u1, u2} S R _inst_2) ((fun (a : Type) (b : Type.{u2}) [self : HasLiftT.{1, succ u2} a b] => self.0) Nat R (HasLiftT.mk.{1, succ u2} Nat R (CoeTCₓ.coe.{1, succ u2} Nat R (Nat.castCoe.{u2} R (AddMonoidWithOne.toNatCast.{u2} R _inst_1)))) n) s
but is expected to have type
  forall {S : Type.{u2}} {R : Type.{u1}} [_inst_1 : AddMonoidWithOne.{u1} R] [_inst_2 : SetLike.{u2, u1} S R] (s : S) [_inst_3 : AddSubmonoidWithOneClass.{u2, u1} S R _inst_1 _inst_2] (n : Nat), Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) (Nat.cast.{u1} R (AddMonoidWithOne.toNatCast.{u1} R _inst_1) n) s
Case conversion may be inaccurate. Consider using '#align nat_cast_mem natCast_memₓ'. -/
theorem natCast_mem [AddSubmonoidWithOneClass S R] (n : ℕ) : (n : R) ∈ s := by
  induction n <;> simp [zero_mem, add_mem, one_mem, *]
#align nat_cast_mem natCast_mem

#print AddSubmonoidWithOneClass.toAddMonoidWithOne /-
instance (priority := 74) AddSubmonoidWithOneClass.toAddMonoidWithOne
    [AddSubmonoidWithOneClass S R] : AddMonoidWithOne s :=
  { AddSubmonoidClass.toAddMonoid s with
    one := ⟨_, one_mem s⟩
    natCast := fun n => ⟨n, natCast_mem s n⟩
    natCast_zero := Subtype.ext Nat.cast_zero
    natCast_succ := fun n => Subtype.ext (Nat.cast_succ _) }
#align add_submonoid_with_one_class.to_add_monoid_with_one AddSubmonoidWithOneClass.toAddMonoidWithOne
-/

end AddSubmonoidWithOneClass

variable {R : Type u} {S : Type v} {T : Type w} [NonAssocSemiring R] (M : Submonoid R)

section SubsemiringClass

#print SubsemiringClass /-
/-- `subsemiring_class S R` states that `S` is a type of subsets `s ⊆ R` that
are both a multiplicative and an additive submonoid. -/
class SubsemiringClass (S : Type _) (R : Type u) [NonAssocSemiring R] [SetLike S R] extends
  SubmonoidClass S R, AddSubmonoidClass S R : Prop
#align subsemiring_class SubsemiringClass
-/

#print SubsemiringClass.addSubmonoidWithOneClass /-
-- See note [lower instance priority]
instance (priority := 100) SubsemiringClass.addSubmonoidWithOneClass (S : Type _) (R : Type u)
    [NonAssocSemiring R] [SetLike S R] [h : SubsemiringClass S R] : AddSubmonoidWithOneClass S R :=
  { h with }
#align subsemiring_class.add_submonoid_with_one_class SubsemiringClass.addSubmonoidWithOneClass
-/

variable [SetLike S R] [hSR : SubsemiringClass S R] (s : S)

include hSR

#print coe_nat_mem /-
theorem coe_nat_mem (n : ℕ) : (n : R) ∈ s :=
  by
  rw [← nsmul_one]
  exact nsmul_mem (one_mem _) _
#align coe_nat_mem coe_nat_mem
-/

namespace SubsemiringClass

#print SubsemiringClass.toNonAssocSemiring /-
-- Prefer subclasses of `non_assoc_semiring` over subclasses of `subsemiring_class`.
/-- A subsemiring of a `non_assoc_semiring` inherits a `non_assoc_semiring` structure -/
instance (priority := 75) toNonAssocSemiring : NonAssocSemiring s :=
  Subtype.coe_injective.NonAssocSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ => rfl
#align subsemiring_class.to_non_assoc_semiring SubsemiringClass.toNonAssocSemiring
-/

#print SubsemiringClass.nontrivial /-
instance nontrivial [Nontrivial R] : Nontrivial s :=
  nontrivial_of_ne 0 1 fun H => zero_ne_one (congr_arg Subtype.val H)
#align subsemiring_class.nontrivial SubsemiringClass.nontrivial
-/

/- warning: subsemiring_class.no_zero_divisors -> SubsemiringClass.noZeroDivisors is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : SetLike.{u2, u1} S R] [hSR : SubsemiringClass.{u1, u2} S R _inst_1 _inst_2] (s : S) [_inst_3 : NoZeroDivisors.{u1} R (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (MulZeroClass.toHasZero.{u1} R (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))], NoZeroDivisors.{u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S R _inst_2) s) (MulMemClass.mul.{u1, u2} R S (MulOneClass.toHasMul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) _inst_2 (SubmonoidClass.to_mulMemClass.{u2, u1} S R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) _inst_2 (SubsemiringClass.to_submonoidClass.{u1, u2} S R _inst_1 _inst_2 hSR)) s) (ZeroMemClass.zero.{u2, u1} S R _inst_2 (AddZeroClass.toHasZero.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (AddSubmonoidClass.to_zeroMemClass.{u2, u1} S R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))) _inst_2 (SubsemiringClass.to_addSubmonoidClass.{u1, u2} S R _inst_1 _inst_2 hSR)) s)
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : SetLike.{u2, u1} S R] [hSR : SubsemiringClass.{u1, u2} S R _inst_1 _inst_2] (s : S) [_inst_3 : NoZeroDivisors.{u1} R (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (MulZeroOneClass.toZero.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))], NoZeroDivisors.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) (NonUnitalNonAssocSemiring.toMul.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) (SubsemiringClass.toNonAssocSemiring.{u1, u2} R S _inst_1 _inst_2 hSR s))) (ZeroMemClass.zero.{u2, u1} S R _inst_2 (MulZeroOneClass.toZero.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (AddSubmonoidClass.toZeroMemClass.{u2, u1} S R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))) _inst_2 (SubsemiringClass.toAddSubmonoidClass.{u1, u2} S R _inst_1 _inst_2 hSR)) s)
Case conversion may be inaccurate. Consider using '#align subsemiring_class.no_zero_divisors SubsemiringClass.noZeroDivisorsₓ'. -/
instance noZeroDivisors [NoZeroDivisors R] : NoZeroDivisors s
    where eq_zero_or_eq_zero_of_mul_eq_zero x y h :=
    Or.cases_on (eq_zero_or_eq_zero_of_mul_eq_zero <| Subtype.ext_iff.mp h)
      (fun h => Or.inl <| Subtype.eq h) fun h => Or.inr <| Subtype.eq h
#align subsemiring_class.no_zero_divisors SubsemiringClass.noZeroDivisors

#print SubsemiringClass.subtype /-
/-- The natural ring hom from a subsemiring of semiring `R` to `R`. -/
def subtype : s →+* R :=
  { SubmonoidClass.Subtype s, AddSubmonoidClass.Subtype s with toFun := coe }
#align subsemiring_class.subtype SubsemiringClass.subtype
-/

/- warning: subsemiring_class.coe_subtype -> SubsemiringClass.coe_subtype is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : SetLike.{u2, u1} S R] [hSR : SubsemiringClass.{u1, u2} S R _inst_1 _inst_2] (s : S), Eq.{succ u1} ((fun (_x : RingHom.{u1, u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S R _inst_2) s) R (SubsemiringClass.toNonAssocSemiring.{u1, u2} R S _inst_1 _inst_2 hSR s) _inst_1) => (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S R _inst_2) s) -> R) (SubsemiringClass.subtype.{u1, u2} R S _inst_1 _inst_2 hSR s)) (coeFn.{succ u1, succ u1} (RingHom.{u1, u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S R _inst_2) s) R (SubsemiringClass.toNonAssocSemiring.{u1, u2} R S _inst_1 _inst_2 hSR s) _inst_1) (fun (_x : RingHom.{u1, u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S R _inst_2) s) R (SubsemiringClass.toNonAssocSemiring.{u1, u2} R S _inst_1 _inst_2 hSR s) _inst_1) => (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S R _inst_2) s) -> R) (RingHom.hasCoeToFun.{u1, u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S R _inst_2) s) R (SubsemiringClass.toNonAssocSemiring.{u1, u2} R S _inst_1 _inst_2 hSR s) _inst_1) (SubsemiringClass.subtype.{u1, u2} R S _inst_1 _inst_2 hSR s)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S R _inst_2) s) R (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S R _inst_2) s) R (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S R _inst_2) s) R (coeBase.{succ u1, succ u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S R _inst_2) s) R (coeSubtype.{succ u1} R (fun (x : R) => Membership.Mem.{u1, u2} R S (SetLike.hasMem.{u2, u1} S R _inst_2) x s))))))
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : SetLike.{u2, u1} S R] [hSR : SubsemiringClass.{u1, u2} S R _inst_1 _inst_2] (s : S), Eq.{succ u1} (forall (a : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)), (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) => R) a) (FunLike.coe.{succ u1, succ u1, succ u1} (RingHom.{u1, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) R (SubsemiringClass.toNonAssocSemiring.{u1, u2} R S _inst_1 _inst_2 hSR s) _inst_1) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) (fun (_x : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) => R) _x) (MulHomClass.toFunLike.{u1, u1, u1} (RingHom.{u1, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) R (SubsemiringClass.toNonAssocSemiring.{u1, u2} R S _inst_1 _inst_2 hSR s) _inst_1) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) R (NonUnitalNonAssocSemiring.toMul.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) (SubsemiringClass.toNonAssocSemiring.{u1, u2} R S _inst_1 _inst_2 hSR s))) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalRingHomClass.toMulHomClass.{u1, u1, u1} (RingHom.{u1, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) R (SubsemiringClass.toNonAssocSemiring.{u1, u2} R S _inst_1 _inst_2 hSR s) _inst_1) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) (SubsemiringClass.toNonAssocSemiring.{u1, u2} R S _inst_1 _inst_2 hSR s)) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1) (RingHomClass.toNonUnitalRingHomClass.{u1, u1, u1} (RingHom.{u1, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) R (SubsemiringClass.toNonAssocSemiring.{u1, u2} R S _inst_1 _inst_2 hSR s) _inst_1) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) R (SubsemiringClass.toNonAssocSemiring.{u1, u2} R S _inst_1 _inst_2 hSR s) _inst_1 (RingHom.instRingHomClassRingHom.{u1, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_2) x s)) R (SubsemiringClass.toNonAssocSemiring.{u1, u2} R S _inst_1 _inst_2 hSR s) _inst_1)))) (SubsemiringClass.subtype.{u1, u2} R S _inst_1 _inst_2 hSR s)) (Subtype.val.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x (SetLike.coe.{u2, u1} S R _inst_2 s)))
Case conversion may be inaccurate. Consider using '#align subsemiring_class.coe_subtype SubsemiringClass.coe_subtypeₓ'. -/
@[simp]
theorem coe_subtype : (subtype s : s → R) = coe :=
  rfl
#align subsemiring_class.coe_subtype SubsemiringClass.coe_subtype

omit hSR

#print SubsemiringClass.toSemiring /-
-- Prefer subclasses of `semiring` over subclasses of `subsemiring_class`.
/-- A subsemiring of a `semiring` is a `semiring`. -/
instance (priority := 75) toSemiring {R} [Semiring R] [SetLike S R] [SubsemiringClass S R] :
    Semiring s :=
  Subtype.coe_injective.Semiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ => rfl
#align subsemiring_class.to_semiring SubsemiringClass.toSemiring
-/

/- warning: subsemiring_class.coe_pow -> SubsemiringClass.coe_pow is a dubious translation:
lean 3 declaration is
  forall {S : Type.{u1}} (s : S) {R : Type.{u2}} [_inst_3 : Semiring.{u2} R] [_inst_4 : SetLike.{u1, u2} S R] [_inst_5 : SubsemiringClass.{u2, u1} S R (Semiring.toNonAssocSemiring.{u2} R _inst_3) _inst_4] (x : coeSort.{succ u1, succ (succ u2)} S Type.{u2} (SetLike.hasCoeToSort.{u1, u2} S R _inst_4) s) (n : Nat), Eq.{succ u2} R ((fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (coeSort.{succ u1, succ (succ u2)} S Type.{u2} (SetLike.hasCoeToSort.{u1, u2} S R _inst_4) s) R (HasLiftT.mk.{succ u2, succ u2} (coeSort.{succ u1, succ (succ u2)} S Type.{u2} (SetLike.hasCoeToSort.{u1, u2} S R _inst_4) s) R (CoeTCₓ.coe.{succ u2, succ u2} (coeSort.{succ u1, succ (succ u2)} S Type.{u2} (SetLike.hasCoeToSort.{u1, u2} S R _inst_4) s) R (coeBase.{succ u2, succ u2} (coeSort.{succ u1, succ (succ u2)} S Type.{u2} (SetLike.hasCoeToSort.{u1, u2} S R _inst_4) s) R (coeSubtype.{succ u2} R (fun (x : R) => Membership.Mem.{u2, u1} R S (SetLike.hasMem.{u1, u2} S R _inst_4) x s))))) (HPow.hPow.{u2, 0, u2} (coeSort.{succ u1, succ (succ u2)} S Type.{u2} (SetLike.hasCoeToSort.{u1, u2} S R _inst_4) s) Nat (coeSort.{succ u1, succ (succ u2)} S Type.{u2} (SetLike.hasCoeToSort.{u1, u2} S R _inst_4) s) (instHPow.{u2, 0} (coeSort.{succ u1, succ (succ u2)} S Type.{u2} (SetLike.hasCoeToSort.{u1, u2} S R _inst_4) s) Nat (SubmonoidClass.nPow.{u2, u1} R (MonoidWithZero.toMonoid.{u2} R (Semiring.toMonoidWithZero.{u2} R _inst_3)) S _inst_4 (SubsemiringClass.to_submonoidClass.{u2, u1} S R (Semiring.toNonAssocSemiring.{u2} R _inst_3) _inst_4 _inst_5) s)) x n)) (HPow.hPow.{u2, 0, u2} R Nat R (instHPow.{u2, 0} R Nat (Monoid.Pow.{u2} R (MonoidWithZero.toMonoid.{u2} R (Semiring.toMonoidWithZero.{u2} R _inst_3)))) ((fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (coeSort.{succ u1, succ (succ u2)} S Type.{u2} (SetLike.hasCoeToSort.{u1, u2} S R _inst_4) s) R (HasLiftT.mk.{succ u2, succ u2} (coeSort.{succ u1, succ (succ u2)} S Type.{u2} (SetLike.hasCoeToSort.{u1, u2} S R _inst_4) s) R (CoeTCₓ.coe.{succ u2, succ u2} (coeSort.{succ u1, succ (succ u2)} S Type.{u2} (SetLike.hasCoeToSort.{u1, u2} S R _inst_4) s) R (coeBase.{succ u2, succ u2} (coeSort.{succ u1, succ (succ u2)} S Type.{u2} (SetLike.hasCoeToSort.{u1, u2} S R _inst_4) s) R (coeSubtype.{succ u2} R (fun (x : R) => Membership.Mem.{u2, u1} R S (SetLike.hasMem.{u1, u2} S R _inst_4) x s))))) x) n)
but is expected to have type
  forall {S : Type.{u2}} (s : S) {R : Type.{u1}} [_inst_3 : Semiring.{u1} R] [_inst_4 : SetLike.{u2, u1} S R] [_inst_5 : SubsemiringClass.{u1, u2} S R (Semiring.toNonAssocSemiring.{u1} R _inst_3) _inst_4] (x : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_4) x s)) (n : Nat), Eq.{succ u1} R (Subtype.val.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x (SetLike.coe.{u2, u1} S R _inst_4 s)) (HPow.hPow.{u1, 0, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_4) x s)) Nat (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_4) x s)) (instHPow.{u1, 0} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u2} R S (SetLike.instMembership.{u2, u1} S R _inst_4) x s)) Nat (SubmonoidClass.nPow.{u1, u2} R (MonoidWithZero.toMonoid.{u1} R (Semiring.toMonoidWithZero.{u1} R _inst_3)) S _inst_4 (SubsemiringClass.toSubmonoidClass.{u1, u2} S R (Semiring.toNonAssocSemiring.{u1} R _inst_3) _inst_4 _inst_5) s)) x n)) (HPow.hPow.{u1, 0, u1} R Nat R (instHPow.{u1, 0} R Nat (Monoid.Pow.{u1} R (MonoidWithZero.toMonoid.{u1} R (Semiring.toMonoidWithZero.{u1} R _inst_3)))) (Subtype.val.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x (SetLike.coe.{u2, u1} S R _inst_4 s)) x) n)
Case conversion may be inaccurate. Consider using '#align subsemiring_class.coe_pow SubsemiringClass.coe_powₓ'. -/
@[simp, norm_cast]
theorem coe_pow {R} [Semiring R] [SetLike S R] [SubsemiringClass S R] (x : s) (n : ℕ) :
    ((x ^ n : s) : R) = (x ^ n : R) :=
  by
  induction' n with n ih
  · simp
  · simp [pow_succ, ih]
#align subsemiring_class.coe_pow SubsemiringClass.coe_pow

#print SubsemiringClass.toCommSemiring /-
/-- A subsemiring of a `comm_semiring` is a `comm_semiring`. -/
instance toCommSemiring {R} [CommSemiring R] [SetLike S R] [SubsemiringClass S R] :
    CommSemiring s :=
  Subtype.coe_injective.CommSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ => rfl
#align subsemiring_class.to_comm_semiring SubsemiringClass.toCommSemiring
-/

#print SubsemiringClass.toOrderedSemiring /-
/-- A subsemiring of an `ordered_semiring` is an `ordered_semiring`. -/
instance toOrderedSemiring {R} [OrderedSemiring R] [SetLike S R] [SubsemiringClass S R] :
    OrderedSemiring s :=
  Subtype.coe_injective.OrderedSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring_class.to_ordered_semiring SubsemiringClass.toOrderedSemiring
-/

#print SubsemiringClass.toStrictOrderedSemiring /-
/-- A subsemiring of an `strict_ordered_semiring` is an `strict_ordered_semiring`. -/
instance toStrictOrderedSemiring {R} [StrictOrderedSemiring R] [SetLike S R]
    [SubsemiringClass S R] : StrictOrderedSemiring s :=
  Subtype.coe_injective.StrictOrderedSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring_class.to_strict_ordered_semiring SubsemiringClass.toStrictOrderedSemiring
-/

#print SubsemiringClass.toOrderedCommSemiring /-
/-- A subsemiring of an `ordered_comm_semiring` is an `ordered_comm_semiring`. -/
instance toOrderedCommSemiring {R} [OrderedCommSemiring R] [SetLike S R] [SubsemiringClass S R] :
    OrderedCommSemiring s :=
  Subtype.coe_injective.OrderedCommSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring_class.to_ordered_comm_semiring SubsemiringClass.toOrderedCommSemiring
-/

#print SubsemiringClass.toStrictOrderedCommSemiring /-
/-- A subsemiring of an `strict_ordered_comm_semiring` is an `strict_ordered_comm_semiring`. -/
instance toStrictOrderedCommSemiring {R} [StrictOrderedCommSemiring R] [SetLike S R]
    [SubsemiringClass S R] : StrictOrderedCommSemiring s :=
  Subtype.coe_injective.StrictOrderedCommSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring_class.to_strict_ordered_comm_semiring SubsemiringClass.toStrictOrderedCommSemiring
-/

#print SubsemiringClass.toLinearOrderedSemiring /-
/-- A subsemiring of a `linear_ordered_semiring` is a `linear_ordered_semiring`. -/
instance toLinearOrderedSemiring {R} [LinearOrderedSemiring R] [SetLike S R]
    [SubsemiringClass S R] : LinearOrderedSemiring s :=
  Subtype.coe_injective.LinearOrderedSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) fun _ _ => rfl
#align subsemiring_class.to_linear_ordered_semiring SubsemiringClass.toLinearOrderedSemiring
-/

#print SubsemiringClass.toLinearOrderedCommSemiring /-
/-- A subsemiring of a `linear_ordered_comm_semiring` is a `linear_ordered_comm_semiring`. -/
instance toLinearOrderedCommSemiring {R} [LinearOrderedCommSemiring R] [SetLike S R]
    [SubsemiringClass S R] : LinearOrderedCommSemiring s :=
  Subtype.coe_injective.LinearOrderedCommSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) fun _ _ => rfl
#align subsemiring_class.to_linear_ordered_comm_semiring SubsemiringClass.toLinearOrderedCommSemiring
-/

end SubsemiringClass

end SubsemiringClass

variable [NonAssocSemiring S] [NonAssocSemiring T]

#print Subsemiring /-
/-- A subsemiring of a semiring `R` is a subset `s` that is both a multiplicative and an additive
submonoid. -/
structure Subsemiring (R : Type u) [NonAssocSemiring R] extends Submonoid R, AddSubmonoid R
#align subsemiring Subsemiring
-/

/-- Reinterpret a `subsemiring` as a `submonoid`. -/
add_decl_doc Subsemiring.toSubmonoid

/-- Reinterpret a `subsemiring` as an `add_submonoid`. -/
add_decl_doc Subsemiring.toAddSubmonoid

namespace Subsemiring

instance : SetLike (Subsemiring R) R
    where
  coe := Subsemiring.carrier
  coe_injective' p q h := by cases p <;> cases q <;> congr

instance : SubsemiringClass (Subsemiring R) R
    where
  zero_mem := zero_mem'
  add_mem := add_mem'
  one_mem := one_mem'
  mul_mem := mul_mem'

/- warning: subsemiring.mem_carrier -> Subsemiring.mem_carrier is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Subsemiring.{u1} R _inst_1} {x : R}, Iff (Membership.Mem.{u1, u1} R (Set.{u1} R) (Set.hasMem.{u1} R) x (Subsemiring.carrier.{u1} R _inst_1 s)) (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Subsemiring.{u1} R _inst_1} {x : R}, Iff (Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x (Subsemigroup.carrier.{u1} R (MulOneClass.toMul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Submonoid.toSubsemigroup.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (Subsemiring.toSubmonoid.{u1} R _inst_1 s)))) (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)
Case conversion may be inaccurate. Consider using '#align subsemiring.mem_carrier Subsemiring.mem_carrierₓ'. -/
@[simp]
theorem mem_carrier {s : Subsemiring R} {x : R} : x ∈ s.carrier ↔ x ∈ s :=
  Iff.rfl
#align subsemiring.mem_carrier Subsemiring.mem_carrier

/- warning: subsemiring.ext -> Subsemiring.ext is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {S : Subsemiring.{u1} R _inst_1} {T : Subsemiring.{u1} R _inst_1}, (forall (x : R), Iff (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x S) (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x T)) -> (Eq.{succ u1} (Subsemiring.{u1} R _inst_1) S T)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {S : Subsemiring.{u1} R _inst_1} {T : Subsemiring.{u1} R _inst_1}, (forall (x : R), Iff (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x S) (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x T)) -> (Eq.{succ u1} (Subsemiring.{u1} R _inst_1) S T)
Case conversion may be inaccurate. Consider using '#align subsemiring.ext Subsemiring.extₓ'. -/
/-- Two subsemirings are equal if they have the same elements. -/
@[ext]
theorem ext {S T : Subsemiring R} (h : ∀ x, x ∈ S ↔ x ∈ T) : S = T :=
  SetLike.ext h
#align subsemiring.ext Subsemiring.ext

/- warning: subsemiring.copy -> Subsemiring.copy is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (S : Subsemiring.{u1} R _inst_1) (s : Set.{u1} R), (Eq.{succ u1} (Set.{u1} R) s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) S)) -> (Subsemiring.{u1} R _inst_1)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (S : Subsemiring.{u1} R _inst_1) (s : Set.{u1} R), (Eq.{succ u1} (Set.{u1} R) s (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) S)) -> (Subsemiring.{u1} R _inst_1)
Case conversion may be inaccurate. Consider using '#align subsemiring.copy Subsemiring.copyₓ'. -/
/-- Copy of a subsemiring with a new `carrier` equal to the old one. Useful to fix definitional
equalities.-/
protected def copy (S : Subsemiring R) (s : Set R) (hs : s = ↑S) : Subsemiring R :=
  { S.toAddSubmonoid.copy s hs, S.toSubmonoid.copy s hs with carrier := s }
#align subsemiring.copy Subsemiring.copy

/- warning: subsemiring.coe_copy -> Subsemiring.coe_copy is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (S : Subsemiring.{u1} R _inst_1) (s : Set.{u1} R) (hs : Eq.{succ u1} (Set.{u1} R) s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) S)), Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) (Subsemiring.copy.{u1} R _inst_1 S s hs)) s
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (S : Subsemiring.{u1} R _inst_1) (s : Set.{u1} R) (hs : Eq.{succ u1} (Set.{u1} R) s (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) S)), Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) (Subsemiring.copy.{u1} R _inst_1 S s hs)) s
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_copy Subsemiring.coe_copyₓ'. -/
@[simp]
theorem coe_copy (S : Subsemiring R) (s : Set R) (hs : s = ↑S) : (S.copy s hs : Set R) = s :=
  rfl
#align subsemiring.coe_copy Subsemiring.coe_copy

/- warning: subsemiring.copy_eq -> Subsemiring.copy_eq is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (S : Subsemiring.{u1} R _inst_1) (s : Set.{u1} R) (hs : Eq.{succ u1} (Set.{u1} R) s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) S)), Eq.{succ u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.copy.{u1} R _inst_1 S s hs) S
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (S : Subsemiring.{u1} R _inst_1) (s : Set.{u1} R) (hs : Eq.{succ u1} (Set.{u1} R) s (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) S)), Eq.{succ u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.copy.{u1} R _inst_1 S s hs) S
Case conversion may be inaccurate. Consider using '#align subsemiring.copy_eq Subsemiring.copy_eqₓ'. -/
theorem copy_eq (S : Subsemiring R) (s : Set R) (hs : s = ↑S) : S.copy s hs = S :=
  SetLike.coe_injective hs
#align subsemiring.copy_eq Subsemiring.copy_eq

#print Subsemiring.toSubmonoid_injective /-
theorem toSubmonoid_injective : Function.Injective (toSubmonoid : Subsemiring R → Submonoid R)
  | r, s, h => ext (SetLike.ext_iff.mp h : _)
#align subsemiring.to_submonoid_injective Subsemiring.toSubmonoid_injective
-/

/- warning: subsemiring.to_submonoid_strict_mono -> Subsemiring.toSubmonoid_strictMono is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R], StrictMono.{u1, u1} (Subsemiring.{u1} R _inst_1) (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (SetLike.partialOrder.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1))) (PartialOrder.toPreorder.{u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (SetLike.partialOrder.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.setLike.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))))) (Subsemiring.toSubmonoid.{u1} R _inst_1)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R], StrictMono.{u1, u1} (Subsemiring.{u1} R _inst_1) (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (SetLike.instPartialOrder.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1))) (PartialOrder.toPreorder.{u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (CompleteSemilatticeInf.toPartialOrder.{u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Submonoid.instCompleteLatticeSubmonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)))))) (Subsemiring.toSubmonoid.{u1} R _inst_1)
Case conversion may be inaccurate. Consider using '#align subsemiring.to_submonoid_strict_mono Subsemiring.toSubmonoid_strictMonoₓ'. -/
@[mono]
theorem toSubmonoid_strictMono : StrictMono (toSubmonoid : Subsemiring R → Submonoid R) :=
  fun _ _ => id
#align subsemiring.to_submonoid_strict_mono Subsemiring.toSubmonoid_strictMono

/- warning: subsemiring.to_submonoid_mono -> Subsemiring.toSubmonoid_mono is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R], Monotone.{u1, u1} (Subsemiring.{u1} R _inst_1) (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (SetLike.partialOrder.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1))) (PartialOrder.toPreorder.{u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (SetLike.partialOrder.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.setLike.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))))) (Subsemiring.toSubmonoid.{u1} R _inst_1)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R], Monotone.{u1, u1} (Subsemiring.{u1} R _inst_1) (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (SetLike.instPartialOrder.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1))) (PartialOrder.toPreorder.{u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (CompleteSemilatticeInf.toPartialOrder.{u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Submonoid.instCompleteLatticeSubmonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)))))) (Subsemiring.toSubmonoid.{u1} R _inst_1)
Case conversion may be inaccurate. Consider using '#align subsemiring.to_submonoid_mono Subsemiring.toSubmonoid_monoₓ'. -/
@[mono]
theorem toSubmonoid_mono : Monotone (toSubmonoid : Subsemiring R → Submonoid R) :=
  toSubmonoid_strictMono.Monotone
#align subsemiring.to_submonoid_mono Subsemiring.toSubmonoid_mono

#print Subsemiring.toAddSubmonoid_injective /-
theorem toAddSubmonoid_injective :
    Function.Injective (toAddSubmonoid : Subsemiring R → AddSubmonoid R)
  | r, s, h => ext (SetLike.ext_iff.mp h : _)
#align subsemiring.to_add_submonoid_injective Subsemiring.toAddSubmonoid_injective
-/

/- warning: subsemiring.to_add_submonoid_strict_mono -> Subsemiring.toAddSubmonoid_strictMono is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R], StrictMono.{u1, u1} (Subsemiring.{u1} R _inst_1) (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (SetLike.partialOrder.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1))) (PartialOrder.toPreorder.{u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (SetLike.partialOrder.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.setLike.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))))) (Subsemiring.toAddSubmonoid.{u1} R _inst_1)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R], StrictMono.{u1, u1} (Subsemiring.{u1} R _inst_1) (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (SetLike.instPartialOrder.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1))) (PartialOrder.toPreorder.{u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (CompleteSemilatticeInf.toPartialOrder.{u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (CompleteLattice.toCompleteSemilatticeInf.{u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (AddSubmonoid.instCompleteLatticeAddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))))))) (Subsemiring.toAddSubmonoid.{u1} R _inst_1)
Case conversion may be inaccurate. Consider using '#align subsemiring.to_add_submonoid_strict_mono Subsemiring.toAddSubmonoid_strictMonoₓ'. -/
@[mono]
theorem toAddSubmonoid_strictMono : StrictMono (toAddSubmonoid : Subsemiring R → AddSubmonoid R) :=
  fun _ _ => id
#align subsemiring.to_add_submonoid_strict_mono Subsemiring.toAddSubmonoid_strictMono

/- warning: subsemiring.to_add_submonoid_mono -> Subsemiring.toAddSubmonoid_mono is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R], Monotone.{u1, u1} (Subsemiring.{u1} R _inst_1) (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (SetLike.partialOrder.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1))) (PartialOrder.toPreorder.{u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (SetLike.partialOrder.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.setLike.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))))) (Subsemiring.toAddSubmonoid.{u1} R _inst_1)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R], Monotone.{u1, u1} (Subsemiring.{u1} R _inst_1) (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (SetLike.instPartialOrder.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1))) (PartialOrder.toPreorder.{u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (CompleteSemilatticeInf.toPartialOrder.{u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (CompleteLattice.toCompleteSemilatticeInf.{u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (AddSubmonoid.instCompleteLatticeAddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))))))) (Subsemiring.toAddSubmonoid.{u1} R _inst_1)
Case conversion may be inaccurate. Consider using '#align subsemiring.to_add_submonoid_mono Subsemiring.toAddSubmonoid_monoₓ'. -/
@[mono]
theorem toAddSubmonoid_mono : Monotone (toAddSubmonoid : Subsemiring R → AddSubmonoid R) :=
  toAddSubmonoid_strictMono.Monotone
#align subsemiring.to_add_submonoid_mono Subsemiring.toAddSubmonoid_mono

/- warning: subsemiring.mk' -> Subsemiring.mk' is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Set.{u1} R) (sm : Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))), (Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.setLike.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)))))) sm) s) -> (forall (sa : AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))), (Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.setLike.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))))))) sa) s) -> (Subsemiring.{u1} R _inst_1))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Set.{u1} R) (sm : Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))), (Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.instSetLikeSubmonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) sm) s) -> (forall (sa : AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))), (Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.instSetLikeAddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) sa) s) -> (Subsemiring.{u1} R _inst_1))
Case conversion may be inaccurate. Consider using '#align subsemiring.mk' Subsemiring.mk'ₓ'. -/
/-- Construct a `subsemiring R` from a set `s`, a submonoid `sm`, and an additive
submonoid `sa` such that `x ∈ s ↔ x ∈ sm ↔ x ∈ sa`. -/
protected def mk' (s : Set R) (sm : Submonoid R) (hm : ↑sm = s) (sa : AddSubmonoid R)
    (ha : ↑sa = s) : Subsemiring R where
  carrier := s
  zero_mem' := ha ▸ sa.zero_mem
  one_mem' := hm ▸ sm.one_mem
  add_mem' x y := by simpa only [← ha] using sa.add_mem
  mul_mem' x y := by simpa only [← hm] using sm.mul_mem
#align subsemiring.mk' Subsemiring.mk'

/- warning: subsemiring.coe_mk' -> Subsemiring.coe_mk' is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R} {sm : Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))} (hm : Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.setLike.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)))))) sm) s) {sa : AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))} (ha : Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.setLike.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))))))) sa) s), Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) (Subsemiring.mk'.{u1} R _inst_1 s sm hm sa ha)) s
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R} {sm : Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))} (hm : Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.instSetLikeSubmonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) sm) s) {sa : AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))} (ha : Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.instSetLikeAddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) sa) s), Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) (Subsemiring.mk'.{u1} R _inst_1 s sm hm sa ha)) s
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_mk' Subsemiring.coe_mk'ₓ'. -/
@[simp]
theorem coe_mk' {s : Set R} {sm : Submonoid R} (hm : ↑sm = s) {sa : AddSubmonoid R} (ha : ↑sa = s) :
    (Subsemiring.mk' s sm hm sa ha : Set R) = s :=
  rfl
#align subsemiring.coe_mk' Subsemiring.coe_mk'

/- warning: subsemiring.mem_mk' -> Subsemiring.mem_mk' is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R} {sm : Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))} (hm : Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.setLike.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)))))) sm) s) {sa : AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))} (ha : Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.setLike.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))))))) sa) s) {x : R}, Iff (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x (Subsemiring.mk'.{u1} R _inst_1 s sm hm sa ha)) (Membership.Mem.{u1, u1} R (Set.{u1} R) (Set.hasMem.{u1} R) x s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R} {sm : Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))} (hm : Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.instSetLikeSubmonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) sm) s) {sa : AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))} (ha : Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.instSetLikeAddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) sa) s) {x : R}, Iff (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x (Subsemiring.mk'.{u1} R _inst_1 s sm hm sa ha)) (Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x s)
Case conversion may be inaccurate. Consider using '#align subsemiring.mem_mk' Subsemiring.mem_mk'ₓ'. -/
@[simp]
theorem mem_mk' {s : Set R} {sm : Submonoid R} (hm : ↑sm = s) {sa : AddSubmonoid R} (ha : ↑sa = s)
    {x : R} : x ∈ Subsemiring.mk' s sm hm sa ha ↔ x ∈ s :=
  Iff.rfl
#align subsemiring.mem_mk' Subsemiring.mem_mk'

/- warning: subsemiring.mk'_to_submonoid -> Subsemiring.mk'_toSubmonoid is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R} {sm : Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))} (hm : Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.setLike.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)))))) sm) s) {sa : AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))} (ha : Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.setLike.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))))))) sa) s), Eq.{succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Subsemiring.toSubmonoid.{u1} R _inst_1 (Subsemiring.mk'.{u1} R _inst_1 s sm hm sa ha)) sm
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R} {sm : Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))} (hm : Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.instSetLikeSubmonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) sm) s) {sa : AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))} (ha : Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.instSetLikeAddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) sa) s), Eq.{succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Subsemiring.toSubmonoid.{u1} R _inst_1 (Subsemiring.mk'.{u1} R _inst_1 s sm hm sa ha)) sm
Case conversion may be inaccurate. Consider using '#align subsemiring.mk'_to_submonoid Subsemiring.mk'_toSubmonoidₓ'. -/
@[simp]
theorem mk'_toSubmonoid {s : Set R} {sm : Submonoid R} (hm : ↑sm = s) {sa : AddSubmonoid R}
    (ha : ↑sa = s) : (Subsemiring.mk' s sm hm sa ha).toSubmonoid = sm :=
  SetLike.coe_injective hm.symm
#align subsemiring.mk'_to_submonoid Subsemiring.mk'_toSubmonoid

/- warning: subsemiring.mk'_to_add_submonoid -> Subsemiring.mk'_toAddSubmonoid is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R} {sm : Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))} (hm : Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.setLike.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)))))) sm) s) {sa : AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))} (ha : Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.setLike.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))))))) sa) s), Eq.{succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Subsemiring.toAddSubmonoid.{u1} R _inst_1 (Subsemiring.mk'.{u1} R _inst_1 s sm hm sa ha)) sa
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R} {sm : Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))} (hm : Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.instSetLikeSubmonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) sm) s) {sa : AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))} (ha : Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.instSetLikeAddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) sa) s), Eq.{succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Subsemiring.toAddSubmonoid.{u1} R _inst_1 (Subsemiring.mk'.{u1} R _inst_1 s sm hm sa ha)) sa
Case conversion may be inaccurate. Consider using '#align subsemiring.mk'_to_add_submonoid Subsemiring.mk'_toAddSubmonoidₓ'. -/
@[simp]
theorem mk'_toAddSubmonoid {s : Set R} {sm : Submonoid R} (hm : ↑sm = s) {sa : AddSubmonoid R}
    (ha : ↑sa = s) : (Subsemiring.mk' s sm hm sa ha).toAddSubmonoid = sa :=
  SetLike.coe_injective ha.symm
#align subsemiring.mk'_to_add_submonoid Subsemiring.mk'_toAddSubmonoid

end Subsemiring

namespace Subsemiring

variable (s : Subsemiring R)

/- warning: subsemiring.one_mem -> Subsemiring.one_mem is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) (OfNat.ofNat.{u1} R 1 (OfNat.mk.{u1} R 1 (One.one.{u1} R (AddMonoidWithOne.toOne.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))))) s
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) (OfNat.ofNat.{u1} R 1 (One.toOfNat1.{u1} R (NonAssocSemiring.toOne.{u1} R _inst_1))) s
Case conversion may be inaccurate. Consider using '#align subsemiring.one_mem Subsemiring.one_memₓ'. -/
/-- A subsemiring contains the semiring's 1. -/
protected theorem one_mem : (1 : R) ∈ s :=
  one_mem s
#align subsemiring.one_mem Subsemiring.one_mem

/- warning: subsemiring.zero_mem -> Subsemiring.zero_mem is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) (OfNat.ofNat.{u1} R 0 (OfNat.mk.{u1} R 0 (Zero.zero.{u1} R (MulZeroClass.toHasZero.{u1} R (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))))) s
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) (OfNat.ofNat.{u1} R 0 (Zero.toOfNat0.{u1} R (MulZeroOneClass.toZero.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)))) s
Case conversion may be inaccurate. Consider using '#align subsemiring.zero_mem Subsemiring.zero_memₓ'. -/
/-- A subsemiring contains the semiring's 0. -/
protected theorem zero_mem : (0 : R) ∈ s :=
  zero_mem s
#align subsemiring.zero_mem Subsemiring.zero_mem

/- warning: subsemiring.mul_mem -> Subsemiring.mul_mem is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) {x : R} {y : R}, (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) y s) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) (HMul.hMul.{u1, u1, u1} R R R (instHMul.{u1} R (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) x y) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) {x : R} {y : R}, (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s) -> (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) y s) -> (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) (HMul.hMul.{u1, u1, u1} R R R (instHMul.{u1} R (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) x y) s)
Case conversion may be inaccurate. Consider using '#align subsemiring.mul_mem Subsemiring.mul_memₓ'. -/
/-- A subsemiring is closed under multiplication. -/
protected theorem mul_mem {x y : R} : x ∈ s → y ∈ s → x * y ∈ s :=
  mul_mem
#align subsemiring.mul_mem Subsemiring.mul_mem

/- warning: subsemiring.add_mem -> Subsemiring.add_mem is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) {x : R} {y : R}, (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) y s) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) (HAdd.hAdd.{u1, u1, u1} R R R (instHAdd.{u1} R (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) x y) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) {x : R} {y : R}, (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s) -> (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) y s) -> (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) (HAdd.hAdd.{u1, u1, u1} R R R (instHAdd.{u1} R (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) x y) s)
Case conversion may be inaccurate. Consider using '#align subsemiring.add_mem Subsemiring.add_memₓ'. -/
/-- A subsemiring is closed under addition. -/
protected theorem add_mem {x y : R} : x ∈ s → y ∈ s → x + y ∈ s :=
  add_mem
#align subsemiring.add_mem Subsemiring.add_mem

/- warning: subsemiring.list_prod_mem -> Subsemiring.list_prod_mem is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) {l : List.{u1} R}, (forall (x : R), (Membership.Mem.{u1, u1} R (List.{u1} R) (List.hasMem.{u1} R) x l) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) x s)) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) (List.prod.{u1} R (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)))) (AddMonoidWithOne.toOne.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)))) l) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) {l : List.{u1} R}, (forall (x : R), (Membership.mem.{u1, u1} R (List.{u1} R) (List.instMembershipList.{u1} R) x l) -> (Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) x s)) -> (Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) (List.prod.{u1} R (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) (Semiring.toOne.{u1} R _inst_4) l) s)
Case conversion may be inaccurate. Consider using '#align subsemiring.list_prod_mem Subsemiring.list_prod_memₓ'. -/
/-- Product of a list of elements in a `subsemiring` is in the `subsemiring`. -/
theorem list_prod_mem {R : Type _} [Semiring R] (s : Subsemiring R) {l : List R} :
    (∀ x ∈ l, x ∈ s) → l.Prod ∈ s :=
  list_prod_mem
#align subsemiring.list_prod_mem Subsemiring.list_prod_mem

/- warning: subsemiring.list_sum_mem -> Subsemiring.list_sum_mem is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) {l : List.{u1} R}, (forall (x : R), (Membership.Mem.{u1, u1} R (List.{u1} R) (List.hasMem.{u1} R) x l) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s)) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) (List.sum.{u1} R (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (MulZeroClass.toHasZero.{u1} R (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) l) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) {l : List.{u1} R}, (forall (x : R), (Membership.mem.{u1, u1} R (List.{u1} R) (List.instMembershipList.{u1} R) x l) -> (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) -> (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) (List.sum.{u1} R (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (MulZeroOneClass.toZero.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) l) s)
Case conversion may be inaccurate. Consider using '#align subsemiring.list_sum_mem Subsemiring.list_sum_memₓ'. -/
/-- Sum of a list of elements in a `subsemiring` is in the `subsemiring`. -/
protected theorem list_sum_mem {l : List R} : (∀ x ∈ l, x ∈ s) → l.Sum ∈ s :=
  list_sum_mem
#align subsemiring.list_sum_mem Subsemiring.list_sum_mem

/- warning: subsemiring.multiset_prod_mem -> Subsemiring.multiset_prod_mem is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : CommSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) (m : Multiset.{u1} R), (forall (a : R), (Membership.Mem.{u1, u1} R (Multiset.{u1} R) (Multiset.hasMem.{u1} R) a m) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4)))) a s)) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4)))) (Multiset.prod.{u1} R (CommSemiring.toCommMonoid.{u1} R _inst_4) m) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : CommSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) (m : Multiset.{u1} R), (forall (a : R), (Membership.mem.{u1, u1} R (Multiset.{u1} R) (Multiset.instMembershipMultiset.{u1} R) a m) -> (Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4)))) a s)) -> (Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4)))) (Multiset.prod.{u1} R (CommSemiring.toCommMonoid.{u1} R _inst_4) m) s)
Case conversion may be inaccurate. Consider using '#align subsemiring.multiset_prod_mem Subsemiring.multiset_prod_memₓ'. -/
/-- Product of a multiset of elements in a `subsemiring` of a `comm_semiring`
    is in the `subsemiring`. -/
protected theorem multiset_prod_mem {R} [CommSemiring R] (s : Subsemiring R) (m : Multiset R) :
    (∀ a ∈ m, a ∈ s) → m.Prod ∈ s :=
  multiset_prod_mem m
#align subsemiring.multiset_prod_mem Subsemiring.multiset_prod_mem

/- warning: subsemiring.multiset_sum_mem -> Subsemiring.multiset_sum_mem is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) (m : Multiset.{u1} R), (forall (a : R), (Membership.Mem.{u1, u1} R (Multiset.{u1} R) (Multiset.hasMem.{u1} R) a m) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) a s)) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) (Multiset.sum.{u1} R (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) m) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) (m : Multiset.{u1} R), (forall (a : R), (Membership.mem.{u1, u1} R (Multiset.{u1} R) (Multiset.instMembershipMultiset.{u1} R) a m) -> (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) a s)) -> (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) (Multiset.sum.{u1} R (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) m) s)
Case conversion may be inaccurate. Consider using '#align subsemiring.multiset_sum_mem Subsemiring.multiset_sum_memₓ'. -/
/-- Sum of a multiset of elements in a `subsemiring` of a `semiring` is
in the `add_subsemiring`. -/
protected theorem multiset_sum_mem (m : Multiset R) : (∀ a ∈ m, a ∈ s) → m.Sum ∈ s :=
  multiset_sum_mem m
#align subsemiring.multiset_sum_mem Subsemiring.multiset_sum_mem

/- warning: subsemiring.prod_mem -> Subsemiring.prod_mem is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : CommSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) {ι : Type.{u2}} {t : Finset.{u2} ι} {f : ι -> R}, (forall (c : ι), (Membership.Mem.{u2, u2} ι (Finset.{u2} ι) (Finset.hasMem.{u2} ι) c t) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4)))) (f c) s)) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4)))) (Finset.prod.{u1, u2} R ι (CommSemiring.toCommMonoid.{u1} R _inst_4) t (fun (i : ι) => f i)) s)
but is expected to have type
  forall {R : Type.{u2}} [_inst_4 : CommSemiring.{u2} R] (s : Subsemiring.{u2} R (Semiring.toNonAssocSemiring.{u2} R (CommSemiring.toSemiring.{u2} R _inst_4))) {ι : Type.{u1}} {t : Finset.{u1} ι} {f : ι -> R}, (forall (c : ι), (Membership.mem.{u1, u1} ι (Finset.{u1} ι) (Finset.instMembershipFinset.{u1} ι) c t) -> (Membership.mem.{u2, u2} R (Subsemiring.{u2} R (Semiring.toNonAssocSemiring.{u2} R (CommSemiring.toSemiring.{u2} R _inst_4))) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} R (Semiring.toNonAssocSemiring.{u2} R (CommSemiring.toSemiring.{u2} R _inst_4))) R (Subsemiring.instSetLikeSubsemiring.{u2} R (Semiring.toNonAssocSemiring.{u2} R (CommSemiring.toSemiring.{u2} R _inst_4)))) (f c) s)) -> (Membership.mem.{u2, u2} R (Subsemiring.{u2} R (Semiring.toNonAssocSemiring.{u2} R (CommSemiring.toSemiring.{u2} R _inst_4))) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} R (Semiring.toNonAssocSemiring.{u2} R (CommSemiring.toSemiring.{u2} R _inst_4))) R (Subsemiring.instSetLikeSubsemiring.{u2} R (Semiring.toNonAssocSemiring.{u2} R (CommSemiring.toSemiring.{u2} R _inst_4)))) (Finset.prod.{u2, u1} R ι (CommSemiring.toCommMonoid.{u2} R _inst_4) t (fun (i : ι) => f i)) s)
Case conversion may be inaccurate. Consider using '#align subsemiring.prod_mem Subsemiring.prod_memₓ'. -/
/-- Product of elements of a subsemiring of a `comm_semiring` indexed by a `finset` is in the
    subsemiring. -/
protected theorem prod_mem {R : Type _} [CommSemiring R] (s : Subsemiring R) {ι : Type _}
    {t : Finset ι} {f : ι → R} (h : ∀ c ∈ t, f c ∈ s) : (∏ i in t, f i) ∈ s :=
  prod_mem h
#align subsemiring.prod_mem Subsemiring.prod_mem

/- warning: subsemiring.sum_mem -> Subsemiring.sum_mem is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) {ι : Type.{u2}} {t : Finset.{u2} ι} {f : ι -> R}, (forall (c : ι), (Membership.Mem.{u2, u2} ι (Finset.{u2} ι) (Finset.hasMem.{u2} ι) c t) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) (f c) s)) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) (Finset.sum.{u1, u2} R ι (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) t (fun (i : ι) => f i)) s)
but is expected to have type
  forall {R : Type.{u2}} [_inst_1 : NonAssocSemiring.{u2} R] (s : Subsemiring.{u2} R _inst_1) {ι : Type.{u1}} {t : Finset.{u1} ι} {f : ι -> R}, (forall (c : ι), (Membership.mem.{u1, u1} ι (Finset.{u1} ι) (Finset.instMembershipFinset.{u1} ι) c t) -> (Membership.mem.{u2, u2} R (Subsemiring.{u2} R _inst_1) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u2} R _inst_1)) (f c) s)) -> (Membership.mem.{u2, u2} R (Subsemiring.{u2} R _inst_1) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u2} R _inst_1)) (Finset.sum.{u2, u1} R ι (NonUnitalNonAssocSemiring.toAddCommMonoid.{u2} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} R _inst_1)) t (fun (i : ι) => f i)) s)
Case conversion may be inaccurate. Consider using '#align subsemiring.sum_mem Subsemiring.sum_memₓ'. -/
/-- Sum of elements in an `subsemiring` of an `semiring` indexed by a `finset`
is in the `add_subsemiring`. -/
protected theorem sum_mem (s : Subsemiring R) {ι : Type _} {t : Finset ι} {f : ι → R}
    (h : ∀ c ∈ t, f c ∈ s) : (∑ i in t, f i) ∈ s :=
  sum_mem h
#align subsemiring.sum_mem Subsemiring.sum_mem

/- warning: subsemiring.to_non_assoc_semiring -> Subsemiring.toNonAssocSemiring is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), NonAssocSemiring.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), NonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s))
Case conversion may be inaccurate. Consider using '#align subsemiring.to_non_assoc_semiring Subsemiring.toNonAssocSemiringₓ'. -/
/-- A subsemiring of a `non_assoc_semiring` inherits a `non_assoc_semiring` structure -/
instance toNonAssocSemiring : NonAssocSemiring s :=
  { s.toSubmonoid.toMulOneClass,
    s.toAddSubmonoid.toAddCommMonoid with
    mul_zero := fun x => Subtype.eq <| mul_zero x
    zero_mul := fun x => Subtype.eq <| zero_mul x
    right_distrib := fun x y z => Subtype.eq <| right_distrib x y z
    left_distrib := fun x y z => Subtype.eq <| left_distrib x y z
    natCast := fun n => ⟨n, coe_nat_mem s n⟩
    natCast_zero := by simp [Nat.cast] <;> rfl
    natCast_succ := fun _ => by simp [Nat.cast] <;> rfl }
#align subsemiring.to_non_assoc_semiring Subsemiring.toNonAssocSemiring

#print Subsemiring.coe_one /-
@[simp, norm_cast]
theorem coe_one : ((1 : s) : R) = (1 : R) :=
  rfl
#align subsemiring.coe_one Subsemiring.coe_one
-/

/- warning: subsemiring.coe_zero -> Subsemiring.coe_zero is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), Eq.{succ u1} R ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeSubtype.{succ u1} R (fun (x : R) => Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s))))) (OfNat.ofNat.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) 0 (OfNat.mk.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) 0 (Zero.zero.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (ZeroMemClass.zero.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1) (AddZeroClass.toHasZero.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (AddSubmonoidClass.to_zeroMemClass.{u1, u1} (Subsemiring.{u1} R _inst_1) R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))) (Subsemiring.setLike.{u1} R _inst_1) (SubsemiringClass.to_addSubmonoidClass.{u1, u1} (Subsemiring.{u1} R _inst_1) R _inst_1 (Subsemiring.setLike.{u1} R _inst_1) (Subsemiring.subsemiringClass.{u1} R _inst_1))) s))))) (OfNat.ofNat.{u1} R 0 (OfNat.mk.{u1} R 0 (Zero.zero.{u1} R (MulZeroClass.toHasZero.{u1} R (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))))))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), Eq.{succ u1} R (Subtype.val.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) s)) (OfNat.ofNat.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) 0 (Zero.toOfNat0.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (ZeroMemClass.zero.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) (MulZeroOneClass.toZero.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (AddSubmonoidClass.toZeroMemClass.{u1, u1} (Subsemiring.{u1} R _inst_1) R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))) (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) (SubsemiringClass.toAddSubmonoidClass.{u1, u1} (Subsemiring.{u1} R _inst_1) R _inst_1 (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) (Subsemiring.instSubsemiringClassSubsemiringInstSetLikeSubsemiring.{u1} R _inst_1))) s)))) (OfNat.ofNat.{u1} R 0 (Zero.toOfNat0.{u1} R (MulZeroOneClass.toZero.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))))
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_zero Subsemiring.coe_zeroₓ'. -/
@[simp, norm_cast]
theorem coe_zero : ((0 : s) : R) = (0 : R) :=
  rfl
#align subsemiring.coe_zero Subsemiring.coe_zero

/- warning: subsemiring.coe_add -> Subsemiring.coe_add is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) (x : coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (y : coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s), Eq.{succ u1} R ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeSubtype.{succ u1} R (fun (x : R) => Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s))))) (HAdd.hAdd.{u1, u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (instHAdd.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (AddMemClass.add.{u1, u1} R (Subsemiring.{u1} R _inst_1) (AddZeroClass.toHasAdd.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Subsemiring.setLike.{u1} R _inst_1) (AddSubmonoidClass.to_addMemClass.{u1, u1} (Subsemiring.{u1} R _inst_1) R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))) (Subsemiring.setLike.{u1} R _inst_1) (SubsemiringClass.to_addSubmonoidClass.{u1, u1} (Subsemiring.{u1} R _inst_1) R _inst_1 (Subsemiring.setLike.{u1} R _inst_1) (Subsemiring.subsemiringClass.{u1} R _inst_1))) s)) x y)) (HAdd.hAdd.{u1, u1, u1} R R R (instHAdd.{u1} R (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeSubtype.{succ u1} R (fun (x : R) => Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s))))) x) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeSubtype.{succ u1} R (fun (x : R) => Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s))))) y))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) (x : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (y : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)), Eq.{succ u1} R (Subtype.val.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) s)) (HAdd.hAdd.{u1, u1, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (instHAdd.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Distrib.toAdd.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonUnitalNonAssocSemiring.toDistrib.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s))))) x y)) (HAdd.hAdd.{u1, u1, u1} R R R (instHAdd.{u1} R (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) (Subtype.val.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) s)) x) (Subtype.val.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) s)) y))
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_add Subsemiring.coe_addₓ'. -/
@[simp, norm_cast]
theorem coe_add (x y : s) : ((x + y : s) : R) = (x + y : R) :=
  rfl
#align subsemiring.coe_add Subsemiring.coe_add

/- warning: subsemiring.coe_mul -> Subsemiring.coe_mul is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) (x : coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (y : coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s), Eq.{succ u1} R ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeSubtype.{succ u1} R (fun (x : R) => Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s))))) (HMul.hMul.{u1, u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (instHMul.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (MulMemClass.mul.{u1, u1} R (Subsemiring.{u1} R _inst_1) (MulOneClass.toHasMul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Subsemiring.setLike.{u1} R _inst_1) (SubmonoidClass.to_mulMemClass.{u1, u1} (Subsemiring.{u1} R _inst_1) R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (Subsemiring.setLike.{u1} R _inst_1) (SubsemiringClass.to_submonoidClass.{u1, u1} (Subsemiring.{u1} R _inst_1) R _inst_1 (Subsemiring.setLike.{u1} R _inst_1) (Subsemiring.subsemiringClass.{u1} R _inst_1))) s)) x y)) (HMul.hMul.{u1, u1, u1} R R R (instHMul.{u1} R (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeSubtype.{succ u1} R (fun (x : R) => Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s))))) x) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeSubtype.{succ u1} R (fun (x : R) => Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s))))) y))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) (x : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (y : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)), Eq.{succ u1} R (Subtype.val.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) s)) (HMul.hMul.{u1, u1, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (instHMul.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Submonoid.mul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (Subsemiring.toSubmonoid.{u1} R _inst_1 s))) x y)) (HMul.hMul.{u1, u1, u1} R R R (instHMul.{u1} R (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Subtype.val.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) s)) x) (Subtype.val.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) s)) y))
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_mul Subsemiring.coe_mulₓ'. -/
@[simp, norm_cast]
theorem coe_mul (x y : s) : ((x * y : s) : R) = (x * y : R) :=
  rfl
#align subsemiring.coe_mul Subsemiring.coe_mul

/- warning: subsemiring.nontrivial -> Subsemiring.nontrivial is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) [_inst_4 : Nontrivial.{u1} R], Nontrivial.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) [_inst_4 : Nontrivial.{u1} R], Nontrivial.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s))
Case conversion may be inaccurate. Consider using '#align subsemiring.nontrivial Subsemiring.nontrivialₓ'. -/
instance nontrivial [Nontrivial R] : Nontrivial s :=
  nontrivial_of_ne 0 1 fun H => zero_ne_one (congr_arg Subtype.val H)
#align subsemiring.nontrivial Subsemiring.nontrivial

/- warning: subsemiring.pow_mem -> Subsemiring.pow_mem is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) {x : R}, (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) x s) -> (forall (n : Nat), Membership.Mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) (HPow.hPow.{u1, 0, u1} R Nat R (instHPow.{u1, 0} R Nat (Monoid.Pow.{u1} R (MonoidWithZero.toMonoid.{u1} R (Semiring.toMonoidWithZero.{u1} R _inst_4)))) x n) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) {x : R}, (Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) x s) -> (forall (n : Nat), Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) (HPow.hPow.{u1, 0, u1} R Nat R (instHPow.{u1, 0} R Nat (Monoid.Pow.{u1} R (MonoidWithZero.toMonoid.{u1} R (Semiring.toMonoidWithZero.{u1} R _inst_4)))) x n) s)
Case conversion may be inaccurate. Consider using '#align subsemiring.pow_mem Subsemiring.pow_memₓ'. -/
protected theorem pow_mem {R : Type _} [Semiring R] (s : Subsemiring R) {x : R} (hx : x ∈ s)
    (n : ℕ) : x ^ n ∈ s :=
  pow_mem hx n
#align subsemiring.pow_mem Subsemiring.pow_mem

/- warning: subsemiring.no_zero_divisors -> Subsemiring.noZeroDivisors is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) [_inst_4 : NoZeroDivisors.{u1} R (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (MulZeroClass.toHasZero.{u1} R (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))], NoZeroDivisors.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (MulMemClass.mul.{u1, u1} R (Subsemiring.{u1} R _inst_1) (MulOneClass.toHasMul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Subsemiring.setLike.{u1} R _inst_1) (SubmonoidClass.to_mulMemClass.{u1, u1} (Subsemiring.{u1} R _inst_1) R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (Subsemiring.setLike.{u1} R _inst_1) (SubsemiringClass.to_submonoidClass.{u1, u1} (Subsemiring.{u1} R _inst_1) R _inst_1 (Subsemiring.setLike.{u1} R _inst_1) (Subsemiring.subsemiringClass.{u1} R _inst_1))) s) (ZeroMemClass.zero.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1) (AddZeroClass.toHasZero.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (AddSubmonoidClass.to_zeroMemClass.{u1, u1} (Subsemiring.{u1} R _inst_1) R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))) (Subsemiring.setLike.{u1} R _inst_1) (SubsemiringClass.to_addSubmonoidClass.{u1, u1} (Subsemiring.{u1} R _inst_1) R _inst_1 (Subsemiring.setLike.{u1} R _inst_1) (Subsemiring.subsemiringClass.{u1} R _inst_1))) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) [_inst_4 : NoZeroDivisors.{u1} R (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (MulZeroOneClass.toZero.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))], NoZeroDivisors.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Submonoid.mul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (Subsemiring.toSubmonoid.{u1} R _inst_1 s)) (ZeroMemClass.zero.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) (MulZeroOneClass.toZero.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (AddSubmonoidClass.toZeroMemClass.{u1, u1} (Subsemiring.{u1} R _inst_1) R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))) (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) (SubsemiringClass.toAddSubmonoidClass.{u1, u1} (Subsemiring.{u1} R _inst_1) R _inst_1 (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) (Subsemiring.instSubsemiringClassSubsemiringInstSetLikeSubsemiring.{u1} R _inst_1))) s)
Case conversion may be inaccurate. Consider using '#align subsemiring.no_zero_divisors Subsemiring.noZeroDivisorsₓ'. -/
instance noZeroDivisors [NoZeroDivisors R] : NoZeroDivisors s
    where eq_zero_or_eq_zero_of_mul_eq_zero x y h :=
    Or.cases_on (eq_zero_or_eq_zero_of_mul_eq_zero <| Subtype.ext_iff.mp h)
      (fun h => Or.inl <| Subtype.eq h) fun h => Or.inr <| Subtype.eq h
#align subsemiring.no_zero_divisors Subsemiring.noZeroDivisors

/- warning: subsemiring.to_semiring -> Subsemiring.toSemiring is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)), Semiring.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)), Semiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) x s))
Case conversion may be inaccurate. Consider using '#align subsemiring.to_semiring Subsemiring.toSemiringₓ'. -/
/-- A subsemiring of a `semiring` is a `semiring`. -/
instance toSemiring {R} [Semiring R] (s : Subsemiring R) : Semiring s :=
  { s.toNonAssocSemiring, s.toSubmonoid.toMonoid with }
#align subsemiring.to_semiring Subsemiring.toSemiring

/- warning: subsemiring.coe_pow -> Subsemiring.coe_pow is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (x : coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) s) (n : Nat), Eq.{succ u1} R ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) s) R (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) s) R (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) s) R (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) s) R (coeSubtype.{succ u1} R (fun (x : R) => Membership.Mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) x s))))) (HPow.hPow.{u1, 0, u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) s) Nat (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) s) (instHPow.{u1, 0} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) s) Nat (SubmonoidClass.nPow.{u1, u1} R (MonoidWithZero.toMonoid.{u1} R (Semiring.toMonoidWithZero.{u1} R _inst_4)) (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SubsemiringClass.to_submonoidClass.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Semiring.toNonAssocSemiring.{u1} R _inst_4) (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (Subsemiring.subsemiringClass.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) s)) x n)) (HPow.hPow.{u1, 0, u1} R Nat R (instHPow.{u1, 0} R Nat (Monoid.Pow.{u1} R (MonoidWithZero.toMonoid.{u1} R (Semiring.toMonoidWithZero.{u1} R _inst_4)))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) s) R (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) s) R (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) s) R (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) s) R (coeSubtype.{succ u1} R (fun (x : R) => Membership.Mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) x s))))) x) n)
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (x : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) x s)) (n : Nat), Eq.{succ u1} R (Subtype.val.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x (SetLike.coe.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) s)) (HPow.hPow.{u1, 0, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) x s)) Nat (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) x s)) (instHPow.{u1, 0} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) x s)) Nat (SubmonoidClass.nPow.{u1, u1} R (MonoidWithZero.toMonoid.{u1} R (Semiring.toMonoidWithZero.{u1} R _inst_4)) (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SubsemiringClass.toSubmonoidClass.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Semiring.toNonAssocSemiring.{u1} R _inst_4) (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (Subsemiring.instSubsemiringClassSubsemiringInstSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) s)) x n)) (HPow.hPow.{u1, 0, u1} R Nat R (instHPow.{u1, 0} R Nat (Monoid.Pow.{u1} R (MonoidWithZero.toMonoid.{u1} R (Semiring.toMonoidWithZero.{u1} R _inst_4)))) (Subtype.val.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x (SetLike.coe.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) s)) x) n)
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_pow Subsemiring.coe_powₓ'. -/
@[simp, norm_cast]
theorem coe_pow {R} [Semiring R] (s : Subsemiring R) (x : s) (n : ℕ) :
    ((x ^ n : s) : R) = (x ^ n : R) :=
  by
  induction' n with n ih
  · simp
  · simp [pow_succ, ih]
#align subsemiring.coe_pow Subsemiring.coe_pow

/- warning: subsemiring.to_comm_semiring -> Subsemiring.toCommSemiring is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : CommSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))), CommSemiring.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4)))) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : CommSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))), CommSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4)))) x s))
Case conversion may be inaccurate. Consider using '#align subsemiring.to_comm_semiring Subsemiring.toCommSemiringₓ'. -/
/-- A subsemiring of a `comm_semiring` is a `comm_semiring`. -/
instance toCommSemiring {R} [CommSemiring R] (s : Subsemiring R) : CommSemiring s :=
  { s.toSemiring with mul_comm := fun _ _ => Subtype.eq <| mul_comm _ _ }
#align subsemiring.to_comm_semiring Subsemiring.toCommSemiring

/- warning: subsemiring.subtype -> Subsemiring.subtype is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), RingHom.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s) _inst_1
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), RingHom.{u1, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) R (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s) _inst_1
Case conversion may be inaccurate. Consider using '#align subsemiring.subtype Subsemiring.subtypeₓ'. -/
/-- The natural ring hom from a subsemiring of semiring `R` to `R`. -/
def subtype : s →+* R :=
  { s.toSubmonoid.Subtype, s.toAddSubmonoid.Subtype with toFun := coe }
#align subsemiring.subtype Subsemiring.subtype

/- warning: subsemiring.coe_subtype -> Subsemiring.coe_subtype is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), Eq.{succ u1} ((coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) -> R) (coeFn.{succ u1, succ u1} (RingHom.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s) _inst_1) (fun (_x : RingHom.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s) _inst_1) => (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) -> R) (RingHom.hasCoeToFun.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s) _inst_1) (Subsemiring.subtype.{u1} R _inst_1 s)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeSubtype.{succ u1} R (fun (x : R) => Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s))))))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), Eq.{succ u1} (forall (ᾰ : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)), (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) => R) ᾰ) (FunLike.coe.{succ u1, succ u1, succ u1} (RingHom.{u1, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) R (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s) _inst_1) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (fun (_x : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) => R) _x) (MulHomClass.toFunLike.{u1, u1, u1} (RingHom.{u1, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) R (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s) _inst_1) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) R (NonUnitalNonAssocSemiring.toMul.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s))) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalRingHomClass.toMulHomClass.{u1, u1, u1} (RingHom.{u1, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) R (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s) _inst_1) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s)) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1) (RingHomClass.toNonUnitalRingHomClass.{u1, u1, u1} (RingHom.{u1, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) R (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s) _inst_1) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) R (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s) _inst_1 (RingHom.instRingHomClassRingHom.{u1, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) R (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s) _inst_1)))) (Subsemiring.subtype.{u1} R _inst_1 s)) (Subtype.val.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) s)))
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_subtype Subsemiring.coe_subtypeₓ'. -/
@[simp]
theorem coe_subtype : ⇑s.Subtype = coe :=
  rfl
#align subsemiring.coe_subtype Subsemiring.coe_subtype

/- warning: subsemiring.to_ordered_semiring -> Subsemiring.toOrderedSemiring is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : OrderedSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R _inst_4))), OrderedSemiring.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R _inst_4))) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R _inst_4))) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R _inst_4)))) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : OrderedSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R _inst_4))), OrderedSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R _inst_4))) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R _inst_4))) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R _inst_4)))) x s))
Case conversion may be inaccurate. Consider using '#align subsemiring.to_ordered_semiring Subsemiring.toOrderedSemiringₓ'. -/
/-- A subsemiring of an `ordered_semiring` is an `ordered_semiring`. -/
instance toOrderedSemiring {R} [OrderedSemiring R] (s : Subsemiring R) : OrderedSemiring s :=
  Subtype.coe_injective.OrderedSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring.to_ordered_semiring Subsemiring.toOrderedSemiring

/- warning: subsemiring.to_strict_ordered_semiring -> Subsemiring.toStrictOrderedSemiring is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : StrictOrderedSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R _inst_4))), StrictOrderedSemiring.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R _inst_4))) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R _inst_4))) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R _inst_4)))) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : StrictOrderedSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R _inst_4))), StrictOrderedSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R _inst_4))) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R _inst_4))) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R _inst_4)))) x s))
Case conversion may be inaccurate. Consider using '#align subsemiring.to_strict_ordered_semiring Subsemiring.toStrictOrderedSemiringₓ'. -/
/-- A subsemiring of a `strict_ordered_semiring` is a `strict_ordered_semiring`. -/
instance toStrictOrderedSemiring {R} [StrictOrderedSemiring R] (s : Subsemiring R) :
    StrictOrderedSemiring s :=
  Subtype.coe_injective.StrictOrderedSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring.to_strict_ordered_semiring Subsemiring.toStrictOrderedSemiring

/- warning: subsemiring.to_ordered_comm_semiring -> Subsemiring.toOrderedCommSemiring is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : OrderedCommSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R (OrderedCommSemiring.toOrderedSemiring.{u1} R _inst_4)))), OrderedCommSemiring.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R (OrderedCommSemiring.toOrderedSemiring.{u1} R _inst_4)))) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R (OrderedCommSemiring.toOrderedSemiring.{u1} R _inst_4)))) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R (OrderedCommSemiring.toOrderedSemiring.{u1} R _inst_4))))) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : OrderedCommSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R (OrderedCommSemiring.toOrderedSemiring.{u1} R _inst_4)))), OrderedCommSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R (OrderedCommSemiring.toOrderedSemiring.{u1} R _inst_4)))) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R (OrderedCommSemiring.toOrderedSemiring.{u1} R _inst_4)))) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (OrderedSemiring.toSemiring.{u1} R (OrderedCommSemiring.toOrderedSemiring.{u1} R _inst_4))))) x s))
Case conversion may be inaccurate. Consider using '#align subsemiring.to_ordered_comm_semiring Subsemiring.toOrderedCommSemiringₓ'. -/
/-- A subsemiring of an `ordered_comm_semiring` is an `ordered_comm_semiring`. -/
instance toOrderedCommSemiring {R} [OrderedCommSemiring R] (s : Subsemiring R) :
    OrderedCommSemiring s :=
  Subtype.coe_injective.OrderedCommSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring.to_ordered_comm_semiring Subsemiring.toOrderedCommSemiring

/- warning: subsemiring.to_strict_ordered_comm_semiring -> Subsemiring.toStrictOrderedCommSemiring is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : StrictOrderedCommSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (StrictOrderedCommSemiring.toStrictOrderedSemiring.{u1} R _inst_4)))), StrictOrderedCommSemiring.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (StrictOrderedCommSemiring.toStrictOrderedSemiring.{u1} R _inst_4)))) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (StrictOrderedCommSemiring.toStrictOrderedSemiring.{u1} R _inst_4)))) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (StrictOrderedCommSemiring.toStrictOrderedSemiring.{u1} R _inst_4))))) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : StrictOrderedCommSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (StrictOrderedCommSemiring.toStrictOrderedSemiring.{u1} R _inst_4)))), StrictOrderedCommSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (StrictOrderedCommSemiring.toStrictOrderedSemiring.{u1} R _inst_4)))) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (StrictOrderedCommSemiring.toStrictOrderedSemiring.{u1} R _inst_4)))) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (StrictOrderedCommSemiring.toStrictOrderedSemiring.{u1} R _inst_4))))) x s))
Case conversion may be inaccurate. Consider using '#align subsemiring.to_strict_ordered_comm_semiring Subsemiring.toStrictOrderedCommSemiringₓ'. -/
/-- A subsemiring of a `strict_ordered_comm_semiring` is a `strict_ordered_comm_semiring`. -/
instance toStrictOrderedCommSemiring {R} [StrictOrderedCommSemiring R] (s : Subsemiring R) :
    StrictOrderedCommSemiring s :=
  Subtype.coe_injective.StrictOrderedCommSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring.to_strict_ordered_comm_semiring Subsemiring.toStrictOrderedCommSemiring

/- warning: subsemiring.to_linear_ordered_semiring -> Subsemiring.toLinearOrderedSemiring is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : LinearOrderedSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R _inst_4)))), LinearOrderedSemiring.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R _inst_4)))) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R _inst_4)))) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R _inst_4))))) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : LinearOrderedSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R _inst_4)))), LinearOrderedSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R _inst_4)))) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R _inst_4)))) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R _inst_4))))) x s))
Case conversion may be inaccurate. Consider using '#align subsemiring.to_linear_ordered_semiring Subsemiring.toLinearOrderedSemiringₓ'. -/
/-- A subsemiring of a `linear_ordered_semiring` is a `linear_ordered_semiring`. -/
instance toLinearOrderedSemiring {R} [LinearOrderedSemiring R] (s : Subsemiring R) :
    LinearOrderedSemiring s :=
  Subtype.coe_injective.LinearOrderedSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) fun _ _ => rfl
#align subsemiring.to_linear_ordered_semiring Subsemiring.toLinearOrderedSemiring

/- warning: subsemiring.to_linear_ordered_comm_semiring -> Subsemiring.toLinearOrderedCommSemiring is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : LinearOrderedCommSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} R _inst_4))))), LinearOrderedCommSemiring.{u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} R _inst_4))))) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} R _inst_4))))) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} R _inst_4)))))) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : LinearOrderedCommSemiring.{u1} R] (s : Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} R _inst_4))))), LinearOrderedCommSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} R _inst_4))))) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} R _inst_4))))) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (StrictOrderedSemiring.toSemiring.{u1} R (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} R (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} R _inst_4)))))) x s))
Case conversion may be inaccurate. Consider using '#align subsemiring.to_linear_ordered_comm_semiring Subsemiring.toLinearOrderedCommSemiringₓ'. -/
/-- A subsemiring of a `linear_ordered_comm_semiring` is a `linear_ordered_comm_semiring`. -/
instance toLinearOrderedCommSemiring {R} [LinearOrderedCommSemiring R] (s : Subsemiring R) :
    LinearOrderedCommSemiring s :=
  Subtype.coe_injective.LinearOrderedCommSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) fun _ _ => rfl
#align subsemiring.to_linear_ordered_comm_semiring Subsemiring.toLinearOrderedCommSemiring

/- warning: subsemiring.nsmul_mem -> Subsemiring.nsmul_mem is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) {x : R}, (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s) -> (forall (n : Nat), Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) (SMul.smul.{0, u1} Nat R (AddMonoid.SMul.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))) n x) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1) {x : R}, (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s) -> (forall (n : Nat), Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) (HSMul.hSMul.{0, u1, u1} Nat R R (instHSMul.{0, u1} Nat R (AddMonoid.SMul.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) n x) s)
Case conversion may be inaccurate. Consider using '#align subsemiring.nsmul_mem Subsemiring.nsmul_memₓ'. -/
protected theorem nsmul_mem {x : R} (hx : x ∈ s) (n : ℕ) : n • x ∈ s :=
  nsmul_mem hx n
#align subsemiring.nsmul_mem Subsemiring.nsmul_mem

/- warning: subsemiring.mem_to_submonoid -> Subsemiring.mem_toSubmonoid is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Subsemiring.{u1} R _inst_1} {x : R}, Iff (Membership.Mem.{u1, u1} R (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (SetLike.hasMem.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.setLike.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)))) x (Subsemiring.toSubmonoid.{u1} R _inst_1 s)) (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Subsemiring.{u1} R _inst_1} {x : R}, Iff (Membership.mem.{u1, u1} R (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (SetLike.instMembership.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.instSetLikeSubmonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)))) x (Subsemiring.toSubmonoid.{u1} R _inst_1 s)) (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)
Case conversion may be inaccurate. Consider using '#align subsemiring.mem_to_submonoid Subsemiring.mem_toSubmonoidₓ'. -/
@[simp]
theorem mem_toSubmonoid {s : Subsemiring R} {x : R} : x ∈ s.toSubmonoid ↔ x ∈ s :=
  Iff.rfl
#align subsemiring.mem_to_submonoid Subsemiring.mem_toSubmonoid

/- warning: subsemiring.coe_to_submonoid -> Subsemiring.coe_toSubmonoid is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.setLike.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)))))) (Subsemiring.toSubmonoid.{u1} R _inst_1 s)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.instSetLikeSubmonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Subsemiring.toSubmonoid.{u1} R _inst_1 s)) (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) s)
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_to_submonoid Subsemiring.coe_toSubmonoidₓ'. -/
@[simp]
theorem coe_toSubmonoid (s : Subsemiring R) : (s.toSubmonoid : Set R) = s :=
  rfl
#align subsemiring.coe_to_submonoid Subsemiring.coe_toSubmonoid

/- warning: subsemiring.mem_to_add_submonoid -> Subsemiring.mem_toAddSubmonoid is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Subsemiring.{u1} R _inst_1} {x : R}, Iff (Membership.Mem.{u1, u1} R (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (SetLike.hasMem.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.setLike.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))))) x (Subsemiring.toAddSubmonoid.{u1} R _inst_1 s)) (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Subsemiring.{u1} R _inst_1} {x : R}, Iff (Membership.mem.{u1, u1} R (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (SetLike.instMembership.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.instSetLikeAddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))))) x (Subsemiring.toAddSubmonoid.{u1} R _inst_1 s)) (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)
Case conversion may be inaccurate. Consider using '#align subsemiring.mem_to_add_submonoid Subsemiring.mem_toAddSubmonoidₓ'. -/
@[simp]
theorem mem_toAddSubmonoid {s : Subsemiring R} {x : R} : x ∈ s.toAddSubmonoid ↔ x ∈ s :=
  Iff.rfl
#align subsemiring.mem_to_add_submonoid Subsemiring.mem_toAddSubmonoid

/- warning: subsemiring.coe_to_add_submonoid -> Subsemiring.coe_toAddSubmonoid is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.setLike.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))))))) (Subsemiring.toAddSubmonoid.{u1} R _inst_1 s)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) s)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (s : Subsemiring.{u1} R _inst_1), Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.instSetLikeAddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Subsemiring.toAddSubmonoid.{u1} R _inst_1 s)) (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) s)
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_to_add_submonoid Subsemiring.coe_toAddSubmonoidₓ'. -/
@[simp]
theorem coe_toAddSubmonoid (s : Subsemiring R) : (s.toAddSubmonoid : Set R) = s :=
  rfl
#align subsemiring.coe_to_add_submonoid Subsemiring.coe_toAddSubmonoid

/-- The subsemiring `R` of the semiring `R`. -/
instance : Top (Subsemiring R) :=
  ⟨{ (⊤ : Submonoid R), (⊤ : AddSubmonoid R) with }⟩

/- warning: subsemiring.mem_top -> Subsemiring.mem_top is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (x : R), Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.hasTop.{u1} R _inst_1))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (x : R), Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instTopSubsemiring.{u1} R _inst_1))
Case conversion may be inaccurate. Consider using '#align subsemiring.mem_top Subsemiring.mem_topₓ'. -/
@[simp]
theorem mem_top (x : R) : x ∈ (⊤ : Subsemiring R) :=
  Set.mem_univ x
#align subsemiring.mem_top Subsemiring.mem_top

/- warning: subsemiring.coe_top -> Subsemiring.coe_top is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R], Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.hasTop.{u1} R _inst_1))) (Set.univ.{u1} R)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R], Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instTopSubsemiring.{u1} R _inst_1))) (Set.univ.{u1} R)
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_top Subsemiring.coe_topₓ'. -/
@[simp]
theorem coe_top : ((⊤ : Subsemiring R) : Set R) = Set.univ :=
  rfl
#align subsemiring.coe_top Subsemiring.coe_top

/- warning: subsemiring.top_equiv -> Subsemiring.topEquiv is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R], RingEquiv.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.hasTop.{u1} R _inst_1))) R (MulMemClass.mul.{u1, u1} R (Subsemiring.{u1} R _inst_1) (MulOneClass.toHasMul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Subsemiring.setLike.{u1} R _inst_1) (Subsemiring.topEquiv._proof_1.{u1} R _inst_1) (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.hasTop.{u1} R _inst_1))) (AddMemClass.add.{u1, u1} R (Subsemiring.{u1} R _inst_1) (AddZeroClass.toHasAdd.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Subsemiring.setLike.{u1} R _inst_1) (Subsemiring.topEquiv._proof_2.{u1} R _inst_1) (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.hasTop.{u1} R _inst_1))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R], RingEquiv.{u1, u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instTopSubsemiring.{u1} R _inst_1)))) R (Submonoid.mul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (Subsemiring.toSubmonoid.{u1} R _inst_1 (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instTopSubsemiring.{u1} R _inst_1)))) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (Distrib.toAdd.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instTopSubsemiring.{u1} R _inst_1)))) (NonUnitalNonAssocSemiring.toDistrib.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instTopSubsemiring.{u1} R _inst_1)))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instTopSubsemiring.{u1} R _inst_1)))) (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instTopSubsemiring.{u1} R _inst_1)))))) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))
Case conversion may be inaccurate. Consider using '#align subsemiring.top_equiv Subsemiring.topEquivₓ'. -/
/-- The ring equiv between the top element of `subsemiring R` and `R`. -/
@[simps]
def topEquiv : (⊤ : Subsemiring R) ≃+* R
    where
  toFun r := r
  invFun r := ⟨r, Subsemiring.mem_top r⟩
  left_inv r := SetLike.eta r _
  right_inv r := [anonymous] r _
  map_mul' := (⊤ : Subsemiring R).coe_mul
  map_add' := (⊤ : Subsemiring R).val_add
#align subsemiring.top_equiv Subsemiring.topEquiv

#print Subsemiring.comap /-
/-- The preimage of a subsemiring along a ring homomorphism is a subsemiring. -/
def comap (f : R →+* S) (s : Subsemiring S) : Subsemiring R :=
  { s.toSubmonoid.comap (f : R →* S), s.toAddSubmonoid.comap (f : R →+ S) with carrier := f ⁻¹' s }
#align subsemiring.comap Subsemiring.comap
-/

/- warning: subsemiring.coe_comap -> Subsemiring.coe_comap is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (s : Subsemiring.{u2} S _inst_2) (f : RingHom.{u1, u2} R S _inst_1 _inst_2), Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) (Subsemiring.comap.{u1, u2} R S _inst_1 _inst_2 f s)) (Set.preimage.{u1, u2} R S (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} R S _inst_1 _inst_2) (fun (_x : RingHom.{u1, u2} R S _inst_1 _inst_2) => R -> S) (RingHom.hasCoeToFun.{u1, u2} R S _inst_1 _inst_2) f) ((fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (Subsemiring.{u2} S _inst_2) (Set.{u2} S) (HasLiftT.mk.{succ u2, succ u2} (Subsemiring.{u2} S _inst_2) (Set.{u2} S) (CoeTCₓ.coe.{succ u2, succ u2} (Subsemiring.{u2} S _inst_2) (Set.{u2} S) (SetLike.Set.hasCoeT.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)))) s))
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (s : Subsemiring.{u2} S _inst_2) (f : RingHom.{u1, u2} R S _inst_1 _inst_2), Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) (Subsemiring.comap.{u1, u2} R S _inst_1 _inst_2 f s)) (Set.preimage.{u1, u2} R S (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R (fun (_x : R) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : R) => S) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S _inst_1 _inst_2 (RingHom.instRingHomClassRingHom.{u1, u2} R S _inst_1 _inst_2)))) f) (SetLike.coe.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2) s))
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_comap Subsemiring.coe_comapₓ'. -/
@[simp]
theorem coe_comap (s : Subsemiring S) (f : R →+* S) : (s.comap f : Set R) = f ⁻¹' s :=
  rfl
#align subsemiring.coe_comap Subsemiring.coe_comap

/- warning: subsemiring.mem_comap -> Subsemiring.mem_comap is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] {s : Subsemiring.{u2} S _inst_2} {f : RingHom.{u1, u2} R S _inst_1 _inst_2} {x : R}, Iff (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x (Subsemiring.comap.{u1, u2} R S _inst_1 _inst_2 f s)) (Membership.Mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.hasMem.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} R S _inst_1 _inst_2) (fun (_x : RingHom.{u1, u2} R S _inst_1 _inst_2) => R -> S) (RingHom.hasCoeToFun.{u1, u2} R S _inst_1 _inst_2) f x) s)
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] {s : Subsemiring.{u2} S _inst_2} {f : RingHom.{u1, u2} R S _inst_1 _inst_2} {x : R}, Iff (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x (Subsemiring.comap.{u1, u2} R S _inst_1 _inst_2 f s)) (Membership.mem.{u2, u2} ((fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : R) => S) x) (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R (fun (_x : R) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : R) => S) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S _inst_1 _inst_2 (RingHom.instRingHomClassRingHom.{u1, u2} R S _inst_1 _inst_2)))) f x) s)
Case conversion may be inaccurate. Consider using '#align subsemiring.mem_comap Subsemiring.mem_comapₓ'. -/
@[simp]
theorem mem_comap {s : Subsemiring S} {f : R →+* S} {x : R} : x ∈ s.comap f ↔ f x ∈ s :=
  Iff.rfl
#align subsemiring.mem_comap Subsemiring.mem_comap

#print Subsemiring.comap_comap /-
theorem comap_comap (s : Subsemiring T) (g : S →+* T) (f : R →+* S) :
    (s.comap g).comap f = s.comap (g.comp f) :=
  rfl
#align subsemiring.comap_comap Subsemiring.comap_comap
-/

#print Subsemiring.map /-
/-- The image of a subsemiring along a ring homomorphism is a subsemiring. -/
def map (f : R →+* S) (s : Subsemiring R) : Subsemiring S :=
  { s.toSubmonoid.map (f : R →* S), s.toAddSubmonoid.map (f : R →+ S) with carrier := f '' s }
#align subsemiring.map Subsemiring.map
-/

/- warning: subsemiring.coe_map -> Subsemiring.coe_map is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (f : RingHom.{u1, u2} R S _inst_1 _inst_2) (s : Subsemiring.{u1} R _inst_1), Eq.{succ u2} (Set.{u2} S) ((fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (Subsemiring.{u2} S _inst_2) (Set.{u2} S) (HasLiftT.mk.{succ u2, succ u2} (Subsemiring.{u2} S _inst_2) (Set.{u2} S) (CoeTCₓ.coe.{succ u2, succ u2} (Subsemiring.{u2} S _inst_2) (Set.{u2} S) (SetLike.Set.hasCoeT.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)))) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) (Set.image.{u1, u2} R S (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} R S _inst_1 _inst_2) (fun (_x : RingHom.{u1, u2} R S _inst_1 _inst_2) => R -> S) (RingHom.hasCoeToFun.{u1, u2} R S _inst_1 _inst_2) f) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) s))
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (f : RingHom.{u1, u2} R S _inst_1 _inst_2) (s : Subsemiring.{u1} R _inst_1), Eq.{succ u2} (Set.{u2} S) (SetLike.coe.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) (Set.image.{u1, u2} R S (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R (fun (_x : R) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : R) => S) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S _inst_1 _inst_2 (RingHom.instRingHomClassRingHom.{u1, u2} R S _inst_1 _inst_2)))) f) (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) s))
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_map Subsemiring.coe_mapₓ'. -/
@[simp]
theorem coe_map (f : R →+* S) (s : Subsemiring R) : (s.map f : Set S) = f '' s :=
  rfl
#align subsemiring.coe_map Subsemiring.coe_map

/- warning: subsemiring.mem_map -> Subsemiring.mem_map is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] {f : RingHom.{u1, u2} R S _inst_1 _inst_2} {s : Subsemiring.{u1} R _inst_1} {y : S}, Iff (Membership.Mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.hasMem.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) y (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) (Exists.{succ u1} R (fun (x : R) => Exists.{0} (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s) (fun (H : Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s) => Eq.{succ u2} S (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} R S _inst_1 _inst_2) (fun (_x : RingHom.{u1, u2} R S _inst_1 _inst_2) => R -> S) (RingHom.hasCoeToFun.{u1, u2} R S _inst_1 _inst_2) f x) y)))
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] {f : RingHom.{u1, u2} R S _inst_1 _inst_2} {s : Subsemiring.{u1} R _inst_1} {y : S}, Iff (Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) y (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) (Exists.{succ u1} R (fun (x : R) => And (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s) (Eq.{succ u2} ((fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : R) => S) x) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R (fun (a : R) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : R) => S) a) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S _inst_1 _inst_2 (RingHom.instRingHomClassRingHom.{u1, u2} R S _inst_1 _inst_2)))) f x) y)))
Case conversion may be inaccurate. Consider using '#align subsemiring.mem_map Subsemiring.mem_mapₓ'. -/
@[simp]
theorem mem_map {f : R →+* S} {s : Subsemiring R} {y : S} : y ∈ s.map f ↔ ∃ x ∈ s, f x = y :=
  Set.mem_image_iff_bex
#align subsemiring.mem_map Subsemiring.mem_map

#print Subsemiring.map_id /-
@[simp]
theorem map_id : s.map (RingHom.id R) = s :=
  SetLike.coe_injective <| Set.image_id _
#align subsemiring.map_id Subsemiring.map_id
-/

#print Subsemiring.map_map /-
theorem map_map (g : S →+* T) (f : R →+* S) : (s.map f).map g = s.map (g.comp f) :=
  SetLike.coe_injective <| Set.image_image _ _ _
#align subsemiring.map_map Subsemiring.map_map
-/

/- warning: subsemiring.map_le_iff_le_comap -> Subsemiring.map_le_iff_le_comap is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] {f : RingHom.{u1, u2} R S _inst_1 _inst_2} {s : Subsemiring.{u1} R _inst_1} {t : Subsemiring.{u2} S _inst_2}, Iff (LE.le.{u2} (Subsemiring.{u2} S _inst_2) (Preorder.toLE.{u2} (Subsemiring.{u2} S _inst_2) (PartialOrder.toPreorder.{u2} (Subsemiring.{u2} S _inst_2) (SetLike.partialOrder.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)))) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s) t) (LE.le.{u1} (Subsemiring.{u1} R _inst_1) (Preorder.toLE.{u1} (Subsemiring.{u1} R _inst_1) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (SetLike.partialOrder.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) s (Subsemiring.comap.{u1, u2} R S _inst_1 _inst_2 f t))
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] {f : RingHom.{u1, u2} R S _inst_1 _inst_2} {s : Subsemiring.{u1} R _inst_1} {t : Subsemiring.{u2} S _inst_2}, Iff (LE.le.{u2} (Subsemiring.{u2} S _inst_2) (Preorder.toLE.{u2} (Subsemiring.{u2} S _inst_2) (PartialOrder.toPreorder.{u2} (Subsemiring.{u2} S _inst_2) (SetLike.instPartialOrder.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)))) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s) t) (LE.le.{u1} (Subsemiring.{u1} R _inst_1) (Preorder.toLE.{u1} (Subsemiring.{u1} R _inst_1) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (SetLike.instPartialOrder.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)))) s (Subsemiring.comap.{u1, u2} R S _inst_1 _inst_2 f t))
Case conversion may be inaccurate. Consider using '#align subsemiring.map_le_iff_le_comap Subsemiring.map_le_iff_le_comapₓ'. -/
theorem map_le_iff_le_comap {f : R →+* S} {s : Subsemiring R} {t : Subsemiring S} :
    s.map f ≤ t ↔ s ≤ t.comap f :=
  Set.image_subset_iff
#align subsemiring.map_le_iff_le_comap Subsemiring.map_le_iff_le_comap

/- warning: subsemiring.gc_map_comap -> Subsemiring.gc_map_comap is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (f : RingHom.{u1, u2} R S _inst_1 _inst_2), GaloisConnection.{u1, u2} (Subsemiring.{u1} R _inst_1) (Subsemiring.{u2} S _inst_2) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (SetLike.partialOrder.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1))) (PartialOrder.toPreorder.{u2} (Subsemiring.{u2} S _inst_2) (SetLike.partialOrder.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2))) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f) (Subsemiring.comap.{u1, u2} R S _inst_1 _inst_2 f)
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (f : RingHom.{u1, u2} R S _inst_1 _inst_2), GaloisConnection.{u1, u2} (Subsemiring.{u1} R _inst_1) (Subsemiring.{u2} S _inst_2) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (SetLike.instPartialOrder.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1))) (PartialOrder.toPreorder.{u2} (Subsemiring.{u2} S _inst_2) (SetLike.instPartialOrder.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2))) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f) (Subsemiring.comap.{u1, u2} R S _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align subsemiring.gc_map_comap Subsemiring.gc_map_comapₓ'. -/
theorem gc_map_comap (f : R →+* S) : GaloisConnection (map f) (comap f) := fun S T =>
  map_le_iff_le_comap
#align subsemiring.gc_map_comap Subsemiring.gc_map_comap

/- warning: subsemiring.equiv_map_of_injective -> Subsemiring.equivMapOfInjective is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (s : Subsemiring.{u1} R _inst_1) (f : RingHom.{u1, u2} R S _inst_1 _inst_2), (Function.Injective.{succ u1, succ u2} R S (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} R S _inst_1 _inst_2) (fun (_x : RingHom.{u1, u2} R S _inst_1 _inst_2) => R -> S) (RingHom.hasCoeToFun.{u1, u2} R S _inst_1 _inst_2) f)) -> (RingEquiv.{u1, u2} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (coeSort.{succ u2, succ (succ u2)} (Subsemiring.{u2} S _inst_2) Type.{u2} (SetLike.hasCoeToSort.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) (MulMemClass.mul.{u1, u1} R (Subsemiring.{u1} R _inst_1) (MulOneClass.toHasMul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Subsemiring.setLike.{u1} R _inst_1) (Subsemiring.equivMapOfInjective._proof_1.{u1} R _inst_1) s) (AddMemClass.add.{u1, u1} R (Subsemiring.{u1} R _inst_1) (AddZeroClass.toHasAdd.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Subsemiring.setLike.{u1} R _inst_1) (Subsemiring.equivMapOfInjective._proof_2.{u1} R _inst_1) s) (MulMemClass.mul.{u2, u2} S (Subsemiring.{u2} S _inst_2) (MulOneClass.toHasMul.{u2} S (MulZeroOneClass.toMulOneClass.{u2} S (NonAssocSemiring.toMulZeroOneClass.{u2} S _inst_2))) (Subsemiring.setLike.{u2} S _inst_2) (Subsemiring.equivMapOfInjective._proof_3.{u2} S _inst_2) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) (AddMemClass.add.{u2, u2} S (Subsemiring.{u2} S _inst_2) (AddZeroClass.toHasAdd.{u2} S (AddMonoid.toAddZeroClass.{u2} S (AddMonoidWithOne.toAddMonoid.{u2} S (AddCommMonoidWithOne.toAddMonoidWithOne.{u2} S (NonAssocSemiring.toAddCommMonoidWithOne.{u2} S _inst_2))))) (Subsemiring.setLike.{u2} S _inst_2) (Subsemiring.equivMapOfInjective._proof_4.{u2} S _inst_2) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)))
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (s : Subsemiring.{u1} R _inst_1) (f : RingHom.{u1, u2} R S _inst_1 _inst_2), (Function.Injective.{succ u1, succ u2} R S (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R (fun (_x : R) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : R) => S) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S _inst_1 _inst_2 (RingHom.instRingHomClassRingHom.{u1, u2} R S _inst_1 _inst_2)))) f)) -> (RingEquiv.{u1, u2} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Submonoid.mul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (Subsemiring.toSubmonoid.{u1} R _inst_1 s)) (Submonoid.mul.{u2} S (MulZeroOneClass.toMulOneClass.{u2} S (NonAssocSemiring.toMulZeroOneClass.{u2} S _inst_2)) (Subsemiring.toSubmonoid.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Distrib.toAdd.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonUnitalNonAssocSemiring.toDistrib.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s)))) (Distrib.toAdd.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonUnitalNonAssocSemiring.toDistrib.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Subsemiring.toNonAssocSemiring.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))))))
Case conversion may be inaccurate. Consider using '#align subsemiring.equiv_map_of_injective Subsemiring.equivMapOfInjectiveₓ'. -/
/-- A subsemiring is isomorphic to its image under an injective function -/
noncomputable def equivMapOfInjective (f : R →+* S) (hf : Function.Injective f) : s ≃+* s.map f :=
  {
    Equiv.Set.image f s
      hf with
    map_mul' := fun _ _ => Subtype.ext (f.map_mul _ _)
    map_add' := fun _ _ => Subtype.ext (f.map_add _ _) }
#align subsemiring.equiv_map_of_injective Subsemiring.equivMapOfInjective

/- warning: subsemiring.coe_equiv_map_of_injective_apply -> Subsemiring.coe_equivMapOfInjective_apply is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (s : Subsemiring.{u1} R _inst_1) (f : RingHom.{u1, u2} R S _inst_1 _inst_2) (hf : Function.Injective.{succ u1, succ u2} R S (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} R S _inst_1 _inst_2) (fun (_x : RingHom.{u1, u2} R S _inst_1 _inst_2) => R -> S) (RingHom.hasCoeToFun.{u1, u2} R S _inst_1 _inst_2) f)) (x : coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s), Eq.{succ u2} S ((fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (coeSort.{succ u2, succ (succ u2)} (Subsemiring.{u2} S _inst_2) Type.{u2} (SetLike.hasCoeToSort.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) S (HasLiftT.mk.{succ u2, succ u2} (coeSort.{succ u2, succ (succ u2)} (Subsemiring.{u2} S _inst_2) Type.{u2} (SetLike.hasCoeToSort.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) S (CoeTCₓ.coe.{succ u2, succ u2} (coeSort.{succ u2, succ (succ u2)} (Subsemiring.{u2} S _inst_2) Type.{u2} (SetLike.hasCoeToSort.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) S (coeBase.{succ u2, succ u2} (coeSort.{succ u2, succ (succ u2)} (Subsemiring.{u2} S _inst_2) Type.{u2} (SetLike.hasCoeToSort.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) S (coeSubtype.{succ u2} S (fun (x : S) => Membership.Mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.hasMem.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)))))) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingEquiv.{u1, u2} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (coeSort.{succ u2, succ (succ u2)} (Subsemiring.{u2} S _inst_2) Type.{u2} (SetLike.hasCoeToSort.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) (MulMemClass.mul.{u1, u1} R (Subsemiring.{u1} R _inst_1) (MulOneClass.toHasMul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Subsemiring.setLike.{u1} R _inst_1) (Subsemiring.equivMapOfInjective._proof_1.{u1} R _inst_1) s) (AddMemClass.add.{u1, u1} R (Subsemiring.{u1} R _inst_1) (AddZeroClass.toHasAdd.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Subsemiring.setLike.{u1} R _inst_1) (Subsemiring.equivMapOfInjective._proof_2.{u1} R _inst_1) s) (MulMemClass.mul.{u2, u2} S (Subsemiring.{u2} S _inst_2) (MulOneClass.toHasMul.{u2} S (MulZeroOneClass.toMulOneClass.{u2} S (NonAssocSemiring.toMulZeroOneClass.{u2} S _inst_2))) (Subsemiring.setLike.{u2} S _inst_2) (Subsemiring.equivMapOfInjective._proof_3.{u2} S _inst_2) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) (AddMemClass.add.{u2, u2} S (Subsemiring.{u2} S _inst_2) (AddZeroClass.toHasAdd.{u2} S (AddMonoid.toAddZeroClass.{u2} S (AddMonoidWithOne.toAddMonoid.{u2} S (AddCommMonoidWithOne.toAddMonoidWithOne.{u2} S (NonAssocSemiring.toAddCommMonoidWithOne.{u2} S _inst_2))))) (Subsemiring.setLike.{u2} S _inst_2) (Subsemiring.equivMapOfInjective._proof_4.{u2} S _inst_2) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (fun (_x : RingEquiv.{u1, u2} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (coeSort.{succ u2, succ (succ u2)} (Subsemiring.{u2} S _inst_2) Type.{u2} (SetLike.hasCoeToSort.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) (MulMemClass.mul.{u1, u1} R (Subsemiring.{u1} R _inst_1) (MulOneClass.toHasMul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Subsemiring.setLike.{u1} R _inst_1) (Subsemiring.equivMapOfInjective._proof_1.{u1} R _inst_1) s) (AddMemClass.add.{u1, u1} R (Subsemiring.{u1} R _inst_1) (AddZeroClass.toHasAdd.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Subsemiring.setLike.{u1} R _inst_1) (Subsemiring.equivMapOfInjective._proof_2.{u1} R _inst_1) s) (MulMemClass.mul.{u2, u2} S (Subsemiring.{u2} S _inst_2) (MulOneClass.toHasMul.{u2} S (MulZeroOneClass.toMulOneClass.{u2} S (NonAssocSemiring.toMulZeroOneClass.{u2} S _inst_2))) (Subsemiring.setLike.{u2} S _inst_2) (Subsemiring.equivMapOfInjective._proof_3.{u2} S _inst_2) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) (AddMemClass.add.{u2, u2} S (Subsemiring.{u2} S _inst_2) (AddZeroClass.toHasAdd.{u2} S (AddMonoid.toAddZeroClass.{u2} S (AddMonoidWithOne.toAddMonoid.{u2} S (AddCommMonoidWithOne.toAddMonoidWithOne.{u2} S (NonAssocSemiring.toAddCommMonoidWithOne.{u2} S _inst_2))))) (Subsemiring.setLike.{u2} S _inst_2) (Subsemiring.equivMapOfInjective._proof_4.{u2} S _inst_2) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) => (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) -> (coeSort.{succ u2, succ (succ u2)} (Subsemiring.{u2} S _inst_2) Type.{u2} (SetLike.hasCoeToSort.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (RingEquiv.hasCoeToFun.{u1, u2} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) (coeSort.{succ u2, succ (succ u2)} (Subsemiring.{u2} S _inst_2) Type.{u2} (SetLike.hasCoeToSort.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) (MulMemClass.mul.{u1, u1} R (Subsemiring.{u1} R _inst_1) (MulOneClass.toHasMul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Subsemiring.setLike.{u1} R _inst_1) (Subsemiring.equivMapOfInjective._proof_1.{u1} R _inst_1) s) (AddMemClass.add.{u1, u1} R (Subsemiring.{u1} R _inst_1) (AddZeroClass.toHasAdd.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Subsemiring.setLike.{u1} R _inst_1) (Subsemiring.equivMapOfInjective._proof_2.{u1} R _inst_1) s) (MulMemClass.mul.{u2, u2} S (Subsemiring.{u2} S _inst_2) (MulOneClass.toHasMul.{u2} S (MulZeroOneClass.toMulOneClass.{u2} S (NonAssocSemiring.toMulZeroOneClass.{u2} S _inst_2))) (Subsemiring.setLike.{u2} S _inst_2) (Subsemiring.equivMapOfInjective._proof_3.{u2} S _inst_2) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)) (AddMemClass.add.{u2, u2} S (Subsemiring.{u2} S _inst_2) (AddZeroClass.toHasAdd.{u2} S (AddMonoid.toAddZeroClass.{u2} S (AddMonoidWithOne.toAddMonoid.{u2} S (AddCommMonoidWithOne.toAddMonoidWithOne.{u2} S (NonAssocSemiring.toAddCommMonoidWithOne.{u2} S _inst_2))))) (Subsemiring.setLike.{u2} S _inst_2) (Subsemiring.equivMapOfInjective._proof_4.{u2} S _inst_2) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Subsemiring.equivMapOfInjective.{u1, u2} R S _inst_1 _inst_2 s f hf) x)) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} R S _inst_1 _inst_2) (fun (_x : RingHom.{u1, u2} R S _inst_1 _inst_2) => R -> S) (RingHom.hasCoeToFun.{u1, u2} R S _inst_1 _inst_2) f ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subsemiring.{u1} R _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) s) R (coeSubtype.{succ u1} R (fun (x : R) => Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x s))))) x))
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (s : Subsemiring.{u1} R _inst_1) (f : RingHom.{u1, u2} R S _inst_1 _inst_2) (hf : Function.Injective.{succ u1, succ u2} R S (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R (fun (_x : R) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : R) => S) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S _inst_1 _inst_2 (RingHom.instRingHomClassRingHom.{u1, u2} R S _inst_1 _inst_2)))) f)) (x : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)), Eq.{succ u2} S (Subtype.val.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Set.{u2} S) (Set.instMembershipSet.{u2} S) x (SetLike.coe.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingEquiv.{u1, u2} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Submonoid.mul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (Subsemiring.toSubmonoid.{u1} R _inst_1 s)) (Submonoid.mul.{u2} S (MulZeroOneClass.toMulOneClass.{u2} S (NonAssocSemiring.toMulZeroOneClass.{u2} S _inst_2)) (Subsemiring.toSubmonoid.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Distrib.toAdd.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonUnitalNonAssocSemiring.toDistrib.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s)))) (Distrib.toAdd.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonUnitalNonAssocSemiring.toDistrib.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Subsemiring.toNonAssocSemiring.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)))))) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (fun (_x : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) => Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u1, succ u2} (RingEquiv.{u1, u2} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Submonoid.mul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (Subsemiring.toSubmonoid.{u1} R _inst_1 s)) (Submonoid.mul.{u2} S (MulZeroOneClass.toMulOneClass.{u2} S (NonAssocSemiring.toMulZeroOneClass.{u2} S _inst_2)) (Subsemiring.toSubmonoid.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Distrib.toAdd.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonUnitalNonAssocSemiring.toDistrib.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s)))) (Distrib.toAdd.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonUnitalNonAssocSemiring.toDistrib.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Subsemiring.toNonAssocSemiring.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)))))) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u1, succ u2} (RingEquiv.{u1, u2} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Submonoid.mul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (Subsemiring.toSubmonoid.{u1} R _inst_1 s)) (Submonoid.mul.{u2} S (MulZeroOneClass.toMulOneClass.{u2} S (NonAssocSemiring.toMulZeroOneClass.{u2} S _inst_2)) (Subsemiring.toSubmonoid.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Distrib.toAdd.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonUnitalNonAssocSemiring.toDistrib.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s)))) (Distrib.toAdd.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonUnitalNonAssocSemiring.toDistrib.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Subsemiring.toNonAssocSemiring.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)))))) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (MulEquivClass.toEquivLike.{max u1 u2, u1, u2} (RingEquiv.{u1, u2} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Submonoid.mul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (Subsemiring.toSubmonoid.{u1} R _inst_1 s)) (Submonoid.mul.{u2} S (MulZeroOneClass.toMulOneClass.{u2} S (NonAssocSemiring.toMulZeroOneClass.{u2} S _inst_2)) (Subsemiring.toSubmonoid.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Distrib.toAdd.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonUnitalNonAssocSemiring.toDistrib.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s)))) (Distrib.toAdd.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonUnitalNonAssocSemiring.toDistrib.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Subsemiring.toNonAssocSemiring.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)))))) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Submonoid.mul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (Subsemiring.toSubmonoid.{u1} R _inst_1 s)) (Submonoid.mul.{u2} S (MulZeroOneClass.toMulOneClass.{u2} S (NonAssocSemiring.toMulZeroOneClass.{u2} S _inst_2)) (Subsemiring.toSubmonoid.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (RingEquivClass.toMulEquivClass.{max u1 u2, u1, u2} (RingEquiv.{u1, u2} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Submonoid.mul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (Subsemiring.toSubmonoid.{u1} R _inst_1 s)) (Submonoid.mul.{u2} S (MulZeroOneClass.toMulOneClass.{u2} S (NonAssocSemiring.toMulZeroOneClass.{u2} S _inst_2)) (Subsemiring.toSubmonoid.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Distrib.toAdd.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonUnitalNonAssocSemiring.toDistrib.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s)))) (Distrib.toAdd.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonUnitalNonAssocSemiring.toDistrib.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Subsemiring.toNonAssocSemiring.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)))))) (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Submonoid.mul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (Subsemiring.toSubmonoid.{u1} R _inst_1 s)) (Distrib.toAdd.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonUnitalNonAssocSemiring.toDistrib.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s)))) (Submonoid.mul.{u2} S (MulZeroOneClass.toMulOneClass.{u2} S (NonAssocSemiring.toMulZeroOneClass.{u2} S _inst_2)) (Subsemiring.toSubmonoid.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Distrib.toAdd.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonUnitalNonAssocSemiring.toDistrib.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Subsemiring.toNonAssocSemiring.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))))) (RingEquiv.instRingEquivClassRingEquiv.{u1, u2} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Submonoid.mul.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)) (Subsemiring.toSubmonoid.{u1} R _inst_1 s)) (Submonoid.mul.{u2} S (MulZeroOneClass.toMulOneClass.{u2} S (NonAssocSemiring.toMulZeroOneClass.{u2} S _inst_2)) (Subsemiring.toSubmonoid.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Distrib.toAdd.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonUnitalNonAssocSemiring.toDistrib.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x s)) (Subsemiring.toNonAssocSemiring.{u1} R _inst_1 s)))) (Distrib.toAdd.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonUnitalNonAssocSemiring.toDistrib.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s))) (Subsemiring.toNonAssocSemiring.{u2} S _inst_2 (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f s)))))))))) (Subsemiring.equivMapOfInjective.{u1, u2} R S _inst_1 _inst_2 s f hf) x)) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R (fun (_x : R) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : R) => S) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S _inst_1 _inst_2 (RingHom.instRingHomClassRingHom.{u1, u2} R S _inst_1 _inst_2)))) f (Subtype.val.{succ u1} R (fun (x : R) => Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) x (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) s)) x))
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_equiv_map_of_injective_apply Subsemiring.coe_equivMapOfInjective_applyₓ'. -/
@[simp]
theorem coe_equivMapOfInjective_apply (f : R →+* S) (hf : Function.Injective f) (x : s) :
    (equivMapOfInjective s f hf x : S) = f x :=
  rfl
#align subsemiring.coe_equiv_map_of_injective_apply Subsemiring.coe_equivMapOfInjective_apply

end Subsemiring

namespace RingHom

variable (g : S →+* T) (f : R →+* S)

#print RingHom.rangeS /-
/-- The range of a ring homomorphism is a subsemiring. See Note [range copy pattern]. -/
def rangeS : Subsemiring S :=
  ((⊤ : Subsemiring R).map f).copy (Set.range f) Set.image_univ.symm
#align ring_hom.srange RingHom.rangeS
-/

/- warning: ring_hom.coe_srange -> RingHom.coe_rangeS is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (f : RingHom.{u1, u2} R S _inst_1 _inst_2), Eq.{succ u2} (Set.{u2} S) ((fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (Subsemiring.{u2} S _inst_2) (Set.{u2} S) (HasLiftT.mk.{succ u2, succ u2} (Subsemiring.{u2} S _inst_2) (Set.{u2} S) (CoeTCₓ.coe.{succ u2, succ u2} (Subsemiring.{u2} S _inst_2) (Set.{u2} S) (SetLike.Set.hasCoeT.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)))) (RingHom.rangeS.{u1, u2} R S _inst_1 _inst_2 f)) (Set.range.{u2, succ u1} S R (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} R S _inst_1 _inst_2) (fun (_x : RingHom.{u1, u2} R S _inst_1 _inst_2) => R -> S) (RingHom.hasCoeToFun.{u1, u2} R S _inst_1 _inst_2) f))
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (f : RingHom.{u1, u2} R S _inst_1 _inst_2), Eq.{succ u2} (Set.{u2} S) (SetLike.coe.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2) (RingHom.rangeS.{u1, u2} R S _inst_1 _inst_2 f)) (Set.range.{u2, succ u1} S R (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R (fun (_x : R) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : R) => S) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S _inst_1 _inst_2 (RingHom.instRingHomClassRingHom.{u1, u2} R S _inst_1 _inst_2)))) f))
Case conversion may be inaccurate. Consider using '#align ring_hom.coe_srange RingHom.coe_rangeSₓ'. -/
@[simp]
theorem coe_rangeS : (f.srange : Set S) = Set.range f :=
  rfl
#align ring_hom.coe_srange RingHom.coe_rangeS

/- warning: ring_hom.mem_srange -> RingHom.mem_rangeS is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] {f : RingHom.{u1, u2} R S _inst_1 _inst_2} {y : S}, Iff (Membership.Mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.hasMem.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) y (RingHom.rangeS.{u1, u2} R S _inst_1 _inst_2 f)) (Exists.{succ u1} R (fun (x : R) => Eq.{succ u2} S (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} R S _inst_1 _inst_2) (fun (_x : RingHom.{u1, u2} R S _inst_1 _inst_2) => R -> S) (RingHom.hasCoeToFun.{u1, u2} R S _inst_1 _inst_2) f x) y))
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] {f : RingHom.{u1, u2} R S _inst_1 _inst_2} {y : S}, Iff (Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) y (RingHom.rangeS.{u1, u2} R S _inst_1 _inst_2 f)) (Exists.{succ u1} R (fun (x : R) => Eq.{succ u2} ((fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : R) => S) x) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R (fun (_x : R) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : R) => S) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S _inst_1 _inst_2 (RingHom.instRingHomClassRingHom.{u1, u2} R S _inst_1 _inst_2)))) f x) y))
Case conversion may be inaccurate. Consider using '#align ring_hom.mem_srange RingHom.mem_rangeSₓ'. -/
@[simp]
theorem mem_rangeS {f : R →+* S} {y : S} : y ∈ f.srange ↔ ∃ x, f x = y :=
  Iff.rfl
#align ring_hom.mem_srange RingHom.mem_rangeS

/- warning: ring_hom.srange_eq_map -> RingHom.rangeS_eq_map is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (f : RingHom.{u1, u2} R S _inst_1 _inst_2), Eq.{succ u2} (Subsemiring.{u2} S _inst_2) (RingHom.rangeS.{u1, u2} R S _inst_1 _inst_2 f) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.hasTop.{u1} R _inst_1)))
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (f : RingHom.{u1, u2} R S _inst_1 _inst_2), Eq.{succ u2} (Subsemiring.{u2} S _inst_2) (RingHom.rangeS.{u1, u2} R S _inst_1 _inst_2 f) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 f (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instTopSubsemiring.{u1} R _inst_1)))
Case conversion may be inaccurate. Consider using '#align ring_hom.srange_eq_map RingHom.rangeS_eq_mapₓ'. -/
theorem rangeS_eq_map (f : R →+* S) : f.srange = (⊤ : Subsemiring R).map f :=
  by
  ext
  simp
#align ring_hom.srange_eq_map RingHom.rangeS_eq_map

/- warning: ring_hom.mem_srange_self -> RingHom.mem_rangeS_self is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (f : RingHom.{u1, u2} R S _inst_1 _inst_2) (x : R), Membership.Mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.hasMem.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} R S _inst_1 _inst_2) (fun (_x : RingHom.{u1, u2} R S _inst_1 _inst_2) => R -> S) (RingHom.hasCoeToFun.{u1, u2} R S _inst_1 _inst_2) f x) (RingHom.rangeS.{u1, u2} R S _inst_1 _inst_2 f)
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (f : RingHom.{u1, u2} R S _inst_1 _inst_2) (x : R), Membership.mem.{u2, u2} ((fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : R) => S) x) (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R (fun (_x : R) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : R) => S) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} R S _inst_1 _inst_2) R S _inst_1 _inst_2 (RingHom.instRingHomClassRingHom.{u1, u2} R S _inst_1 _inst_2)))) f x) (RingHom.rangeS.{u1, u2} R S _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align ring_hom.mem_srange_self RingHom.mem_rangeS_selfₓ'. -/
theorem mem_rangeS_self (f : R →+* S) (x : R) : f x ∈ f.srange :=
  mem_rangeS.mpr ⟨x, rfl⟩
#align ring_hom.mem_srange_self RingHom.mem_rangeS_self

#print RingHom.map_rangeS /-
theorem map_rangeS : f.srange.map g = (g.comp f).srange := by
  simpa only [srange_eq_map] using (⊤ : Subsemiring R).map_map g f
#align ring_hom.map_srange RingHom.map_rangeS
-/

/- warning: ring_hom.fintype_srange -> RingHom.fintypeRangeS is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] [_inst_4 : Fintype.{u1} R] [_inst_5 : DecidableEq.{succ u2} S] (f : RingHom.{u1, u2} R S _inst_1 _inst_2), Fintype.{u2} (coeSort.{succ u2, succ (succ u2)} (Subsemiring.{u2} S _inst_2) Type.{u2} (SetLike.hasCoeToSort.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) (RingHom.rangeS.{u1, u2} R S _inst_1 _inst_2 f))
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] [_inst_4 : Fintype.{u1} R] [_inst_5 : DecidableEq.{succ u2} S] (f : RingHom.{u1, u2} R S _inst_1 _inst_2), Fintype.{u2} (Subtype.{succ u2} S (fun (x : S) => Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (RingHom.rangeS.{u1, u2} R S _inst_1 _inst_2 f)))
Case conversion may be inaccurate. Consider using '#align ring_hom.fintype_srange RingHom.fintypeRangeSₓ'. -/
/-- The range of a morphism of semirings is a fintype, if the domain is a fintype.
Note: this instance can form a diamond with `subtype.fintype` in the
  presence of `fintype S`.-/
instance fintypeRangeS [Fintype R] [DecidableEq S] (f : R →+* S) : Fintype (rangeS f) :=
  Set.fintypeRange f
#align ring_hom.fintype_srange RingHom.fintypeRangeS

end RingHom

namespace Subsemiring

instance : Bot (Subsemiring R) :=
  ⟨(Nat.castRingHom R).srange⟩

instance : Inhabited (Subsemiring R) :=
  ⟨⊥⟩

/- warning: subsemiring.coe_bot -> Subsemiring.coe_bot is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R], Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) (Bot.bot.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.hasBot.{u1} R _inst_1))) (Set.range.{u1, 1} R Nat ((fun (a : Type) (b : Type.{u1}) [self : HasLiftT.{1, succ u1} a b] => self.0) Nat R (HasLiftT.mk.{1, succ u1} Nat R (CoeTCₓ.coe.{1, succ u1} Nat R (Nat.castCoe.{u1} R (AddMonoidWithOne.toNatCast.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))))))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R], Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) (Bot.bot.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instBotSubsemiring.{u1} R _inst_1))) (Set.range.{u1, 1} R Nat (Nat.cast.{u1} R (NonAssocSemiring.toNatCast.{u1} R _inst_1)))
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_bot Subsemiring.coe_botₓ'. -/
theorem coe_bot : ((⊥ : Subsemiring R) : Set R) = Set.range (coe : ℕ → R) :=
  (Nat.castRingHom R).coe_srange
#align subsemiring.coe_bot Subsemiring.coe_bot

/- warning: subsemiring.mem_bot -> Subsemiring.mem_bot is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {x : R}, Iff (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x (Bot.bot.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.hasBot.{u1} R _inst_1))) (Exists.{1} Nat (fun (n : Nat) => Eq.{succ u1} R ((fun (a : Type) (b : Type.{u1}) [self : HasLiftT.{1, succ u1} a b] => self.0) Nat R (HasLiftT.mk.{1, succ u1} Nat R (CoeTCₓ.coe.{1, succ u1} Nat R (Nat.castCoe.{u1} R (AddMonoidWithOne.toNatCast.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))))) n) x))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {x : R}, Iff (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x (Bot.bot.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instBotSubsemiring.{u1} R _inst_1))) (Exists.{1} Nat (fun (n : Nat) => Eq.{succ u1} R (Nat.cast.{u1} R (NonAssocSemiring.toNatCast.{u1} R _inst_1) n) x))
Case conversion may be inaccurate. Consider using '#align subsemiring.mem_bot Subsemiring.mem_botₓ'. -/
theorem mem_bot {x : R} : x ∈ (⊥ : Subsemiring R) ↔ ∃ n : ℕ, ↑n = x :=
  RingHom.mem_rangeS
#align subsemiring.mem_bot Subsemiring.mem_bot

/-- The inf of two subsemirings is their intersection. -/
instance : HasInf (Subsemiring R) :=
  ⟨fun s t =>
    { s.toSubmonoid ⊓ t.toSubmonoid, s.toAddSubmonoid ⊓ t.toAddSubmonoid with carrier := s ∩ t }⟩

/- warning: subsemiring.coe_inf -> Subsemiring.coe_inf is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (p : Subsemiring.{u1} R _inst_1) (p' : Subsemiring.{u1} R _inst_1), Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) (HasInf.inf.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.hasInf.{u1} R _inst_1) p p')) (Inter.inter.{u1} (Set.{u1} R) (Set.hasInter.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) p) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) p'))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (p : Subsemiring.{u1} R _inst_1) (p' : Subsemiring.{u1} R _inst_1), Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) (HasInf.inf.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instHasInfSubsemiring.{u1} R _inst_1) p p')) (Inter.inter.{u1} (Set.{u1} R) (Set.instInterSet.{u1} R) (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) p) (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) p'))
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_inf Subsemiring.coe_infₓ'. -/
@[simp]
theorem coe_inf (p p' : Subsemiring R) : ((p ⊓ p' : Subsemiring R) : Set R) = p ∩ p' :=
  rfl
#align subsemiring.coe_inf Subsemiring.coe_inf

/- warning: subsemiring.mem_inf -> Subsemiring.mem_inf is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {p : Subsemiring.{u1} R _inst_1} {p' : Subsemiring.{u1} R _inst_1} {x : R}, Iff (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x (HasInf.inf.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.hasInf.{u1} R _inst_1) p p')) (And (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x p) (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x p'))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {p : Subsemiring.{u1} R _inst_1} {p' : Subsemiring.{u1} R _inst_1} {x : R}, Iff (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x (HasInf.inf.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instHasInfSubsemiring.{u1} R _inst_1) p p')) (And (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x p) (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x p'))
Case conversion may be inaccurate. Consider using '#align subsemiring.mem_inf Subsemiring.mem_infₓ'. -/
@[simp]
theorem mem_inf {p p' : Subsemiring R} {x : R} : x ∈ p ⊓ p' ↔ x ∈ p ∧ x ∈ p' :=
  Iff.rfl
#align subsemiring.mem_inf Subsemiring.mem_inf

instance : InfSet (Subsemiring R) :=
  ⟨fun s =>
    Subsemiring.mk' (⋂ t ∈ s, ↑t) (⨅ t ∈ s, Subsemiring.toSubmonoid t) (by simp)
      (⨅ t ∈ s, Subsemiring.toAddSubmonoid t) (by simp)⟩

/- warning: subsemiring.coe_Inf -> Subsemiring.coe_infₛ is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (S : Set.{u1} (Subsemiring.{u1} R _inst_1)), Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) (InfSet.infₛ.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.hasInf.{u1} R _inst_1) S)) (Set.interᵢ.{u1, succ u1} R (Subsemiring.{u1} R _inst_1) (fun (s : Subsemiring.{u1} R _inst_1) => Set.interᵢ.{u1, 0} R (Membership.Mem.{u1, u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} (Subsemiring.{u1} R _inst_1)) (Set.hasMem.{u1} (Subsemiring.{u1} R _inst_1)) s S) (fun (H : Membership.Mem.{u1, u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} (Subsemiring.{u1} R _inst_1)) (Set.hasMem.{u1} (Subsemiring.{u1} R _inst_1)) s S) => (fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) s)))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (S : Set.{u1} (Subsemiring.{u1} R _inst_1)), Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) (InfSet.infₛ.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instInfSetSubsemiring.{u1} R _inst_1) S)) (Set.interᵢ.{u1, succ u1} R (Subsemiring.{u1} R _inst_1) (fun (s : Subsemiring.{u1} R _inst_1) => Set.interᵢ.{u1, 0} R (Membership.mem.{u1, u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} (Subsemiring.{u1} R _inst_1)) (Set.instMembershipSet.{u1} (Subsemiring.{u1} R _inst_1)) s S) (fun (H : Membership.mem.{u1, u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} (Subsemiring.{u1} R _inst_1)) (Set.instMembershipSet.{u1} (Subsemiring.{u1} R _inst_1)) s S) => SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) s)))
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_Inf Subsemiring.coe_infₛₓ'. -/
@[simp, norm_cast]
theorem coe_infₛ (S : Set (Subsemiring R)) : ((infₛ S : Subsemiring R) : Set R) = ⋂ s ∈ S, ↑s :=
  rfl
#align subsemiring.coe_Inf Subsemiring.coe_infₛ

/- warning: subsemiring.mem_Inf -> Subsemiring.mem_infₛ is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {S : Set.{u1} (Subsemiring.{u1} R _inst_1)} {x : R}, Iff (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x (InfSet.infₛ.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.hasInf.{u1} R _inst_1) S)) (forall (p : Subsemiring.{u1} R _inst_1), (Membership.Mem.{u1, u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} (Subsemiring.{u1} R _inst_1)) (Set.hasMem.{u1} (Subsemiring.{u1} R _inst_1)) p S) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x p))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {S : Set.{u1} (Subsemiring.{u1} R _inst_1)} {x : R}, Iff (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x (InfSet.infₛ.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instInfSetSubsemiring.{u1} R _inst_1) S)) (forall (p : Subsemiring.{u1} R _inst_1), (Membership.mem.{u1, u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} (Subsemiring.{u1} R _inst_1)) (Set.instMembershipSet.{u1} (Subsemiring.{u1} R _inst_1)) p S) -> (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x p))
Case conversion may be inaccurate. Consider using '#align subsemiring.mem_Inf Subsemiring.mem_infₛₓ'. -/
theorem mem_infₛ {S : Set (Subsemiring R)} {x : R} : x ∈ infₛ S ↔ ∀ p ∈ S, x ∈ p :=
  Set.mem_interᵢ₂
#align subsemiring.mem_Inf Subsemiring.mem_infₛ

#print Subsemiring.infₛ_toSubmonoid /-
@[simp]
theorem infₛ_toSubmonoid (s : Set (Subsemiring R)) :
    (infₛ s).toSubmonoid = ⨅ t ∈ s, Subsemiring.toSubmonoid t :=
  mk'_toSubmonoid _ _
#align subsemiring.Inf_to_submonoid Subsemiring.infₛ_toSubmonoid
-/

#print Subsemiring.infₛ_toAddSubmonoid /-
@[simp]
theorem infₛ_toAddSubmonoid (s : Set (Subsemiring R)) :
    (infₛ s).toAddSubmonoid = ⨅ t ∈ s, Subsemiring.toAddSubmonoid t :=
  mk'_toAddSubmonoid _ _
#align subsemiring.Inf_to_add_submonoid Subsemiring.infₛ_toAddSubmonoid
-/

/-- Subsemirings of a semiring form a complete lattice. -/
instance : CompleteLattice (Subsemiring R) :=
  {
    completeLatticeOfInf (Subsemiring R) fun s =>
      IsGLB.of_image (fun s t => show (s : Set R) ≤ t ↔ s ≤ t from SetLike.coe_subset_coe)
        isGLB_binfᵢ with
    bot := ⊥
    bot_le := fun s x hx =>
      let ⟨n, hn⟩ := mem_bot.1 hx
      hn ▸ coe_nat_mem s n
    top := ⊤
    le_top := fun s x hx => trivial
    inf := (· ⊓ ·)
    inf_le_left := fun s t x => And.left
    inf_le_right := fun s t x => And.right
    le_inf := fun s t₁ t₂ h₁ h₂ x hx => ⟨h₁ hx, h₂ hx⟩ }

/- warning: subsemiring.eq_top_iff' -> Subsemiring.eq_top_iff' is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (A : Subsemiring.{u1} R _inst_1), Iff (Eq.{succ u1} (Subsemiring.{u1} R _inst_1) A (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.hasTop.{u1} R _inst_1))) (forall (x : R), Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x A)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (A : Subsemiring.{u1} R _inst_1), Iff (Eq.{succ u1} (Subsemiring.{u1} R _inst_1) A (Top.top.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instTopSubsemiring.{u1} R _inst_1))) (forall (x : R), Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x A)
Case conversion may be inaccurate. Consider using '#align subsemiring.eq_top_iff' Subsemiring.eq_top_iff'ₓ'. -/
theorem eq_top_iff' (A : Subsemiring R) : A = ⊤ ↔ ∀ x : R, x ∈ A :=
  eq_top_iff.trans ⟨fun h m => h <| mem_top m, fun h m _ => h m⟩
#align subsemiring.eq_top_iff' Subsemiring.eq_top_iff'

section Center

#print Subsemiring.center /-
/-- The center of a semiring `R` is the set of elements that commute with everything in `R` -/
def center (R) [Semiring R] : Subsemiring R :=
  { Submonoid.center R with
    carrier := Set.center R
    zero_mem' := Set.zero_mem_center R
    add_mem' := fun a b => Set.add_mem_center }
#align subsemiring.center Subsemiring.center
-/

/- warning: subsemiring.coe_center -> Subsemiring.coe_center is a dubious translation:
lean 3 declaration is
  forall (R : Type.{u1}) [_inst_4 : Semiring.{u1} R], Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))))) (Subsemiring.center.{u1} R _inst_4)) (Set.center.{u1} R (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)))))
but is expected to have type
  forall (R : Type.{u1}) [_inst_4 : Semiring.{u1} R], Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (Subsemiring.center.{u1} R _inst_4)) (Set.center.{u1} R (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))))
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_center Subsemiring.coe_centerₓ'. -/
theorem coe_center (R) [Semiring R] : ↑(center R) = Set.center R :=
  rfl
#align subsemiring.coe_center Subsemiring.coe_center

#print Subsemiring.center_toSubmonoid /-
@[simp]
theorem center_toSubmonoid (R) [Semiring R] : (center R).toSubmonoid = Submonoid.center R :=
  rfl
#align subsemiring.center_to_submonoid Subsemiring.center_toSubmonoid
-/

/- warning: subsemiring.mem_center_iff -> Subsemiring.mem_center_iff is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] {z : R}, Iff (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) z (Subsemiring.center.{u1} R _inst_4)) (forall (g : R), Eq.{succ u1} R (HMul.hMul.{u1, u1, u1} R R R (instHMul.{u1} R (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))))) g z) (HMul.hMul.{u1, u1, u1} R R R (instHMul.{u1} R (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))))) z g))
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] {z : R}, Iff (Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) z (Subsemiring.center.{u1} R _inst_4)) (forall (g : R), Eq.{succ u1} R (HMul.hMul.{u1, u1, u1} R R R (instHMul.{u1} R (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)))) g z) (HMul.hMul.{u1, u1, u1} R R R (instHMul.{u1} R (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)))) z g))
Case conversion may be inaccurate. Consider using '#align subsemiring.mem_center_iff Subsemiring.mem_center_iffₓ'. -/
theorem mem_center_iff {R} [Semiring R] {z : R} : z ∈ center R ↔ ∀ g, g * z = z * g :=
  Iff.rfl
#align subsemiring.mem_center_iff Subsemiring.mem_center_iff

/- warning: subsemiring.decidable_mem_center -> Subsemiring.decidableMemCenter is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] [_inst_5 : DecidableEq.{succ u1} R] [_inst_6 : Fintype.{u1} R], DecidablePred.{succ u1} R (fun (_x : R) => Membership.Mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) _x (Subsemiring.center.{u1} R _inst_4))
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] [_inst_5 : DecidableEq.{succ u1} R] [_inst_6 : Fintype.{u1} R], DecidablePred.{succ u1} R (fun (_x : R) => Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) _x (Subsemiring.center.{u1} R _inst_4))
Case conversion may be inaccurate. Consider using '#align subsemiring.decidable_mem_center Subsemiring.decidableMemCenterₓ'. -/
instance decidableMemCenter {R} [Semiring R] [DecidableEq R] [Fintype R] :
    DecidablePred (· ∈ center R) := fun _ => decidable_of_iff' _ mem_center_iff
#align subsemiring.decidable_mem_center Subsemiring.decidableMemCenter

/- warning: subsemiring.center_eq_top -> Subsemiring.center_eq_top is a dubious translation:
lean 3 declaration is
  forall (R : Type.{u1}) [_inst_4 : CommSemiring.{u1} R], Eq.{succ u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) (Subsemiring.center.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4)) (Top.top.{u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) (Subsemiring.hasTop.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))))
but is expected to have type
  forall (R : Type.{u1}) [_inst_4 : CommSemiring.{u1} R], Eq.{succ u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) (Subsemiring.center.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4)) (Top.top.{u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))) (Subsemiring.instTopSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R (CommSemiring.toSemiring.{u1} R _inst_4))))
Case conversion may be inaccurate. Consider using '#align subsemiring.center_eq_top Subsemiring.center_eq_topₓ'. -/
@[simp]
theorem center_eq_top (R) [CommSemiring R] : center R = ⊤ :=
  SetLike.coe_injective (Set.center_eq_univ R)
#align subsemiring.center_eq_top Subsemiring.center_eq_top

/-- The center is commutative. -/
instance {R} [Semiring R] : CommSemiring (center R) :=
  { Submonoid.center.commMonoid, (center R).toSemiring with }

end Center

section Centralizer

#print Subsemiring.centralizer /-
/-- The centralizer of a set as subsemiring. -/
def centralizer {R} [Semiring R] (s : Set R) : Subsemiring R :=
  { Submonoid.centralizer s with
    carrier := s.centralizer
    zero_mem' := Set.zero_mem_centralizer _
    add_mem' := fun x y hx hy => Set.add_mem_centralizer hx hy }
#align subsemiring.centralizer Subsemiring.centralizer
-/

/- warning: subsemiring.coe_centralizer -> Subsemiring.coe_centralizer is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] (s : Set.{u1} R), Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))))) (Subsemiring.centralizer.{u1} R _inst_4 s)) (Set.centralizer.{u1} R s (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)))))
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] (s : Set.{u1} R), Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (Subsemiring.centralizer.{u1} R _inst_4 s)) (Set.centralizer.{u1} R s (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))))
Case conversion may be inaccurate. Consider using '#align subsemiring.coe_centralizer Subsemiring.coe_centralizerₓ'. -/
@[simp, norm_cast]
theorem coe_centralizer {R} [Semiring R] (s : Set R) : (centralizer s : Set R) = s.centralizer :=
  rfl
#align subsemiring.coe_centralizer Subsemiring.coe_centralizer

#print Subsemiring.centralizer_toSubmonoid /-
theorem centralizer_toSubmonoid {R} [Semiring R] (s : Set R) :
    (centralizer s).toSubmonoid = Submonoid.centralizer s :=
  rfl
#align subsemiring.centralizer_to_submonoid Subsemiring.centralizer_toSubmonoid
-/

/- warning: subsemiring.mem_centralizer_iff -> Subsemiring.mem_centralizer_iff is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] {s : Set.{u1} R} {z : R}, Iff (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) z (Subsemiring.centralizer.{u1} R _inst_4 s)) (forall (g : R), (Membership.Mem.{u1, u1} R (Set.{u1} R) (Set.hasMem.{u1} R) g s) -> (Eq.{succ u1} R (HMul.hMul.{u1, u1, u1} R R R (instHMul.{u1} R (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))))) g z) (HMul.hMul.{u1, u1, u1} R R R (instHMul.{u1} R (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))))) z g)))
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] {s : Set.{u1} R} {z : R}, Iff (Membership.mem.{u1, u1} R (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.instSetLikeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))) z (Subsemiring.centralizer.{u1} R _inst_4 s)) (forall (g : R), (Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) g s) -> (Eq.{succ u1} R (HMul.hMul.{u1, u1, u1} R R R (instHMul.{u1} R (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)))) g z) (HMul.hMul.{u1, u1, u1} R R R (instHMul.{u1} R (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)))) z g)))
Case conversion may be inaccurate. Consider using '#align subsemiring.mem_centralizer_iff Subsemiring.mem_centralizer_iffₓ'. -/
theorem mem_centralizer_iff {R} [Semiring R] {s : Set R} {z : R} :
    z ∈ centralizer s ↔ ∀ g ∈ s, g * z = z * g :=
  Iff.rfl
#align subsemiring.mem_centralizer_iff Subsemiring.mem_centralizer_iff

/- warning: subsemiring.centralizer_le -> Subsemiring.centralizer_le is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] (s : Set.{u1} R) (t : Set.{u1} R), (HasSubset.Subset.{u1} (Set.{u1} R) (Set.hasSubset.{u1} R) s t) -> (LE.le.{u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (Preorder.toLE.{u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (SetLike.partialOrder.{u1, u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) R (Subsemiring.setLike.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4))))) (Subsemiring.centralizer.{u1} R _inst_4 t) (Subsemiring.centralizer.{u1} R _inst_4 s))
but is expected to have type
  forall {R : Type.{u1}} [_inst_4 : Semiring.{u1} R] (s : Set.{u1} R) (t : Set.{u1} R), (HasSubset.Subset.{u1} (Set.{u1} R) (Set.instHasSubsetSet.{u1} R) s t) -> (LE.le.{u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (Preorder.toLE.{u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)) (Subsemiring.instCompleteLatticeSubsemiring.{u1} R (Semiring.toNonAssocSemiring.{u1} R _inst_4)))))) (Subsemiring.centralizer.{u1} R _inst_4 t) (Subsemiring.centralizer.{u1} R _inst_4 s))
Case conversion may be inaccurate. Consider using '#align subsemiring.centralizer_le Subsemiring.centralizer_leₓ'. -/
theorem centralizer_le {R} [Semiring R] (s t : Set R) (h : s ⊆ t) : centralizer t ≤ centralizer s :=
  Set.centralizer_subset h
#align subsemiring.centralizer_le Subsemiring.centralizer_le

#print Subsemiring.centralizer_univ /-
@[simp]
theorem centralizer_univ {R} [Semiring R] : centralizer Set.univ = center R :=
  SetLike.ext' (Set.centralizer_univ R)
#align subsemiring.centralizer_univ Subsemiring.centralizer_univ
-/

end Centralizer

#print Subsemiring.closure /-
/-- The `subsemiring` generated by a set. -/
def closure (s : Set R) : Subsemiring R :=
  infₛ { S | s ⊆ S }
#align subsemiring.closure Subsemiring.closure
-/

/- warning: subsemiring.mem_closure -> Subsemiring.mem_closure is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {x : R} {s : Set.{u1} R}, Iff (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x (Subsemiring.closure.{u1} R _inst_1 s)) (forall (S : Subsemiring.{u1} R _inst_1), (HasSubset.Subset.{u1} (Set.{u1} R) (Set.hasSubset.{u1} R) s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) S)) -> (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) x S))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {x : R} {s : Set.{u1} R}, Iff (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x (Subsemiring.closure.{u1} R _inst_1 s)) (forall (S : Subsemiring.{u1} R _inst_1), (HasSubset.Subset.{u1} (Set.{u1} R) (Set.instHasSubsetSet.{u1} R) s (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) S)) -> (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) x S))
Case conversion may be inaccurate. Consider using '#align subsemiring.mem_closure Subsemiring.mem_closureₓ'. -/
theorem mem_closure {x : R} {s : Set R} : x ∈ closure s ↔ ∀ S : Subsemiring R, s ⊆ S → x ∈ S :=
  mem_infₛ
#align subsemiring.mem_closure Subsemiring.mem_closure

/- warning: subsemiring.subset_closure -> Subsemiring.subset_closure is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R}, HasSubset.Subset.{u1} (Set.{u1} R) (Set.hasSubset.{u1} R) s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) (Subsemiring.closure.{u1} R _inst_1 s))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R}, HasSubset.Subset.{u1} (Set.{u1} R) (Set.instHasSubsetSet.{u1} R) s (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) (Subsemiring.closure.{u1} R _inst_1 s))
Case conversion may be inaccurate. Consider using '#align subsemiring.subset_closure Subsemiring.subset_closureₓ'. -/
/-- The subsemiring generated by a set includes the set. -/
@[simp]
theorem subset_closure {s : Set R} : s ⊆ closure s := fun x hx => mem_closure.2 fun S hS => hS hx
#align subsemiring.subset_closure Subsemiring.subset_closure

/- warning: subsemiring.not_mem_of_not_mem_closure -> Subsemiring.not_mem_of_not_mem_closure is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R} {P : R}, (Not (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) P (Subsemiring.closure.{u1} R _inst_1 s))) -> (Not (Membership.Mem.{u1, u1} R (Set.{u1} R) (Set.hasMem.{u1} R) P s))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R} {P : R}, (Not (Membership.mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) P (Subsemiring.closure.{u1} R _inst_1 s))) -> (Not (Membership.mem.{u1, u1} R (Set.{u1} R) (Set.instMembershipSet.{u1} R) P s))
Case conversion may be inaccurate. Consider using '#align subsemiring.not_mem_of_not_mem_closure Subsemiring.not_mem_of_not_mem_closureₓ'. -/
theorem not_mem_of_not_mem_closure {s : Set R} {P : R} (hP : P ∉ closure s) : P ∉ s := fun h =>
  hP (subset_closure h)
#align subsemiring.not_mem_of_not_mem_closure Subsemiring.not_mem_of_not_mem_closure

/- warning: subsemiring.closure_le -> Subsemiring.closure_le is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R} {t : Subsemiring.{u1} R _inst_1}, Iff (LE.le.{u1} (Subsemiring.{u1} R _inst_1) (Preorder.toLE.{u1} (Subsemiring.{u1} R _inst_1) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (SetLike.partialOrder.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) (Subsemiring.closure.{u1} R _inst_1 s) t) (HasSubset.Subset.{u1} (Set.{u1} R) (Set.hasSubset.{u1} R) s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) t))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R} {t : Subsemiring.{u1} R _inst_1}, Iff (LE.le.{u1} (Subsemiring.{u1} R _inst_1) (Preorder.toLE.{u1} (Subsemiring.{u1} R _inst_1) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subsemiring.{u1} R _inst_1) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instCompleteLatticeSubsemiring.{u1} R _inst_1))))) (Subsemiring.closure.{u1} R _inst_1 s) t) (HasSubset.Subset.{u1} (Set.{u1} R) (Set.instHasSubsetSet.{u1} R) s (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) t))
Case conversion may be inaccurate. Consider using '#align subsemiring.closure_le Subsemiring.closure_leₓ'. -/
/-- A subsemiring `S` includes `closure s` if and only if it includes `s`. -/
@[simp]
theorem closure_le {s : Set R} {t : Subsemiring R} : closure s ≤ t ↔ s ⊆ t :=
  ⟨Set.Subset.trans subset_closure, fun h => infₛ_le h⟩
#align subsemiring.closure_le Subsemiring.closure_le

/- warning: subsemiring.closure_mono -> Subsemiring.closure_mono is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {{s : Set.{u1} R}} {{t : Set.{u1} R}}, (HasSubset.Subset.{u1} (Set.{u1} R) (Set.hasSubset.{u1} R) s t) -> (LE.le.{u1} (Subsemiring.{u1} R _inst_1) (Preorder.toLE.{u1} (Subsemiring.{u1} R _inst_1) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (SetLike.partialOrder.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) (Subsemiring.closure.{u1} R _inst_1 s) (Subsemiring.closure.{u1} R _inst_1 t))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {{s : Set.{u1} R}} {{t : Set.{u1} R}}, (HasSubset.Subset.{u1} (Set.{u1} R) (Set.instHasSubsetSet.{u1} R) s t) -> (LE.le.{u1} (Subsemiring.{u1} R _inst_1) (Preorder.toLE.{u1} (Subsemiring.{u1} R _inst_1) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subsemiring.{u1} R _inst_1) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instCompleteLatticeSubsemiring.{u1} R _inst_1))))) (Subsemiring.closure.{u1} R _inst_1 s) (Subsemiring.closure.{u1} R _inst_1 t))
Case conversion may be inaccurate. Consider using '#align subsemiring.closure_mono Subsemiring.closure_monoₓ'. -/
/-- Subsemiring closure of a set is monotone in its argument: if `s ⊆ t`,
then `closure s ≤ closure t`. -/
theorem closure_mono ⦃s t : Set R⦄ (h : s ⊆ t) : closure s ≤ closure t :=
  closure_le.2 <| Set.Subset.trans h subset_closure
#align subsemiring.closure_mono Subsemiring.closure_mono

/- warning: subsemiring.closure_eq_of_le -> Subsemiring.closure_eq_of_le is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R} {t : Subsemiring.{u1} R _inst_1}, (HasSubset.Subset.{u1} (Set.{u1} R) (Set.hasSubset.{u1} R) s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) t)) -> (LE.le.{u1} (Subsemiring.{u1} R _inst_1) (Preorder.toLE.{u1} (Subsemiring.{u1} R _inst_1) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (SetLike.partialOrder.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) t (Subsemiring.closure.{u1} R _inst_1 s)) -> (Eq.{succ u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.closure.{u1} R _inst_1 s) t)
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] {s : Set.{u1} R} {t : Subsemiring.{u1} R _inst_1}, (HasSubset.Subset.{u1} (Set.{u1} R) (Set.instHasSubsetSet.{u1} R) s (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) t)) -> (LE.le.{u1} (Subsemiring.{u1} R _inst_1) (Preorder.toLE.{u1} (Subsemiring.{u1} R _inst_1) (PartialOrder.toPreorder.{u1} (Subsemiring.{u1} R _inst_1) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subsemiring.{u1} R _inst_1) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.instCompleteLatticeSubsemiring.{u1} R _inst_1))))) t (Subsemiring.closure.{u1} R _inst_1 s)) -> (Eq.{succ u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.closure.{u1} R _inst_1 s) t)
Case conversion may be inaccurate. Consider using '#align subsemiring.closure_eq_of_le Subsemiring.closure_eq_of_leₓ'. -/
theorem closure_eq_of_le {s : Set R} {t : Subsemiring R} (h₁ : s ⊆ t) (h₂ : t ≤ closure s) :
    closure s = t :=
  le_antisymm (closure_le.2 h₁) h₂
#align subsemiring.closure_eq_of_le Subsemiring.closure_eq_of_le

/- warning: subsemiring.mem_map_equiv -> Subsemiring.mem_map_equiv is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] {f : RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))} {K : Subsemiring.{u1} R _inst_1} {x : S}, Iff (Membership.Mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.hasMem.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.setLike.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 ((fun (a : Sort.{max (succ u1) (succ u2)}) (b : Sort.{max (succ u1) (succ u2)}) [self : HasLiftT.{max (succ u1) (succ u2), max (succ u1) (succ u2)} a b] => self.0) (RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) (RingHom.{u1, u2} R S _inst_1 _inst_2) (HasLiftT.mk.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) (RingHom.{u1, u2} R S _inst_1 _inst_2) (CoeTCₓ.coe.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) (RingHom.{u1, u2} R S _inst_1 _inst_2) (RingHom.hasCoeT.{max u1 u2, u1, u2} (RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) R S _inst_1 _inst_2 (RingEquivClass.toRingHomClass.{max u1 u2, u1, u2} (RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) R S _inst_1 _inst_2 (RingEquiv.ringEquivClass.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))))))) f) K)) (Membership.Mem.{u1, u1} R (Subsemiring.{u1} R _inst_1) (SetLike.hasMem.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)) (coeFn.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (RingEquiv.{u2, u1} S R (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) (fun (_x : RingEquiv.{u2, u1} S R (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) => S -> R) (RingEquiv.hasCoeToFun.{u2, u1} S R (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) (RingEquiv.symm.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) f) x) K)
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] {f : RingEquiv.{u1, u2} R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))} {K : Subsemiring.{u1} R _inst_1} {x : S}, Iff (Membership.mem.{u2, u2} S (Subsemiring.{u2} S _inst_2) (SetLike.instMembership.{u2, u2} (Subsemiring.{u2} S _inst_2) S (Subsemiring.instSetLikeSubsemiring.{u2} S _inst_2)) x (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 (RingHomClass.toRingHom.{max u1 u2, u1, u2} (RingEquiv.{u1, u2} R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) R S _inst_1 _inst_2 (RingEquivClass.toRingHomClass.{max u1 u2, u1, u2} (RingEquiv.{u1, u2} R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) R S _inst_1 _inst_2 (RingEquiv.instRingEquivClassRingEquiv.{u1, u2} R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))))) f) K)) (Membership.mem.{u1, u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : S) => R) x) (Subsemiring.{u1} R _inst_1) (SetLike.instMembership.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1)) (FunLike.coe.{max (succ u1) (succ u2), succ u2, succ u1} (RingEquiv.{u2, u1} S R (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) S (fun (_x : S) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : S) => R) _x) (EmbeddingLike.toFunLike.{max (succ u1) (succ u2), succ u2, succ u1} (RingEquiv.{u2, u1} S R (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) S R (EquivLike.toEmbeddingLike.{max (succ u1) (succ u2), succ u2, succ u1} (RingEquiv.{u2, u1} S R (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) S R (MulEquivClass.toEquivLike.{max u1 u2, u2, u1} (RingEquiv.{u2, u1} S R (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) S R (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (RingEquivClass.toMulEquivClass.{max u1 u2, u2, u1} (RingEquiv.{u2, u1} S R (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) S R (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (RingEquiv.instRingEquivClassRingEquiv.{u2, u1} S R (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))))))) (RingEquiv.symm.{u1, u2} R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) f) x) K)
Case conversion may be inaccurate. Consider using '#align subsemiring.mem_map_equiv Subsemiring.mem_map_equivₓ'. -/
theorem mem_map_equiv {f : R ≃+* S} {K : Subsemiring R} {x : S} :
    x ∈ K.map (f : R →+* S) ↔ f.symm x ∈ K :=
  @Set.mem_image_equiv _ _ (↑K) f.toEquiv x
#align subsemiring.mem_map_equiv Subsemiring.mem_map_equiv

/- warning: subsemiring.map_equiv_eq_comap_symm -> Subsemiring.map_equiv_eq_comap_symm is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (f : RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) (K : Subsemiring.{u1} R _inst_1), Eq.{succ u2} (Subsemiring.{u2} S _inst_2) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 ((fun (a : Sort.{max (succ u1) (succ u2)}) (b : Sort.{max (succ u1) (succ u2)}) [self : HasLiftT.{max (succ u1) (succ u2), max (succ u1) (succ u2)} a b] => self.0) (RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) (RingHom.{u1, u2} R S _inst_1 _inst_2) (HasLiftT.mk.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) (RingHom.{u1, u2} R S _inst_1 _inst_2) (CoeTCₓ.coe.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) (RingHom.{u1, u2} R S _inst_1 _inst_2) (RingHom.hasCoeT.{max u1 u2, u1, u2} (RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) R S _inst_1 _inst_2 (RingEquivClass.toRingHomClass.{max u1 u2, u1, u2} (RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) R S _inst_1 _inst_2 (RingEquiv.ringEquivClass.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))))))) f) K) (Subsemiring.comap.{u2, u1} S R _inst_2 _inst_1 ((fun (a : Sort.{max (succ u2) (succ u1)}) (b : Sort.{max (succ u2) (succ u1)}) [self : HasLiftT.{max (succ u2) (succ u1), max (succ u2) (succ u1)} a b] => self.0) (RingEquiv.{u2, u1} S R (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) (RingHom.{u2, u1} S R _inst_2 _inst_1) (HasLiftT.mk.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (RingEquiv.{u2, u1} S R (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) (RingHom.{u2, u1} S R _inst_2 _inst_1) (CoeTCₓ.coe.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (RingEquiv.{u2, u1} S R (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) (RingHom.{u2, u1} S R _inst_2 _inst_1) (RingHom.hasCoeT.{max u2 u1, u2, u1} (RingEquiv.{u2, u1} S R (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) S R _inst_2 _inst_1 (RingEquivClass.toRingHomClass.{max u2 u1, u2, u1} (RingEquiv.{u2, u1} S R (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) S R _inst_2 _inst_1 (RingEquiv.ringEquivClass.{u2, u1} S R (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))))))) (RingEquiv.symm.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) f)) K)
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (f : RingEquiv.{u1, u2} R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) (K : Subsemiring.{u1} R _inst_1), Eq.{succ u2} (Subsemiring.{u2} S _inst_2) (Subsemiring.map.{u1, u2} R S _inst_1 _inst_2 (RingHomClass.toRingHom.{max u1 u2, u1, u2} (RingEquiv.{u1, u2} R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) R S _inst_1 _inst_2 (RingEquivClass.toRingHomClass.{max u1 u2, u1, u2} (RingEquiv.{u1, u2} R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) R S _inst_1 _inst_2 (RingEquiv.instRingEquivClassRingEquiv.{u1, u2} R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))))) f) K) (Subsemiring.comap.{u2, u1} S R _inst_2 _inst_1 (RingHomClass.toRingHom.{max u1 u2, u2, u1} (RingEquiv.{u2, u1} S R (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) S R _inst_2 _inst_1 (RingEquivClass.toRingHomClass.{max u1 u2, u2, u1} (RingEquiv.{u2, u1} S R (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) S R _inst_2 _inst_1 (RingEquiv.instRingEquivClassRingEquiv.{u2, u1} S R (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))))) (RingEquiv.symm.{u1, u2} R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) f)) K)
Case conversion may be inaccurate. Consider using '#align subsemiring.map_equiv_eq_comap_symm Subsemiring.map_equiv_eq_comap_symmₓ'. -/
theorem map_equiv_eq_comap_symm (f : R ≃+* S) (K : Subsemiring R) :
    K.map (f : R →+* S) = K.comap f.symm :=
  SetLike.coe_injective (f.toEquiv.image_eq_preimage K)
#align subsemiring.map_equiv_eq_comap_symm Subsemiring.map_equiv_eq_comap_symm

/- warning: subsemiring.comap_equiv_eq_map_symm -> Subsemiring.comap_equiv_eq_map_symm is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (f : RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) (K : Subsemiring.{u2} S _inst_2), Eq.{succ u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.comap.{u1, u2} R S _inst_1 _inst_2 ((fun (a : Sort.{max (succ u1) (succ u2)}) (b : Sort.{max (succ u1) (succ u2)}) [self : HasLiftT.{max (succ u1) (succ u2), max (succ u1) (succ u2)} a b] => self.0) (RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) (RingHom.{u1, u2} R S _inst_1 _inst_2) (HasLiftT.mk.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) (RingHom.{u1, u2} R S _inst_1 _inst_2) (CoeTCₓ.coe.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) (RingHom.{u1, u2} R S _inst_1 _inst_2) (RingHom.hasCoeT.{max u1 u2, u1, u2} (RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) R S _inst_1 _inst_2 (RingEquivClass.toRingHomClass.{max u1 u2, u1, u2} (RingEquiv.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) R S _inst_1 _inst_2 (RingEquiv.ringEquivClass.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))))))) f) K) (Subsemiring.map.{u2, u1} S R _inst_2 _inst_1 ((fun (a : Sort.{max (succ u2) (succ u1)}) (b : Sort.{max (succ u2) (succ u1)}) [self : HasLiftT.{max (succ u2) (succ u1), max (succ u2) (succ u1)} a b] => self.0) (RingEquiv.{u2, u1} S R (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) (RingHom.{u2, u1} S R _inst_2 _inst_1) (HasLiftT.mk.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (RingEquiv.{u2, u1} S R (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) (RingHom.{u2, u1} S R _inst_2 _inst_1) (CoeTCₓ.coe.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (RingEquiv.{u2, u1} S R (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) (RingHom.{u2, u1} S R _inst_2 _inst_1) (RingHom.hasCoeT.{max u2 u1, u2, u1} (RingEquiv.{u2, u1} S R (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) S R _inst_2 _inst_1 (RingEquivClass.toRingHomClass.{max u2 u1, u2, u1} (RingEquiv.{u2, u1} S R (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) S R _inst_2 _inst_1 (RingEquiv.ringEquivClass.{u2, u1} S R (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))))))) (RingEquiv.symm.{u1, u2} R S (Distrib.toHasMul.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toHasMul.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toHasAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) f)) K)
but is expected to have type
  forall {R : Type.{u1}} {S : Type.{u2}} [_inst_1 : NonAssocSemiring.{u1} R] [_inst_2 : NonAssocSemiring.{u2} S] (f : RingEquiv.{u1, u2} R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) (K : Subsemiring.{u2} S _inst_2), Eq.{succ u1} (Subsemiring.{u1} R _inst_1) (Subsemiring.comap.{u1, u2} R S _inst_1 _inst_2 (RingHomClass.toRingHom.{max u1 u2, u1, u2} (RingEquiv.{u1, u2} R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) R S _inst_1 _inst_2 (RingEquivClass.toRingHomClass.{max u1 u2, u1, u2} (RingEquiv.{u1, u2} R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)))) R S _inst_1 _inst_2 (RingEquiv.instRingEquivClassRingEquiv.{u1, u2} R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))))) f) K) (Subsemiring.map.{u2, u1} S R _inst_2 _inst_1 (RingHomClass.toRingHom.{max u1 u2, u2, u1} (RingEquiv.{u2, u1} S R (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) S R _inst_2 _inst_1 (RingEquivClass.toRingHomClass.{max u1 u2, u2, u1} (RingEquiv.{u2, u1} S R (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)))) S R _inst_2 _inst_1 (RingEquiv.instRingEquivClassRingEquiv.{u2, u1} S R (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))))) (RingEquiv.symm.{u1, u2} R S (NonUnitalNonAssocSemiring.toMul.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1)) (NonUnitalNonAssocSemiring.toMul.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2)) (Distrib.toAdd.{u1} R (NonUnitalNonAssocSemiring.toDistrib.{u1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} R _inst_1))) (Distrib.toAdd.{u2} S (NonUnitalNonAssocSemiring.toDistrib.{u2} S (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} S _inst_2))) f)) K)
Case conversion may be inaccurate. Consider using '#align subsemiring.comap_equiv_eq_map_symm Subsemiring.comap_equiv_eq_map_symmₓ'. -/
theorem comap_equiv_eq_map_symm (f : R ≃+* S) (K : Subsemiring S) :
    K.comap (f : R →+* S) = K.map f.symm :=
  (map_equiv_eq_comap_symm f.symm K).symm
#align subsemiring.comap_equiv_eq_map_symm Subsemiring.comap_equiv_eq_map_symm

end Subsemiring

namespace Submonoid

#print Submonoid.subsemiringClosure /-
/-- The additive closure of a submonoid is a subsemiring. -/
def subsemiringClosure (M : Submonoid R) : Subsemiring R :=
  {
    AddSubmonoid.closure
      (M : Set
          R) with
    one_mem' := AddSubmonoid.mem_closure.mpr fun y hy => hy M.one_mem
    mul_mem' := fun x y => MulMemClass.mul_mem_add_closure }
#align submonoid.subsemiring_closure Submonoid.subsemiringClosure
-/

/- warning: submonoid.subsemiring_closure_coe -> Submonoid.subsemiringClosure_coe is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (M : Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))), Eq.{succ u1} (Set.{u1} R) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemiring.{u1} R _inst_1) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.setLike.{u1} R _inst_1)))) (Submonoid.subsemiringClosure.{u1} R _inst_1 M)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.setLike.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))))))) (AddSubmonoid.closure.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.setLike.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)))))) M)))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (M : Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))), Eq.{succ u1} (Set.{u1} R) (SetLike.coe.{u1, u1} (Subsemiring.{u1} R _inst_1) R (Subsemiring.instSetLikeSubsemiring.{u1} R _inst_1) (Submonoid.subsemiringClosure.{u1} R _inst_1 M)) (SetLike.coe.{u1, u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) R (AddSubmonoid.instSetLikeAddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (AddSubmonoid.closure.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))) (SetLike.coe.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.instSetLikeSubmonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) M)))
Case conversion may be inaccurate. Consider using '#align submonoid.subsemiring_closure_coe Submonoid.subsemiringClosure_coeₓ'. -/
theorem subsemiringClosure_coe :
    (M.subsemiringClosure : Set R) = AddSubmonoid.closure (M : Set R) :=
  rfl
#align submonoid.subsemiring_closure_coe Submonoid.subsemiringClosure_coe

/- warning: submonoid.subsemiring_closure_to_add_submonoid -> Submonoid.subsemiringClosure_toAddSubmonoid is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (M : Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))), Eq.{succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Subsemiring.toAddSubmonoid.{u1} R _inst_1 (Submonoid.subsemiringClosure.{u1} R _inst_1 M)) (AddSubmonoid.closure.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (HasLiftT.mk.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (CoeTCₓ.coe.{succ u1, succ u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) (Set.{u1} R) (SetLike.Set.hasCoeT.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.setLike.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1)))))) M))
but is expected to have type
  forall {R : Type.{u1}} [_inst_1 : NonAssocSemiring.{u1} R] (M : Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))), Eq.{succ u1} (AddSubmonoid.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1))))) (Subsemiring.toAddSubmonoid.{u1} R _inst_1 (Submonoid.subsemiringClosure.{u1} R _inst_1 M)) (AddSubmonoid.closure.{u1} R (AddMonoid.toAddZeroClass.{u1} R (AddMonoidWithOne.toAddMonoid.{u1} R (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} R (NonAssocSemiring.toAddCommMonoidWithOne.{u1} R _inst_1)))) (SetLike.coe.{u1, u1} (Submonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) R (Submonoid.instSetLikeSubmonoid.{u1} R (MulZeroOneClass.toMulOneClass.{u1} R (NonAssocSemiring.toMulZeroOneClass.{u1} R _inst_1))) M))
Case conversion may be inaccurate. Consider using '#align submonoid.subsemiring_closure_to_add_submonoid Submonoid.subsemiringClosure_toAddSubmonoidₓ'. -/
theorem subsemiringClosure_toAddSubmonoid :
    M.subsemiringClosure.toAddSubmonoid = AddSubmonoid.closure (M : Set R) :=
  rfl
#align submonoid.subsemiring_closure_to_add_submonoid Submonoid.subsemiringClosure_toAddSubmonoid

#print Submonoid.subsemiringClosure_eq_closure /-
/-- The `subsemiring` generated by a multiplicative submonoid coincides with the
`subsemiring.closure` of the submonoid itself . -/
theorem subsemiringClosure_eq_closure : M.subsemiringClosure = Subsemiring.closure (M : Set R) :=
  by
  ext
  refine'
        ⟨fun hx => _, fun hx =>
          (subsemiring.mem_closure.mp hx) M.subsemiring_closure fun s sM => _⟩ <;>
      rintro - ⟨H1, rfl⟩ <;>
    rintro - ⟨H2, rfl⟩
  · exact add_submonoid.mem_closure.mp hx H1.to_add_submonoid H2
  · exact H2 sM
#align submonoid.subsemiring_closure_eq_closure Submonoid.subsemiringClosure_eq_closure
-/

end Submonoid

namespace Subsemiring

#print Subsemiring.closure_submonoid_closure /-
@[simp]
theorem closure_submonoid_closure (s : Set R) : closure ↑(Submonoid.closure s) = closure s :=
  le_antisymm
    (closure_le.mpr fun y hy =>
      (Submonoid.mem_closure.mp hy) (closure s).toSubmonoid subset_closure)
    (closure_mono Submonoid.subset_closure)
#align subsemiring.closure_submonoid_closure Subsemiring.closure_submonoid_closure
-/

#print Subsemiring.coe_closure_eq /-
/-- The elements of the subsemiring closure of `M` are exactly the elements of the additive closure
of a multiplicative submonoid `M`. -/
theorem coe_closure_eq (s : Set R) :
    (closure s : Set R) = AddSubmonoid.closure (Submonoid.closure s : Set R) := by
  simp [← Submonoid.subsemiringClosure_toAddSubmonoid, Submonoid.subsemiringClosure_eq_closure]
#align subsemiring.coe_closure_eq Subsemiring.coe_closure_eq
-/

#print Subsemiring.mem_closure_iff /-
theorem mem_closure_iff {s : Set R} {x} :
    x ∈ closure s ↔ x ∈ AddSubmonoid.closure (Submonoid.closure s : Set R) :=
  Set.ext_iff.mp (coe_closure_eq s) x
#align subsemiring.mem_closure_iff Subsemiring.mem_closure_iff
-/

#print Subsemiring.closure_addSubmonoid_closure /-
@[simp]
theorem closure_addSubmonoid_closure {s : Set R} : closure ↑(AddSubmonoid.closure s) = closure s :=
  by
  ext x
  refine' ⟨fun hx => _, fun hx => closure_mono AddSubmonoid.subset_closure hx⟩
  rintro - ⟨H, rfl⟩
  rintro - ⟨J, rfl⟩
  refine' (add_submonoid.mem_closure.mp (mem_closure_iff.mp hx)) H.to_add_submonoid fun y hy => _
  refine' (submonoid.mem_closure.mp hy) H.to_submonoid fun z hz => _
  exact (add_submonoid.mem_closure.mp hz) H.to_add_submonoid fun w hw => J hw
#align subsemiring.closure_add_submonoid_closure Subsemiring.closure_addSubmonoid_closure
-/

#print Subsemiring.closure_induction /-
/-- An induction principle for closure membership. If `p` holds for `0`, `1`, and all elements
of `s`, and is preserved under addition and multiplication, then `p` holds for all elements
of the closure of `s`. -/
@[elab_as_elim]
theorem closure_induction {s : Set R} {p : R → Prop} {x} (h : x ∈ closure s) (Hs : ∀ x ∈ s, p x)
    (H0 : p 0) (H1 : p 1) (Hadd : ∀ x y, p x → p y → p (x + y))
    (Hmul : ∀ x y, p x → p y → p (x * y)) : p x :=
  (@closure_le _ _ _ ⟨p, Hmul, H1, Hadd, H0⟩).2 Hs h
#align subsemiring.closure_induction Subsemiring.closure_induction
-/

#print Subsemiring.closure_induction₂ /-
/-- An induction principle for closure membership for predicates with two arguments. -/
@[elab_as_elim]
theorem closure_induction₂ {s : Set R} {p : R → R → Prop} {x} {y : R} (hx : x ∈ closure s)
    (hy : y ∈ closure s) (Hs : ∀ x ∈ s, ∀ y ∈ s, p x y) (H0_left : ∀ x, p 0 x)
    (H0_right : ∀ x, p x 0) (H1_left : ∀ x, p 1 x) (H1_right : ∀ x, p x 1)
    (Hadd_left : ∀ x₁ x₂ y, p x₁ y → p x₂ y → p (x₁ + x₂) y)
    (Hadd_right : ∀ x y₁ y₂, p x y₁ → p x y₂ → p x (y₁ + y₂))
    (Hmul_left : ∀ x₁ x₂ y, p x₁ y → p x₂ y → p (x₁ * x₂) y)
    (Hmul_right : ∀ x y₁ y₂, p x y₁ → p x y₂ → p x (y₁ * y₂)) : p x y :=
  closure_induction hx
    (fun x₁ x₁s =>
      closure_induction hy (Hs x₁ x₁s) (H0_right x₁) (H1_right x₁) (Hadd_right x₁) (Hmul_right x₁))
    (H0_left y) (H1_left y) (fun z z' => Hadd_left z z' y) fun z z' => Hmul_left z z' y
#align subsemiring.closure_induction₂ Subsemiring.closure_induction₂
-/

#print Subsemiring.mem_closure_iff_exists_list /-
theorem mem_closure_iff_exists_list {R} [Semiring R] {s : Set R} {x} :
    x ∈ closure s ↔ ∃ L : List (List R), (∀ t ∈ L, ∀ y ∈ t, y ∈ s) ∧ (L.map List.prod).Sum = x :=
  ⟨fun hx =>
    AddSubmonoid.closure_induction (mem_closure_iff.1 hx)
      (fun x hx =>
        suffices ∃ t : List R, (∀ y ∈ t, y ∈ s) ∧ t.Prod = x from
          let ⟨t, ht1, ht2⟩ := this
          ⟨[t], List.forall_mem_singleton.2 ht1, by
            rw [List.map_singleton, List.sum_singleton, ht2]⟩
        Submonoid.closure_induction hx
          (fun x hx => ⟨[x], List.forall_mem_singleton.2 hx, one_mul x⟩)
          ⟨[], List.forall_mem_nil _, rfl⟩ fun x y ⟨t, ht1, ht2⟩ ⟨u, hu1, hu2⟩ =>
          ⟨t ++ u, List.forall_mem_append.2 ⟨ht1, hu1⟩, by rw [List.prod_append, ht2, hu2]⟩)
      ⟨[], List.forall_mem_nil _, rfl⟩ fun x y ⟨L, HL1, HL2⟩ ⟨M, HM1, HM2⟩ =>
      ⟨L ++ M, List.forall_mem_append.2 ⟨HL1, HM1⟩, by
        rw [List.map_append, List.sum_append, HL2, HM2]⟩,
    fun ⟨L, HL1, HL2⟩ =>
    HL2 ▸
      list_sum_mem fun r hr =>
        let ⟨t, ht1, ht2⟩ := List.mem_map'.1 hr
        ht2 ▸ list_prod_mem _ fun y hy => subset_closure <| HL1 t ht1 y hy⟩
#align subsemiring.mem_closure_iff_exists_list Subsemiring.mem_closure_iff_exists_list
-/

variable (R)

#print Subsemiring.gi /-
/-- `closure` forms a Galois insertion with the coercion to set. -/
protected def gi : GaloisInsertion (@closure R _) coe
    where
  choice s _ := closure s
  gc s t := closure_le
  le_l_u s := subset_closure
  choice_eq s h := rfl
#align subsemiring.gi Subsemiring.gi
-/

variable {R}

#print Subsemiring.closure_eq /-
/-- Closure of a subsemiring `S` equals `S`. -/
theorem closure_eq (s : Subsemiring R) : closure (s : Set R) = s :=
  (Subsemiring.gi R).l_u_eq s
#align subsemiring.closure_eq Subsemiring.closure_eq
-/

#print Subsemiring.closure_empty /-
@[simp]
theorem closure_empty : closure (∅ : Set R) = ⊥ :=
  (Subsemiring.gi R).gc.l_bot
#align subsemiring.closure_empty Subsemiring.closure_empty
-/

#print Subsemiring.closure_univ /-
@[simp]
theorem closure_univ : closure (Set.univ : Set R) = ⊤ :=
  @coe_top R _ ▸ closure_eq ⊤
#align subsemiring.closure_univ Subsemiring.closure_univ
-/

#print Subsemiring.closure_union /-
theorem closure_union (s t : Set R) : closure (s ∪ t) = closure s ⊔ closure t :=
  (Subsemiring.gi R).gc.l_sup
#align subsemiring.closure_union Subsemiring.closure_union
-/

#print Subsemiring.closure_unionᵢ /-
theorem closure_unionᵢ {ι} (s : ι → Set R) : closure (⋃ i, s i) = ⨆ i, closure (s i) :=
  (Subsemiring.gi R).gc.l_supᵢ
#align subsemiring.closure_Union Subsemiring.closure_unionᵢ
-/

#print Subsemiring.closure_unionₛ /-
theorem closure_unionₛ (s : Set (Set R)) : closure (⋃₀ s) = ⨆ t ∈ s, closure t :=
  (Subsemiring.gi R).gc.l_supₛ
#align subsemiring.closure_sUnion Subsemiring.closure_unionₛ
-/

#print Subsemiring.map_sup /-
theorem map_sup (s t : Subsemiring R) (f : R →+* S) : (s ⊔ t).map f = s.map f ⊔ t.map f :=
  (gc_map_comap f).l_sup
#align subsemiring.map_sup Subsemiring.map_sup
-/

#print Subsemiring.map_supᵢ /-
theorem map_supᵢ {ι : Sort _} (f : R →+* S) (s : ι → Subsemiring R) :
    (supᵢ s).map f = ⨆ i, (s i).map f :=
  (gc_map_comap f).l_supᵢ
#align subsemiring.map_supr Subsemiring.map_supᵢ
-/

#print Subsemiring.comap_inf /-
theorem comap_inf (s t : Subsemiring S) (f : R →+* S) : (s ⊓ t).comap f = s.comap f ⊓ t.comap f :=
  (gc_map_comap f).u_inf
#align subsemiring.comap_inf Subsemiring.comap_inf
-/

#print Subsemiring.comap_infᵢ /-
theorem comap_infᵢ {ι : Sort _} (f : R →+* S) (s : ι → Subsemiring S) :
    (infᵢ s).comap f = ⨅ i, (s i).comap f :=
  (gc_map_comap f).u_infᵢ
#align subsemiring.comap_infi Subsemiring.comap_infᵢ
-/

#print Subsemiring.map_bot /-
@[simp]
theorem map_bot (f : R →+* S) : (⊥ : Subsemiring R).map f = ⊥ :=
  (gc_map_comap f).l_bot
#align subsemiring.map_bot Subsemiring.map_bot
-/

#print Subsemiring.comap_top /-
@[simp]
theorem comap_top (f : R →+* S) : (⊤ : Subsemiring S).comap f = ⊤ :=
  (gc_map_comap f).u_top
#align subsemiring.comap_top Subsemiring.comap_top
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Subsemiring.prod /-
/-- Given `subsemiring`s `s`, `t` of semirings `R`, `S` respectively, `s.prod t` is `s × t`
as a subsemiring of `R × S`. -/
def prod (s : Subsemiring R) (t : Subsemiring S) : Subsemiring (R × S) :=
  { s.toSubmonoid.Prod t.toSubmonoid, s.toAddSubmonoid.Prod t.toAddSubmonoid with
    carrier := s ×ˢ t }
#align subsemiring.prod Subsemiring.prod
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Subsemiring.coe_prod /-
@[norm_cast]
theorem coe_prod (s : Subsemiring R) (t : Subsemiring S) : (s.Prod t : Set (R × S)) = s ×ˢ t :=
  rfl
#align subsemiring.coe_prod Subsemiring.coe_prod
-/

#print Subsemiring.mem_prod /-
theorem mem_prod {s : Subsemiring R} {t : Subsemiring S} {p : R × S} :
    p ∈ s.Prod t ↔ p.1 ∈ s ∧ p.2 ∈ t :=
  Iff.rfl
#align subsemiring.mem_prod Subsemiring.mem_prod
-/

#print Subsemiring.prod_mono /-
@[mono]
theorem prod_mono ⦃s₁ s₂ : Subsemiring R⦄ (hs : s₁ ≤ s₂) ⦃t₁ t₂ : Subsemiring S⦄ (ht : t₁ ≤ t₂) :
    s₁.Prod t₁ ≤ s₂.Prod t₂ :=
  Set.prod_mono hs ht
#align subsemiring.prod_mono Subsemiring.prod_mono
-/

#print Subsemiring.prod_mono_right /-
theorem prod_mono_right (s : Subsemiring R) : Monotone fun t : Subsemiring S => s.Prod t :=
  prod_mono (le_refl s)
#align subsemiring.prod_mono_right Subsemiring.prod_mono_right
-/

#print Subsemiring.prod_mono_left /-
theorem prod_mono_left (t : Subsemiring S) : Monotone fun s : Subsemiring R => s.Prod t :=
  fun s₁ s₂ hs => prod_mono hs (le_refl t)
#align subsemiring.prod_mono_left Subsemiring.prod_mono_left
-/

#print Subsemiring.prod_top /-
theorem prod_top (s : Subsemiring R) : s.Prod (⊤ : Subsemiring S) = s.comap (RingHom.fst R S) :=
  ext fun x => by simp [mem_prod, MonoidHom.coe_fst]
#align subsemiring.prod_top Subsemiring.prod_top
-/

#print Subsemiring.top_prod /-
theorem top_prod (s : Subsemiring S) : (⊤ : Subsemiring R).Prod s = s.comap (RingHom.snd R S) :=
  ext fun x => by simp [mem_prod, MonoidHom.coe_snd]
#align subsemiring.top_prod Subsemiring.top_prod
-/

#print Subsemiring.top_prod_top /-
@[simp]
theorem top_prod_top : (⊤ : Subsemiring R).Prod (⊤ : Subsemiring S) = ⊤ :=
  (top_prod _).trans <| comap_top _
#align subsemiring.top_prod_top Subsemiring.top_prod_top
-/

#print Subsemiring.prodEquiv /-
/-- Product of subsemirings is isomorphic to their product as monoids. -/
def prodEquiv (s : Subsemiring R) (t : Subsemiring S) : s.Prod t ≃+* s × t :=
  { Equiv.Set.prod ↑s ↑t with
    map_mul' := fun x y => rfl
    map_add' := fun x y => rfl }
#align subsemiring.prod_equiv Subsemiring.prodEquiv
-/

#print Subsemiring.mem_supᵢ_of_directed /-
theorem mem_supᵢ_of_directed {ι} [hι : Nonempty ι] {S : ι → Subsemiring R} (hS : Directed (· ≤ ·) S)
    {x : R} : (x ∈ ⨆ i, S i) ↔ ∃ i, x ∈ S i :=
  by
  refine' ⟨_, fun ⟨i, hi⟩ => (SetLike.le_def.1 <| le_supᵢ S i) hi⟩
  let U : Subsemiring R :=
    Subsemiring.mk' (⋃ i, (S i : Set R)) (⨆ i, (S i).toSubmonoid)
      (Submonoid.coe_supᵢ_of_directed <| hS.mono_comp _ fun _ _ => id) (⨆ i, (S i).toAddSubmonoid)
      (AddSubmonoid.coe_supᵢ_of_directed <| hS.mono_comp _ fun _ _ => id)
  suffices (⨆ i, S i) ≤ U by simpa using @this x
  exact supᵢ_le fun i x hx => Set.mem_unionᵢ.2 ⟨i, hx⟩
#align subsemiring.mem_supr_of_directed Subsemiring.mem_supᵢ_of_directed
-/

#print Subsemiring.coe_supᵢ_of_directed /-
theorem coe_supᵢ_of_directed {ι} [hι : Nonempty ι] {S : ι → Subsemiring R}
    (hS : Directed (· ≤ ·) S) : ((⨆ i, S i : Subsemiring R) : Set R) = ⋃ i, ↑(S i) :=
  Set.ext fun x => by simp [mem_supr_of_directed hS]
#align subsemiring.coe_supr_of_directed Subsemiring.coe_supᵢ_of_directed
-/

#print Subsemiring.mem_supₛ_of_directedOn /-
theorem mem_supₛ_of_directedOn {S : Set (Subsemiring R)} (Sne : S.Nonempty)
    (hS : DirectedOn (· ≤ ·) S) {x : R} : x ∈ supₛ S ↔ ∃ s ∈ S, x ∈ s :=
  by
  haveI : Nonempty S := Sne.to_subtype
  simp only [supₛ_eq_supᵢ', mem_supr_of_directed hS.directed_coe, SetCoe.exists, Subtype.coe_mk]
#align subsemiring.mem_Sup_of_directed_on Subsemiring.mem_supₛ_of_directedOn
-/

#print Subsemiring.coe_supₛ_of_directedOn /-
theorem coe_supₛ_of_directedOn {S : Set (Subsemiring R)} (Sne : S.Nonempty)
    (hS : DirectedOn (· ≤ ·) S) : (↑(supₛ S) : Set R) = ⋃ s ∈ S, ↑s :=
  Set.ext fun x => by simp [mem_Sup_of_directed_on Sne hS]
#align subsemiring.coe_Sup_of_directed_on Subsemiring.coe_supₛ_of_directedOn
-/

end Subsemiring

namespace RingHom

variable [NonAssocSemiring T] {s : Subsemiring R}

variable {σR σS : Type _}

variable [SetLike σR R] [SetLike σS S] [SubsemiringClass σR R] [SubsemiringClass σS S]

open Subsemiring

#print RingHom.domRestrict /-
/-- Restriction of a ring homomorphism to a subsemiring of the domain. -/
def domRestrict (f : R →+* S) (s : σR) : s →+* S :=
  f.comp <| SubsemiringClass.subtype s
#align ring_hom.dom_restrict RingHom.domRestrict
-/

#print RingHom.restrict_apply /-
@[simp]
theorem restrict_apply (f : R →+* S) {s : σR} (x : s) : f.domRestrict s x = f x :=
  rfl
#align ring_hom.restrict_apply RingHom.restrict_apply
-/

#print RingHom.codRestrict /-
/-- Restriction of a ring homomorphism to a subsemiring of the codomain. -/
def codRestrict (f : R →+* S) (s : σS) (h : ∀ x, f x ∈ s) : R →+* s :=
  { (f : R →* S).codRestrict s h, (f : R →+ S).codRestrict s h with toFun := fun n => ⟨f n, h n⟩ }
#align ring_hom.cod_restrict RingHom.codRestrict
-/

#print RingHom.restrict /-
/-- The ring homomorphism from the preimage of `s` to `s`. -/
def restrict (f : R →+* S) (s' : σR) (s : σS) (h : ∀ x ∈ s', f x ∈ s) : s' →+* s :=
  (f.domRestrict s').codRestrict s fun x => h x x.2
#align ring_hom.restrict RingHom.restrict
-/

#print RingHom.coe_restrict_apply /-
@[simp]
theorem coe_restrict_apply (f : R →+* S) (s' : σR) (s : σS) (h : ∀ x ∈ s', f x ∈ s) (x : s') :
    (f.restrict s' s h x : S) = f x :=
  rfl
#align ring_hom.coe_restrict_apply RingHom.coe_restrict_apply
-/

#print RingHom.comp_restrict /-
@[simp]
theorem comp_restrict (f : R →+* S) (s' : σR) (s : σS) (h : ∀ x ∈ s', f x ∈ s) :
    (SubsemiringClass.subtype s).comp (f.restrict s' s h) = f.comp (SubsemiringClass.subtype s') :=
  rfl
#align ring_hom.comp_restrict RingHom.comp_restrict
-/

#print RingHom.rangeSRestrict /-
/-- Restriction of a ring homomorphism to its range interpreted as a subsemiring.

This is the bundled version of `set.range_factorization`. -/
def rangeSRestrict (f : R →+* S) : R →+* f.srange :=
  f.codRestrict f.srange f.mem_rangeS_self
#align ring_hom.srange_restrict RingHom.rangeSRestrict
-/

#print RingHom.coe_rangeSRestrict /-
@[simp]
theorem coe_rangeSRestrict (f : R →+* S) (x : R) : (f.srangeRestrict x : S) = f x :=
  rfl
#align ring_hom.coe_srange_restrict RingHom.coe_rangeSRestrict
-/

#print RingHom.rangeSRestrict_surjective /-
theorem rangeSRestrict_surjective (f : R →+* S) : Function.Surjective f.srangeRestrict :=
  fun ⟨y, hy⟩ =>
  let ⟨x, hx⟩ := mem_rangeS.mp hy
  ⟨x, Subtype.ext hx⟩
#align ring_hom.srange_restrict_surjective RingHom.rangeSRestrict_surjective
-/

#print RingHom.rangeS_top_iff_surjective /-
theorem rangeS_top_iff_surjective {f : R →+* S} :
    f.srange = (⊤ : Subsemiring S) ↔ Function.Surjective f :=
  SetLike.ext'_iff.trans <| Iff.trans (by rw [coe_srange, coe_top]) Set.range_iff_surjective
#align ring_hom.srange_top_iff_surjective RingHom.rangeS_top_iff_surjective
-/

#print RingHom.rangeS_top_of_surjective /-
/-- The range of a surjective ring homomorphism is the whole of the codomain. -/
theorem rangeS_top_of_surjective (f : R →+* S) (hf : Function.Surjective f) :
    f.srange = (⊤ : Subsemiring S) :=
  rangeS_top_iff_surjective.2 hf
#align ring_hom.srange_top_of_surjective RingHom.rangeS_top_of_surjective
-/

#print RingHom.eqLocusS /-
/-- The subsemiring of elements `x : R` such that `f x = g x` -/
def eqLocusS (f g : R →+* S) : Subsemiring R :=
  { (f : R →* S).eqLocus g, (f : R →+ S).eqLocus g with carrier := { x | f x = g x } }
#align ring_hom.eq_slocus RingHom.eqLocusS
-/

#print RingHom.eqLocusS_same /-
@[simp]
theorem eqLocusS_same (f : R →+* S) : f.eqLocusS f = ⊤ :=
  SetLike.ext fun _ => eq_self_iff_true _
#align ring_hom.eq_slocus_same RingHom.eqLocusS_same
-/

#print RingHom.eqOn_sclosure /-
/-- If two ring homomorphisms are equal on a set, then they are equal on its subsemiring closure. -/
theorem eqOn_sclosure {f g : R →+* S} {s : Set R} (h : Set.EqOn f g s) : Set.EqOn f g (closure s) :=
  show closure s ≤ f.eqLocusS g from closure_le.2 h
#align ring_hom.eq_on_sclosure RingHom.eqOn_sclosure
-/

#print RingHom.eq_of_eqOn_stop /-
theorem eq_of_eqOn_stop {f g : R →+* S} (h : Set.EqOn f g (⊤ : Subsemiring R)) : f = g :=
  ext fun x => h trivial
#align ring_hom.eq_of_eq_on_stop RingHom.eq_of_eqOn_stop
-/

#print RingHom.eq_of_eqOn_sdense /-
theorem eq_of_eqOn_sdense {s : Set R} (hs : closure s = ⊤) {f g : R →+* S} (h : s.EqOn f g) :
    f = g :=
  eq_of_eqOn_stop <| hs ▸ eqOn_sclosure h
#align ring_hom.eq_of_eq_on_sdense RingHom.eq_of_eqOn_sdense
-/

#print RingHom.sclosure_preimage_le /-
theorem sclosure_preimage_le (f : R →+* S) (s : Set S) : closure (f ⁻¹' s) ≤ (closure s).comap f :=
  closure_le.2 fun x hx => SetLike.mem_coe.2 <| mem_comap.2 <| subset_closure hx
#align ring_hom.sclosure_preimage_le RingHom.sclosure_preimage_le
-/

#print RingHom.map_closureS /-
/-- The image under a ring homomorphism of the subsemiring generated by a set equals
the subsemiring generated by the image of the set. -/
theorem map_closureS (f : R →+* S) (s : Set R) : (closure s).map f = closure (f '' s) :=
  le_antisymm
    (map_le_iff_le_comap.2 <|
      le_trans (closure_mono <| Set.subset_preimage_image _ _) (sclosure_preimage_le _ _))
    (closure_le.2 <| Set.image_subset _ subset_closure)
#align ring_hom.map_sclosure RingHom.map_closureS
-/

end RingHom

namespace Subsemiring

open RingHom

#print Subsemiring.inclusion /-
/-- The ring homomorphism associated to an inclusion of subsemirings. -/
def inclusion {S T : Subsemiring R} (h : S ≤ T) : S →+* T :=
  S.Subtype.codRestrict _ fun x => h x.2
#align subsemiring.inclusion Subsemiring.inclusion
-/

#print Subsemiring.rangeS_subtype /-
@[simp]
theorem rangeS_subtype (s : Subsemiring R) : s.Subtype.srange = s :=
  SetLike.coe_injective <| (coe_rangeS _).trans Subtype.range_coe
#align subsemiring.srange_subtype Subsemiring.rangeS_subtype
-/

#print Subsemiring.range_fst /-
@[simp]
theorem range_fst : (fst R S).srange = ⊤ :=
  (fst R S).srange_top_of_surjective <| Prod.fst_surjective
#align subsemiring.range_fst Subsemiring.range_fst
-/

#print Subsemiring.range_snd /-
@[simp]
theorem range_snd : (snd R S).srange = ⊤ :=
  (snd R S).srange_top_of_surjective <| Prod.snd_surjective
#align subsemiring.range_snd Subsemiring.range_snd
-/

#print Subsemiring.prod_bot_sup_bot_prod /-
@[simp]
theorem prod_bot_sup_bot_prod (s : Subsemiring R) (t : Subsemiring S) :
    s.Prod ⊥ ⊔ prod ⊥ t = s.Prod t :=
  le_antisymm (sup_le (prod_mono_right s bot_le) (prod_mono_left t bot_le)) fun p hp =>
    Prod.fst_mul_snd p ▸
      mul_mem
        ((le_sup_left : s.Prod ⊥ ≤ s.Prod ⊥ ⊔ prod ⊥ t) ⟨hp.1, SetLike.mem_coe.2 <| one_mem ⊥⟩)
        ((le_sup_right : prod ⊥ t ≤ s.Prod ⊥ ⊔ prod ⊥ t) ⟨SetLike.mem_coe.2 <| one_mem ⊥, hp.2⟩)
#align subsemiring.prod_bot_sup_bot_prod Subsemiring.prod_bot_sup_bot_prod
-/

end Subsemiring

namespace RingEquiv

variable {s t : Subsemiring R}

#print RingEquiv.subsemiringCongr /-
/-- Makes the identity isomorphism from a proof two subsemirings of a multiplicative
    monoid are equal. -/
def subsemiringCongr (h : s = t) : s ≃+* t :=
  {
    Equiv.setCongr <| congr_arg _ h with
    map_mul' := fun _ _ => rfl
    map_add' := fun _ _ => rfl }
#align ring_equiv.subsemiring_congr RingEquiv.subsemiringCongr
-/

#print RingEquiv.ofLeftInverseS /-
/-- Restrict a ring homomorphism with a left inverse to a ring isomorphism to its
`ring_hom.srange`. -/
def ofLeftInverseS {g : S → R} {f : R →+* S} (h : Function.LeftInverse g f) : R ≃+* f.srange :=
  { f.srangeRestrict with
    toFun := fun x => f.srangeRestrict x
    invFun := fun x => (g ∘ f.srange.Subtype) x
    left_inv := h
    right_inv := fun x =>
      Subtype.ext <|
        let ⟨x', hx'⟩ := RingHom.mem_rangeS.mp x.Prop
        show f (g x) = x by rw [← hx', h x'] }
#align ring_equiv.sof_left_inverse RingEquiv.ofLeftInverseS
-/

#print RingEquiv.ofLeftInverseS_apply /-
@[simp]
theorem ofLeftInverseS_apply {g : S → R} {f : R →+* S} (h : Function.LeftInverse g f) (x : R) :
    ↑(ofLeftInverseS h x) = f x :=
  rfl
#align ring_equiv.sof_left_inverse_apply RingEquiv.ofLeftInverseS_apply
-/

#print RingEquiv.ofLeftInverseS_symm_apply /-
@[simp]
theorem ofLeftInverseS_symm_apply {g : S → R} {f : R →+* S} (h : Function.LeftInverse g f)
    (x : f.srange) : (ofLeftInverseS h).symm x = g x :=
  rfl
#align ring_equiv.sof_left_inverse_symm_apply RingEquiv.ofLeftInverseS_symm_apply
-/

#print RingEquiv.subsemiringMap /-
/-- Given an equivalence `e : R ≃+* S` of semirings and a subsemiring `s` of `R`,
`subsemiring_map e s` is the induced equivalence between `s` and `s.map e` -/
@[simps]
def subsemiringMap (e : R ≃+* S) (s : Subsemiring R) : s ≃+* s.map e.toRingHom :=
  { e.toAddEquiv.addSubmonoidMap s.toAddSubmonoid, e.toMulEquiv.submonoidMap s.toSubmonoid with }
#align ring_equiv.subsemiring_map RingEquiv.subsemiringMap
-/

end RingEquiv

/-! ### Actions by `subsemiring`s

These are just copies of the definitions about `submonoid` starting from `submonoid.mul_action`.
The only new result is `subsemiring.module`.

When `R` is commutative, `algebra.of_subsemiring` provides a stronger result than those found in
this file, which uses the same scalar action.
-/


section Actions

namespace Subsemiring

variable {R' α β : Type _}

section NonAssocSemiring

variable [NonAssocSemiring R']

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [SMul R' α] (S : Subsemiring R') : SMul S α :=
  S.toSubmonoid.SMul

#print Subsemiring.smul_def /-
theorem smul_def [SMul R' α] {S : Subsemiring R'} (g : S) (m : α) : g • m = (g : R') • m :=
  rfl
#align subsemiring.smul_def Subsemiring.smul_def
-/

#print Subsemiring.smulCommClass_left /-
instance smulCommClass_left [SMul R' β] [SMul α β] [SMulCommClass R' α β] (S : Subsemiring R') :
    SMulCommClass S α β :=
  S.toSubmonoid.smulCommClass_left
#align subsemiring.smul_comm_class_left Subsemiring.smulCommClass_left
-/

#print Subsemiring.smulCommClass_right /-
instance smulCommClass_right [SMul α β] [SMul R' β] [SMulCommClass α R' β] (S : Subsemiring R') :
    SMulCommClass α S β :=
  S.toSubmonoid.smulCommClass_right
#align subsemiring.smul_comm_class_right Subsemiring.smulCommClass_right
-/

/-- Note that this provides `is_scalar_tower S R R` which is needed by `smul_mul_assoc`. -/
instance [SMul α β] [SMul R' α] [SMul R' β] [IsScalarTower R' α β] (S : Subsemiring R') :
    IsScalarTower S α β :=
  S.toSubmonoid.IsScalarTower

instance [SMul R' α] [FaithfulSMul R' α] (S : Subsemiring R') : FaithfulSMul S α :=
  S.toSubmonoid.FaithfulSMul

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [Zero α] [SMulWithZero R' α] (S : Subsemiring R') : SMulWithZero S α :=
  SMulWithZero.compHom _ S.Subtype.toMonoidWithZeroHom.toZeroHom

end NonAssocSemiring

variable [Semiring R']

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [MulAction R' α] (S : Subsemiring R') : MulAction S α :=
  S.toSubmonoid.MulAction

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [AddMonoid α] [DistribMulAction R' α] (S : Subsemiring R') : DistribMulAction S α :=
  S.toSubmonoid.DistribMulAction

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [Monoid α] [MulDistribMulAction R' α] (S : Subsemiring R') : MulDistribMulAction S α :=
  S.toSubmonoid.MulDistribMulAction

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [Zero α] [MulActionWithZero R' α] (S : Subsemiring R') : MulActionWithZero S α :=
  MulActionWithZero.compHom _ S.Subtype.toMonoidWithZeroHom

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [AddCommMonoid α] [Module R' α] (S : Subsemiring R') : Module S α :=
  { Module.compHom _ S.Subtype with smul := (· • ·) }

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [Semiring α] [MulSemiringAction R' α] (S : Subsemiring R') : MulSemiringAction S α :=
  S.toSubmonoid.MulSemiringAction

#print Subsemiring.center.sMulCommClass_left /-
/-- The center of a semiring acts commutatively on that semiring. -/
instance center.sMulCommClass_left : SMulCommClass (center R') R' R' :=
  Submonoid.center.smulCommClass_left
#align subsemiring.center.smul_comm_class_left Subsemiring.center.sMulCommClass_left
-/

#print Subsemiring.center.sMulCommClass_right /-
/-- The center of a semiring acts commutatively on that semiring. -/
instance center.sMulCommClass_right : SMulCommClass R' (center R') R' :=
  Submonoid.center.smulCommClass_right
#align subsemiring.center.smul_comm_class_right Subsemiring.center.sMulCommClass_right
-/

#print Subsemiring.closureCommSemiringOfComm /-
/-- If all the elements of a set `s` commute, then `closure s` is a commutative monoid. -/
def closureCommSemiringOfComm {s : Set R'} (hcomm : ∀ a ∈ s, ∀ b ∈ s, a * b = b * a) :
    CommSemiring (closure s) :=
  { (closure s).toSemiring with
    mul_comm := fun x y => by
      ext
      simp only [Subsemiring.coe_mul]
      refine'
        closure_induction₂ x.prop y.prop hcomm (fun x => by simp only [zero_mul, mul_zero])
          (fun x => by simp only [zero_mul, mul_zero]) (fun x => by simp only [one_mul, mul_one])
          (fun x => by simp only [one_mul, mul_one])
          (fun x y z h₁ h₂ => by simp only [add_mul, mul_add, h₁, h₂])
          (fun x y z h₁ h₂ => by simp only [add_mul, mul_add, h₁, h₂])
          (fun x y z h₁ h₂ => by rw [mul_assoc, h₂, ← mul_assoc, h₁, mul_assoc]) fun x y z h₁ h₂ =>
          by rw [← mul_assoc, h₁, mul_assoc, h₂, ← mul_assoc] }
#align subsemiring.closure_comm_semiring_of_comm Subsemiring.closureCommSemiringOfComm
-/

end Subsemiring

end Actions

#print posSubmonoid /-
-- While this definition is not about `subsemiring`s, this is the earliest we have
-- both `strict_ordered_semiring` and `submonoid` available.
/-- Submonoid of positive elements of an ordered semiring. -/
def posSubmonoid (R : Type _) [StrictOrderedSemiring R] : Submonoid R
    where
  carrier := { x | 0 < x }
  one_mem' := show (0 : R) < 1 from zero_lt_one
  mul_mem' x y (hx : 0 < x) (hy : 0 < y) := mul_pos hx hy
#align pos_submonoid posSubmonoid
-/

#print mem_posSubmonoid /-
@[simp]
theorem mem_posSubmonoid {R : Type _} [StrictOrderedSemiring R] (u : Rˣ) :
    ↑u ∈ posSubmonoid R ↔ (0 : R) < u :=
  Iff.rfl
#align mem_pos_monoid mem_posSubmonoid
-/

