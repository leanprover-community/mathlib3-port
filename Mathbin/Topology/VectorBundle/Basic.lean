/-
Copyright © 2020 Nicolò Cavalleri. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Nicolò Cavalleri, Sebastien Gouezel, Heather Macbeth, Patrick Massot, Floris van Doorn
-/
import Mathbin.Analysis.NormedSpace.BoundedLinearMaps
import Mathbin.Topology.FiberBundle.Basic

/-!
# Topological vector bundles

In this file we define topological vector bundles.

Let `B` be the base space. In our formalism, a topological vector bundle is by definition the type
`bundle.total_space E` where `E : B → Type*` is a function associating to
`x : B` the fiber over `x`. This type `bundle.total_space E` is just a type synonym for
`Σ (x : B), E x`, with the interest that one can put another topology than on `Σ (x : B), E x`
which has the disjoint union topology.

To have a topological vector bundle structure on `bundle.total_space E`, one should
additionally have the following data:

* `F` should be a normed space over a normed field `R`;
* There should be a topology on `bundle.total_space E`, for which the projection to `B` is
a topological fiber bundle with fiber `F` (in particular, each fiber `E x` is homeomorphic to `F`);
* For each `x`, the fiber `E x` should be a topological vector space over `R`, and the injection
from `E x` to `bundle.total_space F E` should be an embedding;
* There should be a distinguished set of bundle trivializations (which are continuous linear equivs
in the fibres), the "trivialization atlas"
* There should be a choice of bundle trivialization at each point, which belongs to this atlas.

If all these conditions are satisfied, and if moreover for any two trivializations `e`, `e'` in the
atlas the transition function considered as a map from `B` into `F →L[R] F` is continuous on
`e.base_set ∩ e'.base_set` with respect to the operator norm topology on `F →L[R] F`, we register
the typeclass `topological_vector_bundle R F E`.

We define constructions on vector bundles like pullbacks and direct sums in other files.
Only the trivial bundle is defined in this file.

## Tags
Vector bundle
-/


noncomputable section

open Bundle Set

open Classical Bundle

variable (R 𝕜 : Type _) {B : Type _} (F : Type _) (E : B → Type _)

section TopologicalVectorSpace

variable {B F E} [Semiring R] [TopologicalSpace F] [TopologicalSpace B]

/-- A mixin class for `pretrivialization`, stating that a pretrivialization is fibrewise linear with
respect to given module structures on its fibres and the model fibre. -/
protected class Pretrivialization.IsLinear [AddCommMonoid F] [Module R F] [∀ x, AddCommMonoid (E x)]
  [∀ x, Module R (E x)] (e : Pretrivialization F (π E)) : Prop where
  linear : ∀ b ∈ e.baseSet, IsLinearMap R fun x : E b => (e (totalSpaceMk b x)).2
#align pretrivialization.is_linear Pretrivialization.IsLinear

namespace Pretrivialization

variable {F E} (e : Pretrivialization F (π E)) {x : TotalSpace E} {b : B} {y : E b}

theorem linear [AddCommMonoid F] [Module R F] [∀ x, AddCommMonoid (E x)] [∀ x, Module R (E x)] [e.is_linear R] {b : B}
    (hb : b ∈ e.baseSet) : IsLinearMap R fun x : E b => (e (totalSpaceMk b x)).2 :=
  Pretrivialization.IsLinear.linear b hb
#align pretrivialization.linear Pretrivialization.linear

variable [AddCommMonoid F] [Module R F] [∀ x, AddCommMonoid (E x)] [∀ x, Module R (E x)]

/-- A fiberwise linear inverse to `e`. -/
@[simps]
protected def symmₗ (e : Pretrivialization F (π E)) [e.is_linear R] (b : B) : F →ₗ[R] E b := by
  refine' IsLinearMap.mk' (e.symm b) _
  by_cases hb:b ∈ e.base_set
  · exact
      (((e.linear R hb).mk' _).inverse (e.symm b) (e.symm_apply_apply_mk hb) fun v =>
          congr_arg Prod.snd <| e.apply_mk_symm hb v).is_linear
    
  · rw [e.coe_symm_of_not_mem hb]
    exact (0 : F →ₗ[R] E b).is_linear
    
#align pretrivialization.symmₗ Pretrivialization.symmₗ

/-- A pretrivialization for a topological vector bundle defines linear equivalences between the
fibers and the model space. -/
@[simps (config := { fullyApplied := false })]
def linearEquivAt (e : Pretrivialization F (π E)) [e.is_linear R] (b : B) (hb : b ∈ e.baseSet) : E b ≃ₗ[R] F where
  toFun y := (e (totalSpaceMk b y)).2
  invFun := e.symm b
  left_inv := e.symm_apply_apply_mk hb
  right_inv v := by simp_rw [e.apply_mk_symm hb v]
  map_add' v w := (e.linear R hb).map_add v w
  map_smul' c v := (e.linear R hb).map_smul c v
#align pretrivialization.linear_equiv_at Pretrivialization.linearEquivAt

/-- A fiberwise linear map equal to `e` on `e.base_set`. -/
protected def linearMapAt (e : Pretrivialization F (π E)) [e.is_linear R] (b : B) : E b →ₗ[R] F :=
  if hb : b ∈ e.baseSet then e.linearEquivAt R b hb else 0
#align pretrivialization.linear_map_at Pretrivialization.linearMapAt

variable {R}

theorem coe_linear_map_at (e : Pretrivialization F (π E)) [e.is_linear R] (b : B) :
    ⇑(e.linearMapAt R b) = fun y => if b ∈ e.baseSet then (e (totalSpaceMk b y)).2 else 0 := by
  rw [Pretrivialization.linearMapAt]
  split_ifs <;> rfl
#align pretrivialization.coe_linear_map_at Pretrivialization.coe_linear_map_at

theorem coe_linear_map_at_of_mem (e : Pretrivialization F (π E)) [e.is_linear R] {b : B} (hb : b ∈ e.baseSet) :
    ⇑(e.linearMapAt R b) = fun y => (e (totalSpaceMk b y)).2 := by simp_rw [coe_linear_map_at, if_pos hb]
#align pretrivialization.coe_linear_map_at_of_mem Pretrivialization.coe_linear_map_at_of_mem

theorem linear_map_at_apply (e : Pretrivialization F (π E)) [e.is_linear R] {b : B} (y : E b) :
    e.linearMapAt R b y = if b ∈ e.baseSet then (e (totalSpaceMk b y)).2 else 0 := by rw [coe_linear_map_at]
#align pretrivialization.linear_map_at_apply Pretrivialization.linear_map_at_apply

theorem linear_map_at_def_of_mem (e : Pretrivialization F (π E)) [e.is_linear R] {b : B} (hb : b ∈ e.baseSet) :
    e.linearMapAt R b = e.linearEquivAt R b hb :=
  dif_pos hb
#align pretrivialization.linear_map_at_def_of_mem Pretrivialization.linear_map_at_def_of_mem

theorem linear_map_at_def_of_not_mem (e : Pretrivialization F (π E)) [e.is_linear R] {b : B} (hb : b ∉ e.baseSet) :
    e.linearMapAt R b = 0 :=
  dif_neg hb
#align pretrivialization.linear_map_at_def_of_not_mem Pretrivialization.linear_map_at_def_of_not_mem

theorem linear_map_at_eq_zero (e : Pretrivialization F (π E)) [e.is_linear R] {b : B} (hb : b ∉ e.baseSet) :
    e.linearMapAt R b = 0 :=
  dif_neg hb
#align pretrivialization.linear_map_at_eq_zero Pretrivialization.linear_map_at_eq_zero

theorem symmₗ_linear_map_at (e : Pretrivialization F (π E)) [e.is_linear R] {b : B} (hb : b ∈ e.baseSet) (y : E b) :
    e.symmₗ R b (e.linearMapAt R b y) = y := by
  rw [e.linear_map_at_def_of_mem hb]
  exact (e.linear_equiv_at R b hb).left_inv y
#align pretrivialization.symmₗ_linear_map_at Pretrivialization.symmₗ_linear_map_at

theorem linear_map_at_symmₗ (e : Pretrivialization F (π E)) [e.is_linear R] {b : B} (hb : b ∈ e.baseSet) (y : F) :
    e.linearMapAt R b (e.symmₗ R b y) = y := by
  rw [e.linear_map_at_def_of_mem hb]
  exact (e.linear_equiv_at R b hb).right_inv y
#align pretrivialization.linear_map_at_symmₗ Pretrivialization.linear_map_at_symmₗ

end Pretrivialization

variable (R) [TopologicalSpace (TotalSpace E)]

/-- A mixin class for `trivialization`, stating that a trivialization is fibrewise linear with
respect to given module structures on its fibres and the model fibre. -/
protected class Trivialization.IsLinear [AddCommMonoid F] [Module R F] [∀ x, AddCommMonoid (E x)] [∀ x, Module R (E x)]
  (e : Trivialization F (π E)) : Prop where
  linear : ∀ b ∈ e.baseSet, IsLinearMap R fun x : E b => (e (totalSpaceMk b x)).2
#align trivialization.is_linear Trivialization.IsLinear

namespace Trivialization

variable (e : Trivialization F (π E)) {x : TotalSpace E} {b : B} {y : E b}

protected theorem linear [AddCommMonoid F] [Module R F] [∀ x, AddCommMonoid (E x)] [∀ x, Module R (E x)] [e.is_linear R]
    {b : B} (hb : b ∈ e.baseSet) : IsLinearMap R fun y : E b => (e (totalSpaceMk b y)).2 :=
  Trivialization.IsLinear.linear b hb
#align trivialization.linear Trivialization.linear

instance toPretrivialization.is_linear [AddCommMonoid F] [Module R F] [∀ x, AddCommMonoid (E x)] [∀ x, Module R (E x)]
    [e.is_linear R] : e.toPretrivialization.is_linear R :=
  { (‹_› : e.is_linear R) with }
#align trivialization.to_pretrivialization.is_linear Trivialization.toPretrivialization.is_linear

variable [AddCommMonoid F] [Module R F] [∀ x, AddCommMonoid (E x)] [∀ x, Module R (E x)]

/-- A trivialization for a topological vector bundle defines linear equivalences between the
fibers and the model space. -/
def linearEquivAt (e : Trivialization F (π E)) [e.is_linear R] (b : B) (hb : b ∈ e.baseSet) : E b ≃ₗ[R] F :=
  e.toPretrivialization.linearEquivAt R b hb
#align trivialization.linear_equiv_at Trivialization.linearEquivAt

variable {R}

@[simp]
theorem linear_equiv_at_apply (e : Trivialization F (π E)) [e.is_linear R] (b : B) (hb : b ∈ e.baseSet) (v : E b) :
    e.linearEquivAt R b hb v = (e (totalSpaceMk b v)).2 :=
  rfl
#align trivialization.linear_equiv_at_apply Trivialization.linear_equiv_at_apply

@[simp]
theorem linear_equiv_at_symm_apply (e : Trivialization F (π E)) [e.is_linear R] (b : B) (hb : b ∈ e.baseSet) (v : F) :
    (e.linearEquivAt R b hb).symm v = e.symm b v :=
  rfl
#align trivialization.linear_equiv_at_symm_apply Trivialization.linear_equiv_at_symm_apply

variable (R)

/-- A fiberwise linear inverse to `e`. -/
protected def symmₗ (e : Trivialization F (π E)) [e.is_linear R] (b : B) : F →ₗ[R] E b :=
  e.toPretrivialization.symmₗ R b
#align trivialization.symmₗ Trivialization.symmₗ

variable {R}

theorem coe_symmₗ (e : Trivialization F (π E)) [e.is_linear R] (b : B) : ⇑(e.symmₗ R b) = e.symm b :=
  rfl
#align trivialization.coe_symmₗ Trivialization.coe_symmₗ

variable (R)

/-- A fiberwise linear map equal to `e` on `e.base_set`. -/
protected def linearMapAt (e : Trivialization F (π E)) [e.is_linear R] (b : B) : E b →ₗ[R] F :=
  e.toPretrivialization.linearMapAt R b
#align trivialization.linear_map_at Trivialization.linearMapAt

variable {R}

theorem coe_linear_map_at (e : Trivialization F (π E)) [e.is_linear R] (b : B) :
    ⇑(e.linearMapAt R b) = fun y => if b ∈ e.baseSet then (e (totalSpaceMk b y)).2 else 0 :=
  e.toPretrivialization.coe_linear_map_at b
#align trivialization.coe_linear_map_at Trivialization.coe_linear_map_at

theorem coe_linear_map_at_of_mem (e : Trivialization F (π E)) [e.is_linear R] {b : B} (hb : b ∈ e.baseSet) :
    ⇑(e.linearMapAt R b) = fun y => (e (totalSpaceMk b y)).2 := by simp_rw [coe_linear_map_at, if_pos hb]
#align trivialization.coe_linear_map_at_of_mem Trivialization.coe_linear_map_at_of_mem

theorem linear_map_at_apply (e : Trivialization F (π E)) [e.is_linear R] {b : B} (y : E b) :
    e.linearMapAt R b y = if b ∈ e.baseSet then (e (totalSpaceMk b y)).2 else 0 := by rw [coe_linear_map_at]
#align trivialization.linear_map_at_apply Trivialization.linear_map_at_apply

theorem linear_map_at_def_of_mem (e : Trivialization F (π E)) [e.is_linear R] {b : B} (hb : b ∈ e.baseSet) :
    e.linearMapAt R b = e.linearEquivAt R b hb :=
  dif_pos hb
#align trivialization.linear_map_at_def_of_mem Trivialization.linear_map_at_def_of_mem

theorem linear_map_at_def_of_not_mem (e : Trivialization F (π E)) [e.is_linear R] {b : B} (hb : b ∉ e.baseSet) :
    e.linearMapAt R b = 0 :=
  dif_neg hb
#align trivialization.linear_map_at_def_of_not_mem Trivialization.linear_map_at_def_of_not_mem

theorem symmₗ_linear_map_at (e : Trivialization F (π E)) [e.is_linear R] {b : B} (hb : b ∈ e.baseSet) (y : E b) :
    e.symmₗ R b (e.linearMapAt R b y) = y :=
  e.toPretrivialization.symmₗ_linear_map_at hb y
#align trivialization.symmₗ_linear_map_at Trivialization.symmₗ_linear_map_at

theorem linear_map_at_symmₗ (e : Trivialization F (π E)) [e.is_linear R] {b : B} (hb : b ∈ e.baseSet) (y : F) :
    e.linearMapAt R b (e.symmₗ R b y) = y :=
  e.toPretrivialization.linear_map_at_symmₗ hb y
#align trivialization.linear_map_at_symmₗ Trivialization.linear_map_at_symmₗ

variable (R)

/-- A coordinate change function between two trivializations, as a continuous linear equivalence.
  Defined to be the identity when `b` does not lie in the base set of both trivializations. -/
def coordChangeL (e e' : Trivialization F (π E)) [e.is_linear R] [e'.is_linear R] (b : B) : F ≃L[R] F :=
  { if hb : b ∈ e.baseSet ∩ e'.baseSet then (e.linearEquivAt R b (hb.1 : _)).symm.trans (e'.linearEquivAt R b hb.2)
    else LinearEquiv.refl R F with
    continuous_to_fun := by
      by_cases hb:b ∈ e.base_set ∩ e'.base_set
      · simp_rw [dif_pos hb]
        refine' (e'.continuous_on.comp_continuous _ _).snd
        exact e.continuous_on_symm.comp_continuous (Continuous.Prod.mk b) fun y => mk_mem_prod hb.1 (mem_univ y)
        exact fun y => e'.mem_source.mpr hb.2
        
      · rw [dif_neg hb]
        exact continuous_id
        ,
    continuous_inv_fun := by
      by_cases hb:b ∈ e.base_set ∩ e'.base_set
      · simp_rw [dif_pos hb]
        refine' (e.continuous_on.comp_continuous _ _).snd
        exact e'.continuous_on_symm.comp_continuous (Continuous.Prod.mk b) fun y => mk_mem_prod hb.2 (mem_univ y)
        exact fun y => e.mem_source.mpr hb.1
        
      · rw [dif_neg hb]
        exact continuous_id
         }
#align trivialization.coord_changeL Trivialization.coordChangeL

variable {R}

theorem coe_coord_changeL (e e' : Trivialization F (π E)) [e.is_linear R] [e'.is_linear R] {b : B}
    (hb : b ∈ e.baseSet ∩ e'.baseSet) :
    ⇑(coordChangeL R e e' b) = (e.linearEquivAt R b hb.1).symm.trans (e'.linearEquivAt R b hb.2) :=
  congr_arg LinearEquiv.toFun (dif_pos hb)
#align trivialization.coe_coord_changeL Trivialization.coe_coord_changeL

theorem coord_changeL_apply (e e' : Trivialization F (π E)) [e.is_linear R] [e'.is_linear R] {b : B}
    (hb : b ∈ e.baseSet ∩ e'.baseSet) (y : F) : coordChangeL R e e' b y = (e' (totalSpaceMk b (e.symm b y))).2 :=
  congr_arg (fun f => LinearEquiv.toFun f y) (dif_pos hb)
#align trivialization.coord_changeL_apply Trivialization.coord_changeL_apply

theorem mk_coord_changeL (e e' : Trivialization F (π E)) [e.is_linear R] [e'.is_linear R] {b : B}
    (hb : b ∈ e.baseSet ∩ e'.baseSet) (y : F) : (b, coordChangeL R e e' b y) = e' (totalSpaceMk b (e.symm b y)) := by
  ext
  · rw [e.mk_symm hb.1 y, e'.coe_fst', e.proj_symm_apply' hb.1]
    rw [e.proj_symm_apply' hb.1]
    exact hb.2
    
  · exact e.coord_changeL_apply e' hb y
    
#align trivialization.mk_coord_changeL Trivialization.mk_coord_changeL

/-- A version of `coord_change_apply` that fully unfolds `coord_change`. The right-hand side is
ugly, but has good definitional properties for specifically defined trivializations. -/
theorem coord_changeL_apply' (e e' : Trivialization F (π E)) [e.is_linear R] [e'.is_linear R] {b : B}
    (hb : b ∈ e.baseSet ∩ e'.baseSet) (y : F) : coordChangeL R e e' b y = (e' (e.toLocalHomeomorph.symm (b, y))).2 := by
  rw [e.coord_changeL_apply e' hb, e.mk_symm hb.1]
#align trivialization.coord_changeL_apply' Trivialization.coord_changeL_apply'

theorem coord_changeL_symm_apply (e e' : Trivialization F (π E)) [e.is_linear R] [e'.is_linear R] {b : B}
    (hb : b ∈ e.baseSet ∩ e'.baseSet) :
    ⇑(coordChangeL R e e' b).symm = (e'.linearEquivAt R b hb.2).symm.trans (e.linearEquivAt R b hb.1) :=
  congr_arg LinearEquiv.invFun (dif_pos hb)
#align trivialization.coord_changeL_symm_apply Trivialization.coord_changeL_symm_apply

end Trivialization

end TopologicalVectorSpace

section

variable [NontriviallyNormedField R] [∀ x, AddCommMonoid (E x)] [∀ x, Module R (E x)] [NormedAddCommGroup F]
  [NormedSpace R F] [TopologicalSpace B] [TopologicalSpace (TotalSpace E)] [∀ x, TopologicalSpace (E x)]

/- ./././Mathport/Syntax/Translate/Command.lean:355:30: infer kinds are unsupported in Lean 4: #[`total_space_mk_inducing] [] -/
/- ./././Mathport/Syntax/Translate/Command.lean:355:30: infer kinds are unsupported in Lean 4: #[`trivializationAtlas] [] -/
/- ./././Mathport/Syntax/Translate/Command.lean:355:30: infer kinds are unsupported in Lean 4: #[`trivializationAt] [] -/
/- ./././Mathport/Syntax/Translate/Command.lean:355:30: infer kinds are unsupported in Lean 4: #[`mem_base_set_trivialization_at] [] -/
/- ./././Mathport/Syntax/Translate/Command.lean:355:30: infer kinds are unsupported in Lean 4: #[`trivialization_mem_atlas] [] -/
/- ./././Mathport/Syntax/Translate/Command.lean:355:30: infer kinds are unsupported in Lean 4: #[`continuous_on_coord_change'] [] -/
/-- The space `total_space E` (for `E : B → Type*` such that each `E x` is a topological vector
space) has a topological vector space structure with fiber `F` (denoted with
`topological_vector_bundle R F E`) if around every point there is a fiber bundle trivialization
which is linear in the fibers. -/
class TopologicalVectorBundle where
  total_space_mk_inducing : ∀ b : B, Inducing (@totalSpaceMk B E b)
  trivializationAtlas : Set (Trivialization F (π E))
  trivialization_linear' : ∀ (e : Trivialization F (π E)) (he : e ∈ trivialization_atlas), e.is_linear R
  trivializationAt : B → Trivialization F (π E)
  mem_base_set_trivialization_at : ∀ b : B, b ∈ (trivialization_at b).baseSet
  trivialization_mem_atlas : ∀ b : B, trivialization_at b ∈ trivialization_atlas
  continuous_on_coord_change' :
    ∀ (e e' : Trivialization F (π E)) (he : e ∈ trivialization_atlas) (he' : e' ∈ trivialization_atlas),
      have := trivialization_linear' e he
      have := trivialization_linear' e' he'
      ContinuousOn (fun b => Trivialization.coordChangeL R e e' b : B → F →L[R] F) (e.baseSet ∩ e'.baseSet)
#align topological_vector_bundle TopologicalVectorBundle

export
  TopologicalVectorBundle (trivializationAtlas trivializationAt mem_base_set_trivialization_at trivialization_mem_atlas)

variable {F E} [TopologicalVectorBundle R F E]

/-- Given a type `E` equipped with a topological vector bundle structure, this is a `Prop` typeclass
for trivializations of `E`, expressing that a trivialization is in the designated atlas for the
bundle.  This is needed because lemmas about the linearity of trivializations or the continuity (as
functions to `F →L[R] F`, where `F` is the model fibre) of the transition functions are only
expected to hold for trivializations in the designated atlas. -/
@[mk_iff]
class MemTrivializationAtlas (e : Trivialization F (π E)) : Prop where
  out : e ∈ trivializationAtlas R F E
#align mem_trivialization_atlas MemTrivializationAtlas

instance (b : B) :
    MemTrivializationAtlas R
      (trivializationAt R F E b) where out := TopologicalVectorBundle.trivialization_mem_atlas R F E b

instance (priority := 100) trivialization_linear (e : Trivialization F (π E)) [he : MemTrivializationAtlas R e] :
    e.is_linear R :=
  TopologicalVectorBundle.trivialization_linear' e he.out
#align trivialization_linear trivialization_linear

theorem continuous_on_coord_change (e e' : Trivialization F (π E)) [he : MemTrivializationAtlas R e]
    [he' : MemTrivializationAtlas R e'] :
    ContinuousOn (fun b => Trivialization.coordChangeL R e e' b : B → F →L[R] F) (e.baseSet ∩ e'.baseSet) :=
  TopologicalVectorBundle.continuous_on_coord_change' e e' he.out he'.out
#align continuous_on_coord_change continuous_on_coord_change

namespace Trivialization

/-- Forward map of `continuous_linear_equiv_at` (only propositionally equal),
  defined everywhere (`0` outside domain). -/
@[simps (config := { fullyApplied := false }) apply]
def continuousLinearMapAt (e : Trivialization F (π E)) [e.is_linear R] (b : B) : E b →L[R] F :=
  { -- given explicitly to help `simps`
        e.linearMapAt
      R b with
    toFun := e.linearMapAt R b,
    cont := by
      dsimp
      rw [e.coe_linear_map_at b]
      refine' continuous_if_const _ (fun hb => _) fun _ => continuous_zero
      exact
        continuous_snd.comp
          (e.to_local_homeomorph.continuous_on.comp_continuous
            (TopologicalVectorBundle.total_space_mk_inducing R F E b).Continuous fun x => e.mem_source.mpr hb) }
#align trivialization.continuous_linear_map_at Trivialization.continuousLinearMapAt

/-- Backwards map of `continuous_linear_equiv_at`, defined everywhere. -/
@[simps (config := { fullyApplied := false }) apply]
def symmL (e : Trivialization F (π E)) [e.is_linear R] (b : B) : F →L[R] E b :=
  { -- given explicitly to help `simps`
        e.symmₗ
      R b with
    toFun := e.symm b,
    cont := by
      by_cases hb:b ∈ e.base_set
      · rw [(TopologicalVectorBundle.total_space_mk_inducing R F E b).continuous_iff]
        exact
          e.continuous_on_symm.comp_continuous (continuous_const.prod_mk continuous_id) fun x =>
            mk_mem_prod hb (mem_univ x)
        
      · refine' continuous_zero.congr fun x => (e.symm_apply_of_not_mem hb x).symm
         }
#align trivialization.symmL Trivialization.symmL

variable {R}

theorem symmL_continuous_linear_map_at (e : Trivialization F (π E)) [e.is_linear R] {b : B} (hb : b ∈ e.baseSet)
    (y : E b) : e.symmL R b (e.continuousLinearMapAt R b y) = y :=
  e.symmₗ_linear_map_at hb y
#align trivialization.symmL_continuous_linear_map_at Trivialization.symmL_continuous_linear_map_at

theorem continuous_linear_map_at_symmL (e : Trivialization F (π E)) [e.is_linear R] {b : B} (hb : b ∈ e.baseSet)
    (y : F) : e.continuousLinearMapAt R b (e.symmL R b y) = y :=
  e.linear_map_at_symmₗ hb y
#align trivialization.continuous_linear_map_at_symmL Trivialization.continuous_linear_map_at_symmL

variable (R)

/-- In a topological vector bundle, a trivialization in the fiber (which is a priori only linear)
is in fact a continuous linear equiv between the fibers and the model fiber. -/
@[simps (config := { fullyApplied := false }) apply symmApply]
def continuousLinearEquivAt (e : Trivialization F (π E)) [e.is_linear R] (b : B) (hb : b ∈ e.baseSet) : E b ≃L[R] F :=
  { -- given explicitly to help `simps`
          -- given explicitly to help `simps`
          e.toPretrivialization.linearEquivAt
      R b hb with
    toFun := fun y => (e (totalSpaceMk b y)).2, invFun := e.symm b,
    continuous_to_fun :=
      continuous_snd.comp
        (e.toLocalHomeomorph.ContinuousOn.comp_continuous
          (TopologicalVectorBundle.total_space_mk_inducing R F E b).Continuous fun x => e.mem_source.mpr hb),
    continuous_inv_fun := (e.symmL R b).Continuous }
#align trivialization.continuous_linear_equiv_at Trivialization.continuousLinearEquivAt

variable {R}

theorem coe_continuous_linear_equiv_at_eq (e : Trivialization F (π E)) [e.is_linear R] {b : B} (hb : b ∈ e.baseSet) :
    (e.continuousLinearEquivAt R b hb : E b → F) = e.continuousLinearMapAt R b :=
  (e.coe_linear_map_at_of_mem hb).symm
#align trivialization.coe_continuous_linear_equiv_at_eq Trivialization.coe_continuous_linear_equiv_at_eq

theorem symm_continuous_linear_equiv_at_eq (e : Trivialization F (π E)) [e.is_linear R] {b : B} (hb : b ∈ e.baseSet) :
    ((e.continuousLinearEquivAt R b hb).symm : F → E b) = e.symmL R b :=
  rfl
#align trivialization.symm_continuous_linear_equiv_at_eq Trivialization.symm_continuous_linear_equiv_at_eq

@[simp]
theorem continuous_linear_equiv_at_apply' (e : Trivialization F (π E)) [e.is_linear R] (x : TotalSpace E)
    (hx : x ∈ e.source) : e.continuousLinearEquivAt R x.proj (e.mem_source.1 hx) x.2 = (e x).2 := by
  cases x
  rfl
#align trivialization.continuous_linear_equiv_at_apply' Trivialization.continuous_linear_equiv_at_apply'

variable (R)

theorem apply_eq_prod_continuous_linear_equiv_at (e : Trivialization F (π E)) [e.is_linear R] (b : B)
    (hb : b ∈ e.baseSet) (z : E b) : e.toLocalHomeomorph ⟨b, z⟩ = (b, e.continuousLinearEquivAt R b hb z) := by
  ext
  · refine' e.coe_fst _
    rw [e.source_eq]
    exact hb
    
  · simp only [coe_coe, continuous_linear_equiv_at_apply]
    
#align trivialization.apply_eq_prod_continuous_linear_equiv_at Trivialization.apply_eq_prod_continuous_linear_equiv_at

variable {R}

theorem symm_apply_eq_mk_continuous_linear_equiv_at_symm (e : Trivialization F (π E)) [e.is_linear R] (b : B)
    (hb : b ∈ e.baseSet) (z : F) :
    e.toLocalHomeomorph.symm ⟨b, z⟩ = totalSpaceMk b ((e.continuousLinearEquivAt R b hb).symm z) := by
  have h : (b, z) ∈ e.to_local_homeomorph.target := by
    rw [e.target_eq]
    exact ⟨hb, mem_univ _⟩
  apply e.to_local_homeomorph.inj_on (e.to_local_homeomorph.map_target h)
  · simp only [e.source_eq, hb, mem_preimage]
    
  simp_rw [e.apply_eq_prod_continuous_linear_equiv_at R b hb, e.to_local_homeomorph.right_inv h,
    ContinuousLinearEquiv.apply_symm_apply]
#align
  trivialization.symm_apply_eq_mk_continuous_linear_equiv_at_symm Trivialization.symm_apply_eq_mk_continuous_linear_equiv_at_symm

theorem comp_continuous_linear_equiv_at_eq_coord_change (e e' : Trivialization F (π E)) [e.is_linear R] [e'.is_linear R]
    {b : B} (hb : b ∈ e.baseSet ∩ e'.baseSet) :
    (e.continuousLinearEquivAt R b hb.1).symm.trans (e'.continuousLinearEquivAt R b hb.2) = coordChangeL R e e' b := by
  ext v
  rw [coord_changeL_apply e e' hb]
  rfl
#align
  trivialization.comp_continuous_linear_equiv_at_eq_coord_change Trivialization.comp_continuous_linear_equiv_at_eq_coord_change

end Trivialization

namespace TrivialTopologicalVectorBundle

variable (R B F)

/-- Local trivialization for trivial bundle. -/
def trivialization : Trivialization F (π (Bundle.Trivial B F)) where
  toFun x := (x.fst, x.snd)
  invFun y := ⟨y.fst, y.snd⟩
  source := univ
  target := univ
  map_source' x h := mem_univ (x.fst, x.snd)
  map_target' y h := mem_univ ⟨y.fst, y.snd⟩
  left_inv' x h := Sigma.eq rfl rfl
  right_inv' x h := Prod.ext rfl rfl
  open_source := is_open_univ
  open_target := is_open_univ
  continuous_to_fun := by
    rw [← continuous_iff_continuous_on_univ, continuous_iff_le_induced]
    simp only [Prod.topologicalSpace, induced_inf, induced_compose]
    exact le_rfl
  continuous_inv_fun := by
    rw [← continuous_iff_continuous_on_univ, continuous_iff_le_induced]
    simp only [Bundle.TotalSpace.topologicalSpace, induced_inf, induced_compose]
    exact le_rfl
  baseSet := univ
  open_base_set := is_open_univ
  source_eq := rfl
  target_eq := by simp only [univ_prod_univ]
  proj_to_fun y hy := rfl
#align trivial_topological_vector_bundle.trivialization TrivialTopologicalVectorBundle.trivialization

instance trivialization.is_linear :
    (trivialization B F).is_linear R where linear x hx := ⟨fun y z => rfl, fun c y => rfl⟩
#align
  trivial_topological_vector_bundle.trivialization.is_linear TrivialTopologicalVectorBundle.trivialization.is_linear

variable {R}

theorem trivialization.coord_changeL (b : B) :
    (trivialization B F).coordChangeL R (trivialization B F) b = ContinuousLinearEquiv.refl R F := by
  ext v
  rw [Trivialization.coord_changeL_apply']
  exacts[rfl, ⟨mem_univ _, mem_univ _⟩]
#align
  trivial_topological_vector_bundle.trivialization.coord_changeL TrivialTopologicalVectorBundle.trivialization.coord_changeL

@[simp]
theorem trivialization_source : (trivialization B F).source = univ :=
  rfl
#align trivial_topological_vector_bundle.trivialization_source TrivialTopologicalVectorBundle.trivialization_source

@[simp]
theorem trivialization_target : (trivialization B F).target = univ :=
  rfl
#align trivial_topological_vector_bundle.trivialization_target TrivialTopologicalVectorBundle.trivialization_target

instance topologicalVectorBundle : TopologicalVectorBundle R F (Bundle.Trivial B F) where
  trivializationAtlas := {TrivialTopologicalVectorBundle.trivialization B F}
  trivialization_linear' := by
    intro e he
    rw [mem_singleton_iff] at he
    subst he
    infer_instance
  trivializationAt x := TrivialTopologicalVectorBundle.trivialization B F
  mem_base_set_trivialization_at := mem_univ
  trivialization_mem_atlas x := mem_singleton _
  total_space_mk_inducing b :=
    ⟨by
      have : (fun x : trivial B F b => x) = @id F := by
        ext x
        rfl
      simp only [total_space.topological_space, induced_inf, induced_compose, Function.comp, total_space.proj,
        induced_const, top_inf_eq, trivial.proj_snd, id.def, trivial.topological_space, this, induced_id]⟩
  continuous_on_coord_change' := by
    intro e e' he he'
    rw [mem_singleton_iff] at he he'
    subst he
    subst he'
    simp_rw [Trivialization.coordChangeL]
    exact continuous_const.continuous_on
#align
  trivial_topological_vector_bundle.topological_vector_bundle TrivialTopologicalVectorBundle.topologicalVectorBundle

end TrivialTopologicalVectorBundle

-- Not registered as an instance because of a metavariable.
theorem is_topological_vector_bundle_is_topological_fiber_bundle : IsTopologicalFiberBundle F (@TotalSpace.proj B E) :=
  fun x => ⟨trivializationAt R F E x, mem_base_set_trivialization_at R F E x⟩
#align is_topological_vector_bundle_is_topological_fiber_bundle is_topological_vector_bundle_is_topological_fiber_bundle

include R F

namespace TopologicalVectorBundle

theorem continuous_total_space_mk (x : B) : Continuous (@totalSpaceMk B E x) :=
  (TopologicalVectorBundle.total_space_mk_inducing R F E x).Continuous
#align topological_vector_bundle.continuous_total_space_mk TopologicalVectorBundle.continuous_total_space_mk

variable (R B F)

@[continuity]
theorem continuous_proj : Continuous (@TotalSpace.proj B E) := by
  apply @IsTopologicalFiberBundle.continuous_proj B F
  apply @is_topological_vector_bundle_is_topological_fiber_bundle R
#align topological_vector_bundle.continuous_proj TopologicalVectorBundle.continuous_proj

end TopologicalVectorBundle

/-! ### Constructing topological vector bundles -/


variable (R B F)

/-- Analogous construction of `topological_fiber_bundle_core` for vector bundles. This
construction gives a way to construct vector bundles from a structure registering how
trivialization changes act on fibers. -/
structure TopologicalVectorBundleCore (ι : Type _) where
  baseSet : ι → Set B
  is_open_base_set : ∀ i, IsOpen (base_set i)
  indexAt : B → ι
  mem_base_set_at : ∀ x, x ∈ base_set (index_at x)
  coordChange : ι → ι → B → F →L[R] F
  coord_change_self : ∀ i, ∀ x ∈ base_set i, ∀ v, coord_change i i x v = v
  coord_change_continuous : ∀ i j, ContinuousOn (coord_change i j) (base_set i ∩ base_set j)
  coord_change_comp :
    ∀ i j k,
      ∀ x ∈ base_set i ∩ base_set j ∩ base_set k,
        ∀ v, (coord_change j k x) (coord_change i j x v) = coord_change i k x v
#align topological_vector_bundle_core TopologicalVectorBundleCore

/-- The trivial topological vector bundle core, in which all the changes of coordinates are the
identity. -/
def trivialTopologicalVectorBundleCore (ι : Type _) [Inhabited ι] : TopologicalVectorBundleCore R B F ι where
  baseSet ι := univ
  is_open_base_set i := is_open_univ
  indexAt := default
  mem_base_set_at x := mem_univ x
  coordChange i j x := ContinuousLinearMap.id R F
  coord_change_self i x hx v := rfl
  coord_change_comp i j k x hx v := rfl
  coord_change_continuous i j := continuous_on_const
#align trivial_topological_vector_bundle_core trivialTopologicalVectorBundleCore

instance (ι : Type _) [Inhabited ι] : Inhabited (TopologicalVectorBundleCore R B F ι) :=
  ⟨trivialTopologicalVectorBundleCore R B F ι⟩

namespace TopologicalVectorBundleCore

variable {R B F} {ι : Type _} (Z : TopologicalVectorBundleCore R B F ι)

/-- Natural identification to a `topological_fiber_bundle_core`. -/
def toTopologicalFiberBundleCore : TopologicalFiberBundleCore ι B F :=
  { Z with coordChange := fun i j b => Z.coordChange i j b,
    coord_change_continuous := fun i j =>
      isBoundedBilinearMapApply.Continuous.comp_continuous_on
        ((Z.coord_change_continuous i j).prod_map continuous_on_id) }
#align
  topological_vector_bundle_core.to_topological_fiber_bundle_core TopologicalVectorBundleCore.toTopologicalFiberBundleCore

instance toTopologicalFiberBundleCoreCoe :
    Coe (TopologicalVectorBundleCore R B F ι) (TopologicalFiberBundleCore ι B F) :=
  ⟨toTopologicalFiberBundleCore⟩
#align
  topological_vector_bundle_core.to_topological_fiber_bundle_core_coe TopologicalVectorBundleCore.toTopologicalFiberBundleCoreCoe

include Z

theorem coord_change_linear_comp (i j k : ι) :
    ∀ x ∈ Z.baseSet i ∩ Z.baseSet j ∩ Z.baseSet k,
      (Z.coordChange j k x).comp (Z.coordChange i j x) = Z.coordChange i k x :=
  fun x hx => by
  ext v
  exact Z.coord_change_comp i j k x hx v
#align topological_vector_bundle_core.coord_change_linear_comp TopologicalVectorBundleCore.coord_change_linear_comp

/-- The index set of a topological vector bundle core, as a convenience function for dot notation -/
@[nolint unused_arguments has_nonempty_instance]
def Index :=
  ι
#align topological_vector_bundle_core.index TopologicalVectorBundleCore.Index

/-- The base space of a topological vector bundle core, as a convenience function for dot notation-/
@[nolint unused_arguments, reducible]
def Base :=
  B
#align topological_vector_bundle_core.base TopologicalVectorBundleCore.Base

/-- The fiber of a topological vector bundle core, as a convenience function for dot notation and
typeclass inference -/
@[nolint unused_arguments has_nonempty_instance]
def Fiber : B → Type _ :=
  Z.toTopologicalFiberBundleCore.Fiber
#align topological_vector_bundle_core.fiber TopologicalVectorBundleCore.Fiber

instance topologicalSpaceFiber (x : B) : TopologicalSpace (Z.Fiber x) := by
  delta_instance topological_vector_bundle_core.fiber
#align topological_vector_bundle_core.topological_space_fiber TopologicalVectorBundleCore.topologicalSpaceFiber

instance addCommMonoidFiber : ∀ x : B, AddCommMonoid (Z.Fiber x) := by
  dsimp [TopologicalVectorBundleCore.Fiber] <;> delta_instance topological_fiber_bundle_core.fiber
#align topological_vector_bundle_core.add_comm_monoid_fiber TopologicalVectorBundleCore.addCommMonoidFiber

instance moduleFiber : ∀ x : B, Module R (Z.Fiber x) := by
  dsimp [TopologicalVectorBundleCore.Fiber] <;> delta_instance topological_fiber_bundle_core.fiber
#align topological_vector_bundle_core.module_fiber TopologicalVectorBundleCore.moduleFiber

instance addCommGroupFiber [AddCommGroup F] : ∀ x : B, AddCommGroup (Z.Fiber x) := by
  dsimp [TopologicalVectorBundleCore.Fiber] <;> delta_instance topological_fiber_bundle_core.fiber
#align topological_vector_bundle_core.add_comm_group_fiber TopologicalVectorBundleCore.addCommGroupFiber

/-- The projection from the total space of a topological fiber bundle core, on its base. -/
@[reducible, simp, mfld_simps]
def proj : TotalSpace Z.Fiber → B :=
  total_space.proj
#align topological_vector_bundle_core.proj TopologicalVectorBundleCore.proj

/-- The total space of the topological vector bundle, as a convenience function for dot notation.
It is by definition equal to `bundle.total_space Z.fiber`, a.k.a. `Σ x, Z.fiber x` but with a
different name for typeclass inference. -/
@[nolint unused_arguments, reducible]
def TotalSpace :=
  Bundle.TotalSpace Z.Fiber
#align topological_vector_bundle_core.total_space TopologicalVectorBundleCore.TotalSpace

/-- Local homeomorphism version of the trivialization change. -/
def trivChange (i j : ι) : LocalHomeomorph (B × F) (B × F) :=
  TopologicalFiberBundleCore.trivChange (↑Z) i j
#align topological_vector_bundle_core.triv_change TopologicalVectorBundleCore.trivChange

@[simp, mfld_simps]
theorem mem_triv_change_source (i j : ι) (p : B × F) :
    p ∈ (Z.trivChange i j).source ↔ p.1 ∈ Z.baseSet i ∩ Z.baseSet j :=
  TopologicalFiberBundleCore.mem_triv_change_source (↑Z) i j p
#align topological_vector_bundle_core.mem_triv_change_source TopologicalVectorBundleCore.mem_triv_change_source

variable (ι)

/-- Topological structure on the total space of a topological bundle created from core, designed so
that all the local trivialization are continuous. -/
instance toTopologicalSpace : TopologicalSpace Z.TotalSpace :=
  TopologicalFiberBundleCore.toTopologicalSpace ι ↑Z
#align topological_vector_bundle_core.to_topological_space TopologicalVectorBundleCore.toTopologicalSpace

variable {ι} (b : B) (a : F)

@[simp, mfld_simps]
theorem coe_coord_change (i j : ι) : Z.toTopologicalFiberBundleCore.coordChange i j b = Z.coordChange i j b :=
  rfl
#align topological_vector_bundle_core.coe_coord_change TopologicalVectorBundleCore.coe_coord_change

/-- One of the standard local trivializations of a vector bundle constructed from core, taken by
considering this in particular as a fiber bundle constructed from core. -/
def localTriv (i : ι) : Trivialization F (π Z.Fiber) := by
  dsimp [TopologicalVectorBundleCore.TotalSpace, TopologicalVectorBundleCore.Fiber] <;>
    exact Z.to_topological_fiber_bundle_core.local_triv i
#align topological_vector_bundle_core.local_triv TopologicalVectorBundleCore.localTriv

/-- The standard local trivializations of a vector bundle constructed from core are linear. -/
instance localTriv.is_linear (i : ι) :
    (Z.localTriv i).is_linear
      R where linear x hx := by
    dsimp [TopologicalVectorBundleCore.localTriv] <;>
      exact
        { map_add := fun v w => by simp only [ContinuousLinearMap.map_add, mfld_simps],
          map_smul := fun r v => by simp only [ContinuousLinearMap.map_smul, mfld_simps] }
#align topological_vector_bundle_core.local_triv.is_linear TopologicalVectorBundleCore.localTriv.is_linear

variable (i j : ι)

@[simp, mfld_simps]
theorem mem_local_triv_source (p : Z.TotalSpace) : p ∈ (Z.localTriv i).source ↔ p.1 ∈ Z.baseSet i := by
  dsimp [TopologicalVectorBundleCore.Fiber] <;> exact Iff.rfl
#align topological_vector_bundle_core.mem_local_triv_source TopologicalVectorBundleCore.mem_local_triv_source

@[simp, mfld_simps]
theorem base_set_at : Z.baseSet i = (Z.localTriv i).baseSet :=
  rfl
#align topological_vector_bundle_core.base_set_at TopologicalVectorBundleCore.base_set_at

@[simp, mfld_simps]
theorem local_triv_apply (p : Z.TotalSpace) : (Z.localTriv i) p = ⟨p.1, Z.coordChange (Z.indexAt p.1) i p.1 p.2⟩ :=
  rfl
#align topological_vector_bundle_core.local_triv_apply TopologicalVectorBundleCore.local_triv_apply

@[simp, mfld_simps]
theorem mem_local_triv_target (p : B × F) : p ∈ (Z.localTriv i).target ↔ p.1 ∈ (Z.localTriv i).baseSet :=
  Z.toTopologicalFiberBundleCore.mem_local_triv_target i p
#align topological_vector_bundle_core.mem_local_triv_target TopologicalVectorBundleCore.mem_local_triv_target

@[simp, mfld_simps]
theorem local_triv_symm_fst (p : B × F) :
    (Z.localTriv i).toLocalHomeomorph.symm p = ⟨p.1, Z.coordChange i (Z.indexAt p.1) p.1 p.2⟩ :=
  rfl
#align topological_vector_bundle_core.local_triv_symm_fst TopologicalVectorBundleCore.local_triv_symm_fst

@[simp, mfld_simps]
theorem local_triv_symm_apply {b : B} (hb : b ∈ Z.baseSet i) (v : F) :
    (Z.localTriv i).symm b v = Z.coordChange i (Z.indexAt b) b v := by apply (Z.local_triv i).symmApply hb v
#align topological_vector_bundle_core.local_triv_symm_apply TopologicalVectorBundleCore.local_triv_symm_apply

@[simp, mfld_simps]
theorem local_triv_coord_change_eq {b : B} (hb : b ∈ Z.baseSet i ∩ Z.baseSet j) (v : F) :
    (Z.localTriv i).coordChangeL R (Z.localTriv j) b v = Z.coordChange i j b v := by
  rw [Trivialization.coord_changeL_apply', local_triv_symm_fst, local_triv_apply, coord_change_comp]
  exacts[⟨⟨hb.1, Z.mem_base_set_at b⟩, hb.2⟩, hb]
#align topological_vector_bundle_core.local_triv_coord_change_eq TopologicalVectorBundleCore.local_triv_coord_change_eq

/-- Preferred local trivialization of a vector bundle constructed from core, at a given point, as
a bundle trivialization -/
def localTrivAt (b : B) : Trivialization F (π Z.Fiber) :=
  Z.localTriv (Z.indexAt b)
#align topological_vector_bundle_core.local_triv_at TopologicalVectorBundleCore.localTrivAt

@[simp, mfld_simps]
theorem local_triv_at_def : Z.localTriv (Z.indexAt b) = Z.localTrivAt b :=
  rfl
#align topological_vector_bundle_core.local_triv_at_def TopologicalVectorBundleCore.local_triv_at_def

@[simp, mfld_simps]
theorem mem_source_at : (⟨b, a⟩ : Z.TotalSpace) ∈ (Z.localTrivAt b).source := by
  rw [local_triv_at, mem_local_triv_source]
  exact Z.mem_base_set_at b
#align topological_vector_bundle_core.mem_source_at TopologicalVectorBundleCore.mem_source_at

@[simp, mfld_simps]
theorem local_triv_at_apply (p : Z.TotalSpace) : (Z.localTrivAt p.1) p = ⟨p.1, p.2⟩ :=
  TopologicalFiberBundleCore.local_triv_at_apply Z p
#align topological_vector_bundle_core.local_triv_at_apply TopologicalVectorBundleCore.local_triv_at_apply

@[simp, mfld_simps]
theorem local_triv_at_apply_mk (b : B) (a : F) : (Z.localTrivAt b) ⟨b, a⟩ = ⟨b, a⟩ :=
  Z.local_triv_at_apply _
#align topological_vector_bundle_core.local_triv_at_apply_mk TopologicalVectorBundleCore.local_triv_at_apply_mk

@[simp, mfld_simps]
theorem mem_local_triv_at_base_set : b ∈ (Z.localTrivAt b).baseSet :=
  TopologicalFiberBundleCore.mem_local_triv_at_base_set Z b
#align topological_vector_bundle_core.mem_local_triv_at_base_set TopologicalVectorBundleCore.mem_local_triv_at_base_set

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance : TopologicalVectorBundle R F Z.Fiber where
  total_space_mk_inducing b :=
    ⟨by
      refine' le_antisymm _ fun s h => _
      · rw [← continuous_iff_le_induced]
        exact TopologicalFiberBundleCore.continuous_total_space_mk Z b
        
      · refine'
          is_open_induced_iff.mpr
            ⟨(Z.local_triv_at b).source ∩ Z.local_triv_at b ⁻¹' (Z.local_triv_at b).baseSet ×ˢ s,
              (continuous_on_open_iff (Z.local_triv_at b).open_source).mp (Z.local_triv_at b).continuous_to_fun _
                ((Z.local_triv_at b).open_base_set.Prod h),
              _⟩
        rw [preimage_inter, ← preimage_comp, Function.comp]
        simp only [total_space_mk]
        refine' ext_iff.mpr fun a => ⟨fun ha => _, fun ha => ⟨Z.mem_base_set_at b, _⟩⟩
        · simp only [mem_prod, mem_preimage, mem_inter_iff, local_triv_at_apply_mk] at ha
          exact ha.2.2
          
        · simp only [mem_prod, mem_preimage, mem_inter_iff, local_triv_at_apply_mk]
          exact ⟨Z.mem_base_set_at b, ha⟩
          
        ⟩
  trivializationAtlas := Set.range Z.localTriv
  trivialization_linear' := by
    rintro _ ⟨i, rfl⟩
    infer_instance
  trivializationAt := Z.localTrivAt
  mem_base_set_trivialization_at := Z.mem_base_set_at
  trivialization_mem_atlas b := ⟨Z.indexAt b, rfl⟩
  continuous_on_coord_change' := by
    rintro _ _ ⟨i, rfl⟩ ⟨i', rfl⟩
    refine' (Z.coord_change_continuous i i').congr fun b hb => _
    ext v
    simp_rw [ContinuousLinearEquiv.coe_coe, Z.local_triv_coord_change_eq i i' hb]

/-- The projection on the base of a topological vector bundle created from core is continuous -/
@[continuity]
theorem continuous_proj : Continuous Z.proj :=
  TopologicalFiberBundleCore.continuous_proj Z
#align topological_vector_bundle_core.continuous_proj TopologicalVectorBundleCore.continuous_proj

/-- The projection on the base of a topological vector bundle created from core is an open map -/
theorem is_open_map_proj : IsOpenMap Z.proj :=
  TopologicalFiberBundleCore.is_open_map_proj Z
#align topological_vector_bundle_core.is_open_map_proj TopologicalVectorBundleCore.is_open_map_proj

end TopologicalVectorBundleCore

end

/-! ### Topological vector prebundle -/


section

variable [NontriviallyNormedField R] [∀ x, AddCommMonoid (E x)] [∀ x, Module R (E x)] [NormedAddCommGroup F]
  [NormedSpace R F] [TopologicalSpace B]

open TopologicalSpace

open TopologicalVectorBundle

/- ./././Mathport/Syntax/Translate/Basic.lean:610:2: warning: expanding binder collection (e e' «expr ∈ » pretrivialization_atlas) -/
/-- This structure permits to define a vector bundle when trivializations are given as local
equivalences but there is not yet a topology on the total space or the fibers.
The total space is hence given a topology in such a way that there is a fiber bundle structure for
which the local equivalences are also local homeomorphisms and hence vector bundle trivializations.
The topology on the fibers is induced from the one on the total space.

The field `exists_coord_change` is stated as an existential statement (instead of 3 separate
fields), since it depends on propositional information (namely `e e' ∈ pretrivialization_atlas`).
This makes it inconvenient to explicitly define a `coord_change` function when constructing a
`topological_vector_prebundle`. -/
@[nolint has_nonempty_instance]
structure TopologicalVectorPrebundle where
  pretrivializationAtlas : Set (Pretrivialization F (π E))
  pretrivialization_linear' : ∀ (e : Pretrivialization F (π E)) (he : e ∈ pretrivialization_atlas), e.is_linear R
  pretrivializationAt : B → Pretrivialization F (π E)
  mem_base_pretrivialization_at : ∀ x : B, x ∈ (pretrivialization_at x).baseSet
  pretrivialization_mem_atlas : ∀ x : B, pretrivialization_at x ∈ pretrivialization_atlas
  exists_coord_change :
    ∀ (e e') (_ : e ∈ pretrivialization_atlas) (_ : e' ∈ pretrivialization_atlas),
      ∃ f : B → F →L[R] F,
        ContinuousOn f (e.baseSet ∩ e'.baseSet) ∧
          ∀ (b : B) (hb : b ∈ e.baseSet ∩ e'.baseSet) (v : F), f b v = (e' (totalSpaceMk b (e.symm b v))).2
#align topological_vector_prebundle TopologicalVectorPrebundle

namespace TopologicalVectorPrebundle

variable {R E F}

/-- A randomly chosen coordinate change on a `topological_vector_prebundle`, given by
  the field `exists_coord_change`. -/
def coordChange (a : TopologicalVectorPrebundle R F E) {e e' : Pretrivialization F (π E)}
    (he : e ∈ a.pretrivializationAtlas) (he' : e' ∈ a.pretrivializationAtlas) (b : B) : F →L[R] F :=
  Classical.choose (a.exists_coord_change e he e' he') b
#align topological_vector_prebundle.coord_change TopologicalVectorPrebundle.coordChange

theorem continuous_on_coord_change (a : TopologicalVectorPrebundle R F E) {e e' : Pretrivialization F (π E)}
    (he : e ∈ a.pretrivializationAtlas) (he' : e' ∈ a.pretrivializationAtlas) :
    ContinuousOn (a.coordChange he he') (e.baseSet ∩ e'.baseSet) :=
  (Classical.choose_spec (a.exists_coord_change e he e' he')).1
#align topological_vector_prebundle.continuous_on_coord_change TopologicalVectorPrebundle.continuous_on_coord_change

theorem coord_change_apply (a : TopologicalVectorPrebundle R F E) {e e' : Pretrivialization F (π E)}
    (he : e ∈ a.pretrivializationAtlas) (he' : e' ∈ a.pretrivializationAtlas) {b : B} (hb : b ∈ e.baseSet ∩ e'.baseSet)
    (v : F) : a.coordChange he he' b v = (e' (totalSpaceMk b (e.symm b v))).2 :=
  (Classical.choose_spec (a.exists_coord_change e he e' he')).2 b hb v
#align topological_vector_prebundle.coord_change_apply TopologicalVectorPrebundle.coord_change_apply

theorem mk_coord_change (a : TopologicalVectorPrebundle R F E) {e e' : Pretrivialization F (π E)}
    (he : e ∈ a.pretrivializationAtlas) (he' : e' ∈ a.pretrivializationAtlas) {b : B} (hb : b ∈ e.baseSet ∩ e'.baseSet)
    (v : F) : (b, a.coordChange he he' b v) = e' (totalSpaceMk b (e.symm b v)) := by
  ext
  · rw [e.mk_symm hb.1 v, e'.coe_fst', e.proj_symm_apply' hb.1]
    rw [e.proj_symm_apply' hb.1]
    exact hb.2
    
  · exact a.coord_change_apply he he' hb v
    
#align topological_vector_prebundle.mk_coord_change TopologicalVectorPrebundle.mk_coord_change

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- Natural identification of `topological_vector_prebundle` as a `topological_fiber_prebundle`. -/
def toTopologicalFiberPrebundle (a : TopologicalVectorPrebundle R F E) :
    TopologicalFiberPrebundle F (@TotalSpace.proj B E) :=
  { a with pretrivializationAtlas := a.pretrivializationAtlas, pretrivializationAt := a.pretrivializationAt,
    pretrivialization_mem_atlas := a.pretrivialization_mem_atlas,
    continuous_triv_change := by
      intro e he e' he'
      have :=
        is_bounded_bilinear_map_apply.continuous.comp_continuous_on
          ((a.continuous_on_coord_change he' he).prod_map continuous_on_id)
      have H :
        e'.to_local_equiv.target ∩ e'.to_local_equiv.symm ⁻¹' e.to_local_equiv.source =
          (e'.base_set ∩ e.base_set) ×ˢ univ :=
        by
        rw [e'.target_eq, e.source_eq]
        ext ⟨b, f⟩
        simp (config := { contextual := true }) only [-total_space.proj, and_congr_right_iff, e'.proj_symm_apply',
          iff_self_iff, imp_true_iff, mfld_simps]
      rw [H]
      refine' (continuous_on_fst.prod this).congr _
      rintro ⟨b, f⟩ ⟨hb, -⟩
      dsimp only [Function.comp, Prod.map]
      rw [a.mk_coord_change _ _ hb, e'.mk_symm hb.1]
      rfl }
#align
  topological_vector_prebundle.to_topological_fiber_prebundle TopologicalVectorPrebundle.toTopologicalFiberPrebundle

/-- Topology on the total space that will make the prebundle into a bundle. -/
def totalSpaceTopology (a : TopologicalVectorPrebundle R F E) : TopologicalSpace (TotalSpace E) :=
  a.toTopologicalFiberPrebundle.totalSpaceTopology
#align topological_vector_prebundle.total_space_topology TopologicalVectorPrebundle.totalSpaceTopology

/-- Promotion from a `trivialization` in the `pretrivialization_atlas` of a
`topological_vector_prebundle` to a `trivialization`. -/
def trivializationOfMemPretrivializationAtlas (a : TopologicalVectorPrebundle R F E) {e : Pretrivialization F (π E)}
    (he : e ∈ a.pretrivializationAtlas) : @Trivialization B F _ _ _ a.totalSpaceTopology (π E) :=
  a.toTopologicalFiberPrebundle.trivializationOfMemPretrivializationAtlas he
#align
  topological_vector_prebundle.trivialization_of_mem_pretrivialization_atlas TopologicalVectorPrebundle.trivializationOfMemPretrivializationAtlas

theorem linear_of_mem_pretrivialization_atlas (a : TopologicalVectorPrebundle R F E) {e : Pretrivialization F (π E)}
    (he : e ∈ a.pretrivializationAtlas) :
    @Trivialization.IsLinear R B F _ _ _ _ a.totalSpaceTopology _ _ _ _
      (trivializationOfMemPretrivializationAtlas a he) :=
  { linear := (a.pretrivialization_linear' e he).linear }
#align
  topological_vector_prebundle.linear_of_mem_pretrivialization_atlas TopologicalVectorPrebundle.linear_of_mem_pretrivialization_atlas

variable (a : TopologicalVectorPrebundle R F E)

theorem mem_trivialization_at_source (b : B) (x : E b) : totalSpaceMk b x ∈ (a.pretrivializationAt b).source := by
  simp only [(a.pretrivialization_at b).source_eq, mem_preimage, total_space.proj]
  exact a.mem_base_pretrivialization_at b
#align topological_vector_prebundle.mem_trivialization_at_source TopologicalVectorPrebundle.mem_trivialization_at_source

@[simp]
theorem total_space_mk_preimage_source (b : B) : totalSpaceMk b ⁻¹' (a.pretrivializationAt b).source = univ := by
  apply eq_univ_of_univ_subset
  rw [(a.pretrivialization_at b).source_eq, ← preimage_comp, Function.comp]
  simp only [total_space.proj]
  rw [preimage_const_of_mem _]
  exact a.mem_base_pretrivialization_at b
#align
  topological_vector_prebundle.total_space_mk_preimage_source TopologicalVectorPrebundle.total_space_mk_preimage_source

/-- Topology on the fibers `E b` induced by the map `E b → E.total_space`. -/
def fiberTopology (b : B) : TopologicalSpace (E b) :=
  TopologicalSpace.induced (totalSpaceMk b) a.totalSpaceTopology
#align topological_vector_prebundle.fiber_topology TopologicalVectorPrebundle.fiberTopology

@[continuity]
theorem inducing_total_space_mk (b : B) : @Inducing _ _ (a.fiberTopology b) a.totalSpaceTopology (totalSpaceMk b) := by
  letI := a.total_space_topology
  letI := a.fiber_topology b
  exact ⟨rfl⟩
#align topological_vector_prebundle.inducing_total_space_mk TopologicalVectorPrebundle.inducing_total_space_mk

@[continuity]
theorem continuous_total_space_mk (b : B) : @Continuous _ _ (a.fiberTopology b) a.totalSpaceTopology (totalSpaceMk b) :=
  by
  letI := a.total_space_topology
  letI := a.fiber_topology b
  exact (a.inducing_total_space_mk b).Continuous
#align topological_vector_prebundle.continuous_total_space_mk TopologicalVectorPrebundle.continuous_total_space_mk

/-- Make a `topological_vector_bundle` from a `topological_vector_prebundle`.  Concretely this means
that, given a `topological_vector_prebundle` structure for a sigma-type `E` -- which consists of a
number of "pretrivializations" identifying parts of `E` with product spaces `U × F` -- one
establishes that for the topology constructed on the sigma-type using
`topological_vector_prebundle.total_space_topology`, these "pretrivializations" are actually
"trivializations" (i.e., homeomorphisms with respect to the constructed topology). -/
def toTopologicalVectorBundle : @TopologicalVectorBundle R _ F E _ _ _ _ _ _ a.totalSpaceTopology a.fiberTopology where
  total_space_mk_inducing := a.inducing_total_space_mk
  trivializationAtlas :=
    { e | ∃ (e₀ : _)(he₀ : e₀ ∈ a.pretrivializationAtlas), e = a.trivializationOfMemPretrivializationAtlas he₀ }
  trivialization_linear' := by
    rintro _ ⟨e, he, rfl⟩
    apply linear_of_mem_pretrivialization_atlas
  trivializationAt x := a.trivializationOfMemPretrivializationAtlas (a.pretrivialization_mem_atlas x)
  mem_base_set_trivialization_at := a.mem_base_pretrivialization_at
  trivialization_mem_atlas x := ⟨_, a.pretrivialization_mem_atlas x, rfl⟩
  continuous_on_coord_change' := by
    rintro _ _ ⟨e, he, rfl⟩ ⟨e', he', rfl⟩
    refine' (a.continuous_on_coord_change he he').congr _
    intro b hb
    ext v
    rw [a.coord_change_apply he he' hb v, ContinuousLinearEquiv.coe_coe, Trivialization.coord_changeL_apply]
    exacts[rfl, hb]
#align topological_vector_prebundle.to_topological_vector_bundle TopologicalVectorPrebundle.toTopologicalVectorBundle

end TopologicalVectorPrebundle

end

