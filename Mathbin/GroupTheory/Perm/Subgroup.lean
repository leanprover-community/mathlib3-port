/-
Copyright (c) 2020 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module group_theory.perm.subgroup
! leanprover-community/mathlib commit bd9851ca476957ea4549eb19b40e7b5ade9428cc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.Perm.Basic
import Mathbin.Data.Fintype.Perm
import Mathbin.GroupTheory.Subgroup.Finite

/-!
# Lemmas about subgroups within the permutations (self-equivalences) of a type `α`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file provides extra lemmas about some `subgroup`s that exist within `equiv.perm α`.
`group_theory.subgroup` depends on `group_theory.perm.basic`, so these need to be in a separate
file.

It also provides decidable instances on membership in these subgroups, since
`monoid_hom.decidable_mem_range` cannot be inferred without the help of a lambda.
The presence of these instances induces a `fintype` instance on the `quotient_group.quotient` of
these subgroups.
-/


namespace Equiv

namespace Perm

universe u

/- warning: equiv.perm.sum_congr_hom.decidable_mem_range -> Equiv.Perm.sumCongrHom.decidableMemRange is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : DecidableEq.{succ u1} α] [_inst_2 : DecidableEq.{succ u2} β] [_inst_3 : Fintype.{u1} α] [_inst_4 : Fintype.{u2} β], DecidablePred.{succ (max u1 u2)} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (fun (_x : Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) => Membership.Mem.{max u1 u2, max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β))) (SetLike.hasMem.{max u1 u2, max u1 u2} (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β))) (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Subgroup.setLike.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β)))) _x (MonoidHom.range.{max u1 u2, max u1 u2} (Prod.{u1, u2} (Equiv.Perm.{succ u1} α) (Equiv.Perm.{succ u2} β)) (Prod.group.{u1, u2} (Equiv.Perm.{succ u1} α) (Equiv.Perm.{succ u2} β) (Equiv.Perm.permGroup.{u1} α) (Equiv.Perm.permGroup.{u2} β)) (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β)) (Equiv.Perm.sumCongrHom.{u1, u2} α β)))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : DecidableEq.{succ u1} α] [_inst_2 : DecidableEq.{succ u2} β] [_inst_3 : Fintype.{u1} α] [_inst_4 : Fintype.{u2} β], DecidablePred.{succ (max u1 u2)} (Equiv.Perm.{max (succ u2) (succ u1)} (Sum.{u1, u2} α β)) (fun (_x : Equiv.Perm.{max (succ u2) (succ u1)} (Sum.{u1, u2} α β)) => Membership.mem.{max u1 u2, max u1 u2} (Equiv.Perm.{max (succ u2) (succ u1)} (Sum.{u1, u2} α β)) (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u2) (succ u1)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β))) (SetLike.instMembership.{max u1 u2, max u1 u2} (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u2) (succ u1)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β))) (Equiv.Perm.{max (succ u2) (succ u1)} (Sum.{u1, u2} α β)) (Subgroup.instSetLikeSubgroup.{max u1 u2} (Equiv.Perm.{max (succ u2) (succ u1)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β)))) _x (MonoidHom.range.{max u1 u2, max u1 u2} (Prod.{u1, u2} (Equiv.Perm.{succ u1} α) (Equiv.Perm.{succ u2} β)) (Prod.instGroupProd.{u1, u2} (Equiv.Perm.{succ u1} α) (Equiv.Perm.{succ u2} β) (Equiv.Perm.permGroup.{u1} α) (Equiv.Perm.permGroup.{u2} β)) (Equiv.Perm.{max (succ u2) (succ u1)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β)) (Equiv.Perm.sumCongrHom.{u1, u2} α β)))
Case conversion may be inaccurate. Consider using '#align equiv.perm.sum_congr_hom.decidable_mem_range Equiv.Perm.sumCongrHom.decidableMemRangeₓ'. -/
instance sumCongrHom.decidableMemRange {α β : Type _} [DecidableEq α] [DecidableEq β] [Fintype α]
    [Fintype β] : DecidablePred (· ∈ (sumCongrHom α β).range) := fun x => inferInstance
#align equiv.perm.sum_congr_hom.decidable_mem_range Equiv.Perm.sumCongrHom.decidableMemRange

/- warning: equiv.perm.sum_congr_hom.card_range -> Equiv.Perm.sumCongrHom.card_range is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : Fintype.{max u1 u2} (coeSort.{succ (max u1 u2), succ (succ (max u1 u2))} (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β))) Type.{max u1 u2} (SetLike.hasCoeToSort.{max u1 u2, max u1 u2} (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β))) (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Subgroup.setLike.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β)))) (MonoidHom.range.{max u1 u2, max u1 u2} (Prod.{u1, u2} (Equiv.Perm.{succ u1} α) (Equiv.Perm.{succ u2} β)) (Prod.group.{u1, u2} (Equiv.Perm.{succ u1} α) (Equiv.Perm.{succ u2} β) (Equiv.Perm.permGroup.{u1} α) (Equiv.Perm.permGroup.{u2} β)) (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β)) (Equiv.Perm.sumCongrHom.{u1, u2} α β)))] [_inst_2 : Fintype.{max u1 u2} (Prod.{u1, u2} (Equiv.Perm.{succ u1} α) (Equiv.Perm.{succ u2} β))], Eq.{1} Nat (Fintype.card.{max u1 u2} (coeSort.{succ (max u1 u2), succ (succ (max u1 u2))} (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β))) Type.{max u1 u2} (SetLike.hasCoeToSort.{max u1 u2, max u1 u2} (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β))) (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Subgroup.setLike.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β)))) (MonoidHom.range.{max u1 u2, max u1 u2} (Prod.{u1, u2} (Equiv.Perm.{succ u1} α) (Equiv.Perm.{succ u2} β)) (Prod.group.{u1, u2} (Equiv.Perm.{succ u1} α) (Equiv.Perm.{succ u2} β) (Equiv.Perm.permGroup.{u1} α) (Equiv.Perm.permGroup.{u2} β)) (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u1, u2} α β)) (Equiv.Perm.permGroup.{max u1 u2} (Sum.{u1, u2} α β)) (Equiv.Perm.sumCongrHom.{u1, u2} α β))) _inst_1) (Fintype.card.{max u1 u2} (Prod.{u1, u2} (Equiv.Perm.{succ u1} α) (Equiv.Perm.{succ u2} β)) _inst_2)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : Fintype.{max u2 u1} (Subtype.{succ (max u2 u1)} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) (fun (x : Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) => Membership.mem.{max u2 u1, max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) (Subgroup.{max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) (Equiv.Perm.permGroup.{max u2 u1} (Sum.{u2, u1} α β))) (SetLike.instMembership.{max u2 u1, max u2 u1} (Subgroup.{max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) (Equiv.Perm.permGroup.{max u2 u1} (Sum.{u2, u1} α β))) (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) (Subgroup.instSetLikeSubgroup.{max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) (Equiv.Perm.permGroup.{max u2 u1} (Sum.{u2, u1} α β)))) x (MonoidHom.range.{max u2 u1, max u2 u1} (Prod.{u2, u1} (Equiv.Perm.{succ u2} α) (Equiv.Perm.{succ u1} β)) (Prod.instGroupProd.{u2, u1} (Equiv.Perm.{succ u2} α) (Equiv.Perm.{succ u1} β) (Equiv.Perm.permGroup.{u2} α) (Equiv.Perm.permGroup.{u1} β)) (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) (Equiv.Perm.permGroup.{max u2 u1} (Sum.{u2, u1} α β)) (Equiv.Perm.sumCongrHom.{u2, u1} α β))))] [_inst_2 : Fintype.{max u1 u2} (Prod.{u2, u1} (Equiv.Perm.{succ u2} α) (Equiv.Perm.{succ u1} β))], Eq.{1} Nat (Fintype.card.{max u2 u1} (Subtype.{succ (max u2 u1)} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) (fun (x : Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) => Membership.mem.{max u2 u1, max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) (Subgroup.{max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) (Equiv.Perm.permGroup.{max u2 u1} (Sum.{u2, u1} α β))) (SetLike.instMembership.{max u2 u1, max u2 u1} (Subgroup.{max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) (Equiv.Perm.permGroup.{max u2 u1} (Sum.{u2, u1} α β))) (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) (Subgroup.instSetLikeSubgroup.{max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) (Equiv.Perm.permGroup.{max u2 u1} (Sum.{u2, u1} α β)))) x (MonoidHom.range.{max u2 u1, max u2 u1} (Prod.{u2, u1} (Equiv.Perm.{succ u2} α) (Equiv.Perm.{succ u1} β)) (Prod.instGroupProd.{u2, u1} (Equiv.Perm.{succ u2} α) (Equiv.Perm.{succ u1} β) (Equiv.Perm.permGroup.{u2} α) (Equiv.Perm.permGroup.{u1} β)) (Equiv.Perm.{max (succ u1) (succ u2)} (Sum.{u2, u1} α β)) (Equiv.Perm.permGroup.{max u2 u1} (Sum.{u2, u1} α β)) (Equiv.Perm.sumCongrHom.{u2, u1} α β)))) _inst_1) (Fintype.card.{max u1 u2} (Prod.{u2, u1} (Equiv.Perm.{succ u2} α) (Equiv.Perm.{succ u1} β)) _inst_2)
Case conversion may be inaccurate. Consider using '#align equiv.perm.sum_congr_hom.card_range Equiv.Perm.sumCongrHom.card_rangeₓ'. -/
@[simp]
theorem sumCongrHom.card_range {α β : Type _} [Fintype (sumCongrHom α β).range]
    [Fintype (Perm α × Perm β)] :
    Fintype.card (sumCongrHom α β).range = Fintype.card (Perm α × Perm β) :=
  Fintype.card_eq.mpr ⟨(ofInjective (sumCongrHom α β) sumCongrHom_injective).symm⟩
#align equiv.perm.sum_congr_hom.card_range Equiv.Perm.sumCongrHom.card_range

/- warning: equiv.perm.sigma_congr_right_hom.decidable_mem_range -> Equiv.Perm.sigmaCongrRightHom.decidableMemRange is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : α -> Type.{u2}} [_inst_1 : DecidableEq.{succ u1} α] [_inst_2 : forall (a : α), DecidableEq.{succ u2} (β a)] [_inst_3 : Fintype.{u1} α] [_inst_4 : forall (a : α), Fintype.{u2} (β a)], DecidablePred.{succ (max u1 u2)} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (fun (_x : Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) => Membership.Mem.{max u1 u2, max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a)))) (SetLike.hasMem.{max u1 u2, max u1 u2} (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a)))) (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Subgroup.setLike.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a))))) _x (MonoidHom.range.{max u1 u2, max u1 u2} (forall (a : α), Equiv.Perm.{succ u2} (β a)) (Pi.group.{u1, u2} α (fun (a : α) => Equiv.Perm.{succ u2} (β a)) (fun (i : α) => Equiv.Perm.permGroup.{u2} (β i))) (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.sigmaCongrRightHom.{u1, u2} α β)))
but is expected to have type
  forall {α : Type.{u1}} {β : α -> Type.{u2}} [_inst_1 : DecidableEq.{succ u1} α] [_inst_2 : forall (a : α), DecidableEq.{succ u2} (β a)] [_inst_3 : Fintype.{u1} α] [_inst_4 : forall (a : α), Fintype.{u2} (β a)], DecidablePred.{succ (max u1 u2)} (Equiv.Perm.{max (succ u2) (succ u1)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (fun (_x : Equiv.Perm.{max (succ u2) (succ u1)} (Sigma.{u1, u2} α (fun (a : α) => β a))) => Membership.mem.{max u1 u2, max u1 u2} (Equiv.Perm.{max (succ u2) (succ u1)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u2) (succ u1)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a)))) (SetLike.instMembership.{max u1 u2, max u1 u2} (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u2) (succ u1)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a)))) (Equiv.Perm.{max (succ u2) (succ u1)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Subgroup.instSetLikeSubgroup.{max u1 u2} (Equiv.Perm.{max (succ u2) (succ u1)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a))))) _x (MonoidHom.range.{max u1 u2, max u1 u2} (forall (a : α), Equiv.Perm.{succ u2} (β a)) (Pi.group.{u1, u2} α (fun (a : α) => Equiv.Perm.{succ u2} (β a)) (fun (i : α) => Equiv.Perm.permGroup.{u2} (β i))) (Equiv.Perm.{max (succ u2) (succ u1)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.sigmaCongrRightHom.{u1, u2} α β)))
Case conversion may be inaccurate. Consider using '#align equiv.perm.sigma_congr_right_hom.decidable_mem_range Equiv.Perm.sigmaCongrRightHom.decidableMemRangeₓ'. -/
instance sigmaCongrRightHom.decidableMemRange {α : Type _} {β : α → Type _} [DecidableEq α]
    [∀ a, DecidableEq (β a)] [Fintype α] [∀ a, Fintype (β a)] :
    DecidablePred (· ∈ (sigmaCongrRightHom β).range) := fun x => inferInstance
#align equiv.perm.sigma_congr_right_hom.decidable_mem_range Equiv.Perm.sigmaCongrRightHom.decidableMemRange

/- warning: equiv.perm.sigma_congr_right_hom.card_range -> Equiv.Perm.sigmaCongrRightHom.card_range is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : α -> Type.{u2}} [_inst_1 : Fintype.{max u1 u2} (coeSort.{succ (max u1 u2), succ (succ (max u1 u2))} (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a)))) Type.{max u1 u2} (SetLike.hasCoeToSort.{max u1 u2, max u1 u2} (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a)))) (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Subgroup.setLike.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a))))) (MonoidHom.range.{max u1 u2, max u1 u2} (forall (a : α), Equiv.Perm.{succ u2} (β a)) (Pi.group.{u1, u2} α (fun (a : α) => Equiv.Perm.{succ u2} (β a)) (fun (i : α) => Equiv.Perm.permGroup.{u2} (β i))) (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.sigmaCongrRightHom.{u1, u2} α β)))] [_inst_2 : Fintype.{max u1 u2} (forall (a : α), Equiv.Perm.{succ u2} (β a))], Eq.{1} Nat (Fintype.card.{max u1 u2} (coeSort.{succ (max u1 u2), succ (succ (max u1 u2))} (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a)))) Type.{max u1 u2} (SetLike.hasCoeToSort.{max u1 u2, max u1 u2} (Subgroup.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a)))) (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Subgroup.setLike.{max u1 u2} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a))))) (MonoidHom.range.{max u1 u2, max u1 u2} (forall (a : α), Equiv.Perm.{succ u2} (β a)) (Pi.group.{u1, u2} α (fun (a : α) => Equiv.Perm.{succ u2} (β a)) (fun (i : α) => Equiv.Perm.permGroup.{u2} (β i))) (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u1 u2} (Sigma.{u1, u2} α (fun (a : α) => β a))) (Equiv.Perm.sigmaCongrRightHom.{u1, u2} α β))) _inst_1) (Fintype.card.{max u1 u2} (forall (a : α), Equiv.Perm.{succ u2} (β a)) _inst_2)
but is expected to have type
  forall {α : Type.{u2}} {β : α -> Type.{u1}} [_inst_1 : Fintype.{max u2 u1} (Subtype.{succ (max u2 u1)} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) (fun (x : Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) => Membership.mem.{max u2 u1, max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) (Subgroup.{max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u2 u1} (Sigma.{u2, u1} α (fun (a : α) => β a)))) (SetLike.instMembership.{max u2 u1, max u2 u1} (Subgroup.{max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u2 u1} (Sigma.{u2, u1} α (fun (a : α) => β a)))) (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) (Subgroup.instSetLikeSubgroup.{max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u2 u1} (Sigma.{u2, u1} α (fun (a : α) => β a))))) x (MonoidHom.range.{max u2 u1, max u2 u1} (forall (a : α), Equiv.Perm.{succ u1} (β a)) (Pi.group.{u2, u1} α (fun (a : α) => Equiv.Perm.{succ u1} (β a)) (fun (i : α) => Equiv.Perm.permGroup.{u1} (β i))) (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u2 u1} (Sigma.{u2, u1} α (fun (a : α) => β a))) (Equiv.Perm.sigmaCongrRightHom.{u2, u1} α β))))] [_inst_2 : Fintype.{max u2 u1} (forall (a : α), Equiv.Perm.{succ u1} (β a))], Eq.{1} Nat (Fintype.card.{max u2 u1} (Subtype.{succ (max u2 u1)} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) (fun (x : Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) => Membership.mem.{max u2 u1, max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) (Subgroup.{max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u2 u1} (Sigma.{u2, u1} α (fun (a : α) => β a)))) (SetLike.instMembership.{max u2 u1, max u2 u1} (Subgroup.{max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u2 u1} (Sigma.{u2, u1} α (fun (a : α) => β a)))) (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) (Subgroup.instSetLikeSubgroup.{max u2 u1} (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u2 u1} (Sigma.{u2, u1} α (fun (a : α) => β a))))) x (MonoidHom.range.{max u2 u1, max u2 u1} (forall (a : α), Equiv.Perm.{succ u1} (β a)) (Pi.group.{u2, u1} α (fun (a : α) => Equiv.Perm.{succ u1} (β a)) (fun (i : α) => Equiv.Perm.permGroup.{u1} (β i))) (Equiv.Perm.{max (succ u1) (succ u2)} (Sigma.{u2, u1} α (fun (a : α) => β a))) (Equiv.Perm.permGroup.{max u2 u1} (Sigma.{u2, u1} α (fun (a : α) => β a))) (Equiv.Perm.sigmaCongrRightHom.{u2, u1} α β)))) _inst_1) (Fintype.card.{max u2 u1} (forall (a : α), Equiv.Perm.{succ u1} (β a)) _inst_2)
Case conversion may be inaccurate. Consider using '#align equiv.perm.sigma_congr_right_hom.card_range Equiv.Perm.sigmaCongrRightHom.card_rangeₓ'. -/
@[simp]
theorem sigmaCongrRightHom.card_range {α : Type _} {β : α → Type _}
    [Fintype (sigmaCongrRightHom β).range] [Fintype (∀ a, Perm (β a))] :
    Fintype.card (sigmaCongrRightHom β).range = Fintype.card (∀ a, Perm (β a)) :=
  Fintype.card_eq.mpr ⟨(ofInjective (sigmaCongrRightHom β) sigmaCongrRightHom_injective).symm⟩
#align equiv.perm.sigma_congr_right_hom.card_range Equiv.Perm.sigmaCongrRightHom.card_range

/- warning: equiv.perm.subtype_congr_hom.decidable_mem_range -> Equiv.Perm.subtypeCongrHom.decidableMemRange is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} (p : α -> Prop) [_inst_1 : DecidablePred.{succ u1} α p] [_inst_2 : Fintype.{u1} (Prod.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a)))))] [_inst_3 : DecidableEq.{succ u1} (Equiv.Perm.{succ u1} α)], DecidablePred.{succ u1} (Equiv.Perm.{succ u1} α) (fun (_x : Equiv.Perm.{succ u1} α) => Membership.Mem.{u1, u1} (Equiv.Perm.{succ u1} α) (Subgroup.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α)) (SetLike.hasMem.{u1, u1} (Subgroup.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α)) (Equiv.Perm.{succ u1} α) (Subgroup.setLike.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α))) _x (MonoidHom.range.{u1, u1} (Prod.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a))))) (Prod.group.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a)))) (Equiv.Perm.permGroup.{u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.permGroup.{u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a))))) (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α) (Equiv.Perm.subtypeCongrHom.{u1} α p (fun (a : α) => _inst_1 a))))
but is expected to have type
  forall {α : Type.{u1}} (p : α -> Prop) [_inst_1 : DecidablePred.{succ u1} α p] [_inst_2 : Fintype.{u1} (Prod.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a)))))] [_inst_3 : DecidableEq.{succ u1} (Equiv.Perm.{succ u1} α)], DecidablePred.{succ u1} (Equiv.Perm.{succ u1} α) (fun (_x : Equiv.Perm.{succ u1} α) => Membership.mem.{u1, u1} (Equiv.Perm.{succ u1} α) (Subgroup.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α)) (SetLike.instMembership.{u1, u1} (Subgroup.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α)) (Equiv.Perm.{succ u1} α) (Subgroup.instSetLikeSubgroup.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α))) _x (MonoidHom.range.{u1, u1} (Prod.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a))))) (Prod.instGroupProd.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a)))) (Equiv.Perm.permGroup.{u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.permGroup.{u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a))))) (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α) (Equiv.Perm.subtypeCongrHom.{u1} α p (fun (a : α) => _inst_1 a))))
Case conversion may be inaccurate. Consider using '#align equiv.perm.subtype_congr_hom.decidable_mem_range Equiv.Perm.subtypeCongrHom.decidableMemRangeₓ'. -/
instance subtypeCongrHom.decidableMemRange {α : Type _} (p : α → Prop) [DecidablePred p]
    [Fintype (Perm { a // p a } × Perm { a // ¬p a })] [DecidableEq (Perm α)] :
    DecidablePred (· ∈ (subtypeCongrHom p).range) := fun x => inferInstance
#align equiv.perm.subtype_congr_hom.decidable_mem_range Equiv.Perm.subtypeCongrHom.decidableMemRange

/- warning: equiv.perm.subtype_congr_hom.card_range -> Equiv.Perm.subtypeCongrHom.card_range is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} (p : α -> Prop) [_inst_1 : DecidablePred.{succ u1} α p] [_inst_2 : Fintype.{u1} (coeSort.{succ u1, succ (succ u1)} (Subgroup.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subgroup.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α)) (Equiv.Perm.{succ u1} α) (Subgroup.setLike.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α))) (MonoidHom.range.{u1, u1} (Prod.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a))))) (Prod.group.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a)))) (Equiv.Perm.permGroup.{u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.permGroup.{u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a))))) (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α) (Equiv.Perm.subtypeCongrHom.{u1} α p (fun (a : α) => _inst_1 a))))] [_inst_3 : Fintype.{u1} (Prod.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a)))))], Eq.{1} Nat (Fintype.card.{u1} (coeSort.{succ u1, succ (succ u1)} (Subgroup.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α)) Type.{u1} (SetLike.hasCoeToSort.{u1, u1} (Subgroup.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α)) (Equiv.Perm.{succ u1} α) (Subgroup.setLike.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α))) (MonoidHom.range.{u1, u1} (Prod.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a))))) (Prod.group.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a)))) (Equiv.Perm.permGroup.{u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.permGroup.{u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a))))) (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α) (Equiv.Perm.subtypeCongrHom.{u1} α p (fun (a : α) => _inst_1 a)))) _inst_2) (Fintype.card.{u1} (Prod.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a))))) _inst_3)
but is expected to have type
  forall {α : Type.{u1}} (p : α -> Prop) [_inst_1 : DecidablePred.{succ u1} α p] [_inst_2 : Fintype.{u1} (Subtype.{succ u1} (Equiv.Perm.{succ u1} α) (fun (x : Equiv.Perm.{succ u1} α) => Membership.mem.{u1, u1} (Equiv.Perm.{succ u1} α) (Subgroup.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α)) (SetLike.instMembership.{u1, u1} (Subgroup.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α)) (Equiv.Perm.{succ u1} α) (Subgroup.instSetLikeSubgroup.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α))) x (MonoidHom.range.{u1, u1} (Prod.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a))))) (Prod.instGroupProd.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a)))) (Equiv.Perm.permGroup.{u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.permGroup.{u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a))))) (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α) (Equiv.Perm.subtypeCongrHom.{u1} α p (fun (a : α) => _inst_1 a)))))] [_inst_3 : Fintype.{u1} (Prod.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a)))))], Eq.{1} Nat (Fintype.card.{u1} (Subtype.{succ u1} (Equiv.Perm.{succ u1} α) (fun (x : Equiv.Perm.{succ u1} α) => Membership.mem.{u1, u1} (Equiv.Perm.{succ u1} α) (Subgroup.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α)) (SetLike.instMembership.{u1, u1} (Subgroup.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α)) (Equiv.Perm.{succ u1} α) (Subgroup.instSetLikeSubgroup.{u1} (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α))) x (MonoidHom.range.{u1, u1} (Prod.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a))))) (Prod.instGroupProd.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a)))) (Equiv.Perm.permGroup.{u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.permGroup.{u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a))))) (Equiv.Perm.{succ u1} α) (Equiv.Perm.permGroup.{u1} α) (Equiv.Perm.subtypeCongrHom.{u1} α p (fun (a : α) => _inst_1 a))))) _inst_2) (Fintype.card.{u1} (Prod.{u1, u1} (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => p a))) (Equiv.Perm.{succ u1} (Subtype.{succ u1} α (fun (a : α) => Not (p a))))) _inst_3)
Case conversion may be inaccurate. Consider using '#align equiv.perm.subtype_congr_hom.card_range Equiv.Perm.subtypeCongrHom.card_rangeₓ'. -/
@[simp]
theorem subtypeCongrHom.card_range {α : Type _} (p : α → Prop) [DecidablePred p]
    [Fintype (subtypeCongrHom p).range] [Fintype (Perm { a // p a } × Perm { a // ¬p a })] :
    Fintype.card (subtypeCongrHom p).range =
      Fintype.card (Perm { a // p a } × Perm { a // ¬p a }) :=
  Fintype.card_eq.mpr ⟨(ofInjective (subtypeCongrHom p) (subtypeCongrHom_injective p)).symm⟩
#align equiv.perm.subtype_congr_hom.card_range Equiv.Perm.subtypeCongrHom.card_range

/- warning: equiv.perm.subgroup_of_mul_action -> Equiv.Perm.subgroupOfMulAction is a dubious translation:
lean 3 declaration is
  forall (G : Type.{u1}) (H : Type.{u2}) [_inst_1 : Group.{u1} G] [_inst_2 : MulAction.{u1, u2} G H (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1))] [_inst_3 : FaithfulSMul.{u1, u2} G H (MulAction.toHasSmul.{u1, u2} G H (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)) _inst_2)], MulEquiv.{u1, u2} G (coeSort.{succ u2, succ (succ u2)} (Subgroup.{u2} (Equiv.Perm.{succ u2} H) (Equiv.Perm.permGroup.{u2} H)) Type.{u2} (SetLike.hasCoeToSort.{u2, u2} (Subgroup.{u2} (Equiv.Perm.{succ u2} H) (Equiv.Perm.permGroup.{u2} H)) (Equiv.Perm.{succ u2} H) (Subgroup.setLike.{u2} (Equiv.Perm.{succ u2} H) (Equiv.Perm.permGroup.{u2} H))) (MonoidHom.range.{u1, u2} G _inst_1 (Equiv.Perm.{succ u2} H) (Equiv.Perm.permGroup.{u2} H) (MulAction.toPermHom.{u1, u2} G H _inst_1 _inst_2))) (MulOneClass.toHasMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))) (Subgroup.mul.{u2} (Equiv.Perm.{succ u2} H) (Equiv.Perm.permGroup.{u2} H) (MonoidHom.range.{u1, u2} G _inst_1 (Equiv.Perm.{succ u2} H) (Equiv.Perm.permGroup.{u2} H) (MulAction.toPermHom.{u1, u2} G H _inst_1 _inst_2)))
but is expected to have type
  forall (G : Type.{u1}) (H : Type.{u2}) [_inst_1 : Group.{u1} G] [_inst_2 : MulAction.{u1, u2} G H (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1))] [_inst_3 : FaithfulSMul.{u1, u2} G H (MulAction.toSMul.{u1, u2} G H (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)) _inst_2)], MulEquiv.{u1, u2} G (Subtype.{succ u2} (Equiv.Perm.{succ u2} H) (fun (x : Equiv.Perm.{succ u2} H) => Membership.mem.{u2, u2} (Equiv.Perm.{succ u2} H) (Subgroup.{u2} (Equiv.Perm.{succ u2} H) (Equiv.Perm.permGroup.{u2} H)) (SetLike.instMembership.{u2, u2} (Subgroup.{u2} (Equiv.Perm.{succ u2} H) (Equiv.Perm.permGroup.{u2} H)) (Equiv.Perm.{succ u2} H) (Subgroup.instSetLikeSubgroup.{u2} (Equiv.Perm.{succ u2} H) (Equiv.Perm.permGroup.{u2} H))) x (MonoidHom.range.{u1, u2} G _inst_1 (Equiv.Perm.{succ u2} H) (Equiv.Perm.permGroup.{u2} H) (MulAction.toPermHom.{u1, u2} G H _inst_1 _inst_2)))) (MulOneClass.toMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (Group.toDivInvMonoid.{u1} G _inst_1)))) (Subgroup.mul.{u2} (Equiv.Perm.{succ u2} H) (Equiv.Perm.permGroup.{u2} H) (MonoidHom.range.{u1, u2} G _inst_1 (Equiv.Perm.{succ u2} H) (Equiv.Perm.permGroup.{u2} H) (MulAction.toPermHom.{u1, u2} G H _inst_1 _inst_2)))
Case conversion may be inaccurate. Consider using '#align equiv.perm.subgroup_of_mul_action Equiv.Perm.subgroupOfMulActionₓ'. -/
/-- **Cayley's theorem**: Every group G is isomorphic to a subgroup of the symmetric group acting on
`G`. Note that we generalize this to an arbitrary "faithful" group action by `G`. Setting `H = G`
recovers the usual statement of Cayley's theorem via `right_cancel_monoid.to_has_faithful_smul` -/
noncomputable def subgroupOfMulAction (G H : Type _) [Group G] [MulAction G H] [FaithfulSMul G H] :
    G ≃* (MulAction.toPermHom G H).range :=
  MulEquiv.ofLeftInverse' _ (Classical.choose_spec MulAction.toPerm_injective.HasLeftInverse)
#align equiv.perm.subgroup_of_mul_action Equiv.Perm.subgroupOfMulAction

end Perm

end Equiv

