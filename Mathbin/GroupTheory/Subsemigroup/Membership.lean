/-
Copyright (c) 2022 Jireh Loreaux. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jireh Loreaux

! This file was ported from Lean 3 source module group_theory.subsemigroup.membership
! leanprover-community/mathlib commit 8631e2d5ea77f6c13054d9151d82b83069680cb1
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.Subsemigroup.Basic

/-!
# Subsemigroups: membership criteria

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove various facts about membership in a subsemigroup.
The intent is to mimic `group_theory/submonoid/membership`, but currently this file is mostly a
stub and only provides rudimentary support.

* `mem_supr_of_directed`, `coe_supr_of_directed`, `mem_Sup_of_directed_on`,
  `coe_Sup_of_directed_on`: the supremum of a directed collection of subsemigroup is their union.

## TODO

* Define the `free_semigroup` generated by a set. This might require some rather substantial
  additions to low-level API. For example, developing the subtype of nonempty lists, then defining
  a product on nonempty lists, powers where the exponent is a positive natural, et cetera.
  Another option would be to define the `free_semigroup` as the subsemigroup (pushed to be a
  semigroup) of the `free_monoid` consisting of non-identity elements.

## Tags
subsemigroup
-/


variable {ι : Sort _} {M A B : Type _}

section NonAssoc

variable [Mul M]

open Set

namespace Subsemigroup

/- warning: subsemigroup.mem_supr_of_directed -> Subsemigroup.mem_supᵢ_of_directed is a dubious translation:
lean 3 declaration is
  forall {ι : Sort.{u1}} {M : Type.{u2}} [_inst_1 : Mul.{u2} M] {S : ι -> (Subsemigroup.{u2} M _inst_1)}, (Directed.{u2, u1} (Subsemigroup.{u2} M _inst_1) ι (LE.le.{u2} (Subsemigroup.{u2} M _inst_1) (Preorder.toLE.{u2} (Subsemigroup.{u2} M _inst_1) (PartialOrder.toPreorder.{u2} (Subsemigroup.{u2} M _inst_1) (SetLike.partialOrder.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.setLike.{u2} M _inst_1))))) S) -> (forall {x : M}, Iff (Membership.Mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.hasMem.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.setLike.{u2} M _inst_1)) x (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteSemilatticeSup.toHasSup.{u2} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toCompleteSemilatticeSup.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.completeLattice.{u2} M _inst_1))) ι (fun (i : ι) => S i))) (Exists.{u1} ι (fun (i : ι) => Membership.Mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.hasMem.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.setLike.{u2} M _inst_1)) x (S i))))
but is expected to have type
  forall {ι : Sort.{u1}} {M : Type.{u2}} [_inst_1 : Mul.{u2} M] {S : ι -> (Subsemigroup.{u2} M _inst_1)}, (Directed.{u2, u1} (Subsemigroup.{u2} M _inst_1) ι (fun (x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.40 : Subsemigroup.{u2} M _inst_1) (x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.42 : Subsemigroup.{u2} M _inst_1) => LE.le.{u2} (Subsemigroup.{u2} M _inst_1) (Preorder.toLE.{u2} (Subsemigroup.{u2} M _inst_1) (PartialOrder.toPreorder.{u2} (Subsemigroup.{u2} M _inst_1) (CompleteSemilatticeInf.toPartialOrder.{u2} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toCompleteSemilatticeInf.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u2} M _inst_1))))) x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.40 x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.42) S) -> (forall {x : M}, Iff (Membership.mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.instMembership.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u2} M _inst_1)) x (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toSupSet.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u2} M _inst_1)) ι (fun (i : ι) => S i))) (Exists.{u1} ι (fun (i : ι) => Membership.mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.instMembership.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u2} M _inst_1)) x (S i))))
Case conversion may be inaccurate. Consider using '#align subsemigroup.mem_supr_of_directed Subsemigroup.mem_supᵢ_of_directedₓ'. -/
-- TODO: this section can be generalized to `[mul_mem_class B M] [complete_lattice B]`
-- such that `complete_lattice.le` coincides with `set_like.le`
@[to_additive]
theorem mem_supᵢ_of_directed {S : ι → Subsemigroup M} (hS : Directed (· ≤ ·) S) {x : M} :
    (x ∈ ⨆ i, S i) ↔ ∃ i, x ∈ S i :=
  by
  refine' ⟨_, fun ⟨i, hi⟩ => (SetLike.le_def.1 <| le_supᵢ S i) hi⟩
  suffices x ∈ closure (⋃ i, (S i : Set M)) → ∃ i, x ∈ S i by
    simpa only [closure_Union, closure_eq (S _)] using this
  refine' fun hx => closure_induction hx (fun y hy => mem_Union.mp hy) _
  · rintro x y ⟨i, hi⟩ ⟨j, hj⟩
    rcases hS i j with ⟨k, hki, hkj⟩
    exact ⟨k, (S k).mul_mem (hki hi) (hkj hj)⟩
#align subsemigroup.mem_supr_of_directed Subsemigroup.mem_supᵢ_of_directed
#align add_subsemigroup.mem_supr_of_directed AddSubsemigroup.mem_supᵢ_of_directed

/- warning: subsemigroup.coe_supr_of_directed -> Subsemigroup.coe_supᵢ_of_directed is a dubious translation:
lean 3 declaration is
  forall {ι : Sort.{u1}} {M : Type.{u2}} [_inst_1 : Mul.{u2} M] {S : ι -> (Subsemigroup.{u2} M _inst_1)}, (Directed.{u2, u1} (Subsemigroup.{u2} M _inst_1) ι (LE.le.{u2} (Subsemigroup.{u2} M _inst_1) (Preorder.toLE.{u2} (Subsemigroup.{u2} M _inst_1) (PartialOrder.toPreorder.{u2} (Subsemigroup.{u2} M _inst_1) (SetLike.partialOrder.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.setLike.{u2} M _inst_1))))) S) -> (Eq.{succ u2} (Set.{u2} M) ((fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (Subsemigroup.{u2} M _inst_1) (Set.{u2} M) (HasLiftT.mk.{succ u2, succ u2} (Subsemigroup.{u2} M _inst_1) (Set.{u2} M) (CoeTCₓ.coe.{succ u2, succ u2} (Subsemigroup.{u2} M _inst_1) (Set.{u2} M) (SetLike.Set.hasCoeT.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.setLike.{u2} M _inst_1)))) (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteSemilatticeSup.toHasSup.{u2} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toCompleteSemilatticeSup.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.completeLattice.{u2} M _inst_1))) ι (fun (i : ι) => S i))) (Set.unionᵢ.{u2, u1} M ι (fun (i : ι) => (fun (a : Type.{u2}) (b : Type.{u2}) [self : HasLiftT.{succ u2, succ u2} a b] => self.0) (Subsemigroup.{u2} M _inst_1) (Set.{u2} M) (HasLiftT.mk.{succ u2, succ u2} (Subsemigroup.{u2} M _inst_1) (Set.{u2} M) (CoeTCₓ.coe.{succ u2, succ u2} (Subsemigroup.{u2} M _inst_1) (Set.{u2} M) (SetLike.Set.hasCoeT.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.setLike.{u2} M _inst_1)))) (S i))))
but is expected to have type
  forall {ι : Sort.{u1}} {M : Type.{u2}} [_inst_1 : Mul.{u2} M] {S : ι -> (Subsemigroup.{u2} M _inst_1)}, (Directed.{u2, u1} (Subsemigroup.{u2} M _inst_1) ι (fun (x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.267 : Subsemigroup.{u2} M _inst_1) (x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.269 : Subsemigroup.{u2} M _inst_1) => LE.le.{u2} (Subsemigroup.{u2} M _inst_1) (Preorder.toLE.{u2} (Subsemigroup.{u2} M _inst_1) (PartialOrder.toPreorder.{u2} (Subsemigroup.{u2} M _inst_1) (CompleteSemilatticeInf.toPartialOrder.{u2} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toCompleteSemilatticeInf.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u2} M _inst_1))))) x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.267 x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.269) S) -> (Eq.{succ u2} (Set.{u2} M) (SetLike.coe.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u2} M _inst_1) (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toSupSet.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u2} M _inst_1)) ι (fun (i : ι) => S i))) (Set.unionᵢ.{u2, u1} M ι (fun (i : ι) => SetLike.coe.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u2} M _inst_1) (S i))))
Case conversion may be inaccurate. Consider using '#align subsemigroup.coe_supr_of_directed Subsemigroup.coe_supᵢ_of_directedₓ'. -/
@[to_additive]
theorem coe_supᵢ_of_directed {S : ι → Subsemigroup M} (hS : Directed (· ≤ ·) S) :
    ((⨆ i, S i : Subsemigroup M) : Set M) = ⋃ i, ↑(S i) :=
  Set.ext fun x => by simp [mem_supr_of_directed hS]
#align subsemigroup.coe_supr_of_directed Subsemigroup.coe_supᵢ_of_directed
#align add_subsemigroup.coe_supr_of_directed AddSubsemigroup.coe_supᵢ_of_directed

/- warning: subsemigroup.mem_Sup_of_directed_on -> Subsemigroup.mem_supₛ_of_directed_on is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u1}} [_inst_1 : Mul.{u1} M] {S : Set.{u1} (Subsemigroup.{u1} M _inst_1)}, (DirectedOn.{u1} (Subsemigroup.{u1} M _inst_1) (LE.le.{u1} (Subsemigroup.{u1} M _inst_1) (Preorder.toLE.{u1} (Subsemigroup.{u1} M _inst_1) (PartialOrder.toPreorder.{u1} (Subsemigroup.{u1} M _inst_1) (SetLike.partialOrder.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.setLike.{u1} M _inst_1))))) S) -> (forall {x : M}, Iff (Membership.Mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.hasMem.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.setLike.{u1} M _inst_1)) x (SupSet.supₛ.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteSemilatticeSup.toHasSup.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteLattice.toCompleteSemilatticeSup.{u1} (Subsemigroup.{u1} M _inst_1) (Subsemigroup.completeLattice.{u1} M _inst_1))) S)) (Exists.{succ u1} (Subsemigroup.{u1} M _inst_1) (fun (s : Subsemigroup.{u1} M _inst_1) => Exists.{0} (Membership.Mem.{u1, u1} (Subsemigroup.{u1} M _inst_1) (Set.{u1} (Subsemigroup.{u1} M _inst_1)) (Set.hasMem.{u1} (Subsemigroup.{u1} M _inst_1)) s S) (fun (H : Membership.Mem.{u1, u1} (Subsemigroup.{u1} M _inst_1) (Set.{u1} (Subsemigroup.{u1} M _inst_1)) (Set.hasMem.{u1} (Subsemigroup.{u1} M _inst_1)) s S) => Membership.Mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.hasMem.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.setLike.{u1} M _inst_1)) x s))))
but is expected to have type
  forall {M : Type.{u1}} [_inst_1 : Mul.{u1} M] {S : Set.{u1} (Subsemigroup.{u1} M _inst_1)}, (DirectedOn.{u1} (Subsemigroup.{u1} M _inst_1) (fun (x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.361 : Subsemigroup.{u1} M _inst_1) (x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.363 : Subsemigroup.{u1} M _inst_1) => LE.le.{u1} (Subsemigroup.{u1} M _inst_1) (Preorder.toLE.{u1} (Subsemigroup.{u1} M _inst_1) (PartialOrder.toPreorder.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subsemigroup.{u1} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u1} M _inst_1))))) x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.361 x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.363) S) -> (forall {x : M}, Iff (Membership.mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.instMembership.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u1} M _inst_1)) x (SupSet.supₛ.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteLattice.toSupSet.{u1} (Subsemigroup.{u1} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u1} M _inst_1)) S)) (Exists.{succ u1} (Subsemigroup.{u1} M _inst_1) (fun (s : Subsemigroup.{u1} M _inst_1) => And (Membership.mem.{u1, u1} (Subsemigroup.{u1} M _inst_1) (Set.{u1} (Subsemigroup.{u1} M _inst_1)) (Set.instMembershipSet.{u1} (Subsemigroup.{u1} M _inst_1)) s S) (Membership.mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.instMembership.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u1} M _inst_1)) x s))))
Case conversion may be inaccurate. Consider using '#align subsemigroup.mem_Sup_of_directed_on Subsemigroup.mem_supₛ_of_directed_onₓ'. -/
@[to_additive]
theorem mem_supₛ_of_directed_on {S : Set (Subsemigroup M)} (hS : DirectedOn (· ≤ ·) S) {x : M} :
    x ∈ supₛ S ↔ ∃ s ∈ S, x ∈ s := by
  simp only [supₛ_eq_supᵢ', mem_supr_of_directed hS.directed_coe, SetCoe.exists, Subtype.coe_mk]
#align subsemigroup.mem_Sup_of_directed_on Subsemigroup.mem_supₛ_of_directed_on
#align add_subsemigroup.mem_Sup_of_directed_on AddSubsemigroup.mem_supₛ_of_directed_on

/- warning: subsemigroup.coe_Sup_of_directed_on -> Subsemigroup.coe_supₛ_of_directed_on is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u1}} [_inst_1 : Mul.{u1} M] {S : Set.{u1} (Subsemigroup.{u1} M _inst_1)}, (DirectedOn.{u1} (Subsemigroup.{u1} M _inst_1) (LE.le.{u1} (Subsemigroup.{u1} M _inst_1) (Preorder.toLE.{u1} (Subsemigroup.{u1} M _inst_1) (PartialOrder.toPreorder.{u1} (Subsemigroup.{u1} M _inst_1) (SetLike.partialOrder.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.setLike.{u1} M _inst_1))))) S) -> (Eq.{succ u1} (Set.{u1} M) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemigroup.{u1} M _inst_1) (Set.{u1} M) (HasLiftT.mk.{succ u1, succ u1} (Subsemigroup.{u1} M _inst_1) (Set.{u1} M) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemigroup.{u1} M _inst_1) (Set.{u1} M) (SetLike.Set.hasCoeT.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.setLike.{u1} M _inst_1)))) (SupSet.supₛ.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteSemilatticeSup.toHasSup.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteLattice.toCompleteSemilatticeSup.{u1} (Subsemigroup.{u1} M _inst_1) (Subsemigroup.completeLattice.{u1} M _inst_1))) S)) (Set.unionᵢ.{u1, succ u1} M (Subsemigroup.{u1} M _inst_1) (fun (s : Subsemigroup.{u1} M _inst_1) => Set.unionᵢ.{u1, 0} M (Membership.Mem.{u1, u1} (Subsemigroup.{u1} M _inst_1) (Set.{u1} (Subsemigroup.{u1} M _inst_1)) (Set.hasMem.{u1} (Subsemigroup.{u1} M _inst_1)) s S) (fun (H : Membership.Mem.{u1, u1} (Subsemigroup.{u1} M _inst_1) (Set.{u1} (Subsemigroup.{u1} M _inst_1)) (Set.hasMem.{u1} (Subsemigroup.{u1} M _inst_1)) s S) => (fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subsemigroup.{u1} M _inst_1) (Set.{u1} M) (HasLiftT.mk.{succ u1, succ u1} (Subsemigroup.{u1} M _inst_1) (Set.{u1} M) (CoeTCₓ.coe.{succ u1, succ u1} (Subsemigroup.{u1} M _inst_1) (Set.{u1} M) (SetLike.Set.hasCoeT.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.setLike.{u1} M _inst_1)))) s))))
but is expected to have type
  forall {M : Type.{u1}} [_inst_1 : Mul.{u1} M] {S : Set.{u1} (Subsemigroup.{u1} M _inst_1)}, (DirectedOn.{u1} (Subsemigroup.{u1} M _inst_1) (fun (x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.432 : Subsemigroup.{u1} M _inst_1) (x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.434 : Subsemigroup.{u1} M _inst_1) => LE.le.{u1} (Subsemigroup.{u1} M _inst_1) (Preorder.toLE.{u1} (Subsemigroup.{u1} M _inst_1) (PartialOrder.toPreorder.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteSemilatticeInf.toPartialOrder.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Subsemigroup.{u1} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u1} M _inst_1))))) x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.432 x._@.Mathlib.GroupTheory.Subsemigroup.Membership._hyg.434) S) -> (Eq.{succ u1} (Set.{u1} M) (SetLike.coe.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u1} M _inst_1) (SupSet.supₛ.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteLattice.toSupSet.{u1} (Subsemigroup.{u1} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u1} M _inst_1)) S)) (Set.unionᵢ.{u1, succ u1} M (Subsemigroup.{u1} M _inst_1) (fun (s : Subsemigroup.{u1} M _inst_1) => Set.unionᵢ.{u1, 0} M (Membership.mem.{u1, u1} (Subsemigroup.{u1} M _inst_1) (Set.{u1} (Subsemigroup.{u1} M _inst_1)) (Set.instMembershipSet.{u1} (Subsemigroup.{u1} M _inst_1)) s S) (fun (H : Membership.mem.{u1, u1} (Subsemigroup.{u1} M _inst_1) (Set.{u1} (Subsemigroup.{u1} M _inst_1)) (Set.instMembershipSet.{u1} (Subsemigroup.{u1} M _inst_1)) s S) => SetLike.coe.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u1} M _inst_1) s))))
Case conversion may be inaccurate. Consider using '#align subsemigroup.coe_Sup_of_directed_on Subsemigroup.coe_supₛ_of_directed_onₓ'. -/
@[to_additive]
theorem coe_supₛ_of_directed_on {S : Set (Subsemigroup M)} (hS : DirectedOn (· ≤ ·) S) :
    (↑(supₛ S) : Set M) = ⋃ s ∈ S, ↑s :=
  Set.ext fun x => by simp [mem_Sup_of_directed_on hS]
#align subsemigroup.coe_Sup_of_directed_on Subsemigroup.coe_supₛ_of_directed_on
#align add_subsemigroup.coe_Sup_of_directed_on AddSubsemigroup.coe_supₛ_of_directed_on

/- warning: subsemigroup.mem_sup_left -> Subsemigroup.mem_sup_left is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u1}} [_inst_1 : Mul.{u1} M] {S : Subsemigroup.{u1} M _inst_1} {T : Subsemigroup.{u1} M _inst_1} {x : M}, (Membership.Mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.hasMem.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.setLike.{u1} M _inst_1)) x S) -> (Membership.Mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.hasMem.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.setLike.{u1} M _inst_1)) x (HasSup.sup.{u1} (Subsemigroup.{u1} M _inst_1) (SemilatticeSup.toHasSup.{u1} (Subsemigroup.{u1} M _inst_1) (Lattice.toSemilatticeSup.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteLattice.toLattice.{u1} (Subsemigroup.{u1} M _inst_1) (Subsemigroup.completeLattice.{u1} M _inst_1)))) S T))
but is expected to have type
  forall {M : Type.{u1}} [_inst_1 : Mul.{u1} M] {S : Subsemigroup.{u1} M _inst_1} {T : Subsemigroup.{u1} M _inst_1} {x : M}, (Membership.mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.instMembership.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u1} M _inst_1)) x S) -> (Membership.mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.instMembership.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u1} M _inst_1)) x (HasSup.sup.{u1} (Subsemigroup.{u1} M _inst_1) (SemilatticeSup.toHasSup.{u1} (Subsemigroup.{u1} M _inst_1) (Lattice.toSemilatticeSup.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteLattice.toLattice.{u1} (Subsemigroup.{u1} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u1} M _inst_1)))) S T))
Case conversion may be inaccurate. Consider using '#align subsemigroup.mem_sup_left Subsemigroup.mem_sup_leftₓ'. -/
@[to_additive]
theorem mem_sup_left {S T : Subsemigroup M} : ∀ {x : M}, x ∈ S → x ∈ S ⊔ T :=
  show S ≤ S ⊔ T from le_sup_left
#align subsemigroup.mem_sup_left Subsemigroup.mem_sup_left
#align add_subsemigroup.mem_sup_left AddSubsemigroup.mem_sup_left

/- warning: subsemigroup.mem_sup_right -> Subsemigroup.mem_sup_right is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u1}} [_inst_1 : Mul.{u1} M] {S : Subsemigroup.{u1} M _inst_1} {T : Subsemigroup.{u1} M _inst_1} {x : M}, (Membership.Mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.hasMem.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.setLike.{u1} M _inst_1)) x T) -> (Membership.Mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.hasMem.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.setLike.{u1} M _inst_1)) x (HasSup.sup.{u1} (Subsemigroup.{u1} M _inst_1) (SemilatticeSup.toHasSup.{u1} (Subsemigroup.{u1} M _inst_1) (Lattice.toSemilatticeSup.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteLattice.toLattice.{u1} (Subsemigroup.{u1} M _inst_1) (Subsemigroup.completeLattice.{u1} M _inst_1)))) S T))
but is expected to have type
  forall {M : Type.{u1}} [_inst_1 : Mul.{u1} M] {S : Subsemigroup.{u1} M _inst_1} {T : Subsemigroup.{u1} M _inst_1} {x : M}, (Membership.mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.instMembership.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u1} M _inst_1)) x T) -> (Membership.mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.instMembership.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u1} M _inst_1)) x (HasSup.sup.{u1} (Subsemigroup.{u1} M _inst_1) (SemilatticeSup.toHasSup.{u1} (Subsemigroup.{u1} M _inst_1) (Lattice.toSemilatticeSup.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteLattice.toLattice.{u1} (Subsemigroup.{u1} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u1} M _inst_1)))) S T))
Case conversion may be inaccurate. Consider using '#align subsemigroup.mem_sup_right Subsemigroup.mem_sup_rightₓ'. -/
@[to_additive]
theorem mem_sup_right {S T : Subsemigroup M} : ∀ {x : M}, x ∈ T → x ∈ S ⊔ T :=
  show T ≤ S ⊔ T from le_sup_right
#align subsemigroup.mem_sup_right Subsemigroup.mem_sup_right
#align add_subsemigroup.mem_sup_right AddSubsemigroup.mem_sup_right

/- warning: subsemigroup.mul_mem_sup -> Subsemigroup.mul_mem_sup is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u1}} [_inst_1 : Mul.{u1} M] {S : Subsemigroup.{u1} M _inst_1} {T : Subsemigroup.{u1} M _inst_1} {x : M} {y : M}, (Membership.Mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.hasMem.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.setLike.{u1} M _inst_1)) x S) -> (Membership.Mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.hasMem.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.setLike.{u1} M _inst_1)) y T) -> (Membership.Mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.hasMem.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.setLike.{u1} M _inst_1)) (HMul.hMul.{u1, u1, u1} M M M (instHMul.{u1} M _inst_1) x y) (HasSup.sup.{u1} (Subsemigroup.{u1} M _inst_1) (SemilatticeSup.toHasSup.{u1} (Subsemigroup.{u1} M _inst_1) (Lattice.toSemilatticeSup.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteLattice.toLattice.{u1} (Subsemigroup.{u1} M _inst_1) (Subsemigroup.completeLattice.{u1} M _inst_1)))) S T))
but is expected to have type
  forall {M : Type.{u1}} [_inst_1 : Mul.{u1} M] {S : Subsemigroup.{u1} M _inst_1} {T : Subsemigroup.{u1} M _inst_1} {x : M} {y : M}, (Membership.mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.instMembership.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u1} M _inst_1)) x S) -> (Membership.mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.instMembership.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u1} M _inst_1)) y T) -> (Membership.mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.instMembership.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u1} M _inst_1)) (HMul.hMul.{u1, u1, u1} M M M (instHMul.{u1} M _inst_1) x y) (HasSup.sup.{u1} (Subsemigroup.{u1} M _inst_1) (SemilatticeSup.toHasSup.{u1} (Subsemigroup.{u1} M _inst_1) (Lattice.toSemilatticeSup.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteLattice.toLattice.{u1} (Subsemigroup.{u1} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u1} M _inst_1)))) S T))
Case conversion may be inaccurate. Consider using '#align subsemigroup.mul_mem_sup Subsemigroup.mul_mem_supₓ'. -/
@[to_additive]
theorem mul_mem_sup {S T : Subsemigroup M} {x y : M} (hx : x ∈ S) (hy : y ∈ T) : x * y ∈ S ⊔ T :=
  mul_mem (mem_sup_left hx) (mem_sup_right hy)
#align subsemigroup.mul_mem_sup Subsemigroup.mul_mem_sup
#align add_subsemigroup.add_mem_sup AddSubsemigroup.add_mem_sup

/- warning: subsemigroup.mem_supr_of_mem -> Subsemigroup.mem_supᵢ_of_mem is a dubious translation:
lean 3 declaration is
  forall {ι : Sort.{u1}} {M : Type.{u2}} [_inst_1 : Mul.{u2} M] {S : ι -> (Subsemigroup.{u2} M _inst_1)} (i : ι) {x : M}, (Membership.Mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.hasMem.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.setLike.{u2} M _inst_1)) x (S i)) -> (Membership.Mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.hasMem.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.setLike.{u2} M _inst_1)) x (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteSemilatticeSup.toHasSup.{u2} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toCompleteSemilatticeSup.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.completeLattice.{u2} M _inst_1))) ι S))
but is expected to have type
  forall {ι : Sort.{u1}} {M : Type.{u2}} [_inst_1 : Mul.{u2} M] {S : ι -> (Subsemigroup.{u2} M _inst_1)} (i : ι) {x : M}, (Membership.mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.instMembership.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u2} M _inst_1)) x (S i)) -> (Membership.mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.instMembership.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u2} M _inst_1)) x (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toSupSet.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u2} M _inst_1)) ι S))
Case conversion may be inaccurate. Consider using '#align subsemigroup.mem_supr_of_mem Subsemigroup.mem_supᵢ_of_memₓ'. -/
@[to_additive]
theorem mem_supᵢ_of_mem {S : ι → Subsemigroup M} (i : ι) : ∀ {x : M}, x ∈ S i → x ∈ supᵢ S :=
  show S i ≤ supᵢ S from le_supᵢ _ _
#align subsemigroup.mem_supr_of_mem Subsemigroup.mem_supᵢ_of_mem
#align add_subsemigroup.mem_supr_of_mem AddSubsemigroup.mem_supᵢ_of_mem

/- warning: subsemigroup.mem_Sup_of_mem -> Subsemigroup.mem_supₛ_of_mem is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u1}} [_inst_1 : Mul.{u1} M] {S : Set.{u1} (Subsemigroup.{u1} M _inst_1)} {s : Subsemigroup.{u1} M _inst_1}, (Membership.Mem.{u1, u1} (Subsemigroup.{u1} M _inst_1) (Set.{u1} (Subsemigroup.{u1} M _inst_1)) (Set.hasMem.{u1} (Subsemigroup.{u1} M _inst_1)) s S) -> (forall {x : M}, (Membership.Mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.hasMem.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.setLike.{u1} M _inst_1)) x s) -> (Membership.Mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.hasMem.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.setLike.{u1} M _inst_1)) x (SupSet.supₛ.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteSemilatticeSup.toHasSup.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteLattice.toCompleteSemilatticeSup.{u1} (Subsemigroup.{u1} M _inst_1) (Subsemigroup.completeLattice.{u1} M _inst_1))) S)))
but is expected to have type
  forall {M : Type.{u1}} [_inst_1 : Mul.{u1} M] {S : Set.{u1} (Subsemigroup.{u1} M _inst_1)} {s : Subsemigroup.{u1} M _inst_1}, (Membership.mem.{u1, u1} (Subsemigroup.{u1} M _inst_1) (Set.{u1} (Subsemigroup.{u1} M _inst_1)) (Set.instMembershipSet.{u1} (Subsemigroup.{u1} M _inst_1)) s S) -> (forall {x : M}, (Membership.mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.instMembership.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u1} M _inst_1)) x s) -> (Membership.mem.{u1, u1} M (Subsemigroup.{u1} M _inst_1) (SetLike.instMembership.{u1, u1} (Subsemigroup.{u1} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u1} M _inst_1)) x (SupSet.supₛ.{u1} (Subsemigroup.{u1} M _inst_1) (CompleteLattice.toSupSet.{u1} (Subsemigroup.{u1} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u1} M _inst_1)) S)))
Case conversion may be inaccurate. Consider using '#align subsemigroup.mem_Sup_of_mem Subsemigroup.mem_supₛ_of_memₓ'. -/
@[to_additive]
theorem mem_supₛ_of_mem {S : Set (Subsemigroup M)} {s : Subsemigroup M} (hs : s ∈ S) :
    ∀ {x : M}, x ∈ s → x ∈ supₛ S :=
  show s ≤ supₛ S from le_supₛ hs
#align subsemigroup.mem_Sup_of_mem Subsemigroup.mem_supₛ_of_mem
#align add_subsemigroup.mem_Sup_of_mem AddSubsemigroup.mem_supₛ_of_mem

/- warning: subsemigroup.supr_induction -> Subsemigroup.supᵢ_induction is a dubious translation:
lean 3 declaration is
  forall {ι : Sort.{u1}} {M : Type.{u2}} [_inst_1 : Mul.{u2} M] (S : ι -> (Subsemigroup.{u2} M _inst_1)) {C : M -> Prop} {x : M}, (Membership.Mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.hasMem.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.setLike.{u2} M _inst_1)) x (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteSemilatticeSup.toHasSup.{u2} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toCompleteSemilatticeSup.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.completeLattice.{u2} M _inst_1))) ι (fun (i : ι) => S i))) -> (forall (i : ι) (x : M), (Membership.Mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.hasMem.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.setLike.{u2} M _inst_1)) x (S i)) -> (C x)) -> (forall (x : M) (y : M), (C x) -> (C y) -> (C (HMul.hMul.{u2, u2, u2} M M M (instHMul.{u2} M _inst_1) x y))) -> (C x)
but is expected to have type
  forall {ι : Sort.{u1}} {M : Type.{u2}} [_inst_1 : Mul.{u2} M] (S : ι -> (Subsemigroup.{u2} M _inst_1)) {C : M -> Prop} {x : M}, (Membership.mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.instMembership.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u2} M _inst_1)) x (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toSupSet.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u2} M _inst_1)) ι (fun (i : ι) => S i))) -> (forall (i : ι) (x : M), (Membership.mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.instMembership.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u2} M _inst_1)) x (S i)) -> (C x)) -> (forall (x : M) (y : M), (C x) -> (C y) -> (C (HMul.hMul.{u2, u2, u2} M M M (instHMul.{u2} M _inst_1) x y))) -> (C x)
Case conversion may be inaccurate. Consider using '#align subsemigroup.supr_induction Subsemigroup.supᵢ_inductionₓ'. -/
/-- An induction principle for elements of `⨆ i, S i`.
If `C` holds all elements of `S i` for all `i`, and is preserved under multiplication,
then it holds for all elements of the supremum of `S`. -/
@[elab_as_elim,
  to_additive
      " An induction principle for elements of `⨆ i, S i`.\nIf `C` holds all elements of `S i` for all `i`, and is preserved under addition,\nthen it holds for all elements of the supremum of `S`. "]
theorem supᵢ_induction (S : ι → Subsemigroup M) {C : M → Prop} {x : M} (hx : x ∈ ⨆ i, S i)
    (hp : ∀ (i), ∀ x ∈ S i, C x) (hmul : ∀ x y, C x → C y → C (x * y)) : C x :=
  by
  rw [supr_eq_closure] at hx
  refine' closure_induction hx (fun x hx => _) hmul
  obtain ⟨i, hi⟩ := set.mem_Union.mp hx
  exact hp _ _ hi
#align subsemigroup.supr_induction Subsemigroup.supᵢ_induction
#align add_subsemigroup.supr_induction AddSubsemigroup.supᵢ_induction

/- warning: subsemigroup.supr_induction' -> Subsemigroup.supᵢ_induction' is a dubious translation:
lean 3 declaration is
  forall {ι : Sort.{u1}} {M : Type.{u2}} [_inst_1 : Mul.{u2} M] (S : ι -> (Subsemigroup.{u2} M _inst_1)) {C : forall (x : M), (Membership.Mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.hasMem.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.setLike.{u2} M _inst_1)) x (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteSemilatticeSup.toHasSup.{u2} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toCompleteSemilatticeSup.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.completeLattice.{u2} M _inst_1))) ι (fun (i : ι) => S i))) -> Prop}, (forall (i : ι) (x : M) (H : Membership.Mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.hasMem.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.setLike.{u2} M _inst_1)) x (S i)), C x (Subsemigroup.mem_supᵢ_of_mem.{u1, u2} ι M _inst_1 (fun (i : ι) => S i) i x H)) -> (forall (x : M) (y : M) (hx : Membership.Mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.hasMem.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.setLike.{u2} M _inst_1)) x (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteSemilatticeSup.toHasSup.{u2} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toCompleteSemilatticeSup.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.completeLattice.{u2} M _inst_1))) ι (fun (i : ι) => S i))) (hy : Membership.Mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.hasMem.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.setLike.{u2} M _inst_1)) y (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteSemilatticeSup.toHasSup.{u2} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toCompleteSemilatticeSup.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.completeLattice.{u2} M _inst_1))) ι (fun (i : ι) => S i))), (C x hx) -> (C y hy) -> (C (HMul.hMul.{u2, u2, u2} M M M (instHMul.{u2} M _inst_1) x y) (MulMemClass.mul_mem.{u2, u2} (Subsemigroup.{u2} M _inst_1) M _inst_1 (Subsemigroup.setLike.{u2} M _inst_1) (Subsemigroup.mulMemClass.{u2} M _inst_1) (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteSemilatticeSup.toHasSup.{u2} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toCompleteSemilatticeSup.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.completeLattice.{u2} M _inst_1))) ι (fun (i : ι) => S i)) x y hx hy))) -> (forall {x : M} (hx : Membership.Mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.hasMem.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.setLike.{u2} M _inst_1)) x (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteSemilatticeSup.toHasSup.{u2} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toCompleteSemilatticeSup.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.completeLattice.{u2} M _inst_1))) ι (fun (i : ι) => S i))), C x hx)
but is expected to have type
  forall {ι : Sort.{u1}} {M : Type.{u2}} [_inst_1 : Mul.{u2} M] (S : ι -> (Subsemigroup.{u2} M _inst_1)) {C : forall (x : M), (Membership.mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.instMembership.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u2} M _inst_1)) x (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toSupSet.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u2} M _inst_1)) ι (fun (i : ι) => S i))) -> Prop}, (forall (i : ι) (x : M) (H : Membership.mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.instMembership.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u2} M _inst_1)) x (S i)), C x (Subsemigroup.mem_supᵢ_of_mem.{u1, u2} ι M _inst_1 (fun (i : ι) => S i) i x H)) -> (forall (x : M) (y : M) (hx : Membership.mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.instMembership.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u2} M _inst_1)) x (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toSupSet.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u2} M _inst_1)) ι (fun (i : ι) => S i))) (hy : Membership.mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.instMembership.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u2} M _inst_1)) y (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toSupSet.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u2} M _inst_1)) ι (fun (i : ι) => S i))), (C x hx) -> (C y hy) -> (C (HMul.hMul.{u2, u2, u2} M M M (instHMul.{u2} M _inst_1) x y) (MulMemClass.mul_mem.{u2, u2} (Subsemigroup.{u2} M _inst_1) M _inst_1 (Subsemigroup.instSetLikeSubsemigroup.{u2} M _inst_1) (Subsemigroup.instMulMemClassSubsemigroupInstSetLikeSubsemigroup.{u2} M _inst_1) (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toSupSet.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u2} M _inst_1)) ι (fun (i : ι) => S i)) x y hx hy))) -> (forall {x : M} (hx : Membership.mem.{u2, u2} M (Subsemigroup.{u2} M _inst_1) (SetLike.instMembership.{u2, u2} (Subsemigroup.{u2} M _inst_1) M (Subsemigroup.instSetLikeSubsemigroup.{u2} M _inst_1)) x (supᵢ.{u2, u1} (Subsemigroup.{u2} M _inst_1) (CompleteLattice.toSupSet.{u2} (Subsemigroup.{u2} M _inst_1) (Subsemigroup.instCompleteLatticeSubsemigroup.{u2} M _inst_1)) ι (fun (i : ι) => S i))), C x hx)
Case conversion may be inaccurate. Consider using '#align subsemigroup.supr_induction' Subsemigroup.supᵢ_induction'ₓ'. -/
/-- A dependent version of `subsemigroup.supr_induction`. -/
@[elab_as_elim, to_additive "A dependent version of `add_subsemigroup.supr_induction`. "]
theorem supᵢ_induction' (S : ι → Subsemigroup M) {C : ∀ x, (x ∈ ⨆ i, S i) → Prop}
    (hp : ∀ (i), ∀ x ∈ S i, C x (mem_supᵢ_of_mem i ‹_›))
    (hmul : ∀ x y hx hy, C x hx → C y hy → C (x * y) (mul_mem ‹_› ‹_›)) {x : M}
    (hx : x ∈ ⨆ i, S i) : C x hx :=
  by
  refine' Exists.elim _ fun (hx : x ∈ ⨆ i, S i) (hc : C x hx) => hc
  refine' supr_induction S hx (fun i x hx => _) fun x y => _
  · exact ⟨_, hp _ _ hx⟩
  · rintro ⟨_, Cx⟩ ⟨_, Cy⟩
    exact ⟨_, hmul _ _ _ _ Cx Cy⟩
#align subsemigroup.supr_induction' Subsemigroup.supᵢ_induction'
#align add_subsemigroup.supr_induction' AddSubsemigroup.supᵢ_induction'

end Subsemigroup

end NonAssoc

