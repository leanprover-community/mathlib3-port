/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.box_integral.box.basic
! leanprover-community/mathlib commit f2ce6086713c78a7f880485f7917ea547a215982
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Intervals.Monotone
import Mathbin.Topology.Algebra.Order.MonotoneConvergence
import Mathbin.Topology.MetricSpace.Basic

/-!
# Rectangular boxes in `ℝⁿ`

In this file we define rectangular boxes in `ℝⁿ`. As usual, we represent `ℝⁿ` as the type of
functions `ι → ℝ` (usually `ι = fin n` for some `n`). When we need to interpret a box `[l, u]` as a
set, we use the product `{x | ∀ i, l i < x i ∧ x i ≤ u i}` of half-open intervals `(l i, u i]`. We
exclude `l i` because this way boxes of a partition are disjoint as sets in `ℝⁿ`.

Currently, the only use cases for these constructions are the definitions of Riemann-style integrals
(Riemann, Henstock-Kurzweil, McShane).

## Main definitions

We use the same structure `box_integral.box` both for ambient boxes and for elements of a partition.
Each box is stored as two points `lower upper : ι → ℝ` and a proof of `∀ i, lower i < upper i`. We
define instances `has_mem (ι → ℝ) (box ι)` and `has_coe_t (box ι) (set $ ι → ℝ)` so that each box is
interpreted as the set `{x | ∀ i, x i ∈ set.Ioc (I.lower i) (I.upper i)}`. This way boxes of a
partition are pairwise disjoint and their union is exactly the original box.

We require boxes to be nonempty, because this way coercion to sets is injective. The empty box can
be represented as `⊥ : with_bot (box_integral.box ι)`.

We define the following operations on boxes:

* coercion to `set (ι → ℝ)` and `has_mem (ι → ℝ) (box_integral.box ι)` as described above;
* `partial_order` and `semilattice_sup` instances such that `I ≤ J` is equivalent to
  `(I : set (ι → ℝ)) ⊆ J`;
* `lattice` instances on `with_bot (box_integral.box ι)`;
* `box_integral.box.Icc`: the closed box `set.Icc I.lower I.upper`; defined as a bundled monotone
  map from `box ι` to `set (ι → ℝ)`;
* `box_integral.box.face I i : box (fin n)`: a hyperface of `I : box_integral.box (fin (n + 1))`;
* `box_integral.box.distortion`: the maximal ratio of two lengths of edges of a box; defined as the
  supremum of `nndist I.lower I.upper / nndist (I.lower i) (I.upper i)`.

We also provide a convenience constructor `box_integral.box.mk' (l u : ι → ℝ) : with_bot (box ι)`
that returns the box `⟨l, u, _⟩` if it is nonempty and `⊥` otherwise.

## Tags

rectangular box
-/


open Set Function Metric Filter

noncomputable section

open NNReal Classical Topology

namespace BoxIntegral

variable {ι : Type _}

/-!
### Rectangular box: definition and partial order
-/


#print BoxIntegral.Box /-
/-- A nontrivial rectangular box in `ι → ℝ` with corners `lower` and `upper`. Repesents the product
of half-open intervals `(lower i, upper i]`. -/
structure Box (ι : Type _) where
  (lower upper : ι → ℝ)
  lower_lt_upper : ∀ i, lower i < upper i
#align box_integral.box BoxIntegral.Box
-/

attribute [simp] box.lower_lt_upper

namespace Box

variable (I J : Box ι) {x y : ι → ℝ}

instance : Inhabited (Box ι) :=
  ⟨⟨0, 1, fun i => zero_lt_one⟩⟩

/- warning: box_integral.box.lower_le_upper -> BoxIntegral.Box.lower_le_upper is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (I : BoxIntegral.Box.{u1} ι), LE.le.{u1} (ι -> Real) (Pi.hasLe.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.hasLe)) (BoxIntegral.Box.lower.{u1} ι I) (BoxIntegral.Box.upper.{u1} ι I)
but is expected to have type
  forall {ι : Type.{u1}} (I : BoxIntegral.Box.{u1} ι), LE.le.{u1} (ι -> Real) (Pi.hasLe.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.instLEReal)) (BoxIntegral.Box.lower.{u1} ι I) (BoxIntegral.Box.upper.{u1} ι I)
Case conversion may be inaccurate. Consider using '#align box_integral.box.lower_le_upper BoxIntegral.Box.lower_le_upperₓ'. -/
theorem lower_le_upper : I.lower ≤ I.upper := fun i => (I.lower_lt_upper i).le
#align box_integral.box.lower_le_upper BoxIntegral.Box.lower_le_upper

#print BoxIntegral.Box.lower_ne_upper /-
theorem lower_ne_upper (i) : I.lower i ≠ I.upper i :=
  (I.lower_lt_upper i).Ne
#align box_integral.box.lower_ne_upper BoxIntegral.Box.lower_ne_upper
-/

instance : Membership (ι → ℝ) (Box ι) :=
  ⟨fun x I => ∀ i, x i ∈ Ioc (I.lower i) (I.upper i)⟩

instance : CoeTC (Box ι) (Set <| ι → ℝ) :=
  ⟨fun I => { x | x ∈ I }⟩

/- warning: box_integral.box.mem_mk -> BoxIntegral.Box.mem_mk is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {l : ι -> Real} {u : ι -> Real} {x : ι -> Real} {H : forall (i : ι), LT.lt.{0} Real Real.hasLt (l i) (u i)}, Iff (Membership.Mem.{u1, u1} (ι -> Real) (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasMem.{u1} ι) x (BoxIntegral.Box.mk.{u1} ι l u H)) (forall (i : ι), Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) (x i) (Set.Ioc.{0} Real Real.preorder (l i) (u i)))
but is expected to have type
  forall {ι : Type.{u1}} {l : ι -> Real} {u : ι -> Real} {x : ι -> Real} {H : forall (i : ι), LT.lt.{0} Real Real.instLTReal (l i) (u i)}, Iff (Membership.mem.{u1, u1} (ι -> Real) (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instMembershipForAllRealBox.{u1} ι) x (BoxIntegral.Box.mk.{u1} ι l u H)) (forall (i : ι), Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) (x i) (Set.Ioc.{0} Real Real.instPreorderReal (l i) (u i)))
Case conversion may be inaccurate. Consider using '#align box_integral.box.mem_mk BoxIntegral.Box.mem_mkₓ'. -/
@[simp]
theorem mem_mk {l u x : ι → ℝ} {H} : x ∈ mk l u H ↔ ∀ i, x i ∈ Ioc (l i) (u i) :=
  Iff.rfl
#align box_integral.box.mem_mk BoxIntegral.Box.mem_mk

#print BoxIntegral.Box.mem_coe /-
@[simp, norm_cast]
theorem mem_coe : x ∈ (I : Set (ι → ℝ)) ↔ x ∈ I :=
  Iff.rfl
#align box_integral.box.mem_coe BoxIntegral.Box.mem_coe
-/

#print BoxIntegral.Box.mem_def /-
theorem mem_def : x ∈ I ↔ ∀ i, x i ∈ Ioc (I.lower i) (I.upper i) :=
  Iff.rfl
#align box_integral.box.mem_def BoxIntegral.Box.mem_def
-/

#print BoxIntegral.Box.mem_univ_Ioc /-
theorem mem_univ_Ioc {I : Box ι} : (x ∈ pi univ fun i => Ioc (I.lower i) (I.upper i)) ↔ x ∈ I :=
  mem_univ_pi
#align box_integral.box.mem_univ_Ioc BoxIntegral.Box.mem_univ_Ioc
-/

#print BoxIntegral.Box.coe_eq_pi /-
theorem coe_eq_pi : (I : Set (ι → ℝ)) = pi univ fun i => Ioc (I.lower i) (I.upper i) :=
  Set.ext fun x => mem_univ_Ioc.symm
#align box_integral.box.coe_eq_pi BoxIntegral.Box.coe_eq_pi
-/

#print BoxIntegral.Box.upper_mem /-
@[simp]
theorem upper_mem : I.upper ∈ I := fun i => right_mem_Ioc.2 <| I.lower_lt_upper i
#align box_integral.box.upper_mem BoxIntegral.Box.upper_mem
-/

#print BoxIntegral.Box.exists_mem /-
theorem exists_mem : ∃ x, x ∈ I :=
  ⟨_, I.upper_mem⟩
#align box_integral.box.exists_mem BoxIntegral.Box.exists_mem
-/

#print BoxIntegral.Box.nonempty_coe /-
theorem nonempty_coe : Set.Nonempty (I : Set (ι → ℝ)) :=
  I.exists_mem
#align box_integral.box.nonempty_coe BoxIntegral.Box.nonempty_coe
-/

#print BoxIntegral.Box.coe_ne_empty /-
@[simp]
theorem coe_ne_empty : (I : Set (ι → ℝ)) ≠ ∅ :=
  I.nonempty_coe.ne_empty
#align box_integral.box.coe_ne_empty BoxIntegral.Box.coe_ne_empty
-/

#print BoxIntegral.Box.empty_ne_coe /-
@[simp]
theorem empty_ne_coe : ∅ ≠ (I : Set (ι → ℝ)) :=
  I.coe_ne_empty.symm
#align box_integral.box.empty_ne_coe BoxIntegral.Box.empty_ne_coe
-/

instance : LE (Box ι) :=
  ⟨fun I J => ∀ ⦃x⦄, x ∈ I → x ∈ J⟩

#print BoxIntegral.Box.le_def /-
theorem le_def : I ≤ J ↔ ∀ x ∈ I, x ∈ J :=
  Iff.rfl
#align box_integral.box.le_def BoxIntegral.Box.le_def
-/

/- warning: box_integral.box.le_tfae -> BoxIntegral.Box.le_TFAE is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (I : BoxIntegral.Box.{u1} ι) (J : BoxIntegral.Box.{u1} ι), List.TFAE (List.cons.{0} Prop (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι) I J) (List.cons.{0} Prop (HasSubset.Subset.{u1} (Set.{u1} (ι -> Real)) (Set.hasSubset.{u1} (ι -> Real)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.Set.hasCoeT.{u1} ι))) I) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.Set.hasCoeT.{u1} ι))) J)) (List.cons.{0} Prop (HasSubset.Subset.{u1} (Set.{u1} (ι -> Real)) (Set.hasSubset.{u1} (ι -> Real)) (Set.Icc.{u1} (ι -> Real) (Pi.preorder.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.preorder)) (BoxIntegral.Box.lower.{u1} ι I) (BoxIntegral.Box.upper.{u1} ι I)) (Set.Icc.{u1} (ι -> Real) (Pi.preorder.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.preorder)) (BoxIntegral.Box.lower.{u1} ι J) (BoxIntegral.Box.upper.{u1} ι J))) (List.cons.{0} Prop (And (LE.le.{u1} (ι -> Real) (Pi.hasLe.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.hasLe)) (BoxIntegral.Box.lower.{u1} ι J) (BoxIntegral.Box.lower.{u1} ι I)) (LE.le.{u1} (ι -> Real) (Pi.hasLe.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.hasLe)) (BoxIntegral.Box.upper.{u1} ι I) (BoxIntegral.Box.upper.{u1} ι J))) (List.nil.{0} Prop)))))
but is expected to have type
  forall {ι : Type.{u1}} (I : BoxIntegral.Box.{u1} ι) (J : BoxIntegral.Box.{u1} ι), List.TFAE (List.cons.{0} Prop (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) I J) (List.cons.{0} Prop (HasSubset.Subset.{u1} (Set.{u1} (ι -> Real)) (Set.instHasSubsetSet.{u1} (ι -> Real)) (BoxIntegral.Box.toSet.{u1} ι I) (BoxIntegral.Box.toSet.{u1} ι J)) (List.cons.{0} Prop (HasSubset.Subset.{u1} (Set.{u1} (ι -> Real)) (Set.instHasSubsetSet.{u1} (ι -> Real)) (Set.Icc.{u1} (ι -> Real) (Pi.preorder.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.instPreorderReal)) (BoxIntegral.Box.lower.{u1} ι I) (BoxIntegral.Box.upper.{u1} ι I)) (Set.Icc.{u1} (ι -> Real) (Pi.preorder.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.instPreorderReal)) (BoxIntegral.Box.lower.{u1} ι J) (BoxIntegral.Box.upper.{u1} ι J))) (List.cons.{0} Prop (And (LE.le.{u1} (ι -> Real) (Pi.hasLe.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.instLEReal)) (BoxIntegral.Box.lower.{u1} ι J) (BoxIntegral.Box.lower.{u1} ι I)) (LE.le.{u1} (ι -> Real) (Pi.hasLe.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.instLEReal)) (BoxIntegral.Box.upper.{u1} ι I) (BoxIntegral.Box.upper.{u1} ι J))) (List.nil.{0} Prop)))))
Case conversion may be inaccurate. Consider using '#align box_integral.box.le_tfae BoxIntegral.Box.le_TFAEₓ'. -/
theorem le_TFAE :
    TFAE
      [I ≤ J, (I : Set (ι → ℝ)) ⊆ J, Icc I.lower I.upper ⊆ Icc J.lower J.upper,
        J.lower ≤ I.lower ∧ I.upper ≤ J.upper] :=
  by
  tfae_have 1 ↔ 2; exact Iff.rfl
  tfae_have 2 → 3
  · intro h
    simpa [coe_eq_pi, closure_pi_set, lower_ne_upper] using closure_mono h
  tfae_have 3 ↔ 4; exact Icc_subset_Icc_iff I.lower_le_upper
  tfae_have 4 → 2; exact fun h x hx i => Ioc_subset_Ioc (h.1 i) (h.2 i) (hx i)
  tfae_finish
#align box_integral.box.le_tfae BoxIntegral.Box.le_TFAE

variable {I J}

#print BoxIntegral.Box.coe_subset_coe /-
@[simp, norm_cast]
theorem coe_subset_coe : (I : Set (ι → ℝ)) ⊆ J ↔ I ≤ J :=
  Iff.rfl
#align box_integral.box.coe_subset_coe BoxIntegral.Box.coe_subset_coe
-/

/- warning: box_integral.box.le_iff_bounds -> BoxIntegral.Box.le_iff_bounds is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι} {J : BoxIntegral.Box.{u1} ι}, Iff (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι) I J) (And (LE.le.{u1} (ι -> Real) (Pi.hasLe.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.hasLe)) (BoxIntegral.Box.lower.{u1} ι J) (BoxIntegral.Box.lower.{u1} ι I)) (LE.le.{u1} (ι -> Real) (Pi.hasLe.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.hasLe)) (BoxIntegral.Box.upper.{u1} ι I) (BoxIntegral.Box.upper.{u1} ι J)))
but is expected to have type
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι} {J : BoxIntegral.Box.{u1} ι}, Iff (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) I J) (And (LE.le.{u1} (ι -> Real) (Pi.hasLe.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.instLEReal)) (BoxIntegral.Box.lower.{u1} ι J) (BoxIntegral.Box.lower.{u1} ι I)) (LE.le.{u1} (ι -> Real) (Pi.hasLe.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.instLEReal)) (BoxIntegral.Box.upper.{u1} ι I) (BoxIntegral.Box.upper.{u1} ι J)))
Case conversion may be inaccurate. Consider using '#align box_integral.box.le_iff_bounds BoxIntegral.Box.le_iff_boundsₓ'. -/
theorem le_iff_bounds : I ≤ J ↔ J.lower ≤ I.lower ∧ I.upper ≤ J.upper :=
  (le_TFAE I J).out 0 3
#align box_integral.box.le_iff_bounds BoxIntegral.Box.le_iff_bounds

#print BoxIntegral.Box.injective_coe /-
theorem injective_coe : Injective (coe : Box ι → Set (ι → ℝ)) :=
  by
  rintro ⟨l₁, u₁, h₁⟩ ⟨l₂, u₂, h₂⟩ h
  simp only [subset.antisymm_iff, coe_subset_coe, le_iff_bounds] at h
  congr
  exacts[le_antisymm h.2.1 h.1.1, le_antisymm h.1.2 h.2.2]
#align box_integral.box.injective_coe BoxIntegral.Box.injective_coe
-/

#print BoxIntegral.Box.coe_inj /-
@[simp, norm_cast]
theorem coe_inj : (I : Set (ι → ℝ)) = J ↔ I = J :=
  injective_coe.eq_iff
#align box_integral.box.coe_inj BoxIntegral.Box.coe_inj
-/

#print BoxIntegral.Box.ext /-
@[ext]
theorem ext (H : ∀ x, x ∈ I ↔ x ∈ J) : I = J :=
  injective_coe <| Set.ext H
#align box_integral.box.ext BoxIntegral.Box.ext
-/

/- warning: box_integral.box.ne_of_disjoint_coe -> BoxIntegral.Box.ne_of_disjoint_coe is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι} {J : BoxIntegral.Box.{u1} ι}, (Disjoint.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} (Set.{u1} (ι -> Real)) (BooleanAlgebra.toGeneralizedBooleanAlgebra.{u1} (Set.{u1} (ι -> Real)) (Set.booleanAlgebra.{u1} (ι -> Real)))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.Set.hasCoeT.{u1} ι))) I) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.Set.hasCoeT.{u1} ι))) J)) -> (Ne.{succ u1} (BoxIntegral.Box.{u1} ι) I J)
but is expected to have type
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι} {J : BoxIntegral.Box.{u1} ι}, (Disjoint.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.instCompleteBooleanAlgebraSet.{u1} (ι -> Real))))))) (BoundedOrder.toOrderBot.{u1} (Set.{u1} (ι -> Real)) (Preorder.toLE.{u1} (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.instCompleteBooleanAlgebraSet.{u1} (ι -> Real))))))))) (CompleteLattice.toBoundedOrder.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.instCompleteBooleanAlgebraSet.{u1} (ι -> Real))))))) (BoxIntegral.Box.toSet.{u1} ι I) (BoxIntegral.Box.toSet.{u1} ι J)) -> (Ne.{succ u1} (BoxIntegral.Box.{u1} ι) I J)
Case conversion may be inaccurate. Consider using '#align box_integral.box.ne_of_disjoint_coe BoxIntegral.Box.ne_of_disjoint_coeₓ'. -/
theorem ne_of_disjoint_coe (h : Disjoint (I : Set (ι → ℝ)) J) : I ≠ J :=
  mt coe_inj.2 <| h.Ne I.coe_ne_empty
#align box_integral.box.ne_of_disjoint_coe BoxIntegral.Box.ne_of_disjoint_coe

instance : PartialOrder (Box ι) :=
  { PartialOrder.lift (coe : Box ι → Set (ι → ℝ)) injective_coe with le := (· ≤ ·) }

#print BoxIntegral.Box.Icc /-
/-- Closed box corresponding to `I : box_integral.box ι`. -/
protected def Icc : Box ι ↪o Set (ι → ℝ) :=
  OrderEmbedding.ofMapLEIff (fun I : Box ι => Icc I.lower I.upper) fun I J => (le_TFAE I J).out 2 0
#align box_integral.box.Icc BoxIntegral.Box.Icc
-/

/- warning: box_integral.box.Icc_def -> BoxIntegral.Box.icc_def is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι}, Eq.{succ u1} (Set.{u1} (ι -> Real)) (coeFn.{succ u1, succ u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.hasLe.{u1} ι) (Set.hasLe.{u1} (ι -> Real))) (fun (_x : RelEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (RelEmbedding.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) (BoxIntegral.Box.Icc.{u1} ι) I) (Set.Icc.{u1} (ι -> Real) (Pi.preorder.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.preorder)) (BoxIntegral.Box.lower.{u1} ι I) (BoxIntegral.Box.upper.{u1} ι I))
but is expected to have type
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι}, Eq.{succ u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) I) (FunLike.coe.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (fun (_x : BoxIntegral.Box.{u1} ι) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (Function.instEmbeddingLikeEmbedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)))) (RelEmbedding.toEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : BoxIntegral.Box.{u1} ι) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{u1} ι) => LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Set.{u1} (ι -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{u1} (ι -> Real)) => LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.instLESet.{u1} (ι -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (BoxIntegral.Box.Icc.{u1} ι)) I) (Set.Icc.{u1} (ι -> Real) (Pi.preorder.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.instPreorderReal)) (BoxIntegral.Box.lower.{u1} ι I) (BoxIntegral.Box.upper.{u1} ι I))
Case conversion may be inaccurate. Consider using '#align box_integral.box.Icc_def BoxIntegral.Box.icc_defₓ'. -/
theorem icc_def : I.Icc = Icc I.lower I.upper :=
  rfl
#align box_integral.box.Icc_def BoxIntegral.Box.icc_def

/- warning: box_integral.box.upper_mem_Icc -> BoxIntegral.Box.upper_mem_icc is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (I : BoxIntegral.Box.{u1} ι), Membership.Mem.{u1, u1} (ι -> Real) (Set.{u1} (ι -> Real)) (Set.hasMem.{u1} (ι -> Real)) (BoxIntegral.Box.upper.{u1} ι I) (coeFn.{succ u1, succ u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.hasLe.{u1} ι) (Set.hasLe.{u1} (ι -> Real))) (fun (_x : RelEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (RelEmbedding.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) (BoxIntegral.Box.Icc.{u1} ι) I)
but is expected to have type
  forall {ι : Type.{u1}} (I : BoxIntegral.Box.{u1} ι), Membership.mem.{u1, u1} (ι -> Real) ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) I) (Set.instMembershipSet.{u1} (ι -> Real)) (BoxIntegral.Box.upper.{u1} ι I) (FunLike.coe.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (fun (_x : BoxIntegral.Box.{u1} ι) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (Function.instEmbeddingLikeEmbedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)))) (RelEmbedding.toEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : BoxIntegral.Box.{u1} ι) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{u1} ι) => LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Set.{u1} (ι -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{u1} (ι -> Real)) => LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.instLESet.{u1} (ι -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (BoxIntegral.Box.Icc.{u1} ι)) I)
Case conversion may be inaccurate. Consider using '#align box_integral.box.upper_mem_Icc BoxIntegral.Box.upper_mem_iccₓ'. -/
@[simp]
theorem upper_mem_icc (I : Box ι) : I.upper ∈ I.Icc :=
  right_mem_Icc.2 I.lower_le_upper
#align box_integral.box.upper_mem_Icc BoxIntegral.Box.upper_mem_icc

/- warning: box_integral.box.lower_mem_Icc -> BoxIntegral.Box.lower_mem_icc is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (I : BoxIntegral.Box.{u1} ι), Membership.Mem.{u1, u1} (ι -> Real) (Set.{u1} (ι -> Real)) (Set.hasMem.{u1} (ι -> Real)) (BoxIntegral.Box.lower.{u1} ι I) (coeFn.{succ u1, succ u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.hasLe.{u1} ι) (Set.hasLe.{u1} (ι -> Real))) (fun (_x : RelEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (RelEmbedding.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) (BoxIntegral.Box.Icc.{u1} ι) I)
but is expected to have type
  forall {ι : Type.{u1}} (I : BoxIntegral.Box.{u1} ι), Membership.mem.{u1, u1} (ι -> Real) ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) I) (Set.instMembershipSet.{u1} (ι -> Real)) (BoxIntegral.Box.lower.{u1} ι I) (FunLike.coe.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (fun (_x : BoxIntegral.Box.{u1} ι) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (Function.instEmbeddingLikeEmbedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)))) (RelEmbedding.toEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : BoxIntegral.Box.{u1} ι) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{u1} ι) => LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Set.{u1} (ι -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{u1} (ι -> Real)) => LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.instLESet.{u1} (ι -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (BoxIntegral.Box.Icc.{u1} ι)) I)
Case conversion may be inaccurate. Consider using '#align box_integral.box.lower_mem_Icc BoxIntegral.Box.lower_mem_iccₓ'. -/
@[simp]
theorem lower_mem_icc (I : Box ι) : I.lower ∈ I.Icc :=
  left_mem_Icc.2 I.lower_le_upper
#align box_integral.box.lower_mem_Icc BoxIntegral.Box.lower_mem_icc

/- warning: box_integral.box.is_compact_Icc -> BoxIntegral.Box.isCompact_icc is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (I : BoxIntegral.Box.{u1} ι), IsCompact.{u1} (ι -> Real) (Pi.topologicalSpace.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (a : ι) => UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (coeFn.{succ u1, succ u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.hasLe.{u1} ι) (Set.hasLe.{u1} (ι -> Real))) (fun (_x : RelEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (RelEmbedding.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) (BoxIntegral.Box.Icc.{u1} ι) I)
but is expected to have type
  forall {ι : Type.{u1}} (I : BoxIntegral.Box.{u1} ι), IsCompact.{u1} (ι -> Real) (Pi.topologicalSpace.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (a : ι) => UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (FunLike.coe.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (fun (_x : BoxIntegral.Box.{u1} ι) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (Function.instEmbeddingLikeEmbedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)))) (RelEmbedding.toEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : BoxIntegral.Box.{u1} ι) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{u1} ι) => LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Set.{u1} (ι -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{u1} (ι -> Real)) => LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.instLESet.{u1} (ι -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (BoxIntegral.Box.Icc.{u1} ι)) I)
Case conversion may be inaccurate. Consider using '#align box_integral.box.is_compact_Icc BoxIntegral.Box.isCompact_iccₓ'. -/
protected theorem isCompact_icc (I : Box ι) : IsCompact I.Icc :=
  isCompact_Icc
#align box_integral.box.is_compact_Icc BoxIntegral.Box.isCompact_icc

/- warning: box_integral.box.Icc_eq_pi -> BoxIntegral.Box.icc_eq_pi is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι}, Eq.{succ u1} (Set.{u1} (ι -> Real)) (coeFn.{succ u1, succ u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.hasLe.{u1} ι) (Set.hasLe.{u1} (ι -> Real))) (fun (_x : RelEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (RelEmbedding.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) (BoxIntegral.Box.Icc.{u1} ι) I) (Set.pi.{u1, 0} ι (fun (ᾰ : ι) => Real) (Set.univ.{u1} ι) (fun (i : ι) => Set.Icc.{0} Real Real.preorder (BoxIntegral.Box.lower.{u1} ι I i) (BoxIntegral.Box.upper.{u1} ι I i)))
but is expected to have type
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι}, Eq.{succ u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) I) (FunLike.coe.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (fun (_x : BoxIntegral.Box.{u1} ι) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (Function.instEmbeddingLikeEmbedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)))) (RelEmbedding.toEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : BoxIntegral.Box.{u1} ι) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{u1} ι) => LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Set.{u1} (ι -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{u1} (ι -> Real)) => LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.instLESet.{u1} (ι -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (BoxIntegral.Box.Icc.{u1} ι)) I) (Set.pi.{u1, 0} ι (fun (ᾰ : ι) => Real) (Set.univ.{u1} ι) (fun (i : ι) => Set.Icc.{0} Real Real.instPreorderReal (BoxIntegral.Box.lower.{u1} ι I i) (BoxIntegral.Box.upper.{u1} ι I i)))
Case conversion may be inaccurate. Consider using '#align box_integral.box.Icc_eq_pi BoxIntegral.Box.icc_eq_piₓ'. -/
theorem icc_eq_pi : I.Icc = pi univ fun i => Icc (I.lower i) (I.upper i) :=
  (pi_univ_Icc _ _).symm
#align box_integral.box.Icc_eq_pi BoxIntegral.Box.icc_eq_pi

/- warning: box_integral.box.le_iff_Icc -> BoxIntegral.Box.le_iff_icc is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι} {J : BoxIntegral.Box.{u1} ι}, Iff (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι) I J) (HasSubset.Subset.{u1} (Set.{u1} (ι -> Real)) (Set.hasSubset.{u1} (ι -> Real)) (coeFn.{succ u1, succ u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.hasLe.{u1} ι) (Set.hasLe.{u1} (ι -> Real))) (fun (_x : RelEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (RelEmbedding.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) (BoxIntegral.Box.Icc.{u1} ι) I) (coeFn.{succ u1, succ u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.hasLe.{u1} ι) (Set.hasLe.{u1} (ι -> Real))) (fun (_x : RelEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (RelEmbedding.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) (BoxIntegral.Box.Icc.{u1} ι) J))
but is expected to have type
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι} {J : BoxIntegral.Box.{u1} ι}, Iff (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) I J) (HasSubset.Subset.{u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) I) (Set.instHasSubsetSet.{u1} (ι -> Real)) (FunLike.coe.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (fun (_x : BoxIntegral.Box.{u1} ι) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (Function.instEmbeddingLikeEmbedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)))) (RelEmbedding.toEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : BoxIntegral.Box.{u1} ι) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{u1} ι) => LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Set.{u1} (ι -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{u1} (ι -> Real)) => LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.instLESet.{u1} (ι -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (BoxIntegral.Box.Icc.{u1} ι)) I) (FunLike.coe.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (fun (_x : BoxIntegral.Box.{u1} ι) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (Function.instEmbeddingLikeEmbedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)))) (RelEmbedding.toEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : BoxIntegral.Box.{u1} ι) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{u1} ι) => LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Set.{u1} (ι -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{u1} (ι -> Real)) => LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.instLESet.{u1} (ι -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (BoxIntegral.Box.Icc.{u1} ι)) J))
Case conversion may be inaccurate. Consider using '#align box_integral.box.le_iff_Icc BoxIntegral.Box.le_iff_iccₓ'. -/
theorem le_iff_icc : I ≤ J ↔ I.Icc ⊆ J.Icc :=
  (le_TFAE I J).out 0 2
#align box_integral.box.le_iff_Icc BoxIntegral.Box.le_iff_icc

/- warning: box_integral.box.antitone_lower -> BoxIntegral.Box.antitone_lower is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}}, Antitone.{u1, u1} (BoxIntegral.Box.{u1} ι) (ι -> Real) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (Pi.preorder.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.preorder)) (fun (I : BoxIntegral.Box.{u1} ι) => BoxIntegral.Box.lower.{u1} ι I)
but is expected to have type
  forall {ι : Type.{u1}}, Antitone.{u1, u1} (BoxIntegral.Box.{u1} ι) (ι -> Real) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)) (Pi.preorder.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.instPreorderReal)) (fun (I : BoxIntegral.Box.{u1} ι) => BoxIntegral.Box.lower.{u1} ι I)
Case conversion may be inaccurate. Consider using '#align box_integral.box.antitone_lower BoxIntegral.Box.antitone_lowerₓ'. -/
theorem antitone_lower : Antitone fun I : Box ι => I.lower := fun I J H => (le_iff_bounds.1 H).1
#align box_integral.box.antitone_lower BoxIntegral.Box.antitone_lower

/- warning: box_integral.box.monotone_upper -> BoxIntegral.Box.monotone_upper is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}}, Monotone.{u1, u1} (BoxIntegral.Box.{u1} ι) (ι -> Real) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (Pi.preorder.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.preorder)) (fun (I : BoxIntegral.Box.{u1} ι) => BoxIntegral.Box.upper.{u1} ι I)
but is expected to have type
  forall {ι : Type.{u1}}, Monotone.{u1, u1} (BoxIntegral.Box.{u1} ι) (ι -> Real) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)) (Pi.preorder.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (i : ι) => Real.instPreorderReal)) (fun (I : BoxIntegral.Box.{u1} ι) => BoxIntegral.Box.upper.{u1} ι I)
Case conversion may be inaccurate. Consider using '#align box_integral.box.monotone_upper BoxIntegral.Box.monotone_upperₓ'. -/
theorem monotone_upper : Monotone fun I : Box ι => I.upper := fun I J H => (le_iff_bounds.1 H).2
#align box_integral.box.monotone_upper BoxIntegral.Box.monotone_upper

/- warning: box_integral.box.coe_subset_Icc -> BoxIntegral.Box.coe_subset_icc is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι}, HasSubset.Subset.{u1} (Set.{u1} (ι -> Real)) (Set.hasSubset.{u1} (ι -> Real)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.Set.hasCoeT.{u1} ι))) I) (coeFn.{succ u1, succ u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.hasLe.{u1} ι) (Set.hasLe.{u1} (ι -> Real))) (fun (_x : RelEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (RelEmbedding.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) (BoxIntegral.Box.Icc.{u1} ι) I)
but is expected to have type
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι}, HasSubset.Subset.{u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) I) (Set.instHasSubsetSet.{u1} (ι -> Real)) (BoxIntegral.Box.toSet.{u1} ι I) (FunLike.coe.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (fun (_x : BoxIntegral.Box.{u1} ι) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (Function.instEmbeddingLikeEmbedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)))) (RelEmbedding.toEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : BoxIntegral.Box.{u1} ι) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{u1} ι) => LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Set.{u1} (ι -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{u1} (ι -> Real)) => LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.instLESet.{u1} (ι -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (BoxIntegral.Box.Icc.{u1} ι)) I)
Case conversion may be inaccurate. Consider using '#align box_integral.box.coe_subset_Icc BoxIntegral.Box.coe_subset_iccₓ'. -/
theorem coe_subset_icc : ↑I ⊆ I.Icc := fun x hx => ⟨fun i => (hx i).1.le, fun i => (hx i).2⟩
#align box_integral.box.coe_subset_Icc BoxIntegral.Box.coe_subset_icc

/-!
### Supremum of two boxes
-/


/-- `I ⊔ J` is the least box that includes both `I` and `J`. Since `↑I ∪ ↑J` is usually not a box,
`↑(I ⊔ J)` is larger than `↑I ∪ ↑J`. -/
instance : Sup (Box ι) :=
  ⟨fun I J =>
    ⟨I.lower ⊓ J.lower, I.upper ⊔ J.upper, fun i =>
      (min_le_left _ _).trans_lt <| (I.lower_lt_upper i).trans_le (le_max_left _ _)⟩⟩

instance : SemilatticeSup (Box ι) :=
  { Box.partialOrder,
    Box.hasSup with
    le_sup_left := fun I J => le_iff_bounds.2 ⟨inf_le_left, le_sup_left⟩
    le_sup_right := fun I J => le_iff_bounds.2 ⟨inf_le_right, le_sup_right⟩
    sup_le := fun I₁ I₂ J h₁ h₂ =>
      le_iff_bounds.2
        ⟨le_inf (antitone_lower h₁) (antitone_lower h₂),
          sup_le (monotone_upper h₁) (monotone_upper h₂)⟩ }

/-!
### `with_bot (box ι)`

In this section we define coercion from `with_bot (box ι)` to `set (ι → ℝ)` by sending `⊥` to `∅`.
-/


/- warning: box_integral.box.with_bot_coe -> BoxIntegral.Box.withBotCoe is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}}, CoeTCₓ.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real))
but is expected to have type
  forall {ι : Type.{u1}}, CoeTC.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real))
Case conversion may be inaccurate. Consider using '#align box_integral.box.with_bot_coe BoxIntegral.Box.withBotCoeₓ'. -/
instance withBotCoe : CoeTC (WithBot (Box ι)) (Set (ι → ℝ)) :=
  ⟨fun o => o.elim ∅ coe⟩
#align box_integral.box.with_bot_coe BoxIntegral.Box.withBotCoe

#print BoxIntegral.Box.coe_bot /-
@[simp, norm_cast]
theorem coe_bot : ((⊥ : WithBot (Box ι)) : Set (ι → ℝ)) = ∅ :=
  rfl
#align box_integral.box.coe_bot BoxIntegral.Box.coe_bot
-/

#print BoxIntegral.Box.coe_coe /-
@[simp, norm_cast]
theorem coe_coe : ((I : WithBot (Box ι)) : Set (ι → ℝ)) = I :=
  rfl
#align box_integral.box.coe_coe BoxIntegral.Box.coe_coe
-/

#print BoxIntegral.Box.isSome_iff /-
theorem isSome_iff : ∀ {I : WithBot (Box ι)}, I.isSome ↔ (I : Set (ι → ℝ)).Nonempty
  | ⊥ => by
    erw [Option.isSome]
    simp
  | (I : box ι) => by
    erw [Option.isSome]
    simp [I.nonempty_coe]
#align box_integral.box.is_some_iff BoxIntegral.Box.isSome_iff
-/

#print BoxIntegral.Box.bUnion_coe_eq_coe /-
theorem bUnion_coe_eq_coe (I : WithBot (Box ι)) :
    (⋃ (J : Box ι) (hJ : ↑J = I), (J : Set (ι → ℝ))) = I := by
  induction I using WithBot.recBotCoe <;> simp [WithBot.coe_eq_coe]
#align box_integral.box.bUnion_coe_eq_coe BoxIntegral.Box.bUnion_coe_eq_coe
-/

/- warning: box_integral.box.with_bot_coe_subset_iff -> BoxIntegral.Box.withBotCoe_subset_iff is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {I : WithBot.{u1} (BoxIntegral.Box.{u1} ι)} {J : WithBot.{u1} (BoxIntegral.Box.{u1} ι)}, Iff (HasSubset.Subset.{u1} (Set.{u1} (ι -> Real)) (Set.hasSubset.{u1} (ι -> Real)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.withBotCoe.{u1} ι))) I) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.withBotCoe.{u1} ι))) J)) (LE.le.{u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Preorder.toLE.{u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (WithBot.preorder.{u1} (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)))) I J)
but is expected to have type
  forall {ι : Type.{u1}} {I : WithBot.{u1} (BoxIntegral.Box.{u1} ι)} {J : WithBot.{u1} (BoxIntegral.Box.{u1} ι)}, Iff (HasSubset.Subset.{u1} (Set.{u1} (ι -> Real)) (Set.instHasSubsetSet.{u1} (ι -> Real)) (BoxIntegral.Box.withBotToSet.{u1} ι I) (BoxIntegral.Box.withBotToSet.{u1} ι J)) (LE.le.{u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Preorder.toLE.{u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (WithBot.preorder.{u1} (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)))) I J)
Case conversion may be inaccurate. Consider using '#align box_integral.box.with_bot_coe_subset_iff BoxIntegral.Box.withBotCoe_subset_iffₓ'. -/
@[simp, norm_cast]
theorem withBotCoe_subset_iff {I J : WithBot (Box ι)} : (I : Set (ι → ℝ)) ⊆ J ↔ I ≤ J :=
  by
  induction I using WithBot.recBotCoe; · simp
  induction J using WithBot.recBotCoe; · simp [subset_empty_iff]
  simp
#align box_integral.box.with_bot_coe_subset_iff BoxIntegral.Box.withBotCoe_subset_iff

#print BoxIntegral.Box.withBotCoe_inj /-
@[simp, norm_cast]
theorem withBotCoe_inj {I J : WithBot (Box ι)} : (I : Set (ι → ℝ)) = J ↔ I = J := by
  simp only [subset.antisymm_iff, ← le_antisymm_iff, with_bot_coe_subset_iff]
#align box_integral.box.with_bot_coe_inj BoxIntegral.Box.withBotCoe_inj
-/

#print BoxIntegral.Box.mk' /-
/-- Make a `with_bot (box ι)` from a pair of corners `l u : ι → ℝ`. If `l i < u i` for all `i`,
then the result is `⟨l, u, _⟩ : box ι`, otherwise it is `⊥`. In any case, the result interpreted
as a set in `ι → ℝ` is the set `{x : ι → ℝ | ∀ i, x i ∈ Ioc (l i) (u i)}`.  -/
def mk' (l u : ι → ℝ) : WithBot (Box ι) :=
  if h : ∀ i, l i < u i then ↑(⟨l, u, h⟩ : Box ι) else ⊥
#align box_integral.box.mk' BoxIntegral.Box.mk'
-/

/- warning: box_integral.box.mk'_eq_bot -> BoxIntegral.Box.mk'_eq_bot is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {l : ι -> Real} {u : ι -> Real}, Iff (Eq.{succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (BoxIntegral.Box.mk'.{u1} ι l u) (Bot.bot.{u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (WithBot.hasBot.{u1} (BoxIntegral.Box.{u1} ι)))) (Exists.{succ u1} ι (fun (i : ι) => LE.le.{0} Real Real.hasLe (u i) (l i)))
but is expected to have type
  forall {ι : Type.{u1}} {l : ι -> Real} {u : ι -> Real}, Iff (Eq.{succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (BoxIntegral.Box.mk'.{u1} ι l u) (Bot.bot.{u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (WithBot.bot.{u1} (BoxIntegral.Box.{u1} ι)))) (Exists.{succ u1} ι (fun (i : ι) => LE.le.{0} Real Real.instLEReal (u i) (l i)))
Case conversion may be inaccurate. Consider using '#align box_integral.box.mk'_eq_bot BoxIntegral.Box.mk'_eq_botₓ'. -/
@[simp]
theorem mk'_eq_bot {l u : ι → ℝ} : mk' l u = ⊥ ↔ ∃ i, u i ≤ l i :=
  by
  rw [mk']
  split_ifs <;> simpa using h
#align box_integral.box.mk'_eq_bot BoxIntegral.Box.mk'_eq_bot

#print BoxIntegral.Box.mk'_eq_coe /-
@[simp]
theorem mk'_eq_coe {l u : ι → ℝ} : mk' l u = I ↔ l = I.lower ∧ u = I.upper :=
  by
  cases' I with lI uI hI; rw [mk']; split_ifs
  · simp [WithBot.coe_eq_coe]
  · suffices l = lI → u ≠ uI by simpa
    rintro rfl rfl
    exact h hI
#align box_integral.box.mk'_eq_coe BoxIntegral.Box.mk'_eq_coe
-/

#print BoxIntegral.Box.coe_mk' /-
@[simp]
theorem coe_mk' (l u : ι → ℝ) : (mk' l u : Set (ι → ℝ)) = pi univ fun i => Ioc (l i) (u i) :=
  by
  rw [mk']; split_ifs
  · exact coe_eq_pi _
  · rcases not_forall.mp h with ⟨i, hi⟩
    rw [coe_bot, univ_pi_eq_empty]
    exact Ioc_eq_empty hi
#align box_integral.box.coe_mk' BoxIntegral.Box.coe_mk'
-/

instance : Inf (WithBot (Box ι)) :=
  ⟨fun I =>
    WithBot.recBotCoe (fun J => ⊥)
      (fun I J => WithBot.recBotCoe ⊥ (fun J => mk' (I.lower ⊔ J.lower) (I.upper ⊓ J.upper)) J) I⟩

/- warning: box_integral.box.coe_inf -> BoxIntegral.Box.coe_inf is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (I : WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (J : WithBot.{u1} (BoxIntegral.Box.{u1} ι)), Eq.{succ u1} (Set.{u1} (ι -> Real)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.withBotCoe.{u1} ι))) (Inf.inf.{u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (BoxIntegral.Box.WithBot.hasInf.{u1} ι) I J)) (Inter.inter.{u1} (Set.{u1} (ι -> Real)) (Set.hasInter.{u1} (ι -> Real)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.withBotCoe.{u1} ι))) I) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.withBotCoe.{u1} ι))) J))
but is expected to have type
  forall {ι : Type.{u1}} (I : WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (J : WithBot.{u1} (BoxIntegral.Box.{u1} ι)), Eq.{succ u1} (Set.{u1} (ι -> Real)) (BoxIntegral.Box.withBotToSet.{u1} ι (Inf.inf.{u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (BoxIntegral.Box.WithBot.inf.{u1} ι) I J)) (Inter.inter.{u1} (Set.{u1} (ι -> Real)) (Set.instInterSet.{u1} (ι -> Real)) (BoxIntegral.Box.withBotToSet.{u1} ι I) (BoxIntegral.Box.withBotToSet.{u1} ι J))
Case conversion may be inaccurate. Consider using '#align box_integral.box.coe_inf BoxIntegral.Box.coe_infₓ'. -/
@[simp]
theorem coe_inf (I J : WithBot (Box ι)) : (↑(I ⊓ J) : Set (ι → ℝ)) = I ∩ J :=
  by
  induction I using WithBot.recBotCoe;
  · change ∅ = _
    simp
  induction J using WithBot.recBotCoe;
  · change ∅ = _
    simp
  change ↑(mk' _ _) = _
  simp only [coe_eq_pi, ← pi_inter_distrib, Ioc_inter_Ioc, Pi.sup_apply, Pi.inf_apply, coe_mk',
    coe_coe]
#align box_integral.box.coe_inf BoxIntegral.Box.coe_inf

instance : Lattice (WithBot (Box ι)) :=
  { WithBot.semilatticeSup,
    Box.WithBot.hasInf with
    inf_le_left := fun I J => by
      rw [← with_bot_coe_subset_iff, coe_inf]
      exact inter_subset_left _ _
    inf_le_right := fun I J => by
      rw [← with_bot_coe_subset_iff, coe_inf]
      exact inter_subset_right _ _
    le_inf := fun I J₁ J₂ h₁ h₂ =>
      by
      simp only [← with_bot_coe_subset_iff, coe_inf] at *
      exact subset_inter h₁ h₂ }

/- warning: box_integral.box.disjoint_with_bot_coe -> BoxIntegral.Box.disjoint_withBotCoe is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {I : WithBot.{u1} (BoxIntegral.Box.{u1} ι)} {J : WithBot.{u1} (BoxIntegral.Box.{u1} ι)}, Iff (Disjoint.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} (Set.{u1} (ι -> Real)) (BooleanAlgebra.toGeneralizedBooleanAlgebra.{u1} (Set.{u1} (ι -> Real)) (Set.booleanAlgebra.{u1} (ι -> Real)))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.withBotCoe.{u1} ι))) I) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.withBotCoe.{u1} ι))) J)) (Disjoint.{u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (WithBot.partialOrder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (WithBot.orderBot.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) I J)
but is expected to have type
  forall {ι : Type.{u1}} {I : WithBot.{u1} (BoxIntegral.Box.{u1} ι)} {J : WithBot.{u1} (BoxIntegral.Box.{u1} ι)}, Iff (Disjoint.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.instCompleteBooleanAlgebraSet.{u1} (ι -> Real))))))) (BoundedOrder.toOrderBot.{u1} (Set.{u1} (ι -> Real)) (Preorder.toLE.{u1} (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.instCompleteBooleanAlgebraSet.{u1} (ι -> Real))))))))) (CompleteLattice.toBoundedOrder.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.instCompleteBooleanAlgebraSet.{u1} (ι -> Real))))))) (BoxIntegral.Box.withBotToSet.{u1} ι I) (BoxIntegral.Box.withBotToSet.{u1} ι J)) (Disjoint.{u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (WithBot.partialOrder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)) (WithBot.orderBot.{u1} (BoxIntegral.Box.{u1} ι) (Preorder.toLE.{u1} (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)))) I J)
Case conversion may be inaccurate. Consider using '#align box_integral.box.disjoint_with_bot_coe BoxIntegral.Box.disjoint_withBotCoeₓ'. -/
@[simp, norm_cast]
theorem disjoint_withBotCoe {I J : WithBot (Box ι)} : Disjoint (I : Set (ι → ℝ)) J ↔ Disjoint I J :=
  by
  simp only [disjoint_iff_inf_le, ← with_bot_coe_subset_iff, coe_inf]
  rfl
#align box_integral.box.disjoint_with_bot_coe BoxIntegral.Box.disjoint_withBotCoe

/- warning: box_integral.box.disjoint_coe -> BoxIntegral.Box.disjoint_coe is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι} {J : BoxIntegral.Box.{u1} ι}, Iff (Disjoint.{u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (WithBot.partialOrder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (WithBot.orderBot.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (BoxIntegral.Box.{u1} ι) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (HasLiftT.mk.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (CoeTCₓ.coe.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (WithBot.hasCoeT.{u1} (BoxIntegral.Box.{u1} ι)))) I) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (BoxIntegral.Box.{u1} ι) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (HasLiftT.mk.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (CoeTCₓ.coe.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (WithBot.hasCoeT.{u1} (BoxIntegral.Box.{u1} ι)))) J)) (Disjoint.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))) (GeneralizedBooleanAlgebra.toOrderBot.{u1} (Set.{u1} (ι -> Real)) (BooleanAlgebra.toGeneralizedBooleanAlgebra.{u1} (Set.{u1} (ι -> Real)) (Set.booleanAlgebra.{u1} (ι -> Real)))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.Set.hasCoeT.{u1} ι))) I) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.Set.hasCoeT.{u1} ι))) J))
but is expected to have type
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι} {J : BoxIntegral.Box.{u1} ι}, Iff (Disjoint.{u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (WithBot.partialOrder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)) (WithBot.orderBot.{u1} (BoxIntegral.Box.{u1} ι) (Preorder.toLE.{u1} (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)))) (WithBot.some.{u1} (BoxIntegral.Box.{u1} ι) I) (WithBot.some.{u1} (BoxIntegral.Box.{u1} ι) J)) (Disjoint.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.instCompleteBooleanAlgebraSet.{u1} (ι -> Real))))))) (BoundedOrder.toOrderBot.{u1} (Set.{u1} (ι -> Real)) (Preorder.toLE.{u1} (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.instCompleteBooleanAlgebraSet.{u1} (ι -> Real))))))))) (CompleteLattice.toBoundedOrder.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.instCompleteBooleanAlgebraSet.{u1} (ι -> Real))))))) (BoxIntegral.Box.toSet.{u1} ι I) (BoxIntegral.Box.toSet.{u1} ι J))
Case conversion may be inaccurate. Consider using '#align box_integral.box.disjoint_coe BoxIntegral.Box.disjoint_coeₓ'. -/
theorem disjoint_coe : Disjoint (I : WithBot (Box ι)) J ↔ Disjoint (I : Set (ι → ℝ)) J :=
  disjoint_withBotCoe.symm
#align box_integral.box.disjoint_coe BoxIntegral.Box.disjoint_coe

/- warning: box_integral.box.not_disjoint_coe_iff_nonempty_inter -> BoxIntegral.Box.not_disjoint_coe_iff_nonempty_inter is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι} {J : BoxIntegral.Box.{u1} ι}, Iff (Not (Disjoint.{u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (WithBot.partialOrder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (WithBot.orderBot.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (BoxIntegral.Box.{u1} ι) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (HasLiftT.mk.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (CoeTCₓ.coe.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (WithBot.hasCoeT.{u1} (BoxIntegral.Box.{u1} ι)))) I) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (BoxIntegral.Box.{u1} ι) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (HasLiftT.mk.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (CoeTCₓ.coe.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (WithBot.hasCoeT.{u1} (BoxIntegral.Box.{u1} ι)))) J))) (Set.Nonempty.{u1} (ι -> Real) (Inter.inter.{u1} (Set.{u1} (ι -> Real)) (Set.hasInter.{u1} (ι -> Real)) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.Set.hasCoeT.{u1} ι))) I) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.Set.hasCoeT.{u1} ι))) J)))
but is expected to have type
  forall {ι : Type.{u1}} {I : BoxIntegral.Box.{u1} ι} {J : BoxIntegral.Box.{u1} ι}, Iff (Not (Disjoint.{u1} (WithBot.{u1} (BoxIntegral.Box.{u1} ι)) (WithBot.partialOrder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)) (WithBot.orderBot.{u1} (BoxIntegral.Box.{u1} ι) (Preorder.toLE.{u1} (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)))) (WithBot.some.{u1} (BoxIntegral.Box.{u1} ι) I) (WithBot.some.{u1} (BoxIntegral.Box.{u1} ι) J))) (Set.Nonempty.{u1} (ι -> Real) (Inter.inter.{u1} (Set.{u1} (ι -> Real)) (Set.instInterSet.{u1} (ι -> Real)) (BoxIntegral.Box.toSet.{u1} ι I) (BoxIntegral.Box.toSet.{u1} ι J)))
Case conversion may be inaccurate. Consider using '#align box_integral.box.not_disjoint_coe_iff_nonempty_inter BoxIntegral.Box.not_disjoint_coe_iff_nonempty_interₓ'. -/
theorem not_disjoint_coe_iff_nonempty_inter :
    ¬Disjoint (I : WithBot (Box ι)) J ↔ (I ∩ J : Set (ι → ℝ)).Nonempty := by
  rw [disjoint_coe, Set.not_disjoint_iff_nonempty_inter]
#align box_integral.box.not_disjoint_coe_iff_nonempty_inter BoxIntegral.Box.not_disjoint_coe_iff_nonempty_inter

/-!
### Hyperface of a box in `ℝⁿ⁺¹ = fin (n + 1) → ℝ`
-/


#print BoxIntegral.Box.face /-
/-- Face of a box in `ℝⁿ⁺¹ = fin (n + 1) → ℝ`: the box in `ℝⁿ = fin n → ℝ` with corners at
`I.lower ∘ fin.succ_above i` and `I.upper ∘ fin.succ_above i`. -/
@[simps (config := { simpRhs := true })]
def face {n} (I : Box (Fin (n + 1))) (i : Fin (n + 1)) : Box (Fin n) :=
  ⟨I.lower ∘ Fin.succAbove i, I.upper ∘ Fin.succAbove i, fun j => I.lower_lt_upper _⟩
#align box_integral.box.face BoxIntegral.Box.face
-/

/- warning: box_integral.box.face_mk -> BoxIntegral.Box.face_mk is a dubious translation:
lean 3 declaration is
  forall {n : Nat} (l : (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real) (u : (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real) (h : forall (i : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))), LT.lt.{0} Real Real.hasLt (l i) (u i)) (i : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))), Eq.{1} (BoxIntegral.Box.{0} (Fin n)) (BoxIntegral.Box.face n (BoxIntegral.Box.mk.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) l u h) i) (BoxIntegral.Box.mk.{0} (Fin n) (Function.comp.{1, 1, 1} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) Real l (coeFn.{1, 1} (OrderEmbedding.{0, 0} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Fin.hasLe n) (Preorder.toLE.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (PartialOrder.toPreorder.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Fin.partialOrder (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))))) (fun (_x : RelEmbedding.{0, 0} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (LE.le.{0} (Fin n) (Fin.hasLe n)) (LE.le.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Preorder.toLE.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (PartialOrder.toPreorder.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Fin.partialOrder (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))))))) => (Fin n) -> (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (RelEmbedding.hasCoeToFun.{0, 0} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (LE.le.{0} (Fin n) (Fin.hasLe n)) (LE.le.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Preorder.toLE.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (PartialOrder.toPreorder.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Fin.partialOrder (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))))))) (Fin.succAbove n i))) (Function.comp.{1, 1, 1} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) Real u (coeFn.{1, 1} (OrderEmbedding.{0, 0} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Fin.hasLe n) (Preorder.toLE.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (PartialOrder.toPreorder.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Fin.partialOrder (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))))) (fun (_x : RelEmbedding.{0, 0} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (LE.le.{0} (Fin n) (Fin.hasLe n)) (LE.le.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Preorder.toLE.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (PartialOrder.toPreorder.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Fin.partialOrder (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))))))) => (Fin n) -> (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (RelEmbedding.hasCoeToFun.{0, 0} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (LE.le.{0} (Fin n) (Fin.hasLe n)) (LE.le.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Preorder.toLE.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (PartialOrder.toPreorder.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Fin.partialOrder (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))))))) (Fin.succAbove n i))) (fun (j : Fin n) => h (coeFn.{1, 1} (OrderEmbedding.{0, 0} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Fin.hasLe n) (Preorder.toLE.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (PartialOrder.toPreorder.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Fin.partialOrder (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))))) (fun (_x : RelEmbedding.{0, 0} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (LE.le.{0} (Fin n) (Fin.hasLe n)) (LE.le.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Preorder.toLE.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (PartialOrder.toPreorder.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Fin.partialOrder (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))))))) => (Fin n) -> (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (RelEmbedding.hasCoeToFun.{0, 0} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (LE.le.{0} (Fin n) (Fin.hasLe n)) (LE.le.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Preorder.toLE.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (PartialOrder.toPreorder.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (Fin.partialOrder (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))))))) (Fin.succAbove n i) j)))
but is expected to have type
  forall {n : Nat} (l : (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real) (u : (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real) (h : forall (i : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))), LT.lt.{0} Real Real.instLTReal (l i) (u i)) (i : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))), Eq.{1} (BoxIntegral.Box.{0} (Fin n)) (BoxIntegral.Box.face n (BoxIntegral.Box.mk.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) l u h) i) (BoxIntegral.Box.mk.{0} (Fin n) (Function.comp.{1, 1, 1} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) Real l (FunLike.coe.{1, 1, 1} (Function.Embedding.{1, 1} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Fin n) (fun (_x : Fin n) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : Fin n) => Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) _x) (EmbeddingLike.toFunLike.{1, 1, 1} (Function.Embedding.{1, 1} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (Function.instEmbeddingLikeEmbedding.{1, 1} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))))) (RelEmbedding.toEmbedding.{0, 0} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : Fin n) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : Fin n) => LE.le.{0} (Fin n) (instLEFin n) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) => LE.le.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (instLEFin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (Fin.succAbove n i)))) (Function.comp.{1, 1, 1} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) Real u (FunLike.coe.{1, 1, 1} (Function.Embedding.{1, 1} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Fin n) (fun (_x : Fin n) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : Fin n) => Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) _x) (EmbeddingLike.toFunLike.{1, 1, 1} (Function.Embedding.{1, 1} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (Function.instEmbeddingLikeEmbedding.{1, 1} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))))) (RelEmbedding.toEmbedding.{0, 0} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : Fin n) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : Fin n) => LE.le.{0} (Fin n) (instLEFin n) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) => LE.le.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (instLEFin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (Fin.succAbove n i)))) (fun (j : Fin n) => h (FunLike.coe.{1, 1, 1} (Function.Embedding.{1, 1} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Fin n) (fun (_x : Fin n) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : Fin n) => Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) _x) (EmbeddingLike.toFunLike.{1, 1, 1} (Function.Embedding.{1, 1} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (Function.instEmbeddingLikeEmbedding.{1, 1} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))))) (RelEmbedding.toEmbedding.{0, 0} (Fin n) (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : Fin n) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : Fin n) => LE.le.{0} (Fin n) (instLEFin n) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) => LE.le.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (instLEFin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (Fin.succAbove n i)) j)))
Case conversion may be inaccurate. Consider using '#align box_integral.box.face_mk BoxIntegral.Box.face_mkₓ'. -/
@[simp]
theorem face_mk {n} (l u : Fin (n + 1) → ℝ) (h : ∀ i, l i < u i) (i : Fin (n + 1)) :
    face ⟨l, u, h⟩ i = ⟨l ∘ Fin.succAbove i, u ∘ Fin.succAbove i, fun j => h _⟩ :=
  rfl
#align box_integral.box.face_mk BoxIntegral.Box.face_mk

#print BoxIntegral.Box.face_mono /-
@[mono]
theorem face_mono {n} {I J : Box (Fin (n + 1))} (h : I ≤ J) (i : Fin (n + 1)) :
    face I i ≤ face J i := fun x hx i =>
  Ioc_subset_Ioc ((le_iff_bounds.1 h).1 _) ((le_iff_bounds.1 h).2 _) (hx _)
#align box_integral.box.face_mono BoxIntegral.Box.face_mono
-/

/- warning: box_integral.box.monotone_face -> BoxIntegral.Box.monotone_face is a dubious translation:
lean 3 declaration is
  forall {n : Nat} (i : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))), Monotone.{0, 0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (BoxIntegral.Box.{0} (Fin n)) (PartialOrder.toPreorder.{0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (BoxIntegral.Box.partialOrder.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))))) (PartialOrder.toPreorder.{0} (BoxIntegral.Box.{0} (Fin n)) (BoxIntegral.Box.partialOrder.{0} (Fin n))) (fun (I : BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) => BoxIntegral.Box.face n I i)
but is expected to have type
  forall {n : Nat} (i : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))), Monotone.{0, 0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (BoxIntegral.Box.{0} (Fin n)) (PartialOrder.toPreorder.{0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (BoxIntegral.Box.instPartialOrderBox.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))))) (PartialOrder.toPreorder.{0} (BoxIntegral.Box.{0} (Fin n)) (BoxIntegral.Box.instPartialOrderBox.{0} (Fin n))) (fun (I : BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) => BoxIntegral.Box.face n I i)
Case conversion may be inaccurate. Consider using '#align box_integral.box.monotone_face BoxIntegral.Box.monotone_faceₓ'. -/
theorem monotone_face {n} (i : Fin (n + 1)) : Monotone fun I => face I i := fun I J h =>
  face_mono h i
#align box_integral.box.monotone_face BoxIntegral.Box.monotone_face

/- warning: box_integral.box.maps_to_insert_nth_face_Icc -> BoxIntegral.Box.mapsTo_insertNth_face_Icc is a dubious translation:
lean 3 declaration is
  forall {n : Nat} (I : BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) {i : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))} {x : Real}, (Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) x (Set.Icc.{0} Real Real.preorder (BoxIntegral.Box.lower.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) I i) (BoxIntegral.Box.upper.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) I i))) -> (Set.MapsTo.{0, 0} ((Fin n) -> Real) ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real) (Fin.insertNth.{0} n (fun {i : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))} => Real) i x) (coeFn.{1, 1} (OrderEmbedding.{0, 0} (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real)) (BoxIntegral.Box.hasLe.{0} (Fin n)) (Set.hasLe.{0} ((Fin n) -> Real))) (fun (_x : RelEmbedding.{0, 0} (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real)) (LE.le.{0} (BoxIntegral.Box.{0} (Fin n)) (BoxIntegral.Box.hasLe.{0} (Fin n))) (LE.le.{0} (Set.{0} ((Fin n) -> Real)) (Set.hasLe.{0} ((Fin n) -> Real)))) => (BoxIntegral.Box.{0} (Fin n)) -> (Set.{0} ((Fin n) -> Real))) (RelEmbedding.hasCoeToFun.{0, 0} (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real)) (LE.le.{0} (BoxIntegral.Box.{0} (Fin n)) (BoxIntegral.Box.hasLe.{0} (Fin n))) (LE.le.{0} (Set.{0} ((Fin n) -> Real)) (Set.hasLe.{0} ((Fin n) -> Real)))) (BoxIntegral.Box.Icc.{0} (Fin n)) (BoxIntegral.Box.face n I i)) (coeFn.{1, 1} (OrderEmbedding.{0, 0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real)) (BoxIntegral.Box.hasLe.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (Set.hasLe.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real))) (fun (_x : RelEmbedding.{0, 0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real)) (LE.le.{0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (BoxIntegral.Box.hasLe.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))))) (LE.le.{0} (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real)) (Set.hasLe.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real)))) => (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) -> (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real))) (RelEmbedding.hasCoeToFun.{0, 0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real)) (LE.le.{0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (BoxIntegral.Box.hasLe.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))))) (LE.le.{0} (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real)) (Set.hasLe.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real)))) (BoxIntegral.Box.Icc.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) I))
but is expected to have type
  forall {n : Nat} (I : BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) {i : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))} {x : Real}, (Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) x (Set.Icc.{0} Real Real.instPreorderReal (BoxIntegral.Box.lower.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) I i) (BoxIntegral.Box.upper.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) I i))) -> (Set.MapsTo.{0, 0} ((Fin n) -> Real) ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real) (Fin.insertNth.{0} n (fun (i : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) => Real) i x) (FunLike.coe.{1, 1, 1} (Function.Embedding.{1, 1} (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real))) (BoxIntegral.Box.{0} (Fin n)) (fun (_x : BoxIntegral.Box.{0} (Fin n)) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{0} (Fin n)) => Set.{0} ((Fin n) -> Real)) _x) (EmbeddingLike.toFunLike.{1, 1, 1} (Function.Embedding.{1, 1} (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real))) (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real)) (Function.instEmbeddingLikeEmbedding.{1, 1} (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real)))) (RelEmbedding.toEmbedding.{0, 0} (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : BoxIntegral.Box.{0} (Fin n)) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{0} (Fin n)) => LE.le.{0} (BoxIntegral.Box.{0} (Fin n)) (BoxIntegral.Box.instLEBox.{0} (Fin n)) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Set.{0} ((Fin n) -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{0} ((Fin n) -> Real)) => LE.le.{0} (Set.{0} ((Fin n) -> Real)) (Set.instLESet.{0} ((Fin n) -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (BoxIntegral.Box.Icc.{0} (Fin n))) (BoxIntegral.Box.face n I i)) (FunLike.coe.{1, 1, 1} (Function.Embedding.{1, 1} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real))) (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (fun (_x : BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) => Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)) _x) (EmbeddingLike.toFunLike.{1, 1, 1} (Function.Embedding.{1, 1} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real))) (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)) (Function.instEmbeddingLikeEmbedding.{1, 1} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)))) (RelEmbedding.toEmbedding.{0, 0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) => LE.le.{0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (BoxIntegral.Box.instLEBox.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)) => LE.le.{0} (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)) (Set.instLESet.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (BoxIntegral.Box.Icc.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))))) I))
Case conversion may be inaccurate. Consider using '#align box_integral.box.maps_to_insert_nth_face_Icc BoxIntegral.Box.mapsTo_insertNth_face_Iccₓ'. -/
theorem mapsTo_insertNth_face_Icc {n} (I : Box (Fin (n + 1))) {i : Fin (n + 1)} {x : ℝ}
    (hx : x ∈ Icc (I.lower i) (I.upper i)) : MapsTo (i.insertNth x) (I.face i).Icc I.Icc :=
  fun y hy => Fin.insertNth_mem_Icc.2 ⟨hx, hy⟩
#align box_integral.box.maps_to_insert_nth_face_Icc BoxIntegral.Box.mapsTo_insertNth_face_Icc

#print BoxIntegral.Box.mapsTo_insertNth_face /-
theorem mapsTo_insertNth_face {n} (I : Box (Fin (n + 1))) {i : Fin (n + 1)} {x : ℝ}
    (hx : x ∈ Ioc (I.lower i) (I.upper i)) : MapsTo (i.insertNth x) (I.face i) I := fun y hy => by
  simpa only [mem_coe, mem_def, i.forall_iff_succ_above, hx, Fin.insertNth_apply_same,
    Fin.insertNth_apply_succAbove, true_and_iff]
#align box_integral.box.maps_to_insert_nth_face BoxIntegral.Box.mapsTo_insertNth_face
-/

/- warning: box_integral.box.continuous_on_face_Icc -> BoxIntegral.Box.continuousOn_face_icc is a dubious translation:
lean 3 declaration is
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] {n : Nat} {f : ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real) -> X} {I : BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))}, (ContinuousOn.{0, u1} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real) X (Pi.topologicalSpace.{0, 0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) (fun (ᾰ : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) => Real) (fun (a : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) => UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) _inst_1 f (coeFn.{1, 1} (OrderEmbedding.{0, 0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real)) (BoxIntegral.Box.hasLe.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (Set.hasLe.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real))) (fun (_x : RelEmbedding.{0, 0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real)) (LE.le.{0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (BoxIntegral.Box.hasLe.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))))) (LE.le.{0} (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real)) (Set.hasLe.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real)))) => (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) -> (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real))) (RelEmbedding.hasCoeToFun.{0, 0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real)) (LE.le.{0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) (BoxIntegral.Box.hasLe.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))))) (LE.le.{0} (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real)) (Set.hasLe.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real)))) (BoxIntegral.Box.Icc.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne)))))) I)) -> (forall {i : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))} {x : Real}, (Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) x (Set.Icc.{0} Real Real.preorder (BoxIntegral.Box.lower.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) I i) (BoxIntegral.Box.upper.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) I i))) -> (ContinuousOn.{0, u1} ((Fin n) -> Real) X (Pi.topologicalSpace.{0, 0} (Fin n) (fun (j : Fin n) => Real) (fun (a : Fin n) => UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) _inst_1 (Function.comp.{1, 1, succ u1} ((Fin n) -> Real) ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) -> Real) X f (Fin.insertNth.{0} n (fun (ᾰ : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat Nat.hasAdd) n (OfNat.ofNat.{0} Nat 1 (OfNat.mk.{0} Nat 1 (One.one.{0} Nat Nat.hasOne))))) => Real) i x)) (coeFn.{1, 1} (OrderEmbedding.{0, 0} (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real)) (BoxIntegral.Box.hasLe.{0} (Fin n)) (Set.hasLe.{0} ((Fin n) -> Real))) (fun (_x : RelEmbedding.{0, 0} (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real)) (LE.le.{0} (BoxIntegral.Box.{0} (Fin n)) (BoxIntegral.Box.hasLe.{0} (Fin n))) (LE.le.{0} (Set.{0} ((Fin n) -> Real)) (Set.hasLe.{0} ((Fin n) -> Real)))) => (BoxIntegral.Box.{0} (Fin n)) -> (Set.{0} ((Fin n) -> Real))) (RelEmbedding.hasCoeToFun.{0, 0} (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real)) (LE.le.{0} (BoxIntegral.Box.{0} (Fin n)) (BoxIntegral.Box.hasLe.{0} (Fin n))) (LE.le.{0} (Set.{0} ((Fin n) -> Real)) (Set.hasLe.{0} ((Fin n) -> Real)))) (BoxIntegral.Box.Icc.{0} (Fin n)) (BoxIntegral.Box.face n I i))))
but is expected to have type
  forall {X : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} X] {n : Nat} {f : ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real) -> X} {I : BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))}, (ContinuousOn.{0, u1} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real) X (Pi.topologicalSpace.{0, 0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) (fun (ᾰ : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) => Real) (fun (a : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) => UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) _inst_1 f (FunLike.coe.{1, 1, 1} (Function.Embedding.{1, 1} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real))) (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (fun (_x : BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) => Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)) _x) (EmbeddingLike.toFunLike.{1, 1, 1} (Function.Embedding.{1, 1} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real))) (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)) (Function.instEmbeddingLikeEmbedding.{1, 1} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)))) (RelEmbedding.toEmbedding.{0, 0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) => LE.le.{0} (BoxIntegral.Box.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) (BoxIntegral.Box.instLEBox.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1))))) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)) => LE.le.{0} (Set.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)) (Set.instLESet.{0} ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (BoxIntegral.Box.Icc.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))))) I)) -> (forall {i : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))} {x : Real}, (Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) x (Set.Icc.{0} Real Real.instPreorderReal (BoxIntegral.Box.lower.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) I i) (BoxIntegral.Box.upper.{0} (Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) I i))) -> (ContinuousOn.{0, u1} ((Fin n) -> Real) X (Pi.topologicalSpace.{0, 0} (Fin n) (fun (j : Fin n) => Real) (fun (a : Fin n) => UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) _inst_1 (Function.comp.{1, 1, succ u1} ((Fin n) -> Real) ((Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) -> Real) X f (Fin.insertNth.{0} n (fun (ᾰ : Fin (HAdd.hAdd.{0, 0, 0} Nat Nat Nat (instHAdd.{0} Nat instAddNat) n (OfNat.ofNat.{0} Nat 1 (instOfNatNat 1)))) => Real) i x)) (FunLike.coe.{1, 1, 1} (Function.Embedding.{1, 1} (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real))) (BoxIntegral.Box.{0} (Fin n)) (fun (_x : BoxIntegral.Box.{0} (Fin n)) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{0} (Fin n)) => Set.{0} ((Fin n) -> Real)) _x) (EmbeddingLike.toFunLike.{1, 1, 1} (Function.Embedding.{1, 1} (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real))) (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real)) (Function.instEmbeddingLikeEmbedding.{1, 1} (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real)))) (RelEmbedding.toEmbedding.{0, 0} (BoxIntegral.Box.{0} (Fin n)) (Set.{0} ((Fin n) -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : BoxIntegral.Box.{0} (Fin n)) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{0} (Fin n)) => LE.le.{0} (BoxIntegral.Box.{0} (Fin n)) (BoxIntegral.Box.instLEBox.{0} (Fin n)) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Set.{0} ((Fin n) -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{0} ((Fin n) -> Real)) => LE.le.{0} (Set.{0} ((Fin n) -> Real)) (Set.instLESet.{0} ((Fin n) -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (BoxIntegral.Box.Icc.{0} (Fin n))) (BoxIntegral.Box.face n I i))))
Case conversion may be inaccurate. Consider using '#align box_integral.box.continuous_on_face_Icc BoxIntegral.Box.continuousOn_face_iccₓ'. -/
theorem continuousOn_face_icc {X} [TopologicalSpace X] {n} {f : (Fin (n + 1) → ℝ) → X}
    {I : Box (Fin (n + 1))} (h : ContinuousOn f I.Icc) {i : Fin (n + 1)} {x : ℝ}
    (hx : x ∈ Icc (I.lower i) (I.upper i)) : ContinuousOn (f ∘ i.insertNth x) (I.face i).Icc :=
  h.comp (continuousOn_const.fin_insertNth i continuousOn_id) (I.mapsTo_insertNth_face_Icc hx)
#align box_integral.box.continuous_on_face_Icc BoxIntegral.Box.continuousOn_face_icc

/-!
### Covering of the interior of a box by a monotone sequence of smaller boxes
-/


/- warning: box_integral.box.Ioo -> BoxIntegral.Box.Ioo is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}}, OrderHom.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))))
but is expected to have type
  forall {ι : Type.{u1}}, OrderHom.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.instCompleteBooleanAlgebraSet.{u1} (ι -> Real))))))))
Case conversion may be inaccurate. Consider using '#align box_integral.box.Ioo BoxIntegral.Box.Iooₓ'. -/
/-- The interior of a box. -/
protected def Ioo : Box ι →o Set (ι → ℝ)
    where
  toFun I := pi univ fun i => Ioo (I.lower i) (I.upper i)
  monotone' I J h :=
    pi_mono fun i hi => Ioo_subset_Ioo ((le_iff_bounds.1 h).1 i) ((le_iff_bounds.1 h).2 i)
#align box_integral.box.Ioo BoxIntegral.Box.Ioo

#print BoxIntegral.Box.ioo_subset_coe /-
theorem ioo_subset_coe (I : Box ι) : I.Ioo ⊆ I := fun x hx i => Ioo_subset_Ioc_self (hx i trivial)
#align box_integral.box.Ioo_subset_coe BoxIntegral.Box.ioo_subset_coe
-/

/- warning: box_integral.box.Ioo_subset_Icc -> BoxIntegral.Box.ioo_subset_icc is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (I : BoxIntegral.Box.{u1} ι), HasSubset.Subset.{u1} (Set.{u1} (ι -> Real)) (Set.hasSubset.{u1} (ι -> Real)) (coeFn.{succ u1, succ u1} (OrderHom.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))))) (fun (_x : OrderHom.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (OrderHom.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))))) (BoxIntegral.Box.Ioo.{u1} ι) I) (coeFn.{succ u1, succ u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.hasLe.{u1} ι) (Set.hasLe.{u1} (ι -> Real))) (fun (_x : RelEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (RelEmbedding.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) (BoxIntegral.Box.Icc.{u1} ι) I)
but is expected to have type
  forall {ι : Type.{u1}} (I : BoxIntegral.Box.{u1} ι), HasSubset.Subset.{u1} (Set.{u1} (ι -> Real)) (Set.instHasSubsetSet.{u1} (ι -> Real)) (OrderHom.toFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.instCompleteBooleanAlgebraSet.{u1} (ι -> Real)))))))) (BoxIntegral.Box.Ioo.{u1} ι) I) (FunLike.coe.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (fun (_x : BoxIntegral.Box.{u1} ι) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (Function.instEmbeddingLikeEmbedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)))) (RelEmbedding.toEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : BoxIntegral.Box.{u1} ι) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{u1} ι) => LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Set.{u1} (ι -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{u1} (ι -> Real)) => LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.instLESet.{u1} (ι -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (BoxIntegral.Box.Icc.{u1} ι)) I)
Case conversion may be inaccurate. Consider using '#align box_integral.box.Ioo_subset_Icc BoxIntegral.Box.ioo_subset_iccₓ'. -/
protected theorem ioo_subset_icc (I : Box ι) : I.Ioo ⊆ I.Icc :=
  I.ioo_subset_coe.trans coe_subset_icc
#align box_integral.box.Ioo_subset_Icc BoxIntegral.Box.ioo_subset_icc

/- warning: box_integral.box.Union_Ioo_of_tendsto -> BoxIntegral.Box.unionᵢ_ioo_of_tendsto is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Finite.{succ u1} ι] {I : BoxIntegral.Box.{u1} ι} {J : Nat -> (BoxIntegral.Box.{u1} ι)}, (Monotone.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring))) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) J) -> (Filter.Tendsto.{0, u1} Nat (ι -> Real) (Function.comp.{1, succ u1, succ u1} Nat (BoxIntegral.Box.{u1} ι) (ι -> Real) (BoxIntegral.Box.lower.{u1} ι) J) (Filter.atTop.{0} Nat (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring)))) (nhds.{u1} (ι -> Real) (Pi.topologicalSpace.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (a : ι) => UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (BoxIntegral.Box.lower.{u1} ι I))) -> (Filter.Tendsto.{0, u1} Nat (ι -> Real) (Function.comp.{1, succ u1, succ u1} Nat (BoxIntegral.Box.{u1} ι) (ι -> Real) (BoxIntegral.Box.upper.{u1} ι) J) (Filter.atTop.{0} Nat (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring)))) (nhds.{u1} (ι -> Real) (Pi.topologicalSpace.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (a : ι) => UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (BoxIntegral.Box.upper.{u1} ι I))) -> (Eq.{succ u1} (Set.{u1} (ι -> Real)) (Set.unionᵢ.{u1, 1} (ι -> Real) Nat (fun (n : Nat) => coeFn.{succ u1, succ u1} (OrderHom.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))))) (fun (_x : OrderHom.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (OrderHom.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))))) (BoxIntegral.Box.Ioo.{u1} ι) (J n))) (coeFn.{succ u1, succ u1} (OrderHom.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))))) (fun (_x : OrderHom.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (OrderHom.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))))) (BoxIntegral.Box.Ioo.{u1} ι) I))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Finite.{succ u1} ι] {I : BoxIntegral.Box.{u1} ι} {J : Nat -> (BoxIntegral.Box.{u1} ι)}, (Monotone.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (StrictOrderedSemiring.toPartialOrder.{0} Nat Nat.strictOrderedSemiring)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)) J) -> (Filter.Tendsto.{0, u1} Nat (ι -> Real) (Function.comp.{1, succ u1, succ u1} Nat (BoxIntegral.Box.{u1} ι) (ι -> Real) (BoxIntegral.Box.lower.{u1} ι) J) (Filter.atTop.{0} Nat (PartialOrder.toPreorder.{0} Nat (StrictOrderedSemiring.toPartialOrder.{0} Nat Nat.strictOrderedSemiring))) (nhds.{u1} (ι -> Real) (Pi.topologicalSpace.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (a : ι) => UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (BoxIntegral.Box.lower.{u1} ι I))) -> (Filter.Tendsto.{0, u1} Nat (ι -> Real) (Function.comp.{1, succ u1, succ u1} Nat (BoxIntegral.Box.{u1} ι) (ι -> Real) (BoxIntegral.Box.upper.{u1} ι) J) (Filter.atTop.{0} Nat (PartialOrder.toPreorder.{0} Nat (StrictOrderedSemiring.toPartialOrder.{0} Nat Nat.strictOrderedSemiring))) (nhds.{u1} (ι -> Real) (Pi.topologicalSpace.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (a : ι) => UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (BoxIntegral.Box.upper.{u1} ι I))) -> (Eq.{succ u1} (Set.{u1} (ι -> Real)) (Set.unionᵢ.{u1, 1} (ι -> Real) Nat (fun (n : Nat) => OrderHom.toFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.instCompleteBooleanAlgebraSet.{u1} (ι -> Real)))))))) (BoxIntegral.Box.Ioo.{u1} ι) (J n))) (OrderHom.toFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.instCompleteBooleanAlgebraSet.{u1} (ι -> Real)))))))) (BoxIntegral.Box.Ioo.{u1} ι) I))
Case conversion may be inaccurate. Consider using '#align box_integral.box.Union_Ioo_of_tendsto BoxIntegral.Box.unionᵢ_ioo_of_tendstoₓ'. -/
theorem unionᵢ_ioo_of_tendsto [Finite ι] {I : Box ι} {J : ℕ → Box ι} (hJ : Monotone J)
    (hl : Tendsto (lower ∘ J) atTop (𝓝 I.lower)) (hu : Tendsto (upper ∘ J) atTop (𝓝 I.upper)) :
    (⋃ n, (J n).Ioo) = I.Ioo :=
  have hl' : ∀ i, Antitone fun n => (J n).lower i := fun i =>
    (monotone_eval i).comp_antitone (antitone_lower.comp_monotone hJ)
  have hu' : ∀ i, Monotone fun n => (J n).upper i := fun i =>
    (monotone_eval i).comp (monotone_upper.comp hJ)
  calc
    (⋃ n, (J n).Ioo) = pi univ fun i => ⋃ n, Ioo ((J n).lower i) ((J n).upper i) :=
      unionᵢ_univ_pi_of_monotone fun i => (hl' i).Ioo (hu' i)
    _ = I.Ioo :=
      pi_congr rfl fun i hi =>
        unionᵢ_Ioo_of_mono_of_isGLB_of_isLUB (hl' i) (hu' i)
          (isGLB_of_tendsto_atTop (hl' i) (tendsto_pi_nhds.1 hl _))
          (isLUB_of_tendsto_atTop (hu' i) (tendsto_pi_nhds.1 hu _))
    
#align box_integral.box.Union_Ioo_of_tendsto BoxIntegral.Box.unionᵢ_ioo_of_tendsto

/- warning: box_integral.box.exists_seq_mono_tendsto -> BoxIntegral.Box.exists_seq_mono_tendsto is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (I : BoxIntegral.Box.{u1} ι), Exists.{succ u1} (OrderHom.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring))) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι))) (fun (J : OrderHom.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring))) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι))) => And (forall (n : Nat), HasSubset.Subset.{u1} (Set.{u1} (ι -> Real)) (Set.hasSubset.{u1} (ι -> Real)) (coeFn.{succ u1, succ u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.hasLe.{u1} ι) (Set.hasLe.{u1} (ι -> Real))) (fun (_x : RelEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (RelEmbedding.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) (BoxIntegral.Box.Icc.{u1} ι) (coeFn.{succ u1, succ u1} (OrderHom.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring))) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι))) (fun (_x : OrderHom.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring))) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι))) => Nat -> (BoxIntegral.Box.{u1} ι)) (OrderHom.hasCoeToFun.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring))) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι))) J n)) (coeFn.{succ u1, succ u1} (OrderHom.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))))) (fun (_x : OrderHom.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (OrderHom.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.completeBooleanAlgebra.{u1} (ι -> Real))))))))) (BoxIntegral.Box.Ioo.{u1} ι) I)) (And (Filter.Tendsto.{0, u1} Nat (ι -> Real) (Function.comp.{1, succ u1, succ u1} Nat (BoxIntegral.Box.{u1} ι) (ι -> Real) (BoxIntegral.Box.lower.{u1} ι) (coeFn.{succ u1, succ u1} (OrderHom.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring))) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι))) (fun (_x : OrderHom.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring))) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι))) => Nat -> (BoxIntegral.Box.{u1} ι)) (OrderHom.hasCoeToFun.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring))) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι))) J)) (Filter.atTop.{0} Nat (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring)))) (nhds.{u1} (ι -> Real) (Pi.topologicalSpace.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (a : ι) => UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (BoxIntegral.Box.lower.{u1} ι I))) (Filter.Tendsto.{0, u1} Nat (ι -> Real) (Function.comp.{1, succ u1, succ u1} Nat (BoxIntegral.Box.{u1} ι) (ι -> Real) (BoxIntegral.Box.upper.{u1} ι) (coeFn.{succ u1, succ u1} (OrderHom.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring))) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι))) (fun (_x : OrderHom.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring))) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι))) => Nat -> (BoxIntegral.Box.{u1} ι)) (OrderHom.hasCoeToFun.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring))) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.partialOrder.{u1} ι))) J)) (Filter.atTop.{0} Nat (PartialOrder.toPreorder.{0} Nat (OrderedCancelAddCommMonoid.toPartialOrder.{0} Nat (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} Nat Nat.strictOrderedSemiring)))) (nhds.{u1} (ι -> Real) (Pi.topologicalSpace.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (a : ι) => UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (BoxIntegral.Box.upper.{u1} ι I)))))
but is expected to have type
  forall {ι : Type.{u1}} (I : BoxIntegral.Box.{u1} ι), Exists.{succ u1} (OrderHom.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (StrictOrderedSemiring.toPartialOrder.{0} Nat Nat.strictOrderedSemiring)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι))) (fun (J : OrderHom.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (StrictOrderedSemiring.toPartialOrder.{0} Nat Nat.strictOrderedSemiring)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι))) => And (forall (n : Nat), HasSubset.Subset.{u1} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) (OrderHom.toFun.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (StrictOrderedSemiring.toPartialOrder.{0} Nat Nat.strictOrderedSemiring)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)) J n)) (Set.instHasSubsetSet.{u1} (ι -> Real)) (FunLike.coe.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (fun (_x : BoxIntegral.Box.{u1} ι) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (Function.instEmbeddingLikeEmbedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)))) (RelEmbedding.toEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : BoxIntegral.Box.{u1} ι) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{u1} ι) => LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Set.{u1} (ι -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{u1} (ι -> Real)) => LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.instLESet.{u1} (ι -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (BoxIntegral.Box.Icc.{u1} ι)) (OrderHom.toFun.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (StrictOrderedSemiring.toPartialOrder.{0} Nat Nat.strictOrderedSemiring)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)) J n)) (OrderHom.toFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)) (PartialOrder.toPreorder.{u1} (Set.{u1} (ι -> Real)) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} (ι -> Real)) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} (ι -> Real)) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} (ι -> Real)) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} (ι -> Real)) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} (ι -> Real)) (Set.instCompleteBooleanAlgebraSet.{u1} (ι -> Real)))))))) (BoxIntegral.Box.Ioo.{u1} ι) I)) (And (Filter.Tendsto.{0, u1} Nat (ι -> Real) (Function.comp.{1, succ u1, succ u1} Nat (BoxIntegral.Box.{u1} ι) (ι -> Real) (BoxIntegral.Box.lower.{u1} ι) (OrderHom.toFun.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (StrictOrderedSemiring.toPartialOrder.{0} Nat Nat.strictOrderedSemiring)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)) J)) (Filter.atTop.{0} Nat (PartialOrder.toPreorder.{0} Nat (StrictOrderedSemiring.toPartialOrder.{0} Nat Nat.strictOrderedSemiring))) (nhds.{u1} (ι -> Real) (Pi.topologicalSpace.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (a : ι) => UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (BoxIntegral.Box.lower.{u1} ι I))) (Filter.Tendsto.{0, u1} Nat (ι -> Real) (Function.comp.{1, succ u1, succ u1} Nat (BoxIntegral.Box.{u1} ι) (ι -> Real) (BoxIntegral.Box.upper.{u1} ι) (OrderHom.toFun.{0, u1} Nat (BoxIntegral.Box.{u1} ι) (PartialOrder.toPreorder.{0} Nat (StrictOrderedSemiring.toPartialOrder.{0} Nat Nat.strictOrderedSemiring)) (PartialOrder.toPreorder.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instPartialOrderBox.{u1} ι)) J)) (Filter.atTop.{0} Nat (PartialOrder.toPreorder.{0} Nat (StrictOrderedSemiring.toPartialOrder.{0} Nat Nat.strictOrderedSemiring))) (nhds.{u1} (ι -> Real) (Pi.topologicalSpace.{u1, 0} ι (fun (ᾰ : ι) => Real) (fun (a : ι) => UniformSpace.toTopologicalSpace.{0} Real (PseudoMetricSpace.toUniformSpace.{0} Real Real.pseudoMetricSpace))) (BoxIntegral.Box.upper.{u1} ι I)))))
Case conversion may be inaccurate. Consider using '#align box_integral.box.exists_seq_mono_tendsto BoxIntegral.Box.exists_seq_mono_tendstoₓ'. -/
theorem exists_seq_mono_tendsto (I : Box ι) :
    ∃ J : ℕ →o Box ι,
      (∀ n, (J n).Icc ⊆ I.Ioo) ∧
        Tendsto (lower ∘ J) atTop (𝓝 I.lower) ∧ Tendsto (upper ∘ J) atTop (𝓝 I.upper) :=
  by
  choose a b ha_anti hb_mono ha_mem hb_mem hab ha_tendsto hb_tendsto using fun i =>
    exists_seq_strictAnti_strictMono_tendsto (I.lower_lt_upper i)
  exact
    ⟨⟨fun k => ⟨flip a k, flip b k, fun i => hab _ _ _⟩, fun k l hkl =>
        le_iff_bounds.2 ⟨fun i => (ha_anti i).Antitone hkl, fun i => (hb_mono i).Monotone hkl⟩⟩,
      fun n x hx i hi => ⟨(ha_mem _ _).1.trans_le (hx.1 _), (hx.2 _).trans_lt (hb_mem _ _).2⟩,
      tendsto_pi_nhds.2 ha_tendsto, tendsto_pi_nhds.2 hb_tendsto⟩
#align box_integral.box.exists_seq_mono_tendsto BoxIntegral.Box.exists_seq_mono_tendsto

section Distortion

variable [Fintype ι]

#print BoxIntegral.Box.distortion /-
/-- The distortion of a box `I` is the maximum of the ratios of the lengths of its edges.
It is defined as the maximum of the ratios
`nndist I.lower I.upper / nndist (I.lower i) (I.upper i)`. -/
def distortion (I : Box ι) : ℝ≥0 :=
  Finset.univ.sup fun i : ι => nndist I.lower I.upper / nndist (I.lower i) (I.upper i)
#align box_integral.box.distortion BoxIntegral.Box.distortion
-/

/- warning: box_integral.box.distortion_eq_of_sub_eq_div -> BoxIntegral.Box.distortion_eq_of_sub_eq_div is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {I : BoxIntegral.Box.{u1} ι} {J : BoxIntegral.Box.{u1} ι} {r : Real}, (forall (i : ι), Eq.{1} Real (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (BoxIntegral.Box.upper.{u1} ι I i) (BoxIntegral.Box.lower.{u1} ι I i)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (DivInvMonoid.toHasDiv.{0} Real (DivisionRing.toDivInvMonoid.{0} Real Real.divisionRing))) (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (BoxIntegral.Box.upper.{u1} ι J i) (BoxIntegral.Box.lower.{u1} ι J i)) r)) -> (Eq.{1} NNReal (BoxIntegral.Box.distortion.{u1} ι _inst_1 I) (BoxIntegral.Box.distortion.{u1} ι _inst_1 J))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {I : BoxIntegral.Box.{u1} ι} {J : BoxIntegral.Box.{u1} ι} {r : Real}, (forall (i : ι), Eq.{1} Real (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) (BoxIntegral.Box.upper.{u1} ι I i) (BoxIntegral.Box.lower.{u1} ι I i)) (HDiv.hDiv.{0, 0, 0} Real Real Real (instHDiv.{0} Real (LinearOrderedField.toDiv.{0} Real Real.instLinearOrderedFieldReal)) (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) (BoxIntegral.Box.upper.{u1} ι J i) (BoxIntegral.Box.lower.{u1} ι J i)) r)) -> (Eq.{1} NNReal (BoxIntegral.Box.distortion.{u1} ι _inst_1 I) (BoxIntegral.Box.distortion.{u1} ι _inst_1 J))
Case conversion may be inaccurate. Consider using '#align box_integral.box.distortion_eq_of_sub_eq_div BoxIntegral.Box.distortion_eq_of_sub_eq_divₓ'. -/
theorem distortion_eq_of_sub_eq_div {I J : Box ι} {r : ℝ}
    (h : ∀ i, I.upper i - I.lower i = (J.upper i - J.lower i) / r) : distortion I = distortion J :=
  by
  simp only [distortion, nndist_pi_def, Real.nndist_eq', h, map_div₀]
  congr 1 with i
  have : 0 < r := by
    by_contra hr
    have := div_nonpos_of_nonneg_of_nonpos (sub_nonneg.2 <| J.lower_le_upper i) (not_lt.1 hr)
    rw [← h] at this
    exact this.not_lt (sub_pos.2 <| I.lower_lt_upper i)
  simp_rw [NNReal.finset_sup_div, div_div_div_cancel_right _ ((map_ne_zero Real.nnabs).2 this.ne')]
#align box_integral.box.distortion_eq_of_sub_eq_div BoxIntegral.Box.distortion_eq_of_sub_eq_div

/- warning: box_integral.box.nndist_le_distortion_mul -> BoxIntegral.Box.nndist_le_distortion_mul is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (I : BoxIntegral.Box.{u1} ι) (i : ι), LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (OrderedCancelAddCommMonoid.toPartialOrder.{0} NNReal (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} NNReal NNReal.strictOrderedSemiring)))) (NNDist.nndist.{u1} (ι -> Real) (PseudoMetricSpace.toNNDist.{u1} (ι -> Real) (pseudoMetricSpacePi.{u1, 0} ι (fun (ᾰ : ι) => Real) _inst_1 (fun (b : ι) => Real.pseudoMetricSpace))) (BoxIntegral.Box.lower.{u1} ι I) (BoxIntegral.Box.upper.{u1} ι I)) (HMul.hMul.{0, 0, 0} NNReal NNReal NNReal (instHMul.{0} NNReal (Distrib.toHasMul.{0} NNReal (NonUnitalNonAssocSemiring.toDistrib.{0} NNReal (NonAssocSemiring.toNonUnitalNonAssocSemiring.{0} NNReal (Semiring.toNonAssocSemiring.{0} NNReal NNReal.semiring))))) (BoxIntegral.Box.distortion.{u1} ι _inst_1 I) (NNDist.nndist.{0} Real (PseudoMetricSpace.toNNDist.{0} Real Real.pseudoMetricSpace) (BoxIntegral.Box.lower.{u1} ι I i) (BoxIntegral.Box.upper.{u1} ι I i)))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (I : BoxIntegral.Box.{u1} ι) (i : ι), LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (StrictOrderedSemiring.toPartialOrder.{0} NNReal instNNRealStrictOrderedSemiring))) (NNDist.nndist.{u1} (ι -> Real) (PseudoMetricSpace.toNNDist.{u1} (ι -> Real) (pseudoMetricSpacePi.{u1, 0} ι (fun (ᾰ : ι) => Real) _inst_1 (fun (b : ι) => Real.pseudoMetricSpace))) (BoxIntegral.Box.lower.{u1} ι I) (BoxIntegral.Box.upper.{u1} ι I)) (HMul.hMul.{0, 0, 0} NNReal NNReal NNReal (instHMul.{0} NNReal (CanonicallyOrderedCommSemiring.toMul.{0} NNReal instNNRealCanonicallyOrderedCommSemiring)) (BoxIntegral.Box.distortion.{u1} ι _inst_1 I) (NNDist.nndist.{0} Real (PseudoMetricSpace.toNNDist.{0} Real Real.pseudoMetricSpace) (BoxIntegral.Box.lower.{u1} ι I i) (BoxIntegral.Box.upper.{u1} ι I i)))
Case conversion may be inaccurate. Consider using '#align box_integral.box.nndist_le_distortion_mul BoxIntegral.Box.nndist_le_distortion_mulₓ'. -/
theorem nndist_le_distortion_mul (I : Box ι) (i : ι) :
    nndist I.lower I.upper ≤ I.distortion * nndist (I.lower i) (I.upper i) :=
  calc
    nndist I.lower I.upper =
        nndist I.lower I.upper / nndist (I.lower i) (I.upper i) * nndist (I.lower i) (I.upper i) :=
      (div_mul_cancel _ <| mt nndist_eq_zero.1 (I.lower_lt_upper i).Ne).symm
    _ ≤ I.distortion * nndist (I.lower i) (I.upper i) :=
      mul_le_mul_right' (Finset.le_sup <| Finset.mem_univ i) _
    
#align box_integral.box.nndist_le_distortion_mul BoxIntegral.Box.nndist_le_distortion_mul

/- warning: box_integral.box.dist_le_distortion_mul -> BoxIntegral.Box.dist_le_distortion_mul is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (I : BoxIntegral.Box.{u1} ι) (i : ι), LE.le.{0} Real Real.hasLe (Dist.dist.{u1} (ι -> Real) (PseudoMetricSpace.toHasDist.{u1} (ι -> Real) (pseudoMetricSpacePi.{u1, 0} ι (fun (ᾰ : ι) => Real) _inst_1 (fun (b : ι) => Real.pseudoMetricSpace))) (BoxIntegral.Box.lower.{u1} ι I) (BoxIntegral.Box.upper.{u1} ι I)) (HMul.hMul.{0, 0, 0} Real Real Real (instHMul.{0} Real Real.hasMul) ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) NNReal Real (HasLiftT.mk.{1, 1} NNReal Real (CoeTCₓ.coe.{1, 1} NNReal Real (coeBase.{1, 1} NNReal Real NNReal.Real.hasCoe))) (BoxIntegral.Box.distortion.{u1} ι _inst_1 I)) (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (BoxIntegral.Box.upper.{u1} ι I i) (BoxIntegral.Box.lower.{u1} ι I i)))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (I : BoxIntegral.Box.{u1} ι) (i : ι), LE.le.{0} Real Real.instLEReal (Dist.dist.{u1} (ι -> Real) (PseudoMetricSpace.toDist.{u1} (ι -> Real) (pseudoMetricSpacePi.{u1, 0} ι (fun (ᾰ : ι) => Real) _inst_1 (fun (b : ι) => Real.pseudoMetricSpace))) (BoxIntegral.Box.lower.{u1} ι I) (BoxIntegral.Box.upper.{u1} ι I)) (HMul.hMul.{0, 0, 0} Real Real Real (instHMul.{0} Real Real.instMulReal) (NNReal.toReal (BoxIntegral.Box.distortion.{u1} ι _inst_1 I)) (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) (BoxIntegral.Box.upper.{u1} ι I i) (BoxIntegral.Box.lower.{u1} ι I i)))
Case conversion may be inaccurate. Consider using '#align box_integral.box.dist_le_distortion_mul BoxIntegral.Box.dist_le_distortion_mulₓ'. -/
theorem dist_le_distortion_mul (I : Box ι) (i : ι) :
    dist I.lower I.upper ≤ I.distortion * (I.upper i - I.lower i) :=
  by
  have A : I.lower i - I.upper i < 0 := sub_neg.2 (I.lower_lt_upper i)
  simpa only [← NNReal.coe_le_coe, ← dist_nndist, NNReal.coe_mul, Real.dist_eq, abs_of_neg A,
    neg_sub] using I.nndist_le_distortion_mul i
#align box_integral.box.dist_le_distortion_mul BoxIntegral.Box.dist_le_distortion_mul

/- warning: box_integral.box.diam_Icc_le_of_distortion_le -> BoxIntegral.Box.diam_icc_le_of_distortion_le is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (I : BoxIntegral.Box.{u1} ι) (i : ι) {c : NNReal}, (LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (OrderedCancelAddCommMonoid.toPartialOrder.{0} NNReal (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} NNReal NNReal.strictOrderedSemiring)))) (BoxIntegral.Box.distortion.{u1} ι _inst_1 I) c) -> (LE.le.{0} Real Real.hasLe (Metric.diam.{u1} (ι -> Real) (pseudoMetricSpacePi.{u1, 0} ι (fun (ᾰ : ι) => Real) _inst_1 (fun (b : ι) => Real.pseudoMetricSpace)) (coeFn.{succ u1, succ u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.hasLe.{u1} ι) (Set.hasLe.{u1} (ι -> Real))) (fun (_x : RelEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (RelEmbedding.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) (BoxIntegral.Box.Icc.{u1} ι) I)) (HMul.hMul.{0, 0, 0} Real Real Real (instHMul.{0} Real Real.hasMul) ((fun (a : Type) (b : Type) [self : HasLiftT.{1, 1} a b] => self.0) NNReal Real (HasLiftT.mk.{1, 1} NNReal Real (CoeTCₓ.coe.{1, 1} NNReal Real (coeBase.{1, 1} NNReal Real NNReal.Real.hasCoe))) c) (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.hasSub) (BoxIntegral.Box.upper.{u1} ι I i) (BoxIntegral.Box.lower.{u1} ι I i))))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (I : BoxIntegral.Box.{u1} ι) (i : ι) {c : NNReal}, (LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (StrictOrderedSemiring.toPartialOrder.{0} NNReal instNNRealStrictOrderedSemiring))) (BoxIntegral.Box.distortion.{u1} ι _inst_1 I) c) -> (LE.le.{0} Real Real.instLEReal (Metric.diam.{u1} (ι -> Real) (pseudoMetricSpacePi.{u1, 0} ι (fun (ᾰ : ι) => Real) _inst_1 (fun (b : ι) => Real.pseudoMetricSpace)) (FunLike.coe.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (fun (_x : BoxIntegral.Box.{u1} ι) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (Function.Embedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (Function.instEmbeddingLikeEmbedding.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)))) (RelEmbedding.toEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.680 : BoxIntegral.Box.{u1} ι) (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{u1} ι) => LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) x._@.Mathlib.Order.Hom.Basic._hyg.680 x._@.Mathlib.Order.Hom.Basic._hyg.682) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.695 : Set.{u1} (ι -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{u1} (ι -> Real)) => LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.instLESet.{u1} (ι -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.695 x._@.Mathlib.Order.Hom.Basic._hyg.697) (BoxIntegral.Box.Icc.{u1} ι)) I)) (HMul.hMul.{0, 0, 0} Real Real Real (instHMul.{0} Real Real.instMulReal) (NNReal.toReal c) (HSub.hSub.{0, 0, 0} Real Real Real (instHSub.{0} Real Real.instSubReal) (BoxIntegral.Box.upper.{u1} ι I i) (BoxIntegral.Box.lower.{u1} ι I i))))
Case conversion may be inaccurate. Consider using '#align box_integral.box.diam_Icc_le_of_distortion_le BoxIntegral.Box.diam_icc_le_of_distortion_leₓ'. -/
theorem diam_icc_le_of_distortion_le (I : Box ι) (i : ι) {c : ℝ≥0} (h : I.distortion ≤ c) :
    diam I.Icc ≤ c * (I.upper i - I.lower i) :=
  have : (0 : ℝ) ≤ c * (I.upper i - I.lower i) :=
    mul_nonneg c.coe_nonneg (sub_nonneg.2 <| I.lower_le_upper _)
  diam_le_of_forall_dist_le this fun x hx y hy =>
    calc
      dist x y ≤ dist I.lower I.upper := Real.dist_le_of_mem_pi_Icc hx hy
      _ ≤ I.distortion * (I.upper i - I.lower i) := (I.dist_le_distortion_mul i)
      _ ≤ c * (I.upper i - I.lower i) :=
        mul_le_mul_of_nonneg_right h (sub_nonneg.2 (I.lower_le_upper i))
      
#align box_integral.box.diam_Icc_le_of_distortion_le BoxIntegral.Box.diam_icc_le_of_distortion_le

end Distortion

end Box

end BoxIntegral

