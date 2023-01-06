/-
Copyright (c) 2020 Ashvni Narayanan. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Ashvni Narayanan

! This file was ported from Lean 3 source module ring_theory.subring.basic
! leanprover-community/mathlib commit 26f081a2fb920140ed5bc5cc5344e84bcc7cb2b2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.Subgroup.Basic
import Mathbin.RingTheory.Subsemiring.Basic

/-!
# Subrings

Let `R` be a ring. This file defines the "bundled" subring type `subring R`, a type
whose terms correspond to subrings of `R`. This is the preferred way to talk
about subrings in mathlib. Unbundled subrings (`s : set R` and `is_subring s`)
are not in this file, and they will ultimately be deprecated.

We prove that subrings are a complete lattice, and that you can `map` (pushforward) and
`comap` (pull back) them along ring homomorphisms.

We define the `closure` construction from `set R` to `subring R`, sending a subset of `R`
to the subring it generates, and prove that it is a Galois insertion.

## Main definitions

Notation used here:

`(R : Type u) [ring R] (S : Type u) [ring S] (f g : R →+* S)`
`(A : subring R) (B : subring S) (s : set R)`

* `subring R` : the type of subrings of a ring `R`.

* `instance : complete_lattice (subring R)` : the complete lattice structure on the subrings.

* `subring.center` : the center of a ring `R`.

* `subring.closure` : subring closure of a set, i.e., the smallest subring that includes the set.

* `subring.gi` : `closure : set M → subring M` and coercion `coe : subring M → set M`
  form a `galois_insertion`.

* `comap f B : subring A` : the preimage of a subring `B` along the ring homomorphism `f`

* `map f A : subring B` : the image of a subring `A` along the ring homomorphism `f`.

* `prod A B : subring (R × S)` : the product of subrings

* `f.range : subring B` : the range of the ring homomorphism `f`.

* `eq_locus f g : subring R` : given ring homomorphisms `f g : R →+* S`,
     the subring of `R` where `f x = g x`

## Implementation notes

A subring is implemented as a subsemiring which is also an additive subgroup.
The initial PR was as a submonoid which is also an additive subgroup.

Lattice inclusion (e.g. `≤` and `⊓`) is used rather than set notation (`⊆` and `∩`), although
`∈` is defined as membership of a subring's underlying set.

## Tags
subring, subrings
-/


open BigOperators

universe u v w

variable {R : Type u} {S : Type v} {T : Type w} [Ring R]

section SubringClass

/-- `subring_class S R` states that `S` is a type of subsets `s ⊆ R` that
are both a multiplicative submonoid and an additive subgroup. -/
class SubringClass (S : Type _) (R : outParam <| Type u) [Ring R] [SetLike S R] extends
  SubsemiringClass S R, NegMemClass S R : Prop
#align subring_class SubringClass

-- See note [lower instance priority]
instance (priority := 100) SubringClass.add_subgroup_class (S : Type _) (R : outParam <| Type u)
    [SetLike S R] [Ring R] [h : SubringClass S R] : AddSubgroupClass S R :=
  { h with }
#align subring_class.add_subgroup_class SubringClass.add_subgroup_class

variable [SetLike S R] [hSR : SubringClass S R] (s : S)

include hSR

theorem coe_int_mem (n : ℤ) : (n : R) ∈ s := by simp only [← zsmul_one, zsmul_mem, one_mem]
#align coe_int_mem coe_int_mem

namespace SubringClass

instance (priority := 75) toHasIntCast : IntCast s :=
  ⟨fun n => ⟨n, coe_int_mem s n⟩⟩
#align subring_class.to_has_int_cast SubringClass.toHasIntCast

-- Prefer subclasses of `ring` over subclasses of `subring_class`.
/-- A subring of a ring inherits a ring structure -/
instance (priority := 75) toRing : Ring s :=
  Subtype.coe_injective.Ring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) fun _ => rfl
#align subring_class.to_ring SubringClass.toRing

omit hSR

-- Prefer subclasses of `ring` over subclasses of `subring_class`.
/-- A subring of a `comm_ring` is a `comm_ring`. -/
instance (priority := 75) toCommRing {R} [CommRing R] [SetLike S R] [SubringClass S R] :
    CommRing s :=
  Subtype.coe_injective.CommRing coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) fun _ => rfl
#align subring_class.to_comm_ring SubringClass.toCommRing

-- Prefer subclasses of `ring` over subclasses of `subring_class`.
/-- A subring of a domain is a domain. -/
instance (priority := 75) {R} [Ring R] [IsDomain R] [SetLike S R] [SubringClass S R] : IsDomain s :=
  NoZeroDivisors.to_isDomain _

-- Prefer subclasses of `ring` over subclasses of `subring_class`.
/-- A subring of an `ordered_ring` is an `ordered_ring`. -/
instance (priority := 75) toOrderedRing {R} [OrderedRing R] [SetLike S R] [SubringClass S R] :
    OrderedRing s :=
  Subtype.coe_injective.OrderedRing coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) fun _ => rfl
#align subring_class.to_ordered_ring SubringClass.toOrderedRing

-- Prefer subclasses of `ring` over subclasses of `subring_class`.
/-- A subring of an `ordered_comm_ring` is an `ordered_comm_ring`. -/
instance (priority := 75) toOrderedCommRing {R} [OrderedCommRing R] [SetLike S R]
    [SubringClass S R] : OrderedCommRing s :=
  Subtype.coe_injective.OrderedCommRing coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) fun _ => rfl
#align subring_class.to_ordered_comm_ring SubringClass.toOrderedCommRing

-- Prefer subclasses of `ring` over subclasses of `subring_class`.
/-- A subring of a `linear_ordered_ring` is a `linear_ordered_ring`. -/
instance (priority := 75) toLinearOrderedRing {R} [LinearOrderedRing R] [SetLike S R]
    [SubringClass S R] : LinearOrderedRing s :=
  Subtype.coe_injective.LinearOrderedRing coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ => rfl) (fun _ => rfl) (fun _ _ => rfl) fun _ _ => rfl
#align subring_class.to_linear_ordered_ring SubringClass.toLinearOrderedRing

-- Prefer subclasses of `ring` over subclasses of `subring_class`.
/-- A subring of a `linear_ordered_comm_ring` is a `linear_ordered_comm_ring`. -/
instance (priority := 75) toLinearOrderedCommRing {R} [LinearOrderedCommRing R] [SetLike S R]
    [SubringClass S R] : LinearOrderedCommRing s :=
  Subtype.coe_injective.LinearOrderedCommRing coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ => rfl) (fun _ => rfl) (fun _ _ => rfl) fun _ _ => rfl
#align subring_class.to_linear_ordered_comm_ring SubringClass.toLinearOrderedCommRing

include hSR

/-- The natural ring hom from a subring of ring `R` to `R`. -/
def subtype (s : S) : s →+* R :=
  { SubmonoidClass.Subtype s, AddSubgroupClass.subtype s with toFun := coe }
#align subring_class.subtype SubringClass.subtype

@[simp]
theorem coe_subtype : (subtype s : s → R) = coe :=
  rfl
#align subring_class.coe_subtype SubringClass.coe_subtype

@[simp, norm_cast]
theorem coe_nat_cast (n : ℕ) : ((n : s) : R) = n :=
  map_nat_cast (subtype s) n
#align subring_class.coe_nat_cast SubringClass.coe_nat_cast

@[simp, norm_cast]
theorem coe_int_cast (n : ℤ) : ((n : s) : R) = n :=
  map_int_cast (subtype s) n
#align subring_class.coe_int_cast SubringClass.coe_int_cast

end SubringClass

end SubringClass

variable [Ring S] [Ring T]

/-- `subring R` is the type of subrings of `R`. A subring of `R` is a subset `s` that is a
  multiplicative submonoid and an additive subgroup. Note in particular that it shares the
  same 0 and 1 as R. -/
structure Subring (R : Type u) [Ring R] extends Subsemiring R, AddSubgroup R
#align subring Subring

/-- Reinterpret a `subring` as a `subsemiring`. -/
add_decl_doc Subring.toSubsemiring

/-- Reinterpret a `subring` as an `add_subgroup`. -/
add_decl_doc Subring.toAddSubgroup

namespace Subring

/-- The underlying submonoid of a subring. -/
def toSubmonoid (s : Subring R) : Submonoid R :=
  { s.toSubsemiring.toSubmonoid with carrier := s.carrier }
#align subring.to_submonoid Subring.toSubmonoid

instance : SetLike (Subring R) R where
  coe := Subring.carrier
  coe_injective' p q h := by cases p <;> cases q <;> congr

instance : SubringClass (Subring R) R
    where
  zero_mem := zero_mem'
  add_mem := add_mem'
  one_mem := one_mem'
  mul_mem := mul_mem'
  neg_mem := neg_mem'

@[simp]
theorem mem_carrier {s : Subring R} {x : R} : x ∈ s.carrier ↔ x ∈ s :=
  Iff.rfl
#align subring.mem_carrier Subring.mem_carrier

@[simp]
theorem mem_mk {S : Set R} {x : R} (h₁ h₂ h₃ h₄ h₅) :
    x ∈ (⟨S, h₁, h₂, h₃, h₄, h₅⟩ : Subring R) ↔ x ∈ S :=
  Iff.rfl
#align subring.mem_mk Subring.mem_mk

@[simp]
theorem coe_set_mk (S : Set R) (h₁ h₂ h₃ h₄ h₅) :
    ((⟨S, h₁, h₂, h₃, h₄, h₅⟩ : Subring R) : Set R) = S :=
  rfl
#align subring.coe_set_mk Subring.coe_set_mk

@[simp]
theorem mk_le_mk {S S' : Set R} (h₁ h₂ h₃ h₄ h₅ h₁' h₂' h₃' h₄' h₅') :
    (⟨S, h₁, h₂, h₃, h₄, h₅⟩ : Subring R) ≤ (⟨S', h₁', h₂', h₃', h₄', h₅'⟩ : Subring R) ↔ S ⊆ S' :=
  Iff.rfl
#align subring.mk_le_mk Subring.mk_le_mk

/-- Two subrings are equal if they have the same elements. -/
@[ext]
theorem ext {S T : Subring R} (h : ∀ x, x ∈ S ↔ x ∈ T) : S = T :=
  SetLike.ext h
#align subring.ext Subring.ext

/-- Copy of a subring with a new `carrier` equal to the old one. Useful to fix definitional
equalities. -/
protected def copy (S : Subring R) (s : Set R) (hs : s = ↑S) : Subring R :=
  { S.toSubsemiring.copy s hs with
    carrier := s
    neg_mem' := fun _ => hs.symm ▸ S.neg_mem' }
#align subring.copy Subring.copy

@[simp]
theorem coe_copy (S : Subring R) (s : Set R) (hs : s = ↑S) : (S.copy s hs : Set R) = s :=
  rfl
#align subring.coe_copy Subring.coe_copy

theorem copy_eq (S : Subring R) (s : Set R) (hs : s = ↑S) : S.copy s hs = S :=
  SetLike.coe_injective hs
#align subring.copy_eq Subring.copy_eq

theorem to_subsemiring_injective : Function.Injective (toSubsemiring : Subring R → Subsemiring R)
  | r, s, h => ext (SetLike.ext_iff.mp h : _)
#align subring.to_subsemiring_injective Subring.to_subsemiring_injective

@[mono]
theorem to_subsemiring_strict_mono : StrictMono (toSubsemiring : Subring R → Subsemiring R) :=
  fun _ _ => id
#align subring.to_subsemiring_strict_mono Subring.to_subsemiring_strict_mono

@[mono]
theorem to_subsemiring_mono : Monotone (toSubsemiring : Subring R → Subsemiring R) :=
  to_subsemiring_strict_mono.Monotone
#align subring.to_subsemiring_mono Subring.to_subsemiring_mono

theorem to_add_subgroup_injective : Function.Injective (toAddSubgroup : Subring R → AddSubgroup R)
  | r, s, h => ext (SetLike.ext_iff.mp h : _)
#align subring.to_add_subgroup_injective Subring.to_add_subgroup_injective

@[mono]
theorem to_add_subgroup_strict_mono : StrictMono (toAddSubgroup : Subring R → AddSubgroup R) :=
  fun _ _ => id
#align subring.to_add_subgroup_strict_mono Subring.to_add_subgroup_strict_mono

@[mono]
theorem to_add_subgroup_mono : Monotone (toAddSubgroup : Subring R → AddSubgroup R) :=
  to_add_subgroup_strict_mono.Monotone
#align subring.to_add_subgroup_mono Subring.to_add_subgroup_mono

theorem to_submonoid_injective : Function.Injective (toSubmonoid : Subring R → Submonoid R)
  | r, s, h => ext (SetLike.ext_iff.mp h : _)
#align subring.to_submonoid_injective Subring.to_submonoid_injective

@[mono]
theorem to_submonoid_strict_mono : StrictMono (toSubmonoid : Subring R → Submonoid R) := fun _ _ =>
  id
#align subring.to_submonoid_strict_mono Subring.to_submonoid_strict_mono

@[mono]
theorem to_submonoid_mono : Monotone (toSubmonoid : Subring R → Submonoid R) :=
  to_submonoid_strict_mono.Monotone
#align subring.to_submonoid_mono Subring.to_submonoid_mono

/-- Construct a `subring R` from a set `s`, a submonoid `sm`, and an additive
subgroup `sa` such that `x ∈ s ↔ x ∈ sm ↔ x ∈ sa`. -/
protected def mk' (s : Set R) (sm : Submonoid R) (sa : AddSubgroup R) (hm : ↑sm = s)
    (ha : ↑sa = s) : Subring R where
  carrier := s
  zero_mem' := ha ▸ sa.zero_mem
  one_mem' := hm ▸ sm.one_mem
  add_mem' x y := by simpa only [← ha] using sa.add_mem
  mul_mem' x y := by simpa only [← hm] using sm.mul_mem
  neg_mem' x := by simpa only [← ha] using sa.neg_mem
#align subring.mk' Subring.mk'

@[simp]
theorem coe_mk' {s : Set R} {sm : Submonoid R} (hm : ↑sm = s) {sa : AddSubgroup R} (ha : ↑sa = s) :
    (Subring.mk' s sm sa hm ha : Set R) = s :=
  rfl
#align subring.coe_mk' Subring.coe_mk'

@[simp]
theorem mem_mk' {s : Set R} {sm : Submonoid R} (hm : ↑sm = s) {sa : AddSubgroup R} (ha : ↑sa = s)
    {x : R} : x ∈ Subring.mk' s sm sa hm ha ↔ x ∈ s :=
  Iff.rfl
#align subring.mem_mk' Subring.mem_mk'

@[simp]
theorem mk'_to_submonoid {s : Set R} {sm : Submonoid R} (hm : ↑sm = s) {sa : AddSubgroup R}
    (ha : ↑sa = s) : (Subring.mk' s sm sa hm ha).toSubmonoid = sm :=
  SetLike.coe_injective hm.symm
#align subring.mk'_to_submonoid Subring.mk'_to_submonoid

@[simp]
theorem mk'_to_add_subgroup {s : Set R} {sm : Submonoid R} (hm : ↑sm = s) {sa : AddSubgroup R}
    (ha : ↑sa = s) : (Subring.mk' s sm sa hm ha).toAddSubgroup = sa :=
  SetLike.coe_injective ha.symm
#align subring.mk'_to_add_subgroup Subring.mk'_to_add_subgroup

end Subring

/-- A `subsemiring` containing -1 is a `subring`. -/
def Subsemiring.toSubring (s : Subsemiring R) (hneg : (-1 : R) ∈ s) : Subring R :=
  { s.toSubmonoid, s.toAddSubmonoid with
    neg_mem' := by
      rintro x
      rw [← neg_one_mul]
      apply Subsemiring.mul_mem
      exact hneg }
#align subsemiring.to_subring Subsemiring.toSubring

namespace Subring

variable (s : Subring R)

/-- A subring contains the ring's 1. -/
protected theorem one_mem : (1 : R) ∈ s :=
  one_mem _
#align subring.one_mem Subring.one_mem

/-- A subring contains the ring's 0. -/
protected theorem zero_mem : (0 : R) ∈ s :=
  zero_mem _
#align subring.zero_mem Subring.zero_mem

/-- A subring is closed under multiplication. -/
protected theorem mul_mem {x y : R} : x ∈ s → y ∈ s → x * y ∈ s :=
  mul_mem
#align subring.mul_mem Subring.mul_mem

/-- A subring is closed under addition. -/
protected theorem add_mem {x y : R} : x ∈ s → y ∈ s → x + y ∈ s :=
  add_mem
#align subring.add_mem Subring.add_mem

/-- A subring is closed under negation. -/
protected theorem neg_mem {x : R} : x ∈ s → -x ∈ s :=
  neg_mem
#align subring.neg_mem Subring.neg_mem

/-- A subring is closed under subtraction -/
protected theorem sub_mem {x y : R} (hx : x ∈ s) (hy : y ∈ s) : x - y ∈ s :=
  sub_mem hx hy
#align subring.sub_mem Subring.sub_mem

/-- Product of a list of elements in a subring is in the subring. -/
protected theorem list_prod_mem {l : List R} : (∀ x ∈ l, x ∈ s) → l.Prod ∈ s :=
  list_prod_mem
#align subring.list_prod_mem Subring.list_prod_mem

/-- Sum of a list of elements in a subring is in the subring. -/
protected theorem list_sum_mem {l : List R} : (∀ x ∈ l, x ∈ s) → l.Sum ∈ s :=
  list_sum_mem
#align subring.list_sum_mem Subring.list_sum_mem

/-- Product of a multiset of elements in a subring of a `comm_ring` is in the subring. -/
protected theorem multiset_prod_mem {R} [CommRing R] (s : Subring R) (m : Multiset R) :
    (∀ a ∈ m, a ∈ s) → m.Prod ∈ s :=
  multiset_prod_mem _
#align subring.multiset_prod_mem Subring.multiset_prod_mem

/-- Sum of a multiset of elements in an `subring` of a `ring` is
in the `subring`. -/
protected theorem multiset_sum_mem {R} [Ring R] (s : Subring R) (m : Multiset R) :
    (∀ a ∈ m, a ∈ s) → m.Sum ∈ s :=
  multiset_sum_mem _
#align subring.multiset_sum_mem Subring.multiset_sum_mem

/-- Product of elements of a subring of a `comm_ring` indexed by a `finset` is in the
    subring. -/
protected theorem prod_mem {R : Type _} [CommRing R] (s : Subring R) {ι : Type _} {t : Finset ι}
    {f : ι → R} (h : ∀ c ∈ t, f c ∈ s) : (∏ i in t, f i) ∈ s :=
  prod_mem h
#align subring.prod_mem Subring.prod_mem

/-- Sum of elements in a `subring` of a `ring` indexed by a `finset`
is in the `subring`. -/
protected theorem sum_mem {R : Type _} [Ring R] (s : Subring R) {ι : Type _} {t : Finset ι}
    {f : ι → R} (h : ∀ c ∈ t, f c ∈ s) : (∑ i in t, f i) ∈ s :=
  sum_mem h
#align subring.sum_mem Subring.sum_mem

/-- A subring of a ring inherits a ring structure -/
instance toRing : Ring s :=
  Subtype.coe_injective.Ring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) fun _ => rfl
#align subring.to_ring Subring.toRing

protected theorem zsmul_mem {x : R} (hx : x ∈ s) (n : ℤ) : n • x ∈ s :=
  zsmul_mem hx n
#align subring.zsmul_mem Subring.zsmul_mem

protected theorem pow_mem {x : R} (hx : x ∈ s) (n : ℕ) : x ^ n ∈ s :=
  pow_mem hx n
#align subring.pow_mem Subring.pow_mem

@[simp, norm_cast]
theorem coe_add (x y : s) : (↑(x + y) : R) = ↑x + ↑y :=
  rfl
#align subring.coe_add Subring.coe_add

@[simp, norm_cast]
theorem coe_neg (x : s) : (↑(-x) : R) = -↑x :=
  rfl
#align subring.coe_neg Subring.coe_neg

@[simp, norm_cast]
theorem coe_mul (x y : s) : (↑(x * y) : R) = ↑x * ↑y :=
  rfl
#align subring.coe_mul Subring.coe_mul

@[simp, norm_cast]
theorem coe_zero : ((0 : s) : R) = 0 :=
  rfl
#align subring.coe_zero Subring.coe_zero

@[simp, norm_cast]
theorem coe_one : ((1 : s) : R) = 1 :=
  rfl
#align subring.coe_one Subring.coe_one

@[simp, norm_cast]
theorem coe_pow (x : s) (n : ℕ) : (↑(x ^ n) : R) = x ^ n :=
  SubmonoidClass.coe_pow x n
#align subring.coe_pow Subring.coe_pow

-- TODO: can be generalized to `add_submonoid_class`
@[simp]
theorem coe_eq_zero_iff {x : s} : (x : R) = 0 ↔ x = 0 :=
  ⟨fun h => Subtype.ext (trans h s.coe_zero.symm), fun h => h.symm ▸ s.coe_zero⟩
#align subring.coe_eq_zero_iff Subring.coe_eq_zero_iff

/-- A subring of a `comm_ring` is a `comm_ring`. -/
instance toCommRing {R} [CommRing R] (s : Subring R) : CommRing s :=
  Subtype.coe_injective.CommRing coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) fun _ => rfl
#align subring.to_comm_ring Subring.toCommRing

/-- A subring of a non-trivial ring is non-trivial. -/
instance {R} [Ring R] [Nontrivial R] (s : Subring R) : Nontrivial s :=
  s.toSubsemiring.Nontrivial

/-- A subring of a ring with no zero divisors has no zero divisors. -/
instance {R} [Ring R] [NoZeroDivisors R] (s : Subring R) : NoZeroDivisors s :=
  s.toSubsemiring.NoZeroDivisors

/-- A subring of a domain is a domain. -/
instance {R} [Ring R] [IsDomain R] (s : Subring R) : IsDomain s :=
  NoZeroDivisors.to_isDomain _

/-- A subring of an `ordered_ring` is an `ordered_ring`. -/
instance toOrderedRing {R} [OrderedRing R] (s : Subring R) : OrderedRing s :=
  Subtype.coe_injective.OrderedRing coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) fun _ => rfl
#align subring.to_ordered_ring Subring.toOrderedRing

/-- A subring of an `ordered_comm_ring` is an `ordered_comm_ring`. -/
instance toOrderedCommRing {R} [OrderedCommRing R] (s : Subring R) : OrderedCommRing s :=
  Subtype.coe_injective.OrderedCommRing coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) fun _ => rfl
#align subring.to_ordered_comm_ring Subring.toOrderedCommRing

/-- A subring of a `linear_ordered_ring` is a `linear_ordered_ring`. -/
instance toLinearOrderedRing {R} [LinearOrderedRing R] (s : Subring R) : LinearOrderedRing s :=
  Subtype.coe_injective.LinearOrderedRing coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ => rfl) (fun _ => rfl) (fun _ _ => rfl) fun _ _ => rfl
#align subring.to_linear_ordered_ring Subring.toLinearOrderedRing

/-- A subring of a `linear_ordered_comm_ring` is a `linear_ordered_comm_ring`. -/
instance toLinearOrderedCommRing {R} [LinearOrderedCommRing R] (s : Subring R) :
    LinearOrderedCommRing s :=
  Subtype.coe_injective.LinearOrderedCommRing coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ => rfl) (fun _ => rfl) (fun _ _ => rfl) fun _ _ => rfl
#align subring.to_linear_ordered_comm_ring Subring.toLinearOrderedCommRing

/-- The natural ring hom from a subring of ring `R` to `R`. -/
def subtype (s : Subring R) : s →+* R :=
  { s.toSubmonoid.Subtype, s.toAddSubgroup.Subtype with toFun := coe }
#align subring.subtype Subring.subtype

@[simp]
theorem coe_subtype : ⇑s.Subtype = coe :=
  rfl
#align subring.coe_subtype Subring.coe_subtype

@[simp, norm_cast]
theorem coe_nat_cast : ∀ n : ℕ, ((n : s) : R) = n :=
  map_nat_cast s.Subtype
#align subring.coe_nat_cast Subring.coe_nat_cast

@[simp, norm_cast]
theorem coe_int_cast : ∀ n : ℤ, ((n : s) : R) = n :=
  map_int_cast s.Subtype
#align subring.coe_int_cast Subring.coe_int_cast

/-! ## Partial order -/


@[simp]
theorem mem_to_submonoid {s : Subring R} {x : R} : x ∈ s.toSubmonoid ↔ x ∈ s :=
  Iff.rfl
#align subring.mem_to_submonoid Subring.mem_to_submonoid

@[simp]
theorem coe_to_submonoid (s : Subring R) : (s.toSubmonoid : Set R) = s :=
  rfl
#align subring.coe_to_submonoid Subring.coe_to_submonoid

@[simp]
theorem mem_to_add_subgroup {s : Subring R} {x : R} : x ∈ s.toAddSubgroup ↔ x ∈ s :=
  Iff.rfl
#align subring.mem_to_add_subgroup Subring.mem_to_add_subgroup

@[simp]
theorem coe_to_add_subgroup (s : Subring R) : (s.toAddSubgroup : Set R) = s :=
  rfl
#align subring.coe_to_add_subgroup Subring.coe_to_add_subgroup

/-! ## top -/


/-- The subring `R` of the ring `R`. -/
instance : Top (Subring R) :=
  ⟨{ (⊤ : Submonoid R), (⊤ : AddSubgroup R) with }⟩

@[simp]
theorem mem_top (x : R) : x ∈ (⊤ : Subring R) :=
  Set.mem_univ x
#align subring.mem_top Subring.mem_top

@[simp]
theorem coe_top : ((⊤ : Subring R) : Set R) = Set.univ :=
  rfl
#align subring.coe_top Subring.coe_top

/-- The ring equiv between the top element of `subring R` and `R`. -/
@[simps]
def topEquiv : (⊤ : Subring R) ≃+* R :=
  Subsemiring.topEquiv
#align subring.top_equiv Subring.topEquiv

/-! ## comap -/


/-- The preimage of a subring along a ring homomorphism is a subring. -/
def comap {R : Type u} {S : Type v} [Ring R] [Ring S] (f : R →+* S) (s : Subring S) : Subring R :=
  { s.toSubmonoid.comap (f : R →* S), s.toAddSubgroup.comap (f : R →+ S) with
    carrier := f ⁻¹' s.carrier }
#align subring.comap Subring.comap

@[simp]
theorem coe_comap (s : Subring S) (f : R →+* S) : (s.comap f : Set R) = f ⁻¹' s :=
  rfl
#align subring.coe_comap Subring.coe_comap

@[simp]
theorem mem_comap {s : Subring S} {f : R →+* S} {x : R} : x ∈ s.comap f ↔ f x ∈ s :=
  Iff.rfl
#align subring.mem_comap Subring.mem_comap

theorem comap_comap (s : Subring T) (g : S →+* T) (f : R →+* S) :
    (s.comap g).comap f = s.comap (g.comp f) :=
  rfl
#align subring.comap_comap Subring.comap_comap

/-! ## map -/


/-- The image of a subring along a ring homomorphism is a subring. -/
def map {R : Type u} {S : Type v} [Ring R] [Ring S] (f : R →+* S) (s : Subring R) : Subring S :=
  { s.toSubmonoid.map (f : R →* S), s.toAddSubgroup.map (f : R →+ S) with
    carrier := f '' s.carrier }
#align subring.map Subring.map

@[simp]
theorem coe_map (f : R →+* S) (s : Subring R) : (s.map f : Set S) = f '' s :=
  rfl
#align subring.coe_map Subring.coe_map

@[simp]
theorem mem_map {f : R →+* S} {s : Subring R} {y : S} : y ∈ s.map f ↔ ∃ x ∈ s, f x = y :=
  Set.mem_image_iff_bex
#align subring.mem_map Subring.mem_map

@[simp]
theorem map_id : s.map (RingHom.id R) = s :=
  SetLike.coe_injective <| Set.image_id _
#align subring.map_id Subring.map_id

theorem map_map (g : S →+* T) (f : R →+* S) : (s.map f).map g = s.map (g.comp f) :=
  SetLike.coe_injective <| Set.image_image _ _ _
#align subring.map_map Subring.map_map

theorem map_le_iff_le_comap {f : R →+* S} {s : Subring R} {t : Subring S} :
    s.map f ≤ t ↔ s ≤ t.comap f :=
  Set.image_subset_iff
#align subring.map_le_iff_le_comap Subring.map_le_iff_le_comap

theorem gc_map_comap (f : R →+* S) : GaloisConnection (map f) (comap f) := fun S T =>
  map_le_iff_le_comap
#align subring.gc_map_comap Subring.gc_map_comap

/-- A subring is isomorphic to its image under an injective function -/
noncomputable def equivMapOfInjective (f : R →+* S) (hf : Function.Injective f) : s ≃+* s.map f :=
  {
    Equiv.Set.image f s
      hf with
    map_mul' := fun _ _ => Subtype.ext (f.map_mul _ _)
    map_add' := fun _ _ => Subtype.ext (f.map_add _ _) }
#align subring.equiv_map_of_injective Subring.equivMapOfInjective

@[simp]
theorem coe_equiv_map_of_injective_apply (f : R →+* S) (hf : Function.Injective f) (x : s) :
    (equivMapOfInjective s f hf x : S) = f x :=
  rfl
#align subring.coe_equiv_map_of_injective_apply Subring.coe_equiv_map_of_injective_apply

end Subring

namespace RingHom

variable (g : S →+* T) (f : R →+* S)

/-! ## range -/


/-- The range of a ring homomorphism, as a subring of the target. See Note [range copy pattern]. -/
def range {R : Type u} {S : Type v} [Ring R] [Ring S] (f : R →+* S) : Subring S :=
  ((⊤ : Subring R).map f).copy (Set.range f) Set.image_univ.symm
#align ring_hom.range RingHom.range

@[simp]
theorem coe_range : (f.range : Set S) = Set.range f :=
  rfl
#align ring_hom.coe_range RingHom.coe_range

@[simp]
theorem mem_range {f : R →+* S} {y : S} : y ∈ f.range ↔ ∃ x, f x = y :=
  Iff.rfl
#align ring_hom.mem_range RingHom.mem_range

theorem range_eq_map (f : R →+* S) : f.range = Subring.map f ⊤ :=
  by
  ext
  simp
#align ring_hom.range_eq_map RingHom.range_eq_map

theorem mem_range_self (f : R →+* S) (x : R) : f x ∈ f.range :=
  mem_range.mpr ⟨x, rfl⟩
#align ring_hom.mem_range_self RingHom.mem_range_self

theorem map_range : f.range.map g = (g.comp f).range := by
  simpa only [range_eq_map] using (⊤ : Subring R).map_map g f
#align ring_hom.map_range RingHom.map_range

/-- The range of a ring homomorphism is a fintype, if the domain is a fintype.
Note: this instance can form a diamond with `subtype.fintype` in the
  presence of `fintype S`. -/
instance fintypeRange [Fintype R] [DecidableEq S] (f : R →+* S) : Fintype (range f) :=
  Set.fintypeRange f
#align ring_hom.fintype_range RingHom.fintypeRange

end RingHom

namespace Subring

/-! ## bot -/


instance : Bot (Subring R) :=
  ⟨(Int.castRingHom R).range⟩

instance : Inhabited (Subring R) :=
  ⟨⊥⟩

theorem coe_bot : ((⊥ : Subring R) : Set R) = Set.range (coe : ℤ → R) :=
  RingHom.coe_range (Int.castRingHom R)
#align subring.coe_bot Subring.coe_bot

theorem mem_bot {x : R} : x ∈ (⊥ : Subring R) ↔ ∃ n : ℤ, ↑n = x :=
  RingHom.mem_range
#align subring.mem_bot Subring.mem_bot

/-! ## inf -/


/-- The inf of two subrings is their intersection. -/
instance : HasInf (Subring R) :=
  ⟨fun s t =>
    { s.toSubmonoid ⊓ t.toSubmonoid, s.toAddSubgroup ⊓ t.toAddSubgroup with carrier := s ∩ t }⟩

@[simp]
theorem coe_inf (p p' : Subring R) : ((p ⊓ p' : Subring R) : Set R) = p ∩ p' :=
  rfl
#align subring.coe_inf Subring.coe_inf

@[simp]
theorem mem_inf {p p' : Subring R} {x : R} : x ∈ p ⊓ p' ↔ x ∈ p ∧ x ∈ p' :=
  Iff.rfl
#align subring.mem_inf Subring.mem_inf

instance : InfSet (Subring R) :=
  ⟨fun s =>
    Subring.mk' (⋂ t ∈ s, ↑t) (⨅ t ∈ s, Subring.toSubmonoid t) (⨅ t ∈ s, Subring.toAddSubgroup t)
      (by simp) (by simp)⟩

@[simp, norm_cast]
theorem coe_Inf (S : Set (Subring R)) : ((infₛ S : Subring R) : Set R) = ⋂ s ∈ S, ↑s :=
  rfl
#align subring.coe_Inf Subring.coe_Inf

theorem mem_Inf {S : Set (Subring R)} {x : R} : x ∈ infₛ S ↔ ∀ p ∈ S, x ∈ p :=
  Set.mem_interᵢ₂
#align subring.mem_Inf Subring.mem_Inf

@[simp, norm_cast]
theorem coe_infi {ι : Sort _} {S : ι → Subring R} : (↑(⨅ i, S i) : Set R) = ⋂ i, S i := by
  simp only [infᵢ, coe_Inf, Set.binterᵢ_range]
#align subring.coe_infi Subring.coe_infi

theorem mem_infi {ι : Sort _} {S : ι → Subring R} {x : R} : (x ∈ ⨅ i, S i) ↔ ∀ i, x ∈ S i := by
  simp only [infᵢ, mem_Inf, Set.forall_range_iff]
#align subring.mem_infi Subring.mem_infi

@[simp]
theorem Inf_to_submonoid (s : Set (Subring R)) :
    (infₛ s).toSubmonoid = ⨅ t ∈ s, Subring.toSubmonoid t :=
  mk'_to_submonoid _ _
#align subring.Inf_to_submonoid Subring.Inf_to_submonoid

@[simp]
theorem Inf_to_add_subgroup (s : Set (Subring R)) :
    (infₛ s).toAddSubgroup = ⨅ t ∈ s, Subring.toAddSubgroup t :=
  mk'_to_add_subgroup _ _
#align subring.Inf_to_add_subgroup Subring.Inf_to_add_subgroup

/-- Subrings of a ring form a complete lattice. -/
instance : CompleteLattice (Subring R) :=
  {
    completeLatticeOfInf (Subring R) fun s =>
      IsGLB.of_image (fun s t => show (s : Set R) ≤ t ↔ s ≤ t from SetLike.coe_subset_coe)
        isGLB_binfᵢ with
    bot := ⊥
    bot_le := fun s x hx =>
      let ⟨n, hn⟩ := mem_bot.1 hx
      hn ▸ coe_int_mem s n
    top := ⊤
    le_top := fun s x hx => trivial
    inf := (· ⊓ ·)
    inf_le_left := fun s t x => And.left
    inf_le_right := fun s t x => And.right
    le_inf := fun s t₁ t₂ h₁ h₂ x hx => ⟨h₁ hx, h₂ hx⟩ }

theorem eq_top_iff' (A : Subring R) : A = ⊤ ↔ ∀ x : R, x ∈ A :=
  eq_top_iff.trans ⟨fun h m => h <| mem_top m, fun h m _ => h m⟩
#align subring.eq_top_iff' Subring.eq_top_iff'

/-! ## Center of a ring -/


section

variable (R)

/-- The center of a ring `R` is the set of elements that commute with everything in `R` -/
def center : Subring R :=
  { Subsemiring.center R with
    carrier := Set.center R
    neg_mem' := fun a => Set.neg_mem_center }
#align subring.center Subring.center

theorem coe_center : ↑(center R) = Set.center R :=
  rfl
#align subring.coe_center Subring.coe_center

@[simp]
theorem center_to_subsemiring : (center R).toSubsemiring = Subsemiring.center R :=
  rfl
#align subring.center_to_subsemiring Subring.center_to_subsemiring

variable {R}

theorem mem_center_iff {z : R} : z ∈ center R ↔ ∀ g, g * z = z * g :=
  Iff.rfl
#align subring.mem_center_iff Subring.mem_center_iff

instance decidableMemCenter [DecidableEq R] [Fintype R] : DecidablePred (· ∈ center R) := fun _ =>
  decidable_of_iff' _ mem_center_iff
#align subring.decidable_mem_center Subring.decidableMemCenter

@[simp]
theorem center_eq_top (R) [CommRing R] : center R = ⊤ :=
  SetLike.coe_injective (Set.center_eq_univ R)
#align subring.center_eq_top Subring.center_eq_top

/-- The center is commutative. -/
instance : CommRing (center R) :=
  { Subsemiring.center.commSemiring, (center R).toRing with }

end

section DivisionRing

variable {K : Type u} [DivisionRing K]

instance : Field (center K) :=
  { (center K).Nontrivial,
    center.commRing with
    inv := fun a => ⟨a⁻¹, Set.inv_mem_center₀ a.Prop⟩
    mul_inv_cancel := fun ⟨a, ha⟩ h => Subtype.ext <| mul_inv_cancel <| Subtype.coe_injective.Ne h
    div := fun a b => ⟨a / b, Set.div_mem_center₀ a.Prop b.Prop⟩
    div_eq_mul_inv := fun a b => Subtype.ext <| div_eq_mul_inv _ _
    inv_zero := Subtype.ext inv_zero }

@[simp]
theorem center.coe_inv (a : center K) : ((a⁻¹ : center K) : K) = (a : K)⁻¹ :=
  rfl
#align subring.center.coe_inv Subring.center.coe_inv

@[simp]
theorem center.coe_div (a b : center K) : ((a / b : center K) : K) = (a : K) / (b : K) :=
  rfl
#align subring.center.coe_div Subring.center.coe_div

end DivisionRing

/-! ## subring closure of a subset -/


/-- The `subring` generated by a set. -/
def closure (s : Set R) : Subring R :=
  infₛ { S | s ⊆ S }
#align subring.closure Subring.closure

theorem mem_closure {x : R} {s : Set R} : x ∈ closure s ↔ ∀ S : Subring R, s ⊆ S → x ∈ S :=
  mem_Inf
#align subring.mem_closure Subring.mem_closure

/-- The subring generated by a set includes the set. -/
@[simp]
theorem subset_closure {s : Set R} : s ⊆ closure s := fun x hx => mem_closure.2 fun S hS => hS hx
#align subring.subset_closure Subring.subset_closure

theorem not_mem_of_not_mem_closure {s : Set R} {P : R} (hP : P ∉ closure s) : P ∉ s := fun h =>
  hP (subset_closure h)
#align subring.not_mem_of_not_mem_closure Subring.not_mem_of_not_mem_closure

/-- A subring `t` includes `closure s` if and only if it includes `s`. -/
@[simp]
theorem closure_le {s : Set R} {t : Subring R} : closure s ≤ t ↔ s ⊆ t :=
  ⟨Set.Subset.trans subset_closure, fun h => infₛ_le h⟩
#align subring.closure_le Subring.closure_le

/-- Subring closure of a set is monotone in its argument: if `s ⊆ t`,
then `closure s ≤ closure t`. -/
theorem closure_mono ⦃s t : Set R⦄ (h : s ⊆ t) : closure s ≤ closure t :=
  closure_le.2 <| Set.Subset.trans h subset_closure
#align subring.closure_mono Subring.closure_mono

theorem closure_eq_of_le {s : Set R} {t : Subring R} (h₁ : s ⊆ t) (h₂ : t ≤ closure s) :
    closure s = t :=
  le_antisymm (closure_le.2 h₁) h₂
#align subring.closure_eq_of_le Subring.closure_eq_of_le

/-- An induction principle for closure membership. If `p` holds for `0`, `1`, and all elements
of `s`, and is preserved under addition, negation, and multiplication, then `p` holds for all
elements of the closure of `s`. -/
@[elab_as_elim]
theorem closure_induction {s : Set R} {p : R → Prop} {x} (h : x ∈ closure s) (Hs : ∀ x ∈ s, p x)
    (H0 : p 0) (H1 : p 1) (Hadd : ∀ x y, p x → p y → p (x + y)) (Hneg : ∀ x : R, p x → p (-x))
    (Hmul : ∀ x y, p x → p y → p (x * y)) : p x :=
  (@closure_le _ _ _ ⟨p, Hmul, H1, Hadd, H0, Hneg⟩).2 Hs h
#align subring.closure_induction Subring.closure_induction

/-- An induction principle for closure membership, for predicates with two arguments. -/
@[elab_as_elim]
theorem closure_induction₂ {s : Set R} {p : R → R → Prop} {a b : R} (ha : a ∈ closure s)
    (hb : b ∈ closure s) (Hs : ∀ x ∈ s, ∀ y ∈ s, p x y) (H0_left : ∀ x, p 0 x)
    (H0_right : ∀ x, p x 0) (H1_left : ∀ x, p 1 x) (H1_right : ∀ x, p x 1)
    (Hneg_left : ∀ x y, p x y → p (-x) y) (Hneg_right : ∀ x y, p x y → p x (-y))
    (Hadd_left : ∀ x₁ x₂ y, p x₁ y → p x₂ y → p (x₁ + x₂) y)
    (Hadd_right : ∀ x y₁ y₂, p x y₁ → p x y₂ → p x (y₁ + y₂))
    (Hmul_left : ∀ x₁ x₂ y, p x₁ y → p x₂ y → p (x₁ * x₂) y)
    (Hmul_right : ∀ x y₁ y₂, p x y₁ → p x y₂ → p x (y₁ * y₂)) : p a b :=
  by
  refine'
    closure_induction hb _ (H0_right _) (H1_right _) (Hadd_right a) (Hneg_right a) (Hmul_right a)
  refine' closure_induction ha Hs (fun x _ => H0_left x) (fun x _ => H1_left x) _ _ _
  · exact fun x y H₁ H₂ z zs => Hadd_left x y z (H₁ z zs) (H₂ z zs)
  · exact fun x hx z zs => Hneg_left x z (hx z zs)
  · exact fun x y H₁ H₂ z zs => Hmul_left x y z (H₁ z zs) (H₂ z zs)
#align subring.closure_induction₂ Subring.closure_induction₂

theorem mem_closure_iff {s : Set R} {x} :
    x ∈ closure s ↔ x ∈ AddSubgroup.closure (Submonoid.closure s : Set R) :=
  ⟨fun h =>
    closure_induction h (fun x hx => AddSubgroup.subset_closure <| Submonoid.subset_closure hx)
      (AddSubgroup.zero_mem _)
      (AddSubgroup.subset_closure (Submonoid.one_mem (Submonoid.closure s)))
      (fun x y hx hy => AddSubgroup.add_mem _ hx hy) (fun x hx => AddSubgroup.neg_mem _ hx)
      fun x y hx hy =>
      AddSubgroup.closure_induction hy
        (fun q hq =>
          AddSubgroup.closure_induction hx
            (fun p hp => AddSubgroup.subset_closure ((Submonoid.closure s).mul_mem hp hq))
            (by rw [zero_mul q]; apply AddSubgroup.zero_mem _)
            (fun p₁ p₂ ihp₁ ihp₂ => by rw [add_mul p₁ p₂ q]; apply AddSubgroup.add_mem _ ihp₁ ihp₂)
            fun x hx => by
            have f : -x * q = -(x * q) := by simp
            rw [f]; apply AddSubgroup.neg_mem _ hx)
        (by rw [mul_zero x]; apply AddSubgroup.zero_mem _)
        (fun q₁ q₂ ihq₁ ihq₂ => by rw [mul_add x q₁ q₂]; apply AddSubgroup.add_mem _ ihq₁ ihq₂)
        fun z hz => by
        have f : x * -z = -(x * z) := by simp
        rw [f]; apply AddSubgroup.neg_mem _ hz,
    fun h =>
    AddSubgroup.closure_induction h
      (fun x hx =>
        Submonoid.closure_induction hx (fun x hx => subset_closure hx) (one_mem _) fun x y hx hy =>
          mul_mem hx hy)
      (zero_mem _) (fun x y hx hy => add_mem hx hy) fun x hx => neg_mem hx⟩
#align subring.mem_closure_iff Subring.mem_closure_iff

/-- If all elements of `s : set A` commute pairwise, then `closure s` is a commutative ring.  -/
def closureCommRingOfComm {s : Set R} (hcomm : ∀ a ∈ s, ∀ b ∈ s, a * b = b * a) :
    CommRing (closure s) :=
  { (closure s).toRing with
    mul_comm := fun x y => by
      ext
      simp only [Subring.coe_mul]
      refine'
        closure_induction₂ x.prop y.prop hcomm (fun x => by simp only [mul_zero, zero_mul])
          (fun x => by simp only [mul_zero, zero_mul]) (fun x => by simp only [mul_one, one_mul])
          (fun x => by simp only [mul_one, one_mul])
          (fun x y hxy => by simp only [mul_neg, neg_mul, hxy])
          (fun x y hxy => by simp only [mul_neg, neg_mul, hxy])
          (fun x₁ x₂ y h₁ h₂ => by simp only [add_mul, mul_add, h₁, h₂])
          (fun x₁ x₂ y h₁ h₂ => by simp only [add_mul, mul_add, h₁, h₂])
          (fun x₁ x₂ y h₁ h₂ => by rw [← mul_assoc, ← h₁, mul_assoc x₁ y x₂, ← h₂, mul_assoc])
          fun x₁ x₂ y h₁ h₂ => by rw [← mul_assoc, h₁, mul_assoc, h₂, ← mul_assoc] }
#align subring.closure_comm_ring_of_comm Subring.closureCommRingOfComm

theorem exists_list_of_mem_closure {s : Set R} {x : R} (h : x ∈ closure s) :
    ∃ L : List (List R), (∀ t ∈ L, ∀ y ∈ t, y ∈ s ∨ y = (-1 : R)) ∧ (L.map List.prod).Sum = x :=
  AddSubgroup.closure_induction (mem_closure_iff.1 h)
    (fun x hx =>
      let ⟨l, hl, h⟩ := Submonoid.exists_list_of_mem_closure hx
      ⟨[l], by simp [h] <;> clear_aux_decl <;> tauto⟩)
    ⟨[], by simp⟩
    (fun x y ⟨l, hl1, hl2⟩ ⟨m, hm1, hm2⟩ =>
      ⟨l ++ m, fun t ht => (List.mem_append.1 ht).elim (hl1 t) (hm1 t), by simp [hl2, hm2]⟩)
    fun x ⟨L, hL⟩ =>
    ⟨L.map (List.cons (-1)),
      List.forall_mem_map_iff.2 fun j hj => List.forall_mem_cons.2 ⟨Or.inr rfl, hL.1 j hj⟩,
      hL.2 ▸
        List.recOn L (by simp)
          (by simp (config := { contextual := true }) [List.map_cons, add_comm])⟩
#align subring.exists_list_of_mem_closure Subring.exists_list_of_mem_closure

variable (R)

/-- `closure` forms a Galois insertion with the coercion to set. -/
protected def gi : GaloisInsertion (@closure R _) coe
    where
  choice s _ := closure s
  gc s t := closure_le
  le_l_u s := subset_closure
  choice_eq s h := rfl
#align subring.gi Subring.gi

variable {R}

/-- Closure of a subring `S` equals `S`. -/
theorem closure_eq (s : Subring R) : closure (s : Set R) = s :=
  (Subring.gi R).l_u_eq s
#align subring.closure_eq Subring.closure_eq

@[simp]
theorem closure_empty : closure (∅ : Set R) = ⊥ :=
  (Subring.gi R).gc.l_bot
#align subring.closure_empty Subring.closure_empty

@[simp]
theorem closure_univ : closure (Set.univ : Set R) = ⊤ :=
  @coe_top R _ ▸ closure_eq ⊤
#align subring.closure_univ Subring.closure_univ

theorem closure_union (s t : Set R) : closure (s ∪ t) = closure s ⊔ closure t :=
  (Subring.gi R).gc.l_sup
#align subring.closure_union Subring.closure_union

theorem closure_Union {ι} (s : ι → Set R) : closure (⋃ i, s i) = ⨆ i, closure (s i) :=
  (Subring.gi R).gc.l_supr
#align subring.closure_Union Subring.closure_Union

theorem closure_sUnion (s : Set (Set R)) : closure (⋃₀ s) = ⨆ t ∈ s, closure t :=
  (Subring.gi R).gc.l_Sup
#align subring.closure_sUnion Subring.closure_sUnion

theorem map_sup (s t : Subring R) (f : R →+* S) : (s ⊔ t).map f = s.map f ⊔ t.map f :=
  (gc_map_comap f).l_sup
#align subring.map_sup Subring.map_sup

theorem map_supr {ι : Sort _} (f : R →+* S) (s : ι → Subring R) :
    (supᵢ s).map f = ⨆ i, (s i).map f :=
  (gc_map_comap f).l_supr
#align subring.map_supr Subring.map_supr

theorem comap_inf (s t : Subring S) (f : R →+* S) : (s ⊓ t).comap f = s.comap f ⊓ t.comap f :=
  (gc_map_comap f).u_inf
#align subring.comap_inf Subring.comap_inf

theorem comap_infi {ι : Sort _} (f : R →+* S) (s : ι → Subring S) :
    (infᵢ s).comap f = ⨅ i, (s i).comap f :=
  (gc_map_comap f).u_infi
#align subring.comap_infi Subring.comap_infi

@[simp]
theorem map_bot (f : R →+* S) : (⊥ : Subring R).map f = ⊥ :=
  (gc_map_comap f).l_bot
#align subring.map_bot Subring.map_bot

@[simp]
theorem comap_top (f : R →+* S) : (⊤ : Subring S).comap f = ⊤ :=
  (gc_map_comap f).u_top
#align subring.comap_top Subring.comap_top

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- Given `subring`s `s`, `t` of rings `R`, `S` respectively, `s.prod t` is `s ×̂ t`
as a subring of `R × S`. -/
def prod (s : Subring R) (t : Subring S) : Subring (R × S) :=
  { s.toSubmonoid.Prod t.toSubmonoid, s.toAddSubgroup.Prod t.toAddSubgroup with carrier := s ×ˢ t }
#align subring.prod Subring.prod

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[norm_cast]
theorem coe_prod (s : Subring R) (t : Subring S) : (s.Prod t : Set (R × S)) = s ×ˢ t :=
  rfl
#align subring.coe_prod Subring.coe_prod

theorem mem_prod {s : Subring R} {t : Subring S} {p : R × S} : p ∈ s.Prod t ↔ p.1 ∈ s ∧ p.2 ∈ t :=
  Iff.rfl
#align subring.mem_prod Subring.mem_prod

@[mono]
theorem prod_mono ⦃s₁ s₂ : Subring R⦄ (hs : s₁ ≤ s₂) ⦃t₁ t₂ : Subring S⦄ (ht : t₁ ≤ t₂) :
    s₁.Prod t₁ ≤ s₂.Prod t₂ :=
  Set.prod_mono hs ht
#align subring.prod_mono Subring.prod_mono

theorem prod_mono_right (s : Subring R) : Monotone fun t : Subring S => s.Prod t :=
  prod_mono (le_refl s)
#align subring.prod_mono_right Subring.prod_mono_right

theorem prod_mono_left (t : Subring S) : Monotone fun s : Subring R => s.Prod t := fun s₁ s₂ hs =>
  prod_mono hs (le_refl t)
#align subring.prod_mono_left Subring.prod_mono_left

theorem prod_top (s : Subring R) : s.Prod (⊤ : Subring S) = s.comap (RingHom.fst R S) :=
  ext fun x => by simp [mem_prod, MonoidHom.coe_fst]
#align subring.prod_top Subring.prod_top

theorem top_prod (s : Subring S) : (⊤ : Subring R).Prod s = s.comap (RingHom.snd R S) :=
  ext fun x => by simp [mem_prod, MonoidHom.coe_snd]
#align subring.top_prod Subring.top_prod

@[simp]
theorem top_prod_top : (⊤ : Subring R).Prod (⊤ : Subring S) = ⊤ :=
  (top_prod _).trans <| comap_top _
#align subring.top_prod_top Subring.top_prod_top

/-- Product of subrings is isomorphic to their product as rings. -/
def prodEquiv (s : Subring R) (t : Subring S) : s.Prod t ≃+* s × t :=
  { Equiv.Set.prod ↑s ↑t with
    map_mul' := fun x y => rfl
    map_add' := fun x y => rfl }
#align subring.prod_equiv Subring.prodEquiv

/-- The underlying set of a non-empty directed Sup of subrings is just a union of the subrings.
  Note that this fails without the directedness assumption (the union of two subrings is
  typically not a subring) -/
theorem mem_supr_of_directed {ι} [hι : Nonempty ι] {S : ι → Subring R} (hS : Directed (· ≤ ·) S)
    {x : R} : (x ∈ ⨆ i, S i) ↔ ∃ i, x ∈ S i :=
  by
  refine' ⟨_, fun ⟨i, hi⟩ => (SetLike.le_def.1 <| le_supᵢ S i) hi⟩
  let U : Subring R :=
    Subring.mk' (⋃ i, (S i : Set R)) (⨆ i, (S i).toSubmonoid) (⨆ i, (S i).toAddSubgroup)
      (Submonoid.coe_supr_of_directed <| hS.mono_comp _ fun _ _ => id)
      (AddSubgroup.coe_supr_of_directed <| hS.mono_comp _ fun _ _ => id)
  suffices (⨆ i, S i) ≤ U by simpa using @this x
  exact supᵢ_le fun i x hx => Set.mem_unionᵢ.2 ⟨i, hx⟩
#align subring.mem_supr_of_directed Subring.mem_supr_of_directed

theorem coe_supr_of_directed {ι} [hι : Nonempty ι] {S : ι → Subring R} (hS : Directed (· ≤ ·) S) :
    ((⨆ i, S i : Subring R) : Set R) = ⋃ i, ↑(S i) :=
  Set.ext fun x => by simp [mem_supr_of_directed hS]
#align subring.coe_supr_of_directed Subring.coe_supr_of_directed

theorem mem_Sup_of_directed_on {S : Set (Subring R)} (Sne : S.Nonempty) (hS : DirectedOn (· ≤ ·) S)
    {x : R} : x ∈ supₛ S ↔ ∃ s ∈ S, x ∈ s :=
  by
  haveI : Nonempty S := Sne.to_subtype
  simp only [supₛ_eq_supᵢ', mem_supr_of_directed hS.directed_coe, SetCoe.exists, Subtype.coe_mk]
#align subring.mem_Sup_of_directed_on Subring.mem_Sup_of_directed_on

theorem coe_Sup_of_directed_on {S : Set (Subring R)} (Sne : S.Nonempty)
    (hS : DirectedOn (· ≤ ·) S) : (↑(supₛ S) : Set R) = ⋃ s ∈ S, ↑s :=
  Set.ext fun x => by simp [mem_Sup_of_directed_on Sne hS]
#align subring.coe_Sup_of_directed_on Subring.coe_Sup_of_directed_on

theorem mem_map_equiv {f : R ≃+* S} {K : Subring R} {x : S} :
    x ∈ K.map (f : R →+* S) ↔ f.symm x ∈ K :=
  @Set.mem_image_equiv _ _ (↑K) f.toEquiv x
#align subring.mem_map_equiv Subring.mem_map_equiv

theorem map_equiv_eq_comap_symm (f : R ≃+* S) (K : Subring R) :
    K.map (f : R →+* S) = K.comap f.symm :=
  SetLike.coe_injective (f.toEquiv.image_eq_preimage K)
#align subring.map_equiv_eq_comap_symm Subring.map_equiv_eq_comap_symm

theorem comap_equiv_eq_map_symm (f : R ≃+* S) (K : Subring S) :
    K.comap (f : R →+* S) = K.map f.symm :=
  (map_equiv_eq_comap_symm f.symm K).symm
#align subring.comap_equiv_eq_map_symm Subring.comap_equiv_eq_map_symm

end Subring

namespace RingHom

variable {s : Subring R}

open Subring

/-- Restriction of a ring homomorphism to its range interpreted as a subsemiring.

This is the bundled version of `set.range_factorization`. -/
def rangeRestrict (f : R →+* S) : R →+* f.range :=
  (f.codRestrict f.range) fun x => ⟨x, rfl⟩
#align ring_hom.range_restrict RingHom.rangeRestrict

@[simp]
theorem coe_range_restrict (f : R →+* S) (x : R) : (f.range_restrict x : S) = f x :=
  rfl
#align ring_hom.coe_range_restrict RingHom.coe_range_restrict

theorem range_restrict_surjective (f : R →+* S) : Function.Surjective f.range_restrict :=
  fun ⟨y, hy⟩ =>
  let ⟨x, hx⟩ := mem_range.mp hy
  ⟨x, Subtype.ext hx⟩
#align ring_hom.range_restrict_surjective RingHom.range_restrict_surjective

theorem range_top_iff_surjective {f : R →+* S} :
    f.range = (⊤ : Subring S) ↔ Function.Surjective f :=
  SetLike.ext'_iff.trans <| Iff.trans (by rw [coe_range, coe_top]) Set.range_iff_surjective
#align ring_hom.range_top_iff_surjective RingHom.range_top_iff_surjective

/-- The range of a surjective ring homomorphism is the whole of the codomain. -/
theorem range_top_of_surjective (f : R →+* S) (hf : Function.Surjective f) :
    f.range = (⊤ : Subring S) :=
  range_top_iff_surjective.2 hf
#align ring_hom.range_top_of_surjective RingHom.range_top_of_surjective

/-- The subring of elements `x : R` such that `f x = g x`, i.e.,
  the equalizer of f and g as a subring of R -/
def eqLocus (f g : R →+* S) : Subring R :=
  { (f : R →* S).eqMlocus g, (f : R →+ S).eqLocus g with carrier := { x | f x = g x } }
#align ring_hom.eq_locus RingHom.eqLocus

@[simp]
theorem eq_locus_same (f : R →+* S) : f.eqLocus f = ⊤ :=
  SetLike.ext fun _ => eq_self_iff_true _
#align ring_hom.eq_locus_same RingHom.eq_locus_same

/-- If two ring homomorphisms are equal on a set, then they are equal on its subring closure. -/
theorem eq_on_set_closure {f g : R →+* S} {s : Set R} (h : Set.EqOn f g s) :
    Set.EqOn f g (closure s) :=
  show closure s ≤ f.eqLocus g from closure_le.2 h
#align ring_hom.eq_on_set_closure RingHom.eq_on_set_closure

theorem eq_of_eq_on_set_top {f g : R →+* S} (h : Set.EqOn f g (⊤ : Subring R)) : f = g :=
  ext fun x => h trivial
#align ring_hom.eq_of_eq_on_set_top RingHom.eq_of_eq_on_set_top

theorem eq_of_eq_on_set_dense {s : Set R} (hs : closure s = ⊤) {f g : R →+* S} (h : s.EqOn f g) :
    f = g :=
  eq_of_eq_on_set_top <| hs ▸ eq_on_set_closure h
#align ring_hom.eq_of_eq_on_set_dense RingHom.eq_of_eq_on_set_dense

theorem closure_preimage_le (f : R →+* S) (s : Set S) : closure (f ⁻¹' s) ≤ (closure s).comap f :=
  closure_le.2 fun x hx => SetLike.mem_coe.2 <| mem_comap.2 <| subset_closure hx
#align ring_hom.closure_preimage_le RingHom.closure_preimage_le

/-- The image under a ring homomorphism of the subring generated by a set equals
the subring generated by the image of the set. -/
theorem map_closure (f : R →+* S) (s : Set R) : (closure s).map f = closure (f '' s) :=
  le_antisymm
    (map_le_iff_le_comap.2 <|
      le_trans (closure_mono <| Set.subset_preimage_image _ _) (closure_preimage_le _ _))
    (closure_le.2 <| Set.image_subset _ subset_closure)
#align ring_hom.map_closure RingHom.map_closure

end RingHom

namespace Subring

open RingHom

/-- The ring homomorphism associated to an inclusion of subrings. -/
def inclusion {S T : Subring R} (h : S ≤ T) : S →+* T :=
  S.Subtype.codRestrict _ fun x => h x.2
#align subring.inclusion Subring.inclusion

@[simp]
theorem range_subtype (s : Subring R) : s.Subtype.range = s :=
  SetLike.coe_injective <| (coe_srange _).trans Subtype.range_coe
#align subring.range_subtype Subring.range_subtype

@[simp]
theorem range_fst : (fst R S).srange = ⊤ :=
  (fst R S).srange_top_of_surjective <| Prod.fst_surjective
#align subring.range_fst Subring.range_fst

@[simp]
theorem range_snd : (snd R S).srange = ⊤ :=
  (snd R S).srange_top_of_surjective <| Prod.snd_surjective
#align subring.range_snd Subring.range_snd

@[simp]
theorem prod_bot_sup_bot_prod (s : Subring R) (t : Subring S) : s.Prod ⊥ ⊔ prod ⊥ t = s.Prod t :=
  (le_antisymm (sup_le (prod_mono_right s bot_le) (prod_mono_left t bot_le))) fun p hp =>
    Prod.fst_mul_snd p ▸
      mul_mem
        ((le_sup_left : s.Prod ⊥ ≤ s.Prod ⊥ ⊔ prod ⊥ t) ⟨hp.1, SetLike.mem_coe.2 <| one_mem ⊥⟩)
        ((le_sup_right : prod ⊥ t ≤ s.Prod ⊥ ⊔ prod ⊥ t) ⟨SetLike.mem_coe.2 <| one_mem ⊥, hp.2⟩)
#align subring.prod_bot_sup_bot_prod Subring.prod_bot_sup_bot_prod

end Subring

namespace RingEquiv

variable {s t : Subring R}

/-- Makes the identity isomorphism from a proof two subrings of a multiplicative
    monoid are equal. -/
def subringCongr (h : s = t) : s ≃+* t :=
  {
    Equiv.setCongr <| congr_arg _ h with
    map_mul' := fun _ _ => rfl
    map_add' := fun _ _ => rfl }
#align ring_equiv.subring_congr RingEquiv.subringCongr

/-- Restrict a ring homomorphism with a left inverse to a ring isomorphism to its
`ring_hom.range`. -/
def ofLeftInverse {g : S → R} {f : R →+* S} (h : Function.LeftInverse g f) : R ≃+* f.range :=
  { f.range_restrict with
    toFun := fun x => f.range_restrict x
    invFun := fun x => (g ∘ f.range.Subtype) x
    left_inv := h
    right_inv := fun x =>
      Subtype.ext <|
        let ⟨x', hx'⟩ := RingHom.mem_range.mp x.Prop
        show f (g x) = x by rw [← hx', h x'] }
#align ring_equiv.of_left_inverse RingEquiv.ofLeftInverse

@[simp]
theorem of_left_inverse_apply {g : S → R} {f : R →+* S} (h : Function.LeftInverse g f) (x : R) :
    ↑(ofLeftInverse h x) = f x :=
  rfl
#align ring_equiv.of_left_inverse_apply RingEquiv.of_left_inverse_apply

@[simp]
theorem of_left_inverse_symm_apply {g : S → R} {f : R →+* S} (h : Function.LeftInverse g f)
    (x : f.range) : (ofLeftInverse h).symm x = g x :=
  rfl
#align ring_equiv.of_left_inverse_symm_apply RingEquiv.of_left_inverse_symm_apply

/-- Given an equivalence `e : R ≃+* S` of rings and a subring `s` of `R`,
`subring_equiv_map e s` is the induced equivalence between `s` and `s.map e` -/
@[simps]
def subringMap (e : R ≃+* S) : s ≃+* s.map e.toRingHom :=
  e.subsemiringMap s.toSubsemiring
#align ring_equiv.subring_map RingEquiv.subringMap

end RingEquiv

namespace Subring

variable {s : Set R}

attribute [local reducible] closure

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[elab_as_elim]
protected theorem InClosure.rec_on {C : R → Prop} {x : R} (hx : x ∈ closure s) (h1 : C 1)
    (hneg1 : C (-1)) (hs : ∀ z ∈ s, ∀ n, C n → C (z * n)) (ha : ∀ {x y}, C x → C y → C (x + y)) :
    C x := by
  have h0 : C 0 := add_neg_self (1 : R) ▸ ha h1 hneg1
  rcases exists_list_of_mem_closure hx with ⟨L, HL, rfl⟩
  clear hx
  induction' L with hd tl ih
  · exact h0
  rw [List.forall_mem_cons] at HL
  suffices C (List.prod hd) by
    rw [List.map_cons, List.sum_cons]
    exact ha this (ih HL.2)
  replace HL := HL.1
  clear ih tl
  rsuffices ⟨L, HL', HP | HP⟩ :
    ∃ L : List R, (∀ x ∈ L, x ∈ s) ∧ (List.prod hd = List.prod L ∨ List.prod hd = -List.prod L)
  · rw [HP]
    clear HP HL hd
    induction' L with hd tl ih
    · exact h1
    rw [List.forall_mem_cons] at HL'
    rw [List.prod_cons]
    exact hs _ HL'.1 _ (ih HL'.2)
  · rw [HP]
    clear HP HL hd
    induction' L with hd tl ih
    · exact hneg1
    rw [List.prod_cons, neg_mul_eq_mul_neg]
    rw [List.forall_mem_cons] at HL'
    exact hs _ HL'.1 _ (ih HL'.2)
  induction' hd with hd tl ih
  · exact ⟨[], List.forall_mem_nil _, Or.inl rfl⟩
  rw [List.forall_mem_cons] at HL
  rcases ih HL.2 with ⟨L, HL', HP | HP⟩ <;> cases' HL.1 with hhd hhd
  ·
    exact
      ⟨hd::L, List.forall_mem_cons.2 ⟨hhd, HL'⟩,
        Or.inl <| by rw [List.prod_cons, List.prod_cons, HP]⟩
  · exact ⟨L, HL', Or.inr <| by rw [List.prod_cons, hhd, neg_one_mul, HP]⟩
  ·
    exact
      ⟨hd::L, List.forall_mem_cons.2 ⟨hhd, HL'⟩,
        Or.inr <| by rw [List.prod_cons, List.prod_cons, HP, neg_mul_eq_mul_neg]⟩
  · exact ⟨L, HL', Or.inl <| by rw [List.prod_cons, hhd, HP, neg_one_mul, neg_neg]⟩
#align subring.in_closure.rec_on Subring.InClosure.rec_on

theorem closure_preimage_le (f : R →+* S) (s : Set S) : closure (f ⁻¹' s) ≤ (closure s).comap f :=
  closure_le.2 fun x hx => SetLike.mem_coe.2 <| mem_comap.2 <| subset_closure hx
#align subring.closure_preimage_le Subring.closure_preimage_le

end Subring

theorem AddSubgroup.int_mul_mem {G : AddSubgroup R} (k : ℤ) {g : R} (h : g ∈ G) : (k : R) * g ∈ G :=
  by
  convert AddSubgroup.zsmul_mem G h k
  simp
#align add_subgroup.int_mul_mem AddSubgroup.int_mul_mem

/-! ## Actions by `subring`s

These are just copies of the definitions about `subsemiring` starting from
`subsemiring.mul_action`.

When `R` is commutative, `algebra.of_subring` provides a stronger result than those found in
this file, which uses the same scalar action.
-/


section Actions

namespace Subring

variable {α β : Type _}

/-- The action by a subring is the action by the underlying ring. -/
instance [HasSmul R α] (S : Subring R) : HasSmul S α :=
  S.toSubsemiring.HasSmul

theorem smul_def [HasSmul R α] {S : Subring R} (g : S) (m : α) : g • m = (g : R) • m :=
  rfl
#align subring.smul_def Subring.smul_def

instance smul_comm_class_left [HasSmul R β] [HasSmul α β] [SMulCommClass R α β] (S : Subring R) :
    SMulCommClass S α β :=
  S.toSubsemiring.smul_comm_class_left
#align subring.smul_comm_class_left Subring.smul_comm_class_left

instance smul_comm_class_right [HasSmul α β] [HasSmul R β] [SMulCommClass α R β] (S : Subring R) :
    SMulCommClass α S β :=
  S.toSubsemiring.smul_comm_class_right
#align subring.smul_comm_class_right Subring.smul_comm_class_right

/-- Note that this provides `is_scalar_tower S R R` which is needed by `smul_mul_assoc`. -/
instance [HasSmul α β] [HasSmul R α] [HasSmul R β] [IsScalarTower R α β] (S : Subring R) :
    IsScalarTower S α β :=
  S.toSubsemiring.IsScalarTower

instance [HasSmul R α] [FaithfulSMul R α] (S : Subring R) : FaithfulSMul S α :=
  S.toSubsemiring.HasFaithfulSmul

/-- The action by a subring is the action by the underlying ring. -/
instance [MulAction R α] (S : Subring R) : MulAction S α :=
  S.toSubsemiring.MulAction

/-- The action by a subring is the action by the underlying ring. -/
instance [AddMonoid α] [DistribMulAction R α] (S : Subring R) : DistribMulAction S α :=
  S.toSubsemiring.DistribMulAction

/-- The action by a subring is the action by the underlying ring. -/
instance [Monoid α] [MulDistribMulAction R α] (S : Subring R) : MulDistribMulAction S α :=
  S.toSubsemiring.MulDistribMulAction

/-- The action by a subring is the action by the underlying ring. -/
instance [Zero α] [SMulWithZero R α] (S : Subring R) : SMulWithZero S α :=
  S.toSubsemiring.SmulWithZero

/-- The action by a subring is the action by the underlying ring. -/
instance [Zero α] [MulActionWithZero R α] (S : Subring R) : MulActionWithZero S α :=
  S.toSubsemiring.MulActionWithZero

/-- The action by a subring is the action by the underlying ring. -/
instance [AddCommMonoid α] [Module R α] (S : Subring R) : Module S α :=
  S.toSubsemiring.Module

/-- The action by a subsemiring is the action by the underlying ring. -/
instance [Semiring α] [MulSemiringAction R α] (S : Subring R) : MulSemiringAction S α :=
  S.toSubmonoid.MulSemiringAction

/-- The center of a semiring acts commutatively on that semiring. -/
instance center.smul_comm_class_left : SMulCommClass (center R) R R :=
  Subsemiring.center.smul_comm_class_left
#align subring.center.smul_comm_class_left Subring.center.smul_comm_class_left

/-- The center of a semiring acts commutatively on that semiring. -/
instance center.smul_comm_class_right : SMulCommClass R (center R) R :=
  Subsemiring.center.smul_comm_class_right
#align subring.center.smul_comm_class_right Subring.center.smul_comm_class_right

end Subring

end Actions

-- while this definition is not about subrings, this is the earliest we have
-- both ordered ring structures and submonoids available
/-- The subgroup of positive units of a linear ordered semiring. -/
def Units.posSubgroup (R : Type _) [LinearOrderedSemiring R] : Subgroup Rˣ :=
  {
    (posSubmonoid R).comap
      (Units.coeHom R) with
    carrier := { x | (0 : R) < x }
    inv_mem' := fun x => Units.inv_pos.mpr }
#align units.pos_subgroup Units.posSubgroup

@[simp]
theorem Units.mem_pos_subgroup {R : Type _} [LinearOrderedSemiring R] (u : Rˣ) :
    u ∈ Units.posSubgroup R ↔ (0 : R) < u :=
  Iff.rfl
#align units.mem_pos_subgroup Units.mem_pos_subgroup

