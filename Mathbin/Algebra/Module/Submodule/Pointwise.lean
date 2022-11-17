/-
Copyright (c) 2021 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser
-/
import Mathbin.GroupTheory.Subgroup.Pointwise
import Mathbin.LinearAlgebra.Span

/-! # Pointwise instances on `submodule`s

This file provides:

* `submodule.has_pointwise_neg`

and the actions

* `submodule.pointwise_distrib_mul_action`
* `submodule.pointwise_mul_action_with_zero`

which matches the action of `mul_action_set`.

These actions are available in the `pointwise` locale.

## Implementation notes

Most of the lemmas in this file are direct copies of lemmas from
`group_theory/submonoid/pointwise.lean`.
-/


variable {α : Type _} {R : Type _} {M : Type _}

open Pointwise

namespace Submodule

section Neg

section Semiring

variable [Semiring R] [AddCommGroup M] [Module R M]

/-- The submodule with every element negated. Note if `R` is a ring and not just a semiring, this
is a no-op, as shown by `submodule.neg_eq_self`.

Recall that When `R` is the semiring corresponding to the nonnegative elements of `R'`,
`submodule R' M` is the type of cones of `M`. This instance reflects such cones about `0`.

This is available as an instance in the `pointwise` locale. -/
protected def hasPointwiseNeg :
    Neg
      (Submodule R
        M) where neg p :=
    { -p.toAddSubmonoid with carrier := -(p : Set M),
      smul_mem' := fun r m hm => Set.mem_neg.2 $ smul_neg r m ▸ p.smul_mem r $ Set.mem_neg.1 hm }
#align submodule.has_pointwise_neg Submodule.hasPointwiseNeg

scoped[Pointwise] attribute [instance] Submodule.hasPointwiseNeg

open Pointwise

@[simp]
theorem coe_set_neg (S : Submodule R M) : ↑(-S) = -(S : Set M) :=
  rfl
#align submodule.coe_set_neg Submodule.coe_set_neg

@[simp]
theorem neg_to_add_submonoid (S : Submodule R M) : (-S).toAddSubmonoid = -S.toAddSubmonoid :=
  rfl
#align submodule.neg_to_add_submonoid Submodule.neg_to_add_submonoid

@[simp]
theorem mem_neg {g : M} {S : Submodule R M} : g ∈ -S ↔ -g ∈ S :=
  Iff.rfl
#align submodule.mem_neg Submodule.mem_neg

/-- `submodule.has_pointwise_neg` is involutive.

This is available as an instance in the `pointwise` locale. -/
protected def hasInvolutivePointwiseNeg : HasInvolutiveNeg (Submodule R M) where
  neg := Neg.neg
  neg_neg S := SetLike.coe_injective $ neg_neg _
#align submodule.has_involutive_pointwise_neg Submodule.hasInvolutivePointwiseNeg

scoped[Pointwise] attribute [instance] Submodule.hasInvolutivePointwiseNeg

@[simp]
theorem neg_le_neg (S T : Submodule R M) : -S ≤ -T ↔ S ≤ T :=
  SetLike.coe_subset_coe.symm.trans Set.neg_subset_neg
#align submodule.neg_le_neg Submodule.neg_le_neg

theorem neg_le (S T : Submodule R M) : -S ≤ T ↔ S ≤ -T :=
  SetLike.coe_subset_coe.symm.trans Set.neg_subset
#align submodule.neg_le Submodule.neg_le

/-- `submodule.has_pointwise_neg` as an order isomorphism. -/
def negOrderIso : Submodule R M ≃o Submodule R M where
  toEquiv := Equiv.neg _
  map_rel_iff' := neg_le_neg
#align submodule.neg_order_iso Submodule.negOrderIso

theorem closure_neg (s : Set M) : span R (-s) = -span R s := by
  apply le_antisymm
  · rw [span_le, coe_set_neg, ← Set.neg_subset, neg_neg]
    exact subset_span
    
  · rw [neg_le, span_le, coe_set_neg, ← Set.neg_subset]
    exact subset_span
    
#align submodule.closure_neg Submodule.closure_neg

@[simp]
theorem neg_inf (S T : Submodule R M) : -(S ⊓ T) = -S ⊓ -T :=
  SetLike.coe_injective Set.inter_neg
#align submodule.neg_inf Submodule.neg_inf

@[simp]
theorem neg_sup (S T : Submodule R M) : -(S ⊔ T) = -S ⊔ -T :=
  (negOrderIso : Submodule R M ≃o Submodule R M).map_sup S T
#align submodule.neg_sup Submodule.neg_sup

@[simp]
theorem neg_bot : -(⊥ : Submodule R M) = ⊥ :=
  SetLike.coe_injective $ (Set.neg_singleton 0).trans $ congr_arg _ neg_zero
#align submodule.neg_bot Submodule.neg_bot

@[simp]
theorem neg_top : -(⊤ : Submodule R M) = ⊤ :=
  SetLike.coe_injective $ Set.neg_univ
#align submodule.neg_top Submodule.neg_top

@[simp]
theorem neg_infi {ι : Sort _} (S : ι → Submodule R M) : (-⨅ i, S i) = ⨅ i, -S i :=
  (negOrderIso : Submodule R M ≃o Submodule R M).map_infi _
#align submodule.neg_infi Submodule.neg_infi

@[simp]
theorem neg_supr {ι : Sort _} (S : ι → Submodule R M) : (-⨆ i, S i) = ⨆ i, -S i :=
  (negOrderIso : Submodule R M ≃o Submodule R M).map_supr _
#align submodule.neg_supr Submodule.neg_supr

end Semiring

open Pointwise

@[simp]
theorem neg_eq_self [Ring R] [AddCommGroup M] [Module R M] (p : Submodule R M) : -p = p :=
  ext $ fun _ => p.neg_mem_iff
#align submodule.neg_eq_self Submodule.neg_eq_self

end Neg

variable [Semiring R] [AddCommMonoid M] [Module R M]

instance pointwiseAddCommMonoid : AddCommMonoid (Submodule R M) where
  add := (· ⊔ ·)
  add_assoc _ _ _ := sup_assoc
  zero := ⊥
  zero_add _ := bot_sup_eq
  add_zero _ := sup_bot_eq
  add_comm _ _ := sup_comm
#align submodule.pointwise_add_comm_monoid Submodule.pointwiseAddCommMonoid

@[simp]
theorem add_eq_sup (p q : Submodule R M) : p + q = p ⊔ q :=
  rfl
#align submodule.add_eq_sup Submodule.add_eq_sup

@[simp]
theorem zero_eq_bot : (0 : Submodule R M) = ⊥ :=
  rfl
#align submodule.zero_eq_bot Submodule.zero_eq_bot

instance : CanonicallyOrderedAddMonoid (Submodule R M) :=
  { Submodule.pointwiseAddCommMonoid, Submodule.completeLattice with zero := 0, bot := ⊥, add := (· + ·),
    add_le_add_left := fun a b => sup_le_sup_left, exists_add_of_le := fun a b h => ⟨b, (sup_eq_right.2 h).symm⟩,
    le_self_add := fun a b => le_sup_left }

section

variable [Monoid α] [DistribMulAction α M] [SmulCommClass α R M]

/-- The action on a submodule corresponding to applying the action to every element.

This is available as an instance in the `pointwise` locale. -/
protected def pointwiseDistribMulAction : DistribMulAction α (Submodule R M) where
  smul a S := S.map (DistribMulAction.toLinearMap R M a : M →ₗ[R] M)
  one_smul S := (congr_arg (fun f : Module.EndCat R M => S.map f) (LinearMap.ext $ one_smul α)).trans S.map_id
  mul_smul a₁ a₂ S :=
    (congr_arg (fun f : Module.EndCat R M => S.map f) (LinearMap.ext $ mul_smul _ _)).trans (S.map_comp _ _)
  smul_zero a := map_bot _
  smul_add a S₁ S₂ := map_sup _ _ _
#align submodule.pointwise_distrib_mul_action Submodule.pointwiseDistribMulAction

scoped[Pointwise] attribute [instance] Submodule.pointwiseDistribMulAction

open Pointwise

@[simp]
theorem coe_pointwise_smul (a : α) (S : Submodule R M) : ↑(a • S) = a • (S : Set M) :=
  rfl
#align submodule.coe_pointwise_smul Submodule.coe_pointwise_smul

@[simp]
theorem pointwise_smul_to_add_submonoid (a : α) (S : Submodule R M) : (a • S).toAddSubmonoid = a • S.toAddSubmonoid :=
  rfl
#align submodule.pointwise_smul_to_add_submonoid Submodule.pointwise_smul_to_add_submonoid

@[simp]
theorem pointwise_smul_to_add_subgroup {R M : Type _} [Ring R] [AddCommGroup M] [DistribMulAction α M] [Module R M]
    [SmulCommClass α R M] (a : α) (S : Submodule R M) : (a • S).toAddSubgroup = a • S.toAddSubgroup :=
  rfl
#align submodule.pointwise_smul_to_add_subgroup Submodule.pointwise_smul_to_add_subgroup

theorem smul_mem_pointwise_smul (m : M) (a : α) (S : Submodule R M) : m ∈ S → a • m ∈ a • S :=
  (Set.smul_mem_smul_set : _ → _ ∈ a • (S : Set M))
#align submodule.smul_mem_pointwise_smul Submodule.smul_mem_pointwise_smul

instance pointwise_central_scalar [DistribMulAction αᵐᵒᵖ M] [SmulCommClass αᵐᵒᵖ R M] [IsCentralScalar α M] :
    IsCentralScalar α (Submodule R M) :=
  ⟨fun a S => (congr_arg fun f : Module.EndCat R M => S.map f) $ LinearMap.ext $ op_smul_eq_smul _⟩
#align submodule.pointwise_central_scalar Submodule.pointwise_central_scalar

@[simp]
theorem smul_le_self_of_tower {α : Type _} [Semiring α] [Module α R] [Module α M] [SmulCommClass α R M]
    [IsScalarTower α R M] (a : α) (S : Submodule R M) : a • S ≤ S := by
  rintro y ⟨x, hx, rfl⟩
  exact smul_of_tower_mem _ a hx
#align submodule.smul_le_self_of_tower Submodule.smul_le_self_of_tower

end

section

variable [Semiring α] [Module α M] [SmulCommClass α R M]

/-- The action on a submodule corresponding to applying the action to every element.

This is available as an instance in the `pointwise` locale.

This is a stronger version of `submodule.pointwise_distrib_mul_action`. Note that `add_smul` does
not hold so this cannot be stated as a `module`. -/
protected def pointwiseMulActionWithZero : MulActionWithZero α (Submodule R M) :=
  { Submodule.pointwiseDistribMulAction with
    zero_smul := fun S => (congr_arg (fun f : M →ₗ[R] M => S.map f) (LinearMap.ext $ zero_smul α)).trans S.map_zero }
#align submodule.pointwise_mul_action_with_zero Submodule.pointwiseMulActionWithZero

scoped[Pointwise] attribute [instance] Submodule.pointwiseMulActionWithZero

end

end Submodule

