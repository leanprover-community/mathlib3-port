/-
Copyright © 2020 Nicolò Cavalleri. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Nicolò Cavalleri

! This file was ported from Lean 3 source module geometry.manifold.algebra.lie_group
! leanprover-community/mathlib commit c5c7e2760814660967bc27f0de95d190a22297f3
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Geometry.Manifold.Algebra.Monoid

/-!
# Lie groups

A Lie group is a group that is also a smooth manifold, in which the group operations of
multiplication and inversion are smooth maps. Smoothness of the group multiplication means that
multiplication is a smooth mapping of the product manifold `G` × `G` into `G`.

Note that, since a manifold here is not second-countable and Hausdorff a Lie group here is not
guaranteed to be second-countable (even though it can be proved it is Hausdorff). Note also that Lie
groups here are not necessarily finite dimensional.

## Main definitions and statements

* `lie_add_group I G` : a Lie additive group where `G` is a manifold on the model with corners `I`.
* `lie_group I G`     : a Lie multiplicative group where `G` is a manifold on the model with
                        corners `I`.
* `normed_space_lie_add_group` : a normed vector space over a nontrivially normed field
                                 is an additive Lie group.

## Implementation notes

A priori, a Lie group here is a manifold with corners.

The definition of Lie group cannot require `I : model_with_corners 𝕜 E E` with the same space as the
model space and as the model vector space, as one might hope, beause in the product situation,
the model space is `model_prod E E'` and the model vector space is `E × E'`, which are not the same,
so the definition does not apply. Hence the definition should be more general, allowing
`I : model_with_corners 𝕜 E H`.
-/


noncomputable section

open Manifold

-- See note [Design choices about smooth algebraic structures]
/-- A Lie (additive) group is a group and a smooth manifold at the same time in which
the addition and negation operations are smooth. -/
class LieAddGroup {𝕜 : Type _} [NontriviallyNormedField 𝕜] {H : Type _} [TopologicalSpace H]
  {E : Type _} [NormedAddCommGroup E] [NormedSpace 𝕜 E] (I : ModelWithCorners 𝕜 E H) (G : Type _)
  [AddGroup G] [TopologicalSpace G] [ChartedSpace H G] extends HasSmoothAdd I G : Prop where
  smoothNeg : Smooth I I fun a : G => -a
#align lie_add_group LieAddGroup

-- See note [Design choices about smooth algebraic structures]
/-- A Lie group is a group and a smooth manifold at the same time in which
the multiplication and inverse operations are smooth. -/
@[to_additive]
class LieGroup {𝕜 : Type _} [NontriviallyNormedField 𝕜] {H : Type _} [TopologicalSpace H]
  {E : Type _} [NormedAddCommGroup E] [NormedSpace 𝕜 E] (I : ModelWithCorners 𝕜 E H) (G : Type _)
  [Group G] [TopologicalSpace G] [ChartedSpace H G] extends HasSmoothMul I G : Prop where
  smoothInv : Smooth I I fun a : G => a⁻¹
#align lie_group LieGroup

section LieGroup

variable {𝕜 : Type _} [NontriviallyNormedField 𝕜] {H : Type _} [TopologicalSpace H] {E : Type _}
  [NormedAddCommGroup E] [NormedSpace 𝕜 E] {I : ModelWithCorners 𝕜 E H} {F : Type _}
  [NormedAddCommGroup F] [NormedSpace 𝕜 F] {J : ModelWithCorners 𝕜 F F} {G : Type _}
  [TopologicalSpace G] [ChartedSpace H G] [Group G] [LieGroup I G] {E' : Type _}
  [NormedAddCommGroup E'] [NormedSpace 𝕜 E'] {H' : Type _} [TopologicalSpace H']
  {I' : ModelWithCorners 𝕜 E' H'} {M : Type _} [TopologicalSpace M] [ChartedSpace H' M]
  {E'' : Type _} [NormedAddCommGroup E''] [NormedSpace 𝕜 E''] {H'' : Type _} [TopologicalSpace H'']
  {I'' : ModelWithCorners 𝕜 E'' H''} {M' : Type _} [TopologicalSpace M'] [ChartedSpace H'' M']

section

variable (I)

@[to_additive]
theorem smoothInv : Smooth I I fun x : G => x⁻¹ :=
  LieGroup.smoothInv
#align smooth_inv smoothInv

/-- A Lie group is a topological group. This is not an instance for technical reasons,
see note [Design choices about smooth algebraic structures]. -/
@[to_additive
      "An additive Lie group is an additive topological group. This is not an instance for technical\nreasons, see note [Design choices about smooth algebraic structures]."]
theorem topological_group_of_lie_group : TopologicalGroup G :=
  { has_continuous_mul_of_smooth I with continuous_inv := (smoothInv I).Continuous }
#align topological_group_of_lie_group topological_group_of_lie_group

end

@[to_additive]
theorem Smooth.inv {f : M → G} (hf : Smooth I' I f) : Smooth I' I fun x => (f x)⁻¹ :=
  (smoothInv I).comp hf
#align smooth.inv Smooth.inv

@[to_additive]
theorem SmoothOn.inv {f : M → G} {s : Set M} (hf : SmoothOn I' I f s) :
    SmoothOn I' I (fun x => (f x)⁻¹) s :=
  (smoothInv I).compSmoothOn hf
#align smooth_on.inv SmoothOn.inv

@[to_additive]
theorem Smooth.div {f g : M → G} (hf : Smooth I' I f) (hg : Smooth I' I g) : Smooth I' I (f / g) :=
  by 
  rw [div_eq_mul_inv]
  exact ((smoothMul I).comp (hf.prod_mk hg.inv) : _)
#align smooth.div Smooth.div

@[to_additive]
theorem SmoothOn.div {f g : M → G} {s : Set M} (hf : SmoothOn I' I f s) (hg : SmoothOn I' I g s) :
    SmoothOn I' I (f / g) s := by 
  rw [div_eq_mul_inv]
  exact ((smoothMul I).compSmoothOn (hf.prod_mk hg.inv) : _)
#align smooth_on.div SmoothOn.div

end LieGroup

section ProdLieGroup

-- Instance of product group
@[to_additive]
instance {𝕜 : Type _} [NontriviallyNormedField 𝕜] {H : Type _} [TopologicalSpace H] {E : Type _}
    [NormedAddCommGroup E] [NormedSpace 𝕜 E] {I : ModelWithCorners 𝕜 E H} {G : Type _}
    [TopologicalSpace G] [ChartedSpace H G] [Group G] [LieGroup I G] {E' : Type _}
    [NormedAddCommGroup E'] [NormedSpace 𝕜 E'] {H' : Type _} [TopologicalSpace H']
    {I' : ModelWithCorners 𝕜 E' H'} {G' : Type _} [TopologicalSpace G'] [ChartedSpace H' G']
    [Group G'] [LieGroup I' G'] : LieGroup (I.Prod I') (G × G') :=
  { HasSmoothMul.prod _ _ _ _ with smoothInv := smoothFst.inv.prod_mk smoothSnd.inv }

end ProdLieGroup

/-! ### Normed spaces are Lie groups -/


instance normedSpaceLieAddGroup {𝕜 : Type _} [NontriviallyNormedField 𝕜] {E : Type _}
    [NormedAddCommGroup E] [NormedSpace 𝕜 E] : LieAddGroup 𝓘(𝕜, E) E :=
  { modelSpaceSmooth with
    smoothAdd := smooth_iff.2 ⟨continuous_add, fun x y => contDiffAdd.ContDiffOn⟩
    smoothNeg := smooth_iff.2 ⟨continuous_neg, fun x y => contDiffNeg.ContDiffOn⟩ }
#align normed_space_lie_add_group normedSpaceLieAddGroup

