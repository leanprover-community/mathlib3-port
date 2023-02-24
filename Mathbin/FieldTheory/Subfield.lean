/-
Copyright (c) 2020 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anne Baanen

! This file was ported from Lean 3 source module field_theory.subfield
! leanprover-community/mathlib commit 3dadefa3f544b1db6214777fe47910739b54c66a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Algebra.Basic
import Mathbin.Algebra.Order.Field.InjSurj

/-!
# Subfields

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Let `K` be a field. This file defines the "bundled" subfield type `subfield K`, a type
whose terms correspond to subfields of `K`. This is the preferred way to talk
about subfields in mathlib. Unbundled subfields (`s : set K` and `is_subfield s`)
are not in this file, and they will ultimately be deprecated.

We prove that subfields are a complete lattice, and that you can `map` (pushforward) and
`comap` (pull back) them along ring homomorphisms.

We define the `closure` construction from `set R` to `subfield R`, sending a subset of `R`
to the subfield it generates, and prove that it is a Galois insertion.

## Main definitions

Notation used here:

`(K : Type u) [field K] (L : Type u) [field L] (f g : K →+* L)`
`(A : subfield K) (B : subfield L) (s : set K)`

* `subfield R` : the type of subfields of a ring `R`.

* `instance : complete_lattice (subfield R)` : the complete lattice structure on the subfields.

* `subfield.closure` : subfield closure of a set, i.e., the smallest subfield that includes the set.

* `subfield.gi` : `closure : set M → subfield M` and coercion `coe : subfield M → set M`
  form a `galois_insertion`.

* `comap f B : subfield K` : the preimage of a subfield `B` along the ring homomorphism `f`

* `map f A : subfield L` : the image of a subfield `A` along the ring homomorphism `f`.

* `prod A B : subfield (K × L)` : the product of subfields

* `f.field_range : subfield B` : the range of the ring homomorphism `f`.

* `eq_locus_field f g : subfield K` : given ring homomorphisms `f g : K →+* R`,
     the subfield of `K` where `f x = g x`

## Implementation notes

A subfield is implemented as a subring which is is closed under `⁻¹`.

Lattice inclusion (e.g. `≤` and `⊓`) is used rather than set notation (`⊆` and `∩`), although
`∈` is defined as membership of a subfield's underlying set.

## Tags
subfield, subfields
-/


open BigOperators

universe u v w

variable {K : Type u} {L : Type v} {M : Type w} [Field K] [Field L] [Field M]

#print SubfieldClass /-
/-- `subfield_class S K` states `S` is a type of subsets `s ⊆ K` closed under field operations. -/
class SubfieldClass (S K : Type _) [Field K] [SetLike S K] extends SubringClass S K,
  InvMemClass S K : Prop
#align subfield_class SubfieldClass
-/

namespace SubfieldClass

variable (S : Type _) [SetLike S K] [h : SubfieldClass S K]

include h

#print SubfieldClass.toSubgroupClass /-
-- See note [lower instance priority]
/-- A subfield contains `1`, products and inverses.

Be assured that we're not actually proving that subfields are subgroups:
`subgroup_class` is really an abbreviation of `subgroup_with_or_without_zero_class`.
 -/
instance (priority := 100) SubfieldClass.toSubgroupClass : SubgroupClass S K :=
  { h with }
#align subfield_class.subfield_class.to_subgroup_class SubfieldClass.toSubgroupClass
-/

variable {S}

/- warning: subfield_class.coe_rat_mem -> SubfieldClass.coe_rat_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {S : Type.{u2}} [_inst_4 : SetLike.{u2, u1} S K] [h : SubfieldClass.{u2, u1} S K _inst_1 _inst_4] (s : S) (x : Rat), Membership.Mem.{u1, u2} K S (SetLike.hasMem.{u2, u1} S K _inst_4) ((fun (a : Type) (b : Type.{u1}) [self : HasLiftT.{1, succ u1} a b] => self.0) Rat K (HasLiftT.mk.{1, succ u1} Rat K (CoeTCₓ.coe.{1, succ u1} Rat K (Rat.castCoe.{u1} K (DivisionRing.toHasRatCast.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) x) s
but is expected to have type
  forall {K : Type.{u2}} [_inst_1 : Field.{u2} K] {S : Type.{u1}} [_inst_4 : SetLike.{u1, u2} S K] [h : SubfieldClass.{u1, u2} S K _inst_1 _inst_4] (s : S) (x : Rat), Membership.mem.{u2, u1} K S (SetLike.instMembership.{u1, u2} S K _inst_4) (RatCast.ratCast.{u2} K (Field.toRatCast.{u2} K _inst_1) x) s
Case conversion may be inaccurate. Consider using '#align subfield_class.coe_rat_mem SubfieldClass.coe_rat_memₓ'. -/
theorem coe_rat_mem (s : S) (x : ℚ) : (x : K) ∈ s := by
  simpa only [Rat.cast_def] using div_mem (coe_int_mem s x.num) (coe_nat_mem s x.denom)
#align subfield_class.coe_rat_mem SubfieldClass.coe_rat_mem

instance (s : S) : RatCast s :=
  ⟨fun x => ⟨↑x, coe_rat_mem s x⟩⟩

/- warning: subfield_class.coe_rat_cast -> SubfieldClass.coe_rat_cast is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {S : Type.{u2}} [_inst_4 : SetLike.{u2, u1} S K] [h : SubfieldClass.{u2, u1} S K _inst_1 _inst_4] (s : S) (x : Rat), Eq.{succ u1} K ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u2} K S (SetLike.hasMem.{u2, u1} S K _inst_4) x s))))) ((fun (a : Type) (b : Type.{u1}) [self : HasLiftT.{1, succ u1} a b] => self.0) Rat (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) (HasLiftT.mk.{1, succ u1} Rat (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) (CoeTCₓ.coe.{1, succ u1} Rat (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) (Rat.castCoe.{u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) (SubfieldClass.hasRatCast.{u1, u2} K _inst_1 S _inst_4 h s)))) x)) ((fun (a : Type) (b : Type.{u1}) [self : HasLiftT.{1, succ u1} a b] => self.0) Rat K (HasLiftT.mk.{1, succ u1} Rat K (CoeTCₓ.coe.{1, succ u1} Rat K (Rat.castCoe.{u1} K (DivisionRing.toHasRatCast.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) x)
but is expected to have type
  forall {K : Type.{u2}} [_inst_1 : Field.{u2} K] {S : Type.{u1}} [_inst_4 : SetLike.{u1, u2} S K] [h : SubfieldClass.{u1, u2} S K _inst_1 _inst_4] (s : S) (x : Rat), Eq.{succ u2} K (Subtype.val.{succ u2} K (fun (x : K) => Membership.mem.{u2, u2} K (Set.{u2} K) (Set.instMembershipSet.{u2} K) x (SetLike.coe.{u1, u2} S K _inst_4 s)) (RatCast.ratCast.{u2} (Subtype.{succ u2} K (fun (x : K) => Membership.mem.{u2, u1} K S (SetLike.instMembership.{u1, u2} S K _inst_4) x s)) (SubfieldClass.instRatCastSubtypeMemInstMembership.{u2, u1} K _inst_1 S _inst_4 h s) x)) (RatCast.ratCast.{u2} K (Field.toRatCast.{u2} K _inst_1) x)
Case conversion may be inaccurate. Consider using '#align subfield_class.coe_rat_cast SubfieldClass.coe_rat_castₓ'. -/
@[simp]
theorem coe_rat_cast (s : S) (x : ℚ) : ((x : s) : K) = x :=
  rfl
#align subfield_class.coe_rat_cast SubfieldClass.coe_rat_cast

/- warning: subfield_class.rat_smul_mem -> SubfieldClass.rat_smul_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {S : Type.{u2}} [_inst_4 : SetLike.{u2, u1} S K] [h : SubfieldClass.{u2, u1} S K _inst_1 _inst_4] (s : S) (a : Rat) (x : coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s), Membership.Mem.{u1, u2} K S (SetLike.hasMem.{u2, u1} S K _inst_4) (SMul.smul.{0, u1} Rat K (Rat.smulDivisionRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) a ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u2} K S (SetLike.hasMem.{u2, u1} S K _inst_4) x s))))) x)) s
but is expected to have type
  forall {K : Type.{u2}} [_inst_1 : Field.{u2} K] {S : Type.{u1}} [_inst_4 : SetLike.{u1, u2} S K] [h : SubfieldClass.{u1, u2} S K _inst_1 _inst_4] (s : S) (a : Rat) (x : Subtype.{succ u2} K (fun (x : K) => Membership.mem.{u2, u1} K S (SetLike.instMembership.{u1, u2} S K _inst_4) x s)), Membership.mem.{u2, u1} K S (SetLike.instMembership.{u1, u2} S K _inst_4) (HSMul.hSMul.{0, u2, u2} Rat K K (instHSMul.{0, u2} Rat K (SMulZeroClass.toSMul.{0, u2} Rat K (CommMonoidWithZero.toZero.{u2} K (CommGroupWithZero.toCommMonoidWithZero.{u2} K (Semifield.toCommGroupWithZero.{u2} K (Field.toSemifield.{u2} K _inst_1)))) (DistribSMul.toSMulZeroClass.{0, u2} Rat K (AddMonoid.toAddZeroClass.{u2} K (AddMonoidWithOne.toAddMonoid.{u2} K (AddGroupWithOne.toAddMonoidWithOne.{u2} K (Ring.toAddGroupWithOne.{u2} K (DivisionRing.toRing.{u2} K (Field.toDivisionRing.{u2} K _inst_1)))))) (Rat.distribSMul.{u2} K (Field.toDivisionRing.{u2} K _inst_1))))) a (Subtype.val.{succ u2} K (fun (x : K) => Membership.mem.{u2, u2} K (Set.{u2} K) (Set.instMembershipSet.{u2} K) x (SetLike.coe.{u1, u2} S K _inst_4 s)) x)) s
Case conversion may be inaccurate. Consider using '#align subfield_class.rat_smul_mem SubfieldClass.rat_smul_memₓ'. -/
theorem rat_smul_mem (s : S) (a : ℚ) (x : s) : (a • x : K) ∈ s := by
  simpa only [Rat.smul_def] using mul_mem (coe_rat_mem s a) x.prop
#align subfield_class.rat_smul_mem SubfieldClass.rat_smul_mem

instance (s : S) : SMul ℚ s :=
  ⟨fun a x => ⟨a • x, rat_smul_mem s a x⟩⟩

/- warning: subfield_class.coe_rat_smul -> SubfieldClass.coe_rat_smul is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {S : Type.{u2}} [_inst_4 : SetLike.{u2, u1} S K] [h : SubfieldClass.{u2, u1} S K _inst_1 _inst_4] (s : S) (a : Rat) (x : coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s), Eq.{succ u1} K ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u2} K S (SetLike.hasMem.{u2, u1} S K _inst_4) x s))))) (SMul.smul.{0, u1} Rat (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) (SubfieldClass.hasSmul.{u1, u2} K _inst_1 S _inst_4 h s) a x)) (SMul.smul.{0, u1} Rat K (Rat.smulDivisionRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) a ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u2, succ (succ u1)} S Type.{u1} (SetLike.hasCoeToSort.{u2, u1} S K _inst_4) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u2} K S (SetLike.hasMem.{u2, u1} S K _inst_4) x s))))) x))
but is expected to have type
  forall {K : Type.{u2}} [_inst_1 : Field.{u2} K] {S : Type.{u1}} [_inst_4 : SetLike.{u1, u2} S K] [h : SubfieldClass.{u1, u2} S K _inst_1 _inst_4] (s : S) (a : Rat) (x : Subtype.{succ u2} K (fun (x : K) => Membership.mem.{u2, u1} K S (SetLike.instMembership.{u1, u2} S K _inst_4) x s)), Eq.{succ u2} K (Subtype.val.{succ u2} K (fun (x : K) => Membership.mem.{u2, u2} K (Set.{u2} K) (Set.instMembershipSet.{u2} K) x (SetLike.coe.{u1, u2} S K _inst_4 s)) (HSMul.hSMul.{0, u2, u2} Rat (Subtype.{succ u2} K (fun (x : K) => Membership.mem.{u2, u1} K S (SetLike.instMembership.{u1, u2} S K _inst_4) x s)) (Subtype.{succ u2} K (fun (x : K) => Membership.mem.{u2, u1} K S (SetLike.instMembership.{u1, u2} S K _inst_4) x s)) (instHSMul.{0, u2} Rat (Subtype.{succ u2} K (fun (x : K) => Membership.mem.{u2, u1} K S (SetLike.instMembership.{u1, u2} S K _inst_4) x s)) (SubfieldClass.instSMulRatSubtypeMemInstMembership.{u2, u1} K _inst_1 S _inst_4 h s)) a x)) (HSMul.hSMul.{0, u2, u2} Rat K K (instHSMul.{0, u2} Rat K (SMulZeroClass.toSMul.{0, u2} Rat K (CommMonoidWithZero.toZero.{u2} K (CommGroupWithZero.toCommMonoidWithZero.{u2} K (Semifield.toCommGroupWithZero.{u2} K (Field.toSemifield.{u2} K _inst_1)))) (DistribSMul.toSMulZeroClass.{0, u2} Rat K (AddMonoid.toAddZeroClass.{u2} K (AddMonoidWithOne.toAddMonoid.{u2} K (AddGroupWithOne.toAddMonoidWithOne.{u2} K (Ring.toAddGroupWithOne.{u2} K (DivisionRing.toRing.{u2} K (Field.toDivisionRing.{u2} K _inst_1)))))) (Rat.distribSMul.{u2} K (Field.toDivisionRing.{u2} K _inst_1))))) a (Subtype.val.{succ u2} K (fun (x : K) => Membership.mem.{u2, u2} K (Set.{u2} K) (Set.instMembershipSet.{u2} K) x (SetLike.coe.{u1, u2} S K _inst_4 s)) x))
Case conversion may be inaccurate. Consider using '#align subfield_class.coe_rat_smul SubfieldClass.coe_rat_smulₓ'. -/
@[simp]
theorem coe_rat_smul (s : S) (a : ℚ) (x : s) : (↑(a • x) : K) = a • x :=
  rfl
#align subfield_class.coe_rat_smul SubfieldClass.coe_rat_smul

variable (S)

#print SubfieldClass.toField /-
-- Prefer subclasses of `field` over subclasses of `subfield_class`.
/-- A subfield inherits a field structure -/
instance (priority := 75) toField (s : S) : Field s :=
  Subtype.coe_injective.Field (coe : s → K) rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl)
    (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) (fun _ => rfl) fun _ => rfl
#align subfield_class.to_field SubfieldClass.toField
-/

omit h

#print SubfieldClass.toLinearOrderedField /-
-- Prefer subclasses of `field` over subclasses of `subfield_class`.
/-- A subfield of a `linear_ordered_field` is a `linear_ordered_field`. -/
instance (priority := 75) toLinearOrderedField {K} [LinearOrderedField K] [SetLike S K]
    [SubfieldClass S K] (s : S) : LinearOrderedField s :=
  Subtype.coe_injective.LinearOrderedField coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ => rfl) (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl)
    (fun _ => rfl) (fun _ => rfl) (fun _ _ => rfl) fun _ _ => rfl
#align subfield_class.to_linear_ordered_field SubfieldClass.toLinearOrderedField
-/

end SubfieldClass

#print Subfield /-
/-- `subfield R` is the type of subfields of `R`. A subfield of `R` is a subset `s` that is a
  multiplicative submonoid and an additive subgroup. Note in particular that it shares the
  same 0 and 1 as R. -/
structure Subfield (K : Type u) [Field K] extends Subring K where
  inv_mem' : ∀ x ∈ carrier, x⁻¹ ∈ carrier
#align subfield Subfield
-/

/-- Reinterpret a `subfield` as a `subring`. -/
add_decl_doc Subfield.toSubring

namespace Subfield

#print Subfield.toAddSubgroup /-
/-- The underlying `add_subgroup` of a subfield. -/
def toAddSubgroup (s : Subfield K) : AddSubgroup K :=
  { s.toSubring.toAddSubgroup with }
#align subfield.to_add_subgroup Subfield.toAddSubgroup
-/

/-- The underlying submonoid of a subfield. -/
def toSubmonoid (s : Subfield K) : Submonoid K :=
  { s.toSubring.toSubmonoid with }
#align subfield.to_submonoid Subfield.toSubmonoid

instance : SetLike (Subfield K) K :=
  ⟨Subfield.carrier, fun p q h => by cases p <;> cases q <;> congr ⟩

instance : SubfieldClass (Subfield K) K
    where
  add_mem := add_mem'
  zero_mem := zero_mem'
  neg_mem := neg_mem'
  mul_mem := mul_mem'
  one_mem := one_mem'
  inv_mem := inv_mem'

/- warning: subfield.mem_carrier -> Subfield.mem_carrier is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Subfield.{u1} K _inst_1} {x : K}, Iff (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) x (Subfield.carrier.{u1} K _inst_1 s)) (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Subfield.{u1} K _inst_1} {x : K}, Iff (Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (Subsemigroup.carrier.{u1} K (MulOneClass.toMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Submonoid.toSubsemigroup.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subsemiring.toSubmonoid.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 s)))))) (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)
Case conversion may be inaccurate. Consider using '#align subfield.mem_carrier Subfield.mem_carrierₓ'. -/
@[simp]
theorem mem_carrier {s : Subfield K} {x : K} : x ∈ s.carrier ↔ x ∈ s :=
  Iff.rfl
#align subfield.mem_carrier Subfield.mem_carrier

/- warning: subfield.mem_mk -> Subfield.mem_mk is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {S : Set.{u1} K} {x : K} (h₁ : forall {a : K} {b : K}, (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) a S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) b S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (HMul.hMul.{u1, u1, u1} K K K (instHMul.{u1} K (MulOneClass.toHasMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))) a b) S)) (h₂ : Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (OfNat.ofNat.{u1} K 1 (OfNat.mk.{u1} K 1 (One.one.{u1} K (MulOneClass.toHasOne.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))))) S) (h₃ : forall {a : K} {b : K}, (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) a S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) b S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (HAdd.hAdd.{u1, u1, u1} K K K (instHAdd.{u1} K (AddZeroClass.toHasAdd.{u1} K (AddMonoid.toAddZeroClass.{u1} K (AddMonoidWithOne.toAddMonoid.{u1} K (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} K (NonAssocSemiring.toAddCommMonoidWithOne.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))))) a b) S)) (h₄ : Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (AddZeroClass.toHasZero.{u1} K (AddMonoid.toAddZeroClass.{u1} K (AddMonoidWithOne.toAddMonoid.{u1} K (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} K (NonAssocSemiring.toAddCommMonoidWithOne.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))))))) S) (h₅ : forall {x : K}, (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) x S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (Neg.neg.{u1} K (SubNegMonoid.toHasNeg.{u1} K (AddGroup.toSubNegMonoid.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) x) S)) (h₆ : forall (x : K), (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) x S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (Inv.inv.{u1} K (DivInvMonoid.toHasInv.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) x) S)), Iff (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x (Subfield.mk.{u1} K _inst_1 S h₁ h₂ h₃ h₄ h₅ h₆)) (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) x S)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {S : Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))} {x : K} (h₁ : forall (a : K), (Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) a (Subsemigroup.carrier.{u1} K (MulOneClass.toMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Submonoid.toSubsemigroup.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subsemiring.toSubmonoid.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) S))))) -> (Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) (Inv.inv.{u1} K (Field.toInv.{u1} K _inst_1) a) (Subsemigroup.carrier.{u1} K (MulOneClass.toMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Submonoid.toSubsemigroup.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subsemiring.toSubmonoid.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) S)))))), Iff (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x (Subfield.mk.{u1} K _inst_1 S h₁)) (Membership.mem.{u1, u1} K (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (SetLike.instMembership.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.instSetLikeSubring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) x S)
Case conversion may be inaccurate. Consider using '#align subfield.mem_mk Subfield.mem_mkₓ'. -/
@[simp]
theorem mem_mk {S : Set K} {x : K} (h₁ h₂ h₃ h₄ h₅ h₆) :
    x ∈ (⟨S, h₁, h₂, h₃, h₄, h₅, h₆⟩ : Subfield K) ↔ x ∈ S :=
  Iff.rfl
#align subfield.mem_mk Subfield.mem_mk

/- warning: subfield.coe_set_mk -> Subfield.coe_set_mk is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (S : Set.{u1} K) (h₁ : forall {a : K} {b : K}, (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) a S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) b S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (HMul.hMul.{u1, u1, u1} K K K (instHMul.{u1} K (MulOneClass.toHasMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))) a b) S)) (h₂ : Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (OfNat.ofNat.{u1} K 1 (OfNat.mk.{u1} K 1 (One.one.{u1} K (MulOneClass.toHasOne.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))))) S) (h₃ : forall {a : K} {b : K}, (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) a S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) b S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (HAdd.hAdd.{u1, u1, u1} K K K (instHAdd.{u1} K (AddZeroClass.toHasAdd.{u1} K (AddMonoid.toAddZeroClass.{u1} K (AddMonoidWithOne.toAddMonoid.{u1} K (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} K (NonAssocSemiring.toAddCommMonoidWithOne.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))))) a b) S)) (h₄ : Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (AddZeroClass.toHasZero.{u1} K (AddMonoid.toAddZeroClass.{u1} K (AddMonoidWithOne.toAddMonoid.{u1} K (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} K (NonAssocSemiring.toAddCommMonoidWithOne.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))))))) S) (h₅ : forall {x : K}, (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) x S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (Neg.neg.{u1} K (SubNegMonoid.toHasNeg.{u1} K (AddGroup.toSubNegMonoid.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) x) S)) (h₆ : forall (x : K), (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) x S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (Inv.inv.{u1} K (DivInvMonoid.toHasInv.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) x) S)), Eq.{succ u1} (Set.{u1} K) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) (Subfield.mk.{u1} K _inst_1 S h₁ h₂ h₃ h₄ h₅ h₆)) S
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (S : Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (h₁ : forall (a : K), (Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) a (Subsemigroup.carrier.{u1} K (MulOneClass.toMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Submonoid.toSubsemigroup.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subsemiring.toSubmonoid.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) S))))) -> (Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) (Inv.inv.{u1} K (Field.toInv.{u1} K _inst_1) a) (Subsemigroup.carrier.{u1} K (MulOneClass.toMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Submonoid.toSubsemigroup.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subsemiring.toSubmonoid.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) S)))))), Eq.{succ u1} (Set.{u1} K) (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) (Subfield.mk.{u1} K _inst_1 S h₁)) (SetLike.coe.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.instSetLikeSubring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) S)
Case conversion may be inaccurate. Consider using '#align subfield.coe_set_mk Subfield.coe_set_mkₓ'. -/
@[simp]
theorem coe_set_mk (S : Set K) (h₁ h₂ h₃ h₄ h₅ h₆) :
    ((⟨S, h₁, h₂, h₃, h₄, h₅, h₆⟩ : Subfield K) : Set K) = S :=
  rfl
#align subfield.coe_set_mk Subfield.coe_set_mk

/- warning: subfield.mk_le_mk -> Subfield.mk_le_mk is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {S : Set.{u1} K} {S' : Set.{u1} K} (h₁ : forall {a : K} {b : K}, (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) a S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) b S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (HMul.hMul.{u1, u1, u1} K K K (instHMul.{u1} K (MulOneClass.toHasMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))) a b) S)) (h₂ : Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (OfNat.ofNat.{u1} K 1 (OfNat.mk.{u1} K 1 (One.one.{u1} K (MulOneClass.toHasOne.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))))) S) (h₃ : forall {a : K} {b : K}, (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) a S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) b S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (HAdd.hAdd.{u1, u1, u1} K K K (instHAdd.{u1} K (AddZeroClass.toHasAdd.{u1} K (AddMonoid.toAddZeroClass.{u1} K (AddMonoidWithOne.toAddMonoid.{u1} K (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} K (NonAssocSemiring.toAddCommMonoidWithOne.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))))) a b) S)) (h₄ : Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (AddZeroClass.toHasZero.{u1} K (AddMonoid.toAddZeroClass.{u1} K (AddMonoidWithOne.toAddMonoid.{u1} K (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} K (NonAssocSemiring.toAddCommMonoidWithOne.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))))))) S) (h₅ : forall {x : K}, (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) x S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (Neg.neg.{u1} K (SubNegMonoid.toHasNeg.{u1} K (AddGroup.toSubNegMonoid.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) x) S)) (h₆ : forall (x : K), (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) x S) -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (Inv.inv.{u1} K (DivInvMonoid.toHasInv.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) x) S)) (h₁' : forall {a : K} {b : K}, (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) a S') -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) b S') -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (HMul.hMul.{u1, u1, u1} K K K (instHMul.{u1} K (MulOneClass.toHasMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))) a b) S')) (h₂' : Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (OfNat.ofNat.{u1} K 1 (OfNat.mk.{u1} K 1 (One.one.{u1} K (MulOneClass.toHasOne.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))))) S') (h₃' : forall {a : K} {b : K}, (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) a S') -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) b S') -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (HAdd.hAdd.{u1, u1, u1} K K K (instHAdd.{u1} K (AddZeroClass.toHasAdd.{u1} K (AddMonoid.toAddZeroClass.{u1} K (AddMonoidWithOne.toAddMonoid.{u1} K (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} K (NonAssocSemiring.toAddCommMonoidWithOne.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))))) a b) S')) (h₄' : Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (AddZeroClass.toHasZero.{u1} K (AddMonoid.toAddZeroClass.{u1} K (AddMonoidWithOne.toAddMonoid.{u1} K (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} K (NonAssocSemiring.toAddCommMonoidWithOne.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))))))) S') (h₅' : forall {x : K}, (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) x S') -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (Neg.neg.{u1} K (SubNegMonoid.toHasNeg.{u1} K (AddGroup.toSubNegMonoid.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) x) S')) (h₆' : forall (x : K), (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) x S') -> (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) (Inv.inv.{u1} K (DivInvMonoid.toHasInv.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) x) S')), Iff (LE.le.{u1} (Subfield.{u1} K _inst_1) (Preorder.toLE.{u1} (Subfield.{u1} K _inst_1) (PartialOrder.toPreorder.{u1} (Subfield.{u1} K _inst_1) (SetLike.partialOrder.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) (Subfield.mk.{u1} K _inst_1 S h₁ h₂ h₃ h₄ h₅ h₆) (Subfield.mk.{u1} K _inst_1 S' h₁' h₂' h₃' h₄' h₅' h₆')) (HasSubset.Subset.{u1} (Set.{u1} K) (Set.hasSubset.{u1} K) S S')
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {S : Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))} {S' : Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))} (h₁ : forall (a : K), (Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) a (Subsemigroup.carrier.{u1} K (MulOneClass.toMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Submonoid.toSubsemigroup.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subsemiring.toSubmonoid.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) S))))) -> (Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) (Inv.inv.{u1} K (Field.toInv.{u1} K _inst_1) a) (Subsemigroup.carrier.{u1} K (MulOneClass.toMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Submonoid.toSubsemigroup.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subsemiring.toSubmonoid.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) S)))))) (h₂ : forall (x : K), (Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (Subsemigroup.carrier.{u1} K (MulOneClass.toMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Submonoid.toSubsemigroup.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subsemiring.toSubmonoid.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) S'))))) -> (Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) (Inv.inv.{u1} K (Field.toInv.{u1} K _inst_1) x) (Subsemigroup.carrier.{u1} K (MulOneClass.toMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Submonoid.toSubsemigroup.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subsemiring.toSubmonoid.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) S')))))), Iff (LE.le.{u1} (Subfield.{u1} K _inst_1) (Preorder.toLE.{u1} (Subfield.{u1} K _inst_1) (PartialOrder.toPreorder.{u1} (Subfield.{u1} K _inst_1) (SetLike.instPartialOrder.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)))) (Subfield.mk.{u1} K _inst_1 S h₁) (Subfield.mk.{u1} K _inst_1 S' h₂)) (LE.le.{u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (Preorder.toLE.{u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (PartialOrder.toPreorder.{u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (Subring.instCompleteLatticeSubring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) S S')
Case conversion may be inaccurate. Consider using '#align subfield.mk_le_mk Subfield.mk_le_mkₓ'. -/
@[simp]
theorem mk_le_mk {S S' : Set K} (h₁ h₂ h₃ h₄ h₅ h₆ h₁' h₂' h₃' h₄' h₅' h₆') :
    (⟨S, h₁, h₂, h₃, h₄, h₅, h₆⟩ : Subfield K) ≤ (⟨S', h₁', h₂', h₃', h₄', h₅', h₆'⟩ : Subfield K) ↔
      S ⊆ S' :=
  Iff.rfl
#align subfield.mk_le_mk Subfield.mk_le_mk

/- warning: subfield.ext -> Subfield.ext is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {S : Subfield.{u1} K _inst_1} {T : Subfield.{u1} K _inst_1}, (forall (x : K), Iff (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x S) (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x T)) -> (Eq.{succ u1} (Subfield.{u1} K _inst_1) S T)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {S : Subfield.{u1} K _inst_1} {T : Subfield.{u1} K _inst_1}, (forall (x : K), Iff (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x S) (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x T)) -> (Eq.{succ u1} (Subfield.{u1} K _inst_1) S T)
Case conversion may be inaccurate. Consider using '#align subfield.ext Subfield.extₓ'. -/
/-- Two subfields are equal if they have the same elements. -/
@[ext]
theorem ext {S T : Subfield K} (h : ∀ x, x ∈ S ↔ x ∈ T) : S = T :=
  SetLike.ext h
#align subfield.ext Subfield.ext

/- warning: subfield.copy -> Subfield.copy is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (S : Subfield.{u1} K _inst_1) (s : Set.{u1} K), (Eq.{succ u1} (Set.{u1} K) s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) S)) -> (Subfield.{u1} K _inst_1)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (S : Subfield.{u1} K _inst_1) (s : Set.{u1} K), (Eq.{succ u1} (Set.{u1} K) s (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) S)) -> (Subfield.{u1} K _inst_1)
Case conversion may be inaccurate. Consider using '#align subfield.copy Subfield.copyₓ'. -/
/-- Copy of a subfield with a new `carrier` equal to the old one. Useful to fix definitional
equalities. -/
protected def copy (S : Subfield K) (s : Set K) (hs : s = ↑S) : Subfield K :=
  { S.toSubring.copy s hs with
    carrier := s
    inv_mem' := hs.symm ▸ S.inv_mem' }
#align subfield.copy Subfield.copy

/- warning: subfield.coe_copy -> Subfield.coe_copy is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (S : Subfield.{u1} K _inst_1) (s : Set.{u1} K) (hs : Eq.{succ u1} (Set.{u1} K) s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) S)), Eq.{succ u1} (Set.{u1} K) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) (Subfield.copy.{u1} K _inst_1 S s hs)) s
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (S : Subfield.{u1} K _inst_1) (s : Set.{u1} K) (hs : Eq.{succ u1} (Set.{u1} K) s (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) S)), Eq.{succ u1} (Set.{u1} K) (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) (Subfield.copy.{u1} K _inst_1 S s hs)) s
Case conversion may be inaccurate. Consider using '#align subfield.coe_copy Subfield.coe_copyₓ'. -/
@[simp]
theorem coe_copy (S : Subfield K) (s : Set K) (hs : s = ↑S) : (S.copy s hs : Set K) = s :=
  rfl
#align subfield.coe_copy Subfield.coe_copy

/- warning: subfield.copy_eq -> Subfield.copy_eq is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (S : Subfield.{u1} K _inst_1) (s : Set.{u1} K) (hs : Eq.{succ u1} (Set.{u1} K) s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) S)), Eq.{succ u1} (Subfield.{u1} K _inst_1) (Subfield.copy.{u1} K _inst_1 S s hs) S
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (S : Subfield.{u1} K _inst_1) (s : Set.{u1} K) (hs : Eq.{succ u1} (Set.{u1} K) s (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) S)), Eq.{succ u1} (Subfield.{u1} K _inst_1) (Subfield.copy.{u1} K _inst_1 S s hs) S
Case conversion may be inaccurate. Consider using '#align subfield.copy_eq Subfield.copy_eqₓ'. -/
theorem copy_eq (S : Subfield K) (s : Set K) (hs : s = ↑S) : S.copy s hs = S :=
  SetLike.coe_injective hs
#align subfield.copy_eq Subfield.copy_eq

/- warning: subfield.coe_to_subring -> Subfield.coe_toSubring is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Eq.{succ u1} (Set.{u1} K) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.setLike.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subfield.toSubring.{u1} K _inst_1 s)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Eq.{succ u1} (Set.{u1} K) (SetLike.coe.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.instSetLikeSubring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (Subfield.toSubring.{u1} K _inst_1 s)) (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)
Case conversion may be inaccurate. Consider using '#align subfield.coe_to_subring Subfield.coe_toSubringₓ'. -/
@[simp]
theorem coe_toSubring (s : Subfield K) : (s.toSubring : Set K) = s :=
  rfl
#align subfield.coe_to_subring Subfield.coe_toSubring

/- warning: subfield.mem_to_subring -> Subfield.mem_toSubring is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (x : K), Iff (Membership.Mem.{u1, u1} K (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (SetLike.hasMem.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.setLike.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) x (Subfield.toSubring.{u1} K _inst_1 s)) (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (x : K), Iff (Membership.mem.{u1, u1} K (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (SetLike.instMembership.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.instSetLikeSubring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) x (Subfield.toSubring.{u1} K _inst_1 s)) (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)
Case conversion may be inaccurate. Consider using '#align subfield.mem_to_subring Subfield.mem_toSubringₓ'. -/
@[simp]
theorem mem_toSubring (s : Subfield K) (x : K) : x ∈ s.toSubring ↔ x ∈ s :=
  Iff.rfl
#align subfield.mem_to_subring Subfield.mem_toSubring

end Subfield

/- warning: subring.to_subfield -> Subring.toSubfield is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))), (forall (x : K), (Membership.Mem.{u1, u1} K (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (SetLike.hasMem.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.setLike.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) x s) -> (Membership.Mem.{u1, u1} K (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (SetLike.hasMem.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.setLike.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Inv.inv.{u1} K (DivInvMonoid.toHasInv.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) x) s)) -> (Subfield.{u1} K _inst_1)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))), (forall (x : K), (Membership.mem.{u1, u1} K (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (SetLike.instMembership.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.instSetLikeSubring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) x s) -> (Membership.mem.{u1, u1} K (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (SetLike.instMembership.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.instSetLikeSubring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Inv.inv.{u1} K (Field.toInv.{u1} K _inst_1) x) s)) -> (Subfield.{u1} K _inst_1)
Case conversion may be inaccurate. Consider using '#align subring.to_subfield Subring.toSubfieldₓ'. -/
/-- A `subring` containing inverses is a `subfield`. -/
def Subring.toSubfield (s : Subring K) (hinv : ∀ x ∈ s, x⁻¹ ∈ s) : Subfield K :=
  { s with inv_mem' := hinv }
#align subring.to_subfield Subring.toSubfield

namespace Subfield

variable (s t : Subfield K)

section DerivedFromSubfieldClass

/- warning: subfield.one_mem -> Subfield.one_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (OfNat.ofNat.{u1} K 1 (OfNat.mk.{u1} K 1 (One.one.{u1} K (AddMonoidWithOne.toOne.{u1} K (AddGroupWithOne.toAddMonoidWithOne.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))))) s
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (OfNat.ofNat.{u1} K 1 (One.toOfNat1.{u1} K (NonAssocRing.toOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) s
Case conversion may be inaccurate. Consider using '#align subfield.one_mem Subfield.one_memₓ'. -/
/-- A subfield contains the field's 1. -/
protected theorem one_mem : (1 : K) ∈ s :=
  one_mem s
#align subfield.one_mem Subfield.one_mem

/- warning: subfield.zero_mem -> Subfield.zero_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))))) s
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (OfNat.ofNat.{u1} K 0 (Zero.toOfNat0.{u1} K (CommMonoidWithZero.toZero.{u1} K (CommGroupWithZero.toCommMonoidWithZero.{u1} K (Semifield.toCommGroupWithZero.{u1} K (Field.toSemifield.{u1} K _inst_1)))))) s
Case conversion may be inaccurate. Consider using '#align subfield.zero_mem Subfield.zero_memₓ'. -/
/-- A subfield contains the field's 0. -/
protected theorem zero_mem : (0 : K) ∈ s :=
  zero_mem s
#align subfield.zero_mem Subfield.zero_mem

/- warning: subfield.mul_mem -> Subfield.mul_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K} {y : K}, (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) y s) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (HMul.hMul.{u1, u1, u1} K K K (instHMul.{u1} K (Distrib.toHasMul.{u1} K (Ring.toDistrib.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) x y) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K} {y : K}, (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) y s) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (HMul.hMul.{u1, u1, u1} K K K (instHMul.{u1} K (NonUnitalNonAssocRing.toMul.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) x y) s)
Case conversion may be inaccurate. Consider using '#align subfield.mul_mem Subfield.mul_memₓ'. -/
/-- A subfield is closed under multiplication. -/
protected theorem mul_mem {x y : K} : x ∈ s → y ∈ s → x * y ∈ s :=
  mul_mem
#align subfield.mul_mem Subfield.mul_mem

/- warning: subfield.add_mem -> Subfield.add_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K} {y : K}, (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) y s) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (HAdd.hAdd.{u1, u1, u1} K K K (instHAdd.{u1} K (Distrib.toHasAdd.{u1} K (Ring.toDistrib.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) x y) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K} {y : K}, (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) y s) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (HAdd.hAdd.{u1, u1, u1} K K K (instHAdd.{u1} K (Distrib.toAdd.{u1} K (NonUnitalNonAssocSemiring.toDistrib.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))) x y) s)
Case conversion may be inaccurate. Consider using '#align subfield.add_mem Subfield.add_memₓ'. -/
/-- A subfield is closed under addition. -/
protected theorem add_mem {x y : K} : x ∈ s → y ∈ s → x + y ∈ s :=
  add_mem
#align subfield.add_mem Subfield.add_mem

/- warning: subfield.neg_mem -> Subfield.neg_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K}, (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (Neg.neg.{u1} K (SubNegMonoid.toHasNeg.{u1} K (AddGroup.toSubNegMonoid.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) x) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K}, (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (Neg.neg.{u1} K (Ring.toNeg.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) x) s)
Case conversion may be inaccurate. Consider using '#align subfield.neg_mem Subfield.neg_memₓ'. -/
/-- A subfield is closed under negation. -/
protected theorem neg_mem {x : K} : x ∈ s → -x ∈ s :=
  neg_mem
#align subfield.neg_mem Subfield.neg_mem

/- warning: subfield.sub_mem -> Subfield.sub_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K} {y : K}, (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) y s) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (HSub.hSub.{u1, u1, u1} K K K (instHSub.{u1} K (SubNegMonoid.toHasSub.{u1} K (AddGroup.toSubNegMonoid.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))) x y) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K} {y : K}, (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) y s) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (HSub.hSub.{u1, u1, u1} K K K (instHSub.{u1} K (Ring.toSub.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) x y) s)
Case conversion may be inaccurate. Consider using '#align subfield.sub_mem Subfield.sub_memₓ'. -/
/-- A subfield is closed under subtraction. -/
protected theorem sub_mem {x y : K} : x ∈ s → y ∈ s → x - y ∈ s :=
  sub_mem
#align subfield.sub_mem Subfield.sub_mem

/- warning: subfield.inv_mem -> Subfield.inv_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K}, (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (Inv.inv.{u1} K (DivInvMonoid.toHasInv.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) x) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K}, (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (Inv.inv.{u1} K (Field.toInv.{u1} K _inst_1) x) s)
Case conversion may be inaccurate. Consider using '#align subfield.inv_mem Subfield.inv_memₓ'. -/
/-- A subfield is closed under inverses. -/
protected theorem inv_mem {x : K} : x ∈ s → x⁻¹ ∈ s :=
  inv_mem
#align subfield.inv_mem Subfield.inv_mem

/- warning: subfield.div_mem -> Subfield.div_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K} {y : K}, (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) y s) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (HDiv.hDiv.{u1, u1, u1} K K K (instHDiv.{u1} K (DivInvMonoid.toHasDiv.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) x y) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K} {y : K}, (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) y s) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (HDiv.hDiv.{u1, u1, u1} K K K (instHDiv.{u1} K (Field.toDiv.{u1} K _inst_1)) x y) s)
Case conversion may be inaccurate. Consider using '#align subfield.div_mem Subfield.div_memₓ'. -/
/-- A subfield is closed under division. -/
protected theorem div_mem {x y : K} : x ∈ s → y ∈ s → x / y ∈ s :=
  div_mem
#align subfield.div_mem Subfield.div_mem

/- warning: subfield.list_prod_mem -> Subfield.list_prod_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {l : List.{u1} K}, (forall (x : K), (Membership.Mem.{u1, u1} K (List.{u1} K) (List.hasMem.{u1} K) x l) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s)) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (List.prod.{u1} K (Distrib.toHasMul.{u1} K (Ring.toDistrib.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (AddMonoidWithOne.toOne.{u1} K (AddGroupWithOne.toAddMonoidWithOne.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) l) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {l : List.{u1} K}, (forall (x : K), (Membership.mem.{u1, u1} K (List.{u1} K) (List.instMembershipList.{u1} K) x l) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (List.prod.{u1} K (NonUnitalNonAssocRing.toMul.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (NonAssocRing.toOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) l) s)
Case conversion may be inaccurate. Consider using '#align subfield.list_prod_mem Subfield.list_prod_memₓ'. -/
/-- Product of a list of elements in a subfield is in the subfield. -/
protected theorem list_prod_mem {l : List K} : (∀ x ∈ l, x ∈ s) → l.Prod ∈ s :=
  list_prod_mem
#align subfield.list_prod_mem Subfield.list_prod_mem

/- warning: subfield.list_sum_mem -> Subfield.list_sum_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {l : List.{u1} K}, (forall (x : K), (Membership.Mem.{u1, u1} K (List.{u1} K) (List.hasMem.{u1} K) x l) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s)) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (List.sum.{u1} K (Distrib.toHasAdd.{u1} K (Ring.toDistrib.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) l) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {l : List.{u1} K}, (forall (x : K), (Membership.mem.{u1, u1} K (List.{u1} K) (List.instMembershipList.{u1} K) x l) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (List.sum.{u1} K (Distrib.toAdd.{u1} K (NonUnitalNonAssocSemiring.toDistrib.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (CommMonoidWithZero.toZero.{u1} K (CommGroupWithZero.toCommMonoidWithZero.{u1} K (Semifield.toCommGroupWithZero.{u1} K (Field.toSemifield.{u1} K _inst_1)))) l) s)
Case conversion may be inaccurate. Consider using '#align subfield.list_sum_mem Subfield.list_sum_memₓ'. -/
/-- Sum of a list of elements in a subfield is in the subfield. -/
protected theorem list_sum_mem {l : List K} : (∀ x ∈ l, x ∈ s) → l.Sum ∈ s :=
  list_sum_mem
#align subfield.list_sum_mem Subfield.list_sum_mem

/- warning: subfield.multiset_prod_mem -> Subfield.multiset_prod_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (m : Multiset.{u1} K), (forall (a : K), (Membership.Mem.{u1, u1} K (Multiset.{u1} K) (Multiset.hasMem.{u1} K) a m) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) a s)) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (Multiset.prod.{u1} K (CommRing.toCommMonoid.{u1} K (Field.toCommRing.{u1} K _inst_1)) m) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (m : Multiset.{u1} K), (forall (a : K), (Membership.mem.{u1, u1} K (Multiset.{u1} K) (Multiset.instMembershipMultiset.{u1} K) a m) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) a s)) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (Multiset.prod.{u1} K (CommRing.toCommMonoid.{u1} K (Field.toCommRing.{u1} K _inst_1)) m) s)
Case conversion may be inaccurate. Consider using '#align subfield.multiset_prod_mem Subfield.multiset_prod_memₓ'. -/
/-- Product of a multiset of elements in a subfield is in the subfield. -/
protected theorem multiset_prod_mem (m : Multiset K) : (∀ a ∈ m, a ∈ s) → m.Prod ∈ s :=
  multiset_prod_mem m
#align subfield.multiset_prod_mem Subfield.multiset_prod_mem

/- warning: subfield.multiset_sum_mem -> Subfield.multiset_sum_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (m : Multiset.{u1} K), (forall (a : K), (Membership.Mem.{u1, u1} K (Multiset.{u1} K) (Multiset.hasMem.{u1} K) a m) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) a s)) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (Multiset.sum.{u1} K (AddCommGroup.toAddCommMonoid.{u1} K (NonUnitalNonAssocRing.toAddCommGroup.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) m) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (m : Multiset.{u1} K), (forall (a : K), (Membership.mem.{u1, u1} K (Multiset.{u1} K) (Multiset.instMembershipMultiset.{u1} K) a m) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) a s)) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (Multiset.sum.{u1} K (NonUnitalNonAssocSemiring.toAddCommMonoid.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) m) s)
Case conversion may be inaccurate. Consider using '#align subfield.multiset_sum_mem Subfield.multiset_sum_memₓ'. -/
/-- Sum of a multiset of elements in a `subfield` is in the `subfield`. -/
protected theorem multiset_sum_mem (m : Multiset K) : (∀ a ∈ m, a ∈ s) → m.Sum ∈ s :=
  multiset_sum_mem m
#align subfield.multiset_sum_mem Subfield.multiset_sum_mem

/- warning: subfield.prod_mem -> Subfield.prod_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {ι : Type.{u2}} {t : Finset.{u2} ι} {f : ι -> K}, (forall (c : ι), (Membership.Mem.{u2, u2} ι (Finset.{u2} ι) (Finset.hasMem.{u2} ι) c t) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (f c) s)) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (Finset.prod.{u1, u2} K ι (CommRing.toCommMonoid.{u1} K (Field.toCommRing.{u1} K _inst_1)) t (fun (i : ι) => f i)) s)
but is expected to have type
  forall {K : Type.{u2}} [_inst_1 : Field.{u2} K] (s : Subfield.{u2} K _inst_1) {ι : Type.{u1}} {t : Finset.{u1} ι} {f : ι -> K}, (forall (c : ι), (Membership.mem.{u1, u1} ι (Finset.{u1} ι) (Finset.instMembershipFinset.{u1} ι) c t) -> (Membership.mem.{u2, u2} K (Subfield.{u2} K _inst_1) (SetLike.instMembership.{u2, u2} (Subfield.{u2} K _inst_1) K (Subfield.instSetLikeSubfield.{u2} K _inst_1)) (f c) s)) -> (Membership.mem.{u2, u2} K (Subfield.{u2} K _inst_1) (SetLike.instMembership.{u2, u2} (Subfield.{u2} K _inst_1) K (Subfield.instSetLikeSubfield.{u2} K _inst_1)) (Finset.prod.{u2, u1} K ι (CommRing.toCommMonoid.{u2} K (Field.toCommRing.{u2} K _inst_1)) t (fun (i : ι) => f i)) s)
Case conversion may be inaccurate. Consider using '#align subfield.prod_mem Subfield.prod_memₓ'. -/
/-- Product of elements of a subfield indexed by a `finset` is in the subfield. -/
protected theorem prod_mem {ι : Type _} {t : Finset ι} {f : ι → K} (h : ∀ c ∈ t, f c ∈ s) :
    (∏ i in t, f i) ∈ s :=
  prod_mem h
#align subfield.prod_mem Subfield.prod_mem

/- warning: subfield.sum_mem -> Subfield.sum_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {ι : Type.{u2}} {t : Finset.{u2} ι} {f : ι -> K}, (forall (c : ι), (Membership.Mem.{u2, u2} ι (Finset.{u2} ι) (Finset.hasMem.{u2} ι) c t) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (f c) s)) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (Finset.sum.{u1, u2} K ι (AddCommGroup.toAddCommMonoid.{u1} K (NonUnitalNonAssocRing.toAddCommGroup.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) t (fun (i : ι) => f i)) s)
but is expected to have type
  forall {K : Type.{u2}} [_inst_1 : Field.{u2} K] (s : Subfield.{u2} K _inst_1) {ι : Type.{u1}} {t : Finset.{u1} ι} {f : ι -> K}, (forall (c : ι), (Membership.mem.{u1, u1} ι (Finset.{u1} ι) (Finset.instMembershipFinset.{u1} ι) c t) -> (Membership.mem.{u2, u2} K (Subfield.{u2} K _inst_1) (SetLike.instMembership.{u2, u2} (Subfield.{u2} K _inst_1) K (Subfield.instSetLikeSubfield.{u2} K _inst_1)) (f c) s)) -> (Membership.mem.{u2, u2} K (Subfield.{u2} K _inst_1) (SetLike.instMembership.{u2, u2} (Subfield.{u2} K _inst_1) K (Subfield.instSetLikeSubfield.{u2} K _inst_1)) (Finset.sum.{u2, u1} K ι (NonUnitalNonAssocSemiring.toAddCommMonoid.{u2} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u2} K (NonAssocRing.toNonUnitalNonAssocRing.{u2} K (Ring.toNonAssocRing.{u2} K (DivisionRing.toRing.{u2} K (Field.toDivisionRing.{u2} K _inst_1)))))) t (fun (i : ι) => f i)) s)
Case conversion may be inaccurate. Consider using '#align subfield.sum_mem Subfield.sum_memₓ'. -/
/-- Sum of elements in a `subfield` indexed by a `finset` is in the `subfield`. -/
protected theorem sum_mem {ι : Type _} {t : Finset ι} {f : ι → K} (h : ∀ c ∈ t, f c ∈ s) :
    (∑ i in t, f i) ∈ s :=
  sum_mem h
#align subfield.sum_mem Subfield.sum_mem

/- warning: subfield.pow_mem -> Subfield.pow_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K}, (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s) -> (forall (n : Nat), Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (HPow.hPow.{u1, 0, u1} K Nat K (instHPow.{u1, 0} K Nat (Monoid.Pow.{u1} K (Ring.toMonoid.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) x n) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K}, (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s) -> (forall (n : Nat), Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (HPow.hPow.{u1, 0, u1} K Nat K (instHPow.{u1, 0} K Nat (Monoid.Pow.{u1} K (MonoidWithZero.toMonoid.{u1} K (Semiring.toMonoidWithZero.{u1} K (DivisionSemiring.toSemiring.{u1} K (Semifield.toDivisionSemiring.{u1} K (Field.toSemifield.{u1} K _inst_1))))))) x n) s)
Case conversion may be inaccurate. Consider using '#align subfield.pow_mem Subfield.pow_memₓ'. -/
protected theorem pow_mem {x : K} (hx : x ∈ s) (n : ℕ) : x ^ n ∈ s :=
  pow_mem hx n
#align subfield.pow_mem Subfield.pow_mem

/- warning: subfield.zsmul_mem -> Subfield.zsmul_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K}, (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s) -> (forall (n : Int), Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (SMul.smul.{0, u1} Int K (SubNegMonoid.SMulInt.{u1} K (AddGroup.toSubNegMonoid.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) n x) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K}, (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s) -> (forall (n : Int), Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (HSMul.hSMul.{0, u1, u1} Int K K (instHSMul.{0, u1} Int K (SubNegMonoid.SMulInt.{u1} K (AddGroup.toSubNegMonoid.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (Ring.toAddGroupWithOne.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) n x) s)
Case conversion may be inaccurate. Consider using '#align subfield.zsmul_mem Subfield.zsmul_memₓ'. -/
protected theorem zsmul_mem {x : K} (hx : x ∈ s) (n : ℤ) : n • x ∈ s :=
  zsmul_mem hx n
#align subfield.zsmul_mem Subfield.zsmul_mem

/- warning: subfield.coe_int_mem -> Subfield.coe_int_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (n : Int), Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) ((fun (a : Type) (b : Type.{u1}) [self : HasLiftT.{1, succ u1} a b] => self.0) Int K (HasLiftT.mk.{1, succ u1} Int K (CoeTCₓ.coe.{1, succ u1} Int K (Int.castCoe.{u1} K (AddGroupWithOne.toHasIntCast.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))) n) s
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (n : Int), Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (Int.cast.{u1} K (Ring.toIntCast.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) n) s
Case conversion may be inaccurate. Consider using '#align subfield.coe_int_mem Subfield.coe_int_memₓ'. -/
protected theorem coe_int_mem (n : ℤ) : (n : K) ∈ s :=
  coe_int_mem s n
#align subfield.coe_int_mem Subfield.coe_int_mem

/- warning: subfield.zpow_mem -> Subfield.zpow_mem is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K}, (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s) -> (forall (n : Int), Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (HPow.hPow.{u1, 0, u1} K Int K (instHPow.{u1, 0} K Int (DivInvMonoid.Pow.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) x n) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) {x : K}, (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s) -> (forall (n : Int), Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) (HPow.hPow.{u1, 0, u1} K Int K (instHPow.{u1, 0} K Int (DivInvMonoid.Pow.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) x n) s)
Case conversion may be inaccurate. Consider using '#align subfield.zpow_mem Subfield.zpow_memₓ'. -/
theorem zpow_mem {x : K} (hx : x ∈ s) (n : ℤ) : x ^ n ∈ s :=
  by
  cases n
  · simpa using s.pow_mem hx n
  · simpa [pow_succ] using s.inv_mem (s.mul_mem hx (s.pow_mem hx n))
#align subfield.zpow_mem Subfield.zpow_mem

instance : Ring s :=
  s.toSubring.toRing

instance : Div s :=
  ⟨fun x y => ⟨x / y, s.div_mem x.2 y.2⟩⟩

instance : Inv s :=
  ⟨fun x => ⟨x⁻¹, s.inv_mem x.2⟩⟩

instance : Pow s ℤ :=
  ⟨fun x z => ⟨x ^ z, s.zpow_mem x.2 z⟩⟩

/- warning: subfield.to_field -> Subfield.toField is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Field.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Field.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s))
Case conversion may be inaccurate. Consider using '#align subfield.to_field Subfield.toFieldₓ'. -/
/-- A subfield inherits a field structure -/
instance toField : Field s :=
  Subtype.coe_injective.Field (coe : s → K) rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl)
    (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) (fun _ => rfl) fun _ => rfl
#align subfield.to_field Subfield.toField

/- warning: subfield.to_linear_ordered_field -> Subfield.toLinearOrderedField is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_4 : LinearOrderedField.{u1} K] (s : Subfield.{u1} K (LinearOrderedField.toField.{u1} K _inst_4)), LinearOrderedField.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K (LinearOrderedField.toField.{u1} K _inst_4)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K (LinearOrderedField.toField.{u1} K _inst_4)) K (Subfield.setLike.{u1} K (LinearOrderedField.toField.{u1} K _inst_4))) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_4 : LinearOrderedField.{u1} K] (s : Subfield.{u1} K (LinearOrderedField.toField.{u1} K _inst_4)), LinearOrderedField.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K (LinearOrderedField.toField.{u1} K _inst_4)) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K (LinearOrderedField.toField.{u1} K _inst_4)) K (Subfield.instSetLikeSubfield.{u1} K (LinearOrderedField.toField.{u1} K _inst_4))) x s))
Case conversion may be inaccurate. Consider using '#align subfield.to_linear_ordered_field Subfield.toLinearOrderedFieldₓ'. -/
/-- A subfield of a `linear_ordered_field` is a `linear_ordered_field`. -/
instance toLinearOrderedField {K} [LinearOrderedField K] (s : Subfield K) : LinearOrderedField s :=
  Subtype.coe_injective.LinearOrderedField coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ => rfl) (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl)
    (fun _ => rfl) (fun _ => rfl) (fun _ _ => rfl) fun _ _ => rfl
#align subfield.to_linear_ordered_field Subfield.toLinearOrderedField

/- warning: subfield.coe_add -> Subfield.coe_add is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (x : coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (y : coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s), Eq.{succ u1} K ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) (HAdd.hAdd.{u1, u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (instHAdd.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (AddMemClass.add.{u1, u1} K (Subfield.{u1} K _inst_1) (AddZeroClass.toHasAdd.{u1} K (AddMonoid.toAddZeroClass.{u1} K (AddMonoidWithOne.toAddMonoid.{u1} K (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} K (NonAssocSemiring.toAddCommMonoidWithOne.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))))) (Subfield.setLike.{u1} K _inst_1) (AddSubmonoidClass.to_addMemClass.{u1, u1} (Subfield.{u1} K _inst_1) K (AddMonoid.toAddZeroClass.{u1} K (AddMonoidWithOne.toAddMonoid.{u1} K (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} K (NonAssocSemiring.toAddCommMonoidWithOne.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))) (Subfield.setLike.{u1} K _inst_1) (SubsemiringClass.to_addSubmonoidClass.{u1, u1} (Subfield.{u1} K _inst_1) K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subfield.setLike.{u1} K _inst_1) (SubringClass.to_subsemiringClass.{u1, u1} (Subfield.{u1} K _inst_1) K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.setLike.{u1} K _inst_1) (SubfieldClass.to_subringClass.{u1, u1} (Subfield.{u1} K _inst_1) K _inst_1 (Subfield.setLike.{u1} K _inst_1) (Subfield.subfieldClass.{u1} K _inst_1))))) s)) x y)) (HAdd.hAdd.{u1, u1, u1} K K K (instHAdd.{u1} K (Distrib.toHasAdd.{u1} K (Ring.toDistrib.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) x) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) y))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (x : Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (y : Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)), Eq.{succ u1} K (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) (HAdd.hAdd.{u1, u1, u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (instHAdd.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Distrib.toAdd.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (NonUnitalNonAssocSemiring.toDistrib.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (NonAssocRing.toNonUnitalNonAssocRing.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Ring.toNonAssocRing.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Subfield.instRingSubtypeMemSubfieldInstMembershipInstSetLikeSubfield.{u1} K _inst_1 s))))))) x y)) (HAdd.hAdd.{u1, u1, u1} K K K (instHAdd.{u1} K (Distrib.toAdd.{u1} K (NonUnitalNonAssocSemiring.toDistrib.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))) (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) x) (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) y))
Case conversion may be inaccurate. Consider using '#align subfield.coe_add Subfield.coe_addₓ'. -/
@[simp, norm_cast]
theorem coe_add (x y : s) : (↑(x + y) : K) = ↑x + ↑y :=
  rfl
#align subfield.coe_add Subfield.coe_add

/- warning: subfield.coe_sub -> Subfield.coe_sub is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (x : coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (y : coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s), Eq.{succ u1} K ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) (HSub.hSub.{u1, u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (instHSub.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (AddSubgroupClass.sub.{u1, u1} K (Subfield.{u1} K _inst_1) (AddGroup.toSubNegMonoid.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subfield.setLike.{u1} K _inst_1) (SubringClass.addSubgroupClass.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1) (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (SubfieldClass.to_subringClass.{u1, u1} (Subfield.{u1} K _inst_1) K _inst_1 (Subfield.setLike.{u1} K _inst_1) (Subfield.subfieldClass.{u1} K _inst_1))) s)) x y)) (HSub.hSub.{u1, u1, u1} K K K (instHSub.{u1} K (SubNegMonoid.toHasSub.{u1} K (AddGroup.toSubNegMonoid.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) x) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) y))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (x : Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (y : Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)), Eq.{succ u1} K (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) (HSub.hSub.{u1, u1, u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (instHSub.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (AddSubgroupClass.sub.{u1, u1} K (Subfield.{u1} K _inst_1) (AddGroup.toSubNegMonoid.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (Ring.toAddGroupWithOne.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (Subfield.instSetLikeSubfield.{u1} K _inst_1) (SubringClass.addSubgroupClass.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (SubfieldClass.toSubringClass.{u1, u1} (Subfield.{u1} K _inst_1) K _inst_1 (Subfield.instSetLikeSubfield.{u1} K _inst_1) (Subfield.instSubfieldClassSubfieldInstSetLikeSubfield.{u1} K _inst_1))) s)) x y)) (HSub.hSub.{u1, u1, u1} K K K (instHSub.{u1} K (Ring.toSub.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) x) (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) y))
Case conversion may be inaccurate. Consider using '#align subfield.coe_sub Subfield.coe_subₓ'. -/
@[simp, norm_cast]
theorem coe_sub (x y : s) : (↑(x - y) : K) = ↑x - ↑y :=
  rfl
#align subfield.coe_sub Subfield.coe_sub

/- warning: subfield.coe_neg -> Subfield.coe_neg is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (x : coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s), Eq.{succ u1} K ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) (Neg.neg.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (AddSubgroupClass.neg.{u1, u1} K (Subfield.{u1} K _inst_1) (AddGroup.toSubNegMonoid.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subfield.setLike.{u1} K _inst_1) (SubringClass.addSubgroupClass.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1) (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (SubfieldClass.to_subringClass.{u1, u1} (Subfield.{u1} K _inst_1) K _inst_1 (Subfield.setLike.{u1} K _inst_1) (Subfield.subfieldClass.{u1} K _inst_1))) s) x)) (Neg.neg.{u1} K (SubNegMonoid.toHasNeg.{u1} K (AddGroup.toSubNegMonoid.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) x))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (x : Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)), Eq.{succ u1} K (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) (Neg.neg.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (AddSubgroupClass.neg.{u1, u1} K (Subfield.{u1} K _inst_1) (AddGroup.toSubNegMonoid.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (Ring.toAddGroupWithOne.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (Subfield.instSetLikeSubfield.{u1} K _inst_1) (SubringClass.addSubgroupClass.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (SubfieldClass.toSubringClass.{u1, u1} (Subfield.{u1} K _inst_1) K _inst_1 (Subfield.instSetLikeSubfield.{u1} K _inst_1) (Subfield.instSubfieldClassSubfieldInstSetLikeSubfield.{u1} K _inst_1))) s) x)) (Neg.neg.{u1} K (Ring.toNeg.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) x))
Case conversion may be inaccurate. Consider using '#align subfield.coe_neg Subfield.coe_negₓ'. -/
@[simp, norm_cast]
theorem coe_neg (x : s) : (↑(-x) : K) = -↑x :=
  rfl
#align subfield.coe_neg Subfield.coe_neg

/- warning: subfield.coe_mul -> Subfield.coe_mul is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (x : coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (y : coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s), Eq.{succ u1} K ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) (HMul.hMul.{u1, u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (instHMul.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (MulMemClass.mul.{u1, u1} K (Subfield.{u1} K _inst_1) (MulOneClass.toHasMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Subfield.setLike.{u1} K _inst_1) (SubmonoidClass.to_mulMemClass.{u1, u1} (Subfield.{u1} K _inst_1) K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subfield.setLike.{u1} K _inst_1) (SubsemiringClass.to_submonoidClass.{u1, u1} (Subfield.{u1} K _inst_1) K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subfield.setLike.{u1} K _inst_1) (SubringClass.to_subsemiringClass.{u1, u1} (Subfield.{u1} K _inst_1) K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.setLike.{u1} K _inst_1) (SubfieldClass.to_subringClass.{u1, u1} (Subfield.{u1} K _inst_1) K _inst_1 (Subfield.setLike.{u1} K _inst_1) (Subfield.subfieldClass.{u1} K _inst_1))))) s)) x y)) (HMul.hMul.{u1, u1, u1} K K K (instHMul.{u1} K (Distrib.toHasMul.{u1} K (Ring.toDistrib.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) x) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) y))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (x : Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (y : Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)), Eq.{succ u1} K (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) (HMul.hMul.{u1, u1, u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (instHMul.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Submonoid.mul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subsemiring.toSubmonoid.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 s))))) x y)) (HMul.hMul.{u1, u1, u1} K K K (instHMul.{u1} K (NonUnitalNonAssocRing.toMul.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) x) (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) y))
Case conversion may be inaccurate. Consider using '#align subfield.coe_mul Subfield.coe_mulₓ'. -/
@[simp, norm_cast]
theorem coe_mul (x y : s) : (↑(x * y) : K) = ↑x * ↑y :=
  rfl
#align subfield.coe_mul Subfield.coe_mul

/- warning: subfield.coe_div -> Subfield.coe_div is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (x : coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (y : coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s), Eq.{succ u1} K ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) (HDiv.hDiv.{u1, u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (instHDiv.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (Subfield.hasDiv.{u1} K _inst_1 s)) x y)) (HDiv.hDiv.{u1, u1, u1} K K K (instHDiv.{u1} K (DivInvMonoid.toHasDiv.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) x) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) y))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (x : Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (y : Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)), Eq.{succ u1} K (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) (HDiv.hDiv.{u1, u1, u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (instHDiv.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Subfield.instDivSubtypeMemSubfieldInstMembershipInstSetLikeSubfield.{u1} K _inst_1 s)) x y)) (HDiv.hDiv.{u1, u1, u1} K K K (instHDiv.{u1} K (Field.toDiv.{u1} K _inst_1)) (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) x) (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) y))
Case conversion may be inaccurate. Consider using '#align subfield.coe_div Subfield.coe_divₓ'. -/
@[simp, norm_cast]
theorem coe_div (x y : s) : (↑(x / y) : K) = ↑x / ↑y :=
  rfl
#align subfield.coe_div Subfield.coe_div

/- warning: subfield.coe_inv -> Subfield.coe_inv is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (x : coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s), Eq.{succ u1} K ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) (Inv.inv.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (Subfield.hasInv.{u1} K _inst_1 s) x)) (Inv.inv.{u1} K (DivInvMonoid.toHasInv.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) x))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1) (x : Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)), Eq.{succ u1} K (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) (Inv.inv.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Subfield.instInvSubtypeMemSubfieldInstMembershipInstSetLikeSubfield.{u1} K _inst_1 s) x)) (Inv.inv.{u1} K (Field.toInv.{u1} K _inst_1) (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) x))
Case conversion may be inaccurate. Consider using '#align subfield.coe_inv Subfield.coe_invₓ'. -/
@[simp, norm_cast]
theorem coe_inv (x : s) : (↑x⁻¹ : K) = (↑x)⁻¹ :=
  rfl
#align subfield.coe_inv Subfield.coe_inv

/- warning: subfield.coe_zero -> Subfield.coe_zero is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Eq.{succ u1} K ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))) (OfNat.ofNat.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) 0 (OfNat.mk.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) 0 (Zero.zero.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (ZeroMemClass.zero.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1) (AddZeroClass.toHasZero.{u1} K (AddMonoid.toAddZeroClass.{u1} K (AddMonoidWithOne.toAddMonoid.{u1} K (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} K (NonAssocSemiring.toAddCommMonoidWithOne.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))))) (AddSubmonoidClass.to_zeroMemClass.{u1, u1} (Subfield.{u1} K _inst_1) K (AddMonoid.toAddZeroClass.{u1} K (AddMonoidWithOne.toAddMonoid.{u1} K (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} K (NonAssocSemiring.toAddCommMonoidWithOne.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))) (Subfield.setLike.{u1} K _inst_1) (SubsemiringClass.to_addSubmonoidClass.{u1, u1} (Subfield.{u1} K _inst_1) K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subfield.setLike.{u1} K _inst_1) (SubringClass.to_subsemiringClass.{u1, u1} (Subfield.{u1} K _inst_1) K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.setLike.{u1} K _inst_1) (SubfieldClass.to_subringClass.{u1, u1} (Subfield.{u1} K _inst_1) K _inst_1 (Subfield.setLike.{u1} K _inst_1) (Subfield.subfieldClass.{u1} K _inst_1))))) s))))) (OfNat.ofNat.{u1} K 0 (OfNat.mk.{u1} K 0 (Zero.zero.{u1} K (MulZeroClass.toHasZero.{u1} K (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))))))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Eq.{succ u1} K (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)) (OfNat.ofNat.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) 0 (Zero.toOfNat0.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (ZeroMemClass.zero.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) (CommMonoidWithZero.toZero.{u1} K (CommGroupWithZero.toCommMonoidWithZero.{u1} K (Semifield.toCommGroupWithZero.{u1} K (Field.toSemifield.{u1} K _inst_1)))) (AddSubmonoidClass.toZeroMemClass.{u1, u1} (Subfield.{u1} K _inst_1) K (AddMonoid.toAddZeroClass.{u1} K (AddMonoidWithOne.toAddMonoid.{u1} K (AddGroupWithOne.toAddMonoidWithOne.{u1} K (Ring.toAddGroupWithOne.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subfield.instSetLikeSubfield.{u1} K _inst_1) (SubsemiringClass.toAddSubmonoidClass.{u1, u1} (Subfield.{u1} K _inst_1) K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subfield.instSetLikeSubfield.{u1} K _inst_1) (SubringClass.toSubsemiringClass.{u1, u1} (Subfield.{u1} K _inst_1) K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.instSetLikeSubfield.{u1} K _inst_1) (SubfieldClass.toSubringClass.{u1, u1} (Subfield.{u1} K _inst_1) K _inst_1 (Subfield.instSetLikeSubfield.{u1} K _inst_1) (Subfield.instSubfieldClassSubfieldInstSetLikeSubfield.{u1} K _inst_1))))) s)))) (OfNat.ofNat.{u1} K 0 (Zero.toOfNat0.{u1} K (CommMonoidWithZero.toZero.{u1} K (CommGroupWithZero.toCommMonoidWithZero.{u1} K (Semifield.toCommGroupWithZero.{u1} K (Field.toSemifield.{u1} K _inst_1))))))
Case conversion may be inaccurate. Consider using '#align subfield.coe_zero Subfield.coe_zeroₓ'. -/
@[simp, norm_cast]
theorem coe_zero : ((0 : s) : K) = 0 :=
  rfl
#align subfield.coe_zero Subfield.coe_zero

#print Subfield.coe_one /-
@[simp, norm_cast]
theorem coe_one : ((1 : s) : K) = 1 :=
  rfl
#align subfield.coe_one Subfield.coe_one
-/

end DerivedFromSubfieldClass

/- warning: subfield.subtype -> Subfield.subtype is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), RingHom.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (NonAssocRing.toNonAssocSemiring.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (Ring.toNonAssocRing.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (Subfield.ring.{u1} K _inst_1 s))) (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), RingHom.{u1, u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) K (Subsemiring.toNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 s))) (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))
Case conversion may be inaccurate. Consider using '#align subfield.subtype Subfield.subtypeₓ'. -/
/-- The embedding from a subfield of the field `K` to `K`. -/
def subtype (s : Subfield K) : s →+* K :=
  { s.toSubmonoid.Subtype, s.toAddSubgroup.Subtype with toFun := coe }
#align subfield.subtype Subfield.subtype

/- warning: subfield.to_algebra -> Subfield.toAlgebra is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Algebra.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (SubsemiringClass.toCommSemiring.{u1, u1} (Subfield.{u1} K _inst_1) s K (Semifield.toCommSemiring.{u1} K (Field.toSemifield.{u1} K _inst_1)) (Subfield.setLike.{u1} K _inst_1) (Subfield.toAlgebra._proof_1.{u1} K _inst_1)) (Ring.toSemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Algebra.{u1, u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) K (Semifield.toCommSemiring.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Field.toSemifield.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Subfield.toField.{u1} K _inst_1 s))) (DivisionSemiring.toSemiring.{u1} K (Semifield.toDivisionSemiring.{u1} K (Field.toSemifield.{u1} K _inst_1)))
Case conversion may be inaccurate. Consider using '#align subfield.to_algebra Subfield.toAlgebraₓ'. -/
instance toAlgebra : Algebra s K :=
  RingHom.toAlgebra s.Subtype
#align subfield.to_algebra Subfield.toAlgebra

/- warning: subfield.coe_subtype -> Subfield.coe_subtype is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Eq.{succ u1} ((coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) -> K) (coeFn.{succ u1, succ u1} (RingHom.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (NonAssocRing.toNonAssocSemiring.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (Ring.toNonAssocRing.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (Subfield.ring.{u1} K _inst_1 s))) (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (fun (_x : RingHom.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (NonAssocRing.toNonAssocSemiring.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (Ring.toNonAssocRing.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (Subfield.ring.{u1} K _inst_1 s))) (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) => (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) -> K) (RingHom.hasCoeToFun.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (NonAssocRing.toNonAssocSemiring.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (Ring.toNonAssocRing.{u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) (Subfield.ring.{u1} K _inst_1 s))) (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (Subfield.subtype.{u1} K _inst_1 s)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (HasLiftT.mk.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (CoeTCₓ.coe.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeBase.{succ u1, succ u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) s) K (coeSubtype.{succ u1} K (fun (x : K) => Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s))))))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Eq.{succ u1} (forall (ᾰ : Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)), (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) => K) ᾰ) (FunLike.coe.{succ u1, succ u1, succ u1} (RingHom.{u1, u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) K (Subsemiring.toNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 s))) (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (fun (_x : Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) => K) _x) (MulHomClass.toFunLike.{u1, u1, u1} (RingHom.{u1, u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) K (Subsemiring.toNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 s))) (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) K (NonUnitalNonAssocSemiring.toMul.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Subsemiring.toNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 s))))) (NonUnitalNonAssocSemiring.toMul.{u1} K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (NonUnitalRingHomClass.toMulHomClass.{u1, u1, u1} (RingHom.{u1, u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) K (Subsemiring.toNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 s))) (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) (Subsemiring.toNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 s)))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (RingHomClass.toNonUnitalRingHomClass.{u1, u1, u1} (RingHom.{u1, u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) K (Subsemiring.toNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 s))) (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) K (Subsemiring.toNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 s))) (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (RingHom.instRingHomClassRingHom.{u1, u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)) K (Subsemiring.toNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 s))) (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))) (Subfield.subtype.{u1} K _inst_1 s)) (Subtype.val.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)))
Case conversion may be inaccurate. Consider using '#align subfield.coe_subtype Subfield.coe_subtypeₓ'. -/
@[simp]
theorem coe_subtype : ⇑s.Subtype = coe :=
  rfl
#align subfield.coe_subtype Subfield.coe_subtype

/- warning: subfield.to_subring.subtype_eq_subtype -> Subfield.toSubring.subtype_eq_subtype is a dubious translation:
lean 3 declaration is
  forall (F : Type.{u1}) [_inst_4 : Field.{u1} F] (S : Subfield.{u1} F _inst_4), Eq.{succ u1} (RingHom.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subring.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4))) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subring.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4))) F (Subring.setLike.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4)))) (Subfield.toSubring.{u1} F _inst_4 S)) F (NonAssocRing.toNonAssocSemiring.{u1} (coeSort.{succ u1, succ (succ u1)} (Subring.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4))) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subring.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4))) F (Subring.setLike.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4)))) (Subfield.toSubring.{u1} F _inst_4 S)) (Ring.toNonAssocRing.{u1} (coeSort.{succ u1, succ (succ u1)} (Subring.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4))) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subring.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4))) F (Subring.setLike.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4)))) (Subfield.toSubring.{u1} F _inst_4 S)) (Subring.toRing.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4)) (Subfield.toSubring.{u1} F _inst_4 S)))) (NonAssocRing.toNonAssocSemiring.{u1} F (Ring.toNonAssocRing.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4))))) (Subring.subtype.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4)) (Subfield.toSubring.{u1} F _inst_4 S)) (Subfield.subtype.{u1} F _inst_4 S)
but is expected to have type
  forall (F : Type.{u1}) [_inst_4 : Field.{u1} F] (S : Subfield.{u1} F _inst_4), Eq.{succ u1} (RingHom.{u1, u1} (Subtype.{succ u1} F (fun (x : F) => Membership.mem.{u1, u1} F (Subring.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4))) (SetLike.instMembership.{u1, u1} (Subring.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4))) F (Subring.instSetLikeSubring.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4)))) x (Subfield.toSubring.{u1} F _inst_4 S))) F (Subsemiring.toNonAssocSemiring.{u1} F (NonAssocRing.toNonAssocSemiring.{u1} F (Ring.toNonAssocRing.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4)))) (Subring.toSubsemiring.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4)) (Subfield.toSubring.{u1} F _inst_4 S))) (NonAssocRing.toNonAssocSemiring.{u1} F (Ring.toNonAssocRing.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4))))) (Subring.subtype.{u1} F (DivisionRing.toRing.{u1} F (Field.toDivisionRing.{u1} F _inst_4)) (Subfield.toSubring.{u1} F _inst_4 S)) (Subfield.subtype.{u1} F _inst_4 S)
Case conversion may be inaccurate. Consider using '#align subfield.to_subring.subtype_eq_subtype Subfield.toSubring.subtype_eq_subtypeₓ'. -/
theorem toSubring.subtype_eq_subtype (F : Type _) [Field F] (S : Subfield F) :
    S.toSubring.Subtype = S.Subtype :=
  rfl
#align subfield.to_subring.subtype_eq_subtype Subfield.toSubring.subtype_eq_subtype

/-! # Partial order -/


variable (s t)

/- warning: subfield.mem_to_submonoid -> Subfield.mem_toSubmonoid is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Subfield.{u1} K _inst_1} {x : K}, Iff (Membership.Mem.{u1, u1} K (Submonoid.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (SetLike.hasMem.{u1, u1} (Submonoid.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) K (Submonoid.setLike.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))) x (Subfield.toSubmonoid.{u1} K _inst_1 s)) (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Subfield.{u1} K _inst_1} {x : K}, Iff (Membership.mem.{u1, u1} K (Submonoid.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (SetLike.instMembership.{u1, u1} (Submonoid.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) K (Submonoid.instSetLikeSubmonoid.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))) x (Subsemiring.toSubmonoid.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 s)))) (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)
Case conversion may be inaccurate. Consider using '#align subfield.mem_to_submonoid Subfield.mem_toSubmonoidₓ'. -/
@[simp]
theorem mem_toSubmonoid {s : Subfield K} {x : K} : x ∈ s.toSubmonoid ↔ x ∈ s :=
  Iff.rfl
#align subfield.mem_to_submonoid Subfield.mem_toSubmonoid

/- warning: subfield.coe_to_submonoid -> Subfield.coe_toSubmonoid is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Eq.{succ u1} (Set.{u1} K) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Submonoid.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Submonoid.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Submonoid.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Submonoid.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) K (Submonoid.setLike.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))))) (Subfield.toSubmonoid.{u1} K _inst_1 s)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Eq.{succ u1} (Set.{u1} K) (SetLike.coe.{u1, u1} (Submonoid.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) K (Submonoid.instSetLikeSubmonoid.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Subsemiring.toSubmonoid.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 s)))) (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)
Case conversion may be inaccurate. Consider using '#align subfield.coe_to_submonoid Subfield.coe_toSubmonoidₓ'. -/
@[simp]
theorem coe_toSubmonoid : (s.toSubmonoid : Set K) = s :=
  rfl
#align subfield.coe_to_submonoid Subfield.coe_toSubmonoid

/- warning: subfield.mem_to_add_subgroup -> Subfield.mem_toAddSubgroup is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Subfield.{u1} K _inst_1} {x : K}, Iff (Membership.Mem.{u1, u1} K (AddSubgroup.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (SetLike.hasMem.{u1, u1} (AddSubgroup.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) K (AddSubgroup.setLike.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) x (Subfield.toAddSubgroup.{u1} K _inst_1 s)) (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Subfield.{u1} K _inst_1} {x : K}, Iff (Membership.mem.{u1, u1} K (AddSubgroup.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (Ring.toAddGroupWithOne.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (SetLike.instMembership.{u1, u1} (AddSubgroup.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (Ring.toAddGroupWithOne.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) K (AddSubgroup.instSetLikeAddSubgroup.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (Ring.toAddGroupWithOne.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) x (Subfield.toAddSubgroup.{u1} K _inst_1 s)) (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s)
Case conversion may be inaccurate. Consider using '#align subfield.mem_to_add_subgroup Subfield.mem_toAddSubgroupₓ'. -/
@[simp]
theorem mem_toAddSubgroup {s : Subfield K} {x : K} : x ∈ s.toAddSubgroup ↔ x ∈ s :=
  Iff.rfl
#align subfield.mem_to_add_subgroup Subfield.mem_toAddSubgroup

/- warning: subfield.coe_to_add_subgroup -> Subfield.coe_toAddSubgroup is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Eq.{succ u1} (Set.{u1} K) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (AddSubgroup.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (AddSubgroup.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (AddSubgroup.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (AddSubgroup.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) K (AddSubgroup.setLike.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))))) (Subfield.toAddSubgroup.{u1} K _inst_1 s)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) s)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Subfield.{u1} K _inst_1), Eq.{succ u1} (Set.{u1} K) (SetLike.coe.{u1, u1} (AddSubgroup.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (Ring.toAddGroupWithOne.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) K (AddSubgroup.instSetLikeAddSubgroup.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (Ring.toAddGroupWithOne.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (Subfield.toAddSubgroup.{u1} K _inst_1 s)) (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)
Case conversion may be inaccurate. Consider using '#align subfield.coe_to_add_subgroup Subfield.coe_toAddSubgroupₓ'. -/
@[simp]
theorem coe_toAddSubgroup : (s.toAddSubgroup : Set K) = s :=
  rfl
#align subfield.coe_to_add_subgroup Subfield.coe_toAddSubgroup

/-! # top -/


/-- The subfield of `K` containing all elements of `K`. -/
instance : Top (Subfield K) :=
  ⟨{ (⊤ : Subring K) with inv_mem' := fun x _ => Subring.mem_top x }⟩

instance : Inhabited (Subfield K) :=
  ⟨⊤⟩

/- warning: subfield.mem_top -> Subfield.mem_top is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (x : K), Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.hasTop.{u1} K _inst_1))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (x : K), Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.instTopSubfield.{u1} K _inst_1))
Case conversion may be inaccurate. Consider using '#align subfield.mem_top Subfield.mem_topₓ'. -/
@[simp]
theorem mem_top (x : K) : x ∈ (⊤ : Subfield K) :=
  Set.mem_univ x
#align subfield.mem_top Subfield.mem_top

/- warning: subfield.coe_top -> Subfield.coe_top is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K], Eq.{succ u1} (Set.{u1} K) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.hasTop.{u1} K _inst_1))) (Set.univ.{u1} K)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K], Eq.{succ u1} (Set.{u1} K) (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.instTopSubfield.{u1} K _inst_1))) (Set.univ.{u1} K)
Case conversion may be inaccurate. Consider using '#align subfield.coe_top Subfield.coe_topₓ'. -/
@[simp]
theorem coe_top : ((⊤ : Subfield K) : Set K) = Set.univ :=
  rfl
#align subfield.coe_top Subfield.coe_top

/- warning: subfield.top_equiv -> Subfield.topEquiv is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K], RingEquiv.{u1, u1} (coeSort.{succ u1, succ (succ u1)} (Subfield.{u1} K _inst_1) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.hasTop.{u1} K _inst_1))) K (MulMemClass.mul.{u1, u1} K (Subfield.{u1} K _inst_1) (MulOneClass.toHasMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Subfield.setLike.{u1} K _inst_1) (Subfield.topEquiv._proof_1.{u1} K _inst_1) (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.hasTop.{u1} K _inst_1))) (AddMemClass.add.{u1, u1} K (Subfield.{u1} K _inst_1) (AddZeroClass.toHasAdd.{u1} K (AddMonoid.toAddZeroClass.{u1} K (AddMonoidWithOne.toAddMonoid.{u1} K (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} K (NonAssocSemiring.toAddCommMonoidWithOne.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))))) (Subfield.setLike.{u1} K _inst_1) (Subfield.topEquiv._proof_2.{u1} K _inst_1) (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.hasTop.{u1} K _inst_1))) (Distrib.toHasMul.{u1} K (Ring.toDistrib.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Distrib.toHasAdd.{u1} K (Ring.toDistrib.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K], RingEquiv.{u1, u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.instTopSubfield.{u1} K _inst_1)))) K (Submonoid.mul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subsemiring.toSubmonoid.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.instTopSubfield.{u1} K _inst_1)))))) (NonUnitalNonAssocRing.toMul.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (Distrib.toAdd.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.instTopSubfield.{u1} K _inst_1)))) (NonUnitalNonAssocSemiring.toDistrib.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.instTopSubfield.{u1} K _inst_1)))) (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.instTopSubfield.{u1} K _inst_1)))) (NonAssocRing.toNonUnitalNonAssocRing.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.instTopSubfield.{u1} K _inst_1)))) (Ring.toNonAssocRing.{u1} (Subtype.{succ u1} K (fun (x : K) => Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.instTopSubfield.{u1} K _inst_1)))) (Subfield.instRingSubtypeMemSubfieldInstMembershipInstSetLikeSubfield.{u1} K _inst_1 (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.instTopSubfield.{u1} K _inst_1)))))))) (Distrib.toAdd.{u1} K (NonUnitalNonAssocSemiring.toDistrib.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))
Case conversion may be inaccurate. Consider using '#align subfield.top_equiv Subfield.topEquivₓ'. -/
/-- The ring equiv between the top element of `subfield K` and `K`. -/
@[simps]
def topEquiv : (⊤ : Subfield K) ≃+* K :=
  Subsemiring.topEquiv
#align subfield.top_equiv Subfield.topEquiv

/-! # comap -/


variable (f : K →+* L)

#print Subfield.comap /-
/-- The preimage of a subfield along a ring homomorphism is a subfield. -/
def comap (s : Subfield L) : Subfield K :=
  { s.toSubring.comap f with
    inv_mem' := fun x hx =>
      show f x⁻¹ ∈ s by
        rw [map_inv₀ f]
        exact s.inv_mem hx }
#align subfield.comap Subfield.comap
-/

/- warning: subfield.coe_comap -> Subfield.coe_comap is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] (f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) (s : Subfield.{u2} L _inst_2), Eq.{succ u1} (Set.{u1} K) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) (Subfield.comap.{u1, u2} K L _inst_1 _inst_2 f s)) (Set.preimage.{u1, u2} K L (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) (fun (_x : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) => K -> L) (RingHom.hasCoeToFun.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) f) ((fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (Subfield.{u2} L _inst_2) (Set.{u2} L) (HasLiftT.mk.{succ u2, succ u2} (Subfield.{u2} L _inst_2) (Set.{u2} L) (CoeTCₓ.coe.{succ u2, succ u2} (Subfield.{u2} L _inst_2) (Set.{u2} L) (SetLike.Set.hasCoeT.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.setLike.{u2} L _inst_2)))) s))
but is expected to have type
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] (f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) (s : Subfield.{u2} L _inst_2), Eq.{succ u1} (Set.{u1} K) (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) (Subfield.comap.{u1, u2} K L _inst_1 _inst_2 f s)) (Set.preimage.{u1, u2} K L (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K (fun (_x : K) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : K) => L) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonUnitalNonAssocSemiring.toMul.{u1} K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (NonUnitalNonAssocSemiring.toMul.{u2} L (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} L (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))))) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} L (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))) (RingHom.instRingHomClassRingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))))))) f) (SetLike.coe.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.instSetLikeSubfield.{u2} L _inst_2) s))
Case conversion may be inaccurate. Consider using '#align subfield.coe_comap Subfield.coe_comapₓ'. -/
@[simp]
theorem coe_comap (s : Subfield L) : (s.comap f : Set K) = f ⁻¹' s :=
  rfl
#align subfield.coe_comap Subfield.coe_comap

/- warning: subfield.mem_comap -> Subfield.mem_comap is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] {s : Subfield.{u2} L _inst_2} {f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))} {x : K}, Iff (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x (Subfield.comap.{u1, u2} K L _inst_1 _inst_2 f s)) (Membership.Mem.{u2, u2} L (Subfield.{u2} L _inst_2) (SetLike.hasMem.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.setLike.{u2} L _inst_2)) (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) (fun (_x : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) => K -> L) (RingHom.hasCoeToFun.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) f x) s)
but is expected to have type
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] {s : Subfield.{u2} L _inst_2} {f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))} {x : K}, Iff (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x (Subfield.comap.{u1, u2} K L _inst_1 _inst_2 f s)) (Membership.mem.{u2, u2} ((fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : K) => L) x) (Subfield.{u2} L _inst_2) (SetLike.instMembership.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.instSetLikeSubfield.{u2} L _inst_2)) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K (fun (_x : K) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : K) => L) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonUnitalNonAssocSemiring.toMul.{u1} K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (NonUnitalNonAssocSemiring.toMul.{u2} L (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} L (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))))) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} L (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))) (RingHom.instRingHomClassRingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))))))) f x) s)
Case conversion may be inaccurate. Consider using '#align subfield.mem_comap Subfield.mem_comapₓ'. -/
@[simp]
theorem mem_comap {s : Subfield L} {f : K →+* L} {x : K} : x ∈ s.comap f ↔ f x ∈ s :=
  Iff.rfl
#align subfield.mem_comap Subfield.mem_comap

#print Subfield.comap_comap /-
theorem comap_comap (s : Subfield M) (g : L →+* M) (f : K →+* L) :
    (s.comap g).comap f = s.comap (g.comp f) :=
  rfl
#align subfield.comap_comap Subfield.comap_comap
-/

/-! # map -/


#print Subfield.map /-
/-- The image of a subfield along a ring homomorphism is a subfield. -/
def map (s : Subfield K) : Subfield L :=
  { s.toSubring.map f with
    inv_mem' := by
      rintro _ ⟨x, hx, rfl⟩
      exact ⟨x⁻¹, s.inv_mem hx, map_inv₀ f x⟩ }
#align subfield.map Subfield.map
-/

/- warning: subfield.coe_map -> Subfield.coe_map is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] (s : Subfield.{u1} K _inst_1) (f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))), Eq.{succ u2} (Set.{u2} L) ((fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (Subfield.{u2} L _inst_2) (Set.{u2} L) (HasLiftT.mk.{succ u2, succ u2} (Subfield.{u2} L _inst_2) (Set.{u2} L) (CoeTCₓ.coe.{succ u2, succ u2} (Subfield.{u2} L _inst_2) (Set.{u2} L) (SetLike.Set.hasCoeT.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.setLike.{u2} L _inst_2)))) (Subfield.map.{u1, u2} K L _inst_1 _inst_2 f s)) (Set.image.{u1, u2} K L (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) (fun (_x : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) => K -> L) (RingHom.hasCoeToFun.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) f) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) s))
but is expected to have type
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] (s : Subfield.{u1} K _inst_1) (f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))), Eq.{succ u2} (Set.{u2} L) (SetLike.coe.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.instSetLikeSubfield.{u2} L _inst_2) (Subfield.map.{u1, u2} K L _inst_1 _inst_2 f s)) (Set.image.{u1, u2} K L (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K (fun (_x : K) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : K) => L) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonUnitalNonAssocSemiring.toMul.{u1} K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (NonUnitalNonAssocSemiring.toMul.{u2} L (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} L (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))))) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} L (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))) (RingHom.instRingHomClassRingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))))))) f) (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s))
Case conversion may be inaccurate. Consider using '#align subfield.coe_map Subfield.coe_mapₓ'. -/
@[simp]
theorem coe_map : (s.map f : Set L) = f '' s :=
  rfl
#align subfield.coe_map Subfield.coe_map

/- warning: subfield.mem_map -> Subfield.mem_map is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] {f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))} {s : Subfield.{u1} K _inst_1} {y : L}, Iff (Membership.Mem.{u2, u2} L (Subfield.{u2} L _inst_2) (SetLike.hasMem.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.setLike.{u2} L _inst_2)) y (Subfield.map.{u1, u2} K L _inst_1 _inst_2 f s)) (Exists.{succ u1} K (fun (x : K) => Exists.{0} (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s) (fun (H : Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x s) => Eq.{succ u2} L (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) (fun (_x : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) => K -> L) (RingHom.hasCoeToFun.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) f x) y)))
but is expected to have type
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] {f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))} {s : Subfield.{u1} K _inst_1} {y : L}, Iff (Membership.mem.{u2, u2} L (Subfield.{u2} L _inst_2) (SetLike.instMembership.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.instSetLikeSubfield.{u2} L _inst_2)) y (Subfield.map.{u1, u2} K L _inst_1 _inst_2 f s)) (Exists.{succ u1} K (fun (x : K) => And (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x s) (Eq.{succ u2} ((fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : K) => L) x) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K (fun (a : K) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : K) => L) a) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonUnitalNonAssocSemiring.toMul.{u1} K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (NonUnitalNonAssocSemiring.toMul.{u2} L (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} L (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))))) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} L (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))) (RingHom.instRingHomClassRingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))))))) f x) y)))
Case conversion may be inaccurate. Consider using '#align subfield.mem_map Subfield.mem_mapₓ'. -/
@[simp]
theorem mem_map {f : K →+* L} {s : Subfield K} {y : L} : y ∈ s.map f ↔ ∃ x ∈ s, f x = y :=
  Set.mem_image_iff_bex
#align subfield.mem_map Subfield.mem_map

#print Subfield.map_map /-
theorem map_map (g : L →+* M) (f : K →+* L) : (s.map f).map g = s.map (g.comp f) :=
  SetLike.ext' <| Set.image_image _ _ _
#align subfield.map_map Subfield.map_map
-/

/- warning: subfield.map_le_iff_le_comap -> Subfield.map_le_iff_le_comap is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] {f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))} {s : Subfield.{u1} K _inst_1} {t : Subfield.{u2} L _inst_2}, Iff (LE.le.{u2} (Subfield.{u2} L _inst_2) (Preorder.toLE.{u2} (Subfield.{u2} L _inst_2) (PartialOrder.toPreorder.{u2} (Subfield.{u2} L _inst_2) (SetLike.partialOrder.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.setLike.{u2} L _inst_2)))) (Subfield.map.{u1, u2} K L _inst_1 _inst_2 f s) t) (LE.le.{u1} (Subfield.{u1} K _inst_1) (Preorder.toLE.{u1} (Subfield.{u1} K _inst_1) (PartialOrder.toPreorder.{u1} (Subfield.{u1} K _inst_1) (SetLike.partialOrder.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) s (Subfield.comap.{u1, u2} K L _inst_1 _inst_2 f t))
but is expected to have type
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] {f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))} {s : Subfield.{u1} K _inst_1} {t : Subfield.{u2} L _inst_2}, Iff (LE.le.{u2} (Subfield.{u2} L _inst_2) (Preorder.toLE.{u2} (Subfield.{u2} L _inst_2) (PartialOrder.toPreorder.{u2} (Subfield.{u2} L _inst_2) (SetLike.instPartialOrder.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.instSetLikeSubfield.{u2} L _inst_2)))) (Subfield.map.{u1, u2} K L _inst_1 _inst_2 f s) t) (LE.le.{u1} (Subfield.{u1} K _inst_1) (Preorder.toLE.{u1} (Subfield.{u1} K _inst_1) (PartialOrder.toPreorder.{u1} (Subfield.{u1} K _inst_1) (SetLike.instPartialOrder.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)))) s (Subfield.comap.{u1, u2} K L _inst_1 _inst_2 f t))
Case conversion may be inaccurate. Consider using '#align subfield.map_le_iff_le_comap Subfield.map_le_iff_le_comapₓ'. -/
theorem map_le_iff_le_comap {f : K →+* L} {s : Subfield K} {t : Subfield L} :
    s.map f ≤ t ↔ s ≤ t.comap f :=
  Set.image_subset_iff
#align subfield.map_le_iff_le_comap Subfield.map_le_iff_le_comap

/- warning: subfield.gc_map_comap -> Subfield.gc_map_comap is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] (f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))), GaloisConnection.{u1, u2} (Subfield.{u1} K _inst_1) (Subfield.{u2} L _inst_2) (PartialOrder.toPreorder.{u1} (Subfield.{u1} K _inst_1) (SetLike.partialOrder.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1))) (PartialOrder.toPreorder.{u2} (Subfield.{u2} L _inst_2) (SetLike.partialOrder.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.setLike.{u2} L _inst_2))) (Subfield.map.{u1, u2} K L _inst_1 _inst_2 f) (Subfield.comap.{u1, u2} K L _inst_1 _inst_2 f)
but is expected to have type
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] (f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))), GaloisConnection.{u1, u2} (Subfield.{u1} K _inst_1) (Subfield.{u2} L _inst_2) (PartialOrder.toPreorder.{u1} (Subfield.{u1} K _inst_1) (SetLike.instPartialOrder.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1))) (PartialOrder.toPreorder.{u2} (Subfield.{u2} L _inst_2) (SetLike.instPartialOrder.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.instSetLikeSubfield.{u2} L _inst_2))) (Subfield.map.{u1, u2} K L _inst_1 _inst_2 f) (Subfield.comap.{u1, u2} K L _inst_1 _inst_2 f)
Case conversion may be inaccurate. Consider using '#align subfield.gc_map_comap Subfield.gc_map_comapₓ'. -/
theorem gc_map_comap (f : K →+* L) : GaloisConnection (map f) (comap f) := fun S T =>
  map_le_iff_le_comap
#align subfield.gc_map_comap Subfield.gc_map_comap

end Subfield

namespace RingHom

variable (g : L →+* M) (f : K →+* L)

/-! # range -/


#print RingHom.fieldRange /-
/-- The range of a ring homomorphism, as a subfield of the target. See Note [range copy pattern]. -/
def fieldRange : Subfield L :=
  ((⊤ : Subfield K).map f).copy (Set.range f) Set.image_univ.symm
#align ring_hom.field_range RingHom.fieldRange
-/

/- warning: ring_hom.coe_field_range -> RingHom.coe_fieldRange is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] (f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))), Eq.{succ u2} (Set.{u2} L) ((fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (Subfield.{u2} L _inst_2) (Set.{u2} L) (HasLiftT.mk.{succ u2, succ u2} (Subfield.{u2} L _inst_2) (Set.{u2} L) (CoeTCₓ.coe.{succ u2, succ u2} (Subfield.{u2} L _inst_2) (Set.{u2} L) (SetLike.Set.hasCoeT.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.setLike.{u2} L _inst_2)))) (RingHom.fieldRange.{u1, u2} K L _inst_1 _inst_2 f)) (Set.range.{u2, succ u1} L K (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) (fun (_x : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) => K -> L) (RingHom.hasCoeToFun.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) f))
but is expected to have type
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] (f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))), Eq.{succ u2} (Set.{u2} L) (SetLike.coe.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.instSetLikeSubfield.{u2} L _inst_2) (RingHom.fieldRange.{u1, u2} K L _inst_1 _inst_2 f)) (Set.range.{u2, succ u1} L K (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K (fun (_x : K) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : K) => L) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonUnitalNonAssocSemiring.toMul.{u1} K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (NonUnitalNonAssocSemiring.toMul.{u2} L (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} L (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))))) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} L (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))) (RingHom.instRingHomClassRingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))))))) f))
Case conversion may be inaccurate. Consider using '#align ring_hom.coe_field_range RingHom.coe_fieldRangeₓ'. -/
@[simp]
theorem coe_fieldRange : (f.fieldRange : Set L) = Set.range f :=
  rfl
#align ring_hom.coe_field_range RingHom.coe_fieldRange

/- warning: ring_hom.mem_field_range -> RingHom.mem_fieldRange is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] {f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))} {y : L}, Iff (Membership.Mem.{u2, u2} L (Subfield.{u2} L _inst_2) (SetLike.hasMem.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.setLike.{u2} L _inst_2)) y (RingHom.fieldRange.{u1, u2} K L _inst_1 _inst_2 f)) (Exists.{succ u1} K (fun (x : K) => Eq.{succ u2} L (coeFn.{max (succ u1) (succ u2), max (succ u1) (succ u2)} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) (fun (_x : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) => K -> L) (RingHom.hasCoeToFun.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) f x) y))
but is expected to have type
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] {f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))} {y : L}, Iff (Membership.mem.{u2, u2} L (Subfield.{u2} L _inst_2) (SetLike.instMembership.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.instSetLikeSubfield.{u2} L _inst_2)) y (RingHom.fieldRange.{u1, u2} K L _inst_1 _inst_2 f)) (Exists.{succ u1} K (fun (x : K) => Eq.{succ u2} ((fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : K) => L) x) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K (fun (_x : K) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2398 : K) => L) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonUnitalNonAssocSemiring.toMul.{u1} K (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (NonUnitalNonAssocSemiring.toMul.{u2} L (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} L (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))))) (NonUnitalRingHomClass.toMulHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u2} L (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) (RingHomClass.toNonUnitalRingHomClass.{max u1 u2, u1, u2} (RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))) K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))) (RingHom.instRingHomClassRingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2)))))))) f x) y))
Case conversion may be inaccurate. Consider using '#align ring_hom.mem_field_range RingHom.mem_fieldRangeₓ'. -/
@[simp]
theorem mem_fieldRange {f : K →+* L} {y : L} : y ∈ f.fieldRange ↔ ∃ x, f x = y :=
  Iff.rfl
#align ring_hom.mem_field_range RingHom.mem_fieldRange

/- warning: ring_hom.field_range_eq_map -> RingHom.fieldRange_eq_map is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] (f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))), Eq.{succ u2} (Subfield.{u2} L _inst_2) (RingHom.fieldRange.{u1, u2} K L _inst_1 _inst_2 f) (Subfield.map.{u1, u2} K L _inst_1 _inst_2 f (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.hasTop.{u1} K _inst_1)))
but is expected to have type
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] (f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))), Eq.{succ u2} (Subfield.{u2} L _inst_2) (RingHom.fieldRange.{u1, u2} K L _inst_1 _inst_2 f) (Subfield.map.{u1, u2} K L _inst_1 _inst_2 f (Top.top.{u1} (Subfield.{u1} K _inst_1) (Subfield.instTopSubfield.{u1} K _inst_1)))
Case conversion may be inaccurate. Consider using '#align ring_hom.field_range_eq_map RingHom.fieldRange_eq_mapₓ'. -/
theorem fieldRange_eq_map : f.fieldRange = Subfield.map f ⊤ :=
  by
  ext
  simp
#align ring_hom.field_range_eq_map RingHom.fieldRange_eq_map

#print RingHom.map_fieldRange /-
theorem map_fieldRange : f.fieldRange.map g = (g.comp f).fieldRange := by
  simpa only [field_range_eq_map] using (⊤ : Subfield K).map_map g f
#align ring_hom.map_field_range RingHom.map_fieldRange
-/

/- warning: ring_hom.fintype_field_range -> RingHom.fintypeFieldRange is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] [_inst_4 : Fintype.{u1} K] [_inst_5 : DecidableEq.{succ u2} L] (f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))), Fintype.{u2} (coeSort.{succ u2, succ (succ u2)} (Subfield.{u2} L _inst_2) Type.{u2} (SetLike.hasCoeToSort.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.setLike.{u2} L _inst_2)) (RingHom.fieldRange.{u1, u2} K L _inst_1 _inst_2 f))
but is expected to have type
  forall {K : Type.{u1}} {L : Type.{u2}} [_inst_1 : Field.{u1} K] [_inst_2 : Field.{u2} L] [_inst_4 : Fintype.{u1} K] [_inst_5 : DecidableEq.{succ u2} L] (f : RingHom.{u1, u2} K L (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (NonAssocRing.toNonAssocSemiring.{u2} L (Ring.toNonAssocRing.{u2} L (DivisionRing.toRing.{u2} L (Field.toDivisionRing.{u2} L _inst_2))))), Fintype.{u2} (Subtype.{succ u2} L (fun (x : L) => Membership.mem.{u2, u2} L (Subfield.{u2} L _inst_2) (SetLike.instMembership.{u2, u2} (Subfield.{u2} L _inst_2) L (Subfield.instSetLikeSubfield.{u2} L _inst_2)) x (RingHom.fieldRange.{u1, u2} K L _inst_1 _inst_2 f)))
Case conversion may be inaccurate. Consider using '#align ring_hom.fintype_field_range RingHom.fintypeFieldRangeₓ'. -/
/-- The range of a morphism of fields is a fintype, if the domain is a fintype.

Note that this instance can cause a diamond with `subtype.fintype` if `L` is also a fintype.-/
instance fintypeFieldRange [Fintype K] [DecidableEq L] (f : K →+* L) : Fintype f.fieldRange :=
  Set.fintypeRange f
#align ring_hom.fintype_field_range RingHom.fintypeFieldRange

end RingHom

namespace Subfield

/-! # inf -/


/-- The inf of two subfields is their intersection. -/
instance : HasInf (Subfield K) :=
  ⟨fun s t =>
    { s.toSubring ⊓ t.toSubring with
      inv_mem' := fun x hx =>
        Subring.mem_inf.mpr
          ⟨s.inv_mem (Subring.mem_inf.mp hx).1, t.inv_mem (Subring.mem_inf.mp hx).2⟩ }⟩

/- warning: subfield.coe_inf -> Subfield.coe_inf is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (p : Subfield.{u1} K _inst_1) (p' : Subfield.{u1} K _inst_1), Eq.{succ u1} (Set.{u1} K) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) (HasInf.inf.{u1} (Subfield.{u1} K _inst_1) (Subfield.hasInf.{u1} K _inst_1) p p')) (Inter.inter.{u1} (Set.{u1} K) (Set.hasInter.{u1} K) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) p) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) p'))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (p : Subfield.{u1} K _inst_1) (p' : Subfield.{u1} K _inst_1), Eq.{succ u1} (Set.{u1} K) (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) (HasInf.inf.{u1} (Subfield.{u1} K _inst_1) (Subfield.instHasInfSubfield.{u1} K _inst_1) p p')) (Inter.inter.{u1} (Set.{u1} K) (Set.instInterSet.{u1} K) (Subsemigroup.carrier.{u1} K (MulOneClass.toMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Submonoid.toSubsemigroup.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subsemiring.toSubmonoid.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 p))))) (Subsemigroup.carrier.{u1} K (MulOneClass.toMul.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Submonoid.toSubsemigroup.{u1} K (MulZeroOneClass.toMulOneClass.{u1} K (NonAssocSemiring.toMulZeroOneClass.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) (Subsemiring.toSubmonoid.{u1} K (NonAssocRing.toNonAssocSemiring.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) (Subring.toSubsemiring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) (Subfield.toSubring.{u1} K _inst_1 p'))))))
Case conversion may be inaccurate. Consider using '#align subfield.coe_inf Subfield.coe_infₓ'. -/
@[simp]
theorem coe_inf (p p' : Subfield K) : ((p ⊓ p' : Subfield K) : Set K) = p ∩ p' :=
  rfl
#align subfield.coe_inf Subfield.coe_inf

/- warning: subfield.mem_inf -> Subfield.mem_inf is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {p : Subfield.{u1} K _inst_1} {p' : Subfield.{u1} K _inst_1} {x : K}, Iff (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x (HasInf.inf.{u1} (Subfield.{u1} K _inst_1) (Subfield.hasInf.{u1} K _inst_1) p p')) (And (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x p) (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x p'))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {p : Subfield.{u1} K _inst_1} {p' : Subfield.{u1} K _inst_1} {x : K}, Iff (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x (HasInf.inf.{u1} (Subfield.{u1} K _inst_1) (Subfield.instHasInfSubfield.{u1} K _inst_1) p p')) (And (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x p) (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x p'))
Case conversion may be inaccurate. Consider using '#align subfield.mem_inf Subfield.mem_infₓ'. -/
@[simp]
theorem mem_inf {p p' : Subfield K} {x : K} : x ∈ p ⊓ p' ↔ x ∈ p ∧ x ∈ p' :=
  Iff.rfl
#align subfield.mem_inf Subfield.mem_inf

instance : InfSet (Subfield K) :=
  ⟨fun S =>
    { infₛ (Subfield.toSubring '' S) with
      inv_mem' := by
        rintro x hx
        apply subring.mem_Inf.mpr
        rintro _ ⟨p, p_mem, rfl⟩
        exact p.inv_mem (subring.mem_Inf.mp hx p.to_subring ⟨p, p_mem, rfl⟩) }⟩

/- warning: subfield.coe_Inf -> Subfield.coe_infₛ is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (S : Set.{u1} (Subfield.{u1} K _inst_1)), Eq.{succ u1} (Set.{u1} K) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) (InfSet.infₛ.{u1} (Subfield.{u1} K _inst_1) (Subfield.hasInf.{u1} K _inst_1) S)) (Set.interᵢ.{u1, succ u1} K (Subfield.{u1} K _inst_1) (fun (s : Subfield.{u1} K _inst_1) => Set.interᵢ.{u1, 0} K (Membership.Mem.{u1, u1} (Subfield.{u1} K _inst_1) (Set.{u1} (Subfield.{u1} K _inst_1)) (Set.hasMem.{u1} (Subfield.{u1} K _inst_1)) s S) (fun (H : Membership.Mem.{u1, u1} (Subfield.{u1} K _inst_1) (Set.{u1} (Subfield.{u1} K _inst_1)) (Set.hasMem.{u1} (Subfield.{u1} K _inst_1)) s S) => (fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) s)))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (S : Set.{u1} (Subfield.{u1} K _inst_1)), Eq.{succ u1} (Set.{u1} K) (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) (InfSet.infₛ.{u1} (Subfield.{u1} K _inst_1) (Subfield.instInfSetSubfield.{u1} K _inst_1) S)) (Set.interᵢ.{u1, succ u1} K (Subfield.{u1} K _inst_1) (fun (s : Subfield.{u1} K _inst_1) => Set.interᵢ.{u1, 0} K (Membership.mem.{u1, u1} (Subfield.{u1} K _inst_1) (Set.{u1} (Subfield.{u1} K _inst_1)) (Set.instMembershipSet.{u1} (Subfield.{u1} K _inst_1)) s S) (fun (H : Membership.mem.{u1, u1} (Subfield.{u1} K _inst_1) (Set.{u1} (Subfield.{u1} K _inst_1)) (Set.instMembershipSet.{u1} (Subfield.{u1} K _inst_1)) s S) => SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) s)))
Case conversion may be inaccurate. Consider using '#align subfield.coe_Inf Subfield.coe_infₛₓ'. -/
@[simp, norm_cast]
theorem coe_infₛ (S : Set (Subfield K)) : ((infₛ S : Subfield K) : Set K) = ⋂ s ∈ S, ↑s :=
  show ((infₛ (Subfield.toSubring '' S) : Subring K) : Set K) = ⋂ s ∈ S, ↑s
    by
    ext x
    rw [Subring.coe_infₛ, Set.mem_interᵢ, Set.mem_interᵢ]
    exact
      ⟨fun h s s' ⟨s_mem, s'_eq⟩ => h s.toSubring _ ⟨⟨s, s_mem, rfl⟩, s'_eq⟩,
        fun h s s' ⟨⟨s'', s''_mem, s_eq⟩, (s'_eq : ↑s = s')⟩ =>
        h s'' _ ⟨s''_mem, by simp [← s_eq, ← s'_eq]⟩⟩
#align subfield.coe_Inf Subfield.coe_infₛ

/- warning: subfield.mem_Inf -> Subfield.mem_infₛ is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {S : Set.{u1} (Subfield.{u1} K _inst_1)} {x : K}, Iff (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x (InfSet.infₛ.{u1} (Subfield.{u1} K _inst_1) (Subfield.hasInf.{u1} K _inst_1) S)) (forall (p : Subfield.{u1} K _inst_1), (Membership.Mem.{u1, u1} (Subfield.{u1} K _inst_1) (Set.{u1} (Subfield.{u1} K _inst_1)) (Set.hasMem.{u1} (Subfield.{u1} K _inst_1)) p S) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x p))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {S : Set.{u1} (Subfield.{u1} K _inst_1)} {x : K}, Iff (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x (InfSet.infₛ.{u1} (Subfield.{u1} K _inst_1) (Subfield.instInfSetSubfield.{u1} K _inst_1) S)) (forall (p : Subfield.{u1} K _inst_1), (Membership.mem.{u1, u1} (Subfield.{u1} K _inst_1) (Set.{u1} (Subfield.{u1} K _inst_1)) (Set.instMembershipSet.{u1} (Subfield.{u1} K _inst_1)) p S) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x p))
Case conversion may be inaccurate. Consider using '#align subfield.mem_Inf Subfield.mem_infₛₓ'. -/
theorem mem_infₛ {S : Set (Subfield K)} {x : K} : x ∈ infₛ S ↔ ∀ p ∈ S, x ∈ p :=
  Subring.mem_infₛ.trans
    ⟨fun h p hp => h p.toSubring ⟨p, hp, rfl⟩, fun h p ⟨p', hp', p_eq⟩ => p_eq ▸ h p' hp'⟩
#align subfield.mem_Inf Subfield.mem_infₛ

#print Subfield.infₛ_toSubring /-
@[simp]
theorem infₛ_toSubring (s : Set (Subfield K)) :
    (infₛ s).toSubring = ⨅ t ∈ s, Subfield.toSubring t :=
  by
  ext x
  rw [mem_to_subring, mem_Inf]
  erw [Subring.mem_infₛ]
  exact
    ⟨fun h p ⟨p', hp⟩ => hp ▸ subring.mem_Inf.mpr fun p ⟨hp', hp⟩ => hp ▸ h _ hp', fun h p hp =>
      h p.toSubring
        ⟨p,
          Subring.ext fun x =>
            ⟨fun hx => subring.mem_Inf.mp hx _ ⟨hp, rfl⟩, fun hx =>
              subring.mem_Inf.mpr fun p' ⟨hp, p'_eq⟩ => p'_eq ▸ hx⟩⟩⟩
#align subfield.Inf_to_subring Subfield.infₛ_toSubring
-/

#print Subfield.isGLB_infₛ /-
theorem isGLB_infₛ (S : Set (Subfield K)) : IsGLB S (infₛ S) :=
  by
  refine' IsGLB.of_image (fun s t => show (s : Set K) ≤ t ↔ s ≤ t from SetLike.coe_subset_coe) _
  convert isGLB_binfᵢ
  exact coe_Inf _
#align subfield.is_glb_Inf Subfield.isGLB_infₛ
-/

/-- Subfields of a ring form a complete lattice. -/
instance : CompleteLattice (Subfield K) :=
  {
    completeLatticeOfInf (Subfield K) isGLB_infₛ with
    top := ⊤
    le_top := fun s x hx => trivial
    inf := (· ⊓ ·)
    inf_le_left := fun s t x => And.left
    inf_le_right := fun s t x => And.right
    le_inf := fun s t₁ t₂ h₁ h₂ x hx => ⟨h₁ hx, h₂ hx⟩ }

/-! # subfield closure of a subset -/


/- ./././Mathport/Syntax/Translate/Expr.lean:370:4: unsupported set replacement {(«expr / »(x, y)) | (x «expr ∈ » subring.closure[subring.closure] s) (y «expr ∈ » subring.closure[subring.closure] s)} -/
#print Subfield.closure /-
/-- The `subfield` generated by a set. -/
def closure (s : Set K) : Subfield K
    where
  carrier :=
    "./././Mathport/Syntax/Translate/Expr.lean:370:4: unsupported set replacement {(«expr / »(x, y)) | (x «expr ∈ » subring.closure[subring.closure] s) (y «expr ∈ » subring.closure[subring.closure] s)}"
  zero_mem' := ⟨0, Subring.zero_mem _, 1, Subring.one_mem _, div_one _⟩
  one_mem' := ⟨1, Subring.one_mem _, 1, Subring.one_mem _, div_one _⟩
  neg_mem' := fun x ⟨y, hy, z, hz, x_eq⟩ => ⟨-y, Subring.neg_mem _ hy, z, hz, x_eq ▸ neg_div _ _⟩
  inv_mem' := fun x ⟨y, hy, z, hz, x_eq⟩ => ⟨z, hz, y, hy, x_eq ▸ (inv_div _ _).symm⟩
  add_mem' x y x_mem y_mem :=
    by
    obtain ⟨nx, hnx, dx, hdx, rfl⟩ := id x_mem
    obtain ⟨ny, hny, dy, hdy, rfl⟩ := id y_mem
    by_cases hx0 : dx = 0; · rwa [hx0, div_zero, zero_add]
    by_cases hy0 : dy = 0; · rwa [hy0, div_zero, add_zero]
    exact
      ⟨nx * dy + dx * ny, Subring.add_mem _ (Subring.mul_mem _ hnx hdy) (Subring.mul_mem _ hdx hny),
        dx * dy, Subring.mul_mem _ hdx hdy, (div_add_div nx ny hx0 hy0).symm⟩
  mul_mem' x y x_mem y_mem :=
    by
    obtain ⟨nx, hnx, dx, hdx, rfl⟩ := id x_mem
    obtain ⟨ny, hny, dy, hdy, rfl⟩ := id y_mem
    exact
      ⟨nx * ny, Subring.mul_mem _ hnx hny, dx * dy, Subring.mul_mem _ hdx hdy,
        (div_mul_div_comm _ _ _ _).symm⟩
#align subfield.closure Subfield.closure
-/

/- warning: subfield.mem_closure_iff -> Subfield.mem_closure_iff is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Set.{u1} K} {x : K}, Iff (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x (Subfield.closure.{u1} K _inst_1 s)) (Exists.{succ u1} K (fun (y : K) => Exists.{0} (Membership.Mem.{u1, u1} K (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (SetLike.hasMem.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.setLike.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) y (Subring.closure.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) s)) (fun (H : Membership.Mem.{u1, u1} K (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (SetLike.hasMem.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.setLike.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) y (Subring.closure.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) s)) => Exists.{succ u1} K (fun (z : K) => Exists.{0} (Membership.Mem.{u1, u1} K (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (SetLike.hasMem.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.setLike.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) z (Subring.closure.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) s)) (fun (H : Membership.Mem.{u1, u1} K (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (SetLike.hasMem.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.setLike.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) z (Subring.closure.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) s)) => Eq.{succ u1} K (HDiv.hDiv.{u1, u1, u1} K K K (instHDiv.{u1} K (DivInvMonoid.toHasDiv.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) y z) x)))))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Set.{u1} K} {x : K}, Iff (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x (Subfield.closure.{u1} K _inst_1 s)) (Exists.{succ u1} K (fun (y : K) => And (Membership.mem.{u1, u1} K (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (SetLike.instMembership.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.instSetLikeSubring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) y (Subring.closure.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) s)) (Exists.{succ u1} K (fun (z : K) => And (Membership.mem.{u1, u1} K (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (SetLike.instMembership.{u1, u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) K (Subring.instSetLikeSubring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))) z (Subring.closure.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) s)) (Eq.{succ u1} K (HDiv.hDiv.{u1, u1, u1} K K K (instHDiv.{u1} K (Field.toDiv.{u1} K _inst_1)) y z) x)))))
Case conversion may be inaccurate. Consider using '#align subfield.mem_closure_iff Subfield.mem_closure_iffₓ'. -/
theorem mem_closure_iff {s : Set K} {x} :
    x ∈ closure s ↔ ∃ y ∈ Subring.closure s, ∃ z ∈ Subring.closure s, y / z = x :=
  Iff.rfl
#align subfield.mem_closure_iff Subfield.mem_closure_iff

/- warning: subfield.subring_closure_le -> Subfield.subring_closure_le is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Set.{u1} K), LE.le.{u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (Preorder.toLE.{u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (PartialOrder.toPreorder.{u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (Subring.completeLattice.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Subring.closure.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) s) (Subfield.toSubring.{u1} K _inst_1 (Subfield.closure.{u1} K _inst_1 s))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] (s : Set.{u1} K), LE.le.{u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (Preorder.toLE.{u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (PartialOrder.toPreorder.{u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) (Subring.instCompleteLatticeSubring.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) (Subring.closure.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)) s) (Subfield.toSubring.{u1} K _inst_1 (Subfield.closure.{u1} K _inst_1 s))
Case conversion may be inaccurate. Consider using '#align subfield.subring_closure_le Subfield.subring_closure_leₓ'. -/
theorem subring_closure_le (s : Set K) : Subring.closure s ≤ (closure s).toSubring := fun x hx =>
  ⟨x, hx, 1, Subring.one_mem _, div_one x⟩
#align subfield.subring_closure_le Subfield.subring_closure_le

/- warning: subfield.subset_closure -> Subfield.subset_closure is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Set.{u1} K}, HasSubset.Subset.{u1} (Set.{u1} K) (Set.hasSubset.{u1} K) s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) (Subfield.closure.{u1} K _inst_1 s))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Set.{u1} K}, HasSubset.Subset.{u1} (Set.{u1} K) (Set.instHasSubsetSet.{u1} K) s (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) (Subfield.closure.{u1} K _inst_1 s))
Case conversion may be inaccurate. Consider using '#align subfield.subset_closure Subfield.subset_closureₓ'. -/
/-- The subfield generated by a set includes the set. -/
@[simp]
theorem subset_closure {s : Set K} : s ⊆ closure s :=
  Set.Subset.trans Subring.subset_closure (subring_closure_le s)
#align subfield.subset_closure Subfield.subset_closure

/- warning: subfield.not_mem_of_not_mem_closure -> Subfield.not_mem_of_not_mem_closure is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Set.{u1} K} {P : K}, (Not (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) P (Subfield.closure.{u1} K _inst_1 s))) -> (Not (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) P s))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Set.{u1} K} {P : K}, (Not (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) P (Subfield.closure.{u1} K _inst_1 s))) -> (Not (Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) P s))
Case conversion may be inaccurate. Consider using '#align subfield.not_mem_of_not_mem_closure Subfield.not_mem_of_not_mem_closureₓ'. -/
theorem not_mem_of_not_mem_closure {s : Set K} {P : K} (hP : P ∉ closure s) : P ∉ s := fun h =>
  hP (subset_closure h)
#align subfield.not_mem_of_not_mem_closure Subfield.not_mem_of_not_mem_closure

/- warning: subfield.mem_closure -> Subfield.mem_closure is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {x : K} {s : Set.{u1} K}, Iff (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x (Subfield.closure.{u1} K _inst_1 s)) (forall (S : Subfield.{u1} K _inst_1), (HasSubset.Subset.{u1} (Set.{u1} K) (Set.hasSubset.{u1} K) s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) S)) -> (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x S))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {x : K} {s : Set.{u1} K}, Iff (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x (Subfield.closure.{u1} K _inst_1 s)) (forall (S : Subfield.{u1} K _inst_1), (HasSubset.Subset.{u1} (Set.{u1} K) (Set.instHasSubsetSet.{u1} K) s (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) S)) -> (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x S))
Case conversion may be inaccurate. Consider using '#align subfield.mem_closure Subfield.mem_closureₓ'. -/
theorem mem_closure {x : K} {s : Set K} : x ∈ closure s ↔ ∀ S : Subfield K, s ⊆ S → x ∈ S :=
  ⟨fun ⟨y, hy, z, hz, x_eq⟩ t le =>
    x_eq ▸
      t.div_mem (Subring.mem_closure.mp hy t.toSubring le)
        (Subring.mem_closure.mp hz t.toSubring le),
    fun h => h (closure s) subset_closure⟩
#align subfield.mem_closure Subfield.mem_closure

/- warning: subfield.closure_le -> Subfield.closure_le is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Set.{u1} K} {t : Subfield.{u1} K _inst_1}, Iff (LE.le.{u1} (Subfield.{u1} K _inst_1) (Preorder.toLE.{u1} (Subfield.{u1} K _inst_1) (PartialOrder.toPreorder.{u1} (Subfield.{u1} K _inst_1) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subfield.{u1} K _inst_1) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subfield.{u1} K _inst_1) (Subfield.completeLattice.{u1} K _inst_1))))) (Subfield.closure.{u1} K _inst_1 s) t) (HasSubset.Subset.{u1} (Set.{u1} K) (Set.hasSubset.{u1} K) s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) t))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Set.{u1} K} {t : Subfield.{u1} K _inst_1}, Iff (LE.le.{u1} (Subfield.{u1} K _inst_1) (Preorder.toLE.{u1} (Subfield.{u1} K _inst_1) (PartialOrder.toPreorder.{u1} (Subfield.{u1} K _inst_1) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subfield.{u1} K _inst_1) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subfield.{u1} K _inst_1) (Subfield.instCompleteLatticeSubfield.{u1} K _inst_1))))) (Subfield.closure.{u1} K _inst_1 s) t) (HasSubset.Subset.{u1} (Set.{u1} K) (Set.instHasSubsetSet.{u1} K) s (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) t))
Case conversion may be inaccurate. Consider using '#align subfield.closure_le Subfield.closure_leₓ'. -/
/-- A subfield `t` includes `closure s` if and only if it includes `s`. -/
@[simp]
theorem closure_le {s : Set K} {t : Subfield K} : closure s ≤ t ↔ s ⊆ t :=
  ⟨Set.Subset.trans subset_closure, fun h x hx => mem_closure.mp hx t h⟩
#align subfield.closure_le Subfield.closure_le

/- warning: subfield.closure_mono -> Subfield.closure_mono is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {{s : Set.{u1} K}} {{t : Set.{u1} K}}, (HasSubset.Subset.{u1} (Set.{u1} K) (Set.hasSubset.{u1} K) s t) -> (LE.le.{u1} (Subfield.{u1} K _inst_1) (Preorder.toLE.{u1} (Subfield.{u1} K _inst_1) (PartialOrder.toPreorder.{u1} (Subfield.{u1} K _inst_1) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subfield.{u1} K _inst_1) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subfield.{u1} K _inst_1) (Subfield.completeLattice.{u1} K _inst_1))))) (Subfield.closure.{u1} K _inst_1 s) (Subfield.closure.{u1} K _inst_1 t))
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {{s : Set.{u1} K}} {{t : Set.{u1} K}}, (HasSubset.Subset.{u1} (Set.{u1} K) (Set.instHasSubsetSet.{u1} K) s t) -> (LE.le.{u1} (Subfield.{u1} K _inst_1) (Preorder.toLE.{u1} (Subfield.{u1} K _inst_1) (PartialOrder.toPreorder.{u1} (Subfield.{u1} K _inst_1) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subfield.{u1} K _inst_1) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subfield.{u1} K _inst_1) (Subfield.instCompleteLatticeSubfield.{u1} K _inst_1))))) (Subfield.closure.{u1} K _inst_1 s) (Subfield.closure.{u1} K _inst_1 t))
Case conversion may be inaccurate. Consider using '#align subfield.closure_mono Subfield.closure_monoₓ'. -/
/-- Subfield closure of a set is monotone in its argument: if `s ⊆ t`,
then `closure s ≤ closure t`. -/
theorem closure_mono ⦃s t : Set K⦄ (h : s ⊆ t) : closure s ≤ closure t :=
  closure_le.2 <| Set.Subset.trans h subset_closure
#align subfield.closure_mono Subfield.closure_mono

/- warning: subfield.closure_eq_of_le -> Subfield.closure_eq_of_le is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Set.{u1} K} {t : Subfield.{u1} K _inst_1}, (HasSubset.Subset.{u1} (Set.{u1} K) (Set.hasSubset.{u1} K) s ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))) t)) -> (LE.le.{u1} (Subfield.{u1} K _inst_1) (Preorder.toLE.{u1} (Subfield.{u1} K _inst_1) (PartialOrder.toPreorder.{u1} (Subfield.{u1} K _inst_1) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subfield.{u1} K _inst_1) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subfield.{u1} K _inst_1) (Subfield.completeLattice.{u1} K _inst_1))))) t (Subfield.closure.{u1} K _inst_1 s)) -> (Eq.{succ u1} (Subfield.{u1} K _inst_1) (Subfield.closure.{u1} K _inst_1 s) t)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Set.{u1} K} {t : Subfield.{u1} K _inst_1}, (HasSubset.Subset.{u1} (Set.{u1} K) (Set.instHasSubsetSet.{u1} K) s (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1) t)) -> (LE.le.{u1} (Subfield.{u1} K _inst_1) (Preorder.toLE.{u1} (Subfield.{u1} K _inst_1) (PartialOrder.toPreorder.{u1} (Subfield.{u1} K _inst_1) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subfield.{u1} K _inst_1) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subfield.{u1} K _inst_1) (Subfield.instCompleteLatticeSubfield.{u1} K _inst_1))))) t (Subfield.closure.{u1} K _inst_1 s)) -> (Eq.{succ u1} (Subfield.{u1} K _inst_1) (Subfield.closure.{u1} K _inst_1 s) t)
Case conversion may be inaccurate. Consider using '#align subfield.closure_eq_of_le Subfield.closure_eq_of_leₓ'. -/
theorem closure_eq_of_le {s : Set K} {t : Subfield K} (h₁ : s ⊆ t) (h₂ : t ≤ closure s) :
    closure s = t :=
  le_antisymm (closure_le.2 h₁) h₂
#align subfield.closure_eq_of_le Subfield.closure_eq_of_le

/- warning: subfield.closure_induction -> Subfield.closure_induction is a dubious translation:
lean 3 declaration is
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Set.{u1} K} {p : K -> Prop} {x : K}, (Membership.Mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.hasMem.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)) x (Subfield.closure.{u1} K _inst_1 s)) -> (forall (x : K), (Membership.Mem.{u1, u1} K (Set.{u1} K) (Set.hasMem.{u1} K) x s) -> (p x)) -> (p (OfNat.ofNat.{u1} K 1 (OfNat.mk.{u1} K 1 (One.one.{u1} K (AddMonoidWithOne.toOne.{u1} K (AddGroupWithOne.toAddMonoidWithOne.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))))) -> (forall (x : K) (y : K), (p x) -> (p y) -> (p (HAdd.hAdd.{u1, u1, u1} K K K (instHAdd.{u1} K (Distrib.toHasAdd.{u1} K (Ring.toDistrib.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) x y))) -> (forall (x : K), (p x) -> (p (Neg.neg.{u1} K (SubNegMonoid.toHasNeg.{u1} K (AddGroup.toSubNegMonoid.{u1} K (AddGroupWithOne.toAddGroup.{u1} K (NonAssocRing.toAddGroupWithOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) x))) -> (forall (x : K), (p x) -> (p (Inv.inv.{u1} K (DivInvMonoid.toHasInv.{u1} K (DivisionRing.toDivInvMonoid.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) x))) -> (forall (x : K) (y : K), (p x) -> (p y) -> (p (HMul.hMul.{u1, u1, u1} K K K (instHMul.{u1} K (Distrib.toHasMul.{u1} K (Ring.toDistrib.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))) x y))) -> (p x)
but is expected to have type
  forall {K : Type.{u1}} [_inst_1 : Field.{u1} K] {s : Set.{u1} K} {p : K -> Prop} {x : K}, (Membership.mem.{u1, u1} K (Subfield.{u1} K _inst_1) (SetLike.instMembership.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1)) x (Subfield.closure.{u1} K _inst_1 s)) -> (forall (x : K), (Membership.mem.{u1, u1} K (Set.{u1} K) (Set.instMembershipSet.{u1} K) x s) -> (p x)) -> (p (OfNat.ofNat.{u1} K 1 (One.toOfNat1.{u1} K (NonAssocRing.toOne.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))))))) -> (forall (x : K) (y : K), (p x) -> (p y) -> (p (HAdd.hAdd.{u1, u1, u1} K K K (instHAdd.{u1} K (Distrib.toAdd.{u1} K (NonUnitalNonAssocSemiring.toDistrib.{u1} K (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))))) x y))) -> (forall (x : K), (p x) -> (p (Neg.neg.{u1} K (Ring.toNeg.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1))) x))) -> (forall (x : K), (p x) -> (p (Inv.inv.{u1} K (Field.toInv.{u1} K _inst_1) x))) -> (forall (x : K) (y : K), (p x) -> (p y) -> (p (HMul.hMul.{u1, u1, u1} K K K (instHMul.{u1} K (NonUnitalNonAssocRing.toMul.{u1} K (NonAssocRing.toNonUnitalNonAssocRing.{u1} K (Ring.toNonAssocRing.{u1} K (DivisionRing.toRing.{u1} K (Field.toDivisionRing.{u1} K _inst_1)))))) x y))) -> (p x)
Case conversion may be inaccurate. Consider using '#align subfield.closure_induction Subfield.closure_inductionₓ'. -/
/-- An induction principle for closure membership. If `p` holds for `1`, and all elements
of `s`, and is preserved under addition, negation, and multiplication, then `p` holds for all
elements of the closure of `s`. -/
@[elab_as_elim]
theorem closure_induction {s : Set K} {p : K → Prop} {x} (h : x ∈ closure s) (Hs : ∀ x ∈ s, p x)
    (H1 : p 1) (Hadd : ∀ x y, p x → p y → p (x + y)) (Hneg : ∀ x, p x → p (-x))
    (Hinv : ∀ x, p x → p x⁻¹) (Hmul : ∀ x y, p x → p y → p (x * y)) : p x :=
  (@closure_le _ _ _
        ⟨p, Hmul, H1, Hadd, @add_neg_self K _ 1 ▸ Hadd _ _ H1 (Hneg _ H1), Hneg, Hinv⟩).2
    Hs h
#align subfield.closure_induction Subfield.closure_induction

variable (K)

/- warning: subfield.gi -> Subfield.gi is a dubious translation:
lean 3 declaration is
  forall (K : Type.{u1}) [_inst_1 : Field.{u1} K], GaloisInsertion.{u1, u1} (Set.{u1} K) (Subfield.{u1} K _inst_1) (PartialOrder.toPreorder.{u1} (Set.{u1} K) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} K) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} K) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} K) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} K) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} K) (Set.completeBooleanAlgebra.{u1} K))))))) (PartialOrder.toPreorder.{u1} (Subfield.{u1} K _inst_1) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subfield.{u1} K _inst_1) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subfield.{u1} K _inst_1) (Subfield.completeLattice.{u1} K _inst_1)))) (Subfield.closure.{u1} K _inst_1) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subfield.{u1} K _inst_1) (Set.{u1} K) (HasLiftT.mk.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (CoeTCₓ.coe.{succ u1, succ u1} (Subfield.{u1} K _inst_1) (Set.{u1} K) (SetLike.Set.hasCoeT.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.setLike.{u1} K _inst_1)))))
but is expected to have type
  forall (K : Type.{u1}) [_inst_1 : Field.{u1} K], GaloisInsertion.{u1, u1} (Set.{u1} K) (Subfield.{u1} K _inst_1) (PartialOrder.toPreorder.{u1} (Set.{u1} K) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} K) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} K) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} K) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} K) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} K) (Set.instCompleteBooleanAlgebraSet.{u1} K))))))) (PartialOrder.toPreorder.{u1} (Subfield.{u1} K _inst_1) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subfield.{u1} K _inst_1) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subfield.{u1} K _inst_1) (Subfield.instCompleteLatticeSubfield.{u1} K _inst_1)))) (Subfield.closure.{u1} K _inst_1) (SetLike.coe.{u1, u1} (Subfield.{u1} K _inst_1) K (Subfield.instSetLikeSubfield.{u1} K _inst_1))
Case conversion may be inaccurate. Consider using '#align subfield.gi Subfield.giₓ'. -/
/-- `closure` forms a Galois insertion with the coercion to set. -/
protected def gi : GaloisInsertion (@closure K _) coe
    where
  choice s _ := closure s
  gc s t := closure_le
  le_l_u s := subset_closure
  choice_eq s h := rfl
#align subfield.gi Subfield.gi

variable {K}

#print Subfield.closure_eq /-
/-- Closure of a subfield `S` equals `S`. -/
theorem closure_eq (s : Subfield K) : closure (s : Set K) = s :=
  (Subfield.gi K).l_u_eq s
#align subfield.closure_eq Subfield.closure_eq
-/

#print Subfield.closure_empty /-
@[simp]
theorem closure_empty : closure (∅ : Set K) = ⊥ :=
  (Subfield.gi K).gc.l_bot
#align subfield.closure_empty Subfield.closure_empty
-/

#print Subfield.closure_univ /-
@[simp]
theorem closure_univ : closure (Set.univ : Set K) = ⊤ :=
  @coe_top K _ ▸ closure_eq ⊤
#align subfield.closure_univ Subfield.closure_univ
-/

#print Subfield.closure_union /-
theorem closure_union (s t : Set K) : closure (s ∪ t) = closure s ⊔ closure t :=
  (Subfield.gi K).gc.l_sup
#align subfield.closure_union Subfield.closure_union
-/

#print Subfield.closure_unionᵢ /-
theorem closure_unionᵢ {ι} (s : ι → Set K) : closure (⋃ i, s i) = ⨆ i, closure (s i) :=
  (Subfield.gi K).gc.l_supᵢ
#align subfield.closure_Union Subfield.closure_unionᵢ
-/

#print Subfield.closure_unionₛ /-
theorem closure_unionₛ (s : Set (Set K)) : closure (⋃₀ s) = ⨆ t ∈ s, closure t :=
  (Subfield.gi K).gc.l_supₛ
#align subfield.closure_sUnion Subfield.closure_unionₛ
-/

#print Subfield.map_sup /-
theorem map_sup (s t : Subfield K) (f : K →+* L) : (s ⊔ t).map f = s.map f ⊔ t.map f :=
  (gc_map_comap f).l_sup
#align subfield.map_sup Subfield.map_sup
-/

#print Subfield.map_supᵢ /-
theorem map_supᵢ {ι : Sort _} (f : K →+* L) (s : ι → Subfield K) :
    (supᵢ s).map f = ⨆ i, (s i).map f :=
  (gc_map_comap f).l_supᵢ
#align subfield.map_supr Subfield.map_supᵢ
-/

#print Subfield.comap_inf /-
theorem comap_inf (s t : Subfield L) (f : K →+* L) : (s ⊓ t).comap f = s.comap f ⊓ t.comap f :=
  (gc_map_comap f).u_inf
#align subfield.comap_inf Subfield.comap_inf
-/

#print Subfield.comap_infᵢ /-
theorem comap_infᵢ {ι : Sort _} (f : K →+* L) (s : ι → Subfield L) :
    (infᵢ s).comap f = ⨅ i, (s i).comap f :=
  (gc_map_comap f).u_infᵢ
#align subfield.comap_infi Subfield.comap_infᵢ
-/

#print Subfield.map_bot /-
@[simp]
theorem map_bot (f : K →+* L) : (⊥ : Subfield K).map f = ⊥ :=
  (gc_map_comap f).l_bot
#align subfield.map_bot Subfield.map_bot
-/

#print Subfield.comap_top /-
@[simp]
theorem comap_top (f : K →+* L) : (⊤ : Subfield L).comap f = ⊤ :=
  (gc_map_comap f).u_top
#align subfield.comap_top Subfield.comap_top
-/

#print Subfield.mem_supᵢ_of_directed /-
/-- The underlying set of a non-empty directed Sup of subfields is just a union of the subfields.
  Note that this fails without the directedness assumption (the union of two subfields is
  typically not a subfield) -/
theorem mem_supᵢ_of_directed {ι} [hι : Nonempty ι] {S : ι → Subfield K} (hS : Directed (· ≤ ·) S)
    {x : K} : (x ∈ ⨆ i, S i) ↔ ∃ i, x ∈ S i :=
  by
  refine' ⟨_, fun ⟨i, hi⟩ => (SetLike.le_def.1 <| le_supᵢ S i) hi⟩
  suffices x ∈ closure (⋃ i, (S i : Set K)) → ∃ i, x ∈ S i by
    simpa only [closure_unionᵢ, closure_eq]
  refine' fun hx => closure_induction hx (fun x => set.mem_Union.mp) _ _ _ _ _
  · exact hι.elim fun i => ⟨i, (S i).one_mem⟩
  · rintro x y ⟨i, hi⟩ ⟨j, hj⟩
    obtain ⟨k, hki, hkj⟩ := hS i j
    exact ⟨k, (S k).add_mem (hki hi) (hkj hj)⟩
  · rintro x ⟨i, hi⟩
    exact ⟨i, (S i).neg_mem hi⟩
  · rintro x ⟨i, hi⟩
    exact ⟨i, (S i).inv_mem hi⟩
  · rintro x y ⟨i, hi⟩ ⟨j, hj⟩
    obtain ⟨k, hki, hkj⟩ := hS i j
    exact ⟨k, (S k).mul_mem (hki hi) (hkj hj)⟩
#align subfield.mem_supr_of_directed Subfield.mem_supᵢ_of_directed
-/

#print Subfield.coe_supᵢ_of_directed /-
theorem coe_supᵢ_of_directed {ι} [hι : Nonempty ι] {S : ι → Subfield K} (hS : Directed (· ≤ ·) S) :
    ((⨆ i, S i : Subfield K) : Set K) = ⋃ i, ↑(S i) :=
  Set.ext fun x => by simp [mem_supr_of_directed hS]
#align subfield.coe_supr_of_directed Subfield.coe_supᵢ_of_directed
-/

#print Subfield.mem_supₛ_of_directedOn /-
theorem mem_supₛ_of_directedOn {S : Set (Subfield K)} (Sne : S.Nonempty) (hS : DirectedOn (· ≤ ·) S)
    {x : K} : x ∈ supₛ S ↔ ∃ s ∈ S, x ∈ s :=
  by
  haveI : Nonempty S := Sne.to_subtype
  simp only [supₛ_eq_supᵢ', mem_supr_of_directed hS.directed_coe, SetCoe.exists, Subtype.coe_mk]
#align subfield.mem_Sup_of_directed_on Subfield.mem_supₛ_of_directedOn
-/

#print Subfield.coe_supₛ_of_directedOn /-
theorem coe_supₛ_of_directedOn {S : Set (Subfield K)} (Sne : S.Nonempty)
    (hS : DirectedOn (· ≤ ·) S) : (↑(supₛ S) : Set K) = ⋃ s ∈ S, ↑s :=
  Set.ext fun x => by simp [mem_Sup_of_directed_on Sne hS]
#align subfield.coe_Sup_of_directed_on Subfield.coe_supₛ_of_directedOn
-/

end Subfield

namespace RingHom

variable {s : Subfield K}

open Subfield

#print RingHom.rangeRestrictField /-
/-- Restriction of a ring homomorphism to its range interpreted as a subfield. -/
def rangeRestrictField (f : K →+* L) : K →+* f.fieldRange :=
  f.srangeRestrict
#align ring_hom.range_restrict_field RingHom.rangeRestrictField
-/

#print RingHom.coe_rangeRestrictField /-
@[simp]
theorem coe_rangeRestrictField (f : K →+* L) (x : K) : (f.rangeRestrictField x : L) = f x :=
  rfl
#align ring_hom.coe_range_restrict_field RingHom.coe_rangeRestrictField
-/

#print RingHom.eqLocusField /-
/-- The subfield of elements `x : R` such that `f x = g x`, i.e.,
the equalizer of f and g as a subfield of R -/
def eqLocusField (f g : K →+* L) : Subfield K :=
  {
    (f : K →+* L).eqLocus
      g with
    inv_mem' := fun x (hx : f x = g x) => show f x⁻¹ = g x⁻¹ by rw [map_inv₀ f, map_inv₀ g, hx]
    carrier := { x | f x = g x } }
#align ring_hom.eq_locus_field RingHom.eqLocusField
-/

#print RingHom.eqOn_field_closure /-
/-- If two ring homomorphisms are equal on a set, then they are equal on its subfield closure. -/
theorem eqOn_field_closure {f g : K →+* L} {s : Set K} (h : Set.EqOn f g s) :
    Set.EqOn f g (closure s) :=
  show closure s ≤ f.eqLocusField g from closure_le.2 h
#align ring_hom.eq_on_field_closure RingHom.eqOn_field_closure
-/

#print RingHom.eq_of_eqOn_subfield_top /-
theorem eq_of_eqOn_subfield_top {f g : K →+* L} (h : Set.EqOn f g (⊤ : Subfield K)) : f = g :=
  ext fun x => h trivial
#align ring_hom.eq_of_eq_on_subfield_top RingHom.eq_of_eqOn_subfield_top
-/

#print RingHom.eq_of_eqOn_of_field_closure_eq_top /-
theorem eq_of_eqOn_of_field_closure_eq_top {s : Set K} (hs : closure s = ⊤) {f g : K →+* L}
    (h : s.EqOn f g) : f = g :=
  eq_of_eqOn_subfield_top <| hs ▸ eqOn_field_closure h
#align ring_hom.eq_of_eq_on_of_field_closure_eq_top RingHom.eq_of_eqOn_of_field_closure_eq_top
-/

#print RingHom.field_closure_preimage_le /-
theorem field_closure_preimage_le (f : K →+* L) (s : Set L) :
    closure (f ⁻¹' s) ≤ (closure s).comap f :=
  closure_le.2 fun x hx => SetLike.mem_coe.2 <| mem_comap.2 <| subset_closure hx
#align ring_hom.field_closure_preimage_le RingHom.field_closure_preimage_le
-/

#print RingHom.map_field_closure /-
/-- The image under a ring homomorphism of the subfield generated by a set equals
the subfield generated by the image of the set. -/
theorem map_field_closure (f : K →+* L) (s : Set K) : (closure s).map f = closure (f '' s) :=
  le_antisymm
    (map_le_iff_le_comap.2 <|
      le_trans (closure_mono <| Set.subset_preimage_image _ _) (field_closure_preimage_le _ _))
    (closure_le.2 <| Set.image_subset _ subset_closure)
#align ring_hom.map_field_closure RingHom.map_field_closure
-/

end RingHom

namespace Subfield

open RingHom

#print Subfield.inclusion /-
/-- The ring homomorphism associated to an inclusion of subfields. -/
def inclusion {S T : Subfield K} (h : S ≤ T) : S →+* T :=
  S.Subtype.codRestrict _ fun x => h x.2
#align subfield.inclusion Subfield.inclusion
-/

#print Subfield.fieldRange_subtype /-
@[simp]
theorem fieldRange_subtype (s : Subfield K) : s.Subtype.fieldRange = s :=
  SetLike.ext' <| (coe_rangeS _).trans Subtype.range_coe
#align subfield.field_range_subtype Subfield.fieldRange_subtype
-/

end Subfield

namespace RingEquiv

variable {s t : Subfield K}

#print RingEquiv.subfieldCongr /-
/-- Makes the identity isomorphism from a proof two subfields of a multiplicative
    monoid are equal. -/
def subfieldCongr (h : s = t) : s ≃+* t :=
  {
    Equiv.setCongr <| SetLike.ext'_iff.1
        h with
    map_mul' := fun _ _ => rfl
    map_add' := fun _ _ => rfl }
#align ring_equiv.subfield_congr RingEquiv.subfieldCongr
-/

end RingEquiv

namespace Subfield

variable {s : Set K}

#print Subfield.closure_preimage_le /-
theorem closure_preimage_le (f : K →+* L) (s : Set L) : closure (f ⁻¹' s) ≤ (closure s).comap f :=
  closure_le.2 fun x hx => SetLike.mem_coe.2 <| mem_comap.2 <| subset_closure hx
#align subfield.closure_preimage_le Subfield.closure_preimage_le
-/

end Subfield

