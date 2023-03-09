/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro

! This file was ported from Lean 3 source module topology.instances.real
! leanprover-community/mathlib commit f47581155c818e6361af4e4fda60d27d020c226b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.MetricSpace.Basic
import Mathbin.Topology.Algebra.UniformGroup
import Mathbin.Topology.Algebra.UniformMulAction
import Mathbin.Topology.Algebra.Ring.Basic
import Mathbin.Topology.Algebra.Star
import Mathbin.Topology.Algebra.Order.Field
import Mathbin.RingTheory.Subring.Basic
import Mathbin.GroupTheory.Archimedean
import Mathbin.Algebra.Order.Group.Bounds
import Mathbin.Algebra.Periodic
import Mathbin.Topology.Instances.Int

/-!
# Topological properties of ℝ

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


noncomputable section

open Classical Filter Int Metric Set TopologicalSpace

open Classical Topology Filter uniformity Interval

universe u v w

variable {α : Type u} {β : Type v} {γ : Type w}

instance : NoncompactSpace ℝ :=
  Int.closedEmbedding_coe_real.NoncompactSpace

/- warning: real.uniform_continuous_add -> Real.uniformContinuous_add is a dubious translation:
lean 3 declaration is
  UniformContinuous.{0, 0} (Prod.{0, 0} Real Real) Real (Prod.uniformSpace.{0, 0} Real Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (fun (p : Prod.{0, 0} Real Real) => HAdd.hAdd.{0, 0, 0} Real Real Real (instHAdd.{0} Real Real.hasAdd) (Prod.fst.{0, 0} Real Real p) (Prod.snd.{0, 0} Real Real p))
but is expected to have type
  UniformContinuous.{0, 0} (Prod.{0, 0} Real Real) Real (instUniformSpaceProd.{0, 0} Real Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (fun (p : Prod.{0, 0} Real Real) => HAdd.hAdd.{0, 0, 0} Real Real Real (instHAdd.{0} Real Real.instAddReal) (Prod.fst.{0, 0} Real Real p) (Prod.snd.{0, 0} Real Real p))
Case conversion may be inaccurate. Consider using '#align real.uniform_continuous_add Real.uniformContinuous_addₓ'. -/
theorem Real.uniformContinuous_add : UniformContinuous fun p : ℝ × ℝ => p.1 + p.2 :=
  Metric.uniformContinuous_iff.2 fun ε ε0 =>
    let ⟨δ, δ0, Hδ⟩ := rat_add_continuous_lemma abs ε0
    ⟨δ, δ0, fun a b h =>
      let ⟨h₁, h₂⟩ := max_lt_iff.1 h
      Hδ h₁ h₂⟩
#align real.uniform_continuous_add Real.uniformContinuous_add

/- warning: real.uniform_continuous_neg -> Real.uniformContinuous_neg is a dubious translation:
lean 3 declaration is
  UniformContinuous.{0, 0} Real Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (Neg.neg.{0} Real Real.hasNeg)
but is expected to have type
  UniformContinuous.{0, 0} Real Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (Neg.neg.{0} Real Real.instNegReal)
Case conversion may be inaccurate. Consider using '#align real.uniform_continuous_neg Real.uniformContinuous_negₓ'. -/
theorem Real.uniformContinuous_neg : UniformContinuous (@Neg.neg ℝ _) :=
  Metric.uniformContinuous_iff.2 fun ε ε0 =>
    ⟨_, ε0, fun a b h => by rw [dist_comm] at h <;> simpa [Real.dist_eq] using h⟩
#align real.uniform_continuous_neg Real.uniformContinuous_neg

instance : ContinuousStar ℝ :=
  ⟨continuous_id⟩

instance : UniformAddGroup ℝ :=
  UniformAddGroup.mk' Real.uniformContinuous_add Real.uniformContinuous_neg

-- short-circuit type class inference
instance : TopologicalAddGroup ℝ := by infer_instance

instance : ProperSpace ℝ
    where isCompact_closedBall x r :=
    by
    rw [Real.closedBall_eq_Icc]
    apply is_compact_Icc

instance : SecondCountableTopology ℝ :=
  secondCountable_of_proper

/- warning: real.is_topological_basis_Ioo_rat -> Real.isTopologicalBasis_Ioo_rat is a dubious translation:
lean 3 declaration is
  TopologicalSpace.IsTopologicalBasis.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (Set.unionᵢ.{0, 1} (Set.{0} Real) Rat (fun (a : Rat) => Set.unionᵢ.{0, 1} (Set.{0} Real) Rat (fun (b : Rat) => Set.unionᵢ.{0, 0} (Set.{0} Real) (LT.lt.{0} Rat Rat.hasLt a b) (fun (h : LT.lt.{0} Rat Rat.hasLt a b) => Singleton.singleton.{0, 0} (Set.{0} Real) (Set.{0} (Set.{0} Real)) (Set.hasSingleton.{0} (Set.{0} Real)) (Set.Ioo.{0} Real Real.preorder ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) a) ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) b))))))
but is expected to have type
  TopologicalSpace.IsTopologicalBasis.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (Set.unionᵢ.{0, 1} (Set.{0} Real) Rat (fun (a : Rat) => Set.unionᵢ.{0, 1} (Set.{0} Real) Rat (fun (b : Rat) => Set.unionᵢ.{0, 0} (Set.{0} Real) (LT.lt.{0} Rat Rat.instLTRat_1 a b) (fun (h : LT.lt.{0} Rat Rat.instLTRat_1 a b) => Singleton.singleton.{0, 0} (Set.{0} Real) (Set.{0} (Set.{0} Real)) (Set.instSingletonSet.{0} (Set.{0} Real)) (Set.Ioo.{0} Real Real.instPreorderReal (RatCast.ratCast.{0} Real Real.ratCast a) (RatCast.ratCast.{0} Real Real.ratCast b))))))
Case conversion may be inaccurate. Consider using '#align real.is_topological_basis_Ioo_rat Real.isTopologicalBasis_Ioo_ratₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (a b) -/
theorem Real.isTopologicalBasis_Ioo_rat :
    @IsTopologicalBasis ℝ _ (⋃ (a : ℚ) (b : ℚ) (h : a < b), {Ioo a b}) :=
  isTopologicalBasis_of_open_of_nhds (by simp (config := { contextual := true }) [isOpen_Ioo])
    fun a v hav hv =>
    let ⟨l, u, ⟨hl, hu⟩, h⟩ := mem_nhds_iff_exists_Ioo_subset.mp (IsOpen.mem_nhds hv hav)
    let ⟨q, hlq, hqa⟩ := exists_rat_btwn hl
    let ⟨p, hap, hpu⟩ := exists_rat_btwn hu
    ⟨Ioo q p, by
      simp only [mem_Union]
      exact ⟨q, p, Rat.cast_lt.1 <| hqa.trans hap, rfl⟩, ⟨hqa, hap⟩, fun a' ⟨hqa', ha'p⟩ =>
      h ⟨hlq.trans hqa', ha'p.trans hpu⟩⟩
#align real.is_topological_basis_Ioo_rat Real.isTopologicalBasis_Ioo_rat

/- warning: real.cocompact_eq -> Real.cocompact_eq is a dubious translation:
lean 3 declaration is
  Eq.{1} (Filter.{0} Real) (Filter.cocompact.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (Sup.sup.{0} (Filter.{0} Real) (SemilatticeSup.toHasSup.{0} (Filter.{0} Real) (Lattice.toSemilatticeSup.{0} (Filter.{0} Real) (ConditionallyCompleteLattice.toLattice.{0} (Filter.{0} Real) (CompleteLattice.toConditionallyCompleteLattice.{0} (Filter.{0} Real) (Filter.completeLattice.{0} Real))))) (Filter.atBot.{0} Real Real.preorder) (Filter.atTop.{0} Real Real.preorder))
but is expected to have type
  Eq.{1} (Filter.{0} Real) (Filter.cocompact.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (Sup.sup.{0} (Filter.{0} Real) (SemilatticeSup.toSup.{0} (Filter.{0} Real) (Lattice.toSemilatticeSup.{0} (Filter.{0} Real) (ConditionallyCompleteLattice.toLattice.{0} (Filter.{0} Real) (CompleteLattice.toConditionallyCompleteLattice.{0} (Filter.{0} Real) (Filter.instCompleteLatticeFilter.{0} Real))))) (Filter.atBot.{0} Real Real.instPreorderReal) (Filter.atTop.{0} Real Real.instPreorderReal))
Case conversion may be inaccurate. Consider using '#align real.cocompact_eq Real.cocompact_eqₓ'. -/
@[simp]
theorem Real.cocompact_eq : cocompact ℝ = atBot ⊔ atTop := by
  simp only [← comap_dist_right_atTop_eq_cocompact (0 : ℝ), Real.dist_eq, sub_zero,
    comap_abs_at_top]
#align real.cocompact_eq Real.cocompact_eq

/- warning: real.mem_closure_iff -> Real.mem_closure_iff is a dubious translation:
lean 3 declaration is
  forall {s : Set.{0} Real} {x : Real}, Iff (Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) x (closure.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) s)) (forall (ε : Real), (GT.gt.{0} Real Real.hasLt ε (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))) -> (Exists.{1} Real (fun (y : Real) => Exists.{0} (Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) y s) (fun (H : Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) y s) => LT.lt.{0} Real Real.hasLt (Abs.abs.{0} Real (Neg.toHasAbs.{0} Real Real.hasNeg Real.hasSup) (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) y x)) ε))))
but is expected to have type
  forall {s : Set.{0} Real} {x : Real}, Iff (Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) x (closure.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) s)) (forall (ε : Real), (GT.gt.{0} Real Real.instLTReal ε (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))) -> (Exists.{1} Real (fun (y : Real) => And (Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) y s) (LT.lt.{0} Real Real.instLTReal (Abs.abs.{0} Real (Neg.toHasAbs.{0} Real Real.instNegReal Real.instSupReal) (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) y x)) ε))))
Case conversion may be inaccurate. Consider using '#align real.mem_closure_iff Real.mem_closure_iffₓ'. -/
/- TODO(Mario): Prove that these are uniform isomorphisms instead of uniform embeddings
lemma uniform_embedding_add_rat {r : ℚ} : uniform_embedding (λp:ℚ, p + r) :=
_

lemma uniform_embedding_mul_rat {q : ℚ} (hq : q ≠ 0) : uniform_embedding ((*) q) :=
_ -/
theorem Real.mem_closure_iff {s : Set ℝ} {x : ℝ} : x ∈ closure s ↔ ∀ ε > 0, ∃ y ∈ s, |y - x| < ε :=
  by simp [mem_closure_iff_nhds_basis nhds_basis_ball, Real.dist_eq]
#align real.mem_closure_iff Real.mem_closure_iff

/- warning: real.uniform_continuous_inv -> Real.uniformContinuous_inv is a dubious translation:
lean 3 declaration is
  forall (s : Set.{0} Real) {r : Real}, (LT.lt.{0} Real Real.hasLt (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))) r) -> (forall (x : Real), (Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) x s) -> (LE.le.{0} Real Real.hasLe r (Abs.abs.{0} Real (Neg.toHasAbs.{0} Real Real.hasNeg Real.hasSup) x))) -> (UniformContinuous.{0, 0} (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) s) Real (Subtype.uniformSpace.{0} Real (fun (x : Real) => Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) x s) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (fun (p : coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) s) => Inv.inv.{0} Real Real.hasInv (Subtype.val.{1} Real (fun (x : Real) => Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) x s) p)))
but is expected to have type
  forall (s : Set.{0} Real) {r : Real}, (LT.lt.{0} Real Real.instLTReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)) r) -> (forall (x : Real), (Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) x s) -> (LE.le.{0} Real Real.instLEReal r (Abs.abs.{0} Real (Neg.toHasAbs.{0} Real Real.instNegReal Real.instSupReal) x))) -> (UniformContinuous.{0, 0} (Set.Elem.{0} Real s) Real (instUniformSpaceSubtype.{0} Real (fun (x : Real) => Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) x s) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (fun (p : Set.Elem.{0} Real s) => Inv.inv.{0} Real Real.instInvReal (Subtype.val.{1} Real (fun (x : Real) => Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) x s) p)))
Case conversion may be inaccurate. Consider using '#align real.uniform_continuous_inv Real.uniformContinuous_invₓ'. -/
theorem Real.uniformContinuous_inv (s : Set ℝ) {r : ℝ} (r0 : 0 < r) (H : ∀ x ∈ s, r ≤ |x|) :
    UniformContinuous fun p : s => p.1⁻¹ :=
  Metric.uniformContinuous_iff.2 fun ε ε0 =>
    let ⟨δ, δ0, Hδ⟩ := rat_inv_continuous_lemma abs ε0 r0
    ⟨δ, δ0, fun a b h => Hδ (H _ a.2) (H _ b.2) h⟩
#align real.uniform_continuous_inv Real.uniformContinuous_inv

/- warning: real.uniform_continuous_abs -> Real.uniformContinuous_abs is a dubious translation:
lean 3 declaration is
  UniformContinuous.{0, 0} Real Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (Abs.abs.{0} Real (Neg.toHasAbs.{0} Real Real.hasNeg Real.hasSup))
but is expected to have type
  UniformContinuous.{0, 0} Real Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (Abs.abs.{0} Real (Neg.toHasAbs.{0} Real Real.instNegReal Real.instSupReal))
Case conversion may be inaccurate. Consider using '#align real.uniform_continuous_abs Real.uniformContinuous_absₓ'. -/
theorem Real.uniformContinuous_abs : UniformContinuous (abs : ℝ → ℝ) :=
  Metric.uniformContinuous_iff.2 fun ε ε0 =>
    ⟨ε, ε0, fun a b => lt_of_le_of_lt (abs_abs_sub_abs_le_abs_sub _ _)⟩
#align real.uniform_continuous_abs Real.uniformContinuous_abs

/- warning: real.tendsto_inv -> Real.tendsto_inv is a dubious translation:
lean 3 declaration is
  forall {r : Real}, (Ne.{1} Real r (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))) -> (Filter.Tendsto.{0, 0} Real Real (fun (q : Real) => Inv.inv.{0} Real Real.hasInv q) (nhds.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) r) (nhds.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (Inv.inv.{0} Real Real.hasInv r)))
but is expected to have type
  forall {r : Real}, (Ne.{1} Real r (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))) -> (Filter.Tendsto.{0, 0} Real Real (fun (q : Real) => Inv.inv.{0} Real Real.instInvReal q) (nhds.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) r) (nhds.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (Inv.inv.{0} Real Real.instInvReal r)))
Case conversion may be inaccurate. Consider using '#align real.tendsto_inv Real.tendsto_invₓ'. -/
theorem Real.tendsto_inv {r : ℝ} (r0 : r ≠ 0) : Tendsto (fun q => q⁻¹) (𝓝 r) (𝓝 r⁻¹) := by
  rw [← abs_pos] at r0 <;>
    exact
      tendsto_of_uniformContinuous_subtype
        (Real.uniformContinuous_inv { x | |r| / 2 < |x| } (half_pos r0) fun x h => le_of_lt h)
        (IsOpen.mem_nhds ((isOpen_lt' (|r| / 2)).Preimage continuous_abs) (half_lt_self r0))
#align real.tendsto_inv Real.tendsto_inv

/- warning: real.continuous_inv -> Real.continuous_inv is a dubious translation:
lean 3 declaration is
  Continuous.{0, 0} (Subtype.{1} Real (fun (r : Real) => Ne.{1} Real r (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))))) Real (Subtype.topologicalSpace.{0} Real (fun (r : Real) => Ne.{1} Real r (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))) (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (fun (a : Subtype.{1} Real (fun (r : Real) => Ne.{1} Real r (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))))) => Inv.inv.{0} Real Real.hasInv (Subtype.val.{1} Real (fun (r : Real) => Ne.{1} Real r (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))) a))
but is expected to have type
  Continuous.{0, 0} (Subtype.{1} Real (fun (r : Real) => Ne.{1} Real r (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)))) Real (instTopologicalSpaceSubtype.{0} Real (fun (r : Real) => Ne.{1} Real r (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))) (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (fun (a : Subtype.{1} Real (fun (r : Real) => Ne.{1} Real r (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)))) => Inv.inv.{0} Real Real.instInvReal (Subtype.val.{1} Real (fun (r : Real) => Ne.{1} Real r (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))) a))
Case conversion may be inaccurate. Consider using '#align real.continuous_inv Real.continuous_invₓ'. -/
theorem Real.continuous_inv : Continuous fun a : { r : ℝ // r ≠ 0 } => a.val⁻¹ :=
  continuous_iff_continuousAt.mpr fun ⟨r, hr⟩ =>
    Tendsto.comp (Real.tendsto_inv hr) (continuous_iff_continuousAt.mp continuous_subtype_val _)
#align real.continuous_inv Real.continuous_inv

/- warning: real.continuous.inv -> Real.Continuous.inv is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {f : α -> Real}, (forall (a : α), Ne.{1} Real (f a) (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))) -> (Continuous.{u1, 0} α Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) f) -> (Continuous.{u1, 0} α Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (fun (a : α) => Inv.inv.{0} Real Real.hasInv (f a)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {f : α -> Real}, (forall (a : α), Ne.{1} Real (f a) (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))) -> (Continuous.{u1, 0} α Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) f) -> (Continuous.{u1, 0} α Real _inst_1 (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (fun (a : α) => Inv.inv.{0} Real Real.instInvReal (f a)))
Case conversion may be inaccurate. Consider using '#align real.continuous.inv Real.Continuous.invₓ'. -/
theorem Real.Continuous.inv [TopologicalSpace α] {f : α → ℝ} (h : ∀ a, f a ≠ 0)
    (hf : Continuous f) : Continuous fun a => (f a)⁻¹ :=
  show Continuous ((Inv.inv ∘ @Subtype.val ℝ fun r => r ≠ 0) ∘ fun a => ⟨f a, h a⟩) from
    Real.continuous_inv.comp (hf.subtype_mk _)
#align real.continuous.inv Real.Continuous.inv

/- warning: real.uniform_continuous_const_mul -> Real.uniformContinuous_const_mul is a dubious translation:
lean 3 declaration is
  forall {x : Real}, UniformContinuous.{0, 0} Real Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (HMul.hMul.{0, 0, 0} Real Real Real (instHMul.{0} Real Real.hasMul) x)
but is expected to have type
  forall {x : Real}, UniformContinuous.{0, 0} Real Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) ((fun (x._@.Mathlib.Topology.Instances.Real._hyg.946 : Real) (x._@.Mathlib.Topology.Instances.Real._hyg.948 : Real) => HMul.hMul.{0, 0, 0} Real Real Real (instHMul.{0} Real Real.instMulReal) x._@.Mathlib.Topology.Instances.Real._hyg.946 x._@.Mathlib.Topology.Instances.Real._hyg.948) x)
Case conversion may be inaccurate. Consider using '#align real.uniform_continuous_const_mul Real.uniformContinuous_const_mulₓ'. -/
theorem Real.uniformContinuous_const_mul {x : ℝ} : UniformContinuous ((· * ·) x) :=
  uniformContinuous_const_smul x
#align real.uniform_continuous_const_mul Real.uniformContinuous_const_mul

/- warning: real.uniform_continuous_mul -> Real.uniformContinuous_mul is a dubious translation:
lean 3 declaration is
  forall (s : Set.{0} (Prod.{0, 0} Real Real)) {r₁ : Real} {r₂ : Real}, (forall (x : Prod.{0, 0} Real Real), (Membership.Mem.{0, 0} (Prod.{0, 0} Real Real) (Set.{0} (Prod.{0, 0} Real Real)) (Set.hasMem.{0} (Prod.{0, 0} Real Real)) x s) -> (And (LT.lt.{0} Real Real.hasLt (Abs.abs.{0} Real (Neg.toHasAbs.{0} Real Real.hasNeg Real.hasSup) (Prod.fst.{0, 0} Real Real x)) r₁) (LT.lt.{0} Real Real.hasLt (Abs.abs.{0} Real (Neg.toHasAbs.{0} Real Real.hasNeg Real.hasSup) (Prod.snd.{0, 0} Real Real x)) r₂))) -> (UniformContinuous.{0, 0} (coeSort.{1, 2} (Set.{0} (Prod.{0, 0} Real Real)) Type (Set.hasCoeToSort.{0} (Prod.{0, 0} Real Real)) s) Real (Subtype.uniformSpace.{0} (Prod.{0, 0} Real Real) (fun (x : Prod.{0, 0} Real Real) => Membership.Mem.{0, 0} (Prod.{0, 0} Real Real) (Set.{0} (Prod.{0, 0} Real Real)) (Set.hasMem.{0} (Prod.{0, 0} Real Real)) x s) (Prod.uniformSpace.{0, 0} Real Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (fun (p : coeSort.{1, 2} (Set.{0} (Prod.{0, 0} Real Real)) Type (Set.hasCoeToSort.{0} (Prod.{0, 0} Real Real)) s) => HMul.hMul.{0, 0, 0} Real Real Real (instHMul.{0} Real Real.hasMul) (Prod.fst.{0, 0} Real Real (Subtype.val.{1} (Prod.{0, 0} Real Real) (fun (x : Prod.{0, 0} Real Real) => Membership.Mem.{0, 0} (Prod.{0, 0} Real Real) (Set.{0} (Prod.{0, 0} Real Real)) (Set.hasMem.{0} (Prod.{0, 0} Real Real)) x s) p)) (Prod.snd.{0, 0} Real Real (Subtype.val.{1} (Prod.{0, 0} Real Real) (fun (x : Prod.{0, 0} Real Real) => Membership.Mem.{0, 0} (Prod.{0, 0} Real Real) (Set.{0} (Prod.{0, 0} Real Real)) (Set.hasMem.{0} (Prod.{0, 0} Real Real)) x s) p))))
but is expected to have type
  forall (s : Set.{0} (Prod.{0, 0} Real Real)) {r₁ : Real} {r₂ : Real}, (forall (x : Prod.{0, 0} Real Real), (Membership.mem.{0, 0} (Prod.{0, 0} Real Real) (Set.{0} (Prod.{0, 0} Real Real)) (Set.instMembershipSet.{0} (Prod.{0, 0} Real Real)) x s) -> (And (LT.lt.{0} Real Real.instLTReal (Abs.abs.{0} Real (Neg.toHasAbs.{0} Real Real.instNegReal Real.instSupReal) (Prod.fst.{0, 0} Real Real x)) r₁) (LT.lt.{0} Real Real.instLTReal (Abs.abs.{0} Real (Neg.toHasAbs.{0} Real Real.instNegReal Real.instSupReal) (Prod.snd.{0, 0} Real Real x)) r₂))) -> (UniformContinuous.{0, 0} (Set.Elem.{0} (Prod.{0, 0} Real Real) s) Real (instUniformSpaceSubtype.{0} (Prod.{0, 0} Real Real) (fun (x : Prod.{0, 0} Real Real) => Membership.mem.{0, 0} (Prod.{0, 0} Real Real) (Set.{0} (Prod.{0, 0} Real Real)) (Set.instMembershipSet.{0} (Prod.{0, 0} Real Real)) x s) (instUniformSpaceProd.{0, 0} Real Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace) (fun (p : Set.Elem.{0} (Prod.{0, 0} Real Real) s) => HMul.hMul.{0, 0, 0} Real Real Real (instHMul.{0} Real Real.instMulReal) (Prod.fst.{0, 0} Real Real (Subtype.val.{1} (Prod.{0, 0} Real Real) (fun (x : Prod.{0, 0} Real Real) => Membership.mem.{0, 0} (Prod.{0, 0} Real Real) (Set.{0} (Prod.{0, 0} Real Real)) (Set.instMembershipSet.{0} (Prod.{0, 0} Real Real)) x s) p)) (Prod.snd.{0, 0} Real Real (Subtype.val.{1} (Prod.{0, 0} Real Real) (fun (x : Prod.{0, 0} Real Real) => Membership.mem.{0, 0} (Prod.{0, 0} Real Real) (Set.{0} (Prod.{0, 0} Real Real)) (Set.instMembershipSet.{0} (Prod.{0, 0} Real Real)) x s) p))))
Case conversion may be inaccurate. Consider using '#align real.uniform_continuous_mul Real.uniformContinuous_mulₓ'. -/
theorem Real.uniformContinuous_mul (s : Set (ℝ × ℝ)) {r₁ r₂ : ℝ}
    (H : ∀ x ∈ s, |(x : ℝ × ℝ).1| < r₁ ∧ |x.2| < r₂) :
    UniformContinuous fun p : s => p.1.1 * p.1.2 :=
  Metric.uniformContinuous_iff.2 fun ε ε0 =>
    let ⟨δ, δ0, Hδ⟩ := rat_mul_continuous_lemma abs ε0
    ⟨δ, δ0, fun a b h =>
      let ⟨h₁, h₂⟩ := max_lt_iff.1 h
      Hδ (H _ a.2).1 (H _ b.2).2 h₁ h₂⟩
#align real.uniform_continuous_mul Real.uniformContinuous_mul

/- warning: real.continuous_mul -> Real.continuous_mul is a dubious translation:
lean 3 declaration is
  Continuous.{0, 0} (Prod.{0, 0} Real Real) Real (Prod.topologicalSpace.{0, 0} Real Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (fun (p : Prod.{0, 0} Real Real) => HMul.hMul.{0, 0, 0} Real Real Real (instHMul.{0} Real Real.hasMul) (Prod.fst.{0, 0} Real Real p) (Prod.snd.{0, 0} Real Real p))
but is expected to have type
  Continuous.{0, 0} (Prod.{0, 0} Real Real) Real (instTopologicalSpaceProd.{0, 0} Real Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (fun (p : Prod.{0, 0} Real Real) => HMul.hMul.{0, 0, 0} Real Real Real (instHMul.{0} Real Real.instMulReal) (Prod.fst.{0, 0} Real Real p) (Prod.snd.{0, 0} Real Real p))
Case conversion may be inaccurate. Consider using '#align real.continuous_mul Real.continuous_mulₓ'. -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
protected theorem Real.continuous_mul : Continuous fun p : ℝ × ℝ => p.1 * p.2 :=
  continuous_iff_continuousAt.2 fun ⟨a₁, a₂⟩ =>
    tendsto_of_uniformContinuous_subtype
      (Real.uniformContinuous_mul ({ x | |x| < |a₁| + 1 } ×ˢ { x | |x| < |a₂| + 1 }) fun x => id)
      (IsOpen.mem_nhds
        (((isOpen_gt' (|a₁| + 1)).Preimage continuous_abs).Prod
          ((isOpen_gt' (|a₂| + 1)).Preimage continuous_abs))
        ⟨lt_add_one (|a₁|), lt_add_one (|a₂|)⟩)
#align real.continuous_mul Real.continuous_mul

instance : TopologicalRing ℝ :=
  { Real.topologicalAddGroup with continuous_mul := Real.continuous_mul }

instance : CompleteSpace ℝ := by
  apply complete_of_cauchy_seq_tendsto
  intro u hu
  let c : CauSeq ℝ abs := ⟨u, Metric.cauchySeq_iff'.1 hu⟩
  refine' ⟨c.lim, fun s h => _⟩
  rcases Metric.mem_nhds_iff.1 h with ⟨ε, ε0, hε⟩
  have := c.equiv_lim ε ε0
  simp only [mem_map, mem_at_top_sets, mem_set_of_eq]
  refine' this.imp fun N hN n hn => hε (hN n hn)

#print Real.totallyBounded_ball /-
theorem Real.totallyBounded_ball (x ε : ℝ) : TotallyBounded (ball x ε) := by
  rw [Real.ball_eq_Ioo] <;> apply totallyBounded_Ioo
#align real.totally_bounded_ball Real.totallyBounded_ball
-/

section

/- warning: closure_of_rat_image_lt -> closure_of_rat_image_lt is a dubious translation:
lean 3 declaration is
  forall {q : Rat}, Eq.{1} (Set.{0} Real) (closure.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (Set.image.{0, 0} Rat Real ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast)))) (setOf.{0} Rat (fun (x : Rat) => LT.lt.{0} Rat Rat.hasLt q x)))) (setOf.{0} Real (fun (r : Real) => LE.le.{0} Real Real.hasLe ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) q) r))
but is expected to have type
  forall {q : Rat}, Eq.{1} (Set.{0} Real) (closure.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (Set.image.{0, 0} Rat Real (RatCast.ratCast.{0} Real Real.ratCast) (setOf.{0} Rat (fun (x : Rat) => LT.lt.{0} Rat Rat.instLTRat_1 q x)))) (setOf.{0} Real (fun (r : Real) => LE.le.{0} Real Real.instLEReal (RatCast.ratCast.{0} Real Real.ratCast q) r))
Case conversion may be inaccurate. Consider using '#align closure_of_rat_image_lt closure_of_rat_image_ltₓ'. -/
theorem closure_of_rat_image_lt {q : ℚ} :
    closure ((coe : ℚ → ℝ) '' { x | q < x }) = { r | ↑q ≤ r } :=
  Subset.antisymm
    ((isClosed_ge' _).closure_subset_iff.2
      (image_subset_iff.2 fun p h => le_of_lt <| (@Rat.cast_lt ℝ _ _ _).2 h))
    fun x hx =>
    mem_closure_iff_nhds.2 fun t ht =>
      let ⟨ε, ε0, hε⟩ := Metric.mem_nhds_iff.1 ht
      let ⟨p, h₁, h₂⟩ := exists_rat_btwn ((lt_add_iff_pos_right x).2 ε0)
      ⟨_, hε (show abs _ < _ by rwa [abs_of_nonneg (le_of_lt <| sub_pos.2 h₁), sub_lt_iff_lt_add']),
        p, Rat.cast_lt.1 (@lt_of_le_of_lt ℝ _ _ _ _ hx h₁), rfl⟩
#align closure_of_rat_image_lt closure_of_rat_image_lt

#print Real.bounded_iff_bddBelow_bddAbove /-
/- TODO(Mario): Put these back only if needed later
lemma closure_of_rat_image_le_eq {q : ℚ} : closure ((coe:ℚ → ℝ) '' {x | q ≤ x}) = {r | ↑q ≤ r} :=
_

lemma closure_of_rat_image_le_le_eq {a b : ℚ} (hab : a ≤ b) :
  closure (of_rat '' {q:ℚ | a ≤ q ∧ q ≤ b}) = {r:ℝ | of_rat a ≤ r ∧ r ≤ of_rat b} :=
_-/
theorem Real.bounded_iff_bddBelow_bddAbove {s : Set ℝ} : Bounded s ↔ BddBelow s ∧ BddAbove s :=
  ⟨by
    intro bdd
    rcases(bounded_iff_subset_ball 0).1 bdd with ⟨r, hr⟩
    -- hr : s ⊆ closed_ball 0 r
    rw [Real.closedBall_eq_Icc] at hr
    -- hr : s ⊆ Icc (0 - r) (0 + r)
    exact ⟨bdd_below_Icc.mono hr, bdd_above_Icc.mono hr⟩,
    fun h => bounded_of_bddAbove_of_bddBelow h.2 h.1⟩
#align real.bounded_iff_bdd_below_bdd_above Real.bounded_iff_bddBelow_bddAbove
-/

/- warning: real.subset_Icc_Inf_Sup_of_bounded -> Real.subset_Icc_infₛ_supₛ_of_bounded is a dubious translation:
lean 3 declaration is
  forall {s : Set.{0} Real}, (Metric.Bounded.{0} Real Real.pseudoMetricSpace s) -> (HasSubset.Subset.{0} (Set.{0} Real) (Set.hasSubset.{0} Real) s (Set.Icc.{0} Real Real.preorder (InfSet.infₛ.{0} Real Real.hasInf s) (SupSet.supₛ.{0} Real Real.hasSup s)))
but is expected to have type
  forall {s : Set.{0} Real}, (Metric.Bounded.{0} Real Real.pseudoMetricSpace s) -> (HasSubset.Subset.{0} (Set.{0} Real) (Set.instHasSubsetSet.{0} Real) s (Set.Icc.{0} Real Real.instPreorderReal (InfSet.infₛ.{0} Real Real.instInfSetReal s) (SupSet.supₛ.{0} Real Real.instSupSetReal s)))
Case conversion may be inaccurate. Consider using '#align real.subset_Icc_Inf_Sup_of_bounded Real.subset_Icc_infₛ_supₛ_of_boundedₓ'. -/
theorem Real.subset_Icc_infₛ_supₛ_of_bounded {s : Set ℝ} (h : Bounded s) :
    s ⊆ Icc (infₛ s) (supₛ s) :=
  subset_Icc_cinfₛ_csupₛ (Real.bounded_iff_bddBelow_bddAbove.1 h).1
    (Real.bounded_iff_bddBelow_bddAbove.1 h).2
#align real.subset_Icc_Inf_Sup_of_bounded Real.subset_Icc_infₛ_supₛ_of_bounded

end

section Periodic

namespace Function

/- warning: function.periodic.compact_of_continuous' -> Function.Periodic.compact_of_continuous' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {f : Real -> α} {c : Real}, (Function.Periodic.{0, u1} Real α Real.hasAdd f c) -> (LT.lt.{0} Real Real.hasLt (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))) c) -> (Continuous.{0, u1} Real α (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) _inst_1 f) -> (IsCompact.{u1} α _inst_1 (Set.range.{u1, 1} α Real f))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {f : Real -> α} {c : Real}, (Function.Periodic.{0, u1} Real α Real.instAddReal f c) -> (LT.lt.{0} Real Real.instLTReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)) c) -> (Continuous.{0, u1} Real α (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) _inst_1 f) -> (IsCompact.{u1} α _inst_1 (Set.range.{u1, 1} α Real f))
Case conversion may be inaccurate. Consider using '#align function.periodic.compact_of_continuous' Function.Periodic.compact_of_continuous'ₓ'. -/
theorem Periodic.compact_of_continuous' [TopologicalSpace α] {f : ℝ → α} {c : ℝ} (hp : Periodic f c)
    (hc : 0 < c) (hf : Continuous f) : IsCompact (range f) :=
  by
  convert is_compact_Icc.image hf
  ext x
  refine' ⟨_, mem_range_of_mem_image f (Icc 0 c)⟩
  rintro ⟨y, h1⟩
  obtain ⟨z, hz, h2⟩ := hp.exists_mem_Ico₀ hc y
  exact ⟨z, mem_Icc_of_Ico hz, h2.symm.trans h1⟩
#align function.periodic.compact_of_continuous' Function.Periodic.compact_of_continuous'

/- warning: function.periodic.compact_of_continuous -> Function.Periodic.compact_of_continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {f : Real -> α} {c : Real}, (Function.Periodic.{0, u1} Real α Real.hasAdd f c) -> (Ne.{1} Real c (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))) -> (Continuous.{0, u1} Real α (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) _inst_1 f) -> (IsCompact.{u1} α _inst_1 (Set.range.{u1, 1} α Real f))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {f : Real -> α} {c : Real}, (Function.Periodic.{0, u1} Real α Real.instAddReal f c) -> (Ne.{1} Real c (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))) -> (Continuous.{0, u1} Real α (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) _inst_1 f) -> (IsCompact.{u1} α _inst_1 (Set.range.{u1, 1} α Real f))
Case conversion may be inaccurate. Consider using '#align function.periodic.compact_of_continuous Function.Periodic.compact_of_continuousₓ'. -/
/-- A continuous, periodic function has compact range. -/
theorem Periodic.compact_of_continuous [TopologicalSpace α] {f : ℝ → α} {c : ℝ} (hp : Periodic f c)
    (hc : c ≠ 0) (hf : Continuous f) : IsCompact (range f) :=
  by
  cases' lt_or_gt_of_ne hc with hneg hpos
  exacts[hp.neg.compact_of_continuous' (neg_pos.mpr hneg) hf, hp.compact_of_continuous' hpos hf]
#align function.periodic.compact_of_continuous Function.Periodic.compact_of_continuous

/- warning: function.periodic.bounded_of_continuous -> Function.Periodic.bounded_of_continuous is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : PseudoMetricSpace.{u1} α] {f : Real -> α} {c : Real}, (Function.Periodic.{0, u1} Real α Real.hasAdd f c) -> (Ne.{1} Real c (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))) -> (Continuous.{0, u1} Real α (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α _inst_1)) f) -> (Metric.Bounded.{u1} α _inst_1 (Set.range.{u1, 1} α Real f))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : PseudoMetricSpace.{u1} α] {f : Real -> α} {c : Real}, (Function.Periodic.{0, u1} Real α Real.instAddReal f c) -> (Ne.{1} Real c (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))) -> (Continuous.{0, u1} Real α (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (UniformSpace.toTopologicalSpace.{u1} α (PseudoMetricSpace.toUniformSpace.{u1} α _inst_1)) f) -> (Metric.Bounded.{u1} α _inst_1 (Set.range.{u1, 1} α Real f))
Case conversion may be inaccurate. Consider using '#align function.periodic.bounded_of_continuous Function.Periodic.bounded_of_continuousₓ'. -/
/-- A continuous, periodic function is bounded. -/
theorem Periodic.bounded_of_continuous [PseudoMetricSpace α] {f : ℝ → α} {c : ℝ} (hp : Periodic f c)
    (hc : c ≠ 0) (hf : Continuous f) : Bounded (range f) :=
  (hp.compact_of_continuous hc hf).Bounded
#align function.periodic.bounded_of_continuous Function.Periodic.bounded_of_continuous

end Function

end Periodic

section Subgroups

namespace Int

open Metric

/- warning: int.tendsto_coe_cofinite -> Int.tendsto_coe_cofinite is a dubious translation:
lean 3 declaration is
  Filter.Tendsto.{0, 0} Int Real ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Int Real (HasLiftT.mk.{1, 1} Int Real (CoeTCₓ.coe.{1, 1} Int Real (Int.castCoe.{0} Real Real.hasIntCast)))) (Filter.cofinite.{0} Int) (Filter.cocompact.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)))
but is expected to have type
  Filter.Tendsto.{0, 0} Int Real (Int.cast.{0} Real Real.intCast) (Filter.cofinite.{0} Int) (Filter.cocompact.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)))
Case conversion may be inaccurate. Consider using '#align int.tendsto_coe_cofinite Int.tendsto_coe_cofiniteₓ'. -/
/-- Under the coercion from `ℤ` to `ℝ`, inverse images of compact sets are finite. -/
theorem tendsto_coe_cofinite : Tendsto (coe : ℤ → ℝ) cofinite (cocompact ℝ) :=
  by
  refine' tendsto_cocompact_of_tendsto_dist_comp_atTop (0 : ℝ) _
  simp only [Filter.tendsto_atTop, eventually_cofinite, not_le, ← mem_ball]
  change ∀ r : ℝ, (coe ⁻¹' ball (0 : ℝ) r).Finite
  simp [Real.ball_eq_Ioo, Set.finite_Ioo]
#align int.tendsto_coe_cofinite Int.tendsto_coe_cofinite

/- warning: int.tendsto_zmultiples_hom_cofinite -> Int.tendsto_zmultiplesHom_cofinite is a dubious translation:
lean 3 declaration is
  forall {a : Real}, (Ne.{1} Real a (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))) -> (Filter.Tendsto.{0, 0} Int Real (coeFn.{1, 1} (AddMonoidHom.{0, 0} Int Real (AddMonoid.toAddZeroClass.{0} Int Int.addMonoid) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.addGroup)))) (fun (_x : AddMonoidHom.{0, 0} Int Real (AddMonoid.toAddZeroClass.{0} Int Int.addMonoid) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.addGroup)))) => Int -> Real) (AddMonoidHom.hasCoeToFun.{0, 0} Int Real (AddMonoid.toAddZeroClass.{0} Int Int.addMonoid) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.addGroup)))) (coeFn.{1, 1} (Equiv.{1, 1} Real (AddMonoidHom.{0, 0} Int Real (AddMonoid.toAddZeroClass.{0} Int Int.addMonoid) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.addGroup))))) (fun (_x : Equiv.{1, 1} Real (AddMonoidHom.{0, 0} Int Real (AddMonoid.toAddZeroClass.{0} Int Int.addMonoid) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.addGroup))))) => Real -> (AddMonoidHom.{0, 0} Int Real (AddMonoid.toAddZeroClass.{0} Int Int.addMonoid) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.addGroup))))) (Equiv.hasCoeToFun.{1, 1} Real (AddMonoidHom.{0, 0} Int Real (AddMonoid.toAddZeroClass.{0} Int Int.addMonoid) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.addGroup))))) (zmultiplesHom.{0} Real Real.addGroup) a)) (Filter.cofinite.{0} Int) (Filter.cocompact.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))))
but is expected to have type
  forall {a : Real}, (Ne.{1} Real a (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))) -> (Filter.Tendsto.{0, 0} Int Real (FunLike.coe.{1, 1, 1} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Real) => AddMonoidHom.{0, 0} Int Real (AddMonoid.toAddZeroClass.{0} Int Int.instAddMonoidInt) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal)))) a) Int (fun (_x : Int) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.398 : Int) => Real) _x) (AddHomClass.toFunLike.{0, 0, 0} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Real) => AddMonoidHom.{0, 0} Int Real (AddMonoid.toAddZeroClass.{0} Int Int.instAddMonoidInt) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal)))) a) Int Real (AddZeroClass.toAdd.{0} Int (AddMonoid.toAddZeroClass.{0} Int Int.instAddMonoidInt)) (AddZeroClass.toAdd.{0} Real (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal)))) (AddMonoidHomClass.toAddHomClass.{0, 0, 0} ((fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Real) => AddMonoidHom.{0, 0} Int Real (AddMonoid.toAddZeroClass.{0} Int Int.instAddMonoidInt) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal)))) a) Int Real (AddMonoid.toAddZeroClass.{0} Int Int.instAddMonoidInt) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal))) (AddMonoidHom.addMonoidHomClass.{0, 0} Int Real (AddMonoid.toAddZeroClass.{0} Int Int.instAddMonoidInt) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal)))))) (FunLike.coe.{1, 1, 1} (Equiv.{1, 1} Real (AddMonoidHom.{0, 0} Int Real (AddMonoid.toAddZeroClass.{0} Int Int.instAddMonoidInt) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal))))) Real (fun (_x : Real) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Real) => AddMonoidHom.{0, 0} Int Real (AddMonoid.toAddZeroClass.{0} Int Int.instAddMonoidInt) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal)))) _x) (Equiv.instFunLikeEquiv.{1, 1} Real (AddMonoidHom.{0, 0} Int Real (AddMonoid.toAddZeroClass.{0} Int Int.instAddMonoidInt) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal))))) (zmultiplesHom.{0} Real Real.instAddGroupReal) a)) (Filter.cofinite.{0} Int) (Filter.cocompact.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))))
Case conversion may be inaccurate. Consider using '#align int.tendsto_zmultiples_hom_cofinite Int.tendsto_zmultiplesHom_cofiniteₓ'. -/
/-- For nonzero `a`, the "multiples of `a`" map `zmultiples_hom` from `ℤ` to `ℝ` is discrete, i.e.
inverse images of compact sets are finite. -/
theorem tendsto_zmultiplesHom_cofinite {a : ℝ} (ha : a ≠ 0) :
    Tendsto (zmultiplesHom ℝ a) cofinite (cocompact ℝ) :=
  by
  convert (tendsto_cocompact_mul_right₀ ha).comp Int.tendsto_coe_cofinite
  ext n
  simp
#align int.tendsto_zmultiples_hom_cofinite Int.tendsto_zmultiplesHom_cofinite

end Int

namespace AddSubgroup

/- warning: add_subgroup.tendsto_zmultiples_subtype_cofinite -> AddSubgroup.tendsto_zmultiples_subtype_cofinite is a dubious translation:
lean 3 declaration is
  forall (a : Real), Filter.Tendsto.{0, 0} (coeSort.{1, 2} (AddSubgroup.{0} Real Real.addGroup) Type (SetLike.hasCoeToSort.{0, 0} (AddSubgroup.{0} Real Real.addGroup) Real (AddSubgroup.setLike.{0} Real Real.addGroup)) (AddSubgroup.zmultiples.{0} Real Real.addGroup a)) Real (coeFn.{1, 1} (AddMonoidHom.{0, 0} (coeSort.{1, 2} (AddSubgroup.{0} Real Real.addGroup) Type (SetLike.hasCoeToSort.{0, 0} (AddSubgroup.{0} Real Real.addGroup) Real (AddSubgroup.setLike.{0} Real Real.addGroup)) (AddSubgroup.zmultiples.{0} Real Real.addGroup a)) Real (AddMonoid.toAddZeroClass.{0} (coeSort.{1, 2} (AddSubgroup.{0} Real Real.addGroup) Type (SetLike.hasCoeToSort.{0, 0} (AddSubgroup.{0} Real Real.addGroup) Real (AddSubgroup.setLike.{0} Real Real.addGroup)) (AddSubgroup.zmultiples.{0} Real Real.addGroup a)) (SubNegMonoid.toAddMonoid.{0} (coeSort.{1, 2} (AddSubgroup.{0} Real Real.addGroup) Type (SetLike.hasCoeToSort.{0, 0} (AddSubgroup.{0} Real Real.addGroup) Real (AddSubgroup.setLike.{0} Real Real.addGroup)) (AddSubgroup.zmultiples.{0} Real Real.addGroup a)) (AddGroup.toSubNegMonoid.{0} (coeSort.{1, 2} (AddSubgroup.{0} Real Real.addGroup) Type (SetLike.hasCoeToSort.{0, 0} (AddSubgroup.{0} Real Real.addGroup) Real (AddSubgroup.setLike.{0} Real Real.addGroup)) (AddSubgroup.zmultiples.{0} Real Real.addGroup a)) (AddSubgroup.toAddGroup.{0} Real Real.addGroup (AddSubgroup.zmultiples.{0} Real Real.addGroup a))))) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.addGroup)))) (fun (_x : AddMonoidHom.{0, 0} (coeSort.{1, 2} (AddSubgroup.{0} Real Real.addGroup) Type (SetLike.hasCoeToSort.{0, 0} (AddSubgroup.{0} Real Real.addGroup) Real (AddSubgroup.setLike.{0} Real Real.addGroup)) (AddSubgroup.zmultiples.{0} Real Real.addGroup a)) Real (AddMonoid.toAddZeroClass.{0} (coeSort.{1, 2} (AddSubgroup.{0} Real Real.addGroup) Type (SetLike.hasCoeToSort.{0, 0} (AddSubgroup.{0} Real Real.addGroup) Real (AddSubgroup.setLike.{0} Real Real.addGroup)) (AddSubgroup.zmultiples.{0} Real Real.addGroup a)) (SubNegMonoid.toAddMonoid.{0} (coeSort.{1, 2} (AddSubgroup.{0} Real Real.addGroup) Type (SetLike.hasCoeToSort.{0, 0} (AddSubgroup.{0} Real Real.addGroup) Real (AddSubgroup.setLike.{0} Real Real.addGroup)) (AddSubgroup.zmultiples.{0} Real Real.addGroup a)) (AddGroup.toSubNegMonoid.{0} (coeSort.{1, 2} (AddSubgroup.{0} Real Real.addGroup) Type (SetLike.hasCoeToSort.{0, 0} (AddSubgroup.{0} Real Real.addGroup) Real (AddSubgroup.setLike.{0} Real Real.addGroup)) (AddSubgroup.zmultiples.{0} Real Real.addGroup a)) (AddSubgroup.toAddGroup.{0} Real Real.addGroup (AddSubgroup.zmultiples.{0} Real Real.addGroup a))))) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.addGroup)))) => (coeSort.{1, 2} (AddSubgroup.{0} Real Real.addGroup) Type (SetLike.hasCoeToSort.{0, 0} (AddSubgroup.{0} Real Real.addGroup) Real (AddSubgroup.setLike.{0} Real Real.addGroup)) (AddSubgroup.zmultiples.{0} Real Real.addGroup a)) -> Real) (AddMonoidHom.hasCoeToFun.{0, 0} (coeSort.{1, 2} (AddSubgroup.{0} Real Real.addGroup) Type (SetLike.hasCoeToSort.{0, 0} (AddSubgroup.{0} Real Real.addGroup) Real (AddSubgroup.setLike.{0} Real Real.addGroup)) (AddSubgroup.zmultiples.{0} Real Real.addGroup a)) Real (AddMonoid.toAddZeroClass.{0} (coeSort.{1, 2} (AddSubgroup.{0} Real Real.addGroup) Type (SetLike.hasCoeToSort.{0, 0} (AddSubgroup.{0} Real Real.addGroup) Real (AddSubgroup.setLike.{0} Real Real.addGroup)) (AddSubgroup.zmultiples.{0} Real Real.addGroup a)) (SubNegMonoid.toAddMonoid.{0} (coeSort.{1, 2} (AddSubgroup.{0} Real Real.addGroup) Type (SetLike.hasCoeToSort.{0, 0} (AddSubgroup.{0} Real Real.addGroup) Real (AddSubgroup.setLike.{0} Real Real.addGroup)) (AddSubgroup.zmultiples.{0} Real Real.addGroup a)) (AddGroup.toSubNegMonoid.{0} (coeSort.{1, 2} (AddSubgroup.{0} Real Real.addGroup) Type (SetLike.hasCoeToSort.{0, 0} (AddSubgroup.{0} Real Real.addGroup) Real (AddSubgroup.setLike.{0} Real Real.addGroup)) (AddSubgroup.zmultiples.{0} Real Real.addGroup a)) (AddSubgroup.toAddGroup.{0} Real Real.addGroup (AddSubgroup.zmultiples.{0} Real Real.addGroup a))))) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.addGroup)))) (AddSubgroup.subtype.{0} Real Real.addGroup (AddSubgroup.zmultiples.{0} Real Real.addGroup a))) (Filter.cofinite.{0} (coeSort.{1, 2} (AddSubgroup.{0} Real Real.addGroup) Type (SetLike.hasCoeToSort.{0, 0} (AddSubgroup.{0} Real Real.addGroup) Real (AddSubgroup.setLike.{0} Real Real.addGroup)) (AddSubgroup.zmultiples.{0} Real Real.addGroup a))) (Filter.cocompact.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)))
but is expected to have type
  forall (a : Real), Filter.Tendsto.{0, 0} (Subtype.{1} Real (fun (x : Real) => Membership.mem.{0, 0} Real (AddSubgroup.{0} Real Real.instAddGroupReal) (SetLike.instMembership.{0, 0} (AddSubgroup.{0} Real Real.instAddGroupReal) Real (AddSubgroup.instSetLikeAddSubgroup.{0} Real Real.instAddGroupReal)) x (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) Real (FunLike.coe.{1, 1, 1} (AddMonoidHom.{0, 0} (Subtype.{1} Real (fun (x : Real) => Membership.mem.{0, 0} Real (AddSubgroup.{0} Real Real.instAddGroupReal) (SetLike.instMembership.{0, 0} (AddSubgroup.{0} Real Real.instAddGroupReal) Real (AddSubgroup.instSetLikeAddSubgroup.{0} Real Real.instAddGroupReal)) x (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) Real (AddSubmonoid.toAddZeroClass.{0} Real (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal))) (AddSubgroup.toAddSubmonoid.{0} Real Real.instAddGroupReal (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal)))) (Subtype.{1} Real (fun (x : Real) => Membership.mem.{0, 0} Real (AddSubgroup.{0} Real Real.instAddGroupReal) (SetLike.instMembership.{0, 0} (AddSubgroup.{0} Real Real.instAddGroupReal) Real (AddSubgroup.instSetLikeAddSubgroup.{0} Real Real.instAddGroupReal)) x (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) (fun (_x : Subtype.{1} Real (fun (x : Real) => Membership.mem.{0, 0} Real (AddSubgroup.{0} Real Real.instAddGroupReal) (SetLike.instMembership.{0, 0} (AddSubgroup.{0} Real Real.instAddGroupReal) Real (AddSubgroup.instSetLikeAddSubgroup.{0} Real Real.instAddGroupReal)) x (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.398 : Subtype.{1} Real (fun (x : Real) => Membership.mem.{0, 0} Real (AddSubgroup.{0} Real Real.instAddGroupReal) (SetLike.instMembership.{0, 0} (AddSubgroup.{0} Real Real.instAddGroupReal) Real (AddSubgroup.instSetLikeAddSubgroup.{0} Real Real.instAddGroupReal)) x (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) => Real) _x) (AddHomClass.toFunLike.{0, 0, 0} (AddMonoidHom.{0, 0} (Subtype.{1} Real (fun (x : Real) => Membership.mem.{0, 0} Real (AddSubgroup.{0} Real Real.instAddGroupReal) (SetLike.instMembership.{0, 0} (AddSubgroup.{0} Real Real.instAddGroupReal) Real (AddSubgroup.instSetLikeAddSubgroup.{0} Real Real.instAddGroupReal)) x (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) Real (AddSubmonoid.toAddZeroClass.{0} Real (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal))) (AddSubgroup.toAddSubmonoid.{0} Real Real.instAddGroupReal (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal)))) (Subtype.{1} Real (fun (x : Real) => Membership.mem.{0, 0} Real (AddSubgroup.{0} Real Real.instAddGroupReal) (SetLike.instMembership.{0, 0} (AddSubgroup.{0} Real Real.instAddGroupReal) Real (AddSubgroup.instSetLikeAddSubgroup.{0} Real Real.instAddGroupReal)) x (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) Real (AddZeroClass.toAdd.{0} (Subtype.{1} Real (fun (x : Real) => Membership.mem.{0, 0} Real (AddSubgroup.{0} Real Real.instAddGroupReal) (SetLike.instMembership.{0, 0} (AddSubgroup.{0} Real Real.instAddGroupReal) Real (AddSubgroup.instSetLikeAddSubgroup.{0} Real Real.instAddGroupReal)) x (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) (AddSubmonoid.toAddZeroClass.{0} Real (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal))) (AddSubgroup.toAddSubmonoid.{0} Real Real.instAddGroupReal (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a)))) (AddZeroClass.toAdd.{0} Real (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal)))) (AddMonoidHomClass.toAddHomClass.{0, 0, 0} (AddMonoidHom.{0, 0} (Subtype.{1} Real (fun (x : Real) => Membership.mem.{0, 0} Real (AddSubgroup.{0} Real Real.instAddGroupReal) (SetLike.instMembership.{0, 0} (AddSubgroup.{0} Real Real.instAddGroupReal) Real (AddSubgroup.instSetLikeAddSubgroup.{0} Real Real.instAddGroupReal)) x (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) Real (AddSubmonoid.toAddZeroClass.{0} Real (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal))) (AddSubgroup.toAddSubmonoid.{0} Real Real.instAddGroupReal (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal)))) (Subtype.{1} Real (fun (x : Real) => Membership.mem.{0, 0} Real (AddSubgroup.{0} Real Real.instAddGroupReal) (SetLike.instMembership.{0, 0} (AddSubgroup.{0} Real Real.instAddGroupReal) Real (AddSubgroup.instSetLikeAddSubgroup.{0} Real Real.instAddGroupReal)) x (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) Real (AddSubmonoid.toAddZeroClass.{0} Real (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal))) (AddSubgroup.toAddSubmonoid.{0} Real Real.instAddGroupReal (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal))) (AddMonoidHom.addMonoidHomClass.{0, 0} (Subtype.{1} Real (fun (x : Real) => Membership.mem.{0, 0} Real (AddSubgroup.{0} Real Real.instAddGroupReal) (SetLike.instMembership.{0, 0} (AddSubgroup.{0} Real Real.instAddGroupReal) Real (AddSubgroup.instSetLikeAddSubgroup.{0} Real Real.instAddGroupReal)) x (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) Real (AddSubmonoid.toAddZeroClass.{0} Real (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal))) (AddSubgroup.toAddSubmonoid.{0} Real Real.instAddGroupReal (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) (AddMonoid.toAddZeroClass.{0} Real (SubNegMonoid.toAddMonoid.{0} Real (AddGroup.toSubNegMonoid.{0} Real Real.instAddGroupReal)))))) (AddSubgroup.subtype.{0} Real Real.instAddGroupReal (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a))) (Filter.cofinite.{0} (Subtype.{1} Real (fun (x : Real) => Membership.mem.{0, 0} Real (AddSubgroup.{0} Real Real.instAddGroupReal) (SetLike.instMembership.{0, 0} (AddSubgroup.{0} Real Real.instAddGroupReal) Real (AddSubgroup.instSetLikeAddSubgroup.{0} Real Real.instAddGroupReal)) x (AddSubgroup.zmultiples.{0} Real Real.instAddGroupReal a)))) (Filter.cocompact.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)))
Case conversion may be inaccurate. Consider using '#align add_subgroup.tendsto_zmultiples_subtype_cofinite AddSubgroup.tendsto_zmultiples_subtype_cofiniteₓ'. -/
/-- The subgroup "multiples of `a`" (`zmultiples a`) is a discrete subgroup of `ℝ`, i.e. its
intersection with compact sets is finite. -/
theorem tendsto_zmultiples_subtype_cofinite (a : ℝ) :
    Tendsto (zmultiples a).Subtype cofinite (cocompact ℝ) :=
  by
  rcases eq_or_ne a 0 with (rfl | ha)
  · rw [AddSubgroup.zmultiples_zero_eq_bot]
    intro K hK
    rw [Filter.mem_map, mem_cofinite]
    apply Set.toFinite
  intro K hK
  have H := Int.tendsto_zmultiplesHom_cofinite ha hK
  simp only [Filter.mem_map, mem_cofinite, ← preimage_compl] at H⊢
  rw [← (zmultiplesHom ℝ a).rangeRestrict_surjective.image_preimage ((zmultiples a).Subtype ⁻¹' Kᶜ),
    ← preimage_comp, ← AddMonoidHom.coe_comp_rangeRestrict]
  exact finite.image _ H
#align add_subgroup.tendsto_zmultiples_subtype_cofinite AddSubgroup.tendsto_zmultiples_subtype_cofinite

end AddSubgroup

/-- Given a nontrivial subgroup `G ⊆ ℝ`, if `G ∩ ℝ_{>0}` has no minimum then `G` is dense. -/
theorem AddSubgroup.dense_of_no_min {G : AddSubgroup ℝ} {g₀ : ℝ} (g₀_in : g₀ ∈ G) (g₀_ne : g₀ ≠ 0)
    (H' : ¬∃ a : ℝ, IsLeast { g : ℝ | g ∈ G ∧ 0 < g } a) : Dense (G : Set ℝ) :=
  by
  let G_pos := { g : ℝ | g ∈ G ∧ 0 < g }
  push_neg  at H'
  intro x
  suffices ∀ ε > (0 : ℝ), ∃ g ∈ G, |x - g| < ε by simpa only [Real.mem_closure_iff, abs_sub_comm]
  intro ε ε_pos
  obtain ⟨g₁, g₁_in, g₁_pos⟩ : ∃ g₁ : ℝ, g₁ ∈ G ∧ 0 < g₁ :=
    by
    cases' lt_or_gt_of_ne g₀_ne with Hg₀ Hg₀
    · exact ⟨-g₀, G.neg_mem g₀_in, neg_pos.mpr Hg₀⟩
    · exact ⟨g₀, g₀_in, Hg₀⟩
  obtain ⟨a, ha⟩ : ∃ a, IsGLB G_pos a :=
    ⟨Inf G_pos, isGLB_cinfₛ ⟨g₁, g₁_in, g₁_pos⟩ ⟨0, fun _ hx => le_of_lt hx.2⟩⟩
  have a_notin : a ∉ G_pos := by
    intro H
    exact H' a ⟨H, ha.1⟩
  obtain ⟨g₂, g₂_in, g₂_pos, g₂_lt⟩ : ∃ g₂ : ℝ, g₂ ∈ G ∧ 0 < g₂ ∧ g₂ < ε :=
    by
    obtain ⟨b, hb, hb', hb''⟩ := ha.exists_between_self_add' a_notin ε_pos
    obtain ⟨c, hc, hc', hc''⟩ := ha.exists_between_self_add' a_notin (sub_pos.2 hb')
    refine' ⟨b - c, G.sub_mem hb.1 hc.1, _, _⟩ <;> linarith
  refine' ⟨floor (x / g₂) * g₂, _, _⟩
  · exact AddSubgroup.int_mul_mem _ g₂_in
  · rw [abs_of_nonneg (sub_floor_div_mul_nonneg x g₂_pos)]
    linarith [sub_floor_div_mul_lt x g₂_pos]
#align real.subgroup_dense_of_no_min AddSubgroup.dense_of_no_minₓ

/-- Subgroups of `ℝ` are either dense or cyclic. See `real.subgroup_dense_of_no_min` and
`subgroup_cyclic_of_min` for more precise statements. -/
theorem AddSubgroup.dense_or_cyclic (G : AddSubgroup ℝ) :
    Dense (G : Set ℝ) ∨ ∃ a : ℝ, G = AddSubgroup.closure {a} :=
  by
  cases' AddSubgroup.bot_or_exists_ne_zero G with H H
  · right
    use 0
    rw [H, AddSubgroup.closure_singleton_zero]
  · let G_pos := { g : ℝ | g ∈ G ∧ 0 < g }
    by_cases H' : ∃ a, IsLeast G_pos a
    · right
      rcases H' with ⟨a, ha⟩
      exact ⟨a, AddSubgroup.cyclic_of_min ha⟩
    · left
      rcases H with ⟨g₀, g₀_in, g₀_ne⟩
      exact AddSubgroup.dense_of_no_min g₀_in g₀_ne H'
#align real.subgroup_dense_or_cyclic AddSubgroup.dense_or_cyclicₓ

end Subgroups

