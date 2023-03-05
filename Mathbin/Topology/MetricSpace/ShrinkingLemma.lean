/-
Copyright (c) 2021 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module topology.metric_space.shrinking_lemma
! leanprover-community/mathlib commit f2ce6086713c78a7f880485f7917ea547a215982
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.MetricSpace.Basic
import Mathbin.Topology.MetricSpace.EmetricParacompact
import Mathbin.Topology.ShrinkingLemma

/-!
# Shrinking lemma in a proper metric space

In this file we prove a few versions of the shrinking lemma for coverings by balls in a proper
(pseudo) metric space.

## Tags

shrinking lemma, metric space
-/


universe u v

open Set Metric

open Topology

variable {α : Type u} {ι : Type v} [MetricSpace α] [ProperSpace α] {c : ι → α}

variable {x : α} {r : ℝ} {s : Set α}

/- warning: exists_subset_Union_ball_radius_lt -> exists_subset_unionᵢ_ball_radius_lt is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {ι : Type.{u2}} [_inst_1 : MetricSpace.{u1} α] [_inst_2 : ProperSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1)] {c : ι -> α} {s : Set.{u1} α} {r : ι -> Real}, (IsClosed.{u1} α (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1))) s) -> (forall (x : α), (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) -> (Set.Finite.{u2} ι (setOf.{u2} ι (fun (i : ι) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x (Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i)))))) -> (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) s (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i)))) -> (Exists.{succ u2} (ι -> Real) (fun (r' : ι -> Real) => And (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) s (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r' i)))) (forall (i : ι), LT.lt.{0} Real Real.hasLt (r' i) (r i))))
but is expected to have type
  forall {α : Type.{u1}} {ι : Type.{u2}} [_inst_1 : MetricSpace.{u1} α] [_inst_2 : ProperSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1)] {c : ι -> α} {s : Set.{u1} α} {r : ι -> Real}, (IsClosed.{u1} α (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1))) s) -> (forall (x : α), (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) -> (Set.Finite.{u2} ι (setOf.{u2} ι (fun (i : ι) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i)))))) -> (HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) s (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i)))) -> (Exists.{succ u2} (ι -> Real) (fun (r' : ι -> Real) => And (HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) s (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r' i)))) (forall (i : ι), LT.lt.{0} Real Real.instLTReal (r' i) (r i))))
Case conversion may be inaccurate. Consider using '#align exists_subset_Union_ball_radius_lt exists_subset_unionᵢ_ball_radius_ltₓ'. -/
/-- Shrinking lemma for coverings by open balls in a proper metric space. A point-finite open cover
of a closed subset of a proper metric space by open balls can be shrunk to a new cover by open balls
so that each of the new balls has strictly smaller radius than the old one. This version assumes
that `λ x, ball (c i) (r i)` is a locally finite covering and provides a covering indexed by the
same type. -/
theorem exists_subset_unionᵢ_ball_radius_lt {r : ι → ℝ} (hs : IsClosed s)
    (uf : ∀ x ∈ s, { i | x ∈ ball (c i) (r i) }.Finite) (us : s ⊆ ⋃ i, ball (c i) (r i)) :
    ∃ r' : ι → ℝ, (s ⊆ ⋃ i, ball (c i) (r' i)) ∧ ∀ i, r' i < r i :=
  by
  rcases exists_subset_unionᵢ_closed_subset hs (fun i => @is_open_ball _ _ (c i) (r i)) uf us with
    ⟨v, hsv, hvc, hcv⟩
  have := fun i => exists_lt_subset_ball (hvc i) (hcv i)
  choose r' hlt hsub
  exact ⟨r', hsv.trans <| Union_mono <| hsub, hlt⟩
#align exists_subset_Union_ball_radius_lt exists_subset_unionᵢ_ball_radius_lt

/- warning: exists_Union_ball_eq_radius_lt -> exists_unionᵢ_ball_eq_radius_lt is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {ι : Type.{u2}} [_inst_1 : MetricSpace.{u1} α] [_inst_2 : ProperSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1)] {c : ι -> α} {r : ι -> Real}, (forall (x : α), Set.Finite.{u2} ι (setOf.{u2} ι (fun (i : ι) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x (Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i))))) -> (Eq.{succ u1} (Set.{u1} α) (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i))) (Set.univ.{u1} α)) -> (Exists.{succ u2} (ι -> Real) (fun (r' : ι -> Real) => And (Eq.{succ u1} (Set.{u1} α) (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r' i))) (Set.univ.{u1} α)) (forall (i : ι), LT.lt.{0} Real Real.hasLt (r' i) (r i))))
but is expected to have type
  forall {α : Type.{u1}} {ι : Type.{u2}} [_inst_1 : MetricSpace.{u1} α] [_inst_2 : ProperSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1)] {c : ι -> α} {r : ι -> Real}, (forall (x : α), Set.Finite.{u2} ι (setOf.{u2} ι (fun (i : ι) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i))))) -> (Eq.{succ u1} (Set.{u1} α) (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i))) (Set.univ.{u1} α)) -> (Exists.{succ u2} (ι -> Real) (fun (r' : ι -> Real) => And (Eq.{succ u1} (Set.{u1} α) (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r' i))) (Set.univ.{u1} α)) (forall (i : ι), LT.lt.{0} Real Real.instLTReal (r' i) (r i))))
Case conversion may be inaccurate. Consider using '#align exists_Union_ball_eq_radius_lt exists_unionᵢ_ball_eq_radius_ltₓ'. -/
/-- Shrinking lemma for coverings by open balls in a proper metric space. A point-finite open cover
of a proper metric space by open balls can be shrunk to a new cover by open balls so that each of
the new balls has strictly smaller radius than the old one. -/
theorem exists_unionᵢ_ball_eq_radius_lt {r : ι → ℝ} (uf : ∀ x, { i | x ∈ ball (c i) (r i) }.Finite)
    (uU : (⋃ i, ball (c i) (r i)) = univ) :
    ∃ r' : ι → ℝ, (⋃ i, ball (c i) (r' i)) = univ ∧ ∀ i, r' i < r i :=
  let ⟨r', hU, hv⟩ := exists_subset_unionᵢ_ball_radius_lt isClosed_univ (fun x _ => uf x) uU.ge
  ⟨r', univ_subset_iff.1 hU, hv⟩
#align exists_Union_ball_eq_radius_lt exists_unionᵢ_ball_eq_radius_lt

/- warning: exists_subset_Union_ball_radius_pos_lt -> exists_subset_unionᵢ_ball_radius_pos_lt is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {ι : Type.{u2}} [_inst_1 : MetricSpace.{u1} α] [_inst_2 : ProperSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1)] {c : ι -> α} {s : Set.{u1} α} {r : ι -> Real}, (forall (i : ι), LT.lt.{0} Real Real.hasLt (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))) (r i)) -> (IsClosed.{u1} α (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1))) s) -> (forall (x : α), (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) -> (Set.Finite.{u2} ι (setOf.{u2} ι (fun (i : ι) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x (Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i)))))) -> (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) s (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i)))) -> (Exists.{succ u2} (ι -> Real) (fun (r' : ι -> Real) => And (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) s (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r' i)))) (forall (i : ι), Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) (r' i) (Set.Ioo.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))) (r i)))))
but is expected to have type
  forall {α : Type.{u1}} {ι : Type.{u2}} [_inst_1 : MetricSpace.{u1} α] [_inst_2 : ProperSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1)] {c : ι -> α} {s : Set.{u1} α} {r : ι -> Real}, (forall (i : ι), LT.lt.{0} Real Real.instLTReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)) (r i)) -> (IsClosed.{u1} α (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1))) s) -> (forall (x : α), (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) -> (Set.Finite.{u2} ι (setOf.{u2} ι (fun (i : ι) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i)))))) -> (HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) s (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i)))) -> (Exists.{succ u2} (ι -> Real) (fun (r' : ι -> Real) => And (HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) s (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r' i)))) (forall (i : ι), Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) (r' i) (Set.Ioo.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)) (r i)))))
Case conversion may be inaccurate. Consider using '#align exists_subset_Union_ball_radius_pos_lt exists_subset_unionᵢ_ball_radius_pos_ltₓ'. -/
/-- Shrinking lemma for coverings by open balls in a proper metric space. A point-finite open cover
of a closed subset of a proper metric space by nonempty open balls can be shrunk to a new cover by
nonempty open balls so that each of the new balls has strictly smaller radius than the old one. -/
theorem exists_subset_unionᵢ_ball_radius_pos_lt {r : ι → ℝ} (hr : ∀ i, 0 < r i) (hs : IsClosed s)
    (uf : ∀ x ∈ s, { i | x ∈ ball (c i) (r i) }.Finite) (us : s ⊆ ⋃ i, ball (c i) (r i)) :
    ∃ r' : ι → ℝ, (s ⊆ ⋃ i, ball (c i) (r' i)) ∧ ∀ i, r' i ∈ Ioo 0 (r i) :=
  by
  rcases exists_subset_unionᵢ_closed_subset hs (fun i => @is_open_ball _ _ (c i) (r i)) uf us with
    ⟨v, hsv, hvc, hcv⟩
  have := fun i => exists_pos_lt_subset_ball (hr i) (hvc i) (hcv i)
  choose r' hlt hsub
  exact ⟨r', hsv.trans <| Union_mono hsub, hlt⟩
#align exists_subset_Union_ball_radius_pos_lt exists_subset_unionᵢ_ball_radius_pos_lt

/- warning: exists_Union_ball_eq_radius_pos_lt -> exists_unionᵢ_ball_eq_radius_pos_lt is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {ι : Type.{u2}} [_inst_1 : MetricSpace.{u1} α] [_inst_2 : ProperSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1)] {c : ι -> α} {r : ι -> Real}, (forall (i : ι), LT.lt.{0} Real Real.hasLt (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))) (r i)) -> (forall (x : α), Set.Finite.{u2} ι (setOf.{u2} ι (fun (i : ι) => Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x (Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i))))) -> (Eq.{succ u1} (Set.{u1} α) (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i))) (Set.univ.{u1} α)) -> (Exists.{succ u2} (ι -> Real) (fun (r' : ι -> Real) => And (Eq.{succ u1} (Set.{u1} α) (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r' i))) (Set.univ.{u1} α)) (forall (i : ι), Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) (r' i) (Set.Ioo.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))) (r i)))))
but is expected to have type
  forall {α : Type.{u1}} {ι : Type.{u2}} [_inst_1 : MetricSpace.{u1} α] [_inst_2 : ProperSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1)] {c : ι -> α} {r : ι -> Real}, (forall (i : ι), LT.lt.{0} Real Real.instLTReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)) (r i)) -> (forall (x : α), Set.Finite.{u2} ι (setOf.{u2} ι (fun (i : ι) => Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x (Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i))))) -> (Eq.{succ u1} (Set.{u1} α) (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i))) (Set.univ.{u1} α)) -> (Exists.{succ u2} (ι -> Real) (fun (r' : ι -> Real) => And (Eq.{succ u1} (Set.{u1} α) (Set.unionᵢ.{u1, succ u2} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r' i))) (Set.univ.{u1} α)) (forall (i : ι), Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) (r' i) (Set.Ioo.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)) (r i)))))
Case conversion may be inaccurate. Consider using '#align exists_Union_ball_eq_radius_pos_lt exists_unionᵢ_ball_eq_radius_pos_ltₓ'. -/
/-- Shrinking lemma for coverings by open balls in a proper metric space. A point-finite open cover
of a proper metric space by nonempty open balls can be shrunk to a new cover by nonempty open balls
so that each of the new balls has strictly smaller radius than the old one. -/
theorem exists_unionᵢ_ball_eq_radius_pos_lt {r : ι → ℝ} (hr : ∀ i, 0 < r i)
    (uf : ∀ x, { i | x ∈ ball (c i) (r i) }.Finite) (uU : (⋃ i, ball (c i) (r i)) = univ) :
    ∃ r' : ι → ℝ, (⋃ i, ball (c i) (r' i)) = univ ∧ ∀ i, r' i ∈ Ioo 0 (r i) :=
  let ⟨r', hU, hv⟩ :=
    exists_subset_unionᵢ_ball_radius_pos_lt hr isClosed_univ (fun x _ => uf x) uU.ge
  ⟨r', univ_subset_iff.1 hU, hv⟩
#align exists_Union_ball_eq_radius_pos_lt exists_unionᵢ_ball_eq_radius_pos_lt

/- warning: exists_locally_finite_subset_Union_ball_radius_lt -> exists_locallyFinite_subset_unionᵢ_ball_radius_lt is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : MetricSpace.{u1} α] [_inst_2 : ProperSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1)] {s : Set.{u1} α}, (IsClosed.{u1} α (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1))) s) -> (forall {R : α -> Real}, (forall (x : α), (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) -> (LT.lt.{0} Real Real.hasLt (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))) (R x))) -> (Exists.{succ (succ u1)} Type.{u1} (fun (ι : Type.{u1}) => Exists.{succ u1} (ι -> α) (fun (c : ι -> α) => Exists.{succ u1} (ι -> Real) (fun (r : ι -> Real) => Exists.{succ u1} (ι -> Real) (fun (r' : ι -> Real) => And (forall (i : ι), And (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) (c i) s) (And (LT.lt.{0} Real Real.hasLt (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))) (r i)) (And (LT.lt.{0} Real Real.hasLt (r i) (r' i)) (LT.lt.{0} Real Real.hasLt (r' i) (R (c i)))))) (And (LocallyFinite.{u1, u1} ι α (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1))) (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r' i))) (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) s (Set.unionᵢ.{u1, succ u1} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i)))))))))))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : MetricSpace.{u1} α] [_inst_2 : ProperSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1)] {s : Set.{u1} α}, (IsClosed.{u1} α (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1))) s) -> (forall {R : α -> Real}, (forall (x : α), (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) -> (LT.lt.{0} Real Real.instLTReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)) (R x))) -> (Exists.{succ (succ u1)} Type.{u1} (fun (ι : Type.{u1}) => Exists.{succ u1} (ι -> α) (fun (c : ι -> α) => Exists.{succ u1} (ι -> Real) (fun (r : ι -> Real) => Exists.{succ u1} (ι -> Real) (fun (r' : ι -> Real) => And (forall (i : ι), And (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) (c i) s) (And (LT.lt.{0} Real Real.instLTReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)) (r i)) (And (LT.lt.{0} Real Real.instLTReal (r i) (r' i)) (LT.lt.{0} Real Real.instLTReal (r' i) (R (c i)))))) (And (LocallyFinite.{u1, u1} ι α (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1))) (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r' i))) (HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) s (Set.unionᵢ.{u1, succ u1} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i)))))))))))
Case conversion may be inaccurate. Consider using '#align exists_locally_finite_subset_Union_ball_radius_lt exists_locallyFinite_subset_unionᵢ_ball_radius_ltₓ'. -/
/-- Let `R : α → ℝ` be a (possibly discontinuous) function on a proper metric space.
Let `s` be a closed set in `α` such that `R` is positive on `s`. Then there exists a collection of
pairs of balls `metric.ball (c i) (r i)`, `metric.ball (c i) (r' i)` such that

* all centers belong to `s`;
* for all `i` we have `0 < r i < r' i < R (c i)`;
* the family of balls `metric.ball (c i) (r' i)` is locally finite;
* the balls `metric.ball (c i) (r i)` cover `s`.

This is a simple corollary of `refinement_of_locally_compact_sigma_compact_of_nhds_basis_set`
and `exists_subset_Union_ball_radius_pos_lt`. -/
theorem exists_locallyFinite_subset_unionᵢ_ball_radius_lt (hs : IsClosed s) {R : α → ℝ}
    (hR : ∀ x ∈ s, 0 < R x) :
    ∃ (ι : Type u)(c : ι → α)(r r' : ι → ℝ),
      (∀ i, c i ∈ s ∧ 0 < r i ∧ r i < r' i ∧ r' i < R (c i)) ∧
        (LocallyFinite fun i => ball (c i) (r' i)) ∧ s ⊆ ⋃ i, ball (c i) (r i) :=
  by
  have : ∀ x ∈ s, (𝓝 x).HasBasis (fun r : ℝ => 0 < r ∧ r < R x) fun r => ball x r := fun x hx =>
    nhds_basis_uniformity (uniformity_basis_dist_lt (hR x hx))
  rcases refinement_of_locallyCompact_sigmaCompact_of_nhds_basis_set hs this with
    ⟨ι, c, r', hr', hsub', hfin⟩
  rcases exists_subset_unionᵢ_ball_radius_pos_lt (fun i => (hr' i).2.1) hs
      (fun x hx => hfin.point_finite x) hsub' with
    ⟨r, hsub, hlt⟩
  exact ⟨ι, c, r, r', fun i => ⟨(hr' i).1, (hlt i).1, (hlt i).2, (hr' i).2.2⟩, hfin, hsub⟩
#align exists_locally_finite_subset_Union_ball_radius_lt exists_locallyFinite_subset_unionᵢ_ball_radius_lt

/- warning: exists_locally_finite_Union_eq_ball_radius_lt -> exists_locallyFinite_unionᵢ_eq_ball_radius_lt is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : MetricSpace.{u1} α] [_inst_2 : ProperSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1)] {R : α -> Real}, (forall (x : α), LT.lt.{0} Real Real.hasLt (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))) (R x)) -> (Exists.{succ (succ u1)} Type.{u1} (fun (ι : Type.{u1}) => Exists.{succ u1} (ι -> α) (fun (c : ι -> α) => Exists.{succ u1} (ι -> Real) (fun (r : ι -> Real) => Exists.{succ u1} (ι -> Real) (fun (r' : ι -> Real) => And (forall (i : ι), And (LT.lt.{0} Real Real.hasLt (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))) (r i)) (And (LT.lt.{0} Real Real.hasLt (r i) (r' i)) (LT.lt.{0} Real Real.hasLt (r' i) (R (c i))))) (And (LocallyFinite.{u1, u1} ι α (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1))) (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r' i))) (Eq.{succ u1} (Set.{u1} α) (Set.unionᵢ.{u1, succ u1} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i))) (Set.univ.{u1} α))))))))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : MetricSpace.{u1} α] [_inst_2 : ProperSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1)] {R : α -> Real}, (forall (x : α), LT.lt.{0} Real Real.instLTReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)) (R x)) -> (Exists.{succ (succ u1)} Type.{u1} (fun (ι : Type.{u1}) => Exists.{succ u1} (ι -> α) (fun (c : ι -> α) => Exists.{succ u1} (ι -> Real) (fun (r : ι -> Real) => Exists.{succ u1} (ι -> Real) (fun (r' : ι -> Real) => And (forall (i : ι), And (LT.lt.{0} Real Real.instLTReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)) (r i)) (And (LT.lt.{0} Real Real.instLTReal (r i) (r' i)) (LT.lt.{0} Real Real.instLTReal (r' i) (R (c i))))) (And (LocallyFinite.{u1, u1} ι α (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1))) (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r' i))) (Eq.{succ u1} (Set.{u1} α) (Set.unionᵢ.{u1, succ u1} α ι (fun (i : ι) => Metric.ball.{u1} α (MetricSpace.toPseudoMetricSpace.{u1} α _inst_1) (c i) (r i))) (Set.univ.{u1} α))))))))
Case conversion may be inaccurate. Consider using '#align exists_locally_finite_Union_eq_ball_radius_lt exists_locallyFinite_unionᵢ_eq_ball_radius_ltₓ'. -/
/-- Let `R : α → ℝ` be a (possibly discontinuous) positive function on a proper metric space. Then
there exists a collection of pairs of balls `metric.ball (c i) (r i)`, `metric.ball (c i) (r' i)`
such that

* for all `i` we have `0 < r i < r' i < R (c i)`;
* the family of balls `metric.ball (c i) (r' i)` is locally finite;
* the balls `metric.ball (c i) (r i)` cover the whole space.

This is a simple corollary of `refinement_of_locally_compact_sigma_compact_of_nhds_basis`
and `exists_Union_ball_eq_radius_pos_lt` or `exists_locally_finite_subset_Union_ball_radius_lt`. -/
theorem exists_locallyFinite_unionᵢ_eq_ball_radius_lt {R : α → ℝ} (hR : ∀ x, 0 < R x) :
    ∃ (ι : Type u)(c : ι → α)(r r' : ι → ℝ),
      (∀ i, 0 < r i ∧ r i < r' i ∧ r' i < R (c i)) ∧
        (LocallyFinite fun i => ball (c i) (r' i)) ∧ (⋃ i, ball (c i) (r i)) = univ :=
  let ⟨ι, c, r, r', hlt, hfin, hsub⟩ :=
    exists_locallyFinite_subset_unionᵢ_ball_radius_lt isClosed_univ fun x _ => hR x
  ⟨ι, c, r, r', fun i => (hlt i).2, hfin, univ_subset_iff.1 hsub⟩
#align exists_locally_finite_Union_eq_ball_radius_lt exists_locallyFinite_unionᵢ_eq_ball_radius_lt

