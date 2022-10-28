/-
Copyright (c) 2020 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel, Floris van Doorn
-/
import Mathbin.Geometry.Manifold.SmoothManifoldWithCorners
import Mathbin.Geometry.Manifold.LocalInvariantProperties

/-!
# Smooth functions between smooth manifolds

We define `Cⁿ` functions between smooth manifolds, as functions which are `Cⁿ` in charts, and prove
basic properties of these notions.

## Main definitions and statements

Let `M ` and `M'` be two smooth manifolds, with respect to model with corners `I` and `I'`. Let
`f : M → M'`.

* `cont_mdiff_within_at I I' n f s x` states that the function `f` is `Cⁿ` within the set `s`
  around the point `x`.
* `cont_mdiff_at I I' n f x` states that the function `f` is `Cⁿ` around `x`.
* `cont_mdiff_on I I' n f s` states that the function `f` is `Cⁿ` on the set `s`
* `cont_mdiff I I' n f` states that the function `f` is `Cⁿ`.
* `cont_mdiff_on.comp` gives the invariance of the `Cⁿ` property under composition
* `cont_mdiff_iff_cont_diff` states that, for functions between vector spaces,
  manifold-smoothness is equivalent to usual smoothness.

We also give many basic properties of smooth functions between manifolds, following the API of
smooth functions between vector spaces.

## Implementation details

Many properties follow for free from the corresponding properties of functions in vector spaces,
as being `Cⁿ` is a local property invariant under the smooth groupoid. We take advantage of the
general machinery developed in `local_invariant_properties.lean` to get these properties
automatically. For instance, the fact that being `Cⁿ` does not depend on the chart one considers
is given by `lift_prop_within_at_indep_chart`.

For this to work, the definition of `cont_mdiff_within_at` and friends has to
follow definitionally the setup of local invariant properties. Still, we recast the definition
in terms of extended charts in `cont_mdiff_on_iff` and `cont_mdiff_iff`.
-/


open Set Function Filter ChartedSpace SmoothManifoldWithCorners

open TopologicalSpace Manifold

/-! ### Definition of smooth functions between manifolds -/


variable {𝕜 : Type _} [NontriviallyNormedField 𝕜]
  -- declare a smooth manifold `M` over the pair `(E, H)`.
  {E : Type _}
  [NormedAddCommGroup E] [NormedSpace 𝕜 E] {H : Type _} [TopologicalSpace H] (I : ModelWithCorners 𝕜 E H) {M : Type _}
  [TopologicalSpace M] [ChartedSpace H M] [Is : SmoothManifoldWithCorners I M]
  -- declare a smooth manifold `M'` over the pair `(E', H')`.
  {E' : Type _}
  [NormedAddCommGroup E'] [NormedSpace 𝕜 E'] {H' : Type _} [TopologicalSpace H'] (I' : ModelWithCorners 𝕜 E' H')
  {M' : Type _} [TopologicalSpace M'] [ChartedSpace H' M'] [I's : SmoothManifoldWithCorners I' M']
  -- declare a manifold `M''` over the pair `(E'', H'')`.
  {E'' : Type _}
  [NormedAddCommGroup E''] [NormedSpace 𝕜 E''] {H'' : Type _} [TopologicalSpace H''] {I'' : ModelWithCorners 𝕜 E'' H''}
  {M'' : Type _} [TopologicalSpace M''] [ChartedSpace H'' M'']
  -- declare a smooth manifold `N` over the pair `(F, G)`.
  {F : Type _}
  [NormedAddCommGroup F] [NormedSpace 𝕜 F] {G : Type _} [TopologicalSpace G] {J : ModelWithCorners 𝕜 F G} {N : Type _}
  [TopologicalSpace N] [ChartedSpace G N] [Js : SmoothManifoldWithCorners J N]
  -- declare a smooth manifold `N'` over the pair `(F', G')`.
  {F' : Type _}
  [NormedAddCommGroup F'] [NormedSpace 𝕜 F'] {G' : Type _} [TopologicalSpace G'] {J' : ModelWithCorners 𝕜 F' G'}
  {N' : Type _} [TopologicalSpace N'] [ChartedSpace G' N'] [J's : SmoothManifoldWithCorners J' N']
  -- F'' is a normed space
  {F'' : Type _}
  [NormedAddCommGroup F''] [NormedSpace 𝕜 F'']
  -- declare functions, sets, points and smoothness indices
  {f f₁ : M → M'}
  {s s₁ t : Set M} {x : M} {m n : ℕ∞}

/-- Property in the model space of a model with corners of being `C^n` within at set at a point,
when read in the model vector space. This property will be lifted to manifolds to define smooth
functions between manifolds. -/
def ContDiffWithinAtProp (n : ℕ∞) (f : H → H') (s : Set H) (x : H) : Prop :=
  ContDiffWithinAt 𝕜 n (I' ∘ f ∘ I.symm) (I.symm ⁻¹' s ∩ Range I) (I x)

theorem cont_diff_within_at_prop_self_source {f : E → H'} {s : Set E} {x : E} :
    ContDiffWithinAtProp 𝓘(𝕜, E) I' n f s x ↔ ContDiffWithinAt 𝕜 n (I' ∘ f) s x := by
  simp_rw [ContDiffWithinAtProp, model_with_corners_self_coe, range_id, inter_univ]
  rfl

theorem cont_diff_within_at_prop_self {f : E → E'} {s : Set E} {x : E} :
    ContDiffWithinAtProp 𝓘(𝕜, E) 𝓘(𝕜, E') n f s x ↔ ContDiffWithinAt 𝕜 n f s x :=
  cont_diff_within_at_prop_self_source 𝓘(𝕜, E')

theorem cont_diff_within_at_prop_self_target {f : H → E'} {s : Set H} {x : H} :
    ContDiffWithinAtProp I 𝓘(𝕜, E') n f s x ↔ ContDiffWithinAt 𝕜 n (f ∘ I.symm) (I.symm ⁻¹' s ∩ Range I) (I x) :=
  Iff.rfl

/-- Being `Cⁿ` in the model space is a local property, invariant under smooth maps. Therefore,
it will lift nicely to manifolds. -/
theorem cont_diff_within_at_local_invariant_prop (n : ℕ∞) :
    (contDiffGroupoid ∞ I).LocalInvariantProp (contDiffGroupoid ∞ I') (ContDiffWithinAtProp I I' n) :=
  { IsLocal := by
      intro s x u f u_open xu
      have : I.symm ⁻¹' (s ∩ u) ∩ range I = I.symm ⁻¹' s ∩ range I ∩ I.symm ⁻¹' u := by
        simp only [inter_right_comm, preimage_inter]
      rw [ContDiffWithinAtProp, ContDiffWithinAtProp, this]
      symm
      apply cont_diff_within_at_inter
      have : u ∈ 𝓝 (I.symm (I x)) := by
        rw [ModelWithCorners.left_inv]
        exact IsOpen.mem_nhds u_open xu
      apply ContinuousAt.preimage_mem_nhds I.continuous_symm.continuous_at this,
    right_invariance' := by
      intro s x f e he hx h
      rw [ContDiffWithinAtProp] at h⊢
      have : I x = (I ∘ e.symm ∘ I.symm) (I (e x)) := by simp only [hx, mfld_simps]
      rw [this] at h
      have : I (e x) ∈ I.symm ⁻¹' e.target ∩ range I := by simp only [hx, mfld_simps]
      have := ((mem_groupoid_of_pregroupoid.2 he).2.ContDiffWithinAt this).ofLe le_top
      convert (h.comp' _ this).mono_of_mem _ using 1
      · ext y
        simp only [mfld_simps]
        
      refine'
        mem_nhds_within.mpr
          ⟨I.symm ⁻¹' e.target, e.open_target.preimage I.continuous_symm, by
            simp_rw [mem_preimage, I.left_inv, e.maps_to hx], _⟩
      mfld_set_tac,
    congr_of_forall := by
      intro s x f g h hx hf
      apply hf.congr
      · intro y hy
        simp only [mfld_simps] at hy
        simp only [h, hy, mfld_simps]
        
      · simp only [hx, mfld_simps]
        ,
    left_invariance' := by
      intro s x f e' he' hs hx h
      rw [ContDiffWithinAtProp] at h⊢
      have A : (I' ∘ f ∘ I.symm) (I x) ∈ I'.symm ⁻¹' e'.source ∩ range I' := by simp only [hx, mfld_simps]
      have := ((mem_groupoid_of_pregroupoid.2 he').1.ContDiffWithinAt A).ofLe le_top
      convert this.comp _ h _
      · ext y
        simp only [mfld_simps]
        
      · intro y hy
        simp only [mfld_simps] at hy
        simpa only [hy, mfld_simps] using hs hy.1
         }

theorem contDiffWithinAtPropMono (n : ℕ∞) ⦃s x t⦄ ⦃f : H → H'⦄ (hts : t ⊆ s) (h : ContDiffWithinAtProp I I' n f s x) :
    ContDiffWithinAtProp I I' n f t x := by
  apply h.mono fun y hy => _
  simp only [mfld_simps] at hy
  simp only [hy, hts _, mfld_simps]

theorem contDiffWithinAtPropId (x : H) : ContDiffWithinAtProp I I ∞ id Univ x := by
  simp [ContDiffWithinAtProp]
  have : ContDiffWithinAt 𝕜 ∞ id (range I) (I x) := cont_diff_id.cont_diff_at.cont_diff_within_at
  apply this.congr fun y hy => _
  · simp only [mfld_simps]
    
  · simp only [ModelWithCorners.right_inv I hy, mfld_simps]
    

/-- A function is `n` times continuously differentiable within a set at a point in a manifold if
it is continuous and it is `n` times continuously differentiable in this set around this point, when
read in the preferred chart at this point. -/
def ContMdiffWithinAt (n : ℕ∞) (f : M → M') (s : Set M) (x : M) :=
  LiftPropWithinAt (ContDiffWithinAtProp I I' n) f s x

/-- Abbreviation for `cont_mdiff_within_at I I' ⊤ f s x`. See also documentation for `smooth`.
-/
@[reducible]
def SmoothWithinAt (f : M → M') (s : Set M) (x : M) :=
  ContMdiffWithinAt I I' ⊤ f s x

/-- A function is `n` times continuously differentiable at a point in a manifold if
it is continuous and it is `n` times continuously differentiable around this point, when
read in the preferred chart at this point. -/
def ContMdiffAt (n : ℕ∞) (f : M → M') (x : M) :=
  ContMdiffWithinAt I I' n f Univ x

theorem cont_mdiff_at_iff {n : ℕ∞} {f : M → M'} {x : M} :
    ContMdiffAt I I' n f x ↔
      ContinuousAt f x ∧
        ContDiffWithinAt 𝕜 n (extChartAt I' (f x) ∘ f ∘ (extChartAt I x).symm) (Range I) (extChartAt I x x) :=
  lift_prop_at_iff.trans <| by
    rw [ContDiffWithinAtProp, preimage_univ, univ_inter]
    rfl

/-- Abbreviation for `cont_mdiff_at I I' ⊤ f x`. See also documentation for `smooth`. -/
@[reducible]
def SmoothAt (f : M → M') (x : M) :=
  ContMdiffAt I I' ⊤ f x

/-- A function is `n` times continuously differentiable in a set of a manifold if it is continuous
and, for any pair of points, it is `n` times continuously differentiable on this set in the charts
around these points. -/
def ContMdiffOn (n : ℕ∞) (f : M → M') (s : Set M) :=
  ∀ x ∈ s, ContMdiffWithinAt I I' n f s x

/-- Abbreviation for `cont_mdiff_on I I' ⊤ f s`. See also documentation for `smooth`. -/
@[reducible]
def SmoothOn (f : M → M') (s : Set M) :=
  ContMdiffOn I I' ⊤ f s

/-- A function is `n` times continuously differentiable in a manifold if it is continuous
and, for any pair of points, it is `n` times continuously differentiable in the charts
around these points. -/
def ContMdiff (n : ℕ∞) (f : M → M') :=
  ∀ x, ContMdiffAt I I' n f x

/-- Abbreviation for `cont_mdiff I I' ⊤ f`.
Short note to work with these abbreviations: a lemma of the form `cont_mdiff_foo.bar` will
apply fine to an assumption `smooth_foo` using dot notation or normal notation.
If the consequence `bar` of the lemma involves `cont_diff`, it is still better to restate
the lemma replacing `cont_diff` with `smooth` both in the assumption and in the conclusion,
to make it possible to use `smooth` consistently.
This also applies to `smooth_at`, `smooth_on` and `smooth_within_at`.-/
@[reducible]
def Smooth (f : M → M') :=
  ContMdiff I I' ⊤ f

/-! ### Basic properties of smooth functions between manifolds -/


variable {I I'}

theorem ContMdiff.smooth (h : ContMdiff I I' ⊤ f) : Smooth I I' f :=
  h

theorem Smooth.contMdiff (h : Smooth I I' f) : ContMdiff I I' ⊤ f :=
  h

theorem ContMdiffOn.smoothOn (h : ContMdiffOn I I' ⊤ f s) : SmoothOn I I' f s :=
  h

theorem SmoothOn.contMdiffOn (h : SmoothOn I I' f s) : ContMdiffOn I I' ⊤ f s :=
  h

theorem ContMdiffAt.smoothAt (h : ContMdiffAt I I' ⊤ f x) : SmoothAt I I' f x :=
  h

theorem SmoothAt.contMdiffAt (h : SmoothAt I I' f x) : ContMdiffAt I I' ⊤ f x :=
  h

theorem ContMdiffWithinAt.smoothWithinAt (h : ContMdiffWithinAt I I' ⊤ f s x) : SmoothWithinAt I I' f s x :=
  h

theorem SmoothWithinAt.contMdiffWithinAt (h : SmoothWithinAt I I' f s x) : ContMdiffWithinAt I I' ⊤ f s x :=
  h

theorem ContMdiff.contMdiffAt (h : ContMdiff I I' n f) : ContMdiffAt I I' n f x :=
  h x

theorem Smooth.smoothAt (h : Smooth I I' f) : SmoothAt I I' f x :=
  ContMdiff.contMdiffAt h

theorem cont_mdiff_within_at_univ : ContMdiffWithinAt I I' n f Univ x ↔ ContMdiffAt I I' n f x :=
  Iff.rfl

theorem smooth_within_at_univ : SmoothWithinAt I I' f Univ x ↔ SmoothAt I I' f x :=
  cont_mdiff_within_at_univ

theorem cont_mdiff_on_univ : ContMdiffOn I I' n f Univ ↔ ContMdiff I I' n f := by
  simp only [ContMdiffOn, ContMdiff, cont_mdiff_within_at_univ, forall_prop_of_true, mem_univ]

theorem smooth_on_univ : SmoothOn I I' f Univ ↔ Smooth I I' f :=
  cont_mdiff_on_univ

/-- One can reformulate smoothness within a set at a point as continuity within this set at this
point, and smoothness in the corresponding extended chart. -/
theorem cont_mdiff_within_at_iff :
    ContMdiffWithinAt I I' n f s x ↔
      ContinuousWithinAt f s x ∧
        ContDiffWithinAt 𝕜 n (extChartAt I' (f x) ∘ f ∘ (extChartAt I x).symm) ((extChartAt I x).symm ⁻¹' s ∩ Range I)
          (extChartAt I x x) :=
  Iff.rfl

/-- One can reformulate smoothness within a set at a point as continuity within this set at this
point, and smoothness in the corresponding extended chart. This form states smoothness of `f`
written in such a way that the set is restricted to lie within the domain/codomain of the
corresponding charts.
Even though this expression is more complicated than the one in `cont_mdiff_within_at_iff`, it is
a smaller set, but their germs at `ext_chart_at I x x` are equal. It is sometimes useful to rewrite
using this in the goal.
-/
theorem cont_mdiff_within_at_iff' :
    ContMdiffWithinAt I I' n f s x ↔
      ContinuousWithinAt f s x ∧
        ContDiffWithinAt 𝕜 n (extChartAt I' (f x) ∘ f ∘ (extChartAt I x).symm)
          ((extChartAt I x).Target ∩ (extChartAt I x).symm ⁻¹' (s ∩ f ⁻¹' (extChartAt I' (f x)).Source))
          (extChartAt I x x) :=
  by
  rw [cont_mdiff_within_at_iff, and_congr_right_iff]
  set e := extChartAt I x
  set e' := extChartAt I' (f x)
  refine' fun hc => cont_diff_within_at_congr_nhds _
  rw [← e.image_source_inter_eq', ← ext_chart_at_map_nhds_within_eq_image, ← ext_chart_at_map_nhds_within, inter_comm,
    nhds_within_inter_of_mem]
  exact hc (ext_chart_at_source_mem_nhds _ _)

/-- One can reformulate smoothness within a set at a point as continuity within this set at this
point, and smoothness in the corresponding extended chart in the target. -/
theorem cont_mdiff_within_at_iff_target :
    ContMdiffWithinAt I I' n f s x ↔
      ContinuousWithinAt f s x ∧ ContMdiffWithinAt I 𝓘(𝕜, E') n (extChartAt I' (f x) ∘ f) s x :=
  by
  simp_rw [ContMdiffWithinAt, lift_prop_within_at, ← and_assoc']
  have cont : ContinuousWithinAt f s x ∧ ContinuousWithinAt (extChartAt I' (f x) ∘ f) s x ↔ ContinuousWithinAt f s x :=
    by
    refine' ⟨fun h => h.1, fun h => ⟨h, _⟩⟩
    have h₂ := (chart_at H' (f x)).continuous_to_fun.ContinuousWithinAt (mem_chart_source _ _)
    refine' ((I'.continuous_at.comp_continuous_within_at h₂).comp' h).mono_of_mem _
    exact
      inter_mem self_mem_nhds_within
        (h.preimage_mem_nhds_within <| (chart_at _ _).open_source.mem_nhds <| mem_chart_source _ _)
  simp_rw [cont, ContDiffWithinAtProp, extChartAt, LocalEquiv.coe_trans, ModelWithCorners.to_local_equiv_coe,
    LocalHomeomorph.coe_coe, model_with_corners_self_coe, chart_at_self_eq, LocalHomeomorph.refl_apply, comp.left_id]

theorem smooth_within_at_iff :
    SmoothWithinAt I I' f s x ↔
      ContinuousWithinAt f s x ∧
        ContDiffWithinAt 𝕜 ∞ (extChartAt I' (f x) ∘ f ∘ (extChartAt I x).symm) ((extChartAt I x).symm ⁻¹' s ∩ Range I)
          (extChartAt I x x) :=
  cont_mdiff_within_at_iff

theorem smooth_within_at_iff_target :
    SmoothWithinAt I I' f s x ↔ ContinuousWithinAt f s x ∧ SmoothWithinAt I 𝓘(𝕜, E') (extChartAt I' (f x) ∘ f) s x :=
  cont_mdiff_within_at_iff_target

theorem cont_mdiff_at_iff_target {x : M} :
    ContMdiffAt I I' n f x ↔ ContinuousAt f x ∧ ContMdiffAt I 𝓘(𝕜, E') n (extChartAt I' (f x) ∘ f) x := by
  rw [ContMdiffAt, ContMdiffAt, cont_mdiff_within_at_iff_target, continuous_within_at_univ]

theorem smooth_at_iff_target {x : M} :
    SmoothAt I I' f x ↔ ContinuousAt f x ∧ SmoothAt I 𝓘(𝕜, E') (extChartAt I' (f x) ∘ f) x :=
  cont_mdiff_at_iff_target

include Is I's

/-- One can reformulate smoothness within a set at a point as continuity within this set at this
point, and smoothness in any chart containing that point. -/
theorem cont_mdiff_within_at_iff_of_mem_source {x' : M} {y : M'} (hx : x' ∈ (chartAt H x).Source)
    (hy : f x' ∈ (chartAt H' y).Source) :
    ContMdiffWithinAt I I' n f s x' ↔
      ContinuousWithinAt f s x' ∧
        ContDiffWithinAt 𝕜 n (extChartAt I' y ∘ f ∘ (extChartAt I x).symm) ((extChartAt I x).symm ⁻¹' s ∩ Range I)
          (extChartAt I x x') :=
  (cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_indep_chart
    (StructureGroupoid.chart_mem_maximal_atlas _ x) hx (StructureGroupoid.chart_mem_maximal_atlas _ y) hy

theorem cont_mdiff_within_at_iff_of_mem_source' {x' : M} {y : M'} (hx : x' ∈ (chartAt H x).Source)
    (hy : f x' ∈ (chartAt H' y).Source) :
    ContMdiffWithinAt I I' n f s x' ↔
      ContinuousWithinAt f s x' ∧
        ContDiffWithinAt 𝕜 n (extChartAt I' y ∘ f ∘ (extChartAt I x).symm)
          ((extChartAt I x).Target ∩ (extChartAt I x).symm ⁻¹' (s ∩ f ⁻¹' (extChartAt I' y).Source))
          (extChartAt I x x') :=
  by
  refine' (cont_mdiff_within_at_iff_of_mem_source hx hy).trans _
  rw [← ext_chart_at_source I] at hx
  rw [← ext_chart_at_source I'] at hy
  rw [and_congr_right_iff]
  set e := extChartAt I x
  set e' := extChartAt I' (f x)
  refine' fun hc => cont_diff_within_at_congr_nhds _
  rw [← e.image_source_inter_eq', ← ext_chart_at_map_nhds_within_eq_image' I x hx, ←
    ext_chart_at_map_nhds_within' I x hx, inter_comm, nhds_within_inter_of_mem]
  exact hc ((ext_chart_at_open_source _ _).mem_nhds hy)

theorem cont_mdiff_at_iff_of_mem_source {x' : M} {y : M'} (hx : x' ∈ (chartAt H x).Source)
    (hy : f x' ∈ (chartAt H' y).Source) :
    ContMdiffAt I I' n f x' ↔
      ContinuousAt f x' ∧
        ContDiffWithinAt 𝕜 n (extChartAt I' y ∘ f ∘ (extChartAt I x).symm) (Range I) (extChartAt I x x') :=
  (cont_mdiff_within_at_iff_of_mem_source hx hy).trans <| by rw [continuous_within_at_univ, preimage_univ, univ_inter]

omit Is

theorem cont_mdiff_within_at_iff_target_of_mem_source {x : M} {y : M'} (hy : f x ∈ (chartAt H' y).Source) :
    ContMdiffWithinAt I I' n f s x ↔
      ContinuousWithinAt f s x ∧ ContMdiffWithinAt I 𝓘(𝕜, E') n (extChartAt I' y ∘ f) s x :=
  by
  simp_rw [ContMdiffWithinAt]
  rw [(cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_indep_chart_target
      (chart_mem_maximal_atlas I' y) hy,
    and_congr_right]
  intro hf
  simp_rw [StructureGroupoid.lift_prop_within_at_self_target]
  simp_rw [((chart_at H' y).ContinuousAt hy).comp_continuous_within_at hf]
  rw [← ext_chart_at_source I'] at hy
  simp_rw [(ext_chart_at_continuous_at' I' _ hy).comp_continuous_within_at hf]
  rfl

theorem cont_mdiff_at_iff_target_of_mem_source {x : M} {y : M'} (hy : f x ∈ (chartAt H' y).Source) :
    ContMdiffAt I I' n f x ↔ ContinuousAt f x ∧ ContMdiffAt I 𝓘(𝕜, E') n (extChartAt I' y ∘ f) x := by
  rw [ContMdiffAt, cont_mdiff_within_at_iff_target_of_mem_source hy, continuous_within_at_univ, ContMdiffAt]
  infer_instance

omit I's

variable (I)

theorem ModelWithCorners.symm_continuous_within_at_comp_right_iff {X} [TopologicalSpace X] {f : H → X} {s : Set H}
    {x : H} : ContinuousWithinAt (f ∘ I.symm) (I.symm ⁻¹' s ∩ Range I) (I x) ↔ ContinuousWithinAt f s x := by
  refine' ⟨fun h => _, fun h => _⟩
  · have := h.comp I.continuous_within_at (maps_to_preimage _ _)
    simp_rw [preimage_inter, preimage_preimage, I.left_inv, preimage_id', preimage_range, inter_univ] at this
    rwa [Function.comp.assoc, I.symm_comp_self] at this
    
  · rw [← I.left_inv x] at h
    exact h.comp I.continuous_within_at_symm (inter_subset_left _ _)
    

variable {I}

theorem ext_chart_at_symm_continuous_within_at_comp_right_iff {X} [TopologicalSpace X] {f : M → X} {s : Set M}
    {x x' : M} :
    ContinuousWithinAt (f ∘ (extChartAt I x).symm) ((extChartAt I x).symm ⁻¹' s ∩ Range I) (extChartAt I x x') ↔
      ContinuousWithinAt (f ∘ (chartAt H x).symm) ((chartAt H x).symm ⁻¹' s) (chartAt H x x') :=
  by convert I.symm_continuous_within_at_comp_right_iff <;> rfl

include Is

theorem cont_mdiff_within_at_iff_source_of_mem_source {x' : M} (hx' : x' ∈ (chartAt H x).Source) :
    ContMdiffWithinAt I I' n f s x' ↔
      ContMdiffWithinAt 𝓘(𝕜, E) I' n (f ∘ (extChartAt I x).symm) ((extChartAt I x).symm ⁻¹' s ∩ Range I)
        (extChartAt I x x') :=
  by
  have h2x' := hx'
  rw [← ext_chart_at_source I] at h2x'
  simp_rw [ContMdiffWithinAt,
    (cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_indep_chart_source
      (chart_mem_maximal_atlas I x) hx',
    StructureGroupoid.lift_prop_within_at_self_source, ext_chart_at_symm_continuous_within_at_comp_right_iff,
    cont_diff_within_at_prop_self_source, ContDiffWithinAtProp, Function.comp, (chart_at H x).left_inv hx',
    (extChartAt I x).left_inv h2x']
  rfl

theorem cont_mdiff_at_iff_source_of_mem_source {x' : M} (hx' : x' ∈ (chartAt H x).Source) :
    ContMdiffAt I I' n f x' ↔
      ContMdiffWithinAt 𝓘(𝕜, E) I' n (f ∘ (extChartAt I x).symm) (Range I) (extChartAt I x x') :=
  by simp_rw [ContMdiffAt, cont_mdiff_within_at_iff_source_of_mem_source hx', preimage_univ, univ_inter]

theorem contMdiffAtExtChartAt' {x' : M} (h : x' ∈ (chartAt H x).Source) : ContMdiffAt I 𝓘(𝕜, E) n (extChartAt I x) x' :=
  by
  refine' (cont_mdiff_at_iff_of_mem_source h (mem_chart_source _ _)).mpr _
  rw [← ext_chart_at_source I] at h
  refine' ⟨ext_chart_at_continuous_at' _ _ h, _⟩
  refine' cont_diff_within_at_id.congr_of_eventually_eq _ _
  · refine' eventually_eq_of_mem (ext_chart_at_target_mem_nhds_within' I x h) fun x₂ hx₂ => _
    simp_rw [Function.comp_apply, (extChartAt I x).right_inv hx₂]
    rfl
    
  simp_rw [Function.comp_apply, (extChartAt I x).right_inv ((extChartAt I x).MapsTo h)]
  rfl

theorem contMdiffAtExtChartAt : ContMdiffAt I 𝓘(𝕜, E) n (extChartAt I x) x :=
  contMdiffAtExtChartAt' <| mem_chart_source H x

include I's

/-- If the set where you want `f` to be smooth lies entirely in a single chart, and `f` maps it
  into a single chart, the smoothness of `f` on that set can be expressed by purely looking in
  these charts.
  Note: this lemma uses `ext_chart_at I x '' s` instead of `(ext_chart_at I x).symm ⁻¹' s` to ensure
  that this set lies in `(ext_chart_at I x).target`. -/
theorem cont_mdiff_on_iff_of_subset_source {x : M} {y : M'} (hs : s ⊆ (chartAt H x).Source)
    (h2s : MapsTo f s (chartAt H' y).Source) :
    ContMdiffOn I I' n f s ↔
      ContinuousOn f s ∧ ContDiffOn 𝕜 n (extChartAt I' y ∘ f ∘ (extChartAt I x).symm) (extChartAt I x '' s) :=
  by
  constructor
  · refine' fun H => ⟨fun x hx => (H x hx).1, _⟩
    rintro _ ⟨x', hx', rfl⟩
    exact
      ((cont_mdiff_within_at_iff_of_mem_source (hs hx') (h2s.image_subset <| mem_image_of_mem f hx')).mp
              (H _ hx')).2.mono
        (maps_to_ext_chart_at I x hs).image_subset
    
  · rintro ⟨h1, h2⟩ x' hx'
    refine'
      (cont_mdiff_within_at_iff_of_mem_source (hs hx') (h2s.image_subset <| mem_image_of_mem f hx')).mpr
        ⟨h1.continuous_within_at hx', _⟩
    refine' (h2 _ <| mem_image_of_mem _ hx').mono_of_mem _
    rw [← ext_chart_at_source I] at hs
    rw [(extChartAt I x).image_eq_target_inter_inv_preimage hs]
    refine' inter_mem _ (ext_chart_preimage_mem_nhds_within' I x (hs hx') self_mem_nhds_within)
    have := ext_chart_at_target_mem_nhds_within' I x (hs hx')
    refine' nhds_within_mono _ (inter_subset_right _ _) this
    

/-- One can reformulate smoothness on a set as continuity on this set, and smoothness in any
extended chart. -/
theorem cont_mdiff_on_iff :
    ContMdiffOn I I' n f s ↔
      ContinuousOn f s ∧
        ∀ (x : M) (y : M'),
          ContDiffOn 𝕜 n (extChartAt I' y ∘ f ∘ (extChartAt I x).symm)
            ((extChartAt I x).Target ∩ (extChartAt I x).symm ⁻¹' (s ∩ f ⁻¹' (extChartAt I' y).Source)) :=
  by
  constructor
  · intro h
    refine' ⟨fun x hx => (h x hx).1, fun x y z hz => _⟩
    simp only [mfld_simps] at hz
    let w := (extChartAt I x).symm z
    have : w ∈ s := by simp only [w, hz, mfld_simps]
    specialize h w this
    have w1 : w ∈ (chart_at H x).Source := by simp only [w, hz, mfld_simps]
    have w2 : f w ∈ (chart_at H' y).Source := by simp only [w, hz, mfld_simps]
    convert ((cont_mdiff_within_at_iff_of_mem_source w1 w2).mp h).2.mono _
    · simp only [w, hz, mfld_simps]
      
    · mfld_set_tac
      
    
  · rintro ⟨hcont, hdiff⟩ x hx
    refine' ((cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_iff <| hcont x hx).mpr _
    dsimp [ContDiffWithinAtProp]
    convert hdiff x (f x) (extChartAt I x x) (by simp only [hx, mfld_simps]) using 1
    mfld_set_tac
    

/-- One can reformulate smoothness on a set as continuity on this set, and smoothness in any
extended chart in the target. -/
theorem cont_mdiff_on_iff_target :
    ContMdiffOn I I' n f s ↔
      ContinuousOn f s ∧
        ∀ y : M', ContMdiffOn I 𝓘(𝕜, E') n (extChartAt I' y ∘ f) (s ∩ f ⁻¹' (extChartAt I' y).Source) :=
  by
  inhabit E'
  simp only [cont_mdiff_on_iff, ModelWithCorners.source_eq, chart_at_self_eq, LocalHomeomorph.refl_local_equiv,
    LocalEquiv.refl_trans, extChartAt.equations._eqn_1, Set.preimage_univ, Set.inter_univ, and_congr_right_iff]
  intro h
  constructor
  · refine' fun h' y => ⟨_, fun x _ => h' x y⟩
    have h'' : ContinuousOn _ univ := (ModelWithCorners.continuous I').ContinuousOn
    convert (h''.comp' (chart_at H' y).continuous_to_fun).comp' h
    simp
    
  · exact fun h' x y => (h' y).2 x default
    

theorem smooth_on_iff :
    SmoothOn I I' f s ↔
      ContinuousOn f s ∧
        ∀ (x : M) (y : M'),
          ContDiffOn 𝕜 ⊤ (extChartAt I' y ∘ f ∘ (extChartAt I x).symm)
            ((extChartAt I x).Target ∩ (extChartAt I x).symm ⁻¹' (s ∩ f ⁻¹' (extChartAt I' y).Source)) :=
  cont_mdiff_on_iff

theorem smooth_on_iff_target :
    SmoothOn I I' f s ↔
      ContinuousOn f s ∧ ∀ y : M', SmoothOn I 𝓘(𝕜, E') (extChartAt I' y ∘ f) (s ∩ f ⁻¹' (extChartAt I' y).Source) :=
  cont_mdiff_on_iff_target

/-- One can reformulate smoothness as continuity and smoothness in any extended chart. -/
theorem cont_mdiff_iff :
    ContMdiff I I' n f ↔
      Continuous f ∧
        ∀ (x : M) (y : M'),
          ContDiffOn 𝕜 n (extChartAt I' y ∘ f ∘ (extChartAt I x).symm)
            ((extChartAt I x).Target ∩ (extChartAt I x).symm ⁻¹' (f ⁻¹' (extChartAt I' y).Source)) :=
  by simp [← cont_mdiff_on_univ, cont_mdiff_on_iff, continuous_iff_continuous_on_univ]

/-- One can reformulate smoothness as continuity and smoothness in any extended chart in the
target. -/
theorem cont_mdiff_iff_target :
    ContMdiff I I' n f ↔
      Continuous f ∧ ∀ y : M', ContMdiffOn I 𝓘(𝕜, E') n (extChartAt I' y ∘ f) (f ⁻¹' (extChartAt I' y).Source) :=
  by
  rw [← cont_mdiff_on_univ, cont_mdiff_on_iff_target]
  simp [continuous_iff_continuous_on_univ]

theorem smooth_iff :
    Smooth I I' f ↔
      Continuous f ∧
        ∀ (x : M) (y : M'),
          ContDiffOn 𝕜 ⊤ (extChartAt I' y ∘ f ∘ (extChartAt I x).symm)
            ((extChartAt I x).Target ∩ (extChartAt I x).symm ⁻¹' (f ⁻¹' (extChartAt I' y).Source)) :=
  cont_mdiff_iff

theorem smooth_iff_target :
    Smooth I I' f ↔
      Continuous f ∧ ∀ y : M', SmoothOn I 𝓘(𝕜, E') (extChartAt I' y ∘ f) (f ⁻¹' (extChartAt I' y).Source) :=
  cont_mdiff_iff_target

omit Is I's

/-! ### Deducing smoothness from higher smoothness -/


theorem ContMdiffWithinAt.ofLe (hf : ContMdiffWithinAt I I' n f s x) (le : m ≤ n) : ContMdiffWithinAt I I' m f s x :=
  ⟨hf.1, hf.2.ofLe le⟩

theorem ContMdiffAt.ofLe (hf : ContMdiffAt I I' n f x) (le : m ≤ n) : ContMdiffAt I I' m f x :=
  ContMdiffWithinAt.ofLe hf le

theorem ContMdiffOn.ofLe (hf : ContMdiffOn I I' n f s) (le : m ≤ n) : ContMdiffOn I I' m f s := fun x hx =>
  (hf x hx).ofLe le

theorem ContMdiff.ofLe (hf : ContMdiff I I' n f) (le : m ≤ n) : ContMdiff I I' m f := fun x => (hf x).ofLe le

/-! ### Deducing smoothness from smoothness one step beyond -/


theorem ContMdiffWithinAt.ofSucc {n : ℕ} (h : ContMdiffWithinAt I I' n.succ f s x) : ContMdiffWithinAt I I' n f s x :=
  h.ofLe (WithTop.coe_le_coe.2 (Nat.le_succ n))

theorem ContMdiffAt.ofSucc {n : ℕ} (h : ContMdiffAt I I' n.succ f x) : ContMdiffAt I I' n f x :=
  ContMdiffWithinAt.ofSucc h

theorem ContMdiffOn.ofSucc {n : ℕ} (h : ContMdiffOn I I' n.succ f s) : ContMdiffOn I I' n f s := fun x hx =>
  (h x hx).ofSucc

theorem ContMdiff.ofSucc {n : ℕ} (h : ContMdiff I I' n.succ f) : ContMdiff I I' n f := fun x => (h x).ofSucc

/-! ### Deducing continuity from smoothness -/


theorem ContMdiffWithinAt.continuous_within_at (hf : ContMdiffWithinAt I I' n f s x) : ContinuousWithinAt f s x :=
  hf.1

theorem ContMdiffAt.continuous_at (hf : ContMdiffAt I I' n f x) : ContinuousAt f x :=
  (continuous_within_at_univ _ _).1 <| ContMdiffWithinAt.continuous_within_at hf

theorem ContMdiffOn.continuous_on (hf : ContMdiffOn I I' n f s) : ContinuousOn f s := fun x hx =>
  (hf x hx).ContinuousWithinAt

theorem ContMdiff.continuous (hf : ContMdiff I I' n f) : Continuous f :=
  continuous_iff_continuous_at.2 fun x => (hf x).ContinuousAt

/-! ### `C^∞` smoothness -/


theorem cont_mdiff_within_at_top : SmoothWithinAt I I' f s x ↔ ∀ n : ℕ, ContMdiffWithinAt I I' n f s x :=
  ⟨fun h n => ⟨h.1, cont_diff_within_at_top.1 h.2 n⟩, fun H => ⟨(H 0).1, cont_diff_within_at_top.2 fun n => (H n).2⟩⟩

theorem cont_mdiff_at_top : SmoothAt I I' f x ↔ ∀ n : ℕ, ContMdiffAt I I' n f x :=
  cont_mdiff_within_at_top

theorem cont_mdiff_on_top : SmoothOn I I' f s ↔ ∀ n : ℕ, ContMdiffOn I I' n f s :=
  ⟨fun h n => h.ofLe le_top, fun h x hx => cont_mdiff_within_at_top.2 fun n => h n x hx⟩

theorem cont_mdiff_top : Smooth I I' f ↔ ∀ n : ℕ, ContMdiff I I' n f :=
  ⟨fun h n => h.ofLe le_top, fun h x => cont_mdiff_within_at_top.2 fun n => h n x⟩

theorem cont_mdiff_within_at_iff_nat :
    ContMdiffWithinAt I I' n f s x ↔ ∀ m : ℕ, (m : ℕ∞) ≤ n → ContMdiffWithinAt I I' m f s x := by
  refine' ⟨fun h m hm => h.ofLe hm, fun h => _⟩
  cases n
  · exact cont_mdiff_within_at_top.2 fun n => h n le_top
    
  · exact h n le_rfl
    

/-! ### Restriction to a smaller set -/


theorem ContMdiffWithinAt.mono (hf : ContMdiffWithinAt I I' n f s x) (hts : t ⊆ s) : ContMdiffWithinAt I I' n f t x :=
  StructureGroupoid.LocalInvariantProp.lift_prop_within_at_mono (contDiffWithinAtPropMono I I' n) hf hts

theorem ContMdiffAt.contMdiffWithinAt (hf : ContMdiffAt I I' n f x) : ContMdiffWithinAt I I' n f s x :=
  ContMdiffWithinAt.mono hf (subset_univ _)

theorem SmoothAt.smoothWithinAt (hf : SmoothAt I I' f x) : SmoothWithinAt I I' f s x :=
  ContMdiffAt.contMdiffWithinAt hf

theorem ContMdiffOn.mono (hf : ContMdiffOn I I' n f s) (hts : t ⊆ s) : ContMdiffOn I I' n f t := fun x hx =>
  (hf x (hts hx)).mono hts

theorem ContMdiff.contMdiffOn (hf : ContMdiff I I' n f) : ContMdiffOn I I' n f s := fun x hx => (hf x).ContMdiffWithinAt

theorem Smooth.smoothOn (hf : Smooth I I' f) : SmoothOn I I' f s :=
  ContMdiff.contMdiffOn hf

theorem cont_mdiff_within_at_inter' (ht : t ∈ 𝓝[s] x) :
    ContMdiffWithinAt I I' n f (s ∩ t) x ↔ ContMdiffWithinAt I I' n f s x :=
  (cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_inter' ht

theorem cont_mdiff_within_at_inter (ht : t ∈ 𝓝 x) :
    ContMdiffWithinAt I I' n f (s ∩ t) x ↔ ContMdiffWithinAt I I' n f s x :=
  (cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_inter ht

theorem ContMdiffWithinAt.contMdiffAt (h : ContMdiffWithinAt I I' n f s x) (ht : s ∈ 𝓝 x) : ContMdiffAt I I' n f x :=
  (cont_diff_within_at_local_invariant_prop I I' n).lift_prop_at_of_lift_prop_within_at h ht

theorem SmoothWithinAt.smoothAt (h : SmoothWithinAt I I' f s x) (ht : s ∈ 𝓝 x) : SmoothAt I I' f x :=
  ContMdiffWithinAt.contMdiffAt h ht

theorem ContMdiffOn.contMdiffAt (h : ContMdiffOn I I' n f s) (hx : s ∈ 𝓝 x) : ContMdiffAt I I' n f x :=
  (h x (mem_of_mem_nhds hx)).ContMdiffAt hx

theorem SmoothOn.smoothAt (h : SmoothOn I I' f s) (hx : s ∈ 𝓝 x) : SmoothAt I I' f x :=
  h.ContMdiffAt hx

include Is

theorem contMdiffOnExtChartAt : ContMdiffOn I 𝓘(𝕜, E) n (extChartAt I x) (chartAt H x).Source := fun x' hx' =>
  (contMdiffAtExtChartAt' hx').ContMdiffWithinAt

include I's

/-- A function is `C^n` within a set at a point, for `n : ℕ`, if and only if it is `C^n` on
a neighborhood of this point. -/
theorem cont_mdiff_within_at_iff_cont_mdiff_on_nhds {n : ℕ} :
    ContMdiffWithinAt I I' n f s x ↔ ∃ u ∈ 𝓝[insert x s] x, ContMdiffOn I I' n f u := by
  constructor
  · intro h
    -- the property is true in charts. We will pull such a good neighborhood in the chart to the
    -- manifold. For this, we need to restrict to a small enough set where everything makes sense
    obtain ⟨o, o_open, xo, ho, h'o⟩ :
      ∃ o : Set M, IsOpen o ∧ x ∈ o ∧ o ⊆ (chart_at H x).Source ∧ o ∩ s ⊆ f ⁻¹' (chart_at H' (f x)).Source := by
      have : (chart_at H' (f x)).Source ∈ 𝓝 (f x) :=
        IsOpen.mem_nhds (LocalHomeomorph.open_source _) (mem_chart_source H' (f x))
      rcases mem_nhds_within.1 (h.1.preimage_mem_nhds_within this) with ⟨u, u_open, xu, hu⟩
      refine' ⟨u ∩ (chart_at H x).Source, _, ⟨xu, mem_chart_source _ _⟩, _, _⟩
      · exact IsOpen.inter u_open (LocalHomeomorph.open_source _)
        
      · intro y hy
        exact hy.2
        
      · intro y hy
        exact hu ⟨hy.1.1, hy.2⟩
        
    have h' : ContMdiffWithinAt I I' n f (s ∩ o) x := h.mono (inter_subset_left _ _)
    simp only [ContMdiffWithinAt, lift_prop_within_at, ContDiffWithinAtProp] at h'
    -- let `u` be a good neighborhood in the chart where the function is smooth
    rcases h.2.ContDiffOn le_rfl with ⟨u, u_nhds, u_subset, hu⟩
    -- pull it back to the manifold, and intersect with a suitable neighborhood of `x`, to get the
    -- desired good neighborhood `v`.
    let v := insert x s ∩ o ∩ extChartAt I x ⁻¹' u
    have v_incl : v ⊆ (chart_at H x).Source := fun y hy => ho hy.1.2
    have v_incl' : ∀ y ∈ v, f y ∈ (chart_at H' (f x)).Source := by
      intro y hy
      rcases hy.1.1 with (rfl | h')
      · simp only [mfld_simps]
        
      · apply h'o ⟨hy.1.2, h'⟩
        
    refine' ⟨v, _, _⟩
    show v ∈ 𝓝[insert x s] x
    · rw [nhds_within_restrict _ xo o_open]
      refine' Filter.inter_mem self_mem_nhds_within _
      suffices : u ∈ 𝓝[extChartAt I x '' (insert x s ∩ o)] extChartAt I x x
      exact (ext_chart_at_continuous_at I x).ContinuousWithinAt.preimage_mem_nhds_within' this
      apply nhds_within_mono _ _ u_nhds
      rw [image_subset_iff]
      intro y hy
      rcases hy.1 with (rfl | h')
      · simp only [mem_insert_iff, mfld_simps]
        
      · simp only [mem_insert_iff, ho hy.2, h', h'o ⟨hy.2, h'⟩, mfld_simps]
        
      
    show ContMdiffOn I I' n f v
    · intro y hy
      have : ContinuousWithinAt f v y := by
        apply
          (((ext_chart_at_continuous_on_symm I' (f x) _ _).comp' (hu _ hy.2).ContinuousWithinAt).comp'
              (ext_chart_at_continuous_on I x _ _)).congr_mono
        · intro z hz
          simp only [v_incl hz, v_incl' z hz, mfld_simps]
          
        · intro z hz
          simp only [v_incl hz, v_incl' z hz, mfld_simps]
          exact hz.2
          
        · simp only [v_incl hy, v_incl' y hy, mfld_simps]
          
        · simp only [v_incl hy, v_incl' y hy, mfld_simps]
          
        · simp only [v_incl hy, mfld_simps]
          
      refine' (cont_mdiff_within_at_iff_of_mem_source' (v_incl hy) (v_incl' y hy)).mpr ⟨this, _⟩
      · apply hu.mono
        · intro z hz
          simp only [v, mfld_simps] at hz
          have : I ((chart_at H x) ((chart_at H x).symm (I.symm z))) ∈ u := by simp only [hz]
          simpa only [hz, mfld_simps] using this
          
        · have exty : I (chart_at H x y) ∈ u := hy.2
          simp only [v_incl hy, v_incl' y hy, exty, hy.1.1, hy.1.2, mfld_simps]
          
        
      
    
  · rintro ⟨u, u_nhds, hu⟩
    have : ContMdiffWithinAt I I' (↑n) f (insert x s ∩ u) x :=
      haveI : x ∈ insert x s := mem_insert x s
      hu.mono (inter_subset_right _ _) _ ⟨this, mem_of_mem_nhds_within this u_nhds⟩
    rw [cont_mdiff_within_at_inter' u_nhds] at this
    exact this.mono (subset_insert x s)
    

/-- A function is `C^n` at a point, for `n : ℕ`, if and only if it is `C^n` on
a neighborhood of this point. -/
theorem cont_mdiff_at_iff_cont_mdiff_on_nhds {n : ℕ} : ContMdiffAt I I' n f x ↔ ∃ u ∈ 𝓝 x, ContMdiffOn I I' n f u := by
  simp [← cont_mdiff_within_at_univ, cont_mdiff_within_at_iff_cont_mdiff_on_nhds, nhds_within_univ]

/-- Note: This does not hold for `n = ∞`. `f` being `C^∞` at `x` means that for every `n`, `f` is
`C^n` on some neighborhood of `x`, but this neighborhood can depend on `n`. -/
theorem cont_mdiff_at_iff_cont_mdiff_at_nhds {n : ℕ} : ContMdiffAt I I' n f x ↔ ∀ᶠ x' in 𝓝 x, ContMdiffAt I I' n f x' :=
  by
  refine' ⟨_, fun h => h.self_of_nhds⟩
  rw [cont_mdiff_at_iff_cont_mdiff_on_nhds]
  rintro ⟨u, hu, h⟩
  refine' (eventually_mem_nhds.mpr hu).mono fun x' hx' => _
  exact (h x' <| mem_of_mem_nhds hx').ContMdiffAt hx'

omit Is I's

/-! ### Congruence lemmas -/


theorem ContMdiffWithinAt.congr (h : ContMdiffWithinAt I I' n f s x) (h₁ : ∀ y ∈ s, f₁ y = f y) (hx : f₁ x = f x) :
    ContMdiffWithinAt I I' n f₁ s x :=
  (cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_congr h h₁ hx

theorem cont_mdiff_within_at_congr (h₁ : ∀ y ∈ s, f₁ y = f y) (hx : f₁ x = f x) :
    ContMdiffWithinAt I I' n f₁ s x ↔ ContMdiffWithinAt I I' n f s x :=
  (cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_congr_iff h₁ hx

theorem ContMdiffWithinAt.congrOfEventuallyEq (h : ContMdiffWithinAt I I' n f s x) (h₁ : f₁ =ᶠ[𝓝[s] x] f)
    (hx : f₁ x = f x) : ContMdiffWithinAt I I' n f₁ s x :=
  (cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_congr_of_eventually_eq h h₁ hx

theorem Filter.EventuallyEq.cont_mdiff_within_at_iff (h₁ : f₁ =ᶠ[𝓝[s] x] f) (hx : f₁ x = f x) :
    ContMdiffWithinAt I I' n f₁ s x ↔ ContMdiffWithinAt I I' n f s x :=
  (cont_diff_within_at_local_invariant_prop I I' n).lift_prop_within_at_congr_iff_of_eventually_eq h₁ hx

theorem ContMdiffAt.congrOfEventuallyEq (h : ContMdiffAt I I' n f x) (h₁ : f₁ =ᶠ[𝓝 x] f) : ContMdiffAt I I' n f₁ x :=
  (cont_diff_within_at_local_invariant_prop I I' n).lift_prop_at_congr_of_eventually_eq h h₁

theorem Filter.EventuallyEq.cont_mdiff_at_iff (h₁ : f₁ =ᶠ[𝓝 x] f) : ContMdiffAt I I' n f₁ x ↔ ContMdiffAt I I' n f x :=
  (cont_diff_within_at_local_invariant_prop I I' n).lift_prop_at_congr_iff_of_eventually_eq h₁

theorem ContMdiffOn.congr (h : ContMdiffOn I I' n f s) (h₁ : ∀ y ∈ s, f₁ y = f y) : ContMdiffOn I I' n f₁ s :=
  (cont_diff_within_at_local_invariant_prop I I' n).lift_prop_on_congr h h₁

theorem cont_mdiff_on_congr (h₁ : ∀ y ∈ s, f₁ y = f y) : ContMdiffOn I I' n f₁ s ↔ ContMdiffOn I I' n f s :=
  (cont_diff_within_at_local_invariant_prop I I' n).lift_prop_on_congr_iff h₁

/-! ### Locality -/


/-- Being `C^n` is a local property. -/
theorem contMdiffOnOfLocallyContMdiffOn (h : ∀ x ∈ s, ∃ u, IsOpen u ∧ x ∈ u ∧ ContMdiffOn I I' n f (s ∩ u)) :
    ContMdiffOn I I' n f s :=
  (cont_diff_within_at_local_invariant_prop I I' n).lift_prop_on_of_locally_lift_prop_on h

theorem contMdiffOfLocallyContMdiffOn (h : ∀ x, ∃ u, IsOpen u ∧ x ∈ u ∧ ContMdiffOn I I' n f u) : ContMdiff I I' n f :=
  (cont_diff_within_at_local_invariant_prop I I' n).lift_prop_of_locally_lift_prop_on h

/-! ### Smoothness of the composition of smooth functions between manifolds -/


section Composition

/-- The composition of `C^n` functions within domains at points is `C^n`. -/
theorem ContMdiffWithinAt.comp {t : Set M'} {g : M' → M''} (x : M) (hg : ContMdiffWithinAt I' I'' n g t (f x))
    (hf : ContMdiffWithinAt I I' n f s x) (st : MapsTo f s t) : ContMdiffWithinAt I I'' n (g ∘ f) s x := by
  rw [cont_mdiff_within_at_iff] at hg hf⊢
  refine' ⟨hg.1.comp hf.1 st, _⟩
  set e := extChartAt I x
  set e' := extChartAt I' (f x)
  set e'' := extChartAt I'' (g (f x))
  have : e' (f x) = (writtenInExtChartAt I I' x f) (e x) := by simp only [e, e', mfld_simps]
  rw [this] at hg
  have A :
    ∀ᶠ y in 𝓝[e.symm ⁻¹' s ∩ range I] e x,
      y ∈ e.target ∧ f (e.symm y) ∈ t ∧ f (e.symm y) ∈ e'.source ∧ g (f (e.symm y)) ∈ e''.source :=
    by
    simp only [← ext_chart_at_map_nhds_within, eventually_map]
    filter_upwards [hf.1.Tendsto (ext_chart_at_source_mem_nhds I' (f x)),
      (hg.1.comp hf.1 st).Tendsto (ext_chart_at_source_mem_nhds I'' (g (f x))),
      inter_mem_nhds_within s (ext_chart_at_source_mem_nhds I x)]
    rintro x' (hfx' : f x' ∈ _) (hgfx' : g (f x') ∈ _) ⟨hx's, hx'⟩
    simp only [e.map_source hx', true_and_iff, e.left_inv hx', st hx's, *]
  refine'
    ((hg.2.comp _ (hf.2.mono (inter_subset_right _ _)) (inter_subset_left _ _)).mono_of_mem
          (inter_mem _ self_mem_nhds_within)).congr_of_eventually_eq
      _ _
  · filter_upwards [A]
    rintro x' ⟨hx', ht, hfx', hgfx'⟩
    simp only [*, mem_preimage, writtenInExtChartAt, (· ∘ ·), mem_inter_iff, e'.left_inv, true_and_iff]
    exact mem_range_self _
    
  · filter_upwards [A]
    rintro x' ⟨hx', ht, hfx', hgfx'⟩
    simp only [*, (· ∘ ·), writtenInExtChartAt, e'.left_inv]
    
  · simp only [writtenInExtChartAt, (· ∘ ·), mem_ext_chart_source, e.left_inv, e'.left_inv]
    

/-- The composition of `C^∞` functions within domains at points is `C^∞`. -/
theorem SmoothWithinAt.comp {t : Set M'} {g : M' → M''} (x : M) (hg : SmoothWithinAt I' I'' g t (f x))
    (hf : SmoothWithinAt I I' f s x) (st : MapsTo f s t) : SmoothWithinAt I I'' (g ∘ f) s x :=
  hg.comp x hf st

/-- The composition of `C^n` functions on domains is `C^n`. -/
theorem ContMdiffOn.comp {t : Set M'} {g : M' → M''} (hg : ContMdiffOn I' I'' n g t) (hf : ContMdiffOn I I' n f s)
    (st : s ⊆ f ⁻¹' t) : ContMdiffOn I I'' n (g ∘ f) s := fun x hx => (hg _ (st hx)).comp x (hf x hx) st

/-- The composition of `C^∞` functions on domains is `C^∞`. -/
theorem SmoothOn.comp {t : Set M'} {g : M' → M''} (hg : SmoothOn I' I'' g t) (hf : SmoothOn I I' f s)
    (st : s ⊆ f ⁻¹' t) : SmoothOn I I'' (g ∘ f) s :=
  hg.comp hf st

/-- The composition of `C^n` functions on domains is `C^n`. -/
theorem ContMdiffOn.comp' {t : Set M'} {g : M' → M''} (hg : ContMdiffOn I' I'' n g t) (hf : ContMdiffOn I I' n f s) :
    ContMdiffOn I I'' n (g ∘ f) (s ∩ f ⁻¹' t) :=
  hg.comp (hf.mono (inter_subset_left _ _)) (inter_subset_right _ _)

/-- The composition of `C^∞` functions is `C^∞`. -/
theorem SmoothOn.comp' {t : Set M'} {g : M' → M''} (hg : SmoothOn I' I'' g t) (hf : SmoothOn I I' f s) :
    SmoothOn I I'' (g ∘ f) (s ∩ f ⁻¹' t) :=
  hg.comp' hf

/-- The composition of `C^n` functions is `C^n`. -/
theorem ContMdiff.comp {g : M' → M''} (hg : ContMdiff I' I'' n g) (hf : ContMdiff I I' n f) :
    ContMdiff I I'' n (g ∘ f) := by
  rw [← cont_mdiff_on_univ] at hf hg⊢
  exact hg.comp hf subset_preimage_univ

/-- The composition of `C^∞` functions is `C^∞`. -/
theorem Smooth.comp {g : M' → M''} (hg : Smooth I' I'' g) (hf : Smooth I I' f) : Smooth I I'' (g ∘ f) :=
  hg.comp hf

/-- The composition of `C^n` functions within domains at points is `C^n`. -/
theorem ContMdiffWithinAt.comp' {t : Set M'} {g : M' → M''} (x : M) (hg : ContMdiffWithinAt I' I'' n g t (f x))
    (hf : ContMdiffWithinAt I I' n f s x) : ContMdiffWithinAt I I'' n (g ∘ f) (s ∩ f ⁻¹' t) x :=
  hg.comp x (hf.mono (inter_subset_left _ _)) (inter_subset_right _ _)

/-- The composition of `C^∞` functions within domains at points is `C^∞`. -/
theorem SmoothWithinAt.comp' {t : Set M'} {g : M' → M''} (x : M) (hg : SmoothWithinAt I' I'' g t (f x))
    (hf : SmoothWithinAt I I' f s x) : SmoothWithinAt I I'' (g ∘ f) (s ∩ f ⁻¹' t) x :=
  hg.comp' x hf

/-- `g ∘ f` is `C^n` within `s` at `x` if `g` is `C^n` at `f x` and
`f` is `C^n` within `s` at `x`. -/
theorem ContMdiffAt.compContMdiffWithinAt {g : M' → M''} (x : M) (hg : ContMdiffAt I' I'' n g (f x))
    (hf : ContMdiffWithinAt I I' n f s x) : ContMdiffWithinAt I I'' n (g ∘ f) s x :=
  hg.comp x hf (maps_to_univ _ _)

/-- `g ∘ f` is `C^∞` within `s` at `x` if `g` is `C^∞` at `f x` and
`f` is `C^∞` within `s` at `x`. -/
theorem SmoothAt.compSmoothWithinAt {g : M' → M''} (x : M) (hg : SmoothAt I' I'' g (f x))
    (hf : SmoothWithinAt I I' f s x) : SmoothWithinAt I I'' (g ∘ f) s x :=
  hg.compContMdiffWithinAt x hf

/-- The composition of `C^n` functions at points is `C^n`. -/
theorem ContMdiffAt.comp {g : M' → M''} (x : M) (hg : ContMdiffAt I' I'' n g (f x)) (hf : ContMdiffAt I I' n f x) :
    ContMdiffAt I I'' n (g ∘ f) x :=
  hg.comp x hf (maps_to_univ _ _)

/-- The composition of `C^∞` functions at points is `C^∞`. -/
theorem SmoothAt.comp {g : M' → M''} (x : M) (hg : SmoothAt I' I'' g (f x)) (hf : SmoothAt I I' f x) :
    SmoothAt I I'' (g ∘ f) x :=
  hg.comp x hf

theorem ContMdiff.compContMdiffOn {f : M → M'} {g : M' → M''} {s : Set M} (hg : ContMdiff I' I'' n g)
    (hf : ContMdiffOn I I' n f s) : ContMdiffOn I I'' n (g ∘ f) s :=
  hg.ContMdiffOn.comp hf Set.subset_preimage_univ

theorem Smooth.compSmoothOn {f : M → M'} {g : M' → M''} {s : Set M} (hg : Smooth I' I'' g) (hf : SmoothOn I I' f s) :
    SmoothOn I I'' (g ∘ f) s :=
  hg.SmoothOn.comp hf Set.subset_preimage_univ

theorem ContMdiffOn.compContMdiff {t : Set M'} {g : M' → M''} (hg : ContMdiffOn I' I'' n g t) (hf : ContMdiff I I' n f)
    (ht : ∀ x, f x ∈ t) : ContMdiff I I'' n (g ∘ f) :=
  cont_mdiff_on_univ.mp <| hg.comp hf.ContMdiffOn fun x _ => ht x

theorem SmoothOn.compSmooth {t : Set M'} {g : M' → M''} (hg : SmoothOn I' I'' g t) (hf : Smooth I I' f)
    (ht : ∀ x, f x ∈ t) : Smooth I I'' (g ∘ f) :=
  hg.compContMdiff hf ht

end Composition

/-! ### Atlas members are smooth -/


section Atlas

variable {e : LocalHomeomorph M H}

include Is

/-- An atlas member is `C^n` for any `n`. -/
theorem contMdiffOnOfMemMaximalAtlas (h : e ∈ MaximalAtlas I M) : ContMdiffOn I I n e e.Source :=
  ContMdiffOn.ofLe
    ((cont_diff_within_at_local_invariant_prop I I ∞).lift_prop_on_of_mem_maximal_atlas (contDiffWithinAtPropId I) h)
    le_top

/-- The inverse of an atlas member is `C^n` for any `n`. -/
theorem contMdiffOnSymmOfMemMaximalAtlas (h : e ∈ MaximalAtlas I M) : ContMdiffOn I I n e.symm e.Target :=
  ContMdiffOn.ofLe
    ((cont_diff_within_at_local_invariant_prop I I ∞).lift_prop_on_symm_of_mem_maximal_atlas (contDiffWithinAtPropId I)
      h)
    le_top

theorem contMdiffOnChart : ContMdiffOn I I n (chartAt H x) (chartAt H x).Source :=
  contMdiffOnOfMemMaximalAtlas ((contDiffGroupoid ⊤ I).chart_mem_maximal_atlas x)

theorem contMdiffOnChartSymm : ContMdiffOn I I n (chartAt H x).symm (chartAt H x).Target :=
  contMdiffOnSymmOfMemMaximalAtlas ((contDiffGroupoid ⊤ I).chart_mem_maximal_atlas x)

end Atlas

/-! ### The identity is smooth -/


section id

theorem contMdiffId : ContMdiff I I n (id : M → M) :=
  ContMdiff.ofLe ((cont_diff_within_at_local_invariant_prop I I ∞).lift_prop_id (contDiffWithinAtPropId I)) le_top

theorem smoothId : Smooth I I (id : M → M) :=
  contMdiffId

theorem contMdiffOnId : ContMdiffOn I I n (id : M → M) s :=
  contMdiffId.ContMdiffOn

theorem smoothOnId : SmoothOn I I (id : M → M) s :=
  contMdiffOnId

theorem contMdiffAtId : ContMdiffAt I I n (id : M → M) x :=
  contMdiffId.ContMdiffAt

theorem smoothAtId : SmoothAt I I (id : M → M) x :=
  contMdiffAtId

theorem contMdiffWithinAtId : ContMdiffWithinAt I I n (id : M → M) s x :=
  contMdiffAtId.ContMdiffWithinAt

theorem smoothWithinAtId : SmoothWithinAt I I (id : M → M) s x :=
  contMdiffWithinAtId

end id

/-! ### Constants are smooth -/


section id

variable {c : M'}

theorem contMdiffConst : ContMdiff I I' n fun x : M => c := by
  intro x
  refine' ⟨continuous_within_at_const, _⟩
  simp only [ContDiffWithinAtProp, (· ∘ ·)]
  exact contDiffWithinAtConst

@[to_additive]
theorem contMdiffOne [One M'] : ContMdiff I I' n (1 : M → M') := by simp only [Pi.one_def, contMdiffConst]

theorem smoothConst : Smooth I I' fun x : M => c :=
  contMdiffConst

@[to_additive]
theorem smoothOne [One M'] : Smooth I I' (1 : M → M') := by simp only [Pi.one_def, smoothConst]

theorem contMdiffOnConst : ContMdiffOn I I' n (fun x : M => c) s :=
  contMdiffConst.ContMdiffOn

@[to_additive]
theorem contMdiffOnOne [One M'] : ContMdiffOn I I' n (1 : M → M') s :=
  contMdiffOne.ContMdiffOn

theorem smoothOnConst : SmoothOn I I' (fun x : M => c) s :=
  contMdiffOnConst

@[to_additive]
theorem smoothOnOne [One M'] : SmoothOn I I' (1 : M → M') s :=
  contMdiffOnOne

theorem contMdiffAtConst : ContMdiffAt I I' n (fun x : M => c) x :=
  contMdiffConst.ContMdiffAt

@[to_additive]
theorem contMdiffAtOne [One M'] : ContMdiffAt I I' n (1 : M → M') x :=
  contMdiffOne.ContMdiffAt

theorem smoothAtConst : SmoothAt I I' (fun x : M => c) x :=
  contMdiffAtConst

@[to_additive]
theorem smoothAtOne [One M'] : SmoothAt I I' (1 : M → M') x :=
  contMdiffAtOne

theorem contMdiffWithinAtConst : ContMdiffWithinAt I I' n (fun x : M => c) s x :=
  contMdiffAtConst.ContMdiffWithinAt

@[to_additive]
theorem contMdiffWithinAtOne [One M'] : ContMdiffWithinAt I I' n (1 : M → M') s x :=
  contMdiffAtConst.ContMdiffWithinAt

theorem smoothWithinAtConst : SmoothWithinAt I I' (fun x : M => c) s x :=
  contMdiffWithinAtConst

@[to_additive]
theorem smoothWithinAtOne [One M'] : SmoothWithinAt I I' (1 : M → M') s x :=
  contMdiffWithinAtOne

end id

theorem contMdiffOfSupport {f : M → F} (hf : ∀ x ∈ Tsupport f, ContMdiffAt I 𝓘(𝕜, F) n f x) : ContMdiff I 𝓘(𝕜, F) n f :=
  by
  intro x
  by_cases hx:x ∈ Tsupport f
  · exact hf x hx
    
  · refine' ContMdiffAt.congrOfEventuallyEq _ (eventually_eq_zero_nhds.2 hx)
    exact contMdiffAtConst
    

/-! ### Equivalence with the basic definition for functions between vector spaces -/


section Module

theorem cont_mdiff_within_at_iff_cont_diff_within_at {f : E → E'} {s : Set E} {x : E} :
    ContMdiffWithinAt 𝓘(𝕜, E) 𝓘(𝕜, E') n f s x ↔ ContDiffWithinAt 𝕜 n f s x := by
  simp (config := { contextual := true }) only [ContMdiffWithinAt, lift_prop_within_at, ContDiffWithinAtProp, iff_def,
    mfld_simps]
  exact ContDiffWithinAt.continuous_within_at

alias cont_mdiff_within_at_iff_cont_diff_within_at ↔
  ContMdiffWithinAt.contDiffWithinAt ContDiffWithinAt.contMdiffWithinAt

theorem cont_mdiff_at_iff_cont_diff_at {f : E → E'} {x : E} : ContMdiffAt 𝓘(𝕜, E) 𝓘(𝕜, E') n f x ↔ ContDiffAt 𝕜 n f x :=
  by rw [← cont_mdiff_within_at_univ, cont_mdiff_within_at_iff_cont_diff_within_at, cont_diff_within_at_univ]

alias cont_mdiff_at_iff_cont_diff_at ↔ ContMdiffAt.contDiffAt ContDiffAt.contMdiffAt

theorem cont_mdiff_on_iff_cont_diff_on {f : E → E'} {s : Set E} :
    ContMdiffOn 𝓘(𝕜, E) 𝓘(𝕜, E') n f s ↔ ContDiffOn 𝕜 n f s :=
  forall_congr' <| by simp [cont_mdiff_within_at_iff_cont_diff_within_at]

alias cont_mdiff_on_iff_cont_diff_on ↔ ContMdiffOn.contDiffOn ContDiffOn.contMdiffOn

theorem cont_mdiff_iff_cont_diff {f : E → E'} : ContMdiff 𝓘(𝕜, E) 𝓘(𝕜, E') n f ↔ ContDiff 𝕜 n f := by
  rw [← cont_diff_on_univ, ← cont_mdiff_on_univ, cont_mdiff_on_iff_cont_diff_on]

alias cont_mdiff_iff_cont_diff ↔ ContMdiff.contDiff ContDiff.contMdiff

theorem ContDiffWithinAt.compContMdiffWithinAt {g : F → F'} {f : M → F} {s : Set M} {t : Set F} {x : M}
    (hg : ContDiffWithinAt 𝕜 n g t (f x)) (hf : ContMdiffWithinAt I 𝓘(𝕜, F) n f s x) (h : s ⊆ f ⁻¹' t) :
    ContMdiffWithinAt I 𝓘(𝕜, F') n (g ∘ f) s x := by
  rw [cont_mdiff_within_at_iff] at *
  refine' ⟨hg.continuous_within_at.comp hf.1 h, _⟩
  rw [← (extChartAt I x).left_inv (mem_ext_chart_source I x)] at hg
  apply ContDiffWithinAt.comp _ hg hf.2 _
  exact (inter_subset_left _ _).trans (preimage_mono h)

theorem ContDiffAt.compContMdiffAt {g : F → F'} {f : M → F} {x : M} (hg : ContDiffAt 𝕜 n g (f x))
    (hf : ContMdiffAt I 𝓘(𝕜, F) n f x) : ContMdiffAt I 𝓘(𝕜, F') n (g ∘ f) x :=
  hg.compContMdiffWithinAt hf Subset.rfl

theorem ContDiff.compContMdiff {g : F → F'} {f : M → F} (hg : ContDiff 𝕜 n g) (hf : ContMdiff I 𝓘(𝕜, F) n f) :
    ContMdiff I 𝓘(𝕜, F') n (g ∘ f) := fun x => hg.ContDiffAt.compContMdiffAt (hf x)

end Module

/-! ### Smoothness of standard maps associated to the product of manifolds -/


section ProdMk

theorem ContMdiffWithinAt.prodMk {f : M → M'} {g : M → N'} (hf : ContMdiffWithinAt I I' n f s x)
    (hg : ContMdiffWithinAt I J' n g s x) : ContMdiffWithinAt I (I'.Prod J') n (fun x => (f x, g x)) s x := by
  rw [cont_mdiff_within_at_iff] at *
  exact ⟨hf.1.Prod hg.1, hf.2.Prod hg.2⟩

theorem ContMdiffWithinAt.prodMkSpace {f : M → E'} {g : M → F'} (hf : ContMdiffWithinAt I 𝓘(𝕜, E') n f s x)
    (hg : ContMdiffWithinAt I 𝓘(𝕜, F') n g s x) : ContMdiffWithinAt I 𝓘(𝕜, E' × F') n (fun x => (f x, g x)) s x := by
  rw [cont_mdiff_within_at_iff] at *
  exact ⟨hf.1.Prod hg.1, hf.2.Prod hg.2⟩

theorem ContMdiffAt.prodMk {f : M → M'} {g : M → N'} (hf : ContMdiffAt I I' n f x) (hg : ContMdiffAt I J' n g x) :
    ContMdiffAt I (I'.Prod J') n (fun x => (f x, g x)) x :=
  hf.prod_mk hg

theorem ContMdiffAt.prodMkSpace {f : M → E'} {g : M → F'} (hf : ContMdiffAt I 𝓘(𝕜, E') n f x)
    (hg : ContMdiffAt I 𝓘(𝕜, F') n g x) : ContMdiffAt I 𝓘(𝕜, E' × F') n (fun x => (f x, g x)) x :=
  hf.prodMkSpace hg

theorem ContMdiffOn.prodMk {f : M → M'} {g : M → N'} (hf : ContMdiffOn I I' n f s) (hg : ContMdiffOn I J' n g s) :
    ContMdiffOn I (I'.Prod J') n (fun x => (f x, g x)) s := fun x hx => (hf x hx).prod_mk (hg x hx)

theorem ContMdiffOn.prodMkSpace {f : M → E'} {g : M → F'} (hf : ContMdiffOn I 𝓘(𝕜, E') n f s)
    (hg : ContMdiffOn I 𝓘(𝕜, F') n g s) : ContMdiffOn I 𝓘(𝕜, E' × F') n (fun x => (f x, g x)) s := fun x hx =>
  (hf x hx).prodMkSpace (hg x hx)

theorem ContMdiff.prodMk {f : M → M'} {g : M → N'} (hf : ContMdiff I I' n f) (hg : ContMdiff I J' n g) :
    ContMdiff I (I'.Prod J') n fun x => (f x, g x) := fun x => (hf x).prod_mk (hg x)

theorem ContMdiff.prodMkSpace {f : M → E'} {g : M → F'} (hf : ContMdiff I 𝓘(𝕜, E') n f)
    (hg : ContMdiff I 𝓘(𝕜, F') n g) : ContMdiff I 𝓘(𝕜, E' × F') n fun x => (f x, g x) := fun x =>
  (hf x).prodMkSpace (hg x)

theorem SmoothWithinAt.prodMk {f : M → M'} {g : M → N'} (hf : SmoothWithinAt I I' f s x)
    (hg : SmoothWithinAt I J' g s x) : SmoothWithinAt I (I'.Prod J') (fun x => (f x, g x)) s x :=
  hf.prod_mk hg

theorem SmoothWithinAt.prodMkSpace {f : M → E'} {g : M → F'} (hf : SmoothWithinAt I 𝓘(𝕜, E') f s x)
    (hg : SmoothWithinAt I 𝓘(𝕜, F') g s x) : SmoothWithinAt I 𝓘(𝕜, E' × F') (fun x => (f x, g x)) s x :=
  hf.prodMkSpace hg

theorem SmoothAt.prodMk {f : M → M'} {g : M → N'} (hf : SmoothAt I I' f x) (hg : SmoothAt I J' g x) :
    SmoothAt I (I'.Prod J') (fun x => (f x, g x)) x :=
  hf.prod_mk hg

theorem SmoothAt.prodMkSpace {f : M → E'} {g : M → F'} (hf : SmoothAt I 𝓘(𝕜, E') f x) (hg : SmoothAt I 𝓘(𝕜, F') g x) :
    SmoothAt I 𝓘(𝕜, E' × F') (fun x => (f x, g x)) x :=
  hf.prodMkSpace hg

theorem SmoothOn.prodMk {f : M → M'} {g : M → N'} (hf : SmoothOn I I' f s) (hg : SmoothOn I J' g s) :
    SmoothOn I (I'.Prod J') (fun x => (f x, g x)) s :=
  hf.prod_mk hg

theorem SmoothOn.prodMkSpace {f : M → E'} {g : M → F'} (hf : SmoothOn I 𝓘(𝕜, E') f s) (hg : SmoothOn I 𝓘(𝕜, F') g s) :
    SmoothOn I 𝓘(𝕜, E' × F') (fun x => (f x, g x)) s :=
  hf.prodMkSpace hg

theorem Smooth.prodMk {f : M → M'} {g : M → N'} (hf : Smooth I I' f) (hg : Smooth I J' g) :
    Smooth I (I'.Prod J') fun x => (f x, g x) :=
  hf.prod_mk hg

theorem Smooth.prodMkSpace {f : M → E'} {g : M → F'} (hf : Smooth I 𝓘(𝕜, E') f) (hg : Smooth I 𝓘(𝕜, F') g) :
    Smooth I 𝓘(𝕜, E' × F') fun x => (f x, g x) :=
  hf.prodMkSpace hg

end ProdMk

section Projections

theorem contMdiffWithinAtFst {s : Set (M × N)} {p : M × N} : ContMdiffWithinAt (I.Prod J) I n Prod.fst s p := by
  rw [cont_mdiff_within_at_iff']
  refine' ⟨continuous_within_at_fst, _⟩
  refine' cont_diff_within_at_fst.congr (fun y hy => _) _
  · simp only [mfld_simps] at hy
    simp only [hy, mfld_simps]
    
  · simp only [mfld_simps]
    

theorem contMdiffAtFst {p : M × N} : ContMdiffAt (I.Prod J) I n Prod.fst p :=
  contMdiffWithinAtFst

theorem contMdiffOnFst {s : Set (M × N)} : ContMdiffOn (I.Prod J) I n Prod.fst s := fun x hx => contMdiffWithinAtFst

theorem contMdiffFst : ContMdiff (I.Prod J) I n (@Prod.fst M N) := fun x => contMdiffAtFst

theorem smoothWithinAtFst {s : Set (M × N)} {p : M × N} : SmoothWithinAt (I.Prod J) I Prod.fst s p :=
  contMdiffWithinAtFst

theorem smoothAtFst {p : M × N} : SmoothAt (I.Prod J) I Prod.fst p :=
  contMdiffAtFst

theorem smoothOnFst {s : Set (M × N)} : SmoothOn (I.Prod J) I Prod.fst s :=
  contMdiffOnFst

theorem smoothFst : Smooth (I.Prod J) I (@Prod.fst M N) :=
  contMdiffFst

theorem ContMdiffAt.fst {f : N → M × M'} {x : N} (hf : ContMdiffAt J (I.Prod I') n f x) :
    ContMdiffAt J I n (fun x => (f x).1) x :=
  contMdiffAtFst.comp x hf

theorem ContMdiff.fst {f : N → M × M'} (hf : ContMdiff J (I.Prod I') n f) : ContMdiff J I n fun x => (f x).1 :=
  contMdiffFst.comp hf

theorem SmoothAt.fst {f : N → M × M'} {x : N} (hf : SmoothAt J (I.Prod I') f x) : SmoothAt J I (fun x => (f x).1) x :=
  smoothAtFst.comp x hf

theorem Smooth.fst {f : N → M × M'} (hf : Smooth J (I.Prod I') f) : Smooth J I fun x => (f x).1 :=
  smoothFst.comp hf

theorem contMdiffWithinAtSnd {s : Set (M × N)} {p : M × N} : ContMdiffWithinAt (I.Prod J) J n Prod.snd s p := by
  rw [cont_mdiff_within_at_iff']
  refine' ⟨continuous_within_at_snd, _⟩
  refine' cont_diff_within_at_snd.congr (fun y hy => _) _
  · simp only [mfld_simps] at hy
    simp only [hy, mfld_simps]
    
  · simp only [mfld_simps]
    

theorem contMdiffAtSnd {p : M × N} : ContMdiffAt (I.Prod J) J n Prod.snd p :=
  contMdiffWithinAtSnd

theorem contMdiffOnSnd {s : Set (M × N)} : ContMdiffOn (I.Prod J) J n Prod.snd s := fun x hx => contMdiffWithinAtSnd

theorem contMdiffSnd : ContMdiff (I.Prod J) J n (@Prod.snd M N) := fun x => contMdiffAtSnd

theorem smoothWithinAtSnd {s : Set (M × N)} {p : M × N} : SmoothWithinAt (I.Prod J) J Prod.snd s p :=
  contMdiffWithinAtSnd

theorem smoothAtSnd {p : M × N} : SmoothAt (I.Prod J) J Prod.snd p :=
  contMdiffAtSnd

theorem smoothOnSnd {s : Set (M × N)} : SmoothOn (I.Prod J) J Prod.snd s :=
  contMdiffOnSnd

theorem smoothSnd : Smooth (I.Prod J) J (@Prod.snd M N) :=
  contMdiffSnd

theorem ContMdiffAt.snd {f : N → M × M'} {x : N} (hf : ContMdiffAt J (I.Prod I') n f x) :
    ContMdiffAt J I' n (fun x => (f x).2) x :=
  contMdiffAtSnd.comp x hf

theorem ContMdiff.snd {f : N → M × M'} (hf : ContMdiff J (I.Prod I') n f) : ContMdiff J I' n fun x => (f x).2 :=
  contMdiffSnd.comp hf

theorem SmoothAt.snd {f : N → M × M'} {x : N} (hf : SmoothAt J (I.Prod I') f x) : SmoothAt J I' (fun x => (f x).2) x :=
  smoothAtSnd.comp x hf

theorem Smooth.snd {f : N → M × M'} (hf : Smooth J (I.Prod I') f) : Smooth J I' fun x => (f x).2 :=
  smoothSnd.comp hf

theorem smooth_iff_proj_smooth {f : M → M' × N'} :
    Smooth I (I'.Prod J') f ↔ Smooth I I' (Prod.fst ∘ f) ∧ Smooth I J' (Prod.snd ∘ f) := by
  constructor
  · intro h
    exact ⟨smooth_fst.comp h, smooth_snd.comp h⟩
    
  · rintro ⟨h_fst, h_snd⟩
    simpa only [Prod.mk.eta] using h_fst.prod_mk h_snd
    

theorem smoothProdAssoc :
    Smooth ((I.Prod I').Prod J) (I.Prod (I'.Prod J)) fun x : (M × M') × N => (x.1.1, x.1.2, x.2) :=
  smoothFst.fst.prod_mk <| smoothFst.snd.prod_mk smoothSnd

end Projections

section prod_map

variable {g : N → N'} {r : Set N} {y : N}

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- The product map of two `C^n` functions within a set at a point is `C^n`
within the product set at the product point. -/
theorem ContMdiffWithinAt.prodMap' {p : M × N} (hf : ContMdiffWithinAt I I' n f s p.1)
    (hg : ContMdiffWithinAt J J' n g r p.2) : ContMdiffWithinAt (I.Prod J) (I'.Prod J') n (Prod.map f g) (s ×ˢ r) p :=
  (hf.comp p contMdiffWithinAtFst (prod_subset_preimage_fst _ _)).prod_mk <|
    hg.comp p contMdiffWithinAtSnd (prod_subset_preimage_snd _ _)

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem ContMdiffWithinAt.prodMap (hf : ContMdiffWithinAt I I' n f s x) (hg : ContMdiffWithinAt J J' n g r y) :
    ContMdiffWithinAt (I.Prod J) (I'.Prod J') n (Prod.map f g) (s ×ˢ r) (x, y) :=
  ContMdiffWithinAt.prodMap' hf hg

theorem ContMdiffAt.prodMap (hf : ContMdiffAt I I' n f x) (hg : ContMdiffAt J J' n g y) :
    ContMdiffAt (I.Prod J) (I'.Prod J') n (Prod.map f g) (x, y) := by
  rw [← cont_mdiff_within_at_univ] at *
  convert hf.prod_map hg
  exact univ_prod_univ.symm

theorem ContMdiffAt.prodMap' {p : M × N} (hf : ContMdiffAt I I' n f p.1) (hg : ContMdiffAt J J' n g p.2) :
    ContMdiffAt (I.Prod J) (I'.Prod J') n (Prod.map f g) p := by
  rcases p with ⟨⟩
  exact hf.prod_map hg

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem ContMdiffOn.prodMap (hf : ContMdiffOn I I' n f s) (hg : ContMdiffOn J J' n g r) :
    ContMdiffOn (I.Prod J) (I'.Prod J') n (Prod.map f g) (s ×ˢ r) :=
  (hf.comp contMdiffOnFst (prod_subset_preimage_fst _ _)).prod_mk <|
    hg.comp contMdiffOnSnd (prod_subset_preimage_snd _ _)

theorem ContMdiff.prodMap (hf : ContMdiff I I' n f) (hg : ContMdiff J J' n g) :
    ContMdiff (I.Prod J) (I'.Prod J') n (Prod.map f g) := by
  intro p
  exact (hf p.1).prod_map' (hg p.2)

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem SmoothWithinAt.prodMap (hf : SmoothWithinAt I I' f s x) (hg : SmoothWithinAt J J' g r y) :
    SmoothWithinAt (I.Prod J) (I'.Prod J') (Prod.map f g) (s ×ˢ r) (x, y) :=
  hf.prod_map hg

theorem SmoothAt.prodMap (hf : SmoothAt I I' f x) (hg : SmoothAt J J' g y) :
    SmoothAt (I.Prod J) (I'.Prod J') (Prod.map f g) (x, y) :=
  hf.prod_map hg

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem SmoothOn.prodMap (hf : SmoothOn I I' f s) (hg : SmoothOn J J' g r) :
    SmoothOn (I.Prod J) (I'.Prod J') (Prod.map f g) (s ×ˢ r) :=
  hf.prod_map hg

theorem Smooth.prodMap (hf : Smooth I I' f) (hg : Smooth J J' g) : Smooth (I.Prod J) (I'.Prod J') (Prod.map f g) :=
  hf.prod_map hg

end prod_map

section PiSpace

/-!
### Smoothness of functions with codomain `Π i, F i`

We have no `model_with_corners.pi` yet, so we prove lemmas about functions `f : M → Π i, F i` and
use `𝓘(𝕜, Π i, F i)` as the model space.
-/


variable {ι : Type _} [Fintype ι] {Fi : ι → Type _} [∀ i, NormedAddCommGroup (Fi i)] [∀ i, NormedSpace 𝕜 (Fi i)]
  {φ : M → ∀ i, Fi i}

theorem cont_mdiff_within_at_pi_space :
    ContMdiffWithinAt I 𝓘(𝕜, ∀ i, Fi i) n φ s x ↔ ∀ i, ContMdiffWithinAt I 𝓘(𝕜, Fi i) n (fun x => φ x i) s x := by
  simp only [cont_mdiff_within_at_iff, continuous_within_at_pi, cont_diff_within_at_pi, forall_and, writtenInExtChartAt,
    ext_chart_model_space_eq_id, (· ∘ ·), LocalEquiv.refl_coe, id]

theorem cont_mdiff_on_pi_space :
    ContMdiffOn I 𝓘(𝕜, ∀ i, Fi i) n φ s ↔ ∀ i, ContMdiffOn I 𝓘(𝕜, Fi i) n (fun x => φ x i) s :=
  ⟨fun h i x hx => cont_mdiff_within_at_pi_space.1 (h x hx) i, fun h x hx =>
    cont_mdiff_within_at_pi_space.2 fun i => h i x hx⟩

theorem cont_mdiff_at_pi_space :
    ContMdiffAt I 𝓘(𝕜, ∀ i, Fi i) n φ x ↔ ∀ i, ContMdiffAt I 𝓘(𝕜, Fi i) n (fun x => φ x i) x :=
  cont_mdiff_within_at_pi_space

theorem cont_mdiff_pi_space : ContMdiff I 𝓘(𝕜, ∀ i, Fi i) n φ ↔ ∀ i, ContMdiff I 𝓘(𝕜, Fi i) n fun x => φ x i :=
  ⟨fun h i x => cont_mdiff_at_pi_space.1 (h x) i, fun h x => cont_mdiff_at_pi_space.2 fun i => h i x⟩

theorem smooth_within_at_pi_space :
    SmoothWithinAt I 𝓘(𝕜, ∀ i, Fi i) φ s x ↔ ∀ i, SmoothWithinAt I 𝓘(𝕜, Fi i) (fun x => φ x i) s x :=
  cont_mdiff_within_at_pi_space

theorem smooth_on_pi_space : SmoothOn I 𝓘(𝕜, ∀ i, Fi i) φ s ↔ ∀ i, SmoothOn I 𝓘(𝕜, Fi i) (fun x => φ x i) s :=
  cont_mdiff_on_pi_space

theorem smooth_at_pi_space : SmoothAt I 𝓘(𝕜, ∀ i, Fi i) φ x ↔ ∀ i, SmoothAt I 𝓘(𝕜, Fi i) (fun x => φ x i) x :=
  cont_mdiff_at_pi_space

theorem smooth_pi_space : Smooth I 𝓘(𝕜, ∀ i, Fi i) φ ↔ ∀ i, Smooth I 𝓘(𝕜, Fi i) fun x => φ x i :=
  cont_mdiff_pi_space

end PiSpace

/-! ### Linear maps between normed spaces are smooth -/


theorem ContinuousLinearMap.contMdiff (L : E →L[𝕜] F) : ContMdiff 𝓘(𝕜, E) 𝓘(𝕜, F) n L :=
  L.ContDiff.ContMdiff

-- the following proof takes very long to elaborate in pure term mode
theorem ContMdiffAt.clmComp {g : M → F →L[𝕜] F''} {f : M → F' →L[𝕜] F} {x : M}
    (hg : ContMdiffAt I 𝓘(𝕜, F →L[𝕜] F'') n g x) (hf : ContMdiffAt I 𝓘(𝕜, F' →L[𝕜] F) n f x) :
    ContMdiffAt I 𝓘(𝕜, F' →L[𝕜] F'') n (fun x => (g x).comp (f x)) x :=
  @ContDiffAt.compContMdiffAt _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ (fun x : (F →L[𝕜] F'') × (F' →L[𝕜] F) => x.1.comp x.2)
    (fun x => (g x, f x)) x
    (by
      apply ContDiff.contDiffAt
      apply IsBoundedBilinearMap.contDiff
      exact isBoundedBilinearMapComp)
    (-- todo: simplify after #16946
        hg.prodMkSpace
      hf)

theorem ContMdiff.clmComp {g : M → F →L[𝕜] F''} {f : M → F' →L[𝕜] F} (hg : ContMdiff I 𝓘(𝕜, F →L[𝕜] F'') n g)
    (hf : ContMdiff I 𝓘(𝕜, F' →L[𝕜] F) n f) : ContMdiff I 𝓘(𝕜, F' →L[𝕜] F'') n fun x => (g x).comp (f x) := fun x =>
  (hg x).clm_comp (hf x)

/-! ### Smoothness of standard operations -/


variable {V : Type _} [NormedAddCommGroup V] [NormedSpace 𝕜 V]

/-- On any vector space, multiplication by a scalar is a smooth operation. -/
theorem smoothSmul : Smooth (𝓘(𝕜).Prod 𝓘(𝕜, V)) 𝓘(𝕜, V) fun p : 𝕜 × V => p.1 • p.2 :=
  smooth_iff.2 ⟨continuous_smul, fun x y => contDiffSmul.ContDiffOn⟩

theorem ContMdiffWithinAt.smul {f : M → 𝕜} {g : M → V} (hf : ContMdiffWithinAt I 𝓘(𝕜) n f s x)
    (hg : ContMdiffWithinAt I 𝓘(𝕜, V) n g s x) : ContMdiffWithinAt I 𝓘(𝕜, V) n (fun p => f p • g p) s x :=
  (smoothSmul.ofLe le_top).ContMdiffAt.compContMdiffWithinAt x (hf.prod_mk hg)

theorem ContMdiffAt.smul {f : M → 𝕜} {g : M → V} (hf : ContMdiffAt I 𝓘(𝕜) n f x) (hg : ContMdiffAt I 𝓘(𝕜, V) n g x) :
    ContMdiffAt I 𝓘(𝕜, V) n (fun p => f p • g p) x :=
  hf.smul hg

theorem ContMdiffOn.smul {f : M → 𝕜} {g : M → V} (hf : ContMdiffOn I 𝓘(𝕜) n f s) (hg : ContMdiffOn I 𝓘(𝕜, V) n g s) :
    ContMdiffOn I 𝓘(𝕜, V) n (fun p => f p • g p) s := fun x hx => (hf x hx).smul (hg x hx)

theorem ContMdiff.smul {f : M → 𝕜} {g : M → V} (hf : ContMdiff I 𝓘(𝕜) n f) (hg : ContMdiff I 𝓘(𝕜, V) n g) :
    ContMdiff I 𝓘(𝕜, V) n fun p => f p • g p := fun x => (hf x).smul (hg x)

theorem SmoothWithinAt.smul {f : M → 𝕜} {g : M → V} (hf : SmoothWithinAt I 𝓘(𝕜) f s x)
    (hg : SmoothWithinAt I 𝓘(𝕜, V) g s x) : SmoothWithinAt I 𝓘(𝕜, V) (fun p => f p • g p) s x :=
  hf.smul hg

theorem SmoothAt.smul {f : M → 𝕜} {g : M → V} (hf : SmoothAt I 𝓘(𝕜) f x) (hg : SmoothAt I 𝓘(𝕜, V) g x) :
    SmoothAt I 𝓘(𝕜, V) (fun p => f p • g p) x :=
  hf.smul hg

theorem SmoothOn.smul {f : M → 𝕜} {g : M → V} (hf : SmoothOn I 𝓘(𝕜) f s) (hg : SmoothOn I 𝓘(𝕜, V) g s) :
    SmoothOn I 𝓘(𝕜, V) (fun p => f p • g p) s :=
  hf.smul hg

theorem Smooth.smul {f : M → 𝕜} {g : M → V} (hf : Smooth I 𝓘(𝕜) f) (hg : Smooth I 𝓘(𝕜, V) g) :
    Smooth I 𝓘(𝕜, V) fun p => f p • g p :=
  hf.smul hg

