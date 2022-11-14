/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Yury Kudryashov
-/
import Mathbin.Algebra.Algebra.Basic
import Mathbin.Data.Set.UnionLift
import Mathbin.LinearAlgebra.Finsupp
import Mathbin.RingTheory.Ideal.Operations

/-!
# Subalgebras over Commutative Semiring

In this file we define `subalgebra`s and the usual operations on them (`map`, `comap`).

More lemmas about `adjoin` can be found in `ring_theory.adjoin`.
-/


universe u u' v w w'

open BigOperators

/-- A subalgebra is a sub(semi)ring that includes the range of `algebra_map`. -/
structure Subalgebra (R : Type u) (A : Type v) [CommSemiring R] [Semiring A] [Algebra R A] extends Subsemiring A :
  Type v where
  algebra_map_mem' : ∀ r, algebraMap R A r ∈ carrier
  zero_mem' := (algebraMap R A).map_zero ▸ algebra_map_mem' 0
  one_mem' := (algebraMap R A).map_one ▸ algebra_map_mem' 1
#align subalgebra Subalgebra

/-- Reinterpret a `subalgebra` as a `subsemiring`. -/
add_decl_doc Subalgebra.toSubsemiring

namespace Subalgebra

variable {R' : Type u'} {R : Type u} {A : Type v} {B : Type w} {C : Type w'}

variable [CommSemiring R]

variable [Semiring A] [Algebra R A] [Semiring B] [Algebra R B] [Semiring C] [Algebra R C]

include R

instance : SetLike (Subalgebra R A) A where
  coe := Subalgebra.carrier
  coe_injective' p q h := by cases p <;> cases q <;> congr

instance : SubsemiringClass (Subalgebra R A) A where
  add_mem := add_mem'
  mul_mem := mul_mem'
  one_mem := one_mem'
  zero_mem := zero_mem'

@[simp]
theorem mem_carrier {s : Subalgebra R A} {x : A} : x ∈ s.carrier ↔ x ∈ s :=
  Iff.rfl
#align subalgebra.mem_carrier Subalgebra.mem_carrier

@[ext.1]
theorem ext {S T : Subalgebra R A} (h : ∀ x : A, x ∈ S ↔ x ∈ T) : S = T :=
  SetLike.ext h
#align subalgebra.ext Subalgebra.ext

@[simp]
theorem mem_to_subsemiring {S : Subalgebra R A} {x} : x ∈ S.toSubsemiring ↔ x ∈ S :=
  Iff.rfl
#align subalgebra.mem_to_subsemiring Subalgebra.mem_to_subsemiring

@[simp]
theorem coe_to_subsemiring (S : Subalgebra R A) : (↑S.toSubsemiring : Set A) = S :=
  rfl
#align subalgebra.coe_to_subsemiring Subalgebra.coe_to_subsemiring

theorem to_subsemiring_injective : Function.Injective (toSubsemiring : Subalgebra R A → Subsemiring A) := fun S T h =>
  ext fun x => by rw [← mem_to_subsemiring, ← mem_to_subsemiring, h]
#align subalgebra.to_subsemiring_injective Subalgebra.to_subsemiring_injective

theorem to_subsemiring_inj {S U : Subalgebra R A} : S.toSubsemiring = U.toSubsemiring ↔ S = U :=
  to_subsemiring_injective.eq_iff
#align subalgebra.to_subsemiring_inj Subalgebra.to_subsemiring_inj

/-- Copy of a subalgebra with a new `carrier` equal to the old one. Useful to fix definitional
equalities. -/
protected def copy (S : Subalgebra R A) (s : Set A) (hs : s = ↑S) : Subalgebra R A where
  carrier := s
  add_mem' _ _ := hs.symm ▸ S.add_mem'
  mul_mem' _ _ := hs.symm ▸ S.mul_mem'
  algebra_map_mem' := hs.symm ▸ S.algebra_map_mem'
#align subalgebra.copy Subalgebra.copy

@[simp]
theorem coe_copy (S : Subalgebra R A) (s : Set A) (hs : s = ↑S) : (S.copy s hs : Set A) = s :=
  rfl
#align subalgebra.coe_copy Subalgebra.coe_copy

theorem copy_eq (S : Subalgebra R A) (s : Set A) (hs : s = ↑S) : S.copy s hs = S :=
  SetLike.coe_injective hs
#align subalgebra.copy_eq Subalgebra.copy_eq

variable (S : Subalgebra R A)

theorem algebra_map_mem (r : R) : algebraMap R A r ∈ S :=
  S.algebra_map_mem' r
#align subalgebra.algebra_map_mem Subalgebra.algebra_map_mem

theorem srange_le : (algebraMap R A).srange ≤ S.toSubsemiring := fun x ⟨r, hr⟩ => hr ▸ S.algebra_map_mem r
#align subalgebra.srange_le Subalgebra.srange_le

theorem range_subset : Set.range (algebraMap R A) ⊆ S := fun x ⟨r, hr⟩ => hr ▸ S.algebra_map_mem r
#align subalgebra.range_subset Subalgebra.range_subset

theorem range_le : Set.range (algebraMap R A) ≤ S :=
  S.range_subset
#align subalgebra.range_le Subalgebra.range_le

theorem smul_mem {x : A} (hx : x ∈ S) (r : R) : r • x ∈ S :=
  (Algebra.smul_def r x).symm ▸ mul_mem (S.algebra_map_mem r) hx
#align subalgebra.smul_mem Subalgebra.smul_mem

protected theorem one_mem : (1 : A) ∈ S :=
  one_mem S
#align subalgebra.one_mem Subalgebra.one_mem

protected theorem mul_mem {x y : A} (hx : x ∈ S) (hy : y ∈ S) : x * y ∈ S :=
  mul_mem hx hy
#align subalgebra.mul_mem Subalgebra.mul_mem

protected theorem pow_mem {x : A} (hx : x ∈ S) (n : ℕ) : x ^ n ∈ S :=
  pow_mem hx n
#align subalgebra.pow_mem Subalgebra.pow_mem

protected theorem zero_mem : (0 : A) ∈ S :=
  zero_mem S
#align subalgebra.zero_mem Subalgebra.zero_mem

protected theorem add_mem {x y : A} (hx : x ∈ S) (hy : y ∈ S) : x + y ∈ S :=
  add_mem hx hy
#align subalgebra.add_mem Subalgebra.add_mem

protected theorem nsmul_mem {x : A} (hx : x ∈ S) (n : ℕ) : n • x ∈ S :=
  nsmul_mem hx n
#align subalgebra.nsmul_mem Subalgebra.nsmul_mem

protected theorem coe_nat_mem (n : ℕ) : (n : A) ∈ S :=
  coe_nat_mem S n
#align subalgebra.coe_nat_mem Subalgebra.coe_nat_mem

protected theorem list_prod_mem {L : List A} (h : ∀ x ∈ L, x ∈ S) : L.Prod ∈ S :=
  list_prod_mem h
#align subalgebra.list_prod_mem Subalgebra.list_prod_mem

protected theorem list_sum_mem {L : List A} (h : ∀ x ∈ L, x ∈ S) : L.Sum ∈ S :=
  list_sum_mem h
#align subalgebra.list_sum_mem Subalgebra.list_sum_mem

protected theorem multiset_sum_mem {m : Multiset A} (h : ∀ x ∈ m, x ∈ S) : m.Sum ∈ S :=
  multiset_sum_mem m h
#align subalgebra.multiset_sum_mem Subalgebra.multiset_sum_mem

protected theorem sum_mem {ι : Type w} {t : Finset ι} {f : ι → A} (h : ∀ x ∈ t, f x ∈ S) : (∑ x in t, f x) ∈ S :=
  sum_mem h
#align subalgebra.sum_mem Subalgebra.sum_mem

protected theorem multiset_prod_mem {R : Type u} {A : Type v} [CommSemiring R] [CommSemiring A] [Algebra R A]
    (S : Subalgebra R A) {m : Multiset A} (h : ∀ x ∈ m, x ∈ S) : m.Prod ∈ S :=
  multiset_prod_mem m h
#align subalgebra.multiset_prod_mem Subalgebra.multiset_prod_mem

protected theorem prod_mem {R : Type u} {A : Type v} [CommSemiring R] [CommSemiring A] [Algebra R A]
    (S : Subalgebra R A) {ι : Type w} {t : Finset ι} {f : ι → A} (h : ∀ x ∈ t, f x ∈ S) : (∏ x in t, f x) ∈ S :=
  prod_mem h
#align subalgebra.prod_mem Subalgebra.prod_mem

instance {R A : Type _} [CommRing R] [Ring A] [Algebra R A] : SubringClass (Subalgebra R A) A :=
  { Subalgebra.subsemiringClass with neg_mem := fun S x hx => neg_one_smul R x ▸ S.smul_mem hx _ }

protected theorem neg_mem {R : Type u} {A : Type v} [CommRing R] [Ring A] [Algebra R A] (S : Subalgebra R A) {x : A}
    (hx : x ∈ S) : -x ∈ S :=
  neg_mem hx
#align subalgebra.neg_mem Subalgebra.neg_mem

protected theorem sub_mem {R : Type u} {A : Type v} [CommRing R] [Ring A] [Algebra R A] (S : Subalgebra R A) {x y : A}
    (hx : x ∈ S) (hy : y ∈ S) : x - y ∈ S :=
  sub_mem hx hy
#align subalgebra.sub_mem Subalgebra.sub_mem

protected theorem zsmul_mem {R : Type u} {A : Type v} [CommRing R] [Ring A] [Algebra R A] (S : Subalgebra R A) {x : A}
    (hx : x ∈ S) (n : ℤ) : n • x ∈ S :=
  zsmul_mem hx n
#align subalgebra.zsmul_mem Subalgebra.zsmul_mem

protected theorem coe_int_mem {R : Type u} {A : Type v} [CommRing R] [Ring A] [Algebra R A] (S : Subalgebra R A)
    (n : ℤ) : (n : A) ∈ S :=
  coe_int_mem S n
#align subalgebra.coe_int_mem Subalgebra.coe_int_mem

/-- The projection from a subalgebra of `A` to an additive submonoid of `A`. -/
def toAddSubmonoid {R : Type u} {A : Type v} [CommSemiring R] [Semiring A] [Algebra R A] (S : Subalgebra R A) :
    AddSubmonoid A :=
  S.toSubsemiring.toAddSubmonoid
#align subalgebra.to_add_submonoid Subalgebra.toAddSubmonoid

/-- The projection from a subalgebra of `A` to a submonoid of `A`. -/
def toSubmonoid {R : Type u} {A : Type v} [CommSemiring R] [Semiring A] [Algebra R A] (S : Subalgebra R A) :
    Submonoid A :=
  S.toSubsemiring.toSubmonoid
#align subalgebra.to_submonoid Subalgebra.toSubmonoid

/-- A subalgebra over a ring is also a `subring`. -/
def toSubring {R : Type u} {A : Type v} [CommRing R] [Ring A] [Algebra R A] (S : Subalgebra R A) : Subring A :=
  { S.toSubsemiring with neg_mem' := fun _ => S.neg_mem }
#align subalgebra.to_subring Subalgebra.toSubring

@[simp]
theorem mem_to_subring {R : Type u} {A : Type v} [CommRing R] [Ring A] [Algebra R A] {S : Subalgebra R A} {x} :
    x ∈ S.toSubring ↔ x ∈ S :=
  Iff.rfl
#align subalgebra.mem_to_subring Subalgebra.mem_to_subring

@[simp]
theorem coe_to_subring {R : Type u} {A : Type v} [CommRing R] [Ring A] [Algebra R A] (S : Subalgebra R A) :
    (↑S.toSubring : Set A) = S :=
  rfl
#align subalgebra.coe_to_subring Subalgebra.coe_to_subring

theorem to_subring_injective {R : Type u} {A : Type v} [CommRing R] [Ring A] [Algebra R A] :
    Function.Injective (toSubring : Subalgebra R A → Subring A) := fun S T h =>
  ext fun x => by rw [← mem_to_subring, ← mem_to_subring, h]
#align subalgebra.to_subring_injective Subalgebra.to_subring_injective

theorem to_subring_inj {R : Type u} {A : Type v} [CommRing R] [Ring A] [Algebra R A] {S U : Subalgebra R A} :
    S.toSubring = U.toSubring ↔ S = U :=
  to_subring_injective.eq_iff
#align subalgebra.to_subring_inj Subalgebra.to_subring_inj

instance : Inhabited S :=
  ⟨(0 : S.toSubsemiring)⟩

section

/-! `subalgebra`s inherit structure from their `subsemiring` / `semiring` coercions. -/


instance toSemiring {R A} [CommSemiring R] [Semiring A] [Algebra R A] (S : Subalgebra R A) : Semiring S :=
  S.toSubsemiring.toSemiring
#align subalgebra.to_semiring Subalgebra.toSemiring

instance toCommSemiring {R A} [CommSemiring R] [CommSemiring A] [Algebra R A] (S : Subalgebra R A) : CommSemiring S :=
  S.toSubsemiring.toCommSemiring
#align subalgebra.to_comm_semiring Subalgebra.toCommSemiring

instance toRing {R A} [CommRing R] [Ring A] [Algebra R A] (S : Subalgebra R A) : Ring S :=
  S.toSubring.toRing
#align subalgebra.to_ring Subalgebra.toRing

instance toCommRing {R A} [CommRing R] [CommRing A] [Algebra R A] (S : Subalgebra R A) : CommRing S :=
  S.toSubring.toCommRing
#align subalgebra.to_comm_ring Subalgebra.toCommRing

instance toOrderedSemiring {R A} [CommSemiring R] [OrderedSemiring A] [Algebra R A] (S : Subalgebra R A) :
    OrderedSemiring S :=
  S.toSubsemiring.toOrderedSemiring
#align subalgebra.to_ordered_semiring Subalgebra.toOrderedSemiring

instance toStrictOrderedSemiring {R A} [CommSemiring R] [StrictOrderedSemiring A] [Algebra R A] (S : Subalgebra R A) :
    StrictOrderedSemiring S :=
  S.toSubsemiring.toStrictOrderedSemiring
#align subalgebra.to_strict_ordered_semiring Subalgebra.toStrictOrderedSemiring

instance toOrderedCommSemiring {R A} [CommSemiring R] [OrderedCommSemiring A] [Algebra R A] (S : Subalgebra R A) :
    OrderedCommSemiring S :=
  S.toSubsemiring.toOrderedCommSemiring
#align subalgebra.to_ordered_comm_semiring Subalgebra.toOrderedCommSemiring

instance toStrictOrderedCommSemiring {R A} [CommSemiring R] [StrictOrderedCommSemiring A] [Algebra R A]
    (S : Subalgebra R A) : StrictOrderedCommSemiring S :=
  S.toSubsemiring.toStrictOrderedCommSemiring
#align subalgebra.to_strict_ordered_comm_semiring Subalgebra.toStrictOrderedCommSemiring

instance toOrderedRing {R A} [CommRing R] [OrderedRing A] [Algebra R A] (S : Subalgebra R A) : OrderedRing S :=
  S.toSubring.toOrderedRing
#align subalgebra.to_ordered_ring Subalgebra.toOrderedRing

instance toOrderedCommRing {R A} [CommRing R] [OrderedCommRing A] [Algebra R A] (S : Subalgebra R A) :
    OrderedCommRing S :=
  S.toSubring.toOrderedCommRing
#align subalgebra.to_ordered_comm_ring Subalgebra.toOrderedCommRing

instance toLinearOrderedSemiring {R A} [CommSemiring R] [LinearOrderedSemiring A] [Algebra R A] (S : Subalgebra R A) :
    LinearOrderedSemiring S :=
  S.toSubsemiring.toLinearOrderedSemiring
#align subalgebra.to_linear_ordered_semiring Subalgebra.toLinearOrderedSemiring

instance toLinearOrderedCommSemiring {R A} [CommSemiring R] [LinearOrderedCommSemiring A] [Algebra R A]
    (S : Subalgebra R A) : LinearOrderedCommSemiring S :=
  S.toSubsemiring.toLinearOrderedCommSemiring
#align subalgebra.to_linear_ordered_comm_semiring Subalgebra.toLinearOrderedCommSemiring

instance toLinearOrderedRing {R A} [CommRing R] [LinearOrderedRing A] [Algebra R A] (S : Subalgebra R A) :
    LinearOrderedRing S :=
  S.toSubring.toLinearOrderedRing
#align subalgebra.to_linear_ordered_ring Subalgebra.toLinearOrderedRing

instance toLinearOrderedCommRing {R A} [CommRing R] [LinearOrderedCommRing A] [Algebra R A] (S : Subalgebra R A) :
    LinearOrderedCommRing S :=
  S.toSubring.toLinearOrderedCommRing
#align subalgebra.to_linear_ordered_comm_ring Subalgebra.toLinearOrderedCommRing

end

/-- Convert a `subalgebra` to `submodule` -/
def toSubmodule : Submodule R A where
  carrier := S
  zero_mem' := (0 : S).2
  add_mem' x y hx hy := (⟨x, hx⟩ + ⟨y, hy⟩ : S).2
  smul_mem' c x hx := (Algebra.smul_def c x).symm ▸ (⟨algebraMap R A c, S.range_le ⟨c, rfl⟩⟩ * ⟨x, hx⟩ : S).2
#align subalgebra.to_submodule Subalgebra.toSubmodule

@[simp]
theorem mem_to_submodule {x} : x ∈ S.toSubmodule ↔ x ∈ S :=
  Iff.rfl
#align subalgebra.mem_to_submodule Subalgebra.mem_to_submodule

@[simp]
theorem coe_to_submodule (S : Subalgebra R A) : (↑S.toSubmodule : Set A) = S :=
  rfl
#align subalgebra.coe_to_submodule Subalgebra.coe_to_submodule

theorem to_submodule_injective : Function.Injective (toSubmodule : Subalgebra R A → Submodule R A) := fun S T h =>
  ext fun x => by rw [← mem_to_submodule, ← mem_to_submodule, h]
#align subalgebra.to_submodule_injective Subalgebra.to_submodule_injective

theorem to_submodule_inj {S U : Subalgebra R A} : S.toSubmodule = U.toSubmodule ↔ S = U :=
  to_submodule_injective.eq_iff
#align subalgebra.to_submodule_inj Subalgebra.to_submodule_inj

section

/-! `subalgebra`s inherit structure from their `submodule` coercions. -/


instance module' [Semiring R'] [HasSmul R' R] [Module R' A] [IsScalarTower R' R A] : Module R' S :=
  S.toSubmodule.module'
#align subalgebra.module' Subalgebra.module'

instance : Module R S :=
  S.module'

instance [Semiring R'] [HasSmul R' R] [Module R' A] [IsScalarTower R' R A] : IsScalarTower R' R S :=
  S.toSubmodule.IsScalarTower

instance algebra' [CommSemiring R'] [HasSmul R' R] [Algebra R' A] [IsScalarTower R' R A] : Algebra R' S :=
  { ((algebraMap R' A).codRestrict S) fun x => by
      rw [Algebra.algebra_map_eq_smul_one, ← smul_one_smul R x (1 : A), ← Algebra.algebra_map_eq_smul_one]
      exact algebra_map_mem S _ with
    commutes' := fun c x => Subtype.eq <| Algebra.commutes _ _,
    smul_def' := fun c x => Subtype.eq <| Algebra.smul_def _ _ }
#align subalgebra.algebra' Subalgebra.algebra'

instance : Algebra R S :=
  S.algebra'

end

instance no_zero_smul_divisors_bot [NoZeroSmulDivisors R A] : NoZeroSmulDivisors R S :=
  ⟨fun c x h =>
    have : c = 0 ∨ (x : A) = 0 := eq_zero_or_eq_zero_of_smul_eq_zero (congr_arg coe h)
    this.imp_right (@Subtype.ext_iff _ _ x 0).mpr⟩
#align subalgebra.no_zero_smul_divisors_bot Subalgebra.no_zero_smul_divisors_bot

protected theorem coe_add (x y : S) : (↑(x + y) : A) = ↑x + ↑y :=
  rfl
#align subalgebra.coe_add Subalgebra.coe_add

protected theorem coe_mul (x y : S) : (↑(x * y) : A) = ↑x * ↑y :=
  rfl
#align subalgebra.coe_mul Subalgebra.coe_mul

protected theorem coe_zero : ((0 : S) : A) = 0 :=
  rfl
#align subalgebra.coe_zero Subalgebra.coe_zero

protected theorem coe_one : ((1 : S) : A) = 1 :=
  rfl
#align subalgebra.coe_one Subalgebra.coe_one

protected theorem coe_neg {R : Type u} {A : Type v} [CommRing R] [Ring A] [Algebra R A] {S : Subalgebra R A} (x : S) :
    (↑(-x) : A) = -↑x :=
  rfl
#align subalgebra.coe_neg Subalgebra.coe_neg

protected theorem coe_sub {R : Type u} {A : Type v} [CommRing R] [Ring A] [Algebra R A] {S : Subalgebra R A} (x y : S) :
    (↑(x - y) : A) = ↑x - ↑y :=
  rfl
#align subalgebra.coe_sub Subalgebra.coe_sub

@[simp, norm_cast]
theorem coe_smul [Semiring R'] [HasSmul R' R] [Module R' A] [IsScalarTower R' R A] (r : R') (x : S) :
    (↑(r • x) : A) = r • ↑x :=
  rfl
#align subalgebra.coe_smul Subalgebra.coe_smul

@[simp, norm_cast]
theorem coe_algebra_map [CommSemiring R'] [HasSmul R' R] [Algebra R' A] [IsScalarTower R' R A] (r : R') :
    ↑(algebraMap R' S r) = algebraMap R' A r :=
  rfl
#align subalgebra.coe_algebra_map Subalgebra.coe_algebra_map

protected theorem coe_pow (x : S) (n : ℕ) : (↑(x ^ n) : A) = ↑x ^ n :=
  SubmonoidClass.coe_pow x n
#align subalgebra.coe_pow Subalgebra.coe_pow

protected theorem coe_eq_zero {x : S} : (x : A) = 0 ↔ x = 0 :=
  ZeroMemClass.coe_eq_zero
#align subalgebra.coe_eq_zero Subalgebra.coe_eq_zero

protected theorem coe_eq_one {x : S} : (x : A) = 1 ↔ x = 1 :=
  OneMemClass.coe_eq_one
#align subalgebra.coe_eq_one Subalgebra.coe_eq_one

-- todo: standardize on the names these morphisms
-- compare with submodule.subtype
/-- Embedding of a subalgebra into the algebra. -/
def val : S →ₐ[R] A := by refine_struct { toFun := (coe : S → A) } <;> intros <;> rfl
#align subalgebra.val Subalgebra.val

@[simp]
theorem coe_val : (S.val : S → A) = coe :=
  rfl
#align subalgebra.coe_val Subalgebra.coe_val

theorem val_apply (x : S) : S.val x = (x : A) :=
  rfl
#align subalgebra.val_apply Subalgebra.val_apply

@[simp]
theorem to_subsemiring_subtype : S.toSubsemiring.Subtype = (S.val : S →+* A) :=
  rfl
#align subalgebra.to_subsemiring_subtype Subalgebra.to_subsemiring_subtype

@[simp]
theorem to_subring_subtype {R A : Type _} [CommRing R] [Ring A] [Algebra R A] (S : Subalgebra R A) :
    S.toSubring.Subtype = (S.val : S →+* A) :=
  rfl
#align subalgebra.to_subring_subtype Subalgebra.to_subring_subtype

/-- Linear equivalence between `S : submodule R A` and `S`. Though these types are equal,
we define it as a `linear_equiv` to avoid type equalities. -/
def toSubmoduleEquiv (S : Subalgebra R A) : S.toSubmodule ≃ₗ[R] S :=
  LinearEquiv.ofEq _ _ rfl
#align subalgebra.to_submodule_equiv Subalgebra.toSubmoduleEquiv

/-- Transport a subalgebra via an algebra homomorphism. -/
def map (f : A →ₐ[R] B) (S : Subalgebra R A) : Subalgebra R B :=
  { S.toSubsemiring.map (f : A →+* B) with
    algebra_map_mem' := fun r => f.commutes r ▸ Set.mem_image_of_mem _ (S.algebra_map_mem r) }
#align subalgebra.map Subalgebra.map

theorem map_mono {S₁ S₂ : Subalgebra R A} {f : A →ₐ[R] B} : S₁ ≤ S₂ → S₁.map f ≤ S₂.map f :=
  Set.image_subset f
#align subalgebra.map_mono Subalgebra.map_mono

theorem map_injective {f : A →ₐ[R] B} (hf : Function.Injective f) : Function.Injective (map f) := fun S₁ S₂ ih =>
  ext <| Set.ext_iff.1 <| Set.image_injective.2 hf <| Set.ext <| SetLike.ext_iff.mp ih
#align subalgebra.map_injective Subalgebra.map_injective

@[simp]
theorem map_id (S : Subalgebra R A) : S.map (AlgHom.id R A) = S :=
  SetLike.coe_injective <| Set.image_id _
#align subalgebra.map_id Subalgebra.map_id

theorem map_map (S : Subalgebra R A) (g : B →ₐ[R] C) (f : A →ₐ[R] B) : (S.map f).map g = S.map (g.comp f) :=
  SetLike.coe_injective <| Set.image_image _ _ _
#align subalgebra.map_map Subalgebra.map_map

theorem mem_map {S : Subalgebra R A} {f : A →ₐ[R] B} {y : B} : y ∈ map f S ↔ ∃ x ∈ S, f x = y :=
  Subsemiring.mem_map
#align subalgebra.mem_map Subalgebra.mem_map

theorem map_to_submodule {S : Subalgebra R A} {f : A →ₐ[R] B} :
    (S.map f).toSubmodule = S.toSubmodule.map f.toLinearMap :=
  SetLike.coe_injective rfl
#align subalgebra.map_to_submodule Subalgebra.map_to_submodule

theorem map_to_subsemiring {S : Subalgebra R A} {f : A →ₐ[R] B} :
    (S.map f).toSubsemiring = S.toSubsemiring.map f.toRingHom :=
  SetLike.coe_injective rfl
#align subalgebra.map_to_subsemiring Subalgebra.map_to_subsemiring

@[simp]
theorem coe_map (S : Subalgebra R A) (f : A →ₐ[R] B) : (S.map f : Set B) = f '' S :=
  rfl
#align subalgebra.coe_map Subalgebra.coe_map

/-- Preimage of a subalgebra under an algebra homomorphism. -/
def comap (f : A →ₐ[R] B) (S : Subalgebra R B) : Subalgebra R A :=
  { S.toSubsemiring.comap (f : A →+* B) with
    algebra_map_mem' := fun r => show f (algebraMap R A r) ∈ S from (f.commutes r).symm ▸ S.algebra_map_mem r }
#align subalgebra.comap Subalgebra.comap

theorem map_le {S : Subalgebra R A} {f : A →ₐ[R] B} {U : Subalgebra R B} : map f S ≤ U ↔ S ≤ comap f U :=
  Set.image_subset_iff
#align subalgebra.map_le Subalgebra.map_le

theorem gc_map_comap (f : A →ₐ[R] B) : GaloisConnection (map f) (comap f) := fun S U => map_le
#align subalgebra.gc_map_comap Subalgebra.gc_map_comap

@[simp]
theorem mem_comap (S : Subalgebra R B) (f : A →ₐ[R] B) (x : A) : x ∈ S.comap f ↔ f x ∈ S :=
  Iff.rfl
#align subalgebra.mem_comap Subalgebra.mem_comap

@[simp, norm_cast]
theorem coe_comap (S : Subalgebra R B) (f : A →ₐ[R] B) : (S.comap f : Set A) = f ⁻¹' (S : Set B) :=
  rfl
#align subalgebra.coe_comap Subalgebra.coe_comap

instance no_zero_divisors {R A : Type _} [CommSemiring R] [Semiring A] [NoZeroDivisors A] [Algebra R A]
    (S : Subalgebra R A) : NoZeroDivisors S :=
  S.toSubsemiring.NoZeroDivisors
#align subalgebra.no_zero_divisors Subalgebra.no_zero_divisors

instance isDomain {R A : Type _} [CommRing R] [Ring A] [IsDomain A] [Algebra R A] (S : Subalgebra R A) : IsDomain S :=
  Subring.isDomain S.toSubring
#align subalgebra.is_domain Subalgebra.isDomain

end Subalgebra

namespace Submodule

variable {R A : Type _} [CommSemiring R] [Semiring A] [Algebra R A]

variable (p : Submodule R A)

/-- A submodule containing `1` and closed under multiplication is a subalgebra. -/
def toSubalgebra (p : Submodule R A) (h_one : (1 : A) ∈ p) (h_mul : ∀ x y, x ∈ p → y ∈ p → x * y ∈ p) :
    Subalgebra R A :=
  { p with mul_mem' := h_mul,
    algebra_map_mem' := fun r => by
      rw [Algebra.algebra_map_eq_smul_one]
      exact p.smul_mem _ h_one }
#align submodule.to_subalgebra Submodule.toSubalgebra

@[simp]
theorem mem_to_subalgebra {p : Submodule R A} {h_one h_mul} {x} : x ∈ p.toSubalgebra h_one h_mul ↔ x ∈ p :=
  Iff.rfl
#align submodule.mem_to_subalgebra Submodule.mem_to_subalgebra

@[simp]
theorem coe_to_subalgebra (p : Submodule R A) (h_one h_mul) : (p.toSubalgebra h_one h_mul : Set A) = p :=
  rfl
#align submodule.coe_to_subalgebra Submodule.coe_to_subalgebra

@[simp]
theorem to_subalgebra_mk (s : Set A) (h0 hadd hsmul h1 hmul) :
    (Submodule.mk s hadd h0 hsmul : Submodule R A).toSubalgebra h1 hmul =
      Subalgebra.mk s (@hmul) h1 (@hadd) h0 fun r => by
        rw [Algebra.algebra_map_eq_smul_one]
        exact hsmul r h1 :=
  rfl
#align submodule.to_subalgebra_mk Submodule.to_subalgebra_mk

@[simp]
theorem to_subalgebra_to_submodule (p : Submodule R A) (h_one h_mul) : (p.toSubalgebra h_one h_mul).toSubmodule = p :=
  SetLike.coe_injective rfl
#align submodule.to_subalgebra_to_submodule Submodule.to_subalgebra_to_submodule

@[simp]
theorem _root_.subalgebra.to_submodule_to_subalgebra (S : Subalgebra R A) :
    (S.toSubmodule.toSubalgebra S.one_mem fun _ _ => S.mul_mem) = S :=
  SetLike.coe_injective rfl
#align submodule._root_.subalgebra.to_submodule_to_subalgebra submodule._root_.subalgebra.to_submodule_to_subalgebra

end Submodule

namespace AlgHom

variable {R' : Type u'} {R : Type u} {A : Type v} {B : Type w} {C : Type w'}

variable [CommSemiring R]

variable [Semiring A] [Algebra R A] [Semiring B] [Algebra R B] [Semiring C] [Algebra R C]

variable (φ : A →ₐ[R] B)

/-- Range of an `alg_hom` as a subalgebra. -/
protected def range (φ : A →ₐ[R] B) : Subalgebra R B :=
  { φ.toRingHom.srange with algebra_map_mem' := fun r => ⟨algebraMap R A r, φ.commutes r⟩ }
#align alg_hom.range AlgHom.range

@[simp]
theorem mem_range (φ : A →ₐ[R] B) {y : B} : y ∈ φ.range ↔ ∃ x, φ x = y :=
  RingHom.mem_srange
#align alg_hom.mem_range AlgHom.mem_range

theorem mem_range_self (φ : A →ₐ[R] B) (x : A) : φ x ∈ φ.range :=
  φ.mem_range.2 ⟨x, rfl⟩
#align alg_hom.mem_range_self AlgHom.mem_range_self

@[simp]
theorem coe_range (φ : A →ₐ[R] B) : (φ.range : Set B) = Set.range φ := by
  ext
  rw [SetLike.mem_coe, mem_range]
  rfl
#align alg_hom.coe_range AlgHom.coe_range

theorem range_comp (f : A →ₐ[R] B) (g : B →ₐ[R] C) : (g.comp f).range = f.range.map g :=
  SetLike.coe_injective (Set.range_comp g f)
#align alg_hom.range_comp AlgHom.range_comp

theorem range_comp_le_range (f : A →ₐ[R] B) (g : B →ₐ[R] C) : (g.comp f).range ≤ g.range :=
  SetLike.coe_mono (Set.range_comp_subset_range f g)
#align alg_hom.range_comp_le_range AlgHom.range_comp_le_range

/-- Restrict the codomain of an algebra homomorphism. -/
def codRestrict (f : A →ₐ[R] B) (S : Subalgebra R B) (hf : ∀ x, f x ∈ S) : A →ₐ[R] S :=
  { RingHom.codRestrict (f : A →+* B) S hf with commutes' := fun r => Subtype.eq <| f.commutes r }
#align alg_hom.cod_restrict AlgHom.codRestrict

@[simp]
theorem val_comp_cod_restrict (f : A →ₐ[R] B) (S : Subalgebra R B) (hf : ∀ x, f x ∈ S) :
    S.val.comp (f.codRestrict S hf) = f :=
  AlgHom.ext fun _ => rfl
#align alg_hom.val_comp_cod_restrict AlgHom.val_comp_cod_restrict

@[simp]
theorem coe_cod_restrict (f : A →ₐ[R] B) (S : Subalgebra R B) (hf : ∀ x, f x ∈ S) (x : A) :
    ↑(f.codRestrict S hf x) = f x :=
  rfl
#align alg_hom.coe_cod_restrict AlgHom.coe_cod_restrict

theorem injective_cod_restrict (f : A →ₐ[R] B) (S : Subalgebra R B) (hf : ∀ x, f x ∈ S) :
    Function.Injective (f.codRestrict S hf) ↔ Function.Injective f :=
  ⟨fun H x y hxy => H <| Subtype.eq hxy, fun H x y hxy => H (congr_arg Subtype.val hxy : _)⟩
#align alg_hom.injective_cod_restrict AlgHom.injective_cod_restrict

/-- Restrict the codomain of a alg_hom `f` to `f.range`.

This is the bundled version of `set.range_factorization`. -/
@[reducible]
def rangeRestrict (f : A →ₐ[R] B) : A →ₐ[R] f.range :=
  f.codRestrict f.range f.mem_range_self
#align alg_hom.range_restrict AlgHom.rangeRestrict

/-- The equalizer of two R-algebra homomorphisms -/
def equalizer (ϕ ψ : A →ₐ[R] B) : Subalgebra R A where
  carrier := { a | ϕ a = ψ a }
  add_mem' x y (hx : ϕ x = ψ x) (hy : ϕ y = ψ y) := by rw [Set.mem_set_of_eq, ϕ.map_add, ψ.map_add, hx, hy]
  mul_mem' x y (hx : ϕ x = ψ x) (hy : ϕ y = ψ y) := by rw [Set.mem_set_of_eq, ϕ.map_mul, ψ.map_mul, hx, hy]
  algebra_map_mem' x := by rw [Set.mem_set_of_eq, AlgHom.commutes, AlgHom.commutes]
#align alg_hom.equalizer AlgHom.equalizer

@[simp]
theorem mem_equalizer (ϕ ψ : A →ₐ[R] B) (x : A) : x ∈ ϕ.equalizer ψ ↔ ϕ x = ψ x :=
  Iff.rfl
#align alg_hom.mem_equalizer AlgHom.mem_equalizer

/-- The range of a morphism of algebras is a fintype, if the domain is a fintype.

Note that this instance can cause a diamond with `subtype.fintype` if `B` is also a fintype. -/
instance fintypeRange [Fintype A] [DecidableEq B] (φ : A →ₐ[R] B) : Fintype φ.range :=
  Set.fintypeRange φ
#align alg_hom.fintype_range AlgHom.fintypeRange

end AlgHom

namespace AlgEquiv

variable {R : Type u} {A : Type v} {B : Type w}

variable [CommSemiring R] [Semiring A] [Semiring B] [Algebra R A] [Algebra R B]

/-- Restrict an algebra homomorphism with a left inverse to an algebra isomorphism to its range.

This is a computable alternative to `alg_equiv.of_injective`. -/
def ofLeftInverse {g : B → A} {f : A →ₐ[R] B} (h : Function.LeftInverse g f) : A ≃ₐ[R] f.range :=
  { f.range_restrict with toFun := f.range_restrict, invFun := g ∘ f.range.val, left_inv := h,
    right_inv := fun x =>
      Subtype.ext <|
        let ⟨x', hx'⟩ := f.mem_range.mp x.Prop
        show f (g x) = x by rw [← hx', h x'] }
#align alg_equiv.of_left_inverse AlgEquiv.ofLeftInverse

@[simp]
theorem of_left_inverse_apply {g : B → A} {f : A →ₐ[R] B} (h : Function.LeftInverse g f) (x : A) :
    ↑(ofLeftInverse h x) = f x :=
  rfl
#align alg_equiv.of_left_inverse_apply AlgEquiv.of_left_inverse_apply

@[simp]
theorem of_left_inverse_symm_apply {g : B → A} {f : A →ₐ[R] B} (h : Function.LeftInverse g f) (x : f.range) :
    (ofLeftInverse h).symm x = g x :=
  rfl
#align alg_equiv.of_left_inverse_symm_apply AlgEquiv.of_left_inverse_symm_apply

/-- Restrict an injective algebra homomorphism to an algebra isomorphism -/
noncomputable def ofInjective (f : A →ₐ[R] B) (hf : Function.Injective f) : A ≃ₐ[R] f.range :=
  ofLeftInverse (Classical.choose_spec hf.HasLeftInverse)
#align alg_equiv.of_injective AlgEquiv.ofInjective

@[simp]
theorem of_injective_apply (f : A →ₐ[R] B) (hf : Function.Injective f) (x : A) : ↑(ofInjective f hf x) = f x :=
  rfl
#align alg_equiv.of_injective_apply AlgEquiv.of_injective_apply

/-- Restrict an algebra homomorphism between fields to an algebra isomorphism -/
noncomputable def ofInjectiveField {E F : Type _} [DivisionRing E] [Semiring F] [Nontrivial F] [Algebra R E]
    [Algebra R F] (f : E →ₐ[R] F) : E ≃ₐ[R] f.range :=
  ofInjective f f.toRingHom.Injective
#align alg_equiv.of_injective_field AlgEquiv.ofInjectiveField

/-- Given an equivalence `e : A ≃ₐ[R] B` of `R`-algebras and a subalgebra `S` of `A`,
`subalgebra_map` is the induced equivalence between `S` and `S.map e` -/
@[simps]
def subalgebraMap (e : A ≃ₐ[R] B) (S : Subalgebra R A) : S ≃ₐ[R] S.map e.toAlgHom :=
  { e.toRingEquiv.subsemiringMap S.toSubsemiring with
    commutes' := fun r => by
      ext
      simp }
#align alg_equiv.subalgebra_map AlgEquiv.subalgebraMap

end AlgEquiv

namespace Algebra

variable (R : Type u) {A : Type v} {B : Type w}

variable [CommSemiring R] [Semiring A] [Algebra R A] [Semiring B] [Algebra R B]

/-- The minimal subalgebra that includes `s`. -/
def adjoin (s : Set A) : Subalgebra R A :=
  { Subsemiring.closure (Set.range (algebraMap R A) ∪ s) with
    algebra_map_mem' := fun r => Subsemiring.subset_closure <| Or.inl ⟨r, rfl⟩ }
#align algebra.adjoin Algebra.adjoin

variable {R}

protected theorem gc : GaloisConnection (adjoin R : Set A → Subalgebra R A) coe := fun s S =>
  ⟨fun H => le_trans (le_trans (Set.subset_union_right _ _) Subsemiring.subset_closure) H, fun H =>
    show Subsemiring.closure (Set.range (algebraMap R A) ∪ s) ≤ S.toSubsemiring from
      Subsemiring.closure_le.2 <| Set.union_subset S.range_subset H⟩
#align algebra.gc Algebra.gc

/-- Galois insertion between `adjoin` and `coe`. -/
protected def gi : GaloisInsertion (adjoin R : Set A → Subalgebra R A) coe where
  choice s hs := (adjoin R s).copy s <| le_antisymm (Algebra.gc.le_u_l s) hs
  gc := Algebra.gc
  le_l_u S := (Algebra.gc (S : Set A) (adjoin R S)).1 <| le_rfl
  choice_eq _ _ := Subalgebra.copy_eq _ _ _
#align algebra.gi Algebra.gi

instance : CompleteLattice (Subalgebra R A) :=
  GaloisInsertion.liftCompleteLattice Algebra.gi

@[simp]
theorem coe_top : (↑(⊤ : Subalgebra R A) : Set A) = Set.univ :=
  rfl
#align algebra.coe_top Algebra.coe_top

@[simp]
theorem mem_top {x : A} : x ∈ (⊤ : Subalgebra R A) :=
  Set.mem_univ x
#align algebra.mem_top Algebra.mem_top

@[simp]
theorem top_to_submodule : (⊤ : Subalgebra R A).toSubmodule = ⊤ :=
  rfl
#align algebra.top_to_submodule Algebra.top_to_submodule

@[simp]
theorem top_to_subsemiring : (⊤ : Subalgebra R A).toSubsemiring = ⊤ :=
  rfl
#align algebra.top_to_subsemiring Algebra.top_to_subsemiring

@[simp]
theorem top_to_subring {R A : Type _} [CommRing R] [Ring A] [Algebra R A] : (⊤ : Subalgebra R A).toSubring = ⊤ :=
  rfl
#align algebra.top_to_subring Algebra.top_to_subring

@[simp]
theorem to_submodule_eq_top {S : Subalgebra R A} : S.toSubmodule = ⊤ ↔ S = ⊤ :=
  Subalgebra.to_submodule_injective.eq_iff' top_to_submodule
#align algebra.to_submodule_eq_top Algebra.to_submodule_eq_top

@[simp]
theorem to_subsemiring_eq_top {S : Subalgebra R A} : S.toSubsemiring = ⊤ ↔ S = ⊤ :=
  Subalgebra.to_subsemiring_injective.eq_iff' top_to_subsemiring
#align algebra.to_subsemiring_eq_top Algebra.to_subsemiring_eq_top

@[simp]
theorem to_subring_eq_top {R A : Type _} [CommRing R] [Ring A] [Algebra R A] {S : Subalgebra R A} :
    S.toSubring = ⊤ ↔ S = ⊤ :=
  Subalgebra.to_subring_injective.eq_iff' top_to_subring
#align algebra.to_subring_eq_top Algebra.to_subring_eq_top

theorem mem_sup_left {S T : Subalgebra R A} : ∀ {x : A}, x ∈ S → x ∈ S ⊔ T :=
  show S ≤ S ⊔ T from le_sup_left
#align algebra.mem_sup_left Algebra.mem_sup_left

theorem mem_sup_right {S T : Subalgebra R A} : ∀ {x : A}, x ∈ T → x ∈ S ⊔ T :=
  show T ≤ S ⊔ T from le_sup_right
#align algebra.mem_sup_right Algebra.mem_sup_right

theorem mul_mem_sup {S T : Subalgebra R A} {x y : A} (hx : x ∈ S) (hy : y ∈ T) : x * y ∈ S ⊔ T :=
  (S ⊔ T).mul_mem (mem_sup_left hx) (mem_sup_right hy)
#align algebra.mul_mem_sup Algebra.mul_mem_sup

theorem map_sup (f : A →ₐ[R] B) (S T : Subalgebra R A) : (S ⊔ T).map f = S.map f ⊔ T.map f :=
  (Subalgebra.gc_map_comap f).l_sup
#align algebra.map_sup Algebra.map_sup

@[simp, norm_cast]
theorem coe_inf (S T : Subalgebra R A) : (↑(S ⊓ T) : Set A) = S ∩ T :=
  rfl
#align algebra.coe_inf Algebra.coe_inf

@[simp]
theorem mem_inf {S T : Subalgebra R A} {x : A} : x ∈ S ⊓ T ↔ x ∈ S ∧ x ∈ T :=
  Iff.rfl
#align algebra.mem_inf Algebra.mem_inf

@[simp]
theorem inf_to_submodule (S T : Subalgebra R A) : (S ⊓ T).toSubmodule = S.toSubmodule ⊓ T.toSubmodule :=
  rfl
#align algebra.inf_to_submodule Algebra.inf_to_submodule

@[simp]
theorem inf_to_subsemiring (S T : Subalgebra R A) : (S ⊓ T).toSubsemiring = S.toSubsemiring ⊓ T.toSubsemiring :=
  rfl
#align algebra.inf_to_subsemiring Algebra.inf_to_subsemiring

@[simp, norm_cast]
theorem coe_Inf (S : Set (Subalgebra R A)) : (↑(inf S) : Set A) = ⋂ s ∈ S, ↑s :=
  Inf_image
#align algebra.coe_Inf Algebra.coe_Inf

theorem mem_Inf {S : Set (Subalgebra R A)} {x : A} : x ∈ inf S ↔ ∀ p ∈ S, x ∈ p := by
  simp only [← SetLike.mem_coe, coe_Inf, Set.mem_Inter₂]
#align algebra.mem_Inf Algebra.mem_Inf

@[simp]
theorem Inf_to_submodule (S : Set (Subalgebra R A)) : (inf S).toSubmodule = inf (Subalgebra.toSubmodule '' S) :=
  SetLike.coe_injective <| by simp
#align algebra.Inf_to_submodule Algebra.Inf_to_submodule

@[simp]
theorem Inf_to_subsemiring (S : Set (Subalgebra R A)) : (inf S).toSubsemiring = inf (Subalgebra.toSubsemiring '' S) :=
  SetLike.coe_injective <| by simp
#align algebra.Inf_to_subsemiring Algebra.Inf_to_subsemiring

@[simp, norm_cast]
theorem coe_infi {ι : Sort _} {S : ι → Subalgebra R A} : (↑(⨅ i, S i) : Set A) = ⋂ i, S i := by simp [infi]
#align algebra.coe_infi Algebra.coe_infi

theorem mem_infi {ι : Sort _} {S : ι → Subalgebra R A} {x : A} : (x ∈ ⨅ i, S i) ↔ ∀ i, x ∈ S i := by
  simp only [infi, mem_Inf, Set.forall_range_iff]
#align algebra.mem_infi Algebra.mem_infi

@[simp]
theorem infi_to_submodule {ι : Sort _} (S : ι → Subalgebra R A) : (⨅ i, S i).toSubmodule = ⨅ i, (S i).toSubmodule :=
  SetLike.coe_injective <| by simp
#align algebra.infi_to_submodule Algebra.infi_to_submodule

instance : Inhabited (Subalgebra R A) :=
  ⟨⊥⟩

theorem mem_bot {x : A} : x ∈ (⊥ : Subalgebra R A) ↔ x ∈ Set.range (algebraMap R A) :=
  suffices (ofId R A).range = (⊥ : Subalgebra R A) by
    rw [← this, ← SetLike.mem_coe, AlgHom.coe_range]
    rfl
  le_bot_iff.mp fun x hx => Subalgebra.range_le _ ((ofId R A).coe_range ▸ hx)
#align algebra.mem_bot Algebra.mem_bot

theorem to_submodule_bot : (⊥ : Subalgebra R A).toSubmodule = R ∙ 1 := by
  ext x
  simp [mem_bot, -Set.singleton_one, Submodule.mem_span_singleton, Algebra.smul_def]
#align algebra.to_submodule_bot Algebra.to_submodule_bot

@[simp]
theorem coe_bot : ((⊥ : Subalgebra R A) : Set A) = Set.range (algebraMap R A) := by simp [Set.ext_iff, Algebra.mem_bot]
#align algebra.coe_bot Algebra.coe_bot

theorem eq_top_iff {S : Subalgebra R A} : S = ⊤ ↔ ∀ x : A, x ∈ S :=
  ⟨fun h x => by rw [h] <;> exact mem_top, fun h => by ext x <;> exact ⟨fun _ => mem_top, fun _ => h x⟩⟩
#align algebra.eq_top_iff Algebra.eq_top_iff

theorem range_top_iff_surjective (f : A →ₐ[R] B) : f.range = (⊤ : Subalgebra R B) ↔ Function.Surjective f :=
  Algebra.eq_top_iff
#align algebra.range_top_iff_surjective Algebra.range_top_iff_surjective

@[simp]
theorem range_id : (AlgHom.id R A).range = ⊤ :=
  SetLike.coe_injective Set.range_id
#align algebra.range_id Algebra.range_id

@[simp]
theorem map_top (f : A →ₐ[R] B) : (⊤ : Subalgebra R A).map f = f.range :=
  SetLike.coe_injective Set.image_univ
#align algebra.map_top Algebra.map_top

@[simp]
theorem map_bot (f : A →ₐ[R] B) : (⊥ : Subalgebra R A).map f = ⊥ :=
  SetLike.coe_injective <| by simp only [← Set.range_comp, (· ∘ ·), Algebra.coe_bot, Subalgebra.coe_map, f.commutes]
#align algebra.map_bot Algebra.map_bot

@[simp]
theorem comap_top (f : A →ₐ[R] B) : (⊤ : Subalgebra R B).comap f = ⊤ :=
  eq_top_iff.2 fun x => mem_top
#align algebra.comap_top Algebra.comap_top

/-- `alg_hom` to `⊤ : subalgebra R A`. -/
def toTop : A →ₐ[R] (⊤ : Subalgebra R A) :=
  (AlgHom.id R A).codRestrict ⊤ fun _ => mem_top
#align algebra.to_top Algebra.toTop

theorem surjective_algebra_map_iff : Function.Surjective (algebraMap R A) ↔ (⊤ : Subalgebra R A) = ⊥ :=
  ⟨fun h =>
    eq_bot_iff.2 fun y _ =>
      let ⟨x, hx⟩ := h y
      hx ▸ Subalgebra.algebra_map_mem _ _,
    fun h y => Algebra.mem_bot.1 <| eq_bot_iff.1 h (Algebra.mem_top : y ∈ _)⟩
#align algebra.surjective_algebra_map_iff Algebra.surjective_algebra_map_iff

theorem bijective_algebra_map_iff {R A : Type _} [Field R] [Semiring A] [Nontrivial A] [Algebra R A] :
    Function.Bijective (algebraMap R A) ↔ (⊤ : Subalgebra R A) = ⊥ :=
  ⟨fun h => surjective_algebra_map_iff.1 h.2, fun h => ⟨(algebraMap R A).Injective, surjective_algebra_map_iff.2 h⟩⟩
#align algebra.bijective_algebra_map_iff Algebra.bijective_algebra_map_iff

/-- The bottom subalgebra is isomorphic to the base ring. -/
noncomputable def botEquivOfInjective (h : Function.Injective (algebraMap R A)) : (⊥ : Subalgebra R A) ≃ₐ[R] R :=
  AlgEquiv.symm <|
    AlgEquiv.ofBijective (Algebra.ofId R _)
      ⟨fun x y hxy => h (congr_arg Subtype.val hxy : _), fun ⟨y, hy⟩ =>
        let ⟨x, hx⟩ := Algebra.mem_bot.1 hy
        ⟨x, Subtype.eq hx⟩⟩
#align algebra.bot_equiv_of_injective Algebra.botEquivOfInjective

/-- The bottom subalgebra is isomorphic to the field. -/
@[simps symmApply]
noncomputable def botEquiv (F R : Type _) [Field F] [Semiring R] [Nontrivial R] [Algebra F R] :
    (⊥ : Subalgebra F R) ≃ₐ[F] F :=
  botEquivOfInjective (RingHom.injective _)
#align algebra.bot_equiv Algebra.botEquiv

end Algebra

namespace Subalgebra

open Algebra

variable {R : Type u} {A : Type v} {B : Type w}

variable [CommSemiring R] [Semiring A] [Algebra R A] [Semiring B] [Algebra R B]

variable (S : Subalgebra R A)

/-- The top subalgebra is isomorphic to the algebra.

This is the algebra version of `submodule.top_equiv`. -/
@[simps]
def topEquiv : (⊤ : Subalgebra R A) ≃ₐ[R] A :=
  AlgEquiv.ofAlgHom (Subalgebra.val ⊤) toTop rfl <| AlgHom.ext fun _ => Subtype.ext rfl
#align subalgebra.top_equiv Subalgebra.topEquiv

instance subsingleton_of_subsingleton [Subsingleton A] : Subsingleton (Subalgebra R A) :=
  ⟨fun B C => ext fun x => by simp only [Subsingleton.elim x 0, zero_mem B, zero_mem C]⟩
#align subalgebra.subsingleton_of_subsingleton Subalgebra.subsingleton_of_subsingleton

instance _root_.alg_hom.subsingleton [Subsingleton (Subalgebra R A)] : Subsingleton (A →ₐ[R] B) :=
  ⟨fun f g =>
    AlgHom.ext fun a =>
      have : a ∈ (⊥ : Subalgebra R A) := Subsingleton.elim (⊤ : Subalgebra R A) ⊥ ▸ mem_top
      let ⟨x, hx⟩ := Set.mem_range.mp (mem_bot.mp this)
      hx ▸ (f.commutes _).trans (g.commutes _).symm⟩
#align subalgebra._root_.alg_hom.subsingleton subalgebra._root_.alg_hom.subsingleton

instance _root_.alg_equiv.subsingleton_left [Subsingleton (Subalgebra R A)] : Subsingleton (A ≃ₐ[R] B) :=
  ⟨fun f g => AlgEquiv.ext fun x => AlgHom.ext_iff.mp (Subsingleton.elim f.toAlgHom g.toAlgHom) x⟩
#align subalgebra._root_.alg_equiv.subsingleton_left subalgebra._root_.alg_equiv.subsingleton_left

instance _root_.alg_equiv.subsingleton_right [Subsingleton (Subalgebra R B)] : Subsingleton (A ≃ₐ[R] B) :=
  ⟨fun f g => by rw [← f.symm_symm, Subsingleton.elim f.symm g.symm, g.symm_symm]⟩
#align subalgebra._root_.alg_equiv.subsingleton_right subalgebra._root_.alg_equiv.subsingleton_right

theorem range_val : S.val.range = S :=
  ext <| Set.ext_iff.1 <| S.val.coe_range.trans Subtype.range_val
#align subalgebra.range_val Subalgebra.range_val

instance : Unique (Subalgebra R R) :=
  { Algebra.Subalgebra.inhabited with
    uniq := by
      intro S
      refine' le_antisymm (fun r hr => _) bot_le
      simp only [Set.mem_range, mem_bot, id.map_eq_self, exists_apply_eq_apply, default] }

/-- The map `S → T` when `S` is a subalgebra contained in the subalgebra `T`.

This is the subalgebra version of `submodule.of_le`, or `subring.inclusion`  -/
def inclusion {S T : Subalgebra R A} (h : S ≤ T) : S →ₐ[R] T where
  toFun := Set.inclusion h
  map_one' := rfl
  map_add' _ _ := rfl
  map_mul' _ _ := rfl
  map_zero' := rfl
  commutes' _ := rfl
#align subalgebra.inclusion Subalgebra.inclusion

theorem inclusion_injective {S T : Subalgebra R A} (h : S ≤ T) : Function.Injective (inclusion h) := fun _ _ =>
  Subtype.ext ∘ Subtype.mk.inj
#align subalgebra.inclusion_injective Subalgebra.inclusion_injective

@[simp]
theorem inclusion_self {S : Subalgebra R A} : inclusion (le_refl S) = AlgHom.id R S :=
  AlgHom.ext fun x => Subtype.ext rfl
#align subalgebra.inclusion_self Subalgebra.inclusion_self

@[simp]
theorem inclusion_mk {S T : Subalgebra R A} (h : S ≤ T) (x : A) (hx : x ∈ S) : inclusion h ⟨x, hx⟩ = ⟨x, h hx⟩ :=
  rfl
#align subalgebra.inclusion_mk Subalgebra.inclusion_mk

theorem inclusion_right {S T : Subalgebra R A} (h : S ≤ T) (x : T) (m : (x : A) ∈ S) : inclusion h ⟨x, m⟩ = x :=
  Subtype.ext rfl
#align subalgebra.inclusion_right Subalgebra.inclusion_right

@[simp]
theorem inclusion_inclusion {S T U : Subalgebra R A} (hst : S ≤ T) (htu : T ≤ U) (x : S) :
    inclusion htu (inclusion hst x) = inclusion (le_trans hst htu) x :=
  Subtype.ext rfl
#align subalgebra.inclusion_inclusion Subalgebra.inclusion_inclusion

@[simp]
theorem coe_inclusion {S T : Subalgebra R A} (h : S ≤ T) (s : S) : (inclusion h s : A) = s :=
  rfl
#align subalgebra.coe_inclusion Subalgebra.coe_inclusion

/-- Two subalgebras that are equal are also equivalent as algebras.

This is the `subalgebra` version of `linear_equiv.of_eq` and `equiv.set.of_eq`. -/
@[simps apply]
def equivOfEq (S T : Subalgebra R A) (h : S = T) : S ≃ₐ[R] T :=
  { LinearEquiv.ofEq _ _ (congr_arg toSubmodule h) with toFun := fun x => ⟨x, h ▸ x.2⟩,
    invFun := fun x => ⟨x, h.symm ▸ x.2⟩, map_mul' := fun _ _ => rfl, commutes' := fun _ => rfl }
#align subalgebra.equiv_of_eq Subalgebra.equivOfEq

@[simp]
theorem equiv_of_eq_symm (S T : Subalgebra R A) (h : S = T) : (equivOfEq S T h).symm = equivOfEq T S h.symm :=
  rfl
#align subalgebra.equiv_of_eq_symm Subalgebra.equiv_of_eq_symm

@[simp]
theorem equiv_of_eq_rfl (S : Subalgebra R A) : equivOfEq S S rfl = AlgEquiv.refl := by
  ext
  rfl
#align subalgebra.equiv_of_eq_rfl Subalgebra.equiv_of_eq_rfl

@[simp]
theorem equiv_of_eq_trans (S T U : Subalgebra R A) (hST : S = T) (hTU : T = U) :
    (equivOfEq S T hST).trans (equivOfEq T U hTU) = equivOfEq S U (trans hST hTU) :=
  rfl
#align subalgebra.equiv_of_eq_trans Subalgebra.equiv_of_eq_trans

section Prod

variable (S₁ : Subalgebra R B)

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- The product of two subalgebras is a subalgebra. -/
def prod : Subalgebra R (A × B) :=
  { S.toSubsemiring.Prod S₁.toSubsemiring with carrier := S ×ˢ S₁,
    algebra_map_mem' := fun r => ⟨algebra_map_mem _ _, algebra_map_mem _ _⟩ }
#align subalgebra.prod Subalgebra.prod

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simp]
theorem coe_prod : (prod S S₁ : Set (A × B)) = S ×ˢ S₁ :=
  rfl
#align subalgebra.coe_prod Subalgebra.coe_prod

theorem prod_to_submodule : (S.Prod S₁).toSubmodule = S.toSubmodule.Prod S₁.toSubmodule :=
  rfl
#align subalgebra.prod_to_submodule Subalgebra.prod_to_submodule

@[simp]
theorem mem_prod {S : Subalgebra R A} {S₁ : Subalgebra R B} {x : A × B} : x ∈ prod S S₁ ↔ x.1 ∈ S ∧ x.2 ∈ S₁ :=
  Set.mem_prod
#align subalgebra.mem_prod Subalgebra.mem_prod

@[simp]
theorem prod_top : (prod ⊤ ⊤ : Subalgebra R (A × B)) = ⊤ := by ext <;> simp
#align subalgebra.prod_top Subalgebra.prod_top

theorem prod_mono {S T : Subalgebra R A} {S₁ T₁ : Subalgebra R B} : S ≤ T → S₁ ≤ T₁ → prod S S₁ ≤ prod T T₁ :=
  Set.prod_mono
#align subalgebra.prod_mono Subalgebra.prod_mono

@[simp]
theorem prod_inf_prod {S T : Subalgebra R A} {S₁ T₁ : Subalgebra R B} :
    S.Prod S₁ ⊓ T.Prod T₁ = (S ⊓ T).Prod (S₁ ⊓ T₁) :=
  SetLike.coe_injective Set.prod_inter_prod
#align subalgebra.prod_inf_prod Subalgebra.prod_inf_prod

end Prod

section SuprLift

variable {ι : Type _}

theorem coe_supr_of_directed [Nonempty ι] {S : ι → Subalgebra R A} (dir : Directed (· ≤ ·) S) :
    ↑(supr S) = ⋃ i, (S i : Set A) :=
  let K : Subalgebra R A :=
    { carrier := ⋃ i, S i,
      mul_mem' := fun x y hx hy =>
        let ⟨i, hi⟩ := Set.mem_Union.1 hx
        let ⟨j, hj⟩ := Set.mem_Union.1 hy
        let ⟨k, hik, hjk⟩ := dir i j
        Set.mem_Union.2 ⟨k, Subalgebra.mul_mem (S k) (hik hi) (hjk hj)⟩,
      add_mem' := fun x y hx hy =>
        let ⟨i, hi⟩ := Set.mem_Union.1 hx
        let ⟨j, hj⟩ := Set.mem_Union.1 hy
        let ⟨k, hik, hjk⟩ := dir i j
        Set.mem_Union.2 ⟨k, Subalgebra.add_mem (S k) (hik hi) (hjk hj)⟩,
      algebra_map_mem' := fun r =>
        let i := @Nonempty.some ι inferInstance
        Set.mem_Union.2 ⟨i, Subalgebra.algebra_map_mem _ _⟩ }
  have : supr S = K :=
    le_antisymm (supr_le fun i => Set.subset_Union (fun i => ↑(S i)) i)
      (SetLike.coe_subset_coe.1 (Set.Union_subset fun i => SetLike.coe_subset_coe.2 (le_supr _ _)))
  this.symm ▸ rfl
#align subalgebra.coe_supr_of_directed Subalgebra.coe_supr_of_directed

/-- Define an algebra homomorphism on a directed supremum of subalgebras by defining
it on each subalgebra, and proving that it agrees on the intersection of subalgebras. -/
noncomputable def suprLift [Nonempty ι] (K : ι → Subalgebra R A) (dir : Directed (· ≤ ·) K) (f : ∀ i, K i →ₐ[R] B)
    (hf : ∀ (i j : ι) (h : K i ≤ K j), f i = (f j).comp (inclusion h)) (T : Subalgebra R A) (hT : T = supr K) :
    ↥T →ₐ[R] B := by
  subst hT <;>
    exact
      { toFun :=
          Set.unionLift (fun i => ↑(K i)) (fun i x => f i x)
            (fun i j x hxi hxj => by
              let ⟨k, hik, hjk⟩ := dir i j
              rw [hf i k hik, hf j k hjk]
              rfl)
            (↑(supr K)) (by rw [coe_supr_of_directed dir] <;> rfl),
        map_one' := Set.Union_lift_const _ (fun _ => 1) (fun _ => rfl) _ (by simp),
        map_zero' := Set.Union_lift_const _ (fun _ => 0) (fun _ => rfl) _ (by simp),
        map_mul' :=
          Set.Union_lift_binary (coe_supr_of_directed dir) dir _ (fun _ => (· * ·)) (fun _ _ _ => rfl) _ (by simp),
        map_add' :=
          Set.Union_lift_binary (coe_supr_of_directed dir) dir _ (fun _ => (· + ·)) (fun _ _ _ => rfl) _ (by simp),
        commutes' := fun r =>
          Set.Union_lift_const _ (fun _ => algebraMap _ _ r) (fun _ => rfl) _ fun i => by erw [AlgHom.commutes (f i)] }
#align subalgebra.supr_lift Subalgebra.suprLift

variable [Nonempty ι] {K : ι → Subalgebra R A} {dir : Directed (· ≤ ·) K} {f : ∀ i, K i →ₐ[R] B}
  {hf : ∀ (i j : ι) (h : K i ≤ K j), f i = (f j).comp (inclusion h)} {T : Subalgebra R A} {hT : T = supr K}

@[simp]
theorem supr_lift_inclusion {i : ι} (x : K i) (h : K i ≤ T) : suprLift K dir f hf T hT (inclusion h x) = f i x := by
  subst T <;> exact Set.Union_lift_inclusion _ _
#align subalgebra.supr_lift_inclusion Subalgebra.supr_lift_inclusion

@[simp]
theorem supr_lift_comp_inclusion {i : ι} (h : K i ≤ T) : (suprLift K dir f hf T hT).comp (inclusion h) = f i := by
  ext <;> simp
#align subalgebra.supr_lift_comp_inclusion Subalgebra.supr_lift_comp_inclusion

@[simp]
theorem supr_lift_mk {i : ι} (x : K i) (hx : (x : A) ∈ T) : suprLift K dir f hf T hT ⟨x, hx⟩ = f i x := by
  subst hT <;> exact Set.Union_lift_mk x hx
#align subalgebra.supr_lift_mk Subalgebra.supr_lift_mk

theorem supr_lift_of_mem {i : ι} (x : T) (hx : (x : A) ∈ K i) : suprLift K dir f hf T hT x = f i ⟨x, hx⟩ := by
  subst hT <;> exact Set.Union_lift_of_mem x hx
#align subalgebra.supr_lift_of_mem Subalgebra.supr_lift_of_mem

end SuprLift

/-! ## Actions by `subalgebra`s

These are just copies of the definitions about `subsemiring` starting from
`subring.mul_action`.
-/


section Actions

variable {α β : Type _}

/-- The action by a subalgebra is the action by the underlying algebra. -/
instance [HasSmul A α] (S : Subalgebra R A) : HasSmul S α :=
  S.toSubsemiring.HasSmul

theorem smul_def [HasSmul A α] {S : Subalgebra R A} (g : S) (m : α) : g • m = (g : A) • m :=
  rfl
#align subalgebra.smul_def Subalgebra.smul_def

instance smul_comm_class_left [HasSmul A β] [HasSmul α β] [SmulCommClass A α β] (S : Subalgebra R A) :
    SmulCommClass S α β :=
  S.toSubsemiring.smul_comm_class_left
#align subalgebra.smul_comm_class_left Subalgebra.smul_comm_class_left

instance smul_comm_class_right [HasSmul α β] [HasSmul A β] [SmulCommClass α A β] (S : Subalgebra R A) :
    SmulCommClass α S β :=
  S.toSubsemiring.smul_comm_class_right
#align subalgebra.smul_comm_class_right Subalgebra.smul_comm_class_right

/-- Note that this provides `is_scalar_tower S R R` which is needed by `smul_mul_assoc`. -/
instance is_scalar_tower_left [HasSmul α β] [HasSmul A α] [HasSmul A β] [IsScalarTower A α β] (S : Subalgebra R A) :
    IsScalarTower S α β :=
  S.toSubsemiring.IsScalarTower
#align subalgebra.is_scalar_tower_left Subalgebra.is_scalar_tower_left

instance is_scalar_tower_mid {R S T : Type _} [CommSemiring R] [Semiring S] [AddCommMonoid T] [Algebra R S] [Module R T]
    [Module S T] [IsScalarTower R S T] (S' : Subalgebra R S) : IsScalarTower R S' T :=
  ⟨fun x y z => (smul_assoc _ (y : S) _ : _)⟩
#align subalgebra.is_scalar_tower_mid Subalgebra.is_scalar_tower_mid

instance [HasSmul A α] [HasFaithfulSmul A α] (S : Subalgebra R A) : HasFaithfulSmul S α :=
  S.toSubsemiring.HasFaithfulSmul

/-- The action by a subalgebra is the action by the underlying algebra. -/
instance [MulAction A α] (S : Subalgebra R A) : MulAction S α :=
  S.toSubsemiring.MulAction

/-- The action by a subalgebra is the action by the underlying algebra. -/
instance [AddMonoid α] [DistribMulAction A α] (S : Subalgebra R A) : DistribMulAction S α :=
  S.toSubsemiring.DistribMulAction

/-- The action by a subalgebra is the action by the underlying algebra. -/
instance [Zero α] [SmulWithZero A α] (S : Subalgebra R A) : SmulWithZero S α :=
  S.toSubsemiring.SmulWithZero

/-- The action by a subalgebra is the action by the underlying algebra. -/
instance [Zero α] [MulActionWithZero A α] (S : Subalgebra R A) : MulActionWithZero S α :=
  S.toSubsemiring.MulActionWithZero

/-- The action by a subalgebra is the action by the underlying algebra. -/
instance moduleLeft [AddCommMonoid α] [Module A α] (S : Subalgebra R A) : Module S α :=
  S.toSubsemiring.Module
#align subalgebra.module_left Subalgebra.moduleLeft

/-- The action by a subalgebra is the action by the underlying algebra. -/
instance toAlgebra {R A : Type _} [CommSemiring R] [CommSemiring A] [Semiring α] [Algebra R A] [Algebra A α]
    (S : Subalgebra R A) : Algebra S α :=
  Algebra.ofSubsemiring S.toSubsemiring
#align subalgebra.to_algebra Subalgebra.toAlgebra

theorem algebra_map_eq {R A : Type _} [CommSemiring R] [CommSemiring A] [Semiring α] [Algebra R A] [Algebra A α]
    (S : Subalgebra R A) : algebraMap S α = (algebraMap A α).comp S.val :=
  rfl
#align subalgebra.algebra_map_eq Subalgebra.algebra_map_eq

@[simp]
theorem srange_algebra_map {R A : Type _} [CommSemiring R] [CommSemiring A] [Algebra R A] (S : Subalgebra R A) :
    (algebraMap S A).srange = S.toSubsemiring := by
  rw [algebra_map_eq, Algebra.id.map_eq_id, RingHom.id_comp, ← to_subsemiring_subtype, Subsemiring.srange_subtype]
#align subalgebra.srange_algebra_map Subalgebra.srange_algebra_map

@[simp]
theorem range_algebra_map {R A : Type _} [CommRing R] [CommRing A] [Algebra R A] (S : Subalgebra R A) :
    (algebraMap S A).range = S.toSubring := by
  rw [algebra_map_eq, Algebra.id.map_eq_id, RingHom.id_comp, ← to_subring_subtype, Subring.range_subtype]
#align subalgebra.range_algebra_map Subalgebra.range_algebra_map

instance no_zero_smul_divisors_top [NoZeroDivisors A] (S : Subalgebra R A) : NoZeroSmulDivisors S A :=
  ⟨fun c x h =>
    have : (c : A) = 0 ∨ x = 0 := eq_zero_or_eq_zero_of_mul_eq_zero h
    this.imp_left (@Subtype.ext_iff _ _ c 0).mpr⟩
#align subalgebra.no_zero_smul_divisors_top Subalgebra.no_zero_smul_divisors_top

end Actions

section Center

theorem _root_.set.algebra_map_mem_center (r : R) : algebraMap R A r ∈ Set.center A := by
  simp [Algebra.commutes, Set.mem_center_iff]
#align subalgebra._root_.set.algebra_map_mem_center subalgebra._root_.set.algebra_map_mem_center

variable (R A)

/-- The center of an algebra is the set of elements which commute with every element. They form a
subalgebra. -/
def center : Subalgebra R A :=
  { Subsemiring.center A with algebra_map_mem' := Set.algebra_map_mem_center }
#align subalgebra.center Subalgebra.center

theorem coe_center : (center R A : Set A) = Set.center A :=
  rfl
#align subalgebra.coe_center Subalgebra.coe_center

@[simp]
theorem center_to_subsemiring : (center R A).toSubsemiring = Subsemiring.center A :=
  rfl
#align subalgebra.center_to_subsemiring Subalgebra.center_to_subsemiring

@[simp]
theorem center_to_subring (R A : Type _) [CommRing R] [Ring A] [Algebra R A] :
    (center R A).toSubring = Subring.center A :=
  rfl
#align subalgebra.center_to_subring Subalgebra.center_to_subring

@[simp]
theorem center_eq_top (A : Type _) [CommSemiring A] [Algebra R A] : center R A = ⊤ :=
  SetLike.coe_injective (Set.center_eq_univ A)
#align subalgebra.center_eq_top Subalgebra.center_eq_top

variable {R A}

instance : CommSemiring (center R A) :=
  Subsemiring.center.commSemiring

instance {A : Type _} [Ring A] [Algebra R A] : CommRing (center R A) :=
  Subring.center.commRing

theorem mem_center_iff {a : A} : a ∈ center R A ↔ ∀ b : A, b * a = a * b :=
  Iff.rfl
#align subalgebra.mem_center_iff Subalgebra.mem_center_iff

end Center

section Centralizer

@[simp]
theorem _root_.set.algebra_map_mem_centralizer {s : Set A} (r : R) : algebraMap R A r ∈ s.centralizer := fun a h =>
  (Algebra.commutes _ _).symm
#align subalgebra._root_.set.algebra_map_mem_centralizer subalgebra._root_.set.algebra_map_mem_centralizer

variable (R)

/-- The centralizer of a set as a subalgebra. -/
def centralizer (s : Set A) : Subalgebra R A :=
  { Subsemiring.centralizer s with algebra_map_mem' := Set.algebra_map_mem_centralizer }
#align subalgebra.centralizer Subalgebra.centralizer

@[simp, norm_cast]
theorem coe_centralizer (s : Set A) : (centralizer R s : Set A) = s.centralizer :=
  rfl
#align subalgebra.coe_centralizer Subalgebra.coe_centralizer

theorem mem_centralizer_iff {s : Set A} {z : A} : z ∈ centralizer R s ↔ ∀ g ∈ s, g * z = z * g :=
  Iff.rfl
#align subalgebra.mem_centralizer_iff Subalgebra.mem_centralizer_iff

theorem centralizer_le (s t : Set A) (h : s ⊆ t) : centralizer R t ≤ centralizer R s :=
  Set.centralizer_subset h
#align subalgebra.centralizer_le Subalgebra.centralizer_le

@[simp]
theorem centralizer_univ : centralizer R Set.univ = center R A :=
  SetLike.ext' (Set.centralizer_univ A)
#align subalgebra.centralizer_univ Subalgebra.centralizer_univ

end Centralizer

/-- Suppose we are given `∑ i, lᵢ * sᵢ = 1` in `S`, and `S'` a subalgebra of `S` that contains
`lᵢ` and `sᵢ`. To check that an `x : S` falls in `S'`, we only need to show that
`r ^ n • x ∈ M'` for some `n` for each `r : s`. -/
theorem mem_of_finset_sum_eq_one_of_pow_smul_mem {S : Type _} [CommRing S] [Algebra R S] (S' : Subalgebra R S)
    {ι : Type _} (ι' : Finset ι) (s : ι → S) (l : ι → S) (e : (∑ i in ι', l i * s i) = 1) (hs : ∀ i, s i ∈ S')
    (hl : ∀ i, l i ∈ S') (x : S) (H : ∀ i, ∃ n : ℕ, (s i ^ n : S) • x ∈ S') : x ∈ S' := by
  classical suffices : x ∈ (Algebra.ofId S' S).range.toSubmodule
    choose n hn using H
    have : Ideal.span (s' '' ι') = ⊤
    let N := ι'.sup n
    apply (Algebra.ofId S' S).range.toSubmodule.mem_of_span_top_of_smul_mem _ hs'
    change s i ^ N • x ∈ _
    refine' Submodule.smul_mem _ (⟨_, pow_mem (hs i) _⟩ : S') _
#align subalgebra.mem_of_finset_sum_eq_one_of_pow_smul_mem Subalgebra.mem_of_finset_sum_eq_one_of_pow_smul_mem

theorem mem_of_span_eq_top_of_smul_pow_mem {S : Type _} [CommRing S] [Algebra R S] (S' : Subalgebra R S) (s : Set S)
    (l : s →₀ S) (hs : Finsupp.total s S S coe l = 1) (hs' : s ⊆ S') (hl : ∀ i, l i ∈ S') (x : S)
    (H : ∀ r : s, ∃ n : ℕ, (r ^ n : S) • x ∈ S') : x ∈ S' :=
  mem_of_finset_sum_eq_one_of_pow_smul_mem S' l.support coe l hs (fun x => hs' x.2) hl x H
#align subalgebra.mem_of_span_eq_top_of_smul_pow_mem Subalgebra.mem_of_span_eq_top_of_smul_pow_mem

end Subalgebra

section Nat

variable {R : Type _} [Semiring R]

/-- A subsemiring is a `ℕ`-subalgebra. -/
def subalgebraOfSubsemiring (S : Subsemiring R) : Subalgebra ℕ R :=
  { S with algebra_map_mem' := fun i => coe_nat_mem S i }
#align subalgebra_of_subsemiring subalgebraOfSubsemiring

@[simp]
theorem mem_subalgebra_of_subsemiring {x : R} {S : Subsemiring R} : x ∈ subalgebraOfSubsemiring S ↔ x ∈ S :=
  Iff.rfl
#align mem_subalgebra_of_subsemiring mem_subalgebra_of_subsemiring

end Nat

section Int

variable {R : Type _} [Ring R]

/-- A subring is a `ℤ`-subalgebra. -/
def subalgebraOfSubring (S : Subring R) : Subalgebra ℤ R :=
  { S with
    algebra_map_mem' := fun i =>
      Int.induction_on i (by simpa using S.zero_mem) (fun i ih => by simpa using S.add_mem ih S.one_mem) fun i ih =>
        show ((-i - 1 : ℤ) : R) ∈ S by
          rw [Int.cast_sub, Int.cast_one]
          exact S.sub_mem ih S.one_mem }
#align subalgebra_of_subring subalgebraOfSubring

variable {S : Type _} [Semiring S]

@[simp]
theorem mem_subalgebra_of_subring {x : R} {S : Subring R} : x ∈ subalgebraOfSubring S ↔ x ∈ S :=
  Iff.rfl
#align mem_subalgebra_of_subring mem_subalgebra_of_subring

end Int

