/-
Copyright (c) 2021 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module topology.urysohns_lemma
! leanprover-community/mathlib commit 8eb9c42d4d34c77f6ee84ea766ae4070233a973c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.AddTorsor
import Mathbin.LinearAlgebra.AffineSpace.Ordered
import Mathbin.Topology.ContinuousFunction.Basic

/-!
# Urysohn's lemma

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove Urysohn's lemma `exists_continuous_zero_one_of_closed`: for any two disjoint
closed sets `s` and `t` in a normal topological space `X` there exists a continuous function
`f : X → ℝ` such that

* `f` equals zero on `s`;
* `f` equals one on `t`;
* `0 ≤ f x ≤ 1` for all `x`.

## Implementation notes

Most paper sources prove Urysohn's lemma using a family of open sets indexed by dyadic rational
numbers on `[0, 1]`. There are many technical difficulties with formalizing this proof (e.g., one
needs to formalize the "dyadic induction", then prove that the resulting family of open sets is
monotone). So, we formalize a slightly different proof.

Let `urysohns.CU` be the type of pairs `(C, U)` of a closed set `C`and an open set `U` such that
`C ⊆ U`. Since `X` is a normal topological space, for each `c : CU X` there exists an open set `u`
such that `c.C ⊆ u ∧ closure u ⊆ c.U`. We define `c.left` and `c.right` to be `(c.C, u)` and
`(closure u, c.U)`, respectively. Then we define a family of functions
`urysohns.CU.approx (c : urysohns.CU X) (n : ℕ) : X → ℝ` by recursion on `n`:

* `c.approx 0` is the indicator of `c.Uᶜ`;
* `c.approx (n + 1) x = (c.left.approx n x + c.right.approx n x) / 2`.

For each `x` this is a monotone family of functions that are equal to zero on `c.C` and are equal to
one outside of `c.U`. We also have `c.approx n x ∈ [0, 1]` for all `c`, `n`, and `x`.

Let `urysohns.CU.lim c` be the supremum (or equivalently, the limit) of `c.approx n`. Then
properties of `urysohns.CU.approx` immediately imply that

* `c.lim x ∈ [0, 1]` for all `x`;
* `c.lim` equals zero on `c.C` and equals one outside of `c.U`;
* `c.lim x = (c.left.lim x + c.right.lim x) / 2`.

In order to prove that `c.lim` is continuous at `x`, we prove by induction on `n : ℕ` that for `y`
in a small neighborhood of `x` we have `|c.lim y - c.lim x| ≤ (3 / 4) ^ n`. Induction base follows
from `c.lim x ∈ [0, 1]`, `c.lim y ∈ [0, 1]`. For the induction step, consider two cases:

* `x ∈ c.left.U`; then for `y` in a small neighborhood of `x` we have `y ∈ c.left.U ⊆ c.right.C`
  (hence `c.right.lim x = c.right.lim y = 0`) and `|c.left.lim y - c.left.lim x| ≤ (3 / 4) ^ n`.
  Then
  `|c.lim y - c.lim x| = |c.left.lim y - c.left.lim x| / 2 ≤ (3 / 4) ^ n / 2 < (3 / 4) ^ (n + 1)`.

* otherwise, `x ∉ c.left.right.C`; then for `y` in a small neighborhood of `x` we have
  `y ∉ c.left.right.C ⊇ c.left.left.U` (hence `c.left.left.lim x = c.left.left.lim y = 1`),
  `|c.left.right.lim y - c.left.right.lim x| ≤ (3 / 4) ^ n`, and
  `|c.right.lim y - c.right.lim x| ≤ (3 / 4) ^ n`. Combining these inequalities, the triangle
  inequality, and the recurrence formula for `c.lim`, we get
  `|c.lim x - c.lim y| ≤ (3 / 4) ^ (n + 1)`.

The actual formalization uses `midpoint ℝ x y` instead of `(x + y) / 2` because we have more API
lemmas about `midpoint`.

## Tags

Urysohn's lemma, normal topological space
-/


variable {X : Type _} [TopologicalSpace X]

open Set Filter TopologicalSpace

open Topology Filter

namespace Urysohns

#print Urysohns.CU /-
/-- An auxiliary type for the proof of Urysohn's lemma: a pair of a closed set `C` and its
open neighborhood `U`. -/
@[protect_proj]
structure CU (X : Type _) [TopologicalSpace X] where
  (C U : Set X)
  closed_c : IsClosed C
  open_u : IsOpen U
  Subset : C ⊆ U
#align urysohns.CU Urysohns.CU
-/

instance : Inhabited (CU X) :=
  ⟨⟨∅, univ, isClosed_empty, isOpen_univ, empty_subset _⟩⟩

variable [NormalSpace X]

namespace CU

#print Urysohns.CU.left /-
/-- Due to `normal_exists_closure_subset`, for each `c : CU X` there exists an open set `u`
such chat `c.C ⊆ u` and `closure u ⊆ c.U`. `c.left` is the pair `(c.C, u)`. -/
@[simps C]
def left (c : CU X) : CU X where
  C := c.C
  U := (normal_exists_closure_subset c.closed_c c.open_u c.Subset).some
  closed_c := c.closed_c
  open_u := (normal_exists_closure_subset c.closed_c c.open_u c.Subset).choose_spec.1
  Subset := (normal_exists_closure_subset c.closed_c c.open_u c.Subset).choose_spec.2.1
#align urysohns.CU.left Urysohns.CU.left
-/

#print Urysohns.CU.right /-
/-- Due to `normal_exists_closure_subset`, for each `c : CU X` there exists an open set `u`
such chat `c.C ⊆ u` and `closure u ⊆ c.U`. `c.right` is the pair `(closure u, c.U)`. -/
@[simps U]
def right (c : CU X) : CU X
    where
  C := closure (normal_exists_closure_subset c.closed_c c.open_u c.Subset).some
  U := c.U
  closed_c := isClosed_closure
  open_u := c.open_u
  Subset := (normal_exists_closure_subset c.closed_c c.open_u c.Subset).choose_spec.2.2
#align urysohns.CU.right Urysohns.CU.right
-/

#print Urysohns.CU.left_U_subset_right_C /-
theorem left_U_subset_right_C (c : CU X) : c.left.U ⊆ c.right.C :=
  subset_closure
#align urysohns.CU.left_U_subset_right_C Urysohns.CU.left_U_subset_right_C
-/

#print Urysohns.CU.left_U_subset /-
theorem left_U_subset (c : CU X) : c.left.U ⊆ c.U :=
  Subset.trans c.left_U_subset_right_C c.right.Subset
#align urysohns.CU.left_U_subset Urysohns.CU.left_U_subset
-/

#print Urysohns.CU.subset_right_C /-
theorem subset_right_C (c : CU X) : c.C ⊆ c.right.C :=
  Subset.trans c.left.Subset c.left_U_subset_right_C
#align urysohns.CU.subset_right_C Urysohns.CU.subset_right_C
-/

#print Urysohns.CU.approx /-
/-- `n`-th approximation to a continuous function `f : X → ℝ` such that `f = 0` on `c.C` and `f = 1`
outside of `c.U`. -/
noncomputable def approx : ℕ → CU X → X → ℝ
  | 0, c, x => indicator (c.Uᶜ) 1 x
  | n + 1, c, x => midpoint ℝ (approx n c.left x) (approx n c.right x)
#align urysohns.CU.approx Urysohns.CU.approx
-/

/- warning: urysohns.CU.approx_of_mem_C -> Urysohns.CU.approx_of_mem_C is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (n : Nat) {x : X}, (Membership.Mem.{u1, u1} X (Set.{u1} X) (Set.hasMem.{u1} X) x (Urysohns.CU.c.{u1} X _inst_1 c)) -> (Eq.{1} Real (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n c x) (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))))
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (n : Nat) {x : X}, (Membership.mem.{u1, u1} X (Set.{u1} X) (Set.instMembershipSet.{u1} X) x (Urysohns.CU.C.{u1} X _inst_1 c)) -> (Eq.{1} Real (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n c x) (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)))
Case conversion may be inaccurate. Consider using '#align urysohns.CU.approx_of_mem_C Urysohns.CU.approx_of_mem_Cₓ'. -/
theorem approx_of_mem_C (c : CU X) (n : ℕ) {x : X} (hx : x ∈ c.C) : c.approx n x = 0 :=
  by
  induction' n with n ihn generalizing c
  · exact indicator_of_not_mem (fun hU => hU <| c.subset hx) _
  · simp only [approx]
    rw [ihn, ihn, midpoint_self]
    exacts[c.subset_right_C hx, hx]
#align urysohns.CU.approx_of_mem_C Urysohns.CU.approx_of_mem_C

/- warning: urysohns.CU.approx_of_nmem_U -> Urysohns.CU.approx_of_nmem_U is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (n : Nat) {x : X}, (Not (Membership.Mem.{u1, u1} X (Set.{u1} X) (Set.hasMem.{u1} X) x (Urysohns.CU.u.{u1} X _inst_1 c))) -> (Eq.{1} Real (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n c x) (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne))))
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (n : Nat) {x : X}, (Not (Membership.mem.{u1, u1} X (Set.{u1} X) (Set.instMembershipSet.{u1} X) x (Urysohns.CU.U.{u1} X _inst_1 c))) -> (Eq.{1} Real (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n c x) (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal)))
Case conversion may be inaccurate. Consider using '#align urysohns.CU.approx_of_nmem_U Urysohns.CU.approx_of_nmem_Uₓ'. -/
theorem approx_of_nmem_U (c : CU X) (n : ℕ) {x : X} (hx : x ∉ c.U) : c.approx n x = 1 :=
  by
  induction' n with n ihn generalizing c
  · exact indicator_of_mem hx _
  · simp only [approx]
    rw [ihn, ihn, midpoint_self]
    exacts[hx, fun hU => hx <| c.left_U_subset hU]
#align urysohns.CU.approx_of_nmem_U Urysohns.CU.approx_of_nmem_U

/- warning: urysohns.CU.approx_nonneg -> Urysohns.CU.approx_nonneg is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (n : Nat) (x : X), LE.le.{0} Real Real.hasLe (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))) (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n c x)
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (n : Nat) (x : X), LE.le.{0} Real Real.instLEReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)) (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n c x)
Case conversion may be inaccurate. Consider using '#align urysohns.CU.approx_nonneg Urysohns.CU.approx_nonnegₓ'. -/
theorem approx_nonneg (c : CU X) (n : ℕ) (x : X) : 0 ≤ c.approx n x :=
  by
  induction' n with n ihn generalizing c
  · exact indicator_nonneg (fun _ _ => zero_le_one) _
  · simp only [approx, midpoint_eq_smul_add, invOf_eq_inv]
    refine' mul_nonneg (inv_nonneg.2 zero_le_two) (add_nonneg _ _) <;> apply ihn
#align urysohns.CU.approx_nonneg Urysohns.CU.approx_nonneg

/- warning: urysohns.CU.approx_le_one -> Urysohns.CU.approx_le_one is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (n : Nat) (x : X), LE.le.{0} Real Real.hasLe (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n c x) (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne)))
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (n : Nat) (x : X), LE.le.{0} Real Real.instLEReal (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n c x) (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal))
Case conversion may be inaccurate. Consider using '#align urysohns.CU.approx_le_one Urysohns.CU.approx_le_oneₓ'. -/
theorem approx_le_one (c : CU X) (n : ℕ) (x : X) : c.approx n x ≤ 1 :=
  by
  induction' n with n ihn generalizing c
  · exact indicator_apply_le' (fun _ => le_rfl) fun _ => zero_le_one
  · simp only [approx, midpoint_eq_smul_add, invOf_eq_inv, smul_eq_mul, ← div_eq_inv_mul]
    refine' Iff.mpr (div_le_one zero_lt_two) (add_le_add _ _) <;> apply ihn
#align urysohns.CU.approx_le_one Urysohns.CU.approx_le_one

#print Urysohns.CU.bddAbove_range_approx /-
theorem bddAbove_range_approx (c : CU X) (x : X) : BddAbove (range fun n => c.approx n x) :=
  ⟨1, fun y ⟨n, hn⟩ => hn ▸ c.approx_le_one n x⟩
#align urysohns.CU.bdd_above_range_approx Urysohns.CU.bddAbove_range_approx
-/

/- warning: urysohns.CU.approx_le_approx_of_U_sub_C -> Urysohns.CU.approx_le_approx_of_U_sub_C is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] {c₁ : Urysohns.CU.{u1} X _inst_1} {c₂ : Urysohns.CU.{u1} X _inst_1}, (HasSubset.Subset.{u1} (Set.{u1} X) (Set.hasSubset.{u1} X) (Urysohns.CU.u.{u1} X _inst_1 c₁) (Urysohns.CU.c.{u1} X _inst_1 c₂)) -> (forall (n₁ : Nat) (n₂ : Nat) (x : X), LE.le.{0} Real Real.hasLe (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n₂ c₂ x) (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n₁ c₁ x))
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] {c₁ : Urysohns.CU.{u1} X _inst_1} {c₂ : Urysohns.CU.{u1} X _inst_1}, (HasSubset.Subset.{u1} (Set.{u1} X) (Set.instHasSubsetSet.{u1} X) (Urysohns.CU.U.{u1} X _inst_1 c₁) (Urysohns.CU.C.{u1} X _inst_1 c₂)) -> (forall (n₁ : Nat) (n₂ : Nat) (x : X), LE.le.{0} Real Real.instLEReal (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n₂ c₂ x) (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n₁ c₁ x))
Case conversion may be inaccurate. Consider using '#align urysohns.CU.approx_le_approx_of_U_sub_C Urysohns.CU.approx_le_approx_of_U_sub_Cₓ'. -/
theorem approx_le_approx_of_U_sub_C {c₁ c₂ : CU X} (h : c₁.U ⊆ c₂.C) (n₁ n₂ : ℕ) (x : X) :
    c₂.approx n₂ x ≤ c₁.approx n₁ x :=
  by
  by_cases hx : x ∈ c₁.U
  ·
    calc
      approx n₂ c₂ x = 0 := approx_of_mem_C _ _ (h hx)
      _ ≤ approx n₁ c₁ x := approx_nonneg _ _ _
      
  ·
    calc
      approx n₂ c₂ x ≤ 1 := approx_le_one _ _ _
      _ = approx n₁ c₁ x := (approx_of_nmem_U _ _ hx).symm
      
#align urysohns.CU.approx_le_approx_of_U_sub_C Urysohns.CU.approx_le_approx_of_U_sub_C

#print Urysohns.CU.approx_mem_Icc_right_left /-
theorem approx_mem_Icc_right_left (c : CU X) (n : ℕ) (x : X) :
    c.approx n x ∈ Icc (c.right.approx n x) (c.left.approx n x) :=
  by
  induction' n with n ihn generalizing c
  ·
    exact
      ⟨le_rfl,
        indicator_le_indicator_of_subset (compl_subset_compl.2 c.left_U_subset)
          (fun _ => zero_le_one) _⟩
  · simp only [approx, mem_Icc]
    refine' ⟨midpoint_le_midpoint _ (ihn _).1, midpoint_le_midpoint (ihn _).2 _⟩ <;>
      apply approx_le_approx_of_U_sub_C
    exacts[subset_closure, subset_closure]
#align urysohns.CU.approx_mem_Icc_right_left Urysohns.CU.approx_mem_Icc_right_left
-/

/- warning: urysohns.CU.approx_le_succ -> Urysohns.CU.approx_le_succ is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (n : Nat) (x : X), LE.le.{0} Real Real.hasLe (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n c x) (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))) c x)
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (n : Nat) (x : X), LE.le.{0} Real Real.instLEReal (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n c x) (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))) c x)
Case conversion may be inaccurate. Consider using '#align urysohns.CU.approx_le_succ Urysohns.CU.approx_le_succₓ'. -/
theorem approx_le_succ (c : CU X) (n : ℕ) (x : X) : c.approx n x ≤ c.approx (n + 1) x :=
  by
  induction' n with n ihn generalizing c
  · simp only [approx, right_U, right_le_midpoint]
    exact (approx_mem_Icc_right_left c 0 x).2
  · rw [approx, approx]
    exact midpoint_le_midpoint (ihn _) (ihn _)
#align urysohns.CU.approx_le_succ Urysohns.CU.approx_le_succ

#print Urysohns.CU.approx_mono /-
theorem approx_mono (c : CU X) (x : X) : Monotone fun n => c.approx n x :=
  monotone_nat_of_le_succ fun n => c.approx_le_succ n x
#align urysohns.CU.approx_mono Urysohns.CU.approx_mono
-/

#print Urysohns.CU.lim /-
/-- A continuous function `f : X → ℝ` such that

* `0 ≤ f x ≤ 1` for all `x`;
* `f` equals zero on `c.C` and equals one outside of `c.U`;
-/
protected noncomputable def lim (c : CU X) (x : X) : ℝ :=
  ⨆ n, c.approx n x
#align urysohns.CU.lim Urysohns.CU.lim
-/

#print Urysohns.CU.tendsto_approx_atTop /-
theorem tendsto_approx_atTop (c : CU X) (x : X) :
    Tendsto (fun n => c.approx n x) atTop (𝓝 <| c.lim x) :=
  tendsto_atTop_csupᵢ (c.approx_mono x) ⟨1, fun x ⟨n, hn⟩ => hn ▸ c.approx_le_one _ _⟩
#align urysohns.CU.tendsto_approx_at_top Urysohns.CU.tendsto_approx_atTop
-/

/- warning: urysohns.CU.lim_of_mem_C -> Urysohns.CU.lim_of_mem_C is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (x : X), (Membership.Mem.{u1, u1} X (Set.{u1} X) (Set.hasMem.{u1} X) x (Urysohns.CU.c.{u1} X _inst_1 c)) -> (Eq.{1} Real (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 c x) (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))))
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (x : X), (Membership.mem.{u1, u1} X (Set.{u1} X) (Set.instMembershipSet.{u1} X) x (Urysohns.CU.C.{u1} X _inst_1 c)) -> (Eq.{1} Real (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 c x) (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)))
Case conversion may be inaccurate. Consider using '#align urysohns.CU.lim_of_mem_C Urysohns.CU.lim_of_mem_Cₓ'. -/
theorem lim_of_mem_C (c : CU X) (x : X) (h : x ∈ c.C) : c.lim x = 0 := by
  simp only [CU.lim, approx_of_mem_C, h, csupᵢ_const]
#align urysohns.CU.lim_of_mem_C Urysohns.CU.lim_of_mem_C

/- warning: urysohns.CU.lim_of_nmem_U -> Urysohns.CU.lim_of_nmem_U is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (x : X), (Not (Membership.Mem.{u1, u1} X (Set.{u1} X) (Set.hasMem.{u1} X) x (Urysohns.CU.u.{u1} X _inst_1 c))) -> (Eq.{1} Real (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 c x) (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne))))
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (x : X), (Not (Membership.mem.{u1, u1} X (Set.{u1} X) (Set.instMembershipSet.{u1} X) x (Urysohns.CU.U.{u1} X _inst_1 c))) -> (Eq.{1} Real (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 c x) (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal)))
Case conversion may be inaccurate. Consider using '#align urysohns.CU.lim_of_nmem_U Urysohns.CU.lim_of_nmem_Uₓ'. -/
theorem lim_of_nmem_U (c : CU X) (x : X) (h : x ∉ c.U) : c.lim x = 1 := by
  simp only [CU.lim, approx_of_nmem_U c _ h, csupᵢ_const]
#align urysohns.CU.lim_of_nmem_U Urysohns.CU.lim_of_nmem_U

/- warning: urysohns.CU.lim_eq_midpoint -> Urysohns.CU.lim_eq_midpoint is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (x : X), Eq.{1} Real (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 c x) (midpoint.{0, 0, 0} Real Real Real Real.ring (invertibleTwo.{0} Real Real.divisionRing (StrictOrderedSemiring.to_charZero.{0} Real Real.strictOrderedSemiring)) Real.addCommGroup Real.module (addGroupIsAddTorsor.{0} Real Real.addGroup) (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 (Urysohns.CU.left.{u1} X _inst_1 _inst_2 c) x) (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 (Urysohns.CU.right.{u1} X _inst_1 _inst_2 c) x))
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (x : X), Eq.{1} Real (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 c x) (midpoint.{0, 0, 0} Real Real Real Real.instRingReal (invertibleTwo.{0} Real Real.instDivisionRingReal (StrictOrderedSemiring.to_charZero.{0} Real Real.strictOrderedSemiring)) Real.instAddCommGroupReal instModuleRealSemiringInstAddCommMonoidReal (NormedAddTorsor.toAddTorsor.{0, 0} Real Real (NonUnitalSeminormedRing.toSeminormedAddCommGroup.{0} Real (NonUnitalNormedRing.toNonUnitalSeminormedRing.{0} Real (NormedRing.toNonUnitalNormedRing.{0} Real (NormedCommRing.toNormedRing.{0} Real Real.normedCommRing)))) Real.pseudoMetricSpace (SeminormedAddCommGroup.toNormedAddTorsor.{0} Real (NonUnitalSeminormedRing.toSeminormedAddCommGroup.{0} Real (NonUnitalNormedRing.toNonUnitalSeminormedRing.{0} Real (NormedRing.toNonUnitalNormedRing.{0} Real (NormedCommRing.toNormedRing.{0} Real Real.normedCommRing)))))) (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 (Urysohns.CU.left.{u1} X _inst_1 _inst_2 c) x) (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 (Urysohns.CU.right.{u1} X _inst_1 _inst_2 c) x))
Case conversion may be inaccurate. Consider using '#align urysohns.CU.lim_eq_midpoint Urysohns.CU.lim_eq_midpointₓ'. -/
theorem lim_eq_midpoint (c : CU X) (x : X) : c.lim x = midpoint ℝ (c.left.lim x) (c.right.lim x) :=
  by
  refine' tendsto_nhds_unique (c.tendsto_approx_at_top x) ((tendsto_add_at_top_iff_nat 1).1 _)
  simp only [approx]
  exact (c.left.tendsto_approx_at_top x).midpoint (c.right.tendsto_approx_at_top x)
#align urysohns.CU.lim_eq_midpoint Urysohns.CU.lim_eq_midpoint

/- warning: urysohns.CU.approx_le_lim -> Urysohns.CU.approx_le_lim is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (x : X) (n : Nat), LE.le.{0} Real Real.hasLe (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n c x) (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 c x)
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (x : X) (n : Nat), LE.le.{0} Real Real.instLEReal (Urysohns.CU.approx.{u1} X _inst_1 _inst_2 n c x) (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 c x)
Case conversion may be inaccurate. Consider using '#align urysohns.CU.approx_le_lim Urysohns.CU.approx_le_limₓ'. -/
theorem approx_le_lim (c : CU X) (x : X) (n : ℕ) : c.approx n x ≤ c.lim x :=
  le_csupᵢ (c.bddAbove_range_approx x) _
#align urysohns.CU.approx_le_lim Urysohns.CU.approx_le_lim

/- warning: urysohns.CU.lim_nonneg -> Urysohns.CU.lim_nonneg is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (x : X), LE.le.{0} Real Real.hasLe (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))) (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 c x)
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (x : X), LE.le.{0} Real Real.instLEReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)) (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 c x)
Case conversion may be inaccurate. Consider using '#align urysohns.CU.lim_nonneg Urysohns.CU.lim_nonnegₓ'. -/
theorem lim_nonneg (c : CU X) (x : X) : 0 ≤ c.lim x :=
  (c.approx_nonneg 0 x).trans (c.approx_le_lim x 0)
#align urysohns.CU.lim_nonneg Urysohns.CU.lim_nonneg

/- warning: urysohns.CU.lim_le_one -> Urysohns.CU.lim_le_one is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (x : X), LE.le.{0} Real Real.hasLe (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 c x) (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne)))
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (x : X), LE.le.{0} Real Real.instLEReal (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 c x) (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal))
Case conversion may be inaccurate. Consider using '#align urysohns.CU.lim_le_one Urysohns.CU.lim_le_oneₓ'. -/
theorem lim_le_one (c : CU X) (x : X) : c.lim x ≤ 1 :=
  csupᵢ_le fun n => c.approx_le_one _ _
#align urysohns.CU.lim_le_one Urysohns.CU.lim_le_one

/- warning: urysohns.CU.lim_mem_Icc -> Urysohns.CU.lim_mem_Icc is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (x : X), Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 c x) (Set.Icc.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))) (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne))))
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] (c : Urysohns.CU.{u1} X _inst_1) (x : X), Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) (Urysohns.CU.lim.{u1} X _inst_1 _inst_2 c x) (Set.Icc.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)) (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal)))
Case conversion may be inaccurate. Consider using '#align urysohns.CU.lim_mem_Icc Urysohns.CU.lim_mem_Iccₓ'. -/
theorem lim_mem_Icc (c : CU X) (x : X) : c.lim x ∈ Icc (0 : ℝ) 1 :=
  ⟨c.lim_nonneg x, c.lim_le_one x⟩
#align urysohns.CU.lim_mem_Icc Urysohns.CU.lim_mem_Icc

#print Urysohns.CU.continuous_lim /-
/-- Continuity of `urysohns.CU.lim`. See module docstring for a sketch of the proofs. -/
theorem continuous_lim (c : CU X) : Continuous c.lim :=
  by
  obtain ⟨h0, h1234, h1⟩ : 0 < (2⁻¹ : ℝ) ∧ (2⁻¹ : ℝ) < 3 / 4 ∧ (3 / 4 : ℝ) < 1 := by norm_num
  refine'
    continuous_iff_continuousAt.2 fun x =>
      (Metric.nhds_basis_closedBall_pow (h0.trans h1234) h1).tendsto_right_iff.2 fun n _ => _
  simp only [Metric.mem_closedBall]
  induction' n with n ihn generalizing c
  · refine' eventually_of_forall fun y => _
    rw [pow_zero]
    exact Real.dist_le_of_mem_Icc_01 (c.lim_mem_Icc _) (c.lim_mem_Icc _)
  · by_cases hxl : x ∈ c.left.U
    · filter_upwards [IsOpen.mem_nhds c.left.open_U hxl, ihn c.left]with _ hyl hyd
      rw [pow_succ, c.lim_eq_midpoint, c.lim_eq_midpoint,
        c.right.lim_of_mem_C _ (c.left_U_subset_right_C hyl),
        c.right.lim_of_mem_C _ (c.left_U_subset_right_C hxl)]
      refine' (dist_midpoint_midpoint_le _ _ _ _).trans _
      rw [dist_self, add_zero, div_eq_inv_mul]
      exact mul_le_mul h1234.le hyd dist_nonneg (h0.trans h1234).le
    · replace hxl : x ∈ c.left.right.Cᶜ
      exact compl_subset_compl.2 c.left.right.subset hxl
      filter_upwards [IsOpen.mem_nhds (isOpen_compl_iff.2 c.left.right.closed_C) hxl,
        ihn c.left.right, ihn c.right]with y hyl hydl hydr
      replace hxl : x ∉ c.left.left.U
      exact compl_subset_compl.2 c.left.left_U_subset_right_C hxl
      replace hyl : y ∉ c.left.left.U
      exact compl_subset_compl.2 c.left.left_U_subset_right_C hyl
      simp only [pow_succ, c.lim_eq_midpoint, c.left.lim_eq_midpoint,
        c.left.left.lim_of_nmem_U _ hxl, c.left.left.lim_of_nmem_U _ hyl]
      refine' (dist_midpoint_midpoint_le _ _ _ _).trans _
      refine'
        (div_le_div_of_le_of_nonneg (add_le_add_right (dist_midpoint_midpoint_le _ _ _ _) _)
              zero_le_two).trans
          _
      rw [dist_self, zero_add]
      refine'
        (div_le_div_of_le_of_nonneg (add_le_add (div_le_div_of_le_of_nonneg hydl zero_le_two) hydr)
              zero_le_two).trans_eq
          _
      generalize (3 / 4 : ℝ) ^ n = r
      field_simp [two_ne_zero' ℝ]
      ring
#align urysohns.CU.continuous_lim Urysohns.CU.continuous_lim
-/

end CU

end Urysohns

variable [NormalSpace X]

/- warning: exists_continuous_zero_one_of_closed -> exists_continuous_zero_one_of_closed is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] {s : Set.{u1} X} {t : Set.{u1} X}, (IsClosed.{u1} X _inst_1 s) -> (IsClosed.{u1} X _inst_1 t) -> (Disjoint.{u1} (Set.{u1} X) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} X) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} X) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} X) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} X) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} X) (Set.completeBooleanAlgebra.{u1} X)))))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} (Set.{u1} X) (BooleanAlgebra.toGeneralizedBooleanAlgebra.{u1} (Set.{u1} X) (Set.booleanAlgebra.{u1} X))) s t) -> (Exists.{succ u1} (ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (fun (f : ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) => And (Set.EqOn.{u1, 0} X Real (coeFn.{succ u1, succ u1} (ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (fun (_x : ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) => X -> Real) (ContinuousMap.hasCoeToFun.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) f) (OfNat.ofNat.{u1} (X -> Real) 0 (OfNat.mk.{u1} (X -> Real) 0 (Zero.zero.{u1} (X -> Real) (Pi.instZero.{u1, 0} X (fun (ᾰ : X) => Real) (fun (i : X) => Real.hasZero))))) s) (And (Set.EqOn.{u1, 0} X Real (coeFn.{succ u1, succ u1} (ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (fun (_x : ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) => X -> Real) (ContinuousMap.hasCoeToFun.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) f) (OfNat.ofNat.{u1} (X -> Real) 1 (OfNat.mk.{u1} (X -> Real) 1 (One.one.{u1} (X -> Real) (Pi.instOne.{u1, 0} X (fun (ᾰ : X) => Real) (fun (i : X) => Real.hasOne))))) t) (forall (x : X), Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) (coeFn.{succ u1, succ u1} (ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (fun (_x : ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) => X -> Real) (ContinuousMap.hasCoeToFun.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) f x) (Set.Icc.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))) (OfNat.ofNat.{0} Real 1 (OfNat.mk.{0} Real 1 (One.one.{0} Real Real.hasOne))))))))
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] [_inst_2 : NormalSpace.{u1} X _inst_1] {s : Set.{u1} X} {t : Set.{u1} X}, (IsClosed.{u1} X _inst_1 s) -> (IsClosed.{u1} X _inst_1 t) -> (Disjoint.{u1} (Set.{u1} X) (OmegaCompletePartialOrder.toPartialOrder.{u1} (Set.{u1} X) (CompleteLattice.instOmegaCompletePartialOrder.{u1} (Set.{u1} X) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} X) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} X) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} X) (Set.instCompleteBooleanAlgebraSet.{u1} X)))))) (BoundedOrder.toOrderBot.{u1} (Set.{u1} X) (Preorder.toLE.{u1} (Set.{u1} X) (PartialOrder.toPreorder.{u1} (Set.{u1} X) (OmegaCompletePartialOrder.toPartialOrder.{u1} (Set.{u1} X) (CompleteLattice.instOmegaCompletePartialOrder.{u1} (Set.{u1} X) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} X) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} X) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} X) (Set.instCompleteBooleanAlgebraSet.{u1} X)))))))) (CompleteLattice.toBoundedOrder.{u1} (Set.{u1} X) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} X) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} X) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} X) (Set.instCompleteBooleanAlgebraSet.{u1} X)))))) s t) -> (Exists.{succ u1} (ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (fun (f : ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) => And (Set.EqOn.{u1, 0} X Real (FunLike.coe.{succ u1, succ u1, 1} (ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) X (fun (_x : X) => (fun (x._@.Mathlib.Topology.ContinuousFunction.Basic._hyg.699 : X) => Real) _x) (ContinuousMapClass.toFunLike.{u1, u1, 0} (ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (ContinuousMap.instContinuousMapClassContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)))) f) (OfNat.ofNat.{u1} (X -> Real) 0 (Zero.toOfNat0.{u1} (X -> Real) (Pi.instZero.{u1, 0} X (fun (a._@.Mathlib.Data.Set.Function._hyg.1349 : X) => Real) (fun (i : X) => Real.instZeroReal)))) s) (And (Set.EqOn.{u1, 0} X Real (FunLike.coe.{succ u1, succ u1, 1} (ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) X (fun (_x : X) => (fun (x._@.Mathlib.Topology.ContinuousFunction.Basic._hyg.699 : X) => Real) _x) (ContinuousMapClass.toFunLike.{u1, u1, 0} (ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (ContinuousMap.instContinuousMapClassContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)))) f) (OfNat.ofNat.{u1} (X -> Real) 1 (One.toOfNat1.{u1} (X -> Real) (Pi.instOne.{u1, 0} X (fun (a._@.Mathlib.Data.Set.Function._hyg.1349 : X) => Real) (fun (i : X) => Real.instOneReal)))) t) (forall (x : X), Membership.mem.{0, 0} ((fun (x._@.Mathlib.Topology.ContinuousFunction.Basic._hyg.699 : X) => Real) x) (Set.{0} Real) (Set.instMembershipSet.{0} Real) (FunLike.coe.{succ u1, succ u1, 1} (ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) X (fun (_x : X) => (fun (x._@.Mathlib.Topology.ContinuousFunction.Basic._hyg.699 : X) => Real) _x) (ContinuousMapClass.toFunLike.{u1, u1, 0} (ContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (ContinuousMap.instContinuousMapClassContinuousMap.{u1, 0} X Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)))) f x) (Set.Icc.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)) (OfNat.ofNat.{0} Real 1 (One.toOfNat1.{0} Real Real.instOneReal)))))))
Case conversion may be inaccurate. Consider using '#align exists_continuous_zero_one_of_closed exists_continuous_zero_one_of_closedₓ'. -/
/-- Urysohns lemma: if `s` and `t` are two disjoint closed sets in a normal topological space `X`,
then there exists a continuous function `f : X → ℝ` such that

* `f` equals zero on `s`;
* `f` equals one on `t`;
* `0 ≤ f x ≤ 1` for all `x`.
-/
theorem exists_continuous_zero_one_of_closed {s t : Set X} (hs : IsClosed s) (ht : IsClosed t)
    (hd : Disjoint s t) : ∃ f : C(X, ℝ), EqOn f 0 s ∧ EqOn f 1 t ∧ ∀ x, f x ∈ Icc (0 : ℝ) 1 :=
  by
  -- The actual proof is in the code above. Here we just repack it into the expected format.
  set c : Urysohns.CU X := ⟨s, tᶜ, hs, ht.is_open_compl, disjoint_left.1 hd⟩
  exact
    ⟨⟨c.lim, c.continuous_lim⟩, c.lim_of_mem_C, fun x hx => c.lim_of_nmem_U _ fun h => h hx,
      c.lim_mem_Icc⟩
#align exists_continuous_zero_one_of_closed exists_continuous_zero_one_of_closed

