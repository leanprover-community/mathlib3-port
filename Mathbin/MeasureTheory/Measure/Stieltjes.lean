/-
Copyright (c) 2021 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Yury Kudryashov, Sébastien Gouëzel

! This file was ported from Lean 3 source module measure_theory.measure.stieltjes
! leanprover-community/mathlib commit 4280f5f32e16755ec7985ce11e189b6cd6ff6735
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Constructions.BorelSpace.Basic
import Mathbin.Topology.Algebra.Order.LeftRightLim

/-!
# Stieltjes measures on the real line

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Consider a function `f : ℝ → ℝ` which is monotone and right-continuous. Then one can define a
corrresponding measure, giving mass `f b - f a` to the interval `(a, b]`.

## Main definitions

* `stieltjes_function` is a structure containing a function from `ℝ → ℝ`, together with the
assertions that it is monotone and right-continuous. To `f : stieltjes_function`, one associates
a Borel measure `f.measure`.
* `f.measure_Ioc` asserts that `f.measure (Ioc a b) = of_real (f b - f a)`
* `f.measure_Ioo` asserts that `f.measure (Ioo a b) = of_real (left_lim f b - f a)`.
* `f.measure_Icc` and `f.measure_Ico` are analogous.
-/


section MoveThis

-- this section contains lemmas that should be moved to appropriate places after the port to lean 4
open Filter Set

open Topology

/- warning: infi_Ioi_eq_infi_rat_gt -> iInf_Ioi_eq_iInf_rat_gt is a dubious translation:
lean 3 declaration is
  forall {f : Real -> Real} (x : Real), (BddBelow.{0} Real Real.preorder (Set.image.{0, 0} Real Real f (Set.Ioi.{0} Real Real.preorder x))) -> (Monotone.{0, 0} Real Real Real.preorder Real.preorder f) -> (Eq.{1} Real (iInf.{0, 1} Real Real.hasInf (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder x)) (fun (r : coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder x)) => f ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder x)) Real (HasLiftT.mk.{1, 1} (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder x)) Real (CoeTCₓ.coe.{1, 1} (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder x)) Real (coeBase.{1, 1} (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder x)) Real (coeSubtype.{1} Real (fun (x_1 : Real) => Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) x_1 (Set.Ioi.{0} Real Real.preorder x)))))) r))) (iInf.{0, 1} Real Real.hasInf (Subtype.{1} Rat (fun (q' : Rat) => LT.lt.{0} Real Real.hasLt x ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) q'))) (fun (q : Subtype.{1} Rat (fun (q' : Rat) => LT.lt.{0} Real Real.hasLt x ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) q'))) => f ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) (Subtype.{1} Rat (fun (q' : Rat) => LT.lt.{0} Real Real.hasLt x ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) q'))) Real (HasLiftT.mk.{1, 1} (Subtype.{1} Rat (fun (q' : Rat) => LT.lt.{0} Real Real.hasLt x ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) q'))) Real (CoeTCₓ.coe.{1, 1} (Subtype.{1} Rat (fun (q' : Rat) => LT.lt.{0} Real Real.hasLt x ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) q'))) Real (coeTrans.{1, 1, 1} (Subtype.{1} Rat (fun (q' : Rat) => LT.lt.{0} Real Real.hasLt x ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) q'))) Rat Real (Rat.castCoe.{0} Real Real.hasRatCast) (coeSubtype.{1} Rat (fun (q' : Rat) => LT.lt.{0} Real Real.hasLt x ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) q')))))) q))))
but is expected to have type
  forall {f : Real -> Real} (x : Real), (BddBelow.{0} Real Real.instPreorderReal (Set.image.{0, 0} Real Real f (Set.Ioi.{0} Real Real.instPreorderReal x))) -> (Monotone.{0, 0} Real Real Real.instPreorderReal Real.instPreorderReal f) -> (Eq.{1} Real (iInf.{0, 1} Real Real.instInfSetReal (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal x)) (fun (r : Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal x)) => f (Subtype.val.{1} Real (fun (x_1 : Real) => Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) x_1 (Set.Ioi.{0} Real Real.instPreorderReal x)) r))) (iInf.{0, 1} Real Real.instInfSetReal (Subtype.{1} Rat (fun (q' : Rat) => LT.lt.{0} Real Real.instLTReal x (Rat.cast.{0} Real Real.ratCast q'))) (fun (q : Subtype.{1} Rat (fun (q' : Rat) => LT.lt.{0} Real Real.instLTReal x (Rat.cast.{0} Real Real.ratCast q'))) => f (Rat.cast.{0} Real Real.ratCast (Subtype.val.{1} Rat (fun (q' : Rat) => LT.lt.{0} Real Real.instLTReal x (Rat.cast.{0} Real Real.ratCast q')) q)))))
Case conversion may be inaccurate. Consider using '#align infi_Ioi_eq_infi_rat_gt iInf_Ioi_eq_iInf_rat_gtₓ'. -/
theorem iInf_Ioi_eq_iInf_rat_gt {f : ℝ → ℝ} (x : ℝ) (hf : BddBelow (f '' Ioi x))
    (hf_mono : Monotone f) : (⨅ r : Ioi x, f r) = ⨅ q : { q' : ℚ // x < q' }, f q :=
  by
  refine' le_antisymm _ _
  · have : Nonempty { r' : ℚ // x < ↑r' } :=
      by
      obtain ⟨r, hrx⟩ := exists_rat_gt x
      exact ⟨⟨r, hrx⟩⟩
    refine' le_ciInf fun r => _
    obtain ⟨y, hxy, hyr⟩ := exists_rat_btwn r.prop
    refine' ciInf_set_le hf (hxy.trans _)
    exact_mod_cast hyr
  · refine' le_ciInf fun q => _
    have hq := q.prop
    rw [mem_Ioi] at hq
    obtain ⟨y, hxy, hyq⟩ := exists_rat_btwn hq
    refine' (ciInf_le _ _).trans _
    · exact ⟨y, hxy⟩
    · refine' ⟨hf.some, fun z => _⟩
      rintro ⟨u, rfl⟩
      suffices hfu : f u ∈ f '' Ioi x; exact hf.some_spec hfu
      exact ⟨u, u.prop, rfl⟩
    · refine' hf_mono (le_trans _ hyq.le)
      norm_cast
#align infi_Ioi_eq_infi_rat_gt iInf_Ioi_eq_iInf_rat_gt

/- warning: right_lim_eq_of_tendsto -> rightLim_eq_of_tendsto is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [hα : TopologicalSpace.{u1} α] [h'α : OrderTopology.{u1} α hα (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))] [_inst_3 : T2Space.{u2} β _inst_2] {f : α -> β} {a : α} {y : β}, (Ne.{succ u1} (Filter.{u1} α) (nhdsWithin.{u1} α hα a (Set.Ioi.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) a)) (Bot.bot.{u1} (Filter.{u1} α) (CompleteLattice.toHasBot.{u1} (Filter.{u1} α) (Filter.completeLattice.{u1} α)))) -> (Filter.Tendsto.{u1, u2} α β f (nhdsWithin.{u1} α hα a (Set.Ioi.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) a)) (nhds.{u2} β _inst_2 y)) -> (Eq.{succ u2} β (Function.rightLim.{u1, u2} α β _inst_1 _inst_2 f a) y)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] [hα : TopologicalSpace.{u2} α] [h'α : OrderTopology.{u2} α hα (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))] [_inst_3 : T2Space.{u1} β _inst_2] {f : α -> β} {a : α} {y : β}, (Ne.{succ u2} (Filter.{u2} α) (nhdsWithin.{u2} α hα a (Set.Ioi.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) a)) (Bot.bot.{u2} (Filter.{u2} α) (CompleteLattice.toBot.{u2} (Filter.{u2} α) (Filter.instCompleteLatticeFilter.{u2} α)))) -> (Filter.Tendsto.{u2, u1} α β f (nhdsWithin.{u2} α hα a (Set.Ioi.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) a)) (nhds.{u1} β _inst_2 y)) -> (Eq.{succ u1} β (Function.rightLim.{u2, u1} α β _inst_1 _inst_2 f a) y)
Case conversion may be inaccurate. Consider using '#align right_lim_eq_of_tendsto rightLim_eq_of_tendstoₓ'. -/
-- todo after the port: move to topology/algebra/order/left_right_lim
theorem rightLim_eq_of_tendsto {α β : Type _} [LinearOrder α] [TopologicalSpace β]
    [hα : TopologicalSpace α] [h'α : OrderTopology α] [T2Space β] {f : α → β} {a : α} {y : β}
    (h : 𝓝[>] a ≠ ⊥) (h' : Tendsto f (𝓝[>] a) (𝓝 y)) : Function.rightLim f a = y :=
  @leftLim_eq_of_tendsto αᵒᵈ _ _ _ _ _ _ f a y h h'
#align right_lim_eq_of_tendsto rightLim_eq_of_tendsto

/- warning: right_lim_eq_Inf -> rightLim_eq_sInf is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : TopologicalSpace.{u2} β] [_inst_3 : ConditionallyCompleteLinearOrder.{u2} β] [_inst_4 : OrderTopology.{u2} β _inst_2 (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_3)))))] {f : α -> β}, (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (ConditionallyCompleteLattice.toLattice.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_3))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u1} α] [_inst_6 : OrderTopology.{u1} α _inst_5 (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))], (Ne.{succ u1} (Filter.{u1} α) (nhdsWithin.{u1} α _inst_5 x (Set.Ioi.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x)) (Bot.bot.{u1} (Filter.{u1} α) (CompleteLattice.toHasBot.{u1} (Filter.{u1} α) (Filter.completeLattice.{u1} α)))) -> (Eq.{succ u2} β (Function.rightLim.{u1, u2} α β _inst_1 _inst_2 f x) (InfSet.sInf.{u2} β (ConditionallyCompleteLattice.toHasInf.{u2} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u2} β _inst_3)) (Set.image.{u1, u2} α β f (Set.Ioi.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) x)))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : TopologicalSpace.{u1} β] [_inst_3 : ConditionallyCompleteLinearOrder.{u1} β] [_inst_4 : OrderTopology.{u1} β _inst_2 (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_3)))))] {f : α -> β}, (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (ConditionallyCompleteLattice.toLattice.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_3))))) f) -> (forall {x : α} [_inst_5 : TopologicalSpace.{u2} α] [_inst_6 : OrderTopology.{u2} α _inst_5 (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)))))], (Ne.{succ u2} (Filter.{u2} α) (nhdsWithin.{u2} α _inst_5 x (Set.Ioi.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x)) (Bot.bot.{u2} (Filter.{u2} α) (CompleteLattice.toBot.{u2} (Filter.{u2} α) (Filter.instCompleteLatticeFilter.{u2} α)))) -> (Eq.{succ u1} β (Function.rightLim.{u2, u1} α β _inst_1 _inst_2 f x) (InfSet.sInf.{u1} β (ConditionallyCompleteLattice.toInfSet.{u1} β (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{u1} β _inst_3)) (Set.image.{u2, u1} α β f (Set.Ioi.{u2} α (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) x)))))
Case conversion may be inaccurate. Consider using '#align right_lim_eq_Inf rightLim_eq_sInfₓ'. -/
-- todo after the port: move to topology/algebra/order/left_right_lim
theorem rightLim_eq_sInf {α β : Type _} [LinearOrder α] [TopologicalSpace β]
    [ConditionallyCompleteLinearOrder β] [OrderTopology β] {f : α → β} (hf : Monotone f) {x : α}
    [TopologicalSpace α] [OrderTopology α] (h : 𝓝[>] x ≠ ⊥) :
    Function.rightLim f x = sInf (f '' Ioi x) :=
  rightLim_eq_of_tendsto h (hf.tendsto_nhdsWithin_Ioi x)
#align right_lim_eq_Inf rightLim_eq_sInf

#print exists_seq_monotone_tendsto_atTop_atTop /-
-- todo after the port: move to order/filter/at_top_bot
theorem exists_seq_monotone_tendsto_atTop_atTop (α : Type _) [SemilatticeSup α] [Nonempty α]
    [(atTop : Filter α).IsCountablyGenerated] :
    ∃ xs : ℕ → α, Monotone xs ∧ Tendsto xs atTop atTop :=
  by
  haveI h_ne_bot : (at_top : Filter α).ne_bot := at_top_ne_bot
  obtain ⟨ys, h⟩ := exists_seq_tendsto (at_top : Filter α)
  let xs : ℕ → α := fun n => Finset.sup' (Finset.range (n + 1)) Finset.nonempty_range_succ ys
  have h_mono : Monotone xs := by
    intro i j hij
    rw [Finset.sup'_le_iff]
    intro k hk
    refine' Finset.le_sup'_of_le _ _ le_rfl
    rw [Finset.mem_range] at hk⊢
    exact hk.trans_le (add_le_add_right hij _)
  refine' ⟨xs, h_mono, _⟩
  · refine' tendsto_at_top_at_top_of_monotone h_mono _
    have : ∀ a : α, ∃ n : ℕ, a ≤ ys n :=
      by
      rw [tendsto_at_top_at_top] at h
      intro a
      obtain ⟨i, hi⟩ := h a
      exact ⟨i, hi i le_rfl⟩
    intro a
    obtain ⟨i, hi⟩ := this a
    refine' ⟨i, hi.trans _⟩
    refine' Finset.le_sup'_of_le _ _ le_rfl
    rw [Finset.mem_range_succ_iff]
#align exists_seq_monotone_tendsto_at_top_at_top exists_seq_monotone_tendsto_atTop_atTop
-/

#print exists_seq_antitone_tendsto_atTop_atBot /-
theorem exists_seq_antitone_tendsto_atTop_atBot (α : Type _) [SemilatticeInf α] [Nonempty α]
    [h2 : (atBot : Filter α).IsCountablyGenerated] :
    ∃ xs : ℕ → α, Antitone xs ∧ Tendsto xs atTop atBot :=
  @exists_seq_monotone_tendsto_atTop_atTop αᵒᵈ _ _ h2
#align exists_seq_antitone_tendsto_at_top_at_bot exists_seq_antitone_tendsto_atTop_atBot
-/

/- warning: supr_eq_supr_subseq_of_antitone -> iSup_eq_iSup_subseq_of_antitone is a dubious translation:
lean 3 declaration is
  forall {ι₁ : Type.{u1}} {ι₂ : Type.{u2}} {α : Type.{u3}} [_inst_1 : Preorder.{u2} ι₂] [_inst_2 : CompleteLattice.{u3} α] {l : Filter.{u1} ι₁} [_inst_3 : Filter.NeBot.{u1} ι₁ l] {f : ι₂ -> α} {φ : ι₁ -> ι₂}, (Antitone.{u2, u3} ι₂ α _inst_1 (PartialOrder.toPreorder.{u3} α (CompleteSemilatticeInf.toPartialOrder.{u3} α (CompleteLattice.toCompleteSemilatticeInf.{u3} α _inst_2))) f) -> (Filter.Tendsto.{u1, u2} ι₁ ι₂ φ l (Filter.atBot.{u2} ι₂ _inst_1)) -> (Eq.{succ u3} α (iSup.{u3, succ u2} α (ConditionallyCompleteLattice.toHasSup.{u3} α (CompleteLattice.toConditionallyCompleteLattice.{u3} α _inst_2)) ι₂ (fun (i : ι₂) => f i)) (iSup.{u3, succ u1} α (ConditionallyCompleteLattice.toHasSup.{u3} α (CompleteLattice.toConditionallyCompleteLattice.{u3} α _inst_2)) ι₁ (fun (i : ι₁) => f (φ i))))
but is expected to have type
  forall {ι₁ : Type.{u3}} {ι₂ : Type.{u2}} {α : Type.{u1}} [_inst_1 : Preorder.{u2} ι₂] [_inst_2 : CompleteLattice.{u1} α] {l : Filter.{u3} ι₁} [_inst_3 : Filter.NeBot.{u3} ι₁ l] {f : ι₂ -> α} {φ : ι₁ -> ι₂}, (Antitone.{u2, u1} ι₂ α _inst_1 (PartialOrder.toPreorder.{u1} α (OmegaCompletePartialOrder.toPartialOrder.{u1} α (CompleteLattice.instOmegaCompletePartialOrder.{u1} α _inst_2))) f) -> (Filter.Tendsto.{u3, u2} ι₁ ι₂ φ l (Filter.atBot.{u2} ι₂ _inst_1)) -> (Eq.{succ u1} α (iSup.{u1, succ u2} α (ConditionallyCompleteLattice.toSupSet.{u1} α (CompleteLattice.toConditionallyCompleteLattice.{u1} α _inst_2)) ι₂ (fun (i : ι₂) => f i)) (iSup.{u1, succ u3} α (ConditionallyCompleteLattice.toSupSet.{u1} α (CompleteLattice.toConditionallyCompleteLattice.{u1} α _inst_2)) ι₁ (fun (i : ι₁) => f (φ i))))
Case conversion may be inaccurate. Consider using '#align supr_eq_supr_subseq_of_antitone iSup_eq_iSup_subseq_of_antitoneₓ'. -/
-- todo after the port: move to topology/algebra/order/monotone_convergence
theorem iSup_eq_iSup_subseq_of_antitone {ι₁ ι₂ α : Type _} [Preorder ι₂] [CompleteLattice α]
    {l : Filter ι₁} [l.ne_bot] {f : ι₂ → α} {φ : ι₁ → ι₂} (hf : Antitone f)
    (hφ : Tendsto φ l atBot) : (⨆ i, f i) = ⨆ i, f (φ i) :=
  le_antisymm
    (iSup_mono' fun i =>
      Exists.imp (fun j (hj : φ j ≤ i) => hf hj) (hφ.Eventually <| eventually_le_atBot i).exists)
    (iSup_mono' fun i => ⟨φ i, le_rfl⟩)
#align supr_eq_supr_subseq_of_antitone iSup_eq_iSup_subseq_of_antitone

namespace MeasureTheory

-- todo after the port: move these lemmas to measure_theory/measure/measure_space?
variable {α : Type _} {mα : MeasurableSpace α}

include mα

/- warning: measure_theory.tendsto_measure_Ico_at_top -> MeasureTheory.tendsto_measure_Ico_atTop is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {mα : MeasurableSpace.{u1} α} [_inst_1 : SemilatticeSup.{u1} α] [_inst_2 : NoMaxOrder.{u1} α (Preorder.toHasLt.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))] [_inst_3 : Filter.IsCountablyGenerated.{u1} α (Filter.atTop.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))] (μ : MeasureTheory.Measure.{u1} α mα) (a : α), Filter.Tendsto.{u1, 0} α ENNReal (fun (x : α) => coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} α mα) (fun (_x : MeasureTheory.Measure.{u1} α mα) => (Set.{u1} α) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} α mα) μ (Set.Ico.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)) a x)) (Filter.atTop.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) (nhds.{0} ENNReal ENNReal.topologicalSpace (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} α mα) (fun (_x : MeasureTheory.Measure.{u1} α mα) => (Set.{u1} α) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} α mα) μ (Set.Ici.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)) a)))
but is expected to have type
  forall {α : Type.{u1}} {mα : MeasurableSpace.{u1} α} [_inst_1 : SemilatticeSup.{u1} α] [_inst_2 : NoMaxOrder.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))] [_inst_3 : Filter.IsCountablyGenerated.{u1} α (Filter.atTop.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))] (μ : MeasureTheory.Measure.{u1} α mα) (a : α), Filter.Tendsto.{u1, 0} α ENNReal (fun (x : α) => MeasureTheory.OuterMeasure.measureOf.{u1} α (MeasureTheory.Measure.toOuterMeasure.{u1} α mα μ) (Set.Ico.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)) a x)) (Filter.atTop.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) (nhds.{0} ENNReal ENNReal.instTopologicalSpaceENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} α (MeasureTheory.Measure.toOuterMeasure.{u1} α mα μ) (Set.Ici.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)) a)))
Case conversion may be inaccurate. Consider using '#align measure_theory.tendsto_measure_Ico_at_top MeasureTheory.tendsto_measure_Ico_atTopₓ'. -/
theorem tendsto_measure_Ico_atTop [SemilatticeSup α] [NoMaxOrder α]
    [(atTop : Filter α).IsCountablyGenerated] (μ : Measure α) (a : α) :
    Tendsto (fun x => μ (Ico a x)) atTop (𝓝 (μ (Ici a))) :=
  by
  haveI : Nonempty α := ⟨a⟩
  have h_mono : Monotone fun x => μ (Ico a x) := fun i j hij =>
    measure_mono (Ico_subset_Ico_right hij)
  convert tendsto_atTop_iSup h_mono
  obtain ⟨xs, hxs_mono, hxs_tendsto⟩ := exists_seq_monotone_tendsto_atTop_atTop α
  have h_Ici : Ici a = ⋃ n, Ico a (xs n) := by
    ext1 x
    simp only [mem_Ici, mem_Union, mem_Ico, exists_and_left, iff_self_and]
    intro
    obtain ⟨y, hxy⟩ := NoMaxOrder.exists_gt x
    obtain ⟨n, hn⟩ := tendsto_at_top_at_top.mp hxs_tendsto y
    exact ⟨n, hxy.trans_le (hn n le_rfl)⟩
  rw [h_Ici, measure_Union_eq_supr, iSup_eq_iSup_subseq_of_monotone h_mono hxs_tendsto]
  exact Monotone.directed_le fun i j hij => Ico_subset_Ico_right (hxs_mono hij)
#align measure_theory.tendsto_measure_Ico_at_top MeasureTheory.tendsto_measure_Ico_atTop

/- warning: measure_theory.tendsto_measure_Ioc_at_bot -> MeasureTheory.tendsto_measure_Ioc_atBot is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {mα : MeasurableSpace.{u1} α} [_inst_1 : SemilatticeInf.{u1} α] [_inst_2 : NoMinOrder.{u1} α (Preorder.toHasLt.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))] [_inst_3 : Filter.IsCountablyGenerated.{u1} α (Filter.atBot.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))] (μ : MeasureTheory.Measure.{u1} α mα) (a : α), Filter.Tendsto.{u1, 0} α ENNReal (fun (x : α) => coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} α mα) (fun (_x : MeasureTheory.Measure.{u1} α mα) => (Set.{u1} α) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} α mα) μ (Set.Ioc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)) x a)) (Filter.atBot.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) (nhds.{0} ENNReal ENNReal.topologicalSpace (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} α mα) (fun (_x : MeasureTheory.Measure.{u1} α mα) => (Set.{u1} α) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} α mα) μ (Set.Iic.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)) a)))
but is expected to have type
  forall {α : Type.{u1}} {mα : MeasurableSpace.{u1} α} [_inst_1 : SemilatticeInf.{u1} α] [_inst_2 : NoMinOrder.{u1} α (Preorder.toLT.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))] [_inst_3 : Filter.IsCountablyGenerated.{u1} α (Filter.atBot.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))] (μ : MeasureTheory.Measure.{u1} α mα) (a : α), Filter.Tendsto.{u1, 0} α ENNReal (fun (x : α) => MeasureTheory.OuterMeasure.measureOf.{u1} α (MeasureTheory.Measure.toOuterMeasure.{u1} α mα μ) (Set.Ioc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)) x a)) (Filter.atBot.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) (nhds.{0} ENNReal ENNReal.instTopologicalSpaceENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} α (MeasureTheory.Measure.toOuterMeasure.{u1} α mα μ) (Set.Iic.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)) a)))
Case conversion may be inaccurate. Consider using '#align measure_theory.tendsto_measure_Ioc_at_bot MeasureTheory.tendsto_measure_Ioc_atBotₓ'. -/
theorem tendsto_measure_Ioc_atBot [SemilatticeInf α] [NoMinOrder α]
    [(atBot : Filter α).IsCountablyGenerated] (μ : Measure α) (a : α) :
    Tendsto (fun x => μ (Ioc x a)) atBot (𝓝 (μ (Iic a))) :=
  by
  haveI : Nonempty α := ⟨a⟩
  have h_mono : Antitone fun x => μ (Ioc x a) := fun i j hij =>
    measure_mono (Ioc_subset_Ioc_left hij)
  convert tendsto_atBot_iSup h_mono
  obtain ⟨xs, hxs_mono, hxs_tendsto⟩ := exists_seq_antitone_tendsto_atTop_atBot α
  have h_Iic : Iic a = ⋃ n, Ioc (xs n) a := by
    ext1 x
    simp only [mem_Iic, mem_Union, mem_Ioc, exists_and_right, iff_and_self]
    intro
    obtain ⟨y, hxy⟩ := NoMinOrder.exists_lt x
    obtain ⟨n, hn⟩ := tendsto_at_top_at_bot.mp hxs_tendsto y
    exact ⟨n, (hn n le_rfl).trans_lt hxy⟩
  rw [h_Iic, measure_Union_eq_supr, iSup_eq_iSup_subseq_of_antitone h_mono hxs_tendsto]
  exact Monotone.directed_le fun i j hij => Ioc_subset_Ioc_left (hxs_mono hij)
#align measure_theory.tendsto_measure_Ioc_at_bot MeasureTheory.tendsto_measure_Ioc_atBot

/- warning: measure_theory.tendsto_measure_Iic_at_top -> MeasureTheory.tendsto_measure_Iic_atTop is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {mα : MeasurableSpace.{u1} α} [_inst_1 : SemilatticeSup.{u1} α] [_inst_2 : Filter.IsCountablyGenerated.{u1} α (Filter.atTop.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))] (μ : MeasureTheory.Measure.{u1} α mα), Filter.Tendsto.{u1, 0} α ENNReal (fun (x : α) => coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} α mα) (fun (_x : MeasureTheory.Measure.{u1} α mα) => (Set.{u1} α) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} α mα) μ (Set.Iic.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)) x)) (Filter.atTop.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) (nhds.{0} ENNReal ENNReal.topologicalSpace (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} α mα) (fun (_x : MeasureTheory.Measure.{u1} α mα) => (Set.{u1} α) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} α mα) μ (Set.univ.{u1} α)))
but is expected to have type
  forall {α : Type.{u1}} {mα : MeasurableSpace.{u1} α} [_inst_1 : SemilatticeSup.{u1} α] [_inst_2 : Filter.IsCountablyGenerated.{u1} α (Filter.atTop.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)))] (μ : MeasureTheory.Measure.{u1} α mα), Filter.Tendsto.{u1, 0} α ENNReal (fun (x : α) => MeasureTheory.OuterMeasure.measureOf.{u1} α (MeasureTheory.Measure.toOuterMeasure.{u1} α mα μ) (Set.Iic.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1)) x)) (Filter.atTop.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeSup.toPartialOrder.{u1} α _inst_1))) (nhds.{0} ENNReal ENNReal.instTopologicalSpaceENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} α (MeasureTheory.Measure.toOuterMeasure.{u1} α mα μ) (Set.univ.{u1} α)))
Case conversion may be inaccurate. Consider using '#align measure_theory.tendsto_measure_Iic_at_top MeasureTheory.tendsto_measure_Iic_atTopₓ'. -/
theorem tendsto_measure_Iic_atTop [SemilatticeSup α] [(atTop : Filter α).IsCountablyGenerated]
    (μ : Measure α) : Tendsto (fun x => μ (Iic x)) atTop (𝓝 (μ univ)) :=
  by
  cases isEmpty_or_nonempty α
  · have h1 : ∀ x : α, Iic x = ∅ := fun x => Subsingleton.elim _ _
    have h2 : (univ : Set α) = ∅ := Subsingleton.elim _ _
    simp_rw [h1, h2]
    exact tendsto_const_nhds
  have h_mono : Monotone fun x => μ (Iic x) := fun i j hij => measure_mono (Iic_subset_Iic.mpr hij)
  convert tendsto_atTop_iSup h_mono
  obtain ⟨xs, hxs_mono, hxs_tendsto⟩ := exists_seq_monotone_tendsto_atTop_atTop α
  have h_univ : (univ : Set α) = ⋃ n, Iic (xs n) :=
    by
    ext1 x
    simp only [mem_univ, mem_Union, mem_Iic, true_iff_iff]
    obtain ⟨n, hn⟩ := tendsto_at_top_at_top.mp hxs_tendsto x
    exact ⟨n, hn n le_rfl⟩
  rw [h_univ, measure_Union_eq_supr, iSup_eq_iSup_subseq_of_monotone h_mono hxs_tendsto]
  exact Monotone.directed_le fun i j hij => Iic_subset_Iic.mpr (hxs_mono hij)
#align measure_theory.tendsto_measure_Iic_at_top MeasureTheory.tendsto_measure_Iic_atTop

/- warning: measure_theory.tendsto_measure_Ici_at_bot -> MeasureTheory.tendsto_measure_Ici_atBot is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {mα : MeasurableSpace.{u1} α} [_inst_1 : SemilatticeInf.{u1} α] [h : Filter.IsCountablyGenerated.{u1} α (Filter.atBot.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))] (μ : MeasureTheory.Measure.{u1} α mα), Filter.Tendsto.{u1, 0} α ENNReal (fun (x : α) => coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} α mα) (fun (_x : MeasureTheory.Measure.{u1} α mα) => (Set.{u1} α) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} α mα) μ (Set.Ici.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)) x)) (Filter.atBot.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) (nhds.{0} ENNReal ENNReal.topologicalSpace (coeFn.{succ u1, succ u1} (MeasureTheory.Measure.{u1} α mα) (fun (_x : MeasureTheory.Measure.{u1} α mα) => (Set.{u1} α) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{u1} α mα) μ (Set.univ.{u1} α)))
but is expected to have type
  forall {α : Type.{u1}} {mα : MeasurableSpace.{u1} α} [_inst_1 : SemilatticeInf.{u1} α] [h : Filter.IsCountablyGenerated.{u1} α (Filter.atBot.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)))] (μ : MeasureTheory.Measure.{u1} α mα), Filter.Tendsto.{u1, 0} α ENNReal (fun (x : α) => MeasureTheory.OuterMeasure.measureOf.{u1} α (MeasureTheory.Measure.toOuterMeasure.{u1} α mα μ) (Set.Ici.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1)) x)) (Filter.atBot.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α _inst_1))) (nhds.{0} ENNReal ENNReal.instTopologicalSpaceENNReal (MeasureTheory.OuterMeasure.measureOf.{u1} α (MeasureTheory.Measure.toOuterMeasure.{u1} α mα μ) (Set.univ.{u1} α)))
Case conversion may be inaccurate. Consider using '#align measure_theory.tendsto_measure_Ici_at_bot MeasureTheory.tendsto_measure_Ici_atBotₓ'. -/
theorem tendsto_measure_Ici_atBot [SemilatticeInf α] [h : (atBot : Filter α).IsCountablyGenerated]
    (μ : Measure α) : Tendsto (fun x => μ (Ici x)) atBot (𝓝 (μ univ)) :=
  @tendsto_measure_Iic_atTop αᵒᵈ _ _ h μ
#align measure_theory.tendsto_measure_Ici_at_bot MeasureTheory.tendsto_measure_Ici_atBot

end MeasureTheory

end MoveThis

noncomputable section

open Classical Set Filter Function

open ENNReal (ofReal)

open BigOperators ENNReal NNReal Topology MeasureTheory

/-! ### Basic properties of Stieltjes functions -/


#print StieltjesFunction /-
/-- Bundled monotone right-continuous real functions, used to construct Stieltjes measures. -/
structure StieltjesFunction where
  toFun : ℝ → ℝ
  mono' : Monotone to_fun
  right_continuous' : ∀ x, ContinuousWithinAt to_fun (Ici x) x
#align stieltjes_function StieltjesFunction
-/

namespace StieltjesFunction

instance : CoeFun StieltjesFunction fun _ => ℝ → ℝ :=
  ⟨toFun⟩

initialize_simps_projections StieltjesFunction (toFun → apply)

variable (f : StieltjesFunction)

#print StieltjesFunction.mono /-
theorem mono : Monotone f :=
  f.mono'
#align stieltjes_function.mono StieltjesFunction.mono
-/

#print StieltjesFunction.right_continuous /-
theorem right_continuous (x : ℝ) : ContinuousWithinAt f (Ici x) x :=
  f.right_continuous' x
#align stieltjes_function.right_continuous StieltjesFunction.right_continuous
-/

#print StieltjesFunction.rightLim_eq /-
theorem rightLim_eq (f : StieltjesFunction) (x : ℝ) : Function.rightLim f x = f x :=
  by
  rw [← f.mono.continuous_within_at_Ioi_iff_right_lim_eq, continuousWithinAt_Ioi_iff_Ici]
  exact f.right_continuous' x
#align stieltjes_function.right_lim_eq StieltjesFunction.rightLim_eq
-/

/- warning: stieltjes_function.infi_Ioi_eq -> StieltjesFunction.iInf_Ioi_eq is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction) (x : Real), Eq.{1} Real (iInf.{0, 1} Real Real.hasInf (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder x)) (fun (r : coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder x)) => coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder x)) Real (HasLiftT.mk.{1, 1} (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder x)) Real (CoeTCₓ.coe.{1, 1} (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder x)) Real (coeBase.{1, 1} (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder x)) Real (coeSubtype.{1} Real (fun (x_1 : Real) => Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) x_1 (Set.Ioi.{0} Real Real.preorder x)))))) r))) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f x)
but is expected to have type
  forall (f : StieltjesFunction) (x : Real), Eq.{1} Real (iInf.{0, 1} Real Real.instInfSetReal (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal x)) (fun (r : Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal x)) => StieltjesFunction.toFun f (Subtype.val.{1} Real (fun (x_1 : Real) => Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) x_1 (Set.Ioi.{0} Real Real.instPreorderReal x)) r))) (StieltjesFunction.toFun f x)
Case conversion may be inaccurate. Consider using '#align stieltjes_function.infi_Ioi_eq StieltjesFunction.iInf_Ioi_eqₓ'. -/
theorem iInf_Ioi_eq (f : StieltjesFunction) (x : ℝ) : (⨅ r : Ioi x, f r) = f x :=
  by
  suffices Function.rightLim f x = ⨅ r : Ioi x, f r by rw [← this, f.right_lim_eq]
  rw [rightLim_eq_sInf f.mono, sInf_image']
  rw [← ne_bot_iff]
  infer_instance
#align stieltjes_function.infi_Ioi_eq StieltjesFunction.iInf_Ioi_eq

/- warning: stieltjes_function.infi_rat_gt_eq -> StieltjesFunction.iInf_rat_gt_eq is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction) (x : Real), Eq.{1} Real (iInf.{0, 1} Real Real.hasInf (Subtype.{1} Rat (fun (r' : Rat) => LT.lt.{0} Real Real.hasLt x ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) r'))) (fun (r : Subtype.{1} Rat (fun (r' : Rat) => LT.lt.{0} Real Real.hasLt x ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) r'))) => coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) (Subtype.{1} Rat (fun (r' : Rat) => LT.lt.{0} Real Real.hasLt x ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) r'))) Real (HasLiftT.mk.{1, 1} (Subtype.{1} Rat (fun (r' : Rat) => LT.lt.{0} Real Real.hasLt x ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) r'))) Real (CoeTCₓ.coe.{1, 1} (Subtype.{1} Rat (fun (r' : Rat) => LT.lt.{0} Real Real.hasLt x ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) r'))) Real (coeTrans.{1, 1, 1} (Subtype.{1} Rat (fun (r' : Rat) => LT.lt.{0} Real Real.hasLt x ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) r'))) Rat Real (Rat.castCoe.{0} Real Real.hasRatCast) (coeSubtype.{1} Rat (fun (r' : Rat) => LT.lt.{0} Real Real.hasLt x ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) Rat Real (HasLiftT.mk.{1, 1} Rat Real (CoeTCₓ.coe.{1, 1} Rat Real (Rat.castCoe.{0} Real Real.hasRatCast))) r')))))) r))) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f x)
but is expected to have type
  forall (f : StieltjesFunction) (x : Real), Eq.{1} Real (iInf.{0, 1} Real Real.instInfSetReal (Subtype.{1} Rat (fun (r' : Rat) => LT.lt.{0} Real Real.instLTReal x (Rat.cast.{0} Real Real.ratCast r'))) (fun (r : Subtype.{1} Rat (fun (r' : Rat) => LT.lt.{0} Real Real.instLTReal x (Rat.cast.{0} Real Real.ratCast r'))) => StieltjesFunction.toFun f (Rat.cast.{0} Real Real.ratCast (Subtype.val.{1} Rat (fun (r' : Rat) => LT.lt.{0} Real Real.instLTReal x (Rat.cast.{0} Real Real.ratCast r')) r)))) (StieltjesFunction.toFun f x)
Case conversion may be inaccurate. Consider using '#align stieltjes_function.infi_rat_gt_eq StieltjesFunction.iInf_rat_gt_eqₓ'. -/
theorem iInf_rat_gt_eq (f : StieltjesFunction) (x : ℝ) : (⨅ r : { r' : ℚ // x < r' }, f r) = f x :=
  by
  rw [← infi_Ioi_eq f x]
  refine' (iInf_Ioi_eq_iInf_rat_gt _ _ f.mono).symm
  refine' ⟨f x, fun y => _⟩
  rintro ⟨y, hy_mem, rfl⟩
  exact f.mono (le_of_lt hy_mem)
#align stieltjes_function.infi_rat_gt_eq StieltjesFunction.iInf_rat_gt_eq

#print StieltjesFunction.id /-
/-- The identity of `ℝ` as a Stieltjes function, used to construct Lebesgue measure. -/
@[simps]
protected def id : StieltjesFunction where
  toFun := id
  mono' x y := id
  right_continuous' x := continuousWithinAt_id
#align stieltjes_function.id StieltjesFunction.id
-/

#print StieltjesFunction.id_leftLim /-
@[simp]
theorem id_leftLim (x : ℝ) : leftLim StieltjesFunction.id x = x :=
  tendsto_nhds_unique (StieltjesFunction.id.mono.tendsto_leftLim x) <|
    continuousAt_id.Tendsto.mono_left nhdsWithin_le_nhds
#align stieltjes_function.id_left_lim StieltjesFunction.id_leftLim
-/

instance : Inhabited StieltjesFunction :=
  ⟨StieltjesFunction.id⟩

#print Monotone.stieltjesFunction /-
/-- If a function `f : ℝ → ℝ` is monotone, then the function mapping `x` to the right limit of `f`
at `x` is a Stieltjes function, i.e., it is monotone and right-continuous. -/
noncomputable def Monotone.stieltjesFunction {f : ℝ → ℝ} (hf : Monotone f) : StieltjesFunction
    where
  toFun := rightLim f
  mono' x y hxy := hf.rightLim hxy
  right_continuous' := by
    intro x s hs
    obtain ⟨l, u, hlu, lus⟩ : ∃ l u : ℝ, right_lim f x ∈ Ioo l u ∧ Ioo l u ⊆ s :=
      mem_nhds_iff_exists_Ioo_subset.1 hs
    obtain ⟨y, xy, h'y⟩ : ∃ (y : ℝ)(H : x < y), Ioc x y ⊆ f ⁻¹' Ioo l u :=
      mem_nhdsWithin_Ioi_iff_exists_Ioc_subset.1 (hf.tendsto_right_lim x (Ioo_mem_nhds hlu.1 hlu.2))
    change ∀ᶠ y in 𝓝[≥] x, right_lim f y ∈ s
    filter_upwards [Ico_mem_nhdsWithin_Ici ⟨le_refl x, xy⟩]with z hz
    apply lus
    refine' ⟨hlu.1.trans_le (hf.right_lim hz.1), _⟩
    obtain ⟨a, za, ay⟩ : ∃ a : ℝ, z < a ∧ a < y := exists_between hz.2
    calc
      right_lim f z ≤ f a := hf.right_lim_le za
      _ < u := (h'y ⟨hz.1.trans_lt za, ay.le⟩).2
      
#align monotone.stieltjes_function Monotone.stieltjesFunction
-/

#print Monotone.stieltjesFunction_eq /-
theorem Monotone.stieltjesFunction_eq {f : ℝ → ℝ} (hf : Monotone f) (x : ℝ) :
    hf.StieltjesFunction x = rightLim f x :=
  rfl
#align monotone.stieltjes_function_eq Monotone.stieltjesFunction_eq
-/

#print StieltjesFunction.countable_leftLim_ne /-
theorem countable_leftLim_ne (f : StieltjesFunction) : Set.Countable { x | leftLim f x ≠ f x } :=
  by
  apply countable.mono _ f.mono.countable_not_continuous_at
  intro x hx h'x
  apply hx
  exact tendsto_nhds_unique (f.mono.tendsto_left_lim x) (h'x.tendsto.mono_left nhdsWithin_le_nhds)
#align stieltjes_function.countable_left_lim_ne StieltjesFunction.countable_leftLim_ne
-/

/-! ### The outer measure associated to a Stieltjes function -/


/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (a b) -/
#print StieltjesFunction.length /-
/-- Length of an interval. This is the largest monotone function which correctly measures all
intervals. -/
def length (s : Set ℝ) : ℝ≥0∞ :=
  ⨅ (a) (b) (h : s ⊆ Ioc a b), ofReal (f b - f a)
#align stieltjes_function.length StieltjesFunction.length
-/

/- warning: stieltjes_function.length_empty -> StieltjesFunction.length_empty is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction), Eq.{1} ENNReal (StieltjesFunction.length f (EmptyCollection.emptyCollection.{0} (Set.{0} Real) (Set.hasEmptyc.{0} Real))) (OfNat.ofNat.{0} ENNReal 0 (OfNat.mk.{0} ENNReal 0 (Zero.zero.{0} ENNReal ENNReal.hasZero)))
but is expected to have type
  forall (f : StieltjesFunction), Eq.{1} ENNReal (StieltjesFunction.length f (EmptyCollection.emptyCollection.{0} (Set.{0} Real) (Set.instEmptyCollectionSet.{0} Real))) (OfNat.ofNat.{0} ENNReal 0 (Zero.toOfNat0.{0} ENNReal instENNRealZero))
Case conversion may be inaccurate. Consider using '#align stieltjes_function.length_empty StieltjesFunction.length_emptyₓ'. -/
@[simp]
theorem length_empty : f.length ∅ = 0 :=
  nonpos_iff_eq_zero.1 <| iInf_le_of_le 0 <| iInf_le_of_le 0 <| by simp
#align stieltjes_function.length_empty StieltjesFunction.length_empty

/- warning: stieltjes_function.length_Ioc -> StieltjesFunction.length_Ioc is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction) (a : Real) (b : Real), Eq.{1} ENNReal (StieltjesFunction.length f (Set.Ioc.{0} Real Real.preorder a b)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f b) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f a)))
but is expected to have type
  forall (f : StieltjesFunction) (a : Real) (b : Real), Eq.{1} ENNReal (StieltjesFunction.length f (Set.Ioc.{0} Real Real.instPreorderReal a b)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) (StieltjesFunction.toFun f b) (StieltjesFunction.toFun f a)))
Case conversion may be inaccurate. Consider using '#align stieltjes_function.length_Ioc StieltjesFunction.length_Iocₓ'. -/
@[simp]
theorem length_Ioc (a b : ℝ) : f.length (Ioc a b) = ofReal (f b - f a) :=
  by
  refine'
    le_antisymm (iInf_le_of_le a <| iInf₂_le b subset.rfl)
      (le_iInf fun a' => le_iInf fun b' => le_iInf fun h => ENNReal.coe_le_coe.2 _)
  cases' le_or_lt b a with ab ab
  · rw [Real.toNNReal_of_nonpos (sub_nonpos.2 (f.mono ab))]; apply zero_le
  cases' (Ioc_subset_Ioc_iff ab).1 h with h₁ h₂
  exact Real.toNNReal_le_toNNReal (sub_le_sub (f.mono h₁) (f.mono h₂))
#align stieltjes_function.length_Ioc StieltjesFunction.length_Ioc

/- warning: stieltjes_function.length_mono -> StieltjesFunction.length_mono is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction) {s₁ : Set.{0} Real} {s₂ : Set.{0} Real}, (HasSubset.Subset.{0} (Set.{0} Real) (Set.hasSubset.{0} Real) s₁ s₂) -> (LE.le.{0} ENNReal (Preorder.toHasLe.{0} ENNReal (PartialOrder.toPreorder.{0} ENNReal (CompleteSemilatticeInf.toPartialOrder.{0} ENNReal (CompleteLattice.toCompleteSemilatticeInf.{0} ENNReal (CompleteLinearOrder.toCompleteLattice.{0} ENNReal ENNReal.completeLinearOrder))))) (StieltjesFunction.length f s₁) (StieltjesFunction.length f s₂))
but is expected to have type
  forall (f : StieltjesFunction) {s₁ : Set.{0} Real} {s₂ : Set.{0} Real}, (HasSubset.Subset.{0} (Set.{0} Real) (Set.instHasSubsetSet.{0} Real) s₁ s₂) -> (LE.le.{0} ENNReal (Preorder.toLE.{0} ENNReal (PartialOrder.toPreorder.{0} ENNReal (OmegaCompletePartialOrder.toPartialOrder.{0} ENNReal (CompleteLattice.instOmegaCompletePartialOrder.{0} ENNReal (CompleteLinearOrder.toCompleteLattice.{0} ENNReal ENNReal.instCompleteLinearOrderENNReal))))) (StieltjesFunction.length f s₁) (StieltjesFunction.length f s₂))
Case conversion may be inaccurate. Consider using '#align stieltjes_function.length_mono StieltjesFunction.length_monoₓ'. -/
theorem length_mono {s₁ s₂ : Set ℝ} (h : s₁ ⊆ s₂) : f.length s₁ ≤ f.length s₂ :=
  iInf_mono fun a => biInf_mono fun b => h.trans
#align stieltjes_function.length_mono StieltjesFunction.length_mono

open MeasureTheory

#print StieltjesFunction.outer /-
/-- The Stieltjes outer measure associated to a Stieltjes function. -/
protected def outer : OuterMeasure ℝ :=
  OuterMeasure.ofFunction f.length f.length_empty
#align stieltjes_function.outer StieltjesFunction.outer
-/

/- warning: stieltjes_function.outer_le_length -> StieltjesFunction.outer_le_length is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction) (s : Set.{0} Real), LE.le.{0} ENNReal (Preorder.toHasLe.{0} ENNReal (PartialOrder.toPreorder.{0} ENNReal (CompleteSemilatticeInf.toPartialOrder.{0} ENNReal (CompleteLattice.toCompleteSemilatticeInf.{0} ENNReal (CompleteLinearOrder.toCompleteLattice.{0} ENNReal ENNReal.completeLinearOrder))))) (coeFn.{1, 1} (MeasureTheory.OuterMeasure.{0} Real) (fun (_x : MeasureTheory.OuterMeasure.{0} Real) => (Set.{0} Real) -> ENNReal) (MeasureTheory.OuterMeasure.instCoeFun.{0} Real) (StieltjesFunction.outer f) s) (StieltjesFunction.length f s)
but is expected to have type
  forall (f : StieltjesFunction) (s : Set.{0} Real), LE.le.{0} ENNReal (Preorder.toLE.{0} ENNReal (PartialOrder.toPreorder.{0} ENNReal (OmegaCompletePartialOrder.toPartialOrder.{0} ENNReal (CompleteLattice.instOmegaCompletePartialOrder.{0} ENNReal (CompleteLinearOrder.toCompleteLattice.{0} ENNReal ENNReal.instCompleteLinearOrderENNReal))))) (MeasureTheory.OuterMeasure.measureOf.{0} Real (StieltjesFunction.outer f) s) (StieltjesFunction.length f s)
Case conversion may be inaccurate. Consider using '#align stieltjes_function.outer_le_length StieltjesFunction.outer_le_lengthₓ'. -/
theorem outer_le_length (s : Set ℝ) : f.outer s ≤ f.length s :=
  OuterMeasure.ofFunction_le _
#align stieltjes_function.outer_le_length StieltjesFunction.outer_le_length

/- warning: stieltjes_function.length_subadditive_Icc_Ioo -> StieltjesFunction.length_subadditive_Icc_Ioo is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction) {a : Real} {b : Real} {c : Nat -> Real} {d : Nat -> Real}, (HasSubset.Subset.{0} (Set.{0} Real) (Set.hasSubset.{0} Real) (Set.Icc.{0} Real Real.preorder a b) (Set.iUnion.{0, 1} Real Nat (fun (i : Nat) => Set.Ioo.{0} Real Real.preorder (c i) (d i)))) -> (LE.le.{0} ENNReal (Preorder.toHasLe.{0} ENNReal (PartialOrder.toPreorder.{0} ENNReal (CompleteSemilatticeInf.toPartialOrder.{0} ENNReal (CompleteLattice.toCompleteSemilatticeInf.{0} ENNReal (CompleteLinearOrder.toCompleteLattice.{0} ENNReal ENNReal.completeLinearOrder))))) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f b) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f a))) (tsum.{0, 0} ENNReal (OrderedAddCommMonoid.toAddCommMonoid.{0} ENNReal (OrderedSemiring.toOrderedAddCommMonoid.{0} ENNReal (OrderedCommSemiring.toOrderedSemiring.{0} ENNReal (CanonicallyOrderedCommSemiring.toOrderedCommSemiring.{0} ENNReal ENNReal.canonicallyOrderedCommSemiring)))) ENNReal.topologicalSpace Nat (fun (i : Nat) => ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f (d i)) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f (c i))))))
but is expected to have type
  forall (f : StieltjesFunction) {a : Real} {b : Real} {c : Nat -> Real} {d : Nat -> Real}, (HasSubset.Subset.{0} (Set.{0} Real) (Set.instHasSubsetSet.{0} Real) (Set.Icc.{0} Real Real.instPreorderReal a b) (Set.iUnion.{0, 1} Real Nat (fun (i : Nat) => Set.Ioo.{0} Real Real.instPreorderReal (c i) (d i)))) -> (LE.le.{0} ENNReal (Preorder.toLE.{0} ENNReal (PartialOrder.toPreorder.{0} ENNReal (OmegaCompletePartialOrder.toPartialOrder.{0} ENNReal (CompleteLattice.instOmegaCompletePartialOrder.{0} ENNReal (CompleteLinearOrder.toCompleteLattice.{0} ENNReal ENNReal.instCompleteLinearOrderENNReal))))) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) (StieltjesFunction.toFun f b) (StieltjesFunction.toFun f a))) (tsum.{0, 0} ENNReal (LinearOrderedAddCommMonoid.toAddCommMonoid.{0} ENNReal (LinearOrderedAddCommMonoidWithTop.toLinearOrderedAddCommMonoid.{0} ENNReal ENNReal.instLinearOrderedAddCommMonoidWithTopENNReal)) ENNReal.instTopologicalSpaceENNReal Nat (fun (i : Nat) => ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) (StieltjesFunction.toFun f (d i)) (StieltjesFunction.toFun f (c i))))))
Case conversion may be inaccurate. Consider using '#align stieltjes_function.length_subadditive_Icc_Ioo StieltjesFunction.length_subadditive_Icc_Iooₓ'. -/
/-- If a compact interval `[a, b]` is covered by a union of open interval `(c i, d i)`, then
`f b - f a ≤ ∑ f (d i) - f (c i)`. This is an auxiliary technical statement to prove the same
statement for half-open intervals, the point of the current statement being that one can use
compactness to reduce it to a finite sum, and argue by induction on the size of the covering set. -/
theorem length_subadditive_Icc_Ioo {a b : ℝ} {c d : ℕ → ℝ} (ss : Icc a b ⊆ ⋃ i, Ioo (c i) (d i)) :
    ofReal (f b - f a) ≤ ∑' i, ofReal (f (d i) - f (c i)) :=
  by
  suffices
    ∀ (s : Finset ℕ) (b) (cv : Icc a b ⊆ ⋃ i ∈ (↑s : Set ℕ), Ioo (c i) (d i)),
      (of_real (f b - f a) : ℝ≥0∞) ≤ ∑ i in s, of_real (f (d i) - f (c i))
    by
    rcases is_compact_Icc.elim_finite_subcover_image
        (fun (i : ℕ) (_ : i ∈ univ) => @isOpen_Ioo _ _ _ _ (c i) (d i)) (by simpa using ss) with
      ⟨s, su, hf, hs⟩
    have e : (⋃ i ∈ (↑hf.to_finset : Set ℕ), Ioo (c i) (d i)) = ⋃ i ∈ s, Ioo (c i) (d i) := by
      simp only [ext_iff, exists_prop, Finset.set_biUnion_coe, mem_Union, forall_const,
        iff_self_iff, finite.mem_to_finset]
    rw [ENNReal.tsum_eq_iSup_sum]
    refine' le_trans _ (le_iSup _ hf.to_finset)
    exact this hf.to_finset _ (by simpa only [e] )
  clear ss b
  refine' fun s => Finset.strongInductionOn s fun s IH b cv => _
  cases' le_total b a with ab ab
  · rw [ENNReal.ofReal_eq_zero.2 (sub_nonpos.2 (f.mono ab))]; exact zero_le _
  have := cv ⟨ab, le_rfl⟩; simp at this
  rcases this with ⟨i, is, cb, bd⟩
  rw [← Finset.insert_erase is] at cv⊢
  rw [Finset.coe_insert, bUnion_insert] at cv
  rw [Finset.sum_insert (Finset.not_mem_erase _ _)]
  refine' le_trans _ (add_le_add_left (IH _ (Finset.erase_ssubset is) (c i) _) _)
  · refine' le_trans (ENNReal.ofReal_le_ofReal _) ENNReal.ofReal_add_le
    rw [sub_add_sub_cancel]
    exact sub_le_sub_right (f.mono bd.le) _
  · rintro x ⟨h₁, h₂⟩
    refine' (cv ⟨h₁, le_trans h₂ (le_of_lt cb)⟩).resolve_left (mt And.left (not_lt_of_le h₂))
#align stieltjes_function.length_subadditive_Icc_Ioo StieltjesFunction.length_subadditive_Icc_Ioo

/- warning: stieltjes_function.outer_Ioc -> StieltjesFunction.outer_Ioc is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction) (a : Real) (b : Real), Eq.{1} ENNReal (coeFn.{1, 1} (MeasureTheory.OuterMeasure.{0} Real) (fun (_x : MeasureTheory.OuterMeasure.{0} Real) => (Set.{0} Real) -> ENNReal) (MeasureTheory.OuterMeasure.instCoeFun.{0} Real) (StieltjesFunction.outer f) (Set.Ioc.{0} Real Real.preorder a b)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f b) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f a)))
but is expected to have type
  forall (f : StieltjesFunction) (a : Real) (b : Real), Eq.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{0} Real (StieltjesFunction.outer f) (Set.Ioc.{0} Real Real.instPreorderReal a b)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) (StieltjesFunction.toFun f b) (StieltjesFunction.toFun f a)))
Case conversion may be inaccurate. Consider using '#align stieltjes_function.outer_Ioc StieltjesFunction.outer_Iocₓ'. -/
@[simp]
theorem outer_Ioc (a b : ℝ) : f.outer (Ioc a b) = ofReal (f b - f a) :=
  by
  /- It suffices to show that, if `(a, b]` is covered by sets `s i`, then `f b - f a` is bounded
    by `∑ f.length (s i) + ε`. The difficulty is that `f.length` is expressed in terms of half-open
    intervals, while we would like to have a compact interval covered by open intervals to use
    compactness and finite sums, as provided by `length_subadditive_Icc_Ioo`. The trick is to use the
    right-continuity of `f`. If `a'` is close enough to `a` on its right, then `[a', b]` is still
    covered by the sets `s i` and moreover `f b - f a'` is very close to `f b - f a` (up to `ε/2`).
    Also, by definition one can cover `s i` by a half-closed interval `(p i, q i]` with `f`-length
    very close to  that of `s i` (within a suitably small `ε' i`, say). If one moves `q i` very
    slightly to the right, then the `f`-length will change very little by right continuity, and we
    will get an open interval `(p i, q' i)` covering `s i` with `f (q' i) - f (p i)` within `ε' i`
    of the `f`-length of `s i`. -/
  refine'
    le_antisymm (by rw [← f.length_Ioc]; apply outer_le_length)
      (le_iInf₂ fun s hs => ENNReal.le_of_forall_pos_le_add fun ε εpos h => _)
  let δ := ε / 2
  have δpos : 0 < (δ : ℝ≥0∞) := by simpa using εpos.ne'
  rcases ENNReal.exists_pos_sum_of_countable δpos.ne' ℕ with ⟨ε', ε'0, hε⟩
  obtain ⟨a', ha', aa'⟩ : ∃ a', f a' - f a < δ ∧ a < a' :=
    by
    have A : ContinuousWithinAt (fun r => f r - f a) (Ioi a) a :=
      by
      refine' ContinuousWithinAt.sub _ continuousWithinAt_const
      exact (f.right_continuous a).mono Ioi_subset_Ici_self
    have B : f a - f a < δ := by rwa [sub_self, NNReal.coe_pos, ← ENNReal.coe_pos]
    exact (((tendsto_order.1 A).2 _ B).And self_mem_nhdsWithin).exists
  have :
    ∀ i,
      ∃ p : ℝ × ℝ, s i ⊆ Ioo p.1 p.2 ∧ (of_real (f p.2 - f p.1) : ℝ≥0∞) < f.length (s i) + ε' i :=
    by
    intro i
    have :=
      ENNReal.lt_add_right ((ENNReal.le_tsum i).trans_lt h).Ne (ENNReal.coe_ne_zero.2 (ε'0 i).ne')
    conv at this =>
      lhs
      rw [length]
    simp only [iInf_lt_iff, exists_prop] at this
    rcases this with ⟨p, q', spq, hq'⟩
    have : ContinuousWithinAt (fun r => of_real (f r - f p)) (Ioi q') q' :=
      by
      apply ennreal.continuous_of_real.continuous_at.comp_continuous_within_at
      refine' ContinuousWithinAt.sub _ continuousWithinAt_const
      exact (f.right_continuous q').mono Ioi_subset_Ici_self
    rcases(((tendsto_order.1 this).2 _ hq').And self_mem_nhdsWithin).exists with ⟨q, hq, q'q⟩
    exact ⟨⟨p, q⟩, spq.trans (Ioc_subset_Ioo_right q'q), hq⟩
  choose g hg using this
  have I_subset : Icc a' b ⊆ ⋃ i, Ioo (g i).1 (g i).2 :=
    calc
      Icc a' b ⊆ Ioc a b := fun x hx => ⟨aa'.trans_le hx.1, hx.2⟩
      _ ⊆ ⋃ i, s i := hs
      _ ⊆ ⋃ i, Ioo (g i).1 (g i).2 := Union_mono fun i => (hg i).1
      
  calc
    of_real (f b - f a) = of_real (f b - f a' + (f a' - f a)) := by rw [sub_add_sub_cancel]
    _ ≤ of_real (f b - f a') + of_real (f a' - f a) := ENNReal.ofReal_add_le
    _ ≤ (∑' i, of_real (f (g i).2 - f (g i).1)) + of_real δ :=
      (add_le_add (f.length_subadditive_Icc_Ioo I_subset) (ENNReal.ofReal_le_ofReal ha'.le))
    _ ≤ (∑' i, f.length (s i) + ε' i) + δ :=
      (add_le_add (ENNReal.tsum_le_tsum fun i => (hg i).2.le)
        (by simp only [ENNReal.ofReal_coe_nnreal, le_rfl]))
    _ = ((∑' i, f.length (s i)) + ∑' i, ε' i) + δ := by rw [ENNReal.tsum_add]
    _ ≤ (∑' i, f.length (s i)) + δ + δ := (add_le_add (add_le_add le_rfl hε.le) le_rfl)
    _ = (∑' i : ℕ, f.length (s i)) + ε := by simp [add_assoc, ENNReal.add_halves]
    
#align stieltjes_function.outer_Ioc StieltjesFunction.outer_Ioc

#print StieltjesFunction.measurableSet_Ioi /-
theorem measurableSet_Ioi {c : ℝ} : measurable_set[f.outer.caratheodory] (Ioi c) :=
  by
  apply outer_measure.of_function_caratheodory fun t => _
  refine' le_iInf fun a => le_iInf fun b => le_iInf fun h => _
  refine'
    le_trans
      (add_le_add (f.length_mono <| inter_subset_inter_left _ h)
        (f.length_mono <| diff_subset_diff_left h))
      _
  cases' le_total a c with hac hac <;> cases' le_total b c with hbc hbc
  ·
    simp only [Ioc_inter_Ioi, f.length_Ioc, hac, sup_eq_max, hbc, le_refl, Ioc_eq_empty,
      max_eq_right, min_eq_left, Ioc_diff_Ioi, f.length_empty, zero_add, not_lt]
  ·
    simp only [hac, hbc, Ioc_inter_Ioi, Ioc_diff_Ioi, f.length_Ioc, min_eq_right, sup_eq_max, ←
      ENNReal.ofReal_add, f.mono hac, f.mono hbc, sub_nonneg, sub_add_sub_cancel, le_refl,
      max_eq_right]
  ·
    simp only [hbc, le_refl, Ioc_eq_empty, Ioc_inter_Ioi, min_eq_left, Ioc_diff_Ioi, f.length_empty,
      zero_add, or_true_iff, le_sup_iff, f.length_Ioc, not_lt]
  ·
    simp only [hac, hbc, Ioc_inter_Ioi, Ioc_diff_Ioi, f.length_Ioc, min_eq_right, sup_eq_max,
      le_refl, Ioc_eq_empty, add_zero, max_eq_left, f.length_empty, not_lt]
#align stieltjes_function.measurable_set_Ioi StieltjesFunction.measurableSet_Ioi
-/

#print StieltjesFunction.outer_trim /-
theorem outer_trim : f.outer.trim = f.outer :=
  by
  refine' le_antisymm (fun s => _) (outer_measure.le_trim _)
  rw [outer_measure.trim_eq_infi]
  refine' le_iInf fun t => le_iInf fun ht => ENNReal.le_of_forall_pos_le_add fun ε ε0 h => _
  rcases ENNReal.exists_pos_sum_of_countable (ENNReal.coe_pos.2 ε0).ne' ℕ with ⟨ε', ε'0, hε⟩
  refine' le_trans _ (add_le_add_left (le_of_lt hε) _)
  rw [← ENNReal.tsum_add]
  choose g hg using
    show ∀ i, ∃ s, t i ⊆ s ∧ MeasurableSet s ∧ f.outer s ≤ f.length (t i) + of_real (ε' i)
      by
      intro i
      have :=
        ENNReal.lt_add_right ((ENNReal.le_tsum i).trans_lt h).Ne (ENNReal.coe_pos.2 (ε'0 i)).ne'
      conv at this =>
        lhs
        rw [length]
      simp only [iInf_lt_iff] at this
      rcases this with ⟨a, b, h₁, h₂⟩
      rw [← f.outer_Ioc] at h₂
      exact ⟨_, h₁, measurableSet_Ioc, le_of_lt <| by simpa using h₂⟩
  simp at hg
  apply iInf_le_of_le (Union g) _
  apply iInf_le_of_le (ht.trans <| Union_mono fun i => (hg i).1) _
  apply iInf_le_of_le (MeasurableSet.iUnion fun i => (hg i).2.1) _
  exact le_trans (f.outer.Union _) (ENNReal.tsum_le_tsum fun i => (hg i).2.2)
#align stieltjes_function.outer_trim StieltjesFunction.outer_trim
-/

#print StieltjesFunction.borel_le_measurable /-
theorem borel_le_measurable : borel ℝ ≤ f.outer.caratheodory :=
  by
  rw [borel_eq_generateFrom_Ioi]
  refine' MeasurableSpace.generateFrom_le _
  simp (config := { contextual := true }) [f.measurable_set_Ioi]
#align stieltjes_function.borel_le_measurable StieltjesFunction.borel_le_measurable
-/

/-! ### The measure associated to a Stieltjes function -/


#print StieltjesFunction.measure /-
/-- The measure associated to a Stieltjes function, giving mass `f b - f a` to the
interval `(a, b]`. -/
protected irreducible_def measure : Measure ℝ :=
  { toOuterMeasure := f.outer
    m_iUnion := fun s hs =>
      f.outer.iUnion_eq_of_caratheodory fun i => f.borel_le_measurable _ (hs i)
    trimmed := f.outer_trim }
#align stieltjes_function.measure StieltjesFunction.measure
-/

/- warning: stieltjes_function.measure_Ioc -> StieltjesFunction.measure_Ioc is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction) (a : Real) (b : Real), Eq.{1} ENNReal (coeFn.{1, 1} (MeasureTheory.Measure.{0} Real Real.measurableSpace) (fun (_x : MeasureTheory.Measure.{0} Real Real.measurableSpace) => (Set.{0} Real) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{0} Real Real.measurableSpace) (StieltjesFunction.measure f) (Set.Ioc.{0} Real Real.preorder a b)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f b) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f a)))
but is expected to have type
  forall (f : StieltjesFunction) (a : Real) (b : Real), Eq.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{0} Real (MeasureTheory.Measure.toOuterMeasure.{0} Real Real.measurableSpace (StieltjesFunction.measure f)) (Set.Ioc.{0} Real Real.instPreorderReal a b)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) (StieltjesFunction.toFun f b) (StieltjesFunction.toFun f a)))
Case conversion may be inaccurate. Consider using '#align stieltjes_function.measure_Ioc StieltjesFunction.measure_Iocₓ'. -/
@[simp]
theorem measure_Ioc (a b : ℝ) : f.Measure (Ioc a b) = ofReal (f b - f a) := by
  rw [StieltjesFunction.measure]; exact f.outer_Ioc a b
#align stieltjes_function.measure_Ioc StieltjesFunction.measure_Ioc

/- warning: stieltjes_function.measure_singleton -> StieltjesFunction.measure_singleton is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction) (a : Real), Eq.{1} ENNReal (coeFn.{1, 1} (MeasureTheory.Measure.{0} Real Real.measurableSpace) (fun (_x : MeasureTheory.Measure.{0} Real Real.measurableSpace) => (Set.{0} Real) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{0} Real Real.measurableSpace) (StieltjesFunction.measure f) (Singleton.singleton.{0, 0} Real (Set.{0} Real) (Set.hasSingleton.{0} Real) a)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f a) (Function.leftLim.{0, 0} Real Real Real.linearOrder (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f) a)))
but is expected to have type
  forall (f : StieltjesFunction) (a : Real), Eq.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{0} Real (MeasureTheory.Measure.toOuterMeasure.{0} Real Real.measurableSpace (StieltjesFunction.measure f)) (Singleton.singleton.{0, 0} Real (Set.{0} Real) (Set.instSingletonSet.{0} Real) a)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) (StieltjesFunction.toFun f a) (Function.leftLim.{0, 0} Real Real Real.linearOrder (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (StieltjesFunction.toFun f) a)))
Case conversion may be inaccurate. Consider using '#align stieltjes_function.measure_singleton StieltjesFunction.measure_singletonₓ'. -/
@[simp]
theorem measure_singleton (a : ℝ) : f.Measure {a} = ofReal (f a - leftLim f a) :=
  by
  obtain ⟨u, u_mono, u_lt_a, u_lim⟩ :
    ∃ u : ℕ → ℝ, StrictMono u ∧ (∀ n : ℕ, u n < a) ∧ tendsto u at_top (𝓝 a) :=
    exists_seq_strictMono_tendsto a
  have A : {a} = ⋂ n, Ioc (u n) a :=
    by
    refine' subset.antisymm (fun x hx => by simp [mem_singleton_iff.1 hx, u_lt_a]) fun x hx => _
    simp at hx
    have : a ≤ x := le_of_tendsto' u_lim fun n => (hx n).1.le
    simp [le_antisymm this (hx 0).2]
  have L1 : tendsto (fun n => f.measure (Ioc (u n) a)) at_top (𝓝 (f.measure {a})) :=
    by
    rw [A]
    refine' tendsto_measure_Inter (fun n => measurableSet_Ioc) (fun m n hmn => _) _
    · exact Ioc_subset_Ioc (u_mono.monotone hmn) le_rfl
    · exact ⟨0, by simpa only [measure_Ioc] using ENNReal.ofReal_ne_top⟩
  have L2 : tendsto (fun n => f.measure (Ioc (u n) a)) at_top (𝓝 (of_real (f a - left_lim f a))) :=
    by
    simp only [measure_Ioc]
    have : tendsto (fun n => f (u n)) at_top (𝓝 (left_lim f a)) :=
      by
      apply (f.mono.tendsto_left_lim a).comp
      exact
        tendsto_nhdsWithin_of_tendsto_nhds_of_eventually_within _ u_lim
          (eventually_of_forall fun n => u_lt_a n)
    exact ennreal.continuous_of_real.continuous_at.tendsto.comp (tendsto_const_nhds.sub this)
  exact tendsto_nhds_unique L1 L2
#align stieltjes_function.measure_singleton StieltjesFunction.measure_singleton

/- warning: stieltjes_function.measure_Icc -> StieltjesFunction.measure_Icc is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction) (a : Real) (b : Real), Eq.{1} ENNReal (coeFn.{1, 1} (MeasureTheory.Measure.{0} Real Real.measurableSpace) (fun (_x : MeasureTheory.Measure.{0} Real Real.measurableSpace) => (Set.{0} Real) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{0} Real Real.measurableSpace) (StieltjesFunction.measure f) (Set.Icc.{0} Real Real.preorder a b)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f b) (Function.leftLim.{0, 0} Real Real Real.linearOrder (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f) a)))
but is expected to have type
  forall (f : StieltjesFunction) (a : Real) (b : Real), Eq.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{0} Real (MeasureTheory.Measure.toOuterMeasure.{0} Real Real.measurableSpace (StieltjesFunction.measure f)) (Set.Icc.{0} Real Real.instPreorderReal a b)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) (StieltjesFunction.toFun f b) (Function.leftLim.{0, 0} Real Real Real.linearOrder (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (StieltjesFunction.toFun f) a)))
Case conversion may be inaccurate. Consider using '#align stieltjes_function.measure_Icc StieltjesFunction.measure_Iccₓ'. -/
@[simp]
theorem measure_Icc (a b : ℝ) : f.Measure (Icc a b) = ofReal (f b - leftLim f a) :=
  by
  rcases le_or_lt a b with (hab | hab)
  · have A : Disjoint {a} (Ioc a b) := by simp
    simp [← Icc_union_Ioc_eq_Icc le_rfl hab, -singleton_union, ← ENNReal.ofReal_add,
      f.mono.left_lim_le, measure_union A measurableSet_Ioc, f.mono hab]
  · simp only [hab, measure_empty, Icc_eq_empty, not_le]
    symm
    simp [ENNReal.ofReal_eq_zero, f.mono.le_left_lim hab]
#align stieltjes_function.measure_Icc StieltjesFunction.measure_Icc

/- warning: stieltjes_function.measure_Ioo -> StieltjesFunction.measure_Ioo is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction) {a : Real} {b : Real}, Eq.{1} ENNReal (coeFn.{1, 1} (MeasureTheory.Measure.{0} Real Real.measurableSpace) (fun (_x : MeasureTheory.Measure.{0} Real Real.measurableSpace) => (Set.{0} Real) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{0} Real Real.measurableSpace) (StieltjesFunction.measure f) (Set.Ioo.{0} Real Real.preorder a b)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (Function.leftLim.{0, 0} Real Real Real.linearOrder (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f) b) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f a)))
but is expected to have type
  forall (f : StieltjesFunction) {a : Real} {b : Real}, Eq.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{0} Real (MeasureTheory.Measure.toOuterMeasure.{0} Real Real.measurableSpace (StieltjesFunction.measure f)) (Set.Ioo.{0} Real Real.instPreorderReal a b)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) (Function.leftLim.{0, 0} Real Real Real.linearOrder (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (StieltjesFunction.toFun f) b) (StieltjesFunction.toFun f a)))
Case conversion may be inaccurate. Consider using '#align stieltjes_function.measure_Ioo StieltjesFunction.measure_Iooₓ'. -/
@[simp]
theorem measure_Ioo {a b : ℝ} : f.Measure (Ioo a b) = ofReal (leftLim f b - f a) :=
  by
  rcases le_or_lt b a with (hab | hab)
  · simp only [hab, measure_empty, Ioo_eq_empty, not_lt]
    symm
    simp [ENNReal.ofReal_eq_zero, f.mono.left_lim_le hab]
  · have A : Disjoint (Ioo a b) {b} := by simp
    have D : f b - f a = f b - left_lim f b + (left_lim f b - f a) := by abel
    have := f.measure_Ioc a b
    simp only [← Ioo_union_Icc_eq_Ioc hab le_rfl, measure_singleton,
      measure_union A (measurable_set_singleton b), Icc_self] at this
    rw [D, ENNReal.ofReal_add, add_comm] at this
    · simpa only [ENNReal.add_right_inj ENNReal.ofReal_ne_top]
    · simp only [f.mono.left_lim_le, sub_nonneg]
    · simp only [f.mono.le_left_lim hab, sub_nonneg]
#align stieltjes_function.measure_Ioo StieltjesFunction.measure_Ioo

/- warning: stieltjes_function.measure_Ico -> StieltjesFunction.measure_Ico is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction) (a : Real) (b : Real), Eq.{1} ENNReal (coeFn.{1, 1} (MeasureTheory.Measure.{0} Real Real.measurableSpace) (fun (_x : MeasureTheory.Measure.{0} Real Real.measurableSpace) => (Set.{0} Real) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{0} Real Real.measurableSpace) (StieltjesFunction.measure f) (Set.Ico.{0} Real Real.preorder a b)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (Function.leftLim.{0, 0} Real Real Real.linearOrder (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f) b) (Function.leftLim.{0, 0} Real Real Real.linearOrder (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f) a)))
but is expected to have type
  forall (f : StieltjesFunction) (a : Real) (b : Real), Eq.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{0} Real (MeasureTheory.Measure.toOuterMeasure.{0} Real Real.measurableSpace (StieltjesFunction.measure f)) (Set.Ico.{0} Real Real.instPreorderReal a b)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) (Function.leftLim.{0, 0} Real Real Real.linearOrder (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (StieltjesFunction.toFun f) b) (Function.leftLim.{0, 0} Real Real Real.linearOrder (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (StieltjesFunction.toFun f) a)))
Case conversion may be inaccurate. Consider using '#align stieltjes_function.measure_Ico StieltjesFunction.measure_Icoₓ'. -/
@[simp]
theorem measure_Ico (a b : ℝ) : f.Measure (Ico a b) = ofReal (leftLim f b - leftLim f a) :=
  by
  rcases le_or_lt b a with (hab | hab)
  · simp only [hab, measure_empty, Ico_eq_empty, not_lt]
    symm
    simp [ENNReal.ofReal_eq_zero, f.mono.left_lim hab]
  · have A : Disjoint {a} (Ioo a b) := by simp
    simp [← Icc_union_Ioo_eq_Ico le_rfl hab, -singleton_union, hab.ne, f.mono.left_lim_le,
      measure_union A measurableSet_Ioo, f.mono.le_left_lim hab, ← ENNReal.ofReal_add]
#align stieltjes_function.measure_Ico StieltjesFunction.measure_Ico

/- warning: stieltjes_function.measure_Iic -> StieltjesFunction.measure_Iic is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction) {l : Real}, (Filter.Tendsto.{0, 0} Real Real (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f) (Filter.atBot.{0} Real Real.preorder) (nhds.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) l)) -> (forall (x : Real), Eq.{1} ENNReal (coeFn.{1, 1} (MeasureTheory.Measure.{0} Real Real.measurableSpace) (fun (_x : MeasureTheory.Measure.{0} Real Real.measurableSpace) => (Set.{0} Real) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{0} Real Real.measurableSpace) (StieltjesFunction.measure f) (Set.Iic.{0} Real Real.preorder x)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f x) l)))
but is expected to have type
  forall (f : StieltjesFunction) {l : Real}, (Filter.Tendsto.{0, 0} Real Real (StieltjesFunction.toFun f) (Filter.atBot.{0} Real Real.instPreorderReal) (nhds.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) l)) -> (forall (x : Real), Eq.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{0} Real (MeasureTheory.Measure.toOuterMeasure.{0} Real Real.measurableSpace (StieltjesFunction.measure f)) (Set.Iic.{0} Real Real.instPreorderReal x)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) (StieltjesFunction.toFun f x) l)))
Case conversion may be inaccurate. Consider using '#align stieltjes_function.measure_Iic StieltjesFunction.measure_Iicₓ'. -/
theorem measure_Iic {l : ℝ} (hf : Tendsto f atBot (𝓝 l)) (x : ℝ) :
    f.Measure (Iic x) = ofReal (f x - l) :=
  by
  refine' tendsto_nhds_unique (tendsto_measure_Ioc_at_bot _ _) _
  simp_rw [measure_Ioc]
  exact ENNReal.tendsto_ofReal (tendsto.const_sub _ hf)
#align stieltjes_function.measure_Iic StieltjesFunction.measure_Iic

/- warning: stieltjes_function.measure_Ici -> StieltjesFunction.measure_Ici is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction) {l : Real}, (Filter.Tendsto.{0, 0} Real Real (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f) (Filter.atTop.{0} Real Real.preorder) (nhds.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) l)) -> (forall (x : Real), Eq.{1} ENNReal (coeFn.{1, 1} (MeasureTheory.Measure.{0} Real Real.measurableSpace) (fun (_x : MeasureTheory.Measure.{0} Real Real.measurableSpace) => (Set.{0} Real) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{0} Real Real.measurableSpace) (StieltjesFunction.measure f) (Set.Ici.{0} Real Real.preorder x)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) l (Function.leftLim.{0, 0} Real Real Real.linearOrder (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f) x))))
but is expected to have type
  forall (f : StieltjesFunction) {l : Real}, (Filter.Tendsto.{0, 0} Real Real (StieltjesFunction.toFun f) (Filter.atTop.{0} Real Real.instPreorderReal) (nhds.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) l)) -> (forall (x : Real), Eq.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{0} Real (MeasureTheory.Measure.toOuterMeasure.{0} Real Real.measurableSpace (StieltjesFunction.measure f)) (Set.Ici.{0} Real Real.instPreorderReal x)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) l (Function.leftLim.{0, 0} Real Real Real.linearOrder (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) (StieltjesFunction.toFun f) x))))
Case conversion may be inaccurate. Consider using '#align stieltjes_function.measure_Ici StieltjesFunction.measure_Iciₓ'. -/
theorem measure_Ici {l : ℝ} (hf : Tendsto f atTop (𝓝 l)) (x : ℝ) :
    f.Measure (Ici x) = ofReal (l - leftLim f x) :=
  by
  refine' tendsto_nhds_unique (tendsto_measure_Ico_at_top _ _) _
  simp_rw [measure_Ico]
  refine' ENNReal.tendsto_ofReal (tendsto.sub_const _ _)
  have h_le1 : ∀ x, f (x - 1) ≤ left_lim f x := fun x => Monotone.le_leftLim f.mono (sub_one_lt x)
  have h_le2 : ∀ x, left_lim f x ≤ f x := fun x => Monotone.leftLim_le f.mono le_rfl
  refine' tendsto_of_tendsto_of_tendsto_of_le_of_le (hf.comp _) hf h_le1 h_le2
  rw [tendsto_at_top_at_top]
  exact fun y => ⟨y + 1, fun z hyz => by rwa [le_sub_iff_add_le]⟩
#align stieltjes_function.measure_Ici StieltjesFunction.measure_Ici

/- warning: stieltjes_function.measure_univ -> StieltjesFunction.measure_univ is a dubious translation:
lean 3 declaration is
  forall (f : StieltjesFunction) {l : Real} {u : Real}, (Filter.Tendsto.{0, 0} Real Real (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f) (Filter.atBot.{0} Real Real.preorder) (nhds.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) l)) -> (Filter.Tendsto.{0, 0} Real Real (coeFn.{1, 1} StieltjesFunction (fun (_x : StieltjesFunction) => Real -> Real) StieltjesFunction.instCoeFun f) (Filter.atTop.{0} Real Real.preorder) (nhds.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) u)) -> (Eq.{1} ENNReal (coeFn.{1, 1} (MeasureTheory.Measure.{0} Real Real.measurableSpace) (fun (_x : MeasureTheory.Measure.{0} Real Real.measurableSpace) => (Set.{0} Real) -> ENNReal) (MeasureTheory.Measure.instCoeFun.{0} Real Real.measurableSpace) (StieltjesFunction.measure f) (Set.univ.{0} Real)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) u l)))
but is expected to have type
  forall (f : StieltjesFunction) {l : Real} {u : Real}, (Filter.Tendsto.{0, 0} Real Real (StieltjesFunction.toFun f) (Filter.atBot.{0} Real Real.instPreorderReal) (nhds.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) l)) -> (Filter.Tendsto.{0, 0} Real Real (StieltjesFunction.toFun f) (Filter.atTop.{0} Real Real.instPreorderReal) (nhds.{0} Real (UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace)) u)) -> (Eq.{1} ENNReal (MeasureTheory.OuterMeasure.measureOf.{0} Real (MeasureTheory.Measure.toOuterMeasure.{0} Real Real.measurableSpace (StieltjesFunction.measure f)) (Set.univ.{0} Real)) (ENNReal.ofReal (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) u l)))
Case conversion may be inaccurate. Consider using '#align stieltjes_function.measure_univ StieltjesFunction.measure_univₓ'. -/
theorem measure_univ {l u : ℝ} (hfl : Tendsto f atBot (𝓝 l)) (hfu : Tendsto f atTop (𝓝 u)) :
    f.Measure univ = ofReal (u - l) :=
  by
  refine' tendsto_nhds_unique (tendsto_measure_Iic_at_top _) _
  simp_rw [measure_Iic f hfl]
  exact ENNReal.tendsto_ofReal (tendsto.sub_const hfu _)
#align stieltjes_function.measure_univ StieltjesFunction.measure_univ

instance : LocallyFiniteMeasure f.Measure :=
  ⟨fun x => ⟨Ioo (x - 1) (x + 1), Ioo_mem_nhds (by linarith) (by linarith), by simp⟩⟩

end StieltjesFunction

