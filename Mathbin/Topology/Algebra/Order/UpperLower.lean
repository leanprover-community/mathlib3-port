/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module topology.algebra.order.upper_lower
! leanprover-community/mathlib commit bd9851ca476957ea4549eb19b40e7b5ade9428cc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.UpperLower
import Mathbin.Topology.Algebra.Group.Basic

/-!
# Topological facts about upper/lower/order-connected sets

The topological closure and interior of an upper/lower/order-connected set is an
upper/lower/order-connected set (with the notable exception of the closure of an order-connected
set).

## Notes

The lemmas don't mention additive/multiplicative operations. As a result, we decide to prime the
multiplicative lemma names to indicate that there is probably a common generalisation to each pair
of additive/multiplicative lemma.
-/


open Function Set

open Pointwise

/-- Ad hoc class stating that the closure of an upper set is an upper set. This is used to state
lemmas that do not mention algebraic operations for both the additive and multiplicative versions
simultaneously. If you find a satisfying replacement for this typeclass, please remove it! -/
class HasUpperLowerClosure (α : Type _) [TopologicalSpace α] [Preorder α] : Prop where
  isUpperSet_closure : ∀ s : Set α, IsUpperSet s → IsUpperSet (closure s)
  isLowerSet_closure : ∀ s : Set α, IsLowerSet s → IsLowerSet (closure s)
  isOpen_upperClosure : ∀ s : Set α, IsOpen s → IsOpen (upperClosure s : Set α)
  isOpen_lowerClosure : ∀ s : Set α, IsOpen s → IsOpen (lowerClosure s : Set α)
#align has_upper_lower_closure HasUpperLowerClosure

variable {α : Type _} [TopologicalSpace α]

-- See note [lower instance priority]
@[to_additive]
instance (priority := 100) OrderedCommGroup.to_hasUpperLowerClosure [OrderedCommGroup α]
    [ContinuousConstSMul α α] : HasUpperLowerClosure α
    where
  isUpperSet_closure s h x y hxy hx :=
    closure_mono (h.smul_subset <| one_le_div'.2 hxy) <|
      by
      rw [closure_smul]
      exact ⟨x, hx, div_mul_cancel' _ _⟩
  isLowerSet_closure s h x y hxy hx :=
    closure_mono (h.smul_subset <| div_le_one'.2 hxy) <|
      by
      rw [closure_smul]
      exact ⟨x, hx, div_mul_cancel' _ _⟩
  isOpen_upperClosure s hs := by
    rw [← mul_one s, ← mul_upperClosure]
    exact hs.mul_right
  isOpen_lowerClosure s hs := by
    rw [← mul_one s, ← mul_lowerClosure]
    exact hs.mul_right
#align ordered_comm_group.to_has_upper_lower_closure OrderedCommGroup.to_hasUpperLowerClosure
#align ordered_add_comm_group.to_has_upper_lower_closure OrderedAddCommGroup.to_hasUpperLowerClosure

variable [Preorder α] [HasUpperLowerClosure α] {s : Set α}

protected theorem IsUpperSet.closure : IsUpperSet s → IsUpperSet (closure s) :=
  HasUpperLowerClosure.isUpperSet_closure _
#align is_upper_set.closure IsUpperSet.closure

protected theorem IsLowerSet.closure : IsLowerSet s → IsLowerSet (closure s) :=
  HasUpperLowerClosure.isLowerSet_closure _
#align is_lower_set.closure IsLowerSet.closure

protected theorem IsOpen.upperClosure : IsOpen s → IsOpen (upperClosure s : Set α) :=
  HasUpperLowerClosure.isOpen_upperClosure _
#align is_open.upper_closure IsOpen.upperClosure

protected theorem IsOpen.lowerClosure : IsOpen s → IsOpen (lowerClosure s : Set α) :=
  HasUpperLowerClosure.isOpen_lowerClosure _
#align is_open.lower_closure IsOpen.lowerClosure

instance : HasUpperLowerClosure αᵒᵈ
    where
  isUpperSet_closure := @IsLowerSet.closure α _ _ _
  isLowerSet_closure := @IsUpperSet.closure α _ _ _
  isOpen_upperClosure := @IsOpen.lowerClosure α _ _ _
  isOpen_lowerClosure := @IsOpen.upperClosure α _ _ _

/-
Note: `s.ord_connected` does not imply `(closure s).ord_connected`, as we can see by taking
`s := Ioo 0 1 × Ioo 1 2 ∪ Ioo 2 3 × Ioo 0 1` because then
`closure s = Icc 0 1 × Icc 1 2 ∪ Icc 2 3 × Icc 0 1` is not order-connected as
`(1, 1) ∈ closure s`, `(2, 1) ∈ closure s` but `Icc (1, 1) (2, 1) ⊈ closure s`.

`s` looks like
```
xxooooo
xxooooo
oooooxx
oooooxx
```
-/
protected theorem IsUpperSet.interior (h : IsUpperSet s) : IsUpperSet (interior s) :=
  by
  rw [← isLowerSet_compl, ← closure_compl]
  exact h.compl.closure
#align is_upper_set.interior IsUpperSet.interior

protected theorem IsLowerSet.interior (h : IsLowerSet s) : IsLowerSet (interior s) :=
  h.ofDual.interior
#align is_lower_set.interior IsLowerSet.interior

protected theorem Set.OrdConnected.interior (h : s.OrdConnected) : (interior s).OrdConnected :=
  by
  rw [← h.upper_closure_inter_lower_closure, interior_inter]
  exact
    (upperClosure s).upper.interior.OrdConnected.inter (lowerClosure s).lower.interior.OrdConnected
#align set.ord_connected.interior Set.OrdConnected.interior

