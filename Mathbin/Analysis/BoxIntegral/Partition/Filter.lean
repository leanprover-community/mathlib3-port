/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.box_integral.partition.filter
! leanprover-community/mathlib commit 92ca63f0fb391a9ca5f22d2409a6080e786d99f7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.BoxIntegral.Partition.SubboxInduction
import Mathbin.Analysis.BoxIntegral.Partition.Split

/-!
# Filters used in box-based integrals

First we define a structure `box_integral.integration_params`. This structure will be used as an
argument in the definition of `box_integral.integral` in order to use the same definition for a few
well-known definitions of integrals based on partitions of a rectangular box into subboxes (Riemann
integral, Henstock-Kurzweil integral, and McShane integral).

This structure holds three boolean values (see below), and encodes eight different sets of
parameters; only four of these values are used somewhere in `mathlib`. Three of them correspond to
the integration theories listed above, and one is a generalization of the one-dimensional
Henstock-Kurzweil integral such that the divergence theorem works without additional integrability
assumptions.

Finally, for each set of parameters `l : box_integral.integration_params` and a rectangular box
`I : box_integral.box ι`, we define several `filter`s that will be used either in the definition of
the corresponding integral, or in the proofs of its properties. We equip
`box_integral.integration_params` with a `bounded_order` structure such that larger
`integration_params` produce larger filters.

## Main definitions

### Integration parameters

The structure `box_integral.integration_params` has 3 boolean fields with the following meaning:

* `bRiemann`: the value `tt` means that the filter corresponds to a Riemann-style integral, i.e. in
  the definition of integrability we require a constant upper estimate `r` on the size of boxes of a
  tagged partition; the value `ff` means that the estimate may depend on the position of the tag.

* `bHenstock`: the value `tt` means that we require that each tag belongs to its own closed box; the
  value `ff` means that we only require that tags belong to the ambient box.

* `bDistortion`: the value `tt` means that `r` can depend on the maximal ratio of sides of the same
  box of a partition. Presence of this case make quite a few proofs harder but we can prove the
  divergence theorem only for the filter
  `box_integral.integration_params.GP = ⊥ = {bRiemann := ff, bHenstock := tt, bDistortion := tt}`.

### Well-known sets of parameters

Out of eight possible values of `box_integral.integration_params`, the following four are used in
the library.

* `box_integral.integration_params.Riemann` (`bRiemann = tt`, `bHenstock = tt`, `bDistortion = ff`):
  this value corresponds to the Riemann integral; in the corresponding filter, we require that the
  diameters of all boxes `J` of a tagged partition are bounded from above by a constant upper
  estimate that may not depend on the geometry of `J`, and each tag belongs to the corresponding
  closed box.

* `box_integral.integration_params.Henstock` (`bRiemann = ff`, `bHenstock = tt`,
  `bDistortion = ff`): this value corresponds to the most natural generalization of
  Henstock-Kurzweil integral to higher dimension; the only (but important!) difference between this
  theory and Riemann integral is that instead of a constant upper estimate on the size of all boxes
  of a partition, we require that the partition is *subordinate* to a possibly discontinuous
  function `r : (ι → ℝ) → {x : ℝ | 0 < x}`, i.e. each box `J` is included in a closed ball with
  center `π.tag J` and radius `r J`.

* `box_integral.integration_params.McShane` (`bRiemann = ff`, `bHenstock = ff`, `bDistortion = ff`):
  this value corresponds to the McShane integral; the only difference with the Henstock integral is
  that we allow tags to be outside of their boxes; the tags still have to be in the ambient closed
  box, and the partition still has to be subordinate to a function.

* `box_integral.integration_params.GP = ⊥` (`bRiemann = ff`, `bHenstock = tt`, `bDistortion = tt`):
  this is the least integration theory in our list, i.e., all functions integrable in any other
  theory is integrable in this one as well.  This is a non-standard generalization of the
  Henstock-Kurzweil integral to higher dimension.  In dimension one, it generates the same filter as
  `Henstock`. In higher dimension, this generalization defines an integration theory such that the
  divergence of any Fréchet differentiable function `f` is integrable, and its integral is equal to
  the sum of integrals of `f` over the faces of the box, taken with appropriate signs.

  A function `f` is `GP`-integrable if for any `ε > 0` and `c : ℝ≥0` there exists
  `r : (ι → ℝ) → {x : ℝ | 0 < x}` such that for any tagged partition `π` subordinate to `r`, if each
  tag belongs to the corresponding closed box and for each box `J ∈ π`, the maximal ratio of its
  sides is less than or equal to `c`, then the integral sum of `f` over `π` is `ε`-close to the
  integral.

### Filters and predicates on `tagged_prepartition I`

For each value of `integration_params` and a rectangular box `I`, we define a few filters on
`tagged_prepartition I`. First, we define a predicate

```
structure box_integral.integration_params.mem_base_set (l : box_integral.integration_params)
  (I : box_integral.box ι) (c : ℝ≥0) (r : (ι → ℝ) → Ioi (0 : ℝ))
  (π : box_integral.tagged_prepartition I) : Prop :=
```

This predicate says that

* if `l.bHenstock`, then `π` is a Henstock prepartition, i.e. each tag belongs to the corresponding
  closed box;
* `π` is subordinate to `r`;
* if `l.bDistortion`, then the distortion of each box in `π` is less than or equal to `c`;
* if `l.bDistortion`, then there exists a prepartition `π'` with distortion `≤ c` that covers
  exactly `I \ π.Union`.

The last condition is always true for `c > 1`, see TODO section for more details.

Then we define a predicate `box_integral.integration_params.r_cond` on functions
`r : (ι → ℝ) → {x : ℝ | 0 < x}`. If `l.bRiemann`, then this predicate requires `r` to be a constant
function, otherwise it imposes no restrictions on `r`. We introduce this definition to prove a few
dot-notation lemmas: e.g., `box_integral.integration_params.r_cond.min` says that the pointwise
minimum of two functions that satisfy this condition satisfies this condition as well.

Then we define four filters on `box_integral.tagged_prepartition I`.

* `box_integral.integration_params.to_filter_distortion`: an auxiliary filter that takes parameters
  `(l : box_integral.integration_params) (I : box_integral.box ι) (c : ℝ≥0)` and returns the
  filter generated by all sets `{π | mem_base_set l I c r π}`, where `r` is a function satisfying
  the predicate `box_integral.integration_params.r_cond l`;

* `box_integral.integration_params.to_filter l I`: the supremum of `l.to_filter_distortion I c`
  over all `c : ℝ≥0`;

* `box_integral.integration_params.to_filter_distortion_Union l I c π₀`, where `π₀` is a
  prepartition of `I`: the infimum of `l.to_filter_distortion I c` and the principal filter
  generated by `{π | π.Union = π₀.Union}`;

* `box_integral.integration_params.to_filter_Union l I π₀`: the supremum of
  `l.to_filter_distortion_Union l I c π₀` over all `c : ℝ≥0`. This is the filter (in the case
  `π₀ = ⊤` is the one-box partition of `I`) used in the definition of the integral of a function
  over a box.

## Implementation details

* Later we define the integral of a function over a rectangular box as the limit (if it exists) of
  the integral sums along `box_integral.integration_params.to_filter_Union l I ⊤`. While it is
  possible to define the integral with a general filter on `box_integral.tagged_prepartition I` as a
  parameter, many lemmas (e.g., Sacks-Henstock lemma and most results about integrability of
  functions) require the filter to have a predictable structure. So, instead of adding assumptions
  about the filter here and there, we define this auxiliary type that can encode all integration
  theories we need in practice.

* While the definition of the integral only uses the filter
  `box_integral.integration_params.to_filter_Union l I ⊤` and partitions of a box, some lemmas
  (e.g., the Henstock-Sacks lemmas) are best formulated in terms of the predicate `mem_base_set` and
  other filters defined above.

* We use `bool` instead of `Prop` for the fields of `integration_params` in order to have decidable
  equality and inequalities.

## TODO

Currently, `box_integral.integration_params.mem_base_set` explicitly requires that there exists a
partition of the complement `I \ π.Union` with distortion `≤ c`. For `c > 1`, this condition is
always true but the proof of this fact requires more API about
`box_integral.prepartition.split_many`. We should formalize this fact, then either require `c > 1`
everywhere, or replace `≤ c` with `< c` so that we automatically get `c > 1` for a non-trivial
prepartition (and consider the special case `π = ⊥` separately if needed).

## Tags

integral, rectangular box, partition, filter
-/


open Set Function Filter Metric Finset Bool

open Classical Topology Filter NNReal

noncomputable section

namespace BoxIntegral

variable {ι : Type _} [Fintype ι] {I J : Box ι} {c c₁ c₂ : ℝ≥0} {r r₁ r₂ : (ι → ℝ) → Ioi (0 : ℝ)}
  {π π₁ π₂ : TaggedPrepartition I}

open TaggedPrepartition

#print BoxIntegral.IntegrationParams /-
/-- An `integration_params` is a structure holding 3 boolean values used to define a filter to be
used in the definition of a box-integrable function.

* `bRiemann`: the value `tt` means that the filter corresponds to a Riemann-style integral, i.e. in
  the definition of integrability we require a constant upper estimate `r` on the size of boxes of a
  tagged partition; the value `ff` means that the estimate may depend on the position of the tag.

* `bHenstock`: the value `tt` means that we require that each tag belongs to its own closed box; the
  value `ff` means that we only require that tags belong to the ambient box.

* `bDistortion`: the value `tt` means that `r` can depend on the maximal ratio of sides of the same
  box of a partition. Presence of this case makes quite a few proofs harder but we can prove the
  divergence theorem only for the filter
  `box_integral.integration_params.GP = ⊥ = {bRiemann := ff, bHenstock := tt, bDistortion := tt}`.
-/
@[ext]
structure IntegrationParams : Type where
  (bRiemann bHenstock bDistortion : Bool)
#align box_integral.integration_params BoxIntegral.IntegrationParams
-/

variable {l l₁ l₂ : IntegrationParams}

namespace IntegrationParams

#print BoxIntegral.IntegrationParams.equivProd /-
/-- Auxiliary equivalence with a product type used to lift an order. -/
def equivProd : IntegrationParams ≃ Bool × Boolᵒᵈ × Boolᵒᵈ
    where
  toFun l := ⟨l.1, OrderDual.toDual l.2, OrderDual.toDual l.3⟩
  invFun l := ⟨l.1, OrderDual.ofDual l.2.1, OrderDual.ofDual l.2.2⟩
  left_inv := fun ⟨a, b, c⟩ => rfl
  right_inv := fun ⟨a, b, c⟩ => rfl
#align box_integral.integration_params.equiv_prod BoxIntegral.IntegrationParams.equivProd
-/

instance : PartialOrder IntegrationParams :=
  PartialOrder.lift equivProd equivProd.Injective

/- warning: box_integral.integration_params.iso_prod -> BoxIntegral.IntegrationParams.isoProd is a dubious translation:
lean 3 declaration is
  OrderIso.{0, 0} BoxIntegral.IntegrationParams (Prod.{0, 0} Bool (Prod.{0, 0} (OrderDual.{0} Bool) (OrderDual.{0} Bool))) (Preorder.toHasLe.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.partialOrder)) (Prod.hasLe.{0, 0} Bool (Prod.{0, 0} (OrderDual.{0} Bool) (OrderDual.{0} Bool)) (Preorder.toHasLe.{0} Bool (PartialOrder.toPreorder.{0} Bool (SemilatticeInf.toPartialOrder.{0} Bool (Lattice.toSemilatticeInf.{0} Bool (GeneralizedCoheytingAlgebra.toLattice.{0} Bool (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{0} Bool (BooleanAlgebra.toGeneralizedBooleanAlgebra.{0} Bool Bool.booleanAlgebra))))))) (Prod.hasLe.{0, 0} (OrderDual.{0} Bool) (OrderDual.{0} Bool) (OrderDual.hasLe.{0} Bool (Preorder.toHasLe.{0} Bool (PartialOrder.toPreorder.{0} Bool (SemilatticeInf.toPartialOrder.{0} Bool (Lattice.toSemilatticeInf.{0} Bool (GeneralizedCoheytingAlgebra.toLattice.{0} Bool (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{0} Bool (BooleanAlgebra.toGeneralizedBooleanAlgebra.{0} Bool Bool.booleanAlgebra)))))))) (OrderDual.hasLe.{0} Bool (Preorder.toHasLe.{0} Bool (PartialOrder.toPreorder.{0} Bool (SemilatticeInf.toPartialOrder.{0} Bool (Lattice.toSemilatticeInf.{0} Bool (GeneralizedCoheytingAlgebra.toLattice.{0} Bool (GeneralizedBooleanAlgebra.toGeneralizedCoheytingAlgebra.{0} Bool (BooleanAlgebra.toGeneralizedBooleanAlgebra.{0} Bool Bool.booleanAlgebra))))))))))
but is expected to have type
  OrderIso.{0, 0} BoxIntegral.IntegrationParams (Prod.{0, 0} Bool (Prod.{0, 0} (OrderDual.{0} Bool) (OrderDual.{0} Bool))) (Preorder.toLE.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.instPartialOrderIntegrationParams)) (Prod.instLEProd.{0, 0} Bool (Prod.{0, 0} (OrderDual.{0} Bool) (OrderDual.{0} Bool)) (Preorder.toLE.{0} Bool (PartialOrder.toPreorder.{0} Bool (SemilatticeInf.toPartialOrder.{0} Bool (Lattice.toSemilatticeInf.{0} Bool (GeneralizedCoheytingAlgebra.toLattice.{0} Bool (CoheytingAlgebra.toGeneralizedCoheytingAlgebra.{0} Bool (BiheytingAlgebra.toCoheytingAlgebra.{0} Bool (BooleanAlgebra.toBiheytingAlgebra.{0} Bool instBooleanAlgebraBool)))))))) (Prod.instLEProd.{0, 0} (OrderDual.{0} Bool) (OrderDual.{0} Bool) (OrderDual.instLEOrderDual.{0} Bool (Preorder.toLE.{0} Bool (PartialOrder.toPreorder.{0} Bool (SemilatticeInf.toPartialOrder.{0} Bool (Lattice.toSemilatticeInf.{0} Bool (GeneralizedCoheytingAlgebra.toLattice.{0} Bool (CoheytingAlgebra.toGeneralizedCoheytingAlgebra.{0} Bool (BiheytingAlgebra.toCoheytingAlgebra.{0} Bool (BooleanAlgebra.toBiheytingAlgebra.{0} Bool instBooleanAlgebraBool))))))))) (OrderDual.instLEOrderDual.{0} Bool (Preorder.toLE.{0} Bool (PartialOrder.toPreorder.{0} Bool (SemilatticeInf.toPartialOrder.{0} Bool (Lattice.toSemilatticeInf.{0} Bool (GeneralizedCoheytingAlgebra.toLattice.{0} Bool (CoheytingAlgebra.toGeneralizedCoheytingAlgebra.{0} Bool (BiheytingAlgebra.toCoheytingAlgebra.{0} Bool (BooleanAlgebra.toBiheytingAlgebra.{0} Bool instBooleanAlgebraBool)))))))))))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.iso_prod BoxIntegral.IntegrationParams.isoProdₓ'. -/
/-- Auxiliary `order_iso` with a product type used to lift a `bounded_order` structure. -/
def isoProd : IntegrationParams ≃o Bool × Boolᵒᵈ × Boolᵒᵈ :=
  ⟨equivProd, fun ⟨x, y, z⟩ => Iff.rfl⟩
#align box_integral.integration_params.iso_prod BoxIntegral.IntegrationParams.isoProd

instance : BoundedOrder IntegrationParams :=
  isoProd.symm.toGaloisInsertion.liftBoundedOrder

/-- The value
`box_integral.integration_params.GP = ⊥` (`bRiemann = ff`, `bHenstock = tt`, `bDistortion = tt`)
corresponds to a generalization of the Henstock integral such that the Divergence theorem holds true
without additional integrability assumptions, see the module docstring for details. -/
instance : Inhabited IntegrationParams :=
  ⟨⊥⟩

instance : DecidableRel ((· ≤ ·) : IntegrationParams → IntegrationParams → Prop) := fun _ _ =>
  And.decidable

instance : DecidableEq IntegrationParams := fun x y => decidable_of_iff _ (ext_iff x y).symm

#print BoxIntegral.IntegrationParams.Riemann /-
/-- The `box_integral.integration_params` corresponding to the Riemann integral. In the
corresponding filter, we require that the diameters of all boxes `J` of a tagged partition are
bounded from above by a constant upper estimate that may not depend on the geometry of `J`, and each
tag belongs to the corresponding closed box. -/
def Riemann : IntegrationParams where
  bRiemann := true
  bHenstock := true
  bDistortion := false
#align box_integral.integration_params.Riemann BoxIntegral.IntegrationParams.Riemann
-/

#print BoxIntegral.IntegrationParams.Henstock /-
/-- The `box_integral.integration_params` corresponding to the Henstock-Kurzweil integral. In the
corresponding filter, we require that the tagged partition is subordinate to a (possibly,
discontinuous) positive function `r` and each tag belongs to the corresponding closed box. -/
def Henstock : IntegrationParams :=
  ⟨false, true, false⟩
#align box_integral.integration_params.Henstock BoxIntegral.IntegrationParams.Henstock
-/

#print BoxIntegral.IntegrationParams.McShane /-
/-- The `box_integral.integration_params` corresponding to the McShane integral. In the
corresponding filter, we require that the tagged partition is subordinate to a (possibly,
discontinuous) positive function `r`; the tags may be outside of the corresponding closed box
(but still inside the ambient closed box `I.Icc`). -/
def McShane : IntegrationParams :=
  ⟨false, false, false⟩
#align box_integral.integration_params.McShane BoxIntegral.IntegrationParams.McShane
-/

#print BoxIntegral.IntegrationParams.GP /-
/-- The `box_integral.integration_params` corresponding to the generalized Perron integral. In the
corresponding filter, we require that the tagged partition is subordinate to a (possibly,
discontinuous) positive function `r` and each tag belongs to the corresponding closed box. We also
require an upper estimate on the distortion of all boxes of the partition. -/
def GP : IntegrationParams :=
  ⊥
#align box_integral.integration_params.GP BoxIntegral.IntegrationParams.GP
-/

/- warning: box_integral.integration_params.Henstock_le_Riemann -> BoxIntegral.IntegrationParams.henstock_le_riemann is a dubious translation:
lean 3 declaration is
  LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toHasLe.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.partialOrder)) BoxIntegral.IntegrationParams.Henstock BoxIntegral.IntegrationParams.Riemann
but is expected to have type
  LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toLE.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.instPartialOrderIntegrationParams)) BoxIntegral.IntegrationParams.Henstock BoxIntegral.IntegrationParams.Riemann
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.Henstock_le_Riemann BoxIntegral.IntegrationParams.henstock_le_riemannₓ'. -/
theorem henstock_le_riemann : Henstock ≤ Riemann := by decide
#align box_integral.integration_params.Henstock_le_Riemann BoxIntegral.IntegrationParams.henstock_le_riemann

/- warning: box_integral.integration_params.Henstock_le_McShane -> BoxIntegral.IntegrationParams.henstock_le_mcShane is a dubious translation:
lean 3 declaration is
  LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toHasLe.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.partialOrder)) BoxIntegral.IntegrationParams.Henstock BoxIntegral.IntegrationParams.McShane
but is expected to have type
  LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toLE.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.instPartialOrderIntegrationParams)) BoxIntegral.IntegrationParams.Henstock BoxIntegral.IntegrationParams.McShane
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.Henstock_le_McShane BoxIntegral.IntegrationParams.henstock_le_mcShaneₓ'. -/
theorem henstock_le_mcShane : Henstock ≤ McShane := by decide
#align box_integral.integration_params.Henstock_le_McShane BoxIntegral.IntegrationParams.henstock_le_mcShane

/- warning: box_integral.integration_params.GP_le -> BoxIntegral.IntegrationParams.gp_le is a dubious translation:
lean 3 declaration is
  forall {l : BoxIntegral.IntegrationParams}, LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toHasLe.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.partialOrder)) BoxIntegral.IntegrationParams.GP l
but is expected to have type
  forall {l : BoxIntegral.IntegrationParams}, LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toLE.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.instPartialOrderIntegrationParams)) BoxIntegral.IntegrationParams.GP l
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.GP_le BoxIntegral.IntegrationParams.gp_leₓ'. -/
theorem gp_le : GP ≤ l :=
  bot_le
#align box_integral.integration_params.GP_le BoxIntegral.IntegrationParams.gp_le

/- warning: box_integral.integration_params.mem_base_set -> BoxIntegral.IntegrationParams.MemBaseSet is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι], BoxIntegral.IntegrationParams -> (forall (I : BoxIntegral.Box.{u1} ι), NNReal -> ((ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) -> (BoxIntegral.TaggedPrepartition.{u1} ι I) -> Prop)
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι], BoxIntegral.IntegrationParams -> (forall (I : BoxIntegral.Box.{u1} ι), NNReal -> ((ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) -> (BoxIntegral.TaggedPrepartition.{u1} ι I) -> Prop)
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.mem_base_set BoxIntegral.IntegrationParams.MemBaseSetₓ'. -/
/-- The predicate corresponding to a base set of the filter defined by an
`integration_params`. It says that

* if `l.bHenstock`, then `π` is a Henstock prepartition, i.e. each tag belongs to the corresponding
  closed box;
* `π` is subordinate to `r`;
* if `l.bDistortion`, then the distortion of each box in `π` is less than or equal to `c`;
* if `l.bDistortion`, then there exists a prepartition `π'` with distortion `≤ c` that covers
  exactly `I \ π.Union`.

The last condition is automatically verified for partitions, and is used in the proof of the
Sacks-Henstock inequality to compare two prepartitions covering the same part of the box.

It is also automatically satisfied for any `c > 1`, see TODO section of the module docstring for
details. -/
@[protect_proj]
structure MemBaseSet (l : IntegrationParams) (I : Box ι) (c : ℝ≥0) (r : (ι → ℝ) → Ioi (0 : ℝ))
  (π : TaggedPrepartition I) : Prop where
  IsSubordinate : π.IsSubordinate r
  IsHenstock : l.bHenstock → π.IsHenstock
  distortion_le : l.bDistortion → π.distortion ≤ c
  exists_compl : l.bDistortion → ∃ π' : Prepartition I, π'.iUnion = I \ π.iUnion ∧ π'.distortion ≤ c
#align box_integral.integration_params.mem_base_set BoxIntegral.IntegrationParams.MemBaseSet

/- warning: box_integral.integration_params.r_cond -> BoxIntegral.IntegrationParams.RCond is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}}, BoxIntegral.IntegrationParams -> ((ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) -> Prop
but is expected to have type
  forall {ι : Type.{u1}}, BoxIntegral.IntegrationParams -> ((ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) -> Prop
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.r_cond BoxIntegral.IntegrationParams.RCondₓ'. -/
/-- A predicate saying that in case `l.bRiemann = tt`, the function `r` is a constant. -/
def RCond {ι : Type _} (l : IntegrationParams) (r : (ι → ℝ) → Ioi (0 : ℝ)) : Prop :=
  l.bRiemann → ∀ x, r x = r 0
#align box_integral.integration_params.r_cond BoxIntegral.IntegrationParams.RCond

#print BoxIntegral.IntegrationParams.toFilterDistortion /-
/-- A set `s : set (tagged_prepartition I)` belongs to `l.to_filter_distortion I c` if there exists
a function `r : ℝⁿ → (0, ∞)` (or a constant `r` if `l.bRiemann = tt`) such that `s` contains each
prepartition `π` such that `l.mem_base_set I c r π`. -/
def toFilterDistortion (l : IntegrationParams) (I : Box ι) (c : ℝ≥0) :
    Filter (TaggedPrepartition I) :=
  ⨅ (r : (ι → ℝ) → Ioi (0 : ℝ)) (hr : l.RCond r), 𝓟 { π | l.MemBaseSet I c r π }
#align box_integral.integration_params.to_filter_distortion BoxIntegral.IntegrationParams.toFilterDistortion
-/

#print BoxIntegral.IntegrationParams.toFilter /-
/-- A set `s : set (tagged_prepartition I)` belongs to `l.to_filter I` if for any `c : ℝ≥0` there
exists a function `r : ℝⁿ → (0, ∞)` (or a constant `r` if `l.bRiemann = tt`) such that
`s` contains each prepartition `π` such that `l.mem_base_set I c r π`. -/
def toFilter (l : IntegrationParams) (I : Box ι) : Filter (TaggedPrepartition I) :=
  ⨆ c : ℝ≥0, l.toFilterDistortion I c
#align box_integral.integration_params.to_filter BoxIntegral.IntegrationParams.toFilter
-/

#print BoxIntegral.IntegrationParams.toFilterDistortioniUnion /-
/-- A set `s : set (tagged_prepartition I)` belongs to `l.to_filter_distortion_Union I c π₀` if
there exists a function `r : ℝⁿ → (0, ∞)` (or a constant `r` if `l.bRiemann = tt`) such that `s`
contains each prepartition `π` such that `l.mem_base_set I c r π` and `π.Union = π₀.Union`. -/
def toFilterDistortioniUnion (l : IntegrationParams) (I : Box ι) (c : ℝ≥0) (π₀ : Prepartition I) :=
  l.toFilterDistortion I c ⊓ 𝓟 { π | π.iUnion = π₀.iUnion }
#align box_integral.integration_params.to_filter_distortion_Union BoxIntegral.IntegrationParams.toFilterDistortioniUnion
-/

#print BoxIntegral.IntegrationParams.toFilteriUnion /-
/-- A set `s : set (tagged_prepartition I)` belongs to `l.to_filter_Union I π₀` if for any `c : ℝ≥0`
there exists a function `r : ℝⁿ → (0, ∞)` (or a constant `r` if `l.bRiemann = tt`) such that `s`
contains each prepartition `π` such that `l.mem_base_set I c r π` and `π.Union = π₀.Union`. -/
def toFilteriUnion (l : IntegrationParams) (I : Box ι) (π₀ : Prepartition I) :=
  ⨆ c : ℝ≥0, l.toFilterDistortioniUnion I c π₀
#align box_integral.integration_params.to_filter_Union BoxIntegral.IntegrationParams.toFilteriUnion
-/

/- warning: box_integral.integration_params.r_cond_of_bRiemann_eq_ff -> BoxIntegral.IntegrationParams.rCond_of_bRiemann_eq_false is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (l : BoxIntegral.IntegrationParams), (Eq.{1} Bool (BoxIntegral.IntegrationParams.bRiemann l) Bool.false) -> (forall {r : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))}, BoxIntegral.IntegrationParams.RCond.{u1} ι l r)
but is expected to have type
  forall {ι : Type.{u1}} (l : BoxIntegral.IntegrationParams), (Eq.{1} Bool (BoxIntegral.IntegrationParams.bRiemann l) Bool.false) -> (forall {r : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))}, BoxIntegral.IntegrationParams.RCond.{u1} ι l r)
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.r_cond_of_bRiemann_eq_ff BoxIntegral.IntegrationParams.rCond_of_bRiemann_eq_falseₓ'. -/
theorem rCond_of_bRiemann_eq_false {ι} (l : IntegrationParams) (hl : l.bRiemann = false)
    {r : (ι → ℝ) → Ioi (0 : ℝ)} : l.RCond r := by simp [r_cond, hl]
#align box_integral.integration_params.r_cond_of_bRiemann_eq_ff BoxIntegral.IntegrationParams.rCond_of_bRiemann_eq_false

/- warning: box_integral.integration_params.to_filter_inf_Union_eq -> BoxIntegral.IntegrationParams.toFilter_inf_iUnion_eq is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι) (π₀ : BoxIntegral.Prepartition.{u1} ι I), Eq.{succ u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Inf.inf.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Filter.hasInf.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (BoxIntegral.IntegrationParams.toFilter.{u1} ι _inst_1 l I) (Filter.principal.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (setOf.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => Eq.{succ u1} (Set.{u1} (ι -> Real)) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π) (BoxIntegral.Prepartition.iUnion.{u1} ι I π₀))))) (BoxIntegral.IntegrationParams.toFilteriUnion.{u1} ι _inst_1 l I π₀)
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι) (π₀ : BoxIntegral.Prepartition.{u1} ι I), Eq.{succ u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Inf.inf.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Filter.instInfFilter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (BoxIntegral.IntegrationParams.toFilter.{u1} ι _inst_1 l I) (Filter.principal.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (setOf.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => Eq.{succ u1} (Set.{u1} (ι -> Real)) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π) (BoxIntegral.Prepartition.iUnion.{u1} ι I π₀))))) (BoxIntegral.IntegrationParams.toFilteriUnion.{u1} ι _inst_1 l I π₀)
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.to_filter_inf_Union_eq BoxIntegral.IntegrationParams.toFilter_inf_iUnion_eqₓ'. -/
theorem toFilter_inf_iUnion_eq (l : IntegrationParams) (I : Box ι) (π₀ : Prepartition I) :
    l.toFilter I ⊓ 𝓟 { π | π.iUnion = π₀.iUnion } = l.toFilteriUnion I π₀ :=
  (iSup_inf_principal _ _).symm
#align box_integral.integration_params.to_filter_inf_Union_eq BoxIntegral.IntegrationParams.toFilter_inf_iUnion_eq

/- warning: box_integral.integration_params.mem_base_set.mono' -> BoxIntegral.IntegrationParams.MemBaseSet.mono' is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {c₁ : NNReal} {c₂ : NNReal} {r₁ : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))} {r₂ : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))} {l₁ : BoxIntegral.IntegrationParams} {l₂ : BoxIntegral.IntegrationParams} (I : BoxIntegral.Box.{u1} ι), (LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toHasLe.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.partialOrder)) l₁ l₂) -> (LE.le.{0} NNReal (Preorder.toHasLe.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (OrderedCancelAddCommMonoid.toPartialOrder.{0} NNReal (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} NNReal NNReal.strictOrderedSemiring)))) c₁ c₂) -> (forall {π : BoxIntegral.TaggedPrepartition.{u1} ι I}, (forall (J : BoxIntegral.Box.{u1} ι), (Membership.Mem.{u1, u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.TaggedPrepartition.{u1} ι I) (BoxIntegral.TaggedPrepartition.hasMem.{u1} ι I) J π) -> (LE.le.{0} (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))))) (Subtype.hasLe.{0} Real Real.hasLe (fun (x : Real) => Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) x (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) (r₁ (BoxIntegral.TaggedPrepartition.tag.{u1} ι I π J)) (r₂ (BoxIntegral.TaggedPrepartition.tag.{u1} ι I π J)))) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l₁ I c₁ r₁ π) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l₂ I c₂ r₂ π))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {c₁ : NNReal} {c₂ : NNReal} {r₁ : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))} {r₂ : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))} {l₁ : BoxIntegral.IntegrationParams} {l₂ : BoxIntegral.IntegrationParams} (I : BoxIntegral.Box.{u1} ι), (LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toLE.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.instPartialOrderIntegrationParams)) l₁ l₂) -> (LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (StrictOrderedSemiring.toPartialOrder.{0} NNReal instNNRealStrictOrderedSemiring))) c₁ c₂) -> (forall {π : BoxIntegral.TaggedPrepartition.{u1} ι I}, (forall (J : BoxIntegral.Box.{u1} ι), (Membership.mem.{u1, u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.TaggedPrepartition.{u1} ι I) (BoxIntegral.TaggedPrepartition.instMembershipBoxTaggedPrepartition.{u1} ι I) J π) -> (LE.le.{0} (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)))) (Subtype.le.{0} Real Real.instLEReal (fun (x : Real) => Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) x (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) (r₁ (BoxIntegral.TaggedPrepartition.tag.{u1} ι I π J)) (r₂ (BoxIntegral.TaggedPrepartition.tag.{u1} ι I π J)))) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l₁ I c₁ r₁ π) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l₂ I c₂ r₂ π))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.mem_base_set.mono' BoxIntegral.IntegrationParams.MemBaseSet.mono'ₓ'. -/
theorem MemBaseSet.mono' (I : Box ι) (h : l₁ ≤ l₂) (hc : c₁ ≤ c₂) {π : TaggedPrepartition I}
    (hr : ∀ J ∈ π, r₁ (π.Tag J) ≤ r₂ (π.Tag J)) (hπ : l₁.MemBaseSet I c₁ r₁ π) :
    l₂.MemBaseSet I c₂ r₂ π :=
  ⟨hπ.1.mono' hr, fun h₂ => hπ.2 (le_iff_imp.1 h.2.1 h₂), fun hD =>
    (hπ.3 (le_iff_imp.1 h.2.2 hD)).trans hc, fun hD =>
    (hπ.4 (le_iff_imp.1 h.2.2 hD)).imp fun π hπ => ⟨hπ.1, hπ.2.trans hc⟩⟩
#align box_integral.integration_params.mem_base_set.mono' BoxIntegral.IntegrationParams.MemBaseSet.mono'

/- warning: box_integral.integration_params.mem_base_set.mono -> BoxIntegral.IntegrationParams.MemBaseSet.mono is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {c₁ : NNReal} {c₂ : NNReal} {r₁ : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))} {r₂ : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))} {l₁ : BoxIntegral.IntegrationParams} {l₂ : BoxIntegral.IntegrationParams} (I : BoxIntegral.Box.{u1} ι), (LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toHasLe.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.partialOrder)) l₁ l₂) -> (LE.le.{0} NNReal (Preorder.toHasLe.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (OrderedCancelAddCommMonoid.toPartialOrder.{0} NNReal (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} NNReal NNReal.strictOrderedSemiring)))) c₁ c₂) -> (forall {π : BoxIntegral.TaggedPrepartition.{u1} ι I}, (forall (x : ι -> Real), (Membership.Mem.{u1, u1} (ι -> Real) (Set.{u1} (ι -> Real)) (Set.hasMem.{u1} (ι -> Real)) x (coeFn.{succ u1, succ u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.hasLe.{u1} ι) (Set.hasLe.{u1} (ι -> Real))) (fun (_x : RelEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (RelEmbedding.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) (BoxIntegral.Box.Icc.{u1} ι) I)) -> (LE.le.{0} (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))))) (Subtype.hasLe.{0} Real Real.hasLe (fun (x : Real) => Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) x (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) (r₁ x) (r₂ x))) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l₁ I c₁ r₁ π) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l₂ I c₂ r₂ π))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {c₁ : NNReal} {c₂ : NNReal} {r₁ : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))} {r₂ : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))} {l₁ : BoxIntegral.IntegrationParams} {l₂ : BoxIntegral.IntegrationParams} (I : BoxIntegral.Box.{u1} ι), (LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toLE.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.instPartialOrderIntegrationParams)) l₁ l₂) -> (LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (StrictOrderedSemiring.toPartialOrder.{0} NNReal instNNRealStrictOrderedSemiring))) c₁ c₂) -> (forall {π : BoxIntegral.TaggedPrepartition.{u1} ι I}, (forall (x : ι -> Real), (Membership.mem.{u1, u1} (ι -> Real) ((fun (x._@.Mathlib.Order.RelIso.Basic._hyg.869 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) I) (Set.instMembershipSet.{u1} (ι -> Real)) x (FunLike.coe.{succ u1, succ u1, succ u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.instLEBox.{u1} ι) (Set.instLESet.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (fun (_x : BoxIntegral.Box.{u1} ι) => (fun (x._@.Mathlib.Order.RelIso.Basic._hyg.869 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) _x) (RelHomClass.toFunLike.{u1, u1, u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.instLEBox.{u1} ι) (Set.instLESet.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{u1} ι) (x._@.Mathlib.Order.Hom.Basic._hyg.684 : BoxIntegral.Box.{u1} ι) => LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) x._@.Mathlib.Order.Hom.Basic._hyg.682 x._@.Mathlib.Order.Hom.Basic._hyg.684) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{u1} (ι -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.699 : Set.{u1} (ι -> Real)) => LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.instLESet.{u1} (ι -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.697 x._@.Mathlib.Order.Hom.Basic._hyg.699) (RelEmbedding.instRelHomClassRelEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{u1} ι) (x._@.Mathlib.Order.Hom.Basic._hyg.684 : BoxIntegral.Box.{u1} ι) => LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) x._@.Mathlib.Order.Hom.Basic._hyg.682 x._@.Mathlib.Order.Hom.Basic._hyg.684) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{u1} (ι -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.699 : Set.{u1} (ι -> Real)) => LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.instLESet.{u1} (ι -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.697 x._@.Mathlib.Order.Hom.Basic._hyg.699))) (BoxIntegral.Box.Icc.{u1} ι) I)) -> (LE.le.{0} (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)))) (Subtype.le.{0} Real Real.instLEReal (fun (x : Real) => Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) x (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) (r₁ x) (r₂ x))) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l₁ I c₁ r₁ π) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l₂ I c₂ r₂ π))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.mem_base_set.mono BoxIntegral.IntegrationParams.MemBaseSet.monoₓ'. -/
@[mono]
theorem MemBaseSet.mono (I : Box ι) (h : l₁ ≤ l₂) (hc : c₁ ≤ c₂) {π : TaggedPrepartition I}
    (hr : ∀ x ∈ I.Icc, r₁ x ≤ r₂ x) (hπ : l₁.MemBaseSet I c₁ r₁ π) : l₂.MemBaseSet I c₂ r₂ π :=
  hπ.mono' I h hc fun J hJ => hr _ <| π.tag_mem_Icc J
#align box_integral.integration_params.mem_base_set.mono BoxIntegral.IntegrationParams.MemBaseSet.mono

/- warning: box_integral.integration_params.mem_base_set.exists_common_compl -> BoxIntegral.IntegrationParams.MemBaseSet.exists_common_compl is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {I : BoxIntegral.Box.{u1} ι} {c₁ : NNReal} {c₂ : NNReal} {r₁ : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))} {r₂ : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))} {π₁ : BoxIntegral.TaggedPrepartition.{u1} ι I} {π₂ : BoxIntegral.TaggedPrepartition.{u1} ι I} {l : BoxIntegral.IntegrationParams}, (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c₁ r₁ π₁) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c₂ r₂ π₂) -> (Eq.{succ u1} (Set.{u1} (ι -> Real)) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π₁) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π₂)) -> (Exists.{succ u1} (BoxIntegral.Prepartition.{u1} ι I) (fun (π : BoxIntegral.Prepartition.{u1} ι I) => And (Eq.{succ u1} (Set.{u1} (ι -> Real)) (BoxIntegral.Prepartition.iUnion.{u1} ι I π) (SDiff.sdiff.{u1} (Set.{u1} (ι -> Real)) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} (ι -> Real)) (Set.booleanAlgebra.{u1} (ι -> Real))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.Set.hasCoeT.{u1} ι))) I) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π₁))) (And ((coeSort.{1, 1} Bool Prop coeSortBool (BoxIntegral.IntegrationParams.bDistortion l)) -> (LE.le.{0} NNReal (Preorder.toHasLe.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (OrderedCancelAddCommMonoid.toPartialOrder.{0} NNReal (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} NNReal NNReal.strictOrderedSemiring)))) (BoxIntegral.Prepartition.distortion.{u1} ι I π _inst_1) c₁)) ((coeSort.{1, 1} Bool Prop coeSortBool (BoxIntegral.IntegrationParams.bDistortion l)) -> (LE.le.{0} NNReal (Preorder.toHasLe.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (OrderedCancelAddCommMonoid.toPartialOrder.{0} NNReal (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} NNReal NNReal.strictOrderedSemiring)))) (BoxIntegral.Prepartition.distortion.{u1} ι I π _inst_1) c₂)))))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {I : BoxIntegral.Box.{u1} ι} {c₁ : NNReal} {c₂ : NNReal} {r₁ : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))} {r₂ : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))} {π₁ : BoxIntegral.TaggedPrepartition.{u1} ι I} {π₂ : BoxIntegral.TaggedPrepartition.{u1} ι I} {l : BoxIntegral.IntegrationParams}, (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c₁ r₁ π₁) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c₂ r₂ π₂) -> (Eq.{succ u1} (Set.{u1} (ι -> Real)) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π₁) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π₂)) -> (Exists.{succ u1} (BoxIntegral.Prepartition.{u1} ι I) (fun (π : BoxIntegral.Prepartition.{u1} ι I) => And (Eq.{succ u1} (Set.{u1} (ι -> Real)) (BoxIntegral.Prepartition.iUnion.{u1} ι I π) (SDiff.sdiff.{u1} (Set.{u1} (ι -> Real)) (Set.instSDiffSet.{u1} (ι -> Real)) (BoxIntegral.Box.toSet.{u1} ι I) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π₁))) (And ((Eq.{1} Bool (BoxIntegral.IntegrationParams.bDistortion l) Bool.true) -> (LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (StrictOrderedSemiring.toPartialOrder.{0} NNReal instNNRealStrictOrderedSemiring))) (BoxIntegral.Prepartition.distortion.{u1} ι I π _inst_1) c₁)) ((Eq.{1} Bool (BoxIntegral.IntegrationParams.bDistortion l) Bool.true) -> (LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (StrictOrderedSemiring.toPartialOrder.{0} NNReal instNNRealStrictOrderedSemiring))) (BoxIntegral.Prepartition.distortion.{u1} ι I π _inst_1) c₂)))))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.mem_base_set.exists_common_compl BoxIntegral.IntegrationParams.MemBaseSet.exists_common_complₓ'. -/
theorem MemBaseSet.exists_common_compl (h₁ : l.MemBaseSet I c₁ r₁ π₁) (h₂ : l.MemBaseSet I c₂ r₂ π₂)
    (hU : π₁.iUnion = π₂.iUnion) :
    ∃ π : Prepartition I,
      π.iUnion = I \ π₁.iUnion ∧
        (l.bDistortion → π.distortion ≤ c₁) ∧ (l.bDistortion → π.distortion ≤ c₂) :=
  by
  wlog hc : c₁ ≤ c₂
  · simpa [hU, and_comm'] using this h₂ h₁ hU.symm (le_of_not_le hc)
  by_cases hD : (l.bDistortion : Prop)
  · rcases h₁.4 hD with ⟨π, hπU, hπc⟩
    exact ⟨π, hπU, fun _ => hπc, fun _ => hπc.trans hc⟩
  ·
    exact
      ⟨π₁.to_prepartition.compl, π₁.to_prepartition.Union_compl, fun h => (hD h).elim, fun h =>
        (hD h).elim⟩
#align box_integral.integration_params.mem_base_set.exists_common_compl BoxIntegral.IntegrationParams.MemBaseSet.exists_common_compl

/- warning: box_integral.integration_params.mem_base_set.union_compl_to_subordinate -> BoxIntegral.IntegrationParams.MemBaseSet.unionComplToSubordinate is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {I : BoxIntegral.Box.{u1} ι} {c : NNReal} {r₁ : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))} {r₂ : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))} {π₁ : BoxIntegral.TaggedPrepartition.{u1} ι I} {l : BoxIntegral.IntegrationParams}, (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r₁ π₁) -> (forall (x : ι -> Real), (Membership.Mem.{u1, u1} (ι -> Real) (Set.{u1} (ι -> Real)) (Set.hasMem.{u1} (ι -> Real)) x (coeFn.{succ u1, succ u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.hasLe.{u1} ι) (Set.hasLe.{u1} (ι -> Real))) (fun (_x : RelEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) => (BoxIntegral.Box.{u1} ι) -> (Set.{u1} (ι -> Real))) (RelEmbedding.hasCoeToFun.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.hasLe.{u1} ι)) (LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.hasLe.{u1} (ι -> Real)))) (BoxIntegral.Box.Icc.{u1} ι) I)) -> (LE.le.{0} (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))))) (Subtype.hasLe.{0} Real Real.hasLe (fun (x : Real) => Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) x (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) (r₂ x) (r₁ x))) -> (forall {π₂ : BoxIntegral.Prepartition.{u1} ι I} (hU : Eq.{succ u1} (Set.{u1} (ι -> Real)) (BoxIntegral.Prepartition.iUnion.{u1} ι I π₂) (SDiff.sdiff.{u1} (Set.{u1} (ι -> Real)) (BooleanAlgebra.toHasSdiff.{u1} (Set.{u1} (ι -> Real)) (Set.booleanAlgebra.{u1} (ι -> Real))) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (HasLiftT.mk.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (CoeTCₓ.coe.{succ u1, succ u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.Set.hasCoeT.{u1} ι))) I) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π₁))), ((coeSort.{1, 1} Bool Prop coeSortBool (BoxIntegral.IntegrationParams.bDistortion l)) -> (LE.le.{0} NNReal (Preorder.toHasLe.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (OrderedCancelAddCommMonoid.toPartialOrder.{0} NNReal (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} NNReal NNReal.strictOrderedSemiring)))) (BoxIntegral.Prepartition.distortion.{u1} ι I π₂ _inst_1) c)) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r₁ (BoxIntegral.TaggedPrepartition.unionComplToSubordinate.{u1} ι _inst_1 I π₁ π₂ hU r₂)))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {I : BoxIntegral.Box.{u1} ι} {c : NNReal} {r₁ : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))} {r₂ : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))} {π₁ : BoxIntegral.TaggedPrepartition.{u1} ι I} {l : BoxIntegral.IntegrationParams}, (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r₁ π₁) -> (forall (x : ι -> Real), (Membership.mem.{u1, u1} (ι -> Real) ((fun (x._@.Mathlib.Order.RelIso.Basic._hyg.869 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) I) (Set.instMembershipSet.{u1} (ι -> Real)) x (FunLike.coe.{succ u1, succ u1, succ u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.instLEBox.{u1} ι) (Set.instLESet.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (fun (_x : BoxIntegral.Box.{u1} ι) => (fun (x._@.Mathlib.Order.RelIso.Basic._hyg.869 : BoxIntegral.Box.{u1} ι) => Set.{u1} (ι -> Real)) _x) (RelHomClass.toFunLike.{u1, u1, u1} (OrderEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (BoxIntegral.Box.instLEBox.{u1} ι) (Set.instLESet.{u1} (ι -> Real))) (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{u1} ι) (x._@.Mathlib.Order.Hom.Basic._hyg.684 : BoxIntegral.Box.{u1} ι) => LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) x._@.Mathlib.Order.Hom.Basic._hyg.682 x._@.Mathlib.Order.Hom.Basic._hyg.684) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{u1} (ι -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.699 : Set.{u1} (ι -> Real)) => LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.instLESet.{u1} (ι -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.697 x._@.Mathlib.Order.Hom.Basic._hyg.699) (RelEmbedding.instRelHomClassRelEmbedding.{u1, u1} (BoxIntegral.Box.{u1} ι) (Set.{u1} (ι -> Real)) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.682 : BoxIntegral.Box.{u1} ι) (x._@.Mathlib.Order.Hom.Basic._hyg.684 : BoxIntegral.Box.{u1} ι) => LE.le.{u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Box.instLEBox.{u1} ι) x._@.Mathlib.Order.Hom.Basic._hyg.682 x._@.Mathlib.Order.Hom.Basic._hyg.684) (fun (x._@.Mathlib.Order.Hom.Basic._hyg.697 : Set.{u1} (ι -> Real)) (x._@.Mathlib.Order.Hom.Basic._hyg.699 : Set.{u1} (ι -> Real)) => LE.le.{u1} (Set.{u1} (ι -> Real)) (Set.instLESet.{u1} (ι -> Real)) x._@.Mathlib.Order.Hom.Basic._hyg.697 x._@.Mathlib.Order.Hom.Basic._hyg.699))) (BoxIntegral.Box.Icc.{u1} ι) I)) -> (LE.le.{0} (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)))) (Subtype.le.{0} Real Real.instLEReal (fun (x : Real) => Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) x (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) (r₂ x) (r₁ x))) -> (forall {π₂ : BoxIntegral.Prepartition.{u1} ι I} (hU : Eq.{succ u1} (Set.{u1} (ι -> Real)) (BoxIntegral.Prepartition.iUnion.{u1} ι I π₂) (SDiff.sdiff.{u1} (Set.{u1} (ι -> Real)) (Set.instSDiffSet.{u1} (ι -> Real)) (BoxIntegral.Box.toSet.{u1} ι I) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π₁))), ((Eq.{1} Bool (BoxIntegral.IntegrationParams.bDistortion l) Bool.true) -> (LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (StrictOrderedSemiring.toPartialOrder.{0} NNReal instNNRealStrictOrderedSemiring))) (BoxIntegral.Prepartition.distortion.{u1} ι I π₂ _inst_1) c)) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r₁ (BoxIntegral.TaggedPrepartition.unionComplToSubordinate.{u1} ι _inst_1 I π₁ π₂ hU r₂)))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.mem_base_set.union_compl_to_subordinate BoxIntegral.IntegrationParams.MemBaseSet.unionComplToSubordinateₓ'. -/
protected theorem MemBaseSet.unionComplToSubordinate (hπ₁ : l.MemBaseSet I c r₁ π₁)
    (hle : ∀ x ∈ I.Icc, r₂ x ≤ r₁ x) {π₂ : Prepartition I} (hU : π₂.iUnion = I \ π₁.iUnion)
    (hc : l.bDistortion → π₂.distortion ≤ c) :
    l.MemBaseSet I c r₁ (π₁.unionComplToSubordinate π₂ hU r₂) :=
  ⟨hπ₁.1.disjUnion ((π₂.isSubordinate_toSubordinate r₂).mono hle) _, fun h =>
    (hπ₁.2 h).disjUnion (π₂.isHenstock_toSubordinate _) _, fun h =>
    (distortion_unionComplToSubordinate _ _ _ _).trans_le (max_le (hπ₁.3 h) (hc h)), fun _ =>
    ⟨⊥, by simp⟩⟩
#align box_integral.integration_params.mem_base_set.union_compl_to_subordinate BoxIntegral.IntegrationParams.MemBaseSet.unionComplToSubordinate

/- warning: box_integral.integration_params.mem_base_set.filter -> BoxIntegral.IntegrationParams.MemBaseSet.filter is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {I : BoxIntegral.Box.{u1} ι} {c : NNReal} {r : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))} {π : BoxIntegral.TaggedPrepartition.{u1} ι I} {l : BoxIntegral.IntegrationParams}, (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r π) -> (forall (p : (BoxIntegral.Box.{u1} ι) -> Prop), BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r (BoxIntegral.TaggedPrepartition.filter.{u1} ι I π p))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {I : BoxIntegral.Box.{u1} ι} {c : NNReal} {r : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))} {π : BoxIntegral.TaggedPrepartition.{u1} ι I} {l : BoxIntegral.IntegrationParams}, (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r π) -> (forall (p : (BoxIntegral.Box.{u1} ι) -> Prop), BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r (BoxIntegral.TaggedPrepartition.filter.{u1} ι I π p))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.mem_base_set.filter BoxIntegral.IntegrationParams.MemBaseSet.filterₓ'. -/
protected theorem MemBaseSet.filter (hπ : l.MemBaseSet I c r π) (p : Box ι → Prop) :
    l.MemBaseSet I c r (π.filterₓ p) :=
  by
  refine'
    ⟨fun J hJ => hπ.1 J (π.mem_filter.1 hJ).1, fun hH J hJ => hπ.2 hH J (π.mem_filter.1 hJ).1,
      fun hD => (distortion_filter_le _ _).trans (hπ.3 hD), fun hD => _⟩
  rcases hπ.4 hD with ⟨π₁, hπ₁U, hc⟩
  set π₂ := π.filter fun J => ¬p J
  have : Disjoint π₁.Union π₂.Union := by
    simpa [π₂, hπ₁U] using disjoint_sdiff_self_left.mono_right sdiff_le
  refine' ⟨π₁.disj_union π₂.to_prepartition this, _, _⟩
  · suffices ↑I \ π.Union ∪ π.Union \ (π.filter p).iUnion = ↑I \ (π.filter p).iUnion by simpa [*]
    have : (π.filter p).iUnion ⊆ π.Union := bUnion_subset_bUnion_left (Finset.filter_subset _ _)
    ext x
    fconstructor
    · rintro (⟨hxI, hxπ⟩ | ⟨hxπ, hxp⟩)
      exacts[⟨hxI, mt (@this x) hxπ⟩, ⟨π.Union_subset hxπ, hxp⟩]
    · rintro ⟨hxI, hxp⟩
      by_cases hxπ : x ∈ π.Union
      exacts[Or.inr ⟨hxπ, hxp⟩, Or.inl ⟨hxI, hxπ⟩]
  · have : (π.filter fun J => ¬p J).distortion ≤ c := (distortion_filter_le _ _).trans (hπ.3 hD)
    simpa [hc]
#align box_integral.integration_params.mem_base_set.filter BoxIntegral.IntegrationParams.MemBaseSet.filter

/- warning: box_integral.integration_params.bUnion_tagged_mem_base_set -> BoxIntegral.IntegrationParams.biUnionTagged_memBaseSet is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {I : BoxIntegral.Box.{u1} ι} {c : NNReal} {r : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))} {l : BoxIntegral.IntegrationParams} {π : BoxIntegral.Prepartition.{u1} ι I} {πi : forall (J : BoxIntegral.Box.{u1} ι), BoxIntegral.TaggedPrepartition.{u1} ι J}, (forall (J : BoxIntegral.Box.{u1} ι), (Membership.Mem.{u1, u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Prepartition.{u1} ι I) (BoxIntegral.Prepartition.hasMem.{u1} ι I) J π) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l J c r (πi J))) -> (forall (J : BoxIntegral.Box.{u1} ι), (Membership.Mem.{u1, u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Prepartition.{u1} ι I) (BoxIntegral.Prepartition.hasMem.{u1} ι I) J π) -> (BoxIntegral.TaggedPrepartition.IsPartition.{u1} ι J (πi J))) -> ((coeSort.{1, 1} Bool Prop coeSortBool (BoxIntegral.IntegrationParams.bDistortion l)) -> (LE.le.{0} NNReal (Preorder.toHasLe.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (OrderedCancelAddCommMonoid.toPartialOrder.{0} NNReal (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} NNReal NNReal.strictOrderedSemiring)))) (BoxIntegral.Prepartition.distortion.{u1} ι I (BoxIntegral.Prepartition.compl.{u1} ι I (Finite.of_fintype.{u1} ι _inst_1) π) _inst_1) c)) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r (BoxIntegral.Prepartition.biUnionTagged.{u1} ι I π πi))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {I : BoxIntegral.Box.{u1} ι} {c : NNReal} {r : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))} {l : BoxIntegral.IntegrationParams} {π : BoxIntegral.Prepartition.{u1} ι I} {πi : forall (J : BoxIntegral.Box.{u1} ι), BoxIntegral.TaggedPrepartition.{u1} ι J}, (forall (J : BoxIntegral.Box.{u1} ι), (Membership.mem.{u1, u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Prepartition.{u1} ι I) (BoxIntegral.Prepartition.instMembershipBoxPrepartition.{u1} ι I) J π) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l J c r (πi J))) -> (forall (J : BoxIntegral.Box.{u1} ι), (Membership.mem.{u1, u1} (BoxIntegral.Box.{u1} ι) (BoxIntegral.Prepartition.{u1} ι I) (BoxIntegral.Prepartition.instMembershipBoxPrepartition.{u1} ι I) J π) -> (BoxIntegral.TaggedPrepartition.IsPartition.{u1} ι J (πi J))) -> ((Eq.{1} Bool (BoxIntegral.IntegrationParams.bDistortion l) Bool.true) -> (LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (StrictOrderedSemiring.toPartialOrder.{0} NNReal instNNRealStrictOrderedSemiring))) (BoxIntegral.Prepartition.distortion.{u1} ι I (BoxIntegral.Prepartition.compl.{u1} ι I (Finite.of_fintype.{u1} ι _inst_1) π) _inst_1) c)) -> (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r (BoxIntegral.Prepartition.biUnionTagged.{u1} ι I π πi))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.bUnion_tagged_mem_base_set BoxIntegral.IntegrationParams.biUnionTagged_memBaseSetₓ'. -/
theorem biUnionTagged_memBaseSet {π : Prepartition I} {πi : ∀ J, TaggedPrepartition J}
    (h : ∀ J ∈ π, l.MemBaseSet J c r (πi J)) (hp : ∀ J ∈ π, (πi J).IsPartition)
    (hc : l.bDistortion → π.compl.distortion ≤ c) : l.MemBaseSet I c r (π.biUnionTagged πi) :=
  by
  refine'
    ⟨tagged_prepartition.is_subordinate_bUnion_tagged.2 fun J hJ => (h J hJ).1, fun hH =>
      tagged_prepartition.is_Henstock_bUnion_tagged.2 fun J hJ => (h J hJ).2 hH, fun hD => _,
      fun hD => _⟩
  · rw [prepartition.distortion_bUnion_tagged, Finset.sup_le_iff]
    exact fun J hJ => (h J hJ).3 hD
  · refine' ⟨_, _, hc hD⟩
    rw [π.Union_compl, ← π.Union_bUnion_partition hp]
    rfl
#align box_integral.integration_params.bUnion_tagged_mem_base_set BoxIntegral.IntegrationParams.biUnionTagged_memBaseSet

/- warning: box_integral.integration_params.r_cond.mono -> BoxIntegral.IntegrationParams.RCond.mono is a dubious translation:
lean 3 declaration is
  forall {l₁ : BoxIntegral.IntegrationParams} {l₂ : BoxIntegral.IntegrationParams} {ι : Type.{u1}} {r : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))}, (LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toHasLe.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.partialOrder)) l₁ l₂) -> (BoxIntegral.IntegrationParams.RCond.{u1} ι l₂ r) -> (BoxIntegral.IntegrationParams.RCond.{u1} ι l₁ r)
but is expected to have type
  forall {l₁ : BoxIntegral.IntegrationParams} {l₂ : BoxIntegral.IntegrationParams} {ι : Type.{u1}} {r : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))}, (LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toLE.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.instPartialOrderIntegrationParams)) l₁ l₂) -> (BoxIntegral.IntegrationParams.RCond.{u1} ι l₂ r) -> (BoxIntegral.IntegrationParams.RCond.{u1} ι l₁ r)
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.r_cond.mono BoxIntegral.IntegrationParams.RCond.monoₓ'. -/
@[mono]
theorem RCond.mono {ι : Type _} {r : (ι → ℝ) → Ioi (0 : ℝ)} (h : l₁ ≤ l₂) (hr : l₂.RCond r) :
    l₁.RCond r := fun hR => hr (le_iff_imp.1 h.1 hR)
#align box_integral.integration_params.r_cond.mono BoxIntegral.IntegrationParams.RCond.mono

/- warning: box_integral.integration_params.r_cond.min -> BoxIntegral.IntegrationParams.RCond.min is a dubious translation:
lean 3 declaration is
  forall {l : BoxIntegral.IntegrationParams} {ι : Type.{u1}} {r₁ : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))} {r₂ : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))}, (BoxIntegral.IntegrationParams.RCond.{u1} ι l r₁) -> (BoxIntegral.IntegrationParams.RCond.{u1} ι l r₂) -> (BoxIntegral.IntegrationParams.RCond.{u1} ι l (fun (x : ι -> Real) => LinearOrder.min.{0} (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero))))) (Subtype.linearOrder.{0} Real Real.linearOrder (fun (x : Real) => Membership.Mem.{0, 0} Real (Set.{0} Real) (Set.hasMem.{0} Real) x (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) (r₁ x) (r₂ x)))
but is expected to have type
  forall {l : BoxIntegral.IntegrationParams} {ι : Type.{u1}} {r₁ : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))} {r₂ : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))}, (BoxIntegral.IntegrationParams.RCond.{u1} ι l r₁) -> (BoxIntegral.IntegrationParams.RCond.{u1} ι l r₂) -> (BoxIntegral.IntegrationParams.RCond.{u1} ι l (fun (x : ι -> Real) => Min.min.{0} (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)))) (LinearOrder.toMin.{0} (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)))) (Subtype.linearOrder.{0} Real Real.linearOrder (fun (x : Real) => Membership.mem.{0, 0} Real (Set.{0} Real) (Set.instMembershipSet.{0} Real) x (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal)))))) (r₁ x) (r₂ x)))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.r_cond.min BoxIntegral.IntegrationParams.RCond.minₓ'. -/
theorem RCond.min {ι : Type _} {r₁ r₂ : (ι → ℝ) → Ioi (0 : ℝ)} (h₁ : l.RCond r₁) (h₂ : l.RCond r₂) :
    l.RCond fun x => min (r₁ x) (r₂ x) := fun hR x => congr_arg₂ min (h₁ hR x) (h₂ hR x)
#align box_integral.integration_params.r_cond.min BoxIntegral.IntegrationParams.RCond.min

/- warning: box_integral.integration_params.to_filter_distortion_mono -> BoxIntegral.IntegrationParams.toFilterDistortion_mono is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {c₁ : NNReal} {c₂ : NNReal} {l₁ : BoxIntegral.IntegrationParams} {l₂ : BoxIntegral.IntegrationParams} (I : BoxIntegral.Box.{u1} ι), (LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toHasLe.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.partialOrder)) l₁ l₂) -> (LE.le.{0} NNReal (Preorder.toHasLe.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (OrderedCancelAddCommMonoid.toPartialOrder.{0} NNReal (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} NNReal NNReal.strictOrderedSemiring)))) c₁ c₂) -> (LE.le.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Preorder.toHasLe.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (PartialOrder.toPreorder.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Filter.partialOrder.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)))) (BoxIntegral.IntegrationParams.toFilterDistortion.{u1} ι _inst_1 l₁ I c₁) (BoxIntegral.IntegrationParams.toFilterDistortion.{u1} ι _inst_1 l₂ I c₂))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {c₁ : NNReal} {c₂ : NNReal} {l₁ : BoxIntegral.IntegrationParams} {l₂ : BoxIntegral.IntegrationParams} (I : BoxIntegral.Box.{u1} ι), (LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toLE.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.instPartialOrderIntegrationParams)) l₁ l₂) -> (LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (StrictOrderedSemiring.toPartialOrder.{0} NNReal instNNRealStrictOrderedSemiring))) c₁ c₂) -> (LE.le.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Preorder.toLE.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (PartialOrder.toPreorder.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Filter.instPartialOrderFilter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)))) (BoxIntegral.IntegrationParams.toFilterDistortion.{u1} ι _inst_1 l₁ I c₁) (BoxIntegral.IntegrationParams.toFilterDistortion.{u1} ι _inst_1 l₂ I c₂))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.to_filter_distortion_mono BoxIntegral.IntegrationParams.toFilterDistortion_monoₓ'. -/
@[mono]
theorem toFilterDistortion_mono (I : Box ι) (h : l₁ ≤ l₂) (hc : c₁ ≤ c₂) :
    l₁.toFilterDistortion I c₁ ≤ l₂.toFilterDistortion I c₂ :=
  iInf_mono fun r =>
    iInf_mono' fun hr =>
      ⟨hr.mono h, principal_mono.2 fun _ => MemBaseSet.mono I h hc fun _ _ => le_rfl⟩
#align box_integral.integration_params.to_filter_distortion_mono BoxIntegral.IntegrationParams.toFilterDistortion_mono

/- warning: box_integral.integration_params.to_filter_mono -> BoxIntegral.IntegrationParams.toFilter_mono is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (I : BoxIntegral.Box.{u1} ι) {l₁ : BoxIntegral.IntegrationParams} {l₂ : BoxIntegral.IntegrationParams}, (LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toHasLe.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.partialOrder)) l₁ l₂) -> (LE.le.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Preorder.toHasLe.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (PartialOrder.toPreorder.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Filter.partialOrder.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)))) (BoxIntegral.IntegrationParams.toFilter.{u1} ι _inst_1 l₁ I) (BoxIntegral.IntegrationParams.toFilter.{u1} ι _inst_1 l₂ I))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (I : BoxIntegral.Box.{u1} ι) {l₁ : BoxIntegral.IntegrationParams} {l₂ : BoxIntegral.IntegrationParams}, (LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toLE.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.instPartialOrderIntegrationParams)) l₁ l₂) -> (LE.le.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Preorder.toLE.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (PartialOrder.toPreorder.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Filter.instPartialOrderFilter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)))) (BoxIntegral.IntegrationParams.toFilter.{u1} ι _inst_1 l₁ I) (BoxIntegral.IntegrationParams.toFilter.{u1} ι _inst_1 l₂ I))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.to_filter_mono BoxIntegral.IntegrationParams.toFilter_monoₓ'. -/
@[mono]
theorem toFilter_mono (I : Box ι) {l₁ l₂ : IntegrationParams} (h : l₁ ≤ l₂) :
    l₁.toFilter I ≤ l₂.toFilter I :=
  iSup_mono fun c => toFilterDistortion_mono I h le_rfl
#align box_integral.integration_params.to_filter_mono BoxIntegral.IntegrationParams.toFilter_mono

/- warning: box_integral.integration_params.to_filter_Union_mono -> BoxIntegral.IntegrationParams.toFilteriUnion_mono is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (I : BoxIntegral.Box.{u1} ι) {l₁ : BoxIntegral.IntegrationParams} {l₂ : BoxIntegral.IntegrationParams}, (LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toHasLe.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.partialOrder)) l₁ l₂) -> (forall (π₀ : BoxIntegral.Prepartition.{u1} ι I), LE.le.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Preorder.toHasLe.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (PartialOrder.toPreorder.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Filter.partialOrder.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)))) (BoxIntegral.IntegrationParams.toFilteriUnion.{u1} ι _inst_1 l₁ I π₀) (BoxIntegral.IntegrationParams.toFilteriUnion.{u1} ι _inst_1 l₂ I π₀))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (I : BoxIntegral.Box.{u1} ι) {l₁ : BoxIntegral.IntegrationParams} {l₂ : BoxIntegral.IntegrationParams}, (LE.le.{0} BoxIntegral.IntegrationParams (Preorder.toLE.{0} BoxIntegral.IntegrationParams (PartialOrder.toPreorder.{0} BoxIntegral.IntegrationParams BoxIntegral.IntegrationParams.instPartialOrderIntegrationParams)) l₁ l₂) -> (forall (π₀ : BoxIntegral.Prepartition.{u1} ι I), LE.le.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Preorder.toLE.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (PartialOrder.toPreorder.{u1} (Filter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)) (Filter.instPartialOrderFilter.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I)))) (BoxIntegral.IntegrationParams.toFilteriUnion.{u1} ι _inst_1 l₁ I π₀) (BoxIntegral.IntegrationParams.toFilteriUnion.{u1} ι _inst_1 l₂ I π₀))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.to_filter_Union_mono BoxIntegral.IntegrationParams.toFilteriUnion_monoₓ'. -/
@[mono]
theorem toFilteriUnion_mono (I : Box ι) {l₁ l₂ : IntegrationParams} (h : l₁ ≤ l₂)
    (π₀ : Prepartition I) : l₁.toFilteriUnion I π₀ ≤ l₂.toFilteriUnion I π₀ :=
  iSup_mono fun c => inf_le_inf_right _ <| toFilterDistortion_mono _ h le_rfl
#align box_integral.integration_params.to_filter_Union_mono BoxIntegral.IntegrationParams.toFilteriUnion_mono

#print BoxIntegral.IntegrationParams.toFilteriUnion_congr /-
theorem toFilteriUnion_congr (I : Box ι) (l : IntegrationParams) {π₁ π₂ : Prepartition I}
    (h : π₁.iUnion = π₂.iUnion) : l.toFilteriUnion I π₁ = l.toFilteriUnion I π₂ := by
  simp only [to_filter_Union, to_filter_distortion_Union, h]
#align box_integral.integration_params.to_filter_Union_congr BoxIntegral.IntegrationParams.toFilteriUnion_congr
-/

/- warning: box_integral.integration_params.has_basis_to_filter_distortion -> BoxIntegral.IntegrationParams.hasBasis_toFilterDistortion is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι) (c : NNReal), Filter.HasBasis.{u1, succ u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) ((ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) (BoxIntegral.IntegrationParams.toFilterDistortion.{u1} ι _inst_1 l I c) (BoxIntegral.IntegrationParams.RCond.{u1} ι l) (fun (r : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) => setOf.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r π))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι) (c : NNReal), Filter.HasBasis.{u1, succ u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) ((ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) (BoxIntegral.IntegrationParams.toFilterDistortion.{u1} ι _inst_1 l I c) (BoxIntegral.IntegrationParams.RCond.{u1} ι l) (fun (r : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) => setOf.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r π))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.has_basis_to_filter_distortion BoxIntegral.IntegrationParams.hasBasis_toFilterDistortionₓ'. -/
theorem hasBasis_toFilterDistortion (l : IntegrationParams) (I : Box ι) (c : ℝ≥0) :
    (l.toFilterDistortion I c).HasBasis l.RCond fun r => { π | l.MemBaseSet I c r π } :=
  hasBasis_biInf_principal'
    (fun r₁ hr₁ r₂ hr₂ =>
      ⟨_, hr₁.min hr₂, fun _ => MemBaseSet.mono _ le_rfl le_rfl fun x hx => min_le_left _ _,
        fun _ => MemBaseSet.mono _ le_rfl le_rfl fun x hx => min_le_right _ _⟩)
    ⟨fun _ => ⟨1, zero_lt_one⟩, fun _ _ => rfl⟩
#align box_integral.integration_params.has_basis_to_filter_distortion BoxIntegral.IntegrationParams.hasBasis_toFilterDistortion

/- warning: box_integral.integration_params.has_basis_to_filter_distortion_Union -> BoxIntegral.IntegrationParams.hasBasis_toFilterDistortioniUnion is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι) (c : NNReal) (π₀ : BoxIntegral.Prepartition.{u1} ι I), Filter.HasBasis.{u1, succ u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) ((ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) (BoxIntegral.IntegrationParams.toFilterDistortioniUnion.{u1} ι _inst_1 l I c π₀) (BoxIntegral.IntegrationParams.RCond.{u1} ι l) (fun (r : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) => setOf.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => And (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r π) (Eq.{succ u1} (Set.{u1} (ι -> Real)) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π) (BoxIntegral.Prepartition.iUnion.{u1} ι I π₀))))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι) (c : NNReal) (π₀ : BoxIntegral.Prepartition.{u1} ι I), Filter.HasBasis.{u1, succ u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) ((ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) (BoxIntegral.IntegrationParams.toFilterDistortioniUnion.{u1} ι _inst_1 l I c π₀) (BoxIntegral.IntegrationParams.RCond.{u1} ι l) (fun (r : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) => setOf.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => And (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r π) (Eq.{succ u1} (Set.{u1} (ι -> Real)) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π) (BoxIntegral.Prepartition.iUnion.{u1} ι I π₀))))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.has_basis_to_filter_distortion_Union BoxIntegral.IntegrationParams.hasBasis_toFilterDistortioniUnionₓ'. -/
theorem hasBasis_toFilterDistortioniUnion (l : IntegrationParams) (I : Box ι) (c : ℝ≥0)
    (π₀ : Prepartition I) :
    (l.toFilterDistortioniUnion I c π₀).HasBasis l.RCond fun r =>
      { π | l.MemBaseSet I c r π ∧ π.iUnion = π₀.iUnion } :=
  (l.hasBasis_toFilterDistortion I c).inf_principal _
#align box_integral.integration_params.has_basis_to_filter_distortion_Union BoxIntegral.IntegrationParams.hasBasis_toFilterDistortioniUnion

/- warning: box_integral.integration_params.has_basis_to_filter_Union -> BoxIntegral.IntegrationParams.hasBasis_toFilteriUnion is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι) (π₀ : BoxIntegral.Prepartition.{u1} ι I), Filter.HasBasis.{u1, succ u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (NNReal -> (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) (BoxIntegral.IntegrationParams.toFilteriUnion.{u1} ι _inst_1 l I π₀) (fun (r : NNReal -> (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) => forall (c : NNReal), BoxIntegral.IntegrationParams.RCond.{u1} ι l (r c)) (fun (r : NNReal -> (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) => setOf.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => Exists.{1} NNReal (fun (c : NNReal) => And (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c (r c) π) (Eq.{succ u1} (Set.{u1} (ι -> Real)) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π) (BoxIntegral.Prepartition.iUnion.{u1} ι I π₀)))))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι) (π₀ : BoxIntegral.Prepartition.{u1} ι I), Filter.HasBasis.{u1, succ u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (NNReal -> (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) (BoxIntegral.IntegrationParams.toFilteriUnion.{u1} ι _inst_1 l I π₀) (fun (r : NNReal -> (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) => forall (c : NNReal), BoxIntegral.IntegrationParams.RCond.{u1} ι l (r c)) (fun (r : NNReal -> (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) => setOf.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => Exists.{1} NNReal (fun (c : NNReal) => And (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c (r c) π) (Eq.{succ u1} (Set.{u1} (ι -> Real)) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π) (BoxIntegral.Prepartition.iUnion.{u1} ι I π₀)))))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.has_basis_to_filter_Union BoxIntegral.IntegrationParams.hasBasis_toFilteriUnionₓ'. -/
theorem hasBasis_toFilteriUnion (l : IntegrationParams) (I : Box ι) (π₀ : Prepartition I) :
    (l.toFilteriUnion I π₀).HasBasis (fun r : ℝ≥0 → (ι → ℝ) → Ioi (0 : ℝ) => ∀ c, l.RCond (r c))
      fun r => { π | ∃ c, l.MemBaseSet I c (r c) π ∧ π.iUnion = π₀.iUnion } :=
  by
  have := fun c => l.hasBasis_toFilterDistortioniUnion I c π₀
  simpa only [set_of_and, set_of_exists] using has_basis_supr this
#align box_integral.integration_params.has_basis_to_filter_Union BoxIntegral.IntegrationParams.hasBasis_toFilteriUnion

/- warning: box_integral.integration_params.has_basis_to_filter_Union_top -> BoxIntegral.IntegrationParams.hasBasis_toFilteriUnion_top is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι), Filter.HasBasis.{u1, succ u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (NNReal -> (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) (BoxIntegral.IntegrationParams.toFilteriUnion.{u1} ι _inst_1 l I (Top.top.{u1} (BoxIntegral.Prepartition.{u1} ι I) (OrderTop.toHasTop.{u1} (BoxIntegral.Prepartition.{u1} ι I) (BoxIntegral.Prepartition.hasLe.{u1} ι I) (BoxIntegral.Prepartition.orderTop.{u1} ι I)))) (fun (r : NNReal -> (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) => forall (c : NNReal), BoxIntegral.IntegrationParams.RCond.{u1} ι l (r c)) (fun (r : NNReal -> (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) => setOf.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => Exists.{1} NNReal (fun (c : NNReal) => And (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c (r c) π) (BoxIntegral.TaggedPrepartition.IsPartition.{u1} ι I π))))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι), Filter.HasBasis.{u1, succ u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (NNReal -> (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) (BoxIntegral.IntegrationParams.toFilteriUnion.{u1} ι _inst_1 l I (Top.top.{u1} (BoxIntegral.Prepartition.{u1} ι I) (OrderTop.toTop.{u1} (BoxIntegral.Prepartition.{u1} ι I) (BoxIntegral.Prepartition.instLEPrepartition.{u1} ι I) (BoxIntegral.Prepartition.instOrderTopPrepartitionInstLEPrepartition.{u1} ι I)))) (fun (r : NNReal -> (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) => forall (c : NNReal), BoxIntegral.IntegrationParams.RCond.{u1} ι l (r c)) (fun (r : NNReal -> (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) => setOf.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => Exists.{1} NNReal (fun (c : NNReal) => And (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c (r c) π) (BoxIntegral.TaggedPrepartition.IsPartition.{u1} ι I π))))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.has_basis_to_filter_Union_top BoxIntegral.IntegrationParams.hasBasis_toFilteriUnion_topₓ'. -/
theorem hasBasis_toFilteriUnion_top (l : IntegrationParams) (I : Box ι) :
    (l.toFilteriUnion I ⊤).HasBasis (fun r : ℝ≥0 → (ι → ℝ) → Ioi (0 : ℝ) => ∀ c, l.RCond (r c))
      fun r => { π | ∃ c, l.MemBaseSet I c (r c) π ∧ π.IsPartition } :=
  by
  simpa only [tagged_prepartition.is_partition_iff_Union_eq, prepartition.Union_top] using
    l.has_basis_to_filter_Union I ⊤
#align box_integral.integration_params.has_basis_to_filter_Union_top BoxIntegral.IntegrationParams.hasBasis_toFilteriUnion_top

/- warning: box_integral.integration_params.has_basis_to_filter -> BoxIntegral.IntegrationParams.hasBasis_toFilter is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι), Filter.HasBasis.{u1, succ u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (NNReal -> (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) (BoxIntegral.IntegrationParams.toFilter.{u1} ι _inst_1 l I) (fun (r : NNReal -> (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) => forall (c : NNReal), BoxIntegral.IntegrationParams.RCond.{u1} ι l (r c)) (fun (r : NNReal -> (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))) => setOf.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => Exists.{1} NNReal (fun (c : NNReal) => BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c (r c) π)))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι), Filter.HasBasis.{u1, succ u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (NNReal -> (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) (BoxIntegral.IntegrationParams.toFilter.{u1} ι _inst_1 l I) (fun (r : NNReal -> (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) => forall (c : NNReal), BoxIntegral.IntegrationParams.RCond.{u1} ι l (r c)) (fun (r : NNReal -> (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))) => setOf.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => Exists.{1} NNReal (fun (c : NNReal) => BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c (r c) π)))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.has_basis_to_filter BoxIntegral.IntegrationParams.hasBasis_toFilterₓ'. -/
theorem hasBasis_toFilter (l : IntegrationParams) (I : Box ι) :
    (l.toFilter I).HasBasis (fun r : ℝ≥0 → (ι → ℝ) → Ioi (0 : ℝ) => ∀ c, l.RCond (r c)) fun r =>
      { π | ∃ c, l.MemBaseSet I c (r c) π } :=
  by simpa only [set_of_exists] using has_basis_supr (l.has_basis_to_filter_distortion I)
#align box_integral.integration_params.has_basis_to_filter BoxIntegral.IntegrationParams.hasBasis_toFilter

#print BoxIntegral.IntegrationParams.tendsto_embedBox_toFilteriUnion_top /-
theorem tendsto_embedBox_toFilteriUnion_top (l : IntegrationParams) (h : I ≤ J) :
    Tendsto (TaggedPrepartition.embedBox I J h) (l.toFilteriUnion I ⊤)
      (l.toFilteriUnion J (Prepartition.single J I h)) :=
  by
  simp only [to_filter_Union, tendsto_supr]; intro c
  set π₀ := prepartition.single J I h
  refine' le_iSup_of_le (max c π₀.compl.distortion) _
  refine'
    ((l.has_basis_to_filter_distortion_Union I c ⊤).tendsto_iffₓ
          (l.has_basis_to_filter_distortion_Union J _ _)).2
      fun r hr => _
  refine' ⟨r, hr, fun π hπ => _⟩
  rw [mem_set_of_eq, prepartition.Union_top] at hπ
  refine' ⟨⟨hπ.1.1, hπ.1.2, fun hD => le_trans (hπ.1.3 hD) (le_max_left _ _), fun hD => _⟩, _⟩
  · refine' ⟨_, π₀.Union_compl.trans _, le_max_right _ _⟩
    congr 1
    exact (prepartition.Union_single h).trans hπ.2.symm
  · exact hπ.2.trans (prepartition.Union_single _).symm
#align box_integral.integration_params.tendsto_embed_box_to_filter_Union_top BoxIntegral.IntegrationParams.tendsto_embedBox_toFilteriUnion_top
-/

/- warning: box_integral.integration_params.exists_mem_base_set_le_Union_eq -> BoxIntegral.IntegrationParams.exists_memBaseSet_le_iUnion_eq is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {I : BoxIntegral.Box.{u1} ι} {c : NNReal} (l : BoxIntegral.IntegrationParams) (π₀ : BoxIntegral.Prepartition.{u1} ι I), (LE.le.{0} NNReal (Preorder.toHasLe.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (OrderedCancelAddCommMonoid.toPartialOrder.{0} NNReal (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} NNReal NNReal.strictOrderedSemiring)))) (BoxIntegral.Prepartition.distortion.{u1} ι I π₀ _inst_1) c) -> (LE.le.{0} NNReal (Preorder.toHasLe.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (OrderedCancelAddCommMonoid.toPartialOrder.{0} NNReal (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} NNReal NNReal.strictOrderedSemiring)))) (BoxIntegral.Prepartition.distortion.{u1} ι I (BoxIntegral.Prepartition.compl.{u1} ι I (Finite.of_fintype.{u1} ι _inst_1) π₀) _inst_1) c) -> (forall (r : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))), Exists.{succ u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => And (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r π) (And (LE.le.{u1} (BoxIntegral.Prepartition.{u1} ι I) (BoxIntegral.Prepartition.hasLe.{u1} ι I) (BoxIntegral.TaggedPrepartition.toPrepartition.{u1} ι I π) π₀) (Eq.{succ u1} (Set.{u1} (ι -> Real)) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π) (BoxIntegral.Prepartition.iUnion.{u1} ι I π₀)))))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {I : BoxIntegral.Box.{u1} ι} {c : NNReal} (l : BoxIntegral.IntegrationParams) (π₀ : BoxIntegral.Prepartition.{u1} ι I), (LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (StrictOrderedSemiring.toPartialOrder.{0} NNReal instNNRealStrictOrderedSemiring))) (BoxIntegral.Prepartition.distortion.{u1} ι I π₀ _inst_1) c) -> (LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (StrictOrderedSemiring.toPartialOrder.{0} NNReal instNNRealStrictOrderedSemiring))) (BoxIntegral.Prepartition.distortion.{u1} ι I (BoxIntegral.Prepartition.compl.{u1} ι I (Finite.of_fintype.{u1} ι _inst_1) π₀) _inst_1) c) -> (forall (r : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))), Exists.{succ u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => And (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r π) (And (LE.le.{u1} (BoxIntegral.Prepartition.{u1} ι I) (BoxIntegral.Prepartition.instLEPrepartition.{u1} ι I) (BoxIntegral.TaggedPrepartition.toPrepartition.{u1} ι I π) π₀) (Eq.{succ u1} (Set.{u1} (ι -> Real)) (BoxIntegral.TaggedPrepartition.iUnion.{u1} ι I π) (BoxIntegral.Prepartition.iUnion.{u1} ι I π₀)))))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.exists_mem_base_set_le_Union_eq BoxIntegral.IntegrationParams.exists_memBaseSet_le_iUnion_eqₓ'. -/
theorem exists_memBaseSet_le_iUnion_eq (l : IntegrationParams) (π₀ : Prepartition I)
    (hc₁ : π₀.distortion ≤ c) (hc₂ : π₀.compl.distortion ≤ c) (r : (ι → ℝ) → Ioi (0 : ℝ)) :
    ∃ π, l.MemBaseSet I c r π ∧ π.toPrepartition ≤ π₀ ∧ π.iUnion = π₀.iUnion :=
  by
  rcases π₀.exists_tagged_le_is_Henstock_is_subordinate_Union_eq r with ⟨π, hle, hH, hr, hd, hU⟩
  refine' ⟨π, ⟨hr, fun _ => hH, fun _ => hd.trans_le hc₁, fun hD => ⟨π₀.compl, _, hc₂⟩⟩, ⟨hle, hU⟩⟩
  exact prepartition.compl_congr hU ▸ π.to_prepartition.Union_compl
#align box_integral.integration_params.exists_mem_base_set_le_Union_eq BoxIntegral.IntegrationParams.exists_memBaseSet_le_iUnion_eq

/- warning: box_integral.integration_params.exists_mem_base_set_is_partition -> BoxIntegral.IntegrationParams.exists_memBaseSet_isPartition is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {c : NNReal} (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι), (LE.le.{0} NNReal (Preorder.toHasLe.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (OrderedCancelAddCommMonoid.toPartialOrder.{0} NNReal (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} NNReal NNReal.strictOrderedSemiring)))) (BoxIntegral.Box.distortion.{u1} ι _inst_1 I) c) -> (forall (r : (ι -> Real) -> (coeSort.{1, 2} (Set.{0} Real) Type (Set.hasCoeToSort.{0} Real) (Set.Ioi.{0} Real Real.preorder (OfNat.ofNat.{0} Real 0 (OfNat.mk.{0} Real 0 (Zero.zero.{0} Real Real.hasZero)))))), Exists.{succ u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => And (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r π) (BoxIntegral.TaggedPrepartition.IsPartition.{u1} ι I π)))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {c : NNReal} (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι), (LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (StrictOrderedSemiring.toPartialOrder.{0} NNReal instNNRealStrictOrderedSemiring))) (BoxIntegral.Box.distortion.{u1} ι _inst_1 I) c) -> (forall (r : (ι -> Real) -> (Set.Elem.{0} Real (Set.Ioi.{0} Real Real.instPreorderReal (OfNat.ofNat.{0} Real 0 (Zero.toOfNat0.{0} Real Real.instZeroReal))))), Exists.{succ u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (fun (π : BoxIntegral.TaggedPrepartition.{u1} ι I) => And (BoxIntegral.IntegrationParams.MemBaseSet.{u1} ι _inst_1 l I c r π) (BoxIntegral.TaggedPrepartition.IsPartition.{u1} ι I π)))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.exists_mem_base_set_is_partition BoxIntegral.IntegrationParams.exists_memBaseSet_isPartitionₓ'. -/
theorem exists_memBaseSet_isPartition (l : IntegrationParams) (I : Box ι) (hc : I.distortion ≤ c)
    (r : (ι → ℝ) → Ioi (0 : ℝ)) : ∃ π, l.MemBaseSet I c r π ∧ π.IsPartition :=
  by
  rw [← prepartition.distortion_top] at hc
  have hc' : (⊤ : prepartition I).compl.distortion ≤ c := by simp
  simpa [is_partition_iff_Union_eq] using l.exists_mem_base_set_le_Union_eq ⊤ hc hc' r
#align box_integral.integration_params.exists_mem_base_set_is_partition BoxIntegral.IntegrationParams.exists_memBaseSet_isPartition

/- warning: box_integral.integration_params.to_filter_distortion_Union_ne_bot -> BoxIntegral.IntegrationParams.toFilterDistortioniUnion_neBot is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {c : NNReal} (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι) (π₀ : BoxIntegral.Prepartition.{u1} ι I), (LE.le.{0} NNReal (Preorder.toHasLe.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (OrderedCancelAddCommMonoid.toPartialOrder.{0} NNReal (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} NNReal NNReal.strictOrderedSemiring)))) (BoxIntegral.Prepartition.distortion.{u1} ι I π₀ _inst_1) c) -> (LE.le.{0} NNReal (Preorder.toHasLe.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (OrderedCancelAddCommMonoid.toPartialOrder.{0} NNReal (StrictOrderedSemiring.toOrderedCancelAddCommMonoid.{0} NNReal NNReal.strictOrderedSemiring)))) (BoxIntegral.Prepartition.distortion.{u1} ι I (BoxIntegral.Prepartition.compl.{u1} ι I (Finite.of_fintype.{u1} ι _inst_1) π₀) _inst_1) c) -> (Filter.NeBot.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (BoxIntegral.IntegrationParams.toFilterDistortioniUnion.{u1} ι _inst_1 l I c π₀))
but is expected to have type
  forall {ι : Type.{u1}} [_inst_1 : Fintype.{u1} ι] {c : NNReal} (l : BoxIntegral.IntegrationParams) (I : BoxIntegral.Box.{u1} ι) (π₀ : BoxIntegral.Prepartition.{u1} ι I), (LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (StrictOrderedSemiring.toPartialOrder.{0} NNReal instNNRealStrictOrderedSemiring))) (BoxIntegral.Prepartition.distortion.{u1} ι I π₀ _inst_1) c) -> (LE.le.{0} NNReal (Preorder.toLE.{0} NNReal (PartialOrder.toPreorder.{0} NNReal (StrictOrderedSemiring.toPartialOrder.{0} NNReal instNNRealStrictOrderedSemiring))) (BoxIntegral.Prepartition.distortion.{u1} ι I (BoxIntegral.Prepartition.compl.{u1} ι I (Finite.of_fintype.{u1} ι _inst_1) π₀) _inst_1) c) -> (Filter.NeBot.{u1} (BoxIntegral.TaggedPrepartition.{u1} ι I) (BoxIntegral.IntegrationParams.toFilterDistortioniUnion.{u1} ι _inst_1 l I c π₀))
Case conversion may be inaccurate. Consider using '#align box_integral.integration_params.to_filter_distortion_Union_ne_bot BoxIntegral.IntegrationParams.toFilterDistortioniUnion_neBotₓ'. -/
theorem toFilterDistortioniUnion_neBot (l : IntegrationParams) (I : Box ι) (π₀ : Prepartition I)
    (hc₁ : π₀.distortion ≤ c) (hc₂ : π₀.compl.distortion ≤ c) :
    (l.toFilterDistortioniUnion I c π₀).ne_bot :=
  ((l.hasBasis_toFilterDistortion I _).inf_principal _).neBot_iff.2 fun r hr =>
    (l.exists_memBaseSet_le_iUnion_eq π₀ hc₁ hc₂ r).imp fun π hπ => ⟨hπ.1, hπ.2.2⟩
#align box_integral.integration_params.to_filter_distortion_Union_ne_bot BoxIntegral.IntegrationParams.toFilterDistortioniUnion_neBot

#print BoxIntegral.IntegrationParams.toFilterDistortioniUnion_neBot' /-
instance toFilterDistortioniUnion_neBot' (l : IntegrationParams) (I : Box ι) (π₀ : Prepartition I) :
    (l.toFilterDistortioniUnion I (max π₀.distortion π₀.compl.distortion) π₀).ne_bot :=
  l.toFilterDistortioniUnion_neBot I π₀ (le_max_left _ _) (le_max_right _ _)
#align box_integral.integration_params.to_filter_distortion_Union_ne_bot' BoxIntegral.IntegrationParams.toFilterDistortioniUnion_neBot'
-/

#print BoxIntegral.IntegrationParams.toFilterDistortion_neBot /-
instance toFilterDistortion_neBot (l : IntegrationParams) (I : Box ι) :
    (l.toFilterDistortion I I.distortion).ne_bot := by
  simpa using (l.to_filter_distortion_Union_ne_bot' I ⊤).mono inf_le_left
#align box_integral.integration_params.to_filter_distortion_ne_bot BoxIntegral.IntegrationParams.toFilterDistortion_neBot
-/

#print BoxIntegral.IntegrationParams.toFilter_neBot /-
instance toFilter_neBot (l : IntegrationParams) (I : Box ι) : (l.toFilter I).ne_bot :=
  (l.toFilterDistortion_neBot I).mono <| le_iSup _ _
#align box_integral.integration_params.to_filter_ne_bot BoxIntegral.IntegrationParams.toFilter_neBot
-/

#print BoxIntegral.IntegrationParams.toFilteriUnion_neBot /-
instance toFilteriUnion_neBot (l : IntegrationParams) (I : Box ι) (π₀ : Prepartition I) :
    (l.toFilteriUnion I π₀).ne_bot :=
  (l.toFilterDistortioniUnion_neBot' I π₀).mono <|
    le_iSup (fun c => l.toFilterDistortioniUnion I c π₀) _
#align box_integral.integration_params.to_filter_Union_ne_bot BoxIntegral.IntegrationParams.toFilteriUnion_neBot
-/

#print BoxIntegral.IntegrationParams.eventually_isPartition /-
theorem eventually_isPartition (l : IntegrationParams) (I : Box ι) :
    ∀ᶠ π in l.toFilteriUnion I ⊤, TaggedPrepartition.IsPartition π :=
  eventually_iSup.2 fun c =>
    eventually_inf_principal.2 <|
      eventually_of_forall fun π h =>
        π.isPartition_iff_iUnion_eq.2 (h.trans Prepartition.iUnion_top)
#align box_integral.integration_params.eventually_is_partition BoxIntegral.IntegrationParams.eventually_isPartition
-/

end IntegrationParams

end BoxIntegral

